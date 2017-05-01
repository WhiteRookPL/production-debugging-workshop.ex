defmodule KV.RestAPI.Web do
  @moduledoc """
  A module that keeps using definitions for controllers
  and so on.

  This can be used in your application as:

      use KV.RestAPI.Web, :controller
      use KV.RestAPI.Web, :router

  The definitions below will be executed for every
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: KV.RestAPI.Web
      import Plug.Conn
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "lib/kv_rest_api/web/templates", namespace: KV.RestAPI.Web
      import Phoenix.Controller, only: [ get_csrf_token: 0, get_flash: 2, view_module: 1 ]
    end
  end
  @doc """
  When used, dispatch to the appropriate controller etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
