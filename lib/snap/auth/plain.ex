defmodule Snap.Auth.Plain do
  @moduledoc """
  Implements HTTP Basic Auth, if necessary.

  If the cluster config defines a username and password, an `Authorization:
  Basic` header is added to the request.

  ```
  config :my_app, MyApp.Cluster,
    url: "http://localhost:9200",
    username: "foo",
    password: "bar
  ```

  If no username or password is defined, no `Authorization` header is added,
  making it suitable for local development.
  """
  @behaviour Snap.Auth

  def sign(config, method, path, headers, body) do
    with {:ok, username} when is_binary(username) <- Keyword.fetch(config, :username),
         {:ok, password} when is_binary(password) <- Keyword.fetch(config, :password) do
      auth_headers = [{"Authorization", encode_header(username, password)}]

      new_headers = headers ++ auth_headers

      {:ok, {method, path, new_headers, body}}
    else
      _ -> {:ok, {method, path, headers, body}}
    end
  end

  defp encode_header(username, password) do
    body = username <> ":" <> password

    "Basic " <> Base.encode64(body)
  end
end
