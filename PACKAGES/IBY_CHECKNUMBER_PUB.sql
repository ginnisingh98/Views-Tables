--------------------------------------------------------
--  DDL for Package IBY_CHECKNUMBER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_CHECKNUMBER_PUB" AUTHID CURRENT_USER AS
/*$Header: ibyckprs.pls 120.23.12010000.2 2009/07/28 12:10:58 asarada ship $*/

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
 -- The attributes of a paper document (usually this
 -- is check stock).
 --
 TYPE paperStockRecType IS RECORD (
     doc_id              CE_PAYMENT_DOCUMENTS.
                             payment_document_id%TYPE,
     doc_name            CE_PAYMENT_DOCUMENTS.
                             payment_document_name%TYPE,
     num_setup_docs      CE_PAYMENT_DOCUMENTS.
                             number_of_setup_documents%TYPE,
     num_lines_per_stub  CE_PAYMENT_DOCUMENTS.
                             number_of_lines_per_remit_stub%TYPE
     );

 --
 -- Table of paper document attributes
 --
 TYPE paperStocksTabType IS TABLE OF paperStockRecType
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
     pmt_currency       IBY_DOCS_PAYABLE_ALL.payment_currency_code%TYPE,
     pmt_function       IBY_DOCS_PAYABLE_ALL.payment_function%TYPE,
     format_payment_id  IBY_DOCS_PAYABLE_ALL.formatting_payment_id%TYPE,
     org_id             IBY_DOCS_PAYABLE_ALL.org_id%TYPE,
     org_type           IBY_DOCS_PAYABLE_ALL.org_type%TYPE
     );

 --
 -- Table of overflow doc recs.
 --
 TYPE overflowDocsTabType IS TABLE OF overflowDocsRecType
     INDEX BY BINARY_INTEGER;

/*--------------------------------------------------------------------
 | NAME:
 |     performCheckNumbering
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
             );

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
     p_payInstrTab   IN IBY_PAYINSTR_PUB.pmtInstrTabType
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
     p_instruction_id    IN IBY_PAY_INSTRUCTIONS_ALL.
                                payment_instruction_id%TYPE,
     x_pmtsInPmtInstrTab IN OUT NOCOPY IBY_PAYINSTR_PUB.pmtsInpmtInstrTabType,
     x_dummyPaperPmtsTab IN OUT NOCOPY IBY_PAYGROUP_PUB.paymentTabType,
     x_setupDocsTab      IN OUT NOCOPY docsTabType,
     x_overflowDocsTab   IN OUT NOCOPY overflowDocsTabType,
     x_insErrorsTab      IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorTabType,
     x_insTokenTab       IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.
                                           trxnErrTokenTabType
     );

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
     );

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
     RETURN NUMBER;

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
 RETURN NUMBER;

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
     );

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
     );

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
     );

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
     );

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
     );

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
 | NOTES:
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
     );


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
 | NOTES:
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
     );

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
     );

/*--------------------------------------------------------------------
 | NAME:
 |    isSinglePayment
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
 FUNCTION isSinglePayment(
     p_paperPmtsTab      IN paperPmtsSpecialDocsTabType
     ) RETURN BOOLEAN;

/*--------------------------------------------------------------------
 | NAME:
 |    isContigPaperNumAvlbl
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
 FUNCTION isContigPaperNumAvlbl(
     p_payment_doc_id IN CE_PAYMENT_DOCUMENTS.payment_document_id%TYPE,
     p_start_number   IN IBY_PAYMENTS_ALL.paper_document_number%TYPE,
     p_end_number     IN IBY_PAYMENTS_ALL.paper_document_number%TYPE
     ) RETURN BOOLEAN;

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
     ) RETURN BOOLEAN;

END IBY_CHECKNUMBER_PUB;

/
