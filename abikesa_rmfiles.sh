# To delete old folders and files from a Git repository using the command line, follow these steps:
    cd spjd
    git checkout main
    rm -r sibs*
    # rm file_name

# Stage the Deletions
    git add -A folder_name/
    git add file_name
    git add -A

    git commit -m "Removed old folders and files"
    git push origin branch_name
