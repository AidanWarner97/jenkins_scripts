#!/bin/bash

repo forall -c '
  echo "Repo: $REPO_PATH"

  CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

  if [ "$CURRENT_BRANCH" = "HEAD" ]; then
    echo "Detached HEAD detected."

    # Try to infer branch from git config (only one branch should have config)
    # List all tracked branches
    BRANCHES=$(git config --get-regexp ^branch\..*\.remote | sed "s/branch\.\(.*\)\.remote.*/\1/")
    
    if [ -z "$BRANCHES" ]; then
      echo "No branch tracking info found in git config. Cannot reattach. Skipping."
      echo "-----------------------------"
      exit 0
    fi

    # If multiple branches, you may want to pick best guess, or fail

    # For simplicity, pick the first configured branch
    BRANCH=$(echo "$BRANCHES" | head -n1)

    REMOTE=$(git config branch."$BRANCH".remote)
    MERGE_REF=$(git config branch."$BRANCH".merge)    # e.g. refs/heads/main

    echo "Configured branch: $BRANCH"
    echo "Remote: $REMOTE"
    echo "Merge ref: $MERGE_REF"

    REMOTE_BRANCH=${MERGE_REF#refs/heads/}

    # Check if local branch exists, else create tracking branch
    if git show-ref --verify --quiet refs/heads/"$BRANCH"; then
      echo "Checking out existing local branch '$BRANCH'"
      git checkout "$BRANCH"
    else
      echo "Creating and checking out branch '$BRANCH' tracking '$REMOTE/$REMOTE_BRANCH'"
      git checkout -b "$BRANCH" --track "$REMOTE/$REMOTE_BRANCH"
    fi

    CURRENT_BRANCH=$BRANCH
  fi

  # reset, clean, pull
  git reset --hard
  git clean -fd
  git pull

  LOCAL_HEAD=$(git rev-parse HEAD)

  # resolve remote name "origin" fallback if missing
  REMOTE=$(git config branch."$CURRENT_BRANCH".remote)
  if [ -z "$REMOTE" ]; then
    REMOTE="origin"
  fi

  REMOTE_BRANCH=$(git config branch."$CURRENT_BRANCH".merge)
  REMOTE_BRANCH=${REMOTE_BRANCH#refs/heads/}

  REMOTE_HEAD=$(git rev-parse "$REMOTE/$REMOTE_BRANCH")

  if [ "$LOCAL_HEAD" = "$REMOTE_HEAD" ]; then
    echo "Local and remote are in sync on branch $CURRENT_BRANCH."
  else
    echo "WARNING: Local and remote differ on branch $CURRENT_BRANCH!"
    echo "Local HEAD:  $LOCAL_HEAD"
    echo "Remote HEAD: $REMOTE_HEAD"
  fi

  echo "-----------------------------"
'
