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
<br/> In my case, I will also grep/filter the search down for ```peira``` releated process activity.

```
ps aux | grep -a "peira"
```

Read the content of the ```storefront-capture.scap``` file where the process name ```peira``` was identified:
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

Can we see all the ```nmap``` traffic from that newly-created pod:
```
sysdig -r malicious-traffic.scap "proc.name=nmap and evt.type=sendto and fd.sip=10.244.0.8"
```



Use  ```-S``` or  ```--summary``` to print the event summary (i.e. the list of the top events) when the capture ends.

```
sysdig -r malicious-traffic.scap proc.name=nmap --summary
```

<img width="953" alt="Screenshot 2024-09-04 at 14 40 33" src="https://github.com/user-attachments/assets/b6e6e05e-f158-4667-b2a9-1bf82748a87c">



This could still be useless, as its missing some context. Mayve you would like to see the ```markdown format``` otuput:
```
sysdig --list-markdown
```

```
sysdig --list
```

<img width="953" alt="Screenshot 2024-09-04 at 14 10 59" src="https://github.com/user-attachments/assets/1f6b3b27-9dd4-40a8-b25f-f16ade9765a7">



On the flip side, I never really learned how to read packets in ```ASCII format```:
```
sysdig -r storefront-capture.scap proc.name=sandbox-agent or proc.name=nmap --print-hex-ascii
```
Filter for some specific plain text context from within the scap output:
```
sysdig -r storefront-capture.scap "proc.name=wget and evt.type=write" | grep -a "api.twilio.com"
```

You can also watch this activity via Sysdig Chisels:
```
sysdig -c spy_users.lua
```

Delete the rogue workload when no longer needed:
```
kubectl delete -f https://installer.calicocloud.io/rogue-demo.yaml -n storefront
```

## Part 4 - Getting the help you need

```
sysdig --help
```

```
sysdig --help | grep -a "color"
```

```
sysdig --log-level=warning
```

#### Run Sysdig as non-root user

```https://github.com/draios/sysdig/wiki/How-to-Install-Sysdig-for-Linux#use-sysdig-as-non-root```

Check which version of the Falco libraries are used:
```
sysdig  --libs-version
```
<br/>
https://man7.org/linux/man-pages/man8/sysdig.8.html

## Part 5 - Opening and Deleting Files

```
echo "helloworld" > helloworld.txt
```

```
cat helloworld.txt
```

Instead, we need a background process/program that will do this throughout the length of the capture:
```
wget https://raw.githubusercontent.com/nigel-falco/sysdig-inspect/main/file_watcher.sh
```

```
chmod +x file_watcher.sh
```

```
./file_watcher.sh &
```

Print all the open system calls invoked by cat
```
sysdig proc.name=cat and evt.type=read and evt.buffer contains helloworld
```

<img width="953" alt="Screenshot 2024-09-04 at 14 37 45" src="https://github.com/user-attachments/assets/b74868c5-666f-4cb8-b379-57792ae65dee">


Print the name of the files opened by cat
```
sysdig -p"%evt.arg.name" proc.name=cat and evt.type=open
```

Compare and contrast the info collect from the Modern eBPF probe:
```
sysdig proc.name=cat --modern-bpf
```

## Part 6 - Chisels

Sysdig chisels are little scripts that analyze the sysdig event stream to perform useful actions. <br/>
To get the list of available chisels, type
            
```
sysdig -cl
```

To run one of the chisels, you use the ```-c``` flag, e.g.
```
sysdig -c topfiles_bytes
```

Above is the top files by activity, the below is top system calls over a period of time:
```
sysdig -c topscalls.lua
```

```
sysdig -c httplog.lua --color true
```

![Screenshot 2024-09-05 at 15 49 17](https://github.com/user-attachments/assets/cbb5c5a4-ae27-45c3-8fa3-533fcc5dc8bb)

Advanced use case to exclude specific file descriptor names:
```
sysdig -c topfiles_bytes "not fd.name contains /dev"
```

## Part 7 - Terminal Shell into Containers

Again, we need a background process to run automatic shell logins
```
wget https://raw.githubusercontent.com/nigel-falco/sysdig-inspect/main/login_shells.sh
```

```
chmod +x login_shells.sh
```

```
./login_shells.sh &
```

To avoid this syntax errors, you can either escape the parentheses or wrap the entire filter in quotes so that the shell doesn't misinterpret the command.
```
sysdig "proc.name in (bash,sh,zsh) and evt.type=execve"
```
For checking interactive terminal activity, use:
```
sysdig "proc.name in (bash,sh,zsh) and fd.name contains /dev/tty"
```

![Screenshot 2024-09-05 at 15 34 17](https://github.com/user-attachments/assets/25bb16d8-4628-4406-94ad-22bf82979680)

```
sysdig "proc.name in (bash,sh,zsh) and evt.type=execve" -p "%evt.time %proc.name %user.name"
```

Get the container-specific activity:
```
sysdig --modern-bpf -pc evt.type=connect and container.id!=host
```

## Part 8 - Plugins

The same plugins used by ```Falco``` can also be also used for extending the inputs of ```Sysdig OSS```. <br/>
Plugins help to add new event sources that can be evaluated using filtering expressions/Falco rules and the ability to define new fields that can extract information from events.

<img width="498" alt="Screenshot 2024-09-06 at 09 56 41" src="https://github.com/user-attachments/assets/f21961de-59c4-41a6-8557-845e3fb03439">

Once installed, download the plugin you need from the [plugin registry](https://d20hasrqv82i0q.cloudfront.net/?prefix=plugins/stable/) or elsewhere and install it in ```/usr/share/sysdig/plugins``` following these steps:

```
mkdir -p /usr/share/sysdig/plugins
cd /tmp
wget https://download.falco.org/plugins/stable/dummy-0.2.0-x86_64.tar.gz
tar xvzf dummy-0.2.0-x86_64.tar.gz
mv libdummy.so /usr/share/sysdig/plugins/
```

To verify the plugin is correctly deployed, you can run the following command:
```
sysdig -Il
```

### Configuration file

To enable plugins, you can either use a Falco plugin configuration file or pass arguments to your command line. <br/>
Let's download an example of a config file for the dummy plugin to generate ```10 synthetic events``` to briefly test our plugin framework:

```
wget https://raw.githubusercontent.com/nigel-falco/sysdig-inspect/main/dummy-config.yaml
```

To use this configuration file, just use the option ```--plugin-config-file``` followed by the filename you have created containing the configuration.
```
sysdig --plugin-config-file dummy-config.yaml
```

### Command line configuration

As an alternative, you can use the options -H and/or -I in the command line to configure a plugin as follows:

```
sysdig -H dummy:'{"jitter":50}' -I dummy:'{"start":1,"maxEvents":10}'
```
