defmodule B1Web.Router do
  use B1Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {B1Web.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/hangman", B1Web do
    pipe_through :browser

    get "/", HangmanController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", B1Web do
  #   pipe_through :api
  # end
end
