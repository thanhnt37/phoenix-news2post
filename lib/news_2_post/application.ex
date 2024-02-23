defmodule News2Post.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      News2PostWeb.Telemetry,
      News2Post.Repo,
      {DNSCluster, query: Application.get_env(:news_2_post, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: News2Post.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: News2Post.Finch},
      # Start a worker by calling: News2Post.Worker.start_link(arg)
      # {News2Post.Worker, arg},
      # Start to serve requests, typically the last entry
      News2PostWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: News2Post.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    News2PostWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
