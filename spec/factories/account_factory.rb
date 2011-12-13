Factory.define(:account) do |f|
  f.name Faker::Company.name
  f.full_domain 'test_host'
end