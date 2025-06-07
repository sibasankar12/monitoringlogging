# **Comprehensive Prometheus Lecture Notes & Training Material**  

---

## **1. Introduction to Prometheus**  
### **1.1 What is Prometheus?**  
Prometheus is an open-source **monitoring and alerting toolkit** designed for **reliability and scalability**. Originally developed at **SoundCloud** in 2012, it became the **second hosted project** (after Kubernetes) in the **Cloud Native Computing Foundation (CNCF)** and **graduated in 2018**.  

#### **Key Characteristics**  
- **Multi-dimensional data model** (time series identified by metric name + key-value pairs).  
- **Pull-based scraping** (HTTP-based metric collection).  
- **PromQL**: A powerful query language for slicing/dicing time-series data.  
- **Standalone & decentralized** (no reliance on distributed storage).  
- **Integrated Alerting** (via Alertmanager).  

#### **Comparison with Other Tools**  
| Tool | Architecture | Data Model | Strengths | Weaknesses |  
|------|-------------|------------|-----------|------------|  
| **Prometheus** | Pull-based | Multi-dimensional | High scalability, Kubernetes-native | No long-term storage (without Thanos/Cortex) |  
| **Graphite** | Push-based | Hierarchical | Simple, mature | Limited query flexibility |  
| **InfluxDB** | Push/Pull | Tag-based | High write performance | Complex clustering |  
| **Datadog** | SaaS | Multi-dimensional | Full-stack monitoring | Expensive at scale |  

---

## **2. Prometheus Architecture (Deep Dive)**  
### **2.1 Core Components**  

#### **1. Prometheus Server**  
- **Retrieval (Scraping)**: Pulls metrics from configured targets via HTTP.  
- **Storage**: Time-Series Database (TSDB) with local storage (optionally remote-write).  
- **HTTP Server**: Serves PromQL queries and Web UI.  

#### **2. Exporters**  
- **Purpose**: Bridge between Prometheus and 3rd-party systems.  
- **Types**:  
  - **Node Exporter** (hardware/OS metrics).  
  - **Blackbox Exporter** (probes for HTTP, TCP, ICMP).  
  - **Database Exporters** (MySQL, PostgreSQL, MongoDB).  

#### **3. Pushgateway**  
- **Use-case**: Metrics from short-lived jobs (e.g., cron jobs).  
- **How it works**: Jobs push metrics → Prometheus scrapes Pushgateway.  

#### **4. Alertmanager**  
- **Responsibilities**:  
  - Deduplication of alerts.  
  - Grouping (e.g., all alerts from a cluster).  
  - Routing (email, Slack, PagerDuty).  

#### **5. Service Discovery**  
- **Supported Mechanisms**:  
  - Kubernetes  
  - AWS EC2  
  - Consul  
  - Static Configs  

### **2.2 Data Flow**  
1. **Scrape**: Targets are scraped at configured intervals (`scrape_interval`).  
2. **Store**: Compressed and stored in TSDB (default retention: 15d).  
3. **Evaluate Rules**: Recording/Alerts rules are processed.  
4. **Alertmanager**: Fires notifications if conditions are met.  

---

## **3. Prometheus Variants & Deployment Models**  
### **3.1 Standalone Prometheus**  
- **Pros**: Simple, low latency.  
- **Cons**: No HA, limited retention.  

### **3.2 Federated Prometheus**  
- **Hierarchy**:  
  - **Leaf Prometheus**: Scrapes local targets.  
  - **Global Prometheus**: Aggregates data from leaves.  

### **3.3 Scalable Prometheus (Thanos/Cortex/Mimir)**  

#### **Thanos**  
- **Components**:  
  - **Sidecar**: Attaches to Prometheus, uploads data to object storage.  
  - **Store Gateway**: Queries historical data from S3/GCS.  
  - **Query**: Unified view across clusters.  

#### **Cortex/Mimir**  
- **Features**:  
  - Multi-tenancy.  
  - Horizontal scaling.  

### **3.4 Managed Prometheus Services**  

#### **Amazon Managed Service for Prometheus (AMP)**  
- **Integration**: Works with EKS, IAM for security.  
- **Pricing**: Pay per query & storage.  

#### **Google Cloud Managed Service for Prometheus**  
- **Features**:  
  - Fully compatible with PromQL.  
  - Integrated with Cloud Monitoring.  

---

## **4. Key Metrics & Alerting**  
### **4.1 Infrastructure Monitoring**  
#### **CPU**  
```promql
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)  
```  

#### **Memory**  
```promql
(node_memory_MemTotal_bytes - node_memory_MemFree_bytes) / node_memory_MemTotal_bytes * 100  
```  

### **4.2 Kubernetes Monitoring**  
#### **Pod Restarts**  
```promql
kube_pod_container_status_restarts_total  
```  

#### **OOM Kills**  
```promql
container_memory_working_set_bytes / container_spec_memory_limit_bytes > 0.9  
```  

### **4.3 Alerting Rules Example**  
```yaml
groups:
- name: node-alerts
  rules:
  - alert: HighDiskUsage
    expr: (node_filesystem_avail_bytes{mountpoint="/"} * 100) / node_filesystem_size_bytes{mountpoint="/"} < 10
    for: 10m
    labels:
      severity: critical
    annotations:
      summary: "High disk usage on {{ $labels.instance }}"
```

---

## **5. Hands-On Labs**  
### **Lab 1: Deploy Prometheus on AWS Graviton**  
```bash
wget https://github.com/prometheus/prometheus/releases/download/v2.53.4/prometheus-2.53.4.linux-arm64.tar.gz
tar -xvzf prometheus-*.tar.gz
sudo mv prometheus promtool /usr/local/bin/
```  

### **Lab 2: Configure HA with Thanos**  
```yaml
# thanos-sidecar.yml
sidecar:
  prometheus:
    http_address: "0.0.0.0:9090"
  objstore:
    type: S3
    config:
      bucket: "thanos-storage"
      endpoint: "s3.amazonaws.com"
```  

### **Lab 3: Optimize PromQL Queries**  
```promql
# Top 5 CPU-consuming pods
topk(5, sum by (pod) (rate(container_cpu_usage_seconds_total[5m])))
```  

---

## **6. Advanced Topics**  
### **6.1 Remote Write**  
```yaml
remote_write:
  - url: "http://thanos-receive:10908/api/v1/receive"
```  

### **6.2 Recording Rules**  
```yaml
groups:
- name: cpu-recording
  rules:
  - record: instance:node_cpu:avg_rate5m
    expr: avg by (instance) (rate(node_cpu_seconds_total[5m]))
```  

### **6.3 Scaling Best Practices**  
- **Sharding**: Split targets across multiple Prometheus servers.  
- **Metrics Relabeling**: Drop unnecessary metrics.  

---

## **7. Assessment Questions**  
1. **Architecture**: Explain how Prometheus scrapes metrics in a Kubernetes cluster.  
2. **Scalability**: Compare Thanos and Cortex.  
3. **Troubleshooting**: Write a PromQL query to find HTTP 5xx errors.  

---

## **8. References**  
- **Books**: *Prometheus: Up & Running* by Brian Brazil.  
- **Courses**: [Prometheus Certified Associate (PCA)](https://training.linuxfoundation.org/).  
