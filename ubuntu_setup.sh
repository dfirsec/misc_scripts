#!/bin/bash

# CERRORit: JohnHammond
# https://github.com/JohnHammond/ignition_key/blob/master/ignition_key.sh

# Define colors ]
ERROR=$(tput bold && tput setaf 1)
SUCCESS=$(tput bold && tput setaf 2)
WARNING=$(tput bold && tput setaf 3)
PROCESSING=$(tput bold && tput setaf 6)
RESET=$(tput sgr0)

UPDATE(){
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

# Testing if root ]
if [ $UID -ne 0 ]; then
	ERROR "You must run this script as root!" && echo
	exit
fi


PROCESSING "[ Updating repositories ]"
UPDATE

PROCESSING "[ Installing Snap ]"
sudo apt install snapd

PROCESSING "[ Installing Visual Studio Code ]"
sudo apt install software-properties-common apt-transport-https -y

PROCESSING "[ Importing the Microsoft GPG key ]"
wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -

PROCESSING "[ Enabling the Visual Studio Code repository and install ]"
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
sudo apt update
sudo apt install code -y

PROCESSING "[ Installing git ]"
sudo apt install git -y

PROCESSING "[ Installing Sublime Text ]" # according to https://www.sublimetext.com/docs/3/linux_repositories.html-
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
sudo apt install -y apt-transport-https
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
sudo apt update
sudo apt install sublime-text -y

PROCESSING "[ Installing terminator ]"
sudo apt install terminator -y

PROCESSING "[ Setting terminator as the default terminal emulator ]"
sed -i s/Exec=gnome-terminal/Exec=terminator/g /usr/share/applications/gnome-terminal.desktop

PROCESSING "[ Forcing color prompt in ~/.bashrc ]"
echo "export PS1='${debian_chroot:+($debian_chroot)}\[\033[38;5;11m\]\u\[$(tput sgr0)\]@\h:\[$(tput sgr0)\]\[\033[38;5;6m\][\w]\[$(tput sgr0)\]: \[$(tput sgr0)\]'" >>~/.bashrc

PROCESSING "[ Installing SimpleScreenRecorder ]"
echo "" | sudo add-apt-repository ppa:maarten-baert/simplescreenrecorder
sudo apt update
sudo apt install simplescreenrecorder -y

PROCESSING "[ Installing task ]"
sudo apt install taskwarrior -y

PROCESSING "[ Installing pip3 ]"
sudo apt install python-pip3 -y

PROCESSING "[ Removing boilerplate home directories ]"
rmdir ~/Desktop ~/Documents ~/Downloads ~/Music ~/Pictures ~/Public ~/Templates ~/Videos

PROCESSING "[ Installing guake ]"
sudo apt install guake -y

PROCESSING "[ Installing openvpn ]"
sudo apt install openvpn -y

PROCESSING "[ Installing nmap ]"
sudo apt install nmap -y

PROCESSING "[ Installing docker ]"
sudo apt install -y docker.io
sudo groupadd docker
sudo usermod -aG docker "$(logname)"

PROCESSING "[ Installing curl ]"
sudo apt install curl -y

PROCESSING "[ Installing pinta ]"
sudo apt install pinta -y

PROCESSING "[ Installing exiftool ]"
sudo apt install exiftool -y

PROCESSING "[ Installing Python PIL ]"
sudo apt install python-pil -y

PROCESSING "[ Installing sqlitebrowser ]"
sudo apt install sqlitebrowser -y

PROCESSING "[ Installing Wireshark ]"
sudo apt install wireshark -y

PROCESSING "[ Installing pefile ]"
pip3 install pefile

PROCESSING "[ Downloading volatility3 ]"
git clone https://github.com/volatilityfoundation/volatility3.git

PROCESSING "[ Installing volatility ]"
sudo snap install volatility-phocean

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

PROCESSING "[ Installing Atom ]"
wget -qO - https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" > /etc/apt/sources.list.d/atom.list'
sudo apt update
sudo apt install atom -y

PROCESSING "[ Installing python-requests ]"
pip3 install requests

PROCESSING "[ Installing idle ]"
sudo apt install -y idle

PROCESSING "[ Installing xclip ]"
sudo apt install -y xclip
grep "alias xclip" ~/.bashrc
if [ $? -eq 1 ]; then
	echo "alias xclip='xclip -selection clipboard'" >>~/.bashrc
fi

PROCESSING "[ Installing Python flask ]"
sudo pip3 install flask

PROCESSING "[ Installing Python flask-login ]"
sudo pip3 install flask-login

PROCESSING "[ Installing Python colorama ]"
sudo pip3 install colorama

PROCESSING "[ Installing Python passlib ]"
sudo pip3 install passlib

PROCESSING "[ Installing Spotify ]"
sudo snap install spotify

PROCESSING "[ Installing Binwalk ]"
sudo apt install binwalk -y

PROCESSING "[ Installing Tesseract ]"
sudo apt install tesseract-ocr -y

PROCESSING "[ Installing foremost ]"
sudo apt install foremost -y

PROCESSING "[ Installing rot13 ]"
sudo apt install bsdgames -y

PROCESSING "[ Installing hexedit ]"
sudo apt install hexedit -y

PROCESSING "[ Installing Python pwntools ]"
sudo pip3 install pwntools

PROCESSING "[ Installing Go ]"
sudo apt install golang-go -y
sudo apt install gccgo-go -y
PROCESSING "Adding GOPATH and GOBIN to .bashrc, so future installs are easy.."
grep "export GOPATH" ~/.bashrc
if [ $? -eq 1 ]; then
	echo "export GOPATH=\$HOME/.go/" >>~/.bashrc
fi
grep "export GOBIN" ~/.bashrc
if [ $? -eq 1 ]; then
	echo "export GOBIN=\$HOME/.go/bin" >>~/.bashrc
	echo "export PATH=\$PATH:\$GOBIN" >>~/.bashrc
fi

PROCESSING "[ Installing gobuster ]"
go get github.com/OJ/gobuster

PROCESSING "[ Installing sqlite ]"
sudo apt install sqlite -y

PROCESSING "[ Installing nikto ]"
sudo apt install nikto -y

PROCESSING "[ Installing zbarimg ]"
sudo apt install zbar-tools -y

PROCESSING "[ Installing qrencode ]"
sudo apt install qrencode -y

PROCESSING "[ Installing pdfcrack ]"
sudo apt install pdfcrack -y

PROCESSING "[ Installing Virtualbox ]"
sudo apt install virtualbox-qt -y

PROCESSING "[ Installing Vagrant ]"
sudo apt install vagrant -y

# PROCESSING "[ Installing Hopper ]"
# wget "https://d2ap6ypl1xbe4k.cloudfront.net/Hopper-v4-4.5.28-Linux.deb"
# dpkg -i Hopper-v4-4.5.28-Linux.deb
# rm Hopper-v4-4.5.28-Linux.deb

PROCESSING "[ Installing Oracle Java 8 ]"
echo "" | sudo add-apt-repository ppa:webupd8team/java
sudo apt update
sudo apt install oracle-java8-installer -y

PROCESSING "Downloading stegsolve.jar ]"
wget "http://www.caesum.com/handbook/Stegsolve.jar" -O "stegsolve.jar"
chmod +x "stegsolve.jar"

PROCESSING "[ Installing fcrackzip ]"
sudo apt install fcrackzip -y

PROCESSING "[ Installing unrar ]"
sudo apt install unrar -y

PROCESSING "[ Installing 7zip ]"
sudo apt install p7zip -y

PROCESSING "[ Installing steghide ]"
sudo apt install steghide -y

PROCESSING "[ Installing hashcat ]"
wget https://hashcat.net/files/hashcat-5.1.0.7z
p7zip -d hashcat-5.1.0.7z
cd hashcat-5.1.0 || exit
cp hashcat64.bin /usr/bin/
ln -s /usr/bin/hashcat64.bin /usr/bin/hashcat

PROCESSING "[ Installing ffmpeg ]"
sudo apt install ffmpeg -y

PROCESSING "[ Installing Python library netifaces ]"
sudo pip3 install netifaces

PROCESSING "[ Installing Python library iptools ]"
sudo pip3 install iptools

PROCESSING "[ Installing Python library OpenSSL ]"
sudo pip3 install pyopenssl

PROCESSING "[ Installing Python library pydispatch ]"
sudo pip3 install pydispatch

PROCESSING "[ Installing GIMP ]"
sudo apt install gimp -y

PROCESSING "[ Installing cmake ]"
sudo apt install cmake -y

PROCESSING "[ Installing mplayer ]"
sudo apt install mplayer -y

PROCESSING "[ Installing sshpass ]"
sudo apt install sshpass -y

PROCESSING "[ Installing tcpflow ]"
sudo apt install tcpflow -y

PROCESSING "[ Installing Python scapy ]"
sudo pip3 install scapy

PROCESSING "[ Installing the thing that 7z2john.pl needs ]"
sudo apt install libcompress-raw-lzma-perl

PROCESSING "[ Installing dos2unix ]"
sudo apt install libcompress-raw-lzma-perl

PROCESSING "[ Updating Prompt ]"
alias brc='source ~/.bashrc'
brc
