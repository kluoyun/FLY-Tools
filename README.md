# FLY-Tools

## Install

Note: FLY-Tools can automatically obtain the klipper directory through klipper.service in the system. If the automatic acquisition fails, please manually specify the klipper directory.

1. Install FLY-Tools using the install script

    ```
    wget -O flytools_install.sh https://raw.githubusercontent.com/kluoyun/FLY-Tools/main/scripts/install.sh && sudo bash flytools_install.sh
    ```

      
2. Custom installation

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

3. Open from the browser

    * Open default port 9999
    * `http://{your device ip}:9999/`
