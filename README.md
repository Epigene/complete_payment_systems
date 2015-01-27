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

The complete module name is CompletePaymentSystems, but the aliased shorthand CPS is recommended.

### Configure Defaults
in */config/initializers/cps.rb*

```ruby
CPS.configure do |config|
  # Your CPS account user
  config.default_user = "pasta_test_3d"

  # server-to-server POST response processing route
  config.default_callback_url = "http://www.app.com/cps/process"

  # Url to "Thank-you"-"Retry" differ route
  config.default_redirect_url = "http://www.app.com/cps/return"
  config.default_product_name = "Product"
  config.default_product_url = "www.test.com"
  config.default_country = "US"

  # Used in client data, like street and zip, if you choose not to ask for these
  config.placeholder_value = "PLACEHOLDER"

  config.cps_url = "https://3ds.cps.lv/GatorServo/request" # This will probably never change
  config.cps_method = "sendForAuth" # This will also probably remain the same
  config.cert_pass = 'pasS%123' # your cert chain password

  # Your .pem format cert chain location
  config.rsa_cert_path = "#{CPS.root}/lib/complete_payment_systems/certs/Pasta_test_3d.pem"
end
```

### Build a payment request
Instantiate a CPS::Request object, passit a hash with parameters:
```ruby
hash = {
  order: (Time.now.to_i),            # Pass the unique purchase ID here
  value: 100     ,                   # Pass the purchase value in cents here (1$ purcase value = 100)
  currency: "EUR",                   # Pass the purchase currency 3-letter code here ($ = "USD")
  holder_name: "John",               # Ask buyer for this in a form
  holder_surname: "Doe",             # Ask buyer for this in a form
  card_number: "4314229999999913",   # Ask buyer for this in a form
  card_exp: "01/18",                 # Ask buyer for this in a form
  card_cvv: "123",                   # Ask buyer for this in a form
  holder_ip: "123.124.125.226",      # Get this from request.remote_ip
  holder_street: "NOT USED",         # (Optional) Ask buyer for this in a form
  holder_zip: "NOT USED",            # (Optional) Ask buyer for this in a form
  holder_city: "NOT USED",           # (Optional) Ask buyer for this in a form
  holder_country: "US",              # (Optional) Ask buyer for this in a form
  holder_email: "test@domain.com",   # (Optional) Ask buyer for this in a form
  user: "Some User"                  # Best defined in config and not passed
  callback_url: "http://www.app.lv", # Best defined in config and not passed
  redirect_url: "http://www.app.lv", # Best defined in config and not passed
  product_name: "Product",           # Best defined in config and not passed
  product_url: "www.test.com"        # Best defined in config and not passed
}
CPS::Request.new(hash)
```
# Process response
Instantiate a CPS::Response object with an xml parameter (get the xml from server response .body)
```ruby
@response = CPS.Response.new(request_response.body)
```
API exposes reader methods #xml, #response_hash, #code, #message
as well as convenience methods #ok? and #signature_ok?

```ruby
r = CPS::Response.new(valid_xml_response)
r.response_hash
  => {"referenceId"=>"9095359",
 "orderId"=>"1422019383",
 "value"=>"100",
 "currency"=>"USD",
 "resultCode"=>"000",
 "resultMessage"=>"Captured",
 "resultText"=>"Captured",
 "digiSignature"=>
  "HlcnASe5fZyM7uVz4xwqp ... XGx5SVqSA=="}
r.code
  => "000"
r.message
  => "Captured"
r.signature_ok?
  => true
r.ok?
  => true
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/complete_payment_systems/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Dev Notes

calbackUrl atbilde atnāks pirmā, jo te mēs sūtam atbildi pa tiešo no mūsu servera uz jūso noradītu URL

#### Direct-3D request example
hash = {
  order: (Time.now.to_i),            # Pass the unique purchase ID here
  value: 166,                        # Pass the purchase value in cents here (1$ purcase value = 100)
  currency: (params["currency"]),    # Pass the purchase currency 3-letter code here ($ = "USD")
  holder_name: "John",               # Ask buyer for this in a form
  holder_surname: "Doe",             # Ask buyer for this in a form
  card_number: "4314229999999913",   # Ask buyer for this in a form
  card_exp: "01/18",                 # Ask buyer for this in a form
  card_cvv: "123",                   # Ask buyer for this in a form
  holder_ip: "123.124.125.226",      # Get this from request.remote_ip
  holder_street: "NOT USED",         # (Optional) Ask buyer for this in a form
  holder_zip: "NOT USED",            # (Optional) Ask buyer for this in a form
  holder_city: "NOT USED",           # (Optional) Ask buyer for this in a form
  holder_country: "US",              # (Optional) Ask buyer for this in a form
  holder_email: "test@domain.com",   # (Optional) Ask buyer for this in a form
  user: "Some User"                  # Best defined in config and not passed
  callback_url: "http://www.app.lv", # Best defined in config and not passed
  redirect_url: "http://www.app.lv", # Best defined in config and not passed
  product_name: "Product",           # Best defined in config and not passed
  product_url: "www.test.com"        # Best defined in config and not passed
}
@request = CPS::Request.new(hash)

