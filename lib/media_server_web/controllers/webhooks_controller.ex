defmodule MediaServerWeb.WebhooksController do
  use MediaServerWeb, :controller

  def create(conn, %{"id" => "movie", "eventType" => "Download"}) do
    MediaServer.MoviesIndex.reset()

    conn
    |> send_resp(201, "Ok")
  end

  def create(conn, %{"id" => "movie", "eventType" => "MovieDelete"}) do
    MediaServer.MoviesIndex.reset()

    conn
    |> send_resp(201, "Ok")
  end

  def create(conn, %{"id" => "movie", "eventType" => "MovieFileDelete"}) do
    MediaServer.MoviesIndex.reset()

    conn
    |> send_resp(201, "Ok")
  end

  def create(conn, %{"id" => "series", "eventType" => "Download"}) do
    MediaServer.SeriesIndex.reset()

    conn
    |> send_resp(201, "Ok")
  end

  def create(conn, %{"id" => "series", "eventType" => "SeriesDelete"}) do
    MediaServer.SeriesIndex.reset()

    conn
    |> send_resp(201, "Ok")
  end

  def create(conn, %{"id" => "series", "eventType" => "EpisodeFileDelete"}) do
    MediaServer.SeriesIndex.reset()

    conn
    |> send_resp(201, "Ok")
  end

  def create(conn, _payload) do
    conn
    |> send_resp(200, "Ok")
  end
end