#!/bin/bash

# Push a metric to the Prometheus Pushgateway

# Set the Pushgateway address
PUSHGATEWAY_ADDRESS="localhost"
PUSHGATEWAY_PORT="9091"

# Define the metric and its value
METRIC_NAME="batch_job_duration_seconds"
METRIC_VALUE=$(date +%s)

# Construct the metric payload in the expected format
METRIC_PAYLOAD="#HELP $METRIC_NAME Duration of the batch job in seconds
#TYPE $METRIC_NAME gauge
$METRIC_NAME $METRIC_VALUE"

# Push the metric to the Pushgateway
echo -e "$METRIC_PAYLOAD" | curl --data-binary @- http://$PUSHGATEWAY_ADDRESS:$PUSHGATEWAY_PORT/metrics/job/batch_job
