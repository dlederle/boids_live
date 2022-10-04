defmodule BoidsWeb.FlockLive do
  use BoidsWeb, :live_view

  alias Boids
  alias Boids.Boid
  alias Boids.Flock

  @tick_rate_ms 12
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

    flock =
      [
        Boid.new(0, 0),
        Boid.new(10, 0),
        Boid.new(10, 10),
        Boid.new(20, 10),
        Boid.new(20, 20),
        Boid.new(20, 20),
        Boid.new(20, 20),
        Boid.new(30, 20)
      ]
      |> Flock.new()

    {:ok,
     socket
     |> assign(:flock, flock)}
  end

  def handle_info(:tick, %{assigns: %{flock: flock}} = socket) do
    tick()

    moved_flock =
      flock
      |> Boids.calculate_flock()
      |> Boids.move_flock(&wrap/1)

    updated_socket = assign(socket, :flock, moved_flock)
    boids = Enum.map(flock.members, &Boid.position/1)

    {:noreply, push_event(updated_socket, "render_boids", %{boids: boids})}
  end

  defp tick(), do: Process.send_after(self(), :tick, @tick_rate_ms)

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
