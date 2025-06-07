# **Ultimate PromQL Cheat Sheet for Node Monitoring**  
*(CPU, Memory, Disk, Network, Troubleshooting & Health Indicators)*  

---

## **Table of Contents**  
1. **[CPU Metrics](#1-cpu-metrics)**  
2. **[Memory Metrics](#2-memory-metrics)**  
3. **[Disk & Storage Metrics](#3-disk--storage-metrics)**  
4. **[Network Metrics](#4-network-metrics)**  
5. **[System Load & Process Metrics](#5-system-load--process-metrics)**  
6. **[Troubleshooting Scenarios](#6-troubleshooting-scenarios)**  
7. **[Health Indicators & Alerts](#7-health-indicators--alerts)**  

---

## **1. CPU Metrics**  
| **Use Case**               | **PromQL Query**                                                                 | **Explanation**                                                                 |
|----------------------------|----------------------------------------------------------------------------------|---------------------------------------------------------------------------------|
| **Overall CPU Usage (%)**  | `100 - (avg by (instance)(rate(node_cpu_seconds_total{mode="idle"}[1m])) * 100)` | Calculates non-idle CPU time (user + system).                                   |
| **Per-Core Utilization**   | `rate(node_cpu_seconds_total{mode!="idle"}[5m])`                                | Shows CPU time per core (excludes idle).                                       |
| **CPU Saturation**         | `rate(node_context_switches_total[5m])`                                          | High values indicate CPU contention.                                            |
| **Steal Time (Cloud VMs)** | `rate(node_cpu_seconds_total{mode="steal"}[5m])`                                | Measures CPU stolen by hypervisor (>0.5s/sec = noisy neighbor).                |
| **Top CPU Processes**      | `topk(3, rate(node_cpu_seconds_total{mode="user"}[5m]))`                        | Identifies top 3 user-space processes.                                         |

---

## **2. Memory Metrics**  
| **Use Case**                     | **PromQL Query**                                                                 | **Explanation**                                                                 |
|----------------------------------|----------------------------------------------------------------------------------|---------------------------------------------------------------------------------|
| **Memory Usage (%)**             | `(node_memory_MemTotal_bytes - node_memory_MemFree_bytes) / node_memory_MemTotal_bytes * 100` | Raw memory usage (includes caches).                                             |
| **Available Memory (%)**         | `(node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100`            | Real available memory (excludes buffers/cache).                                 |
| **Swap Usage**                   | `(node_memory_SwapTotal_bytes - node_memory_SwapFree_bytes) / node_memory_SwapTotal_bytes * 100` | Swap space utilization (>20% = warning).                                        |
| **OOM Killer Risk**              | `node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes < 0.1`              | Triggers if available memory <10%.                                              |
| **Slab Memory (Kernel)**         | `node_memory_Slab_bytes`                                                         | Kernel memory usage (leaks cause high values).                                  |

---

## **3. Disk & Storage Metrics**  
| **Use Case**                     | **PromQL Query**                                                                 | **Explanation**                                                                 |
|----------------------------------|----------------------------------------------------------------------------------|---------------------------------------------------------------------------------|
| **Disk Space Usage (%)**         | `100 - (node_filesystem_avail_bytes{mountpoint="/"} * 100 / node_filesystem_size_bytes{mountpoint="/"})` | Root partition usage.                                                           |
| **Disk I/O Latency (ms)**       | `rate(node_disk_io_time_seconds_total[1m]) * 1000`                              | >50ms indicates disk bottlenecks.                                               |
| **Disk Throughput (MB/s)**      | `rate(node_disk_read_bytes_total[1m]) / 1024 / 1024`                             | Read throughput.                                                                |
| **Inode Usage (%)**             | `(node_filesystem_files_free{mountpoint="/"} / node_filesystem_files{mountpoint="/"}) * 100` | Critical if <5% free.                                                           |
| **RAID Degradation**            | `node_md_disks_required - node_md_disks_active`                                 | >0 indicates failed disks.                                                      |

---

## **4. Network Metrics**  
| **Use Case**                     | **PromQL Query**                                                                 | **Explanation**                                                                 |
|----------------------------------|----------------------------------------------------------------------------------|---------------------------------------------------------------------------------|
| **Network Traffic (MB/s)**      | `rate(node_network_receive_bytes_total{device="eth0"}[1m]) / 1024 / 1024`        | Incoming traffic on eth0.                                                       |
| **Packet Drops**                | `rate(node_network_receive_drop_total[5m])`                                      | High drops = NIC issues.                                                        |
| **TCP Retransmits**             | `rate(node_netstat_Tcp_RetransSegs[5m])`                                         | Network instability if >0.                                                      |
| **Connection States**           | `node_netstat_Tcp_CurrEstab`                                                     | Current ESTABLISHED connections.                                                |
| **Bandwidth Saturation**        | `rate(node_network_transmit_bytes_total{device="eth0"}[5m]) / 125000`            | % of 1Gbps link (125000 = 1Gbps in KB/s).                                      |

---

## **5. System Load & Process Metrics**  
| **Use Case**                     | **PromQL Query**                                                                 | **Explanation**                                                                 |
|----------------------------------|----------------------------------------------------------------------------------|---------------------------------------------------------------------------------|
| **Load Average vs. Cores**      | `node_load1 / count by (instance)(node_cpu_seconds_total{mode="system"})`        | >1.0 = Saturation risk.                                                        |
| **Running Processes**           | `node_procs_running`                                                             | High counts may indicate fork bombs.                                            |
| **Zombie Processes**            | `node_procs_zombie`                                                              | >0 requires investigation.                                                      |
| **File Descriptors Usage**      | `node_filefd_allocated / node_filefd_maximum * 100`                              | >90% = risk of "too many open files".                                           |

---

## **6. Troubleshooting Scenarios**  
| **Issue**                       | **Diagnostic Query**                                                                 | **Solution**                                                                 |
|----------------------------------|----------------------------------------------------------------------------------|---------------------------------------------------------------------------------|
| **High CPU**                    | `topk(3, rate(node_cpu_seconds_total{mode="user"}[5m]))`                        | Check `top -c` for runaway processes.                                        |
| **Memory Leak**                 | `increase(node_memory_Slab_bytes[24h]) > 0`                                      | Reboot or investigate kernel modules.                                        |
| **Disk Full**                   | `predict_linear(node_filesystem_avail_bytes[6h], 3600*24) < 0`                 | Clean logs or expand storage.                                                |
| **Network Bottleneck**          | `rate(node_network_receive_errs_total[5m]) > 0`                                 | Check NIC/driver or upgrade bandwidth.                                       |
| **OOM Killer Active**           | `node_vmstat_oom_kill`                                                          | Increase memory or limit process usage.                                      |

---

## **7. Health Indicators & Alerts**  
| **Alert Condition**             | **PromQL Query**                                                                 | **Severity**                                                                 |
|----------------------------------|----------------------------------------------------------------------------------|---------------------------------------------------------------------------------|
| **Critical CPU**                | `100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 90`         | `critical`                                                                   |
| **Low Memory**                  | `node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes < 0.1`             | `warning`                                                                    |
| **Disk Full (Predictive)**      | `predict_linear(node_filesystem_avail_bytes[6h], 86400) < 0`                    | `critical`                                                                   |
| **High Network Errors**         | `rate(node_network_receive_errs_total[5m]) + rate(node_network_transmit_errs_total[5m]) > 5` | `warning`                                                                    |
| **Zombie Processes**            | `node_procs_zombie > 0`                                                         | `info`                                                                       |

---

### **How to Use This Cheat Sheet**  
1. **Grafana Dashboards**: Paste queries into panels.  
2. **Alert Rules**: Use Section 7 in `alert.rules`.  
3. **CLI Debugging**: Run with `curl http://localhost:9090/api/v1/query?query=<PROMQL>`.  

**Pro Tip**: Combine with `recording_rules` to optimize frequent queries!  

```yaml
# Example recording rule for CPU
- record: instance:node_cpu:avg_rate5m
  expr: avg by (instance)(rate(node_cpu_seconds_total[5m]))
