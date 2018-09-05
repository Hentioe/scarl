FROM debian:stretch


RUN apt-get update \
    && apt-get install openssl -y\
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/lib/apt/lists/partial/*


ARG APP_HOME=/home/pord


COPY _build/prod $APP_HOME
COPY scarl-prod.sqlite3 "$APP_HOME/rel/bot/scarl-prod.sqlite3"


WORKDIR $APP_HOME


ENV LANG=C.UTF-8
ENV PATH="$APP_HOME/rel/bot/bin:$PATH"


ENTRYPOINT [ "bot", "foreground" ]