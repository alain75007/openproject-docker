#FROM ruby:2.1-wheezy
FROM debian:jessie
#FROM ubuntu:trusty
MAINTAINER Alain Beauvois alain@questioncode.fr

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -q
RUN apt-get install -y --force-yes supervisor  cron locales wget curl procps net-tools

RUN locale-gen en_US en_US.UTF-8 fr_FR fr_FR.UTF-8

# install https support 
RUN apt-get install -y --force-yes apt-transport-https
RUN apt-get install -y --force-yes openssh-server 
EXPOSE 22
EXPOSE 8080


#RUN wget -qO - https://deb.packager.io/key | apt-key add -
#RUN echo "deb https://deb.packager.io/gh/opf/openproject jessie stable/4.1" | tee /etc/apt/sources.list.d/openproject.list
#RUN apt-get -q update
#RUN apt-get -q -y install openproject*=4.1.0-1432220703.c001492.jessie

RUN locale-gen en_US en_US.UTF-8

#RUN apt-get install -y --force-yes build-essential curl git zlib1g-dev libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt-dev libxslt1-dev libmysqlclient-dev libpq-dev libsqlite3-dev libyaml-0-2 libmagickwand-dev libmagickcore-dev libgraphviz-dev ruby-dev

RUN apt-get install -y --force-yes git curl build-essential zlib1g-dev libyaml-dev libssl-dev libmysqlclient-dev libpq-dev memcached 

# Install utilities
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7

# Add HTTPS support for APT. Passengers APT repository is stored on an HTTPS server.
RUN apt-get install -q -y --force-yes apt-transport-https ca-certificates
#RUN echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main' > /etc/apt/sources.list.d/passenger.list
#RUN echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger wheezy main' > /etc/apt/sources.list.d/passenger.list
RUN echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger jessie main' > /etc/apt/sources.list.d/passenger.list
RUN chown root: /etc/apt/sources.list.d/passenger.list
RUN chmod 600 /etc/apt/sources.list.d/passenger.list
RUN apt-get update -q
RUN apt-get install -q -y --force-yes memcached subversion vim wget python-setuptools openssh-server sudo pwgen libcurl4-openssl-dev passenger
RUN easy_install supervisor
#RUN mkdir /var/log/supervisor/

# see: http://flnkr.com/2013/12/creating-a-docker-ubuntu-13-10-image-with-openssh/
RUN mkdir /var/run/sshd
RUN /usr/sbin/sshd
RUN sed -i 's/.*session.*required.*pam_loginuid.so.*/session optional pam_loginuid.so/g' /etc/pam.d/sshd
RUN /bin/echo -e "LANG=\"en_US.UTF-8\"" > /etc/default/local

#
# Install MySQL
#
# RUN apt-get -y --force-yes -q install postgresql postgresql-client postgresql-contrib
RUN apt-get install -y --force-yes -q mysql-client mysql-server


#RUN apt-get install nodejs # for execjs
RUN curl -sL https://deb.nodesource.com/setup | bash -
RUN apt-get install -y nodejs
RUN apt-get clean
RUN npm -g install bower


#
# Setup OpenProject
#
ENV CONFIGURE_OPTS --disable-install-doc
ADD ./files/Gemfile.local /Gemfile.local
ADD ./files/Gemfile.plugins /Gemfile.plugins
ADD ./files/setup_system.sh /setup_system.sh
RUN /bin/bash /setup_system.sh
RUN rm /setup_system.sh
ENV PATH /home/openproject/.rbenv/bin:$PATH
ADD ./files/passenger-standalone.json /home/openproject/openproject/passenger-standalone.json
ADD ./files/start_openproject.sh /home/openproject/start_openproject.sh
ADD ./files/start_openproject_worker.sh /home/openproject/start_openproject_worker.sh

ADD ./files/supervisord.conf /etc/supervisord.conf

#ENV RAILS_ENV production
RUN touch /var/run/supervisor.sock
RUN chmod 777 /var/run/supervisor.sock
#RUN service supervisor restart
ENTRYPOINT ["supervisord", "-n"]
RUN echo "INFO: openproject ssh password: `cat /root/openproject-root-pw.txt`"
