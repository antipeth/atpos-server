{
  config,
  pkgs,
  host,
  ...
}:
{
  services = {
      syncthing = {
          enable = true;
          user = "root";
          dataDir = "/root/Documents";    # Default folder for new synced folders
          configDir = "/root/.config/syncthing";   # Folder for Syncthing's settings and keys
      };
  };
}
