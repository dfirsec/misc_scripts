#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

apt-get install libncurses-dev python-pip
pip install virtualenv
virtualenv ~/.rekall_env
pip install --upgrade setuptools pip wheel
pip install future==0.16.0
pip install pybindgen
pip install rekall
pip install yara
pip install yara-python
echo 'alias rekal="source ~/.rekall_env/bin/activate; rekall"' >> ~/.bash_aliases


# If the following error is encountered...
# OSError: /usr/lib/libyara.so: cannot open shared object file: No such file or directory

# Create a symbolic link....
# sudo ln -s /usr/local/lib/python2.7/dist-packages/usr/lib/libyara.so /usr/lib/libyara.so

# Ref: https://stackoverflow.com/questions/41255478/issue-oserror-usr-lib-libyara-so-cannot-open-shared-object-file-no-such-fi
