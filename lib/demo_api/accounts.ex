defmodule Account do
  use DemoApiWeb, :controller

  @base_url "https://test.demo.engineering"

  def get_accounts() do
    # Couldn't find endpoint for `/accounts` so using `/signin/token`.
    with \
      body <- Jason.encode!(%{ token: Credentials.get("a-token") }),
      headers <- Helpers.get_base_headers()
    do
      case HTTPoison.post!("#{@base_url}/signin/token", body, headers) do
        %{status_code: 200, body: body, headers: resp_headers} ->
          handle_accounts_resp(body, resp_headers) 
        %{status_code: 404, body: body, headers: _resp_headers} ->
          Jason.decode!(body)
        %{status_code: _status_code, body: body, headers: _resp_headers} ->
          Jason.decode!(body)
      end
    else
      {:req, _} -> %{error: "unknown error"}
    end
  end


  def handle_accounts_resp(body, _resp_headers) do
    Jason.decode!(body)
  end


  def get_account_balance(account_id) do
    with \
      headers <- Helpers.get_reauthenticated_headers()
    do
      case HTTPoison.get!("#{@base_url}/accounts/#{account_id}/balances", headers) do
        %{status_code: 200, body: body, headers: resp_headers} ->
          handle_account_balance_resp(body, resp_headers) 
        %{status_code: 404, body: body, headers: _resp_headers} ->
          Jason.decode!(body)
        %{status_code: _status_code, body: body, headers: _resp_headers} ->
          Jason.decode!(body)
      end
    else
      {:req, _} -> %{error: "unknown error"}
    end
  end

  def handle_account_balance_resp(body, resp_headers) do
    headers = Enum.into resp_headers, %{}
    Credentials.add("last-request-id", headers["f-request-id"])
    Credentials.add("r-token", headers["r-token"])
    Credentials.add("f-token", Helpers.get_f_token_from_spec(headers["f-token-spec"]))

    Jason.decode!(body)
  end


  def get_account_transactions(account_id) do
    with \
      headers <- Helpers.get_reauthenticated_headers()
    do
      case HTTPoison.get!("#{@base_url}/accounts/#{account_id}/transactions", headers) do
        %{status_code: 200, body: body, headers: resp_headers} ->
          handle_account_transaction_resp(body, resp_headers) 
        %{status_code: 404, body: body, headers: _resp_headers} ->
          Jason.decode!(body)
        %{status_code: _status_code, body: body, headers: _resp_headers} ->
          Jason.decode!(body)
      end
    else
      {:req, _} -> %{error: "unknown error"}
    end
  end

  def handle_account_transaction_resp(body, resp_headers) do
    headers = Enum.into resp_headers, %{}
    Credentials.add("last-request-id", headers["f-request-id"])
    Credentials.add("r-token", headers["r-token"])
    Credentials.add("f-token", Helpers.get_f_token_from_spec(headers["f-token-spec"]))

    Jason.decode!(body)
  end

  def get_account_details(account_id) do
    # Seems to follow logical UI flow where user would first go to
    # see balance before being allowed to see account details ¯\_(ツ)_/¯.
    get_account_balance(account_id)

    with \
      headers <- Helpers.get_reauthenticated_headers()
    do
      case HTTPoison.get!("#{@base_url}/accounts/#{account_id}/details", headers) do
        %{status_code: 200, body: body, headers: resp_headers} ->
          handle_account_detail_resp(body, resp_headers) 
        %{status_code: 404, body: body, headers: _resp_headers} ->
          Jason.decode!(body)
        %{status_code: _status_code, body: body, headers: _resp_headers} ->
          Jason.decode!(body)
      end
    else
      {:req, _} -> %{error: "unknown error"}
    end
  end

  def handle_account_detail_resp(body, _resp_headers) do
    decoded_body = Jason.decode!(body)
    %{decoded_body | "number" => Helpers.decrypt_account_number(body)}
  end

end
