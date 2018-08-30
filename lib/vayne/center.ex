defmodule Vayne.Center do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Vayne.Center.Cache, [])
    ]

    opts = [strategy: :one_for_one, name: Vayne.Center.Supervisor]
    ret = Supervisor.start_link(children, opts)
    Application.ensure_all_started(:trot, :permanent)
    ret
  end
end
