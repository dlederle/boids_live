defmodule Boids do
  @moduledoc """
    Adapted from:
    https://vergenet.net/~conrad/boids/pseudocode.html
    https://p5js.org/examples/simulate-flocking.html
  """
  import Nx, only: [is_tensor: 1]

  alias Boids.{Boid, Flock}

  # run one frame of the flocking algorithm
  def calculate_flock(%Flock{members: members} = flock) do
    %Flock{
      members:
        Enum.map(members, fn b ->
          separation = separate(b, flock)
          %{b | acceleration: Nx.add(b.acceleration, separation)}
        end)
    }
  end

  def move_flock(%Flock{members: members}, wrap_fn \\ &Function.identity/1) do
    %Flock{
      members:
        Enum.map(members, fn b ->
          b |> Boid.update() |> wrap_fn.()
        end)
    }
  end

  # PSEUDOCODE:
  #   	Vector c = 0;
  # 		FOR EACH BOID b
  # 			IF b != bJ THEN
  # 				IF |b.position - bJ.position| < 100 THEN
  # 					c = c - (b.position - bJ.position)
  # 				END IF
  # 			END IF
  # 		END
  #
  # 		RETURN c
  def separate(%Boid{} = boid, %Flock{members: members}) do
    desired_separation = 100

    initial_vector = Nx.tensor([0, 0])

    {steer, count} =
      Enum.reduce(members, {initial_vector, 0}, fn b, {v, count} ->
        d = distance(boid.position, b.position)

        if d > 0 and d < desired_separation do
          {
            boid.position
            # vector pointing away from neighbor
            |> Nx.subtract(b.position)
            # weight by distance
            |> Nx.divide(d)
            |> Nx.add(v),
            count + 1
          }
        else
          {v, count}
        end
      end)

    if count > 0 do
      Nx.divide(steer, count)
    else
      steer
    end
  end

  # PSEUDOCODE:
  # 		Vector pcJ
  # 		FOR EACH BOID b
  # 			IF b != bJ THEN
  # 				pcJ = pcJ + b.position
  # 			END IF
  # 		END
  #
  # 		pcJ = pcJ / N-1
  #
  # 		RETURN (pcJ - bJ.position) / 100
  def align(boids) when is_list(boids) do
  end

  # PSEUDOCODE:
  #     Vector pvJ
  # 		FOR EACH BOID b
  # 			IF b != bJ THEN
  # 				pvJ = pvJ + b.velocity
  # 			END IF
  # 		END
  #
  # 		pvJ = pvJ / N-1
  #
  # 		RETURN (pvJ - bJ.velocity) / 8
  def cohesion(boids) when is_list(boids) do
  end

  # God ol' Pythagoras
  def distance(a, b) when is_tensor(a) and is_tensor(b) do
    [ax, ay] = Nx.to_flat_list(a)
    [bx, by] = Nx.to_flat_list(b)

    :math.sqrt(
      :math.pow(bx - ax, 2) +
        :math.pow(by - ay, 2)
    )
  end
end
