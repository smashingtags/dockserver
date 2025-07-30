#!/usr/bin/with-contenv bash
# shellcheck shell=bash

ansibleinstall() {
      if [ -z `command -v ansible` ]; then
         if [[ -r /etc/os-release ]]; then lsb_dist="$(. /etc/os-release && echo "$ID")"; fi
         package_list="ansible dialog python3-lxml"
         package_listdebian="apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367"
         package_listubuntu="apt-add-repository --yes --update ppa:ansible/ansible"
         if [[ $lsb_dist == 'ubuntu' ]] || [[ $lsb_dist == 'rasbian' ]]; then ${package_listubuntu} 1>/dev/null 2>&1; else ${package_listdebian} 1>/dev/null 2>&1; fi
         for i in ${package_list}; do
            $(command -v apt) install $i --reinstall -yqq 1>/dev/null 2>&1
         done
         if [[ $lsb_dist == 'ubuntu' ]]; then add-apt-repository --yes --remove ppa:ansible/ansible; fi
      fi

      if [[ ! -d "/etc/ansible/inventories" ]]; then
         $(command -v mkdir) -p $invet
      fi
      cat > /etc/ansible/inventories/local << EOF; $(echo)
## CUSTOM local inventories
[local]
127.0.0.1 ansible_connection=local
EOF
      if [[ -f /etc/ansible/ansible.cfg ]]; then
        $(command -v mv) /etc/ansible/ansible.cfg /etc/ansible/ansible.cfg.bak
      fi
cat > /etc/ansible/ansible.cfg << EOF; $(echo)
## CUSTOM Ansible.cfg
[defaults]
deprecation_warnings = False
command_warnings = False
force_color = True
inventory = /etc/ansible/inventories/local
retry_files_enabled = False
EOF
}
