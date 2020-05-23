{ config, lib, pkgs, ... }:

let

  cfg = config.nmt;

  inherit (lib) mkOption types;

in {
  options.nmt = {
    name = mkOption {
      type = types.str;
      internal = true;
      readOnly = true;
      description = "Name of test case.";
    };

    description = mkOption {
      type = types.str;
      default = "";
      description = "Optional description of this test case.";
    };

    script = mkOption {
      type = types.lines;
      example = ''
        assertFileExists home-files/.Xresources
      '';
      description = "Test script.";
    };

    startUpCommands = mkOption {
      type = types.lines;
      default = ''
        out=$out/${cfg.name}
        mkdir -p $out
      '';
      description = "command to run befor the assertions";
    };

    log = mkOption {
      type = types.bool;
      default = true;
      description = "wether to log the assertions to the output";
    };

    inputs = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [ coreutils diffutils findutils gnugrep ];
      description = "packages that are availabe in the test suit";
    };

    toplevel = mkOption {
      type = types.package;
      description = "package to build for the test";
    };
  };

  config = {
    nmt.toplevel = pkgs.runCommand "test-${cfg.name}" {
      inputs = cfg.inputs;
    } ''
      #!${pkgs.bash}/bin/bash
      ${cfg.startUpCommands}

      ${lib.optionalString cfg.log "NMT_LOG=1"} 

      . "${./bash-lib/assertions.sh}"

      ${cfg.script}
    '';
  };
}
