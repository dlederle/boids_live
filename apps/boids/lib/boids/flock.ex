defmodule Boids.Flock do
  alias Boids.Boid
  alias Boids.Vector

  defstruct members: []

  def new(members) when is_list(members), do: %__MODULE__{members: members}

  def add(%__MODULE__{members: members}, %Boid{} = boid) do
    %__MODULE__{
      members: [boid | members]
    }
  end

  def size(%__MODULE__{members: members}), do: Enum.count(members)

  @doc """
    Calculates one frame of the algorithm, updating the acceleration of each member of the flock.
  """
  def calculate_next_acceleration(%__MODULE__{members: members} = flock) do
    %__MODULE__{
      members:
        Enum.map(members, fn b ->
          separation = separate(b, flock) |> Vector.multiply(1.5)
          alignment = align(b, flock) |> Vector.multiply(1.0)
          coherence = cohere(b, flock) |> Vector.multiply(1.0)

          # IO.inspect("~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
          #  IO.inspect(alignment, label: "alignment")
          #    IO.inspect(coherence, label: "coherence")
          #    IO.inspect(separation, label: "separation")

          acceleration =
            b.acceleration
            |> Vector.add(separation)
            |> Vector.add(coherence)
            |> Vector.add(alignment)

          %{b | acceleration: acceleration}
        end)
    }
  end

  @doc """
    Updates the position of every member of the flock by applying its acceleration.
  """
  def move_flock(%__MODULE__{members: members}, wrap_fn \\ &Function.identity/1) do
    %__MODULE__{
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
  defp separate(%Boid{} = boid, %__MODULE__{members: members}) do
    desired_separation = 25

    initial_vector = Vector.new([0, 0])

    {steer, count} =
      Enum.reduce(members, {initial_vector, 0}, fn b, {v, count} ->
        d = Vector.distance(boid.position, b.position)

        if d > 0 and d < desired_separation do
          {
            boid.position
            # vector pointing away from neighbor
            |> Vector.subtract(b.position)
            |> Vector.to_unit_vector()
            # weight by distance
            |> Vector.divide(d)
            |> Vector.add(v),
            count + 1
          }
        else
          {v, count}
        end
      end)

    if count > 0 do
      normalized_steer = Vector.divide(steer, count)

      if Vector.magnitude(normalized_steer) > 0 do
        # Implement Reynolds: Steering = Desired - Velocity
        steer
        |> Vector.to_unit_vector()
        |> Vector.subtract(boid.velocity)
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
  defp align(%Boid{} = boid, %__MODULE__{members: members}) do
    neighbor_distance = 50

    initial_vector = Vector.new([0, 0])

    {steer, count} =
      Enum.reduce(members, {initial_vector, 0}, fn b, {v, count} ->
        d = Vector.distance(boid.position, b.position)

        if d > 0 and d < neighbor_distance do
          {
            Vector.add(b.velocity, v),
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
      |> Vector.divide(count)
      |> Vector.to_unit_vector()
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
  defp cohere(%Boid{} = boid, %__MODULE__{members: members}) do
    neighbor_distance = 50

    initial_vector = Vector.new([0, 0])

    {steer, count} =
      Enum.reduce(members, {initial_vector, 0}, fn b, {v, count} ->
        d = Vector.distance(boid.position, b.position)

        if d > 0 and d < neighbor_distance do
          {
            Vector.add(b.position, v),
            count + 1
          }
        else
          {v, count}
        end
      end)

    if count > 0 do
      steer
      |> Vector.divide(count)
      |> Vector.to_unit_vector()
      |> Vector.subtract(boid.velocity)
    else
      steer
    end
  end
end
