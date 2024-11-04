{
  description = "atp server nixos k3s";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      host = "test";
    in
    {
      nixosConfigurations = {
        "${host}" = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit system;
            inherit host;
          };
          modules = [
            ./hosts/${host}/config.nix
            inputs.disko.nixosModules.disko
          ];
        };
      };
      packages.${system} = {
        image = self.nixosConfigurations.${host}.config.system.build.diskoImages;
      };
    };
}
