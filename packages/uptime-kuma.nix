{
  config,
  pkgs,
  host,
  ...
}:
{
  services.uptime-kuma = {
    enable = true;
  };
}
