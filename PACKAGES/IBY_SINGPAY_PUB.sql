--------------------------------------------------------
--  DDL for Package IBY_SINGPAY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_SINGPAY_PUB" AUTHID CURRENT_USER AS
/*$Header: ibypsins.pls 120.4.12010000.2 2008/08/22 15:28:33 vkarlapu ship $*/

 --
 -- This record stores all the document fields that are used in
 -- as criteria for grouping a document into a payment. Each
 -- of these fields will result in a grouping rule.
 --
 -- Some of the fields of this record are not used specifically
 -- for grouping, but for raising business events etc.
 -- e.g., the calling app pay req id
 --
 -- Some of the grouping criteria are user defined; these are
 -- specified in the IBY_PMT_CREATION_RULES table. This record
 -- contains placeholder for the user defined grouping fields
 -- as well.
 --
 TYPE paymentGroupCriteriaType IS RECORD (
     calling_app_payreq_cd
         IBY_PAY_SERVICE_REQUESTS.call_app_pay_service_req_code%TYPE,
     document_id
         IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE,
     calling_app_id
         IBY_DOCS_PAYABLE_ALL.calling_app_id%TYPE,
     calling_app_doc_id1
         IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref1%TYPE,
     calling_app_doc_id2
         IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref2%TYPE,
     calling_app_doc_id3
         IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref3%TYPE,
     calling_app_doc_id4
         IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref4%TYPE,
     calling_app_doc_id5
         IBY_DOCS_PAYABLE_ALL.calling_app_doc_unique_ref5%TYPE,
     pay_proc_ttype_cd
         IBY_DOCS_PAYABLE_ALL.pay_proc_trxn_type_code%TYPE,
     payment_grp_num
         IBY_DOCS_PAYABLE_ALL.payment_grouping_number%TYPE,
     payment_method_cd
         IBY_DOCS_PAYABLE_ALL.payment_method_code%TYPE,
     int_bank_acct_id
         IBY_DOCS_PAYABLE_ALL.internal_bank_account_id%TYPE,
     ext_bank_acct_id
         IBY_DOCS_PAYABLE_ALL.external_bank_account_id%TYPE,
     payment_profile_id
         IBY_DOCS_PAYABLE_ALL.payment_profile_id%TYPE,
     org_id
         IBY_DOCS_PAYABLE_ALL.org_id%TYPE,
     org_type
         IBY_DOCS_PAYABLE_ALL.org_type%TYPE,
     le_id
         IBY_DOCS_PAYABLE_ALL.legal_entity_id%TYPE,
     payment_function
         IBY_DOCS_PAYABLE_ALL.payment_function%TYPE,
     ext_payee_id
         IBY_DOCS_PAYABLE_ALL.ext_payee_id%TYPE,
     payee_party_id
         IBY_DOCS_PAYABLE_ALL.payee_party_id%TYPE,
     payee_party_site_id
         IBY_DOCS_PAYABLE_ALL.party_site_id%TYPE,
     supplier_site_id
         IBY_DOCS_PAYABLE_ALL.supplier_site_id%TYPE,
     amount_withheld
         IBY_DOCS_PAYABLE_ALL.amount_withheld%TYPE,

     bank_inst1_code
         IBY_EXTERNAL_PAYEES_ALL.bank_instruction1_code%TYPE,
     bank_inst2_code
         IBY_EXTERNAL_PAYEES_ALL.bank_instruction2_code%TYPE,
     pmt_txt_msg1
         IBY_EXTERNAL_PAYEES_ALL.payment_text_message1%TYPE,
     pmt_txt_msg2
         IBY_EXTERNAL_PAYEES_ALL.payment_text_message2%TYPE,
     pmt_txt_msg3
         IBY_EXTERNAL_PAYEES_ALL.payment_text_message3%TYPE,

     payment_currency
         IBY_DOCS_PAYABLE_ALL.payment_currency_code%TYPE,
     payment_amount
         IBY_DOCS_PAYABLE_ALL.payment_amount%TYPE,
     payment_date
         IBY_DOCS_PAYABLE_ALL.payment_date%TYPE,
     pay_alone_flag
         IBY_DOCS_PAYABLE_ALL.exclusive_payment_flag%TYPE,

     pmt_due_date
         IBY_DOCS_PAYABLE_ALL.payment_due_date%TYPE,
     discount_date
         IBY_DOCS_PAYABLE_ALL.discount_date%TYPE,

     processing_type
         IBY_PAYMENT_PROFILES.processing_type%TYPE,
     decl_option
         IBY_PAYMENT_PROFILES.declaration_option%TYPE,
     decl_only_fx_flag
         IBY_PAYMENT_PROFILES.dcl_only_foreign_curr_pmt_flag%TYPE,
     decl_curr_fx_rate_type
         IBY_PAYMENT_PROFILES.declaration_curr_fx_rate_type%TYPE,
     decl_curr_code
         IBY_PAYMENT_PROFILES.declaration_currency_code%TYPE,
     decl_threshold_amount
         IBY_PAYMENT_PROFILES.declaration_threshold_amount%TYPE,
     support_prom_notes_flag
         IBY_PAYMENT_METHODS_VL.support_bills_payable_flag%TYPE
     );

 --
 -- Table of payment grouping criteria.
 --
 TYPE paymentGroupCriteriaTabType IS TABLE OF paymentGroupCriteriaType
     INDEX BY BINARY_INTEGER;

/*--------------------------------------------------------------------
 | NAME:
 |     createPayments
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
     x_return_status              IN OUT NOCOPY VARCHAR2
     );

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
     x_docErrorTab        IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
     x_errTokenTab        IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.
                                            trxnErrTokenTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     initializePmts
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
 PROCEDURE initializePmts(
     x_paymentTab      IN OUT NOCOPY IBY_PAYGROUP_PUB.paymentTabType
     );

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
     );

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
     p_debug_text IN VARCHAR2);


END IBY_SINGPAY_PUB;

/
