require 'sinatra/base'
require 'sinatra/json'
require 'rack/ssl'
#require 'sinatra/respond_with' #respond with multiple content types
require 'logger'
require_relative '../vbucket/configuration'
require_relative '../vbucket/authentication'

module VBucket
  class Service < Sinatra::Base
    #use Rack::SSL #TODO: uncomment when web server is set up with SSL
    helpers Sinatra::JSON
    #helpers Sinatra::RespondWith #TODO: xml, atom support
    configure :production, :development do
      enable :logging
    end

    def initialize(config = VBucket::Configuration.new, logger = Logger.new(default_log_location))
      super()
      @logger = logger
      @config = config
      @logger.debug "Using Config file: #{@config.config_path}"
      @logger.debug "Using Auth file: #{@config.auth_file}"
      @logger.debug "vBucket File Root: #{@config.vbucket_file_root}"

      @auth = VBucket::Authentication.new(@config.auth_file)
      @logger.debug "Loaded [#{@auth.key_count}] authentication keys."

      @vbucket_root = @config.vbucket_file_root
    end

    def default_log_location
      File.expand_path(File.join(File.dirname(__FILE__), '../../log/vbucket.log'))
    end

    before do
      log_transaction
      halt 401 unless @auth.has_permission? auth_token
    end

    get '/' do #:provides => [:json, :xml, :atom] do
      files = Dir.glob(File.join(@vbucket_root, '*')).map { |f| "#{request.url}#{f.split('/').last}" }
      #respond_with files
      json :files => files
      #TODO: XML support
      #TODO: Content type
    end

    get '/:filename' do |filename|
      file = File.join(@vbucket_root, filename)
      halt 404 unless File.exist?(file)
      send_file file, :filename => filename, :type => 'Application/octet-stream'
    end

    head '/:filename' do |filename|
      file = File.join(@vbucket_root, filename)
      halt 404 unless File.exist?(file)
      send_file file, :filename => filename, :type => 'Application/octet-stream'
    end

    post '/' do
      (File.exist? File.join(@vbucket_root, filename)) ? (status 200) : (status 201)
      File.open(File.join(@vbucket_root, params[:file][:tempfile]), 'wb') { |f| f.write(params[:file][:tempfile].read) }
      body nil

      # TODO: We need to clean up the file if the transfer is unsuccessful
      # TODO: rescue IO errors
    end

    put('/:filename') do |filename|
      (File.exist? File.join(@vbucket_root, filename)) ? (status 200) : (status 201)
      File.open(File.join(@vbucket_root, filename), 'wb') { |f| f.write(params[:file][:tempfile].read) }
      body nil

      # TODO: PUT Folders?
      # TODO: Streaming upload?
      # TODO: We need to clean up the file if the transfer is unsuccessful
    end

    delete '/:filename' do |filename|
      (File.exist? File.join(@vbucket_root, filename)) ? (status 200) : (status 404)
      File.delete(File.join(@vbucket_root, filename))
    end

    private

    def auth_token
      auth_header = request.env['HTTP_AUTHORIZATION'] || ''
      auth_header.split.last
    end

    def log_transaction
      @logger.debug "#{request.ip} - #{request.request_method} #{request.path} #{request.accept}"
    end

  end
end