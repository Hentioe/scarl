FROM debian:stretch


ARG APP_HOME=/home/pord


COPY _build/prod $APP_HOME


WORKDIR $APP_HOME

ENV LANG=C.UTF-8
ENV PATH="$APP_HOME/rel/bot/bin:$PATH"
ENV PORT=1055


EXPOSE $PORT


ENTRYPOINT [ "bot", "foreground" ]