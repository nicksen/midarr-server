defmodule MediaServer.Action do
  use Ecto.Schema
  import Ecto.Changeset

  alias MediaServer.Repo

  schema "user_actions" do
    field :action, :string

    timestamps()
  end

  def changeset(action, attrs) do
    action
    |> cast(attrs, [:action])
    |> validate_required([:action])
    |> unique_constraint(:action)
  end

  def list_actions do
    Repo.all(__MODULE__)
  end

  def create_action(attrs \\ %{}) do
    %__MODULE__{}
    |> __MODULE__.changeset(attrs)
    |> Repo.insert()
  end
end