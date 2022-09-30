defmodule Boids do
  @moduledoc """
    Adapted from:
    https://vergenet.net/~conrad/boids/pseudocode.html
    https://p5js.org/examples/simulate-flocking.html
  """
  alias Boids.{Boid, Flock}

  # run one frame of the flocking algorithm
  def flock(%Flock{members: members}) do
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
  def separate(boids) when is_list(boids) do
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
end
