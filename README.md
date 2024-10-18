# genesis-ci-update

`genesis-ci-update` is a configurable Bash script designed to update CI (Continuous Integration) configurations for Genesis projects. It copies and updates configuration files and directories from a template to a target project, allowing for easy maintenance of consistent CI setups across multiple repositories.

## Features

- Selectively updates specified directories and files
- Preserves custom configurations
- Easily configurable through arrays
- Identifies potentially removed files
- Works without Git dependencies

## Prerequisites

- Bash shell (version 4.0 or later recommended)
- Standard Unix utilities (find, cp, etc.)

## Installation

1. Copy the `ci-update.sh` script to your desired location.
2. Make the script executable:
   ```
   chmod +x ci-update.sh
   ```

## Usage

Run the script with the following command:

```
./ci-update.sh <template_path> <target_path> [ci_directory_name]
```

Where:
- `<template_path>` is the path to the directory containing the template CI configuration
- `<target_path>` is the path to the target project directory
- `[ci_directory_name]` is an optional name for the CI directory (default is "ci")

## Configuration

The script uses several arrays to control its behavior. You can modify these arrays at the top of the script to customize which directories and files are updated:

- `DIRS_TO_UPDATE`: Directories to be updated (relative to the CI directory)
- `FILES_TO_COPY`: Individual files to be copied from the base template directory
- `DIRS_TO_PRESERVE`: Directories that should not be deleted during the update process

Example configuration:

```bash
DIRS_TO_UPDATE=(
    "pipeline"
    "scripts"
    "tasks"
)

FILES_TO_COPY=(
    "repipe"
)

DIRS_TO_PRESERVE=(
    "pipeline/custom-*"
)
```

## How It Works

1. The script creates the target CI directory if it doesn't exist.
2. For each directory in `DIRS_TO_UPDATE`, it:
   - Removes existing contents (except those matching patterns in `DIRS_TO_PRESERVE`)
   - Copies new contents from the template
3. Copies individual files listed in `FILES_TO_COPY` from the template to the target.
4. Identifies and reports potentially removed files by comparing the template and target directories.

## Example

```bash
./ci-update.sh /path/to/genesis-ci-template /path/to/my-project
```

This command will update the CI configuration in `/path/to/my-project/ci` using the template from `/path/to/genesis-ci-template/ci`.

## Contributing

Contributions to improve `genesis-ci-update` are welcome. Please feel free to submit pull requests or open issues to suggest improvements or report bugs.

## License

Apache 2.0
