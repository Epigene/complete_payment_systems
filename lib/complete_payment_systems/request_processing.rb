module CompletePaymentSystems

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

  def self.build_request_xml(params_hash: {})
    values = {
      user: "pasta_test_3d", # "test_pasta_sign" for direct, "pasta_test_3d" for direct with 3D
      callback_url: "http://www.google.lv",
      redirect_url: "http://www.google.lv",
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

    values[:signature] = CPS.sign(user: values[:user], card_number: values[:card_number]).gsub(/\n/, '')

    values[:signature_line] = '<digiSignature>' + values[:signature] + '</digiSignature>'

    xml_string = ""
    xml_string = %Q|<?xml version="1.0" encoding="UTF-8" ?>\n| +
      %Q|<cpsxml xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"\n| +
      %Q|        xsi:schemaLocation="http://www.cps.lv/xml/ns/cpsxml https://3ds.cps.lv/GatorServo/Gator_SendForAuth.xsd"\n| +
      %Q|        xmlns="http://www.cps.lv/xml/ns/cpsxml">\n| +
      %Q|  <header xmlns="">\n| +
      %Q|    <responsetype>direct</responsetype>\n| +
      %Q|    <user>#{values[:user]}</user>\n| +
      %Q|    <type>sendForAuth</type>\n| +
      %Q|    <transType>DB</transType>\n| +
      %Q|    | + values[:signature_line] + "\n" +
      %Q|    <callbackUrl>#{values[:callback_url]}</callbackUrl>\n| +
      %Q|    <redirectUrl>#{values[:redirect_url]}</redirectUrl>\n| +
      %Q|  </header>\n| +
      %Q|  <request xmlns="">\n| +
      %Q|    <orderNumber>#{values[:order]}</orderNumber>\n| +
      %Q|    <cardholder>\n| +
      %Q|      <firstName>#{values[:holder_name]}</firstName>\n| +
      %Q|      <lastName>#{values[:holder_surname]}</lastName>\n| +
      %Q|      <street>#{values[:holder_street]}</street>\n| +
      %Q|      <zip>#{values[:holder_zip]}</zip>\n| +
      %Q|      <city>#{values[:holder_city]}</city>\n| +
      %Q|      <country>#{values[:holder_country]}</country>\n| +
      %Q|      <email>#{values[:holder_email]}</email>\n| +
      %Q|      <ip>#{values[:holder_ip]}</ip>\n| +
      %Q|    </cardholder>\n| +
      %Q|    <card>\n| +
      %Q|      <cardNumber>#{values[:card_number]}</cardNumber>\n| +
      %Q|      <expires>#{values[:card_exp]}</expires>\n| +
      %Q|      <cvv>#{values[:card_cvv]}</cvv>\n| +
      %Q|    </card>\n| +
      %Q|    <amount>\n| +
      %Q|      <value>100</value>\n| +
      %Q|      <currency>USD</currency>\n| +
      %Q|    </amount>\n| +
      %Q|    <product>\n| +
      %Q|      <productName>#{values[:product_name]}</productName>\n| +
      %Q|      <productUrl>#{values[:product_url]}</productUrl>\n| +
      %Q|    </product>\n| +
      %Q|  </request>\n| +
      %Q|</cpsxml>|

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

end