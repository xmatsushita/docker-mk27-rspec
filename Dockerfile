FROM ruby:2.7.2-alpine as builder
ENV WORK_DIR=/root

WORKDIR $WORK_DIR
ADD ./Gemfile $WORK_DIR/Gemfile
ADD ./Gemfile.lock $WORK_DIR/Gemfile.lock
RUN apk update && apk upgrade
RUN apk add --update --no-cache --virtual=.build-dependencies \
  curl-dev \
  linux-headers \
  libxml2-dev \
  libxslt-dev \
  ruby-dev \
  yaml-dev \
  zlib-dev \
  mysql-dev \
  build-base \
  && apk add --update --no-cache \
  bash \
  git \
  openssh \
  openssl \
  ruby-json \
  mysql-client \
  mariadb-dev \
  tzdata \
  yaml \
  && gem install bundler:2.2.12 \
  && bundle install -j4 \
  && apk del .build-dependencies

# Service
FROM ruby:2.7.2-alpine

ENV LANG C.UTF-8
ENV TZ=Asia/Tokyo
ENV APP_ROOT=/srv/app

RUN mkdir -p $APP_ROOT
WORKDIR $APP_ROOT
ADD . $APP_ROOT

RUN apk add --update --no-cache \
  bash \
  git \
  openssh \
  openssl \
  ruby-json \
  mysql-client \
  mariadb-dev \
  redis \
  tzdata \
  yaml \
  less \
  && gem install bundler:2.2.12

COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /usr/local/bin /usr/local/bin

CMD ["/bin/sh"]
