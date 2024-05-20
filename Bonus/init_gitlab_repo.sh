#!/bin/bash
set -e
GREEN="\033[32m"
RESET="\033[0m"

GITLAB_URL="http://k3d.gitlab.com"
GITLAB_ROOT_USER="root"
GITLAB_REPO_NAME="gitlab_cpalusze"
GITHUB_REPO_NAME="cpalusze"
GITLAB_NAMESPACE="root"
GITLAB_PSW=$(kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath="{.data.password}" | base64 -d)
LOCAL_REPO_DIR="gitlab_cpalusze"

echo -e "${GREEN}Creating GitLab project...${RESET}"
curl --header "Private-Token: $GITLAB_PSW" -X POST "$GITLAB_URL/api/v4/projects" \
    --form "name=$GITLAB_REPO_NAME" \
    --form "visibility=public"

# Clone the newly created GitLab repository
git clone "http://$GITLAB_ROOT_USER:$GITLAB_PSW@$GITLAB_URL/$GITLAB_NAMESPACE/$GITLAB_REPO_NAME.git" $LOCAL_REPO_DIR

# Clone the GitHub repository
git clone "https://github.com/Cpaluszek/$GITHUB_REPO_NAME.git"

# Move the contents from the GitHub repository to the GitLab repository
mv ${GITHUB_REPO_NAME}/* ${LOCAL_REPO_DIR}/
mv ${GITHUB_REPO_NAME}/.gitignore ${LOCAL_REPO_DIR}/  # Ensure hidden files are moved too

# Navigate to the local GitLab repository directory
cd ${LOCAL_REPO_DIR}

# Initialize and push the changes to GitLab
echo -e "${GREEN}Pushing local repository to GitLab...${RESET}"
git add .
git commit -m "Initial commit with Kubernetes manifests"
git push -u origin master

echo -e "${GREEN}GitLab project initialized and pushed successfully.${RESET}"