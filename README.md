### AUTOMATIC RECON USING CRONTAB


# INSTALATION
```
git clone https://github.com/D0Lv-1N/recon.git
cd recon
chmod +x *.sh
mkdir state
./setup.sh
```

# create crontab with command:
```
crontab -e
```
# fill the file crontab with
note:replace 'ubuntu' with the linux os username
```
@reboot sleep 120 && /bin/bash /home/ubuntu/recon/recon.sh >> /home/ubuntu/recon/cron.log 2>&1

```
Enter the target domain in the targets.txt file
