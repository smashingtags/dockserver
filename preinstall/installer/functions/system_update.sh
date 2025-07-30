#!/usr/bin/with-contenv bash
# shellcheck shell=bash

updatesystem() {
   while true; do
      # shellcheck disable=SC2046
      printf "
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    🚀 DockServer PRE-Install Runs
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
"
      basefolder="/opt/appdata"
      source="/opt/dockserver/preinstall/templates/local"
      oldsinstall && proxydel
      package_list="update upgrade dist-upgrade autoremove autoclean"
      for i in ${package_list}; do
         echo "running now $i" && apt $i -yqq 1>/dev/null 2>&1
      done
      folder="/mnt"
      for fo in ${folder}; do
         mkdir -p $fo/{unionfs,downloads,incomplete,torrent,nzb} \
         $fo/{incomplete,downloads}/{nzb,torrent}/{complete,temp,movies,tv,tv4k,movies4k,movieshdr,tvhdr,remux} \
         $fo/downloads/torrent/{temp,complete}/{movies,tv,tv4k,movies4k,movieshdr,tvhdr,remux} \
         $fo/{torrent,nzb}/watch
         find $fo -exec $(command -v chmod) a=rx,u+w {} \;
         find $fo -exec $(command -v chown) -hR 1000:1000 {} \;
      done
      appfolder="/opt/appdata"
      for app in ${appfolder}; do
        mkdir -p $app/{compose,system}
        find $app -exec $(command -v chmod) a=rx,u+w {} \;
        find $app -exec $(command -v chown) -hR 1000:1000 {} \;
      done

      #### CHANGE DNS SERVERS ####
      mapfile -t "FILE" < <($(which find) "/etc/netplan" -type f -name "*.yaml")
      for NETYAML in "${FILE[@]}"; do
         $(which sed) -i 's/185.12.64.1/9.9.9.9/' ${NETYAML} &>/dev/null
         $(which sed) -i 's/185.12.64.2/149.112.112.112/' ${NETYAML} &>/dev/null
         $(which sed) -i 's/2a01:4ff:ff00::add:2/2620:fe::fe/' ${NETYAML} &>/dev/null
         $(which sed) -i 's/2a01:4ff:ff00::add:1/2620:fe::9/' ${NETYAML} &>/dev/null
      done
      netplan apply

     if test -f /etc/sysctl.d/99-sysctl.conf; then
         config="/etc/sysctl.d/99-sysctl.conf"
         ipv6=$(cat $config | grep -qE 'ipv6' && echo true || false)
           if [ $ipv6 != 'true' ] || [ $ipv6 == 'true' ]; then
              grep -qE 'net.ipv6.conf.all.disable_ipv6 = 1' $config || \
              echo 'net.ipv6.conf.all.disable_ipv6 = 1' >>$config
              grep -qE 'net.ipv6.conf.default.disable_ipv6 = 1' $config || \
              echo 'net.ipv6.conf.default.disable_ipv6 = 1' >>$config
              grep -qE 'net.ipv6.conf.lo.disable_ipv6 = 1' $config || \
              echo 'net.ipv6.conf.lo.disable_ipv6 = 1' >>$config
              grep -qE 'net.core.default_qdisc=fq' $config || \
              echo 'net.core.default_qdisc=fq' >>$config
              grep -qE 'net.ipv4.tcp_congestion_control=bbr' $config || \
              echo 'net.ipv4.tcp_congestion_control=bbr' >>$config
              sysctl -p -q
           fi
      fi

      bash -c "$(curl -sL https://raw.githubusercontent.com/ilikenwf/apt-fast/master/quick-install.sh)"
      echo debconf apt-fast/maxdownloads string 16 | debconf-set-selections
      echo debconf apt-fast/dlflag boolean true | debconf-set-selections
      echo debconf apt-fast/aptmanager string apt | debconf-set-selections

      package_basic=(software-properties-common rsync language-pack-en-base pciutils lshw nano rsync fuse curl wget tar pigz pv iptables ipset fail2ban)
      apt install ${package_basic[@]} --reinstall -yqq 1>/dev/null 2>&1 && sleep 1
      break
   done
}
