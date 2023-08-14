defmodule Auth do
  use DemoApiWeb, :controller

  @base_url "https://test.demo.engineering"

  def signin(password) do
    with \
      body <- Jason.encode!(%{ username: Credentials.get("username"), password: password }),
      headers <- Helpers.get_base_headers()
    do
      case HTTPoison.post!("#{@base_url}/signin", body, headers) do
        %{status_code: 200, body: body, headers: resp_headers} ->
          handle_signin_resp(body, resp_headers) 
        %{status_code: 404, body: body, headers: _resp_headers} ->
          Jason.decode!(body)
        %{status_code: _status_code, body: body, headers: _resp_headers} ->
          Jason.decode!(body)
      end
    else
      {:req, _} -> %{error: "unknown error"}
    end

  end

  def handle_signin_resp(body, resp_headerss) do
    headers = Enum.into resp_headerss, %{}
    Credentials.add("last-request-id", headers["f-request-id"])
    Credentials.add("r-token", headers["r-token"])
    Credentials.add("f-token", Helpers.get_f_token_from_spec(headers["f-token-spec"]))

    Jason.decode!(body)
  end


  def select_mfa_method(device_id) do
    with \
      body <- Jason.encode!(%{  device_id: device_id }),
      headers <- Helpers.get_mfa_headers()
    do
      case HTTPoison.post!("#{@base_url}/signin/mfa", body, headers) do
        %{status_code: 200, body: body, headers: resp_headers} ->
          handle_mfa_resp(body, resp_headers) 
        %{status_code: 404, body: body, headers: _resp_headers} ->
          Jason.decode!(body)
        %{status_code: _status_code, body: body, headers: _resp_headers} ->
          Jason.decode!(body)
      end
    else
      {:req, _} -> %{error: "unknown error"}
    end
  end

  def handle_mfa_resp(_body, resp_headerss) do
    headers = Enum.into resp_headerss, %{}
    Credentials.add("last-request-id", headers["f-request-id"])
    Credentials.add("r-token", headers["r-token"])
    Credentials.add("f-token", Helpers.get_f_token_from_spec(headers["f-token-spec"]))

    # Since no data returned, using the hard coded value
    %{ code: "123456" }
  end


  def verify_mfa(code) do
    with \
      body <- Jason.encode!(%{ code: code }),
      headers <- Helpers.get_mfa_headers()
    do
      case HTTPoison.post!("#{@base_url}/signin/mfa/verify", body, headers) do
        %{status_code: 200, body: body, headers: resp_headers} ->
          handle_mfa_verify_resp(body, resp_headers) 
        %{status_code: 404, body: body, headers: _resp_headers} ->
          Jason.decode!(body)
        %{status_code: _status_code, body: body, headers: _resp_headers} ->
          Jason.decode!(body)
      end
    else
      {:req, _} -> %{error: "unknown error"}
    end
  end

  defp handle_mfa_verify_resp(body, _resp_headers) do
    Credentials.add("a-token", Jason.decode!(body)["data"]["a_token"])
    Credentials.add("enc-key", Helpers.parseEncryptionKey(body))

    Jason.decode!(body)
  end

  def reauthenticate do
    with \
      body <- Jason.encode!(%{ token: Credentials.get("a-token") }),
      headers <- Helpers.get_mfa_headers()
    do
      case HTTPoison.post!("#{@base_url}/signin/token", body, headers) do
        %{status_code: 200, body: body, headers: resp_headers} ->
          handle_reauthenticate_resp(body, resp_headers) 
        %{status_code: 404, body: body, headers: _resp_headers} ->
          Jason.decode!(body)
        %{status_code: _status_code, body: body, headers: _resp_headers} ->
          Jason.decode!(body)
      end
    else
      {:req, _} -> %{error: "unknown error"}
    end
  end

  def handle_reauthenticate_resp(body, resp_headers) do
    headers = Enum.into resp_headers, %{}
    Credentials.add("a-token", Jason.decode!(body)["data"]["a_token"])
    Credentials.add("enc-key", Helpers.parseEncryptionKey(body))
    Credentials.add("s-token", headers["s-token"])
    Credentials.add("last-request-id", headers["f-request-id"])
    Credentials.add("r-token", headers["r-token"])
    Credentials.add("f-token", Helpers.get_f_token_from_spec(headers["f-token-spec"]))

    Jason.decode!(body)
  end
end
