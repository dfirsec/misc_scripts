My post install script for Xubuntu; tested on a fresh install of Xubuntu 20.04-core (https://unit193.net/xubuntu/core/).

:loudspeaker:  
**Install at your own risk -- recommend testing in a VM before installing on a live system**.

## Steps
**1)** Download the script
```text
user@machine:[~]: wget https://git.io/Jf9lF -O xfce_post_install.sh
```

**2)** Make the script executable 
```text
user@machine:[~]: chmod +x xfce_post_install.sh
```

**3)** Launch the script
```text
user@machine:[~]: ./xfce_post_install.sh
```

**4)** Enter sudo creds
```text
[+] Updating repositories
[sudo] password for user: 
```

**4)** Reboot for goodluck :relaxed:
```text
user@machine:[~]: reboot 
```


## Tools -- *more to follow*
Didier Steven's Tools - https://github.com/DidierStevens/DidierStevensSuite

**base64dump**: Extract base64 strings from file
```text
Command:  base64dump
```

**emldump**: Analyze MIME files
```text
Command:  emldump
```

**jpegdump**: JPEG file analysis tool
```text
Command:  jpegdump
```

**oledump**: Analyze OLE files (Compound Binary Files)
```text
Command:  oledump
```

**pdf-parser**: PDF analysis
```text
Command:  pdf-parser
```

**pdfid**: PDF triage
```text
Command:   pdfid
```

**xorsearch**: Bruteforce a file for XOR, ROL, ROT, SHIFT...encoding and search for a string
```text
Command:  xorsearch-x86-s (x86 static)
          xorsearch-x86-d (x86 dynamic)
          xorsearch-x64-s (x64 static)
          xorsearch-x64-d (x64 dynamic)
```

**xorstrings**: Bruteforce a file for XOR, ROL, ROT, SHIFT...encoding and dump strings
```text
Command:  xorstrings
```
