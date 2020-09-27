class ContactMailer < ApplicationMailer
  def contact_mail(contact)
   @contact = contact
   mail to: @contact.email, subject: "アジェンダ削除の確認メール"
 end
end
