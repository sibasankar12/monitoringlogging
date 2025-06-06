# Lab 03: Setting Up and Monitoring with Node Exporter

## Introduction
Node Exporter is a Prometheus exporter for hardware and OS metrics exposed by *NIX kernels. This lab guides you through installing Node Exporter and configuring Prometheus to scrape system metrics from a Linux host.

## Objective
By the end of this lab, you will be able to:
- Install and run Node Exporter on Linux
- Configure Prometheus to scrape Node Exporter metrics
- Query and visualize system metrics in Prometheus UI
- Verify target health status

## Prerequisites
- Linux system (tested on Ubuntu 22.04)
- Prometheus installed ([Lab 02](#))
- Ports 9090 (Prometheus) and 9100 (Node Exporter) available
- Basic terminal familiarity

---

## Lab Steps

### Step 1: Install Node Exporter

1. Download the latest Node Exporter binary:
```bash
wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz
```

2. Extract the package:
```bash
tar xvfz node_exporter-*.linux-amd64.tar.gz
```

3. Organize files and clean up:
```bash
mkdir node_exporter
mv node_exporter-*.linux-amd64/* node_exporter/
rm node_exporter-*.tar.gz
```

4. Run Node Exporter in background:
```bash
cd node_exporter
./node_exporter > /dev/null 2>&1 &
```

5. Verify metrics are exposed:
```bash
curl http://localhost:9100/metrics | head
```
*Expected output:*
```
# HELP go_gc_duration_seconds A summary of the pause duration of garbage collection cycles.
# TYPE go_gc_duration_seconds summary
```

### Step 2: Configure Prometheus

1. Create Prometheus config file:
```bash
cat <<EOF > prom-node-exporter.yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']
EOF
```

2. Start Prometheus with new config:
```bash
./prometheus --config.file=prom-node-exporter.yaml
```

**Troubleshooting Tip:** If port 9090 is occupied:
```bash
sudo lsof -i :9090  # Find process
sudo kill <PID>     # Free the port
```

### Step 3: Explore Metrics in Prometheus UI

1. Access Prometheus at:
```
http://localhost:9090
```

2. Try these PromQL queries:
   - CPU usage by mode:
     ```promql
     rate(node_cpu_seconds_total[1m])
     ```
   - Available memory:
     ```promql
     node_memory_MemAvailable_bytes / 1024 / 1024
     ```
   - Disk I/O:
     ```promql
     rate(node_disk_read_bytes_total[5m])
     ```

3. Check target status:
   - Navigate to Status → Targets
   - Verify `node_exporter` shows as **UP**

---

## Key Metrics to Monitor

| Metric | Description | Critical Threshold |
|--------|-------------|--------------------|
| `node_memory_MemAvailable_bytes` | Available RAM | < 10% of total |
| `node_filesystem_avail_bytes` | Free disk space | < 15% |
| `node_load1` | 1-min load avg | > CPU cores × 1.5 |
| `rate(node_network_receive_bytes_total[5m])` | Network traffic | N/A |

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Connection refused" on port 9100 | Verify Node Exporter is running with `ps aux | grep node_exporter` |
| No metrics in Prometheus | Check `prom-node-exporter.yaml` targets match Node Exporter IP:port |
| High CPU usage | Limit collectors with `--collector.<name>` flags |

---

## Conclusion
You've successfully:
- Deployed Node Exporter to expose system metrics
- Configured Prometheus scraping
- Visualized key system resources
- Verified data collection health

Next steps:
1. Add alert rules for critical thresholds
2. Configure Grafana dashboards
3. Monitor multiple hosts by deploying Node Exporters

## Further Reading
- [Node Exporter GitHub](https://github.com/prometheus/node_exporter)
- [Official Collectors List](https://prometheus.io/docs/guides/node-exporter/)
- [Linux Monitoring Best Practices](https://prometheus.io/docs/guides/node-exporter/#monitoring-linux-hosts)

> **Security Note:** For production, run Node Exporter as a systemd service and enable firewall rules to restrict access to port 9100.
