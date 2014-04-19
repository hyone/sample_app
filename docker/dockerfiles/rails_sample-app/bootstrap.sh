#!/bin/sh

export HOME='/project'
export RBENV_ROOT='/usr/local/rbenv'
export PATH="${RBENV_ROOT}/bin:${PATH}"

LOGFILE="${HOME}/log/foreman.log"

cd /project
touch ${LOGFILE}
eval "$(rbenv init -)"
bundle exec rake 'db:create'
bundle exec rake 'db:migrate'
bundle exec rake 'test:prepare'
bundle exec foreman start >>${LOGFILE} 2>&1
