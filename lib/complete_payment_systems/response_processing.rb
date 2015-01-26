module CompletePaymentSystems

  def self.parse_response xml

    @response = Nokogiri::XML(xml) do |config|
      config.strict.nonet
    end

    puts @response.xpath("//referenceId").text
    puts @response.xpath("//orderId").text
    puts @response.xpath("//value").text
    puts @response.xpath("//currency").text
    puts @response.xpath("//resultCode").text
    puts @response.xpath("//resultMessage").text # Important
    puts @response.xpath("//resultText").text # Informative only
    puts @response.xpath("//digiSignature").text

    return {
      "referenceId" => @response.xpath("//referenceId").text,
      "orderId" => @response.xpath("//orderId").text,
      "value" => @response.xpath("//value").text,
      "currency" => @response.xpath("//currency").text,
      "resultCode" => @response.xpath("//resultCode").text,
      "resultMessage" => @response.xpath("//resultMessage").text,
      "resultText" => @response.xpath("//resultText").text,
      "digiSignature" => @response.xpath("//digiSignature").text
    }

  end

  # CPS.verify_signature(CPS.parse_response(CPS.read_test_xml)["digiSignature"], CPS.build_hashable_string( CPS.parse_response(CPS.read_test_xml) ) )
  def self.verify_signature(digi_signature, hash_string)
    puts "called verify signature"
    puts digi_signature
    puts hash_string

    puts "Decoded resp:"
    puts decoded_resp = Base64.decode64(digi_signature)

    puts "Public key:"
    puts public_key = OpenSSL::X509::Certificate.new(
      File.read "#{CPS.root}/lib/complete_payment_systems/certs/cps.cer").
      public_key

    puts "Verification status:"
    puts public_key.verify(OpenSSL::Digest::SHA1.new, decoded_resp, hash_string).inspect
  end

  # CPS.build_hashable_string( CPS.parse_response(CPS.read_test_xml) )
  def self.build_hashable_string response_hash
    rh = response_hash
    return "#{rh["referenceId"]}#{rh["orderId"]}#{rh["value"]}#{rh["currency"]}#{rh["resultCode"]}#{rh["resultMessage"]}#{rh["resultText"]}"
  end

  def self.read_test_xml
    return File.read("#{CPS.root}/response.xml")
  end

end