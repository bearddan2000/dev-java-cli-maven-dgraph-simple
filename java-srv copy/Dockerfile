FROM maven:3-openjdk-17

WORKDIR /usr/src/mymaven

COPY bin .

ENV WAIT_VERSION 2.7.2

ADD https://github.com/ufoscout/docker-compose-wait/releases/download/$WAIT_VERSION/wait /wait

RUN chmod +x /wait

CMD "mvn clean compile exec:java"
