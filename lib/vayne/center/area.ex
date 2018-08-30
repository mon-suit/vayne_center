defmodule Vayne.Center.Area do

  def areas, do: Application.get_env(:vayne_center, :areas, [])

  def get_str_rules do
    Enum.reduce(areas(), %{}, fn ({area, rule}, acc) ->
      strs = rule[:str] || []
      Enum.reduce(strs, acc, fn (str, acc) -> Map.put(acc, ~r/#{str}/, area) end)
    end)
  end

  def get_ip_rules do
    Enum.reduce(areas(), %{}, fn ({area, rule}, acc) ->
      strs = rule[:ip] || []
      Enum.reduce(strs, acc, fn (ip, acc) -> Map.put(acc, InetCidr.parse(ip), area) end)
    end)
  end

  def get_area(resource) do
    default  = Application.get_env(:vayne_center, :default_area, :undefine)
    resource = String.trim(resource)

    area = case try_extrace_ip(resource) do
      {:ok, ip} ->
        {_, area} = get_ip_rules()
        |> Enum.find({nil, nil}, fn {cidr, _area} -> InetCidr.contains?(cidr, ip) end)
        area
      _ ->
        {_, area} = get_str_rules()
        |> Enum.find({nil, nil}, fn {regex, _area} -> resource =~ regex end)
        area
    end

    area || default
  end

  def try_extrace_ip(resource) do
    case Regex.run(~r/\d+\.\d+\.\d+\.\d+/, resource) do
      [ip] -> {:ok, InetCidr.parse_address!(ip)}
      nil  -> :error
    end
  end

end
