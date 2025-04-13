{
  description = "A remote gaming module based on KDE Plasma and Sunshine";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosModules = {
      hybrid-remote = import ./module.nix;
    };
  };
}
