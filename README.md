# my Dockerfiles

These images comes with systemd setup so services can be upped and downed within the container.
This is really useful for Ansible testing.

* `centos7.4` - base CentOS 7.4 Dockerfile with passwordless ssh login
* `ubuntu16.04` - base Ubuntu 16.04 Dockerfile with passwordless ssh login

Push container to remote:
```bash
# Save container to image
docker commit -a "Ken Tore Tallakstad tallakstad@gmail.com" -m "message" <containerID> kentore82/repo:tag

# Push remote
docker push kentore82/repo:tag


```