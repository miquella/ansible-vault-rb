require 'spec_helper'

module Ansible
  class Vault
    RSpec.describe FileReader do
      let(:file) { FileReader.new(fixture_path('empty.yml')) }

      describe '#initialize(path)' do
        it 'must extract the file header' do
          expect(file.header).to eq '$ANSIBLE_VAULT;1.1;AES256'
        end

        it 'must extract the raw contents of the file removing line breaks' do
          expect(file.body).to match /\A[a-f0-9]*\z/
        end

        it 'must handle a blank file' do
          file = FileReader.new(fixture_path('blank.yml'))
          expect(file.header).to be nil
          expect(file.body).to eq ''
        end
      end

      it 'must be able to extract the ciphertext from the encoded body' do
        expect(file.ciphertext).
          to eq BinASCII.unhexlify('995a664974068a8b77e696c305af2c82')
      end

      it 'must be able to extract the hmac value from the encoded body' do
        expect(file.hmac).to eq '16b9b8ae8e164768d0505bcb16269efb35804643dd351084b3c6ebbc6f7db2c8'
      end

      it 'must be able to extract the salt value from the encoded body' do
        expect(file.salt).
          to eq BinASCII.unhexlify(
            '9371efa1796a8c3d3752d0d64837cf21ddf1d57978773d43e23ab1f96c90e035'
        )
      end

      describe '#encrypted?' do
        it 'must return true when the file is in the correct format' do
          expect(file).to be_encrypted
        end

        it 'must return false when the file is in an unexpected format' do
          plaintext_file = FileReader.new(fixture_path('plaintext.yml'))
          expect(plaintext_file).to_not be_encrypted
        end
      end
    end
  end
end
