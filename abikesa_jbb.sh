# User-defined inputs for abi/abikesa_jbb.sh; substantive edits on 08/14/2023:
read -p "Enter your GitHub username: " GITHUB_USERNAME
read -p "Enter your GitHub repository name: " REPO_NAME
read -p "Enter your email address: " EMAIL_ADDRESS
read -p "Enter your root directory (e.g., ~/Dropbox/1f.ἡἔρις,κ/1.ontology): " ROOT_DIR
read -p "Enter the name of the subdirectory to be built within the root directory: " SUBDIR_NAME
read -p "Enter your commit statement " COMMIT_THIS
read -p "Enter your SSH key path (e.g., ~/.ssh/id_nh_projectbetaprojectbeta): " SSH_KEY_PATH

# Ensure ssh-agent is running; https://github.com/jhurepos/projectbeta 
eval "$(ssh-agent -s)"

# Remove all identities from the SSH agent
ssh-add -D

# Add your SSH key to the agent
chmod 600 "$(eval echo $SSH_KEY_PATH)"
ssh-add "$(eval echo $SSH_KEY_PATH)"

# Build the book with Jupyter Book
git config --local user.name "$GITHUB_USERNAME"
git config --local user.email "$EMAIL_ADDRESS"

cd "$(eval echo $ROOT_DIR)"
jb build $SUBDIR_NAME
rm -rf $REPO_NAME

if [ -d "$REPO_NAME" ]; then
  echo "Directory $REPO_NAME already exists. Choose another directory or delete the existing one."
  exit 1
fi

# Cloning
git clone "git@github.com:$GITHUB_USERNAME/$REPO_NAME"
if [ ! -d "$REPO_NAME" ]; then
  echo "Failed to clone the repository. Check your GitHub username, repository name, and permissions."
  exit 1
fi

# Copy files from subdirectory to the current repository directory; restored $REPO_NAME!!!
cp -r $SUBDIR_NAME/* $REPO_NAME
cd $REPO_NAME

git add ./*
git commit -m "$COMMIT_THIS"
git remote -v
ssh-add -D 
# Remove all identities from the SSH agent
chmod 600 "$(eval echo $SSH_KEY_PATH)"
# ls -l ~/.ssh/id_nh_projectbetaprojectbeta

git remote set-url origin "git@github.com:$GITHUB_USERNAME/$REPO_NAME"
ssh-add "$(eval echo $SSH_KEY_PATH)"
git config --local user.name "$GITHUB_USERNAME"
git config --local user.email "$EMAIL_ADDRESS"


# Checkout the main branch
git checkout main
if [ $? -ne 0 ]; then
  echo "Failed to checkout the main branch. Make sure it exists in the repository."
  exit 1
fi

# Pushing changes
git push -u origin main
if [ $? -ne 0 ]; then
  echo "Failed to push to the repository. Check your SSH key path and GitHub permissions."
  exit 1
fi

ghp-import -n -p -f _build/html
cd ..
rm -rf $REPO_NAME
echo "Jupyter Book content updated and pushed to $GITHUB_USERNAME/$REPO_NAME repository!"
