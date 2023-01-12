git clone https://github.com/serid/dotfiles.git

# Clone files to ~/

cp ./dotfiles/.* ~/

read -p "Remove \"./dotfiles/\"? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    rm -rf ./dotfiles/
fi
