defmodule LogRotate do
  use Application
  use GenServer
  require Logger

  @filenames Application.get_env :log_rotate, :filenames, []
  @check_every Application.get_env :log_rotate, :check_every, 1000
  @max_log_size Application.get_env :log_rotate, :max_log_size, 1048576
  @num_backups Application.get_env :log_rotate, :num_backups, 9

  def start(_type, _args) do
    config = [
      check_every: @check_every,
      max_log_size: @max_log_size,
      num_backups: @num_backups,
      filenames: @filenames
    ]
    GenServer.start_link(__MODULE__, config, name: Rotater)
    {:ok, self()}
  end

  def init(config) do
    state = Enum.into config, %{}
    loop state[:check_every]
    {:ok, state}
  end

  def handle_info(:check_log_size, state) do
    Enum.each state[:filenames], fn(file) -> check(file, state) end
    loop state[:check_every]
    {:noreply, state}
  end

  defp check(filename, state) do
    # Logger.info "checking #{filename} for state: #{inspect state}"
    case File.stat filename do
      {:ok, %File.Stat{size: size}} ->
        if size > state[:max_log_size] do
          rotate filename, 0, state[:num_backups]
        end
      _ -> nil
    end
  end

  defp loop(interval), do: Process.send_after(self(), :check_log_size, interval)

  defp rotate(filename, n, max_n) when n < max_n do
    if File.exists?(dot(filename, n)) do
      rotate(filename, n+1, max_n)
      #File.rename not available prior to elixir 1.1
      :file.rename dot(filename, n), dot(filename, n+1)
    end
  end

  defp rotate(_file_name, _n, _max_n) do
    nil
  end

  defp dot(filename, 0) do
    filename
  end

  defp dot(filename, n) do
    "#{filename}.#{n-1}"
  end

end
