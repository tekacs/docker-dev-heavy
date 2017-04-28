FROM fedora:rawhide
MAINTAINER Amar Sood <mail@tekacs.com>

EXPOSE 22

RUN dnf -y update && dnf -y install openssh-server passwd && dnf clean all

COPY entrypoint.sh /
COPY boot.sh /

ENTRYPOINT ["/boot.sh"]
