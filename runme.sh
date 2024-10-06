#!/bin/bash 
#functions

function arch 
{
su -c 'pacman -S --noconfirm wget'
}

function gentoo
{
su -c 'emerge -vg wget sys-fs/genfstab vim'
}

# Colors
red='\e[0;31m'
white='\e[0;97m'

#WARNING
echo -e "${red}warning: DO NOT USE THIS SCRIPT ON A INSTALLED OS${white}"

# Pkg manager check
echo "checking package manager..."

#Installing wget and git
which pacman &>/dev/null 
if [ $? -eq 0 ]
then
arch
else
  which emerge &>/dev/null 
  if [ $? -eq 0 ]
  then
    gentoo
  else
    echo -e "${red}warning: Support only gentoo-livecd and archlinux-livecd"
    echo -e "${white}attention: if you want to continue, install git, cfdisk, archinstall-scripts(arch-chroot, genfstab) and wget to your OS and type YES"
    read -r -p "type: " yes 
    if [[ "$yes" != 'YES' ]]
    then
      echo 'exiting'
      exit
    fi
  fi
fi

#root
echo "checking user id..."
if [ "$EUID" -ne 0 ]
then
  echo "starting install..."
  su -c 'sh ./setup.sh'
  exit
fi
echo "wow you run this as root"
echo "starting install..."
sh ./setup.sh

