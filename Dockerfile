FROM ubuntu:14.10
MAINTAINER Karl Hepworth

# Convert sources to legacy.
RUN sed -i.bak -r 's/(archive|security).ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list

# Add Python PPA
RUN add-apt-repository ppa:fkrull/deadsnakes-python2.7

# Install dependencies.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       python-pip make git curl wget \
       python python-yaml python-paramiko python-jinja2 python-httplib2 \
       python-software-properties software-properties-common \
       rsyslog sudo build-essential gcc rsync openssh-server openssl \
       python-dev python-setuptools libssl-dev libffi-dev \
       curl wget apt-transport-https \
    && rm -Rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean
RUN pip install setuptools
RUN pip install pyopenssl==0.13.1 pyasn1 ndg-httpsclient
RUN sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf
#ADD etc/rsyslog.d/50-default.conf /etc/rsyslog.d/50-default.conf

# On the Utopic Unicorn we actually need a later version of python...
RUN apt-get update
RUN apt-get build-dep -y python2.7
RUN apt-get install python2.7
RUN apt-get clean

# Install Ansible
RUN pip install urllib3 cryptography
RUN pip install --upgrade pip virtualenv virtualenvwrapper
RUN pip install ansible==2.3

COPY initctl_faker .
RUN chmod +x initctl_faker && rm -fr /sbin/initctl && ln -s /initctl_faker /sbin/initctl

# Install Ansible inventory file
RUN mkdir /etc/ansible
RUN echo "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

# Report some information
RUN python --version
RUN ansible --version