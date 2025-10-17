module ApplicationHelper
  def whatsapp_link_for(product_name = nil)
    number = ENV["WHATSAPP_NUMBER"].to_s
    message = product_name.present? ? "Hola! Quiero consultar por el producto #{product_name}" : "Hola! Quiero hacer una consulta"
    "https://wa.me/#{number}?text=#{ERB::Util.url_encode(message)}"
  end
end
