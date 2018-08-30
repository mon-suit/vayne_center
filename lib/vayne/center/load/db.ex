defmodule Vayne.Center.Load.DB do
  alias Vayne.Center.{Util, Area}

  @types ~w(mysql memcache mongodb redis)
  @interval 60

  def run do
    Enum.reduce(@types, %{}, fn (type, acc) ->
      res = Util.falcon_endpoint(type)
      Enum.reduce(res, acc, fn (resource, acc) ->
        area = Area.get_area(resource)
        task = apply(__MODULE__, String.to_atom(type), [resource])
        update_in(acc[area], fn v ->
          v = v || []
          [task | v]
        end)
      end)
    end)
  end

  def mysql(res) do
    [role, ip, port] = case String.split(res, ":") do
      [ip]             -> ["slave", ip, nil]
      [ip, port]       -> ["slave", ip, port]
      [role, ip, port] -> [role,    ip, port]
    end

    export_params   = %{"endpoint" => res, "step" => 60, "metric_spec" => "mysql"}
    metric_params = %{"hostname" => ip, "port" => Util.try_parse(port), "role" => role}
                    |> Map.merge(mysql_opt(res))

    Util.new_task("mysql", res, @interval,
      %{module: Vayne.Metric.Mysql, params: metric_params},
      %{module: Vayne.Export.OpenFalcon, params: export_params}
    )
  end

  def mysql_opt(_res), do: %{}
  #def mysql_opt(_res), do: %{"username" => "monitor_account", "password" => "password"}

  def redis(res) do
    [ip, port] = case String.split(res, ":") do
      [ip]             -> [ip, nil]
      [ip, port]       -> [ip, port]
    end

    export_params   = %{"endpoint" => res, "step" => 60, "metric_spec" => "redis"}
    metric_params = %{"host" => ip, "port" => Util.try_parse(port)}
                    |> Map.merge(redis_opt(res))

    Util.new_task("redis", res, @interval,
      %{module: Vayne.Metric.Redis, params: metric_params},
      %{module: Vayne.Export.OpenFalcon, params: export_params}
    )
  end

  def redis_opt(_res), do: %{}
  #def redis_opt(_res), do: %{"max_memory" => 99999, "password" => "password"}

  def memcache(res) do
    [ip, port] = case String.split(res, ":") do
      [ip]             -> [ip, nil]
      [ip, port]       -> [ip, port]
    end

    export_params   = %{"endpoint" => res, "step" => 60, "metric_spec" => "memcache"}
    metric_params = %{"hostname" => ip, "port" => Util.try_parse(port)}

    Util.new_task("memcache", res, @interval,
      %{module: Vayne.Metric.Memcache, params: metric_params},
      %{module: Vayne.Export.OpenFalcon, params: export_params}
    )
  end

  def mongodb(res) do
    [role, ip, port] = case String.split(res, ":") do
      [ip]             -> [nil,  ip, nil]
      [ip, port]       -> [nil,  ip, port]
      [role, ip, port] -> [role, ip, port]
    end

    export_params   = %{"endpoint" => res, "step" => 60, "metric_spec" => "mongodb"}
    metric_params = %{"hostname" => ip, "port" => Util.try_parse(port), "role" => role}
                    |> Map.merge(mongodb_opt(res))

    Util.new_task("mongodb", res, @interval,
      %{module: Vayne.Metric.Mongodb, params: metric_params},
      %{module: Vayne.Export.OpenFalcon, params: export_params}
    )
  end

  def mongodb_opt(_res), do: %{}
  #def mongodb_opt(_res), do: %{"username" => "monitor_account", "password" => "password"}
end
