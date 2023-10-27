# FLY-Tools

[中文](./README-ZH.md)

**Note: FLY-Tools can automatically obtain the klipper directory through klipper.service in the system. If the automatic acquisition fails, please manually specify the klipper directory.**

**Note: The old version of klipper is not supported, please be sure to use the latest version of klipper.**

**Note: More motherboard models are being adapted during canboot firmware compilation.**


## Introduction to Fly-Tools

* Fly-Tools is a WEB tool used to improve Klipper user experience
    
1. Feature

    * Multi-language support, dark theme support
    * Supports querying and copying USB serial port ID, USB device ID, CANbus UUID, Video device ID
    * Support one-click enable or disable specified CAN device
    *Support online modification of the rate and sending buffer size of CAN devices
    * Support online compilation of klipper firmware for FLY motherboard (Katapult firmware compilation is being adapted)
    * Support online burning, support DFU, HID, CAN and other burning methods
    * Support downloading all compiled firmware files
    * Support online generation of Klipper load graph
    * Supports one-click automatic measurement and generation of resonance diagrams
    * Support WEB webpage SSH (based on [ttyd](https://github.com/tsl0922/ttyd))
    * Modify some system settings online (only supports FLYOS)

2. Effect drawing

    <table>
    <tr>
    <td><img src="./images/langs.png" title="multi-language" border=0></td>
    <td><img src="./images/dark.png" title="dark color" border=0></td>
    </tr>
    <tr>
    <td><img src="./images/home.png" title="Query ID" border=0></td>
    <td><img src="./images/editcan.png" title="Modify CAN device parameters" border=0></td>
    </tr>
    <tr>
    <td><img src="./images/build-flash.gif" title="Compiling and flashing firmware" border=0></td>
    <td><img src="./images/klippyload.gif" title="Generate load graph" border=0></td>
    </tr>
    <tr>
    <td><img src="./images/webssh.png" title="WEB SSH" border=0></td>
    <td><img src="./images/setting.png" title="Setting" border=0></td>
    </tr>
    </table>
    

## Install Fly-Tools

1. Pull the latest version of klipper

    ```
    cd ~/klipper
    git pull
    ```
    
    * If you have modified klipper in the past and the pull failed, please use the following command. (This operation will discard files you have previously modified)
  
    ```
    cd ~/klipper
    git checkout .
    git pull
    ```
      

2. Pull the latest Katapult (formerly Canboot)

    ```
    cd ~/
    git clone https://github.com/Arksine/katapult
    ```

3. Install Fly-Tools service

    > The installation process relies on the Git service provider. If the download progress is stuck, please press `CTRL+C` to exit and try again.

    > The maximum number of requests per hour for Github is 60, unknown for Gitee

    * Get the installation script via Github

        ```
        curl -kfsSL https://raw.githubusercontent.com/kluoyun/FLY-Tools/main/scripts/install.sh | sudo bash
        ```

    * Get the installation script via Gitee

        ```
        curl -kfsSL https://gitee.com/zxkxz/FLY-Tools/raw/main/scripts/install.sh | sudo bash
        ```

4. Open from the browser

    * Open default port 9999
    * `http://{your device ip}:9999/`
      
## Use configuration files

* When there is no configuration file, parameters are automatically obtained by default.

1. Fly-Tools configuration file

    * The configuration file can be used by modifying the `/etc/systemd/system/Fly-Tools.service` file
    * Modify `ExecStart=/usr/local/bin/Fly-Tools` to `ExecStart=/usr/local/bin/Fly-Tools -c/path/fly-tools.conf`
    * Restart service
        ```
        sudo systemctl daemon-reload
        sudo systemctl restart Fly-Tools.service
        ```

2. Example configuration

    * fly-tools.conf
        ```ini
        [app]
        port: 9999        # The port that the FlyTools service listens on, leave it blank and default to 9999
        ttyd_port: 9998   # The ttyd service port of web SSH, leave it blank and the default is 9998

        [printer]
        user: fly                                        # Username for which Klipper is installed, leave blank for automatic recognition
        klipper_sock: /home/fly/printer_data/comms/klippy.sock # Klipper's Unix socket network
        klipper_dir: /home/fly/klipper                   # Klipper warehouse directory, leave blank for automatic recognition
        katapult_dir: /home/fly/katapult                 # Katapult warehouse directory, left blank for automatic recognition
        logs_dir: /home/fly/printer_data/logs            # The log file directory of Klipper and other services will be automatically recognized if left blank.
        configs_dir: /home/fly/printer_data/configs      # The configuration file directory of Klipper and other services will be automatically recognized if left blank.

        [log]
        path:  # Log storage path, leave it blank and do not save it to a file

        ```
      
## Custom installation

* TODO

# Disclaimer:

**Thank you for using our services. The information and tools we provide are for informational purposes only and we make no warranty or promise as to their safety, accuracy or reliability. We are not responsible for any loss or problem caused by improper use, network failure, etc. during use. Use with caution and at your own risk.**
