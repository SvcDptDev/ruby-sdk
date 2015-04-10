require "base64"
require 'httparty'
require_relative "velocity_exception"
require_relative "velocity_processor"
require_relative "velocity_xml_creator"
include Velocity::VelocityException::VelocityErrors
include Velocity::VelocityException::VelocityErrorMessages

module Velocity
  class VelocityConnection
    attr_accessor :session_token, :identity_token
    
    def initialize(identity_token)
      @identity_token = identity_token
    end

    def identity_token
      @identity_token
    end
    
    SIGNON_URL = "https://api.cert.nabcommerce.com/REST/2.0.18/SvcInfo/token"

   # ----------------------------> signOn Method  <----------------------------- # 
    
   # "signOn" method for making GET request.
   # In this method to genrate the session token by passing the identity_token.
   # It returns the session token in string.

    def signOn()
      begin
        response_xml = HTTParty.get(SIGNON_URL,
        headers: { "Content-Type" => "application/json", 
          "Authorization" => "Basic #{encode_token(identity_token)}"},
        verify: false,:timeout => 60 )
        encode_token(response_xml)
      rescue Exception => ex
        return "invalid session token"
      end
    end
    
    private
    
    def encode_token(str)
      begin
        Base64.strict_encode64(str.gsub(/"/, '').concat(":"))
      rescue Exception => ex
        return "invalid identity token"
      end
    end
  end
end