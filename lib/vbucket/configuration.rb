require 'yaml'
require_relative '../../lib/vbucket'

module VBucket
  class Configuration
    attr_reader :share, :config_path

    def initialize(path_ = default_path)
      @config_path = path_ || default_path
      raise VBucket::MissingConfigFile, @config_path unless File.exist? @config_path
      config_data      = YAML.load_file(@config_path)
      @share = chk_data config_data[:share]
      raise VBucket::CannotAccessShare, @share unless share_exist?(@share)
    end

    private

    def default_path
      File.expand_path(File.join(File.dirname(__FILE__), '../../config/vbucket.conf'))
    end

    def chk_data(data_)
      raise VBucket::MissingConfigData, data_ unless data_
      data_
    end

    def share_exist?(path_)
      Dir.exist? path_
    end

  end
end