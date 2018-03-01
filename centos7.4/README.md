# Howto:

```
$ docker build --rm -t kentore82/centos7.4:base .
$ docker run -d kentore82/centos7.4:base

# Get container IP:
$ docker container list
$ docker inspect <container ID> | grep IPAddress

$ ssh -i /path/to/priv/key root@<container IP> 
```
