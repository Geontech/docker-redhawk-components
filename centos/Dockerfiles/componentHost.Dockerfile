FROM geontech/redhawk-development as builder

COPY ./rhSharedLibrary/root/core-framework/ /root/core-framework
WORKDIR /root/core-framework/redhawk/src
RUN yum install -y git rpm-build automake gstreamer-python libuuid-devel boost-devel cppunit-devel autoconf automake libtool expat-devel gcc-c++ java-1.8.0-openjdk-devel python-devel python-matplotlib-qt4 numpy PyQt4 log4cxx log4cxx-devel omniORB omniORB-devel omniORB-doc omniORB-servers omniORB-utils python-jinja2 xsd libsqlite3x libsqlite3x-devel && \
    /bin/bash -lc "./build.sh" 
    
FROM geontech/redhawk-runtime as runner
WORKDIR /root/rpms
COPY --from=builder /root/core-framework /root/core-framework
WORKDIR /etc/redhawk/logging
COPY /root/core-framework/redhawk/src/testing/sdr/dom/mgr/logging.properties /etc/redhawk/logging
COPY /root/core-framework/redhawk/src/testing/sdr/dom/mgr/logrotate.redhawk /etc/redhawk/logging
WORKDIR /root/rpms
RUN yum install -y automake libtool gcc-c++ boost-devel libuuid-devel numactl-devel log4cxx-devel && \
    cd  /root/core-framework/redhawk/src/base/framework && \
    /bin/bash -lc "make install" && \
    cd /root/core-framework/redhawk/src/base/framework/idl && \
    /bin/bash -lc "make install" && \
    cd /root/core-framework/redhawk/src/control/sdr/ComponentHost && \
    /bin/bash -lc "make install"

# CMD ...run your sandboxed component
ENTRYPOINT ["/bin/bash", "-lc"]
