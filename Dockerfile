FROM mongo:3.6.1

ENV TZ=Australia/Melbourne

COPY ./ /

RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -y tzdata && \
    chmod +x /*.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/run.sh"]
