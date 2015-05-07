require 'ffi-xattr'

module Pail
  class File

    def initialize(absolute_path)
      @absolute_path = absolute_path
      @metadata = Xattr.new(@absolute_path)
    end

  end
end
