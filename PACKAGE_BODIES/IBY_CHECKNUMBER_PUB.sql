--------------------------------------------------------
--  DDL for Package Body IBY_CHECKNUMBER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_CHECKNUMBER_PUB" AS
/*$Header: ibyckprb.pls 120.64.12010000.16 2010/04/01 10:53:54 asarada ship $*/

 --
 -- Declare global variables
 --
 G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBY_CHECKNUMBER_PUB';
 G_CURRENT_RUNTIME_LEVEL      CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;

 --
 -- List of instruction statuses that are used / set in this
 -- module (payment instruction creation flow).
 --
 -- This module will only process payment instructions that are in
 -- 'created' status.
 --
 -- If there were any problems when numbering the payment instructions
 -- this module will set the status of the payment instruction to
 -- 'printing deferred' status and the check printing module has to
 -- be called again on this payment instruction.
 --
 -- This module will never set the status of a payment instruction to
 -- 'creation error' because that can only be done by the PICP.
 --
 INS_STATUS_CREATED         CONSTANT VARCHAR2(100) := 'CREATED';
 INS_STATUS_PRINT_DEFR      CONSTANT VARCHAR2(100) := 'PRINTING_DEFERRED';
 INS_STATUS_READY_TO_PRINT  CONSTANT VARCHAR2(100) :=
                                         'CREATED_READY_FOR_PRINTING';
 INS_STATUS_READY_TO_FORMAT CONSTANT VARCHAR2(100) :=
                                         'CREATED_READY_FOR_FORMATTING';

 --
 -- List of payment statuses that are used / set in this
 -- module (payment instruction creation flow).
 --
 PMT_STATUS_CREATED        CONSTANT VARCHAR2(100) := 'CREATED';
 PMT_STATUS_INS_CREATED    CONSTANT VARCHAR2(100) := 'INSTRUCTION_CREATED';

 --
 -- List of document statuses that are used / set in this
 -- module (payment instruction creation flow).
 --
 DOC_STATUS_PAY_CREATED    CONSTANT VARCHAR2(100) := 'PAYMENT_CREATED';

 -- Transaction types (for inserting into IBY_TRANSACTION_ERRORS table)
 TRXN_TYPE_INSTR  CONSTANT VARCHAR2(100) := 'INSTRUCTION';
 TRXN_TYPE_PMT    CONSTANT VARCHAR2(100) := 'PAYMENT';

 --
 -- List of process ciompletion statuses that are returned to
 -- the caller after completing this flow.
 --
 PROCESS_STATUS_SUCCESS   CONSTANT VARCHAR2(100) := 'SUCCESS';
 PROCESS_STATUS_FAILED    CONSTANT VARCHAR2(100) := 'FAILURE';

 --
 -- Forward declarations
 --
 PROCEDURE print_debuginfo(
              p_module      IN VARCHAR2,
              p_debug_text  IN VARCHAR2,
              p_debug_level IN VARCHAR2 DEFAULT FND_LOG.LEVEL_STATEMENT
              );

/*--------------------------------------------------------------------
 | NAME:
 |     performCheckNumbering
 |
 | PURPOSE:
 |     Prints the given payment instruction on the provided paper stock
 |     (payment document).
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
 |
 *---------------------------------------------------------------------*/
 PROCEDURE performCheckNumbering(
             p_instruction_id           IN IBY_PAY_INSTRUCTIONS_ALL.
                                               payment_instruction_id%TYPE,
             p_pmt_document_id          IN CE_PAYMENT_DOCUMENTS.
                                               payment_document_id%TYPE,
             p_user_assgn_num           IN IBY_PAYMENTS_ALL.
                                               paper_document_number%TYPE,
             x_return_status            IN OUT NOCOPY VARCHAR2,
             x_return_message           IN OUT NOCOPY VARCHAR2,
             x_msg_count                IN OUT NOCOPY NUMBER,
             x_msg_data                 IN OUT NOCOPY VARCHAR2
             )
 IS

 l_module_name       VARCHAR2(200) := G_PKG_NAME || '.performCheckNumbering';

 l_ret_status        NUMBER := -1;
 l_ret_message       VARCHAR2(2000);

 l_pmtInstrRec       IBY_PAY_INSTRUCTIONS_ALL%ROWTYPE;

 l_pmtsInInstrRec    IBY_PAYINSTR_PUB.pmtsInPmtInstrRecType;
 l_pmtsInInstrTab    IBY_PAYINSTR_PUB.pmtsInpmtInstrTabType;

 l_error_code        VARCHAR2(500);

 l_instruction_id    NUMBER(15);

 /*
  * These two are used for holding dummy payments and dummy
  * documents that are associated with setup and overflow
  * documents.
  */
 l_dummy_pmts_tab    IBY_PAYGROUP_PUB.paymentTabType;
 l_dummy_docs_tab    docsTabType;
 l_overflow_docs_tab overflowDocsTabType;

 l_instr_err_tab     IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_err_tokens_tab    IBY_VALIDATIONSETS_PUB.trxnErrTokenTabType;

 l_pkg_name          CONSTANT VARCHAR2(100) := 'AP_AWT_CALLOUT_PKG';

 l_callout_name      VARCHAR2(500);
 l_stmt              VARCHAR2(1000);

 /* used in invocation of callout procedure */
 l_api_version       CONSTANT NUMBER := 1.0;
 l_msg_count         NUMBER;
 l_msg_data          VARCHAR2(2000);

 /*
  * Cursor to pick up the payments (and related fields)
  * of a given payment instruction.
  */
 CURSOR c_pmts_in_instruction (p_instr_id IBY_PAY_INSTRUCTIONS_ALL.
                                              payment_instruction_id%TYPE)
 IS
 SELECT
     pmt.payment_id,
     instr.payment_instruction_id,
     pmt.payment_amount,
     pmt.payment_currency_code,
     pmt.payment_status,
     pmt.payment_profile_id,
     prof.processing_type,
     -1, /* pmt_details_len */
     -1, /* document_count */
     pmt.separate_remit_advice_req_flag,
     pmt.paper_document_number
 FROM
     IBY_PAYMENTS_ALL pmt,
     IBY_PAY_INSTRUCTIONS_ALL instr,
     IBY_PAYMENT_PROFILES prof
 WHERE
     instr.payment_instruction_id = p_instr_id AND
     instr.payment_instruction_id = pmt.payment_instruction_id AND
     instr.payment_profile_id     = pmt.payment_profile_id AND
     instr.payment_profile_id     = prof.payment_profile_id AND
     pmt.payment_status           = PMT_STATUS_INS_CREATED

 /*
  * Fix for bug 5198523:
  *
  * Ordering the payments by payment reference number
  * guarantees that the paper document numbers provided
  * to these payments downstream also follow the same
  * order.
  */
 ORDER BY pmt.payment_reference_number ASC
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

	     print_debuginfo(l_module_name, 'Provided payment instruction id: '
	         || p_instruction_id);

     END IF;
     /*
      * Pick up all attributes of the given payment instruction
      * from the IBY_PAY_INSTRUCTIONS_ALL table.
      */
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
             l_pmtInstrRec.payment_instruction_id,
             l_pmtInstrRec.payment_profile_id,
             l_pmtInstrRec.process_type,
             l_pmtInstrRec.payment_instruction_status,
             l_pmtInstrRec.payments_complete_code,
             l_pmtInstrRec.generate_sep_remit_advice_flag,
             l_pmtInstrRec.remittance_advice_created_flag,
             l_pmtInstrRec.regulatory_report_created_flag,
             l_pmtInstrRec.bill_payable_flag,
             l_pmtInstrRec.legal_entity_id,
             l_pmtInstrRec.payment_count,
             l_pmtInstrRec.positive_pay_file_created_flag,
             l_pmtInstrRec.print_instruction_immed_flag,
             l_pmtInstrRec.transmit_instr_immed_flag,
             l_pmtInstrRec.created_by,
             l_pmtInstrRec.creation_date,
             l_pmtInstrRec.last_updated_by,
             l_pmtInstrRec.last_update_date,
             l_pmtInstrRec.last_update_login,
             l_pmtInstrRec.object_version_number,
             l_pmtInstrRec.internal_bank_account_id,
             l_pmtInstrRec.pay_admin_assigned_ref_code,
             l_pmtInstrRec.transmission_date,
             l_pmtInstrRec.acknowledgement_date,
             l_pmtInstrRec.comments,
             l_pmtInstrRec.bank_assigned_ref_code,
             l_pmtInstrRec.org_id,
             l_pmtInstrRec.org_type,
             l_pmtInstrRec.payment_date,
             l_pmtInstrRec.payment_currency_code,
             l_pmtInstrRec.payment_service_request_id,
             l_pmtInstrRec.payment_function,
             l_pmtInstrRec.payment_reason_code,
             l_pmtInstrRec.rfc_identifier,
             l_pmtInstrRec.payment_reason_comments,
             l_pmtInstrRec.payment_document_id,
             l_pmtInstrRec.printer_name,
             l_pmtInstrRec.attribute_category,
             l_pmtInstrRec.attribute1,
             l_pmtInstrRec.attribute2,
             l_pmtInstrRec.attribute3,
             l_pmtInstrRec.attribute4,
             l_pmtInstrRec.attribute5,
             l_pmtInstrRec.attribute6,
             l_pmtInstrRec.attribute7,
             l_pmtInstrRec.attribute8,
             l_pmtInstrRec.attribute9,
             l_pmtInstrRec.attribute10,
             l_pmtInstrRec.attribute11,
             l_pmtInstrRec.attribute12,
             l_pmtInstrRec.attribute13,
             l_pmtInstrRec.attribute14,
             l_pmtInstrRec.attribute15
         FROM
             IBY_PAY_INSTRUCTIONS_ALL
         WHERE
             payment_instruction_id = p_instruction_id
             ;

     EXCEPTION

         WHEN OTHERS THEN
         /*
          * This error condition will be handled below.
          */
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Exception occured when '
	             || 'retrieving details of payment instruction '
	             || p_instruction_id
	             );
	         print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	         print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);

         END IF;
     END;

     IF (l_pmtInstrRec.payment_instruction_id IS NULL) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Provided payment instruction id '
	             || p_instruction_id
	             || ' not found in IBY_PAY_INSTRUCTIONS_ALL table. '
	             || 'Processing cannot continue. Aborting program.'
	             );

         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;

         l_error_code := 'IBY_INS_NOT_FOUND';
         FND_MESSAGE.set_name('IBY', l_error_code);

         FND_MESSAGE.SET_TOKEN('INS_ID',
             p_instruction_id,
             FALSE);

         x_return_message := FND_MESSAGE.get;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     END IF;

     /*
      * Only proceed if the payment instruction is in the
      * 'created' status.
      */
     IF (l_pmtInstrRec.payment_instruction_status
             <> INS_STATUS_CREATED                    AND
         l_pmtInstrRec.payment_instruction_status
             <> INS_STATUS_READY_TO_PRINT             AND
         l_pmtInstrRec.payment_instruction_status
             <> INS_STATUS_READY_TO_FORMAT
        ) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Payment instruction id '
	             || p_instruction_id
	             || ' has status '
	             || l_pmtInstrRec.payment_instruction_status
	             || '. Payment instruction must be in '
	             || INS_STATUS_READY_TO_PRINT
	             || ' or '
	             || INS_STATUS_READY_TO_FORMAT
	             || ' for check numbering. '
	             || 'Processing cannot continue. Aborting program.'
	             );

         END IF;
         x_return_status  := FND_API.G_RET_STS_ERROR;

         l_error_code := 'IBY_INS_NOT_NUM_STATUS';
         FND_MESSAGE.set_name('IBY', l_error_code);

         FND_MESSAGE.SET_TOKEN('INS_ID',
             p_instruction_id,
             FALSE);

         FND_MESSAGE.SET_TOKEN('BAD_STATUS',
             l_pmtInstrRec.payment_instruction_status,
             FALSE);

         FND_MESSAGE.SET_TOKEN('GOOD_STATUS1',
             INS_STATUS_READY_TO_PRINT,
             FALSE);

         FND_MESSAGE.SET_TOKEN('GOOD_STATUS2',
             INS_STATUS_READY_TO_FORMAT,
             FALSE);

         FND_MESSAGE.SET_TOKEN('GOOD_STATUS3',
             INS_STATUS_CREATED,
             FALSE);

         x_return_message := FND_MESSAGE.get;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     ELSE

         /*
          * If we reached here, it means that the given payment
          * instruction is in an appropriate status for numbering.
          *
          * SPECIAL CASE:
          *
          * Check for a special case, where this payment instruction
          * might have already been numbered earlier, but the format
          * program crashed or raised an exception. In that case, the
          * status of the payment instruction would not have been
          * changed.
          *
          * Such a payment instruction would re-enter the check
          * numbering flow, but we must not renumber this instruction
          * because we have already numbered it.
          *
          * If the specified payment document is already locked by the
          * given payment instruction, then we know that this payment
          * instruction has already been numbered and is re-entering
          * the check numbering flow.
          *
          * Simply return success and exit.
          */
         BEGIN

             SELECT
                 ce.payment_instruction_id
             INTO
                 l_instruction_id
             FROM
                 CE_PAYMENT_DOCUMENTS ce
             WHERE
                 ce.payment_document_id = p_pmt_document_id
             ;

             IF (l_instruction_id = p_instruction_id) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Payment instruction '
	                     || p_instruction_id
	                     || ' has already been numbered. Returning '
	                     || 'success response ..'
	                     );

                 END IF;
                 x_return_status  := FND_API.G_RET_STS_SUCCESS;
                 x_return_message := 'SUCCESS';

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'EXIT');

                 END IF;
                 RETURN;

             ELSE

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Payment instruction '
	                     || p_instruction_id
	                     || ' has not been previously numbered.'
	                     );

                 END IF;
             END IF;


         EXCEPTION
             WHEN OTHERS THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Exception occured when '
	                 || 'getting details of payment document id '
	                 || p_pmt_document_id
	                 || ' from CE_PAYMENT_DOCUMENTS table.',
	                 FND_LOG.LEVEL_UNEXPECTED
	                 );

	             print_debuginfo(l_module_name, 'SQL code: '
	                 || SQLCODE, FND_LOG.LEVEL_UNEXPECTED);
	             print_debuginfo(l_module_name, 'SQL err msg: '
	                 || SQLERRM, FND_LOG.LEVEL_UNEXPECTED);

             END IF;
             /*
              * Propogate exception to caller.
              */
             RAISE;

         END;

     END IF;

     /*
      * Pick up all payments of the given payment instruction
      * from the IBY_PAYMENTS_ALL table.
      */
     OPEN  c_pmts_in_instruction(p_instruction_id);
     FETCH c_pmts_in_instruction BULK COLLECT INTO l_pmtsInInstrTab;
     CLOSE c_pmts_in_instruction;

     IF (l_pmtsInInstrTab.COUNT = 0) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Cannot retrieve payments '
	             || 'and profile details for the provided payment '
	             || 'instruction id. Processing cannot continue. '
	             || 'Aborting program.'
	             );

         END IF;
         x_return_status  := FND_API.G_RET_STS_ERROR;

         l_error_code := 'IBY_INS_PMTS_NOT_FOUND';
         FND_MESSAGE.set_name('IBY', l_error_code);

         FND_MESSAGE.SET_TOKEN('INS_ID',
             p_instruction_id,
             FALSE);

         x_return_message := FND_MESSAGE.get;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     END IF;

     /* populate the document count associated with each payment */
       /* removed the call to populateDocumentCount, alternatively in
        * processPaperPayments() API, the count of document is got through
        * a query on iby_docs_payable_all  - AtT Build pmts perf issue
        */
   --  populateDocumentCount(l_pmtsInInstrTab);

     /*
      * Calculate the number of setup and overflow documents for
      * this payment instruction.
      *
      * Then provide all the payments with check numbers.
      */
     processPaperPayments(
         p_pmt_document_id, p_user_assgn_num, l_pmtInstrRec,
         l_pmtsInInstrTab, l_dummy_pmts_tab, l_dummy_docs_tab,
         l_overflow_docs_tab, l_instr_err_tab, l_err_tokens_tab,
         l_ret_status, l_ret_message, x_msg_count, x_msg_data);

     /*
      * Now, that we have completed check printing, update
      * the payments of the payment instruction with check
      * numbers.
      *
      * Insert the created dummy documents (setup and overflow
      * documents) into the database.
      *
      * Finally, change the status of the payment instruction
      * to 'submitted for printing'.
      */
     IF (l_ret_status = 0) THEN

         performDBUpdates(p_instruction_id,
             l_pmtsInInstrTab, l_dummy_pmts_tab,
             l_dummy_docs_tab, l_overflow_docs_tab,
             l_instr_err_tab, l_err_tokens_tab);

     ELSE

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Check numbering process '
	             || 'did not succeed. Raising exception ..',
	             FND_LOG.LEVEL_UNEXPECTED
	             );

         END IF;
         /*
          * Raise an exception.
          */
         APP_EXCEPTION.RAISE_EXCEPTION;

     END IF;

     /*
      * If we reached here, it means that the payments of the
      * payment instruction have been numbered successfully
      * and that the status of the payment instruction is now
      * 'CREATED_READY_FOR_PRINTING' | 'CREATED_READY_FOR_FORMATTING'.
      *
      * After check numbering has been completed, invoke the withholding
      * certificates hook. This is relevant only for AP, but we will
      * call this hook blindly and let AP figure out whether there
      * are any payments of interest for them.
      */
     l_callout_name := l_pkg_name || '.' || 'zx_witholdingCertificatesHook';

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Attempting to call hook: '
	         || l_callout_name);

     END IF;
     l_stmt := 'CALL '|| l_callout_name || '(:1, :2, :3, :4, :5, :6, :7, :8)';

     BEGIN

         EXECUTE IMMEDIATE
             (l_stmt)
         USING
             IN  p_instruction_id,
             IN  'GENERATE',
             IN  l_api_version,
             IN  FND_API.G_FALSE,
             IN  FND_API.G_FALSE,
             OUT x_return_status,
             OUT l_msg_count,
             OUT l_msg_data
         ;

         /*
          * If the called procedure did not return success,
          * raise an exception.
          */
         IF (x_return_status IS NULL OR
             x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Fatal: External app callout '''
	                 || l_callout_name
	                 || ''', returned failure status - '
	                 || x_return_status
	                 || '. Raising exception.',
	                 FND_LOG.LEVEL_UNEXPECTED
	                 );

             END IF;
             l_error_code := 'IBY_INS_AWT_CERT_HOOK_FAILED';
             FND_MESSAGE.set_name('IBY', l_error_code);

             l_ret_message := FND_MESSAGE.get;

             APP_EXCEPTION.RAISE_EXCEPTION;

         END IF;

     EXCEPTION

         WHEN PROCEDURE_NOT_IMPLEMENTED THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Callout "' || l_callout_name
	                 || '" not implemented by calling app - AP'
	                 );

	             print_debuginfo(l_module_name, 'Skipping hook call.');

             END IF;
         WHEN OTHERS THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Fatal: External app callout '''
	                 || l_callout_name
	                 || ''', generated exception.',
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
     END;

     x_return_status  := FND_API.G_RET_STS_SUCCESS;
     x_return_message := 'SUCCESS';

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Returning success response ..');

	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 EXCEPTION
     WHEN OTHERS THEN
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Exception occured when '
	         || 'performing payment numbering. Payment numbering '
	         || 'process will be aborted.'
	         );
	     print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	     print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);

     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_return_message := l_ret_message;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END performCheckNumbering;

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
     x_pmtsInPmtInstrTab  IN OUT NOCOPY IBY_PAYINSTR_PUB.pmtsInpmtInstrTabType
     )
 IS

 l_module_name VARCHAR2(200) := G_PKG_NAME || '.populateDocumentCount';
 l_docs_in_pmt_count docsInPmtCountTabType;

 CURSOR c_document_count
 IS
 SELECT
     count(*),
     payment_id
 FROM
     IBY_DOCS_PAYABLE_ALL
 WHERE
     document_status = DOC_STATUS_PAY_CREATED
 GROUP BY
     payment_id
 ;

 BEGIN

     OPEN  c_document_count;
     FETCH c_document_count BULK COLLECT INTO l_docs_in_pmt_count;
     CLOSE c_document_count;

     IF (l_docs_in_pmt_count.COUNT = 0) THEN

         /*
          * Normally this shouldn't happen.
          */
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'No documents payable '
	             || 'were found in ''payments created'' status '
	             || 'though created payments exist. '
	             || 'Possible data corruption. Aborting ..',
	             FND_LOG.LEVEL_UNEXPECTED
	             );

         END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;

     END IF;

     FOR i in x_pmtsInPmtInstrTab.FIRST .. x_pmtsInPmtInstrTab.LAST LOOP

         FOR j in l_docs_in_pmt_count.FIRST .. l_docs_in_pmt_count.LAST LOOP

             IF (x_pmtsInPmtInstrTab(i).payment_id = l_docs_in_pmt_count(j).
                 payment_id) THEN

                 x_pmtsInPmtInstrTab(i).document_count :=
                     l_docs_in_pmt_count(j).doc_count;

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Num docs for payment: '
	                     || x_pmtsInPmtInstrTab(i).payment_id
	                     || ' is: '
	                     || x_pmtsInPmtInstrTab(i).document_count
	                     );

                 END IF;
                 /* exit inner loop */
                 EXIT;

             END IF;

         END LOOP;

     END LOOP;

 END populateDocumentCount;

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
     p_payInstrTab   IN IBY_PAYINSTR_PUB.pmtInstrTabType
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
             payment_instruction_status = p_payInstrTab(i).
                                              payment_instruction_status
         WHERE
             payment_instruction_id = p_payInstrTab(i).payment_instruction_id;
     END LOOP;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END updatePaymentInstructions;

/*--------------------------------------------------------------------
 | NAME:
 |     insertPaperDocuments
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
 PROCEDURE insertPaperDocuments(
     p_paperPmtsTab      IN IBY_PAYGROUP_PUB.paymentTabType,
     p_setupDocsTab      IN docsTabType,
     p_overflowDocsTab   IN overflowDocsTabType
     )
 IS
 l_setup_pmts_tab     IBY_PAYGROUP_PUB.paymentTabType;
 l_overflow_pmts_tab  IBY_PAYGROUP_PUB.paymentTabType;

 l_module_name VARCHAR2(200) := G_PKG_NAME || '.insertPaperDocuments';
 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     IF (p_paperPmtsTab.COUNT = 0) THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'No paper documents were '
	             || 'provided for insert. Exiting ..'
	             );
	         print_debuginfo(l_module_name, 'EXIT');
         END IF;
         RETURN;
     END IF;

     /*
      * Split the p_paperPmtsTab to get the setup payments
      * and overflow payments into separate data structures.
      */
     splitPaymentsByType(p_paperPmtsTab, l_setup_pmts_tab,
         l_overflow_pmts_tab);

     /*
      * Handle setup payments.
      */
     IF (l_setup_pmts_tab.COUNT <> 0) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Inserting '
	             || l_setup_pmts_tab.COUNT
	             || ' setup payments.'
	             );

         END IF;
         /* setup payments can be bulk inserted */
         FORALL i in l_setup_pmts_tab.FIRST..l_setup_pmts_tab.LAST
             INSERT INTO IBY_PAYMENTS_ALL VALUES l_setup_pmts_tab(i);

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Inserting '
	             || p_setupDocsTab.COUNT
	             || ' setup documents.'
	             );

         END IF;
         /* documents related to setup payments can be bulk inserted */
         FORALL i in p_setupDocsTab.FIRST..p_setupDocsTab.LAST
             INSERT INTO IBY_DOCS_PAYABLE_ALL VALUES p_setupDocsTab(i);

     END IF;

     /*
      * Handle overflow payments.
      */
     IF (l_overflow_pmts_tab.COUNT <> 0) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Inserting '
	             || l_overflow_pmts_tab.COUNT
	             || ' overflow payments.'
	             );

         END IF;
         /* overflow payments can be bulk inserted */
         FORALL i in l_overflow_pmts_tab.FIRST..l_overflow_pmts_tab.LAST
             INSERT INTO IBY_PAYMENTS_ALL VALUES l_overflow_pmts_tab(i);


         /*
          * Fix for bug 6765314:
          *
          * The overflow payment is a dummy payment that is related
          * to a real payment. Copy the important attributes of the
          * real payment onto the original payment. This will ensure
          * that when the overflow payment is printed, it contains
          * the payee name, payer name etc.
          *
          * The external bank account id field on the overflow
          * payment actually contains the payment id of the
          * real payment. See KLUDGE in performSpecialPaperHandling()
          * for more information on this.
          */
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Updating '
	             || 'overflow payments with attributes '
	             || 'from related real payments.'
	             );

         END IF;
         FOR i in l_overflow_pmts_tab.FIRST..l_overflow_pmts_tab.LAST LOOP

             UPDATE
                 iby_payments_all overflow
             SET
                     (
                     overflow.payment_method_code,
                     overflow.internal_bank_account_id,
                     overflow.org_id,
                     overflow.org_type,
                     overflow.legal_entity_id,
                     overflow.delivery_channel_code,
                     overflow.ext_payee_id,
                     overflow.payment_profile_id,
                     overflow.payee_party_id,
                     overflow.party_site_id,
                     overflow.supplier_site_id,
                     overflow.payment_reason_code,
                     overflow.payment_reason_comments,
                     overflow.payment_date,
                     overflow.remittance_message1,
                     overflow.remittance_message2,
                     overflow.remittance_message3,
                     overflow.payment_due_date,
                     overflow.beneficiary_party,
                     overflow.remit_to_location_id,
                     overflow.payee_name,
                     overflow.payee_address1,
                     overflow.payee_address2,
                     overflow.payee_address3,
                     overflow.payee_address4,
                     overflow.payee_city,
                     overflow.payee_postal_code,
                     overflow.payee_state,
                     overflow.payee_province,
                     overflow.payee_county,
                     overflow.payee_country,
                     overflow.org_name,
                     overflow.payer_legal_entity_name,
                     overflow.payee_party_name,
                     overflow.payer_party_site_name,
                     overflow.payee_address_concat,
                     overflow.beneficiary_name,
                     overflow.payer_party_number,
                     overflow.payee_party_number,
                     overflow.payee_alternate_name,
                     overflow.payee_site_alternate_name,
                     overflow.payee_supplier_number,
                     overflow.payee_first_party_reference,
                     overflow.address_source,
                     overflow.employee_address_code,
                     overflow.employee_person_id,
                     overflow.employee_payment_flag,
                     overflow.employee_address_id,
                     overflow.payer_party_id,
                     overflow.payer_location_id,
                     overflow.payee_supplier_id,
                     overflow.payee_supplier_site_name,
                     overflow.payee_supplier_site_alt_name
                     ) =
                 (
                 SELECT
                     real.payment_method_code,
                     real.internal_bank_account_id,
                     real.org_id,
                     real.org_type,
                     real.legal_entity_id,
                     real.delivery_channel_code,
                     real.ext_payee_id,
                     real.payment_profile_id,
                     real.payee_party_id,
                     real.party_site_id,
                     real.supplier_site_id,
                     real.payment_reason_code,
                     real.payment_reason_comments,
                     real.payment_date,
                     real.remittance_message1,
                     real.remittance_message2,
                     real.remittance_message3,
                     real.payment_due_date,
                     real.beneficiary_party,
                     real.remit_to_location_id,
                     real.payee_name,
                     real.payee_address1,
                     real.payee_address2,
                     real.payee_address3,
                     real.payee_address4,
                     real.payee_city,
                     real.payee_postal_code,
                     real.payee_state,
                     real.payee_province,
                     real.payee_county,
                     real.payee_country,
                     real.org_name,
                     real.payer_legal_entity_name,
                     real.payee_party_name,
                     real.payer_party_site_name,
                     real.payee_address_concat,
                     real.beneficiary_name,
                     real.payer_party_number,
                     real.payee_party_number,
                     real.payee_alternate_name,
                     real.payee_site_alternate_name,
                     real.payee_supplier_number,
                     real.payee_first_party_reference,
                     real.address_source,
                     real.employee_address_code,
                     real.employee_person_id,
                     real.employee_payment_flag,
                     real.employee_address_id,
                     real.payer_party_id,
                     real.payer_location_id,
                     real.payee_supplier_id,
                     real.payee_supplier_site_name,
                     real.payee_supplier_site_alt_name
                 FROM
                     iby_payments_all real
                 WHERE
                     real.payment_id = overflow.external_bank_account_id
                 )
             WHERE overflow.payment_id = l_overflow_pmts_tab(i).payment_id
             ;
         END LOOP;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Updating '
	             || p_overflowDocsTab.COUNT
	             || ' overflow documents.'
	             );

         END IF;
         /*
          * For overflow payments, the documents are already
          * available in the IBY_DOCS_PAYABLE_ALL table. The
          * formatting payment id on these documents needs
          * to be updated to account for the overflow payments
          * (1 overflow payment = 1 printed void check).
          */
         FOR i in p_overflowDocsTab.FIRST..p_overflowDocsTab.LAST LOOP

             UPDATE
                 IBY_DOCS_PAYABLE_ALL
             SET
                 formatting_payment_id =
                     p_overflowDocsTab(i).format_payment_id
             WHERE
                 document_payable_id = p_overflowDocsTab(i).doc_id;

         END LOOP;

     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END insertPaperDocuments;

/*--------------------------------------------------------------------
 | NAME:
 |     splitPaymentsByType
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
 PROCEDURE splitPaymentsByType(
     p_paperPmtsTab      IN IBY_PAYGROUP_PUB.paymentTabType,
     x_setupPmtsTab      IN OUT NOCOPY IBY_PAYGROUP_PUB.paymentTabType,
     x_overflowPmtsTab   IN OUT NOCOPY IBY_PAYGROUP_PUB.paymentTabType
     )
 IS

 l_module_name VARCHAR2(200) := G_PKG_NAME || '.splitPaymentsByType';

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     IF (p_paperPmtsTab.COUNT = 0) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'No payments to split. Exiting ..');
	         print_debuginfo(l_module_name, 'EXIT');
         END IF;
         RETURN;

     END IF;

     FOR i in p_paperPmtsTab.FIRST..p_paperPmtsTab.LAST LOOP

         /* setup payments */
         IF (p_paperPmtsTab(i).payment_status = 'VOID_BY_SETUP') THEN

             x_setupPmtsTab(x_setupPmtsTab.COUNT + 1)
                 := p_paperPmtsTab(i);

         /* overflow payments */
         ELSIF (p_paperPmtsTab(i).payment_status = 'VOID_BY_OVERFLOW') THEN

             x_overflowPmtsTab(x_overflowPmtsTab.COUNT + 1)
                 := p_paperPmtsTab(i);

         /* normally, shouldn't come here */
         ELSE
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Ignoring payment with '
	                 || 'status '
	                 || p_paperPmtsTab(i).payment_status
	                 );
             END IF;
         END IF;

     END LOOP;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Created '
	         || x_setupPmtsTab.COUNT
	         || ' setup payments and '
	         || x_overflowPmtsTab.COUNT
	         || ' overflow payments from '
	         || p_paperPmtsTab.COUNT
	         || ' provided payments.'
	         );

	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END splitPaymentsByType;

/*--------------------------------------------------------------------
 | NAME:
 |     performDBUpdates
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
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE performDBUpdates(
     p_instruction_id    IN IBY_PAY_INSTRUCTIONS_ALL.
                                payment_instruction_id%TYPE,
     x_pmtsInPmtInstrTab IN OUT NOCOPY IBY_PAYINSTR_PUB.pmtsInpmtInstrTabType,
     x_dummyPaperPmtsTab IN OUT NOCOPY IBY_PAYGROUP_PUB.paymentTabType,
     x_setupDocsTab      IN OUT NOCOPY docsTabType,
     x_overflowDocsTab   IN OUT NOCOPY overflowDocsTabType,
     x_insErrorsTab      IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
     x_insTokenTab       IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.
                                           trxnErrTokenTabType
     )
 IS
 l_module_name      VARCHAR2(200)  := G_PKG_NAME || '.performDBUpdates';

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     /*
      * Update the payments table by providing a check number to
      * each payment.
      */
     updatePmtsWithCheckNumbers(x_pmtsInPmtInstrTab);

     /*
      * Insert the setup and overflow documents that have been
      * created as part of paper payments handing.
      */
     insertPaperDocuments(x_dummyPaperPmtsTab, x_setupDocsTab,
         x_overflowDocsTab);

     /*
      * Insert any payment instruction errors into
      * IBY_TRANSACTION_ERRORS table.
      */
     IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N', x_insErrorsTab,
         x_insTokenTab);

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
 |     processPaperPayments
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
 PROCEDURE processPaperPayments(
     p_pmt_document_id   IN CE_PAYMENT_DOCUMENTS.payment_document_id%TYPE,
     p_user_assgn_num    IN IBY_PAYMENTS_ALL.paper_document_number%TYPE,
     x_pmtInstrRec       IN OUT NOCOPY IBY_PAY_INSTRUCTIONS_ALL%ROWTYPE,
     x_pmtsInPmtInstrTab IN OUT NOCOPY IBY_PAYINSTR_PUB.pmtsInpmtInstrTabType,
     x_dummyPaperPmtsTab IN OUT NOCOPY IBY_PAYGROUP_PUB.paymentTabType,
     x_setupDocsTab      IN OUT NOCOPY docsTabType,
     x_overflowDocsTab   IN OUT NOCOPY overflowDocsTabType,
     x_instrErrorTab     IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
     x_insTokenTab       IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.
                                           trxnErrTokenTabType,
     x_return_status     IN OUT NOCOPY NUMBER,
     x_return_message    IN OUT NOCOPY VARCHAR2,
     x_msg_count         IN OUT NOCOPY NUMBER,
     x_msg_data          IN OUT NOCOPY VARCHAR2
     )
 IS

 l_module_name       VARCHAR2(200) := G_PKG_NAME
                                          || '.processPaperPayments';
 l_processing_type   VARCHAR2(100); -- PRINTED | ELECTRONIC
 l_num_printed_docs  NUMBER(15);
 l_paper_stock_rec   paperStockRecType;
 l_paper_stocks_tab  paperStocksTabType;
 l_docs_count        NUMBER;

 l_error_code        VARCHAR2(3000);

 l_paper_special_docs_rec    paperPmtsSpecialDocsRecType;
 l_paper_special_docs_tab    paperPmtsSpecialDocsTabType;

 l_pmtsInPmtInstrRec IBY_PAYINSTR_PUB.pmtsInpmtInstrRecType;

 CURSOR c_paper_stock (p_pmt_doc_id IN CE_PAYMENT_DOCUMENTS.
                                       payment_document_id%TYPE)
 IS
 SELECT
        payment_document_id,
        payment_document_name,
        NVL(number_of_setup_documents, 0),
        DECODE(attached_remittance_stub_flag,'Y',number_of_lines_per_remit_stub,NULL) number_of_lines_per_remit_stub
 FROM
        CE_PAYMENT_DOCUMENTS
 WHERE
        payment_document_id = p_pmt_doc_id
 ;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     OPEN  c_paper_stock (p_pmt_document_id);
     FETCH c_paper_stock BULK COLLECT INTO l_paper_stocks_tab;
     CLOSE c_paper_stock;

     /*
      * There should be exactly one payment document linked
      * to a particular payment document name.
      */
     IF (l_paper_stocks_tab.COUNT <> 1) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Unable to get matching payment '
	             || 'document from CE_PAYMENT_DOCUMENTS for payment '
	             || 'document id: '
	             || p_pmt_document_id
	             || '. Number of payment documents retrieved: '
	             || l_paper_stocks_tab.COUNT
	             );

         END IF;
         x_return_status := -1;

         l_error_code := 'IBY_INS_NO_PMT_DOC';
         FND_MESSAGE.set_name('IBY', l_error_code);

         FND_MESSAGE.SET_TOKEN('PMT_DOC_ID',
             p_pmt_document_id,
             FALSE);

         x_return_message := FND_MESSAGE.get;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');
         END IF;
         RETURN;

     END IF;

     /*
      * Since, payment instructions are grouped by
      * profile id, they are implicitly grouped
      * by processing type as well.
      *
      * pmtsInpmtInstrTabType will have multiple records for
      * a payment instruction (one record for each payment
      * in the instruction). All these payments will have the
      * same profile id, and the same procesing type
      * (because only payments with a specific profile id wil
      * be grouped into a payment instruction).
      *
      * Therefore, in order to determine the processing type
      * of a payment instruction, we simply need to retrieve
      * the processing type from any payment of that
      * instruction. We do this by retrieving the processing
      * type of the first payment of that instruction.
      */
     l_pmtsInPmtInstrRec := x_pmtsInPmtInstrTab(x_pmtsInPmtInstrTab.FIRST);
     l_processing_type   := l_pmtsInPmtInstrRec.processing_type;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'For payment instruction '
	         || x_pmtInstrRec.payment_instruction_id
	         || ', profile id: '
	         || x_pmtInstrRec.payment_profile_id
	         || ', processing type: '
	         || l_processing_type
	         || ', # pmts: '
	         || x_pmtInstrRec.payment_count
	         );

     END IF;
     /*
      * If the processing type for this instruction is set
      * to 'PAPER', it means that this payment instruction
      * will be physically printed onto paper.
      *
      * Perform paper payment specific processing such as
      * calculating setup and overflow documents.
      */
     IF (l_processing_type = 'PRINTED') THEN

         /* Get the attributes of the paper stock */
         /*
          * There will only be one paper stock linked to
          * a particular payment document name, so we can
          * simply take the first record from the fetched
          * paper stocks table.
          */
         l_paper_stock_rec := l_paper_stocks_tab(1);

         IF (l_paper_stock_rec.doc_id IS NOT NULL) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Paper stock matching '
	                 || 'profile id '
	                 || x_pmtInstrRec.payment_profile_id
	                 || ' has following attributes - Name: '
	                 || l_paper_stock_rec.doc_name
	                 || ', num setup docs: '
	                 || l_paper_stock_rec.num_setup_docs
	                 || ', num lines per stub: '
	                 || l_paper_stock_rec.num_lines_per_stub
	                 );

             END IF;
         ELSE

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Fatal: No paper stock '
	                 || 'linked to profile id '
	                 || x_pmtInstrRec.payment_profile_id
	                 || '. Payment instruction creation cannot continue. '
	                 || 'Aborting program ..'
	                 );

             END IF;
             x_return_status := -1;

             l_error_code := 'IBY_INS_NO_PAPER_STOCK';
             FND_MESSAGE.set_name('IBY', l_error_code);

             FND_MESSAGE.SET_TOKEN('INS_ID',
                 x_pmtInstrRec.payment_instruction_id,
                 FALSE);

             x_return_message := FND_MESSAGE.get;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'EXIT');
             END IF;
             RETURN;

         END IF;

         /*
          * If we reached here it means paper stock
          * attributes were retrieved successfully
          * for the profile on the instruction.
          */

         /*
          * Loop through all the payments for this
          * payment instruction, processing them one-by-one.
          */
         FOR j in x_pmtsInPmtInstrTab.FIRST .. x_pmtsInPmtInstrTab.LAST
             LOOP

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Processing payment '
	                 || x_pmtsInPmtInstrTab(j).payment_id
	                 || ' for instruction '
	                 || x_pmtInstrRec.payment_instruction_id
	                 || ' ..'
	                 );
             END IF;
         /* Removing the call to getDocumentCount, rather accessing
          * IBY_DOCS_PAYABLE_ALL table to get the count of the
 	  * documents
 	  */
           /*  l_docs_count := getDocumentCountForPayment(
                                 x_pmtsInPmtInstrTab(j).payment_id,
                                 x_pmtsInPmtInstrTab
                                 );
	    */

	            SELECT
 	                 COUNT(*)
		    INTO
 	                 x_pmtsInPmtInstrTab(j).document_count
 	            FROM
 	                 IBY_DOCS_PAYABLE_ALL
 	            WHERE
 	                 payment_id =  x_pmtsInPmtInstrTab(j).payment_id
 	            AND
 	                 document_status = DOC_STATUS_PAY_CREATED;


 	            l_docs_count := x_pmtsInPmtInstrTab(j).document_count;
             IF (l_docs_count <= 0) THEN
                 /*
                  * A successful payment must be linked to at least
                  * least one successful document payable. If not
                  * there is a data consistency issue.
                  *
                  * Raise an alert and abort the program.
                  */
                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Fatal: No successful '
	                     || 'docs were found for successful pmt with id '
	                     || x_pmtsInPmtInstrTab(j).payment_id
	                     || '. Possible data corruption. '
	                     || 'Aborting program ..'
	                     );

                 END IF;
                  x_return_status := -1;

                  l_error_code := 'IBY_INS_PMT_NO_DOCS';
                  FND_MESSAGE.set_name('IBY', l_error_code);

                  FND_MESSAGE.SET_TOKEN('PMT_ID',
                     x_pmtsInPmtInstrTab(j).payment_id,
                     FALSE);

                  FND_MESSAGE.SET_TOKEN('INS_ID',
                     x_pmtInstrRec.payment_instruction_id,
                     FALSE);

                  x_return_message := FND_MESSAGE.get;

                  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                  print_debuginfo(l_module_name, 'EXIT');
                  END IF;
                  RETURN;

             END IF;

             l_num_printed_docs := getNumPrintedDocsByFormula(
                                       l_docs_count,
                                       l_paper_stock_rec.
                                           num_lines_per_stub
                                       );

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'For payment id '
	                 || x_pmtsInPmtInstrTab(j).payment_id
	                 || ', docs count on payment: '
	                 || l_docs_count
	                 || ', lines per stub on stock: '
	                 || l_paper_stock_rec.num_lines_per_stub
	                 || ', calculated number of printed docs: '
	                 || l_num_printed_docs);

             END IF;
             /*
              * Add the details about the setup docs and
              * overflow docs for this payment into the
              * special docs table. This special docs table
              * will be used for inserting dummy payments
              * into the IBY_DOCS_PAYABLE_ALL and
              * IBY_PAYMENTS_ALL tables to account for setup
              * and overflow checks.
              */
             l_paper_special_docs_rec.payment_id          :=
                 x_pmtsInPmtInstrTab(j).payment_id;

             l_paper_special_docs_rec.instruction_id      :=
                 x_pmtsInPmtInstrTab(j).pay_instr_id;

             /*
              * Only one printed document per payment will be a
              * valid payment document. The rest of the documents
              * will be overflow documents that will be void and
              * are only used to store the document payable
              * ids.
              */
             l_paper_special_docs_rec.num_overflow_docs   :=
                 l_num_printed_docs - 1;

             /*
              * Number of setup documents to print is
              * specified in the paper stock set up.
              */
             l_paper_special_docs_rec.num_setup_docs      :=
                 l_paper_stock_rec.num_setup_docs;

             /*
              * Lines per stub in used in populating
              * dummy documents payable for this
              * payment.
              */
             l_paper_special_docs_rec.num_lines_per_stub  :=
                 l_paper_stock_rec.num_lines_per_stub;

             /* add record to dummy docs table */
             l_paper_special_docs_tab(l_paper_special_docs_tab.COUNT
                 + 1) := l_paper_special_docs_rec;

         END LOOP; -- for each payment in this instruction

         /*
          * If we reached here, it means that 'num overflow docs'
          * and 'num setup docs' has been populated for each
          * paper payment in the l_paper_special_docs_tab table.
          *
          * Use this information to create appropriate number
          * of dummy payments (to insert into IBY_PAYMENTS_ALL table)
          * and corresponding documents (to insert into
          * IBY_DOCS_PAYABLE_ALL table).
          */
         performSpecialPaperDocHandling(
             l_paper_special_docs_tab,
             x_dummyPaperPmtsTab,
             x_setupDocsTab,
             x_overflowDocsTab
             );

         /*
          * After setup and overflow payments have been
          * handled, we can start assigning physical check
          * numbers to the paper payments.
          *
          * The 'paper special docs tab' holds real payments
          * that have to be printed onto paper; the 'paper pmts
          * tab' holds the dummy payments that also have to
          * printed onto paper. So both types of payments
          * need to be provided with check numbers.
          */
         assignCheckNumbers(
             x_pmtInstrRec,
             l_paper_stock_rec.doc_id,
             p_user_assgn_num,
             l_paper_special_docs_tab,
             x_dummyPaperPmtsTab,
             x_instrErrorTab,
             x_insTokenTab,
             x_return_message,
             x_return_status,
             x_msg_count,
             x_msg_data
             );

         IF (x_return_status = -1) THEN

             /*
              * Return back the x_return status and
              * x_return_message values that we received
              * from assignCheckNumbers() call.
              */
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Check numbering did '
	                 || 'not succeed.'
	                 );

	             print_debuginfo(l_module_name, 'EXIT');
             END IF;
             RETURN;

         END IF;

         /*
          * l_paper_special_docs_tab contains list of paper
          * payments that now have check number assigned.
          *
          * But this data structure is a local object. We
          * have to copy back the check numbers into
          * x_pmtsInPmtInstrTab which will be used to
          * finally update the database.
          */
         FOR m in l_paper_special_docs_tab.FIRST ..
             l_paper_special_docs_tab.LAST LOOP

             FOR p in x_pmtsInPmtInstrTab.FIRST ..
                 x_pmtsInPmtInstrTab.LAST LOOP

                 IF (l_paper_special_docs_tab(m).payment_id
                     = x_pmtsInPmtInstrTab(p).payment_id) THEN

                     x_pmtsInPmtInstrTab(p).check_number
                         := l_paper_special_docs_tab(m).check_number;

                 END IF;

             END LOOP; -- for p in x_pmtsInPmtInstrTab

         END LOOP; -- for m in l_paper_special_docs_tab

     ELSIF (l_processing_type = 'ELECTRONIC') THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Provided processing '
	             || 'type : '
	             || l_processing_type
	             || ' does not require printed '
	             || 'documents. '
	             || 'No processing will be performed.'
	             );
         End IF;
	          /*
	           * There will only be one paper stock linked to
	           * a particular payment document name, so we can
	           * simply take the first record from the fetched
	           * paper stocks table.
	           */
	          l_paper_stock_rec := l_paper_stocks_tab(1);

	          IF (l_paper_stock_rec.doc_id IS NOT NULL) THEN

                    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	              print_debuginfo(l_module_name, 'Paper stock matching '
	                  || 'profile id '
	                  || x_pmtInstrRec.payment_profile_id
	                  || ' has following attributes - Name: '
	                  || l_paper_stock_rec.doc_name
	                  || ', num setup docs: '
	                  || l_paper_stock_rec.num_setup_docs
	                  || ', num lines per stub: '
	                  || l_paper_stock_rec.num_lines_per_stub
	                  );
                   END IF;

	          ELSE

                    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	              print_debuginfo(l_module_name, 'Fatal: No paper stock '
	                  || 'linked to profile id '
	                  || x_pmtInstrRec.payment_profile_id
	                  || '. Payment instruction creation cannot continue. '
	                  || 'Aborting program ..'
	                  );
                   END IF;

	              x_return_status := -1;

	              l_error_code := 'IBY_INS_NO_PAPER_STOCK';
	              FND_MESSAGE.set_name('IBY', l_error_code);

	              FND_MESSAGE.SET_TOKEN('INS_ID',
	                  x_pmtInstrRec.payment_instruction_id,
	                  FALSE);

	              x_return_message := FND_MESSAGE.get;

	              print_debuginfo(l_module_name, 'EXIT');
	              RETURN;

	          END IF;

	          /*
	           * If we reached here it means paper stock
	           * attributes were retrieved successfully
	           * for the profile on the instruction.
	           */

	          /*
	           * Loop through all the payments for this
	           * payment instruction, processing them one-by-one.
	           */
	          FOR j in x_pmtsInPmtInstrTab.FIRST .. x_pmtsInPmtInstrTab.LAST
	              LOOP

                    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	              print_debuginfo(l_module_name, 'Processing payment '
	                  || x_pmtsInPmtInstrTab(j).payment_id
	                  || ' for instruction '
	                  || x_pmtInstrRec.payment_instruction_id
	                  || ' ..'
	                  );
                   END IF;
	          /* Removing the call to getDocumentCount, rather accessing
	           * IBY_DOCS_PAYABLE_ALL table to get the count of the
	  	  * documents
	  	  */
	            /*  l_docs_count := getDocumentCountForPayment(
	                                  x_pmtsInPmtInstrTab(j).payment_id,
	                                  x_pmtsInPmtInstrTab
	                                  );
	 	    */

	 	            SELECT
	  	                 COUNT(*)
	 		    INTO
	  	                 x_pmtsInPmtInstrTab(j).document_count
	  	            FROM
	  	                 IBY_DOCS_PAYABLE_ALL
	  	            WHERE
	  	                 payment_id =  x_pmtsInPmtInstrTab(j).payment_id
	  	            AND
	  	                 document_status = DOC_STATUS_PAY_CREATED;


	  	            l_docs_count := x_pmtsInPmtInstrTab(j).document_count;
	              IF (l_docs_count <= 0) THEN
	                  /*
	                   * A successful payment must be linked to at least
	                   * least one successful document payable. If not
	                   * there is a data consistency issue.
	                   *
	                   * Raise an alert and abort the program.
	                   */
                    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                  print_debuginfo(l_module_name, 'Fatal: No successful '
	                      || 'docs were found for successful pmt with id '
	                      || x_pmtsInPmtInstrTab(j).payment_id
	                      || '. Possible data corruption. '
	                      || 'Aborting program ..'
	                      );
                   END IF;

	                   x_return_status := -1;

	                   l_error_code := 'IBY_INS_PMT_NO_DOCS';
	                   FND_MESSAGE.set_name('IBY', l_error_code);

	                   FND_MESSAGE.SET_TOKEN('PMT_ID',
	                      x_pmtsInPmtInstrTab(j).payment_id,
	                      FALSE);

	                   FND_MESSAGE.SET_TOKEN('INS_ID',
	                      x_pmtInstrRec.payment_instruction_id,
	                      FALSE);

	                   x_return_message := FND_MESSAGE.get;

	                   print_debuginfo(l_module_name, 'EXIT');
	                   RETURN;

	              END IF;

	              l_num_printed_docs := getNumPrintedDocsByFormula(
	                                        l_docs_count,
	                                        l_paper_stock_rec.
	                                            num_lines_per_stub
	                                        );

                    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	              print_debuginfo(l_module_name, 'For payment id '
	                  || x_pmtsInPmtInstrTab(j).payment_id
	                  || ', docs count on payment: '
	                  || l_docs_count
	                  || ', lines per stub on stock: '
	                  || l_paper_stock_rec.num_lines_per_stub
	                  || ', calculated number of printed docs: '
	                  || l_num_printed_docs);
                   END IF;

	              /*
	               * Add the details about the setup docs and
	               * overflow docs for this payment into the
	               * special docs table. This special docs table
	               * will be used for inserting dummy payments
	               * into the IBY_DOCS_PAYABLE_ALL and
	               * IBY_PAYMENTS_ALL tables to account for setup
	               * and overflow checks.
	               */
	              l_paper_special_docs_rec.payment_id          :=
	                  x_pmtsInPmtInstrTab(j).payment_id;

	              l_paper_special_docs_rec.instruction_id      :=
	                  x_pmtsInPmtInstrTab(j).pay_instr_id;

	              /*
	               * Only one printed document per payment will be a
	               * valid payment document. The rest of the documents
	               * will be overflow documents that will be void and
	               * are only used to store the document payable
	               * ids.
	               */
	              l_paper_special_docs_rec.num_overflow_docs   :=
	                  l_num_printed_docs - 1;

	              /*
	               * Number of setup documents to print is
	               * specified in the paper stock set up.
	               */
	              l_paper_special_docs_rec.num_setup_docs      :=
	                  l_paper_stock_rec.num_setup_docs;

	              /*
	               * Lines per stub in used in populating
	               * dummy documents payable for this
	               * payment.
	               */
	              l_paper_special_docs_rec.num_lines_per_stub  :=
	                  l_paper_stock_rec.num_lines_per_stub;

	              /* add record to dummy docs table */
	              l_paper_special_docs_tab(l_paper_special_docs_tab.COUNT
	                  + 1) := l_paper_special_docs_rec;

	          END LOOP; -- for each payment in this instruction

	          /*
	           * If we reached here, it means that 'num overflow docs'
	           * and 'num setup docs' has been populated for each
	           * paper payment in the l_paper_special_docs_tab table.
	           *
	           * Use this information to create appropriate number
	           * of dummy payments (to insert into IBY_PAYMENTS_ALL table)
	           * and corresponding documents (to insert into
	           * IBY_DOCS_PAYABLE_ALL table).
	           */
                   /*Special Paper Doc Handling is not required for Electronic type of payments*/
	          /*performSpecialPaperDocHandling(
	              l_paper_special_docs_tab,
	              x_dummyPaperPmtsTab,
	              x_setupDocsTab,
	              x_overflowDocsTab
	              );*/

	          /*
	           * After setup and overflow payments have been
	           * handled, we can start assigning physical check
	           * numbers to the paper payments.
	           *
	           * The 'paper special docs tab' holds real payments
	           * that have to be printed onto paper; the 'paper pmts
	           * tab' holds the dummy payments that also have to
	           * printed onto paper. So both types of payments
	           * need to be provided with check numbers.
	           */
	          assignElectronicCheckNumbers(
	              x_pmtInstrRec,
	              l_paper_stock_rec.doc_id,
	              p_user_assgn_num,
	              l_paper_special_docs_tab,
	              x_dummyPaperPmtsTab,
	              x_instrErrorTab,
	              x_insTokenTab,
	              x_return_message,
	              x_return_status,
	              x_msg_count,
	              x_msg_data
	              );

	          IF (x_return_status = -1) THEN

	              /*
	               * Return back the x_return status and
	               * x_return_message values that we received
	               * from assignCheckNumbers() call.
	               */
                    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	              print_debuginfo(l_module_name, 'Check numbering did '
	                  || 'not succeed.'
	                  );

	              print_debuginfo(l_module_name, 'EXIT');
                   END IF;
	              RETURN;

	          END IF;

	          /*
	           * l_paper_special_docs_tab contains list of paper
	           * payments that now have check number assigned.
	           *
	           * But this data structure is a local object. We
	           * have to copy back the check numbers into
	           * x_pmtsInPmtInstrTab which will be used to
	           * finally update the database.
	           */
	          FOR m in l_paper_special_docs_tab.FIRST ..
	              l_paper_special_docs_tab.LAST LOOP

	              FOR p in x_pmtsInPmtInstrTab.FIRST ..
	                  x_pmtsInPmtInstrTab.LAST LOOP

	                  IF (l_paper_special_docs_tab(m).payment_id
	                      = x_pmtsInPmtInstrTab(p).payment_id) THEN

	                      x_pmtsInPmtInstrTab(p).check_number
	                          := l_paper_special_docs_tab(m).check_number;

	                  END IF;

	              END LOOP; -- for p in x_pmtsInPmtInstrTab

             END LOOP; -- for m in l_paper_special_docs_tab


     ELSE

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Unknown processing '
	             || 'type provided: '
	             || l_processing_type
	             || '. Aborting program ..'
	             );

         END IF;
          x_return_status := -1;

          l_error_code := 'IBY_INS_UNK_PROC_TYPE';
          FND_MESSAGE.set_name('IBY', l_error_code);

          FND_MESSAGE.SET_TOKEN('UNK_PROC_TYPE',
              l_processing_type,
              FALSE);

          FND_MESSAGE.SET_TOKEN('INS_ID',
              x_pmtInstrRec.payment_instruction_id,
              FALSE);

          x_return_message := FND_MESSAGE.get;

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	          print_debuginfo(l_module_name, 'EXIT');
          END IF;
          RETURN;

     END IF; -- if processing_type = 'PRINTED'

     /*
      * If we reached here, return success.
      */
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Returning success response ..');
     END IF;
     x_return_status := 0;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END processPaperPayments;

/*--------------------------------------------------------------------
 | NAME:
 |     getDocumentCountForPayment
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
 FUNCTION getDocumentCountForPayment(
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%TYPE,
     p_pmtsInPmtInstrTab  IN IBY_PAYINSTR_PUB.pmtsInpmtInstrTabType
     )
 RETURN NUMBER
 IS
 l_doc_count  NUMBER := -1;

 BEGIN

     FOR i in p_pmtsInPmtInstrTab.FIRST .. p_pmtsInPmtInstrTab.LAST LOOP

         IF (p_pmtsInPmtInstrTab(i).payment_id = p_payment_id) THEN

             l_doc_count := p_pmtsInPmtInstrTab(i).document_count;
             EXIT;

         END IF;

     END LOOP;

     RETURN l_doc_count;

 END getDocumentCountForPayment;

/*--------------------------------------------------------------------
 | NAME:
 |     assignCheckNumbers
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
 |
 | NOTES:
 |     This method will perform a COMMIT.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE assignCheckNumbers(
     x_pmtInstrRec       IN OUT NOCOPY IBY_PAY_INSTRUCTIONS_ALL%ROWTYPE,
     p_payment_doc_id    IN CE_PAYMENT_DOCUMENTS.payment_document_id%TYPE,
     p_user_assgn_num    IN IBY_PAYMENTS_ALL.paper_document_number%TYPE,
     x_paperPmtsTab      IN OUT NOCOPY paperPmtsSpecialDocsTabType,
     x_dummyPaperPmtsTab IN OUT NOCOPY IBY_PAYGROUP_PUB.paymentTabType,
     x_instrErrorTab     IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
     x_insTokenTab       IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.
                                           trxnErrTokenTabType,
     x_return_message    IN OUT NOCOPY VARCHAR2,
     x_return_status     IN OUT NOCOPY NUMBER,
     x_msg_count         IN OUT NOCOPY NUMBER,
     x_msg_data          IN OUT NOCOPY VARCHAR2
     )
 IS

 l_paper_pmts_count     NUMBER := 0;
 l_last_used_check_num  NUMBER := 0;
 l_last_avail_check_num NUMBER := 0;
 l_physical_stock_count NUMBER := 0;
 l_anticipated_last_check_num  NUMBER := 0;

 l_pmt_doc_name      VARCHAR2(200) := '';
 l_pmt_instr_id      IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE;

 l_error_code        IBY_TRANSACTION_ERRORS.error_code%TYPE;
 l_instr_err_rec     IBY_TRANSACTION_ERRORS%ROWTYPE;
 l_token_rec         IBY_TRXN_ERROR_TOKENS%ROWTYPE;

 l_send_to_file_flag VARCHAR2(1);
 l_instr_status      IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_status%TYPE;

 l_single_pmt_flag   BOOLEAN;
 l_nos_avlbl_flag    BOOLEAN;
 l_used_flag         BOOLEAN;

 l_module_name       VARCHAR2(200) := G_PKG_NAME || '.assignCheckNumbers';

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     /*
      * Total number of paper payments is sum of real paper payments
      * and dummy paper payments.
      */
     l_paper_pmts_count := x_paperPmtsTab.COUNT + x_dummyPaperPmtsTab.COUNT;

     /* should never come into if, but just in case */
     IF (l_paper_pmts_count = 0) THEN

         /*
          * Shouldn't come here. This method was called because there
          * was atleast one payment instruction with processing type
          * 'PAPER'. This implies that there should be at least one
          * payment instruction with processing type 'PAPER'.
          *
          * If no such payment exists, about the program.
          */
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Total # of paper payments '
	             || 'is 0. Possible data corruption. Aborting ..'
	             );

	         print_debuginfo(l_module_name, 'EXIT');
         END IF;
         x_return_status := -1;

         l_error_code := 'IBY_INS_PMTS_NOT_FOUND';
         FND_MESSAGE.set_name('IBY', l_error_code);

         FND_MESSAGE.SET_TOKEN('INS_ID',
             x_pmtInstrRec.payment_instruction_id,
             FALSE);

         FND_MSG_PUB.ADD;

         FND_MSG_PUB.COUNT_AND_GET(
             p_count => x_msg_count,
             p_data  => x_msg_data
             );

         x_return_message := FND_MESSAGE.get;

         RETURN;

     ELSE

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Total # of paper payments: '
	             || l_paper_pmts_count
	             );

         END IF;
     END IF;

     /*
      * When this printed payment instruction is formatted, the
      * output can be sent to any of two places:
      *
      * a. To the printer
      * b. To a file (for printing outside the Oracle system).
      *
      * The status of the payment instruction needs to be adjusted
      * as per this destination flag.
      */
     BEGIN

         SELECT
             send_to_file_flag
         INTO
             l_send_to_file_flag
         FROM
             IBY_PAYMENT_PROFILES
         WHERE
             payment_profile_id = x_pmtInstrRec.payment_profile_id
         ;

     EXCEPTION
         WHEN OTHERS THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Fatal: Exception when '
	             || 'attempting to get "send to file flag" for payment '
	             || 'instruction '
	             || x_pmtInstrRec.payment_instruction_id
	             || ' with payment profile id '
	             || x_pmtInstrRec.payment_profile_id
	             );

	         print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	         print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);

	         print_debuginfo(l_module_name, 'Aborting numbering process ..');

         END IF;
         x_return_status := -1;

         l_error_code := 'IBY_INS_PROF_EXCEP';
         FND_MESSAGE.set_name('IBY', l_error_code);

         FND_MESSAGE.SET_TOKEN('INS_ID',
             x_pmtInstrRec.payment_instruction_id,
             FALSE);

         FND_MESSAGE.SET_TOKEN('PROF_ID',
             x_pmtInstrRec.payment_profile_id,
             FALSE);

         FND_MSG_PUB.ADD;

         FND_MSG_PUB.COUNT_AND_GET(
             p_count => x_msg_count,
             p_data  => x_msg_data
             );

         x_return_message := FND_MESSAGE.get;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     END;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'For payment instruction '
	         || x_pmtInstrRec.payment_instruction_id
	         || ' with payment profile id '
	         || x_pmtInstrRec.payment_profile_id
	         || ', send to file flag: '
	         || l_send_to_file_flag
	         );

     END IF;
     /*
      * The payment instruction status is dependant upon
      * the 'send to file' flag. Preset the instruction
      * status appropriately.
      */
     IF (UPPER(l_send_to_file_flag) = 'Y') THEN
         l_instr_status := INS_STATUS_READY_TO_FORMAT;
     ELSE
         l_instr_status := INS_STATUS_READY_TO_PRINT;
     END IF;

     /*
      * Check whether the provided payments list consists
      * of a single payment.
      */
     l_single_pmt_flag := isSinglePayment(x_paperPmtsTab);

     /*
      * IMPORTANT NOTE:
      * Irrespective of whether this payment instruction
      * could be numbered successfully or not, we will
      * change the status of the payment instruction at
      * this point from 'CREATED' -> 'CREATED_READY_FOR_PRINTING'
      * or 'CREATED_READY_FOR_FORMATTING'.
      *
      * In case, the payments could be numbered successfully,
      * the new payment instruction status becomes a transient
      * status (because the format will immediately change the
      * payment status to 'FORMATTED').
      *
      * In case, the  numbering failed for some reason, or some
      * other exception was thrown, the payment instruction
      * will remain in the new status. This will be sufficient
      * for the UI to recognize that the payment instruction
      * did not finish the numbering operation successfully.
      *
      * Therefore, the UI will call the check numering flow
      * again, and we will have another go at numbering this
      * payment instruction.
      */

     /*
      * Blindly update the payment instruction status
      * (see above comment).
      */
     UPDATE
         IBY_PAY_INSTRUCTIONS_ALL
     SET
         payment_instruction_status = l_instr_status
     WHERE
         payment_instruction_id = x_pmtInstrRec.payment_instruction_id;

     /*
      * For single payments, do not perform any commits because
      * single payments API is session based and only the caller
      * decides to commit / not commit.
      */
     IF (l_single_pmt_flag <> TRUE) THEN

         /*
          * This commit is needed so that in case of any exceptions
          * in this method (e.g., payment document locked), the
          * payment instruction status is changed from 'CREATED'
          * to the next valid status.
          *
          * Payments in 'CREATED' status are not visible in the UI,
          * this is because 'CREATED' is a transient status.
          */
         COMMIT;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Payment instruction '
	             || x_pmtInstrRec.payment_instruction_id
	             || ' status committed to '
	             || l_instr_status
	             || ' before numbering.'
	             );

         END IF;
     END IF;

     /*
      * Pull up the details of the paper stock, like the
      * last used check number and the last available
      * check number.
      *
      * Note: This SELECT will lock the underlying base
      * table IBY_PAYMENT_DOCUMENTS_B. We need to lock this
      * table because we need to update the last_document_number.
      */
    SELECT
         payment_document_name,
         payment_instruction_id
     INTO
         l_pmt_doc_name,
         l_pmt_instr_id
     FROM
         CE_PAYMENT_DOCUMENTS
     WHERE
         payment_document_id = p_payment_doc_id
     ;


      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name, 'Got the payment document name');

      END IF;
     /*
      *
      * Pull up the details of the paper stock, like the
      * last used check number and the last available
      * check number.
      *
      * Note: This SELECT will lock the underlying base
      * table IBY_PAYMENT_DOCUMENTS_B. We need to lock this
      * table because we need to update the last_document_number.
      *
      *  If document is already locked for single payment,
      * NO_DATA_FOUND exception would be thrown.
      * Bug - 7499044
      */
     BEGIN
     SELECT
         NVL(last_issued_document_number, 0),
         NVL(last_available_document_number, -1),
         payment_document_name,
         payment_instruction_id
     INTO
         l_last_used_check_num,
         l_last_avail_check_num,
         l_pmt_doc_name,
         l_pmt_instr_id
     FROM
         CE_PAYMENT_DOCUMENTS
     WHERE
         payment_document_id = p_payment_doc_id
     FOR UPDATE SKIP LOCKED
     ;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
                     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                     print_debuginfo(l_module_name, 'Payment document '
	             || ''''
	             || l_pmt_doc_name
	             || ''''
	             || ' with payment doc id '
	             || p_payment_doc_id
	             || ' has been locked from payments workbench ',
	             FND_LOG.LEVEL_UNEXPECTED
	             );

	         print_debuginfo(l_module_name, 'Processing cannot continue '
	             || 'because payment document is unavailable (locked).',
	             FND_LOG.LEVEL_UNEXPECTED
	             );

	         print_debuginfo(l_module_name, 'Changing the status of the '
	             || 'payment instruction to '
	             || l_instr_status
	             );

         END IF;
         /*
          * Fix for bug 5735030:
          *
          * Populate error message in output file so that
          * the user knows the cause of the failure even
          * if logging is turned off.
          */
         l_error_code := 'IBY_PMT_DOC_SING_LOCKED';
         FND_MESSAGE.SET_NAME('IBY', l_error_code);

         FND_MESSAGE.SET_TOKEN('DOC_NAME',
             l_pmt_doc_name,
             FALSE);

         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.GET);

         /*
          * Return failure status.
          */
         x_return_status := -1;

         l_error_code := 'IBY_PMT_DOC_SING_LOCKED';
         FND_MESSAGE.set_name('IBY', l_error_code);

         FND_MESSAGE.SET_TOKEN('DOC_NAME',
             l_pmt_doc_name,
             FALSE);

         FND_MSG_PUB.ADD;

         FND_MSG_PUB.COUNT_AND_GET(
             p_count => x_msg_count,
             p_data  => x_msg_data
             );

         x_return_message := FND_MESSAGE.get;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');
         END IF;
         RETURN;


     END;
     IF (l_pmt_instr_id IS NOT NULL) THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Payment document '
	             || ''''
	             || l_pmt_doc_name
	             || ''''
	             || ' with payment doc id '
	             || p_payment_doc_id
	             || ' has been locked by payment instruction '
	             || l_pmt_instr_id,
	             FND_LOG.LEVEL_UNEXPECTED
	             );

	         print_debuginfo(l_module_name, 'Processing cannot continue '
	             || 'because payment document is unavailable (locked).',
	             FND_LOG.LEVEL_UNEXPECTED
	             );

	         print_debuginfo(l_module_name, 'Changing the status of the '
	             || 'payment instruction to '
	             || l_instr_status
	             );

         END IF;
         /*
          * Fix for bug 5735030:
          *
          * Populate error message in output file so that
          * the user knows the cause of the failure even
          * if logging is turned off.
          */
         l_error_code := 'IBY_INS_PMT_DOC_LOCKED_DETAIL';
         FND_MESSAGE.SET_NAME('IBY', l_error_code);

         FND_MESSAGE.SET_TOKEN('THIS_INS_NUM',
             x_pmtInstrRec.payment_instruction_id,
             FALSE);

         FND_MESSAGE.SET_TOKEN('PREV_INS_NUM',
             l_pmt_instr_id,
             FALSE);

         FND_MESSAGE.SET_TOKEN('DOC_NAME',
             l_pmt_doc_name,
             FALSE);

         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.GET);

         /*
          * Return failure status.
          */
         x_return_status := -1;

         l_error_code := 'IBY_INS_PMT_DOC_LOCKED';
         FND_MESSAGE.set_name('IBY', l_error_code);

         FND_MESSAGE.SET_TOKEN('INS_ID',
             l_pmt_instr_id,
             FALSE);

         FND_MSG_PUB.ADD;

         FND_MSG_PUB.COUNT_AND_GET(
             p_count => x_msg_count,
             p_data  => x_msg_data
             );

         x_return_message := FND_MESSAGE.get;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');
         END IF;
         RETURN;

     END IF;

     /*
      * Log warnings if there is any missing/incomplete information.
      */
     IF (l_last_avail_check_num = -1) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Warning: payment document id '
	             || p_payment_doc_id
	             || ' has no last available document number set. '
	             || 'Assuming that infinite number of paper documents '
	             || 'can be printed for this payment document.'
	             );

         END IF;
     END IF;

     IF (l_last_used_check_num = 0) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Warning: payment document id '
	             || p_payment_doc_id
	             || ' has last used document number set to zero. '
	             || 'Assuming that no paper documents have yet '
	             || 'been printed for this payment document.'
	             );

         END IF;
     END IF;


     /*
      * If user has explicitly provided a start number for check
      * numbering, we have to use it in our numbering logic.
      * This will only happen for single payments.
      *
      * For Build Program invoked numbering, we will always start
      * from the last issued check number on the payment document + 1.
      */
     IF (p_user_assgn_num IS NULL) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'User has not explicitly '
	             || 'provided a check number to start numbering from. '
	             || 'Numbering will start from last issued check number '
	             || 'on check stock.'
	             );

         END IF;
     ELSE

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'User has explicitly '
	             || 'provided start number for numbering: '
	             || p_user_assgn_num
	             );

         END IF;
         /*
          * The code below uses the variable 'l_last_used_check_num'
          * as the starting number for check numbering. The numbering
          * will begin from l_last_used_check_num + 1.
          *
          * If the user has explicitly provided a start number for
          * numbering, we need to adjust the l_last_used_check_num
          * value accordingly.
          */
         l_last_used_check_num := p_user_assgn_num - 1;

     END IF;

     /*
      * Check if enough paper documents are available to complete
      * this payment instruction.
      *
      * Perform this check only if a value has been provided
      * for the last available document number. If no value is
      * set assume that an infinite number of checks can be
      * printed for this paper stock (payment document).
      */
     IF (l_last_avail_check_num <> -1) THEN

         /*
          * Check if enough paper documents are available to complete
          * this payment instruction.
          */
         l_physical_stock_count := l_last_avail_check_num
                                       - l_last_used_check_num;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Available paper stock = '
	             || l_physical_stock_count
	             || ' for payment document name '
	             || ''''
	             || l_pmt_doc_name
	             || ''''
	             );

         END IF;
         IF (l_physical_stock_count < l_paper_pmts_count) THEN

             /*
              * Not enough paper stock is available to print
              * the checks for this payment instruction.
              *
              * Set the status of the payment instruction to
              * failed.
              */
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Deferring payment '
	                 || 'instruction print '
	                 || x_pmtInstrRec.payment_instruction_id
	                 || ' because of insufficient paper stock.',
	                 FND_LOG.LEVEL_UNEXPECTED
	                 );

             END IF;
             x_pmtInstrRec.payment_instruction_status := l_instr_status;

             l_error_code := 'IBY_INS_INSUFFICIENT_PAY_DOCS';

             FND_MESSAGE.set_name('IBY', l_error_code);

             FND_MESSAGE.SET_TOKEN('NUM_AVAIL',
                 l_physical_stock_count,
                 FALSE);

             l_token_rec.token_name  := 'NUM_AVAIL';
             l_token_rec.token_value := l_physical_stock_count;
             x_insTokenTab(x_insTokenTab.COUNT + 1) := l_token_rec;

             FND_MESSAGE.SET_TOKEN('NUM_REQD',
                 l_paper_pmts_count,
                 FALSE);

             l_token_rec.token_name  := 'NUM_REQD';
             l_token_rec.token_value := l_paper_pmts_count;
             x_insTokenTab(x_insTokenTab.COUNT + 1) := l_token_rec;

             /*
              * Once we fail a pmt instruction, we must add a
              * corresponding error message to the errors table.
              */
             IBY_PAYINSTR_UTILS_PKG.createErrorRecord(
                 x_pmtInstrRec.payment_instruction_id,
                 x_pmtInstrRec.payment_instruction_status,
                 l_error_code,
                 FND_MESSAGE.get,
                 'N',
                 l_instr_err_rec
                 );

             IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(
                 l_instr_err_rec,
                 x_instrErrorTab,
                 x_insTokenTab
                 );

             /* add error message to msg stack */
             FND_MSG_PUB.ADD;

             FND_MSG_PUB.COUNT_AND_GET(
                 p_count => x_msg_count,
                 p_data  => x_msg_data
                 );

             /* set error message to return to caller */
             x_return_message := FND_MESSAGE.get;

             /*
              * Now, raise an exception. This will be caught
              * in the exception handler below and the changes
              * made to the DB in this transaction
              * will be rolled back.
              */
             APP_EXCEPTION.RAISE_EXCEPTION;

         ELSE

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Sufficient paper stock '
	                 || 'is available to print this instruction.'
	                 );

             END IF;
         END IF;

     END IF; -- l_last_avail_check_num <> -1

     /*
      * If sufficient paper stock is available, we will be using
      * up the paper stock by assigning it to the available
      * paper payments. Therefore, update the last used paper
      * stock number in CE_PAYMENT_DOCUMENTS.
      *
      * That way if another instance of the payment instruction
      * creation program is operating concurrently, it will
      * be blocked by the SELECT .. FOR UPDATE statement in
      * this method.
      *
      */
     l_anticipated_last_check_num := l_last_used_check_num
                                         + l_paper_pmts_count;

     /*
      * We will be printing the checks starting with
      * paper doc num 'l_last_used_check_num + 1' and
      * ending with paper doc num l_anticipated_last_check_num.
      *
      * Check whether all the paper doc numbers within this
      * range are available. We cannot have any gaps in the
      * numbering because checks have to be numbered
      * contiguously.
      */
     l_nos_avlbl_flag := isContigPaperNumAvlbl(
                             p_payment_doc_id,
                             l_last_used_check_num + 1,
                             l_anticipated_last_check_num
                             );

     IF (l_nos_avlbl_flag = FALSE) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Contiguous paper stock '
	             || 'is not available for printing payment instruction '
	             || x_pmtInstrRec.payment_instruction_id
	             );

         END IF;
         /*
          * Return failure status.
          */
         x_return_status := -1;

         l_error_code := 'IBY_INS_NSF_CONTIG_NUM';
         FND_MESSAGE.set_name('IBY', l_error_code);

         FND_MESSAGE.SET_TOKEN('NUM_PMT_DOCS',
             l_paper_pmts_count,
             FALSE);

         FND_MSG_PUB.ADD;

         FND_MSG_PUB.COUNT_AND_GET(
             p_count => x_msg_count,
             p_data  => x_msg_data
             );

         x_return_message := FND_MESSAGE.get;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');
         END IF;
         RETURN;

     END IF;

     /*
      * A paper document number (check number) is considered
      * unused if it is not present in IBY_USED_PAYMENT_DOCS
      * table.
      *
      * This logic will work when check numbering is invoked
      * from the Build Program. In this case, the numbering
      * logic always starts with the last issued doc number + 1
      * when assigning new check numbers. Therefore, the
      * check numbers will always be unique (unused).
      *
      * However, when check numbering is invoked for single
      * payments, the user is allowed to provide the start
      * number for check numbering. It is possible that
      * a payment has already been numbered with the user
      * provided start number, but this paper document may
      * not yet have been inserted into the IBY_USED_PAYMENT_DOCS
      * table (because the user has not yet confirmed the
      * payment).
      *
      * Therefore, for single payments, when the user provides
      * the start number for check numbering, we will have to
      * verify that the provided number is unused by checking
      * the paper document number on existing payments.
      */
     IF (p_user_assgn_num IS NOT NULL) THEN

         l_used_flag := isPaperNosUsedOnExistPmt(
                            p_payment_doc_id,
                            l_last_used_check_num + 1,
                            l_anticipated_last_check_num);

         IF (l_used_flag = TRUE) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Paper document number(s) '
	                 || 'generated after numbering are invalid (already used). '
	                 || 'User needs to provide a new start number or use '
	                 || 'the defaulted start number.'
	                 );

             END IF;
             /*
              * Return failure status.
              */
             x_return_status := -1;

             l_error_code := 'IBY_INS_ALREADY_USED_NUM';
             FND_MESSAGE.set_name('IBY', l_error_code);

             FND_MSG_PUB.ADD;

             FND_MSG_PUB.COUNT_AND_GET(
                 p_count => x_msg_count,
                 p_data  => x_msg_data
                 );

             x_return_message := FND_MESSAGE.get;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'EXIT');
             END IF;
             RETURN;

         ELSE

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Paper document number(s) '
	                 || 'generated after numbering are unused. '
	                 );

             END IF;
         END IF;

     END IF;

     /*
      * For single payments, the payment document should
      * not be locked (see bug 4597718).
      */
     IF (l_single_pmt_flag = TRUE) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'This is a single payment. '
	             || 'Payment document will not be locked ..'
	             );

         END IF;
         /*
          * Update the check stock to reflect the latest used
          * check number.
          */
         UPDATE
             CE_PAYMENT_DOCUMENTS
         SET
             last_issued_document_number = l_anticipated_last_check_num
         WHERE
             payment_document_id         = p_payment_doc_id
         AND
	    last_issued_document_number < l_anticipated_last_check_num
         ;

     ELSE

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'This is not a single payment. '
	             || 'Payment document will be locked ..'
	             );

         END IF;
         /*
          * Update the check stock to reflect the latest used
          * check number, and lock the check stock.
          */
         UPDATE
             CE_PAYMENT_DOCUMENTS
         SET
             last_issued_document_number = l_anticipated_last_check_num,
             payment_instruction_id      = x_pmtInstrRec.payment_instruction_id
         WHERE
             payment_document_id         = p_payment_doc_id

         ;

     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Finished updating the last '
	         || 'available check number in CE_PAYMENT_DOCUMENTS. '
	         || 'Current last check number: '
	         || l_anticipated_last_check_num
	         );

     END IF;
     /* uncomment for debug purposes */
     --print_debuginfo(l_module_name, 'x_dummyPaperPmtsTab.COUNT: '
     --    || x_dummyPaperPmtsTab.COUNT);
     --print_debuginfo(l_module_name, 'x_paperPmtsTab.COUNT: '
     --    || x_paperPmtsTab.COUNT);

     /*
      * Assign contiguous check numbers to the setup checks.
      * These are dummy checks that are printed at the
      * beginning of the payment instruction print run.
      */
     IF (x_dummyPaperPmtsTab.COUNT <> 0) THEN

         FOR i in x_dummyPaperPmtsTab.FIRST .. x_dummyPaperPmtsTab.LAST LOOP

             IF (x_dummyPaperPmtsTab(i).payment_status = 'VOID_BY_SETUP') THEN

                 l_last_used_check_num := l_last_used_check_num + 1;
                 x_dummyPaperPmtsTab(i).paper_document_number
                     := l_last_used_check_num;

             END IF;

         END LOOP; -- for all setup payments in x_dummyPaperPmtsTab

     END IF;

     /* handle real checks and overflow checks here */
     FOR i in x_paperPmtsTab.FIRST .. x_paperPmtsTab.LAST LOOP

         /*
          * We must assign the check numbers in sequence
          * so that when a paper payment is printed, all the
          * paper documents for that payment have contiguous
          * number.
          */


         /*
          * If this payment has any overflow documents, then
          * some overflow payments would have been created.
          * Assign check numbers to these overflow payments
          * too.
          *
          * Overflow payments are created one-by-one and are
          * assigned incremental payment ids. So no need to sort
          * these overflow payments (they are already sorted).
          *
          * Simply find the overflow payments related to the real
          * payment and assign them with contiguous check numbers.
          */
         IF (x_dummyPaperPmtsTab.COUNT <> 0) THEN

             FOR j in x_dummyPaperPmtsTab.FIRST .. x_dummyPaperPmtsTab.LAST LOOP

                 /*
                  * The external_bank_account_id field actually contains
                  * the original payment id (the payment that originally
                  * contained the documents payable stored in the dummy
                  * overflow payment).
                  *
                  * See KLUDGE in performSpecialPaperHandling()
                  * method to see why this was done.
                  */
                 IF (x_dummyPaperPmtsTab(j).payment_status = 'VOID_BY_OVERFLOW')
                     THEN

                     IF (x_dummyPaperPmtsTab(j).external_bank_account_id
                         = x_paperPmtsTab(i).payment_id) THEN

                         l_last_used_check_num := l_last_used_check_num + 1;
                         x_dummyPaperPmtsTab(j).paper_document_number
                             := l_last_used_check_num;

                     END IF;

                 END IF;

             END LOOP; -- for all overflow pmts in x_dummyPaperPmtsTab

         END IF;

          /* Bug 7252846 -  priting of overflow and original payments must be such that, the overflow payments must be
	  printed first, followed by original ones. In this case, the numbering should happen first for overflow payments
	  followed by original ones */

	  /* assign check number to paper payment */
         l_last_used_check_num := l_last_used_check_num + 1;
         x_paperPmtsTab(i).check_number := l_last_used_check_num;


     END LOOP; -- for all pmts in x_paperPmtsTab

     /*
      * Final check:
      *
      * If all paper payments (including real payments, setup payments
      * and overflow payments) have been assigned check numbers
      * correctly, then the number of check numbers used up should
      * match the total paper payments count.
      *
      * If the two don't match, it means that some check numbers were
      * unassigned, or multiply assigned. In either case, abort the
      * program. This check will reveal any bugs in this method.
      */
     IF (l_anticipated_last_check_num <> l_last_used_check_num) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Check numbers were not '
	             || 'properly assigned. '
	             || 'Anticipated last used check number: '
	             || l_anticipated_last_check_num
	             || '. Actual last used check number: '
	             || l_last_used_check_num
	             || '. Deferring print for payment instruction '
	             || x_pmtInstrRec.payment_instruction_id,
	             FND_LOG.LEVEL_UNEXPECTED
	             );

         END IF;
         x_pmtInstrRec.payment_instruction_status := l_instr_status;

         l_error_code := 'IBY_INS_NUMBERING_ERR_1';

         FND_MESSAGE.set_name('IBY', l_error_code);

         FND_MESSAGE.SET_TOKEN('NUM_CALC',
             l_anticipated_last_check_num,
             FALSE);

         l_token_rec.token_name  := 'NUM_CALC';
         l_token_rec.token_value := l_anticipated_last_check_num;
         x_insTokenTab(x_insTokenTab.COUNT + 1) := l_token_rec;

         FND_MESSAGE.SET_TOKEN('NUM_ACTU',
             l_last_used_check_num,
             FALSE);

         l_token_rec.token_name  := 'NUM_ACTU';
         l_token_rec.token_value := l_last_used_check_num;
         x_insTokenTab(x_insTokenTab.COUNT + 1) := l_token_rec;

         /*
          * Once we fail a pmt instruction, we must add a
          * corresponding error message to the errors table.
          */
         IBY_PAYINSTR_UTILS_PKG.createErrorRecord(
             x_pmtInstrRec.payment_instruction_id,
             x_pmtInstrRec.payment_instruction_status,
             l_error_code,
             FND_MESSAGE.get,
             'N',
             l_instr_err_rec
             );

         IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(
             l_instr_err_rec,
             x_instrErrorTab,
             x_insTokenTab
             );

         /* add error msg to message stack */
         FND_MSG_PUB.ADD;

         FND_MSG_PUB.COUNT_AND_GET(
             p_count => x_msg_count,
             p_data  => x_msg_data
             );

         /* set error message to return to caller */
         x_return_message := FND_MESSAGE.get;

         APP_EXCEPTION.RAISE_EXCEPTION;

     END IF;

     /*
      * Return success status.
      */
     x_return_message := 'SUCCESS';
     x_return_status  := 0;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
     EXCEPTION
         WHEN OTHERS THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Exception occured when '
	             || 'performing document numbering. '
	             );
	         print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	         print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);

         END IF;
         /*
          * Rollback any DB changes made in this method.
          */
         ROLLBACK;

         /*
          * Return error status to caller.
          * The error message would have already been set.
          */
         x_return_status := -1;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
 END assignCheckNumbers;

/*--------------------------------------------------------------------
 | NAME:
 |     getNumPrintedDocsByFormula
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
 FUNCTION getNumPrintedDocsByFormula(
     p_num_docs_payable      IN NUMBER,
     p_num_lines_per_stub    IN NUMBER
     )
     RETURN NUMBER
 IS

 l_num_printed_docs  NUMBER := -1;
 l_carryover         NUMBER := -1;
 l_extra_printed_doc NUMBER := -1;

 BEGIN

    /*
     * We will try to fit n docs payable into m stubs, where
     * p = number of lines per stub. The problem is to calculate
     * m, given n and p.
     *
     * Now, number of stubs (i.e., printed docs) will be at least n/p
     *
     * Therefore, m >= n/p
     *
     * If n/p division is not exact, it means that some docs payable
     * are left over.  Now, the number of docs payable left over (i.e.,
     * the reminder) is necessarily less than p, because reminder is
     * always less than the divisor.
     *
     * So, the reminder docs payable will definitely fit into one stub.
     *
     * Therefore, m = n/p + r
     *
     * where r = 0, if the reminder is zero i.e., n mod p = 0
     *  else r = 1, if the reminder is non-zero i.e., n mod p > 0
     */

    l_carryover := MOD(p_num_docs_payable, p_num_lines_per_stub);

    IF (l_carryover <> 0) THEN
        l_extra_printed_doc := 1;
    ELSE
        l_extra_printed_doc := 0;
    END IF;

    l_num_printed_docs := FLOOR(p_num_docs_payable / p_num_lines_per_stub)
                              + l_extra_printed_doc;

    return l_num_printed_docs;

 END getNumPrintedDocsByFormula;

/*--------------------------------------------------------------------
 | NAME:
 |     performSpecialPaperDocHandling
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
 PROCEDURE performSpecialPaperDocHandling(
     x_paperSpecialTab   IN OUT NOCOPY paperPmtsSpecialDocsTabType,
     x_dummyPaperPmtsTab IN OUT NOCOPY IBY_PAYGROUP_PUB.paymentTabType,
     x_setupDocsTab      IN OUT NOCOPY docsTabType,
     x_overflowDocsTab   IN OUT NOCOPY overflowDocsTabType
     )
 IS
 l_doc_rec     iby_docs_payable_all%ROWTYPE;
 l_pmt_rec     IBY_PAYMENTS_ALL%ROWTYPE;

 l_payment_id  IBY_PAYMENTS_ALL.payment_id%TYPE;

 l_pmtsInPmtInstrRec IBY_PAYINSTR_PUB.pmtsInPmtInstrRecType;

--Bug 6486816
-- Previously formatting_payment_id was updated for each document of payment but
--after which x_overflowDocsTab was updates for next payment, losing the
--previous values. So, storing all the overflow docs in a new table which will
--be passed to  calling function

x_overflowDocsTab_out overflowDocsTabType;
l_begin_doc_index_outrec NUMBER := 1;

 l_module_name VARCHAR2(200) := G_PKG_NAME
                                    || '.performSpecialPaperDocHandling';
 l_begin_doc_index NUMBER := 0;
 l_end_doc_index   NUMBER := 0;

 /* payments cursor */
 CURSOR c_document_data(p_payment_id IBY_DOCS_PAYABLE_ALL.payment_id%TYPE)
 IS
 SELECT
     document_payable_id,
     payment_id,
     payment_currency_code,
     payment_function,
     formatting_payment_id,
     org_id,
     org_type
 FROM
     IBY_DOCS_PAYABLE_ALL
 WHERE
     payment_id = p_payment_id
 ORDER BY
     document_payable_id ASC
 ;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     /*
      * STEP 1:
      * Handle setup documents.
      *
      * Setup documents are dummy checks that are printed at the
      * beginning of a check print run. They are basically void checks
      * used to align the printer.
      *
      * Since each setup document is to be printed as a separate check
      * do the following:
      * a. Insert a dummy payment for each setup document that is to be
      *    printed.
      * b. For each inserted dummy payment, insert as many dummy documents
      *    payable as will fit onto the check stub of the setup document.
      * c. Add this dummy payment to the corresponding payment instruction.
      *
      * Note that setup checks are to be printed once per payment
      * instruction (not once per payment).
      */
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Performing setup document handling ..');

     END IF;
     FOR i IN x_paperSpecialTab.FIRST .. x_paperSpecialTab.LAST LOOP

         /*
          * Setup documents have to be generated once per payment
          * instruction. Generate setup docs for an instruction
          * only if the 'setup docs flag' is set to 'N'.
          */
         IF (x_paperSpecialTab(i).setup_docs_for_instr_finished <> 'Y') THEN

             FOR j IN 1 .. x_paperSpecialTab(i).num_setup_docs LOOP

                 /*
                  * Insert a dummy payment into IBY_PAYMENTS_ALL
                  * table for each setup document.
                  */

                 /*
                  * This is a new payment; Get an id for this payment
                  */
                 IBY_PAYGROUP_PUB.getNextPaymentID(l_payment_id);

                 l_pmt_rec.payment_id               := l_payment_id;
                 l_pmt_rec.payment_profile_id       :=  -1;
                 l_pmt_rec.payment_status           := 'VOID_BY_SETUP';
                 l_pmt_rec.payment_amount           := 0;
                 l_pmt_rec.internal_bank_account_id := -1;
                 l_pmt_rec.created_by               := fnd_global.user_id;
                 l_pmt_rec.creation_date            := sysdate;
                 l_pmt_rec.last_updated_by          := fnd_global.user_id;
                 l_pmt_rec.last_update_date         := sysdate;
                 l_pmt_rec.last_update_login        := fnd_global.login_id;
                 l_pmt_rec.object_version_number    := 1;
                 l_pmt_rec.ext_payee_id             := -1;
                 l_pmt_rec.payment_service_request_id := -1;

                 /*
                  * Fix for bug 5336487:
                  *
                  * For setup checks, set the payment currency
                  * to '-1'.
                  */
                 l_pmt_rec.payment_currency_code    := '-1';

                 l_pmt_rec.org_id                   := -1;
                 l_pmt_rec.org_type                 := 'OPERATING_UNIT';
                 l_pmt_rec.legal_entity_id          := -1;

                 /*
                  * Fix for bug 5336487:
                  *
                  * For setup checks, set the payment function
                  * to '-1'.
                  */
                 l_pmt_rec.payment_function         := '-1';

                 l_pmt_rec.process_type             := 'STANDARD';
                 l_pmt_rec.payments_complete_flag   := 'N';
                 l_pmt_rec.bill_payable_flag        := 'N';
                 l_pmt_rec.exclusive_payment_flag   := 'N';
                 l_pmt_rec.declare_payment_flag     := 'N';
                 l_pmt_rec.pregrouped_payment_flag  := 'N';
                 l_pmt_rec.stop_confirmed_flag      := 'N';
                 l_pmt_rec.stop_released_flag       := 'N';
                 l_pmt_rec.stop_request_placed_flag := 'N';
                 l_pmt_rec.separate_remit_advice_req_flag
                                                    := 'N';
                 l_pmt_rec.payment_method_code      := '-1';

                 /*
                  * Set the instruction id for this payment to the
                  * currently running payment instruction id
                  */
                 l_pmt_rec.payment_instruction_id   := x_paperSpecialTab(i).
                                                           instruction_id;

                 /* add payment to PLSQL table of payments */
                 /* this will be used to insert into IBY_PAMENTS table */
                 x_dummyPaperPmtsTab(x_dummyPaperPmtsTab.COUNT + 1)
                     := l_pmt_rec;

                 /*
                  * No need to add this payment to the payment instructions
                  * PLSQL table 'x_pmtsInPmtInstrTab'. This is because
                  * setup payments are dummy payments that are handled
                  * separately.
                  */

                 /*
                  * For each dummy payment, insert corresponding dummy
                  * documents. Insert as many dummy documents as will
                  * fit into the stub of the printed document.
                  */

                 /*
                  * Fix for bug 5642449:
                  *
                  * Only create dummy documents to stamp on the setup
                  * check if we know the number of lines per stub.
                  * Otherwise, simply create the setup checks without
                  * populating the check stub with document ids (because
                  * we do not know how many document ids will fit on the
                  * check stub).
                  */
                 IF (x_paperSpecialTab(i).num_lines_per_stub IS NOT NULL AND
                     x_paperSpecialTab(i).num_lines_per_stub > 0) THEN

                     FOR k IN 1 .. x_paperSpecialTab(i).num_lines_per_stub LOOP

                         /*
                          * This is a new document; Get an id for this document
                          */
                         l_doc_rec.document_payable_id :=
                             IBY_DISBURSE_SUBMIT_PUB_PKG.
                                 getNextDocumentPayableID();

                         /*
                          * By default, set the formatting payment id to
                          * payment id for each document
                          */
                         l_doc_rec.formatting_payment_id :=
                             l_doc_rec.document_payable_id;
                         l_doc_rec.calling_app_id        := -1;
                         l_doc_rec.document_type         := 'INVOICE';
                         l_doc_rec.document_status       := 'VOID_BY_SETUP';
                         l_doc_rec.payment_id            := l_payment_id;
                         l_doc_rec.payment_amount        := -1;
                         l_doc_rec.payment_method_code   := -1;
                         l_doc_rec.exclusive_payment_flag:= 'N';
                         l_doc_rec.payee_party_id        := -1;
                         l_doc_rec.legal_entity_id       := -1;
                         l_doc_rec.created_by            := fnd_global.user_id;
                         l_doc_rec.creation_date         := sysdate;
                         l_doc_rec.last_updated_by       := fnd_global.user_id;
                         l_doc_rec.last_update_date      := sysdate;
                         l_doc_rec.last_update_login     := fnd_global.login_id;
                         l_doc_rec.object_version_number := 1;

                         /*
                          * Fix for bug 5336487:
                          *
                          * For setup documents, set the payment currency
                          * to '-1'.
                          */
                         l_doc_rec.document_currency_code:= '-1';
                         l_doc_rec.payment_currency_code := '-1';

                         l_doc_rec.payment_service_request_id
                                                         := -1;
                         l_doc_rec.org_id                := -1;
                         l_doc_rec.org_type              := 'OPERATING_UNIT';
                         l_doc_rec.calling_app_doc_unique_ref1 := '-1';
                         l_doc_rec.calling_app_doc_unique_ref2 := '-1';
                         l_doc_rec.calling_app_doc_unique_ref3 := '-1';
                         l_doc_rec.calling_app_doc_unique_ref4 := '-1';
                         l_doc_rec.calling_app_doc_unique_ref5 := '-1';
                         l_doc_rec.pay_proc_trxn_type_code
                                                         := '-1';

                         /*
                          * Fix for bug 5336487:
                          *
                          * For setup documents, set the payment function
                          * to '-1'.
                          */
                         l_doc_rec.payment_function      := '-1';

                         l_doc_rec.calling_app_doc_ref_number := -1;
                         l_doc_rec.payment_date          := sysdate;
                         l_doc_rec.document_date         := sysdate;
                         l_doc_rec.document_amount       := 0;
                         l_doc_rec.straight_through_flag := 'Y';
                         l_doc_rec.allow_removing_document_flag := 'N';
                         l_doc_rec.ext_payee_id          := -1;

                         /* add document to PLSQL table of documents */
                         x_setupDocsTab(x_setupDocsTab.COUNT + 1)  := l_doc_rec;

                     END LOOP; -- for num_lines_per_stub

                 ELSE

                     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                     print_debuginfo(l_module_name, 'Setup checks will not '
	                         || 'contain invoice numbers because number of lines '
	                         || 'per stub is unknown.'
	                         );

                     END IF;
                 END IF; -- if num lines per stub is not null

             END LOOP; -- for num_setup_docs in payment

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Added '
	                 || x_paperSpecialTab(i).num_setup_docs
	                 || ' setup payments with '
	                 ||  x_paperSpecialTab(i).num_lines_per_stub
	                 || ' dummy documents payable each, to payment instruction '
	                 || x_paperSpecialTab(i).instruction_id
	                 );

             END IF;
             /*
              * Once we have finished generating setup documents for an
              * instruction, set the 'setup docs flag' to 'Y' for all
              * records with the same instruction id in the paperSpecialTab
              * PLSQL table. This is to prevent the code fro generating
              * setup docs more than once for a payment instruction.
              */
             updateSetupDocsFlagForInstr(x_paperSpecialTab(i).instruction_id,
                 x_paperSpecialTab);

         END IF; -- if setup_docs_for_instr_finished <> 'Y'

     END LOOP; -- for each pmt in instruction with process type 'PAPER'

     /*
      * STEP 2:
      * Handle overflow documents.
      *
      * The number of lines that can be printed onto a check stub
      * is limited by the physical dimenensions of the paper stock.
      * The number of lines per stub is available as an attribute of
      * the paper stock.
      *
      * In each line on the stub, we will print the id of the
      * documents payable that are paid by that check.
      * So one check, can accomodate 'n' documents payable where
      * 'n' is the number of lines per stub for the paper stock
      * of the check.
      *
      * If a payment has more documents payable lined to it than
      * will fit onto the check stub, do the following:
      *
      * a. Calculate the number of overflow checks that need to
      *    be printed to accomodate the excess documents payable.
      *    (this is already accomplished by the document numbering
      *     flow).
      * b. For each overflow check, insert a dummy payment.
      * c. Add this dummy payment to the correspoding payment instruction.
      */
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Performing overflow document '
	         || 'handling ..');

     END IF;
     FOR i IN x_paperSpecialTab.FIRST .. x_paperSpecialTab.LAST LOOP

         /*
          * Pull up all the documents associated with this payment id.
          * The format_payment_id of these documents will be changed
          * to handle overflows.
          *
          * Only do this if a payment has non-zero overflow documents.
          */
         IF (x_paperSpecialTab(i).num_overflow_docs IS NOT NULL AND
             x_paperSpecialTab(i).num_overflow_docs > 0) THEN

             OPEN  c_document_data(x_paperSpecialTab(i).payment_id);
             FETCH c_document_data BULK COLLECT INTO x_overflowDocsTab;
             CLOSE c_document_data;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Payment '
	                 || x_paperSpecialTab(i).payment_id
	                 || ' has overflow documents payable. '
	                 || x_paperSpecialTab(i).num_overflow_docs
	                 || ' overflow paper payments will be '
	                 || ' created for this payment.'
	                 );

             END IF;
         END IF;

         /* initialize indices on overflow docs array before entering loop */
         l_begin_doc_index := 1;
         l_end_doc_index   := 0;

         /*
          * If there are no overflow docs for a payment, that payment
          * will not enter this loop.
          */

         /*
          * Fix for bug 5252629:
          *
          * If number of overflow docs is null for a payment, it means
          * that the user did not specify the number of lines per
          * stub for the check stock that the payment is meant to
          * be printed on.
          *
          * In this case we cannot do overflow handling. Handle this
          * situation gracefully by skipping overflow handling.
          */
         IF ( x_paperSpecialTab(i).num_overflow_docs IS NOT NULL) THEN

             /* informative debug message */
             IF (x_paperSpecialTab(i).num_overflow_docs = 0) THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Overflow handling not '
	                     || 'required for payment instruction '
	                     || x_paperSpecialTab(i).instruction_id
	                     );

                 END IF;
             END IF;

             FOR j IN 1 .. x_paperSpecialTab(i).num_overflow_docs LOOP

                 /*
                  * Insert a dummy payment into IBY_PAYMENTS_ALL
                  * table for each set of overflow documents.
                  */

                 /*
                  * This is a new payment; Get an id for this payment
                  */
                 IBY_PAYGROUP_PUB.getNextPaymentID(l_payment_id);

                 l_pmt_rec.payment_id               := l_payment_id;
                 l_pmt_rec.payment_profile_id       :=  -1;
                 l_pmt_rec.payment_status           := 'VOID_BY_OVERFLOW';
                 l_pmt_rec.payment_amount           := 0;
                 l_pmt_rec.internal_bank_account_id := -1;
                 l_pmt_rec.created_by               := fnd_global.user_id;
                 l_pmt_rec.creation_date            := sysdate;
                 l_pmt_rec.last_updated_by          := fnd_global.user_id;
                 l_pmt_rec.last_update_date         := sysdate;
                 l_pmt_rec.last_update_login        := fnd_global.login_id;
                 l_pmt_rec.object_version_number    := 1;
                 l_pmt_rec.ext_payee_id             := -1;
                 l_pmt_rec.payment_service_request_id
                                                := -1;

                 /*
                  * Fix for bug 5336487:
                  *
                  * For overflow documents, set the currency
                  * of the documents to the currency of the
                  * parent payment (instead of hardcoding to
                  * a dummy value).
                  *
                  * Since grouping by payment curency is a
                  * hardcoded grouping rule, we can use the
                  * payment currency from any real document
                  * of this payment.
                  */
                 l_pmt_rec.payment_currency_code    := x_overflowDocsTab(1).
                                                           pmt_currency;

                 /*
                  * Fix for bug 5332172:
                  *
                  * Do not hardcode the org id to -1 because the UI
                  * restricts the viewing of these payments by org.
                  *
                  * Instead, use the org id of one of the overflow
                  * documents payable that will be printed on this
                  * overflow payment.
                  *
                  * We can use any of the documents that will be
                  * part of this payment because all documents
                  * payable that are part of a payment are guaranteed
                  * to have the same (org id, org type); this is
                  * a hardcoded grouping rule.
                  */
                 l_pmt_rec.org_id                   := x_overflowDocsTab(1).
                                                           org_id;
                 l_pmt_rec.org_type                 := x_overflowDocsTab(1).
                                                           org_type;

                 l_pmt_rec.legal_entity_id          := -1;

                 /*
                  * Fix for bug 5336487:
                  *
                  * For overflow payments, set the payment function
                  * to the same as it's child documents.
                  *
                  * Since grouping by payment function is a hardcoded
                  * grouping rule, we can pick up the payment
                  * function from any of the documents and set it to
                  * the payment.
                  */
                 l_pmt_rec.payment_function         := x_overflowDocsTab(1).
                                                           pmt_function;

                 l_pmt_rec.process_type             := 'STANDARD';
                 l_pmt_rec.payments_complete_flag   := 'N';
                 l_pmt_rec.bill_payable_flag        := 'N';
                 l_pmt_rec.exclusive_payment_flag   := 'N';
                 l_pmt_rec.declare_payment_flag     := 'N';
                 l_pmt_rec.pregrouped_payment_flag  := 'N';
                 l_pmt_rec.stop_confirmed_flag      := 'N';
                 l_pmt_rec.stop_released_flag       := 'N';
                 l_pmt_rec.stop_request_placed_flag := 'N';
                 l_pmt_rec.separate_remit_advice_req_flag
                                                := 'N';
                 l_pmt_rec.payment_method_code      := '-1';

                 /*
                  * KLUDGE:
                  *
                  * We are creating a dummy payment to store overflow
                  * documents. These payments are actually part of a real
                  * payment indicated by x_paperSpecialTab(i).payment_id.
                  *
                  * When it is time for check numbering, we want to number
                  * the real payment and the dummy payments contiguously.
                  * Therefore, we need to know what dummy payments are
                  * related to which real payment.
                  *
                  * The l_pmt_rec structure cannot store the real payment
                  * id because it is exactly mapped to a row in
                  * IBY_PAYMENTS_ALL.
                  *
                  * Instead of creating a new data structure to hold
                  * (real payment id, dummy payment id), we use an
                  * optional field in the l_pmt_rec record to store the
                  * real payment id.
                  *
                  * This is the 'payee party site id' field. Since this is
                  * a dummy payment any value we provide for this field
                  * does not really matter.
                  *
                  * This field will be accessed in assignCheckNumbers()
                  * method to find out all dummy payments related to a
                  * real payment.
                  */

                 /*
                  * UPDATE:
                  * Use external_bank_account_id as the placeholder
                  * for the related original payment id. We are trying to
                  * use some field on the payment, that is relatively
                  * useless, to store some extra information.
                  *
                  * The external bank account id is a good candidate
                  * for this because this field is expected to be
                  * not used for paper payments anyway. The payee
                  * party site id field will be overwritten with data
                  * from the original payment as part of fix for
                  * bug 6765314.
                  *
                  * Even though, we really don't need this link between
                  * the overflow payment and the original payment
                  * outside of this package, it would be a good idea to
                  * persist this information somehow so that we can
                  * quickly answer the question "What is the original
                  * payment that this overflow payment is related to?"
                  *
                  * Ideally we should have a specific column on the
                  * payment to store this information, so that we don't
                  * have these kludges.
                  */
                 l_pmt_rec.external_bank_account_id :=
                     x_paperSpecialTab(i).payment_id;

                 /*
                  * Set the instruction id for this payment to the
                  * currently running payment instruction id
                  */
                 l_pmt_rec.payment_instruction_id   := x_paperSpecialTab(i).
                                                       instruction_id;

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Creating dummy overflow '
	                     || ' payment '
	                     || l_payment_id
	                     || ' for payment '
	                     || x_paperSpecialTab(i).payment_id
	                     );

                 END IF;
                 /* add payment to PLSQL table of payments */
                 x_dummyPaperPmtsTab(x_dummyPaperPmtsTab.COUNT + 1)
                     := l_pmt_rec;

                 /*
                  * No need to add this payment to the payment instructions
                  * PLSQL table 'x_pmtsInPmtInstrTab'. This is because
                  * overflow payments are dummy payments that are handled
                  * separately.
                  */

                 /*
                  * We have just created a dummy payment for overflow
                  * purposes.
                  *
                  * Some documents will need to be updated so that their
                  * formatting_payment_id is set to the id of the dummy
                  * payment that we just created.
                  *
                  * Originally, all documents will have the same value
                  * for payment_id and formatting_payment_id. When there
                  * are overflow documents, then the following will happen:
                  *
                  * a. Documents that will fit into one stub will
                  *    contain payment_id same as original document
                  *    id.
                  *
                  * b. All documents that will not fit into the stub (a)
                  *    will have to printed on void checks. These will
                  *    be identified because for these documents the
                  *    formatting_payment_id <> the payment id.
                  *
                  * So at this point, we have to identify documents
                  * for this payment that will not fit into the first
                  * stub and change their formatting_payment_id to the one
                  * that we generated for the dummy payment. We do this in
                  * a loop to finish all excess documents.
                  *
                  * Example,
                  * Payment 102 contains 10 documents.
                  * Check stub contains space for 4 document lines.
                  *
                  * Therefore, number of printed checks will be
                  * (4 docs)     +  (4 docs)     + (2 docs)      =  3 checks
                  * [Void check]    [Void check]   [Real check]
                  *
                  * One check will be the real check, 2 checks are overflow.
                  * We have already calculated the number of overflow
                  * checks by the time we come here.
                  *
                  * We need to link the documents that will fit into the
                  * overflow checks to the dummy payments (void checks)
                  * that we just created.
                  */

                 /*
                  * Change the format_payment_id of 'n' documents of this
                  * payment to the dummy payment id, where 'n' = num lines
                  * that will fit on the stub.  These 'n' documents
                  * will be printed on a voided check.
                  */

                 /*
                  * Make sure that the end index does not exceed the
                  * size of the docs array.
                  */

                 /* need to subtract 1 because 'begin index' is 1 based */
                 IF (l_begin_doc_index +
                     (x_paperSpecialTab(i).num_lines_per_stub - 1)
                         > x_overflowDocsTab.COUNT) THEN

                     l_end_doc_index := x_overflowDocsTab.COUNT;

                 ELSE

                     l_end_doc_index := l_begin_doc_index +
                                            (x_paperSpecialTab(i).
                                                num_lines_per_stub - 1);

                 END IF;

                 FOR k IN l_begin_doc_index .. l_end_doc_index LOOP

                     x_overflowDocsTab(k).format_payment_id := l_payment_id;
-- Bug 6486816- copying the overfloW record into the out parameter
                     x_overflowDocsTab_out(l_begin_doc_index_outrec) :=x_overflowDocsTab(k);
                     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                     print_debuginfo(l_module_name, 'For document '
	                         || x_overflowDocsTab(k).doc_id
	                         || ' with pmt id '
	                         || x_overflowDocsTab(k).payment_id
	                         || ' format pmt id set to '
	                         || x_overflowDocsTab(k).format_payment_id
	                         );

                     END IF;
                     l_begin_doc_index := l_begin_doc_index + 1;
                     l_begin_doc_index_outrec := l_begin_doc_index_outrec + 1;
                 END LOOP;

             END LOOP; -- for num_overflow_docs in payment

         ELSE

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Not creating any '
	                 || 'overflow payments for payment instruction '
	                 || x_paperSpecialTab(i).instruction_id
	                 || ' because num lines per stub is not specified '
	                 || 'for the associated payment document.'
	                 );

             END IF;
         END IF; -- if num overflow docs is not null

         IF (x_paperSpecialTab(i).num_overflow_docs IS NOT NULL AND
             x_paperSpecialTab(i).num_overflow_docs > 0) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Added '
	                 || x_paperSpecialTab(i).num_overflow_docs
	                 || ' overflow payments to payment instruction '
	                 || x_paperSpecialTab(i).instruction_id
	                 );

             END IF;
         END IF;

     END LOOP; -- for each pmt in instruction with process type 'PAPER'
-- Bug 6486816- copy the overflow documents table with all details to
--the variable that is passed to calling function.
            x_overflowDocsTab := x_overflowDocsTab_out;
     IF (x_overflowDocsTab.COUNT > 0) THEN

         FOR i IN x_overflowDocsTab.FIRST .. x_overflowDocsTab.LAST LOOP

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Doc id '
	                 || x_overflowDocsTab(i).doc_id
	                 || ', payment id: '
	                 || x_overflowDocsTab(i).payment_id
	                 || ', format payment id: '
	                 || x_overflowDocsTab(i).format_payment_id
	                 );

             END IF;
         END LOOP;

     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END performSpecialPaperDocHandling;

/*--------------------------------------------------------------------
 | NAME:
 |     updateSetupDocsFlagForInstr
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
 PROCEDURE updateSetupDocsFlagForInstr(
     p_instrId         IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE,
     x_paperSpecialTab IN OUT NOCOPY paperPmtsSpecialDocsTabType
     )
 IS
 BEGIN

     /*
      * Loop through all the paper payments table. If we find any
      * payment instruction that matches the given payment
      * instruction, set the 'set up docs' flag for the payment
      * instruction to 'Y' to indicate that setup documents
      * have already been generated for this payment instruction.
      */
     FOR i IN x_paperSpecialTab.FIRST .. x_paperSpecialTab.LAST LOOP

         IF (x_paperSpecialTab(i).instruction_id = p_instrId) THEN
             x_paperSpecialTab(i).setup_docs_for_instr_finished := 'Y';
         END IF;

     END LOOP;

 END updateSetupDocsFlagForInstr;

/*--------------------------------------------------------------------
 | NAME:
 |     updatePmtsWithCheckNumbers
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
 PROCEDURE updatePmtsWithCheckNumbers(
     p_pmtsInPayInstTab  IN IBY_PAYINSTR_PUB.pmtsInpmtInstrTabType
     )
 IS
 l_module_name VARCHAR2(200) := G_PKG_NAME || '.updatePmtsWithCheckNumbers';

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     /* Normally, this should not happen */
     IF (p_pmtsInPayInstTab.COUNT = 0) THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'No payments '
	             || 'were provided to update '
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
             paper_document_number = p_pmtsInPayInstTab(i).check_number
         WHERE
             payment_id = p_pmtsInPayInstTab(i).payment_id
         AND payment_status = p_pmtsInPayInstTab(i).payment_status;

     END LOOP;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END updatePmtsWithCheckNumbers;

/*--------------------------------------------------------------------
 | NAME:
 |    isPaperDocNumUsed
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
 PROCEDURE isPaperDocNumUsed(
     p_payment_doc_id IN IBY_USED_PAYMENT_DOCS.payment_document_id%TYPE,
     x_paper_doc_num  IN IBY_USED_PAYMENT_DOCS.used_document_number%TYPE,
     x_return_status  IN OUT NOCOPY VARCHAR2
     )
 IS

 l_module_name VARCHAR2(200) := G_PKG_NAME || '.isPaperDocNumUsed';
 l_used_paper_doc_number NUMBER := 0;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     /*
      * Check if this paper document number has already
      * been used.
      */
     BEGIN

         SELECT
             used_document_number
         INTO
             l_used_paper_doc_number
         FROM
             IBY_USED_PAYMENT_DOCS
         WHERE
             payment_document_id  = p_payment_doc_id AND
             used_document_number = x_paper_doc_num
         ;

     EXCEPTION

         WHEN NO_DATA_FOUND THEN

             /* now rows means success */
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Paper document '
	                 || 'number '
	                 || x_paper_doc_num
	                 || ' is unused.'
	                 );

             END IF;
         WHEN OTHERS THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Exception occured when '
	                 || 'attempting to get details of paper document '
	                 || x_paper_doc_num
	                 || ' from IBY_USED_PAYMENT_DOCS table.'
	                 );

	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);

             END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Returning error response ..');

	             print_debuginfo(l_module_name, 'EXIT');

             END IF;
             RETURN;

     END;


     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Returning success response ..');
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END isPaperDocNumUsed;

/*--------------------------------------------------------------------
 | NAME:
 |    isSinglePayment
 |
 | PURPOSE:
 |    Determines whether the provided list of payments consists of a
 |    single payment.
 |
 |    If the following conditions are satisfied
 |
 |       a. Only one payment is present in the provided list of payments
 |       b. The payment service request of the provided payment
 |          has process type 'IMMEDIATE'
 |
 |    then the payment is considered to be a single payment.
 |
 | PARAMETERS:
 |     IN
 |         p_paperPmtsTab - PLSQL table of paper payments. Ensure that
 |                          this table only consists of real paper payments
 |                          (no dummy payments - setup or overflow payments
 |                          - should be included in this list).
 |     OUT
 |         NONE
 |
 | RETURNS:
 |         BOOLEAN        - TRUE, if the provided payments list consists of
 |                                a single payment
 |                          FALSE, otherwise
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 FUNCTION isSinglePayment(
     p_paperPmtsTab      IN paperPmtsSpecialDocsTabType
     ) RETURN BOOLEAN
 IS

 l_module_name       VARCHAR2(200) := G_PKG_NAME || '.isSinglePayment';

 l_retflag      BOOLEAN;
 l_process_type IBY_PAY_SERVICE_REQUESTS.process_type%TYPE;
 l_pmt_rec      paperPmtsSpecialDocsRecType;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     IF (p_paperPmtsTab.COUNT = 0) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Paper payments list is empty. '
	             || 'Returning false ..'
	             );

         END IF;
         l_retflag := FALSE;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN l_retflag;

     END IF;

     IF (p_paperPmtsTab.COUNT <> 1) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Paper payments count is more '
	             || 'than 1. Returning false ..'
	             );

         END IF;
         l_retflag := FALSE;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN l_retflag;

     END IF;

     /*
      * If we reached here, it means that there is only one
      * paper payment in the provided payment array.
      *
      * Look up the process type of the payment service request
      * to confirm that the process type is IMMEDIATE.
      *
      * These two conditions are necessary and sufficient to
      * determine whether a payment is a single payment.
      */
     BEGIN

         l_pmt_rec := p_paperPmtsTab(p_paperPmtsTab.FIRST);

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Provided payment id is '
	             || l_pmt_rec.payment_id
	             );

         END IF;
         SELECT
             req.process_type
         INTO
             l_process_type
         FROM
             IBY_PAY_SERVICE_REQUESTS req,
             IBY_PAYMENTS_ALL pmt
         WHERE
             req.payment_service_request_id =
                 pmt.payment_service_request_id         AND
             pmt.payment_id = l_pmt_rec.payment_id
         ;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Processing type of parent '
	             || 'request is '
	             || l_process_type
	             );

         END IF;
         /*
          * Set the return flag based on the processing type.
          */
         IF (l_process_type = 'IMMEDIATE') THEN

             l_retflag := TRUE;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Setting return flag '
	                || 'to true.'
	                );

             END IF;
         ELSE

             l_retflag := FALSE;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Setting return flag '
	                || 'to false because processing type is not IMMEDIATE.'
	                );

             END IF;
         END IF;

     EXCEPTION
         WHEN OTHERS THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Fatal: Exception when attempting '
	                 || 'to get processing type for payment '
	                 || l_pmt_rec.payment_id,
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

     END;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');
     END IF;
     RETURN l_retflag;

 END isSinglePayment;

/*--------------------------------------------------------------------
 | NAME:
 |    isContigPaperNumAvlbl
 |
 |
 | PURPOSE:
 |    Checks whether the paper document numbers from the given start
 |    number to the given end number are available contiguoulsy for
 |    printing.
 |
 |    For the purpose of printing checks, we should always presume
 |    the the user is going to print checks on prenumbered check stock
 |    on a tractor feed. Therefore, the check numbering should always
 |    be contiguous.
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
 FUNCTION isContigPaperNumAvlbl(
     p_payment_doc_id IN CE_PAYMENT_DOCUMENTS.payment_document_id%TYPE,
     p_start_number   IN IBY_PAYMENTS_ALL.paper_document_number%TYPE,
     p_end_number     IN IBY_PAYMENTS_ALL.paper_document_number%TYPE
     ) RETURN BOOLEAN
 IS

 l_module_name    VARCHAR2(200) := G_PKG_NAME || '.isContigPaperNumAvlbl';
 l_retflag        BOOLEAN;
 l_paper_doc_num  IBY_PAYMENTS_ALL.paper_document_number%TYPE;

 l_api_version    CONSTANT NUMBER       := 1.0;
 l_return_status  VARCHAR2 (100);

 l_msg_count      NUMBER;
 l_msg_data       VARCHAR2(3000);
 l_test           VARCHAR2(200) :='TRUE';

 l_last_issued_doc_num NUMBER;
 l_last_avail_doc_num NUMBER;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

	     print_debuginfo(l_module_name, 'Start #: '
	         || p_start_number
	         || ', end #: '
	         || p_end_number
	         || ', payment document: '
	         || p_payment_doc_id
	         );

     END IF;
     IF (p_start_number   IS NULL OR
         p_end_number     IS NULL OR
         p_payment_doc_id IS NULL
         ) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Provided params are invalid. '
	             || 'Returning false.');

         END IF;
         l_retflag := FALSE;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');
         END IF;
         RETURN l_retflag;

     END IF;

     /*
      * Validate the entire contiguous range of provided
      * paper document numbers. If even a single paper
      * document number fails validation, it means that
      * we do not have a contiguous rage of paper document
      * numbers available.
      */
     l_retflag := TRUE;

     /*
      * Performance Fix:
      *
      * This method has been re-written so that it does not loop
      * through every paper document number within the range validating
      * one-by-one.
      *
      * Now, it simply executes two SQL statements to verify whether
      * the given print range is valid.
      */

     BEGIN

         /*
          * First check against CE_PAYMENT_DOCUMENTS table whether
          * the start_number is greater than the last_issued_document_number
          * and the end_number is less than / equal to the last_available
          * _document_number.
          *
          * Two, special situations are possible here:
          * 1. last_issued_document_number = 0, this means that check has never
          *    been used so far. In this case, we should allow any start_number.
          *
          * 2. last_available_document_number is null, this means that there
          *    is no upper limit for the check numbers. In this case, we
          *    allow any end_number.
	  *
	  *
	  *  Bug 8968846: Start number need not be validated on the last issued
	  * document number. For the batch flow, start number is generated based
	  * on the last issued document number.
	  * In case of single payment flow, user can choose any unused document
	  * number which is less than last issued document number.
	  *
	  *   So to process the flow smoothly in both cases, validation on the
	  * start number is removed.
          */


             SELECT
                 pmt_doc.last_issued_document_number,
                 pmt_doc.last_available_document_number
             INTO
	         l_last_issued_doc_num,
		 l_last_avail_doc_num
             FROM
                 CE_PAYMENT_DOCUMENTS pmt_doc
             WHERE
                 pmt_doc.payment_document_id = p_payment_doc_id ;


     EXCEPTION
         WHEN OTHERS THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Exception occured when checking for '
	                 || 'provided check range against CE_PAYMENT_DOCUMENTS table.');
	             print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	             print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);

             END IF;
             l_retflag := FALSE;

     END;

     /*  Bug 8968846:
      *  Logic for validating the start number and end number
      *  is moved here
      */
     IF (nvl(l_last_avail_doc_num, p_end_number) < p_end_number) THEN

            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		     print_debuginfo(l_module_name, 'Last available '
			 || 'paper document number is '
			 || l_last_avail_doc_num
			 );

		     print_debuginfo(l_module_name, ' Last paper document number '
			 || p_end_number
			 || ' is above last available document number '
			 || l_last_avail_doc_num
			 );
	     END IF;

             FND_MESSAGE.set_name('IBY', 'IBY_DOC_NUM_ABOVE_ALLOWED');

             FND_MESSAGE.SET_TOKEN('LAST_AVAILABLE_DOC_NUM',
                 l_last_avail_doc_num,
                 FALSE);

             FND_MSG_PUB.ADD;

             l_retflag := FALSE;
	     l_test := 'FALSE';
     END IF;



     IF (l_test = 'TRUE') THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Provided print range is valid in '
	             || 'CE_PAYMENT_DOCUMENTS table. Verifying if any document within '
	             || 'is already USED / SPOILED ..'
	             );

         END IF;
         BEGIN

             /*
              * Next check if any USED / SPOILED documents already exist
              * for this payment document in the provided check
              * range.
              *
              * If such a USED / SPOILED document already exists, then
              * we cannot use this range of numbers for printing.
              */
             SELECT
                 'TRUE'
             INTO
                 l_test
             FROM
                 DUAL
             WHERE EXISTS
                 (
                 SELECT
                     used_document_number
                 FROM
                     IBY_USED_PAYMENT_DOCS
                 WHERE
                     payment_document_id = p_payment_doc_id     AND
                     document_use <> 'SKIPPED' AND
                     used_document_number >= p_start_number AND
                     used_document_number <= p_end_number
                 )
             ;

             IF (l_test = 'TRUE') THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Provided print range is not valid because '
	                     || 'some documents with this range are already USED / SPOILED. '
	                     || 'You cannot use this print range.'
	                     );

                 END IF;
                 l_retflag := FALSE;

             ELSE

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Provided print range is valid because '
	                     || 'no documents with this range are already USED / SPOILED. '
	                     || 'You can use this print range.'
	                     );

                 END IF;
                 l_retflag := TRUE;

             END IF;


         EXCEPTION
             WHEN NO_DATA_FOUND THEN
                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'No data was found occured when checking if any '
	                     || 'USED / SPOILED documents exist in provided check range.');
	                 print_debuginfo(l_module_name, 'This means no SPOILED / USED checks '
	                     || 'exist for the given check range. Range is valid.');
                 END IF;
                 l_retflag := TRUE;

             WHEN OTHERS THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Exception occured when checking if any '
	                     || 'USED / SPOILED documents exist in provided check range.');
	                 print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	                 print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);

                 END IF;
                 l_retflag := FALSE;

         END;

     ELSE

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Provided print range is not valid in '
	             || 'CE_PAYMENT_DOCUMENTS table. You cannot use this print range.'
	             );

         END IF;
         l_retflag := FALSE;

     END IF;


     IF (l_retflag = FALSE) THEN

         /*
          * Fix for bug 5327347:
          *
          * If we reach here, it means that one of the paper documents
          * in the supplied range has already been used.
          *
          * This means that we will need to display to the
          * user a message like 'sufficient contiguous payment
          * documents are not available to print this instruction.'
          *
          * However, the message 'paper doc number # has already been
          * used' has been set in the FND message stack already
          * by the IBY_DISBURSE_UI_API_PUB_PKG.validate_paper_doc_number(..)
          * method.
          *
          * Clear this message from the stack as it is redundant.
          */
         FND_MSG_PUB.initialize;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning FALSE');
         END IF;
     ELSE
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning TRUE');
         END IF;
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');
     END IF;
     RETURN l_retflag;

 END isContigPaperNumAvlbl;

/*--------------------------------------------------------------------
 | NAME:
 |    isPaperNosUsedOnExistPmt
 |
 | PURPOSE:
 |    Checks whether the paper document numbers from the given start
 |    number to the given end number are already used on any existing
 |    payments.
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
 FUNCTION isPaperNosUsedOnExistPmt(
     p_payment_doc_id IN CE_PAYMENT_DOCUMENTS.payment_document_id%TYPE,
     p_start_number   IN IBY_PAYMENTS_ALL.paper_document_number%TYPE,
     p_end_number     IN IBY_PAYMENTS_ALL.paper_document_number%TYPE
     ) RETURN BOOLEAN
 IS

 l_module_name    VARCHAR2(200) := G_PKG_NAME || '.isPaperNosUsedOnExistPmt';
 l_retflag        BOOLEAN;

 l_paper_doc_num       IBY_PAYMENTS_ALL.paper_document_number%TYPE;
 l_test_paper_doc_num  IBY_PAYMENTS_ALL.paper_document_number%TYPE;
 l_test_pmt_id         IBY_PAYMENTS_ALL.payment_id%TYPE;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

	     print_debuginfo(l_module_name, 'Start #: '
	         || p_start_number
	         || ', end #: '
	         || p_end_number
	         || ', payment document: '
	         || p_payment_doc_id
	         );

     END IF;
     IF (p_start_number   IS NULL OR
         p_end_number     IS NULL OR
         p_payment_doc_id IS NULL
         ) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Provided params are invalid. '
	             || 'Returning true.');

         END IF;
         l_retflag := TRUE;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');
         END IF;
         RETURN l_retflag;

     END IF;

     /*
      * Validate the entire contiguous range of provided
      * paper document numbers. If even a single paper
      * document number has already been used on a payment,
      * it is an error and we will return TRUE.
      */
     l_retflag := FALSE;
     FOR i IN 1 .. (p_end_number - p_start_number + 1) LOOP    -- Bug 6922269

         l_paper_doc_num := p_start_number + i - 1;

         BEGIN

             SELECT
                 pmt.paper_document_number,
                 pmt.payment_id
             INTO
                 l_test_paper_doc_num,
                 l_test_pmt_id
             FROM
                 IBY_PAYMENTS_ALL         pmt,
                 IBY_PAY_INSTRUCTIONS_ALL inst
             WHERE
                 pmt.payment_instruction_id = inst.payment_instruction_id AND
                 inst.payment_document_id   = p_payment_doc_id AND
                 pmt.paper_document_number  = l_paper_doc_num
             ;

             /*
              * If we reached here it means that we were able to
              * successfully retrieve a payment with the provided
              * paper document number. This implies that the
              * paper document number has already been used.
              */
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Paper document number '
	                 || l_test_paper_doc_num
	                 || ' has already been used for payment id '
	                 || l_test_pmt_id
	                 );

             END IF;
             l_retflag := TRUE;

         EXCEPTION
             WHEN OTHERS THEN

             /*
              * Handle exceptions gracefully. Assume that an
              * exception means that no data was found i.e., paper
              * document number has not been used.
              */
             NULL;

         END;

     END LOOP;


     IF (l_retflag = FALSE) THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning FALSE');
         END IF;
     ELSE
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning TRUE');
         END IF;
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');
     END IF;
     RETURN l_retflag;

 END isPaperNosUsedOnExistPmt;

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
     p_debug_level IN VARCHAR2 DEFAULT FND_LOG.LEVEL_STATEMENT
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
 |     assignElectronicCheckNumbers
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
 |
 | NOTES:
 |     This method will perform a COMMIT.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE assignElectronicCheckNumbers(
     x_pmtInstrRec       IN OUT NOCOPY IBY_PAY_INSTRUCTIONS_ALL%ROWTYPE,
     p_payment_doc_id    IN CE_PAYMENT_DOCUMENTS.payment_document_id%TYPE,
     p_user_assgn_num    IN IBY_PAYMENTS_ALL.paper_document_number%TYPE,
     x_paperPmtsTab      IN OUT NOCOPY paperPmtsSpecialDocsTabType,
     x_dummyPaperPmtsTab IN OUT NOCOPY IBY_PAYGROUP_PUB.paymentTabType,
     x_instrErrorTab     IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
     x_insTokenTab       IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.
                                           trxnErrTokenTabType,
     x_return_message    IN OUT NOCOPY VARCHAR2,
     x_return_status     IN OUT NOCOPY NUMBER,
     x_msg_count         IN OUT NOCOPY NUMBER,
     x_msg_data          IN OUT NOCOPY VARCHAR2
     )
 IS

 l_paper_pmts_count     NUMBER := 0;
 l_last_used_check_num  NUMBER := 0;
 l_last_avail_check_num NUMBER := 0;
 l_physical_stock_count NUMBER := 0;
 l_anticipated_last_check_num  NUMBER := 0;

 l_pmt_doc_name      VARCHAR2(200) := '';
 l_pmt_instr_id      IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE;

 l_error_code        IBY_TRANSACTION_ERRORS.error_code%TYPE;
 l_instr_err_rec     IBY_TRANSACTION_ERRORS%ROWTYPE;
 l_token_rec         IBY_TRXN_ERROR_TOKENS%ROWTYPE;

 l_send_to_file_flag VARCHAR2(1);
 l_instr_status      IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_status%TYPE;

 l_single_pmt_flag   BOOLEAN;
 l_nos_avlbl_flag    BOOLEAN;
 l_used_flag         BOOLEAN;

 l_module_name       VARCHAR2(200) := G_PKG_NAME || '.assignCheckNumbers';

 BEGIN

     IF (G_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        print_debuginfo(l_module_name, 'ENTER');
     END IF;

     l_paper_pmts_count := x_paperPmtsTab.COUNT;

     /* should never come into if, but just in case */
     IF (l_paper_pmts_count = 0) THEN

         /*
          * Shouldn't come here. This method was called because there
          * was atleast one payment instruction with processing type
          * 'PAPER'. This implies that there should be at least one
          * payment instruction with processing type 'PAPER'.
          *
          * If no such payment exists, about the program.
          */
         IF (G_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          print_debuginfo(l_module_name, 'Total # of Electronic payments '
             || 'is 0. Possible data corruption. Aborting ..'
             );


         print_debuginfo(l_module_name, 'EXIT');
         END IF;
         x_return_status := -1;

         l_error_code := 'IBY_INS_PMTS_NOT_FOUND';
         FND_MESSAGE.set_name('IBY', l_error_code);

         FND_MESSAGE.SET_TOKEN('INS_ID',
             x_pmtInstrRec.payment_instruction_id,
             FALSE);

         FND_MSG_PUB.ADD;

         FND_MSG_PUB.COUNT_AND_GET(
             p_count => x_msg_count,
             p_data  => x_msg_data
             );

         x_return_message := FND_MESSAGE.get;

         RETURN;
     ELSE
         IF (G_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           print_debuginfo(l_module_name, 'Total # of Electronic payments: '
             || l_paper_pmts_count
             );
         END IF;

     END IF;

     /*
      * Check whether the provided payments list consists
      * of a single payment.
      */
     l_single_pmt_flag := isSinglePayment(x_paperPmtsTab);

     /*
      * For single payments, do not perform any commits because
      * single payments API is session based and only the caller
      * decides to commit / not commit.
      */
     IF (l_single_pmt_flag <> TRUE) THEN

         /*
          * This commit is needed so that in case of any exceptions
          * in this method (e.g., payment document locked), the
          * payment instruction status is changed from 'CREATED'
          * to the next valid status.
          *
          * Payments in 'CREATED' status are not visible in the UI,
          * this is because 'CREATED' is a transient status.
          */
         COMMIT;

         IF (G_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           print_debuginfo(l_module_name, 'Payment instruction '
             || x_pmtInstrRec.payment_instruction_id
             || ' status committed to '
             || l_instr_status
             || ' before numbering.'
             );
         END IF;

     END IF;

     /*
      * Pull up the details of the paper stock, like the
      * last used check number and the last available
      * check number.
      *
      * Note: This SELECT will lock the underlying base
      * table IBY_PAYMENT_DOCUMENTS_B. We need to lock this
      * table because we need to update the last_document_number.
      */
    SELECT
         payment_document_name,
         payment_instruction_id
     INTO
         l_pmt_doc_name,
         l_pmt_instr_id
     FROM
         CE_PAYMENT_DOCUMENTS
     WHERE
         payment_document_id = p_payment_doc_id
     ;


      IF (G_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       print_debuginfo(l_module_name, 'Got the payment document name');
      END IF;

     /*
      *
      * Pull up the details of the paper stock, like the
      * last used check number and the last available
      * check number.
      *
      * Note: This SELECT will lock the underlying base
      * table IBY_PAYMENT_DOCUMENTS_B. We need to lock this
      * table because we need to update the last_document_number.
      *
      *  If document is already locked for single payment,
      * NO_DATA_FOUND exception would be thrown.
      * Bug - 7499044
      */
     BEGIN
     SELECT
         NVL(last_issued_document_number, 0),
         NVL(last_available_document_number, -1),
         payment_document_name,
         payment_instruction_id
     INTO
         l_last_used_check_num,
         l_last_avail_check_num,
         l_pmt_doc_name,
         l_pmt_instr_id
     FROM
         CE_PAYMENT_DOCUMENTS
     WHERE
         payment_document_id = p_payment_doc_id
     FOR UPDATE SKIP LOCKED
     ;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
                     print_debuginfo(l_module_name, 'Payment document '
             || ''''
             || l_pmt_doc_name
             || ''''
             || ' with payment doc id '
             || p_payment_doc_id
             || ' has been locked from payments workbench ',
             FND_LOG.LEVEL_UNEXPECTED
             );

         IF (G_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          print_debuginfo(l_module_name, 'Processing cannot continue '
             || 'because payment document is unavailable (locked).',
             FND_LOG.LEVEL_UNEXPECTED
             );


          print_debuginfo(l_module_name, 'Changing the status of the '
             || 'payment instruction to '
             || l_instr_status
             );
         END IF;
         /*
          * Fix for bug 5735030:
          *
          * Populate error message in output file so that
          * the user knows the cause of the failure even
          * if logging is turned off.
          */
         l_error_code := 'IBY_PMT_DOC_SING_LOCKED';
         FND_MESSAGE.SET_NAME('IBY', l_error_code);

         FND_MESSAGE.SET_TOKEN('DOC_NAME',
             l_pmt_doc_name,
             FALSE);

         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.GET);

         /*
          * Return failure status.
          */
         x_return_status := -1;

         l_error_code := 'IBY_PMT_DOC_SING_LOCKED';
         FND_MESSAGE.set_name('IBY', l_error_code);

         FND_MESSAGE.SET_TOKEN('DOC_NAME',
             l_pmt_doc_name,
             FALSE);

         FND_MSG_PUB.ADD;

         FND_MSG_PUB.COUNT_AND_GET(
             p_count => x_msg_count,
             p_data  => x_msg_data
             );

         x_return_message := FND_MESSAGE.get;

         IF (G_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          print_debuginfo(l_module_name, 'EXIT');
         END IF;
         RETURN;


     END;
     IF (l_pmt_instr_id IS NOT NULL) THEN
         IF (G_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          print_debuginfo(l_module_name, 'Payment document '
             || ''''
             || l_pmt_doc_name
             || ''''
             || ' with payment doc id '
             || p_payment_doc_id
             || ' has been locked by payment instruction '
             || l_pmt_instr_id,
             FND_LOG.LEVEL_UNEXPECTED
             );


          print_debuginfo(l_module_name, 'Processing cannot continue '
             || 'because payment document is unavailable (locked).',
             FND_LOG.LEVEL_UNEXPECTED
             );

          print_debuginfo(l_module_name, 'Changing the status of the '
             || 'payment instruction to '
             || l_instr_status
             );
           END IF;

         /*
          * Fix for bug 5735030:
          *
          * Populate error message in output file so that
          * the user knows the cause of the failure even
          * if logging is turned off.
          */
         l_error_code := 'IBY_INS_PMT_DOC_LOCKED_DETAIL';
         FND_MESSAGE.SET_NAME('IBY', l_error_code);

         FND_MESSAGE.SET_TOKEN('THIS_INS_NUM',
             x_pmtInstrRec.payment_instruction_id,
             FALSE);

         FND_MESSAGE.SET_TOKEN('PREV_INS_NUM',
             l_pmt_instr_id,
             FALSE);

         FND_MESSAGE.SET_TOKEN('DOC_NAME',
             l_pmt_doc_name,
             FALSE);

         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.GET);

         /*
          * Return failure status.
          */
         x_return_status := -1;

         l_error_code := 'IBY_INS_PMT_DOC_LOCKED';
         FND_MESSAGE.set_name('IBY', l_error_code);

         FND_MESSAGE.SET_TOKEN('INS_ID',
             l_pmt_instr_id,
             FALSE);

         FND_MSG_PUB.ADD;

         FND_MSG_PUB.COUNT_AND_GET(
             p_count => x_msg_count,
             p_data  => x_msg_data
             );

         x_return_message := FND_MESSAGE.get;

         IF (G_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          print_debuginfo(l_module_name, 'EXIT');
         END IF;
         RETURN;

     END IF;

     /*
      * Log warnings if there is any missing/incomplete information.
      */
     IF (l_last_avail_check_num = -1) THEN

         IF (G_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          print_debuginfo(l_module_name, 'Warning: payment document id '
             || p_payment_doc_id
             || ' has no last available document number set. '
             || 'Assuming that infinite number of paper documents '
             || 'can be printed for this payment document.'
             );
         END IF;

     END IF;

     IF (l_last_used_check_num = 0) THEN

         IF (G_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          print_debuginfo(l_module_name, 'Warning: payment document id '
             || p_payment_doc_id
             || ' has last used document number set to zero. '
             || 'Assuming that no paper documents have yet '
             || 'been printed for this payment document.'
             );
         END IF;

     END IF;


     /*
      * If user has explicitly provided a start number for check
      * numbering, we have to use it in our numbering logic.
      * This will only happen for single payments.
      *
      * For Build Program invoked numbering, we will always start
      * from the last issued check number on the payment document + 1.
      */
     IF (p_user_assgn_num IS NULL) THEN

         IF (G_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          print_debuginfo(l_module_name, 'User has not explicitly '
             || 'provided a check number to start numbering from. '
             || 'Numbering will start from last issued check number '
             || 'on check stock.'
             );
         END IF;

     ELSE

         IF (G_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          print_debuginfo(l_module_name, 'User has explicitly '
             || 'provided start number for numbering: '
             || p_user_assgn_num
             );
         END IF;

         /*
          * The code below uses the variable 'l_last_used_check_num'
          * as the starting number for check numbering. The numbering
          * will begin from l_last_used_check_num + 1.
          *
          * If the user has explicitly provided a start number for
          * numbering, we need to adjust the l_last_used_check_num
          * value accordingly.
          */
         l_last_used_check_num := p_user_assgn_num - 1;

     END IF;

     /*
      * Check if enough paper documents are available to complete
      * this payment instruction.
      *
      * Perform this check only if a value has been provided
      * for the last available document number. If no value is
      * set assume that an infinite number of checks can be
      * printed for this paper stock (payment document).
      */
     IF (l_last_avail_check_num <> -1) THEN

         /*
          * Check if enough paper documents are available to complete
          * this payment instruction.
          */
         l_physical_stock_count := l_last_avail_check_num
                                       - l_last_used_check_num;

         IF (G_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          print_debuginfo(l_module_name, 'Available paper stock = '
             || l_physical_stock_count
             || ' for payment document name '
             || ''''
             || l_pmt_doc_name
             || ''''
             );
         END IF;

         IF (l_physical_stock_count < l_paper_pmts_count) THEN

             /*
              * Not enough paper stock is available to print
              * the checks for this payment instruction.
              *
              * Set the status of the payment instruction to
              * failed.
              */
             IF (G_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              print_debuginfo(l_module_name, 'Deferring payment '
                 || 'instruction print '
                 || x_pmtInstrRec.payment_instruction_id
                 || ' because of insufficient paper stock.',
                 FND_LOG.LEVEL_UNEXPECTED
                 );
             END IF;

             x_pmtInstrRec.payment_instruction_status := l_instr_status;

             l_error_code := 'IBY_INS_INSUFFICIENT_PAY_DOCS';

             FND_MESSAGE.set_name('IBY', l_error_code);

             FND_MESSAGE.SET_TOKEN('NUM_AVAIL',
                 l_physical_stock_count,
                 FALSE);

             l_token_rec.token_name  := 'NUM_AVAIL';
             l_token_rec.token_value := l_physical_stock_count;
             x_insTokenTab(x_insTokenTab.COUNT + 1) := l_token_rec;

             FND_MESSAGE.SET_TOKEN('NUM_REQD',
                 l_paper_pmts_count,
                 FALSE);

             l_token_rec.token_name  := 'NUM_REQD';
             l_token_rec.token_value := l_paper_pmts_count;
             x_insTokenTab(x_insTokenTab.COUNT + 1) := l_token_rec;

             /*
              * Once we fail a pmt instruction, we must add a
              * corresponding error message to the errors table.
              */
             IBY_PAYINSTR_UTILS_PKG.createErrorRecord(
                 x_pmtInstrRec.payment_instruction_id,
                 x_pmtInstrRec.payment_instruction_status,
                 l_error_code,
                 FND_MESSAGE.get,
                 'N',
                 l_instr_err_rec
                 );

             IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(
                 l_instr_err_rec,
                 x_instrErrorTab,
                 x_insTokenTab
                 );

             /* add error message to msg stack */
             FND_MSG_PUB.ADD;

             FND_MSG_PUB.COUNT_AND_GET(
                 p_count => x_msg_count,
                 p_data  => x_msg_data
                 );

             /* set error message to return to caller */
             x_return_message := FND_MESSAGE.get;

             /*
              * Now, raise an exception. This will be caught
              * in the exception handler below and the changes
              * made to the DB in this transaction
              * will be rolled back.
              */
             APP_EXCEPTION.RAISE_EXCEPTION;

         ELSE

             IF (G_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              print_debuginfo(l_module_name, 'Sufficient paper stock '
                 || 'is available to print this instruction.'
                 );
             END IF;

         END IF;

     END IF; -- l_last_avail_check_num <> -1

     /*
      * If sufficient paper stock is available, we will be using
      * up the paper stock by assigning it to the available
      * paper payments. Therefore, update the last used paper
      * stock number in CE_PAYMENT_DOCUMENTS.
      *
      * That way if another instance of the payment instruction
      * creation program is operating concurrently, it will
      * be blocked by the SELECT .. FOR UPDATE statement in
      * this method.
      *
      */
     l_anticipated_last_check_num := l_last_used_check_num
                                         + l_paper_pmts_count;

     /*
      * We will be printing the checks starting with
      * paper doc num 'l_last_used_check_num + 1' and
      * ending with paper doc num l_anticipated_last_check_num.
      *
      * Check whether all the paper doc numbers within this
      * range are available. We cannot have any gaps in the
      * numbering because checks have to be numbered
      * contiguously.
      */
     l_nos_avlbl_flag := isContigPaperNumAvlbl(
                             p_payment_doc_id,
                             l_last_used_check_num + 1,
                             l_anticipated_last_check_num
                             );

     IF (l_nos_avlbl_flag = FALSE) THEN

         IF (G_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          print_debuginfo(l_module_name, 'Contiguous paper stock '
             || 'is not available for printing payment instruction '
             || x_pmtInstrRec.payment_instruction_id
             );
         END IF;

         /*
          * Return failure status.
          */
         x_return_status := -1;

         l_error_code := 'IBY_INS_NSF_CONTIG_NUM';
         FND_MESSAGE.set_name('IBY', l_error_code);

         FND_MESSAGE.SET_TOKEN('NUM_PMT_DOCS',
             l_paper_pmts_count,
             FALSE);

         FND_MSG_PUB.ADD;

         FND_MSG_PUB.COUNT_AND_GET(
             p_count => x_msg_count,
             p_data  => x_msg_data
             );

         x_return_message := FND_MESSAGE.get;

         IF (G_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          print_debuginfo(l_module_name, 'EXIT');
         END IF;
         RETURN;

     END IF;

     /*
      * A paper document number (check number) is considered
      * unused if it is not present in IBY_USED_PAYMENT_DOCS
      * table.
      *
      * This logic will work when check numbering is invoked
      * from the Build Program. In this case, the numbering
      * logic always starts with the last issued doc number + 1
      * when assigning new check numbers. Therefore, the
      * check numbers will always be unique (unused).
      *
      * However, when check numbering is invoked for single
      * payments, the user is allowed to provide the start
      * number for check numbering. It is possible that
      * a payment has already been numbered with the user
      * provided start number, but this paper document may
      * not yet have been inserted into the IBY_USED_PAYMENT_DOCS
      * table (because the user has not yet confirmed the
      * payment).
      *
      * Therefore, for single payments, when the user provides
      * the start number for check numbering, we will have to
      * verify that the provided number is unused by checking
      * the paper document number on existing payments.
      */
     IF (p_user_assgn_num IS NOT NULL) THEN

         l_used_flag := isPaperNosUsedOnExistPmt(
                            p_payment_doc_id,
                            l_last_used_check_num + 1,
                            l_anticipated_last_check_num);

         IF (l_used_flag = TRUE) THEN

             IF (G_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              print_debuginfo(l_module_name, 'Paper document number(s) '
                 || 'generated after numbering are invalid (already used). '
                 || 'User needs to provide a new start number or use '
                 || 'the defaulted start number.'
                 );
             END IF;

             /*
              * Return failure status.
              */
             x_return_status := -1;

             l_error_code := 'IBY_INS_ALREADY_USED_NUM';
             FND_MESSAGE.set_name('IBY', l_error_code);

             FND_MSG_PUB.ADD;

             FND_MSG_PUB.COUNT_AND_GET(
                 p_count => x_msg_count,
                 p_data  => x_msg_data
                 );

             x_return_message := FND_MESSAGE.get;

             IF (G_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              print_debuginfo(l_module_name, 'EXIT');
             END IF;
             RETURN;

         ELSE

             IF (G_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              print_debuginfo(l_module_name, 'Paper document number(s) '
                 || 'generated after numbering are unused. '
                 );
             END IF;

         END IF;

     END IF;

     /*
      * For single payments, the payment document should
      * not be locked (see bug 4597718).
      */
     IF (l_single_pmt_flag = TRUE) THEN

         IF (G_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          print_debuginfo(l_module_name, 'This is a single payment. '
             || 'Payment document will not be locked ..'
             );
         END IF;

         /*
          * Update the check stock to reflect the latest used
          * check number.
          */
         UPDATE
             CE_PAYMENT_DOCUMENTS
         SET
             last_issued_document_number = l_anticipated_last_check_num
         WHERE
             payment_document_id         = p_payment_doc_id
         AND
	     last_issued_document_number < l_anticipated_last_check_num
         ;

     ELSE

         IF (G_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          print_debuginfo(l_module_name, 'This is not a single payment. '
             || 'Payment document will be locked ..'
             );
         END IF;

         /*
          * Update the check stock to reflect the latest used
          * check number, and lock the check stock.
          */
         UPDATE
             CE_PAYMENT_DOCUMENTS
         SET
             last_issued_document_number = l_anticipated_last_check_num,
             payment_instruction_id      = x_pmtInstrRec.payment_instruction_id
         WHERE
             payment_document_id         = p_payment_doc_id
         ;

     END IF;

     IF (G_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      print_debuginfo(l_module_name, 'Finished updating the last '
         || 'available check number in CE_PAYMENT_DOCUMENTS. '
         || 'Current last check number: '
         || l_anticipated_last_check_num
         );
     END IF;

     /* uncomment for debug purposes */
     --print_debuginfo(l_module_name, 'x_dummyPaperPmtsTab.COUNT: '
     --    || x_dummyPaperPmtsTab.COUNT);
     --print_debuginfo(l_module_name, 'x_paperPmtsTab.COUNT: '
     --    || x_paperPmtsTab.COUNT);


     /*
      * Commenting below code as we do not have setup
      * or overflow documents for Electronic Processing type
      * of payments.
      */
     /*
      * Assign contiguous check numbers to the setup checks.
      * These are dummy checks that are printed at the
      * beginning of the payment instruction print run.
      */
     /*IF (x_dummyPaperPmtsTab.COUNT <> 0) THEN

         FOR i in x_dummyPaperPmtsTab.FIRST .. x_dummyPaperPmtsTab.LAST LOOP

             IF (x_dummyPaperPmtsTab(i).payment_status = 'VOID_BY_SETUP') THEN

                 l_last_used_check_num := l_last_used_check_num + 1;
                 x_dummyPaperPmtsTab(i).paper_document_number
                     := l_last_used_check_num;

             END IF;

         END LOOP; -- for all setup payments in x_dummyPaperPmtsTab

     END IF;*/

     /* assign check number to paper payment */
     FOR i in x_paperPmtsTab.FIRST .. x_paperPmtsTab.LAST LOOP

         l_last_used_check_num := l_last_used_check_num + 1;
         x_paperPmtsTab(i).check_number := l_last_used_check_num;

     END LOOP; -- for all pmts in x_paperPmtsTab

     /*
      * Final check:
      *
      * If all paper payments (including real payments, setup payments
      * and overflow payments) have been assigned check numbers
      * correctly, then the number of check numbers used up should
      * match the total paper payments count.
      *
      * If the two don't match, it means that some check numbers were
      * unassigned, or multiply assigned. In either case, abort the
      * program. This check will reveal any bugs in this method.
      */
     IF (l_anticipated_last_check_num <> l_last_used_check_num) THEN

         IF (G_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          print_debuginfo(l_module_name, 'Check numbers were not '
             || 'properly assigned. '
             || 'Anticipated last used check number: '
             || l_anticipated_last_check_num
             || '. Actual last used check number: '
             || l_last_used_check_num
             || '. Deferring print for payment instruction '
             || x_pmtInstrRec.payment_instruction_id,
             FND_LOG.LEVEL_UNEXPECTED
             );
          END IF;

         x_pmtInstrRec.payment_instruction_status := l_instr_status;

         l_error_code := 'IBY_INS_NUMBERING_ERR_1';

         FND_MESSAGE.set_name('IBY', l_error_code);

         FND_MESSAGE.SET_TOKEN('NUM_CALC',
             l_anticipated_last_check_num,
             FALSE);

         l_token_rec.token_name  := 'NUM_CALC';
         l_token_rec.token_value := l_anticipated_last_check_num;
         x_insTokenTab(x_insTokenTab.COUNT + 1) := l_token_rec;

         FND_MESSAGE.SET_TOKEN('NUM_ACTU',
             l_last_used_check_num,
             FALSE);

         l_token_rec.token_name  := 'NUM_ACTU';
         l_token_rec.token_value := l_last_used_check_num;
         x_insTokenTab(x_insTokenTab.COUNT + 1) := l_token_rec;

         /*
          * Once we fail a pmt instruction, we must add a
          * corresponding error message to the errors table.
          */
         IBY_PAYINSTR_UTILS_PKG.createErrorRecord(
             x_pmtInstrRec.payment_instruction_id,
             x_pmtInstrRec.payment_instruction_status,
             l_error_code,
             FND_MESSAGE.get,
             'N',
             l_instr_err_rec
             );

         IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(
             l_instr_err_rec,
             x_instrErrorTab,
             x_insTokenTab
             );

         /* add error msg to message stack */
         FND_MSG_PUB.ADD;

         FND_MSG_PUB.COUNT_AND_GET(
             p_count => x_msg_count,
             p_data  => x_msg_data
             );

         /* set error message to return to caller */
         x_return_message := FND_MESSAGE.get;

         APP_EXCEPTION.RAISE_EXCEPTION;

     END IF;

     /*
      * Return success status.
      */
     x_return_message := 'SUCCESS';
     x_return_status  := 0;

     IF (G_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      print_debuginfo(l_module_name, 'EXIT');
     END IF;

     EXCEPTION
         WHEN OTHERS THEN

         IF (G_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          print_debuginfo(l_module_name, 'Exception occured when '
             || 'performing document numbering. '
             );
          print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
          print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);
         END IF;
         /*
          * Rollback any DB changes made in this method.
          */
         ROLLBACK;

         /*
          * Return error status to caller.
          * The error message would have already been set.
          */
         x_return_status := -1;

         IF (G_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          print_debuginfo(l_module_name, 'EXIT');
         END IF;

 END assignElectronicCheckNumbers;


END IBY_CHECKNUMBER_PUB;

/
