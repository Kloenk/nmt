{
  description = "This is a basic test framework for projects using the Nixpkgs module system. It is inspired by the nix-darwin test framework.";

  outputs = { self }: {
    lib.nmt = import ./.;
  };
}
