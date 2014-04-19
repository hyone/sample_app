#!/bin/sh

cd /project
eval "$(rbenv init -)"
touch /var/log/sample_app
bundle exec foreman start >> /var/log/sample_app
