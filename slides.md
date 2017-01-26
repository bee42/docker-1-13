# What's in Docker 1.13

![](images/docker-logo.png)

### **Niclas Mietz**
### **Peter Rossbach**

---
## Docker Compose meets Swarm

![](images/compose-meets-swarm.png)

-
### Deploy with docker-compose

```
$ docker stack deploy \
    --compose-file ./docker-compose.yml \
    mystack
```
***
* https://docs.docker.com/compose/compose-file/#/deploy
* https://github.com/docker/docker/issues/28527

-
### Simple placement
```
version: "3"
services:
  redis:
    image: redis:3.2-alpine
    ports:
      - "6379"
    networks:
      - app
    deploy:
      placement:
        constraints: [node.role == manager]
```

-
### Add some service parameter

```
version: "3"
services:
  ...
  xxx-app:
    image: xxx-app
    ports:
      - 5000:80
    networks:
      - app
    depends_on:
      - redis
    deploy:
      mode: replicated
      replicas: 2
      labels: [APP=XXX]
      placement:
        constraints: [node.role == worker]
```

-
### Add Resource constraints I

```
  yyy-app:
    deploy:
      mode: replicated
      replicas: 2
      labels: [APP=XXX]
      # service resource management
      resources:
        # Hard limit - Docker does not allow to allocate more
        limits:
          cpus: '0.25'
          memory: 512M
        # Soft limit - Docker makes best effort to return to it
        reservations:
          cpus: '0.25'
          memory: 256M
      # service restart policy
```
-
### Add Resource constraints II

```
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
        window: 120s
      # service update configuration
      update_config:
        parallelism: 1
        delay: 10s
        failure_action: continue
        monitor: 60s
        max_failure_ratio: 0.3
      # placement constraint - in this case on 'worker' nodes only
      placement:
        constraints: [node.role == worker]
```

---
## Management of plugins

```bash
Usage:	docker plugin COMMAND

Manage plugins

Options:
      --help   Print usage

Commands:
  create      Create a plugin from a rootfs and configuration.
              Plugin data directory must contain config.json and rootfs directory.
  disable     Disable a plugin
  enable      Enable a plugin
  inspect     Display detailed information on one or more plugins
  install     Install a plugin
  ls          List plugins
  push        Push a plugin to a registry
  rm          Remove one or more plugins
  set         Change settings for a plugin

Run 'docker plugin COMMAND --help' for more information on a command.
```

---
## Management of the system

```bash
Usage:	docker system COMMAND

Manage Docker

Options:
      --help   Print usage

Commands:
  df          Show docker disk usage
  events      Get real time events from the server
  info        Display system-wide information
  prune       Remove unused data

Run 'docker system COMMAND --help' for more information on a command.
```

-
### docker system df

```
$ docker system df
```

| TYPE          | TOTAL | ACTIVE | SIZE     | RECLAIMABLE     |
|:--------------|:------|:-------|:---------|:----------------|
| Images        | 75    | 1      | 8.132 GB | 7.401 GB (91%)  |
| Containers    | 4     | 1      | 0 B      | 0 B             |
| Local Volumes | 4     | 0      | 17.64 MB | 17.64 MB (100%) |

-
### Remove unused things

```bash
$ docker volume prune
```

```bash
$ docker image prune
```

```bash
$ docker network prune
```

```bash
$ docker container prune
```

or all

```bash
$ docker system prune
```
***
Use this command with **caution**

---
## Cache Layers When Building

This means that we can go back to the old days of “pulling before building” to populate the build cache and avoid having to build all layers again.

```
$ docker pull myimage:v1.0
$ docker build --cache-from myimage:v1.0 -t myimage:v1.1 .
```

***
* https://github.com/docker/docker/pull/26839

-
## Squash image layers when building

Squash newly built layers into a single new layer

```bash
$ docker build --squash=true -t ... <dir>
```

Normal ways to build smaller images

* https://semaphoreci.com/blog/2016/12/13/lightweight-docker-images-in-5-steps.html

---
## Secrets Management for services

```bash
Usage:	docker secret COMMAND

Manage Docker secrets

Options:
      --help   Print usage

Commands:
  create      Create a secret from a file or STDIN as content
  inspect     Display detailed information on one or more secrets
  ls          List secrets
  rm          Remove one or more secrets

Run 'docker secret COMMAND --help' for more information on a command.
```

```
$ docker secret create --label env=dev --label rev=20170125 my_secret ./secret.json
```

-
### Password examples

```
$ echo "my-cool-password" | docker secret create login-password
$ docker service create \
    --name myapp \
    --secret login-password \
    ubuntu
# secret mount at /run/secrets/login-password
$ docker exec -it myapp cat /run/secrets/login-password
my-cool-password
```

---
## Attach container to service mesh network

```bash
$ docker network create \
    --driver overlay \
    --attachable \
    my-attachable-network
```

Then you can connect to this network with a container started with docker run:

$ docker run --rm -it \
    --net my-attachable-network \
    ping google.com
```

---
## Activation of Experimental

![](images/docker_experimental.png)

-
### Check before if the file exists

```bash
$ cat /etc/docker/daemon.json
```

If there is nothing you can use this directly.
Otherwise copy your content and extend it with the `experimental` key .

```bash
$ cat > /etc/docker/daemon.json <<EOF
{
  "experimental": true
}
EOF
```


---
## Container Snapshot and restore

![](images/criu-logo.png)

***
* https://criu.org/

-
### Check the kernel

```bash
$ uname -a
Linux deathstar 4.9.0 #1 SMP Thu Dec 15 22:46:19 CET 2016 x86_64 GNU/Linux
```

---
### Check out the source

```bash
$ git clone https://github.com/xemul/criu
```


```bash
# Latest Release of CRIU
$ git checkout v2.10
```

-
### Install depencendies for CRIU

```bash
$ sudo apt-get update && \
  apt-get install \
    build-essential \
    libprotobuf-dev \
    libprotobuf-c0-dev \
    protobuf-c-compiler \
    protobuf-compiler \
    python-protobuf \
    libnet1-dev \
    libnl-3-dev \
    libcap-dev
```

```bash
$ sudo make
```

-
### Required for documentation

```bash
$ sudo apt-get install asciidoc xmlto
```

-
### Install to your local path (/usr/local)

```bash
$ sudo make install
```

-
### Check CRIU

```bash
$ sudo criu check
```

```bash
# This should happen
Looks good.
```

-
### Test CRIU with Docker

* Start a container

```bash
$ docker run --security-opt=seccomp:unconfined \
  --name cr -d busybox /bin/sh -c \
  'i=0; while true; do echo $i; i=$(expr $i + 1); sleep 1; done'
```

-
#### Lets have a look of the output

```bash
$ docker attach cr
```

Create a checkpoint

```bash
$ docker checkpoint create cr checkpoint1
```

-
#### Restore Checkpoint

```bash
$ docker start --checkpoint checkpoint1 cr
$ docker attach cr
```

Or use it directly

```bash
$ docker start -a --checkpoint checkpoint1 cr
```

For overview of the hole

Look at the logs

```bash
$ docker logs cr
```


---
## Docker Metrics - experimental

```
$ cat /etc/docker/daemon.json <<EOF
{
  "experimental":true,
  "metrics-addr":"127.0.0.1:5050"
}
EOF
# access it with docker for mac
$ docker run --rm --network=host alpine \
  sh -c 'apk add --no-cache -q curl && curl localhost:5050/metrics'
```

***
* Engine Metrics 1.13
* Container metrics 1.14

-
###  Docker Metrics - prometheus

```
# HELP http_response_size_bytes The HTTP response sizes in bytes.
# TYPE http_response_size_bytes summary
http_response_size_bytes{handler="prometheus",quantile="0.5"} NaN
http_response_size_bytes{handler="prometheus",quantile="0.9"} NaN
http_response_size_bytes{handler="prometheus",quantile="0.99"} NaN
http_response_size_bytes_sum{handler="prometheus"} 0
http_response_size_bytes_count{handler="prometheus"} 0
```

---
## Build your systems for friends

![](images/build4friends.png)

---
## DevOps Gathering

![](images/Logo_docker_gathering_quadrat_2017_RZ.png)

* 23.3 Docker Workshop
* 24.3 DevOps Talks & Trainings
* 25.3 OpenSpace

### Discount code: docker-bochum-10

***
https://devops-gathering.io

---
## Sponsoring

***
![](images/setlog.png)

***
![](images/gdata.png)

---
## Many Thanks for following!

![](images/bee42-logo.png)

* Start this presentation with
  * `docker run -d -ti -p 4219:80 bee42/docker-1.13
  * `open http://<dockerhost>:4219/docker-1.13`

***
* Follow the us [bee42.com](https://bee42.com)

---
## Links

* https://blog.codeship.com/whats-new-docker-1-13
* https://benchmarks.cisecurity.org/tools2/docker/CIS_Docker_1.13.0_Benchmark_v1.0.0.pdf
* https://blog.docker.com/2017/01/whats-new-in-docker-1-13/
* https://blog.docker.com/2017/01/cpu-management-docker-1-13/
* https://blog.nimbleci.com/2016/11/17/whats-coming-in-docker-1-13/
* http://blog.terranillius.com/post/composev3_swarm/
* https://www.infoq.com/news/2017/01/docker-1.13
