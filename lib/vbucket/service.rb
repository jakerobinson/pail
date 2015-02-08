require 'sinatra/base'
require 'sinatra/json'
#require 'rack/ssl'
require 'sinatra/respond_with' #respond with multiple content types
require 'logger'
require 'nokogiri'
require_relative 'configuration'

module VBucket
  class Service < Sinatra::Base
    #use Rack::SSL #TODO: uncomment when web server is set up with SSL
    helpers Sinatra::JSON
    register Sinatra::RespondWith #TODO: xml, atom support
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
      @logger.debug "vBucket File Root: #{@config.vbucket_file_root}"

      @vbucket_root = @config.vbucket_file_root
    end

    before do
      log_transaction
    end

    get '/' do
      files = Dir.glob(File.join(@vbucket_root, '*')).map { |f| "#{request.url}#{f.split('/').last}" }
      respond_to do |accept|
        accept.xml { xml_file_list files }
        accept.json { json files }
      end
    end

    get '/:filename' do |filename|
      file = File.join(@vbucket_root, filename)
      halt 404 unless File.exist?(file)
      send_file file, :filename => filename, :type => 'Application/octet-stream'
    end

    head '/:filename' do |filename|
      file = File.join(@vbucket_root, filename)
      File.exist?(file) ? (status 200) : (halt 404)
      response.headers['Content-Length'] = File.size(file)
    end

    post '/' do
      (File.exist? File.join(@vbucket_root, params[:file][:filename])) ? (status 200) : (status 201)
      File.open(File.join(@vbucket_root, params[:file][:filename]), 'wb') { |f| f.write(params[:file][:tempfile].read) }
      body nil

      # TODO: Do we need to clean up the file if the transfer is unsuccessful?
      # TODO: rescue IO errors
    end

    put('/:filename') do |filename|
      (File.exist? File.join(@vbucket_root, filename)) ? (status 200) : (status 201)
      File.open(File.join(@vbucket_root, filename), 'wb') { |file| file.write(request.body.read) }
      body nil

      # TODO: PUT Folders? Current thought is no.
      # TODO: Streaming upload?
      # TODO: Do we need to clean up the file if the transfer is unsuccessful?
    end

    delete '/:filename' do |filename|
      filepath = File.join(@vbucket_root, filename)
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

  end
end