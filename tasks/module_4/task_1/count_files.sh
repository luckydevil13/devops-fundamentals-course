#!/usr/bin/env bash

function count_files() {
    local dir_path="$1"
    local file_count=$(find "$dir_path" -type f | wc -l)
    echo "$file_count"
}

function count_files_in_subdirs() {
    local dir_path="$1"
    local subdirs=$(find "$dir_path" -type d)
    for subdir in $subdirs; do
        local file_count=$(count_files "$subdir")
        echo "Directory: $subdir, File count: $file_count"
    done
}

if [ $# -lt 1 ]; then
    echo "Usage: $0 <dir> [<dir> ...]"
    exit 1
fi

# Call the function with each directory path as an argument.
for dir_path in "$@"; do
    count_files_in_subdirs "$dir_path"
done