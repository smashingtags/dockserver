#!/usr/bin/with-contenv bash
# shellcheck shell=bash
#####################################
# All rights reserved.              #
# started from Zero                 #
# Docker owned dockserver           #
# Docker Maintainer dockserver      #
#####################################
#####################################
# THIS DOCKER IS UNDER LICENSE      #
# NO CUSTOMIZING IS ALLOWED         #
# NO REBRANDING IS ALLOWED          #
# NO CODE MIRRORING IS ALLOWED      #
#####################################
# shellcheck disable=SC2003
# shellcheck disable=SC2006
# shellcheck disable=SC2207
# shellcheck disable=SC2012
# shellcheck disable=SC2086
# shellcheck disable=SC2196
# shellcheck disable=SC2046

# Source the function scripts
source /opt/dockserver/preinstall/installer/functions/system_update.sh
source /opt/dockserver/preinstall/installer/functions/docker_install.sh
source /opt/dockserver/preinstall/installer/functions/ansible_install.sh
source /opt/dockserver/preinstall/installer/functions/fail2ban_config.sh
source /opt/dockserver/preinstall/installer/functions/misc_config.sh

# Call the functions
updatesystem
dockerinstall
ansibleinstall
fail2banconfig
miscconfig
