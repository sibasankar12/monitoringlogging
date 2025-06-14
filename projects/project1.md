# **Monitoring and Logging - Project 1**  
**Course-End Project Document**  

---

## **i) Introduction**  
In today's fast-paced digital landscape, monitoring application performance and logging critical metrics are essential for maintaining system reliability and improving user experience. This project focuses on implementing a robust monitoring solution for a Java application using **Prometheus** for metrics collection and **Grafana** for visualization.  

The retail company in this scenario aims to transition to a DevOps architecture, automating monitoring across its online platforms and physical stores. By leveraging Prometheus and Grafana, the company can detect issues faster, optimize performance, and enhance operational efficiency.  

---

## **ii) Objective**  
The primary objective of this project is to:  
- Implement **continuous monitoring** of a Java application by collecting metrics (e.g., API response times, stock levels, sales performance).  
- Configure **Prometheus** to scrape and store these metrics.  
- Use **Grafana** to create interactive dashboards for real-time visualization.  
- Automate feedback loops for faster issue detection and resolution.  

---

## **iii) Prerequisites**  
Before starting the project, ensure the following prerequisites are met:  
1. **Basic knowledge of:**  
   - Linux command line  
   - Java programming  
   - DevOps concepts (CI/CD, monitoring)  
2. **Software/Tools required:**  
   - A Linux-based environment (Ubuntu/CentOS)  
   - Java Development Kit (JDK)  
   - Prometheus (installed and configured)  
   - Grafana (installed and configured)  
   - A Java application (for publishing custom metrics)  
3. **Access to:**  
   - A terminal for executing commands  
   - Web browser for accessing Prometheus and Grafana dashboards  

---

## **iv) Technical Information**  
### **Key Tools & Technologies:**  
1. **Prometheus**  
   - Open-source monitoring and alerting toolkit.  
   - Collects and stores time-series data.  
   - Uses a **pull-based** model to scrape metrics from applications.  
   - Supports **PromQL** for querying metrics.  

2. **Grafana**  
   - Open-source visualization platform.  
   - Connects to Prometheus as a data source.  
   - Provides customizable dashboards with graphs, gauges, and alerts.  

3. **Java Application**  
   - Uses **Micrometer** (a metrics instrumentation library) to expose Prometheus-compatible metrics.  
   - Publishes custom metrics (e.g., API response time, error rates).  

---

## **v) Implementation Approach**  
The project will be implemented in the following phases:  
1. **Setup & Installation:**  
   - Install Prometheus and Grafana on a Linux server.  
2. **Java Application Configuration:**  
   - Instrument the Java app to expose metrics via an HTTP endpoint.  
3. **Prometheus Configuration:**  
   - Define scrape jobs to collect metrics from the Java app.  
4. **Grafana Configuration:**  
   - Connect Grafana to Prometheus.  
   - Design dashboards for visualizing metrics.  
5. **Validation:**  
   - Verify metrics collection and dashboard functionality.  

---

## **vi) Implementation Steps**  

### **Task 1: Install Prometheus**  
1. Log in to the Linux terminal.  
2. Download and install Prometheus:  
   ```bash
   wget https://github.com/prometheus/prometheus/releases/download/v2.30.0/prometheus-2.30.0.linux-amd64.tar.gz
   tar -xvf prometheus-2.30.0.linux-amd64.tar.gz
   cd prometheus-2.30.0.linux-amd64
   ```
3. Configure `prometheus.yml` to scrape the Java app:  
   ```yaml
   scrape_configs:
     - job_name: 'java_app'
       metrics_path: '/actuator/prometheus'
       static_configs:
         - targets: ['localhost:8080']
   ```
4. Start Prometheus:  
   ```bash
   ./prometheus --config.file=prometheus.yml
   ```
5. Access Prometheus UI at `http://<server-ip>:9090`.  

---

### **Task 2: Configure Java Application Metrics**  
1. Add **Micrometer Prometheus** dependency to the Java app (`pom.xml` for Maven):  
   ```xml
   <dependency>
       <groupId>io.micrometer</groupId>
       <artifactId>micrometer-registry-prometheus</artifactId>
       <version>1.7.0</version>
   </dependency>
   ```
2. Enable metrics endpoint in `application.properties`:  
   ```properties
   management.endpoints.web.exposure.include=prometheus,health,metrics
   management.endpoint.prometheus.enabled=true
   ```
3. Run the Java app and verify metrics at `http://localhost:8080/actuator/prometheus`.  

---

### **Task 3: Install and Configure Grafana**  
1. Install Grafana:  
   ```bash
   sudo apt-get install -y grafana
   sudo systemctl start grafana-server
   ```
2. Access Grafana at `http://<server-ip>:3000` (default login: admin/admin).  
3. Add Prometheus as a data source:  
   - Go to **Configuration > Data Sources > Add data source**.  
   - Select **Prometheus**, enter URL `http://localhost:9090`.  
   - Click **Save & Test**.  

---

### **Task 4: Create a Metrics Dashboard**  
1. In Grafana, create a new dashboard.  
2. Add a **Time Series** panel to track API response times.  
3. Use PromQL query:  
   ```promql
   http_server_requests_seconds_count{uri="/api/products"}
   ```
4. Add a **Gauge** for error rates:  
   ```promql
   rate(http_server_requests_seconds_count{status="500"}[5m])
   ```
5. Save the dashboard.  

---

## **vii) Validation of the Solution**  
To ensure the solution works correctly:  
1. **Check Prometheus Targets:**  
   - Go to `http://<server-ip>:9090/targets`.  
   - Verify the Java app target is **UP**.  
2. **Verify Metrics in Prometheus:**  
   - Execute a PromQL query (e.g., `up`) to confirm data collection.  
3. **Check Grafana Dashboard:**  
   - Ensure graphs display real-time metrics.  
   - Test dashboard interactivity (time range adjustments, filters).  
4. **Simulate Load & Monitor:**  
   - Use `curl` or Postman to send API requests.  
   - Observe metric changes in Grafana.  

---

## **Conclusion**  
This project successfully implements **Prometheus + Grafana** for monitoring a Java application, enabling real-time visibility into system performance. By automating feedback loops, the retail company can now detect and resolve issues faster, improving operational efficiency and customer satisfaction.  
