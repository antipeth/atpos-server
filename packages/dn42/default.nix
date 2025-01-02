{
  config,
  pkgs,
  host,
  ...
}:
{
  imports = [
    ./wireguard.nix
  ];
}
