function cls 
{
  clear
  one='\e[0;91m'
  two='\e[0;92m'
  three='\e[0;93m'
  four='\e[0;94m'
  five='\e[0;95m'
  red='\e[0;31m'
  white='\e[0;97m'

  echo -e "${one}  _____           _              ____            _              "
  echo -e "${two} |_   _|   _ _ __| |__   ___    / ___| ___ _ __ | |_ ___   ___  "
  echo -e "${three}   | || | | | '__| '_ \ / _ \  | |  _ / _ \ '_ \| __/ _ \ / _ \ "
  echo -e "${four}   | || |_| | |  | |_) | (_) | | |_| |  __/ | | | || (_) | (_) |"
  echo -e "${five}   |_| \__,_|_|  |_.__/ \___/   \____|\___|_| |_|\__\___/ \___/ "
  echo -e "${white}"
}

echo "installing gentoo"
  emerge-webrsync &> /dev/null
  getuto &> /dev/null
  emerge -g app-portage/mirrorselect app-portage/cpuid2cpuflags sys-boot/grub efibootmgr &>/dev/null
  mirrorselect -i -o >> /etc/portage/make.conf 
  end=0

  echo
cls
  while [ $end -ne "1" ]
  do
  echo "select profile"
  echo " 1.list profiles"
  echo " 2.select"
  read -r -p "choice: " choice

  if [ "$choice" == "1" ]
  then
    eselect profile list
  fi

  if [ "$choice" == "2" ]
  then
    end=1
    read -r -p "profile: " profile
    read -r -p "use profile $profile(y/n)" yes
    if [ $yes -ne "y" ]
    then
      end=0
    fi
  fi
  done
  end=0
cls
  echo

  echo "updating @world"
  echo " 1.binary"
  echo " 2.nonbinary"
  while [ $end -ne "1" ]
  do
  read -r -p "choice:" choice

  if [ "$choice" == "1" ]
  then
    flags=-g
    end=1
  fi

  if [ "$choice" == "2" ]
  then
    flags=''
    end=1
    echo -e "nonbinary? good luck))\n"
  fi
  done
cls
  read -n 1 -s -r -p "Press any key to CHAGE THE @WORLD"
  echo
  echo "@world update is slow(wait ~20 min)"
  emerge $flags --update --deep --newuse @world &> /dev/null
  echo "UTC" > /etc/timezone
  echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
  locale-gen 
  eselect locale set 2 
  touch /etc/portage/package.use/installkernel
  echo 'installing kernel...'
  echo 'sys-kernel/installkernel dracut' >> /etc/portage/package.use/installkernel
  emerge -vg sys-kernel/gentoo-kernel-bin &> /dev/null
  cls
  read -r -p "hostname: " hostname 
  echo $hostname >> /etc/hostname
  emerge -v net-misc/dhcpcd &> /dev/null
  rc-update add dhcpcd default &> /dev/null
  cls
  echo "enter root password"
  passwd
  cls
  echo "add new user (y/N)"
  read -r -p "choice: " yes
  if [ $yes == "y" ]
  then
    read -r -p "username:" user 
    useradd -m -G wheel,audio,video $user 
    passwd $user 
  fi
  cls
  grub-install --target=x86_64-efi --efi-directory=/efi 
  grub-mkconfig -o /boot/grub/grub.cfg
  reboot


