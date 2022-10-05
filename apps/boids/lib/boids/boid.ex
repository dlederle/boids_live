defmodule Boids.Boid do
  defstruct acceleration: Nx.tensor([0, 0]),
            velocity: Nx.tensor([0, 0]),
            position: Nx.tensor([0, 0])

  def new(x, y) do
    %__MODULE__{
      acceleration: Nx.tensor([:rand.uniform(), :rand.uniform()]),
      velocity: Nx.tensor([:rand.uniform(), :rand.uniform()]),
      position: Nx.tensor([x, y])
    }
  end

  def position(%__MODULE__{position: position}), do: Nx.to_flat_list(position)

  def update(%__MODULE__{} = boid) do
    v = Nx.add(boid.velocity, boid.acceleration)
    p = Nx.add(boid.position, v)
    a = Nx.multiply(boid.acceleration, 0)

    %__MODULE__{
      velocity: v,
      position: p,
      acceleration: a
    }
  end
end
