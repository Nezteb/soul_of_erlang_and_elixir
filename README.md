# Telemetry-Driven Development Demo

- http://localhost:4000/
- http://localhost:4000/dashboard/load_control
- http://localhost:4000/dashboard/metrics
- http://localhost:4000/dashboard/processes
- https://www.tldraw.com/

## TODO

- [ ] Docker compose stack with LGTM stack
  - [X] Dockerfile for just this service?
    - Container per node? Demo system can spin up new nodes dynamically, so maybe just a single basic Docker container.
  - [ ] Figure out how to get DNS Cluster working locally with Docker Compose? https://docs.docker.com/desktop/features/networking/
    - https://elixirforum.com/t/using-dns-cluster-with-docker-compose-locally-it-can-be-done/61336
    - https://github.com/igin/elixir_phoenix_compose_cluster_demo
- [ ] Basic OTel span sending to LGTM stack
- [ ] Every thing else is extra win!

---

# MySystem

This is updated source code of the demo used in my talk [Soul of Erlang and Elixir](https://www.youtube.com/watch?v=JvBT4XBdoUE). Note that some changes have been made compared to the original demo (the code of which can be found [here](https://github.com/sasa1977/demo_system)).

## Usage

The Elixir & Erlang versions are specified in the .tool-versions. You can use the [asdf version manager](https://github.com/asdf-vm/asdf) to install them.


0. `mix deps.get`
1. Build the release with `mix release`.
2. Start it with `_build/prod/rel/my_system/bin/my_system start`
3. You can find the load control dashboard at http://localhost:4000/dashboard/load_control
4. The sum calculation page is available at http://localhost:4000
5. Compared to the original demo, there is no helper code to find the busiest process(es). Instead, you can use the [processes dashboard](http://localhost:4000/dashboard/processes), and sort by reductions.
6. To upgrade the running system invoke `mix upgrade`. Note that this task is very hacky, and it will only update the two modules which need to be changed to fix the problem.
7. To start additional node(s) you can invoke `mix add_node`. This will start a dev node that listens on the next available port (4001, 4002, ...). The node will take over some part of the synthetic load created on the load control page. If the node is taken down, the remaining nodes will take over the missing load.

## License

MIT
