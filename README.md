# Universal Studio

**Project status:** *beta* - feel free to test this project. "It works on my
machine, let me know if it doesn't work on yours."

<!--                  do not break the river please :)                      -->
Universal Studio is an audio production environment for Linux, built to enable
collaborative audio production across distributions and environments. Included
in this is a broad selection of DAW's, plugins, and collaboration tools.
Although this project was initially built to enable the Linux audio community
to more easily tackle collaborative challenges like [Server vs
Server](https://www.servervsserver.com/), it's also quite suitable as a place
to start for anyone who is looking to use Linux for audio production.
<!-- What's a river? Read this: https://w.wiki/44aF                         -->

## Usage

This project contains a script called `universal-launcher` that can be used to
launch any program it provides. To get `universal-launcher`, execute this:

```bash
curl -sSLo universal-launcher https://codeberg.org/PowerUser/universal-studio/raw/branch/main/universal-launcher.sh
chmod +x universal-launcher
./universal-launcher ardour
```

After a moment, Ardour should launch. Replace `ardour` with another application
listed in `flake.nix` to launch a different one instead. Please note that
everything will need to be download the first time you use it, so the first run
will take longer than usual.

## FAQ

### What does `universal-launcher` do?

Universal launcher works in one of two ways, depending on whether you have the
`nix` command already. If you have the command, it runs the project as a flake,
using the system version of `nix`. If you don't have the `nix` command, it
downloads a static `nix` binary from
[`nix-portable`](https://github.com/DavHau/nix-portable) and then runs the
project in the same way it would if `nix` was already installed. The difference
is `nix-portable` doesn't require privileges to use and isn't as invasive to
get running (it only creates one directory). You can also force it to use
nix-portable by setting `FORCE_NIX_PORTABLE` to `true` before running the
script, or set it inside the script.

### How do I completely remove this from my system?

How you remove this depends on whether you were using `nix-portable` or `nix`.
Follow the instructions below for whether or not you have nix. If you don't
know whether you are using nix, you probably aren't, but if running `which nix`
in your terminal gives you an error, you aren't using nix.

#### I am not using `nix`

1. Remove the `~/.nix-portable` directory
2. Remove the `nix-portable` binary and the `universal-launcher` script from
   where you are storing them.

#### I am using `nix`

If you are using `nix`, you should look into the `nix-collect-garbage` command,
which you can learn about in the [nix
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
repository. Huge props to @pacew and @JohnTheBard for their hard work on the
project.
