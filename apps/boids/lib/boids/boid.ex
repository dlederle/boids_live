defmodule Boids.Boid do
  alias Boids.Vector

  defstruct acceleration: Vector.new([0, 0]),
            velocity: Vector.new([0, 0]),
            position: Vector.new([0, 0])

  def new(x, y) do
    %__MODULE__{
      acceleration: Vector.new([:rand.uniform(), :rand.uniform()]),
      velocity: Vector.new([:rand.uniform(), :rand.uniform()]),
      position: Vector.new([x, y])
    }
  end

  def position(%__MODULE__{position: position}), do: Vector.to_flat_list(position)

  def update(%__MODULE__{} = boid) do
    v = Vector.add(boid.velocity, boid.acceleration)
    p = Vector.add(boid.position, v)
    a = Vector.multiply(boid.acceleration, 0)

    %__MODULE__{
      velocity: v,
      position: p,
      acceleration: a
    }
  end
end
