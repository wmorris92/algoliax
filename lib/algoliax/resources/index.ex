defmodule Algoliax.Resources.Index do
  @moduledoc false

  import Algoliax.Utils, only: [index_name: 2, camelize: 1]
  alias Algoliax.{Config, Settings, SettingsStore}

  def ensure_settings(module, settings) do
    index_name = index_name(module, settings)

    case SettingsStore.get_settings(index_name) do
      nil ->
        configure_index(module, settings)
        get_settings(module, settings)

      _ ->
        true
    end
  end

  def get_settings(module, settings) do
    index_name = index_name(module, settings)
    algolia_remote_settings = Config.requests().get_settings(index_name)
    SettingsStore.set_settings(index_name, algolia_remote_settings)
    algolia_remote_settings
  end

  def configure_index(module, settings) do
    index_name = index_name(module, settings)

    algolia_settings =
      Settings.settings()
      |> Enum.into(%{}, fn setting ->
        {camelize(setting), Keyword.get(settings, setting)}
      end)

    Config.requests().configure_index(index_name, algolia_settings)
  end

  def delete_index(module, settings) do
    index_name = index_name(module, settings)
    Config.requests().delete_index(index_name)
  end
end
