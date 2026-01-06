FROM ruby:3.4.8-alpine3.23
LABEL com.puvvadi.image.authors="kd@puvvadi.me"
LABEL version="4.30"

ENV TZ=Asia/Kolkata

RUN apk --no-cache upgrade --purge
RUN apk --no-cache add build-base git

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 4000

ENTRYPOINT ["bundle", "exec", "jekyll", "serve", "--host", "0.0.0.0"]
