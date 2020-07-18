module Velocity
  module VelocityException
    module VelocityErrors
      CWSFault                                        = Class.new(StandardError) # 207
      CWSInvalidOperationFault                        = Class.new(StandardError) # 208
      CWSValidationResultFault                        = Class.new(StandardError) # 225
      CWSInvalidMessageFormatFault                    = Class.new(StandardError) # 306
      CWSDeserializationFault                         = Class.new(StandardError) # 312
      CWSExtendedDataNotSupportedFault                = Class.new(StandardError) # 313
      CWSInvalidServiceConfigFault                    = Class.new(StandardError) # 314
      CWSOperationNotSupportedFault                   = Class.new(StandardError) # 317
      CWSTransactionFailedFault                       = Class.new(StandardError) # 318
      CWSTransactionAlreadySettledFault               = Class.new(StandardError) # 327
      CWSConnectionFault                              = Class.new(StandardError) # 328
      BadRequestError                                 = Class.new(StandardError) # 400
      SystemFault                                     = Class.new(StandardError) # 401
      AuthenticationFault                             = Class.new(StandardError) # 406
      STSUnavailableFault                             = Class.new(StandardError) # 412
      AuthorizationFault                              = Class.new(StandardError) # 413
      ClaimNotFoundFault                              = Class.new(StandardError) # 415
      AccessClaimNotFoundFault                        = Class.new(StandardError) # 416
      DuplicateClaimFault                             = Class.new(StandardError) # 420
      DuplicateUserFault                              = Class.new(StandardError) # 421
      ClaimTypeNotAllowedFault                        = Class.new(StandardError) # 422
      ClaimSecurityDomainMismatchFault                = Class.new(StandardError) # 423
      ClaimPropertyValidationFault                    = Class.new(StandardError) # 424
      RelyingPartyNotAssociatedToSecurityDomainFault  = Class.new(StandardError) # 450
      NotFoundError                                   = Class.new(StandardError) # 404
      InternalServerError                             = Class.new(StandardError) # 500
      ServiceUnavailableError                         = Class.new(StandardError) # 503
      GatewayTimeoutError                             = Class.new(StandardError) # 504
      InvalidTokenFault                               = Class.new(StandardError) # 5005
      CWSTransactionServiceUnavailableFault           = Class.new(StandardError) # 9999
      UnexpectedError                                 = Class.new(StandardError) # 9999 Use your own message
      ParameterMissing                                = Class.new(StandardError)
      ApplicationAndMerchentProfileidFault            = Class.new(StandardError)
      ErrorInVerifyXmlFault                           = Class.new(StandardError)
      ErrorAuthXmlFault                               = Class.new(StandardError)
      ErrorAauthncapXmlFault                          = Class.new(StandardError)
      ErrorCapXmlFault                                = Class.new(StandardError)
      ErrorAdjXmlFault                                = Class.new(StandardError)
      ErrorUndoXmlFault                               = Class.new(StandardError)
      ErrorRetuByidXml                                = Class.new(StandardError)
    end

    module VelocityErrorMessages
      MESSAGE = {
        # connection messages
        cws_fault: "General CWS fault",
        cws_invalid_operation_fault: "Invalid operation is being attempted",
        cws_validation_result_fault: "Xml validation Errors",
        cws_invalid_message_format_fault: "Invalid Message Format",
        cws_deserialization_fault: "Deserialization not Successfull",
        cws_extended_data_not_supported_fault: "Manage Billing Data Not Supported",
        cws_invalid_service_config_fault: "Invalid Service Configuration",
        cws_operation_not_supported_fault: "Operation Not Supported",
        cws_transaction_failed_fault: "Transaction Failed",
        cws_transaction_already_settled_fault: "Transaction Already Settled",
        cws_connection_fault: "Connection Failure",
        bad_request_error: "Bad Request",
        system_fault: "System problem",
        authentication_fault: "Authentication Failure",
        sts_unavailable_fault: "Security Token Service is unavailable",
        authorization_fault: "Authorization Failure",
        claim_not_found_fault: "Claim Not Found",
        access_claim_not_found_fault: "Access Claim Not Found",
        duplicate_claim_fault: "Duplicate Claim",
        duplicate_user_fault: "Duplicate User",
        claim_type_not_allowed_fault: "Claim Type Not Allowed",
        claim_security_domain_mismatch_fault: "Claim Security Domain Mismatch",
        claim_property_validation_fault: "Claim Property Validation",
        relying_party_not_associated_to_security_domain_fault: "Relying Party Not Associated To Security Domain",
        not_found_error: "Not Forund",
        internal_server_error: "Internal Server Error",
        service_unavailable_error: "Service Unavailable",
        gateway_timeout_error: "Gateway Time out",
        invalid_token_fault: "Invalid Token",
        cws_transaction_service_unavailable_fault: "Transaction Service Unavailable",
        err_transparent_js: "Post data is not set from transparent redirect.",
        err_session_xml_not_set: "Before curl request session and/or xml not set!",
        err_credential_not_set: "Error one or credential not like applicationid, merchantprofileid etc.",
        err_post_method: "Error in path and/or data array in post method.",
        err_get_method: "Error in path and/or data array in get method.",
        err_put_method: "Error in path and/or data array in put method.",
        err_attribute_arr_not_set: "attributes array returned from authorize response is not set!",
        err_unknown: "unknown error in response data!",
        err_signon: "invalid identity token",
        # verify
        err_verf_sesstoken: "session token is not set for verify request!",
        err_verf_avswflid: "PaymentAccountDataToken and/or workflowid are not set!",
        err_verf_attr_aray: "After authorization attribute array is not!",
        err_verf_tran_data: "transaction data array not set for verify request",
        error_in_verify_xml_fault: "Some value not set in xml for verify!",
         # authorize
        err_auth_sesstoken: "session token is not set for authorize request!",
        err_aurh_avswflid: "PaymentAccountDataToken and/or workflowid are not set!",
        err_aurh_attr_aray: "After authorization attribute array is not!",
        err_auth_tran_data: "transaction data array not set for authorize request",
        error_auth_xml_fault: "Some value not set in xml for authorize!",
        # capture
        err_cap_sesswfltransid: "for capture sessiontoken, workflowid and/or transaction id are not set!",
        err_cap_transid_amount: "transaction id and/or amount not set in xml for captureXML!",
        error_cap_xml_fault: "Some value not set in xml for capture!",
        # adjust
        err_adjust_sesswfltransid: "for adjust sessiontoken, workflowid and/or transaction id are not set!",
        err_ver_auth_cap_path: "verify or authorize or authorizeandcapture request path not set proper!",
        err_adj_transid_amount: "transaction id and/or amount not set in xml for adjustXML!",
        error_adj_xml_fault: "Some value not set in xml for adjust!",
        # authorizeandcapture
        err_authncap_data_array: "authorizeandcapture data array not set!",
        error_authncap_xml_fault: "authorizeandcapture reqest xml object is null!",
        err_aurhncap_avswflid: "PaymentAccountDataToken, avsdata and/or workflowid are not set!",
        # undo
        err_undo_transid: "transaction id not set in xml for undoXML!",
        error_undo_xml_fault: "Some value not set in xml for undo!",
        err_undo_sesswfltransid: "for undo sessiontoken, workflowid and/or transaction id are not set!",
        # returnbyid
        err_return_data_array: "transaction id and/or amount not set in xml for returnByIdXML!",
        error_retu_byid_xml: "Some value not set in xml for returnById!",
        err_return_tranidwid: "for returnbyId sessiontoken, workflowid and/or transaction id are not set!",
        err_return_unlinked_amnt: "for returnunlinked sessiontoken, workflowid and/or transaction id are not set!",
        err_returnun_data_array: "Some value not set in xml for returnUnlinkedXML!",
        parameter_missing: "Parameter is missing, please provide parameters.",
        #querytransactiondetails
        application_and_merchent_profileid_fault: "Error in applicationprofileid or merchantprofileid",
        qtd_parameter_missing: "Some value not set in querytransactiondetail, batchid, transactionid or capturedates"
      }
    end
  end
end
