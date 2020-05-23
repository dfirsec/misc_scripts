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

# check if ran as sudo
if [ "$EUID" -eq 0 ]; then
	error "Please do not run as root" && echo
	exit
fi

update_sys() {
	sudo apt update
	sudo apt upgrade -y
}

processing "[ Forcing color prompt in ~/.bashrc ]"
echo "export PS1='${debian_chroot:+($debian_chroot)}\[\033[38;5;11m\]\u\[$(tput sgr0)\]@\h:\[$(tput sgr0)\]\[\033[38;5;6m\][\w]\[$(tput sgr0)\]: \[$(tput sgr0)\]'" >>~/.bashrc

install_check() {
	progs=(snapd software-properties-common apt-transport-https code git terminator taskwarrior python3-pip build-essential libssl-dev libffi-dev python3-dev guake openvpn nmap docker.io curl pinta libimage-exiftool-perl python-pil sqlitebrowser wireshark binwalk tesseract-ocr foremost idle xclip bsdgames hexedit golang-go gccgo-go sqlite nikto sqlite nikto zbar-tools qrencode pdfcrack virtualbox-qt vagrant ffmpeg fcrackzip unrar p7zip steghide gimp cmake mplayer sshpass tcpflow libcompress-raw-lzma-perl sublime-text simplescreenrecorder stegsolve hashcat vnc gobuster font-manager openjdk-11-jre-headless ghidra volatility3)
	for name in "${progs[@]}"; do
		dpkg -s "$name" &>/dev/null
		if [ $? -eq 0 ]; then
			echo "$name is installed" &>/dev/null
		else
			############################
			#   vscode
			############################
			if [[ $name == "code" ]]; then
				processing "[ Importing the Microsoft GPG key ]"
				wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
				processing "[ Enabling the Visual Studio Code repository and install ]"
				sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
				sudo apt update
				sudo apt install code -y

			############################
			#   docker
			############################
			elif [[ $name == "docker.io" ]]; then
				processing "[ Installing Docker ]"
				sudo apt install docker.io -y
				sudo groupadd docker
				sudo usermod -aG docker "$(logname)"

			############################
			#   atom
			############################
			elif [[ $name == "atom" ]]; then
				processing "[ Installing Atom ]"
				wget -qO - https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add -
				sudo sh -c 'echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" > /etc/apt/sources.list.d/atom.list'
				sudo apt update
				sudo apt install atom -y

			############################
			#   xclip
			############################
			elif [[ $name == "xclip" ]]; then
				processing "[ Installing xclip ]"
				sudo apt install -y xclip
				grep "alias xclip" ~/.bashrc
				if [ $? -eq 1 ]; then
					echo "alias xclip='xclip -selection clipboard'" >>~/.bashrc
				fi

			############################
			#   sublime
			############################
			elif [[ $name == "sublime-text" ]]; then
				processing "[ Installing Sublime Text ]" # according to https://www.sublimetext.com/docs/3/linux_repositories.html-
				wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
				echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
				sudo apt update
				sudo apt install sublime-text -y

			############################
			#  simplescreenrecorder
			############################
			elif [[ $name == "simplescreenrecorder" ]]; then
				processing "[ Installing SimpleScreenRecorder ]"
				echo "" | sudo add-apt-repository ppa:maarten-baert/simplescreenrecorder
				sudo apt update
				sudo apt install simplescreenrecorder -y

			############################
			#  stegsolve
			############################
			elif [[ $name == "stegsolve" ]]; then
				if [ -f "stegsolve.jar" ]; then
					echo 'skipping' &>/dev/null
				else
					processing "[ Downloading stegsolve.jar ]"
					wget "http://www.caesum.com/handbook/Stegsolve.jar" -O "stegsolve.jar"
					chmod +x "stegsolve.jar"
				fi

			############################
			#   hashcat
			############################
			elif [[ $name == "hashcat" ]]; then
				if [[ -x $(command -v hashcat) ]]; then
					echo 'skipping' &>/dev/null
				else
					processing "[ Installing hashcat ]"
					wget https://hashcat.net/files/hashcat-5.1.0.7z
					p7zip -d hashcat-5.1.0.7z
					cd hashcat-5.1.0 || exit
					cp hashcat64.bin /usr/bin/
					ln -s /usr/bin/hashcat64.bin /usr/bin/hashcat
					cd || exit
					rm -rf hashcat-5.1.0
				fi

			############################
			#   vnc
			############################
			elif [[ $name == "vnc" ]]; then
				sudo dpkg-query -l | grep vnc &>/dev/null
				if [ $? -eq 0 ]; then
					echo "$name is installed" &>/dev/null
				else
					processing "[ Install Real VNC Viewer ]"
					wget "https://www.realvnc.com/download/file/viewer.files/VNC-Viewer-6.20.113-Linux-x64.deb" -O vnc_viewer.deb
					dpkg -i vnc_viewer.deb
					rm vnc_viewer.deb

					processing "[ Install Real VNC Connect (Server) ]"
					wget 'https://www.realvnc.com/download/file/vnc.files/VNC-Server-6.7.1-Linux-x64.deb' -O vnc_server.deb
					dpkg -i vnc_server.deb
					rm vnc_server.deb

					processing "[ Adding VNC Connect (Server) service to the default startup /etc/rc.local ]"
					grep "vncserver-x11-serviced.service" /etc/rc.local
					if [ $? -eq 1 ]; then
						echo "systemctl start vncserver-x11-serviced.service" >>~/etc/rc.local
					fi
				fi

			############################
			#   snapd
			############################
			elif [[ $name == "snapd" ]]; then
				processing "[ Installing Snap ]"
				sudo apt install snapd -y

				snap_progs=(spotify volatility-phocean)
				for prog in "${snap_progs[@]}"; do
					snap list | grep "$prog" &>/dev/null
					if [ $? -eq 0 ]; then
						echo 'skipping' &>/dev/null
					else
						processing "[ Installing Spotify ]"
						sudo snap install spotify

						processing "[ Installing volatility ]"
						sudo snap install volatility-phocean
					fi
				done

			############################
			#   ghidra
			############################
			elif [[ $name == "ghidra" ]]; then
				ghidra_dir="/opt/ghidra"
				jdk_dir="/opt/jdk-11"
				if [[ -d $ghidra_dir ]]; then
					info "ghidra already installed here: $ghidra_dir"
				else
					wget 'https://ghidra-sre.org/ghidra_9.1.2_PUBLIC_20200212.zip' --no-hsts
					sudo unzip -q ghidra_9.1.2_PUBLIC_20200212.zip -d /opt && sudo mv /opt/ghidra_* /opt/ghidra
				fi
				if [[ -d $jdk_dir ]]; then
					info "jdk-11 already installed here: $jdk_dir"
				else
					wget 'https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.7%2B10/OpenJDK11U-jdk_x64_linux_hotspot_11.0.7_10.tar.gz' --no-hsts
					sudo mkdir -p /opt/jdk-11/ && sudo tar -xzf OpenJDK11U-jdk_x64_linux_hotspot_11.0.7_10.tar.gz -C /opt/jdk-11/ --strip-components 1
				fi

			############################
			#   volatility3
			############################
			elif [[ $name == "volatility3" ]]; then
				vol_dir="$HOME/volatility3"
				if [[ -d $vol_dir ]]; then
					echo 'skipping' &>/dev/null
				else
					processing "[ Downloading volatility3 ]"
					git clone https://github.com/volatilityfoundation/volatility3.git
				fi

			############################
			#   process all others
			############################
			else
				processing "[ Installing $name ]"
				sudo apt install "$name" -y
			fi
		fi
	done
}

#  pip installations
pip_installs() {
	pip_progs=(requests flask flask-login colorama passlib pwntools netifaces iptools pyopenssl pydispatch scapy pefile)
	for name in "${pip_progs[@]}"; do
		python3 -c "import $name" &>/dev/null
		if [ $? -eq 0 ]; then
			echo 'skipping' &>/dev/null
		else
			processing "[ Installing $name ]"
			pip3 install "$name"
		fi
	done
}

# setup paths
setup_paths() {
	processing "[ Adding GOPATH and GOBIN to .bashrc ]"
	grep "export GOPATH" ~/.bashrc
	if [ $? -eq 1 ]; then
		echo "export GOPATH=\$HOME/.go/" >>~/.bashrc
	fi
	grep "export GOBIN" ~/.bashrc
	if [ $? -eq 1 ]; then
		echo "export GOBIN=\$HOME/.go/bin" >>~/.bashrc
		echo "export PATH=\$PATH:\$GOBIN" >>~/.bashrc
	fi
}

# remove boilerplate directories
remove_dirs() {
	bp_dirs=("$HOME/Desktop $HOME/Documents $HOME/Downloads $HOME/Music $HOME/Pictures $HOME/Public $HOME/Templates $HOME/Videos")
	for name in "${bp_dirs[@]}"; do
		if [ -d "$name" ]; then
			processing "[ Removing boilerplate home directories ]"
			rmdir "$name"
		fi
	done
}

processing "[ Updating repositories ]"
update_sys

processing "[ Checking Installed Software ]"
install_check

processing "[ Installing Python Modules ]"
pip_installs

processing "[ Setting terminator as the default terminal emulator ]"
sed -i s/Exec=gnome-terminal/Exec=terminator/g /usr/share/applications/gnome-terminal.desktop

processing "[ Setting up Paths ]"
setup_paths

processing "[ Updating Prompt ]"
echo "Done!"
exec bash
