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

echo "installing gentoo"
  emerge-webrsync
  getuto
  emerge -vg app-portage/mirrorselect app-portage/cpuid2cpuflags sys-boot/grub efibootmgr
  mirrorselect -i -o >> /etc/portage/make.conf
  emerge --sync
  end=0

  echo

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
    echo -e "binary? good luck))\n"
  fi
  done

  read -n 1 -s -r -p "Press any key to CHAGE THE @WORLD"
  emerge $flags --update --deep --newuse @world
  echo "UTC" > /etc/timezone
  echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
  locale-gen
  eselect locale set 2 
  touch /etc/portage/package.use/installkernel
  echo 'sys-kernel/installkernel dracut' >> /etc/portage/package.use/installkernel
  emerge -avg sys-kernel/gentoo-kernel-bin
  read -r -p "hostname: " hostname
  echo $hostname >> /etc/hostname
  emerge -av net-misc/dhcpcd
  rc-update add dhcpcd default
  echo "enter root password"
  passwd 
  grub-install --target=x86_64-efi --efi-directory=/efi 
  grub-mkconfig -o /boot/grub/grub.cfg
  exit

