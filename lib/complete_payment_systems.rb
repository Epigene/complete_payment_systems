require "complete_payment_systems/version"
#require 'rubygems'
require 'openssl'
require 'digest/sha1'
require 'base64'
require 'unirest'
require 'active_support/all'

module CompletePaymentSystems

  ROOT = File.expand_path("../..", __FILE__)

  class << self
  end

  def decode signature

  end

  def self.unirest
    # sending_path = "#{CPS.root}/cps.xml"
    # #a = File.open(sending_path, "rb").read
    # a = File.read(sending_path)

    response = Unirest.post "https://3ds.cps.lv/GatorServo/request",
                        #headers:{ "Accept" => "application/json" },
                        parameters:{ type: "sendForAuth", xml: self.make_xml }

    puts response.code # Status code
    puts response.headers # Response headers
    puts response.body # Parsed body
    puts response.raw_body # Unparsed body

    return "OK" if response.body.to_s.match(/Captured/).present?
    return "ERROR"
  end

  def self.make_xml
    values = {
      user: "test_pasta_sign", # "test_pasta_sign" for direct, "pasta_test_3d" for direct with 3D
      order: (Time.now.to_i),
      holder_name: "Test",
      holder_surname: "User",
      holder_street: "NOT USED",
      holder_zip: "NOT USED",
      holder_city: "NOT USED",
      holder_country: "LV",
      holder_email: "hi@creo.mobi",
      holder_ip: "123.124.125.226",
      card_number: "4012001037167778", # For 3D-Secure number is 4314229999999913
      card_exp: "06/18", # 3D-sec is "01/18"
      card_cvv: "999", # 3D-sec is "123"
      product_name: "Product",
      product_url: "www.test.com"
    }

    values[:signature] = CPS.sign
    values[:signature_line] = '<digiSignature>' + values[:signature] + '</digiSignature>'

    xml_path = "#{CPS.root}/cps.xml"
    a = File.open(xml_path,'w') do |file|
      file.write(%Q|<?xml version="1.0" encoding="UTF-8" ?>\n|)
      file.write(%Q|<cpsxml xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"\n|)
      file.write(%Q|        xsi:schemaLocation="http://www.cps.lv/xml/ns/cpsxml https://3ds.cps.lv/GatorServo/Gator_SendForAuth.xsd"\n|)
      file.write(%Q|        xmlns="http://www.cps.lv/xml/ns/cpsxml">\n|)
      file.write(%Q|  <header xmlns="">\n|)
      file.write(%Q|    <responsetype>direct</responsetype>\n|)
      file.write(%Q|    <user>#{values[:user]}</user>\n|)
      file.write(%Q|    <type>sendForAuth</type>\n|)
      file.write(%Q|    <transType>DB</transType>\n|)
      file.write(%Q|    | + values[:signature_line] + "\n")
      file.write(%Q|  </header>\n|)
      file.write(%Q|  <request xmlns="">\n|)
      file.write(%Q|    <orderNumber>#{values[:order]}</orderNumber>\n|)
      file.write(%Q|    <cardholder>\n|)
      file.write(%Q|      <firstName>#{values[:holder_name]}</firstName>\n|)
      file.write(%Q|      <lastName>#{values[:holder_surname]}</lastName>\n|)
      file.write(%Q|      <street>#{values[:holder_street]}</street>\n|)
      file.write(%Q|      <zip>#{values[:holder_zip]}</zip>\n|)
      file.write(%Q|      <city>#{values[:holder_city]}</city>\n|)
      file.write(%Q|      <country>#{values[:holder_country]}</country>\n|)
      file.write(%Q|      <email>#{values[:holder_email]}</email>\n|)
      file.write(%Q|      <ip>#{values[:holder_ip]}</ip>\n|)
      file.write(%Q|    </cardholder>\n|)
      file.write(%Q|    <card>\n|)
      file.write(%Q|      <cardNumber>#{values[:card_number]}</cardNumber>\n|)
      file.write(%Q|      <expires>#{values[:card_exp]}</expires>\n|)
      file.write(%Q|      <cvv>#{values[:card_cvv]}</cvv>\n|)
      file.write(%Q|    </card>\n|)
      file.write(%Q|    <amount>\n|)
      file.write(%Q|      <value>100</value>\n|)
      file.write(%Q|      <currency>USD</currency>\n|)
      file.write(%Q|    </amount>\n|)
      file.write(%Q|    <product>\n|)
      file.write(%Q|      <productName>#{values[:product_name]}</productName>\n|)
      file.write(%Q|      <productUrl>#{values[:product_url]}</productUrl>\n|)
      file.write(%Q|    </product>\n|)
      file.write(%Q|  </request>\n|)
      file.write(%Q|</cpsxml>|)
    end

    return File.read(xml_path)
  end

  def self.sign(type: "sendForAuth", user: "test_pasta_sign", order_id: "#{Time.now.to_i}", value: "100", currency: "USD", card_number: "4012001037167778", product: "Product")
    keypass = 'pasS%123'
    # type
    # user
    # orderNumber
    # value
    # currency
    # cardNumber (if present)
    # productName
    # ˇˇ
    sign_string = [type, user, order_id, value, currency, card_number, product].join()

    # rsa         = OpenSSL::PKey::RSA.new(File.read("#{CPS.root}/Test_pasta_sign.pem"), keypass )
    # signature   = Base64.encode64(rsa.sign(OpenSSL::Digest::SHA1.new, sign_string))
    # return signature

    rsa         = OpenSSL::PKey::RSA.new(File.read("#{CPS.root}/Test_pasta_sign.pem"), keypass )
    #sha1        = OpenSSL::Digest::SHA1.new, sign_string
    signature   = Base64.encode64(rsa.sign(OpenSSL::Digest::SHA1.new, sign_string))
    return signature

    response = "HlcnASe5fZyM7uVz4xwqpe9MF6+pHWXt0Fg9t5tbgmgsjLIzVZMvErzJYsZymiHEnyCbYdbAUcman8JfOP1/LnAvPAhpxz09wNsXBYJcK7YjR+Ktu2faraRfgVG0t8QTjUumk5ayTMIA/IYHvIy+2bDJgmqVQEIctl8mFdn/RyrOFFhSB2aNQwXFP1DA9Ul4c+UyDq1d5AqwGyuevKR3qFodco2DT8eO6PMpRZstecAib2Bjk5tkIY2iNRYTj7TFwtM2ASMXnbYWz82E389/AHTCBpKl4d7o6ewysPjvz4LI1pykvCJRrL10y7HGYKgoo/+JnCp9s9J4iFGx5SVqSA=="



    # [16] pry(main)> v = OpenSSL::X509::Certificate.new File.read "#{CPS.root}/cps.cer"
    # => #<OpenSSL::X509::Certificate subject=#<OpenSSL::X509::Name:0x007f9b3da00db8>, issuer=#<OpenSSL::X509::Name:0x007f9b3da00d40>, serial=#<OpenSSL::BN:0x007f9b3da00cc8>, not_before=2014-03-31 10:20:50 UTC, not_after=2016-05-02 21:46:29 UTC>
    # [17] pry(main)> p = v.public_key
    # => #<OpenSSL::PKey::RSA:0x007f9b3da38920>
  end

  def self.root
    ROOT
  end

end

CPS = CompletePaymentSystems