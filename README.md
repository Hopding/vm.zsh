# `vm.zsh`

Simpler runtime version management.

Most language runtimes have version managers that allow you to install and switch between different runtime versions via the CLI. This is much more convenient than manually installing runtimes and is less likely to corrupt your system.

So why should you use `vm.zsh`?
* **Consistent CLI.** If you're working with multiple version managers it is difficult to remember each tool's idiosyncrasies. `vm.zsh` enhances several common version managers with a unified interface for the most common operations: `list`, `use`, `install`, and `uninstall`.
* **Fast startup.** Many version managers must be initialized before they can be used. This initialization is usually done in your `.bash_profile` or `.zshrc` and as a result increases the time it takes to load a new shell/terminal (by up to several seconds). `vm.zsh` solves this problem by (1) lazy loading the version managers and (2) using the default/latest version of each runtime whenever a shell is created.

## Install

```
curl -o- https://raw.githubusercontent.com/Hopding/vm.zsh/master/vm.zsh > ~/.vm.zsh
echo 'source ~/.vm.zsh' >> ~/.zshrc
```

## Usage

```
  Usage: <vm> [command] [args]

  Variants:

    jvm                         Java (https://sdkman.io/)
    nvm                         Node (https://github.com/nvm-sh/nvm)
    pvm                         Python (https://github.com/pyenv/pyenv)
    gvm                         Go (https://github.com/stefanmaric/g)
    rvm                         Ruby (https://rvm.io/)

  Commands:

    <vm> list                   List installed versions of runtime
    <vm> use <version>          Use a specific version of runtime
    <vm> install <version>      Install a specific version of runtime
    <vm> install list           List all installable versions of runtime
    <vm> uninstall <version>    Uninstall a specific version of runtime

  Examples:

    jvm install 11.0.2-open
    rvm install list
    nvm use v9.8.0
    pvm install 3.9.5
    nvm install 12
    gvm install list
    rvm uninstall ruby-2.7.2
```

## Version Manager Versions

`vm.zsh` has been tested with the following version manager versions:
* `nvm` - **v0.38.0**
* `sdk` - **v5.11.6**
* `pyenv` - **v2.0.2**
* `g` - **v0.9.0**
* `rvm` - **v1.29.12**