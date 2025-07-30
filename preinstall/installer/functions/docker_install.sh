#!/usr/bin/with-contenv bash
# shellcheck shell=bash

dockerinstall() {
      if [ -z `command -v docker` ]; then
         curl --silent -fsSL https://raw.githubusercontent.com/docker/docker-install/master/install.sh | sudo bash >/dev/null 2>&1
      fi
         mkdir -p /etc/docker &>/dev/null
         rsync -aqhv ${source}/daemon.j2 /etc/docker/daemon.json 1>/dev/null 2>&1
         usermod -aG docker $(whoami)
         systemctl reload-or-restart docker.service 1>/dev/null 2>&1
         systemctl enable docker.service >/dev/null 2>&1
         curl --silent -fsSL https://raw.githubusercontent.com/MatchbookLab/local-persist/master/scripts/install.sh | sudo bash 1>/dev/null 2>&1
         docker volume create -d local-persist -o mountpoint=/mnt --name=unionfs
         docker network create --driver=bridge proxy 1>/dev/null 2>&1
      if [ -z `command -v docker-compose` ]; then
         curl -L --fail https://raw.githubusercontent.com/linuxserver/docker-docker-compose/master/run.sh -o /usr/local/bin/docker-compose
         ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
         chmod +x /usr/local/bin/docker-compose /usr/bin/docker-compose
      fi
}
