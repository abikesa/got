cp -r got git
jb build git
ls -al ~/.ssh
ssh-keygen -t ed25519 -C "abikesa.shl@gmail.com" -f ~/.ssh/id_git2got2.pub
echo "Please manually add the above SSH public key to your GitHub account's SSH keys."
read -p "Once you have added the SSH key to your GitHub account, press Enter to continue..."
cat ~/.ssh/id_git2got2.pub
eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain ~/.ssh/id_git2got2

# Build the book with Jupyter Book
jb build git2
git clone "https://github.com/abikesa/got"
cp -r git2/* got
cd got
git add ./*
git commit -m "$GIT_COMMIT_MESSAGE"
chmod 600 $SSH_KEY_PATH

# Configure the remote URL with SSH
git remote set-url origin "git@github.com:$GITHUB_USERNAME/$REPO_NAME"

# Push changes
git push -u origin main
ghp-import -n -p -f _build/html
rm -rf $REPO_NAME
echo "Jupyter Book content updated and pushed to $GITHUB_USERNAME/$REPO_NAME repository!"
