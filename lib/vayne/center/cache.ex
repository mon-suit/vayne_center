defmodule Vayne.Center.Cache do

  def start_link do
    Agent.start_link(&load_task/0, name: __MODULE__)
  end

  def update,        do: Agent.update(__MODULE__, &load_task/0)
  def raw_tasks,     do: Agent.get(__MODULE__,    &(&1))
  def tasks(region), do: Agent.get(__MODULE__,    &(&1[region]))

  def load_task do
    [
      Vayne.Center.Load.DB.run(),
      Vayne.Center.Load.HTTP.run(),
    ] |> Enum.reduce(%{}, fn (tasks, acc) ->
      Map.merge(acc, tasks, fn _k, v1, v2 -> v1 ++ v2 end)
    end)
  end

end
