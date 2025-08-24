# TODO: All AI, update.

# Use Elixir 1.14 as base image
FROM hexpm/elixir:1.14-erlang-25-alpine AS builder

# Install build dependencies
RUN apk add --no-cache build-base git nodejs npm

# Prepare build directory
WORKDIR /app

# Install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set build ENV
ENV MIX_ENV=prod

# Install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mix deps.compile

# Build assets
COPY assets assets
COPY priv priv
RUN mix assets.deploy

# Copy config and lib files
COPY config config
COPY lib lib
COPY rel rel

# Compile and build release
RUN mix compile
RUN mix release

# Prepare release image
FROM alpine:3.16 AS app
RUN apk add --no-cache libstdc++ openssl ncurses-libs

WORKDIR /app

# Copy release from builder stage
COPY --from=builder /app/_build/prod/rel/my_system ./

# Run as non-root user for security
RUN adduser -D myuser
USER myuser

# Set runtime ENV
ENV PORT=4000 \
    RELEASE_DISTRIBUTION=name \
    ERL_EPMD_PORT=4369 \
    ERL_AFLAGS="-kernel inet_dist_listen_min 4370 inet_dist_listen_max 4372"

EXPOSE ${PORT} 4369 4370-4372

ENTRYPOINT ["/app/bin/my_system"]
CMD ["start"]
