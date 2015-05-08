require_relative '../../spec_helper'

describe 'Pail::Pfile' do

  let(:pail_file) {Pail::Pfile.new(File.join(File.dirname(__FILE__),'../../assets/cat.jpg'))}
  let(:sample_metadata) { {foo: 'foo', bar: 'bar', baz: 'baz'} }

  context 'add' do
    subject { pail_file.add(sample_metadata) }

      it { is_expected.to eq(true) }

  end

  context 'get' do
    before(:example) { pail_file.add(pizza: 'pepperoni') }
    after(:example) { pail_file.delete(:pizza)}
    subject { pail_file.get('pizza') }

    it { is_expected.to eq('pepperoni') }

  end

  context 'list' do
    before(:example) { pail_file.add(sample_metadata)}
    subject { pail_file.list }

    it { is_expected.to eq( {foo: 'foo', bar: 'bar', baz: 'baz'}) }
  end

  context 'delete' do
    before(:example) { pail_file.add(sample_metadata) }
    subject { pail_file.delete(:foo) }

    it { is_expected.to eq(true) }
  end
end