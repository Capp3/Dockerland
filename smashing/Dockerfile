FROM ruby:2.6
RUN mkdir /smashing

RUN apt-get update && \
    apt-get upgrade -yq && \
    apt-get install -yq nodejs

COPY Gemfile /smashing/Gemfile
WORKDIR /smashing

RUN bundle install --jobs 80
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3030

CMD ["smashing", "start", "-p", "3030"]