FROM       ubuntu:16.04
MAINTAINER Ken Tore Tallakstad "https://github.com/kentore82"

RUN apt-get update

RUN apt-get install -y openssh-server python2.7 python2.7-dev
RUN mkdir /var/run/sshd

ADD ./start.sh /start.sh

RUN echo 'root:root' |chpasswd

RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

RUN chmod 755 /start.sh
EXPOSE 22
RUN ./start.sh

CMD    ["/usr/sbin/sshd", "-D"]
