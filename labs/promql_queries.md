# Lab 04: Writing Basic PromQL Queries

## Introduction
PromQL (Prometheus Query Language) allows querying and aggregating time series data collected by Prometheus. This lab teaches fundamental PromQL operations for system monitoring, including filtering, aggregation, and rate calculations.

## Objective
By the end of this lab, you will be able to:
- Retrieve and filter metrics using labels
- Perform arithmetic operations on metrics
- Aggregate time series data
- Calculate rate of change for counter metrics
- Convert between metric units

## Prerequisites
- Running Prometheus server (http://localhost:9090)
- Node Exporter configured (from Lab 03)
- Basic understanding of Linux terminal

---

## Lab Steps

### Step 1: Retrieve a Single Metric

1. Access Prometheus UI:
   ```
   http://localhost:9090
   ```

2. In the "Expression" input box, enter:
   ```promql
   node_cpu_seconds_total
   ```
3. Click "Execute" and view results in both "Console" and "Graph" tabs

### Step 2: Filter Metrics by Label

1. Query available filesystems:
   ```promql
   node_filesystem_avail_bytes
   ```

2. Filter for root filesystem only:
   ```promql
   node_filesystem_avail_bytes{device="/dev/root"}
   ```
   *Note: Replace `/dev/root` with your actual root device from Step 1 results*

### Step 3: Aggregate Data with sum()

1. View network transmit bytes per interface:
   ```promql
   node_network_transmit_bytes_total
   ```

2. Sum across all interfaces:
   ```promql
   sum(node_network_transmit_bytes_total)
   ```

### Step 4: Arithmetic Operations

1. Get available memory in bytes:
   ```promql
   node_memory_MemAvailable_bytes
   ```

2. Convert to megabytes:
   ```promql
   node_memory_MemAvailable_bytes / 1024 / 1024
   ```

### Step 5: Calculate Rates

1. View total network bytes received:
   ```promql
   node_network_receive_bytes_total
   ```

2. Calculate receive rate per second (1m window):
   ```promql
   rate(node_network_receive_bytes_total[1m])
   ```

---

## Key PromQL Concepts

| Operation | Example | Purpose |
|-----------|---------|---------|
| **Instant vector** | `node_cpu_seconds_total` | Raw metric values |
| **Label filtering** | `{job="node_exporter"}` | Narrow results |
| **Range vector** | `[5m]` | Time window for functions |
| **Rate** | `rate(metric[1m])` | Per-second average |
| **Aggregation** | `sum by (instance)` | Combine time series |

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "No data" results | Verify Node Exporter is running (`curl localhost:9100/metrics`) |
| "Unknown metric" | Check metric name at `/metrics` endpoint |
| Graph not showing | Adjust time range (try last 1 hour) |
| Rate() returning empty | Ensure querying a counter metric |

---

## Conclusion
You've successfully:
- Retrieved raw system metrics
- Applied label filters for targeted queries
- Aggregated data across dimensions
- Performed unit conversions
- Calculated rate of change for counters

Next steps:
1. Create recording rules for frequent queries
2. Set up alerts based on PromQL expressions
3. Build Grafana dashboards using these queries

## Further Reading
- [PromQL Official Documentation](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [PromQL Cheat Sheet](https://promlabs.com/promql-cheat-sheet/)
- [Advanced Aggregation Techniques](https://timber.io/blog/promql-for-humans/)

> **Pro Tip:** Use `count(node_cpu_seconds_total{mode="idle"})` to determine number of CPU cores!
