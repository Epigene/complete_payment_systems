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
    attr_accessor :default_user, :default_callback_url, :default_redirect_url, :default_product_name, :default_product_url, :default_country, :placeholder_value,
      :cps_url, :cps_method, :cert_pass, :rsa_cert_path, :success_regex

    def initialize
      @default_user = "pasta_test_3d"
      @default_callback_url = "http://www.google.com"
      @default_redirect_url = "http://www.google.lv"
      @default_product_name = "Product"
      @default_product_url = "www.test.com"
      @default_country = "US"
      @placeholder_value = "Not@Used.com"


      @cps_url = "https://3ds.cps.lv/GatorServo/request"
      @cps_method = "sendForAuth"
      @cert_pass = 'pasS%123'
      @rsa_cert_path = "#{CPS.root}/lib/complete_payment_systems/certs/Pasta_test_3d.pem"
      @success_regex = /Captured/
    end

  end

  CPS.configure {}

  def self.return_test_instance
    hash = {
      order: (Time.now.to_i),            # Pass the unique purchase ID here
      value: "166",                      # Pass the purchase value in cents here (1$ purcase value = 100)
      currency: "USD",    # Pass the purchase currency 3-letter code here ($ = "USD")
      holder_name: "John",               # Ask buyer for this in a form
      holder_surname: "Doe",             # Ask buyer for this in a form
      card_number: "4314229999999913",   # Ask buyer for this in a form
      card_exp: "01/18",                 # Ask buyer for this in a form
      card_cvv: "123",                   # Ask buyer for this in a form
      holder_ip: "123.124.125.226"       # Get this from request.remote_ip
    }

    return CPS::Request.new(hash)

  end

end

CPS = CompletePaymentSystems