# GitHealth

A Bash script to perform health checks on Git repositories. `githealth` checks for large files, outdated dependencies in Node.js and Python projects, and unoptimized images. By running this script, you can improve the performance and maintainability of your repository.

## Features

- **Large Files Check**: Identifies files in the repository larger than a specified threshold (default: 500 KB). Adjust the threshold as needed.
- **Outdated Dependencies Check**: Checks for outdated dependencies in projects using Node.js (`package.json`) and Python (`requirements.txt`).
- **Unoptimized Images Check**: Finds image files (`.png` and `.jpg`) with quality above a certain threshold (default: 80). Adjust the quality threshold as needed.

## Usage

1. **Clone the repository**:
    ```bash
    git clone https://github.com/yourusername/githealth.git
    cd githealth
    ```

2. **Run the script**:
    - Make sure the script is executable:
        ```bash
        chmod +x githealth.sh
        ```
    - Run the script from within your Git repository:
        ```bash
        ../githealth/githealth.sh
        ```

## Configuration

- **Thresholds**: You can adjust the thresholds for file size and image quality within the script.
    - `threshold_kb`: The size threshold in KB for identifying large files. Default is 500 KB.
    - Image quality threshold: Adjust this in the script (default is 80).

## Versioning

- **Current version**: 0.0.1

## Contributions and Forking

- Feel free to fork this repository, modify the script, and make versions as needed. Please give proper credit if you use or modify the script.
- Contributions and improvements are welcome! Please submit a pull request or open an issue if you find any bugs or have suggestions.

## License

This project is open source and available under the [MIT License](LICENSE).

---

Thank you for using `githealth`! If you have any questions or suggestions, please don't hesitate to reach out.

Happy coding!
