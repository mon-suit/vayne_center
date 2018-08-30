defmodule Vayne.Center.Load.HTTP do

  alias Vayne.Center.{Util, Area}

  @interval 60

  @default_http_tag   %{"code" => 200, "proto" => "http", "url" => "/"}
  @default_report_tag ~w(code host method port proto url match area)

  def run do
    {:ok, metrics} = Util.falcon_metric("http.check")
    Enum.map(metrics, fn %{"hosts" => hosts, "strategy" => strategy} ->
      tags = Util.parse_tags(strategy["tags"])
      parse_http_task(tags, hosts)
    end)
    |> List.flatten
    |> Enum.reduce(%{}, fn ({area, task}, acc) ->
      update_in(acc[area], fn array ->
        array = array || []
        [task | array]
      end)
    end)
  end

  #can translate endpoint to server internal ip address
  defp addr_translate(_resource), do: nil

  defp parse_http_task(tags, hosts) do
    report_tags = tags |> Map.take(@default_report_tag) |> Util.make_tags
    metric_func = gen_http_metric_param(tags)

    Enum.map(hosts, fn resource ->
      trans_addr = addr_translate(resource)

      area = tags["area"] || Area.get_area(trans_addr || resource)
      area = if is_binary(area), do: String.to_atom(area), else: area

      metric_params = metric_func.(trans_addr || resource)
      export_params = %{"endpoint" => resource, "step" => @interval, "tags" => report_tags}

      task = Util.new_task("http_check", resource, @interval,
        %{module: Vayne.Metric.Http, params: metric_params},
        %{module: Vayne.Export.OpenFalcon, params: export_params}
      )

      {area, task}
    end)
  end

  defp gen_http_metric_param(tags) do
    tags = Map.merge(@default_http_tag, tags)

    proto = String.downcase(tags["proto"])

    status_code = if is_binary(tags["code"]) and tags["code"] =~ ~r/^\d+$/ do
      String.to_integer(tags["code"])
    else
      tags["code"]
    end

    suffix = String.replace(tags["url"], ~r/^\/*/, "")

    fn resource ->
        addr   = if tags["port"], do: "#{resource}:#{tags["port"]}", else: resource
        url    = "#{proto}://#{addr}/#{suffix}"
        params = %{"url"  => url, "status_code" => status_code}
        params = if tags["method"], do: Map.put(params, "method", tags["method"]), else: params
        params = if tags["host"],   do: Map.put(params, "host", tags["host"]),     else: params
        params = if tags["body"],   do: Map.put(params, "body", tags["body"]),     else: params
        params = if tags["match"],  do: Map.put(params, "match", tags["match"]),   else: params
        params
    end
  end

end
