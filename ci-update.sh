#!/bin/bash
# Originally Written By Tristan J. Poland 2024


set -euo pipefail

# Default CI directory name
DEFAULT_CI_DIR="ci"

# Array of directories to update (relative to CI directory)
DIRS_TO_UPDATE=(
    "pipeline"
    "scripts"
    "tasks"
)

# Array of files to copy from base template directory (relative to CI directory)
FILES_TO_COPY=(
    "repipe"
)

# Directories to preserve (not to be deleted during update)
DIRS_TO_PRESERVE=(
    "pipeline/custom-*"
)

# Function to display usage information
usage() {
    echo "Usage: $0 <template_path> <target_path> [ci_directory_name]"
    echo "  template_path: Path to the template CI directory"
    echo "  target_path: Path to the target project directory"
    echo "  ci_directory_name: Name of the CI directory (default: 'ci')"
    exit 1
}

# Check arguments
if [ "$#" -lt 2 ]; then
    usage
fi

TEMPLATE_PATH="$1"
TARGET_PATH="$2"
CI_DIR="${3:-$DEFAULT_CI_DIR}"

TEMPLATE_CI_PATH="$TEMPLATE_PATH/$CI_DIR"
TARGET_CI_PATH="$TARGET_PATH/$CI_DIR"

# Check if template CI directory exists
if [ ! -d "$TEMPLATE_CI_PATH" ]; then
    echo "Error: Template CI directory not found at $TEMPLATE_CI_PATH"
    exit 1
fi

# Create target CI directory if it doesn't exist
mkdir -p "$TARGET_CI_PATH"

# Function to safely remove directory contents
safe_remove_contents() {
    local dir="$1"
    local exclude_pattern=""
    for pattern in "${DIRS_TO_PRESERVE[@]}"; do
        exclude_pattern="$exclude_pattern ! -name '$pattern'"
    done
    find "$dir" -mindepth 1 -maxdepth 1 $exclude_pattern -exec rm -rf {} +
}

# Update specified directories
for dir in "${DIRS_TO_UPDATE[@]}"; do
    echo "Updating $dir directory..."
    target_dir="$TARGET_CI_PATH/$dir"
    mkdir -p "$target_dir"
    safe_remove_contents "$target_dir"
    cp -R "$TEMPLATE_CI_PATH/$dir"/* "$target_dir/" 2>/dev/null || true
done

# Copy specified files from base template to target
echo "Copying base template files..."
for file in "${FILES_TO_COPY[@]}"; do
    if [ -f "$TEMPLATE_CI_PATH/$file" ]; then
        cp "$TEMPLATE_CI_PATH/$file" "$TARGET_CI_PATH/"
    fi
done

echo "CI update completed successfully."

# Function to compare directories and list potentially removed files
compare_directories() {
    local template_dir="$1"
    local target_dir="$2"
    local prefix="$3"

    find "$target_dir" -type f | while read -r target_file; do
        local rel_path="${target_file#$target_dir/}"
        local template_file="$template_dir/$rel_path"
        if [ ! -e "$template_file" ]; then
            echo "Potentially removed from template: $prefix$rel_path"
        fi
    done
}

echo "Identifying potentially removed files..."
compare_directories "$TEMPLATE_CI_PATH" "$TARGET_CI_PATH" "$CI_DIR/"
for dir in "${DIRS_TO_UPDATE[@]}"; do
    compare_directories "$TEMPLATE_CI_PATH/$dir" "$TARGET_CI_PATH/$dir" "$CI_DIR/$dir/"
done

echo "CI update process completed."