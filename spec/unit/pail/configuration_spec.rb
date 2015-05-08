require_relative '../../spec_helper'

describe 'Pail::Configuration' do

  before(:each) do
    allow(YAML).to receive(:load_file) {
      {
        share:     '/example/pail/'
      }
    }
  end

  describe '#new' do
    #TODO: refactor using rspec subject and contexts

    it 'loads a configuration file' do
      allow(Dir).to receive(:exist?).with('/example/pail/') { true }
      test_config = Pail::Configuration.new
      expect(test_config.share).to eq('/example/pail/')
    end

    it 'raises exception if dir does not exist' do
      allow(Dir).to receive(:exist?).with('/example/pail/') { false }
      expect { Pail::Configuration.new }.to raise_error(Pail::CannotAccessShare)
    end

    it 'raises an error if config file is missing' do
      allow(File).to receive(:exist?) { false }

      expect { Pail::Configuration.new('') }.to raise_error(Pail::MissingConfigFile)
    end

  end
end