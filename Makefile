setup: dotfiles-setup macos-setup tooling-setup brew-setup

dotfiles-setup:
	rm ~/.gitconfig
	ln -s $(PWD)/git/gitconfig ~/.gitconfig

	rm ~/.aliases
	ln -s $(PWD)/shell/aliases.sh ~/.aliases

	rm ~/.zshrc
	ln -s $(PWD)/shell/zshrc.sh ~/.zshrc

macos-setup:
	# Set computer name (as done via System Preferences → Sharing)
	sudo scutil --set ComputerName "dragonland"
	sudo scutil --set LocalHostName "dragonland"
	sudo scutil --set HostName "dragonland"
	sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "dragonland"

	sh $(PWD)/system/setup-locale.sh
	sh $(PWD)/system/setup-macos.sh

tooling-setup:
	curl --proto '=https' --tlsv1.2 -fsS https://sh.rustup.rs | sh
	curl --proto '=https' --tlsv1.2 -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | sh

brew-setup:
	brew bundle --file=$(PWD)/system/Brewfile



update: software-update brew-update npm-update

software-update:
	# Update App Store apps
	sudo softwareupdate -i -a

brew-update:
	# Update Homebrew (Cask) & packages
	brew update
	brew upgrade

npm-update:
	# Update npm & packages
	npm install npm -g
	npm update -g



backup: brew-backup

brew-backup:
	brew bundle dump --file=$(PWD)/system/Brewfile --describe --force
