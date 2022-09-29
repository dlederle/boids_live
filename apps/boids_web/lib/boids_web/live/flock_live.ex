defmodule BoidsWeb.FlockLive do
  use BoidsWeb, :live_view

  @tick_rate_ms 8

  def render(assigns) do
    ~H"""
    <canvas data-i={@i} phx-hook="canvas" id="flock" phx-update="ignore">
      Canvas not supported!
    </canvas>
    """
  end

  def mount(_params, _session, socket) do
    tick()
    {:ok, assign(socket, :i, 0)}
  end

  def handle_info(:tick, %{assigns: %{i: i}} = socket) do
    tick()
    {:noreply, assign(socket, :i, i + 0.5)}
  end

  defp tick(), do: Process.send_after(self(), :tick, @tick_rate_ms)
end
