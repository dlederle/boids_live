defmodule Boids.Boid do
  alias Tensor.Tensor

  defstruct acceleration: Tensor.new([0, 0]),
            velocity: Tensor.new([0, 0]),
            position: Tensor.new([0, 0])

  def new(x, y) do
    %__MODULE__{
      acceleration: Tensor.new([0, 0]),
      velocity: Tensor.new([:rand.uniform(), :rand.uniform()]),
      position: Tensor.new([x, y])
    }
  end
end
