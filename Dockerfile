ARG BUILD_ENV=nocerts
FROM ubuntu:18.04 as os-update
MAINTAINER Robert Walker <rainbowseismic@gmail.com>

ENV BUILD_ENV=${BUILD_ENV}

RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y \
      g++ \
      git \
      make \
      cmake \
      cmake-gui \
      libxml2-dev \
      libfl-dev \
      python3-dev \
      python3-numpy \
      libqt4-dev \
      qtbase5-dev \
      libmysqlclient-dev \
      libpq-dev \
      libsqlite3-dev \
      ncurses-dev \
      flex \
      openmpi-common

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

RUN mkdir sc-build \
	&& cd sc-build \
	&& ccmake ${DEV_DIR} \
	&& make install


#RUN rm -fr /var/lib/apt /var/lib/dpkg /var/lib/cache /var/lib/log

WORKDIR $HOME

CMD /bin/bash
