# Weather Report

Weather Report is a simple weather reporting and forecasting
application, written using Ruby on Rails.

## Installation

This project was created using Ruby 3.0.5, so ensure that you have
that installed before proceeding. Alternatively, you can install the
project using the provided `Dockerfile` and associated scripts.

### Docker

Run the following scripts at your terminal to build and run the
application.

```command
./bin/docker-build && ./bin/docker-run
```

You can also clean up resources Docker created when done:

```command
./bin/docker-destroy
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

## Testing

Things you may want to cover:

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Discussion

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
