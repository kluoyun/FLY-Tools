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

dpkg -s jq > /dev/null
if [ $? != 0 ]; then
sudo apt update
sudo apt install jq -y
fi


rm -rf /tmp/._fts > /dev/null
STATE=""
dialog --clear --colors --backtitle "Fly-Tools ${LTAG} Installer (0/3)" --title "\Z2Select installation source" --menu "\Z4If you can access Github, please try to use Github to install it." 20 60 10 \
"Github"    "Use Github to install it." \
"Gitee"     "Use Gitee to install it." \
"Exit"      "Exit the installer" \
2>/tmp/._fts

STATE=$(cat /tmp/._fts)
rm -rf /tmp/._fts > /dev/null

case $STATE in
    Exit)
        echo "\nGoodbye!!!\n"
        exit 0
        ;;
    "")
        echo "\nGoodbye!!!\n"
        exit 0
        ;;
    "Github")
        GIT_URL="github.com"
        GIT_API="api.github.com"
        GIT_USER="kluoyun"
        GIT_TTYD_USER="tsl0922"
    ;;
    "Gitee")
        GIT_URL="gitee.com"
        GIT_API="gitee.com/api/v5"
        GIT_USER="zxkxz"
        GIT_TTYD_USER="ZXKXZ"
    ;;
esac


LTAG=$(curl -Ls "https://${GIT_API}/repos/${GIT_USER}/FLY-Tools/releases/latest" | jq -r '.tag_name')
if [ "$?" != "0" ]; then
    dialog --colors --backtitle "Fly-Tools Installer (1/3)" --title "\Z1\ZbInstall Error Fly-Tools" --infobox "\Z3Unable to get latest version.\n If it is a gitee source, it may be that your installation times are too many, resulting in IP restrictions." 10 60
    echo "\n"
    exit 1
fi
TTYD_LTAG=$(curl -Ls "https://${GIT_API}/repos/${GIT_TTYD_USER}/ttyd/releases/latest" | jq -r '.tag_name')
if [ "$?" != "0" ]; then
    dialog --colors --backtitle "Fly-Tools Installer (1/3)" --title "\Z1\ZbInstall Error ttyd" --infobox "\Z3Unable to get latest version.\n If it is a gitee source, it may be that your installation times are too many, resulting in IP restrictions." 10 60
    echo "\n"
    exit 1
fi

M=$(uname -m)
rm -rf /tmp/._fts > /dev/null
STATE=""
dialog --clear --colors --backtitle "Fly-Tools ${LTAG} Installer (1/3)" --title "\Z2Choose system architecture" --menu "\Z4The current system architecture is: \Z1\Zr\Zb${M}\Zn \n\Z0Choose your system architecture." 20 60 10 \
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
"Exit"           "Exit the installer" \
2>/tmp/._fts

STATE=$(cat /tmp/._fts)
rm -rf /tmp/._fts > /dev/null

case $STATE in
    Exit)
        echo "\nGoodbye!!!\n"
        exit 0
        ;;
    Other)
        echo "Please go to the release page to download the executable file and install it yourself."
        echo "\nGoodbye!!!\n"
        exit 0
        ;;
    "")
        echo "\nGoodbye!!!\n"
        exit 0
        ;;
    *)
        
        URL="https://${GIT_URL}/${GIT_USER}/FLY-Tools/releases/download/${LTAG}/Fly-Tools_${STATE}"

        case $STATE in
            linux-amd64)
                TTYD_STATE="x86_64"
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
        TTYD_URL="https://${GIT_URL}/${GIT_TTYD_USER}/ttyd/releases/download/${TTYD_LTAG}/ttyd.${TTYD_STATE}"
        ;;
esac

# echo FLY-Tools url: $URL
# echo ttyd url: $TTYD_URL
# echo ""

sudo cat > /etc/default/ttyd << EOF
# /etc/default/ttyd

TTYD_OPTIONS="--writable -p 9998 -6 -O login"
EOF

sudo systemctl stop ttyd-f.service > /dev/null 2>&1
sudo rm /usr/local/bin/ttyd-f > /dev/null 2>&1

wget --no-check-certificate -c -O ./ttyd-f $TTYD_URL 2>&1 | \
stdbuf -o0 awk '/[.] +[0-9][0-9]?[0-9]?%/ { print substr($0,63,3) }'| \
dialog --backtitle "Fly-Tools ${LTAG} Installer (2/3)" --title "Download components (1/2)" --gauge "Download ttyd-${TTYD_STATE}-${TTYD_LTAG}" 10 80

if [ ! -f "./ttyd-f" ] || [ ! -s "./ttyd-f" ]; then
    sudo rm ./ttyd-f > /dev/null 2>&1
    dialog --colors --backtitle "Fly-Tools ${LTAG} Installer (2/3)" --title "\Z1Download Error\Zn" --infobox "Download ttyd-${TTYD_STATE}-${TTYD_LTAG} failed, please check the network" 10 60
    echo "\n"
    exit 1
fi
sudo mv ./ttyd-f /usr/local/bin/ttyd-f
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
if [ "$?" != "0" ]; then
    dialog --colors --backtitle "Fly-Tools ${LTAG} Installer (2/3)" --title "\Z1Install ttyd Error\Zn" --infobox "The ttyd service failed to install and start successfully." 10 60
    echo "\n"
    exit 1
fi

if [ -e "/etc/systemd/system/FLY-Tools.service" ];then
    sudo systemctl stop FLY-Tools.service > /dev/null 2>&1
    sudo rm /etc/systemd/system/FLY-Tools.service > /dev/null 2>&1
    sudo rm /usr/local/bin/FLY-Tools > /dev/null 2>&1
    sudo systemctl daemon-reload > /dev/null 2>&1
fi

sudo systemctl stop Fly-Tools.service > /dev/null 2>&1
sudo rm /usr/local/bin/Fly-Tools > /dev/null 2>&1

wget --no-check-certificate -c -O ./Fly-Tools $URL 2>&1 | \
stdbuf -o0 awk '/[.] +[0-9][0-9]?[0-9]?%/ { print substr($0,63,3) }'| \
dialog --backtitle "Fly-Tools ${LTAG} Installer (2/3)" --title "Download components (2/2)" --gauge "Download Fly-Tools-${STATE}-${LTAG}" 10 80

if [ ! -f "./Fly-Tools" ] || [ ! -s "./Fly-Tools" ]; then
    sudo rm ./Fly-Tools > /dev/null 2>&1
    dialog --colors --backtitle "Fly-Tools ${LTAG} Installer (2/3)" --title "\Z1Download Error\Zn" --infobox "Download Fly-Tools-${STATE}-${LTAG} failed, please check the network" 10 60
    echo "\n"
    exit 1
fi
sudo mv ./Fly-Tools /usr/local/bin/Fly-Tools
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
if [ "$?" != "0" ]; then
    dialog --colors --backtitle "Fly-Tools ${LTAG} Installer (2/3)" --title "\Z1Install Fly-Tools Error\Zn" --infobox "The Fly-Tools service failed to install and start successfully." 10 60
    echo "\n"
    exit 1
fi

dialog --colors --backtitle "Fly-Tools ${LTAG} Installer (3/3)" --title "\Z4Fly-Tools installed successfully\Zn" --msgbox "Fly-Tools installation completed.\nPlease open your browser and visit http://{ip}:9999/\n\nPress the \Z1\ZrEnter\Zn key to exit." 10 60

echo "\nGoodbye!!!\n"
exit 0
