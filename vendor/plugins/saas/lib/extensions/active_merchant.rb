#
# Rails 3 expects creditcard.errors[:name] to return []
# if there are no error. But AM returns nil. This is a fix.
#
class ActiveMerchant::Validateable::Errors

  alias old_accessor []

  def [](key)
    old_accessor(key) || Array.new
  end

end

