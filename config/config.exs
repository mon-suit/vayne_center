use Mix.Config

config :cipher, keyphrase:   "00000000000000000000000000000000",
                ivphrase:    "00000000000000000000000000000000",
                magic_token: "vayne"

config :trot, :heartbeat, "/heartbeat"
config :trot, :router, Vayne.Center.Router

config :vayne_center, default_area: :idc_foo
config :vayne_center, areas: [
  idc_foo: %{
    str: [".foo.", "^foo."],
    ip: ["10.1.0.0/16"]
  },
  idc_bar: %{
    str: [".bar.", "^bar."],
    ip: ["10.2.0.0/16", "10.3.0.0/16"]
  }
]

config :vayne_center, falcon_api_user: "root"
config :vayne_center, falcon_api_addr: :first


config :falcon_plus_api, sigs: [
  %{"name" => "root", "sig" => "openfalcon-token"},
]

config :falcon_plus_api, addr: %{
  first:  "http://127.0.0.1:8080",
}
