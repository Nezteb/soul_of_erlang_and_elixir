node_name := "tdd"
node_host := "host.docker.internal
node_cookie := "cookie"

all: services setup compile format lint test

iex:
    iex --name {{node_name}}@{{node_host}} \
        --cookie {{node_cookie}} \
        -S mix phx.server

services:
    docker-compose up --detach \
                      --remove-orphans \
                      --renew-anon-volumes \
                      --force-recreate \
                      lgtm postgres

docker:
    docker-compose up --detach \
                      --remove-orphans \
                      --renew-anon-volumes \
                      --force-recreate \
                      --build

setup:
    mix setup

compile:
    mix compile --warnings-as-errors

release:
    MIX_ENV=prod mix release

lint:
    mix credo diff
    mix dialyzer

lint-diff:
    mix credo diff --from-git-merge-base main

format:
    mix format

test:
    mix test
