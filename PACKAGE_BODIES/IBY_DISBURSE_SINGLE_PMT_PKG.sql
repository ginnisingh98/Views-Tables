--------------------------------------------------------
--  DDL for Package Body IBY_DISBURSE_SINGLE_PMT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_DISBURSE_SINGLE_PMT_PKG" AS
/*$Header: ibysingb.pls 120.55.12010000.11 2010/02/16 09:21:24 asarada ship $*/

 --
 -- Declare global variables
 --
 G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBY_DISBURSE_SINGLE_PMT_PKG';
G_CURRENT_RUNTIME_LEVEL      CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
 --
 -- List of instruction statuses that are used / set in this
 -- module.
 --
 INS_STATUS_CREATED         CONSTANT VARCHAR2(100) := 'CREATED';

 --
 -- List of payment request statuses that are used in this
 -- module.
 --
 REQ_STATUS_INSERTED        CONSTANT VARCHAR2(100) := 'INSERTED';
 REQ_STATUS_SUBMITTED       CONSTANT VARCHAR2(100) := 'SUBMITTED';
 REQ_STATUS_ASGN_COMPLETE   CONSTANT VARCHAR2(100) := 'ASSIGNMENT_COMPLETE';
 REQ_STATUS_VALIDATED       CONSTANT VARCHAR2(100) := 'DOCUMENTS_VALIDATED';
 REQ_STATUS_RETRY_DOC_VALID CONSTANT VARCHAR2(100) :=
                                         'RETRY_DOCUMENT_VALIDATION';
 REQ_STATUS_PAY_CRTD        CONSTANT VARCHAR2(100) := 'PAYMENTS_CREATED';
 REQ_STATUS_RETRY_PMT_CREAT CONSTANT VARCHAR2(100) := 'RETRY_PAYMENT_CREATION';

 --
 -- List of payment statuses that are used / set in this
 -- module.
 --
 PMT_STATUS_INS_CREATED    CONSTANT VARCHAR2(100) := 'INSTRUCTION_CREATED';
 PMT_STATUS_SETUP          CONSTANT VARCHAR2(100) := 'VOID_BY_SETUP';
 PMT_STATUS_OVERFLOW       CONSTANT VARCHAR2(100) := 'VOID_BY_OVERFLOW';
 PMT_STATUS_FAIL_VALID     CONSTANT VARCHAR2(100) := 'FAILED_VALIDATION';
 PMT_STATUS_ISSUED         CONSTANT VARCHAR2(100) := 'ISSUED';
 PMT_STATUS_FORMATTED      CONSTANT VARCHAR2(100) := 'FORMATTED';

 --
 -- List of document statuses that are used / set in this
 -- module.
 --
 DOC_STATUS_SUBMITTED       CONSTANT VARCHAR2(100) := 'SUBMITTED';

 --
 -- List of rejection level system options that are used in
 -- this module.
 --
 REJ_LVL_REQUEST  CONSTANT VARCHAR2(100) := 'REQUEST';

 -- Transaction types (for selection from IBY_TRANSACTION_ERRORS table)
 TRXN_TYPE_DOC   CONSTANT VARCHAR2(100) := 'DOCUMENT_PAYABLE';
 TRXN_TYPE_PMT   CONSTANT VARCHAR2(100) := 'PAYMENT';
 TRXN_TYPE_INS   CONSTANT VARCHAR2(100) := 'INSTRUCTION';

 /*
  * Paper document usage reasons.
  */
 DOC_USE_ISSUED      CONSTANT VARCHAR2(100) := 'ISSUED';

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
     )
 IS
 l_return_status  VARCHAR2 (100);
 l_return_message VARCHAR2 (3000);
 l_ret_status     NUMBER;

 l_payreq_status  VARCHAR2 (100);
 l_payreq_id      IBY_PAY_SERVICE_REQUESTS.payment_service_request_id%TYPE;
 l_is_duplicate   BOOLEAN := TRUE;
 l_module_name    VARCHAR2(200) := G_PKG_NAME ||
                                       '.submit_single_payment';

 l_api_version    CONSTANT NUMBER       := 1.0;
 l_api_name       CONSTANT VARCHAR2(30) := 'submit_single_payment';

 l_errbuf         VARCHAR2(5000);
 l_retcode        VARCHAR2(2000);

 l_msg_count       NUMBER;
 l_msg_data        VARCHAR2(4000);

 /* hook related params */
 l_pkg_name       VARCHAR2(200);
 l_callout_name   VARCHAR2(500);
 l_stmt           VARCHAR2(1000);
 l_error_code     VARCHAR2(3000);

 /* used in validating provided paper doc number */
 l_paper_doc_num              NUMBER;
 l_last_issued_paper_doc_num  NUMBER;
 l_next_avlbl_paper_doc_num   NUMBER;

 /*
  * If a single document in the request fails validation,
  * fail the entire request.
  */
 l_document_rejection_level VARCHAR2(100) := REJ_LVL_REQUEST;
 l_payment_rejection_level  VARCHAR2(100) := REJ_LVL_REQUEST;

 /* since the user has created the payment, there is no need to review it */
 l_review_proposed_pmts_flag VARCHAR2(1)  := 'N';

 /* these are used in payment instruction creation */
 l_profile_attribs    IBY_DISBURSE_SUBMIT_PUB_PKG.profileProcessAttribs;
 l_pmtInstrTab        IBY_PAYINSTR_PUB.pmtInstrTabType;

 /* used to record manual payments */
 l_pmt_rec            IBY_PAYMENTS_ALL%ROWTYPE;
 l_pmts_tab           IBY_PAYGROUP_PUB.paymentTabType;
 l_payment_id         IBY_PAYMENTS_ALL.payment_id%TYPE;

 /* used to store access types for manual payment */
 l_process_func_rec   IBY_PROCESS_FUNCTIONS%ROWTYPE;
 l_process_org_rec    IBY_PROCESS_ORGS%ROWTYPE;

 /* used to store transaction error ids that are returned to caller */
 l_trxnErrorIdsTab    trxnErrorIdsTab;

 /* stores the created payment instruction */
 l_pmtInstrRec        IBY_PAY_INSTRUCTIONS_ALL%ROWTYPE;

 /* transmit immediately flag - for electronic payments */
 l_transmit_now_flag  VARCHAR2(1);

 l_msg_index_out   NUMBER;

 l_trx_pmt_index      BINARY_INTEGER := 0;

 /*
  * Cursor to pick up all document errors that
  * were generated during the processing of this single
  * payment.
  */
 CURSOR c_doc_errors_list (p_payreq_id NUMBER)
 IS
 SELECT
     err.transaction_error_id
 FROM
     IBY_TRANSACTION_ERRORS   err,
     IBY_DOCS_PAYABLE_ALL     doc,
     IBY_PAY_SERVICE_REQUESTS prq
 WHERE
     err.transaction_id             = doc.document_payable_id        AND
     err.transaction_type           = TRXN_TYPE_DOC                  AND
     doc.payment_service_request_id = prq.payment_service_request_id AND
     prq.payment_service_request_id = p_payreq_id
     ;

 /*
  * Cursor to pick up all payment errors that
  * were generated during the processing of this single
  * payment.
  */
 CURSOR c_pmt_errors_list (p_payreq_id NUMBER)
 IS
 SELECT
     err.transaction_error_id
 FROM
     IBY_TRANSACTION_ERRORS   err,
     IBY_PAYMENTS_ALL         pmt,
     IBY_PAY_SERVICE_REQUESTS prq
 WHERE
     err.transaction_id             = pmt.payment_id                 AND
     err.transaction_type           = TRXN_TYPE_PMT                  AND
     pmt.payment_service_request_id = prq.payment_service_request_id AND
     prq.payment_service_request_id = p_payreq_id
     ;

 /*
  * Cursor to pick up all payment instruction errors that
  * were generated during the processing of this single
  * payment.
  */
 CURSOR c_pmtinstr_errors_list (p_payreq_id NUMBER)
 IS
 SELECT
     err.transaction_error_id
 FROM
     IBY_TRANSACTION_ERRORS   err,
     IBY_PAYMENTS_ALL         pmt,
     IBY_PAY_INSTRUCTIONS_ALL ins,
     IBY_PAY_SERVICE_REQUESTS prq
 WHERE
     err.transaction_id             = ins.payment_instruction_id     AND
     err.transaction_type           = TRXN_TYPE_INS                  AND
     pmt.payment_service_request_id = prq.payment_service_request_id AND
     pmt.payment_instruction_id     = ins.payment_instruction_id     AND
     prq.payment_service_request_id = p_payreq_id
     ;

 /*
  * Implementing the callout is optional for the calling app.
  * If the calling app does not implement the hook, then
  * the call to the hook will result in ORA-06576 error.
  *
  * There is no exception name associated with this code, so
  * we create one called 'PROCEDURE_NOT_IMPLEMENTED'. If this
  * exception occurs, it is not fatal: we log the error and
  * proceed.
  *
  * If, on the other hand, the calling app implements the
  * callout, but the callout throws an exception, it is fatal
  * and we must abort the program (this will be caught
  * in WHEN OTHERS block).
  */
 PROCEDURE_NOT_IMPLEMENTED EXCEPTION;
 PRAGMA EXCEPTION_INIT(PROCEDURE_NOT_IMPLEMENTED, -6576);

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

	     print_debuginfo(l_module_name, 'Calling app id: ' || p_calling_app_id);
	     print_debuginfo(l_module_name, 'Calling app pay req cd: '
	         || p_calling_app_payreq_cd);

     END IF;
     /* standard call to check for api compatibility */
     IF NOT FND_API.Compatible_API_Call(
                l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME) THEN

         FND_MESSAGE.SET_NAME('IBY', 'IBY_204400_API_VER_MISMATCH');
         FND_MSG_PUB.Add;

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

     END IF;

     /* initialize message list if p_init_msg_list is set to TRUE. */
     IF FND_API.to_Boolean(p_init_msg_list) THEN
         FND_MSG_PUB.initialize;
     END IF;

     /* initialize API return status to success */
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     /*
      * Check if parameters are correctly provided.
      */

     /*
      * Maturity date is mandatory in case bill payable flag
      * is set to 'Y'.
      */
     IF (UPPER(p_bill_payable_flag) = 'Y' AND p_maturity_date IS NULL) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Maturity date is '
	             || 'mandatory if ''bill payable flag'' is set to '
	             || '''Y''.'
	             );

	         print_debuginfo(l_module_name, 'Single payment request '
	             || 'cannot be processed further. '
	             || 'Exiting ..');

         END IF;
         /*
          * Return error status and exit.
          */
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         FND_MESSAGE.SET_NAME('IBY', 'IBY_MATURITY_DATE_REQD');
         FND_MSG_PUB.ADD;

         FND_MSG_PUB.COUNT_AND_GET(
             p_count => x_msg_count,
             p_data  => x_msg_data
             );

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, '+--------------------------------------+');
	     print_debuginfo(l_module_name, '|STEP 1: Insert Payment Service Request|');
	     print_debuginfo(l_module_name, '+--------------------------------------+');

     END IF;
     /*
      * STEP 1:
      *
      * Insert payment request into IBY_PAY_SERVICE_REQUESTS
      * table and generate payment request id.
      */
     BEGIN

         /*
          * First check whether this is a duplicate request.
          *
          * In the case a duplicate request, this function will
          * return the previously generated payment request id.
          *
          * In the case of a new request, this function will
          * return 0
          */
         l_payreq_id := IBY_DISBURSE_SUBMIT_PUB_PKG.
                            checkIfDuplicate(
                                p_calling_app_id,
                                p_calling_app_payreq_cd);

         IF (l_payreq_id = 0) THEN
             l_is_duplicate := FALSE;
         END IF;

         /*
          * Insert the payment request only if it is not a duplicate.
          */
         IF (l_is_duplicate = FALSE) THEN
             l_payreq_id := insert_payreq(
                                p_calling_app_id,
                                p_calling_app_payreq_cd,
                                p_internal_bank_account_id,
                                p_pay_process_profile_id,
                                p_is_manual_payment_flag
                                );

             IF (l_payreq_id = -1) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Could not insert payment '
	                     || 'service request for calling app id '
	                     || p_calling_app_id
	                     || ', calling app payment service request cd '
	                     || p_calling_app_payreq_cd
	                     );

	                  print_debuginfo(l_module_name, 'Single payment request '
	                      || 'cannot be processed further. '
	                      || 'Exiting ..');

                  END IF;
                  /*
                   * Return error status and exit.
                   */
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                  FND_MESSAGE.SET_NAME('IBY', 'IBY_SINGPAY_INSERT_FAILED');
                  FND_MSG_PUB.ADD;

                  FND_MSG_PUB.COUNT_AND_GET(
                      p_count => x_msg_count,
                      p_data  => x_msg_data
                      );

                  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                  print_debuginfo(l_module_name, 'EXIT');

                  END IF;
                  RETURN;

             ELSE

                  /*
                   * Payment service request as successfully inserted
                   * into the DB. Commit at this point.
                   */
                  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                  print_debuginfo(l_module_name, 'Payment service request '
	                      || 'inserted successfully into the database.'
	                      || 'Payment request id: '
	                      || l_payreq_id);

                  END IF;
             END IF;

         ELSE
                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Payment service '
	                     || 'request '
	                     || p_calling_app_payreq_cd
	                     || ' is a duplicate. Skipping insert of request '
	                     );

                 END IF;
         END IF; -- if not duplicate

     END;


     /*
      * Check whether this is a manual payment. Manual
      * payments are payments that have been directly
      * from AP and simply needs to be recorded in IBY.
      *
      * Manual payments follow a special payment processing
      * logic - no validations are necessary and no need
      * to insert documents payable of the manual payment.
      */
     IF (UPPER(p_is_manual_payment_flag) = 'Y') THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'This is a manual payment.');

         END IF;
         /*
          * Fix for bug 5237833:
          *
          * Manual payments can be electronic payments as
          * well. So do not blindly validate the paper
          * document number.
          *
          * If the processing type for the provided profile
          * is ELECTRONIC, skip paper document number validation.
          */

         /*
          * Get the processing type for the provided payment
          * profile. This will determine whether this manual
          * payment is electronic or printed.
          */
         IBY_DISBURSE_SUBMIT_PUB_PKG.get_profile_process_attribs(
             p_pay_process_profile_id,
             l_profile_attribs
             );

         /*
          * Validate the paper document number only for 'printed'
          * processing type.
          */

         IF (l_profile_attribs.processing_type = 'PRINTED' OR
              (l_profile_attribs.processing_type = 'ELECTRONIC' AND
                                p_payment_document_id IS NOT NULL)) THEN

             l_paper_doc_num := p_paper_document_number;
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Provided '
	                 || 'paper document number: '
	                 || l_paper_doc_num
	                 );

             END IF;
             /*
              * Call paper document number validation API.
              */
             IBY_DISBURSE_UI_API_PUB_PKG.validate_paper_doc_number(
                 l_api_version,
                 FND_API.G_FALSE,
                 p_payment_document_id,
                 l_paper_doc_num,
                 l_return_status,
                 x_msg_count,
                 x_msg_data
                 );

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Return status after paper '
	                 || 'document number validation: '
	                 || l_return_status
	                 );

             END IF;
             IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Paper document number '
	                     || l_paper_doc_num
	                     || ' failed validation.'
	                     );

	                 print_debuginfo(l_module_name, 'Manual payment will '
	                     || 'not be inserted into database. Returning failure '
	                     || 'response.'
	                     );

                 END IF;
                 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'EXIT');

                 END IF;
                 RETURN;

             ELSE

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Paper document number '
	                     || l_paper_doc_num
	                     || ' passed validation.'
	                     );

                 END IF;
             END IF;

             /*
              * If we reached here, it means that the provided paper
              * document number is valid.
              *
              * Mark the provided paper document number as used so that
              * it will not be available again.
              */

             /*
              * STEP A:
              *
              * Update the last issued document number in
              * CE_PAYMENT_DOCUMENTS table if the user
              * provided paper document number is greater
              * than the existing last issued paper doc num.
              *
              * Calling the validate_paper_doc_number(..) with
              * a null value will provide us the next available
              * paper doc number. By subtracting 1 from this value
              * we get the last issued paper doc number.
              */
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Determining whether to update '
	                 || 'last issued paper doc num for provided check stock ..'
	                 );

             END IF;
             IBY_DISBURSE_UI_API_PUB_PKG.validate_paper_doc_number(
                 l_api_version,
                 FND_API.G_FALSE,
                 p_payment_document_id,
                 l_next_avlbl_paper_doc_num,
                 l_return_status,
                 x_msg_count,
                 x_msg_data
                 );

             l_last_issued_paper_doc_num := l_next_avlbl_paper_doc_num - 1;

             IF (l_paper_doc_num > l_last_issued_paper_doc_num) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Provided paper doc number '
	                     || l_paper_doc_num
	                     || ' is greater than the last issued paper doc num '
	                     || l_last_issued_paper_doc_num
	                     );


                 END IF;
                 /*
                  * Update the check stock to reflect the latest used
                  * check number.
                  */
                 UPDATE
                     CE_PAYMENT_DOCUMENTS
                 SET
                     last_issued_document_number = l_paper_doc_num
                 WHERE
                     payment_document_id         = p_payment_document_id
                 ;

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Updated CE_PAYMENT_DOCUMENTS '
	                     || 'table to use '
	                     || l_paper_doc_num
	                     || ' as last issued paper document number.'
	                     );

                 END IF;
             ELSE

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Provided paper doc number '
	                     || l_paper_doc_num
	                     || ' is less than the last issued paper doc num '
	                     || l_last_issued_paper_doc_num
	                     );

	                 print_debuginfo(l_module_name, 'Last issued paper doc num '
	                     || ' will not be updated.'
	                     );

                 END IF;
             END IF;


             /*
              * STEP B:
              *
              * The IBY_USED_PAYMENT_DOCS table contains
              * all the used paper document numbers.
              *
              * Insert the used document number into the used
              * payment documents table.
              */

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Inserting paper document '
	                 || 'number '
	                 || l_paper_doc_num
	                 || ' into IBY_USED_PAYMENT_DOCS table.'
	                 );

             END IF;
             INSERT INTO IBY_USED_PAYMENT_DOCS (
                 PAYMENT_DOCUMENT_ID,
                 USED_DOCUMENT_NUMBER,
                 DATE_USED,
                 DOCUMENT_USE,
                 CREATED_BY,
                 CREATION_DATE,
                 LAST_UPDATED_BY,
                 LAST_UPDATE_DATE,
                 LAST_UPDATE_LOGIN,
                 OBJECT_VERSION_NUMBER
                 )
             VALUES (
                 p_payment_document_id,
                 l_paper_doc_num,
                 sysdate,
                 DOC_USE_ISSUED,
                 fnd_global.user_id,
                 sysdate,
                 fnd_global.user_id,
                 sysdate,
                 fnd_global.login_id,
                 1
                 );

         ELSE

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'This is an electronic '
	                 || 'manual payment. '
	                 );

             END IF;
         END IF; -- if processing type is PRINTED

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Invoking payment recording logic ..');

         END IF;
         IBY_PAYGROUP_PUB.getNextPaymentID(l_payment_id);

         --print_debuginfo(l_module_name, 'Got the payment id as: ' || IBY_PAYGROUP_PUB.getNextPaymentID(l_payment_id));

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Before calling initialize_pmt_table..');

         END IF;
         IBY_PAYGROUP_PUB.initialize_pmt_table(l_trx_pmt_index);

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Successfully came out of the call initialize_pmt_table..');

         END IF;
         FOR l_trx_pmt_index IN nvl(IBY_PAYGROUP_PUB.pmtTable.payment_id.FIRST,0) .. nvl(IBY_PAYGROUP_PUB.pmtTable.payment_id.LAST,-99)
         LOOP

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	          print_debuginfo(l_module_name, 'Inside the for loop for manual payments ..');
          END IF;
         IBY_PAYGROUP_PUB.pmtTable.payment_id(l_trx_pmt_index)   := l_payment_id;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'l_payment_id is ' || IBY_PAYGROUP_PUB.pmtTable.payment_id(l_trx_pmt_index));

         END IF;
         /*
          * Fix for bug 4956141:
          *
          * Provide payment reference number for manual payments.
          */
         IBY_PAYGROUP_PUB.pmtTable.
             payment_reference_number(l_trx_pmt_index)   := provide_pmt_reference_num();

         IF (IBY_PAYGROUP_PUB.pmtTable.payment_reference_number(l_trx_pmt_index) = -1) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Unable to provide payment '
	                 || 'reference for manual payment.'
	                 );

	             print_debuginfo(l_module_name, 'Manual payment will '
	                 || 'not be inserted into database. Returning failure '
	                 || 'response.'
	                 );

             END IF;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'EXIT');

             END IF;
             RETURN;

         END IF;

         IBY_PAYGROUP_PUB.pmtTable.payment_method_code(l_trx_pmt_index)  := p_payment_method_cd;
         IBY_PAYGROUP_PUB.pmtTable.payment_service_request_id(l_trx_pmt_index) := l_payreq_id;
         IBY_PAYGROUP_PUB.pmtTable.process_type(l_trx_pmt_index)         := 'MANUAL';

         /*
          * The final status of the manual payment is dependant
          * upon whether it is an printed or an electronic
          * payment.
          */
         IF (l_profile_attribs.processing_type = 'PRINTED') THEN
             IBY_PAYGROUP_PUB.pmtTable.payment_status(l_trx_pmt_index)       := PMT_STATUS_ISSUED;
         ELSE
             IBY_PAYGROUP_PUB.pmtTable.payment_status(l_trx_pmt_index)       := PMT_STATUS_FORMATTED;
         END IF;

         IBY_PAYGROUP_PUB.pmtTable.payment_function(l_trx_pmt_index)      := p_payment_function;
         IBY_PAYGROUP_PUB.pmtTable.payment_amount(l_trx_pmt_index)        := p_payment_amount;
         IBY_PAYGROUP_PUB.pmtTable.payment_currency_code(l_trx_pmt_index) := p_payment_currency;
         IBY_PAYGROUP_PUB.pmtTable.internal_bank_account_id(l_trx_pmt_index) := p_internal_bank_account_id;
         IBY_PAYGROUP_PUB.pmtTable.org_id(l_trx_pmt_index)               := p_organization_id;
         IBY_PAYGROUP_PUB.pmtTable.org_type(l_trx_pmt_index)             := p_organization_type;
         IBY_PAYGROUP_PUB.pmtTable.legal_entity_id(l_trx_pmt_index)      := p_legal_entity_id;
         IBY_PAYGROUP_PUB.pmtTable.payments_complete_flag(l_trx_pmt_index)   := 'Y';
         IBY_PAYGROUP_PUB.pmtTable.ext_payee_id(l_trx_pmt_index)         := IBY_DISBURSE_SUBMIT_PUB_PKG.
                                               derivePayeeIdFromContext(
                                                   p_payee_party_id,
                                                   p_payee_party_site_id,
                                                   p_supplier_site_id,
                                                   p_organization_id,
                                                   p_organization_type,
                                                   p_payment_function
                                                   );
         IBY_PAYGROUP_PUB.pmtTable.payee_party_id(l_trx_pmt_index)       := p_payee_party_id;
         IBY_PAYGROUP_PUB.pmtTable.party_site_id(l_trx_pmt_index)        := p_payee_party_site_id;
         IBY_PAYGROUP_PUB.pmtTable.supplier_site_id(l_trx_pmt_index)     := p_supplier_site_id;
         IBY_PAYGROUP_PUB.pmtTable.payment_profile_id(l_trx_pmt_index)   := p_pay_process_profile_id;
         IBY_PAYGROUP_PUB.pmtTable.payment_date(l_trx_pmt_index)         := p_payment_date;
         IBY_PAYGROUP_PUB.pmtTable.anticipated_value_date(l_trx_pmt_index) := p_anticipated_value_date;

         /*
          * Fix for bug 5727990:
          *
          * If the payment type is electronic then set the
          * paper document number to null (instead of -1).
          */
         IF (l_profile_attribs.processing_type = 'ELECTRONIC' AND p_paper_document_number = -1) THEN
             IBY_PAYGROUP_PUB.pmtTable.paper_document_number(l_trx_pmt_index) := NULL;
         ELSE
	     IBY_PAYGROUP_PUB.pmtTable.paper_document_number(l_trx_pmt_index) := p_paper_document_number;
         END IF;

         IBY_PAYGROUP_PUB.pmtTable.maturity_date(l_trx_pmt_index)        := p_maturity_date;
         IBY_PAYGROUP_PUB.pmtTable.bill_payable_flag(l_trx_pmt_index)    := p_bill_payable_flag;
         IBY_PAYGROUP_PUB.pmtTable.attribute_category(l_trx_pmt_index)   := p_attribute_category;
         IBY_PAYGROUP_PUB.pmtTable.attribute1(l_trx_pmt_index)           := p_attribute1;
         IBY_PAYGROUP_PUB.pmtTable.attribute2(l_trx_pmt_index)           := p_attribute2;
         IBY_PAYGROUP_PUB.pmtTable.attribute3(l_trx_pmt_index)           := p_attribute3;
         IBY_PAYGROUP_PUB.pmtTable.attribute4(l_trx_pmt_index)           := p_attribute4;
         IBY_PAYGROUP_PUB.pmtTable.attribute5(l_trx_pmt_index)           := p_attribute5;
         IBY_PAYGROUP_PUB.pmtTable.attribute6(l_trx_pmt_index)           := p_attribute6;
         IBY_PAYGROUP_PUB.pmtTable.attribute7(l_trx_pmt_index)           := p_attribute7;
         IBY_PAYGROUP_PUB.pmtTable.attribute8(l_trx_pmt_index)           := p_attribute8;
         IBY_PAYGROUP_PUB.pmtTable.attribute9(l_trx_pmt_index)           := p_attribute9;
         IBY_PAYGROUP_PUB.pmtTable.attribute10(l_trx_pmt_index)          := p_attribute10;
         IBY_PAYGROUP_PUB.pmtTable.attribute11(l_trx_pmt_index)          := p_attribute11;
         IBY_PAYGROUP_PUB.pmtTable.attribute12(l_trx_pmt_index)          := p_attribute12;
         IBY_PAYGROUP_PUB.pmtTable.attribute13(l_trx_pmt_index)          := p_attribute13;
         IBY_PAYGROUP_PUB.pmtTable.attribute14(l_trx_pmt_index)          := p_attribute14;
         IBY_PAYGROUP_PUB.pmtTable.attribute15(l_trx_pmt_index)          := p_attribute15;

         END LOOP;

         --l_pmts_tab(l_pmts_tab.COUNT)   := l_pmt_rec;

         /*
          * Insert manual payment into IBY_PAYMENTS_ALL
          * table.
          */
         IBY_PAYGROUP_PUB.insertPayments;

         /*
          * Fix for bug 5727990:
          *
          * Invoke auditPaymentData(..) to populate bank
          * related information on the payment record.
          */
         IBY_PAYGROUP_PUB.auditPaymentData(l_trx_pmt_index);

         IBY_PAYGROUP_PUB.updatePayments();

         /*
          * Fix for bug 5337475:
          *
          * Derive the process org and process funtion from the
          * payment on this request and insert them as process
          * functions and process orgs associated with this
          * request.
          *
          * If this is not done, the UI will not allow the user
          * to see the manual payment.
          */
         /* process function for this manual payment */
         l_process_func_rec.payment_function := p_payment_function;
         l_process_func_rec.object_id        := l_payreq_id;
         l_process_func_rec.object_type      := 'PAYMENT_REQUEST';

         INSERT INTO IBY_PROCESS_FUNCTIONS
             (
             object_id,
             object_type,
             payment_function
             )
         VALUES
             (
             l_process_func_rec.object_id,
             l_process_func_rec.object_type,
             l_process_func_rec.payment_function
             )
             ;

         /* process org for this manual payment */
         l_process_org_rec.org_id            := p_organization_id;
         l_process_org_rec.org_type          := p_organization_type;
         l_process_org_rec.object_id         := l_payreq_id;
         l_process_org_rec.object_type       := 'PAYMENT_REQUEST';

         INSERT INTO IBY_PROCESS_ORGS
             (
             object_id,
             object_type,
             org_id,
             org_type
             )
         VALUES
             (
             l_process_org_rec.object_id,
             l_process_org_rec.object_type,
             l_process_org_rec.org_id,
             l_process_org_rec.org_type
             )
             ;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Finished inserting '
	             || 'access types for this manual payment ..'
	             );

         END IF;
         /*
          * If the payment has been recorded, return success.
          *
          * We will not do a commit here. It is the callers
          * responsibility to commit.
          */
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Manual payment '
	             || 'has been recorded in IBY with payment id '
	             || l_payment_id
	             || ' [pmt reference number = '
	             || IBY_PAYGROUP_PUB.pmtTable.payment_reference_number(l_trx_pmt_index)
	             || ']'
	             || ' [paper document number = '
	             || IBY_PAYGROUP_PUB.pmtTable.paper_document_number(l_trx_pmt_index)
	             || ']'
	             );

         END IF;
         /* return back the payment id to the caller */
         x_payment_id    := l_payment_id;

	 /* Bug 7330978 - return back the payment reference number and paper document number to the caller */
	 x_pmt_ref_num   := IBY_PAYGROUP_PUB.pmtTable.payment_reference_number(l_trx_pmt_index);
         x_paper_doc_num   := IBY_PAYGROUP_PUB.pmtTable.paper_document_number(l_trx_pmt_index);

         x_return_status := FND_API.G_RET_STS_SUCCESS;

         /*
          * Log all the params that we are passing back
          * to the caller.
          */
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name,
	             'List of params passed back to caller - ');
	         print_debuginfo(l_module_name, 'x_num_printed_docs = '
	             || x_num_printed_docs);
	         print_debuginfo(l_module_name, 'x_payment_id = '
	             || x_payment_id);
	         print_debuginfo(l_module_name, 'x_paper_doc_num = '
	             || x_paper_doc_num);
	         print_debuginfo(l_module_name, 'x_pmt_ref_num = '
	             || x_pmt_ref_num);
	         print_debuginfo(l_module_name, 'x_return_status = '
	             || x_return_status);

	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     END IF; -- if manual payment


     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, '+------------------------+');
	     print_debuginfo(l_module_name, '|STEP 2: Insert Documents|');
	     print_debuginfo(l_module_name, '+------------------------+');

     END IF;
     /*
      * STEP 2:
      *
      * Insert the documents of this payment request into the
      * IBY_DOCS_PAYABLE_ALL table.
      */

     BEGIN

         /*
          * Insert the payment request documents only if the
          * request is not a duplicate.
          */
         IF (l_is_duplicate = FALSE) THEN
             l_payreq_status := IBY_DISBURSE_SUBMIT_PUB_PKG.
                                    get_payreq_status(l_payreq_id);

             IF (l_payreq_status = REQ_STATUS_INSERTED) THEN

                 l_ret_status := IBY_DISBURSE_SUBMIT_PUB_PKG.
                                     insert_payreq_documents(
                                         p_calling_app_id,
                                         p_calling_app_payreq_cd,
                                         l_payreq_id
                                         );

                 IF (l_ret_status = -1) THEN

                     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                     print_debuginfo(l_module_name, 'Could not insert '
	                         || 'documents payable for payment service '
	                         || 'request. Calling app id '
	                         || p_calling_app_id
	                         || ', calling app payment service request cd '
	                         || p_calling_app_payreq_cd
	                         );

	                      print_debuginfo(l_module_name, 'Single payment '
	                          || 'request cannot be processed further. '
	                          || 'Exiting ..');

                      END IF;
                      /* store error ids in output param */
                      retrieve_transaction_errors(
                          l_payreq_id,
                          x_error_ids_tab
                          );

                      /*
                       * Return error status and exit.
                       */
                      FND_MESSAGE.SET_NAME('IBY', 'IBY_SINGPAY_DOCS_FAILED');
                      FND_MSG_PUB.ADD;

                      FND_MSG_PUB.COUNT_AND_GET(
                          p_count => x_msg_count,
                          p_data  => x_msg_data
                          );

                      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                      print_debuginfo(l_module_name, 'EXIT');

                      END IF;
                      RETURN;

                 END IF;

             END IF;

         ELSE
                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Payment service '
	                     || 'request '
	                     || p_calling_app_payreq_cd
	                     || ' is a duplicate. Skipping insert of documents '
	                     );


                 END IF;
         END IF; -- if not duplicate

     END;

     /*
      * STEP 3:
      *
      * Call the build program functional flows one-by-one.
      */

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, '+-----------------------------------+');
	     print_debuginfo(l_module_name, '|STEP 3A: Account/Profile Assignment|');
	     print_debuginfo(l_module_name, '+-----------------------------------+');

     END IF;
     /*
      * F4 - Account Profile / Assignment Flow
      *
      * Check if the payment requests is in 'submitted'
      * status, and assign default payment profiles/
      * internal bank accounts to each document in the
      * request, if the documents do not already have them.
      */
     BEGIN
         l_payreq_status := IBY_DISBURSE_SUBMIT_PUB_PKG.
                                get_payreq_status(l_payreq_id);

         IF (l_payreq_status = REQ_STATUS_SUBMITTED) THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Found payment request '
	                 || l_payreq_id
	                 || ' in "submitted" status.'
	                 );

	             print_debuginfo(l_module_name, 'Going to perform '
	                 || 'assignments for payment req id: '
	                 || l_payreq_id);

             END IF;
             IBY_ASSIGN_PUB.performAssignments(
                                l_payreq_id,
                                l_return_status);

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Request status after '
	                 || 'assignments: ' || l_return_status);

             END IF;
         END IF;

         IF (l_return_status <> REQ_STATUS_ASGN_COMPLETE) THEN

             /*
              * If assignments for single payment request are not
              * complete, set the return status to an error status.
              */
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Setting return status of API to '
	                 || FND_API.G_RET_STS_ERROR
	                 || ' because assignments were incomplete.'
	                 );

             END IF;
             /* store error ids in output param */
             retrieve_transaction_errors(
                 l_payreq_id,
                 x_error_ids_tab
                 );

             /*
              * Return error status and exit.
              */
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Returning error response .. ');
             END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'EXIT');

             END IF;
             RETURN;

         END IF;

     EXCEPTION

         WHEN OTHERS THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Exception occured when performing '
	             || 'assignments. Assignment flow will be aborted and no '
	             || 'assignments will be committed for payment request '
	             || l_payreq_id
	             );
	          print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	          print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);

          END IF;
          /* store error ids in output param */
          retrieve_transaction_errors(
              l_payreq_id,
              x_error_ids_tab
              );

          /*
           * Return error status and exit.
           */
          FND_MESSAGE.SET_NAME('IBY', 'IBY_ASSIGNMENTS_FAILED');
          FND_MSG_PUB.ADD;

          FND_MSG_PUB.COUNT_AND_GET(
              p_count => x_msg_count,
              p_data  => x_msg_data
              );

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	          print_debuginfo(l_module_name, 'EXIT');

          END IF;
          RETURN;

     END;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, '+----------------------------+');
	     print_debuginfo(l_module_name, '|STEP 3B: Document Validation|');
	     print_debuginfo(l_module_name, '+----------------------------+');

     END IF;
     /*
      * F5 - Document Validation Flow (Part I)
      *
      * Check if the payment request is in 'ASSIGNMENT_COMPLETE' status.
      * 'ASSIGNMENT_COMPLETE' indicates that the all the data elements
      * required for building payments are present in the payment request.
      *
      * Validate the documents of thsi payment request.
      */
     BEGIN

         l_payreq_status := IBY_DISBURSE_SUBMIT_PUB_PKG.
                                get_payreq_status(l_payreq_id);

         IF (l_payreq_status = REQ_STATUS_ASGN_COMPLETE) THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Found payment request '
	                 || l_payreq_id
	                 || ' in "assignment complete" status.'
	                 );

	             print_debuginfo(l_module_name, 'Going to validate documents '
	                     || 'for payment request '
	                     || l_payreq_id);

             END IF;
             IBY_VALIDATIONSETS_PUB.applyDocumentValidationSets(
                                        l_payreq_id,
                                        l_document_rejection_level,
                                        TRUE,
                                        l_return_status);

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Request status after '
	                 || 'document validation: ' || l_return_status);

             END IF;
         END IF;

         IF (l_return_status <> REQ_STATUS_VALIDATED) THEN

             /*
              * If documents of the single payment request were not
              * successfully validated set the return status to an
              * error status.
              */
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Setting return status of API to '
	                 || FND_API.G_RET_STS_ERROR
	                 || ' because document validations failed.'
	                 );

             END IF;
             /* store error ids in output param */
             retrieve_transaction_errors(
                 l_payreq_id,
                 x_error_ids_tab
                 );

             /*
              * Return error status and exit.
              */
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Returning error response .. ');
             END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'EXIT');

             END IF;
             RETURN;

         END IF;

     EXCEPTION

         WHEN OTHERS THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Exception occured when validating '
	             || 'documents. Document validation will be aborted and no '
	             || 'document statuses will be committed for payment request '
	             || l_payreq_id
	             );
	         print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	         print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);

         END IF;
          /* store error ids in output param */
          retrieve_transaction_errors(
              l_payreq_id,
              x_error_ids_tab
              );

         /*
          * Return error status and exit.
          */

         FND_MESSAGE.SET_NAME('IBY', 'IBY_DOC_VALIDATION_FAILED');
         FND_MSG_PUB.ADD;

         FND_MSG_PUB.COUNT_AND_GET(
             p_count => x_msg_count,
             p_data  => x_msg_data
             );

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     END;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, '+-------------------------+');
	     print_debuginfo(l_module_name, '|STEP 3D: Payment Creation|');
	     print_debuginfo(l_module_name, '+-------------------------+');

     END IF;
     /*
      * F6 - Payment Creation Flow (Part I)
      *
      * Find all payment requests that are in 'validated' status
      * and create payments from the documents of such requests.
      */

     BEGIN
         l_payreq_status := IBY_DISBURSE_SUBMIT_PUB_PKG.
                                get_payreq_status(l_payreq_id);

         IF (l_payreq_status = REQ_STATUS_VALIDATED) THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Found payment request '
	                 || l_payreq_id
	                 || ' in "validated" status.'
	                 );

	             print_debuginfo(l_module_name, 'Going to create payments '
	                 || 'for payment request '
	                 || l_payreq_id);

             END IF;
             IBY_PAYGROUP_PUB.createPayments(
                                 l_payreq_id,
                                 l_payment_rejection_level,
                                 l_review_proposed_pmts_flag,
                                 p_override_pmt_complete_pt,
                                 p_bill_payable_flag,
                                 p_maturity_date,
                                 G_PKG_NAME,
                                 l_return_status);

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Request status after payment '
	                 || 'creation: ' || l_return_status);

             END IF;
         END IF;

         IF (l_return_status <> REQ_STATUS_PAY_CRTD) THEN

             /*
              * If documents of the single payment request were not
              * successfully grouped into a payment set the return
              * status to an error status.
              */
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Setting return status of API to '
	                 || FND_API.G_RET_STS_ERROR
	                 || ' because payment creation failed.'
	                 );

             END IF;
             /* store error ids in output param */
             retrieve_transaction_errors(
                 l_payreq_id,
                 x_error_ids_tab
                 );

             /*
              * Return error status and exit.
              */
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Returning error response .. ');
             END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'EXIT');

             END IF;
             RETURN;

         END IF;

     EXCEPTION

         WHEN OTHERS THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Exception occured when '
	             || 'building payments. Payment creation will be '
	             || 'aborted and no payments will be committed for '
	             || 'payment request '
	             || l_payreq_id
	             );
	         print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	         print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);

         END IF;
          /* store error ids in output param */
          retrieve_transaction_errors(
              l_payreq_id,
              x_error_ids_tab
              );

         /*
          * Return error status and exit.
          */

         FND_MESSAGE.SET_NAME('IBY', 'IBY_PMT_CREATION_FAILED');
         FND_MSG_PUB.ADD;

         FND_MSG_PUB.COUNT_AND_GET(
             p_count => x_msg_count,
             p_data  => x_msg_data
             );

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     END;

     /*
      * If we reached here, it means that the build program
      * finished successfully. Set the response message to
      * 'success'.
      */
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     l_payreq_status := IBY_DISBURSE_SUBMIT_PUB_PKG.
                            get_payreq_status(l_payreq_id);

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Final status of payment request '
	         || l_payreq_id
	         || ' (calling app pay req cd: '
	         || p_calling_app_payreq_cd
	         || ') before payment instruction creation is '
	         || l_payreq_status
	         );

     END IF;
     /*
      * If we reached here, it means that payment creation was
      * successful. Invoke payment instruction creation.
      */

     /*
      * Get the processing type for the provided payment
      * profile. This is needed for payment instruction
      * creation.
      */
     IBY_DISBURSE_SUBMIT_PUB_PKG.get_profile_process_attribs(
         p_pay_process_profile_id,
         l_profile_attribs
         );

     /*
      * Before attempting to create payment instructions
      * check if the provided paper document number is
      * valid. If not, abort processing here.
      *
      * Fix for bug 5060974:
      *
      * Validate the paper document number only for 'printed'
      * processing type.
      */

     IF (l_profile_attribs.processing_type = 'PRINTED' OR
           (l_profile_attribs.processing_type = 'ELECTRONIC' AND
                                p_payment_document_id IS NOT NULL)) THEN

         l_paper_doc_num := p_paper_document_number;

         IBY_DISBURSE_UI_API_PUB_PKG.validate_paper_doc_number(
             l_api_version,
             FND_API.G_FALSE,
             p_payment_document_id,
             l_paper_doc_num,
             l_return_status,
             x_msg_count,
             x_msg_data,
             FND_API.G_FALSE
             );

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Paper document number '
	                 || l_paper_doc_num
	                 || ' failed validation. Aborting ..'
	                 );

             END IF;
             APP_EXCEPTION.RAISE_EXCEPTION;

         ELSE

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Paper document number '
	                 || l_paper_doc_num
	                 || ' passed validation.'
	                 );

             END IF;
         END IF;

     ELSE

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Not validating paper document '
	             || 'number because processing type for profile '
	             || p_pay_process_profile_id
	             || ' is ELECTRONIC.'
	             );

         END IF;
     END IF; -- if processing type is 'PRINTED'

     /*
      * If processing type is electronic, then we need to pass
      * the 'transmit now flag' with a valid value.
      *
      * If the caller has not provided a value for this flag
      * default the value based on the profile.
      */
     l_transmit_now_flag := p_transmit_immediate_flag;

     IF (l_profile_attribs.processing_type = 'ELECTRONIC') THEN

         IF (p_transmit_immediate_flag IS NULL) THEN

             l_transmit_now_flag := l_profile_attribs.transmit_now_flag;

         END IF;

     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Invoking payment instruction '
	         || 'creation using processing type: '
	         || l_profile_attribs.processing_type
	         );

     END IF;
     /*
      * Now, create a payment instruction for the
      * inserted payment.
      */
     IBY_PAYINSTR_PUB.createPaymentInstructions(
         l_profile_attribs.processing_type,
         p_payment_document_id,
         p_printer_name,
         p_print_immediate_flag,
         l_transmit_now_flag,
         NULL,                       /* admin assigned ref */
         NULL,                       /* comments */
         NULL,                       /* pmt profile id */
         p_calling_app_id,
         p_calling_app_payreq_cd,
         l_payreq_id,
         p_internal_bank_account_id,
         p_payment_currency,
         p_legal_entity_id,
         p_organization_id,
         p_organization_type,
         NULL,
         NULL,
         'Y',                        /* single payments flow flag */
         l_pmtInstrTab,
         l_return_status,
         x_msg_count,
         x_msg_data
         );

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Return status of payment '
	         || 'instruction creation: '
	         || l_return_status
	         );

     END IF;
     --IBY_BUILD_INSTRUCTIONS_PUB_PKG.build_pmt_instructions(
     --    l_errbuf,
     --    l_retcode,
     --    l_profile_attribs.processing_type,
     --    p_payment_document_id,
     --    p_print_immediate_flag,
     --    p_printer_name,
     --    NULL,                       /* transmit now flag */
     --    NULL,                       /* admin assigned ref */
     --    NULL,                       /* comments */
     --    NULL,                       /* pmt profile id */
     --    p_internal_bank_account_id,
     --    p_calling_app_id,
     --    p_calling_app_payreq_cd,
     --    p_payment_currency,
     --    p_legal_entity_id,
     --    p_organization_id,
     --    p_organization_type,
     --    NULL,
     --    NULL
     --    );

     --print_debuginfo(l_module_name, 'Return code after payment '
     --    || 'instruction creation: '
     --    || l_retcode
     --    );

     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

         /*
          * If the payment instruction was not successfully
          * created set the return status to an error status.
          */
         FND_MESSAGE.SET_NAME('IBY', 'IBY_INS_CREATION_FAILED');
         FND_MSG_PUB.ADD;

         FND_MSG_PUB.COUNT_AND_GET(
             p_count => x_msg_count,
             p_data  => x_msg_data
             );

         /* store error ids in output param */
         retrieve_transaction_errors(
             l_payreq_id,
             x_error_ids_tab
             );

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning error response '
	             || 'because payment instruction creation failed .. '
	             );

         END IF;
         /*
          * Return error status and exit.
          */
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     END IF;

     /*
      * Since we are processing a single payment, only one
      * payment instruction is expected to be created.
      * Store the created payment instruction in the l_pmtInstrRec
      * record structure.
      */
     IF (l_pmtInstrTab.COUNT <> 1) THEN

         /*
          * If multiple payment instruction instructions
          * were created, it is an error. Set the return
          * status to an error status.
          */
         FND_MESSAGE.SET_NAME('IBY', 'IBY_INS_CREATION_FAILED');
         FND_MSG_PUB.ADD;

         FND_MSG_PUB.COUNT_AND_GET(
             p_count => x_msg_count,
             p_data  => x_msg_data
             );

         /* store error ids in output param */
         retrieve_transaction_errors(
             l_payreq_id,
             x_error_ids_tab
             );

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning error response '
	             || 'because multiple payment instructions were created .. '
	             );

         END IF;
         /*
          * Return error status and exit.
          */
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     ELSE

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Only one payment '
	             || 'instruction was created as expected.'
	             );

         END IF;
         l_pmtInstrRec := l_pmtInstrTab(1);

     END IF;

     /*
      * If we reached here, it means that the payment instruction
      * creation program finished successfully. Invoke
      * check numbering if we are building payment instructions
      * of processing type 'printed'.
      */
     IF (l_profile_attribs.processing_type = 'PRINTED' OR
           (l_profile_attribs.processing_type = 'ELECTRONIC' AND
                                p_payment_document_id IS NOT NULL)) THEN

         /*
          * Invoke check numbering for the created payment
          * instruction.
          */
         IBY_CHECKNUMBER_PUB.performCheckNumbering(
             l_pmtInstrRec.payment_instruction_id,
             p_payment_document_id,
             p_paper_document_number,
             l_return_status,
             l_return_message,
             x_msg_count,
             x_msg_data
             );

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'After numbering, '
	             || 'return status: '
	             || l_return_status
	             || ', and return message: '
	             || l_return_message
	             );

         END IF;
         /*
          * If check numbering did not succeed return with an
          * error.
          */
         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

             /*
              * Fix for bug 5327347:
              *
              * Only populate the FND message stack if we
              * do not already have a message for the user.
              *
              * Otherwise, the user gets innundated with error
              * messages.
              */
             IF (FND_MSG_PUB.COUNT_MSG = 0) THEN

                 FND_MESSAGE.SET_NAME('IBY', 'IBY_INS_NUMBERING_ERROR');
                 FND_MSG_PUB.ADD;

                 FND_MSG_PUB.COUNT_AND_GET(
                     p_count => x_msg_count,
                     p_data  => x_msg_data
                     );

             END IF;

             /* store error ids in output param */
             retrieve_transaction_errors(
                 l_payreq_id,
                 x_error_ids_tab
                 );

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Returning error response '
	                     || 'because check numbering failed .. '
	                     );

             END IF;
             /*
              * Return error status and exit.
              */
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'EXIT');

             END IF;
             RETURN;

         END IF;

     ELSE

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Processing type is '
	             || l_profile_attribs.processing_type
	             || '. Numbering of paper documents skipped ..'
	             );

         END IF;
         /*
          * WITHHOLDING HOOK:
          *
          * Fix for bug 6706749:
          *
          * If we reached here, it means the processing type
          * is electronic.
          *
          * For electronic payment instructions, check numbering
          * not required. Instead, directly call the extracting
          * and formatting programs.
          *
          * However, just before calling the extract/format program,
          * we need to invoke the withholding certificates hook.
          * For printed payments, this is already being done
          * when the checks are numbered. For electronic payments,
          * we need to explicitly add this call.
          */

         IF (l_pmtInstrRec.payment_instruction_status =
             INS_STATUS_CREATED) THEN

             l_pkg_name     := 'AP_AWT_CALLOUT_PKG';
             l_callout_name := l_pkg_name
                                   || '.'
                                   || 'zx_witholdingCertificatesHook';

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name,
	                 'Attempting to call hook: '
	                 || l_callout_name
	                 );

             END IF;
             l_stmt := 'CALL '|| l_callout_name
                              || '(:1, :2, :3, :4, :5, :6, :7, :8)';

             BEGIN

                 EXECUTE IMMEDIATE
                     (l_stmt)
                 USING
                     IN  l_pmtInstrRec.payment_instruction_id,
                     IN  'GENERATE',
                     IN  l_api_version,
                     IN  FND_API.G_FALSE,
                     IN  FND_API.G_FALSE,
                     OUT l_return_status,
                     OUT l_msg_count,
                     OUT l_msg_data
                     ;

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name,
	                     'Finished invoking hook: '
	                     || l_callout_name
	                     || ', return status: '
	                     || l_return_status
	                     );

                 END IF;
                 /*
                  * If the called procedure did not return success,
                  * raise an exception.
                  */
                 IF (l_return_status IS NULL OR
                     l_return_status <> FND_API.G_RET_STS_SUCCESS)
                     THEN

                     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                     print_debuginfo(l_module_name,
	                         'Fatal: External app callout '''
	                         || l_callout_name
	                         || ''', returned failure status - '
	                         || l_return_status
	                         || '. Raising exception.'
	                         );

                     END IF;
                     APP_EXCEPTION.RAISE_EXCEPTION;

                 END IF;


             EXCEPTION

                 WHEN PROCEDURE_NOT_IMPLEMENTED THEN
                     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                     print_debuginfo(l_module_name,
	                         'Callout "'
	                         || l_callout_name
	                         || '" not implemented by application - AP'
	                         );

	                     print_debuginfo(l_module_name,
	                         'Skipping hook call.');

                     END IF;
                 WHEN OTHERS THEN

                     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                     print_debuginfo(l_module_name,
	                         'Fatal: External app '
	                         || 'callout '''
	                         || l_callout_name
	                         || ''', generated exception.'
	                         );

                     END IF;
                     l_error_code := 'IBY_INS_AWT_CERT_HOOK_FAILED';
                     FND_MESSAGE.set_name('IBY', l_error_code);

                     FND_MESSAGE.SET_TOKEN('CALLOUT',
                         l_callout_name,
                         FALSE);

                     /*
                      * Set the message on the error stack
                      * to display in UI (in case of direct
                      * API call from UI).
                      */
                     FND_MSG_PUB.ADD;

                     FND_MSG_PUB.COUNT_AND_GET(
                         p_count => x_msg_count,
                         p_data  => x_msg_data
                         );

                     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                     print_debuginfo(l_module_name, 'Raising exception '
	                             || 'because withholding certificates hook '
	                             || 'returned an error .. '
	                             );

                     END IF;
                     RAISE;

             END;

         END IF; -- if instruction status = 'created'

     END IF; -- if processing type = 'printed'

     /*
      * If we reached here, it means that the payments of the
      * payment instruction were numbered successfully (in the
      * case of printed payments).
      *
      * Populate the API output params such as the payment reference
      * number, paper document number etc. with the data from the
      * created single payment.
      */
     populateOutParams(
         l_payreq_id,
         l_profile_attribs.processing_type,
         x_num_printed_docs,
         x_payment_id,
         x_paper_doc_num,
         x_pmt_ref_num
         );

     /*
      * Invoke the set of post-payment instruction
      * creation programs that are responsible for
      * extracting, formatting and printing the
      * payment instruction data.
      */
     BEGIN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Invoking '
	             || 'extract and format programs for '
	             || 'instruction '
	             || l_pmtInstrRec.payment_instruction_id
	             );

         END IF;
         IBY_FD_POST_PICP_PROGS_PVT.
             Run_Post_PI_Programs(
             l_pmtInstrRec.payment_instruction_id,
             'N'
             );

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Extract '
	             || 'and format operation completed.'
	             );

         END IF;
     EXCEPTION
         WHEN OTHERS THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Extract and '
	             || 'format operation generated '
	             || 'exception for payment instruction '
	             || l_pmtInstrRec.payment_instruction_id
	             );

	         print_debuginfo(l_module_name, 'SQL code: '
	             || SQLCODE);
	         print_debuginfo(l_module_name, 'SQL err msg: '
	             || SQLERRM);

         END IF;
         FND_MESSAGE.SET_NAME('IBY', 'IBY_INS_BACKEND_ERROR');

         FND_MESSAGE.SET_TOKEN('INS_ID',
             l_pmtInstrRec.payment_instruction_id,
             FALSE);

         FND_MSG_PUB.ADD;

         FND_MSG_PUB.COUNT_AND_GET(
             p_count => x_msg_count,
             p_data  => x_msg_data
             );

         /* store error ids in output param */
         retrieve_transaction_errors(
             l_payreq_id,
             x_error_ids_tab
             );

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning error response '
	             || 'because extract and format operation failed for '
	             || 'created payment instruction .. '
	             );

         END IF;
         /*
          * Return error status and exit.
          */
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     END;

     /*
      * If we reached here, it means that the single payment
      * request has been processed successfully.
      *
      * Finalize the instruction status (mark all payments of
      * instruction as completed) and return success response.
      */

     /*
      * The finalize API is only meant for printed payment
      * instructions. For electronic payment instructions,
      * call the mark payments complete API directly.
      */
     IF (l_profile_attribs.processing_type = 'PRINTED') THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Finalizing printed pmt instruction '
	             || 'and pmt statuses ..');

         END IF;
         IBY_DISBURSE_UI_API_PUB_PKG.finalize_instr_print_status(
             l_pmtInstrRec.payment_instruction_id,
             x_return_status
         );

     ELSE

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Finalizing electronic pmt instruction '
	             || 'and pmt statuses ..');

         END IF;
         IBY_DISBURSE_UI_API_PUB_PKG.finalize_electronic_instr(
             l_pmtInstrRec.payment_instruction_id,
             x_return_status
         );

     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Return status after finalize call '
	         || x_return_status);

     END IF;
     IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning success response ..');
         END IF;
     ELSE
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning error response: '
	             || x_return_status);

	         print_debuginfo(l_module_name, 'Unable to finalize payment '
	             || 'instruction. Aborting ..'
	             );

         END IF;
         /*
          * Return error status and exit.
          */
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         FND_MESSAGE.SET_NAME('IBY', 'IBY_INS_FINALIZE_STATUS_FAIL');
         FND_MESSAGE.SET_TOKEN('INS_ID',
             l_pmtInstrRec.payment_instruction_id,
             FALSE);
         FND_MSG_PUB.ADD;

         FND_MSG_PUB.COUNT_AND_GET(
             p_count => x_msg_count,
             p_data  => x_msg_data
             );

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'List of params passed back to caller - ');
	     print_debuginfo(l_module_name, 'x_num_printed_docs = '
	         || x_num_printed_docs);
	     print_debuginfo(l_module_name, 'x_payment_id = '
	         || x_payment_id);
	     print_debuginfo(l_module_name, 'x_paper_doc_num = '
	         || x_paper_doc_num);
	     print_debuginfo(l_module_name, 'x_pmt_ref_num = '
	         || x_pmt_ref_num);
	     print_debuginfo(l_module_name, 'x_return_status = '
	         || x_return_status);

	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 EXCEPTION

     WHEN OTHERS THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Exception occured when '
	             || 'processing single payment. Single payment creation will '
	             || 'be aborted and no records will be committed for '
	             || 'payment request '
	             || l_payreq_id
	             );
	         print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	         print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);

         END IF;
         /* store error ids in output param */
         retrieve_transaction_errors(
             l_payreq_id,
             x_error_ids_tab
             );

         /*
          * Return error status and exit.
          */
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

 END submit_single_payment;

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
     RETURN NUMBER
 IS

 l_payreq_id     IBY_PAY_SERVICE_REQUESTS.payment_service_request_id%TYPE;
 l_module_name   VARCHAR2(200) := G_PKG_NAME || '.insert_payreq';

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     l_payreq_id := IBY_DISBURSE_SUBMIT_PUB_PKG.getNextPayReqId();

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Generated payment request id: '
	         || l_payreq_id);

     END IF;
     /*
      * Insert the payment request into IBY_PAY_SERVICE_REQUESTS
      * table. Supply defaults for values not provided by the
      * calling app.
      */
     INSERT INTO IBY_PAY_SERVICE_REQUESTS (
         CALLING_APP_ID,
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN,
         OBJECT_VERSION_NUMBER,
         CALL_APP_PAY_SERVICE_REQ_CODE,
         PAYMENT_SERVICE_REQUEST_STATUS,
         PAYMENT_SERVICE_REQUEST_ID,
         PROCESS_TYPE,
         INTERNAL_BANK_ACCOUNT_ID,
         PAYMENT_PROFILE_ID,
         ALLOW_ZERO_PAYMENTS_FLAG
         )
     VALUES(
         p_calling_app_id,
         fnd_global.user_id,
         sysdate,
         fnd_global.user_id,
         sysdate,
         fnd_global.login_id,
         1,
         p_calling_app_payreq_cd,
         REQ_STATUS_INSERTED,
         l_payreq_id,
         DECODE(p_is_manual_payment_flag, 'Y', 'MANUAL', 'IMMEDIATE'),
         p_internal_bank_account_id,
         p_pay_process_profile_id,
         'Y'
         );

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');
     END IF;
     RETURN l_payreq_id;

 EXCEPTION
     WHEN OTHERS THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Exception occured when '
	             || 'inserting payment request status for '
	             || 'calling app id '
	             || p_calling_app_id
	             || ', calling app payment service request cd '
	             || p_calling_app_payreq_cd
	             );
	         print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	         print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);

         END IF;
         l_payreq_id := -1;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning -1 for pay req id');
	         print_debuginfo(l_module_name, 'EXIT');
         END IF;
         RETURN l_payreq_id;

 END insert_payreq;

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
 |     This method is only meant for single payments flow.
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
     )
 IS

 l_module_name   VARCHAR2(200) := G_PKG_NAME || '.populateOutParams';

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

	     print_debuginfo(l_module_name, 'Provided params - pay req id: '
	         || p_payreq_id
	         || ', processing type: '
	         || p_processing_type
	         );

     END IF;
     IF (p_processing_type = 'ELECTRONIC') THEN

         /*
          * Fix for bug 5249885:
          *
          * Since AP displays the paper document number
          * in the UI, it is better to pass this value
          * as null (display blank) rather than -1.
          */
         x_paper_doc_num    := NULL;
         x_num_printed_docs := -1;
         x_pmt_ref_num      := -1;
         x_payment_id       := -1;

         BEGIN

             /*
              * Get the payment reference number of the created
              * payment. We expect only one payment to be created
              * because this is an electronic single payment (so,
              * no setup and overflow payments will be created).
              */

             /*
              * Fix for bug 5179465:
              *
              * The final status for electronic single payments
              * will be FORMATTED.
              *
              * Use this status when quering for the attributes
              * of the single payment.
              */

             /*
              *
              * Fix for bug 5225777:
              *
              * The populateOutParams(..) method is called before
              * the payment status is set to FORMATTED by the
              * finalize_electronic_instr(..) method. Therefore,
              * is is safest to check for both the FORMATTED and
              * the INSTRUCTION_CREATED statuses for payments.
              */
	     /*
	      * Fix for bug 8436938
	      *
	      * A valid paper document number can be available
	      * even for ELECTRONIC payments for outhouse-check-print
	      * situations
	      *
	      */
             SELECT
                 pmt.payment_id,
                 pmt.payment_reference_number,
                 decode(pmt.paper_document_number,-1,NULL,pmt.paper_document_number)
             INTO
                 x_payment_id,
                 x_pmt_ref_num,
                 x_paper_doc_num
             FROM
                 IBY_PAYMENTS_ALL pmt
             WHERE
                 pmt.payment_service_request_id = p_payreq_id AND
                 pmt.payment_status IN
                     (
                     PMT_STATUS_FORMATTED,
                     PMT_STATUS_INS_CREATED
                     )
             ;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'For payment request '
	                 || p_payreq_id
	                 || ' an electronic single payment with '
	                 || 'payment id '
	                 || x_payment_id
	                 || ' and payment reference number '
	                 || x_pmt_ref_num
	                 || ' has been created.'
	                 );

             END IF;
         EXCEPTION

             WHEN OTHERS THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Exception occured when '
	                     || 'retrieving payment reference number for '
	                     || 'single payment with pay req id '
	                     || p_payreq_id
	                     );

	                 print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	                 print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);

                 END IF;
                 APP_EXCEPTION.RAISE_EXCEPTION;

         END;

     ELSIF (p_processing_type = 'PRINTED') THEN

         x_paper_doc_num    := -1;
         x_num_printed_docs := -1;
         x_pmt_ref_num      := -1;
         x_payment_id       := -1;

         BEGIN

             /*
              * Get the payment reference number and paper document
              * number of the created payment. Multiple payments can
              * created because this is a printed single payment (so,
              * setup and overflow payments will be created).
              *
              * The setup and overflow payments will have status
              * VOID_BY_SETUP and VOID_BY_OVERFLOW respectively.
              * By selecting the payment with status
              * INSTRUCTION_CREATED we will be picking up only
              * the actual payment.
              */
             SELECT
                 pmt.payment_id,
                 pmt.payment_reference_number,
                 pmt.paper_document_number
             INTO
                 x_payment_id,
                 x_pmt_ref_num,
                 x_paper_doc_num
             FROM
                 IBY_PAYMENTS_ALL pmt
             WHERE
                 pmt.payment_service_request_id = p_payreq_id AND
                 pmt.payment_status = PMT_STATUS_INS_CREATED
             ;

             /*
              * Get the count of the paper documents that are
              * needed to print the created single payment.
              *
              * This count will include setup payments + overflow
              * payments + actual single payment.
              */
             SELECT
                 count(*)
             INTO
                 x_num_printed_docs
             FROM
                 IBY_PAYMENTS_ALL
             WHERE
                 payment_service_request_id = p_payreq_id AND
                 payment_status IN (
                     PMT_STATUS_INS_CREATED,
                     PMT_STATUS_SETUP,
                     PMT_STATUS_OVERFLOW)
             ;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'For payment request '
	                 || p_payreq_id
	                 || ' a printed single payment with '
	                 || 'payment id '
	                 || x_payment_id
	                 || ' and payment reference number '
	                 || x_pmt_ref_num
	                 || ' has been created.'
	                 );

	             print_debuginfo(l_module_name, 'Paper document number '
	                 || 'of created single payment is '
	                 || x_paper_doc_num
	                 || '.'
	                 );

             END IF;
         EXCEPTION

             WHEN OTHERS THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Exception occured when '
	                     || 'retrieving payment reference number for '
	                     || 'single payment with pay req id '
	                     || p_payreq_id
	                     );

	                 print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	                 print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);

                 END IF;
                 APP_EXCEPTION.RAISE_EXCEPTION;

         END;

     ELSE

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Unknown processing type: '
	             || p_processing_type
	             || ' has been provided. Cannot proceed. Aborting ..'
	             );

         END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;

     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END populateOutParams;

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
     )
 IS

 /*
  * Cursor to pick up all document errors that
  * were generated during the processing of this single
  * payment.
  */
 CURSOR c_doc_errors_list (p_payreq_id NUMBER)
 IS
 SELECT
     err.transaction_error_id
 FROM
     IBY_TRANSACTION_ERRORS   err,
     IBY_DOCS_PAYABLE_ALL     doc,
     IBY_PAY_SERVICE_REQUESTS prq
 WHERE
     err.transaction_id             = doc.document_payable_id        AND
     err.transaction_type           = TRXN_TYPE_DOC                  AND
     doc.payment_service_request_id = prq.payment_service_request_id AND
     prq.payment_service_request_id = p_payreq_id
     ;

 /*
  * Cursor to pick up all payment errors that
  * were generated during the processing of this single
  * payment.
  */
 CURSOR c_pmt_errors_list (p_payreq_id NUMBER)
 IS
 SELECT
     err.transaction_error_id
 FROM
     IBY_TRANSACTION_ERRORS   err,
     IBY_PAYMENTS_ALL         pmt,
     IBY_PAY_SERVICE_REQUESTS prq
 WHERE
     err.transaction_id             = pmt.payment_id                 AND
     err.transaction_type           = TRXN_TYPE_PMT                  AND
     pmt.payment_service_request_id = prq.payment_service_request_id AND
     prq.payment_service_request_id = p_payreq_id
     ;

 /*
  * Cursor to pick up all payment instruction errors that
  * were generated during the processing of this single
  * payment.
  */
 CURSOR c_pmtinstr_errors_list (p_payreq_id NUMBER)
 IS
 SELECT
     err.transaction_error_id
 FROM
     IBY_TRANSACTION_ERRORS   err,
     IBY_PAYMENTS_ALL         pmt,
     IBY_PAY_INSTRUCTIONS_ALL ins,
     IBY_PAY_SERVICE_REQUESTS prq
 WHERE
     err.transaction_id             = ins.payment_instruction_id     AND
     err.transaction_type           = TRXN_TYPE_INS                  AND
     pmt.payment_service_request_id = prq.payment_service_request_id AND
     pmt.payment_instruction_id     = ins.payment_instruction_id     AND
     prq.payment_service_request_id = p_payreq_id
     ;

 l_trxnErrorIdsTab  trxnErrorIdsTab;
 l_module_name      VARCHAR2(200) := G_PKG_NAME ||
                                       '.retrieve_transaction_errors';

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');
	     print_debuginfo(l_module_name, 'Payment request id: ' || p_payreq_id);

     END IF;
     /*
      * Pick up all the documents errors for the single payment.
      */
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Retrieving document errors ..');
     END IF;
     OPEN  c_doc_errors_list(p_payreq_id);
     FETCH c_doc_errors_list BULK COLLECT INTO l_trxnErrorIdsTab;
     CLOSE c_doc_errors_list;

     IF (l_trxnErrorIdsTab.COUNT <> 0) THEN

         FOR i in l_trxnErrorIdsTab.FIRST .. l_trxnErrorIdsTab.LAST LOOP

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Trxn error id for doc: '
	                 || l_trxnErrorIdsTab(i).trxn_error_id
	                 );

             END IF;
             x_trxnErrorIdsTab(x_trxnErrorIdsTab.COUNT + 1) :=
                 l_trxnErrorIdsTab(i);

         END LOOP;

     ELSE

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'No document errors were '
	             || 'generated.');

         END IF;
     END IF;

     /*
      * Pick up all the payment errors for the single payment.
      */
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Retrieving payment errors ..');
     END IF;
     OPEN  c_pmt_errors_list(p_payreq_id);
     FETCH c_pmt_errors_list BULK COLLECT INTO l_trxnErrorIdsTab;
     CLOSE c_pmt_errors_list;

     IF (l_trxnErrorIdsTab.COUNT <> 0) THEN

         FOR i in l_trxnErrorIdsTab.FIRST .. l_trxnErrorIdsTab.LAST LOOP

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Trxn error id for pmt: '
	                 || l_trxnErrorIdsTab(i).trxn_error_id);

             END IF;
             x_trxnErrorIdsTab(x_trxnErrorIdsTab.COUNT + 1) :=
                 l_trxnErrorIdsTab(i);

         END LOOP;

     ELSE

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'No payment errors were '
	             || 'generated.');

         END IF;
     END IF;

     /*
      * Pick up all the payment instruction errors for the single payment.
      */
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Retrieving payment instruction errors ..');
     END IF;
     OPEN  c_pmtinstr_errors_list(p_payreq_id);
     FETCH c_pmtinstr_errors_list BULK COLLECT INTO l_trxnErrorIdsTab;
     CLOSE c_pmtinstr_errors_list;

     IF (l_trxnErrorIdsTab.COUNT <> 0) THEN

         FOR i in l_trxnErrorIdsTab.FIRST .. l_trxnErrorIdsTab.LAST LOOP

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Trxn error id for ins: '
	                 || l_trxnErrorIdsTab(i).trxn_error_id);

             END IF;
             x_trxnErrorIdsTab(x_trxnErrorIdsTab.COUNT + 1) :=
                 l_trxnErrorIdsTab(i);

         END LOOP;

     ELSE

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'No payment instruction errors '
	             || 'were generated.');

         END IF;
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Transaction error list populated '
	         || 'with '
	         || x_trxnErrorIdsTab.COUNT
	         || ' errors.'
	         );

	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 EXCEPTION

     /*
      * This method is called whenever there are errors in the
      * processing cycle. This method may itself generate
      * exception, in which case the user will not get any
      * useful error messages.
      *
      * Any exceptions generated by this method should be handled
      * gracefully, so that the single payment process returns
      * with an appropriate error status.
      */
     WHEN OTHERS THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Exception occured when '
	             || 'retrieving transaction error messages. '
	             );
	         print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	         print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);

	         print_debuginfo(l_module_name, 'Handling exception gracefully '
	             || 'to allow process to complete ..'
	             );

         END IF;
 END retrieve_transaction_errors;

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
     RETURN NUMBER
 IS
 PRAGMA AUTONOMOUS_TRANSACTION;

 l_module_name        VARCHAR2(200) := G_PKG_NAME
                                       || '.provide_pmt_reference_num';
 l_ret_val            NUMBER(15);

 l_last_used_ref_num         NUMBER := 0;
 l_anticipated_last_ref_num  NUMBER := 0;


 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     /*
      * Select the payment reference information from
      * the IBY_PAYMENT_REFERENCES table.
      */
     SELECT
             NVL(last_used_ref_number, -1)
     INTO
             l_last_used_ref_num
     FROM
             IBY_PAYMENT_REFERENCES
     FOR UPDATE
     ;

     IF (l_last_used_ref_num = -1) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Payment reference information '
	             || 'not setup. Last used ref number: '
	             || l_last_used_ref_num
	             || '. Cannot continue. Aborting ..'
	             );

         END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;

     END IF;

     /*
      * Since we are numbering one payment, add one to the
      * last used ref number.
      */
     l_anticipated_last_ref_num := l_last_used_ref_num + 1;
     l_ret_val := l_anticipated_last_ref_num;

     /*
      * Update the last used ref number and commit. So that
      * other concurrent instances, now get the updated last
      * used ref number.
      */
     UPDATE
         IBY_PAYMENT_REFERENCES
     SET
         last_used_ref_number = l_anticipated_last_ref_num;

     /*
      * End the autonomous transaction.
      */
     COMMIT;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Payment reference returned: '
	         || l_ret_val);
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
     RETURN l_ret_val;

 EXCEPTION
     WHEN OTHERS THEN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Exception occured when '
	         || 'providing payment reference'
	         );
	     print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	     print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);

     END IF;
     /*
      * End autonomous transaction.
      */
     ROLLBACK;

     l_ret_val := -1;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Payment reference returned: '
	         || l_ret_val);
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
     RETURN l_ret_val;

 END provide_pmt_reference_num;


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
     p_debug_text IN VARCHAR2)
 IS

 BEGIN

     /*
      * Write the debug message to the concurrent manager log file.
      */
     iby_build_utils_pkg.print_debuginfo(p_module, p_debug_text);

 END print_debuginfo;


END IBY_DISBURSE_SINGLE_PMT_PKG;

/
