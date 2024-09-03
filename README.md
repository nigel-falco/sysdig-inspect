# Sysdig Inspect Lab

## Part 1 - Install Sysdig with Basic Filters

We can compare Sysdig Inspect and Tetragon via the below Lab environment: <br/>
```https://isovalent.com/labs/tetragon-getting-started```
<br/><br/>
You can automatically install Sysdig Inspect via the below installer:
```
curl -s https://s3.amazonaws.com/download.draios.com/stable/install-sysdig | sudo bash
```
You can run Sysdig with no filters via the below command: <br/>
Similar to running Wireshark without filters, its impossible to read.

```
sysdig
```

Run a capture for ```5 Seconds``` via the below ```timeout``` commands:
```
timeout 5 sysdig -w nigel-capture.scap
```

You can read the content of the ```nigel-capture.scap``` file with the below command:
```
sysdig -r nigel-capture.scap
```

```epoll_pwait``` - event type is generated when a program waits for an I/O event on an epoll file descriptor
```https://linux.die.net/man/2/epoll_pwait```
```
sysdig -r nigel-capture.scap evt.type=epoll_pwait
```

```kube-apiserver``` process validates and configures data for the api objects which include pods, services, and replicationcontrollers in Kubernetes
```
sysdig -r nigel-capture.scap evt.type=epoll_pwait and proc.name=kube-apiserver
```

## Part 2 - Monitoring a Microservice Architecture

Introduce the Storefront web application to Kubernetes:
```
kubectl apply -f https://installer.calicocloud.io/storefront-demo.yaml
```
Check the IP addresses assigned to our workloads:
```
kubectl get pod -n storefront -o wide
```
Run a capture for ```5 Seconds``` to capture the 
```
timeout 5 sysdig -w storefront-capture.scap
```

Better understand what processes are running on the system with either ```ps aux``` or ```top``` commands:
<br/> 

```
ps aux
```

Read the content of the ```storefront-capture.scap``` file with the below command:
```
sysdig -r storefront-capture.scap proc.name=sandbox-agent or proc.name=peira
```

<img width="953" alt="Screenshot 2024-09-03 at 16 07 37" src="https://github.com/user-attachments/assets/55ab4efe-e8cb-4167-96e6-e79bd4e486ac">

## Part 3 - Introduce a Rogue/Malicious workload

```
kubectl apply -f https://installer.calicocloud.io/rogue-demo.yaml -n storefront
```

Capture all the bad traffic:
```
timeout 5 sysdig -w malicious-traffic.scap
```

Delete the rogue workload when no longer needed:
```
kubectl delete -f https://installer.calicocloud.io/rogue-demo.yaml -n storefront
```
