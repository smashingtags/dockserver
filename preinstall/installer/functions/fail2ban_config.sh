#!/usr/bin/with-contenv bash
# shellcheck shell=bash

fail2banconfig() {
      while true; do
         f2ban=$($(command -v systemctl) is-active fail2ban | grep -qE 'active' && echo true || echo false)
         if [[ $f2ban != 'true' ]]; then echo "Waiting for fail2ban to start" && sleep 1 && continue; else break; fi
      done

      ORGFILE="/etc/fail2ban/jail.conf"
      LOCALMOD="/etc/fail2ban/jail.local"
cat > /etc/fail2ban/filter.d/log4j-jndi.conf << EOF; $(echo)
# jay@gooby.org
# https://jay.gooby.org/2021/12/13/a-fail2ban-filter-for-the-log4j-cve-2021-44228
# https://gist.github.com/jaygooby/3502143639e09bb694e9c0f3c6203949
# Thanks to https://gist.github.com/kocour for a better regex
[log4j-jndi]
maxretry = 1
enabled = true
port = 80,443
logpath = /opt/appdata/traefik/traefik.log
EOF

cat > /etc/fail2ban/filter.d/authelia.conf << EOF; $(echo)
[authelia]
enabled = true
port = http,https,9091
filter = authelia
logpath = /opt/appdata/authelia/authelia.log
maxretry = 2
bantime = 90d
findtime = 7d
chain = DOCKER-USER
EOF
grep -qE '#log4j
[Definition]
failregex   = (?i)^<HOST> .* ".*\$.*(7B|\{).*(lower:)?.*j.*n.*d.*i.*:.*".*?$' /etc/fail2ban/jail.local || \
 echo '#log4j
[Definition]
failregex   = (?i)^<HOST> .* ".*\$.*(7B|\{).*(lower:)?.*j.*n.*d.*i.*:.*".*?$' > /etc/fail2ban/jail.local
         sed -i "s#rotate 4#rotate 1#g" /etc/logrotate.conf
         sed -i "s#weekly#daily#g" /etc/logrotate.conf

      f2ban=$($(command -v systemctl) is-active fail2ban | grep -qE 'active' && echo true || echo false)
      if [[ $f2ban != "false" ]]; then
         $(command -v systemctl) reload-or-restart fail2ban.service 1>/dev/null 2>&1
         $(command -v systemctl) enable fail2ban.service 1>/dev/null 2>&1
      fi
}
