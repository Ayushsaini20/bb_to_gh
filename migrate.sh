#!/bin/bash

BB_WORKSPACE=bb_to_gh
BB_PROJECT=Test_project
BB_REPO=test_repo
GHE_TOKEN="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"  # Ensure this is correct
BB_TOKEN="ATCTT3xFfGN0A6xCuuBWma5Cd0Jwxbd8AQZP4bK_3DILs3BrLneFZetnn_qRnlrV356QG8wZPmwgkKM0H5mWhHIbsGBjMtd4jC_YWPlneOs10JunPoAXKsgLuaJeHIgIkahyFBrrsEeudYg2FCYw01ciK6tRzM-9UkRY5sNlLBO7JHYVL_YI8TU=BEED5B08"
GH_REPO="test_ghrepo"
GH_USERNAME="Ayushsaini20"
GH_EMAIL="ayushsaini963@gmail.com"
BB_REPO_URL="https://x-token-auth:$BB_TOKEN@bitbucket.org/$BB_WORKSPACE/$BB_REPO.git"
GITHUB_REMOTE_URL="https://github.com/$GH_USERNAME/$GH_REPO.git"

echo "Cloning BitBucket Repository into GitHub Runner Context"
git clone $BB_REPO_URL
cd $BB_REPO || { echo "Failed to enter repository directory"; exit 1; }

echo "Creating GitHub Repository with GH APIs"
curl -X POST https://api.github.com/user/repos \
-H "Authorization: Bearer $GHE_TOKEN" \
-H "Accept: application/vnd.github+json" \
-d "{
  \"name\": \"$GH_REPO\",
  \"description\": \"Test Repo migrated from Bitbucket\",
  \"private\": true
}"

if [ $? -ne 0 ]; then
    echo "Failed to create GitHub repository. Exiting."
    exit 1
fi

echo "Adding GitHub remote..."
git config user.name "$GH_USERNAME"
git config user.email "$GH_EMAIL"

# Add GitHub remote with token-based authentication
git remote add github "https://$GH_USERNAME:$GHE_TOKEN@github.com/$GH_USERNAME/$GH_REPO.git"

if [ $? -ne 0 ]; then
    echo "Failed to add GitHub remote. Exiting."
    exit 1
fi

echo "Pushing to GitHub..."
git push --mirror github

if [ $? -ne 0 ]; then
    echo "Failed to push to GitHub. Exiting."
    exit 1
fi

echo "Marking the BitBucket Repository as Archived (Read-Only)..."
curl -X PUT "https://api.bitbucket.org/2.0/repositories/$BB_WORKSPACE/$BB_REPO" \
-H "Authorization: Bearer $BB_TOKEN" \
-H "Content-Type: application/json" \
-d "{
  \"is_private\": true,
  \"archived\": true
}"

if [ $? -ne 0 ]; then
    echo "Failed to archive the BitBucket repository. Exiting."
    exit 1
fi

echo "Cleaning up Workspace"
cd ..
rm -rf $BB_REPO

echo "Migration and archival completed successfully."
