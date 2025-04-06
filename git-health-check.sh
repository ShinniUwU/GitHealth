#!/bin/bash

# GitHealth - Git Repository Health Checker
# Version: 0.0.3
# Checks for large files, outdated dependencies (Node/Bun/Python), and unoptimized images.

# --- Configuration ---
# Adjust default thresholds here or override with environment variables.
DEFAULT_LARGE_FILE_THRESHOLD_KB=500
DEFAULT_IMAGE_QUALITY_THRESHOLD=80 # Flags images with quality *above* this value

# Use environment variables if set, otherwise use defaults
LARGE_FILE_THRESHOLD_KB="${LARGE_FILE_THRESHOLD_KB:-$DEFAULT_LARGE_FILE_THRESHOLD_KB}"
IMAGE_QUALITY_THRESHOLD="${IMAGE_QUALITY_THRESHOLD:-$DEFAULT_IMAGE_QUALITY_THRESHOLD}"
LARGE_FILE_THRESHOLD_BYTES=$((LARGE_FILE_THRESHOLD_KB * 1024))

# --- Helper Functions ---

# Function to print errors to stderr
error_msg() {
  printf "Error: %s\n" "$1" >&2
}

# Function to print warnings to stderr
warning_msg() {
  printf "Warning: %s\n" "$1" >&2
}

# Function to check if the script is run in a Git repository
ensure_git_repo() {
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    error_msg "This script must be run inside a Git repository."
    exit 1
  fi
}

# --- Check Functions ---

# Function to check for large files in the repository history
check_large_files() {
  printf "Checking for large files (>%d KB)...\n" "$LARGE_FILE_THRESHOLD_KB"

  local large_files_found=0
  local large_files_output
  large_files_output=$(git rev-list --objects --all |
    git cat-file --batch-check='%(objectname) %(objecttype) %(objectsize) %(rest)' |
    awk -v threshold="$LARGE_FILE_THRESHOLD_BYTES" '$3 > threshold && $2 == "blob" {
        # Extract filename if available in %(rest)
        sub(/^[^\t]+\t/, "", $4);
        printf "  - %s (%.0f KB) SHA: %s\n", $4, $3/1024, $1
    }')

  if [[ -n "$large_files_output" ]]; then
    printf "Found large files:\n%s\n" "$large_files_output"
    large_files_found=1
  fi

  if [[ "$large_files_found" -eq 0 ]]; then
    printf "No large files found.\n"
  fi
}

# Function to check for outdated dependencies
check_outdated_dependencies() {
  printf "Checking for outdated dependencies...\n"

  local found_outdated=0
  local project_type_detected=0
  local node_project_checked=0 # Flag to prevent checking npm if bun already checked

  # Check for Bun project (prioritize if bun.lockb exists)
  if [ -f "bun.lockb" ]; then
    project_type_detected=1
    node_project_checked=1 # Consider Node/JS checked if bun.lockb exists
    printf "Bun project detected (bun.lockb). "
    if command -v bun &>/dev/null; then
      printf "Checking outdated dependencies with bun...\n"
      local bun_output
      bun_output=$(bun outdated 2>&1)
      local bun_exit_code=$?
      # bun outdated exits non-zero if outdated packages exist
      if [[ $bun_exit_code -ne 0 ]]; then
          # Check if the output indicates an actual error vs just outdated packages
          if echo "$bun_output" | grep -q -E '(error:|ERR!)'; then
             warning_msg "bun outdated command may have failed:\n$bun_output"
          else
             printf "Outdated bun packages found:\n%s\n" "$bun_output"
             found_outdated=1
          fi
      elif [[ $bun_exit_code -eq 0 ]]; then
        # Exit code 0 means no outdated packages found
        printf "No outdated bun packages found.\n"
      fi
    else
      warning_msg "'bun' command not found, but bun.lockb exists. Skipping Bun dependency check."
    fi
  fi

  # Check for Node.js project (npm) - only if bun check wasn't performed
  if [[ "$node_project_checked" -eq 0 && -f "package.json" ]]; then
     project_type_detected=1
     printf "Node.js project detected (package.json). "
     if command -v npm &>/dev/null; then
       printf "Checking outdated dependencies with npm...\n"
       local npm_outdated_output
       npm_outdated_output=$(npm outdated 2>&1)
       local npm_exit_code=$?

       if [[ $npm_exit_code -ne 0 && -n "$npm_outdated_output" ]]; then
         if [[ "$npm_outdated_output" == *"ERR!"* ]]; then
            warning_msg "npm outdated command failed:\n$npm_outdated_output"
         else
            printf "Outdated npm packages found:\n%s\n" "$npm_outdated_output"
            found_outdated=1
         fi
       elif [[ $npm_exit_code -eq 0 ]]; then
         printf "No outdated npm packages found.\n"
       fi
     else
       warning_msg "npm command not found. Skipping Node.js dependency check (package.json found)."
     fi
  fi

  # Check for Python project (pip) - independent check
  if [ -f "requirements.txt" ]; then
    project_type_detected=1
    printf "Python project detected (requirements.txt). "
     if command -v pip &>/dev/null; then
        printf "Checking outdated dependencies with pip...\n"
        local pip_outdated_output
        pip_outdated_output=$(pip list --outdated 2>&1)
        local pip_exit_code=$?

        if [[ $pip_exit_code -eq 0 ]]; then
            if echo "$pip_outdated_output" | grep -q -E '^[a-zA-Z0-9]'; then # Check if there's output beyond the header
                printf "Outdated pip packages found:\n%s\n" "$pip_outdated_output"
                found_outdated=1
            else
                printf "No outdated pip packages found.\n"
            fi
        else
             warning_msg "pip list --outdated command failed:\n$pip_outdated_output"
        fi
    else
      warning_msg "pip command not found. Skipping Python dependency check (requirements.txt found)."
    fi
  fi

   # Final message if no supported files found
   if [[ "$project_type_detected" -eq 0 ]]; then
    printf "No supported dependency files found (bun.lockb, package.json, requirements.txt).\n"
   fi
}


# Function to check for potentially unoptimized images (high quality)
check_unoptimized_images() {
  printf "Checking for unoptimized images (Quality > %d)...\n" "$IMAGE_QUALITY_THRESHOLD"

  if ! command -v identify &>/dev/null; then
    warning_msg "'identify' command not found (part of ImageMagick). Skipping image optimization check."
    printf "Install ImageMagick to enable this check.\n"
    return
  fi

  local unoptimized_images_found=0
  local image_output
  image_output=$(find . -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) -exec identify -format "%i: %Q\n" {} \; 2>/dev/null |
                 awk -v threshold="$IMAGE_QUALITY_THRESHOLD" '$2 > threshold {print "  - " $1 " (Quality: " $2 ")"}' )

  if [[ -n "$image_output" ]]; then
    printf "Found potentially unoptimized images:\n%s\n" "$image_output"
    unoptimized_images_found=1
  fi

  if [[ "$unoptimized_images_found" -eq 0 ]]; then
     printf "No potentially unoptimized images found (above quality %d).\n" "$IMAGE_QUALITY_THRESHOLD"
  fi
}

# --- Main Execution ---
main() {
  printf "\n--- Git Repository Health Check ---\n\n"
  ensure_git_repo # Exit if not a git repo

  check_large_files
  printf "\n"

  check_outdated_dependencies
  printf "\n"

  check_unoptimized_images
  printf "\n"

  printf "--- Check Complete ---\n"
}

# Run the main function
main
