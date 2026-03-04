DOTFILES := $(shell cd "$(dir $(lastword $(MAKEFILE_LIST)))" && pwd)
UNAME := $(shell uname)

.PHONY: install help

help: ## Show this help
	@grep -E '^[a-z][a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "After install, use 'dot help' for day-to-day management."

install: ## Bootstrap dotfiles on a fresh machine
	@echo "Bootstrapping dotfiles from $(DOTFILES) ..."
	@# Create required directories
	@mkdir -p $(HOME)/.cache $(HOME)/.local/share $(HOME)/.local/state $(HOME)/.local/bin
	@mkdir -p $(HOME)/dotfiles.local/zsh/functions $(HOME)/dotfiles.local/config/git $(HOME)/dotfiles.local/config/fd
	@mkdir -p $(HOME)/.config/ghostty $(HOME)/.config/bat $(HOME)/.config/fd $(HOME)/.config/git $(HOME)/.config/tmux $(HOME)/.config/npm
	@# Shell symlinks
	@ln -sfn $(DOTFILES)/zsh/env.zsh     $(HOME)/.zshenv
	@ln -sfn $(DOTFILES)/zsh/rc.zsh      $(HOME)/.zshrc
	@ln -sfn $(DOTFILES)/zsh/profile.zsh $(HOME)/.zprofile
	@ln -sfn $(DOTFILES)/zsh/login.zsh   $(HOME)/.zlogin
	@# Git
	@ln -sfn $(DOTFILES)/config/git/config $(HOME)/.config/git/config
	@# App configs
	@ln -sfn $(DOTFILES)/config/starship/starship.toml $(HOME)/.config/starship.toml
	@ln -sfn $(DOTFILES)/config/ghostty/config         $(HOME)/.config/ghostty/config
	@ln -sfn $(DOTFILES)/config/bat/config             $(HOME)/.config/bat/config
	@ln -sfn $(DOTFILES)/config/tmux/tmux.conf         $(HOME)/.config/tmux/tmux.conf
	@cat $(DOTFILES)/config/fd/ignore > $(HOME)/.config/fd/ignore
	@cp $(HOME)/.config/fd/ignore $(HOME)/.rgignore
	@# Brew
ifeq ($(UNAME),Darwin)
	@brew bundle --file=$(DOTFILES)/Brewfile
endif
	@echo ""
	@echo "✓ Done. Run 'dot help' for day-to-day management."
	@echo "  Machine-local overrides go in ~/dotfiles.local/"
