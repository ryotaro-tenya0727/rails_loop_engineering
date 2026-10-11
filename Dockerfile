FROM ruby:3.4.11-slim

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends build-essential default-libmysqlclient-dev git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 3000

CMD ["bash", "-lc", "rm -f tmp/pids/server.pid && bundle exec rails db:prepare && bundle exec rails server -b 0.0.0.0"]
