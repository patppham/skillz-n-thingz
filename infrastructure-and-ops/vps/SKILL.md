---
name: vps
description: SSH connection skill to access and manage the VPS.
---

# VPS SSH Connection Skill

You have access to the VPS hosting the web applications. Use this skill for remote server administration, log audits, deployment troubleshooting, and process management.

## SSH Access

To connect to the VPS via SSH as the `deployer` user, use the following command:

```bash
ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no deployer@example.com
```

## System Overview

- **IP Address:** `1.2.3.4`
- **Default Port:** `22`
- **OS:** Ubuntu 24.04 LTS
- **Default Deployment Directory:** `/home/deployer/`

---

## Folder Structures & Applications

The following applications are deployed on the VPS under the `deployer` user:

### 1. Web Application Backend
- **Directory:** `/home/deployer/app-backend`
- **Backend Port:** `3005` (bound to all interfaces, proxied locally)
- **PM2 App Name:** `app-backend`
- **Logs:** `/home/deployer/.pm2/logs/app-backend-error.log` and `app-backend-out.log`

### 2. Static Site Resume
- **Directory:** `/home/deployer/ai-resume`
- **Mode:** Static build served directly by Nginx from `/home/deployer/ai-resume/dist`

---

## Deployments & Cron Scripts

Deployment logs and scripts are located in `/home/deployer/scripts/`:

* **Scripts:**
  * `~/scripts/deploy-app.sh` (polls Git every 5 mins)
  * `~/scripts/deploy-airesume.sh` (polls Git every 5 mins)
  * `~/scripts/backup-vps.sh`
* **Logs:**
  * `~/scripts/deploy-app.log`
  * `~/scripts/deploy-airesume.log`

---

## Common Commands

### Process Management (PM2)
To check or manage processes:
```bash
ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no deployer@example.com "pm2 status"
ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no deployer@example.com "pm2 show <app_id>"
ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no deployer@example.com "pm2 logs <app_id> --lines 50"
```

### Viewing Nginx Server Configs
Nginx site configurations are available in `/etc/nginx/sites-available/`:
```bash
ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no deployer@example.com "cat /etc/nginx/sites-available/app"
ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no deployer@example.com "cat /etc/nginx/sites-available/ai-resume"
```
