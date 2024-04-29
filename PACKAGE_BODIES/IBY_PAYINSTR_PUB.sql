--------------------------------------------------------
--  DDL for Package Body IBY_PAYINSTR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_PAYINSTR_PUB" AS
/*$Header: ibypymib.pls 120.82.12010000.20 2010/05/28 10:04:46 vkarlapu ship $*/

 --
 -- Declare global variables
 --
 G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBY_PAYINSTR_PUB';
 G_CURRENT_RUNTIME_LEVEL      CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;

 --
 -- List of instruction statuses that are used / set in this
 -- module (payment instruction creation flow).
 --
 INS_STATUS_CREATED        CONSTANT VARCHAR2(100) := 'CREATED';
 INS_STATUS_CREAT_ERROR    CONSTANT VARCHAR2(100) := 'CREATION_ERROR';

 --
 -- List of request statuses that are used / set in this
 -- module (payment instruction creation flow).
 --
 REQ_STATUS_PMTS_CREATED   CONSTANT VARCHAR2(100) := 'PAYMENTS_CREATED';

 --
 -- List of payment statuses that are used / set in this
 -- module (payment instruction creation flow).
 --
 PMT_STATUS_CREATED        CONSTANT VARCHAR2(100) := 'CREATED';
 PMT_STATUS_INSTR_VAL_FAIL CONSTANT VARCHAR2(100) := 'INSTRUCTION_FAILED_VAL';
 PMT_STATUS_INSTR_CREATED  CONSTANT VARCHAR2(100) := 'INSTRUCTION_CREATED';

 --
 -- List of document statuses that are used / set in this
 -- module (payment instruction creation flow).
 --
 DOC_STATUS_PAY_CREATED    CONSTANT VARCHAR2(100) := 'PAYMENT_CREATED';

 -- Transaction types (for inserting into IBY_TRANSACTION_ERRORS table)
 TRXN_TYPE_INSTR  CONSTANT VARCHAR2(100) := 'PAYMENT_INSTRUCTION';

 --
 -- List of valid processing types on the payment profile.
 --
 P_TYPE_PRINTED     CONSTANT VARCHAR2(100) := 'PRINTED';
 P_TYPE_ELECTRONIC  CONSTANT VARCHAR2(100) := 'ELECTRONIC';

 -- Object types (for inserting into user access tables)
 OBJECT_TYPE_INSTR  CONSTANT VARCHAR2(100) := 'PAYMENT_INSTRUCTION';

 --
 -- Forward declarations
 --
 PROCEDURE print_debuginfo(
              p_module      IN VARCHAR2,
              p_debug_text  IN VARCHAR2,
              p_debug_level IN VARCHAR2  DEFAULT FND_LOG.LEVEL_STATEMENT
              );

/*--------------------------------------------------------------------
 | NAME:
 |     createPaymentInstructions
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
 PROCEDURE createPaymentInstructions(

             /*-- processing criteria --*/
             p_processing_type          IN IBY_PAYMENT_PROFILES.
                                               processing_type%TYPE,
             p_pmt_document_id          IN CE_PAYMENT_DOCUMENTS.
                                               payment_document_id%TYPE,
             p_printer_name             IN VARCHAR2,
             p_print_now_flag           IN VARCHAR2,
             p_transmit_now_flag        IN VARCHAR2,

             /*-- user/admin assigned criteria --*/
             p_admin_assigned_ref       IN IBY_PAY_INSTRUCTIONS_ALL.
                                               pay_admin_assigned_ref_code%TYPE,
             p_comments                 IN IBY_PAY_INSTRUCTIONS_ALL.
                                               comments%TYPE,

             /*-- selection criteria --*/
             p_payment_profile_id       IN IBY_PAYMENTS_ALL.
                                               payment_profile_id%TYPE,
             p_calling_app_id           IN IBY_PAY_SERVICE_REQUESTS.
                                               calling_app_id%TYPE,
             p_calling_app_payreq_cd    IN IBY_PAY_SERVICE_REQUESTS.
                                               call_app_pay_service_req_code
                                                   %TYPE,
             p_payreq_id                IN IBY_PAY_SERVICE_REQUESTS.
                                               payment_service_request_id
                                                   %TYPE,
             p_internal_bank_account_id IN IBY_PAYMENTS_ALL.
                                               internal_bank_account_id%TYPE,
             p_payment_currency         IN IBY_PAYMENTS_ALL.
                                               payment_currency_code%TYPE,
             p_le_id                    IN IBY_PAYMENTS_ALL.
                                               legal_entity_id%TYPE,
             p_org_id                   IN IBY_PAYMENTS_ALL.org_id%TYPE,
             p_org_type                 IN IBY_PAYMENTS_ALL.org_type%TYPE,
             p_payment_from_date        IN IBY_PAYMENTS_ALL.payment_date%TYPE,
             p_payment_to_date          IN IBY_PAYMENTS_ALL.payment_date%TYPE,

             /*-- single payments / batch flow identifier --*/
             p_single_pmt_flow_flag     IN VARCHAR2 DEFAULT 'N',

             /*-- out params --*/
             x_pmtInstrTab              IN OUT NOCOPY pmtInstrTabType,
             x_return_status            IN OUT NOCOPY VARCHAR2,
             x_msg_count                OUT NOCOPY NUMBER,
             x_msg_data                 OUT NOCOPY VARCHAR2
             )
 IS

 l_module_name           VARCHAR2(200) := G_PKG_NAME
                                              || '.createPaymentInstructions';
 l_first_record          VARCHAR2(1)   := 'Y';
 l_instr_id              NUMBER(15)    := 0;
 l_pmt_date_flag         VARCHAR2(1)   := 'N';
 l_pmts_in_instr_count   NUMBER(15)    := 0;
 l_instr_amount          NUMBER(15)    := -1;
 l_pmt_fx_amount         NUMBER(15)    := -1;
 l_pmt_details_length    NUMBER(15)    := -1;
 l_pmt_function_flag     VARCHAR2(1)   := 'N';
 l_pmt_reason_flag       VARCHAR2(1)   := 'N';
 l_pmt_curr_flag         VARCHAR2(1)   := 'N';
 l_int_bank_acct_flag    VARCHAR2(1)   := 'N';
 l_max_pmts_flag         VARCHAR2(1)   := 'N';
 l_max_pmts_limit        NUMBER(15)    := 0;
 l_payment_curr_flag     VARCHAR2(1)   := 'N';
 l_le_flag               VARCHAR2(1)   := 'N';
 l_org_flag              VARCHAR2(1)   := 'N';
 l_max_amount_flag       VARCHAR2(1)   := 'N';
 l_max_amount_limit      NUMBER(15)    := 0;
 l_max_amount_curr       VARCHAR2(10)  := '';
 l_exchg_rate_type       VARCHAR2(30)  := '';
 l_rfc_flag              VARCHAR2(1)   := 'N';
 l_pmt_method_flag       VARCHAR2(1)   :='N';
 l_ppr_flag              VARCHAR2(1)   := 'N';

 /*
  * These are used in storing distinct pmt functions and orgs of
  * a payment instruction into schema tables. This information
  * is used by the UI in restricting user access.
  */
 l_pmtFxAccessTypesTab  distinctPmtFxAccessTab;
 l_orgAccessTypesTab    distinctOrgAccessTab;

 /* promissory note flag setting on instruction creation rules */
 l_prom_note_flag        VARCHAR2(1)   := 'N';

 l_ca_id                 NUMBER(15)    := 0;

 /*
  * These two are related data structures. Each row in instrTabType
  * PLSQL table is used in inserting a row into the IBY_PAY_INSTRUCTIONS_ALL
  * table.
  *
  * Since the IBY_PAY_INSTRUCTIONS_ALL table does not contain a payment id,
  * a separate data structure is needed to keep track of the payments
  * that are part of a payment instruction. This information is tracked
  * in the pmtsInInstrTabType table. The rows in pmtsInInstrTabType are
  * used to update the rows in IBY_PAYMENTS_ALL table with payment instruction
  * ids.
  *
  *            l_instrTab                        l_pmtsInInstrTab
  * (insert into IBY_PAY_INSTRUCTIONS_ALL)       (update IBY_PAYMENTS_ALL)
  * /--------------------------------------\     /-------------\
  * |Payment |Payment|..|Instr  |Payment|..|     |Payment |Pmt |
  * |Instr Id|Profile|..|Status |Count  |..|     |Instr Id|Id  |
  * |        |Id     |..|       |       |..|     |        |    |
  * |--------------------------------------|     |-------------|
  * |   4000 |     10|  |CREATED|      3|  |     |   4000 | 501|
  * |        |       |  |       |       |  |     |   4000 | 504|
  * |        |       |  |       |       |  |     |   4000 | 505|
  * |--------|-------|--|-------|-------|--|     |--------|----|
  * |   4001 |     12|  |CREATED|     19|  |     |   4001 | 502|
  * |        |       |  |       |       |  |     |   4001 | 509|
  * |        |       |  |       |       |  |     |   4001 | 511|
  * |        |       |  |       |       |  |     |   4001 | 523|
  * |        |       |  |       |       |  |     |     :  |  : |
  * |--------|-------|--|-------|-------|--|     |--------|----|
  * |    :   |     : |  |    :  |     : |  |     |     :  |  : |
  * \________|_______|__|_______|_______|__/     \________|____/
  *
  * Combining these two structures into one structure is messy
  * because you cannot directly use the combined data structure for
  * bulk updates.
  */

 l_pmtInstrRec               IBY_PAY_INSTRUCTIONS_ALL%ROWTYPE;
 l_pmtInstrTab               pmtInstrTabType;

 l_pmtsInInstrRec            pmtsInPmtInstrRecType;
 l_pmtsInInstrTab            pmtsInPmtInstrTabType;

 l_instrGrpCriTab            instrGroupCriteriaTabType;

 /* holds the error messages against failed instructions */
 l_docErrorTab               IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_errTokenTab               IBY_VALIDATIONSETS_PUB.trxnErrTokenTabType;

 /* previous payment attributes */
 prev_ca_id                  iby_pay_service_requests.calling_app_id%TYPE;
 prev_pmt_id                 iby_payments_all.payment_id%TYPE;
 prev_pmt_currency           iby_payments_all.payment_currency_code%TYPE;
 prev_pmt_amount             iby_payments_all.payment_amount%TYPE;
 prev_int_bank_acct_id       iby_payments_all.
                                 internal_bank_account_id%TYPE;
 prev_org_id                 iby_payments_all.org_id%TYPE;
 prev_org_type               iby_payments_all.org_type%TYPE;
 prev_le_id                  iby_payments_all.legal_entity_id%TYPE;
 prev_profile_id             iby_payments_all.payment_profile_id%TYPE;
 prev_payment_date           iby_payments_all.payment_date%TYPE;
 prev_pmt_function           iby_payments_all.payment_function%TYPE;
 prev_pmt_reason_code        iby_payments_all.payment_reason_code%TYPE;
 prev_pmt_reason_commt       iby_payments_all.payment_reason_comments%TYPE;
 prev_prom_note_flag         iby_payments_all.bill_payable_flag%TYPE;
 prev_rfc_identifier         hz_code_assignments.class_code%TYPE;
 prev_pmt_method_code        iby_payments_all.payment_method_code%TYPE;
 prev_ppr_id                 iby_payments_all.payment_service_request_id%TYPE;

 /* current payment attributes */
 curr_ca_id                  iby_pay_service_requests.calling_app_id%TYPE;
 curr_pmt_id                 iby_payments_all.payment_id%TYPE;
 curr_pmt_currency           iby_payments_all.payment_currency_code%TYPE;
 curr_pmt_amount             iby_payments_all.payment_amount%TYPE;
 curr_int_bank_acct_id       iby_payments_all.
                                 internal_bank_account_id%TYPE;
 curr_org_id                 iby_payments_all.org_id%TYPE;
 curr_org_type               iby_payments_all.org_type%TYPE;
 curr_le_id                  iby_payments_all.legal_entity_id%TYPE;
 curr_profile_id             iby_payments_all.payment_profile_id%TYPE;
 curr_payment_date           iby_payments_all.payment_date%TYPE;
 curr_pmt_function           iby_payments_all.payment_function%TYPE;
 curr_pmt_reason_code        iby_payments_all.payment_reason_code%TYPE;
 curr_pmt_reason_commt       iby_payments_all.payment_reason_comments%TYPE;
 curr_prom_note_flag         iby_payments_all.bill_payable_flag%TYPE;
 curr_rfc_identifier         hz_code_assignments.class_code%TYPE;
 curr_pmt_method_code        iby_payments_all.payment_method_code%TYPE;
 curr_ppr_id                 iby_payments_all.payment_service_request_id%TYPE;

 l_sql_chunk       VARCHAR2(3000);
 l_cursor_stmt     VARCHAR2(8000);

 TYPE dyn_payments    IS REF CURSOR;
 l_pmts_cursor        dyn_payments;

 /* maps profile ids to system profile codes */
 l_profile_map        IBY_BUILD_UTILS_PKG.profileIdToCodeMapTabType;

 l_date_pattern    VARCHAR2(100) := 'YYYY/MM/DD HH24:MI:SS';
 l_pmt_from_date   VARCHAR2(50);
 l_pmt_to_date     VARCHAR2(50);


 BEGIN
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

	     print_debuginfo(l_module_name, 'Calling app id: '
	         || NVL(TO_CHAR(p_calling_app_id), '<not provided>'));
	     print_debuginfo(l_module_name, 'Calling app payment request cd: '
	         || NVL(p_calling_app_payreq_cd, '<not provided>'));

	     print_debuginfo(l_module_name, 'Processing type: '
	         || NVL(p_processing_type, '<not provided>'));

	     print_debuginfo(l_module_name, 'Single payments flow flag: '
	         || NVL(p_single_pmt_flow_flag, '<not provided>'));

     END IF;
     /*
      * 'Processing Type' is a mandatory parameter. Validate
      * that it is correctly provided. Valid values are
      * 'PRINTED', 'ELECTRONIC'.
      */
     IF (p_processing_type IS NULL OR (p_processing_type <> P_TYPE_ELECTRONIC
        AND p_processing_type <> P_TYPE_PRINTED)) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Provided processing type: '
	             || p_processing_type
	             || ' is invalid. Aborting program ..',
	             FND_LOG.LEVEL_UNEXPECTED
	             );

         END IF;
         FND_MESSAGE.SET_NAME('IBY', 'IBY_INS_MISSING_PROCESS_TYPE');
         FND_MSG_PUB.ADD;

         FND_MSG_PUB.COUNT_AND_GET(
             p_count => x_msg_count,
             p_data  => x_msg_data
             );

         APP_EXCEPTION.RAISE_EXCEPTION;

     END IF;


     /* Org type must be provided if org id is provided */
     IF (p_org_id IS NOT NULL and p_org_type IS NULL) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Invalid selection '
	             || 'criteria provided; org id has been provided '
	             || 'but org type has not been provided.',
	             FND_LOG.LEVEL_UNEXPECTED
	             );

	         print_debuginfo(l_module_name, 'Payment instruction '
	             || 'creation will not proceed.',
	             FND_LOG.LEVEL_UNEXPECTED
	             );

         END IF;
         FND_MESSAGE.SET_NAME('IBY', 'IBY_INS_MISSING_ORG_TYPE');
         FND_MSG_PUB.ADD;

         FND_MSG_PUB.COUNT_AND_GET(
             p_count => x_msg_count,
             p_data  => x_msg_data
             );

         APP_EXCEPTION.RAISE_EXCEPTION;

     END IF;


     /*
      * If processing type is 'PRINTED', then the following are mandatory:
      * a. Payment document
      * b. Print now flag
      * c. Payment currency
      */
     IF (p_processing_type = P_TYPE_PRINTED) THEN

         /* Payment document */
         IF (p_pmt_document_id IS NULL) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Payment document id is '
	                 || 'mandatory for printed processing type. '
	                 || 'Insufficient data. Aborting program ..',
	                 FND_LOG.LEVEL_UNEXPECTED
	                 );

             END IF;
             FND_MESSAGE.SET_NAME('IBY', 'IBY_INS_MISSING_PMT_DOCUMENT');
             FND_MSG_PUB.ADD;

             FND_MSG_PUB.COUNT_AND_GET(
                 p_count => x_msg_count,
                 p_data  => x_msg_data
                 );

             APP_EXCEPTION.RAISE_EXCEPTION;

         END IF;

         /* Print now flag */
         IF (p_print_now_flag IS NULL) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Print immediate flag is '
	                 || 'mandatory for printed processing type. '
	                 || 'Insufficient data. Aborting program ..',
	                 FND_LOG.LEVEL_UNEXPECTED
	                 );

             END IF;
             FND_MESSAGE.SET_NAME('IBY', 'IBY_INS_MISSING_PRINT_NOW_FLAG');
             FND_MSG_PUB.ADD;

             FND_MSG_PUB.COUNT_AND_GET(
                 p_count => x_msg_count,
                 p_data  => x_msg_data
                 );

             APP_EXCEPTION.RAISE_EXCEPTION;

         ELSE

             IF (UPPER(p_print_now_flag) = 'Y' AND
                 p_printer_name IS NULL)       THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Printer name is '
	                     || 'mandatory if print immediate flag is '
	                     || 'set to "Y". Aborting program ..',
	                     FND_LOG.LEVEL_UNEXPECTED
	                     );

                 END IF;
                  FND_MESSAGE.SET_NAME('IBY', 'IBY_INS_MISSING_PRINTER');
                  FND_MSG_PUB.ADD;

                  FND_MSG_PUB.COUNT_AND_GET(
                      p_count => x_msg_count,
                      p_data  => x_msg_data
                      );

                 APP_EXCEPTION.RAISE_EXCEPTION;

             END IF;

         END IF;

         /* Payment currency */
         /*
          * Do not validate for payment currency here.
          * As per latest discussion with Omar and Lauren
          * it is the responsibility of the iPayment UI
          * to ensure that 'grouping by payment currency'
          * is enforced when the processing type for a
          * profile is PRINTED.
          *
          * This will mean that for any profile with processing
          * type printed, grouping by payment currency will be
          * triggered. Thus, the payment instructions created for
          * profiles with processing type PRINTED will consist of
          * payments of a single currency only; allowing these
          * payment instructions to be printed on paper stock.
          *
          * In the PICP, 'grouping by payment currency' will
          * continue to remain a user defined grouping rule, but
          * the UI will enforce that is is always turned on for
          * profiles of printed type.
          */
         /*------------------------------------------------------
         IF (p_payment_currency IS NULL) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Payment currency is '
	                 || 'mandatory for printed processing type. '
	                 || 'Insufficient data. Aborting program ..'
	                 );

             END IF;
             FND_MESSAGE.SET_NAME('IBY', 'IBY_INS_MISSING_PMT_CURRENCY');
             FND_MSG_PUB.ADD;

             FND_MSG_PUB.COUNT_AND_GET(
                 p_count => x_msg_count,
                 p_data  => x_msg_data
                 );

             APP_EXCEPTION.RAISE_EXCEPTION;

         END IF;
         ---------------------------------------------------------*/

     END IF;

     /*
      * If processing type is 'ELECTRONIC', then the following are mandatory:
      * a. Transmit now flag
      */
     IF (p_processing_type = P_TYPE_ELECTRONIC) THEN

         IF (p_transmit_now_flag IS NULL) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Transmit now flag is '
	                 || 'mandatory for electronic processing type. '
	                 || 'Insufficient data. Aborting program ..',
	                 FND_LOG.LEVEL_UNEXPECTED
	                 );

             END IF;
             FND_MESSAGE.SET_NAME('IBY', 'IBY_INS_MISSING_TRANSMIT_NOW_FLAG');
             FND_MSG_PUB.ADD;

             FND_MSG_PUB.COUNT_AND_GET(
                 p_count => x_msg_count,
                 p_data  => x_msg_data
                 );

             APP_EXCEPTION.RAISE_EXCEPTION;

         END IF;

     END IF;

     /*
      * Build up the WHERE clause (of the SQL statement to pick up the
      * available payments) in chunks; add only non-null selection
      * parameters into the WHERE clause.
      */
     IF (p_calling_app_id IS NOT NULL) THEN
         l_sql_chunk := l_sql_chunk
                            || ' AND prq.calling_app_id = '
                            || p_calling_app_id
                            ;
     END IF;

     IF (p_payreq_id IS NOT NULL) THEN
         l_sql_chunk := l_sql_chunk
                            || ' AND prq.payment_service_request_id = '
                            || p_payreq_id
                            ;
     END IF;



     l_pmt_from_date := To_Char(p_payment_from_date,l_date_pattern);
     l_pmt_to_date := To_Char(p_payment_to_date,l_date_pattern);

     /*
      * Build up payment date shunks of the form -
      * TO_DATE('29-MAR-06', 'YYYY/MM/DD HH24:MI:SS')
      */
     IF (p_payment_from_date IS NOT NULL) THEN
         l_sql_chunk := l_sql_chunk
                            || ' AND pmts.payment_date >= '
                            || 'TO_DATE('
                            || ''''
                            || l_pmt_from_date
                            || ''''
                            || ', '
                            || ''''
                            || l_date_pattern
                            || ''''
                            || ')'
                            ;
     END IF;

     IF (p_payment_to_date IS NOT NULL) THEN
         l_sql_chunk := l_sql_chunk
                            || ' AND pmts.payment_date <= '
                            || 'TO_DATE('
                            || ''''
                            || l_pmt_to_date
                            || ''''
                            || ', '
                            || ''''
                            || l_date_pattern
                            || ''''
                            || ')'
                            ;
     END IF;

     IF (p_internal_bank_account_id IS NOT NULL) THEN
         l_sql_chunk := l_sql_chunk
                            || ' AND pmts.internal_bank_account_id = '
                            || p_internal_bank_account_id;
     END IF;

     IF (p_payment_profile_id IS NOT NULL) THEN
         l_sql_chunk := l_sql_chunk
                            || ' AND pmts.payment_profile_id = '
                            || p_payment_profile_id
                            ;
     END IF;

     IF (p_payment_currency IS NOT NULL) THEN
         l_sql_chunk := l_sql_chunk
                            || ' AND pmts.payment_currency_code = '
                            || ''''
                            || p_payment_currency
                            || ''''
                            ;
     END IF;

     /*
      * Org type and org id should always be given
      * together as a pair.
      */
     IF (p_org_id IS NOT NULL AND p_org_type IS NOT NULL) THEN
         l_sql_chunk := l_sql_chunk
                            || ' AND pmts.org_id = '
                            || p_org_id
                            || ' AND pmts.org_type = '
                            || ''''
                            || p_org_type
                            || ''''
                            ;

     END IF;

     IF (p_le_id IS NOT NULL) THEN
         l_sql_chunk := l_sql_chunk
                            || ' AND pmts.legal_entity_id = '
                            || p_le_id
                            ;
     END IF;

     /* log the created chunk */
     IF (l_sql_chunk IS NULL) THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'l_sql_chunk is null. '
	             || 'All available payments will be picked up '
	             || 'for payment instruction creation.'
	             );
         END IF;
     ELSE

         /*
          * Add a trailing space to the SQL chunk. This will
          * ensure that there is no SQL typo caused by any
          * subsequent appent to this chunk.
          */
         l_sql_chunk := l_sql_chunk || ' ';

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'l_sql_chunk: '
	             || l_sql_chunk);
         END IF;
     END IF;

     /*
      * Cursor to pick up payment requests that match provided
      * selection criteria:
      *
      * Some of these criteria can be null, as they are optional.
      * In such a case, do not put that criteria in the WHERE
      * clause (because then you will not get any payments).
      * Instead, build up the SQL statement in chunks using
      * only the non-null selection parameters, and use this
      * chunk in the WHERE clause.
      *
      * We want to pick up all payments that match the provided
      * selection criteria. If all selection criteria are set
      * to 'null', it means that user wants to select all pending
      * payments.
      *
      * Because the WHERE clause is dynamic, we have to use
      * a dynamic cursor (REF CURSOR).
      */

     /*
      * Important Technical Note:
      * -------------------------
      * This SELECT statement uses SKIP LOCKED syntax.
      * This is an undocumented feature of Oracle, that
      * will only select unlocked rows.
      *
      * When there are multiple instances of the payment
      * instruction program running concurrently, we need to
      * make sure that no two instances are operating on the
      * same rows. So we lock the rows that each instance
      * picks up by using SELECT .. FOR UPDATE syntax.
      *
      * Now, suppose the second instance of the payment instruction
      * creation program is invoked concurrently, it will also
      * attempt to pick up all rows that match the provided
      * selection criteria. If even one row in the selection
      * maps to a row that has already been picked up by the
      * first instance of the payment instruction creation
      * program, then the second instance has to wait till the
      * first instance completes (because the rows were locked).
      *
      * We want the second instance to only pick up the rows that
      * were not already selected by the first instance (i.e.,
      * pick up only unlocked rows). This is accomplished by the
      * SELECT .. FOR UPDATE SKIP LOCKED syntax.
      *
      * With this approach, it is possible to have multiple
      * instances of the payment instruction creation running
      * concurrently and each operating on it's own data.
      *
      * Though the SKIP LOCKED feature is undocumented, we have
      * received permission from the performance team to
      * use it.
      */

     /*
      * Note I:
      * Since this is a 'select for update', we cannot select
      * from views. We have to use the underlying base tables
      * instead. That's why we select from the base tables
      * for the payment profile.
      */

     /*
      * Note II:
      * Debugging this select can be tricky. Sometimes the
      * select will return no rows even when the matching rows
      * are present in the table; this is because of the SKIP
      * LOCKED syntax - it's going to skip any rows that are
      * locked even if they match the selection criteria.
      *
      * To debug the select statement, comment out the skip
      * locked syntax.
      */

     l_cursor_stmt :=
         'SELECT '
             || 'prq.call_app_pay_service_req_code,           '
             || 'prq.calling_app_id,                          '
             || 'prq.payment_service_request_id,              '
             || 'pmts.payment_id,                             '
             || 'pmts.internal_bank_account_id,               '
             || 'pmts.payment_profile_id,                     '
             || 'pmts.org_id,                                 '
             || 'pmts.org_type,                               '
             || 'pmts.legal_entity_id,                        '
             || 'pmts.payment_currency_code,                  '
             || 'pmts.payment_amount,                         '
             || 'pmts.payment_date,                           '
             || 'pmts.payment_function,                       '
             || 'pmts.payment_reason_code,                    '
             || 'pmts.payment_reason_comments,                '
             || 'NVL(LENGTH(pmts.payment_details), 0),        '
             || 'pmts.bill_payable_flag ,                     '
             || 'pmts.payment_service_request_id,             '
	     || 'rfc_ca.class_code,                           '
	     || 'pmts.payment_method_code,                    '
             || 'icr.group_by_payment_date,                   '
             || 'icr.group_by_payment_currency,               '
             || 'icr.group_by_max_payments_flag,              '
             || 'icr.max_payments_per_instruction,            '
             || 'icr.group_by_internal_bank_account,          '
             || 'icr.group_by_max_instruction_flag,           '
             || 'icr.max_amount_per_instr_value,              '
             || 'icr.max_amount_per_instr_curr_code,          '
             || 'icr.max_amount_fx_rate_type,                 '
             || 'icr.group_by_pay_service_request,            '
             || 'icr.group_by_legal_entity,                   '
             || 'icr.group_by_organization,                   '
             || 'icr.group_by_payment_function,               '
             || 'icr.group_by_payment_reason,                 '
             || 'icr.group_by_bill_payable,                   '
             || 'icr.group_by_pay_service_request,            '
             || 'icr.group_by_rfc ,                            '
	     || 'icr.group_by_payment_method                  '
         || 'FROM '
             || 'IBY_PAYMENTS_SEC_V             pmts,           '
             || 'IBY_INSTR_CREATION_RULES     icr,            '
             || 'IBY_PAY_SERVICE_REQUESTS     prq,            '
             || 'IBY_SYS_PMT_PROFILES_B       sppf,           '
             || 'IBY_ACCT_PMT_PROFILES_B      appf,           '
             || 'HZ_PARTIES                   branch_party,   '
             || 'HZ_CODE_ASSIGNMENTS          rfc_ca,         '
             || 'CE_BANK_ACCOUNTS             bank_accts      '
         || 'WHERE  '
             || 'pmts.payment_status         = :pmt_status                AND '
             || 'sppf.processing_type        = :processing_type           AND '
             || 'pmts.payment_service_request_id  =                           '
                 || 'prq.payment_service_request_id                       AND '
             || 'prq.payment_service_request_status = :req_status         AND '
             || 'pmts.payment_profile_id     = appf.payment_profile_id    AND '
             || 'sppf.system_profile_code    =                                '
                 || 'appf.system_profile_code(+)                          AND '
             || 'appf.system_profile_code    = icr.system_profile_code(+) AND '
             || 'rfc_ca.owner_table_name(+)  = :table_name                AND '
             || 'rfc_ca.class_category(+)    = :category                  AND '
             || 'rfc_ca.owner_table_id(+)    = branch_party.party_id      AND '
             || 'branch_party.party_id       = bank_accts.bank_branch_id  AND '
             || 'bank_accts.bank_account_id  =                                '
             || 'pmts.internal_bank_account_id                                '
             || NVL (l_sql_chunk, 'AND 1=1 ')
         || 'ORDER BY '
             || 'pmts.payment_profile_id,       '  -- |
             || 'pmts.payment_date,             '  -- |
             || 'pmts.payment_currency_code,    '  -- |
             || 'pmts.internal_bank_account_id, '  -- | Ensure that the grouping
             || 'pmts.legal_entity_id,          '  -- | logic below follows the
             || 'pmts.org_id,                   '  -- | same order as this
             || 'pmts.org_type,                 '  -- | order by clause; else,
             || 'pmts.payment_function,         '  -- | more instructions will
             || 'pmts.payment_reason_code,      '  -- | be created than the
             || 'pmts.payment_reason_comments,  '  -- | absolute minimum.
             || 'pmts.bill_payable_flag,        '  -- |
             || 'pmts.payment_service_request_id,' -- |
             || 'rfc_ca.class_code,              '  -- |
	     || 'pmts.payment_method_code       '  -- |
         || 'FOR UPDATE of pmts.payment_id, prq.payment_service_request_id SKIP LOCKED '
         ;
	 /* Modified the for update clause for the bug 7261651*/

     /*
      * Print the cursor statement for debug purposes.
      */
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Dynamic cursor statement: ');
             IBY_BUILD_UTILS_PKG.printWrappedString(l_cursor_stmt);
     	     print_debuginfo(l_module_name, 'cursor bind parameters - ');
	     print_debuginfo(l_module_name, ':pmt_status      = '
	         || PMT_STATUS_CREATED);
	     print_debuginfo(l_module_name, ':processing_type = '
	         || p_processing_type);
	     print_debuginfo(l_module_name, ':req_status      = '
	         || REQ_STATUS_PMTS_CREATED);
	     print_debuginfo(l_module_name, ':table_name      = '
	         || 'HZ_PARTIES');
	     print_debuginfo(l_module_name, ':category        = '
	         || 'RFC_IDENTIFIER');

     END IF;
     OPEN l_pmts_cursor FOR
         l_cursor_stmt
     USING
         PMT_STATUS_CREATED,
         p_processing_type,
         REQ_STATUS_PMTS_CREATED,
         'HZ_PARTIES',
         'RFC_IDENTIFIER'
         ;
     FETCH l_pmts_cursor BULK COLLECT INTO l_instrGrpCriTab;
     CLOSE l_pmts_cursor;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Number of payments matching '
	         || 'provided selection criteria: '
	         || l_instrGrpCriTab.COUNT
	         );

     END IF;
     /*
      * Exit if no payments were found.
      */
     IF (l_instrGrpCriTab.COUNT = 0) THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'No payments were '
	             || 'retrieved from DB. Either no pending '
	             || 'payments exist, or one or more '
	             || 'of the selected tables were locked causing '
	             || 'the select to exit due to NOWAIT clause. '
	             || 'You might want to try payment instruction '
	             || 'creation again later.'
	             );

	         print_debuginfo(l_module_name, 'Exiting '
	             || 'payment instruction creation ..');

         END IF;
         x_return_status := FND_API.G_RET_STS_SUCCESS;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');
         END IF;
         RETURN;
     END IF;

     /*
      * Loop through all the fetched payments, grouping them
      * into payment instructions.
      */
     FOR i in l_instrGrpCriTab.FIRST .. l_instrGrpCriTab.LAST LOOP

         curr_ca_id             := l_instrGrpCriTab(i).calling_app_id;
         curr_pmt_id            := l_instrGrpCriTab(i).payment_id;
         curr_int_bank_acct_id  := l_instrGrpCriTab(i).int_bank_acct_id;
         curr_profile_id        := l_instrGrpCriTab(i).payment_profile_id;
         curr_org_id            := l_instrGrpCriTab(i).org_id;
         curr_org_type          := l_instrGrpCriTab(i).org_type;
         curr_le_id             := l_instrGrpCriTab(i).le_id;
         curr_pmt_currency      := l_instrGrpCriTab(i).payment_currency;
         curr_pmt_amount        := l_instrGrpCriTab(i).payment_amount;
         curr_payment_date      := l_instrGrpCriTab(i).payment_date;
         curr_pmt_function      := l_instrGrpCriTab(i).payment_function;
         curr_pmt_reason_code   := l_instrGrpCriTab(i).payment_reason_code;
         curr_pmt_reason_commt  := l_instrGrpCriTab(i).payment_reason_comments;
         curr_prom_note_flag    := l_instrGrpCriTab(i).pmt_prom_note_flag;
         curr_ppr_id            := l_instrGrpCriTab(i).ppr_id;
         curr_rfc_identifier    := l_instrGrpCriTab(i).rfc_identifier;
         curr_pmt_method_code   := l_instrGrpCriTab(i).payment_method_code;

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	          print_debuginfo(l_module_name, 'curr_pmt_method_code :=' ||curr_pmt_method_code ||' and l_instrGrpCriTab('||i||').payment_method_code '||l_instrGrpCriTab(i).payment_method_code );
	          print_debuginfo(l_module_name, 'Payment_id :'||l_instrGrpCriTab(i).payment_id);
	  END IF;
         /* used in raising biz events */
         l_ca_id                := l_instrGrpCriTab(i).calling_app_id;

         /* user defined grouping rule flags */
         l_pmt_date_flag        := l_instrGrpCriTab(i).pmt_date_flag;
         l_pmt_curr_flag        := l_instrGrpCriTab(i).pmt_curr_flag;
         l_int_bank_acct_flag   := l_instrGrpCriTab(i).int_bank_acct_flag;
         l_le_flag              := l_instrGrpCriTab(i).le_flag;
         l_org_flag             := l_instrGrpCriTab(i).org_flag;
         l_max_pmts_flag        := l_instrGrpCriTab(i).max_payments_flag;
         l_max_pmts_limit       := l_instrGrpCriTab(i).max_payments_limit;
         l_max_amount_flag      := l_instrGrpCriTab(i).max_amount_flag;
         l_max_amount_limit     := l_instrGrpCriTab(i).max_amount_limit;
         l_max_amount_curr      := l_instrGrpCriTab(i).max_amount_currency;
         l_exchg_rate_type      := l_instrGrpCriTab(i).max_amount_fx_rate_type;
         l_pmt_details_length   := l_instrGrpCriTab(i).pmt_details_length;
         l_pmt_function_flag    := l_instrGrpCriTab(i).pmt_function_flag;
         l_pmt_reason_flag      := l_instrGrpCriTab(i).pmt_reason_flag;
         l_prom_note_flag       := l_instrGrpCriTab(i).prom_note_flag;
         l_ppr_flag             := l_instrGrpCriTab(i).ppr_flag;
         l_rfc_flag             := l_instrGrpCriTab(i).rfc_flag;
         l_pmt_method_flag      := l_instrGrpCriTab(i).pmt_method_flag;
         l_payment_curr_flag    := l_instrGrpCriTab(i).pmt_curr_flag;

         /*
          * Log all the fetched payment fields
          */
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name,
	             'Fetched payment data for payment id: ' || curr_pmt_id
	             || ', calling app id: '        || curr_ca_id
	             || ', ppr id: '                || curr_ppr_id
	             || ', internal bank account: ' || curr_int_bank_acct_id
	             || ', profile: '               || curr_profile_id
	             || ', org: '                   || curr_org_id
	             || ', org type: '              || curr_org_type
	             || ', payment currency: '      || curr_pmt_currency
	             || ', payment amount: '        || curr_pmt_amount
	             || ', payment date: '          || curr_payment_date
	             || ', payment function: '      || curr_pmt_function
	             || ', payment reason code: '   || curr_pmt_reason_code
	             || ', payment reason commts: ' || curr_pmt_reason_commt
	             || ', is pmt a prom note? '    || curr_prom_note_flag
	             || ', rfc identifier :'        || curr_rfc_identifier
		     || ', payment method: '        || curr_pmt_method_code
	             );

	         print_debuginfo(l_module_name,
	             'Fetched payment data for payment id: ' || curr_pmt_id
	             || ', max pmts flag: '         || l_max_pmts_flag
	             || ', max pmts limit: '        || l_max_pmts_limit
	             || ', max amount flag: '       || l_max_amount_flag
	             || ', max amount curr: '       || l_max_amount_curr
	             || ', max amount limit: '      || l_max_amount_limit
	             || ', pmt function flag: '     || l_pmt_function_flag
	             || ', pmt reason flag: '       || l_pmt_reason_flag
	             || ', prom note flag: '        || l_prom_note_flag
	             || ', ppr flag: '              || l_ppr_flag
	             || ', rfc flag: '              || l_rfc_flag
	             || ', pmt curr flag: '         || l_payment_curr_flag
		     || ', pmt method flag: '       || l_pmt_method_flag
	         );

         END IF;
         IF (l_first_record = 'Y') THEN
             prev_pmt_id               := curr_pmt_id;
             prev_ca_id                := curr_ca_id;
             prev_int_bank_acct_id     := curr_int_bank_acct_id;
             prev_profile_id           := curr_profile_id;
             prev_org_id               := curr_org_id;
             prev_org_type             := curr_org_type;
             prev_pmt_currency         := curr_pmt_currency;
             prev_pmt_amount           := curr_pmt_amount;
             prev_payment_date         := curr_payment_date;
             prev_pmt_function         := curr_pmt_function;
             prev_pmt_reason_code      := curr_pmt_reason_code;
             prev_pmt_reason_commt     := curr_pmt_reason_commt;
             prev_prom_note_flag       := curr_prom_note_flag;
             prev_ppr_id               := curr_ppr_id;
             prev_rfc_identifier       := curr_rfc_identifier;
             prev_pmt_method_code      := curr_pmt_method_code;
         END IF;

         IF (UPPER(l_max_amount_flag) = 'Y') THEN

             l_pmt_fx_amount := getFxAmount(
                 curr_pmt_currency,           /* IN:  source currency */
                 l_max_amount_curr,           /* IN:  target currency */
                 curr_payment_date,           /* IN:  exchange rate date */
                 l_exchg_rate_type,           /* IN:  exchange rate type */
                 curr_pmt_amount              /* IN:  source amount */
                 );

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Payment amount in fx '
	                 || 'currency: '
	                 ||  l_pmt_fx_amount
	                 );

             END IF;
             IF (l_pmt_fx_amount = -1) THEN

                 /*
                  * This means that an exception occured when we
                  * attempted currency conversion. We cannot
                  * proceed. Stop the program.
                  */

                 /*
                  * Error occurred in call to GL API to convert
                  * amount. Raise exception.
                  */
                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Currency conversion '
	                     || 'from currency '
	                     || curr_pmt_currency
	                     || ' to currency '
	                     || l_max_amount_curr
	                     || ' with exchange rate date '
	                     || curr_payment_date
	                     || ' and exchange rate type '
	                     || l_exchg_rate_type
	                     || ' failed. '
	                     || 'Raising exception.',
	                     FND_LOG.LEVEL_UNEXPECTED
	                     );

                 END IF;
                 APP_EXCEPTION.RAISE_EXCEPTION;

             END IF;

         END IF;

         /*
          * We have just fetched a new payment from the selection.
          * We will either insert this payment into a new instruction or
          * we will be inserting this payment into the currently running
          * payment instruction.
          *
          * In either case, we need to insert this pmt into an instruction.
          * So pre-populate the instruction record with attributes of
          * this payment. This is because the instruction takes on the
          * attributes of it's constituent payments.
          *
          * Note: For user defined grouping rules, we will
          * have to populate the payment attribute only if
          * the user has turned on grouping by that attribute.
          */

         /* Only pre-fill hardcoded grouping rule attributes */
         l_pmtInstrRec.payment_profile_id       := curr_profile_id;

         /*
          * Pre-fill all user provided instruction attributes.
          * These attributes are applicable to all payment
          * instructions created as part of this processing run.
          */

         l_pmtInstrRec.comments                := p_comments;
         l_pmtInstrRec.pay_admin_assigned_ref_code := p_admin_assigned_ref;
         l_pmtInstrRec.printer_name            := p_printer_name;
         l_pmtInstrRec.payment_document_id     := p_pmt_document_id;

         /*
          * The 'print now' and 'transmit now' flags are not null
          * columns in the database. However, they are optional
          * params in the API.
          *
          * Therefore, set these flags to a default value if not
          * provided (based on the processing type).
          */
         IF (p_processing_type = P_TYPE_PRINTED) THEN
             l_pmtInstrRec.print_instruction_immed_flag := p_print_now_flag;
             l_pmtInstrRec.transmit_instr_immed_flag := 'N';
         ELSE
             l_pmtInstrRec.print_instruction_immed_flag := 'N';
             l_pmtInstrRec.transmit_instr_immed_flag := p_transmit_now_flag;
         END IF;

         /*
          * Pre-fill grouping rule attributes for user
          * selected grouping rules.
          *
          * It is necessary to pre-fill user defined grouping
          * attributes before the grouping rules are triggered
          * because we don't know which user defined grouping rules
          * are going to get triggered first, and once a rule is
          * triggered all rules below it are skipped. So it is too
          * late to populate grouping attributes within the grouping
          * rule itself.
          */

         IF (l_int_bank_acct_flag = 'Y') THEN
             l_pmtInstrRec.internal_bank_account_id := curr_int_bank_acct_id;
         END IF;

         IF (l_pmt_curr_flag = 'Y') THEN
             l_pmtInstrRec.payment_currency_code    := curr_pmt_currency;
         END IF;

         IF (l_le_flag = 'Y') THEN
             l_pmtInstrRec.legal_entity_id          := curr_le_id;
         END IF;

         IF (l_org_flag = 'Y') THEN
             l_pmtInstrRec.org_id                   := curr_org_id;
             l_pmtInstrRec.org_type                 := curr_org_type;
         END IF;

         IF (l_pmt_date_flag = 'Y') THEN
             l_pmtInstrRec.payment_date             := curr_payment_date;
         END IF;

         IF (l_pmt_function_flag = 'Y') THEN
             l_pmtInstrRec.payment_function         := curr_pmt_function;
         END IF;

         IF (l_pmt_reason_flag = 'Y') THEN
             l_pmtInstrRec.payment_reason_code      := curr_pmt_reason_code;
             l_pmtInstrRec.payment_reason_comments  := curr_pmt_reason_commt;
         END IF;

         IF (l_prom_note_flag = 'Y') THEN
             l_pmtInstrRec.bill_payable_flag        := curr_prom_note_flag;
         END IF;

         IF (l_ppr_flag = 'Y') THEN
             l_pmtInstrRec.payment_service_request_id := curr_ppr_id;
         END IF;

         IF (l_rfc_flag = 'Y') THEN
             l_pmtInstrRec.rfc_identifier           := curr_rfc_identifier;
         END IF;
         -- SEPA specific code
	 IF (l_pmt_method_flag = 'Y') THEN
             l_pmtInstrRec.payment_method_code      := curr_pmt_method_code;
         END IF;

         /*
          * Pre-fill the payment record with the details
          * of the current payment.
          */
         l_pmtsInInstrRec.payment_id        := curr_pmt_id;
         l_pmtsInInstrRec.payment_amount    := curr_pmt_amount;
         l_pmtsInInstrRec.payment_currency  := curr_pmt_currency;
         l_pmtsInInstrRec.profile_id        := curr_profile_id;
         l_pmtsInInstrRec.processing_type   := p_processing_type;
         l_pmtsInInstrRec.pmt_details_len   := l_pmt_details_length;


         /*-- HARDCODED GROUPING RULES START HERE --*/

         /*
          * Grouping Step 1: Payment Profile ID
          */
         IF (prev_profile_id <> curr_profile_id) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Grouping by payment '
	                 || 'profile triggered for payment '
	                 || curr_pmt_id);

             END IF;
             insertPmtIntoInstruction(l_pmtInstrRec, l_pmtInstrTab,
                 true, l_instr_id,
                 l_pmtsInInstrTab, l_pmtsInInstrRec,
                 l_pmts_in_instr_count, l_instr_amount);

             GOTO label_finish_iteration;
         END IF;

         /*-- USER DEFINED GROUPING RULES START HERE --*/

         /*
          * Grouping Step 2: Payment Date
          */
         IF (l_pmt_date_flag = 'Y') THEN
             IF (prev_payment_date <> curr_payment_date) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Grouping by '
	                     || 'payment date triggered for payment '
	                     || curr_pmt_id);

                 END IF;
                 insertPmtIntoInstruction(l_pmtInstrRec, l_pmtInstrTab,
                     true, l_instr_id,
                     l_pmtsInInstrTab, l_pmtsInInstrRec,
                     l_pmts_in_instr_count, l_instr_amount);

                 GOTO label_finish_iteration;
             END IF;
         END IF;

         /*
          * Grouping Step 3: Payment Currency
          */
         IF (l_payment_curr_flag = 'Y') THEN
             IF (prev_pmt_currency <> curr_pmt_currency) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Grouping by payment '
	                     || 'currency triggered for payment '
	                     || curr_pmt_id);

                 END IF;
                 insertPmtIntoInstruction(l_pmtInstrRec, l_pmtInstrTab,
                     true, l_instr_id,
                     l_pmtsInInstrTab, l_pmtsInInstrRec,
                     l_pmts_in_instr_count, l_instr_amount);

                 GOTO label_finish_iteration;
             END IF;
         END IF;

         /*
          * Grouping Step 4: Internal Bank Account ID
          */
         IF (l_int_bank_acct_flag = 'Y') THEN
             IF (prev_int_bank_acct_id <> curr_int_bank_acct_id) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Grouping by internal bank '
	                     || 'account triggered for payment '
	                     || curr_pmt_id);

                 END IF;
                 insertPmtIntoInstruction(l_pmtInstrRec, l_pmtInstrTab,
                     true, l_instr_id,
                     l_pmtsInInstrTab, l_pmtsInInstrRec,
                     l_pmts_in_instr_count, l_instr_amount);

                 GOTO label_finish_iteration;
             END IF;
         END IF;

         /*
          * Grouping Step 5: Legal Entity (LE)
          */
         IF (l_le_flag = 'Y') THEN
             IF (prev_le_id <> curr_le_id) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Grouping by '
	                     || 'legal entity (LE) triggered for payment '
	                     || curr_pmt_id);

                 END IF;
                 insertPmtIntoInstruction(l_pmtInstrRec, l_pmtInstrTab,
                     true, l_instr_id,
                     l_pmtsInInstrTab, l_pmtsInInstrRec,
                     l_pmts_in_instr_count, l_instr_amount);

                 GOTO label_finish_iteration;
             END IF;
         END IF;

         /*
          * Grouping Step 6: Organization Id And Organization Type
          */
         IF (l_org_flag = 'Y') THEN
             IF (prev_org_id <> curr_org_id)     OR
                (prev_org_type <> curr_org_type) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Grouping by '
	                     || 'organization triggered for payment '
	                     || curr_pmt_id);

                 END IF;
                 insertPmtIntoInstruction(l_pmtInstrRec, l_pmtInstrTab,
                     true, l_instr_id,
                     l_pmtsInInstrTab, l_pmtsInInstrRec,
                     l_pmts_in_instr_count, l_instr_amount);

                 GOTO label_finish_iteration;
             END IF;
         END IF;

         /*
          * Grouping Step 7: Payment Function
          */
         IF (l_pmt_function_flag = 'Y') THEN
             IF (prev_pmt_function <> curr_pmt_function) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Grouping by '
	                     || 'payment function triggered for payment '
	                     || curr_pmt_id);

                 END IF;
                 insertPmtIntoInstruction(l_pmtInstrRec, l_pmtInstrTab,
                     true, l_instr_id,
                     l_pmtsInInstrTab, l_pmtsInInstrRec,
                     l_pmts_in_instr_count, l_instr_amount);

                 GOTO label_finish_iteration;
             END IF;
         END IF;

         /*
          * Grouping Step 8: Payment Reason Code / Comments
          */
         IF (l_pmt_reason_flag = 'Y') THEN
             IF (NVL(prev_pmt_reason_code, 0) <>
                     NVL(curr_pmt_reason_code, 0) OR
                 NVL(prev_pmt_reason_commt, 0) <>
                     NVL(curr_pmt_reason_commt, 0)) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Grouping by '
	                     || 'payment reason code / comments triggered for payment '
	                     || curr_pmt_id);

                 END IF;
                 insertPmtIntoInstruction(l_pmtInstrRec, l_pmtInstrTab,
                     true, l_instr_id,
                     l_pmtsInInstrTab, l_pmtsInInstrRec,
                     l_pmts_in_instr_count, l_instr_amount);

                 GOTO label_finish_iteration;
             END IF;
         END IF;

         /*
          * Grouping Step 9: Promissory Note Flag
          */
         IF (l_prom_note_flag = 'Y') THEN
             IF (NVL(prev_prom_note_flag, 0) <> NVL(curr_prom_note_flag, 0))
                 THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Grouping by '
	                     || 'promissory note flag triggered for payment '
	                     || curr_pmt_id);

                 END IF;
                 insertPmtIntoInstruction(l_pmtInstrRec, l_pmtInstrTab,
                     true, l_instr_id,
                     l_pmtsInInstrTab, l_pmtsInInstrRec,
                     l_pmts_in_instr_count, l_instr_amount);

                 GOTO label_finish_iteration;
             END IF;
         END IF;

         /*
          * Grouping Step 10: Payment Process Request
          */
         IF (l_ppr_flag = 'Y') THEN
             IF (prev_ppr_id <> curr_ppr_id)
                 THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Grouping by '
	                     || 'payment process request triggered for payment '
	                     || curr_pmt_id);

                 END IF;
                 insertPmtIntoInstruction(l_pmtInstrRec, l_pmtInstrTab,
                     true, l_instr_id,
                     l_pmtsInInstrTab, l_pmtsInInstrRec,
                     l_pmts_in_instr_count, l_instr_amount);

                 GOTO label_finish_iteration;
             END IF;
         END IF;

         /*
          * Grouping Step 11: RFC Flag
          */
         IF (l_rfc_flag = 'Y') THEN
             IF (NVL(prev_rfc_identifier, 0) <> NVL(curr_rfc_identifier, 0))
                 THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Grouping by '
	                     || 'rfc identifier triggered for payment '
	                     || curr_pmt_id);

                 END IF;
                 insertPmtIntoInstruction(l_pmtInstrRec, l_pmtInstrTab,
                     true, l_instr_id,
                     l_pmtsInInstrTab, l_pmtsInInstrRec,
                     l_pmts_in_instr_count, l_instr_amount);

                 GOTO label_finish_iteration;
             END IF;
         END IF;

         -- SEPA code
	  IF (l_pmt_method_flag = 'Y') THEN
             IF (NVL(prev_pmt_method_code, 0) <> NVL(curr_pmt_method_code, 0))
                 THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Grouping by '
	                     || 'payment method triggered for payment '
	                     || curr_pmt_id);

                 END IF;
                 insertPmtIntoInstruction(l_pmtInstrRec, l_pmtInstrTab,
                     true, l_instr_id,
                     l_pmtsInInstrTab, l_pmtsInInstrRec,
                     l_pmts_in_instr_count, l_instr_amount);

                 GOTO label_finish_iteration;
             END IF;
         END IF;

         /*
          * Grouping Step 12: Max Payments Per Instruction
          */
         IF (l_max_pmts_flag = 'Y') THEN
             IF (l_pmts_in_instr_count = l_max_pmts_limit) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Grouping by '
	                     || 'max payments per instruction triggered '
	                     || 'for payment '
	                     || curr_pmt_id);

                 END IF;
                 insertPmtIntoInstruction(l_pmtInstrRec, l_pmtInstrTab,
                     true, l_instr_id,
                     l_pmtsInInstrTab, l_pmtsInInstrRec,
                     l_pmts_in_instr_count, l_instr_amount);

                 GOTO label_finish_iteration;
             END IF;
         END IF;

         /*
          * Grouping Step 13: Break Payments According To Max Amount
          *                  Per Instruction
          */
         IF (UPPER(l_max_amount_flag) = 'Y') THEN
             IF ((l_instr_amount + l_pmt_fx_amount)
                > l_max_amount_limit) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Grouping by '
	                     || 'max total amount per instruction triggered '
	                     || 'for payment '
	                     || curr_pmt_id);

                 END IF;
                 insertPmtIntoInstruction(l_pmtInstrRec, l_pmtInstrTab,
                     true, l_instr_id,
                     l_pmtsInInstrTab, l_pmtsInInstrRec,
                     l_pmts_in_instr_count, l_instr_amount);

                 GOTO label_finish_iteration;
             END IF;
         END IF;

         /*
          * End Of Grouping:
          * If a document reaches here, it means that this document
          * is similar to the previous document as far a grouping
          * criteria is concerned.
          *
          * Add this document to the currently running payment.
          */
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'No grouping rules '
	             || 'were triggered for payment '
	             || curr_pmt_id);

         END IF;
         insertPmtIntoInstruction(l_pmtInstrRec, l_pmtInstrTab,
             false, l_instr_id,
             l_pmtsInInstrTab, l_pmtsInInstrRec,
             l_pmts_in_instr_count, l_instr_amount);

         <<label_finish_iteration>>

         /*
          * We just finished inserting a payment into an
          * instruction. Therefore, the instruction id
          * is available now.
          *
          * For each payment in this instruction, store the
          * payment function and org, if unique.
          *
          * This information will be used by the UI in
          * restricting user access.
          */
         deriveDistinctAccessTypsForIns(
             l_instr_id,
             curr_pmt_function,
             curr_org_id,
             curr_org_type,
             l_pmtFxAccessTypesTab,
             l_orgAccessTypesTab
             );

         /*
          * Lastly, before going into the next iteration
          * of the loop copy all the current grouping criteria
          * into 'prev' fields so that we can compare these
          * fields with the next record.
          *
          * No need to copy the current values into the previous ones for
          * the first record because we have already done it at the beginning.
          */
         IF (l_first_record <> 'Y') THEN
             prev_pmt_id               := curr_pmt_id;
             prev_ca_id                := curr_ca_id;
             prev_int_bank_acct_id     := curr_int_bank_acct_id;
             prev_profile_id           := curr_profile_id;
             prev_org_id               := curr_org_id;
             prev_org_type             := curr_org_type;
             prev_pmt_currency         := curr_pmt_currency;
             prev_pmt_amount           := curr_pmt_amount;
             prev_payment_date         := curr_payment_date;
             prev_pmt_function         := curr_pmt_function;
             prev_pmt_reason_code      := curr_pmt_reason_code;
             prev_pmt_reason_commt     := curr_pmt_reason_commt;
             prev_prom_note_flag       := curr_prom_note_flag;
             prev_rfc_identifier       := curr_rfc_identifier;
             prev_ppr_id               := curr_ppr_id;
	     prev_pmt_method_code      := curr_pmt_method_code;
         END IF;

         /*
          *  Remember to reset the first record flag before going
          *  into the next iteration.
          */
         IF (l_first_record = 'Y') THEN
             l_first_record := 'N';
         END IF;

     END LOOP;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Created '
	         || l_pmtInstrTab.COUNT    || ' payment instruction(s) from '
	         || l_pmtsInInstrTab.COUNT || ' payments(s)'
	         );

     END IF;
     /*
      * Initialize the created instructions.
      */
     initializeInstrs(l_pmtInstrTab, p_single_pmt_flow_flag);

     /*
      * Get the mapping between profile ids and system profile codes.
      *
      * Individual payment instructions contain the profile id
      * as an attribute. However, the config tables like
      * pmt instruction creation rules etc. contain settings
      * based on system profile codes.
      *
      * Therefore, we need this mapping for operations that
      * take place below.
      */
     IBY_BUILD_UTILS_PKG.getProfileMap(l_profile_map);

     /* populate the document count associated with each payment */
     populateDocumentCount(l_pmtsInInstrTab);

     /*
      * Payment instruction validations
      */
     performInstructionValidations(l_pmtInstrTab, l_pmtsInInstrTab,
         l_docErrorTab, l_errTokenTab);

     /*
      * Payment instructions that require separate remittance advices
      * need to be identified and flagged.
      */
     flagSeparateRemitAdvcPayments(l_pmtInstrTab, l_pmtsInInstrTab,
         l_profile_map);

     /*
      * All payment instructions for this run have been
      * created and stored in a PLSQL table. Now write these
      * payment instructions to the database.
      *
      * Similarly, update the payments table by providing a
      * payment instruction id to each selected payment.
      */
     performDBUpdates(l_pmtInstrTab, l_pmtsInInstrTab, l_docErrorTab,
         l_errTokenTab, l_profile_map, x_return_status);

     /*
      * Insert the distinct payment functions and orgs that
      * were found in the created payment instructions. These
      * will be used for limiting UI access to users.
      */
     insertDistinctAccessTypsForIns(l_pmtFxAccessTypesTab,
         l_orgAccessTypesTab);

     /*
      * Call separate remittance advice flow (F17) for any
      * payment instructions that require separate remittance
      * advice.
      */

     /*
      * Finally, raise business events to inform the calling app
      * if any payment instructions have failed.
      *
      * Note: this should be the last call after database records
      * have been inserted / updated. This is because you cannot
      * 'rollback' a business event once raised.
      */
     raiseBizEvents(l_pmtInstrTab);

     /*
      * Copy back the created payment instructions
      * to the out parameter.
      */
     x_pmtInstrTab := l_pmtInstrTab;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'COUNT x_pmtInstrTab: '
	         || x_pmtInstrTab.COUNT);
	     print_debuginfo(l_module_name, 'COUNT l_pmtInstrTab: '
	         || l_pmtInstrTab.COUNT);

	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END createPaymentInstructions;

/*--------------------------------------------------------------------
 | NAME:
 |     recreatePaymentInstruction
 |
 | PURPOSE:
 |
 |
 | PARAMETERS:
 |     IN
 |     p_instruction_id
 |         ID of payment instruction to be re-created.
 |
 |     OUT
 |     x_return_status
 |         -1 to indicate failure
 |          0 to indicate success
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE recreatePaymentInstruction(
             x_pmtInstrRec       IN OUT NOCOPY IBY_PAY_INSTRUCTIONS_ALL%
                                                   ROWTYPE,
             x_docErrorTab       IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.
                                                   docErrorTabType,
             x_errTokenTab       IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.
                                                   trxnErrTokenTabType,
             x_return_status     IN OUT NOCOPY NUMBER)
 IS

 l_return_status  NUMBER;

 l_doc_seq_flag   BOOLEAN;
 l_pmt_ref_flag   BOOLEAN;

 l_instruction_id IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE;
 l_profile_id     IBY_PAY_INSTRUCTIONS_ALL.payment_profile_id%TYPE;

 /* maps profile ids to system profile codes */
 l_profile_map        IBY_BUILD_UTILS_PKG.profileIdToCodeMapTabType;

 l_sort_options_tab sortOptionsTabType;
 l_sort_pmt_tab     sortedPmtTabType;

 TYPE dyn_sort_payments IS REF CURSOR;
 l_sort_pmts_cursor     dyn_sort_payments;

 l_module_name    VARCHAR2(200) := G_PKG_NAME || '.recreatePaymentInstruction';

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     l_instruction_id := x_pmtInstrRec.payment_instruction_id;

     /*
      * Pick up all validation sets that were:
      * a. Applied on this payment instruction earlier
      * b. Caused this payment instruction to fail
      * c. Have 'do not apply error flag' set to 'N'
      *    (i.e., non-overridden validations)
      *
      * These validations have to be re-applied on the
      * payment instruction.
      */
     reApplyPayInstrValidationSets(x_pmtInstrRec, x_docErrorTab, x_errTokenTab);

     /*
      * Check if document sequence have been assigned for the
      * payments of this payment instruction. If not, we
      * will need to assign document seq numbers for all
      * payments of this payment instruction.
      *
      * Note: Document sequence numbers will either be assigned
      * to all payments of the instruction or to none at all.
      * It is not possible that only some of the payments of this
      * instruction have document sequence numbers and not all.
      *
      * This behavior is by design.
      */
     l_doc_seq_flag := checkIfDocSeqCompleted(l_instruction_id);

     IF (l_doc_seq_flag = FALSE) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Document sequencing yet to '
	             || 'be completed for payment instruction '
	             || l_instruction_id
	             );

         END IF;
     ELSE

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Document sequencing already '
	             || 'completed for payment instruction '
	             || l_instruction_id
	             );

         END IF;
     END IF;

     /*
      * Check if payment references have been assigned for the
      * payments of this payment instruction. If not, we will need
      * to assign payment references now.
      *
      * Note: Payment reference numbers will either be assigned
      * to all payments of the instruction or to none at all.
      * It is not possible that only some of the payments of this
      * instruction have payment reference numbers and not all.
      *
      * This behavior is by design.
      */
     l_pmt_ref_flag := checkIfPmtRefCompleted(l_instruction_id);

     IF (l_pmt_ref_flag = FALSE) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Payment references yet to '
	             || 'be provided for payment instruction '
	             || l_instruction_id
	             );

         END IF;
     ELSE

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Payment references already '
	             || 'provided for payment instruction '
	             || l_instruction_id
	             );

         END IF;
     END IF;

     /*
      * If document sequencing or payment referencing for
      * this payment instruction has not yet taken place,
      * do so now.
      */
     IF (l_doc_seq_flag = FALSE OR l_pmt_ref_flag = FALSE) THEN

         /* get the profile id of this pmt instruction */
         l_profile_id := get_instruction_profile(l_instruction_id);

         /*
          * Pick up the sorting criteria for attached to this profile
          * and put them into a PLSQL table.
          *
          * Our payment instruction will use the sorting criteria
          * from this table.
          */
         retrieveSortOptionForProfile(l_profile_id, l_sort_options_tab);

         IF (l_sort_options_tab.COUNT = 0) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'No sorting options have been '
	                 || 'set up for the profile '
	                 || l_profile_id
	                 || ' linked to payment instruction '
	                 || l_instruction_id
	                 );

             END IF;
         END IF;

         /*
          * Get the mapping between profile ids and system profile codes.
          *
          * We need this mapping for operations that
          * take place below.
          */
         IBY_BUILD_UTILS_PKG.getProfileMap(l_profile_map);

         /*
          * Get the payments of this instruction in sorted
          * order.
          */
         getSortedPmtsForInstr(
             l_instruction_id,
             l_profile_id,
             l_sort_options_tab,
             l_profile_map,
             l_sort_pmt_tab
             );

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Number of payments picked '
	             || 'up for instruction id '
	             || l_instruction_id
	             || ' is '
	             || l_sort_pmt_tab.COUNT
	             );

         END IF;
         /*
          * This should not happen because a payment
          * instruction should contain at least one
          * payment.
          */
         IF (l_sort_pmt_tab.COUNT = 0) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'No payments were '
	                 || 'picked up for payment instruction '
	                 || l_instruction_id
	                 || '. Possible data corruption. Aborting '
	                 || 'program.',
	                 FND_LOG.LEVEL_UNEXPECTED
	                 );

             END IF;
             APP_EXCEPTION.RAISE_EXCEPTION;

         END IF;

         IF (l_doc_seq_flag = FALSE) THEN

             /*
              * Generate document sequence numbers for the
              * payments on this instruction.
              */
             /*
              * Fix for bug 5069407:
              *
              * Document sequencing log commented out.
	      *
              */
             --performDocSequenceNumbering(l_sort_pmt_tab, x_docErrorTab,
                -- x_errTokenTab);

             /*
              * Update the payments table with the generated
              * document sequence numbers.
              */
             updatePmtsWithSeqNum(l_sort_pmt_tab);

         END IF;

         IF (l_pmt_ref_flag = FALSE) THEN

             /*
              * Generate payment reference numbers for the
              * payments on this instruction.
              */
             providePaymentReferences(l_sort_pmt_tab);

             /*
              * Update the payments table with the generated
              * payment reference numbers.
              */
             updatePmtsWithPmtRef(l_sort_pmt_tab);

         END IF;

     END IF;

     x_return_status := 0;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 EXCEPTION
     WHEN OTHERS THEN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Exception occured when '
	         || 're-creating payment instruction id '
	         || l_instruction_id,
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

 END recreatePaymentInstruction;

/*--------------------------------------------------------------------
 | NAME:
 |     insertPmtIntoInstruction
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
 PROCEDURE insertPmtIntoInstruction(
     x_pmtInstrRec         IN OUT NOCOPY IBY_PAY_INSTRUCTIONS_ALL%ROWTYPE,
     x_pmtInstrTab         IN OUT NOCOPY pmtInstrTabType,
     p_newPmtInstrFlag     IN BOOLEAN,
     x_currentPmtInstrId   IN OUT NOCOPY IBY_PAY_INSTRUCTIONS_ALL.
                                             payment_instruction_id%TYPE,
     x_pmtsInPmtInstrTab   IN OUT NOCOPY pmtsInPmtInstrTabType,
     x_pmtsInPmtInstrRec   IN OUT NOCOPY pmtsInPmtInstrRecType,
     x_pmtsInPmtInstrCount IN OUT NOCOPY NUMBER,
     x_instrAmount         IN OUT NOCOPY NUMBER
     )
 IS
 l_module_name  VARCHAR2(200) := G_PKG_NAME || '.insertPmtIntoInstruction';

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     /*
      * GROUPING LOGIC IS IN IF-ELSE BLOCK BELOW:
      *
      * Irrespective of whether this document is part of
      * an existing payment or whether it should be part
      * of a new payment, ensure that the PLSQL payments
      * table is updated with the details of this document
      * within this if-else block.
      *
      * We need to do this each time we enter this procedure
      * because this might well be the last document in
      * in the payment request, and this procedure may
      * not be called again for this payment request. So
      * the PLSQL payments table should always be up-to-date
      * when it exits this procedure.
      */
     IF (p_newPmtInstrFlag = true) THEN

         /*
          * This is a new payment; Get an id for this payment
          */
         getNextPaymentInstructionID(x_currentPmtInstrId);

         /*
          * Create a new payment instruction record using the
          * incoming payment as a constituent, and insert this
          * record into the PLSQL payments table.
          */
         x_pmtInstrRec.payment_instruction_id :=  x_currentPmtInstrId;

         x_pmtsInPmtInstrCount              := 1;
         x_pmtInstrRec.payment_count        := x_pmtsInPmtInstrCount;

         x_instrAmount  :=  x_pmtsInPmtInstrRec.payment_amount;

         x_pmtInstrTab(x_pmtInstrTab.COUNT + 1) := x_pmtInstrRec;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Inserted payment: '
	             || x_pmtsInPmtInstrRec.payment_id || ' into new payment '
	             || 'instruction: '
	             || x_currentPmtInstrId);

         END IF;
         /*
          * Assign the payment instruction id of the new payment
          * instruction to this payment, and insert the payment
          * into the payments array.
          */
         x_pmtsInPmtInstrRec.pay_instr_id := x_pmtInstrRec.
                                                 payment_instruction_id;
         x_pmtsInPmtInstrTab(x_pmtsInPmtInstrTab.COUNT + 1)
             := x_pmtsInPmtInstrRec;

     ELSE

         /*
          * This means we need to add the incoming payment to
          * the current payment instruction.
          */

         /*
          * First check special case: Payments PLSQL table is empty
          *
          * If the PLSQL table for payments is empty, we have to
          * intitialize it by inserting a dummy record. This dummy
          * record will get overwritten below.
          */
         IF (x_pmtInstrTab.COUNT = 0) THEN

             getNextPaymentInstructionID(x_currentPmtInstrId);

             x_pmtInstrRec.payment_instruction_id := x_currentPmtInstrId;

             x_pmtsInPmtInstrCount          := 0;
             x_pmtInstrRec.payment_count    := x_pmtsInPmtInstrCount;

             /*
              * Insert the first record into the table. This
              * is a dummy record.
              */
             x_pmtInstrTab(x_pmtInstrTab.COUNT + 1) := x_pmtInstrRec;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Created a new payment '
	                 || 'instruction: '
	                 || x_currentPmtInstrId);

             END IF;
         END IF;

         /*
          * The incoming payment should be part of the current payment
          * instruction. So add the payment amount to the current payment
          * instruction record and increment the payment count for the
          * current payment instruction record.
          */
         x_pmtInstrRec.payment_instruction_id := x_currentPmtInstrId;

         x_pmtsInPmtInstrCount        := x_pmtsInPmtInstrCount + 1;
         x_pmtInstrRec.payment_count  := x_pmtsInPmtInstrCount;

         x_instrAmount := x_instrAmount + x_pmtsInPmtInstrRec.payment_amount;

         /*-- uncomment for debugging --*/
         /*
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'x_pmtsInPmtInstrCount: '
	             || x_pmtsInPmtInstrCount);

	         print_debuginfo(l_module_name, 'Instruction id: '
	             || x_pmtInstrRec.payment_instruction_id
	             || ', instruction count: '
	             || x_pmtInstrRec.payment_count
	             );
         END IF;
         */
         /*-- end debug --*/

         /*
          * Overwrite the current payment instruction record in the
          * PLSQL payment instructions table with the updated record.
          */
         x_pmtInstrTab(x_pmtInstrTab.COUNT) := x_pmtInstrRec;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Inserted payment: '
	             || x_pmtsInPmtInstrRec.payment_id
	             || ' into existing payment instruction: '
	             || x_currentPmtInstrId);

         END IF;
         /*
          * Assign the instruction id of the current payment
          * instruction to this payment, and insert the payment
          * into the payments array.
          */
         x_pmtsInPmtInstrRec.pay_instr_id := x_pmtInstrRec.
                                                 payment_instruction_id;
         x_pmtsInPmtInstrTab(x_pmtsInPmtInstrTab.COUNT + 1)
             := x_pmtsInPmtInstrRec;

     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END insertPmtIntoInstruction;

/*--------------------------------------------------------------------
 | NAME:
 |     insertPaymentInstructions
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
 PROCEDURE insertPaymentInstructions(
     p_payInstrTab           IN pmtInstrTabType
     )
 IS
 l_module_name VARCHAR2(200) := G_PKG_NAME || '.insertPaymentInstructions';

 TYPE t_payment_instruction_id IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_profile_id IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.payment_profile_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_process_type IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.process_type%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_instruction_status IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_status%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payments_complete_code IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.payments_complete_code%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_gen_sep_remit_advice_flag IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.generate_sep_remit_advice_flag%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_remit_advice_created_flag IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.remittance_advice_created_flag%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_regul_rpt_created_flag IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.regulatory_report_created_flag%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_bill_payable_flag IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.bill_payable_flag%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_legal_entity_id IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.legal_entity_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_count IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.payment_count%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_pos_pay_file_created_flag IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.positive_pay_file_created_flag%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_print_instruction_immed_flag IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.print_instruction_immed_flag%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_transmit_instr_immed_flag IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.transmit_instr_immed_flag%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_created_by IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.created_by%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_creation_date IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.creation_date%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_last_updated_by IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.last_updated_by%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_last_update_date IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.last_update_date%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_last_update_login IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.last_update_login%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_object_version_number IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.object_version_number%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_internal_bank_account_id IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.internal_bank_account_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_pay_admin_assigned_ref_code IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.pay_admin_assigned_ref_code%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_transmission_date IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.transmission_date%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_acknowledgement_date IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.acknowledgement_date%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_comments IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.comments%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_bank_assigned_ref_code IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.bank_assigned_ref_code%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_org_id IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.org_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_org_type IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.org_type%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_date IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.payment_date%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_currency_code IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.payment_currency_code%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_service_request_id IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.payment_service_request_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_function IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.payment_function%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_reason_code IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.payment_reason_code%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_rfc_identifier IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.rfc_identifier%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_pmt_method_code IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.payment_method_code%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_reason_comments IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.payment_reason_comments%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_payment_document_id IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.payment_document_id%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_printer_name IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.printer_name%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute_category IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.attribute_category%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute1 IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.attribute1%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute2 IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.attribute2%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute3 IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.attribute3%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute4 IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.attribute4%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute5 IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.attribute5%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute6 IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.attribute6%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute7 IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.attribute7%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute8 IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.attribute8%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute9 IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.attribute9%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute10 IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.attribute10%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute11 IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.attribute11%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute12 IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.attribute12%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute13 IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.attribute13%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute14 IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.attribute14%TYPE
     INDEX BY BINARY_INTEGER;
 TYPE t_attribute15 IS TABLE OF
     IBY_PAY_INSTRUCTIONS_ALL.attribute15%TYPE
     INDEX BY BINARY_INTEGER;

 l_payment_instruction_id               t_payment_instruction_id;
 l_payment_profile_id                   t_payment_profile_id;
 l_process_type                         t_process_type;
 l_payment_instruction_status           t_payment_instruction_status;
 l_payments_complete_code               t_payments_complete_code;
 l_gen_sep_remit_advice_flag            t_gen_sep_remit_advice_flag;
 l_remit_advice_created_flag            t_remit_advice_created_flag;
 l_regul_rpt_created_flag               t_regul_rpt_created_flag;
 l_bill_payable_flag                    t_bill_payable_flag;
 l_legal_entity_id                      t_legal_entity_id;
 l_payment_count                        t_payment_count;
 l_pos_pay_file_created_flag            t_pos_pay_file_created_flag;
 l_print_instr_immed_flag               t_print_instruction_immed_flag;
 l_transmit_instr_immed_flag            t_transmit_instr_immed_flag;
 l_created_by                           t_created_by;
 l_creation_date                        t_creation_date;
 l_last_updated_by                      t_last_updated_by;
 l_last_update_date                     t_last_update_date;
 l_last_update_login                    t_last_update_login;
 l_object_version_number                t_object_version_number;
 l_internal_bank_account_id             t_internal_bank_account_id;
 l_pay_admin_assigned_ref_code          t_pay_admin_assigned_ref_code;
 l_transmission_date                    t_transmission_date;
 l_acknowledgement_date                 t_acknowledgement_date;
 l_comments                             t_comments;
 l_bank_assigned_ref_code               t_bank_assigned_ref_code;
 l_org_id                               t_org_id;
 l_org_type                             t_org_type;
 l_payment_date                         t_payment_date;
 l_payment_currency_code                t_payment_currency_code;
 l_payment_service_request_id           t_payment_service_request_id;
 l_payment_function                     t_payment_function;
 l_payment_reason_code                  t_payment_reason_code;
 l_rfc_identifier                       t_rfc_identifier;
 l_pmt_method_code			t_pmt_method_code;
 l_payment_reason_comments              t_payment_reason_comments;
 l_payment_document_id                  t_payment_document_id;
 l_printer_name                         t_printer_name;
 l_attribute_category                   t_attribute_category;
 l_attribute1                           t_attribute1;
 l_attribute2                           t_attribute2;
 l_attribute3                           t_attribute3;
 l_attribute4                           t_attribute4;
 l_attribute5                           t_attribute5;
 l_attribute6                           t_attribute6;
 l_attribute7                           t_attribute7;
 l_attribute8                           t_attribute8;
 l_attribute9                           t_attribute9;
 l_attribute10                          t_attribute10;
 l_attribute11                          t_attribute11;
 l_attribute12                          t_attribute12;
 l_attribute13                          t_attribute13;
 l_attribute14                          t_attribute14;
 l_attribute15                          t_attribute15;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     /* Normally, this shouldn't happen */
     IF (p_payInstrTab.COUNT = 0) THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'After grouping, no payment '
	             || 'instructions were found to update '
	             || 'IBY_PAY_INSTRUCTIONS_ALL table.'
	             || ' Possible data corruption issue.');
         END IF;
         RETURN;
     END IF;

     FOR i IN p_payInstrTab.FIRST..p_payInstrTab.LAST LOOP

         l_payment_instruction_id(i)
             := p_payInstrTab(i).payment_instruction_id;
         l_payment_profile_id(i)
             := p_payInstrTab(i).payment_profile_id;
         l_process_type(i)
             := NVL(p_payInstrTab(i).process_type, 'STANDARD');
         l_payment_instruction_status(i)
             := NVL(p_payInstrTab(i).payment_instruction_status, 'CREATED');
         l_payments_complete_code(i)
             := NVL(p_payInstrTab(i).payments_complete_code, 'NO');
         l_gen_sep_remit_advice_flag(i)
             := NVL(p_payInstrTab(i).generate_sep_remit_advice_flag, 'N');
         l_remit_advice_created_flag(i)
             := NVL(p_payInstrTab(i).remittance_advice_created_flag, 'N');
         l_regul_rpt_created_flag(i)
             := NVL(p_payInstrTab(i).regulatory_report_created_flag, 'N');
         l_bill_payable_flag(i)
             := NVL(p_payInstrTab(i).bill_payable_flag, 'N');
         l_legal_entity_id(i)
             := p_payInstrTab(i).legal_entity_id;
         l_payment_count(i)
             := p_payInstrTab(i).payment_count;
         l_pos_pay_file_created_flag(i)
             := NVL(p_payInstrTab(i).positive_pay_file_created_flag, 'N');
         l_print_instr_immed_flag(i)
             := NVL(p_payInstrTab(i).print_instruction_immed_flag, 'N');
         l_transmit_instr_immed_flag(i)
             := NVL(p_payInstrTab(i).transmit_instr_immed_flag, 'N');
         l_created_by(i)
             := NVL(p_payInstrTab(i).created_by, fnd_global.user_id);
         l_creation_date(i)
             := NVL(p_payInstrTab(i).creation_date, sysdate);
         l_last_updated_by(i)
             := NVL(p_payInstrTab(i).last_updated_by, fnd_global.user_id);
         l_last_update_date(i)
             := NVL(p_payInstrTab(i).last_update_date, sysdate);
         l_last_update_login(i)
             := NVL(p_payInstrTab(i).last_update_login, fnd_global.user_id);
         l_object_version_number(i)
             := NVL(p_payInstrTab(i).object_version_number, 1);
         l_internal_bank_account_id(i)
             := p_payInstrTab(i).internal_bank_account_id;
         l_pay_admin_assigned_ref_code(i)
             := p_payInstrTab(i).pay_admin_assigned_ref_code;
         l_transmission_date(i)
             := p_payInstrTab(i).transmission_date;
         l_acknowledgement_date(i)
             := p_payInstrTab(i).acknowledgement_date;
         l_comments(i)
             := p_payInstrTab(i).comments;
         l_bank_assigned_ref_code(i)
             := p_payInstrTab(i).bank_assigned_ref_code;
         l_org_id(i)
             := p_payInstrTab(i).org_id;
         l_org_type(i)
             := p_payInstrTab(i).org_type;
         l_payment_date(i)
             := p_payInstrTab(i).payment_date;
         l_payment_currency_code(i)
             := p_payInstrTab(i).payment_currency_code;
         l_payment_service_request_id(i)
             := p_payInstrTab(i).payment_service_request_id;
         l_payment_function(i)
             := p_payInstrTab(i).payment_function;
         l_payment_reason_code(i)
             := p_payInstrTab(i).payment_reason_code;
         l_rfc_identifier(i)
             := p_payInstrTab(i).rfc_identifier;
	 l_pmt_method_code(i)
	     := p_payInstrTab(i).payment_method_code;
         l_payment_reason_comments(i)
             := p_payInstrTab(i).payment_reason_comments;
         l_payment_document_id(i)
             := p_payInstrTab(i).payment_document_id;
         l_printer_name(i)
             := p_payInstrTab(i).printer_name;
         l_attribute_category(i)
             := p_payInstrTab(i).attribute_category;
         l_attribute1(i)
             := p_payInstrTab(i).attribute1;
         l_attribute2(i)
             := p_payInstrTab(i).attribute2;
         l_attribute3(i)
             := p_payInstrTab(i).attribute3;
         l_attribute4(i)
             := p_payInstrTab(i).attribute4;
         l_attribute5(i)
             := p_payInstrTab(i).attribute5;
         l_attribute6(i)
             := p_payInstrTab(i).attribute6;
         l_attribute7(i)
             := p_payInstrTab(i).attribute7;
         l_attribute8(i)
             := p_payInstrTab(i).attribute8;
         l_attribute9(i)
             := p_payInstrTab(i).attribute9;
         l_attribute10(i)
             := p_payInstrTab(i).attribute10;
         l_attribute11(i)
             := p_payInstrTab(i).attribute11;
         l_attribute12(i)
             := p_payInstrTab(i).attribute12;
         l_attribute13(i)
             := p_payInstrTab(i).attribute13;
         l_attribute14(i)
             := p_payInstrTab(i).attribute14;
         l_attribute15(i)
             := p_payInstrTab(i).attribute15;

     END LOOP;


     FORALL i in p_payInstrTab.FIRST..p_payInstrTab.LAST
         INSERT INTO IBY_PAY_INSTRUCTIONS_ALL
         (
         payment_instruction_id,
         payment_profile_id,
         process_type,
         payment_instruction_status,
         payments_complete_code,
         generate_sep_remit_advice_flag,
         remittance_advice_created_flag,
         regulatory_report_created_flag,
         bill_payable_flag,
         legal_entity_id,
         payment_count,
         positive_pay_file_created_flag,
         print_instruction_immed_flag,
         transmit_instr_immed_flag,
         created_by,
         creation_date,
         last_updated_by,
         last_update_date,
         last_update_login,
         object_version_number,
         internal_bank_account_id,
         pay_admin_assigned_ref_code,
         transmission_date,
         acknowledgement_date,
         comments,
         bank_assigned_ref_code,
         org_id,
         org_type,
         payment_date,
         payment_currency_code,
         payment_service_request_id,
         payment_function,
         payment_reason_code,
         rfc_identifier,
	 payment_method_code,
         payment_reason_comments,
         payment_document_id,
         printer_name,
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
         attribute15
         )
         VALUES
         (
         l_payment_instruction_id(i),
         l_payment_profile_id(i),
         l_process_type(i),
         l_payment_instruction_status(i),
         l_payments_complete_code(i),
         l_gen_sep_remit_advice_flag(i),
         l_remit_advice_created_flag(i),
         l_regul_rpt_created_flag(i),
         l_bill_payable_flag(i),
         l_legal_entity_id(i),
         l_payment_count(i),
         l_pos_pay_file_created_flag(i),
         l_print_instr_immed_flag(i),
         l_transmit_instr_immed_flag(i),
         l_created_by(i),
         l_creation_date(i),
         l_last_updated_by(i),
         l_last_update_date(i),
         l_last_update_login(i),
         l_object_version_number(i),
         l_internal_bank_account_id(i),
         l_pay_admin_assigned_ref_code(i),
         l_transmission_date(i),
         l_acknowledgement_date(i),
         l_comments(i),
         l_bank_assigned_ref_code(i),
         l_org_id(i),
         l_org_type(i),
         l_payment_date(i),
         l_payment_currency_code(i),
         l_payment_service_request_id(i),
         l_payment_function(i),
         l_payment_reason_code(i),
         l_rfc_identifier(i),
	 l_pmt_method_code(i),
         l_payment_reason_comments(i),
         l_payment_document_id(i),
         l_printer_name(i),
         l_attribute_category(i),
         l_attribute1(i),
         l_attribute2(i),
         l_attribute3(i),
         l_attribute4(i),
         l_attribute5(i),
         l_attribute6(i),
         l_attribute7(i),
         l_attribute8(i),
         l_attribute9(i),
         l_attribute10(i),
         l_attribute11(i),
         l_attribute12(i),
         l_attribute13(i),
         l_attribute14(i),
         l_attribute15(i)
         )
         ;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END insertPaymentInstructions;

/*--------------------------------------------------------------------
 | NAME:
 |     updatePaymentInstructions
 |
 | PURPOSE:
 |     Performs an update of all created instructions from PLSQL
 |     table into IBY_PAY_INSTRUCTIONS_ALL table.
 |
 |     The created instructions have already been inserted into
 |     IBY_PAY_INSTRUCTIONS_ALL after grouping (and before validation).
 |     So we only need to update certain fields of the instruction
 |     that have been changed after the grouping was performed.
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
 PROCEDURE updatePaymentInstructions(
     p_payInstrTab   IN pmtInstrTabType
     )
 IS
 l_module_name VARCHAR2(200) := G_PKG_NAME || '.updatePaymentInstructions';

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     /* Normally, this shouldn't happen */
     IF (p_payInstrTab.COUNT = 0) THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'No payment instructions'
	             || ' were found to update IBY_PAY_INSTRUCTIONS_ALL table.');
         END IF;
         RETURN;
     END IF;

     FOR i in p_payInstrTab.FIRST..p_payInstrTab.LAST LOOP

         UPDATE
             IBY_PAY_INSTRUCTIONS_ALL
         SET
             payment_instruction_status     =
                 p_payInstrTab(i).payment_instruction_status,
             generate_sep_remit_advice_flag =
                 p_payInstrTab(i).generate_sep_remit_advice_flag
         WHERE
             payment_instruction_id = p_payInstrTab(i).payment_instruction_id
         ;

     END LOOP;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END updatePaymentInstructions;

/*--------------------------------------------------------------------
 | NAME:
 |     getNextPaymentInstructionID
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
 PROCEDURE getNextPaymentInstructionID(
     x_pmtInstrID IN OUT NOCOPY IBY_PAY_INSTRUCTIONS_ALL.
                                    payment_instruction_id%TYPE
     )
 IS

 BEGIN

     SELECT
         IBY_PAY_INSTRUCTIONS_ALL_S.NEXTVAL
     INTO
         x_pmtInstrID
     FROM
         DUAL
     ;

 END getNextPaymentInstructionID;

/*--------------------------------------------------------------------
 | NAME:
 |     updatePmtsWithInstructionID
 |
 | PURPOSE:
 |
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
 *---------------------------------------------------------------------*/
 PROCEDURE updatePmtsWithInstructionID(
     p_pmtsInPayInstTab  IN pmtsInPmtInstrTabType
     )
 IS
 l_module_name VARCHAR2(200) := G_PKG_NAME || '.updatePmtsWithInstructionID';

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     /* Normally, this should not happen */
     IF (p_pmtsInPayInstTab.COUNT = 0) THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'After grouping, no '
	             || 'payments provided to update '
	             || 'IBY_PAYMENTS_ALL table. Possible data '
	             || 'corruption issue.');
         END IF;
         RETURN;
     END IF;

     /*
      * Update the payments. We cannot use bulk update here
      * because the bulk update syntax does not allow us to
      * reference individual fields of the PL/SQL record.
      *
      * TBD: Is there any way to optimize this update?
      */
     FOR i in p_pmtsInPayInstTab.FIRST..p_pmtsInPayInstTab.LAST LOOP

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Instruction: '
	             || p_pmtsInPayInstTab(i).pay_instr_id || ', payment: '
	             || p_pmtsInPayInstTab(i).payment_id);

         END IF;
         UPDATE
             IBY_PAYMENTS_ALL
         SET
             payment_instruction_id = p_pmtsInPayInstTab(i).pay_instr_id,
             paper_document_number  = p_pmtsInPayInstTab(i).check_number,
             payment_status         = p_pmtsInPayInstTab(i).payment_status,

             /*
              * Fix for bug 5467767:
              *
              * The payer abbreviated agency code and payer
              * federal employer number need to be populated
              * on the payment as these are required by some
              * formats.
              *
              * Populate them here because the functions that
              * retrieve these values need the payment instruction
              * id as an input param.
              */
             payer_abbreviated_agency_code =
                 IBY_FD_EXTRACT_GEN_PVT.
                     Get_Abbreviated_Agency_Code(
                         p_pmtsInPayInstTab(i).pay_instr_id),

             payer_federal_us_employer_id  =
                 IBY_FD_EXTRACT_GEN_PVT.
                     Get_FEIN(
                         p_pmtsInPayInstTab(i).pay_instr_id)

         WHERE
             payment_id = p_pmtsInPayInstTab(i).payment_id
         ;

     END LOOP;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END updatePmtsWithInstructionID;

/*--------------------------------------------------------------------
 | NAME:
 |     getFxAmount
 |
 | PURPOSE:
 |
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
 |     No exception will be raised in this function if the call to
 |     GL API to convert the amount fails; Instead '-1' will be
 |     for the amount. The caller should recognize this and raise
 |     an exception.
 |
 *---------------------------------------------------------------------*/
 FUNCTION getFxAmount(
     p_source_currency   IN VARCHAR2,
     p_target_currency   IN VARCHAR2,
     p_exch_rate_date    IN DATE,
     p_exch_rate_type    IN VARCHAR2,
     p_source_amount     IN NUMBER
     ) RETURN NUMBER

 IS
 l_module_name  VARCHAR2(200)  := G_PKG_NAME || '.getFxAmount';
 l_fx_amount    NUMBER(15);

 BEGIN

    /*
     * Cannot log anywhere within this function because that
     * violates pragma restrict_references!
     */

    l_fx_amount := gl_currency_api.convert_amount(
                       p_source_currency,
                       p_target_currency,
                       p_exch_rate_date,
                       p_exch_rate_type,
                       p_source_amount
                       );

    RETURN l_fx_amount;

    EXCEPTION

        WHEN OTHERS THEN
             /*
              * The GL convert_amount() API enforces pragma
              * restrict_references. So we cannot raise an
              * exception here.
              *
              * Instead log the exception and pass -1 as the
              * amount. The caller should recognize that -1
              * indicates an exception occured.
              */
             l_fx_amount := -1;

             RETURN l_fx_amount;

 END getFxAmount;


/*--------------------------------------------------------------------
|  Name :  createLogicalGroups
|
|  Purpose : To create logical groups in payment instruction (for SEPA)
|
|  Parameters:
|   IN:
|   x_pmtInstrTab -- Table of payment instruction
|
|   OUT:
|   N/A
|
|
|
*-----------------------------------------------------------------------*/
PROCEDURE createLogicalGroups(
x_pmtInstrTab IN pmtInstrTabType
)
IS

l_grouping_mode varchar2(40);
l_payment_profile_code IBY_ACCT_PMT_PROFILES_B.SYSTEM_PROFILE_CODE%TYPE;
select_clause VARCHAR(4000);
into_clause   VARCHAR(4000);
from_clause   VARCHAR(4000);
where_clause  VARCHAR(4000);
order_clause  VARCHAR(4000);


l_payment_instruction_id  IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE;
l_grp_cntr NUMBER;
l_logical_group_reference  IBY_PAYMENTS_ALL.LOGICAL_GROUP_REFERENCE%TYPE;
l_profileRec  IBY_SYS_PMT_PROFILES_B%ROWTYPE;

TYPE type_payment_id IS TABLE OF
     IBY_PAYMENTS_ALL.payment_id%TYPE
     INDEX BY BINARY_INTEGER;
t_payment_id type_payment_id;

TYPE type_logical_group_reference IS TABLE OF
     IBY_PAYMENTS_ALL.logical_group_reference%TYPE
     INDEX BY BINARY_INTEGER;
t_logical_group_reference type_logical_group_reference;

TYPE type_legal_entity_id IS TABLE OF
     iby_payments_all.legal_entity_id%TYPE
     INDEX BY BINARY_INTEGER;
t_legal_entity_id type_legal_entity_id;

TYPE type_payment_currency_code IS TABLE OF
     iby_payments_all.payment_currency_code%TYPE
     INDEX BY BINARY_INTEGER;
t_payment_currency_code type_payment_currency_code;

TYPE type_payment_method_code IS TABLE OF
     iby_payments_all.payment_method_code%TYPE
     INDEX BY BINARY_INTEGER;
t_payment_method_code type_payment_method_code;

TYPE type_payment_date IS TABLE OF
     iby_payments_all.payment_date%TYPE
     INDEX BY BINARY_INTEGER;
t_payment_date type_payment_date;

TYPE type_payment_reason_code IS TABLE OF
     iby_payments_all.payment_reason_code%TYPE
     INDEX BY BINARY_INTEGER;
t_payment_reason_code type_payment_reason_code;

TYPE type_internal_bank_account_id IS TABLE OF
     iby_payments_all.internal_bank_account_id%TYPE
     INDEX BY BINARY_INTEGER;
t_internal_bank_account_id type_internal_bank_account_id;


/* Added as part of SEPA Changes Bug 9437357*/
TYPE type_settlement_priority IS TABLE OF
     iby_payments_all.settlement_priority%TYPE
     INDEX BY BINARY_INTEGER;
t_settlement_priority type_settlement_priority;

TYPE type_payment_function IS TABLE OF
     iby_payments_all.payment_function%TYPE
     INDEX BY BINARY_INTEGER;
t_payment_function type_payment_function;

TYPE type_ext_payee_id IS TABLE OF
     iby_payments_all.ext_payee_id%TYPE
     INDEX BY BINARY_INTEGER;
t_ext_payee_id type_ext_payee_id;

TYPE type_org_id IS TABLE OF
     iby_payments_all.org_id%TYPE
     INDEX BY BINARY_INTEGER;
t_org_id type_org_id;

l_group_by_legal_entity        iby_pmt_logical_grp_rules.group_by_legal_entity%TYPE;
l_group_by_payment_method      iby_pmt_logical_grp_rules.group_by_payment_method%TYPE;
l_group_by_payment_date        iby_pmt_logical_grp_rules.group_by_payment_date%TYPE;
l_group_by_internal_bank_acct  iby_pmt_logical_grp_rules.group_by_internal_bank_account%TYPE;
l_group_by_operating_unit      iby_pmt_logical_grp_rules.group_by_operating_unit%TYPE;

/*Added as part of SEPA Changes Bug 9437357 */
l_group_by_payment_currency    iby_pmt_logical_grp_rules.group_by_payment_currency%TYPE;
l_group_by_settlement_priority iby_pmt_logical_grp_rules.group_by_settlement_priority%TYPE;
l_group_by_payment_function    iby_pmt_logical_grp_rules.group_by_payment_function%TYPE;


l_first_group_by     VARCHAR2(1);

prev_legal_entity_id     iby_payments_all.legal_entity_id%TYPE;
prev_payment_method_code         iby_payments_all.payment_method_code%TYPE;
prev_payment_date                iby_payments_all.payment_date%TYPE;
prev_internal_bank_account_id    iby_payments_all.internal_bank_account_id%TYPE;

/*Added as part of SEPA Changes Bug 9437357 */
prev_payment_currency_code      iby_payments_all.payment_currency_code%TYPE;
prev_settlement_priority iby_payments_all.settlement_priority%TYPE;
prev_payment_function    iby_payments_all.payment_function%TYPE;


prev_ext_payee_id                iby_payments_all.ext_payee_id%TYPE;


l_module_name  VARCHAR2(200)  := G_PKG_NAME || '.createLogicalGroups';

BEGIN

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	  print_debuginfo(l_module_name, 'ENTER');

  END IF;
  FOR i in  x_pmtInstrTab.FIRST ..  x_pmtInstrTab.LAST LOOP

	l_payment_instruction_id := x_pmtInstrTab(i).payment_instruction_id;

        SELECT sysprf.logical_grouping_mode
             , sysprf.system_profile_code
          INTO l_grouping_mode
             , l_payment_profile_code
          FROM IBY_SYS_PMT_PROFILES_B sysprf
             , IBY_ACCT_PMT_PROFILES_B actprf
         WHERE actprf.PAYMENT_PROFILE_ID  = x_pmtInstrTab(i).payment_profile_id
           AND actprf.SYSTEM_PROFILE_CODE = sysprf.system_profile_code;

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo(l_module_name, 'Instruction: '
	             || l_payment_instruction_id || ', Grouping Mode: '
	             || l_grouping_mode);
        END IF;
        IF (l_grouping_mode IS NOT NULL) THEN
	IF l_grouping_mode = 'SNGL' THEN

           SELECT PAYMENT_ID BULK COLLECT
             INTO t_payment_id
             FROM IBY_PAYMENTS_ALL
            WHERE PAYMENT_INSTRUCTION_ID = l_payment_instruction_id;

           FOR j in t_payment_id.FIRST .. t_payment_id.LAST
           LOOP
              t_logical_group_reference(j) := l_payment_instruction_id||'_'||j;
              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	              print_debuginfo(l_module_name, 'payment_id: '
	                   || t_payment_id(j) || ', logical_grp_ref: '
	                   || t_logical_group_reference(j));

              END IF;
           END LOOP;

           FORALL k IN t_payment_id.FIRST .. t_payment_id.LAST
              UPDATE IBY_PAYMENTS_ALL
                 SET LOGICAL_GROUP_REFERENCE = t_logical_group_reference(k)
               WHERE payment_id              = t_payment_id(k) ;

	ELSIF l_grouping_mode = 'GRPD' THEN

	   l_logical_group_reference  := l_payment_instruction_id||'_1';

           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	           print_debuginfo(l_module_name, 'logical_grp_ref: '
	                   || l_logical_group_reference );

           END IF;
	   UPDATE IBY_PAYMENTS_ALL
	      SET logical_group_reference = l_logical_group_reference
	    WHERE payment_instruction_id  = l_payment_instruction_id;

	ELSIF l_grouping_mode = 'MIXD' THEN

	/* bug 8208986 - the previous values are made to hold '' so that the
	 * first payment in an instruction
         * always has a new logical group id
	 */

	   prev_legal_entity_id :='';
	   prev_payment_method_code := '';
	   prev_payment_date :='';
           prev_internal_bank_account_id :='';
           prev_payment_currency_code := '';
           prev_settlement_priority := '';
           prev_payment_function := '';


           SELECT nvl(group_by_legal_entity, 'N'),
                  nvl(group_by_payment_method, 'N'),
                  nvl(group_by_payment_date, 'N'),
                  nvl(group_by_internal_bank_account, 'N'),
                  nvl(group_by_payment_currency, 'N'),
                  nvl(group_by_settlement_priority, 'N'),
                  nvl(group_by_payment_function, 'N')
                 INTO l_group_by_legal_entity,
                  l_group_by_payment_method,
                  l_group_by_payment_date,
                  l_group_by_internal_bank_acct,
                  l_group_by_payment_currency,
                  l_group_by_settlement_priority,
                  l_group_by_payment_function
             FROM IBY_PMT_LOGICAL_GRP_RULES
             WHERE SYSTEM_PROFILE_CODE = l_payment_profile_code;

	   from_clause   :=' FROM IBY_PAYMENTS_ALL';
	   order_clause  := ' ORDER BY ';

           l_first_group_by := 'Y';

           IF l_group_by_legal_entity = 'Y' THEN
              order_clause     := order_clause || ' legal_entity_id';
              l_first_group_by := 'N';
           END IF;


           IF l_group_by_payment_method = 'Y' THEN
              IF l_first_group_by = 'Y' THEN
                 order_clause := order_clause || ' PAYMENT_METHOD_CODE';
                 l_first_group_by := 'N';
              ELSE
                 order_clause := order_clause || ' , PAYMENT_METHOD_CODE';
              END IF;
           END IF;

           IF l_group_by_payment_date = 'Y' THEN
              IF l_first_group_by = 'Y' THEN
                 order_clause := order_clause || ' PAYMENT_DATE';
                 l_first_group_by := 'N';
              ELSE
                 order_clause := order_clause || ' , PAYMENT_DATE';
              END IF;
           END IF;

           IF l_group_by_internal_bank_acct = 'Y' THEN
              IF l_first_group_by = 'Y' THEN
                 order_clause := order_clause || ' INTERNAL_BANK_ACCOUNT_ID';
                 l_first_group_by := 'N';
              ELSE
                 order_clause := order_clause || ' , INTERNAL_BANK_ACCOUNT_ID';
              END IF;
           END IF;

           IF l_group_by_payment_currency = 'Y' THEN
              IF l_first_group_by = 'Y' THEN
                 order_clause := order_clause || ' PAYMENT_CURRENCY_CODE';
                 l_first_group_by := 'N';
              ELSE
                 order_clause := order_clause || ' , PAYMENT_CURRENCY_CODE';
              END IF;
           END IF;

           IF l_group_by_settlement_priority = 'Y' THEN
              IF l_first_group_by = 'Y' THEN
                 order_clause := order_clause || ' SETTLEMENT_PRIORITY';
                 l_first_group_by := 'N';
              ELSE
                 order_clause := order_clause || ' , SETTLEMENT_PRIORITY';
              END IF;
           END IF;

           IF l_group_by_payment_function = 'Y' THEN
              IF l_first_group_by = 'Y' THEN
                 order_clause := order_clause || ' PAYMENT_FUNCTION';
                 l_first_group_by := 'N';
              ELSE
                 order_clause := order_clause || ' , PAYMENT_FUNCTION';
              END IF;
           END IF;

           where_clause := ' WHERE payment_instruction_id = ' || l_payment_instruction_id;

	   select_clause := 'SELECT PAYMENT_ID
                                  , legal_entity_id
                                  , PAYMENT_METHOD_CODE
                                  , PAYMENT_DATE
                                  , INTERNAL_BANK_ACCOUNT_ID
                                  , PAYMENT_CURRENCY_CODE
                                  , SETTLEMENT_PRIORITY
                                  , PAYMENT_FUNCTION'
                                 ;

           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	           print_debuginfo(l_module_name, 'select_clause: '
	                || select_clause);
	           print_debuginfo(l_module_name, 'from_clause: '
	                || from_clause);
	           print_debuginfo(l_module_name, 'where_clause: '
	                || where_clause);
	           print_debuginfo(l_module_name, 'order_clause: '
	                || order_clause);

           END IF;
/*
	   EXECUTE IMMEDIATE select_clause
                          || into_clause
                          || from_clause
                          || where_clause
                          || order_clause;
*/

	   EXECUTE IMMEDIATE select_clause
                          || from_clause
                          || where_clause
                          || order_clause
           BULK COLLECT INTO  t_payment_id
                            , t_legal_entity_id
                            , t_payment_method_code
                            , t_payment_date
                            , t_internal_bank_account_id
                            , t_payment_currency_code
                            , t_settlement_priority
                            , t_payment_function
                            ;

           l_grp_cntr            := 0;

           FOR j in t_payment_id.FIRST .. t_payment_id.LAST
           LOOP

	      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	              print_debuginfo(l_module_name, 'The values for current payment record: t_legal_entity_id:'||t_legal_entity_id(j) ||',t_payment_method_code:'
	              ||t_payment_method_code(j)||',t_payment_date: '||t_payment_date(j)
	              ||',t_internal_bank_account_id: '|| t_internal_bank_account_id(j)
                      ||',t_payment_currency_code: '|| t_payment_currency_code(j)
                      ||',t_settlement_priority: '|| t_settlement_priority(j)
                      ||',t_payment_function: '|| t_payment_function(j)
                      ) ;
                      print_debuginfo(l_module_name, 'The values for previous payment record: prev_legal_entity_id:' || prev_legal_entity_id ||',prev_payment_method_code:'
		      || prev_payment_method_code ||',prev_payment_date:' || prev_payment_date
		      ||',prev_internal_bank_account_id: '|| prev_internal_bank_account_id
                      ||',prev_payment_currency_code: '|| prev_payment_currency_code
                      ||',prev_settlement_priority: '|| prev_settlement_priority
                      ||',prev_payment_function: '|| prev_payment_function) ;
              END IF;

               IF     t_legal_entity_id(j)          = prev_legal_entity_id
	                 AND t_payment_method_code(j)      = prev_payment_method_code
	                 AND t_payment_date(j)             = prev_payment_date
	                 AND t_internal_bank_account_id(j) = prev_internal_bank_account_id
                         AND t_payment_currency_code(j) = prev_payment_currency_code
                         AND t_settlement_priority(j) = prev_settlement_priority
                         AND t_payment_function(j) = prev_payment_function

	              THEN
	                 t_logical_group_reference(j)     := l_logical_group_reference;
                         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                     print_debuginfo(l_module_name, 'The prev and current payment have same values for grouping attributes. payment_id: '
	                       || t_payment_id(j) || ', logical_grp_ref: '
	                       || t_logical_group_reference(j));
                       END IF;
              ELSE
                 prev_legal_entity_id     := t_legal_entity_id(j);
                 prev_payment_method_code         := t_payment_method_code(j);
                 prev_payment_date                := t_payment_date(j);
                 prev_internal_bank_account_id    := t_internal_bank_account_id(j);
                 prev_payment_currency_code       := t_payment_currency_code(j);
                 prev_settlement_priority         := t_settlement_priority(j);
                 prev_payment_function            := t_payment_function(j);
                 l_grp_cntr                       := l_grp_cntr + 1;
                 l_logical_group_reference        := l_payment_instruction_id ||'_'|| l_grp_cntr;
                 t_logical_group_reference(j)     := l_logical_group_reference;
                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, ' The prev and current payment have different values for grouping attributes. payment_id: '
	                   || t_payment_id(j) || ', logical_grp_ref: '
	                   || t_logical_group_reference(j));

                 END IF;
              END IF;
           END LOOP;

           FORALL j IN t_payment_id.FIRST .. t_payment_id.LAST
	      UPDATE IBY_PAYMENTS_ALL
                 SET logical_group_reference =  t_logical_group_reference(j)
               WHERE payment_id  = t_payment_id(j);

	END IF;
      END IF;
  END LOOP;

END createLogicalGroups;


/*--------------------------------------------------------------------
 | NAME:
 |     performInstructionValidations
 |
 | PURPOSE:
 |
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
 *---------------------------------------------------------------------*/
 PROCEDURE performInstructionValidations(
     x_pmtInstrTab           IN OUT NOCOPY pmtInstrTabType,
     x_pmtsInPmtInstrTab     IN OUT NOCOPY pmtsInPmtInstrTabType,
     x_docErrorTab           IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.
                                               docErrorTabType,
     x_errTokenTab           IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.
                                               trxnErrTokenTabType
     )
 IS

 l_module_name VARCHAR2(200) := G_PKG_NAME || '.performInstructionValidations';

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     /*--- uncomment for debugging ----*/
     /*
     FOR i in x_pmtInstrTab.FIRST..x_pmtInstrTab.LAST LOOP
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Instruction id: '
	             || x_pmtInstrTab(i).instruction_id
	             || ', payment count: '
	             || x_pmtInstrTab(i).payment_count
	             );
         END IF;
     END LOOP;
     */
     /*--- end debug ----*/

     insertPaymentInstructions(x_pmtInstrTab);

     updatePmtsWithInstructionID(x_pmtsInPmtInstrTab);

     applyPayInstrValidationSets(x_pmtInstrTab, x_docErrorTab, x_errTokenTab);

     /*------ This procedure creates logical groups under each payment instruction- SEPA --------*/
     createLogicalGroups(x_pmtInstrTab);

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END performInstructionValidations;


/*--------------------------------------------------------------------
 | NAME:
 |     performDBUpdates
 |
 | PURPOSE:
 |
 |
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
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE performDBUpdates(
     x_pmtInstrTab       IN OUT NOCOPY pmtInstrTabType,
     x_pmtsInPmtInstrTab IN OUT NOCOPY pmtsInPmtInstrTabType,
     x_docErrorTab       IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
     x_errTokenTab       IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.
                                           trxnErrTokenTabType,
     p_profileMap        IN IBY_BUILD_UTILS_PKG.profileIdToCodeMapTabType,
     x_return_status     IN OUT NOCOPY VARCHAR2
     )
 IS
 l_module_name      VARCHAR2(200)  := G_PKG_NAME || '.performDBUpdates';
 l_sorted_pmts_tab  sortedPmtTabType;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     /*
      * Update the payments table by providing a instruction id to
      * each payment.
      */
     updatePmtsWithInstructionID(x_pmtsInPmtInstrTab);

     /*
      * Get the payments for each payment instruction in sorted
      * order. This method will also assign payment references to
      * the sorted payments.
      */
     performSortedPaymentNumbering(x_pmtInstrTab, l_sorted_pmts_tab,
         p_profileMap, x_docErrorTab, x_errTokenTab);

     /*
      * Update individual payments with their document sequence numbers
      * and payment references.
      */
     updatePmtsWithSeqNumPmtRef(l_sorted_pmts_tab);

     /*
      * All payment instructions for this run have been
      * created and stored in a PLSQL table. These instructions
      * have already been written into the IBY_PAY_INSTRUCTIONS_ALL
      * table just before validations. Now update these
      * payment instructions with any additional information.
      *
      * E.g., the payment instruction could have been failed because
      * the document sequencing API call failed. Therefore, the
      * payment instruction status needs to be updated.
      */
     updatePaymentInstructions(x_pmtInstrTab);

     /*
      * If any payment instructions/payments were failed, the
      * IBY_TRANSACTION_ERRORS table must be populated with the
      * corresponding error messages.
      */
     IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N', x_docErrorTab,
         x_errTokenTab);

     /* Pass back the return status to the caller */
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 EXCEPTION

     WHEN OTHERS THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Fatal: Exception when updating '
	             || 'payment instruction/payment status after payment '
	             || 'instruction creation. All changes will be rolled back.',
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
 |     applyPayInstrValidationSets
 |
 | PURPOSE:
 |
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
 *---------------------------------------------------------------------*/
 PROCEDURE applyPayInstrValidationSets(
     x_pmtInstrTab   IN OUT NOCOPY pmtInstrTabType,
     x_docErrorTab   IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
     x_errTokenTab   IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.trxnErrTokenTabType
     )
 IS

 l_module_name   VARCHAR2(200) := G_PKG_NAME || '.applyPayInstrValidationSets';
 l_valSetsTab    instructionValSetsTab;
 l_stmt          VARCHAR2(200);
 l_result        NUMBER := 0;

 l_doc_err_rec   IBY_TRANSACTION_ERRORS%ROWTYPE;
 l_error_code    VARCHAR2(100);
 l_error_msg     VARCHAR2(500);

 /*
  * Pick up all validation sets applicable to a particular instruction.
  */

 /*
  * Fix for bug 5041372:
  *
  * For instructions, the validation level code has been changed
  * from 'INSTRUCTION' to 'DISBURSEMENT_INSTRUCTION'.
  */
 CURSOR  c_instr_val_sets(p_instr_id IBY_PAY_INSTRUCTIONS_ALL.
                                         payment_instruction_id%TYPE)
 IS
 SELECT DISTINCT
     val_asgn.validation_assignment_id,
     val.validation_set_code,
     val.validation_code_package,
     val.validation_code_entry_point
 FROM
     IBY_VALIDATION_SETS_VL    val,
     IBY_VAL_ASSIGNMENTS       val_asgn,
     IBY_PAY_INSTRUCTIONS_ALL  pmt_instr,
     IBY_PAYMENT_PROFILES      prof,
     IBY_TRANSMIT_CONFIGS_VL   txconf,
     IBY_TRANSMIT_PROTOCOLS_VL txproto,
     IBY_PAYMENTS_SEC_V pmt
 WHERE
     pmt_instr.payment_instruction_id = p_instr_id
     AND pmt.payment_instruction_id = pmt_instr.payment_instruction_id
     AND val.validation_set_code   = val_asgn.validation_set_code
     AND val.validation_level_code = 'DISBURSEMENT_INSTRUCTION'
     AND (val_asgn.val_assignment_entity_type = 'INTBANKACCOUNT'
              AND val_asgn.assignment_entity_id  =
                  pmt_instr.internal_bank_account_id
          OR val_asgn.val_assignment_entity_type = 'FORMAT'
              AND val_asgn.assignment_entity_id  =
                  prof.payment_format_code
          OR val_asgn.val_assignment_entity_type = 'BANK'
              AND val_asgn.assignment_entity_id  =
                  prof.bepid
          OR val_asgn.val_assignment_entity_type = 'TRANSPROTOCOL'
              AND val_asgn.assignment_entity_id  =
                  txconf.transmit_protocol_code
          OR val_asgn.val_assignment_entity_type = 'METHOD'
              AND val_asgn.assignment_entity_id  =
                  pmt.payment_method_code
          )
     AND pmt_instr.payment_profile_id   = prof.payment_profile_id(+)
     AND prof.transmit_configuration_id = txconf.transmit_configuration_id(+)
     AND txconf.transmit_protocol_code  = txproto.transmit_protocol_code(+)
     AND NVL(val_asgn.inactive_date, sysdate+1) > sysdate
     ;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

	     print_debuginfo(l_module_name, 'Fresh validation scenario. '
	         || 'All applicable validations will be applied.'
	         );

     END IF;
     FOR i in  x_pmtInstrTab.FIRST ..  x_pmtInstrTab.LAST LOOP

         /*
          * Pick up the validation sets applicable to each
          * instruction.
          */
         OPEN  c_instr_val_sets(x_pmtInstrTab(i).payment_instruction_id);
         FETCH c_instr_val_sets BULK COLLECT INTO l_valSetsTab;
         CLOSE c_instr_val_sets;

         IF (l_valSetsTab.COUNT = 0) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'No validation sets were '
	                 || 'linked to instruction '
	                 || x_pmtInstrTab(i).payment_instruction_id
	                 || '. Skipping instruction '
	                 || 'validations for this instruction ..');

	             print_debuginfo(l_module_name, '+-------------------------+');

             END IF;
         ELSE

             /*
              * Invoke the validation sets applicable to this
              * payment instruction one-by-one.
              */
             executeValidationsForInstr(
                 x_pmtInstrTab(i),
                 l_valSetsTab,
                 FALSE,
                 x_docErrorTab,
                 x_errTokenTab
                 );

         END IF; -- if count of val sets <> 0

     END LOOP; -- for each payment instruction in request

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END applyPayInstrValidationSets;

/*--------------------------------------------------------------------
 | NAME:
 |     reApplyPayInstrValidationSets
 |
 | PURPOSE:
 |
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
 *---------------------------------------------------------------------*/
 PROCEDURE reApplyPayInstrValidationSets(
     x_pmtInstrRec   IN OUT NOCOPY IBY_PAY_INSTRUCTIONS_ALL%ROWTYPE,
     x_docErrorTab   IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
     x_errTokenTab   IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.trxnErrTokenTabType
     )
 IS

 l_module_name   VARCHAR2(200) := G_PKG_NAME ||
                                      '.reApplyPayInstrValidationSets';
 l_valSetsTab    instructionValSetsTab;
 l_stmt          VARCHAR2(200);
 l_result        NUMBER := 0;

 /*
  * Pick up all validation sets applicable to a particular instruction
  * that have not overridden by the payment administrator.
  */
 CURSOR  c_retry_instrvalsets(p_instr_id IBY_PAY_INSTRUCTIONS_ALL.
                                             payment_instruction_id%TYPE)
 IS
 SELECT DISTINCT
     val_asgn.validation_assignment_id,
     val.validation_set_code,
     val.validation_code_package,
     val.validation_code_entry_point
 FROM
     IBY_VALIDATION_SETS_VL    val,
     IBY_VAL_ASSIGNMENTS       val_asgn,
     IBY_PAY_INSTRUCTIONS_ALL  pmt_instr,
     IBY_PAYMENT_PROFILES      prof,
     IBY_TRANSMIT_CONFIGS_VL   txconf,
     IBY_TRANSMIT_PROTOCOLS_VL txproto,
     IBY_TRANSACTION_ERRORS    txerrors
 WHERE
     pmt_instr.payment_instruction_id = p_instr_id
     AND val.validation_set_code   = val_asgn.validation_set_code
     AND val.validation_level_code = 'DISBURSEMENT_INSTRUCTION'
     AND (val_asgn.val_assignment_entity_type = 'INTBANKACCOUNT'
              AND val_asgn.assignment_entity_id  =
                  pmt_instr.internal_bank_account_id
          OR val_asgn.val_assignment_entity_type = 'FORMAT'
              AND val_asgn.assignment_entity_id  =
                  prof.payment_format_code
          OR val_asgn.val_assignment_entity_type = 'BANK'
              AND val_asgn.assignment_entity_id  =
                  prof.bepid
          OR val_asgn.val_assignment_entity_type = 'TRANSPROTOCOL'
              AND val_asgn.assignment_entity_id  =
                  txconf.transmit_protocol_code
          )
     AND pmt_instr.payment_profile_id   = prof.payment_profile_id(+)
     AND prof.transmit_configuration_id = txconf.transmit_configuration_id(+)
     AND txconf.transmit_protocol_code  = txproto.transmit_protocol_code(+)
     AND NVL(val_asgn.inactive_date, sysdate+1) > sysdate
     /*
      * Fix for bug 5206725:
      *
      * The set of conditions below will filter out validation sets
      * that have already been overridden by the user.
      */
     AND txerrors.transaction_type      = 'PAYMENT_INSTRUCTION'
     AND txerrors.transaction_id        = p_instr_id
     AND txerrors.error_type            = 'VALIDATION'
     AND txerrors.validation_set_code   = val.validation_set_code
     AND txerrors.do_not_apply_error_flag = 'N'
     ;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

	     print_debuginfo(l_module_name, 'Validation re-entry scenario. '
	         || 'Only non-overridden validations will be applied.'
	         );

     END IF;
     /*
      * Pick up the validation sets applicable to each
      * instruction.
      */
     OPEN  c_retry_instrvalsets(x_pmtInstrRec.payment_instruction_id);
     FETCH c_retry_instrvalsets BULK COLLECT INTO l_valSetsTab;
     CLOSE c_retry_instrvalsets;

     IF (l_valSetsTab.COUNT = 0) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'No validation sets were '
	             || 'linked to instruction '
	             || x_pmtInstrRec.payment_instruction_id
	             || '. Skipping instruction '
	             || 'validations for this instruction ..');

	         print_debuginfo(l_module_name, '+-------------------------+');

         END IF;
     ELSE

         /*
          * Invoke the validation sets applicable to this
          * payment instruction one-by-one.
          */
         executeValidationsForInstr(
             x_pmtInstrRec,
             l_valSetsTab,
             TRUE,
             x_docErrorTab,
             x_errTokenTab
             );

     END IF; -- if count of val sets <> 0

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'After re-applying validations '
	         || 'error messages count: '
	         || x_docErrorTab.COUNT
	         );

     END IF;
     /*
      * Update the payment instruction status if there
      * were no errors.
      */
     IF (x_docErrorTab.COUNT = 0) THEN

         /*
          * When a payment instruction enters this method,
          * it will be in CREATION_ERROR status. If after validation,
          * we find that no error messages were generated, then
          * we should update the status of this payment instruction
          * to CREATED.
          */
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Error count is zero '
	             || 'indicating that this payment instruction passed '
	             || 'all validations. '
	             || 'Setting instruction status to CREATED.'
	             );

         END IF;
         x_pmtInstrRec.payment_instruction_status := INS_STATUS_CREATED;

     ELSE

         /*
          * We use the error count in the re-validation
          * flow purely to determine whether the payment
          * instruction generated any errors when the
          * validation sets were applied.
          *
          * If we get an error count greater than 0, we know
          * that this pmt instruction generated errors, and we
          * will continue to keep its status as
          * CREATION_ERROR.
          *
          * However, make sure to delete the PLSQL table of
          * errors. These errors were generated by the validation
          * sets and would have already been written into the
          * IBY_TRANSACTION_ERRORS table.
          *
          * If we don't clear out these errors here, the PICP
          * will try to insert these errors again in
          * performDBUpdates(..) and will fail with a unique
          * constraint violation because the errors already
          * exist.
          */
         x_docErrorTab.DELETE;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Cleared out error messages '
	             || 'in memory because these were already stored in the '
	             || 'in the DB.'
	             );

         END IF;
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END reApplyPayInstrValidationSets;

/*--------------------------------------------------------------------
 | NAME:
 |     executeValidationsForInstr
 |
 | PURPOSE:
 |     This method is called to apply validation sets onto
 |     a payment instructions.
 |
 |     This method is called during both fresh validations and
 |     re-validations for a payment instruction.
 |
 |     The p_isReval flag is used To differentiate between these two cases.
 |
 | PARAMETERS:
 |     IN
 |          p_valSetsTab   - list of validation sets applicable to this
 |                           pmt instruction.
 |
 |          p_isReval      - flag indicating whether this is a first
 |                           attempt at validating the pmt instruction, or
 |                           a revalidation.
 |
 |                           TRUE  = Re-validation
 |                           FALSE = Fresh validation
 |
 |     OUT
 |           x_pmtInstrRec - pmt instruction record containing the pmt
 |                           instruction id.
 |
 |           x_docErrorTab -
 |                           List of errors generated by validation sets.
 |                           Only the count of this list is used to
 |                           check if the payment instruction had
 |                           any validation errors. This count checking
 |                           is only performed during re-validation flow.
 |                           This param is not relevant for fresh validations.
 |
 |            x_errTokenTab -
 |                           List of error tokens associated with the
 |                           error messages.
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE executeValidationsForInstr(
     x_pmtInstrRec   IN OUT NOCOPY IBY_PAY_INSTRUCTIONS_ALL%ROWTYPE,
     p_valSetsTab    IN instructionValSetsTab,
     p_isReval       IN BOOLEAN,
     x_docErrorTab   IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
     x_errTokenTab   IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.trxnErrTokenTabType
     )
 IS

 l_module_name   VARCHAR2(200) := G_PKG_NAME || '.executeValidationsForInstr';

 l_stmt          VARCHAR2(200);
 l_result        NUMBER := 0;

 l_doc_err_rec   IBY_TRANSACTION_ERRORS%ROWTYPE;
 l_error_code    VARCHAR2(100);
 l_error_msg     VARCHAR2(500);

 l_count         NUMBER;

 CURSOR c_instr_errors(p_instr_id NUMBER)
 IS
 SELECT
     *
 FROM
     IBY_TRANSACTION_ERRORS
 WHERE
     transaction_id   =  p_instr_id        AND
     transaction_type =  TRXN_TYPE_INSTR   AND
     error_status     <> 'INACTIVE'
     ;

 BEGIN


     /*
      * Fix for bug 5440434:
      *
      * Before doing any validations, set any
      * existing validation error messages that
      * exist against this instruction to 'inactive'
      * status in the IBY_TRANSACTION_ERRORS table.
      *
      * Unless we do this, the old errors will
      * continue to show up against this instruction
      * in the IBY UI even if the instruction is validated
      * successfully this time round.
      */

     /*
      * Only inactivate old errors if we are doing
      * re-validation. In a fresh validation scenario,
      * there are no existing errors to inactivate.
      */
     IF (p_isReval = TRUE) THEN

       --  IBY_BUILD_UTILS_PKG.inactivateOldErrors(
       --      x_pmtInstrRec.payment_instruction_id,
       --      TRXN_TYPE_INSTR
       --     );

       IBY_BUILD_UTILS_PKG.resetPaymentInstructionErrors(x_pmtInstrRec.payment_instruction_id);

     END IF;

     FOR j in p_valSetsTab.FIRST .. p_valSetsTab.LAST LOOP

         /*
          * Dynamically call the validation set applicable
          * to the current payment.
          */
         l_stmt := 'CALL '
                       || p_valSetsTab(j).val_code_package
                       || '.'
                       || p_valSetsTab(j).val_code_entry_pt
                       || '(:1,:2,:3,:4,:5)';

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Executing ' || l_stmt);

         END IF;
         EXECUTE IMMEDIATE (l_stmt) USING
             IN p_valSetsTab(j).val_assign_id,
             IN p_valSetsTab(j).val_set_id,
             IN x_pmtInstrRec.payment_instruction_id,
             IN 'N',
             OUT l_result;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Finished executing '
	             || l_stmt);

	         print_debuginfo(l_module_name, 'Result: '
	             || l_result);

         END IF;
         /*
          * If instruction fails validation, then
          * set the status of the instruction to failed
          * validation.
          */
         IF (l_result <> 0) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Payment instruction '
	                 || x_pmtInstrRec.payment_instruction_id
	                 || ' failed validation by validation set '
	                 || p_valSetsTab(j).val_code_package
	                 || '.'
	                 || p_valSetsTab(j).val_code_entry_pt
	                 );

             END IF;
             x_pmtInstrRec.payment_instruction_status :=
                 INS_STATUS_CREAT_ERROR;

             /*
              * Fix for bug 5206701:
              *
              * No need to insert an error message here.
              * The payment instruction validation set
              * would have already inserted an error message
              * when it applied the validation on the
              * payment instruction.
              */

         END IF; -- result <> 0

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, '+-------------------------+');

         END IF;
     END LOOP; -- for each val set applicable to this instruction

     /*
      * Fix for bug 5482490:
      *
      * Fetch all active error messages stored in
      * IBY_TRANSACTION_ERRORS for this payment instruction.
      *
      * The count of these error messages is used to determine
      * whether the payment instruction is valid or not.
      */

     /*
      * Fix for bug 5515376:
      *
      * Only pick up the errors list if we are doing
      * a re-validation.
      *
      * In a fresh validations scenario, the errors list is
      * not used and should not be populated. If populated,
      * the PICP will use this errors list to insert into the
      * transaction errors table and will run into a primary
      * key violation error.
      */
     IF (p_isReval = TRUE) THEN

         OPEN  c_instr_errors(x_pmtInstrRec.payment_instruction_id);
         FETCH c_instr_errors BULK COLLECT INTO x_docErrorTab;
         CLOSE c_instr_errors;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, '# error messages generated by '
	             || 'validation sets for pmt instruction '
	             || x_pmtInstrRec.payment_instruction_id
	             || ': '
	             || x_docErrorTab.COUNT
	             );

         END IF;
     END IF;

 END executeValidationsForInstr;

/*--------------------------------------------------------------------
 | NAME:
 |     raiseBizEvents
 |
 | PURPOSE:
 |
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
 *---------------------------------------------------------------------*/
 PROCEDURE raiseBizEvents(
     x_pmtInstrTab        IN OUT NOCOPY pmtInstrTabType
     )
 IS

 l_module_name VARCHAR2(200) := G_PKG_NAME || '.raiseBizEvents';
 l_xml_clob         CLOB;
 l_rejection_level  VARCHAR2(200);
 l_event_name       VARCHAR2(200);
 l_event_key        NUMBER;
 l_param_names      JTF_VARCHAR2_TABLE_300;
 l_param_vals       JTF_VARCHAR2_TABLE_300;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

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
     SELECT
         IBY_EVENT_KEY_S.NEXTVAL
     INTO
         l_event_key
     FROM
         DUAL
     ;

     /*
      * Raise a business event with the list of failed
      * payment instructions. This business event should
      * trigger a workflow in the calling app to allow user
      * to review and modify these payment instructions.
      */
     l_event_name :=
         'oracle.apps.iby.instructionprogram.validation'
             || '.notify_instruction_failure';

     /*
      * All payment instructions that are not in 'created' status
      * are failed instructions. Raise a business event for any
      * such failed instruction [to inform the payment administrator
      * to review the error in the Creation Failure Handling Flow (F9)
      * and to take corrective action].
      *
      * Only negative business events are raised; If all payment
      * instructions are in 'created' status, no business event
      * will be raised.
      */

     FOR i IN x_pmtInstrTab.FIRST .. x_pmtInstrTab.LAST  LOOP

         IF (x_pmtInstrTab(i).payment_instruction_status <>
             INS_STATUS_CREATED) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Raising biz event '
	                 || l_event_name
	                 || ' for pay instruction '
	                 || x_pmtInstrTab(i).payment_instruction_id);

             END IF;
             l_xml_clob := getXMLClob(x_pmtInstrTab(i).payment_instruction_id,
                               INS_STATUS_CREATED);

             IF (l_xml_clob IS NULL) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Data inconsistency: '
	                     || 'Failed payment instruction exists in PLSQL '
	                     || 'table, but not database table (though database '
	                     || 'insert has occured). Aborting program ..',
	                     FND_LOG.LEVEL_UNEXPECTED
	                     );

                 END IF;
                 APP_EXCEPTION.RAISE_EXCEPTION;

             ELSE

                 IBY_BUILD_UTILS_PKG.printXMLClob(l_xml_clob);

                 /* No params to pass */
                 l_param_names.EXTEND;
                 l_param_vals.EXTEND;

                 iby_workflow_pvt.raise_biz_event(l_event_name, l_event_key,
                     l_param_names, l_param_vals, l_xml_clob);

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Raised biz event '
	                     || l_event_name || ' with key '
	                     || l_event_key  || '.');

                 END IF;
             END IF; -- if xml clob is null


         ELSE

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Not raising biz event '
	                 || l_event_name
	                 || ' for pay instr '
	                 || x_pmtInstrTab(i).payment_instruction_id
	                 || ' because instruction is valid.'
	                 );

             END IF;
         END IF; -- if instruction status <> 'created'

     END LOOP;

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
 |     getXMLClob
 |
 | PURPOSE:
 |
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
 |     XML generation from PLSQL is evolving rapidly.
 |
 |     The code below uses DBMS_XMLQuery() to generate XML
 |     from a SELECT statement.
 |
 |     DBMS_XMLQuery() uses Java code internally, and is slow.
 |
 |     Better ways to generate XML are:
 |     1. DBMS_XMLGEN
 |        DBMS_XMLGEN is a built-in package in C. It is fast. However,
 |        it is supported only in Oracle 9i and above.
 |
 |     2. SQLX
 |        This is the new emerging standard for SQL -> XML.
 |        It is both fast and easy. However, only Oracle 9i and
 |        above.
 |
 *---------------------------------------------------------------------*/
 FUNCTION getXMLClob(
     p_pay_instruction_id     IN VARCHAR2,
     p_instruction_status     IN VARCHAR2
     )
     RETURN VARCHAR2
 IS
 l_module_name  VARCHAR2(200)  := G_PKG_NAME || '.getXMLClob';
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
      * Note:
      *
      * Replace DBMS_XMLQuery with DBMS_XMLGEN or SQLX
      * when Oracle 9i is minimum requirement in tech
      * stack (see notes above).
      */

     /*
      * Select the given payment instruction from the database;
      * this is a redundant query only used to generate an
      * XML output.
      */

     l_sql := 'SELECT payment_instruction_id '
                  || 'FROM IBY_PAY_INSTRUCTIONS_ALL '
                  || 'WHERE payment_instruction_id = :p_ins_id '
                  || 'AND  payment_instruction_status <> :p_ins_status';

     l_ctx := DBMS_XMLQuery.newContext(l_sql);
     DBMS_XMLQuery.setBindValue(l_ctx, 'p_ins_id', p_pay_instruction_id);
     DBMS_XMLQuery.setBindValue(l_ctx, 'p_ins_status', p_instruction_status);
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
          * It means all payments were successful.
          * return NULL clob to caller.
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
 |     performSortedPaymentNumbering
 |
 | PURPOSE:
 |
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
 PROCEDURE performSortedPaymentNumbering(
     x_pmtInstrTab   IN OUT NOCOPY pmtInstrTabType,
     x_sortedPmtTab  IN OUT NOCOPY sortedPmtTabType,
     p_profileMap    IN IBY_BUILD_UTILS_PKG.profileIdToCodeMapTabType,
     x_docErrorTab   IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
     x_errTokenTab   IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.trxnErrTokenTabType
     )
 IS

 l_module_name VARCHAR2(200) := G_PKG_NAME || '.performSortedPaymentNumbering';

 l_sort_pmt_tab     sortedPmtTabType;

 l_sort_options_rec sortOptionsRecType;
 l_sort_options_tab sortOptionsTabType;

 l_sql_chunk   VARCHAR2(3000);
 l_cursor_stmt VARCHAR2(5000);

 l_order_by    VARCHAR2(200);
 l_sort_option VARCHAR2(2000);

 TYPE dyn_sort_payments IS REF CURSOR;
 l_sort_pmts_cursor     dyn_sort_payments;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     /*
      * Pick up the sorting criteria for all profiles and put
      * them into a PLSQL table.
      *
      * Each payment instruction will use the sorting criteria
      * from this table (record matching its profile id).
      *
      * No need to validate the user provided sorting options
      * as the user will be selecting these from a lookup.
      */
     retrieveSortingOptions(x_pmtInstrTab, l_sort_options_tab);

     IF (l_sort_options_tab.COUNT = 0) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'No sorting options have been '
	             || 'set up for the profiles on any of the created '
	             || 'payment instructions.'
	             );

         END IF;
     END IF;

     /*
      * Loop through all the payment instructions.
      *
      * For each payment instruction:
      * a. Get the payments of the instruction in sorted order.
      * b. Sequence the sorted payments with unique document
      *    sequence numbers.
      * c. Number the sorted payments with unique payment
      *    references.
      */
     FOR i in x_pmtInstrTab.FIRST .. x_pmtInstrTab.LAST LOOP

         /*
          * Perform payment sorting only for payment instructions
          * in 'CREATED' status.
          */
         IF (x_pmtInstrTab(i).payment_instruction_status = 'CREATED') THEN

             getSortedPmtsForInstr(
                 x_pmtInstrTab(i).payment_instruction_id,
                 x_pmtInstrTab(i).payment_profile_id,
                 l_sort_options_tab,
                 p_profileMap,
                 l_sort_pmt_tab
                 );

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Number of payments picked '
	                 || 'up for instruction id '
	                 || x_pmtInstrTab(i).payment_instruction_id
	                 || ' is '
	                 || l_sort_pmt_tab.COUNT
	                 );

             END IF;
             /*
              * This should not happen because a payment
              * instruction should contain at least one
              * payment.
              */
             IF (l_sort_pmt_tab.COUNT = 0) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'No payments were '
	                     || 'picked up for payment instruction '
	                     || x_pmtInstrTab(i).payment_instruction_id
	                     || '. Possible data corruption. Aborting '
	                     || 'program.',
	                     FND_LOG.LEVEL_UNEXPECTED
	                     );

                 END IF;
                 APP_EXCEPTION.RAISE_EXCEPTION;

             END IF;

             /*
              * STEP I:
              * Assign document sequence numbers to the payments of
              * this payment instruction.
              */
             /*
              * Fix for bug 5069407:
              *
              * Document sequencing log commented out.
	      *
              */
             --performDocSequenceNumbering(l_sort_pmt_tab, x_docErrorTab,
                 --x_errTokenTab);

             /*
              * STEP II:
              * Assign payment references to the payments of this
              * payment instruction.
              */
             providePaymentReferences(l_sort_pmt_tab);

             /*
              * Provide list of sorted payments to caller by adding the
              * sorted payments for the current payment instruction into
              * master list of sorted payments.
              */
             IF (l_sort_pmt_tab.COUNT <> 0) THEN

                 FOR sort_index IN l_sort_pmt_tab.FIRST ..
                     l_sort_pmt_tab.LAST LOOP

                     x_sortedPmtTab(x_sortedPmtTab.COUNT + 1) :=
                         l_sort_pmt_tab(sort_index);

                 END LOOP;

             END IF;

             /*
              * If there were any failures during document
              * sequencing or providing references to payments,
              * the corresponding payment instruction would
              * have been marked as failed.
              *
              * Copy back the failed payment instructions
              * into x_pmtInstrTab so that the status of these
              * failed payment instructions can be updated in
              * the database.
              */
             markFailedInstructions(x_pmtInstrTab, l_sort_pmt_tab);

         ELSE

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Payment instruction '
	                 || x_pmtInstrTab(i).payment_instruction_id
	                 || ' is in '
	                 || x_pmtInstrTab(i).payment_instruction_status
	                 || '. Payment reference numbering will not be '
	                 || 'performed for this instruction because it '
	                 || 'is not in *created* status.'
	                 );

             END IF;
         END IF; -- if instr status = 'CREATED'

     END LOOP; -- for each payment instruction

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 EXCEPTION
     WHEN OTHERS THEN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Exception occured when '
	         || 'performing sorted payment numbering for '
	         || 'payment instructions.',
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

 END performSortedPaymentNumbering;

/*--------------------------------------------------------------------
 | NAME:
 |     buildOrderByFromSortOptions
 |
 | PURPOSE:
 |
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
 FUNCTION buildOrderByFromSortOptions(
     x_sortOptionsRec     IN OUT NOCOPY sortOptionsRecType
     )
 RETURN VARCHAR2
 IS

 l_sql_chunk   VARCHAR2(3000) := NULL;

 l_order_by    VARCHAR2(200);
 l_sort_option VARCHAR2(2000);

 l_module_name VARCHAR2(200) := G_PKG_NAME || '.buildOrderByFromSortOptions';

 BEGIN

     /*
      * Build up the ORDER BY clause (of the SQL statement to
      * pick up the available payments) in chunks; add only
      * non-null sorting parameters into the ORDER BY clause.
      *
      * Sort orders are specified as 'ASCENDING' and 'DESCENDING';
      * Convert them to 'ASC' and 'DESC' respectively.
      */
     IF (x_sortOptionsRec.pmt_profile_cd IS NOT NULL) THEN

         /* initialize the sql string */
         l_sql_chunk := '';

         /* Trim any leading or lagging spaces */
         x_sortOptionsRec.sort_option_1 :=
         ltrim(rtrim(x_sortOptionsRec.sort_option_1));
         x_sortOptionsRec.sort_option_2 :=
             ltrim(rtrim(x_sortOptionsRec.sort_option_2));
         x_sortOptionsRec.sort_option_3 :=
                     ltrim(rtrim(x_sortOptionsRec.sort_option_3));

         x_sortOptionsRec.sort_order_1 :=
                     ltrim(rtrim(x_sortOptionsRec.sort_order_1));
         x_sortOptionsRec.sort_order_2 :=
                     ltrim(rtrim(x_sortOptionsRec.sort_order_2));
         x_sortOptionsRec.sort_order_3 :=
                     ltrim(rtrim(x_sortOptionsRec.sort_order_3));

         /*
          * Rename the sort options (if necessary), so that they
          * match the column names of the appropriate tables.
          */
         renameSortOption(x_sortOptionsRec.sort_option_1);
         renameSortOption(x_sortOptionsRec.sort_option_2);
         renameSortOption(x_sortOptionsRec.sort_option_3);

         /*
          * Form SQL statement 'ORDER BY' clause by appending
          * user specified sort options and sort orders.
          */

         /* sort option 1 and sort order 1 */
         IF (x_sortOptionsRec.sort_option_1 IS NOT NULL OR
             x_sortOptionsRec.sort_option_1 <> '') THEN

             l_order_by := '';
             l_sort_option := '';

             /* use sort order only if sort option is provided */
             IF (x_sortOptionsRec.sort_order_1 IS NOT NULL OR
                 x_sortOptionsRec.sort_order_1 <> '') THEN

                 l_order_by := REPLACE(x_sortOptionsRec.
                                  sort_order_1, 'ENDING');

             END IF;

             /*
              * Sorting by payment amount is a special case;
              * It should always be preceded by sorting by
              * payment currency.
              */
             IF (x_sortOptionsRec.sort_option_1 = 'pmt.payment_amount')
                 THEN

                 l_sort_option :=
                     'pmt.payment_currency_code '
                         || l_order_by
                         || ', '
                         || x_sortOptionsRec.sort_option_1;
             ELSE

                 l_sort_option := x_sortOptionsRec.sort_option_1;

             END IF;

                     l_sql_chunk := l_sql_chunk || l_sort_option;
                     l_sql_chunk := l_sql_chunk || ' ' || l_order_by;

         END IF; -- if sort option 1 not null

         /* sort option 2 and sort order 2 */
         IF (x_sortOptionsRec.sort_option_2 IS NOT NULL OR
             x_sortOptionsRec.sort_option_2 <> '') THEN

             l_order_by := '';
             l_sort_option := '';

             /* use sort order only if sort option is provided */
             IF (x_sortOptionsRec.sort_order_2 IS NOT NULL OR
                 x_sortOptionsRec.sort_order_2 <> '') THEN

                 l_order_by := REPLACE(x_sortOptionsRec.
                                   sort_order_2, 'ENDING');

             END IF;

             l_sort_option := x_sortOptionsRec.sort_option_2
                                          || ' ' || l_order_by;

             /*
              * Sorting by payment amount is a special case;
              * It should always be preceded by sorting by
              * payment currency.
              */
             IF (x_sortOptionsRec.sort_option_2 = 'pmt.payment_amount')
                 THEN

                 l_sort_option :=
                     'pmt.payment_currency_code '
                         || l_order_by
                         || ', '
                         || l_sort_option;

             END IF;

             IF (l_sql_chunk IS NULL) THEN

                 l_sql_chunk := l_sort_option;

             ELSE

                 l_sql_chunk := l_sql_chunk || ', ' || l_sort_option;

             END IF;

         END IF;  -- if sort option 2 not null

         /* sort option 3 and sort order 3 */
         IF (x_sortOptionsRec.sort_option_3 IS NOT NULL OR
             x_sortOptionsRec.sort_option_3 <> '') THEN

             l_order_by := '';
             l_sort_option := '';

             /* use sort order only if sort option is provided */
             IF (x_sortOptionsRec.sort_order_3 IS NOT NULL OR
                 x_sortOptionsRec.sort_order_3 <> '') THEN

                 l_order_by := REPLACE(x_sortOptionsRec.
                                   sort_order_3, 'ENDING');

             END IF;

             l_sort_option := x_sortOptionsRec.sort_option_3
                                  || ' ' || l_order_by;

             /*
              * Sorting by payment amount is a special case;
              * It should always be preceded by sorting by
              * payment currency.
              */
             IF (x_sortOptionsRec.sort_option_3 = 'pmt.payment_amount')
                 THEN

                 l_sort_option:=
                     'pmt.payment_currency_code '
                         || l_order_by
                         || ', '
                         || l_sort_option;

             END IF;

             IF (l_sql_chunk IS NULL) THEN

                 l_sql_chunk := l_sort_option;

             ELSE

                 l_sql_chunk := l_sql_chunk || ', ' || l_sort_option;

             END IF;

         END IF;  -- if sort option 3 not null

         IF (l_sql_chunk IS NOT NULL) THEN
             l_sql_chunk := 'ORDER BY ' || l_sql_chunk;
         END IF;

     END IF; -- x_sortOptionsRec.pmt_profile_cd IS NOT NULL

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Formed order by clause : '
	         || l_sql_chunk);

     END IF;
     RETURN l_sql_chunk;

 END buildOrderByFromSortOptions;

/*--------------------------------------------------------------------
 | NAME:
 |     markFailedInstructions
 |
 | PURPOSE:
 |
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
 PROCEDURE markFailedInstructions(
     x_pmtInstrTab        IN OUT NOCOPY pmtInstrTabType,
     p_sortedPmtTab       IN            sortedPmtTabType
     )
 IS
 BEGIN

     IF (p_sortedPmtTab.COUNT = 0 OR x_pmtInstrTab.COUNT = 0) THEN
         RETURN;
     END IF;

     FOR i IN p_sortedPmtTab.FIRST .. p_sortedPmtTab.LAST LOOP

         IF (p_sortedPmtTab(i).instr_status <> INS_STATUS_CREATED)
             THEN

             FOR j in x_pmtInstrTab.FIRST .. x_pmtInstrTab.LAST LOOP

                 IF (x_pmtInstrTab(j).payment_instruction_id =
                     p_sortedPmtTab(i).instr_id) THEN

                     x_pmtInstrTab(j).payment_instruction_status :=
                         p_sortedPmtTab(i).instr_status;

                 END IF;

             END LOOP;

         END IF;

     END LOOP;

 END markFailedInstructions;

/*--------------------------------------------------------------------
 | NAME:
 |     performDocSequenceNumbering
 |
 | PURPOSE:
 |
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
 PROCEDURE performDocSequenceNumbering(
     x_sortedPmtTab  IN OUT NOCOPY sortedPmtTabType,
     x_docErrorTab   IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
     x_errTokenTab   IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.trxnErrTokenTabType
     )
 IS

 l_module_name VARCHAR2(200) := G_PKG_NAME || '.performDocSequenceNumbering';
 l_seq_num     NUMBER(38);

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
         /*
          * STEP I:
          * Get the primary ledger linked to the LE on the
          * payment. The primary ledger id is the same as the
          * set of books id, and it is needed for the document
          * sequencing API.
          */
         getLedgerIdFromLEId(x_sortedPmtTab);

         /*
          * STEP II:
          * Invoke the document sequencing API to assign
          * unique sequence numbers to the individual
          * payments of the instruction.
          */
         assignSequenceNumbers(x_sortedPmtTab, x_docErrorTab, x_errTokenTab);

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END performDocSequenceNumbering;


/*--------------------------------------------------------------------
 | NAME:
 |     getLedgerIdFromLEId
 |
 | PURPOSE:
 |     Returns the id of the primary ledger linked with the given LE.
 |
 |
 | PARAMETERS:
 |     IN
 |     p_le_id - id of the a particular legal entity.
 |
 |     OUT
 |
 |
 | RETURNS:
 |     ledger id - A positive value, if successful
 |                -1, if unsuccessful
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE getLedgerIdFromLEId(
     x_sortedPmtTab       IN OUT NOCOPY sortedPmtTabType
     )

 IS

 l_ret_val     BOOLEAN := FALSE;
 l_ledger_list GL_MC_INFO.ledger_tbl_type := GL_MC_INFO.ledger_tbl_type();
 l_ledger_id   NUMBER(15);
 l_le_id       IBY_PAY_INSTRUCTIONS_ALL.legal_entity_id%TYPE;

 l_module_name VARCHAR2(200) := G_PKG_NAME || '.getLedgerIdFromLEId';

 BEGIN

     FOR i IN x_sortedPmtTab.FIRST .. x_sortedPmtTab.LAST LOOP

         IF (x_sortedPmtTab(i).doc_cat_code IS NOT NULL) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Payment id '
	                 || x_sortedPmtTab(i).payment_id
	                 || ' has document category code '
	                 || x_sortedPmtTab(i).doc_cat_code
	                 || '. Attempting to get set-of-books id for this pmt.'
	                 );

             END IF;
             BEGIN

                 /*
                  * Initialize ledger list before each iteration.
                  */
                 l_ledger_list := GL_MC_INFO.ledger_tbl_type();

                 l_le_id := x_sortedPmtTab(i).le_id;

                 /*
                  * A given LE can be linked to many types of ledgers:
                  *
                  * a. Primary Ledger      [Only one possible for a given LE]
                  * b. Secondary Ledger    [Many possible for a given LE]
                  * c. ALC Ledger          [Many possible for a given LE]
                  *
                  * Therefore, it is possible to uniquely derive the id
                  * of the primary ledger from the given LE id.
                  */

                 /*
                  * Get the primary ledger id for the given LE.
                  * The ledger id was formerly known as the
                  * set of books id.
                  */
                 l_ret_val := GL_MC_INFO.get_le_ledgers
                                  ( p_legal_entity_id     => l_le_id
                                  , p_get_primary_flag    => 'Y'
                                  , p_get_secondary_flag  => 'N'
                                  , p_get_alc_flag        => 'N'
                                  , x_ledger_list         => l_ledger_list
                                  );

                 /*
                  * Check if return status is a success.
                  * Otherwise raise error.
                  */
                 IF (l_ret_val <> TRUE) THEN

                     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                     print_debuginfo(l_module_name, 'Unable to get primary '
	                         || 'ledger for given legal entity: '
	                         || l_le_id
	                         );

                     END IF;
                     l_ledger_id := -1;

                 ELSIF (l_ledger_list.COUNT = 0) THEN

                     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                     print_debuginfo(l_module_name, 'No primary ledger '
	                         || 'was linked to given legal entity: '
	                         || l_le_id
	                         );

                     END IF;
                     l_ledger_id := -1;

                 ELSE

                     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                     print_debuginfo(l_module_name, 'Ledger count: '
	                         || l_ledger_list.COUNT);

                     END IF;
                    /*
                     * Only one ledger is expected to be returned.
                     */
                    l_ledger_id := l_ledger_list(1).ledger_id;

                    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                    print_debuginfo(l_module_name, 'Got primary ledger id '
	                        || l_ledger_id
	                        || ' for le id '
	                        || l_le_id
	                        );

                    END IF;
                 END IF;

                 /*
                  * If we could not get the ledger id (i.e., set of
                  * books id), we cannot do document sequencing.
                  * Raise an exception.
                  */
                 IF (l_ledger_id = -1) THEN

                     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                     print_debuginfo(l_module_name, 'Primary ledger '
	                         || 'linked to legal entity id '
	                         || l_le_id
	                         || ' was not found. Raising exception ..',
	                         FND_LOG.LEVEL_UNEXPECTED
	                         );

                     END IF;
                     APP_EXCEPTION.RAISE_EXCEPTION;

                 ELSE

                     /* store the retrieved ledger id along with the payment */
                     x_sortedPmtTab(i).ledger_id := l_ledger_id;

                 END IF;

             EXCEPTION
                 WHEN OTHERS THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Exception occured when '
	                     || 'attempting to get primary ledger for payment id '
	                     || x_sortedPmtTab(i).payment_id,
	                     FND_LOG.LEVEL_UNEXPECTED
	                     );

	                 print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE,
	                     FND_LOG.LEVEL_UNEXPECTED);
	                 print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM,
	                     FND_LOG.LEVEL_UNEXPECTED);

                 END IF;
                 /*
                  * If we could not get the ledger id, then payment
                  * document sequencing will fail. There is no point
                  * in proceeding further.
                  */

                 /*
                  * Propogate exception to caller.
                  */
                 RAISE;

             END;

         ELSE

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Payment id '
	                 || x_sortedPmtTab(i).payment_id
	                 || ' has no document category code. Skipping '
	                 || 'call to get set-of-books id.'
	                 );

             END IF;
         END IF;

     END LOOP;

 END getLedgerIdFromLEId;

/*--------------------------------------------------------------------
 | NAME:
 |     assignSequenceNumbers
 |
 | PURPOSE:
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
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE assignSequenceNumbers(
    x_sortedPmtTab  IN OUT NOCOPY sortedPmtTabType,
    x_docErrorTab   IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
    x_errTokenTab   IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.trxnErrTokenTabType
    )

 IS

 l_ret_val         BOOLEAN := FALSE;
 l_seq_return      NUMBER;
 l_sequence_number NUMBER(38) := NULL;
 l_sequence_id     fnd_document_sequences.doc_sequence_id%TYPE;
 v_profVal         VARCHAR2(40);
 l_module_name     VARCHAR2(200) := G_PKG_NAME || '.assignSequenceNumbers';
 l_doc_err_rec     IBY_TRANSACTION_ERRORS%ROWTYPE;
 l_error_code      VARCHAR2(100);
 l_error_msg       VARCHAR2(500);

 BEGIN

     /*
      * Print following profile options for debug purposes:
      * a. 'UNIQUE:SEQ_NUMBERS'
      *    This should be set to 'A' (always used) or 'P'
      *    (partially used) for sequence numbering to work.
      *    E.g., FND_PROFILE.PUT( 'UNIQUE:SEQ_NUMBERS', 'P');
      *
      * b. 'USER_ID'
      *    This should be set to any not null value.
      *    E.g., FND_PROFILE.PUT( 'USER_ID', '1234');
      *
      * These profile options are used by the FND document sequencing
      * API so they must be set.
      */
     FND_PROFILE.GET( 'UNIQUE:SEQ_NUMBERS', v_profVal );
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Profile val for UNIQUE:SEQ_NUMBERS: '
	         || v_profVal);

     END IF;
     IF (v_profVal IS NULL OR (v_profVal <> 'A' AND v_profVal <> 'P')) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Sequential numbering profile '
	             || 'option is not set to A (always used) or P '
	             || '(partially used). Sequence number generation will fail ..'
	             );

         END IF;
     END IF;

     FND_PROFILE.GET( 'USER_ID', v_profVal);
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Profile val for USER_ID: '
	         || v_profVal);


     END IF;
     FOR i IN x_sortedPmtTab.FIRST .. x_sortedPmtTab.LAST LOOP

         IF (x_sortedPmtTab(i).doc_cat_code IS NOT NULL) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Attempting to get doc sequence '
	                 || 'number for payment id '
	                 || x_sortedPmtTab(i).payment_id
	                 || ' with doc cat code '
	                 || x_sortedPmtTab(i).doc_cat_code
	                 );

             END IF;
             BEGIN

             /*
              * Next get sequence number by invoking the AOL FND document
              * sequencing API.
              */
             l_seq_return := FND_SEQNUM.get_seq_val
                              ( app_id    => x_sortedPmtTab(i).ca_id
                              , cat_code  => x_sortedPmtTab(i).doc_cat_code
                              , sob_id    => x_sortedPmtTab(i).ledger_id
                              , met_code  => 'A'
                              , trx_date  => x_sortedPmtTab(i).payment_date
                              , seq_val   => l_sequence_number
                              , docseq_id => l_sequence_id
                              );

             /*
              * Check if return status is a success.
              * Otherwise raise error.
              */
             IF (l_seq_return <> FND_SEQNUM.SEQSUCC OR
                 l_sequence_number IS NULL) THEN

                 APP_EXCEPTION.RAISE_EXCEPTION;

             ELSE

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Sequence number generation '
	                     || 'successful for payment id '
	                     || x_sortedPmtTab(i).payment_id
	                     || ', seq num: '
	                     || l_sequence_number
	                     || ', seq id: '
	                     || l_sequence_id
	                     );

                 END IF;
                 /* Assign the retrieved sequence number to the payment */
                 x_sortedPmtTab(i).sequence_number := l_sequence_number;
                 x_sortedPmtTab(i).sequence_id     := l_sequence_id;

             END IF;

             EXCEPTION
                 WHEN OTHERS THEN

                 /*
                  * If an exception occurs, try to log as much
                  * details of the FND API call as possible.
                  */
                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Exception occured when '
	                     || 'invoking FND doc sequencing API. Parameters passed to '
	                     || 'FND API -  '
	                     || 'application id: '
	                     || x_sortedPmtTab(i).ca_id
	                     || ', document category code: '
	                     || x_sortedPmtTab(i).doc_cat_code
	                     || ', ledger id: '
	                     || x_sortedPmtTab(i).ledger_id
	                     || ', method code: '
	                     || 'A'
	                     || ', payment date: '
	                     || x_sortedPmtTab(i).payment_date,
	                     FND_LOG.LEVEL_UNEXPECTED
	                     );

                 END IF;
                 /*
                  * Propogate the exception.
                  */
                 RAISE;

             END;

         ELSE

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Doc sequence '
	                 || 'number generation skipped for payment id '
	                 || x_sortedPmtTab(i).payment_id
	                 || ' because it contains no doc cat code.'
	                 );

             END IF;
         END IF;

     END LOOP;

 EXCEPTION
     WHEN OTHERS THEN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Exception occured when attempting '
	         || 'to perform document sequencing for payment instructions.',
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

 END assignSequenceNumbers;

/*--------------------------------------------------------------------
 | NAME:
 |     getSortOptionsForProfile
 |
 | PURPOSE:
 |
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
 FUNCTION getSortOptionsForProfile(
     p_sortOptionsTab     IN sortOptionsTabType,
     p_profileMap         IN IBY_BUILD_UTILS_PKG.profileIdToCodeMapTabType,
     p_profile_id         IN IBY_PAY_INSTRUCTIONS_ALL.payment_profile_id%TYPE
     )
 RETURN sortOptionsRecType

 IS
 l_sort_options_rec sortOptionsRecType;
 l_profile_code IBY_PAYMENT_PROFILES.system_profile_code%TYPE;

 l_module_name     VARCHAR2(200) := G_PKG_NAME || '.getSortOptionsForProfile';

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');
	     print_debuginfo(l_module_name, 'Profile id: ' || p_profile_id);

     END IF;
     IF (p_sortOptionsTab.COUNT = 0) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'No sort options have been provided '
	             || '. Returning NULL ..');

	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN NULL;

     END IF;

     /*
      * First match the given profile id to its corresponding
      * system profile code.
      */
     l_profile_code := IBY_BUILD_UTILS_PKG.getProfileCodeFromId(
                           p_profile_id,
                           p_profileMap
                           );

     FOR j IN p_sortOptionsTab.FIRST .. p_sortOptionsTab.LAST LOOP

         /*
          * Get the sort options linked to this
          * system profile code.
          */
         IF (p_sortOptionsTab(j).pmt_profile_cd = l_profile_code) THEN

             l_sort_options_rec := p_sortOptionsTab(j);
             EXIT;

         END IF;

     END LOOP;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
     RETURN l_sort_options_rec;

 END getSortOptionsForProfile;

/*--------------------------------------------------------------------
 | NAME:
 |    renameSortOption
 |
 | PURPOSE:
 |
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
 PROCEDURE renameSortOption(
     x_sortOption     IN OUT NOCOPY VARCHAR2
     )
 IS
 l_module_name VARCHAR2(200) := G_PKG_NAME || '.renameSortOption';
 BEGIN

     IF (x_sortOption IS NULL OR x_sortOption = '') THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Sort option is null. '
	             || 'Exiting ..'
	             );
         END IF;
         RETURN;

     END IF;

     /*
      * Map the user specified sort option to the form
      * <table alias>.<column name>.
      *
      * Table Aliases Table / View
      * ------------- --------------------
      * payee          -> HZ_PARTIES
      * payee_location -> HZ_LOCATIONS
      * payee_bank     -> IBY_EXT_BANK_ACCOUNTS_V
      * pmts           -> IBY_PAYMENTS_ALL
      *
      * These aliased table names are used in
      * query to pick up the sorted payments
      * in getSortedPmtsForInstr().
      */
     CASE x_sortOption

         WHEN 'PAYEE_NAME' THEN
             x_sortOption := 'UPPER(payee.party_name)';

         WHEN 'PAYEE_NUMBER' THEN
             x_sortOption := 'payee.party_number';

         WHEN 'POSTAL_CODE' THEN
             x_sortOption := 'payee_location.postal_code';

         WHEN 'PAYEE_TAXPAYER_ID' THEN
             x_sortOption := 'payee.tax_reference';

         WHEN 'PAYEE_BANK_BRANCH' THEN
             x_sortOption := 'pmt.EXT_BRANCH_NUMBER';

         WHEN 'PAYMENT_AMOUNT' THEN
             x_sortOption := 'pmt.payment_amount';

         WHEN 'PAYMENT_FUNCTION' THEN
             x_sortOption := 'pmt.payment_function';

         WHEN 'PAYMENT_DATE' THEN
             x_sortOption := 'pmt.payment_date';

         WHEN 'PAYER_ORG_ID' THEN
             x_sortOption := 'pmt.org_id';

         ELSE
             /* unknown sort option */
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Unknown sort option '
	                 || ''''
	                 || x_sortOption
	                 || ''''
	                 || ' provided. This could cause SQL exception '
	                 || 'when retrieving payments.'
	                 );

             END IF;
     END CASE;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Sort option mapped to '
	         || ''''
	         || x_sortOption
	         || ''''
	         || '.'
	         );

     END IF;
 END renameSortOption;

/*--------------------------------------------------------------------
 | NAME:
 |    providePaymentReferences
 |
 | PURPOSE:
 |
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
 |     This procedure is implemented as an autonomus transaction
 |     in order to serialize access to the payment references table.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE providePaymentReferences(
     x_sortPmtsTab    IN OUT NOCOPY sortedPmtTabType
     )
 IS
 PRAGMA AUTONOMOUS_TRANSACTION;

 l_sorted_pmts_count  NUMBER := 0;
 l_last_used_ref_num  NUMBER := 0;
 l_anticipated_last_ref_num  NUMBER := 0;

 l_module_name       VARCHAR2(200) := G_PKG_NAME
                                          || '.providePaymentReferences';
 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     l_sorted_pmts_count := x_sortPmtsTab.COUNT;

     IF (l_sorted_pmts_count = 0) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Number of sorted payments '
	             || 'provided is zero. Exiting ..'
	             );

         END IF;
         RETURN;

     END IF;

     BEGIN

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
	                  || '. Cannot continue. Aborting ..',
	                  FND_LOG.LEVEL_UNEXPECTED
	                  );

              END IF;
              APP_EXCEPTION.RAISE_EXCEPTION;

          END IF;

         /*
          * Check if we have sufficient payment reference numbers
          * to perform the numbering.
          */
         l_anticipated_last_ref_num := l_last_used_ref_num +
                                           l_sorted_pmts_count;

         /*
          * If we have sufficient number of payment references, update
          * the last used ref number and commit. So that other
          * concurrent instances, now get the updated last
          * used ref number.
          */
         UPDATE
             IBY_PAYMENT_REFERENCES
         SET
             last_used_ref_number = l_anticipated_last_ref_num
         ;

         /*
          * Use the retrieved payment references to number
          * the sorted payments one-by-one.
          */
         FOR i IN x_sortPmtsTab.FIRST .. x_sortPmtsTab.LAST LOOP

             l_last_used_ref_num := l_last_used_ref_num + 1;
             x_sortPmtsTab(i).payment_ref := l_last_used_ref_num;

         END LOOP;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Finished assigning payment '
	             || 'references to '
	             || x_sortPmtsTab.COUNT
	             || ' payment(s).'
	             );

	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         /*
          * End the autonomous transaction.
          */
         COMMIT;

     EXCEPTION
         WHEN OTHERS THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Exception occured when '
	             || 'providing payment references'
	             );
	         print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	         print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);

         END IF;
         /*
          * We either provide payment references to all the sorted
          * payments or to none at all.
          *
          * If we failed to provide payment references to any payment,
          * mark the corresponding payment instructions as failed.
          */
         FOR i IN x_sortPmtsTab.FIRST .. x_sortPmtsTab.LAST LOOP

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Setting parent payment '
	                 || 'instruction '
	                 || x_sortPmtsTab(i).instr_id
	                 || 'of payment '
	                 || x_sortPmtsTab(i).payment_id
	                 || ' to failed status because payment references '
	                 || 'could not be provided.'
	                 );

             END IF;
             /* just to be sure, initialize the pmt ref to an invalid value */
             x_sortPmtsTab(i).payment_ref  := -1;
             x_sortPmtsTab(i).instr_status := INS_STATUS_CREAT_ERROR;

         END LOOP;

         /*
          * End autonomous transaction.
          */
         ROLLBACK;

     END;

 END providePaymentReferences;

/*--------------------------------------------------------------------
 | NAME:
 |     populateDocumentCount
 |
 | PURPOSE:
 |
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
 *---------------------------------------------------------------------*/
 PROCEDURE populateDocumentCount(
     x_pmtsInPmtInstrTab  IN OUT NOCOPY pmtsInPmtInstrTabType
     )
 IS

 l_module_name VARCHAR2(200) := G_PKG_NAME || '.populateDocumentCount';
 l_docs_in_pmt_count docsInPmtCountTabType;

 CURSOR c_document_count(l_pmt_id iby_payments_all.payment_id%type)
 IS
 SELECT
      count(payment_id)
 FROM
     IBY_DOCS_PAYABLE_ALL
 WHERE
     document_status = DOC_STATUS_PAY_CREATED
 AND
     payment_id = l_pmt_id
 ;

 BEGIN

    /* OPEN  c_document_count;
     FETCH c_document_count BULK COLLECT INTO l_docs_in_pmt_count;
     CLOSE c_document_count;
     */

     FOR i in x_pmtsInPmtInstrTab.FIRST .. x_pmtsInPmtInstrTab.LAST LOOP

        OPEN  c_document_count(x_pmtsInPmtInstrTab(i).payment_id);
        FETCH c_document_count INTO x_pmtsInPmtInstrTab(i).document_count;
 	CLOSE c_document_count;

     END LOOP;

 END populateDocumentCount;

/*--------------------------------------------------------------------
 | NAME:
 |     flagSeparateRemitAdvcPayments
 |
 | PURPOSE:
 |
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
 PROCEDURE flagSeparateRemitAdvcPayments(
     x_pmtInstrTab       IN OUT NOCOPY pmtInstrTabType,
     x_pmtsInPmtInstrTab IN OUT NOCOPY pmtsInPmtInstrTabType,
     p_profileMap        IN IBY_BUILD_UTILS_PKG.profileIdToCodeMapTabType
     )
 IS

 l_docs_limit            NUMBER(15);
 l_pmt_details_len_limit NUMBER(15);
 l_module_name           VARCHAR2(200) := G_PKG_NAME
                             || '.flagSeparateRemitAdvcPayments';
 l_profile_code          IBY_PAYMENT_PROFILES.system_profile_code%TYPE;
 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     FOR i in x_pmtsInPmtInstrTab.FIRST .. x_pmtsInPmtInstrTab.LAST LOOP

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Payment id: '
	             || x_pmtsInPmtInstrTab(i).payment_id
	             || ', profile id: '
	             || x_pmtsInPmtInstrTab(i).profile_id
	             || ', pmt details length: '
	             || x_pmtsInPmtInstrTab(i).pmt_details_len
	             );

         END IF;
         BEGIN

             /*
              * Get the system profile code from the profile id.
              */
             l_profile_code := IBY_BUILD_UTILS_PKG.getProfileCodeFromId(
                                   x_pmtsInPmtInstrTab(i).profile_id,
                                   p_profileMap
                                   );

 	     /* pick only those records that have a
		format attached.
	     */

	     SELECT
                 NVL(document_count_limit, -1),
                 NVL(payment_details_length_limit, -1)
             INTO
                 l_docs_limit,
                 l_pmt_details_len_limit
             FROM
                 IBY_REMIT_ADVICE_SETUP
             WHERE
                 system_profile_code = l_profile_code
		AND remittance_advice_format_code IS NOT NULL
             ;

         EXCEPTION
             WHEN OTHERS THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Non-fatal: Exception occured '
	                 || 'when attempting to get remit advice setup for '
	                 || 'profile id: '
	                 ||  x_pmtsInPmtInstrTab(i).profile_id
	                 || ' which mapped to system profile code: '
	                 || l_profile_code
	                 );
	             print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	             print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);

	             print_debuginfo(l_module_name, 'Separate remittance advice '
	                 || 'flag will not be set for payments with profile '
	                 ||  x_pmtsInPmtInstrTab(i).profile_id
	                 );

             END IF;
             /*
              * In case of an exception, re-initialize the remit
              * advice parameters.
              */
             l_docs_limit := -1;
             l_pmt_details_len_limit := -1;

             GOTO label_next_payment;
         END;

         /*
          * If we reached here, it means that remittance conditions
          * were setup for this profile.
          */

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Retrieved from remit advice setup - '
	             || 'documents limit: '
	             || l_docs_limit
	             || ', pmt details length limit: '
	             || l_pmt_details_len_limit
	             || ' for profile id '
	             || x_pmtsInPmtInstrTab(i).profile_id
	             );

         END IF;
         /*
          * If user has linked a separate remittance advice for
          * this profile, but has not setup any remittance
          * conditions, it means that the user wants remittance
          * advice to be generated unconditonally for payments
          * with this profile.
          */
         IF (l_docs_limit = -1 AND l_pmt_details_len_limit = -1) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Unconditionally '
	                 || 'setting remit advice flag to '
	                 || ''''
	                 || 'Y'
	                 || ''''
	                 || ' for payment '
	                 || x_pmtsInPmtInstrTab(i).payment_id
	                 || ' with profile id '
	                 || x_pmtsInPmtInstrTab(i).profile_id
	                 );

             END IF;
             x_pmtsInPmtInstrTab(i).separate_remit_advice_flag := 'Y';

         ELSE

             /*
              * Conditional remittance advice creation.
              */

             /* check if docs limit has been exceeded */
             IF (l_docs_limit <> -1) THEN

                 IF (x_pmtsInPmtInstrTab(i).document_count
                     > l_docs_limit) THEN

                     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                     print_debuginfo(l_module_name, 'Setting '
	                         || 'remit advice flag for payment '
	                         || x_pmtsInPmtInstrTab(i).payment_id
	                         || ' because document count '
	                         || x_pmtsInPmtInstrTab(i).document_count
	                         || ' exceeded document limit '
	                         || l_docs_limit
	                         );

                     END IF;
                     x_pmtsInPmtInstrTab(i).separate_remit_advice_flag := 'Y';

                 END IF;

             END IF;

             /* check if payment details length exceeded */
             IF (l_pmt_details_len_limit <> -1) THEN

                 IF (x_pmtsInPmtInstrTab(i).pmt_details_len
                     > l_pmt_details_len_limit) THEN

                     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                     print_debuginfo(l_module_name, 'Setting '
	                         || 'remit advice flag for payment '
	                         || x_pmtsInPmtInstrTab(i).payment_id
	                         || ' because pmt details length '
	                         || x_pmtsInPmtInstrTab(i).pmt_details_len
	                         || ' exceeded payment details limit '
	                         || l_pmt_details_len_limit
	                         );

                     END IF;
                     x_pmtsInPmtInstrTab(i).separate_remit_advice_flag := 'Y';

                 END IF;

             END IF;

         END IF;

         /*
          * We have just finished processing one payment.
          * If remittance flag is set for payment, set the
          * generate_remit_advice_flag for the corresponding
          * payment instruction.
          *
          * The payment instruction will use this flag to
          * determine whether to call separate remittance advice
          * creation flow (F17) for a payment instruction at the
          * end of the payment instruction creation flow.
          */
         IF (x_pmtsInPmtInstrTab(i).separate_remit_advice_flag = 'Y') THEN
             setRemitFlagForPmtInstruction(
                 x_pmtsInPmtInstrTab(i).pay_instr_id,
                 x_pmtInstrTab
                 );
         END IF;


         <<label_next_payment>>
         NULL; -- null needed because of label

     END LOOP;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END flagSeparateRemitAdvcPayments;

/*--------------------------------------------------------------------
 | NAME:
 |     setRemitFlagForPmtInstruction
 |
 | PURPOSE:
 |
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
 PROCEDURE setRemitFlagForPmtInstruction(
     p_pmtInstrId        IN IBY_PAY_INSTRUCTIONS_ALL.
                                payment_instruction_id%TYPE,
     x_pmtInstrTab       IN OUT NOCOPY pmtInstrTabType
     )
 IS

 BEGIN

     FOR i in x_pmtInstrTab.FIRST .. x_pmtInstrTab.LAST LOOP

         IF (x_pmtInstrTab(i).payment_instruction_id = p_pmtInstrId) THEN
             x_pmtInstrTab(i).generate_sep_remit_advice_flag := 'Y';
         END IF;

     END LOOP;

 END setRemitFlagForPmtInstruction;

/*--------------------------------------------------------------------
 | NAME:
 |     retrieveSortingOptions
 |
 | PURPOSE:
 |
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
 PROCEDURE retrieveSortingOptions(
     p_pmtInstrTab        IN pmtInstrTabType,
     x_sortOptionsTab     IN OUT NOCOPY sortOptionsTabType
     )
 IS

 l_module_name       VARCHAR2(200) := G_PKG_NAME || '.retrieveSortingOptions';

 /*
  * Cursor to pick up all available profiles with their sorting
  * options from the IBY_INSTR_CREATION_RULES table.
  */
 CURSOR c_sorting_options
 IS
 SELECT
     system_profile_code,
     sort_option_1,
     sort_order_1,
     sort_option_2,
     sort_order_2,
     sort_option_3,
     sort_order_3
 FROM
     IBY_INSTR_CREATION_RULES;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     /*
      * Pick up sorting options for all available profiles.
      */
     OPEN  c_sorting_options;
     FETCH c_sorting_options BULK COLLECT INTO x_sortOptionsTab;
     CLOSE c_sorting_options;

     IF (x_sortOptionsTab.COUNT = 0) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'No records were found in '
	             || 'IBY_INSTR_CREATION_RULES. Exiting .. '
	             );

	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END retrieveSortingOptions;

/*--------------------------------------------------------------------
 | NAME:
 |     updatePmtsWithSeqNumPmtRef
 |
 | PURPOSE:
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
 PROCEDURE updatePmtsWithSeqNumPmtRef(
     p_sortedPmtsTab       IN sortedPmtTabType
     )
 IS
 BEGIN

     IF (p_sortedPmtsTab.COUNT = 0) THEN
         RETURN;
     END IF;

     FOR i IN p_sortedPmtsTab.FIRST .. p_sortedPmtsTab.LAST LOOP

         UPDATE
             IBY_PAYMENTS_ALL
         SET
             payment_reference_number = p_sortedPmtsTab(i).payment_ref,
             document_category_code   = p_sortedPmtsTab(i).doc_cat_code,
             document_sequence_id     = p_sortedPmtsTab(i).sequence_id,
             document_sequence_value  = p_sortedPmtsTab(i).sequence_number
         WHERE
             payment_id = p_sortedPmtsTab(i).payment_id
         ;

     END LOOP;

 END updatePmtsWithSeqNumPmtRef;

/*--------------------------------------------------------------------
 | NAME:
 |     updatePmtsWithSeqNum
 |
 | PURPOSE:
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
 PROCEDURE updatePmtsWithSeqNum(
     p_sortedPmtsTab       IN sortedPmtTabType
     )
 IS
 BEGIN

     IF (p_sortedPmtsTab.COUNT = 0) THEN
         RETURN;
     END IF;

     FOR i IN p_sortedPmtsTab.FIRST .. p_sortedPmtsTab.LAST LOOP

         UPDATE
             IBY_PAYMENTS_ALL
         SET
             document_category_code   = p_sortedPmtsTab(i).doc_cat_code,
             document_sequence_id     = p_sortedPmtsTab(i).sequence_id,
             document_sequence_value  = p_sortedPmtsTab(i).sequence_number
         WHERE
             payment_id = p_sortedPmtsTab(i).payment_id
         ;

     END LOOP;

 END updatePmtsWithSeqNum;

/*--------------------------------------------------------------------
 | NAME:
 |     updatePmtsWithPmtRef
 |
 | PURPOSE:
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
 PROCEDURE updatePmtsWithPmtRef(
     p_sortedPmtsTab       IN sortedPmtTabType
     )
 IS
 BEGIN

     IF (p_sortedPmtsTab.COUNT = 0) THEN
         RETURN;
     END IF;

     FOR i IN p_sortedPmtsTab.FIRST .. p_sortedPmtsTab.LAST LOOP

         UPDATE
             IBY_PAYMENTS_ALL
         SET
             payment_reference_number = p_sortedPmtsTab(i).payment_ref
         WHERE
             payment_id = p_sortedPmtsTab(i).payment_id
         ;

     END LOOP;

 END updatePmtsWithPmtRef;

/*--------------------------------------------------------------------
 | NAME:
 |     deriveDistinctAccessTypsForIns
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
 PROCEDURE deriveDistinctAccessTypsForIns(
     p_instruction_id      IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id
                                  %TYPE,
     p_pmt_function        IN IBY_PAYMENTS_ALL.payment_function%TYPE,
     p_org_id              IN IBY_PAYMENTS_ALL.org_id%TYPE,
     p_org_type            IN IBY_PAYMENTS_ALL.org_type%TYPE,
     x_pmtFxAccessTypesTab IN OUT NOCOPY distinctPmtFxAccessTab,
     x_orgAccessTypesTab   IN OUT NOCOPY distinctOrgAccessTab
     )
 IS

 l_pmt_function_found BOOLEAN := FALSE;
 l_org_found          BOOLEAN := FALSE;
 l_index              NUMBER := -1;

 l_module_name        VARCHAR2(200) := G_PKG_NAME ||
                                           '.deriveDistinctAccessTypsForIns';

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     IF (x_pmtFxAccessTypesTab.COUNT <> 0) THEN

         FOR i IN x_pmtFxAccessTypesTab.FIRST .. x_pmtFxAccessTypesTab.LAST LOOP

             /* search for given payment function    */
             /* for the given payment instruction id */

             /*
              * Fix for bug 5331992:
              *
              * Search for the payment functions stored in
              * x_pmtFxAccessTypesTab for the given pmt
              * instruction id (not across all records in
              * in x_pmtFxAccessTypesTab)
              */
             IF (x_pmtFxAccessTypesTab(i).payment_function = p_pmt_function AND
                 x_pmtFxAccessTypesTab(i).object_id        = p_instruction_id)
             THEN

                 l_pmt_function_found := TRUE;

             END IF;

         END LOOP;

     END IF;

     IF (x_orgAccessTypesTab.COUNT <> 0) THEN

         FOR i IN x_orgAccessTypesTab.FIRST .. x_orgAccessTypesTab.LAST LOOP

             /* search for given org                 */
             /* for the given payment instruction id */

             /*
              * Fix for bug 5331992:
              *
              * Search for the orgs stored in
              * x_orgAccessTypesTab for the given pmt
              * instruction id (not across all records in
              * in x_orgAccessTypesTab)
              */
             IF (x_orgAccessTypesTab(i).org_id    = p_org_id   AND
                 x_orgAccessTypesTab(i).org_type  = p_org_type AND
                 x_orgAccessTypesTab(i).object_id = p_instruction_id) THEN

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
	             || ' for payment instruction '
	             || p_instruction_id
	             );

         END IF;
         /*
          * These attributes can be hardcoded.
          */
         x_pmtFxAccessTypesTab(l_index + 1).object_id   := p_instruction_id;
         x_pmtFxAccessTypesTab(l_index + 1).object_type :=
             OBJECT_TYPE_INSTR;

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
	             || ' for payment instruction '
	             || p_instruction_id
	             );

         END IF;
         /*
          * These attributes can be hardcoded.
          */
         x_orgAccessTypesTab(l_index + 1).object_id   := p_instruction_id;
         x_orgAccessTypesTab(l_index + 1).object_type := OBJECT_TYPE_INSTR;

     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END deriveDistinctAccessTypsForIns;

/*--------------------------------------------------------------------
 | NAME:
 |     insertDistinctAccessTypsForIns
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
 PROCEDURE insertDistinctAccessTypsForIns(
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


     FORALL i in p_pmtFxAccessTypesTab.FIRST..p_pmtFxAccessTypesTab.LAST
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

     FORALL j in p_orgAccessTypesTab.FIRST..p_orgAccessTypesTab.LAST
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

 END insertDistinctAccessTypsForIns;

/*--------------------------------------------------------------------
 | NAME:
 |     checkIfDocSeqCompleted
 |
 | PURPOSE:
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
 *---------------------------------------------------------------------*/
 FUNCTION checkIfDocSeqCompleted(
     p_instr_id  IN    IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE
     )
     RETURN BOOLEAN
 IS

 l_ret_val BOOLEAN;
 l_seq_num NUMBER;

 l_module_name VARCHAR2(200) := G_PKG_NAME || '.checkIfDocSeqCompleted';

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');
	     print_debuginfo(l_module_name, 'instr id = ' || p_instr_id);

     END IF;
     /*
      * It is good enough to check one payment for this
      * payment instruction to see if document sequencing
      * has already taken place for this payment instruction.
      *
      * By design, either all the payments of this payment
      * instruction are assigned document sequence numbers
      * or none are.
      */
     SELECT
         document_sequence_value
     INTO
         l_seq_num
     FROM
         IBY_PAYMENTS_ALL
     WHERE
         payment_instruction_id = p_instr_id AND
         ROWNUM                 = 1
     ;

     /*
      * Return appropriate flag.
      */
     IF (l_seq_num IS NULL) THEN

         l_ret_val := FALSE;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning FALSE');

         END IF;
     ELSE

         l_ret_val := TRUE;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning TRUE');

         END IF;
     END IF;

     return l_ret_val;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 EXCEPTION
     WHEN OTHERS THEN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Exception occured when '
	         || 'checking whether document sequencing has been '
	         || 'already completed for payment instruction '
	         || p_instr_id,
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

 END checkIfDocSeqCompleted;

/*--------------------------------------------------------------------
 | NAME:
 |     checkIfPmtRefCompleted
 |
 | PURPOSE:
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
 *---------------------------------------------------------------------*/
 FUNCTION checkIfPmtRefCompleted(
     p_instr_id  IN    IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE
     )
     RETURN BOOLEAN
 IS

 l_ret_val BOOLEAN;
 l_pmt_ref NUMBER;

 l_module_name VARCHAR2(200) := G_PKG_NAME || '.checkIfPmtRefCompleted';

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     /*
      * It is good enough to check one payment for this
      * payment instruction to see if payment referencing
      * has already taken place for this payment instruction.
      *
      * By design, either all the payments of this payment
      * instruction are assigned payment reference numbers
      * or none are.
      */
     SELECT
         payment_reference_number
     INTO
         l_pmt_ref
     FROM
         IBY_PAYMENTS_ALL
     WHERE
         payment_instruction_id = p_instr_id AND
         ROWNUM                 = 1
     ;

     /*
      * Return appropriate flag.
      */
     IF (l_pmt_ref IS NULL) THEN

         l_ret_val := FALSE;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning FALSE');

         END IF;
     ELSE

         l_ret_val := TRUE;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning TRUE');

         END IF;
     END IF;

     return l_ret_val;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END checkIfPmtRefCompleted;

/*--------------------------------------------------------------------
 | NAME:
 |     getSortedPmtsForInstr
 |
 | PURPOSE:
 |
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
 PROCEDURE getSortedPmtsForInstr(
     p_instr_id       IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE,
     p_profile_id     IN IBY_PAY_INSTRUCTIONS_ALL.payment_profile_id%TYPE,
     p_sortOptionsTab IN sortOptionsTabType,
     p_profileMap     IN IBY_BUILD_UTILS_PKG.profileIdToCodeMapTabType,
     x_sortedPmtTab   IN OUT NOCOPY sortedPmtTabType
     )
 IS

 l_sort_options_rec sortOptionsRecType;

 l_sql_chunk   VARCHAR2(3000);
 l_cursor_stmt VARCHAR2(5000);

 TYPE dyn_sort_payments IS REF CURSOR;
 l_sort_pmts_cursor     dyn_sort_payments;

 l_module_name VARCHAR2(200) := G_PKG_NAME || '.getSortedPmtsForInstr';



 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     l_sort_options_rec := getSortOptionsForProfile(
                               p_sortOptionsTab,
                               p_profileMap,
                               p_profile_id
                               );

     IF (l_sort_options_rec.pmt_profile_cd IS NULL) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'No sort options set '
	             || 'up for payment profile '
	             || p_profile_id
	             || '. Payments of payment instruction '
	             || p_instr_id
	             || ' will *not* be sorted before numbering.'
	             );

         END IF;
     ELSE

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Sort options set '
	             || 'up for payment profile '
	             || p_profile_id
	             || '. Payments of payment instruction '
	             || p_instr_id
	             || ' will be sorted before numbering.'
	             );

         END IF;
         l_sql_chunk := buildOrderByFromSortOptions(
                            l_sort_options_rec);

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Formed order by clause: '
	             || l_sql_chunk);

         END IF;
     END IF;

     /*
      * Pick up all payments for this payment instruction
      * after sorting them by the provided sort criteria (if
      * provided).
      *
      * Pad null values in the SELECT statement for the fields
      * that will be filled up later.
      */

/* Perf Bug 5872977 */
     IF l_sql_chunk is NOT NULL THEN

        l_cursor_stmt :=

         'SELECT '
             ||  'pmt.payment_id,                                     '
             ||  'NVL (pmt.payment_reference_number, -1),             '
             ||  'pmt.payment_instruction_id,                         '
             ||  'ins.payment_instruction_status,                     '
             ||  'req.calling_app_id,                                 '
             ||  'pmt.legal_entity_id,                                '
             ||  'pmt_mthds.document_category_code,                   '
             ||  'pmt.payment_date,                                   '
             ||  'NULL, ' /* ledger id */
             ||  'NULL, ' /* sequence number */
             ||  'NULL '  /* sequence id */
         || 'FROM                                                     '
             || 'IBY_PAYMENTS_ALL         pmt,                        '
             || 'IBY_PAY_SERVICE_REQUESTS req,                        '
             || 'IBY_PAYMENT_METHODS_VL   pmt_mthds,                  '
             || 'IBY_PAY_INSTRUCTIONS_ALL ins,                        '
             || 'HZ_PARTIES               payee,                      '
             || 'HZ_LOCATIONS             payee_location,             '
             || 'IBY_EXT_BANK_ACCOUNTS    payee_bank                  ' -- Bug 5872977
         || 'WHERE '
             || '    pmt.payment_instruction_id = :instr_id           '
             || 'AND pmt.payment_status         = :pmt_status         '
             || 'AND pmt.payment_instruction_id =                     '
             || '    ins.payment_instruction_id                       '
             || 'AND pmt.payment_service_request_id =                 '
             || '    req.payment_service_request_id                   '
             || 'AND pmt.payment_method_code =                        '
             || '    pmt_mthds.payment_method_code                    '
             || 'AND pmt.payee_party_id             = payee.party_id  '
             || 'AND pmt.remit_to_location_id       =                 '
             || '    payee_location.location_id(+)                    '
             || 'AND pmt.external_bank_account_id   =                 '
             || '    payee_bank.ext_bank_account_id(+)                '
             || NVL (l_sql_chunk, 'AND 1=1 ')
             ;
     ELSE
        l_cursor_stmt :=

         'SELECT '
             ||  'pmt.payment_id,                                     '
             ||  'NVL (pmt.payment_reference_number, -1),             '
             ||  'pmt.payment_instruction_id,                         '
             ||  'ins.payment_instruction_status,                     '
             ||  'req.calling_app_id,                                 '
             ||  'pmt.legal_entity_id,                                '
             ||  'pmt_mthds.document_category_code,                   '
             ||  'pmt.payment_date,                                   '
             ||  'NULL, ' /* ledger id */
             ||  'NULL, ' /* sequence number */
             ||  'NULL '  /* sequence id */
         || 'FROM                                                     '
             || 'IBY_PAYMENTS_ALL         pmt,                        '
             || 'IBY_PAY_SERVICE_REQUESTS req,                        '
             || 'IBY_PAYMENT_METHODS_VL   pmt_mthds,                  '
             || 'IBY_PAY_INSTRUCTIONS_ALL ins,                        '
             || 'HZ_PARTIES               payee                       '
         || 'WHERE '
             || '    pmt.payment_instruction_id = :instr_id           '
             || 'AND pmt.payment_status         = :pmt_status         '
             || 'AND pmt.payment_instruction_id =                     '
             || '    ins.payment_instruction_id                       '
             || 'AND pmt.payment_service_request_id =                 '
             || '    req.payment_service_request_id                   '
             || 'AND pmt.payment_method_code =                        '
             || '    pmt_mthds.payment_method_code                    '
             || 'AND pmt.payee_party_id             = payee.party_id  '
             ;
     END IF;

/* Perf Bug 5872977 */

     /*
      * Print the cursor statement for debug purposes.
      */
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Dynamic cursor statement: ');
             IBY_BUILD_UTILS_PKG.printWrappedString(l_cursor_stmt);
	     print_debuginfo(l_module_name, 'cursor bind parameters - ');
	     print_debuginfo(l_module_name, ':instr_id      = '
	         || p_instr_id);
	     print_debuginfo(l_module_name, ':pmt_status    = '
	         || PMT_STATUS_INSTR_CREATED);
     END IF;
     OPEN l_sort_pmts_cursor FOR
         l_cursor_stmt
     USING
         p_instr_id,
         PMT_STATUS_INSTR_CREATED
     ;

     FETCH l_sort_pmts_cursor BULK COLLECT INTO x_sortedPmtTab;
     CLOSE l_sort_pmts_cursor;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Number of payments picked '
	         || 'up for instruction id '
	         || p_instr_id
	         || ' is '
	         || x_sortedPmtTab.COUNT
	         );

	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 EXCEPTION
     WHEN OTHERS THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Exception occured when attempting '
	             || 'to get payments in sorted order for payment instruction '
	             || p_instr_id,
	             FND_LOG.LEVEL_UNEXPECTED
	             );

	         print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE,
	             FND_LOG.LEVEL_UNEXPECTED);
	         print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM,
	             FND_LOG.LEVEL_UNEXPECTED);

         END IF;
         /*
          * Propagate exception to caller.
          */
         APP_EXCEPTION.RAISE_EXCEPTION;

 END getSortedPmtsForInstr;

/*--------------------------------------------------------------------
 | NAME:
 |     dummyGLAPI
 |
 | PURPOSE:
 |     Dummy method; to be used for testing purposes.
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
 *---------------------------------------------------------------------*/
 PROCEDURE dummyGLAPI(
     p_exch_date          IN         DATE,
     p_source_amount      IN         NUMBER,
     p_source_curr        IN         VARCHAR2,
     p_decl_curr          IN         VARCHAR2,
     p_decl_fx_rate_type  IN         VARCHAR2,
     x_decl_amount        OUT NOCOPY NUMBER)
 IS

 BEGIN

     x_decl_amount := p_source_amount * 2;

 END dummyGLAPI;

/*--------------------------------------------------------------------
 | NAME:
 |     dummy_ruleFunction
 |
 | PURPOSE:
 |     Dummy method; to be used for testing purposes.
 |     You will need to register this function with an event
 |     subscription for this function to be called.
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
 FUNCTION dummy_ruleFunction(
     p_subscription IN            RAW,
     p_event        IN OUT NOCOPY WF_EVENT_T
     )
     RETURN VARCHAR2
 IS

 l_module_name     VARCHAR2(200)  := G_PKG_NAME || '.dummy_ruleFunction';
 l_parameter_list  wf_parameter_list_t := wf_parameter_list_t();
 l_parameter_t     wf_parameter_t:= wf_parameter_t(NULL, NULL);
 l_parameter_name  l_parameter_t.name%TYPE;
 l_parameter_value l_parameter_t.value%TYPE;
 l_clob            CLOB;
 i                 PLS_INTEGER;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     l_parameter_list := p_event.getParameterList();

     IF (l_parameter_list IS NOT NULL) THEN
         i := l_parameter_list.FIRST;
         WHILE (i <= l_parameter_list.LAST) LOOP
             l_parameter_name  := NULL;
             l_parameter_value := NULL;

             l_parameter_name  := l_parameter_list(i).getName();
             l_parameter_value := l_parameter_list(i).getValue();

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Param Name: '
	                 || l_parameter_name || ', Param Value: '
	                 || l_parameter_value
	                 );

             END IF;
             i := l_parameter_list.NEXT(i);
         END LOOP;
     END IF;

     l_clob := p_event.getEventData();

     IF (l_clob IS NOT NULL) THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Clob is not null');
         END IF;
         IBY_BUILD_UTILS_PKG.printXMLClob(l_clob);
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
     RETURN 'SUCCESS';

 END dummy_ruleFunction;

/*--------------------------------------------------------------------
 | NAME:
 |     get_instruction_profile
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
 FUNCTION get_instruction_profile (
     l_pmt_instr_id IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE)
     RETURN NUMBER
 IS

 l_pmt_instr_profile IBY_PAY_INSTRUCTIONS_ALL.payment_profile_id%TYPE;
 l_module_name       VARCHAR2(200) := G_PKG_NAME || '.get_instruction_profile';

 BEGIN

     SELECT
         payment_profile_id
     INTO
         l_pmt_instr_profile
     FROM
         IBY_PAY_INSTRUCTIONS_ALL
     WHERE
         payment_instruction_id = l_pmt_instr_id
     ;

     RETURN l_pmt_instr_profile;

 EXCEPTION
     WHEN OTHERS THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Exception occured when '
	             || 'retrieving profile for '
	             || 'payment instruction '
	             || l_pmt_instr_id,
	             FND_LOG.LEVEL_UNEXPECTED
	             );
	         print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE,
	             FND_LOG.LEVEL_UNEXPECTED);
	         print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM,
	             FND_LOG.LEVEL_UNEXPECTED);

         END IF;
         /*
          * Propogate exception to caller.
          */
         RAISE;

 END get_instruction_profile;

/*--------------------------------------------------------------------
 | NAME:
 |     retrieveSortOptionForProfile
 |
 | PURPOSE:
 |
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
 PROCEDURE retrieveSortOptionForProfile(
     p_profile_id     IN IBY_PAY_INSTRUCTIONS_ALL.payment_profile_id%TYPE,
     x_sortOptionsTab IN OUT NOCOPY sortOptionsTabType
     )
 IS

 l_module_name   VARCHAR2(200) := G_PKG_NAME || '.retrieveSortOptionForProfile';

 /*
  * Cursor to pick up the sorting options for the given
  * profile from the IBY_INSTR_CREATION_RULES table.
  */
 CURSOR c_sorting_options
 IS
 SELECT
     icr.system_profile_code,
     icr.sort_option_1,
     icr.sort_order_1,
     icr.sort_option_2,
     icr.sort_order_2,
     icr.sort_option_3,
     icr.sort_order_3
 FROM
     IBY_INSTR_CREATION_RULES icr,
     IBY_PAYMENT_PROFILES     prof
 WHERE
     prof.payment_profile_id = p_profile_id             AND
     icr.system_profile_code = prof.system_profile_code
 ;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     /*
      * Pick up sorting options for all available profiles.
      */
     OPEN  c_sorting_options;
     FETCH c_sorting_options BULK COLLECT INTO x_sortOptionsTab;
     CLOSE c_sorting_options;

     IF (x_sortOptionsTab.COUNT = 0) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'No records were found in '
	             || 'IBY_INSTR_CREATION_RULES. Exiting .. '
	             );

	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END retrieveSortOptionForProfile;

/*--------------------------------------------------------------------
 | NAME:
 |     initializeInstrs
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
 PROCEDURE initializeInstrs(
     x_pmtInstrTab           IN OUT NOCOPY pmtInstrTabType,
     p_single_pmt_flow_flag  IN VARCHAR2
     )
 IS

 l_module_name   VARCHAR2(200) := G_PKG_NAME || '.initializeInstrs';
 l_process_type  IBY_PAY_INSTRUCTIONS_ALL.process_type%TYPE;
 l_multi_pi_flag BOOLEAN := FALSE;
 l_instr_seq_num VARCHAR2(200);

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     IF (x_pmtInstrTab.COUNT = 0) THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'No instructions to initialize.');
	         print_debuginfo(l_module_name, 'EXIT');
         END IF;
         RETURN;
     END IF;

     IF (UPPER(p_single_pmt_flow_flag) = 'Y') THEN
         l_process_type := 'IMMEDIATE';
     ELSE
         l_process_type := 'STANDARD';
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Process type of payment instruction(s) '
	         || 'initialized to '
	         || l_process_type
	         );

     END IF;
     /*
      * Determine whether multiple payment instructions
      * were created during this run. This will have an
      * impact on the way we set the admin assigned ref
      * on the payment instruction.
      */
     IF (x_pmtInstrTab.COUNT > 1) THEN
         l_multi_pi_flag := TRUE;
     ELSE
         l_multi_pi_flag := FALSE;
     END IF;

     FOR i IN x_pmtInstrTab.FIRST .. x_pmtInstrTab.LAST LOOP

         x_pmtInstrTab(i).process_type                   := l_process_type;
         x_pmtInstrTab(i).payment_instruction_status     := 'CREATED';
         x_pmtInstrTab(i).payments_complete_code         :=
             NVL(x_pmtInstrTab(i).payments_complete_code, 'NO');
         x_pmtInstrTab(i).generate_sep_remit_advice_flag :=
             NVL(x_pmtInstrTab(i).generate_sep_remit_advice_flag, 'N');
         x_pmtInstrTab(i).remittance_advice_created_flag :=
             NVL(x_pmtInstrTab(i).remittance_advice_created_flag, 'N');
         x_pmtInstrTab(i).regulatory_report_created_flag :=
             NVL(x_pmtInstrTab(i).regulatory_report_created_flag, 'N');
         x_pmtInstrTab(i).bill_payable_flag              :=
             NVL(x_pmtInstrTab(i).bill_payable_flag, 'N');
         x_pmtInstrTab(i).positive_pay_file_created_flag :=
             NVL(x_pmtInstrTab(i).positive_pay_file_created_flag, 'N');

         /*
          * Fix for bug 5023151:
          *
          * Do not overwrite the 'print now' or 'transmit now'
          * flags if they are already set.
          */
         x_pmtInstrTab(i).print_instruction_immed_flag   :=
             NVL(x_pmtInstrTab(i).print_instruction_immed_flag, 'N');
         x_pmtInstrTab(i).transmit_instr_immed_flag      :=
             NVL(x_pmtInstrTab(i).transmit_instr_immed_flag, 'N');

         x_pmtInstrTab(i).created_by                     := fnd_global.user_id;
         x_pmtInstrTab(i).creation_date                  := sysdate;
         x_pmtInstrTab(i).last_updated_by                := fnd_global.user_id;
         x_pmtInstrTab(i).last_update_login              := fnd_global.user_id;
         x_pmtInstrTab(i).last_update_date               := sysdate;
         x_pmtInstrTab(i).object_version_number          := 1;

	 /*
          * Fix for bug 5337042:
          *
          * If there is more than one PI getting created
	  * then append the pay_admin_assigned_ref with numbers
	  */
	 IF (l_multi_pi_flag = TRUE AND
             x_pmtInstrTab(i).pay_admin_assigned_ref_code IS NOT NULL) THEN

            /*
             * Fix for bug 5479918:
             *
             * Remove space after the hyphen
             *
             * When multiple PIs are created use the following
             * format for the admin ref -
             *
             *  LSBP-1
             *  LSBP-2
             *  LSBP-3
             *
             *  :
             *
             *  LSB-n
             *
             * Assuming that the user gave 'LSB' as the admin assigned ref
             * conc program param.
             */
	    x_pmtInstrTab(i).pay_admin_assigned_ref_code :=
		x_pmtInstrTab(i).pay_admin_assigned_ref_code ||'-'|| i;

	 END IF;

         /*
          * Fix for bug 5584658:
          *
          * Call the Federal API for payment instruction sequence
          * assignment. This API will detect if the installation is
          * a Federal install and return a sequence number (if possible).
          *
          * If the Federal API returns a sequence number assign this
          * value to the admin assigned ref field on the payment
          * instruction.
          *
          * If the Federal API returns null, then leave the present
          * value of the admin assigned ref on the pmt instruction
          * unchanged.
          */

         BEGIN
         l_instr_seq_num := FV_FEDERAL_PAYMENT_FIELDS_PKG.
                                get_pay_instr_seq_num(
                                    x_pmtInstrTab(i).org_id,
                                    x_pmtInstrTab(i).payment_reason_code
                                    );
         EXCEPTION
          WHEN OTHERS THEN
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	           print_debuginfo(l_module_name, 'FV module returned exception.. Swallowing');

           END IF;
         END;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'For pmt instr id: '
	             || x_pmtInstrTab(i).payment_instruction_id
	             || ' with org id: '
	             || x_pmtInstrTab(i).org_id
	             || ' and payment reason code: '
	             || x_pmtInstrTab(i).payment_reason_code
	             || ', Federal Seq API returned seq #: '
	             || l_instr_seq_num
	             );

         END IF;
         IF (l_instr_seq_num IS NOT NULL) THEN
	    x_pmtInstrTab(i).pay_admin_assigned_ref_code := l_instr_seq_num;
         END IF;

     END LOOP;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END initializeInstrs;


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

END IBY_PAYINSTR_PUB;

/
