require 'yaml'
require_relative '../../lib/vbucket'

module VBucket
  class Configuration
    attr_reader :auth_file, :vbucket_file_root, :config_path

    def initialize(manual_path_ = nil)
      @config_path = manual_path_ || default_path
      raise VBucket::MissingConfigFile, @config_path unless File.exist? @config_path
      config_data      = YAML.load_file(@config_path)
      @auth_file       = chk_data config_data[:auth_file]
      @vbucket_file_root = chk_data config_data[:vbucket_file_root]
    end

    private

    def default_path
      File.expand_path(File.join(File.dirname(__FILE__), '../../config/config.yaml'))
    end

    def chk_data(data_)
      raise VBucket::MissingConfigData, data_ unless data_
      data_
    end

    #TODO: def valid_root?

  end
end