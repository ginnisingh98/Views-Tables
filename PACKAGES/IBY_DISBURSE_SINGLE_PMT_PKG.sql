--------------------------------------------------------
--  DDL for Package IBY_DISBURSE_SINGLE_PMT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_DISBURSE_SINGLE_PMT_PKG" AUTHID CURRENT_USER AS
/*$Header: ibysings.pls 120.12.12010000.3 2009/04/29 07:08:20 bkjain ship $*/

 TYPE payreq_tbl_type IS TABLE of iby_pay_service_requests.
                                      payment_service_request_id%TYPE
    INDEX BY BINARY_INTEGER;

 --
 -- These two records store the distinct payment
 -- functions, and orgs that are present in a
 -- payment request.
 --
 -- The disbursement UI uses the data in this table to
 -- restrict access to the user (depending upon the
 -- users' payment function and organization).
 --
 TYPE distinctPmtFxAccessType IS RECORD (
     object_id
         IBY_PROCESS_FUNCTIONS.object_id%TYPE,
     object_type
         IBY_PROCESS_FUNCTIONS.object_type%TYPE,
     payment_function
         IBY_PROCESS_FUNCTIONS.payment_function%TYPE
 );

 TYPE distinctOrgAccessType IS RECORD (
     object_id
         IBY_PROCESS_ORGS.object_id%TYPE,
     object_type
         IBY_PROCESS_ORGS.object_type%TYPE,
     org_type
         IBY_PROCESS_ORGS.org_type%TYPE,
     org_id
         IBY_PROCESS_ORGS.org_id%TYPE
 );

 --
 -- Table of distinct access types.
 --
 TYPE distinctPmtFxAccessTab IS TABLE OF distinctPmtFxAccessType
     INDEX BY BINARY_INTEGER;

 TYPE distinctOrgAccessTab IS TABLE OF distinctOrgAccessType
     INDEX BY BINARY_INTEGER;

 --
 -- Record to store the default payment processing
 -- attributes derived from the payment process profile.
 --
 -- TYPE profileProcessAttribs IS RECORD (
 --     processing_type
 --        IBY_PAYMENT_PROFILES.processing_type%TYPE
 -- );

 /*
  * Record to store transaction error id from
  * IBY_TRANSACTION_ERRORS table.
  */
 TYPE trxnErrorIdRecType IS RECORD (
     trxn_error_id
         IBY_TRANSACTION_ERRORS.transaction_error_id%TYPE
 );

 /*
  * Table of transaction error ids.
  */
 TYPE trxnErrorIdsTab IS TABLE OF trxnErrorIdRecType
     INDEX BY BINARY_INTEGER;

/*--------------------------------------------------------------------
 | NAME:
 |     submit_single_payment
 |
 | PURPOSE:
 |     Entry point for the single payment API; This procedure will return
 |     a success/failure response back to the caller synchronously.
 |
 |     It is the callers responsibility to perform a COMMIT in case of
 |     success (rollback in case of failure). This API will not perform
 |     a commit.
 |
 |     Functional blocks of this API include -
 |       - validate the provided document payable
 |       - create a payment
 |       - validate the payment
 |       - create a payment instruction
 |       - validate the payment instruction
 |       - invoke extract/format for the created instruction
 |       - mark the payment complete
 |
 |     Single payments are automatically marked complete by this API.
 |     That is the understanding with the calling application as well.
 |
 |     For this reason, single payments should not be again marked complete
 |     by the user (this is handled in the iPayment UI).
 |
 |     Note 1: it is the calling applications responsibility to ensure
 |     that all the hardcoded grouping rules are applied on the documents
 |     payable *before* the single payment API is invoked. This is to
 |     ensure that the single payment API does not generate multiple
 |     payments after grouping the provided documents payable.
 |
 |     If such a situation arises, the single payment API will fail the
 |     request.
 |
 |     Note 2: Only one payment will be created by the single payment API
 |     regardless of the number of provided documents payable (this is
 |     ensured because of Note 1).
 |
 |     Since only one payment is created, it also follows that the single
 |     payment API will only create a single payment instruction with this
 |     payment.
 |
 | PARAMETERS:
 |    IN
 |
 |    p_api_version
 |
 |    p_init_msg_list
 |
 |    p_calling_app_id
 |        The 3-character product code of the calling application. Example,
 |        '200' for Oracle Payables.
 |
 |    p_calling_app_payreq_cd
 |        Id of the payment service request from the calling app's
 |        point of view. For a given calling app, this id should be
 |        unique.
 |
 |    p_is_manual_payment_flag
 |        Specifies whether this payment is a manual payment or
 |        a quick payment. Manual payments are payments made outside
 |        of Oracle Payments that need to be recorded. Manual
 |        payments do not undergo any validation, the given payment is
 |        simply inserted into IBY tables.
 |
 |    p_payment_function
 |        Payment function. Used in setting the payee context.
 |
 |    p_internal_bank_account_id
 |        The internal bank account to pay from.
 |
 |    p_pay_process_profile_id
 |        Payment process profile. The payment profile drives how this
 |        payment is processed in IBY.
 |
 |    p_payment_method_cd
 |        The payment method.
 |
 |    p_legal_entity_id
 |        Legal entity.
 |
 |    p_organization_id
 |        Org id. Used in setting the payee context.
 |
 |    p_organization_type
 |        Org type. Used in setting the payee context.
 |
 |    p_payment_date
 |        The payment date.
 |        Currently not used.
 |
 |    p_payment_amount
 |        The payment amount.
 |
 |    p_payment_currency
 |        The payment currency.
 |
 |    p_payee_party_id
 |        Payee party id. Used in setting the payee context.
 |
 |    p_payee_party_site_id
 |        Payee party site id. Used in setting the payee context.
 |
 |    p_supplier_site_id
 |        Supplier site id. Used in setting the payee context.
 |
 |    p_payee_bank_account_id
 |        Payee bank account id. Only relevant for electronic single payments.
 |        Currently not used.
 |
 |    p_override_pmt_complete_pt
 |        Override completion point flag. If this flag is set to 'Y', IBY
 |        will immediately mark the single payment as completed without
 |        waiting for the pre-set completion event.
 |
 |    p_bill_payable_flag
 |        Indicates whether this payment is a future-dated payment.
 |        Currently not used.
 |
 |    p_anticipated_value_date
 |        Anticipated value date.
 |        Currently not used.
 |
 |    p_maturity_date
 |        Payment maturity date/
 |        Required parameter if the payment is a future-dated payment.
 |        Currently not used.
 |
 |    p_payment_document_id
 |        The paper document (check stock) to be used for numbering and
 |        printing of the payment. Only relevant for printed payments.
 |        If not provided, this value will be derived from the payment
 |        process profile.
 |
 |    p_paper_document_number
 |        The number of the paper document (check number). Only relevant
 |        for printed single payments. If this value is not provided
 |        the next available paper document number will be used.
 |
 |    p_printer_name
 |        Printer name is required if the payment needs to be printed
 |        immediately.
 |
 |    p_print_immediate_flag
 |        Whether to print the payment immediately. If set to N, user
 |        will have to initiate printing from the IBY UI.
 |
 |
 |    p_transmit_immediate_flag
 |       Flag indicating whether this payment needs to be transmitted
 |       to the bank immediately upon formatting. Only relevant for
 |       electronic payments. If this param is set to N, user will have
 |       to initiate transmission from the IBY UI.
 |
 |    p_payee_address_line1 .. p_payee_address_line4
 |        Payee address lines.  If payee address information is
 |        provided as API params, then these would be used to create
 |        the payment. If not provided, the payment would be stamped
 |        with the address information derived from payee party site id.
 |
 |    p_payee_address_city
 |        Payee city.
 |
 |    p_payee_address_county
 |        Payee county.
 |
 |    p_payee_address_state
 |        Payee state.
 |
 |    p_payee_address_zip
 |        Payee postal code.
 |
 |    p_payee_address_country
 |        Payee country.
 |
 |    p_attribute_category
 |        Descriptive flex fields category.
 |        Currently not used.
 |
 |    p_attribute1 .. p_attribute15
 |        Descriptive flex field attributes.
 |        Currently not used.
 |
 | OUT
 |
 |    x_num_printed_docs
 |        Total number of printed documents generated after numbering.
 |        This will include the actual single payment [1 document] plus
 |        any setup and overflow documents.
 |
 |    x_payment_id
 |        Payment id of the actual single payment. This value maps to
 |        IBY_PAYMENTS_ALL.payment_id.
 |
 |    x_paper_doc_num
 |        Paper document number of the actual single payment. This could be
 |        a check number, for example.
 |
 |    x_pmt_ref_num
 |        Payment reference number stamped by IBY on the actual single
 |        payment. Use this payment reference number when interacting with
 |        third parties e.g., banks.
 |
 |    x_return_status
 |        Return status of the API.
 |
 |        S - Success
 |        E - Error / failure
 |        U - Unexpected / system error
 |
 |    x_error_ids_tab
 |        List of validation error ids that map to
 |        IBY_TRANSACTION_ERRORS.transaction_error_id. Use these
 |        error ids to look up this table for list of validation errors.
 |
 |        This parameter is only relevant when the return status is E.
 |
 |    x_msg_count
 |        Generated FND messages count.
 |
 |    x_msg_data
 |        Generated FND messages. This param is only relevant in case
 |        the return status is U. Unwind the message stack to see list
 |        of exceptions / system errors.
 |
 | RETURNS:
 |
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE submit_single_payment(
     p_api_version                IN         NUMBER,
     p_init_msg_list              IN         VARCHAR2,
     p_calling_app_id             IN         NUMBER,
     p_calling_app_payreq_cd      IN         VARCHAR2,
     p_is_manual_payment_flag     IN         VARCHAR2,
     p_payment_function           IN         VARCHAR2,
     p_internal_bank_account_id   IN         NUMBER,
     p_pay_process_profile_id     IN         NUMBER,
     p_payment_method_cd          IN         VARCHAR2,
     p_legal_entity_id            IN         NUMBER,
     p_organization_id            IN         NUMBER,
     p_organization_type          IN         VARCHAR2,
     p_payment_date               IN         DATE,
     p_payment_amount             IN         NUMBER,
     p_payment_currency           IN         VARCHAR2,
     p_payee_party_id             IN         NUMBER,
     p_payee_party_site_id        IN         NUMBER   DEFAULT NULL,
     p_supplier_site_id           IN         NUMBER   DEFAULT NULL,
     p_payee_bank_account_id      IN         NUMBER,
     p_override_pmt_complete_pt   IN         VARCHAR2,
     p_bill_payable_flag          IN         VARCHAR2,
     p_anticipated_value_date     IN         DATE     DEFAULT NULL,
     p_maturity_date              IN         DATE,
     p_payment_document_id        IN         NUMBER,
     p_paper_document_number      IN         NUMBER,
     p_printer_name               IN         VARCHAR2,
     p_print_immediate_flag       IN         VARCHAR2,
     p_transmit_immediate_flag    IN         VARCHAR2,
     p_payee_address_line1        IN         VARCHAR2 DEFAULT NULL,
     p_payee_address_line2        IN         VARCHAR2 DEFAULT NULL,
     p_payee_address_line3        IN         VARCHAR2 DEFAULT NULL,
     p_payee_address_line4        IN         VARCHAR2 DEFAULT NULL,
     p_payee_address_city         IN         VARCHAR2 DEFAULT NULL,
     p_payee_address_county       IN         VARCHAR2 DEFAULT NULL,
     p_payee_address_state        IN         VARCHAR2 DEFAULT NULL,
     p_payee_address_zip          IN         VARCHAR2 DEFAULT NULL,
     p_payee_address_country      IN         VARCHAR2 DEFAULT NULL,
     p_attribute_category         IN         VARCHAR2 DEFAULT NULL,
     p_attribute1                 IN         VARCHAR2 DEFAULT NULL,
     p_attribute2                 IN         VARCHAR2 DEFAULT NULL,
     p_attribute3                 IN         VARCHAR2 DEFAULT NULL,
     p_attribute4                 IN         VARCHAR2 DEFAULT NULL,
     p_attribute5                 IN         VARCHAR2 DEFAULT NULL,
     p_attribute6                 IN         VARCHAR2 DEFAULT NULL,
     p_attribute7                 IN         VARCHAR2 DEFAULT NULL,
     p_attribute8                 IN         VARCHAR2 DEFAULT NULL,
     p_attribute9                 IN         VARCHAR2 DEFAULT NULL,
     p_attribute10                IN         VARCHAR2 DEFAULT NULL,
     p_attribute11                IN         VARCHAR2 DEFAULT NULL,
     p_attribute12                IN         VARCHAR2 DEFAULT NULL,
     p_attribute13                IN         VARCHAR2 DEFAULT NULL,
     p_attribute14                IN         VARCHAR2 DEFAULT NULL,
     p_attribute15                IN         VARCHAR2 DEFAULT NULL,
     x_num_printed_docs           OUT NOCOPY NUMBER,
     x_payment_id                 OUT NOCOPY NUMBER,
     x_paper_doc_num              OUT NOCOPY NUMBER,
     x_pmt_ref_num                OUT NOCOPY NUMBER,
     x_return_status              OUT NOCOPY VARCHAR2,
     x_error_ids_tab              OUT NOCOPY trxnErrorIdsTab,
     x_msg_count                  OUT NOCOPY NUMBER,
     x_msg_data                   OUT NOCOPY VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     insert_payreq
 |
 |
 | PURPOSE:
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 FUNCTION insert_payreq (
     p_calling_app_id         IN IBY_PAY_SERVICE_REQUESTS.calling_app_id%TYPE,
     p_calling_app_payreq_cd  IN IBY_PAY_SERVICE_REQUESTS.
                                    call_app_pay_service_req_code%TYPE,
     p_internal_bank_account_id
                              IN IBY_PAY_SERVICE_REQUESTS.
                                     internal_bank_account_id%TYPE,
     p_pay_process_profile_id
                              IN IBY_PAY_SERVICE_REQUESTS.
                                     payment_profile_id%TYPE,
     p_is_manual_payment_flag IN VARCHAR2
     )
     RETURN NUMBER;

/*--------------------------------------------------------------------
 | NAME:
 |     populateOutParams
 |
 | PURPOSE:
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE populateOutParams(
     p_payreq_id          IN IBY_PAY_SERVICE_REQUESTS.
                                 payment_service_request_id%TYPE,
     p_processing_type    IN IBY_PAYMENT_PROFILES.processing_type%TYPE,
     x_num_printed_docs   OUT NOCOPY NUMBER,
     x_payment_id         OUT NOCOPY IBY_PAYMENTS_ALL.
                                 payment_id%TYPE,
     x_paper_doc_num      OUT NOCOPY IBY_PAYMENTS_ALL.
                                 paper_document_number%TYPE,
     x_pmt_ref_num        OUT NOCOPY IBY_PAYMENTS_ALL.
                                 payment_reference_number%TYPE
     );

/*--------------------------------------------------------------------
 | NAME:
 |     retrieve_transaction_errors
 |
 |
 | PURPOSE:
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE retrieve_transaction_errors(
     p_payreq_id        IN IBY_PAY_SERVICE_REQUESTS.
                            payment_service_request_id%TYPE,
     x_trxnErrorIdsTab  IN OUT NOCOPY trxnErrorIdsTab
     );

/*--------------------------------------------------------------------
 | NAME:
 |     provide_pmt_reference_num
 |
 |
 | PURPOSE:
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 FUNCTION provide_pmt_reference_num
     RETURN NUMBER;


/*--------------------------------------------------------------------
 | NAME:
 |     print_debuginfo
 |
 | PURPOSE:
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE print_debuginfo(p_module IN VARCHAR2,
     p_debug_text IN VARCHAR2);


END IBY_DISBURSE_SINGLE_PMT_PKG;

/
