### AUTOMATIC RECON USING CRONTAB

```
git clone https://github.com/D0Lv-1N/recon.git
cd recon
chmod +x recon.sh
mkdir state
```

create crontab with command:
```
crontab -e
```
#fill the file with:
```
@reboot sleep (use persecond format) && /bin/bash /home/(your user)/recon/recon.sh >> /home/dolvin/recon/cron.log 2>&1

```
Enter the target domain in the targets.txt file
