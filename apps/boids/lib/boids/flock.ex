defmodule Boids.Flock do
  alias Boids.Boid

  defstruct members: []

  def new(members) when is_list(members), do: %__MODULE__{members: members}

  def add(%__MODULE__{members: members}, %Boid{} = boid) do
    %__MODULE__{
      members: [boid | members]
    }
  end

  def size(%__MODULE__{members: members}), do: Enum.count(members)
end
