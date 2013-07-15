#! /usr/bin/env bash

# Changing directories to your project and load rvm gemset
cd ~/code/mxkcd
source ~/.rvm/environments/ruby-2.0.0-p247-turbo@mxkcd

# call script via bundler
bundle exec ruby mxkcd.rb
