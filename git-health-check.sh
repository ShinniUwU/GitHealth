#!/bin/bash

# Git Repository Health Checker

# Check if the script is run in a Git repository
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "This script must be run inside a Git repository."
  exit 1
fi

# Check large files in the repository
check_large_files() {
  local threshold_kb=500 # Threshold size in KB (adjust as needed)
  echo "Checking for large files (>$threshold_kb KB)..."
  
  # Find files larger than the threshold size
  git lfs ls-files --size | awk -v threshold=$((threshold_kb * 1024)) '$2 > threshold {print $1 ": " $2 " bytes"}'
  
  # If Git LFS is not being used, use alternative method
  if [ $? -ne 0 ]; then
    git ls-tree -r --long HEAD | awk -v threshold=$((threshold_kb * 1024)) '$4 > threshold {print $6 " (" $4 " bytes)"}'
  fi
}

# Check outdated dependencies
check_outdated_dependencies() {
  echo "Checking for outdated dependencies..."
  
  # Check if a package.json file exists
  if [ -f "package.json" ]; then
    echo "Node.js project detected. Checking for outdated dependencies..."
    npm outdated
  fi
  
  # Check if a requirements.txt file exists
  if [ -f "requirements.txt" ]; then
    echo "Python project detected. Checking for outdated dependencies..."
    pip list --outdated
  fi
}

# Check unoptimized images
check_unoptimized_images() {
  echo "Checking for unoptimized images..."
  
  # Find image files that can be optimized
  find . -type f \( -name "*.png" -o -name "*.jpg" \) -exec identify -format "%i: %Q\n" {} \; | awk '$2 > 80 {print $1}' # Adjust the quality threshold as needed
}

# Perform all checks
perform_checks() {
  check_large_files
  echo ""
  
  check_outdated_dependencies
  echo ""
  
  check_unoptimized_images
}

# Execute the checks
perform_checks
