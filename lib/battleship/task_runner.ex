defmodule Battleship.TaskRunner do
  # TODO: reimplement this using Genserver(https://hexdocs.pm/elixir/1.14/Task.html#await/2-compatibility-with-otp-behaviours
  require Logger

  @remote_node_name "phoenix-aayushsahu-com"

  def get_task_runner_node() do
    Node.list()
    |> Enum.find(nil, fn node_name ->
      node_name
      |> Atom.to_string()
      |> String.contains?(@remote_node_name)
    end)
  end

  def run(task_info, remote_node) do
    %{module: module, function: function, args: args} = task_info

    Task.async(fn ->
      Process.flag(:trap_exit, true)

      _t2 =
        Task.Supervisor.async_nolink(
          # Accumulator.TaskRunner is a task supervisor that's running on remote node
          {Accumulator.TaskRunner, remote_node},
          module,
          function,
          args
        )

      receive do
        {:DOWN, _, _, pid, _reason} ->
          Logger.error("Task execution failed with PID: #{pid}")
          nil

        {_ref, result} ->
          result
      end
    end)
    |> Task.await()
  end
end
