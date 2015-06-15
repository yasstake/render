FROM ubuntu:trusty

# for postgres
EXPOSE 5432

#for mapbox
EXPOSE 3000

#-- update ubuntu packages
RUN apt-get update && apt-get -y install python-software-properties && apt-get -y install software-properties-common && apt-get -y install golang
RUN apt-get -y install git && apt-get -y install wget && apt-get -y install unzip && apt-get -y install npm

#----  imposm   
RUN cd /tmp && \
    wget http://imposm.org/static/rel/http://imposm.org/static/rel/imposm3-0.1dev-20150515-593f252-linux-x86-64.tar.gz && \
    gzip -dc imposm3-0.1dev-20150515-593f252-linux-x86-64.tar.gz | tar xvf -  && \
    cd imposm3-0.1dev-20150515-593f252-linux-x86-64.tar.gz && \
    ls && \
    cp imposm3 /usr/local/	&&\
    cp -r lib/* /usr/local/lib

#-----    install java  ----------
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

WORKDIR /data
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

#---- install osmosis ----
RUN cd /tmp && wget http://bretth.dev.openstreetmap.org/osmosis-build/osmosis-latest.zip && cd /usr/local/ && unzip /tmp/osmosis-latest.zip


#---- postgis  -----
RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main universe" > /etc/apt/sources.list && apt-get -y update && wget --quiet --no-check-certificate -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" >> /etc/apt/sources.list && apt-get -y update && apt-get -y upgrade && locale-gen --no-purge en_US.UTF-8
ENV LC_ALL en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8
RUN apt-get -y install postgresql-9.3 postgresql-contrib-9.3 postgresql-9.3-postgis-2.1 postgis
RUN echo "host    all             all             0.0.0.0/0               md5" >> /etc/postgresql/9.3/main/pg_hba.conf
RUN service postgresql start && /bin/su postgres -c "createuser -d -s -r -l mapbox" && /bin/su postgres -c "psql postgres -c \"ALTER USER mapbox WITH ENCRYPTED PASSWORD 'mapbox'\"" && service postgresql stop
RUN echo "listen_addresses = '*'" >> /etc/postgresql/9.3/main/postgresql.conf
RUN echo "port = 5432" >> /etc/postgresql/9.3/main/postgresql.conf

#--- node js ----
RUN (cd /tmp && wget http://nodejs.org/dist/v0.10.36/node-v0.10.36-linux-x64.tar.gz && cd /usr/local && tar --strip-components 1 -xzf /tmp/node-v0.10.36-linux-x64.tar.gz)


#---- mapbox studio --
RUN cd /tmp && wget https://mapbox.s3.amazonaws.com/mapbox-studio/mapbox-studio-linux-x64-v0.2.7.zip && cd / && unzip /tmp/mapbox-studio-linux-x64-v0.2.7.zip




#--- mapbox util
RUN cd /tmp && wget https://raw.githubusercontent.com/mapbox/postgis-vt-util/master/lib.sql

ADD start.sh /start.sh
RUN chmod 0755 /start.sh

CMD ["/start.sh"]
#CMD ["bash"]

