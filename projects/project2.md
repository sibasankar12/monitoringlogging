# **Monitoring and Logging - Project 2**  


### **Course-End Project Document**  
#### **Publishing Application Logs Directly to ELK Stack**  

---

## **i) Introduction**  
Modern applications generate vast amounts of logs, which are critical for debugging, performance monitoring, and security analysis. This project focuses on automating log collection, processing, and visualization using the **ELK Stack (Elasticsearch, Logstash, Kibana)** for a **NodeJS** application running in a **Dockerized** environment.  

The goal is to enable **General Insurance**, a global insurance provider, to transition to DevOps by implementing centralized log management. This will reduce mean time to resolution (MTTR), improve software quality, and provide real-time insights into application behavior.  

---

## **ii) Objective**  
The primary objectives are:  
- Deploy a scalable **ELK Stack** to ingest, process, and store logs.  
- Configure a **NodeJS** application to stream logs directly to Elasticsearch via **Filebeat**.  
- Visualize logs in **Kibana** with custom dashboards and alerts.  
- Ensure seamless integration with **Docker** for microservices logging.  

---

## **iii) Prerequisites**  
### **Technical Requirements**  
1. **Infrastructure:**  
   - Linux server (Ubuntu 20.04+) with Docker and Docker Compose installed.  
   - Minimum 4GB RAM, 2 CPU cores (Elasticsearch is resource-intensive).  
2. **Software:**  
   - NodeJS v14+ (for the application).  
   - Docker Engine v20.10+ and Docker Compose v2.2+.  
   - ELK Stack (Elasticsearch 8.x, Logstash 8.x, Kibana 8.x).  
   - Filebeat 8.x (lightweight log shipper).  
3. **Knowledge:**  
   - Basic Linux commands, Docker concepts, and NodeJS logging.  

---

## **iv) Technical Deep Dive**  
### **Key Components**  
1. **Elasticsearch**  
   - Distributed NoSQL database for log storage and retrieval.  
   - Uses inverted indices for fast full-text search (Lucene-based).  
   - REST API for CRUD operations (`GET /_cat/indices?v` for index health).  

2. **Logstash**  
   - Processes logs with **pipelines** (input → filter → output).  
   - Supports Grok patterns for parsing unstructured logs (e.g., `%{TIMESTAMP_ISO8601:timestamp}`).  

3. **Kibana**  
   - Visualizes Elasticsearch data with Lens, TSVB, and Dashboard tools.  
   - Supports **KQL (Kibana Query Language)** for filtering (`method: "GET" AND status: 200`).  

4. **Filebeat**  
   - Lightweight agent that forwards logs to Logstash/Elasticsearch.  
   - Uses **modules** for pre-built configurations (e.g., `nginx`, `docker`).  

5. **NodeJS Application**  
   - Uses **Winston** or **Morgan** for structured logging (JSON format preferred).  
   - Logs are written to `stdout` (Docker best practice) or files.  

---

## **v) Implementation Approach**  
1. **ELK Stack Deployment**  
   - Use Docker Compose for single-node ELK (suitable for PoC).  
   - For production, deploy Elasticsearch as a cluster with dedicated nodes.  

2. **Log Pipeline Design**  
   - **Option 1:** NodeJS → Filebeat → Elasticsearch (direct).  
   - **Option 2:** NodeJS → Filebeat → Logstash (for filtering) → Elasticsearch.  

3. **Kibana Customization**  
   - Create index patterns, visualizations, and dashboards.  
   - Set up alerts using **Elastic Alerting** (e.g., error rate > 5%).  

---

## **vi) Implementation Steps (Technical Depth)**  

### **Task 1: Install ELK Stack with Docker**  
1. Create `docker-compose.yml` for ELK:  
   ```yaml
   version: '3.8'
   services:
     elasticsearch:
       image: docker.elastic.co/elasticsearch/elasticsearch:8.6.2
       environment:
         - discovery.type=single-node
         - ES_JAVA_OPTS=-Xms1g -Xmx1g
       volumes:
         - es_data:/usr/share/elasticsearch/data
       ports:
         - "9200:9200"
   
     logstash:
       image: docker.elastic.co/logstash/logstash:8.6.2
       volumes:
         - ./logstash/pipeline:/usr/share/logstash/pipeline
       ports:
         - "5044:5044"
       depends_on:
         - elasticsearch
   
     kibana:
       image: docker.elastic.co/kibana/kibana:8.6.2
       ports:
         - "5601:5601"
       depends_on:
         - elasticsearch
   
   volumes:
     es_data:
   ```  
2. Start the stack:  
   ```bash
   docker-compose up -d
   ```  
3. Verify Elasticsearch:  
   ```bash
   curl -X GET "http://localhost:9200/_cluster/health?pretty"
   ```  

---

### **Task 2: Configure NodeJS to Log to Filebeat**  
1. Install **Winston** in NodeJS:  
   ```bash
   npm install winston
   ```  
2. Configure JSON logging (`logger.js`):  
   ```javascript
   const winston = require('winston');
   const logger = winston.createLogger({
     format: winston.format.json(),
     transports: [
       new winston.transports.File({ filename: '/var/log/nodeapp/app.log' }),
     ],
   });
   module.exports = logger;
   ```  
3. Mount logs to Filebeat in `docker-compose.yml`:  
   ```yaml
   nodeapp:
     image: node:14
     volumes:
       - ./app:/app
       - ./logs:/var/log/nodeapp
   ```  

---

### **Task 3: Deploy Filebeat**  
1. Create `filebeat.yml`:  
   ```yaml
   filebeat.inputs:
     - type: log
       paths:
         - /var/log/nodeapp/*.log
       json.keys_under_root: true
   
   output.elasticsearch:
     hosts: ["elasticsearch:9200"]
     indices:
       - index: "nodeapp-logs-%{+yyyy.MM.dd}"
   ```  
2. Add Filebeat to `docker-compose.yml`:  
   ```yaml
   filebeat:
     image: docker.elastic.co/beats/filebeat:8.6.2
     volumes:
       - ./filebeat.yml:/usr/share/filebeat/filebeat.yml
       - ./logs:/var/log/nodeapp
     depends_on:
       - elasticsearch
   ```  

---

### **Task 4: Visualize Logs in Kibana**  
1. Access Kibana at `http://localhost:5601`.  
2. Create an **index pattern** for `nodeapp-logs-*`.  
3. Build a dashboard:  
   - Use **Lens** to plot HTTP method distribution (e.g., `GET`, `POST`).  
   - Add a **Data Table** to show top error messages.  
   - Configure a **TSVB** (Time Series Visual Builder) for request rate.  

---

## **vii) Validation**  
1. **Verify Log Ingestion**:  
   ```bash
   curl -X GET "http://localhost:9200/nodeapp-logs-*/_search?pretty"
   ```  
   - Check for `"hits.total.value" > 0`.  

2. **Test Kibana Discover**:  
   - Filter logs by `level: "error"` or `method: "POST"`.  

3. **Alerting Test**:  
   - Simulate errors in NodeJS and trigger Kibana alerts.  

---

## **Conclusion**  
This project demonstrates a **production-ready** ELK Stack implementation for centralized log management. By leveraging Docker and Filebeat, General Insurance can now monitor application logs in real time, reducing downtime and accelerating DevOps workflows.  

**Next Steps:**  
- Add **APM (Application Performance Monitoring)** for end-to-end tracing.  
- Secure ELK with **TLS** and role-based access control (RBAC).  
- Scale Elasticsearch with **master/data/node separation**.  

