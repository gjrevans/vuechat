defmodule VuechatWeb.Message do
  use Ecto.Schema
  import Ecto.Changeset
  alias VuechatWeb.Message


  schema "messages" do
    field :body, :string
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(%Message{} = message, attrs) do
    message
    |> cast(attrs, [:username, :body])
    |> validate_required([:username, :body])
  end
end
