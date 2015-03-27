# CompletePaymentSystems

Ruby gem for a simple CPS (Complete Payment Systems) service API - creates request XML from a parameters hash, processes the response.

Only direct-3D payments supported for now.

###### Workflow Overview:
1. Install gem, congifure defaults
2. Build an appropriate parameter hash using user-entered card values
3. Instantiate CPS::Request object passing the hash as the single argument
4. Pass the request instance to the form view (see /example_request_form.html.erb)
5. Capture the CPS server response in a controller action that listens on _config.default_callback_url_
6. Based on the response (@response.ok?) change order status
7. Based on order status, process user return experience at _config.default_redirect_url_

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
  config.placeholder_value = "Not@Used.com"

  config.cps_url = "https://3ds.cps.lv/GatorServo/request" # This will probably never change
  config.cps_method = "sendForAuth" # This will also probably remain the same
  config.cert_pass = 'pasS%123' # your cert chain password

  # Your .pem format cert chain location
  config.rsa_cert_path = "#{CPS.root}/lib/complete_payment_systems/certs/Pasta_test_3d.pem"
end
```

### Build a payment request
Instantiate a CPS::Request object, pass it a hash with parameters:
```ruby
def create

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
  
  # Passed to view which silently submits a form to CPS server
  @cps_request = CPS::Request.new(hash)
  
end
```
### Post the built object data from a form rendered by the create method
```ruby
<html>
 <head>
 </head>
 <body onload="document.cpsForm.submit();" style="display:none;">
 <form method="POST" name="cpsForm" action="<%= CPS.config.cps_url %>">
 <input name="type" value="<%= CPS.config.cps_method %>">
 <textarea name="xml">
<%= @cps_request.xml %>
</textarea>
 <input type="submit" value="Send">
 </form>
 </body>
</html>
```
# Process response
Instantiate a CPS::Response object with an xml parameter (get the xml from `params` hash)
```ruby
@response = CPS.Response.new(params[:xmlResponse])
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
## Testing setup
### Use testing create sending form
This will use the xml from production code, but post it to test server on button press, allowing you to debug
```ruby
<html>
 <head>
 </head>
 <body>
 <form method="POST" action="https://3ds.cps.lv/GatorServo/request">
 <input name="type" value="sendForAuth">
 <textarea name="xml">
<%= @cps_request.xml %>
 </textarea>
 <input type="submit" value="Send">
 </form>
 </body>
</html>
```
### Use development config
Set return urls to use a domain that points to localhost, such as lvh.me
  `config.default_callback_url = "http://lvh.me:3000/pay/cps/"`
  `config.default_redirect_url = "http://lvh.me:3000/pay/cps/"`
For 3D test purchases set
  `config.default_user = "pasta_test_3d"`
For non-3D test purchases set
  `config.default_user = "testa_pasta_sign"`

### Use CPS-given test cards
Access http://wiki.cps.lv/index.php/Test_account (Login and Pass required)
Use examples given there (NB, use test currency, USD)

## Contributing

1. Fork it ( https://github.com/[my-github-username]/complete_payment_systems/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Dev Notes

calbackUrl atbilde atnāks pirmā, jo te mēs sūtam atbildi pa tiešo no mūsu servera uz jūso noradītu URL

#### Direct-3D request example
```ruby
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
```
