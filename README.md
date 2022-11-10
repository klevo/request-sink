# request-sink
Simple request forwarder that can be exposed publicly (through a tunnel) to forward requests to local apps under development.

## Setup

```shell
bundle install
```

### Run it development

```shell
bundle exec rerun "rackup -p 3033"
```

### Run in production

```shell
RACK_ENV=production bundle exec rackup -p 3033
```
