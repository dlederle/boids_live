defmodule BoidsWeb.FlockLive do
  use BoidsWeb, :live_view

  @tick_rate_ms 60
  @width 500
  @height 500

  def render(assigns) do
    ~H"""
    <canvas width="500" height="500" phx-hook="canvas" id="flock" phx-update="ignore" style="border: 1px solid black;">
      Canvas not supported!
    </canvas>
    """
  end

  def mount(_params, _session, socket) do
    tick()

    {:ok,
     socket
     |> assign(:x, 0)
     |> assign(:y, 0)}
  end

  def handle_info(:tick, %{assigns: %{x: x, y: y}} = socket) do
    tick()
    {nx, ny} = generate_next_coord({x, y})

    updated_socket =
      socket
      |> assign(:x, nx)
      |> assign(:y, ny)

    {:noreply, push_event(updated_socket, "render_boid", %{x: nx, y: ny})}
  end

  defp tick(), do: Process.send_after(self(), :tick, @tick_rate_ms)

  defp generate_next_coord({x, y}) do
    nx =
      cond do
        x > @width -> 0
        x < 0 -> @width
        true -> x + 1
      end

    ny =
      cond do
        y > @height -> 0
        y < 0 -> @height
        true -> y + 1
      end

    {nx, ny}
  end
end
