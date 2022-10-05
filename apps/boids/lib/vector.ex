defmodule Boids.Vector do
  @moduledoc """
  Helpers for working with vectors
  """
  import Nx, only: [is_tensor: 1]

  defdelegate multiply(a, b), to: Nx
  defdelegate divide(a, b), to: Nx
  defdelegate add(a, b), to: Nx
  defdelegate subtract(a, b), to: Nx
  defdelegate new(list), to: Nx, as: :tensor
  defdelegate to_flat_list(vec), to: Nx

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
