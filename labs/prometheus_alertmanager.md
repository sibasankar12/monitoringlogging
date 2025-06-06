# **Lab: Configuring Alertmanager for Email Notifications**

## **Introduction**
In modern infrastructure monitoring, real-time alerting is crucial for maintaining system reliability. This lab guides you through integrating Prometheus with Alertmanager to create an email notification system for critical system events. You'll learn to configure alert rules, set up email notifications, and validate the entire pipeline by simulating a system failure.

This hands-on exercise is designed for:
- DevOps engineers implementing monitoring solutions
- System administrators managing server infrastructure
- SRE professionals building alerting systems

---

## **Objective**
By completing this lab, you will:
1. Configure Prometheus to send alerts to Alertmanager
2. Set up email notifications for critical system events
3. Create meaningful alert rules for system monitoring
4. Validate the alerting system through controlled testing
5. Understand the end-to-end alert notification workflow

---

## **Prerequisites**
- Linux server (Ubuntu 20.04/22.04 recommended)
- Prometheus installed (v2.40+)
- Node Exporter installed (v1.5+)
- Gmail account or access to SMTP server
- Basic terminal proficiency
- Ports 9090, 9093, and 9100 accessible

---

## **Lab Steps**

### **1. Configure Prometheus for Alertmanager**

1. Navigate to your Prometheus directory:
   ```bash
   cd /etc/prometheus
   ```

2. Edit the main configuration file:
   ```bash
   sudo nano prometheus.yml
   ```

3. Add the Alertmanager configuration (ensure proper YAML indentation):
   ```yaml
   alerting:
     alertmanagers:
     - static_configs:
       - targets: ["localhost:9093"]
   
   rule_files:
     - '/etc/prometheus/rules.yml'
   ```

4. Create alert rules file:
   ```bash
   sudo nano rules.yml
   ```

5. Add these alert rules:
   ```yaml
   groups:
   - name: system-alerts
     rules:
     - alert: InstanceDown
       expr: up == 0
       for: 2m
       labels:
         severity: "critical"
       annotations:
         summary: "Instance {{ $labels.instance }} down"
         description: "{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 2 minutes"
   ```

---

### **2. Install and Configure Alertmanager**

1. Download the latest Alertmanager:
   ```bash
   wget https://github.com/prometheus/alertmanager/releases/download/v0.25.0/alertmanager-0.25.0.linux-amd64.tar.gz
   ```

2. Extract and install:
   ```bash
   tar xvfz alertmanager-*.tar.gz
   cd alertmanager-*/
   sudo mv alertmanager amtool /usr/local/bin/
   ```

3. Create configuration directory:
   ```bash
   sudo mkdir -p /etc/alertmanager
   ```

4. Create the configuration file:
   ```bash
   sudo nano /etc/alertmanager/alertmanager.yml
   ```

5. Configure email notifications (update with your credentials):
   ```yaml
   global:
     smtp_smarthost: 'smtp.gmail.com:587'
     smtp_from: 'your.email@gmail.com'
     smtp_auth_username: 'your.email@gmail.com'
     smtp_auth_password: 'your-app-password'
     smtp_require_tls: true
   
   route:
     group_by: ['alertname']
     group_wait: 30s
     group_interval: 5m
     repeat_interval: 3h
     receiver: 'email-team'
   
   receivers:
   - name: 'email-team'
     email_configs:
     - to: 'team-alerts@yourdomain.com'
       send_resolved: true
   ```

---

### **3. Start and Validate Services**

1. Start Alertmanager as a service:
   ```bash
   sudo alertmanager --config.file=/etc/alertmanager/alertmanager.yml
   ```

2. Restart Prometheus to apply changes:
   ```bash
   sudo systemctl restart prometheus
   ```

3. Verify services are running:
   ```bash
   ps aux | grep -E 'prometheus|alertmanager'
   ```

---

### **4. Test the Alert System**

1. Stop Node Exporter to trigger an alert:
   ```bash
   sudo systemctl stop node_exporter
   ```

2. Monitor alert status:
   ```bash
   watch -n 1 'curl -s http://localhost:9090/api/v1/alerts | jq .'
   ```

3. Check Alertmanager UI:
   ```
   http://localhost:9093
   ```

4. Verify email receipt (check spam folder)

5. Clean up by restarting Node Exporter:
   ```bash
   sudo systemctl start node_exporter
   ```

---

## **Troubleshooting Guide**

| Symptom | Solution |
|---------|----------|
| No alerts in Prometheus UI | Verify `rules.yml` path in prometheus.yml matches actual file location |
| Alertmanager not receiving alerts | Check Prometheus and Alertmanager logs with `journalctl -u prometheus -f` |
| Emails not being delivered | Test SMTP settings with `swaks` utility: `swaks --to test@example.com --from your.email@gmail.com --server smtp.gmail.com:587 -tls -au your.email@gmail.com -ap YOUR_PASSWORD` |
| Alerts not resolving | Ensure `send_resolved: true` is set in Alertmanager config |

---

## **Further Reading**
1. [Official Alertmanager Documentation](https://prometheus.io/docs/alerting/latest/alertmanager/)
2. [Prometheus Alerting Rules Guide](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/)
3. [Gmail SMTP Setup for Applications](https://support.google.com/accounts/answer/185833)
4. [Alertmanager Configuration Examples](https://github.com/prometheus/alertmanager/blob/main/doc/examples/simple.yml)

---

## **Conclusion**
In this lab, you've successfully:
- Configured Prometheus to forward alerts to Alertmanager
- Established email notifications for critical system events
- Created meaningful alert rules for infrastructure monitoring
- Validated the entire alerting pipeline through controlled testing

**Next Steps:**
1. Expand alert rules to monitor additional system metrics
2. Configure different severity levels and routing
3. Set up maintenance windows to prevent false alerts
4. Integrate with additional notification channels (Slack, PagerDuty)

**Lab Duration:** 45-60 minutes  
**Skill Level:** Intermediate  
**Key Takeaways:**
- Understanding of Prometheus-Alertmanager integration
- Practical experience with alert configuration
- Ability to troubleshoot notification pipelines

