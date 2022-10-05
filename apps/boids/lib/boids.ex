defmodule Boids do
  @moduledoc """
    Adapted from:
    https://vergenet.net/~conrad/boids/pseudocode.html
    https://p5js.org/examples/simulate-flocking.html
  """
  alias Boids.Flock

  defdelegate calculate_next_acceleration(flock), to: Flock
  defdelegate move_flock(flock, wrap_fn \\ &Function.identity/1), to: Flock
end
