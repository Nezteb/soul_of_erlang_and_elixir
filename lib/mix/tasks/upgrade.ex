defmodule Mix.Tasks.MySystem.Upgrade do
  @moduledoc false

  use Mix.Task

  # TODO: Doing live upgrades might not be easily doable with the distributed erlang setup?
  def run(_args) do
    # TODO: Collect telemetry here?
    # TODO: Or use :net_kernel.monitor_nodes/2?
    Node.start(:"upgrader@127.0.0.1")
    Node.set_cookie(:super_secret)

    # TODO: Update node connection? Which node will it connect to?
    Node.connect(:"my_system_1@127.0.0.1")

    Enum.each(
      [MySystem.Math, MySystemWeb.Math],
      fn module ->
        :ok =
          File.cp!(
            "_build/prod/lib/my_system/ebin/#{module}.beam",
            "_build/prod/rel/my_system/lib/my_system-0.1.0/ebin/#{module}.beam"
          )

        :rpc.call(:"my_system_1@127.0.0.1", :code, :purge, [module])
        {:module, ^module} = :rpc.call(:"my_system_1@127.0.0.1", :code, :load_file, [module])
      end
    )

    Mix.Shell.IO.info("Upgrade finished successfully.")
  end
end
