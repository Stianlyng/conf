#!/bin/bash

mkdir -p $HOME/nas
mkdir -p $HOME/nas/media
mkdir -p $HOME/nas/vault
mkdir -p $HOME/nas/public

media="192.168.1.5:/volume1/media $HOME/nas/media nfs timeo=50,bg,defaults 0 0"

usbshare1 ="192.168.1.5:/volume1/usbshare1 $HOME/nas/usbshare1 nfs timeo=50,bg,defaults 0 0"

public="192.168.1.5:/volume1/Public $HOME/nas/public nfs timeo=50,bg,defaults 0 0"

vault="192.168.1.5:/volume1/Vault $HOME/nas/vault nfs timeo=50,bg,defaults 0 0"

images="192.168.1.5:/volume1/homes/stian /home/stian/nas/images nfs timeo=50,bg,defaults 0 0"
# Append to fstab

echo "$media" | sudo tee -a /etc/fstab
echo "$usbshare1" | sudo tee -a /etc/fstab
echo "$vault" | sudo tee -a /etc/fstab
echo "$public" | sudo tee -a /etc/fstab
echo "$images" | sudo tee -a /etc/fstab
