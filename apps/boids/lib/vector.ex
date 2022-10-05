defmodule Boids.Vector do
  @moduledoc """
  Helpers for working with vectors
  """
  import Nx, only: [is_tensor: 1]

  # God ol' Pythagoras
  def distance(a, a), do: 0

  def distance(a, b) when is_tensor(a) and is_tensor(b) do
    [ax, ay] = Nx.to_flat_list(a)
    [bx, by] = Nx.to_flat_list(b)

    :math.sqrt(
      :math.pow(bx - ax, 2) +
        :math.pow(by - ay, 2)
    )
  end

  def magnitude(vector) when is_tensor(vector) do
    vector
    |> distance(Nx.tensor([0, 0]))
  end

  def to_unit_vector(vector) when is_tensor(vector) do
    vector
    |> Nx.divide(magnitude(vector))
  end
end
