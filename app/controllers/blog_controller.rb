class BlogController < ApplicationController
  
  def page
      @page = Page.find(params[:id])
   end  
   
   def contact
     if request.post? and params[:reset_password]
            if contact = Contact.new(params[:reset_password])

              contact.name = "#{params[:reset_password][:sender_name]}"
              contact.email = "#{params[:reset_password][:sender_email]}"
              contact.subject = "#{params[:reset_password][:title]}"
              contact.message = "#{params[:reset_password][:body]}"
              contact.save


              Emailer.deliver_contact_email(contact)

              flash[:notice] = "Thank you for sending a mail."
              redirect_to("/contacts")

            end
         else
           @title = "contacts"
         end
    
   end
end
