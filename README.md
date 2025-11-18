# dots

## Install Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
````

## Add Homebrew to PATH
```bash
eval "$(/usr/local/bin/brew shellenv)"
```

## Install VS Code
```bash
# I use nvim, I promise!
brew install --cask visual-studio-code
```

## Install shell

## Install FZF and other cmd packages
```bash
brew install fzf eza rg highlight fd cmatrix jq yq bat
/opt/homebrew/opt/fzf/install
```

## Install ZSH config
```bash
rm -Rf $HOME/.zshrc
ln -s $HOME/dots/zsh/.zshrc $HOME/
```

## Install Yazi
```bash
brew install yazi ffmpeg sevenzip jq poppler fd ripgrep fzf zoxide resvg imagemagick font-symbols-only-nerd-font ghostscript
rm -Rf $HOME/.config/yazi
ln -s $HOME/dots/yazi $HOME/.config/
```

## Install tmux
```bash
brew install tmux
# brew install tpm # Not needed for now
rm -Rf $HOME/.tmux.conf
ln -s $HOME/dots/tmux/.tmux.conf $HOME/.tmux.conf
```

## Install Nerdfonts
```bash
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono-nerd-font
```

## Install terminal
```bash
brew install --cask ghostty
rm -Rf $HOME/.config/ghostty
ln -s $HOME/dots/ghostty $HOME/.config/
```

## Install LazyGit
```bash
brew install jesseduffield/lazygit/lazygit
rm -Rf $HOME/.config/lazygit/config.yml
ln -s $HOME/dots/lazygit $HOME/.config/
```

## Install Git Dash
```bash
brew install gh
gh auth login
gh extension install dlvhdr/gh-dash
```

## Install Neovim (btw)
```bash
brew install neovim
rm -Rf $HOME/.config/nvim
ln -s $HOME/dots/nvim $HOME/.config/
./scripts/install-language-servers.sh
```

## Install opencode
```bash
curl -fsSL https://opencode.ai/install | bash
rm -Rf ~/.config/opencode
ln -s ~/dots/opencode ~/.config/opencode

# MCPs
git clone git@github.com:microsoft/markitdown.git
cd markitdown
brew install uv
uv venv --python=3.12 .venv
source .venv/bin/activate
uv pip install -e 'packages/markitdown[all]'
cd ..
rm -Rf markitdown
```

## Install Docker
```bash
brew install --cask docker
open /Applications/Docker.app
brew install jesseduffield/lazydocker/lazydocker
```

## Create coding folder
```bash
mkdir $HOME/coding
```

## Install Protobuf
```bash
brew install protobuf
brew install grpcurl
```

## Install Postgres
```bash
brew install postgresql@17
# brew services start postgresql@14
```

## Install AWS CLI
```bash
brew install awscli
# aws configure sso
# - Every day you need to run aws sso login --profile <profile_name> to get a new token
```
