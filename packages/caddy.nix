{
  config,
  pkgs,
  host,
  ...
}:
{
  services.caddy = {
    enable = true;
    virtualHosts."example.com"={
    extraConfig = ''
      reverse_proxy localhost:8384 {
          header_up Host {upstream_hostport}
      }
    '';
    };
  };
}
