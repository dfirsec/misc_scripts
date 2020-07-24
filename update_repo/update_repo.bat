@echo off

set USER=%1
set REPO=%2

rem Must provide at least two arguments
if "%2" == "" (
    echo.
    echo Usage: %0 username repo
    exit /b
) else (
    goto gitrun
)

:gitrun
Remove all files from git cache
call git rm -r --cached .
call git add .
call git commit -am "Refreshing .gitignore"

rem Check out to a temporary branch:
call git checkout --orphan TEMP_BRANCH

rem Add all the files:
call git add -A

rem Commit the changes:
call git commit -am "Initial commit"

rem Delete the old branch:
call git branch -D master

rem Rename the temporary branch to master:
call git branch -m master

rem Switch to SSH:
call git remote set-url origin git@github.com:%USER%/%REPO%.git

rem Finally, force update to our repository:
call git push -f origin master
