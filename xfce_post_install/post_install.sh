#!/bin/bash

# Credit: JohnHammond
# https://github.com/JohnHammond/ignition_key/blob/master/ignition_key.sh

# Define colors ]
ERROR=$(tput bold && tput setaf 1)
SUCCESS=$(tput bold && tput setaf 2)
INFO=$(tput bold && tput setaf 3)
PROCESSING=$(tput bold && tput setaf 6)
reset=$(tput sgr0)

ERROR() {
	echo -e "\n${ERROR}[ERROR] ${1}${reset}"
}

SUCCESS() {
	echo -e "\n${SUCCESS}[SUCCESS] ${1}${reset}"
}

INFO() {
	echo -e "\n${INFO}[INFO] ${1}${reset}"
}

PROCESSING() {
	echo -e "\n${PROCESSING}${1}${reset}"
}

# progress bar
# ref: https://unix.stackexchange.com/questions/415421/linux-how-to-create-simple-progress-bar-in-bash
prog_bar() {
	local width=25 p=$1
	shift # same as shift 1
	# create a string of spaces, then change them to dots
	printf -v dots "%*s" "$((p * width / 100))" ""
	dots=${dots// /.}
	# print those dots on a fixed-width space plus the percentage etc.
	printf "\r\e[K|%-*s| %3d %% %s" "$width" "$dots" "$p" "$*"
}

# check if ran as sudo
if [ "$EUID" -eq 0 ]; then
	ERROR "Please do not run as root" && echo
	exit
fi

update_sys() {
	sudo apt update
	sudo apt upgrade -y
	sudo apt autoremove -y
}

install_pgks() {
	REQPKGS=(
		apt-transport-https
		binwalk
		bsdgames
		build-essential
		cmake
		curl
		fcrackzip
		ffmpeg
		font-manager
		foremost
		gimp
		git terminator
		golang-go
		guake
		hashcat
		hexedit
		idle
		imagemagick
		kazam 
		gobuster
		libcompress-raw-lzma-perl
		libffi-dev
		libimage-exiftool-perl
		libncurses5
		libssl-dev
		mplayer
		nikto
		nmap
		openjdk-13-jdk
		openjdk-13-jre
		openvpn
		p7zip
		pdfcrack
		pinta
		python3-flask
		python3-pip
		python3-scapy
		qrencode
		software-properties-common
		sqlite
		sqlite
		sqlitebrowser
		sshpass
		steghide
		taskwarrior
		tcpflow
		tesseract-ocr
		unrar
		vagrant
		virtualbox-qt
		whois
		xclip
		zbar-tools
	)

	for req in "${REQPKGS[@]}"; do
		if ! sudo dpkg-query -l | grep -w "$req" &>/dev/null; then
			PROCESSING "$req"
			for x in {1..100}; do
				prog_bar "$x"
				sudo apt install -y "$req" >/dev/null
				sleep .05
			done
			echo
		fi
	done

	OPTPKGS=(
		atom
		burpsuite
		code
		docker
		ghidra
		hashcat
		hopper
		snapd
		sqlmap
		stegsolve
		sublime
		vnc
		volatility3
		wireshark
	)

	for pkg in "${OPTPKGS[@]}"; do
		if ! sudo dpkg-query -l | grep -w "$pkg" &>/dev/null; then
			############################
			#   wireshark
			############################
			if [[ $pkg == "wireshark" ]]; then
				PROCESSING "[+] Installing wireshark"
				for x in {1..100}; do
					prog_bar "$x"
					sudo add-apt-repository ppa:wireshark-dev/stable >/dev/null
					sudo apt update >/dev/null
					sudo DEBIAN_FRONTEND=noninteractive apt-get -y install wireshark >/dev/null
					unset DEBIAN_FRONTEND
					sleep .05
				done
				echo
			fi

			############################
			#   vscode
			############################
			if [[ $pkg == "code" ]]; then
				PROCESSING "[+] Importing the Microsoft GPG key"
				wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
				PROCESSING "[+] Enabling the Visual Studio Code repository and install"
				sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" >/dev/null
				for x in {1..100}; do
					prog_bar "$x"
					sudo apt update >/dev/null
					sudo apt install code -y >/dev/null
					sleep .05
				done
				echo
			fi

			############################
			#   docker
			############################
			if [[ $pkg == "docker" ]]; then
				PROCESSING "[+] Installing Docker"
				for x in {1..100}; do
					prog_bar "$x"
					sudo apt install docker.io -y >/dev/null
					sudo groupadd docker >/dev/null
					sudo usermod -aG docker "$(logpkg)"
					sleep .05
				done
				echo
			fi

			############################
			#   atom
			############################
			if [[ $pkg == "atom" ]]; then
				PROCESSING "[+] Installing Atom"
				for x in {1..100}; do
					prog_bar "$x"
					wget -qO - https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add -
					sudo sh -c 'echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" > /etc/apt/sources.list.d/atom.list' >/dev/null
					sudo apt update >/dev/null
					sudo apt install atom -y >/dev/null
					sleep .05
				done
				echo
			fi

			############################
			#   sublime
			############################
			if [[ $pkg == "sublime-text" ]]; then
				PROCESSING "[+] Installing Sublime Text" # according to https://www.sublimetext.com/docs/3/linux_repositories.html-
				for x in {1..100}; do
					prog_bar "$x"
					wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
					echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
					sudo apt update >/dev/null
					sudo apt install sublime-text -y >/dev/null
					sleep .05
				done
				echo
			fi

			############################
			#  stegsolve
			############################
			if [[ $pkg == "stegsolve" ]]; then
				if [ -f "stegsolve.jar" ]; then
					echo 'skipping' &>/dev/null
				else
					PROCESSING "[+] Downloading stegsolve.jar"
					for x in {1..100}; do
						prog_bar "$x"
						wget -q "http://www.caesum.com/handbook/Stegsolve.jar" -O "stegsolve.jar"
						chmod +x "stegsolve.jar"
						sleep .05
					done
					echo
				fi
			fi

			############################
			#   hashcat
			############################
			# if [[ $pkg == "hashcat" ]]; then
			# 	if [[ -x $(command -v hashcat) ]]; then
			# 		echo 'skipping' &>/dev/null
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
				if ! sudo dpkg-query -l | grep realvnc &>/dev/null; then
					echo "$pkg is installed" &>/dev/null
				else
					PROCESSING "[+] Installing Real VNC Viewer"
					for x in {1..100}; do
						prog_bar "$x"
						wget -q 'https://www.realvnc.com/download/file/viewer.files/VNC-Viewer-6.20.113-Linux-x64.deb' -O vnc_viewer.deb
						sudo dpkg -i vnc_viewer.deb >/dev/null
						rm vnc_viewer.deb
						sleep .05
					done
					echo

					PROCESSING "[+] Installing Real VNC Connect (Server)"
					for x in {1..100}; do
						prog_bar "$x"
						wget -q 'https://www.realvnc.com/download/file/vnc.files/VNC-Server-6.7.1-Linux-x64.deb' -O vnc_server.deb
						sudo dpkg -i vnc_server.deb >/dev/null
						rm vnc_server.deb
						sleep .05
					done
					echo

					PROCESSING "[+] Adding VNC Connect (Server) service to the default startup"
					if ! systemctl is-active --quiet vncserver-x11-serviced; then
						for x in {1..100}; do
							prog_bar "$x"
							sudo /etc/init.d/vncserver-x11-serviced start
							sudo update-rc.d vncserver-x11-serviced defaults
							sleep .05
						done
						echo
					fi
				fi
			fi

			############################
			#   snapd
			############################
			if [[ $pkg == "snapd" ]]; then
				PROCESSING "[+] Installing Snap"
				for x in {1..100}; do
					prog_bar "$x"
					sudo apt install snapd -y >/dev/null
				done
				echo

				SNAPPKGS=(spotify volatility-phocean)
				PROCESSING "[+] Installing snap packages"
				for x in {1..100}; do
					prog_bar "$x"
					sudo snap install "${SNAPPKGS[@]}" >/dev/null
					sleep .05
				done
				echo
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
						sudo unzip -q ghidra_*.zip -d /opt && sudo mv /opt/ghidra_* /opt/ghidra >/dev/null
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
					echo 'skipping' &>/dev/null
				else
					PROCESSING "[+] Downloading volatility3"
					for x in {1..100}; do
						prog_bar "$x"
						sudo git clone https://github.com/volatilityfoundation/volatility3.git /opt/volatility3 >/dev/null
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
			# 			echo 'skipping' &>/dev/null
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
			# 			echo 'skipping' &>/dev/null
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
					echo 'skipping' &>/dev/null
				else
					PROCESSING "[+] Downloading sqlmap"
					for x in {1..100}; do
						prog_bar "$x"
						sudo git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git /opt/sqlmap >/dev/null
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
	if ! grep "export PS1" ~/.bashrc >/dev/null; then
		echo "export PS1='${debian_chroot:+($debian_chroot)}\[\033[38;5;11m\]\u\[$(tput sgr0)\]@\h:\[$(tput sgr0)\]\[\033[38;5;6m\][\w]\[$(tput sgr0)\]: \[$(tput sgr0)\]'" >>~/.bashrc
	fi

	PROCESSING "[+] Adding sqlmap to .bashrc"
	if ! grep "alias sqlmap" ~/.bashrc >/dev/null; then
		echo "alias sqlmap='python /opt/sqlmap/sqlmap.py'" >>~/.bashrc
	fi

	PROCESSING "[+] Adding volatility3 to .bashrc"
	if ! grep "alias vol3" ~/.bashrc >/dev/null; then
		echo "alias vol3='python3 /opt/volatility3/vol.py'" >>~/.bashrc
	fi

	PROCESSING "[+] Adding xclip to .bashrc"
	if ! grep "alias xclip" ~/.bashrc >/dev/null; then
		echo "alias xclip='xclip -selection clipboard'" >>~/.bashrc
	fi
}

#  pip installations
py_mods() {
	MODULES=(requests
		bs4
		colorama
		iptools
		Mako
		netifaces
		passlib
		pefile
		Pillow
		pwntools
		pydispatch
		pyopenssl
		requests
	)

	# update $PATH for user-binaries (systemd-path user-binaries)
	if grep "export PATH=\$HOME/.local/bin/:\$PATH" ~/.bashrc >/dev/null; then
		echo "path exists" &>/dev/null
	else
		echo "export PATH=\$HOME/.local/bin/:\$PATH" >>~/.bashrc
	fi

	#check_installed=$(pip list | awk '{print $1}' | awk '{if(NR>2)print}')

	PROCESSING "[+] Installing Python modules"
	sudo python3 -m pip install -U pip >/dev/null
	for mod in "${MODULES[@]}"; do
		sudo python3 -m pip install -U "$mod" >/dev/null
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
update_sys 2>install_errorss.txt

PROCESSING "[+] Installing packages"
install_pgks 2>install_errors.txt

PROCESSING "[+] Setting up Paths"
setup_paths 2>install_errors.txt

PROCESSING "[+] Installing Python Modules"
py_mods 2>install_errors.txt

# replace default terminal emulator with terminator
if echo "$XDG_CURRENT_DESKTOP" | grep XFCE &>/dev/null; then
	PROCESSING "[+] Setting terminator as the default terminal emulator"
	CURR_TERM=$(pstree -sA $$ | awk -F "---" '{ print $2 }')
	sudo mv /usr/bin/"$CURR_TERM" /usr/bin/"$CURR_TERM".bak
	sudo ln -s /usr/bin/terminator /usr/bin/"$CURR_TERM"
fi

PROCESSING "[+] Fixing any broken installs"
sudo apt --fix-broken install &>/dev/null

PROCESSING "[+] Updating bash prompt"
if [ -s "install_errors.txt" ]; then
	ERROR "see install_errors.txt"
else
	SUCCESS "No ERRORs encountered"
fi
# refresh bash
exec bash
