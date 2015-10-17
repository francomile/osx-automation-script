#!/bin/sh

# This script will setup a new Mac OS X installation at my needs.
# Read it carefully before running it, and change it to suit your needs.
# Many of this configs where taken from different places in the web, namely:
# https://gist.github.com/brandonb927/3195465, https://github.com/mathiasbynens/dotfiles/blob/master/.osx


# Set the pretty colours for use:
black='\033[0;30m'
white='\033[0;37m'
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
magenta='\033[0;35m'
cyan='\033[0;36m'

# Resets the style
reset=`tput sgr0`

# Color-echo. Improved. [ by @joaocunha]
# arg $1 = message
# arg $2 = Color
cecho() {
  echo "${2}${1}${reset}"
  return
}


# Start the script:
cecho "----------------------------------------------------------" $cyan
cecho "==============>  STARTING SETUP SCRIPT  <=================" $cyan
cecho "----------------------------------------------------------" $cyan
echo ""

# Ask for the administrator password upfront and run a keep-alive to update existing `sudo` time stamp until script has finished:
cd ~
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &


#=================================================
# INSTALL HOMEBREW PACKAGE MANAGER AND BINARIES:
#=================================================

# Check for Homebrew,
# Install if we don't have it:
echo ""
cecho "Installing homebrew package manager and binaries..." $green
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Update homebrew recipes:
brew update

# Install GNU core utilities (those that come with OS X are outdated):
brew install coreutils

# Install GNU `find`, `locate`, `updatedb`, and `xargs`, g-prefixed:
brew install findutils

# Install Bash 4:
brew install bash

# Install more recent versions of some OS X tools:
brew tap homebrew/dupes
brew install homebrew/dupes/grep

# Update your path in ~/.bash_profile:

echo "$PATH=$(brew --prefix coreutils)/libexec/gnubin:$PATH" >> ~/.bash_profile
source ~/.bash_profile

# Install more binaries:
binaries=(
  openssl
  nmap
  htop
  watch
  zsh
  zsh-completions
  tmux
  md5sha1sum
  wget
  iperf
  python3
  tree
  ack
  git
)

echo ""
cecho "Installing more binaries..." $green
brew install ${binaries[@]}

# Cleanup:
echo ""
cecho "Performing brew cleanup..." $green
brew cleanup



#============================================
# INSTALL APPLICATIONS WITH HOMEBREW CASK:
#============================================

echo ""
cecho "Installing Homebrew cask and Applications..." $green
brew install caskroom/cask/brew-cask
# For beta versins like Sublime Text 3:
brew tap caskroom/versions

apps=(
  adium
  alfred
  android-file-transfer
  appcleaner
  atom
  boom
  caffeine
  cheatsheet
  chicken
  clipmenu
  colors
  diskmaker-x
  dropbox
  flux
  filezilla
  firefox
  github-desktop
  handbrake
  imageoptim
  limechat
  istumbler
  iTerm
  mac-linux-usb-loader
  malwarebytes-anti-malware
  max
  netspot
  nosleep
  onyx
  paparazzi
  qlmarkdown
  sequel-pro
  sizeup
  skype
  sourcetree
  spectacle
  sublime-text3
  teamviewer
  the-unarchiver
  torbrowser
  tunnelblick
  vagrant
  vagrant-manager
  vlc
  virtualbox
  istumbler
  utorrent
  xquartz
  wireshark
)

# Install apps to /Applications
# Default is: /Users/$user/Applications
brew cask install --appdir="/Applications" ${apps[@]}

# Add the correct path to Alfred in order to beeing able to launch apps from it:
brew cask alfred link

# Install Mackup:
echo ""
cehco "Installing Mackup for backup and restore of applications settings..." $green
brew install mackup
# After setting up Dropbox, run 'mackup backup' if it's the forst time using it or
# 'mackup restore' if your restoring a Mackup backup from Dropbox.



#============================================
# SYMLINKING SOME GOODIES BUILT IN  MAC OS X:
#============================================

echo ""
cecho "Creating symlinks from usefull built in tools to /Applications folder..." $green
# Make a symlink to /usr/sbin/ of the 'airport' utility for scanning your local wireless environment:
ln -s /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport /usr/sbin/airport

# Symlink Mac OS X Utils to /Applications folder:
ln -s /System/Library/CoreServices/Applications/Network\ Utility.app /Applications/
ln -s /System/Library/CoreServices/Applications/Screen\ Sharing.app /Applications/
ln -s /System/Library/CoreServices/Applications/Wireless\ Diagnostics.app /Applications/
ln -s /System/Library/CoreServices/Applications/Directory\ Utility.app /Applications/



#============================================
# CONFIGURATIONS AND PREFERENCES:
#============================================

# Set Google DNS servers:
echo ""
cecho "Setting Google DNS servers..." $green
networksetup -setdnsservers Wi-Fi 8.8.8.8 8.8.4.4
networksetup -setdnsservers Ethernet 8.8.8.8 8.8.4.4

# Choose your computer name: (hostname)
echo ""
cecho "Would you like to set your computer name (as done via System Preferences >> Sharing)?  (y/n)" $green
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  cecho "What would you like it to be?" $green
  read HOSTNAME
  sudo scutil --set ComputerName $HOSTNAME
  sudo scutil --set HostName $HOSTNAME
  sudo scutil --set LocalHostName $HOSTNAME
  sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $HOSTNAME
fi

# General UI/UX:
echo ""
cecho "Automatically quit printer app once the print jobs complete" $green
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

echo ""
cecho "Check for software updates daily, not just once per week" $green
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

echo ""
cecho "Disable smart quotes and smart dashes" $green
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# General Power and Performance modifications
echo ""
cecho "Disable hibernation? (speeds up entering sleep mode)" $green
sudo pmset -a hibernatemode 0

echo ""
cecho "Disable the sound effects on boot" $green
sudo nvram SystemAudioVolume=" "


# Trackpad, mouse, keyboard, Bluetooth accessories, and input:
echo ""
cecho "Increasing sound quality for Bluetooth headphones/headsets" $green
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

echo ""
cecho "Enabling full keyboard access for all controls (enable Tab in modal dialogs, menu windows, etc.)" $green
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

echo ""
cecho "Setting a blazingly fast keyboard repeat rate" $green
defaults write -g ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain KeyRepeat -int 0.02
defaults write NSGlobalDomain InitialKeyRepeat -int 12

echo ""
cecho "Setting trackpad & mouse speed to a reasonable number" $green
defaults write -g com.apple.trackpad.scaling 2
defaults write -g com.apple.mouse.scaling 2.5

echo ""
cecho "Turn off keyboard illumination when computer is not used for 5 minutes" $green
defaults write com.apple.BezelServices kDimTime -int 300

echo ""
cecho "Disable display from automatically adjusting brightness" $green
sudo defaults write /Library/Preferences/com.apple.iokit.AmbientLightSensor "Automatic Display Enabled" -bool false

echo ""
cecho "Disable keyboard from automatically adjusting backlight brightness in low light" $green
sudo defaults write /Library/Preferences/com.apple.iokit.AmbientLightSensor "Automatic Keyboard Enabled" -bool false


# screen settings:
echo ""
cecho "Requiring password immediately after sleep or screen saver begins" $green
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

echo ""
screenshot_location="${HOME}/Downloads"
cecho "Setting location to ${screenshot_location}" $green
defaults write com.apple.screencapture location -string "${screenshot_location}"

echo ""
cecho "Enabling subpixel font rendering on non-Apple LCDs" $green
defaults write NSGlobalDomain AppleFontSmoothing -int 2

echo ""
cecho "Enabling HiDPI display modes (requires restart)" $green
sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true


# Finder:
echo ""
cecho "Show icons for hard drives, servers, and removable media on the desktop" $green
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true

echo ""
cecho "Show all filename extensions in Finder by default" $green
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

echo ""
cecho "Show status bar in Finder by default" $green
defaults write com.apple.finder ShowStatusBar -bool true

echo ""
cecho "Display full POSIX path as Finder window title" $green
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

echo ""
cecho "Disable the warning when changing a file extension" $green
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

echo ""
cecho "Avoid creation of .DS_Store files on network volumes" $green
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

echo ""
cecho "Allowing text selection in Quick Look/Preview in Finder by default" $green
defaults write com.apple.finder QLEnableTextSelection -bool true

echo ""
cecho "Enable snap-to-grid for icons on the desktop and in other icon views" $green
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

echo ""
cecho "Increase Window resize speed for Cocoa apps" $green
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

echo ""
cecho "Show hidden ~/Library folder" $green
chflags nohidden ~/Library

echo ""
cecho "Allow quitting Finder via ⌘ + Q; doing so will also hide desktop icons." $green
defaults write com.apple.finder QuitMenuItem -bool true


# Dock, Mission Control, Dashboard:
echo ""
cecho "Setting the icon size of Dock items to 36 pixels for optimal size/screen-realestate" $green
defaults write com.apple.dock tilesize -int 36

echo ""
cecho "Speed up Mission Control animations and grouping windows by application" $green
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.dock "expose-group-by-app" -bool true

echo ""
cecho "Set Dock to auto-hide and remove the auto-hiding delay" $green
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0

echo ""
cecho "Disable Dashboard" $green
defaults write com.apple.dashboard mcx-disabled -bool true


# Terminal
echo ""
cecho "Enabling UTF-8 ONLY in Terminal.app and setting the Ocean theme by default" $green
defaults write com.apple.terminal StringEncodings -array 4
defaults write com.apple.Terminal "Default Window Settings" -string "Ocean"
defaults write com.apple.Terminal "Startup Window Settings" -string "Ocean"

echo ""
cecho "Don’t display the annoying prompt when quitting iTerm" $green
defaults write com.googlecode.iterm2 PromptOnQuit -bool false


#Time Machine
echo ""
cecho "Prevent Time Machine from prompting to use new hard drives as backup volume" $green
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

echo ""
cecho "Disable local Time Machine backups? (This can take up a ton of SSD space on <128GB SSDs)" $green
hash tmutil &> /dev/null && sudo tmutil disablelocal

# Messages:
echo ""
cecho "Disable smart quotes in Messages.app (it's annoying for messages that contain code)" $green
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false


echo ""
cecho "Done!" $green
echo ""
echo ""
cecho "-----------------------------------------------------------------------" $cyan
cecho "--------------------------  END OF SCRIPT!  ---------------------------" $cyan
cecho "-----------------------------------------------------------------------" $cyan
echo ""
echo ""
cecho "Note that some of these changes require a logout/restart to take effect." $red
cecho "Killing some open applications in order to take effect." $green
echo ""

find ~/Library/Application\ Support/Dock -name "*.db" -maxdepth 1 -delete
for app in "Activity Monitor" "Address Book" "Calendar" "Contacts" "cfprefsd" \
  "Dock" "Finder"  "Messages" "SystemUIServer" \
  "Terminal" ; do
  killall "${app}" > /dev/null 2>&1
done
