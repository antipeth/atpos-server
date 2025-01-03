{
  config,
  pkgs,
  host,
  ...
}:
{
  imports = [
    ./hardware.nix
    # ../../packages/caddy.nix
    # ../../packages/dn42
    # ../../packages/netdata.nix
    # ../../packages/podman.nix
    # ../../packages/syncthing.nix
    # ../../packages/traefik.nix
    # ../../packages/uptime-kuma.nix
  ];

  boot = {
    # Kernel
    kernelPackages = pkgs.linuxPackages_zen;
    kernelModules = [ "tcp_bbr" ];

    kernel = {
      sysctl = {
        # bbr
        "net.ipv4.tcp_congestion_control" = "bbr";
        "net.core.default_qdisc" = "fq";
        "net.core.wmem_max" = 1073741824;
        "net.core.rmem_max" = 1073741824;
        "net.ipv4.tcp_rmem" = "4096 87380 1073741824";
        "net.ipv4.tcp_wmem" = "4096 87380 1073741824";

        # DN42
        "net.ipv4.ip_forward" = 1;
        "net.ipv6.conf.default.forwarding" = 1;
        "net.ipv6.conf.all.forwarding" = 1;
        "net.ipv4.conf.default.rp_filter" = 0;
        "net.ipv4.conf.all.rp_filter" = 0;
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

  swapDevices = [
    {
      device = "/swapfile";
      size = 2075;
    }
  ];
  # Enable networking
  networking.hostName = host;
  networking = {
    usePredictableInterfaceNames = false;
    interfaces.eth0.ipv4.addresses = [
      {
        address = "103.124.107.65";
        prefixLength = 24;
      }
    ];
    defaultGateway = {
      address = "103.124.107.1";
      interface = "eth0";
    };
    interfaces.eth0.ipv6.addresses = [
      {
        address = "2402:d0c0:10:53cc::1";
        prefixLength = 64;
      }
    ];
    defaultGateway6 = {
      address = "2402:d0c0:10::1";
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
      hashedPassword = "$y$j9T$9MsNIswva2STzSKAuZFVG.$svjTdbWdgqmHkwi5fAx7.HQfYHF9RkUegnu50jhI71C";
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

  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      222
      443
    ];
  };

  system.stateVersion = "24.11";
}
