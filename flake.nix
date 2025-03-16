{
  description = "A remote gaming module based on KDE Plasma and Sunshine";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs }: {
    nixosModules = {
      hybrid-remote = import ./module.nix;
    };
  };
}
