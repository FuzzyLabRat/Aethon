# Alpine Linux
FROM alpine:latest

# Container Metadata
LABEL name=aethon 
LABEL version=0.0.1
LABEL description="A Docker-based Ansible install w/ Ansible Galaxy"
LABEL maintainer="FuzzyLabRat (FuzzyLabRat@gmail.com)"

# Install Ansible, OpenSSH, Client, and Git; remove temp
RUN apk update && \
apk add --no-cache ansible openssh openssh-client git && \
rm -rf /tmp/*

# Permit Root Login in SSHD Config and set to root:root
RUN  sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config \
  && echo "root:root" | chpasswd

# Specify entrypoint.sh as start script
ADD docker-entrypoint.sh /usr/local/bin

#make sure we get fresh keys
RUN rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key

# Setup Ansible Galaxy plugins in requirements.yml
COPY ./../requirements.yml /ansible/requirements.yml
RUN ansible-galaxy install -n -p /ansible/roles -r /ansible/requirements.yml --ignore-errors


EXPOSE 22
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["/usr/sbin/sshd","-D","-e"]