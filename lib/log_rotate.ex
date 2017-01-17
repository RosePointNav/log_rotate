defmodule LogRotate do
  use Application
  use GenServer
  require Logger

  def start(_type, _args) do
    config = Application.get_env :logger, :rotate
    GenServer.start_link(__MODULE__, config, name: Rotater)
    {:ok, self}
  end

  def init(config) do
    state = Enum.into config, %{}
    loop state[:check_every]
    {:ok, state}
  end

  def handle_info(:check_log_size, state) do
    case File.stat state[:file_name] do
      {:ok, %File.Stat{size: size}} ->
        if size > state[:max_log_size] do
          rotate state[:file_name], 0, state[:num_backups]
        end
      _ -> nil 
    end
    loop state[:check_every]
    {:noreply, state}
  end

  defp loop(interval), do: Process.send_after(self, :check_log_size, interval)

  defp rotate(file_name, n, max_n) when n < max_n do
    if File.exists?(dot(file_name, n)) do
      rotate(file_name, n+1, max_n)
      File.rename dot(file_name, n), dot(file_name, n+1)
    end
  end

  defp rotate(_file_name, _n, _max_n) do
    nil
  end

  defp dot(file_name, 0) do
    file_name
  end
  
  defp dot(file_name, n) do
    "#{file_name}.#{n}"
  end

end
