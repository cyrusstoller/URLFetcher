URL Fetcher
=========

## How does this work?

This Rails application fetches the content from user-supplied URLs. The service is accessible via a REST API.

After a POST request is issued to the Rails application to create a new `content` record, its `id` is placed in a queue, until a worker fetches the content of the url provided by the user.

After the content has been fetched a POST request will be issued to the `callback_url` if it has been provided.

### Scaling
If the traffic demands it, you can easily increase the number of rails servers and/or the number of resque workers, since this application uses foreman.

On Heroku, you would do this with a command like `$ heroku ps:scale worker=4`. Each server is treated modularly, so they can be swapped in and out if they misbehave.

This application should have no issue handling access from multiple clients.

### Trusting the client

This application effectively only has one user, the admin, authenticated through HTTP Basic Authentication. Unless a user has the admin username and password, they will not have access to this application at all. This will hopefully keep out malicious users.

## Setting up your development/test environment

### Set .env

Create a `.env` file to add configurations that you don't want to be stored in your github repo.

```
ADMIN_USER=YYYYYY
ADMIN_PASSWORD=XXXXXX
```

Or on Heroku you can do something like `heroku config:add ADMIN_USER=YYYYYY ADMIN_PASSWORD=XXXXXX`

### Redis

If you don't have Redis installed you can do that easily with [homebrew](http://mxcl.github.com/homebrew/).

```
$ brew install redis
```

## Starting up the application

```
$ bundle install
$ rake db:create # first time only
$ rake db:migrate # only if you updated the database
$ redis-server /usr/local/etc/redis.conf # probably best to do in a separate terminal window
$ foreman start
$ bundle exec autotest
```

## Deploying on Heroku

You'll need to change your host so that callbacks will provide the appropriate url. Change the url in `config/config.yml`.

### Setting up your application

```
$ heroku create --stack cedar
$ git push heroku master
$ heroku run rake db:create
$ heroku run rake db:migrate
$ heroku ps:scale worker=2 # for two workers
```

### Updating your application

```
$ git push heroku master
$ heroku run rake db:migrate # only if you updated the database
```

## Settings

Currently this application will follow up to a maximum of 5 redirects. You can change the maximum number of tolerable redirects in `config/config.yml`.