#!/bin/sh


if [ "${SUDO_USER}" = "root" ]; then
    echo "Please do not execute it under the root user"
    exit 1
fi

if [ -z "${SUDO_USER}" ]; then
    echo "Requires \"sudo \" privileges"
    exit 1
fi

[ -n "${BASE_USER}" ] || BASE_USER="${SUDO_USER}"

M=$(uname -m)

URL="https://raw.githubusercontent.com/kluoyun/FLY-Tools/main/application/Fly-Tools_linux_arm64"
TTYD_URL="https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.aarch64"

if [ "$M" = "armhf" ] || [ "$M" = "armv7l" ] ;then
    URL="https://raw.githubusercontent.com/kluoyun/FLY-Tools/main/application/Fly-Tools_linux_arm"
    TTYD_URL="https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.armhf"
elif [ "$M" = "arm64" ] || [ "$M" = "aarch64" ] ;then
    URL="https://raw.githubusercontent.com/kluoyun/FLY-Tools/main/application/Fly-Tools_linux_arm64"
    TTYD_URL="https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.aarch64"
elif [ "$M" = "x86_64" ];then
    URL="https://raw.githubusercontent.com/kluoyun/FLY-Tools/main/application/Fly-Tools_linux_amd64"
    TTYD_URL="https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.i686"
else
    echo "Unsupported System Architectures: ${M} !!!"
    exit 1
fi

sudo cat > /etc/default/ttyd << EOF
# /etc/default/ttyd

TTYD_OPTIONS="-p 9998 -6 -O login"
EOF

sudo systemctl stop ttyd-f.service > /dev/null 2>&1
sudo rm /usr/local/bin/ttyd-f > /dev/null 2>&1
sudo wget -c $TTYD_URL -O /usr/local/bin/ttyd-f #> /dev/null 2>&1
sudo chmod +x /usr/local/bin/ttyd-f

sudo touch /etc/systemd/system/ttyd-f.service
sudo chmod +x /etc/systemd/system/ttyd-f.service
sudo cat > /etc/systemd/system/ttyd-f.service << EOF
[Unit]
Description=ttyd-f
Requires=network-online.target
After=network-online.target

[Install]
WantedBy=multi-user.target

[Service]
Type=simple
Restart=always
RemainAfterExit=yes
RestartSec=1
User=root
ExecStart=/usr/local/bin/ttyd-f -p 9998 -6 -O login
EOF

sudo systemctl daemon-reload
sudo systemctl enable ttyd-f.service
sudo systemctl restart ttyd-f.service

sudo systemctl stop FLY-Tools.service > /dev/null 2>&1
sudo rm /usr/local/bin/FLY-Tools > /dev/null 2>&1
sudo wget -c $URL -O /usr/local/bin/FLY-Tools #> /dev/null 2>&1
sudo chmod +x /usr/local/bin/FLY-Tools

sudo touch /etc/systemd/system/FLY-Tools.service
sudo chmod +x /etc/systemd/system/FLY-Tools.service
sudo cat > /etc/systemd/system/FLY-Tools.service << EOF
[Unit]
Description=FLY-Tools
Requires=network-online.target
After=network-online.target

[Install]
WantedBy=multi-user.target

[Service]
Type=simple
Restart=always
RemainAfterExit=yes
RestartSec=1
User=root
ExecStart=/usr/local/bin/FLY-Tools -p 9999 -l /tmp/FLY-Tools.log
EOF

sudo systemctl daemon-reload
sudo systemctl restart FLY-Tools.service
sudo systemctl enable FLY-Tools.service

echo "安装结束"
