https://github.com/docker/docker/issues/28527

```bash
docker stack deploy
```


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


```bash
docker container prune
```
```bash
docker image prune
```
```bash
docker network prune
```
```bash
docker container prune
```



![](images/docker_experimental.jpg)

---


## Check before if the file exists

```bash
cat /etc/docker/daemon.json
```

If there is nothing you can use this directly.
Otherwise copy your content and extend it with the `experimental` key .

```bash
cat > /etc/docker/daemon.json <<EOF
{
  "experimental": true
}
EOF
```

---

## Check the kernel

```bash
uname -a 
Linux deathstar 4.9.0 #1 SMP Thu Dec 15 22:46:19 CET 2016 x86_64 GNU/Linux
```

---

## Check out the source

```bash
git clone https://github.com/xemul/criu
```


```bash
# Latest Release of CRIU
git checkout v2.10
```

---

## Install Depencendies for CRIU

```bash
sudo apt-get update && \
sudo apt-get install \
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
sudo make
```

---

## Required for documentation 

```bash
sudo apt-get install asciidoc xmlto
```
## Install to your local path (/usr/local)

``bash
sudo make install
```
## Check CRIU

```bash
sudo criu check
```

```bash
# This should happen
Looks good.
```

---

# Test CRIU with Docker

## Start a container

```bash
docker run --security-opt=seccomp:unconfined --name cr -d busybox /bin/sh -c 'i=0; while true; do echo $i; i=$(expr $i + 1); sleep 1; done'
```

## Lets have a look of the output

```bash
docker attach cr
```

## Create a ceckpoint

```bash
docker checkpoint create cr checkpoint1
```

## Restore Checkpoint

```bash
docker start --checkpoint checkpoint1 cr

docker attach cr
```

## Or use it directly

```bash
docker start -a --checkpoint checkpoint1 cr
```

## For overview of the hole 

Look at the logs

```bash
docker logs cr
````