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
          separation = separate(b, flock) |> Nx.multiply(1.5)
          alignment = align(b, flock) |> Nx.multiply(1.0)
          coherence = cohere(b, flock) |> Nx.multiply(1.0)

          # IO.inspect("~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
          #  IO.inspect(alignment, label: "alignment")
          #    IO.inspect(coherence, label: "coherence")
          #    IO.inspect(separation, label: "separation")

          acceleration =
            b.acceleration
            |> Nx.add(separation)
            |> Nx.add(coherence)
            |> Nx.add(alignment)

          %{b | acceleration: acceleration}
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
    desired_separation = 25

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
            |> Nx.add(v)
            |> to_unit_vector(),
            count + 1
          }
        else
          {v, count}
        end
      end)

    if count > 0 do
      normalized_steer = Nx.divide(steer, count)

      if magnitude(normalized_steer) > 0 do
        # Implement Reynolds: Steering = Desired - Velocity
        steer
        |> to_unit_vector()
      else
        normalized_steer
      end
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
  def align(%Boid{} = boid, %Flock{members: members}) do
    neighbor_distance = 50

    initial_vector = Nx.tensor([0, 0])

    {steer, count} =
      Enum.reduce(members, {initial_vector, 0}, fn b, {v, count} ->
        d = distance(boid.position, b.position)

        if d > 0 and d < neighbor_distance do
          {
            Nx.add(b.velocity, v),
            count + 1
          }
        else
          {v, count}
        end
      end)

    if count > 0 do
      #   sum.div(count);
      #   sum.normalize();
      #   sum.mult(this.maxspeed);
      #   let steer = p5.Vector.sub(sum, this.velocity);
      #   steer.limit(this.maxforce);
      #   return steer;
      steer
      |> Nx.divide(count)
      |> to_unit_vector()
    else
      steer
    end
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
  def cohere(%Boid{} = boid, %Flock{members: members}) do
    neighbor_distance = 50

    initial_vector = Nx.tensor([0, 0])

    {steer, count} =
      Enum.reduce(members, {initial_vector, 0}, fn b, {v, count} ->
        d = distance(boid.position, b.position)

        if d > 0 and d < neighbor_distance do
          {
            Nx.add(b.position, v),
            count + 1
          }
        else
          {v, count}
        end
      end)

    if count > 0 do
      #   sum.div(count);
      #   sum.normalize();
      #   sum.mult(this.maxspeed);
      #   let steer = p5.Vector.sub(sum, this.velocity);
      #   steer.limit(this.maxforce);
      #   return steer;
      steer
      |> Nx.divide(count)
      |> to_unit_vector()
      |> Nx.subtract(boid.velocity)
    else
      steer
    end

    # if (count > 0) {
    #   sum.div(count);
    #   return this.seek(sum);  // Steer towards the location
    # } else {
    #   return createVector(0, 0);
    # }
  end

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
