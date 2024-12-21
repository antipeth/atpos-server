{
  config,
  pkgs,
  host,
  ...
}:
{
  imports = [
    ./hardware.nix
    ../../packages/syncthing.nix
    ../../packages/caddy.nix
    # ../../packages/netdata.nix
    # ../../packages/traefik.nix
  ];

  boot = {
    # Kernel
    kernelPackages = pkgs.linuxPackages_zen;
    kernelModules = [ "tcp_bbr" ];

    kernel = {
      sysctl = {
        "net.ipv4.tcp_congestion_control" = "bbr";
        "net.core.default_qdisc" = "fq";
        "net.core.wmem_max" = 1073741824;
        "net.core.rmem_max" = 1073741824;
        "net.ipv4.tcp_rmem" = "4096 87380 1073741824";
        "net.ipv4.tcp_wmem" = "4096 87380 1073741824";
      };
    };
 
    # Bootloader.
    # loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    loader.grub = {
      enable = true;
      device = "/dev/vda";
      useOSProber = true;
    };
    # Make /tmp a tmpfs
    tmp = {
      useTmpfs = false;
      tmpfsSize = "30%";
    };
  };

  swapDevices = [{ device = "/swapfile"; size = 2075; }];
  # Enable networking
  networking.hostName = host;
    networking = {
    usePredictableInterfaceNames = false;
    interfaces.eth0.ipv4.addresses = [
      {
        address = "142.171.85.245";
        prefixLength = 26;
      }
    ];
    defaultGateway = {
      address = "142.171.85.193";
      interface = "eth0";
    };
    interfaces.eth0.ipv6.addresses = [
      {
        address = "2607:f130:0:16d::87c0:3482";
        prefixLength = 64;
      }
    ];
    defaultGateway6 = {
      address = "2607:f130:0:16d::1";
      interface = "eth0";
    };
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
      "2606:4700:4700::1111"
      "2001:4860:4860::8888"
    ];
  };

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  nixpkgs.config.allowUnfree = true;

  users = {
    mutableUsers = false;
    users.root = {
      hashedPassword = "$y$j9T$p82ajC6GM3YheN88bq.cP/$.Y9XkDToYGukBt24CkzKCcH5Xq9ogjh6mGpoS2litQ7";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINkg2UubcWG09dZbAOudxetJPC0Sgk2JM2uUCLEzY8Pv"
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    micro
    wget
    curl
    git
    fastfetch
    lsof
  ];

  environment.variables = {
      # KUBECONFIG = /etc/rancher/k3s/k3s.yaml;
  };

   # Services to start
  services.openssh = {
    enable = true;
    ports = [ 222 ];
    settings = {
      PasswordAuthentication = false;
      AllowUsers = null; # Allows all users by default. Can be [ "user1" "user2" ]
      UseDns = false;
      X11Forwarding = false;
      PermitRootLogin = "yes"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
    };
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  networking.firewall.enable = false;

  system.stateVersion = "24.11";
}
