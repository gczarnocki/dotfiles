# dotfiles

@gczarnocki does dotfiles.

# Prerequisites

Checkout this repository into `~/dotfiles` directory.

```sh
cd $HOME
git clone https://github.com/gczarnocki/dotfiles.git
cd dotfiles
```

# Install `Homebrew`

https://brew.sh

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

# Run `Brewfile`

```sh
brew bundle
```

# Run `stow`

```sh
stow bash home vim
```