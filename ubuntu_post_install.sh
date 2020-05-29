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
	sudo apt autoremove -y
}

install_check() {
	reqpkgs=(python3-pip python3-flask python3-scapy libncurses5 software-properties-common apt-transport-https git terminator taskwarrior build-essential libssl-dev libffi-dev guake openvpn nmap curl pinta libimage-exiftool-perl sqlitebrowser binwalk tesseract-ocr foremost idle xclip bsdgames hexedit golang-go sqlite nikto sqlite nikto zbar-tools qrencode pdfcrack virtualbox-qt vagrant ffmpeg fcrackzip unrar p7zip steghide gimp cmake mplayer sshpass tcpflow libcompress-raw-lzma-perl kazam gobuster font-manager hexedit openjdk-13-jre openjdk-13-jdk)

	sudo apt install -y "${reqpkgs[@]}"

	optpkgs=(code docker atom sublime ghidra volatility3 hopper stegsolve vnc hashcat snapd sqlmap burpsuite wireshark)

	for pkg in "${optpkgs[@]}"; do
		if ! sudo dpkg -s "$pkg" &>/dev/null; then
			############################
			#   wireshark
			############################
			if [[ $pkg == "wireshark" ]]; then
				processing "[+] Installing wireshark"
				sudo DEBIAN_FRONTEND=noninteractive apt-get -y install wireshark >/dev/null && echo "Successfully installed $pkg"
				unset DEBIAN_FRONTEND
			fi
			############################
			#   vscode
			############################
			if [[ $pkg == "code" ]]; then
				processing "[+] Importing the Microsoft GPG key"
				wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
				processing "[+] Enabling the Visual Studio Code repository and install"
				sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
				sudo apt update
				sudo apt install code -y >/dev/null && echo "Successfully installed $pkg"
			fi
			############################
			#   docker
			############################
			if [[ $pkg == "docker" ]]; then
				processing "[+] Installing Docker"
				sudo apt install docker.io -y >/dev/null && echo "Successfully installed $pkg"
				sudo groupadd docker
				sudo usermod -aG docker "$(logpkg)"
			fi
			############################
			#   atom
			############################
			if [[ $pkg == "atom" ]]; then
				processing "[+] Installing Atom"
				wget -qO - https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add -
				sudo sh -c 'echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" > /etc/apt/sources.list.d/atom.list'
				sudo apt update
				sudo apt install atom -y >/dev/null && echo "Successfully installed $pkg"
			fi
			############################
			#   sublime
			############################
			if [[ $pkg == "sublime-text" ]]; then
				processing "[+] Installing Sublime Text" # according to https://www.sublimetext.com/docs/3/linux_repositories.html-
				wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
				echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
				sudo apt update
				sudo apt install sublime-text -y >/dev/null && echo "Successfully installed $pkg"
			fi
			############################
			#  stegsolve
			############################
			if [[ $pkg == "stegsolve" ]]; then
				if [ -f "stegsolve.jar" ]; then
					echo 'skipping' &>/dev/null
				else
					processing "[+] Downloading stegsolve.jar"
					wget "http://www.caesum.com/handbook/Stegsolve.jar" -O "stegsolve.jar"
					chmod +x "stegsolve.jar"
				fi
			fi
			############################
			#   hashcat
			############################
			if [[ $pkg == "hashcat" ]]; then
				if [[ -x $(command -v hashcat) ]]; then
					echo 'skipping' &>/dev/null
				else
					processing "[+] Installing hashcat"
					wget https://hashcat.net/files/hashcat-5.1.0.7z
					p7zip -d hashcat-5.1.0.7z
					cd hashcat-5.1.0 || exit
					cp hashcat64.bin /usr/bin/
					ln -s /usr/bin/hashcat64.bin /usr/bin/hashcat
					cd || exit
					rm -rf hashcat-5.1.0
				fi
			fi
			############################
			#   vnc
			############################
			if [[ $pkg == "vnc" ]]; then
				if ! sudo dpkg-query -l | grep vnc &>/dev/null; then
					echo "$pkg is installed" &>/dev/null
				else
					processing "[+] Install Real VNC Viewer"
					wget "https://www.realvnc.com/download/file/viewer.files/VNC-Viewer-6.20.113-Linux-x64.deb" -O vnc_viewer.deb
					dpkg -i vnc_viewer.deb >/dev/null && echo "Successfully installed $pkg"
					rm vnc_viewer.deb

					processing "[+] Install Real VNC Connect (Server)"
					wget 'https://www.realvnc.com/download/file/vnc.files/VNC-Server-6.7.1-Linux-x64.deb' -O vnc_server.deb
					dpkg -i vnc_server.deb >/dev/null && echo "Successfully installed $pkg"
					rm vnc_server.deb

					processing "[+] Adding VNC Connect (Server) service to the default startup"
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
				processing "[+] Installing Snap"
				sudo apt install snapd -y >/dev/null && echo "Successfully installed $pkg"

				snap_pkgs=(spotify volatility-phocean)
				for snap in "${snap_pkgs[@]}"; do
					processing "[+] Installing $snap"
				done
				sudo snap install "${snap_pkgs[@]}"

				# for snap in "${snap_pkgs[@]}"; do
				# 	# snap list | grep "$prog" &>/dev/null
				# 	if ! snap list | grep "$snap"; then
				# 		echo 'skipping' &>/dev/null
				# 	else
				# 		processing "[+] Installing Spotify"
				# 		sudo snap install spotify && echo "Successfully installed $snap"

				# 		processing "[+] Installing volatility"
				# 		sudo snap install volatility-phocean && echo "Successfully installed $snap"
				# 	fi
				# done
			fi
			############################
			#   ghidra
			############################
			if [[ $pkg == "ghidra" ]]; then
				ghidra_dir="/opt/ghidra"
				if [[ -d $ghidra_dir ]]; then
					info "ghidra already installed here: $ghidra_dir"
				else
					wget 'https://ghidra-sre.org/ghidra_9.1.2_PUBLIC_20200212.zip' --no-hsts
					sudo unzip -q ghidra_9.1.2_PUBLIC_20200212.zip -d /opt && sudo mv /opt/ghidra_* /opt/ghidra
					rm ghidra_*.zip
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
				vol_dir="opt/volatility3"
				if [[ -d $vol_dir ]]; then
					echo 'skipping' &>/dev/null
				else
					processing "[+] Downloading volatility3"
					sudo git clone https://github.com/volatilityfoundation/volatility3.git /opt/volatility3
				fi
			fi
		############################
		#   burpsuite
		############################
		elif [[ $pkg == "burpsuite" ]]; then
			burp_dir="$HOME/burpsuite"
			if [[ -d $burp_dir ]]; then
				echo 'skipping' &>/dev/null
			else
				processing "[+] Downloading volatility3"
				wget 'https://portswigger.net/burp/releases/download'
			fi

			############################
			#   hopperv4
			############################
			if [[ $pkg == "hopper" ]]; then
				if [[ -x $(command -v hopper) ]]; then
					echo 'skipping' &>/dev/null
				else
					processing "[+] Downloading Hopperv4"
					wget "https://d2ap6ypl1xbe4k.cloudfront.net/Hopper-v4-4.5.28-Linux.deb"
					sudo dpkg -i Hopper-v4-4.5.28-Linux.deb
					rm Hopper-v4-4.5.28-Linux.deb
				fi
			fi
			############################
			#   sqlmap
			############################
			if [[ $pkg == "sqlmap" ]]; then
				sqlmap_dir="opt/sqlmap"
				if [[ -d $sqlmap_dir ]]; then
					echo 'skipping' &>/dev/null
				else
					processing "[+] Downloading sqlmap"
					sudo git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git /opt/sqlmap
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
	if ! grep "export PS1" ~/.bashrc; then
		echo "export PS1='${debian_chroot:+($debian_chroot)}\[\033[38;5;11m\]\u\[$(tput sgr0)\]@\h:\[$(tput sgr0)\]\[\033[38;5;6m\][\w]\[$(tput sgr0)\]: \[$(tput sgr0)\]'" >>~/.bashrc
	fi
	processing "[+] Adding sqlmap to .bashrc"
	if ! grep "sqlmap" ~/.bashrc; then
		echo "alias sqlmap='python /opt/sqlmap/sqlmap.py'" >>~/.bashrc
	fi
	processing "[+] Adding ghidra to .bashrc"
	if ! grep "ghidra" ~/.bashrc; then
		echo "alias ghidra='/opt/ghidra/ghidraRun'" >>~/.bashrc
	fi
	# processing "[+] Adding openjdk to .bashrc"
	# if ! grep "jdk" ~/.bashrc; then
	# 	echo "export PATH=/opt/jdk-11/bin:$PATH" >>~/.bashrc
	# fi
	processing "[+] Adding volatility3 to .bashrc"
	if ! grep "vol3" ~/.bashrc; then
		echo "alias vol3='python3 /opt/volatility3/vol.py'" >>~/.bashrc
	fi
	processing "[+] Adding xclip to .bashrc"
	if ! grep "xclip" ~/.bashrc; then
		echo "alias xclip='xclip -selection clipboard'" >>~/.bashrc
	fi
}

#  pip installations
py_mods() {
	modules=(requests mako colorama passlib pwntools netifaces iptools pyopenssl pydispatch pefile Pillow)
	if grep "export PATH=\$HOME/.local/bin/:\$PATH" ~/.bashrc
	then
		echo "path exists" &>/dev/null
	else
		echo "export PATH=\$HOME/.local/bin/:\$PATH" >>~/.bashrc
	fi
	processing "[+] Installing Python modules"
	sudo python3 -m pip install --upgrade pip
	sudo python3 -m pip install --upgrade "${modules[@]}"

}

# remove boilerplate directories
remove_dirs() {
	bp_dirs=("$HOME/Desktop $HOME/Documents $HOME/Downloads $HOME/Music $HOME/Pictures $HOME/Public $HOME/Templates $HOME/Videos")
	for pkg in "${bp_dirs[@]}"; do
		if [ -d "$pkg" ]; then
			processing "[+] Removing boilerplate home directories"
			rmdir "$pkg"
		fi
	done
}

processing "[+] Updating repositories"
update_sys 2>install_errors.txt

processing "[+] Checking Installed Software"
install_check 2>install_errors.txt

processing "[+] Setting up Paths"
setup_paths 2>install_errors.txt

processing "[+] Installing Python Modules"
py_mods 2>install_errors.txt

if echo "$XDG_CURRENT_DESKTOP" | grep XFCE &>/dev/null; then
	processing "[+] Setting terminator as the default terminal emulator"
	curr_term=$(pstree -sA $$ | awk -F "---" '{ print $2 }')
	sudo mv /usr/bin/"$curr_term" /usr/bin/"$curr_term".bak
	sudo ln -s /usr/bin/terminator /usr/bin/"$curr_term"
fi

processing "[+] Updating bash prompt"
echo "Done!"
if [ -s "install_errors.txt" ]; then
	error "see install_errors.txt"
else
	success "No errors encountered"
fi

exec bash
