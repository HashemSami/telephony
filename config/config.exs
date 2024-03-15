import Config

config :mix_test_watch,
  cli_executable: "elixir --erl \"-elixir ansi_enabled true\" -S mix"
