# GitHealth

**Version: 0.0.3**

A Bash script to perform essential health checks on your Git repositories. `githealth` helps you identify potential issues like large files, outdated dependencies in Node.js (npm/Bun) and Python projects, and potentially unoptimized images. Running these checks can help improve repository performance, reduce clone times, enhance security, and maintain overall code health.

## Why GitHealth?

* **Performance:** Large files bloat repository size, slowing down clones and fetches.
* **Maintainability:** Keeping dependencies updated is crucial for security and leveraging the latest features.
* **Storage:** Unoptimized images can consume unnecessary space.
* **Best Practices:** Encourages good repository hygiene.
  
## Features

* **Large Files Check:** Identifies files committed to the Git history larger than a specified size threshold. (Default: 500 KB)
* **Outdated Dependencies Check:** Detects outdated dependencies in projects using Node.js (`package.json` with `npm`) and Python (`requirements.txt` with `pip`).
* **Unoptimized Images Check:** Finds image files (`.png`, `.jpg`, `.jpeg`) with quality potentially higher than necessary (suggesting they could be optimized further). Requires ImageMagick. (Default quality threshold: 80)

## Prerequisites

Before running `githealth`, ensure you have the following installed:

* **Bash:** The script is written for Bash.
* **Git:** Essential for interacting with the repository.
* **awk:** Used for text processing (usually standard on Linux/macOS).
* **(Optional) Bun:** Required for checking Bun dependencies (`bun outdated`).
* **(Optional) Node.js & npm:** Required for checking Node.js dependencies if not using Bun (`npm outdated`).
* **(Optional) Python & pip:** Required for checking Python dependencies (`pip list --outdated`).
* **(Optional) ImageMagick:** Required for the unoptimized image check (`identify` command).
    * *Installation (examples):*
        * Debian/Ubuntu: `sudo apt update && sudo apt install imagemagick`
        * macOS (Homebrew): `brew install imagemagick`
        * Bun: See official Bun installation instructions.

## Configuration

You can configure the thresholds by:

1.  **Editing the script:** Modify the default values for the following variables near the top of `githealth.sh`:
    * `DEFAULT_LARGE_FILE_THRESHOLD_KB`: Size threshold in KB for large files (Default: 500).
    * `DEFAULT_IMAGE_QUALITY_THRESHOLD`: Quality threshold for images (Default: 80). Images *above* this quality will be flagged.
2.  **Using Environment Variables:** Override the defaults by setting environment variables before running the script:
    ```bash
    export LARGE_FILE_THRESHOLD_KB=1000 # Set large file threshold to 1MB
    export IMAGE_QUALITY_THRESHOLD=85  # Set image quality threshold to 85
    ./githealth.sh
    ```
    Or inline:
    ```bash
    LARGE_FILE_THRESHOLD_KB=1000 IMAGE_QUALITY_THRESHOLD=85 ./githealth.sh
    ```
