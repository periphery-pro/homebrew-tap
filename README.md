# Periphery Homebrew Tap

This tap installs Periphery from prebuilt binary archives.

## Install

Add the tap, then install the CLI formula:

```sh
brew tap periphery-pro/tap
brew install periphery-cli
```

You can also install in one command:

```sh
brew install periphery-pro/tap/periphery-cli
```

The formula installs the `periphery` executable.

## Upgrade

```sh
brew update
brew upgrade periphery-cli
```

## Notes

The `periphery-cli` formula conflicts with the public `periphery` formula from `homebrew/core`, because both install a `periphery` executable.
