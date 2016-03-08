# Le Clash Stats
> Prototype showcase for some basic API operations, and web app creation stuff.

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
3. Fetch rankigns with rake task `rake api:fetch_rankings['token']`
4. Start server with `rails s` command and navigate to `http://localhost:3000`

## Deployment

* Preferred way of deployment is to deploy to Heroku with a MLab Sandbox instance for free MongoDB storage
* DB can be populated by using `RAILS_ENV=production rake api:...`
