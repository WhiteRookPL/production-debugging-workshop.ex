defmodule KV.RestAPI.Web.ErrorViewTest do
  use KV.RestAPI.Web.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views.
  import Phoenix.View

  test "renders 404.json" do
    assert render(KV.RestAPI.Web.ErrorView, "404.json", []) == %{errors: %{detail: "Not found"}}
  end

  test "render 500.json" do
    assert render(KV.RestAPI.Web.ErrorView, "500.json", []) == %{errors: %{detail: "Internal server error"}}
  end

  test "render any other" do
    assert render(KV.RestAPI.Web.ErrorView, "505.json", []) == %{errors: %{detail: "Internal server error"}}
  end
end