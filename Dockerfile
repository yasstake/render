FROM ubuntu

# for postgres
EXPOSE 5432

#for mapbox
EXPOSE 3000

#-- update ubuntu packages
RUN apt-get update
RUN apt-get -y install python-software-properties software-properties-common golang git wget unzip libboost-dev zlib1g-dev libshp-dev libgd2-xpm-dev  libgdal1-dev libexpat1-dev libgeos++-dev libprotobuf-dev libsparsehash-dev libv8-dev libicu-dev protobuf-compiler libosmpbf-dev cmake sqlite3 lbzip2 libzip2 libgdal-dev gdal-bin doxygen libbz2-dev build-essential graphviz libproj-dev

#--- osmium
RUN cd /tmp && git clone http://github.com/osmcode/libosmium && cd libosmium && mkdir build && cd build && cmake .. && make && make install

#--- osmcoastline
RUN cd /tmp && git clone https://github.com/joto/osmcoastline && cd osmcoastline && mkdir build && cd build && cmake .. && make install





#----  imposm   
RUN cd /tmp && \
    wget http://imposm.org/static/rel/imposm3-0.1dev-20150515-593f252-linux-x86-64.tar.gz && \
    gzip -dc imposm3-0.1dev-20150515-593f252-linux-x86-64.tar.gz | tar xvf -  && \
    cd imposm3-0.1dev-20150515-593f252-linux-x86-64 && \
    cp imposm3 /usr/local/	&&\
    cp -r lib/* /usr/local/lib


#---- install osmosis ----
RUN cd /tmp && wget http://bretth.dev.openstreetmap.org/osmosis-build/osmosis-latest.zip && cd /usr/local/ && unzip /tmp/osmosis-latest.zip


#--- node js ----
RUN (cd /tmp && wget http://nodejs.org/dist/v0.10.36/node-v0.10.36-linux-x64.tar.gz && cd /usr/local && tar --strip-components 1 -xzf /tmp/node-v0.10.36-linux-x64.tar.gz)

#---- mapbox studio --
RUN cd /tmp && wget https://mapbox.s3.amazonaws.com/mapbox-studio/mapbox-studio-linux-x64-v0.2.7.zip && unzip /tmp/mapbox-studio-linux-x64-v0.2.7.zip && mv /tmp/mapbox-studio-linux-x64-v0.2.7 /mapbox

#--- mapbox util
RUN cd /tmp && wget https://raw.githubusercontent.com/mapbox/postgis-vt-util/master/lib.sql
#--- 

#--- project
RUN mkdir /project && cd /project && git clone https://github.com/yasstake/render

ADD start.sh /start.sh
RUN chmod 0755 /start.sh

#---- postgis  -----
#RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
#RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list

RUN apt-get -y install postgresql postgresql-contrib postgis
RUN echo "host    all             all             0.0.0.0/0               md5" >> /etc/postgresql/9.3/main/pg_hba.conf
RUN echo "listen_addresses = '*'" >> /etc/postgresql/9.3/main/postgresql.conf
RUN echo "port = 5432" >> /etc/postgresql/9.3/main/postgresql.conf

#RUN service postgresql start && sudo -u postgres "createuser -d -s -r -l mapbox" && sudo -u postgres "psql postgres -c \"ALTER USER mapbox WITH ENCRYPTED PASSWORD 'mapbox'\"" && service postgresql stop

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



CMD ["/start.sh"]
#CMD ["bash"]

