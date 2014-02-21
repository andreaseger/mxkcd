#! /usr/bin/env bash

# Changing directories to your project and load rvm gemset
export PATH="/home/sch1zo/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
cd /srv/cron/mxkcd

#call script via bundler
bundle exec ruby mxkcd.rb
