# **Installing Prometheus on ARM64 (AArch64) AWS Graviton Instances**  

Prometheus is a powerful open-source monitoring and alerting toolkit. With the rise of ARM64-based cloud instances (such as AWS Graviton), running Prometheus efficiently on these systems requires the correct binary.  

In this guide, we’ll:  
✅ Install Prometheus on an **ARM64 (AArch64) Ubuntu 22.04 AWS Graviton instance**.  
✅ Configure it as a **systemd service** for auto-start on boot.  

---

## **1. Verify System Architecture**  
Before installing, confirm your machine is **ARM64 (AArch64)**. Run:  
```sh
uname -m
# Output should be: aarch64
```

If you’re on an AWS Graviton instance (like `t4g` or `c7g`), you’ll see:  
```sh
Linux ip-172-31-20-190 6.5.0-1017-aws #17~22.04.2-Ubuntu SMP aarch64 aarch64 aarch64 GNU/Linux
```
This confirms you need the **`linux-arm64`** version of Prometheus.  

---

## **2. Download and Install Prometheus for ARM64**  

### **Download the Latest ARM64 Binary**  
```sh
wget https://github.com/prometheus/prometheus/releases/download/v2.53.4/prometheus-2.53.4.linux-arm64.tar.gz
```

### **Extract and Move to `/usr/local/bin`**  
```sh
tar -xvzf prometheus-2.53.4.linux-arm64.tar.gz
cd prometheus-2.53.4.linux-arm64/
sudo mv prometheus promtool /usr/local/bin/
```

### **Verify Installation**  
```sh
prometheus --version
# Should output: Prometheus 2.53.4 (built for linux-arm64)
```

---

## **3. Configure Prometheus**  

### **Create a Dedicated User (Security Best Practice)**  
```sh
sudo useradd --no-create-home --shell /bin/false prometheus
```

### **Set Up Directories**  
```sh
sudo mkdir -p /etc/prometheus /var/lib/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
```

### **Copy Default Config**  
```sh
sudo cp prometheus.yml /etc/prometheus/
sudo cp consoles/ console_libraries/ /etc/prometheus/ -r
sudo chown -R prometheus:prometheus /etc/prometheus
```

---

## **4. Create a Systemd Service for Auto-Start**  

### **Create the Service File**  
```sh
sudo nano /etc/systemd/system/prometheus.service
```

Paste the following (adjust paths if needed):  
```ini
[Unit]
Description=Prometheus Monitoring
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries
Restart=always

[Install]
WantedBy=multi-user.target
```

### **Reload Systemd and Start Prometheus**  
```sh
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
```

### **Check Status**  
```sh
sudo systemctl status prometheus
# Should show "active (running)"
```

---

## **5. Access Prometheus Web UI**  
By default, Prometheus runs on port `9090`.  

### **Open in Browser (if AWS Security Group allows)**  
```sh
curl http://localhost:9090
```
Or, access via:  
`http://<YOUR_AWS_PUBLIC_IP>:9090`

---

## **Conclusion**  
You’ve successfully installed Prometheus on an **ARM64 (AWS Graviton) Ubuntu** machine and configured it as a **systemd service**. Now, it will:  
- Auto-start on boot (`systemctl enable`)  
- Run securely under a dedicated user  
- Store metrics in `/var/lib/prometheus`  

For production setups, consider:  
🔹 Securing with HTTPS (Nginx reverse proxy)  
🔹 Adding Alertmanager (`alertmanager.service`)  
🔹 Setting up persistent storage (EBS volumes)  

