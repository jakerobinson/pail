require_relative '../../spec_helper'

describe 'VBucket::Service' do

  let(:header) { {'HTTP_AUTHORIZATION' => 'Token 527337312fc400145d75b6d0e3640253', Accept: 'application/json'} }

  def app
    VBucket::Service
  end

  before(:example) do
    allow(File).to receive(:read) { "12345\n67890\nabcde\nghijklmnopqrstuvwxyz" }
    allow(Dir).to receive(:glob) { %w(/srv/files/1.txt /srv/files/2.txt /srv/files/bar /srv/files/baz.jpg /srv/files/foo /srv/files/qux.pdf) }
    allow(YAML).to receive(:load_file) { {auth_file: 'vbucket.keys', vbucket_file_root: '/example/vbucket/'} }
    allow_any_instance_of(VBucket::Service).to receive(:send_file) { 'This is a test' }
  end

  describe 'run' do
    context 'missing config data' do
      it 'shuts down'
      it 'gives a meaningful error message'
    end

  end

  describe 'GET' do

    it 'GETs /' do
      # allow(File).to receive(:read) { "12345\n67890\nabcde\nghijklmnopqrstuvwxyz" }
      # allow(Dir).to receive(:glob) { %w(/srv/files/1.txt /srv/files/2.txt /srv/files/bar /srv/files/baz.jpg /srv/files/foo /srv/files/qux.pdf) }
      # allow(YAML).to receive(:load_file) { {auth_file: 'vbucket.keys', vbucket_file_root: '/example/vbucket/'}}
      # allow_any_instance_of(VBucket::Service).to receive(:send_file) { 'This is a test' }
      allow_any_instance_of(VBucket::Authentication).to receive(:has_permission?) { true }

      get '/', nil, header
      expect(last_response).to be_ok
      expect(last_response.body).to eq('{"files":["http://example.org/1.txt","http://example.org/2.txt","http://example.org/bar","http://example.org/baz.jpg","http://example.org/foo","http://example.org/qux.pdf"]}')
    end

    it 'GETs /:filename' do
      # allow(File).to receive(:read) { "12345\n67890\nabcde\nghijklmnopqrstuvwxyz" }
      #
      # #allow(Dir).to receive(:glob) { %w(/srv/files/1.txt /srv/files/2.txt /srv/files/bar /srv/files/baz.jpg /srv/files/foo /srv/files/qux.pdf) }
      # allow(YAML).to receive(:load_file) { {auth_file: 'vbucket.keys', vbucket_file_root: '/example/vbucket/'}}
      # allow_any_instance_of(VBucket::Service).to receive(:send_file) { 'This is a test' }
      allow_any_instance_of(VBucket::Authentication).to receive(:has_permission?) { true }
      allow(File).to receive(:exist?) { true }

      get '/1.txt', nil, header
      expect(last_response).to be_ok
      expect(Digest::MD5.hexdigest(last_response.body)).to eq('ce114e4501d2f4e2dcea3e17b546f339')
    end

    it 'responds with 404 when file does not exist' do
      # allow(File).to receive(:read) { "12345\n67890\nabcde\nghijklmnopqrstuvwxyz" }
      #
      # #allow(Dir).to receive(:glob) { %w(/srv/files/1.txt /srv/files/2.txt /srv/files/bar /srv/files/baz.jpg /srv/files/foo /srv/files/qux.pdf) }
      # allow(YAML).to receive(:load_file) { {auth_file: 'vbucket.keys', vbucket_file_root: '/example/vbucket/'}}
      # allow_any_instance_of(VBucket::Service).to receive(:send_file) { 'This is a test' }
      allow_any_instance_of(VBucket::Authentication).to receive(:has_permission?) { true }
      allow(File).to receive(:exist?) { false }
      get '/thisShouldBeA404', nil, header
      expect(last_response.status).to eq(404)
    end

    it 'responds with 401 when token is not valid' do
      allow_any_instance_of(VBucket::Authentication).to receive(:has_permission?) { false }

      get '/', nil, header
      expect(last_response.status).to eq(401)
    end

    # This is covered by Rack::Protection::PathTraversal
    # it 'does not allow modifying files outside of vbucket_root' do
    #   get '/../busted.txt', nil, header
    #   expect(last_response.status).to eq(404)
    # end
  end

  describe 'HEAD' do

    # TODO: Mock Rack::File or move this to integration test?
    it 'HEADs /:filename' do
      allow_any_instance_of(VBucket::Authentication).to receive(:has_permission?) { true }
      allow(File).to receive(:exist?) { true }
      head '/1.txt', nil, header
      expect(last_response).to be_ok
      #expect(last_response.header['Content-Length']).to eq('14')
    end

    it 'responds with 404 when file does not exist' do
      allow_any_instance_of(VBucket::Authentication).to receive(:has_permission?) { true }
      allow(File).to receive(:exist?) { false }
      head '/thisShouldBeA404', nil, header
      expect(last_response.status).to eq(404)
    end

    it 'responds with 401 when not authenticated' do
      allow_any_instance_of(VBucket::Authentication).to receive(:has_permission?) { false }

      head '/foo', nil, header
      expect(last_response.status).to eq(401)
    end
  end

  describe 'POST' do

    it 'POSTs file to /' do
      test_file = Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), '../../assets/cat.jpg'), 'image/jpeg', true)
      allow_any_instance_of(VBucket::Authentication).to receive(:has_permission?) { true }
      allow(File).to receive(:exist?) { false }

      post '/cat.jpg', {'file' => test_file}, header
      expect(last_response.status).to eq(201)

    end

    it 'responds with 401 when not authenticated' do
      allow_any_instance_of(VBucket::Authentication).to receive(:has_permission?) { false }

      post '/', nil, header
      expect(last_response.status).to eq(401)
    end
  end

  describe 'PUT' do

    it 'PUTs /:filename' do
      allow_any_instance_of(VBucket::Authentication).to receive(:has_permission?) { true }
      test_file = Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), '../../assets/cat.jpg'), 'image/jpeg', true)
      allow(File).to receive(:exist?) { false }
      allow(File).to receive(:open) { 4607 }

      put '/cat.jpg', {'file' => test_file}, header
      expect(last_response.status).to eq(201)
    end

    it 'responds with 401 when not authenticated' do
      allow_any_instance_of(VBucket::Authentication).to receive(:has_permission?) { false }

      put '/cat.jpg', nil, header
      expect(last_response.status).to eq(401)
    end

  end

  describe 'DELETE' do

    it 'DELETEs /:filename' do
      allow_any_instance_of(VBucket::Authentication).to receive(:has_permission?) { true }
      allow(File).to receive(:exist?) { true }
      allow(File).to receive(:delete) { 1 }

      delete '/cat.jpg', nil, header
      expect(last_response.status).to eq(200)
    end

    it 'responds with 404 when file does not exist'

    it 'responds with 401 when not authenticated' do
      allow_any_instance_of(VBucket::Authentication).to receive(:has_permission?) { false }

      delete '/foo', nil, header
      expect(last_response.status).to eq(401)
    end

  end
end