module ApplicationHelper
  def whatsapp_link_for(product_name = nil)
    number = "5493513033711" # Número de WhatsApp: +54 9 351 303 3711
    message = product_name.present? ? "Hola! Quiero consultar por el producto #{product_name}" : "Hola! Quiero hacer una consulta"
    "https://wa.me/#{number}?text=#{ERB::Util.url_encode(message)}"
  end
end
