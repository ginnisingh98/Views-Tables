--------------------------------------------------------
--  DDL for Package IBY_PAYINSTR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_PAYINSTR_PUB" AUTHID CURRENT_USER AS
/*$Header: ibypymis.pls 120.31.12010000.1 2008/07/28 05:42:15 appldev ship $*/

 /*
  * This record corresponds to a row in the IBY_PAY_INSTRUCTIONS_ALL
  * table.
  *
  * A PLSQL table of these records are created after applying
  * grouping rules and this table is used in bulk inserting
  * these payment instructions into the IBY_PAY_INSTRUCTIONS_ALL
  * table.
  *
  * The record docsInPaymentRecType holds the payments
  * corresponding to this payment instruction.
  */
 --
 -- This PLSQL table corresponds to IBY_PAY_INSTRUCTIONS_ALL and it
 -- will be used in bulk updating the IBY_PAY_INSTRUCTIONS_ALL table.
 --
 TYPE pmtInstrTabType IS TABLE OF IBY_PAY_INSTRUCTIONS_ALL%ROWTYPE
     INDEX BY BINARY_INTEGER;

 --
 -- This record needs to be created because of the fact that
 -- there is no payment id column in IBY_PAY_INSTRUCTIONS_ALL table.
 -- So we cannot add the payment id as a field in the pmtInstrRecType
 -- record (adding this field to the record will cause a syntax
 -- error during the bulk update).
 --
 -- Therefore, we need a separate data structure to keep track
 -- of the payments that are part of a payment instruction. The
 -- pmtsInpmtInstrRecType is that data structure.
 -- After all the grouping operations are completed, the
 -- IBY_PAYMENTS_ALL table needs to be updated to indicate the
 -- PAYMENT_INSTRUCTION_ID for each payment that has been put
 -- into a payment instruction. The pmtsInpmtInstrRecType
 -- is used for this update.
 --
 -- The record pmtInstrRecType holds the payment instructions
 -- corresponding to these payments.
 --
 TYPE pmtsInPmtInstrRecType IS RECORD (
     payment_id
         IBY_PAYMENTS_ALL.payment_id%TYPE,
     pay_instr_id
         IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE,
     payment_amount
         IBY_PAYMENTS_ALL.payment_amount%TYPE,
     payment_currency
         IBY_PAYMENTS_ALL.payment_currency_code%TYPE,
     payment_status
         IBY_PAYMENTS_ALL.payment_status%TYPE
             := 'INSTRUCTION_CREATED',
     profile_id
         IBY_PAYMENTS_ALL.payment_profile_id%TYPE,
     processing_type
         IBY_PAYMENT_PROFILES.processing_type%TYPE,
     pmt_details_len
         NUMBER,
     document_count
         NUMBER,
     separate_remit_advice_flag
         IBY_PAYMENTS_ALL.separate_remit_advice_req_flag%TYPE := 'N',
     check_number
         IBY_PAYMENTS_ALL.paper_document_number%TYPE
     );

 --
 -- Used to update of the IBY_PAYMENTS_ALL table.
 --
 TYPE pmtsInPmtInstrTabType IS TABLE OF pmtsInPmtInstrRecType
     INDEX BY BINARY_INTEGER;

 --
 -- For check payments, we have to keep track of setup and
 -- overflow documents. These are dummy documents that are
 -- inserted into IBY_DOCS_PAYABLE_ALL table and linked to
 -- a particular payment.
 --
 -- This data structure holds all payments that have processing
 -- type set to 'PAPER' - i.e., payment payments.
 --
 TYPE paperPmtsSpecialDocsRecType IS RECORD (
     payment_id           IBY_PAYMENTS_ALL.payment_id%TYPE,
     instruction_id       IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE,
     num_setup_docs       NUMBER,
     num_overflow_docs    NUMBER,

     /*
      * This has to be retrieved from the profile
      * on the payment
      */
     num_lines_per_stub   NUMBER,

     /*
      * Flag to indicate whether setup docs have
      * already been generated for a particular
      * instruction.
      */
     setup_docs_for_instr_finished  VARCHAR2(1) := 'N',

     /*
      * Physical paper document number for this payment.
      * This number is derived from the paper stock.
      */
     check_number         NUMBER
     );

 --
 -- Table of paperPmtsSpecialDocsRecType records.
 --
 TYPE paperPmtsSpecialDocsTabType IS TABLE OF paperPmtsSpecialDocsRecType
     INDEX BY BINARY_INTEGER;

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
 TYPE instrGroupCriteriaType IS RECORD (
     calling_app_payreq_cd
         IBY_PAY_SERVICE_REQUESTS.call_app_pay_service_req_code%TYPE,
     calling_app_id
         IBY_PAY_SERVICE_REQUESTS.calling_app_id%TYPE,
     pay_service_req_id
         IBY_PAY_SERVICE_REQUESTS.payment_service_request_id%TYPE,
     payment_id
         IBY_PAYMENTS_ALL.payment_id%TYPE,
     int_bank_acct_id
         IBY_PAYMENTS_ALL.internal_bank_account_id%TYPE,
     payment_profile_id
         IBY_PAYMENTS_ALL.payment_profile_id%TYPE,
     org_id
         IBY_PAYMENTS_ALL.org_id%TYPE,
     org_type
         IBY_PAYMENTS_ALL.org_type%TYPE,
     le_id
         IBY_PAYMENTS_ALL.legal_entity_id%TYPE,
     payment_currency
         IBY_PAYMENTS_ALL.payment_currency_code%TYPE,
     payment_amount
         IBY_PAYMENTS_ALL.payment_amount%TYPE,
     payment_date
         IBY_PAYMENTS_ALL.payment_date%TYPE,
     payment_function
         IBY_PAYMENTS_ALL.payment_function%TYPE,
     payment_reason_code
         IBY_PAYMENTS_ALL.payment_reason_code%TYPE,
     payment_reason_comments
         IBY_PAYMENTS_ALL.payment_reason_comments%TYPE,
     pmt_details_length
         NUMBER,
     pmt_prom_note_flag
         IBY_PAYMENTS_ALL.bill_payable_flag%TYPE,
     ppr_id
         IBY_PAYMENTS_ALL.payment_service_request_id%TYPE,
     rfc_identifier
         HZ_CODE_ASSIGNMENTS.class_code%TYPE,
     payment_method_code
         IBY_PAYMENTS_ALL.payment_method_code%TYPE,
     pmt_date_flag
         IBY_INSTR_CREATION_RULES.group_by_payment_date%TYPE,
     pmt_curr_flag
         IBY_INSTR_CREATION_RULES.group_by_payment_currency%TYPE,
     max_payments_flag
         IBY_INSTR_CREATION_RULES.group_by_max_payments_flag%TYPE,
     max_payments_limit
         IBY_INSTR_CREATION_RULES.max_payments_per_instruction%TYPE,
     int_bank_acct_flag
         IBY_INSTR_CREATION_RULES.group_by_internal_bank_account%TYPE,
     max_amount_flag
         IBY_INSTR_CREATION_RULES.group_by_max_instruction_flag%TYPE,
     max_amount_limit
         IBY_INSTR_CREATION_RULES.max_amount_per_instr_value%TYPE,
     max_amount_currency
         IBY_INSTR_CREATION_RULES.max_amount_per_instr_curr_code%TYPE,
     max_amount_fx_rate_type
         IBY_INSTR_CREATION_RULES.max_amount_fx_rate_type%TYPE,
     pay_service_req_flag
         IBY_INSTR_CREATION_RULES.group_by_pay_service_request%TYPE,
     le_flag
         IBY_INSTR_CREATION_RULES.group_by_legal_entity%TYPE,
     org_flag
         IBY_INSTR_CREATION_RULES.group_by_organization%TYPE,
     pmt_function_flag
         IBY_INSTR_CREATION_RULES.group_by_payment_function%TYPE,
     pmt_reason_flag
         IBY_INSTR_CREATION_RULES.group_by_payment_reason%TYPE,
     prom_note_flag
         IBY_INSTR_CREATION_RULES.group_by_bill_payable%TYPE,
     ppr_flag
         IBY_INSTR_CREATION_RULES.group_by_pay_service_request%TYPE,
     rfc_flag
         IBY_INSTR_CREATION_RULES.group_by_rfc%TYPE,
     pmt_method_flag
         IBY_INSTR_CREATION_RULES.group_by_payment_method%TYPE
     );

 --
 -- Table of payment grouping criteria.
 --
 TYPE instrGroupCriteriaTabType IS TABLE OF instrGroupCriteriaType
     INDEX BY BINARY_INTEGER;

 --
 -- This record stores one validation sets applicable to
 -- a particular payment.
 --
 TYPE instructionValSetsRec IS RECORD (
     val_assign_id
         IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     val_set_id
         IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     val_code_package
         IBY_VALIDATION_SETS_VL.validation_code_package%TYPE,
     val_code_entry_pt
         IBY_VALIDATION_SETS_VL.validation_code_entry_point%TYPE
     );

 --
 -- Table of validation sets applicable to a particular payment
 --
 TYPE instructionValSetsTab IS TABLE OF instructionValSetsRec
     INDEX BY BINARY_INTEGER;

 --
 -- Record to temporarily hold count of documents payable
 -- under a payment.
 --
 TYPE docsInPmtCountRecType IS RECORD (
     doc_count           NUMBER,
     payment_id          IBY_PAYMENTS_ALL.
                             payment_id%TYPE
     );

 --
 -- Temporary table to hold count of docs under a payment.
 -- This information will be copied into pmtsInPmtInstrTabType
 -- table for more permanent storage in the pay instr creation
 -- program.
 --
 TYPE docsInPmtCountTabType IS TABLE OF docsInPmtCountRecType
     INDEX BY BINARY_INTEGER;

 --
 -- PLSQL table of documents payable. This table is used to
 -- insert dummy documents payable into IBY_DOCS_PAYABLE_ALL
 -- (for handling setup and overflow documents).
 --
 TYPE docsTabType IS TABLE OF iby_docs_payable_all%ROWTYPE
     INDEX BY BINARY_INTEGER;

 --
 -- Record that holds the formatting_payment_id for a particular
 -- document.
 --
 -- If the document is an overflow document, the formatting_payment_id
 -- will be different from the payment_id, otherwise, both these
 -- will be the same for a particular document.
 --
 TYPE overflowDocsRecType IS RECORD (
     doc_id             IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE,
     payment_id         IBY_DOCS_PAYABLE_ALL.payment_id%TYPE,
     format_payment_id  IBY_DOCS_PAYABLE_ALL.formatting_payment_id%TYPE
     );

 --
 -- Table of overflow doc recs.
 --
 TYPE overflowDocsTabType IS TABLE OF overflowDocsRecType
     INDEX BY BINARY_INTEGER;

 --
 -- Record to hold a payment after sorting. After sorting,
 -- each payment will be assigned a payment reference number.
 --
 TYPE sortedPmtRecType IS RECORD (
     payment_id         IBY_PAYMENTS_ALL.payment_id%TYPE,
     payment_ref        IBY_PAYMENTS_ALL.payment_reference_number%TYPE,
     instr_id           IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE,
     instr_status       IBY_PAY_INSTRUCTIONS_ALL.
                            payment_instruction_status%TYPE,
     ca_id              IBY_PAY_SERVICE_REQUESTS.calling_app_id%TYPE,
     le_id              IBY_PAYMENTS_ALL.legal_entity_id%TYPE,
     doc_cat_code       IBY_PAYMENT_METHODS_VL.document_category_code%TYPE,
     payment_date       IBY_PAYMENTS_ALL.payment_date%TYPE,
     ledger_id          GL_LEDGER_LE_V.ledger_id%TYPE := -1,
     sequence_number    IBY_PAYMENTS_ALL.document_sequence_value%TYPE := -1,
     sequence_id        FND_DOCUMENT_SEQUENCES.doc_sequence_id%TYPE := -1
     );

 --
 -- Table of sorted payment records.
 --
 TYPE sortedPmtTabType IS TABLE OF sortedPmtRecType
     INDEX BY BINARY_INTEGER;

 --
 -- Possible sort options along with the sort order for a single
 -- payment profile.
 --
 TYPE sortOptionsRecType IS RECORD (
     pmt_profile_cd     IBY_INSTR_CREATION_RULES.system_profile_code%TYPE,
     sort_option_1      IBY_INSTR_CREATION_RULES.sort_option_1%TYPE,
     sort_order_1       IBY_INSTR_CREATION_RULES.sort_order_1%TYPE,
     sort_option_2      IBY_INSTR_CREATION_RULES.sort_option_2%TYPE,
     sort_order_2       IBY_INSTR_CREATION_RULES.sort_order_2%TYPE,
     sort_option_3      IBY_INSTR_CREATION_RULES.sort_option_3%TYPE,
     sort_order_3       IBY_INSTR_CREATION_RULES.sort_order_3%TYPE
     );

 --
 -- Table of sort options across profiles.
 --
 TYPE sortOptionsTabType IS TABLE OF sortOptionsRecType
     INDEX BY BINARY_INTEGER;

 --
 --
 -- These two tables store the distinct payment
 -- functions, and orgs that are present in a
 -- payment instruction.
 --
 -- The disbursement UI uses the data in these tables to
 -- restrict access to the user (depending upon the
 -- users' payment function and organization).
 --

 --
 -- Table of distinct access types.
 --
 TYPE distinctPmtFxAccessTab IS TABLE OF IBY_PROCESS_FUNCTIONS%ROWTYPE
     INDEX BY BINARY_INTEGER;

 TYPE distinctOrgAccessTab IS TABLE OF IBY_PROCESS_ORGS%ROWTYPE
     INDEX BY BINARY_INTEGER;


/*--------------------------------------------------------------------
 | NAME:
 |     createPaymentInstructions
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
             );

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
             x_pmtInstrRec       IN OUT NOCOPY IBY_PAY_INSTRUCTIONS_ALL
                                                   %ROWTYPE,
             x_docErrorTab       IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.
                                                   docErrorTabType,
             x_errTokenTab       IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.
                                                   trxnErrTokenTabType,
             x_return_status     IN OUT NOCOPY NUMBER);


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
     x_pmtInstrRec         IN OUT NOCOPY IBY_PAY_INSTRUCTIONS_ALL
                                             %ROWTYPE,
     x_pmtInstrTab         IN OUT NOCOPY pmtInstrTabType,
     p_newPmtInstrFlag     IN BOOLEAN,
     x_currentPmtInstrId   IN OUT NOCOPY IBY_PAY_INSTRUCTIONS_ALL.
                                             payment_instruction_id%TYPE,
     x_pmtsInPmtInstrTab   IN OUT NOCOPY pmtsInPmtInstrTabType,
     x_pmtsInPmtInstrRec   IN OUT NOCOPY pmtsInpmtInstrRecType,
     x_pmtsInPmtInstrCount IN OUT NOCOPY NUMBER,
     x_instrAmount         IN OUT NOCOPY NUMBER
     );

/*--------------------------------------------------------------------
 | NAME:
 |     insertPaymentInstructions
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
 PROCEDURE insertPaymentInstructions(
     p_payInstrTab           IN pmtInstrTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     updatePaymentInstructions
 |
 | PURPOSE:
 |     Performs an update of all created instructions from PLSQL
 |     table into IBY_PAY_INSTRUCTIONS_ALL table.
 |
 |     The created instructions have already been inserted into
 |     IBY_PAY_INSTRUCTIONS_ALL after grouping. So we only need to
 |     update certain fields of the instruction that have been
 |     changed after the grouping was performed.
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
     );

/*--------------------------------------------------------------------
 | NAME:
 |     getNextPaymentInstructionID
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
 PROCEDURE getNextPaymentInstructionID(
     x_pmtInstrID IN OUT NOCOPY IBY_PAY_INSTRUCTIONS_ALL.
                                    payment_instruction_id%TYPE
     );

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
     );

/*--------------------------------------------------------------------
 | NAME:
 |     performDBUpdates
 |
 | PURPOSE:
 |
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
     );

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
     );

/*--------------------------------------------------------------------
 | NAME:
 |     getFxAmount()
 |
 | PURPOSE:
 |     Calls GL API to get converted amount in foreign currency.
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
 FUNCTION getFxAmount(
     p_source_currency   IN VARCHAR2,
     p_target_currency   IN VARCHAR2,
     p_exch_rate_date    IN DATE,
     p_exch_rate_type    IN VARCHAR2,
     p_source_amount     IN NUMBER
     )
     RETURN NUMBER;

 /*
  * This pragma is needed because the GL API enforces it.
  */
 PRAGMA RESTRICT_REFERENCES(getFxAmount, WNDS, WNPS, RNPS);

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
     );

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
     );

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
     );

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
     );

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
     );

/*--------------------------------------------------------------------
 | NAME:
 |     executeValidationsForInstr
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
 PROCEDURE executeValidationsForInstr(
     x_pmtInstrRec  IN OUT NOCOPY IBY_PAY_INSTRUCTIONS_ALL%ROWTYPE,
     p_valSetsTab   IN instructionValSetsTab,
     p_isReval      IN BOOLEAN,
     x_docErrorTab  IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
     x_errTokenTab  IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.trxnErrTokenTabType
     );

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
     );

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
 *---------------------------------------------------------------------*/
 FUNCTION getXMLClob(
     p_pay_instruction_id     IN VARCHAR2,
     p_instruction_status     IN VARCHAR2
     )
     RETURN VARCHAR2;

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
     );

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
     x_pmtInstrTab    IN OUT NOCOPY pmtInstrTabType,
     x_sortedPmtTab   IN OUT NOCOPY sortedPmtTabType,
     p_profileMap     IN IBY_BUILD_UTILS_PKG.profileIdToCodeMapTabType,
     x_docErrorTab    IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
     x_errTokenTab    IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.trxnErrTokenTabType
     );

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
     x_sortedPmtTab    IN OUT NOCOPY sortedPmtTabType,
     x_docErrorTab     IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
     x_errTokenTab     IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.trxnErrTokenTabType
     );

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
     );

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
    );

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
     );

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
 RETURN sortOptionsRecType;

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
 RETURN VARCHAR2;


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
     );

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
 |
 *---------------------------------------------------------------------*/
 PROCEDURE providePaymentReferences(
     x_sortPmtsTab    IN OUT NOCOPY sortedPmtTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     dummyGLAPI
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
 PROCEDURE dummyGLAPI(
     p_exch_date          IN         DATE,
     p_source_amount      IN         NUMBER,
     p_source_curr        IN         VARCHAR2,
     p_decl_curr          IN         VARCHAR2,
     p_decl_fx_rate_type  IN         VARCHAR2,
     x_decl_amount        OUT NOCOPY NUMBER);

/*--------------------------------------------------------------------
 | NAME:
 |     dummy_ruleFunction
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
 FUNCTION dummy_ruleFunction(
     p_subscription IN            RAW,
     p_event        IN OUT NOCOPY WF_EVENT_T
     )
     RETURN VARCHAR2;

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
     );

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
     );

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
     );

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
     );

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
     RETURN BOOLEAN;

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
     RETURN BOOLEAN;

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
     );

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
     RETURN NUMBER;

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
     );

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
     );

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
     );


END IBY_PAYINSTR_PUB;

/
