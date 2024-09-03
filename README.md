# Sysdig Inspect Lab

We can compare Sysdig Inspect and Tetragon via the below Lab environment:
```https://isovalent.com/labs/tetragon-getting-started```
<br/>
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

You can read the content of the nigel-capture.scap file with the below command:
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
