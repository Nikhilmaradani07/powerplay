# DevOps Intern Assignment – AWS EC2, Monitoring & CloudWatch

## **👤 Author**
**Sivanikhil Maradani**  
---

## **📌 Overview**

This project demonstrates a complete DevOps workflow using AWS EC2, shell scripting, Nginx, CloudWatch integration, and automated monitoring.

### **Key Components**
- EC2 instance setup & user management
- Nginx server hosting a metadata-driven webpage
- Automated system monitoring script
- CloudWatch log upload via AWS CLI
- systemd timer (bonus)
- Disk usage email alert (bonus)
- Final cleanup & documentation

---

## **📍 Part 1: EC2 Setup & User Management**

### **Create New User**
```bash
sudo adduser devops_intern
````

### **Enable Passwordless sudo**

```bash
sudo visudo -f /etc/sudoers.d/devops_intern
```

Add:

```
devops_intern ALL=(ALL) NOPASSWD:ALL
```

### **Set Hostname**

```bash
sudo hostnamectl set-hostname nikhil-devops
hostname
```

### **Switch & Verify**

```bash
sudo su - devops_intern
whoami
```

---

## **📍 Part 2: Web Server Setup**

### **Install Nginx**

```bash
sudo apt install nginx -y
```

### **Create Dynamic HTML File**

```bash
sudo tee /var/www/html/index.html > /dev/null <<EOF
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>DevOps Intern - Simple Web Page</title>
</head>
<body>
  <h1>DevOps Intern - Simple Web Page</h1>
  <p><b>Name:</b> Sivanikhil Maradani</p>
  <p><b>Instance ID:</b> $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>
  <p><b>Server Uptime:</b> $(uptime -p)</p>
</body>
</html>
EOF
```

### **Access in Browser**

```
http://<public-ip>/
```

---

## **📍 Part 3: Monitoring Script**

### **Script Location**

```
/usr/local/bin/system_report.sh
```

### **Purpose**

Logs key system metrics periodically:

| Metric        | Source                 |
| ------------- | ---------------------- |
| CPU usage     | `mpstat`               |
| Memory usage  | `free`                 |
| Disk usage    | `df -h`                |
| Top processes | `ps -eo pid,comm,%cpu` |
| Uptime        | `uptime -p`            |

### **Make Executable**

```bash
sudo chmod +x /usr/local/bin/system_report.sh
```

### **Test Script**

```bash
sudo /usr/local/bin/system_report.sh
sudo tail -n 50 /var/log/system_report.log
```

---

## **📍 Part 4: AWS Integration**

### **Create Log Group**

```bash
aws logs create-log-group --log-group-name /devops/intern-metrics
```

### **Create Log Stream**

```bash
aws logs create-log-stream \
  --log-group-name /devops/intern-metrics \
  --log-stream-name system-report-stream
```

### **Convert Log File to JSON**

```bash
TIMESTAMP_MS=$(($(date +%s) * 1000))
MESSAGE=$(sed ':a;N;$!ba;s/\n/\\n/g' /var/log/system_report.log | tr '"' "'")

cat > log-events.json <<EOF
[
  {
    "timestamp": $TIMESTAMP_MS,
    "message": "$MESSAGE"
  }
]
EOF
```

### **Upload Log File**

```bash
aws logs put-log-events \
  --log-group-name /devops/intern-metrics \
  --log-stream-name system-report-stream \
  --log-events file://log-events.json
```

### **🚀 Deliverable: CloudWatch Screenshot**

<img width="1918" height="1020" alt="image" src="https://github.com/user-attachments/assets/e2f9c1a4-b6db-4fd9-baaf-1102e10f3c3a" />

---


### **Repository Structure**

```
powerplay/
│
├─ README.md
├─ system_report.sh
├─ system-report.service
├─ system-report.timer
├─ cron_root.txt
├─ log-events.json
└─ screenshot/
```

### **Export Cron Jobs**

```bash
sudo crontab -l > cron_root.txt
```

### **Terminate EC2**

```bash
aws ec2 terminate-instances --instance-ids i-01fd78cef2b0bf5b2
```

---


### **✔ Replaced Cron With systemd Timer**

Service File:

```
/etc/systemd/system/system-report.service
```

Timer File:

```
/etc/systemd/system/system-report.timer
```

Enable Timer:

```bash
sudo systemctl enable --now system-report.timer
```

### **✔ Disk Usage Email Alert**

Added to script:

```bash
echo "$ALERT_BODY" | mail -s "$ALERT_SUBJECT" devops_intern
```
### Disk Usage Email Alert

At the end of `system_report.sh`, a disk usage alert is implemented:

```bash
DISK_USAGE_PERCENT=$(df -h / | awk 'NR==2 {gsub(/%/, "", $5); print $5}')
THRESHOLD=80

if [ "$DISK_USAGE_PERCENT" -gt "$THRESHOLD" ]; then
  ALERT_SUBJECT="High Disk Usage on $(hostname) - ${DISK_USAGE_PERCENT}%"
  ALERT_BODY="Warning: Disk usage on $(hostname) has reached ${DISK_USAGE_PERCENT}%.
Current value: ${DISK_USAGE_PERCENT}%
Log file: /var/log/system_report.log
Time: $(date)"

  echo "$ALERT_BODY" | mail -s "$ALERT_SUBJECT" nikhilmaradani71@gmail.com
fi
```

Check emails:

```bash
mail
```
<img width="837" height="108" alt="image" src="https://github.com/user-attachments/assets/3e559128-6083-4760-9cd4-1537a813c631" />
<img width="1113" height="421" alt="image" src="https://github.com/user-attachments/assets/ceeba40a-6969-4c09-b2db-9fde42e2c983" />


## 📸 Screenshots (Final Submission)
---
## **📌 User creation + hostname**
<img width="751" height="186" alt="1" src="https://github.com/user-attachments/assets/2add118c-2cab-402b-93a5-c79dc351360f" />

---
## **📌 Server webpage**
<img width="1918" height="1020" alt="2" src="https://github.com/user-attachments/assets/bc264d41-ec6d-4990-8ff3-509599a96a7a" />

---
## **📌 Log file output**
<img width="1897" height="755" alt="3" src="https://github.com/user-attachments/assets/9dea56e4-5287-4ed5-b574-15bd6b9da037" />

---
## **📌 CloudWatch logs**
<img width="1918" height="1020" alt="image" src="https://github.com/user-attachments/assets/9aaee1b8-cc98-4486-85b2-03781e992406" />

---

## **🚀 Final Result**

This project demonstrates real-world DevOps tasks including monitoring, automation, AWS logging, and system orchestration using `systemd` and CloudWatch.
