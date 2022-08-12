defmodule BattleshipWeb.PageController do
  use BattleshipWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
