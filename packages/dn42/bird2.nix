{
  config,
  pkgs,
  host,
  ...
}:
{
  services.bird2 = {
    enable = true;
    checkConfig = false;
    config = ''

define OWNAS =  4242420003;
define OWNIP =  172.20.192.2;
define OWNIPv6 = fd25:5547:5a89::1;
define OWNNET = 172.20.192.0/28;
define OWNNETv6 = fd25:5547:5a89::/48;
define OWNNETSET = [172.20.192.0/28+];
define OWNNETSETv6 = [fd25:5547:5a89::/48+];

router id OWNIP;
protocol device {
    scan time 10;
}

/*
 *  Utility functions
 */

function is_self_net() {
  return net ~ OWNNETSET;
}

function is_self_net_v6() {
  return net ~ OWNNETSETv6;
}

function is_valid_network() {
  return net ~ [
    172.20.0.0/14{21,29}, # dn42
    172.20.0.0/24{28,32}, # dn42 Anycast
    172.21.0.0/24{28,32}, # dn42 Anycast
    172.22.0.0/24{28,32}, # dn42 Anycast
    172.23.0.0/24{28,32}, # dn42 Anycast
    172.31.0.0/16+,       # ChaosVPN
    10.100.0.0/14+,       # ChaosVPN
    10.127.0.0/16+,       # neonetwork
    10.0.0.0/8{15,24}     # Freifunk.net
  ];
}

roa4 table dn42_roa;
roa6 table dn42_roa_v6;

protocol static {
    roa4 { table dn42_roa; };
    include "/etc/bird/roa_dn42.conf";
};

protocol static {
    roa6 { table dn42_roa_v6; };
    include "/etc/bird/roa_dn42_v6.conf";
};

function is_valid_network_v6() {
  return net ~ [
    fd00::/8{44,64} # ULA address space as per RFC 4193
  ];
}

protocol kernel {
    scan time 20;

    ipv6 {
        import none;
        export filter {
            if source = RTS_STATIC then reject;
            krt_prefsrc = OWNIPv6;
            accept;
        };
    };
};

protocol kernel {
    scan time 20;

    ipv4 {
        import none;
        export filter {
            if source = RTS_STATIC then reject;
            krt_prefsrc = OWNIP;
            accept;
        };
    };
}

protocol static {
    route OWNNET reject;

    ipv4 {
        import all;
        export none;
    };
}

protocol static {
    route OWNNETv6 reject;

    ipv6 {
        import all;
        export none;
    };
}

template bgp dnpeers {
    local as OWNAS;
    path metric 1;

    ipv4 {
        import filter {
          if is_valid_network() && !is_self_net() then {
            if (roa_check(dn42_roa, net, bgp_path.last) != ROA_VALID) then {
              # Reject when unknown or invalid according to ROA
              print "[dn42] ROA check failed for ", net, " ASN ", bgp_path.last;
              reject;
            } else accept;
          } else reject;
        };

        export filter { if is_valid_network() && source ~ [RTS_STATIC, RTS_BGP] then accept; else reject; };
        import limit 9000 action block;
    };

    ipv6 {   
        import filter {
          if is_valid_network_v6() && !is_self_net_v6() then {
            if (roa_check(dn42_roa_v6, net, bgp_path.last) != ROA_VALID) then {
              # Reject when unknown or invalid according to ROA
              print "[dn42] ROA check failed for ", net, " ASN ", bgp_path.last;
              reject;
            } else accept;
          } else reject;
        };
        export filter { if is_valid_network_v6() && source ~ [RTS_STATIC, RTS_BGP] then accept; else reject; };
        import limit 9000 action block; 
    };
}


include "/etc/bird/peers/*";
'';
  };
}
