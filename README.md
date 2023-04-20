# sing-box shadow-tls guide
> UDP + TUN support
## Server
1. change to root user
```bash
sudo -s
```
2. run the script
```bash
bash <(curl -s https://codeberg.org/l0Ye2sE/sing-box-stls/raw/branch/main/install-server.sh)
```
## Client
script in the end gives you a json config put this in a file named config.json and
- android
    - use [Nekobox](https://github.com/MatsuriDayo/NekoBoxForAndroid/releases) and import from file option
- ios
    - I didn't test it but maybe there is some sing-box for ios client
- windows
    1. download [sing-box binary](https://github.com/SagerNet/sing-box/releases)
    2. put sing-box binary and config.json in one folder
    3. run cmd as administrator
    4. in cmd go to the folder
    5. run
    ```bash
    sing-box.exe run -c config.json
    ```
- linux
    1. download [sing-box binary](https://github.com/SagerNet/sing-box/releases)
    2. put sing-box binary and config.json in one directory
    4. cd into the directory
    5. run
    ```bash
     sudo ./sing-box run -c config.json
    ```
> for mac it's probably like linux
