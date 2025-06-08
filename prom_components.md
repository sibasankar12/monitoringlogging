# **Complete Lecture Notes: Prometheus Monitoring Stack**

## **1. Prometheus Pushgateway**
### **Overview**
- Used for ephemeral or batch jobs that cannot be scraped directly.
- Acts as an intermediary cache for metrics pushed by short-lived jobs.
- Not meant for long-term storage.

### **Key Points**
- **Use Cases**:
  - Batch jobs (cron jobs, ETL pipelines).
  - Short-lived services (serverless functions).
- **Port**: `9091` (default).
- **Metrics Lifetime**: Persists until manually deleted or auto-expired (configurable).
- **Security**: No built-in auth; use reverse proxy (NGINX, Apache) for security.

### **Sample Push Command**
```sh
echo "example_metric 3.14" | curl --data-binary @- http://pushgateway.example.com:9091/metrics/job/my_job/instance/my_instance
```

### **Scrape Config (in Prometheus)**
```yaml
scrape_configs:
  - job_name: 'pushgateway'
    honor_labels: true  # Prevents job/instance relabeling
    static_configs:
      - targets: ['pushgateway.example.com:9091']
```

---

## **2. Alertmanager**
### **Overview**
- Handles alerts sent by Prometheus.
- Deduplicates, groups, and routes alerts to receivers (Email, Slack, PagerDuty).

### **Key Points**
- **Port**: `9093` (default).
- **Alert States**:
  - `firing`: Active alert.
  - `resolved`: Condition no longer true.
- **Inhibition Rules**: Suppress certain alerts if another is firing.
- **Silencing**: Mute alerts temporarily.

### **Sample Alert Rule (in Prometheus)**
```yaml
groups:
- name: example
  rules:
  - alert: HighCPU
    expr: node_cpu_seconds_total{mode="idle"} < 10
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "High CPU usage on {{ $labels.instance }}"
```

### **Alertmanager Config**
```yaml
route:
  receiver: 'slack-notifications'
  group_by: [alertname, cluster]
  routes:
  - match:
      severity: 'critical'
    receiver: 'pagerduty'
receivers:
- name: 'slack-notifications'
  slack_configs:
  - api_url: 'https://hooks.slack.com/services/...'
    channel: '#alerts'
```

---

## **3. Application Instrumentation**
### **Overview**
- Adding metrics to applications via client libraries (Python, Go, Java, etc.).
- Exposing metrics via `/metrics` endpoint.

### **Key Metrics Types**
- **Counter**: Monotonically increasing (e.g., requests count).
- **Gauge**: Can go up/down (e.g., memory usage).
- **Histogram/Summary**: Tracks distributions (e.g., request latency).

### **Sample Python Instrumentation**
```python
from prometheus_client import start_http_server, Counter

REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP Requests')

def handle_request():
    REQUEST_COUNT.inc()
    return "Hello, Prometheus!"

start_http_server(8000)  # Exposes /metrics on port 8000
```

### **Scrape Config**
```yaml
scrape_configs:
  - job_name: 'my_app'
    static_configs:
      - targets: ['app.example.com:8000']
```

---

## **4. Node Exporter**
### **Overview**
- Exposes hardware and OS metrics (CPU, memory, disk, network).
- Runs on each node being monitored.

### **Key Points**
- **Port**: `9100` (default).
- **Metrics**:
  - `node_cpu_seconds_total`
  - `node_memory_MemFree_bytes`
  - `node_filesystem_avail_bytes`
- **Use Case**: Infrastructure monitoring.

### **Scrape Config**
```yaml
scrape_configs:
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['node1.example.com:9100', 'node2.example.com:9100']
```

---

## **5. Advanced PromQL Queries**
### **Common Use Cases**
| Query | Purpose |
|--------|---------|
| `rate(http_requests_total[5m])` | Request rate over 5m |
| `sum by (instance) (node_cpu_seconds_total{mode="idle"})` | CPU idle time per instance |
| `histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))` | 95th percentile latency |
| `node_memory_MemFree_bytes / node_memory_MemTotal_bytes * 100` | Free memory % |
| `predict_linear(node_filesystem_avail_bytes[1h], 4*3600) < 0` | Predict disk full in 4h |

### **Operators & Functions**
- `rate()`: Per-second average over time.
- `increase()`: Absolute growth over time.
- `sum()/avg()/min()/max()`: Aggregations.
- `by/without`: Grouping.
- `>`, `<`, `==`: Filtering.

---

## **6. Important Technical Details**
### **Port Numbers**
| Component | Default Port |
|-----------|-------------|
| Prometheus Server | `9090` |
| Pushgateway | `9091` |
| Alertmanager | `9093` |
| Node Exporter | `9100` |
| Blackbox Exporter | `9115` |
| Grafana | `3000` |

### **Critical Considerations**
1. **Cardinality Explosion**: Avoid high-cardinality labels (e.g., user IDs).
2. **Scrape Interval**: Default `15s`; adjust based on needs.
3. **Retention**: Default `15d`; configure `--storage.tsdb.retention.time` for longer retention.
4. **HA Setup**: Run multiple Prometheus instances + Alertmanagers.
5. **Relabeling**: Modify labels before ingestion (e.g., drop sensitive data).

---

## **7. Summary Table: Key Pointers**
| Topic | Key Takeaways |
|-------|--------------|
| **Pushgateway** | For short-lived jobs, not long-term storage. |
| **Alertmanager** | Handles routing, deduplication, silencing. |
| **App Instrumentation** | Use `/metrics` endpoint, avoid high cardinality. |
| **Node Exporter** | Monitors OS/hardware metrics (`9100`). |
| **PromQL** | `rate()`, `sum()`, `histogram_quantile()` are essential. |
| **Ports** | Prometheus (`9090`), Alertmanager (`9093`), Node Exporter (`9100`). |
| **Scrape Config** | Define `job_name`, `static_configs` in `prometheus.yml`. |
| **Security** | No built-in auth; use reverse proxy or network policies. |

