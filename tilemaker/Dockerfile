FROM ubuntu

RUN apt-get update
RUN apt-get install -y build-essential liblua5.1-0 liblua5.1-0-dev libprotobuf-dev libsqlite3-dev protobuf-compiler shapelib libshp-dev software-properties-common git gcc wget unzip emacs

RUN add-apt-repository ppa:ostogvin/tjo-develop
RUN apt-get update
RUN apt-get install -y libboost1.58-all-dev


RUN git clone https://github.com/rpavlik/luabind.git
RUN (cd luabind && ln -s /usr/lib/x86_64-linux-gnu/liblua5.1.so /usr/lib/ && bjam install)
RUN ln -s /usr/local/lib/libluabindd.so /usr/local/lib/libluabind.so
RUN sudo ldconfig

RUN (cd /tmp && wget https://github.com/systemed/tilemaker/archive/v1.2.0.zip && unzip v1.2.0.zip && cd /tmp/tilemaker-1.2.0 && make && make install)


