#!/bin/bash
############################
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

########## Variables
# dotfiles directory
dir=~/dotfiles
# list of files/folders to symlink in homedir    # list of files/folders to symlink in homedir
files="config gitconfig ipython lesskey profile"
target=~

##########

create_symlinks() {
    local source=$1


    if [ -d $source ]; then
        # Process each item in the source and recursively call create_symlinks
        for item in $source/*; do
            create_symlinks $item
        done
    elif [ -f $source ]; then
        # If it's a file, create a symlink
        local rel_path="${source#$dir/}"
        local target_path="$target/.$rel_path"
        ln -sf $source $target_path
        echo "Created symlink: $target_path -> $source"
    fi
}

for file in $files; do
    echo "Creating symlink to $file in home directory."
    create_symlinks $dir/$file
done
