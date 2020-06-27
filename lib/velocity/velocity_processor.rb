require "base64"
require 'nokogiri'
require 'httparty'
require 'rexml/document'
require_relative "velocity_exception"
require_relative "velocity_xml_creator"
require_relative "velocity_connection"
include Velocity::VelocityException::VelocityErrors
include Velocity::VelocityException::VelocityErrorMessages

module Velocity  
  class VelocityProcessor

  # This class represents a Velocity Transaction.
  # It can be used to query and 
  # "verify/authorize/authorizeandcapture/capture/undo/adjust/returnbyid/returnunlinked/captureall/querytransactionsdetails" transactions.

    attr_accessor :session_token, :identity_token, :work_flow_id, :application_profile_id, :merchant_profile_id
    
    def initialize(identity_token,work_flow_id,application_profile_id,merchant_profile_id)
      @identity_token = identity_token
      @work_flow_id = work_flow_id
      @application_profile_id = application_profile_id
      @merchant_profile_id = merchant_profile_id
    end
    
    def identity_token
      @identity_token
    end
    
    def work_flow_id
      @work_flow_id
    end
    
    def application_profile_id
      @application_profile_id
    end
    
    def merchant_profile_id
      @merchant_profile_id
    end

    def session_token
      Velocity::VelocityConnection.new(identity_token)
    end

    def xmlbody
      Velocity::VelocityXmlCreator.new(application_profile_id,merchant_profile_id)
    end

  # paths for according to request needed.

    URL = if Rails.env == "production"
            "https://api.nabcommerce.com/REST/2.0.18/Txn/"
          else
            "https://api.cert.nabcommerce.com/REST/2.0.18/Txn/"
          end
    QTD_URL = if Rails.env == "production"
                "https://api.nabcommerce.com/REST/2.0.18/DataServices/TMS/transactionsDetail"
              else
                "https://api.cert.nabcommerce.com/REST/2.0.18/DataServices/TMS/transactionsDetail"
              end

  # ----------------------------> verify Method  <----------------------------- #

  # "verify" method for making POST request.  
  # In this method to Verify the card detail and address detail of customer.
  # This Method create corresponding xml for gateway request.
  # This Method Reqest send to gateway and handle the response.
  # "params" hash,this hash holds collection of transaction details.
  # It returns response_xml as object of successfull or failure of gateway response. 

    def verify(params)
      begin
        response_xml = HTTParty.post(URL+"#{work_flow_id}"+"/"+"verify",
          body: xmlbody.verifyXML(params),
          headers: {"Authorization" => "Basic #{session_token.signOn}"},
          verify: false,:timeout => 60)
        processError?(response_xml)
      rescue Exception => ex
        return "transaction details not set for verify request"
      end  
    end

  # ----------------------------> authorize Method  <----------------------------- #
  
  # "authorize" method for making POST request.
  # In this method Authorize a payment_method for a particular amount.
  # This Method create corresponding xml for gateway request.
  # This Method Reqest send to gateway and handle the response.
  # "params" hash,this hash holds collection of transaction details.
  # It returns response_xml is object of successfull or failure of gateway response.

    def authorize(params)
      begin
        response_xml = HTTParty.post( URL+"#{work_flow_id}",
          body: xmlbody.authorizeXML(params),
          headers: {"Authorization" => "Basic #{session_token.signOn}"},
          verify: false,:timeout => 60)
        processError?(response_xml)
      rescue Exception => ex
        return "transaction details not set for authorize request"
      end
    end

  # ------------------------> authorizeAndCapture Method  <--------------------------- #

  # "authorizeAndCapture" method for making POST request.
  # "In this method authorizeAndCapture operation is used to authorize transactions by performing 
  #   a check on cardholder's funds and reserves".
  # The authorization amount if sufficient funds are available.
  # This Method create corresponding xml for gateway request.
  # This Method Reqest send to gateway and handle the response.
  # params hash,this hash holds collection of transaction details.
  # It returns response_xml is object of successfull or failure of gateway response.

    def authorizeAndCapture(params)
      begin
        response_xml = HTTParty.post( URL+"#{work_flow_id}",
          body: xmlbody.authorizeAndCaptureXML(params),
          headers: {"Authorization" => "Basic #{session_token.signOn}"},
          verify: false,:timeout => 60)
        processError?(response_xml)
      rescue Exception => ex
        return "for authorizeAndCapture PaymentAccountDataToken, Carddata and/or workflowid are not set!"
      end 
    end

  # ----------------------------> capture Method  <----------------------------- #
  
  # "capture" method for making PUT request.
  # "Captures an authorization. Optionally specify an amount to do a partial capture of the 
  #  initial authorization. The default is to capture the full amount of the authorization".
  # params hash,this hash holds collection of transaction details.
  # It returns response_xml is object of successfull or failure of gateway response.

    def capture(params)
      begin
        trid = params[:TransactionId].to_s
        response_xml = HTTParty.put( URL+"#{work_flow_id}"+"/"+trid,
          body: xmlbody.captureXML(params),
          headers: {"Authorization" => "Basic #{session_token.signOn}"},
          verify: false,:timeout => 60)
        processError?(response_xml)
      rescue Exception => ex
        return "for capture amount and/or transaction id are not set!"
      end  
    end

  # ----------------------------> undo Method  <----------------------------- #
  
  # "undo" method for making PUT request.
  # "The Undo operation is used to release cardholder funds by performing a void (Credit Card) or 
  # reversal (PIN Debit) on a previously authorized transaction that has not been captured (flagged) for settlement."
  # params hash,this hash holds collection of transaction details.
  # It returns response_xml is object of successfull or failure of gateway response.

    def undo(params)
      begin
        trid = params[:TransactionId].to_s
        response_xml = HTTParty.put( URL+"#{work_flow_id}"+"/"+trid,
          body: xmlbody.undoXML(params),
          headers: {"Authorization" => "Basic #{session_token.signOn}"},
          verify: false,:timeout => 60)
      processError?(response_xml)
      rescue Exception => ex
        return "for undo amount and/or transaction id are not set!"
      end
    end

  # ---------------------------------> adjust Method  <----------------------------- # 
  
  # "adjust" method for making PUT request.
  # "Adjust this transaction. If the transaction has not yet been captured and settled it can be Adjust to 
  # A previously authorized amount (incremental or reversal) prior to capture and settlement."
  # params hash,this hash holds collection of transaction details.
  # It returns response_xml is object of successfull or failure of gateway response.

    def adjust(params)
      begin
        trid = params[:TransactionId].to_s
        response_xml = HTTParty.put( URL+"#{work_flow_id}"+"/"+trid,
          body: xmlbody.adjustXML(params),
          headers: {"Authorization" => "Basic #{session_token.signOn}"},
          verify: false,:timeout => 60)
        processError?(response_xml)
      rescue Exception => ex
        return "for adjust amount and/or transaction id are not set!"
      end
    end

  # ----------------------------> returnById Method  <----------------------------- #

  # "returnById" method for making POST request.
  # "The ReturnById operation is used to perform a linked credit to a cardholder’s account from 
  #  the merchant’s account based on a previously authorized and settled transaction."
  # params hash,this hash holds collection of transaction details.
  # It returns response_xml is object of successfull or failure of gateway response.

    def returnById(params)
      begin
        response_xml = HTTParty.post( URL+"#{work_flow_id}",
          body: xmlbody.returnByIdXML(params),
          headers: {"Authorization" => "Basic #{session_token.signOn}"},
          verify: false,:timeout => 60)
        processError?(response_xml)
      rescue Exception => ex
        return "for returnById amount and/or transaction id are not set!"
      end    
    end  

  # ----------------------------> returnUnlinked Method  <----------------------------- #
  
  # "returnUnlinked" method for making POST request.
  # The ReturnUnlinked operation is used to perform an "unlinked", or standalone, credit to a cardholder’s account from the merchant’s account.
  # This operation is useful when a return transaction is not associated with a previously authorized and settled transaction.
  # params hash,this hash holds collection of transaction details.
  # It returns response_xml is object of successfull or failure of gateway response.

    def returnUnlinked(params)
      begin
        response_xml = HTTParty.post( URL+"#{work_flow_id}",
          body: xmlbody.returnUnlinkedXML(params),
          headers: {"Authorization" => "Basic #{session_token.signOn}"},
          verify: false,:timeout => 60)
          processError?(response_xml)  
      rescue Exception => ex
        return "for authorizeAndCapture PaymentAccountDataToken, Carddata and/or workflowid are not set!"
      end
    end

  # ----------------------------> captureAll Method  <----------------------------- #

  # "captureAll" method for making PUT request.
  # The CaptureAll operation is used to flag all transactions for settlement that have been successfully authorized using the Authorize operation.
  # params hash,this hash holds collection of transaction details.
  # It returns response_xml is object of successfull or failure of gateway response.

    def captureAll()
      begin
        response_xml = HTTParty.put( URL+"#{work_flow_id}",
          body: xmlbody.captureAllXML(),
          headers: {"Authorization" => "Basic #{session_token.signOn}"},
          verify: false,:timeout => 60)
        p response_xml
        processError?(response_xml)  
      rescue Exception => ex
        return "for captureAll sessiontoken, workflowid are not set!"
        #return ex.message
      end
    end  
 
  # ----------------------> queryTransactionsDetail Method  <------------------------- #

  # "queryTransactionsDetail" method for making POST request.
  # In this operation queries the specified transactions and returns both summary details and full transaction details as a serialized object.
  # This method contains the same search criteria and includeRelated functionality as QueryTransactionsSummary.
  # params hash,this hash holds collection of transaction details.
  # It returns response_xml is object of successfull or failure of gateway response.

    def queryTransactionsDetail(params)
      begin
        response_xml = HTTParty.post( QTD_URL,
          :body => xmlbody.queryTransactionsDetailJSON(params),
          :headers => {"Authorization" => "Basic #{session_token.signOn}", 'Content-Type' => 'application/json'},
             verify: false,:timeout => 60)
           @response = response_xml
           if @response.size == 0
                 @response = 'No query transaction details are found' 
                 return @response
           else
              response_xml = @response
              processError?(response_xml)        
           end        
      rescue Exception => ex 
        return "Some value not set in querytransactiondetail, batchid, transactionid or transactiondates!" 
      end  
    end  

    private
  
  # processError? method in Velocity response for error messages
  # response_xml is response object, error message created on the basis of gateway error status. 
  # @response.code comming from gateway response status.
  # In this method returns error massages or       

    def processError?(response_xml)
      @response = response_xml   
      #p @response
      msg = REXML::Document.new(@response.body)
        if @response.code == 200 || @response.code == 201
           #p "200200200200"
          error = REXML::XPath.first(msg, "/BankcardTransactionResponsePro/Status/text()")
          if error == "Failure"
            return REXML::XPath.first(msg, "/BankcardTransactionResponsePro/Status/text()"), 
              REXML::XPath.first(msg, "/BankcardTransactionResponsePro/StatusMessage/text()") 
          else
            return @response
          end
          # return @response
        elsif @response.code == 400 || @response.code == 500 || @response.code == 5000
          #p "400400400400"
          error = REXML::XPath.first(msg, "/ErrorResponse/Reason/text()")
             
          if error == "Validation Errors Occurred"  
              error1 = REXML::XPath.first(msg, "/ErrorResponse/ValidationErrors/ValidationError/RuleMessage/text()")
              @response = error1
              if @response == nil    
                  @response = "Bad Request" 
                  return @response
              else
                  return @response  
              end
          else 
             @response = error
            # p @response
             if @response == nil    
                  @response = "Bad Request" 
                  return @response
              else
                  return @response  
              end
          end
        else
           return @response
        end
    end

  end
end
