FROM ruby:3.0.5

RUN gem install bundler:2.4.1
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 3000/tcp

CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]
