FROM ubuntu:15.04

RUN apt-get update
RUN apt-get install -q -y	\
    git     	       	  	\
    ruby-dev			\
    rubygems			\
    libsqlite3-dev 		\
    build-essential		\
    libcurl4-openssl-dev	\
    libpq-dev			\
    libxslt-dev			\
    libxml2-dev

RUN gem install			\
    bundler			\
    foreman

ENV RACK_ENV "production"
ENV STRINGER_DATABASE "stringerdb" 

RUN git clone https://github.com/swanson/stringer.git
WORKDIR /stringer

RUN sed -i 's/^ruby "2.0.0"/ruby "2.1.2"/' Gemfile
RUN sed -i 's/^console/#console/' Procfile

RUN bundle install

ADD database.yml config/database.yml
RUN mkdir /db
ENV REFRESH_RATE 1800

CMD ((sleep 10 ; while [ true ]; do bundle exec rake fetch_feeds; sleep $REFRESH_RATE; done) & rake db:migrate RACK_ENV=production && foreman start)
