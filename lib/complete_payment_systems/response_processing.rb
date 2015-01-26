module CompletePaymentSystems
  class Response

    attr_accessor :xml, :response_hash, :code, :message

    def initialize(xml)
      if xml.present?
        puts 'ir'
      else
        puts 'nav'
      end

      @xml = xml || File.read("#{CPS.root}/response.xml") # TO-DO remove this!
      @response_hash = parse_response(@xml)
      @code = @response_hash["resultCode"]
      @message = @response_hash["resultMessage"]
    end

    def ok?
      return signature_ok? && message.match(/Captured/).present? && code == "000"
    end

    def signature_ok?
      digi_signature = response_hash["digiSignature"]
      hash_string = build_hashable_string
      decoded_resp = Base64.decode64(digi_signature)
      public_key = OpenSSL::X509::Certificate.new(
        File.read "#{CPS.root}/lib/complete_payment_systems/certs/cps.cer").
        public_key
      return public_key.verify(OpenSSL::Digest::SHA1.new, decoded_resp, hash_string)
    end

    private

      def parse_response xml
        @response = Nokogiri::XML(xml) do |config|
          config.strict.nonet
        end

        return {
          "referenceId" => @response.xpath("//referenceId").text,
          "orderId" => @response.xpath("//orderId").text,
          "value" => @response.xpath("//value").text,
          "currency" => @response.xpath("//currency").text,
          "resultCode" => @response.xpath("//resultCode").text,
          "resultMessage" => @response.xpath("//resultMessage").text, # Important
          "resultText" => @response.xpath("//resultText").text, # Informative only
          "digiSignature" => @response.xpath("//digiSignature").text
        }
      end

      def build_hashable_string
        rh = @response_hash
        return "#{rh["referenceId"]}#{rh["orderId"]}#{rh["value"]}#{rh["currency"]}#{rh["resultCode"]}#{rh["resultMessage"]}#{rh["resultText"]}"
      end

  end

  # def self.read_test_xml
  #   return File.read("#{CPS.root}/response.xml")
  # end

end