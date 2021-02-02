  #!/bin/bash  
     apt update && apt dist-upgrade -y && apt-get install -y software-properties-common apparmor-utils apt-transport-https avahi-daemon ca-certificates curl dbus jq network-manager socat && systemctl disable ModemManager && curl -fsSL get.docker.com | sh && curl -sL "https://raw.githubusercontent.com/home-assistant/hassio-installer/master/hassio_install.sh" | bash -s
exit 0 
