# Migrate Repo from BitBucket to GitHub Enterprise

## Mapper
# BitBucket Workspace -> GitHub Enterprise
# BitBucket Project -> GitHub Organization
# BitBucket Repository -> GitHub Repository

BB_WORKSPACE=bb_to_gh
BB_PROJECT=Test_project
BB_REPO=test_repo
GITHUB_REMOTE_URL=https://x-access-token:$GHE_TOKEN@github.com/Ayushsaini20/test_ghrepo
GH_REPO="test_ghrepo"
GH_USERNAME=Ayushsaini20
GH_EMAIL=ayushsaini963@gmail.com

echo "Cloning BitBucket Repository into GitHub Runner Context"
git clone https://x-token-auth:$BB_TOKEN@bitbucket.org/$BB_WORKSPACE/$BB_REPO.git
cd $BB_REPO

echo "Creating GitHub Repository with GH APIs"

curl -X POST https://api.github.com/user/repos \
-H "Authorization: Bearer $GHE_TOKEN" \
-H "Accept: application/vnd.github+json" \
-d '{
  \"name\": \"$GH_REPO\",
  \"description\": \"Test Repo\",
  \"private\": true
}'

echo "Adding GitHub remote..."
git config user.name Ayushsaini20
git config user.email ayushsaini963@gmail.com
git remote add github "$GITHUB_REMOTE_URL"

if [ $? -ne 0 ]; then
    echo "Failed to add GitHub remote. Exiting."
    exit 1
fi

# Step 3: Push all branches and tags to GitHub
echo "Pushing to GitHub..."
git push --mirror github

if [ $? -ne 0 ]; then
    echo "Failed to push to GitHub. Exiting."
    exit 1
fi

echo "Cleaning up Workspace"
cd ..
rm -rf $BB_REPO
