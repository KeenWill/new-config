{ lib, pkgs, ... }: 
let 
    root = "/tank/htpc";
    tz = "America/New_York";
    
    puid=1000;
    pgid=100; 
in
{
  config.project.name = "htpc-download-box";
  config.networks = {
    htpc = {
      name = "htpc";
      ipam = {
        config = [{
          subnet = "172.32.100.0/24";
          gateway = "172.32.100.1";
        }];
      };
    };
  };
  config.services = {
    deluge = {
      service = {
        container_name = "deluge";
        image = "linuxserver/deluge:latest";
        restart = "unless-stopped";
        environment = { 
            PUID = puid;
            PGID = pgid;
            TZ = tz;
        };
        volumes = [ 
            "${root}/downloads:/downloads" # downloads folder
            "${root}/config/deluge:/config" # config files
        ];
        ports = [
            "8112:8112"
            "6881:6881"
            "6881:6881/udp"
            "58846:58846"
        ];
        networks = ["htpc"];
      };
    };

    jackett = {
      service = {
        container_name = "jackett";
        image = "linuxserver/jackett:latest";
        restart = "unless-stopped";
        environment = { 
            PUID = puid;
            PGID = pgid;
            TZ = tz;
        };
        volumes = [ 
            "/etc/localtime:/etc/localtime:ro"
            "${root}/downloads/torrent-blackhole:/downloads" # place where to put .torrent files for manual download
            "${root}/config/jackett:/config" # config files
        ];
        ports = [ "9117:9117" ];
        networks = ["htpc"];
      };
    };

    nzbget = {
      service = {
        container_name = "nzbget";
        image = "linuxserver/nzbget:latest";
        restart = "unless-stopped";
        environment = { 
            PUID = puid;
            PGID = pgid;
            TZ = tz;
        };
        volumes = [ 
            "${root}/downloads/downloads" # download folder
            "${root}/config/nzbget:/config" # config files
        ];
        ports = [ "6789:6789" ];
        networks = ["htpc"];
      };
    };

    sonarr = {
      service = {
        container_name = "sonarr";
        image = "linuxserver/sonarr:latest";
        restart = "unless-stopped";
        environment = { 
            PUID = puid;
            PGID = pgid;
            TZ = tz;
        };
        volumes = [ 
            "/etc/localtime:/etc/localtime:ro"
            "${root}/config/sonarr:/config" # config files
            "${root}/complete/tv:/tv" # tv shows folder
            "${root}/downloads:/downloads" # download folder
        ];
        ports = [ 
            "8989:8989"
        ];
        networks = ["htpc"];
      };
    };

    radarr = {
      service = {
        container_name = "radarr";
        image = "linuxserver/radarr:latest";
        restart = "unless-stopped";
        environment = { 
            PUID = puid;
            PGID = pgid;
            TZ = tz;
        };
        volumes = [ 
            "/etc/localtime:/etc/localtime:ro"
            "${root}/config/radarr:/config" # config files
            "${root}/complete/movies:/movies" # movies folder
            "${root}/downloads:/downloads" # download folder
        ];
        ports = [ "7878:7878" ];
        networks = ["htpc"];
      };
    };

    # plex-server = {
    #   service = {
    #     container_name = "plex-server";
    #     image = "linuxserver/plex:latest";
    #     restart = "unless-stopped";
    #     environment = { 
    #         PUID = puid;
    #         PGID = pgid;
    #         TZ = tz;
    #         VERSION = "docker";
    #         PLEX_CLAIM = "claim-fUUAqeFd8wPgy73c1M1Y";
    #     };
    #     volumes = [ 
    #         "${root}/config/plex:/config" # plex config
    #         "${root}/complete/movies:/movies"
    #         "${root}/complete/tv:/tv"
    #     ];
    #     ports = [
    #         "32400:32400/tcp"
    #         "8324:8324/tcp"
    #         "32469:32469/tcp"
    #         "1900:1900/udp"
    #         "32410:32410/udp"
    #         "32412:32412/udp"
    #         "32413:32413/udp"
    #         "32414:32414/udp"
    #     ];
    #     networks = ["htpc"];
    #   };
    # };

    bazarr = {
      service = {
        container_name = "bazarr";
        image = "linuxserver/bazarr:latest";
        restart = "unless-stopped";
        environment = { 
            PUID = puid;
            PGID = pgid;
            TZ = tz;
            UMASK_SET = "022";
        };
        volumes = [
            "${root}/config/bazarr:/config" # config files
            "${root}/complete/movies:/movies" # movies shows folder
            "${root}/complete/tv:/tv" # tv folder
        ];
        ports = [ "6767:6767" ];
        networks = ["htpc"];
      };
    };
  };
}