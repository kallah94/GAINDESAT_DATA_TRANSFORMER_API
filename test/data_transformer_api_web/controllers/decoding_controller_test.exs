defmodule DataTransformerApiWeb.DecodingControllerTest do
  use DataTransformerApiWeb.ConnCase

  alias DataTransformerApi.Decoders
  alias DataTransformerApi.Decoders.Decoding

  @create_attrs %{

  }
  @update_attrs %{

  }
  @invalid_attrs %{}

  def fixture(:decoding) do
    {:ok, decoding} = Decoders.create_decoding(@create_attrs)
    decoding
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all decodings", %{conn: conn} do
      conn = get(conn, Routes.decoding_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create decoding" do
    test "renders decoding when data is valid", %{conn: conn} do
      conn = post(conn, Routes.decoding_path(conn, :create), decoding: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.decoding_path(conn, :show, id))

      assert %{
               "id" => id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.decoding_path(conn, :create), decoding: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update decoding" do
    setup [:create_decoding]

    test "renders decoding when data is valid", %{conn: conn, decoding: %Decoding{id: id} = decoding} do
      conn = put(conn, Routes.decoding_path(conn, :update, decoding), decoding: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.decoding_path(conn, :show, id))

      assert %{
               "id" => id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, decoding: decoding} do
      conn = put(conn, Routes.decoding_path(conn, :update, decoding), decoding: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete decoding" do
    setup [:create_decoding]

    test "deletes chosen decoding", %{conn: conn, decoding: decoding} do
      conn = delete(conn, Routes.decoding_path(conn, :delete, decoding))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.decoding_path(conn, :show, decoding))
      end
    end
  end

  defp create_decoding(_) do
    decoding = fixture(:decoding)
    %{decoding: decoding}
  end
end
