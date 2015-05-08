module Pail
  class List
    attr_reader :path

    def initialize(path)
      raise "The path: #{path} is not a valid directory" unless File.directory? path
      @path = path
    end

    def files
      files = dir.select { |entity| FileTest.file? entity }
      pfiles = {}
      files.each do |entity_path|
        pfile = Pail::Pfile.new(entity_path)
        pfiles[File.basename entity_path] = pfile.list
      end
      pfiles
    end

    def folders
      folders = dir.select { |entity| FileTest.directory? entity }
      folders.map { |f| File.basename f }
    end

    private

    def dir
      @dir ||= Dir.glob(File.join(@path, '*'))
    end

  end
end