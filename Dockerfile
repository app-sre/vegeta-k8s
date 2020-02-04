FROM python:3.8.1-alpine3.11

ARG AWS_CLI_VERSION=1.17.9
ARG VEGETA_VERSION=12.7.0

RUN pip install --no-cache-dir awscli==$AWS_CLI_VERSION && \
    apk -uv add bash curl && \
    curl -L https://github.com/tsenart/vegeta/releases/download/v$VEGETA_VERSION/vegeta-$VEGETA_VERSION-linux-amd64.tar.gz | \
        tar -C /usr/local/bin -xzvf - vegeta && \
    apk del curl

ADD attack.sh /usr/local/bin

CMD attack.sh
