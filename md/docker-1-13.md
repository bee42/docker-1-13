# What's in Docker 1.13

![](images/docker-logo.png)

### **Niclas Mietz**
### **Peter Rossbach**

---
## Deploy with docker-componse

https://github.com/docker/docker/issues/28527

```bash
$ docker stack deploy
```
**TODO**

-
### docker-compose V3

```
$ docker stack deploy \
    --compose-file ./docker-compose.yml \
    mystack
```

---
## Management of plugins

```bash
Usage:	docker plugin COMMAND

Manage plugins

Options:
      --help   Print usage

Commands:
  create      Create a plugin from a rootfs and configuration. Plugin data directory must contain config.json and rootfs directory.
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

---
## Remove unused things

```bash
$ docker container prune
```
```bash
$ docker image prune
```
```bash
$ docker network prune
```
$ ```bash
docker container prune
```

---
## Activation of Experimental

![](images/docker_experimental.jpg)

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

## Or use it directly

```bash
$ docker start -a --checkpoint checkpoint1 cr
```

## For overview of the hole

Look at the logs

```bash
$ docker logs cr
```

---
## Cache Layers When Building

This means that we can go back to the old days of “pulling before building” to populate the build cache and avoid having to build all layers again.

```
$ docker pull myimage:v1.0
$ docker build --cache-from myimage:v1.0 -t myimage:v1.1 .
```

***
* https://github.com/docker/docker/pull/26839

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
## New –port flag in docker service create

```
$ docker service create --publish 8080:80 my-service
```

New port syntax:

```
$ docker service create \
    --name my-service \
    --port mode=ingress,target=80,published=8080,protocol=tcp
```

Allow more options at the future, like mounts at service!

---
## Links

* https://blog.codeship.com/whats-new-docker-1-13
* https://benchmarks.cisecurity.org/tools2/docker/CIS_Docker_1.13.0_Benchmark_v1.0.0.pdf
* https://blog.docker.com/2017/01/whats-new-in-docker-1-13/
* https://blog.docker.com/2017/01/cpu-management-docker-1-13/
* https://blog.nimbleci.com/2016/11/17/whats-coming-in-docker-1-13/
