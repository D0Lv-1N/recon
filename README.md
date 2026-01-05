### AUTOMATIC RECON USING CRONTAB


# INSTALATION
```
git clone https://github.com/D0Lv-1N/recon.git
cd recon
chmod +x *.sh
mkdir state
./setup.sh
```
# NOTIFY TOOLS
Read the complete guide on how to set up notify here: https://github.com/projectdiscovery/notify

# CRONTAB SETUP

The line you add to `crontab -e` looks like this right now:

```/dev/null/crontab_example.md#L1-2
@reboot sleep 120 && /bin/bash /home/ubuntu/recon/recon.sh >> /home/ubuntu/recon/cron.log 2>&1
```

### 1. Understanding the fields

A typical crontab entry has **five** space‑separated values followed by the command:

| Minute | Hour | Day‑of‑Month | Month | Day‑of‑Week | Command |
|--------|------|--------------|-------|------------|---------|
| `0`    | `2`  | `*`          | `*`   | `*`        | `/path/to/script.sh` |

- **Minute** – when the minute should trigger (0‑59)  
- **Hour** – when the hour should trigger (0‑23)  
- **Day‑of‑Month** – which day of the month (1‑31)  
- **Month** – which month (1‑12 or names)  
- **Day‑of‑Week** – which weekday (0‑7, both 0 and 7 = Sunday)  

If you put `*` in a field it means “every possible value” for that field.

### 2. Running the script at a specific **clock time**

If you want the recon to start **every day at 02:30 AM**, change the line to:

```/dev/null/crontab_example.md#L3-4
30 2 * * * /bin/bash /home/ubuntu/recon/recon.sh >> /home/ubuntu/recon/cron.log 2>&1
```

- `30` → minute 30  
- `2`  → hour 2 (02:00‑02:59)  
- `*`  → every day of the month  
- `*`  → every month  
- `*`  → every day of the week  

### 3. Running the script **after the system boots** with a custom delay

The current setup uses `@reboot` which fires **immediately** after the system reaches run‑levels 2‑5.  
If you want a **delay of N minutes** after boot, keep the `@reboot` keyword and prepend a `sleep`:

```/dev/null/crontab_example.md#L5-6
@reboot sleep 5 && /bin/bash /home/ubuntu/recon/recon.sh >> /home/ubuntu/recon/cron.log 2>&1
```

- `sleep 5` pauses **5 seconds** before launching the script.  
- To wait **10 minutes**, use `sleep 600` (600 seconds).  
- To wait **15 minutes**, use `sleep 900`, and so on.

#### Example: 3‑minute post‑boot delay

```/dev/null/crontab_example.md#L7-8
@reboot sleep 180 && /bin/bash /home/ubuntu/recon/recon.sh >> /home/ubuntu/recon/cron.log 2>&1
```

### 4. Combining both: specific time **and** boot‑delay logic

If you want the script to run **both** at a fixed daily time **and** after a reboot (e.g., you sometimes reboot and want it to start 2 minutes later), you can add a second line that only triggers on reboot:

```/dev/null/crontab_example.md#L9-10
# Run daily at 03:00 AM
0 3 * * * /bin/bash /home/ubuntu/recon/recon.sh >> /home/ubuntu/recon/cron.log 2>&1

# Run 2 minutes after any reboot
@reboot sleep 120 && /bin/bash /home/ubuntu/recon/recon.sh >> /home/ubuntu/recon/cron.log 2>&1
```

### 5. Editing the crontab

1. Open the editor:  

   ```/dev/null/crontab_example.md#L12-13
   crontab -e
   ```

2. Locate the line that starts with `@reboot` (or the one with the schedule you want to modify).  
3. Change the values as shown above.  
4. Save and exit the editor.  
5. Verify that the new schedule is installed:  

   ```/dev/null/crontab_example.md#L15-16
   crontab -l
   ```

### 6. Quick reference cheat‑sheet

| Desired schedule | Crontab expression | Explanation |
|------------------|--------------------|-------------|
| Every 5 minutes | `*/5 * * * * /path/to/script.sh` | Runs at minute 0,5,10,… of every hour |
| Every hour at minute 15 | `15 * * * * /path/to/script.sh` | At 01:15, 02:15, 03:15, … |
| Daily at 04:00 AM | `0 4 * * * /path/to/script.sh` | Once per day at 04:00 |
| Weekly on Sunday at 02:30 AM | `30 2 * * 0 /path/to/script.sh` | `0` = Sunday |
| After boot, wait 7 minutes | `@reboot sleep 420 && /path/to/script.sh` | 420 seconds = 7 minutes |
| After boot, run at 05:00 AM regardless of reboot time | `0 5 * * * /path/to/script.sh` (no `@reboot`) | Simple daily schedule |

---

### TL;DR

- **Change the time** → edit the five‑field schedule (`min hour dom mon dow`).  
- **Add a delay after boot** → keep `@reboot` and prepend `sleep <seconds>`.  
- **Multiple schedules** → add separate lines for each pattern.  

Just open `crontab -e`, modify the line(s), save, and you’re done. Happy recon!


# Targets
- Edit the `targets.txt` file and list the domains you want the recon to monitor.  
- Each line in `targets.txt` should contain one domain name.
