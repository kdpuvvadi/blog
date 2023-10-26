FROM ruby:alpine
LABEL com.puvvadi.image.authors="kd@puvvadi.me"
LABEL version="1.0"

ENV TZ Asia/Kolkata

RUN apk --no-cache upgrade --purge
RUN apk --no-cache add build-base git

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 4000

CMD ["bundle", "exec", "jekyll", "serve", "--incremental", "--host", "0.0.0.0"]
