defmodule DemoApiWeb.AccountController do
  use DemoApiWeb, :controller

  def get_accounts(conn, _params) do
    resp = Account.get_accounts()
    json(conn, resp)
  end

  def get_account_balance(conn, %{ "account_id" => account_id}) do
    resp = Account.get_account_balance(account_id)
    json(conn, resp)
  end

  def get_account_transactions(conn, %{ "account_id" => account_id}) do
    resp = Account.get_account_transactions(account_id)
    json(conn, resp)
  end

  def get_account_details(conn, %{ "account_id" => account_id}) do
    resp = Account.get_account_details(account_id)
    json(conn, resp)
  end

end