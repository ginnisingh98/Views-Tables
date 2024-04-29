--------------------------------------------------------
--  DDL for Package Body IBY_DISBURSE_UI_API_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_DISBURSE_UI_API_PUB_PKG" AS
/*$Header: ibydapib.pls 120.160.12010000.53 2010/09/01 16:47:54 gmaheswa ship $*/

 /*
  * Declare global variables
  */
 G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBY_DISBURSE_UI_API_PUB_PKG';
 G_CURRENT_RUNTIME_LEVEL      CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;

 /*
  * List of document statuses that are used / set in this
  * module.
  */
 DOC_STATUS_PMT_REMOVED  CONSTANT VARCHAR2(100) := 'REMOVED_PAYMENT_REMOVED';
 DOC_STATUS_PMT_STOPPED  CONSTANT VARCHAR2(100) := 'REMOVED_PAYMENT_STOPPED';
 DOC_STATUS_PMT_VOIDED   CONSTANT VARCHAR2(100) := 'REMOVED_PAYMENT_VOIDED';
 DOC_STATUS_PMT_SPOILED  CONSTANT VARCHAR2(100) := 'REMOVED_PAYMENT_SPOILED';
 DOC_STATUS_INS_TERM     CONSTANT VARCHAR2(100) :=
                             'REMOVED_INSTRUCTION_TERMINATED';
 DOC_STATUS_REQ_TERM     CONSTANT VARCHAR2(100) :=
                             'REMOVED_REQUEST_TERMINATED';
 DOC_STATUS_VALID        CONSTANT VARCHAR2(100) := 'VALIDATED';
 DOC_STATUS_PAY_CREAT    CONSTANT VARCHAR2(100) := 'PAYMENT_CREATED';
 DOC_STATUS_REJECTED     CONSTANT VARCHAR2(100) := 'REJECTED';
 DOC_STATUS_REMOVED      CONSTANT VARCHAR2(100) := 'REMOVED';
 DOC_STATUS_VOID_SETUP   CONSTANT VARCHAR2(100) := 'VOID_BY_SETUP';
 DOC_STATUS_FAIL_CA      CONSTANT VARCHAR2(100) := 'FAILED_BY_CALLING_APP';

 /*
  * List of payment statuses that are used / set in this
  * module.
  */
 PAY_STATUS_INS_TERM       CONSTANT VARCHAR2(100) :=
                               'REMOVED_INSTRUCTION_TERMINATED';
 PAY_STATUS_REQ_TERM       CONSTANT VARCHAR2(100) :=
                               'REMOVED_REQUEST_TERMINATED';
 PAY_STATUS_CREATED        CONSTANT VARCHAR2(100) := 'CREATED';
 PAY_STATUS_MODIFIED       CONSTANT VARCHAR2(100) := 'MODIFIED';
 PAY_STATUS_MOD_BNK_ACC    CONSTANT VARCHAR2(100) :=
                               'MODIFIED_PAYEE_BANK_ACCOUNT';
 PAY_STATUS_INS_CREAT      CONSTANT VARCHAR2(100) := 'INSTRUCTION_CREATED';
 PAY_STATUS_VOID           CONSTANT VARCHAR2(100) := 'VOID';
 PAY_STATUS_REPRINT        CONSTANT VARCHAR2(100) := 'READY_TO_REPRINT';
 PAY_STATUS_SPOILED        CONSTANT VARCHAR2(100) := 'REMOVED_DOCUMENT_SPOILED';
 PAY_STATUS_ISSUED         CONSTANT VARCHAR2(100) := 'ISSUED';
 PAY_STATUS_SUB_FOR_PRINT  CONSTANT VARCHAR2(100) := 'SUBMITTED_FOR_PRINTING';
 PAY_STATUS_FORMATTED      CONSTANT VARCHAR2(100) := 'FORMATTED';
 PAY_STATUS_TRANSMITTED    CONSTANT VARCHAR2(100) := 'TRANSMITTED';
 PAY_STATUS_ACK            CONSTANT VARCHAR2(100) := 'ACKNOWLEDGED';
 PAY_STATUS_BNK_VALID      CONSTANT VARCHAR2(100) := 'BANK_VALIDATED';
 PAY_STATUS_PAID           CONSTANT VARCHAR2(100) := 'PAID';
 PAY_STATUS_REMOVED        CONSTANT VARCHAR2(100) := 'REMOVED';
 PAY_STATUS_VOID_SETUP     CONSTANT VARCHAR2(100) := 'VOID_BY_SETUP';
 PAY_STATUS_VOID_OVERFLOW  CONSTANT VARCHAR2(100) := 'VOID_BY_OVERFLOW';
 PAY_STATUS_STOPPED        CONSTANT VARCHAR2(100) := 'REMOVED_PAYMENT_STOPPED';
 PAY_STATUS_SETUP_REPRINT  CONSTANT VARCHAR2(100) := 'VOID_BY_SETUP_REPRINT';
 PAY_STATUS_OVERFLOW_REPRINT
                           CONSTANT VARCHAR2(100) := 'VOID_BY_OVERFLOW_REPRINT';
 PAY_STATUS_REJECTED       CONSTANT VARCHAR2(100) := 'REJECTED';
 /*
  * List of payment instruction statuses that are used / set in this
  * module.
  */
 INS_STATUS_READY_TO_PRINT  CONSTANT VARCHAR2(100) :=
                                         'CREATED_READY_FOR_PRINTING';
 INS_STATUS_READY_TO_FORMAT CONSTANT VARCHAR2(100) :=
                                         'CREATED_READY_FOR_FORMATTING';
 INS_STATUS_FORMAT_TO_PRINT CONSTANT VARCHAR2(100) :=
                                         'FORMATTED_READY_FOR_PRINTING';
 INS_STATUS_PRINTED         CONSTANT VARCHAR2(100) :=
                                         'PRINTED';
 INS_STATUS_TERMINATED      CONSTANT VARCHAR2(100) := 'TERMINATED';
 INS_STATUS_FORMATTED       CONSTANT VARCHAR2(100) := 'FORMATTED';
 INS_STATUS_FORMATTED_ELEC  CONSTANT VARCHAR2(100) := 'FORMATTED_ELECTRONIC';
 INS_STATUS_TRANSMITTED     CONSTANT VARCHAR2(100) := 'TRANSMITTED';

 /*
  * List of payment request statuses that are used / set in this
  * module.
  */
 REQ_STATUS_TERMINATED  CONSTANT VARCHAR2(100) := 'TERMINATED';
 REQ_STATUS_COMPLETED  CONSTANT VARCHAR2(100) := 'COMPLETED';

 /*
  * Paper document usage reasons.
  */
 DOC_USE_SPOILED     CONSTANT VARCHAR2(100) := 'SPOILED';
 DOC_USE_ISSUED      CONSTANT VARCHAR2(100) := 'ISSUED';

 /*
  * Payment completion code.
  */
 PMT_COMPLETE_YES    CONSTANT VARCHAR2(10) := 'YES';

 /*
  * List of valid processing types on the payment profile.
  */
 P_TYPE_PRINTED      CONSTANT VARCHAR2(100) := 'PRINTED';
 P_TYPE_ELECTRONIC   CONSTANT VARCHAR2(100) := 'ELECTRONIC';

 /*
  * List of process types.
  */
 PROCESS_TYPE_IMMEDIATE CONSTANT VARCHAR2(100) := 'IMMEDIATE';
 PROCESS_TYPE_STANDARD  CONSTANT VARCHAR2(100) := 'STANDARD';
 PROCESS_TYPE_MANUAL    CONSTANT VARCHAR2(100) := 'MANUAL';



   /* Bug 9404359  */
  /* added for caching the external_bank_acct_id*/
  TYPE t_ext_acct_id_rec_type IS RECORD(
    ext_bank_account_id  iby_ext_bank_accounts.ext_bank_account_id%TYPE
   );
  TYPE t_ext_acct_id_tbl_type IS TABLE OF t_ext_acct_id_rec_type INDEX BY VARCHAR2(2000);
  g_ext_acct_id_tbl  t_ext_acct_id_tbl_type;



/*--------------------------------------------------------------------
 | NAME:
 |     payment_stop_request
 |
 |
 | PURPOSE:For Initiating the payment stop process. This procedure should be
 | called only by AP. This should not be called by IBY.
 |
 |
 | PARAMETERS:
 |     IN      p_payment_id      -- id of the payment.
 |             p_requested_by   -- User id of person who issued the void request.
 |                                 This id will be stored as an attribute of the
 |                                 payment.
 |             p_request_reason
 |             p_request_reference
 |             p_request_date
 |
 |     OUT
 |            x_return_status - Result of the API call:
 |                                FND_API.G_RET_STS_SUCCESS indicates that a
 |                                  callout was invoked successfully.
 |                                  In this case the caller must COMMIT
 |                                  the status change.
 |
 |                                FND_API.G_RET_STS_UNEXP_ERROR (or other) indicates
 |                                  that API did not complete successfully.
 |                                  In this case, the caller must issue a
 |                                  ROLLBACK to undo all status changes.
 |             x_msg_count
 |             x_msg_data
 |
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE payment_stop_request (
        p_payment_id		     IN  NUMBER,
        p_requested_by       IN  NUMBER,
        p_request_reason     IN  VARCHAR2,
        p_request_reference  IN  VARCHAR2,
        p_request_date       IN  DATE,
        x_return_status	  OUT nocopy VARCHAR2,
        x_msg_count		    OUT nocopy NUMBER,
        x_msg_data		    OUT nocopy VARCHAR2)
  IS
       l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME
                                         || '.payment_stop_request';

  BEGIN
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	          print_debuginfo(l_module_name, 'ENTER');

          END IF;
          UPDATE iby_payments_all
          SET STOP_REQUEST_PLACED_FLAG = 'Y',
              STOP_REQUEST_PLACED_BY = p_requested_by,
              STOP_REQUEST_REASON = p_request_reason,
              STOP_REQUEST_REFERENCE= p_request_reference,
              STOP_REQUEST_DATE = p_request_date,
              STOP_RELEASED_FLAG = 'N',
              STOP_RELEASED_BY = NULL,
              STOP_RELEASE_DATE = NULL,
              STOP_RELEASE_REASON = NULL,
              STOP_RELEASE_REFERENCE = NULL

          WHERE
              PAYMENT_ID = p_payment_id;

         x_return_status := FND_API.G_RET_STS_SUCCESS;
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	           print_debuginfo(l_module_name, 'EXIT');

           END IF;
          EXCEPTION
            WHEN OTHERS THEN
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                   x_msg_count := 1;
                   x_msg_data := substr(SQLERRM,1,25);

               IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	               print_debuginfo(l_module_name, 'EXIT');
               END IF;
  END payment_stop_request;


  /*--------------------------------------------------------------------
 | NAME:
 |     payment_stop_release
 |
 |
 | PURPOSE:For Releasing the stop request . This procedure should be
 | called only by AP. This should not be called by IBY.
 |
 |
 | PARAMETERS:
 |     IN      p_payment_id      -- payment id
 |             p_released_by   -- User id of person who issued the void request.
 |                                 This id will be stored as an attribute of the
 |                                 payment.
 |             p_release_reason
 |             p_release_reference
 |             p_release_date
 |
 |     OUT     x_return_status - Result of the API call:
 |                                FND_API.G_RET_STS_SUCCESS indicates that a
 |                                  callout was invoked successfully.
 |                                  In this case the caller must COMMIT
 |                                  the status change.
 |
 |                                FND_API.G_RET_STS_UNEXP_ERROR (or other) indicates
 |                                  that API did not complete successfully.
 |                                  In this case, the caller must issue a
 |                                  ROLLBACK to undo all status changes.
 |             x_msg_count
 |             x_msg_data
 |
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE payment_stop_release (
        p_payment_id		     IN  NUMBER,
        p_released_by        IN  NUMBER,
        p_release_reason     IN  VARCHAR2,
        p_release_reference  IN  VARCHAR2,
        p_release_date       IN  DATE,
        x_return_status	     OUT nocopy VARCHAR2,
        x_msg_count		       OUT nocopy NUMBER,
        x_msg_data		       OUT nocopy VARCHAR2)
  IS
     l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME
                                         || '.payment_stop_release';
  BEGIN
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	          print_debuginfo(l_module_name, 'ENTER');

          END IF;
          UPDATE iby_payments_all
          SET STOP_RELEASED_FLAG = 'Y',
              STOP_RELEASED_BY = p_released_by,
              STOP_RELEASE_DATE = p_release_date,
              STOP_RELEASE_REASON = p_release_reason,
              STOP_RELEASE_REFERENCE = p_release_reference

          WHERE
              PAYMENT_ID = p_payment_id;

         x_return_status := FND_API.G_RET_STS_SUCCESS;
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	           print_debuginfo(l_module_name, 'EXIT');

           END IF;
          EXCEPTION
            WHEN OTHERS THEN
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                   x_msg_count := 1;
                   x_msg_data := substr(SQLERRM,1,25);

               IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	               print_debuginfo(l_module_name, 'EXIT');

               END IF;
  END payment_stop_release;





/*--------------------------------------------------------------------
 | NAME:
 |     remove_document_payable
 |
 | PURPOSE:
 |     Invokes the callout of the calling app to remove a submitted
 |     document payable from the payment processing cycle.
 |
 |     The calling application can free up the removed document, and
 |     make it available for submission in a future payment request.
 |
 | PARAMETERS:
 |     IN
 |       p_doc_id        - ID of the document payable to be removed.
 |       p_doc_status    - Current status of the document payable to
 |                         be removed.
 |
 |     OUT
 |       x_return_status - Result of the API call:
 |                         FND_API.G_RET_STS_SUCCESS indicates that a
 |                           callout was invoked successfully.
 |                           In this case the caller must COMMIT
 |                           the status change.
 |
 |                         FND_API.G_RET_STS_ERROR (or other) indicates
 |                           that API did not complete successfully.
 |                           In this case, the caller must issue a
 |                           ROLLBACK to undo all status changes.
 |
 | RETURNS:
 |
 | NOTES:
 |   Internal API, not for public use.
 |
 |   This API will not do a COMMIT. It is the the callers responsbility
 |   to perform COMMIT / ROLLBACK depending upon the returned status.
 |
 |   The callout invoked must be handled synchronously by the
 |   calling application. So the COMMIT / ROLLBACK should affect
 |   the changes made to the database by the calling application as
 |   well. This will ensure that IBY and the calling application are
 |   in sync w.r.t. to the specified document payable.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE remove_document_payable (
     p_doc_id         IN NUMBER,
     p_doc_status     IN VARCHAR2,
     x_return_status  OUT NOCOPY VARCHAR2
     )
 IS

 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME
                                         || '.remove_document_payable';

 l_rejection_id   NUMBER(15);

 /* used in forming callout procedure name */
 l_calling_app_id NUMBER;
 l_app_short_name VARCHAR2(200);
 l_pkg_name       VARCHAR2(200);
 l_callout_name   VARCHAR2(500);
 l_stmt           VARCHAR2(1000);

 /* used in invocation of callout procedure */
 l_api_version    CONSTANT NUMBER := 1.0;
 l_msg_count      NUMBER;
 l_msg_data       VARCHAR2(2000);

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
     FND_MSG_PUB.initialize;

     /*
      * STATUS CHANGE:
      *
      * UI Responsibility:
      * document status = REMOVED
      *
      * API Responsibility:
      * NONE
      */

     /*
      * Get the next available rejected document group id.
      */
     SELECT
         IBY_REJECTED_DOCS_GROUP_S.NEXTVAL
     INTO
         l_rejection_id
     FROM
         DUAL
     ;

     /*
      * Update the removed document with the rejected document
      * group id. The calling application will identify rejected
      * documents using this id.
      */
     UPDATE
         IBY_DOCS_PAYABLE_ALL
     SET
         rejected_docs_group_id = l_rejection_id
     WHERE
         document_payable_id = p_doc_id        AND
         document_status     = p_doc_status
     ;

     /*
      * Get the application name of the calling app. This
      * will be used in the callout.
      */
     SELECT
         fnd.application_short_name
     INTO
         l_app_short_name
     FROM
         FND_APPLICATION      fnd,
         IBY_DOCS_PAYABLE_ALL doc
     WHERE
         fnd.application_id      = doc.calling_app_id AND
         doc.document_payable_id = p_doc_id
     ;

     /*
      * Get the constructed package name to use in the
      * call out.
      */
     l_pkg_name := construct_callout_pkg_name(l_app_short_name);

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Constructed package name: '
	         || l_pkg_name);

     END IF;
     IF (l_pkg_name IS NULL) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Package name is null. '
	             || 'Raising exception.');

         END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;

     END IF;


     /*
      * Now try to call the external app's implementation of the hook.
      * The calling app may or may not have implemented the hook, so
      * it's not fatal if the implementation does not exist.
      */
     l_callout_name := l_pkg_name || '.' || 'documents_payable_rejected';

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Attempting to invoke callout: '
	         || l_callout_name);

     END IF;
     l_stmt := 'CALL '|| l_callout_name || '(:1, :2, :3, :4, :5, :6, :7)';

     BEGIN

         EXECUTE IMMEDIATE
             (l_stmt)
         USING
             IN  l_api_version,
             IN  FND_API.G_FALSE,
             IN  FND_API.G_FALSE,
             OUT x_return_status,
             OUT l_msg_count,
             OUT l_msg_data,
             IN  l_rejection_id
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
	                 || '. Raising exception.'
	                 );

             END IF;
             APP_EXCEPTION.RAISE_EXCEPTION;

         END IF;

     EXCEPTION

         WHEN PROCEDURE_NOT_IMPLEMENTED THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Callout "' || l_callout_name
	                 || '" not implemented by calling app '
	                 || l_app_short_name || '.');

	             print_debuginfo(l_module_name, 'Skipping hook call.');


             END IF;
         WHEN OTHERS THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Fatal: External app callout '''
	                 || l_callout_name
	                 || ''', generated exception.'
	                 );

	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);
             END IF;
             FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

             /*
              * Propogate exception to caller.
              */
             RAISE;
     END;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 EXCEPTION

     WHEN OTHERS THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Exception occured when '
	             || 'removing document payable '
	             || p_doc_id
	             || ', with status '
	             || p_doc_status
	             );

	         print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	         print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);
         END IF;
         FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);
         x_return_status := FND_API.G_RET_STS_ERROR;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
 END remove_document_payable;

/*--------------------------------------------------------------------
 | NAME:
 |     remove_documents_payable
 |
 | PURPOSE:
 |     Invokes a series of callouts to the calling app to remove
 |     a set of submitted documents payable from the payment processing
 |     cycle.
 |
 |     The calling application can free up the removed documents, and
 |     make them available for submission in future payment request(s).
 |
 | PARAMETERS:
 |     IN
 |       p_doc_list        - IDs of the documents payable to be removed.
 |                           This should be an array of document payable ids.
 |
 |       p_doc_status_list - Current statuses of the documents payable to
 |                           be removed. This should be an array of statuses.
 |
 |     OUT
 |       x_return_status   - Result of the API call:
 |                         FND_API.G_RET_STS_SUCCESS indicates that all
 |                           callouts were invoked successfully.
 |                           In this case the caller must COMMIT
 |                           the status changes.
 |
 |                         FND_API.G_RET_STS_ERROR (or other) indicates
 |                           that at least one event did not complete
 |                           successfully. In this case, the caller must
 |                           issue a ROLLBACK to undo all status changes.
 |
 | RETURNS:
 |
 | NOTES:
 |   This API will not do a COMMIT. It is the the callers responsbility
 |   to perform COMMIT / ROLLBACK depending upon the returned status.
 |
 |   The callouts invoked must be handled synchronously by the
 |   calling application. So the COMMIT / ROLLBACK should affect
 |   the changes made to the database by the calling application as
 |   well. This will ensure that IBY and the calling application are
 |   in sync w.r.t. to the specified documents payable.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE remove_documents_payable (
     p_doc_list         IN docPayIDTab,
     p_doc_status_list  IN docPayStatusTab,
     x_return_status    OUT NOCOPY VARCHAR2
     )
 IS

 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME
                                         || '.remove_documents_payable';
 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     FND_MSG_PUB.initialize;

     IF (p_doc_list.COUNT = 0 OR p_doc_status_list.COUNT = 0) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Error: List of document '
	             || 'payable ids/statuses is empty'
	             || '. Returning failure response .. '
	             );

         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     END IF;

     IF (p_doc_list.COUNT <> p_doc_status_list.COUNT) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Error: List of document '
	             || 'payable ids must match list of document payable '
	             || 'statuses'
	             || '. Returning failure response .. '
	             );

         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     END IF;

     /*
      * Start processing the documents payable, one-by-one.
      */
     FOR i IN p_doc_list.FIRST .. p_doc_list.LAST LOOP

         remove_document_payable (
             p_doc_list(i),
             p_doc_status_list(i),
             x_return_status
             );

         /*
          * Check if the call to remove the document
          * payable succeeded.
          */
         IF (x_return_status IS NULL OR
	     x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

             /*
              * Even if a single call to remove a doc payable
              * failed, return failure for the entire API request.
              */
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Removing of document '
	                 || p_doc_list(i)
	                 || ' failed.'
	                 );

	             print_debuginfo(l_module_name, 'EXIT');

             END IF;
             /*
              * It is the callers responsibility to rollback
              * all the changes.
              */
             RETURN;

         END IF;

     END LOOP;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Returning success response ..');

	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END remove_documents_payable;

/*--------------------------------------------------------------------
 | NAME:
 |     remove_payment
 |
 |
 | PURPOSE:
 |     Invokes a callout of the calling app to remove a set of
 |     submitted documents payable from the payment processing
 |     cycle.
 |
 |     The calling application can free up the removed documents, and
 |     make them available for submission in future payment request(s).
 |
 | PARAMETERS:
 |     IN
 |       p_pmt_id          - ID of the payment to be removed.
 |
 |       p_pmt_status_list - Current status of the payment to
 |                           be removed.
 |
 |     OUT
 |       x_return_status   - Result of the API call:
 |                         FND_API.G_RET_STS_SUCCESS indicates that
 |                           the callout was invoked successfully.
 |                           In this case the caller must COMMIT
 |                           the status changes.
 |
 |                         FND_API.G_RET_STS_ERROR (or other) indicates
 |                           that tha API did not complete successfully.
 |                           In this case, the caller must issue a
 |                           ROLLBACK to undo all status changes.
 |
 | RETURNS:
 |
 | NOTES:
 |   Internal API, not for public use.
 |
 |   This API will not do a COMMIT. It is the the callers responsibility
 |   to perform COMMIT / ROLLBACK depending upon the returned status.
 |
 |   The callout invoked must be handled synchronously by the
 |   calling application. So the COMMIT / ROLLBACK should affect
 |   the changes made to the database by the calling application as
 |   well. This will ensure that IBY and the calling application are
 |   in sync w.r.t. to the specified documents payable.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE remove_payment (
     p_pmt_id         IN NUMBER,
     p_pmt_status     IN VARCHAR2,
     x_return_status  OUT NOCOPY VARCHAR2
     )
 IS

 l_module_name    CONSTANT VARCHAR2(200) := G_PKG_NAME || '.remove_payment';

 l_rejection_id   NUMBER(15);

 /* used in forming callout procedure name */
 l_calling_app_id NUMBER;
 l_app_short_name VARCHAR2(200);
 l_pkg_name       VARCHAR2(200);
 l_callout_name   VARCHAR2(500);
 l_stmt           VARCHAR2(1000);

 /* used in invocation of callout procedure */
 l_api_version    CONSTANT NUMBER := 1.0;
 l_msg_count      NUMBER;
 l_msg_data       VARCHAR2(2000);

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
     FND_MSG_PUB.initialize;

     /*
      * STATUS CHANGE:
      *
      * UI Responsibility:
      * payment status = REMOVED
      *
      * API Responsibility:
      * document_status = REMOVED_PAYMENT_REMOVED
      */
     UPDATE
         IBY_DOCS_PAYABLE_ALL
     SET
         document_status = DOC_STATUS_PMT_REMOVED,

         /*
          * Fix for bug 4405981:
          *
          * The straight through flag should be set to 'N',
          * if the document was rejected / required manual
          * intervention.
          */
         straight_through_flag = 'N'
     WHERE
         payment_id = p_pmt_id
     ;

     /*
      * Get the next available rejected document group id.
      */
     SELECT
         IBY_REJECTED_DOCS_GROUP_S.NEXTVAL
     INTO
         l_rejection_id
     FROM
         DUAL
     ;

     /*
      * Update the removed documents with the rejected document
      * group id. The calling application will identify rejected
      * documents using this id.
      */
     UPDATE
         IBY_DOCS_PAYABLE_ALL
     SET
         rejected_docs_group_id = l_rejection_id
     WHERE
         payment_id = p_pmt_id
     ;

     /*
      * Get the application name of the calling app. This
      * will be used in the callout.
      */
     SELECT
         fnd.application_short_name
     INTO
         l_app_short_name
     FROM
         FND_APPLICATION           fnd,
         IBY_PAYMENTS_ALL          pmt,
         IBY_PAY_SERVICE_REQUESTS  req
     WHERE
         fnd.application_id             = req.calling_app_id             AND
         req.payment_service_request_id = pmt.payment_service_request_id AND
         pmt.payment_id                 = p_pmt_id
     ;

     /*
      * Get the constructed package name to use in the
      * call out.
      */
     l_pkg_name := construct_callout_pkg_name(l_app_short_name);

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Constructed package name: '
	         || l_pkg_name);

     END IF;
     IF (l_pkg_name IS NULL) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Package name is null. '
	             || 'Raising exception.');

         END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;

     END IF;

     /*
      * Now try to call the external app's implementation of the hook.
      * The calling app may or may not have implemented the hook, so
      * it's not fatal if the implementation does not exist.
      */
     l_callout_name := l_pkg_name || '.' || 'documents_payable_rejected';

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Attempting to invoke callout: '
	         || l_callout_name);

     END IF;
     l_stmt := 'CALL '|| l_callout_name || '(:1, :2, :3, :4, :5, :6, :7)';

     BEGIN

         EXECUTE IMMEDIATE
             (l_stmt)
         USING
             IN  l_api_version,
             IN  FND_API.G_FALSE,
             IN  FND_API.G_FALSE,
             OUT x_return_status,
             OUT l_msg_count,
             OUT l_msg_data,
             IN  l_rejection_id
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
	                 || '. Raising exception.'
	                 );

             END IF;
             APP_EXCEPTION.RAISE_EXCEPTION;

         END IF;

     EXCEPTION

         WHEN PROCEDURE_NOT_IMPLEMENTED THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Callout "' || l_callout_name
	                 || '" not implemented by calling app '
	                 || l_app_short_name || '.');

	             print_debuginfo(l_module_name, 'Skipping hook call.');


             END IF;
         WHEN OTHERS THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Fatal: External app callout '''
	                 || l_callout_name
	                 || ''', generated exception.'
	                 );

	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);
             END IF;
             FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

             /*
              * Propogate exception to caller.
              */
             RAISE;
     END;


     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 EXCEPTION

     WHEN OTHERS THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Exception occured when '
	             || 'removing payment '
	             || p_pmt_id
	             || ', with status '
	             || p_pmt_status
	             );

	         print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	         print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);
         END IF;
         FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

         x_return_status := FND_API.G_RET_STS_ERROR;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
 END remove_payment;

/*--------------------------------------------------------------------
 | NAME:
 |     remove_payments
 |
 | PURPOSE:
 |     Invokes a series of callouts of the calling app to remove
 |     a set of submitted documents payable from the payment processing
 |     cycle.
 |
 |     The calling application can free up the removed documents, and
 |     make them available for submission in future payment request(s).
 |
 | PARAMETERS:
 |     IN
 |       p_pmt_list        - IDs of the payments to be removed.
 |                           This should be an array of payment ids. All
 |                           the child documents payable of each of the
 |                           specified payments will be removed.
 |
 |       p_pmt_status_list - Current statuses of the payments to
 |                           be removed. This should be an array of statuses.
 |
 |     OUT
 |       x_return_status   - Result of the API call:
 |                         FND_API.G_RET_STS_SUCCESS indicates that all
 |                           the callouts were invoked successfully.
 |                           In this case the caller must COMMIT
 |                           the status changes.
 |
 |                         FND_API.G_RET_STS_ERROR (or other) indicates
 |                           that at least one event did not complete
 |                           successfully. In this case, the caller must
 |                           issue a ROLLBACK to undo all status changes.
 |
 | RETURNS:
 |
 | NOTES:
 |   Internal API, not for public use.
 |
 |   This API will not do a COMMIT. It is the the callers responsbility
 |   to perform COMMIT / ROLLBACK depending upon the returned status.
 |
 |   The callouts invoked must be handled synchronously by the
 |   calling application. So the COMMIT / ROLLBACK should affect
 |   the changes made to the database by the calling application as
 |   well. This will ensure that IBY and the calling application are
 |   in sync w.r.t. to the specified documents payable.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE remove_payments (
     p_pmt_list         IN pmtIDTab,
     p_pmt_status_list  IN pmtStatusTab,
     x_return_status    OUT NOCOPY VARCHAR2
     )
 IS

 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME || '.remove_payments';

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     FND_MSG_PUB.initialize;

     IF (p_pmt_list.COUNT = 0 OR p_pmt_status_list.COUNT = 0) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Error: List of payment '
	             || 'payable ids/statuses is empty'
	             || '. Returning failure response .. '
	             );

         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     END IF;

     IF (p_pmt_list.COUNT <> p_pmt_status_list.COUNT) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Error: List of payment '
	             || 'ids must match list of payment statuses. '
	             || 'Returning failure response .. '
	             );

         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     END IF;

     /*
      * Start processing the payments, one-by-one.
      */
     FOR i IN p_pmt_list.FIRST .. p_pmt_list.LAST LOOP

         remove_payment (
             p_pmt_list(i),
             p_pmt_status_list(i),
             x_return_status
             );

         /*
          * Check if the call to remove the payment succeeded.
          */
         IF (x_return_status IS NULL OR
	     x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

             /*
              * Even if a single call to remove a payment
              * failed, return failure for the entire API request.
              */
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Removing of payment '
	                 || p_pmt_list(i)
	                 || ' failed.'
	                 );

	             print_debuginfo(l_module_name, 'EXIT');

             END IF;
             /*
              * It is the callers responsibility to rollback
              * all the changes.
              */
             RETURN;

         END IF;

     END LOOP;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Returning success response ..');

	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END remove_payments;

/*--------------------------------------------------------------------
 | NAME:
 |     remove_payment_request
 |
 | PURPOSE:
 |     Invokes a series of callouts of the calling app to remove
 |     all the submitted documents payable of the given payment request
 |     from the payment processing cycle.
 |
 |     The calling application can free up the removed documents, and
 |     make them available for submission in future payment request(s).
 |
 | PARAMETERS:
 |     IN
 |       p_payreq_id       - ID of the payment request which must be removed.
 |                           All documents payable associated with the
 |                           specified payment request will be removed.
 |
 |     OUT
 |       x_return_status   - Result of the API call:
 |                         FND_API.G_RET_STS_SUCCESS indicates that all
 |                           the callouts were invoked successfully.
 |                           In this case the caller must COMMIT
 |                           the status changes.
 |
 |                         FND_API.G_RET_STS_ERROR (or other) indicates
 |                           that at least one event did not complete
 |                           successfully. In this case, the caller must
 |                           issue a ROLLBACK to undo all status changes.
 |
 | RETURNS:
 |
 | NOTES:
 |   Internal API, not for public use.
 |
 |   This API will not do a COMMIT. It is the the callers responsbility
 |   to perform COMMIT / ROLLBACK depending upon the returned status.
 |
 |   The callouts invoked must be handled synchronously by the
 |   calling application. So the COMMIT / ROLLBACK should affect
 |   the changes made to the database by the calling application as
 |   well. This will ensure that IBY and the calling application are
 |   in sync w.r.t. to the specified documents payable.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE remove_payment_request (
     p_payreq_id        IN  NUMBER,
     x_return_status    OUT NOCOPY VARCHAR2
     )
 IS

 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME ||
                                             '.remove_payment_request';

 l_docs_list        IBY_VALIDATIONSETS_PUB.rejectedDocTabType;
 l_doc_id_list      docPayIDTab;
 l_doc_status_list  docPayStatusTab;

 /*
  * Cursor to get list of documents along with their statuses for
  * the given payment service request.
  */
 CURSOR c_docs (p_payreq_id IBY_PAY_SERVICE_REQUESTS.
                                payment_service_request_id%TYPE)
 IS
 SELECT
     doc.document_payable_id,
     doc.document_status
 FROM
     IBY_DOCS_PAYABLE_ALL doc
 WHERE
     doc.payment_service_request_id = p_payreq_id
 ;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     FND_MSG_PUB.initialize;

     /*
      * Pick up all documents for this payment request.
      */
     OPEN  c_docs(p_payreq_id);
     FETCH c_docs BULK COLLECT INTO l_docs_list;
     CLOSE c_docs;

     IF (l_docs_list.COUNT <> 0) THEN

         /*
          * Separate out the payment ids and the payment statuses.
          * This is because the rejection API expects these as
          * separate arrays.
          */
         FOR i IN l_docs_list.FIRST .. l_docs_list.LAST LOOP
             l_doc_id_list(i) := l_docs_list(i).doc_id;
         END LOOP;

         FOR i IN l_docs_list.FIRST .. l_docs_list.LAST LOOP
             l_doc_status_list(i) := l_docs_list(i).doc_status;
         END LOOP;

         /*
          * Now, remove all the documents of this request.
          */
         remove_documents_payable (
             l_doc_id_list,
             l_doc_status_list,
             x_return_status
             );

         /*
          * Check if the call to remove the documents succeeded.
          */
         IF (x_return_status IS NULL OR
	     x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

             /*
              * Even if a single call to remove a document
              * failed, return failure for the entire API request.
              */
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Removing of documents '
	                 || 'for payment request '
	                 || p_payreq_id
	                 || ' failed.'
	                 );

	             print_debuginfo(l_module_name, 'EXIT');

             END IF;
             /*
              * It is the callers responsibility to rollback
              * all the changes.
              */
             RETURN;

         END IF;

     ELSE

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'No documents were found for '
	             || 'payment request id '
	             || p_payreq_id
	             || '. Skipping ..'
	             );

         END IF;
     END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Returning success response ..');

	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END remove_payment_request;

/*--------------------------------------------------------------------
 | NAME:
 |     stop_payment
 |
 |
 | PURPOSE:
 |     Invokes a callout of the calling app to remove a set of
 |     submitted documents payable from the payment processing
 |     cycle.
 |
 |     The calling application can free up the removed documents, and
 |     make them available for submission in future payment request(s).
 |
 | PARAMETERS:
 |     IN
 |       p_pmt_id          - ID of the payment to be stopped.
 |
 |       p_pmt_status_list - Current status of the payment to
 |                           be stopped.
 |
 |     OUT
 |       x_return_status   - Result of the API call:
 |                         FND_API.G_RET_STS_SUCCESS indicates that the
 |                           callout was invoked successfully.
 |                           In this case the caller must COMMIT
 |                           the status changes.
 |
 |                         FND_API.G_RET_STS_ERROR (or other) indicates
 |                           that tha API did not complete successfully.
 |                           In this case, the caller must issue a
 |                           ROLLBACK to undo all status changes.
 |
 | RETURNS:
 |
 | NOTES:
 |   Internal API, not for public use.
 |
 |   This API will not do a COMMIT. It is the the callers responsibility
 |   to perform COMMIT / ROLLBACK depending upon the returned status.
 |
 |   The callouts invoked must be handled synchronously by the
 |   calling application. So the COMMIT / ROLLBACK should affect
 |   the changes made to the database by the calling application as
 |   well. This will ensure that IBY and the calling application are
 |   in sync w.r.t. to the specified documents payable.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE stop_payment (
     p_pmt_id         IN NUMBER,
     p_pmt_status     IN VARCHAR2,
     x_return_status  OUT NOCOPY VARCHAR2
     )
 IS

l_module_name    CONSTANT VARCHAR2(200) := G_PKG_NAME ||'.stop_payment ';

 l_rejection_id   NUMBER(15);

 /* used in forming callout procedure name */
 l_calling_app_id NUMBER;
 l_app_short_name VARCHAR2(200);
 l_pkg_name       VARCHAR2(200);
 l_callout_name   VARCHAR2(500);
 l_stmt           VARCHAR2(1000);

 /* used in invocation of callout procedure */
 l_api_version    CONSTANT NUMBER := 1.0;
 l_msg_count      NUMBER;
 l_msg_data       VARCHAR2(2000);


l_instr_id       IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE;
l_valid_pmts_count NUMBER;

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
     FND_MSG_PUB.initialize;

     /*
      * STATUS CHANGE:
      *
      * UI Responsibility:
      * payment status = REMOVED_PAYMENT_STOPPED
      *
      * API Responsibility:
      * document_status = REMOVED_PAYMENT_STOPPED
      */
     UPDATE
         IBY_DOCS_PAYABLE_ALL
     SET
         document_status = DOC_STATUS_PMT_STOPPED
     WHERE
         payment_id = p_pmt_id
     ;

     /*
      * Get the next available rejected document group id.
      */
     SELECT
         IBY_REJECTED_DOCS_GROUP_S.NEXTVAL
     INTO
         l_rejection_id
     FROM
         DUAL
     ;

     /*
      * Update the removed documents with the rejected document
      * group id. The calling application will identify rejected
      * documents using this id.
      */
     UPDATE
         IBY_DOCS_PAYABLE_ALL
     SET
         rejected_docs_group_id = l_rejection_id
     WHERE
         payment_id = p_pmt_id
     ;

/* Bug 6609931 */
BEGIN
	SELECT
	   instr.payment_instruction_id
	INTO
	   l_instr_id
	FROM
	  IBY_PAY_INSTRUCTIONS_ALL instr,
	  IBY_PAYMENTS_ALL pmt
	WHERE
	  instr.payment_instruction_id = pmt.payment_instruction_id AND
	  pmt.payment_id = p_pmt_id;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
           l_instr_id:=null;
 END;

/* Bug 7028817*/
/* If the payment is stopped before instruction is created,
should by pass the below logic.
So, having condition based on the instruction id*/

IF  l_instr_id IS NOT NULL THEN

	-- get the count of valid payments- which are not stopped, voided, removed
	-- and overfloW/setup payment- these will not have payment reference number
	   SELECT
	       count(*)
	  INTO
	      l_valid_pmts_count
	  FROM
	      IBY_PAYMENTS_ALL pmt
	  WHERE
	    pmt.payment_instruction_id = l_instr_id AND
	    pmt.payment_reference_number is not null AND
	    pmt.payment_status NOT IN
	      (PAY_STATUS_VOID, PAY_STATUS_REMOVED, PAY_STATUS_STOPPED, PAY_STATUS_REJECTED);


	print_debuginfo(l_module_name , 'The number of valid payments : ' ||
	l_valid_pmts_count);


	  IF (l_valid_pmts_count = 0) THEN
		/*
		 * * Set the payment instruction status to TERMINATED
		 * * because no valid payments now exist for this
		 * * payment instruction.
		 * */

		UPDATE
		     IBY_PAY_INSTRUCTIONS_ALL
		SET
		    payment_instruction_status = INS_STATUS_TERMINATED
		WHERE
		    payment_instruction_id = l_instr_id;

			/* Also since the Payment Instruction is terminated
			 * we should be unlocking the payment document which this
			 * instruction may be locking to make it available for other
			 * Done per bug 6852606
			 */
			 print_debuginfo(l_module_name, 'Trying to unlock the payment document as PI termination: ');
			 UPDATE
			     CE_PAYMENT_DOCUMENTS
			 SET
			     payment_instruction_id = NULL,
			     /* Bug 6707369
			      * If some of the documents are skipped, the payment
			      * document's last issued check number must be updated
			      */
			     last_issued_document_number = nvl(
				     (SELECT MAX(pmt.paper_document_number)
				      FROM iby_payments_all pmt
				      WHERE pmt.payment_instruction_id = l_instr_id)
				      ,last_issued_document_number
				      )
			 WHERE
			     payment_instruction_id = l_instr_id;
			 print_debuginfo(l_module_name, 'Payment document unlocking successful for PI : ' || l_instr_id);

	  END IF;

 END IF;
 /* ending if for the condition based on instruction id(Bug 7028817)*/


     /*
      * Get the application name of the calling app. This
      * will be used in the callout.
      */
     SELECT
         fnd.application_short_name
     INTO
         l_app_short_name
     FROM
         FND_APPLICATION           fnd,
         IBY_PAYMENTS_ALL          pmt,
         IBY_PAY_SERVICE_REQUESTS  req
     WHERE
         fnd.application_id             = req.calling_app_id             AND
         req.payment_service_request_id = pmt.payment_service_request_id AND
         pmt.payment_id                 = p_pmt_id
     ;

     /*
      * Get the constructed package name to use in the
      * call out.
      */
     l_pkg_name := construct_callout_pkg_name(l_app_short_name);

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Constructed package name: '
	         || l_pkg_name);

     END IF;
     IF (l_pkg_name IS NULL) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Package name is null. '
	             || 'Raising exception.');

         END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;

     END IF;

     /*
      * Now try to call the external app's implementation of the hook.
      * The calling app may or may not have implemented the hook, so
      * it's not fatal if the implementation does not exist.
      */
     l_callout_name := l_pkg_name || '.' || 'documents_payable_rejected';

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Attempting to invoke callout: '
	         || l_callout_name);

     END IF;
     l_stmt := 'CALL '|| l_callout_name || '(:1, :2, :3, :4, :5, :6, :7)';

     BEGIN

         EXECUTE IMMEDIATE
             (l_stmt)
         USING
             IN  l_api_version,
             IN  FND_API.G_FALSE,
             IN  FND_API.G_FALSE,
             OUT x_return_status,
             OUT l_msg_count,
             OUT l_msg_data,
             IN  l_rejection_id
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
	                 || '. Raising exception.'
	                 );

             END IF;
             APP_EXCEPTION.RAISE_EXCEPTION;

         END IF;

     EXCEPTION

         WHEN PROCEDURE_NOT_IMPLEMENTED THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Callout "' || l_callout_name
	                 || '" not implemented by calling app '
	                 || l_app_short_name || '.');

	             print_debuginfo(l_module_name, 'Skipping hook call.');

             END IF;
         WHEN OTHERS THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Fatal: External app callout '''
	                 || l_callout_name
	                 || ''', generated exception.'
	                 );

	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);
             END IF;
             FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

             /*
              * Propogate exception to caller.
              */
             RAISE;
     END;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 EXCEPTION

     WHEN OTHERS THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Exception occured when '
	             || 'stopping payment '
	             || p_pmt_id
	             || ', with status '
	             || p_pmt_status
	             );

	         print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	         print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);
         END IF;
         FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

         x_return_status := FND_API.G_RET_STS_ERROR;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
 END stop_payment;

/*--------------------------------------------------------------------
 | NAME:
 |     stop_payments
 |
 | PURPOSE:
 |     Invokes a series of callouts of the calling app to remove
 |     a set of submitted documents payable from the payment processing
 |     cycle.
 |
 |     The calling application can free up the removed documents, and
 |     make them available for submission in future payment request(s).
 |
 | PARAMETERS:
 |     IN
 |       p_pmt_list        - IDs of the payments to be stopped.
 |                           This should be an array of payment ids. All
 |                           the child documents payable of each of the
 |                           specified payments will be removed.
 |
 |       p_pmt_status_list - Current statuses of the payments to
 |                           be stopped. This should be an array of statuses.
 |
 |     OUT
 |       x_return_status   - Result of the API call:
 |                         FND_API.G_RET_STS_SUCCESS indicates that all
 |                           the callouts were invoked successfully.
 |                           In this case the caller must COMMIT
 |                           the status changes.
 |
 |                         FND_API.G_RET_STS_ERROR (or other) indicates
 |                           that at least one event did not complete
 |                           successfully. In this case, the caller must
 |                           issue a ROLLBACK to undo all status changes.
 |
 | RETURNS:
 |
 | NOTES:
 |   Internal API, not for public use.
 |
 |   This API will not do a COMMIT. It is the the callers responsbility
 |   to perform COMMIT / ROLLBACK depending upon the returned status.
 |
 |   The callouts invoked must be handled synchronously by the
 |   calling application. So the COMMIT / ROLLBACK should affect
 |   the changes made to the database by the calling application as
 |   well. This will ensure that IBY and the calling application are
 |   in sync w.r.t. to the specified documents payable.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE stop_payments (
     p_pmt_list         IN pmtIDTab,
     p_pmt_status_list  IN pmtStatusTab,
     x_return_status    OUT NOCOPY VARCHAR2
     )
 IS

 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME || '.stop_payments';

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     FND_MSG_PUB.initialize;

     IF (p_pmt_list.COUNT = 0 OR p_pmt_status_list.COUNT = 0) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Error: List of payment '
	             || 'payable ids/statuses is empty'
	             || '. Returning failure response .. '
	             );

         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     END IF;

     IF (p_pmt_list.COUNT <> p_pmt_status_list.COUNT) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Error: List of payment '
	             || 'ids must match list of payment statuses. '
	             || 'Returning failure response .. '
	             );

         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     END IF;

     /*
      * Start processing the payments, one-by-one.
      */
     FOR i IN p_pmt_list.FIRST .. p_pmt_list.LAST LOOP

         stop_payment (
             p_pmt_list(i),
             p_pmt_status_list(i),
             x_return_status
             );

         /*
          * Check if the call to stop the payment succeeded.
          */
         IF (x_return_status IS NULL OR
	     x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

             /*
              * Even if a single call to stop a payment
              * failed, return failure for the entire API request.
              */
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Stopping of payment '
	                 || p_pmt_list(i)
	                 || ' failed.'
	                 );

	             print_debuginfo(l_module_name, 'EXIT');

             END IF;
             /*
              * It is the callers responsibility to rollback
              * all the changes.
              */
             RETURN;

         END IF;

     END LOOP;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Returning success response ..');

	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END stop_payments;

/*--------------------------------------------------------------------
 | NAME:
 |     void_payment
 |
 | PURPOSE:
 |     Sets the status of the specified payment id to VOID in the IBY
 |     tables. This API is used in the AP void and reissue flow to keep
 |     IBY and AP tables in sync.
 |
 |     This API is meant for AP only and should not be used by the IBY UI.
 |     There is a separate API for voiding payments from the IBY UI - see
 |     void_pmt_internal(..) method.
 |
 | PARAMETERS:
 |     IN
 |       p_api_version   - Version of the API.
 |
 |       p_init_msg_list - Standard API parameter; default as FND_API.G_FALSE
 |
 |       p_pmt_id        - ID of the payment to be voided. This id will map
 |                         to IBY_PAYMENTS_ALL.PAYMENT_ID column.
 |
 |       p_voided_by     - User id of person who issued the void request.
 |                         This id will be stored as an attribute of the
 |                         payment.
 |
 |       p_void_date     - Date on which the void request was made.
 |
 |       p_void_reason   - Reason why this payment needs to be voided.
 |
 |     OUT
 |       x_return_status - Standard return status. Possible values are:
 |                         FND_API.G_RET_STS_SUCCESS
 |                           API completed successfully. Caller must
 |                           now COMMIT the database changes.
 |
 |                         FND_API.G_RET_STS_ERROR
 |                           API call failed. Caller must ROLLBACK any
 |                           base changes.
 |
 |       x_msg_count     - Standard msg count
 |
 |       x_msg_data      - Standard msg data
 |
 | RETURNS:
 |
 | NOTES:
 |  Public API.
 |
 |  This API will not do a COMMIT. It is the the callers responsbility
 |  to perform COMMIT / ROLLBACK depending upon the returned status.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE void_payment (
     p_api_version    IN NUMBER,
     p_init_msg_list  IN VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_pmt_id         IN NUMBER,
     p_voided_by      IN NUMBER,
     p_void_date      IN DATE,
     p_void_reason    IN VARCHAR2,
     x_return_status  OUT NOCOPY VARCHAR2,
     x_msg_count      OUT NOCOPY NUMBER,
     x_msg_data       OUT NOCOPY VARCHAR2
     )
 IS

 l_module_name   CONSTANT VARCHAR2(200) := G_PKG_NAME || '.void_payment';
 l_calling_app_id NUMBER;

 l_api_version   CONSTANT NUMBER        := 1.0;
 l_api_name      CONSTANT VARCHAR2(100) := 'void_payment';

 l_instr_id       IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE;
 l_valid_pmts_count
                  NUMBER;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

	     print_debuginfo(l_module_name, 'Parameters passed - '
	         || 'payment id: '
	         || p_pmt_id
	         || ', voided by: '
	         || p_voided_by
	         || ', void date: '
	         || p_void_date
	         || ', void reason: '
	         || p_void_reason
	         );

     END IF;
     /* Standard call to check for API compatibility */
     IF NOT FND_API.Compatible_API_Call(
                        l_api_version,
                        p_api_version,
                        l_api_name,
                        G_PKG_NAME) THEN

         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

     END IF;

     /* Initialize message list if p_init_msg_list is set to TRUE */
     IF FND_API.to_boolean(p_init_msg_list) THEN
         FND_MSG_PUB.initialize;
     END IF;

     /* Initialize return status */
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     /*
      * STEP I:
      *
      * Void the specified payment.
      */
     UPDATE
         IBY_PAYMENTS_ALL
     SET
         payment_status = PAY_STATUS_VOID,
         voided_by      = p_voided_by,
         void_date      = p_void_date,
         void_reason    = p_void_reason,
	 positive_pay_file_created_flag = NULL
     WHERE
         payment_id = p_pmt_id
     ;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Payment '
	         || p_pmt_id
	         || ' set to void status ..'
	         );

     END IF;
     /*
      * STEP II:
      *
      * Void the documents linked to this payment.
      */
     UPDATE
         IBY_DOCS_PAYABLE_ALL
     SET
         document_status = DOC_STATUS_PMT_VOIDED
     WHERE
         payment_id = p_pmt_id
     ;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Documents of payment '
	         || p_pmt_id
	         || ' set to void status ..'
	         );

     END IF;
     /*
      * STEP III:
      *
      * Fix for bug 5017119:
      *
      * After voiding this payment, check the payment instruction
      * to see whether any non-voided / non-removed payments
      * exist for this instruction.
      *
      * If this payment was the last valid payment on the instruction,
      * and we just voided it, then set the status of the instruction
      * to TERMINATED to signify that this is the final status for
      * the instruction.
      */

     /*
      * Fix for bug 5108035:
      *
      * Don't assume that every payment to be voided will have an
      * associated payment instruction id; a manual payment will
      * not have a payment instruction id for example.
      *
      *
      * Therefore, if we run into an exception when attempting to
      * get the payment instruction of the payment to be voided,
      * treat it as non-fatal.
      */
     BEGIN

         SELECT
             instr.payment_instruction_id
         INTO
             l_instr_id
         FROM
             IBY_PAY_INSTRUCTIONS_ALL instr,
             IBY_PAYMENTS_ALL         pmt
         WHERE
             instr.payment_instruction_id = pmt.payment_instruction_id AND
             pmt.payment_id = p_pmt_id
         ;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Provided payment '
	             || p_pmt_id
	             || ' has payment instruction id '
	             || l_instr_id
	             || '. Checking this instruction for any remaining '
	             || 'valid payments ..'
	             );

         END IF;
         SELECT
             count(*)
         INTO
             l_valid_pmts_count
         FROM
             IBY_PAYMENTS_ALL pmt
         WHERE
             pmt.payment_instruction_id = l_instr_id AND
             pmt.payment_status NOT IN
                 (
                  PAY_STATUS_VOID,
                  PAY_STATUS_REMOVED
                 )
         ;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Number of remaining valid payments '
	             || 'for pmt instruction '
	             || l_instr_id
	             || ' is '
	             || l_valid_pmts_count
	             );

         END IF;
         IF (l_valid_pmts_count = 0) THEN

             /*
              * Set the payment instruction status to TERMINATED
              * because no valid payments now exist for this
              * payment instruction.
              */
             UPDATE
                 IBY_PAY_INSTRUCTIONS_ALL
             SET
                 payment_instruction_status = INS_STATUS_TERMINATED
             WHERE
                 payment_instruction_id = l_instr_id
             ;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Status of payment instruction '
	                 || l_instr_id
	                 || ' updated to TERMINATED because it has no remaining '
	                 || 'valid payments.'
	                 );

             END IF;
	/* Also since the Payment Instruction is terminated
	 * we should be unlocking the payment document which this
	 * instruction may be locking to make it available for other
	 * Done per bug 6852606
	 */
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Trying to unlock the payment document as PI termination: ');
         END IF;
	 UPDATE
	     CE_PAYMENT_DOCUMENTS
	 SET
	     payment_instruction_id = NULL,
	     /* Bug 6707369
	      * If some of the documents are skipped, the payment
	      * document's last issued check number must be updated
	      */
	     last_issued_document_number = nvl(
		     (SELECT MAX(pmt.paper_document_number)
		      FROM iby_payments_all pmt
		      WHERE pmt.payment_instruction_id = l_instr_id)
		      ,last_issued_document_number
		      )
	 WHERE
	     payment_instruction_id = l_instr_id;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Payment document unlocking successful for PI : ' || l_instr_id);

         END IF;
         END IF;

     EXCEPTION

         WHEN OTHERS THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Non-fatal: Exception occured '
	                 || 'when attempting to get parent payment instruction of '
	                 || 'payment '
	                 || p_pmt_id
	                 );

	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);

             END IF;
     END;

     /*
      * Standard call to get message count and if count is 1, get
      * message info.
      */
     FND_MSG_PUB.Count_And_Get(
                     p_encoded => FND_API.G_FALSE,
                     p_count   => x_msg_count,
                     p_data    => x_msg_data
                     );

     x_return_status := FND_API.G_RET_STS_SUCCESS;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Returning success response ..');

	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
     EXCEPTION

         WHEN OTHERS THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Exception occured when '
	                 || 'attempting to void payment id '
	                 || p_pmt_id
	                 );

	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);
             END IF;
             FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

             x_return_status := FND_API.G_RET_STS_ERROR;

             FND_MSG_PUB.Count_And_Get(
                             p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count,
                             p_data    => x_msg_data
                             );

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Returning error response ..');
	             print_debuginfo(l_module_name, 'EXIT');

             END IF;
             RETURN;

 END void_payment;

/*--------------------------------------------------------------------
 | NAME:
 |     void_pmt_internal
 |
 | PURPOSE:
 |     Sets the status of the specified payment id to VOID in the IBY
 |     tables. This API is used in the IBY UI to void a payment.
 |
 |     This API is meant for IBY only and should not be used by AP.
 |     There is a separate public API for voiding payments from AP - see
 |     void_payment(..) method.
 |
 | PARAMETERS:
 |     IN
 |       p_api_version   - Version of the API.
 |
 |       p_init_msg_list - Standard API parameter; default as FND_API.G_FALSE
 |
 |       p_pmt_id        - ID of the payment to be voided. This id will map
 |                         to IBY_PAYMENTS_ALL.PAYMENT_ID column.
 |
 |       p_voided_by     - User id of person who issued the void request.
 |                         This id will be stored as an attribute of the
 |                         payment.
 |
 |       p_void_date     - Date on which the void request was made.
 |
 |       p_void_reason   - Reason why this payment needs to be voided.
 |
 |     OUT
 |       x_return_status - Standard return status. Possible values are:
 |                         FND_API.G_RET_STS_SUCCESS
 |                           API completed successfully. Caller must
 |                           now COMMIT the database changes.
 |
 |                         FND_API.G_RET_STS_ERROR
 |                           API call failed. Caller must ROLLBACK any
 |                           base changes.
 |
 |       x_msg_count     - Standard msg count
 |
 |       x_msg_data      - Standard msg data
 |
 | RETURNS:
 |
 | NOTES:
 |  Internal API, not for public use.
 |
 |  This API will not do a COMMIT. It is the the callers responsbility
 |  to perform COMMIT / ROLLBACK depending upon the returned status.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE void_pmt_internal (
     p_api_version    IN NUMBER,
     p_init_msg_list  IN VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_pmt_id         IN NUMBER,
     p_voided_by      IN NUMBER,
     p_void_date      IN DATE,
     p_void_reason    IN VARCHAR2,
     x_return_status  OUT NOCOPY VARCHAR2,
     x_msg_count      OUT NOCOPY NUMBER,
     x_msg_data       OUT NOCOPY VARCHAR2
     )
 IS

 l_module_name   CONSTANT VARCHAR2(200) := G_PKG_NAME || '.void_pmt_internal';
 l_calling_app_id NUMBER;

 l_api_version   CONSTANT NUMBER        := 1.0;
 l_api_name      CONSTANT VARCHAR2(100) := 'void_pmt_internal';

 /* used in forming callout procedure name */
 l_app_short_name VARCHAR2(200);
 l_pkg_name       VARCHAR2(200);
 l_callout_name   VARCHAR2(500);
 l_stmt           VARCHAR2(1000);

 /* used in invocation of callout procedure */
 l_msg_count      NUMBER;
 l_msg_data       VARCHAR2(2000);

 l_ret_flag       VARCHAR2(1) := 'Y';

 l_test           VARCHAR2(2000);
 l_org            NUMBER(15);

 l_instr_id       IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE;

 l_valid_pmts_count NUMBER;
 l_curr_pmt_status  VARCHAR2(200);

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
     /*
      * Set the apps context. This is necessary so that
      * the calling application can see the org based
      * tables associated with this payment.
      *
      * See bug 4945922.
      */
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Setting apps context .. ');

     END IF;
     fnd_global.APPS_INITIALIZE(
         user_id      => fnd_global.user_id,
         resp_id      => fnd_global.resp_id,
         resp_appl_id => fnd_global.resp_appl_id
         );

     mo_global.init(fnd_global.application_short_name);

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Apps context set [user: '
	         || fnd_global.user_id
	         || ', responsbility id: '
	         || fnd_global.resp_id
	         || ', responsibility application id: '
	         || fnd_global.resp_appl_id
	         || ']'
	         );

	     print_debuginfo(l_module_name, 'Apps context [app short name: '
	         || fnd_global.application_short_name
	         || ']'
	         );

     END IF;
    /*--- RYAN TEST CODE ---*/
    /*---- start ----*/
    /*
    begin
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name, 'Start RYAN test');
      END IF;
      select 'row found in moac synonym'
      into l_test
      from ap_invoices
      where invoice_id = 10045;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name, 'End RYAN test: l_test = ' || l_test);
      END IF;
    exception
      when no_data_found then
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('RYAN TEST: ap_pmt_callout_pkg',
	          'in no data found exception');
      END IF;
    end;
    */
    /*---- end ----*/

    /*--- YING TEST CODE ---*/
    /*---- start ----*/
    /*
    begin
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name, 'Start YING test');
      END IF;
      select organization_id
      into l_org
      from ce_security_profiles_v
      where organization_type='OPERATING_UNIT';
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name, 'End YING test: l_org = ' || l_org);
      END IF;
    exception
      when no_data_found then
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('YING TEST: org id',
	          'in no data found exception');
      END IF;
    end;
    */
    /*---- end ----*/

     /* Standard call to check for API compatibility */
     IF NOT FND_API.Compatible_API_Call(
                        l_api_version,
                        p_api_version,
                        l_api_name,
                        G_PKG_NAME) THEN

         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

     END IF;

     /* Initialize message list if p_init_msg_list is set to TRUE */
     IF FND_API.to_boolean(p_init_msg_list) THEN
         FND_MSG_PUB.initialize;
     END IF;

     /* Initialize return status */
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     /*
      * Fix for bug 5623941:
      *
      * STEP I:
      *
      * Before doing anything check if the payment is already
      * voided. If it is already voided, we don't need to do anything;
      * just exit.
      */

     /*
      * Get the current status of the
      * payment into l_curr_pmt_status
      */
     SELECT
         pmt.payment_status
     INTO
         l_curr_pmt_status
     FROM
         IBY_PAYMENTS_ALL pmt
     WHERE
         payment_id = p_pmt_id
     ;

     IF (l_curr_pmt_status = PAY_STATUS_VOID) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Payment '
	             || p_pmt_id
	             || ' is already voided. Skipping .. '
	             );

         END IF;
         x_return_status := FND_API.G_RET_STS_SUCCESS;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning success response ..');
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     END IF;

     /*
      * STEP II:
      *
      * Check if the external application allows this payment
      * to be voided. If not there is no point in proceeding
      * further.
      */
     is_void_allowed (
         p_api_version,
         FND_API.G_FALSE,
         p_pmt_id,
         l_ret_flag,
         x_return_status,
         x_msg_count,
         x_msg_data
         );

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Void allowed flag '
	          || 'after call to is_void_allowed() API: '
	          || l_ret_flag
	          );

     END IF;
     /*
      * If the void allowed flag is not set to 'Y',
      * exit the procedure with an error.
      */
     IF (UPPER(l_ret_flag) <> 'Y') THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Void not allowed. '
	             || 'Returning failure response.'
	             );

         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;

         FND_MSG_PUB.Count_And_Get(
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
             );

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     END IF;

     /*
      * STEP III:
      *
      * Void the specified payment.
      */
     UPDATE
         IBY_PAYMENTS_ALL
     SET
         payment_status = PAY_STATUS_VOID,
         voided_by      = p_voided_by,
         void_date      = p_void_date,
         void_reason    = p_void_reason,
	 positive_pay_file_created_flag = NULL
     WHERE
         payment_id = p_pmt_id
     ;

     /*
      * STEP IV:
      *
      * Void the documents linked to this payment.
      */
     UPDATE
         IBY_DOCS_PAYABLE_ALL
     SET
         document_status = DOC_STATUS_PMT_VOIDED
     WHERE
         payment_id = p_pmt_id
     ;

     /*
      * STEP V:
      *
      * Fix for bug 5017119:
      *
      * After voiding this payment, check the payment instruction
      * to see whether any non-voided / non-removed payments
      * exist for this instruction.
      *
      * If this payment was the last valid payment on the instruction,
      * and we just voided it, then set the status of the instruction
      * to TERMINATED to signify that this is the final status for
      * the instruction.
      */

     /*
      * Fix for bug 8729551:
      *
      * Don't assume that every payment to be voided will have an
      * associated payment instruction id; a manual payment will
      * not have a payment instruction id for example.
      *
      *
      * Therefore, if we run into an exception when attempting to
      * get the payment instruction of the payment to be voided,
      * treat it as non-fatal.
      */

     BEGIN
	     SELECT
		 instr.payment_instruction_id
	     INTO
		 l_instr_id
	     FROM
		 IBY_PAY_INSTRUCTIONS_ALL instr,
		 IBY_PAYMENTS_ALL         pmt
	     WHERE
		 instr.payment_instruction_id = pmt.payment_instruction_id AND
		 pmt.payment_id = p_pmt_id
	     ;

	     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		     print_debuginfo(l_module_name, 'Provided payment '
			 || p_pmt_id
			 || ' has payment instruction id '
			 || l_instr_id
			 || '. Checking this instruction for any remaining valid payments ..'
			 );

	     END IF;
	     SELECT
		 count(*)
	     INTO
		 l_valid_pmts_count
	     FROM
		 IBY_PAYMENTS_ALL pmt
	     WHERE
		 pmt.payment_instruction_id = l_instr_id AND
		 pmt.payment_status NOT IN
		     (
		      PAY_STATUS_VOID,
		      PAY_STATUS_REMOVED
		     )
	     ;

	     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		     print_debuginfo(l_module_name, 'Number of remaining valid payments '
			 || 'for pmt instruction '
			 || l_instr_id
			 || ' is '
			 || l_valid_pmts_count
			 );

	     END IF;
	     IF (l_valid_pmts_count = 0) THEN

		 /*
		  * Set the payment instruction status to TERMINATED
		  * because no valid payments now exist for this
		  * payment instruction.
		  */
		 UPDATE
		     IBY_PAY_INSTRUCTIONS_ALL
		 SET
		     payment_instruction_status = INS_STATUS_TERMINATED
		 WHERE
		     payment_instruction_id = l_instr_id
		 ;

		 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			 print_debuginfo(l_module_name, 'Status of payment instruction '
			     || l_instr_id
			     || ' updated to TERMINATED because it has no remaining '
			     || 'valid payments.'
			     );

		 END IF;
		/* Also since the Payment Instruction is terminated
		 * we should be unlocking the payment document which this
		 * instruction may be locking to make it available for other
		 * Done per bug 6852606
		 */
		 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			 print_debuginfo(l_module_name, 'Trying to unlock the payment document as PI termination: ');
		 END IF;
		 UPDATE
		     CE_PAYMENT_DOCUMENTS
		 SET
		     payment_instruction_id = NULL,
		     /* Bug 6707369
		      * If some of the documents are skipped, the payment
		      * document's last issued check number must be updated
		      */
		     last_issued_document_number = nvl(
			     (SELECT MAX(pmt.paper_document_number)
			      FROM iby_payments_all pmt
			      WHERE pmt.payment_instruction_id = l_instr_id)
			      ,last_issued_document_number
			      )
		 WHERE
		     payment_instruction_id = l_instr_id;
		 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			 print_debuginfo(l_module_name, 'Payment document unlocking successful for PI : ' || l_instr_id);


		 END IF;
	     END IF;
     EXCEPTION

         WHEN OTHERS THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Non-fatal: Exception occured '
	                 || 'when attempting to get parent payment instruction of '
	                 || 'payment '
	                 || p_pmt_id
	                 );

	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);

             END IF;
     END;

     /*
      * STEP VI:
      *
      * Call external application hook to inform it of
      * the voided payments.
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
         FND_APPLICATION           fnd,
         IBY_PAYMENTS_ALL          pmt,
         IBY_PAY_SERVICE_REQUESTS  req
     WHERE
         fnd.application_id             = req.calling_app_id             AND
         req.payment_service_request_id = pmt.payment_service_request_id AND
         pmt.payment_id                 = p_pmt_id
     ;

     /*
      * Get the constructed package name to use in the
      * call out.
      */
     l_pkg_name := construct_callout_pkg_name(l_app_short_name);

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Constructed package name: '
	         || l_pkg_name);

     END IF;
     IF (l_pkg_name IS NULL) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Package name is null. '
	             || 'Raising exception.');

         END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;

     END IF;

     /*
      * Now try to call the external app's implementation of the hook.
      * The calling app may or may not have implemented the hook, so
      * it's not fatal if the implementation does not exist.
      */
     l_callout_name := l_pkg_name || '.' || 'payment_voided';

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Attempting to invoke callout: '
	         || l_callout_name);

     END IF;
     --l_stmt := 'CALL '|| l_callout_name
     --                     || '(:1, :2, :3, :4, :5, :6, :7, :8)';

     l_stmt := 'BEGIN '|| l_callout_name
                          || '('
                          || 'p_api_version   => :1, '
                          || 'p_payment_id    => :2, '
                          || 'p_void_date     => :3, '
                          || 'p_init_msg_list => :4, '
                          || 'p_commit        => :5, '
                          || 'x_return_status => :6, '
                          || 'x_msg_count     => :7, '
                          || 'x_msg_data      => :8  '
                          || '); END;'
                          ;

     BEGIN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Params passed to callout - ');
	         print_debuginfo(l_module_name, 'p_pmt_id: '    || p_pmt_id);
	         print_debuginfo(l_module_name, 'p_void_date: ' || p_void_date);

         END IF;
         EXECUTE IMMEDIATE
             (l_stmt)
         USING
             IN  l_api_version,
             IN  p_pmt_id,
             IN  p_void_date,
             IN  FND_API.G_FALSE,
             IN  FND_API.G_FALSE,   /* commit flag */
             OUT x_return_status,
             OUT l_msg_count,
             OUT l_msg_data
         ;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Finished invoking callout ..');
	         print_debuginfo(l_module_name, 'Status returned by callout: '
	             || x_return_status);

         END IF;
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
	                 || '. Raising exception.'
	                 );

             END IF;
             APP_EXCEPTION.RAISE_EXCEPTION;

         END IF;

     EXCEPTION

         WHEN PROCEDURE_NOT_IMPLEMENTED THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Callout "' || l_callout_name
	                 || '" not implemented by calling app '
	                 || l_app_short_name || '.');

	             print_debuginfo(l_module_name, 'Skipping hook call.');

             END IF;
         WHEN OTHERS THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Fatal: External app callout '''
	                 || l_callout_name
	                 || ''', generated exception.'
	                 );

	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);
             END IF;
             FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

             /*
              * Propogate exception to caller.
              */
             RAISE;
     END;

     /*
      * Standard call to get message count and if count is 1, get
      * message info.
      */
     FND_MSG_PUB.Count_And_Get(
                     p_encoded => FND_API.G_FALSE,
                     p_count   => x_msg_count,
                     p_data    => x_msg_data
                     );

     x_return_status := FND_API.G_RET_STS_SUCCESS;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Returning success response ..');

	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 EXCEPTION
     WHEN OTHERS THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Exception occured when '
	             || 'attempting to void payment id '
	             || p_pmt_id
	             );

	         print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	         print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);
         END IF;
         FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

         x_return_status := FND_API.G_RET_STS_ERROR;

         FND_MSG_PUB.Count_And_Get(
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
             );

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning error response ..');
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

 END void_pmt_internal;

/*--------------------------------------------------------------------
 | NAME:
 |     is_void_allowed
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
 PROCEDURE is_void_allowed (
     p_api_version    IN NUMBER,
     p_init_msg_list  IN VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_pmt_id         IN NUMBER,
     x_return_flag    OUT NOCOPY VARCHAR2,   /* 'Y'/'N' flag */
     x_return_status  OUT NOCOPY VARCHAR2,
     x_msg_count      OUT NOCOPY NUMBER,
     x_msg_data       OUT NOCOPY VARCHAR2
     )
 IS

 l_module_name    CONSTANT VARCHAR2(200) := G_PKG_NAME || '.is_void_allowed';

 /* used in forming callout procedure name */
 l_app_short_name VARCHAR2(200);
 l_pkg_name       VARCHAR2(200);
 l_callout_name   VARCHAR2(500);
 l_stmt           VARCHAR2(1000);

 /* used in invocation of callout procedure */
 l_api_version    CONSTANT NUMBER := 1.0;
 l_msg_count      NUMBER;
 l_msg_data       VARCHAR2(2000);

 l_api_name      CONSTANT VARCHAR2(100) := 'is_void_allowed';

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
     /* Standard call to check for API compatibility */
     IF NOT FND_API.Compatible_API_Call(
                        l_api_version,
                        p_api_version,
                        l_api_name,
                        G_PKG_NAME) THEN

         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

     END IF;

     /* Initialize message list if p_init_msg_list is set to TRUE */
     IF FND_API.to_boolean(p_init_msg_list) THEN
         FND_MSG_PUB.initialize;
     END IF;

     /* Initialize return status */
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     /*
      * Get the application name of the calling app. This
      * will be used in the callout.
      */
     SELECT
         fnd.application_short_name
     INTO
         l_app_short_name
     FROM
         FND_APPLICATION           fnd,
         IBY_PAYMENTS_ALL          pmt,
         IBY_PAY_SERVICE_REQUESTS  req
     WHERE
         fnd.application_id             = req.calling_app_id             AND
         req.payment_service_request_id = pmt.payment_service_request_id AND
         pmt.payment_id                 = p_pmt_id
     ;

     /*
      * Get the constructed package name to use in the
      * call out.
      */
     l_pkg_name := construct_callout_pkg_name(l_app_short_name);

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Constructed package name: '
	         || l_pkg_name);

     END IF;
     IF (l_pkg_name IS NULL) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Package name is null. '
	             || 'Raising exception.');

         END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;

     END IF;

     /*
      * Now try to call the external app's implementation of the hook.
      * The calling app may or may not have implemented the hook, so
      * it's not fatal if the implementation does not exist.
      */
     l_callout_name := l_pkg_name || '.' || 'void_payment_allowed';

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Attempting to invoke callout: '
	         || l_callout_name);

     END IF;
     l_stmt := 'CALL '|| l_callout_name || '(:1, :2, :3, :4, :5, :6, :7, :8)';

     BEGIN

         EXECUTE IMMEDIATE
             (l_stmt)
         USING
             IN  l_api_version,
             IN  FND_API.G_FALSE,
             IN  FND_API.G_FALSE,
             IN  p_pmt_id,
             OUT x_return_flag,
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
	                 || '. Raising exception.'
	                 );

             END IF;
             APP_EXCEPTION.RAISE_EXCEPTION;

         END IF;

     EXCEPTION

         WHEN PROCEDURE_NOT_IMPLEMENTED THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Callout "' || l_callout_name
	                 || '" not implemented by calling app '
	                 || l_app_short_name || '.');

	             print_debuginfo(l_module_name, 'Skipping hook call.');

             END IF;
             /*
              * Fix for bug 5083294:
              *
              * Default the return flag to 'Y' (meaning
              * void is allowed) in case the calling
              * application has not implemented this
              * callout.
              */
             x_return_flag := 'Y';

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Defaulting x_return_flag to '
	                 || ''''
	                 || x_return_flag
	                 || ''''
	                 || ' [Meaning: void is allowed by default]'
	                 );

             END IF;
         WHEN OTHERS THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Fatal: External app callout '''
	                 || l_callout_name
	                 || ''', generated exception.'
	                 );

	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);
             END IF;
             FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

             /*
              * Propogate exception to caller.
              */
             RAISE;
     END;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 EXCEPTION

     WHEN OTHERS THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Exception occured when '
	             || 'checking voidability of payment '
	             || p_pmt_id
	             );

	         print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	         print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);
         END IF;
         FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

         x_return_status := FND_API.G_RET_STS_ERROR;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
 END is_void_allowed;

/*--------------------------------------------------------------------
 | NAME:
 |     void_pmts_internal
 |
 | PURPOSE:
 |     Invokes a series of callouts of the calling app to remove
 |     a set of submitted documents payable from the payment processing
 |     cycle.
 |
 |     The calling application can free up the removed documents, and
 |     make them available for submission in future payment request(s).
 |
 | PARAMETERS:
 |     IN
 |       p_pmt_list        - IDs of the payments to be stopped.
 |                           This should be an array of payment ids. All
 |                           the child documents payable of each of the
 |                           specified payments will be removed.
 |
 |       p_pmt_status_list - Current statuses of the payments to
 |                           be stopped. This should be an array of statuses.
 |
 |       p_voided_by       - User id of person who issued the void request.
 |                           This id will be stored as an attribute of the
 |                           payment.
 |
 |       p_void_date       - Date on which the void request was made.
 |
 |       p_void_reason     - Reason why this payment needs to be voided.
 |
 |     OUT
 |       x_return_status   - Result of the API call:
 |                         FND_API.G_RET_STS_SUCCESS indicates that all
 |                           the callouts were invoked successfully.
 |                           In this case the caller must COMMIT
 |                           the status changes.
 |
 |                         FND_API.G_RET_STS_ERROR (or other) indicates
 |                           that at least one event did not complete
 |                           successfully. In this case, the caller must
 |                           issue a ROLLBACK to undo all status changes.
 |
 | RETURNS:
 |
 | NOTES:
 |   Internal API, not for public use.
 |
 |   This API will not do a COMMIT. It is the the callers responsbility
 |   to perform COMMIT / ROLLBACK depending upon the returned status.
 |
 |   The callouts invoked must be handled synchronously by the
 |   calling application. So the COMMIT / ROLLBACK should affect
 |   the changes made to the database by the calling application as
 |   well. This will ensure that IBY and the calling application are
 |   in sync w.r.t. to the specified documents payable.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE void_pmts_internal (
     p_instr_id         IN NUMBER,
     p_voided_by        IN NUMBER,
     p_void_date        IN DATE,
     p_void_reason      IN VARCHAR2,
     x_return_status    OUT NOCOPY VARCHAR2
     )
 IS

 l_module_name   CONSTANT VARCHAR2(200) := G_PKG_NAME || '.void_pmts_internal';

 l_api_version   CONSTANT NUMBER        := 1.0;
 l_msg_count     NUMBER;
 l_msg_data      VARCHAR2(2000);

 l_pmts_list     pmtIDTab;
 l_pmt_date DATE;

 CURSOR c_payments (p_instr_id IN NUMBER)
 IS
 SELECT
     payment_id
 FROM
     IBY_PAYMENTS_ALL
 WHERE
     payment_instruction_id = p_instr_id  AND
     payments_complete_flag = 'Y'
 ;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     FND_MSG_PUB.initialize;

     /* Bug: 8692538
      *
      * Validation to make sure that void date is not prior to payment date
      */
     /* Bug 9850931 - Truncating the payment date before checking it with
     void date as void date is not stored with timestamps. */
     SELECT Max(trunc(payment_date))
     INTO l_pmt_date
     FROM iby_payments_all
     WHERE payment_instruction_id = p_instr_id  AND
     payments_complete_flag = 'Y';

     IF(p_void_date < l_pmt_date) THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
           fnd_message.set_name('IBY', 'IBY_VOID_DATE_BEF_PMT_DATE');
            fnd_message.set_Token('PMT_DATE', l_pmt_date);
            fnd_msg_pub.add;
           RETURN;
     END IF;



     /*
      * Pick up all qualifying payments of the payment instruction.
      */
     OPEN  c_payments(p_instr_id);
     FETCH c_payments BULK COLLECT INTO l_pmts_list;
     CLOSE c_payments;

     /*
      * Return failure if no payments were found.
      */
     IF (l_pmts_list.COUNT = 0) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'No completed payments '
	             || ' were found for payment instruction id '
	             || p_instr_id
	             );

         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     END IF;

     /*
      * Start processing the payments, one-by-one.
      */
     FOR i IN l_pmts_list.FIRST .. l_pmts_list.LAST LOOP

         void_pmt_internal (
             l_api_version,
             FND_API.G_FALSE,
             l_pmts_list(i),
             p_voided_by,
             p_void_date,
             p_void_reason,
             x_return_status,
             l_msg_count,
             l_msg_data
             );

         /*
          * Check if the call to stop the payment succeeded.
          */
         IF (x_return_status IS NULL OR
	     x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

             /*
              * Even if a single call to remove a payment
              * failed, return failure for the entire API request.
              */
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Voiding of completed payment '
	                 || l_pmts_list(i)
	                 || ' failed.'
	                 );

	             print_debuginfo(l_module_name, 'EXIT');

             END IF;
             /*
              * It is the callers responsibility to rollback
              * all the changes.
              */
             RETURN;

         END IF;

     END LOOP;

     /*
      * If we reached here, it means that all payments
      * of the given payment instruction have been
      * voided successfully.
      */
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'All payments of payment '
	         || 'instruction id '
	         || p_instr_id
	         || ' voided successfully.'
	         );

     END IF;
     /*
      * Fix for bug 5017119:
      *
      * After voiding all the payments of an instruction,
      * change the instruction status to TERMINATED
      * so that user cannot take any further action on the
      * payment instruction.
      */
     UPDATE
         iby_pay_instructions_all
     SET
         payment_instruction_status = INS_STATUS_TERMINATED
     WHERE
         payment_instruction_id = p_instr_id
     ;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Status of payment instruction '
	         || p_instr_id
	         || ' set to TERMINATED because all payments have been voided.'
	         );

     END IF;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Returning success response ..');

	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END void_pmts_internal;

/*--------------------------------------------------------------------
 | NAME:
 |     validate_paper_doc_number
 |
 | PURPOSE:
 |     Validates that the given paper document number is valid for the
 |     given payment document (check stock) id.
 |
 | PARAMETERS:
 |     IN
 |       p_api_version   -  Version of the API.
 |
 |       p_init_msg_list - Standard API parameter; default as FND_API.G_FALSE
 |
 |       p_payment_doc_id
 |                       - ID of the payment document (check stock) to use.
 |
 |     IN/OUT
 |       x_paper_doc_num - Paper document number (check number) to use.
 |                         If a value is provided, this value will be validated.
 |                         If no value (i.e., NULL) is provided, then the
 |                         next available paper document number will be
 |                         returned as an output parameter.
 |
 |     OUT
 |       x_return_status - Standard return status. Possible values are:
 |                         FND_API.G_RET_STS_SUCCESS
 |                           The given paper document number is valid
 |                           for the given payment document.
 |
 |                           It is possible that there were warnings.
 |                           Please unwind the FND message stack to
 |                           check if there were any warnings to display
 |                           to the user.
 |
 |                         FND_API.G_RET_STS_ERROR
 |                           The given paper document number is invalid.
 |                           Possible reasons are the paper document number
 |                           has already been used, or the paper document
 |                           number is not in the valid range for the given
 |                           payment document.
 |
 |       x_msg_count     - Standard msg count
 |
 |       x_msg_data      - Standard msg data
 |
 | RETURNS:
 |
 | NOTES:
 |  Public API.
 |
 |   This API will not do a COMMIT/ROLLBACK. There are no database
 |   state changes implemented by this API. It is a read only API.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE validate_paper_doc_number (
     p_api_version         IN NUMBER,
     p_init_msg_list       IN VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_payment_doc_id      IN NUMBER,
     x_paper_doc_num       IN OUT NOCOPY NUMBER,
     x_return_status       OUT NOCOPY VARCHAR2,
     x_msg_count           OUT NOCOPY NUMBER,
     x_msg_data            OUT NOCOPY VARCHAR2,
     show_warn_msgs_flag   IN VARCHAR2 DEFAULT FND_API.G_TRUE
     )
 IS

 l_module_name   CONSTANT VARCHAR2(200) := G_PKG_NAME
                                           || '.validate_paper_doc_number';

 l_api_version   CONSTANT NUMBER        := 1.0;
 l_api_name      CONSTANT VARCHAR2(100) := 'validate_paper_doc_number';

 l_error_code    VARCHAR2(3000);

 l_last_used_check_num   NUMBER := 0;
 l_next_check_number     NUMBER := 0;

 l_first_avail_check_num NUMBER := 0;
 l_last_avail_check_num  NUMBER := 0;
 l_pmt_doc_name          VARCHAR2(200) := '';
 l_used_paper_doc_number NUMBER := 0;

 l_flag                  BOOLEAN;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     /* Standard call to check for API compatibility */
     IF NOT FND_API.Compatible_API_Call(
                        l_api_version,
                        p_api_version,
                        l_api_name,
                        G_PKG_NAME) THEN

         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

     END IF;

     /* Initialize message list if p_init_msg_list is set to TRUE */
     IF FND_API.to_boolean(p_init_msg_list) THEN
         FND_MSG_PUB.initialize;
     END IF;

     /* Initialize return status */
     x_return_status := FND_API.G_RET_STS_SUCCESS;


     /*
      * Pull up the details of the paper stock, like the
      * last used check number and the last available
      * check number.
      */
     BEGIN

         SELECT
             NVL(last_issued_document_number,     0),
             NVL(first_available_document_num,    0),
             NVL(last_available_document_number, -1),
             payment_document_name
         INTO
             l_last_used_check_num,
             l_first_avail_check_num,
             l_last_avail_check_num,
             l_pmt_doc_name
         FROM
             CE_PAYMENT_DOCUMENTS
         WHERE
             payment_document_id = p_payment_doc_id
         ;

     EXCEPTION

         WHEN NO_DATA_FOUND THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'No payment document '
	                 || 'with payment document id '
	                 || p_payment_doc_id
	                 || ' was found in CE_PAYMENT_DOCUMENTS table.'
	                 );

	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);
             END IF;
             FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

             x_return_status := FND_API.G_RET_STS_ERROR;

             l_error_code := 'IBY_INS_NO_PMT_DOC';
             FND_MESSAGE.set_name('IBY', l_error_code);

             FND_MESSAGE.SET_TOKEN('PMT_DOC_ID',
                 p_payment_doc_id,
                 FALSE);

             FND_MSG_PUB.ADD;

             FND_MSG_PUB.COUNT_AND_GET(
                 p_count => x_msg_count,
                 p_data  => x_msg_data
                 );

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Returning error response ..');

	             print_debuginfo(l_module_name, 'EXIT');

             END IF;
             RETURN;


         WHEN OTHERS THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Exception occured when '
	                 || 'attempting to get details of payment document id '
	                 || p_payment_doc_id
	                 );

	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);

             END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;

             l_error_code := 'IBY_PMT_DOC_EXCEPTION';
             FND_MESSAGE.set_name('IBY', l_error_code);

             FND_MESSAGE.SET_TOKEN('PMT_DOC_ID',
                 p_payment_doc_id,
                 FALSE);

             FND_MSG_PUB.ADD;

             FND_MSG_PUB.COUNT_AND_GET(
                 p_count => x_msg_count,
                 p_data  => x_msg_data
                 );

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Returning error response ..');

	             print_debuginfo(l_module_name, 'EXIT');

             END IF;
             RETURN;

     END;

     /*
      * If we reached here, it means that we were able to get
      * the details of the provided payment document.
      */

     /*
      * If a null value is provided for the paper document number,
      * we have to return the next available paper document number
      * and exit.
      */
     IF (x_paper_doc_num IS NULL) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Paper document number '
	             || 'has not been provided. Generating ..'
	             );

         END IF;
         /*
          * Loop through the available paper documents until
          * we get a paper document number that is -
          *
          * 1. Not used
          * 2. Not greater than the last available document number.
          *
          * If both these conditions are not satisfied, return an
          * error response.
          */
         x_paper_doc_num := -1;
         l_error_code    := NULL;

         l_next_check_number := l_last_used_check_num;

         WHILE (x_paper_doc_num < 0 AND l_error_code IS NULL) LOOP

             /*
              * Increment the check number by one and check
              * if it unused. If it is unused, we can return
              * this check number, else we need to increment
              * check number by one more and try again in a
              * loop.
              */
             l_next_check_number := l_next_check_number + 1;

             x_paper_doc_num := l_next_check_number;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Generated paper document '
	                 || 'number is '
	                 || x_paper_doc_num
	                 );

             END IF;
             /*
              * Fix for bug 5005222:
              *
              * If last available paper document number is not
              * specified by the user (-1), assume that there
              * are an infinite number of checks available for
              * numbering [no upper bound].
              */
             /* check that we are not out of paper stock */
             IF (x_paper_doc_num         > l_last_avail_check_num AND
                 l_last_avail_check_num <> -1)                    THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Last available '
	                     || 'paper document number is '
	                     || l_last_avail_check_num
	                     );

	                 print_debuginfo(l_module_name, 'Provided payment document '
	                     || p_payment_doc_id
	                     || ' is exhausted. No more paper documents are '
	                     || 'available for issue.'
	                     );

                 END IF;
                 x_return_status := FND_API.G_RET_STS_SUCCESS;

		 --Bug 8367408 : Paper document number should be reset per AP
		 x_paper_doc_num := NULL;

                 l_error_code := 'IBY_CHECK_STOCK_EXHTD_REENTER';
                 FND_MESSAGE.set_name('IBY', l_error_code);

                 FND_MSG_PUB.ADD;

                 FND_MSG_PUB.COUNT_AND_GET(
                     p_count => x_msg_count,
                     p_data  => x_msg_data
                     );

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Returning error response ..');


                 END IF;
             ELSE

                 /*
                  * Check if this paper document number has already
                  * been used.
                  */
                 l_flag := checkIfDocUsed(x_paper_doc_num, p_payment_doc_id);

                 IF (l_flag = TRUE) THEN

                     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                     print_debuginfo(l_module_name, 'Generated paper document '
	                         || 'number '
	                         || x_paper_doc_num
	                         || ' has been used. Generating next available '
	                         || 'paper doc number ..'
	                         );

                     END IF;
                     /* this will cause the while loop to iterate */
                     x_paper_doc_num := -1;

                 ELSE

                     x_return_status := FND_API.G_RET_STS_SUCCESS;

                     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                     print_debuginfo(l_module_name, 'Generated paper document '
	                         || 'number '
	                         || x_paper_doc_num
	                         || ' is unused.'
	                         );

	                     print_debuginfo(l_module_name, 'Returning success '
	                         || 'response ..');

                     END IF;
                 END IF; -- if l_flag <> true

             END IF; -- if x_paper_doc_num < l_last_avail_check_num

         END LOOP;

         /* exit at this point as we will not be doing any validations */
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     END IF; -- if x_paper_doc_num is null

     /*
      * Start the paper document number validations.
      */

     /*
      * Provided paper document number cannot be below
      * first available paper doc number.
      */
     IF (x_paper_doc_num < l_first_avail_check_num) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Provided paper doc number '
	                 || x_paper_doc_num
	                 || ' is below first available document number '
	                 || l_first_avail_check_num
	                 );

             END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;

             l_error_code := 'IBY_DOC_NUM_BELOW_ALLOWED';
             FND_MESSAGE.set_name('IBY', l_error_code);

             FND_MESSAGE.SET_TOKEN('FIRST_AVAILABLE_DOC_NUM',
                 l_first_avail_check_num,
                 FALSE);

             FND_MSG_PUB.ADD;

             FND_MSG_PUB.COUNT_AND_GET(
                 p_count => x_msg_count,
                 p_data  => x_msg_data
                 );

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Returning error response ..');

	             print_debuginfo(l_module_name, 'EXIT');

             END IF;
             RETURN;

     END IF;

     /*
      * Fix for bug 5005222:
      *
      * If last available paper document number is not
      * specified by the user (-1), assume that there
      * are an infinite number of checks available for
      * numbering [no upper bound].
      */

     /*
      * Provided paper document number cannot be above
      * last available paper doc number.
      */
     IF (x_paper_doc_num         > l_last_avail_check_num AND
         l_last_avail_check_num <> -1)                    THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Last available '
	                 || 'paper document number is '
	                 || l_last_avail_check_num
	                 );

	             print_debuginfo(l_module_name, 'Provided paper doc number '
	                 || x_paper_doc_num
	                 || ' is above last available document number '
	                 || l_last_avail_check_num
	                 );

             END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;

             l_error_code := 'IBY_DOC_NUM_ABOVE_ALLOWED';
             FND_MESSAGE.set_name('IBY', l_error_code);

             FND_MESSAGE.SET_TOKEN('LAST_AVAILABLE_DOC_NUM',
                 l_last_avail_check_num,
                 FALSE);

             FND_MSG_PUB.ADD;

             FND_MSG_PUB.COUNT_AND_GET(
                 p_count => x_msg_count,
                 p_data  => x_msg_data
                 );

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Returning error response ..');

	             print_debuginfo(l_module_name, 'EXIT');

             END IF;
             RETURN;

     END IF;

     /*
      * Provided paper document number should not be below
      * last issued paper doc number (warning).
      */
     IF (x_paper_doc_num < l_last_used_check_num) THEN

         /*
          * This check will only result in a warning message.
          * Ignore this check, if the show warnings flag is
          * set to false.
          *
          * This method can be called multiple times in the
          * single payments flow, this could result in a large
          * number of error messages being put into the message
          * stack and displayed to the user.
          *
          * By setting the show warnings flag to 'false' for
          * the single payments flow, the number of potential
          * messages displayed to the user is reduced.
          */
         IF (show_warn_msgs_flag = FND_API.G_TRUE) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Warning: Provided paper '
	                 || 'doc number '
	                 || x_paper_doc_num
	                 || ' is below last issued document number '
	                 || l_last_used_check_num
	                 );

             END IF;
             l_error_code := 'IBY_DOC_NUM_BELOW_ISSUED';
             FND_MESSAGE.set_name('IBY', l_error_code);

             FND_MSG_PUB.ADD;

             FND_MSG_PUB.COUNT_AND_GET(
                 p_count => x_msg_count,
                 p_data  => x_msg_data
                 );

         END IF;

     END IF;

     /*
      * Check if this paper document number has already
      * been used.
      */
     l_flag := checkIfDocUsed(x_paper_doc_num, p_payment_doc_id);

     IF (l_flag = TRUE) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Provided paper document '
	             || 'number '
	             || x_paper_doc_num
	             || ' has already been used.'
	             );

         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;

         l_error_code := 'IBY_DOC_NUM_USED';
         FND_MESSAGE.set_name('IBY', l_error_code);

         FND_MSG_PUB.ADD;

         FND_MSG_PUB.COUNT_AND_GET(
             p_count => x_msg_count,
             p_data  => x_msg_data
             );

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning error response ..');

	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     ELSE

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Provided paper document '
	             || 'number '
	             || x_paper_doc_num
	             || ' is unused.'
	             );

         END IF;
     END IF; -- if l_flag <> true

     /*
      * If we reached here, it means that both the paper document
      * number and the payment document id are valid.
      */
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Returning success response ..');

     END IF;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END validate_paper_doc_number;



/*--------------------------------------------------------------------
 | NAME:
 |     validate_payment_document
 |
 | PURPOSE:
 |     Validates that the given payment document.
 |
 | PARAMETERS:
 |     IN
 |       p_api_version   -  Version of the API.
 |
 |       p_init_msg_list - Standard API parameter; default as FND_API.G_FALSE
 |
 |       p_payment_doc_id
 |                       - ID of the payment document (check stock) to use.
 |
 |    OUT
 |       x_return_status - Standard return status. Possible values are:
 |                         FND_API.G_RET_STS_SUCCESS
 |                           The given payment document is valid
 |                           and it is not locked by any of Instructions or
 |                           with single payment.
 |
 |
 |
 |                         FND_API.G_RET_STS_ERROR
 |                           The given payment document is already locked.
 |                           Possible reasons are the payement document
 |                           has already locked by any Instruction, or
 |                           for single payment by another user.
 |
 |       x_msg_count     - Standard msg count
 |
 |       x_msg_data      - Standard msg data
 |
 | RETURNS:
 |
 | NOTES:
 |  Public API.
 |
 |   This API will not do a COMMIT/ROLLBACK. There are no database
 |   state changes implemented by this API. It is a read only API.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE validate_payment_document (
     p_api_version         IN NUMBER,
     p_init_msg_list       IN VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_payment_doc_id      IN NUMBER,
     x_return_status       OUT NOCOPY VARCHAR2,
     x_msg_count           OUT NOCOPY NUMBER,
     x_msg_data            OUT NOCOPY VARCHAR2
     )
 IS
 l_module_name   CONSTANT VARCHAR2(200) := G_PKG_NAME
                                           || '.validate_payment_document';

 l_api_version   CONSTANT NUMBER        := 1.0;
 l_api_name      CONSTANT VARCHAR2(100) := 'validate_payment_document';

 l_error_code    VARCHAR2(3000);
 l_pmt_doc_name  VARCHAR2(200) := '';
 l_pmt_doc_name_dup  VARCHAR2(200) := '';
 l_pmt_instr_id  NUMBER(15);
 BEGIN
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo(l_module_name, 'ENTER');
	    print_debuginfo(l_module_name, 'p_payment_doc_id:'||p_payment_doc_id);

    END IF;
     /* Standard call to check for API compatibility */
     IF NOT FND_API.Compatible_API_Call(
                        l_api_version,
                        p_api_version,
                        l_api_name,
                        G_PKG_NAME) THEN

         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

     END IF;

     /* Initialize message list if p_init_msg_list is set to TRUE */
     IF FND_API.to_boolean(p_init_msg_list) THEN
         FND_MSG_PUB.initialize;
     END IF;

     /* Initialize return status */
     x_return_status := FND_API.G_RET_STS_SUCCESS;


      /*
      * Pull up the name of the paper stock
      */
    BEGIN
         SELECT
             payment_document_name,  payment_instruction_id
         INTO
             l_pmt_doc_name, l_pmt_instr_id
         FROM
             CE_PAYMENT_DOCUMENTS
         WHERE
             payment_document_id = p_payment_doc_id;
     EXCEPTION

         WHEN NO_DATA_FOUND THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'No payment document '
	                 || 'with payment document id '
	                 || p_payment_doc_id
	                 || ' was found in CE_PAYMENT_DOCUMENTS table.'
	                 );

	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);
             END IF;
             FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

             x_return_status := FND_API.G_RET_STS_ERROR;

             l_error_code := 'IBY_INS_NO_PMT_DOC';
             FND_MESSAGE.set_name('IBY', l_error_code);

             FND_MESSAGE.SET_TOKEN('PMT_DOC_ID',
                 p_payment_doc_id,
                 FALSE);

             FND_MSG_PUB.ADD;

             FND_MSG_PUB.COUNT_AND_GET(
                 p_count => x_msg_count,
                 p_data  => x_msg_data
                 );

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Returning error response ..');

	             print_debuginfo(l_module_name, 'EXIT');

             END IF;
             RETURN;


         WHEN OTHERS THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Exception occured when '
	                 || 'attempting to get details of payment document id '
	                 || p_payment_doc_id
	                 );

	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);

             END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;

             l_error_code := 'IBY_PMT_DOC_EXCEPTION';
             FND_MESSAGE.set_name('IBY', l_error_code);

             FND_MESSAGE.SET_TOKEN('PMT_DOC_ID',
                 p_payment_doc_id,
                 FALSE);

             FND_MSG_PUB.ADD;

             FND_MSG_PUB.COUNT_AND_GET(
                 p_count => x_msg_count,
                 p_data  => x_msg_data
                 );

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Returning error response ..');

	             print_debuginfo(l_module_name, 'EXIT');

             END IF;
             RETURN;

     END;


  /*
   * If payment document is already locked by any instruction
   * error message would be thrown.
   */

    IF (l_pmt_instr_id <> NULL) THEN
                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Payment document '
	                 || 'with payment document id '
	                 || p_payment_doc_id
	                 || ' with name'
	                 || l_pmt_doc_name
	                 || ' is locked by instruction'
	                 || l_pmt_instr_id
	                 );
                 END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;

             l_error_code := 'IBY_PAY_DOC_ALREADY_USE';
             FND_MESSAGE.set_name('IBY', l_error_code);

             FND_MESSAGE.SET_TOKEN('PAY_INSTRUCTION',
                 l_pmt_instr_id,
                 FALSE);
             FND_MSG_PUB.ADD;

             FND_MSG_PUB.COUNT_AND_GET(
                 p_count => x_msg_count,
                 p_data  => x_msg_data
                 );

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Returning error response ..');

	             print_debuginfo(l_module_name, 'EXIT');

             END IF;
             RETURN;

    END IF;



     /*
      * LOCK THE PAYMENT DOCUMENT
      * If payment document not found, then it means that it is locked
      * by another user for single payment.
      */
    BEGIN
         SELECT
             payment_document_name
         INTO
             l_pmt_doc_name_dup
         FROM
             CE_PAYMENT_DOCUMENTS
         WHERE
             payment_document_id = p_payment_doc_id
         FOR UPDATE SKIP LOCKED;
          EXCEPTION

         WHEN NO_DATA_FOUND THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Payment document '
	                 || 'with payment document id '
	                 || p_payment_doc_id
	                 || 'is locked by another user for single payment.'
	                 );

	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);
             END IF;
             --FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

             x_return_status := FND_API.G_RET_STS_ERROR;

             l_error_code := 'IBY_PMT_DOC_UNAVAILABLE';
             FND_MESSAGE.set_name('IBY', l_error_code);

             FND_MSG_PUB.ADD;

             FND_MSG_PUB.COUNT_AND_GET(
                 p_count => x_msg_count,
                 p_data  => x_msg_data
                 );

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Returning error response ..');

	             print_debuginfo(l_module_name, 'EXIT');

             END IF;
             RETURN;


         WHEN OTHERS THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Exception occured when '
	                 || 'attempting to get details of payment document id '
	                 || p_payment_doc_id
	                 );

	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);

             END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;

             l_error_code := 'IBY_PMT_DOC_EXCEPTION';
             FND_MESSAGE.set_name('IBY', l_error_code);

             FND_MESSAGE.SET_TOKEN('PMT_DOC_ID',
                 p_payment_doc_id,
                 FALSE);

             FND_MSG_PUB.ADD;

             FND_MSG_PUB.COUNT_AND_GET(
                 p_count => x_msg_count,
                 p_data  => x_msg_data
                 );

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Returning error response ..');

	             print_debuginfo(l_module_name, 'EXIT');

             END IF;
             RETURN;

     END;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END validate_payment_document;


/*--------------------------------------------------------------------
 | NAME:
 |     terminate_pmt_instruction
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
 |   Internal API, not for public use.
 |
 | UPDATE ON MAY-04-2006, rameshsh
 | This method was not performing a COMMIT earlier. Due to bug 5206672
 | a COMMIT has been added in the code before invoking unlock_pmt_entity(..).
 *---------------------------------------------------------------------*/
 PROCEDURE terminate_pmt_instruction (
     p_instr_id       IN NUMBER,
     p_instr_status   IN VARCHAR2,
     x_return_status  OUT NOCOPY VARCHAR2
     )
 IS

 l_module_name    CONSTANT VARCHAR2(200) := G_PKG_NAME
                                            || '.terminate_pmt_instruction';

 l_rejection_id   NUMBER(15);

 /* used in forming callout procedure name */
 l_calling_app_id NUMBER;
 l_pkg_name       VARCHAR2(200);
 l_pckg_name      VARCHAR2(200) := 'AP_AWT_CALLOUT_PKG';
 l_callout_name   VARCHAR2(500);
 l_stmt           VARCHAR2(1000);

 /* used in invocation of callout procedure */
 l_api_version    CONSTANT NUMBER := 1.0;
 l_msg_count      NUMBER;
 l_msg_data       VARCHAR2(2000);

 l_appNamesTab    appNamesTab;
 l_appIdsTab      appIdsTab;

 l_pmt_doc_id     NUMBER(15);
 l_pmt_doc_name   VARCHAR2(2000);

 l_flag           BOOLEAN := FALSE;
 l_error_code     VARCHAR2(3000);

 l_ret_status     VARCHAR2(300);

 l_valid_pmts_count NUMBER;

 l_max_paper_document_number NUMBER;
 l_min_paper_document_number NUMBER;
 l_number_of_payments NUMBER;
 l_last_issued NUMBER;
 l_document_locked BOOLEAN := TRUE;
 l_last_issued_modified NUMBER;
 l_irregular_document_numbers EXCEPTION;
 l_request_status VARCHAR2(30);

 /*
  * Cursor to pick up names of all calling applications
  * associated with a particular payment instruction.
  */
 CURSOR c_app_names (p_instr_id NUMBER)
 IS
 SELECT DISTINCT
     fnd.application_short_name
 FROM
     FND_APPLICATION          fnd,
     IBY_PAYMENTS_ALL         pmt,
     IBY_PAY_SERVICE_REQUESTS req,
     IBY_PAY_INSTRUCTIONS_ALL ins
 WHERE
     pmt.payment_instruction_id     = ins.payment_instruction_id     AND
     req.payment_service_request_id = pmt.payment_service_request_id AND
     fnd.application_id             = req.calling_app_id             AND
     ins.payment_instruction_id     = p_instr_id
 ;

 /*
  * Cursor to pick up ids all calling applications
  * associated with a particular payment instruction.
  */
 CURSOR c_app_ids (p_instr_id NUMBER)
 IS
 SELECT
     fnd.application_id
 FROM
     FND_APPLICATION          fnd,
     IBY_PAYMENTS_ALL         pmt,
     IBY_PAY_SERVICE_REQUESTS req,
     IBY_PAY_INSTRUCTIONS_ALL ins
 WHERE
     pmt.payment_instruction_id     = ins.payment_instruction_id     AND
     req.payment_service_request_id = pmt.payment_service_request_id AND
     fnd.application_id             = req.calling_app_id             AND
     ins.payment_instruction_id     = p_instr_id
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

     END IF;
     FND_MSG_PUB.initialize;

     /*
      * STATUS CHANGE:
      *
      * API Responsibility:
      * instruction status = TERMINATED
      * payment_status  = REMOVED_INSTRUCTION_TERMINATED
      * document_status = REMOVED_INSTRUCTION_TERMINATED
      *
      */

     /*
      * STEP 1:
      *
      * If the given payment instruction is locked, it means
      * that some concurrent program is acting upon the
      * pmt instruction at the moment.
      *
      * To prevent data corruption do not allow the payment
      * instruction to be terminated.
      */
     l_flag := checkIfPmtEntityLocked(p_instr_id, 'PAYMENT_INSTRUCTION');

    /* for bug 6196551 */
        SELECT
             count(*)
         INTO
             l_valid_pmts_count
         FROM
             IBY_PAYMENTS_ALL pmt
         WHERE
             pmt.payment_instruction_id = p_instr_id AND
             pmt.payment_status NOT IN
                 (
                  PAY_STATUS_VOID,
                  PAY_STATUS_REMOVED,
		  PAY_STATUS_STOPPED
                 );

    IF (l_valid_pmts_count=0) THEN
    l_flag := FALSE;
    END IF;

    SELECT get_conc_request_status(request_id)
    INTO l_request_status
    FROM iby_pay_instructions_all
    WHERE payment_instruction_id = p_instr_id;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo(l_module_name, 'Request Status::'
	             || l_request_status
	             );

    END IF;
     IF (l_flag = TRUE  AND l_request_status <> 'SUCCESS' AND l_request_status <> 'ERROR') THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Payment instruction '
	             || p_instr_id
	             || ' has been locked by a concurrent program.'
	             || ' It cannot be terminated at present.'
	             );

         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;

         l_error_code := 'IBY_INS_LOCKED';
         FND_MESSAGE.set_name('IBY', l_error_code);
         FND_MSG_PUB.ADD;

         --FND_MSG_PUB.COUNT_AND_GET(
         --    p_count => x_msg_count,
         --    p_data  => x_msg_data
         --    );

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning error response ..');

	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     ELSE

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Payment instruction '
	             || p_instr_id
	             || ' is not locked.'
	             );

         END IF;
     END IF;

     /*
      * STEP 1.1:
      *
      * Before terminating payment instruction, call AP hook for voiding
      * withholding certificates.
      */

     l_callout_name := l_pckg_name || '.' || 'zx_witholdingCertificatesHook';

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Attempting to call hook for voiding '
	         || 'withholding certificates: '
	         || l_callout_name);

     END IF;
     l_stmt := 'CALL '|| l_callout_name || '(:1, :2, :3, :4, :5, :6, :7, :8)';

     BEGIN

         EXECUTE IMMEDIATE
             (l_stmt)
         USING
             IN  p_instr_id,
             IN  'TERMINATE',
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



     /*
      * STEP 2:
      *
      * Update payment instruction, payment and document statuses
      * to 'terminated'.
      */
     UPDATE
         iby_pay_instructions_all
     SET
         payment_instruction_status = INS_STATUS_TERMINATED
     WHERE
         payment_instruction_id = p_instr_id
     ;

     BEGIN

         UPDATE
             IBY_PAYMENTS_ALL
         SET
             payment_status = PAY_STATUS_INS_TERM
         WHERE
             payment_instruction_id = p_instr_id     AND
             (
              payment_status <> PAY_STATUS_REMOVED       AND
              payment_status <> PAY_STATUS_VOID_SETUP    AND
              payment_status <> PAY_STATUS_VOID_OVERFLOW AND
              payment_status <> PAY_STATUS_SPOILED       AND
              payment_status <> PAY_STATUS_STOPPED       AND
              payment_status <> PAY_STATUS_INS_TERM      AND
              payment_status <> PAY_STATUS_REQ_TERM      AND
              payment_status <> PAY_STATUS_VOID          AND
              payment_status <> PAY_STATUS_ACK           AND
              payment_status <> PAY_STATUS_BNK_VALID     AND
              payment_status <> PAY_STATUS_PAID
             )
         ;

     EXCEPTION

         WHEN NO_DATA_FOUND THEN
             /*
              * Handle gracefully the situation where no payments
              * exist for the given request.
              */
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'No payments in valid '
	                 || 'status exist for payment instruction '
	                 || p_instr_id
	                 );

             END IF;
         WHEN OTHERS THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Fatal: Exception occured '
	                 || 'when attempting to update status of payments '
	                 || 'for payment instruction '
	                 || p_instr_id
	                 || '. Aborting program ..'
	                 );
	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);
             END IF;
             FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

             /*
              * Propogate exception to caller.
              */
             RAISE;

     END;

     BEGIN

         UPDATE
             IBY_DOCS_PAYABLE_ALL
         SET
             document_status = DOC_STATUS_INS_TERM,

             /*
              * Fix for bug 4405981:
              *
              * The straight through flag should be set to 'N',
              * if the document was rejected / required manual
              * intervention.
              */
             straight_through_flag = 'N'

         WHERE
             payment_id IN
                 (
                  SELECT
                      payment_id
                  FROM
                      IBY_PAYMENTS_ALL
                  WHERE
                      payment_instruction_id = p_instr_id   AND
                      payment_status = PAY_STATUS_INS_TERM
                 )
                 AND
                 (
                  document_status <> DOC_STATUS_REJECTED    AND
                  document_status <> DOC_STATUS_REMOVED     AND
                  document_status <> DOC_STATUS_PMT_REMOVED AND
                  document_status <> DOC_STATUS_PMT_STOPPED AND
                  document_status <> DOC_STATUS_REQ_TERM    AND
                  document_status <> DOC_STATUS_INS_TERM    AND
                  document_status <> DOC_STATUS_VOID_SETUP  AND
                  document_status <> DOC_STATUS_PMT_VOIDED
                 )
         ;

    EXCEPTION

         WHEN NO_DATA_FOUND THEN
             /*
              * Handle gracefully the situation where no documents
              * exist for the given payment instruciton.
              */
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'No payments exist for payment '
	                 || 'instruction '
	                 || p_instr_id
	                 );
             END IF;
             FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

         WHEN OTHERS THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Fatal: Exception occured '
	                 || 'when attempting to update status of payments '
	                 || 'for payment instruction '
	                 || p_instr_id
	                 || '. Aborting program ..'
	                 );
	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);
             END IF;
             FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

             /*
              * Propogate exception to caller.
              */
             RAISE;

     END;



     /*
      * STEP 3:
      * Restore the Unused Check numbers and
      * Unlock the payment document that has been locked by this payment
      * instruction.
      */
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Restoring the Unused Check numbers '
	         || 'by payment instruction '
	         || p_instr_id
	         );

     END IF;

/*Restoring the Unused Check numbers*/
/*Modified for Bug 7325373*/
     BEGIN
         BEGIN
                SELECT last_issued_document_number INTO l_last_issued
                FROM ce_payment_documents WHERE payment_instruction_id = p_instr_id;
             EXCEPTION
                WHEN No_Data_Found THEN
                  l_document_locked := FALSE;
              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	              print_debuginfo(l_module_name, 'Payment Document is not locked by the instruction '
	             || p_instr_id
	             );
              END IF;
         END;

	 /* If document is locked*/
         IF(l_document_locked = TRUE) THEN

		SELECT Max(paper_document_number), Min(paper_document_number), Count(*)
		INTO l_max_paper_document_number, l_min_paper_document_number, l_number_of_payments
		FROM iby_payments_all WHERE payment_instruction_id = p_instr_id;

                l_last_issued_modified := l_last_issued - l_number_of_payments;

		 IF ((l_last_issued <> l_max_paper_document_number)
		    OR ((l_max_paper_document_number - l_min_paper_document_number) <>  (l_number_of_payments - 1)))
		 THEN
		       RAISE l_irregular_document_numbers;
		 END IF;

		 UPDATE
		     CE_PAYMENT_DOCUMENTS
		 SET
		     last_issued_document_number = l_last_issued_modified
		 WHERE
		     payment_instruction_id = p_instr_id
		 RETURNING
		     payment_document_id,
		     payment_document_name
		 INTO
		     l_pmt_doc_id,
		     l_pmt_doc_name
		 ;

		     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			     print_debuginfo(l_module_name, 'Check number restored for Payment document id '
			     || l_pmt_doc_id
			     || ' with name '
			     || l_pmt_doc_name
			     );


		     END IF;

               /* Updating payments table to clear the paper document numbers Bug 8412987*/
	       /* bug : 8787079 Including 'Void_by_overflow' and 'Void_by_setup' statuses */
		 UPDATE
		     IBY_PAYMENTS_ALL
		 SET
		     paper_document_number = null
		 WHERE
		     payment_instruction_id = p_instr_id     AND
		     payment_status in
		                    (PAY_STATUS_INS_TERM,
				     PAY_STATUS_VOID_SETUP,
                                     PAY_STATUS_VOID_OVERFLOW)
		 ;

		     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			     print_debuginfo(l_module_name, 'nulled out paper document numbers in iby_payments_all');

		     END IF;
        END IF;
     EXCEPTION
        WHEN l_irregular_document_numbers THEN
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	            print_debuginfo(l_module_name, 'Fatal: Exception occured '
	             || 'while restoring the used check numbers.'
	             || p_instr_id
	             );
            END IF;
            RAISE;

        WHEN OTHERS THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Non-Fatal: Exception occured '
	             || 'while restoring the used check numbers. '
	             || p_instr_id
	             );

             END IF;
     END;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Unlocking payment document locked '
	         || 'by payment instruction '
	         || p_instr_id
	         );
     END IF;

/* Unlocking the payment document*/
     BEGIN

         UPDATE
             CE_PAYMENT_DOCUMENTS
         SET
             payment_instruction_id = NULL
         WHERE
             payment_instruction_id = p_instr_id
         RETURNING
             payment_document_id,
             payment_document_name
         INTO
             l_pmt_doc_id,
             l_pmt_doc_name
         ;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Payment document id '
	             || l_pmt_doc_id
	             || ' with name '
	             || l_pmt_doc_name
	             || ' unlocked successfully.'
	             );

         END IF;
     EXCEPTION
         WHEN OTHERS THEN

         /*
          * This is a no-fatal exception. We will log the exception
          * and return.
          */
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Non-Fatal: Exception occured '
	             || 'when unlocking pmt document locked by pmt instruction '
	             || p_instr_id
	             );

	         print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	         print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);
         END IF;
         FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

     END;

     /*
      * STEP 4:
      *
      * Invoke callouts to inform calling applications about the
      * terminated documents payable.
      */

     /*
      * Pick up the names of all the applications which have
      * payments in the current payment instruction.
      *
      * Remember, one payment instruction can contain payments
      * across multiple calling applications.
      */
     OPEN  c_app_names (p_instr_id);
     FETCH c_app_names BULK COLLECT INTO l_appNamesTab;
     CLOSE c_app_names;

     /*
      * Pick up the ids of all the applications which have
      * payments in the current payment instruction.
      *
      * Remember, one payment instruction can contain payments
      * across multiple calling applications.
      */
     OPEN  c_app_ids (p_instr_id);
     FETCH c_app_ids BULK COLLECT INTO l_appIdsTab;
     CLOSE c_app_ids;

     /*
      * This should normally never happen.
      */
     IF (l_appIdsTab.COUNT = 0) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'No calling application ids '
	             || 'were fetched for payment instruction '
	             || p_instr_id
	             || ' Possible data corruption. Raising exception ..'
	             );

         END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;

     END IF;

     /*
      * Loop through all the application names, invoking the
      * callout of each application.
      */
     FOR i IN l_appNamesTab.FIRST .. l_appNamesTab.LAST LOOP

         /*
          * Get the constructed package name to use in the
          * call out.
          */
         l_pkg_name := construct_callout_pkg_name(l_appNamesTab(i));

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Constructed package name: '
	             || l_pkg_name);

         END IF;
         IF (l_pkg_name IS NULL) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Package name is null. '
	                 || 'Raising exception.');

             END IF;
             APP_EXCEPTION.RAISE_EXCEPTION;

         END IF;

         /*
          * Get the next available rejected document group id.
          */
         SELECT
             IBY_REJECTED_DOCS_GROUP_S.NEXTVAL
         INTO
             l_rejection_id
         FROM
             DUAL
         ;

         /*
          * Update the terminated documents for this calling app
          * with the rejected document group id. The calling
          * application will identify rejected documents using
          * this id.
          */
         UPDATE
             IBY_DOCS_PAYABLE_ALL
         SET
             rejected_docs_group_id = l_rejection_id
         WHERE
             document_status  = DOC_STATUS_INS_TERM AND
             calling_app_id   = l_appIdsTab(i)      AND
             payment_id IN
                 (SELECT
                      payment_id
                  FROM
                      IBY_PAYMENTS_ALL
                  WHERE
                      payment_instruction_id = p_instr_id    AND
                      payment_status = PAY_STATUS_INS_TERM
                  )
         ;

         /*
          * Now try to call the external app's implementation of the hook.
          * The calling app may or may not have implemented the hook, so
          * it's not fatal if the implementation does not exist.
          */
         l_callout_name := l_pkg_name || '.' || 'documents_payable_rejected';

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Attempting to invoke callout: '
	             || l_callout_name);

         END IF;
         l_stmt := 'CALL '|| l_callout_name || '(:1, :2, :3, :4, :5, :6, :7)';

         BEGIN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Parameter passed to callout - '
	                 || 'l_rejection_id: '
	                 || l_rejection_id
	                 );

             END IF;
             EXECUTE IMMEDIATE
                 (l_stmt)
             USING
                 IN  l_api_version,
                 IN  FND_API.G_FALSE,
                 IN  FND_API.G_FALSE,
                 OUT x_return_status,
                 OUT l_msg_count,
                 OUT l_msg_data,
                 IN  l_rejection_id
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
	                     || '. Raising exception.'
	                     );

                 END IF;
                 APP_EXCEPTION.RAISE_EXCEPTION;

             END IF;

         EXCEPTION

             WHEN PROCEDURE_NOT_IMPLEMENTED THEN
                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Callout "' || l_callout_name
	                     || '" not implemented by calling app '
	                     || l_appNamesTab(i) || '.');

	                 print_debuginfo(l_module_name, 'Skipping hook call.');


                 END IF;
             WHEN OTHERS THEN
                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Fatal: External app callout '''
	                     || l_callout_name
	                     || ''', generated exception.'
	                     );

	                 print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	                 print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);
                 END IF;
                 FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

                 /*
                  * Propogate exception to caller.
                  */
                 RAISE;

         END;

     END LOOP;

     /*
      * STEP 5:
      *
      * Clean up the pmt instruction by unstamping it. In case the
      * concurrent request that was handling this pmt instruction
      * had aborted with an exception, this step will clean up the data.
      */

     /*
      * Fix for bug 5206672:
      *
      * If we reached here, then the payment instruction has
      * been updated to TERMINATED status and the calling app
      * has been informed.
      *
      * Perform a COMMIT here before calling unlock_pmt_entity(..)
      * otherwise a deadlock ensues.
      */
     COMMIT;

     unlock_pmt_entity(
         p_instr_id,
         'PAYMENT_INSTRUCTION',
         l_ret_status
         );

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 EXCEPTION

     WHEN OTHERS THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Exception occured when '
	             || 'terminating payment instruction '
	             || p_instr_id
	             || ', with status '
	             || p_instr_status
	             );

	         print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	         print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);
         END IF;
         FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

         x_return_status := FND_API.G_RET_STS_ERROR;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
 END terminate_pmt_instruction;

/*--------------------------------------------------------------------
 | NAME:
 |     terminate_pmt_request
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
 |   Internal API, not for public use.
 |
 | UPDATE ON MAY-05-2006, rameshsh
 | This method was not performing a COMMIT earlier. Due to bug 5206672
 | a COMMIT has been added in the code before invoking unlock_pmt_entity(..).
 |
 *---------------------------------------------------------------------*/
 PROCEDURE terminate_pmt_request (
     p_req_id         IN NUMBER,
     p_req_status     IN VARCHAR2,
     x_return_status  OUT NOCOPY VARCHAR2
     )
 IS

 l_module_name    CONSTANT VARCHAR2(200) := G_PKG_NAME
                                            || '.terminate_pmt_request';
 l_straight_thr_proc VARCHAR2(1);

 l_rejection_id   NUMBER(15);

 /* used in forming callout procedure name */
 l_calling_app_id NUMBER;
 l_app_short_name VARCHAR2(200);
 l_pkg_name       VARCHAR2(200);
 l_callout_name   VARCHAR2(500);
 l_stmt           VARCHAR2(1000);

 /* used in invocation of callout procedure */
 l_api_version    CONSTANT NUMBER := 1.0;
 l_msg_count      NUMBER;
 l_msg_data       VARCHAR2(2000);

 l_flag           BOOLEAN := FALSE;

 l_error_code     VARCHAR2(3000);
 l_ret_status     VARCHAR2(300);
 l_allowed VARCHAR2(20):= 'YES';

CURSOR pmt_instructions(l_ppr_id number)
is
select instr.payment_instruction_id, instr.payment_instruction_status
from iby_pay_instructions_all instr
where exists (select 'Payment' from iby_payments_all pmt
where pmt.payment_service_request_id = l_ppr_id
and pmt.payment_instruction_id = instr.payment_instruction_id);



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

	     print_debuginfo(l_module_name, 'Parameters passed - '
	         || 'payment request id: '
	         || p_req_id
	         || ', payment request status: '
	         || p_req_status
	         );

     END IF;
     FND_MSG_PUB.initialize;

     /*
      * STATUS CHANGE:
      *
      * API Responsibility:
      * request status  = TERMINATED
      * payment_status  = REMOVED_REQUEST_TERMINATED
      * document_status = REMOVED_REQUEST_TERMINATED
      *
      */

     /*
      * STEP 1:
      *
      * If the given payment request is locked, it means
      * that some concurrent program is acting upon the
      * ppr at the moment.
      *
      * To prevent data corruption do not allow the payment
      * request to be terminated.
      */
     l_flag := checkIfPmtEntityLocked(p_req_id, 'PAYMENT_REQUEST');

     IF (l_flag = TRUE) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Payment request '
	             || p_req_id
	             || ' has been locked by a concurrent program.'
	             || ' It cannot be terminated at present.'
	             );

         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;

         l_error_code := 'IBY_PPR_LOCKED';
         FND_MESSAGE.set_name('IBY', l_error_code);
         FND_MSG_PUB.ADD;

         --FND_MSG_PUB.COUNT_AND_GET(
         --    p_count => x_msg_count,
         --    p_data  => x_msg_data
         --    );

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning error response ..');

	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     ELSE

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Payment request '
	             || p_req_id
	             || ' is not locked.'
	             );

         END IF;
     END IF;

     /*
      * Fix for bug  5112559:
      *
      * Before performing any action, first check if any of
      * the payments of this ppr are part of a payment instruction,
      * if so, do not allow the ppr to be terminated.
      *
      *
      * Fix for Bug 9277808:
      *
      */
     l_flag := checkIfPmtInInstExists(p_req_id);

     IF (l_flag = TRUE) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'The payment request '
	             || p_req_id
	             || ' contains at least one payment that is '
	             || 'part of a payment instruction. Payment '
	             || 'request cannot be terminated at this stage.'
	             );

         END IF;

         SELECT CREATE_PMT_INSTRUCTIONS_FLAG INTO l_straight_thr_proc
	 FROM IBY_PAY_SERVICE_REQUESTS
	 WHERE PAYMENT_SERVICE_REQUEST_ID = p_req_id;

         /* If instructions are not created for this batch alone,
	  * this ppr cannot be terminated.
	  * User has to proceed with the termination of individual
	  * instructions
	  */
	 IF l_straight_thr_proc <> 'Y' THEN
		 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			 print_debuginfo(l_module_name, 'Instructions may contain payments related'||
			                                ' to other PPRs');
			 print_debuginfo(l_module_name, 'Returning error message..');

		 END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
         l_error_code := 'IBY_PPR_TERM_NOT_ALLOWED';
         FND_MESSAGE.set_name('IBY', l_error_code);
         FND_MSG_PUB.ADD;

	 ELSE
	        /* Sanity Check to confirm if all the instructions
		 * could be terminated
		 */
		FOR pmt_instr in pmt_instructions(p_req_id) loop
                        l_allowed := IBY_FD_USER_API_PUB.Pmt_Instr_Terminate_Allowed(
		                           pmt_instr.payment_instruction_id);
			IF(l_allowed = 'NO') THEN
				 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
					 print_debuginfo(l_module_name, 'Payment instruction '||
									pmt_instr.payment_instruction_id||
									' can not be terminated');
					 print_debuginfo(l_module_name, 'Returning error message..');

				 END IF;
			         x_return_status := FND_API.G_RET_STS_ERROR;
				 l_error_code := 'IBY_PPR_TERM_NOT_ALLOWED';
				 FND_MESSAGE.set_name('IBY', l_error_code);
				 FND_MSG_PUB.ADD;
				 return;
			END IF;
		end loop;


	        /* Terminating each Payment instruction created for this PPR
		 */
                FOR pmt_instr in pmt_instructions(p_req_id) loop
                       terminate_pmt_instruction(pmt_instr.payment_instruction_id,
		                                 pmt_instr.payment_instruction_status,
						 x_return_status);
                       IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
				 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
					 print_debuginfo(l_module_name, 'Exception while terminating Payment instruction '||
									pmt_instr.payment_instruction_id);
					 print_debuginfo(l_module_name, 'Returning error message..');

				 END IF;
		            x_return_status := FND_API.G_RET_STS_ERROR;
			    return;
		       END IF;
		end loop;

	 END IF;

       COMMIT;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;


     RETURN;

     END IF;

     /*
      * STEP 2:
      *
      * Set the request status to TERMINATED.
      */
     UPDATE
         iby_pay_service_requests
     SET
         payment_service_request_status = REQ_STATUS_TERMINATED
     WHERE
         payment_service_request_id = p_req_id
     ;


     BEGIN

         UPDATE
             IBY_PAYMENTS_ALL
         SET
             payment_status = PAY_STATUS_REQ_TERM
         WHERE
             payment_service_request_id = p_req_id       AND
             (
              payment_status <> PAY_STATUS_REMOVED       AND
              payment_status <> PAY_STATUS_VOID_SETUP    AND
              payment_status <> PAY_STATUS_VOID_OVERFLOW AND
              payment_status <> PAY_STATUS_SPOILED       AND
              payment_status <> PAY_STATUS_STOPPED       AND
              payment_status <> PAY_STATUS_INS_TERM      AND
              payment_status <> PAY_STATUS_REQ_TERM      AND
              payment_status <> PAY_STATUS_VOID          AND
              payment_status <> PAY_STATUS_ACK           AND
              payment_status <> PAY_STATUS_BNK_VALID     AND
              payment_status <> PAY_STATUS_PAID
             )
         ;

     EXCEPTION

         WHEN NO_DATA_FOUND THEN
             /*
              * Handle gracefully the situation where no payments
              * exist for the given request.
              */
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'No payments exist for payment '
	                 || 'request '
	                 || p_req_id
	                 );


             END IF;
         WHEN OTHERS THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Fatal: Exception occured '
	                 || 'when attempting to update status of payments '
	                 || 'for payment request '
	                 || p_req_id
	                 || '. Aborting program ..'
	                 );
	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);
             END IF;
             FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

             /*
              * Propogate exception to caller.
              */
             RAISE;

     END;

     /*
      * STEP 3:
      *
      * Set status of documents to TERMINATED.
      */
     BEGIN

         UPDATE
             IBY_DOCS_PAYABLE_ALL
         SET
             document_status = DOC_STATUS_REQ_TERM,

             /*
              * Fix for bug 4405981:
              *
              * The straight through flag should be set to 'N',
              * if the document was rejected / required manual
              * intervention.
              */
             straight_through_flag = 'N'
         WHERE
             payment_service_request_id = p_req_id   AND
             (
              document_status <> DOC_STATUS_REJECTED    AND
              document_status <> DOC_STATUS_REMOVED     AND
              document_status <> DOC_STATUS_PMT_REMOVED AND
              document_status <> DOC_STATUS_PMT_STOPPED AND
              document_status <> DOC_STATUS_REQ_TERM    AND
              document_status <> DOC_STATUS_INS_TERM    AND
              document_status <> DOC_STATUS_VOID_SETUP  AND
              document_status <> DOC_STATUS_PMT_VOIDED
             )
         ;

     EXCEPTION

         WHEN NO_DATA_FOUND THEN

             /*
              * Handle gracefully the situation where no documents payable
              * exist for the given request.
              */
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'No docs payable exist for payment '
	                 || 'request '
	                 || p_req_id
	                 || '. Exiting ..'
	                 );

             END IF;
             /*
              * If no documents payable exist for the given request,
              * it is not worth proceeding further.
              *
              * Return success status to the caller.
              */
             x_return_status := FND_API.G_RET_STS_SUCCESS;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'EXIT');
             END IF;
             RETURN;

         WHEN OTHERS THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Fatal: Exception occured '
	                 || 'when attempting to update status of documents '
	                 || 'payable for payment request '
	                 || p_req_id
	                 || '. Aborting program ..'
	                 );
	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);
             END IF;
             FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

             /*
              * Propogate exception to caller.
              */
             RAISE;

     END;

     /*
      * STEP 4:
      *
      * Inform calling application about rejected documents.
      */

     /*
      * Get the next available rejected document group id.
      */
     SELECT
         IBY_REJECTED_DOCS_GROUP_S.NEXTVAL
     INTO
         l_rejection_id
     FROM
         DUAL
     ;

     /*
      * Update the terminated documents with the rejected document
      * group id. The calling application will identify rejected
      * documents using this id.
      */
     UPDATE
         IBY_DOCS_PAYABLE_ALL
     SET
         rejected_docs_group_id = l_rejection_id
     WHERE
         document_status            = DOC_STATUS_REQ_TERM AND
         payment_service_request_id = p_req_id
     ;

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
         req.payment_service_request_id = p_req_id
     ;

     /*
      * Get the constructed package name to use in the
      * call out.
      */
     l_pkg_name := construct_callout_pkg_name(l_app_short_name);

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Constructed package name: '
	         || l_pkg_name);

     END IF;
     IF (l_pkg_name IS NULL) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Package name is null. '
	             || 'Raising exception.');

         END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;

     END IF;

     /*
      * Now try to call the external app's implementation of the hook.
      * The calling app may or may not have implemented the hook, so
      * it's not fatal if the implementation does not exist.
      */
     l_callout_name := l_pkg_name || '.' || 'documents_payable_rejected';

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Attempting to invoke callout: '
	         || l_callout_name);

	     print_debuginfo(l_module_name, 'Parameter(s) passed to callout - '
	         || 'rejection id: '
	         || l_rejection_id
	         );

     END IF;
     l_stmt := 'CALL '|| l_callout_name || '(:1, :2, :3, :4, :5, :6, :7)';

     BEGIN

         EXECUTE IMMEDIATE
             (l_stmt)
         USING
             IN  l_api_version,
             IN  FND_API.G_FALSE,
             IN  FND_API.G_FALSE,
             OUT x_return_status,
             OUT l_msg_count,
             OUT l_msg_data,
             IN  l_rejection_id
         ;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Parameter(s) returned by callout - '
	         || 'x_return_status: '
	         || x_return_status
	         );

         END IF;
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
	                 || '. Raising exception.'
	                 );

             END IF;
             APP_EXCEPTION.RAISE_EXCEPTION;

         END IF;

     EXCEPTION

         WHEN PROCEDURE_NOT_IMPLEMENTED THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Callout "' || l_callout_name
	                 || '" not implemented by calling app '
	                 || l_app_short_name || '.');

	             print_debuginfo(l_module_name, 'Skipping hook call.');


             END IF;
         WHEN OTHERS THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Fatal: External app callout '''
	                 || l_callout_name
	                 || ''', generated exception.'
	                 );

	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);
             END IF;
             FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

             /*
              * Propogate exception to caller.
              */
             RAISE;
     END;

     /*
      * STEP 5:
      *
      * Clean up the ppr by unstamping it. In case the
      * concurrent request that was handling this ppr
      * had aborted with an exception, this step will
      * clean up the data.
      */

     /*
      * Fix for bug 5206672:
      *
      * If we reached here, then the payment request has
      * been updated to TERMINATED status and the calling app
      * has been informed.
      *
      * Perform a COMMIT here before calling unlock_pmt_entity(..)
      * otherwise a deadlock ensues.
      */
     COMMIT;

     unlock_pmt_entity(
         p_req_id,
         'PAYMENT_REQUEST',
         l_ret_status
         );

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 EXCEPTION

     WHEN OTHERS THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Exception occured when '
	             || 'terminating payment request '
	             || p_req_id
	             || ', with status '
	             || p_req_status
	             );

	         print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	         print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);
         END IF;
         FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

         x_return_status := FND_API.G_RET_STS_ERROR;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
 END terminate_pmt_request;

/*--------------------------------------------------------------------
 | NAME:
 |     resubmit_pmt_request
 |
 |
 | PURPOSE:
 |
 |
 | PARAMETERS:
 |     IN
 |     p_payreq_id     The id of the payment request that needs to be
 |                     re-processed by the Build Program.
 |     OUT
 |     x_conc_req_id   The id of the concurrent request that was launched
 |                     by this API. The user will have to check this
 |                     concurrent request status via SRS UI to know the
 |                     result of the concurrent request. This concurrent
 |                     request will invoke the Build Program for this
 |                     payment request.
 |     x_error_buf     message buffer that stores the cause of the error.
 |     x_return_status '-1' will be returned in the case of an error
 |                     '0' will be returned if the request completed
 |                     successfully.
 |
 | RETURNS:
 |
 | NOTES:
 |     This method will perform a COMMIT after each functional
 |     flow is complete. The caller should have finished all database
 |     operations before making a call this method. The caller should
 |     not call commit after invoking this method.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE resubmit_pmt_request (
     p_payreq_id     IN NUMBER,
     x_conc_req_id   IN OUT NOCOPY NUMBER,
     x_error_buf     IN OUT NOCOPY VARCHAR2,
     x_return_status IN OUT NOCOPY NUMBER
     )
 IS

 l_module_name   CONSTANT VARCHAR2(200) := G_PKG_NAME
                                           || '.resubmit_pmt_request';

 l_req_attribs   IBY_PAY_SERVICE_REQUESTS%ROWTYPE;
 l_ret_status    VARCHAR2(200);

    l_icx_numeric_characters   VARCHAR2(30); -- Bug 6411356
    l_bool_val   boolean;  -- Bug 6411356

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     FND_MSG_PUB.initialize;

     /*
      * STATUS CHANGE:
      *
      * UI Responsibility:
      * request status = RETRY_DOCUMENT_VALIDATION    |
      *                  RETRY_PAYMENT_CREATION
      * payment_status = MODIFIED                     |
      *                  MODIFIED_PAYEE_BANK_ACCOUNT
      *
      * API Responsibility:
      * NONE
      */

     /*
      * Pick up the attributes of this request; these are
      * params like rejection level settings, review
      * payments setting etc.
      */
     SELECT
         payment_service_request_id,
         calling_app_id,
         call_app_pay_service_req_code,
         payment_service_request_status,
         process_type,
         allow_zero_payments_flag,
         created_by,
         creation_date,
         last_updated_by,
         last_update_date,
         object_version_number,
         last_update_login,
         internal_bank_account_id,
         payment_profile_id,
         maximum_payment_amount,
         minimum_payment_amount,
         document_rejection_level_code,
         payment_rejection_level_code,
         require_prop_pmts_review_flag,
         org_type,
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
         create_pmt_instructions_flag,
         payment_document_id,
         request_id
     INTO
         l_req_attribs
     FROM
         IBY_PAY_SERVICE_REQUESTS
     WHERE
         PAYMENT_SERVICE_REQUEST_ID = p_payreq_id
     ;

     /*
      * Now resubmit the payment request by invoking
      * the Build Program functional flows again for
      * this request.
      *
      * This method will begin processing the payment
      * request from the last processed point. Therefore,
      * we need not bother about the last processed point
      * here.
      *
      * This will launch a concurrent request for processing
      * the payment request. We will return the concurrent
      * request id back to the user.
      */


    --Bug 6411356
    --below code added to set the current nls character setting
    --before submitting a child requests.
    fnd_profile.get('ICX_NUMERIC_CHARACTERS',l_icx_numeric_characters);
    l_bool_val:= FND_REQUEST.SET_OPTIONS( numeric_characters => l_icx_numeric_characters);

     x_conc_req_id := FND_REQUEST.SUBMIT_REQUEST(
                     'IBY',
                     'IBYBUILD',
                     '',
                     '',
                     FALSE,
                     ''||l_req_attribs.calling_app_id||'',
                     ''||l_req_attribs.call_app_pay_service_req_code||'',
                     ''||l_req_attribs.internal_bank_account_id||'',
                     ''||l_req_attribs.payment_profile_id||'',
                     ''||l_req_attribs.allow_zero_payments_flag||'',
                     ''||l_req_attribs.maximum_payment_amount||'',
                     ''||l_req_attribs.minimum_payment_amount||'',
                     ''||l_req_attribs.document_rejection_level_code||'',
                     ''||l_req_attribs.payment_rejection_level_code||'',
                     ''||l_req_attribs.require_prop_pmts_review_flag||'',
                     'N',
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

     IF (x_conc_req_id = 0) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Concurrent program request failed.');
         END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;

     ELSE

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'The concurrent request was '
	             || 'launched successfully. '
	             || 'Check concurrent request id :'
	             || to_char(x_conc_req_id)
	             );

         END IF;
         /*
          * Lock the payment request so that the user is not
          * allowed to take any action upon this payment
          * request until the concurrent request just launched
          * has completed.
          */
         lock_pmt_entity(
             p_payreq_id,
             'PAYMENT_REQUEST',
             x_conc_req_id,
             l_ret_status
             );

         /*
          * If we are unable to lock the payment request, abort.
          */
         IF (l_ret_status <> FND_API.G_RET_STS_SUCCESS) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Unable to lock payment '
	                 || 'process request: '
	                 || p_payreq_id
	                 || '.'
	                 );

             END IF;
             APP_EXCEPTION.RAISE_EXCEPTION;

         END IF;

     END IF;

     x_return_status := 0;
     x_error_buf := 'BUILD PROGRAM INVOKED - RESUBMITTING PAYMENT'
         || ' REQUEST SUCCEEDED';
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 EXCEPTION

   WHEN OTHERS THEN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Exception occured when resubmitting '
	         || 'payment request id '
	         || p_payreq_id
	         );
	     print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	     print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);
     END IF;
     FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

     x_error_buf := 'BUILD PROGRAM ERROR - RESUBMITTING PAYMENT'
         || ' REQUEST FAILED';

     x_return_status := -1;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END resubmit_pmt_request;

/*--------------------------------------------------------------------
 | NAME:
 |     resubmit_instruction
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
 |   Internal API, not for public use.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE resubmit_instruction (
     p_ins_id        IN NUMBER,
     x_conc_req_id   IN OUT NOCOPY NUMBER,
     x_error_buf     IN OUT NOCOPY VARCHAR2,
     x_return_status IN OUT NOCOPY NUMBER
     )
 IS

 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME || '.resubmit_instruction';
 l_str_ret_status       VARCHAR2(200);
 l_icx_numeric_characters   VARCHAR2(30); -- Bug 6411356
 l_bool_val   boolean;  -- Bug 6411356

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     FND_MSG_PUB.initialize;

     /*
      * STATUS CHANGE:
      *
      * UI Responsibility:
      * instruction status = RETRY_CREATION
      *
      * API Responsibility:
      * NONE
      */

     /*
      * This will launch a concurrent request for processing
      * the payment instruction. We will return the concurrent
      * request id back to the user.
      */


    --Bug 6411356
    --below code added to set the current nls character setting
    --before submitting a child requests.
    fnd_profile.get('ICX_NUMERIC_CHARACTERS',l_icx_numeric_characters);
    l_bool_val:= FND_REQUEST.SET_OPTIONS( numeric_characters => l_icx_numeric_characters);


     x_conc_req_id := FND_REQUEST.SUBMIT_REQUEST(
                     'IBY',
                     'IBYREPICP',
                     '',
                     '',
                     FALSE,
                     ''||p_ins_id||'',
                     '', '', '', '', '', '', '', '', '', '',
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

     IF (x_conc_req_id = 0) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Concurrent program request failed.');
         END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;

     ELSE

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'The concurrent request was '
	             || 'launched successfully. '
	             || 'Check concurrent request id :'
	             || to_char(x_conc_req_id)
	             );

         END IF;
         /*
          * Lock the payment instruction so that the user is not
          * allowed to take any action upon this payment
          * instruction until the concurrent request just launched
          * has completed.
          */

         /*
          * Fix for bug 5206725:
          *
          * Pass a VARCHAR data type for the return status
          * instead of a NUMBER data type.
          */
         lock_pmt_entity(
             p_ins_id,
             'PAYMENT_INSTRUCTION',
             x_conc_req_id,
             l_str_ret_status
             );

         IF (l_str_ret_status <> FND_API.G_RET_STS_SUCCESS) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Unable to lock payment '
	                 || 'instruction: '
	                 || p_ins_id
	                 || '.'
	                 );

             END IF;
             APP_EXCEPTION.RAISE_EXCEPTION;

         END IF;

     END IF;

     x_return_status := 0;
     x_error_buf := 'PICP INVOKED - RESUBMITTING PAYMENT'
         || ' INSTRUCTION SUCCEEDED';

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 EXCEPTION

   WHEN OTHERS THEN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Exception occured when resubmitting '
	         || 'payment instruction '
	         || p_ins_id
	         );
	     print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	     print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);
     END IF;
     FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

     x_error_buf := 'PICP ERROR - RESUBMITTING PAYMENT'
         || ' INSTRUCTION FAILED';

     x_return_status := -1;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END resubmit_instruction;

/*--------------------------------------------------------------------
 | NAME:
 |     reprint_prenum_pmt_documents
 |
 |
 | PURPOSE:
 |     This API should be called if it is required to re-print some of the
 |     paper documents of a payment instruction. This API should only
 |     be called with the list of paper documents that were spoilt (not
 |     with the list of paper documents that were skipped, issued etc.).
 |
 |     The list of used paper documents numbers will be used to insert
 |     records into the IBY_USED_PAYMENT_DOCS table.
 |
 |     The list of new paper document numbers will be used to update the
 |     IBY_PAYMENTS_ALL table with the new paper document numbers for
 |     the corresponding paments. The payment status will then be set to
 |     READY_FOR_REPRINT.
 |
 |     Finally, this API will invoke the paper printing flow.
 |
 |     This method should only be invoked for reprinting payment documents
 |     that are prenumbered (paper stock type is 'prenumbered'). For
 |     reprinting payment documents that are on blank stock use the method
 |     reprint_blank_pmt_documents().
 |
 | PARAMETERS:
 |     IN
 |       p_instr_id      - ID of the payment instruction, for which some
 |                         payments need to be re-printed.
 |       p_pmt_doc_id    - The payment document id (check stock) which
 |                         is to be used for re-printing.
 |       p_pmt_list      - List of payments that are affected by the
 |                         re-print. These payments will be updated with
 |                         new paper document numbers (provided by the user).
 |       p_new_ppr_docs_list
 |                       - List of new paper document numbers to print
 |                         the provided payments on.
 |       p_old_ppr_docs_list
 |                       - List of previously used paper document numbers.
 |                         These will be inserted into IBY_USED_PAYMENT_DOCS
 |                         table indicating that they were spoiled.
 |       p_printer_name  - Printer to use for re-printing payments.
 |
 |
 |     OUT
 |       x_return_status - Result of the API call:
 |                         FND_API.G_RET_STS_SUCCESS indicates that the
 |                           reprint process was triggered successfully.
 |                           In this case the caller must COMMIT
 |                           the status change.
 |
 |                         FND_API.G_RET_STS_ERROR (or other) indicates
 |                           that API did not complete successfully.
 |                           In this case, the caller must issue a
 |                           ROLLBACK to undo all status changes.
 |
 | RETURNS:
 |
 | NOTES:
 |   Internal API, not for public use.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE reprint_prenum_pmt_documents(
     p_instr_id          IN NUMBER,
     p_pmt_doc_id        IN NUMBER,
     p_pmt_list          IN pmtIDTab,
     p_new_ppr_docs_list IN pmtDocsTab,
     p_old_ppr_docs_list IN pmtDocsTab,
     p_printer_name      IN VARCHAR2,
     x_return_status     OUT NOCOPY VARCHAR2
     )
 IS

 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME
                                         || '.reprint_prenum_pmt_documents';

 l_pkg_name    CONSTANT VARCHAR2(100) := 'AP_AWT_CALLOUT_PKG';

 l_callout_name     VARCHAR2(500);
 l_stmt             VARCHAR2(1000);

 /* used in invocation of callout procedure */
 l_api_version      CONSTANT NUMBER := 1.0;
 l_msg_count        NUMBER;
 l_msg_data         VARCHAR2(2000);

 l_curr_pmt_status  VARCHAR2(200);
 l_temp_status      VARCHAR2(200);

 l_last_list_num    NUMBER;
 l_last_doc_num     NUMBER;

 /*
  * Implementing the hook is optional for the calling app.
  * If the calling app does not implement the hook, then
  * the call to the hook will result in ORA-06576 error.
  *
  * There is no exception name associated with this code, so
  * we create one called 'PROCEDURE_NOT_IMPLEMENTED'. If this
  * exception occurs, it is not fatal: we log the error and
  * proceed.
  *
  * If, on the other hand, the calling app implements the
  * hook, but the hook throws an exception, it is fatal
  * and we must abort the program (this will be caught
  * in WHEN OTHERS block).
  */
 PROCEDURE_NOT_IMPLEMENTED EXCEPTION;
 PRAGMA EXCEPTION_INIT(PROCEDURE_NOT_IMPLEMENTED, -6576);

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     FND_MSG_PUB.initialize;

     /*
      * STATUS CHANGE:
      *
      * UI Responsibility:
      * NONE
      *
      * API Responsibility:
      * paper document use reason = SPOILED
      * payment status = READY_TO_REPRINT
      */

     IF (p_pmt_list.COUNT          = 0  OR
         p_new_ppr_docs_list.COUNT = 0  OR
         p_old_ppr_docs_list.COUNT = 0) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Error: List of used paper '
	             || 'document numbers/new paper document numbers/payment '
	             || 'ids is empty'
	             || '. Returning failure response .. '
	             );

         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     END IF;

     IF (p_pmt_list.COUNT <> p_new_ppr_docs_list.COUNT  OR
         p_pmt_list.COUNT <> p_old_ppr_docs_list.COUNT) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Error: List of paper '
	             || 'doc numbers must match list of payment ids. '
	             || 'Returning failure response .. '
	             );

         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     END IF;

     /*
      * STEP 0 .
      *
      * Setting the printer name supplied
      * while reprinting the payment
      * instruction
      *
      */

	UPDATE iby_pay_instructions_all ins
	SET ins.printer_name = p_printer_name
	WHERE ins.payment_instruction_id = p_instr_id;


     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Set printer name as '
	         || p_printer_name
	         || ' for payment instruction id  '
	         || p_instr_id
	         );

     END IF;
       /*A commit is necessary to avoid deadlock situations*/
       COMMIT;

     /*
      * STEP 1:
      *
      * Update the IBY_USED_PAYMENT_DOCS table with the list of
      * used paper document numbers. Since the user invokes this API
      * to reprint the paper documents, it follows that the earlier
      * used paper document was spoilt. Therefore, set the status of
      * the earlier used paper document to SPOILED.
      */

     FOR i IN p_old_ppr_docs_list.FIRST .. p_old_ppr_docs_list.LAST LOOP

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Updating paper doc number '
	             || p_old_ppr_docs_list(i)
	             || ' of payment document id '
	             || p_pmt_doc_id
	             || ' to spoiled status ..'
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
             p_pmt_doc_id,
             p_old_ppr_docs_list(i),
             sysdate,
             DOC_USE_SPOILED,
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.login_id,
             1
             );

     END LOOP;

     /*
      * STEP 2:
      *
      * Update the IBY_PAYMENTS_ALL table with the list of
      * new paper document numbers. The payment ids and new
      * paper document numbers have been provided in matching
      * order. The status of the payment also needs to be
      * updated to READY_FOR_REPRINT.
      */

     FOR i IN p_new_ppr_docs_list.FIRST .. p_new_ppr_docs_list.LAST LOOP

         /*
          * Get the current status of the
          * payment into l_curr_pmt_status
          */
         SELECT
             pmt.payment_status
         INTO
             l_curr_pmt_status
         FROM
             IBY_PAYMENTS_ALL pmt
         WHERE
             payment_id = p_pmt_list(i)
         ;

         /*
          * For debug purposes.
          */
         IF (l_curr_pmt_status = PAY_STATUS_VOID_SETUP) THEN

             l_temp_status := PAY_STATUS_SETUP_REPRINT;

         ELSIF (l_curr_pmt_status = PAY_STATUS_VOID_OVERFLOW) THEN

             l_temp_status := PAY_STATUS_OVERFLOW_REPRINT;

         ELSE

             l_temp_status := PAY_STATUS_REPRINT;

         END IF;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Updating status of payment id '
	             || p_pmt_list(i)
	             || ' from '
	             || l_curr_pmt_status
	             || ' to '
	             || l_temp_status
	             );

         END IF;
         /*
          * Set the payment status to READY_TO_REPRINT
          *
          * Void and overflow payments are identified by
          * their statuses, so we do not want to blindly
          * overwrite ther statuses. Instead, set their
          * status to special statuses that indicate the
          * payment is a setup / overflow payment and
          * it must be reprinted.
          */
         UPDATE
             IBY_PAYMENTS_ALL
         SET
             paper_document_number  = p_new_ppr_docs_list(i),
             payment_status         = DECODE(
                                          l_curr_pmt_status,
                                          PAY_STATUS_VOID_SETUP,
                                          PAY_STATUS_SETUP_REPRINT,
                                          PAY_STATUS_VOID_OVERFLOW,
                                          PAY_STATUS_OVERFLOW_REPRINT,
                                          PAY_STATUS_REPRINT
                                          )
         WHERE
             payment_id             = p_pmt_list(i) AND
             payment_instruction_id = p_instr_id
         ;

     END LOOP;


     /*
      * STEP 2A:
      *
      * Fix for bug 5470041:
      *
      * Update the last issued document number
      * in CE_PAYMENT_DOCUMENTS table using the
      * greatest document number from the user
      * provided list of new document numbers
      * for reprinting.
      */

     l_last_list_num := -1;

     FOR i IN p_new_ppr_docs_list.FIRST .. p_new_ppr_docs_list.LAST LOOP

         IF (p_new_ppr_docs_list(i) > l_last_list_num) THEN

             l_last_list_num := p_new_ppr_docs_list(i);

         END IF;

     END LOOP;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Greatest paper document number '
	         || 'derived from provided list: '
	         || l_last_list_num
	         );

     END IF;
     /*
      * This update uses an extra security check - we
      * only update the last issued doc number if the
      * provided list contains a doc number greater
      * than what is already stored in the database.
      */
     UPDATE
         CE_PAYMENT_DOCUMENTS
     SET
         last_issued_document_number =
             GREATEST(l_last_list_num, last_issued_document_number)
     WHERE
         payment_document_id         = p_pmt_doc_id
     RETURNING
         last_issued_document_number
     INTO
         l_last_doc_num
     ;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Payment document id '
	         || p_pmt_doc_id
	         || ' updated with last issued doc number set to: '
	         || l_last_doc_num
	         );

     END IF;
     /*
      * STEP 3:
      *
      * Invoke the hook that handles witholding certificates.
      * Every time a paper document is PRINTED | REPRINTED |
      * SPOILED, the witholding certificates should be in sync.
      */
     l_callout_name := l_pkg_name || '.' || 'zx_witholdingCertificatesHook';

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Attempting to call hook: '
	         || l_callout_name);

     END IF;
     l_stmt := 'CALL '|| l_callout_name || '(:1, :2, :3, :4, :5, :6, :7, :8)';

     BEGIN

	  iby_debug_pub.log(debug_msg => 'Enter withholding(printed) pkg:'||l_callout_name||': Timestamp:'  || systimestamp,
		       debug_level => FND_LOG.LEVEL_PROCEDURE,
		       module => l_module_name);

         EXECUTE IMMEDIATE
             (l_stmt)
         USING
             IN  p_instr_id,
             IN  'REPRINT',
             IN  l_api_version,
             IN  FND_API.G_FALSE,
             IN  FND_API.G_FALSE,
             OUT x_return_status,
             OUT l_msg_count,
             OUT l_msg_data
         ;

	  iby_debug_pub.log(debug_msg => 'Exit withholding(printed) pkg:'||l_callout_name||': Timestamp:'  || systimestamp,
	       debug_level => FND_LOG.LEVEL_PROCEDURE,
	       module => l_module_name);

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
	                 || '. Raising exception.'
	                 );

             END IF;
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
	                 || ''', generated exception.'
	                 );

	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);
             END IF;
             FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

             /*
              * Propogate exception to caller.
              */
             RAISE;
     END;



     /*
      * STEP 4:
      *
      * Invoke the print routine to re-print these payments.
      */
     IBY_FD_POST_PICP_PROGS_PVT.
         Run_Post_PI_Programs(
             p_instr_id,
             'Y'
             );

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Returning success response ..');

	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 EXCEPTION
     WHEN OTHERS THEN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Exception occured when '
	         || 'performing re-print for payment instruction '
	         || p_instr_id
	         );

	     print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	     print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);
     END IF;
     FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

     x_return_status := FND_API.G_RET_STS_ERROR;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END reprint_prenum_pmt_documents;


/*--------------------------------------------------------------------
 | NAME:
 |     reprint_blank_pmt_documents
 |
 |
 | PURPOSE:
 |     This API should be called if it is required to re-print some of the
 |     paper documents of a payment instruction. This API should only
 |     be called with the list of paper documents that were spoilt (not
 |     with the list of paper documents that were skipped, issued etc.).
 |
 |     The payment status will then be set to READY_FOR_REPRINT. No paper
 |     document number adjustment is required because the same paper
 |     document can be reused for bank paper stock. Only the status of the
 |     payment will be changed, the exiting paper document number on the
 |     payment will be untoched.
 |
 |     Finally, this API will invoke the paper printing flow.
 |
 |     This method should only be invoked for reprinting payment
 |     documents that are printed on blank paper stock (not for
 |     paper stock type that is 'prenumbered'). For reprinting
 |     payment documents that are on prenumbered stock use the method
 |     reprint_prenum_pmt_documents().
 |
 | PARAMETERS:
 |     IN
 |       p_instr_id      - ID of the payment instruction, for which some
 |                         payments need to be re-printed.
 |       p_pmt_list      - List of payments that are affected by the
 |                         re-print. The status of these payments will be
 |                         updated to indicate they are ready for reprint.
 |       p_printer_name  - Printer to use for re-printing payments.
 |
 |
 |     OUT
 |       x_return_status - Result of the API call:
 |                         FND_API.G_RET_STS_SUCCESS indicates that the
 |                           reprint process was triggered successfully.
 |                           In this case the caller must COMMIT
 |                           the status change.
 |
 |                         FND_API.G_RET_STS_ERROR (or other) indicates
 |                           that API did not complete successfully.
 |                           In this case, the caller must issue a
 |                           ROLLBACK to undo all status changes.
 |
 | RETURNS:
 |
 | NOTES:
 |   Internal API, not for public use.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE reprint_blank_pmt_documents(
     p_instr_id          IN NUMBER,
     p_pmt_list          IN pmtIDTab,
     p_printer_name      IN VARCHAR2,
     x_return_status     OUT NOCOPY VARCHAR2
     )
 IS

 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME
                                         || '.reprint_blank_pmt_documents';

 l_curr_pmt_status  VARCHAR2(200);

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     FND_MSG_PUB.initialize;

     /*
      * STEP 0 .
      *
      * Setting the printer name supplied
      * while reprinting the payment
      * instruction
      *
      */

	UPDATE iby_pay_instructions_all ins
	SET ins.printer_name = p_printer_name
	WHERE ins.payment_instruction_id = p_instr_id;


     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Set printer name as '
	         || p_printer_name
	         || ' for payment instruction id  '
	         || p_instr_id
	         );

     END IF;
       /*A commit is necessary to avoid deadlock situations*/
       COMMIT;

     /*
      * STEP 1:
      *
      * Check whether any payments have been provided.
      */
     IF (p_pmt_list.COUNT = 0) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Error: List of payment ids '
	             || 'is empty'
	             || '. Returning failure response .. '
	             );

         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     END IF;

     /*
      * STEP 2:
      *
      * Update the IBY_PAYMENTS_ALL table with the new status.
      * The status of the payment needs to be READY_FOR_REPRINT.
      */
     FOR i IN p_pmt_list.FIRST .. p_pmt_list.LAST LOOP

         /*
          * Get the current status of the
          * payment into l_curr_pmt_status
          */
         SELECT
             pmt.payment_status
         INTO
             l_curr_pmt_status
         FROM
             IBY_PAYMENTS_ALL pmt
         WHERE
             payment_id = p_pmt_list(i)
         ;


         /*
          * Set the payment status to READY_TO_REPRINT
          *
          * Void and overflow payments are identified by
          * their statuses, so we do not want to blindly
          * overwrite ther statuses. Instead, set their
          * status to special statuses that indicate the
          * payment is a setup / overflow payment and
          * it must be reprinted.
          */
         UPDATE
             IBY_PAYMENTS_ALL
         SET
             payment_status         = DECODE(
                                          l_curr_pmt_status,
                                          PAY_STATUS_VOID_SETUP,
                                          PAY_STATUS_SETUP_REPRINT,
                                          PAY_STATUS_VOID_OVERFLOW,
                                          PAY_STATUS_OVERFLOW_REPRINT,
                                          PAY_STATUS_REPRINT
                                          )
         WHERE
             payment_id             = p_pmt_list(i) AND
             payment_instruction_id = p_instr_id
         ;

     END LOOP;


     /*
      * STEP 3:
      *
      * Invoke the print routine to re-print these payments.
      */
     IBY_FD_POST_PICP_PROGS_PVT.
         Run_Post_PI_Programs(
             p_instr_id,
             'Y'
             );

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Returning success response ..');

	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 EXCEPTION
     WHEN OTHERS THEN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Exception occured when '
	         || 'performing re-print for payment instruction '
	         || p_instr_id
	         );

	     print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	     print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);
     END IF;
     FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

     x_return_status := FND_API.G_RET_STS_ERROR;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END reprint_blank_pmt_documents;

/*--------------------------------------------------------------------
 | NAME:
 |     reprint_payment_instruction
 |
 | PURPOSE:
 |     Reprints all the payment documents associated with a payment
 |     instruction.
 |
 |     Note that in this case, no renumbering of the paper documents
 |     is required. This API is equivalent to making a fresh print call
 |     for a payment instruction (only requirement is that the payments of
 |     the payment instruction be numbered). We simply send the payment
 |     instruction for printing with the existing payment document numbers.
 |
 |     Do not call this API if printing for the payment instruction has
 |     already been attempted earlier.
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
 |   Internal API, not for public use.
 |
 |   This procedure performs a COMMIT.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE reprint_payment_instruction (
     p_instr_id          IN NUMBER,
     p_printer_name      IN VARCHAR2,
     x_return_status     OUT NOCOPY VARCHAR2
     )
 IS

 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME
                                         || '.reprint_payment_instruction';

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     FND_MSG_PUB.initialize;

     /*
      * STEP 1:
      *
      * Update the status of the payments of the given
      * instruction to indicate that they must be reprinted.
      */
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Updating statuses of the '
	         || 'payments of payment instruction '
	         || p_instr_id
	         || ' to formatted ..'
	         );

     END IF;
     UPDATE
         IBY_PAYMENTS_ALL
     SET
         payment_status = PAY_STATUS_FORMATTED
     WHERE
         payment_instruction_id = p_instr_id AND
         PAYMENT_SERVICE_REQUEST_ID <> -1
     ;

     /*
      * STEP 2:
      *
      * Update the status of the payment instruction
      * to indicate that it must be re-printed.
      */
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Updating status of '
	         || 'payment instruction '
	         || p_instr_id
	         || ' to formatted - ready for printing ..'
	         );
     END IF;
     UPDATE
         IBY_PAY_INSTRUCTIONS_ALL
     SET
         payment_instruction_status = INS_STATUS_FORMAT_TO_PRINT
     WHERE
         payment_instruction_id = p_instr_id
     ;

     /*
      * This commit is necessary. Otherwise a deadlocked
      * condition is created when we try to update the same
      * payment instruction with the concurrent request id
      * (for handling intermediate statuses).
      */
     COMMIT;


     /*
      * STEP 3:
      *
      * Invoke the print routine to re-print these payments.
      */

     /*
      * Note that reprint flag is 'N' in this case;
      * this is to treat the re-print as a fresh print.
      */
     IBY_FD_POST_PICP_PROGS_PVT.
         Run_Post_PI_Programs(
             p_instr_id,
             'N'
             );

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Returning success response ..');

	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 EXCEPTION
     WHEN OTHERS THEN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Exception occured when '
	         || 'performing re-print for payment instruction '
	         || p_instr_id
	         );

	     print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	     print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);
     END IF;
     FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

     x_return_status := FND_API.G_RET_STS_ERROR;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END reprint_payment_instruction;


/*--------------------------------------------------------------------
 | NAME:
 |     finalize_print_status
 |
 |
 | PURPOSE:
 |     Records the final print status for a set of paper documents.
 |
 |     This is an overloaded method. See the other method signature
 |     for complete documentation.
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
 |   Internal API, not for public use.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE finalize_print_status(
     p_instr_id         IN NUMBER,
     p_pmt_doc_id       IN NUMBER,
     p_used_docs_list   IN paperDocNumTab,
     x_return_status    OUT NOCOPY VARCHAR2
     )
 IS
 BEGIN

     finalize_print_status(
         p_instr_id,
         p_pmt_doc_id,
         p_used_docs_list,
         FALSE,
         x_return_status
         );

 END finalize_print_status;

/*--------------------------------------------------------------------
 | NAME:
 |     finalize_print_status
 |
 |
 | PURPOSE:
 |     Records the final print status for a set of paper documents.
 |
 |     This is an overloaded method. See the other method signature
 |     for complete documentation.
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
 |   Internal API, not for public use.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE finalize_print_status(
     p_instr_id         IN NUMBER,
     p_pmt_doc_id       IN NUMBER,
     p_used_docs_list   IN paperDocNumTab,
     p_used_pmts_list   IN paperDocNumTab,
     x_return_status    OUT NOCOPY VARCHAR2
     )
 IS
 BEGIN
     finalize_print_status(
         p_instr_id,
         p_pmt_doc_id,
         p_used_docs_list,
         p_used_pmts_list,
         FALSE,
         x_return_status
         );

 END finalize_print_status;
/*--------------------------------------------------------------------
 | NAME:
 |     finalize_print_status
 |
 |
 | PURPOSE:
 |     Records the final print status for a set of paper documents.
 |
 |     This is an overloaded method. See the other method signature
 |     for complete documentation.
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
 |   Internal API, not for public use.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE finalize_print_status(
     p_instr_id           IN NUMBER,
     p_pmt_doc_id         IN NUMBER,
     p_used_docs_list     IN paperDocNumTab,
     p_used_pmts_list     IN paperDocNumTab,
     p_submit_postive_pay IN BOOLEAN,
     x_return_status      OUT NOCOPY VARCHAR2
     )
IS
 p_skipped_docs_list paperDocNumTab;
 BEGIN
 p_skipped_docs_list(1) := -1;

     finalize_print_status(
         p_instr_id,
         p_pmt_doc_id,
         p_used_docs_list,
         p_used_pmts_list,
	 p_skipped_docs_list,
	 p_submit_postive_pay,
         x_return_status
         );

 END finalize_print_status;

/*--------------------------------------------------------------------
 | NAME:
 |     finalize_print_status
 |
 | PURPOSE:
 |     Records the final print status for a set of paper documents. This
 |     API will insert the given set of paper document numbers into the
 |     IBY_USED_PAYMENT_DOCS table along with the usage reason indicating
 |     whether the paper document was spoiled.
 |
 |     Note that this API should only be invoked with the list of spoiled
 |     paper documents. The UI should directly handle the successfully
 |     printed paper documents. For performance reasons, this API is
 |     designed only to handle the spoiled paper document case.
 |
 |     This API will set the usage reason for each provided document
 |     to 'SPOILED' in the IBY_USED_PAYMENT_DOCS table, and it will also
 |     set the status of the corresponding payment to
 |     REMOVED_DOCUMENT_SPOILED.
 |
 |     Then, this API will set the status of the successfully printed
 |     payments to ISSUED status and then invoke the 'mark complete'
 |     API to mark the payments of this payment instruction as complete.
 |
 | PARAMETERS:
 |     IN
 |       p_pmt_doc_id      - The payment document id (check stock id)
 |                           of the given list of paper documents.
 |       p_used_docs_list  - The list of paper documents that have been
 |                           used for printing
 |
 |       p_submit_postive_pay
 |                         - Flag indicating whether positive pay file
 |                           report needs to be launched after finalizing
 |                           the payments.
 |
 |     OUT
 |       x_return_status   - Result of the API call:
 |                           FND_API.G_RET_STS_SUCCESS indicates that the
 |                           finalization process completed raised
 |                           successfully. In this case the caller must
 |                           COMMIT the status change.
 |
 |                           FND_API.G_RET_STS_ERROR (or other) indicates
 |                           that API did not complete successfully.
 |                           In this case, the caller must issue a
 |                           ROLLBACK to undo all status changes.
 |
 | RETURNS:
 |
 | NOTES:
 |   Internal API, not for public use.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE finalize_print_status(
     p_instr_id           IN NUMBER,
     p_pmt_doc_id         IN NUMBER,
     p_used_docs_list     IN paperDocNumTab,
     p_submit_postive_pay IN BOOLEAN,
     x_return_status      OUT NOCOPY VARCHAR2
     )
 IS
 p_used_pmts_list paperDocNumTab;
 p_skipped_docs_list paperDocNumTab;
 BEGIN
 p_used_pmts_list(1) := -1;
 p_skipped_docs_list(1) := -1;

       finalize_final_print_status(
               p_instr_id,
               p_pmt_doc_id,
               p_used_docs_list,
               p_used_pmts_list,
	       p_skipped_docs_list,
	       p_submit_postive_pay,
               x_return_status
               );

 END finalize_print_status;


/*--------------------------------------------------------------------
 | NAME:
 |     finalize_print_status
 |
 | PURPOSE:
 |     Records the final print status for a set of paper documents. This
 |     API will insert the given set of paper document numbers into the
 |     IBY_USED_PAYMENT_DOCS table along with the usage reason indicating
 |     whether the paper document was spoiled.
 |
 |     Note that this API should only be invoked with the list of spoiled
 |     paper documents. The UI should directly handle the successfully
 |     printed paper documents. For performance reasons, this API is
 |     designed only to handle the spoiled paper document case.
 |
 |     This API will set the usage reason for each provided document
 |     to 'SPOILED' in the IBY_USED_PAYMENT_DOCS table, and it will also
 |     set the status of the corresponding payment to
 |     REMOVED_DOCUMENT_SPOILED.
 |
 |     Then, this API will set the status of the successfully printed
 |     payments to ISSUED status and then invoke the 'mark complete'
 |     API to mark the payments of this payment instruction as complete.
 |
 | PARAMETERS:
 |     IN
 |       p_pmt_doc_id      - The payment document id (check stock id)
 |                           of the given list of paper documents.
 |       p_used_docs_list  - The list of paper documents that have been
 |                           used for printing
 |       p_use_reason_list - The list of paper document usage reasons. This
 |                           list will contain a lookup code that specifies
 |                           whether the paper document was correctly
 |                           printed or not. Possible values include
 |                           ISSUED | SPOILED. SKIPPED will never be a
 |                           provided reason because skipped documents have
 |                           successfully printed (only numbering is wrong).
 |       p_submit_postive_pay
 |                         - Flag indicating whether positive pay file
 |                           report needs to be launched after finalizing
 |                           the payments.
 |
 |     OUT
 |       x_return_status   - Result of the API call:
 |                           FND_API.G_RET_STS_SUCCESS indicates that the
 |                           finalization process completed raised
 |                           successfully. In this case the caller must
 |                           COMMIT the status change.
 |
 |                           FND_API.G_RET_STS_ERROR (or other) indicates
 |                           that API did not complete successfully.
 |                           In this case, the caller must issue a
 |                           ROLLBACK to undo all status changes.
 |
 | RETURNS:
 |
 | NOTES:
 |   Internal API, not for public use.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE finalize_print_status(
     p_instr_id           IN NUMBER,
     p_pmt_doc_id         IN NUMBER,
     p_used_docs_list     IN paperDocNumTab,
     p_used_pmts_list     IN paperDocNumTab,
     p_skipped_docs_list  IN paperDocNumTab,
     p_submit_postive_pay IN BOOLEAN,
     x_return_status      OUT NOCOPY VARCHAR2
     )
 IS

 BEGIN

          finalize_final_print_status(
               p_instr_id,
               p_pmt_doc_id,
               p_used_docs_list,
               p_used_pmts_list,
	       p_skipped_docs_list,
	       p_submit_postive_pay,
               x_return_status
               );
 END finalize_print_status;

/*--------------------------------------------------------------------
 | NAME:
 |     finalize_instr_print_status
 |
 | PURPOSE:
 |     Records the final print status for all the paper documents that
 |     are part of a payment instruction.
 |
 |     This is an overloaded method. See the other method signature for
 |     complete documentation.
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
 |   Internal API, not for public use.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE finalize_instr_print_status(
     p_instr_id       IN NUMBER,
     x_return_status  OUT NOCOPY VARCHAR2
     )
 IS
 BEGIN

     finalize_instr_print_status(
         p_instr_id,
         FALSE,
         x_return_status
         );

 END finalize_instr_print_status;

/*--------------------------------------------------------------------
 | NAME:
 |     finalize_instr_print_status
 |
 | PURPOSE:
 |     Records the final print status for all the paper documents that
 |     are part of a payment instruction. This API will insert the paper
 |     document numbers linked to each payment in the instruction into the
 |     IBY_USED_PAYMENT_DOCS table along with the usage reason indicating
 |     that the paper document was successfully printed.
 |
 |     This API should only invoked when *all* the payments that are part
 |     of a payment instruction have been printed successfully.
 |
 |     This API is a light weight alternative to the finalize_print_status()
 |     API because the caller does not have to provide the list of used
 |     payment documents along with the usage reason. This API derives the
 |     list of used payment documents from the payments on the instruction
 |     and it sets the usage reason for each payment document as 'issued'.
 |
 | PARAMETERS:
 |     IN
 |       p_instr_id        - The payment instruction id for which all
 |                           checks were successfully printed.
 |
 |       p_submit_postive_pay
 |                         - Flag indicating whether positive pay file
 |                           report needs to be launched after finalizing
 |                           the payments.
 |
 |     OUT
 |       x_return_status   - Result of the API call:
 |                           FND_API.G_RET_STS_SUCCESS indicates that the
 |                           finalization process completed raised
 |                           successfully. In this case the caller must
 |                           COMMIT the status change.
 |
 |                           FND_API.G_RET_STS_ERROR (or other) indicates
 |                           that API did not complete successfully.
 |                           In this case, the caller must issue a
 |                           ROLLBACK to undo all status changes.
 |
 | RETURNS:
 |
 | NOTES:
 |   Internal API, not for public use.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE finalize_instr_print_status(
     p_instr_id           IN NUMBER,
     p_submit_postive_pay IN BOOLEAN,
     x_return_status      OUT NOCOPY VARCHAR2
     )
 IS
 p_pmt_doc_id NUMBER := NULL;
 p_used_docs_list paperDocNumTab;
 p_used_pmts_list paperDocNumTab;
 p_skipped_pmts_list paperDocNumTab;
 BEGIN
 p_used_docs_list(1) := -1;
 p_used_pmts_list(1) := -1;
 p_skipped_pmts_list(1) := -1;

          finalize_final_print_status(
               p_instr_id,
               p_pmt_doc_id,
               p_used_docs_list,
               p_used_pmts_list,
	       p_skipped_pmts_list,
	       p_submit_postive_pay,
               x_return_status
               );

 END finalize_instr_print_status;

 /*--------------------------------------------------------------------
 | NAME:
 |     finalize_final_print_status
 |
 | PURPOSE:
 |     Records the final print status for a set of paper documents. This
 |     API will insert the given set of paper document numbers into the
 |     IBY_USED_PAYMENT_DOCS table along with the usage reason indicating
 |     whether the paper document was spoiled.
 |
 |     Note that this API should only be invoked with the list of spoiled
 |     paper documents. The UI should directly handle the successfully
 |     printed paper documents. For performance reasons, this API is
 |     designed only to handle the spoiled paper document case.
 |
 |     This API will set the usage reason for each provided document
 |     to 'SPOILED' in the IBY_USED_PAYMENT_DOCS table, and it will also
 |     set the status of the corresponding payment to
 |     REMOVED_DOCUMENT_SPOILED.
 |
 |     Then, this API will set the status of the successfully printed
 |     payments to ISSUED status and then invoke the 'mark complete'
 |     API to mark the payments of this payment instruction as complete.
 |
 | PARAMETERS:
 |     IN
 |       p_pmt_doc_id      - The payment document id (check stock id)
 |                           of the given list of paper documents.
 |       p_used_docs_list  - The list of paper documents that have been
 |                           used for printing
 |       p_use_reason_list - The list of paper document usage reasons. This
 |                           list will contain a lookup code that specifies
 |                           whether the paper document was correctly
 |                           printed or not. Possible values include
 |                           ISSUED | SPOILED. SKIPPED will never be a
 |                           provided reason because skipped documents have
 |                           successfully printed (only numbering is wrong).
 |       p_submit_postive_pay
 |                         - Flag indicating whether positive pay file
 |                           report needs to be launched after finalizing
 |                           the payments.
 |
 |     OUT
 |       x_return_status   - Result of the API call:
 |                           FND_API.G_RET_STS_SUCCESS indicates that the
 |                           finalization process completed raised
 |                           successfully. In this case the caller must
 |                           COMMIT the status change.
 |
 |                           FND_API.G_RET_STS_ERROR (or other) indicates
 |                           that API did not complete successfully.
 |                           In this case, the caller must issue a
 |                           ROLLBACK to undo all status changes.
 |
 | RETURNS:
 |
 | NOTES:
 |   Internal API, not for public use.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE finalize_final_print_status(
     p_instr_id           IN NUMBER,
     p_pmt_doc_id         IN NUMBER,
     p_used_docs_list     IN paperDocNumTab,
     p_used_pmts_list     IN paperDocNumTab,
     p_skipped_docs_list  IN paperDocNumTab,
     p_submit_postive_pay IN BOOLEAN,
     x_return_status      OUT NOCOPY VARCHAR2
     )
 IS
 l_request_id  NUMBER;
 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME
                                         || '.finalize_final_print_status';
 l_used_docs_list VARCHAR2(4000) := NULL;
 l_used_pmts_list VARCHAR2(4000) := NULL;
 l_skipped_docs_list VARCHAR2(4000) := NULL;

 l_submit_postive_pay VARCHAR2(20);
 l_request_status BOOLEAN := FALSE;
 l_req_status VARCHAR2(30);
 BEGIN

       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');
      END IF;

         IF(p_used_docs_list(1) <> -1) THEN
           FOR i IN p_used_docs_list.FIRST .. p_used_docs_list.LAST LOOP
            l_used_docs_list := l_used_docs_list||p_used_docs_list(i)||'$';
           END LOOP;
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'l_used_docs_list: '|| l_used_docs_list);
           END IF;
         ELSE
         l_used_docs_list := NULL;
         END IF;

         IF(p_used_pmts_list(1) <> -1) THEN
           FOR i IN p_used_pmts_list.FIRST .. p_used_pmts_list.LAST LOOP
            l_used_pmts_list := l_used_pmts_list||p_used_pmts_list(i)||'$';
           END LOOP;
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'l_used_pmts_list: '|| l_used_pmts_list);
           END IF;
         ELSE
         l_used_pmts_list := NULL;
         END IF;

	 IF(p_skipped_docs_list(1) <> -1) THEN
           FOR i IN p_skipped_docs_list.FIRST .. p_skipped_docs_list.LAST LOOP
            l_skipped_docs_list := l_skipped_docs_list||p_skipped_docs_list(i)||'$';
           END LOOP;
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'l_skipped_docs_list: '|| l_skipped_docs_list);
           END IF;
         ELSE
         l_skipped_docs_list := NULL;
         END IF;


         IF (p_submit_postive_pay = TRUE) THEN
          l_submit_postive_pay := 'TRUE';
         ELSE
          l_submit_postive_pay := 'FALSE';
         END IF;

        SELECT request_id INTO l_request_id
        FROM iby_pay_instructions_all
        WHERE payment_instruction_id = p_instr_id;

         IF(l_request_id IS NOT NULL) THEN

              l_req_status :=  get_conc_request_status(l_request_id);

              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                    print_debuginfo(l_module_name, 'Request Status::'
                             || l_req_status
                             );
              END IF;

              IF(l_req_status = 'ERROR') THEN
                    IBY_DISBURSE_UI_API_PUB_PKG.unlock_pmt_entity(
                                         p_instr_id ,
                                         'PAYMENT_INSTRUCTION',
                                         x_return_status
                                         );

                    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_ERROR;
                    ELSE
                      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                        print_debuginfo(l_module_name, 'unlock_pmt_entity() API returned success');
                      END IF;
                    END IF;
             END IF;
         END IF;
  IF(l_request_id IS NULL OR l_req_status = 'ERROR')  THEN

 l_request_id := FND_REQUEST.SUBMIT_REQUEST
	    (
	      'IBY',
	      'IBY_FD_RECORD_PRINT_STATUS',
	      null,  -- description
	      null,  -- start_time
	      FALSE, -- sub_request
	      p_instr_id,
	      p_pmt_doc_id,
	      l_used_docs_list,
              l_used_pmts_list,
              l_submit_postive_pay,
              l_skipped_docs_list, '', '', '', '', '', '', '',
	      '', '', '', '', '', '', '', '',
	      '', '', '', '', '', '', '', '',
	      '', '', '', '', '', '', '', '',
	      '', '', '', '', '', '', '', '',
	      '', '', '', '', '', '', '', '',
	      '', '', '', '', '', '', '', '',
	      '', '', '', '', '', '', '', '',
	      '', '', '', '', '', '', '', '',
	      '', '', '', '', '', '', '', '',
	      '', '', '', '', '', '', '', '',
	      '', '', '', '', '', '', ''
	    );

            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              print_debuginfo(l_module_name, 'Calling the lock_pmt_entity() API to lock instruction: ' || p_instr_id
                                    || ' for the extract/formatting/printing/delivery program');
            END IF;

      IBY_DISBURSE_UI_API_PUB_PKG.lock_pmt_entity(
             p_object_id         => p_instr_id,
             p_object_type       => 'PAYMENT_INSTRUCTION',
             p_conc_request_id   => l_request_id,
             x_return_status     => x_return_status
             );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSE

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          print_debuginfo(l_module_name, 'lock_pmt_entity() API returned success');
        END IF;
      END IF;

 END IF;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');
      END IF;

END finalize_final_print_status;
 /*--------------------------------------------------------------------
 | NAME:
 |   record_print_status
 |
 | PURPOSE:
 |     Records the final print status for a set of paper documents. This
 |     API will insert the given set of paper document numbers into the
 |     IBY_USED_PAYMENT_DOCS table along with the usage reason indicating
 |     whether the paper document was spoiled.
 |
 |     Note that this API should only be invoked with the list of spoiled
 |     paper documents. The UI should directly handle the successfully
 |     printed paper documents. For performance reasons, this API is
 |     designed only to handle the spoiled paper document case.
 |
 |     This API will set the usage reason for each provided document
 |     to 'SPOILED' in the IBY_USED_PAYMENT_DOCS table, and it will also
 |     set the status of the corresponding payment to
 |     REMOVED_DOCUMENT_SPOILED.
 |
 |     Then, this API will set the status of the successfully printed
 |     payments to ISSUED status and then invoke the 'mark complete'
 |     API to mark the payments of this payment instruction as complete.
 |
 | PARAMETERS:
 |     IN
 |       p_pmt_doc_id      - The payment document id (check stock id)
 |                           of the given list of paper documents.
 |       p_used_docs_list  - The list of paper documents that have been
 |                           used for printing
 |       p_use_reason_list - The list of paper document usage reasons. This
 |                           list will contain a lookup code that specifies
 |                           whether the paper document was correctly
 |                           printed or not. Possible values include
 |                           ISSUED | SPOILED. SKIPPED will never be a
 |                           provided reason because skipped documents have
 |                           successfully printed (only numbering is wrong).
 |       p_submit_postive_pay
 |                         - Flag indicating whether positive pay file
 |                           report needs to be launched after finalizing
 |                           the payments.
 |       p_args8 - p_args100
 |        These 93 parameters are mandatory for any stored procedure
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
 | NOTES:
 |   Internal API, not for public use.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE record_print_status(
     x_errbuf                     OUT NOCOPY VARCHAR2,
     x_retcode                    OUT NOCOPY VARCHAR2,
     p_instr_id           IN NUMBER,
     p_pmt_doc_id         IN NUMBER,
     p_used_docs_list     IN VARCHAR2,
     p_used_pmts_list     IN VARCHAR2,
     p_submit_postive_pay IN VARCHAR2,
     p_skipped_docs_list  IN VARCHAR2 DEFAULT NULL,
     p_arg7  IN VARCHAR2 DEFAULT NULL,
     p_arg8  IN VARCHAR2 DEFAULT NULL, p_arg9  IN VARCHAR2 DEFAULT NULL,
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
  l_request_id            NUMBER;
  l_return_status      VARCHAR2(4000);
  l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME
                                         || '.record_print_status';
 l_paper_doc_num IBY_PAYMENTS_ALL.paper_document_number%TYPE;
 l_payment_status_list  docPayStatusTab;
 l_pmtDocsTab  paperDocNumTab;
  l_skipped_document_number IBY_PAYMENTS_ALL.paper_document_number%TYPE;
  l_pmt_doc_id     NUMBER(15);

 /* used in invocation of callout procedure */
 l_api_version    CONSTANT NUMBER := 1.0;
 l_msg_count      NUMBER;
 l_first_doc_number      NUMBER;
 l_last_doc_number      NUMBER;
 l_msg_data       VARCHAR2(2000);
 l_pkg_name       CONSTANT VARCHAR2(100) := 'AP_AWT_CALLOUT_PKG';
 l_callout_name   VARCHAR2(500);
 l_stmt           VARCHAR2(1000);

 /* Bug #6508530 -used for changing status for spoiled payment, document */
 l_doc_id_list    docPayIDTab;
 l_doc_status_list  docPayStatusTab;

 l_submit_postive_pay BOOLEAN;
 l_used_docs_list paperDocNumTab;
 l_used_pmts_list paperDocNumTab;
 l_skipped_docs_list paperDocNumTab;

 t_used_docs_list VARCHAR2(4000);
 t_used_pmts_list VARCHAR2(4000);
 t_skipped_docs_list VARCHAR2(4000);

 l_str  VARCHAR2(4000) := NULL;
 l_count NUMBER := 0;
 j NUMBER := 1;

 x_return_status_remove_doc    VARCHAR2(200);

 CURSOR c_docs (p_pmt_id IBY_PAYMENTS_ALL.
                                payment_id%TYPE)
 IS
 SELECT
     doc.document_payable_id,
     doc.document_status
 FROM
     IBY_DOCS_PAYABLE_ALL doc
 WHERE
     doc.payment_id = p_pmt_id

 ;


 /*
  * Cursor to pick up all the payment document numbers that
  * are linked to payments of a particular payment
  * instruction.
  */

 /*
  * Fix for bug 4887500.
  *
  * When finalizing the status of a payment instruction, the payment
  * status may not be in the right status for single payments.
  *
  * This is because the Post-PICP program performs the status change
  * for the payment and since it runs as a separate conc request, it
  * may not have completed by the time the single payments API
  * calls this post-PICP program and immediately starts to finalize
  * the payment status.
  *
  * Therefore, the best approach would be to not consider the payment
  * status when the payment is a single payment (i.e., process type of
  * the payment is 'immediate').
  */

 CURSOR c_pmt_docs (p_instr_id NUMBER)
 IS
 SELECT
     pmt.paper_document_number
 FROM
     IBY_PAYMENTS_ALL pmt
 WHERE
     pmt.payment_instruction_id = p_instr_id    AND
         (
             (
              pmt.payment_status         = PAY_STATUS_FORMATTED      OR
              pmt.payment_status         = PAY_STATUS_SUB_FOR_PRINT
             )
             OR
             (
              pmt.process_type           = PROCESS_TYPE_IMMEDIATE
             )
         )
 ;

 /*
  * Implementing the hook is optional for the calling app.
  * If the calling app does not implement the hook, then
  * the call to the hook will result in ORA-06576 error.
  *
  * There is no exception name associated with this code, so
  * we create one called 'PROCEDURE_NOT_IMPLEMENTED'. If this
  * exception occurs, it is not fatal: we log the error and
  * proceed.
  *
  * If, on the other hand, the calling app implements the
  * hook, but the hook throws an exception, it is fatal
  * and we must abort the program (this will be caught
  * in WHEN OTHERS block).
  */
 PROCEDURE_NOT_IMPLEMENTED EXCEPTION;
 PRAGMA EXCEPTION_INIT(PROCEDURE_NOT_IMPLEMENTED, -6576);

 BEGIN

   iby_debug_pub.log(debug_msg => 'Enter Record Print Status: Timestamp:'  || systimestamp,
		       debug_level => FND_LOG.LEVEL_PROCEDURE,
		       module => l_module_name);

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');
     END IF;
     FND_MSG_PUB.initialize;

     IF (p_submit_postive_pay = 'TRUE') THEN
          l_submit_postive_pay := TRUE;
         ELSE
          l_submit_postive_pay := FALSE;
         END IF;

      /*
      * STEP 1.5:
      *
      * Managing skipped documents
      * Finding out which of the documents are skipped
      *
      */
 IF(p_skipped_docs_list IS NOT NULL) THEN
         t_skipped_docs_list := p_skipped_docs_list;
      WHILE (LENGTH(t_skipped_docs_list) <> 0) LOOP

          l_count := instr(t_skipped_docs_list, '$');
          l_str := substr(t_skipped_docs_list,1,l_count-1);
          l_skipped_docs_list(j) := to_number(l_str);
          t_skipped_docs_list := substr(t_skipped_docs_list, l_count+1);
          l_str := NULL;
          l_count := 0;
                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			 print_debuginfo(l_module_name, 'l_skipped_docs_list(j): '|| l_skipped_docs_list(j));
		 END IF;
          j := j+1;
       END LOOP;

 FOR i IN l_skipped_docs_list.FIRST .. l_skipped_docs_list.LAST LOOP
         BEGIN

                -- check if it already exists in the used_documents_table
		SELECT cedocs.used_document_number
   	        INTO  l_skipped_document_number
		FROM iby_used_payment_docs cedocs
		WHERE cedocs.payment_document_id = p_pmt_doc_id
		 AND cedocs.used_document_number = l_skipped_docs_list(i);

	 EXCEPTION
	 WHEN NO_DATA_FOUND THEN

                 -- inserting the document as skipped
                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'inserting as skipped  ' || l_skipped_docs_list(i));
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
		     p_pmt_doc_id,
		     l_skipped_docs_list(i),
		     sysdate,
		     'SKIPPED',
		     fnd_global.user_id,
		     sysdate,
		     fnd_global.user_id,
		     sysdate,
		     fnd_global.login_id,
		     1
		     );
	 END;

 END LOOP;

 END IF;

 j := 1;
 IF(p_used_docs_list IS NOT NULL) THEN

  t_used_docs_list := p_used_docs_list;

       WHILE (LENGTH(t_used_docs_list) <> 0) LOOP
          l_count := instr(t_used_docs_list, '$');
          l_str := substr(t_used_docs_list,1,l_count-1);
          l_used_docs_list(j) := to_number(l_str);
          t_used_docs_list := substr(t_used_docs_list, l_count+1);
          l_str := NULL;
          l_count := 0;
                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			 print_debuginfo(l_module_name, 'l_used_docs_list(j): '|| l_used_docs_list(j));
		 END IF;
          j := j+1;
       END LOOP;

     /*
      * STATUS CHANGE:
      *
      * UI Responsibility:
      * NONE
      *
      * API Responsibility:
      * payment instruction status = PRINTED
      *
      * payment status = REMOVED_DOCUMENT_SPOILED (for spoiled payments)
      * payment status = ISSUED (for successful payments)
      */

	     IF (l_used_docs_list.COUNT = 0) THEN

		 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			 print_debuginfo(l_module_name, 'Error: List of used paper '
			     || 'document numbers is empty'
			     || '. Returning failure response .. '
			     );

		 END IF;
		 l_return_status := FND_API.G_RET_STS_ERROR;

		 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			 print_debuginfo(l_module_name, 'EXIT');
		 END IF;
		 RETURN;

	     END IF;


      -- looping through the complete document list
  IF(p_used_pmts_list IS NOT NULL) THEN

      l_str := NULL;
      l_count := 0;
      j := 1;
      t_used_pmts_list := p_used_pmts_list;

          WHILE (LENGTH(t_used_pmts_list) <> 0) LOOP
            l_count := instr(t_used_pmts_list, '$');
            l_str := substr(t_used_pmts_list,1,l_count-1);
            l_used_pmts_list(j) := to_number(l_str);
            t_used_pmts_list := substr(t_used_pmts_list, l_count+1);
            l_str := NULL;
            l_count := 0;
                  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			 print_debuginfo(l_module_name, 'l_used_pmts_list(j): '|| l_used_pmts_list(j));
		 END IF;
            j := j+1;
         END LOOP;

      j := 1;
     /*
      * STEP 1:
      *
      * Start processing the used paper documents, one-by-one.
      *
      * This API will only be called with the list of spoiled
      * paper documents, so we can set the usage reason for
      * each paper document to 'spoiled'.
      */

     FOR i IN l_used_docs_list.FIRST .. l_used_docs_list.LAST LOOP

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	  print_debuginfo(l_module_name, 'fetching the payment status for the documents and storing them in an array for: '|| l_used_docs_list(i));
        END IF;
	 -- fetching the payment status for the documents and storing them in an array
	 SELECT payment_status
	 INTO l_payment_status_list(i)
	 FROM IBY_PAYMENTS_ALL
	 WHERE paper_document_number = l_used_docs_list(i)
	 AND payment_id = l_used_pmts_list(i)
	 AND payment_instruction_id = p_instr_id;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Paper Document Number = ' || l_used_docs_list(i));
	         print_debuginfo(l_module_name, 'Payment ID : Payment Status = ' || l_used_pmts_list(i) || ':' || l_payment_status_list(i));

         END IF;
	 BEGIN

		-- checking if the document is already skipped earlier
		SELECT cedocs.used_document_number
   	        INTO  l_skipped_document_number
		FROM iby_used_payment_docs cedocs
		WHERE cedocs.payment_document_id = p_pmt_doc_id
		 AND cedocs.used_document_number = l_used_docs_list(i)
		 AND cedocs.document_use = 'SKIPPED';

	 EXCEPTION
	 WHEN NO_DATA_FOUND THEN

		 --if the document is not skipped earlier insert new
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
		     p_pmt_doc_id,
		     l_used_docs_list(i),
		     sysdate,
		     decode(l_payment_status_list(i),'REMOVED_DOCUMENT_SPOILED','SPOILED','ISSUED'),
		     fnd_global.user_id,
		     sysdate,
		     fnd_global.user_id,
		     sysdate,
		     fnd_global.login_id,
		     1
		     );

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Document number not found, inserting new');
                 END IF;
	 END;

         -- updating the document_use in any case
	 UPDATE IBY_USED_PAYMENT_DOCS
	 SET DOCUMENT_USE = decode(l_payment_status_list(i),'REMOVED_DOCUMENT_SPOILED','SPOILED','ISSUED')
	 WHERE payment_document_id = p_pmt_doc_id
	 AND used_document_number = l_used_docs_list(i);

	 print_debuginfo(l_module_name, 'Found skipped document number, updating document usage');

      END LOOP;

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Finished updating document use table.');

      END IF;

     /*
      * STEP 2:
      *
      * Pick up all payments for this payment instruction
      * that have the given paper document number one-by-one.
      *
      * For each such payment, set the payment status to 'SPOILED'.
      */
     BEGIN

	 -- looping through the entire document list
         FOR i IN l_used_docs_list.FIRST .. l_used_docs_list.LAST LOOP


   	  print_debuginfo(l_module_name, 'Payment ID : Paper Doc Num : Payment Status = ' || l_used_pmts_list(i) || ' : ' || l_used_docs_list(i) || ' : ' || l_payment_status_list(i));

	  -- only invoices for those paper_documents which are marked as spoiled are unlocked here
	  IF ( l_payment_status_list(i) = 'REMOVED_DOCUMENT_SPOILED') THEN

	     l_paper_doc_num := l_used_docs_list(i);
	     print_debuginfo(l_module_name, 'In the loop, spoiled document number : ('||i||') :' || l_used_pmts_list(i) );

             UPDATE
                 IBY_PAYMENTS_ALL
             SET
                 payment_status = PAY_STATUS_SPOILED
             WHERE
                 payment_instruction_id = p_instr_id          AND
                 payment_id   = l_used_pmts_list(i)
             ;


            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	            print_debuginfo(l_module_name, 'Finished updating payments table');
            END IF;
             UPDATE
	         IBY_DOCS_PAYABLE_ALL
             SET
                 document_status = DOC_STATUS_PMT_SPOILED
             WHERE
                  payment_id = l_used_pmts_list(i)
             ;

	      print_debuginfo(l_module_name, 'Finished updating document payable table');

            OPEN  c_docs(l_used_pmts_list(i));
            FETCH c_docs BULK COLLECT INTO l_doc_id_list, l_doc_status_list;
            CLOSE c_docs;

           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	           print_debuginfo(l_module_name, 'The number of doc ids for this '
	                                          ||'payment' ||l_doc_id_list.COUNT);

           END IF;
	   remove_documents_payable (
                     l_doc_id_list,
		     l_doc_status_list,
		     x_return_status_remove_doc
		     );
	IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		print_debuginfo(l_module_name,'Inside loop,after callling'
		|| 'remove_documents_payable');


	END IF;
	    IF (x_return_status_remove_doc <> FND_API.G_RET_STS_SUCCESS) THEN

		     /*
  		      * Even if a single call to remove a document
     		      * failed, return failure for the entire
     		      * API request.
  		      */
		     print_debuginfo(l_module_name, 'Removing of documents '
			 || 'for payment instruction id '
			 || p_instr_id
			 || ' failed.'
			 );

		     print_debuginfo(l_module_name, 'EXIT');

		     /*
  		      * It is the callers responsibility to rollback
       		      * all the changes.
       		      */
		     RETURN;

	    END IF;

	 END IF;

        END LOOP;

     EXCEPTION
         WHEN OTHERS THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Fatal: Exception occured '
	                 || 'when attempting to update payment with payment '
	                 || 'instruction id '
	                 || p_instr_id
	                 || ' and paper document number '
	                 || l_paper_doc_num
	                 );

	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);
             END IF;
             FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

             /*
              * Propogate exception to caller.
              */
             RAISE;

     END;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Finished updating payments table.');

     END IF;

   ELSE

      /*
      * STEP 1:
      *
      * Start processing the used paper documents, one-by-one.
      *
      * This API will only be called with the list of spoiled
      * paper documents, so we can set the usage reason for
      * each paper document to 'spoiled'.
      */
          FOR i IN l_used_docs_list.FIRST .. l_used_docs_list.LAST LOOP

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
             p_pmt_doc_id,
             l_used_docs_list(i),
             sysdate,
             DOC_USE_SPOILED,
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.login_id,
             1
             );

     END LOOP;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Finished updating document use table.');

     END IF;
     /*
      * STEP 2:
      *
      * Pick up all payments for this payment instruction
      * that have the given paper document number one-by-one.
      *
      * For each such payment, set the payment status to 'SPOILED'.
      */
     BEGIN

         FOR i IN l_used_docs_list.FIRST .. l_used_docs_list.LAST LOOP

             l_paper_doc_num := l_used_docs_list(i);
	      print_debuginfo(l_module_name, 'In the loop, l_used_docs_list('||
i||') :'
|| l_used_docs_list(i) );

             UPDATE
                 IBY_PAYMENTS_ALL
             SET
                 payment_status = PAY_STATUS_SPOILED
             WHERE
                 payment_instruction_id = p_instr_id          AND
                 payment_id   = l_used_docs_list(i)
             ;


            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	            print_debuginfo(l_module_name, 'Finished updating payments table');
            END IF;
             UPDATE
	         IBY_DOCS_PAYABLE_ALL
             SET
                 document_status = DOC_STATUS_PMT_SPOILED
             WHERE
                  payment_id = l_used_docs_list(i)
             ;

	      print_debuginfo(l_module_name, 'Finished updating document payable table');

            OPEN  c_docs(l_used_docs_list(i));
            FETCH c_docs BULK COLLECT INTO l_doc_id_list, l_doc_status_list;
            CLOSE c_docs;

           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	           print_debuginfo(l_module_name, 'The number of doc ids for this '
	                                          ||'payment' ||l_doc_id_list.COUNT);

           END IF;
	   remove_documents_payable (
                     l_doc_id_list,
		     l_doc_status_list,
		     x_return_status_remove_doc
		     );
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                    print_debuginfo(l_module_name,'Inside loop,after callling'
                    || 'remove_documents_payable');


            END IF;
	    IF (x_return_status_remove_doc <> FND_API.G_RET_STS_SUCCESS) THEN

		     /*
  		      * Even if a single call to remove a document
     		      * failed, return failure for the entire
     		      * API request.
  		      */
		     print_debuginfo(l_module_name, 'Removing of documents '
			 || 'for payment instruction id '
			 || p_instr_id
			 || ' failed.'
			 );

		     print_debuginfo(l_module_name, 'EXIT');

		     /*
  		      * It is the callers responsibility to rollback
       		      * all the changes.
       		      */
		     RETURN;

	    END IF;

        END LOOP;

     EXCEPTION
         WHEN OTHERS THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Fatal: Exception occured '
	                 || 'when attempting to update payment with payment '
	                 || 'instruction id '
	                 || p_instr_id
	                 || ' and paper document number '
	                 || l_paper_doc_num
	                 );

	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);
             END IF;
             FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

             /*
              * Propogate exception to caller.
              */
             RAISE;

     END;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Finished updating payments table.');

     END IF;

 END IF;

     /*
      * STEP 3:
      *
      * Invoke the hook that handles witholding certificates.
      * Every time a paper document is PRINTED | REPRINTED |
      * SPOILED, the witholding certificates should be in sync.
      */
     l_callout_name := l_pkg_name || '.' || 'zx_witholdingCertificatesHook';

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Attempting to call hook: '
	         || l_callout_name);

     END IF;
     l_stmt := 'CALL '|| l_callout_name || '(:1, :2, :3, :4, :5, :6, :7, :8)';

     BEGIN

     iby_debug_pub.log(debug_msg => 'Enter withholding pkg:'||l_callout_name||': Timestamp:'  || systimestamp,
	       debug_level => FND_LOG.LEVEL_PROCEDURE,
	       module => l_module_name);

         EXECUTE IMMEDIATE
             (l_stmt)
         USING
             IN  p_instr_id,
             IN  'SPOILED',
             IN  l_api_version,
             IN  FND_API.G_FALSE,
             IN  FND_API.G_FALSE,
             OUT l_return_status,
             OUT l_msg_count,
             OUT l_msg_data
         ;

    iby_debug_pub.log(debug_msg => 'Exit withholding pkg:'||l_callout_name||': Timestamp:'  || systimestamp,
       debug_level => FND_LOG.LEVEL_PROCEDURE,
       module => l_module_name);

         /*
          * If the called procedure did not return success,
          * raise an exception.
          */
         IF (l_return_status IS NULL OR
             l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Fatal: External app callout '''
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
	             print_debuginfo(l_module_name, 'Callout "' || l_callout_name
	                 || '" not implemented by calling app - AP'
	                 );

	             print_debuginfo(l_module_name, 'Skipping hook call.');


             END IF;
         WHEN OTHERS THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Fatal: External app callout '''
	                 || l_callout_name
	                 || ''', generated exception.'
	                 );

	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);
             END IF;
             FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

             /*
              * Propogate exception to caller.
              */
             RAISE;
     END;

ELSE

     /*
      * STATUS CHANGE:
      *
      * UI Responsibility:
      * NONE
      *
      * API Responsibility:
      * payment status = ISSUED
      * payment instruction status = PRINTED
      */

     /*
      * STEP 1:
      *
      * Derive list of paper documents associated with the payments
      * of this instruction.
      */
     OPEN  c_pmt_docs(p_instr_id);
     FETCH c_pmt_docs BULK COLLECT INTO l_pmtDocsTab;
     CLOSE c_pmt_docs;

     IF (l_pmtDocsTab.COUNT = 0) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Error: Number of '
	             || 'paper documents associated with payment instruction '
	             || p_instr_id
	             || ' is zero. '
	             || 'Returning failure response .. '
	             );

         END IF;
         l_return_status := FND_API.G_RET_STS_ERROR;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     END IF;

     /*
      * STEP 2:
      *
      * Derive the payment document id (check stock) that was used to
      * print the payments of this instruction. The payment document
      * id also needs to be inserted into the IBY_USED_PAYMENT_DOCUMENTS
      * table.
      */
     SELECT
         payment_document_id
     INTO
         l_pmt_doc_id
     FROM
         IBY_PAY_INSTRUCTIONS_ALL
     WHERE
         payment_instruction_id = p_instr_id
     ;

     IF (l_pmt_doc_id IS NULL) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Error: Could not derive '
	             || 'payment document associated with payment instruction '
	             || p_instr_id
	             || '. Returning failure response .. '
	             );

         END IF;
         l_return_status := FND_API.G_RET_STS_ERROR;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     END IF;

     /*
      * STEP 3:
      *
      * Insert the paper document numbers and the payment
      * doc id we picked up in steps (1) and (2) into the
      * IBY_USED_PAYMENT_DOCUMENTS table. Set the usage
      * reason for each paper document as 'issued'.
      */

   	MERGE
		INTO IBY_USED_PAYMENT_DOCS target
		USING (
			 SELECT pmt.paper_document_number as used_document_number
	                  FROM IBY_PAYMENTS_ALL pmt
		          WHERE
			        pmt.payment_instruction_id = p_instr_id
				AND(
					( pmt.payment_status=PAY_STATUS_FORMATTED OR
		                           pmt.payment_status=PAY_STATUS_SUB_FOR_PRINT
					 )
					OR( pmt.process_type=PROCESS_TYPE_IMMEDIATE)
				)

		)src

		on(target.payment_document_id = l_pmt_doc_id
		AND target.used_document_number= src.used_document_number
		)

		WHEN MATCHED
		THEN
			UPDATE
			SET target.DOCUMENT_USE = DOC_USE_ISSUED
		WHEN NOT MATCHED
		THEN
			INSERT(
			     target.PAYMENT_DOCUMENT_ID,
			     target.USED_DOCUMENT_NUMBER,
			     target.DATE_USED,
			     target.DOCUMENT_USE,
			     target.CREATED_BY,
			     target.CREATION_DATE,
			     target.LAST_UPDATED_BY,
			     target.LAST_UPDATE_DATE,
			     target.LAST_UPDATE_LOGIN,
			     target.OBJECT_VERSION_NUMBER
			     )
			 VALUES (
			     l_pmt_doc_id,
			     src.used_document_number,
			     sysdate,
			     DOC_USE_ISSUED,
			     fnd_global.user_id,
			     sysdate,
			     fnd_global.user_id,
			     sysdate,
			     fnd_global.login_id,
			     1
			     );
END IF;

     /*
      * STEP 4:
      *
      * Change the status of the successful payments of this instruction
      * to ISSUED status. The ISSUED status is the final status for a
      * paper payment; the payment must be in ISSUED status in order to
      * be marked complete.
      */
     UPDATE
         IBY_PAYMENTS_ALL
     SET
         payment_status = PAY_STATUS_ISSUED
     WHERE
         payment_instruction_id = p_instr_id     AND
         (
             payment_status IN
             (
             PAY_STATUS_FORMATTED,
             PAY_STATUS_SUB_FOR_PRINT
             )
             OR
             (
             process_type = PROCESS_TYPE_IMMEDIATE
             )
         )
     ;

     /*
      * STEP 5:
      *
      * Mark all the payments of the given payment instruction
      * as complete.
      */
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Attempting to mark payments of '
	         || 'payment instruction '
	         || p_instr_id
	         || ' as complete.'
	         );

     END IF;
     mark_all_pmts_complete (
         p_instr_id,
         l_submit_postive_pay,
         l_return_status
         );

     IF (l_return_status IS NULL OR
         l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Error status '
	             || l_return_status
	             || ' was received from the mark_all_pmts_complete() '
	             || 'method. Raising exception.'
	             );

         END IF;


         IF(p_used_docs_list IS NOT NULL) THEN
		 l_return_status := FND_API.G_RET_STS_ERROR;

			 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
				 print_debuginfo(l_module_name, 'EXIT');

			 END IF;
		 RETURN;
         ELSE
	  APP_EXCEPTION.RAISE_EXCEPTION;
	 END IF;

     ELSE

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Successfully maked payments '
	             || 'as complete.'
	             );

         END IF;
     END IF;

     /*
      * STEP 6:
      *
      * Change the status of the payment instruction to PRINTED.
      */
     UPDATE
         IBY_PAY_INSTRUCTIONS_ALL
     SET
         payment_instruction_status = INS_STATUS_PRINTED
     WHERE
         payment_instruction_id = p_instr_id
     ;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Successfully set payment '
	         || 'instruction status to PRINTED.'
	         );

     END IF;
     l_return_status := FND_API.G_RET_STS_SUCCESS;
     COMMIT;
                              /*
                              * The payment instruction was possibly locked
                              * by the UI. Unlock it if possible.
                              */
                             IBY_DISBURSE_UI_API_PUB_PKG.unlock_pmt_entity(
                                 p_instr_id ,
                                 'PAYMENT_INSTRUCTION',
                                 l_return_status
                                 );
     x_errbuf := 'RECORD PRINT STATUS COMPLETED SUCCESSFULLY';
     x_retcode := '0';

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Returning success response ..');

	     print_debuginfo(l_module_name, 'EXIT');

     END IF;

  iby_debug_pub.log(debug_msg => 'Exit Record Print Status : Timestamp:'  || systimestamp,
		       debug_level => FND_LOG.LEVEL_PROCEDURE,
		       module => l_module_name);
 EXCEPTION
     WHEN OTHERS THEN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Exception occured when '
	         || 'recording final print status for payment instruction '
	         || p_instr_id
	         );

	     print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	     print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);
     END IF;
     FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

     l_return_status := FND_API.G_RET_STS_ERROR;
     ROLLBACK;
      x_errbuf := 'RECORD PRINT STATUS COMPLETED IN ERRORS';
      x_retcode := '-1';
                             /*
                              * The payment instruction was possibly locked
                              * by the UI. Unlock it if possible.
                              */
                             IBY_DISBURSE_UI_API_PUB_PKG.unlock_pmt_entity(
                                 p_instr_id ,
                                 'PAYMENT_INSTRUCTION',
                                 l_return_status
                                 );

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END record_print_status;

/*--------------------------------------------------------------------
 | NAME:
 |     mark_all_pmts_complete
 |
 | PURPOSE:
 |     Marks all payments of the given payment instruction as complete.
 |
 |     This method overloads the other mark_all_pmts_complete(..)
 |     See the other method for complete documentation.
 |
 | NOTES:
 |     Internal API, not for public use.
 |
 |     This method does not COMMIT/ROLLBACK. It is the callers responsibility
 |     to COMMIT/ROLLBACK depending upon the return status.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE mark_all_pmts_complete (
     p_instr_id       IN NUMBER,
     x_return_status  OUT NOCOPY VARCHAR2
     )
 IS

 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME
                                         || '.mark_all_pmts_complete';
 BEGIN

     /*
      * Call mark_all_pmts_complete(..) with the submit
      * positive pay file report flag set to 'no' by
      * default.
      */
     mark_all_pmts_complete(p_instr_id, FALSE, x_return_status);

 END mark_all_pmts_complete;

/*--------------------------------------------------------------------
 | NAME:
 |     mark_all_pmts_complete
 |
 | PURPOSE:
 |     Marks all payments of the given payment instruction as complete.
 |     Also marks the status of the payment instruction to complete.
 |
 |     Only payments that are in 'valid' status will be marked complete,
 |     others will be left untouched. The 'valid' status for a payment
 |     is dependent upon whether it is a printed payment or an electronic
 |     payment. Here is list of valid statuses by processing type:
 |
 |     Processing     Valid statuses for payments
 |     Type
 |     ----------     ---------------------------
 |     PRINTED        ISSUED
 |
 |     ELECTRONIC     FORMATTED
 |                    TRANSMITTED
 |                    ACKNOWLEDGED
 |                    BANK_VALIDATED
 |                    PAID
 |
 |     Therefore, the caller must ensure that they set the payment
 |     status to valid status for all the payments that are to be
 |     marked complete *before* calling this API.
 |
 |     Once payments are marked as complete, the calling application
 |     hook 'payments_completed()' is invoked to inform the calling
 |     app that their payments have been marked complete.
 |
 | PARAMETERS:
 |     IN
 |       p_instr_id        - The payment instruction id for which the
 |                           payments need to be marked complete.
 |
 |       p_submit_postive_pay
 |                         - Flag indicating whether positive pay file
 |                           report needs to be launched after marking
 |                           the payments complete.
 |
 |     OUT
 |       x_return_status   - Result of the API call:
 |                           FND_API.G_RET_STS_SUCCESS indicates that
 |                           the mark complete process finished
 |                           successfully. In this case the caller must
 |                           COMMIT the status change.
 |
 |                           FND_API.G_RET_STS_ERROR (or other) indicates
 |                           that API did not complete successfully.
 |                           In this case, the caller must issue a
 |                           ROLLBACK to undo all status changes.
 |
 | RETURNS:
 |
 | NOTES:
 |     Internal API, not for public use.
 |
 |     This method does not COMMIT/ROLLBACK. It is the callers responsibility
 |     to COMMIT/ROLLBACK depending upon the return status.
 *---------------------------------------------------------------------*/
 PROCEDURE mark_all_pmts_complete (
     p_instr_id           IN NUMBER,
     p_submit_postive_pay IN BOOLEAN,
     x_return_status      OUT NOCOPY VARCHAR2
     )
 IS

 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME
                                         || '.mark_all_pmts_complete';

 l_completion_id   NUMBER(15);
 l_processing_type VARCHAR2(200);
 l_process_type    VARCHAR2(200);
 l_completion_point VARCHAR2(30);

 /* used in forming callout procedure name */
 l_calling_app_id NUMBER;
 l_app_short_name VARCHAR2(200);
 l_pkg_name       VARCHAR2(200);
 l_callout_name   VARCHAR2(500);
 l_stmt           VARCHAR2(1000);

 /* used in invocation of callout procedure */
 l_api_version    CONSTANT NUMBER := 1.0;
 l_msg_count      NUMBER;
 l_msg_data       VARCHAR2(2000);

 l_appNamesTab    appNamesTab;
 l_appIdsTab      appIdsTab;

 l_pprIdsTab      pprIdsTab;

 l_pmts_complete_code   VARCHAR2(1000);

 l_pmt_doc_id     NUMBER(15);
 l_pmt_doc_name   VARCHAR2(2000);

 l_doc_count      NUMBER(15);
 l_pmt_count      NUMBER(15);
 l_incomplete_pmts  NUMBER(15);

 /*
  * These variables are related to kicking off automatic
  * reports.
  */
 l_profile_id     IBY_PAYMENT_PROFILES.
                      payment_profile_id%TYPE;
 l_auto_pi_reg_submit_flag
                  IBY_SYS_PMT_PROFILES_B.
                      automatic_pi_reg_submit%TYPE;
 l_auto_sra_submit_flag
                  IBY_REMIT_ADVICE_SETUP.
                      automatic_sra_submit_flag%TYPE;
 l_remit_format_code
                  IBY_REMIT_ADVICE_SETUP.
                      remittance_advice_format_code%TYPE;
 l_pos_pay_format IBY_PAYMENT_PROFILES.
                      positive_pay_format_code%TYPE;
 l_pi_reg_format  IBY_SYS_PMT_PROFILES_B.
                      pi_register_format%TYPE;


 l_conc_req_id    NUMBER(15);

 l_icx_numeric_characters   VARCHAR2(30); -- Bug 6411356
 l_bool_val   boolean;  -- Bug 6411356

 l_error_code     IBY_TRANSACTION_ERRORS.error_code%TYPE;
 /*
  * Cursor to pick up all the distinct PPR ids for the set
  * of payments which are with this instruction.
  *
  * Added for bug 7505803
  *
  */
  CURSOR c_ppr_ids (p_instr_id NUMBER)
  IS
  SELECT DISTINCT
         PMT.PAYMENT_SERVICE_REQUEST_ID
  FROM IBY_PAYMENTS_ALL PMT
  WHERE PMT.PAYMENT_INSTRUCTION_ID = p_instr_id;


 /*
  * Cursor to pick up all calling applications associated
  * with a particular payment instruction.
  */

 /*
  * Fix for bug 4901075.
  *
  * Added distinct clause to select statement so that duplicate
  * calling app ids are eliminated.
  *
  * Otherwise, the call out could be invoked multiple times
  * per calling app.
  */
 CURSOR c_app_names (p_instr_id NUMBER)
 IS
 SELECT DISTINCT
     fnd.application_short_name
 INTO
     l_app_short_name
 FROM
     FND_APPLICATION          fnd,
     IBY_PAYMENTS_ALL         pmt,
     IBY_PAY_SERVICE_REQUESTS req,
     IBY_PAY_INSTRUCTIONS_ALL ins
 WHERE
     pmt.payment_instruction_id     = ins.payment_instruction_id     AND
     req.payment_service_request_id = pmt.payment_service_request_id AND
     fnd.application_id             = req.calling_app_id             AND
     ins.payment_instruction_id     = p_instr_id
 ;

 /*
  * Cursor to pick up ids all calling applications
  * associated with a particular payment instruction.
  */
 CURSOR c_app_ids (p_instr_id NUMBER)
 IS
 SELECT
     fnd.application_id
 FROM
     FND_APPLICATION          fnd,
     IBY_PAYMENTS_ALL         pmt,
     IBY_PAY_SERVICE_REQUESTS req,
     IBY_PAY_INSTRUCTIONS_ALL ins
 WHERE
     pmt.payment_instruction_id     = ins.payment_instruction_id     AND
     req.payment_service_request_id = pmt.payment_service_request_id AND
     fnd.application_id             = req.calling_app_id             AND
     ins.payment_instruction_id     = p_instr_id
 ;

 /* EFT Paper Document Generation Begin*/
 /*Bug 9376894*/
 /*CURSOR c_pmt_docs (p_instr_id NUMBER)
 IS
 SELECT
     pmt.paper_document_number
 FROM
     IBY_PAYMENTS_ALL pmt
 WHERE
     pmt.payment_instruction_id = p_instr_id    AND
     pmt.payment_status         = PAY_STATUS_FORMATTED;*/

/* EFT Paper Document Generation End */



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
     FND_MSG_PUB.initialize;

      iby_debug_pub.log(debug_msg => 'Enter Mark Complete: Timestamp:'  || systimestamp,
		       debug_level => FND_LOG.LEVEL_PROCEDURE,
		       module => l_module_name);

     /*
      * STEP 0 :
      *
      * Set the apps context. This is necessary so that
      * the calling application can see the org based
      * tables associated with these payments.
      *
      * See bugs 9229224, 4945922.
      */

     /*IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             print_debuginfo(l_module_name, 'Setting apps context .. ');
     END IF;

     fnd_global.APPS_INITIALIZE(
         user_id      => fnd_global.user_id,
         resp_id      => fnd_global.resp_id,
         resp_appl_id => fnd_global.resp_appl_id
         );

     mo_global.init(fnd_global.application_short_name);

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             print_debuginfo(l_module_name, 'Apps context set [user: '
                 || fnd_global.user_id
                 || ', responsbility id: '
                 || fnd_global.resp_id
                 || ', responsibility application id: '
                 || fnd_global.resp_appl_id
                 || ']'
                 );

             print_debuginfo(l_module_name, 'Apps context [app short name: '
                 || fnd_global.application_short_name
                 || ']'
                 );
     END IF;*/


     /*
      * STEP I:
      *
      * Get the processing type of this payment instruction.
      * The processing type is used as a criterion in selecting
      * which payments of this payment instruction are updated
      * to completed status.
      */
      -- Bug: 9851821
      -- Introduced row level locking for instructions
      -- This will ensure multiple checks are not made for the
      -- same instruction
     SELECT
         prof.processing_type,
         inst.payments_complete_code,
         inst.process_type
     INTO
         l_processing_type,
         l_pmts_complete_code,
         l_process_type
     FROM
         IBY_PAYMENT_PROFILES     prof,
         IBY_PAY_INSTRUCTIONS_ALL inst
     WHERE
         prof.payment_profile_id     = inst.payment_profile_id  AND
         inst.payment_instruction_id = p_instr_id
     FOR UPDATE OF inst.payment_instruction_id NOWAIT ;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'For payment instruction '
	         || p_instr_id
	         || ', payment complete code: '
	         || l_pmts_complete_code
	         || ' and process type: '
	         || l_process_type
	         );

     END IF;
     /*
      * STEP II:
      *
      * Check whether we need to mark payments complete
      * for the payments of this payment instruction.
      *
      * Payments should be marked complete should be called
      * *except* when:
      *
      * A. The payments of this payment instruction have already
      * been marked complete.
      */
     IF (UPPER(l_pmts_complete_code) = 'YES') THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Not performing mark pmts '
	             || 'complete for payment instruction '
	             || p_instr_id
	             || ' because payments already marked complete '
	             || 'for this instruction.'
	             );

         END IF;
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning success response ..');

	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN;

     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Processing type of payment instruction '
	         || p_instr_id
	         || ' is '
	         || l_processing_type
	         );

     END IF;
     /*
      * STEP III:
      *
      * Mark all payments of this payment instruction as
      * completed.
      */
     IF (l_processing_type = P_TYPE_PRINTED) THEN

         UPDATE
             IBY_PAYMENTS_ALL
         SET
             payments_complete_flag = 'Y'
         WHERE
             payment_instruction_id = p_instr_id
	 AND payment_status         = PAY_STATUS_ISSUED
         ;

     ELSE

         /* electronic processing type */
	 l_completion_point := IBY_DISBURSE_UI_API_PUB_PKG.Get_Pmt_Completion_Point(p_instr_id);

         IF (l_process_type <> PROCESS_TYPE_IMMEDIATE) THEN

             /* batch payment(s) */

             UPDATE
                 IBY_PAYMENTS_ALL
             SET
                 payments_complete_flag = 'Y'
             WHERE
                 payment_instruction_id = p_instr_id
	     AND (payment_status IN
                     (
                     PAY_STATUS_FORMATTED,
                     PAY_STATUS_TRANSMITTED,
                     PAY_STATUS_ACK,
                     PAY_STATUS_BNK_VALID,
                     PAY_STATUS_PAID
                     )
	          OR
	          (payment_status = PAY_STATUS_INS_CREAT AND l_completion_point ='CREATED')
	         )
             ;

         ELSE

             /* quick/single payment */

             /*
              * The Post-PICP program is responsible for
              * setting the payment status to FORMATTED /
              * TRANSMITTED for electronic payments.
              *
              * However, when mark_all_payments(..) is called
              * for single payments, the Post-PICP would have
              * not yet executed (because it runs as a separate
              * conc program). Therefore, we set the payment
              * complete flag to 'Y' here even through the
              * payment is not technically complete.
              *
              * This special handling is applicable only to
              * single payments.
              */

             /*
              * Fix for bug 5179474:
              *
              * The PICP will now set the payment status to
              * FORMATTED without waiting for the Post-PICP
              * to complete.
              *
              * Reason for this change is so that the payment
              * status and the payment complete flag are in
              * sync (as in batch payments scenario).
              *
              * Therefore, mark the payment complete if the
              * payment status is FORMATTED.
              */

	     l_completion_point := IBY_DISBURSE_UI_API_PUB_PKG.Get_Pmt_Completion_Point(p_instr_id);

             UPDATE
                 IBY_PAYMENTS_ALL
             SET
                 payments_complete_flag = 'Y'
             WHERE
                 payment_instruction_id = p_instr_id
	     AND (payment_status IN
                     (
                     PAY_STATUS_FORMATTED
                     )
	          OR
	          (payment_status = PAY_STATUS_INS_CREAT AND l_completion_point ='CREATED')
	         )
             ;

         END IF;

     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Finished marking payments of '
	         || 'payment instruction '
	         || p_instr_id
	         || ' as complete.'
	         );

     END IF;
     /*
      * STEP IV:
      *
      * Get the 'process type' if this payment instruction.
      *
      * If this payment instruction has been created as part
      * of single payments flow, the process type will be
      * IMMEDIATE, else it will be STANDARD.
      *
      * We need to know the process type because we should not be
      * invoking the callout for quick payments (as these are
      * automatically marked as complete by AP).
      */

     /*
      * Fix for bug 4923416.
      *
      * Get the process type from the payment instruction itself
      * instead of deriving it from the payments of the instruction.
      */
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Process type for pmt instruction '
	         || p_instr_id
	         || ' is '
	         || l_process_type
	         );

     END IF;
     /*
      * STEP V:
      *
      * Mark the given payment instruction as completed.
      */

     UPDATE
         IBY_PAY_INSTRUCTIONS_ALL
     SET
         payments_complete_code = PMT_COMPLETE_YES
     WHERE
         payment_instruction_id = p_instr_id
     ;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Finished marking payment instruction '
	         || p_instr_id
	         || ' as complete.'
	         );

     END IF;
     /*
      * Pick up the names of all the applications which have
      * payments in the current payment instruction.
      *
      * Remember, one payment instruction can contain payments
      * across multiple calling applications.
      */
     OPEN  c_app_names (p_instr_id);
     FETCH c_app_names BULK COLLECT INTO l_appNamesTab;
     CLOSE c_app_names;

     /*
      * Pick up the ids of all the applications which have
      * payments in the current payment instruction.
      *
      * Remember, one payment instruction can contain payments
      * across multiple calling applications.
      */
     OPEN  c_app_ids (p_instr_id);
     FETCH c_app_ids BULK COLLECT INTO l_appIdsTab;
     CLOSE c_app_ids;

     /*
      * STEP VI:
      *
      * Loop through all the application names, invoking the
      * callout of each application.
      */
     FOR i IN l_appNamesTab.FIRST .. l_appNamesTab.LAST LOOP

         /*
          * Get the constructed package name to use in the
          * call out.
          */
         l_pkg_name := construct_callout_pkg_name(l_appNamesTab(i));

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Constructed package name: '
	             || l_pkg_name);

         END IF;
         IF (l_pkg_name IS NULL) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Package name is null. '
	                 || 'Raising exception.');

             END IF;
             APP_EXCEPTION.RAISE_EXCEPTION;

         END IF;


         /*
          * Get the next available completed payments group id.
          */
         SELECT
             IBY_COMPLETED_PMTS_GROUP_S.NEXTVAL
         INTO
             l_completion_id
         FROM
             DUAL
         ;

         /*
          * Update the completed payments for this calling app
          * with the completed document group id. The calling
          * application will identify completed documents using
          * this id.
          */
         IF (l_processing_type = P_TYPE_PRINTED) THEN

             UPDATE
                 IBY_PAYMENTS_ALL     pmt
             SET
                 pmt.completed_pmts_group_id = l_completion_id
             WHERE
                 pmt.payment_instruction_id = p_instr_id         AND
                 pmt.payments_complete_flag = 'Y'                AND
                 payment_status             = PAY_STATUS_ISSUED  AND
                 pmt.payment_id IN
                     (SELECT
                          doc.payment_id
                      FROM
                          IBY_DOCS_PAYABLE_ALL doc
                      WHERE
                          doc.payment_id     = pmt.payment_id AND
                          doc.calling_app_id = l_appIdsTab(i)
                      )
             ;

         ELSE

	     l_completion_point := IBY_DISBURSE_UI_API_PUB_PKG.Get_Pmt_Completion_Point(p_instr_id);

             UPDATE
                 IBY_PAYMENTS_ALL     pmt
             SET
                 pmt.completed_pmts_group_id = l_completion_id
             WHERE
                 pmt.payment_instruction_id = p_instr_id         AND
                 pmt.payments_complete_flag = 'Y'                AND
                 (payment_status IN
                     (
                     PAY_STATUS_FORMATTED,
                     PAY_STATUS_TRANSMITTED,
                     PAY_STATUS_ACK,
                     PAY_STATUS_BNK_VALID,
                     PAY_STATUS_PAID
                     )
	          OR
	          (payment_status = PAY_STATUS_INS_CREAT AND l_completion_point ='CREATED')
	         )
		 AND pmt.payment_id IN
                     (SELECT
                          doc.payment_id
                      FROM
                          IBY_DOCS_PAYABLE_ALL doc
                      WHERE
                          doc.payment_id     = pmt.payment_id AND
                          doc.calling_app_id = l_appIdsTab(i)
                      )
             ;

         END IF;

         /*
          * DEBUG PRINT FOR PAYMENTS
          *
          * Print list of payments marked complete. This is
          * very important for debugging AP-IBY boundry issues.
          */
         IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               print_completed_pmts(l_completion_id);
         END IF;

         /*
          * Update the documents of the completed payments with
          * the completed document group id. This will allow the
          * calling app to select the completed documents directly
          * if they so wish.
          */
         UPDATE
             IBY_DOCS_PAYABLE_ALL doc
         SET
             doc.completed_pmts_group_id = l_completion_id
         WHERE
             doc.document_status <> 'REMOVED' AND /* Bug 6388935- removed
document handling */
             doc.payment_id IN
                 (SELECT
                      pmt.payment_id
                  FROM
                      IBY_PAYMENTS_ALL pmt
                  WHERE
                      pmt.completed_pmts_group_id = l_completion_id
                  )
         ;

         /*
          * DEBUG PRINT FOR DOCUMENTS
          *
          * Print list of documents payable marked complete. This is
          * very important for debugging AP-IBY boundry issues.
          */
         IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               print_completed_docs(l_completion_id);
         END IF;

         /*
          * For single payments, do not invoke the callout because
          * single payments are automatically confirmed by AP.
          *
          * Only invoke callout where process type is not immediate.
          */
         IF (l_process_type <> PROCESS_TYPE_IMMEDIATE) THEN

             /*
              * Now try to call the external app's implementation of the hook.
              * The calling app may or may not have implemented the hook, so
              * it's not fatal if the implementation does not exist.
              */
             l_callout_name := l_pkg_name || '.' || 'payments_completed';

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Attempting to invoke callout: '
	                 || l_callout_name, FND_LOG.LEVEL_UNEXPECTED);

             END IF;
             SELECT
                 count(*)
             INTO
                 l_pmt_count
             FROM
                 IBY_PAYMENTS_ALL pmt
             WHERE
                 pmt.completed_pmts_group_id = l_completion_id
             ;

             SELECT
                 count(*)
             INTO
                 l_doc_count
             FROM
                 IBY_DOCS_PAYABLE_ALL doc
             WHERE
                 doc.completed_pmts_group_id = l_completion_id
             ;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Params passed to callout - '
	                 || 'completed pmts group id: '
	                 || l_completion_id,
	                 FND_LOG.LEVEL_UNEXPECTED
	                 );

	             print_debuginfo(l_module_name, 'Params not passed to callout - '
	                 || 'completed pmts count: '
	                 || l_pmt_count
	                 || ', completed docs count: '
	                 || l_doc_count
	                 );

             END IF;
             l_stmt := 'CALL '|| l_callout_name
                              || '(:1, :2, :3, :4, :5, :6, :7)';

             BEGIN

		  iby_debug_pub.log(debug_msg => 'Enter Callout pkg:'||l_callout_name||': Timestamp:'  || systimestamp,
		       debug_level => FND_LOG.LEVEL_PROCEDURE,
		       module => l_module_name);

                 EXECUTE IMMEDIATE
                     (l_stmt)
                 USING
                     IN  l_api_version,
                     IN  FND_API.G_FALSE,
                     IN  FND_API.G_FALSE,
                     OUT x_return_status,
                     OUT l_msg_count,
                     OUT l_msg_data,
                     IN  l_completion_id
                 ;

		  iby_debug_pub.log(debug_msg => 'Exit Callout pkg:'||l_callout_name||': Timestamp:'  || systimestamp,
		       debug_level => FND_LOG.LEVEL_PROCEDURE,
		       module => l_module_name);


                 /*
                  * If the called procedure did not return success,
                  * raise an exception.
                  */
                 IF (x_return_status IS NULL OR
                     x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

                     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                     print_debuginfo(l_module_name, 'Fatal: External app '
	                         || 'callout '''
	                         || l_callout_name
	                         || ''', returned failure status - '
	                         || x_return_status
	                         || '. Raising exception.',
	                         FND_LOG.LEVEL_UNEXPECTED
	                         );

                     END IF;
                     APP_EXCEPTION.RAISE_EXCEPTION;

                 END IF;

             EXCEPTION

                 WHEN PROCEDURE_NOT_IMPLEMENTED THEN
                     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                     print_debuginfo(l_module_name, 'Callout "'
	                         || l_callout_name
	                         || '" not implemented by calling app '
	                         || l_app_short_name || '.');

	                     print_debuginfo(l_module_name, 'Skipping hook call.');

                     END IF;
                 WHEN OTHERS THEN
                     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                     print_debuginfo(l_module_name, 'Fatal: External app '
	                         || 'callout '''
	                         || l_callout_name
	                         || ''', generated exception.',
	                         FND_LOG.LEVEL_UNEXPECTED
	                         );

	                     print_debuginfo(l_module_name, 'SQL code: '
	                         || SQLCODE, FND_LOG.LEVEL_UNEXPECTED);
	                     print_debuginfo(l_module_name, 'SQL err msg: '
	                         || SQLERRM, FND_LOG.LEVEL_UNEXPECTED);

                     END IF;
                     /*
                      * Fix for bug 5608142:
                      *
                      * When mark complete API fails, it is most likely
                      * because document sequencing has not been setup
                      * correctly.
                      *
                      * Populate a message on the message stack so that
                      * this message can be displayed to the user.
                      */
                     l_error_code := 'IBY_COMPL_CALLOUT_ERROR';
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

                     /*
                      * Set the error message on the concurrent
                      * program output file (to warn user that
                      * the hook failed).
                      */
                     FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.GET);

                     --FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

                     /*
                      * Propogate exception to caller.
                      */
                     RAISE;

             END;

         ELSE

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Not attempting to invoke callout '
	                 || 'because this is a single payment.');

             END IF;
         END IF;

     END LOOP;

     /* Added for Bug: 7505803
      * New Status "COMPLETED" is added for Payment process Request.
      * Step VI (A):
      *
      * Mark Payment Process Requests as complete if all the payments that are not
      * rejected, removed are marked as complete.
      *
      * Get the list of PPRs whose payments are paid with this instruction and
      * find the list of PPRs for which all the payments are marked as complete.
      *
      * Note: An instruction may consists of payments belonging to different payment
      * process requests.
      *
      */

     /*
      * Pick up the distinct ppr ids for the
      * payments in the current payment instruction.
      *
      * Remember, one payment instruction can contain payments
      * across multiple PPRs.
      */
     OPEN  c_ppr_ids (p_instr_id);
     FETCH c_ppr_ids BULK COLLECT INTO l_pprIdsTab;
     CLOSE c_ppr_ids;


  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	  print_debuginfo(l_module_name, 'Changing Status of PPR to COMPLETED');

  END IF;
     /*
      * Loop through all the pprIds, to check whether all the payments
      * of that PPR are marked as complete.
      */
     FOR i IN l_pprIdsTab.FIRST .. l_pprIdsTab.LAST LOOP
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'PPR ID::'||l_pprIdsTab(i));
     END IF;
         select count(*)
         into l_incomplete_pmts
         from iby_payments_all where
         payment_service_request_id = l_pprIdsTab(i)
         and payments_complete_flag = 'N'
         and payment_status not in
                                   ('REMOVED_INSTRUCTION_TERMINATED',
                                    'REMOVED',
                                    'REMOVED_PAYMENT_STOPPED',
                                    'REMOVED_DOCUMENT_SPOILED',
                                    'REJECTED',
                                    'FAILED_BY_CALLING_APP',
                                    'FAILED_BY_REJECTION_LEVEL',
                                    'FAILED_VALIDATION',
                                    'INSTRUCTION_FAILED_VALIDATION',
                                    'REMOVED_DOCUMENT_SKIPPED');

        if l_incomplete_pmts = 0 then
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo(l_module_name, 'Changing Status of PPR ::'||l_pprIdsTab(i)||' as COMPLETED');
        END IF;
        update iby_pay_service_requests
        set payment_service_request_status = REQ_STATUS_COMPLETED
        where payment_service_request_id = l_pprIdsTab(i);
        end if;

     END LOOP;
     /*
      * Step VII:
      *
      * Unlock the payment document that has been locked by this payment
      * instruction.
      */

     /*
      * For single payments, the payment document is not locked.
      * Consequently, there is no need to unlock it either.
      */
     IF (l_process_type <> PROCESS_TYPE_IMMEDIATE) THEN

         IF (l_processing_type = P_TYPE_PRINTED OR l_processing_type = P_TYPE_ELECTRONIC) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Unlocking payment document '
	                 || 'locked by payment instruction '
	                 || p_instr_id
	             );

             END IF;
             BEGIN
	       iby_debug_pub.log(debug_msg => 'Enter Paper Document Numbering: Timestamp:'  || systimestamp,
		       debug_level => FND_LOG.LEVEL_PROCEDURE,
		       module => l_module_name);

                /* EFT Paper DOCUMENT NUMBER BEGIN*/
                /* Bug 9376894*/
                 IF(l_processing_type = p_type_electronic) THEN

                   SELECT payment_document_id
                   INTO l_pmt_doc_id
                   FROM iby_pay_instructions_all
                   WHERE payment_instruction_id = p_instr_id;

                   IF(l_pmt_doc_id is not null) THEN

                      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Processing Type for Payment Instuction '
	                   || p_instr_id ||' is '||p_type_electronic||
                           ' and Payment document ID is ' ||l_pmt_doc_id
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
                           (SELECT l_pmt_doc_id PAYMENT_DOCUMENT_ID,
                                   paper_document_number USED_DOCUMENT_NUMBER,
                                   sysdate DATE_USED,
                                   PAY_STATUS_ISSUED DOCUMENT_USE,
                                   fnd_global.user_id CREATED_BY,
                                   sysdate CREATION_DATE,
                                   fnd_global.user_id LAST_UPDATED_BY,
                                   sysdate LAST_UPDATE_DATE,
                                   fnd_global.login_id LAST_UPDATE_LOGIN,
                                   1 OBJECT_VERSION_NUMBER
                            FROM iby_payments_all
                            WHERE payment_instruction_id = p_instr_id AND
                            payment_status = PAY_STATUS_FORMATTED AND paper_document_number is not null);
                   END IF;

                 END IF;

                 /* EFT DOCUMENT NUMBER END*/
		 iby_debug_pub.log(debug_msg => 'Exit Paper Document Numbering: Timestamp:'  || systimestamp,
		       debug_level => FND_LOG.LEVEL_PROCEDURE,
		       module => l_module_name);
                 UPDATE
                     CE_PAYMENT_DOCUMENTS
                 SET
                     payment_instruction_id = NULL,
		     /* Bug 6707369
		      * If some of the documents are skipped, the payment
		      * document's last issued check number must be updated
		      */
		     last_issued_document_number = nvl(
		     (SELECT MAX(pmt.paper_document_number)
		      FROM iby_payments_all pmt
		      WHERE pmt.payment_instruction_id = p_instr_id)
		      ,last_issued_document_number
		      )
                 WHERE
                     payment_instruction_id = p_instr_id
                 RETURNING
                     payment_document_id,
                     payment_document_name
                 INTO
                     l_pmt_doc_id,
                     l_pmt_doc_name
                 ;

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Payment document id '
	                     || ''''
	                     || l_pmt_doc_id
	                     || ''''
	                     || ' with name '
	                     || ''''
	                     || l_pmt_doc_name
	                     || ''''
	                     || ' unlocked successfully.'
	                     );

                 END IF;
             EXCEPTION
                 WHEN OTHERS THEN

                 /*
                  * This is a non-fatal exception. We will log the exception
                  * and return.
                  */
                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Non-Fatal: Exception occured '
	                     || 'when unlocking pmt document locked by pmt instruction '
	                     || p_instr_id
	                     );

	                 print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	                 print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);

                 END IF;
             END;

         /*ELSE

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Not attempting to unlock '
	                 || 'payment document because this is an electronic '
	                 || 'instruction'
	                 );

             END IF;*/
         END IF; -- if processing type = PRINTED OR Electronic

     ELSE

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Not attempting to unlock '
	             || 'payment document because this is a single '
	             || 'payment (payment document was never locked)'
	             );

         END IF;
     END IF; -- process type <> IMMEDIATE

     /*
      * Step VIII:
      *
      * Invoke payment related reports if necessary.
      *
      * These reports are:
      *   + Final payment instruction register
      *   + Separate remittance advice report
      */

    --Bug 6411356
    --below code added to set the current nls character setting
    --before submitting a child requests.
    fnd_profile.get('ICX_NUMERIC_CHARACTERS',l_icx_numeric_characters);

     /*
      *
      * Get the profile id for this payment instruction
      * along with the report related settings.
      */
     SELECT
         prof.payment_profile_id,
         prof.positive_pay_format_code,
         sys_prof.automatic_pi_reg_submit,
         sys_prof.pi_register_format,
         remit.automatic_sra_submit_flag,
         remit.remittance_advice_format_code
     INTO
         l_profile_id,
         l_pos_pay_format,
         l_auto_pi_reg_submit_flag,
         l_pi_reg_format,
         l_auto_sra_submit_flag,
         l_remit_format_code
     FROM
         IBY_PAYMENT_PROFILES     prof,
         IBY_SYS_PMT_PROFILES_B   sys_prof,
         IBY_PAY_INSTRUCTIONS_ALL inst,
         IBY_REMIT_ADVICE_SETUP   remit
     WHERE
         prof.payment_profile_id      = inst.payment_profile_id   AND
         sys_prof.system_profile_code = prof.system_profile_code  AND
         remit.system_profile_code    = prof.system_profile_code  AND
         inst.payment_instruction_id  = p_instr_id;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'For payment instruction '
	         || p_instr_id
	         || ', profile id: '
	         || l_profile_id
	         || ', auto pi register submit flag: '
	         || l_auto_pi_reg_submit_flag
	         || ', pi register format: '
	         || l_pi_reg_format
	         || ', auto remit advice submit flag: '
	         || l_auto_sra_submit_flag
	         || ', remittance advice format: '
	         || l_remit_format_code
	         || ', positive pay format: '
	         || l_pos_pay_format
	         );

     END IF;
     /*
      * Launch the Final Payment Instruction Register report.
      */

     /*
      * Fix for bug 5732799:
      *
      * Pass the payment instruction register format as a
      * param when launching the payment instruction register
      * report.
      */
     IF (UPPER(l_auto_pi_reg_submit_flag) = 'Y' AND
         l_pi_reg_format IS NOT NULL) THEN

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
         l_bool_val := FND_REQUEST.SET_OPTIONS(
                           numeric_characters => l_icx_numeric_characters
                           );

         l_conc_req_id := FND_REQUEST.SUBMIT_REQUEST(
                             'IBY',
                             'IBY_FD_FINAL_PMT_REGISTER',
                             '',
                             '',
                             FALSE,
                             ''||p_instr_id||'',
                             ''||l_pi_reg_format||'',
                             '', '', '', '', '', '', '', '', '',
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
	             print_debuginfo(l_module_name, 'Request to launch payment '
	                 || 'instruction register report concurrent program failed.');
             END IF;
             APP_EXCEPTION.RAISE_EXCEPTION;

         ELSE

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Payment instruction register '
	                 || 'report was launched successfully. '
	                 || 'Check concurrent request id :'
	                 || to_char(l_conc_req_id)
	                 );

             END IF;
         END IF;

     END IF;

     /*
      * Launch the Separate Remittance Advice report.
      */
     IF (UPPER(l_auto_sra_submit_flag) = 'Y') THEN

         l_bool_val := FND_REQUEST.SET_OPTIONS(
                           numeric_characters => l_icx_numeric_characters
                           );

         l_conc_req_id := FND_REQUEST.SUBMIT_REQUEST(
                             'IBY',
                             'IBY_FD_SRA_FORMAT',
                             '',
                             '',
                             FALSE,
                             ''||p_instr_id||'','','',
                             ''||l_remit_format_code||'',
                             '', '', '', '', '', '', '', '', '',
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
	             print_debuginfo(l_module_name, 'Request to launch separate '
	                 || 'remittance advice report concurrent program failed.');
             END IF;
             APP_EXCEPTION.RAISE_EXCEPTION;

         ELSE

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Separate remittance advice '
	                 || 'report was launched successfully. '
	                 || 'Check concurrent request id :'
	                 || to_char(l_conc_req_id)
	                 );

             END IF;
         END IF;

     END IF;


     /*
      * Launch the Positive Pay program.
      */
     IF (p_submit_postive_pay = TRUE AND l_pos_pay_format IS NOT NULL) THEN

         l_bool_val := FND_REQUEST.SET_OPTIONS(
                           numeric_characters => l_icx_numeric_characters
                           );

         l_conc_req_id := FND_REQUEST.SUBMIT_REQUEST(
                             'IBY',
                             'IBY_FD_POS_PAY_FORMAT',
                             '',
                             '',
                             FALSE,

                             '', -- do not supply profile
                             '', -- do not supply from pmt date
                             '', -- do not supply to pmt date
                             ''||p_instr_id||'',

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
	             print_debuginfo(l_module_name, 'Request to launch positive '
	                 || 'pay concurrent program failed.');
             END IF;
             APP_EXCEPTION.RAISE_EXCEPTION;

         ELSE

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Positive pay '
	                 || 'program was launched successfully. '
	                 || 'Check concurrent request id :'
	                 || to_char(l_conc_req_id)
	                 );

             END IF;
         END IF;

     ELSE

         /*
          * In case we did not launch the positive pay
          * program, mention why.
          */
         IF (p_submit_postive_pay = FALSE) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Positive pay '
	                 || 'program not launched because submit '
	                 || 'positive pay flag was not set.'
	                 );

             END IF;
         ELSE

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Positive pay '
	                 || 'program not launched because positive '
	                 || 'pay format was not set on profile id '
	                 || l_profile_id
	                 );

             END IF;
         END IF;

     END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Returning success response ..');

	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 EXCEPTION

     WHEN OTHERS THEN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Exception occured when '
	         || 'marking payments complete for payment instruction '
	         || p_instr_id
	         );

	     print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	     print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);
     END IF;
    -- FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

     x_return_status := FND_API.G_RET_STS_ERROR;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END mark_all_pmts_complete;

/*--------------------------------------------------------------------
 | NAME:
 |     transmit_pmt_instruction
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
 |     Internal API, not for public use.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE transmit_pmt_instruction (
     p_instr_id         IN NUMBER,
     p_trans_status     IN VARCHAR2,
     p_error_code       IN VARCHAR2,
     p_error_msg        IN VARCHAR2,
     x_return_status    OUT NOCOPY VARCHAR2
     )
 IS

 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME
                                         || '.transmit_pmt_instruction';

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');
     END IF;
     FND_MSG_PUB.initialize;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Update payment transaction statuses (instruction, payments, etc.)
     IBY_FD_POST_PICP_PROGS_PVT.Post_Results(
         p_instr_id,
         p_trans_status,
         'N',
         x_return_status
         );

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Return status from Post_Results(..): '
	         || x_return_status
	         );

     END IF;
     if p_trans_status = 'TRANSMISSION_FAILED' then
        IBY_FD_POST_PICP_PROGS_PVT.Insert_Transmission_Error(p_instr_id,
                                                             p_error_code,
                                                             p_error_msg);
     end if;

     IF (x_return_status IS NULL OR
         x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning error response: '
	             || x_return_status
	             );
         END IF;
     ELSE
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning success response ..');
         END IF;
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 EXCEPTION
     WHEN OTHERS THEN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Exception occured when '
	         || 'performing transmit for payment instruction '
	         || p_instr_id
	         );

	     print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	     print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);
     END IF;
     FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

     x_return_status := FND_API.G_RET_STS_ERROR;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END transmit_pmt_instruction;

/*--------------------------------------------------------------------
 | NAME:
 |     construct_callout_pkg_name
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
 FUNCTION construct_callout_pkg_name (
     p_app_short_name IN VARCHAR2
     ) RETURN VARCHAR2
 IS

 l_pkg_prefix    VARCHAR2(100);
 l_pkg_suffix    VARCHAR2(100) := '_PMT_CALLOUT_PKG';
 l_pkg_name      VARCHAR2(200);

 l_module_name   CONSTANT VARCHAR2(200)  := G_PKG_NAME ||
                                            '.construct_callout_pkg_name';

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');
	     print_debuginfo(l_module_name, 'Provided app short name: '
	         || p_app_short_name);

     END IF;
     IF (p_app_short_name IS NULL) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'No app short name provided. '
	             || 'Returning null ..'
	         );

	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN NULL;

     END IF;

     /*
      * When we invoke the hook procedure in the external app,
      * we must use the hook signature as <package name>.<procedure name>.
      *
      * For some applications, the application short name cannot
      * be directly used in forming the package name.
      *
      * Example, for AP, the application short name is 'SQLAP',
      * but the AP packages begin as 'AP_XXXX'. Therefore,
      * we will convert the application short names into package
      * prefixes here.
      */
     CASE p_app_short_name
         WHEN 'SQLAP' THEN
             l_pkg_prefix := 'AP';
         ELSE
             l_pkg_prefix := p_app_short_name;
     END CASE;

     l_pkg_name := l_pkg_prefix || l_pkg_suffix;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Constructed package name: '
	         || l_pkg_name);

	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
     RETURN l_pkg_name;

 END construct_callout_pkg_name;

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
 | NAME:  get_message_text
 |
 |
 | PURPOSE:  This function will return the transalated message text
 |           for validation errors stored in iby_transaction_errors
 |           This function should be used from the UI pages.
 |
 | PARAMETERS:
 |     IN  p_transaction_error_id - Transaction error id for the error
 |     IN  p_error_code           - Error code.  This paramester is required
 |                                  so that the function does not hit the
 |                                  iby_transaction_errors table again.
 |
 | RETURNS: translated message_text
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 FUNCTION get_message_text (p_transaction_error_id IN NUMBER,
                            p_error_code           IN VARCHAR2)
 RETURN VARCHAR2 AS
  l_error_mes   varchar2(4000);

  TYPE l_token_info_rec IS RECORD(
    token_name          iby_trxn_error_tokens.token_name%TYPE,
    token_value         iby_trxn_error_tokens.token_value%TYPE,
    lookup_type_source  iby_trxn_error_tokens.lookup_type_source%TYPE,
    meaning             fnd_lookups.meaning%TYPE);

  TYPE l_token_info_tab IS TABLE OF l_token_info_rec;

  l_token_info  l_token_info_tab;

  CURSOR token_info(c_trxn_error_id IN iby_transaction_errors.transaction_error_id%TYPE) IS
  SELECT t.token_name, t.token_value, t.lookup_type_source, l.meaning
    FROM iby_trxn_error_tokens t, fnd_lookups l
   WHERE t.transaction_error_id = (c_trxn_error_id)
     AND t.lookup_type_source = l.lookup_type(+)
     AND t.token_value = l.lookup_code(+);

 BEGIN

   IF (p_transaction_error_id IS NOT NULL AND
       p_error_code IS NOT NULL) THEN

     FND_MESSAGE.SET_NAME('IBY', p_error_code);

     -- get token info if any.
     BEGIN
       OPEN token_info(p_transaction_error_id);
       FETCH token_info
       BULK COLLECT INTO l_token_info;
       CLOSE token_info;
     EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
     END;

     IF (l_token_info.COUNT > 0) THEN
       FOR j IN l_token_info.FIRST..l_token_info.LAST LOOP
         IF (l_token_info(j).lookup_type_source IS NULL) THEN
           FND_MESSAGE.SET_TOKEN(l_token_info(j).token_name, l_token_info(j).token_value);
         ELSE
           FND_MESSAGE.SET_TOKEN(l_token_info(j).token_name, l_token_info(j).meaning);
         END IF;

       END LOOP;
     END IF;

   END IF;

   l_error_mes := FND_MESSAGE.GET;
   RETURN  l_error_mes;

 END get_message_text;

/*--------------------------------------------------------------------
 | NAME:  get_message_list
 |
 |
 | PURPOSE:  This function will return the transalated message text
 |           for validation errors stored in iby_transaction_errors for an
 |           specific transaction.  This function will return the list of
 |           messages in html format.
 |           This function should be used from the UI pages.
 |
 | PARAMETERS:
 |     IN  p_transaction_id   - Transaction id (instruction, payment or document id)
 |     IN  p_transaction_type - Transaction type.
 |                              (PAYMENT, PAYMENT INSTRUCTION, etc.)
 |
 | RETURNS: translated list of messages for a transaction in html format
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 FUNCTION get_message_list (p_transaction_id   IN NUMBER,
                            p_transaction_type IN VARCHAR2)
 RETURN VARCHAR2 AS

   l_contact_mes   varchar2(4000);
   TYPE l_mes_info_rec IS RECORD (
     trxn_error_id       iby_transaction_errors.transaction_error_id%TYPE,
     error_code          iby_transaction_errors.error_code%TYPE);

   TYPE l_token_info_rec IS RECORD(
     token_name          iby_trxn_error_tokens.token_name%TYPE,
     token_value         iby_trxn_error_tokens.token_value%TYPE,
     lookup_type_source  iby_trxn_error_tokens.lookup_type_source%TYPE,
     meaning             fnd_lookups.meaning%TYPE);

   TYPE l_mes_info_tab IS TABLE OF l_mes_info_rec;
   TYPE l_token_info_tab IS TABLE OF l_token_info_rec;

   l_mes_info    l_mes_info_tab;
   l_token_info  l_token_info_tab;

   CURSOR trxn_errors IS
   SELECT transaction_error_id, error_code
     FROM iby_transaction_errors
    WHERE transaction_id = p_transaction_id
      AND transaction_type = p_transaction_type
      AND error_status = 'ACTIVE';

   CURSOR token_info(c_trxn_error_id IN iby_transaction_errors.transaction_error_id%TYPE) IS
   SELECT t.token_name, t.token_value, t.lookup_type_source, l.meaning
     FROM iby_trxn_error_tokens t, fnd_lookups l
    WHERE t.transaction_error_id = (c_trxn_error_id)
      AND t.lookup_type_source = l.lookup_type(+)
      AND t.token_value = l.lookup_code(+);

 BEGIN
    BEGIN
      OPEN trxn_errors;
      FETCH trxn_errors
      BULK COLLECT INTO l_mes_info;
      CLOSE trxn_errors;
    EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
    END;

   IF (l_mes_info.COUNT > 0) THEN
     l_contact_mes := '<OL>';
     FOR i IN l_mes_info.FIRST..l_mes_info.LAST LOOP
       FND_MESSAGE.SET_NAME('IBY',l_mes_info(i).error_code);

       -- get token info if any.
       BEGIN
         OPEN token_info(l_mes_info(i).trxn_error_id);
         FETCH token_info
         BULK COLLECT INTO l_token_info;
         CLOSE token_info;
       EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
       END;

       IF (l_token_info.COUNT > 0) THEN
         FOR j IN l_token_info.FIRST..l_token_info.LAST LOOP
           IF (l_token_info(j).lookup_type_source IS NULL) THEN
             FND_MESSAGE.SET_TOKEN(l_token_info(j).token_name, l_token_info(j).token_value);
           ELSE
             FND_MESSAGE.SET_TOKEN(l_token_info(j).token_name, l_token_info(j).meaning);
           END IF;

         END LOOP;
       END IF;

       l_contact_mes := l_contact_mes||'<LI>'||FND_MESSAGE.GET||'</LI>';

     END LOOP;
     l_contact_mes := l_contact_mes||'</OL>';

   END IF;
   RETURN l_contact_mes;
 END get_message_list;

/*--------------------------------------------------------------------
 | NAME:
 |     perform_check_print
 |
 | PURPOSE: This procedure calls the IBY_CHECKNUMBER_PUB.performCheckNumbering
 |          procedure to lock the payment document and number the payments
 |
 |
 | PARAMETERS:
 |     IN  p_instruction_id    -  Payment Instruction to print
 |     IN  p_pmt_document_id   -  Payment document id used to print
 |                                payment instruction
 |     IN  p_printer_name      -  Printer defined by the user
 |
 |     OUT x_return_status     -  Return status (S, E, U)
 |     OUT x_return_message    -  This error code will indicate if there
 |                                is any error during the numbering of the
 |                                payment instruction or if the payment
 |                                document cannot be locked.
 |
 | NOTES:  This procedure is only called from the Print UI since it will
 |         number the complete payment instruction.
 |
 | IMPORTANT NOTE:
 |         This procedure originally did not perform a COMMIT. However,
 |         after unexpected behaviors started occuring after lock/unlock
 |         APIs for handling intermediate statuses were introduced.
 |
 |         These APIs stamp a conc request id against a pmt entity
 |         (such as a pmt request or pmt instruction) and perform a commit.
 |
 |         If that underlying pmt entity has already been updated, but not
 |         committed a deadlock condition ensues and this API exits with
 |         error 'ORA-00060: deadlock detected while waiting for resource'.
 |
 |         Therefore, a COMMIT is performed after the payment instruction
 |         is updated in this method. The Post-PICP API will lock the
 |         same payment instruction by stamping the conc request id on it.
 |         This operation does not fail now because the changes made to the
 |         payment instruction have already been committed.
 |
 |         See bug 5195769 for an example of this deadlock scenario.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE perform_check_print(
             p_instruction_id    IN NUMBER,
             p_pmt_document_id   IN NUMBER,
             p_printer_name      IN VARCHAR2,
             x_return_status     IN OUT NOCOPY VARCHAR2,
             x_return_message    IN OUT NOCOPY VARCHAR2) IS

 l_module_name  CONSTANT VARCHAR2(200) := G_PKG_NAME|| '.perform_check_print';
 l_instr_status IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_status%TYPE;

 l_error_code   VARCHAR2(3000);

 l_msg_count    NUMBER;
 l_msg_data     VARCHAR2(4000);

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     FND_MSG_PUB.initialize;

     /*
      * Get the status of the provided payment instruction.
      */
     BEGIN

         SELECT
             payment_instruction_status
         INTO
             l_instr_status
         FROM
             IBY_PAY_INSTRUCTIONS_ALL
         WHERE
             payment_instruction_id = p_instruction_id
         ;

     EXCEPTION
         WHEN OTHERS THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Fatal: Exception occured '
	                 || 'when attempting to get status of payment '
	                 || 'instruction '
	                 || p_instruction_id
	                 || '. Aborting ..'
	                 );

             END IF;
             l_error_code := 'IBY_INS_NOT_FOUND';
             FND_MESSAGE.set_name('IBY', l_error_code);

             FND_MESSAGE.SET_TOKEN('INS_ID',
                 p_instruction_id,
                 FALSE);
             FND_MSG_PUB.add;
             x_return_message := FND_MESSAGE.get;

             /*
              * Propogate exception.
              */
             RAISE;
     END;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Status of payment instruction '
	         || p_instruction_id
	         || ' is '
	         || l_instr_status
	         );

     END IF;
     /*
      * First check whether the provided payment instruction
      * is in the right status.
      */
     IF (l_instr_status <> INS_STATUS_READY_TO_PRINT  AND
         l_instr_status <> INS_STATUS_READY_TO_FORMAT AND
         l_instr_status <> INS_STATUS_FORMAT_TO_PRINT AND
         l_instr_status <> PAY_STATUS_CREATED) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Payment instruction '
	                 || p_instruction_id
	                 || ' is in status '
	                 || l_instr_status
	                 || '. Cannot print this instruction ..'
	                 );

             END IF;
             l_error_code := 'IBY_INS_NOT_PRINT_STATUS';
             FND_MESSAGE.set_name('IBY', l_error_code);

             FND_MESSAGE.SET_TOKEN('INS_ID',
                 p_instruction_id,
                 FALSE);

             FND_MESSAGE.SET_TOKEN('BAD_STATUS',
                 l_instr_status,
                 FALSE);
              FND_MSG_PUB.add;
             x_return_message := FND_MESSAGE.get;

             APP_EXCEPTION.RAISE_EXCEPTION;

     END IF;

     /*
      * If we reached here, the payment instruction is the
      * correct status.
      *
      * Update the printer associated with this payment instruction
      * with the provided printer name. The Post-PICP modules
      * will use this printer for printing the checks.
      */
     UPDATE
         IBY_PAY_INSTRUCTIONS_ALL
     SET
         printer_name = p_printer_name
     WHERE
         payment_instruction_id = p_instruction_id
     ;

     /*
      * Fix for bug 5195769:
      *
      * This commit is necessary. Otherwise a deadlocked
      * condition is created when we try to update the same
      * payment instruction with the concurrent request id
      * (for handling intermediate statuses).
      */
     COMMIT;

     /*
      * Lastly invoke numbering and/or printing depending
      * upon the status of the payment instruction.
      */
     IF (l_instr_status = INS_STATUS_FORMAT_TO_PRINT) THEN

         /*
          * This means that this payment instruction is
          * already formatted. Only printing is required.
          */
         BEGIN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Going to invoke '
	                 || 'extract and format operation for payment instruction '
	                 || p_instruction_id
	                 );

             END IF;
             IBY_FD_POST_PICP_PROGS_PVT.
                 Run_Post_PI_Programs(
                     p_instruction_id,
                     'N'
                     );

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Extract and format '
	                 || 'operation completed successfully.'
	                 );

             END IF;
         EXCEPTION
             WHEN OTHERS THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Extract and '
	                 || 'format operation generated '
	                 || 'exception for payment instruction '
	                 || p_instruction_id
	                 );

             END IF;
             l_error_code := 'IBY_INS_BACKEND_ERROR';
             FND_MESSAGE.set_name('IBY', l_error_code);

             FND_MESSAGE.SET_TOKEN('INS_ID',
                 p_instruction_id,
                 FALSE);
              FND_MSG_PUB.add;
             x_return_message := FND_MESSAGE.get;

             /*
              * Propagate exception.
              */
             RAISE;

         END;

     ELSE

         /*
          * This means that this payment instruction is not
          * yet numbered. Invoke the numbering flow.
          */
        print_debuginfo(l_module_name, 'Performing Check Numbering : 1');
         IBY_CHECKNUMBER_PUB.performCheckNumbering(
             p_instruction_id,
             p_pmt_document_id,
             NULL,
             x_return_status,
             x_return_message,
             l_msg_count,
             l_msg_data
             );

         IF (x_return_status IS NULL OR
	     x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Check numbering '
	                 || 'operation failed for payment instruction '
	                 || p_instruction_id
	                 || ' with error message: '
	                 || x_return_message
	                 );

             END IF;
             APP_EXCEPTION.RAISE_EXCEPTION;

         END IF;

         /*
          * After numbering, invoke the printing flow.
          */
         BEGIN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Invoking extract and '
	                 || 'format operation for payment instruction '
	                 || p_instruction_id
	                 );

             END IF;
             IBY_FD_POST_PICP_PROGS_PVT.
                 Run_Post_PI_Programs(
                     p_instruction_id,
                     'N'
                     );

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Extract and format '
	                 || 'operation completed successfully'
	                 );

             END IF;
         EXCEPTION
             WHEN OTHERS THEN

             l_error_code := 'IBY_INS_BACKEND_ERROR';
             FND_MESSAGE.set_name('IBY', l_error_code);

             FND_MESSAGE.SET_TOKEN('INS_ID',
                 p_instruction_id,
                 FALSE);
             FND_MSG_PUB.add;
             x_return_message := FND_MESSAGE.get;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Extract and '
	                 || 'format operation generated '
	                 || 'exception for payment instruction '
	                 || p_instruction_id
	                 );

             END IF;
             /*
              * Propagate exception.
              */
             RAISE;

         END;

     END IF;

     /*
      * Return success.
      */
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Returning success response ..');
     END IF;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 EXCEPTION
     WHEN OTHERS THEN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Exception occured when '
	         || 'performing check print'
	         );

	     print_debuginfo(l_module_name, 'SQL code: '
	         || SQLCODE);
	     print_debuginfo(l_module_name, 'SQL err msg: '
	         || SQLERRM);
     END IF;
     FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Returning failure response .. '
	         );

     END IF;
     /*
      * The error message would have already been set.
      * Just set the error status here.
      */
     x_return_status := FND_API.G_RET_STS_ERROR;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END perform_check_print;

/*--------------------------------------------------------------------
 | NAME:
 |     checkIfDocUsed
 |
 | PURPOSE:
 |     Checks if a given paper document number has already been used.
 |     A used paper document implies that a check has already been
 |     printed for the given paper document number.
 |
 |
 | PARAMETERS:
 |     IN
 |       p_paper_doc_num   - Paper document number (check number) to verify.
 |
 |       p_pmt_document_id - Payment document id (check stock) that this
 |                           paper document number belongs to.
 |     OUT
 |       NONE
 |
 | RETURNS:
 |       TRUE  - if the paper document number has already been used.
 |       FALSE - if the paper document number has not been used.
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 FUNCTION checkIfDocUsed(
     p_paper_doc_num     IN NUMBER,
     p_pmt_document_id   IN NUMBER
     ) RETURN BOOLEAN
 IS

 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME
                                         || '.checkIfDocUsed';

 l_flag BOOLEAN;
 l_used_paper_doc_number NUMBER := 0;

 BEGIN

     /*
      * Check if this paper document number has already
      * been used by searching the the IBY_USED_PAYMENT_DOCS
      * table.
      */
     SELECT
         used_document_number
     INTO
         l_used_paper_doc_number
     FROM
         IBY_USED_PAYMENT_DOCS
     WHERE
         payment_document_id  = p_pmt_document_id     AND
         used_document_number = p_paper_doc_num AND
	 document_use <> 'SKIPPED'
     ;

     /*
      * If we reached here, it means that a row has been
      * found in the IBY_USED_PAYMENT_DOCS table for the
      * given (paper doc number, payment document id)
      * combination. This means that the paper document
      * is used.
      *
      * Set the return flag to true.
      */
     l_flag := TRUE;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Returning TRUE.');
     END IF;
     RETURN l_flag;

 EXCEPTION

     WHEN NO_DATA_FOUND THEN

         /* now rows means success */
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Paper document '
	             || 'number '
	             || p_paper_doc_num
	             || ' is unused.'
	             );

         END IF;
         /* set the return flag to false */
         l_flag := FALSE;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning FALSE.');
         END IF;
         RETURN l_flag;

     WHEN OTHERS THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Exception occured when '
	             || 'attempting to get details of paper document '
	             || p_paper_doc_num
	             || ' from IBY_USED_PAYMENT_DOCS table.'
	             );

	         print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	         print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);

	         print_debuginfo(l_module_name, 'Unexpected error. '
	             || 'Raising exception ..');

         END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;

 END checkIfDocUsed;

/*--------------------------------------------------------------------
 | NAME:
 |     insert_conc_request
 |
 | PURPOSE:
 |     Inserts a given concurrent request id into the
 |     IBY_PROCESS_CONC_REQUESTS table for audit purposes.
 |
 | PARAMETERS:
 |     IN
 |     p_object_id         The id of the payment entity. This can be
 |                         a payment id, a payment request id or a payment
 |                         instruction id.
 |
 |     p_object_type       The type of the payment entity. This can be
 |                         one of the following
 |                             PAYMENT
 |                             PAYMENT_REQUEST
 |                             PAYMENT_INSTRUCTION
 |
 |     p_conc_request_id   The concurrent request id.
 |
 |     p_completed_flag    Flag indicating whether the concurrent request
 |                         has completed.
 |
 |     OUT
 |     x_return_status     Return status (S, E, U)
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE insert_conc_request(
             p_object_id         IN NUMBER,
             p_object_type       IN VARCHAR2,
             p_conc_request_id   IN NUMBER,
             p_completed_flag    IN VARCHAR2 DEFAULT 'N',
             x_return_status     IN OUT NOCOPY VARCHAR2
             )
 IS

 l_module_name  CONSTANT VARCHAR2(200) := G_PKG_NAME|| '.insert_conc_request';
 l_dup_count NUMBER;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

	     print_debuginfo(l_module_name, 'Inserting conc request id '
	         || p_conc_request_id
	         || ' into IBY_PROCESS_CONC_REQUESTS for object id '
	         || p_object_id
	         || ' with object type '
	         || p_object_type
	         );

     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Checking if a duplicate conc request record exists');
     END IF;

     SELECT COUNT(*) dup_count
     INTO l_dup_count
     FROM IBY_PROCESS_CONC_REQUESTS
     WHERE OBJECT_ID = p_object_id
     AND OBJECT_TYPE = p_object_type
     AND REQUEST_ID = p_conc_request_id
     ;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Concurrent request l_dup_count : ' || l_dup_count);
     END IF;


     IF (l_dup_count > 0) THEN

	     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		     print_debuginfo(l_module_name, 'By passing conc request insertion');
	     END IF;

     ELSE

	     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		     print_debuginfo(l_module_name, 'Inserting conc request');
	     END IF;


	     INSERT INTO IBY_PROCESS_CONC_REQUESTS
		 (
		 OBJECT_ID,             /* 1 */
		 OBJECT_TYPE,
		 REQUEST_ID,
		 COMPLETED_FLAG,
		 CREATED_BY,            /* 5 */
		 CREATION_DATE,
		 LAST_UPDATED_BY,
		 LAST_UPDATE_DATE,
		 LAST_UPDATE_LOGIN,
		 OBJECT_VERSION_NUMBER  /* 10 */
		 )
		 VALUES
		 (
		 p_object_id,           /* 1 */
		 p_object_type,
		 p_conc_request_id,
		 p_completed_flag,
		 fnd_global.user_id,    /* 5 */
		 sysdate,
		 fnd_global.user_id,
		 sysdate,
		 fnd_global.login_id,
		 1                      /* 10 */
		 )
		 ;
     END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 EXCEPTION
     WHEN OTHERS THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Exception occured when '
	             || 'inserting conc request id '
	             || p_conc_request_id
	             || ' into IBY_PROCESS_CONC_REQUESTS for object id '
	             || p_object_id
	             || ' with object type '
	             || p_object_type
	             || '.'
	             );

	         print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	         print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);

         END IF;
         FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);
         x_return_status := FND_API.G_RET_STS_ERROR;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
 END insert_conc_request;

/*--------------------------------------------------------------------
 | NAME:
 |     lock_pmt_entity
 |
 | PURPOSE:
 |     Stamps the given payment entity with the given concurrent
 |     request id to lock the entity.
 |
 |     The IBY UI will not allow any follow on operation on a payment
 |     entity that is locked.
 |
 |     Locking/unlocking is the mechanism by which to preserve
 |     data integrity of payment entities which are in transient
 |     statuses.
 |
 |     This method also inserts the provided concurrent request into
 |     IBY_PROCESS_CONC_REQUESTS table for audit purposes.
 |
 | PARAMETERS:
 |     IN
 |     p_object_id         The id of the payment entity. This can be
 |                         a payment id, a payment request id or a payment
 |                         instruction id.
 |
 |     p_object_type       The type of the payment entity. This can be
 |                         one of the following
 |                             PAYMENT
 |                             PAYMENT_REQUEST
 |                             PAYMENT_INSTRUCTION
 |
 |     p_conc_request_id   The concurrent request id to stamp the payment
 |                         entity with. If NULL is provided, the value of
 |                         FND_GLOBAL.CONC_REQUEST_ID will be used.
 |
 |     OUT
 |     x_return_status     Return status (S, E, U)
 |
 | RETURNS:
 |
 | NOTES:
 |     This method is implemented as an autonomous transaction
 |     so that a COMMIT can be performed on the payment entity
 |     without side effects on the main transaction.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE lock_pmt_entity(
             p_object_id         IN NUMBER,
             p_object_type       IN VARCHAR2,
             p_conc_request_id   IN NUMBER DEFAULT NULL,
             x_return_status     IN OUT NOCOPY VARCHAR2
             )
 IS
 PRAGMA AUTONOMOUS_TRANSACTION;

 l_module_name     CONSTANT VARCHAR2(200) := G_PKG_NAME|| '.lock_pmt_entity';
 l_conc_request_id NUMBER;
 l_template_type_code xdo_templates_b.template_type_code%type := null;
 l_default_output_type xdo_templates_b.default_output_type%type := null;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     FND_MSG_PUB.initialize;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Input params - '
	         || 'object id: '
	         || p_object_id
	         || ', object type: '
	         || p_object_type
	         );

     END IF;
     /*
      * STEP 1:
      *
      * If the concurrent request id has not been provided,
      * derive it from the current context.
      */
     IF (p_conc_request_id IS NULL) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Concurrent request id not '
	             || 'provided. Deriving from context ..'
	             );

         END IF;
         l_conc_request_id := FND_GLOBAL.conc_request_id;

     ELSE

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Concurrent request id '
	             || 'provided as input param: '
	             || p_conc_request_id
	             );

         END IF;
         l_conc_request_id := p_conc_request_id;

     END IF;

     /*
      * STEP 2:
      *
      * Stamp the given entity with the provided concurrent request id.
      */
     IF (p_object_type = 'PAYMENT_REQUEST') THEN

         UPDATE
             IBY_PAY_SERVICE_REQUESTS req
         SET
             req.request_id = l_conc_request_id
         WHERE
             req.payment_service_request_id = p_object_id
         ;

     ELSIF (p_object_type = 'PAYMENT_INSTRUCTION') THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo(l_module_name, 'Value of the Payment Instruction Id is: ' || p_object_id);
        END IF;
     BEGIN
        SELECT  temp.template_type_code, temp.default_output_type
          INTO l_template_type_code, l_default_output_type
          FROM iby_pay_instructions_all ins,
               iby_payment_profiles pp,
               iby_formats_b format,
               XDO_TEMPLATES_B temp
           WHERE ins.payment_instruction_id  = p_object_id
           AND ins.payment_profile_id        = pp.payment_profile_id
           AND format.FORMAT_CODE            = pp.PAYMENT_FORMAT_CODE
           AND format.FORMAT_TEMPLATE_CODE   = temp.template_code;
     EXCEPTION
        WHEN OTHERS THEN
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	            print_debuginfo(l_module_name, 'SQL Query giving Other Exception Setting Default Values for the variables');
            END IF;
            l_template_type_code := null;
            l_default_output_type := null;
     END;

         IF(l_template_type_code = 'RTF' AND l_default_output_type = 'EXCEL') THEN
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	            print_debuginfo(l_module_name, 'Updating the output file type to' || l_default_output_type);
            END IF;
             UPDATE FND_CONCURRENT_REQUESTS
             SET output_file_type = 'XLS'
             WHERE request_id = l_conc_request_id;
         END IF;

         UPDATE
             IBY_PAY_INSTRUCTIONS_ALL inst
         SET
             inst.request_id = l_conc_request_id
         WHERE
             inst.payment_instruction_id = p_object_id
         ;

     ELSIF (p_object_type = 'PAYMENT') THEN

         UPDATE
             IBY_PAYMENTS_ALL pmt
         SET
             pmt.request_id = l_conc_request_id
         WHERE
             pmt.payment_id = p_object_id
         ;

     ELSE

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Unknown payment entity type '
	             || p_object_type
	             || ' provided. Raising exception .. '
	             );

         END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;

     END IF;

     /*
      * STEP 3:
      *
      * Insert concurrent request into audit table.
      */

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Inserting cp into audit table');

     END IF;
     insert_conc_request(
             p_object_id,
             p_object_type,
             l_conc_request_id,
             'N',
             x_return_status
             );

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Return status from '
	         || 'insert_conc_request(..) call = '
	         || x_return_status
	         );


     END IF;
     IF (x_return_status IS NULL OR
         x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Audit of conc request '
	             || l_conc_request_id
	             || ' failed. Returning error response .. '
	             );

         END IF;
         /*
          * Undo any database changes made in this method.
          */
         ROLLBACK;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');
         END IF;
         RETURN;

     END IF;

     /*
      * STEP 4:
      *
      * Finally, perform a COMMIT to lock the payment entity
      * with a concurrent request id.
      */
     COMMIT;

     x_return_status := FND_API.G_RET_STS_SUCCESS;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Returning success response ..');

	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 EXCEPTION
     WHEN OTHERS THEN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Exception occured when locking '
	         || 'pmt entity.');

	     print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	     print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);

     END IF;
     FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

     ROLLBACK;

     x_return_status := FND_API.G_RET_STS_ERROR;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END lock_pmt_entity;

/*--------------------------------------------------------------------
 | NAME:
 |     unlock_pmt_entity
 |
 | PURPOSE:
 |     Nulls out the concurrent request id on given payment entity
 |     to unlock the entity.
 |
 |     The IBY UI will not allow any follow on operation on a payment
 |     entity that is locked.
 |
 |     Locking/unlocking is the mechanism by which to preserve
 |     data integrity of payment entities which are in transient
 |     statuses.
 |
 | PARAMETERS:
 |     IN
 |     p_object_id         The id of the payment entity. This can be
 |                         a payment id, a payment request id or a payment
 |                         instruction id.
 |
 |     p_object_type       The type of the payment entity. This can be
 |                         one of the following
 |                             PAYMENT
 |                             PAYMENT_REQUEST
 |                             PAYMENT_INSTRUCTION
 |
 |     OUT
 |     x_return_status     Return status (S, E, U)
 |
 | RETURNS:
 |
 | NOTES:
 |     This method is implemented as an autonomous transaction
 |     so that a COMMIT can be performed on the payment entity
 |     without side effects on the main transaction.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE unlock_pmt_entity(
             p_object_id         IN NUMBER,
             p_object_type       IN VARCHAR2,
             x_return_status     IN OUT NOCOPY VARCHAR2
             )
 IS
 PRAGMA AUTONOMOUS_TRANSACTION;

 l_module_name     CONSTANT VARCHAR2(200) := G_PKG_NAME|| '.unlock_pmt_entity';

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

	     print_debuginfo(l_module_name, 'Input params - '
	         || 'object id: '
	         || p_object_id
	         || ', object type: '
	         || p_object_type
	         );

     END IF;
     /*
      * STEP 1:
      *
      * Unstamp the given entity with the provided concurrent request id.
      */
     IF (p_object_type = 'PAYMENT_REQUEST') THEN

         UPDATE
             IBY_PAY_SERVICE_REQUESTS req
         SET
             req.request_id = NULL
         WHERE
             req.payment_service_request_id = p_object_id
         ;

     ELSIF (p_object_type = 'PAYMENT_INSTRUCTION') THEN

         UPDATE
             IBY_PAY_INSTRUCTIONS_ALL inst
         SET
             inst.request_id = NULL
         WHERE
             inst.payment_instruction_id = p_object_id
         ;

     ELSIF (p_object_type = 'PAYMENT') THEN

         UPDATE
             IBY_PAYMENTS_ALL pmt
         SET
             pmt.request_id = NULL
         WHERE
             pmt.payment_id = p_object_id
         ;

     ELSE

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Unknown payment entity type '
	             || p_object_type
	             || ' provided. Raising exception .. '
	             );

         END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;

     END IF;

     /*
      * STEP 3:
      *
      * Finally, perform a COMMIT to unlock the payment entity
      * with a concurrent request id.
      */
     COMMIT;

     x_return_status := FND_API.G_RET_STS_SUCCESS;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Returning success response ..');

	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 EXCEPTION
     WHEN OTHERS THEN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Exception occured when unlocking '
	         || 'pmt entity.');

	     print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	     print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);

     END IF;
     FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

     ROLLBACK;

     x_return_status := FND_API.G_RET_STS_ERROR;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 END unlock_pmt_entity;

/*--------------------------------------------------------------------
 | NAME:
 |     populatePaymentFunctions
 |
 |
 | PURPOSE:
 |     Populate the payment functions that user has access to
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
 PROCEDURE populatePaymentFunctions(
             x_return_status     IN OUT NOCOPY VARCHAR2,
             x_return_message    IN OUT NOCOPY VARCHAR2) IS

 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME
                                         || '.populatePaymentFunctions';
l_func varchar2(30);
l_bool boolean;
l_count number;
cursor c_pay_function is
select lookup_code
from fnd_lookups
where lookup_type='IBY_PAYMENT_FUNCTIONS';

begin

FND_MSG_PUB.initialize;

-- first check whether the payment function is populated or not
  begin
   select count(1)
    into l_count
   from IBY_USER_PAY_FUNS_GT;
   exception
      WHEN OTHERS THEN

         /* now rows means success */
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Exception in select ');
         END IF;
          null;
     end;

   if(l_count<>0) then
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        return;
   end if;

    OPEN  c_pay_function;
    loop
     FETCH c_pay_function INTO l_func;
     exit when c_pay_function%NOTFOUND;
      -- check security
    l_bool := fnd_function.test_instance(
   'IBY_' || l_func,
   null,
   null,
   null,
   null,
   null,
   null,
   fnd_global.user_name);

   if(l_bool) then
   --print_debuginfo(l_module_name, 'User has access to:' || l_func);
    insert into IBY_USER_PAY_FUNS_GT(payment_function)
    values(l_func);
	end if;
      end loop;
      close c_pay_function;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
        return;
   EXCEPTION

    WHEN OTHERS THEN
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'SQL err msg: '
	       || SQLERRM);
	     print_debuginfo(l_module_name, 'Returning failure response .. '
	       );
     END IF;
     FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);
     /*
      * The error message would have already been set.
      * Just set the error status here.
      */
     x_return_status := FND_API.G_RET_STS_ERROR;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
end populatePaymentFunctions;



/*--------------------------------------------------------------------
 | NAME:
 |     checkUserFunctionAccess
 |
 |
 | PURPOSE:
 |     Check whether the user has access to a particular function
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
FUNCTION checkUserFunctionAccess(p_function_name in VARCHAR2) return VARCHAR2
IS
  l_boolean BOOLEAN := FALSE;
  l_result VARCHAR2(1);
  l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME
                                         || '.checkUserFunctionAccess';
begin
  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	  print_debuginfo(l_module_name, 'Begin checkUserFunctionAccess');
	  print_debuginfo(l_module_name, 'Checking user function access' || p_function_name);

  END IF;
  l_boolean := FND_FUNCTION.TEST(p_function_name);

  IF ( l_boolean = TRUE ) THEN
     l_result := 'Y';
  ELSE
     l_result := 'N';
  END IF;

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	  print_debuginfo(l_module_name, 'End checkUserFunctionAccess');
  END IF;
  RETURN l_result;

EXCEPTION
WHEN OTHERS THEN
  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	  print_debuginfo(l_module_name, 'checkUserFunctionAccess failed');
  END IF;
  l_result := 'N';
  RETURN l_result;

END checkUserFunctionAccess;


/*--------------------------------------------------------------------
 | NAME:
 |     checkUserAccess
 |
 |
 | PURPOSE:
 |     Check whether the user has access to all the org. or payment function
 |      of a particular object.
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
PROCEDURE checkUserAccess(
             p_object_id         IN NUMBER,
             p_object_type       IN VARCHAR2,
             x_access_flag       IN OUT NOCOPY VARCHAR2,
             x_return_status     IN OUT NOCOPY VARCHAR2,
             x_return_message    IN OUT NOCOPY VARCHAR2)
IS
 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME
                                         || '.checkUserAccess';

 l_function_count NUMBER:=0;
 l_org_count NUMBER:=0;
 l_msg_count NUMBER:=0;
 l_message_code VARCHAR2(30);
begin

-- initiate the return parameter
IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	print_debuginfo(l_module_name, 'ENTER');

END IF;
FND_MSG_PUB.initialize;
populatePaymentFunctions(x_return_status, x_return_message);
x_access_flag:='N';

 /* Initialize return status */
x_return_status := FND_API.G_RET_STS_SUCCESS;

select count(1)
into l_function_count
from iby_process_functions pfun
where object_id=p_object_id
and   object_type=p_object_type
and pfun.payment_function not in
       (select payment_function
        from IBY_USER_PAY_FUNS_GT
        );
IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	print_debuginfo(l_module_name, 'Number of Missing Payment Function:' ||l_function_count);

END IF;
select count(1)
into l_org_count
from iby_process_orgs porg
where object_id=p_object_id
and   object_type=p_object_type
and porg.org_id not in
       (select  organization_id
        from ce_security_profiles_v cep
        where cep.organization_type=porg.org_type
        );
IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	print_debuginfo(l_module_name, 'Number of Missing Org:' ||l_org_count);
END IF;
	-- check the user access
    if(l_function_count<>0 OR l_org_count <>0) THEN
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            print_debuginfo(l_module_name, 'User doesnt have full access to the payment request or payment instruction');
            END IF;

  -- return error message for different object type

       if(p_object_type='PAYMENT_REQUEST') then
         l_message_code :='IBY_FD_ACCESS_REQUEST_ERROR';
       else
         l_message_code :='IBY_FD_ACCESS_INSTR_ERROR';

       end if;


        FND_MESSAGE.set_name('IBY', l_message_code);
        FND_MSG_PUB.add;

        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count   => l_msg_count,
                                  p_data    => x_return_message
                                  );

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Returning error response ..');
	             print_debuginfo(l_module_name, 'Error count:' || l_msg_count);
	             print_debuginfo(l_module_name, 'Error Text:' || x_return_message);
	             print_debuginfo(l_module_name, 'EXIT');
             END IF;
   end if;

EXCEPTION
WHEN OTHERS THEN
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo(l_module_name, 'SQL err msg: '
	       || SQLERRM);
	     print_debuginfo(l_module_name, 'Returning failure response .. '
	       );
     END IF;
     FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);
     /*
      * The error message would have already been set.
      * Just set the error status here.
      */
     x_return_status := FND_API.G_RET_STS_ERROR;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');
     END IF;
end checkUserAccess;

/*--------------------------------------------------------------------
 | NAME:
 |     checkIfAllPmtsTerminated
 |
 | PURPOSE:
 |     Checks if all payments of a given payment instruction
 |     have been terminated.
 |
 | PARAMETERS:
 |     IN
 |       p_instr_id   - Payment instruction id to verify.
 |
 |     OUT
 |       NONE
 |
 | RETURNS:
 |       TRUE  - if all payments have been terminated.
 |       FALSE - if at least one non-terminated payment exists.
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 FUNCTION checkIfAllPmtsTerminated(
     p_instr_id          IN NUMBER
     ) RETURN BOOLEAN
 IS

 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME
                                         || '.checkIfAllPmtsTerminated';

 l_flag             BOOLEAN := FALSE;

 l_all_pmts_count   NUMBER;
 l_term_pmts_count  NUMBER;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     SELECT
         COUNT(*)
     INTO
         l_all_pmts_count
     FROM
         IBY_PAYMENTS_ALL pmt
     WHERE
         pmt.payment_instruction_id = p_instr_id
     ;


     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Count of all payments in pmt instr '
	         || p_instr_id
	         || ' = '
	         || l_all_pmts_count
	         );

     END IF;
     SELECT
         COUNT(*)
     INTO
         l_term_pmts_count
     FROM
         IBY_PAYMENTS_ALL pmt
     WHERE
         pmt.payment_instruction_id = p_instr_id
     AND
         pmt.payment_status = PAY_STATUS_REQ_TERM
     ;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Count of terminated payments in '
	         || 'pmt instr '
	         || p_instr_id
	         || ' = '
	         || l_all_pmts_count
	         );

     END IF;
     /*
      * If all payments have been terminated return TRUE.
      */
     IF (l_all_pmts_count = l_term_pmts_count) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'All payments in pmt instr '
	             || p_instr_id
	             || ' have been terminated. Returning TRUE.'
	             );

         END IF;
         l_flag := TRUE;

     ELSE

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'At least one payment in pmt instr '
	             || p_instr_id
	             || ' has not been terminated. Returning FALSE.'
	             );

         END IF;
         l_flag := FALSE;

     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
     RETURN l_flag;

 EXCEPTION

     WHEN OTHERS THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Exception occured when '
	             || 'checking if all pmts of pmt instruction '
	             || p_instr_id
	             || ' were terminated.'
	             );

	         print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	         print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);

         END IF;
         l_flag := FALSE;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning FALSE.');
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN l_flag;

 END checkIfAllPmtsTerminated;

/*--------------------------------------------------------------------
 | NAME:
 |     checkIfPmtInInstExists
 |
 | PURPOSE:
 |     Checks if all payments of a given payment instruction
 |     have been terminated.
 |
 | PARAMETERS:
 |     IN
 |       p_payreq_id - Payment request to verify.
 |
 |     OUT
 |       NONE
 |
 | RETURNS:
 |       TRUE  - if at least one payment of the ppr is part of
 |                   an instruction.
 |       FALSE - if none of the payments of the ppr are part of
 |                   an instruction.
 |
 | NOTES:
 |       This method is meant exclusively to be used by the
 |       terminate_pmt_request(..) API. Do not use call this
 |       method for other general purposes.
 |
 |
 |       -- IMPORTANT --
 |       This method locks rows in the IBY_PAYMENTS_ALL table and
 |       expects that the caller will commit/rollback to release lock.
 |
 *---------------------------------------------------------------------*/
 FUNCTION checkIfPmtInInstExists(
     p_payreq_id          IN NUMBER
     ) RETURN BOOLEAN
 IS

 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME
                                         || '.checkIfPmtInInstExists';

 l_flag             BOOLEAN := FALSE;
 l_test             VARCHAR2(200);

 l_all_pmts_count   NUMBER;
 l_term_pmts_count  NUMBER;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     /*
      * This method is called by terminate_pmt_request(..)
      * to check if any of the payments are part of a payment
      * instruction.
      *
      * TIME T1: This method returns FALSE
      *          implying that none of the
      *          payments of the ppr are part
      *          of any payment instruction.
      *
      * TIME T2: PICP runs and picks up payments
      *          of which some payments are from this
      *          ppr.
      *
      * TIME T3: terminate_pmt_request(..) terminates
      *          a ppr based on the return value of
      *          this method. Now, we have an payment
      *          instruction that contains a payment
      *          from this ppr that has been terminated.
      *          This situation is wrong and should never
      *          occur.
      *
      * To prevent this situation, we lock the payments
      * table first, before attempting to terminate
      * a ppr.
      *
      * This lock will get released when the UI peforms a
      * COMMIT / ROLLBACK action based on the return value
      * of the terminate_pmt_request(..) API.
      */

     /*
      * Instead of locking the entire table only lock the
      * rows that we are interested in (explicit locking).
      */
     -- LOCK TABLE IBY_PAYMENTS_ALL IN EXCLUSIVE MODE;

     SELECT
         pmt.payment_id
     INTO
         l_test
     FROM
         IBY_PAYMENTS_ALL pmt
     WHERE
         pmt.payment_instruction_id IS NOT NULL
     AND
         pmt.payment_service_request_id = p_payreq_id
     FOR UPDATE
     ;

     /*
      * Now check whether the payments of this request
      * are linked to any payment instructions.
      */
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
              pmt.payment_id
          FROM
              IBY_PAYMENTS_ALL pmt
          WHERE
              pmt.payment_instruction_id IS NOT NULL
          AND
              pmt.payment_service_request_id = p_payreq_id
          )
     ;

     IF (l_test = 'TRUE') THEN
         l_flag := TRUE;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning flag as TRUE.');
         END IF;
     ELSE
         l_flag := FALSE;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning flag as FALSE.');
         END IF;
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
     RETURN l_flag;

 EXCEPTION

     WHEN NO_DATA_FOUND THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Payment request id '
	             || p_payreq_id
	             || ' does not contain any payments.'
	             );

         END IF;
         /*
          * This ppr only contains documents and no payments.
          *
          * Therefore, allow this ppr to be terminated by
          * returning FALSE.
          */
         l_flag := FALSE;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning FALSE.');
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN l_flag;

     WHEN OTHERS THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Exception occured when '
	             || 'checking if any pmts of pmt request '
	             || p_payreq_id
	             || ' were part of a pmt instruction.'
	             );

	         print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	         print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);

         END IF;
         /*
          * In case of an exception, play safe and return TRUE.
          *
          * The terminate_pmt_request(..) API will not allow the
          * request to be terminated.
          */
         l_flag := TRUE;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning TRUE.');
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN l_flag;

 END checkIfPmtInInstExists;

/*--------------------------------------------------------------------
 | NAME:
 |     finalize_electronic_instr
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
 |     Internal API, not for public use.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE finalize_electronic_instr(
             p_instr_id          IN NUMBER,
             x_return_status     IN OUT NOCOPY VARCHAR2
             )
 IS

 l_module_name     CONSTANT VARCHAR2(200)
                                := G_PKG_NAME ||
                                       '.finalize_electronic_instr';
 l_completion_point       VARCHAR2(30);
 l_flag            BOOLEAN := FALSE;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');
     END IF;
     FND_MSG_PUB.initialize;

     /*
      * STEP 1:
      *
      * Check if payment instruction transmission is outside
      * the system.
      *
      * Update the payment instruction and payment statuses
      * to final statuses accordingly.
      */
     l_flag := checkIfInstrXmitOutsideSystem(p_instr_id);
     l_completion_point := IBY_DISBURSE_UI_API_PUB_PKG.Get_Pmt_Completion_Point(p_instr_id);

     IF (l_completion_point <> 'CREATED') THEN
	     IF (l_flag = TRUE) THEN

		 UPDATE
		     IBY_PAY_INSTRUCTIONS_ALL inst
		 SET
		     inst.payment_instruction_status = INS_STATUS_FORMATTED_ELEC
		 WHERE
		     inst.payment_instruction_id = p_instr_id
		 ;

		 UPDATE
		     IBY_PAYMENTS_ALL pmt
		 SET
		     pmt.payment_status = PAY_STATUS_FORMATTED
		 WHERE
		     pmt.payment_instruction_id = p_instr_id
		 ;

	     ELSE

		 UPDATE
		     IBY_PAY_INSTRUCTIONS_ALL inst
		 SET
		     inst.payment_instruction_status = INS_STATUS_TRANSMITTED
		 WHERE
		     inst.payment_instruction_id = p_instr_id
		 ;

		 UPDATE
		     IBY_PAYMENTS_ALL pmt
		 SET
		     pmt.payment_status = PAY_STATUS_TRANSMITTED
		 WHERE
		     pmt.payment_instruction_id = p_instr_id
		 ;

	     END IF;

     END IF;

     /*
      * STEP 2:
      *
      * Mark the payment instruction and payments complete.
      */
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name,
	         'Invoking mark payments complete API ..');

     END IF;
     mark_all_pmts_complete(p_instr_id, x_return_status);

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Returning status: '
	         || x_return_status
	         );

	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 EXCEPTION
     WHEN OTHERS THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Exception occured when '
	             || 'finalizing electronic payment instruction '
	             || p_instr_id
	             || '.'
	             );

	         print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	         print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);

         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning error status: '
	             || x_return_status
	             );
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
 END finalize_electronic_instr;

/*--------------------------------------------------------------------
 | NAME:
 |     checkIfInstrXmitOutsideSystem
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
 |     Internal API, not for public use.
 |
 *---------------------------------------------------------------------*/
 FUNCTION checkIfInstrXmitOutsideSystem(
     p_instr_id          IN NUMBER
     ) RETURN BOOLEAN
 IS

 l_module_name CONSTANT VARCHAR2(200)
                            := G_PKG_NAME
                                   || '.checkIfInstrXmitOutsideSystem';

 l_flag             BOOLEAN := FALSE;
 l_test             VARCHAR2(200);

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     /*
      * If the transmit configuration id linked to the profile
      * on a payment instruction is null, it means that transmit
      * configuration has not been set up for that profile.
      *
      * This implies that the payment instruction needs to be
      * transmitted outside the system (i.e., using an external
      * application).
      */
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
              instr.payment_instruction_id
          FROM
              IBY_PAY_INSTRUCTIONS_ALL instr,
              IBY_PAYMENT_PROFILES     prof
          WHERE
              instr.payment_instruction_id = p_instr_id
          AND
              prof.payment_profile_id = instr.payment_profile_id
          AND
              prof.transmit_configuration_id IS NULL
          )
     ;

     IF (l_test = 'TRUE') THEN
         l_flag := TRUE;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Transmission is outside the system.');
	         print_debuginfo(l_module_name, 'Returning flag as TRUE.');
         END IF;
     ELSE
         l_flag := FALSE;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Transmission is inside the system.');
	         print_debuginfo(l_module_name, 'Returning flag as FALSE.');
         END IF;
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
     RETURN l_flag;

 EXCEPTION

     WHEN OTHERS THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Exception occured when '
	             || 'checking if instruction '
	             || p_instr_id
	             || ' needs to be transmitted using external system(s).'
	             );

	         print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	         print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);

         END IF;
         /*
          * In case of an exception, play safe and return TRUE.
          *
          * The user will have to transmit the payment instruction
          * outside of IBY using some external application.
          */
         l_flag := FALSE; /* bug 9663534 If the above SQL doesn't return any row it will throw no_data_found Exception. In that case and in case of any exception l_flag nust be FALSE.*/
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Transmission will have to be '
	             || 'outside the system (irrespective of setting).');
	         print_debuginfo(l_module_name, 'Returning TRUE.');
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN l_flag;

 END checkIfInstrXmitOutsideSystem;

/*--------------------------------------------------------------------
 | NAME:
 |     checkIfPmtEntityLocked
 |
 |
 | PURPOSE:
 |     Checks if a given payment entity is locked (i.e., stamped
 |     with a concurrent request id).
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
 |     Internal API, not for public use.
 |
 *---------------------------------------------------------------------*/
 FUNCTION checkIfPmtEntityLocked(
     p_object_id         IN NUMBER,
     p_object_type       IN VARCHAR2
     ) RETURN BOOLEAN
 IS
 l_module_name CONSTANT VARCHAR2(200)
                            := G_PKG_NAME || '.checkIfPmtEntityLocked';

 l_flag             BOOLEAN := FALSE;
 l_test             VARCHAR2(200);

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

     END IF;
     IF (p_object_type = 'PAYMENT_REQUEST') THEN

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
                 req.payment_service_request_id
             FROM
                 IBY_PAY_SERVICE_REQUESTS req
             WHERE
                 req.payment_service_request_id = p_object_id
             AND
                 req.request_id IS NOT NULL
             )
         ;

     ELSIF (p_object_type = 'PAYMENT_INSTRUCTION') THEN

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
                 inst.payment_instruction_id
             FROM
                 IBY_PAY_INSTRUCTIONS_ALL inst
             WHERE
                 inst.payment_instruction_id = p_object_id
             AND
                 inst.request_id IS NOT NULL
             )
         ;

     ELSIF (p_object_type = 'PAYMENT') THEN

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
                 pmt.payment_id
             FROM
                 IBY_PAYMENTS_ALL pmt
             WHERE
                 pmt.payment_id = p_object_id
             AND
                 pmt.request_id IS NOT NULL
             )
         ;

     ELSE

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Unknown payment entity type '
	             || p_object_type
	             || ' provided. Raising exception .. '
	             );

         END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;

     END IF;

     IF (l_test = 'TRUE') THEN
         l_flag := TRUE;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning flag as TRUE.');
         END IF;
     ELSE
         l_flag := FALSE;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning flag as FALSE.');
         END IF;
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
     RETURN l_flag;

 EXCEPTION

     /*
      * Fix for bug 5195694:
      *
      * If no row was found, it means that the
      * payment entity is not locked.
      */
     WHEN NO_DATA_FOUND THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Pmt entity id '
	             || p_object_id
	             || ' of type '
	             || p_object_type
	             || ' is not locked.'
	             );

         END IF;
         l_flag := FALSE;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Returning FALSE.');
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN l_flag;

     WHEN OTHERS THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Exception occured when '
	             || 'checking if pmt entity id '
	             || p_object_id
	             || ' of type '
	             || p_object_type
	             || ' is locked.'
	             );

	         print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	         print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);

         END IF;
         /*
          * In case of an exception, play safe and return TRUE.
          *
          * The user will assume that the pmt entity is locked.
          */
         l_flag := TRUE;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Treating payment entity as locked.');
	         print_debuginfo(l_module_name, 'Returning TRUE.');
	         print_debuginfo(l_module_name, 'EXIT');

         END IF;
         RETURN l_flag;

 END checkIfPmtEntityLocked;

 -- The procedure to submit a request set
 /*--------------------------------------------------------------------
 | NAME:
 |     submit_masking_req_set
 |
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
 PROCEDURE submit_masking_req_set (
     x_request_id      OUT NOCOPY NUMBER,
     x_return_status   OUT NOCOPY VARCHAR2,
     x_msg_count       OUT NOCOPY NUMBER,
     x_msg_data        OUT NOCOPY VARCHAR2
 ) IS
 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME || '.submit_masking_req_set';

 l_api_version    CONSTANT NUMBER := 1.0;
 l_msg_count      NUMBER;
 l_msg_data       VARCHAR2(2000);

 l_phase          VARCHAR2(200);
 l_success BOOLEAN;
 submit_failed EXCEPTION;

 BEGIN
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo(l_module_name, 'ENTER');

    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    FND_MSG_PUB.initialize;

    /* set the context for the request set IBY_SECURITY_MASKING_REQ_SET */
    l_success := fnd_submit.set_request_set('IBY', 'IBY_SECURITY_MASKING_REQ_SET');
    l_phase := 'After set request set.';

        if ( l_success ) then

           /* submit program IBY_CREDITCARD_MASKING which is in stage STAGE1 */
           l_success := fnd_submit.submit_program('IBY','IBY_CREDITCARD_MASKING', 'STAGE1',
                          '','','','','','','','','','','','','','','','','','','','',
                          '','','','','','','','','','','','','','','','','','','','',
                          '','','','','','','','','','','','','','','','','','','','',
                          '','','','','','','','','','','','','','','','','','','','',
                          '','','','','','','','','','','','','','','','','','','','');
           l_phase := 'After submit program 1.';
           if ( not l_success ) then
              raise submit_failed;
           end if;

           /* submit program IBY_EXT_BANKACCT_MASKING which is in stage STAGE1 */
           l_success := fnd_submit.submit_program('IBY','IBY_EXT_BANKACCT_MASKING', 'STAGE1',
                          '','','','','','','','','','','','','','','','','','','','',
                          '','','','','','','','','','','','','','','','','','','','',
                          '','','','','','','','','','','','','','','','','','','','',
                          '','','','','','','','','','','','','','','','','','','','',
                          '','','','','','','','','','','','','','','','','','','','');
           l_phase := 'After submit program 2.';
           if ( not l_success ) then
              raise submit_failed;
           end if;

           /*  Submit the Request set  */
           x_request_id := fnd_submit.submit_set(null,FALSE);
           l_phase := 'After submit request set.';

       else
           l_phase := 'Failed after set request set.';
           raise submit_failed;
       end if;
 EXCEPTION
   WHEN submit_failed THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Exception submit_failed - ' || l_phase);
     END IF;
     FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

   WHEN others THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Exception others.');
	     print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	     print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);
     END IF;
     FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

 END submit_masking_req_set;

 -- The procedure to submit a request set
 /*--------------------------------------------------------------------
 | NAME:
 |     submit_decrypt_req_set
 |
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
 PROCEDURE submit_decrypt_req_set (
     x_request_id      OUT NOCOPY NUMBER,
     x_return_status   OUT NOCOPY VARCHAR2,
     x_msg_count       OUT NOCOPY NUMBER,
     x_msg_data        OUT NOCOPY VARCHAR2
 ) IS
 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME || '.submit_decrypt_req_set';

 l_api_version    CONSTANT NUMBER := 1.0;
 l_msg_count      NUMBER;
 l_msg_data       VARCHAR2(2000);

 l_phase          VARCHAR2(200);
 l_success BOOLEAN;
 submit_failed EXCEPTION;

 BEGIN
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo(l_module_name, 'ENTER');

    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    FND_MSG_PUB.initialize;

    /* set the context for the request set IBY_SECURITY_DECRYPT_REQ_SET */
    l_success := fnd_submit.set_request_set('IBY', 'IBY_SECURITY_DECRYPT_REQ_SET');
    l_phase := 'After set request set.';

        if ( l_success ) then

           /* submit program IBY_CREDITCARD_DECRYPTION which is in stage STAGE1 */
           l_success := fnd_submit.submit_program('IBY','IBY_CREDITCARD_DECRYPTION', 'STAGE1',
                          '','','','','','','','','','','','','','','','','','','','',
                          '','','','','','','','','','','','','','','','','','','','',
                          '','','','','','','','','','','','','','','','','','','','',
                          '','','','','','','','','','','','','','','','','','','','',
                          '','','','','','','','','','','','','','','','','','','','');
           l_phase := 'After submit program 1.';
           if ( not l_success ) then
              raise submit_failed;
           end if;

           /* submit program IBY_EXT_BANKACCT_DECRYPTION which is in stage STAGE1 */
           l_success := fnd_submit.submit_program('IBY','IBY_EXT_BANKACCT_DECRYPTION', 'STAGE1',
                          '','','','','','','','','','','','','','','','','','','','',
                          '','','','','','','','','','','','','','','','','','','','',
                          '','','','','','','','','','','','','','','','','','','','',
                          '','','','','','','','','','','','','','','','','','','','',
                          '','','','','','','','','','','','','','','','','','','','');
           l_phase := 'After submit program 2.';
           if ( not l_success ) then
              raise submit_failed;
           end if;

           /* submit program IBY_TRXN_EXTENSION_DECRYPTION which is in stage STAGE1 */
           l_success := fnd_submit.submit_program('IBY','IBY_TRXN_EXTENSION_DECRYPTION', 'STAGE1',
                          '','','','','','','','','','','','','','','','','','','','',
                          '','','','','','','','','','','','','','','','','','','','',
                          '','','','','','','','','','','','','','','','','','','','',
                          '','','','','','','','','','','','','','','','','','','','',
                          '','','','','','','','','','','','','','','','','','','','');
           l_phase := 'After submit program 3.';
           if ( not l_success ) then
              raise submit_failed;
           end if;

           /* submit program IBY_TX_CREDITCARD_DECRYPTION which is in stage STAGE1 */
           l_success := fnd_submit.submit_program('IBY','IBY_TX_CREDITCARD_DECRYPTION', 'STAGE1',
                          '','','','','','','','','','','','','','','','','','','','',
                          '','','','','','','','','','','','','','','','','','','','',
                          '','','','','','','','','','','','','','','','','','','','',
                          '','','','','','','','','','','','','','','','','','','','',
                          '','','','','','','','','','','','','','','','','','','','');
           l_phase := 'After submit program 4.';
           if ( not l_success ) then
              raise submit_failed;
           end if;

           /*  Submit the Request set  */
           x_request_id := fnd_submit.submit_set(null,FALSE);
           l_phase := 'After submit request set.';

       else
           l_phase := 'Failed after set request set.';
           raise submit_failed;
       end if;
 EXCEPTION
   WHEN submit_failed THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Exception submit_failed - ' || l_phase);
     END IF;
     FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

   WHEN others THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Exception others.');
	     print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	     print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);
     END IF;
     FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

 END submit_decrypt_req_set;

/*--------------------------------------------------------------------
 | NAME:
 |     get_conc_request_status
 |
 | PURPOSE:
 |     Get the concurrent request id status using the FND API.
 |
 | PARAMETERS:
 |     IN     x_request_id
 |
 | RETURNS: x_request_status (SUCCESS, ERROR, PENDING)
 |
 | NOTES:
 |     Internal API, not for public use.
 |     This API is used by the FD Dashboard to determine if a request
 |     has terminated with error.
 |
 *---------------------------------------------------------------------*/
 FUNCTION get_conc_request_status (
     x_request_id     IN NUMBER)
 RETURN VARCHAR2 AS

   v_call_status   BOOLEAN;
   v_req_phase_t   VARCHAR2(80);
   v_req_status_t  VARCHAR2(80);
   v_req_phase_c   VARCHAR2(30);
   v_req_status_c  VARCHAR2(30);
   v_message       VARCHAR2(240);
   v_request_id    iby_payments_all.request_id%TYPE;

   x_return_status VARCHAR2(30) := 'PENDING';

 BEGIN
   IF (x_request_id IS NOT NULL) THEN
     v_request_id := x_request_id;
     -- call FND API to get request status
     v_call_status := FND_CONCURRENT.get_request_status(
                      v_request_id,
                      null, null,
                      v_req_phase_t, v_req_status_t,
                      v_req_phase_c, v_req_status_c,
                      v_message);

     IF (v_call_status) THEN

       IF (v_req_phase_c = 'COMPLETE') THEN
         IF (v_req_status_c IN ('ERROR', 'CANCELLED', 'TERMINATED')) THEN
           x_return_status := 'ERROR';
         END IF;
       END IF;
     ELSE
       x_return_status := 'ERROR';
     END IF;
   ELSE
     x_return_status := 'SUCCESS';
   END IF;

   RETURN x_return_status;
 END get_conc_request_status;

/*--------------------------------------------------------------------
 | NAME:
 |     print_completed_pmts
 |
 |
 | PURPOSE:
 |     Prints list of payments marked complete using the provided
 |     completion group id.
 |
 |     This function is used for debugging purposes.
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
 |     Internal API, not for public use.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE print_completed_pmts(
             p_completion_id          IN NUMBER
             )
 IS
 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME
                                         || '.print_completed_pmts';

 l_pmts_list     pmtIDTab;

 /*
  * Cursor to pick up all payment ids associated with the
  * provided completion id.
  */
 CURSOR c_pmt_ids (p_complete_id NUMBER)
 IS
 SELECT
     pmt.payment_id
 FROM
     IBY_PAYMENTS_ALL         pmt
 WHERE
     pmt.completed_pmts_group_id = p_complete_id
 ;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');
	     print_debuginfo(l_module_name, 'completion id: ' || p_completion_id);

     END IF;
     FND_MSG_PUB.initialize;

     OPEN  c_pmt_ids (p_completion_id);
     FETCH c_pmt_ids BULK COLLECT INTO l_pmts_list;
     CLOSE c_pmt_ids;

     IF (l_pmts_list.COUNT > 0) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'List of completed payments - ');

         END IF;
         FOR i IN l_pmts_list.FIRST .. l_pmts_list.LAST LOOP

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'pmt id: ' || l_pmts_list(i));

             END IF;
         END LOOP;

     ELSE

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'No completed payments '
	             || 'were retrieved using completion id '
	             || p_completion_id
	             );

         END IF;
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 EXCEPTION
     WHEN OTHERS THEN

     /*
      * This is a non-fatal exception. We will log the exception
      * and return.
      */
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Non-Fatal: Exception occured '
	         || 'when trying to print completed payments using '
	         || 'completion id: '
	         || p_completion_id
	         );

	     print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	     print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);
     END IF;
     FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

 END print_completed_pmts;


/*--------------------------------------------------------------------
 | NAME:
 |     print_completed_docs
 |
 |
 | PURPOSE:
 |     Prints list of documents payable marked complete using the
 |     provided completion group id.
 |
 |     This function is used for debugging purposes.
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
 |     Internal API, not for public use.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE print_completed_docs(
             p_completion_id          IN NUMBER
             )
 IS
 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME
                                         || '.print_completed_docs';

 l_docs_list     docPayIDTab;

 /*
  * Cursor to pick up all document ids associated with the
  * provided completion id.
  */
 CURSOR c_doc_ids (p_complete_id NUMBER)
 IS
 SELECT
     doc.document_payable_id
 FROM
     IBY_DOCS_PAYABLE_ALL        doc
 WHERE
     doc.completed_pmts_group_id = p_complete_id
 ;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');
	     print_debuginfo(l_module_name, 'completion id: ' || p_completion_id);

     END IF;
     FND_MSG_PUB.initialize;

     OPEN  c_doc_ids (p_completion_id);
     FETCH c_doc_ids BULK COLLECT INTO l_docs_list;
     CLOSE c_doc_ids;

     IF (l_docs_list.COUNT > 0) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'List of completed documents - ');

         END IF;
         FOR i IN l_docs_list.FIRST .. l_docs_list.LAST LOOP

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'doc id: ' || l_docs_list(i));

             END IF;
         END LOOP;

     ELSE

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'No completed documents '
	             || 'were retrieved using completion id '
	             || p_completion_id
	             );

         END IF;
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
 EXCEPTION
     WHEN OTHERS THEN

     /*
      * This is a non-fatal exception. We will log the exception
      * and return.
      */
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Non-Fatal: Exception occured '
	         || 'when trying to print completed documents using '
	         || 'completion id: '
	         || p_completion_id
	         );

	     print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
	     print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);
     END IF;
     FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

 END print_completed_docs;


/*--------------------------------------------------------------------
 | NAME:
 |     is_security_function_valid
 |
 | PURPOSE:
 |     This API will return Y or N is the security function passed
 |     is assigned to the user.  This function wraps the
 |     FND_FUNCTION.TEST API.
 |
 | PARAMETERS:
 |     IN     x_security_function_name
 |
 | RETURNS: x_function_valid (Y, N)
 |
 | NOTES:
 |     Internal API, not for public use.
 |     This API is used by the taks list page to determine if a user is
 |     available to do the setup for the Shared, FD or FC tasks.
 |
 *---------------------------------------------------------------------*/
 FUNCTION is_security_function_valid (
     x_security_function_name     IN VARCHAR2)
 RETURN VARCHAR2 AS

   x_return_status VARCHAR2(30) := 'N';

 BEGIN

   IF fnd_function.test(x_security_function_name) THEN
     x_return_status := 'Y';
   END IF;

   RETURN x_return_status;
 END is_security_function_valid;



  /*--------------------------------------------------------------------
 | NAME:
 |    Rejected_user_acc
 |
 |
 | PURPOSE:
 |     Checks whether the user has access to all the org. or payment function
 |      of rejected or removed entities ( documents or payments) for a
 |      given payment service request.
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
 |     Internal API, not for public use.
 |
 *---------------------------------------------------------------------*/
 PROCEDURE Rejected_user_acc(
             p_pay_service_request_id  IN NUMBER,
             x_inaccessible_entities OUT NOCOPY VARCHAR2,
             x_return_status     IN OUT NOCOPY VARCHAR2,
             x_return_message    IN OUT NOCOPY VARCHAR2)
  IS
 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME
                                         || '.Rejected_user_acc';

 l_doc_function_count NUMBER:=0;
 l_doc_org_count NUMBER:=0;
 l_pmt_org_count NUMBER:=0;
BEGIN


IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	print_debuginfo(l_module_name, 'ENTER');
END IF;
--Initializing the out parameter
 x_inaccessible_entities :='N';

FND_MSG_PUB.initialize;

/*Initializing security through CE for populating the
   ce related global tables*/
CEP_STANDARD.init_security();

populatePaymentFunctions(x_return_status, x_return_message);

 /* Initialize return status */
x_return_status := FND_API.G_RET_STS_SUCCESS;

select count(1)
into l_doc_function_count
FROM  IBY_DOCS_PAYABLE_ALL docs
where  docs.document_status IN
        ( 'REJECTED',
          'FAILED_BY_RELATED_DOCUMENT',
          'FAILED_BY_REJECTION_LEVEL',
          'FAILED_BY_CALLING_APP',
          'REMOVED',
          'REMOVED_PAYMENT_REMOVED',
          'REMOVED_REQUEST_TERMINATED',
          'REMOVED_INSTRUCTION_TERMINATED',
          'REMOVED_PAYMENT_STOPPED',
          'REMOVED_PAYMENT_VOIDED')
AND docs.payment_service_request_id = p_pay_service_request_id
and docs.payment_function not in
       (select payment_function
        from IBY_USER_PAY_FUNS_GT
        );
IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	print_debuginfo(l_module_name, 'Number of Missing Payment Function for rejected documents:' ||l_doc_function_count);

END IF;
select count(1)
into l_doc_org_count
FROM  IBY_DOCS_PAYABLE_ALL docs
where  docs.document_status IN
        ( 'REJECTED',
          'FAILED_BY_RELATED_DOCUMENT',
          'FAILED_BY_REJECTION_LEVEL',
          'FAILED_BY_CALLING_APP',
          'REMOVED',
          'REMOVED_PAYMENT_REMOVED',
          'REMOVED_REQUEST_TERMINATED',
          'REMOVED_INSTRUCTION_TERMINATED',
          'REMOVED_PAYMENT_STOPPED',
          'REMOVED_PAYMENT_VOIDED')
AND docs.payment_service_request_id = p_pay_service_request_id
and docs.org_id not in
       (select  organization_id
        from ce_security_profiles_v cep
        where cep.organization_type=docs.org_type
        );

IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	print_debuginfo(l_module_name, 'Number of Missing Orgs for rejected documents:' ||l_doc_org_count);


END IF;
select count(1)
into  l_pmt_org_count
FROM  iby_payments_all payments
where  payments.payment_status IN
                        ('FAILED_BY_REJECTION_LEVEL',
                        'FAILED_BY_CALLING_APP',
                        'REMOVED',
                        'REMOVED_REQUEST_TERMINATED',
                        'REMOVED_INSTRUCTION_TERMINATED',
                        'REMOVED_DOCUMENT_SPOILED',
                        'REMOVED_PAYMENT_STOPPED',
                        'VOID',
                        'REJECTED',
                        'FAILED_VALIDATION')
AND payments.payment_service_request_id = p_pay_service_request_id
and payments.org_id not in
       (select  organization_id
        from ce_security_profiles_v cep
        where cep.organization_type=payments.org_type
        );
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo(l_module_name, 'Number of Missing Org for rejected payments:' ||l_pmt_org_count);

    END IF;
-- check the user access
if(l_doc_function_count<>0 OR l_doc_org_count <>0 OR l_pmt_org_count <>0) THEN

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo(l_module_name, 'User doesnt have full access to the Rejected documents or Rejected Payments for a given payment process Request');

   END IF;
   x_inaccessible_entities:='Y';
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo(l_module_name, 'Returning Y for x_inaccessible_entities');

   END IF;
end if;
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo(l_module_name, 'EXIT');

   END IF;
EXCEPTION
WHEN OTHERS THEN
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo(l_module_name, 'SQL err msg: '
	       || SQLERRM);
	     print_debuginfo(l_module_name, 'Returning failure response .. '
	       );
     END IF;
     FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);
     /*
      * The error message would have already been set.
      * Just set the error status here.
      */
     x_return_status := FND_API.G_RET_STS_ERROR;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');


     END IF;
 END Rejected_user_acc;

/*--------------------------------------------------------------------
 | NAME:
 |     get_vendor_id
 |
 |
 | PURPOSE:
 |     Get the vendor_id from AP tables based on the party_id
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
 PROCEDURE get_vendor_id(
             p_party_id  IN NUMBER,
             x_vendor_id OUT NOCOPY NUMBER)
 IS
 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME
                                         || '.get_vendor_id';
 BEGIN
 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
 print_debuginfo(l_module_name, 'ENTER');
 END IF;
--Initializing the out parameter
 x_vendor_id :=0;
 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
 print_debuginfo(l_module_name, 'Calling AP tables to get the vendor_id');
 END IF;
 -- Calling AP tables to get the vendor_id
     BEGIN
       SELECT vendor_id into x_vendor_id
       from AP_SUPPLIERS
       where party_id = p_party_id;
     EXCEPTION
      WHEN NO_DATA_FOUND THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      print_debuginfo(l_module_name, 'Query returned no rows for vendor_id');
      END IF;
      WHEN OTHERS THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      print_debuginfo(l_module_name, 'Exception occured in the query');
      END IF;
     END;
  print_debuginfo(l_module_name, 'EXIT');

 END get_vendor_id;

 /*--------------------------------------------------------------------
 | NAME:
 |     get_default_bank_acct
 |
 |
 | PURPOSE:
 |     Get the default_bank_acct from IBY API
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
 PROCEDURE get_default_bank_acct(
             currency_code   iby_ext_bank_accounts.currency_code%TYPE,
	     Payee_Party_Id         IBY_EXTERNAL_PAYEES_ALL.payee_party_id%TYPE,
	     Payee_Party_Site_Id    IBY_EXTERNAL_PAYEES_ALL.party_site_id%TYPE,
	     Supplier_Site_Id       IBY_EXTERNAL_PAYEES_ALL.supplier_site_id%TYPE,
	     Payer_Org_Id           IBY_EXTERNAL_PAYEES_ALL.org_id%TYPE,
	     Payer_Org_Type         IBY_EXTERNAL_PAYEES_ALL.org_type%TYPE,
	     Payment_Function       IBY_EXTERNAL_PAYEES_ALL.payment_function%TYPE,
	     old_ext_bank_acct_id       IBY_EXT_BANK_ACCOUNTS.ext_bank_account_id%TYPE,
	     x_default_bank_acct_id OUT NOCOPY iby_ext_bank_accounts.ext_bank_account_id%TYPE)
 IS
 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME
                                         || '.get_default_bank_acct';
 l_trxn_attributes_rec IBY_DISBURSEMENT_COMP_PUB.Trxn_Attributes_Rec_Type;
 l_return_status             VARCHAR2(1);
 l_msg_count                 NUMBER(15);
 l_msg_data                  VARCHAR2(2000);
 l_payee_bankaccounts_tbl    IBY_DISBURSEMENT_COMP_PUB.Payee_BankAccount_Tab_Type;

 BEGIN
 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
 print_debuginfo(l_module_name, 'ENTER');
 END IF;

IF ((g_ext_acct_id_tbl.EXISTS(Supplier_Site_Id||currency_code))) THEN

	 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	 print_debuginfo(l_module_name, 'External Bank Account Id found in cache for Supplier Site id:'||
	 Supplier_Site_Id||' and Currency code:'||currency_code);
	 END IF;
	 	x_default_bank_acct_id := g_ext_acct_id_tbl(Supplier_Site_Id||currency_code).ext_bank_account_id;

ELSE

 --l_trxn_attributes_rec.Application_Id := Application_Id;
 l_trxn_attributes_rec.Payer_Legal_Entity_Id := null;
 l_trxn_attributes_rec.Payer_Org_Id := Payer_Org_Id;
 l_trxn_attributes_rec.Payer_Org_Type := Payer_Org_Type;
 l_trxn_attributes_rec.Payee_Party_Id := Payee_Party_Id;
 l_trxn_attributes_rec.Payee_Party_Site_Id := Payee_Party_Site_Id;
 l_trxn_attributes_rec.Supplier_Site_Id := Supplier_Site_Id;
 l_trxn_attributes_rec.Pay_Proc_Trxn_Type_Code := null;
 l_trxn_attributes_rec.Payment_Currency := currency_code;
 l_trxn_attributes_rec.Payment_Amount := null;
 l_trxn_attributes_rec.Payment_Function := Payment_Function;
 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
 print_debuginfo(l_module_name, 'Payee party Id:: '||Payee_Party_Id);
 print_debuginfo(l_module_name, 'Payee party site Id:: '||Payee_Party_Site_Id);
 print_debuginfo(l_module_name, 'Supplier site Id:: '||Supplier_Site_Id);
 print_debuginfo(l_module_name, 'Org Id:: '||Payer_Org_Id);
 print_debuginfo(l_module_name, 'Org Type:: '||Payer_Org_Type);
 print_debuginfo(l_module_name, 'Payment Function:: '||Payment_Function);
 print_debuginfo(l_module_name, 'currency code:: '||currency_code);
 print_debuginfo(l_module_name, 'Calling IBY_DISBURSEMENT_COMP_PUB.Get_Applicable_Payee_Acc_list to get the default bank account');
 END IF;

 x_default_bank_acct_id := null;
IBY_DISBURSEMENT_COMP_PUB.Get_Applicable_Payee_Acc_list
      (p_api_version			=>  1.0,
       p_init_msg_list			=>  FND_API.G_TRUE,
       p_trxn_attributes_rec		=>  l_trxn_attributes_rec,
       x_return_status			=>  l_return_status,
       x_msg_count			=>  l_msg_count,
       x_msg_data			=>  l_msg_data,
       x_payee_bankaccounts_tbl         =>  l_payee_bankaccounts_tbl);

	IF l_payee_bankaccounts_tbl.COUNT <> 0 THEN

	    for i in l_payee_bankaccounts_tbl.first .. l_payee_bankaccounts_tbl.last loop
		IF l_payee_bankaccounts_tbl(i).Payee_BankAccount_Id = old_ext_bank_acct_id THEN
			IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			print_debuginfo(l_module_name, 'Old bank account is still valid');
			print_debuginfo(l_module_name, 'External Bank account Id:: '||l_payee_bankaccounts_tbl(i).Payee_BankAccount_Id);
			print_debuginfo(l_module_name, 'External Bank Account Num:: '||l_payee_bankaccounts_tbl(i).Payee_BankAccount_Num);
			print_debuginfo(l_module_name, 'External bank Account Name:: '||l_payee_bankaccounts_tbl(i).Payee_BankAccount_Name);
			END IF;
			x_default_bank_acct_id := l_payee_bankaccounts_tbl(i).Payee_BankAccount_Id;
		END IF;
	    end loop;

	    IF x_default_bank_acct_id is null THEN
		x_default_bank_acct_id := l_payee_bankaccounts_tbl(l_payee_bankaccounts_tbl.first).Payee_BankAccount_Id;
		IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			print_debuginfo(l_module_name, 'Old bank account is not valid');
			print_debuginfo(l_module_name, 'External Bank account Id:: '||l_payee_bankaccounts_tbl(l_payee_bankaccounts_tbl.first).Payee_BankAccount_Id);
			print_debuginfo(l_module_name, 'External Bank Account Num:: '||l_payee_bankaccounts_tbl(l_payee_bankaccounts_tbl.first).Payee_BankAccount_Num);
			print_debuginfo(l_module_name, 'External bank Account Name:: '||l_payee_bankaccounts_tbl(l_payee_bankaccounts_tbl.first).Payee_BankAccount_Name);
		END IF;
	    END IF;

	g_ext_acct_id_tbl(Supplier_Site_Id||currency_code).ext_bank_account_id := x_default_bank_acct_id;
	ELSE
	     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'No Valid Bank account');
	     END IF;
	END IF;

END IF;


IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
print_debuginfo(l_module_name, 'Returned External Bank account Id:: '||x_default_bank_acct_id);
print_debuginfo(l_module_name, 'EXIT');
END IF;
END get_default_bank_acct;

Procedure initialize IS
 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME
                                         || '.initialize';
BEGIN
IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
print_debuginfo(l_module_name, 'Enter');
END IF;
     g_ext_acct_id_tbl.DELETE;
IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
print_debuginfo(l_module_name, 'EXIT');
END IF;
END initialize;


FUNCTION Get_Pmt_Completion_Point (
     p_instruction_id           IN   NUMBER
) RETURN VARCHAR2 IS

  l_completion_point VARCHAR2(30);

    CURSOR l_ins_csr (p_payment_instruction_id IN NUMBER) IS
    SELECT pp.MARK_COMPLETE_EVENT
      FROM iby_pay_instructions_all ins,
           iby_payment_profiles pp
     WHERE ins.payment_instruction_id = p_payment_instruction_id
       AND ins.payment_profile_id = pp.payment_profile_id;

BEGIN

    OPEN l_ins_csr(p_instruction_id);
    FETCH l_ins_csr INTO l_completion_point;

  RETURN l_completion_point;

END Get_Pmt_Completion_Point;


END IBY_DISBURSE_UI_API_PUB_PKG;


/
