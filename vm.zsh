#! /bin/zshrc

################################################################################
# Simpler runtime version management.                                          # 
#                                                                              #
# Most language runtimes have version managers that allow you to install and   #
# switch between different runtime versions via the CLI. This is much more     #
# convenient than manually installing runtimes and is less likely to corrupt   #
# your system.                                                                 #
#                                                                              #
# So why should you use `vm.zsh`?                                              #
#   * **Consistent CLI.** If you're working with multiple version managers it  #
#     is difficult to remember each tool's idiosyncrasies. `vm.zsh` enhances   #
#     several common version managers with a unified interface for the most    #
#     common operations: `list`, `use`, `install`, and `uninstall`.            #
#   * **Fast startup.** Many version managers must be initialized before they  #
#     can be used. This initialization is usually done in your `.bash_profile` #
#     or `.zshrc` and as a result increases the time it takes to load a new    #
#     shell/terminal (by up to several seconds). `vm.zsh` solves this problem  #
#     by (1) lazy loading the version managers and (2) using the               #
#     default/latest version of each runtime whenever a shell is created.      #
################################################################################

alias vm="echo '
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
'"

function _rename_function() {
  # Check if the specified function is defined.
  # If so, store its definition in `_`. If not, return.
  test -n "$(declare -f $1)" || return

  # Redefine the specified function, but replace the first occurence of 
  # $1 with $2, thereby renaming it.
  eval "${_/$1/$2}"

  # Remove the function defined under the old name.
  unset -f $1
}

################################################################################
################################## NVM #########################################
################################################################################

# Use the latest version installed by `nvm`. This way we get access to `node` 
# and `npm` whenever a new shell is opened, but without taking the immediate
# performance hit brought on by initializing `nvm`.
export NVM_DIR="$HOME/.nvm"
newest_node_version=$(ls "$NVM_DIR/versions/node" | sort -V | tail -1)
if ! [[ -z "$newest_node_version" ]] then
  export PATH="$NVM_DIR/versions/node/$newest_node_version/bin:$PATH"
fi

# Enhanced version of `nvm`.
function enhanced_nvm() {
  if [[ "$1" == "list" ]] then
    orig_nvm list node
  elif [[ "$1" == "use" ]] then
    orig_nvm use "$2"
  elif [[ "$1" == "install" ]] && [[ "$2" == "list" ]] then
    orig_nvm ls-remote
  elif [[ "$1" == "install" ]] then
    orig_nvm install "$2"
  elif [[ "$1" == "uninstall" ]] then
    orig_nvm uninstall "$2"
  else
    orig_nvm "$@"
  fi
}

# Lazy-loading wrapper/proxy. Will only be called on first invokation of `nvm`.
function nvm() {

  # Remove this function, subsequent calls will execute `nvm` directly
  unfunction "$0"

  # Load `nvm`
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

  # Replace `nvm` with `enhanced_nvm`.
  _rename_function nvm orig_nvm
  _rename_function enhanced_nvm nvm

  # Execute `nvm` binary
  $0 "$@"
}

################################################################################
################################## RVM #########################################
################################################################################

# Use the default version installed by `rvm`. This way we get access to `ruby` 
# whenever a new shell is opened, but without taking the immediate performance 
# hit brought on by initializing `rvm`.
export PATH="$PATH:$HOME/.rvm/bin"
default_ruby_version=$(basename $(readlink "$HOME/.rvm/rubies/default"))
export PATH="$HOME/.rvm/rubies/$default_ruby_version/bin:$PATH"
export PATH="$HOME/.rvm/gems/$default_ruby_version@global/bin:$PATH"
export PATH="$HOME/.rvm/gems/$default_ruby_version/bin:$PATH"
export GEM_HOME="$HOME/.rvm/gems/$default_ruby_version"
export GEM_PATH="$HOME/.rvm/gems/$default_ruby_version:$GEM_PATH"
export GEM_PATH="$HOME/.rvm/gems/$default_ruby_version@global:$GEM_PATH"

# Lazy-loading wrapper/proxy of `rvm` that also enhances its CLI. 
function rvm() {
  _rename_function rvm rvm_proxy
  source ~/.rvm/scripts/rvm

  if [[ "$1" == "list" ]] then
    rvm list
  elif [[ "$1" == "use" ]] then
    rvm use "$2"
  elif [[ "$1" == "install" ]] && [[ "$2" == "list" ]] then
    rvm list known
  elif [[ "$1" == "install" ]] then
    rvm install "$2"
  elif [[ "$1" == "uninstall" ]] then
    rvm remove "$2"
  else
    rvm "$@"
  fi

  _rename_function rvm_proxy rvm
}

################################################################################
################################## JVM #########################################
################################################################################

# Use the current java version installed by `sdk`. This way we get access to 
# `java` whenever a new shell is opened, but without taking the immediate
# performance hit brought on by initializing `sdk`.
export SDKMAN_DIR="$HOME/.sdkman"
export PATH="$SDKMAN_DIR/candidates/java/current/bin:$PATH"
export JAVA_HOME="$SDKMAN_DIR/candidates/java/current"

# Enhanced version of `sdk` specifically for java.
function jvm() {
  if [[ "$1" == "list" ]] then
    sdk list java | grep installed
  elif [[ "$1" == "use" ]] then
    sdk use java "$2"
  elif [[ "$1" == "install" ]] && [[ "$2" == "list" ]] then
    sdk list java
  elif [[ "$1" == "install" ]] then
    sdk install java "$2"
  elif [[ "$1" == "uninstall" ]] then
    sdk uninstall java "$2"
  else
    sdk "$@"
  fi
}

# Lazy-loading wrapper/proxy. Will only be called on first invokation of `sdk`.
function sdk() {

  # Remove this function, subsequent calls will execute `sdk` directly
  unfunction "$0"

  # Load `sdk`
  [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

  # Execute `sdk` binary
  $0 "$@"
}

################################################################################
################################## PVM #########################################
################################################################################

# Use the latest version installed by `pyenv`. This way we get access to 
# `python` and `pip` whenever a new shell is opened, but without taking the 
# immediate performance hit brought on by initializing `pyenv`.
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/shims:$PATH"
export PYENV_VERSION=$(ls "$PYENV_ROOT/versions" | sort -V | tail -1)

# Enhanced version of `pyenv`.
function pvm() {
  if [[ "$1" == "list" ]] then
    pyenv versions
  elif [[ "$1" == "use" ]] then
    pyenv shell "$2"
  elif [[ "$1" == "install" ]] && [[ "$2" == "list" ]] then
    pyenv install --list
  elif [[ "$1" == "install" ]] then
    pyenv install "$2"
  elif [[ "$1" == "uninstall" ]] then
    pyenv uninstall "$2"
  else
    pyenv "$@"
  fi
}

# Lazy-loading wrapper/proxy. Will only be called on first invokation of `pyenv`.
function pyenv() {

  # Remove this function, subsequent calls will execute `pyenv` directly
  unfunction "$0"

  # Load `pyenv`
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"

  # Execute `pyenv` binary
  $0 "$@"
}

################################################################################
################################## GVM #########################################
################################################################################

# Use the latest version installed by `g`. Running the `g` command will not 
# set these variables, though it will update their subcontents/folders. Unlike
# several of the other version managers, `g` is stateless.
export GOPATH="$HOME/go"; 
export GOROOT="$HOME/.go"; 
export PATH="$GOPATH/bin:$PATH"; 

# Enhanced version of `g`.
function gvm() {
  if [[ "$1" == "list" ]] then
    $GOPATH/bin/g list
  elif [[ "$1" == "use" ]] then
    $GOPATH/bin/g set "$2"
  elif [[ "$1" == "install" ]] && [[ "$2" == "list" ]] then
    $GOPATH/bin/g list-all
  elif [[ "$1" == "install" ]] then
    $GOPATH/bin/g install "$2"
  elif [[ "$1" == "uninstall" ]] then
    $GOPATH/bin/g remove "$2"
  else
    $GOPATH/bin/g "$@"
  fi
}