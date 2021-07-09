#!/bin/bash

ROOT_UID=0
THEME_DIR="/boot/grub/themes"
THEME_NAME=hex-arch

echo "=========================================================================="
echo "                       ${THEME_NAME}"
echo "=========================================================================="

function has_command() {
  command -v $1 > /dev/null
}

echo -e "\nChecking for root access...\n"

# check root access
if [ "$UID" -eq "$ROOT_UID" ]; then

  if [ ! -d "/boot/grub/themes/" ] then
   echo "Creating themes directory"
   mkdir /boot/grub/themes/
  fi 
  if [ -d "/boot/grub/themes/$THEME_NAME" ] then
   echo "Deleting previously installed theme files of the ${THEME_NAME} theme"
   rm -r /boot/grub/themes/${THEME_NAME}
  fi 
  
  echo "Copying theme files"
  cp -r ${THEME_NAME} /boot/grub/themes/
  
  echo "Setting the default theme"
  grep "GRUB_THEME=" /etc/default/grub 2>&1 >/dev/null && sed -i '/GRUB_THEME=/d' /etc/default/grub
  echo "GRUB_THEME=\"/boot/grub/themes/${THEME_NAME}/theme.txt\"" >> /etc/default/grub

  echo "Updating GRUB"
  if has_command update-grub; then
    update-grub
  elif has_command grub-mkconfig; then
    grub-mkconfig -o /boot/grub/grub.cfg
  elif has_command grub2-mkconfig; then
    if has_command zypper; then
      grub2-mkconfig -o /boot/grub2/grub.cfg
    elif has_command dnf; then
      grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
    fi
  fi
  echo "Theme installed successfully"

else
  echo "Please run me as root"
fi
