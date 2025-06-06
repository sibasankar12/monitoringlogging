# Centralized Logging and Monitoring with ELK Stack: Complete Guide

## Table of Contents
1. [Introduction to Centralized Logging](#introduction-to-centralized-logging)
2. [ELK Stack Architecture](#elk-stack-architecture)
3. [Elasticsearch Deep Dive](#elasticsearch-deep-dive)
4. [Logstash Pipeline Configuration](#logstash-pipeline-configuration)
5. [Kibana Visualization Techniques](#kibana-visualization-techniques)
6. [Advanced Log Collection with Filebeat](#advanced-log-collection-with-filebeat)
7. [Kafka Integration for Scalability](#kafka-integration-for-scalability)
8. [CI/CD Pipeline Integration](#cicd-pipeline-integration)
9. [Real-World Case Studies](#real-world-case-studies)
10. [Best Practices](#best-practices)
11. [Hands-On Labs](#hands-on-labs)
12. [Further Resources](#further-resources)

---

## Introduction to Centralized Logging
### Why Centralized Logging?
- **Challenge:** Distributed systems generate logs across 100s of servers
- **Solution:** Aggregate logs in one place for:
  - Faster troubleshooting (mean time to resolution ↓ 70%)
  - Compliance auditing (HIPAA/GDPR ready)
  - Performance trend analysis

### Log Types in DevOps
| Log Type | Format Example | Use Case |
|----------|----------------|----------|
| **Application** | `{"level":"ERROR","msg":"DB connection failed"}` | Debugging errors |
| **System** | `Aug 23 10:00:01 server1 cron[1234]: Job completed` | Server health checks |
| **Audit** | `user=admin action=delete ip=192.168.1.1` | Security investigations |

---

## ELK Stack Architecture
### Component Breakdown
![ELK Stack Architecture](https://www.elastic.co/static-res/images/elk/elk-diagram.svg)

1. **Elasticsearch**  
   - Distributed JSON document store
   - Indexes logs for fast search (response in <100ms for TBs of data)

2. **Logstash**  
   - Processing pipeline:  
     ```
     Input → Filter (Grok, Mutate) → Output
     ```

3. **Kibana**  
   - Visualization layer with:
     - Canvas (pixel-perfect reports)
     - Lens (drag-and-drop analytics)
     - Machine learning (anomaly detection)

### Deployment Options
| Type | Pros | Cons | Best For |
|------|------|------|----------|
| **Self-Managed** | Full control | Maintenance overhead | Enterprises |
| **Elastic Cloud** | Auto-scaling | Vendor lock-in | Startups |
| **Hybrid** | Balance of both | Complex setup | Regulated industries |

---

## Elasticsearch Deep Dive
### Core Concepts
- **Index:** Logical namespace (e.g., `logs-2023.08`)
- **Shard:** Horizontal partition (default 5 shards/index)
- **Document:** JSON record with fields like `@timestamp`, `message`

### Optimizing for Logs
```yaml
# Index settings in elasticsearch.yml
index.refresh_interval: 30s  # Reduce write load
index.number_of_replicas: 1  # For fault tolerance
```

**Hot-Warm Architecture:**
- **Hot nodes:** SSDs for recent logs
- **Warm nodes:** HDDs for older logs (ILM policies auto-rotate)

---

## Logstash Pipeline Configuration
### Sample Pipeline for Apache Logs
```conf
input {
  file {
    path => "/var/log/apache2/*.log"
    start_position => "beginning"
  }
}

filter {
  grok {
    match => { "message" => "%{COMBINEDAPACHELOG}" }
  }
  date {
    match => [ "timestamp", "dd/MMM/yyyy:HH:mm:ss Z" ]
  }
}

output {
  elasticsearch {
    hosts => ["http://es01:9200"]
    index => "apache-%{+YYYY.MM.dd}"
  }
}
```

**Grok Patterns Cheatsheet:**
- `%{IP:client}` → Extract IP to `client` field
- `%{NUMBER:bytes}` → Convert to numeric

---

## Kibana Visualization Techniques
### Dashboard Design Principles
1. **Hierarchy:**  
   - Top: Summary stats (request rate, error %)
   - Middle: Trends (time-series graphs)
   - Bottom: Raw logs table

2. **Alert Setup:**
   ```yaml
   # Alert rule for error spikes
   condition: count() OVER 5m > 100 
   action: Post to Slack #prod-alerts
   ```

**Visualization Types:**
- **Geo Map:** Track global users
- **Heatmap:** Spot 5xx errors by hour
- **Markdown:** Add investigation notes

---

## Advanced Log Collection with Filebeat
### Lightweight Alternative to Logstash
```yaml
# filebeat.yml
filebeat.inputs:
- type: filestream
  paths: [/var/log/nginx/*.log]

output.elasticsearch:
  hosts: ["es01:9200"]
  pipeline: "nginx_parsing" 
```

**Benefits:**
- 10x lower CPU than Logstash
- Built-in modules for Nginx, MySQL, etc.

---

## Kafka Integration for Scalability
### Why Kafka?
- **Buffer** logs during Elasticsearch maintenance
- **Fan-out** to multiple consumers (SIEM, analytics)

```conf
# Logstash input from Kafka
input {
  kafka {
    bootstrap_servers => "kafka01:9092"
    topics => ["app_logs"]
  }
}
```

**Deployment Tip:**  
Use Kafka Connect with Elasticsearch Sink for direct ES writes

---

## CI/CD Pipeline Integration
### GitLab Example
1. **Filebeat on Runners:**
   ```yaml
   # .gitlab-ci.yml
   deploy:
     script:
       - curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.9.1-linux-x86_64.tar.gz
       - tar xzvf filebeat-8.9.1-linux-x86_64.tar.gz
       - ./filebeat setup -e
   ```

2. **Kibana Dashboard:**  
   Track build success rates, test durations

---

## Real-World Case Studies
### Netflix
- **Challenge:** 1PB+ daily logs
- **Solution:**  
  - Custom Elasticsearch plugins
  - Tiered storage (hot/warm/frozen)
- **Outcome:** 90% faster incident resolution

### GitHub
- **Use Case:** Detect DDoS attacks
- **Implementation:**  
  - GeoIP filtering in Logstash
  - Real-time Kibana dashboards

---

## Best Practices
1. **Log Structure:**
   ```json
   {
     "@timestamp": "ISO8601",
     "log.level": "ERROR",
     "service.name": "payment-gateway",
     "trace.id": "abc123"
   }
   ```

2. **Retention Policy:**  
   - 7 days hot → 30 days warm → 1 year cold (S3)

3. **Security:**  
   - TLS between components
   - Role-based access in Kibana

---

## Hands-On Labs
### Lab 1: Apache Log Analysis
```bash
docker-compose up -d elasticsearch logstash kibana apache
# Access Kibana at http://localhost:5601
```

**Tasks:**
1. Create grok pattern for Apache logs
2. Build dashboard with:
   - Requests/minute
   - Top 5 error URLs

---

## Further Resources
1. **Official Docs:**  
   [Elasticsearch Guide](https://www.elastic.co/guide/index.html)  
2. **Certifications:**  
   [Elastic Certified Engineer](https://www.elastic.co/training/certification)  
3. **Books:**  
   *Elasticsearch: The Definitive Guide*  
4. **Community:**  
   [Elastic Discuss Forums](https://discuss.elastic.co/)
