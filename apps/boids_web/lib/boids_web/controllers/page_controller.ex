defmodule BoidsWeb.PageController do
  use BoidsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
