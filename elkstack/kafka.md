# **Lab Tutorial 05: Building an Automated Log Processing Pipeline with Kafka and ELK Stack**

## **Introduction**
This lab demonstrates how to integrate Apache Kafka with the ELK Stack to create a resilient, high-volume log processing pipeline. Kafka acts as a buffer during log surges, protecting Logstash and Elasticsearch from overload while ensuring no data loss. You'll configure Filebeat to ship Apache logs to Kafka, then process them through Logstash into Elasticsearch.

## **Objective**
- Install and configure Apache Kafka as a message broker
- Set up Filebeat to forward logs to Kafka topics
- Configure Logstash to consume logs from Kafka
- Validate end-to-end log flow through the pipeline
- Visualize logs in Kibana

## **Lab Prerequisites**
- Ubuntu 20.04/22.04 LTS server
- Minimum 4GB RAM, 2 CPU cores
- ELK Stack (Elasticsearch 8.x, Logstash, Kibana) installed
- Java 11+ Runtime Environment
- Sudo privileges
- Internet access for package downloads

---

## **Lab Steps**

### **Step 1: System Setup and Java Installation**

1. Update system packages:
```bash
sudo apt update && sudo apt upgrade -y
```

2. Install Java Runtime:
```bash
sudo apt install -y default-jre
```

3. Verify Java installation:
```bash
java -version
```

### **Step 2: Kafka Installation and Configuration**

1. Install ZooKeeper (Kafka dependency):
```bash
sudo apt install -y zookeeperd
```

2. Download and install Kafka:
```bash
wget https://downloads.apache.org/kafka/3.8.0/kafka_2.12-3.8.0.tgz
tar -xvzf kafka_2.12-3.8.0.tgz
sudo mv kafka_2.12-3.8.0 /opt/kafka
```

3. Create systemd service for Kafka (create `/etc/systemd/system/kafka.service`):
```ini
[Unit]
Description=Apache Kafka Server
Requires=zookeeper.service
After=zookeeper.service

[Service]
Type=simple
ExecStart=/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties
ExecStop=/opt/kafka/bin/kafka-server-stop.sh
Restart=on-abnormal

[Install]
WantedBy=multi-user.target
```

4. Start and enable Kafka:
```bash
sudo systemctl start kafka
sudo systemctl enable kafka
```

5. Create Kafka topic for Apache logs:
```bash
/opt/kafka/bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic apache
```

### **Step 3: Configure Logstash Pipeline**

1. Create Logstash config file:
```bash
sudo nano /etc/logstash/conf.d/kafka-apache.conf
```

2. Add pipeline configuration:
```plaintext
input {
  kafka {
    bootstrap_servers => "localhost:9092"
    topics => ["apache"]
    codec => "json"
  }
}

filter {
  grok {
    match => { "message" => "%{COMBINEDAPACHELOG}" }
  }
  date {
    match => [ "timestamp", "dd/MMM/yyyy:HH:mm:ss Z" ]
  }
  geoip {
    source => "clientip"
  }
}

output {
  elasticsearch {
    hosts => ["http://localhost:9200"]
    index => "apache-logs-%{+YYYY.MM.dd}"
  }
  stdout { codec => rubydebug }
}
```

3. Restart Logstash:
```bash
sudo systemctl restart logstash
```

### **Step 4: Configure Filebeat**

1. Install Filebeat:
```bash
sudo apt install -y filebeat
```

2. Configure Filebeat to send to Kafka:
```bash
sudo nano /etc/filebeat/filebeat.yml
```
```yaml
filebeat.inputs:
- type: filestream
  enabled: true
  paths:
    - /var/log/apache2/access.log

output.kafka:
  hosts: ["localhost:9092"]
  topic: apache
  codec.json:
    pretty: false
```

3. Start Filebeat:
```bash
sudo systemctl start filebeat
sudo systemctl enable filebeat
```

### **Step 5: Generate Test Logs**

1. Install Apache:
```bash
sudo apt install -y apache2
```

2. Generate traffic:
```bash
for i in {1..100}; do curl localhost; done
```

---

## **Validation Steps**

### **1. Verify Kafka Topic**
```bash
/opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic apache --from-beginning
```

### **2. Check Elasticsearch Index**
```bash
curl -XGET "localhost:9200/_cat/indices/apache*?v"
```

### **3. Verify in Kibana**
1. Create index pattern `apache-logs-*`
2. Explore logs in Discover
3. Create visualizations of HTTP status codes, client IPs, etc.

---

## **Command Summary**

| Action | Command |
|--------|---------|
| Create Kafka topic | `/opt/kafka/bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --topic apache` |
| List Kafka topics | `/opt/kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092` |
| View Kafka messages | `/opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic apache` |
| Check Elasticsearch indices | `curl -XGET "localhost:9200/_cat/indices?v"` |
| Test Logstash config | `sudo /usr/share/logstash/bin/logstash -f /etc/logstash/conf.d/kafka-apache.conf --config.test_and_exit` |

---

## **Common Issues & Troubleshooting**

| Issue | Solution |
|-------|----------|
| Kafka not starting | Check ZooKeeper status: `sudo systemctl status zookeeper` |
| Logstash Kafka connection errors | Verify Kafka is running: `sudo systemctl status kafka` |
| No logs in Elasticsearch | Check Logstash logs: `journalctl -u logstash` |
| Filebeat not sending logs | Test Filebeat output: `sudo filebeat test output` |

---

## **Summary**
✔ Successfully integrated Kafka with ELK Stack  
✔ Configured resilient log pipeline with Kafka buffer  
✔ Processed Apache logs with Grok patterns in Logstash  
✔ Verified log flow from Filebeat → Kafka → Logstash → Elasticsearch  

## **Further Reading**
- [Kafka with ELK Best Practices](https://www.elastic.co/blog/just-enough-kafka-for-the-elastic-stack)
- [Logstash Kafka Input Plugin](https://www.elastic.co/guide/en/logstash/current/plugins-inputs-kafka.html)
- [Filebeat Kafka Output](https://www.elastic.co/guide/en/beats/filebeat/current/kafka-output.html)
