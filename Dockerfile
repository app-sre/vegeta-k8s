FROM registry.access.redhat.com/ubi8/python-36

ARG AWS_CLI_VERSION=1.17.9
ARG VEGETA_VERSION=12.8.3

RUN pip install --no-cache-dir awscli==$AWS_CLI_VERSION && \
    curl -L https://github.com/tsenart/vegeta/releases/download/v$VEGETA_VERSION/vegeta-$VEGETA_VERSION-linux-amd64.tar.gz | \
        tar -C /opt/app-root/bin -xzvf - vegeta

ADD attack.sh /opt/app-root/bin

CMD attack.sh
