# **Lab Tutorial 04: Configuring Filebeat for Log Collection**

## **Introduction**
Filebeat is a lightweight shipper for forwarding and centralizing log data. As part of the Elastic Stack, it collects logs from specified files and forwards them either to Elasticsearch or Logstash for processing. This lab guides you through installing and configuring Filebeat to monitor system logs and ship them to the ELK Stack.

## **Objective**
- Install and configure Filebeat on Ubuntu
- Enable system module for log collection
- Validate log shipping to Logstash/Elasticsearch
- Verify logs in Kibana

## **Lab Prerequisites**
- Ubuntu 20.04/22.04 LTS
- ELK Stack installed (Elasticsearch, Logstash, Kibana)
- Sudo privileges
- Internet access for package installation

---

## **Lab Steps**

### **Step 1: Install Filebeat**

1. Update system packages:
```bash
sudo apt update
```

2. Install Java runtime (if not present):
```bash
sudo apt install -y default-jre
```

3. Add Elasticsearch GPG key:
```bash
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
```

4. Add Elastic repository:
```bash
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list
```

5. Install Filebeat:
```bash
sudo apt update && sudo apt install -y filebeat
```

### **Step 2: Configure Filebeat**

1. Edit configuration file:
```bash
sudo nano /etc/filebeat/filebeat.yml
```

2. Configure Logstash output (comment Elasticsearch output):
```yaml
output.logstash:
  hosts: ["localhost:5044"]
```

3. Enable system module:
```bash
sudo filebeat modules enable system
```

4. Load Kibana dashboards:
```bash
sudo filebeat setup
```

### **Step 3: Start Filebeat Service**

1. Start and enable service:
```bash
sudo systemctl start filebeat
sudo systemctl enable filebeat
```

2. Verify status:
```bash
sudo systemctl status filebeat
```

---

## **Validation Steps**

### **1. Verify Logstash Receiving Logs**
Configure Logstash with this test config:
```bash
sudo nano /etc/logstash/conf.d/filebeat.conf
```
```plaintext
input {
  beats {
    port => 5044
  }
}
output {
  stdout { codec => rubydebug }
}
```
Restart Logstash and check for incoming logs:
```bash
sudo systemctl restart logstash
```

### **2. Verify Elasticsearch Index**
Check for Filebeat indices:
```bash
curl -XGET "http://localhost:9200/_cat/indices/filebeat*?v"
```

### **3. Verify in Kibana**
1. Access Kibana at `http://localhost:5601`
2. Navigate to **Discover**
3. Create data view for `filebeat-*` pattern
4. Verify system logs are visible

---

## **Common Errors & Troubleshooting**

| Error | Solution |
|-------|----------|
| "Connection refused" from Filebeat | Verify Logstash is running and listening on port 5044 |
| No indices in Elasticsearch | Check Filebeat logs: `journalctl -u filebeat` |
| "Permission denied" errors | Ensure Filebeat user has read access to log files |
| Dashboard setup fails | Manually run `filebeat setup --dashboards` |

**Debugging Commands:**
```bash
# Check Filebeat logs
sudo journalctl -u filebeat -f

# Test Filebeat configuration
sudo filebeat test config

# Verify Elasticsearch connection
sudo filebeat test output
```

---

## **Summary**
✔ Installed and configured Filebeat  
✔ Enabled system module for log collection  
✔ Verified log shipping to Logstash and Elasticsearch  
✔ Confirmed data visibility in Kibana  

## **Further Reading**
- [Filebeat Documentation](https://www.elastic.co/guide/en/beats/filebeat/current/index.html)
- [Filebeat Modules Reference](https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-modules.html)
- [Logstash Beats Input](https://www.elastic.co/guide/en/logstash/current/plugins-inputs-beats.html)

