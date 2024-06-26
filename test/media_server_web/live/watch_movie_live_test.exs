defmodule MediaServerWeb.WatchMovieLiveTest do
  use MediaServerWeb.ConnCase

  import Phoenix.LiveViewTest
  import Ecto.Query

  setup %{conn: conn} do
    %{conn: conn |> log_in_user(MediaServer.AccountsFixtures.user_fixture())}
  end

  test "it should continue", %{conn: conn} do
    movie = MediaServer.MoviesIndex.find(MediaServer.MoviesIndex.all(), "1")

    {:ok, view, _disconnected_html} =
      live(conn, Routes.watch_index_path(conn, :index, movie: movie["id"]))

    render_hook(view, :video_destroyed, %{
      current_time: 89,
      duration: 100
    })

    query =
      from m in MediaServer.Movies,
        where: m.external_id == ^movie["id"]

    result = MediaServer.Repo.one(query)

    assert MediaServer.MovieContinues.where(movies_id: result.id).current_time === 89

    {:ok, view, _disconnected_html} =
      live(conn, Routes.watch_index_path(conn, :index, movie: movie["id"], timestamp: 89))

    assert render(view) =~ "89"

    render_hook(view, :video_destroyed, %{
      current_time: 45,
      duration: 100
    })

    query =
      from m in MediaServer.Movies,
        where: m.external_id == ^movie["id"]

    result = MediaServer.Repo.one(query)

    assert MediaServer.MovieContinues.where(movies_id: result.id).current_time === 45
  end

  test "it should not subtitle", %{conn: conn} do
    movie = MediaServer.MoviesIndex.find(MediaServer.MoviesIndex.all(), "2")

    {:ok, _view, disconnected_html} =
      live(conn, Routes.watch_index_path(conn, :index, movie: movie["id"]))

    refute disconnected_html =~ Routes.subtitle_path(conn, :index, movie: 2)
  end

  test "it should not have navigation", %{conn: conn} do
    movie = MediaServer.MoviesIndex.find(MediaServer.MoviesIndex.all(), "2")

    {:ok, _view, disconnected_html} =
      live(conn, Routes.watch_index_path(conn, :index, movie: movie["id"]))

    refute disconnected_html =~ "mobile-menu"
  end
end
