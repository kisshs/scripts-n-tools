#!/bin/bash

# u1decrypt.sh - Decrypts file or directory from Ubuntu One cloud
# by dual
#
# Original script from:
# http://gnome-look.org/content/show.php/Ubuntu+One+Encrypt+Decrypt?content=142064

# DEFINE SYNC DIRECTORY
ubuntu1="$HOME/Ubuntu One"

echo "u1decrypt.sh - Decrypts encrypted file from Ubuntu One cloud to home directory"
echo

# Check for argument
if [ $# -ne 1 ]; then
    echo "u1decrypt.sh needs an encrypted file as an argument... exiting."
    exit 1
else
    target="$1"
fi

# Verify sync directory
[ -d "$ubuntu1" ] || {
    echo "$ubuntu1 directory not found... exiting."
    exit 1
}

# Verify openssl is installed
if [ "$(which openssl)" = "" ]; then
    echo "openssl not found... exiting."
    exit 1
fi

# Get decryption passphrase
read -p "Enter the decryption passphrase: " pass
if [[ "$pass" = "" ]]; then
    echo "A passphrase is required to decrypt data... exiting."
    exit 1
fi

# Copy and decrypt
if [[ "$target" =~ \.tar\.gz\.des3 ]]; then
    echo "Decrypting $target..."
    filename=$(basename "$target" .des3)
    dirname=$(basename "$filename" .tar.gz)
    openssl des3 -d -salt -pass pass:"$pass" -in "$target" -out "$HOME/$filename"
    if [ -e "$dirname" ]; then
        echo "Directory $dirname exists."
        read -p "Do you want to overwrite $dirname [y/n]? " yorn
        if [[ "$yorn" = 'y' || "$yorn" = 'Y' ]]; then
            tar xzf "$HOME/$filename"
            rm "$HOME/$filename"
        else
            echo "Exiting so as to not overwrite $dirname."
            rm "$HOME/$filename"
            exit 1
        fi
    else
        tar xzf "$HOME/$filename"
        rm "$HOME/$filename"
    fi
elif [[ "$target" =~ \.des3 ]]; then
    echo "Decrypting $target..."
    filename=$(basename "$target" .des3)
    if [ -e "$HOME/$filename" ]; then
        openssl des3 -d -salt -pass pass:"$pass" -in "$target" -out "$HOME/$filename-1"
    else
        openssl des3 -d -salt -pass pass:"$pass" -in "$target" -out "$HOME/$filename"
    fi
else
    echo "$target is not encrypted file... exiting."
    exit 1
fi

echo
echo "Done."
