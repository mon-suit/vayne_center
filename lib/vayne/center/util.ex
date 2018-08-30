defmodule Vayne.Center.Util do

  alias FalconPlusApi.Api.{Host, Hostgroup}

  def falcon_api_user, do: Application.get_env(:vayne_center, :falcon_api_user)

  def falcon_api_addr, do: Application.get_env(:vayne_center, :falcon_api_addr)

  def falcon_metric(metric) do
    Host.find_by_strategy(
      falcon_api_user(),
      falcon_api_addr(),
      body: %{"metric" => metric}
    )
  end

  def falcon_endpoint(type) do
    {:ok, hgs} = Hostgroup.list(falcon_api_user(), falcon_api_addr())
    hgs = hgs |> Enum.filter(fn hg -> hg["grp_name"] =~ ~r/^#{type}@/ end)
    hgs
    |> Enum.reduce([], fn (%{"id" => id}, acc) ->
      {:ok, info} = Hostgroup.get_info_by_id(id, falcon_api_user(), falcon_api_addr())
      host = Enum.map(info["hosts"], &(&1["hostname"]))
      acc ++ host
    end)
    |> Enum.uniq
  end

  def new_task(type, res, interval, metric, export) do
    param_hash = :erlang.phash2({metric, export, interval})
    %Vayne.Task{
      interval:    interval,
      metric_info: metric,
      export_info: export,
      uniqe_key:   "#{type}##{res}##{param_hash}",
    }
  end

  def try_parse(value) when is_binary(value) do
    case Integer.parse(value) do
      {v, _} -> v
      _      -> value
    end
  end
  def try_parse(value), do: value

  def parse_tags(tags) do
    tags
    |> String.split(",")
    |> Enum.map(fn x ->
      case Regex.run(~r/(.+?)=(.+)/, x, capture: :all_but_first) do
        [k, v] -> {k, v}
        _      -> nil
      end
    end)
    |> Enum.filter(&(&1))
    |> Enum.into(%{})
  end

  def make_tags(tags) when is_map(tags) do
    tags
    |> Map.to_list
    |> Enum.sort
    |> Enum.map(fn {k, v} -> "#{k}=#{v}" end) |> Enum.join(",")
  end

  def make_tags(_), do: nil
end
