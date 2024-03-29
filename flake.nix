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
        # Applications to make available through `nix run` and such
        Apps = with pkgs; [

          #######################
          ###       DAW       ###
          #######################

          ardour
          audacity
          bespokesynth
          carla
          raysession
          zrythm

          #######################
          ###  Miscellaneous  ###
          #######################

          sonobus
          syncthing

        ];
        # Plugins to load (lv2/…)
        Plugins = with pkgs; [

          ######################
          ###  Plugin packs  ###
          ######################

          # dpf-plugins  # not in repos yet
          # wolf-spectrum  # not in repos yet
          airwindows-lv2
          calf
          cmt
          distrho
          gxplugins-lv2
          infamousPlugins
          lsp-plugins
          mda_lv2
          swh_lv2
          tap-plugins
          x42-plugins
          zam-plugins

          # b.music
          bchoppr
          bjumblr
          boops
          bschaffl
          bsequencer
          bslizr

          ######################
          ###  Noise makers  ###
          ######################

          # General-purpose
          # vital
          cardinal
          helm
          odin2
          surge-XT
          zynaddsubfx

          # Sound fonts
          sfizz
          fluidsynth
          x42-gmsynth
          ninjas2

          # Specialized
          sorcer

          # Drums
          ChowKick
          geonkick
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
          ChowPhaser

          # Distortion
          CHOWTapeModel
          ChowCentaur
          fire
          wolf-shaper

          ######################
          ###   Misc Other   ###
          ######################

          sonobus
          carla
          stochas

        ];
        # lv2_path will look like:
        # ${helm}/lib/lv2:$HOME/.lv2:$HOME/.nix-profile/lib/lv2:/run/current-system/sw/lib/lv2
        # this is just more general to loop over all plugins as makeSearchPath adds lib/lv2 to all
        # outputs and concat them with a colon in between as explained in:
        # https://nixos.org/manual/nixpkgs/stable/#function-library-lib.strings.makeSearchPath
        lv2_path    = (lib.makeSearchPath "lib/lv2"    Plugins);
        clap_path   = (lib.makeSearchPath "lib/clap"   Plugins);
        vst3_path   = (lib.makeSearchPath "lib/vst3"   Plugins);
        vst_path    = (lib.makeSearchPath "lib/vst"    Plugins);
        lxvst_path  = (lib.makeSearchPath "lib/lxvst"  Plugins);
        ladspa_path = (lib.makeSearchPath "lib/ladspa" Plugins);
        dssi_path   = (lib.makeSearchPath "lib/dssi"   Plugins);
        wrapProgram = { programToWrap, filesToWrap ? "*" }: pkgs.runCommand
          # name of the program, like ardour-with-plugins-6.9
          (programToWrap.pname + "-with-plugins-" + programToWrap.version)
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
      {
        # Executed by `nix build .#<name>`
        packages = flake-utils.lib.flattenTree {
          # This creates an entry self.packages.${system}.ardour with the wrapped program.
          ardour       = wrapProgram { programToWrap = pkgs.ardour      ; };
          audacity     = wrapProgram { programToWrap = pkgs.audacity    ; };
          bespokesynth = wrapProgram { programToWrap = pkgs.bespokesynth; };
          carla        = wrapProgram { programToWrap = pkgs.carla       ; };
          zrythm       = wrapProgram { programToWrap = pkgs.zrythm      ; };
          raysession   = pkgs.raysession; # raysession doesn't need all the other packages
        };
        # Executed by `nix run .#<name>`
        apps = {
          ardour       = { type = "app"; program = "${self.packages.${system}.ardour}/bin/ardour8"           ; };
          audacity     = { type = "app"; program = "${self.packages.${system}.audacity}/bin/audacity"        ; };
          bespokesynth = { type = "app"; program = "${self.packages.${system}.bespokesynth}/bin/BespokeSynth"; };
          carla        = { type = "app"; program = "${self.packages.${system}.carla}/bin/carla"              ; };
          zrythm       = { type = "app"; program = "${self.packages.${system}.zrythm}/bin/zrythm"            ; };
          raysession   = { type = "app"; program = "${self.packages.${system}.raysession}/bin/raysession"    ; };
          sonobus      = { type = "app"; program = "${self.packages.${system}.sonobus}/bin/sonobus"          ; };
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
