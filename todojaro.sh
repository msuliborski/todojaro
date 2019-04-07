#!/bin/bash

VERSION="beta1";
HELP="
run: sudo /.todojaro.sh
Run with sudo on user you are using daily.
More help will come soon :)";

if [[ ( $1 = -v ) || ( $1 = --version ) ]]; then  
	echo "Version $VERSION"; exit;
fi

if [[ ( $1 = -h ) || ( $1 = --help ) ]]; then 
	echo ${HELP}; exit;
fi

if [[ $UID != 0 ]]; then 
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

displayHeader() {
	printf "\033c"
	echo "--------------------------------------------------------------------------------"
	if $1; then sleep 0.5; fi
	echo "-------------------------------Welcome to TODOjaro!-----------------------------"
	if $1; then sleep 0.5; fi
	echo "--------------------------------------------------------------------------------"
	sleep 0.5;
	echo ""
}

executeCommands() {
	commands=("$@")
	for i in "${commands[@]}"
	do
	    echo "";
	    echo "Executing: $i";
	    echo "";
	    sleep 1;
	    eval $i;
	done
	echo "";
	echo "EXECUTED!";
	read -n 1 -s -r -p "Press any key to continue...";
	echo "";
}

#askUserYesOrNo "How YOU doin'?"
askUserYesOrNo (){ 
	while true; do
		read -p "$1 [y or n]: " decision
		case ${decision} in
			[Yy]* ) return 1; break;;
			[Nn]* ) return 0; break;;
		esac
	done	
}
# local result=$?    gives 1 if answear was 'yes' and 0 if 'no'

#askUserForJetBrainsInstall "name" "url-name" "zip-name" "script-name";
askUserForJetBrainsInstall (){ 
	displayHeader false;
	askUserYesOrNo "Install $1";
	if [[ $? == 1 ]]; then
		echo "Now we try to guess what is the newest version of $1";
		echo "Be patient and do not stop the script!";
		sleep 5;
		goSearch=1;
		for (( i=2019; $i >= 2018; i-- )) ; do
			for (( j=4; $j >= 0; j-- )) ; do
				for (( k=6; $k >= 0; k-- )) ; do
					if [[ $goSearch == 1 ]]; then 
					    if [[ $k == 0 ]]; then 
					        wget "https://download-cf.jetbrains.com/$2-$i.$j.tar.gz" -O "$4.tar.gz"
					    else 
					        wget "https://download-cf.jetbrains.com/$2-$i.$j.$k.tar.gz" -O "$4.tar.gz"
					    fi
						if [[ $? == 0 ]]; then goSearch=0; fi
					fi
				done
			done
		done
		declare -a commands=(
			"sudo tar -xvzf $4.tar.gz -C /opt/"
			"rm -rf $4.tar.gz"
			"sudo mv /opt/$3* /opt/$4"
			"sudo chmod -R 777 /opt/$4"
			"sudo su -c 'sh /opt/$4/bin/$4.sh' ${SUDO_USER}")
		executeCommands "${commands[@]}";
		return 1;
	else 
		return 0; fi
}
# local result=$?    gives 1 if programme is going to be installed and 0 if not


#askUserForAndroidStudioInstall
askUserForAndroidStudioInstall (){ 
	displayHeader false;
	askUserYesOrNo "Install Android Studio";
	if [[ $? == 1 ]]; then
	    wget "https://dl.google.com/dl/android/studio/ide-zips/3.3.2.0/android-studio-ide-182.5314842-linux.zip" -O "android-studio.zip"			
		declare -a commands=(
			"sudo unzip android-studio.zip -d /opt/"
			"sudo chmod -R 777 /opt/android-studio"
			"sudo su -c 'sh /opt/android-studio/bin/studio.sh' ${SUDO_USER}")
		executeCommands "${commands[@]}";
		return 1;
	else 
		return 0; fi
}
# local result=$?    gives 1 if programme is going to be installed and 0 if not

updateAndUpgrade() {
declare -a commands=(
		"pacman -Syu")
	executeCommands "${commands[@]}";
}

removeJunkFiles() { # probably wrong code :)
declare -a commands=(
		"sudo pacman -y thunderbird usb-creator* aisleriot gnome-mahjongg gnome-mines gnome-sudoku deja-dup remmina cheese shotwell simple-scan totem transmission* vim gnome-todo gnome-getting-started* gnome-startup-applications")
	executeCommands "${commands[@]}";
}


configureLidSwitch() {
	while true; do
		echo "";
		read -r -p "What to do after closing the laptop lid, nothing or suspend? [n, s, cancel]: " decision
		case ${decision} in
			[Nn]* )
				declare -a commands=(
		        "sudo sed -i -e 's/#HandleLidSwitch=suspend/HandleLidSwitch=ignore/g' /etc/systemd/logind.conf"
		        "sudo sed -i -e 's/HandleLidSwitch=suspend/HandleLidSwitch=ignore/g' /etc/systemd/logind.conf")
	            executeCommands "${commands[@]}"; 
	            break;;
			[Ss]* )
				declare -a commands=(
		        "sudo sed -i -e 's/#HandleLidSwitch=suspend/HandleLidSwitch=suspend/g' /etc/systemd/logind.conf"
		        "sudo sed -i -e 's/HandleLidSwitch=ignore/HandleLidSwitch=suspend/g' /etc/systemd/logind.conf")
	            executeCommands "${commands[@]}"; 
	            break;;
			cancel )
				break;;
		esac
	done;
}

configureDrivers() {
	declare -a commands=(
		"sudo mhwd -a pci nonfree 0300")
	executeCommands "${commands[@]}";
}

addUbuntuLikePrompt() {
	echo "" >> /home/${SUDO_USER}/.bashrc;
	echo "force_color_prompt=yes" >> /home/${SUDO_USER}/.bashrc;
	echo "color_prompt=yes" >> /home/${SUDO_USER}/.bashrc;
	echo "parse_git_branch() {" >> /home/${SUDO_USER}/.bashrc;
	echo "    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'" >> /home/${SUDO_USER}/.bashrc;
	echo "}" >> /home/${SUDO_USER}/.bashrc;
	echo "if [ \"\$color_prompt\" = yes ]; then" >> /home/${SUDO_USER}/.bashrc;
	echo "    PS1='\${debian_chroot:+(\$debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;31m\]\$(parse_git_branch)\[\033[00m\]\\$ '" >> /home/${SUDO_USER}/.bashrc;
	echo "else" >> /home/${SUDO_USER}/.bashrc;
	echo "    PS1='\${debian_chroot:+(\$debian_chroot)}\u@\h:\w\$(parse_git_branch)\\$ '" >> /home/${SUDO_USER}/.bashrc;
	echo "fi" >> /home/${SUDO_USER}/.bashrc;
	echo "unset color_prompt force_color_prompt" >> /home/${SUDO_USER}/.bashrc;
}

#################################################################################
############################### --- START HERE --- ##############################
#################################################################################

#displayHeader false;
#askUserYesOrNo "Remove junk files?";
#if [[ $? == 1 ]]; then removeJunkFiles; fi

displayHeader false;
askUserYesOrNo "Perform an update of all packages?";
if [[ $? == 1 ]]; then updateAndUpgrade; fi

displayHeader false;
askUserYesOrNo "Configure lid switch?";
if [[ $? == 1 ]]; then configureLidSwitch; fi

displayHeader false;
askUserYesOrNo "Configure drivers? ";
if [[ $? == 1 ]]; then configureDrivers; fi

displayHeader false;
askUserYesOrNo "Make prompt like in Ubuntu with git branch support?";
if [[ $? == 1 ]]; then addUbuntuLikePrompt; fi

askUserForJetBrainsInstall "IntelliJ IDEA" "idea/ideaIU" "idea-IU" "idea";
askUserForJetBrainsInstall "CLion" "cpp/CLion" "clion" "clion";
askUserForJetBrainsInstall "PyCharm" "python/pycharm-professional" "pycharm" "pycharm";
askUserForJetBrainsInstall "Rider" "rider/JetBrains.Rider" "JetBrains\ R" "rider";
askUserForAndroidStudioInstall

displayHeader false;
echo "Thanks, that's it for now :)";
sleep 1;



