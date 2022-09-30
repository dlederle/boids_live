defmodule Boids do
  @moduledoc """
    Adapted from:
    https://vergenet.net/~conrad/boids/pseudocode.html
    https://p5js.org/examples/simulate-flocking.html
  """
  import Nx, only: [is_tensor: 1]

  alias Boids.{Boid, Flock}

  # run one frame of the flocking algorithm
  def calculate_flock(%Flock{members: members}) do
    %Flock{
      members:
        Enum.map(members, fn b ->
          separation = separate(b, members)
          IO.inspect(separation)

          members
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

    {steer, count} =
      Enum.reduce(members, {Nx.tensor(0, 0), 0}, fn b, {v, count} ->
        distance = distance(boid.position, b.position)
        return = {v, count}

        if(distance > 0 and distance < desired_separation) do
          return = {
            boid.position
            # vector pointing away from neighbor
            |> Nx.subtract(b.position)
            # weight by distance
            |> Nx.divide(distance)
            |> Nx.add(v),
            count + 1
          }
        end

        return
      end)

    # TODO: velocity stuff
    Nx.divide(steer, count)
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
