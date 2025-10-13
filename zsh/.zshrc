# --------------------------- #
#          HISTORY
# --------------------------- #
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# --------------------------- #
#            FZF
# --------------------------- #
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='fd --hidden --no-ignore --exclude .git --exclude node_modules --exclude .cache --follow'
export FZF_DEFAULT_OPTS="--layout=reverse --inline-info \
   --color=fg+:magenta,gutter:-1,pointer:magenta,marker:magenta,preview-bg:#171c23,hl:yellow,hl+:yellow,info:green,prompt:green \
   --multi --preview-window noborder"
export HIGHLIGHT_STYLE=base16

# Use FZF opts in fzf-tab
zstyle ':fzf-tab:*' use-fzf-default-opts yes
# Use tab to select multiple items like in fzf inside fzf-tab
# C-Space collides with tmux, so we ignore it.
zstyle ':fzf-tab:*' fzf-bindings 'tab:toggle+down,ctrl-space:ignore'

# --------------------------- #
#           ZINIT
# --------------------------- #

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download init, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit load Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit
zinit cdreplay -q


# --------------------------- #
#        COMPLETIONS
# --------------------------- #
# allow case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
# Show tree preview for cd completion (max 3 levels deep)
# zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --level=3 --color=always $realpath 2>/dev/null || eza --color=always $realpath'


# --------------------------- #
#          VIM MODE
# --------------------------- #
zinit ice depth=1; zinit light jeffreytse/zsh-vi-mode

# https://github.com/jeffreytse/zsh-vi-mode?tab=readme-ov-file#system-clipboard
ZVM_SYSTEM_CLIPBOARD_ENABLED=true
# https://github.com/jeffreytse/zsh-vi-mode?tab=readme-ov-file#highlight-behavior
ZVM_VI_HIGHLIGHT_BACKGROUND=green
ZVM_VI_HIGHLIGHT_FOREGROUND=black
# https://github.com/jeffreytse/zsh-vi-mode?tab=readme-ov-file#command-line-initial-mode
ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
# https://github.com/jeffreytse/zsh-vi-mode?tab=readme-ov-file#vim-edition
# Open cmd in nvim when typiing 'vv'
ZVM_VI_EDITOR="nvim"
# https://github.com/jeffreytse/zsh-vi-mode?tab=readme-ov-file#surround
# - S" : Add " for visual selection
# - ys" : Add " for visual selection
# - cs"' : Change " to '
# - ds" : Delete "
ZVM_VI_SURROUND_BINDKEY="classic" # I failed to make 's-prefix' work
ZVM_KEYTIMEOUT=1

# --------------------------- #
#           PROMPT
# --------------------------- #
setopt PROMPT_SUBST

# Initial prompt is the same as insert mode, because that's the default mode
PS1=$'\n%B%F{234}%K{green} %~ %K{234}%F{green}%b%k%f%b'
PS1+=$'\n%F{green} %f%b'

# Update prompt color based on vi-mode
# https://github.com/jeffreytse/zsh-vi-mode?tab=readme-ov-file#vi-mode-indicator
function zvm_after_select_vi_mode() {
  case $ZVM_MODE in
    $ZVM_MODE_NORMAL)
      PS1=$'\n%B%F{234}%K{red} %~ %K{234}%F{red}%b%k%f%b'
      PS1+=$'\n%F{green} %f%b'
    ;;
    $ZVM_MODE_INSERT)
      PS1=$'\n%B%F{234}%K{green} %~ %K{234}%F{green}%b%k%f%b'
      PS1+=$'\n%F{green} %f%b'
    ;;
    $ZVM_MODE_VISUAL)
      PS1=$'\n%B%F{234}%K{magenta} %~ %K{234}%F{magenta}%b%k%f%b'
      PS1+=$'\n%F{green} %f%b'
    ;;
    $ZVM_MODE_VISUAL_LINE)
      PS1=$'\n%B%F{234}%K{magenta} %~ %K{234}%F{magenta}%b%k%f%b'
      PS1+=$'\n%F{green} %f%b'
    ;;
    $ZVM_MODE_REPLACE)
      PS1=$'\n%B%F{234}%K{cyan} %~ %K{234}%F{cyan}%b%k%f%b'
      PS1+=$'\n%F{green} %f%b'
    ;;
  esac
}


# --------------------------- #
#           BREW
# --------------------------- #
export HOMEBREW_NO_ENV_HINTS=1
HOMEBREW_DIR=""
# check if dir exists
if [ -d "/opt/homebrew" ]; then
  HOMEBREW_DIR="/opt/homebrew"

  eval "$(/opt/homebrew/bin/brew shellenv)"

elif [ -f "/usr/local/bin/brew" ]; then
  HOMEBREW_DIR="/usr/local/bin"

  eval "$(/usr/local/bin/brew shellenv)"

else
  echo "Homebrew not found"
fi
export HOMEBREW_DIR


# --------------------------- #
#          ENV VARS
# --------------------------- #
# Main apps
export EDITOR=nvim
export TERMINAL=ghostty
export BROWSER="Google Chrome"

# Go
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin

# Bun
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"

# Directories
export CODE_DIR="$HOME/coding"
export DOTS_DIR="$HOME/dots"
export CONFIG_DIR="$HOME/.config"
export XDG_CONFIG_HOME="$CONFIG_DIR"

# Add bin paths to PATH
export PATH="$HOMEBREW_DIR/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$GOPATH:$GOBIN:$PATH" # Go
export PATH="$HOME/.cargo/bin:$PATH" # Rust
export PATH="$BUN_INSTALL/bin:$PATH" # Bun
export PATH="$HOME/.opencode/bin:$PATH" # OpenCode
export PATH="$HOME/.local/share/bob/nvim-bin:$PATH" # bob (neovim)
export PATH="$CODE_DIR:$PATH"


# --------------------------- #
#          ALIASES
# --------------------------- #
[[ -f "$DOTS_DIR/zsh/.aliases" ]] && source "$DOTS_DIR/zsh/.aliases"


# --------------------------- #
#         FUNCTIONS
# --------------------------- #
[[ -f "$DOTS_DIR/zsh/.functions.sh" ]] && source "$DOTS_DIR/zsh/.functions.sh"


# --------------------------- #
#         ADDITIONAL
# --------------------------- #
# Source Profile (specific env variables, functions and aliases)
[ -s "$HOME/.profile" ] && source "$HOME/.profile"
