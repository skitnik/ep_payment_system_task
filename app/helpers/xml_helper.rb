# frozen_string_literal: true

module XmlHelper
  def extract_xml_params(xml_params, permitted_params)
    doc = Nokogiri::XML(xml_params)
    data = params_hash(doc, permitted_params)
    ActionController::Parameters.new(data).permit(permitted_params)
  end

  private

  def params_hash(doc, permitted_params)
    permitted_params.each_with_object({}) do |param, hash|
      if param == :amount
        amount = doc.xpath("//#{param}").text
        hash[param] = BigDecimal(amount) if amount.present?
      else
        value = doc.xpath("//#{param}").text
        hash[param] = value.presence
      end
    end
  end
end
