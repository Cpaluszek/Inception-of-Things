#!/bin/bash
set -e
GREEN="\033[32m"
RESET="\033[0m"

GITLAB_URL="gitlab.k3d.gitlab.com"
GITLAB_ROOT_USER="root"
GITLAB_REPO_NAME="gitlab_cpalusze"
GITHUB_REPO_NAME="cpalusze"
GITLAB_NAMESPACE="root"
GITLAB_PSW=$(kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath="{.data.password}" | base64 -d)
LOCAL_REPO_DIR="gitlab_cpalusze"
GITLAB_TOKEN="glpat-9WmXGohANm9yLsTBTuyh"

# Create .netrc file with GitLab credentials
echo "machine gitlab.k3d.gitlab.com
login root
password ${GITLAB_PSW}" | sudo tee /root/.netrc > /dev/null

sudo chmod 600 /root/.netrc

echo -e "${GREEN}Creating GitLab project...${RESET}"
curl --header "Private-Token: $GITLAB_TOKEN" -X POST "$GITLAB_URL/api/v4/projects" \
    --form "name=$GITLAB_REPO_NAME" \
    --form "visibility=public"

# Clone the newly created GitLab repository
echo -e "${GREEN}Cloning the GitLab repository...${RESET}"
# git clone "$GITLAB_ROOT_USER:$GITLAB_PSW@$GITLAB_URL/$GITLAB_NAMESPACE/$GITLAB_REPO_NAME.git" $LOCAL_REPO_DIR
git clone "http://$GITLAB_URL/$GITLAB_NAMESPACE/$GITLAB_REPO_NAME.git" $LOCAL_REPO_DIR

# Clone the GitHub repository
echo -e "${GREEN}Cloning the GitHub repository...${RESET}"
git clone "https://github.com/Cpaluszek/$GITHUB_REPO_NAME.git"

# Move the contents from the GitHub repository to the GitLab repository
echo -e "${GREEN}Moving the contents from the GitHub repository to the GitLab repository...${RESET}"
mv ${GITHUB_REPO_NAME}/* ${LOCAL_REPO_DIR}/
rm -rf ${GITHUB_REPO_NAME}

echo -e "${GREEN}Directory contents:${RESET}"
ls -la ${LOCAL_REPO_DIR}

# Navigate to the local GitLab repository directory
cd ${LOCAL_REPO_DIR}

# Initialize and push the changes to GitLab
echo -e "${GREEN}Pushing local repository to GitLab...${RESET}"
git add .
git commit -m "Initial commit with Kubernetes manifests"
git push --set-upstream origin main

echo -e "${GREEN}GitLab project initialized and pushed successfully.${RESET}"

 argocd app set will --repo "http://gitlab-webservice-default.gitlab.svc:8181/$GITLAB_ROOT_USER/$GITLAB_REPO_NAME.git/"
