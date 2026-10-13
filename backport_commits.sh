#!/usr/bin/env bash

set -eEuo pipefail

# branches
BRANCHES=(
  "rel-1877-dev"
  "rel-2150-dev"
)
REMOTE_NAME="origin"
WORKTREE_DIR_BASE=".worktree/backports"

# usage and fail if there is no argument
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <commit-sha>"
  exit 1
fi

# commit sha to backport is first argument
BACKPORT_COMMIT_SHA="$1"


# Question to user which branches from BRANCHES should be targetted
# enumrate branches and user has to answer the number of the branch to target.
# multiple branches can be targetted by providing csv. Default is A for all
# branches.
SELECTED_BRANCHES=()

echo "Available branches:"
for i in "${!BRANCHES[@]}"; do
  echo "$((i + 1)). ${BRANCHES[$i]}"
done
read -rp "Select branches to target (comma-separated numbers, default A for all): " input

if [[ -z "$input" || "$input" == "A" || "$input" == "a" ]]; then
  SELECTED_BRANCHES=("${BRANCHES[@]}")
else
  IFS=',' read -ra selected_indices <<< "$input"
  for index in "${selected_indices[@]}"; do
    if [[ $index =~ ^[0-9]+$ ]] && (( index >= 1 && index <= ${#BRANCHES[@]} )); then
      SELECTED_BRANCHES+=("${BRANCHES[$((index - 1))]}")
    else
      echo "Invalid selection: $index"
      exit 1
    fi
  done
fi

echo "Selected branches: ${SELECTED_BRANCHES[*]}"

# for each selected branch
# 1. create a worktree on the latest commit in $REMOTE_NAME of the branch
# 2. cherry-pick the commits from the current branch to the worktree
for branch in "${SELECTED_BRANCHES[@]}"; do
  echo "Processing branch: $branch"

  # create worktree
  WORKTREE_DIR="$WORKTREE_DIR_BASE/$branch-$BACKPORT_COMMIT_SHA"
  NEW_BRANCH_NAME="backport/$branch/$BACKPORT_COMMIT_SHA"
  git worktree add -b "$NEW_BRANCH_NAME" "$WORKTREE_DIR" "$REMOTE_NAME/$branch" || {
    echo "Failed to create worktree for branch $branch. Please check if the branch exists."
    exit 1
  }

  # cherry-pick the commit
  pushd "$WORKTREE_DIR" > /dev/null
  git cherry-pick "$BACKPORT_COMMIT_SHA" || {
    echo "Cherry-pick failed for branch $branch. Please resolve conflicts manually."
    exit 1
  }

  # alter the commit message and add a backport commit with the original commit
  # sha before the signed-off lines
  git commit --amend -m "$(git log -1 --pretty=%B | sed "s/\(Signed-off-by:.*\)/Backport of $BACKPORT_COMMIT_SHA\n\n\1/")"
  echo "Amended commit message for backport to branch $branch"

  # create PR
  gh pr create --fill --base "$branch" || {
    echo "Failed to create PR for branch $branch. Please create it manually."
    exit 1
  }

  popd > /dev/null

  echo "Successfully backported commit $BACKPORT_COMMIT_SHA to branch $branch"
done
