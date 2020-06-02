#!/bin/bash

# Credit: JohnHammond
# https://github.com/JohnHammond/ignition_key/blob/master/ignition_key.sh

# Define colors ]
error=$(tput bold && tput setaf 1)
success=$(tput bold && tput setaf 2)
info=$(tput bold && tput setaf 3)
processing=$(tput bold && tput setaf 6)
reset=$(tput sgr0)

error() {
	echo -e "\n${error}[ERROR] ${1}${reset}"
}

success() {
	echo -e "\n${success}[SUCCESS] ${1}${reset}"
}

info() {
	echo -e "\n${info}[INFO] ${1}${reset}"
}

processing() {
	echo -e "\n${processing}${1}${reset}"
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
	error "Please do not run as root" && echo
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
		kazam gobuster
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
			processing "$req"
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
				processing "[+] Installing wireshark"
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
				processing "[+] Importing the Microsoft GPG key"
				wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
				processing "[+] Enabling the Visual Studio Code repository and install"
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
				processing "[+] Installing Docker"
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
				processing "[+] Installing Atom"
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
				processing "[+] Installing Sublime Text" # according to https://www.sublimetext.com/docs/3/linux_repositories.html-
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
					processing "[+] Downloading stegsolve.jar"
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
			# 		processing "[+] Installing hashcat"
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
					processing "[+] Installing Real VNC Viewer"
					for x in {1..100}; do
						prog_bar "$x"
						wget -q 'https://www.realvnc.com/download/file/viewer.files/VNC-Viewer-6.20.113-Linux-x64.deb' -O vnc_viewer.deb
						sudo dpkg -i vnc_viewer.deb >/dev/null
						rm vnc_viewer.deb
						sleep .05
					done
					echo

					processing "[+] Installing Real VNC Connect (Server)"
					for x in {1..100}; do
						prog_bar "$x"
						wget -q 'https://www.realvnc.com/download/file/vnc.files/VNC-Server-6.7.1-Linux-x64.deb' -O vnc_server.deb
						sudo dpkg -i vnc_server.deb >/dev/null
						rm vnc_server.deb
						sleep .05
					done
					echo

					processing "[+] Adding VNC Connect (Server) service to the default startup"
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
				processing "[+] Installing Snap"
				for x in {1..100}; do
					prog_bar "$x"
					sudo apt install snapd -y >/dev/null
				done
				echo

				SNAPPKGS=(spotify volatility-phocean)
				processing "[+] Installing snap packages"
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
				ghidra_dir="/opt/ghidra"
				if [[ -d $ghidra_dir ]]; then
					info "ghidra already installed here: $ghidra_dir"
				else
					for x in {1..100}; do
						prog_bar "$x"
						wget -q 'https://ghidra-sre.org/ghidra_9.1.2_PUBLIC_20200212.zip' --no-hsts
						sudo unzip -q ghidra_9.1.2_PUBLIC_20200212.zip -d /opt && sudo mv /opt/ghidra_* /opt/ghidra >/dev/null
						rm ghidra_*.zip
						sleep .05
					done
					echo
				fi
				# jdk_dir="/opt/jdk-11"
				# if [[ -d $jdk_dir ]]; then
				# 	info "jdk-11 already installed here: $jdk_dir"
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
				vol_dir="/opt/volatility3"
				if [[ -d $vol_dir ]]; then
					echo 'skipping' &>/dev/null
				else
					processing "[+] Downloading volatility3"
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
			# 			processing "[+] Downloading burpsuite"
			# 			for x in {1..100}; do
			# 				prog_bar "$x"
			# 				wget -q 'https://portswigger.net/burp/releases/download'
			#
			# 			done
			# 			success
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
			# 			processing "[+] Downloading Hopperv4"
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
				sqlmap_dir="/opt/sqlmap"
				if [[ -d $sqlmap_dir ]]; then
					echo 'skipping' &>/dev/null
				else
					processing "[+] Downloading sqlmap"
					for x in {1..100}; do
						prog_bar "$x"
						sudo git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git /opt/sqlmap >/dev/null
						sleep .05
					done
					echo
				fi
			fi
		else
			info "$pkg is already installed"
		fi
	done
}

# setup paths
setup_paths() {
	processing "[+] Forcing color prompt in ~/.bashrc"
	if ! grep "export PS1" ~/.bashrc >/dev/null; then
		echo "export PS1='${debian_chroot:+($debian_chroot)}\[\033[38;5;11m\]\u\[$(tput sgr0)\]@\h:\[$(tput sgr0)\]\[\033[38;5;6m\][\w]\[$(tput sgr0)\]: \[$(tput sgr0)\]'" >>~/.bashrc
	fi

	processing "[+] Adding sqlmap to .bashrc"
	if ! grep "alias sqlmap" ~/.bashrc >/dev/null; then
		echo "alias sqlmap='python /opt/sqlmap/sqlmap.py'" >>~/.bashrc
	fi

	processing "[+] Adding ghidra to .bashrc"
	if ! grep "alias ghidra" ~/.bashrc >/dev/null; then
		echo "alias ghidra='/opt/ghidra/ghidraRun'" >>~/.bashrc
	fi

	# processing "[+] Adding openjdk to .bashrc"
	# if ! grep "jdk" ~/.bashrc >/dev/null; then
	# 	echo "export PATH=/opt/jdk-11/bin:$PATH" >>~/.bashrc
	# fi

	processing "[+] Adding volatility3 to .bashrc"
	if ! grep "alias vol3" ~/.bashrc >/dev/null; then
		echo "alias vol3='python3 /opt/volatility3/vol.py'" >>~/.bashrc
	fi

	processing "[+] Adding xclip to .bashrc"
	if ! grep "alias xclip" ~/.bashrc >/dev/null; then
		echo "alias xclip='xclip -selection clipboard'" >>~/.bashrc
	fi
}

#  pip installations
py_mods() {
	modules=(requests
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

	processing "[+] Installing Python modules"
	sudo python3 -m pip install --upgrade pip >/dev/null
	for mod in "${modules[@]}"; do
		sudo python3 -m pip install --upgrade "$mod" >/dev/null
	done
}

# remove boilerplate directories
remove_dirs() {
	bp_dirs=(
		"$HOME"/Desktop
		"$HOME"/Documents
		"$HOME"/Downloads
		"$HOME"/Music
		"$HOME"/Pictures
		"$HOME"/Public
		"$HOME"/Templates
		"$HOME"/Videos
	)

	for pkg in "${bp_dirs[@]}"; do
		if [ -d "$pkg" ]; then
			processing "[+] Removing boilerplate home directories"
			rmdir "$pkg"
		fi
	done
}

processing "[+] Updating repositories"
update_sys 2>install_errors.txt

processing "[+] Installing packages"
install_pgks 2>install_errors.txt

processing "[+] Setting up Paths"
setup_paths 2>install_errors.txt

processing "[+] Installing Python Modules"
py_mods 2>install_errors.txt

# replace default terminal emulator with terminator
if echo "$XDG_CURRENT_DESKTOP" | grep XFCE &>/dev/null; then
	processing "[+] Setting terminator as the default terminal emulator"
	curr_term=$(pstree -sA $$ | awk -F "---" '{ print $2 }')
	sudo mv /usr/bin/"$curr_term" /usr/bin/"$curr_term".bak
	sudo ln -s /usr/bin/terminator /usr/bin/"$curr_term"
fi

processing "[+] Fixing any broken installs"
sudo apt --fix-broken install &>/dev/null

processing "[+] Updating bash prompt"
if [ -s "install_errors.txt" ]; then
	error "see install_errors.txt"
else
	success "No errors encountered"
fi
# refresh bash
exec bash