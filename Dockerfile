FROM redis:3.2

MAINTAINER Johan Andersson <Grokzen@gmail.com>

# Some Environment Variables
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -yqq \
      net-tools supervisor ruby rubygems locales gettext-base && \
    apt-get clean -yqq

# # Ensure UTF-8 lang and locale
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

RUN gem install redis

RUN apt-get install -y gcc make g++ build-essential libc6-dev tcl git supervisor ruby pwgen

ARG redis_version=3.2.1

RUN wget -qO redis.tar.gz http://download.redis.io/releases/redis-${redis_version}.tar.gz \
    && tar xfz redis.tar.gz -C / \
    && mv /redis-$redis_version /redis

RUN (cd /redis && make)

RUN mkdir /redis-conf
RUN mkdir /redis-data
RUN mkdir /etc/redis
#COPY ./docker-data/redis-cluster.tmpl /redis-conf/redis-cluster.tmpl
#COPY ./docker-data/redis.tmpl /redis-conf/redis.tmpl

# Add supervisord configuration
#COPY ./docker-data/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Add startup script
#COPY ./docker-data/docker-entrypoint.sh /docker-entrypoint.sh
ADD run.sh /run.sh
ADD cluster.sh /cluster.sh
RUN chmod 755 /*.sh
#ENV REDIS_PASS **Random**
ENV REDIS_PASS 123456
VOLUME ["/data"]
#EXPOSE 7000 7001 7002 7003 7004 7005 7006 7007
EXPOSE 6379

COPY client.rb /var/lib/gems/2.1.0/gems/redis-3.3.3/lib/redis/client.rb

#ENTRYPOINT ["/docker-entrypoint.sh"]
#CMD ["redis-cluster"]
CMD ["/run.sh"]
