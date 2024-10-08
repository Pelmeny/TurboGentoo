function yesno
{
    if [[ ! "$yes" =~ ^(yes|y)$ ]]
    then

      exit

    fi
}

function textedit
{
  echo -e " 1.nano\n 2.vim"
  read -r -p "choice:" choice
  if [ "$choice" == "1" ]
  then
    editor=nano
  fi 
  if [ "$choice" == "2" ]
  then
    editor=vim
  fi 
  echo
}

function delexit
{
  umount -R /mnt/gentoo/ 
  rm -rf /mnt/gentoo/
  rm -rf ./sh-downloads
  exit
}

function download
{
  mkdir ./sh-downloads
  curl -O https://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64-desktop-openrc/latest-stage3-amd64-desktop-openrc.txt
  mv ./latest-stage3-amd64-desktop-openrc.txt ./sh-downloads/hash.txt 
  file=$(cat ./sh-downloads/hash.txt | grep .tar)
  file=${file%.t*}
  file=${file#*rc-}
  cd /mnt/gentoo/
  curl -O https://distfiles.gentoo.org/releases/amd64/autobuilds/"$file"/stage3-amd64-openrc-"$file".tar.xz
  cd $pwd 
}

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

  echo -e "
${one}┏┓           ┳      ┓┓
${two}┃┓┏┓┏┓╋┏┓┏┓  ┃┏┓┏╋┏┓┃┃┏┓┏┓
${three}┗┛┗ ┛┗┗┗┛┗┛  ┻┛┗┛┗┗┻┗┗┗ ┛ 
${white}
"

}

function errchk
{
  if [ ! $? -eq 0 ]
  then
    echo -e "${red}================================="
    echo -e "= err: 1                        =\n= command not execute correctly ="
    echo -e "=================================${white}"
    delexit
  fi
}
function untar
{
  cd /mnt/gentoo
  tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
  cd $pwd
}

function makeconf
{
  echo -e " 1. use premaked make.conf(for gnome only)\n 2. create it yourself(recomended) "
  read -r -p "choice: " choice
  if [ "$choice" == "1" ]
  then
    cp ./make.conf /mnt/gentoo/etc/portage/
    echo
    echo "please chage this file to use on your PC"
    read -n 1 -s -r -p "Press any key to continue"
    $editor /mnt/gentoo/etc/portage/make.conf
  
  fi 
  if [ "$choice" == "2" ]
  then 
    $editor /mnt/gentoo/etc/portage/make.conf
  fi 
}

function nvmetest
{
  p=''
  read -r -p "do you install system to nvme(y/n)" yes
  if [[ "$yes" =~ ^(yes|y)$ ]]
  then 
     p=p 
  fi 
}

function install
{
  echo "copyring resolv.conf"
  cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
  echo

  clear
  echo -e "
${one}┏┓    ┏┓┏┓┏┳┓  ┓    
${two}┃┓┏┓┏┓┣ ┗┓ ┃ ┏┓┣┓   
${three}┗┛┗ ┛┗┻ ┗┛ ┻ ┗┻┗┛•••
${white}
  "
  genfstab -U /mnt/gentoo >> /mnt/gentoo/etc/fstab
  echo

  clear
  echo -e "
${one}┏┓┓        •       
${two}┃ ┣┓┏┓┏┓┏┓╋┓┏┓┏┓   
${three}┗┛┛┗┛ ┗┛┗┛┗┗┛┗┗┫•••
${four}               ┛  
${white}
  "
  cp ./tochroot.sh /mnt/gentoo/ 
  arch-chroot /mnt/gentoo sh /tochroot.sh
}
cls
echo "select texteditor"
pwd=$(pwd)
textedit
cls
nvmetest
cls
echo -e "select disk to install:"
lsblk -nd
end=0

while [ $end -ne 1 ]
do

  read -r -p "disk: " disk
  ls /dev | grep -w $disk &> /dev/null
  if [ $? -eq 0 ]
  then

    end=1
    echo
    read -r -p "disk $disk will be formated,do you want to continue(y/N)" yes
    yesno 
  fi 
done
echo 
echo -e "please create 2 partitions\n 1. type: EFI size: 500MB\n 2. type: Linux size: >80GB"
echo -e "${red}warning: If you disobey the instructions the system will not install correctly${white}"
echo 
read -n 1 -s -r -p "Press any key to run cfdisk"

cfdisk /dev/$disk
errchk
mkfs.vfat -F32 /dev/"$disk""$p"1 &> /dev/null
errchk
mkfs.ext4 /dev/"$disk""$p"2 &> /dev/null
errchk
cls
echo "mounting disks..."
mount --mkdir /dev/"$disk""$p"2 /mnt/gentoo 
errchk
mount --mkdir /dev/"$disk""$p"1 /mnt/gentoo/efi
errchk
cls
echo "downloading stage3..."
download &> /dev/null
untar &> /dev/null
makeconf
cls
install
rm -rf /mnt/gentoo/tochroot.sh 
rm -rf /mnt/gentoo/$file
