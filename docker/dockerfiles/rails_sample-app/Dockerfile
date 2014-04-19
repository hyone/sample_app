FROM hyone/rbenv:2.1

RUN apt-get install -q -y \
      postgresql-common \
      postgresql-server-dev-9.1

ADD project/Gemfile /tmp/Gemfile
ADD project/Gemfile.lock /tmp/Gemfile.lock
RUN cd /tmp && eval "$(rbenv init -)" && bundle install --without development

# install app
ADD project /project
WORKDIR /project
RUN mv /tmp/.bundle .

## Command

ADD init.d/sample_app /etc/init.d/sample_app
ADD monit/sample_app  /etc/monit/conf.d/sample_app
ADD bootstrap.sh /project/bin/bootstrap.sh
RUN chmod +x /etc/init.d/sample_app ; \
    chmod +x /project/bin/bootstrap.sh ; \
    chown root:root /project/bin/bootstrap.sh

CMD ["/usr/bin/monit", "-I"]
