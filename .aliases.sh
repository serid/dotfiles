export EDITOR=vim

export PATH=$PATH:/opt/fasm:/opt/dotnet:/home/serid/.dotnet/tools:~/.local/bin

# General
alias rm="rm -i"
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

alias remove_orphans="pacman -Qtdq | sudo xargs pacman -Rns --noconfirm"

alias cag="clear; cargo"

alias chelp="clang --help | grep"

function cdl()
{
  cd $1
  ls
}

function package_reason()
{
  pacman -Qi $1 | grep Reason
}

#function repeat() {
    #number=$1
    #shift
    #for i in `seq $number`; do
      #$@
    #done
#}
