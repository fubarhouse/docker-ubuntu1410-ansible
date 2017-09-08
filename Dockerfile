FROM ubuntu:14.10
MAINTAINER Karl Hepworth

# Convert sources to legacy.
RUN sed -i.bak -r 's/(archive|security).ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list

# Install dependencies.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       make git curl wget libssl-dev libffi-dev \
       rsyslog sudo build-essential gcc rsync openssh-server openssl \
       curl wget apt-transport-https \
    && rm -Rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean
RUN sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf
#ADD etc/rsyslog.d/50-default.conf /etc/rsyslog.d/50-default.conf

# Add Python PPA & Setup Python.
RUN apt-get update
RUN apt-get install -y software-properties-common python-software-properties
RUN add-apt-repository ppa:fkrull/deadsnakes-python2.7

RUN apt-get install -y --force-yes python2.7 python2.7-minimal \
    libpython2.7-stdlib libpython2.7-minimal libpython2.7 \
    libpython2.7-dev python2.7-dev python-pip python-yaml \
    python-paramiko python-jinja2 python-httplib2 python-setuptools

RUN pip install setuptools
RUN pip install pyopenssl==0.13.1 pyasn1 ndg-httpsclient

# Upgrade Python the hard way.
RUN wget https://www.python.org/ftp/python/2.7.13/Python-2.7.13.tgz \
    && tar xfz Python-2.7.13.tgz \
    && cd Python-2.7.13/ && ./configure --prefix /usr/local/lib/python2.7.13 --enable-ipv6 \
    && make \
    && make install \
    && echo 'export PATH="/usr/local/lib/python2.7.13/bin/:${PATH}"' >> /root/.profile

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