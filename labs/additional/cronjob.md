# **Lab: Automating Metric Pushing with a Cron Job**

## **Introduction**
This lab demonstrates how to collect metrics from short-lived jobs using Prometheus Pushgateway. You'll learn to configure a cron job that periodically pushes metrics to Pushgateway, which Prometheus then scrapes for visualization. This pattern is essential for monitoring batch jobs, scheduled tasks, and other ephemeral processes.

Key concepts covered:
- Pushgateway architecture and use cases
- Metric pushing from shell scripts
- Cron job scheduling
- Prometheus target configuration

---

## **Objective**
By completing this lab, you will:
1. Set up and configure Prometheus Pushgateway
2. Create a bash script to push custom metrics
3. Automate metric collection using cron
4. Validate the end-to-end metric pipeline
5. Visualize pushed metrics in Prometheus

---

## **Prerequisites**
- Linux server (Ubuntu/CentOS recommended)
- Prometheus installed and running
- Basic terminal/command line knowledge
- Ports 9090 (Prometheus) and 9091 (Pushgateway) accessible
- `curl` and `cron` packages installed

---

## **Lab Steps**

### **1. Install and Configure Pushgateway**

1. Download the latest Pushgateway release:
   ```bash
   wget https://github.com/prometheus/pushgateway/releases/download/v1.6.1/pushgateway-1.6.1.linux-amd64.tar.gz
   ```

2. Extract and install:
   ```bash
   tar xvfz pushgateway-*.tar.gz
   cd pushgateway-*/
   sudo mv pushgateway /usr/local/bin/
   ```

3. Create systemd service (for proper process management):
   ```bash
   sudo nano /etc/systemd/system/pushgateway.service
   ```

4. Add this service configuration:
   ```ini
   [Unit]
   Description=Prometheus Pushgateway
   After=network.target

   [Service]
   User=pushgateway
   Group=pushgateway
   ExecStart=/usr/local/bin/pushgateway
   Restart=always

   [Install]
   WantedBy=multi-user.target
   ```

5. Start and enable the service:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl start pushgateway
   sudo systemctl enable pushgateway
   ```

6. Verify installation:
   ```bash
   curl http://localhost:9091/metrics
   ```

---

### **2. Configure Prometheus to Scrape Pushgateway**

1. Edit Prometheus configuration:
   ```bash
   sudo nano /etc/prometheus/prometheus.yml
   ```

2. Add Pushgateway scrape config:
   ```yaml
   scrape_configs:
     - job_name: 'pushgateway'
       honor_labels: true  # Crucial for pushed metrics
       static_configs:
         - targets: ['localhost:9091']
       scrape_interval: 15s
   ```

3. Reload Prometheus:
   ```bash
   sudo systemctl reload prometheus
   ```

---

### **3. Create Metric Pushing Script**

1. Create script directory:
   ```bash
   mkdir -p ~/metrics_scripts
   cd ~/metrics_scripts
   ```

2. Create push script:
   ```bash
   nano push_metrics.sh
   ```

3. Add this script content:
   ```bash
   #!/bin/bash

   # Configuration
   PUSHGATEWAY="localhost:9091"
   JOB_NAME="batch_job"
   METRIC_NAME="job_duration_seconds"

   # Generate metric value (current timestamp)
   METRIC_VALUE=$(date +%s)

   # Prepare metric payload
   cat <<EOF | curl --data-binary @- http://${PUSHGATEWAY}/metrics/job/${JOB_NAME}
   # TYPE ${METRIC_NAME} gauge
   # HELP ${METRIC_NAME} Duration of job execution in seconds
   ${METRIC_NAME} ${METRIC_VALUE}
   EOF

   echo "Metric pushed at $(date)"
   ```

4. Make script executable:
   ```bash
   chmod +x push_metrics.sh
   ```

---

### **4. Schedule with Cron**

1. Edit crontab:
   ```bash
   crontab -e
   ```

2. Add this line to run every minute:
   ```bash
   * * * * * /bin/bash /home/$USER/metrics_scripts/push_metrics.sh >> /home/$USER/metrics_scripts/push.log 2>&1
   ```

3. Verify cron job:
   ```bash
   tail -f /home/$USER/metrics_scripts/push.log
   ```

---

### **5. Validate the Setup**

1. Check Pushgateway metrics:
   ```bash
   curl http://localhost:9091/metrics | grep batch_job
   ```

2. Query in Prometheus UI (`http://localhost:9090`):
   ```promql
   batch_job_job_duration_seconds
   ```

3. Check targets status:
   ```
   http://localhost:9090/targets
   ```

---

## **Troubleshooting Guide**

| Issue | Solution |
|-------|----------|
| No metrics in Pushgateway | Verify script is executable and cron is running (`systemctl status cron`) |
| Prometheus not scraping | Check target status at `http://localhost:9090/targets` |
| Permission denied errors | Ensure user has execute permissions on the script |
| Metrics not appearing | Verify `honor_labels: true` in Prometheus config |

---

## **Further Reading**
- [Pushgateway Documentation](https://github.com/prometheus/pushgateway)
- [Prometheus Metric Types](https://prometheus.io/docs/concepts/metric_types/)
- [Cron Job Scheduling Guide](https://www.man7.org/linux/man-pages/man5/crontab.5.html)
- [Advanced Pushgateway Patterns](https://prometheus.io/docs/practices/pushing/)

---

## **Conclusion**
You've successfully:
- Deployed Prometheus Pushgateway
- Created automated metric collection via cron
- Configured Prometheus to scrape pushed metrics
- Validated the end-to-end workflow

**Production Recommendations:**
1. Add authentication to Pushgateway
2. Implement proper job labeling
3. Set up metric expiration
4. Monitor Pushgateway resource usage

**Lab Duration:** 30-45 minutes  
**Skill Level:** Intermediate  
**Key Takeaways:**
- Understanding of push vs pull metrics
- Cron job configuration skills
- Metric pipeline troubleshooting

