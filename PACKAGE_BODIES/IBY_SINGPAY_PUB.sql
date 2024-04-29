--------------------------------------------------------
--  DDL for Package Body IBY_SINGPAY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_SINGPAY_PUB" AS
/*$Header: ibypsinb.pls 120.31.12010000.4 2009/03/06 14:59:03 visundar ship $*/

 --
 -- Declare global variables
 --
 G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBY_SINGPAY_PUB';

 --
 -- List of document statuses that are used / set in this
 -- module (payment creation flow).
 --
 DOC_STATUS_VALIDATED    CONSTANT VARCHAR2(100) := 'VALIDATED';
 DOC_STATUS_PAY_CREATED  CONSTANT VARCHAR2(100) := 'PAYMENTS_CREATED';
 DOC_STATUS_CA_FAILED    CONSTANT VARCHAR2(100) := 'FAILED_BY_CALLING_APP';
 DOC_STATUS_RELN_FAIL    CONSTANT VARCHAR2(100) := 'FAILED_BY_RELATED_DOCUMENT';
 DOC_STATUS_PAY_VAL_FAIL CONSTANT VARCHAR2(100) := 'PAYMENT_FAILED_VALIDATION';
 DOC_STATUS_FAIL_BY_REJLVL CONSTANT VARCHAR2(100)
                                                := 'FAILED_BY_REJECTION_LEVEL';

 --
 -- List of payment statuses that are used / set in this
 -- module (payment creation flow).
 --
 PAY_STATUS_REJECTED       CONSTANT VARCHAR2(100) := 'REJECTED';
 PAY_STATUS_FAIL_VALID     CONSTANT VARCHAR2(100) := 'FAILED_VALIDATION';
 PAY_STATUS_CREATED        CONSTANT VARCHAR2(100) := 'CREATED';
 PAY_STATUS_CA_FAILED      CONSTANT VARCHAR2(100) := 'FAILED_BY_CALLING_APP';
 PAY_STATUS_FAIL_BY_REJLVL CONSTANT VARCHAR2(100)
                                        := 'FAILED_BY_REJECTION_LEVEL';

 --
 -- List of payment request statuses that are set in this
 -- module (payment creation flow).
 --
 REQ_STATUS_PAY_CRTD      CONSTANT VARCHAR2(100) := 'PAYMENTS_CREATED';
 REQ_STATUS_FAIL_PAY_CR   CONSTANT VARCHAR2(100) := 'FAILED_PAYMENT_VALIDATION';
 REQ_STATUS_USER_REVW     CONSTANT VARCHAR2(100) := 'PENDING_REVIEW';
 REQ_STATUS_USER_REVW_ERR CONSTANT VARCHAR2(100)
                                       := 'PENDING_REVIEW_PMT_VAL_ERRORS';

 --
 -- List of rejection level system options  that are possible for
 -- this module (payment creation flow).
 --
 REJ_LVL_REQUEST  CONSTANT VARCHAR2(100) := 'REQUEST';
 REJ_LVL_PAYMENT  CONSTANT VARCHAR2(100) := 'PAYMENT';
 REJ_LVL_NONE     CONSTANT VARCHAR2(100) := 'NONE';

 -- Transaction types (for inserting into IBY_TRANSACTION_ERRORS table)
 TRXN_TYPE_DOC   CONSTANT VARCHAR2(100) := 'DOCUMENT_PAYABLE';
 TRXN_TYPE_PMT   CONSTANT VARCHAR2(100) := 'PAYMENT';

/*--------------------------------------------------------------------
 | NAME:
 |     createPayments
 |
 | PURPOSE:
 |     Entry point for payment creation flow. All payment grouping
 |     rules are handled within this method.
 |
 |     This method is very similar to createPayments(..) in the
 |     IBY_PAYGROUP_PUB package. That package is meant for normal
 |     build program flow, whereas this package is meant for single
 |     payments flow.
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
 PROCEDURE createPayments(
     p_payment_request_id         IN IBY_PAY_SERVICE_REQUESTS.
                                         payment_service_request_id%TYPE,
     p_pmt_rejection_level        IN IBY_INTERNAL_PAYERS_ALL.
                                         payment_rejection_level_code%TYPE,
     p_review_proposed_pmts_flag  IN IBY_INTERNAL_PAYERS_ALL.
                                         require_prop_pmts_review_flag%TYPE,
     p_override_complete_point    IN VARCHAR2,
     p_bill_payable_flag          IN         VARCHAR2,
     p_maturity_date              IN         DATE,
     x_return_status      IN OUT NOCOPY VARCHAR2)
 IS

 l_module_name           VARCHAR2(200) := G_PKG_NAME || '.createPayments';

 /* these are related to central bank reporting */
 l_decl_option             VARCHAR2(100) := '';
 l_decl_only_fx_flag       VARCHAR2(1)   := '';
 l_decl_curr_fx_rate_type  VARCHAR2(255) := '';
 l_decl_curr_code          VARCHAR2(10)  := '';
 l_decl_threshold_amount   NUMBER(15)    := 0;

/* Bug 5709596 */
-- l_cbrTab                  IBY_PAYGROUP_PUB.centralBankReportTabType;

 l_ca_payreq_cd            VARCHAR2(255) := '';
 l_ca_id                   NUMBER(15)    := 0;
 l_all_pmts_success_flag   BOOLEAN       := FALSE;
 l_all_pmts_failed_flag    BOOLEAN       := FALSE;

 /* rejection level system options */
 l_rejection_level         VARCHAR2(200);
 l_review_pmts_flag        VARCHAR2(1)   := 'N';

 l_paymentTab        IBY_PAYGROUP_PUB.paymentTabType;
 l_docsInPmtTab      IBY_PAYGROUP_PUB.docsInPaymentTabType;

 /* these two are passed to calling app via hook */
 l_hookPaymentTab    IBY_PAYGROUP_PUB.hookPaymentTabType;
 l_hookDocsInPmtTab  IBY_PAYGROUP_PUB.hookDocsInPaymentTabType;

 /* holds the error messages against failed documents */
 l_docErrorTab       IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docTokenTab       IBY_VALIDATIONSETS_PUB.trxnErrTokenTabType;

 /* payment request imposed limits on payments */
 /* not used but needs to be passed into performDocumentGrouping() method */
 l_payReqCriteria    IBY_PAYGROUP_PUB.payReqImposedCriteria;

 BEGIN

     print_debuginfo(l_module_name, 'ENTER');

     print_debuginfo(l_module_name, 'Payment Request Id : '||
         p_payment_request_id);

     /*
      * Group the documents of the payment request into payments.
      */
     IBY_PAYGROUP_PUB.performDocumentGrouping(p_payment_request_id
       , l_paymentTab
       , l_docsInPmtTab
       , l_ca_id
       , l_ca_payreq_cd
       , l_payReqCriteria
--     , l_cbrTab
       );

     print_debuginfo(l_module_name, 'After grouping '
         || l_paymentTab.COUNT   || ' payment(s) from '
         || l_docsInPmtTab.COUNT || ' document(s) for payment request '
         || p_payment_request_id || ' were created.'
         );

     /*
      * IMPORTANT CHECK FOR SINGLE PAYMENTS:
      *
      * After hardcoded grouping not more than one payment should be
      * created from the given documents for the single payment flow.
      *
      * This is because the calling app is expected to have performed
      * the hardcoded grouping before the single payment API is invoked.
      *
      * If we have created more than one payment from the given document,
      * it is an error and return failure.
      */
     IF (l_paymentTab.COUNT <> 1) THEN

         print_debuginfo(l_module_name, 'Application of hardcoded '
             || 'grouping rules did not generate exactly one payment. '
             || 'Only one payment can be created for single payments. '
             || 'Payment creation failed.'
             );

         x_return_status := FND_API.G_RET_STS_ERROR;

         APP_EXCEPTION.RAISE_EXCEPTION;

     END IF;

     /*
      * Fix for bug 5357948:
      *
      * Search for common attributes of the documents
      * of each payment, and set the corresponding
      * attribute on the parent payment itself if
      * such a common attribute is found.
      */
     IBY_PAYGROUP_PUB.sweepCommonPmtAttributes(l_paymentTab, l_docsInPmtTab);

     /*
      * Set the default attributes for the created payments.
      */
     initializePmts(l_paymentTab);

     /*
      * Handle credit memos
      */

     /*
      * Update: Credit memo handling is now performed at the calling
      * application itself.
      * - rameshsh, 3/29/2005
      */
     --printDocsInPmtTab(l_docsInPmtTab);
     --performCreditMemoHandling(l_paymentTab, l_docsInPmtTab);
     --printDocsInPmtTab(l_docsInPmtTab);

     /*
      * Maturity date calculation
      *
      * For bills payable
      *   a.k.a promissory notes
      *   a.k.a future dated payments
      */

     /*
      * Fix for bug 5334222:
      *
      * There is no need to calculate the maturity date for
      * single payments. The maturity date for single payments
      * is expected to be passed in.
      *
      * Simply assign the passed in maturity date to the
      * created payment in case it is a bills payable.
      */
     IF (UPPER(p_bill_payable_flag) = 'Y') THEN

         /*
          * We can use index 1 to access the payment because
          * only one payment is expected to be created
          * (this being a single payment).
          */
         l_paymentTab(1).maturity_date := p_maturity_date;

         /*
          * Fix for bug 5334222:
          *
          * Set the bills payable flag to 'Y' whenever the
          * maturity date is set.
          */
         l_paymentTab(1).bill_payable_flag := 'Y';

         print_debuginfo(l_module_name, 'Payment '
             || l_paymentTab(1).payment_id
             || ' is a bills payable; Maturity date '
             || ' set to '
             || l_paymentTab(1).maturity_date
             );

     ELSE

         print_debuginfo(l_module_name, 'Not setting maturity '
             || 'date for payment '
             || l_paymentTab(1).payment_id
             || ' as it is not a bill payable.'
             );

     END IF;

     /*
      * Fix for bug 5935493:
      *
      * Payment validations are dependent upon finding the
      * payments in the IBY_PAYMENTS_ALL table. Therefore, insert
      * the payments from the PLSQL table into the
      * IBY_PAYMENTS_ALL table.
      *
      * Central bank reporting could be implemented via a hook
      * that is expecting payments to be populated in
      * IBY_PAYMENTS_ALL table. Therefore, payments need to
      * inserted before performing central bank reporting as well.
      */
     IBY_PAYGROUP_PUB.insertPayments(l_paymentTab);

     /*
      * Fix for bug 5972585:
      *
      * Update the documents payable that are part of the created
      * payments with payment ids.
      *
      * This is normally done in performDBUpdates(..) call at
      * the end of this method. However, some customers might
      * want to do custom validations on documents that are
      * part of the created payments. Therefore, update the
      * documents with payment ids before the payment validation
      * call.
      *
      * We do this even before central bank reporting because
      * again the customer could potentially want to retrieve
      * documents that are part of the created payments in the
      * central bank reporting hook.
      */
     IBY_PAYGROUP_PUB.updateDocsWithPaymentID(l_docsInPmtTab);

     /*
      * Fix for bug 5972585:
      *
      * Update the payments table with audit data before
      * calling central bank reporting or payment validations.
      *
      * This is because the customer could have implemented
      * custom central bank reporting or custom payment
      * validations that could depend upon the denormalized
      * payment attributes being present in the the payments
      * table.
      */

     /*
      * Fix for bug 5511781:
      *
      * Along with the payment we insert the audit data for the
      * payment as well. These are denormalized data from payment
      * related tables like payee, payer, payee bank, payer bank
      * etc.
      *
      * This information is also used by the extract and format
      * logic.
      */
     IBY_PAYGROUP_PUB.auditPaymentData(l_paymentTab);

     /*
      * Fix for bug 5337671:
      *
      * Perform central bank reporting prior to calling
      * payment validations.
      *
      * This is because some validations are dependent upon
      * whether the payment has the 'declare payment flag'
      * set to 'Y'.
      */

     /*
      * Perform declarations / central bank reporting.
      */
     IBY_PAYGROUP_PUB.performCentralBankReporting(
         l_paymentTab
       , l_docsInPmtTab
--     , l_cbrTab
         );

     /*
      * Fix for bug 5935493:
      *
      * After central bank reporting is completed,
      * the declare payments flag could be set on some/all
      * payments by the hook. Therefore, we need to
      * update the payments in IBY_PAYMENTS_ALL table
      * so that this flag is accessible for validation.
      */
     IBY_PAYGROUP_PUB.updatePayments(l_paymentTab);


     /*
      * Payment validations
      */
     IBY_PAYGROUP_PUB.applyPaymentValidationSets(p_payment_request_id,l_paymentTab,
         l_docsInPmtTab, l_docErrorTab, l_docTokenTab);


    /* Validation check for negative payment amounts
     * Added for the Bug 7344352
     */
    negativePmtAmountCheck(l_paymentTab,
         l_docsInPmtTab, l_docErrorTab, l_docTokenTab);

     /*
      * Payment grouping number validation.
      */

     /*
      * Commented out because of performance impact
      * - Ramesh, Nov 17 2006.
      */
     --IBY_PAYGROUP_PUB.performPmtGrpNumberValidation(l_paymentTab,
     --    l_docsInPmtTab, l_docErrorTab, l_docTokenTab);

     /*
      * Payment validation might have failed some payments (and by
      * cascade, the documents that were part of these payments).
      *
      * Make sure to fail related documents whenever documents are
      * failed.
      */
     IBY_PAYGROUP_PUB.adjustSisterDocsAndPmts(l_paymentTab,
         l_docsInPmtTab, l_docErrorTab, l_docTokenTab);

     /*
      * Call post-payment creation hook. This hook will pass
      * the created payments to the calling application for
      * approval/adjustment.
      *
      * The adjusted payments are read back and inserted into
      * IBY_PAYMENTS_LL table.
      *
      * This is a general hook that is called for all other
      * products except AP. For AP special hooks are called
      * below.
      */
     IF (l_ca_id <> 200) THEN

         /*
          * Only successful payments are passed to be passed to
          * to the calling application via the hook / callout.
          *
          * From the existing list of all payments, create new data
          * structures that only store successful payments. This
          * 'success only' list of payments will be passed to the
          * calling application.
          *
          * This method writes the payment data to global temp tables.
          */
         IBY_PAYGROUP_PUB.performPreHookProcess(
             l_ca_payreq_cd, l_ca_id, l_paymentTab,
             l_docsInPmtTab, l_hookPaymentTab,
             l_hookDocsInPmtTab);

         /*
          * Hook to call external application for implementation of the
          * following functionality:
          *
          * 1. Bank charge calculation
          * 2. Tax withtholding
          *
          * Any other miscellaneous correction of payment/document data
          * is also allowed in the hook.
          */
         IBY_PAYGROUP_PUB.callHook(p_payment_request_id);

         /*
          * The external app may decide not to pay a document(s)
          * within a payment, or may decide not to make a payment(s).
          * In such cases, the external app will set the 'don't pay flag'
          * and provide a 'don't pay reason' at the document / payment
          * level (as appropriate) in the provided data structures.
          *
          * If a document(s) is marked as don't pay, then we must
          * adjust the payment amount appropriately.
          *
          * Also, some documents are related via 'payment grouping number'.
          * All documents that are related must be failed and their
          * constituent payment amounts must be adjusted
          *
          * This method reads the payment data from global temp tables.
          */
         IBY_PAYGROUP_PUB.performPostHookProcess(
             l_paymentTab, l_docsInPmtTab,
             l_hookPaymentTab, l_hookDocsInPmtTab,
             l_docErrorTab, l_docTokenTab);

     END IF; -- if calling product <> AP


     /*
      * SPECIAL HOOKS FOR AP:
      *
      * NOTE:
      * -----
      * + Extended withholding hook should not be invoked for
      *   single payments.
      *
      * + Japanese bank charges hook should not be invoked for
      *   single payments.
      */
     IF (l_ca_id = 200) THEN
         print_debuginfo(l_module_name, 'Not invoking any AP hooks.');
     END IF;

     /*
      * Flag payments that require separate remittance
      * advice.
      */
     IBY_PAYGROUP_PUB.flagSeparateRemitAdvicePmts(l_paymentTab,
         l_docsInPmtTab);

     /*
      * Get the rejection level system option and pass
      * it to subsequent methods.
      */

     /*
      * For single payments, there is no concept of
      * payment rejection level system option. In the
      * single payments flow, only one payment will be
      * created, so if the payment fails, the request
      * fails.
      *
      * So for single payments, the payment rejection
      * level is implictly 'REQUEST'.
      */
     l_rejection_level := 'REQUEST';

     /*
      * There is no question of reviewing the payment for
      * single payments. Review payments flag is only
      * applicable to standard payments built by the
      * Build Program.
      *
      * Hardcode the review payments flag to 'N' for single
      * payments.
      */
     l_review_pmts_flag := 'N';

     /*
      * All payments for this payment request have been
      * created and stored in a PLSQL table. Now write these
      * payments to the database.
      *
      * Similarly, update the documents table by providing a
      * payment id to each document.
      */
     performDBUpdates(p_payment_request_id, l_rejection_level,
         l_review_pmts_flag, p_override_complete_point,
         l_paymentTab, l_docsInPmtTab, l_all_pmts_success_flag,
         l_all_pmts_failed_flag, x_return_status,
         l_docErrorTab, l_docTokenTab
         );

     /*
      * NOTE:
      *
      * Do not raise business events / invoke callouts for
      * single payments. This is because Single Payments API
      * is a synchronous API and we do not commit any data if
      * there are validation failures.
      */

     print_debuginfo(l_module_name, 'EXIT');

 END createPayments;

/*--------------------------------------------------------------------
 | NAME:
 |     performDBUpdates
 |
 | PURPOSE:
 |     This is the top level method that is called by the
 |     payment creation program to:
 |         1. insert payments to DB
 |         2. update documents with payment id
 |         3. update status of payment request
 |
 |     This method will read the 'rejection level' system option
 |     and do updates accordingly.
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
     p_payreq_id          IN            IBY_PAY_SERVICE_REQUESTS.
                                          payment_service_request_id%type,
     p_rej_level          IN            VARCHAR2,
     p_review_pmts_flag   IN            VARCHAR2,
     p_override_compl_pt  IN            VARCHAR2,
     x_paymentTab         IN OUT NOCOPY IBY_PAYGROUP_PUB.paymentTabType,
     x_docsInPmtTab       IN OUT NOCOPY IBY_PAYGROUP_PUB.docsInPaymentTabType,
     x_allPmtsSuccessFlag IN OUT NOCOPY BOOLEAN,
     x_allPmtsFailedFlag  IN OUT NOCOPY BOOLEAN,
     x_return_status      IN OUT NOCOPY VARCHAR2,
     x_docErrorTab        IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.
                                            docErrorTabType,
     x_errTokenTab        IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.
                                            trxnErrTokenTabType
     )
 IS
 l_module_name       VARCHAR2(200)  := G_PKG_NAME || '.performDBUpdates';
 l_allsuccess_flag   BOOLEAN := TRUE;
 l_allfailed_flag    BOOLEAN := TRUE;
 l_request_status    VARCHAR2(200);

 --l_doc_err_rec       IBY_VALIDATIONSETS_PUB.docErrorRecType;
 l_doc_err_rec       IBY_TRANSACTION_ERRORS%ROWTYPE;

 l_triggering_pmt_id IBY_PAYMENTS_ALL.payment_id%TYPE;

 BEGIN

     print_debuginfo(l_module_name, 'ENTER');

     /*
      * Print the rejection level system option
      */
     print_debuginfo(l_module_name, 'Rejection level system option set to: '
         || p_rej_level);

     /*
      * Find out whether all the payments within this
      * payment request have 'success' status. This
      * information is used below.
      */
     FOR i in  x_paymentTab.FIRST ..  x_paymentTab.LAST LOOP
         IF (x_paymentTab(i).payment_status <> PAY_STATUS_CREATED) THEN
             l_triggering_pmt_id := x_paymentTab(i).payment_id;
             l_allsuccess_flag := FALSE;
             print_debuginfo(l_module_name, 'At least one payment has '
                 || 'failed validation.');
             EXIT WHEN (1=1);
         END IF;
     END LOOP;

     /*
      * Check if all payments have failed for this
      * payment request. This information is used below.
      */
     FOR i in  x_paymentTab.FIRST .. x_paymentTab.LAST LOOP
         IF (x_paymentTab(i).payment_status = PAY_STATUS_CREATED) THEN
             l_allfailed_flag := FALSE;
             print_debuginfo(l_module_name, 'At least one payment has '
                 || 'has been successfully validated.');
             EXIT WHEN (1=1);
         END IF;
     END LOOP;

     /*
      * Update the status of the payments/documents
      * as per the rejection level (if necessary).
      */
     IF (p_rej_level = REJ_LVL_REQUEST) THEN

         IF (l_allsuccess_flag = FALSE) THEN
             /*
              * This means that at least one payment in this
              * payment request has failed.
              *
              * For 'request' rejection level:
              * If any payment in the request fails validation,
              * the entire payment request should be rejected;
              * So fail all payments in this payment request.
              */
             print_debuginfo(l_module_name, 'Failing all payments and '
                     || 'documents for payment request '
                     || p_payreq_id);
             FOR i in  x_paymentTab.FIRST ..  x_paymentTab.LAST LOOP

                 IF (x_paymentTab(i).payment_status = PAY_STATUS_CREATED) THEN

                     x_paymentTab(i).payment_status :=
                         PAY_STATUS_FAIL_BY_REJLVL;

                     /*
                      * Once we fail a payment, we need to create
                      * an error record and insert this record
                      * into the errors table.
                      */
                     IBY_BUILD_UTILS_PKG.createErrorRecord(
                         TRXN_TYPE_PMT,
                         x_paymentTab(i).payment_id,
                         x_paymentTab(i).payment_status,
                         NULL,
                         x_paymentTab(i).payment_id,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         l_doc_err_rec,
                         x_errTokenTab,
                         l_triggering_pmt_id
                         );

                     IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(
                         l_doc_err_rec, x_docErrorTab, x_errTokenTab);

                     IBY_PAYGROUP_PUB.failDocsOfPayment(
                         x_paymentTab(i).payment_id,
                         DOC_STATUS_PAY_VAL_FAIL,
                         x_docsInPmtTab, x_docErrorTab,
                         x_errTokenTab);

                 END IF;

             END LOOP;

             /* set the status of the payment request to failed */
             l_request_status := REQ_STATUS_FAIL_PAY_CR;

         ELSE

             /*
              * For single payments, ignore the review proposed
              * payments flag and blindly set the request status
              * to 'payments created'.
              */

             /* set the status of the payment request to pmts created */
             l_request_status := REQ_STATUS_PAY_CRTD;

         END IF;

     ELSIF (p_rej_level = REJ_LVL_PAYMENT) THEN

         /*
          * Check if all payments in the request have failed.
          */
         IF (l_allfailed_flag = TRUE) THEN

             l_request_status := REQ_STATUS_FAIL_PAY_CR;

         ELSE

             /*
              * At least one payment in the request was
              * successful.
              */

             /*
              * For single payments, ignore the review proposed
              * payments flag and blindly set the payment
              * status to 'payments created'.
              */

             /* set the status of the payment request to pmts created */
             l_request_status := REQ_STATUS_PAY_CRTD;

             print_debuginfo(l_module_name, 'Review proposed payments '
                 || 'flag has not been set. Setting status of successful '
                 || 'request to created.');

         END IF;

     ELSIF (p_rej_level = REJ_LVL_NONE) THEN

         /*
          * For single payments, ignore the review proposed
          * payments flag and the user review errors flag.
          */
         IF (l_allfailed_flag = TRUE) THEN
             l_request_status := REQ_STATUS_FAIL_PAY_CR;
         ELSE
             l_request_status := REQ_STATUS_PAY_CRTD;
         END IF;

     ELSE

         print_debuginfo(l_module_name, 'Unknown rejection level: '
             || p_rej_level
             || '. Aborting payment creation ..' );

         APP_EXCEPTION.RAISE_EXCEPTION;

     END IF;

     /*
      * If this single payment has been created successfully,
      * and the override completion point flag is set, then set
      * the payment completed flag to 'yes'.
      */
     IF (x_allPmtsSuccessFlag = TRUE) THEN
         IF (UPPER(p_override_compl_pt) = 'Y') THEN
             FOR i IN x_paymentTab.FIRST .. x_paymentTab.LAST LOOP
                 x_paymentTab(i).payments_complete_flag := 'Y';
             END LOOP;
         END IF;
     END IF;

     /*
      * All payments for this payment request have been
      * created and stored in a PLSQL table. Now write these
      * payments to the database.
      */
     IBY_PAYGROUP_PUB.updatePayments(x_paymentTab);

     /*
      * Update the documents table by providing a payment id to
      * each document.
      */
     IBY_PAYGROUP_PUB.updateDocsWithPaymentID(x_docsInPmtTab);

     /*
      * If any payments/documents were failed, the IBY_TRANSACTION_
      * ERRORS table must be populated with the corresponding error
      * messages.
      */
     IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N', x_docErrorTab,
         x_errTokenTab);

     /*
      * Update the status of the payment request.
      */
     print_debuginfo(l_module_name, 'Updating status of payment request '
         || p_payreq_id || ' to ' || l_request_status || '.');

     UPDATE
         IBY_PAY_SERVICE_REQUESTS
     SET
         payment_service_request_status = l_request_status
     WHERE
         payment_service_request_id = p_payreq_id
     ;

     /* Pass back the request status to the caller */
     x_return_status := l_request_status;

     /*
      * Pass the 'all payments success' and 'all payments
      * failed' flags back to the caller.
      *
      * These flag will be used in raising business events.
      */
     x_allPmtsSuccessFlag := l_allsuccess_flag;
     x_allPmtsFailedFlag  := l_allfailed_flag;

     print_debuginfo(l_module_name, 'EXIT');

 EXCEPTION

     WHEN OTHERS THEN
         print_debuginfo(l_module_name, 'Fatal: Exception when updating '
             || 'payment request/payment/document status after payment '
             || 'creation. All changes will be rolled back. Payment request '
             || 'id is ' || p_payreq_id);
         print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
         print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);

         /*
          * Propogate exception to caller.
          */
         RAISE;

 END performDBUpdates;

/*--------------------------------------------------------------------
 | NAME:
 |     initializePmts
 |
 | PURPOSE:
 |     Sets the default attributes for a created payment such as
 |     payment status, process type etc.
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
 PROCEDURE initializePmts(
     x_paymentTab      IN OUT NOCOPY IBY_PAYGROUP_PUB.paymentTabType
     )
 IS
 BEGIN

     IF (x_paymentTab.COUNT = 0) THEN
         RETURN;
     END IF;

     FOR i IN x_paymentTab.FIRST .. x_paymentTab.LAST LOOP

         x_paymentTab(i).payment_status                 := 'CREATED';
         x_paymentTab(i).process_type                   := 'IMMEDIATE';
         x_paymentTab(i).payments_complete_flag         := 'N';
         x_paymentTab(i).bill_payable_flag              := 'N';
         x_paymentTab(i).exclusive_payment_flag         := 'N';
         x_paymentTab(i).separate_remit_advice_req_flag := 'N';
         x_paymentTab(i).declare_payment_flag           := 'N';
         x_paymentTab(i).pregrouped_payment_flag        := 'N';
         x_paymentTab(i).stop_confirmed_flag            := 'N';
         x_paymentTab(i).stop_released_flag             := 'N';
         x_paymentTab(i).stop_request_placed_flag       := 'N';
         x_paymentTab(i).created_by                     := fnd_global.user_id;
         x_paymentTab(i).creation_date                  := sysdate;
         x_paymentTab(i).last_updated_by                := fnd_global.user_id;
         x_paymentTab(i).last_update_login              := fnd_global.user_id;
         x_paymentTab(i).last_update_date               := sysdate;
         x_paymentTab(i).object_version_number          := 1;

     END LOOP;

 END initializePmts;


 /*--------------------------------------------------------------------
 | NAME:
 |     negativePmtAmountCheck
 |
 | PURPOSE: Validation to check that payment amount is not a negative
 |value
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
 | NOTES: Added for the bug 7344352
 |
 *---------------------------------------------------------------------*/
 PROCEDURE negativePmtAmountCheck(
     x_paymentTab      IN OUT NOCOPY IBY_PAYGROUP_PUB.paymentTabType,
     x_docsInPmtTab  IN OUT NOCOPY IBY_PAYGROUP_PUB.docsInPaymentTabType,
     x_docErrorTab   IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
     x_errTokenTab   IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.trxnErrTokenTabType
     )
 IS
  l_module_name   VARCHAR2(200)  := G_PKG_NAME || '.negativePmtAmountCheck';
  l_doc_err_rec   IBY_TRANSACTION_ERRORS%ROWTYPE;
  l_error_code    VARCHAR2(100);
  l_error_msg     VARCHAR2(500);
  l_token_rec     IBY_TRXN_ERROR_TOKENS%ROWTYPE;
 BEGIN
            print_debuginfo(l_module_name, 'ENTER');

	         FOR i in x_paymentTab.FIRST ..  x_paymentTab.LAST LOOP

                      IF (x_paymentTab(i).payment_status = PAY_STATUS_CREATED) THEN

			    IF (x_paymentTab(i).payment_amount < 0) THEN

				 x_paymentTab(i).payment_status
				     := PAY_STATUS_REJECTED;

				 print_debuginfo(l_module_name, 'Failed payment '
				     || x_paymentTab(i).payment_id
				     || ' because payment amount '
				     || x_paymentTab(i).payment_amount
                                     ||' is less than zero'
				     );

				 l_error_code := 'IBY_PMT_NEGATIVE_AMT';
				 FND_MESSAGE.set_name('IBY', l_error_code);

				 FND_MESSAGE.SET_TOKEN('PMT_AMOUNT',
				     x_paymentTab(i).payment_amount,
				     FALSE);

				 l_token_rec.token_name  := 'PMT_AMOUNT';
				 l_token_rec.token_value := x_paymentTab(i).payment_amount;
				 x_errTokenTab(x_errTokenTab.COUNT + 1) := l_token_rec;

				 /*
				  * Once we fail a payment, we need to create
				  * an error record and insert this record
				  * into the errors table.
				  */
				 IBY_BUILD_UTILS_PKG.createPmtErrorRecord(
				     x_paymentTab(i).payment_id,
				     x_paymentTab(i).payment_status,
				     l_error_code,
				     FND_MESSAGE.get,
				     l_doc_err_rec
				     );

				 IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(
				     l_doc_err_rec, x_docErrorTab, x_errTokenTab);

				 /* fail the docs of this payment */
				 IBY_PAYGROUP_PUB.failDocsOfPayment(x_paymentTab(i).payment_id,
				     DOC_STATUS_PAY_VAL_FAIL, x_docsInPmtTab,
				     x_docErrorTab, x_errTokenTab);

			     END IF;
			 END IF;
	        END LOOP;
            print_debuginfo(l_module_name, 'EXIT');
 END negativePmtAmountCheck;




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
 PROCEDURE print_debuginfo(p_module IN VARCHAR2,
     p_debug_text IN VARCHAR2)
 IS

 BEGIN

     /*
      * Write the debug message to the concurrent manager log file.
      */
     iby_build_utils_pkg.print_debuginfo(p_module, p_debug_text);

 END print_debuginfo;


END IBY_SINGPAY_PUB;

/
