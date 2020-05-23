{ modules, testedAttrPath, tests, pkgs, lib ? pkgs.lib }:

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

  list = pkgs.runScript "nmt-list-tests" ''
    touch $out

    ${lib.concateStringsSep "\n" (map (n: ''
      echo ${n}
      echo ${n} >> $out
     '') (lib.attrNames tests))}
  '';
}
