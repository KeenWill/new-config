{ lib, pkgs, ... }: 
let 
    root = "/tank/htpc";
    tz = "America/New_York";
    
    puid=1000;
    pgid=100; 
in
{
  config.project.name = "htpc-download-box";
#   config.networks = {
#     traefik-custom = {
#       name = "traefik-custom";
#       ipam = {
#         config = [{
#           subnet = "172.32.0.0/16";
#           gateway = "172.32.0.1";
#         }];
#       };
#     };
#   };
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
        network_mode = "host";
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
        network_mode = "host";
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
        network_mode = "host";
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
        network_mode = "host";
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
        network_mode = "host";
      };
    };

    plex-server = {
      service = {
        container_name = "plex-server";
        image = "plexinc/pms-docker:latest";
        restart = "unless-stopped";
        environment = { 
            PUID = puid;
            PGID = pgid;
            TZ = tz;
        };
        volumes = [ 
            "${root}/config/plex/db:/config" # plex database
            "${root}/config/plex/transcode:/transcode" # temp transcoded files
            "${root}/complete:/data" # media library
        ];
        network_mode = "host";
      };
    };

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
        network_mode = "host";
      };
    };
  };
}