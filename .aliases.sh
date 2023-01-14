export EDITOR=vim

# General
#alias rm="rm -i"
alias mv="mv -i"
alias cp="cp -i"
alias l="ls"
alias ll='ls -oh'
alias la='ls -A'
alias v="vim"
alias e="emacs"
alias j="jobs"
alias c="cdl"
alias o="xdg-open"
alias p="python3"
alias pi="p -i"
alias nf="touch"
alias hexdump="hexdump -C"
alias extract="tar -xvf"
alias where="readlink -f"
alias pong="ping 8.8.8.8"
alias update="sudo pacman -Syu"
alias show="clear;tree"
alias new="urxvt &"
alias summ="du -h --summarize *"
alias rmsc="rm -f Screenshot*"
alias Find="find 2>/dev/null"
alias sgpm="sudo systemctl start gpm"

alias cag="clear; cargo"

alias chelp="clang --help | grep"

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

function cdl()
{
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
