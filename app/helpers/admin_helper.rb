module AdminHelper
  def delete_button_with_csrf(url, text, confirm_message)
    form_with(url: url, method: :delete, local: true, style: 'display: inline;') do |f|
      f.hidden_field :authenticity_token, value: form_authenticity_token
      f.submit text, 
               class: 'btn btn-sm btn-danger', 
               style: 'background: #dc3545; color: white; padding: 6px 12px; border-radius: 4px; border: none; font-size: 12px; display: inline-flex; align-items: center; gap: 4px; cursor: pointer;',
               data: { confirm: confirm_message }
    end
  end
end
