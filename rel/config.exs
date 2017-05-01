use Mix.Releases.Config,
  default_release: :default,
  default_environment: Mix.env()

cookie_dev = :dev
environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: cookie_dev
  set overlay_vars: [ cookie: cookie_dev ]
  set vm_args: "rel/vm.args"
end

cookie_prod = :"HardCoreCookieForProductionMode"
environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: cookie_prod
  set overlay_vars: [ cookie: cookie_prod ]
  set vm_args: "rel/vm.args"
end

release :production_debugging_workshop_ex do
  set version: "1.0.0"
  set applications: [
    runtime_tools: :permanent,
    sasl: :permanent,
    kv: :permanent,
    kv_map_reduce: :permanent,
    kv_persistence: :permanent,
    kv_rest_api: :permanent,
    kv_server: :permanent,
    xprof: :permanent,
    recon: :permanent,
    eper: :permanent,
    dbg: :permanent
  ]
end