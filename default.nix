{ modules, tests, pkgs, lib ? pkgs.lib }:

let

  evalTest = name: test:
    lib.evalModules {
      modules = let
        initModule = { config, ... }: {
          nmt.name = name;
        };
      in [ initModule ./nmt.nix test ] ++ modules;
    };

  evaluatedTests = lib.mapAttrs evalTest tests;

in rec {
  
  run = evaluatedTests;

  all = pkgs.symlinkJoin {
    name = "all-tests";
    paths  = lib.mapAttrsToList (name: script: script.config.nmt.toplevel) run;
  };

  list = pkgs.runCommand "nmt-list-tests" { } ''
    #!${pkgs.bash}/bin/bash
    touch $out

    ${lib.concatStringsSep "\n" (map (n: ''
      echo ${n}
      echo ${n} >> $out
     '') (lib.attrNames tests))}
  '';
}
