

#!/bin/bash



# Check CPU and memory usage of the pod

CPU=$(kubectl top pod ${POD_NAME} | awk '{print $2}' | tail -n1)

MEMORY=$(kubectl top pod ${POD_NAME} | awk '{print $3}' | tail -n1)



# Check resource limits and requests set in the pod spec

CPU_LIMIT=$(kubectl describe pod ${POD_NAME} | grep "Limits" | awk '{print $4}')

MEMORY_LIMIT=$(kubectl describe pod ${POD_NAME} | grep "Limits" | awk '{print $6}')

CPU_REQUEST=$(kubectl describe pod ${POD_NAME} | grep "Requests" | awk '{print $4}')

MEMORY_REQUEST=$(kubectl describe pod ${POD_NAME} | grep "Requests" | awk '{print $6}')



# Check if CPU and memory usage are close to or exceeding the limits and requests

if (( $(echo "$CPU >= $CPU_LIMIT" |bc -l) )) || (( $(echo "$MEMORY >= $MEMORY_LIMIT" |bc -l) )) || (( $(echo "$CPU >= $CPU_REQUEST" |bc -l) )) || (( $(echo "$MEMORY >= $MEMORY_REQUEST" |bc -l) )); then

    echo "Pod ${POD_NAME} is using high CPU and/or memory resources, which may be causing the slow response time."

fi