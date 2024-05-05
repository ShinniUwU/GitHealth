#!/bin/bash

# Git Repository Health Checker

# Function to check if the script is run in a Git repository
ensure_git_repo() {
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "Error: This script must be run inside a Git repository."
    exit 1
  fi
}

# Function to check for large files in the repository
check_large_files() {
  local threshold_kb=500  # Adjust threshold size as needed

  echo "Checking for large files (>$threshold_kb KB)..."

  # Use git lfs to list large files if available
  if command -v git-lfs &>/dev/null; then
    git lfs ls-files --size | awk -v threshold=$((threshold_kb * 1024)) '$2 > threshold {print $1 ": " $2 " bytes"}'
  else
    # Alternative method using git ls-tree
    git ls-tree -r --long HEAD | awk -v threshold=$((threshold_kb * 1024)) '$4 > threshold {print $6 " (" $4 " bytes)"}'
  fi
}

# Function to check for outdated dependencies
check_outdated_dependencies() {
  echo "Checking for outdated dependencies..."

  # Check for Node.js project
  if [ -f "package.json" ]; then
    echo "Node.js project detected. Checking for outdated dependencies..."
    npm outdated || echo "Failed to check Node.js dependencies. Make sure npm is installed and properly configured."
  fi

  # Check for Python project
  if [ -f "requirements.txt" ]; then
    echo "Python project detected. Checking for outdated dependencies..."
    pip list --outdated || echo "Failed to check Python dependencies. Make sure pip is installed and properly configured."
  fi
}

# Function to check for unoptimized images
check_unoptimized_images() {
  echo "Checking for unoptimized images..."

  # Find image files (JPEG and PNG) and list those with quality below threshold
  find . -type f \( -name "*.png" -o -name "*.jpg" \) -exec identify -format "%i: %Q\n" {} \; | awk '$2 < 80 {print $1}' # Adjust the quality threshold as needed
}

# Perform all checks
perform_checks() {
  ensure_git_repo
  check_large_files
  echo ""

  check_outdated_dependencies
  echo ""

  check_unoptimized_images
}

# Execute the checks
perform_checks
