# frozen_string_literal: true

require 'rails_helper'

RSpec.describe XmlHelper, type: :helper do
  describe '#extract_xml_params' do
    let(:permitted_params) { %i[email password amount] }

    context 'when valid XML data is provided' do
      let(:xml_data) do
        <<-XML
        <user>
          <email>user@example.com</email>
          <password>password123</password>
          <amount>100.50</amount>
        </user>
        XML
      end

      it 'returns the expected parameters' do
        result = helper.extract_xml_params(xml_data, permitted_params)

        expect(result[:email]).to eq('user@example.com')
        expect(result[:password]).to eq('password123')
        expect(result[:amount]).to eq(100.50)
      end
    end

    context 'when XML data is missing some fields' do
      let(:xml_data) do
        <<-XML
        <user>
          <email>user@example.com</email>
          <amount>50.00</amount>
        </user>
        XML
      end

      it 'returns nil for the missing fields' do
        result = helper.extract_xml_params(xml_data, permitted_params)

        expect(result[:email]).to eq('user@example.com')
        expect(result[:password]).to be_nil
        expect(result[:amount]).to eq(50.00)
      end
    end

    context 'when amount is not a valid number' do
      let(:xml_data) do
        <<-XML
        <user>
          <email>user@example.com</email>
          <password>password123</password>
          <amount>invalid_number</amount>
        </user>
        XML
      end

      it 'raises an error' do
        expect do
          helper.extract_xml_params(xml_data, permitted_params)
        end.to raise_error(ArgumentError)
      end
    end
  end
end
