#!/usr/bin/env bash
# The GPLv3 License (GPLv3)
#
# Copyright (c) 2022 Blakely North
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


### HELLO THERE!
# Welcome to the source code 😎
# Check out the variables at the top here for some quick ways to customize this
# script. Otherwise, feel free to take a look around! If you have any
# questions, feel free to file an issue to ask it.


# Main repository available at https://codeberg.org/PowerUser/universal-studio

# Requires: curl

# shellcheck disable=SC2016

set -eu

program_name=universal-studio
program_ver=0.1.0
homepage=https://codeberg.org/PowerUser/universal-studio

# Standalone mode: enables the script to work without the need for the repository (enabled in releases)
standalone_mode=${STANDALONE:-false}

# Enable automatic update checks
auto_check_updates=${AUTO_CHECK_UPDATES:-false}

raw_repo_url=https://codeberg.org/PowerUser/universal-studio/raw/branch
release_url=https://codeberg.org/PowerUser/universal-studio/releases/download

# where to check updates from
update_url=$raw_repo_url/main/universal-studio.sh

# url to get package list (flake.nix)
pkg_list_url=$raw_repo_url/main/flake.nix

# Version of nix-portable to pull from nix-portable releases page
nix_portable_version=v010
nix_portable_dl_url=https://github.com/DavHau/nix-portable/releases/download/"$nix_portable_version"/nix-portable

# Get the directory the script is in
script_self="$(realpath "$0")"
script_dir="$(dirname "$script_self")"
nix_portable_location="$script_dir/nix-portable"

application_list_name=Apps

# All types of plugins supported by universal studio, listed as their names appear in /usr/lib, in no specific order
plugin_types=(clap vst3 lv2 vst ladspa dssi lxvst)

# Initialize FORCE_NIX_PORTABLE to false if it's unset
FORCE_NIX_PORTABLE="${FORCE_NIX_PORTABLE:-false}"

# Helper functions for printing information
msg() { echo "$@"; }
err() { msg  "$@" >&2; }
dbg() { ("${DEBUG:-false}" && err "$@") || true; }

usage() {
   msg "Usage:"
   msg " Launch applications: ${Grn_o}$program_name ${Cyn_o}app_1 app_2 app_3 [...]${Nc_o}"
   msg " Other functionality: ${Grn_o}$program_name ${Cyn_o}[option]${Nc_o}"
   msg "  The options are:"
   msg "   ${Cyn_o}list${Nc_o}                 List all applications available to launch"
   msg "   ${Cyn_o}update <0.1.0|main>${Nc_o}  Updates to a specified branch or version of this script (e.g. $program_ver or 'main')"
   msg "   ${Cyn_o}checkupdate${Nc_o}          Check for updates to this script"
   msg "   ${Cyn_o}version${Nc_o}              Prints version info"
   msg "   ${Cyn_o}help${Nc_o}                 Print this help menu"
   msg
   msg "Example:"
   msg " # Start bespokesynth, ardour, and carla"
   msg " ${Grn_o}$program_name ${Cyn_o}bespokesynth ardour carla${Nc_o}"
   msg
   msg "Check $homepage for updates"
   exit "$1"
}

version() {
   msg "$program_name v$program_ver"
   msg "Check $homepage for updates"
   exit "$1"
}


# version comparison functions from stackoverflow: https://stackoverflow.com/a/4024263/11162605
verlte() { [  "$1" = "$(echo -e "$1\n$2" | sort -V | head -n1)" ]; }
# shellcheck disable=SC2015
verlt() { [ "$1" = "$2" ] && return 1 || verlte "$1" "$2"; }

# Print the first argument
get_name() { printf '%s' "$1"; }
# Print all arguments but the first argument
get_args() { shift; if test $# -gt 0; then printf '%s ' "$@"; fi; }

# Update to a given version
self_update() {
   if [ -n "$1" ]; then
      tmp_newver="$(mktemp --suffix="-$program_name-new-$program_ver")"
      tmp_oldver="$(mktemp --suffix="-$program_name-previous-$program_ver")"
      # check if it's a version number or a branch
      if grep -Pq 'v?\d+\.\d+\.\d+$' <<< "$1"; then
         if curl -sSL "$release_url/$1/universal-studio" > "$tmp_newver" && ! grep -Pqm 1 '^Not [Ff]ound\.?$' "$tmp_newver"; then
            # update files
            cat "$script_self" > "$tmp_oldver"
            cat "$tmp_newver" > "$script_self"
         else
            err "${Red_e}Error:${Nc_e} couldn't fetch version '$1'"
            rm "$tmp_newver" "$tmp_oldver"
            exit 1
         fi
      else
         if curl -sSL "$raw_repo_url/$1/universal-studio.sh" > "$tmp_newver" && ! grep -Pqm 1 '^Not [Ff]ound\.?$' "$tmp_newver"; then
            # update files
            cat "$script_self" > "$tmp_oldver"
            cat "$tmp_newver" > "$script_self"
         else
            # NOTE: it will get here if the version above was entered incorrectly too
            err "${Red_e}Error:${Nc_e} couldn't fetch branch '$1'"
            rm "$tmp_newver" "$tmp_oldver"
            exit 1
         fi
      fi
      msg "Old version has been copied to: $tmp_oldver"
      msg "${Grn_o}Update success!${Nc_o}"
      exit 0;
   else
      err "${Red_e}Error:${Nc_e} please provide a version to update to ('main' for the latest unstable version)"
      err "See project homepage for a list of all versions: $homepage"
   fi
}

# checks for updates
check_update() {
   latest_ver="$(curl -sSL "$update_url" | grep -Po 'program_ver=\K\d+\.\d+\.\d+$')"
   if verlt "$program_ver" "$latest_ver"; then
      msg "${Ylw_o}Info:${Nc_o} a new version is available!"
      msg "See project homepage for updates: $homepage"
   elif $1; then
      msg "No new version is available"
   fi
   $1 && msg "(current: v$program_ver latest: v$latest_ver)"
}

# Extract the list of applications from flake.nix
pkgs_list_available() {
   # Get the package list and filter through it to find the list of available packages
   if "$standalone_mode"; then
      curl -sSL "$pkg_list_url"
   else
      cat "$script_dir/flake.nix"
   fi | # Get the whole flake
      sed -n /"$application_list_name"' =.\+\[$/,/\];/{ :loop; N; /\];/!{b loop}; p; q; }' | # Select the application list
      grep -o '\w\+$' # Select the lines with list elements on them
}

# Prints a list of all unavailable packages passed to it
pkgs_is_available() {
   all_pkgs="$(pkgs_list_available)"
   while ! test $# = 0; do
      search="$(eval "get_name $1")"
      echo "$all_pkgs" | grep -Fx "$search" > /dev/null || printf '  %s\n' "$search"
      shift
   done
}

# bubblewrap helper function from nix-portable (source: https://github.com/DavHau/nix-portable/blob/master/default.nix#L241-L287)
# The only modification is to remove paths to plugins (/usr/lib/vst3, etc)
collectBinds(){
  ### gather paths to bind for proot
  # we cannot bind / to / without running into a lot of trouble, therefore
  # we need to collect all top level directories and bind them inside an empty root
  pluginPaths="$(find /usr/lib -mindepth 1 -maxdepth 1)"

  arg="$1"; shift

  binds=("")
  for p in $pluginPaths; do
    # If path exists, is real, and is in the list of plugin types, make a temp dir for it and put the temp dir and the real path in the bind list
    if [ -e "$p" ]; then
      real=$(realpath "$p")
      if [ -e "$real" ]; then
        # shellcheck disable=SC2076
        if [[ " ${real##*/} " =~ " $* " ]]; then
          tmpdir="$emptytmpdir/${p##*/}"
          mkdir "$tmpdir"
          binds+=("$arg" "$tmpdir" "$p")
        fi
      fi
    fi
  done
}

# Runs a command, but wrapped with bubblewrap to disable access to certain directories
run_wrapped() {
   emptytmpdir="$(mktemp -d)"

   # NixOS doesn't require nixGL
   if test -s /bin/sh && [[ "$(realpath /bin/sh)" == /nix/store/* ]]; then
      eval "$*"
   else
      collectBinds --bind "${plugin_types[@]}"
      eval "$nix" run 'nixpkgs#bubblewrap' -- \
         --bind / / \
         --dev-bind /dev /dev \
         "\${binds[@]}" \
         \
         "$nix" run 'github:nix-community/nixGL#nixGLIntel' -- \
         \
         "$*"
   fi
   rm -rf "$emptytmpdir"
}

# returns true if you are root
am_i_root() { test "$(id -u)" = 0; }

# Checks if a command exists
command_exists() { command -v "$1" > /dev/null; }

# Get some colors for ~flare~ (but don't use colors if output isn't a terminal)
# Colors for stdout
Cyn_o='' Ylw_o='' Grn_o='' Nc_o=''
if test -t 1; then
   if command_exists tput; then
      Grn_o="$(tput setaf 2)" Ylw_o="$(tput setaf 3)" Cyn_o="$(tput setaf 6)" Nc_o="$(tput sgr0)";:
   else
      Grn_o='[32m' Ylw_o='[33m' Cyn_o='[36m' Nc_o='(B[m';:
   fi
fi
# Colors for stderr
Red_e='' Grn_e='' Ylw_e='' Cyn_e='' Nc_e=''
if test -t 2; then
   if command_exists tput; then
      Red_e="$(tput setaf 1)" Grn_e="$(tput setaf 2)" Ylw_e="$(tput setaf 3)" Cyn_e="$(tput setaf 6)" Nc_e="$(tput sgr0)";:
   else
      Red_e='[31m' Grn_e='[32m' Ylw_e='[33m' Cyn_e='[36m' Nc_e='(B[m';:
   fi
fi

# Check if in standalone mode, set $flake accordingly
if "$standalone_mode"; then
   flake='github:PowerUser64/universal-studio'
else
   if ! [ -f "$script_dir"/flake.nix ]; then
      err "${Red_e}Error:${Nc_e} flake.nix could not be found."
      err "Please either enable standalone mode (set STANDALONE=true) or clone the repository and disable standalone mode."
      exit 1
   fi
   flake="$script_dir"
fi

# See if a new version is available
if "$standalone_mode" && "$auto_check_updates"; then
   check_update false
fi

# Warn if running as root
if am_i_root; then
   err "${Ylw_e}Warning:${Nc_e} This script does not need to be run as root."
   sleep 2
fi

# Test if curl exists
if ! command_exists curl; then
   err "${Red_e}Error:${Nc_e} \`curl\` does not exist or could not be found in \$PATH. Please install curl and try again." >&2
   exit 1
fi

# Check if no arguments are passed
if test $# = 0; then
   err "${Red_e}Error:${Nc_e} Please provide an option or a list or applications."
   usage 1
fi

# # Check if no arguments are passed
# if "$standalone_mode"; then
#    dbg "${Red_e}Error:${Nc_e} Please provide an option or a list or applications."
#    usage 1
# fi

# Very simple command line argument parsing
case "$1" in
   list) msg "Available packages:"; pkgs_list_available | sort | sed 's/^/  /'; exit;;
   update) shift; self_update "${1:-}";;
   checkupdate) shift; check_update true;;
   -h|--help|help) usage 0;;
   -v|--version|version) version 0;;
   # Don't allow packages that start with a '-' so grep doesn't complain
   -*) err "${Red_e}Error:${Nc_e} option $1 does not exist."; err "See \`$Grn_e$program_name help$Nc_e\` for a list of all options."; exit 1;;
esac

# Exit if any unavailable applications were requested
unavailable="$(pkgs_is_available "$@")"
if [ -n "$unavailable" ]; then
   err "${Red_e}Error:${Nc_e} Some of the requested packages are not available:"
   err "$unavailable"
   err "See \`${Grn_e}$program_name ${Cyn_e}list${Nc_e}\` for a list of all available applications"
   exit 1
fi

# Find or get nix-portable, or select the system version of nix
if command_exists nix && ! "$FORCE_NIX_PORTABLE"; then
   dbg '`nix` command detected, using it'
   nix='nix --extra-experimental-features "flakes nix-command"'
elif command_exists nix-portable; then  # check if nix-portable is in $PATH
   nix="nix-portable nix"
# Check if we haven't yet downloaded nix-portable
elif ! test -x "$nix_portable_location"; then
   # Get nix-portable from GitHub releases
   msg "${Grn_o}\`nix-portable\`${Nc_o} not found locally, downloading from github releases..."
   curl -sSLo "$nix_portable_location" "$nix_portable_dl_url"
   chmod +x "$nix_portable_location"
   nix="$nix_portable_location nix"
# If we already have nix-portable and it's executable, it will get here
else
   nix="$nix_portable_location nix"
fi
if "$FORCE_NIX_PORTABLE"; then
   dbg "Forcing nix portable"
fi

dbg "nix command is $nix"
for package in "$@"; do
   pkg="$(eval "get_name $package")"
   args="$(eval "get_args $package")"
   msg "Running ${Grn_o}$pkg${Cyn_o}${args:+ }$args${Nc_o} with ${Grn_o}$(eval "get_name $nix")${Nc_o}…"
   # arguments are quoted here because zsh doesn't like having the pound sign unescaped in some cases
   cmd=("$nix" run "$flake#$pkg" -- "$args")
   run_wrapped "${cmd[@]}" &
   # Replace arg array with pid's of running apps
   set -- "$@" $!
   shift
done

# Pass on ctrl-c
cleanup() { err;err "Finishing up…"; kill -TERM "$@"; }
# shellcheck disable=SC2064
trap "cleanup $*" INT

wait
