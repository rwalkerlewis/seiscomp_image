ARG BUILD_ENV=nocerts
FROM ubuntu:20.04 as os-update
MAINTAINER Robert Walker <rainbowseismic@gmail.com>

ENV BUILD_ENV=${BUILD_ENV}

RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y \
      g++ \
      gfortran \
      git \
      make \
      cmake \
      cmake-gui \
      libxml2-dev \
      libfl-dev \
      python3-dev \
      python3-numpy \
      qtbase5-dev \
      libmysqlclient-dev \
      libpq-dev \
      libsqlite3-dev \
      ncurses-dev \
      flex \
      openmpi-common \
      sudo \
      man \
      libboost-all-dev \
      libqt5svg5-dev \
      cmake-curses-gui \
      libssl-dev \
      wget \
      libgpm2 \
      libmariadb3 \
      libtinfo5 \
      libncurses5 \
      mariadb-common \
      galera-3 \
      gawk \
      iproute2 libaio1 libatm1 libcap2-bin libcgi-fast-perl \
	  libcgi-pm-perl libconfig-inifiles-perl libdbd-mysql-perl libdbi-perl \
  libencode-locale-perl libfcgi-perl libhtml-parser-perl libhtml-tagset-perl \
  libhtml-template-perl libhttp-date-perl libhttp-message-perl libio-html-perl \
  liblwp-mediatypes-perl libmnl0 libpam-cap libpopt0 libreadline5 libsnappy1v5 \
  libterm-readkey-perl libtimedate-perl liburi-perl libwrap0 libxtables12 lsof \
  mariadb-client mariadb-client-10.3 mariadb-client-core-10.3 mariadb-server \
  mariadb-server-10.3 mariadb-server-core-10.3 psmisc rsync socat \
  python3-attr python3-automat python3-cffi-backend python3-click \
  python3-colorama python3-constantly python3-cryptography python3-dateutil \
  python3-hamcrest python3-hyperlink python3-idna python3-incremental \
  python3-openssl python3-pyasn1 python3-pyasn1-modules \
  python3-service-identity python3-six python3-twisted python3-twisted-bin \
  python3-zope.interface \
  screen



# # --------------------------------------------------------------------------- 80

FROM os-update as build-certs-doi

ONBUILD COPY docker/certs/ /usr/local/share/ca-certificates
ONBUILD RUN update-ca-certificates
ONBUILD ENV CERT_PATH=/etc/ssl/certs CERT_FILE=DOIRootCA2.pem

FROM os-update as build-nocerts
ONBUILD ENV CERT_PATH=no  CERT_FILE=no

# --------------------------------------------------------------------------- 80
FROM build-${BUILD_ENV} as build-deps
ARG user=seiscomp_user
ARG uid
ARG gid
# Create 'seiscomp-user' user
ENV SEISCOMP_USER=${user}
ENV SEISCOMP_DIR=seiscomp-user
ENV DEV_DIR=/opt/seiscomp \
	BASE_DIR=/opt \
	BUILD_DIR=/home/seiscomp \
	SEISCOMP=seiscomp \
	HOME=/home/${SEISCOMP_DIR} \
	PATH_ORIG=${PATH}

# Create seiscomp-user
RUN useradd -m $SEISCOMP_USER \
  && echo "${SEISCOMP_USER}:${SEISCOMP_USER}" | chpasswd \
  && adduser ${SEISCOMP_USER} sudo \
  && usermod --shell /bin/bash ${SEISCOMP_USER} \
  && usermod --uid ${uid} ${SEISCOMP_USER} \
  && groupmod --gid ${gid} ${SEISCOMP_USER}
RUN mkdir $DEV_DIR \
  && chown $SEISCOMP_USER $DEV_DIR \
  && chgrp $SEISCOMP_USER $DEV_DIR \
  && mkdir -p $BUILD_DIR/build \
  && chown -R $SEISCOMP_USER $BUILD_DIR \
  && chgrp -R $SEISCOMP_USER $BUILD_DIR

# Create sysop
RUN adduser sysop \
	&& addgroup admin \
	&& usermod -a -G admin,adm,audio sysop

# --------------------------------------------------------------------------- 80
# Collect SeisComp Source
USER ${SEISCOMP_USER}
WORKDIR ${BASE_DIR}
# Set variables for build
ENV REPO_PATH=https://github.com/SeisComP

RUN echo "Cloning base repository into ${DEV_DIR}" \
	&& git clone ${REPO_PATH}/seiscomp.git ${DEV_DIR} \
	&& echo 'Cloning base components' \
	&& cd ${DEV_DIR}/src/base \
	&& git clone $REPO_PATH/seedlink.git \
	&& git clone $REPO_PATH/common.git \
	&& git clone $REPO_PATH/main.git \
	&& git clone $REPO_PATH/extras.git \
	&& echo "Cloning external base components" \
	&& git clone $REPO_PATH/contrib-gns.git \
	&& git clone $REPO_PATH/contrib-ipgp.git \
	&& git clone https://github.com/swiss-seismological-service/sed-SeisComP-contributions.git contrib-sed \
	&& echo "Done" \ 
	&& cd ../../

# --------------------------------------------------------------------------- 80
# Build Seiscomp
USER ${SEISCOMP_USER}
WORKDIR ${BUILD_DIR}

RUN cd ${BUILD_DIR} \
	&& mkdir -p build \
	&& cd build \
	&& cmake -DCMAKE_INSTALL_PREFIX=${BUILD_DIR} ${DEV_DIR} \
	&& make install


#RUN rm -fr /var/lib/apt /var/lib/dpkg /var/lib/cache /var/lib/log


# --------------------------------------------------------------------------- 80
# Build Environment

USER ${SEISCOMP_USER}
WORKDIR ${BUILD_DIR}

#ZRUN ./bin/seiscomp print env  > ~/.bashrc 


# --------------------------------------------------------------------------- 80
# Build Database
USER ${SEISCOMP_USER}
WORKDIR ${HOME}
ENV SQLPWD=Password

#RUN ./bin/seiscomp install-deps base mariadb-server gui \
#	&& /etc/init.d/mysql start 
#	&& mysql -e "SET old_passwords=0; ALTER USER root@localhost IDENTIFIED BY '${SQLPWD}'; FLUSH PRIVILEGES;" 
	


CMD /bin/bash
