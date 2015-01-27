module CompletePaymentSystems
  class Request

    attr_reader :params, :xml

    def initialize(params)
      @params = params #|| File.read("#{CPS.root}/response.xml")
      @xml = build_request_xml
    end

    def send!
      response = Unirest.post CPS.config.cps_url,
                          #headers:{ "Accept" => "application/json" },
                          parameters:{ type: CPS.config.cps_method, xml: xml }

      puts response.code # Status code
      puts response.headers # Response headers
      puts response.body # Parsed body

      return "OK" if response.body.to_s.match(CPS.config.success_regex).present?
      return "ERROR"
    end

    private
      def sign(type: CPS.config.cps_method, user: CPS.config.default_user, order_id: "", value: "", currency: "", card_number: "", product: CPS.config.default_product_name)
        sign_string = [type, user, order_id, value, currency, card_number, product].join()
        rsa         = OpenSSL::PKey::RSA.new(File.read(CPS.config.rsa_cert_path), CPS.config.cert_pass )
        signed_hash = rsa.sign(OpenSSL::Digest::SHA1.new, sign_string)
        Base64.encode64(signed_hash)
      end

      def build_request_xml
        values = {
          user: (params[:user] || CPS.config.default_user), # "test_pasta_sign" for direct, "pasta_test_3d" for direct with 3D
          callback_url: (params[:callback_url] || CPS.config.default_callback_url),
          redirect_url: (params[:redirect_url] || CPS.config.default_redirect_url),
          order: (params[:order] || Time.now.to_i), # TO-DO remove fallback
          value: (params[:value]),
          currency: (params[:currency]),
          holder_name: params[:holder_name],
          holder_surname: params[:holder_surname],
          holder_street: (params[:holder_street] || CPS.config.placeholder_value),
          holder_zip: (params[:holder_zip] || CPS.config.placeholder_value),
          holder_city: (params[:holder_city] || CPS.config.placeholder_value),
          holder_country: (params[:holder_country] || CPS.config.default_country),
          holder_email: (params[:holder_email] || CPS.config.placeholder_value),
          holder_ip: ( params[:holder_ip] ),
          card_number: params[:card_number], # 4012001037167778 for direct, For 3D-Secure number is 4314229999999913
          card_exp: params[:card_exp], # 06/18 for direct, 3D-sec is "01/18"
          card_cvv: params[:card_cvv], # 999 for direct, 3D-sec is "123"
          product_name: (params[:product_name] || CPS.config.default_product_name),
          product_url: (params[:product_url] || CPS.config.default_product_url)
        }

        values[:signature] = sign(order_id: values[:order], value: values[:value], currency: values[:currency], card_number: values[:card_number]).gsub(/\n/, '')

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
          %Q|      <value>#{values[:value]}</value>\n| +
          %Q|      <currency>#{values[:currency]}</currency>\n| +
          %Q|    </amount>\n| +
          %Q|    <product>\n| +
          %Q|      <productName>#{values[:product_name]}</productName>\n| +
          %Q|      <productUrl>#{values[:product_url]}</productUrl>\n| +
          %Q|    </product>\n| +
          %Q|  </request>\n| +
          %Q|</cpsxml>|
      end
  end
end