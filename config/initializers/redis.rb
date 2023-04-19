redis_host = ENV["REDIS_HOST"] || "localhost"
redis_port = ENV["REDIS_PORT"] || 6379

# TODO: explore using connection_pool or the builtin Rails cache
# wrapper. Note that this doesn't provide connection pooling.
REDIS = Redis.new(host: redis_host)
