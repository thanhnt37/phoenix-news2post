defmodule News2PostWeb.Router do
  use News2PostWeb, :router

  import News2PostWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {News2PostWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated_api do
    plug ExOauth2Provider.Plug.VerifyHeader, otp_app: :news_2_post, realm: "Bearer"
    plug ExOauth2Provider.Plug.EnsureAuthenticated, typ: "access"
  end

  scope "/", News2PostWeb do
    pipe_through :browser

  end

  scope "/oauth", News2PostWeb do
    pipe_through :api
    post "/token", OAuthController, :grant_token
  end

  scope "/oauth", News2PostWeb do
    pipe_through [:api, :authenticated_api]
    post "/app", OAuthController, :create_application
  end

  # Other scopes may use custom stacks.
   scope "/api", News2PostWeb do
     pipe_through [:api, :authenticated_api]

     get "/v1/posts", ApiController, :get_posts
     post "/v1/posts", ApiController, :create_post
     get "/v1/posts/:sk", ApiController, :show_post

     get "/v1/news", ApiController, :get_news
     post "/v1/news", ApiController, :create_news
     get "/v1/news/:sk", ApiController, :show_news
   end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:news_2_post, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: News2PostWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", News2PostWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", News2PostWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/", DashboardController, :index

    get "/news", NewsController, :index
    get "/news/new", NewsController, :new
    get "/news/:sk", NewsController, :show
    post "/news", NewsController, :create
    put "/news/:sk/re-write", NewsController, :re_write

    get "/posts", PostController, :index
    get "/posts/:sk", PostController, :show
    get "/posts/:sk/edit", PostController, :edit
    patch "/posts/:sk", PostController, :update
    put "/posts/:sk", PostController, :update
    delete "/posts/:sk", PostController, :delete
    put "/posts/:sk/approve", PostController, :approve
    put "/posts/:sk/publish", PostController, :publish

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email
  end

  scope "/", News2PostWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :edit
    post "/users/confirm/:token", UserConfirmationController, :update
  end

  scope "/", News2PostWeb do
    pipe_through [:browser, :require_authenticated_admin_user]

    resources "/users", UserController

    get "/configs", ConfigsController, :edit
    put "/configs", ConfigsController, :update
  end

end
