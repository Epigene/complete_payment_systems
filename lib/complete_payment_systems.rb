require "complete_payment_systems/version"
require 'rubygems'
require 'openssl'
require 'digest/sha1'
require 'base64'
require 'unirest'

module CompletePaymentSystems

  ROOT = File.expand_path("../..", __FILE__)

  class << self
  end

  def self.sign
    keypass = 'password'
    # type
    # user
    # orderNumber
    # value
    # currency
    # cardNumber (if present)
    # productName
    # ˇˇ
    # sign_string = [param1, param2, param3].join()
    sign_string = "sendForAuthtest_merchant_sign9991945100USD4314229999999913Product"
    rsa         = OpenSSL::PKey::RSA.new(File.read("#{CPS.root}/Test_sign.pem"), keypass )
    signature   = Base64.encode64(rsa.sign(OpenSSL::Digest::SHA1.new, sign_string))
  end

  def decode signature

  end

  def self.unirest
    sending_path = "#{CPS.root}/cps.xml"
    a = File.open(sending_path,'w') do |file|
      file.write(%Q|<?xml version="1.0" encoding="UTF-8" ?>\n|)
      file.write(%Q|<cpsxml xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"\n|)
      file.write(%Q|        xsi:schemaLocation="http://www.cps.lv/xml/ns/cpsxml"\n|)
      file.write(%Q|        https://3ds.cps.lv/GatorServo/Gator_SendForAuth.xsd\n|)
      file.write(%Q|        xmlns="http://www.cps.lv/xml/ns/cpsxml">\n|)
      file.write(%Q|  <header xmlns="">\n|)
      file.write(%Q|    <responsetype>direct</responsetype>\n|)
      file.write(%Q|    <user>test_merchant_sign</user>\n|)
      file.write(%Q|    <type>sendForAuth</type>\n|)
      file.write(%Q|    <transType>DB</transType>\n|)
      file.write(%q|    <digiSignature>beOLV8RRek9UoYpwKKUO5tGJXArO0l57rdXxPcYAuLgzRPtPzq80Rk5nwSqJ\ndXzt3yCzGOrbb4QPuZOXiDBl4yEFoRAED6u2FxlbC4giyYwtVRhy/UwSa35r\nLw0f8efNsn8HvwakHp8nFKjxOj5f8r0F/bCChATHaDE9UcaEpPU=|+ "\n</digiSignature>" + "\n")
      file.write(%Q|  </header>\n|)
      file.write(%Q|  <request xmlns="">\n|)
      file.write(%Q|    <orderNumber>9991945</orderNumber>\n|)
      file.write(%Q|    <cardholder>\n|)
      file.write(%Q|      <firstName>Anyname</firstName>\n|)
      file.write(%Q|      <lastName>LastName</lastName>\n|)
      file.write(%Q|      <street>Kronvalda</street>\n|)
      file.write(%Q|      <zip>LV-1050</zip>\n|)
      file.write(%Q|      <city>Riga</city>\n|)
      file.write(%Q|      <country>LV</country>\n|)
      file.write(%Q|      <email>email@domain.com</email>\n|)
      file.write(%Q|      <ip>123.124.125.126</ip>\n|)
      file.write(%Q|    </cardholder>\n|)
      file.write(%Q|    <amount>\n|)
      file.write(%Q|      <value>100</value>\n|)
      file.write(%Q|      <currency>USD</currency>\n|)
      file.write(%Q|    </amount>\n|)
      file.write(%Q|    <product>\n|)
      file.write(%Q|      <productName>Product</productName>\n|)
      file.write(%Q|      <productUrl>www.test.com</productUrl>\n|)
      file.write(%Q|    </product>\n|)
      file.write(%Q|  </request>\n|)
      file.write(%Q|</cpsxml>|)
    end

    a = File.open(sending_path, "rb").read

    #puts a

    response = Unirest.post "https://3ds.cps.lv/GatorServo/request",
                        #headers:{ "Accept" => "application/json" },
                        parameters:{ type: "sendForAuth", xml: a }

    puts response.code # Status code
    puts response.headers # Response headers
    puts response.body # Parsed body
    puts response.raw_body # Unparsed body
  end

  def self.root
    ROOT
  end

end

CPS = CompletePaymentSystems