
# Update Github Repo

Script removes old commits from your github repo.

## Installation

Script is \*nix specific.  Requires zip and unzip installed.

```text
sudo apt install zip unzip
```

### Step 1

Clone your repository

```text
git clone https://github.com/{USER}/{REPO}.git
```

### Step 2

Copy the script to your repository source directory and make it executable.

```text
cd {repository directory}
chmod +x update_git_repo.sh
```

### Step 3

Run the script by providing your github username followed by the repository name.  

```text
usage: ./update_git_repo.sh {USER} {REPO}


Backing up /mnt/d/Code/Python/ioc-search...
Sun Dec  8 06:12:15 EST 2019
  adding: mnt/d/Code/ioc-search/
  adding: mnt/d/Code/ioc-search/.git/
  adding: mnt/d/Code/ioc-search/.git/branches
  adding: mnt/d/Code/ioc-search/.git/COMMIT_EDITMSG
  ...
Backup finished!
Sun Dec  8 06:52:15 EST 2019
Switched to a new branch 'TEMP_BRANCH'
[TEMP_BRANCH (root-commit) 2eb14c] Initial commit
 4 files changed, 213 insertions(+)
 create mode 100644 README.md
 create mode 100644 ioc_search.py
 ...
Deleted branch master (was a1311fd).
Counting objects: 6, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (4/4), done.
Writing objects: 100% (6/6), 3.12 KiB | 800.00 KiB/s, done.
Total 6 (delta 0), reused 0 (delta 0)
```

Note: Recommend adding `*.sh` to your .gitignore file so the script is not tracked and uploaded.

*Ref: 
<https://help.github.com/en/github/using-git/ignoring-files>*


*What to check if gitignore is not working: 
<https://stackoverflow.com/questions/7529266/git-global-ignore-not-working/22835691#22835691>*
