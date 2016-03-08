# Le Clash Stats
> Prototype showcase for some basic API operations, and web app creation stuff.

![Alt text](/lcs-screenshot.jpg?raw=true "Screenshot")

## Major dependencies
* Rails 4
* MongoDB and Mongoid ORM
* Slim templating engine
* REST Client for API ops
* Materialize CSS for material design conformant styles
* Actionpack page caching gem for page caching
* Puma web server for faster concurrent serving

## Setup

1. Get Clash of Clans API keys from
2. Fetch locations with rake task `rake api:fetch_location['token']`
3. Fetch rankigns with rake task `rake api:fetch_ranks['token']`
4. Create secret and have it in you ENV variable with `rake secret`
4. Start server with `rails s` command and navigate to `http://localhost:3000`
5. If you are testing perf locally, remember to run asset precompile task `RAILS_ENV=production bin/rake assets:precompile` and run Puma server in production environment `rails s -e production` with enough threads and workers

## Deployment

* Preferred way of deployment is to deploy to Heroku with a MLab Sandbox instance for free MongoDB storage
* DB can be populated by using `RAILS_ENV=production rake api:...`

# Performance
* Since the content only updates once an hour, page caching can be used – using Actionpack page caching gem for this
* Also Mongoid query caching is being used
* To test the perf you can use `ab -n 15000 -c 100 -l -k http://localhost:3000/`
