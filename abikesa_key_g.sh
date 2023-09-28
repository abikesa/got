#!/bin/bash

# Check if required commands are available
for cmd in git ssh-keygen jb ghp-import; do
  if ! command -v $cmd &> /dev/null; then
    echo "Error: $cmd is not installed."
    exit 1
  fi
done

# User Inputs
read -p "Enter your GitHub username: " GITHUB_USERNAME
read -p "Enter your GitHub repository name: " REPO_NAME
read -p "Enter your email address: " EMAIL_ADDRESS
read -p "Enter your root directory: e.g. ~/dropbox/1f.ἡἔρις,κ/1.ontology " ROOT_DIR
read -p "Enter the name of the subdirectory: " SUBDIR_NAME
read -p "Enter the .ipynb file name in ROOT_DIR:  " POPULATE_BE
read -p "Enter your git commit message: " GIT_COMMIT_MESSAGE
read -p "Enter the number of acts: " NUMBER_OF_ACTS
read -p "Enter the number of files per act: " NUMBER_OF_FILES_PER_ACT
read -p "Enter the number of sub-files per file: " NUMBER_OF_SUB_FILES_PER_FILE
read -p "Enter the number of notebooks: " NUMBER_OF_NOTEBOOKS

# Initialize directory
git config --local user.name "$GITHUB_USERNAME"
git config --local user.email "$EMAIL_ADDRESS"
cd $(eval echo $ROOT_DIR)
rm -rf $REPO_NAME
git clone "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
cp -r $REPO_NAME $SUBDIR_NAME

# SSH Setup
# SSH Setup
SSH_KEY_PATH="$HOME/.ssh/id_${SUBDIR_NAME}${REPO_NAME}"

# Check if the SSH key already exists
if [ -f "$SSH_KEY_PATH" ]; then
  # Prompt the user for confirmation before deletion
  read -p "The SSH key already exists. Do you want to delete it? [y/N] " confirm
  if [ "$confirm" == "y" ] || [ "$confirm" == "Y" ]; then
    rm -rf $SSH_KEY_PATH*
    echo "SSH key deleted."
  else
    echo "SSH key not deleted."
  fi
fi

# Generate a new SSH key if it does not exist
if [ ! -f "$SSH_KEY_PATH" ]; then
  ssh-keygen -t ed25519 -C "$EMAIL_ADDRESS" -f $SSH_KEY_PATH
fi

# Copy & paste key to GitHub 
echo "Please manually add the SSH public key to GitHub."
read -p "Press Enter to continue..."
eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain $SSH_KEY_PATH

# Jupyter Book Setup
jb build $SUBDIR_NAME

cp -r $SUBDIR_NAME/* $REPO_NAME/
cd $REPO_NAME
git add ./*
git commit -m "$GIT_COMMIT_MESSAGE"
chmod 600 $SSH_KEY_PATH

# Git Operations
git remote set-url origin "git@github.com:$GITHUB_USERNAME/$REPO_NAME.git"
git push -u origin main
ghp-import -n -p -f _build/html
rm -rf $REPO_NAME
echo "Jupyter Book content updated and pushed to $GITHUB_USERNAME/$REPO_NAME repository!"

