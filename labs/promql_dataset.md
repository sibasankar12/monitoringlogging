# Lab 06: Querying Node Exporter Metrics with Docker and PromQL

## Introduction
This lab demonstrates how to quickly set up a Prometheus monitoring environment using Docker and write targeted PromQL queries to analyze system metrics from Node Exporter. The Dockerized approach eliminates host dependencies while providing a clean testing environment.

## Objective
By the end of this lab, you will be able to:
- Deploy Prometheus and Node Exporter using Docker Compose
- Write precise PromQL queries with label filtering
- Use regex and negative matching in queries
- Analyze CPU metrics at different granularities

## Prerequisites
- Docker Engine installed
- Docker Compose v2+
- 2GB free memory
- Ports 9097 and 9107 available

---

## Lab Setup

### 1. Launch Monitoring Stack

1. Clone the repository:
```bash
git clone https://github.com/prometheus-community/prometheus-playground.git
cd prometheus-playground/node-exporter
```

2. Start containers (modified ports to avoid conflicts):
```bash
docker compose up -d
```

3. Verify running services:
```bash
docker ps
```
*Expected Output:*
```
CONTAINER ID   IMAGE                      PORTS                    NAMES
abc123        prom/prometheus:latest     0.0.0.0:9097->9090/tcp   prometheus
def456        prom/node-exporter:latest  0.0.0.0:9107->9100/tcp   node_exporter
```

### 2. Access Interfaces

- **Prometheus UI:** http://localhost:9097
- **Node Exporter Metrics:** http://localhost:9107/metrics

---

## PromQL Query Practice

### Basic Metric Retrieval
```promql
node_cpu_seconds_total
```

### Label Filtering
1. System-mode CPU time:
```promql
node_cpu_seconds_total{mode="system"}
```

2. System-mode for CPU 0 only:
```promql
node_cpu_seconds_total{mode="system",cpu="0"}
```

### Advanced Matching
1. Regex for modes starting with 's':
```promql
node_cpu_seconds_total{mode=~"s.*"}
```

2. Exclude idle CPU time:
```promql
node_cpu_seconds_total{mode!="idle"}
```

---

## Key Learning Points

| Concept | Example | Purpose |
|---------|---------|---------|
| Exact match | `{mode="user"}` | Isolate specific metrics |
| Regex match | `{mode=~"user\|system"}` | Broad pattern matching |
| Negative match | `{mode!="idle"}` | Exclude unwanted data |
| Multi-label | `{mode="system",cpu="0"}` | Precise dimension filtering |

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Containers not starting | Run `docker compose logs` to view errors |
| No metrics in Prometheus | Verify Node Exporter target at `http://localhost:9097/targets` |
| Port conflicts | Modify `docker-compose.yml` ports mapping |

---

## Conclusion
You've successfully:
- Deployed a containerized monitoring stack
- Executed targeted metric queries
- Applied label filtering techniques
- Analyzed CPU utilization patterns

Next steps:
1. Add recording rules for common queries
2. Configure alerts for CPU saturation
3. Expand to monitor additional containers

## Cleanup
Stop and remove containers:
```bash
docker compose down
```

## Further Reading
- [Prometheus Querying Basics](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [Node Exporter Metrics Reference](https://prometheus.io/docs/guides/node-exporter/)
- [Docker Compose for Monitoring](https://github.com/prometheus-community/prometheus-playground)

> **Pro Tip:** Use `count(node_cpu_seconds_total{mode="system"}) by (instance)` to count CPUs per host!
