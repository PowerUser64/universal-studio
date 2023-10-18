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

This project contains a script called `universal-studio` that can be used to
launch any program it provides. To get `universal-studio`, execute this:

```bash
curl -sSLo universal-studio https://codeberg.org/PowerUser/universal-studio/raw/branch/main/universal-studio.sh
chmod +x universal-studio
./universal-studio ardour
```

After a moment, Ardour should launch. Replace `ardour` with another application
listed in `flake.nix` to launch a different one instead. Please note that
everything will need to be download the first time you use it, so the first run
will take longer than usual.

## Links

* [Codeberg (Main repository)](https://codeberg.org/PowerUser/universal-studio)
* [GitHub (Mirror)](https://github.com/PowerUser64/universal-studio)
* Support the project - [Liberapay](https://liberapay.com/PowerUser/)

<!--
## Versioning
IDEA ONE:
This project follows [semantic versioning](https://semver.org/), but it's worth
explaining for what reason different numbers will go up, so here's an overview.

Take for example this version code: `v0.1.2`. This is what the numbers mean:

- The `v` simply indicates you are looking at a version code.
- The `0` indicates major, potentially breaking changes since the last
  version.\
  Example:
  - Updating to the latest version of the distributed packages.
- The `1` indicates additions to the project that shouldn't break existing
  functionality.\
  Examples:
  - A command-line option is added to `universal-studio.sh`.
  - A package is added without updating existing ones.
- The `2` indicates small changes.\
  Example:
  - A bug fix to `universal-studio.sh`.
  - A broken package is updated.

IDEA TWO:
Have two version numbers, one for universal-studio and the other for the
software packages.

IDEA THREE:
Use a date to indicate versions. - Simple but doesn't communicate a whole lot
of useful information.
-->

## Contributing

Feel free to do any of the things in the [TODO](#TODO) section yourself and
submit a pull request! If you want a package, first search for it on
[search.nixos.org](https://search.nixos.org/packages?channel=unstable). If you
don't find it, please make a packaging request at the [nix package
repository](https://github.com/NixOS/nixpkgs/). If you do find it, please open
an issue to request the package or add it yourself and submit a pull request.

<!-- TODO: Move TODO list below the FAQ -->
## TODO

<!-- Hidden TODO list:
Empty!
-->

<!-- **Software distribution:**

* [ ] Ensure all nix packages we use are up-to-date
* Update nix packages that need it
  * [x]
* Add wanted and missing packages to the nix package repository
  * Plugins
    * [ ] Wolf Shaper
    * [ ] DPF Plugins
    * [ ] OneTrick Simian
  * Programs
    * [ ] [RaySession](https://github.com/NixOS/nixpkgs/issues/194022)
    * [X] [Patchance](https://github.com/NixOS/nixpkgs/issues/194023) - WIP -->

<!-- **Interface:**

* [x] Add options to `universal-studio`
  * [x] `list` to show what packages can be launched
* [x] Make an option in `universal-studio` to start
  [Syncthing](https://syncthing.net/) -->

<!-- **Housekeeping:** -->

* Beautify readme
  * [ ] Banner
  * [ ] Badges
  * [ ] Blazingly fast
  * Other trendy things

## FAQ
<!-- TODO: add emojis to the questions so they stand out -->
### What does `universal-studio` do?

Universal launcher works in one of two ways, depending on whether you have the
`nix` command already. If you have the `nix` command, it runs the project as a
flake, using the system version of `nix`. If you don't have the `nix` command,
it downloads a static `nix` binary from
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
2. Remove the `nix-portable` binary and the `universal-studio` script from
   where you are storing them.

#### I am using `nix`

If you are using `nix`, you should look into the `nix-collect-garbage` command,
which you can learn about in the [nix
manual](https://nixos.org/manual/nix/stable/command-ref/nix-collect-garbage.html).

## Credits

Huge credit to [@tobiasBora](https://discourse.nixos.org/u/tobiasBora) on
the NixOS forum for helping get this project started in nix. You can read our
forum post [here](https://discourse.nixos.org/t/22191). This project would not
have been possible without his support.

[pacew/unfatarians-studio](https://codeberg.org/pacew/unfatarians-studio) -
This is the beginning of this project, as a docker image. Developing it as a
docker image proved to have a number of unforeseen challenges, and in the
process of researching alternatives, I discovered nix. Since it was such a big
swing in how the project worked, I decided it would be best to put it in a new
repository. Huge props to @pacew and @JohnTheBard for all their hard work on
the project.

<!-- vim: sw=2 ts=2
-->
