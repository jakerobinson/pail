module VBucket
  class Authentication

    def initialize(auth_file_path_)
      # TODO: ReadOnly, WriteOnly keyfiles?
      @keys = File.read(auth_file_path_).split("\n")
      @keys.delete_if {|x| x =~ /.*\s.*/}
    end

    def has_permission?(key_)
      @keys.include? key_
    end

    def key_count
      @keys.count
    end

  end
end
