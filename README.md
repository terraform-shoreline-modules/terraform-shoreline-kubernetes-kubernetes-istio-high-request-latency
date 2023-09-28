
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Istio High Request Latency
---

The Istio High Request Latency incident type refers to an issue where the average execution time for requests in Istio is longer than the expected threshold of 100ms. This may result in slow or unresponsive services, negatively impacting the user experience. It may require investigation and troubleshooting to identify the underlying cause and resolve the issue.

### Parameters
```shell
export POD_NAME="PLACEHOLDER"

export NAMESPACE="PLACEHOLDER"

export CONTAINER_NAME="PLACEHOLDER"

export SERVICE_NAME="PLACEHOLDER"

export RESOURCE_NAME="PLACEHOLDER"

export RESOURCE_VALUE="PLACEHOLDER"

export DEPLOYMENT_NAME="PLACEHOLDER"
```

## Debug

### Check if Istio is installed in the cluster
```shell
kubectl get ns istio-system
```

### Check the status of the Istio pods and services
```shell
kubectl get pods -n istio-system

kubectl get svc -n istio-system
```

### Check the logs of the Istio sidecar proxy for the affected service
```shell
kubectl logs ${POD_NAME} -c istio-proxy -n ${NAMESPACE}
```

### Check the latency of the requests to the affected service
```shell
kubectl exec ${POD_NAME} -c ${CONTAINER_NAME} -n ${NAMESPACE} -- sh -c "curl http://localhost:8080/healthz"
```

### Check the Istio configuration for the affected service
```shell
kubectl get virtualservices -n ${NAMESPACE}

kubectl get destinationrules -n ${NAMESPACE}

kubectl get gateway -n ${NAMESPACE}
```

### Check if there are any network issues affecting the service
```shell
kubectl exec ${POD_NAME} -n ${NAMESPACE} -- ping ${SERVICE_NAME}
```

### Check if there are any CPU or memory issues affecting the service
```shell
kubectl top pods -n ${NAMESPACE}

kubectl describe pod ${POD_NAME} -n ${NAMESPACE}
```

### Resource constraints: The service may be under-resourced, leading to a slower response time for requests.
```shell


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


```

## Repair

### If the issue is related to hardware resource constraints, consider increasing the resources allocated to the affected service or adding more nodes to the cluster.
```shell


#!/bin/bash



# Set variables

DEPLOYMENT_NAME=${DEPLOYMENT_NAME}

RESOURCE_NAME=${RESOURCE_NAME}

RESOURCE_VALUE=${RESOURCE_VALUE}

# Use kubectl patch to patch the deployment
kubectl patch deployment $DEPLOYMENT_NAME -p '{"spec":{"template":{"spec":{"containers":{"resources":[{"limits":{"'$RESOURCE_NAME'":"'$RESOURCE_VALUE'"}, "requests":{"'$RESOURCE_NAME'":"'$RESOURCE_VALUE'"}}]}}}}}'

```