require_relative '../../spec_helper'

describe 'VBucket::Configuration' do

  before(:each) do
    allow(YAML).to receive(:load_file) {
      {
        auth_file:       'vbucket.keys',
        vbucket_file_root: '/example/vbucket/'
      }
    }
  end

  describe '#new' do

    it 'loads a configuration file' do
      test_config = VBucket::Configuration.new
      expect(test_config.vbucket_file_root).to eq('/example/vbucket/')
    end

    it 'raises an error if required data is missing' do
      allow(YAML).to receive(:load_file) { {auth_file: 'vbucket.keys'} } # Missing vbucket_file_root

      expect { VBucket::Configuration.new }.to raise_error(VBucket::MissingConfigData)
    end

    it 'raises an error if config file is missing' do
      allow(File).to receive(:exist) { false }

      expect { VBucket::Configuration.new('') }.to raise_error(VBucket::MissingConfigFile)
    end

  end
end