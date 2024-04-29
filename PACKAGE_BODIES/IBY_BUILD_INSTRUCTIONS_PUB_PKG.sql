--------------------------------------------------------
--  DDL for Package Body IBY_BUILD_INSTRUCTIONS_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_BUILD_INSTRUCTIONS_PUB_PKG" AS
/*$Header: ibypayib.pls 120.49.12010000.5 2010/06/14 08:43:22 asarada ship $*/

 --
 -- Declare global variables
 --
 G_CURRENT_RUNTIME_LEVEL      CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
 G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBY_BUILD_INSTRUCTIONS_PUB_PKG';

 --
 -- List of instruction statuses that are used / set in this
 -- module (payment instruction creation flow).
 --
 INS_STATUS_CREATED         CONSTANT VARCHAR2(100) := 'CREATED';
 INS_STATUS_PRINT_DEFERRED  CONSTANT VARCHAR2(100) := 'PRINTING_DEFERRED';
 INSTR_STATUS_RETRY_CREAT   CONSTANT VARCHAR2(100) := 'RETRY_CREATION';
 INSTR_STATUS_CREAT_ERROR   CONSTANT VARCHAR2(100) := 'CREATION_ERROR';
 INS_STATUS_READY_TO_PRINT  CONSTANT VARCHAR2(100) :=
                                         'CREATED_READY_FOR_PRINTING';
 INS_STATUS_READY_TO_FORMAT CONSTANT VARCHAR2(100) :=
                                         'CREATED_READY_FOR_FORMATTING';

/*--------------------------------------------------------------------
 | NAME:
 |     build_pmt_instructions
 |
 | PURPOSE:
 |     This is the top level procedure of the payment instruction
 |     creation program; This procedure will run as a concurrent program.
 |
 | PARAMETERS:
 |     IN
 |
 |     p_calling_app_id
 |         The 3-character product code of the calling application
 |
 |     p_calling_app_payreq_cd
 |         Id of the payment service request from the calling app's
 |         point of view. For a given calling app, this id should be
 |         unique; the build program will communicate back to the calling
 |         app using this payment request id.
 |
 |     p_internal_bank_account_id
 |         The internal bank account to pay from.
 |
 |     p_payment_profile_id
 |         Payment profile
 |
 |     p_allow_zero_payments_flag
 |         'Y' / 'N' flag indicating whether zero value payments are allowed.
 |         If not set, this value will be defaulted to 'Y'.
 |
 |     p_payment_date
 |         The payment date.
 |
 |     p_anticipated_value_date
 |         The anticipated value date.
 |
 |     p_args10 - p_args100
 |         These 91 parameters are mandatory for any stored procedure
 |         that is submitted from Oracle Forms as a concurrent request
 |         (to get the total number of args to the concurrent procedure
 |         to 100).
 |
 |     OUT
 |
 |     x_errbuf
 |     x_retcode
 |
 |         These two are mandatory output paramaters for a concurrent
 |         program. They will store the error message and error code
 |         to indicate a successful/failed run of the concurrent request.
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE build_pmt_instructions(
     x_errbuf                     OUT NOCOPY VARCHAR2,
     x_retcode                    OUT NOCOPY VARCHAR2,

     /*-- processing criteria --*/
     p_processing_type            IN         VARCHAR2,
     p_payment_profile_id         IN         VARCHAR2 DEFAULT NULL,
     p_pmt_document_id            IN         VARCHAR2 DEFAULT NULL,
     p_internal_bank_account_id   IN         VARCHAR2 DEFAULT NULL,
     p_print_now_flag             IN         VARCHAR2 DEFAULT NULL,
     p_printer_name               IN         VARCHAR2 DEFAULT NULL,
     p_payment_currency           IN         VARCHAR2 DEFAULT NULL,
     p_transmit_now_flag          IN         VARCHAR2 DEFAULT NULL,

     /*-- user/admin assigned criteria --*/
     p_admin_assigned_ref         IN         VARCHAR2 DEFAULT NULL,
     p_comments                   IN         VARCHAR2 DEFAULT NULL,

     /*-- selection criteria --*/
     p_calling_app_id             IN         VARCHAR2 DEFAULT NULL,
     p_calling_app_payreq_cd      IN         VARCHAR2 DEFAULT NULL,
     p_le_id                      IN         VARCHAR2 DEFAULT NULL,
     p_org_id                     IN         VARCHAR2 DEFAULT NULL,
     p_org_type                   IN         VARCHAR2 DEFAULT NULL,
     p_payment_from_date          IN         VARCHAR2 DEFAULT NULL,
     p_payment_to_date            IN         VARCHAR2 DEFAULT NULL,

     p_arg19  IN VARCHAR2 DEFAULT NULL,
     p_arg20  IN VARCHAR2 DEFAULT NULL, p_arg21  IN VARCHAR2 DEFAULT NULL,
     p_arg22  IN VARCHAR2 DEFAULT NULL, p_arg23  IN VARCHAR2 DEFAULT NULL,
     p_arg24  IN VARCHAR2 DEFAULT NULL, p_arg25  IN VARCHAR2 DEFAULT NULL,
     p_arg26  IN VARCHAR2 DEFAULT NULL, p_arg27  IN VARCHAR2 DEFAULT NULL,
     p_arg28  IN VARCHAR2 DEFAULT NULL, p_arg29  IN VARCHAR2 DEFAULT NULL,
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

 l_return_status  VARCHAR2 (100);
 l_return_message VARCHAR2 (3000);

 l_msg_count      NUMBER;
 l_msg_data       VARCHAR2(4000);

 /* hook related params */
 l_pkg_name       VARCHAR2(200);
 l_callout_name   VARCHAR2(500);
 l_stmt           VARCHAR2(1000);
 l_ret_status     VARCHAR2(300);
 l_error_code     VARCHAR2(3000);
 l_api_version    CONSTANT NUMBER := 1.0;

 l_payreq_id      IBY_PAY_SERVICE_REQUESTS.payment_service_request_id%TYPE;
 l_module_name    VARCHAR2(200) := G_PKG_NAME || '.build_payment_instructions';
 l_not_provided   CONSTANT VARCHAR2(100) := '<not provided>';

 l_pmtInstrTab    IBY_PAYINSTR_PUB.pmtInstrTabType;

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

     END IF;
     SAVEPOINT BEGIN_PMT_INST_PROCESSING;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, '+--------------------------------------+');
	     print_debuginfo(l_module_name, '|STEP 1: Create Payment Instructions   |');
	     print_debuginfo(l_module_name, '+--------------------------------------+');

     END IF;
     /*
      * F8 - Payment Instruction Creation Flow (Part I)
      *
      * Find all payments that are in 'created' status
      * and create payment instructions from such payments.
      */

     BEGIN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Provided selection criteria - ');

	         print_debuginfo(l_module_name, 'p_processing_type: '
	             || NVL(p_processing_type,           l_not_provided));
	         print_debuginfo(l_module_name, 'p_payment_profile_id: '
	             || NVL(p_payment_profile_id,        l_not_provided));
	         print_debuginfo(l_module_name, 'p_pmt_document_id: '
	             || NVL(p_pmt_document_id,           l_not_provided));
	         print_debuginfo(l_module_name, 'p_internal_bank_account_id: '
	             || NVL(p_internal_bank_account_id,  l_not_provided));
	         print_debuginfo(l_module_name, 'p_print_now_flag: '
	             || NVL(p_print_now_flag,            l_not_provided));
	         print_debuginfo(l_module_name, 'p_printer_name: '
	             || NVL(p_printer_name,              l_not_provided));
	         print_debuginfo(l_module_name, 'p_payment_currency: '
	             || NVL(p_payment_currency,          l_not_provided));
	         print_debuginfo(l_module_name, 'p_transmit_now_flag: '
	             || NVL(p_transmit_now_flag,         l_not_provided));
	         print_debuginfo(l_module_name, 'p_admin_assigned_ref: '
	             || NVL(p_admin_assigned_ref,        l_not_provided));
	         print_debuginfo(l_module_name, 'p_comments: '
	             || NVL(p_comments,                  l_not_provided));
	         print_debuginfo(l_module_name, 'p_calling_app_id: '
	             || NVL(p_calling_app_id,            l_not_provided));
	         print_debuginfo(l_module_name, 'p_calling_app_payreq_cd: '
	             || NVL(p_calling_app_payreq_cd,     l_not_provided));
	         print_debuginfo(l_module_name, 'p_le_id: '
	             || NVL(p_le_id,                     l_not_provided));
	         print_debuginfo(l_module_name, 'p_org_id: '
	             || NVL(p_org_id,                    l_not_provided));
	         print_debuginfo(l_module_name, 'p_org_type: '
	             || NVL(p_org_type,                  l_not_provided));
	         print_debuginfo(l_module_name, 'p_payment_from_date: '
	             || NVL(p_payment_from_date,         l_not_provided));
	         print_debuginfo(l_module_name, 'p_payment_to_date: '
	             || NVL(p_payment_to_date,           l_not_provided));

         END IF;
         IF (p_calling_app_payreq_cd IS NOT NULL) THEN

             IF (p_calling_app_id IS NULL) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Invalid selection '
	                     || 'criteria provided; calling app payment '
	                     || 'service request id has been provided but '
	                     || 'calling app id has not been provided.'
	                     || 'For selection by payment service request, '
	                     || 'the calling app id needs to be provided.'
	                     );

	                 print_debuginfo(l_module_name, 'Payment instruction '
	                     || 'creation will not proceed.'
	                     );

                 END IF;
                 x_errbuf := 'PAY INSTRUCTION PROGRAM ERROR - INVALID '
                      || 'SELECTION CRITERIA PROVIDED';
                 x_retcode := '-1';

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'EXIT');

                 END IF;
                 RETURN;

             END IF;

             l_payreq_id := get_payreq_id(p_calling_app_id,
                                p_calling_app_payreq_cd);

         END IF;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Invoking createPaymentInstructions()');

         END IF;
         /*
          * Invoke payment instruction creation logic.
          */
         IBY_PAYINSTR_PUB.createPaymentInstructions(
             p_processing_type,
             p_pmt_document_id,
             p_printer_name,
             p_print_now_flag,
             p_transmit_now_flag,
             p_admin_assigned_ref,
             p_comments,
             p_payment_profile_id,
             TO_NUMBER(p_calling_app_id),
             p_calling_app_payreq_cd,
             l_payreq_id,
             TO_NUMBER(p_internal_bank_account_id),
             p_payment_currency,
             TO_NUMBER(p_le_id),
             TO_NUMBER(p_org_id),
             p_org_type,

             /*
              * Fix for bug 5129717:
              *
              * Provide the appropriate date pattern to
              * convert date filter criteria into DATE
              * datetypes.
              */
             TO_DATE(p_payment_from_date, 'YYYY/MM/DD HH24:MI:SS'),
             TO_DATE(p_payment_to_date,   'YYYY/MM/DD HH24:MI:SS'),
             'N',                 -- single payments flow flag
             l_pmtInstrTab,
             l_return_status,
             l_msg_count,
             l_msg_data
             );

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Status after payment '
	             || 'instruction creation: '
	             || l_return_status);

         END IF;
         /*
          * If payment instruction creation was completed, then commit.
          */
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Payment instruction '
	             || 'creation completed successfully.');

	         print_debuginfo(l_module_name, 'Performing commit ..');
         END IF;
         COMMIT;

     EXCEPTION

         WHEN OTHERS THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Exception occured when '
	             || 'creating payment instructions. Payment instruction '
	             || 'creation will be aborted.'
	             );
	         print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	         print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);

         END IF;
         ROLLBACK TO SAVEPOINT BEGIN_PMT_INST_PROCESSING;

         x_errbuf := 'PROGRAM ERROR - CANNOT CREATE PAYMENT INSTRUCTIONS';
         x_retcode := '-1';
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     END;


     /*
      * If we reached here, it means that the payment instruction
      * creation program finished successfully. Invoke
      * check numbering if we are building payment instructions
      * of processing type 'printed'.
      */
     BEGIN

         IF (p_processing_type = 'PRINTED' OR (p_processing_type = 'ELECTRONIC' and p_pmt_document_id IS NOT NULL)) THEN

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
                             p_pmt_document_id,
                             NULL,
                             l_return_status,
                             l_return_message,
                             l_msg_count,
                             l_msg_data
                             );

                         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                         print_debuginfo(l_module_name, 'After numbering, '
	                             || 'return status: '
	                             || l_return_status
	                             || ', and return message: '
	                             || l_return_message
	                             );

                         END IF;
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

                             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                             print_debuginfo(l_module_name, 'Extract and '
	                                 || 'format operation generated '
	                                 || 'exception for payment instruction '
	                                 || l_pmtInstrTab(i).payment_instruction_id,
	                                 FND_LOG.LEVEL_UNEXPECTED
	                                 );

	                             print_debuginfo(l_module_name, 'SQL code: '
	                                 || SQLCODE, FND_LOG.LEVEL_UNEXPECTED);
	                             print_debuginfo(l_module_name, 'SQL err msg: '
	                                 || SQLERRM, FND_LOG.LEVEL_UNEXPECTED);

                             END IF;
                             /*
                              * Propogate exception.
                              */
                             RAISE;

                         END;

                         /*
                          * Move all other successful payment instructions
                          * to deferred status (for later numbering).
                          */
                         moveInstrToDeferredStatus(l_pmtInstrTab,
                             l_pmtInstrTab(i).payment_instruction_id);

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

         ELSE

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Processing type is '
	                 || p_processing_type
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
                                 OUT l_ret_status,
                                 OUT l_msg_count,
                                 OUT l_msg_data
                             ;

                             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                             print_debuginfo(l_module_name,
	                                 'Finished invoking hook: '
	                                 || l_callout_name
	                                 || ', return status: '
	                                 || l_ret_status, FND_LOG.LEVEL_UNEXPECTED);

                             END IF;
                             /*
                              * If the called procedure did not return success,
                              * raise an exception.
                              */
                             IF (l_ret_status IS NULL OR
                                 l_ret_status <> FND_API.G_RET_STS_SUCCESS)
                                 THEN

                                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                                 print_debuginfo(l_module_name,
	                                     'Fatal: External app callout '''
	                                     || l_callout_name
	                                     || ''', returned failure status - '
	                                     || l_ret_status
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

                                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                                 print_debuginfo(l_module_name,
	                                     'Fatal: External app '
	                                     || 'callout '''
	                                     || l_callout_name
	                                     || ''', generated exception.',
	                                     FND_LOG.LEVEL_UNEXPECTED
	                                     );

                                 END IF;
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
                                 FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
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
	                                 || l_pmtInstrTab(i).payment_instruction_id,
	                                 FND_LOG.LEVEL_UNEXPECTED
	                                 );

	                             print_debuginfo(l_module_name, 'SQL code: '
	                                 || SQLCODE, FND_LOG.LEVEL_UNEXPECTED);
	                             print_debuginfo(l_module_name, 'SQL err msg: '
	                                 || SQLERRM, FND_LOG.LEVEL_UNEXPECTED);

                             END IF;
                             /*
                              * Propogate exception.
                              */
                             RAISE;

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

         END IF; -- processing type = 'printed'

         /*
          * In case check numbering completes, perform a commit.
          */
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Performing commit ..');
         END IF;
         COMMIT;

     EXCEPTION

         WHEN OTHERS THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Exception occured when performing '
	             || 'check numbering / invoking extract and format. '
	             || 'Processing aborted ..'
	             );
	         print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	         print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);

         END IF;
         x_errbuf := 'PROGRAM ERROR - CANNOT PERFORM '
             || 'CHECK NUMBERING';
         x_retcode := '-1';
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     END;

     /*
      * If we reached here, it means that the payment instruction
      * creation program finished successfully. Set the response
      * message to 'success'.
      */
     x_errbuf := 'PAYMENT INSTRUCTION CREATION PROGRAM COMPLETED SUCCESSFULLY';
     x_retcode := '0';

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END build_pmt_instructions;

/*--------------------------------------------------------------------
 | NAME:
 |     rebuild_pmt_instruction
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
 PROCEDURE rebuild_pmt_instruction(
     x_errbuf         OUT NOCOPY VARCHAR2,
     x_retcode        OUT NOCOPY VARCHAR2,
     p_pmt_instr_id   IN         VARCHAR2,
     p_arg4   IN VARCHAR2 DEFAULT NULL, p_arg5   IN VARCHAR2 DEFAULT NULL,
     p_arg6   IN VARCHAR2 DEFAULT NULL, p_arg7   IN VARCHAR2 DEFAULT NULL,
     p_arg8   IN VARCHAR2 DEFAULT NULL, p_arg9   IN VARCHAR2 DEFAULT NULL,
     p_arg10  IN VARCHAR2 DEFAULT NULL, p_arg11  IN VARCHAR2 DEFAULT NULL,
     p_arg12  IN VARCHAR2 DEFAULT NULL, p_arg13  IN VARCHAR2 DEFAULT NULL,
     p_arg14  IN VARCHAR2 DEFAULT NULL, p_arg15  IN VARCHAR2 DEFAULT NULL,
     p_arg16  IN VARCHAR2 DEFAULT NULL, p_arg17  IN VARCHAR2 DEFAULT NULL,
     p_arg18  IN VARCHAR2 DEFAULT NULL, p_arg19  IN VARCHAR2 DEFAULT NULL,
     p_arg20  IN VARCHAR2 DEFAULT NULL, p_arg21  IN VARCHAR2 DEFAULT NULL,
     p_arg22  IN VARCHAR2 DEFAULT NULL, p_arg23  IN VARCHAR2 DEFAULT NULL,
     p_arg24  IN VARCHAR2 DEFAULT NULL, p_arg25  IN VARCHAR2 DEFAULT NULL,
     p_arg26  IN VARCHAR2 DEFAULT NULL, p_arg27  IN VARCHAR2 DEFAULT NULL,
     p_arg28  IN VARCHAR2 DEFAULT NULL, p_arg29  IN VARCHAR2 DEFAULT NULL,
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
 l_return_status  NUMBER;
 l_ret_status     VARCHAR2 (100);
 l_return_message VARCHAR2 (3000);

 l_instr_status   IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_status%TYPE;
 l_instr_rec      IBY_PAY_INSTRUCTIONS_ALL%ROWTYPE;
 l_instr_tab      IBY_PAYINSTR_PUB.pmtInstrTabType;

 l_doc_error_tab  IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_doc_token_tab  IBY_VALIDATIONSETS_PUB.trxnErrTokenTabType;

 l_profile_attribs IBY_DISBURSE_SUBMIT_PUB_PKG.profileProcessAttribs;

 l_msg_count      NUMBER;
 l_msg_data       VARCHAR2(4000);

 l_module_name    VARCHAR2(200) := G_PKG_NAME || '.rebuild_pmt_instruction';

 BEGIN

     SAVEPOINT BEGIN_REBUILD;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

	     print_debuginfo(l_module_name, 'Provided payment instruction id: '
	         || p_pmt_instr_id);

     END IF;
     BEGIN

         /*
          * Retrieve the attributes of the provided payment instruction.
          */
         l_instr_rec := get_instruction_attributes(p_pmt_instr_id);

         IF (l_instr_rec.payment_instruction_status IS NULL) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Attributes of payment '
	                 || 'instruction id: '
	                 || p_pmt_instr_id
	                 || ' could not be retrieved. Aborting rebuild ..',
	                 FND_LOG.LEVEL_UNEXPECTED
	                 );

             END IF;
             APP_EXCEPTION.RAISE_EXCEPTION;

         END IF;

         /*
          * Check the status of the provided payment instruction.
          */
         l_instr_status := l_instr_rec.payment_instruction_status;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Payment instruction status is: '
	             || l_instr_status);

         END IF;
         IF (l_instr_status <> INSTR_STATUS_RETRY_CREAT  AND
             l_instr_status <> INSTR_STATUS_CREAT_ERROR) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Payment instruction '
	                 || 'should be in '
	                 || INSTR_STATUS_RETRY_CREAT
	                 || ' or '
	                 || INSTR_STATUS_CREAT_ERROR
	                 || ' status for rebuilding. '
	                 || 'Skipping payment instruction rebuild ..'
	                 );

             END IF;
         ELSE

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name,
	                 'Invoking recreatePaymentInstruction()');

             END IF;
             IBY_PAYINSTR_PUB.recreatePaymentInstruction(
                 l_instr_rec,
                 l_doc_error_tab,
                 l_doc_token_tab,
                 l_return_status);

             /*
              * The provided payment instruction has been revalidated
              * and (possibly) document sequencing and payment referencing
              * has occured for the payments of this instruction.
              * Therefore, the payment instruction status needs to be updated.
              */
             l_instr_tab(l_instr_tab.COUNT + 1) := l_instr_rec;
             IBY_PAYINSTR_PUB.updatePaymentInstructions(l_instr_tab);

             /*
              * If the payment instructions wwas again failed, the
              * IBY_TRANSACTION_ERRORS table must be populated with the
              * corresponding error messages.
              */
             IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',
                 l_doc_error_tab, l_doc_token_tab);

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Status after payment '
	                 || 'instruction rebuild: '
	                 || l_return_status);

             END IF;
         END IF;

         /*
          * After rebuilding completes, perform a commit.
          */
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Performing commit ..');
         END IF;
         COMMIT;

     EXCEPTION
         WHEN OTHERS THEN

         /*
          * In the case of an exception rollback all the
          * database changes and return failure response.
          */
         ROLLBACK TO SAVEPOINT BEGIN_REBUILD;

         x_errbuf  := 'PAY INSTRUCTION REBUILD ERROR';
         x_retcode := '-1';

          /*
           * The payment instruction was possibly locked by the UI.
           * Unlock it if possible.
           */
          IBY_DISBURSE_UI_API_PUB_PKG.unlock_pmt_entity(
              p_pmt_instr_id,
              'PAYMENT_INSTRUCTION',
              l_ret_status
              );

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     END;


     /*
      * Get the default processing related attributes
      * from the payment process profile on the given
      * payment instruction. These attributes like the
      * processing type etc. will be used in check
      * numbering and formatting calls.
      */
     IBY_DISBURSE_SUBMIT_PUB_PKG.get_profile_process_attribs(
         l_instr_rec.payment_profile_id,
         l_profile_attribs
         );

     /*
      * If we reached here, it means that the payment instruction
      * re-creation program finished successfully. Invoke
      * check numbering if we are building payment instructions
      * of processing type 'printed'.
      */
     BEGIN

         IF (l_profile_attribs.processing_type = 'PRINTED') THEN

             IF (l_instr_tab.COUNT > 0) THEN

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
                 FOR i IN l_instr_tab.FIRST .. l_instr_tab.LAST LOOP

                     /*
                      * Number only successful payment
                      * instructions.
                      */
                     IF (l_instr_tab(i).payment_instruction_status =
                             INS_STATUS_CREATED) THEN

                         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                         print_debuginfo(l_module_name, 'Invoking '
	                             || 'numbering for payment '
	                             || 'instruction '
	                             || l_instr_tab(i).payment_instruction_id
	                             || ' with instruction status: '
	                             || l_instr_tab(i).payment_instruction_status
	                             );

                         END IF;
                         /*
                          * Invoke check numbering for this payment
                          * instruction.
                          */

                         /*
                          * Fix for bug 5206725:
                          *
                          * Do not use the payment document on the profile
                          * for numbering. This is an optional attribute
                          * on the profile that may or may not be present.
                          *
                          * Since, this is a rebuild scenario, the pmt
                          * document id would have already been provided
                          * to the payment instruction in the first attempt.
                          *
                          * This value is stored as a payment instruction
                          * attribute. Re-use the stored value.
                          */
                         IBY_CHECKNUMBER_PUB.performCheckNumbering(
                             l_instr_tab(i).payment_instruction_id,
                             l_instr_rec.payment_document_id,
                             NULL,
                             l_ret_status,
                             l_return_message,
                             l_msg_count,
                             l_msg_data
                             );

                         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                         print_debuginfo(l_module_name, 'After numbering, '
	                             || 'return status: '
	                             || l_ret_status
	                             || ', and return message: '
	                             || l_return_message
	                             );

                         END IF;
                         IF (l_ret_status <> FND_API.G_RET_STS_SUCCESS) THEN

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
	                                 || l_instr_tab(i).payment_instruction_id
	                                 );

                             END IF;
                             IBY_FD_POST_PICP_PROGS_PVT.
                                 Run_Post_PI_Programs(
                                     l_instr_tab(i).payment_instruction_id,
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
	                                 || l_instr_tab(i).payment_instruction_id,
	                                 FND_LOG.LEVEL_UNEXPECTED
	                                 );

	                             print_debuginfo(l_module_name, 'SQL code: '
	                                 || SQLCODE, FND_LOG.LEVEL_UNEXPECTED);
	                             print_debuginfo(l_module_name, 'SQL err msg: '
	                                 || SQLERRM, FND_LOG.LEVEL_UNEXPECTED);

                             END IF;
                             /*
                              * Propogate exception.
                              */
                             RAISE;

                         END;

                         /*
                          * Move all other successful payment instructions
                          * to deferred status (for later numbering).
                          */
                         moveInstrToDeferredStatus(l_instr_tab,
                             l_instr_tab(i).payment_instruction_id);

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
	                             || l_instr_tab(i).payment_instruction_id
	                             || ', as it is in status '
	                             || l_instr_tab(i).payment_instruction_status
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

         ELSIF (l_profile_attribs.processing_type = 'ELECTRONIC' AND
                    l_instr_rec.payment_document_id IS NOT NULL) THEN

	              IF (l_instr_tab.COUNT > 0) THEN

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
	                  FOR i IN l_instr_tab.FIRST .. l_instr_tab.LAST LOOP

	                      /*
	                       * Number only successful payment
	                       * instructions.
	                       */
	                      IF (l_instr_tab(i).payment_instruction_status =
	                              INS_STATUS_CREATED) THEN

	                          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	 	                         print_debuginfo(l_module_name, 'Invoking '
	 	                             || 'numbering for payment '
	 	                             || 'instruction '
	 	                             || l_instr_tab(i).payment_instruction_id
	 	                             || ' with instruction status: '
	 	                             || l_instr_tab(i).payment_instruction_status
	 	                             );

	                          END IF;
	                          /*
	                           * Invoke check numbering for this payment
	                           * instruction.
	                           */

	                          /*
	                           * Fix for bug 5206725:
	                           *
	                           * Do not use the payment document on the profile
	                           * for numbering. This is an optional attribute
	                           * on the profile that may or may not be present.
	                           *
	                           * Since, this is a rebuild scenario, the pmt
	                           * document id would have already been provided
	                           * to the payment instruction in the first attempt.
	                           *
	                           * This value is stored as a payment instruction
	                           * attribute. Re-use the stored value.
	                           */
	                          IBY_CHECKNUMBER_PUB.performCheckNumbering(
	                              l_instr_tab(i).payment_instruction_id,
	                              l_instr_rec.payment_document_id,
	                              NULL,
	                              l_ret_status,
	                              l_return_message,
	                              l_msg_count,
	                              l_msg_data
	                              );

	                          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	 	                         print_debuginfo(l_module_name, 'After numbering, '
	 	                             || 'return status: '
	 	                             || l_ret_status
	 	                             || ', and return message: '
	 	                             || l_return_message
	 	                             );

	                          END IF;
	                          IF (l_ret_status <> FND_API.G_RET_STS_SUCCESS) THEN

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
	 	                                 || l_instr_tab(i).payment_instruction_id
	 	                                 );

	                              END IF;
	                              IBY_FD_POST_PICP_PROGS_PVT.
	                                  Run_Post_PI_Programs(
	                                      l_instr_tab(i).payment_instruction_id,
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
	 	                                 || l_instr_tab(i).payment_instruction_id,
	 	                                 FND_LOG.LEVEL_UNEXPECTED
	 	                                 );

	 	                             print_debuginfo(l_module_name, 'SQL code: '
	 	                                 || SQLCODE, FND_LOG.LEVEL_UNEXPECTED);
	 	                             print_debuginfo(l_module_name, 'SQL err msg: '
	 	                                 || SQLERRM, FND_LOG.LEVEL_UNEXPECTED);

	                              END IF;
	                              /*
	                               * Propogate exception.
	                               */
	                              RAISE;

	                          END;

	                          /*
	                           * Move all other successful payment instructions
	                           * to deferred status (for later numbering).
	                           */
	                          moveInstrToDeferredStatus(l_instr_tab,
	                              l_instr_tab(i).payment_instruction_id);

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
	 	                             || l_instr_tab(i).payment_instruction_id
	 	                             || ', as it is in status '
	 	                             || l_instr_tab(i).payment_instruction_status
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

             IF (l_instr_tab.COUNT > 0) THEN

                 /*
                  * Loop through all the payment instructions one-by-one.
                  *
                  * Invoke extract and format for each successful payment
                  * instruction.
                  */
                 FOR i IN l_instr_tab.FIRST .. l_instr_tab.LAST LOOP

                     /*
                      * Call post-PICP programs only for successful
                      * payment instructions.
                      */
                     IF (l_instr_tab(i).payment_instruction_status =
                             INS_STATUS_CREATED) THEN

                         BEGIN

                             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                             print_debuginfo(l_module_name, 'Invoking '
	                                 || 'extract and format for payment '
	                                 || 'instruction '
	                                 || l_instr_tab(i).payment_instruction_id
	                                 || ' with instruction status: '
	                                 || l_instr_tab(i).payment_instruction_status
	                                 );

                             END IF;
                             IBY_FD_POST_PICP_PROGS_PVT.
                                 Run_Post_PI_Programs(
                                     l_instr_tab(i).payment_instruction_id,
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
	                                 || l_instr_tab(i).payment_instruction_id,
	                                 FND_LOG.LEVEL_UNEXPECTED
	                                 );

	                             print_debuginfo(l_module_name, 'SQL code: '
	                                 || SQLCODE, FND_LOG.LEVEL_UNEXPECTED);
	                             print_debuginfo(l_module_name, 'SQL err msg: '
	                                 || SQLERRM, FND_LOG.LEVEL_UNEXPECTED);

                             END IF;
                             /*
                              * Propogate exception.
                              */
                             RAISE;

                         END;

                     ELSE

                         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                         print_debuginfo(l_module_name, 'Not invoking '
	                             || 'extract and format for payment '
	                             || 'instruction '
	                             || l_instr_tab(i).payment_instruction_id
	                             || ' because it is in status: '
	                             || l_instr_tab(i).payment_instruction_status
	                             );

                         END IF;
                     END IF;

                 END LOOP;

             END IF; -- if count of instructions > 0

         END IF; -- processing type = 'printed'

         /*
          * In case check numbering completes, perform a commit.
          */
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Performing commit ..');
         END IF;
         COMMIT;

     EXCEPTION

         WHEN OTHERS THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Exception occured when performing '
	             || 'check numbering / invoking extract and format. '
	             || 'Processing aborted ..'
	             );
	         print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	         print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);

         END IF;
         x_errbuf := 'PROGRAM ERROR - CANNOT PERFORM '
             || 'CHECK NUMBERING';
         x_retcode := '-1';

          /*
           * The payment instruction was possibly locked by the UI.
           * Unlock it if possible.
           */
          IBY_DISBURSE_UI_API_PUB_PKG.unlock_pmt_entity(
              p_pmt_instr_id,
              'PAYMENT_INSTRUCTION',
              l_ret_status
              );

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     END;

     /*
      * If we reached here, it means that the payment instruction
      * creation program finished successfully. Set the response
      * message to 'success'.
      */
     x_errbuf := 'PAYMENT INSTRUCTION RE-CREATION PROGRAM COMPLETED '
                     || 'SUCCESSFULLY';
     x_retcode := '0';

     /*
      * The payment instruction was possibly locked by the UI.
      * Unlock it if possible.
      */
     IBY_DISBURSE_UI_API_PUB_PKG.unlock_pmt_entity(
         p_pmt_instr_id,
         'PAYMENT_INSTRUCTION',
         l_ret_status
         );

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');


     END IF;
 END rebuild_pmt_instruction;

/*--------------------------------------------------------------------
 | NAME:
 |     moveInstrToDeferredStatus
 |
 |
 | PURPOSE:
 |     This method will set the status of a given payment instructions
 |     to 'CREATED_READY_FOR_PRINTING' | 'CREATED_READY_FOR_FORMATTING'
 |     status depending upon the payment profile on the instruction.
 |
 |     In case the second argument is not null, the status of that
 |     particular payment instruction will not be touched by this method.
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
 PROCEDURE moveInstrToDeferredStatus(
     p_pmtInstrTab       IN OUT NOCOPY IBY_PAYINSTR_PUB.pmtInstrTabType,
     p_instr_to_skip     IN IBY_PAY_INSTRUCTIONS_ALL.
                                payment_instruction_id%TYPE DEFAULT NULL
     )
 IS
 l_module_name    VARCHAR2(200) := G_PKG_NAME || '.moveInstrToDeferredStatus';

 l_send_to_file_flag VARCHAR2(1);
 l_processing_type IBY_PAYMENT_PROFILES.PROCESSING_TYPE%TYPE;
 l_instr_status      IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_status%TYPE;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     IF (p_pmtInstrTab.COUNT = 0) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'List of provided payment '
	             || 'instructions is empty. Exiting .. '
	             );

	         print_debuginfo(l_module_name, 'EXIT');
         END IF;
         RETURN;

     END IF;

     FOR i in p_pmtInstrTab.FIRST..p_pmtInstrTab.LAST LOOP

         /*
          * Set the status of all payment instructions in the given
          * list to 'printing deferred' except for the specified
          * payment instruction which is to be skipped (because it
          * has been printed).
          */

         IF (p_instr_to_skip IS NULL OR p_pmtInstrTab(i).payment_instruction_id
             <> p_instr_to_skip) THEN

             /*
                * The payment instruction status is dependant upon
                * the 'send to file' flag. Pre-set the instruction
                * status appropriately.
                */
             SELECT
                   send_to_file_flag, processing_type
               INTO
                   l_send_to_file_flag, l_processing_type
               FROM
                   IBY_PAYMENT_PROFILES
               WHERE
                   payment_profile_id = p_pmtInstrTab(i).payment_profile_id
               ;
             IF (l_processing_type = 'PRINTED') THEN


               IF (UPPER(l_send_to_file_flag) = 'Y') THEN
                   l_instr_status := INS_STATUS_READY_TO_FORMAT;
               ELSE
                   l_instr_status := INS_STATUS_READY_TO_PRINT;
               END IF;


               UPDATE
                   IBY_PAY_INSTRUCTIONS_ALL
               SET
                   payment_instruction_status = l_instr_status
               WHERE
                   payment_instruction_id = p_pmtInstrTab(i).
                                                payment_instruction_id;

               IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Updated payment '
	                 || 'instruction '
	                 || p_pmtInstrTab(i).payment_instruction_id
	                 || ' to '
	                 || l_instr_status
	                 || ' status.'
	                 );

               END IF;
             ELSE
              l_instr_status := INS_STATUS_CREATED;
              UPDATE
                   IBY_PAY_INSTRUCTIONS_ALL
               SET
                   payment_instruction_status = l_instr_status
               WHERE
                   payment_instruction_id = p_pmtInstrTab(i).
                                                payment_instruction_id;

               IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Updated payment '
	                 || 'instruction '
	                 || p_pmtInstrTab(i).payment_instruction_id
	                 || ' to '
	                 || l_instr_status
	                 || ' status.'
	                 );

               END IF;
             END IF;
         ELSE

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Skipping payment '
	                 || 'instruction '
	                 || p_pmtInstrTab(i).payment_instruction_id
	                 || ' ..'
	                 );

             END IF;
         END IF;

     END LOOP;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END moveInstrToDeferredStatus;

/*--------------------------------------------------------------------
 | NAME:
 |     get_payreq_id
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
 FUNCTION get_payreq_id (
     l_ca_id        IN IBY_PAY_SERVICE_REQUESTS.calling_app_id%TYPE,
     l_ca_payreq_cd IN IBY_PAY_SERVICE_REQUESTS.
                           call_app_pay_service_req_code%TYPE
     )
     RETURN IBY_PAY_SERVICE_REQUESTS.payment_service_request_id%TYPE
 IS

 l_payreq_id     NUMBER := -1;
 l_module_name   VARCHAR2(200) := G_PKG_NAME || '.get_payreq_id';

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     SELECT
         payment_service_request_id
     INTO
         l_payreq_id
     FROM
         IBY_PAY_SERVICE_REQUESTS
     WHERE
         calling_app_id = l_ca_id
     AND
         call_app_pay_service_req_code = l_ca_payreq_cd;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');
     END IF;
     RETURN l_payreq_id;

 EXCEPTION
     WHEN OTHERS THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Exception occured when '
	             || 'retrieving payment request id for '
	             || 'calling application '
	             || l_ca_id
	             || ' with calling app payment request cd '
	             || l_ca_payreq_cd
	             );
	         print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	         print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);
	         print_debuginfo(l_module_name, 'Returning -1 for payreq id');

         END IF;
         l_payreq_id := -1;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');
         END IF;
         RETURN l_payreq_id;

 END get_payreq_id;

/*--------------------------------------------------------------------
 | NAME:
 |     get_instruction_attributes
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
 FUNCTION get_instruction_attributes(
     l_pmt_instr_id IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE)
     RETURN IBY_PAY_INSTRUCTIONS_ALL%ROWTYPE
 IS

 l_module_name       VARCHAR2(200) := G_PKG_NAME ||
                                          '.get_instruction_attributes';

 l_instr_rec         IBY_PAY_INSTRUCTIONS_ALL%ROWTYPE;

 BEGIN

     SELECT
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
     INTO
         l_instr_rec.payment_instruction_id,
         l_instr_rec.payment_profile_id,
         l_instr_rec.process_type,
         l_instr_rec.payment_instruction_status,
         l_instr_rec.payments_complete_code,
         l_instr_rec.generate_sep_remit_advice_flag,
         l_instr_rec.remittance_advice_created_flag,
         l_instr_rec.regulatory_report_created_flag,
         l_instr_rec.bill_payable_flag,
         l_instr_rec.legal_entity_id,
         l_instr_rec.payment_count,
         l_instr_rec.positive_pay_file_created_flag,
         l_instr_rec.print_instruction_immed_flag,
         l_instr_rec.transmit_instr_immed_flag,
         l_instr_rec.created_by,
         l_instr_rec.creation_date,
         l_instr_rec.last_updated_by,
         l_instr_rec.last_update_date,
         l_instr_rec.last_update_login,
         l_instr_rec.object_version_number,
         l_instr_rec.internal_bank_account_id,
         l_instr_rec.pay_admin_assigned_ref_code,
         l_instr_rec.transmission_date,
         l_instr_rec.acknowledgement_date,
         l_instr_rec.comments,
         l_instr_rec.bank_assigned_ref_code,
         l_instr_rec.org_id,
         l_instr_rec.org_type,
         l_instr_rec.payment_date,
         l_instr_rec.payment_currency_code,
         l_instr_rec.payment_service_request_id,
         l_instr_rec.payment_function,
         l_instr_rec.payment_reason_code,
         l_instr_rec.rfc_identifier,
         l_instr_rec.payment_reason_comments,
         l_instr_rec.payment_document_id,
         l_instr_rec.printer_name,
         l_instr_rec.attribute_category,
         l_instr_rec.attribute1,
         l_instr_rec.attribute2,
         l_instr_rec.attribute3,
         l_instr_rec.attribute4,
         l_instr_rec.attribute5,
         l_instr_rec.attribute6,
         l_instr_rec.attribute7,
         l_instr_rec.attribute8,
         l_instr_rec.attribute9,
         l_instr_rec.attribute10,
         l_instr_rec.attribute11,
         l_instr_rec.attribute12,
         l_instr_rec.attribute13,
         l_instr_rec.attribute14,
         l_instr_rec.attribute15
     FROM
         IBY_PAY_INSTRUCTIONS_ALL
     WHERE
         payment_instruction_id = l_pmt_instr_id
     ;


     RETURN l_instr_rec;

 EXCEPTION
     WHEN OTHERS THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Exception occured when '
	             || 'retrieving payment instruction attributes for '
	             || 'payment instruction '
	             || l_pmt_instr_id
	             );
	         print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	         print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);
	         print_debuginfo(l_module_name, 'Returning NULL.');

         END IF;
         RETURN NULL;

 END get_instruction_attributes;

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
 |     build_electronic_instructions
 |
 | PURPOSE:
 |     Concurrent program wrapper for creating electronic payment
 |     instructions.
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
 PROCEDURE build_electronic_instructions(
     x_errbuf                     OUT NOCOPY VARCHAR2,
     x_retcode                    OUT NOCOPY VARCHAR2,

     /*-- processing criteria --*/
     p_processing_type            IN         VARCHAR2,

     /*-- user/admin assigned criteria --*/
     p_admin_assigned_ref         IN         VARCHAR2 DEFAULT NULL,
     p_comments                   IN         VARCHAR2 DEFAULT NULL,

     /*-- selection criteria --*/
     p_payment_profile_id         IN         VARCHAR2 DEFAULT NULL,
     p_payment_currency           IN         VARCHAR2 DEFAULT NULL,
     p_internal_bank_account_id   IN         VARCHAR2 DEFAULT NULL,
     p_calling_app_id             IN         VARCHAR2 DEFAULT NULL,
     p_calling_app_payreq_cd      IN         VARCHAR2 DEFAULT NULL,
     p_le_id                      IN         VARCHAR2 DEFAULT NULL,
     p_org_type                   IN         VARCHAR2 DEFAULT NULL,
     p_org_id                     IN         VARCHAR2 DEFAULT NULL,
     p_payment_from_date          IN         VARCHAR2 DEFAULT NULL,
     p_payment_to_date            IN         VARCHAR2 DEFAULT NULL,
     p_transmit_now_flag          IN         VARCHAR2 DEFAULT NULL,

     p_arg16  IN VARCHAR2 DEFAULT NULL, p_arg17  IN VARCHAR2 DEFAULT NULL,
     p_arg18  IN VARCHAR2 DEFAULT NULL, p_arg19  IN VARCHAR2 DEFAULT NULL,
     p_arg20  IN VARCHAR2 DEFAULT NULL, p_arg21  IN VARCHAR2 DEFAULT NULL,
     p_arg22  IN VARCHAR2 DEFAULT NULL, p_arg23  IN VARCHAR2 DEFAULT NULL,
     p_arg24  IN VARCHAR2 DEFAULT NULL, p_arg25  IN VARCHAR2 DEFAULT NULL,
     p_arg26  IN VARCHAR2 DEFAULT NULL, p_arg27  IN VARCHAR2 DEFAULT NULL,
     p_arg28  IN VARCHAR2 DEFAULT NULL, p_arg29  IN VARCHAR2 DEFAULT NULL,
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
 l_module_name    VARCHAR2(200) := G_PKG_NAME
                                       || '.build_electronic_instructions';
 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     build_pmt_instructions(
         x_errbuf,
         x_retcode,

         /*-- processing criteria --*/
         p_processing_type,
         p_payment_profile_id,
         NULL,                  -- p_pmt_document_id
         p_internal_bank_account_id,
         NULL,                  -- p_print_now_flag
         NULL,                  -- p_printer_name
         p_payment_currency,
         p_transmit_now_flag,

         /*-- user/admin assigned criteria --*/
         p_admin_assigned_ref,
         p_comments,

         /*-- selection criteria --*/
         p_calling_app_id,
         p_calling_app_payreq_cd,
         p_le_id,
         p_org_id,
         p_org_type,
         p_payment_from_date,
         p_payment_to_date
         );

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END build_electronic_instructions;

/*--------------------------------------------------------------------
 | NAME:
 |     build_printed_instructions
 |
 | PURPOSE:
 |     Concurrent program wrapper for creating printed payment
 |     instructions.
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
 PROCEDURE build_printed_instructions(
     x_errbuf                     OUT NOCOPY VARCHAR2,
     x_retcode                    OUT NOCOPY VARCHAR2,

     /*-- processing criteria --*/
     p_processing_type            IN         VARCHAR2,

     /*-- user/admin assigned criteria --*/
     p_admin_assigned_ref         IN         VARCHAR2 DEFAULT NULL,
     p_comments                   IN         VARCHAR2 DEFAULT NULL,

     /*-- selection criteria --*/
     p_payment_profile_id         IN         VARCHAR2 DEFAULT NULL,
     p_payment_currency           IN         VARCHAR2 DEFAULT NULL,
     p_internal_bank_account_id   IN         VARCHAR2 DEFAULT NULL,
     p_pmt_document_id            IN         VARCHAR2 DEFAULT NULL,
     p_calling_app_id             IN         VARCHAR2 DEFAULT NULL,
     p_calling_app_payreq_cd      IN         VARCHAR2 DEFAULT NULL,
     p_le_id                      IN         VARCHAR2 DEFAULT NULL,
     p_org_type                   IN         VARCHAR2 DEFAULT NULL,
     p_org_id                     IN         VARCHAR2 DEFAULT NULL,
     p_payment_from_date          IN         VARCHAR2 DEFAULT NULL,
     p_payment_to_date            IN         VARCHAR2 DEFAULT NULL,
     p_print_now_flag             IN         VARCHAR2 DEFAULT NULL,
     p_printer_name               IN         VARCHAR2 DEFAULT NULL,

     p_arg18  IN VARCHAR2 DEFAULT NULL, p_arg19  IN VARCHAR2 DEFAULT NULL,
     p_arg20  IN VARCHAR2 DEFAULT NULL, p_arg21  IN VARCHAR2 DEFAULT NULL,
     p_arg22  IN VARCHAR2 DEFAULT NULL, p_arg23  IN VARCHAR2 DEFAULT NULL,
     p_arg24  IN VARCHAR2 DEFAULT NULL, p_arg25  IN VARCHAR2 DEFAULT NULL,
     p_arg26  IN VARCHAR2 DEFAULT NULL, p_arg27  IN VARCHAR2 DEFAULT NULL,
     p_arg28  IN VARCHAR2 DEFAULT NULL, p_arg29  IN VARCHAR2 DEFAULT NULL,
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
 l_module_name    VARCHAR2(200) := G_PKG_NAME
                                       || '.build_printed_instructions';
 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     build_pmt_instructions(
         x_errbuf,
         x_retcode,

         /*-- processing criteria --*/
         p_processing_type,
         p_payment_profile_id,
         p_pmt_document_id,
         p_internal_bank_account_id,
         p_print_now_flag,
         p_printer_name,
         p_payment_currency,
         NULL,                  -- p_transmit_now_flag

         /*-- user/admin assigned criteria --*/
         p_admin_assigned_ref,
         p_comments,

         /*-- selection criteria --*/
         p_calling_app_id,
         p_calling_app_payreq_cd,
         p_le_id,
         p_org_id,
         p_org_type,
         p_payment_from_date,
         p_payment_to_date
         );

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END build_printed_instructions;

END IBY_BUILD_INSTRUCTIONS_PUB_PKG;

/
