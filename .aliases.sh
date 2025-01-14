export EDITOR=nvim

# General
#alias rm="rm -i"
alias mv="mv -i"
alias cp="cp -i"
alias l="ls"
alias ll='ls -oh'
alias la='ls -A'
alias v="nvim"
alias j="jobs"
alias c="cdl"
alias o="xdg-open"
alias p="python3"
alias pi="p -i"
alias nf="touch"
alias hexdump="hexdump -C"
alias extract="tar -xvf"
alias absolute="readlink -f"
alias pong="ping 8.8.8.8"
alias poff="poweroff"
alias Find="find 2>/dev/null"

function nixgc() {
    # Delete old system generations
    sudo nix-env -p /nix/var/nix/profiles/system --delete-generations old

    if [[ -z $1 ]]; then
        echo Provide a generation number as argument to keep its bootloader from deletion. Here are the generations:
        sudo nix-env -p /nix/var/nix/profiles/system --list-generations
    else
        echo Deleting all bootloader entries except $1.
        sudo bash -c "cd /boot/loader/entries; ls | grep -v $1 | xargs rm"
    fi

    # Delete old user profile generations and collect garbage
    nix-collect-garbage -d
}

function with_github_token() {
    # Encrypt file "~/.git-credentials" with
    #openssl aes-256-cbc -pbkdf2 -in ~/.git-credentials -out credentials.enc

    openssl aes-256-cbc -pbkdf2 -d -in ~/dotfiles/credentials.enc -out ~/.git-credentials
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
