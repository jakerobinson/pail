require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/respond_with' #respond with multiple content types
require 'logger'
require 'nokogiri'
require_relative 'configuration'

module VBucket
  class Service < Sinatra::Base

    helpers Sinatra::JSON
    register Sinatra::RespondWith
    configure :production, :development do
      enable :logging
    end

    def initialize(
      config = VBucket::Configuration.new,
      logger = Logger.new(default_log_location)
    )
      super()
      @logger = logger
      @config = config
      @logger.debug "Using Config file: #{@config.config_path}"
      @logger.debug "vBucket File Root: #{@config.share}"

      @share = @config.share
    end

    before do
      log_transaction
    end

    # TODO: Atom response
    get '/', provides: [:json, :html, :xml] do
      files = file_list
      respond_to do |accept|
        accept.xml { xml_file_list files }
        accept.json { json files }
        accept.html { files }
      end
    end

    get '/:filename' do |filename|
      file = File.join(@share, filename)
      halt 404 unless File.exist?(file)
      send_file file, :filename => filename, :type => 'Application/octet-stream'
    end

    head '/:filename' do |filename|
      file = File.join(@share, filename)
      File.exist?(file) ? (status 200) : (halt 404)
      response.headers['Content-Length'] = File.size(file)
    end

    post '/' do
      halt 400 unless params[:file]
      (File.exist? File.join(@share, params[:file][:filename])) ? (status 200) : (status 201)
      File.open(File.join(@share, params[:file][:filename]), 'wb') { |f| f.write(params[:file][:tempfile].read) }
      body nil

      # TODO: post_upload_directive
      # TODO: Do we need to clean up the file if the transfer is unsuccessful?
      # TODO: rescue IO errors
    end

    put('/:filename') do |filename|
      (File.exist? File.join(@share, filename)) ? (status 200) : (status 201)
      File.open(File.join(@share, filename), 'wb') { |file| file.write(request.body.read) }
      body nil

      # TODO: post_upload_directive
      # TODO: PUT Folders or Files into folders (for Gem server use case)
      # TODO: Streaming upload?
    end

    delete '/:filename' do |filename|
      filepath = File.join(@share, filename)
      (File.exist? filepath) ? (File.delete(filepath); status 200) : (status 404)
    end

    private

    def default_log_location
      File.expand_path(File.join(File.dirname(__FILE__), '../../log/vbucket.log'))
    end

    def xml_file_list(files)
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.files {
          files.each do |filename|
            xml.file filename
          end
        }
      end
      builder.to_xml
    end

    def log_transaction
      @logger.debug "#{request.ip} - #{request.request_method} #{request.path} #{request.accept}"
    end

    def file_list
      Dir.glob(File.join(@share, '*')).map { |f| "#{request.url}#{f.split('/').last}" }
    end

  end
end