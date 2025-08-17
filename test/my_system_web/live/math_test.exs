defmodule MySystemWeb.MathTest do
  use MySystemWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  describe "math" do
    test "it works", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert view |> element("form") |> render_submit(number: 5) =~ "∑(1..5) = calculating"
    end
  end

  describe "telemetry" do
    # TODO: Implement tests
    test "stub" do
      assert false
    end
  end
end
