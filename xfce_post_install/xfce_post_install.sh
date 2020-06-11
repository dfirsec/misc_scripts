#!/bin/bash

# Credit: JohnHammond
# https://github.com/JohnHammond/ignition_key/blob/master/ignition_key.sh

# Define colors ]
ERROR=$(tput bold && tput setaf 1)
SUCCESS=$(tput bold && tput setaf 2)
INFO=$(tput bold && tput setaf 3)
PROCESSING=$(tput bold && tput setaf 6)
RESET=$(tput sgr0)

LOGFILE="post-install.log"

ERROR() {
    echo -e "\n${ERROR}[ERROR] ${1}${RESET}"
}

SUCCESS() {
    echo -e "\n${SUCCESS}[SUCCESS] ${1}${RESET}"
}

INFO() {
    echo -e "\n${INFO}[INFO] ${1}${RESET}"
}

PROCESSING() {
    echo -e "\n${PROCESSING}${1}${RESET}"
}

# check if ran as sudo
if [ "$EUID" -eq 0 ]; then
    ERROR "Please do not run as root" && echo
    exit
fi

update_sys() {
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get autoremove -y
}

install_pkgs() {
    REQPKGS=(
        aeskeyfind
        apt-transport-https
        automake
        binutils
        binwalk
        bison
        bsdgames
        build-essential
        bundler
        clamav-daemon
        cmake
        curl
        default-jre
        dos2unix
        epic5
        exfat-utils
        fcrackzip
        feh
        ffmpeg
        firefox
        flex
        font-manager
        foremost
        gdb-minimal
        geany
        gimp
        git
        git terminator
        gobuster
        golang-go
        graphviz
        gtk2-engines
        guake
        hashcat
        hexedit
        ibus
        idle
        imagemagick
        inetsim
        inspircd
        kazam
        lame
        libimage-exiftool-perl
        ltrace
        mercurial
        mplayer
        nginx
        ngrep
        nikto
        nmap
        openjdk-13-jdk
        openjdk-13-jre
        openssh-client
        openssh-server
        openssl
        openvpn
        p7zip-rar
        p7zip-full
        pdfcrack
        pdfresurrect
        pdftk
        pinta
        python3-flask
        python3-pip
        python3-scapy
        python3-testresources
        python3-pyqt5
        pyqt5-dev-tools
        qttools5-dev-tools
        qpdf
        qrencode
        radare2
        rhino
        rsakeyfind
        ruby-full
        scalpel
        scite
        sleuthkit
        software-properties-common
        sqlite
        sqlitebrowser
        ssdeep
        sshpass
        steghide
        stegsnow
        strace
        stunnel4
        subversion
        sysdig
        taskwarrior
        tcpdump
        tcpflow
        tcpick
        tcpxtract
        tesseract-ocr
        tor
        torsocks
        unhide
        unicode
        unrar
        upx-ucl
        usbmount
        vagrant
        vbindiff
        virtualenv
        virtualbox-qt
        whois
        wxhexeditor
        xclip
        xmlstarlet
        xterm
        yara
        zbar-tools
        zlib1g-dev
    )

    PROCESSING "[+] Adding universal repo"
    sudo add-apt-repository universe >/dev/null

    for req in "${REQPKGS[@]}"; do
        if ! dpkg -s "$req" 2>/dev/null; then
            PROCESSING "[+] Installing $req"
            sudo apt-get install -y "$req"
        fi
    done
}

install_opt_pkgs() {
    OPTPKGS=(
        atom
        code
        docker
        ghidra
        snapd
        sqlmap
        stegsolve
        sublime
        vnc
        volatility3
        wireshark
    )

    for pkg in "${OPTPKGS[@]}"; do
        if ! dpkg -s "$pkg" 2>/dev/null; then
            ############################
            #   wireshark
            ############################
            if [[ $pkg == "wireshark" ]]; then
                PROCESSING "[+] Installing wireshark"
                sudo add-apt-repository ppa:wireshark-dev/stable
                sudo apt-get update
                echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
                sudo DEBIAN_FRONTEND=noninteractive apt-get -y install wireshark
                unset DEBIAN_FRONTEND
            fi

            ############################
            #   vscode
            ############################
            if [[ $pkg == "code" ]]; then
                PROCESSING "[+] Importing the Microsoft GPG key"
                wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
                PROCESSING "[+] Enabling the Visual Studio Code repository and install"
                sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
                sudo apt-get update
                sudo apt-get install code -y
            fi

            ############################
            #   docker
            ############################
            if [[ $pkg == "docker" ]]; then
                PROCESSING "[+] Installing Docker"
                sudo apt-get install docker.io -y
                sudo groupadd docker 2>/dev/null
                sudo usermod -aG docker "$LOGNAME"
            fi

            ############################
            #   atom
            ############################
            if [[ $pkg == "atom" ]]; then
                PROCESSING "[+] Installing Atom"
                wget -qO - https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add -
                sudo sh -c 'echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" > /etc/apt/sources.list.d/atom.list'
                sudo apt-get update
                sudo apt-get install atom -y
            fi

            ############################
            #   sublime
            ############################
            if [[ $pkg == "sublime-text" ]]; then
                PROCESSING "[+] Installing Sublime Text" # according to https://www.sublimetext.com/docs/3/linux_repositories.html-
                wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
                echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
                sudo apt-get update
                sudo apt-get install sublime-text -y
            fi

            ############################
            #  stegsolve
            ############################
            if [[ $pkg == "stegsolve" ]]; then
                if ! [ -f "stegsolve.jar" ]; then
                    PROCESSING "[+] Downloading stegsolve.jar"
                    wget -q "http://www.caesum.com/handbook/Stegsolve.jar" -O "stegsolve.jar"
                    chmod +x "stegsolve.jar"

                fi
            fi

            ############################
            #   vnc
            ############################
            if [[ $pkg == "vnc" ]]; then
                if ! sudo dpkg-query -l | grep realvnc; then
                    PROCESSING "[+] Installing Real VNC Viewer"
                    wget -q 'https://www.realvnc.com/download/file/viewer.files/VNC-Viewer-6.20.113-Linux-x64.deb' -O vnc_viewer.deb
                    sudo dpkg -i vnc_viewer.deb
                    rm vnc_viewer.deb

                    PROCESSING "[+] Installing Real VNC Connect (Server)"
                    wget -q 'https://www.realvnc.com/download/file/vnc.files/VNC-Server-6.7.1-Linux-x64.deb' -O vnc_server.deb
                    sudo dpkg -i vnc_server.deb
                    rm vnc_server.deb

                    PROCESSING "[+] Adding VNC Connect (Server) service to the default startup"
                    if ! systemctl is-active --quiet vncserver-x11-serviced; then
                        sudo systemctl start vncserver-x11-serviced.service
                        sudo systemctl enable vncserver-x11-serviced.service
                    fi
                fi
            fi

            ############################
            #   snapd
            ############################
            if [[ $pkg == "snapd" ]]; then
                PROCESSING "[+] Installing Snap"
                sudo apt-get install snapd -y

                SNAPPKGS=(spotify volatility-phocean)
                PROCESSING "[+] Installing snap packages"
                sudo snap install "${SNAPPKGS[@]}"
            fi

            ############################
            #   ghidra
            ############################
            if [[ $pkg == "ghidra" ]]; then
                GHIDRA_DIR="/opt/ghidra"
                GHIDRA_ICON='https://git.io/JfMiE'
                GHIDRA_DESKTOP='https://git.io/JfMiz'
                GHIDRA_VER=$(wget -O - -q https://www.ghidra-sre.org | grep 'Download Ghidra' | sed 's/.*href=.//' | sed 's/".*//')
                if [[ -d $GHIDRA_DIR ]]; then
                    PROCESSING "ghidra already installed here: $GHIDRA_DIR"
                else
                    PROCESSING "[+] Installing ghidra"
                    wget -c -q "https://ghidra-sre.org/$GHIDRA_VER" --no-hsts
                    wget -q $GHIDRA_ICON --no-hsts -O ghidra.png
                    wget -q $GHIDRA_DESKTOP --no-hsts -O ghidra.desktop
                    sudo unzip -q ghidra_*.zip -d /opt && sudo mv /opt/ghidra_* /opt/ghidra
                    rm ghidra_*.zip
                    sudo ln -s $GHIDRA_DIR/ghidraRun /usr/local/bin/ghidra
                    sudo mv ghidra.png $GHIDRA_DIR/support/ghidra.png
                    mv ghidra.desktop "$HOME"/Desktop/ghidra.desktop
                    chmod +x "$HOME"/Desktop/ghidra.desktop
                    chown "$USER":"$USER" "$HOME"/Desktop/ghidra.desktop

                    if test -f "$GHIDRA_VER"; then
                        {
                            rm -f "$GHIDRA_VER"
                            sudo rm -rf /opt/ghidra_*
                            sudo rm -rf /opt/ghidra/ghidra_*
                        } 2>/dev/null
                    fi
                fi
            fi

            ############################
            #   volatility3
            ############################
            if [[ $pkg == "volatility3" ]]; then
                VOL_DIR="/opt/volatility3"
                if ! [ -d $VOL_DIR ]; then
                    PROCESSING "[+] Downloading volatility3"
                    sudo git clone https://github.com/volatilityfoundation/volatility3.git /opt/volatility3 2>/dev/null
                fi
            fi

            ############################
            #   sqlmap
            ############################
            if [[ $pkg == "sqlmap" ]]; then
                SQLMAP_DIR="/opt/sqlmap"
                if ! [ -d $SQLMAP_DIR ]; then
                    PROCESSING "[+] Downloading sqlmap"
                    sudo git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git /opt/sqlmap 2>/dev/null
                fi
            fi
        else
            echo "$pkg is already installed"
        fi
    done
}

# setup paths
setup_paths() {
    PROCESSING "[+] Forcing color prompt in ~/.bashrc"
    if ! grep "export PS1" ~/.bashrc; then
        echo "export PS1='${debian_chroot:+($debian_chroot)}\[\033[38;5;11m\]\u\[$(tput sgr0)\]@\h:\[$(tput sgr0)\]\[\033[38;5;6m\][\w]\[$(tput sgr0)\]: \[$(tput sgr0)\]'" >>~/.bashrc
    fi

    PROCESSING "[+] Adding sqlmap to .bashrc"
    if ! grep "alias sqlmap" ~/.bashrc; then
        echo "alias sqlmap='python /opt/sqlmap/sqlmap.py'" >>~/.bashrc
    fi

    PROCESSING "[+] Adding volatility3 to .bashrc"
    if ! grep "alias vol3" ~/.bashrc; then
        echo "alias vol3='python3 /opt/volatility3/vol.py'" >>~/.bashrc
    fi

    PROCESSING "[+] Adding xclip to .bashrc"
    if ! grep "alias xclip" ~/.bashrc; then
        echo "alias xclip='xclip -selection clipboard'" >>~/.bashrc
    fi
}

install_ruby_gems() {
    PROCESSING "[+] Installing Ruby Gems"
    GEMS=(
        therubyracer
        origami
        passivedns-client
        pedump
    )
    for GEM in "${GEMS[@]}"; do
        sudo gem install "$GEM"
    done
}

#  pip installations
install_py_mods() {
    MODULES=(
        acora
        bitstring
        bottle
        bs4
        capstone
        colorama
        crypto
        cryptography
        cybox
        distorm3
        dnslib
        dnspython
        fuzzywuzzy
        hachoir
        iptools
        ipwhois
        jsbeautifier
        levenshtein-coding
        Mako
        ndg-httpsclient
        netifaces
        numpy
        olefile
        oletools
        passlib
        pefile
        Pillow
        pwntools
        pyasn1
        pydispatch
        pydivert
        pydot
        pyelftools
        pygeoip
        pylzma
        pyopenssl
        pypdns
        pyqt5
        pypssl
        python-magic
        r2pipe
        rarfile
        requests
        scipy
        shodan
        uTidylib
        virustotal3
        xortool
        yara-python
    )

    #check_installed=$(pip list | awk '{print $1}' | awk '{if(NR>2)print}')
    sudo python3 -m pip install -U setuptools pip wheel
    for mod in "${MODULES[@]}"; do
        sudo python3 -m pip install "$mod"
    done
}

# setup paths
setup_paths() {
    PROCESSING "[+] Changing shell color prompt"
    if ! grep "export PS1" ~/.bashrc; then
        echo "export PS1='${debian_chroot:+($debian_chroot)}\[\033[38;5;11m\]\u\[$(tput sgr0)\]@\h:\[$(tput sgr0)\]\[\033[38;5;6m\][\w]\[$(tput sgr0)\]: \[$(tput sgr0)\]'" >>~/.bashrc
    fi

    PROCESSING "[+] Updating shell for sqlmap"
    if ! grep "alias sqlmap" ~/.bashrc; then
        echo "alias sqlmap='python /opt/sqlmap/sqlmap.py'" >>~/.bashrc
    fi

    PROCESSING "[+] Updating shell for volatility3"
    if ! grep "alias vol3" ~/.bashrc; then
        echo "alias vol3='python3 /opt/volatility3/vol.py'" >>~/.bashrc
    fi

    PROCESSING "[+] Updating shell for xclip"
    if ! grep "alias xclip" ~/.bashrc; then
        echo "alias xclip='xclip -selection clipboard'" >>~/.bashrc
    fi

    # update $PATH for user-binaries (systemd-path user-binaries)
    PROCESSING "[+] Updating path for user-binaries"
    if ! grep "export PATH=\$HOME/.local/bin/:\$PATH" ~/.bashrc; then
        echo "export PATH=\$HOME/.local/bin/:\$PATH" >>~/.bashrc
    fi
}

# remove boilerplate directories
remove_bpdirs() {
    BP_DIRS=(
        "$HOME"/Documents
        "$HOME"/Music
        "$HOME"/Pictures
        "$HOME"/Public
        "$HOME"/Templates
        "$HOME"/Videos
    )

    for dir in "${BP_DIRS[@]}"; do
        # if [ -d "$dir" ]; then
        #     rmdir "$dir"
        # fi
        [ -d "$dir" ] && rm -rf "$dir"
    done
}

replace_term() {
    # replace default terminal emulator with terminator
    if echo "$XDG_CURRENT_DESKTOP" | grep -q XFCE; then
        PROCESSING "[+] Setting terminator as the default terminal emulator"
        CURR_TERM=$(pstree -sA $$ | awk -F "---" '{ print $2 }')
        sudo mv /usr/bin/"$CURR_TERM" /usr/bin/"$CURR_TERM".bak
        sudo ln -s /usr/bin/terminator /usr/bin/"$CURR_TERM"
        sudo cp /usr/share/applications/terminator.desktop "$HOME"/Desktop
        sudo chmod +x "$HOME"/Desktop/terminator.desktop
        sudo chown "$USER":"$USER" "$HOME"/Desktop/terminator.desktop
    fi
}

clean_up() {
    PROCESSING "[+] Fixing any broken installs"
    sudo apt-get --fix-broken install

    PROCESSING "[+] Cleaning apt cache"
    sudo apt-get clean

    PROCESSING "[+] Removing old kernels"
    sudo apt-get purge "$(dpkg --list | grep -P -o "linux-image-\d\S+" | head -n-4)" -y 2>>$LOGFILE

    PROCESSING "[+] Emptying the trash"
    rm -rf /home/*/.local/share/Trash/*/** 2>/dev/null
    rm -rf /root/.local/share/Trash/*/** 2>/dev/null
}

# Processing Stage
{
    PROCESSING "[+] Updating repositories"
    update_sys

    PROCESSING "[+] Installing packages"
    install_pkgs

    PROCESSING "[+] Installing optional packages"
    install_opt_pkgs

    PROCESSING "[+] Setting up shell and paths"
    setup_paths

    PROCESSING "[+] Installing Ruby Gems"
    install_ruby_gems

    PROCESSING "[+] Installing Python Modules"
    install_py_mods

    PROCESSING "[+] Removing boilerplate home directories"
    remove_bpdirs

    replace_term

    clean_up
} 2>>$LOGFILE

PROCESSING "[+] Updating bash prompt"

if [ -s $LOGFILE ]; then
    INFO "Check $LOGFILE for possible errors encountered"
else
    SUCCESS $LOGFILE
fi

# refresh bash
exec bash
