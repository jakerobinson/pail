require 'json'

module Pail
  class List
    attr_reader :path

    def initialize(path)
      raise "The path: #{path} is not a valid directory" unless Dir.exist? path
      @path = path
    end

    def files
      f = dir.select { |entity| FileTest.file? entity }
      pfiles = {}
      f.each do |entity_path|
        pfile = Pail::Pfile.new(entity_path)
        pfiles[File.basename entity_path] = pfile.list
      end
      pfiles
    end

    def folders
      f_hash = {}
      f = dir.select { |entity| FileTest.directory? entity }
      f.map { |f| f_hash[File.basename f] = nil }
      f_hash
    end

    def to_hash
      {:files => self.files, :folders => self.folders}
    end

    def to_json
      self.to_hash.to_json
    end

    private

    def dir
      @dir ||= Dir.glob(File.join(@path, '*'))
    end

  end
end