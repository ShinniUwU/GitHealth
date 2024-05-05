# Git Health Check

This repository contains a Bash script (`git_health_check.sh`) that performs health checks on a Git repository. It checks for:
- Large files (greater than a specified size).
- Outdated dependencies (for Node.js and Python projects).
- Unoptimized images (with adjustable quality threshold).

## Usage

Run the script from the terminal within a Git repository:
```bash
./git_health_check.sh
