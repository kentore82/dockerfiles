# Howto:

```
# Build image
$ docker build --rm -t kentore82/ubuntu16.04:base .

# Run container
$ docker run -d --cap-add SYS_ADMIN --security-opt seccomp:unconfined \
 -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /tmp/$(mktemp -d):/run \ 
 --name <containerName> kentore82/ubuntu16.04:base

# Get container IP:
$ docker inspect <containerName> | grep IPAddress

$ ssh -i /path/to/priv/key root@<container IP>
```
