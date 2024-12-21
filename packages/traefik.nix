{
  config,
  pkgs,
  host,
  ...
}:
{
  services.traefik = {
    enable = true;

    staticConfigOptions = {
      # log = {
        # level = "INFO";
        # filePath = "${config.services.traefik.dataDir}/traefik.log";
        # format = "json";
      # };
      entryPoints = {
        # web = {
        #   address = ":80";
        # };
        websecure= {
          address = ":443";
	      # http.tls.certResolver = "myresolver";
        };
      };

      certificatesResolvers.myresolver.acme = {
	      tlschallenge = true;
        email = "youremail@domain.com";
        storage = "${config.services.traefik.dataDir}/acme.json";
        # httpChallenge.entryPoint = "web";
      };

      api.dashboard = true;
      # Access the Traefik dashboard on <Traefik IP>:8080 of your server
      api.insecure = true;
    };
    dynamicConfigOptions = {
      http = {
        routers = {
          syncthing = {
	          entryPoints = [ "websecure" ];
            rule = "Host(`1.example.com`)";
            service = "syncthing";
	          tls.certresolver = "myresolver";
          };
          netdata = {
	          entryPoints = [ "websecure" ];
            rule = "Host(`2.example.com`)";
            service = "netdata";
	          tls.certresolver = "myresolver";
          };
          alist = {
	          entryPoints = [ "websecure" ];
            rule = "Host(`3.example.com`)";
            service = "alist";
	          tls.certresolver = "myresolver";
          };
        };
        services = {
          syncthing = {
            loadBalancer = {
              servers = [
                {
                  url = "http://localhost:8384";
                }
              ];
            };
          };
          netdata = {
            loadBalancer = {
              servers = [
                {
                  url = "http://localhost:19999";
                }
              ];
            };
          };
          alist = {
            loadBalancer = {
              servers = [
                {
                  url = "http://localhost:5244";
                }
              ];
            };
          };
        };
      };
    };
  };
}

