require_relative '../../spec_helper'

describe 'VBucket::Configuration' do

  before(:each) do
    allow(YAML).to receive(:load_file) {
      {
        auth_file: 'vbucket.keys',
        share:     '/example/vbucket/'
      }
    }
  end

  describe '#new' do
    #TODO: refactor using rspec subject and contexts

    it 'loads a configuration file' do
      allow(Dir).to receive(:exist?).with('/example/vbucket/') { true }
      test_config = VBucket::Configuration.new
      expect(test_config.share).to eq('/example/vbucket/')
    end

    it 'raises exception if dir does not exist' do
      allow(Dir).to receive(:exist?).with('/example/vbucket/') { false }
      expect { VBucket::Configuration.new }.to raise_error(VBucket::CannotAccessShare)
    end

    it 'raises an error if required data is missing' do
      allow(YAML).to receive(:load_file) { {auth_file: 'vbucket.keys'} } # Missing share

      expect { VBucket::Configuration.new }.to raise_error(VBucket::MissingConfigData)
    end

    it 'raises an error if config file is missing' do
      allow(File).to receive(:exist?) { false }

      expect { VBucket::Configuration.new('') }.to raise_error(VBucket::MissingConfigFile)
    end

  end
end