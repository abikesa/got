```bash

#!/bin/bash

# Check if required commands are available
for cmd in git ssh-keygen jb ghp-import; do
  if ! command -v $cmd &> /dev/null; then
    echo "Error: $cmd is not installed."
    exit 1
  fi
done

# Input information
read -p "Enter your GitHub username: " GITHUB_USERNAME
read -p "Enter your GitHub repository name: " REPO_NAME
read -p "Enter your email address: " EMAIL_ADDRESS
read -p "Enter your root directory (e.g., ~/Dropbox/1f.ἡἔρις,κ/1.ontology): " ROOT_DIR
read -p "Enter the name of the subdirectory to be created within the root directory: " SUBDIR_NAME
read -p "Enter the name of the populate_be.ipynb file in ROOT_DIR: " POPULATE_BE
read -p "Enter your git commit message: " GIT_COMMIT_MESSAGE

# Set up directories and paths
git config --local user.name "$GITHUB_USERNAME"
git config --local user.email "$EMAIL_ADDRESS"
cd $(eval echo $ROOT_DIR)
rm -rf $REPO_NAME
mkdir -p $SUBDIR_NAME
cp $POPULATE_BE $SUBDIR_NAME/intro.ipynb
cd $SUBDIR_NAME

# Check if SSH keys already exist, and if not, generate a new one
SSH_KEY_PATH="$HOME/.ssh/id_${SUBDIR_NAME}${REPO_NAME}"
rm -rf $SSH_KEY_PATH*
if [ ! -f "$SSH_KEY_PATH" ]; then
  ssh-keygen -t ed25519 -C "$EMAIL_ADDRESS" -f $SSH_KEY_PATH
fi

cat ${SSH_KEY_PATH}.pub
echo "Please manually add the above SSH public key to your GitHub account's SSH keys."
read -p "Once you have added the SSH key to your GitHub account, press Enter to continue..."
eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain $SSH_KEY_PATH

# Number of acts, files per act, and sub-files per file
NUMBER_OF_ACTS=9
NUMBER_OF_FILES_PER_ACT=9
NUMBER_OF_SUB_FILES_PER_FILE=9
NUMBER_OF_NOTEBOOKS=5

# Create _toc.yml file
toc_file="_toc.yml"
echo "format: jb-book" > $toc_file
echo "root: intro.ipynb" >> $toc_file # Make sure this file exists
echo "title: Play" >> $toc_file
echo "parts:" >> $toc_file

# Iterate through the acts, files per act, and sub-files per file
for ((i=0; i<$NUMBER_OF_ACTS; i++)); do
  mkdir -p "act_${i}"
  echo "  - caption: Part $(($i + 1))" >> $toc_file
  echo "    chapters:" >> $toc_file
  for ((j=0; j<$NUMBER_OF_FILES_PER_ACT; j++)); do
    mkdir -p "act_${i}/act_${i}_${j}"
    for ((k=0; k<$NUMBER_OF_SUB_FILES_PER_FILE; k++)); do
      mkdir -p "act_${i}/act_${i}_${j}/act_${i}_${j}_${k}"
      for ((n=1; n<=$NUMBER_OF_NOTEBOOKS; n++)); do
        new_file="act_${i}/act_${i}_${j}/act_${i}_${j}_${k}/act_${i}_${j}_${k}_${n}.ipynb"
        touch "$new_file"
        cp "intro.ipynb" "$new_file" # This line copies the content into the new file
        echo "      - file: $new_file" >> $toc_file
      done
    done
  done
done

# Create _config.yml file
config_file="_config.yml"
echo "title: Your Book Title" > $config_file
echo "copyright: Mwaka" > $config_file
echo "author: Your Name" >> $config_file
echo "logo: https://raw.githubusercontent.com/jhutrc/jhutrc.github.io/main/hub_and_spoke.jpg" >> $config_file

# Build the book with Jupyter Book
cd ..
jb build $SUBDIR_NAME
git clone "https://github.com/$GITHUB_USERNAME/$REPO_NAME"
cp -r $SUBDIR_NAME/* $REPO_NAME
cd $REPO_NAME
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
