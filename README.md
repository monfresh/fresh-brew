# fresh-brew

fresh-brew is a script that will set up a basic development environment on your
Mac with Homebrew, Apple's Command Line Tools, and Git.

It can be run multiple times on the same machine safely. It installs,
upgrades, or skips packages based on what is already installed on the machine.

You can also easily [customize](#customize-in-fresh-brewlocal-and-brewfilelocal)
the script to install additional tools.

## What's supported

Supported chips:

- Apple Silicon M1
- Intel

Supported macOS versions:

- Big Sur
- Catalina
- Mojave

Supported shells:

- bash
- zsh
- fish

## Installation

Begin by opening the Terminal application on your Mac. The easiest way to open
an application in macOS is to search for it via [Spotlight]. The default
keyboard shortcut for invoking Spotlight is `command-Space`. Once Spotlight
is up, just start typing the first few letters of the app you are looking for,
and once it appears, press `return` to launch it.

In your Terminal window, copy and paste the command below, then press `return`.

```sh
bash <(curl -s https://raw.githubusercontent.com/monfresh/fresh-brew/main/fresh-press)
```

The [script](https://github.com/monfresh/fresh-brew/blob/main/pour.sh) itself is
available in this repo for you to review if you want to see what it does
and how it works.

Note that the script might ask you to enter your macOS password at various
points. This is the same password that you use to log in to your Mac. The
prompt comes from Homebrew, because it needs permissions to write to the
`/usr/local` (or `/opt/homebrew` on M1 Macs) directory.

**Once the script is done, quit and relaunch Terminal.**

I recommend running the script regularly to keep your computer up
to date. Once the script has been installed, you'll be able to run it at your
convenience by typing `freshbrew` and pressing `return` in your Terminal.

[spotlight]: https://support.apple.com/en-us/HT204014

## Debugging script failures

Your last `fresh-brew` run will be saved to a file called `fresh-brew.log` in your home
folder. Read through it to see if you can debug the issue yourself. If not,
copy the entire contents of `fresh-brew.log` into a
[new GitHub Issue](https://github.com/monfresh/fresh-brew/issues/new), or attach the whole log file to the issue.

## How to tell if the script worked

If you see "All done!" at the bottom of your terminal, then everything the
script was meant to do worked. **Now make sure you quit and restart your terminal.**

To verify that your dev environment is properly configured, run these commands:

```shell
brew doctor
```

You should see a message that "Your system is ready to brew."


## Check the Node installation

To verify if Node was installed and configured:

```shell
node --version
```
You should see `v14.17.1` or later

```shell
nodenv help
```
You should see various commands you can run with `nodenv`.

## Next steps

The next thing you'll want to do after running the script is to [configure Git with your name, email, and preferred editor](https://www.moncefbelyamani.com/first-things-to-configure-before-using-git/).

## What it sets up

- [GitHub CLI] brings GitHub to your terminal.
- [Homebrew] for managing operating system libraries
- [Nodenv] to easily install and manage Node versions
- [Yarn] to manage JS dependencies

[github cli]: https://cli.github.com
[homebrew]: http://brew.sh/
[Nodenv]: https://github.com/nodenv/nodenv
[yarn]: https://yarnpkg.com

It should take less than 15 minutes to install (depends on your machine and
internet connection).

## Customize in `/fresh-brew.local` and `/Brewfile.local`

By adding these two files inside your project, you can customize each project
with different tools. Note that tools installed via Homebrew will be available
globally, so if you need two different versions of a tool for different projects,
this script might not work for you.

For an example of a customization that should work across projects, view the
[fresh-brew.local](https://github.com/monfresh/fresh-brew/blob/main/fresh-brew.local)
and [Brewfile.local](https://github.com/monfresh/fresh-brew/blob/main/Brewfile.local)
in this repo, or download them:

```sh
# Download the sample files to your computer
curl --remote-name https://raw.githubusercontent.com/monfresh/fresh-brew/fresh-brew.local
curl --remote-name https://raw.githubusercontent.com/monfresh/fresh-brew/Brewfile.local

# open the files in your text editor
open fresh-brew.local
open Brewfile.local
```

These files should be placed at the root of your project.
`fresh-brew.local` is run at the end of the `pour.sh` script.
Put your customizations there. If you want to install additional
tools or Mac apps with Homebrew, add them to your `Brewfile.local`.

Write your customizations such that they can be run safely more than once.
See the `pour.sh` script for examples. Any function defined in `pour.sh` can be
used in your `fresh-brew.local`.

If you want to skip running `fresh-brew.local`, you can set the `SKIP_LOCAL`
environment variable to `true` before running `bash pour.sh`:

```shell
export SKIP_LOCAL=true
bash pour.sh
```

In the example files above, `nodenv` and `yarn` will be installed globally via
Homebrew, but then you can install different versions of `node` using `nodenv`,
and you can switch between them by specifying the node version in a `.node-version`
file at the root of your project. That way, you can have one project that uses
Node version 14.7.1, and another that uses Node version 16.9.1. Each project will
have its own `fresh-brew.local` file that installs the desired version using
`nodenv`.
