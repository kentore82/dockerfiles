# Howto:

```
# Build image
$ docker build --rm -t kentore82/centos7.4:base .

# Run container
$ docker run -d --cap-add SYS_ADMIN --security-opt seccomp:unconfined \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /tmp/$(mktemp -d):/run \
    --privileged \
    -h <hostname> \
    --name <containerName> \
    --dns=<$DNSIP> --dns=8.8.8.8 --dns=8.8.4.4 kentore82/<image>

# Get container IP:
$ docker inspect <containerName> | grep IPAddress

$ ssh -i /path/to/priv/key root@<container IP>
```
