require_relative '../../spec_helper'

describe 'Pail::List' do
  let(:path) { File.join(File.dirname(__FILE__), '../../assets/') }
  let(:bad_path) { '/foo/bar/baz/' }

  context 'invalid path' do
    it 'raises error on bad path' do
      expect { Pail::List.new(bad_path) }.to raise_error(RuntimeError, 'The path: /foo/bar/baz/ is not a valid directory')
    end
  end

  context 'valid path' do
    subject(:pail_list) { Pail::List.new path }

    describe '#path' do
      it 'returns the path' do
        expect(pail_list.path).to include('/assets/')
      end
    end

    describe '#files' do
      it 'returns a hash' do
        expect(pail_list.files).to be_a Hash
      end

      it 'contains a list of files' do
        expect(pail_list.files.keys).to include('cat.jpg')
      end
    end

    describe '#folders' do
      it 'returns an array' do
        expect(pail_list.folders).to be_a Hash
      end

      it 'contains a list of folders' do
        expect(pail_list.folders.keys).to contain_exactly('moar_cats')
      end
    end

    describe '#to_hash' do
      it 'returns a hash' do
        expect(pail_list.to_hash).to be_a Hash
      end

      it 'contains a list of files and folders' do
        expect(pail_list.to_hash.keys).to contain_exactly(:files, :folders)
      end
    end

  end

end