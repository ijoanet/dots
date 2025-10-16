# run ls on cd
function cd() {
	builtin cd "$@" && eza --all --icons=always --grid
}

#  Make a directory and move into it
function mcdir() {
	mkdir -p -- "$1" && cd -P -- "$1" || exit
}

# Search in AUR packages
#function faur() {
#	yay -Slq | fzf --multi --preview 'yay -Si {1}' | xargs -ro yay -S
#}

#function raur() {
#	yay -Qq | fzf --multi --preview 'yay -Qi {1}' | xargs -ro yay -Rns
#}

# Find string on files on directory
function fif() {
	if [ ! "$#" -gt 0 ]; then
		echo "Need a string to search for!"
		return 1
	fi
	rg --files-with-matches --no-messages "$1" | fzf --preview "highlight -O ansi -l {} 2> /dev/null | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' || rg --ignore-case --pretty --context 10 '$1' {}"
}

# Find and Replace
#   $1 -> string to find
#   $2 -> substitution
function replace() {
	grep -rl "$1" * | xargs -i@ sed -i "s|$1|$2|g" @
}

# Check Go script coverage
function gocover() {
	t="/tmp/go-cover.$$.tmp"
	go test $COVERAGE_ARGS -coverprofile="$t" ./... && go tool cover -html="$t" && unlink "$t"
}

# Craetes an executable bash script
#  $1 -> script name
function mksh() {
  touch "$1" && chmod +x "$1" && echo "#!/bin/bash" >>"$1" && nvim "$1"
}

# Count chars of a parameter
function countchars() {
  local str=$1
  echo ${#str}
}

# functions
function brew_upgrate() {
    # We need to use --greedy on cask upgrade becase some of them does not have the `latest` versioning tag
    brew update && brew upgrade && brew upgrade --cask --greedy && brew cleanup
}

function brew_install() {
    local inst=$(brew formulae | fzf --query="$1" -m --preview $FB_FORMULA_PREVIEW --bind $FB_FORMULA_BIND)

    if [[ $inst ]]; then
        for prog in $(echo $inst); do; brew install $prog; done;
    fi
}

function brew_uninstall() {
    local uninst=$(brew leaves | fzf --query="$1" -m --preview $FB_FORMULA_PREVIEW --bind $FB_FORMULA_BIND)

    if [[ $uninst ]]; then
        for prog in $(echo $uninst);
        do; brew uninstall $prog; done;
    fi
}

function brew_cask_install() {
    local inst=$(brew casks | fzf --query="$1" -m --preview $FB_CASK_PREVIEW --bind $FB_CASK_BIND)

    if [[ $inst ]]; then
        for prog in $(echo $inst); do; brew install --cask $prog; done;
    fi
}

function brew_cask_uninstall() {
    local inst=$(brew list --cask | fzf --query="$1" -m --preview $FB_CASK_PREVIEW --bind $FB_CASK_BIND)

    if [[ $inst ]]; then
        for prog in $(echo $inst); do; brew uninstall --cask $prog; done;
    fi
}

# TMUX functions
# tat: tmux attach
# - gets the name of the current directory and removes periods, which tmux doesn’t like.
# - if any session with the same name is open, it re-attaches to it.
# - otherwise, it checks if an .envrc file is present and starts a new tmux session using direnv exec.
# - otherwise, starts a new tmux session with that name.
function tat {
  name=$(basename `pwd` | sed -e 's/\.//g')

  if tmux ls 2>&1 | grep "$name"; then
    tmux attach -t "$name"
  elif [ -f .envrc ]; then
    direnv exec / tmux new-session -s "$name"
  else
    tmux new-session -s "$name"
  fi
}

function gotf() {
    # Ensure compatibility with macOS
    # export LC_ALL=C

    # Find all Go test files
    local files
    files=($(find . -type f -name "*_test.go"))

    # Collect test functions
    local test_list=()
    for file in "$files[@]"; do
        local tests
        tests=($(grep -Eo 'func (Test[A-Za-z0-9_]*)\(' "$file" | sed 's/func //;s/.$//'))
        for test in "$tests[@]"; do
            local dir
            dir=$(dirname "$file")
            test_list+=("$dir/:$test")
        done
    done

    # Show test list in fzf and allow selection
    local selected
    selected=$(printf "%s\n" "${test_list[@]}" | fzf --multi)

    # If a test is selected, run it
    if [[ -n "$selected" ]]; then
        local dir test
        dir=$(echo "$selected" | cut -d':' -f1)
        test=$(echo "$selected" | cut -d':' -f2)
        echo "Running test: $test in $dir"
        gotest -count=1 -v -run "^$test$" "$dir"
    fi
}

# Cheat sheet function
# Creates a markdown file in ~/.cheat/ with the name of the command passed as parameter
# If the file already exists, it opens it in the editor
# If no parameter is passed, it shows a message
# If the ~/.cheat/ directory doesn't exist, it creates it
function cheat() {
    if [ -z "$1" ]; then
        echo "Please provide a command to search for."
        return 1
    fi

    # If cheat sheet directory doesn't exist, create it
    mkdir -p "$HOME/dots/cheat"

    # If markdown file doesn't exist, create it with a header
    if [ ! -f "$HOME/dots/cheat/$1.md" ]; then
      echo "# $1" > "$HOME/dots/cheat/$1.md"
      echo "Created new cheat sheet: $HOME/dots/cheat/$1.md"
    fi

    # Open the markdown file in editor
    $EDITOR "$HOME/dots/cheat/$1.md"
}

# Journal function
# Creates a markdown file in ~/diary/ with the name of the current date (YYYY-MM-DD.md)
# If the file already exists, it opens it in the editor
# If the ~/diary/ directory doesn't exist, it creates it
# If no parameter is passed, it shows a message
function journal() {
    local journal_dir="$HOME/journal"
    local today_file="$journal_dir/$(date +%Y-%m-%d).md"

    # Create journal directory if it doesn't exist
    mkdir -p "$journal_dir"

    # Create today's journal file with a header if it doesn't exist
    if [ ! -f "$today_file" ]; then
        local date_str=$(date "+%e of %B of %Y")
        echo "#$date_str" > "$today_file"
        echo "Created new journal entry: $today_file"
    fi

    # Open today's journal file in editor
    $EDITOR "$today_file"
}
