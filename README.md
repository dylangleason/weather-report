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

A `docker-compose.yml` file has been included to make running the dev
services as easy as possible:

```command
docker-compose up -d
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
  render the main view via a Rails `Base` Controller, rather than
  defining a web API using the `API` Controller and writing a separate
  client app (e.g. using React).
- I encapsulated domain models and business logic as a service class
  in the `lib` directory, in order to limit coupling with Rails
  infrastructure. By doing so, we can reuse domain logic in the
  context of a web API more easily in the future, and it also makes
  our domain services easier to test.
- I chose to cache response data to OpenWeather queries rather than
  caching pages or view fragments, but the latter is possible since we
  don't require any request filters. I chose not to go this route,
  though, since this strategy could change if using an API controller.

## Areas of Improvement

Here are a few areas that could use improvement, but I did not
implement due to lack of time.

- Improve error handling on the backend. I added stubs for custom
  error handler methods using `rescue_from` but did not implement
  them. This could provide more useful error reporting for client
  apps.
- Support search for a full or partial address in the input, rather
  than just a zipcode. This would likely require use of another
  third-party API.
- I used some prebuilt components using Bulma CSS to build a very
  simple, but rudimentary UI. This could definitely be improved upon
  by implementing input validation and other error handling, better
  animations, icons, etc.
- I was really struggling to understand how autoloading worked in
  Rails 7. I first added my code to `lib`, then I moved my files to
  `app/lib` after reading that this was the recommend practice.
  Despite doing so, I could not at all get Rails to resolve my module
  or class names and just encountered `NameError`. It's been a few
  years since I've worked in Rails, and I see autoloading hasn't
  gotten any easier...
- Add integration or end-to-end tests. I focused mostly on writing
  unit tests for the `WeatherService`, which was straightforward to do
  as I used dependency injection to mock out dependencies to
  infrastructure. A controller test would probably be well suited
  toward an end-to-end test, but would require using Minitest stubs
  rather than dependency injection. Using fake services that more
  closely resemble the Weather APIs might also make this more robust.
- Configure connection pools for Redis using the builtin Rails cache
  wrapper. I wasn't quite sure how to use this as it seemed to use a
  different API than `Redis` or `Miniredis`, which made it unclear how
  to mock or stub in a test environment. The basic Redis client does
  not manage connection pooling, but there is a
  [connection_pool](https://github.com/mperham/connection_pool)
  library that wraps the underlying functionality, which may also be
  worth exploring.
- Similar to Redis connection pools, implement a persistent HTTP
  client and use a singleton instance in the application to improve
  HTTP request performance. It seems there is a library that follows
  the `Net::HTTP` API closely that supports persistent connections
  [here](https://github.com/drbrain/net-http-persistent).
- ~~Add a `docker-compose.yml` file to orchestrate Docker local
  development scripts more cleanly. Support hot reloading in the
  `Dockerfile` to shorten development loop.~~
