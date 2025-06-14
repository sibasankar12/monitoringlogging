# **Lab Tutorial: ELK Stack Installation on Ubuntu Linux**  

## **Introduction to the ELK Stack**  

The **ELK Stack** (Elasticsearch, Logstash, Kibana) is a powerful open-source solution for log management, data analytics, and visualization. Developed by **Elastic NV**, it is widely used for centralized logging, real-time monitoring, and business intelligence.  

### **1. Elasticsearch**  
- **Developed by:** Shay Banon (2004, later open-sourced in 2010).  
- **Purpose:** Distributed search and analytics engine for storing and querying large datasets.  
- **Key Features:**  
  - Near real-time search.  
  - Scalable and fault-tolerant.  
  - RESTful API for easy integration.  

### **2. Logstash**  
- **Developed by:** Jordan Sissel (2009, later acquired by Elastic).  
- **Purpose:** Data processing pipeline for ingesting, transforming, and forwarding logs.  
- **Key Features:**  
  - Supports multiple input sources (files, databases, APIs).  
  - Filtering and enrichment capabilities.  
  - Output to Elasticsearch, Kafka, etc.  

### **3. Kibana**  
- **Developed by:** Elastic NV (2013).  
- **Purpose:** Visualization and dashboarding tool for Elasticsearch data.  
- **Key Features:**  
  - Interactive dashboards.  
  - Real-time analytics.  
  - User-friendly UI for log exploration.  

### **Support & Licensing**  
- **Open-Source (Free Tier):** Basic features available under the **Apache 2.0** license.  
- **Enterprise Tier:** Advanced security, monitoring, and support (paid).  
- **Community & Documentation:** [Elastic Official Docs](https://www.elastic.co/guide/index.html).  

---

## **Lab Objectives**  
✔ Install **Elasticsearch, Logstash, and Kibana (ELK Stack)** on **Ubuntu Linux**.  
✔ Verify each component is running correctly.  
✔ Validate package integrity and dependencies.  

---

## **Lab Prerequisites**  
- **Operating System:** Ubuntu 20.04/22.04 LTS (64-bit).  
- **Hardware Requirements:**  
  - Minimum **2 CPU cores, 4GB RAM, 20GB disk space**.  
  - Recommended **4 CPU cores, 8GB RAM** for production.  
- **User Permissions:** `sudo` access for package installation.  
- **Network:** Internet connectivity for downloading packages.  

---

## **Step 1: Install Java (ELK Dependency)**  
Elasticsearch requires **Java 11+**. Install OpenJDK:  

```bash
sudo apt update
sudo apt install -y openjdk-11-jdk
```  

**Verify Java Installation:**  
```bash
java -version
```  
**Expected Output:**  
```
openjdk version "11.0.xx"
```  

---

## **Step 2: Install Elasticsearch**  

### **1. Add Elasticsearch Repository**  
```bash
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elastic-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/elastic-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list
```  

### **2. Install Elasticsearch**  
```bash
sudo apt update
sudo apt install -y elasticsearch
```  

### **3. Configure Elasticsearch**  
Edit the config file:  
```bash
sudo nano /etc/elasticsearch/elasticsearch.yml
```  
Uncomment/modify:  
```yaml
network.host: 0.0.0.0  
http.port: 9200  
cluster.initial_master_nodes: ["your-hostname"]  
```  

### **4. Start & Enable Elasticsearch**  
```bash
sudo systemctl start elasticsearch
sudo systemctl enable elasticsearch
```  

### **5. Verify Elasticsearch**  
```bash
curl -X GET "localhost:9200"
```  
**Expected Output:** JSON response with cluster details.  

---

## **Step 3: Install Logstash**  

### **1. Install Logstash**  
```bash
sudo apt install -y logstash
```  

### **2. Validate Logstash**  
Test a basic pipeline:  
```bash
echo 'input { stdin { } } output { stdout {} }' | sudo /usr/share/logstash/bin/logstash -e 'input { stdin { } } output { stdout {} }'
```  
Type a message (e.g., "Hello ELK") and check output.  

### **3. Start Logstash**  
```bash
sudo systemctl start logstash
sudo systemctl enable logstash
```  

---

## **Step 4: Install Kibana**  

### **1. Install Kibana**  
```bash
sudo apt install -y kibana
```  

### **2. Configure Kibana**  
Edit `/etc/kibana/kibana.yml`:  
```yaml
server.port: 5601  
server.host: "0.0.0.0"  
elasticsearch.hosts: ["http://localhost:9200"]  
```  

### **3. Start & Enable Kibana**  
```bash
sudo systemctl start kibana
sudo systemctl enable kibana
```  

### **4. Access Kibana**  
Open in browser:  
```
http://<your-server-ip>:5601
```  

---

## **Step 5: Validate ELK Stack**  

### **1. Check Services**  
```bash
sudo systemctl status elasticsearch logstash kibana
```  
All services should show **active (running)**.  

### **2. Test Data Flow**  
- Send a test log via Logstash to Elasticsearch.  
- Verify in Kibana **Discover** tab.  

---

## **Troubleshooting**  
| **Issue**                  | **Solution**                          |  
|----------------------------|---------------------------------------|  
| Elasticsearch not starting | Check logs: `journalctl -u elasticsearch` |  
| Kibana inaccessible        | Verify `server.host` and firewall (`sudo ufw allow 5601`) |  
| Java errors                | Reinstall OpenJDK: `sudo apt install --reinstall openjdk-11-jdk` |  

---

## **Summary**  
✔ Installed **Java 11** (ELK dependency).  
✔ Configured **Elasticsearch** (port 9200).  
✔ Set up **Logstash** for log ingestion.  
✔ Deployed **Kibana** (port 5601) for visualization.  

## **Further Reading**  
- [Elasticsearch Docs](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)  
- [Logstash Pipelines](https://www.elastic.co/guide/en/logstash/current/configuration.html)  
- [Kibana Dashboards](https://www.elastic.co/guide/en/kibana/current/index.html)  
