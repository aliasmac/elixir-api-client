defmodule DemoApiWeb.AuthController do
  use DemoApiWeb, :controller

  def signin(conn, %{
    "username" => username,
    "password" => password
  }) do
    Credentials.add("username", username)
    Credentials.add("device-id", get_req_header(conn, "device-id") |> hd())
    Credentials.add("api-key", get_req_header(conn, "api-key") |> hd())
    resp = Auth.signin(password)
    json(conn, resp)
  end

  def signin_mfa_method(conn, %{
    "device_id" => device_id,
  }) do
    resp = Auth.select_mfa_method(device_id)
    json(conn, resp)
  end


  def signin_mfa_verify(conn, %{
    "code" => code
  }) do
    resp = Auth.verify_mfa(code)
    json(conn, resp)
  end

  def reauthenticate(conn, _params) do
    resp = Auth.reauthenticate()
    json(conn, resp)
  end
end