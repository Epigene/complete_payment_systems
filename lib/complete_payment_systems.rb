require "complete_payment_systems/version"
require "complete_payment_systems/xml_parsing"
#require 'rubygems'
require 'openssl'
require 'digest/sha1'
require 'base64'
require 'unirest'
require 'active_support/all'
require 'nokogiri'

module CompletePaymentSystems

  ROOT = File.expand_path("../..", __FILE__)



  # class << self
  # end

  # def decode signature

  # end

  def self.unirest
    response = Unirest.post "https://3ds.cps.lv/GatorServo/request",
                        #headers:{ "Accept" => "application/json" },
                        parameters:{ type: "sendForAuth", xml: self.make_xml }

    puts response.code # Status code
    puts response.headers # Response headers
    puts response.body # Parsed body

    return "OK" if response.body.to_s.match(/Captured/).present?
    return "ERROR"
  end

  def self.make_xml
    values = {
      user: "pasta_test_3d", # "test_pasta_sign" for direct, "pasta_test_3d" for direct with 3D
      order: (Time.now.to_i),
      holder_name: "Test",
      holder_surname: "User",
      holder_street: "NOT USED",
      holder_zip: "NOT USED",
      holder_city: "NOT USED",
      holder_country: "LV",
      holder_email: "hi@creo.mobi",
      holder_ip: "123.124.125.226",
      card_number: "4314229999999913", # 4012001037167778 for direct, For 3D-Secure number is 4314229999999913
      card_exp: "01/18", # 06/18 for direct, 3D-sec is "01/18"
      card_cvv: "123", # 999 for direct, 3D-sec is "123"
      product_name: "Product",
      product_url: "www.test.com"
    }

    values[:signature] = CPS.sign(user: values[:user], card_number: values[:card_number])

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
      file.write(%Q|    <callbackUrl>www.google.lv</callbackUrl>\n|)
      file.write(%Q|    <redirectUrl>http://www.google.lv</redirectUrl>\n|)
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

  def self.sign(type: "sendForAuth", user: "pasta_test_3d", order_id: "#{Time.now.to_i}", value: "100", currency: "USD", card_number: "4012001037167778", product: "Product")

    keypass = 'pasS%123'
    sign_string = [type, user, order_id, value, currency, card_number, product].join()

    cert_path = "#{CPS.root}/lib/complete_payment_systems/certs"
    rsa       = OpenSSL::PKey::RSA.new(File.read("#{cert_path}/Pasta_test_3d.pem"), keypass )
    puts "Signed hash:"
    signed_hash = rsa.sign(OpenSSL::Digest::SHA1.new, sign_string)
    puts "Signature"
    puts signature = Base64.encode64(signed_hash)

    return signature
  end

  def self.root
    ROOT
  end

end

CPS = CompletePaymentSystems