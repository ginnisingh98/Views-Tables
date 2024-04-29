--------------------------------------------------------
--  DDL for Package Body IBY_ASSIGN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_ASSIGN_PUB" AS
/*$Header: ibyasgnb.pls 120.12.12010000.5 2009/09/08 11:19:34 jnallam ship $*/

 --
 -- Declare global variables
 --
 G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBY_ASSIGN_PUB';
 G_LEVEL_STATEMENT CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
 G_CUR_RUNTIME_LEVEL CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
 G_LEVEL_UNEXPECTED CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
 G_LEVEL_ERROR CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
 G_LEVEL_EXCEPTION CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
 G_LEVEL_EVENT CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
 G_LEVEL_PROCEDURE CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;

 --
 -- List of document statuses that are set in this
 -- module (assignment flow).
 --
 DOC_STATUS_MISSING_ACC   CONSTANT VARCHAR2(100) := 'MISSING_ACCOUNT';
 DOC_STATUS_MISSING_PROF  CONSTANT VARCHAR2(100) := 'MISSING_PROFILE';
 DOC_STATUS_MISSING_BOTH  CONSTANT VARCHAR2(100) :=
     'MISSING_ACCOUNT_AND_PROFILE';
 DOC_STATUS_FULL_ASSIGNED CONSTANT VARCHAR2(100) := 'READY_FOR_VALIDATION';

 --
 -- List of payment request statuses that are set in this
 -- module (assignment flow).
 --
 REQ_STATUS_FULL_ASSIGNED CONSTANT VARCHAR2(100) := 'ASSIGNMENT_COMPLETE';
 REQ_STATUS_INFO_REQD     CONSTANT VARCHAR2(100) := 'INFORMATION_REQUIRED';


TYPE DefualtInternalBankAcctType IS RECORD (
     internal_bank_account_id     CE_BANK_ACCOUNTS.bank_account_id%TYPE,
     l_is_valid BOOLEAN
     );

TYPE l_int_bank_accts_tbl_type IS TABLE OF DefualtInternalBankAcctType INDEX BY VARCHAR2(2000);
 l_int_bank_accts_tbl  l_int_bank_accts_tbl_type;

 l_int_bank_accts_index varchar2(2000);

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
 |     performAssignments
 |
 | PURPOSE:
 |     The entry point for the account/profile assigments flow (F4).
 |     This method picks up all documents for the payment request
 |     and checks if any of them have a missing iinternal bank account
 |     or payment profile.
 |
 |     If yes, then it tries to default the missing account/profile
 |     from (a) the request, (b) from CE API for bank accounts, (c)
 |     from payment method for profile
 |
 |     If it is not possible to default account/profile, the document
 |     status is updated to 'missing account/profile'.
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
 PROCEDURE performAssignments(
     p_payment_request_id IN IBY_PAY_SERVICE_REQUESTS.
                                 payment_service_request_id%type,
     x_return_status      IN OUT NOCOPY VARCHAR2)
 IS

 l_module_name          CONSTANT VARCHAR2(200) := G_PKG_NAME ||
                                                      '.performAssignments';
 l_profile_id           iby_docs_payable_all.payment_profile_id%TYPE := -1;

 dummybankAccountsArray IBY_ASSIGN_PUB.bankAccounts;
 bankAccountsArray      CE_BANK_AND_ACCOUNT_UTIL.BankAcctIdTable;

 l_assignCriTab         IBY_ASSIGN_PUB.assignCriteriaTabType;
 l_updateDocsRec        IBY_ASSIGN_PUB.updateDocAttributesRec;
 l_setDocsRec           IBY_ASSIGN_PUB.setDocAttributesRec;
 l_setDocsTab           IBY_ASSIGN_PUB.setDocAttribsTabType;

 l_acct_default_flag    BOOLEAN := false;
 l_prof_default_flag    BOOLEAN := false;

 G_LINES_PER_FETCH      CONSTANT  NUMBER:= 1000;
 l_trx_line_index       BINARY_INTEGER;
 l_no_rec_in_ppr        BOOLEAN;

 /* variables for fields from document */
 doc_id                 iby_docs_payable_all.document_payable_id%TYPE;
 ca_doc_id1             iby_docs_payable_all.
                            calling_app_doc_unique_ref1%TYPE;
 ca_doc_id2             iby_docs_payable_all.
                            calling_app_doc_unique_ref2%TYPE;
 ca_doc_id3             iby_docs_payable_all.
                            calling_app_doc_unique_ref3%TYPE;
 ca_doc_id4             iby_docs_payable_all.
                            calling_app_doc_unique_ref4%TYPE;
 ca_doc_id5             iby_docs_payable_all.
                            calling_app_doc_unique_ref5%TYPE;
 ca_id                  iby_docs_payable_all.calling_app_id%TYPE;
 pp_tt_cd               iby_docs_payable_all.pay_proc_trxn_type_code%TYPE;
 doc_int_bank_acct_id   iby_docs_payable_all.internal_bank_account_id%TYPE;
 doc_profile_id         iby_docs_payable_all.payment_profile_id%TYPE;
 doc_pay_currency       iby_docs_payable_all.payment_currency_code%TYPE;
 doc_pmt_method         iby_docs_payable_all.payment_method_code%TYPE;
 doc_pmt_format         iby_docs_payable_all.payment_format_code%TYPE;
 doc_org_id             iby_docs_payable_all.org_id%TYPE;
 doc_org_type           iby_docs_payable_all.org_type%TYPE;
 doc_pmt_date           iby_docs_payable_all.payment_date%TYPE;
 doc_payee_id           iby_docs_payable_all.ext_payee_id%TYPE;

 /* variables for fields from payment request */
 req_ca_payreq_id       iby_pay_service_requests.
                            call_app_pay_service_req_code%TYPE;
 req_ca_id              iby_pay_service_requests.calling_app_id%TYPE;
 req_int_bank_acct_id   iby_pay_service_requests.internal_bank_account_id%TYPE;
 req_profile_id         iby_pay_service_requests.payment_profile_id%TYPE;

 /*
  * Cursor to pick up the documents of a given payment request.
  */
 CURSOR c_document_attribs(p_payment_request_id VARCHAR2)
 IS
 SELECT document_payable_id,
        calling_app_id,                     --| These seven
        calling_app_doc_unique_ref1,        --| are used
        calling_app_doc_unique_ref2,        --| by the
        calling_app_doc_unique_ref3,        --| calling app
        calling_app_doc_unique_ref4,        --| to uniquely
        calling_app_doc_unique_ref5,        --| id a
        pay_proc_trxn_type_code,            --| document
        NVL(internal_bank_account_id, -1),  -- Internal bank account id
        NVL(payment_profile_id, -1),        -- Payment profile id
        payment_currency_code,
        payment_method_code,
        payment_format_code,
        org_id,
        org_type,
        payment_date,
        NVL(ext_payee_id, -1)               -- payee id
 FROM IBY_DOCS_PAYABLE_ALL
 WHERE  payment_service_request_id = p_payment_request_id
 AND    (internal_bank_account_id IS NULL OR
         payment_profile_id       IS NULL)
 ORDER BY document_payable_id;

 BEGIN
     IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
     print_debuginfo(l_module_name, 'ENTER');
     END IF;

     IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
     print_debuginfo(l_module_name, 'Payment Request Id : '||
         p_payment_request_id);
     END IF;

     /*
      * Get attributes from the payment request like
      * calling app payred id, internal bank account etc.
      */
     getRequestAttributes(p_payment_request_id, req_ca_payreq_id,
         req_ca_id, req_int_bank_acct_id, req_profile_id);

     IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
     print_debuginfo(l_module_name,
         'Fetched assignment attributes from request -'
             || ' Payment request id: '     || p_payment_request_id
             || ', CA payment request id: ' || req_ca_payreq_id
             || ', internal bank account: ' || req_int_bank_acct_id
             || ', payment profile: '       || req_profile_id
         );
     END IF;

     /*-- REQUEST LEVEL DEFAULTING STARTS HERE --*/
     /*
      * Populate the updateDocAttributesRec record. This information
      * will be used to update all documents in IBY_DOCS_PAYABLE_ALL
      * that have this payment request id.
      */

     IF (req_int_bank_acct_id IS NOT NULL) THEN
         l_updateDocsRec.payment_request_id := p_payment_request_id;
         l_updateDocsRec.int_bank_acct_id   := req_int_bank_acct_id;
         l_updateDocsRec.bank_acct_flag     := true;
     END IF;

     IF (req_profile_id IS NOT NULL) THEN
         l_updateDocsRec.payment_request_id := p_payment_request_id;
         l_updateDocsRec.pay_profile_id     := req_profile_id;
         l_updateDocsRec.pay_profile_flag   := true;
     END IF;

     /*
      * If both bank account and profile were available from the request
      * then we have all the information we need to update the documents.
      * Update the documents and exit.
      */
     IF (req_int_bank_acct_id IS NOT NULL AND req_profile_id IS NOT NULL) THEN
         /*
          * Update IBY_DOCS_PAYABLE_ALL table with the account id and
          * profile id from request.
          */
         updateDocumentAssignments(l_updateDocsRec);

         /*
          * Update document and request statuses.
          */
         finalizeStatuses(p_payment_request_id, x_return_status);

         /*
          * All documents now have account and profile assigned. No
          * need to continue further, we can exit at this point.
          */
         RETURN;

     ELSIF (req_int_bank_acct_id IS NOT NULL OR req_profile_id IS NOT NULL) THEN
         /*
          * Update IBY_DOCS_PAYABLE_ALL table with either the account
          * id or the profile id (whichever was available).
          *
          * Then continue down the process to individually assign
          * profile/account to the documents on a case-by-case basis.
          */
         updateDocumentAssignments(l_updateDocsRec);

     END IF;

     /*-- DOCUMENT LEVEL DEFAULTING STARTS HERE --*/
     /*
      * Request level attributes were not populated, or only
      * partially populated to the documents. We have to individually
      * determine what attributes to assign to each document.
      */

     l_no_rec_in_ppr := TRUE;

     /*
      * Step 1:
      * Pull up all documents for this payment request where
      * the document does not have the bank account or profile
      * assigned.
      */
     OPEN  c_document_attribs(p_payment_request_id);
     LOOP

     iby_disburse_submit_pub_pkg.delete_docspayTab;

     FETCH c_document_attribs BULK COLLECT INTO
           iby_disburse_submit_pub_pkg.docspayTab.document_payable_id,
           iby_disburse_submit_pub_pkg.docspayTab.calling_app_id,
           iby_disburse_submit_pub_pkg.docspayTab.calling_app_doc_unique_ref1,
           iby_disburse_submit_pub_pkg.docspayTab.calling_app_doc_unique_ref2,
           iby_disburse_submit_pub_pkg.docspayTab.calling_app_doc_unique_ref3,
           iby_disburse_submit_pub_pkg.docspayTab.calling_app_doc_unique_ref4,
           iby_disburse_submit_pub_pkg.docspayTab.calling_app_doc_unique_ref5,
           iby_disburse_submit_pub_pkg.docspayTab.pay_proc_trxn_type_code,
           iby_disburse_submit_pub_pkg.docspayTab.internal_bank_account_id,
           iby_disburse_submit_pub_pkg.docspayTab.payment_profile_id,
           iby_disburse_submit_pub_pkg.docspayTab.payment_currency_code,
           iby_disburse_submit_pub_pkg.docspayTab.payment_method_code,
           iby_disburse_submit_pub_pkg.docspayTab.payment_format_code,
           iby_disburse_submit_pub_pkg.docspayTab.org_id,
           iby_disburse_submit_pub_pkg.docspayTab.org_type,
           iby_disburse_submit_pub_pkg.docspayTab.payment_date,
           iby_disburse_submit_pub_pkg.docspayTab.ext_payee_id
     LIMIT G_LINES_PER_FETCH;

     FOR l_trx_line_index IN nvl(iby_disburse_submit_pub_pkg.docspayTab.document_payable_id.FIRST,0) .. nvl(iby_disburse_submit_pub_pkg.docspayTab.document_payable_id.LAST,-99)
     LOOP
        l_no_rec_in_ppr := FALSE;

     /*
      * Step 2:
      * Loop through the fetched documents assigning default
      * internal bank account and payment profile whenever
      * necessary (and whenever possible).
      */

         doc_id               :=  iby_disburse_submit_pub_pkg.docspayTab.document_payable_id(l_trx_line_index);
         ca_id                :=  iby_disburse_submit_pub_pkg.docspayTab.calling_app_id(l_trx_line_index);
         ca_doc_id1           :=  iby_disburse_submit_pub_pkg.docspayTab.calling_app_doc_unique_ref1(l_trx_line_index);
         ca_doc_id2           :=  iby_disburse_submit_pub_pkg.docspayTab.calling_app_doc_unique_ref2(l_trx_line_index);
         ca_doc_id3           :=  iby_disburse_submit_pub_pkg.docspayTab.calling_app_doc_unique_ref3(l_trx_line_index);
         ca_doc_id4           :=  iby_disburse_submit_pub_pkg.docspayTab.calling_app_doc_unique_ref4(l_trx_line_index);
         ca_doc_id5           :=  iby_disburse_submit_pub_pkg.docspayTab.calling_app_doc_unique_ref5(l_trx_line_index);
         pp_tt_cd             :=  iby_disburse_submit_pub_pkg.docspayTab.pay_proc_trxn_type_code(l_trx_line_index);
         doc_int_bank_acct_id :=  iby_disburse_submit_pub_pkg.docspayTab.internal_bank_account_id(l_trx_line_index);
         doc_profile_id       :=  iby_disburse_submit_pub_pkg.docspayTab.payment_profile_id(l_trx_line_index);
         doc_pay_currency     :=  iby_disburse_submit_pub_pkg.docspayTab.payment_currency_code(l_trx_line_index);
         doc_pmt_method       :=  iby_disburse_submit_pub_pkg.docspayTab.payment_method_code(l_trx_line_index);
         doc_pmt_format       :=  iby_disburse_submit_pub_pkg.docspayTab.payment_format_code(l_trx_line_index);
         doc_org_id           :=  iby_disburse_submit_pub_pkg.docspayTab.org_id(l_trx_line_index);
         doc_org_type         :=  iby_disburse_submit_pub_pkg.docspayTab.org_type(l_trx_line_index);
         doc_pmt_date         :=  iby_disburse_submit_pub_pkg.docspayTab.payment_date(l_trx_line_index);
         doc_payee_id         :=  iby_disburse_submit_pub_pkg.docspayTab.ext_payee_id(l_trx_line_index);

         /*
          * Log the fields for the fetched document
          */
         IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
         print_debuginfo(l_module_name, 'Fetched attributes for document: '
             || doc_id
             || ', calling app id: '        || ca_id
             || ', calling app doc id1: '   || ca_doc_id1
             || ', calling app doc id2: '   || ca_doc_id2
             || ', calling app doc id3: '   || ca_doc_id3
             || ', calling app doc id4: '   || ca_doc_id4
             || ', calling app doc id5: '   || ca_doc_id5
             || ', ca pay proc ttype cd: '  || pp_tt_cd
             );
         END IF;


         IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
	 print_debuginfo(l_module_name, 'Other attributes for document: '
             || doc_id
             || ', internal bank account: ' || doc_int_bank_acct_id
             || ', profile: '               || doc_profile_id
             || ', payment method: '        || doc_pmt_method
             || ', payment format: '        || doc_pmt_format
             || ', payment currency: '      || doc_pay_currency
             || ', org id: '                || doc_org_id
             || ', org type: '              || doc_org_type
             || ', payment date: '          || doc_pmt_date
             || ', payee id: '              || doc_payee_id
             );
	 END IF;


         /*
          * Reset the temporary record after each iteration
          * so that old field values are overwritten.
          */
         l_setDocsRec.doc_id            := NULL;
         l_setDocsRec.ca_id             := NULL;
         l_setDocsRec.ca_doc_id1        := NULL;
         l_setDocsRec.ca_doc_id2        := NULL;
         l_setDocsRec.ca_doc_id3        := NULL;
         l_setDocsRec.ca_doc_id4        := NULL;
         l_setDocsRec.ca_doc_id5        := NULL;
         l_setDocsRec.pp_tt_cd          := NULL;
         l_setDocsRec.pay_profile_id    := NULL;
         l_setDocsRec.int_bank_acct_id  := NULL;
         l_setDocsRec.status            := NULL;

         /*
          * Step 2A:
          * Try to default the internal bank account for
          * the document.
          */
         IF (doc_int_bank_acct_id = -1) THEN
             /*
              * Call Cash Management API
              *
              * Input : Payment currency
              *         Organization id
              * Output: List of internal bank accounts
              *         that match this criteria
              *
              * If there is only one bank account that matches
              * the given criteria, then the bank account can be
              * defaulted, not otherwise.
              */
              doc_int_bank_acct_id := NULL;
             /*CE_BANK_AND_ACCOUNT_UTIL.get_internal_bank_accts(
                                          doc_pay_currency,
                                          doc_org_type,
                                          doc_org_id,
                                          doc_pmt_date,
                                          bankAccountsArray
                                          );*/
	     l_int_bank_accts_index := doc_pay_currency||'$'||doc_org_type||'$'||doc_org_id||'$'||doc_pmt_date;
             IF(l_int_bank_accts_index is not null) THEN


                 IF(l_int_bank_accts_tbl.EXISTS(l_int_bank_accts_index)) THEN
	                  IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
			  print_debuginfo(l_module_name, 'Fetching the value from Cache Structure l_int_bank_accts_tbl ' || l_int_bank_accts_index);
			  END IF;

	     	          doc_int_bank_acct_id := l_int_bank_accts_tbl(l_int_bank_accts_index).internal_bank_account_id;
	     	          l_acct_default_flag := l_int_bank_accts_tbl(l_int_bank_accts_index).l_is_valid;
	         ELSE

                    CE_BANK_AND_ACCOUNT_UTIL.get_internal_bank_accts(
	                                             doc_pay_currency,
	                                             doc_org_type,
	                                             doc_org_id,
	                                             doc_pmt_date,
	                                             doc_int_bank_acct_id,
	                                             l_acct_default_flag
                                                     );
		    IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
		    print_debuginfo(l_module_name, 'Inserting values into Cache Structure l_int_bank_accts_tbl ' || l_int_bank_accts_index);
	            END IF;

                    l_int_bank_accts_tbl(l_int_bank_accts_index).internal_bank_account_id:=doc_int_bank_acct_id;
	     	    l_int_bank_accts_tbl(l_int_bank_accts_index).l_is_valid := l_acct_default_flag;
                END IF;
              END IF;

             /*--
             -- Uncomment if you want to test with a dummy API
             --
             --dummyCEAPI(doc_pay_currency, doc_pmt_date, doc_org_id,
             --    dummyBankAccountsArray);

	     IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Number of bank accounts '
                 || ' returned by CE for currency '
                 || doc_pay_currency
                 || ', pmt date '
                 || doc_pmt_date
                 || ' and org '
                 || doc_org_id
                 || ' is '
                 || bankAccountsArray.COUNT
                 );
	     END IF;
             */


             /*
              * If only bank account returned, then assign this as
              * default bank account to this document.
              */
             /*IF (bankAccountsArray.COUNT = 1) THEN

		 IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Setting default bank account'
                     || ' to '
                     || bankAccountsArray(bankAccountsArray.COUNT)
                     || ' for document: '
                     || doc_id
                     );
	         END IF;

                 l_setDocsRec.doc_id     := doc_id;
                 l_setDocsRec.ca_id      := ca_id;
                 l_setDocsRec.ca_doc_id1 := ca_doc_id1;
                 l_setDocsRec.ca_doc_id2 := ca_doc_id2;
                 l_setDocsRec.ca_doc_id3 := ca_doc_id3;
                 l_setDocsRec.ca_doc_id4 := ca_doc_id4;
                 l_setDocsRec.ca_doc_id5 := ca_doc_id5;
                 l_setDocsRec.pp_tt_cd   := pp_tt_cd;
                 l_setDocsRec.int_bank_acct_id
                     := bankAccountsArray(bankAccountsArray.COUNT);
                 l_acct_default_flag := true;*/

	       IF (l_acct_default_flag) THEN

	           IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
		   print_debuginfo(l_module_name, 'Setting default bank account'
	                           || ' to '
	                           || doc_int_bank_acct_id
	                           || ' for document: '
	                           || doc_id
	                           );
		   END IF;

	                        l_setDocsRec.doc_id     := doc_id;
	                        l_setDocsRec.ca_id      := ca_id;
	                        l_setDocsRec.ca_doc_id1 := ca_doc_id1;
	                        l_setDocsRec.ca_doc_id2 := ca_doc_id2;
	                        l_setDocsRec.ca_doc_id3 := ca_doc_id3;
	                        l_setDocsRec.ca_doc_id4 := ca_doc_id4;
	                        l_setDocsRec.ca_doc_id5 := ca_doc_id5;
	                        l_setDocsRec.pp_tt_cd   := pp_tt_cd;
	                        l_setDocsRec.int_bank_acct_id
	                            := doc_int_bank_acct_id;
             ELSE

                 /*
                  * CE returned multiple bank accounts for the given
                  * document attributes. We cannot default the bank
                  * account.
                  */
                 l_setDocsRec.doc_id     := doc_id;
                 l_setDocsRec.ca_id      := ca_id;
                 l_setDocsRec.ca_doc_id1 := ca_doc_id1;
                 l_setDocsRec.ca_doc_id2 := ca_doc_id2;
                 l_setDocsRec.ca_doc_id3 := ca_doc_id3;
                 l_setDocsRec.ca_doc_id4 := ca_doc_id4;
                 l_setDocsRec.ca_doc_id5 := ca_doc_id5;
                 l_setDocsRec.pp_tt_cd   := pp_tt_cd;
                 l_setDocsRec.status := DOC_STATUS_MISSING_ACC;

		 IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
		 print_debuginfo(l_module_name, 'Internal bank account '
                     || 'could not be defaulted for document: '
                     || doc_id
                     || '. This is because the Cash Management API did '
                     || 'not return a unique bank account for org '
                     || doc_org_id
                     || ' and currency '
                     || doc_pay_currency
                     || '.'
                     );
		 END IF;

             END IF;

         END IF;

         /*
          * Step 2B:
          * Try to default the payment profile for
          * the document.
          */
         IF (doc_profile_id = -1) THEN

             /* Initialize */
             l_profile_id := -1;

             /*
              * ATTEMPT I:
              * Attempt to get the default payment format from the
              * payee on the document.
              *
              * If there is only one profile linked to this format,
              * then default this profile for the document.
              */
             IF (doc_payee_id <> -1) THEN

                 l_profile_id := getProfileFromPayeeFormat(doc_payee_id);

		 IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Derived profile id: '
                     || l_profile_id
                     || ' from payee format '
                     || ' for document '
                     || doc_id
                     );
	         END IF;

             END IF;

             IF (l_profile_id = -1) THEN

                 /*
                  * ATTEMPT II:
                  * Attempt to derive the payment profile from the
                  * document's payment method and other attributes.
                  * If only one payment profile exists for the given
                  * set of attributes, then we can default
                  * this profile to the document.
                  */
                 l_profile_id := getProfileFromProfileDrivers(doc_pmt_method,
                                     doc_org_id, doc_org_type,
                                     doc_pay_currency, doc_int_bank_acct_id
                                     );

		 IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Derived profile id: '
                     || l_profile_id
                     || ' from payment method id '
                     || doc_pmt_method
                     || ' and payment format id '
                     || doc_pmt_format
                     || ' for document '
                     || doc_id
                     );
	         END IF;

             END IF;

             /*
              * Profile id of '-1' means that either no payment
              * profile was mapped to this document's (method,
              * org, currency, int bank account), or more than
              * one payment profile was mapped to this payment method.
              *
              * If that is the case, we cannot default.
              */
             IF (l_profile_id <> -1) THEN

                 l_setDocsRec.doc_id      := doc_id;
                 l_setDocsRec.ca_id       := ca_id;
                 l_setDocsRec.ca_doc_id1  := ca_doc_id1;
                 l_setDocsRec.ca_doc_id2  := ca_doc_id2;
                 l_setDocsRec.ca_doc_id3  := ca_doc_id3;
                 l_setDocsRec.ca_doc_id4  := ca_doc_id4;
                 l_setDocsRec.ca_doc_id5  := ca_doc_id5;
                 l_setDocsRec.pp_tt_cd    := pp_tt_cd;
                 l_setDocsRec.pay_profile_id := l_profile_id;
                 l_prof_default_flag      := true;

             ELSE

                 l_setDocsRec.doc_id      := doc_id;
                 l_setDocsRec.ca_id       := ca_id;
                 l_setDocsRec.ca_doc_id1  := ca_doc_id1;
                 l_setDocsRec.ca_doc_id2  := ca_doc_id2;
                 l_setDocsRec.ca_doc_id3  := ca_doc_id3;
                 l_setDocsRec.ca_doc_id4  := ca_doc_id4;
                 l_setDocsRec.ca_doc_id5  := ca_doc_id5;
                 l_setDocsRec.pp_tt_cd    := pp_tt_cd;

                 /*
                  * If we come here, it means that the document is
                  * missing a profile.
                  *
                  * If the document is already missing an internal
                  * bank account as well, set the status of the document
                  * to reflect that it is missing both account and profile.
                  */
                 IF (l_setDocsRec.status = DOC_STATUS_MISSING_ACC) THEN

                     l_setDocsRec.status := DOC_STATUS_MISSING_BOTH;

                 ELSE

                     l_setDocsRec.status := DOC_STATUS_MISSING_PROF;

                 END IF;

		 IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Payment profile could not '
                     || 'be derived for document id: '
                     || doc_id
                     );
	         END IF;

             END IF;

         END IF;

         /*
          * 'READY_FOR_VALIDATION' status means the document has
          * both bank account and profile. This can happen in
          * 3 situations:
          *
          * 1. We were able to default both the bank account and
          *    payment profile for this document.
          *
          * 2. We were able to default bank account and profile was
          *    already available.
          *
          * 3. We were able to default profile and bank account was
          *    already available.
          *
          * If either of these is missing, then the document status
          * would have been set to 'MISSING_ACCOUNT' | 'MISSING_PROFILE'
          * earlier.
          *
          * [The situation of both account and profile being already
          *  available would not occur because our query would not
          *  have picked those documents up.]
          */
         IF ((l_acct_default_flag = true AND l_prof_default_flag = true) OR
             (l_acct_default_flag = true AND doc_profile_id <> -1) OR
             (l_prof_default_flag = true AND doc_int_bank_acct_id <> -1)) THEN

             l_setDocsRec.status := DOC_STATUS_FULL_ASSIGNED;

         END IF;

         /*
          * Add this record to the PLSQL table. We will update the
          * PLSQL table outside this loop when all documents have
          * been processed.
          */
         l_setDocsTab(l_setDocsTab.COUNT + 1) := l_setDocsRec;

         /*
          * Reset flags before going into next iteration
          */
         l_acct_default_flag := false;
         l_prof_default_flag := false;

     END LOOP; -- for documents cursor

     EXIT WHEN c_document_attribs%NOTFOUND;

     END LOOP; -- for documents cursor

     /*
      * If no documents were provided with the payment request,
      * there is no point in going further.
      *
      * A pament request with no documents payable is an invalid
      * request. Return error response.
      */
     IF (l_no_rec_in_ppr) THEN

	 IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
         print_debuginfo(l_module_name, 'Found no documents with incomplete '
             || 'assignments for payment request: '
             || p_payment_request_id
             || '. Finalizing status of docs and request and exiting.. ');
         END IF;

         /*
          * Update document and request statuses.
          */
         finalizeStatuses(p_payment_request_id, x_return_status);

	 IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
	 print_debuginfo(l_module_name, 'EXIT');
         END IF;

         RETURN;

     END IF;

     iby_disburse_submit_pub_pkg.delete_docspayTab;

     CLOSE c_document_attribs;


     /*
      * Update the bank account and/or profile for the
      * documents for which we were able to come up with
      * defaults.
      */
     setDocumentAssignments(l_setDocsTab);

     /*
      * Update the payment request status. This depends upon whether
      * all documents in the request have their bank account and profile
      * assigned or not.
      *
      * Internally, this function will call a hook to access an external
      * application if all documents have not been completely assigned
      * their bank account / profile.
      */
     updateRequestStatus(p_payment_request_id, x_return_status);

     /*
      * Finally, raise a business event to inform the calling
      * app of any documents with missing account/profile.
      */
     raiseBizEvents(p_payment_request_id, req_ca_payreq_id, req_ca_id);

     IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
     print_debuginfo(l_module_name, 'EXIT');
     END IF;

 END performAssignments;

/*--------------------------------------------------------------------
 | NAME:
 |     getRequestAttributes
 |
 | PURPOSE:
 |     Returns the calling app pay service request id, the internal
 |     bank account associated with the request (if any), the payment
 |     profile associated with the request (if any) and other
 |     identifying information for the given payment request.
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
         IBY_PAY_SERVICE_REQUESTS.calling_app_id%TYPE,
     x_bankAcctId IN OUT NOCOPY
         IBY_PAY_SERVICE_REQUESTS.internal_bank_account_id%TYPE,
     x_profileId  IN OUT NOCOPY
         IBY_PAY_SERVICE_REQUESTS.payment_profile_id%TYPE
     )
 IS
 l_module_name  CONSTANT VARCHAR2(200) := G_PKG_NAME || '.getRequestAttributes';
 BEGIN

     SELECT call_app_pay_service_req_code,
            calling_app_id,
            internal_bank_account_id,         -- Internal bank account ID
            payment_profile_id                -- Payment profile ID
     INTO   x_caPayReqCd,
            x_caId,
            x_bankAcctId,
            x_profileId
     FROM IBY_PAY_SERVICE_REQUESTS
     WHERE  payment_service_request_id = p_payReqId;

 END getRequestAttributes;

/*--------------------------------------------------------------------
 | NAME:
 |     updateDocumentAssignments
 |
 | PURPOSE:
 |     Updates the account/profile attributes of documents in the
 |     payment request using information from the given PLSQL table.
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
 PROCEDURE updateDocumentAssignments(
     p_updateDocsRec IN IBY_ASSIGN_PUB.updateDocAttributesRec
     )
 IS
 l_module_name  CONSTANT VARCHAR2(200) := G_PKG_NAME ||
                                              '.updateDocumentAssignments';

 BEGIN

     IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
     print_debuginfo(l_module_name, 'ENTER');
     END IF;

     /* Check if account needs to be updated */
     IF (p_updateDocsRec.bank_acct_flag = true) THEN

	 IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
         print_debuginfo(l_module_name, 'Internal bank account '
             || 'will be set to '
             || p_updateDocsRec.int_bank_acct_id
             || ' for all documents of payment request '
             || p_updateDocsRec.payment_request_id
             );
         END IF;

     END IF;

     /* Check if profile needs to be updated */
     IF (p_updateDocsRec.pay_profile_flag = true) THEN

	 IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
         print_debuginfo(l_module_name, 'Payment profile '
             || 'will be set to '
             || p_updateDocsRec.pay_profile_id
             || ' for all documents of payment request '
             || p_updateDocsRec.payment_request_id
             );
         END IF;

     END IF;

     /*
      * There are three possible situations:
      * 1. Both the account and profile need to be updated
      * 2. Only the account needs to be updated
      * 3. Only the profile needs to be updated
      *
      * All of these situations will be handled by the SQL
      * string below.
      */

     UPDATE
         IBY_DOCS_PAYABLE_ALL
     SET
         internal_bank_account_id =
             NVL(
                 p_updateDocsRec.int_bank_acct_id,
                 internal_bank_account_id
                ),
         payment_profile_id =
             NVL(
                 p_updateDocsRec.pay_profile_id,
                 payment_profile_id
                )
     WHERE
         payment_service_request_id = p_updateDocsRec.payment_request_id
     ;

     IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
     print_debuginfo(l_module_name, 'EXIT');
     END IF;

 END updateDocumentAssignments;


/*--------------------------------------------------------------------
 | NAME:
 |     finalizeStatuses
 |
 | PURPOSE:
 |     Updates the statuses of the documents and the payment request.
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
 PROCEDURE finalizeStatuses(
     p_payReqID IN IBY_PAY_SERVICE_REQUESTS.payment_service_request_id%TYPE,
     x_req_status  IN OUT NOCOPY VARCHAR2
     )
 IS

 l_module_name   CONSTANT VARCHAR2(200) := G_PKG_NAME || '.finalizeStatuses';

 BEGIN

     IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
     print_debuginfo(l_module_name, 'ENTER');
     END IF;

     /* Update document statuses */
     UPDATE
         IBY_DOCS_PAYABLE_ALL
     SET
         document_status = DOC_STATUS_FULL_ASSIGNED
     WHERE
         payment_service_request_id = p_payReqID
     ;

     /* Update payment request statuse */
     UPDATE
         IBY_PAY_SERVICE_REQUESTS
     SET
         payment_service_request_status = REQ_STATUS_FULL_ASSIGNED
     WHERE
         payment_service_request_id = p_payReqID
     ;

     /*  Pass back the request status to the caller */
     x_req_status := REQ_STATUS_FULL_ASSIGNED;

     IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
     print_debuginfo(l_module_name, 'EXIT');
     END IF;

 END finalizeStatuses;


/*--------------------------------------------------------------------
 | NAME:
 |     dummyCEAPI
 |
 | PURPOSE:
 |     Returns a dummy bank account as default for the given
 |     (Org, Pmt Date, Currency) combination. This method simulates
 |     the API provided by CE and is meant for testing purposes.
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
 PROCEDURE dummyCEAPI(
     p_payCurrency   IN IBY_DOCS_PAYABLE_ALL.payment_currency_code%TYPE,
     p_pmtDate       IN IBY_DOCS_PAYABLE_ALL.payment_date%TYPE,
     p_OrgID         IN IBY_DOCS_PAYABLE_ALL.org_id%TYPE,
     x_bankAccounts  IN OUT NOCOPY IBY_ASSIGN_PUB.bankAccounts
     )
 IS

 BEGIN

     x_bankAccounts(x_bankAccounts.COUNT+1) := 9831508;

 END dummyCEAPI;


/*--------------------------------------------------------------------
 | NAME:
 |     setDocumentAssignments
 |
 | PURPOSE:
 |    Updates the account/profile attributes of individual documents
 |    using information from the given PLSQL table.
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
 PROCEDURE setDocumentAssignments(
     p_setDocAttribsTab IN IBY_ASSIGN_PUB.setDocAttribsTabType
     )
 IS

 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME ||
                                             '.setDocumentAssignments';

 l_update_acct      VARCHAR2(1000);
 l_update_prof      VARCHAR2(1000);
 l_acct_flag        BOOLEAN  := false;
 l_prof_flag        BOOLEAN  := false;

 l_update_str       VARCHAR2(2000);
 l_status_str       VARCHAR2(1000);
 l_sql_str          VARCHAR2(4000);

 BEGIN

     IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
     print_debuginfo(l_module_name, 'ENTER');
     END IF;

     /*
      * Exit if no records were provided to update.
      *
      */
     IF (p_setDocAttribsTab.COUNT = 0) THEN
         IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
         print_debuginfo(l_module_name, 'No records were provided. Exiting ..');
         END IF;

	 RETURN;

     END IF;

     /*
      * Loop through all the records, updating one document
      * per iteration.
      */
     FOR i in p_setDocAttribsTab.FIRST..p_setDocAttribsTab.LAST LOOP

         IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
         print_debuginfo(l_module_name, 'Setting attributes for document: '
             || p_setDocAttribsTab(i).doc_id
             );
         END IF;

         /* Reset flags before going into next iteration */
         l_acct_flag   := false;
         l_prof_flag   := false;
         l_update_acct := '';
         l_update_prof := '';

         /* bank account */
         IF (nvl(p_setDocAttribsTab(i).int_bank_acct_id,-1) <> -1) THEN

             l_acct_flag   := true;
             l_update_acct := 'internal_bank_account_id = '
                              || p_setDocAttribsTab(i).int_bank_acct_id;

         END IF;

         /* payment profile */
         IF (nvl(p_setDocAttribsTab(i).pay_profile_id,-1) <> -1) THEN

             l_prof_flag   := true;
             l_update_prof := 'payment_profile_id = '
                              || p_setDocAttribsTab(i).pay_profile_id;

         END IF;

         /* status */
         /*
          * Note: Using binding instead of concatenation for status
          * value because the adding quotes to status string is ugly.
          */

         /*
          * Fix for bug 4405981:
          *
          * Update the straight through flag whenever a
          * document is missing internal bank account / profile
          * or both.
          */
         l_status_str := 'document_status = :status, '
                             || 'straight_through_flag = :flag';

         /*
          * There are four possible situations:
          * 1. Both the account and profile need to be updated
          * 2. Only the account needs to be updated
          * 3. Only the profile needs to be updated
          * 4. Neither account nor profile needs to be updated
          *
          * Depending upon the situation, form the appropriate
          * SQL string.
          */
         IF (l_acct_flag = true AND l_prof_flag = true) THEN

             IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
             print_debuginfo(l_module_name, 'Updating both account and '
                 || 'profile');
             END IF;

             /*
              * Status will be READY_FOR_VALIDATION as
              * both account and profile are available.
              */
             l_update_str := l_update_acct
                                 || ', '
                                 || l_update_prof
                                 || ', '
                                 || l_status_str
                                 ;

         ELSIF (l_acct_flag = true) THEN

             IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
             print_debuginfo(l_module_name, 'Only updating account');
             END IF;

             l_update_str := l_update_acct || ', ' || l_status_str;

         ELSIF (l_prof_flag = true) THEN

             IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
             print_debuginfo(l_module_name, 'Only updating profile');
             END IF;

             l_update_str := l_update_prof || ', ' || l_status_str;

         ELSE

             /*
              * If we reached here it means that either internal
              * bank account, or profile or both could not be
              * defaulted for the document.
              *
              * Therefore, update the document status appropriately.
              */

             IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
             print_debuginfo(l_module_name, 'Updating status of doc '
                 || p_setDocAttribsTab(i).doc_id
                 || ' to '
                 || p_setDocAttribsTab(i).status
                 );
             END IF;

             UPDATE
                 IBY_DOCS_PAYABLE_ALL
             SET
                 document_status       = p_setDocAttribsTab(i).status,
                 straight_through_flag = 'N'
             WHERE
                 document_payable_id   = p_setDocAttribsTab(i).doc_id
             ;


             GOTO label_finish_iteration;

         END IF;

         /*
          * Form the complete SQL statement.
          */
         l_sql_str := 'UPDATE IBY_DOCS_PAYABLE_ALL SET '
                      || l_update_str
                      || ' WHERE document_payable_id = '
                      || p_setDocAttribsTab(i).doc_id;

         IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
         print_debuginfo(l_module_name, 'SQL str: ' || l_sql_str);
         END IF;

         IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
         print_debuginfo(l_module_name, 'Setting status to: '
             || p_setDocAttribsTab(i).status);
         END IF;

         /*
          * Dynamic SQL update
          */
         EXECUTE IMMEDIATE
             l_sql_str
         USING
             p_setDocAttribsTab(i).status,  /* document status       */
             'N'                            /* straight through flag */
         ;


         <<label_finish_iteration>>

         /*
          * This null is needed because the PLSQL compiler needs
          * a statement after the GOTO label.
          */
         NULL;

     END LOOP;

     IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
     print_debuginfo(l_module_name, 'EXIT');
     END IF;

 END setDocumentAssignments;

/*--------------------------------------------------------------------
 | NAME:
 |     getProfileFromProfileDrivers
 |
 | PURPOSE:
 |     Derives the payment profile for the given (payment method,
 |     org, payment currency, internal bank acct)
 |     combination.
 |
 |     This method will only be able to derive the profile from
 |     this combination if there is only one payment profile
 |     uniquely associated with the given (payment method,
 |     org, currency, bank acct). If multiple profiles match, or no
 |     profiles matches -1 will be returned.
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 |     -1 signifies that no profile could be derived from the given
 |     (method, org, currency, bank acct) combination.
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 FUNCTION getProfileFromProfileDrivers(
     p_pmt_method_cd     IN IBY_DOCS_PAYABLE_ALL.payment_method_code%TYPE,
     p_org_id            IN IBY_DOCS_PAYABLE_ALL.org_id%TYPE,
     p_org_type          IN IBY_DOCS_PAYABLE_ALL.org_type%TYPE,
     p_pmt_currency      IN IBY_DOCS_PAYABLE_ALL.payment_currency_code%TYPE,
     p_int_bank_acct_id  IN IBY_DOCS_PAYABLE_ALL.internal_bank_account_id%TYPE
     ) RETURN NUMBER
 IS
 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME ||
                                             '.getProfileFromProfileDrivers';

 l_profile_id  NUMBER;
 l_profiles_tab IBY_BUILD_UTILS_PKG.pmtProfTabType;

 BEGIN

     IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
     print_debuginfo(l_module_name, 'ENTER');
     END IF;

     IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
     print_debuginfo(l_module_name, 'Checking for profiles '
         || 'applicable for given org id '
         || p_org_id
         || ' and org type '
         || p_org_type
         || ' and payment method '
         || p_pmt_method_cd
         || ' and payment currency '
         || p_pmt_currency
         || ' and internal bank account '
         || p_int_bank_acct_id
         || ' combination ...'
         );
     END IF;

     /*
      * Get the list of all payment profiles that
      * match the given list of profile drivers.
      */
     IBY_BUILD_UTILS_PKG.getProfListFromProfileDrivers(
         p_pmt_method_cd,
         p_org_id,
         p_org_type,
         p_pmt_currency,
         p_int_bank_acct_id,
         l_profiles_tab);

     /*
      * If count is exactly one, it means that there is
      * a profile that uniquely matches the given set of
      * drivers. This profile can be defaulted to the
      * document. Return this profile to the caller.
      *
      * If count is 0 or more than 1, it means that we
      * cannot default a profile from the given set of
      * drivers. In this case, return -1.
      */
     IF (l_profiles_tab.COUNT = 1) THEN

         l_profile_id := l_profiles_tab(1).profile_id;

     ELSE

         l_profile_id := -1;

     END IF;

     RETURN l_profile_id;

 EXCEPTION
     WHEN OTHERS THEN

	 IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
	 print_debuginfo(l_module_name, 'Non-Fatal: Exception when '
             || 'attempting to get payment profile for given (payment '
             || 'method, org, currency , bank acct) '
             || 'combination. Profile id '
             || 'will be returned as -1.'
             );
	 END IF;

	 IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
	 print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	 END IF;

	 IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
	 print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);
	 END IF;

         l_profile_id := -1;
	 IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
	 print_debuginfo(l_module_name, 'ENTER');
	 END IF;

         RETURN l_profile_id;

 END getProfileFromProfileDrivers;

/*--------------------------------------------------------------------
 | NAME:
 |      updateRequestStatus
 |
 | PURPOSE:
 |      Updates the payment request status. If all documents have an
 |      account and a profile (either from the start, or after defaulting)
 |      then the request status will be 'fully assigned', otherwise
 |      the request status will be set to 'information required'.
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
 PROCEDURE updateRequestStatus(
     p_payReqID IN IBY_PAY_SERVICE_REQUESTS.payment_service_request_id%TYPE,
     x_req_status  IN OUT NOCOPY VARCHAR2
     )
 IS

 l_unassgnDocsTab    IBY_ASSIGN_PUB.unassignedDocsTabType;
 l_preHookDocsTab    IBY_ASSIGN_PUB.unassignedDocsTabType;
 l_setDocAttribsTab  IBY_ASSIGN_PUB.setDocAttribsTabType;
 l_module_name       CONSTANT VARCHAR2(200) := G_PKG_NAME ||
                                                   '.updateRequestStatus';
 l_request_status    VARCHAR2(200);
 l_str               VARCHAR2(5000);

 /*
  * Cursor to pick up all documents that do not have
  * a payment profile or an internal bank account
  * assigned.
  */
 CURSOR c_unassigned_docs(p_payment_request_id VARCHAR2)
 IS
 SELECT document_payable_id,
	payment_currency_code,
	org_id,
	payment_method_code,
        calling_app_id,                     --| These seven
        calling_app_doc_unique_ref1,        --| are used
        calling_app_doc_unique_ref2,        --| by the
        calling_app_doc_unique_ref3,        --| calling app
        calling_app_doc_unique_ref4,        --| to uniquely
        calling_app_doc_unique_ref5,        --| id a
        pay_proc_trxn_type_code,            --| document
        NVL(internal_bank_account_id, -1),
        NVL(payment_profile_id, -1)
 FROM IBY_DOCS_PAYABLE_ALL
 WHERE  payment_service_request_id = p_payment_request_id
 AND    (internal_bank_account_id IS NULL OR
         payment_profile_id       IS NULL)
 ORDER BY document_payable_id;

 BEGIN

     IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
     print_debuginfo(l_module_name, 'ENTER');
     END IF;

     OPEN  c_unassigned_docs(p_payReqID);
     FETCH c_unassigned_docs BULK COLLECT INTO l_unassgnDocsTab;
     CLOSE c_unassigned_docs;

     IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
     print_debuginfo(l_module_name, 'Found ' || l_unassgnDocsTab.COUNT
         || ' documents that were not assigned payment profile'
         || ' and/or bank account.');
     END IF;

     /*
      * If there are no unassigned documents, update the
      * status of the payment request to 'ASSIGNMENT_COMPLETE'.
      */
     IF (l_unassgnDocsTab.COUNT = 0) THEN

         x_req_status := REQ_STATUS_FULL_ASSIGNED;

         UPDATE
             IBY_PAY_SERVICE_REQUESTS
         SET
             payment_service_request_status = REQ_STATUS_FULL_ASSIGNED
         WHERE
             payment_service_request_id = p_payreqID
         ;

	 IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
	 print_debuginfo(l_module_name, 'Payment request status updated to '
             || 'ASSIGNMENT_COMPLETE status.');
	 END IF;

	 IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
	 print_debuginfo(l_module_name, 'EXIT');
	 END IF;

         RETURN;

     END IF;

     /*
      * If we reached here, it means that there is at least
      * one unassigned document in the payment request.
      *
      * We need to call the hook to see if it can default
      * any doc assignments.
      */

     /*
      * CALL HOOK:
      *
      * Call a hook to access custom assignment logic. The
      * hook may be able supply the missing internal bank
      * account and/or payment profile.
      *
      * Input:
      *   List of documents with missing assignments
      * Output:
      *   List of documents with assignments
      */
     BEGIN
         IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
	 print_debuginfo(l_module_name, 'Calling hook for custom assignments');
	 END IF;

         IBY_ASSIGNEXT_PUB.hookForAssignments(l_unassgnDocsTab);

         --
         -- Uncomment for testing
         --
         --dummyAsgnHook(l_unassgnDocsTab);

	 IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
	 print_debuginfo(l_module_name, 'Finished calling hook for custom '
             || 'assignments.');
	 END IF;

     EXCEPTION
         WHEN OTHERS THEN
	     IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
             print_debuginfo(l_module_name, 'Fatal: Exception occured '
                 || 'when calling assignment hook.', FND_LOG.LEVEL_UNEXPECTED);
	     END IF;

	     IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE,
                 FND_LOG.LEVEL_UNEXPECTED);
	     END IF;

	     IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM,
                 FND_LOG.LEVEL_UNEXPECTED);
	     END IF;

             /*
              * Propogate exception to caller.
              */
             RAISE;
     END;

     /*
      * Copy the records from the hook data structure to
      * our internal data structure used for updating tables.
      */
     populateDocAttributes(l_unassgnDocsTab, l_setDocAttribsTab);

     /*
      * Update the documents table with the hook provided
      * data.
      */
     setDocumentAssignments(l_setDocAttribsTab);

     /*
      * Update the status of the payment request.
      */
     FOR i in l_unassgnDocsTab.FIRST .. l_unassgnDocsTab.LAST LOOP

         IF (l_unassgnDocsTab(i).int_bank_acct_id = -1 OR
             l_unassgnDocsTab(i).pay_profile_id   = -1) THEN

             /*
              * At least one document in the request does not
              * have an assigned bank account / profile.
              */
	     IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
             print_debuginfo(l_module_name, 'Unassigned documents '
                 || 'exist for this payment request.');
	     END IF;

             l_request_status := REQ_STATUS_INFO_REQD;
             GOTO label_update_request_status;

         END IF;

     END LOOP;

     /*
      * Reaching here means all the documents have been
      * assigned a status by the external application.
      */
     l_request_status := REQ_STATUS_FULL_ASSIGNED;

     <<label_update_request_status>>

     /*
      * Update the payment request status appropriately.
      */
     UPDATE
         IBY_PAY_SERVICE_REQUESTS
     SET
         payment_service_request_status = l_request_status
     WHERE
         payment_service_request_id = p_payreqID
     ;

     IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
     print_debuginfo(l_module_name, 'Payment request status updated to '
         || l_request_status || ' status.');
     END IF;

     /* Pass back the request status to the caller */
     x_req_status := l_request_status;

     IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
     print_debuginfo(l_module_name, 'EXIT');
     END IF;

 EXCEPTION
     WHEN OTHERS THEN
         IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
         print_debuginfo(l_module_name, 'Fatal: Exception when '
             || 'attempting to update request status.',
             FND_LOG.LEVEL_UNEXPECTED);
         END IF;

	 IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
         print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE,
             FND_LOG.LEVEL_UNEXPECTED);
         END IF;

	 IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
         print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM,
             FND_LOG.LEVEL_UNEXPECTED);
         END IF;

         /*
          * Propogate exception to caller.
          */
         RAISE;

 END updateRequestStatus;

/*--------------------------------------------------------------------
 | NAME:
 |     dummyAsgnHook
 |
 | PURPOSE:
 |     Assigns a dummy internal bank account and dummy payment profile
 |     to the given documents. To be used for testing purposes.
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
 PROCEDURE dummyAsgnHook(
     x_unassgnDocsTab IN OUT NOCOPY IBY_ASSIGN_PUB.unassignedDocsTabType
     )
 IS
 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME || '.dummyAsgnHook';
 BEGIN

     IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
     print_debuginfo(l_module_name, 'ENTER');
     END IF;

     FOR i in x_unassgnDocsTab.FIRST .. x_unassgnDocsTab.LAST LOOP
         x_unassgnDocsTab(i).int_bank_acct_id := 746051;
         x_unassgnDocsTab(i).pay_profile_id   := 10;
     END LOOP;

     IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
     print_debuginfo(l_module_name, 'EXIT');
     END IF;

 END dummyAsgnHook;

/*--------------------------------------------------------------------
 | NAME:
 |     populateDocAttributes
 |
 | PURPOSE:
 |     Reads the account/profile assignments provided by the hook
 |     and assign them to the documents PLSQL table. This documents
 |     PLSQL table will later be used in updating the documents
 |     in the database.
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
 PROCEDURE populateDocAttributes(
     p_hookAsgnDocsTab  IN            IBY_ASSIGN_PUB.unassignedDocsTabType,
     x_setDocAttribsTab IN OUT NOCOPY IBY_ASSIGN_PUB.setDocAttribsTabType
     )
 IS
 l_docAttrsRec IBY_ASSIGN_PUB.setDocAttributesRec;
 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME || '.populateDocAttributes';
 BEGIN

     IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
     print_debuginfo(l_module_name, 'ENTER');
     END IF;

     /*
      * Loop through the hook assigned docs, and populate the
      * internal bank account / payment profile, whenever provided,
      * into the document attributes table.
      *
      * This document attributes table will be used to update
      * the DB with the hook provided assignments.
      */
     FOR i in p_hookAsgnDocsTab.FIRST .. p_hookAsgnDocsTab.LAST LOOP

         /* document id */
         l_docAttrsRec.doc_id    := p_hookAsgnDocsTab(i).document_id;

         /* caller assigned doc id */
         l_docAttrsRec.ca_id      := p_hookAsgnDocsTab(i).calling_app_id;
         l_docAttrsRec.ca_doc_id1 := p_hookAsgnDocsTab(i).calling_app_doc_id1;
         l_docAttrsRec.ca_doc_id2 := p_hookAsgnDocsTab(i).calling_app_doc_id2;
         l_docAttrsRec.ca_doc_id3 := p_hookAsgnDocsTab(i).calling_app_doc_id3;
         l_docAttrsRec.ca_doc_id4 := p_hookAsgnDocsTab(i).calling_app_doc_id4;
         l_docAttrsRec.ca_doc_id5 := p_hookAsgnDocsTab(i).calling_app_doc_id5;
         l_docAttrsRec.pp_tt_cd   := p_hookAsgnDocsTab(i).pay_proc_ttype_cd;

         /* internal bank account */
         IF (NVL(p_hookAsgnDocsTab(i).int_bank_acct_id,-1) = -1) THEN
	     l_docAttrsRec.status := DOC_STATUS_MISSING_ACC;
             l_docAttrsRec.int_bank_acct_id := NULL;

         ELSE
	 l_docAttrsRec.int_bank_acct_id := p_hookAsgnDocsTab(i).int_bank_acct_id;

	 END IF;

         /* payment profile */
         IF (NVL(p_hookAsgnDocsTab(i).pay_profile_id, -1) = -1) THEN
             /*
              * If internal bank account is already missing for
              * this document, then both int bank account and
              * profile are missing.
              *
              * Set document status to reflect this.
              */
             IF (l_docAttrsRec.status = DOC_STATUS_MISSING_ACC) THEN

                 l_docAttrsRec.status := DOC_STATUS_MISSING_BOTH;

             ELSE

                 l_docAttrsRec.status := DOC_STATUS_MISSING_PROF;

             END IF;
	     l_docAttrsRec.pay_profile_id := NULL;
         ELSE

	 l_docAttrsRec.pay_profile_id := p_hookAsgnDocsTab(i).pay_profile_id;

	 END IF;

         /* if both attributes are available, update the status */
         IF (NVL(p_hookAsgnDocsTab(i).int_bank_acct_id,-1) <> -1 AND
             NVL(p_hookAsgnDocsTab(i).pay_profile_id, -1) <> -1) THEN

             l_docAttrsRec.status := DOC_STATUS_FULL_ASSIGNED;

         END IF;

         /* add record with doc attributes to table */
         x_setDocAttribsTab(x_setDocAttribsTab.COUNT + 1) := l_docAttrsRec;

     END LOOP;

     IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
     print_debuginfo(l_module_name, 'EXIT');
     END IF;

 END populateDocAttributes;

/*--------------------------------------------------------------------
 | NAME:
 |     raiseBizEvents
 |
 | PURPOSE:
 |      Raises business events (when necessary) to signal to the
 |      external application that some documents in the payment
 |      request contain documents with missing account/profile.
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
     p_cap_id             IN            NUMBER
     )
 IS
 l_module_name    CONSTANT VARCHAR2(200) := G_PKG_NAME || '.raiseBizEvents';
 l_xml_clob       CLOB;
 l_event_name     VARCHAR2(200);
 l_event_key      NUMBER;
 l_param_names    JTF_VARCHAR2_TABLE_300;
 l_param_vals     JTF_VARCHAR2_TABLE_300;

 BEGIN

     IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
     print_debuginfo(l_module_name, 'ENTER');
     END IF;

     IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
     print_debuginfo(l_module_name, 'Payreq id: '
         || p_payreq_id);
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

     /*
      * Raise a business event with the list of documents
      * that have either internal bank account, or payment
      * profile, or both, missing. This business event should
      * trigger the calling app to launch a worfkflow
      * to enable the user to assign the missing information
      * to these docs.
      */
     l_event_name :=
          'oracle.apps.iby.buildprogram.validation.notify_incomplete_docs';

     IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
     print_debuginfo(l_module_name, 'Going to raise biz event '
          || l_event_name);
     END IF;

     /*
      * Select all docs that:
      * 1. Have the given pay req id
      * 2. Are missing either account or profile (or both)
      *
      * And create an XML fragment with these documents.
      */

     l_xml_clob := getXMLClob(p_payreq_id);

     IF (l_xml_clob IS NULL) THEN

         IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
         print_debuginfo(l_module_name, 'Not raising biz event '
             || l_event_name || ' because all documents were '
             || ' fully assigned. So no documents to notify.'
             );
         END IF;

     ELSE

	 IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
	 print_debuginfo(l_module_name, 'Going to raise biz event '
             || l_event_name);
	 END IF;

         IBY_BUILD_UTILS_PKG.printXMLClob(l_xml_clob);

         l_param_names.EXTEND;
         l_param_vals.EXTEND;
         l_param_names(1) := 'calling_app_id';
         l_param_vals(1)  := p_cap_id;

         l_param_names.EXTEND;
         l_param_vals.EXTEND;
         l_param_names(1) := 'pay_service_request_id';
         l_param_vals(1)  := p_cap_payreq_id;

         iby_workflow_pvt.raise_biz_event(l_event_name, l_event_key,
             l_param_names, l_param_vals);

	 IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
         print_debuginfo(l_module_name, 'Raised biz event '
             || l_event_name || ' with key '
             || l_event_key  || '.');
         END IF;

     END IF;

     IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
     print_debuginfo(l_module_name, 'EXIT');
     END IF;

 END raiseBizEvents;

/*--------------------------------------------------------------------
 | NAME:
 |     getXMLClob
 |
 | PURPOSE:
 |     Returns an XML clob that contains a list of documents that
 |     are missing account/profile.
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
 FUNCTION getXMLClob(
     p_payreq_id     IN VARCHAR2
     )
     RETURN CLOB
 IS
 l_module_name  CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.getXMLClob';
 l_xml_clob     CLOB := NULL;

 l_ctx          DBMS_XMLQuery.ctxType;
 l_sql          VARCHAR2(2000);
 l_sqlcode      NUMBER;
 l_sqlerrm      VARCHAR2(300);

 BEGIN

     IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
     print_debuginfo(l_module_name, 'ENTER');
     END IF;

     /*
      * Select all docs that:
      * 1. Have the given pay req id
      * 2. Are missing either account or profile (or both)
      */
     l_sql := 'SELECT calling_app_id, '
                  || 'calling_app_doc_unique_ref1, '
                  || 'calling_app_doc_unique_ref2, '
                  || 'calling_app_doc_unique_ref3, '
                  || 'calling_app_doc_unique_ref4, '
                  || 'calling_app_doc_unique_ref5, '
                  || 'pay_proc_trxn_type_code, '
                  || 'internal_bank_account_id, '
                  || 'payment_profile_id '
                  || 'FROM IBY_DOCS_PAYABLE_ALL '
                  || 'WHERE payment_service_request_id = :payreq_id '
                  || 'AND   (internal_bank_account_id IS NULL '
                  || 'OR    payment_profile_id       IS NULL)';

     l_ctx := DBMS_XMLQuery.newContext(l_sql);
     DBMS_XMLQuery.setBindValue(l_ctx, 'payreq_id', p_payreq_id);
     DBMS_XMLQuery.useNullAttributeIndicator(l_ctx, TRUE);

     /* raise an exception if no rows were found */
     DBMS_XMLQuery.setRaiseException(l_ctx, TRUE);
     DBMS_XMLQuery.setRaiseNoRowsException(l_ctx, TRUE);
     DBMS_XMLQuery.propagateOriginalException(l_ctx, TRUE);

     l_xml_clob := DBMS_XMLQuery.getXML(l_ctx);
     DBMS_XMLQuery.closeContext(l_ctx);

     IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
     print_debuginfo(l_module_name, 'EXIT');
     END IF;

     RETURN l_xml_clob;

 EXCEPTION

     WHEN OTHERS THEN

         DBMS_XMLQuery.getExceptionContent(l_ctx, l_sqlcode, l_sqlerrm);

	 IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
         print_debuginfo(l_module_name, 'SQL code: '   || l_sqlcode);
         END IF;

	 IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
         print_debuginfo(l_module_name, 'SQL err msg: '|| l_sqlerrm);
         END IF;

         /*
          * Do not raise exception if no rows found.
          * It means all documents have assignments.
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

	     IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'No rows were returned for query;'
                 || ' Returning null xml clob.');
	     END IF;

             RETURN NULL;
         END IF;

	 IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
         print_debuginfo(l_module_name, 'Fatal: Exception when attempting '
             || 'to raise business event.', FND_LOG.LEVEL_UNEXPECTED);
	 END IF;

         IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
         print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE,
             FND_LOG.LEVEL_UNEXPECTED);
         END IF;

         IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
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
 |     getProfileFromPayeeFormat
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
 FUNCTION getProfileFromPayeeFormat(
     p_payee_id            IN IBY_DOCS_PAYABLE_ALL.ext_payee_id%TYPE
     ) RETURN NUMBER
 IS
 l_module_name  CONSTANT VARCHAR2(200)  := G_PKG_NAME ||
                                               '.getProfileFromPayeeFormat';

 l_profile_id   IBY_PAYMENT_PROFILES.payment_profile_id%TYPE := -1;

 BEGIN

     IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
     print_debuginfo(l_module_name, 'ENTER');
     END IF;

     /*
      * This select will fail if is more than one row
      * or no rows. That's perfect because we want to find
      * a profile that is linked to exactly one format.
      */
     SELECT
         NVL(prof.payment_profile_id, -1)
     INTO
         l_profile_id
     FROM
         IBY_PAYMENT_PROFILES    prof,
         IBY_EXTERNAL_PAYEES_ALL payee
     WHERE
         payee.ext_payee_id       = ext_payee_id AND
         prof.payment_format_code = payee.payment_format_code
     ;

     IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
     print_debuginfo(l_module_name, 'EXIT');
     END IF;

     RETURN l_profile_id;

 EXCEPTION

     WHEN OTHERS THEN

         /*
          * In case of an exception, return -1
          */
         IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
         print_debuginfo(l_module_name, 'Non-fatal: Exception thrown '
             || 'when attempting to get payment profile '
             || 'linked to format. Returning -1.'
             );
         END IF;

	 IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
         print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
         END IF;

	 IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
         print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);
         END IF;

         l_profile_id := -1;

	 IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
         print_debuginfo(l_module_name, 'EXIT');
         END IF;

         RETURN l_profile_id;

 END getProfileFromPayeeFormat;

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
     IF (l_default_debug_level >= G_CUR_RUNTIME_LEVEL) THEN
         iby_build_utils_pkg.print_debuginfo(p_module, p_debug_text,
             p_debug_level);
     END IF;

 END print_debuginfo;


END IBY_ASSIGN_PUB;

/
