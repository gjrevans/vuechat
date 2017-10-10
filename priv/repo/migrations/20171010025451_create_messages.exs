defmodule Vuechat.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :username, :string
      add :body, :string

      timestamps()
    end
    
    create index(:messages, :inserted_at)
  end
end
