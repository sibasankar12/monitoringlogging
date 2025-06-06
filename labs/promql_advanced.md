# Lab 05: Writing Advanced PromQL Queries for Real-World Monitoring

## Introduction
This lab builds on basic PromQL knowledge to create production-grade queries for system monitoring. You'll learn to detect resource bottlenecks, analyze performance trends, and establish alerting thresholds using advanced PromQL features.

## Objective
By the end of this lab, you will be able to:
- Create memory pressure alerts with dynamic thresholds
- Analyze disk I/O patterns to identify performance issues
- Track system uptime for maintenance planning
- Monitor network traffic to detect bottlenecks
- Join metrics for enriched monitoring context

## Prerequisites
- Prometheus server running (http://localhost:9090)
- Node Exporter configured (from Lab 03)
- Basic PromQL knowledge (from Lab 04)
- 15+ minutes of metric collection for meaningful rates

---

## Lab Steps

### 1. Memory Pressure Alerting

**Query:** Calculate memory utilization percentage
```promql
100 * (1 - (
  node_memory_MemFree_bytes 
  + node_memory_Cached_bytes 
  + node_memory_Buffers_bytes
) / node_memory_MemTotal_bytes)
```

**Alert Rule Example:**
```yaml
- alert: HighMemoryUsage
  expr: 100 * (1 - (node_memory_MemFree_bytes + node_memory_Cached_bytes + node_memory_Buffers_bytes) / node_memory_MemTotal_bytes) > 90
  for: 10m
  labels:
    severity: critical
  annotations:
    summary: "High memory usage on {{ $labels.instance }}"
```

### 2. Disk I/O Performance Analysis

**Query:** Total disk I/O per instance (MB/s)
```promql
sum by(instance) (
  rate(node_disk_read_bytes_total[5m]) 
  + rate(node_disk_written_bytes_total[5m])
) / 1024 / 1024
```

**Visualization Tip:** 
- Compare with `rate(node_disk_io_time_seconds_total[5m])` to identify contention

### 3. System Uptime Monitoring

**Query:** Uptime in days
```promql
(
  node_time_seconds{job="node_exporter"} 
  - node_boot_time_seconds{job="node_exporter"}
) / 86400
```

**Maintenance Alert:**
```promql
# Alert if uptime > 30 days
(
  node_time_seconds{job="node_exporter"} 
  - node_boot_time_seconds{job="node_exporter"}
) > 2592000
```

### 4. Network Bottleneck Detection

**Query:** Receive traffic by device (with hostnames)
```promql
sum by(device, instance) (
  rate(node_network_receive_bytes_total[1m])
) * on(instance) group_left(nodename) node_uname_info
```

**Query:** Transmit traffic by device
```promql
sum by(device, instance) (
  rate(node_network_transmit_bytes_total[1m])
) * on(instance) group_left(nodename) node_uname_info
```

**Threshold Example:**
```promql
# Alert if > 1Gbps sustained
rate(node_network_receive_bytes_total[5m]) * 8 > 1e9
```

---

## Advanced Techniques

### Metric Joins
```promql
# Add instance IP to CPU metrics
node_cpu_seconds_total * on(instance) group_left(ip) (
  node_network_address_info{address_type="ipv4"}
)
```

### Predictive Alerting
```promql
# Predict disk full in 4h
predict_linear(node_filesystem_avail_bytes[1h], 4*3600) < 0
```

### Histogram Quantiles
```promql
# 95th percentile disk latency
histogram_quantile(0.95, 
  rate(node_disk_read_time_seconds_bucket[5m])
)
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| No data for new metrics | Ensure Node Exporter v1.3+ for full metric coverage |
| "Many-to-many" errors | Verify `group_left`/`group_right` matches |
| Counter resets | Use `rate()` instead of `increase()` |
| High cardinality | Add more label filters |

---

## Conclusion
You've successfully:
- Created memory pressure alerts with dynamic thresholds
- Identified disk I/O bottlenecks using rate analysis
- Tracked system uptime for maintenance planning
- Detected network congestion points
- Enriched metrics with additional context

Next steps:
1. Integrate these queries with Alertmanager
2. Build comprehensive Grafana dashboards
3. Set up recording rules for frequent queries

## Further Reading
- [Prometheus Alerting Rules](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/)
- [Advanced PromQL Techniques](https://www.robustperception.io/tag/promql)
- [Production Alerting Practices](https://prometheus.io/docs/practices/alerting/)

> **Pro Tip:** Use `recording_rules` to pre-compute complex expressions and reduce dashboard load times!
