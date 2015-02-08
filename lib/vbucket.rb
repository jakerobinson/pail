require 'vbucket/version'
require 'vbucket/service'
require 'vbucket/configuration'

module VBucket
  class Exception < StandardError; end

  class MissingConfigData < VBucket::Exception
    def initialize(missing_data_)
      super("The following data is missing from the config file: #{missing_data_}")
    end
  end

  class MissingConfigFile < VBucket::Exception
    def initialize(file_path_)
      super("The config file is missing from path: #{file_path_}")
    end
  end

end
