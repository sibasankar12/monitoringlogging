# **Lab Tutorial 01: Setting up and Configuring Elasticsearch for Log Storage**  

## **Introduction**  
Elasticsearch is a powerful distributed search and analytics engine commonly used for log storage and analysis. In this lab, you will learn how to set up and configure Elasticsearch to store and manage application logs. By the end of this tutorial, you will be able to create indices, add documents, retrieve data, and clean up resources in Elasticsearch.  

## **Objective**  
- Verify Elasticsearch is running.  
- Create an index with custom settings and mappings.  
- Add, retrieve, and delete documents in Elasticsearch.  
- Check index status and perform cleanup.  

## **Lab Prerequisites**  
- **Elasticsearch installed and running** (locally or on a server).  
- **Basic familiarity with command-line tools** (e.g., `curl`).  
- **Access to a terminal or command prompt.**  

---

## **Lab Steps**  

### **Step 1: Verify Elasticsearch is Running**  
Run the following command to check if Elasticsearch is operational:  

```bash
curl -X GET "localhost:9200"
```  
**Expected Output:**  
A JSON response containing cluster details (name, version, etc.).  

---

### **Step 2: Create an Index**  
Define an index (`my-index`) with custom settings (shards, replicas) and mappings (field types):  

```bash
curl -X PUT "localhost:9200/my-index" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "number_of_shards": 3,
    "number_of_replicas": 1
  },
  "mappings": {
    "properties": {
      "field1": { "type": "text" },
      "field2": { "type": "keyword" }
    }
  }
}
'
```  
**Expected Output:**  
A confirmation (`"acknowledged": true`) that the index was created.  

---

### **Step 3: Add a Document**  
Insert a sample document into `my-index`:  

```bash
curl -X POST "localhost:9200/my-index/_doc/1" -H 'Content-Type: application/json' -d'
{
  "field1": "value1",
  "field2": "value2"
}
'
```  
**Expected Output:**  
A response with the document ID (`"_id": "1"`) and status (`"result": "created"`).  

---

### **Step 4: Retrieve the Document**  
Fetch the stored document by its ID:  

```bash
curl -X GET "localhost:9200/my-index/_doc/1"
```  
**Expected Output:**  
The document data (`field1`, `field2`) along with metadata.  

---

### **Step 5: Check Index Status**  
List all indices and filter for `my-index`:  

```bash
curl 'localhost:9200/_cat/indices?v' | grep my-index
```  
**Expected Output:**  
A table showing `my-index` with details like health, status, and document count.  

---

### **Step 6: Delete the Index**  
Clean up by removing `my-index`:  

```bash
curl -X DELETE "localhost:9200/my-index"
```  
**Expected Output:**  
A confirmation (`"acknowledged": true`) that the index was deleted.  

---

### **Step 7: Verify Index Deletion**  
Confirm `my-index` no longer exists:  

```bash
curl 'localhost:9200/_cat/indices?v' | grep my-index
```  
**Expected Output:**  
No output (index is deleted).  

---

## **Command Summary**  

| **Action**               | **Command**                                                                 |
|--------------------------|-----------------------------------------------------------------------------|
| Verify Elasticsearch     | `curl -X GET "localhost:9200"`                                             |
| Create an index          | `curl -X PUT "localhost:9200/my-index" -H 'Content-Type: application/json' -d'{...}'` |
| Add a document           | `curl -X POST "localhost:9200/my-index/_doc/1" -H 'Content-Type: application/json' -d'{...}'` |
| Retrieve a document      | `curl -X GET "localhost:9200/my-index/_doc/1"`                             |
| List indices             | `curl 'localhost:9200/_cat/indices?v' \| grep my-index`                    |
| Delete an index          | `curl -X DELETE "localhost:9200/my-index"`                                 |

---

## **Summary**  
In this lab, you learned how to:  
1. Verify Elasticsearch is running.  
2. Create an index with custom settings and mappings.  
3. Add, retrieve, and delete documents.  
4. Check index status and perform cleanup.  

## **Further Reading**  
- [Elasticsearch Official Documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)  
- [Elasticsearch API Guide](https://www.elastic.co/guide/en/elasticsearch/reference/current/rest-apis.html)  
