require_relative '../../spec_helper'

describe 'VBucket::Service' do

  before(:example) do
    @mock_config = double
    @mock_auth   = double
    @mock_logger = double
    allow(Dir).to receive(:glob) { %w(/srv/files/1.txt /srv/files/2.txt /srv/files/bar /srv/files/baz.jpg /srv/files/foo /srv/files/qux.pdf) }

    allow(@mock_config).to receive(:vbucket_file_root) { '/srv/files/' }
    allow(@mock_config).to receive(:config_path) { '/srv/files/' }
    allow(@mock_config).to receive(:auth_file) { '/foo/bar/vbucket.keys' }
    allow(@mock_auth).to receive(:key_count) { 5 }
    allow(@mock_auth).to receive(:has_permission?).with('SomeBadToken') { false }
    allow(@mock_auth).to receive(:has_permission?).with('527337312fc400145d75b6d0e3640253') { true }
    allow(@mock_auth).to receive(:has_permission?).with(nil) { false }
    allow(VBucket::Configuration).to receive(:new) { @mock_config }
    allow(VBucket::Authentication).to receive(:new) { @mock_auth }
    #allow(any_instance_of(VBucket::Configuration)).to receive(:initialize) { mock_config }
    VBucket::Service.any_instance.stub(:send_file) { 'This is a test' }
  end

  let(:header) { {'HTTP_AUTHORIZATION' => 'Token 527337312fc400145d75b6d0e3640253', Accept: 'application/json'} }

  def app
    VBucket::Service
  end

  describe 'GET' do

    it 'GETs /' do
      get '/', nil, header
      expect(last_response).to be_ok
      expect(last_response.body).to eq('{"files":["http://example.org/1.txt","http://example.org/2.txt","http://example.org/bar","http://example.org/baz.jpg","http://example.org/foo","http://example.org/qux.pdf"]}')
    end

    it 'GETs /:filename' do
      get '/1.txt', nil, header
      expect(last_response).to be_ok
      expect(Digest::MD5.hexdigest(last_response.body)).to eq('ce114e4501d2f4e2dcea3e17b546f339')
    end

    it 'responds with 404 when file does not exist' do
      get '/thisShouldBeA404', nil, header
      expect(last_response.status).to eq(404)
    end

    it 'responds with 401 when token is not valid' do
      get '/', nil, {'HTTP_AUTHORIZATION' => 'Token SomeBadToken', Accept: 'application/json'}
      expect(last_response.status).to eq(401)
    end

    it 'responds with 401 when missing Authorization header' do
      get '/', nil, {Accept: 'application/json'} # No Authorization header here, which with cause 401
      expect(last_response.status).to eq(401)
    end


    # This is covered by Rack::Protection::PathTraversal
    # Need to probably Rack::File if I want to do this test
    # it 'does not allow modifying files outside of vbucket_root' do
    #   get '/../busted.txt', nil, header
    #   expect(last_response.status).to eq(404)
    # end
  end

  describe 'HEAD' do

    # TODO: Mock Rack::File or move this to integration test?
    it 'HEADs /:filename' do
      head '/1.txt', nil, header
      expect(last_response).to be_ok
      expect(last_response.header['Content-Length']).to eq('14')
    end

    it 'responds with 404 when file does not exist' do
      head '/thisShouldBeA404', nil, header
      expect(last_response.status).to eq(404)
    end

    it 'responds with 401 when not authenticated' do
      head '/foo', nil, {'HTTP_AUTHORIZATION' => 'Token SomeBadToken', Accept: 'application/json'}
      expect(last_response.status).to eq(401)
    end
  end

  describe 'POST' do

    # it 'POSTs file to /' do
    #   pending
    # end

    it 'responds with 401 when not authenticated' do
      post '/', nil, {'HTTP_AUTHORIZATION' => 'Token SomeBadToken', Accept: 'application/json'}
      expect(last_response.status).to eq(401)
    end
  end

  describe 'PUT' do

    it 'PUTs /:filename' do
      testFile = Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), '../../assets/cat.jpg'), 'image/jpeg', true)
      File.stub(:exist?) { false }
      File.stub(:open) { 4607 }

      put '/cat.jpg', {'file' => testFile}, header
      expect(last_response.status).to eq(201)
    end

    it 'responds with 401 when not authenticated' do
      put '/cat.jpg', nil, {'HTTP_AUTHORIZATION' => 'Token SomeBadToken', Accept: 'application/json'}
      expect(last_response.status).to eq(401)
    end

  end

  describe 'DELETE' do

    it 'DELETEs /:filename' do
      allow(File).to receive(:delete) { 1 }

      delete '/cat.jpg', nil, header
      expect(last_response.status).to eq(200)
    end

    it 'responds with 404 when file does not exist' do
      pending
    end

    it 'responds with 401 when not authenticated' do
      delete '/foo', nil, {'HTTP_AUTHORIZATION' => 'Token SomeBadToken', Accept: 'application/json'}
      expect(last_response.status).to eq(401)
    end

  end
end