#!/bin/bash

# Credit: JohnHammond
# https://github.com/JohnHammond/ignition_key/blob/master/ignition_key.sh

# Define colors ]
ERROR=$(tput bold && tput setaf 1)
SUCCESS=$(tput bold && tput setaf 2)
WARNING=$(tput bold && tput setaf 3)
PROCESSING=$(tput bold && tput setaf 6)
RESET=$(tput sgr0)

UPDATE() {
	sudo apt update
	sudo apt upgrade -y
}

ERROR() {
	echo -e "\n${ERROR}${1}${RESET}"
}
SUCCESS() {
	echo -e "\n${SUCCESS}${1}${RESET}"
}
WARNING() {
	echo -e "\n${WARNING}${1}${RESET}"
}
PROCESSING() {
	echo -e "\n${PROCESSING}${1}${RESET}"
}

INSTALL_CHECK() {
	progs=(snapd software-properties-common apt-transport-https code git terminator taskwarrior python3-pip build-essential libssl-dev libffi-dev python3-dev guake openvpn nmap docker.io curl pinta exiftool python-pil sqlitebrowser wireshark binwalk tesseract-ocr foremost idle pefile xclip bsdgames hexedit golang-go gccgo-go sqlite nikto sqlite nikto zbar-tools qrencode pdfcrack virtualbox-qt vagrant oracle-java8-installer ffmpeg fcrackzip unrar p7zip steghide gimp cmake mplayer sshpass tcpflow libcompress-raw-lzma-perl sublime-text simplescreenrecorder stegsolve.jar hashcat vnc_viewer.deb)
	for name in "${progs[@]}"; do
		if ! [ -x "$(command -v "$name")" ]; then
			if [[ $name == "code" ]]; then
				PROCESSING "[ Importing the Microsoft GPG key ]"
				wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
				PROCESSING "[ Enabling the Visual Studio Code repository and install ]"
				sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
				sudo apt update
				sudo apt install code -y
			elif [[ $name == "docker.io" ]]; then
				PROCESSING "[ Installing Docker ]"
				sudo apt install docker.io -y
				sudo groupadd docker
				sudo usermod -aG docker "$(logname)"
			elif [[ $name == "atom" ]]; then
				PROCESSING "[ Installing Atom ]"
				wget -qO - https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add -
				sudo sh -c 'echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" > /etc/apt/sources.list.d/atom.list'
				sudo apt update
				sudo apt install atom -y
			elif [[ $name == "xclip" ]]; then
				PROCESSING "[ Installing xclip ]"
				sudo apt install -y xclip
				grep "alias xclip" ~/.bashrc
				if [ $? -eq 1 ]; then
					echo "alias xclip='xclip -selection clipboard'" >>~/.bashrc
				fi
			elif [[ $name == "oracle-java8-installer" ]]; then
				PROCESSING "[ Installing Oracle Java 8 ]"
				echo "" | sudo add-apt-repository ppa:webupd8team/java
				sudo apt update
				sudo apt install oracle-java8-installer -y
			elif [[ $name == "sublime-text" ]]; then
				PROCESSING "[ Installing Sublime Text ]" # according to https://www.sublimetext.com/docs/3/linux_repositories.html-
				wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
				echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
				sudo apt update
				sudo apt install sublime-text -y
			elif [[ $name == "simplescreenrecorder" ]]; then
				PROCESSING "[ Installing SimpleScreenRecorder ]"
				echo "" | sudo add-apt-repository ppa:maarten-baert/simplescreenrecorder
				sudo apt update
				sudo apt install simplescreenrecorder -y
			elif [[ $name == "stegsolve.jar" ]]; then
				PROCESSING "[ Downloading stegsolve.jar ]"
				wget "http://www.caesum.com/handbook/Stegsolve.jar" -O "stegsolve.jar"
				chmod +x "stegsolve.jar"
			elif [[ $name == "hashcat" ]]; then
				PROCESSING "[ Installing hashcat ]"
				wget https://hashcat.net/files/hashcat-5.1.0.7z
				p7zip -d hashcat-5.1.0.7z
				cd hashcat-5.1.0 || exit
				cp hashcat64.bin /usr/bin/
				ln -s /usr/bin/hashcat64.bin /usr/bin/hashcat
			elif [[ $name == "vnc_viewer.deb" ]]; then
				PROCESSING "[ Install Real VNC Viewer ]"
				wget "https://www.realvnc.com/download/file/viewer.files/VNC-Viewer-6.17.1113-Linux-x64.deb" -O vnc_viewer.deb
				dpkg -i vnc_viewer.deb
				rm vnc_viewer.deb

				PROCESSING "[ Install Real VNC Connect (Server) ]"
				wget 'https://www.realvnc.com/download/file/vnc.files/VNC-Server-6.2.1-Linux-x64.deb' -O vnc_server.deb
				dpkg -i vnc_server.deb
				rm vnc_server.deb

				PROCESSING "[ Adding VNC Connect (Server) service to the default startup /etc/rc.local ]"
				grep "vncserver-x11-serviced.service" /etc/rc.local
				if [ $? -eq 1 ]; then
					echo "systemctl start vncserver-x11-serviced.service" >>~/etc/rc.local
				fi
			elif [[ $name == "snapd" ]]; then
				PROCESSING "[ Installing Snap ]"
				sudo apt install snapd -y

				PROCESSING "[ Installing Spotify ]"
				sudo snap install spotify

				PROCESSING "[ Installing volatility ]"
				sudo snap install volatility-phocean
			else
				PROCESSING "[ Installing $name ]"
				sudo apt install "$name" -y
			fi
		else
			echo "$name already installed, skipping..." &>/dev/null
		fi
	done
}

# Testing if root ]
if [ $UID -ne 0 ]; then
	ERROR "You must run this script as root!" && echo
	exit
fi

PROCESSING "[ Updating repositories ]"
UPDATE

PROCESSING "[ Checking Installed Software ]"
INSTALL_CHECK

PROCESSING "[ Setting terminator as the default terminal emulator ]"
sed -i s/Exec=gnome-terminal/Exec=terminator/g /usr/share/applications/gnome-terminal.desktop

PROCESSING "[ Forcing color prompt in ~/.bashrc ]"
echo "export PS1='${debian_chroot:+($debian_chroot)}\[\033[38;5;11m\]\u\[$(tput sgr0)\]@\h:\[$(tput sgr0)\]\[\033[38;5;6m\][\w]\[$(tput sgr0)\]: \[$(tput sgr0)\]'" >>~/.bashrc

bp_dirs=("$HOME/Desktop $HOME/Documents $HOME/Downloads $HOME/Music $HOME/Pictures $HOME/Public $HOME/Templates $HOME/Videos")
for name in "${bp_dirs[@]}"; do
	if [ -d "$name" ]; then
		PROCESSING "[ Removing boilerplate home directories ]"
		rmdir "$name"
	fi
done

############################
#   pip installations
############################
pip_progs=(requests flask flask-login colorama passlib pwntools netifaces iptools pyopenssl pydispatch scapy)
PROCESSING "[ Updating pip and installing modules ]"
python3 -m pip install -U pip
for name in "${pip_progs[@]}"; do
	if python3 -c "import $name" &>/dev/null; then
		echo 'skipping' &>/dev/null
	else
		PROCESSING "[ Installing $name ]"
		pip3 install "$name"
	fi
done

############################
#   git installations
############################
PROCESSING "[ Downloading volatility3 ]"
git clone https://github.com/volatilityfoundation/volatility3.git

############################
#   setup paths
############################
PROCESSING "[ Adding GOPATH and GOBIN to .bashrc ]"
grep "export GOPATH" ~/.bashrc
if [ $? -eq 1 ]; then
	echo "export GOPATH=\$HOME/.go/" >>~/.bashrc
fi
grep "export GOBIN" ~/.bashrc
if [ $? -eq 1 ]; then
	echo "export GOBIN=\$HOME/.go/bin" >>~/.bashrc
	echo "export PATH=\$PATH:\$GOBIN" >>~/.bashrc
fi
PROCESSING "[ Updating Prompt ]"
alias brc='source ~/.bashrc'
brc

PROCESSING "[ Installing gobuster ]"
go get github.com/OJ/gobuster
