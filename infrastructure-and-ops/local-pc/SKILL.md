---
name: local-pc
description: General SSH connection skill to access the local headless PC.
---

# Local PC SSH Connection Skill

You have access to the local headless PC (IP: 192.168.1.100). Use this skill for remote system administration, execution, and local server management.

## Network Interfaces

* **10GbE Card (Intel X540)**: IP `192.168.1.100` (MAC `11-22-33-44-55-66`). Prioritized for internet and general network traffic.
* **1GbE/2.5GbE Onboard (Realtek RTL8125)**: IP `192.168.1.101` (MAC `AA-BB-CC-DD-EE-FF`). Dedicated for Wake-on-LAN (WoL).

## SSH Access

To access the PC via PowerShell over SSH, use the following command:

```bash
ssh -i ~/.ssh/id_local_pc -o StrictHostKeyChecking=no developer@192.168.1.100
```

When executing background scripts on this machine, ensure you use `Start-Process` with `-WindowStyle Hidden` so that they survive SSH disconnections.

## Wake on LAN (WoL)

To wake the PC from the local network, send a magic packet to the Realtek MAC address `AA-BB-CC-DD-EE-FF`. You can execute this self-contained Python command:

```bash
python3 -c "import socket; b=bytes.fromhex('AABBCCDDEEFF'); p=b'\xff'*6+b*16; s=socket.socket(socket.AF_INET,socket.SOCK_DGRAM); s.setsockopt(socket.SOL_SOCKET,socket.SO_BROADCAST,1); s.sendto(p,('255.255.255.255',9))"
```
