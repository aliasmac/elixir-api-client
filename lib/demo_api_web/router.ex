defmodule DemoApiWeb.Router do
  use DemoApiWeb, :router

  # plug does transformation on connection object
  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/signin", DemoApiWeb do
    pipe_through :api

    post "/", AuthController, :signin
    post "/mfa", AuthController, :signin_mfa_method
    post "/mfa/verify", AuthController, :signin_mfa_verify
    post "/token", AuthController, :reauthenticate
  end

  scope "/accounts", DemoApiWeb do
    pipe_through :api

    get "/", AccountController, :get_accounts
    get "/:account_id/balances", AccountController, :get_account_balance
    get "/:account_id/transactions", AccountController, :get_account_transactions
    get "/:account_id/details", AccountController, :get_account_details
  end
end
