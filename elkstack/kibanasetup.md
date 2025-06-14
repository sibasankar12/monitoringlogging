# **Lab Tutorial 03: Building Dashboards and Visualizations in Kibana**

## **Introduction**
Kibana is the visualization layer of the ELK Stack, enabling users to explore, analyze, and visualize data stored in Elasticsearch. This lab guides you through creating Kibana dashboards to monitor application logs, helping identify performance issues and system health trends.

## **Objective**
- Ingest sample log data into Elasticsearch via Logstash
- Create Kibana data views for log analysis
- Build visualizations (bar charts, pie charts) from log data
- Assemble visualizations into interactive dashboards

## **Lab Prerequisites**
- Running ELK Stack (Elasticsearch 7.x+, Logstash, Kibana)
- Basic familiarity with Kibana's interface
- Terminal access with `curl` command available
- Sample log data (provided in lab steps)

---

## **Lab Steps**

### **Step 1: Ingest Sample Logs via Logstash**
1. Start Logstash with a test configuration:
```bash
sudo /usr/share/logstash/bin/logstash -e '
input { stdin { } }
output {
  elasticsearch {
    hosts => ["http://localhost:9200"]
    index => "kibana_lab"
  }
  stdout { codec => rubydebug }
}'
```

2. Paste these sample logs when prompted:
```log
2017-11-29 19:22:31,580 [main] DEBUG - This is debug log...
2017-11-29 19:22:31,581 [main] INFO - This is info log...
2017-11-29 19:22:31,581 [main] WARN - This is warn log...
2017-11-29 19:22:31,581 [main] ERROR - This is error log...
2017-11-29 19:22:31,582 [main] FATAL - This is fatal log...
2017-11-29 19:23:44,026 [main] DEBUG - This is debug log...
2017-11-29 19:23:44,028 [main] INFO - This is info log...
```

3. Verify data in Elasticsearch:
```bash
curl -XGET "localhost:9200/kibana_lab/_search?pretty"
```

### **Step 2: Create Kibana Data View**
1. Access Kibana at `http://localhost:5601`
2. Navigate to **Stack Management > Index Patterns**
3. Click **Create index pattern**
4. Enter `kibana_lab*` as pattern name
5. Select `@timestamp` as time field
6. Click **Create index pattern**

### **Step 3: Build Visualizations**
1. Go to **Visualize Library**
2. Create **Vertical Bar** chart:
   - Y-axis: Count of documents
   - X-axis: Date histogram using `@timestamp`
3. Create **Pie Chart**:
   - Slice by: `log_level` (or equivalent field)
   - Size by: Count
4. Save visualizations with descriptive names

### **Step 4: Create Dashboard**
1. Navigate to **Dashboard**
2. Click **Create dashboard**
3. Add existing visualizations
4. Configure layout and sizing
5. Save as "Application Logs Monitoring"

---

## **Common Errors & Troubleshooting**

| Error | Solution |
|-------|----------|
| "No results found" in Discover | Verify index pattern matches actual index name |
| Visualizations not loading | Check field mappings in Elasticsearch |
| "Unable to fetch mapping" error | Ensure index contains data before creating pattern |
| Dashboard filters not working | Verify field is mapped as keyword (not text) |
| Time picker not functioning | Confirm timestamp field is properly mapped |

**Debugging Tips:**
1. Check Elasticsearch index status:
```bash
curl -XGET "localhost:9200/_cat/indices/kibana_lab?v"
```

2. Verify field mappings:
```bash
curl -XGET "localhost:9200/kibana_lab/_mapping?pretty"
```

3. Reset Kibana saved objects (if needed):
```bash
curl -XPOST "localhost:5601/api/saved_objects/_import?overwrite=true" -H "kbn-xsrf: true" --form file=@export.ndjson
```

---

## **Summary**
✔ Successfully ingested sample log data into Elasticsearch  
✔ Created Kibana data views for log analysis  
✔ Built multiple visualizations (bar charts, pie charts)  
✔ Combined visualizations into an interactive dashboard  

## **Further Reading**
- [Kibana Visualization Guide](https://www.elastic.co/guide/en/kibana/current/visualize.html)
- [Dashboard Best Practices](https://www.elastic.co/blog/kibana-dashboard-design-best-practices)
- [ELK Stack Monitoring](https://www.elastic.co/guide/en/elastic-stack-overview/current/monitoring-production.html)

**Next Lab:** Advanced Kibana: Machine Learning and Alerting
