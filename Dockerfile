FROM debian:12 AS builder
# Install system dependencies
RUN apt-get update
RUN apt-get install -y build-essential libboost-system-dev libboost-thread-dev \
                       libexpat1-dev libmatheval-dev libconfig++-dev \
                       libboost-dev wget libdb5.3++-dev file libfl-dev libc6-dev \
                       libfann-dev libfann2

# Build Libiconv
RUN cd /usr/src && wget https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.16.tar.gz && tar -xvf libiconv-1.16.tar.gz
RUN cd /usr/src/libiconv-1.16 && ./configure --enable-static && make all install
RUN ldconfig

# Build the binaries
ADD src/ /usr/src/cbng-core
RUN cd /usr/src/cbng-core && make clean all

# Compile the databases
# Note: scratch doesn"t have a shell, so we can"t use `RUN` there
ADD data/ /usr/src/cbng-data
RUN /usr/src/cbng-core/create_bayes_db /usr/src/cbng-data/bayes.db /usr/src/cbng-data/main_bayes_train.dat
RUN /usr/src/cbng-core/create_bayes_db /usr/src/cbng-data/two_bayes.db /usr/src/cbng-data/two_bayes_train.dat

# Build a clean runtime image
FROM scratch

# Copy in the binary files
COPY --from=builder /usr/src/cbng-core/cluebotng /opt/cbng-core/cluebotng
COPY --from=builder /usr/src/cbng-core/create_ann /opt/cbng-core/create_ann
COPY --from=builder /usr/src/cbng-core/create_bayes_db /opt/cbng-core/create_bayes_db
COPY --from=builder /usr/src/cbng-core/print_bayes_db /opt/cbng-core/print_bayes_db

# Copy in the data files
COPY --from=builder /usr/src/cbng-data/bayes.db /opt/cbng-core/data/bayes.db
COPY --from=builder /usr/src/cbng-data/two_bayes.db /opt/cbng-core/data/two_bayes.db
ADD data/main_ann.fann /opt/cbng-core/data/main_ann.fann

# Config in the config files
ADD conf/ /opt/cbng-core/conf

# Run time settings
WORKDIR /opt/cbng-core
EXPOSE 3565

# Runtime
ENTRYPOINT ["/opt/cbng-core/cluebotng"]
