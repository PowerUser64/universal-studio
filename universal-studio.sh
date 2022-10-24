#!/usr/bin/env sh
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

# Main repository available at https://codeberg.org/PowerUser/universal-studio

# Requires: curl

# shellcheck disable=SC2016

set -eu

program_name=universal-studio
program_ver=0.0.2
homepage=https://codeberg.org/PowerUser/universal-studio

pkg_list_url=https://codeberg.org/PowerUser/universal-studio/raw/branch/main/flake.nix

# Version of nix-portable to pull from nix-portable releases page
nix_portable_version=v009
nix_portable_dl_url=https://github.com/DavHau/nix-portable/releases/download/"$nix_portable_version"/nix-portable

# Nix flake to run - TODO: figure out how to make this point to codeberg
flake='github:PowerUser64/universal-studio'

# Get the directory the script is in
script_dir="$(dirname "$(realpath "$0")")"
nix_portable_location="$script_dir/nix-portable"

application_list_name=myApplications

# Initialize FORCE_NIX_PORTABLE to false if it's unset
FORCE_NIX_PORTABLE="${FORCE_NIX_PORTABLE:-false}"

# Helper functions for printing information
msg() { echo "$@"; }
err() { msg  "$@" >&2; }
dbg() { ("${DEBUG:-false}" && err "$@") || true; }

usage() {
   msg "Usage:"
   msg " Launch applications: $program_name ${Grn}app_1${Nc} ${Grn}app_2${Nc} ${Grn}app_3${Nc} ${Grn}[...]${Nc}"
   msg " Other functionality: $program_name ${Grn}[option]${Nc}"
   msg "  The options are:"
   msg "   ${Grn}list${Nc}             List all applications available to launch"
   msg "   ${Grn}help${Nc}             Print this help menu"
   msg
   msg "Example:"
   msg " $program_name bespokesynth ardour carla     # Start bespokesynth, ardour, and carla"
   msg
   msg "Check $homepage for updates"
   exit "$1"
}

version() {
   msg "$program_name v$program_ver"
   msg "Check $homepage for updates"
   exit "$1"
}

# Extract the list of applications from flake.nix
pkgs_list_available() {
   # Download the
   curl -sSL "$pkg_list_url" | # Get the script from the repository
      sed -n /"$application_list_name"' =.\+\[$/,/\];/{ :loop; N; /\];/!{b loop}; p; q; }' | # Select the application list
      grep -o '\w\+$' # Select the lines with list elements on them
}

# Prints a list of all unavailable packages passed to it
pkgs_is_available() {
   all_pkgs="$(pkgs_list_available)"
   while ! test $# = 0; do
      echo "$all_pkgs" | grep -Fx "$1" > /dev/null || printf '  %s\n' "$1"
      shift
   done
}

# returns true if you are root
am_i_root() { test "$(id -u)" = 0; }

# Checks if a command exists
command_exists() { command -v "$1" > /dev/null; }

# Get some colors for ~flare~
Red='' Ylw='' Nc='' Grn='' Nc='';:
# Colors for stdout
if test -t 1; then
   if command_exists tput; then
      Grn="$(tput setaf 2)" Nc="$(tput sgr0)";:
   else
      Grn='[32m' Nc='(B[m';:
   fi
fi
# Colors for stderr
if test -t 2; then
   if command_exists tput; then
      Red="$(tput setaf 1)" Ylw="$(tput setaf 3)" Nc="$(tput sgr0)";:
   else
      Red='[31m' Ylw='[33m' Nc='(B[m';:
   fi
fi

# Warn if running as root
if am_i_root; then
   err "${Ylw}Warning:${Nc} This script does not need to be run as root."
   sleep 2
fi

# Test if curl exists
if ! command_exists curl; then
   err "${Red}Error:${Nc} \`curl\` does not exist or could not be found in $PATH. Please install curl and try again." >&2
   exit 1
fi

# Check if no arguments are passed
if test $# = 0; then
   err "${Red}Error:${Nc} Please provide an option or a list or applications."
   usage 1
fi

# Very simple command line argument parsing
case "$1" in
   list) msg "Available packages:"; pkgs_list_available | sort | sed 's/^/  /'; exit;;
   -h|--help|help) usage 0;;
   -v|--version|version) version 0;;
   # Don't allow packages that start with a '-' so grep doesn't complain
   -*) err "${Red}Error:${Nc} option $1 does not exist."; err "See \`$program_name help\` for a list of all options."; exit 1;;
esac

# Exit if any unavailable applications were requested
unavailable="$(pkgs_is_available "$@")"
if [ -n "$unavailable" ]; then
   msg "${Red}Error:${Nc} Some of the requested packages are not available:"
   msg "$unavailable"
   msg "See $program_name --list for a list of all available applications"
   exit 1
fi

# Find or get nix-portable, or select the system version of nix
if command_exists nix && ! "$FORCE_NIX_PORTABLE"; then
   dbg '`nix` command detected, using it'
   nix='nix --extra-experimental-features flakes --extra-experimental-features nix-command'

elif command_exists nix-portable; then  # check if nix-portable is in $PATH
   nix="nix-portable nix"

# Check if we haven't yet downloaded nix-portable
elif ! test -x "$nix_portable_location"; then
   # Get nix-portable from GitHub releases
   msg '`nix-portable` not found locally, downloading from github releases...'
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
   msg "Running ${Grn}$package${Nc} with nix…"
   # arguments are quoted here because zsh doesn't like having the pound sign unescaped in some cases
   eval "$nix run '$flake#$package'" &
done
wait
