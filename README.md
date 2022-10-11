# Universal Studio

**Project status:** *alpha* - feel free to test this project. It works on my
machine, let me know if it works on yours.

Universal Studio is an audio production environment for Linux, built to enable
collaborative audio production. Included in this is a selection of DAW's,
plugins, and collaboration tools. Although this project was initially built to
enable [unfa](https://unfa.xyz)'s Linux audio community to more easily tackle
collaborative challenges like [Server vs
Server](https://www.servervsserver.com/), it is suitable as an easy starting
ground for Linux audio production.

## Usage

1. [Install Nix](https://nixos.wiki/wiki/Nix_Installation_Guide)
2. Run this: <!-- TODO: figure out how to simplify this to `nix run 'codeberg:universal-studio`-->

```bash
nix --extra-experimental-features flakes --extra-experimental-features nix-command run 'https://codeberg.org/PowerUser/universal-studio#ardour'
```

You should now see Ardour and have some audio plugins ready to use. To run
other packages included in this suite, replace `ardour` at the end of the
command with any of the other apps listed in the [`apps`
list](https://codeberg.org/PowerUser/universal-studio/src/branch/main/flake.nix#L146),
within `flake.nix`.

> Note: to shorten this command, you can follow the instructions
[here](https://nixos.wiki/wiki/Flakes#Enable_flakes), which will allow you to
ommit the two `--extra-experimental-features` flags.

## Credits

NixOS forum - Huge thank you to
[@tobiasBora](https://discourse.nixos.org/u/tobiasBora) on the NixOS forum for
helping get this project started in nix. You can read our forum post
[here](https://discourse.nixos.org/t/22191).

[pacew/unfatarians-studio](https://codeberg.org/pacew/unfatarians-studio) -
This is the beginning of this project, as a docker image. Developing it as a
docker image proved to have a number of unforeseen challenges, and in the
process of researching alternatives, I discovered nix. Since it was such a big
swing in how the project worked, I decided it would be best to put it in a new
repository.
