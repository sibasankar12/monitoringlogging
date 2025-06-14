# **Lab Tutorial 02: Building Logstash Pipelines for Centralized Log Collection**  

## **Introduction**  
Logstash is a critical component of the **ELK Stack**, designed for data ingestion, transformation, and forwarding to storage systems like Elasticsearch. In this lab, you will configure a Logstash pipeline to collect logs, process them (optional filtering), and store them in Elasticsearch for centralized log management.  

## **Objective**  
- Configure a Logstash pipeline with **input**, **filter**, and **output** blocks.  
- Test the pipeline by sending dummy data to Elasticsearch.  
- Validate log storage in Elasticsearch and verify indexed data.  

## **Lab Prerequisites**  
- **ELK Stack installed** (Elasticsearch, Logstash, Kibana).  
- **Basic familiarity with terminal commands** (e.g., `curl`, `nano`).  
- **Sudo privileges** for editing configuration files.  

---

## **Lab Steps**  

### **Step 1: Configure the Logstash Pipeline**  
1. Open the Logstash configuration file:  
   ```bash
   sudo nano /etc/logstash/conf.d/logstash.conf
   ```  
2. Add the following configuration to define a pipeline with:  
   - **Input:** Accepts logs from stdin (command line).  
   - **Filter (Optional):** Add transformations if needed (e.g., Grok parsing).  
   - **Output:** Sends logs to Elasticsearch and prints to stdout for debugging.  

   ```plaintext
   input {
     stdin { }
   }
   filter {
     # Optional: Add filters here (e.g., Grok, Mutate)
   }
   output {
     elasticsearch {
       hosts => ["http://localhost:9200"]
       index => "test_index"
     }
     stdout { codec => rubydebug }
   }
   ```  

   **Save the file** (`Ctrl+O`, `Enter`, `Ctrl+X`).  

---

### **Step 2: Test the Pipeline**  
1. Start Logstash with the configuration file:  
   ```bash
   /usr/share/logstash/bin/logstash -f /etc/logstash/conf.d/logstash.conf
   ```  
   - Logstash will start and wait for input.  

2. **Enter a test message** in the terminal:  
   ```plaintext
   Hello, this is a test message.
   ```  
   - Press `Enter` to send the message.  
   - Observe the processed output in the terminal (Ruby debug format).  

---

### **Step 3: Validate Data in Elasticsearch**  
1. Check if `test_index` was created:  
   ```bash
   curl 'localhost:9200/_cat/indices?v' | grep test_index
   ```  
   **Expected Output:**  
   ```plaintext
   green open test_index  XXXX 1 0 1 0 5kb 5kb
   ```  

2. Query the indexed data:  
   ```bash
   curl -X GET "localhost:9200/test_index/_search?pretty"
   ```  
   **Expected Output:**  
   ```json
   {
     "hits": {
       "hits": [{
         "_source": { "message": "Hello, this is a test message." }
       }]
     }
   }
   ```  

---

### **Step 4: Cleanup (Optional)**  
Delete the test index after validation:  
```bash
curl -X DELETE "localhost:9200/test_index"
```  

---

## **Command Summary**  

| **Action**                     | **Command**                                                                 |
|--------------------------------|-----------------------------------------------------------------------------|
| Edit Logstash config           | `sudo nano /etc/logstash/conf.d/logstash.conf`                              |
| Start Logstash pipeline        | `/usr/share/logstash/bin/logstash -f /etc/logstash/conf.d/logstash.conf`    |
| Check Elasticsearch indices    | `curl 'localhost:9200/_cat/indices?v' \| grep test_index`                   |
| Query indexed data             | `curl -X GET "localhost:9200/test_index/_search?pretty"`                    |
| Delete test index              | `curl -X DELETE "localhost:9200/test_index"`                                |

---

## **Summary**  
✔ Configured a **Logstash pipeline** with input, filter, and output blocks.  
✔ Tested the pipeline by sending logs to **Elasticsearch**.  
✔ Validated data storage using `curl` commands.  

## **Further Reading**  
- [Logstash Configuration Guide](https://www.elastic.co/guide/en/logstash/current/configuration.html)  
- [Elasticsearch Index Management](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices.html)  

**Next Lab:** Visualizing Logs in Kibana.
