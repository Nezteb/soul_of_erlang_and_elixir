defmodule MySystem.ClusterMonitor do
  @moduledoc """
  TODO: Docs explaining that only leader node reports telemetry.

  Modified version of SmartRent's cluster setup, which I attribute primarily to:
  - Kawika Kekahuna (Senior Software Engineer II @ SmartRent)
  - Jon Carstens (Director of Engineering @ SmartRent)
  - Noah helped a bit
  """

  use GenServer
  require Logger

  @telemetry_event_name [:cluster, :peers]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, %{}, name: opts[:name] || __MODULE__)
  end

  @impl GenServer
  def init(state) do
    Logger.info("Monitoring nodes...", state: inspect(state))

    # https://www.erlang.org/doc/apps/kernel/net_kernel.html#monitor_nodes/2
    :net_kernel.monitor_nodes(true, %{connection_id: true, node_type: :all, nodedown_reason: true})

    # Give 2s for the cluster to form before reporting telemetry
    Process.send_after(self(), :report_initial_telemetry_if_leader, Kernel.to_timeout(second: 2))

    {:ok, state}
  end

  @impl GenServer
  def handle_info(:report_initial_telemetry_if_leader, state) do
    send_self_nodeup_if_leader()
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:nodeup, node, info}, state) do
    Logger.info("Node up!", node: node, info: inspect(info))
    report_telemetry_if_leader()
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:nodedown, node, info}, state) do
    Logger.info("Node down!", node: node, info: inspect(info))
    report_telemetry_if_leader()
    {:noreply, state}
  end

  defp send_self_nodeup_if_leader() do
    if leader?() do
      # https://www.erlang.org/doc/apps/erts/erlang#nodes/2
      node_pairs = :erlang.nodes(:known, %{connection_id: true, node_type: true})

      {node, node_info} =
        Enum.find(node_pairs, fn {node, _node_info} ->
          node == Node.self()
        end)

      Process.send(self(), {:nodeup, node, node_info}, [])
    else
      Logger.info("send_self_nodeup_if_leader: Not leader!")
    end
  end

  defp report_telemetry_if_leader() do
    if leader?() do
      nodes_by_type =
        :erlang.nodes(:known, %{node_type: true})
        |> Enum.group_by(fn {_node, %{node_type: type}} -> type end)
        |> Map.new(fn {type, nodes} -> {type, Enum.count(nodes)} end)

      Logger.info("Leader sees nodes", nodes_by_type: inspect(nodes_by_type))

      known_node_count = Map.get(nodes_by_type, :visible, 0) + Map.get(nodes_by_type, :hidden, 0)
      visible_node_count = Map.get(nodes_by_type, :visible, 0)
      hidden_node_count = Map.get(nodes_by_type, :hidden, 0)

      :telemetry.execute(
        @telemetry_event_name,
        %{
          # Add 1 to include self in count
          visible_node_count: visible_node_count + 1,
          hidden_node_count: hidden_node_count,
          known_node_count: known_node_count
        },
        %{leader_node: Node.self()}
      )
    else
      Logger.info("report_telemetry_if_leader: Not leader!")
    end
  end

  # Simple leader election: first/leftmost node in sorted list is leader.
  defp leader?() do
    # https://hexdocs.pm/elixir/Node.html#list/1
    # https://www.erlang.org/doc/apps/erts/erlang.html#nodes/1
    [leader | _] = Enum.sort(Node.list([:this, :visible]))

    leader == Node.self()
  end
end
