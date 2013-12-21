#! /usr/bin/env bash

# Changing directories to your project and load rvm gemset
cd /srv/cron/mxkcd
source /usr/local/rvm/environments/ruby-2.0.0-p353-turbo@mxkcd

# call script via bundler
bundle exec ruby mxkcd.rb
