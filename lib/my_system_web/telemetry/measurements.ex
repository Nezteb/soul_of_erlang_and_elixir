defmodule MySystemWeb.Telemetry.Measurements do
  @moduledoc """
  A helper for reporting periodict telemetry measurements.
  """

  @telemetry_event_name [:beam, :usage]

  def erlang_system_info() do
    # TODO: Add other helpful telemetry from https://www.erlang.org/docs/28/apps/erts/erlang.html#system_info/1
    # (while avoiding high-cardinality data)
    :telemetry.execute(@telemetry_event_name, %{
      atom_count: :erlang.system_info(:atom_count),
      ets_count: :erlang.system_info(:ets_count),
      port_count: :erlang.system_info(:port_count),
      process_count: :erlang.system_info(:process_count)
    })
  end
end
