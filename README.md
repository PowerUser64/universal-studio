# Universal Studio

**Project status:** *beta* - feel free to test this project. It works on my
machine, let me know if it works on yours.

Universal Studio is an audio production environment for Linux, built to enable
collaborative audio production across distributions and environments. Included
in this is a broad selection of DAW's, plugins, and collaboration tools.
Although this project was initially built to enable [unfa](https://unfa.xyz)'s
Linux audio community to more easily tackle collaborative challenges like
[Server vs Server](https://www.servervsserver.com/), it is also suitable as an
easy starting ground for Linux audio production.

## Usage

This project contains a script called `universal-launcher` that can be used to
launch any program it provides. To get `universal-launcher`, execute this:

```bash
curl -sSLo universal-launcher https://codeberg.org/PowerUser/universal-studio/raw/branch/main/universal-launcher.sh
chmod +x universal-launcher
```

Now, you can run `./universal-launcher ardour` to launch Ardour; or replace
`ardour` with another application listed in `flake.nix` to launch it instead.
Note that the script might take a little longer than usual to run programs the
first time you launch them.

## FAQ

### What does `universal-launcher` do?

Universal launcher works in one of two ways, depending on whether you have the
`nix` command already. If you have the command, it runs the project as a flake,
using the system version of `nix`. If you don't have the `nix` command, it
downloads a static `nix` binary from a project called
[`nix-portable`](https://github.com/DavHau/nix-portable), which it then uses to
run the project as a nix flake, just as it would if you already had the `nix`
command. The difference is it doesn't require privileges to use and it isn't
invasive to get running.

### How do I completely remove this from my system?

How you remove this depends on whether you were using `nix-portable` or `nix`.
To find out, simply type `which nix` into your terminal. If this gives you an
error, you are not using `nix`.

#### I do not have `nix` installed

1. Remove the `~/.nix-portable` directory
2. Remove the `nix-portable` binary and the `universal-launcher` script from
   where you are storing them.

#### I have `nix` installed

If you already have `nix`, you should look into the `nix-collect-garbage`
command, which you can learn about in the [nix
manual](https://nixos.org/manual/nix/stable/command-ref/nix-collect-garbage.html).

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
