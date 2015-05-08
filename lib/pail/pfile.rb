require 'ffi-xattr'

module Pail
  class Pfile
    attr_reader :path

    def initialize(path)
      @path     = path
      @metadata = Xattr.new(@path)
    end

    def add(data)
      data.each do |k, v|
        @metadata.set("user.#{k.to_s}", v)
      end
      true
    end

    def get(key)
      @metadata.get("user.#{key}")
    end

    def list
      list = @metadata.to_hash
      Hash[list.map { |k, v| [k.gsub('user.', '').to_sym, v] }]
    end

    def delete(key)
      @metadata.remove("user.#{key}")
      true
    end
  end
end
