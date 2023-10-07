defmodule MediaServerWeb.UserFollowTest do
  use MediaServerWeb.ConnCase

  import Phoenix.LiveViewTest

  alias MediaServer.AccountsFixtures

  setup %{conn: conn} do
    user = AccountsFixtures.user_fixture()

    %{conn: conn |> log_in_user(user), user: user}
  end

  test "it should follow movie", %{conn: conn, user: user} do
    Phoenix.PubSub.subscribe(MediaServer.PubSub, "user")

    movie = MediaServer.MoviesIndex.all() |> List.first()

    {:ok, view, _html} = live(conn, ~p"/movies/#{movie["id"]}")

    view
    |> element("#follow", "Follow")
    |> render_hook(:follow, %{media_id: movie["id"], media_type: "movie", user_id: user.id})

    assert_received {:followed, %{"media_id" => 3, "media_type" => "movie", "user_id" => _user_id}}

    # Not ideal but wait for processed message (async)
    :timer.sleep(1000)

    media = MediaServer.MediaActions.all()

    assert Enum.count(media) === 1

    assert Enum.at(media, 0).media_id === movie["id"]
    assert Enum.at(media, 0).action_id === MediaServer.Actions.get_followed_id()
  end

  test "it should unfollow movie", %{conn: conn, user: user} do
    Phoenix.PubSub.subscribe(MediaServer.PubSub, "user")

    movie = MediaServer.MoviesIndex.all() |> List.first()

    MediaServer.MediaActions.create(%{
      media_id: movie["id"],
      user_id: user.id,
      action_id: MediaServer.Actions.get_followed_id(),
      media_type_id: MediaServer.MediaTypes.get_type_id("movie")
    })

    {:ok, view, _html} = live(conn, ~p"/movies/#{movie["id"]}")

    view
    |> element("#follow", "Following")
    |> render_hook(:unfollow, %{media_id: movie["id"], media_type: "movie", user_id: user.id})

    assert_received {:unfollowed, %{"media_id" => 3, "media_type" => "movie", "user_id" => _user_id}}

    # Not ideal but wait for processed message (async)
    :timer.sleep(1000)

    media = MediaServer.MediaActions.all()

    assert Enum.count(media) === 0
  end

  test "it should grant push notifications", %{conn: conn, user: user} do
    Phoenix.PubSub.subscribe(MediaServer.PubSub, "user")

    movie = MediaServer.MoviesIndex.all() |> List.first()

    {:ok, view, _html} = live(conn, ~p"/movies/#{movie["id"]}")

    view
    |> element("#follow", "Follow")
    |> render_hook(:grant_push_notifications, %{media_id: movie["id"], media_type: "movie", user_id: user.id, push_subscription: "some subscription"})

    assert_received {:granted_push_notifications, %{"media_id" => 3, "media_type" => "movie", "user_id" => _user_id, "push_subscription" => "some subscription"}}

    # Not ideal but wait for processed message (async)
    :timer.sleep(1000)

    push_subscriptions = MediaServer.PushSubscriptions.all()

    assert Enum.at(push_subscriptions, 0).push_subscription === "some subscription"
  end

  test "it should deny push notifications", %{conn: conn, user: user} do
    Phoenix.PubSub.subscribe(MediaServer.PubSub, "user")

    movie = MediaServer.MoviesIndex.all() |> List.first()

    {:ok, view, _html} = live(conn, ~p"/movies/#{movie["id"]}")

    view
    |> element("#follow", "Follow")
    |> render_hook(:deny_push_notifications, %{media_id: movie["id"], media_type: "movie", user_id: user.id, message: "some message"})

    assert_received {:denied_push_notifications, %{"media_id" => 3, "media_type" => "movie", "user_id" => _user_id, "message" => "some message"}}

    # Not ideal but wait for processed message (async)
    :timer.sleep(1000)

    push_subscriptions = MediaServer.PushSubscriptions.all()

    assert Enum.at(push_subscriptions, 0).push_subscription === "some message"
  end
end