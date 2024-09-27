
reboot_needed=1
board=$(batocera-info | grep '^Board: ' | sed -e 's/^Board: //' | tr '[:upper:]' '[:lower:]')

if [[ "$board" == "rg40xx" ]] || [[ "$board" == "rg35xx-h" ]]; then
    if [ -f /tmp/patch/${board}-boot-modded.img ]; then
        # img files from https://discord.com/channels/1173228527605272666/1227424831360733305/1269857770665148427
        dd if=/tmp/patch/${board}-boot-modded.img of=/dev/mmcblk0p1
        reboot_needed=0
    fi
fi

if [[ "$board" == "rg40xx" ]] && [ -f /tmp/patch/rg40xx-h-stick-leds-v*-installer.zip ]; then
    old_dir="$PWD"
    cd /userdata/system
    # Installer files from https://discord.com/channels/1173228527605272666/1227424831360733305/1269857770665148427
    mv /tmp/patch/rg40xx-h-stick-leds-v*-installer.zip ./rg40xx-h-stick-leds-installer.zip
    unzip rg40xx-h-stick-leds-installer.zip
    rm rg40xx-h-stick-leds-installer.zip
    sed -i -e 's/^reboot/#reboot/g' -e 's/echo "Rebooting..."/#echo "Rebooting..."/' ./ledservice_installer.sh
    chmod +x ./ledservice_installer.sh
    ./ledservice_installer.sh
    rm ./ledservice_installer.sh
    cd "$old_dir"

    curl --silent \
        --location \
        https://raw.githubusercontent.com/zarquon-42/knulli-led-per-game/refs/heads/main/install.sh \
        -O /tmp/patch/install_led_per_game.sh

    chmod +x /tmp/patch/install_led_per_game.sh

    /tmp/patch/install_led_per_game.sh

    reboot_needed=0
fi

if [ reboot_needed -eq 0 ]
    reboot
    exit 0
fi
