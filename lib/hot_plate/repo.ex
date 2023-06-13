defmodule HotPlate.Repo do
  use Ecto.Repo,
    otp_app: :hot_plate,
    adapter: Ecto.Adapters.MyXQL
end
