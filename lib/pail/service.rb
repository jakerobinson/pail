require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/respond_with' #respond with multiple content types
require 'logger'
require 'nokogiri'
require 'fileutils'
require 'find'
require_relative 'configuration'

module Pail
  class Service < Sinatra::Base

    helpers Sinatra::JSON
    register Sinatra::RespondWith
    configure :production, :development do
      enable :logging
    end

    def initialize(
      config = Pail::Configuration.new,
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

    # TODO: RSS support?
    get '/*', provides: [:json, :html, :xml] do
      halt 404 unless path_exist?
      if FileTest.file?(absolute_path)
        send_file absolute_path, :filename => File.basename(absolute_path), :type => 'Application/octet-stream'
      else
        respond_with_file_list
      end
    end

    head '/*' do
      File.exist?(absolute_path) ? (status 200) : (halt 404)
      response.headers['Content-Length'] = File.size(file)
    end

    # Upload a file
    post '/*' do
      halt 400 unless params[:file]
      (File.exist? File.join(@share, params[:splat], params[:file][:filename])) ? (status 200) : (status 201)
      File.open(File.join(@share, params[:splat], params[:file][:filename]), 'wb') { |f| f.write(params[:file][:tempfile].read) }
      pail_file = Pail::Pfile.new(File.join(@share, params[:splat], params[:file][:filename]))
      if params[:metadata]
        metadata = JSON::load(params[:metadata]).to_h
        pail_file.add metadata
      end
      body nil

      # TODO: post_upload_directive
      # TODO: Do we need to clean up the file if the transfer is unsuccessful?
      # TODO: rescue IO errors
    end

    # Create a folder path. When specifying nested paths, any missing folders in that path will be created.
    put('/folder/*') do
      (Dir.exist? File.join(@share, params[:splat])) ? (halt 409) : (status 201)
      FileUtils.mkdir_p File.join(@share, params[:splat])
    end

    # Upload a file to specific file path
    put('/*') do
      (File.exist? absolute_path) ? (status 200) : (status 201)
      File.open(absolute_path, 'wb') { |file| file.write(request.body.read) }
      body nil

      # TODO: Write file metadata? Can I do this with a PUT?
      # TODO: post_upload_directive
      # TODO: PUT Folders or Files into folders (for Gem server use case)
    end

    delete '/*' do
      halt 404 unless path_exist?
      File.delete(absolute_path)
      status 200
    end

    private

    def absolute_path
      @absolute_path ||= File.join(@share, params[:splat])
    end

    def path_exist?
      File.exist?(absolute_path) || File.directory?(absolute_path)
    end

    def default_log_location
      File.expand_path(File.join(File.dirname(__FILE__), '../../log/pail.log'))
    end

    def xml_file_list(file_list)
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.files {
          file_list[:files].each do |filename|
            xml.file filename
          end
        }
      end
      builder.to_xml
    end

    def log_transaction
      @logger.debug "#{request.ip} - #{request.request_method} #{request.path} #{request.accept}"
    end

    def respond_with_file_list
      files = file_list absolute_path
      respond_to do |accept|
        accept.xml { xml_file_list files }
        accept.json { json files }
        accept.html { files.to_s }
      end
    end

    def file_list(path)
      list          = Pail::List.new(path).to_hash
      modified_list = {files: {}, folders: {}}

      list.each do |entity_type, entity_list|
        entity_list.map { |filename,_| modified_list[entity_type][File.join(request.url, filename)] = list[entity_type].delete filename }
      end
      modified_list
    end

  end
end
