{
  description = "Audio production environment";

  inputs = {
    nixpkgs = { url = "github:NixOS/nixpkgs/nixpkgs-unstable"; };
    flake-utils = { url = "github:numtide/flake-utils"; };
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        lib = pkgs.lib;
        # Plugins to load (lv2/…)
        myPlugins = [ pkgs.helm ];
        # lv2_path will look like:
        # ${helm}/lib/lv2:$HOME/.lv2:$HOME/.nix-profile/lib/lv2:/run/current-system/sw/lib/lv2
        # this is just more general to loop over all plugins as makeSearchPath adds lib/lv2 to all
        # outputs and concat them with a colon in between as explained in:
        # https://nixos.org/manual/nixpkgs/stable/#function-library-lib.strings.makeSearchPath
        # TODO READER: you should do the same for all other plugin formats, this is left as an
        #              exercice for the reader ;-)
        lv2_path = (lib.makeSearchPath "lib/lv2" myPlugins);
        wrapMyProgram = { programToWrap, filesToWrap ? "*" }: pkgs.runCommand
          # name of the program, like ardour-with-my-plugins-6.9
          (programToWrap.pname + "-with-my-plugins-" + programToWrap.version)
          {
            nativeBuildInputs = with pkgs; [
              makeBinaryWrapper
            ];
            buildInputs = [
              programToWrap
            ];
          }
          ''
            mkdir -p $out/bin
            for file in ${programToWrap}/bin/${filesToWrap};
            do
              filename="$(basename -- $file)"
              # TODO READER: should do the same for all plugins formats (you can have multiple prefix arguments)
              # to see the content of the wrapper to debug, use less as it is in binary format (for compatibility
              # with MacOs)
              makeWrapper "$file" "$out/bin/$filename" \
                --prefix LV2_PATH : "${lv2_path}";
            done
          '';
      in
      rec {
        # Executed by `nix build .#<name>`
        packages = flake-utils.lib.flattenTree {
          # This creates an entry self.packages.${system}.ardour with the wrapped program.
          ardour = wrapMyProgram { programToWrap = pkgs.ardour; };
        };
        # Executed by `nix run .#<name>`
        apps = {
          ardour = {
            type = "app";
            program = "${self.packages.${system}.ardour}/bin/ardour6";
          };
        };
        # Used by `nix develop` (not really needed if you use nix run)
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            self.packages.${system}.ardour
          ];
        };
      }
    );
}
