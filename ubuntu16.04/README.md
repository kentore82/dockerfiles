# Howto:

```
$ sudo docker run -d -p 5800:22 -P --name test_sshd rastasheep/ubuntu-sshd:14.04
$ sudo docker port test_sshd 22

$ ssh root@localhost -p 32769 
# The password is `root`
root@test_sshd $
```
