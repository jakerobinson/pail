require 'pail/version'
require 'pail/service'
require 'pail/configuration'

module Pail
  class Exception < StandardError; end

  class MissingConfigData < Pail::Exception
    def initialize(missing_data_)
      super("The following data is missing from the config file: #{missing_data_}")
    end
  end

  class MissingConfigFile < Pail::Exception
    def initialize(file_path_)
      super("The config file is missing from path: #{file_path_}")
    end
  end

  class CannotAccessShare < Pail::Exception
    def initialize(file_path_)
      super("Directory does not exist or permissions issue: #{file_path_}")
    end
  end

end
