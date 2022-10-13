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

set -eux

# Helper functions for printing information
msg() { echo "$@"; }
err() { msg  "$@" >&2; }
dbg() { ("${DEBUG:-false}" && err "$@" >&2) || true; }

# Get what package to run from the user
if test -z "${1:-}"; then
   err 'Error: Please specify an application to run. Look near the bottom flake.nix file for a list of applications, like ardour.' >&2
   exit 1
fi

PACKAGE="$1"

# Version of nix-portable to pull from nix-portable releases page
NIX_PORTABLE_VERSION=v009

# Get the directory the script is in
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
NIX_LOCATION="$SCRIPT_DIR/nix-portable"

# Nix flake to run - TODO: figure out how to make this point to codeberg
FLAKE='github:PowerUser64/universal-studio'

# Test if curl exists
if ! command -v curl > /dev/null; then
   err 'Error: `curl` does not exist or could not be found in $PATH. Please install curl and try again.' >&2
fi

# Find nix-portable if we already have it or select the system version of nix
if command -v nix > /dev/null && ! "${FORCE_NIX_PORTABLE:-false}"; then
   dbg '`nix` command detected, using it'
   NIX='nix --extra-experimental-features flakes --extra-experimental-features nix-command'
elif command -v nix-portable > /dev/null; then
   NIX="nix-portable nix"
elif ! test -x "$NIX_LOCATION"; then  # Check if nix-portable already exists and is executable
   # Get nix-portable from github releases
   msg '`nix-portable` not found, downloading from github releases...'
   # quoting the arguments here because zsh doesn't like the pound sign
   # shellcheck disable=SC2026
   curl -sSLo "$NIX_LOCATION" https://github.com/DavHau/nix-portable/releases/download/"$NIX_PORTABLE_VERSION"/nix-portable
   chmod +x "$NIX_LOCATION"
   NIX="$NIX_LOCATION nix"
else
   NIX="$NIX_LOCATION nix"
fi

if "${FORCE_NIX_PORTABLE:-false}"; then
   dbg "Forcing nix portable"
fi

dbg "nix command is $NIX"
msg "Running $PACKAGE with nix…"
eval "$NIX run '$FLAKE#$PACKAGE'"
