# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def flash_notices
    raw([:notice, :error, :alert].collect {|type| content_tag(:p, flash[type], :id => type) if flash[type] }.join)
  end
  
  # Render a submit button and cancel link
  def submit_or_cancel(cancel_url = session[:return_to] ? session[:return_to] : url_for(:action => 'index'), label = 'Save changes')
    raw(content_tag(:p, submit_tag(label) + ' or ' +
      link_to('cancel', cancel_url), :id => 'submit_or_cancel', :class => 'submit'))
  end

  def discount_label(discount)
    (discount.percent? ? number_to_percentage(discount.amount * 100, :precision => 0) : number_to_currency(discount.amount)) + ' off'
  end
end
