# RequestSink

<img src="https://user-images.githubusercontent.com/32981/201108854-8fdd870a-d742-4495-94ce-5c4f836f6a41.png" width="350" height="350" />

Simple request forwarder that can be exposed publicly (through a tunnel) to forward requests to local apps under development.

This is useful if you have some kind of a push API you want to develop against, and you want to receive requests from such API, safely, on your localhost.

Why not just expose the other app in question instead? Well usually it's going to be something like a Rails app, running in development mode. You don't want to expose such codebase in development mode to public internet directly, due to the large attack surface and possible disclosure of sensitive information.

## Setup

```shell
bundle install
```

## Run it in development

If you're developing on RequestSink, run it as follows. Code reloading is enabled.

Let's say you're running a Rails app on localhost port 3000. To forward requests that hit
RequestSink you can do:

```shell
FORWARD_TO="http://localhost:3000" FORWARD_HEADERS="X_FORWARDED_FOR X_API_KEY" bundle exec rerun "rackup -p 3033"
```

`FORWARD_TO` environment variable is required and should contain a fully qualified URI. It can also contain a path, however *always* ommit the trailing `/`.

## Run in production

For all other uses outside of developing on the codebase, run in production mode:

```shell
FORWARD_TO="http://localhost:3000" FORWARD_HEADERS="X_FORWARDED_FOR X_API_KEY" RACK_ENV=production bundle exec rackup -p 3033
```

To expose KitcheSink on the public internet, use something like [Cloudflare tunnel](https://www.cloudflare.com/en-gb/products/tunnel/) or [ngrok](https://ngrok.com).

## Testing

Testing sending a JSON payload to KitchenSink. Returns status code from the target
it forwarded the request to:

```shell
curl -X POST http://127.0.0.1:3033/any/path \
  -H 'Content-Type: application/json' \
  -d '{"sample":"json"}' \
  -w '%{http_code}'
```

or with a different request method:

```shell
curl -X PUT http://127.0.0.1:3033/any/path  \
  -H 'Content-Type: application/json' \
  -d '{"sample":"json"}' \
  -w '%{http_code}'
```
