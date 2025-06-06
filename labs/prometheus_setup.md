# Lab 02: Setting Up a Local Prometheus Instance and Exploring Its Web Interface

## Introduction
Prometheus is an open-source systems monitoring and alerting toolkit that collects and stores metrics as time series data. This lab guides you through running a local Prometheus instance and exploring its web interface to monitor system metrics.

## Objective
By the end of this lab, you will be able to:
- Start a Prometheus server locally
- Navigate the Prometheus web UI
- Execute basic PromQL queries
- Interpret metric data and visualizations

## Prerequisites
- Linux system (Ubuntu/CentOS)
- Prometheus binary downloaded ([Download Page](https://prometheus.io/download/))
- Basic terminal familiarity
- Port 9090 accessible

---

## Lab Steps

### Step 1: Start Prometheus Binary

1. Navigate to your Prometheus directory:
```bash
cd ~/prometheus
```

2. Start the Prometheus server with the default config:
```bash
./prometheus --config.file=prometheus.yml
```
*Keep this terminal open during the lab*

**Expected Output:**
```
level=info ts=2023-08-23T10:00:00.000Z caller=main.go:300 msg="Starting Prometheus" version="(version=2.30.3, branch=HEAD, revision=..."
```

### Step 2: Explore Prometheus UI

1. Access the web interface in your browser:
```
http://localhost:9090
```

2. **Execute your first query:**
   - Navigate to "Graph" tab
   - In the expression bar, type: 
     ```
     process_virtual_memory_bytes
     ```
   - Click "Execute"
   - Switch to "Graph" view

3. **Check scrape targets:**
   - Go to Status → Targets
   - Verify `prometheus` job shows as **UP**

4. **View raw metrics:**
   - From Targets page, copy:
     ```
     http://localhost:9090/metrics
     ```
   - Paste into a new browser tab

---

## Key Observations

1. **Metric Types in UI:**
   - Counter: `prometheus_http_requests_total`
   - Gauge: `go_goroutines`
   - Histogram: `prometheus_http_request_duration_seconds`

2. **Time Controls:**
   - Use the time range selector (top right) to adjust the query window
   - Try 1h, 6h, and 1d ranges

3. **Basic PromQL Examples:**
   ```promql
   rate(prometheus_http_requests_total[5m])
   node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes
   ```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Connection refused" on port 9090 | Verify Prometheus process is running with `ps aux | grep prometheus` |
| No metrics visible | Check if `prometheus.yml` has correct scrape configs |
| "Empty query result" | Verify metric name exists at `/metrics` endpoint |

---

## Conclusion
You've successfully:
- Deployed a local Prometheus instance
- Executed basic metric queries
- Visualized system resource usage
- Verified scrape target health

Next steps:
1. Add Node Exporter for system metrics
2. Configure alert rules in `prometheus.yml`
3. Integrate with Grafana for dashboards

## Further Reading
- [Prometheus Querying Basics](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [Official Configuration Docs](https://prometheus.io/docs/prometheus/latest/configuration/configuration/)
- [PromQL Cheat Sheet](https://promlabs.com/promql-cheat-sheet/)

> **Pro Tip:** Use `Ctrl+C` in the terminal to gracefully shutdown Prometheus when done.
