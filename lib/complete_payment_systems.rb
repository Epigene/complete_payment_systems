require "complete_payment_systems/version"
require "complete_payment_systems/request_processing"
require "complete_payment_systems/response_processing"
#require 'rubygems'
require 'openssl'
require 'digest/sha1'
require 'base64'
require 'unirest'
require 'active_support/all'
require 'nokogiri'

module CompletePaymentSystems

  CPS = CompletePaymentSystems
  ROOT = File.expand_path("../..", __FILE__)

  def self.root
    ROOT
  end

  class << self
    attr_accessor :config
  end

  def self.configure
    self.config ||= Config.new
    yield(config)
  end

  class Config
    attr_accessor :default_user, :default_callback_url, :default_redirect_url, :default_product_name, :default_product_url,
      :placeholder_value, :cps_url, :cps_method, :cert_pass, :rsa_cert_path, :success_regex

    def initialize
      @default_user = "pasta_test_3d"
      @default_callback_url = "http://www.google.com"
      @default_redirect_url = "http://www.google.lv"
      @default_product_name = "Product"
      @default_product_url = "www.test.com"
      @placeholder_value = "PLACEHOLDER"

      @cps_url = "https://3ds.cps.lv/GatorServo/request"
      @cps_method = "sendForAuth"
      @cert_pass = 'pasS%123'
      @rsa_cert_path = "#{CPS.root}/lib/complete_payment_systems/certs/Pasta_test_3d.pem"
      @success_regex = /Captured/
    end

  end

  CPS.configure {}

  # TO-DO Delete this after production checks
  def self.make_xml
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
      file.write(%Q|    <callbackUrl>#{values[:callback_url]}</callbackUrl>\n|)
      file.write(%Q|    <redirectUrl>#{values[:redirect_url]}</redirectUrl>\n|)
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

end

CPS = CompletePaymentSystems