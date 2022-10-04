defmodule BoidsWeb.FlockLive do
  use BoidsWeb, :live_view

  alias Boids
  alias Boids.Boid
  alias Boids.Flock

  @tick_rate_ms 16
  @width 640
  @height 360

  def render(assigns) do
    width = @width
    height = @height

    ~H"""
    <canvas width={width} height={height} phx-hook="canvas" id="flock" phx-update="ignore" style="border: 1px solid black;">
      Canvas not supported!
    </canvas>
    <form phx-change="set_tick_rate">
      <label for="tick_rate">Tick Rate</label>
      <input type="range" name="tick_rate" id="tick_rate" min="0" max="100" value={@tick_rate} phx-debounce="1000">
    </form>
    """
  end

  def mount(_params, _session, socket) do
    tick(@tick_rate_ms)

    flock =
      [
        Boid.new(0, 0),
        Boid.new(10, 0),
        Boid.new(20, 10),
        Boid.new(10, 10),
        Boid.new(250, 250)
      ]
      |> Flock.new()

    {:ok,
     socket
     |> assign(:tick_rate, @tick_rate_ms)
     |> assign(:flock, flock)}
  end

  def handle_event("set_tick_rate", %{"_target" => ["tick_rate"], "tick_rate" => rate}, socket) do
    {:noreply, assign(socket, :tick_rate, String.to_integer(rate))}
  end

  def handle_info(:tick, %{assigns: %{flock: flock, tick_rate: tick_rate}} = socket) do
    tick(tick_rate)

    moved_flock =
      flock
      |> Boids.calculate_flock()
      |> Boids.move_flock(&wrap/1)

    updated_socket = assign(socket, :flock, moved_flock)
    boids = Enum.map(flock.members, &Boid.position/1)

    {:noreply, push_event(updated_socket, "render_boids", %{boids: boids})}
  end

  defp tick(tick_rate), do: Process.send_after(self(), :tick, tick_rate)

  # Enforce canvas borders, wrap boid around to the other side
  defp wrap(boid) do
    # Goofy to convert it into a list then back to a tensor :(
    new_pos =
      boid
      |> Boid.position()
      |> case do
        [x, y] when x < 0 -> [@width, y]
        [x, y] when x > @width -> [0, y]
        [x, y] when y < 0 -> [x, @width]
        [x, y] when y > @height -> [x, 0]
        inbounds -> inbounds
      end
      |> Nx.tensor()

    %{boid | position: new_pos}
  end
end
