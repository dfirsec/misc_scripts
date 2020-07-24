
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

#### *nix version
```text
usage: ./update_git_repo.sh <USER> <REPO>
```

#### *windows version

```text
usage: ./update_git_repo.bat <USER> <REPO>
```
---------------------------------------------------------------------
#### Note: 
Recommend adding `*.sh` to your .gitignore file so the script is not tracked and uploaded.

*Ref: 
<https://help.github.com/en/github/using-git/ignoring-files>*


*What to check if gitignore is not working: 
<https://stackoverflow.com/questions/7529266/git-global-ignore-not-working/22835691#22835691>*
