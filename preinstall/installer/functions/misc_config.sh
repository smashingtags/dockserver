#!/usr/bin/with-contenv bash
# shellcheck shell=bash

miscconfig() {
      disable=(apt-daily.service apt-daily.timer apt-daily-upgrade.timer apt-daily-upgrade.service)
      systemctl disable ${disable[@]} >/dev/null 2>&1

      gpu="ntel NVIDIA"
      for i in ${gpu}; do
            TDV=$(lspci | grep -i --color 'vga\|display\|3d\|2d' 1>/dev/null 2>&1 && echo true || echo false)
            if [[ $TDV == "true" ]]; then $(command -v bash) ${source}/gpu.sh; fi
      done

      if [[ "$(systemd-detect-virt)" == "lxc" ]]; then $(command -v bash) /opt/dockserver/preinstall/installer/subinstall/lxc.sh; fi

      #bad ips mod
      ipset -q flush ips
      ipset -q create ips hash:net
      for ip in $(curl --compressed https://raw.githubusercontent.com/scriptzteam/IP-BlockList-v4/master/ips.txt 2>/dev/null | grep -v "#" | grep -v -E "\s[1-2]$" | cut -f 1); do ipset add ips $ip; done
      iptables -I INPUT -m set --match-set ips src -j DROP
      update-locale LANG=LANG=LC_ALL=en_US.UTF-8 LANGUAGE 1>/dev/null 2>&1
      localectl set-locale LANG=LC_ALL=en_US.UTF-8 1>/dev/null 2>&1

      ## raiselimits
      sed -i '/hard nofile/ d' /etc/security/limits.conf
      sed -i '/soft nofile/ d' /etc/security/limits.conf
      sed -i '$ i\* hard nofile 32768\n* soft nofile 16384' /etc/security/limits.conf
      printf "
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    🚀 DockServer PRE-Install is done
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
"
}

proxydel() {
   delproxy="apache2 nginx"
   for i in ${delproxy}; do
      $(command -v systemctl) stop $i 1>/dev/null 2>&1
      $(command -v systemctl) disable $i 1>/dev/null 2>&1
      $(command -v apt) remove $i -yqq 1>/dev/null 2>&1
      $(command -v apt) purge $i -yqq 1>/dev/null 2>&1
      break
   done
}

oldsinstall() {
   oldsolutions="plexguide cloudbox gooby sudobox sbox pandaura salty"
   for i in ${oldsolutions}; do
      folders="/var/ /opt/ /home/ /srv/"
      for ii in ${folders}; do
         show=$(find $ii -maxdepth 2 -type d -name $i -print)
         if [[ $show != '' ]]; then
            echo ""
            printf "\033[0;31m You need to reinstall your operating system.
sorry, you need a freshly installed server. We can not install on top of $i\033[0m\n"
            echo ""
            read -erp "Type confirm when you have read the message: " input
            if [[ "$input" = "confirm" ]]; then exit; else oldsinstall; fi
         fi
      done
   done
}
