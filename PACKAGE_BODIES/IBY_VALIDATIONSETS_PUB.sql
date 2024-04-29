--------------------------------------------------------
--  DDL for Package Body IBY_VALIDATIONSETS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_VALIDATIONSETS_PUB" AS
/*$Header: ibyvallb.pls 120.60.12010000.21 2010/06/22 11:05:15 pschalla ship $*/

 --
 -- Declaring Global variables
 --
 G_CURRENT_RUNTIME_LEVEL      CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
 G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBY_VALIDATIONSETS_PUB';

 --
 -- User Defined Exceptions
 --
 g_abort_program EXCEPTION;

 --
 -- List of rejection level system options  that are possible for
 -- this module (document validation flow).
 --
 REJ_LVL_REQUEST  CONSTANT VARCHAR2(100) := 'REQUEST';
 REJ_LVL_DOCUMENT CONSTANT VARCHAR2(100) := 'DOCUMENT';
 REJ_LVL_NONE     CONSTANT VARCHAR2(100) := 'NONE';
 REJ_LVL_PAYEE    CONSTANT VARCHAR2(100) := 'PAYEE';

 --
 -- List of document statuses that are used / set in this
 -- module (document validation flow).
 --
 DOC_STATUS_RDY_FOR_VAL  CONSTANT VARCHAR2(100) := 'READY_FOR_VALIDATION';
 DOC_STATUS_REJECTED     CONSTANT VARCHAR2(100) := 'REJECTED';
 DOC_STATUS_FAIL_VALID   CONSTANT VARCHAR2(100) := 'FAILED_VALIDATION';
 DOC_STATUS_VALIDATED    CONSTANT VARCHAR2(100) := 'VALIDATED';
 DOC_STATUS_RELN_FAIL    CONSTANT VARCHAR2(100) := 'FAILED_BY_RELATED_DOCUMENT';
 DOC_STATUS_FAIL_BY_REJLVL CONSTANT VARCHAR2(100)
                                                := 'FAILED_BY_REJECTION_LEVEL';
 DOC_STATUS_FAIL_BY_CA   CONSTANT VARCHAR2(100)
                                                := 'FAILED_BY_CALLING_APP';
 DOC_STATUS_REMOVED      CONSTANT VARCHAR2(100) := 'REMOVED';

 --
 -- List of payment statuses that are used / set in this
 -- module (payment creation flow).
 --
 PAY_STATUS_INS_CRTD     CONSTANT VARCHAR2(100) := 'INSTRUCTION_CREATED';

 --
 -- List of payment request statuses that are set in this
 -- module (document validation flow).
 --
 REQ_STATUS_FAIL_VAL      CONSTANT VARCHAR2(100) := 'VALIDATION_FAILED';
 REQ_STATUS_VALIDATED     CONSTANT VARCHAR2(100) := 'DOCUMENTS_VALIDATED';
 REQ_STATUS_USER_REVW_ERR CONSTANT VARCHAR2(100) :=
                                       'PENDING_REVIEW_DOC_VAL_ERRORS';

 -- Transaction type (for inserting into IBY_TRANSACTION_ERRORS table)
 TRXN_TYPE_DOC   CONSTANT VARCHAR2(100) := 'DOCUMENT_PAYABLE';

 -- Dummy record
 l_dummy_err_token_tab trxnErrTokenTabType;
 /* holds list of default format for each payee */
 l_payee_format_tab      payeeFormatTabType;

 /* holds list of format linked to each profile */
 l_profile_format_tab    profileFormatTabType;

 TYPE externalBankAcctType IS RECORD (
     external_bank_account_id     IBY_EXT_BANK_ACCOUNTS_V.ext_bank_account_id%TYPE,
     country_code             IBY_EXT_BANK_ACCOUNTS_V.country_code%TYPE,
     end_date      IBY_EXT_BANK_ACCOUNTS_V.end_date%TYPE,
     foreign_pmts_ok_flag      IBY_EXT_BANK_ACCOUNTS_V.foreign_payment_use_flag%TYPE
     );
 --
 TYPE externalBankAcctTabType IS TABLE OF externalBankAcctType
     INDEX BY BINARY_INTEGER;

 ext_bank_acct_tbl  externalBankAcctTabType;

TYPE internalBankAcctType IS RECORD (
     internal_bank_account_id     CE_BANK_ACCOUNTS.bank_account_id%TYPE,
     bank_home_country        CE_BANK_BRANCHES_V.bank_home_country%TYPE,
     country      CE_BANK_BRANCHES_V.country%TYPE
     );
 --
 TYPE internalBankAcctTabType IS TABLE OF internalBankAcctType
     INDEX BY BINARY_INTEGER;

int_bank_acct_tbl  internalBankAcctTabType;
/*Begin of Bug 8322794*/

TYPE l_int_bank_accts_tbl_type IS TABLE OF BOOLEAN INDEX BY VARCHAR2(2000);
 l_int_bank_accts_tbl  l_int_bank_accts_tbl_type;

 l_internal_bank_accts_index varchar2(2000);

/*End of Bug 8322794*/

/*--------------------------------------------------------------------
 | NAME:
 |     print_debuginfo
 |
 | PURPOSE:
 |     This procedure prints the debug message to the concurrent manager
 |     log file.
 |
 | PARAMETERS:
 |     IN
 |      p_debug_text - The debug message to be printed
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE print_debuginfo(p_module      IN VARCHAR2,
                           p_debug_text  IN VARCHAR2,
                           p_debug_level IN VARCHAR2  DEFAULT
                                                      FND_LOG.LEVEL_STATEMENT
                           )
 IS
 l_default_debug_level VARCHAR2(200) := FND_LOG.LEVEL_STATEMENT;
 BEGIN

     /*
      * Set the debug level to the value passed in
      * (provided this value is not null).
      */
     IF (p_debug_level IS NOT NULL) THEN
         l_default_debug_level := p_debug_level;
     END IF;

     /*
      * Write the debug message to the concurrent manager log file.
      */

     /*
      * Fix for bug 5578607:
      *
      * Call the underlying routine only if the current debug
      * level exceeds the runtime debug level.
      */
     --IF (l_default_debug_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

         iby_build_utils_pkg.print_debuginfo(p_module, p_debug_text,
             p_debug_level);

     --END IF;

 END print_debuginfo;

/*--------------------------------------------------------------------
 | NAME:
 |     performDBUpdates
 |
 | PURPOSE:
 |     Updates the status of the payment request and documents of the
 |     payment request.
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
 PROCEDURE performDBUpdates(
     p_pay_service_request_id
                          IN IBY_PAY_SERVICE_REQUESTS.
                                 payment_service_request_id%type,
     p_allDocsTab         IN docPayTabType,
     x_errorDocsTab       IN OUT NOCOPY docStatusTabType,
     p_allDocsSuccessFlag IN BOOLEAN,
     p_allDocsFailedFlag  IN BOOLEAN,
     p_rejectionLevel     IN VARCHAR2,
     x_txnErrorsTab       IN OUT NOCOPY docErrorTabType,
     x_errTokenTab        IN OUT NOCOPY trxnErrTokenTabType,
     x_return_status      IN OUT NOCOPY VARCHAR2
     )
 IS

 l_request_status   VARCHAR2(200);
 l_module_name      CONSTANT VARCHAR2(200) := G_PKG_NAME || '.performDBUpdates';
 l_flag             VARCHAR2(1) := 'N';
 l_empty_table      docStatusTabType;

 BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo(l_module_name, 'ENTER');

    END IF;
    /*
     * Get the rejection level system option
     */
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo(l_module_name, 'Rejection level system option set to: '
	        || p_rejectionLevel);


    END IF;
    /*-----------START DEBUG---------------*/

    IF (x_errorDocsTab.COUNT <> 0) THEN

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo(l_module_name, 'Printing list of error documents: ');

        END IF;
        FOR i IN x_errorDocsTab.FIRST .. x_errorDocsTab.LAST LOOP

            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	            print_debuginfo(l_module_name, 'doc id: '
	                || x_errorDocsTab(i).doc_id
	                || ', doc status: '
	                || x_errorDocsTab(i).doc_status);

            END IF;
        END LOOP;

    ELSE

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo(l_module_name, 'list of error documents is empty');

        END IF;
    END IF;

    /*-----------END   DEBUG---------------*/

    /*
     * Log the states of important flags
     */
    IF (p_allDocsFailedFlag = TRUE) THEN
        l_flag := 'Y';
    END IF;
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo(l_module_name, 'All docs failed flag: ' || l_flag);

    END IF;
    l_flag := 'N';
    IF (p_allDocsSuccessFlag = TRUE) THEN
        l_flag := 'Y';
    END IF;
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo(l_module_name, 'All docs success flag: ' || l_flag);


    END IF;
    IF (p_rejectionLevel = REJ_LVL_REQUEST) THEN

        /*
         * For request level rejections, even if one document
         * in the request has failed validation, set the status
         * of the request to 'failed validation'.
         */
        IF (p_allDocsSuccessFlag = TRUE) THEN
            l_request_status := REQ_STATUS_VALIDATED;
        ELSE
            l_request_status := REQ_STATUS_FAIL_VAL;
        END IF;

        /*
         * If all docs have not passed validations, it
         * means that at least one doc is in error.
         *
         * In such a case, all documents in the request
         * have to be failed.
         */
        IF (p_allDocsSuccessFlag <> TRUE) THEN
            failAllDocsForRequest(p_allDocsTab, x_errorDocsTab,
                x_txnErrorsTab, x_errTokenTab);
        END IF;

    ELSIF (p_rejectionLevel = REJ_LVL_DOCUMENT) THEN

        /*
         * If all documents have failed validation for this
         * payment request, set the status of the request
         * to 'failed validation'; Otherwise, set the status
         * of the request as 'validated'.
         */
        IF (p_allDocsFailedFlag = TRUE) THEN
            l_request_status := REQ_STATUS_FAIL_VAL;
        ELSE
            l_request_status := REQ_STATUS_VALIDATED;
        END IF;

    ELSIF (p_rejectionLevel = REJ_LVL_PAYEE) THEN

        /*
         * Payee rejection level is similar to the
         * document rejection level, the difference
         * being that all documents for a particular
         * payee must be failed if any documents for that
         * payee has failed. This cascade failure
         * has already happened before this method is called.
         */
        IF (p_allDocsFailedFlag = TRUE) THEN
            l_request_status := REQ_STATUS_FAIL_VAL;
        ELSE
            l_request_status := REQ_STATUS_VALIDATED;
        END IF;

    ELSIF (p_rejectionLevel = REJ_LVL_NONE) THEN

        /*
         * For rejection level 'none', set request status
         * to 'validated' if all documents were successfully
         * validated, else, set request status to 'user
         * review'.
         */
        IF (p_allDocsSuccessFlag = TRUE) THEN
            l_request_status := REQ_STATUS_VALIDATED;
        ELSE
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	            print_debuginfo(l_module_name, 'At least one doc '
	                || 'has failed. Setting request status to '
	                || REQ_STATUS_USER_REVW_ERR
	                );
            END IF;
            l_request_status := REQ_STATUS_USER_REVW_ERR;

            /*
             * Special handling of failed documents:
             *
             * In the nomal scenario, when a document fails
             * validation, it's status is set to 'REJECTED'
             * and the document is kicked back to the calling
             * app via a business event. This is the end of
             * the lifecycle for these failed documents.
             *
             * In the case of rejection level 'NONE', if a
             * document fails validation, it is not kicked back
             * to the calling app. Instead, it sits in IBY
             * and waits for the user to take corrective action
             * via the IBY UI. Therefore, these documents that
             * are failed but not kicked back, should have a
             * special status to indicate that though failed,
             * these documents are still 'alive' in IBY.
             *
             * Therefore, we use a special status 'FAILED_VALIDATION'
             * to differentiate between documents that have failed
             * but not have been kicked back, and documents
             * that have failed and have been kicked back
             * (those that have been kicked back will have
             * status 'REJECTED').
             */
            FOR i in x_errorDocsTab.FIRST .. x_errorDocsTab.LAST LOOP
                x_errorDocsTab(i).doc_status := DOC_STATUS_FAIL_VALID;
            END LOOP;

        END IF;

    ELSE

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo(l_module_name, 'Unknown rejection level: '
	            || p_rejectionLevel
	            || '. Aborting document validation ..',
	            FND_LOG.LEVEL_UNEXPECTED
	            );

        END IF;
        APP_EXCEPTION.RAISE_EXCEPTION;

    END IF;

    /*
     * Update the status of the invalid documents
     */
    IF (x_errorDocsTab.COUNT > 0) THEN

        FOR i in x_errorDocsTab.FIRST..x_errorDocsTab.LAST LOOP

            UPDATE
                IBY_DOCS_PAYABLE_ALL
            SET
                document_status       = x_errorDocsTab(i).doc_status,

                /*
                 * Fix for bug 4405981:
                 *
                 * The straight through flag should be set to 'N',
                 * if the document was rejected / required manual
                 * intervention.
                 */
                straight_through_flag =
                    DECODE(
                           x_errorDocsTab(i).doc_status,
                           DOC_STATUS_REJECTED,       'N',
                           DOC_STATUS_RELN_FAIL,      'N',
                           DOC_STATUS_FAIL_BY_REJLVL, 'N',
                           DOC_STATUS_FAIL_BY_CA,     'N',
                           DOC_STATUS_REMOVED,        'N',
                           'Y'
                           )
            WHERE
                document_payable_id = x_errorDocsTab(i).doc_id
            AND
                payment_service_request_id = p_pay_service_request_id;

        END LOOP;

    END IF;

    /*
     * All documents that haven't failed validation must have been
     * successfully validated. Set the status of these docs to
     * validated.
     */
    /* Update the status of the valid documents */
    UPDATE
        IBY_DOCS_PAYABLE_ALL
    SET
        document_status = DOC_STATUS_VALIDATED
    WHERE
        document_status NOT IN
            (
            DOC_STATUS_REJECTED,
            DOC_STATUS_RELN_FAIL,
            DOC_STATUS_FAIL_BY_REJLVL,
            DOC_STATUS_FAIL_VALID,
            DOC_STATUS_FAIL_BY_CA,
            DOC_STATUS_REMOVED
            ) AND
        payment_service_request_id = p_pay_service_request_id;

    /*
     * We have collected all the error messages against the failed
     * documents in a PLSQL table. Use this to update the
     * IBY_TRANSACTION_ERRORS table.
     */
    insert_transaction_errors('N', x_txnErrorsTab, x_errTokenTab);

    /*
     * Finally, update the status of the payment request.
     */
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo(l_module_name, 'Updating status of payment request '
	        || p_pay_service_request_id || ' to ' || l_request_status || '.');

    END IF;
    UPDATE
        IBY_PAY_SERVICE_REQUESTS
    SET
        payment_service_request_status = l_request_status
    WHERE
        payment_service_request_id = p_pay_service_request_id;

    /*
     * Pass back the request status to the caller.
     */
    x_return_status := l_request_status;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo(l_module_name, 'EXIT');

    END IF;
    EXCEPTION
        WHEN OTHERS THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo(l_module_name, 'Fatal: Exception when updating '
	            || 'payment request/document status after document '
	            || 'validation. All changes will be rolled back. Payment request '
	            || 'id is ' || p_pay_service_request_id,
	            FND_LOG.LEVEL_UNEXPECTED
	            );
	        print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE,
	            FND_LOG.LEVEL_UNEXPECTED);
	        print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM,
	            FND_LOG.LEVEL_UNEXPECTED);

        END IF;
        /*
         * Propogate exception to caller.
         */
        RAISE;

 END performDBUpdates;

/*--------------------------------------------------------------------
 | NAME:
 |     validate_CH_EST
 |
 | PURPOSE:
 |     This function is to validate Switzerland ESR reference number.
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
 FUNCTION validate_CH_EST ( p_esr_number IN VARCHAR2
 ) RETURN BOOLEAN IS

 l_check_string          VARCHAR2(20) := '9468271350946827135';

 l_number_carried          NUMBER;
 l_esr_length           NUMBER;
 l_esr_check_digit         NUMBER(1);
 l_esr_digit             VARCHAR(1);
 l_calculated_check_digit     VARCHAR(10);
 l_number_to_check        NUMBER;

 BEGIN
   l_number_carried     := 0;

   l_esr_length        := nvl(length(p_esr_number), 0);

   -- Take the check digit
   l_esr_check_digit    := substr(p_esr_number, l_esr_length, 1);

   FOR l_esr_position in 1..l_esr_length-1
   LOOP
     l_esr_digit       := substr(p_esr_number, l_esr_position, 1);
     l_number_to_check  := l_number_carried + to_number(l_esr_digit);
     l_number_carried     := substr(l_check_string, l_number_to_check, 1);
   END LOOP;

   l_calculated_check_digit := to_char(10 - l_number_carried);

   IF l_calculated_check_digit <> l_esr_check_digit THEN
      return (FALSE);
   ELSE
      return (TRUE);
   END IF;

 END validate_CH_EST;


 --
 -- The following are public API's.
 --

/*--------------------------------------------------------------------
 | NAME:
 |     applyDocumentValidationSets
 |
 | PURPOSE:
 |     Picks up validation sets which are applicable to a document
 |     and validates each document in the payment request
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
 | NOTES:  Added new validation to validate if the account attached to
 |         the document is valid for the payee.
 |         This was orginally always assumed to be true
 |
 *---------------------------------------------------------------------*/
 PROCEDURE applyDocumentValidationSets(
     p_pay_service_request_id IN IBY_PAY_SERVICE_REQUESTS.
                                     payment_service_request_id%TYPE,
     p_doc_rejection_level    IN IBY_INTERNAL_PAYERS_ALL.
                                     document_rejection_level_code%TYPE,
     p_is_singpay_flag        IN BOOLEAN,
     x_return_status          IN OUT NOCOPY VARCHAR2)
 IS

 l_stmt                  VARCHAR2(200);

 /* 0 indicates success; non-zero indicates failure */
 l_result                NUMBER := 0;

 /* holds list of all documents for a payment request */
 l_docs_tab              docPayTabType;

 /* holds list of failed documents for a payment request */
 l_invalid_docs_tab      docStatusTabType;
 l_invalid_doc_rec       docStatusRecType;
 l_doc_error_tab         docErrorTabType;

 /* holds list of validation sets applicable to a particular document */
 l_val_set_index         VARCHAR2(2000);
 l_val_sets_tab          valSetTabType;
 l_val_sets_temp_tab     valSetTabType;
 l_val_sets_count        NUMBER := 0;

 l_all_docs_success_flag BOOLEAN := FALSE;
 l_all_docs_failed_flag  BOOLEAN := TRUE;
 l_doc_failed_flag       BOOLEAN := FALSE;
 l_is_valid              BOOLEAN := FALSE;
 l_already_failed_flag   BOOLEAN := FALSE;
 /*Bug: 9311274
   Replaced l_end_date_valid by l_account_found
   We will now also validate if the account attached to
   the document is valid for the payee.
   This was orginally always assumed to be true
  */
 l_account_found        BOOLEAN := TRUE;

 l_rejection_level  VARCHAR2(200);


 /* variables for fields from payment request */
 req_ca_payreq_cd       iby_pay_service_requests.
                            call_app_pay_service_req_code%TYPE;
 req_ca_id              iby_pay_service_requests.calling_app_id%TYPE;

 --l_bankAccountsArray    CE_BANK_AND_ACCOUNT_UTIL.BankAcctIdTable;

 l_print_var     VARCHAR2(1) := '';
 l_doc_err_rec   IBY_TRANSACTION_ERRORS%ROWTYPE;
 l_doc_token_tab trxnErrTokenTabType;
 l_ext_bank_acct_id               IBY_EXT_BANK_ACCOUNTS_V.ext_bank_account_id%TYPE;
 l_end_date      IBY_EXT_BANK_ACCOUNTS_V.end_date%TYPE;
 l_country_code      IBY_EXT_BANK_ACCOUNTS_V.country_code%TYPE;
 l_foreign_pmts_ok_flag           IBY_EXT_BANK_ACCOUNTS_V.foreign_payment_use_flag%TYPE;

 l_int_bank_acct_id               CE_BANK_ACCOUNTS.bank_account_id%TYPE;
 l_country                        CE_BANK_BRANCHES_V.country%TYPE;
 l_bank_home_country              CE_BANK_BRANCHES_V.bank_home_country%TYPE;

 l_payee_id			  IBY_DOCS_PAYABLE_ALL.ext_payee_id%TYPE;
 l_payee_party_id		  IBY_DOCS_PAYABLE_ALL.payee_party_id%TYPE;

 l_profile_id                     IBY_PAYMENT_PROFILES.payment_profile_id%TYPE;
 l_payment_format_cd              IBY_PAYMENT_PROFILES.payment_format_code%TYPE;
 l_bepid                          IBY_PAYMENT_PROFILES.bepid%TYPE;
 l_transmit_protocol_cd           IBY_PAYMENT_PROFILES.transmit_protocol_code%TYPE;
 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME ||
                                             '.applyDocumentValidationSets';

 /*
  * Pick up all documents for the specified payment request
  */

 /*
  * Pick up validated documents also in this cursor. Otherwise,
  * if all invalid documents are dismissed by the user we will
  * end up with a situation where no documents are picked up
  * by this cursor, and the request will be left unprocessed
  * during payment re-validation flow.
  */
 CURSOR c_docs_list(p_pay_service_request_id IBY_PAY_SERVICE_REQUESTS.
            payment_service_request_id%TYPE)
 IS
 SELECT docs.document_payable_id,
     docs.calling_app_doc_unique_ref1,
     docs.calling_app_doc_unique_ref2,
     docs.calling_app_doc_unique_ref3,
     docs.calling_app_doc_unique_ref4,
     docs.calling_app_doc_unique_ref5,
     docs.calling_app_doc_ref_number,
     docs.calling_app_id,
     docs.pay_proc_trxn_type_code,
     docs.payment_grouping_number,
     docs.ext_payee_id,
     docs.payment_profile_id,
     docs.org_id,
     docs.org_type,
     docs.payment_method_code,
     docs.payment_format_code,
     docs.payment_currency_code,
     docs.internal_bank_account_id,
     docs.external_bank_account_id,
     docs.payment_date
 FROM
     IBY_DOCS_PAYABLE_ALL    docs
 WHERE
     docs.payment_service_request_id = p_pay_service_request_id
     AND docs.document_status IN
         (
         DOC_STATUS_RDY_FOR_VAL,
         DOC_STATUS_FAIL_VALID,
         DOC_STATUS_FAIL_BY_REJLVL,
         DOC_STATUS_RELN_FAIL,
         DOC_STATUS_VALIDATED
         );

 /*
  * Pick up all validation sets applicable to the
  * specified document
  */
 CURSOR  c_validation_sets(p_document_payable_id    IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE,
            p_payment_grouping_number            IBY_DOCS_PAYABLE_ALL.payment_grouping_number%TYPE,
            p_ext_payee_id                       IBY_DOCS_PAYABLE_ALL.ext_payee_id%TYPE,
             p_payment_method_code               IBY_DOCS_PAYABLE_ALL.payment_method_code%TYPE,
             p_int_bank_acct_id                  IBY_DOCS_PAYABLE_ALL.internal_bank_account_id%TYPE,
             p_payment_format_code               IBY_PAYMENT_PROFILES.payment_format_code%TYPE,
             p_bepid                             IBY_PAYMENT_PROFILES.bepid%TYPE,
             p_transmit_protocol_code            IBY_PAYMENT_PROFILES.transmit_protocol_code%TYPE,
             p_country                           CE_BANK_BRANCHES_V.country%TYPE
             )
 IS
 SELECT DISTINCT
     p_document_payable_id,
     p_payment_grouping_number,
     p_ext_payee_id,
     val.validation_set_code,
     val.validation_code_package,
     val.validation_code_entry_point,
     val_options.validation_assignment_id,
     val_options.val_assignment_entity_type,
     val.validation_set_display_name
 FROM
     IBY_VALIDATION_SETS_VL    val,
     IBY_VAL_ASSIGNMENTS       val_options
 WHERE
     val.validation_set_code   = val_options.validation_set_code
     AND val.validation_level_code = 'DOCUMENT'
     AND (val_options.val_assignment_entity_type    = 'METHOD'
              AND val_options.assignment_entity_id  =
                      p_payment_method_code
          OR val_options.val_assignment_entity_type = 'INTBANKACCOUNT'
              AND val_options.assignment_entity_id  =
                  to_char(p_int_bank_acct_id)
          OR val_options.val_assignment_entity_type = 'FORMAT'
              AND val_options.assignment_entity_id  =
                  p_payment_format_code
          OR val_options.val_assignment_entity_type = 'BANK'
              AND val_options.assignment_entity_id  =
                  to_char(p_bepid)
          OR val_options.val_assignment_entity_type = 'TRANSPROTOCOL'
              AND val_options.assignment_entity_id  =
                  p_transmit_protocol_code
          )
     AND NVL(val_options.inactive_date, sysdate+1) > sysdate

     /*
      * Fix for bug 4997133:
      *
      * Select validation sets that have the same payment method
      * code as the document, or have payment method code as null.
      *
      * Payment method code null implies that the validation
      * set is applicable to all payment methods.
      */
     AND (NVL(p_payment_method_code, '0') =
             NVL(val_options.payment_method_code, '0') OR
             val_options.payment_method_code IS NULL
         )

     /*
      * Fix for bug 4997133:
      *
      * Select validation sets that have the same country code
      * code as the document, or have country code as null.
      *
      * Country code null implies that the validation
      * set is applicable to all countries.
      */
     AND (p_country = val_options.territory_code OR
         val_options.territory_code IS NULL
         )
     ;

 BEGIN
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

	     print_debuginfo(l_module_name, 'Payment request id: '
	         || p_pay_service_request_id);

     END IF;
     /*
      * Fetch all the documents for this payment request.
      */
     OPEN  c_docs_list(p_pay_service_request_id);
     FETCH c_docs_list BULK COLLECT INTO l_docs_tab;
     CLOSE c_docs_list;

     /*
      * Exit if no documents were found.
      */
     IF (l_docs_tab.COUNT = 0) THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'No documents payable were '
	             || 'retrieved from DB for payment request '
	             || p_pay_service_request_id
	             || '. Exiting document validation..');

	         print_debuginfo(l_module_name, 'EXIT');
         END IF;
         RETURN;
     END IF;
     /*
      * Performance Fix:
      *
      * Instead of calling IBY_BUILD_UTILS_PKG.inactivateOldErrors(..)
      * once per document, delete all the error messages linked
      * to the failed documents of this PPR, and reset the document status
      * of the failed documents in one shot.
      */
     IBY_BUILD_UTILS_PKG.resetDocumentErrors(p_pay_service_request_id);

     /*
      * Loop through all the documents, validating them one-by-one.
      */
     FOR i in l_docs_tab.FIRST .. l_docs_tab.LAST LOOP

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Validating document id: '
	             || l_docs_tab(i).doc_id
	             );

	         print_debuginfo(l_module_name, 'document identifiers: '
	             || ' ('
	             || 'calling app doc unique id1: '
	             || l_docs_tab(i).ca_doc_id1
	             || ' calling app doc unique id2: '
	             || l_docs_tab(i).ca_doc_id2
	             || ' calling app doc unique id3: '
	             || l_docs_tab(i).ca_doc_id3
	             || ' calling app doc ref num: '
	             || l_docs_tab(i).ca_doc_ref_num
	             || ')'
	             );

         END IF;
         /*
          * Fix for bug 5440434:
          *
          * Before doing any validations, set any
          * existing validation error messages that
          * exist against this document to 'inactive'
          * status in the IBY_TRANSACTION_ERRORS table.
          *
          * Unless we do this, the old errors will
          * continue to show up against this document
          * in the IBY UI even if the document is validated
          * successfully this time round.
          */
         --IBY_BUILD_UTILS_PKG.inactivateOldErrors(l_docs_tab(i).doc_id,
         --    TRXN_TYPE_DOC);

         /*
          * STEP 1:
          * Core build program validations
          */

         /*
          * First validate that payment profile on the document
          * is valid for (pmt method, org, pmt currency,
          * int bank acct) on the document.
          */
         /* Initialize flag */
         IF(l_docs_tab(i).ext_bank_acct_id is not null) THEN
            IF (ext_bank_acct_tbl.EXISTS(l_docs_tab(i).ext_bank_acct_id)) THEN
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	            print_debuginfo(l_module_name, 'Getting the data from Cache For Ext Bank Account Id: ' || l_docs_tab(i).ext_bank_acct_id);
            END IF;
                l_end_date := ext_bank_acct_tbl(l_docs_tab(i).ext_bank_acct_id).end_date;
                l_country_code := ext_bank_acct_tbl(l_docs_tab(i).ext_bank_acct_id).country_code;
                l_foreign_pmts_ok_flag := ext_bank_acct_tbl(l_docs_tab(i).ext_bank_acct_id).foreign_pmts_ok_flag;
            ELSE
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Getting the data from DB For Ext Bank Account Id: ' || l_docs_tab(i).ext_bank_acct_id);
             END IF;
             BEGIN
                 -- Bug : 9248800 : Will reference base columns instead of view.
                 SELECT ieba.ext_bank_account_id,
                 ieba.country_code,
                 ieba.end_date,
                 ieba.foreign_payment_use_flag
                 INTO l_ext_bank_acct_id,
                 l_country_code,
                 l_end_date,
                 l_foreign_pmts_ok_flag
                 FROM IBY_EXT_BANK_ACCOUNTS ieba
                 WHERE ieba.ext_bank_account_id = l_docs_tab(i).ext_bank_acct_id;

             EXCEPTION
                      WHEN NO_DATA_FOUND THEN

                        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                        print_debuginfo(l_module_name, 'Exception No Data Found For Ext Bank Account Id: ' || l_docs_tab(i).ext_bank_acct_id);
                        END IF;
                        l_ext_bank_acct_id := null;
                        l_country_code := null;
                        l_end_date := null;
                        l_foreign_pmts_ok_flag := null;
             END;
            ext_bank_acct_tbl(l_docs_tab(i).ext_bank_acct_id).external_bank_account_id := l_ext_bank_acct_id;
            ext_bank_acct_tbl(l_docs_tab(i).ext_bank_acct_id).end_date := l_end_date;
            ext_bank_acct_tbl(l_docs_tab(i).ext_bank_acct_id).country_code := l_country_code;
            ext_bank_acct_tbl(l_docs_tab(i).ext_bank_acct_id).foreign_pmts_ok_flag := l_foreign_pmts_ok_flag;
            END IF;
         ELSE
         l_ext_bank_acct_id := null;
         l_country_code := null;
         l_end_date := null;
         l_foreign_pmts_ok_flag := null;
         END IF;

         IF(l_docs_tab(i).int_bank_acct_id is not null) THEN
             IF (int_bank_acct_tbl.EXISTS(l_docs_tab(i).int_bank_acct_id)) THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Getting the data from Cache For Int Bank Account Id: ' || l_docs_tab(i).int_bank_acct_id);
             END IF;
                l_country := int_bank_acct_tbl(l_docs_tab(i).int_bank_acct_id).country;
                l_bank_home_country := int_bank_acct_tbl(l_docs_tab(i).int_bank_acct_id).bank_home_country;

             ELSE
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Getting the data from DB For Int Bank Account Id: ' || l_docs_tab(i).int_bank_acct_id);
             END IF;
                 BEGIN
                    SELECT cba.bank_account_id,
                     cb.country,
                     cb.bank_home_country
                     INTO l_int_bank_acct_id,
                     l_country,
                     l_bank_home_country
                     FROM CE_BANK_ACCOUNTS cba, CE_BANK_BRANCHES_V cb
                     WHERE cba.bank_branch_id = cb.branch_party_id
                     AND  cba.bank_account_id = l_docs_tab(i).int_bank_acct_id;


                EXCEPTION
                          WHEN NO_DATA_FOUND THEN

                            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                            print_debuginfo(l_module_name, 'Exception No Data Found For Int Bank Account Id: ' || l_docs_tab(i).int_bank_acct_id);
                            END IF;
                            l_int_bank_acct_id := null;
                            l_country := null;
                            l_bank_home_country := null;
                END;
                int_bank_acct_tbl(l_docs_tab(i).int_bank_acct_id).internal_bank_account_id := l_int_bank_acct_id;
                int_bank_acct_tbl(l_docs_tab(i).int_bank_acct_id).country := l_country;
                int_bank_acct_tbl(l_docs_tab(i).int_bank_acct_id).bank_home_country := l_bank_home_country;
             END IF;
         ELSE
         l_int_bank_acct_id := null;
         l_country := null;
         l_bank_home_country := null;
         END IF;
         l_is_valid := FALSE;

         l_is_valid :=  validateProfileFromProfDrivers(
                            l_docs_tab(i).profile_id,
                            l_docs_tab(i).org_id,
                            l_docs_tab(i).org_type,
                            l_docs_tab(i).pmt_method_cd,
                            l_docs_tab(i).pmt_curr_code,
                            l_docs_tab(i).int_bank_acct_id
                            );

         IF (l_is_valid = FALSE) THEN
             /*
              * If profile is not applicable,
              * add doc to list of invalid documents.
              */
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Failing document id: '
	                 || l_docs_tab(i).doc_id
	                 || ' because payment profile is invalid');

             END IF;
             l_invalid_doc_rec.doc_id      := l_docs_tab(i).doc_id;
             l_invalid_doc_rec.pmt_grp_num := l_docs_tab(i).pmt_grp_num;
             l_invalid_doc_rec.payee_id    := l_docs_tab(i).payee_id;
             l_invalid_doc_rec.doc_status  := DOC_STATUS_REJECTED;
             l_invalid_docs_tab(l_invalid_docs_tab.COUNT + 1) :=
                 l_invalid_doc_rec;

             l_doc_failed_flag             := TRUE;

             /*
              * Once we fail a doc, we must add a corresponding
              * error message to the error table.
              */
             IBY_BUILD_UTILS_PKG.createErrorRecord(
                 TRXN_TYPE_DOC,
                 l_docs_tab(i).doc_id,
                 l_invalid_doc_rec.doc_status,
                 l_docs_tab(i).ca_id,
                 l_docs_tab(i).ca_doc_id1,
                 l_docs_tab(i).ca_doc_id2,
                 l_docs_tab(i).ca_doc_id3,
                 l_docs_tab(i).ca_doc_id4,
                 l_docs_tab(i).ca_doc_id5,
                 l_docs_tab(i).pp_tt_cd,
                 l_doc_err_rec,
                 l_doc_token_tab,
                 NULL,
                 'IBY_DOC_INVALID_PROFILE'
                 );

             insertIntoErrorTable(l_doc_err_rec, l_doc_error_tab,
                 l_doc_token_tab);

         ELSE

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Payment profile is valid for '
	                 || 'document id: '
	                 || l_docs_tab(i).doc_id);

             END IF;
         END IF;

         /*
          * Validate that the profile on the document
          * is compatible with the format on the document
          * payee.
          */

         /* Initialize flag */
         l_is_valid := FALSE;

         l_is_valid := checkProfileFormatCompat(
                           l_docs_tab(i).doc_id,
                           l_docs_tab(i).payee_id,
                           l_docs_tab(i).profile_id
                           );

         IF (l_is_valid = FALSE) THEN
             /*
              * If profile is not compatible with format,
              * add doc to list of invalid documents.
              */
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Failing document id: '
	                 || l_docs_tab(i).doc_id
	                 || ' because payment profile is not compatible '
	                 || ' with payment format.'
	                 );

             END IF;
             l_invalid_doc_rec.doc_id      := l_docs_tab(i).doc_id;
             l_invalid_doc_rec.pmt_grp_num := l_docs_tab(i).pmt_grp_num;
             l_invalid_doc_rec.payee_id    := l_docs_tab(i).payee_id;
             l_invalid_doc_rec.doc_status  := DOC_STATUS_REJECTED;
             l_invalid_docs_tab(l_invalid_docs_tab.COUNT + 1) :=
                 l_invalid_doc_rec;

             l_doc_failed_flag             := TRUE;

             /*
              * Once we fail a doc, we must add a corresponding
              * error message to the error table.
              */
             IBY_BUILD_UTILS_PKG.createErrorRecord(
                 TRXN_TYPE_DOC,
                 l_docs_tab(i).doc_id,
                 l_invalid_doc_rec.doc_status,
                 l_docs_tab(i).ca_id,
                 l_docs_tab(i).ca_doc_id1,
                 l_docs_tab(i).ca_doc_id2,
                 l_docs_tab(i).ca_doc_id3,
                 l_docs_tab(i).ca_doc_id4,
                 l_docs_tab(i).ca_doc_id5,
                 l_docs_tab(i).pp_tt_cd,
                 l_doc_err_rec,
                 l_doc_token_tab,
                 NULL,
                 'IBY_DOC_INV_PROFILE_FORMAT'
                 );

             insertIntoErrorTable(l_doc_err_rec, l_doc_error_tab,
                 l_doc_token_tab);

         ELSE

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Payment profile is compatible '
	                 || 'with payment format for '
	                 || 'document id: '
	                 || l_docs_tab(i).doc_id);

             END IF;
         END IF;

         /* Validating external/supplier bank account */
         /* Initialize flag */
         l_is_valid := FALSE;

         IF(nvl(l_end_date,sysdate+1) > sysdate) THEN
         l_is_valid := TRUE;
         END IF;

         IF(l_is_valid = TRUE) THEN
	  print_debuginfo(l_module_name, 'Ext Bank Acct Id field is: '
                 || l_docs_tab(i).ext_bank_acct_id
                 || ' for the assignments '
                 );
           print_debuginfo(l_module_name, 'Ext Payee Id field is: '
                 || l_docs_tab(i).payee_id
                 || ' for the assignments '
                 );
           IF(l_docs_tab(i).ext_bank_acct_id is not null and l_docs_tab(i).payee_id is not null) THEN
	   -- Set this to false only if bank account exists, We do not validate if
	   -- no bank account exists.
	    l_is_valid := FALSE;
             BEGIN
               SELECT end_date INTO l_end_date
               FROM iby_pmt_instr_uses_all
               WHERE instrument_id = l_docs_tab(i).ext_bank_acct_id
               AND ext_pmt_party_id = l_docs_tab(i).payee_id
               AND instrument_type = 'BANKACCOUNT'
               --Bug 9839599 AND payment_function = 'PAYABLES_DISB'
               AND payment_flow = 'DISBURSEMENTS';
	       -- Found account. Need not go forward.
	       l_account_found := TRUE;
             EXCEPTION
               WHEN NO_DATA_FOUND THEN
	       print_debuginfo(l_module_name, 'Bank Acct is not present at supplier site level');
	       l_end_date := null;
	       l_account_found := FALSE;
	       WHEN OTHERS THEN
	       print_debuginfo(l_module_name, 'Sql Query returns OTHER exception');
               l_end_date := null;
	     END;

	       SELECT PAYEE_PARTY_ID INTO l_payee_party_id
	       FROM IBY_EXTERNAL_PAYEES_ALL
	       WHERE EXT_PAYEE_ID = l_docs_tab(i).payee_id;

	       IF(l_end_date IS null AND l_account_found = FALSE) THEN
		       BEGIN
			  SELECT EXT_PAYEE_ID INTO l_payee_id
			  FROM IBY_EXTERNAL_PAYEES_ALL
			  WHERE PAYEE_PARTY_ID = l_payee_party_id
			  AND PARTY_SITE_ID IS NOT NULL
			  AND ORG_ID IS NOT NULL
			  AND ORG_TYPE IS NOT NULL
			  AND SUPPLIER_SITE_ID IS NULL;
		       EXCEPTION
		       WHEN NO_DATA_FOUND THEN
		       l_payee_id := null;
		       print_debuginfo(l_module_name, 'No Address OU level Payee Exists');
		       END;
	         IF (l_payee_id IS NOT null) THEN
		       BEGIN
			  SELECT end_date INTO l_end_date
			  FROM iby_pmt_instr_uses_all
			  WHERE instrument_id = l_docs_tab(i).ext_bank_acct_id
			  AND ext_pmt_party_id = l_payee_id
			  AND instrument_type = 'BANKACCOUNT'
			  --Bug 9839599 AND payment_function = 'PAYABLES_DISB'
			  AND payment_flow = 'DISBURSEMENTS';
			  -- Bank Account Found do not go further.
			  l_account_found := TRUE;
		       EXCEPTION
		       WHEN NO_DATA_FOUND THEN
		       print_debuginfo(l_module_name, 'Bank Acct is not present at Address OU level');
		       l_end_date := null;
		       WHEN OTHERS THEN
		       print_debuginfo(l_module_name, 'Sql Query returns OTHER exception');
		       l_end_date := null;
		       END;
	         END IF;
	       END IF;
	       IF(l_end_date IS null AND l_account_found = FALSE) THEN
		       BEGIN
			  SELECT EXT_PAYEE_ID INTO l_payee_id
			  FROM IBY_EXTERNAL_PAYEES_ALL
			  WHERE PAYEE_PARTY_ID = l_payee_party_id
			  AND PARTY_SITE_ID IS NOT NULL
			  AND ORG_ID IS NULL
			  AND ORG_TYPE IS NULL
			  AND SUPPLIER_SITE_ID IS NULL;
		       EXCEPTION
		       WHEN NO_DATA_FOUND THEN
		       l_payee_id := null;
		       print_debuginfo(l_module_name, 'No Address level Payee Exists');
		       END;
		 IF (l_payee_id IS NOT null) THEN
		       BEGIN
			  SELECT end_date INTO l_end_date
			  FROM iby_pmt_instr_uses_all
			  WHERE instrument_id = l_docs_tab(i).ext_bank_acct_id
			  AND ext_pmt_party_id = l_payee_id
			  AND instrument_type = 'BANKACCOUNT'
			  --Bug 9839599 AND payment_function = 'PAYABLES_DISB'
			  AND payment_flow = 'DISBURSEMENTS';
			  -- Found Account . Do not need to go ahead.
			  l_account_found := TRUE;
		       EXCEPTION
		       WHEN NO_DATA_FOUND THEN
		       print_debuginfo(l_module_name, 'Bank Acct is not present at Address level');
		       l_end_date := null;
		       WHEN OTHERS THEN
		       print_debuginfo(l_module_name, 'Sql Query returns OTHER exception');
		       l_end_date := null;
		       END;
		 END IF;
	       END IF;
               IF(l_end_date IS null AND l_account_found = FALSE) THEN
		       BEGIN
			  SELECT EXT_PAYEE_ID INTO l_payee_id
			  FROM IBY_EXTERNAL_PAYEES_ALL
			  WHERE PAYEE_PARTY_ID = l_payee_party_id
			  AND PARTY_SITE_ID IS NULL
			  AND ORG_ID IS NULL
			  AND ORG_TYPE IS NULL
			  AND SUPPLIER_SITE_ID IS NULL;
		       EXCEPTION
		       WHEN NO_DATA_FOUND THEN
		       l_payee_id := null;
		       print_debuginfo(l_module_name, 'No Address OU level Payee Exists');
		       END;
		 IF (l_payee_id IS NOT null) THEN
		       BEGIN
			  SELECT end_date INTO l_end_date
			  FROM iby_pmt_instr_uses_all
			  WHERE instrument_id = l_docs_tab(i).ext_bank_acct_id
			  AND ext_pmt_party_id = l_payee_id
			  AND instrument_type = 'BANKACCOUNT'
			  --Bug 9839599 AND payment_function = 'PAYABLES_DISB'
			  AND payment_flow = 'DISBURSEMENTS';
			   -- Found Account . Do not need to go ahead.
			  l_account_found := TRUE;
		       EXCEPTION
		       WHEN NO_DATA_FOUND THEN
		       print_debuginfo(l_module_name, 'Bank Acct is not present at Address level');
		       l_end_date := null;
		       WHEN OTHERS THEN
		       print_debuginfo(l_module_name, 'Sql Query returns OTHER exception');
		       l_end_date := null;
		       END;
		 END IF;
	       END IF;
             print_debuginfo(l_module_name, 'End Date field is: '
                 || l_end_date
                 || ' for the assignments '
                 );
            IF (l_account_found = TRUE) THEN
             IF(nvl(l_end_date,sysdate+1) > sysdate) THEN
             l_is_valid := TRUE;
             END IF;
	    ELSE
	    print_debuginfo(l_module_name, 'Account attached to supplier is not valid in this context!');
	    l_is_valid := FALSE;
	    END IF;
           END IF;
         END IF;

         IF (l_is_valid = FALSE) THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Failing document id: '
	                 || l_docs_tab(i).doc_id
	                 || ' Supplier / External Bankaccount is attached is NOT valid '
	                 );

             END IF;
             l_invalid_doc_rec.doc_id      := l_docs_tab(i).doc_id;
             l_invalid_doc_rec.pmt_grp_num := l_docs_tab(i).pmt_grp_num;
             l_invalid_doc_rec.payee_id    := l_docs_tab(i).payee_id;
             l_invalid_doc_rec.doc_status  := DOC_STATUS_REJECTED;
             l_invalid_docs_tab(l_invalid_docs_tab.COUNT + 1) :=
                 l_invalid_doc_rec;
             l_doc_failed_flag             := TRUE;

             /*
              * Once we fail a doc, we must add a corresponding
              * error message to the error table.
              */
             IBY_BUILD_UTILS_PKG.createErrorRecord(
                 TRXN_TYPE_DOC,
                 l_docs_tab(i).doc_id,
                 l_invalid_doc_rec.doc_status,
                 l_docs_tab(i).ca_id,
                 l_docs_tab(i).ca_doc_id1,
                 l_docs_tab(i).ca_doc_id2,
                 l_docs_tab(i).ca_doc_id3,
                 l_docs_tab(i).ca_doc_id4,
                 l_docs_tab(i).ca_doc_id5,
                 l_docs_tab(i).pp_tt_cd,
                 l_doc_err_rec,
                 l_doc_token_tab,
                 NULL,
                 'IBY_DOC_INV_BANK_ACCOUNT'
                 );
             insertIntoErrorTable(l_doc_err_rec, l_doc_error_tab,
                 l_doc_token_tab);
         ELSE
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Supplier / External Bankaccount is attached is valid for '
	                 || 'document id: '
	                 || l_docs_tab(i).doc_id);
             END IF;
         END IF;
         /*
          * Next, validate that internal bank account on doc is
          * valid for (org, currency) on document.
          */

         /*
          * Call CE API
          */
         /* Initialize flag */


         l_is_valid := FALSE;

         /* Commented for bug # 8322794
         CE_BANK_AND_ACCOUNT_UTIL.get_internal_bank_accts(
                                      l_docs_tab(i).pmt_curr_code,
                                      l_docs_tab(i).org_type,
                                      l_docs_tab(i).org_id,
                                      l_docs_tab(i).pmt_date,
                                      l_docs_tab(i).int_bank_acct_id,
                                      l_is_valid
                                      );
         */

         /*Begin of Bug 8322794*/

         l_internal_bank_accts_index := l_docs_tab(i).pmt_curr_code||'$'||l_docs_tab(i).org_type||'$'||l_docs_tab(i).org_id||'$'||l_docs_tab(i).pmt_date||'$'||l_docs_tab(i).int_bank_acct_id;
         IF(l_internal_bank_accts_index is not null) THEN
             IF(l_int_bank_accts_tbl.EXISTS(l_internal_bank_accts_index)) THEN
                   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                   print_debuginfo(l_module_name, 'Fetching the value from Cache Structure l_int_bank_accts_tbl ' || l_internal_bank_accts_index);
                   END IF;
	           l_is_valid := l_int_bank_accts_tbl(l_internal_bank_accts_index);
	     ELSE
	      print_debuginfo(l_module_name, 'Fetching the value from the DB for l_int_bank_accts_tbl ' || l_internal_bank_accts_index);
	      	 CE_BANK_AND_ACCOUNT_UTIL.get_internal_bank_accts(
	                                            l_docs_tab(i).pmt_curr_code,
	                                            l_docs_tab(i).org_type,
	                                            l_docs_tab(i).org_id,
	                                            l_docs_tab(i).pmt_date,
	                                            l_docs_tab(i).int_bank_acct_id,
	                                            l_is_valid
                                      );

	     	l_int_bank_accts_tbl(l_internal_bank_accts_index) := l_is_valid;
	     END IF;
         END IF;

         /*End of Bug 8322794*/


         IF (l_is_valid = FALSE) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Internal bank account '
	                 || l_docs_tab(i).int_bank_acct_id
	                 || ' is not applicable for org '
	                 || l_docs_tab(i).org_id
	                 || ', currency '
	                 || l_docs_tab(i).pmt_curr_code
	                 || ' and payment date '
	                 || l_docs_tab(i).pmt_date
	                 || ' combination');

             END IF;
             /*
              * If int bank account is not applicable,
              * add doc to list of invalid documents.
              */
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Failing document id: '
	                 || l_docs_tab(i).doc_id
	                 || ' because internal bank account is invalid');

             END IF;
             l_already_failed_flag :=
                 checkIfDocFailed(l_docs_tab(i).doc_id,
                     l_invalid_docs_tab);

             /*
              * Add this doc to the list of invalid documents
              * only if it is not already present in the
              * invalid docs list.
              */
             IF (l_already_failed_flag = FALSE) THEN

                 l_invalid_doc_rec.doc_id      := l_docs_tab(i).doc_id;
                 l_invalid_doc_rec.pmt_grp_num := l_docs_tab(i).pmt_grp_num;
                 l_invalid_doc_rec.payee_id    := l_docs_tab(i).payee_id;
                 l_invalid_doc_rec.doc_status  := DOC_STATUS_REJECTED;
                 l_invalid_docs_tab(l_invalid_docs_tab.COUNT + 1) :=
                     l_invalid_doc_rec;

                 l_doc_failed_flag             := TRUE;

             /*
              * Once we fail a doc, we must add a corresponding
              * error message to the error table.
              */
             IBY_BUILD_UTILS_PKG.createErrorRecord(
                 TRXN_TYPE_DOC,
                 l_docs_tab(i).doc_id,
                 l_invalid_doc_rec.doc_status,
                 l_docs_tab(i).ca_id,
                 l_docs_tab(i).ca_doc_id1,
                 l_docs_tab(i).ca_doc_id2,
                 l_docs_tab(i).ca_doc_id3,
                 l_docs_tab(i).ca_doc_id4,
                 l_docs_tab(i).ca_doc_id5,
                 l_docs_tab(i).pp_tt_cd,
                 l_doc_err_rec,
                 l_doc_token_tab,
                 NULL,
                 'IBY_DOC_INV_INTBANKACCT'
                 );

             insertIntoErrorTable(l_doc_err_rec, l_doc_error_tab,
                 l_doc_token_tab);

             END IF;

         ELSE

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Internal bank acct is valid for '
	                 || 'document id: '
	                 || l_docs_tab(i).doc_id);

             END IF;
         END IF;  -- if internal bank acct is invalid

         /*
          * Next, validate that external payee id on the doc is
          * valid (not -1). The ext payee id on the document
          * is derived from the payee context on the document;
          * these are fields such as payee id, payee party id,
          * payee party site id etc.
          *
          * The external party id is derived when the document
          * in inserted into the IBY tables. If the logic to
          * derive the ext payee id, could not find a matching
          * ext payee id for the document, then the ext payee id
          * would be set to -1 for that document.
          *
          * Fail all document that have the ext payee id set to
          * -1. The user is expected to seed the IBY_EXTERNAL_PAYEES_ALL
          * table such that the ext payee id is always available for
          * payee context on the document (otherwise, the
          * document cannot be paid!).
          */

         /* Initialize flag */
         l_is_valid := FALSE;

         IF (l_docs_tab(i).payee_id = -1) THEN
             l_is_valid := FALSE;
         ELSE
             l_is_valid := TRUE;
         END IF;

         IF (l_is_valid = FALSE) THEN

             /*
              * If ext payee id is not available,
              * add doc to list of invalid documents.
              */
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Failing document id: '
	                 || l_docs_tab(i).doc_id
	                 || ' because external payee id is not '
	                 || 'available for this document'
	                 );

             END IF;
             l_already_failed_flag :=
                 checkIfDocFailed(l_docs_tab(i).doc_id,
                     l_invalid_docs_tab);

             /*
              * Add this doc to the list of invalid documents
              * only if it is not already present in the
              * invalid docs list.
              */
             IF (l_already_failed_flag = FALSE) THEN

                 l_invalid_doc_rec.doc_id      := l_docs_tab(i).doc_id;
                 l_invalid_doc_rec.pmt_grp_num := l_docs_tab(i).pmt_grp_num;
                 l_invalid_doc_rec.payee_id    := l_docs_tab(i).payee_id;
                 l_invalid_doc_rec.doc_status  := DOC_STATUS_REJECTED;
                 l_invalid_docs_tab(l_invalid_docs_tab.COUNT + 1) :=
                     l_invalid_doc_rec;

                 l_doc_failed_flag             := TRUE;

             /*
              * Once we fail a doc, we must add a corresponding
              * error message to the error table.
              */
             IBY_BUILD_UTILS_PKG.createErrorRecord(
                 TRXN_TYPE_DOC,
                 l_docs_tab(i).doc_id,
                 l_invalid_doc_rec.doc_status,
                 l_docs_tab(i).ca_id,
                 l_docs_tab(i).ca_doc_id1,
                 l_docs_tab(i).ca_doc_id2,
                 l_docs_tab(i).ca_doc_id3,
                 l_docs_tab(i).ca_doc_id4,
                 l_docs_tab(i).ca_doc_id5,
                 l_docs_tab(i).pp_tt_cd,
                 l_doc_err_rec,
                 l_doc_token_tab,
                 NULL,
                 'IBY_DOC_INVALID_EXT_PAYEE'
                 );

             insertIntoErrorTable(l_doc_err_rec, l_doc_error_tab,
                 l_doc_token_tab);

             END IF;

         ELSE

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'External payee id is valid for '
	                 || 'document id: '
	                 || l_docs_tab(i).doc_id);

             END IF;
         END IF;  -- if external payee id is invalid

         /*
          * Validate that the external bank account can be used
          * for cross border payments (if the internal bank account
          * and external bank accounts belong to different countries).
          */

         /* Initialize flag */
         l_is_valid := FALSE;

         IF (l_country IS NOT NULL AND
             l_country_code IS NOT NULL) THEN

             IF (l_country <>
                 l_country_code) THEN

                 /*
                  * This is a cross border payment.
                  */
                 IF (UPPER(l_foreign_pmts_ok_flag) = 'Y') THEN

                     l_is_valid := TRUE;

                 ELSE

                     /*
                      * Fail document because cross-border
                      * payments are not allowed to this external
                      * bank account.
                      */
                     l_is_valid := FALSE;

                 END IF;

             ELSE

                 /*
                  * This is a domestic payment. Skip this
                  * validation.
                  */
                l_is_valid := TRUE;

             END IF;

         ELSE

             /*
              * If either internal bank account country is null
              * or external bank account country is null, assume
              * that the payment is domestic, and skip the validation.
              */
             l_is_valid := TRUE;

         END IF;


         IF (l_is_valid = FALSE) THEN

             /*
              * If cross border payment has been failed,
              * add doc to list of invalid documents.
              */

             -- Changed the error message for bug 5442800 (Panaraya)
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Failing document id: '
	                 || l_docs_tab(i).doc_id
	                 || 'The payee bank account is set up to allow '
	                 || 'domestic payments only. The internal bank '
	                 || 'account used to pay this document will result '
	                 || 'in an international payment to this payee bank '
	                 || 'account.'
	                 );

             END IF;
             l_already_failed_flag :=
                 checkIfDocFailed(l_docs_tab(i).doc_id,
                     l_invalid_docs_tab);

             /*
              * Add this doc to the list of invalid documents
              * only if it is not already present in the
              * invalid docs list.
              */
             IF (l_already_failed_flag = FALSE) THEN

                 l_invalid_doc_rec.doc_id      := l_docs_tab(i).doc_id;
                 l_invalid_doc_rec.pmt_grp_num := l_docs_tab(i).pmt_grp_num;
                 l_invalid_doc_rec.payee_id    := l_docs_tab(i).payee_id;
                 l_invalid_doc_rec.doc_status  := DOC_STATUS_REJECTED;
                 l_invalid_docs_tab(l_invalid_docs_tab.COUNT + 1) :=
                     l_invalid_doc_rec;

                 l_doc_failed_flag             := TRUE;

             /*
              * Once we fail a doc, we must add a corresponding
              * error message to the error table.
              */
             IBY_BUILD_UTILS_PKG.createErrorRecord(
                 TRXN_TYPE_DOC,
                 l_docs_tab(i).doc_id,
                 l_invalid_doc_rec.doc_status,
                 l_docs_tab(i).ca_id,
                 l_docs_tab(i).ca_doc_id1,
                 l_docs_tab(i).ca_doc_id2,
                 l_docs_tab(i).ca_doc_id3,
                 l_docs_tab(i).ca_doc_id4,
                 l_docs_tab(i).ca_doc_id5,
                 l_docs_tab(i).pp_tt_cd,
                 l_doc_err_rec,
                 l_doc_token_tab,
                 NULL,
                 'IBY_DOC_INV_CROSSBORDER_PMT'
                 );

             insertIntoErrorTable(l_doc_err_rec, l_doc_error_tab,
                 l_doc_token_tab);

             END IF;

         END IF;  -- if external payee id is invalid

         /*
          * STEP 2:
          * Dynamic validations via validation sets
          */

         /*
          * Fetch all applicable validation sets for this document.
          */
       IF (l_profile_format_tab.EXISTS(l_docs_tab(i).profile_id) ) THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo(l_module_name, 'Getting Data from Cache For Profile Id: ' || l_docs_tab(i).profile_id);
       END IF;
         l_payment_format_cd := l_profile_format_tab(l_docs_tab(i).profile_id).payment_format_cd;
         l_bepid := l_profile_format_tab(l_docs_tab(i).profile_id).bepid;
         l_transmit_protocol_cd := l_profile_format_tab(l_docs_tab(i).profile_id).transmit_protocol_cd;

       ELSE
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo(l_module_name, 'Getting Data from DB For Profile Id: ' || l_docs_tab(i).profile_id);
       END IF;
           BEGIN
                SELECT ipp.payment_profile_id,
                   ipp.payment_format_code, ipp.bepid, ipp.transmit_protocol_code
                INTO l_profile_id,l_payment_format_cd,l_bepid,l_transmit_protocol_cd
                FROM IBY_PAYMENT_PROFILES ipp
                WHERE ipp.payment_profile_id = l_docs_tab(i).profile_id ;

           EXCEPTION
                      WHEN NO_DATA_FOUND THEN

                        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                        print_debuginfo(l_module_name, 'Exception No Data Found Occured For Profile Id: ' || l_docs_tab(i).profile_id);
                        END IF;
                        l_profile_id := null;
                        l_payment_format_cd := null;
                        l_bepid := null;
                        l_transmit_protocol_cd := null;
           END;
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	           print_debuginfo(l_module_name, 'Assigning the values in Cache For Profile Id: ' || l_docs_tab(i).profile_id);
           END IF;
           l_profile_format_tab(l_docs_tab(i).profile_id).profile_id := l_profile_id;
           l_profile_format_tab(l_docs_tab(i).profile_id).payment_format_cd := l_payment_format_cd;
           l_profile_format_tab(l_docs_tab(i).profile_id).bepid := l_bepid;
           l_profile_format_tab(l_docs_tab(i).profile_id).transmit_protocol_cd := l_transmit_protocol_cd;

       END IF;
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	          print_debuginfo(l_module_name, 'Before doing a bulk insert to the cursor');
	          print_debuginfo(l_module_name, 'Before doing a bulk insert doc_id is ' || l_docs_tab(i).doc_id);
	          print_debuginfo(l_module_name, 'Before doing a bulk insert pmt_grp_num is ' || l_docs_tab(i).pmt_grp_num);
	          print_debuginfo(l_module_name, 'Before doing a bulk insert payee_id is ' || l_docs_tab(i).payee_id);
	          print_debuginfo(l_module_name, 'Before doing a bulk insert pmt_method_cd is ' || l_docs_tab(i).pmt_method_cd);
	          print_debuginfo(l_module_name, 'Before doing a bulk insert int_bank_acct_id is ' || l_docs_tab(i).int_bank_acct_id);
	          print_debuginfo(l_module_name, 'Before doing a bulk insert l_payment_format_cd is ' || l_payment_format_cd);
	          print_debuginfo(l_module_name, 'Before doing a bulk insert l_bepid is ' || l_bepid);
	          print_debuginfo(l_module_name, 'Before doing a bulk insert l_transmit_protocol_cd is ' || l_transmit_protocol_cd);
	          print_debuginfo(l_module_name, 'Before doing a bulk insert l_country is ' || l_country);

          END IF;
        --l_val_set_index = 'DOCUMENT'||'$'||p_payment_method_code||'$'||p_int_bank_acct_id||'$'||p_payment_format_code||'$'||p_bepid||'$'||p_transmit_protocol_code||'$'||p_country;
        l_val_set_index := 'DOCUMENT'||'$'||l_docs_tab(i).pmt_method_cd||'$'||To_Char(l_docs_tab(i).int_bank_acct_id)||'$'||l_payment_format_cd||'$'||To_Char(l_bepid)||'$'||l_transmit_protocol_cd||'$'||l_country;
        IF (val_set_outer_tbl.EXISTS(l_val_set_index)) THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo(l_module_name, 'The data for the index already exists');


        END IF;
        l_val_sets_temp_tab := val_set_outer_tbl(l_val_set_index).val_set_tbl;
            IF (l_val_sets_temp_tab.count <> 0) THEN
               FOR k in l_val_sets_temp_tab.FIRST .. l_val_sets_temp_tab.LAST LOOP
                  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                  print_debuginfo(l_module_name, 'Before doing a bulk insert to the cursor and in If loop');
                  END IF;
                  l_val_sets_tab(k).doc_id := l_docs_tab(i).doc_id;
                  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                  print_debuginfo(l_module_name, 'Before doing a bulk insert doc_id is ' || l_val_sets_tab(k).doc_id);
                  END IF;
                  l_val_sets_tab(k).pmt_grp_num := val_set_outer_tbl(l_val_set_index).val_set_tbl(k).pmt_grp_num;
                  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                  print_debuginfo(l_module_name, 'Before doing a bulk insert pmt_grp_num is ' || l_val_sets_tab(k).pmt_grp_num);
                  END IF;
                  l_val_sets_tab(k).payee_id := val_set_outer_tbl(l_val_set_index).val_set_tbl(k).payee_id;
                   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                   print_debuginfo(l_module_name, 'Before doing a bulk insert payee_id is ' || l_val_sets_tab(k).payee_id);
                   END IF;
                  l_val_sets_tab(k).val_set_code := val_set_outer_tbl(l_val_set_index).val_set_tbl(k).val_set_code;
                  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                  print_debuginfo(l_module_name, 'Before doing a bulk insert val_set_code is ' || l_val_sets_tab(k).val_set_code);
                  END IF;
                  l_val_sets_tab(k).val_code_pkg := val_set_outer_tbl(l_val_set_index).val_set_tbl(k).val_code_pkg;
                  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                  print_debuginfo(l_module_name, 'Before doing a bulk insert val_code_pkg is ' || l_val_sets_tab(k).val_code_pkg);
                  END IF;
                  l_val_sets_tab(k).val_code_entry_point := val_set_outer_tbl(l_val_set_index).val_set_tbl(k).val_code_entry_point;
                  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                  print_debuginfo(l_module_name, 'Before doing a bulk insert val_code_entry_point is ' || l_val_sets_tab(k).val_code_entry_point);
                  END IF;
                  l_val_sets_tab(k).val_assign_id := val_set_outer_tbl(l_val_set_index).val_set_tbl(k).val_assign_id;
                  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                  print_debuginfo(l_module_name, 'Before doing a bulk insert val_assign_id is ' || l_val_sets_tab(k).val_assign_id);
                  END IF;
                  l_val_sets_tab(k).val_assign_entity_type := val_set_outer_tbl(l_val_set_index).val_set_tbl(k).val_assign_entity_type;
                  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                  print_debuginfo(l_module_name, 'Before doing a bulk insert val_assign_entity_type is ' || l_val_sets_tab(k).val_assign_entity_type);
                  END IF;
                  l_val_sets_tab(k).val_set_name := val_set_outer_tbl(l_val_set_index).val_set_tbl(k).val_set_name;
                  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                  print_debuginfo(l_module_name, 'Before doing a bulk insert val_set_name is ' || l_val_sets_tab(k).val_set_name);
                  END IF;
              END LOOP;
           ELSE
              l_val_sets_tab := val_set_outer_tbl(l_val_set_index).val_set_tbl;
           END IF;
           l_val_sets_count := val_set_outer_tbl(l_val_set_index).val_set_count;
        ELSE
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo(l_module_name, 'Need to query DB again');


        END IF;
         OPEN  c_validation_sets(l_docs_tab(i).doc_id, l_docs_tab(i).pmt_grp_num, l_docs_tab(i).payee_id,
              l_docs_tab(i).pmt_method_cd, l_docs_tab(i).int_bank_acct_id, l_payment_format_cd,l_bepid,l_transmit_protocol_cd,l_country);
         FETCH c_validation_sets BULK COLLECT INTO l_val_sets_tab;
         CLOSE c_validation_sets;
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'After fetching values from the cursor');

             END IF;
             val_set_outer_tbl(l_val_set_index).val_set_tbl := l_val_sets_tab;
             val_set_outer_tbl(l_val_set_index).val_set_count := l_val_sets_tab.count;
             l_val_sets_count := l_val_sets_tab.count;
        END IF;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'After doing a bulk insert to the cursor');
	             print_debuginfo(l_module_name, 'The cursor return count is' || l_val_sets_count);
             END IF;
         /*
          * Exit if no validation sets applicable to this doc were found.
          */
         IF (l_val_sets_count = 0) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'No validation sets applicable '
	                 || 'to document payable id '
	                 || l_docs_tab(i).doc_id
	                 || ' were found. Skipping validations for this doc..');

	             print_debuginfo(l_module_name, '+-------------------------+');

             END IF;
         ELSE

             /*
              * Loop through all the applicable validation sets
              * for each document
              */
             FOR j in l_val_sets_tab.FIRST .. l_val_sets_tab.LAST LOOP

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Applicable validation set ('
	                     || l_val_sets_tab(j).val_assign_entity_type
	                     || ') : '
	                     || l_val_sets_tab(j).val_set_name
	                     );

                 END IF;
                 /*
                  * Dynamically call the corresponding validation code
                  * entry point.
                  */
                 l_stmt := 'CALL '
                               || l_val_sets_tab(j).val_code_pkg
                               || '.'
                               || l_val_sets_tab(j).val_code_entry_point
                               || '(:1,:2,:3,:4,:5)';

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Executing ' || l_stmt);

                 END IF;
                 EXECUTE IMMEDIATE (l_stmt) USING
                     IN l_val_sets_tab(j).val_assign_id,
                     IN l_val_sets_tab(j).val_set_code,
                     IN l_val_sets_tab(j).doc_id,
                     IN 'N',
                     OUT l_result;

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Finished executing '
	                     || l_stmt);

	                 print_debuginfo(l_module_name, 'Result: '
	                     || l_result);

                 END IF;
                 IF (l_result <> 0) THEN
                     /*
                      * If document has failed validation, add it to
                      * list of invalid documents.
                      */

                     l_already_failed_flag :=
                         checkIfDocFailed(l_val_sets_tab(j).doc_id,
                             l_invalid_docs_tab);

                     /*
                      * Add this doc to the list of invalid documents
                      * only if it is not already present in the
                      * invalid docs list.
                      */
                     IF (l_already_failed_flag = FALSE) THEN

                         l_invalid_doc_rec.doc_id := l_val_sets_tab(j).doc_id;
                         l_invalid_doc_rec.pmt_grp_num :=
                             l_val_sets_tab(j).pmt_grp_num;
                         l_invalid_doc_rec.payee_id :=
                             l_val_sets_tab(j).payee_id;
                         l_invalid_doc_rec.doc_status := DOC_STATUS_REJECTED;

                         l_invalid_docs_tab(l_invalid_docs_tab.COUNT + 1) :=
                             l_invalid_doc_rec;

                         l_doc_failed_flag        := TRUE;

                         /*
                          * Validations sets handle the error messages
                          * themselves. Therefore, no need to populate
                          * the error record here.
                          */

                     END IF;

                 ELSE
                         l_doc_failed_flag        := FALSE;

                 END IF; -- if result <> 0

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, '+-------------------------+');

                 END IF;
             END LOOP; -- for each validation set

         END IF; -- if count of val sets <> 0

         /*
          * At least one document in the payment request has
          * been validated successfully. Keep track of this
          * fact; it will be used in updating the status
          * of the payment request.
          */
         IF (l_doc_failed_flag = FALSE) THEN
             l_all_docs_failed_flag := FALSE;
         END IF;

     END LOOP; -- for each document

     /*
      * Documents within a payment request may be related to each
      * other by the 'payment grouping number'. If any document is
      * failed, then all it's related documents must also be failed.
      *
      * If any documents have been failed due to validation
      * then make sure to fail it's sister docs.
      */
     IF (l_invalid_docs_tab.COUNT > 0) THEN
         failRelatedDocs(l_docs_tab, l_invalid_docs_tab, l_doc_error_tab,
             l_doc_token_tab);
     END IF;

     /*
      * Check if at least one document has failed. This
      * information is used when updating the payment
      * request status.
      */
     IF (l_invalid_docs_tab.COUNT > 0) THEN
         l_all_docs_success_flag := FALSE;
     ELSE
         l_all_docs_success_flag := TRUE;
     END IF;

     /*
      * Get the rejection level system option
      */
     IF (p_doc_rejection_level IS NOT NULL) THEN

         /*
          * Use the document rejection level passed in
          * with the payment service request (if available).
          */
         l_rejection_level := p_doc_rejection_level;

     ELSE

         /*
          * If the document rejection level is not passed
          * in with the payment service request, derive
          * the document rejection level setting at the
          * enterprise level.
          */
         l_rejection_level := getDocRejLevelSysOption();

     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Rejection level system option: '
	         || l_rejection_level);

     END IF;
     /*
      * If the rejection level is 'payee', then fail all
      * documents for this payee even if a single document
      * for this payee has failed.
      */
     IF (l_all_docs_success_flag = FALSE) THEN

         IF (l_rejection_level = REJ_LVL_PAYEE) THEN

             failAllDocsForPayee(l_docs_tab, l_invalid_docs_tab,
                 l_doc_error_tab, l_doc_token_tab);

             /*
              * Since docs related by payee id have been failed,
              * it is possible that some new payment grouping
              * no's have been failed as part of this process.
              *
              * Therefore, again scan all documents and fail
              * those that are related by orig doc id.
              */
             IF (l_invalid_docs_tab.COUNT > 0) THEN
                 failRelatedDocs(l_docs_tab, l_invalid_docs_tab,
                     l_doc_error_tab, l_doc_token_tab);
             END IF;

         END IF;

     END IF;

     /*
      * All docs of payment request may have been failed because of
      * cascaded failures.
      *
      * Compare the docs in the payment request with the docs in the
      * error docs list to see if all have failed or not.
      */
     l_all_docs_failed_flag := checkIfAllDocsFailed(l_docs_tab,
                                   l_invalid_docs_tab);

     /*
      * Update the status of the documents and the payment
      * request.
      */
     performDBUpdates(
         p_pay_service_request_id,
         l_docs_tab,
         l_invalid_docs_tab,
         l_all_docs_success_flag,
         l_all_docs_failed_flag,
         l_rejection_level,
         l_doc_error_tab,
         l_doc_token_tab,
         x_return_status
         );

     /*
      * Get attributes from the payment request like
      * calling app payred id, calling app id etc.
      * These are required to raise business events.
      */
     getRequestAttributes(p_pay_service_request_id, req_ca_payreq_cd,
         req_ca_id);

     /*
      * Finally, raise business events to inform the calling app
      * if any documents have failed.
      *
      * Note: this should be the last call after database records
      * have been inserted / updated. This is because you cannot
      * 'rollback' a business event once raised.
      */
     IF (p_is_singpay_flag = FALSE) THEN

         raiseBizEvents(p_pay_service_request_id, req_ca_payreq_cd, req_ca_id,
             l_all_docs_success_flag, l_rejection_level);

     ELSE

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Not invoking raiseBizEvents() '
	             || 'because the request '
	             || p_pay_service_request_id
	             || ' is a single payment.'
	             );

         END IF;
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Completed validations for payment '
	         || 'request :'
	         || p_pay_service_request_id);

	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
     EXCEPTION
         WHEN OTHERS THEN
             FND_MESSAGE.SET_NAME('IBY', '');
             FND_MESSAGE.SET_TOKEN('SQLERR','applyDocumentValidationSets: '
                 || substr(SQLERRM, 1, 300));
             FND_MSG_PUB.Add;
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name,substr(SQLERRM, 1, 300),
	                 FND_LOG.LEVEL_UNEXPECTED);
             END IF;
             RAISE g_abort_program;

 END applyDocumentValidationSets;

/*--------------------------------------------------------------------
 | NAME:
 |     performOnlineValidations
 |
 | PURPOSE:
 |     Perform online/immediate validations. Immediate validations
 |     invoke the same validation sets as deferred validations, but
 |     errors are returned as warnings and status of the documents
 |     are not affected.
 |
 |     Online validations are performed on documents individually.
 |     At the time when online validations are invoked the
 |     payment request is not yet formed in the calling app.
 |
 |     So this method is invoked for one document at a time by the
 |     calling app.
 |
 | PARAMETERS:
 |     IN
 |         p_document_id
 |             the id of the given document.
 |
 |     OUT
 |         x_return_status
 |             -1 indicates that the given document has failed
 |                 at least one validation.
 |             0 indicates that the given document has passed
 |                 all validations.
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE performOnlineValidations(
     p_document_id     IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     x_return_status   IN OUT NOCOPY NUMBER)
 IS
 l_module_name        CONSTANT VARCHAR2(200) := G_PKG_NAME ||
                                                    '.performOnlineValidations';
 l_stmt               VARCHAR2(200);
 l_result             NUMBER := 0;
 l_validation_failed  BOOLEAN := FALSE;

 /*
  * Pick up validation sets based on method, internal bank
  * account and format attributes on the given document.
  *
  * At the time of online validations, the payment profile
  * is not expected to be available. This means that we
  * cannot perform online validations based on bank or
  * transmission protocol (since these are derived from
  * the payment profile).
  */

 /*
  * Fix for bug 5548886:
  *
  * Add index hint to improve performance.
  */
 CURSOR
     c_val_sets(p_document_payable_id VARCHAR2)
 IS
 SELECT /*+ INDEX(docs IBY_DOCS_PAYABLE_GT_N1)  NO_EXPAND */
     docs.document_payable_id,
     val.validation_set_code,
     val.validation_code_package,
     val.validation_code_entry_point,
     val_options.validation_assignment_id,
     val_options.val_assignment_entity_type,
     val.validation_set_display_name
 FROM
     IBY_VALIDATION_SETS_VL    val,
     IBY_VAL_ASSIGNMENTS       val_options,
     IBY_DOCS_PAYABLE_GT       docs
 WHERE
     docs.document_payable_id = p_document_payable_id
 AND
     val.validation_set_code = val_options.validation_set_code
 AND
     val.validation_level_code = 'DOCUMENT'
 AND (val_options.val_assignment_entity_type = 'METHOD'
          AND val_options.assignment_entity_id = docs.payment_method_code
     OR val_options.val_assignment_entity_type = 'INTBANKACCOUNT'
          AND val_options.assignment_entity_id = docs.internal_bank_account_id
     OR val_options.val_assignment_entity_type = 'FORMAT'
          AND val_options.assignment_entity_id = docs.payment_format_code
     )
 AND NVL(val_options.inactive_date, sysdate+1) >= sysdate
 ;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

	     print_debuginfo(l_module_name, 'Document id: '
	         || p_document_id);

     END IF;
     /*
      * Loop through all applicable validation sets for this
      * document.
      *
      * Validation sets will be picked up based on provided
      * document attributes. Almost all the document attributes
      * are optional at the time of online validations, so
      * it is possible that few/none of the validation sets
      * are picked up.
      */
     FOR valset_rec in c_val_sets(p_document_id) LOOP

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Applicable validation set ('
	             || valset_rec.val_assignment_entity_type
	             || ') : '
	             || valset_rec.validation_set_display_name
	             );

         END IF;
         /*
          * Dynamically execute the validation
          */
         l_stmt := 'CALL '
                       || valset_rec.validation_code_package
                       || '.'
                       || valset_rec.validation_code_entry_point
                       || '(:1,:2,:3,:4,:5)';

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Executing '|| l_stmt);

         END IF;
         EXECUTE IMMEDIATE (l_stmt) USING
             IN valset_rec.validation_assignment_id,
             IN valset_rec.validation_set_code,
             IN valset_rec.document_payable_id,
             IN 'Y',
             OUT l_result;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'result: '|| l_result);

         END IF;
         IF (l_result <> 0) THEN

             /*
              * If document has failed validation, set the
              * validation failed flag. This will be used
              * to determine the return status.
              */
             l_validation_failed := TRUE;

         END IF;

     END LOOP;

     /*
      * If even a single validation has failed for this
      * document , set the return status to indicate
      * validation failure.
      */
     IF (l_validation_failed = TRUE) THEN
         x_return_status := -1;
     ELSE
         x_return_status := 0;
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Return status before exiting: '
	         || x_return_status
	         );

	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 EXCEPTION
     WHEN OTHERS THEN
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Exception occured when attempting '
	         || 'online validation.'
	         );
	     print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	     print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);

     END IF;
     /*
      * Since online validations are really validation warnings,
      * set the return status to -1 and exit gracefully.
      */
     x_return_status := -1;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Return status before exiting: '
	         || x_return_status
	         );

	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END performOnlineValidations;

/*--------------------------------------------------------------------
 | NAME:
 |     initDocumentData
 |
 | PURPOSE:
 |     Initializes the document record from Oracle Payment's tables.
 |     All the related fields of a document are picked up including
 |     Payer/Payee/Payer Bank/Payee Bank.
 |
 |     These fields are populated into the document record and passed
 |     to the caller (validation sets) as an output parameter.
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
 PROCEDURE initDocumentData(
     p_document_id  IN IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE,
     x_document_rec IN OUT NOCOPY documentRecType,
     p_isOnline     IN VARCHAR2
     )
 IS

 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME || '.initDocumentData';

 /*
  * Cursor for deferred validation.
  *
  * Pick up all the document fields which need to be validated.
  *
  * Note: If you modify the fields in the query below, please
  * modify the fields in the 'documentRecType' record in the spec
  * as well.
  */
 CURSOR c_documentInfo (p_doc_id
             IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE)
 RETURN documentRecType
 IS
 SELECT
     docs.calling_app_id                 calling_app_id,
     docs.calling_app_doc_unique_ref1    calling_app_doc_id1,
     docs.calling_app_doc_unique_ref2    calling_app_doc_id2,
     docs.calling_app_doc_unique_ref3    calling_app_doc_id3,
     docs.calling_app_doc_unique_ref4    calling_app_doc_id4,
     docs.calling_app_doc_unique_ref5    calling_app_doc_id5,
     docs.pay_proc_trxn_type_code        pay_proc_trxn_type_cd,
     docs.document_payable_id            document_id,
     docs.payment_amount                 document_amount,
     docs.payment_currency_code          document_pay_currency,
     docs.exclusive_payment_flag         exclusive_payment_flag,
     docs.delivery_channel_code          delivery_channel_code,
     del_chn.format_value                delivery_chn_format_val,
     docs.unique_remittance_identifier   unique_remit_id_code,
     docs.payment_reason_comments        payment_reason_comments,
     docs.settlement_priority            settlement_priority,
     docs.remittance_message1            remittance_message1,
     docs.remittance_message2            remittance_message2,
     docs.remittance_message3            remittance_message3,
     docs.uri_check_digit                uri_check_digit,
     docs.external_bank_account_id       external_bank_account_id,


     iba_bnk_branch.bank_number          int_bank_num,
     iba_bnk_branch.bank_name            int_bank_name,
     iba_bnk_branch.bank_name_alt        int_bank_name_alt,
     iba_bnk_branch.branch_number        int_bank_branch_num,
     iba_bnk_branch.bank_branch_name     int_bank_branch_name,
     iba_bnk_branch.bank_branch_name_alt int_bank_branch_name_alt,

     iba.bank_account_num                int_bank_acc_num,
     iba.bank_account_name               int_bank_acc_name,
     iba.bank_account_name_alt           int_bank_acc_name_alt,
     iba.bank_account_type               int_bank_acc_type,
     iba.iban_number                     int_bank_acc_iban,
     ''                                  int_bank_assigned_id1,
     ''                                  int_bank_assigned_id2,
     iba.eft_user_num                    int_eft_user_number,
     iba.check_digits                    int_bank_acc_chk_dgts,
     iba.eft_requester_identifier        int_eft_req_identifier,
     iba.short_account_name              int_bank_acc_short_name,
     iba.account_holder_name             int_bank_acc_holder_name,
     iba.account_holder_name_alt         int_bank_acc_holder_name_alt,

     payer.party_legal_name              payer_le_name,
     payer.party_address_country         payer_le_country,
     payer.party_phone                   payer_phone,
     payer.party_registration_number     payer_registration_number, -- added by asarada (SEPA Credit Transfer 3.3 Changes)
     IBY_FD_EXTRACT_GEN_PVT.
            Get_FP_TaxRegistration
               (docs.legal_entity_id)    payer_tax_registration_number, -- added by asarada (SEPA Credit Transfer 3.3 Changes)
     eba.bank_number                     ext_bank_num,
     eba.bank_name                       ext_bank_name,
     ''                                  ext_bank_name_alt,
     eba.branch_number                   ext_bank_branch_num,
     eba.bank_branch_name                ext_bank_branch_name,
     eba_bank_branch.bank_branch_name_alt ext_bank_branch_name_alt,
     eba.country_code                    ext_bank_country,
     eba_bank_branch.address_line1       ext_bank_branch_addr1,
     nvl(eba_bank_branch.country,eba_bank_branch.bank_home_country)             ext_bank_branch_country,

     eba.bank_account_number             ext_bank_acc_num,
     eba.bank_account_name               ext_bank_acc_name,
     eba.alternate_account_name          ext_bank_acc_name_alt,
     eba.bank_account_type               ext_bank_acc_type,
     eba.iban_number                     ext_bank_acc_iban,
     eba.check_digits                    ext_bank_acc_chk_dgts,
     eba.short_acct_name                 ext_bank_acc_short_name,
     eba.primary_acct_owner_name         ext_bank_acc_holder_name,
     ''                                  ext_bank_acc_holder_name_alt,
     eba.eft_swift_code    ext_bank_acc_BIC,     -- The documentRecType in the ibyvalls.pls was modified

     payee.party_name                    payee_party_name,
     payee_addr.add_line1                payee_party_addr1,
     payee_addr.add_line2                payee_party_addr2,
     payee_addr.add_line3                payee_party_addr3,
     payee_addr.city                     payee_party_city,
     payee_addr.state                    payee_party_state,
     payee_addr.province                 payee_party_province,
     payee_addr.county                   payee_party_county,
     payee_addr.postal_code              payee_party_postal,
     payee_addr.country                  payee_party_country,

     docs.bank_charge_bearer             bank_charge_bearer,
     docs.payment_reason_code            payment_reason_code,
     docs.payment_method_code            payment_method_cd,
     docs.payment_format_code            payee_payment_format_cd,
     payeesite.party_site_name           payee_party_site_name
 FROM
     IBY_DOCS_PAYABLE_ALL         docs,
     IBY_PP_FIRST_PARTY_V         payer,
     HZ_PARTIES                   payee,
     HZ_PARTY_SITES               payeesite,
     CE_BANK_ACCOUNTS             iba,
     CE_BANK_BRANCHES_V           iba_bnk_branch,
     IBY_EXT_BANK_ACCOUNTS_INT_V  eba,
     CE_BANK_BRANCHES_V           eba_bank_branch,
     IBY_DELIVERY_CHANNELS_B      del_chn,

     /*
      * Fix for bug 5997016:
      *
      * The payee address cannot be always assumed to be stored in
      * HZ_LOCATIONS table (TCA).
      *
      * For employee type payees, the address is stored in
      * per_addresses (HR).
      *
      * The 'address source' column on the document payable identifies
      * the source of the address information -
      * TCA = address is stored in HZ_LOCATIONS
      * HR  = address is stored in PER_ADDRESSES
      *
      * Therefore, we need to dynamically pick up the payee address
      * fields from the correct table. The SELECT statement below is
      * used to dynamically form the address table based on the
      * address source. This dynamic table is aliased as payee_addr.
      *
      * There is a dynamic address tabled formed in a similar manner
      * during the payment creation process as well [see method
      * IBY_PAYGROUP_PUB.auditPaymentData(..)].
      */
     (
     SELECT

      /* payee add line1 */
      DECODE(
        doc.address_source,

        -- supplier address line 1
        'TCA', payee_loc.address1,

        -- employee add line 1
        DECODE
        (
          doc.employee_address_code,

          -- employee home addr line 1
          'HOME', per_addr.address_line1,

          -- employee office addr line 1
          'OFFICE',per_loc.address_line_1,

          --address code not specified
          DECODE (per_addr.address_id,
                 NULL, per_loc.address_line_1,
                 per_addr.address_line1)
         )

        ) add_line1,

      /* payee add line2 */
      DECODE(
        doc.address_source,

        -- supplier address line 2
        'TCA', payee_loc.address2,

        -- employee add line 2
        DECODE
        (
          doc.employee_address_code,

          -- employee home addr line 2
          'HOME', per_addr.address_line2,

          -- employee office addr line 2
          'OFFICE',per_loc.address_line_2,

          --address code not specified
          DECODE (per_addr.address_id,
                 NULL, per_loc.address_line_2,
                 per_addr.address_line2)
         )
        ) add_line2,


      /* payee add line3 */
      DECODE(
        doc.address_source,

        -- supplier address line 3
        'TCA', payee_loc.address3,

        -- employee add line 3
        DECODE
        (
          doc.employee_address_code,

          -- employee home addr line 3
          'HOME', per_addr.address_line3,

          -- employee office addr line 3
          'OFFICE',per_loc.address_line_3,

          --address code not specified
          DECODE (per_addr.address_id,
                 NULL, per_loc.address_line_3,
                 per_addr.address_line3)
         )

        ) add_line3,


      /* payee add line4 */
      DECODE(
        doc.address_source,

        -- supplier address line 4
        'TCA', payee_loc.address4,

        -- employee home/office addr line 4 (not available)
        null

        ) add_line4,

      /* payee city */
      DECODE(
        doc.address_source,

        -- supplier city
        'TCA', payee_loc.city,

        -- employee city
        DECODE
        (
          doc.employee_address_code,

          -- employee home city
          'HOME', per_addr.town_or_city,

          -- employee office city
          'OFFICE', per_loc.town_or_city,

          -- address code not specified
          DECODE (per_addr.address_id,
                 NULL, per_loc.town_or_city,
                 per_addr.town_or_city)
          )

        ) city,


      /* payee county */
      DECODE(
        doc.address_source,

        -- supplier county
        'TCA', payee_loc.county,

        -- employee county
        (
        DECODE(
          doc.employee_address_code,

          -- employee home county
          'HOME',
          DECODE(
            per_addr.style,
            'US',     NVL(per_addr.region_1,   ''),
            'US_GLB', NVL(per_addr.region_1,   ''),
            'IE',     NVL(ap_web_db_expline_pkg.
                              getcountyprovince(
                                  per_addr.style,
                                  per_addr.region_1),
                        ''),
            'IE_GLB', NVL(ap_web_db_expline_pkg.
                              getcountyprovince(
                                  per_addr.style,
                                  per_addr.region_1),
                        ''),
            'GB',     NVL(ap_web_db_expline_pkg.
                              getcountyprovince(
                                  per_addr.style,
                                  per_addr.region_1),
                        ''),
            ''),

          -- employee office county
          'OFFICE',
          DECODE(
            per_loc.style,
            'US',      NVL(per_loc.region_1,   ''),
            'US_GLB',  NVL(per_loc.region_1,   ''),
            'IE',      NVL(ap_web_db_expline_pkg.
                               getcountyprovince(
                                   per_loc.style,
                                   per_loc.region_1),
                         ''),
            'IE_GLB',  NVL(ap_web_db_expline_pkg.
                               getcountyprovince(
                                   per_loc.style,
                                   per_loc.region_1),
                         ''),
            'GB',      NVL(ap_web_db_expline_pkg.
                               getcountyprovince(
                                   per_loc.style,
                                   per_loc.region_1),
                         ''),
            ''),


            --address code not specified
            decode(per_addr.address_id,
            NULL,DECODE(
            per_loc.style,
            'US',      NVL(per_loc.region_1,   ''),
            'US_GLB',  NVL(per_loc.region_1,   ''),
            'IE',      NVL(ap_web_db_expline_pkg.
                               getcountyprovince(
                                   per_loc.style,
                                   per_loc.region_1),
                         ''),
            'IE_GLB',  NVL(ap_web_db_expline_pkg.
                               getcountyprovince(
                                   per_loc.style,
                                   per_loc.region_1),
                         ''),
            'GB',      NVL(ap_web_db_expline_pkg.
                               getcountyprovince(
                                   per_loc.style,
                                   per_loc.region_1),
                         ''),
            ''),
             DECODE(
            per_addr.style,
            'US',     NVL(per_addr.region_1,   ''),
            'US_GLB', NVL(per_addr.region_1,   ''),
            'IE',     NVL(ap_web_db_expline_pkg.
                              getcountyprovince(
                                  per_addr.style,
                                  per_addr.region_1),
                        ''),
            'IE_GLB', NVL(ap_web_db_expline_pkg.
                              getcountyprovince(
                                  per_addr.style,
                                  per_addr.region_1),
                        ''),
            'GB',     NVL(ap_web_db_expline_pkg.
                              getcountyprovince(
                                  per_addr.style,
                                  per_addr.region_1),
                        ''),
            ''))
            )
          )
        ) county,

      /* payee province */
      DECODE(
        doc.address_source,

        -- supplier province
        'TCA', payee_loc.province,

        -- employee province
        (
        DECODE(

          doc.employee_address_code,

          -- employee home province
          'HOME',
          DECODE(per_addr.style,
            'US',      '',
            'US_GLB',  '',
            'IE',      '',
            'IE_GLB',  '',
            'GB',      '',
            'CA',      NVL(per_addr.region_1,   ''),
            'CA_GLB',  NVL(per_addr.region_1,   ''),
            'JP',      NVL(per_addr.region_1,   ''),
            NVL(ap_web_db_expline_pkg.
                    getcountyprovince(
                        per_addr.style,
                        per_addr.region_1),
              '')
            ),

          -- employee office province
          'OFFICE',
          DECODE(per_loc.style,
            'US',      '',
            'US_GLB',  '',
            'IE',      '',
            'IE_GLB',  '',
            'GB',      '',
            'CA',      NVL(per_loc.region_1,   ''),
            'CA_GLB',  NVL(per_loc.region_1,   ''),
            'JP',      NVL(per_loc.region_1,   ''),
            NVL(ap_web_db_expline_pkg.
                    getcountyprovince(
                        per_loc.style,
                        per_loc.region_1),
              '')
              ),

            --address code not specified
            decode(per_addr.address_id,
            NULL,DECODE(per_loc.style,
            'US',      '',
            'US_GLB',  '',
            'IE',      '',
            'IE_GLB',  '',
            'GB',      '',
            'CA',      NVL(per_loc.region_1,   ''),
            'CA_GLB',  NVL(per_loc.region_1,   ''),
            'JP',      NVL(per_loc.region_1,   ''),
            NVL(ap_web_db_expline_pkg.
                    getcountyprovince(
                        per_loc.style,
                        per_loc.region_1),
              '')
              ),
             DECODE(per_addr.style,
            'US',      '',
            'US_GLB',  '',
            'IE',      '',
            'IE_GLB',  '',
            'GB',      '',
            'CA',      NVL(per_addr.region_1,   ''),
            'CA_GLB',  NVL(per_addr.region_1,   ''),
            'JP',      NVL(per_addr.region_1,   ''),
            NVL(ap_web_db_expline_pkg.
                    getcountyprovince(
                        per_addr.style,
                        per_addr.region_1),
              '')
            ))
            )
          )
        ) province,

      /* payee state */
      DECODE(
        doc.address_source,

        -- supplier state
        'TCA', payee_loc.state,

         -- employee state
         (
         DECODE(
           doc.employee_address_code,

           -- employee home state
           'HOME',
           DECODE(per_addr.style,
             'CA',     '',
             'CA_GLB', '',
             NVL(per_addr.region_2,   '')),

           -- employee office state
           'OFFICE',
           DECODE(per_loc.style,
             'CA',     '',
             'CA_GLB', '',
             NVL(per_loc.region_2, '')),

           --address code not specified
           decode(per_addr.address_id,
           NULL,DECODE(per_loc.style,
             'CA',     '',
             'CA_GLB', '',
              NVL(per_loc.region_2, '')),
            DECODE(per_addr.style,
             'CA',     '',
             'CA_GLB', '',
              NVL(per_addr.region_2,   '')))
           )
         )
       ) state,

     /* payee country */
      DECODE(
        doc.address_source,

        -- supplier country
        'TCA', payee_loc.country,

        -- employee country
        (
        DECODE(
          doc.employee_address_code,

          -- employee home country
          'HOME', per_addr.country,

          -- employee office country
          'OFFICE',per_loc.country,

          --address code not specified
          DECODE (per_addr.address_id,
               NULL, per_loc.country,
               per_addr.country
               )
          )
        )
        ) country,

      /* payee postal code */
      DECODE(
        doc.address_source,

        -- supplier postal code
        'TCA', payee_loc.postal_code,

        -- employee postal code
        (
        DECODE(
          doc.employee_address_code,

          -- employee home postal code
          'HOME', per_addr.postal_code,

          -- employee office postal code
          'OFFICE',per_loc.postal_code,

          --address code not specified
          DECODE (per_addr.address_id,
               NULL, per_loc.postal_code,
               per_addr.postal_code
               )
          )
        )
        ) postal_code,


      /* payee address concat */
      DECODE(
        doc.address_source,

        -- supplier address concat
        'TCA',
        payee_loc.address1
          || ', '
          || payee_loc.address2
          || ', '
          || payee_loc.address3
          || ', '
          || payee_loc.city
          || ', '
          || payee_loc.state
          || ', '
          || payee_loc.country
          || ', '
          || payee_loc.postal_code,

        -- employee address concat
        (
        DECODE(
          doc.employee_address_code,

          -- employee home address concat
          'HOME',
          per_addr.address_line1
            || ', '
            || per_addr.address_line2
            || ', '
            || per_addr.address_line3
            || ', '
            || per_addr.town_or_city
            || ', '
            || DECODE(
                 per_addr.style,
                 'CA',     '',
                 'CA_GLB', '',
                 NVL(per_addr.region_2, '')
                 )
            || ', '
            || per_addr.country
            || ', '
            || per_addr.postal_code,

          -- employee office address concat
          'OFFICE',
          per_loc.address_line_1
            || ', '
            || per_loc.address_line_2
            || ', '
            || per_loc.address_line_3
            || ', '
            || per_loc.town_or_city
            || ', '
            || DECODE(
                 per_loc.style,
                 'CA',     '',
                 'CA_GLB', '',
                 NVL(per_loc.region_2, '')
                 )
            || ', '
            || per_loc.country
            || ', '
            || per_loc.postal_code,

          -- address code not specified
          DECODE (per_addr.address_id,
               NULL, per_loc.address_line_1
            || ', '
            || per_loc.address_line_2
            || ', '
            || per_loc.address_line_3
            || ', '
            || per_loc.town_or_city
            || ', '
            || DECODE(
                 per_loc.style,
                 'CA',     '',
                 'CA_GLB', '',
                 NVL(per_loc.region_2, '')
                 )
            || ', '
            || per_loc.country
            || ', '
            || per_loc.postal_code,

              per_addr.address_line1
            || ', '
            || per_addr.address_line2
            || ', '
            || per_addr.address_line3
            || ', '
            || per_addr.town_or_city
            || ', '
            || DECODE(
                 per_addr.style,
                 'CA',     '',
                 'CA_GLB', '',
                 NVL(per_addr.region_2, '')
                 )
            || ', '
            || per_addr.country
            || ', '
            || per_addr.postal_code)
          )
        )
      ) add_concat

  FROM
      IBY_DOCS_PAYABLE_ALL     doc,

      /* Employee address related */
      HR_LOCATIONS             per_loc,
      PER_ADDRESSES            per_addr,
      PER_ALL_ASSIGNMENTS_F    per_assgn,

      /* Supplier address related */
      HZ_LOCATIONS             payee_loc
  WHERE
    doc.document_payable_id            = p_doc_id
    AND doc.employee_person_id         = per_addr.person_id(+)
    AND per_addr.primary_flag(+) = 'Y'
    AND SYSDATE BETWEEN
            per_addr.date_from(+)
            AND NVL(per_addr.date_to(+), SYSDATE+1)
    AND doc.employee_person_id         = per_assgn.person_id(+)
    AND per_assgn.location_id          = per_loc.location_id(+)
    AND per_assgn.primary_flag(+)      = 'Y'
    AND per_assgn.assignment_type(+) = 'E'
    AND (TRUNC(SYSDATE) BETWEEN
            per_assgn.effective_start_date(+)
            AND per_assgn.effective_end_date(+)
        )
    AND doc.remit_to_location_id       = payee_loc.location_id(+)

     ) payee_addr

 WHERE
     docs.document_payable_id           = p_doc_id
     AND docs.legal_entity_id           = payer.party_legal_id
     AND docs.payee_party_id            = payee.party_id
     AND docs.party_site_id             = payeesite.party_site_id (+)
     AND docs.internal_bank_account_id  = iba.bank_account_id
     AND iba_bnk_branch.branch_party_id = iba.bank_branch_id
     AND docs.external_bank_account_id  = eba.ext_bank_account_id(+)
     AND eba.bank_party_id              = eba_bank_branch.bank_party_id(+)
     AND eba.branch_party_id            = eba_bank_branch.branch_party_id(+)
     AND docs.delivery_channel_code     = del_chn.delivery_channel_code(+)
     ;

 /*
  * The cursor for online validation (i.e, immediate validation)
  * is similar to the cursor for deferred validation.
  * However, only document id is guaranteed to be available.
  * Other fields like payer id, payee id, internal bank account id,
  * external bank acount id etc. may or may not be provided.
  * Therefore, perform an outer join with all entities other than
  * the IBY_DOCS_PAYABLE_GT.
  */
 CURSOR c_onlineDocumentInfo(p_doc_id
             IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE)
 RETURN documentRecType
 IS
 SELECT
     docs.calling_app_id                 calling_app_id,
     docs.calling_app_doc_unique_ref1    calling_app_doc_id1,
     docs.calling_app_doc_unique_ref2    calling_app_doc_id2,
     docs.calling_app_doc_unique_ref3    calling_app_doc_id3,
     docs.calling_app_doc_unique_ref4    calling_app_doc_id4,
     docs.calling_app_doc_unique_ref5    calling_app_doc_id5,
     docs.pay_proc_trxn_type_code        pay_proc_trxn_type_cd,
     docs.document_payable_id            document_id,
     docs.payment_amount                 document_amount,
     docs.payment_currency_code          document_pay_currency,
     docs.exclusive_payment_flag         exclusive_payment_flag,
     docs.delivery_channel_code          delivery_channel_code,
     del_chn.format_value                delivery_chn_format_val,
     docs.unique_remittance_identifier   unique_remit_id_code,
     docs.payment_reason_comments        payment_reason_comments,
     docs.settlement_priority            settlement_priority,
     docs.remittance_message1            remittance_message1,
     docs.remittance_message2            remittance_message2,
     docs.remittance_message3            remittance_message3,
     docs.uri_check_digit                uri_check_digit,
     docs.external_bank_account_id       external_bank_account_id,


     iba_bnk_branch.bank_number          int_bank_num,
     iba_bnk_branch.bank_name            int_bank_name,
     iba_bnk_branch.bank_name_alt        int_bank_name_alt,
     iba_bnk_branch.branch_number        int_bank_branch_num,
     iba_bnk_branch.bank_branch_name     int_bank_branch_name,
     iba_bnk_branch.bank_branch_name_alt int_bank_branch_name_alt,

     iba.bank_account_num                int_bank_acc_num,
     iba.bank_account_name               int_bank_acc_name,
     iba.bank_account_name_alt           int_bank_acc_name_alt,
     iba.bank_account_type               int_bank_acc_type,
     iba.iban_number                     int_bank_acc_iban,
     ''                                  int_bank_assigned_id1,
     ''                                  int_bank_assigned_id2,
     iba.eft_user_num                    int_eft_user_number,
     iba.check_digits                    int_bank_acc_chk_dgts,
     iba.eft_requester_identifier        int_eft_req_identifier,
     iba.short_account_name              int_bank_acc_short_name,
     iba.account_holder_name             int_bank_acc_holder_name,
     iba.account_holder_name_alt         int_bank_acc_holder_name_alt,

     payer.party_legal_name              payer_le_name,
     payer.party_address_country         payer_le_country,
     payer.party_phone                   payer_phone,
     payer.party_registration_number     payer_registration_number, --added by asarada (SEPA Credit Transfer 3.3)
     IBY_FD_EXTRACT_GEN_PVT.
            Get_FP_TaxRegistration
               (docs.legal_entity_id)    payer_tax_registration_number, -- added by asarada (SEPA Credit Transfer 3.3 Changes)

     eba.bank_number                     ext_bank_num,
     eba.bank_name                       ext_bank_name,
     ''                                  ext_bank_name_alt,
     eba.branch_number                   ext_bank_branch_num,
     eba.bank_branch_name                ext_bank_branch_name,
     eba_bank_branch.bank_branch_name_alt ext_bank_branch_name_alt,
     eba.country_code                    ext_bank_country,
     eba_bank_branch.address_line1       ext_bank_branch_addr1,
     nvl(eba_bank_branch.country,eba_bank_branch.bank_home_country)             ext_bank_branch_country,

     eba.bank_account_number             ext_bank_acc_num,
     eba.bank_account_name               ext_bank_acc_name,
     eba.alternate_account_name          ext_bank_acc_name_alt,
     eba.bank_account_type               ext_bank_acc_type,
     eba.iban_number                     ext_bank_acc_iban,
     eba.check_digits                    ext_bank_acc_chk_dgts,
     eba.short_acct_name                 ext_bank_acc_short_name,
     eba.primary_acct_owner_name         ext_bank_acc_holder_name,
     ''                                  ext_bank_acc_holder_name_alt,
     eba.eft_swift_code    ext_eft_swift_code,   -- The documentRecType in the ibyvalls.pls was modified
     payee.party_name                    payee_party_name,

     /*
      * Note regarding bugfix for bug 5997016:
      *
      * Normally, this cursor c_onlineDocumentInfo, and the cursor
      * above c_documentInfo are in sync. This means that both
      * cursors pick up the same data except that the
      * online document cursor picks up the document attributes
      * from IBY_DOCS_PAYABLE_GT whereas the offline
      * document validation cursor picks up the document
      * attributes from IBY_DOCS_PAYABLE_ALL table.
      *
      * In fix for bug 5997016, we made the offline doc validation
      * cursor pick up the address data dynamically from
      * HR or TCA tables depending on the address source column.
      *
      * In the online validation cursor, we will not propagate
      * the same logic. There are some reasons for this -
      *
      * 1. Some columns that are present in IBY_DOCS_PAYABLE_ALL
      *    table are not present in IBY_DOCS_PAYABLE_GT table.
      *    E.g., address_source is not available in the GT table.
      *    Therefore, to support the dynamic payee address
      *    functionality we would need to make a data model change.
      *
      * 2. The online validation API is meant to provide a
      *    a quick response to the user as the validation is
      *    called syncronously by the user. By adding complex
      *    joins, we will be adding a performance penalty to
      *    online validation.
      *
      * 3. The intent of online validations is to catch basic
      *    errors in the document. The payee address validation
      *    on the document is a corner case, and it is not
      *    necessary to do this as part of online validation.
      *
      * The offline validation / batch validation will catch
      * these errors. The online validation is meant to be
      * simple and quick that targets the basic errors on the
      * document.
      *
      * We will continue to pick up the payee address from
      * HZ_LOCATIONS. In the case of employee type payees
      * the payee address fields will be null. This is
      * fine. The offline validation will catch these
      * errors anyway.
      */
     payee_loc.address1                  payee_party_addr1,
     payee_loc.address2                  payee_party_addr2,
     payee_loc.address3                  payee_party_addr3,
     payee_loc.city                      payee_party_city,
     payee_loc.state                     payee_party_state,
     payee_loc.province                  payee_party_province,
     payee_loc.county                    payee_party_county,
     payee_loc.postal_code               payee_party_postal,
     payee_loc.country                   payee_party_country,

     docs.bank_charge_bearer             bank_charge_bearer,
     docs.payment_reason_code            payment_reason_code,
     docs.payment_method_code            payment_method_cd,
     docs.payment_format_code            payee_payment_format_cd,
     payeesite.party_site_name           payee_party_site_name

 FROM
     IBY_DOCS_PAYABLE_GT         docs,
     IBY_PP_FIRST_PARTY_V        payer,
     HZ_PARTIES                  payee,
     HZ_PARTY_SITES              payeesite,
     HZ_LOCATIONS                payee_loc,
     CE_BANK_ACCOUNTS            iba,
     CE_BANK_BRANCHES_V          iba_bnk_branch,
     IBY_EXT_BANK_ACCOUNTS_INT_V eba,
     CE_BANK_BRANCHES_V          eba_bank_branch,
     IBY_DELIVERY_CHANNELS_B     del_chn
 WHERE
     docs.document_payable_id           = p_doc_id
     AND docs.legal_entity_id           = payer.party_legal_id
     AND docs.payee_party_id            = payee.party_id
     AND docs.payee_party_id            = payee_party_site_id
     AND docs.remit_to_location_id      = payee_loc.location_id(+)
     AND docs.internal_bank_account_id  = iba.bank_account_id (+)
     AND iba_bnk_branch.branch_party_id (+) = iba.bank_branch_id
     AND docs.external_bank_account_id  = eba.ext_bank_account_id(+)
     AND eba.bank_party_id              = eba_bank_branch.bank_party_id(+)
     AND eba.branch_party_id            = eba_bank_branch.branch_party_id(+)
     AND docs.delivery_channel_code     = del_chn.delivery_channel_code(+)
     ;

    -- bug 5230187 - Added outer joins to iba and iba_bnk_branch in cursor c_onlineDocumentInfo
 /*
  * If the c_documentInfo cursor returns no rows, then
  * use this cursor to pick up the identifying fields
  * of the document. This document will surely fail
  * validation, and we need to provide the identifying fields
  * to the validation sets.
  */
 CURSOR c_basicDocumentInfo (p_doc_id
             IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE)
 RETURN basicDocRecType
 IS
 SELECT
     docs.calling_app_id                 calling_app_id,
     docs.calling_app_doc_unique_ref1    calling_app_doc_id1,
     docs.calling_app_doc_unique_ref2    calling_app_doc_id2,
     docs.calling_app_doc_unique_ref3    calling_app_doc_id3,
     docs.calling_app_doc_unique_ref4    calling_app_doc_id4,
     docs.calling_app_doc_unique_ref5    calling_app_doc_id5,
     docs.pay_proc_trxn_type_code        pay_proc_trxn_type_cd,
     docs.document_payable_id            document_id
 FROM
     IBY_DOCS_PAYABLE_ALL  docs
 WHERE
     docs.document_payable_id          = p_doc_id
 ;

 /*
  * If the c_onlineDocumentInfo cursor returns no rows, then
  * use this cursor to pick up the identifying fields
  * of the document. This document will surely fail
  * validation, and we need to provide the identifying fields
  * to the validation sets.
  */
 CURSOR c_basicOnlineDocumentInfo (p_doc_id
             IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE)
 RETURN basicDocRecType
 IS
 SELECT
     docs.calling_app_id                 calling_app_id,
     docs.calling_app_doc_unique_ref1    calling_app_doc_id1,
     docs.calling_app_doc_unique_ref2    calling_app_doc_id2,
     docs.calling_app_doc_unique_ref3    calling_app_doc_id3,
     docs.calling_app_doc_unique_ref4    calling_app_doc_id4,
     docs.calling_app_doc_unique_ref5    calling_app_doc_id5,
     docs.pay_proc_trxn_type_code        pay_proc_trxn_type_cd,
     docs.document_payable_id            document_id
 FROM
     IBY_DOCS_PAYABLE_GT  docs
 WHERE
     docs.document_payable_id          = p_doc_id
 ;

 l_no_rows_flag   BOOLEAN := FALSE;
 basic_doc_rec    basicDocRecType;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');
	     print_debuginfo(l_module_name, 'Picking up document data for: '
	         || p_document_id);
	     print_debuginfo(l_module_name, 'p_isOnline: '
	         || p_isOnline);

     END IF;
     /*
      * If the caller wants to perform an online validation
      * pick up the fields of the given document only.
      *
      * Otherwise, pick up the fields from the document, payer,
      * payer bank, payee and payee bank as well.
      */
     IF (UPPER(p_isOnline) = 'Y') THEN

         OPEN  c_onlineDocumentInfo(p_document_id);
         FETCH c_onlineDocumentInfo INTO x_document_rec;
         CLOSE c_onlineDocumentInfo;

         /*
          * If the fetched doc id is null, it implies
          * no rows were found by the cursor.
          */
         IF (x_document_rec.document_id IS NULL) THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'No rows for online doc');
             END IF;
             l_no_rows_flag := TRUE;
         ELSE
             l_no_rows_flag := FALSE;
         END IF;

     ELSE

         OPEN  c_documentInfo(p_document_id);
         FETCH c_documentInfo INTO x_document_rec;
         CLOSE c_documentInfo;

         /*
          * If the fetched doc id is null, it implies
          * no rows were found by the cursor.
          */
         IF (x_document_rec.document_id IS NULL) THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'No rows for offline doc');
             END IF;
             l_no_rows_flag := TRUE;
         ELSE
             l_no_rows_flag := FALSE;
         END IF;

     END IF;

     /*
      * We try to get all the document fields required for validation
      * by joining with the payee/payer/int bank and ext bank
      * tables. If this join fails for some reason, then no
      * doc fields will be fetched. This will lead to an empty
      * document being returned which causes the program to abort.
      *
      * In such a case, pick up only the document fields from
      * IBY_DOCS_PAYABLE_ALL and pass it back. This document
      * will surely fail validation because of the missing fields.
      * Since we passed back the basic doc fields, this document
      * can be failed in a graceful manner.
      */
     IF (l_no_rows_flag = TRUE) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Unable to find related fields '
	          || 'for document '
	          || p_document_id
	          || '. Only basic document fields will be returned.'
	          );

         END IF;
         IF (UPPER(p_isOnline) = 'Y') THEN

             OPEN  c_basicOnlineDocumentInfo(p_document_id);
             FETCH c_basicOnlineDocumentInfo INTO basic_doc_rec;
             CLOSE c_basicOnlineDocumentInfo;

         ELSE

             OPEN  c_basicDocumentInfo(p_document_id);
             FETCH c_basicDocumentInfo INTO basic_doc_rec;
             CLOSE c_basicDocumentInfo;

         END IF;

         /*
          * Copy the basic fields of the doc back into the
          * out param record which will be passed to the
          * validation sets
          */
         x_document_rec.calling_app_id := basic_doc_rec.calling_app_id;

         x_document_rec.calling_app_doc_id1 :=
             basic_doc_rec.calling_app_doc_id1;
         x_document_rec.calling_app_doc_id2 :=
             basic_doc_rec.calling_app_doc_id2;
         x_document_rec.calling_app_doc_id3 :=
             basic_doc_rec.calling_app_doc_id3;
         x_document_rec.calling_app_doc_id4 :=
             basic_doc_rec.calling_app_doc_id4;
         x_document_rec.calling_app_doc_id5 :=
             basic_doc_rec.calling_app_doc_id5;

         x_document_rec.pay_proc_trxn_type_cd :=
             basic_doc_rec.pay_proc_trxn_type_cd;
         x_document_rec.document_id := basic_doc_rec.document_id;

     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
     EXCEPTION
         WHEN OTHERS THEN
             FND_MESSAGE.SET_NAME('IBY', '');
             FND_MESSAGE.SET_TOKEN('SQLERR','initDocumentData : '||
                 substr(SQLERRM, 1, 300));
             FND_MSG_PUB.Add;
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name,'            '||
	                 substr(SQLERRM, 1, 300), FND_LOG.LEVEL_UNEXPECTED);
             END IF;
             RAISE g_abort_program;


 END initDocumentData;

/*--------------------------------------------------------------------
 | NAME:
 |     initCharValData
 |
 | PURPOSE:
 |     Initializes the character validation record with data from
 |     Oracle Payment's tables.
 |
 |     Character validation checks if any invalid characters are
 |     present in the document. So mostly VARCHAR fields are picked
 |     up (it is not necessary to validate numeric fields for invalid
 |     characters).
 |
 |     Usually document lines are not sent to the bank, so these are
 |     not picked up for validation.
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
 PROCEDURE initCharValData(
     p_document_id  IN IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE,
     x_charval_rec  IN OUT NOCOPY charValRecType
     )
 IS

 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME || '.initCharValData';

 CURSOR c_charval_fields (p_doc_id IBY_DOCS_PAYABLE_ALL.
                              document_payable_id%TYPE)
 IS
 SELECT

  /* DOCUMENT RELATED */
  doc.document_payable_id,
  doc.calling_app_id,
  doc.calling_app_doc_unique_ref1,
  doc.calling_app_doc_unique_ref2,
  doc.calling_app_doc_unique_ref3,
  doc.calling_app_doc_unique_ref4,
  doc.calling_app_doc_unique_ref5,
  doc.pay_proc_trxn_type_code,
  doc.calling_app_doc_ref_number,
  doc.unique_remittance_identifier,
  doc.uri_check_digit,
  doc.po_number,
  doc.document_description,
  doc.bank_assigned_ref_code,
  doc.payment_reason_comments,
  doc.remittance_message1,
  doc.remittance_message2,
  doc.remittance_message3,
  dlv.format_value,
  pmt_reason.format_value,
  lines.calling_app_document_line_code,
  lines.line_type,
  lines.line_name,
  lines.description,
  lines.unit_of_measure,
  lines.po_number,

  /* PAYER */
  payer.party_number,                  -- payer number
  payer.party_name,                    -- payer name
  payer.party_legal_name,              -- payer legal name
  payer.party_tax_id,                  -- payer tax id
  payer.party_address_line1,           -- payer add line 1
  payer.party_address_line2,           -- payer add line 2,
  payer.party_address_line3,           -- payer add line 3
  payer.party_address_city,            -- payer city
  payer.party_address_county ,         -- payer county
  payer.party_address_state,           -- payer state
  payer.party_address_country,         -- payer country
  payer.party_address_postal_code,     -- payer postal code

  /* PAYER BANK */
  iba_bnk_branch.bank_name,            -- payer bank name
  iba_bnk_branch.bank_number,          -- payer bank number
  iba_bnk_branch.branch_number,        -- payer bank branch number
  iba_bnk_branch.bank_branch_name,     -- payer bank branch name
  iba_bnk_branch.eft_swift_code,       -- payer bank swift code
  iba_bnk_branch.address_line1,        -- payer bank add line 1
  iba_bnk_branch.address_line2,        -- payer bank add line 2
  iba_bnk_branch.address_line3,        -- payer bank add line 3
  iba_bnk_branch.city,                 -- payer bank city
  iba_bnk_branch.province,             -- payer bank county
  iba_bnk_branch.state,                -- payer bank state
  nvl(iba_bnk_branch.country,iba_bnk_branch.bank_home_country),              -- payer bank country
  iba_bnk_branch.zip,                  -- payer bank postal code
  iba_bnk_branch.bank_name_alt,        -- payer bank name alt
  iba_bnk_branch.bank_branch_name_alt, -- payer bank branch name alt

  iba.bank_account_name_alt,           -- payer bank acct name alt
  iba.bank_account_type,               -- payer bank acct type
  '',                                  -- payer bank assigned id1
  '',                                  -- payer bank assigned id2
  iba.eft_user_num,                    -- payer eft user number
  iba.eft_requester_identifier,        -- payer eft req identifier
  iba.short_account_name,              -- payer bank acct short name
  iba.account_holder_name_alt,         -- payer bank acct holder name alt
  iba.account_holder_name,             -- payer bank account holder name
  iba.bank_account_num,                -- payer bank account num
  iba.bank_account_name,               -- payer bank account name
  iba.iban_number,                     -- payer bank acct iban number
  iba.check_digits,                    -- payer bank acct check digits

  /* PAYEE */
  payee.party_number,                  -- payee number
  payee.party_name,                    -- payee name
  payee.tax_reference,                 -- payee tax number
  payee_loc.address1,                  -- payee add line1
  payee_loc.address2,                  -- payee add line2
  payee_loc.address3,                  -- payee add line3
  payee_loc.city,                      -- payee city
  payee_loc.county,                    -- payee county
  payee_loc.province,                  -- payee province
  payee_loc.state,                     -- payee state
  payee_loc.country,                   -- payee country
  payee_loc.postal_code,               -- payee postal code

  /* PAYEE BANK */
  eba.bank_name,                       -- payee bank name
  eba.bank_number,                     -- payee bank number
  eba.branch_number,                   -- payee bank branch number
  eba.bank_branch_name,                -- payee bank branch name
  eba.primary_acct_owner_name,         -- payee bank account holder name
  eba.bank_account_number,             -- payee bank account number
  eba.bank_account_name,               -- payee bank account name
  eba.iban_number,                     -- payee bank account IBAN
  eba.eft_swift_code,                  -- payee bank swift code
  eba.check_digits,                    -- payee bank account check digits
  '',                                  -- payee bank add line 1
  '',                                  -- payee bank add line 2
  '',                                  -- payee bank add line 3
  '',                                  -- payee bank city
  '',                                  -- payee bank county
  '',                                  -- payee bank state
  '',                                  -- payee bank country
  '',                                  -- payee bank postal code
  '',                                  -- payee bank name alternate
  '',                                  -- payee bank branch name alternate
  eba.country_code,                    -- payee bank country code
  eba.alternate_account_name,          -- payee bank account name alternate
  eba.bank_account_type,               -- payee bank account type
  eba.short_acct_name,                 -- payee bank account short name
  ''                                   -- payee bank acct holder name alt
 FROM
  /* Document related */
  IBY_DOCS_PAYABLE_ALL     doc,
  IBY_PAYMENT_REASONS_VL   pmt_reason,
  IBY_DELIVERY_CHANNELS_VL dlv,
  IBY_DOCUMENT_LINES       lines,
  /* Payer */
  IBY_PP_FIRST_PARTY_V     payer,
  /* Payer bank */
  CE_BANK_ACCOUNTS         iba,
  CE_BANK_BRANCHES_V       iba_bnk_branch,
  /* Payee */
  HZ_PARTIES               payee,
  HZ_LOCATIONS             payee_loc,
  /* Payee bank */
  IBY_EXT_BANK_ACCOUNTS_V  eba
 WHERE
  /* document related */
  doc.document_payable_id            = p_doc_id
  AND doc.payment_reason_code        = pmt_reason.payment_reason_code(+)
  AND doc.delivery_channel_code      = dlv.delivery_channel_code(+)
  AND doc.document_payable_id        = lines.document_payable_id(+)
  /* payer */
  AND doc.legal_entity_id            = payer.party_legal_id
  /* payer bank */
  AND doc.internal_bank_account_id   = iba.bank_account_id
  AND iba_bnk_branch.branch_party_id = iba.bank_branch_id
  /* payee */
  AND doc.payee_party_id             = payee.party_id
  AND doc.remit_to_location_id       = payee_loc.location_id(+)
  /* payee bank */
  AND doc.external_bank_account_id   = eba.ext_bank_account_id(+)
  ;

 BEGIN

     --
     -- Fetching fields from character validation cursor
     --
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Picking up character '
	         || 'validation fields for: '
	         || p_document_id);

     END IF;
     OPEN  c_charval_fields(p_document_id);
     FETCH c_charval_fields INTO x_charval_rec;
     CLOSE c_charval_fields;

     EXCEPTION
         WHEN OTHERS THEN
             FND_MESSAGE.SET_NAME('IBY', '');
             FND_MESSAGE.SET_TOKEN('SQLERR','initCharValData: '
                 || substr(SQLERRM, 1, 300));
             FND_MSG_PUB.Add;
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name,'        '
	                 || substr(SQLERRM, 1, 300), FND_LOG.LEVEL_UNEXPECTED);
             END IF;
             RAISE g_abort_program;

 END initCharValData;

/*--------------------------------------------------------------------
 | NAME:
 |     initPaymentData
 |
 | PURPOSE:
 |     Initializes the payment record from Oracle Payment's tables.
 |
 |     Fields of the payment are picked up and populated into a
 |     payment record. The validation sets will validate the
 |     various payment fields.
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
 PROCEDURE initPaymentData(
     p_payment_id  IN IBY_PAYMENTS_ALL.payment_id%type,
     x_payment_rec IN OUT NOCOPY paymentRecType
     )
 IS

 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME || '.initPaymentData';

 /*
  * Pick up all the Payment fields which need to be validated.
  * Note: If any field is modified in the query below, the same
  * field in 'paymentRecType' record in the spec should be
  * modified accordingly.
  */
 CURSOR c_payment_rec (p_pay_id IBY_PAYMENTS_ALL.payment_id%TYPE)
     RETURN paymentRecType IS
 SELECT
     pay.payment_id                 pmt_id,
     pay.payment_amount             pmt_amount,
     pay.payment_currency_code      pmt_currency,
     pay.delivery_channel_code      pmt_delivery_channel_code,
     payer.party_address_country    pmt_payer_le_country,
     pay.payment_details            pmt_detail,
     0                              pmt_payment_reason_count,
     pay.int_bank_account_iban  int_bank_account_iban,
     pay.payer_tax_registration_num payer_tax_registration_num,
     pay.payer_le_registration_num payer_le_registration_num,
     payer.party_address_line1,
     payer.party_address_city,
     payer.party_address_postal_code,
     payer_bank_acc.currency_code

 FROM
     IBY_PAYMENTS_ALL     pay,
     IBY_PP_FIRST_PARTY_V payer,
     CE_BANK_ACCOUNTS     payer_bank_acc
 WHERE
     pay.payment_id = p_pay_id
 AND
     pay.legal_entity_id = payer.party_legal_id
 AND
     pay.internal_bank_account_id = payer_bank_acc.bank_account_id;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Picking up payment data for: '
	         || p_payment_id);

     END IF;
     /*
      * Fetch the payment related fields
      */
     OPEN c_payment_rec(p_payment_id);
     FETCH c_payment_rec INTO x_payment_rec;

     -- Get payment_reason_count (for Belgium)
     SELECT count(distinct payment_reason_code)
       INTO x_payment_rec.pmt_payment_reason_count
       FROM iby_docs_payable_all
      WHERE payment_id = p_payment_id;

     CLOSE c_payment_rec;

     EXCEPTION
         WHEN OTHERS THEN
             FND_MESSAGE.SET_NAME('IBY', '');
             FND_MESSAGE.SET_TOKEN('SQLERR','initPaymentData : '||
                 substr(SQLERRM, 1, 300));
             FND_MSG_PUB.Add;
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name,'            '||
	                 substr(SQLERRM, 1, 300), FND_LOG.LEVEL_UNEXPECTED);
             END IF;
             RAISE g_abort_program;

 END initPaymentData;

/*--------------------------------------------------------------------
 | NAME:
 |     initInstructionData
 |
 | PURPOSE:
 |     Initializes the instruction record from Oracle Payment's tables.
 |
 |     Fields related to a payment instruction are picked up and
 |     populated into an instruction record. The validation sets will
 |     validate individual fields of this record.
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
 PROCEDURE initInstructionData (
      p_instruction_id  IN IBY_PAY_INSTRUCTIONS_ALL.
                               payment_instruction_id%type,
      x_instruction_rec IN OUT NOCOPY instructionRecType
      )
 IS

 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME || '.initInstructionData';

 /*
  * Picking up all the instruction fields which need to be validated.
  * Note: If any field is to be modified in the query below, the same
  * field in 'instructionRecType' in the spec should be changed accordingly.
  */
 CURSOR c_instruction_rec (p_instr_id IBY_PAY_INSTRUCTIONS_ALL.
                                          payment_instruction_id%type)
 RETURN instructionRecType
 IS
 SELECT
     instr.payment_instruction_id   ins_id,
     0                              ins_amount,
     0                              ins_document_count
 FROM
     IBY_PAY_INSTRUCTIONS_ALL instr
 WHERE
     instr.payment_instruction_id = p_instr_id;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Picking up instruction data for: '
	         || p_instruction_id);

     END IF;
     /*
      * Fetching fields from Payment cursor
      */
     OPEN c_instruction_rec(p_instruction_id);
     FETCH c_instruction_rec INTO x_instruction_rec;

     -- Get instruction_amount and document_count
     select sum(d.document_amount),
     	    count(d.document_payable_id)
       into x_instruction_rec.ins_amount,
            x_instruction_rec.ins_document_count
       from iby_docs_payable_all d, iby_payments_all p
      where p.payment_instruction_id = p_instruction_id
        and p.payment_id = d.payment_id

        /*
         * Fix for bug 5672789:
         *
         * When calculating payment count for an instruction,
         * only pick up payments that are in
         * 'INSTRUCTION_CREATED' status.
         */
        and p.payment_status IN (PAY_STATUS_INS_CRTD)
        ;

     CLOSE c_instruction_rec;

     EXCEPTION
         WHEN OTHERS THEN
             FND_MESSAGE.SET_NAME('IBY', '');
             FND_MESSAGE.SET_TOKEN('SQLERR','initInstructionData : '||
                 substr(SQLERRM, 1, 300));
             FND_MSG_PUB.Add;
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name,'            '||
	                 substr(SQLERRM, 1, 300), FND_LOG.LEVEL_UNEXPECTED);
             END IF;
             RAISE g_abort_program;

 END initInstructionData;

/*--------------------------------------------------------------------
 | NAME:
 |     insert_transaction_errors
 |
 | PURPOSE:
 |     Inserts the error messages into the errors table. For
 |     online validations, the error messages are inserted into
 |     IBY_TRANSACTION_ERRORS_GT; for deferred validations, the
 |     error messages are inserted into IBY_TRANSACTION_ERRORS
 |     table.
 |
 |     Validation sets populate the transaction errors into a PLSQL
 |     table. This method performs a bulk insert of the given records
 |     into the transaction errors table.
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
 PROCEDURE insert_transaction_errors(
     p_isOnlineVal     IN            VARCHAR2,
     x_docErrorTab     IN OUT NOCOPY docErrorTabType,
     x_trxnErrTokenTab IN OUT NOCOPY trxnErrTokenTabType
     )
 IS
 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME ||
                                             '.insert_transaction_errors';

 /*
  * Column types for insertion into IBY_TRANSACTION_ERRORS table.
  */
 TYPE t_transaction_error_id IS TABLE OF
     IBY_TRANSACTION_ERRORS.transaction_error_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_transaction_type IS TABLE OF
     IBY_TRANSACTION_ERRORS.transaction_type%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_transaction_id IS TABLE OF
     IBY_TRANSACTION_ERRORS.transaction_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_error_code IS TABLE OF
     IBY_TRANSACTION_ERRORS.error_code%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_error_date IS TABLE OF
     IBY_TRANSACTION_ERRORS.error_date%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_error_status IS TABLE OF
     IBY_TRANSACTION_ERRORS.error_status%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_calling_app_doc_unique_ref1 IS TABLE OF
     IBY_TRANSACTION_ERRORS.calling_app_doc_unique_ref1%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_ovrride_allowed_on_err_flg IS TABLE OF
     IBY_TRANSACTION_ERRORS.override_allowed_on_error_flag%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_do_not_apply_error_flag IS TABLE OF
     IBY_TRANSACTION_ERRORS.do_not_apply_error_flag%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_created_by IS TABLE OF
     IBY_TRANSACTION_ERRORS.created_by%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_creation_date IS TABLE OF
     IBY_TRANSACTION_ERRORS.creation_date%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_last_updated_by IS TABLE OF
     IBY_TRANSACTION_ERRORS.last_updated_by%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_last_update_date IS TABLE OF
     IBY_TRANSACTION_ERRORS.last_update_date%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_object_version_number IS TABLE OF
     IBY_TRANSACTION_ERRORS.object_version_number%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_last_update_login IS TABLE OF
     IBY_TRANSACTION_ERRORS.last_update_login%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_calling_app_id IS TABLE OF
     IBY_TRANSACTION_ERRORS.calling_app_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_pay_proc_trxn_type_code IS TABLE OF
     IBY_TRANSACTION_ERRORS.pay_proc_trxn_type_code%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_calling_app_doc_unique_ref2 IS TABLE OF
     IBY_TRANSACTION_ERRORS.calling_app_doc_unique_ref2%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_calling_app_doc_unique_ref3 IS TABLE OF
     IBY_TRANSACTION_ERRORS.calling_app_doc_unique_ref3%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_calling_app_doc_unique_ref4 IS TABLE OF
     IBY_TRANSACTION_ERRORS.calling_app_doc_unique_ref4%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_calling_app_doc_unique_ref5 IS TABLE OF
     IBY_TRANSACTION_ERRORS.calling_app_doc_unique_ref5%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_error_type IS TABLE OF
     IBY_TRANSACTION_ERRORS.error_type%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_error_message IS TABLE OF
     IBY_TRANSACTION_ERRORS.error_message%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_validation_set_code IS TABLE OF
     IBY_TRANSACTION_ERRORS.validation_set_code%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_pass_date IS TABLE OF
     IBY_TRANSACTION_ERRORS.pass_date%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_override_justification IS TABLE OF
     IBY_TRANSACTION_ERRORS.override_justification%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_override_date IS TABLE OF
     IBY_TRANSACTION_ERRORS.override_date%TYPE
     INDEX BY BINARY_INTEGER;

 l_transaction_error_id           t_transaction_error_id;
 l_transaction_type               t_transaction_type;
 l_transaction_id                 t_transaction_id;
 l_error_code                     t_error_code;
 l_error_date                     t_error_date;
 l_error_status                   t_error_status;
 l_calling_app_doc_unique_ref1    t_calling_app_doc_unique_ref1;
 l_ovrride_allowed_on_err_flg     t_ovrride_allowed_on_err_flg;
 l_do_not_apply_error_flag        t_do_not_apply_error_flag;
 l_created_by                     t_created_by;
 l_creation_date                  t_creation_date;
 l_last_updated_by                t_last_updated_by;
 l_last_update_date               t_last_update_date;
 l_object_version_number          t_object_version_number;
 l_last_update_login              t_last_update_login;
 l_calling_app_id                 t_calling_app_id;
 l_pay_proc_trxn_type_code        t_pay_proc_trxn_type_code;
 l_calling_app_doc_unique_ref2    t_calling_app_doc_unique_ref2;
 l_calling_app_doc_unique_ref3    t_calling_app_doc_unique_ref3;
 l_calling_app_doc_unique_ref4    t_calling_app_doc_unique_ref4;
 l_calling_app_doc_unique_ref5    t_calling_app_doc_unique_ref5;
 l_error_type                     t_error_type;
 l_error_message                  t_error_message;
 l_validation_set_code            t_validation_set_code;
 l_pass_date                      t_pass_date;
 l_override_justification         t_override_justification;
 l_override_date                  t_override_date;

 /*
  * Column types for insertion into IBY_TRXN_ERROR_TOKENS table.
  */
 TYPE t_trxn_error_id IS TABLE OF
     IBY_TRXN_ERROR_TOKENS.transaction_error_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_token_name IS TABLE OF
     IBY_TRXN_ERROR_TOKENS.token_name%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_crtd_by IS TABLE OF
     IBY_TRXN_ERROR_TOKENS.created_by%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_crt_date IS TABLE OF
     IBY_TRXN_ERROR_TOKENS.creation_date%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_last_updt_by IS TABLE OF
     IBY_TRXN_ERROR_TOKENS.last_updated_by%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_last_updt_date IS TABLE OF
     IBY_TRXN_ERROR_TOKENS.last_update_date%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_object_ver_number IS TABLE OF
     IBY_TRXN_ERROR_TOKENS.object_version_number%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_token_value IS TABLE OF
     IBY_TRXN_ERROR_TOKENS.token_value%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_lookup_type_source IS TABLE OF
     IBY_TRXN_ERROR_TOKENS.lookup_type_source%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_last_updt_login IS TABLE OF
     IBY_TRXN_ERROR_TOKENS.last_update_login%TYPE
     INDEX BY BINARY_INTEGER;

 l_trxn_error_id           t_trxn_error_id;
 l_token_name              t_token_name;
 l_crtd_by                 t_crtd_by;
 l_crt_date                t_crt_date;
 l_last_updtd_by           t_last_updt_by;
 l_last_updt_date          t_last_updt_date;
 l_object_ver_number       t_object_ver_number;
 l_token_value             t_token_value;
 l_lookup_type_source      t_lookup_type_source;
 l_last_updt_login         t_last_updt_login;


 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

	     print_debuginfo(l_module_name, 'Online flag: ' || p_isOnlineVal);

     END IF;
     IF (x_docErrorTab.COUNT > 0) THEN

             /*
              * Create an array of values for each column. These arrays
              * will be used in the bulk insert.
              */
             FOR i in x_docErrorTab.FIRST..x_docErrorTab.LAST LOOP

                 l_transaction_error_id(i)
                     := x_docErrorTab(i).transaction_error_id;
                 l_transaction_type(i)
                     := x_docErrorTab(i).transaction_type;
                 l_transaction_id(i)
                     := x_docErrorTab(i).transaction_id;
                 l_error_code(i)
                     := x_docErrorTab(i).error_code;
                 l_error_date(i)
                     := NVL(x_docErrorTab(i).error_date, sysdate);
                 l_error_status(i)
                     := NVL(x_docErrorTab(i).error_status, 'ACTIVE');
                 l_calling_app_doc_unique_ref1(i)
                     := x_docErrorTab(i).calling_app_doc_unique_ref1;

                 /*
                  * Fix for bug 5206309:
                  *
                  * For payment instructions, the override
                  * allowed flag needs to be defaulted to Y
                  * for the time being.
                  */
                 IF (x_docErrorTab(i).transaction_type =
                         'PAYMENT_INSTRUCTION') THEN

                     l_ovrride_allowed_on_err_flg(i)
                         := NVL(x_docErrorTab(i).
                                    override_allowed_on_error_flag,
                                'Y');

                 ELSE

                     l_ovrride_allowed_on_err_flg(i)
                         := NVL(x_docErrorTab(i).
                                    override_allowed_on_error_flag,
                                'N');

                 END IF;

                 l_do_not_apply_error_flag(i)
                     := NVL(x_docErrorTab(i).do_not_apply_error_flag, 'N');
                 l_created_by(i)
                     := NVL(x_docErrorTab(i).created_by, fnd_global.user_id);
                 l_creation_date(i)
                     := NVL(x_docErrorTab(i).creation_date, sysdate);
                 l_last_updated_by(i)
                     := NVL(x_docErrorTab(i).last_updated_by,
                            fnd_global.user_id);
                 l_last_update_date(i)
                     := NVL(x_docErrorTab(i).last_update_date, sysdate);
                 l_object_version_number(i)
                     := NVL(x_docErrorTab(i).object_version_number, 1);
                 l_last_update_login(i)
                     := NVL(x_docErrorTab(i).last_update_login,
                            fnd_global.user_id);
                 l_calling_app_id(i)
                     := x_docErrorTab(i).calling_app_id;
                 l_pay_proc_trxn_type_code(i)
                     := x_docErrorTab(i).pay_proc_trxn_type_code;
                 l_calling_app_doc_unique_ref2(i)
                     := x_docErrorTab(i).calling_app_doc_unique_ref2;
                 l_calling_app_doc_unique_ref3(i)
                     := x_docErrorTab(i).calling_app_doc_unique_ref3;
                 l_calling_app_doc_unique_ref4(i)
                     := x_docErrorTab(i).calling_app_doc_unique_ref4;
                 l_calling_app_doc_unique_ref5(i)
                     := x_docErrorTab(i).calling_app_doc_unique_ref5;
                 l_error_type(i)
                     := NVL(x_docErrorTab(i).error_type, 'VALIDATION');
                 l_error_message(i)
                     := x_docErrorTab(i).error_message;
                 l_validation_set_code(i)
                     := x_docErrorTab(i).validation_set_code;
                 l_pass_date(i)
                     := x_docErrorTab(i).pass_date;
                 l_override_justification(i)
                     := x_docErrorTab(i).override_justification;
                 l_override_date(i)
                     := x_docErrorTab(i).override_date;

             END LOOP;

             END IF;

     IF (UPPER(p_isOnlineVal) = 'N') THEN

         /*
          * Insert error messages into IBY_TRANSACTION_ERRORS table.
          */

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Bulk inserting errors into '
	                 || 'IBY_TRANSACTION_ERRORS.');

             END IF;
             --FORALL i in x_docErrorTab.FIRST..x_docErrorTab.LAST
             --   INSERT INTO IBY_TRANSACTION_ERRORS VALUES x_docErrorTab(i);


             /*
              * Use named columns in bulk insert syntax to avoid any
              * dependencies on the order of the columns in the table.
              */
             FORALL i in x_docErrorTab.FIRST..x_docErrorTab.LAST
                 INSERT INTO IBY_TRANSACTION_ERRORS
                      (
                      transaction_error_id,
                      transaction_type,
                      transaction_id,
                      error_code,
                      error_date,
                      error_status,
                      calling_app_doc_unique_ref1,
                      override_allowed_on_error_flag,
                      do_not_apply_error_flag,
                      created_by,
                      creation_date,
                      last_updated_by,
                      last_update_date,
                      object_version_number,
                      last_update_login,
                      calling_app_id,
                      pay_proc_trxn_type_code,
                      calling_app_doc_unique_ref2,
                      calling_app_doc_unique_ref3,
                      calling_app_doc_unique_ref4,
                      calling_app_doc_unique_ref5,
                      error_type,
                      error_message,
                      validation_set_code,
                      pass_date,
                      override_justification,
                      override_date
                      )
                  VALUES
                      (
                      l_transaction_error_id(i),
                      l_transaction_type(i),
                      l_transaction_id(i),
                      l_error_code(i),
                      l_error_date(i),
                      l_error_status(i),
                      l_calling_app_doc_unique_ref1(i),
                      l_ovrride_allowed_on_err_flg(i),
                      l_do_not_apply_error_flag(i),
                      l_created_by(i),
                      l_creation_date(i),
                      l_last_updated_by(i),
                      l_last_update_date(i),
                      l_object_version_number(i),
                      l_last_update_login(i),
                      l_calling_app_id(i),
                      l_pay_proc_trxn_type_code(i),
                      l_calling_app_doc_unique_ref2(i),
                      l_calling_app_doc_unique_ref3(i),
                      l_calling_app_doc_unique_ref4(i),
                      l_calling_app_doc_unique_ref5(i),
                      l_error_type(i),
                      l_error_message(i),
                      l_validation_set_code(i),
                      l_pass_date(i),
                      l_override_justification(i),
                      l_override_date(i)
                      )
                      ;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Finished populating '
	                 || 'IBY_TRANSACTION_ERRORS.');


             END IF;
     ELSE

         /*
          * Insert error messages into IBY_TRANSACTION_ERRORS_GT table.
          */

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Bulk Inserting errors into '
	                 || 'IBY_TRANSACTION_ERRORS_GT.');

             END IF;
             --FORALL i in x_docErrorTab.FIRST..x_docErrorTab.LAST
             --   INSERT INTO IBY_TRANSACTION_ERRORS_GT VALUES x_docErrorTab(i);

             /*
              * Use named columns in bulk insert syntax to avoid any
              * dependencies on the order of the columns in the table.
              */
             FORALL i in x_docErrorTab.FIRST..x_docErrorTab.LAST
                 INSERT INTO IBY_TRANSACTION_ERRORS_GT
                     (
                     transaction_error_id,
                     transaction_type,
                     transaction_id,
                     error_code,
                     error_date,
                     error_status,
                     calling_app_doc_unique_ref1,
                     override_allowed_on_error_flag,
                     do_not_apply_error_flag,
                     created_by,
                     creation_date,
                     last_updated_by,
                     last_update_date,
                     object_version_number,
                     last_update_login,
                     calling_app_id,
                     pay_proc_trxn_type_code,
                     calling_app_doc_unique_ref2,
                     calling_app_doc_unique_ref3,
                     calling_app_doc_unique_ref4,
                     calling_app_doc_unique_ref5,
                     error_type,
                     error_message,
                     validation_set_code,
                     pass_date,
                     override_justification,
                     override_date
                     )
                 VALUES
                     (
                     l_transaction_error_id(i),
                     l_transaction_type(i),
                     l_transaction_id(i),
                     l_error_code(i),
                     l_error_date(i),
                     l_error_status(i),
                     l_calling_app_doc_unique_ref1(i),
                     l_ovrride_allowed_on_err_flg(i),
                     l_do_not_apply_error_flag(i),
                     l_created_by(i),
                     l_creation_date(i),
                     l_last_updated_by(i),
                     l_last_update_date(i),
                     l_object_version_number(i),
                     l_last_update_login(i),
                     l_calling_app_id(i),
                     l_pay_proc_trxn_type_code(i),
                     l_calling_app_doc_unique_ref2(i),
                     l_calling_app_doc_unique_ref3(i),
                     l_calling_app_doc_unique_ref4(i),
                     l_calling_app_doc_unique_ref5(i),
                     l_error_type(i),
                     l_error_message(i),
                     l_validation_set_code(i),
                     l_pass_date(i),
                     l_override_justification(i),
                     l_override_date(i)
                     )
                     ;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Finished populating '
	                 || 'IBY_TRANSACTION_ERRORS_GT.');


             END IF;
     END IF; -- p_isOnlineVal = 'N'

     /*
      * For both online validations and deferred validations,
      * error tokens are always inserted into the IBY_TRXN_ERROR_TOKENS
      * table.
      */

     IF (x_trxnErrTokenTab.COUNT > 0) THEN

         /*
          * Create an array of values for each column. These arrays
          * will be used in the bulk insert.
          */
         FOR j in x_trxnErrTokenTab.FIRST..x_trxnErrTokenTab.LAST LOOP

             l_trxn_error_id(j)      := x_trxnErrTokenTab(j).
                                            transaction_error_id;
             l_token_name(j)         := x_trxnErrTokenTab(j).
                                            token_name;
             l_crtd_by(j)            := NVL(x_trxnErrTokenTab(j).
                                            created_by, fnd_global.user_id);
             l_crt_date(j)           := NVL(x_trxnErrTokenTab(j).
                                            creation_date, sysdate);
             l_last_updtd_by(j)      := NVL(x_trxnErrTokenTab(j).
                                            last_updated_by,
                                            fnd_global.user_id);
             l_last_updt_date(j)     := NVL(x_trxnErrTokenTab(j).
                                            last_update_date, sysdate);
             l_object_ver_number(j)  := NVL(x_trxnErrTokenTab(j).
                                            object_version_number, 1);
             l_token_value(j)        := x_trxnErrTokenTab(j).
                                            token_value;
             l_lookup_type_source(j) := x_trxnErrTokenTab(j).
                                            lookup_type_source;
             l_last_updt_login(j)    := NVL(x_trxnErrTokenTab(j).
                                            last_update_login,
                                            fnd_global.user_id);

         END LOOP;


         --FORALL j in x_trxnErrTokenTab.FIRST..x_trxnErrTokenTab.LAST
         --   INSERT INTO IBY_TRXN_ERROR_TOKENS VALUES x_trxnErrTokenTab(j);

         FORALL j in x_trxnErrTokenTab.FIRST..x_trxnErrTokenTab.LAST
            INSERT INTO IBY_TRXN_ERROR_TOKENS
                (
                transaction_error_id,
                token_name,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                object_version_number,
                token_value,
                lookup_type_source,
                last_update_login
                )
            VALUES
                (
                l_trxn_error_id(j),
                l_token_name(j),
                l_crtd_by(j),
                l_crt_date(j),
                l_last_updtd_by(j),
                l_last_updt_date(j),
                l_object_ver_number(j),
                l_token_value(j),
                l_lookup_type_source(j),
                l_last_updt_login(j)
                )
                ;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Finished populating '
	             || 'IBY_TRXN_ERROR_TOKENS.');

         END IF;
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
     --
     -- Need to raise Business Event here with error information
     --
     EXCEPTION
         WHEN OTHERS THEN
             FND_MESSAGE.SET_NAME('IBY', '');
             FND_MESSAGE.SET_TOKEN('SQLERR',
                 'insert_transaction_errors : ' || SQLERRM);
             FND_MSG_PUB.Add;
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, SQLERRM, FND_LOG.LEVEL_UNEXPECTED);
             END IF;
         RAISE g_abort_program;

 END insert_transaction_errors;

/*--------------------------------------------------------------------
 | NAME:
 |     insert_transaction_errors
 |
 | PURPOSE:
 |     Original procedure that has been overloaded.
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
 PROCEDURE insert_transaction_errors(
     p_isOnlineVal IN            VARCHAR2,
     x_docErrorTab IN OUT NOCOPY docErrorTabType
     )
 IS
 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME ||
     '.insert_transaction_errors';

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Old Method - ENTER');

     END IF;
     insert_transaction_errors(p_isOnlineVal, x_docErrorTab,
         l_dummy_err_token_tab);

 END insert_transaction_errors;

/*--------------------------------------------------------------------
 | NAME:
 |     insertIntoErrorTable
 |
 | PURPOSE:
 |     Inserts the document validation errors into PLSQL Table
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
 PROCEDURE insertIntoErrorTable(
     x_docErrorRec     IN OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
     x_docErrorTab     IN OUT NOCOPY docErrorTabType,
     x_trxnErrTokenTab IN OUT NOCOPY trxnErrTokenTabType
     )
 IS

 l_transaction_error_id IBY_TRANSACTION_ERRORS.transaction_error_id%TYPE;
 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME || '.insertIntoErrorTable';
 l_index NUMBER;

 BEGIN

     print_debuginfo (l_module_name, 'Validation Failed: '
         || x_docErrorRec.error_message);

     /* Get the next sequence value from IBY_TRANSACTION_ERRORS_S */
     IF x_docErrorRec.transaction_error_id IS NULL THEN

         SELECT
             IBY_TRANSACTION_ERRORS_S.NEXTVAL
         INTO
             l_transaction_error_id
         FROM
             DUAL
         ;

        x_docErrorRec.transaction_error_id := l_transaction_error_id;

     ELSE

        l_transaction_error_id := x_docErrorRec.transaction_error_id;

     END IF;

     IF (x_trxnErrTokenTab.COUNT > 0) THEN

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo(l_module_name, 'Token SQL table will be populated.');

        END IF;
        FOR i in x_trxnErrTokenTab.FIRST..x_trxnErrTokenTab.LAST
        LOOP

           IF x_trxnErrTokenTab(i).transaction_error_id is NULL THEN
              x_trxnErrTokenTab(i).transaction_error_id :=
                  l_transaction_error_id;
           END IF;

        END LOOP;

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo(l_module_name, 'Transaction_error_id in token '
	            || 'SQL table is populated.');

        END IF;
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Finished populating the error table.');

     END IF;
     l_index :=  x_docErrorTab.COUNT + 1;
     x_docErrorTab(l_index) := x_docErrorRec;

     /*
      * Reset the transaction error id on the x_docErrorRec object.
      * The transaction error id is the primary key of the
      * IBY_TRANSACTION_ERRORS table and cannot be reused for a
      * new error message.
      *
      * Since it is the callers responsibility to initialize the
      * transaction error id (if need be) on x_docErrorRec, we
      * can safely reset the transaction error id here.
      */
     x_docErrorRec.transaction_error_id := null;

 END insertIntoErrorTable;

 /*
  * The original procedure is overloaded
  */
 PROCEDURE insertIntoErrorTable(
     x_docErrorRec IN OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
     x_docErrorTab IN OUT NOCOPY docErrorTabType
     )
 IS

 l_transaction_error_id IBY_TRANSACTION_ERRORS.transaction_error_id%TYPE;
 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME || '.insertIntoErrorTable';

 BEGIN
     print_debuginfo (l_module_name, 'Old Method - Validation Failed: '
         || x_docErrorRec.error_message);

     insertIntoErrorTable(x_docErrorRec, x_docErrorTab, l_dummy_err_token_tab);

 END insertIntoErrorTable;

 /*--------------------------------------------------------------------
  | NAME:
  |     retrieveErrorMSG
  |
  | PURPOSE:
  |     Function to retrieve an error message according to an object
  |     code and an error message number provided.
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
  PROCEDURE retrieveErrorMSG (
             p_object_code   IN fnd_lookups.lookup_code%TYPE,
             p_msg_name      IN fnd_new_messages.message_name%TYPE,
             p_message       IN OUT NOCOPY fnd_new_messages.message_text%TYPE
  ) IS

  l_msg_token fnd_lookups.meaning%TYPE;

  BEGIN

    -- Retrieve the message token
    SELECT meaning
      INTO l_msg_token
      FROM fnd_lookups
     WHERE lookup_type = 'IBY_VALIDATION_FIELDS'
       AND lookup_code = p_object_code;

    FND_MESSAGE.SET_NAME('IBY', p_msg_name);
    FND_MESSAGE.SET_TOKEN('ERR_OBJECT', l_msg_token, false);
    p_message := fnd_message.get;

    EXCEPTION
          WHEN OTHERS THEN
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	          print_debuginfo(G_PKG_NAME || '.retrieveErrorMSG',
	          	'Fatal: Exception when retrieving a validation error message.');
	          print_debuginfo(G_PKG_NAME || '.retrieveErrorMSG',
	          	'SQL code: '   || SQLCODE);
	          print_debuginfo(G_PKG_NAME || '.retrieveErrorMSG',
	          	'SQL err msg: '|| SQLERRM);

          END IF;
 END retrieveErrorMSG;

/*--------------------------------------------------------------------
 | NAME:
 |     evaluateCondition
 |
 | PURPOSE:
 |     Procedure to evaluate a specific condition for a
 |     particular field on the basis of a token. This will
 |     minimize code in the Validation entry point procedures.
 |
 |     The possible token values are:
 |     EQUALSTO, NOTEQUALSTO, NOTNULL, LENGTH, MAXLENGTH,
 |     MINLENGTH, MIN, MAX, MASK, LIKE, SET, CUSTOM, ASSIGN,
 |     TYPE.
 |
 |     For token 'CUSTOM', this makes a dynamic PLSQL call to
 |     a procedure specified in the parameter 'p_value'.
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
 PROCEDURE evaluateCondition(
     p_fieldName   IN VARCHAR2,
     p_fieldValue  IN VARCHAR2,
     p_token       IN VARCHAR2,
     p_char_value  IN VARCHAR2,
     p_num_value   IN NUMBER,
     x_valResult   OUT NOCOPY BOOLEAN,
     x_docErrorRec IN OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE
     )
 IS

 l_stmt VARCHAR2(200);
 l_cnt NUMBER;
 l_chr VARCHAR2(1);
 l_deliv_cnt NUMBER;
 l_temp_num  NUMBER;
 l_num_flag  VARCHAR2(1);
 l_lookup_code_cnt NUMBER;
 l_error_msg VARCHAR2(2000);
 l_transaction_error_id IBY_TRANSACTION_ERRORS.transaction_error_id%TYPE;

 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME || '.evaluateCondition';

 BEGIN
     x_valResult := TRUE;
     x_docErrorRec.error_message  :='';

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

	     print_debuginfo(l_module_name, 'Evaluating '
	         || p_fieldName || ',' || p_fieldValue || ','
	         || p_token     || ',' || p_char_value || ','
	         || p_num_value);

     END IF;
     /*
      * Fix for bugs 5661094 and 5663530:
      *
      * Null fields need to be handled correctly. For example,
      * when checking whether a value has max length of 140,
      * if the value is null, then it must be treated as a
      * success.
      *
      * Most of the validation conditions using length checks
      * below will automatically get skipped if the value is null.
      *
      * The only special case is numeric values. Numeric values
      * should be treated as failed if the value is null.
      *
      * operator     data type
      * ---------    ---------
      * EQUALTO      - char
      * NOTEQUALTO   - char
      * GRTTHAN      - char
      * GRTEQUAL     - char
      * LESSTHAN     - char
      * LESSEQUAL    - char
      * ISNULL       - any
      * NOTNULL      - any
      * STRIS        - char
      * STRISNOT     - char
      * NUMERIC      - num
      * STARTWITH    - char
      * NOTSTARTWITH - char
      * INSET        - char
      * INLOOKUPTYPE - char
      * DIGITSONLY   - char
      * NOTINSET     - char
      * INDELIV      - char
      * VALID_CH_ESR - char
      * MAXLENGTH    - char
      * MINLENGTH    - char
      * EXACTLENGTH  - char
      * MASK         - char
      * LIKE         - char
      * CUSTOM       - char
      *
      * In the first if condition below, we treat numeric values
      * different from the rest of the data types.
      */

     --
     -- Applying each condition as per the token
     --

     IF (p_fieldvalue IS NULL and p_token = 'NUMERIC') THEN
         retrieveErrorMSG (p_fieldName, 'IBY_VALID_OBJ_INVALID', l_error_msg);
         x_docErrorRec.error_message := l_error_msg;
         x_docErrorRec.error_code := 'IBY_VALID_OBJ_INVALID';
         x_valResult := FALSE;
     ELSIF (p_token = 'MAXLENGTH' AND length(p_fieldValue) > p_num_value) THEN
         retrieveErrorMSG (p_fieldName, 'IBY_VALID_OBJ_INC_LENGTH', l_error_msg);
         x_docErrorRec.error_message := l_error_msg;
         x_docErrorRec.error_code := 'IBY_VALID_OBJ_INC_LENGTH';
         x_valResult := FALSE;
     ELSIF (p_token = 'MINLENGTH' AND length(p_fieldValue) < p_num_value) THEN
         retrieveErrorMSG (p_fieldName, 'IBY_VALID_OBJ_INC_LENGTH', l_error_msg);
         x_docErrorRec.error_message := l_error_msg;
         x_docErrorRec.error_code := 'IBY_VALID_OBJ_INC_LENGTH';
         x_valResult := FALSE;
     ELSIF (p_token = 'EXACTLENGTH' AND length(p_fieldValue) <> p_num_value) THEN
         retrieveErrorMSG (p_fieldName, 'IBY_VALID_OBJ_INC_LENGTH', l_error_msg);
         x_docErrorRec.error_message := l_error_msg;
         x_docErrorRec.error_code := 'IBY_VALID_OBJ_INC_LENGTH';
         x_valResult := FALSE;
     ELSIF (p_token = 'EQUALTO' AND to_number(p_fieldValue) <> p_num_value) THEN
         retrieveErrorMSG (p_fieldName, 'IBY_VALID_OBJ_INCORRECT', l_error_msg);
         x_docErrorRec.error_message := l_error_msg;
         x_docErrorRec.error_code := 'IBY_VALID_OBJ_INCORRECT';
         x_valResult := FALSE;
     ELSIF (p_token = 'NOTEQUALTO' AND to_number(p_fieldValue) = p_num_value) THEN
         retrieveErrorMSG (p_fieldName, 'IBY_VALID_OBJ_INCORRECT', l_error_msg);
         x_docErrorRec.error_message := l_error_msg;
         x_docErrorRec.error_code := 'IBY_VALID_OBJ_INCORRECT';
         x_valResult := FALSE;
     ELSIF (p_token = 'GRTTHAN' AND
            to_number(p_fieldValue) <= p_num_value) THEN
         retrieveErrorMSG (p_fieldName, 'IBY_VALID_OBJ_INCORRECT', l_error_msg);
         x_docErrorRec.error_message := l_error_msg;
         x_docErrorRec.error_code := 'IBY_VALID_OBJ_INCORRECT';
	 x_valResult := FALSE;
     ELSIF (p_token = 'GRTEQUAL' AND
            to_number(p_fieldValue) < p_num_value) THEN
         retrieveErrorMSG (p_fieldName, 'IBY_VALID_OBJ_INCORRECT', l_error_msg);
         x_docErrorRec.error_message := l_error_msg;
         x_docErrorRec.error_code := 'IBY_VALID_OBJ_INCORRECT';
	 x_valResult := FALSE;
     ELSIF (p_token = 'LESSTHAN' AND
            to_number(p_fieldValue) >= p_num_value) THEN
         retrieveErrorMSG (p_fieldName, 'IBY_VALID_OBJ_INCORRECT', l_error_msg);
         x_docErrorRec.error_message := l_error_msg;
         x_docErrorRec.error_code := 'IBY_VALID_OBJ_INCORRECT';
	 x_valResult := FALSE;
     ELSIF (p_token = 'LESSEQUAL' AND
            to_number(p_fieldValue) > p_num_value) THEN
         retrieveErrorMSG (p_fieldName, 'IBY_VALID_OBJ_EXCEED_MAX', l_error_msg);
         x_docErrorRec.error_message := l_error_msg;
         x_docErrorRec.error_code := 'IBY_VALID_OBJ_EXCEED_MAX';
 	 x_valResult := FALSE;
     ELSIF (p_token = 'ISNULL' AND p_fieldValue is not NULL) THEN
         retrieveErrorMSG (p_fieldName, 'IBY_VALID_OBJ_NULL', l_error_msg);
         x_docErrorRec.error_message := l_error_msg;
         x_docErrorRec.error_code := 'IBY_VALID_OBJ_NULL';
         x_valResult := FALSE;
     ELSIF (p_token = 'NOTNULL' AND p_fieldValue is NULL) THEN
         retrieveErrorMSG (p_fieldName, 'IBY_VALID_OBJ_REQUIRED', l_error_msg);
         x_docErrorRec.error_message := l_error_msg;
         x_docErrorRec.error_code := 'IBY_VALID_OBJ_REQUIRED';
         x_valResult := FALSE;
     ELSIF (p_token = 'STRIS' AND p_fieldValue <> p_char_value ) THEN
         retrieveErrorMSG (p_fieldName, 'IBY_VALID_OBJ_INCORRECT', l_error_msg);
         x_docErrorRec.error_message := l_error_msg;
         x_docErrorRec.error_code := 'IBY_VALID_OBJ_INCORRECT';
         x_valResult := FALSE;
     ELSIF (p_token = 'STRISNOT' AND p_fieldValue = p_char_value ) THEN
          retrieveErrorMSG (p_fieldName, 'IBY_VALID_OBJ_INCORRECT', l_error_msg);
         x_docErrorRec.error_message := l_error_msg;
         x_docErrorRec.error_code := 'IBY_VALID_OBJ_INCORRECT';
         x_valResult := FALSE;
     ELSIF (p_token = 'NUMERIC') THEN
         begin
           l_temp_num := to_number(p_fieldValue);
           l_num_flag := 'Y';
         exception
           when others then
             l_num_flag := 'N';
         end;

         IF l_num_flag = 'N' THEN
            retrieveErrorMSG (p_fieldName, 'IBY_VALID_OBJ_NUM_VALUE', l_error_msg);
            x_docErrorRec.error_message := l_error_msg;
            x_docErrorRec.error_code := 'IBY_VALID_OBJ_NUM_VALUE';
            x_valResult := FALSE;
         END IF;
     ELSIF (p_token = 'STARTWITH' AND substr(p_fieldValue,1,length(p_char_value)) <> p_char_value ) THEN
           retrieveErrorMSG (p_fieldName, 'IBY_VALID_OBJ_INCORRECT', l_error_msg);
           x_docErrorRec.error_message := l_error_msg;
           x_docErrorRec.error_code := 'IBY_VALID_OBJ_INCORRECT';
           x_valResult := FALSE;
     ELSIF (p_token = 'NOTSTARTWITH' AND substr(p_fieldValue,1,length(p_char_value)) = p_char_value ) THEN
           retrieveErrorMSG (p_fieldName, 'IBY_VALID_OBJ_INCORRECT', l_error_msg);
           x_docErrorRec.error_message := l_error_msg;
           x_docErrorRec.error_code := 'IBY_VALID_OBJ_INCORRECT';
           x_valResult := FALSE;
     ELSIF (p_token = 'INSET' AND instr(p_char_value, p_fieldValue) = 0) THEN
           retrieveErrorMSG (p_fieldName, 'IBY_VALID_OBJ_INVALID', l_error_msg);
           x_docErrorRec.error_message := l_error_msg;
           x_docErrorRec.error_code := 'IBY_VALID_OBJ_INVALID';
           x_valResult := FALSE;
     ELSIF (p_token = 'NOTINSET' AND instr(p_char_value, p_fieldValue) <> 0) THEN
           retrieveErrorMSG (p_fieldName, 'IBY_VALID_OBJ_INVALID', l_error_msg);
           x_docErrorRec.error_message := l_error_msg;
           x_docErrorRec.error_code := 'IBY_VALID_OBJ_INVALID';
           x_valResult := FALSE;
     ELSIF p_token = 'INDELIV' THEN
         select count(*)
           into l_deliv_cnt
           from iby_delivery_channels_vl
          where territory_code = p_char_value
            and delivery_channel_code = p_fieldValue
            -- and enabled_flag = 'Y'
            ;

         IF l_deliv_cnt = 0 THEN
            retrieveErrorMSG (p_fieldName, 'IBY_VALID_OBJ_INVALID', l_error_msg);
            x_docErrorRec.error_message := l_error_msg;
            x_docErrorRec.error_code := 'IBY_VALID_OBJ_INVALID';
            x_valResult := FALSE;
         END IF;
     ELSIF (p_token = 'INLOOKUPTYPE') THEN
         select count(*)
           into l_lookup_code_cnt
           from fnd_lookups
          where lookup_type = p_char_value
            and lookup_code = p_fieldValue;

         IF l_lookup_code_cnt = 0 THEN
            retrieveErrorMSG (p_fieldName, 'IBY_VALID_OBJ_INVALID', l_error_msg);
            x_docErrorRec.error_message := l_error_msg;
            x_docErrorRec.error_code := 'IBY_VALID_OBJ_INVALID';
            x_valResult := FALSE;
         END IF;
     ELSIF (p_token = 'DIGITSONLY' and translate(trim(p_fieldValue),'0123456789','          ') <>
            rpad(' ', length(trim(p_fieldValue)), ' ') ) THEN
         retrieveErrorMSG (p_fieldName, 'IBY_VALID_OBJ_NUM_ONLY', l_error_msg);
         x_docErrorRec.error_message := l_error_msg;
         x_docErrorRec.error_code := 'IBY_VALID_OBJ_NUM_ONLY';
         x_valResult := FALSE;
     ELSIF (p_token = 'VALID_CH_ESR') THEN
         if not validate_CH_EST(p_fieldValue) then
            retrieveErrorMSG (p_fieldName, 'IBY_VALID_OBJ_INVALID', l_error_msg);
            x_docErrorRec.error_message := l_error_msg;
            x_docErrorRec.error_code := 'IBY_VALID_OBJ_INVALID';
            x_valResult := FALSE;
         end if;
     ELSIF (p_token = 'MASK' AND
            LENGTH(TRIM(TRANSLATE(p_fieldValue,p_char_value,' ')))=0) THEN
         retrieveErrorMSG (p_fieldName, 'IBY_VALID_OBJ_INVALID', l_error_msg);
         x_docErrorRec.error_message := l_error_msg;
         x_docErrorRec.error_code := 'IBY_VALID_OBJ_INVALID';
         x_valResult := FALSE;
     ELSIF (p_token = 'CUSTOM') THEN
           l_stmt := 'BEGIN '||p_char_value||'(:1,:2,:3); END;';

           EXECUTE IMMEDIATE (l_stmt) USING
               IN p_fieldName,
               IN p_fieldValue,
               OUT l_chr;

         IF (l_chr <> '0') THEN
            retrieveErrorMSG (p_fieldName, 'IBY_VALID_OBJ_INVALID', l_error_msg);
            x_docErrorRec.error_message := l_error_msg;
            x_docErrorRec.error_code := 'IBY_VALID_OBJ_INVALID';
            x_valResult := FALSE;
         END IF;
     -- the following ELSE is dummy
     ELSE
         retrieveErrorMSG (p_fieldName, 'IBY_VALID_OBJ_INVALID', l_error_msg);
         x_docErrorRec.error_message := l_error_msg;
         x_docErrorRec.error_code := 'IBY_VALID_OBJ_INVALID';
     END IF;

     IF NOT x_valResult THEN

        SELECT
            IBY_TRANSACTION_ERRORS_S.NEXTVAL
        INTO
            l_transaction_error_id
        FROM
            DUAL
        ;

        x_docErrorRec.transaction_error_id := l_transaction_error_id;

        INSERT INTO IBY_TRXN_ERROR_TOKENS
        (TRANSACTION_ERROR_ID, TOKEN_NAME, TOKEN_VALUE, LOOKUP_TYPE_SOURCE,
         CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN, OBJECT_VERSION_NUMBER)
        VALUES
        (l_transaction_error_id, 'ERR_OBJECT', p_fieldName, 'IBY_VALIDATION_FIELDS',
         fnd_global.user_id, sysdate, fnd_global.user_id, sysdate,
         fnd_global.user_id, 1);

     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
     RETURN;

     EXCEPTION
         WHEN OTHERS THEN
             FND_MESSAGE.SET_NAME('IBY', '');
             FND_MESSAGE.SET_TOKEN('SQLERR','evaluateCondition : '||
                 substr(SQLERRM, 1, 300));
             FND_MSG_PUB.Add;
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name,'            '||
	                 substr(SQLERRM, 1, 300), FND_LOG.LEVEL_UNEXPECTED);
             END IF;
             RAISE g_abort_program;

 END evaluateCondition;

 -- Utility procedures
/*--------------------------------------------------------------------
 | NAME:
 |     getParamValue
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
 PROCEDURE getParamValue (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.
                                    validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.
                                    validation_set_code%TYPE,
     p_validation_param_code IN IBY_VALIDATION_PARAMS_B.
                                    validation_parameter_code%TYPE,
     p_value                 OUT NOCOPY VARCHAR2)

 IS

 l_module_name      CONSTANT VARCHAR2(200) := G_PKG_NAME || '.getParamValue';

 BEGIN

   select decode(vp.validation_parameter_type,
          'VARCHAR2', val_param_varchar2_value,
          'NUMBER', val_param_number_value,
          'DATE', val_param_date_value)
     into p_value
     from iby_val_assignments        va,
          iby_validation_values      vv,
          iby_validation_params_vl   vp
   where va.validation_set_code = p_validation_set_code
     and va.validation_assignment_id = p_validation_assign_id
     and va.validation_set_code = vv.validation_set_code
     and va.validation_assignment_id = vv.validation_assignment_id
     and vv.validation_parameter_code = p_validation_param_code
     and vp.validation_set_code = va.validation_set_code
     and vp.validation_parameter_code = vv.validation_parameter_code;

   /*
    * Fix for bug 5262536:
    *
    * The code below should only be applicable to field names.
    * Otherwise, it nulls out the limit value attached to
    * a validation set.
    *
    * Therefore, add an if condition for the block below
    * checking for the validation param code P_FIELD_NAME.
    */
   IF (p_validation_param_code = 'P_FIELD_NAME') THEN
       if substr(p_validation_set_code,1,8) = 'RULE_INS' and
           substr(p_value,1,4) <> 'INS_' then
           p_value := null;
       elsif substr(p_validation_set_code,1,8) = 'RULE_PMT' and
           substr(p_value,1,4) <> 'PMT_' then
           p_value := null;
       elsif substr(p_validation_set_code,1,8) = 'RULE_DOC' and
           substr(p_value,1,4) in ('INS_', 'PMT_') then
           p_value := null;
       end if;
   END IF;

 EXCEPTION
   WHEN OTHERS THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	       print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);
       END IF;
       p_value := null;

 END getParamValue;

/*--------------------------------------------------------------------
 | NAME:
 |     getDocumentFieldValue
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
 PROCEDURE getDocumentFieldValue (
     p_field_name	IN VARCHAR2,
     p_document_rec	IN documentRecType,
     p_field_value	OUT NOCOPY VARCHAR2)
 IS

 BEGIN
   if p_field_name = 'DOCUMENT_ID' then
      p_field_value := p_document_rec.document_id;
   elsif p_field_name = 'DOCUMENT_AMOUNT' then
      p_field_value := p_document_rec.document_amount;
   elsif p_field_name = 'DOCUMENT_PAY_CURRENCY' then
      p_field_value := p_document_rec.document_pay_currency;
   elsif p_field_name = 'EXCLUSIVE_PAYMENT_FLAG' then
      p_field_value := p_document_rec.exclusive_payment_flag;
   elsif p_field_name = 'DELIVERY_CHANNEL_CODE' then
      p_field_value := p_document_rec.delivery_channel_code;
   elsif p_field_name = 'UNIQUE_REMIT_ID_CODE' then
      p_field_value := p_document_rec.unique_remit_id_code;
   elsif p_field_name = 'INT_BANK_NUM' then
      p_field_value := p_document_rec.int_bank_num;
   elsif p_field_name = 'INT_BANK_NAME' then
      p_field_value := p_document_rec.int_bank_name;
   elsif p_field_name = 'INT_BANK_NAME_ALT' then
      p_field_value := p_document_rec.int_bank_name_alt;
   elsif p_field_name = 'INT_BANK_BRANCH_NUM' then
      p_field_value := p_document_rec.int_bank_branch_num;
   elsif p_field_name = 'INT_BANK_BRANCH_NAME' then
      p_field_value := p_document_rec.int_bank_branch_name;
   elsif p_field_name = 'INT_BANK_BRANCH_NAME_ALT' then
      p_field_value := p_document_rec.int_bank_branch_name_alt;
   elsif p_field_name = 'INT_BANK_ACC_NUM' then
      p_field_value := p_document_rec.int_bank_acc_num;
   elsif p_field_name = 'INT_BANK_ACC_NAME' then
      p_field_value := p_document_rec.int_bank_acc_name;
   elsif p_field_name = 'INT_BANK_ACC_NAME_ALT' then
      p_field_value := p_document_rec.int_bank_acc_name_alt;
   elsif p_field_name = 'INT_BANK_ACC_TYPE' then
      p_field_value := p_document_rec.int_bank_acc_type;
   elsif p_field_name = 'INT_BANK_ACC_IBAN' then
      p_field_value := p_document_rec.int_bank_acc_iban;
   elsif p_field_name = 'INT_BANK_ASSIGNED_ID1' then
      p_field_value := p_document_rec.int_bank_assigned_id1;
   elsif p_field_name = 'INT_BANK_ASSIGNED_ID2' then
      p_field_value := p_document_rec.int_bank_assigned_id2;
   elsif p_field_name = 'INT_EFT_USER_NUMBER' then
      p_field_value := p_document_rec.int_eft_user_number;
   elsif p_field_name = 'PAYER_LE_NAME' then
      p_field_value := p_document_rec.payer_le_name;
   elsif p_field_name = 'PAYER_LE_COUNTRY' then
      p_field_value := p_document_rec.payer_le_country;
   elsif p_field_name = 'PAYER_PHONE' then
      p_field_value := p_document_rec.payer_phone;
   elsif p_field_name = 'EXT_BANK_NUM' then
      p_field_value := p_document_rec.ext_bank_num;
   elsif p_field_name = 'EXT_BANK_NAME' then
      p_field_value := p_document_rec.ext_bank_name;
   elsif p_field_name = 'EXT_BANK_NAME_ALT' then
      p_field_value := p_document_rec.ext_bank_name_alt;
   elsif p_field_name = 'EXT_BANK_BRANCH_NUM' then
      p_field_value := p_document_rec.ext_bank_branch_num;
   elsif p_field_name = 'EXT_BANK_BRANCH_NAME' then
      p_field_value := p_document_rec.ext_bank_branch_name;
   elsif p_field_name = 'EXT_BANK_BRANCH_NAME_ALT' then
      p_field_value := p_document_rec.ext_bank_branch_name_alt;
   elsif p_field_name = 'EXT_BANK_COUNTRY' then
      p_field_value := p_document_rec.ext_bank_country;
   elsif p_field_name = 'EXT_BANK_BRANCH_COUNTRY' then
      p_field_value := p_document_rec.ext_bank_branch_country;
   elsif p_field_name = 'EXT_BANK_BRANCH_ADDR1' then
      p_field_value := p_document_rec.ext_bank_branch_addr1;
   elsif p_field_name = 'EXT_BANK_ACC_NUM' then
      p_field_value := p_document_rec.ext_bank_acc_num;
   elsif p_field_name = 'EXT_BANK_ACC_NAME' then
      p_field_value := p_document_rec.ext_bank_acc_name;
   elsif p_field_name = 'EXT_BANK_ACC_NAME_ALT' then
      p_field_value := p_document_rec.ext_bank_acc_name_alt;
   elsif p_field_name = 'EXT_BANK_ACC_TYPE' then
      p_field_value := p_document_rec.ext_bank_acc_type;
   elsif p_field_name = 'EXT_BANK_ACC_IBAN' then
      p_field_value := p_document_rec.ext_bank_acc_iban;
   elsif p_field_name = 'EXT_BANK_ACC_CHK_DGTS' then
      p_field_value := p_document_rec.ext_bank_acc_chk_dgts;
   elsif p_field_name = 'PAYEE_PARTY_NAME' then
      p_field_value := p_document_rec.payee_party_name;
   elsif p_field_name = 'PAYEE_PARTY_SITE_ADDR1' then
      p_field_value := p_document_rec.payee_party_addr1;
   elsif p_field_name = 'EXTERNAL_BANK_ACCOUNT_ID' then
      p_field_value := p_document_rec.external_bank_account_id;

   /*
    * Update by Ramesh:
    *
    * Change some of the payee address related field names
    * because of the way the names are seeded in
    * the IBY_VALIDATION_FIELDS lookup.
    *
    * For example, here the field name is PAYEE_PARTY_CITY
    * but in the lookup, it is seeded as PAYEE_PARTY_SITE_CITY.
    *
    * Because of the mismatch, the field value is returned as
    * null and the validation always fails. It is simpler
    * to rename the field names here that in the lookup.
    *
    * Hence changing the payee addredd related field names
    * here.
    */
   elsif p_field_name = 'PAYEE_PARTY_SITE_CITY' then
      p_field_value := p_document_rec.payee_party_city;
   elsif p_field_name = 'PAYEE_PARTY_SITE_POSTAL' then
      p_field_value := p_document_rec. payee_party_postal;
   elsif p_field_name = 'PAYEE_PARTY_SITE_COUNTRY' then
      p_field_value := p_document_rec.payee_party_country;
   elsif p_field_name = 'BANK_CHARGE_BEARER' then
      p_field_value := p_document_rec.bank_charge_bearer;
   elsif p_field_name = 'PAYMENT_REASON_CODE' then
      p_field_value := p_document_rec.payment_reason_code;
   elsif p_field_name = 'PAYMENT_METHOD_ID' then
      p_field_value := p_document_rec.payment_method_cd;
   elsif p_field_name = 'PAYMENT_FORMAT_ID' then
      p_field_value := p_document_rec.payment_format_cd;
   elsif p_field_name = 'PAYMENT_REASON_COMMENTS' then
      p_field_value := p_document_rec.PAYMENT_REASON_COMMENTS;
   elsif p_field_name = 'SETTLEMENT_PRIORITY' then
      p_field_value := p_document_rec.SETTLEMENT_PRIORITY;
   elsif p_field_name = 'REMITTANCE_MESSAGE1' then
      p_field_value := p_document_rec.REMITTANCE_MESSAGE1;
   elsif p_field_name = 'REMITTANCE_MESSAGE2' then
      p_field_value := p_document_rec.REMITTANCE_MESSAGE2;
   elsif p_field_name = 'REMITTANCE_MESSAGE3' then
      p_field_value := p_document_rec.REMITTANCE_MESSAGE3;
   elsif p_field_name = 'URI_CHECK_DIGIT' then
      p_field_value := p_document_rec.URI_CHECK_DIGIT;

    /*
     * Updated by sodash
     * for Payee BIC validation
     */
   elsif p_field_name = 'EXT_EFT_SWIFT_CODE' then
      p_field_value := p_document_rec.ext_eft_swift_code;

  /*Start of Bug 9704929*/
  elsif p_field_name = 'PAYEE_PARTY_SITE_NAME' then
      p_field_value := p_document_rec.payee_party_site_name;
 /*End of Bug 9704929*/
   else
      null;
   end if;

 END getDocumentFieldValue;

/*--------------------------------------------------------------------
 | NAME:
 |     getPaymentFieldValue
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
 PROCEDURE getPaymentFieldValue (
     p_field_name	IN VARCHAR2,
     p_payment_rec	IN paymentRecType,
     p_field_value	OUT NOCOPY VARCHAR2)
 IS

 BEGIN
   if p_field_name = 'PMT_ID' then
      p_field_value := p_payment_rec.pmt_id;
   elsif p_field_name = 'PMT_AMOUNT' then
      p_field_value := p_payment_rec.pmt_amount;
   elsif p_field_name = 'PMT_CURRENCY' then
      p_field_value := p_payment_rec.pmt_currency;
   elsif p_field_name = 'PMT_DETAIL' then
      p_field_value := p_payment_rec.pmt_detail;
   elsif p_field_name = 'PMT_DELIVERY_CHANNEL_CODE' then
      p_field_value := p_payment_rec.pmt_delivery_channel_code;
   elsif p_field_name = 'PMT_PAYER_LE_COUNTRY' then
      p_field_value := p_payment_rec.pmt_payer_le_country;
   elsif p_field_name = 'PMT_PAYMENT_REASON_COUNT' then
      p_field_value := p_payment_rec.pmt_payment_reason_count;

   /*
    * Updated by sodash
    * Payer IBAN and Payer Address Validations
    */
   elsif p_field_name = 'INT_BANK_ACC_IBAN' then
      p_field_value := p_payment_rec.int_bank_account_iban;
   elsif p_field_name = 'PARTY_ADDRESS_LINE1' then
      p_field_value := p_payment_rec.party_address_line1;
   elsif p_field_name = 'PARTY_ADDRESS_CITY' then
      p_field_value := p_payment_rec.party_address_city;
   elsif p_field_name = 'PARTY_ADDRESS_POSTAL_CODE' then
      p_field_value := p_payment_rec.party_address_postal_code;

   else
      null;
   end if;

 END getPaymentFieldValue;

/*--------------------------------------------------------------------
 | NAME:
 |     getInstructionFieldValue
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
 PROCEDURE getInstructionFieldValue (
     p_field_name	IN VARCHAR2,
     p_instruction_rec	IN instructionRecType,
     p_field_value	OUT NOCOPY VARCHAR2)
 IS

 BEGIN
   if p_field_name = 'INS_ID' then
      p_field_value := p_instruction_rec.ins_id;
   elsif p_field_name = 'INS_AMOUNT' then
      p_field_value := p_instruction_rec.ins_amount;
   elsif p_field_name = 'INS_DOCUMENT_COUNT' then
      p_field_value := p_instruction_rec.ins_document_count;
   else
      null;
   end if;

 END getInstructionFieldValue;

/*--------------------------------------------------------------------
 | NAME:
 |     getRequestAttributes
 |
 | PURPOSE:
 |     Gets the calling app payment service request id, and the
 |     calling app id for the given payment service request.
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE getRequestAttributes(
     p_payReqId   IN IBY_PAY_SERVICE_REQUESTS.payment_service_request_id%TYPE,
     x_caPayReqCd IN OUT NOCOPY
         IBY_PAY_SERVICE_REQUESTS.call_app_pay_service_req_code%TYPE,
     x_caId       IN OUT NOCOPY
         IBY_PAY_SERVICE_REQUESTS.calling_app_id%TYPE
     )
 IS
 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME || '.getRequestAttributes';
 BEGIN

     SELECT
         call_app_pay_service_req_code,
         calling_app_id
     INTO
         x_caPayReqCd,
         x_caId
     FROM
         IBY_PAY_SERVICE_REQUESTS
     WHERE
         payment_service_request_id = p_payReqId;

 END getRequestAttributes;

/*--------------------------------------------------------------------
 | NAME:
 |     raiseBizEvents
 |
 | PURPOSE:
 |     Raises business events to inform the calling app of a change
 |     in document/payment request status.
 |
 |     The payload for the business event will be an XML clob that
 |     contains a list of failed documents (or the payment request id
 |     if the entire request has failed).
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE raiseBizEvents(
     p_payreq_id          IN            VARCHAR2,
     p_cap_payreq_id      IN            VARCHAR2,
     p_cap_id             IN            NUMBER,
     x_allDocsSuccessFlag IN OUT NOCOPY BOOLEAN,
     p_rejectionLevel     IN            VARCHAR2
     )
 IS

 l_module_name    CONSTANT VARCHAR2(200) := G_PKG_NAME || '.raiseBizEvents';
 l_xml_clob       CLOB;
 l_event_name     VARCHAR2(200);
 l_event_key      NUMBER;
 l_param_names    JTF_VARCHAR2_TABLE_300;
 l_param_vals     JTF_VARCHAR2_TABLE_300;

 l_rej_doc_id_list     IBY_DISBURSE_UI_API_PUB_PKG.docPayIDTab;
 l_rej_doc_status_list IBY_DISBURSE_UI_API_PUB_PKG.docPayStatusTab;

 l_return_status  VARCHAR2(500);

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

	     print_debuginfo(l_module_name, 'Payreq id: '
	         || p_payreq_id);

     END IF;
     /*
      * Get the rejection level system option
      */
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Rejection level system option: '
	         || p_rejectionLevel);

     END IF;
     /*
      * These tables are used to pass event keys
      * to the business event.
      */
     l_param_names := JTF_VARCHAR2_TABLE_300();
     l_param_vals  := JTF_VARCHAR2_TABLE_300();

     /*
      * The event key uniquely identifies a specific
      * occurance of an event. Therefore, it should be
      * a sequence number.
      */
     SELECT IBY_EVENT_KEY_S.nextval INTO l_event_key
     FROM DUAL;

     IF (p_rejectionLevel = REJ_LVL_REQUEST) THEN

         /*
          * For request level rejections, even if one
          * payment within the request fails, then the
          * entire payment request should be failed.
          */
         IF (x_allDocsSuccessFlag <> TRUE) THEN

             /*
              * Invoke the callout API with the payment request id.
              * This API should trigger the calling application to
              * fail the payment request and all it's associated
              * docs.
              */
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Going to invoke API call '
	                 || 'remove_payment_request()');

             END IF;
             /*
              * Invoke API to inform calling application
              * about the rejected payment request. This API
              * will remove all the documents payable in this
              * payment request from the processing cycle and
              * inform the calling application about this fact.
              */
             IBY_DISBURSE_UI_API_PUB_PKG.remove_payment_request (
                 p_payreq_id,
                 l_return_status
                 );

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Return status of '
	                 || 'remove_payment_request() API call: '
	                 || l_return_status,
	                 FND_LOG.LEVEL_UNEXPECTED
	                 );

             END IF;
             IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'API call did not succeed. '
	                     || 'Aborting build program .. ',
	                     FND_LOG.LEVEL_UNEXPECTED
	                     );

                 END IF;
                 APP_EXCEPTION.RAISE_EXCEPTION;

             END IF;

         ELSE

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Not invoking API. '
	                 || ' Reason: All documents were valid.'
	                 );

             END IF;
         END IF;

     ELSIF (p_rejectionLevel = REJ_LVL_DOCUMENT OR
            p_rejectionLevel = REJ_LVL_PAYEE) THEN
         /*
          * Invoke an API call with the list of failed
          * documents. This API call should trigger the
          * calling app to fail these docs.
          */

         /*
          * Select all docs that:
          * 1. Have the given pay req id
          * 2. Are not in 'validated' status
          */
         getRejectedDocs(p_payreq_id, l_rej_doc_id_list,
             l_rej_doc_status_list);

         IF (l_rej_doc_id_list.COUNT = 0) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Not invoking API '
	                 || ' because all documents were '
	                 || ' successfully validated. So no failed documents '
	                 || ' to notify.'
	                 );

             END IF;
         ELSE

	     print_debuginfo(l_module_name, 'Printing list of failed '
	         || 'documents');

             FOR i IN l_rej_doc_id_list.FIRST .. l_rej_doc_id_list.LAST LOOP

	         print_debuginfo(l_module_name, 'Doc id: '
	             || l_rej_doc_id_list(i)
	             || ', doc status: '
	             || l_rej_doc_status_list(i)
                     );

             END LOOP;

             /*
              * Invoke API to inform calling application
              * about the rejected documents.
              */
             IBY_DISBURSE_UI_API_PUB_PKG.remove_documents_payable (
                 l_rej_doc_id_list,
                 l_rej_doc_status_list,
                 l_return_status
                 );

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Return status of '
	                 || 'remove_documents_payable() API call: '
	                 || l_return_status,
	                 FND_LOG.LEVEL_UNEXPECTED
	                 );

             END IF;
             IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'API call did not succeed. '
	                     || 'Aborting build program .. ',
	                     FND_LOG.LEVEL_UNEXPECTED
	                     );

                 END IF;
                 APP_EXCEPTION.RAISE_EXCEPTION;

             END IF;

         END IF;

     ELSIF (p_rejectionLevel = REJ_LVL_NONE) THEN

         /*
          * Rejection level NONE means that manual intervention
          * is required in case any documents in the payment
          * service request have failed.
          *
          * Therefore, raise a business event for this rejection level
          * only if at least one document payable has failed in the
          * request.
          */

         l_event_name :=
             'oracle.apps.iby.buildprogram.validation.notify_user_error';

         IF (x_allDocsSuccessFlag <> TRUE) THEN

             /*
              * Raise a business event with the payment request id.
              * This business event should inform the user that
              * at least some documents payable have failed. This
              * should cause the user to manually review the failed
              * documents via the UI and take corrective action.
              */
             l_param_names.EXTEND;
             l_param_vals.EXTEND;
             l_param_names(1) := 'calling_app_id';
             l_param_vals(1)  := p_cap_id;

             l_param_names.EXTEND;
             l_param_vals.EXTEND;
             l_param_names(1) := 'pay_service_request_id';
             l_param_vals(1)  := p_cap_payreq_id;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Going to raise biz event '
	                 || l_event_name);

             END IF;
             iby_workflow_pvt.raise_biz_event(l_event_name, l_event_key,
                 l_param_names, l_param_vals);

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Raised biz event '
	                 || l_event_name || ' with key '
	                 || l_event_key  || '.');

             END IF;
         ELSE

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Not raising biz event '
	                 || l_event_name || '. Reason: All documents '
	                 || 'were valid.');

             END IF;
         END IF;

     ELSE

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Unknown rejection level: '
	             || p_rejectionLevel
	             || '. Aborting payment creation ..',
	             FND_LOG.LEVEL_UNEXPECTED
	             );

         END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;

     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 EXCEPTION
     WHEN OTHERS THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Fatal: Exception when attempting '
	             || 'to raise business event.', FND_LOG.LEVEL_UNEXPECTED);
	         print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE,
	             FND_LOG.LEVEL_UNEXPECTED);
	         print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM,
	             FND_LOG.LEVEL_UNEXPECTED);

         END IF;
         /*
          * Propogate exception to caller.
          */
         RAISE;

 END raiseBizEvents;

/*--------------------------------------------------------------------
 | NAME:
 |     failRelatedDocs
 |
 | PURPOSE:
 |     Fail all documents related to an already rejected document.
 |     Documents are related to each other by the 'payment grouping number'
 |     field.
 |
 | PARAMETERS:
 |     IN
 |     p_allDocsTab  List of all documents within this payment request
 |
 |     IN/OUT
 |     x_failedDocsTab  List of documents from this payment request that
 |                      have failed validation. When this procedure
 |                      completes, all documents that are related to
 |                      the documents in this list will also be marked
 |                      as failed and added to this list
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE failRelatedDocs(
     p_allDocsTab        IN            docPayTabType,
     x_failedDocsTab     IN OUT NOCOPY docStatusTabType,
     x_docErrorTab       IN OUT NOCOPY docErrorTabType,
     x_errTokenTab       IN OUT NOCOPY trxnErrTokenTabType
     )
 IS

 l_module_name        CONSTANT VARCHAR2(200) := G_PKG_NAME ||
                                                    '.failRelatedDocs';

 l_newlyFailedDocsTab docStatusTabType;
 l_invalidDocRec      docStatusRecType;
 --l_doc_err_rec        docErrorRecType;
 l_doc_err_rec        IBY_TRANSACTION_ERRORS%ROWTYPE;

 TYPE pmtGrpNumTabType is TABLE OF
     IBY_DOCS_PAYABLE_ALL.payment_grouping_number%TYPE
     INDEX BY BINARY_INTEGER;

 l_storedPmtGrpNumTab pmtGrpNumTabType;
 l_already_processed_flag BOOLEAN := FALSE;
 l_already_failed_flag BOOLEAN    := FALSE;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     FOR i in x_failedDocsTab.FIRST .. x_failedDocsTab.LAST LOOP

         IF (x_failedDocsTab(i).doc_status <> DOC_STATUS_RELN_FAIL) THEN

             /*
              * First check, if we have already processed this payment
              * grouping number. If yes, then skip to the next document.
              */
             l_already_processed_flag := FALSE;
             IF (l_storedPmtGrpNumTab.COUNT <> 0) THEN
                 FOR k in l_storedPmtGrpNumTab.FIRST .. l_storedPmtGrpNumTab.LAST
                 LOOP

                     IF (x_failedDocsTab(i).pmt_grp_num =
                         l_storedPmtGrpNumTab(k)) THEN
                             l_already_processed_flag := TRUE;
                             EXIT;
                     END IF;

                 END LOOP;
             END IF;

             IF (l_already_processed_flag <> TRUE) THEN

                 /*
                  * Loop through all the documents for this request,
                  * failing any documents that have the same orig
                  * doc id of the failed doc.
                  */
                 FOR j in p_allDocsTab.FIRST .. p_allDocsTab.LAST LOOP

                     IF (x_failedDocsTab(i).doc_id <> p_allDocsTab(j).doc_id)
                         THEN

                         IF (x_failedDocsTab(i).pmt_grp_num =
                                p_allDocsTab(j).pmt_grp_num) THEN

                             /*
                              * Check if this doc has already failed and
                              * been stored in the error docs list. If
                              *  it has already been failed, skip it.
                              */
                             l_already_failed_flag :=
                                 checkIfDocFailed(p_allDocsTab(j).doc_id,
                                     x_failedDocsTab);

                             IF (l_already_failed_flag = FALSE) THEN

                                 /*
                                  * Add this document to list of docs
                                  * failed by relation
                                  */
                                 l_invalidDocRec.doc_id
                                     := p_allDocsTab(j).doc_id;
                                 l_invalidDocRec.pmt_grp_num :=
                                     p_allDocsTab(j).pmt_grp_num;
                                 l_invalidDocRec.payee_id :=
                                     p_allDocsTab(j).payee_id;
                                 l_invalidDocRec.doc_status :=
                                     DOC_STATUS_RELN_FAIL;

                                 l_newlyFailedDocsTab(
                                     l_newlyFailedDocsTab.COUNT + 1) :=
                                         l_invalidDocRec;

                                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                                 print_debuginfo(l_module_name, 'Cascaded doc '
	                                     || 'failure: '
	                                     || x_failedDocsTab(i).doc_id
	                                     || ' -> '
	                                     || p_allDocsTab(j).doc_id
	                                     || '. Related by '
	                                     || x_failedDocsTab(i).pmt_grp_num
	                                     || '.'
	                                     );

                                 END IF;
                                 /*
                                  * Once we fail a doc, we must add a
                                  * corresponding error message to the
                                  * error table.
                                  */
                                 IBY_BUILD_UTILS_PKG.createErrorRecord(
                                     TRXN_TYPE_DOC,
                                     p_allDocsTab(j).doc_id,
                                     l_invalidDocRec.doc_status,
                                     p_allDocsTab(j).ca_id,
                                     p_allDocsTab(j).ca_doc_id1,
                                     p_allDocsTab(j).ca_doc_id2,
                                     p_allDocsTab(j).ca_doc_id3,
                                     p_allDocsTab(j).ca_doc_id4,
                                     p_allDocsTab(j).ca_doc_id5,
                                     p_allDocsTab(j).pp_tt_cd,
                                     l_doc_err_rec,
                                     x_errTokenTab,
                                     x_failedDocsTab(i).doc_id
                                     );

                                 insertIntoErrorTable(l_doc_err_rec,
                                     x_docErrorTab, x_errTokenTab);

                             END IF; -- not already failed

                         END IF;

                     END IF;

                 END LOOP; -- for each doc in request

                 /*
                  * Once we have processed all documents which have this
                  * orig doc id, we must not re-process them if there is
                  * another error doc with the same orig doc id.
                  *
                  * Therefore, store the processed orig doc id. We will
                  * skip any future error docs that have the same orig
                  * doc id.
                  */
                 l_storedPmtGrpNumTab(l_storedPmtGrpNumTab.COUNT + 1) :=
                     x_failedDocsTab(i).pmt_grp_num;

             END IF; -- not already processed

         END IF;

     END LOOP; -- for all failed documents

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Total # related docs failed: '
	         || l_newlyFailedDocsTab.COUNT);

     END IF;
     /*
      * Copy all the newly failed documents back into the
      * original failed documents table. The original failed
      * docs table will be used to update the database.
      */
     IF (l_newlyFailedDocsTab.COUNT <> 0) THEN
         FOR i in l_newlyFailedDocsTab.FIRST .. l_newlyFailedDocsTab.LAST LOOP
             x_failedDocsTab(x_failedDocsTab.COUNT + 1) :=
                 l_newlyFailedDocsTab(i);
         END LOOP;
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END failRelatedDocs;

/*--------------------------------------------------------------------
 | NAME:
 |     failAllDocsForPayee
 |
 | PURPOSE:
 |     Fail all documents that have the same payee id of an already
 |     rejected document. This is needed for 'payee level rejections'.
 |
 |
 | PARAMETERS:
 |     IN
 |     p_allDocsTab  List of all documents within this payment request
 |
 |     IN/OUT
 |     x_failedDocsTab  List of documents from this payment request that
 |                      have failed validation. When this procedure
 |                      completes, all documents that are related to
 |                      the documents in this list by payee id will also
 |                      be marked as failed and added to this list
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE failAllDocsForPayee(
     p_allDocsTab        IN            docPayTabType,
     x_failedDocsTab     IN OUT NOCOPY docStatusTabType,
     x_docErrorTab       IN OUT NOCOPY docErrorTabType,
     x_errTokenTab       IN OUT NOCOPY trxnErrTokenTabType
     )
 IS

 l_module_name        CONSTANT VARCHAR2(200) := G_PKG_NAME ||
                                                    '.failAllDocsForPayee';

 l_newlyFailedDocsTab docStatusTabType;
 l_invalidDocRec      docStatusRecType;
 l_doc_err_rec        IBY_TRANSACTION_ERRORS%ROWTYPE;
 l_doc_token_tab      trxnErrTokenTabType;

 TYPE payeeTabType is TABLE OF
     IBY_DOCS_PAYABLE_ALL.ext_payee_id%TYPE
     INDEX BY BINARY_INTEGER;

 l_storedPayeesTab payeeTabType;
 l_already_processed_flag BOOLEAN := FALSE;
 l_already_failed_flag BOOLEAN    := FALSE;
 l_print_var         VARCHAR2(1)  := '';

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     IF (x_failedDocsTab.COUNT = 0) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Exiting because error docs list '
	             || 'is empty');

	         print_debuginfo(l_module_name, 'EXIT');
         END IF;
         RETURN;

     END IF;


     FOR i in x_failedDocsTab.FIRST .. x_failedDocsTab.LAST LOOP

         IF (x_failedDocsTab(i).doc_status <> DOC_STATUS_FAIL_BY_REJLVL) THEN

             /*
              * First check, if we have already processed this payee
              * id. If yes, then skip to the next document.
              */
             l_already_processed_flag := FALSE;
             IF (l_storedPayeesTab.COUNT <> 0) THEN

                 FOR k in l_storedPayeesTab.FIRST .. l_storedPayeesTab.LAST
                 LOOP

                     IF (x_failedDocsTab(i).payee_id =
                         l_storedPayeesTab(k)) THEN
                             l_already_processed_flag := TRUE;
                             EXIT;
                     END IF;

                 END LOOP;

             END IF;

             IF (l_already_processed_flag <> TRUE) THEN

                 /*
                  * Loop through all the documents for this request,
                  * failing any documents that have the same payee id
                  * as the failed doc.
                  */
                 FOR j in p_allDocsTab.FIRST .. p_allDocsTab.LAST LOOP

                     IF (x_failedDocsTab(i).doc_id <> p_allDocsTab(j).doc_id)
                         THEN

                         IF (x_failedDocsTab(i).payee_id =
                                p_allDocsTab(j).payee_id) THEN

                             /*
                              * Check if this doc has already failed and
                              * been stored in the error docs list. If
                              *  it has already been failed, skip it.
                              */
                             l_already_failed_flag :=
                                 checkIfDocFailed(p_allDocsTab(j).doc_id,
                                     x_failedDocsTab);

                             IF (l_already_failed_flag = FALSE) THEN
                                 /*
                                  * Add this document to list of docs
                                  * failed because of same payee
                                  */
                                 l_invalidDocRec.doc_id :=
                                     p_allDocsTab(j).doc_id;
                                 l_invalidDocRec.pmt_grp_num :=
                                     p_allDocsTab(j).pmt_grp_num;
                                 l_invalidDocRec.payee_id :=
                                     p_allDocsTab(j).payee_id;
                                 l_invalidDocRec.doc_status :=
                                     DOC_STATUS_FAIL_BY_REJLVL;

                                 l_newlyFailedDocsTab(
                                     l_newlyFailedDocsTab.COUNT + 1) :=
                                         l_invalidDocRec;

                                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                                 print_debuginfo(l_module_name, 'Cascaded doc '
	                                     || 'failure: '
	                                     || x_failedDocsTab(i).doc_id
	                                     || ' -> '
	                                     || p_allDocsTab(j).doc_id
	                                     || '. Related by payee '
	                                     || x_failedDocsTab(i).payee_id
	                                     || '.'
	                                     );

                                 END IF;
                                 /*
                                  * Once we fail a doc, we must add a
                                  * corresponding error message to the
                                  * error table.
                                  */
                                 IBY_BUILD_UTILS_PKG.createErrorRecord(
                                     TRXN_TYPE_DOC,
                                     p_allDocsTab(j).doc_id,
                                     l_invalidDocRec.doc_status,
                                     p_allDocsTab(j).ca_id,
                                     p_allDocsTab(j).ca_doc_id1,
                                     p_allDocsTab(j).ca_doc_id2,
                                     p_allDocsTab(j).ca_doc_id3,
                                     p_allDocsTab(j).ca_doc_id4,
                                     p_allDocsTab(j).ca_doc_id5,
                                     p_allDocsTab(j).pp_tt_cd,
                                     l_doc_err_rec,
                                     x_errTokenTab,
                                     x_failedDocsTab(i).doc_id
                                     );

                                 insertIntoErrorTable(l_doc_err_rec,
                                     x_docErrorTab, x_errTokenTab);

                             END IF; -- not already failed

                         END IF;

                     END IF;

                 END LOOP; -- for each doc in request

                 /*
                  * Once we have processed all documents which have this
                  * orig doc id, we must not re-process them if there is
                  * another error doc with the same orig doc id.
                  *
                  * Therefore, store the processed orig doc id. We will
                  * skip any future error docs that have the same orig
                  * doc id.
                  */
                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Adding payee id: '
	                     || x_failedDocsTab(i).payee_id
	                     || ' to stored payees tab'
	                     );
                 END IF;
                 l_storedPayeesTab(l_storedPayeesTab.COUNT + 1) :=
                     x_failedDocsTab(i).payee_id;

             END IF; -- not already processed

         END IF;

     END LOOP; -- for all failed documents

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Total # payee related docs failed: '
	         || l_newlyFailedDocsTab.COUNT);

     END IF;
     /*
      * Copy all the newly failed documents back into the
      * original failed documents table. The original failed
      * docs table will be used to update the database.
      */
     IF (l_newlyFailedDocsTab.COUNT <> 0) THEN
         FOR i in l_newlyFailedDocsTab.FIRST .. l_newlyFailedDocsTab.LAST LOOP
             x_failedDocsTab(x_failedDocsTab.COUNT + 1) :=
                 l_newlyFailedDocsTab(i);
         END LOOP;
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END failAllDocsForPayee;

/*--------------------------------------------------------------------
 | NAME:
 |     failAllDocsForRequest
 |
 | PURPOSE:
 |     Fail all documents in the payment request. All documents that
 |     are present in the error docs list will already be failed with
 |     status REJECTED. Add any non-failed docs present in the
 |     payment request to the error docs list, and status set the
 |     status of such added docs to FAILED_BY_REJ_LEVEL.
 |     This is needed for 'request level rejections'.
 |
 |
 | PARAMETERS:
 |     IN
 |     p_allDocsTab  List of all documents within this payment request
 |
 |     IN/OUT
 |     x_failedDocsTab  List of documents from this payment request that
 |                      have failed validation. When this procedure
 |                      completes, all documents in this request will
 |                      be marked as failed and added to this list
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE failAllDocsForRequest(
     p_allDocsTab        IN            docPayTabType,
     x_failedDocsTab     IN OUT NOCOPY docStatusTabType,
     x_docErrorTab       IN OUT NOCOPY docErrorTabType,
     x_errTokenTab       IN OUT NOCOPY trxnErrTokenTabType
     )
 IS

 l_module_name         CONSTANT VARCHAR2(200) := G_PKG_NAME ||
                                                     '.failAllDocsForRequest';

 l_invalidDocRec       docStatusRecType;
 l_already_failed_flag BOOLEAN      := FALSE;
 l_print_var           VARCHAR2(1)  := '';
 l_doc_err_rec         IBY_TRANSACTION_ERRORS%ROWTYPE;
 l_doc_token_tab       trxnErrTokenTabType;
 l_index               NUMBER := 0;
 l_triggering_doc      IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     /*
      * We will be failing all successful documents in the
      * request because at least one document in the request
      * has failed, and the rejection level is set to 'REQUEST'.
      *
      * When failing the successful docs, we need to refer to
      * the triggering doc in the error message. The triggering
      * doc can be any failed document in the failed documents
      * list.
      */
     IF (x_failedDocsTab.COUNT <> 0) THEN

         l_index := x_failedDocsTab.FIRST;
         l_triggering_doc := x_failedDocsTab(l_index).doc_id;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Triggering doc id: '
	             || l_triggering_doc);

         END IF;
     END IF;

     /*
      * Loop through all the documents for this request,
      * failing any documents that have not been already
      * failed.
      */
     FOR j in p_allDocsTab.FIRST .. p_allDocsTab.LAST LOOP

         /*
          * Check if this doc has already failed and
          * been stored in the error docs list. If
          * it has already been failed, skip it.
          */
         l_already_failed_flag :=
             checkIfDocFailed(p_allDocsTab(j).doc_id,
                 x_failedDocsTab);

         IF (l_already_failed_flag = FALSE) THEN
             /*
              * Add this document to list of docs
              * failed because of same payee
              */
             l_invalidDocRec.doc_id :=
                 p_allDocsTab(j).doc_id;
             l_invalidDocRec.pmt_grp_num :=
                 p_allDocsTab(j).pmt_grp_num;
             l_invalidDocRec.payee_id :=
                 p_allDocsTab(j).payee_id;
             l_invalidDocRec.doc_status :=
                 DOC_STATUS_FAIL_BY_REJLVL;

             x_failedDocsTab(
                x_failedDocsTab.COUNT + 1) :=
                     l_invalidDocRec;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Failing doc '
	                 || p_allDocsTab(j).doc_id
	                 || ' because all docs in request must be failed.'
	                 );

             END IF;
             /*
              * Once we fail a doc, we must add a corresponding
              * error message to the error table.
              */
             IBY_BUILD_UTILS_PKG.createErrorRecord(
                 TRXN_TYPE_DOC,
                 p_allDocsTab(j).doc_id,
                 l_invalidDocRec.doc_status,
                 p_allDocsTab(j).ca_id,
                 p_allDocsTab(j).ca_doc_id1,
                 p_allDocsTab(j).ca_doc_id2,
                 p_allDocsTab(j).ca_doc_id3,
                 p_allDocsTab(j).ca_doc_id4,
                 p_allDocsTab(j).ca_doc_id5,
                 p_allDocsTab(j).pp_tt_cd,
                 l_doc_err_rec,
                 x_errTokenTab,
                 l_triggering_doc
                 );

             insertIntoErrorTable(l_doc_err_rec, x_docErrorTab,
                 x_errTokenTab);

         END IF; -- not already failed

     END LOOP; -- for each doc in request

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END failAllDocsForRequest;
/*--------------------------------------------------------------------
 | NAME:
 |     getXMLClob
 |
 | PURPOSE:
 |     Performs a database query to get all failed documents for
 |     the given payment request. These failed documents are put
 |     into a XML structure and returned to the caller as a CLOB.
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 |
 *---------------------------------------------------------------------*/
 FUNCTION getXMLClob(
     p_payreq_id     IN VARCHAR2
     )
     RETURN CLOB
 IS
 l_module_name  CONSTANT VARCHAR2(200) := G_PKG_NAME || '.getXMLClob';
 l_xml_clob     CLOB := NULL;

 l_ctx          DBMS_XMLQuery.ctxType;
 l_sql          VARCHAR2(2000);
 l_sqlcode      NUMBER;
 l_sqlerrm      VARCHAR2(300);

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');
     END IF;
     /*
      * Select all docs that:
      * 1. Have the given pay req id
      * 2. Are not in 'documents_validated' status
      * 3. Were updated in the process of payment creation
      *    (some docs might have failed earlier in document
      *    validation flow. We don't want to pick them up).
      */
     l_sql := 'SELECT calling_app_id, '
                  || 'calling_app_doc_unique_ref1, '
                  || 'calling_app_doc_unique_ref2, '
                  || 'calling_app_doc_unique_ref3, '
                  || 'calling_app_doc_unique_ref4, '
                  || 'calling_app_doc_unique_ref5, '
                  || 'pay_proc_trxn_type_code '
                  || 'FROM iby_docs_payable_all '
                  || 'WHERE payment_service_request_id = :payreq_id '
                  || 'AND  document_status <> :doc_status';

     l_ctx := DBMS_XMLQuery.newContext(l_sql);
     DBMS_XMLQuery.setBindValue(l_ctx, 'payreq_id', p_payreq_id);
     DBMS_XMLQuery.setBindValue(l_ctx, 'doc_status', DOC_STATUS_VALIDATED);
     DBMS_XMLQuery.useNullAttributeIndicator(l_ctx, TRUE);

     /* raise an exception if no rows were found */
     DBMS_XMLQuery.setRaiseException(l_ctx, TRUE);
     DBMS_XMLQuery.setRaiseNoRowsException(l_ctx, TRUE);
     DBMS_XMLQuery.propagateOriginalException(l_ctx, TRUE);

     l_xml_clob := DBMS_XMLQuery.getXML(l_ctx);
     DBMS_XMLQuery.closeContext(l_ctx);

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
     RETURN l_xml_clob;

 EXCEPTION

     WHEN OTHERS THEN
         DBMS_XMLQuery.getExceptionContent(l_ctx, l_sqlcode, l_sqlerrm);
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'SQL code: '   || l_sqlcode);
	         print_debuginfo(l_module_name, 'SQL err msg: '|| l_sqlerrm);

         END IF;
         /*
          * Do not raise exception if no rows found.
          * It means all docs are valid.
          * Return NULL clob to caller.
          *
          * 1403 = NO_DATA_FOUND
          *
          * Note: We are unable to explicitly catch the
          * NO_DATA_FOUND exception here because the caller
          * raises some other exception. So we have to check
          * value of the original error code instead.
          */
         IF (l_sqlcode = 1403) THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'No rows were returned for query;'
	                 || ' Returning null xml clob.');
             END IF;
             RETURN NULL;
         END IF;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Fatal: Exception when attempting '
	             || 'to raise business event.', FND_LOG.LEVEL_UNEXPECTED);
	         print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE,
	             FND_LOG.LEVEL_UNEXPECTED);
	         print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM,
	             FND_LOG.LEVEL_UNEXPECTED);

         END IF;
         /*
          * Propogate exception to caller.
          */
         RAISE;

 END getXMLClob;

/*--------------------------------------------------------------------
 | NAME:
 |     getRejectedDocs
 |
 | PURPOSE:
 |     Performs a database query to get all failed documents for
 |     the given payment request. These failed documents are put
 |     into data structure and returned to the caller.
 |
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 |
 *---------------------------------------------------------------------*/
 PROCEDURE getRejectedDocs(
     p_payreq_id    IN VARCHAR2,
     x_docIDTab     IN OUT NOCOPY IBY_DISBURSE_UI_API_PUB_PKG.docPayIDTab,
     x_docStatusTab IN OUT NOCOPY IBY_DISBURSE_UI_API_PUB_PKG.docPayStatusTab
     )
 IS
 l_module_name  CONSTANT VARCHAR2(200) := G_PKG_NAME || '.getRejectedDocs';
 l_rej_docs_list rejectedDocTabType;

 /*
  * Cursor to get list of failed documents for a payment service
  * request.
  */
 CURSOR c_rejected_docs (p_payreq_id IBY_PAY_SERVICE_REQUESTS.
                                         payment_service_request_id%TYPE)
 IS
 SELECT
     doc.document_payable_id,
     doc.document_status
 FROM
     IBY_DOCS_PAYABLE_ALL doc
 WHERE
     doc.payment_service_request_id = p_payreq_id AND
     doc.document_status <> DOC_STATUS_VALIDATED
 ;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     /*
      * Pick up all rejected documents for this payment request.
      */
     OPEN  c_rejected_docs(p_payreq_id);
     FETCH c_rejected_docs BULK COLLECT INTO l_rej_docs_list;
     CLOSE c_rejected_docs;

     /*
      * Separate out the document ids and the document statuses.
      * This is because the rejection API expects these as
      * separate arrays.
      */
     IF (l_rej_docs_list.COUNT > 0) THEN

         FOR i IN l_rej_docs_list.FIRST .. l_rej_docs_list.LAST LOOP
             x_docIDTab(i) := l_rej_docs_list(i).doc_id;
         END LOOP;

         FOR i IN l_rej_docs_list.FIRST .. l_rej_docs_list.LAST LOOP
             x_docStatusTab(i) := l_rej_docs_list(i).doc_status;
         END LOOP;

     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END getRejectedDocs;

/*--------------------------------------------------------------------
 | NAME:
 |     checkIfDocFailed
 |
 | PURPOSE:
 |     Checks if a given document exists within a list of given
 |     failed documents.
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 |
 *---------------------------------------------------------------------*/
 FUNCTION checkIfDocFailed(
     p_doc_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE,
     p_failedDocsTab IN docStatusTabType
     )
     RETURN BOOLEAN
 IS
 l_return_flag  BOOLEAN        := FALSE;
 l_module_name  CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.checkIfDocFailed';
 l_print_var    VARCHAR2(50)   := 'false';

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     /*
      * If error documents table is empty, return false
      */
     IF (p_failedDocsTab.COUNT = 0) THEN

         l_return_flag := FALSE;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning false as '
	             || 'error docs list is empty');
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         return l_return_flag;

     END IF;

     /*
      * If the given document exists in the list of
      * failed documents, it means that this document
      * has been failed.
      */
     FOR i in p_failedDocsTab.FIRST .. p_failedDocsTab.LAST LOOP

         IF (p_failedDocsTab(i).doc_id = p_doc_id) THEN
             l_return_flag := TRUE;
             EXIT;
         END IF;

     END LOOP;

     IF (l_return_flag = TRUE) THEN
         l_print_var := 'true';
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Returning flag as '
	         || l_print_var
	         || ' for document '
	         || p_doc_id);

	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
     return l_return_flag;

 END checkIfDocFailed;

/*--------------------------------------------------------------------
 | NAME:
 |     checkIfAllDocsFailed
 |
 | PURPOSE:
 |     Checks if all documents of the payment request have failed.
 |     All documents have failed if each and every document within
 |     the payment request is found to exist in the list of invalid
 |     documents.
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 |
 *---------------------------------------------------------------------*/
 FUNCTION checkIfAllDocsFailed(
     p_allDocsTab    IN docPayTabType,
     p_failedDocsTab IN docStatusTabType
     )
     RETURN BOOLEAN
 IS
 l_return_flag  BOOLEAN        := TRUE;
 l_check_flag   BOOLEAN        := FALSE;
 l_module_name  CONSTANT VARCHAR2(200) := G_PKG_NAME || '.checkIfAllDocsFailed';
 l_print_var    VARCHAR2(50)   := 'false';

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     /*
      * If error documents table is empty, return false
      */
     IF (p_failedDocsTab.COUNT = 0) THEN

         l_return_flag := FALSE;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning false as '
	             || ' error docs list is empty');
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         return l_return_flag;

     END IF;

     /*
      * If provided documents table is empty, return true
      */
     IF (p_allDocsTab.COUNT = 0) THEN

         l_return_flag := TRUE;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning true as '
	             || ' empty docs list has been provided');
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         return l_return_flag;

     END IF;

     /*
      * Loop through all the documents in the request, checking
      * if doc has failed. If even a single doc has not failed,
      * we can return immediately that not all docs have failed
      */
     FOR i in p_allDocsTab.FIRST .. p_allDocsTab.LAST LOOP

         l_check_flag := checkIfDocFailed(p_allDocsTab(i).doc_id,
                             p_failedDocsTab);

         IF (l_check_flag = FALSE) THEN
             l_return_flag := FALSE;
             EXIT;
         END IF;

     END LOOP;

     IF (l_return_flag = TRUE) THEN
         l_print_var := 'true';
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Returning flag as '
	         || l_print_var);

	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
     return l_return_flag;

 END checkIfAllDocsFailed;

/*--------------------------------------------------------------------
 | NAME:
 |     getDocRejLevelSysOption
 |
 | PURPOSE:
 |     Gets the document rejection level system option.
 |
 |     Possible values are:
 |     REQUEST | DOCUMENT | PAYEE | NONE
 |
 |     The handling of document validation failures is dependent
 |     upon the rejection level setting.
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
 FUNCTION getDocRejLevelSysOption RETURN VARCHAR2
 IS
 l_rejLevel        VARCHAR2(200);
 l_sys_options_tab sysOptionsTabType;
 l_module_name     CONSTANT VARCHAR2(200) := G_PKG_NAME ||
                                                 '.getDocRejLevelSysOption';
 l_print_var       NUMBER        := -1;

 CURSOR c_sys_options
 IS
 SELECT
     sysoptions.document_rejection_level_code
 FROM
     IBY_INTERNAL_PAYERS_ALL sysoptions
 WHERE
     sysoptions.org_id IS NULL
 ;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     /*
      * Fetch the system options for the given org
      */
     OPEN  c_sys_options;
     FETCH c_sys_options BULK COLLECT INTO l_sys_options_tab;
     CLOSE c_sys_options;

     IF (l_sys_options_tab.COUNT = 0) THEN

         /*
          * This means that the document rejection level
          * is not set at the enterprise level.
          *
          * Enterprise level rejection levels (i.e., with org
          * id set to null) are expected to be seeded.
          *
          * Raise an exception and abort processing.
          */
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Document rejection level '
	             || 'system option is not set at '
	             || 'enterprise level. It is mandatory to '
	             || 'setup rejection levels at enterprise level. '
	             || 'Raising exception.. ',
	             FND_LOG.LEVEL_UNEXPECTED
	             );

         END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;

     ELSIF (l_sys_options_tab.COUNT <> 1) THEN

         /*
          * This means that there are multiple document
          * rejection levels set at the enterprise level.
          * We don't know which one to use.
          *
          * Raise an exception and abort processing.
          */
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Multiple document rejection '
	             || 'level system options are set at '
	             || 'enterprise level. It is mandatory to '
	             || 'setup only one document rejection level '
	             || 'at enterprise level. '
	             || 'Raising exception.. ',
	             FND_LOG.LEVEL_UNEXPECTED
	             );

         END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;

     ELSE

         /*
          * Return the retrieved enterprise level
          * document rejection level system option.
          */
         l_rejLevel := l_sys_options_tab(1).rej_level;

     END IF; -- if l_sys_options_tab.COUNT = 0

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Returning rejection level: '
	         || l_rejLevel);

	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
     RETURN l_rejLevel;

     EXCEPTION
         WHEN OTHERS THEN

             /*
              * In case of an exception, return NULL
              */
             l_rejLevel := NULL;
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'No document rejection level '
	                 || 'set up at enterprise level. '
	                 || 'Returning NULL.');

	             print_debuginfo(l_module_name, 'EXIT');
             END IF;
             RETURN l_rejLevel;

 END getDocRejLevelSysOption;

/*--------------------------------------------------------------------
 | NAME:
 |     validateProfileFromProfDrivers
 |
 | PURPOSE:
 |     Checks if the given payment profile is valid for the given
 |     (payment method, org, payment currency, internal
 |     bank account) combination on the document.
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 |
 *---------------------------------------------------------------------*/
 FUNCTION validateProfileFromProfDrivers(
     p_profile_id        IN IBY_DOCS_PAYABLE_ALL.payment_profile_id%TYPE,
     p_org_id            IN IBY_DOCS_PAYABLE_ALL.org_id%TYPE,
     p_org_type          IN IBY_DOCS_PAYABLE_ALL.org_type%TYPE,
     p_pmt_method_cd     IN IBY_DOCS_PAYABLE_ALL.payment_method_code%TYPE,
     p_pmt_currency      IN IBY_DOCS_PAYABLE_ALL.payment_currency_code%TYPE,
     p_int_bank_acct_id  IN IBY_DOCS_PAYABLE_ALL.internal_bank_account_id%TYPE
     )
     RETURN BOOLEAN
 IS
 l_return_flag  BOOLEAN        := FALSE;
 l_module_name  CONSTANT VARCHAR2(200)
                               := G_PKG_NAME ||
                                      '.validateProfileFromProfDrivers';

 l_valid_flag     VARCHAR2(1);
 l_profile_id     IBY_DOCS_PAYABLE_ALL.payment_profile_id%TYPE;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

	     print_debuginfo(l_module_name, 'Provided parameters are: '
	         || 'Profile id: '
	         || p_profile_id
	         || ', org id: '
	         || p_org_id
	         || ', org type: '
	         || p_org_type
	         || ', payment method: '
	         || p_pmt_method_cd
	         || ', payment currency: '
	         || p_pmt_currency
	         || ', int bank acct id: '
	         || p_int_bank_acct_id
	         );

     END IF;
     /*
      * Get the list of all payment profiles that
      * match the given list of profile drivers.
      */
     l_profile_id := p_profile_id;
     IBY_BUILD_UTILS_PKG.getProfListFromProfileDrivers(
         p_pmt_method_cd,
         p_org_id,
         p_org_type,
         p_pmt_currency,
         p_int_bank_acct_id,
         l_profile_id,
         l_valid_flag);

     /*
      * If count is non-zero it means that at least one
      * profile matches the given set of drivers.
      *
      * Otherwise, it means that no profile matches the
      * given set of drivers; implying that the profile
      * on the document is invalid (so return FALSE).
      */
     IF (l_valid_flag = 'N') THEN

         l_return_flag := FALSE;

     ELSE

                 l_return_flag := TRUE;

     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
     RETURN l_return_flag;

 END validateProfileFromProfDrivers;

/*--------------------------------------------------------------------
 | NAME:
 |     checkProfileFormatCompat
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
 FUNCTION checkProfileFormatCompat(
     p_doc_id            IN IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE,
     p_payee_id          IN IBY_DOCS_PAYABLE_ALL.ext_payee_id%TYPE,
     p_profile_id        IN IBY_DOCS_PAYABLE_ALL.payment_profile_id%TYPE
     ) RETURN BOOLEAN
 IS
 l_return_flag  BOOLEAN;
 l_module_name  CONSTANT VARCHAR2(200)
                               := G_PKG_NAME || '.checkProfileFormatCompat';

 l_payee_id         IBY_EXTERNAL_PAYEES_ALL.ext_payee_id%TYPE;
 l_payee_format_cd  IBY_EXTERNAL_PAYEES_ALL.payment_format_code%TYPE;

 l_payment_profile_id     IBY_PAYMENT_PROFILES.payment_profile_id%TYPE;
 l_prof_pmt_format_cd     IBY_PAYMENT_PROFILES.payment_format_code%TYPE;
 l_bepid                  IBY_PAYMENT_PROFILES.bepid%TYPE;
 l_transmit_protocol_cd   IBY_PAYMENT_PROFILES.transmit_protocol_code%TYPE;


 BEGIN

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name, 'ENTER');

      END IF;
     l_return_flag := FALSE;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Validating profile-format '
	         || 'compatibility for document '
	         || p_doc_id
	         );


     END IF;
     IF (p_profile_id IS NULL OR p_profile_id = -1) THEN

         l_return_flag := TRUE;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Profile id not '
	             || 'available. Cannot validate. Returning success.'
	             );

	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN l_return_flag;

     END IF;


     IF (p_payee_id IS NULL OR p_payee_id = -1) THEN

         l_return_flag := TRUE;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Payee id not '
	             || 'available. Cannot validate. Returning success.'
	             );

	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN l_return_flag;

     END IF;

     /*
      * Pick up the default format for the payee on the
      * document.
      */
     /* Initialize */
     l_payee_format_cd := NULL;

         IF (l_payee_format_tab.EXISTS(p_payee_id)) THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Getting the data from Cache For Payee Id: ' || p_payee_id);
         END IF;
            l_payee_format_cd := l_payee_format_tab(p_payee_id).payment_format_cd;
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Format: '
	                 || l_payee_format_cd
	                 || ' linked to payee '
	                 || p_payee_id);
             END IF;
         ELSE
            BEGIN
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	            print_debuginfo(l_module_name, 'Getting the data from DB For Payee Id: ' || p_payee_id);
            END IF;
                 SELECT payee.ext_payee_id, payee.payment_format_code
                 INTO l_payee_id, l_payee_format_cd
                 FROM IBY_EXTERNAL_PAYEES_ALL payee
                 WHERE payee.ext_payee_id = p_payee_id;


            EXCEPTION
                      WHEN NO_DATA_FOUND THEN

                        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                        print_debuginfo(l_module_name, 'Exception No Data Found For Payee Id: ' || p_payee_id);
                        END IF;
                        l_payee_id := null;
                        l_payee_format_cd := null;
            END;
            l_payee_format_tab(p_payee_id).payee_id := l_payee_id;
            l_payee_format_tab(p_payee_id).payment_format_cd := l_payee_format_cd;
         END IF;


     IF (l_payee_format_cd IS NULL) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'No format was found '
	             || 'linked to payee '
	             || p_payee_id
	             );

         END IF;
         l_return_flag := TRUE;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Format cd not '
	             || 'available. Cannot validate. Returning success.'
	             );

	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN l_return_flag;

     END IF;

     /*
      * Check if the format on the payee matches the format
      * on the profiles that are set up.
      */
    l_return_flag := FALSE;

    IF (l_profile_format_tab.EXISTS(p_profile_id) ) THEN
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo(l_module_name, 'Getting the value from Cache Structure for profile id: ' || p_profile_id);
    END IF;
         IF (l_profile_format_tab(p_profile_id).payment_format_cd  = l_payee_format_cd)
         THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Profile: '
	                 || p_profile_id
	                 || ' is compatible with format '
	                 || l_payee_format_cd);

         END IF;
             l_return_flag := TRUE;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'EXIT');
             END IF;
         END IF;
             RETURN l_return_flag;

    ELSE

         BEGIN
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	           print_debuginfo(l_module_name, 'Getting the value from DB for profile id: ' || p_profile_id);
           END IF;
           SELECT
           ipp.payment_profile_id, ipp.payment_format_code,ipp.bepid, ipp.transmit_protocol_code
           INTO l_payment_profile_id,l_prof_pmt_format_cd,l_bepid,l_transmit_protocol_cd
           FROM IBY_PAYMENT_PROFILES ipp
           WHERE ipp.payment_profile_id = p_profile_id ;

          EXCEPTION
                      WHEN NO_DATA_FOUND THEN

                        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                        print_debuginfo(l_module_name, 'Exception No Data Found For Profile Id: ' || p_profile_id);
                        END IF;
                        l_payment_profile_id := null;
                        l_prof_pmt_format_cd := null;
                        l_bepid := null;
                        l_transmit_protocol_cd := null;
          END;
          l_profile_format_tab(p_profile_id).profile_id  := l_payment_profile_id;
          l_profile_format_tab(p_profile_id).payment_format_cd  := l_prof_pmt_format_cd;
          l_profile_format_tab(p_profile_id).bepid  := l_bepid;
          l_profile_format_tab(p_profile_id).transmit_protocol_cd  := l_transmit_protocol_cd;

           IF (l_profile_format_tab(p_profile_id).payment_format_cd  = l_payee_format_cd)
           THEN
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	           print_debuginfo(l_module_name, 'Profile: '
	                     || p_profile_id
	                     || ' is compatible with format '
	                     || l_payee_format_cd);

           END IF;
                 l_return_flag := TRUE;

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'EXIT');
                 END IF;
           END IF;

                 RETURN l_return_flag;
    END IF;

     /*
      * If we reached here, it means that no profile was
      * found matching the given format. This is an error.
      * Return validation failure result.
      */
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'No profiles matched format '
	         || l_payee_format_cd
	         || ' for document '
	         || p_doc_id
	         || '. Profile '
	         || p_profile_id
	         || ' and format '
	         || l_payee_format_cd
	         || ' are not compatible.'
	         );

     END IF;
     l_return_flag := TRUE;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
     RETURN l_return_flag;

 END checkProfileFormatCompat;






END IBY_VALIDATIONSETS_PUB;

/
