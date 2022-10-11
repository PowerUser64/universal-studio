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
        # TODO: figure out how to use this
        # Applications to install
        # myApplications = with pkgs; [
        #
        #   ######################
        #   ###      DAW       ###
        #   ######################
        #
        #   ardour
        #   audacity
        #   bespokesynth
        #   carla
        #   zrythm
        #
        # ];
        # Plugins to load (lv2/…)
        myPlugins = with pkgs; [

          ######################
          ###  Plugin packs  ###
          ######################

          # dpf-plugins  # not in repos yet
          # wolf-spectrum  # not in repos yet
          airwindows-lv2
          calf
          distrho
          gxplugins-lv2
          infamousPlugins
          lsp-plugins
          mda_lv2
          swh_lv2
          tap-plugins
          x42-plugins
          zam-plugins

          ######################
          ###  Instruments   ###
          ######################

          # General-purpose
          cardinal
          odin2
          surge-XT
          x42-gmsynth

          # Specialized synths
          sorcer

          # Drum synths
          ChowKick
          geonkick
          helm
          x42-avldrums

          ######################
          ###    Effects     ###
          ######################

          # Reverb
          aether-lv2
          dragonfly-reverb
          zita-convolver

          # Filtering
          diopser
          noise-repellent
          rnnoise-plugin
          wolf-shaper

          # Misc. Processing
          CHOWTapeModel
          ChowCentaur
          ChowPhaser

        ];
        # lv2_path will look like:
        # ${helm}/lib/lv2:$HOME/.lv2:$HOME/.nix-profile/lib/lv2:/run/current-system/sw/lib/lv2
        # this is just more general to loop over all plugins as makeSearchPath adds lib/lv2 to all
        # outputs and concat them with a colon in between as explained in:
        # https://nixos.org/manual/nixpkgs/stable/#function-library-lib.strings.makeSearchPath
        # TODO READER: you should do the same for all other plugin formats, this is left as an
        #              exercice for the reader ;-)
        lv2_path    = (lib.makeSearchPath "lib/lv2"    myPlugins);
        clap_path   = (lib.makeSearchPath "lib/clap"   myPlugins);
        vst3_path   = (lib.makeSearchPath "lib/vst3"   myPlugins);
        vst_path    = (lib.makeSearchPath "lib/vst"    myPlugins);
        lxvst_path  = (lib.makeSearchPath "lib/lxvst"  myPlugins);
        ladspa_path = (lib.makeSearchPath "lib/ladspa" myPlugins);
        dssi_path   = (lib.makeSearchPath "lib/dssi"   myPlugins);
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
              makeWrapper "$file" "$out/bin/$filename"  \
                --prefix LV2_PATH    : "${lv2_path}"    \
                --prefix CLAP_PATH   : "${clap_path}"   \
                --prefix VST3_PATH   : "${vst3_path}"   \
                --prefix VST_PATH    : "${vst_path}"    \
                --prefix LXVST_PATH  : "${lxvst_path}"  \
                --prefix LADSPA_PATH : "${ladspa_path}" \
                --prefix DSSI_PATH   : "${dssi_path}"   ;
            done
          '';
      in
      rec {
        # Executed by `nix build .#<name>`
        packages = flake-utils.lib.flattenTree {
          # This creates an entry self.packages.${system}.ardour with the wrapped program.
          ardour       = wrapMyProgram { programToWrap = pkgs.ardour      ; };
          audacity     = wrapMyProgram { programToWrap = pkgs.audacity    ; };
          bespokesynth = wrapMyProgram { programToWrap = pkgs.bespokesynth; };
          carla        = wrapMyProgram { programToWrap = pkgs.carla       ; };
          zrythm       = wrapMyProgram { programToWrap = pkgs.zrythm      ; };
        };
        # Executed by `nix run .#<name>`
        apps = {
          ardour       = { type = "app"; program = "${self.packages.${system}.ardour}/bin/ardour6"           ; };
          audacity     = { type = "app"; program = "${self.packages.${system}.audacity}/bin/audacity"        ; };
          bespokesynth = { type = "app"; program = "${self.packages.${system}.bespokesynth}/bin/BespokeSynth"; };
          carla        = { type = "app"; program = "${self.packages.${system}.carla}/bin/carla"              ; };
          zrythm       = { type = "app"; program = "${self.packages.${system}.carla}/bin/zrythm"             ; };
        };
        # Used by `nix develop` (not really needed if you use nix run)
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            self.packages.${system}.ardour
            self.packages.${system}.audacity
            self.packages.${system}.bespokesynth
            self.packages.${system}.carla
            self.packages.${system}.zrythm
          ];
        };
      }
    );
}
