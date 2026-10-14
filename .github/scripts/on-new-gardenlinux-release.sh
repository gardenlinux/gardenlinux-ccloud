#!/usr/bin/env bash

set -euo pipefail

release_line="${1:-${RELEASE_LINE:-}}"
upstream_tag="${2:-${GARDENLINUX_UPSTREAM_TAG:-}}"
repo_tag="${3:-${REPOSITORY_TAG:-}}"
target_branch="${4:-${TARGET_BRANCH:-}}"
upstream_repo="https://github.com/gardenlinux/gardenlinux.git"
repo_slug="${GITHUB_REPOSITORY:-}"
work_branch="automation/track-${release_line}-${repo_tag//./-}"
pr_title="Track upstream ${release_line} release ${repo_tag}"

if [[ -z "${release_line}" || -z "${upstream_tag}" || -z "${repo_tag}" || -z "${target_branch}" ]]; then
  echo "Usage: $0 <release-line> <upstream-tag> <repo-tag> <target-branch>"
  exit 1
fi

if [[ -z "${repo_slug}" ]]; then
  echo "GITHUB_REPOSITORY is required"
  exit 1
fi

repo_root=$(git rev-parse --show-toplevel)
cd "${repo_root}"

upstream_commit_sha=$(git ls-remote --tags "${upstream_repo}" "refs/tags/${upstream_tag}" "refs/tags/${upstream_tag}^{}" \
  | awk '{print $1, $2}' \
  | sort -k2 \
  | tail -n1 \
  | awk '{print $1}')

if [[ -z "${upstream_commit_sha}" ]]; then
  echo "Could not resolve upstream commit SHA for tag ${upstream_tag}"
  exit 1
fi

echo "Detected new gardenlinux/gardenlinux release"
echo "  release line      : ${release_line}"
echo "  upstream tag      : ${upstream_tag}"
echo "  upstream commit   : ${upstream_commit_sha}"
echo "  repository tag    : ${repo_tag}"
echo "  target branch     : ${target_branch}"
echo "  work branch       : ${work_branch}"

git fetch origin "${target_branch}"
git fetch origin "${work_branch}:refs/remotes/origin/${work_branch}" || true
git checkout -B "${work_branch}" "origin/${target_branch}"

echo "Updating submodule and workflow references"
COMMIT="${upstream_commit_sha}" make update

echo "Updating VERSION"
printf '%s\n' "${repo_tag}" > VERSION

if [[ -z "$(git status --porcelain)" ]]; then
  echo "No changes detected after update; skipping commit and PR creation."
  exit 0
fi

echo "Updated files:"
git status --short

git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

git add -A
git restore -WS .github/workflows
git commit -m "Track upstream ${release_line} release ${repo_tag}"
git push --force-with-lease origin "${work_branch}"

pr_body=$(cat <<EOF
## Summary
- track upstream Garden Linux release line ${release_line}
- upstream tag: ${upstream_tag}
- upstream commit: ${upstream_commit_sha}
- repository tag: ${repo_tag}
- target branch: ${target_branch}

## Changes
- update the Garden Linux submodule to ${upstream_commit_sha}
- refresh workflow references via \`COMMIT=${upstream_commit_sha} make update\`
- set \`VERSION=${repo_tag}\`

## TODO
- [ ] update the workflows manually
EOF
)

existing_pr_number=$(gh pr list \
  --repo "${repo_slug}" \
  --base "${target_branch}" \
  --head "${work_branch}" \
  --state open \
  --json number \
  --jq '.[0].number')

if [[ -n "${existing_pr_number}" ]]; then
  echo "PR already exists: #${existing_pr_number}"
  gh pr edit "${existing_pr_number}" \
    --repo "${repo_slug}" \
    --title "${pr_title}" \
    --body "${pr_body}"
else
  gh pr create \
    --repo "${repo_slug}" \
    --base "${target_branch}" \
    --head "${work_branch}" \
    --title "${pr_title}" \
    --body "${pr_body}"
fi
