#!/bin/bash

# Parameters required by the script
read -p "Enter your GitHub username (e.g., abikesa): " GITHUB_USER
read -p "Enter your GitHub repository name (e.g., nabongo): " GITHUB_REPO
read -p "Enter your email address (e.g., abikesa.sh@gmail.com): " EMAIL_ADDRESS
read -p "Enter your root directory (e.g., ~/Dropbox/1f.ἡἔρις,κ/1.ontology): " ROOT_DIR
read -p "Enter the name of the local directory to be created within the root directory (e.g., charles): " LOCAL_DIR
read -p "Enter the SSH key name (e.g., id_charlesnabongo): " SSH_KEYNAME
read -p "Enter your git commit message (e.g., automated abikesa_fromfolks.sh script): " GIT_COMMIT_MESSAGE

# Folked from some_repo to GITHUB_USER/GITHUB_REPO
cd $(eval echo $ROOT_DIR)
git clone "https://github.com/$GITHUB_USER/$GITHUB_REPO"
cp -r "$GITHUB_REPO/*" "$LOCAL_DIR"
jb build "$LOCAL_DIR"
cp -r "$LOCAL_DIR/*" "$GITHUB_REPO"
cd "$GITHUB_REPO"
git add .
git commit -m "$GIT_COMMIT_MESSAGE"

# Overcoming the error: no sufficient permissions
git remote -v
git remote set-url origin "git@github.com:$GITHUB_USER/$GITHUB_REPO"
git config user.name "$GITHUB_USER"
git config user.email "$EMAIL_ADDRESS"
git checkout main

# Check if SSH keys already exist, and if not, generate a new one
read -p "Enter your SSH key name (e.g., id_charlesnabongo, not ~/.ssh/id_charlesnabongo): " SSH_KEYNAME
SSH_KEYPATH="$HOME/.ssh/$SSH_KEYNAME"

if [ ! -f "$SSH_KEYPATH" ]; then
  ssh-keygen -t ed25519 -C "$EMAIL_ADDRESS" -f $SSH_KEYPATH
fi

cat "$SSH_KEYPATH.pub"
echo "Please manually add the above SSH public key to your GitHub account's SSH keys."
read -p "Once you have added the SSH key to your GitHub account, press Enter to continue..."
eval "$(ssh-agent -s)"
ssh-add -D
ssh-add $SSH_KEYPATH
chmod 600 $SSH_KEYPATH

# Configure the remote URL with SSH
git remote set-url origin "git@github.com:$GITHUB_USER/$GITHUB_REPO"

# Push changes
git push -u origin main
ghp-import -n -p -f _build/html
rm -rf "$GITHUB_REPO"
echo "jb content updated & pushed to $GITHUB_USER/$GITHUB_REPO repository!"

