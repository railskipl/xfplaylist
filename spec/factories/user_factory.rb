Factory.define(:user) do |f|
  f.name Faker::Name.name
  f.email Faker::Internet.email
  f.association :account
  f.password 'foobar'
  f.password_confirmation 'foobar'
end