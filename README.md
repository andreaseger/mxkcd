[@mxkcd](https://twitter.com/mxkcd)
=====

xkcd rss to twitter bot optimized for mobile

- picks the official [xkcd rss](http://xkcd.com/rss.xml)
- converts the link to the mobile version, i.e. adds the `m` subdomain
- extracts the image source from the description
- posts all of these as one tidy tweet

auth
---

at the moment just use the gem [t](https://github.com/sferik/t) with `t authorize`
and copy the resulting token/secret from `~/.trc` into `config/auth.yml`

cron
---

add something like this to your contab

```
0,1,5,30,55 3-7 * * 1,3,5 ruby /path/to/mxkcd.rb >> /var/log/mxkcd.log
```

if you use rvm you can use a wrapper like this

``` sh
#! /usr/bin/env bash

# Changing directories to your project and load rvm gemset
cd /path/to/mxkcd
source ~/.rvm/environments/ruby-2.0.0-p247-turbo@mxkcd

# call script via bundler
bundle exec ruby mxkcd.rb
```


Contributing
---

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

