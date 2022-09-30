defmodule Boids.Boid do
  defstruct acceleration: Nx.tensor([0, 0]),
            velocity: Nx.tensor([0, 0]),
            position: Nx.tensor([0, 0])

  def new(x, y) do
    %__MODULE__{
      acceleration: Nx.tensor([0, 0]),
      velocity: Nx.tensor([:rand.uniform(), :rand.uniform()]),
      position: Nx.tensor([x, y])
    }
  end
end
