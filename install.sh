#!/bin/bash

config_dir="$HOME/.config"

# Default apps
shell=zsh

##################################################
##						##
##		     methods			##
##						##
##################################################

ask_question() {
  local prompt="$1"
  local default_answer="Y"

  read -p "${prompt} [Y/n] " answer

  if [[ -z "$answer" ]]; then
    answer="$default_answer"
  fi

  [[ "$answer" =~ ^[Yy]$ ]]
}

# Example usage
# if ask_question "Do you want to continue?"; then
#   echo "You chose to continue."
# else
#   echo "You chose not to continue."
# fi

##################################################
##						##
##		 adding folders			##
##						##
##################################################
mkdir -p $HOME/code
mkdir -p $HOME/.local/share/

##################################################
##						##
##		     dotfiles			##
##						##
##################################################

chmod -R 755 configs
chmod -R 755 scripts
chmod -R 755 hardware

#############	    Symlinks 	      ############

# regular
ln -fs $(pwd)/configs/alacritty  $config_dir/alacritty
ln -fs $(pwd)/configs/kmonad     $config_dir/kmonad
ln -fs $(pwd)/configs/nvim       $config_dir/nvim


# Other 
ln -fs $(pwd)/wallpapers	 $HOME/.wallpapers
ln -fs $(pwd)/scripts		 $HOME/.scripts
ln -fs $(pwd)/fonts 		 $HOME/.local/share/fonts
ln -fs $(pwd)/desktopfiles 	 $HOME/.local/share/applications

# Styling (gtk etc)
ln -fs $(pwd)/configs/styling/gtk-3.0	 $HOME/.config/gtk-3.0
ln -fs $(pwd)/configs/styling/xsettingsd $HOME/.config/xsettingsd
ln -fs $(pwd)/configs/styling/gtkrc-2.0	 $HOME/.gtkrc-2.0
ln -fs $(pwd)/configs/styling/icons	 $HOME/.icons

# Shell environments
ln -fs $(pwd)/configs/zshrc	 $HOME/.zshrc
ln -fs $(pwd)/configs/bashrc	 $HOME/.bashrc
ln -fs $(pwd)/configs/profile    $HOME/.profile


##################################################
##						##
##		     Scrips			##
##						##
##################################################

packages=(

  # Essentials
  "alacritty"
  "ranger"
  "$shell"
  "base-devel"
  "openssh"
  "git"
  "fzf"
  "neovim"
  "tldr"
  "dmidecode"
  "gnupg" # encryption for secrets etc..

  # Development
  "nodejs"
  "npm"

)

#########               Graphical  	    #########

if ask_question "Do you want to install a graphical environment (Hyprland)"; then

  packages+=( 
  "firefox"
  "rofi"
  "nemo"
  "polkit-kde-agent"

  # Hyprland
  "hyprland"
  "xdg-desktop-portal-hyprland"
  "swaybg"
  "waybar"
  "dunst"
  "wl-clipboard"
  )

  ln -s $(pwd)/configs/rofi 	  $config_dir/rofi
  ln -s $(pwd)/configs/rofi 	  $config_dir/rofi
  ln -s $(pwd)/configs/hypr	 $config_dir/hypr
  ln -s $(pwd)/configs/waybar	 $config_dir/waybar
  ln -s $(pwd)/configs/cheatsheet.md $config_dir/cheatsheet.md # hypr keybinds
else
  echo "You chose not to install graphical apps."
fi

for pkg in "${packages[@]}"; do
  sudo pacman -S --needed --noconfirm $pkg || echo "Failed to install $pkg" >> logfile.txt
done

# Install yay
git clone https://aur.archlinux.org/yay.git 
cd yay
makepkg -si
cd ..
rm -rf yay


# AUR
yay -S jetbrains-toolbox usbimager

# Install kMonad
./scripts/kmonad_setup.sh

# install virtmanager
./scripts/apps/virtmanager_install.sh

###########	SHELL	###########

# Change default shell
chsh -s /bin/$shell

###########	SSH	###########

./scripts/git_setup.sh

##################################################
##						##
##		     Hardware			##
##						##
##################################################

####   Change modkey if running inside a VM   ####
#
if sudo dmidecode -s system-manufacturer | grep -iq "vmware\|virtualbox\|xen\|kvm\|qemu\|Microsoft Corporation"; then
  echo "Running in a VM"

  # Set custom modkey
  ./scripts/utils/replace_words.sh configs/sxhkd/sxhkdrc super alt
  ./scripts/utils/replace_words.sh configs/hypr/keybinds.conf SUPER alt

else
  echo "Not running in a VM"
fi

sudo pacman -Rs dmudecode

####     Choose spesific machine configs     ####

PS3="Select a file: "

files=$(ls hardware)

select file in Default $files
do
    case $file in
        "Quit")
            echo "Exiting."
            break;;
        *)
            if [[ -n $file ]]; then
                echo "You selected $file"
		./hardware/$file
                break
            else
                echo "Invalid selection"
            fi
            ;;
    esac
done

#######################################################


# refresh fonts cache. uncomment if fonts is not added correctly
#fc-cache -fv
echo 'End of script!'
