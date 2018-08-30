defmodule Vayne.Center.Router do

  use Trot.Router

  def resp_type(conn, _opt) do
    conn |> put_resp_content_type("application/json")
  end

  @headers [{"Content-Type", "application/json"}]

  def encode(term) do
    term |> :erlang.term_to_binary |> Cipher.encrypt
  end

  def decode(binary) do
    binary |> Cipher.decrypt |> :erlang.binary_to_term
  end

  get "/tasks/:region" do
    tasks = region
            |> String.to_atom
            |> Vayne.Center.Cache.tasks()
            |> encode()

    {200, tasks, @headers}
  end

  import_routes Trot.NotFound

end
