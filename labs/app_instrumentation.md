# Lab 07: Instrumenting Java Applications for Prometheus Monitoring

## Introduction
This lab demonstrates how to add Prometheus instrumentation to a Java application using the Simpleclient library. You'll expose custom metrics, configure Prometheus scraping, and visualize JVM and application metrics.

## Objective
By the end of this lab, you will be able to:
- Instrument a Java application with Prometheus metrics
- Expose metrics via HTTP endpoint
- Configure Prometheus to scrape Java application metrics
- Visualize custom and JVM metrics in Prometheus UI

## Prerequisites
- Java JDK 11+
- Maven 3.6+
- Prometheus installed (from previous labs)
- Basic Java knowledge

---

## Lab Setup

### 1. Clone and Build Sample Application

1. Clone the example repository:
```bash
git clone https://github.com/RobustPerception/java_examples.git
cd java_examples/java_simple/
```

2. Build the application:
```bash
mvn package
```

### 2. Run Instrumented Application

1. Start the Java application:
```bash
java -jar target/java_simple-1.0-SNAPSHOT-jar-with-dependencies.jar &
```

2. Verify it's running:
```bash
curl localhost:1234/
```
*Expected Output:* `Hello World!`

3. Check exposed metrics:
```bash
curl localhost:1234/metrics | grep hello_worlds_total
```

---

## Key Instrumentation Concepts

The sample application demonstrates:

1. **Counter Metric** - Tracks total requests:
```java
static final Counter requests = Counter.build()
    .name("hello_worlds_total")
    .help("Total hello world requests.").register();
```

2. **Gauge Metric** - Monitors in-progress requests:
```java
static final Gauge inprogress = Gauge.build()
    .name("hello_worlds_in_progress")
    .help("Current hello worlds in progress.").register();
```

3. **Default JVM Metrics** - Automatically collected:
```java
DefaultExports.initialize();
```

---

## Configure Prometheus

1. Create scrape config:
```bash
cat <<EOF > prometheus-java.yml
scrape_configs:
  - job_name: 'java-app'
    metrics_path: '/metrics'
    static_configs:
      - targets: ['localhost:1234']
EOF
```

2. Start Prometheus:
```bash
./prometheus --config.file=prometheus-java.yml
```

---

## Monitoring Practice

### 1. Access Prometheus UI
```
http://localhost:9090
```

### 2. Try These Queries

1. Request rate (requests per second):
```promql
rate(hello_worlds_total[1m])
```

2. Current JVM memory usage:
```promql
jvm_memory_bytes_used{area="heap"}
```

3. Active requests:
```promql
hello_worlds_in_progress
```

### 3. Generate Load
```bash
# Run in separate terminal
while true; do curl localhost:1234/; sleep 0.5; done
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| No metrics exposed | Verify app is running with `ps aux | grep java` |
| Connection refused | Check port 1234 is open with `netstat -tulnp` |
| Unknown metrics | Ensure `DefaultExports.initialize()` is called |

---

## Conclusion
You've successfully:
- Instrumented a Java app with custom metrics
- Exposed metrics via HTTP endpoint
- Configured Prometheus scraping
- Visualized application and JVM metrics

Next steps:
1. Add histograms for request latency
2. Configure alert rules for error rates
3. Build Grafana dashboards

## Cleanup
Stop the Java application:
```bash
pkill -f java_simple
```

## Further Reading
- [Java Client Documentation](https://github.com/prometheus/client_java)
- [Instrumentation Best Practices](https://prometheus.io/docs/practices/instrumentation/)
- [Spring Boot Starter](https://github.com/prometheus/client_java#spring-boot-starter)

> **Pro Tip:** Use `@Timed` annotations in Spring Boot apps for automatic endpoint timing metrics!
