export EDITOR=hx

# General
#alias rm="rm -i"
alias mv="mv -i"
alias cp="cp -i"
alias l="exa"
alias ll="exa -l"
alias la="exa -A"
alias j="jobs"
alias c="cdl"
alias o="xdg-open"
alias p="python3"
alias pi="p -i"
alias hexdump="hexdump -C"
alias extract="tar -xvf"
alias absolute="readlink -f"
alias pong="ping 8.8.8.8"
alias poff="poweroff"
alias Find="find 2>/dev/null"
alias git-river="git log --all --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)'"

function nixrun() {
    local what="$1"
    shift
    nix run "nixpkgs#$what" -- "$@"
}

# Open a nix-shell with a package that contains a provided program name
function autoshell() {
    if [ $# -ne 1 ]; then
        echo "Usage: auto-shell <program>" >&2
        return 1
    fi

    local program="$1"

    if command -v "$program" >/dev/null 2>&1; then
        echo "The program '$program' is already available." >&2
        return 1
    fi

    local error_msg
    error_msg="$("$program" 2>&1)"
    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        echo "The program '$program' executed successfully but shouldn't be available." >&2
        return 1
    elif [ $exit_code -ne 127 ]; then
        echo "The program '$program' returned an error (code $exit_code):" >&2
        echo "$error_msg" >&2
        return 1
    fi

    # Parse packages out of suggested nix-shells
    local packages
    packages="$(echo "$error_msg" | awk '/^  nix-shell -p / {print $3}')"

    if [ -z "$packages" ]; then
        echo "No package suggestions found for '$program'." >&2
        echo "$error_msg" >&2
        return 1
    fi

    # Choose package with same name as program or else pick first suggestion
    local chosen_package
    chosen_package=""
    while IFS= read -r pkg; do
        if [ "$pkg" = "$program" ]; then
            chosen_package="$pkg"
            break
        fi
    done <<< "$packages"

    if [ -z "$chosen_package" ]; then
        chosen_package="$(echo "$packages" | head -n1)"
    fi

    #echo "Entering nix-shell with package: $chosen_package" >&2
    local escaped_program
    printf -v escaped_program "%q" "$program"
    nix-shell -p "$chosen_package" --run "$escaped_program; exec \"$SHELL\""
}

export HISTFILESIZE=10000
export HISTSIZE=99999

function nixgc() {
  nix-collect-garbage -d
  sudo nix-collect-garbage -d

  echo "Deleting old bootloader entries."
  local last_generation=$(sudo nix-env -p /nix/var/nix/profiles/system --list-generations | awk 'END {print $1}')
  echo "Keeping generation $last_generation."
  sudo bash -c "cd /boot/loader/entries; ls | grep -v $last_generation | xargs rm"
}

# Create a new "~/.git-credentials" in encryoted form
function new_github_token() {
    echo "https://serid:$1@github.com" | openssl aes-256-cbc -pbkdf2 -out credentials.enc
}

function with_github_token() {
    openssl aes-256-cbc -pbkdf2 -d -in ~/dotfiles/credentials.enc -out ~/.git-credentials || return
    $@
    rm ~/.git-credentials
}

# Issue with arguments with spaces
#function rm() {
    ## Add -i if there are a lot of files
    #if [[ $# -gt 1 ]]
    #then
        #/bin/rm -i $@
    #else
        #/bin/rm $1
    #fi
#}

function cdl() {
  cd $1
  ls
}

#function repeat() {
    #number=$1
    #shift
    #for i in `seq $number`; do
      #$@
    #done
#}
