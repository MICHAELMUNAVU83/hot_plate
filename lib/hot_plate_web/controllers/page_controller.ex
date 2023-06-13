defmodule HotPlateWeb.PageController do
  use HotPlateWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
