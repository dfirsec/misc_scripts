#!/bin/bash

# DFIRSec (@pulsecode)

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
    echo -e "\n${INFO}${1}${RESET}"
}

PROCESSING() {
    echo -e "${PROCESSING}${1}${RESET}"
}

# check if ran as sudo
if [ "$EUID" -eq 0 ]; then
    ERROR "Please do not run as root" && echo
    exit
fi

spin() {
    sp="/|\\-/|\\-"
    while :; do
        for i in $(seq 0 7); do
            echo -n "${sp:$i:1}"
            echo -en "\010"
            sleep 0.10
        done
    done
}

# Ref: https://gist.github.com/tedivm/e11ebfdc25dc1d7935a3d5640a1f1c90
apt_wait() {
    spin &
    SPIN_PID=$!
    trap 'kill -9 $SPIN_PID' $(seq 0 15)
    # sudo rm /var/lib/apt/lists/lock
    # sudo rm /var/lib/dpkg/lock
    # sudo rm /var/lib/dpkg/lock-frontend
    # sudo dpkg --configure -a
    while sudo fuser /var/lib/dpkg/lock >/dev/null 2>&1; do
        sleep 1
    done
    while sudo fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do
        sleep 1
    done
    if [ -f /var/log/unattended-upgrades/unattended-upgrades.log ]; then
        while sudo fuser /var/log/unattended-upgrades/unattended-upgrades.log >/dev/null 2>&1; do
            sleep 1
        done
    fi
    kill -9 $SPIN_PID
}

update_sys() {
    spin &
    SPIN_PID=$!
    trap 'kill -9 $SPIN_PID' $(seq 0 15)
    {
        sudo apt-get -qq update
        sudo apt-get -qq upgrade -y
        sudo apt-get -qq autoremove -y
    } >/dev/null 2>>$LOGFILE
    kill -9 $SPIN_PID
}

install_pkgs() {
    REQPKGS=(
        aeskeyfind
        apt-transport-https
        audacity
        autoconf
        automake
        binutils
        binwalk
        bison
        bless
        bsdgames
        build-essential
        bundler
        clamav
        clamav-daemon
        clamtk
        cmake
        curl
        default-jre
        dos2unix
        dpkg-dev
        emacs
        epic5
        ewf-tools
        exfat-utils
        fcrackzip
        feh
        ffmpeg
        firefox
        flex
        font-manager
        foremost
        g++
        gcc
        gdb-minimal
        geany
        gimp
        git
        gobuster
        golang-go
        graphviz
        gtk2-engines
        guake
        hashcat
        hashdeep
        hexedit
        ibus
        idle
        imagemagick
        inetsim
        inspircd
        kazam
        lame
        libewf-dev
        libimage-exiftool-perl
        libncurses5-dev
        libncursesw5-dev
        libssl-dev
        libxml2-dev
        ltrace
        mercurial
        mitmproxy
        mplayer
        neofetch
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
        p7zip-full
        p7zip-rar
        patch
        pdfcrack
        pdfresurrect
        pdftk
        pinta
        pyqt5-dev-tools
        python3-flask
        python3-libewf
        python3-pip
        python3-pyqt5
        python3-scapy
        python3-testresources
        qemu
        qpdf
        qrencode
        qttools5-dev-tools
        radare2
        rhino
        rsakeyfind
        ruby-full
        scalpel
        scite
        sleuthkit
        snapd
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
        terminator
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
        virtualbox-qt
        virtualenv
        vlc
        wget
        whois
        wxhexeditor
        xclip
        xmlstarlet
        xterm
        yara
        zbar-tools
        zlib1g-dev
    )

    for req in "${REQPKGS[@]}"; do
        if ! dpkg -s "$req" &>/dev/null; then
            PROCESSING "[+] Installing $req"
            sudo apt-get -qq install -y "$req" >/dev/null 2>>$LOGFILE
        else
            echo "installed" >/dev/null
        fi
    done
}

# setup paths
setup_paths() {
    # update $PATH for user-binaries (systemd-path user-binaries)
    INFO "[+] Updating path for user-binaries"
    if ! grep "export PATH=\$HOME/.local/bin/:\$PATH" ~/.bashrc >/dev/null; then
        echo "export PATH=\$HOME/.local/bin/:\$PATH" >>~/.bashrc
    fi

    INFO "[+] Forcing color prompt in ~/.bashrc"
    if ! grep "export PS1" ~/.bashrc >/dev/null; then
        echo "export PS1='${debian_chroot:+($debian_chroot)}\[\033[38;5;11m\]\u\[$(tput sgr0)\]@\h:\[$(tput sgr0)\]\[\033[38;5;6m\][\w]\[$(tput sgr0)\]: \[$(tput sgr0)\]'" >>~/.bashrc
    fi

    INFO "[+] Adding xclip alias"
    if ! grep "alias xclip" ~/.bashrc >/dev/null; then
        echo "alias xclip='xclip -selection clipboard'" >>~/.bashrc
    fi
}

install_opt_pkgs() {
    OPTPKGS=(
        atom
        balena-etcher
        dirsearch
        docker
        ghidra
        jd-gui
        plaso
        sqlmap
        stegsolve
        sublime
        vnc
        vscode
        volatility3
        wireshark
    )

    for pkg in "${OPTPKGS[@]}"; do
        if ! dpkg -s "$pkg" &>/dev/null; then
            ############################
            #   atom
            ############################
            if [[ $pkg == "atom" ]]; then
                PROCESSING "[+] Installing Atom"
                {
                    wget -qO - https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add -
                    sudo sh -c 'echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" > /etc/apt/sources.list.d/atom.list'
                    sudo apt-get -qq update
                    sudo apt-get -qq install atom -y
                } >/dev/null 2>>$LOGFILE
            fi

            ############################
            #   balena-etcher
            ############################
            if [[ $pkg == "balena-etcher" ]]; then
                PROCESSING "[+] Installing Etcher"
                {
                    echo "deb https://deb.etcher.io stable etcher" | sudo tee /etc/apt/sources.list.d/balena-etcher.list
                    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 379CE192D401AB61
                    sudo apt-get -qq update && sudo apt-get -qq install balena-etcher-electron -y
                } >/dev/null 2>>$LOGFILE
            fi

            ############################
            #   dirsearch
            ############################
            if [[ $pkg == "dirsearch" ]]; then
                DIRSRCH_DIR="/opt/dirsearch"
                if ! [ -d $DIRSRCH_DIR ]; then
                    PROCESSING "[+] Installing dirsearch"
                    sudo git clone https://github.com/maurosoria/dirsearch.git $DIRSRCH_DIR >/dev/null 2>>$LOGFILE
                fi
                INFO "[+] Adding dirsearch alias"
                if ! grep "alias dirsearch" ~/.bashrc >/dev/null; then
                    echo "alias dirsearch='python3 /opt/dirsearch/dirsearch.py'" >>~/.bashrc
                fi
            fi

            ############################
            #   docker
            ############################
            if [[ $pkg == "docker" ]]; then
                PROCESSING "[+] Installing Docker"
                {
                    sudo apt-get -qq install docker.io -y
                    sudo groupadd docker
                    sudo usermod -aG docker "$LOGNAME"
                } >/dev/null 2>>$LOGFILE
            fi

            ############################
            #   ghidra
            ############################
            if [[ $pkg == "ghidra" ]]; then
                GHIDRA_DIR="/opt/ghidra"
                GHIDRA_ICON='https://git.io/JfMiE'
                GHIDRA_DESKTOP='https://git.io/JfMiz'
                GHIDRA_VER=$(wget -O - -q https://www.ghidra-sre.org | grep 'Download Ghidra' | sed 's/.*href=.//' | sed 's/".*//')
                if ! [[ -d $GHIDRA_DIR ]]; then
                    PROCESSING "[+] Installing ghidra"
                    wget -c -q "https://ghidra-sre.org/$GHIDRA_VER" --no-hsts
                    wget -q $GHIDRA_ICON --no-hsts -O ghidra.png
                    wget -q $GHIDRA_DESKTOP --no-hsts -O ghidra.desktop
                    sudo unzip -q ghidra_*.zip -d /opt && sudo mv /opt/ghidra_* $GHIDRA_DIR
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
                        } >/dev/null 2>>$LOGFILE
                    fi
                fi
            fi

            ############################
            #   jd-gui
            ############################
            if [[ $pkg == "jd-gui" ]]; then
                if ! command -v java-jar /opt/jd-gui/jd-gui.jar >/dev/null; then
                    PROCESSING "[+] Installing jd-gui"
                    wget -c -q https://github.com/java-decompiler/jd-gui/releases/download/v1.6.6/jd-gui-1.6.6.deb -O jd-gui.deb
                    sudo dpkg -i jd-gui.deb >/dev/null 2>>$LOGFILE
                    rm jd-gui.deb
                fi
            fi

            ############################
            #   plaso
            ############################
            if [[ $pkg == "plaso" ]]; then
                PRE_REQ=(
                    libewf
                    libewf-python3
                    python3-dfvfs
                    python3-plaso
                    plaso-tools
                )

                INFO "[+] Adding GIFT repo for plaso install"
                PROCESSING "[+] Installing log2timeline/plaso"
                {
                    sudo add-apt-repository ppa:gift/stable -y
                    sudo apt-get -qq update
                    sudo apt-get -qq install "${PRE_REQ[@]}" -y
                } >/dev/null 2>>$LOGFILE
            fi

            ############################
            #  stegsolve
            ############################
            if [[ $pkg == "stegsolve" ]]; then
                if ! [ -f /opt/stegsolve/stegsolve.jar ]; then
                    sudo mkdir /opt/stegsolve/
                    INFO "[+] Downloading stegsolve.jar"
                    sudo wget -q "http://www.caesum.com/handbook/Stegsolve.jar" -O /opt/stegsolve/stegsolve.jar
                    sudo chmod +x /opt/stegsolve/stegsolve.jar
                    sudo chown "$USER":"$USER" /opt/stegsolve/stegsolve.jar
                    INFO "[+] Adding stegsolve alias"
                    if ! grep "alias stegsolve" ~/.bashrc >/dev/null; then
                        echo "alias stegsolve='/opt/stegsolve/stegsolve.jar'" >>~/.bashrc
                    fi
                fi
            fi

            ############################
            #   sqlmap
            ############################
            if [[ $pkg == "sqlmap" ]]; then
                SQLMAP_DIR="/opt/sqlmap"
                if ! [ -d $SQLMAP_DIR ]; then
                    INFO "[+] Downloading sqlmap"
                    sudo git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git $SQLMAP_DIR >/dev/null 2>>$LOGFILE
                fi
                INFO "[+] Adding sqlmap alias"
                if ! grep "alias sqlmap" ~/.bashrc >/dev/null; then
                    echo "alias sqlmap='python3 /opt/sqlmap/sqlmap.py'" >>~/.bashrc
                fi
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
            #   vnc
            ############################
            if [[ $pkg == "vnc" ]]; then
                if ! sudo dpkg-query -l | grep realvnc >/dev/null; then
                    PROCESSING "[+] Installing Real VNC Viewer"
                    wget -q 'https://www.realvnc.com/download/file/viewer.files/VNC-Viewer-6.20.113-Linux-x64.deb' -O vnc_viewer.deb
                    sudo dpkg -i vnc_viewer.deb >/dev/null 2>>$LOGFILE
                    rm vnc_viewer.deb

                    PROCESSING "[+] Installing Real VNC Connect (Server)"
                    wget -q 'https://www.realvnc.com/download/file/vnc.files/VNC-Server-6.7.1-Linux-x64.deb' -O vnc_server.deb
                    sudo dpkg -i vnc_server.deb >/dev/null 2>>$LOGFILE
                    rm vnc_server.deb

                    INFO "[+] Adding VNC Connect (Server) service to the default startup"
                    if ! systemctl is-active --quiet vncserver-x11-serviced; then
                        {
                            sudo systemctl start vncserver-x11-serviced.service
                            sudo systemctl enable vncserver-x11-serviced.service
                        } >/dev/null 2>>$LOGFILE
                    fi
                fi
            fi

            ############################
            #   volatility3
            ############################
            if [[ $pkg == "volatility3" ]]; then
                VOL3_DIR="/opt/volatility3"
                if ! [ -d $VOL3_DIR ]; then
                    INFO "[+] Downloading volatility3"
                    sudo git clone https://github.com/volatilityfoundation/volatility3.git $VOL3_DIR >/dev/null 2>>$LOGFILE
                fi
                INFO "[+] Adding volatility3 alias"
                if ! grep "alias vol3" ~/.bashrc >/dev/null; then
                    echo "alias vol3='sudo python3 /opt/volatility3/vol.py'" >>~/.bashrc
                fi
            fi

            ############################
            #   vscode
            ############################
            if [[ $pkg == "vscode" ]]; then
                PROCESSING "[+] Installing vscode"
                INFO "[+] Importing the Microsoft GPG key"
                INFO"[+] Enabling the Visual Studio Code repository and install"
                {
                    wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
                    sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
                    sudo apt-get -qq update
                    sudo apt-get -qq install code -y
                } >/dev/null 2>>$LOGFILE
                # rm vscode sources list to avoide conflict
                if [ -f /etc/apt/sources.list.d/vscode.list ]; then
                    sudo rm /etc/apt/sources.list.d/vscode.list
                fi

                # intall option
                # wget -q https://go.microsoft.com/fwlink/?LinkID=760868 --no-hsts -O vscode.deb
                # sudo dpkg -i vscode.deb &>/dev/null
            fi

            ############################
            #   wireshark
            ############################
            if [[ $pkg == "wireshark" ]]; then
                PROCESSING "[+] Installing wireshark"
                echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
                {
                    yes '' | sudo add-apt-repository ppa:wireshark-dev/stable
                    sudo apt-get -qq update
                    sudo DEBIAN_FRONTEND=noninteractive apt-get -qq install wireshark -y
                } >/dev/null 2>>$LOGFILE
                unset DEBIAN_FRONTEND
            fi
        else
            echo "$pkg is already installed" >/dev/null
        fi
    done
}

snap_tools() {
    SNAP_PKGS=(spotify volatility-phocean)
    sudo snap install "${SNAP_PKGS[@]}" >/dev/null 2>>$LOGFILE
    INFO "[+] Adding volatility2 alias"
    if ! grep "alias vol2" ~/.bashrc >/dev/null; then
        echo "alias vol2='volatility-phocean.volatility'" >>~/.bashrc
    fi
}

didier_tools() {
    DSTOOLS_DIR="/opt/didier"
    URL='http://didierstevens.com/files/software/'

    TOOLS=(
        base64dump_V0_0_11.zip
        emldump_V0_0_10.zip
        jpegdump_V0_0_7.zip
        oledump_V0_0_49.zip
        pdf-parser_V0_7_4.zip
        pdfid_v0_2_7.zip
    )

    if ! [ -d $DSTOOLS_DIR ]; then
        sudo mkdir $DSTOOLS_DIR
        for TOOL in "${TOOLS[@]}"; do
            TOOL_NAME=$(echo "$TOOL" | tr "[:upper:]" "[:lower:]" | awk -F_ '{print $1}')
            sudo mkdir $DSTOOLS_DIR/"$TOOL_NAME"
            INFO "[+] Downloading $TOOL"
            wget -c -q "$URL""$TOOL" --no-hsts
            sudo unzip -q "$TOOL" -d $DSTOOLS_DIR/"$TOOL_NAME"

            INFO "[+] Adding $TOOL_NAME alias"
            if ! grep "alias $TOOL_NAME" ~/.bashrc >/dev/null; then
                echo "alias $TOOL_NAME='python2 $DSTOOLS_DIR/$TOOL_NAME/$TOOL_NAME.py'" >>~/.bashrc
            fi
            rm -f "$TOOL"
        done
    fi

    XOR_TOOLS=(XORSearch_V1_11_3.zip XORStrings_V0_0_1.zip)
    for TOOL in "${XOR_TOOLS[@]}"; do
        TOOL_NAME=$(echo "$TOOL" | tr "[:upper:]" "[:lower:]" | awk -F_ '{print $1}')
        sudo mkdir $DSTOOLS_DIR/"$TOOL_NAME"
        INFO "[+] Downloading $TOOL"
        wget -c -q "$URL""$TOOL" --no-hsts
        PROCESSING "[+] Installing $TOOL_NAME"
        sudo unzip -q "$TOOL" -d $DSTOOLS_DIR/"$TOOL_NAME"

        INFO "[+] Adding $TOOL_NAME alias"
        if ! grep "alias xorstrings" ~/.bashrc >/dev/null; then
            echo "alias xorstrings='$DSTOOLS_DIR/xorstrings/xorstrings'" >>~/.bashrc
        fi

        if ! grep "alias xorsearch-x86-s" ~/.bashrc >/dev/null; then
            echo "alias xorsearch-x86-s='$DSTOOLS_DIR/xorsearch/xorsearch-x86-static'" >>~/.bashrc
        fi

        if ! grep "alias xorsearch-x86-d" ~/.bashrc >/dev/null; then
            echo "alias xorsearch-x86-dc='$DSTOOLS_DIR/xorsearch/xorsearch-x86-dynamic'" >>~/.bashrc
        fi

        if ! grep "alias xorsearch-x64-s" ~/.bashrc >/dev/null; then
            echo "alias xorsearch-x64-s='$DSTOOLS_DIR/xorsearch/xorsearch-x64-static'" >>~/.bashrc
        fi

        if ! grep "alias xorsearch-x64-d" ~/.bashrc >/dev/null; then
            echo "alias xorsearch-x64-d='$DSTOOLS_DIR/xorsearch/xorsearch-x64-dynamic'" >>~/.bashrc
        fi
        rm -f "$TOOL"
    done

    # xorstrings clean-up
    sudo gcc -w $DSTOOLS_DIR/xorstrings/XORStrings.c -o $DSTOOLS_DIR/xorstrings/xorstrings
    sudo rm -rf $DSTOOLS_DIR/xorstrings/OSX $DSTOOLS_DIR/xorstrings/XORStrings.c $DSTOOLS_DIR/xorstrings/xorstrings.exe
    sudo chown "$USER":"$USER" $DSTOOLS_DIR/xorstrings/xorstrings

    # xorsearch clean-up
    sudo mv $DSTOOLS_DIR/xorsearch/Linux/* $DSTOOLS_DIR/xorsearch/ && sudo rm -rf $DSTOOLS_DIR/xorsearch/Linux/
    sudo rm -rf $DSTOOLS_DIR/xorsearch/OSX $DSTOOLS_DIR/xorsearch/Windows/ $DSTOOLS_DIR/xorsearch/xorsearch.exe $DSTOOLS_DIR/xorsearch/XORSearch.c
    sudo chown "$USER":"$USER" $DSTOOLS_DIR/xorsearch/xorsearch-x*
    chmod +x $DSTOOLS_DIR/xorsearch/xorsearch-x*
}

bulk_ext_install() {
    spin &
    SPIN_PID=$!
    trap 'kill -9 $SPIN_PID' $(seq 0 15)

    INFO "[+] Cloning bulk_extractor repo"
    sudo git clone https://github.com/simsong/bulk_extractor.git /opt/bulk_extractor/ >/dev/null 2>>$LOGFILE
    {
        pushd /opt/bulk_extractor/ || return
        sudo chmod +x ./bootstrap.sh
        sudo ./bootstrap.sh
        sudo ./configure --enable-silent-rules
        sudo make
        sudo make install
        popd >/dev/null || return
    } >/dev/null 2>>~/$LOGFILE

    kill -9 $SPIN_PID
}

install_ruby_gems() {
    GEMS=(
        therubyracer
        origami
        passivedns-client
        pedump
    )
    sudo gem install "${GEMS[@]}" >/dev/null 2>>$LOGFILE
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
    spin &
    SPIN_PID=$!
    trap 'kill -9 $SPIN_PID' $(seq 0 15)

    sudo python3 -m pip -q install -U setuptools pip wheel
    for mod in "${MODULES[@]}"; do
        PROCESSING "[+] Installing Python module $mod"
        sudo python3 -m pip -q install "$mod"
    done
    kill -9 $SPIN_PID
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
        [ -d "$dir" ] && rm -rf "$dir"
    done
}

replace_term() {
    # replace default terminal emulator with terminator
    if echo "$XDG_CURRENT_DESKTOP" | grep -q XFCE; then
        CURR_TERM=$(pstree -sA $$ | awk -F "---" '{ print $2 }')
        sudo mv /usr/bin/"$CURR_TERM" /usr/bin/"$CURR_TERM".bak
        sudo ln -s /usr/bin/terminator /usr/bin/"$CURR_TERM"
        sudo cp /usr/share/applications/terminator.desktop "$HOME"/Desktop
        sudo chmod +x "$HOME"/Desktop/terminator.desktop
        sudo chown "$USER":"$USER" "$HOME"/Desktop/terminator.desktop
    fi
}

clean_up() {
    INFO "[+] Fixing any broken installs"
    sudo apt-get -qq --fix-broken install

    INFO "[+] Cleaning apt cache"
    sudo apt-get -qq clean

    INFO "[+] Removing old kernels"
    sudo apt-get -qq purge "$(dpkg -l | grep -P -o "linux-image-\d\S+" | head -n-4)" -y 2>>$LOGFILE

    INFO "[+] Removing no longer required packages"
    sudo apt-get -qq autoremove -y >/dev/null 2>>$LOGFILE

    INFO "[+] Emptying the trash"
    rm -rf /home/*/.local/share/Trash/*/** >/dev/null 2>>$LOGFILE
    rm -rf /root/.local/share/Trash/*/** >/dev/null 2>>$LOGFILE
}

# Processing Stage
{
    sudo test
    INFO "[+] Waiting for lock release"
    apt_wait

    INFO "[+] Updating repositories"
    update_sys

    # install packages
    install_pkgs

    INFO "[+] Setting up shell and paths"
    setup_paths

    # install optional packages"
    install_opt_pkgs

    PROCESSING "[+] Installing snap packages"
    snap_tools

    PROCESSING "[+] Installing Didier's tools"
    didier_tools

    PROCESSING "[+] Installing bulk_extractor"
    bulk_ext_install

    PROCESSING "[+] Installing Ruby Gems"
    install_ruby_gems

    PROCESSING "[+] Installing Python Modules"
    install_py_mods

    PROCESSING "[+] Removing boilerplate home directories"
    remove_bpdirs

    INFO "[+] Setting terminator as the default terminal emulator"
    replace_term

    clean_up
} 2>>$LOGFILE

INFO "[+] Updating bash prompt"

SUCCESS "Check $LOGFILE for possible errors encountered"

# refresh bash
exec bash
