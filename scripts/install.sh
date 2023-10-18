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

dpkg -s dialog > /dev/null
if [ $? != 0 ]; then
sudo apt update
sudo apt install dialog -y
fi

M=$(uname -m)
rm -rf /tmp/._fts > /dev/null
dialog --clear --title "Fly-Tools Installer" --menu "The current system architecture is: ${M}\nChoose your system architecture." 20 60 10 \
"linux-amd64"    "X86_64 ..." \
"linux-arm64"    "aarch64, arm64-v8a arm64 ..." \
"linux-arm"      "armeabi-v7a, armhf, arm ..." \
"linux-i386"     "x86, i686 ..." \
"linux-mips"     "Mips ..." \
"linux-mipsle"   "Mipsle ..." \
"linux-mips64"   "Mips64 ..." \
"linux-mips64le" "Mips64le ..." \
"linux-s390x"    "S390x ..." \
"Other"          "Please install manually for other architectures" \
"Exit" "Exit the installer" \
2>/tmp/._fts

STATE=$(cat /tmp/._fts)
rm -rf /tmp/._fts > /dev/null
dialog --clear

case $STATE in
    Exit)
        exit 0
        ;;
    Other)
        echo "Please go to the release page to download the executable file and install it yourself."
        exit 0
        ;;
    "")
        exit 0
        ;;
    *)
        LTAG=$(curl -Ls "https://api.github.com/repos/kluoyun/Fly-Tools/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
        URL="https://github.com/kluoyun/Fly-Tools/releases/download/${LTAG}/Fly-Tools_${STATE}"

        case $STATE in
            linux-amd64)
                TTYD_STATE="X86_64"
                ;;
            linux-arm64)
                TTYD_STATE="aarch64"
                ;;
            linux-arm)
                TTYD_STATE="armhf"
                ;;
            linux-i386)
                TTYD_STATE="i686"
                ;;
            linux-mips)
                TTYD_STATE="mips"
                ;;
            linux-mipsle)
                TTYD_STATE="mipsel"
                ;;
            linux-mips64)
                TTYD_STATE="mips64"
                ;;
            linux-mips64le)
                TTYD_STATE="mips64el"
                ;;
            linux-s390x)
                TTYD_STATE="s390x"
                ;;
        esac
        TTYD_LTAG=$(curl -Ls "https://api.github.com/repos/tsl0922/ttyd/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
        TTYD_URL="https://github.com/tsl0922/ttyd/releases/download/${TTYD_LTAG}/ttyd.${TTYD_STATE}"
        ;;
esac

echo $URL
echo $TTYD_URL

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
ExecStart=/usr/local/bin/ttyd-f --writable -p 9998 -6 -O login
EOF

sudo systemctl daemon-reload
sudo systemctl enable ttyd-f.service
sudo systemctl restart ttyd-f.service

if [ -e "/etc/systemd/system/FLY-Tools.service" ];then
    sudo systemctl stop FLY-Tools.service > /dev/null 2>&1
    sudo rm /etc/systemd/system/FLY-Tools.service > /dev/null 2>&1
    sudo rm /usr/local/bin/FLY-Tools > /dev/null 2>&1
    sudo systemctl daemon-reload > /dev/null 2>&1
fi

sudo systemctl stop Fly-Tools.service > /dev/null 2>&1
sudo rm /usr/local/bin/Fly-Tools > /dev/null 2>&1
sudo wget -c $URL -O /usr/local/bin/Fly-Tools #> /dev/null 2>&1
sudo chmod +x /usr/local/bin/Fly-Tools

sudo touch /etc/systemd/system/Fly-Tools.service
sudo chmod +x /etc/systemd/system/Fly-Tools.service
sudo cat > /etc/systemd/system/Fly-Tools.service << EOF
[Unit]
Description=Fly-Tools
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
ExecStart=/usr/local/bin/Fly-Tools
EOF

sudo systemctl daemon-reload
sudo systemctl restart Fly-Tools.service
sudo systemctl enable Fly-Tools.service

echo "安装结束"
