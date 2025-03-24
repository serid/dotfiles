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

function with_github_token() {
    # Encrypt file "~/.git-credentials" with
    #openssl aes-256-cbc -pbkdf2 -in ~/.git-credentials -out credentials.enc

    openssl aes-256-cbc -pbkdf2 -d -in ~/dotfiles/credentials.enc -out ~/.git-credentials || return
    $@
    echo "" > ~/.git-credentials
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
