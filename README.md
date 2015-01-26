# CompletePaymentSystems

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'complete_payment_systems'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install complete_payment_systems

## Usage

# Configure Defaults

in /config/initializers/cps.rb
```ruby
CPS.configure do |config|
  config.default_user = "pasta_test_3d" # Your CPS account user
  config.default_callback_url = "http://www.app.com/cps/process" # server-to-server POST response processing route
  config.default_redirect_url = "http://www.app.com/cps/return" # Url to "Thank-you"-"Retry" differ route
  config.default_product_name = "Product"
  config.default_product_url = "www.test.com"
end
```

# Build payment request
```ruby
hash = {
  order: (Time.now.to_i),            # Pass the unique purchase ID here
  holder_name: "Test",               # Ask buyer for this in a form
  holder_surname: "User",            # Ask buyer for this in a form
  card_number: "4314229999999913",   # Ask buyer for this in a form
  card_exp: "01/18",                 # Ask buyer for this in a form
  card_cvv: "123",                   # Ask buyer for this in a form
  holder_street: "NOT USED",         # (Optional) Ask buyer for this in a form
  holder_zip: "NOT USED",            # (Optional) Ask buyer for this in a form
  holder_city: "NOT USED",           # (Optional) Ask buyer for this in a form
  holder_country: "US",              # (Optional) Ask buyer for this in a form
  holder_email: "test@domain.com",   # (Optional) Ask buyer for this in a form
  holder_ip: "123.124.125.226",      # (Optional) Ask buyer for this in a form
  user: "Some User"                  # Best defined in config and not passed
  callback_url: "http://www.app.lv", # Best defined in config and not passed
  redirect_url: "http://www.app.lv", # Best defined in config and not passed
  product_name: "Product",           # Best defined in config and not passed
  product_url: "www.test.com"        # Best defined in config and not passed
}

CPS.build_request_xml(params_hash: hash)
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/complete_payment_systems/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Dev Notes

calbackUrl atbilde atnāks pirmā, jo te mēs sūtam atbildi pa tiešo no mūsu servera uz jūso noradītu URL

# self.build_request_xml

Takes one argument - params_hash
