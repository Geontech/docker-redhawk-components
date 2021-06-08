FROM geontech/redhawk-ubuntu-development as builder

COPY ./rhSharedLibrary/root/core-framework/ /root/core-framework
RUN apt-get install -y git rpm && \
    ln -s bash /bin/sh.bash && \
    mv /bin/sh.bash /bin/sh && \
    cd /root/core-framework/redhawk/src && \
    export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/ && \
    sed -i "s/\$(BOOST_SYSTEM_LIB)/$\(BOOST_SYSTEM_LIB\) $\(BOOST_FILESYSTEM_LIB\) $\(OMNICOS_LIBS\) $\(CPPUNIT_LIBS\)/g" /root/core-framework/redhawk/src/control/sdr/ComponentHost/Makefile.am && \
    /bin/bash -lc "./build.sh distclean && ./build.sh" 
    
FROM geontech/redhawk-ubuntu-runtime as runner
WORKDIR /root/rpms
COPY --from=builder /root/core-framework /root/core-framework
RUN apt-get update && \
    apt-get install -y alien automake libtool libboost-filesystem-dev liblog4cxx-dev libboost-thread-dev libboost-regex-dev libcppunit-dev && \
    cd /root/core-framework/redhawk/src/control/sdr/ComponentHost && \
    /bin/bash -lc "make install" && \
    rm -rf /root/core-framework

# CMD ...run your sandboxed component
ENTRYPOINT ["/bin/bash", "-lc"]
