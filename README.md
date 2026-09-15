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

The formula installs the `periphery` executable with its bundled runtime libraries. On macOS, Periphery does not require the standalone Command Line Tools package for runtime library loading. You still need the build tools required by your project, such as Xcode for Xcode projects. Homebrew may also require developer tools during installation.

## Upgrade

```sh
brew update
brew upgrade periphery-cli
```

## Notes

The `periphery-cli` formula conflicts with the public `periphery` formula from `homebrew/core`, because both install a `periphery` executable.
