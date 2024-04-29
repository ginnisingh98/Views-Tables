--------------------------------------------------------
--  DDL for Package Body IBY_DISBURSE_SUBMIT_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_DISBURSE_SUBMIT_PUB_PKG" AS
/*$Header: ibybildb.pls 120.79.12010000.22 2010/04/15 10:31:37 asarada ship $*/

 --
 -- Declare global variables
 --
 G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBY_DISBURSE_SUBMIT_PUB_PKG';
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
 REQ_STATUS_PEN_REV_DOC_VAL CONSTANT VARCHAR2(100) :=
                                         'PENDING_REVIEW_DOC_VAL_ERRORS';
 REQ_STATUS_PEN_REV_PMT_VAL CONSTANT VARCHAR2(100) :=
                                       'PENDING_REVIEW_PMT_VAL_ERRORS';
 REQ_STATUS_RETRY_PMT_CREAT CONSTANT VARCHAR2(100) := 'RETRY_PAYMENT_CREATION';
 REQ_STATUS_PMT_CRTD        CONSTANT VARCHAR2(100) := 'PAYMENTS_CREATED';
 REQ_STATUS_USER_REVW       CONSTANT VARCHAR2(100) := 'PENDING_REVIEW';
 REQ_STATUS_BUILD_ERROR     CONSTANT VARCHAR2(100) := 'BUILD_ERROR';

 --
 -- List of instruction statuses that are used / set in this
 -- module.
 --
 INS_STATUS_CREATED         CONSTANT VARCHAR2(100) := 'CREATED';

 --
 -- List of payment statuses that are used / set in this
 -- module.
 --
 PAY_STATUS_CREATED      CONSTANT VARCHAR2(100) := 'CREATED';
 PAY_STATUS_MOD_BNK_ACC  CONSTANT VARCHAR2(100) :=
     'MODIFIED_PAYEE_BANK_ACCOUNT';
 PAY_STATUS_MODIFIED     CONSTANT VARCHAR2(100) := 'MODIFIED';

 --
 -- List of document statuses that are used / set in this
 -- module.
 --
 DOC_STATUS_SUBMITTED    CONSTANT VARCHAR2(100) := 'SUBMITTED';
 DOC_STATUS_VALIDATED    CONSTANT VARCHAR2(100) := 'VALIDATED';
 DOC_STATUS_RDY_FOR_VAL  CONSTANT VARCHAR2(100) := 'READY_FOR_VALIDATION';
 DOC_STATUS_FAILED_VAL   CONSTANT VARCHAR2(100) := 'FAILED_VALIDATION';


 TYPE payee_id_tbl_type is table of NUMBER index by VARCHAR2(200);
 l_payee_id_tbl       payee_id_tbl_type;
   G_CURRENT_RUNTIME_LEVEL      CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   G_LEVEL_UNEXPECTED           CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
   G_LEVEL_ERROR                CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
   G_LEVEL_EXCEPTION            CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
   G_LEVEL_EVENT                CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
   G_LEVEL_PROCEDURE            CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
   G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;

/*--------------------------------------------------------------------
 | NAME:
 |     submit_payment_process_request
 |
 | PURPOSE:
 |     This is the top level procedure of the build program; This
 |     procedure will run as a concurrent program.
 |
 | PARAMETERS:
 |    IN
 |
 |    p_calling_app_id
 |         The 3-character product code of the calling application
 |         (e.g., '200' for Oracle Payables).
 |
 |    p_calling_app_payreq_cd
 |         Id of the payment service request from the calling app's
 |         point of view. For a given calling app, this id should be
 |         unique; the build program will communicate back to the calling
 |         app using this payment request id.
 |
 |    p_internal_bank_account_id
 |        The internal bank account to pay from. Normally, the
 |        internal bank account is a document level attribute.
 |        If provided, all the documents payable of this payment
 |        service request will be assigned with this internal bank
 |        account by default. Note that if the document payable already
 |        had an internal bank account, the request level internal bank
 |        account will be used to overwrite it.
 |
 |    p_payment_profile_id
 |        Payment profile for this payment request. Normally, the
 |        payment profile is a document level attribute. If provided
 |        at the request level, then all the documents payable of
 |        this payment service request will be assigned with this
 |        payment profile (regardless of whether the documents already
 |        have their own profiles).
 |
 |    p_allow_zero_payments_flag
 |        'Y' / 'N' flag indicating whether zero value payments are allowed.
 |        If not set, this value will be defaulted to 'N'. This value
 |        will be used in validating the documents payable of this request.
 |
 |    p_maximum_payment_amount
 |        Maximum allowed amount for a payment created from the documents
 |        payable of this request. Payments will be validated against this
 |        ceiling.
 |
 |    p_minimum_payment_amount
 |        Minimum allowed amount for payment created from the documents
 |        payable of this request. Payments will be validated against this
 |        floor.
 |
 |    p_document_rejection_level
 |        Document rejection level system option. The value of this system
 |        option determines how validation failures at the document level
 |        are handled. For example, if a single document fails for the
 |        request, then all the other documents of the request will be
 |        automatically failed if the rejection level is set to 'REQUEST'.
 |
 |    p_payment_rejection_level
 |        Payment rejection level system option. The value of this system
 |        option determines how validation failures at the payment level
 |        are handled. For example, if a single payment fails validation
 |        then all the payments of the request will be automatically
 |        failed if the rejection level is set to 'REQUEST'.
 |
 |    p_review_proposed_pmts_flag
 |        Review proposed payments flag. After payments are created, they
 |        could be automatically picked by the PICP and put into payment
 |        instructions. In case the user wants to review the created payments
 |        first before they are allowed to be put into payment instructions,
 |        then this flag must be set to 'Y'.
 |
 |    p_create_instrs_flag
 |        'Y' / 'N' flag indicating whether payment instruction creation
 |        should be invoked for this payment service request as soon the
 |        Build Program completes.
 |
 |    p_args13 - p_args100
 |        These 88 parameters are mandatory for any stored procedure
 |        that is submitted from Oracle Forms as a concurrent request
 |        (to get the total number of args to the concurrent procedure
 |         to 100).
 |
 | OUT
 |
 |    x_errbuf
 |    x_retcode
 |
 |        These two are mandatory output paramaters for a concurrent
 |        program. They will store the error message and error code
 |        to indicate a successful/failed run of the concurrent request.
 |
 | RETURNS:
 |
 | NOTES: 1. Introduced new procedure print_log.
 |           This will print messages to concurrent program logs.
 |           We intend to print only a very limited set to conc logs.
 |           Will print stages, return messages from validations and
 |           exceptions(error).
 *---------------------------------------------------------------------*/
 PROCEDURE submit_payment_process_request(
     x_errbuf                     OUT NOCOPY VARCHAR2,
     x_retcode                    OUT NOCOPY VARCHAR2,
     p_calling_app_id             IN         VARCHAR2,
     p_calling_app_payreq_cd      IN         VARCHAR2,
     p_internal_bank_account_id   IN         VARCHAR2 DEFAULT NULL,
     p_payment_profile_id         IN         VARCHAR2 DEFAULT NULL,
     p_allow_zero_payments_flag   IN         VARCHAR2 DEFAULT 'N',
     p_maximum_payment_amount     IN         VARCHAR2 DEFAULT NULL,
     p_minimum_payment_amount     IN         VARCHAR2 DEFAULT NULL,
     p_document_rejection_level   IN         VARCHAR2 DEFAULT NULL,
     p_payment_rejection_level    IN         VARCHAR2 DEFAULT NULL,
     p_review_proposed_pmts_flag  IN         VARCHAR2 DEFAULT 'X',
     p_create_instrs_flag         IN         VARCHAR2 DEFAULT 'N',
     p_payment_document_id        IN         VARCHAR2 DEFAULT NULL,
     p_attribute_category  IN VARCHAR2 DEFAULT NULL, p_attribute1  IN VARCHAR2 DEFAULT NULL,
     p_attribute2  IN VARCHAR2 DEFAULT NULL, p_attribute3  IN VARCHAR2 DEFAULT NULL,
     p_attribute4  IN VARCHAR2 DEFAULT NULL, p_attribute5  IN VARCHAR2 DEFAULT NULL,
     p_attribute6  IN VARCHAR2 DEFAULT NULL, p_attribute7  IN VARCHAR2 DEFAULT NULL,
     p_attribute8  IN VARCHAR2 DEFAULT NULL, p_attribute9  IN VARCHAR2 DEFAULT NULL,
     p_attribute10  IN VARCHAR2 DEFAULT NULL, p_attribute11  IN VARCHAR2 DEFAULT NULL,
     p_attribute12  IN VARCHAR2 DEFAULT NULL, p_attribute13  IN VARCHAR2 DEFAULT NULL,
     p_attribute14  IN VARCHAR2 DEFAULT NULL, p_attribute15  IN VARCHAR2 DEFAULT NULL,
     p_arg30  IN VARCHAR2 DEFAULT NULL, p_arg31  IN VARCHAR2 DEFAULT NULL,
     p_arg32  IN VARCHAR2 DEFAULT NULL, p_arg33  IN VARCHAR2 DEFAULT NULL,
     p_arg34  IN VARCHAR2 DEFAULT NULL, p_arg35  IN VARCHAR2 DEFAULT NULL,
     p_arg36  IN VARCHAR2 DEFAULT NULL, p_arg37  IN VARCHAR2 DEFAULT NULL,
     p_arg38  IN VARCHAR2 DEFAULT NULL, p_arg39  IN VARCHAR2 DEFAULT NULL,
     p_arg40  IN VARCHAR2 DEFAULT NULL, p_arg41  IN VARCHAR2 DEFAULT NULL,
     p_arg42  IN VARCHAR2 DEFAULT NULL, p_arg43  IN VARCHAR2 DEFAULT NULL,
     p_arg44  IN VARCHAR2 DEFAULT NULL, p_arg45  IN VARCHAR2 DEFAULT NULL,
     p_arg46  IN VARCHAR2 DEFAULT NULL, p_arg47  IN VARCHAR2 DEFAULT NULL,
     p_arg48  IN VARCHAR2 DEFAULT NULL, p_arg49  IN VARCHAR2 DEFAULT NULL,
     p_arg50  IN VARCHAR2 DEFAULT NULL, p_arg51  IN VARCHAR2 DEFAULT NULL,
     p_arg52  IN VARCHAR2 DEFAULT NULL, p_arg53  IN VARCHAR2 DEFAULT NULL,
     p_arg54  IN VARCHAR2 DEFAULT NULL, p_arg55  IN VARCHAR2 DEFAULT NULL,
     p_arg56  IN VARCHAR2 DEFAULT NULL, p_arg57  IN VARCHAR2 DEFAULT NULL,
     p_arg58  IN VARCHAR2 DEFAULT NULL, p_arg59  IN VARCHAR2 DEFAULT NULL,
     p_arg60  IN VARCHAR2 DEFAULT NULL, p_arg61  IN VARCHAR2 DEFAULT NULL,
     p_arg62  IN VARCHAR2 DEFAULT NULL, p_arg63  IN VARCHAR2 DEFAULT NULL,
     p_arg64  IN VARCHAR2 DEFAULT NULL, p_arg65  IN VARCHAR2 DEFAULT NULL,
     p_arg66  IN VARCHAR2 DEFAULT NULL, p_arg67  IN VARCHAR2 DEFAULT NULL,
     p_arg68  IN VARCHAR2 DEFAULT NULL, p_arg69  IN VARCHAR2 DEFAULT NULL,
     p_arg70  IN VARCHAR2 DEFAULT NULL, p_arg71  IN VARCHAR2 DEFAULT NULL,
     p_arg72  IN VARCHAR2 DEFAULT NULL, p_arg73  IN VARCHAR2 DEFAULT NULL,
     p_arg74  IN VARCHAR2 DEFAULT NULL, p_arg75  IN VARCHAR2 DEFAULT NULL,
     p_arg76  IN VARCHAR2 DEFAULT NULL, p_arg77  IN VARCHAR2 DEFAULT NULL,
     p_arg78  IN VARCHAR2 DEFAULT NULL, p_arg79  IN VARCHAR2 DEFAULT NULL,
     p_arg80  IN VARCHAR2 DEFAULT NULL, p_arg81  IN VARCHAR2 DEFAULT NULL,
     p_arg82  IN VARCHAR2 DEFAULT NULL, p_arg83  IN VARCHAR2 DEFAULT NULL,
     p_arg84  IN VARCHAR2 DEFAULT NULL, p_arg85  IN VARCHAR2 DEFAULT NULL,
     p_arg86  IN VARCHAR2 DEFAULT NULL, p_arg87  IN VARCHAR2 DEFAULT NULL,
     p_arg88  IN VARCHAR2 DEFAULT NULL, p_arg89  IN VARCHAR2 DEFAULT NULL,
     p_arg90  IN VARCHAR2 DEFAULT NULL, p_arg91  IN VARCHAR2 DEFAULT NULL,
     p_arg92  IN VARCHAR2 DEFAULT NULL, p_arg93  IN VARCHAR2 DEFAULT NULL,
     p_arg94  IN VARCHAR2 DEFAULT NULL, p_arg95  IN VARCHAR2 DEFAULT NULL,
     p_arg96  IN VARCHAR2 DEFAULT NULL, p_arg97  IN VARCHAR2 DEFAULT NULL,
     p_arg98  IN VARCHAR2 DEFAULT NULL, p_arg99  IN VARCHAR2 DEFAULT NULL,
     p_arg100 IN VARCHAR2 DEFAULT NULL
     )
 IS

 l_return_status   VARCHAR2 (100);
 l_return_message  VARCHAR2 (3000);
 l_ret_status      NUMBER;

 l_msg_count       NUMBER;
 l_msg_data        VARCHAR2(4000);

 l_payreq_status   VARCHAR2 (100);
 l_payreq_id       IBY_PAY_SERVICE_REQUESTS.payment_service_request_id%TYPE;
 l_req_id          IBY_PAY_SERVICE_REQUESTS.payment_service_request_id%TYPE;
 l_is_duplicate    BOOLEAN := TRUE;

 l_profile_attribs profileProcessAttribs;
 l_pmtInstrTab     IBY_PAYINSTR_PUB.pmtInstrTabType;

 l_profile_name    VARCHAR2(2000);
 l_flag            BOOLEAN := FALSE;

 /* hook related params */
 l_pkg_name       VARCHAR2(200);
 l_callout_name   VARCHAR2(500);
 l_stmt           VARCHAR2(1000);
 l_error_code     VARCHAR2(3000);
 l_api_version    CONSTANT NUMBER := 1.0;


 l_module_name     CONSTANT VARCHAR2(200) := G_PKG_NAME ||
                                       '.submit_payment_process_request';

 l_create_instrs_flag IBY_PAY_SERVICE_REQUESTS.
                          create_pmt_instructions_flag%TYPE;

 l_payment_doc_id     IBY_PAY_SERVICE_REQUESTS.payment_document_id%TYPE;

 /*
  * This flag indicates to the payment re-creation flow whether
  * payments were just created in the payment creation flow.
  *
  * If this flag is set to TRUE, the payment re-creation flow
  * will know that payments were just created, and so will not
  * attempt to re-create the payments.
  *
  * If this flag is set to FALSE, the payment re-creation flow
  * will know that the user has created the payments in a previous
  * run, has reviewed them and is now attempting to move the payments
  * forward in the process. In this case, the re-creation flow will
  * process the payments.
  */
 l_pmt_current_session_flag BOOLEAN := FALSE;

 /*
  * This flag indicates to the document re-validation flow
  * whether documents were just validated.
  *
  * If documents were just validated, the re-validation
  * flow should not be triggered.
  */
 l_doc_current_session_flag BOOLEAN := FALSE;

 /*
  * Flag that indicates whether payment creation
  * should be re-tried.
  */
 l_do_retry_flag BOOLEAN := FALSE;

 /*
  * Bug 8924569 Phase1 Solution
  *
 l_distinct_ppp_count NUMBER;
 l_distinct_ppp NUMBER;
  */

 /*
  * Bug 8924569 Phase2 Solution
  */
  l_payment_profile_id NUMBER;

  CURSOR get_distinct_ppps(l_payrequest_id NUMBER) IS
   SELECT DISTINCT payment_profile_id
    FROM iby_docs_payable_all
    WHERE payment_service_request_id = l_payrequest_id;

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


  -- To track concurrent request id's ::
  IF nvl(fnd_global.CONC_REQUEST_ID,-99) > 0
  THEN
    -- If exists a valid value print in the concurrent log
    print_log(l_module_name, 'Enter Build :: Concurrent Request ID::'||fnd_global.CONC_REQUEST_ID);
  ELSE
    -- Otherwise print in debug table.
    IF (6 >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
       -- CONDITION Will always be true.
       fnd_log.string(6,l_module_name,'Enter Build :: Concurrent Request ID::'||fnd_global.CONC_REQUEST_ID);
    END IF;
  END IF;




     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

	     print_debuginfo(l_module_name, 'Calling app id: ' || p_calling_app_id);
	     print_debuginfo(l_module_name, 'Calling app pay req cd: '
	         || p_calling_app_payreq_cd);

     END IF;
     /*
      * Check if parameters are correctly provided.
      */
     IF (UPPER(p_create_instrs_flag) = 'Y') THEN

         /*
          * Payment profile is mandatory if 'create instructions'
          * flag is set to 'Y'.
          */
         IF (p_payment_profile_id IS NULL) THEN

	     /*
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Payment profile '
	                 || 'is mandatory if ''create instructions flag'' is '
	                 || 'set to ''Y''.'
	                 );

	             print_debuginfo(l_module_name, 'Payment service request '
	                 || 'cannot be processed further. '
	                 || 'Exiting build program.');

             END IF;
             x_errbuf := 'BUILD PROGRAM ERROR - PARAMETERS INVALID';
             x_retcode := '-1';

             FND_MESSAGE.SET_NAME('IBY', 'IBY_BUILD_INV_PARAMS');
             FND_MSG_PUB.ADD;

             FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'EXIT');

             END IF;
             RETURN;*/

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		print_debuginfo(l_module_name, 'Payment profile submission considered optional after bug 8781032');
             END IF;

         ELSE

         /*
          * Get the default processing related attributes
          * from the payment process profile.
          *
          * We need this to know the processing type of the
          * profile (needed for creating payment instructions).
          */
         get_profile_process_attribs(
             p_payment_profile_id,
             l_profile_attribs
             );

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Profile ' || p_payment_profile_id
	             || ' has processing type '
	             || l_profile_attribs.processing_type
	             );

         END IF;
         /*
          * If p_create_instrs_flag = 'Y', it means that the PICP
          * has to be invoked synchronously by the Build Program.
          *
          * In this case, either the payment document should be provided
          * as an input param, or, a default payment document should
          * be available on the profile.
          *
          * If both of these conditions are not met, fail the payment
          * service request.
          */

         /*
          * Fix for bug 4948884:
          * Skip this check for ELECTRONIC processing type.
          */
         IF (l_profile_attribs.processing_type <> 'ELECTRONIC') THEN

             IF (p_payment_document_id IS NULL) THEN

                 /*
                  * Check if a default payment document is associated with
                  * the provided profile. If not, we cannot create payment
                  * instructions automatically for this request.
                  */
                 checkIfDefaultPmtDocOnProfile (
                     p_payment_profile_id,
                     l_profile_name,
                     l_flag
                     );

                 IF (l_flag = FALSE) THEN


	                     print_log(l_module_name, 'Payment profile '
	                         || p_payment_profile_id
	                         || ' with name '
	                         || l_profile_name
	                         || ' cannot be used when automatically '
	                         || 'creating payment instructions because '
	                         || 'it has no default payment document.'
	                         );

	                     print_log(l_module_name, 'RESOLUTION: Either '
	                         || 'provide the payment document id explicitly '
	                         || '(input param to build program), or, associate '
	                         || 'a default payment document id with the profile '
	                         || 'used.'
	                         );

	                     print_log(l_module_name, 'Payment service request '
	                         || 'cannot be processed further. '
	                         || 'Exiting build program.');

                     x_errbuf := 'BUILD PROGRAM ERROR - PARAMETERS INVALID';
                     x_retcode := '-1';

                     FND_MESSAGE.SET_NAME('IBY',
                         'IBY_BUILD_NO_DEFAULT_PMT_DOC');

                     FND_MESSAGE.SET_TOKEN('PROF_NAME',
                         l_profile_name,
                         FALSE);

                     FND_MSG_PUB.ADD;

                     FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

                     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                     print_debuginfo(l_module_name, 'EXIT');

                     END IF;
                     RETURN;

                 END IF;

             ELSE

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Payment document id '
	                     || p_payment_document_id
	                     || ' has been provided as an input param. Skipping '
	                     || 'check for default payment doc on profile.'
	                     );

                 END IF;
             END IF; -- if p_payment_document_id is null

         END IF; -- if processing type is not 'electronic'

       END IF; -- payment profile NULL bug 8781032

     END IF; -- if p_create_instrs_flag = 'Y'


     /*
      * If payment document id is provided at request level,
      * ensure that the user has provided both the payment profile
      * and the internal bank account at the request level also.
      */
     IF (p_payment_document_id IS NOT NULL) THEN

         IF (p_payment_profile_id       IS NULL  OR
             p_internal_bank_account_id IS NULL) THEN


	             print_log(l_module_name, 'Error: Payment document id '
	                 || p_payment_document_id
	                 || ' provided at request level. You must provide '
	                 || '*both* payment profile and internal bank account '
	                 || 'at request level, if you provide payment document id.'
	                 );

	             print_log(l_module_name, 'RESOLUTION: Provide '
	                 || 'both the payment profile id and the internal '
	                 || 'bank account id as input params to build program '
	                 || '(if you provide the payment document id as an '
	                 || 'input param).'
	                 );

	             print_log(l_module_name, 'Payment service request '
	                 || 'cannot be processed further. '
	                 || 'Exiting build program.');


             x_errbuf := 'BUILD PROGRAM ERROR - PARAMETERS INVALID';
             x_retcode := '-1';

             FND_MESSAGE.SET_NAME('IBY',
                 'IBY_BUILD_MISS_PMT_DOC_REL_PAR');

             FND_MSG_PUB.ADD;

             FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'EXIT');

             END IF;
             RETURN;

         END IF;

     END IF;

  	     print_log(l_module_name, '+-----------------------------------------------------------------------------------------------------+');
	     print_log(l_module_name, '|STEP 1: Insert Payment Service Request:: Timestamp:'||systimestamp ||'|');
	     print_log(l_module_name, '+-----------------------------------------------------------------------------------------------------+');

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
         l_payreq_id := checkIfDuplicate(p_calling_app_id,
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
                                p_payment_profile_id,
                                p_allow_zero_payments_flag,
                                p_maximum_payment_amount,
                                p_minimum_payment_amount,
                                p_document_rejection_level,
                                p_payment_rejection_level,
                                p_review_proposed_pmts_flag,
                                p_create_instrs_flag,
                                p_payment_document_id,
                                p_attribute_category,
                                p_attribute1,
                                p_attribute2,
                                p_attribute3,
                                p_attribute4,
                                p_attribute5,
                                p_attribute6,
                                p_attribute7,
                                p_attribute8,
                                p_attribute9,
                                p_attribute10,
                                p_attribute11,
                                p_attribute12,
                                p_attribute13,
                                p_attribute14,
                                p_attribute15
                                );

             IF (l_payreq_id = -1) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Could not insert payment '
	                     || 'service request for calling app id '
	                     || p_calling_app_id
	                     || ', calling app payment service request cd '
	                     || p_calling_app_payreq_cd
	                     );

	                 print_debuginfo(l_module_name, 'Payment service request '
	                     || 'cannot be processed further. '
	                     || 'Exiting build program.');

                 END IF;
                 /*
                  * Rollback any DB changes and exit.
                  */
                 ROLLBACK;

                 x_errbuf := 'BUILD PROGRAM ERROR - CANNOT INSERT '
                     || 'PAYMENT SERVICE REQUEST';
                 x_retcode := '-1';

                 FND_MESSAGE.SET_NAME('IBY', 'IBY_BUILD_REQ_INSERT_ERROR');
                 FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

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
	                      || 'inserted successfully into the database. '
	                      || 'Payment request id: '
	                      || l_payreq_id);

                  END IF;
                  COMMIT;

             END IF;

         ELSE
             -- Introducing new log messages
                print_log(l_module_name, 'Payment service '
	                     || 'request '
	                     || p_calling_app_payreq_cd
	                     || ' is a duplicate. Skipping insert of request '
	                     );

         END IF; -- if not duplicate

     END;


	     print_log(l_module_name, '+----------------------------------------------------------------------------------------------------+');
	     print_log(l_module_name, '|STEP 2: Insert Documents :Timestamp:'||systimestamp ||'|');
	     print_log(l_module_name, '+----------------------------------------------------------------------------------------------------+');


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
             l_payreq_status := get_payreq_status(l_payreq_id);

             IF (l_payreq_status = REQ_STATUS_INSERTED) THEN

--ebs_pga_mem('Before insert_payreq_documents');

                 l_ret_status := insert_payreq_documents(p_calling_app_id,
                                     p_calling_app_payreq_cd,
                                     l_payreq_id
                                     );

--ebs_pga_mem('After insert_payreq_documents');

                 IF (l_ret_status = -1) THEN

                     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                     print_debuginfo(l_module_name, 'Could not insert '
	                         || 'documents payable for payment service '
	                         || 'request. Calling app id '
	                         || p_calling_app_id
	                         || ', calling app payment service request cd '
	                         || p_calling_app_payreq_cd
	                         );

	                     print_debuginfo(l_module_name, 'Payment service '
	                          || 'request cannot be processed further. '
	                          || 'Exiting build program.');

                     END IF;
                     /*
                      * Rollback any DB changes and exit.
                      */
                     ROLLBACK;

                     x_errbuf := 'BUILD PROGRAM ERROR - CANNOT INSERT '
                         || 'DOCUMENTS FOR PAYMENT SERVICE REQUEST';
                     x_retcode := '-1';

                     FND_MESSAGE.SET_NAME('IBY', 'IBY_BUILD_DOC_INSERT_ERROR');
                     FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

                     /*
                      * The payment request was possibly locked by the UI.
                      * Unlock it if possible.
                      */
                     IBY_DISBURSE_UI_API_PUB_PKG.unlock_pmt_entity(
                                 l_payreq_id ,
                                 'PAYMENT_REQUEST',
                                 l_return_status
                                 );

                     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                     print_debuginfo(l_module_name, 'Unlocked Payment service Request');

                     END IF;

                     update_payreq_status(l_payreq_id,
		                          REQ_STATUS_BUILD_ERROR,
					  l_return_status);


                     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                     print_debuginfo(l_module_name, 'EXIT');

                     END IF;
                     RETURN;

                 ELSE

                     /*
                      * Payment service request documents successfully inserted
                      * into the DB. Commit at this point.
                      */
                     COMMIT;
                 END IF;

             END IF;

         ELSE

	         print_log(l_module_name, 'Payment service '
	                     || 'request '
	                     || p_calling_app_payreq_cd
	                     || ' is a duplicate. Skipping insert of documents '
	                     );

         END IF; -- if not duplicate

     END;

     /*
      * STEP 3:
      *
      * Call the build program functional flows one-by-one.
      */
	     print_log(l_module_name, '+--------------------------------------------------------------------------------------------------------+');
	     print_log(l_module_name, '|STEP 3: Account/Profile Assignment :Timestamp:'||systimestamp ||'|');
	     print_log(l_module_name, '+--------------------------------------------------------------------------------------------------------+');
     /*
      * F4 - Account Profile / Assignment Flow
      *
      * If the provided payment reqist is in 'submitted'
      * status, assign default payment profiles/
      * internal bank accounts to each document in the
      * request, if the documents do not already have them.
      */
     BEGIN
         l_payreq_status := get_payreq_status(l_payreq_id);

         IF (l_payreq_status = REQ_STATUS_SUBMITTED) THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Found payment request '
	                 || l_payreq_id
	                 || ' in "submitted" status.'
	                 );
             END IF;
/* 7492186 */
          BEGIN
             SELECT payment_service_request_id
             INTO l_req_id
             FROM iby_pay_service_requests
             WHERE payment_service_request_id = l_payreq_id
             AND payment_service_request_status = l_payreq_status
             FOR UPDATE SKIP LOCKED;

              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	              print_debuginfo(l_module_name, 'Acquired lock');

              END IF;
          EXCEPTION
             WHEN NO_DATA_FOUND
             THEN

	          --Print in conc. log if any error occurs
		  print_log(l_module_name, 'PPR is already locked by another request.'||
	                  'This is a duplicate Build Request');

                  RETURN;
           END;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Going to perform '
	                 || 'assignments for payment req id: '
	                 || l_payreq_id);

             END IF;
--ebs_pga_mem('Before performAssignments');

             IBY_ASSIGN_PUB.performAssignments(
                                l_payreq_id,
                                l_return_status);

--ebs_pga_mem('After performAssignments');

             print_log(l_module_name, 'Request status after '
	                 || 'assignments: ' || l_return_status);


         END IF;

         /*
          * If assignments were completed, then commit.
          */

         COMMIT;

     EXCEPTION

         WHEN OTHERS THEN

	         print_log(l_module_name, 'Exception occured when performing '
	             || 'assignments. Assignment flow will be aborted and no '
	             || 'assignments will be committed for payment request '
	             || l_payreq_id
	             );
	          print_log(l_module_name, 'SQLCODE: ' || SQLCODE);
	          print_log(l_module_name, 'SQLERRM: ' || SQLERRM);


          ROLLBACK;

          x_errbuf := 'BUILD PROGRAM ERROR - CANNOT COMPLETE '
              || 'ACCOUNT/PROFILE ASSIGNMENTS';
          x_retcode := '-1';

          FND_MESSAGE.SET_NAME('IBY', 'IBY_BUILD_DOC_ASSIGN_ERROR');
          FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

          /*
           * The payment request was possibly locked by the UI.
           * Unlock it if possible.
           */
          IBY_DISBURSE_UI_API_PUB_PKG.unlock_pmt_entity(
              l_payreq_id ,
              'PAYMENT_REQUEST',
              l_return_status
              );

	     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		     print_debuginfo(l_module_name, 'Unlocked Payment service Request');

	     END IF;

	     update_payreq_status(l_payreq_id,
				  REQ_STATUS_BUILD_ERROR,
				  l_return_status);

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	          print_debuginfo(l_module_name, 'EXIT');

          END IF;
          RETURN;

     END;

	     print_log(l_module_name, '+----------------------------------------------------------------------------------------------------+');
	     print_log(l_module_name, '|STEP 4: Document Validation :Timestamp:'||systimestamp ||'|');
	     print_log(l_module_name, '+----------------------------------------------------------------------------------------------------+');

     /*
      * F5 - Document Validation Flow (Part I)
      *
      * Check if the payment request is in 'ASSIGNMENT_COMPLETE' status;
      * 'ASSIGNMENT_COMPLETE' indicates that the all the data elements
      * required for building payments are present in the payment request.
      *
      * Validate the documents of such payment requests.
      */
     BEGIN

         l_payreq_status := get_payreq_status(l_payreq_id);

         IF (l_payreq_status = REQ_STATUS_ASGN_COMPLETE) THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Found payment request '
	                 || l_payreq_id
	                 || ' in "assignment complete" status.'
	                 );
             END IF;
/* 7492186 */
          BEGIN
             SELECT payment_service_request_id
             INTO l_req_id
             FROM iby_pay_service_requests
             WHERE payment_service_request_id = l_payreq_id
             AND payment_service_request_status = l_payreq_status
             FOR UPDATE SKIP LOCKED;

              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	              print_debuginfo(l_module_name, 'aquired lock');

              END IF;
          EXCEPTION
             WHEN NO_DATA_FOUND
             THEN
             print_log(l_module_name, 'PPR is already locked by another request.'||
	                  'This is a duplicate Build Request');
                     RETURN;
           END;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Going to validate documents '
	                     || 'for payment request '
	                     || l_payreq_id);

             END IF;
--ebs_pga_mem('Before applyDocumentValidationSets');

             IBY_VALIDATIONSETS_PUB.applyDocumentValidationSets(
                                        l_payreq_id,
                                        p_document_rejection_level,
                                        FALSE,
                                        l_return_status);

--ebs_pga_mem('After applyDocumentValidationSets');

             /*
              * This flag is used by the document re-validation flow
              * downstream to decide whether to re-validate documents
              * or not.
              *
              * Without this flag, the document re-validation flow will
              * attempt to re-validate documents that have just
              * been validated.
              *
              * By using this flag we prevent the above situation.
              */
             l_doc_current_session_flag := TRUE;

             print_log(l_module_name, 'Request status after '
	                 || 'document validation: ' || l_return_status);


         END IF;

         /*
          * If document validations were completed, then commit.
          */
         COMMIT;

     EXCEPTION

         WHEN OTHERS THEN
                 print_log(l_module_name, 'Exception occured when validating '
	             || 'documents. Document validation will be aborted and no '
	             || 'document statuses will be committed for payment request '
	             || l_payreq_id
	             );
	         print_log(l_module_name, 'SQLCODE: ' || SQLCODE);
	         print_log(l_module_name, 'SQLERRM: ' || SQLERRM);


         ROLLBACK;

          x_errbuf := 'BUILD PROGRAM ERROR - CANNOT VALIDATE '
              || 'DOCUMENTS';
          x_retcode := '-1';

          FND_MESSAGE.SET_NAME('IBY', 'IBY_BUILD_DOC_VAL_ERROR');
          FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

          /*
           * The payment request was possibly locked by the UI.
           * Unlock it if possible.
           */
          IBY_DISBURSE_UI_API_PUB_PKG.unlock_pmt_entity(
              l_payreq_id ,
              'PAYMENT_REQUEST',
              l_return_status
              );

	     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		     print_debuginfo(l_module_name, 'Unlocked Payment service Request');

	     END IF;

	     update_payreq_status(l_payreq_id,
				  REQ_STATUS_BUILD_ERROR,
				  l_return_status);

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	          print_debuginfo(l_module_name, 'EXIT');

          END IF;
          RETURN;

     END;

     	     print_log(l_module_name, '+--------------------------------------------------------------------------------------------------------+');
	     print_log(l_module_name, '|STEP 5: Document Re-Validation: Timestamp:'||systimestamp ||'|');
	     print_log(l_module_name, '+--------------------------------------------------------------------------------------------------------+');


     /*
      * F5 - Document Validation Flow (Part II)
      *
      * Payment requests can re-enter the document validation
      * flow after user review/modification (F7 flow).
      *
      * Re-validate the documents of the payment request if it
      * is in 'retry document validation' status.
      */
     BEGIN

         IF (l_doc_current_session_flag = TRUE) THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Current session flag: '
	                 || 'true'
	                 );
             END IF;
         ELSE
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Current session flag: '
	                 || 'false'
	                 );
             END IF;
         END IF;

         l_payreq_status := get_payreq_status(l_payreq_id);

         IF (l_payreq_status = REQ_STATUS_RETRY_DOC_VALID) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Found payment request '
	                 || l_payreq_id
	                 || ' in "retry document validation" status.'
	                 );

             END IF;
             /*
              * Fix for bug 5395425:
              *
              * Change the document status to 'ready for validation'
              * only if we are about to retry document
              * validation.
              */

             /*
              * When we re-enter the document validation flow,
              * the document status could be 'failed validation'.
              * Set the document status back to 'ready for validation'
              * so that the validation flow treats these docs as
              * fresh documents.
              */
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Going to change document '
	                 || 'status to "ready for validation" for failed '
	                 || 'documents of payment request '
	                 || l_payreq_id);

             END IF;
             UPDATE
                 IBY_DOCS_PAYABLE_ALL
             SET
                 document_status = DOC_STATUS_RDY_FOR_VAL
             WHERE
                 payment_service_request_id = l_payreq_id AND
                 document_status = DOC_STATUS_FAILED_VAL
             ;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Document status changes '
	                 || 'completed');

	             print_debuginfo(l_module_name, 'Going to re-validate documents '
	                     || 'for payment request '
	                     || l_payreq_id);

             END IF;
             IBY_VALIDATIONSETS_PUB.applyDocumentValidationSets(
                                        l_payreq_id,
                                        p_document_rejection_level,
                                        FALSE,
                                        l_return_status);

                   print_log(l_module_name, 'Request status after document '
	                 || 're-validation: ' || l_return_status);

         ELSIF (l_payreq_status = REQ_STATUS_PEN_REV_DOC_VAL AND
                l_doc_current_session_flag = FALSE) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Found payment request '
	                 || l_payreq_id
	                 || ' in "pending review - document validation error" status.'
	                 );

	             print_debuginfo(l_module_name, 'Going to re-validate documents '
	                     || 'for payment request '
	                     || l_payreq_id);

             END IF;
             IBY_VALIDATIONSETS_PUB.applyDocumentValidationSets(
                                        l_payreq_id,
                                        p_document_rejection_level,
                                        FALSE,
                                        l_return_status);

             print_log(l_module_name, 'Request status after document '
	                 || 're-validation: ' || l_return_status);


         END IF;


         /*
          * If document validations were completed, then commit.
          */
         COMMIT;

     EXCEPTION

         WHEN OTHERS THEN
	         print_log(l_module_name, 'Exception occured when re-validating '
	             || 'documents. Document validation will be aborted and no '
	             || 'document statuses will be committed for payment request '
	             || l_payreq_id
	             );
	         print_log(l_module_name, 'SQLCODE: ' || SQLCODE);
	         print_log(l_module_name, 'SQLERRM: ' || SQLERRM);

         ROLLBACK;

          x_errbuf := 'BUILD PROGRAM ERROR - CANNOT COMPLETE '
              || 'DOCUMENT RE-VALIDATION';
          x_retcode := '-1';

          FND_MESSAGE.SET_NAME('IBY', 'IBY_BUILD_DOC_REVAL_ERROR');
          FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

          /*
           * The payment request was possibly locked by the UI.
           * Unlock it if possible.
           */
          IBY_DISBURSE_UI_API_PUB_PKG.unlock_pmt_entity(
              l_payreq_id ,
              'PAYMENT_REQUEST',
              l_return_status
              );


	     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		     print_debuginfo(l_module_name, 'Unlocked Payment service Request');

	     END IF;

	     update_payreq_status(l_payreq_id,
				  REQ_STATUS_BUILD_ERROR,
				  l_return_status);

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	          print_debuginfo(l_module_name, 'EXIT');

          END IF;
          RETURN;

     END;

	     print_log(l_module_name, '+--------------------------------------------------------------------------------------------------+');
	     print_log(l_module_name, '|STEP 6: Payment Creation :Timestamp:'||systimestamp ||'|');
	     print_log(l_module_name, '+--------------------------------------------------------------------------------------------------+');

     /*
      * F6 - Payment Creation Flow (Part I)
      *
      * If the payment request is in 'validated' status,
      * create payments from the documents of the requests.
      */

     BEGIN
         l_payreq_status := get_payreq_status(l_payreq_id);

         IF (l_payreq_status = REQ_STATUS_VALIDATED) THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Found payment request '
	                 || l_payreq_id
	                 || ' in "validated" status.'
	                 );
             END IF;
/* 7492186 */
          BEGIN
             SELECT payment_service_request_id
             INTO l_req_id
             FROM iby_pay_service_requests
             WHERE payment_service_request_id = l_payreq_id
             AND payment_service_request_status = l_payreq_status
             FOR UPDATE SKIP LOCKED;

              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	              print_debuginfo(l_module_name, 'aquired lock');

              END IF;
          EXCEPTION
             WHEN NO_DATA_FOUND
             THEN
                  print_log(l_module_name, 'PPR is already locked by another request.'||
	                  'This is a duplicate Build Request');
                  RETURN;
           END;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Going to create payments '
	                 || 'for payment request '
	                 || l_payreq_id);

             END IF;
--ebs_pga_mem('Before createPayments');

             IBY_PAYGROUP_PUB.createPayments(
                                  l_payreq_id,
                                  p_payment_rejection_level,
                                  p_review_proposed_pmts_flag,
                                  null,
                                  null,
                                  null,
                                  G_PKG_NAME,
                                  l_return_status);

--ebs_pga_mem('After createPayments');

             /*
              * This flag is used by the payment re-creation flow
              * downstream to decide whether to re-create payments
              * or not.
              *
              * Without this flag, the payment re-creation flow will
              * immediately move payments that are in PENDING_REVIEW
              * status to CREATED status before the user has a chance
              * to review them.
              *
              * By using this flag we prevent the above situation.
              */
             l_pmt_current_session_flag := TRUE;

             print_log(l_module_name, 'Request status after payment '
	                 || 'creation: ' || l_return_status);

         END IF;

         /*
          * If payment creation was completed, then commit.
          */
         COMMIT;

     EXCEPTION

         WHEN OTHERS THEN
                 print_log(l_module_name, 'Exception occured when '
	             || 'building payments. Payment creation will be '
	             || 'aborted and no payments will be committed for '
	             || 'payment request '
	             || l_payreq_id
	             );
	         print_log(l_module_name, 'SQLCODE: ' || SQLCODE);
	         print_log(l_module_name, 'SQLERRM: ' || SQLERRM);


         ROLLBACK;

          x_errbuf := 'BUILD PROGRAM ERROR - CANNOT CREATE PAYMENTS';
          x_retcode := '-1';

          FND_MESSAGE.SET_NAME('IBY', 'IBY_BUILD_PMT_CREAT_ERROR');
          FND_FILE.PUT_LINE(FND_FILE.log, FND_MESSAGE.GET);

          /*
           * The payment request was possibly locked by the UI.
           * Unlock it if possible.
           */
          IBY_DISBURSE_UI_API_PUB_PKG.unlock_pmt_entity(
              l_payreq_id ,
              'PAYMENT_REQUEST',
              l_return_status
              );


	     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		     print_debuginfo(l_module_name, 'Unlocked Payment service Request');

	     END IF;

	     update_payreq_status(l_payreq_id,
				  REQ_STATUS_BUILD_ERROR,
				  l_return_status);

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	          print_debuginfo(l_module_name, 'EXIT');

          END IF;
          RETURN;

     END;

	     print_log(l_module_name, '+---------------------------------------------------------------------------------------------------------------------+');
	     print_log(l_module_name, '|STEP 7: Payment Re-Creation:Timestamp:'||systimestamp ||'|');
	     print_log(l_module_name, '+---------------------------------------------------------------------------------------------------------------------+');

     /*
      * F6 - Payment Creation Flow (Part II)
      *
      * Payment requests can re-enter the payment creation
      * flow after user review/modification (F7 flow).
      *
      * Re-create the payments of the payment requests if it
      * is in 'retry payment creation' status.
      */

     BEGIN

         IF (l_pmt_current_session_flag = TRUE) THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Current session flag: '
	                 || 'true'
	                 );
             END IF;
         ELSE
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Current session flag: '
	                 || 'false'
	                 );
             END IF;
         END IF;

         l_payreq_status := get_payreq_status(l_payreq_id);

         IF (l_payreq_status = REQ_STATUS_USER_REVW) THEN

             l_flag := checkIfPmtsInModifiedStatus(l_payreq_id);

             /*
              * If payments have been modified (by dismissing
              * constituent documents, for example), then
              * the payments of the request need to be re-built.
              *
              * For this, the payment request status should be
              * set to 'RETRY_PAYMENT_CREATION'.
              *
              * Ideally, the UI should do this step, but because
              * of technical limitations of the UI, the status is
              * adjusted here.
              */
             IF (l_flag = TRUE) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Payment request '
	                     || l_payreq_id
	                     || ' contains payments in "modified" status. '
	                     || 'Adjusting request status to '
	                     || REQ_STATUS_RETRY_PMT_CREAT
	                     );

                 END IF;
                 /*
                  * Update the request status in the database so that
                  * it is visible to the payment creation module.
                  */
                 UPDATE
                     IBY_PAY_SERVICE_REQUESTS
                 SET
                     payment_service_request_status =
                         REQ_STATUS_RETRY_PMT_CREAT
                 WHERE
                     payment_service_request_id = l_payreq_id;

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Status of payment request '
	                     || l_payreq_id
	                     || ' updated in DB. '
	                     );

                 END IF;
                 l_payreq_status := REQ_STATUS_RETRY_PMT_CREAT;

             END IF;

         END IF;

         /*
          * Fix for bug 5331527:
          *
          * PPRs in REQ_STATUS_PEN_REV_PMT_VAL need to be
          * re-validated.
          *
          * Therefore, call createPayments(..) for such PPRs.
          */
         IF (l_payreq_status = REQ_STATUS_RETRY_PMT_CREAT  OR
             l_payreq_status = REQ_STATUS_PEN_REV_PMT_VAL) THEN

             IF (l_payreq_status = REQ_STATUS_RETRY_PMT_CREAT) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Found payment request '
	                     || l_payreq_id
	                     || ' in "retry payment creation" status.'
	                     );

                 END IF;
                 /*
                  * In the case of PPRs with status
                  * REQ_STATUS_RETRY_PMT_CREAT, we can blindly go
                  * ahead and retry the payment creation.
                  */
                 l_do_retry_flag := TRUE;

             ELSE

                 /*
                  * This means that the PPR contained payments with
                  * validation failures.
                  *
                  * We need to run payment validations again.
                  */
                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Found payment request '
	                     || l_payreq_id
	                     || ' in "pending review - pmt validation errors" status.'
	                     );

                 END IF;
                 /*
                  * In the case of PPRs with status
                  * REQ_STATUS_PEN_REV_PMT_VAL, we can retry the
                  * payment creation only of the current session
                  * flag is FALSE, otherwise,  we will never be
                  * giving the user a chance to review the payments
                  * that have failed validation.
                  */
                 IF (l_pmt_current_session_flag = FALSE) THEN
                     l_do_retry_flag := TRUE;
                 ELSE
                     l_do_retry_flag := FALSE;
                 END IF;

             END IF;

             IF (l_do_retry_flag = TRUE) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Going to retry payment '
	                     || 'creation for payment request: '
	                     || l_payreq_id);

                 END IF;
                 IBY_PAYGROUP_PUB.createPayments(
                                      l_payreq_id,
                                      p_payment_rejection_level,
                                      p_review_proposed_pmts_flag,
                                      null,
                                      null,
                                      null,
                                      G_PKG_NAME,
                                      l_return_status);

	                 print_log(l_module_name, 'Request status after retrying '
	                     || 'payment creation: ' || l_return_status);

             END IF;

         ELSIF (l_payreq_status = REQ_STATUS_USER_REVW AND
                l_pmt_current_session_flag = FALSE) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Found payment request '
	                 || l_payreq_id
	                 || ' in "pending review" status.'
	                 ,G_LEVEL_STATEMENT);

	             print_debuginfo(l_module_name, 'Payment request '
	                 || l_payreq_id
	                 || ' will not be revalidated. Only request status '
	                 || 'will be set to "created".'
	                 ,G_LEVEL_STATEMENT);

             END IF;
             /*
              * When the user reviews payments, she has an option
              * of changing the external (payee) bank account on
              * the payment.
              *
              * At this point, the UI will change the status of the
              * payment to "modified payee bank account".
              *
              * The Build Program does not re-validate payments that
              * have been reviewed by the user (because the review
              * process is considered a lightweight process that
              * does not require re-validation).
              *
              * Therefore, the status of the payment needs to be
              * changed back to "created" status so that the
              * PICP can pick up this payment for for further
              * processing.
              */
             l_flag := checkIfPmtsInModBankAccStatus(l_payreq_id);

             /*
              * If payments have been modified (by dismissing
              * constituent documents, for example), then
              * the payments of the request need to be re-built.
              *
              * For this, the payment request status should be
              * set to 'RETRY_PAYMENT_CREATION'.
              *
              * Ideally, the UI should do this step, but because
              * of technical limitations of the UI, the status is
              * adjusted here.
              */
             IF (l_flag = TRUE) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Payments in "modified bank '
	                     || 'account" status will be updated for request '
	                     || l_payreq_id
	                     );

                 END IF;
                 UPDATE
                    IBY_PAYMENTS_ALL
                 SET
                    payment_status = PAY_STATUS_CREATED
                 WHERE
                    payment_service_request_id = l_payreq_id AND
                    payment_status = PAY_STATUS_MOD_BNK_ACC
                 ;

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Payment status changes '
	                     || 'completed');

                 END IF;
             ELSE

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'No payments in "modified bank '
	                     || 'account" status found for request '
	                     || l_payreq_id
	                     );

                 END IF;
             END IF;

             /*
              * User has reviewed the payments in this request and
              * allowed it to proceed. No need to revalidate. Simply
              * change the request status to CREATED and exit.
              */
             UPDATE
                 IBY_PAY_SERVICE_REQUESTS
             SET
                 payment_service_request_status = REQ_STATUS_PMT_CRTD
             WHERE
                 payment_service_request_id = l_payreq_id;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Updated status of'
	                 || ' payment request '
	                 || l_payreq_id
	                 || ' to "created"'
	                 );

             END IF;
         END IF;

         /*
          * If payment creation was completed, then commit.
          */
         COMMIT;

     EXCEPTION

         WHEN OTHERS THEN
                 print_log(l_module_name, 'Exception occured when '
	             || 're-building payments. Payment creation will be '
	             || 'aborted and no payments will be committed for '
	             || 'payment request '
	             || l_payreq_id
	             );
	         print_log(l_module_name, 'SQLCODE: ' || SQLCODE);
	         print_log(l_module_name, 'SQLERRM: ' || SQLERRM);


         ROLLBACK;

          x_errbuf := 'BUILD PROGRAM ERROR - CANNOT COMPLETE '
              || 'PAYMENT RE-CREATION';
          x_retcode := '-1';

          FND_MESSAGE.SET_NAME('IBY', 'IBY_BUILD_PMT_RECREAT_ERROR');
          FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

          /*
           * The payment request was possibly locked by the UI.
           * Unlock it if possible.
           */
          IBY_DISBURSE_UI_API_PUB_PKG.unlock_pmt_entity(
              l_payreq_id ,
              'PAYMENT_REQUEST',
              l_return_status
              );


	     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		     print_debuginfo(l_module_name, 'Unlocked Payment service Request');

	     END IF;

	     update_payreq_status(l_payreq_id,
				  REQ_STATUS_BUILD_ERROR,
				  l_return_status);

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
     x_errbuf := 'BUILD PROGRAM COMPLETED SUCCESSFULLY';
     x_retcode := '0';

     l_payreq_status := get_payreq_status(l_payreq_id);

     print_log(l_module_name, 'Final status of payment request '
	         || l_payreq_id
	         || ' (calling app pay req cd: '
	         || p_calling_app_payreq_cd
	         || ') before exiting build program is '
	         || l_payreq_status
	         );


     /*
      * Launch payment process status report. This
      * report needs to launched at the end of the
      * Build Program cycle (Build Program cycle
      * is considered completed when payments are
      * created. Creation of payment instructions
      * is an auxiliary step).
      *
      * The PPR status report needs to be launched
      * based on the enterprise level settings.
      *
      * See bug 5363433 for details.
      */
     launchPPRStatusReport(l_payreq_id);

     /*
      * If we reached here, it means that the Build Program has
      * completed processing the payment request. Check if payment
      * instructions have to be synchronously created from the payments
      * of this payment request.
      */
             print_log(l_module_name, '+--------------------------------------------------------------------------------------------------------------------------+');
	     print_log(l_module_name, '|STEP 8: Check PICP Kickoff Flag: Timestamp:'||systimestamp ||'|');
	     print_log(l_module_name, '+--------------------------------------------------------------------------------------------------------------------------+');

     /*
      * The create instructions flag would have been provided
      * as an input param to the build program.
      *
      * If this is a re-run of the build program (e.g., after
      * user has reviewed proposed payments, the create
      * instructions flag would not be again passed in; instead
      * we have to check the IBY_PAY_SERVICE_REQUESTS to get the
      * original value for this flag).
      *
      * Use the retrieved value to determine whether to kick off
      * the PICP (Fix for bug 4746624).
      */
     IF (p_create_instrs_flag = 'N') THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Picking up create '
	                 || 'instructions flag from payment request table ..'
	                 );

         END IF;
         BEGIN

             SELECT
                 NVL(create_pmt_instructions_flag, 'N')
             INTO
                 l_create_instrs_flag
             FROM
                 IBY_PAY_SERVICE_REQUESTS
             WHERE
                 PAYMENT_SERVICE_REQUEST_ID = l_payreq_id
             ;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Create instructions '
	                 || 'flag successfully retrieved.'
	                 );

             END IF;
         EXCEPTION

             WHEN OTHERS THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Non-Fatal: Exception when '
	                     || 'attempting to retrieve create instructions flag.');
	                 print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	                 print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);

	                 print_debuginfo(l_module_name, 'Payment instruction creation '
	                     || 'will not be attempted.');

                 END IF;
         END;

     ELSE

         /*
          * Use the passed in value.
          */
         l_create_instrs_flag := p_create_instrs_flag;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Passed in create instructions '
	             || 'flag parameter will be used.'
	             );

         END IF;
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Value of create '
	         || 'instructions flag: '
	         || l_create_instrs_flag
	         );

     END IF;
     /*
      * The payment document id would have been provided
      * as an input param to the build program.
      *
      * If this is a re-run of the build program (e.g., after
      * user has reviewed proposed payments, the payment doc
      * id would not be again passed in; instead
      * we have to check the IBY_PAY_SERVICE_REQUESTS to get the
      * original value for this param).
      */
     IF (p_payment_document_id IS NULL) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Picking up payment '
	                 || 'document id from payment request table ..'
	                 );

         END IF;
         BEGIN

             SELECT
                 payment_document_id
             INTO
                 l_payment_doc_id
             FROM
                 IBY_PAY_SERVICE_REQUESTS
             WHERE
                 PAYMENT_SERVICE_REQUEST_ID = l_payreq_id
             ;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Payment document '
	                 || 'id successfully retrieved.'
	                 );

             END IF;
         EXCEPTION

             WHEN OTHERS THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Non-Fatal: Exception when '
	                     || 'attempting to retrieve payment document id.');
	                 print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	                 print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);

                 END IF;
         END;

     ELSE

         /*
          * Use the passed in value.
          */
         l_payment_doc_id := p_payment_document_id;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Passed in payment document '
	             || 'id parameter will be used.'
	             );

         END IF;
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Value of payment '
	         || 'document id: '
	         || ''''
	         || l_payment_doc_id
	         || ''''
	         );

     END IF;



     /*
      * Call payment instruction creation routine
      * if payment instructions have to be created
      * synchronously after build.
      */
     IF (l_payreq_status <> REQ_STATUS_PMT_CRTD OR
         UPPER(l_create_instrs_flag) <> 'Y') THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Not attempting '
	             || 'to create payment instructions ..'
	             );

	         print_debuginfo(l_module_name, 'Final status of payment request '
	             || l_payreq_id
	             || ' is '
	             || l_payreq_status
	             );

         END IF;
         /*
          * The payment request was possibly locked by the UI.
          * Unlock it if possible.
          */
         IBY_DISBURSE_UI_API_PUB_PKG.unlock_pmt_entity(
             l_payreq_id ,
             'PAYMENT_REQUEST',
             l_return_status
             );

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Final status of payment request '
	         || l_payreq_id
	         || ' is '
	         || l_payreq_status
	         );

     END IF;


     /*
      * Start Bug 8924569 - Phase 1 solution.
      * If the passed PPP is NULL
      *  Before routing for create payment instructions,
      *  we will have to ensure that the
      *  single distinct PPP is stamped in the PPR request header as well.
      *
      *  Bug 8883966: At each stage of the build process, transaction should be
      * committed.
      *
     BEGIN
     l_payment_profile_id := p_payment_profile_id;
     IF (l_payment_profile_id IS NULL) THEN

	      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		print_debuginfo(l_module_name, 'Start Bug 8924569 - Phase 1 solution');
		print_debuginfo(l_module_name, 'Passed payment profile id on the PPR header is NULL');
		print_debuginfo(l_module_name, 'Finding if the request is stamped with single distinct PPP on all its documents');
	      END IF;

	      -- Finding number of distinct ppps on all documents payable in the request
	      SELECT COUNT(*) distinct_ppp_count
	      INTO l_distinct_ppp_count
		FROM
		 ( SELECT DISTINCT payment_profile_id
		    FROM iby_docs_payable_all
		    WHERE payment_service_request_id = l_payreq_id
		 ) distinctppp;

	     -- If single distinct PPP found, we stamp it on the PPR header
	     -- Else reset create payment instructions flag to N
	     IF (l_distinct_ppp_count = 1) THEN

		 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			 print_debuginfo(l_module_name, 'Single distinct PPP found : Count='|| l_distinct_ppp_count);
		 END IF;

                 -- Pick a sample PPP, this should be the single distinct PPP.
		 SELECT payment_profile_id
		 INTO l_distinct_ppp
		 FROM iby_docs_payable_all
		 WHERE payment_service_request_id = l_payreq_id
		  AND ROWNUM = 1 ;

		 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			 print_debuginfo(l_module_name, 'Stamping the distinct PPP on the PPR header : ppp_ID=' || l_distinct_ppp);
		 END IF;

                 -- Change this process parameter to the single distinct PPP value for later use.
		 l_payment_profile_id := l_distinct_ppp;

                 -- Stamp this single distinct PPP on PPR header as well.
		 UPDATE iby_pay_service_requests
		 SET payment_profile_id           = l_distinct_ppp
		 WHERE payment_service_request_id = l_payreq_id;

	     ELSE
		 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			 print_debuginfo(l_module_name, 'Single distinct PPP not found : Count '|| l_distinct_ppp_count);
			 print_debuginfo(l_module_name, 'Bypassing payment instruction creation per bug 8924569');
		 END IF;
		--Reset create payment instructions flag to 'N'
		l_create_instrs_flag := 'N';
	     END IF;

	     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		print_debuginfo(l_module_name, 'End Bug 8924569 - Phase 1 solution');
	     END IF;
     END IF;
         /*
          * If PPR IS stamped successfully, trasaction
	  * should be committed.
          *
         COMMIT;

     EXCEPTION

         WHEN OTHERS THEN
                 print_log(l_module_name, 'Exception occured when '
	             || 'while stamping PPP to PPR.'
	             || l_payreq_id
	             );
	         print_log(l_module_name, 'SQLCODE: ' || SQLCODE);
	         print_log(l_module_name, 'SQLERRM: ' || SQLERRM);

         ROLLBACK;

          x_errbuf := 'BUILD PROGRAM COMPLETE - ERROR OCCURED BEFORE '
              || 'TRIGGERING INSTRUCTION CREATION. SUBMIT STANDARD REQUEST'
	      || 'FOR INSTRUCTION CREATION';
          x_retcode := '-1';

          FND_MESSAGE.SET_NAME('IBY', 'IBY_BUILD_PPP_ASSIGN');
          FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

          /*
           * The payment request was possibly locked by the UI.
           * Unlock it if possible.
           *
          IBY_DISBURSE_UI_API_PUB_PKG.unlock_pmt_entity(
              l_payreq_id ,
              'PAYMENT_REQUEST',
              l_return_status
              );


	     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		     print_debuginfo(l_module_name, 'Unlocked Payment service Request');

	     END IF;

	     update_payreq_status(l_payreq_id,
				  REQ_STATUS_BUILD_ERROR,
				  l_return_status);

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	          print_debuginfo(l_module_name, 'EXIT');

          END IF;
          RETURN;

     END;
      End Bug 8924569 - Phase 1 solution */

  /* Start Bug 8924569 - Phase 2 solution */
  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	 print_debuginfo(l_module_name, 'Start Bug 8924569 - Phase 2 solution');
  END IF;

  FOR distinct_ppps_rec IN get_distinct_ppps(l_payreq_id)
  LOOP

	     l_payment_profile_id := distinct_ppps_rec.payment_profile_id ;
	     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		print_debuginfo(l_module_name, 'Looping for distinct PPP_ID '|| l_payment_profile_id);
	     END IF;
     /*
      * If we reached here, it means that payment
      * instructions have to be created from the payments
      * of this payment request.
      */
     	     print_log(l_module_name, '+--------------------------------------------------------------------------------------------------------------+');
	     print_log(l_module_name, '|STEP 9: Payment Instruction Creation :Timestamp:'||systimestamp ||'|');
	     print_log(l_module_name, '+--------------------------------------------------------------------------------------------------------------+');

     BEGIN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Synchronously '
	             || 'attempting to create payment instructions ..'
	             );

         END IF;
         /*
          * Get the default processing related attributes
          * from the payment process profile.
          */
         get_profile_process_attribs(
             l_payment_profile_id,
             l_profile_attribs
             );

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Attributes of profile '
	             || l_payment_profile_id
	             || ' - '
	             );
	         print_debuginfo(l_module_name, 'Processing type: '
	             || l_profile_attribs.processing_type
	             );
	         print_debuginfo(l_module_name, 'Payment document: '
	             || l_profile_attribs.payment_doc_id
	             );
	         print_debuginfo(l_module_name, 'Printer name: '
	             || l_profile_attribs.printer_name
	             );
	         print_debuginfo(l_module_name, 'Print now flag: '
	             || l_profile_attribs.print_now_flag
	             );
	         print_debuginfo(l_module_name, 'Transmit now flag: '
	             || l_profile_attribs.transmit_now_flag
	             );

         END IF;
         /*
          * Now, invoke payment instruction for this
          * payment request.
          */

--ebs_pga_mem('Before IBY_PAYINSTR_PUB.createPaymentInstructions');

         IBY_PAYINSTR_PUB.createPaymentInstructions(
             l_profile_attribs.processing_type,
             NVL(l_payment_doc_id, l_profile_attribs.payment_doc_id),
             l_profile_attribs.printer_name,
             l_profile_attribs.print_now_flag,
             l_profile_attribs.transmit_now_flag,
             p_calling_app_payreq_cd,       /* admin assigned ref */
             NULL,                       /* comments */
             l_payment_profile_id,       /* payment profile id */
             p_calling_app_id,
             p_calling_app_payreq_cd,
             l_payreq_id,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             'N',                        /* single payments flow flag */
             l_pmtInstrTab,
             l_return_status,
             l_msg_count,
             l_msg_data
             );

--ebs_pga_mem('After IBY_PAYINSTR_PUB.createPaymentInstructions');

         print_log(l_module_name, 'Return status of payment '
	             || 'instruction creation: '
	             || l_return_status
	             );


         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Raising exception '
	                 || 'because instruction creation '
	                 || 'did not complete successfully ..',
	                 FND_LOG.LEVEL_UNEXPECTED
	                 );

             END IF;
             APP_EXCEPTION.RAISE_EXCEPTION;

         END IF;


         /*
          * If payment instruction creation was completed, then commit.
          */
         COMMIT;

     EXCEPTION

         WHEN OTHERS THEN

                 print_log(l_module_name, 'Exception occured when '
	             || 'creating payment instructions. Payment instruction '
	             || 'creation will be aborted and no instructions will be '
	             || 'committed for payment request '
	             || l_payreq_id
	             );
	         print_log(l_module_name, 'SQLCODE: ' || SQLCODE);
	         print_log(l_module_name, 'SQLERRM: ' || SQLERRM);


         ROLLBACK;

          x_errbuf := 'BUILD PROGRAM ERROR - CANNOT COMPLETE '
              || 'PAYMENT INSTRUCTION CREATION';

          FND_MESSAGE.SET_NAME('IBY', 'IBY_BUILD_INS_CREAT_ERROR');
          FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

          /*
           * The payment request was possibly locked by the UI.
           * Unlock it if possible.
           */
          IBY_DISBURSE_UI_API_PUB_PKG.unlock_pmt_entity(
              l_payreq_id ,
              'PAYMENT_REQUEST',
              l_return_status
              );

          x_retcode := '-1';
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	          print_debuginfo(l_module_name, 'EXIT');

          END IF;
          RETURN;

     END;

     /*
      * If we reached here, it means that payment instruction
      * creation was successful. Perform check numbering for the
      * payments of the instruction.
      */
     	     print_log(l_module_name, '+----------------------------------------------------------------------------------------------------------+');
	     print_log(l_module_name, '|STEP 10: Check Numbering : Timestamp:'||systimestamp ||'|');
	     print_log(l_module_name, '+----------------------------------------------------------------------------------------------------------+');

     BEGIN

         /*
          * If we reached here, it means that the payment instruction
          * creation program finished successfully. Invoke
          * check numbering if we are building payment instructions
          * of processing type 'printed'.
          */
         IF (l_profile_attribs.processing_type = 'PRINTED' OR
              (l_profile_attribs.processing_type = 'ELECTRONIC' and l_payment_doc_id is not null)) THEN

             IF (l_pmtInstrTab.COUNT > 0) THEN

                 /*
                  * Perform check numbering (paper document numbering)
                  * for the first successful payment instruction. All
                  * other payment instructions are to be moved to a
                  * deferred status for later numbering.
                  *
                  * This is because the payment document (check stock)
                  * is locked once it is used to number a payment
                  * instruction. This lock will only be released after
                  * the user has confirmed that the checks printed
                  * correctly. So, there is no point in proceeding
                  * with other payment instructions until the numbered
                  * instruction has been confirmed by the user.
                  */
                 FOR i IN l_pmtInstrTab.FIRST .. l_pmtInstrTab.LAST LOOP

                     /*
                      * Number only successful payment
                      * instructions.
                      */
                     IF (l_pmtInstrTab(i).payment_instruction_status =
                             INS_STATUS_CREATED) THEN

                         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                         print_debuginfo(l_module_name, 'Invoking '
	                             || 'numbering for payment '
	                             || 'instruction '
	                             || l_pmtInstrTab(i).payment_instruction_id
	                             || ' with instruction status: '
	                             || l_pmtInstrTab(i).payment_instruction_status
	                             );

                         END IF;
                         /*
                          * Invoke check numbering for this payment
                          * instruction.
                          */
                         IBY_CHECKNUMBER_PUB.performCheckNumbering(
                             l_pmtInstrTab(i).payment_instruction_id,

                             /*
                              * Use the provided payment document id
                              * if available; else, use the payment
                              * doc id associated with the profile.
                              */
                             NVL(
                                 l_payment_doc_id,
                                 l_profile_attribs.payment_doc_id
                                ),

                             NULL,
                             l_return_status,
                             l_return_message,
                             l_msg_count,
                             l_msg_data
                             );

                           print_log(l_module_name, 'After numbering, '
	                             || 'return status: '
	                             || l_return_status
	                             || ', and return message: '
	                             || l_return_message
	                             );


                         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

                             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                             print_debuginfo(l_module_name, 'Check '
	                                 || 'numbering module returned failure '
	                                 || 'response. Aborting.. ',
	                                 FND_LOG.LEVEL_UNEXPECTED
	                                 );

                             END IF;
                             APP_EXCEPTION.RAISE_EXCEPTION;

                         END IF;

                         /*
                          * The first successful payment instruction has now
                          * been numbered.
                          *
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
	                                 || l_pmtInstrTab(i).payment_instruction_id
	                                 );

                             END IF;
                             IBY_FD_POST_PICP_PROGS_PVT.
                                 Run_Post_PI_Programs(
                                     l_pmtInstrTab(i).payment_instruction_id,
                                     'N'
                                     );

                             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                             print_debuginfo(l_module_name, 'Extract '
	                                 || 'and format operation completed.'
	                                 );

                             END IF;
                         EXCEPTION
                             WHEN OTHERS THEN


	                             print_log(l_module_name, 'Extract and '
	                                 || 'format operation generated '
	                                 || 'exception for payment instruction '
	                                 || l_pmtInstrTab(i).payment_instruction_id
	                                 );

	                             print_log(l_module_name, 'SQL code: '
	                                 || SQLCODE);
	                             print_log(l_module_name, 'SQL err msg: '
	                                 || SQLERRM);


                             ROLLBACK;

                             x_errbuf := 'BUILD PROGRAM ERROR - '
                                 || 'EXTRACT/FORMAT OPERATION FAILED';
                             x_retcode := '-1';

                             FND_MESSAGE.SET_NAME('IBY',
                                 'IBY_BUILD_BACKEND_ERROR');
                             FND_FILE.PUT_LINE(FND_FILE.LOG,
                                 FND_MESSAGE.GET);

                             /*
                              * The payment request was possibly locked
                              * by the UI. Unlock it if possible.
                              */
                             IBY_DISBURSE_UI_API_PUB_PKG.unlock_pmt_entity(
                                 l_payreq_id ,
                                 'PAYMENT_REQUEST',
                                 l_return_status
                                 );

                             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                             print_debuginfo(l_module_name, 'EXIT');

                             END IF;
                             RETURN;

                         END;

                         /*
                          * Move all other successful payment instructions
                          * to deferred status (for later numbering).
                          */
                         IBY_BUILD_INSTRUCTIONS_PUB_PKG.
                             moveInstrToDeferredStatus(
                                 l_pmtInstrTab,
                                 l_pmtInstrTab(i).payment_instruction_id
                                 );

                         /*
                          * Once we have numbered and formatted the first
                          * successful payment instruction, exit.
                          */
                         EXIT;

                     ELSE

                         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                         print_debuginfo(l_module_name, 'Not invoking '
	                             || 'paper document numbering for payment '
	                             || 'instruction '
	                             || l_pmtInstrTab(i).payment_instruction_id
	                             || ', as it is in status '
	                             || l_pmtInstrTab(i).payment_instruction_status
	                             );

                         END IF;
                     END IF;

                 END LOOP;

             ELSE

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Instruction count is '
	                     || 'zero. Skipping paper document numbering ..'
	                     );

                 END IF;
             END IF; -- if instruction count > 0
        /* Start Bug 8591394 */
         ELSE

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Processing type is '
	                 || l_profile_attribs.processing_type
	                 || '. Numbering of paper documents skipped ..'
	                 );

             END IF;
             /*
              * If we reached here, it means the processing type
              * is electronic.
              *
              * For electronic payment instructions, check numbering
              * not required. Instead, directly call the extracting
              * and formatting programs.
              */

             IF (l_pmtInstrTab.COUNT > 0) THEN

                 /*
                  * Loop through all the payment instructions one-by-one.
                  *
                  * Invoke extract and format for each successful payment
                  * instruction.
                  */
                 FOR i IN l_pmtInstrTab.FIRST .. l_pmtInstrTab.LAST LOOP

                     /*
                      * Call post-PICP programs only for successful
                      * payment instructions.
                      */
                     IF (l_pmtInstrTab(i).payment_instruction_status =
                             INS_STATUS_CREATED) THEN

                         /*
                          * WITHHOLDING CERTIFICATES HOOK:
                          *
                          * Fix for bug 6706749:
                          *
                          * We need to invoke withholding certificates hook for
                          * electronic payments. This is already being done
                          * from printed payments since base R12. Invoking
                          * withholding certificates for electronic payments
                          * is new functionality that is addressed in this
                          * fix.
                          */

                         l_pkg_name     := 'AP_AWT_CALLOUT_PKG';
                         l_callout_name := l_pkg_name
                                           || '.'
                                           || 'zx_witholdingCertificatesHook';

                         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                         print_debuginfo(l_module_name,
	                             'Attempting to call hook: '
	                             || l_callout_name, FND_LOG.LEVEL_UNEXPECTED);

                         END IF;
                         l_stmt := 'CALL '|| l_callout_name
                                          || '(:1, :2, :3, :4, :5, :6, :7, :8)';


                         BEGIN

                             EXECUTE IMMEDIATE
                                 (l_stmt)
                             USING
                                 IN  l_pmtInstrTab(i).payment_instruction_id,
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
	                                 || l_return_status, FND_LOG.LEVEL_UNEXPECTED);

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
	                                     || '. Raising exception.',
	                                     FND_LOG.LEVEL_UNEXPECTED);

                                 END IF;
                                 APP_EXCEPTION.RAISE_EXCEPTION;

                             END IF;

                         EXCEPTION

                             WHEN PROCEDURE_NOT_IMPLEMENTED THEN
                                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                                 print_debuginfo(l_module_name,
	                                     'Callout "'
	                                     || l_callout_name
	                                     || '" not implemented by application - AP',
	                                     FND_LOG.LEVEL_UNEXPECTED);

	                                 print_debuginfo(l_module_name,
	                                     'Skipping hook call.');

                                 END IF;
                             WHEN OTHERS THEN


	                                 print_log(l_module_name,
	                                     'Fatal: External app '
	                                     || 'callout '''
	                                     || l_callout_name
	                                     || ''', generated exception.'
	                                     );


                                 l_error_code := 'IBY_INS_AWT_CERT_HOOK_FAILED';
                                 FND_MESSAGE.set_name('IBY', l_error_code);

                                 FND_MESSAGE.SET_TOKEN('CALLOUT',
                                     l_callout_name,
                                     FALSE);
                                 /*
                                  * Set the error message on the concurrent
                                  * program output file (to warn user that
                                  * the hook failed).
                                  */
                                 FND_FILE.PUT_LINE(FND_FILE.LOG,
                                     FND_MESSAGE.GET);

                                 /*
                                  * Set the message on the error stack
                                  * to display in UI (in case of direct
                                  * API call from UI).
                                  */
                                 FND_MSG_PUB.ADD;

                                 /*
                                  * Propogate exception to caller.
                                  */
                                 RAISE;

                         END;

                         BEGIN

                             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                             print_debuginfo(l_module_name, 'Invoking '
	                                 || 'extract and format for payment '
	                                 || 'instruction '
	                                 || l_pmtInstrTab(i).payment_instruction_id
	                                 || ' with instruction status: '
	                                 || l_pmtInstrTab(i).payment_instruction_status
	                                 );

                             END IF;
                             IBY_FD_POST_PICP_PROGS_PVT.
                                 Run_Post_PI_Programs(
                                     l_pmtInstrTab(i).payment_instruction_id,
                                     'N'
                                     );

                                 print_log(l_module_name, 'Extract '
	                                 || 'and format operation completed.'
	                                 );


                         EXCEPTION
                             WHEN OTHERS THEN


	                             print_log(l_module_name, 'Extract and '
	                                 || 'format operation generated '
	                                 || 'exception for payment instruction '
	                                 || l_pmtInstrTab(i).payment_instruction_id
	                                 );

	                             print_debuginfo(l_module_name, 'SQL code: '
	                                 || SQLCODE);
	                             print_debuginfo(l_module_name, 'SQL err msg: '
	                                 || SQLERRM);

                             ROLLBACK;

                             x_errbuf := 'BUILD PROGRAM ERROR - '
                                 || 'EXTRACT/FORMAT OPERATION FAILED';
                             x_retcode := '-1';

                             FND_MESSAGE.SET_NAME('IBY',
                                 'IBY_BUILD_BACKEND_ERROR');
                             FND_FILE.PUT_LINE(FND_FILE.LOG,
                                 FND_MESSAGE.GET);

                             /*
                              * The payment request was possibly locked
                              * by the UI. Unlock it if possible.
                              */
                             IBY_DISBURSE_UI_API_PUB_PKG.unlock_pmt_entity(
                                 l_payreq_id ,
                                 'PAYMENT_REQUEST',
                                 l_return_status
                                 );

                             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                             print_debuginfo(l_module_name, 'EXIT');

                             END IF;
                             RETURN;

                         END;

                     ELSE

                         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                         print_debuginfo(l_module_name, 'Not invoking '
	                             || 'extract and format for payment '
	                             || 'instruction '
	                             || l_pmtInstrTab(i).payment_instruction_id
	                             || ' because it is in status: '
	                             || l_pmtInstrTab(i).payment_instruction_status
	                             );

                         END IF;
                     END IF;

                 END LOOP;

             END IF; -- if count of instructions > 0

         END IF; -- if processing type = 'printed'

         /*
          * In case check numbering completes, perform a commit.
          */
         COMMIT;

     EXCEPTION

         WHEN OTHERS THEN


	         print_log(l_module_name, 'Exception occured when '
	             || 'numbering checks of payment instructions. Check numbering '
	             || 'will be aborted ..'
	             );
	         print_log(l_module_name, 'SQLCODE: ' || SQLCODE);
	         print_log(l_module_name, 'SQLERRM: ' || SQLERRM);


         ROLLBACK;

          x_errbuf := 'BUILD PROGRAM ERROR - CANNOT COMPLETE '
              || 'CHECK NUMBERING';
          x_retcode := '-1';

          FND_MESSAGE.SET_NAME('IBY', 'IBY_BUILD_NUMBERING_ERROR');
          FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

          /*
           * The payment request was possibly locked
           * by the UI. Unlock it if possible.
           */
          IBY_DISBURSE_UI_API_PUB_PKG.unlock_pmt_entity(
              l_payreq_id ,
              'PAYMENT_REQUEST',
              l_return_status
              );

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	          print_debuginfo(l_module_name, 'EXIT');

          END IF;
          RETURN;

     END;

	     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		print_debuginfo(l_module_name, 'Looping ends for distinct PPP_ID '|| l_payment_profile_id);
	     END IF;

  END LOOP;

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	 print_debuginfo(l_module_name, 'End Bug 8924569 - Phase 2 solution');
  END IF;

  /* End Bug 8924569 - Phase 2 solution */

     /*
      * If we reached here, it means that the build program
      * finished successfully. Set the response message to
      * 'success'.
      */
     x_errbuf := 'BUILD PROGRAM COMPLETED SUCCESSFULLY';
     x_retcode := '0';

     FND_MESSAGE.SET_NAME('IBY', 'IBY_BUILD_COMPLETED');
     FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

     /*
      * The payment request was possibly locked
      * by the UI. Unlock it if possible.
      */
     IBY_DISBURSE_UI_API_PUB_PKG.unlock_pmt_entity(
         l_payreq_id ,
         'PAYMENT_REQUEST',
         l_return_status
         );

	     print_log(l_module_name, 'Build Program completed successfully. ::'||systimestamp
	         || ':: Exiting ..'
	         );

             print_log(l_module_name, '+----------------------------------------------------------------------------------------------------------+');
	     print_log(l_module_name, '|Build Complete :: Timestamp:'||systimestamp ||'|');
	     print_log(l_module_name, '+----------------------------------------------------------------------------------------------------------+');


	     print_log(l_module_name, 'EXIT');


 END submit_payment_process_request;

/*--------------------------------------------------------------------
 | NAME:
 |     get_payreq_list
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
 FUNCTION get_payreq_list (
     p_status IN IBY_PAY_SERVICE_REQUESTS.PAYMENT_SERVICE_REQUEST_STATUS%type)
     RETURN payreq_tbl_type
 IS

 payreq_list payreq_tbl_type;
 l_module_name       VARCHAR2(200) := G_PKG_NAME || '.get_payreq_list';

 CURSOR c_pay_req_list (
     c_status IN IBY_PAY_SERVICE_REQUESTS.PAYMENT_SERVICE_REQUEST_STATUS%type)
 IS
 SELECT
     payment_service_request_id
 FROM
     IBY_PAY_SERVICE_REQUESTS
 WHERE
     payment_service_request_status=c_status;

 BEGIN

     OPEN c_pay_req_list(p_status);
     FETCH c_pay_req_list BULK COLLECT INTO payreq_list;
     CLOSE c_pay_req_list;

     RETURN payreq_list;

 EXCEPTION
     WHEN OTHERS THEN
         RETURN payreq_list;

 END get_payreq_list;

/*--------------------------------------------------------------------
 | NAME:
 |     get_payreq_status
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
 FUNCTION get_payreq_status (
     l_payreq_id IN IBY_PAY_SERVICE_REQUESTS.payment_service_request_id%TYPE)
     RETURN VARCHAR2
 IS

 l_payreq_status     VARCHAR2(100);
 l_module_name       CONSTANT VARCHAR2(200) := G_PKG_NAME ||
                                                   '.get_payreq_status';

 BEGIN

     SELECT
         payment_service_request_status
     INTO
         l_payreq_status
     FROM
         IBY_PAY_SERVICE_REQUESTS
     WHERE
         payment_service_request_id = l_payreq_id;

     RETURN l_payreq_status;

 EXCEPTION
     WHEN OTHERS THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Exception occured when '
	             || 'retrieving payment request status for '
	             || 'payment request '
	             || l_payreq_id
	             );
	         print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	         print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);
	         print_debuginfo(l_module_name, 'Returning NULL for status');
         END IF;
         RETURN NULL;

 END get_payreq_status;

/*--------------------------------------------------------------------
 | NAME:
 |     checkIfPmtsInModifiedStatus
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
 FUNCTION checkIfPmtsInModifiedStatus(
     l_payreq_id IN IBY_PAY_SERVICE_REQUESTS.payment_service_request_id%TYPE)
     RETURN BOOLEAN
 IS

 l_ret_flag      BOOLEAN := FALSE;
 l_module_name   CONSTANT VARCHAR2(200) := G_PKG_NAME ||
                                               '.checkIfPmtsInModifiedStatus';
 l_test          VARCHAR2(200);

 BEGIN

    SELECT
        'TRUE'
    INTO
        l_test
    FROM
        DUAL
    WHERE
        EXISTS
        (
        SELECT
            payment_id
        FROM
            IBY_PAYMENTS_ALL
        WHERE
            payment_service_request_id = l_payreq_id         AND
            payment_status             = PAY_STATUS_MODIFIED
        )
    ;

    IF (l_test = 'TRUE') THEN
        l_ret_flag := TRUE;
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo(l_module_name, 'Returning flag as TRUE.');
        END IF;
    ELSE
        l_ret_flag := FALSE;
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo(l_module_name, 'Returning flag as FALSE.');
        END IF;
    END IF;

    RETURN l_ret_flag;

 EXCEPTION
     WHEN OTHERS THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Non-fatal: Exception occured when '
	             || 'testing whether payments in MODIFIED status exist for '
	             || 'request id '
	             || l_payreq_id
	             );

	         print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	         print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);

	         print_debuginfo(l_module_name, 'Return flag will be defaulted to '
	             || 'FALSE.'
	             );

         END IF;
         l_ret_flag := FALSE;

         RETURN l_ret_flag;

 END checkIfPmtsInModifiedStatus;

/*--------------------------------------------------------------------
 | NAME:
 |     checkIfPmtsInModBankAccStatus
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
 FUNCTION checkIfPmtsInModBankAccStatus(
     l_payreq_id IN IBY_PAY_SERVICE_REQUESTS.payment_service_request_id%TYPE)
     RETURN BOOLEAN
 IS

 l_ret_flag      BOOLEAN := FALSE;
 l_module_name   CONSTANT VARCHAR2(200) := G_PKG_NAME ||
                                               '.checkIfPmtsInModBankAccStatus';
 l_test          VARCHAR2(200);

 BEGIN

    SELECT
        'TRUE'
    INTO
        l_test
    FROM
        DUAL
    WHERE
        EXISTS
        (
        SELECT
            payment_id
        FROM
            IBY_PAYMENTS_ALL
        WHERE
            payment_service_request_id = l_payreq_id         AND
            payment_status             = PAY_STATUS_MOD_BNK_ACC
        )
    ;

    IF (l_test = 'TRUE') THEN
        l_ret_flag := TRUE;
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo(l_module_name, 'Returning flag as TRUE.');
        END IF;
    ELSE
        l_ret_flag := FALSE;
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo(l_module_name, 'Returning flag as FALSE.');
        END IF;
    END IF;

    RETURN l_ret_flag;

 EXCEPTION
     WHEN OTHERS THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Exception occured when testing '
	             || 'whether "modified bank account" payments exist for request id '
	             || l_payreq_id
	             );

	         print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	         print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);

	         print_debuginfo(l_module_name, 'Return flag will be defaulted to '
	             || 'FALSE.'
	             );

         END IF;
         l_ret_flag := FALSE;

         RETURN l_ret_flag;

 END checkIfPmtsInModBankAccStatus;

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
     p_payment_profile_id
                              IN IBY_PAY_SERVICE_REQUESTS.
                                     payment_profile_id%TYPE,
     p_allow_zero_payments_flag
                              IN IBY_PAY_SERVICE_REQUESTS.
                                     allow_zero_payments_flag%TYPE,
     p_maximum_payment_amount IN IBY_PAY_SERVICE_REQUESTS.
                                     maximum_payment_amount%TYPE,
     p_minimum_payment_amount IN IBY_PAY_SERVICE_REQUESTS.
                                     minimum_payment_amount%TYPE,
     p_doc_rej_level          IN IBY_PAY_SERVICE_REQUESTS.
                                     document_rejection_level_code%TYPE,
     p_pmt_rej_level          IN IBY_PAY_SERVICE_REQUESTS.
                                     payment_rejection_level_code%TYPE,
     p_revw_prop_pmts_flag    IN IBY_PAY_SERVICE_REQUESTS.
                                     require_prop_pmts_review_flag%TYPE,
     p_create_instrs_flag     IN IBY_PAY_SERVICE_REQUESTS.
                                     create_pmt_instructions_flag%TYPE,
     p_payment_document_id    IN IBY_PAY_SERVICE_REQUESTS.
                                     payment_document_id%TYPE,
     p_attribute_category     IN IBY_PAY_SERVICE_REQUESTS.
                                     attribute_category%TYPE,
     p_attribute1             IN IBY_PAY_SERVICE_REQUESTS.
                                     attribute1%TYPE,
     p_attribute2             IN IBY_PAY_SERVICE_REQUESTS.
                                     attribute2%TYPE,
     p_attribute3             IN IBY_PAY_SERVICE_REQUESTS.
                                     attribute3%TYPE,
     p_attribute4             IN IBY_PAY_SERVICE_REQUESTS.
                                     attribute4%TYPE,
     p_attribute5             IN IBY_PAY_SERVICE_REQUESTS.
                                     attribute5%TYPE,
     p_attribute6             IN IBY_PAY_SERVICE_REQUESTS.
                                     attribute6%TYPE,
     p_attribute7             IN IBY_PAY_SERVICE_REQUESTS.
                                     attribute7%TYPE,
     p_attribute8             IN IBY_PAY_SERVICE_REQUESTS.
                                     attribute8%TYPE,
     p_attribute9             IN IBY_PAY_SERVICE_REQUESTS.
                                     attribute9%TYPE,
     p_attribute10             IN IBY_PAY_SERVICE_REQUESTS.
                                     attribute10%TYPE,
     p_attribute11             IN IBY_PAY_SERVICE_REQUESTS.
                                     attribute11%TYPE,
     p_attribute12             IN IBY_PAY_SERVICE_REQUESTS.
                                     attribute12%TYPE,
     p_attribute13             IN IBY_PAY_SERVICE_REQUESTS.
                                     attribute13%TYPE,
     p_attribute14             IN IBY_PAY_SERVICE_REQUESTS.
                                     attribute14%TYPE,
     p_attribute15             IN IBY_PAY_SERVICE_REQUESTS.
                                     attribute15%TYPE
     )
     RETURN NUMBER
 IS

 l_payreq_id     IBY_PAY_SERVICE_REQUESTS.payment_service_request_id%TYPE;
 l_module_name   CONSTANT VARCHAR2(200) := G_PKG_NAME || '.insert_payreq';

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     l_payreq_id := getNextPayReqId();

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
         ALLOW_ZERO_PAYMENTS_FLAG,
         MAXIMUM_PAYMENT_AMOUNT,
         MINIMUM_PAYMENT_AMOUNT,
         INTERNAL_BANK_ACCOUNT_ID,
         PAYMENT_PROFILE_ID,
         DOCUMENT_REJECTION_LEVEL_CODE,
         PAYMENT_REJECTION_LEVEL_CODE,
         REQUIRE_PROP_PMTS_REVIEW_FLAG,
         CREATE_PMT_INSTRUCTIONS_FLAG,
         PAYMENT_DOCUMENT_ID,
         ATTRIBUTE_CATEGORY,
         ATTRIBUTE1,
         ATTRIBUTE2,
         ATTRIBUTE3,
         ATTRIBUTE4,
         ATTRIBUTE5,
         ATTRIBUTE6,
         ATTRIBUTE7,
         ATTRIBUTE8,
         ATTRIBUTE9,
         ATTRIBUTE10,
         ATTRIBUTE11,
         ATTRIBUTE12,
         ATTRIBUTE13,
         ATTRIBUTE14,
         ATTRIBUTE15
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
         'STANDARD',       -- hardcode to 'standard' in the build program
         DECODE(
             p_allow_zero_payments_flag, NULL, 'N', p_allow_zero_payments_flag
               ),
         p_maximum_payment_amount,
         p_minimum_payment_amount,
         p_internal_bank_account_id,
         p_payment_profile_id,
         p_doc_rej_level,
         p_pmt_rej_level,
         p_revw_prop_pmts_flag,
         p_create_instrs_flag,
         p_payment_document_id,
         p_attribute_category,
         p_attribute1,
         p_attribute2,
         p_attribute3,
         p_attribute4,
         p_attribute5,
         p_attribute6,
         p_attribute7,
         p_attribute8,
         p_attribute9,
         p_attribute10,
         p_attribute11,
         p_attribute12,
         p_attribute13,
         p_attribute14,
         p_attribute15
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
 |     checkIfDuplicate
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
 FUNCTION checkIfDuplicate(
     p_calling_app_id         IN IBY_PAY_SERVICE_REQUESTS.calling_app_id%TYPE,
     p_calling_app_payreq_cd  IN IBY_PAY_SERVICE_REQUESTS.
                                    call_app_pay_service_req_code%TYPE
     )
     RETURN NUMBER
 IS
 l_payreq_id     IBY_PAY_SERVICE_REQUESTS.payment_service_request_id%TYPE;
 l_module_name   CONSTANT VARCHAR2(200) := G_PKG_NAME || '.checkIfDuplicate';
 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     /*
      * Check if a payment request id exists for the
      * given calling app.
      */
     SELECT
         payment_service_request_id INTO l_payreq_id
     FROM
         IBY_PAY_SERVICE_REQUESTS
     WHERE
         calling_app_id = p_calling_app_id
     AND
         call_app_pay_service_req_code = p_calling_app_payreq_cd;

     /*
      * If we found a row, then the request is a duplicate
      */
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Calling app payment request '
	         || p_calling_app_payreq_cd
	         || ' is a duplicate for calling app '
	         || p_calling_app_id
	         || '. Previously generated payment request id: '
	         || l_payreq_id);

	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
     RETURN l_payreq_id;

     EXCEPTION

         WHEN NO_DATA_FOUND THEN
                 /*
                  * Means that this is a new payment request
                  * for this calling app.
                  */
                 l_payreq_id := 0;
                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'This is a new '
	                     || 'payment request. Returning 0.'
	                     );

	                 print_debuginfo(l_module_name, 'EXIT');

                 END IF;
                 RETURN l_payreq_id;

         WHEN OTHERS THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Fatal: Exception when '
	                 || 'attempting to check whether provided calling '
	                 || 'app payment request '
	                 || p_calling_app_payreq_cd
	                 || ' is a duplicate. Aborting program ..',
	                 FND_LOG.LEVEL_UNEXPECTED
	                 );
	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE,
	                 FND_LOG.LEVEL_UNEXPECTED);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM,
	                 FND_LOG.LEVEL_UNEXPECTED);
	             print_debuginfo(l_module_name, 'EXIT');

             END IF;
             /*
              * Propogate exception to caller.
              */
             RAISE;

 END checkIfDuplicate;

/*--------------------------------------------------------------------
 | NAME:
 |     derivePayeeIdFromContext
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
 FUNCTION derivePayeeIdFromContext(
     p_payee_party_id         IN IBY_EXTERNAL_PAYEES_ALL.payee_party_id%TYPE,
     p_payee_party_site_id    IN IBY_EXTERNAL_PAYEES_ALL.party_site_id%TYPE,
     p_supplier_site_id       IN IBY_EXTERNAL_PAYEES_ALL.supplier_site_id%TYPE,
     p_org_id                 IN IBY_EXTERNAL_PAYEES_ALL.org_id%TYPE,
     p_org_type               IN IBY_EXTERNAL_PAYEES_ALL.org_type%TYPE,
     p_pmt_function           IN IBY_EXTERNAL_PAYEES_ALL.payment_function%TYPE
     )
     RETURN NUMBER
 IS
 l_payee_id     IBY_EXTERNAL_PAYEES_ALL.ext_payee_id%TYPE;
 l_module_name  CONSTANT VARCHAR2(200) := G_PKG_NAME ||
                                              '.derivePayeeIdFromContext';

 l_payee_party_site_id IBY_EXTERNAL_PAYEES_ALL.party_site_id%TYPE;

 l_payee_index      VARCHAR2(200);


 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

	     print_debuginfo(l_module_name, 'Given payee context:'
	         || ' payee party id '
	         || p_payee_party_id
	         || ', party site id '
	         || p_payee_party_site_id
	         || ', supplier site id '
	         || p_supplier_site_id
	         || ', org id '
	         || p_org_id
	         || ', org type '
	         || p_org_type
	         || ', pmt_function '
	         || p_pmt_function
	         );

     END IF;
     /*
      * Adding Caching Logic to avoid database hits for the same input
      * combination.
      *
      */
      l_payee_index :=    to_char(p_payee_party_id)
                       || '$$'
                       || to_char(p_payee_party_site_id)
                       || '$$'
                       || to_char(p_supplier_site_id)
                       || '$$'
                       || to_char(p_org_id)
                       || '$$'
                       || p_org_type
                       || '$$'
                       || p_pmt_function;

      IF (l_payee_id_tbl.EXISTS(l_payee_index)) THEN
         RETURN l_payee_id_tbl(l_payee_index);
      END IF;

     /*
      * SPECIAL HANDLING FOR LOAN PAYMENTS:
      *
      * For loan payments, treat party site id as null
      * when performing external payee id match via
      * payee context.
      *
      * See bug 4700623.
      */
     l_payee_party_site_id := p_payee_party_site_id;

     IF (p_pmt_function = 'LOANS_PAYMENTS') THEN

         l_payee_party_site_id := NULL;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Special handling for loans payments; '
	             || 'the payee party id has been set to null for context match.'
	             );

         END IF;
     END IF;

     /*
      * Attempt to make an exact match for the given payee context;
      * if that doesn't work, attempt to match the partial payee
      * context.
      *
      * In every case, the 'payee party id' and 'payment function'
      * fields will always be part of the payee context that is
      * used to derive the external payee id.
      */

     /*
      * ATTEMPT I: EXACT MATCH
      *
      * Check if a payee id exists for the given combination
      * of (payee party id, payee party site id, supplier site id,
      * org id and org type). These fields define a payee context.
      */
     BEGIN

         SELECT
             ext_payee_id INTO l_payee_id
         FROM
             IBY_EXTERNAL_PAYEES_ALL
         WHERE
             payee_party_id              = p_payee_party_id                AND
             payment_function            = p_pmt_function                  AND
             NVL(party_site_id,     '0') = NVL(l_payee_party_site_id, '0') AND
             NVL(supplier_site_id,  '0') = NVL(p_supplier_site_id,    '0') AND
             NVL(org_id,            '0') = NVL(p_org_id,              '0') AND
             NVL(org_type,          '0') = NVL(p_org_type,            '0') AND
             NVL(INACTIVE_DATE,SYSDATE)  >= SYSDATE
             ;

         /*
          * If we found a row, then the given payee context was
          * exactly matched. Return the retrieved payee id.
          */
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Payee id '
	             || l_payee_id
	             || ' exactly matched given payee context.'
	             || ' Caching before exiting.'
	             );

         END IF;
         l_payee_id_tbl(l_payee_index) := l_payee_id;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN l_payee_id;

     EXCEPTION

         WHEN NO_DATA_FOUND THEN
             /*
              * Means that a payee could not be exactly
              * matched for the given payee context.
              */
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'No Payee was '
	                 || ' exactly matched for the given payee context.'
	                 );

             END IF;
         WHEN OTHERS THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Fatal: Exception when '
	                 || 'attempting to perform exact match for given '
	                 || 'payee context.',
	                 FND_LOG.LEVEL_UNEXPECTED
	                 );

	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE,
	                 FND_LOG.LEVEL_UNEXPECTED);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM,
	                 FND_LOG.LEVEL_UNEXPECTED);
	             print_debuginfo(l_module_name, 'EXIT');

             END IF;
             /*
              * Propogate exception to caller.
              */
             RAISE;
     END;

     /*
      * ATTEMPT II: PARTIAL MATCH
      *
      * Check if a payee id exists for the combination
      * of (payee party id, payee party site id).
      * These fields define a partial payee context.
      */
     BEGIN

         SELECT
             ext_payee_id INTO l_payee_id
         FROM
             IBY_EXTERNAL_PAYEES_ALL
         WHERE
             payee_party_id              = p_payee_party_id                AND
             payment_function            = p_pmt_function                  AND
             NVL(party_site_id, '0')     = NVL(l_payee_party_site_id, '0') AND
             supplier_site_id      IS NULL                                 AND
             org_id                IS NULL                                 AND
             org_type              IS NULL                                 AND
             NVL(INACTIVE_DATE,SYSDATE)  >= SYSDATE
             ;

         /*
          * If we found a row, then the given partial payee
          * context was matched. Return the retrieved payee id.
          */
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Payee id '
	             || l_payee_id
	             || ' matched given partial payee context '
	             || ' Caching before exiting.'
	             );

         END IF;
         l_payee_id_tbl(l_payee_index) := l_payee_id;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN l_payee_id;

     EXCEPTION

         WHEN NO_DATA_FOUND THEN
             /*
              * Means that a payee could not be matched
              * for the given partial payee context.
              */
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'No Payee was '
	                 || 'matched for the given partial payee '
	                 || 'context of (payee party id, payment function '
	                 || 'payee party site id).'
	                 );

             END IF;
         WHEN OTHERS THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Fatal: Exception when '
	                 || 'attempting to perform match for given partial '
	                 || 'payee context of (payee party id, payment function '
	                 || ', payee party site id).',
	                 FND_LOG.LEVEL_UNEXPECTED
	                 );

	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE,
	                 FND_LOG.LEVEL_UNEXPECTED);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM,
	                 FND_LOG.LEVEL_UNEXPECTED);
	             print_debuginfo(l_module_name, 'EXIT');

             END IF;
             /*
              * Propogate exception to caller.
              */
             RAISE;
     END;

     /*
      * ATTEMPT III: PARTIAL MATCH
      *
      * Check if a payee id exists for the given
      * payee party id. This fields defines a partial
      * payee context.
      */
     BEGIN

         SELECT
             ext_payee_id INTO l_payee_id
         FROM
             IBY_EXTERNAL_PAYEES_ALL
         WHERE
             payee_party_id   = p_payee_party_id        AND
             payment_function = p_pmt_function          AND
             party_site_id         IS NULL              AND
             supplier_site_id      IS NULL              AND
             org_id                IS NULL              AND
             org_type              IS NULL              AND
             NVL(INACTIVE_DATE,SYSDATE)  >= SYSDATE
             ;

         /*
          * If we found a row, then the given partial payee
          * context was matched. Return the retrieved payee id.
          */
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Payee id '
	             || l_payee_id
	             || ' matched given partial payee context '
	             || 'of (payee party id, payment function).'
	             || ' Caching before exiting.'
	             );

         END IF;
         l_payee_id_tbl(l_payee_index) := l_payee_id;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN l_payee_id;

     EXCEPTION

         WHEN NO_DATA_FOUND THEN
             /*
              * Means that a payee could not be matched
              * for the given partial payee context.
              */
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'No Payee was '
	                 || 'matched for the given partial payee '
	                 || 'context of (payee party id, payment function).'
	                 );

             END IF;
         WHEN OTHERS THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Fatal: Exception when '
	                 || 'attempting to perform match for given partial '
	                 || 'payee context of (payee party id, payment function).',
	                 FND_LOG.LEVEL_UNEXPECTED
	                 );

	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE,
	                 FND_LOG.LEVEL_UNEXPECTED);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM,
	                 FND_LOG.LEVEL_UNEXPECTED);
	             print_debuginfo(l_module_name, 'EXIT');

             END IF;
             /*
              * Propogate exception to caller.
              */
             RAISE;
     END;

     /*
      * END OF ATTEMPTS:
      *
      * If we reached here it means that the payee id could not
      * be matched from the given payee context (both exact
      * match and partial match have failed).
      *
      * This means that we have received a document payable for
      * the payee id is unknown. This document therefore cannot
      * be paid; it has to be failed.
      *
      * Return -1 to indicate that a payee id was not found
      * for the given context.
      */
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'No Payee was '
	         || 'matched for the given payee context '
	         || '(even partial context match failed). '
	         || 'Returning -1 for the payee id.'
	         );

     END IF;
         l_payee_id := -1;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN l_payee_id;

 END derivePayeeIdFromContext;

/*--------------------------------------------------------------------
 | NAME:
 |     deriveExactPayeeIdFromContext
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
 FUNCTION deriveExactPayeeIdFromContext(
     p_payee_party_id         IN IBY_EXTERNAL_PAYEES_ALL.payee_party_id%TYPE,
     p_payee_party_site_id    IN IBY_EXTERNAL_PAYEES_ALL.party_site_id%TYPE,
     p_supplier_site_id       IN IBY_EXTERNAL_PAYEES_ALL.supplier_site_id%TYPE,
     p_org_id                 IN IBY_EXTERNAL_PAYEES_ALL.org_id%TYPE,
     p_org_type               IN IBY_EXTERNAL_PAYEES_ALL.org_type%TYPE,
     p_pmt_function           IN IBY_EXTERNAL_PAYEES_ALL.payment_function%TYPE
     )
     RETURN NUMBER
 IS
 l_payee_id     IBY_EXTERNAL_PAYEES_ALL.ext_payee_id%TYPE;
 l_module_name  CONSTANT VARCHAR2(200) := G_PKG_NAME ||
                                              '.deriveExactPayeeIdFromContext';

 l_payee_party_site_id IBY_EXTERNAL_PAYEES_ALL.party_site_id%TYPE;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

	     print_debuginfo(l_module_name, 'Given payee context:'
	         || ' payee party id '
	         || p_payee_party_id
	         || ', party site id '
	         || p_payee_party_site_id
	         || ', supplier site id '
	         || p_supplier_site_id
	         || ', org id '
	         || p_org_id
	         || ', org type '
	         || p_org_type
	         || ', pmt_function '
	         || p_pmt_function
	         );

     END IF;
     /*
      * SPECIAL HANDLING FOR LOAN PAYMENTS:
      *
      * For loan payments, treat party site id as null
      * when performing external payee id match via
      * payee context.
      *
      * See bug 4700623.
      */
     l_payee_party_site_id := p_payee_party_site_id;

     IF (p_pmt_function = 'LOANS_PAYMENTS') THEN

         l_payee_party_site_id := NULL;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Special handling for loans payments; '
	             || 'the payee party id has been set to null for context match.'
	             );

         END IF;
     END IF;

     /*
      * Attempt to make an exact match for the given payee context;
      * if that doesn't work, attempt to match the partial payee
      * context.
      *
      * In every case, the 'payee party id' and 'payment function'
      * fields will always be part of the payee context that is
      * used to derive the external payee id.
      */

     /*
      * EXACT MATCH:
      *
      * Check if a payee id exists for the given combination
      * of (payee party id, payee party site id, supplier site id,
      * org id and org type). These fields define a payee context.
      */
     BEGIN

         SELECT
             ext_payee_id INTO l_payee_id
         FROM
             IBY_EXTERNAL_PAYEES_ALL
         WHERE
             payee_party_id              = p_payee_party_id                AND
             payment_function            = p_pmt_function                  AND
             NVL(party_site_id,     '0') = NVL(l_payee_party_site_id, '0') AND
             NVL(supplier_site_id,  '0') = NVL(p_supplier_site_id,    '0') AND
             NVL(org_id,            '0') = NVL(p_org_id,              '0') AND
             NVL(org_type,          '0') = NVL(p_org_type,            '0') AND
             NVL(INACTIVE_DATE,SYSDATE)  >= SYSDATE
             ;

         /*
          * If we found a row, then the given payee context was
          * exactly matched. Return the retrieved payee id.
          */
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Payee id '
	             || l_payee_id
	             || ' exactly matched given payee context.'
	             );

	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN l_payee_id;

     EXCEPTION

         WHEN NO_DATA_FOUND THEN
             /*
              * Means that a payee could not be exactly
              * matched for the given payee context.
              */
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'No Payee was '
	                 || ' exactly matched for the given payee context.'
	                 );

             END IF;
         WHEN OTHERS THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Fatal: Exception when '
	                 || 'attempting to perform exact match for given '
	                 || 'payee context.',
	                 FND_LOG.LEVEL_UNEXPECTED
	                 );

	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE,
	                 FND_LOG.LEVEL_UNEXPECTED);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM,
	                 FND_LOG.LEVEL_UNEXPECTED);
	             print_debuginfo(l_module_name, 'EXIT');

             END IF;
             /*
              * Propogate exception to caller.
              */
             RAISE;
     END;

     /*
      * END OF ATTEMPT:
      *
      * If we reached here it means that the payee id could not
      * be matched from the given payee context (exact
      * match failed).
      *
      * Return -1 to indicate that a payee id was not found
      * for the given context.
      */
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'No Payee was '
	         || 'matched for the given payee context. '
	         || 'Returning -1 for the payee id.'
	         );

     END IF;
         l_payee_id := -1;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN l_payee_id;

 END deriveExactPayeeIdFromContext;

/*--------------------------------------------------------------------
 | NAME:
 |     getNextPayReqID
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
 FUNCTION getNextPayReqID
     RETURN NUMBER
 IS
 l_payreq_id     NUMBER(15);

 BEGIN

     SELECT IBY_PAY_SERVICE_REQUESTS_S.nextval INTO l_payreq_id
         FROM DUAL;

     RETURN l_payreq_id;

 END getNextPayReqID;

/*--------------------------------------------------------------------
 | NAME:
 |     insert_payreq_documents
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
 FUNCTION insert_payreq_documents (
     p_calling_app_id        IN IBY_PAY_SERVICE_REQUESTS.calling_app_id%TYPE,
     p_calling_app_payreq_cd IN IBY_PAY_SERVICE_REQUESTS.
                                    call_app_pay_service_req_code%TYPE,
     p_payreq_id             IN IBY_PAY_SERVICE_REQUESTS.
                                    payment_service_request_id%TYPE
     )
     RETURN NUMBER
 IS

 l_return_status    NUMBER := -1;
 l_app_short_name   VARCHAR2(200);

 l_view_name          VARCHAR2(200);

 TYPE dyn_documents   IS REF CURSOR;
 l_docs_cursor        dyn_documents;

 l_lines_view_name      VARCHAR2(200);

 /* payee conext generated internally based on supplied payee fields */
 l_payee_id             IBY_EXTERNAL_PAYEES_ALL.ext_payee_id%TYPE;

 l_pmtFxAccessTypesTab  distinctPmtFxAccessTab;
 l_orgAccessTypesTab    distinctOrgAccessTab;

 l_module_name          CONSTANT VARCHAR2(200) := G_PKG_NAME ||
                                                  '.insert_payreq_documents';

 l_trx_line_index       BINARY_INTEGER;
 l_no_rec_in_ppr        BOOLEAN;
 G_LINES_PER_FETCH       CONSTANT  NUMBER:= 1000;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     /*
      * Get the shortname of the calling app from the calling
      * app id.
      */
     SELECT
         fnd.application_short_name
     INTO
         l_app_short_name
     FROM
         FND_APPLICATION fnd
     WHERE
         fnd.application_id = p_calling_app_id;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Calling app short name: '
	         || l_app_short_name);

     END IF;
     /*
      * For some applications, the application short name cannot
      * be directly used in forming the view name.
      *
      * Example, for AP, the application short name is 'SQLAP',
      * but the AP tables/views begin as 'AP_XXXX'. Therefore,
      * we will convert the application short names into table
      * prefixes here.
      */
     CASE l_app_short_name
         WHEN 'SQLAP' THEN
             l_app_short_name := 'AP';
         ELSE
             /* do nothing */
             NULL;
     END CASE;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Processed calling app short name: '
	         || l_app_short_name);

     END IF;
     /*
      * Dynamically form the view name.
      *
      * The view name is dependent upon the calling
      * app name and will be of the form
      * <calling app name>_DOCUMENTS_PAYABLE.
      */
     l_view_name := l_app_short_name || '_DOCUMENTS_PAYABLE';

     /*
      * Read the documents for this payment service request
      * from the calling app's view. The calling app's view
      * will be prefixed with the application short name.
      */
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Going to fetch'
	         || ' documents from ' || l_view_name
	         || ' table using calling app id '
	         || p_calling_app_id
	         || ' and calling app pay req cd '
	         || p_calling_app_payreq_cd
	         || ' as keys');

     END IF;
     l_no_rec_in_ppr := TRUE;

     /* old select - for reference purposes */
     /*----------------------------------
     OPEN l_docs_cursor FOR
         'SELECT * FROM '
             || l_view_name
             || ' WHERE calling_app_id = :ca_id'
             || ' AND call_app_pay_service_req_code = :ca_payreq_cd'
         USING
             p_calling_app_id,
             p_calling_app_payreq_cd
         ;
     ------------------------------------*/

     /*
      * Ensure that the order of the columns in this SELECT matches
      * exactly with the order of the columns of the template table
      * IBY_GEN_DOCS_PAYABLE.
      *
      * By using names columns in this SELECT (instead of select *),
      * we are making it possible for the external application to
      * have a slightly different column ordering that what is
      * present in IBY_GEN_DOCS_PAYABLE (otherwise, the ordering
      * becomes strict).
      */
     OPEN l_docs_cursor FOR
         'SELECT '
             || 'pay_proc_trxn_type_code,            '
             || 'calling_app_id,                     '
             || 'calling_app_doc_unique_ref1,        '
             || 'calling_app_doc_unique_ref2,        '
             || 'calling_app_doc_unique_ref3,        '
             || 'calling_app_doc_unique_ref4,        '
             || 'calling_app_doc_unique_ref5,        '
             || 'calling_app_doc_ref_number,         '
             || 'call_app_pay_service_req_code,      '
             || 'IBY_DOCS_PAYABLE_ALL_S.nextval,     '
             || 'payment_function,                   '
             || 'payment_date,                       '
             || 'document_date,                      '
             || 'document_type,                      '
             || 'document_currency_code,             '
             || 'document_amount,                    '
             || 'payment_currency_code,              '
             || 'payment_amount,                     '
             || 'payment_method_code,                '
             || 'exclusive_payment_flag,             '
             || 'remit_payee_party_id,                     '
             || 'remit_party_site_id,                      '
             || 'remit_supplier_site_id,                   '
             || 'remit_beneficiary_party,                  '
             || 'legal_entity_id,                    '
             || 'org_id,                             '
             || 'org_type,                           '
             || 'allow_removing_document_flag,       '
             || 'created_by,                         '    -- Ramesh, Why r we selecting this?
             || 'creation_date,                      '
             || 'last_updated_by,                    '
             || 'last_update_date,                   '
             || 'last_update_login,                  '
             || 'object_version_number,              '
             || 'anticipated_value_date,             '
             || 'po_number,                          '
             || 'document_description,               '
             || 'document_currency_tax_amount,       '
             || 'document_curr_charge_amount,        '
             || 'amount_withheld,                    '
             || 'payment_curr_discount_taken,        '
             || 'discount_date,                      '
             || 'payment_due_date,                   '
             || 'payment_profile_id,                 '
             || 'internal_bank_account_id,           '
             || 'external_bank_account_id,           '
             || 'bank_charge_bearer,                 '
             || 'interest_rate,                      '
             || 'payment_grouping_number,            '
             || 'payment_reason_code,                '
             || 'payment_reason_comments,            '
             || 'settlement_priority,                '
             || 'remittance_message1,                '
             || 'remittance_message2,                '
             || 'remittance_message3,                '
             || 'unique_remittance_identifier,       '
             || 'uri_check_digit,                    '
             || 'delivery_channel_code,              '
             || 'payment_format_code,                '
             || 'document_sequence_id,               '
             || 'document_sequence_value,            '
             || 'document_category_code,             '
             || 'bank_assigned_ref_code,             '
             || 'remit_to_location_id,               '
             || 'attribute_category,                 '
             || 'attribute1,                         '
             || 'attribute2,                         '
             || 'attribute3,                         '
             || 'attribute4,                         '
             || 'attribute5,                         '
             || 'attribute6,                         '
             || 'attribute7,                         '
             || 'attribute8,                         '
             || 'attribute9,                         '
             || 'attribute10,                        '
             || 'attribute11,                        '
             || 'attribute12,                        '
             || 'attribute13,                        '
             || 'attribute14,                        '
             || 'attribute15,                        '
             || 'address_source,                     '
             || 'employee_address_code,              '
             || 'employee_person_id,                 '
             || 'employee_payment_flag,              '
             || 'employee_address_id,                '
             || 'payee_party_id,		'
             || 'party_site_id,		'
             || 'supplier_site_id,	'
             || 'beneficiary_party,	'
             || 'relationship_id,		'
             || 'global_attribute_category,          '
             || 'global_attribute1,		     '
             || 'global_attribute2,		     '
             || 'global_attribute3,		     '
             || 'global_attribute4,		     '
             || 'global_attribute5,		     '
             || 'global_attribute6,		     '
             || 'global_attribute7,		     '
             || 'global_attribute8,		     '
             || 'global_attribute9,		     '
             || 'global_attribute10,		     '
             || 'global_attribute11,		     '
             || 'global_attribute12,		     '
             || 'global_attribute13,		     '
             || 'global_attribute14,		     '
             || 'global_attribute15,		     '
             || 'global_attribute16,		     '
             || 'global_attribute17,		     '
             || 'global_attribute18,		     '
             || 'global_attribute19,		     '
             || 'global_attribute20		     '
         || 'FROM '
             || l_view_name
             || ' WHERE calling_app_id = :ca_id'
             || ' AND call_app_pay_service_req_code = :ca_payreq_cd'
         USING
             p_calling_app_id,
             p_calling_app_payreq_cd
         ;

     LOOP

     delete_docspayTab;

     FETCH l_docs_cursor BULK COLLECT INTO
        iby_disburse_submit_pub_pkg.docspayTab.pay_proc_trxn_type_code           ,
        iby_disburse_submit_pub_pkg.docspayTab.calling_app_id                    ,
        iby_disburse_submit_pub_pkg.docspayTab.calling_app_doc_unique_ref1       ,
        iby_disburse_submit_pub_pkg.docspayTab.calling_app_doc_unique_ref2       ,
        iby_disburse_submit_pub_pkg.docspayTab.calling_app_doc_unique_ref3       ,
        iby_disburse_submit_pub_pkg.docspayTab.calling_app_doc_unique_ref4       ,
        iby_disburse_submit_pub_pkg.docspayTab.calling_app_doc_unique_ref5       ,
        iby_disburse_submit_pub_pkg.docspayTab.calling_app_doc_ref_number        ,
        iby_disburse_submit_pub_pkg.docspayTab.call_app_pay_service_req_code     ,
        iby_disburse_submit_pub_pkg.docspayTab.document_payable_id               ,
        iby_disburse_submit_pub_pkg.docspayTab.payment_function                  ,
        iby_disburse_submit_pub_pkg.docspayTab.payment_date                      ,
        iby_disburse_submit_pub_pkg.docspayTab.document_date                     ,
        iby_disburse_submit_pub_pkg.docspayTab.document_type                     ,
        iby_disburse_submit_pub_pkg.docspayTab.document_currency_code            ,
        iby_disburse_submit_pub_pkg.docspayTab.document_amount                   ,
        iby_disburse_submit_pub_pkg.docspayTab.payment_currency_code             ,
        iby_disburse_submit_pub_pkg.docspayTab.payment_amount                    ,
        iby_disburse_submit_pub_pkg.docspayTab.payment_method_code               ,
        iby_disburse_submit_pub_pkg.docspayTab.exclusive_payment_flag            ,
        iby_disburse_submit_pub_pkg.docspayTab.payee_party_id                    ,
        iby_disburse_submit_pub_pkg.docspayTab.party_site_id                     ,
        iby_disburse_submit_pub_pkg.docspayTab.supplier_site_id                  ,
        iby_disburse_submit_pub_pkg.docspayTab.beneficiary_party                 ,
        iby_disburse_submit_pub_pkg.docspayTab.legal_entity_id                   ,
        iby_disburse_submit_pub_pkg.docspayTab.org_id                            ,
        iby_disburse_submit_pub_pkg.docspayTab.org_type                          ,
        iby_disburse_submit_pub_pkg.docspayTab.allow_removing_document_flag      ,
        iby_disburse_submit_pub_pkg.docspayTab.created_by                        ,
        iby_disburse_submit_pub_pkg.docspayTab.creation_date                     ,
        iby_disburse_submit_pub_pkg.docspayTab.last_updated_by                   ,
        iby_disburse_submit_pub_pkg.docspayTab.last_update_date                  ,
        iby_disburse_submit_pub_pkg.docspayTab.last_update_login                 ,
        iby_disburse_submit_pub_pkg.docspayTab.object_version_number             ,
        iby_disburse_submit_pub_pkg.docspayTab.anticipated_value_date            ,
        iby_disburse_submit_pub_pkg.docspayTab.po_number                         ,
        iby_disburse_submit_pub_pkg.docspayTab.document_description              ,
        iby_disburse_submit_pub_pkg.docspayTab.document_currency_tax_amount      ,
        iby_disburse_submit_pub_pkg.docspayTab.document_curr_charge_amount       ,
        iby_disburse_submit_pub_pkg.docspayTab.amount_withheld                   ,
        iby_disburse_submit_pub_pkg.docspayTab.payment_curr_discount_taken       ,
        iby_disburse_submit_pub_pkg.docspayTab.discount_date                     ,
        iby_disburse_submit_pub_pkg.docspayTab.payment_due_date                  ,
        iby_disburse_submit_pub_pkg.docspayTab.payment_profile_id                ,
        iby_disburse_submit_pub_pkg.docspayTab.internal_bank_account_id          ,
        iby_disburse_submit_pub_pkg.docspayTab.external_bank_account_id          ,
        iby_disburse_submit_pub_pkg.docspayTab.bank_charge_bearer                ,
        iby_disburse_submit_pub_pkg.docspayTab.interest_rate                     ,
        iby_disburse_submit_pub_pkg.docspayTab.payment_grouping_number           ,
        iby_disburse_submit_pub_pkg.docspayTab.payment_reason_code               ,
        iby_disburse_submit_pub_pkg.docspayTab.payment_reason_comments           ,
        iby_disburse_submit_pub_pkg.docspayTab.settlement_priority               ,
        iby_disburse_submit_pub_pkg.docspayTab.remittance_message1               ,
        iby_disburse_submit_pub_pkg.docspayTab.remittance_message2               ,
        iby_disburse_submit_pub_pkg.docspayTab.remittance_message3               ,
        iby_disburse_submit_pub_pkg.docspayTab.unique_remittance_identifier      ,
        iby_disburse_submit_pub_pkg.docspayTab.uri_check_digit                   ,
        iby_disburse_submit_pub_pkg.docspayTab.delivery_channel_code             ,
        iby_disburse_submit_pub_pkg.docspayTab.payment_format_code               ,
        iby_disburse_submit_pub_pkg.docspayTab.document_sequence_id              ,
        iby_disburse_submit_pub_pkg.docspayTab.document_sequence_value           ,
        iby_disburse_submit_pub_pkg.docspayTab.document_category_code            ,
        iby_disburse_submit_pub_pkg.docspayTab.bank_assigned_ref_code            ,
        iby_disburse_submit_pub_pkg.docspayTab.remit_to_location_id              ,
        iby_disburse_submit_pub_pkg.docspayTab.attribute_category                ,
        iby_disburse_submit_pub_pkg.docspayTab.attribute1                        ,
        iby_disburse_submit_pub_pkg.docspayTab.attribute2                        ,
        iby_disburse_submit_pub_pkg.docspayTab.attribute3                        ,
        iby_disburse_submit_pub_pkg.docspayTab.attribute4                        ,
        iby_disburse_submit_pub_pkg.docspayTab.attribute5                        ,
        iby_disburse_submit_pub_pkg.docspayTab.attribute6                        ,
        iby_disburse_submit_pub_pkg.docspayTab.attribute7                        ,
        iby_disburse_submit_pub_pkg.docspayTab.attribute8                        ,
        iby_disburse_submit_pub_pkg.docspayTab.attribute9                        ,
        iby_disburse_submit_pub_pkg.docspayTab.attribute10                       ,
        iby_disburse_submit_pub_pkg.docspayTab.attribute11                       ,
        iby_disburse_submit_pub_pkg.docspayTab.attribute12                       ,
        iby_disburse_submit_pub_pkg.docspayTab.attribute13                       ,
        iby_disburse_submit_pub_pkg.docspayTab.attribute14                       ,
        iby_disburse_submit_pub_pkg.docspayTab.attribute15                       ,
        iby_disburse_submit_pub_pkg.docspayTab.address_source                    ,
        iby_disburse_submit_pub_pkg.docspayTab.employee_address_code             ,
        iby_disburse_submit_pub_pkg.docspayTab.employee_person_id                ,
        iby_disburse_submit_pub_pkg.docspayTab.employee_payment_flag             ,
        iby_disburse_submit_pub_pkg.docspayTab.employee_address_id               ,
	 /*TPP-Start*/
        iby_disburse_submit_pub_pkg.docspayTab.inv_payee_party_id                ,
        iby_disburse_submit_pub_pkg.docspayTab.inv_party_site_id                 ,
        iby_disburse_submit_pub_pkg.docspayTab.inv_supplier_site_id              ,
        iby_disburse_submit_pub_pkg.docspayTab.inv_beneficiary_party                   ,
        iby_disburse_submit_pub_pkg.docspayTab.relationship_id                   ,
	 /*TPP-End*/
         /*German Format*/
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute_category         ,
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute1                 ,
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute2                 ,
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute3                 ,
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute4                 ,
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute5                 ,
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute6                 ,
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute7                 ,
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute8                 ,
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute9                 ,
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute10                ,
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute11                ,
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute12                ,
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute13                ,
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute14                ,
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute15                ,
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute16                ,
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute17                ,
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute18                ,
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute19                ,
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute20
        /*German Format*/
     LIMIT G_LINES_PER_FETCH;

     FOR l_trx_line_index IN nvl(iby_disburse_submit_pub_pkg.docspayTab.pay_proc_trxn_type_code.FIRST,0) .. nvl(iby_disburse_submit_pub_pkg.docspayTab.pay_proc_trxn_type_code.LAST,-99)
     LOOP
        l_no_rec_in_ppr := FALSE;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Processed document payable id: '
	         || to_char(iby_disburse_submit_pub_pkg.docspayTab.document_payable_id(l_trx_line_index)));

     END IF;
     /*
      * Populate rest of the document attributes required in the table
      * IBY_DOCS_PAYABLE_ALL into a PLSQL record structure.
      * We will use this structure in doing a bulk insert into the
      * IBY_DOCS_PAYABLE_ALL table.
      */
         iby_disburse_submit_pub_pkg.docspayTab.payment_service_request_id(l_trx_line_index)
                                            := p_payreq_id;
--         iby_disburse_submit_pub_pkg.docspayTab.document_payable_id
--                                            := getNextDocumentPayableID();
         --
         -- Set document status ot 'submitted' when docs are first inserted
         -- into the IBY_DOCS_PAYABLE_ALL table.
         --
         iby_disburse_submit_pub_pkg.docspayTab.document_status(l_trx_line_index)   := DOC_STATUS_SUBMITTED;

         iby_disburse_submit_pub_pkg.docspayTab.exclusive_payment_flag(l_trx_line_index)
                                            := NVL(iby_disburse_submit_pub_pkg.docspayTab.exclusive_payment_flag(l_trx_line_index), 'N');

         --
         -- From the given payee context (payee party id, payee party site
         -- id, supplier site id, org id and org type) on the document,
         -- derive the payee id from the IBY_EXTERNAL_PAYEES_ALL table.
         --
         l_payee_id := derivePayeeIdFromContext(
                           iby_disburse_submit_pub_pkg.docspayTab.payee_party_id(l_trx_line_index),
                           iby_disburse_submit_pub_pkg.docspayTab.party_site_id(l_trx_line_index),
                           iby_disburse_submit_pub_pkg.docspayTab.supplier_site_id(l_trx_line_index),
                           iby_disburse_submit_pub_pkg.docspayTab.org_id(l_trx_line_index),
                           iby_disburse_submit_pub_pkg.docspayTab.org_type(l_trx_line_index),
                           iby_disburse_submit_pub_pkg.docspayTab.payment_function(l_trx_line_index)
                           );

         -- Store the external payee id as an attribute of the document
         iby_disburse_submit_pub_pkg.docspayTab.ext_payee_id(l_trx_line_index)    := l_payee_id;

         l_payee_id := derivePayeeIdFromContext(
                           iby_disburse_submit_pub_pkg.docspayTab.inv_payee_party_id(l_trx_line_index),
                           iby_disburse_submit_pub_pkg.docspayTab.inv_party_site_id(l_trx_line_index),
                           iby_disburse_submit_pub_pkg.docspayTab.inv_supplier_site_id(l_trx_line_index),
                           iby_disburse_submit_pub_pkg.docspayTab.org_id(l_trx_line_index),
                           iby_disburse_submit_pub_pkg.docspayTab.org_type(l_trx_line_index),
                           iby_disburse_submit_pub_pkg.docspayTab.payment_function(l_trx_line_index)
                           );

         -- Store the external inv payee id as an attribute of the document
         iby_disburse_submit_pub_pkg.docspayTab.ext_inv_payee_id(l_trx_line_index)    := l_payee_id;

         iby_disburse_submit_pub_pkg.docspayTab.created_by(l_trx_line_index)      := fnd_global.user_id;
         iby_disburse_submit_pub_pkg.docspayTab.creation_date(l_trx_line_index)   := sysdate;
         iby_disburse_submit_pub_pkg.docspayTab.last_updated_by(l_trx_line_index) := fnd_global.user_id;
         iby_disburse_submit_pub_pkg.docspayTab.last_update_date(l_trx_line_index)  := sysdate;
         iby_disburse_submit_pub_pkg.docspayTab.last_update_login(l_trx_line_index) := fnd_global.login_id;
         iby_disburse_submit_pub_pkg.docspayTab.object_version_number(l_trx_line_index) := 1;

         iby_disburse_submit_pub_pkg.docspayTab.allow_removing_document_flag(l_trx_line_index)
                                            := NVL(iby_disburse_submit_pub_pkg.docspayTab.allow_removing_document_flag(l_trx_line_index),'Y');

         /*
          * By default this flag will be set to 'Y'.
          * It can be changed by the UI.
          */
         iby_disburse_submit_pub_pkg.docspayTab.straight_through_flag(l_trx_line_index) := 'Y';

         /*
          * For each document, store the payment funtion
          * and org if unique.
          */
         deriveDistinctAccessTypsForReq(
             p_payreq_id,
             iby_disburse_submit_pub_pkg.docspayTab.payment_function(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.org_id(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.org_type(l_trx_line_index),
             l_pmtFxAccessTypesTab,
             l_orgAccessTypesTab
             );

         /*
          * Following columns are not selected in the above cursor
          * They need to be initialized, otherwise, "No Data Found" is encountered.
          */
         iby_disburse_submit_pub_pkg.docspayTab.payment_id(l_trx_line_index) := NULL;
         iby_disburse_submit_pub_pkg.docspayTab.formatting_payment_id(l_trx_line_index) := NULL;
         iby_disburse_submit_pub_pkg.docspayTab.completed_pmts_group_id(l_trx_line_index) := NULL;
         iby_disburse_submit_pub_pkg.docspayTab.rejected_docs_group_id(l_trx_line_index) := NULL;

        END LOOP; -- for limited set of documents fetched

     /*
      * Insert document info in IBY_DOCS_PAYABLE_ALL
      */
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Before insert '  );

         END IF;
     FOR l_trx_line_index IN nvl(iby_disburse_submit_pub_pkg.docspayTab.pay_proc_trxn_type_code.FIRST,0) .. nvl(iby_disburse_submit_pub_pkg.docspayTab.pay_proc_trxn_type_code.LAST,-99)
     LOOP
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	            print_debuginfo(l_module_name, '1: ' || iby_disburse_submit_pub_pkg.docspayTab.pay_proc_trxn_type_code(l_trx_line_index));
	            print_debuginfo(l_module_name, '2: ' || iby_disburse_submit_pub_pkg.docspayTab.calling_app_id(l_trx_line_index));
	            print_debuginfo(l_module_name, '3: ' || iby_disburse_submit_pub_pkg.docspayTab.calling_app_doc_ref_number(l_trx_line_index));
	            print_debuginfo(l_module_name, '4: ' || iby_disburse_submit_pub_pkg.docspayTab.document_payable_id(l_trx_line_index));
	            print_debuginfo(l_module_name, '5: ' || iby_disburse_submit_pub_pkg.docspayTab.payment_function(l_trx_line_index));
	            print_debuginfo(l_module_name, '6: ' || iby_disburse_submit_pub_pkg.docspayTab.payment_date(l_trx_line_index));
	            print_debuginfo(l_module_name, '7: ' || iby_disburse_submit_pub_pkg.docspayTab.document_date(l_trx_line_index));
	            print_debuginfo(l_module_name, '8: ' || iby_disburse_submit_pub_pkg.docspayTab.document_type(l_trx_line_index));
	            print_debuginfo(l_module_name, '9: ' || iby_disburse_submit_pub_pkg.docspayTab.document_status(l_trx_line_index));
	            print_debuginfo(l_module_name, '10: ' || iby_disburse_submit_pub_pkg.docspayTab.document_currency_code(l_trx_line_index));
	            print_debuginfo(l_module_name, '11: ' || iby_disburse_submit_pub_pkg.docspayTab.document_amount(l_trx_line_index));
	            print_debuginfo(l_module_name, '12: ' || iby_disburse_submit_pub_pkg.docspayTab.payment_currency_code(l_trx_line_index));
	            print_debuginfo(l_module_name, '13: ' || iby_disburse_submit_pub_pkg.docspayTab.payment_amount(l_trx_line_index));
	            print_debuginfo(l_module_name, '14: ' || iby_disburse_submit_pub_pkg.docspayTab.payment_service_request_id(l_trx_line_index));
	            print_debuginfo(l_module_name, '15: ' || iby_disburse_submit_pub_pkg.docspayTab.payment_method_code(l_trx_line_index));
	            print_debuginfo(l_module_name, '16: ' || iby_disburse_submit_pub_pkg.docspayTab.exclusive_payment_flag(l_trx_line_index));
	            print_debuginfo(l_module_name, '17: ' || iby_disburse_submit_pub_pkg.docspayTab.straight_through_flag(l_trx_line_index));
	            print_debuginfo(l_module_name, '18: ' || iby_disburse_submit_pub_pkg.docspayTab.ext_payee_id(l_trx_line_index));
	            print_debuginfo(l_module_name, '19: ' || iby_disburse_submit_pub_pkg.docspayTab.payee_party_id(l_trx_line_index));
	            print_debuginfo(l_module_name, '20: ' || iby_disburse_submit_pub_pkg.docspayTab.legal_entity_id(l_trx_line_index));
	            print_debuginfo(l_module_name, '21: ' || iby_disburse_submit_pub_pkg.docspayTab.org_id(l_trx_line_index));
	            print_debuginfo(l_module_name, '22: ' || iby_disburse_submit_pub_pkg.docspayTab.allow_removing_document_flag(l_trx_line_index));
	            print_debuginfo(l_module_name, '23: ' || iby_disburse_submit_pub_pkg.docspayTab.created_by(l_trx_line_index));
	            print_debuginfo(l_module_name, '24: ' || iby_disburse_submit_pub_pkg.docspayTab.creation_date(l_trx_line_index));
	            print_debuginfo(l_module_name, '25: ' || iby_disburse_submit_pub_pkg.docspayTab.last_updated_by(l_trx_line_index));
	            print_debuginfo(l_module_name, '26: ' || iby_disburse_submit_pub_pkg.docspayTab.last_update_date(l_trx_line_index));
	            print_debuginfo(l_module_name, '27: ' || iby_disburse_submit_pub_pkg.docspayTab.object_version_number(l_trx_line_index));
	            print_debuginfo(l_module_name, '28: ' || iby_disburse_submit_pub_pkg.docspayTab.calling_app_doc_unique_ref1(l_trx_line_index));
	            print_debuginfo(l_module_name, '29: ' || iby_disburse_submit_pub_pkg.docspayTab.calling_app_doc_unique_ref2(l_trx_line_index));
	            print_debuginfo(l_module_name, '30: ' || iby_disburse_submit_pub_pkg.docspayTab.calling_app_doc_unique_ref3(l_trx_line_index));
	            print_debuginfo(l_module_name, '31: ' || iby_disburse_submit_pub_pkg.docspayTab.calling_app_doc_unique_ref4(l_trx_line_index));
	            print_debuginfo(l_module_name, '32: ' || iby_disburse_submit_pub_pkg.docspayTab.calling_app_doc_unique_ref5(l_trx_line_index));
	            print_debuginfo(l_module_name, '33: ' || iby_disburse_submit_pub_pkg.docspayTab.last_update_login(l_trx_line_index));
	            print_debuginfo(l_module_name, '34: ' || iby_disburse_submit_pub_pkg.docspayTab.party_site_id(l_trx_line_index));
	            print_debuginfo(l_module_name, '35: ' || iby_disburse_submit_pub_pkg.docspayTab.supplier_site_id(l_trx_line_index));
	            print_debuginfo(l_module_name, '36: ' || iby_disburse_submit_pub_pkg.docspayTab.beneficiary_party(l_trx_line_index));
	            print_debuginfo(l_module_name, '37: ' || iby_disburse_submit_pub_pkg.docspayTab.org_type(l_trx_line_index));
	            print_debuginfo(l_module_name, '38: ' || iby_disburse_submit_pub_pkg.docspayTab.anticipated_value_date(l_trx_line_index));
	            print_debuginfo(l_module_name, '39: ' || iby_disburse_submit_pub_pkg.docspayTab.po_number(l_trx_line_index));
	            print_debuginfo(l_module_name, '40: ' || iby_disburse_submit_pub_pkg.docspayTab.document_description(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.document_currency_tax_amount(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.document_curr_charge_amount(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.amount_withheld(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.payment_curr_discount_taken(l_trx_line_index));
	            print_debuginfo(l_module_name, '45: ' || iby_disburse_submit_pub_pkg.docspayTab.discount_date(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.payment_due_date(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.payment_profile_id(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.payment_id(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.formatting_payment_id(l_trx_line_index));
	            print_debuginfo(l_module_name, '50: ' || iby_disburse_submit_pub_pkg.docspayTab.internal_bank_account_id(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.external_bank_account_id(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.bank_charge_bearer(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.interest_rate(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.payment_grouping_number(l_trx_line_index));
	            print_debuginfo(l_module_name, '55: ' || iby_disburse_submit_pub_pkg.docspayTab.payment_reason_code(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.payment_reason_comments(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.settlement_priority(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.remittance_message1(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.remittance_message2(l_trx_line_index));
	            print_debuginfo(l_module_name, '60: ' || iby_disburse_submit_pub_pkg.docspayTab.remittance_message3(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.unique_remittance_identifier(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.uri_check_digit(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.delivery_channel_code(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.payment_format_code(l_trx_line_index));
	            print_debuginfo(l_module_name, '65: ' || iby_disburse_submit_pub_pkg.docspayTab.document_sequence_id(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.document_sequence_value(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.document_category_code(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.bank_assigned_ref_code(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.remit_to_location_id(l_trx_line_index));
	            print_debuginfo(l_module_name, '70: ' || iby_disburse_submit_pub_pkg.docspayTab.completed_pmts_group_id(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.rejected_docs_group_id(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.attribute_category(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.attribute1(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.attribute2(l_trx_line_index));
	            print_debuginfo(l_module_name, '75: ' || iby_disburse_submit_pub_pkg.docspayTab.attribute3(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.attribute4(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.attribute5(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.attribute6(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.attribute7(l_trx_line_index));
	            print_debuginfo(l_module_name, '80: ' || iby_disburse_submit_pub_pkg.docspayTab.attribute8(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.attribute9(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.attribute10(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.attribute11(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.attribute12(l_trx_line_index));
	            print_debuginfo(l_module_name, '85: ' || iby_disburse_submit_pub_pkg.docspayTab.attribute13(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.attribute14(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.attribute15(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.address_source(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.employee_address_code(l_trx_line_index));
	            print_debuginfo(l_module_name, '90: ' || iby_disburse_submit_pub_pkg.docspayTab.employee_payment_flag(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.employee_person_id(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' || iby_disburse_submit_pub_pkg.docspayTab.employee_address_id(l_trx_line_index));
	            print_debuginfo(l_module_name, '95: ' ||         iby_disburse_submit_pub_pkg.docspayTab.inv_payee_party_id(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' ||         iby_disburse_submit_pub_pkg.docspayTab.inv_party_site_id(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' ||         iby_disburse_submit_pub_pkg.docspayTab.inv_supplier_site_id(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' ||         iby_disburse_submit_pub_pkg.docspayTab.inv_beneficiary_party(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' ||         iby_disburse_submit_pub_pkg.docspayTab.ext_inv_payee_id(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' ||         iby_disburse_submit_pub_pkg.docspayTab.relationship_id(l_trx_line_index));
	            print_debuginfo(l_module_name, '101: ' ||      iby_disburse_submit_pub_pkg.docspayTab.global_attribute_category(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' ||         iby_disburse_submit_pub_pkg.docspayTab.global_attribute1(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' ||         iby_disburse_submit_pub_pkg.docspayTab.global_attribute2(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' ||         iby_disburse_submit_pub_pkg.docspayTab.global_attribute3(l_trx_line_index));
	            print_debuginfo(l_module_name, '105' ||       iby_disburse_submit_pub_pkg.docspayTab.global_attribute4(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' ||         iby_disburse_submit_pub_pkg.docspayTab.global_attribute5(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' ||         iby_disburse_submit_pub_pkg.docspayTab.global_attribute6(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' ||         iby_disburse_submit_pub_pkg.docspayTab.global_attribute7(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' ||         iby_disburse_submit_pub_pkg.docspayTab.global_attribute8(l_trx_line_index));
	            print_debuginfo(l_module_name, '110' ||       iby_disburse_submit_pub_pkg.docspayTab.global_attribute9(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' ||         iby_disburse_submit_pub_pkg.docspayTab.global_attribute10(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' ||         iby_disburse_submit_pub_pkg.docspayTab.global_attribute11(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' ||         iby_disburse_submit_pub_pkg.docspayTab.global_attribute12(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' ||         iby_disburse_submit_pub_pkg.docspayTab.global_attribute13(l_trx_line_index));
	            print_debuginfo(l_module_name, '115' ||       iby_disburse_submit_pub_pkg.docspayTab.global_attribute14(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' ||         iby_disburse_submit_pub_pkg.docspayTab.global_attribute15(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' ||         iby_disburse_submit_pub_pkg.docspayTab.global_attribute16(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' ||         iby_disburse_submit_pub_pkg.docspayTab.global_attribute17(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' ||         iby_disburse_submit_pub_pkg.docspayTab.global_attribute18(l_trx_line_index));
	            print_debuginfo(l_module_name, '120' ||       iby_disburse_submit_pub_pkg.docspayTab.global_attribute19(l_trx_line_index));
	            print_debuginfo(l_module_name, '1' ||         iby_disburse_submit_pub_pkg.docspayTab.global_attribute20(l_trx_line_index));
            END IF;
     END LOOP;
     END IF;

     FORALL l_trx_line_index IN nvl(iby_disburse_submit_pub_pkg.docspayTab.pay_proc_trxn_type_code.FIRST,0) .. nvl(iby_disburse_submit_pub_pkg.docspayTab.pay_proc_trxn_type_code.LAST,-99)
         INSERT INTO IBY_DOCS_PAYABLE_ALL
             (
             pay_proc_trxn_type_code,
             calling_app_id,
             calling_app_doc_ref_number,
             document_payable_id,
             payment_function,
             payment_date,
             document_date,
             document_type,
             document_status,
             document_currency_code,
             document_amount,
             payment_currency_code,
             payment_amount,
             payment_service_request_id,
             payment_method_code,
             exclusive_payment_flag,
             straight_through_flag,
             ext_payee_id,
             payee_party_id,
             legal_entity_id,
             org_id,
             allow_removing_document_flag,
             created_by,
             creation_date,
             last_updated_by,
             last_update_date,
             object_version_number,
             calling_app_doc_unique_ref1,
             calling_app_doc_unique_ref2,
             calling_app_doc_unique_ref3,
             calling_app_doc_unique_ref4,
             calling_app_doc_unique_ref5,
             last_update_login,
             party_site_id,
             supplier_site_id,
             beneficiary_party,
             org_type,
             anticipated_value_date,
             po_number,
             document_description,
             document_currency_tax_amount,
             document_curr_charge_amount,
             amount_withheld,
             payment_curr_discount_taken,
             discount_date,
             payment_due_date,
             payment_profile_id,
             payment_id,
             formatting_payment_id,
             internal_bank_account_id,
             external_bank_account_id,
             bank_charge_bearer,
             interest_rate,
             payment_grouping_number,
             payment_reason_code,
             payment_reason_comments,
             settlement_priority,
             remittance_message1,
             remittance_message2,
             remittance_message3,
             unique_remittance_identifier,
             uri_check_digit,
             delivery_channel_code,
             payment_format_code,
             document_sequence_id,
             document_sequence_value,
             document_category_code,
             bank_assigned_ref_code,
             remit_to_location_id,
             completed_pmts_group_id,
             rejected_docs_group_id,
             attribute_category,
             attribute1,
             attribute2,
             attribute3,
             attribute4,
             attribute5,
             attribute6,
             attribute7,
             attribute8,
             attribute9,
             attribute10,
             attribute11,
             attribute12,
             attribute13,
             attribute14,
             attribute15,
             address_source,
             employee_address_code,
             employee_payment_flag,
             employee_person_id,
             employee_address_id,
	     inv_payee_party_id,
	     inv_party_site_id,
	     inv_supplier_site_id,
	     inv_beneficiary_party,
	     ext_inv_payee_id,
	     relationship_id,
             global_attribute_category,
             global_attribute1,
             global_attribute2,
             global_attribute3,
             global_attribute4,
             global_attribute5,
             global_attribute6,
             global_attribute7,
             global_attribute8,
             global_attribute9,
             global_attribute10,
             global_attribute11,
             global_attribute12,
             global_attribute13,
             global_attribute14,
             global_attribute15,
             global_attribute16,
             global_attribute17,
             global_attribute18,
             global_attribute19,
             global_attribute20
             )
         VALUES
             (
             iby_disburse_submit_pub_pkg.docspayTab.pay_proc_trxn_type_code(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.calling_app_id(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.calling_app_doc_ref_number(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.document_payable_id(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.payment_function(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.payment_date(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.document_date(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.document_type(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.document_status(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.document_currency_code(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.document_amount(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.payment_currency_code(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.payment_amount(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.payment_service_request_id(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.payment_method_code(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.exclusive_payment_flag(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.straight_through_flag(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.ext_payee_id(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.payee_party_id(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.legal_entity_id(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.org_id(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.allow_removing_document_flag(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.created_by(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.creation_date(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.last_updated_by(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.last_update_date(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.object_version_number(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.calling_app_doc_unique_ref1(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.calling_app_doc_unique_ref2(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.calling_app_doc_unique_ref3(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.calling_app_doc_unique_ref4(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.calling_app_doc_unique_ref5(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.last_update_login(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.party_site_id(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.supplier_site_id(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.beneficiary_party(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.org_type(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.anticipated_value_date(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.po_number(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.document_description(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.document_currency_tax_amount(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.document_curr_charge_amount(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.amount_withheld(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.payment_curr_discount_taken(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.discount_date(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.payment_due_date(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.payment_profile_id(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.payment_id(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.formatting_payment_id(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.internal_bank_account_id(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.external_bank_account_id(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.bank_charge_bearer(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.interest_rate(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.payment_grouping_number(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.payment_reason_code(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.payment_reason_comments(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.settlement_priority(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.remittance_message1(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.remittance_message2(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.remittance_message3(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.unique_remittance_identifier(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.uri_check_digit(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.delivery_channel_code(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.payment_format_code(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.document_sequence_id(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.document_sequence_value(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.document_category_code(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.bank_assigned_ref_code(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.remit_to_location_id(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.completed_pmts_group_id(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.rejected_docs_group_id(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.attribute_category(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.attribute1(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.attribute2(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.attribute3(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.attribute4(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.attribute5(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.attribute6(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.attribute7(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.attribute8(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.attribute9(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.attribute10(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.attribute11(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.attribute12(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.attribute13(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.attribute14(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.attribute15(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.address_source(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.employee_address_code(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.employee_payment_flag(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.employee_person_id(l_trx_line_index),
             iby_disburse_submit_pub_pkg.docspayTab.employee_address_id(l_trx_line_index),

	     iby_disburse_submit_pub_pkg.docspayTab.inv_payee_party_id(l_trx_line_index)                ,
	     iby_disburse_submit_pub_pkg.docspayTab.inv_party_site_id(l_trx_line_index)                 ,
	     iby_disburse_submit_pub_pkg.docspayTab.inv_supplier_site_id(l_trx_line_index)              ,
	     iby_disburse_submit_pub_pkg.docspayTab.inv_beneficiary_party(l_trx_line_index)                   ,
	     iby_disburse_submit_pub_pkg.docspayTab.ext_inv_payee_id(l_trx_line_index)                  ,
	     iby_disburse_submit_pub_pkg.docspayTab.relationship_id(l_trx_line_index),

             iby_disburse_submit_pub_pkg.docspayTab.global_attribute_category(l_trx_line_index),
	     iby_disburse_submit_pub_pkg.docspayTab.global_attribute1(l_trx_line_index),
	     iby_disburse_submit_pub_pkg.docspayTab.global_attribute2(l_trx_line_index),
	     iby_disburse_submit_pub_pkg.docspayTab.global_attribute3(l_trx_line_index),
	     iby_disburse_submit_pub_pkg.docspayTab.global_attribute4(l_trx_line_index),
	     iby_disburse_submit_pub_pkg.docspayTab.global_attribute5(l_trx_line_index),
	     iby_disburse_submit_pub_pkg.docspayTab.global_attribute6(l_trx_line_index),
	     iby_disburse_submit_pub_pkg.docspayTab.global_attribute7(l_trx_line_index),
	     iby_disburse_submit_pub_pkg.docspayTab.global_attribute8(l_trx_line_index),
	     iby_disburse_submit_pub_pkg.docspayTab.global_attribute9(l_trx_line_index),
	     iby_disburse_submit_pub_pkg.docspayTab.global_attribute10(l_trx_line_index),
	     iby_disburse_submit_pub_pkg.docspayTab.global_attribute11(l_trx_line_index),
	     iby_disburse_submit_pub_pkg.docspayTab.global_attribute12(l_trx_line_index),
	     iby_disburse_submit_pub_pkg.docspayTab.global_attribute13(l_trx_line_index),
	     iby_disburse_submit_pub_pkg.docspayTab.global_attribute14(l_trx_line_index),
	     iby_disburse_submit_pub_pkg.docspayTab.global_attribute15(l_trx_line_index),
	     iby_disburse_submit_pub_pkg.docspayTab.global_attribute16(l_trx_line_index),
	     iby_disburse_submit_pub_pkg.docspayTab.global_attribute17(l_trx_line_index),
	     iby_disburse_submit_pub_pkg.docspayTab.global_attribute18(l_trx_line_index),
	     iby_disburse_submit_pub_pkg.docspayTab.global_attribute19(l_trx_line_index),
	     iby_disburse_submit_pub_pkg.docspayTab.global_attribute20(l_trx_line_index)
             );

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Finished inserting'
	         || ' documents into IBY_DOCS_PAYABLE_ALL'
	         || ' table');

     END IF;
        EXIT WHEN l_docs_cursor%NOTFOUND;

     END LOOP; -- for documents cursor

     /*
      * If no documents were provided with the payment request,
      * there is no point in going further.
      *
      * A pament request with no documents payable is an invalid
      * request. Return error response.
      */
     IF (l_no_rec_in_ppr) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Payment request '
	             || 'did not contain any documents. Returning error ..'
	             );

	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         l_return_status := -1;
         CLOSE l_docs_cursor;
         RETURN l_return_status;

     END IF;

     delete_docspayTab;

     CLOSE l_docs_cursor;

     /*
      * Insert the distinct payment functions and orgs that
      * were found in the documents of this request. These
      * will be used for limiting UI access to users.
      */
     insertDistinctAccessTypsForReq(l_pmtFxAccessTypesTab,
         l_orgAccessTypesTab);

     /*
      * If the documents were inserted successfully, update the
      * status of the payment request to 'submitted'.
      */
     UPDATE
         IBY_PAY_SERVICE_REQUESTS
     SET
         payment_service_request_status = REQ_STATUS_SUBMITTED
     WHERE
         payment_service_request_id = p_payreq_id;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Updated status of'
	         || ' payment request '
	         || p_payreq_id
	         || ' to "submitted"'
	         );

     END IF;
     /*
      * If we reached here, it means that the document
      * insertion was successful. Set the return status
      * to success.
      */
     l_return_status := 0;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');
     END IF;
     RETURN l_return_status;

 EXCEPTION
     WHEN OTHERS THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Exception occured when '
	             || 'attempting to insert documents for '
	             || 'calling app id '
	             || p_calling_app_id
	             || ', calling app payment service request id '
	             || p_calling_app_payreq_cd
	             );
	         print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	         print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);

	         print_debuginfo(l_module_name, 'EXIT');
         END IF;
         l_return_status := -1;
         RETURN l_return_status;

 END insert_payreq_documents;

/*--------------------------------------------------------------------
 | NAME:
 |     getNextDocumentPayableID
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
 FUNCTION getNextDocumentPayableID
     RETURN NUMBER
 IS

 l_docPayID IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE;

 BEGIN

     SELECT IBY_DOCS_PAYABLE_ALL_S.nextval INTO l_docPayID
         FROM DUAL;

     RETURN l_docPayID;

 END getNextDocumentPayableID;

/*--------------------------------------------------------------------
 | NAME:
 |     getNextDocumentPayableLineID
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
 FUNCTION getNextDocumentPayableLineID
     RETURN NUMBER
 IS

 l_docLineID IBY_DOCUMENT_LINES.document_payable_line_id%TYPE;

 BEGIN

     SELECT IBY_DOCUMENT_LINES_S.nextval INTO l_docLineID
         FROM DUAL;

     RETURN l_docLineID;

 END getNextDocumentPayableLineID;

/*--------------------------------------------------------------------
 | NAME:
 |     deriveDistinctAccessTypsForReq
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
 PROCEDURE deriveDistinctAccessTypsForReq(
     p_payreq_id           IN IBY_DOCS_PAYABLE_ALL.payment_service_request_id
                                  %TYPE,
     p_pmt_function        IN IBY_DOCS_PAYABLE_ALL.payment_function%TYPE,
     p_org_id              IN IBY_DOCS_PAYABLE_ALL.org_id%TYPE,
     p_org_type            IN IBY_DOCS_PAYABLE_ALL.org_type%TYPE,
     x_pmtFxAccessTypesTab IN OUT NOCOPY distinctPmtFxAccessTab,
     x_orgAccessTypesTab   IN OUT NOCOPY distinctOrgAccessTab
     )
 IS

 l_pmt_function_found BOOLEAN := FALSE;
 l_org_found          BOOLEAN := FALSE;
 l_index              NUMBER := -1;

 l_module_name        CONSTANT VARCHAR2(200) := G_PKG_NAME ||
                                            '.deriveDistinctAccessTypsForReq';

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     IF (x_pmtFxAccessTypesTab.COUNT <> 0) THEN

         FOR i IN x_pmtFxAccessTypesTab.FIRST .. x_pmtFxAccessTypesTab.LAST LOOP

             /* search for given payment function */
             IF (x_pmtFxAccessTypesTab(i).payment_function = p_pmt_function)
             THEN
                 l_pmt_function_found := TRUE;
             END IF;

         END LOOP;

     END IF;

     IF (x_orgAccessTypesTab.COUNT <> 0) THEN

         FOR i IN x_orgAccessTypesTab.FIRST .. x_orgAccessTypesTab.LAST LOOP

             /* search for given org */
             IF (x_orgAccessTypesTab(i).org_id   = p_org_id AND
                 x_orgAccessTypesTab(i).org_type = p_org_type) THEN
                 l_org_found := TRUE;
             END IF;

         END LOOP;

     END IF;


     /* if payment function was not found, add to list */
     IF (l_pmt_function_found = FALSE) THEN

         l_index := x_pmtFxAccessTypesTab.COUNT;

         x_pmtFxAccessTypesTab(l_index + 1).
             payment_function := p_pmt_function;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Found distinct pmt function: '
	             || p_pmt_function
	             );

         END IF;
         /*
          * These attributes can be hardcoded.
          */
         x_pmtFxAccessTypesTab(l_index + 1).object_id   := p_payreq_id;
         x_pmtFxAccessTypesTab(l_index + 1).object_type := 'PAYMENT_REQUEST';

     END IF;

     /* if org was not found, add to list */
     IF (l_org_found = FALSE) THEN

         l_index := x_orgAccessTypesTab.COUNT;

         x_orgAccessTypesTab(l_index + 1).org_id   := p_org_id;
         x_orgAccessTypesTab(l_index + 1).org_type := p_org_type;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Found distinct org id: '
	             || p_org_id
	             || ' with org type '
	             || p_org_type
	             );

         END IF;
         /*
          * These attributes can be hardcoded.
          */
         x_orgAccessTypesTab(l_index + 1).object_id   := p_payreq_id;
         x_orgAccessTypesTab(l_index + 1).object_type := 'PAYMENT_REQUEST';

     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END deriveDistinctAccessTypsForReq;

/*--------------------------------------------------------------------
 | NAME:
 |     insertDistinctAccessTypsForReq
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
 PROCEDURE insertDistinctAccessTypsForReq(
     p_pmtFxAccessTypesTab IN distinctPmtFxAccessTab,
     p_orgAccessTypesTab   IN distinctOrgAccessTab
     )
 IS

 TYPE t_object_id IS TABLE OF
     NUMBER(15)
     INDEX BY BINARY_INTEGER;
 TYPE t_object_type IS TABLE OF
     VARCHAR2(30)
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_function IS TABLE OF
     VARCHAR2(30)
     INDEX BY BINARY_INTEGER;
 TYPE t_org_type IS TABLE OF
     VARCHAR2(30)
     INDEX BY BINARY_INTEGER;
 TYPE t_org_id IS TABLE OF
     NUMBER(15)
     INDEX BY BINARY_INTEGER;

 l_object_id                  t_object_id;
 l_object_type                t_object_type;
 l_payment_function           t_payment_function;
 l_org_type                   t_org_type;
 l_org_id                     t_org_id;

 BEGIN

     IF (p_pmtFxAccessTypesTab.COUNT <> 0) THEN

         FOR i IN p_pmtFxAccessTypesTab.FIRST .. p_pmtFxAccessTypesTab.LAST
             LOOP

             l_object_id(i)        := p_pmtFxAccessTypesTab(i).object_id;
             l_object_type(i)      := p_pmtFxAccessTypesTab(i).object_type;
             l_payment_function(i) := p_pmtFxAccessTypesTab(i).payment_function;

         END LOOP;

     END IF;

     IF (p_orgAccessTypesTab.COUNT <> 0) THEN

         FOR i IN p_orgAccessTypesTab.FIRST .. p_orgAccessTypesTab.LAST
             LOOP

             l_object_id(i)        := p_orgAccessTypesTab(i).object_id;
             l_object_type(i)      := p_orgAccessTypesTab(i).object_type;
             l_org_type(i)         := p_orgAccessTypesTab(i).org_type;
             l_org_id(i)           := p_orgAccessTypesTab(i).org_id;

         END LOOP;

     END IF;

     --FORALL i in p_pmtFxAccessTypesTab.FIRST..p_pmtFxAccessTypesTab.LAST
     --    INSERT INTO IBY_PROCESS_FUNCTIONS VALUES p_pmtFxAccessTypesTab(i);

     FORALL i in nvl(p_pmtFxAccessTypesTab.FIRST,0) .. nvl(p_pmtFxAccessTypesTab.LAST,-99)
         INSERT INTO IBY_PROCESS_FUNCTIONS
             (
             object_id,
             object_type,
             payment_function
             )
         VALUES
             (
             l_object_id(i),
             l_object_type(i),
             l_payment_function(i)
             )
             ;

     --FORALL j in p_orgAccessTypesTab.FIRST..p_orgAccessTypesTab.LAST
     --    INSERT INTO IBY_PROCESS_ORGS VALUES p_orgAccessTypesTab(j);

     FORALL j in nvl(p_orgAccessTypesTab.FIRST,0) .. nvl(p_orgAccessTypesTab.LAST,-99)
         INSERT INTO IBY_PROCESS_ORGS
             (
             object_id,
             object_type,
             org_id,
             org_type
             )
         VALUES
             (
             l_object_id(j),
             l_object_type(j),
             l_org_id(j),
             l_org_type(j)
             )
             ;

 END insertDistinctAccessTypsForReq;

/*--------------------------------------------------------------------
 | NAME:
 |     get_profile_process_attribs
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
 PROCEDURE get_profile_process_attribs(
     p_profile_id         IN IBY_PAYMENT_PROFILES.payment_profile_id%TYPE,
     x_profile_attribs    IN OUT NOCOPY  profileProcessAttribs
     )
 IS

 l_module_name   VARCHAR2(200) := G_PKG_NAME || '.get_profile_process_attribs';

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
/*  Bug 5709596 */
     IF paymentProfilesTab.exists(p_profile_id) THEN
        x_profile_attribs.processing_type   := paymentProfilesTab(p_profile_id).processing_type;
        x_profile_attribs.payment_doc_id    := paymentProfilesTab(p_profile_id).default_payment_document_id;
        x_profile_attribs.printer_name      := paymentProfilesTab(p_profile_id).default_printer;
        x_profile_attribs.print_now_flag    := paymentProfilesTab(p_profile_id).print_instruction_immed_flag;
        x_profile_attribs.transmit_now_flag := paymentProfilesTab(p_profile_id).transmit_instr_immed_flag;
     ELSE
        set_profile_attribs(p_profile_id);
        x_profile_attribs.processing_type   := paymentProfilesTab(p_profile_id).processing_type;
        x_profile_attribs.payment_doc_id    := paymentProfilesTab(p_profile_id).default_payment_document_id;
        x_profile_attribs.printer_name      := paymentProfilesTab(p_profile_id).default_printer;
        x_profile_attribs.print_now_flag    := paymentProfilesTab(p_profile_id).print_instruction_immed_flag;
        x_profile_attribs.transmit_now_flag := paymentProfilesTab(p_profile_id).transmit_instr_immed_flag;
     END IF;

     BEGIN
        SELECT
            cedoc.payment_document_id
        INTO
            x_profile_attribs.payment_doc_id
        FROM
            CE_PAYMENT_DOCUMENTS   cedoc
        WHERE
            cedoc.payment_document_id = x_profile_attribs.payment_doc_id;
     EXCEPTION
        WHEN OTHERS THEN
           x_profile_attribs.payment_doc_id := null;
     END;
/*  Bug 5709596 */

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 EXCEPTION
     WHEN OTHERS THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Exception occured '
	             || 'when attempting to get processing attributes '
	             || 'for profile '
	             || p_profile_id
	             || '. Payment process likely to fail .. '
	             );

	         print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	         print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);

	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
 END get_profile_process_attribs;

/*--------------------------------------------------------------------
 | NAME:
 |     checkIfDefaultPmtDocOnProfile
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
 PROCEDURE checkIfDefaultPmtDocOnProfile (
     p_profile_id   IN     IBY_PAYMENT_PROFILES.payment_profile_id%TYPE,
     x_profile_name IN OUT NOCOPY IBY_PAYMENT_PROFILES.system_profile_name%TYPE,
     x_return_flag  IN OUT NOCOPY BOOLEAN
     )

 IS

 l_default_pmt_doc_id IBY_PAYMENT_PROFILES.payment_profile_id%TYPE;
 l_module_name        VARCHAR2(200) := G_PKG_NAME
                                           || '.checkIfDefaultPmtDocOnProfile';

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     BEGIN

/*  Bug 5709596 */
        IF paymentProfilesTab.exists(p_profile_id) THEN
           l_default_pmt_doc_id := paymentProfilesTab(p_profile_id).default_payment_document_id;
           x_profile_name       := paymentProfilesTab(p_profile_id).system_profile_name;
        ELSE
           set_profile_attribs(p_profile_id);
           l_default_pmt_doc_id := paymentProfilesTab(p_profile_id).default_payment_document_id;
           x_profile_name       := paymentProfilesTab(p_profile_id).system_profile_name;
        END IF;
/*  Bug 5709596 */

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo(l_module_name, 'Profile id '
	             || p_profile_id
	             || ' with name '
	             || ''''
	             || x_profile_name
	             || ''''
	             || ' has default payment doc id: '
	             || l_default_pmt_doc_id
	             );

        END IF;
         IF (l_default_pmt_doc_id IS NOT NULL) THEN
             /*
              * If we reached here, it means that a default payment
              * document is associated with the provided payment
              * profile.
              *
              * So, return TRUE.
              */
             x_return_flag := TRUE;
         ELSE
             x_return_flag := FALSE;
         END IF;

     EXCEPTION
         WHEN OTHERS THEN

         /*
          * If any exceptions occur, return FALSE.
          */
         x_return_flag := FALSE;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Non-fatal: Exception occured '
	             || 'when attempting to get default payment doc id '
	             || 'for profile '
	             || p_profile_id
	             );

	         print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	         print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);

         END IF;
     END;

     IF (x_return_flag = TRUE) THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning TRUE');
         END IF;
     ELSE
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning FALSE');
         END IF;
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END checkIfDefaultPmtDocOnProfile;

/*--------------------------------------------------------------------
 | NAME:
 |     launchPPRStatusReport
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
 PROCEDURE launchPPRStatusReport(
     p_payreq_id      IN      IBY_PAY_SERVICE_REQUESTS.
                                  payment_service_request_id%TYPE
     )
 IS
 l_module_name     CONSTANT VARCHAR2(200) := G_PKG_NAME ||
                                                 '.launchPPRStatusReport';

 l_report_format   IBY_INTERNAL_PAYERS_ALL.ppr_report_format%TYPE;
 l_report_flag     IBY_INTERNAL_PAYERS_ALL.automatic_ppr_report_submit%TYPE;

 l_app_short_name  VARCHAR2(200);
 l_ca_payreq_cd    IBY_PAY_SERVICE_REQUESTS.call_app_pay_service_req_code%TYPE;
 l_ca_id           IBY_PAY_SERVICE_REQUESTS.calling_app_id%TYPE;
 l_conc_req_id     NUMBER(15);

 l_bool_val        BOOLEAN; -- Bug 6411356

 l_icx_numeric_characters   VARCHAR2(30); -- Bug 6411356


 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     /*
      * Fetch the system options at the enterprise level
      * (i.e., where org id is null).
      */
     SELECT
         automatic_ppr_report_submit,
         ppr_report_format
     INTO
         l_report_flag,
         l_report_format
     FROM
         IBY_INTERNAL_PAYERS_ALL sysoptions
     WHERE
         sysoptions.org_id IS NULL
     ;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Enterprise level settings - '
	         || 'Automatic ppr status report submit flag: '
	         || l_report_flag
	         || ', Report format: '
	         || l_report_format
	         );

     END IF;
     IF (l_report_flag <> 'Y' OR l_report_format IS NULL) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Not launching '
	             || 'automatic ppr status report; both report '
	             || 'flag and report format need to be set '
	             || 'at enterprise level to launch this report.'
	             );

	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     END IF;

     /*
      * If we reached here, it means that the user has specified
      * via enterprise level settings, the the payment process
      * status report needs to be launched for each PPR.
      */

     /*
      * Get the application name of the calling app. This
      * will be used in the callout.
      */
     SELECT
         fnd.application_short_name
     INTO
         l_app_short_name
     FROM
         FND_APPLICATION          fnd,
         IBY_PAY_SERVICE_REQUESTS req
     WHERE
         fnd.application_id             = req.calling_app_id AND
         req.payment_service_request_id = p_payreq_id
     ;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Calling app short name: '
	         || l_app_short_name
	         );

     END IF;
     /*
      * Get the calling application payreq code for the
      * given payment request id.
      */
     IBY_VALIDATIONSETS_PUB.getRequestAttributes(
         p_payreq_id, l_ca_payreq_cd, l_ca_id);

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Calling app request code: '
	         || l_ca_payreq_cd
	         );

     END IF;
     /*
      * Launch the report.
      */

     /*
      * Fix for bug 5407120:
      *
      * Before kicking off reports / formats make sure that
      * the numeric characters delimiter is correctly set
      * by using FND_REQUEST.SET_OPTIONS(..).
      *
      * The argument provided to this method is based on
      * the lookup ICX_NUMERIC_CHARACTERS.
      *
      * Otherwise, the num delimiter would be picked up
      * based on NLS territory and could cause problems.
      *
      * E.g., $10000.52 would be displayed as $10.000,52 for
      * PL territory and this causes problems to XML publisher.
      */
     --Bug 6411356
     --below code added to set the current nls character setting
     --before submitting a child requests.
     fnd_profile.get('ICX_NUMERIC_CHARACTERS',l_icx_numeric_characters);
     l_bool_val := FND_REQUEST.SET_OPTIONS( numeric_characters => l_icx_numeric_characters);

     l_conc_req_id := FND_REQUEST.SUBMIT_REQUEST(
                     'IBY',
                     'IBY_FD_PPR_STATUS_PRT',
                     '',
                     '',
                     FALSE,

                     l_app_short_name,
                     l_ca_payreq_cd,
                     l_report_format,
                     '',

                     '', '', '', '', '', '', '',
                     '', '', '', '', '', '', '', '', '', '',
                     '', '', '', '', '', '', '', '', '', '',
                     '', '', '', '', '', '', '', '', '', '',
                     '', '', '', '', '', '', '', '', '', '',
                     '', '', '', '', '', '', '', '', '', '',
                     '', '', '', '', '', '', '', '', '', '',
                     '', '', '', '', '', '', '', '', '', '',
                     '', '', '', '', '', '', '', '', '', '',
                     '', '', '', '', '', '', ''
                     );

     IF (l_conc_req_id = 0) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Concurrent program request failed.');

         END IF;
     ELSE

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'The concurrent request was '
	             || 'launched successfully. '
	             || 'Check concurrent request id: '
	             || to_char(l_conc_req_id)
	             );

         END IF;
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 EXCEPTION
     WHEN OTHERS THEN

         /*
          * Treat this exception as non-fatal.
          *
          * It's not the end of the world if we couldn't
          * launch a report.
          */
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Non-Fatal: Exception occured '
	             || 'when attempting to launch the automatic payment process '
	             || 'request status report.'
	             );

	         print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	         print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);

	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
 END launchPPRStatusReport;

/*--------------------------------------------------------------------
 | NAME:
 |     set_profile_attribs
 |
 |
 | PURPOSE:
 |     Sets the attributes of the payment profile structure
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
 PROCEDURE set_profile_attribs(
     p_profile_id         IN IBY_PAYMENT_PROFILES.payment_profile_id%TYPE
     ) IS
 l_module_name     CONSTANT VARCHAR2(200) := G_PKG_NAME ||
                                       '.set_profile_attribs';
 l_ppp_rec         IBY_PAYMENT_PROFILES%rowtype;
 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     BEGIN
        SELECT *
          INTO l_ppp_rec
          FROM IBY_PAYMENT_PROFILES
         WHERE payment_profile_id = p_profile_id;
     EXCEPTION
        WHEN OTHERS THEN
           l_ppp_rec := null;
     END;
     paymentProfilesTab(p_profile_id) := l_ppp_rec;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END set_profile_attribs;



/*--------------------------------------------------------------------
 | NAME:
 |
 | PURPOSE:
 |     This procedure is used to free up the memory used by
 |     global memory structure
 |
 | PARAMETERS:
 |
 |     NONE
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE delete_docspayTab IS
 l_module_name     CONSTANT VARCHAR2(200) := G_PKG_NAME ||
                                       '.delete_docspayTab';
  BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');
     END IF;
        iby_disburse_submit_pub_pkg.docspayTab.pay_proc_trxn_type_code.delete;
        iby_disburse_submit_pub_pkg.docspayTab.calling_app_id.delete;
        iby_disburse_submit_pub_pkg.docspayTab.calling_app_doc_ref_number.delete;
        iby_disburse_submit_pub_pkg.docspayTab.call_app_pay_service_req_code.delete;
        iby_disburse_submit_pub_pkg.docspayTab.document_payable_id.delete;
        iby_disburse_submit_pub_pkg.docspayTab.payment_function.delete;
        iby_disburse_submit_pub_pkg.docspayTab.payment_date.delete;
        iby_disburse_submit_pub_pkg.docspayTab.document_date.delete;
        iby_disburse_submit_pub_pkg.docspayTab.document_type.delete;
        iby_disburse_submit_pub_pkg.docspayTab.document_status.delete;
        iby_disburse_submit_pub_pkg.docspayTab.document_currency_code.delete;
        iby_disburse_submit_pub_pkg.docspayTab.document_amount.delete;
        iby_disburse_submit_pub_pkg.docspayTab.payment_currency_code.delete;
        iby_disburse_submit_pub_pkg.docspayTab.payment_amount.delete;
        iby_disburse_submit_pub_pkg.docspayTab.payment_service_request_id.delete;
        iby_disburse_submit_pub_pkg.docspayTab.payment_method_code.delete;
        iby_disburse_submit_pub_pkg.docspayTab.exclusive_payment_flag.delete;
        iby_disburse_submit_pub_pkg.docspayTab.straight_through_flag.delete;
        iby_disburse_submit_pub_pkg.docspayTab.ext_payee_id.delete;
        iby_disburse_submit_pub_pkg.docspayTab.payee_party_id.delete;
        iby_disburse_submit_pub_pkg.docspayTab.legal_entity_id.delete;
        iby_disburse_submit_pub_pkg.docspayTab.org_id.delete;
        iby_disburse_submit_pub_pkg.docspayTab.allow_removing_document_flag.delete;
        iby_disburse_submit_pub_pkg.docspayTab.created_by.delete;
        iby_disburse_submit_pub_pkg.docspayTab.creation_date.delete;
        iby_disburse_submit_pub_pkg.docspayTab.last_updated_by.delete;
        iby_disburse_submit_pub_pkg.docspayTab.last_update_date.delete;
        iby_disburse_submit_pub_pkg.docspayTab.object_version_number.delete;
        iby_disburse_submit_pub_pkg.docspayTab.calling_app_doc_unique_ref1.delete;
        iby_disburse_submit_pub_pkg.docspayTab.calling_app_doc_unique_ref2.delete;
        iby_disburse_submit_pub_pkg.docspayTab.calling_app_doc_unique_ref3.delete;
        iby_disburse_submit_pub_pkg.docspayTab.calling_app_doc_unique_ref4.delete;
        iby_disburse_submit_pub_pkg.docspayTab.calling_app_doc_unique_ref5.delete;
        iby_disburse_submit_pub_pkg.docspayTab.last_update_login.delete;
        iby_disburse_submit_pub_pkg.docspayTab.party_site_id.delete;
        iby_disburse_submit_pub_pkg.docspayTab.supplier_site_id.delete;
        iby_disburse_submit_pub_pkg.docspayTab.beneficiary_party.delete;
        iby_disburse_submit_pub_pkg.docspayTab.org_type.delete;
        iby_disburse_submit_pub_pkg.docspayTab.anticipated_value_date.delete;
        iby_disburse_submit_pub_pkg.docspayTab.po_number.delete;
        iby_disburse_submit_pub_pkg.docspayTab.document_description.delete;
        iby_disburse_submit_pub_pkg.docspayTab.document_currency_tax_amount.delete;
        iby_disburse_submit_pub_pkg.docspayTab.document_curr_charge_amount.delete;
        iby_disburse_submit_pub_pkg.docspayTab.amount_withheld.delete;
        iby_disburse_submit_pub_pkg.docspayTab.payment_curr_discount_taken.delete;
        iby_disburse_submit_pub_pkg.docspayTab.discount_date.delete;
        iby_disburse_submit_pub_pkg.docspayTab.payment_due_date.delete;
        iby_disburse_submit_pub_pkg.docspayTab.payment_profile_id.delete;
        iby_disburse_submit_pub_pkg.docspayTab.payment_id.delete;
        iby_disburse_submit_pub_pkg.docspayTab.formatting_payment_id.delete;
        iby_disburse_submit_pub_pkg.docspayTab.internal_bank_account_id.delete;
        iby_disburse_submit_pub_pkg.docspayTab.external_bank_account_id.delete;
        iby_disburse_submit_pub_pkg.docspayTab.bank_charge_bearer.delete;
        iby_disburse_submit_pub_pkg.docspayTab.interest_rate.delete;
        iby_disburse_submit_pub_pkg.docspayTab.payment_grouping_number.delete;
        iby_disburse_submit_pub_pkg.docspayTab.payment_reason_code.delete;
        iby_disburse_submit_pub_pkg.docspayTab.payment_reason_comments.delete;
        iby_disburse_submit_pub_pkg.docspayTab.settlement_priority.delete;
        iby_disburse_submit_pub_pkg.docspayTab.remittance_message1.delete;
        iby_disburse_submit_pub_pkg.docspayTab.remittance_message2.delete;
        iby_disburse_submit_pub_pkg.docspayTab.remittance_message3.delete;
        iby_disburse_submit_pub_pkg.docspayTab.unique_remittance_identifier.delete;
        iby_disburse_submit_pub_pkg.docspayTab.uri_check_digit.delete;
        iby_disburse_submit_pub_pkg.docspayTab.delivery_channel_code.delete;
        iby_disburse_submit_pub_pkg.docspayTab.payment_format_code.delete;
        iby_disburse_submit_pub_pkg.docspayTab.document_sequence_id.delete;
        iby_disburse_submit_pub_pkg.docspayTab.document_sequence_value.delete;
        iby_disburse_submit_pub_pkg.docspayTab.document_category_code.delete;
        iby_disburse_submit_pub_pkg.docspayTab.bank_assigned_ref_code.delete;
        iby_disburse_submit_pub_pkg.docspayTab.remit_to_location_id.delete;
        iby_disburse_submit_pub_pkg.docspayTab.completed_pmts_group_id.delete;
        iby_disburse_submit_pub_pkg.docspayTab.rejected_docs_group_id.delete;
        iby_disburse_submit_pub_pkg.docspayTab.attribute_category.delete;
        iby_disburse_submit_pub_pkg.docspayTab.attribute1.delete;
        iby_disburse_submit_pub_pkg.docspayTab.attribute2.delete;
        iby_disburse_submit_pub_pkg.docspayTab.attribute3.delete;
        iby_disburse_submit_pub_pkg.docspayTab.attribute4.delete;
        iby_disburse_submit_pub_pkg.docspayTab.attribute5.delete;
        iby_disburse_submit_pub_pkg.docspayTab.attribute6.delete;
        iby_disburse_submit_pub_pkg.docspayTab.attribute7.delete;
        iby_disburse_submit_pub_pkg.docspayTab.attribute8.delete;
        iby_disburse_submit_pub_pkg.docspayTab.attribute9.delete;
        iby_disburse_submit_pub_pkg.docspayTab.attribute10.delete;
        iby_disburse_submit_pub_pkg.docspayTab.attribute11.delete;
        iby_disburse_submit_pub_pkg.docspayTab.attribute12.delete;
        iby_disburse_submit_pub_pkg.docspayTab.attribute13.delete;
        iby_disburse_submit_pub_pkg.docspayTab.attribute14.delete;
        iby_disburse_submit_pub_pkg.docspayTab.attribute15.delete;
        iby_disburse_submit_pub_pkg.docspayTab.address_source.delete;
        iby_disburse_submit_pub_pkg.docspayTab.employee_address_code.delete;
        iby_disburse_submit_pub_pkg.docspayTab.employee_payment_flag.delete;
        iby_disburse_submit_pub_pkg.docspayTab.employee_person_id.delete;
        iby_disburse_submit_pub_pkg.docspayTab.employee_address_id.delete;
        iby_disburse_submit_pub_pkg.docspayTab.bank_instruction1_code.delete;
        iby_disburse_submit_pub_pkg.docspayTab.bank_instruction2_code.delete;
        iby_disburse_submit_pub_pkg.docspayTab.payment_text_message1.delete;
        iby_disburse_submit_pub_pkg.docspayTab.payment_text_message2.delete;
        iby_disburse_submit_pub_pkg.docspayTab.payment_text_message3.delete;
        iby_disburse_submit_pub_pkg.docspayTab.group_by_remittance_message.delete;
        iby_disburse_submit_pub_pkg.docspayTab.group_by_bank_charge_bearer.delete;
        iby_disburse_submit_pub_pkg.docspayTab.group_by_delivery_channel.delete;
        iby_disburse_submit_pub_pkg.docspayTab.group_by_settle_priority_flag.delete;
        iby_disburse_submit_pub_pkg.docspayTab.group_by_payment_details_flag.delete;
        iby_disburse_submit_pub_pkg.docspayTab.payment_details_length_limit.delete;
        iby_disburse_submit_pub_pkg.docspayTab.payment_details_formula.delete;
        iby_disburse_submit_pub_pkg.docspayTab.group_by_max_documents_flag.delete;
        iby_disburse_submit_pub_pkg.docspayTab.max_documents_per_payment.delete;
        iby_disburse_submit_pub_pkg.docspayTab.group_by_unique_remit_id_flag.delete;
        iby_disburse_submit_pub_pkg.docspayTab.group_by_payment_reason.delete;
        iby_disburse_submit_pub_pkg.docspayTab.group_by_due_date_flag.delete;
        iby_disburse_submit_pub_pkg.docspayTab.processing_type.delete;
        iby_disburse_submit_pub_pkg.docspayTab.declaration_option.delete;
        iby_disburse_submit_pub_pkg.docspayTab.dcl_only_foreign_curr_pmt_flag.delete;
        iby_disburse_submit_pub_pkg.docspayTab.declaration_curr_fx_rate_type.delete;
        iby_disburse_submit_pub_pkg.docspayTab.declaration_currency_code.delete;
        iby_disburse_submit_pub_pkg.docspayTab.declaration_threshold_amount.delete;
        iby_disburse_submit_pub_pkg.docspayTab.maximum_payment_amount.delete;
        iby_disburse_submit_pub_pkg.docspayTab.minimum_payment_amount.delete;
        iby_disburse_submit_pub_pkg.docspayTab.allow_zero_payments_flag.delete;
        iby_disburse_submit_pub_pkg.docspayTab.support_bills_payable_flag.delete;
        iby_disburse_submit_pub_pkg.docspayTab.iba_legal_entity_id.delete;
        iby_disburse_submit_pub_pkg.docspayTab.int_bank_country_code.delete;
        iby_disburse_submit_pub_pkg.docspayTab.ext_bank_country_code.delete;
        iby_disburse_submit_pub_pkg.docspayTab.foreign_pmts_allowed_flag.delete;
        iby_disburse_submit_pub_pkg.docspayTab.inv_payee_party_id.delete;
        iby_disburse_submit_pub_pkg.docspayTab.inv_party_site_id.delete;
        iby_disburse_submit_pub_pkg.docspayTab.inv_supplier_site_id.delete;
        iby_disburse_submit_pub_pkg.docspayTab.inv_beneficiary_party.delete;
        iby_disburse_submit_pub_pkg.docspayTab.ext_inv_payee_id.delete;
        iby_disburse_submit_pub_pkg.docspayTab.relationship_id.delete;
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute_category.delete;
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute1.delete;
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute2.delete;
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute3.delete;
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute4.delete;
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute5.delete;
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute6.delete;
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute7.delete;
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute8.delete;
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute9.delete;
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute10.delete;
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute11.delete;
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute12.delete;
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute13.delete;
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute14.delete;
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute15.delete;
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute16.delete;
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute17.delete;
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute18.delete;
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute19.delete;
        iby_disburse_submit_pub_pkg.docspayTab.global_attribute20.delete;
        iby_disburse_submit_pub_pkg.docspayTab.dont_pay_flag.delete;
        iby_disburse_submit_pub_pkg.docspayTab.dont_pay_reason_code.delete;
        iby_disburse_submit_pub_pkg.docspayTab.dont_pay_description.delete;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END delete_docspayTab;

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
 PROCEDURE print_debuginfo(
     p_module      IN VARCHAR2,
     p_debug_text  IN VARCHAR2,
     p_debug_level IN VARCHAR2  DEFAULT FND_LOG.LEVEL_STATEMENT
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
     IF (l_default_debug_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         iby_build_utils_pkg.print_debuginfo(p_module, p_debug_text,
             p_debug_level);
     END IF;

 END print_debuginfo;


/*--------------------------------------------------------------------
 | NAME:
 |     update_payreq_status
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
 PROCEDURE update_payreq_status (
     l_payreq_id IN IBY_PAY_SERVICE_REQUESTS.payment_service_request_id%TYPE,
     l_payreq_status IN IBY_PAY_SERVICE_REQUESTS.payment_service_request_status%TYPE,
     x_return_status  IN OUT NOCOPY VARCHAR2)
 IS
 l_module_name     CONSTANT VARCHAR2(200) := G_PKG_NAME ||
                                       '.update_payreq_status';
 BEGIN
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Enter');

     END IF;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     update iby_pay_service_requests
     set payment_service_request_status = l_payreq_status
     where payment_service_request_id = l_payreq_id;

     COMMIT;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;

 EXCEPTION
     WHEN OTHERS THEN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Exception occured when updating '
	         || 'req status');

	     print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	     print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);

     END IF;

     x_return_status := FND_API.G_RET_STS_ERROR;
     ROLLBACK;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT in the Exception block');

     END IF;

 END update_payreq_status;


 PROCEDURE print_log(
     p_module      IN VARCHAR2,
     p_debug_text  IN VARCHAR2
     )
 IS
 l_default_debug_level NUMBER := FND_LOG.LEVEL_STATEMENT;
 BEGIN



     /*
      * Write the debug message to the concurrent manager log file.
      */
     IBY_DEBUG_PUB.log(p_module, p_debug_text,l_default_debug_level);


 END print_log;


END IBY_DISBURSE_SUBMIT_PUB_PKG;

/
