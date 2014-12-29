require_relative '../../spec_helper'

describe 'VBucket::Authentication' do
  describe '#new' do
    it 'creates a new Authentication object' do
      allow(File).to receive(:read) { "12345\n67890\nabcde\nghijklmnopqrstuvwxyz" }

      auth_object = VBucket::Authentication.new('../foo/bar')
      expect(auth_object).to be_a_kind_of(VBucket::Authentication)
    end

    it 'loads auth keys' do
      allow(File).to receive(:read) { "12345\n67890\nabcde\nghijklmnopqrstuvwxyz" }

      auth_object = VBucket::Authentication.new('../foo/bar')
      expect(auth_object.key_count).to be(4)

    end

    it 'authorizes users' do
      allow(File).to receive(:read) { "12345\n67890\nabcde\nghijklmnopqrstuvwxyz" }

      auth_object = VBucket::Authentication.new('../foo/bar')
      expect(auth_object.has_permission?('12345')).to be_truthy
    end

    it 'throws out lines with whitespace' do
      allow(File).to receive(:read) { "12345\n67890\nabcde\n \nghijklmnopqrstuvwxyz" }

      auth_object = VBucket::Authentication.new('../foo/bar')
      expect(auth_object.has_permission?(' ')).to be_falsey
      expect(auth_object.key_count).to be(4)
    end

    # it 'raises error when key file cannot be found' do
    #   pending
    # end



  end
end