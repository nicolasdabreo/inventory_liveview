# Find eligible builder and runner images on Docker Hub. We use Ubuntu/Debian instead of
# Alpine to avoid DNS resolution issues in production.
#
# https://hub.docker.com/r/hexpm/elixir/tags?page=1&name=ubuntu
# https://hub.docker.com/_/ubuntu?tab=tags
#

ARG ELIXIR_VERSION=1.14.4
ARG OTP_VERSION=26.0
ARG DEBIAN_VERSION=bullseye-20220801-slim

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

# 
# Builder
# 

FROM ${BUILDER_IMAGE} as builder

# set up builder environment
ENV DEBIAN_FRONTEND=noninteractive
ENV MIX_ENV=prod 
ENV HEX_HOME=/app/.hex

WORKDIR /app

# install debian packages
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends build-essential ca-certificates git && \
    apt-get clean && \
    rm -f /var/lib/apt/lists/*_*

# install hex & rebar
RUN mix local.hex --force && \
  mix local.rebar --force

# install elixir deps
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV

# set up compile time dependancies
RUN mkdir config
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

# prepare assets and compile
COPY priv priv
COPY lib lib
COPY assets assets
RUN mix assets.deploy
RUN mix compile

# build release
COPY rel rel
COPY config/runtime.exs config/
RUN mix release

# 
# Runner
# 

FROM ${RUNNER_IMAGE} as deployment

RUN apt-get update -y && \
    apt-get install -y locales && \
    apt-get clean && \
    rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR "/app"

RUN chown nobody /app

# copy the final release from the builder
COPY --from=builder --chown=nobody:root /app/_build/prod/rel/mrp ./

USER nobody

CMD ["/app/bin/migrate", "/app/bin/server"]
