{
  config,
  pkgs,
  host,
  ...
}:
{
  networking.wireguard.interfaces.dn42-peer = {
    privateKey = "QFfBB+y4Qms6V8IV/sdoZZthh2GBMeYQzkEKVMPGmH4=";
    allowedIPsAsRoutes = false;
    listenPort = 40003;
    peers = [
      {
        publicKey = "+Bz9Xgjauqj0BoFAyk0lZL/0bernO3ra4mdXZRtlCl8=";
        allowedIPs = [ "0.0.0.0/0" "::/0" ];
        endpoint = "74.48.189.174:40003";
      }
    ];
    postSetup = ''
      ${pkgs.iproute2}/bin/ip addr add fe80::b72b/64 dev dn42-peer
      ${pkgs.iproute2}/bin/ip addr add fd25:5547:5a89::1/128 dev dn42-peer
      ${pkgs.iproute2}/bin/ip addr add 172.20.192.2/32 peer 172.20.192.1/32 dev dn42-peer
    '';
  };

  networking.firewall = {
    allowedTCPPorts = [ 40003 ];
    allowedUDPPorts = [ 40003 ];
  };
}
