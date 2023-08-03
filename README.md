# FLY-Tools

## Install

**Note: FLY-Tools can automatically obtain the klipper directory through klipper.service in the system. If the automatic acquisition fails, please manually specify the klipper directory.**

**Note: The old version of klipper is not supported, please be sure to use the latest version of klipper.**

**Note: More motherboard models are being adapted during canboot firmware compilation.**

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
      
2. Install FLY-Tools using the install script

    ```
    wget -O flytools_install.sh https://raw.githubusercontent.com/kluoyun/FLY-Tools/main/scripts/install.sh && sudo bash flytools_install.sh
    ```

      
3. Custom installation

    * You can also manually download a program that matches the system architecture to run.
    * Use the `-h` parameter to see how to use it

        ```
        Usage of Fly-Tools_linux_arm64:
            -c string
                    Canboot repository directory
            -k string
                    Klipper repository directory
            -l string
                    Save log output to file
            -p int
                    FLY-Tools run WEB port (default 9999)
            -v    cat FLY-Tools Version
        ```

4. Open from the browser

    * Open default port 9999
    * `http://{your device ip}:9999/`
