# frozen_string_literal: true

require "yaml"

module Bot
  module DefaultConfig
    PREFIX = "!"
    USERNAME = "TfLBot"
    GAME = nil
    PR_ANNOUNCE_CHANNELS_IDS = [].freeze
    METRICS_PORT = nil
  end

  class Config
    def load_config(config_file)
      return if config_loaded

      cfg = YAML.load_file(config_file)

      @prefix = config(cfg, "command_prefix", prefix)
      @username = config(cfg, "username", username)
      @game = config(cfg, "game", game)
      @pr_announce_channels_ids = config(cfg, "pr_announce_channels_ids", [])

      @metrics_port = config(cfg, "metrics_port", nil)
      @metrics_port = @metrics_port.to_i unless @metrics_port.nil?

      @config_loaded = true
    end

    def config_loaded
      @config_loaded ||= false
    end

    def prefix
      @prefix ||= DefaultConfig::PREFIX
    end

    def username
      @username ||= DefaultConfig::USERNAME
    end

    def game
      @game ||= DefaultConfig::GAME
    end

    def pr_announce_channels_ids
      @pr_announce_channels_ids ||= DefaultConfig::PR_ANNOUNCE_CHANNELS_IDS
    end

    def metrics_port
      @metrics_port ||= DefaultConfig::METRICS_PORT
    end

    private

    def config(cfg, key, default)
      if cfg.key?(key) && !cfg[key].nil?
        cfg[key]
      else
        default
      end
    end
  end
end
