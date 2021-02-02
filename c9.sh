#!/bin/bash
docker run -d \
  --name=cloud9 \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Europe/London \
  -e GITURL=https://github.com/linuxserver/docker-cloud9.git `#optional` \
  #-e USERNAME= `#optional` \
  #-e PASSWORD= `#optional` \
  -p 8000:8000 \
  -v /home/mi11k1/c9:/code `#optional` \
  -v /var/run/docker.sock:/var/run/docker.sock `#optional` \
  --restart unless-stopped \
  ghcr.io/linuxserver/cloud9