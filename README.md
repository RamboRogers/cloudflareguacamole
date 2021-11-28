# Zero Trust Cloudflare Guacamole Instant Docker

This is a formula for instantly building a secure zero trust [Guacamole](https://guacamole.apache.org) instance connected through [Cloudflare Teams](https://www.cloudflare.com/teams/remote-workforces/) and protected by the [Zero Trust Network Access](https://www.cloudflare.com/teams/zero-trust-network-access/) (ZTNA).  This is a proof on concept configuration for testing, it implements full zero trust.  You cannot access this Guacamole instance outside of the authenication policies defined in the Cloudflare Teams zero trust design.  If the back end network were compromosed that this docker container is on, this Guacamole host is not directly accessible as the ports are not exposed. 

## This Container

1. Loads the lastest version of Debian
2. Adds the DNS record and routing using Cloudflared
3. Connects to the warp network using Cloudflared
4. Connects to existing Cloudflare Teams using Cloudflared
5. Installs the latest version of Guacamole and Guacd
6. Installs mariadb and configures for Guacamole
7. Install and configures Tomcat with Guacamole client

---

## Prepare

Git clone the repository and configure two files, Dockerfile and config.yml. You'll want to set your timezone, set your Cloudflare Team name, and then the domain you use for your Cloudflare Team.

**config.yml** - Change your domain.
```bash
ingress:
  - hostname: guacamole.yourdomain.com
    service: http://127.0.0.1:8080
  - service: http_status:404
```

**Dockerfile** - Change the timezone and the team name.
```bash
ENV CLOUDFLARETEAM yourcloudflareteamname
ENV TZ America/New_York
```


**Teams Console Setup** - Make sure to [setup your application](https://developers.cloudflare.com/cloudflare-one/applications/configure-apps/self-hosted-apps) in Cloudflare.
Once you've configured your files, you can build the container.  You will need access to the Cloudflare Teams console and the main Cloudflare console as well during this process.  The application name must match the DNS definition for the hostname which is guacamole.

---
## Build and Run
To build this container, simply execute buildrun.sh on a linux or mac docker host. You could also manually execute the docker commands.  During the build the build will pause and provide you with a Cloudflare URL to follow to authorize the Argo tunnel.  Once your approve this tunnel, the build will continue.

```bash
docker build --no-cache -t cloudflareguacamole .
docker run --name cloudflareguacamole --restart always -d cloudflareguacamole
```

You should now have a working Guacamole environment ready for usage from Cloudeflare!  


---
## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)