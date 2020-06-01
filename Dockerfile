FROM ruby:2.5

RUN apt-get update -y && apt-get install -y --no-install-recommends \
  default-jre \
  default-mysql-client \
  libprotobuf-dev \
  protobuf-compiler

COPY Gemfile* /usr/src/app/
WORKDIR /usr/src/app

ENV BUNDLE_PATH /gems

RUN bundle install

COPY . /usr/src/app/

#ENTRYPOINT ["./docker-entrypoint.sh"]
#CMD ["bin/rails", "s", "-b", "0.0.0.0"]
