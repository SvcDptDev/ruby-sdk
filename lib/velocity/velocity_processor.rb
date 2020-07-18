require "base64"
require "nokogiri"
require "httparty"
require "rexml/document"
require_relative "velocity_exception"
require_relative "velocity_xml_creator"
require_relative "velocity_connection"
include Velocity::VelocityException::VelocityErrors
include Velocity::VelocityException::VelocityErrorMessages

module Velocity
  class VelocityProcessor
    # This class represents a Velocity Transaction.
    # It can be used to query and
    # "verify/authorize/authorizeandcapture/capture/undo/adjust/returnbyid/
    # returnunlinked/captureall/querytransactionsdetails" transactions.

    attr_accessor :session_token,
                  :identity_token,
                  :work_flow_id,
                  :application_profile_id,
                  :merchant_profile_id

    def initialize(identity_token, work_flow_id, application_profile_id, merchant_profile_id)
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
      Velocity::VelocityXmlCreator.new(application_profile_id, merchant_profile_id)
    end

    # Paths for requests, according to request needed.
    URL = if Rails.env.production?
            "https://api.nabcommerce.com/REST/2.0.18/Txn/"
          else
            "https://api.cert.nabcommerce.com/REST/2.0.18/Txn/"
          end
    QTD_URL = if Rails.env.production?
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
      response_xml = HTTParty.post(
        URL + work_flow_id.to_s + "/" + "verify",
        body:    xmlbody.verifyXML(params),
        headers: { "Authorization" => "Basic #{session_token.signOn}" },
        verify:  false,
        timeout: 60
      )
      processError?(response_xml)
    rescue StandardError => e
      "Transaction details not set for verify request - #{e.message}"
    end

    # ----------------------------> authorize Method  <----------------------------- #

    # "authorize" method for making POST request.
    # In this method Authorize a payment_method for a particular amount.
    # This Method create corresponding xml for gateway request.
    # This Method Reqest send to gateway and handle the response.
    # "params" hash,this hash holds collection of transaction details.
    # It returns response_xml is object of successfull or failure of gateway response.
    def authorize(params)
      response_xml = HTTParty.post(
        URL + work_flow_id.to_s,
        body:    xmlbody.authorizeXML(params),
        headers: { "Authorization" => "Basic #{session_token.signOn}" },
        verify:  false,
        timeout: 60
      )
      processError?(response_xml)
    rescue StandardError => e
      "Transaction details not set for authorize request - #{e.message}"
    end

    # ------------------------> authorizeAndCapture Method  <--------------------------- #

    # "authorizeAndCapture" method for making POST request.
    # "In this method authorizeAndCapture operation is used to authorize transactions by performing
    #   a check on cardholder"s funds and reserves".
    # The authorization amount if sufficient funds are available.
    # This Method create corresponding xml for gateway request.
    # This Method Reqest send to gateway and handle the response.
    # params hash,this hash holds collection of transaction details.
    # It returns response_xml is object of successfull or failure of gateway response.
    def authorizeAndCapture(params)
      response_xml = HTTParty.post(
        URL + work_flow_id.to_s,
        body:    xmlbody.authorizeAndCaptureXML(params),
        headers: { "Authorization" => "Basic #{session_token.signOn}" },
        verify:  false,
        timeout: 60
      )
      processError?(response_xml)
    rescue StandardError => e
      "For authorizeAndCapture PaymentAccountDataToken,"\
      "Carddata and/or workflowid are not set! - #{e.message}"
    end

    # ----------------------------> capture Method  <----------------------------- #

    # "capture" method for making PUT request.
    # "Captures an authorization. Optionally specify an amount to do a partial capture of the
    #  initial authorization. The default is to capture the full amount of the authorization".
    # params hash,this hash holds collection of transaction details.
    # It returns response_xml is object of successfull or failure of gateway response.
    def capture(params)
      transaction_id = params[:TransactionId].to_s
      response_xml = HTTParty.put(
        URL + work_flow_id.to_s + "/" + transaction_id,
        body:    xmlbody.captureXML(params),
        headers: { "Authorization" => "Basic #{session_token.signOn}" },
        verify:  false,
        timeout: 60
      )
      processError?(response_xml)
    rescue StandardError => e
      "For capture amount and/or transaction id are not set! - #{e.message}"
    end

    # ----------------------------> undo Method  <----------------------------- #

    # "undo" method for making PUT request.
    # "The Undo operation is used to release cardholder funds by performing a void (Credit Card) or
    # reversal (PIN Debit) on a previously authorized transaction that has not been captured
    # (flagged) for settlement."
    # params hash,this hash holds collection of transaction details.
    # It returns response_xml is object of successfull or failure of gateway response.
    def undo(params)
      transaction_id = params[:TransactionId].to_s
      response_xml = HTTParty.put(
        URL + work_flow_id.to_s + "/" + transaction_id,
        body:    xmlbody.undoXML(params),
        headers: { "Authorization" => "Basic #{session_token.signOn}" },
        verify:  false,
        timeout: 60
      )
      processError?(response_xml)
    rescue StandardError => e
      "For undo amount and/or transaction id are not set! - #{e.message}"
    end

    # ---------------------------------> adjust Method  <----------------------------- #

    # "adjust" method for making PUT request.
    # "Adjust this transaction. If the transaction has not yet been captured and settled
    # it can be Adjust to
    # A previously authorized amount (incremental or reversal) prior to capture and settlement."
    # params hash,this hash holds collection of transaction details.
    # It returns response_xml is object of successfull or failure of gateway response.
    def adjust(params)
      transaction_id = params[:TransactionId].to_s
      response_xml = HTTParty.put(
        URL + work_flow_id.to_s + "/" + transaction_id,
        body:    xmlbody.adjustXML(params),
        headers: { "Authorization" => "Basic #{session_token.signOn}" },
        verify:  false,
        timeout: 60
      )
      processError?(response_xml)
    rescue StandardError => e
      "For adjust amount and/or transaction id are not set! - #{e.message}"
    end

    # ----------------------------> returnById Method  <----------------------------- #

    # "returnById" method for making POST request.
    # "The ReturnById operation is used to perform a linked credit to a cardholder's account from
    #  the merchant's account based on a previously authorized and settled transaction."
    # params hash,this hash holds collection of transaction details.
    # It returns response_xml is object of successfull or failure of gateway response.
    def returnById(params)
      response_xml = HTTParty.post(
        URL + work_flow_id.to_s,
        body:    xmlbody.returnByIdXML(params),
        headers: { "Authorization" => "Basic #{session_token.signOn}" },
        verify:  false,
        timeout: 60
      )
      processError?(response_xml)
    rescue StandardError => e
      "For returnById amount and/or transaction id are not set! - #{e.message}"
    end

    # ----------------------------> returnUnlinked Method  <----------------------------- #

    # "returnUnlinked" method for making POST request.
    # The ReturnUnlinked operation is used to perform an "unlinked", or standalone, credit to
    # a cardholder's account from the merchant's account.
    # This operation is useful when a return transaction is not associated with a previously
    # authorized and settled transaction.
    # params hash,this hash holds collection of transaction details.
    # It returns response_xml is object of successfull or failure of gateway response.
    def returnUnlinked(params)
      response_xml = HTTParty.post(
        URL + work_flow_id.to_s,
        body:    xmlbody.returnUnlinkedXML(params),
        headers: { "Authorization" => "Basic #{session_token.signOn}" },
        verify:  false,
        timeout: 60
      )
        processError?(response_xml)
    rescue StandardError => e
      "For authorizeAndCapture PaymentAccountDataToken, "\
      "Carddata and/or workflowid are not set! - #{e.message}"
    end

    # ----------------------------> captureAll Method  <----------------------------- #

    # "captureAll" method for making PUT request.
    # The CaptureAll operation is used to flag all transactions for settlement that have
    # been successfully authorized using the Authorize operation.
    # params hash,this hash holds collection of transaction details.
    # It returns response_xml is object of successfull or failure of gateway response.
    def captureAll
      response_xml = HTTParty.put(
        URL + work_flow_id.to_s,
        body:    xmlbody.captureAllXML,
        headers: { "Authorization" => "Basic #{session_token.signOn}" },
        verify:  false,
        timeout: 60
      )
      p response_xml
      processError?(response_xml)
    rescue StandardError => e
      "For captureAll sessiontoken, workflowid are not set! - #{e.message}"
      #return ex.message
    end

    # ----------------------> queryTransactionsDetail Method  <------------------------- #

    # "queryTransactionsDetail" method for making POST request.
    # In this operation queries the specified transactions and returns both summary details
    # and full transaction details as a serialized object.
    # This method contains the same search criteria and includeRelated functionality as
    # QueryTransactionsSummary.
    # params hash,this hash holds collection of transaction details.
    # It returns response_xml is object of successfull or failure of gateway response.
    def queryTransactionsDetail(params)
      response_xml = HTTParty.post(
        QTD_URL,
        body:    xmlbody.queryTransactionsDetailJSON(params),
        headers: {
          "Authorization" => "Basic #{session_token.signOn}",
          "Content-Type" => "application/json"
        },
        verify:  false,
        timeout: 60
      )
      @response = response_xml
      if @response.size.zero?
        @response = "No query transaction details were found"
        return @response
      else
        response_xml = @response
        processError?(response_xml)
      end
    rescue StandardError => e
      "Some value not set in querytransactiondetail, "\
      "batchid, transactionid or transactiondates! - #{e.message}"
    end

    private

    # processError? method in Velocity response for error messages
    # response_xml is response object, error message created on the basis of gateway error status.
    # @response.code comming from gateway response status.
    # In this method returns error massages or
    def processError?(response_xml)
      @response = response_xml
      # p @response
      msg = REXML::Document.new("<ClientResponse>" + @response.body + "</ClientResponse>")
      if @response.code == 200 || @response.code == 201
        # p "200200200200"
        error = REXML::XPath.first(
          msg,
          "/ClientResponse/BankcardTransactionResponsePro/Status/text()"
        )
        return @response unless error == "Failure"

        return [
          REXML::XPath.first(
            msg,
            "/ClientResponse/BankcardTransactionResponsePro/Status/text()"
          ),
          REXML::XPath.first(
            msg,
            "/ClientResponse/BankcardTransactionResponsePro/StatusMessage/text()"
          )
        ]
        # return @response
      elsif @response.code == 400 || @response.code == 500 || @response.code == 5000
        # p "400400400400"
        error = REXML::XPath.first(msg, "/ClientResponse/ErrorResponse/Reason/text()")

        if error == "Validation Errors Occurred"
          error1 = REXML::XPath.first(
            msg,
            "/ClientResponse/ErrorResponse/ValidationErrors/ValidationError/RuleMessage/text()"
          )
          @response = error1
        else
          @response = error
          # p @response
        end
        @response = "Bad Request" if @response.nil?
        return @response
      else
        return @response
      end
    end
  end
end
