require_relative '../../spec_helper'

describe 'Pail::Service' do

  let(:header) { {'HTTP_AUTHORIZATION' => 'Token 527337312fc400145d75b6d0e3640253', Accept: 'application/json'} }
  let(:file_list) {%w(/example/pail/1.txt /example/pail/2.txt /example/pail/bar /example/pail/baz.jpg /example/pail/foo /example/pail/qux.pdf)}
  def app
    Pail::Service
  end

  before(:example) do
    allow(Dir).to receive(:glob) { file_list }
    allow(YAML).to receive(:load_file) { {share: '/example/pail/'} }
    allow(File).to receive(:exist?).with('/Users/jrobinson/pail/spec/unit/pail/../../assets/cat.jpg') { true }
    allow(File).to receive(:exist?).with('/Users/jrobinson/pail/config/pail.conf') { true }
    allow(File).to receive(:exist?).with('/Users/jrobinson/pail/lib/pail/public') { false }
    allow(File).to receive(:exist?).with('/example/pail/thisShouldBeA404') { false }
    allow(File).to receive(:exist?) { true }
    allow(FileTest).to receive(:file?).with('/example/pail/') { false }
    allow(FileTest).to receive(:file?).with('/example/pail/cat.jpg') { true }
    file_list.each { |file| allow(FileTest).to receive(:file?).with(file) { true } }
    allow_any_instance_of(Pail::Service).to receive(:send_file) { 'This is a test' }
  end

  describe 'run' do
    context 'missing config data' do
      it 'shuts down'
      it 'gives a meaningful error message'
    end

  end

  #TODO: refactor with contexts and subject
  describe 'GET' do

    it 'GETs /' do
      allow(Dir).to receive(:exist?) { true }
      get '/', nil, header
      expect(last_response).to be_ok
      expect(last_response.body).to eq('{"files":["http://example.org/1.txt","http://example.org/2.txt","http://example.org/bar","http://example.org/baz.jpg","http://example.org/foo","http://example.org/qux.pdf"],"folders":[]}')
    end

    it 'GETs /:filename' do
      allow(File).to receive(:exist?) { true }
      allow(Dir).to receive(:exist?) { true }

      get '/1.txt', nil, header
      expect(last_response).to be_ok
      expect(Digest::MD5.hexdigest(last_response.body)).to eq('ce114e4501d2f4e2dcea3e17b546f339')
    end

    it 'responds with 404 when file does not exist' do
      allow(File).to receive(:exist?) { false }
      allow(Dir).to receive(:exist?) { true }

      get '/thisShouldBeA404', nil, header
      expect(last_response.status).to eq(404)
    end

    # This is covered by Rack::Protection::PathTraversal
    # it 'does not allow modifying files outside of share' do
    #   get '/../busted.txt', nil, header
    #   expect(last_response.status).to eq(404)
    # end
  end

  describe 'HEAD' do

    # TODO: Mock Rack::File or move this to integration test?
    it 'HEADs /:filename' do
      allow(File).to receive(:exist?) { true }
      allow(Dir).to receive(:exist?) { true }
      head '/1.txt', nil, header
      expect(last_response).to be_ok
      #expect(last_response.header['Content-Length']).to eq('14')
    end

    it 'responds with 404 when file does not exist' do
      allow(File).to receive(:exist?) { false }
      allow(Dir).to receive(:exist?) { true }
      head '/thisShouldBeA404', nil, header
      expect(last_response.status).to eq(404)
    end
  end

  describe 'POST' do

    # # # This test is not working due to params not being passed. post using curl works fine.
    # it 'POSTs file to /' do
    #   test_file = Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), '../../assets/cat.jpg'), 'image/jpeg', true)
    #   allow_any_instance_of(Pail::Authentication).to receive(:has_permission?) { true }
    #   allow(File).to receive(:exist?).with(/\/example\/pail\/var\/folders\/.*/) { false }
    #   allow(File).to receive(:open)
    #
    #   post '/', {'file' => test_file}, header
    #   expect(last_response.status).to eq(201)
    # end

    it 'responds with 400 when missing data'

  end

  describe 'PUT' do

    it 'PUTs /:filename' do
      test_file = Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), '../../assets/cat.jpg'), 'image/jpeg', true)
      allow(File).to receive(:exist?).with('/example/pail/cat.jpg') { false }
      allow(Dir).to receive(:exist?) { true }
      allow(File).to receive(:open) { 4607 }

      put '/cat.jpg', {'file' => test_file}, header
      expect(last_response.status).to eq(201)
    end
  end

  describe 'DELETE' do

    it 'DELETEs /:filename' do
      allow(File).to receive(:exist?) { true }
      allow(File).to receive(:delete) { 1 }

      delete '/cat.jpg', nil, header
      expect(last_response.status).to eq(200)
    end

    it 'responds with 404 when file does not exist' do
      allow(File).to receive(:exist?) { false }

      delete '/foo', nil, header
      expect(last_response.status).to eq(404)
    end

  end
end