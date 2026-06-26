#!/bin/bash

echo "Starting LFS pull operations..."

repo forall -c '
    # Get the name of the current project directory (e.g., android-crates-io)
    PROJECT_NAME=$(basename "$PWD")

    # Define the repository to exclude
    EXCLUDE_REPO="android-crates-io"

    if [ "$PROJECT_NAME" = "$EXCLUDE_REPO" ]; then
        echo "Skipping Git LFS operations for $PROJECT_NAME (excluded)."
    else
        echo "Processing Git LFS for $PROJECT_NAME..."
        git lfs install --local 2>&1 && \
        git lfs pull 2>&1 && \
        git lfs checkout 2>&1
    fi
'

echo "LFS pull operations completed."

# You might want to check the overall exit code here if you want to ensure
# that only actual LFS failures (not the excluded repo) cause the script to fail.
# For now, it will likely still report success if the excluded repo is the only issue.
