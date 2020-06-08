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


install_pgks() {
	REQPKGS=(
		aeskeyfind
		apt-transport-https
		automake
		binutils
		binwalk
		bison
		bsdgames
		build-essential
		bulk-extractor
		bundler
		clamav-daemon
		cmake
		curl
		default-jre
		docker-engine
		dos2unix
		elfparser
		epic5
		exfat-utils
		fcrackzip
		feh
		ffmpeg
		firefox
		flare-fakenet-ng
		flare-floss
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
		gtksourceview2
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
		lib32stdc++6
		libboost1.54-all-dev
		libc6-dev-i386
		libcanberra-gtk-module:i386
		libcompress-raw-lzma-perl
		libemail-outlook-message-perl
		libemu2
		libffi-dev
		libfuzzy-dev
		libgif-dev
		libgif4
		libgtk2.0-0:i386
		libgtkmm-2.4-1c2:i386
		libimage-exiftool-perl
		libjavassist-java
		libjpeg-turbo8
		libjpeg-turbo8-dev
		liblzma-dev
		libmagic-dev
		libmozjs-24-bin
		libncurses5
		libncurses5-dev
		libncurses5:i386
		libolecf-tools
		libpcre++-dev
		libpcre3
		libpcre3-dev
		libsm6:i386
		libsqlite3-dev
		libssl-dev
		libtool
		libwebkitgtk-1.0-0
		libxml2-dev
		libxslt1-dev
		libxxf86vm1:i386
		libyaml-dev
		libyara3
		libzmq3-dev
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
		p7zip
		p7zip-full
		pdfcrack
		pdfresurrect
		pdftk
		pinta
		pyew
		python3-flask
		python3-pip
		python3-scapy
		qpdf
		qrencode
		radare2
		rhino
		rsakeyfind
		ruby-full
		scalpel
		scite
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
		swftools
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
		virtualbox-qt
		whois
		wireshark
		wxhexeditor
		xclip
		xmlstarlet
		xpdf
		xterm
		yara
		zbar-tools
		zlib1g-dev
	)

	for req in "${REQPKGS[@]}"; do
		if ! dpkg -s "$req" &> /dev/null; then
			PROCESSING "$req"
			sudo apt-get install -y "$req"
		fi
	done

	OPTPKGS=(
		atom
		code
		docker
		ghidra
		hashcat
		snapd
		sqlmap
		stegsolve
		sublime
		vnc
		volatility3
		wireshark
	)

	for pkg in "${OPTPKGS[@]}"; do
		if ! dpkg -s "$req" &> /dev/null; then
			############################
			#   wireshark
			############################
			if [[ $pkg == "wireshark" ]]; then
				PROCESSING "[+] Installing wireshark"
				sudo add-apt-repository ppa:wireshark-dev/stable
				sudo apt-get update
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
				sudo groupadd docker
				sudo usermod -aG docker "$(logpkg)"
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
				if [ -f "stegsolve.jar" ]; then
					echo 'skipping'
				else
					PROCESSING "[+] Downloading stegsolve.jar"
					wget -q "http://www.caesum.com/handbook/Stegsolve.jar" -O "stegsolve.jar"
					chmod +x "stegsolve.jar"

				fi
			fi

			############################
			#   hashcat
			############################
			# if [[ $pkg == "hashcat" ]]; then
			# 	if [[ -x $(command -v hashcat) ]]; then
			# 		echo 'skipping'
			# 	else
			# 		PROCESSING "[+] Installing hashcat"
			# 		wget -q https://hashcat.net/files/hashcat-5.1.0.7z
			# 		p7zip -d hashcat-5.1.0.7z
			# 		cd hashcat-5.1.0 || exit
			# 		cp hashcat64.bin /usr/bin/
			# 		ln -s /usr/bin/hashcat64.bin /usr/bin/hashcat
			# 		cd || exit
			# 		rm -rf hashcat-5.1.0
			# 	fi
			# fi

			############################
			#   vnc
			############################
			if [[ $pkg == "vnc" ]]; then
				if ! sudo dpkg-query -l | grep realvnc; then
					echo "$pkg is installed"
				else
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
						sudo /etc/init.d/vncserver-x11-serviced start
						sudo update-rc.d vncserver-x11-serviced defaults
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
					INFO "ghidra already installed here: $GHIDRA_DIR"
				else
					for x in {1..100}; do
						prog_bar "$x"
						wget -c -q "https://ghidra-sre.org/$GHIDRA_VER" --no-hsts
						wget -O ghidra.png -c -q $GHIDRA_ICON --no-hsts
						wget -O ghidra.desktop -c -q $GHIDRA_DESKTOP --no-hsts
						sudo unzip -q ghidra_*.zip -d /opt && sudo mv /opt/ghidra_* /opt/ghidra
						rm ghidra_*.zip
						sudo ln -s $GHIDRA_DIR/ghidraRun /usr/local/bin/ghidra
						sudo mv ghidra.png $GHIDRA_DIR/support/ghidra.png
						mv ghidra.desktop "$HOME"/Desktop/ghidra.desktop
						chmod +x "$HOME"/Desktop/ghidra.desktop
						chown "$USER":"$USER" "$HOME"/Desktop/ghidra.desktop
						sleep .05
					done
					echo
				fi
				# jdk_dir="/opt/jdk-11"
				# if [[ -d $jdk_dir ]]; then
				# 	INFO "jdk-11 already installed here: $jdk_dir"
				# else
				# 	wget 'https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.7%2B10/OpenJDK11U-jdk_x64_linux_hotspot_11.0.7_10.tar.gz' --no-hsts
				# 	sudo mkdir -p /opt/jdk-11/ && sudo tar -xzf OpenJDK11U-jdk_x64_linux_hotspot_11.0.7_10.tar.gz -C /opt/jdk-11/ --strip-components 1
				# 	rm OpenJDK11U*.tar.gz
				# fi
			fi

			############################
			#   volatility3
			############################
			if [[ $pkg == "volatility3" ]]; then
				VOL_DIR="/opt/volatility3"
				if [[ -d $VOL_DIR ]]; then
					echo 'skipping'
				else
					PROCESSING "[+] Downloading volatility3"
					for x in {1..100}; do
						prog_bar "$x"
						sudo git clone https://github.com/volatilityfoundation/volatility3.git /opt/volatility3
						sleep .05
					done
					echo
				fi
			fi

			############################
			#   burpsuite
			############################
			# burpsuite() {
			# 	if [[ $pkg == "burpsuite" ]]; then
			# 		burp_dir="$HOME/burpsuite"
			# 		if [[ -d $burp_dir ]]; then
			# 			echo 'skipping'
			# 		else
			# 			PROCESSING "[+] Downloading burpsuite"
			# 			for x in {1..100}; do
			# 				prog_bar "$x"
			# 				wget -q 'https://portswigger.net/burp/releases/download'
			#
			# 			done
			# 			SUCCESS
			# 		fi
			# 	fi
			# }

			############################
			#   hopperv4
			############################
			# hopper() {
			# 	if [[ $pkg == "hopper" ]]; then
			# 		if [[ -x $(command -v hopper) ]]; then
			# 			echo 'skipping'
			# 		else
			# 			PROCESSING "[+] Downloading Hopperv4"
			# 			for x in {1..100}; do
			# 				prog_bar "$x"
			# 				wget -q "https://d2ap6ypl1xbe4k.cloudfront.net/Hopper-v4-4.5.28-Linux.deb"
			# 				sudo dpkg -i Hopper-v4-4.5.28-Linux.deb
			# 				rm Hopper-v4-4.5.28-Linux.deb
			#
			# 			done
			# 			echo
			# 		fi
			# 	fi
			# }

			############################
			#   sqlmap
			############################
			if [[ $pkg == "sqlmap" ]]; then
				SQLMAP_DIR="/opt/sqlmap"
				if [[ -d $SQLMAP_DIR ]]; then
					echo 'skipping'
				else
					PROCESSING "[+] Downloading sqlmap"
					for x in {1..100}; do
						prog_bar "$x"
						sudo git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git /opt/sqlmap
						sleep .05
					done
					echo
				fi
			fi
		else
			INFO "$pkg is already installed"
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
		gem install "$GEM"
	done
}

#  pip installations
install_py_mods() {
	MODULES=(
		balbuzard
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
		docker-compose
		fuzzywuzzy
		hachoir
		iptools
		ipwhois
		jsbeautifier
		levenshtein-coding
		M2Crypto
		Mako
		mitmproxy
		ndg-httpsclient
		netfilterqueue
		netifaces
		numpy
		olefile
		oletools
		passlib
		pefile
		Pillow
		pwntools
		pyasn1
		pydeep
		pydispatch
		pydivert
		pydot
		pyelftools
		pygeoip
		pylzma
		pyopenssl
		pypdns
		pypssl
		python-magic
		qt4
		r2pipe
		rarfile
		rekall
		requesocks
		requests
		scipy
		setuptools
		shodan
		uTidylib
		utidylib
		virustotal3
		xortool
		yara-python
	)

	# update $PATH for user-binaries (systemd-path user-binaries)
	if grep "export PATH=\$HOME/.local/bin/:\$PATH" ~/.bashrc; then
		echo "path exists"
	else
		echo "export PATH=\$HOME/.local/bin/:\$PATH" >>~/.bashrc
	fi

	#check_installed=$(pip list | awk '{print $1}' | awk '{if(NR>2)print}')

	PROCESSING "[+] Installing Python modules"
	sudo python3 -m pip install -U pip
	for mod in "${MODULES[@]}"; do
		sudo python3 -m pip install -U "$mod"
	done
}

# remove boilerplate directories
remove_dirs() {
	BP_DIRS=(
		"$HOME"/Desktop
		"$HOME"/Documents
		"$HOME"/Downloads
		"$HOME"/Music
		"$HOME"/Pictures
		"$HOME"/Public
		"$HOME"/Templates
		"$HOME"/Videos
	)

	for pkg in "${BP_DIRS[@]}"; do
		if [ -d "$pkg" ]; then
			PROCESSING "[+] Removing boilerplate home directories"
			rmdir "$pkg"
		fi
	done
}

PROCESSING "[+] Updating repositories"
update_sys

PROCESSING "[+] Installing packages"
install_pgks

PROCESSING "[+] Setting up Paths"
setup_paths

PROCESSING "[+] Installing Ruby Gems"
install_ruby_gems

PROCESSING "[+] Installing Python Modules"
install_py_mods

# replace default terminal emulator with terminator
if echo "$XDG_CURRENT_DESKTOP" | grep XFCE; then
	PROCESSING "[+] Setting terminator as the default terminal emulator"
	CURR_TERM=$(pstree -sA $$ | awk -F "---" '{ print $2 }')
	sudo mv /usr/bin/"$CURR_TERM" /usr/bin/"$CURR_TERM".bak
	sudo ln -s /usr/bin/terminator /usr/bin/"$CURR_TERM"
fi

PROCESSING "[+] Fixing any broken installs"
sudo apt-get --fix-broken install

PROCESSING "[+] Cleaning apt cache"
sudo apt-get clean

PROCESSING "[+] Removing old kernels"
sudo apt-get purge "$( dpkg --list | grep -P -o "linux-image-\d\S+"| head -n-4 )" -y

processing "[+] Emptying the trash"
rm -rf /home/*/.local/share/Trash/*/** &>/dev/null
rm -rf /root/.local/share/Trash/*/** &>/dev/null

SUCCESS "Final cleanup"

if [ -s $LOGFILE ]; then
	ERROR $LOGFILE
else
	SUCCESS $LOGFILE
fi

PROCESSING "[+] Updating bash prompt"
# refresh bash
exec bash
