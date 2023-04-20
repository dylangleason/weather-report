# Weather Report

Weather Report is a simple weather reporting and forecasting
application, written using Ruby on Rails.

## Prerequisites

This project was created using Ruby 3.0.5 and also utilizes Redis for
caching, so ensure that you have that installed before proceeding if
running from your host environment. Alternatively, you can install the
project using the provided `Dockerfile` and associated scripts
(recommended).

## Environment

This project utilizes data from
[OpenWeather](https://openweathermap.org/api) APIs. Make sure to
export your `OPENWEATHER_API_KEY` to your environment prior to running
the web server, either via Docker or on your host.

## Running the Dev Server

Run the following scripts at your terminal to build and run the
application.

```command
./bin/docker-run
```

You can also clean up resources Docker created when done:

```command
./bin/docker-destroy
```

## Running the Tests

Tests can be run, also via Docker:

```command
docker run -it --rm weather-report bundle exec rake test
```

## Architecture

The weather report uses a very simple layered architecture and uses
the Model-View-Controller (MVC) pattern. However, note that the data
model does not utilize a relational or persistent datastore; instead
we rely on an external service called OpenWeather and store our data
temporarily in cache.

## Services

### OpenWeather

OpenWeather is an external service that we query via a REST API to
fetch weather data for the specified location.

### Redis

Redis is used as a cache to store data temporarily to avoid repeated
lookups to the OpenWeather service. Cache keys are a unique zipcode
with a TTL of 30 minutes.

## Approach

- Due to the UI requirement, and to keep things simple, I elected to
  render views via a Rails `Base` Controller, rather than defining a
  web API using the `API` Controller and writing a separate client app
  (e.g. using React).
- However, I encapsulated domain models and business logic in the as
  services classes in the `lib` directory in order to limit coupling
  with Rails infrastructure. By doing so, we can reuse domain logic in
  the context of a web API more easily in the future, and it also
  makes our domain services easier to test.
- I chose to implement caching response data to OpenWeather queries
  rather than caching pages or view fragments, but the latter is
  possible since we don't require any request filters. I chose not to
  go this route, though, since this strategy could change if using an
  API controller.

## Areas of Improvement

Here are a few areas that could use improvement, but I did not
implement due to lack of time.

- Spend more time on error handling when OpenWeather or their related
  Geocoder service is down or rate limited.
- I used some prebuilt components using Bulma CSS to build a very
  simple / rudimentary UI. This could definitely be improved with
  input validation and other error handling, better animations, icons,
  etc. My frontend skills are a bit limited...
- Consider configuring autoload or eager load paths to clean up
  inclusion of `lib` directory services.
- I focused on writing unit tests for the business logic, but I didn't
  have enough time to figure out a way to write high-value tests for
  controllers, as those would require patching in order to mock
  infrastructure rather than using dependency injection. I figured the
  value there was limited from a testing standpoint relative to
  testing the feature end-to-end via the web interface. Some postman
  tests could also be useful for testing the one API request.
- Explore using the Rails / Redis cache integration via `Rails.cache`
  rather than using a custom singleton. I wasn't quite sure how to use
  this as it seemed to use a different API from `Redis`, and wasn't
  sure how to test as I was using `Miniredis`. I believe the Rails
  version handles connection pooling which is an important
  consideration when scaling in a production environment. The basic
  Redis client does not manage connection pooling.
