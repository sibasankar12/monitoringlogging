# Advanced Prometheus Concepts: Instrumentation, Alerting & Pushgateway

## Table of Contents
1. [Instrumentation in Depth](#instrumentation-in-depth)
2. [Recording Rules Mastery](#recording-rules-mastery)
3. [Alerting with Prometheus & Alertmanager](#alerting-with-prometheus--alertmanager)
4. [Pushgateway for Ephemeral Jobs](#pushgateway-for-ephemeral-jobs)
5. [Real-World Use Cases](#real-world-use-cases)
6. [Architecture Deep Dive](#architecture-deep-dive)
7. [Further Learning](#further-learning)

---

## Instrumentation in Depth
### What is Instrumentation?
Instrumentation involves embedding monitoring code directly into applications to expose metrics like request counts, error rates, and latency. Unlike exporters (which translate existing metrics), instrumentation creates **net-new metrics** from application internals.

### Key Techniques
| Method                      | Use Case                          | Example                          |
|-----------------------------|-----------------------------------|----------------------------------|
| **Client Libraries**        | Custom app metrics                | `http_requests_total` in Python  |
| **Auto-Instrumentation**    | Framework integration (e.g., Spring Boot Actuator) | JVM metrics in Java |
| **Manual Counters**         | Business logic tracking           | `orders_processed_total`         |

**Example: Instrumenting a Python Flask App**
```python
from prometheus_client import start_http_server, Counter

REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP Requests')
@app.route('/')
def home():
    REQUEST_COUNT.inc()  # Increment counter
    return "Hello, Prometheus!"
```

### When to Use Exporters vs. Instrumentation?
- **Exporters:** Legacy systems, databases, hardware (e.g., `node_exporter`).
- **Instrumentation:** Custom applications, microservices.

---

## Recording Rules Mastery
### Why Recording Rules?
Precompute frequent queries to:
- Reduce dashboard load times.
- Lower PromQL complexity (e.g., replace `rate(http_requests_total[5m])` with `http_requests_per_minute`).

### Rule Configuration
**File:** `/etc/prometheus/rules.yml`
```yaml
groups:
- name: http_rules
  interval: 30s  # Override global eval interval
  rules:
  - record: http_requests_per_minute
    expr: sum(rate(http_requests_total[1m])) by (service)
```

**Best Practices:**
1. **Aggregate Early:** Compute summaries (e.g., `sum by (job)`).
2. **Limit Cardinality:** Avoid high-dimension labels in rules.
3. **Monitor Rule Health:** Alert on `prometheus_rule_evaluation_failures_total`.

---

## Alerting with Prometheus & Alertmanager
### Alert Rules vs. Recording Rules
| Feature          | Alert Rules                      | Recording Rules               |
|------------------|----------------------------------|--------------------------------|
| **Output**       | Alerts sent to Alertmanager      | New time series in TSDB        |
| **Use Case**     | Notify when `memory_usage > 90%` | Precompute `memory_usage_avg`  |

**Alert Example: High CPU**
```yaml
- alert: HighCPU
  expr: avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) by (instance) < 0.1
  for: 10m
  labels:
    severity: critical
  annotations:
    summary: "{{ $labels.instance }} CPU overloaded"
```

### Alertmanager Workflow
1. **Deduplication:** Merge identical alerts.
2. **Routing:** Send `severity=critical` to PagerDuty, `warning` to Slack.
3. **Inhibition:** Silence disk alerts if node is down.

**Notification Channels:**
- **Slack:**
  ```yaml
  receivers:
  - name: slack_alerts
    slack_configs:
    - api_url: "https://hooks.slack.com/services/..."
      channel: "#alerts"
  ```

---

## Pushgateway for Ephemeral Jobs
### When to Use Pushgateway?
- **Short-lived jobs:** Cron jobs, CI/CD pipelines.
- **Serverless:** AWS Lambda, Google Cloud Functions.

**Push Example: Cron Job**
```bash
# Push exit code of a backup script
echo "backup_exit_code $(echo $?)" | curl --data-binary @- http://pushgateway:9091/metrics/job/backup/instance/db01
```

**Automation Tips:**
1. **Client Libraries:** Use Python’s `prometheus_client` for batch jobs.
2. **Lifecycle Management:** Add `# TYPE` and `# HELP` metadata.

**Limitations:**
- **No Forgetting:** Manual cleanup via `curl -X DELETE`.
- **No Timestamps:** Metrics use push time (not event time).

---

## Real-World Use Cases
### 1. Kubernetes Monitoring
- **Instrumentation:** Sidecar containers for custom app metrics.
- **Alert:** `kube_pod_status_phase{phase="Pending"} > 300` (stuck pods).

### 2. E-Commerce Dashboard
- **Recording Rule:** `shopping_cart_abandonment_rate = abandoned_carts / total_carts`.
- **Alert:** Alert when rate exceeds 70%.

### 3. Batch Processing
- **Pushgateway:** Track Spark job progress with `spark_tasks_completed_total`.

---

## Architecture Deep Dive
![Advanced Prometheus Architecture](https://miro.medium.com/v2/resize:fit:1400/1*6Q1zF8xY6Q8Z-0-0Q9Q9Qw.png)  
*(Source: [CNCF Blog](https://www.cncf.io/blog/))*

1. **Targets:** Instrumented apps, exporters, Pushgateway.
2. **Prometheus Server:** Scrapes, evaluates rules, sends alerts.
3. **Alertmanager:** Routes alerts to Slack/email/PagerDuty.
4. **Grafana:** Visualizes precomputed metrics from recording rules.

---

## Further Learning
1. **Official Docs:**
   - [Instrumentation Guidelines](https://prometheus.io/docs/practices/instrumentation/)
   - [Alerting Configuration](https://prometheus.io/docs/alerting/latest/configuration/)
2. **Books:**
   - *Prometheus: Up & Running* (O’Reilly).
3. **Tools:**
   - **Grafana Mimir:** Long-term storage for Prometheus.
   - **OpenTelemetry:** Unified instrumentation standard.

---

## Hands-On Lab
**Task:** Set up alerts for a MySQL server using `mysqld_exporter`.  
**Steps:**
1. Deploy MySQL and exporter:
   ```bash
   docker run -d --name mysql -e MYSQL_ROOT_PASSWORD=secret mysql:latest
   docker run -d --name mysqld_exporter -e DATA_SOURCE_NAME="root:secret@(mysql:3306)/" prom/mysqld-exporter
   ```
2. Create alert rules for slow queries (`mysql_global_status_slow_queries > 10`).

**Verify:** Check Alertmanager UI at `http://localhost:9093`.

---

> "Monitor like you mean it: Instrument everything, alert on what matters, and precompute the rest."  
> — *Prometheus Best Practices*


