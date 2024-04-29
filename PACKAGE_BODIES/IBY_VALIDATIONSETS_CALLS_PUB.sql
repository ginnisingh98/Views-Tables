--------------------------------------------------------
--  DDL for Package Body IBY_VALIDATIONSETS_CALLS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_VALIDATIONSETS_CALLS_PUB" AS
/*$Header: ibyvalcb.pls 120.20.12010000.11 2010/04/06 07:11:40 asarada ship $*/

G_CURRENT_RUNTIME_LEVEL      CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
 G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBY_VALIDATIONSETS_CALLS_PUB';


 --
 -- List of possible transaction types
 -- These are used to insert into the IBY_TRANSACTION_ERRORS table.
 --
 TRANS_TYPE_DOC   CONSTANT VARCHAR2(100) := 'DOCUMENT_PAYABLE';
 TRANS_TYPE_PAY   CONSTANT VARCHAR2(100) := 'PAYMENT';
 TRANS_TYPE_INS   CONSTANT VARCHAR2(100) := 'PAYMENT_INSTRUCTION';

 --
 -- List of possible error types
 -- These are used to insert into the IBY_TRANSACTION_ERRORS table.
 --
 ERROR_TYPE_VALIDATION   CONSTANT VARCHAR2(100) := 'VALIDATION';
 ERROR_TYPE_BANK         CONSTANT VARCHAR2(100) := 'BANK';


 PROCEDURE validate_uri_using_modulus10(s IN VARCHAR2,
     x_valResult   OUT NOCOPY BOOLEAN,
     x_docErrorRec IN OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE);

 PROCEDURE xxno_chk_mod_10_11
    (p_kid_nr  IN  varchar2,
     x_valResult   OUT NOCOPY BOOLEAN,
     x_docErrorRec IN OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE);

/*--------------------------------------------------------------------
 | NAME:
 |     CITI_AT_EFT_DOM_PAYEE
 |
 | PURPOSE:
 |     Citibank Austrian domestic EFT payee validation
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
 PROCEDURE CITI_AT_EFT_DOM_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id           IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate target name
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PAYEE_PARTY_NAME',
         l_document_rec.payee_party_name,
         'MAXLENGTH',
         null,
         35,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate target bank account number
     -- by CE

     -- Validate target bank country code
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_BRANCH_COUNTRY',
         l_document_rec.ext_bank_branch_country,
         'STRIS',
         'AT',
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate target bank code
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_BRANCH_NUM',
         l_document_rec.ext_bank_branch_num,
         'MAXLENGTH',
         null,
         5,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Insert errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END CITI_AT_EFT_DOM_PAYEE;

/*--------------------------------------------------------------------
 | NAME:
 |     CITI_AT_EFT_DOM_DOC
 |
 | PURPOSE:
 |     Citibank Austrian domestic EFT document validation
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
 PROCEDURE CITI_AT_EFT_DOM_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate transaction code
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'DELIVERY_CHANNEL_CODE',
         l_document_rec.delivery_channel_code,
         'INDELIV',
         'AT',
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END CITI_AT_EFT_DOM_DOC;

/*--------------------------------------------------------------------
 | NAME:
 |     AT_EFT_INT_INTERNAL_BANK
 |
 | PURPOSE:
 |     Austrian International EFT internal bank validation
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
 PROCEDURE AT_EFT_INT_INTERNAL_BANK(
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate payer bank account number
     -- by CE

     -- Validate payer bank sort code
     -- by CE

     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'INT_BANK_BRANCH_NUM',
         '+'||substr(l_document_rec.int_bank_branch_num,1,1)||'+',
         'NOTINSET',
         '+0+9+',
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Insert errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END AT_EFT_INT_INTERNAL_BANK;

 /*--------------------------------------------------------------------
 | NAME:
 |     AT_EFT_INT_PAYER
 |
 | PURPOSE:
 |     Austrian international EFT payer validation
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
 PROCEDURE AT_EFT_INT_PAYER (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate payer company description
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PAYER_LE_NANE',
         l_document_rec.payer_le_name,
         'NOTNULL',
         null,
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate payer location telephone number
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PAYER_PHONE',
         l_document_rec.payer_phone,
         'NOTNULL',
         null,
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Insert errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END AT_EFT_INT_PAYER;

 /*--------------------------------------------------------------------
 | NAME:
 |     AT_EFT_INT_PAYEE
 |
 | PURPOSE:
 |     Austrian international EFT payee validation
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
 PROCEDURE AT_EFT_INT_PAYEE(
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate payee bank account number
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_ACC_NUM',
         l_document_rec.ext_bank_acc_num,
         'NOTNULL',
         null,
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate payee bank sort code
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_BRANCH_NUM',
         l_document_rec.ext_bank_branch_num,
         'NOTNULL',
         null,
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Insert errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END AT_EFT_INT_PAYEE;

/*--------------------------------------------------------------------
 | NAME:
 |     CITI_BE_EFT_DOM_PAYEE
 |
 | PURPOSE:
 |     Citibank Belgian domestic EFT payee validation
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
 PROCEDURE CITI_BE_EFT_DOM_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate target name
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PAYEE_PARTY_NAME',
         l_document_rec.payee_party_name,
         'MAXLENGTH',
         null,
         26,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate target bank account number
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_ACC_NUM',
         l_document_rec.ext_bank_acc_num,
         'MAXLENGTH',
         null,
         12,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_ACC_NUM',
         l_document_rec.ext_bank_acc_num,
         'DIGITSONLY',
         null,
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- by CE (the most important validation for this data)
     -- check algorithm

     -- Validate target bank country code
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_BRANCH_COUNTRY',
         l_document_rec.ext_bank_branch_country,
         'STRIS',
         'BE',
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END CITI_BE_EFT_DOM_PAYEE;

/*--------------------------------------------------------------------
 | NAME:
 |     P_CITI_BE_EFT_DOM_PMT
 |
 | PURPOSE:
 |     Citibank Belgian domestic EFT payment validation
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
 PROCEDURE P_CITI_BE_EFT_DOM_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_payment_rec IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 l_max_ach_amt NUMBER;

 BEGIN

     -- Initializing the payment record
     IBY_VALIDATIONSETS_PUB.initPaymentData(p_payment_id,l_payment_rec);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_payment_id;
     l_docErrorRec.transaction_type := 'PAYMENT';
     l_docErrorRec.calling_app_doc_unique_ref1 := p_payment_id;

     -- Validate transaction reference
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PMT_ID',
         l_payment_rec.pmt_id,
         'MAXLENGTH',
         null,
         8,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate transaction amount
     IBY_VALIDATIONSETS_PUB.getParamValue(
                            p_validation_assign_id,
                            p_validation_set_code,
                            'MAX_PAYMENT_AMOUNT',
                            l_max_ach_amt );

     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PMT_AMOUNT',
         l_payment_rec.pmt_amount,
         'LESSEQUAL',
         null,
         l_max_ach_amt,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     -- The first parameter p_is_online_val takes hardcoded value 'N'.
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END P_CITI_BE_EFT_DOM_PMT;

/*--------------------------------------------------------------------
 | NAME:
 |     BE_EFT_DOM_DOC
 |
 | PURPOSE:
 |     Belgian domestic EFT document validation
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
 PROCEDURE BE_EFT_DOM_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate payment currency
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'DOCUMENT_PAY_CURRENCY',
         l_document_rec.document_pay_currency,
         'STRIS',
         'EUR',
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END BE_EFT_DOM_DOC;

 /*--------------------------------------------------------------------
 | NAME:
 |     BE_EFT_INT_PAYEE
 |
 | PURPOSE:
 |     Belgian international EFT payee validation
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
 PROCEDURE BE_EFT_INT_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate vendor site cost code
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'BANK_CHARGE_BEARER',
         l_document_rec.bank_charge_bearer,
         'INLOOKUPTYPE',
         'IBY_BANK_CHARGE_BEARER',
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate payee bank number/branch number
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_NUM',
         l_document_rec.ext_bank_num,
         'NOTNULL',
         null,
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.evaluateCondition(
            'EXT_BANK_BRANCH_NUM',
            l_document_rec.ext_bank_branch_num,
            'NOTNULL',
            null,
            null,
            l_valResult,
            l_docErrorRec);

        IF (l_valResult = FALSE) THEN
           IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
           l_valid := 1;
        END IF;
     END IF;

     -- Validate EFT cost code
     -- Not necessary. Combined into Validate Supplier cost code.

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END BE_EFT_INT_PAYEE;

/*--------------------------------------------------------------------
 | NAME:
 |     BE_EFT_INT_DOC
 |
 | PURPOSE:
 |     Belgian international EFT document validation
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
 PROCEDURE BE_EFT_INT_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate payment method
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_ACC_NUM',
         l_document_rec.ext_bank_acc_num,
         'NOTNULL',
         null,
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate number of IBLC code
     -- Not coded. This has been moved to the payment level.

     -- Validate number of detail records
     -- Not coded. This has been moved to the instruction level.

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END BE_EFT_INT_DOC;

/*--------------------------------------------------------------------
 | NAME:
 |     P_BE_EFT_INT_PMT
 |
 | PURPOSE:
 |     Belgian international EFT payment validation.
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
 PROCEDURE P_BE_EFT_INT_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_payment_rec IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 l_max_check_amt NUMBER;
 l_max_pay_reason_cnt NUMBER;

 BEGIN

     -- Initializing the payment record
     IBY_VALIDATIONSETS_PUB.initPaymentData(p_payment_id,l_payment_rec);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_payment_id;
     l_docErrorRec.transaction_type := 'PAYMENT';
     l_docErrorRec.calling_app_doc_unique_ref1 := p_payment_id;

     -- Validate payment amount
     IBY_VALIDATIONSETS_PUB.getParamValue(
                            p_validation_assign_id,
                            p_validation_set_code,
                            'MAX_PAYMENT_AMOUNT',
                            l_max_check_amt );

     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PMT_AMOUNT',
         l_payment_rec.pmt_amount,
         'LESSEQUAL',
         null,
         l_max_check_amt,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate number of IBLC codes
     -- Bug 5411492 changes start here
     -- Analysis - the commenting of this code will ignore the validation.
/*------------------------------------------------------------------------
     IBY_VALIDATIONSETS_PUB.getParamValue(
                            p_validation_assign_id,
                            p_validation_set_code,
                            'MAX_PAYMENT_REASON_COUNT',
                            l_max_pay_reason_cnt );

     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PMT_PAYMENT_REASON_COUNT',
         l_payment_rec.pmt_payment_reason_count,
         'LESSEQUAL',
         null,
         l_max_pay_reason_cnt,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

---------------------------------------------------------------------------*/

-- Bug 5411492 changes end here

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     -- The first parameter p_is_online_val takes hardcoded value 'N'.
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END P_BE_EFT_INT_PMT;

/*--------------------------------------------------------------------
 | NAME:
 |     I_BE_EFT_INT_INSTR
 |
 | PURPOSE:
 |     Belgian international EFT payment instruction validation
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
 PROCEDURE I_BE_EFT_INT_INSTR (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_instruction_id     IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
     IS

 l_instruction_rec IBY_VALIDATIONSETS_PUB.instructionRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 l_max_num_of_docs NUMBER;

 BEGIN

     -- Initializing the payment record
     IBY_VALIDATIONSETS_PUB.initInstructionData(p_instruction_id,l_instruction_rec);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_instruction_id;
     l_docErrorRec.transaction_type := 'PAYMENT_INSTRUCTION';
     l_docErrorRec.calling_app_doc_unique_ref1 := p_instruction_id;

     -- Validate number of detail records
     IBY_VALIDATIONSETS_PUB.getParamValue(
                            p_validation_assign_id,
                            p_validation_set_code,
                            'MAX_DOCUMENT_COUNT',
                            l_max_num_of_docs );

     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'INS_DOCUMENT_COUNT',
         l_instruction_rec.ins_document_count,
         'LESSEQUAL',
         null,
         l_max_num_of_docs,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     -- The first parameter p_is_online_val takes hardcoded value 'N'.
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END I_BE_EFT_INT_INSTR;

/*--------------------------------------------------------------------
 | NAME:
 |     CITI_CH_EFT_DOM_PAYEE
 |
 | PURPOSE:
 |     Citibank Swiss domestic EFT payee validation.
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
 PROCEDURE CITI_CH_EFT_DOM_PAYEE(
     p_validation_assign_id IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     if l_document_rec.delivery_channel_code = '1000' then

        -- Validate target name
        IBY_VALIDATIONSETS_PUB.evaluateCondition(
            'PAYEE_PARTY_NAME',
            l_document_rec.payee_party_name,
            'MAXLENGTH',
            null,
            20,
            l_valResult,
            l_docErrorRec);

        IF (l_valResult = FALSE) THEN
           IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
           l_valid := 1;
        END IF;

        -- Validate target address
        IBY_VALIDATIONSETS_PUB.evaluateCondition(
	    'PAYEE_PARTY_SITE_ADDR1',
	    l_document_rec.payee_party_addr1,
	    'NOTNULL',
	    null,
	    null,
	    l_valResult,
	    l_docErrorRec);

        IF (l_valResult = FALSE) THEN
   	       IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
	       l_valid := 1;
        END IF;

        IBY_VALIDATIONSETS_PUB.evaluateCondition(
            'PAYEE_PARTY_SITE_ADDR1',
            l_document_rec.payee_party_addr1,
            'MAXLENGTH',
            null,
            20,
            l_valResult,
            l_docErrorRec);

        IF (l_valResult = FALSE) THEN
           IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
           l_valid := 1;
        END IF;

        -- Validate target bank account number
        IBY_VALIDATIONSETS_PUB.evaluateCondition(
            'EXT_BANK_ACC_NUM',
            l_document_rec.ext_bank_acc_num,
            'DIGITSONLY',
            null,
            null,
            l_valResult,
            l_docErrorRec);

        IF (l_valResult = FALSE) THEN
           IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
           l_valid := 1;
        END IF;

        IBY_VALIDATIONSETS_PUB.evaluateCondition(
            'EXT_BANK_ACC_NUM',
            l_document_rec.ext_bank_acc_num,
            'EXACTLENGTH',
            null,
            9,
            l_valResult,
            l_docErrorRec);

        IF (l_valResult = FALSE) THEN
           IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
           l_valid := 1;
        END IF;

     elsif l_document_rec.delivery_channel_code in ('0100', '0000') then

        -- Validate target name
        IBY_VALIDATIONSETS_PUB.evaluateCondition(
            'PAYEE_PARTY_NAME',
            l_document_rec.payee_party_name,
            'MAXLENGTH',
            null,
            24,
            l_valResult,
            l_docErrorRec);

        IF (l_valResult = FALSE) THEN
           IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
           l_valid := 1;
        END IF;

        -- Validate target address
        IBY_VALIDATIONSETS_PUB.evaluateCondition(
	        'PAYEE_PARTY_SITE_ADDR1',
	        l_document_rec.payee_party_addr1,
	        'NOTNULL',
	        null,
	        null,
	        l_valResult,
	        l_docErrorRec);

        IF (l_valResult = FALSE) THEN
   	       IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
	       l_valid := 1;
        END IF;

        IBY_VALIDATIONSETS_PUB.evaluateCondition(
            'PAYEE_PARTY_SITE_ADDR1',
            l_document_rec.payee_party_addr1,
            'MAXLENGTH',
            null,
            24,
            l_valResult,
            l_docErrorRec);

        IF (l_valResult = FALSE) THEN
           IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
           l_valid := 1;
        END IF;

        -- Validate target bank address
        IBY_VALIDATIONSETS_PUB.evaluateCondition(
            'EXT_BANK_BRANCH_ADDR1',
            l_document_rec.ext_bank_branch_addr1,
            'NOTNULL',
            null,
            null,
            l_valResult,
            l_docErrorRec);

        IF (l_valResult = FALSE) THEN
           IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(
               l_docErrorRec, l_docErrorTab);
           l_valid := 1;
        END IF;

        IBY_VALIDATIONSETS_PUB.evaluateCondition(
            'EXT_BANK_BRANCH_ADDR1',
            l_document_rec.ext_bank_branch_addr1,
            'MAXLENGTH',
            null,
            24,
            l_valResult,
            l_docErrorRec);

        IF (l_valResult = FALSE) THEN
           IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
           l_valid := 1;
        END IF;

        -- Validate target bank code
        if (length(l_document_rec.ext_bank_branch_num) in (3, 4, 5) or
	    (length(l_document_rec.ext_bank_branch_num) = 9 and
	     substr(l_document_rec.ext_bank_branch_num,1,2) = '07') ) then
	   null;
	else
	   -- this is a dummy validation for generating the error message.
           IBY_VALIDATIONSETS_PUB.evaluateCondition(
               'EXT_BANK_BRANCH_NUM',
               l_document_rec.ext_bank_branch_num,
               'MAXLENGTH',
               null,
               -1,
               l_valResult,
               l_docErrorRec);

           IF (l_valResult = FALSE) THEN
              IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
              l_valid := 1;
           END IF;
        end if;

        -- Validate target bank account number
        IBY_VALIDATIONSETS_PUB.evaluateCondition(
            'EXT_BANK_ACC_NUM',
            l_document_rec.ext_bank_acc_num,
            'MAXLENGTH',
            null,
            27,
            l_valResult,
            l_docErrorRec);

        IF (l_valResult = FALSE) THEN
           IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
           l_valid := 1;
        END IF;
     else
        null;
     end if;

     -- Insert errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the validation result
     x_result := l_valid;

 END CITI_CH_EFT_DOM_PAYEE;

/*--------------------------------------------------------------------
 | NAME:
 |     CITI_CH_EFT_DOM_DOC
 |
 | PURPOSE:
 |     Citibank Swiss domestic EFT document validation.
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
 PROCEDURE CITI_CH_EFT_DOM_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate transaction code
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'DELIVERY_CHANNEL_CODE',
         l_document_rec.delivery_channel_code,
         'INDELIV',
         'CH',
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate ESR reference number
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'UNIQUE_REMIT_ID_CODE',
         l_document_rec.unique_remit_id_code,
         'VALID_CH_ESR',
         null,
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END CITI_CH_EFT_DOM_DOC;

/*--------------------------------------------------------------------
 | NAME:
 |     P_CITI_CH_EFT_DOM_PMT
 |
 | PURPOSE:
 |     Citibank Swiss domestic EFT payment validation.
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
 PROCEDURE P_CITI_CH_EFT_DOM_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_payment_rec IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the payment record
     IBY_VALIDATIONSETS_PUB.initPaymentData(p_payment_id,l_payment_rec);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_payment_id;
     l_docErrorRec.transaction_type := 'PAYMENT';
     l_docErrorRec.calling_app_doc_unique_ref1 := p_payment_id;

     -- Validate transaction reference
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PMT_ID',
         l_payment_rec.pmt_id,
         'MAXLENGTH',
         null,
         11,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     -- The first parameter p_is_online_val takes hardcoded value 'N'.
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END P_CITI_CH_EFT_DOM_PMT;

/*--------------------------------------------------------------------
 | NAME:
 |     CH_EFT_GEN_PAYEE
 |
 | PURPOSE:
 |     Swiss EFT general payee validation.
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
 PROCEDURE CH_EFT_GEN_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the payment record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate bank account type (delivery channel)
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'DELIVERY_CHANNEL_CODE',
         l_document_rec.delivery_channel_code,
         'INDELIV',
         'CH',
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate bank account number
/*
     Bug 6269371: Corrected delivery channel codes as seeded in
                  IBY_DELIVERY_CHANNELS_B table.
*/
     if l_document_rec.delivery_channel_code in ('CH_BANK', 'CH_DTACHECK') then
        IBY_VALIDATIONSETS_PUB.evaluateCondition(
            'EXT_BANK_ACC_NUM',
            l_document_rec.ext_bank_acc_num,
            'NOTNULL',
            null,
            null,
            l_valResult,
            l_docErrorRec);

        IF (l_valResult = FALSE) THEN
           IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
           l_valid := 1;
        END IF;
     end if;

     -- Validate supplier name and address
     -- Note coded. This will be handled in a separate validation set for char set.

     -- Insert errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the validation result
     x_result := l_valid;

 END CH_EFT_GEN_PAYEE;

/*--------------------------------------------------------------------
 | NAME:
 |     CH_EFT_GEN_DOC
 |
 | PURPOSE:
 |     Swiss EFT general document validation.
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
 PROCEDURE CH_EFT_GEN_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the payment record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     if l_document_rec.delivery_channel_code = 'CH_ESR' then  -- Bug 6269371

        -- Validate ESR exclusive payment flag
        IBY_VALIDATIONSETS_PUB.evaluateCondition(
            'EXCLUSIVE_PAYMENT_FLAG',
            l_document_rec.exclusive_payment_flag,
            'STRIS',
            'Y',
            null,
            l_valResult,
            l_docErrorRec);

        IF (l_valResult = FALSE) THEN
           IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
           l_valid := 1;
        END IF;

        -- Validate ESR number: case 1 ESR number is null
        IBY_VALIDATIONSETS_PUB.evaluateCondition(
            'UNIQUE_REMIT_ID_CODE',
            l_document_rec.unique_remit_id_code,
            'NOTNULL',
            null,
            null,
            l_valResult,
            l_docErrorRec);

        IF (l_valResult = FALSE) THEN
           IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
           l_valid := 1;
        END IF;

        -- Validate ESR number: case 2 ESR number length is 15, 16 or 27
        IBY_VALIDATIONSETS_PUB.evaluateCondition(
            'UNIQUE_REMIT_ID_CODE',
            '+'||length(l_document_rec.unique_remit_id_code)||'+',
            'INSET',
            '+15+16+27+',
            null,
            l_valResult,
            l_docErrorRec);

        IF (l_valResult = FALSE) THEN
           IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
           l_valid := 1;
        END IF;

        -- Validate ESR number: case 3
        IBY_VALIDATIONSETS_PUB.evaluateCondition(
            'UNIQUE_REMIT_ID_CODE',
            l_document_rec.unique_remit_id_code,
            'DIGITSONLY',
            null,
            null,
            l_valResult,
            l_docErrorRec);

        IF (l_valResult = FALSE) THEN
           IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
           l_valid := 1;
        ELSE
           if length(l_document_rec.unique_remit_id_code) <> 15 then
              IBY_VALIDATIONSETS_PUB.evaluateCondition(
                  'UNIQUE_REMIT_ID_CODE',
                  l_document_rec.unique_remit_id_code,
                  'VALID_CH_ESR',
                  null,
                  null,
                  l_valResult,
                  l_docErrorRec);

              IF (l_valResult = FALSE) THEN
                 IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
                 l_valid := 1;
              END IF;

           end if;
        END IF;

        -- Validate invoice amount
        IBY_VALIDATIONSETS_PUB.evaluateCondition(
            'DOCUMENT_AMOUNT',
            l_document_rec.document_amount,
            'GRTEQUAL',
            null,
            0,
            l_valResult,
            l_docErrorRec);

        IF (l_valResult = FALSE) THEN
           IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
           l_valid := 1;
        END IF;

     elsif l_document_rec.delivery_channel_code = 'CH_BANK' then -- Bug 6269371

        -- Validate payment currency
        IBY_VALIDATIONSETS_PUB.evaluateCondition(
            'DOCUMENT_PAY_CURRENCY',
            l_document_rec.document_pay_currency,
            'STRIS',
            'CHF',
            null,
            l_valResult,
            l_docErrorRec);

        IF (l_valResult = FALSE) THEN
           IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
           l_valid := 1;
        END IF;

     else
        null;
     end if;

     -- Validate ESR number for non-ESR payments
     if l_document_rec.delivery_channel_code <> 'CH_ESR' then -- Bug 6269371
        IBY_VALIDATIONSETS_PUB.evaluateCondition(
            'UNIQUE_REMIT_ID_CODE',
            trim(l_document_rec.unique_remit_id_code),
            'ISNULL',
            null,
            null,
            l_valResult,
            l_docErrorRec);

        IF (l_valResult = FALSE) THEN
           IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
           l_valid := 1;
        END IF;
     end if;

     -- Validate invoice number
     -- Not coded. To be handled in a separate validation set for char set.

     -- Validate bank account type for SAD payments
     -- Ignore: SAD format is obsolete.

     -- Insert errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the validation result
     x_result := l_valid;

 END CH_EFT_GEN_DOC;

  /*--------------------------------------------------------------------
  | NAME:
  |     CITI_DE_EFT_DOM_PAYEE
  |
  | PURPOSE:
  |     Citibank German domestic EFT payee validation
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
  PROCEDURE CITI_DE_EFT_DOM_PAYEE (
      p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
      p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
      p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
      p_is_online_val      IN VARCHAR2,
      x_result             OUT NOCOPY NUMBER)
  IS

  l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
  l_valResult BOOLEAN;
  l_valid NUMBER := 0;
  l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
  l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

  BEGIN

      -- Initializing the document record
      IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

      l_docErrorRec.validation_set_code := p_validation_set_code;
      l_docErrorRec.transaction_id := p_document_id;
      l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
      l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
      l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
      l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

      -- Validate target name
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PAYEE_PARTY_NAME',
         l_document_rec.payee_party_name,
         'MAXLENGTH',
         null,
         27,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

      -- Validate target bank account number
      -- by CE

      -- Validate target bank country code
      IBY_VALIDATIONSETS_PUB.evaluateCondition(
          'EXT_BANK_BRANCH_COUNTRY',
          l_document_rec.ext_bank_branch_country,
          'STRIS',
          'DE',
          null,
          l_valResult,
          l_docErrorRec);

      IF (l_valResult = FALSE) THEN
         IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
         l_valid := 1;
      END IF;

      -- Validate target bank code
      IBY_VALIDATIONSETS_PUB.evaluateCondition(
          'EXT_BANK_BRANCH_NUM',
          l_document_rec.ext_bank_branch_num,
          'MAXLENGTH',
          null,
          8,
          l_valResult,
          l_docErrorRec);

      IF (l_valResult = FALSE) THEN
         IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
         l_valid := 1;
      END IF;

      -- Inserting errors into IBY_TRANSACTION_ERRORS
      IF (l_valid = 1) THEN
         IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
      END IF;

      -- Return the Validation Result
      x_result := l_valid;

  END CITI_DE_EFT_DOM_PAYEE;

 /*--------------------------------------------------------------------
 | NAME:
 |     CITI_DE_EFT_DOM_DOC
 |
 | PURPOSE:
 |     Citibank German domestic EFT document validation
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
 PROCEDURE CITI_DE_EFT_DOM_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate transaction code
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'DELIVERY_CHANNEL_CODE',
         l_document_rec.delivery_channel_code,
         'INDELIV',
         'DE',
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END CITI_DE_EFT_DOM_DOC;

 /*--------------------------------------------------------------------
 | NAME:
 |     DE_EFT_DOM_INTERNAL_BANK
 |
 | PURPOSE:
 |     German domestic EFT internal bank validation
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
 PROCEDURE DE_EFT_DOM_INTERNAL_BANK (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate user EFT number
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'INT_EFT_USER_NUMBER',
         l_document_rec.int_eft_user_number,
         'EXACTLENGTH',
         10,
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate user bank account number
     -- by CE

     -- Validate user bank BLZ
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'INT_BANK_BRANCH_NUM',
         l_document_rec.int_bank_branch_num,
         'EXACTLENGTH',
         8,
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'INT_BANK_BRANCH_NUM',
         '+'||substr(l_document_rec.int_bank_branch_num, 1, 1)||'+',
         'NOTINSET',
         '+0+9+',
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END DE_EFT_DOM_INTERNAL_BANK;

 /*--------------------------------------------------------------------
 | NAME:
 |     DE_EFT_DOM_PAYER
 |
 | PURPOSE:
 |     German domestic EFT payer validation
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
 PROCEDURE DE_EFT_DOM_PAYER (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate location description for organization ID
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PAYER_LE_NANE',
         l_document_rec.payer_le_name,
         'NOTNULL',
         null,
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END DE_EFT_DOM_PAYER;

/*--------------------------------------------------------------------
 | NAME:
 |     DE_EFT_DOM_PAYEE
 |
 | PURPOSE:
 |     German domestic EFT payee validation
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
 PROCEDURE DE_EFT_DOM_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate customer/supplier bank name
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_ACC_NAME',
         l_document_rec.ext_bank_acc_name,
         'NOTNULL',
         null,
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate customer/supplier bank account number
     -- by CE

     -- Validate customer/supplier bank BLZ
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_BRANCH_NUM',
         l_document_rec.ext_bank_branch_num,
         'EXACTLENGTH',
         8,
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_BRANCH_NUM',
         '+'||substr(l_document_rec.ext_bank_branch_num, 1, 1)||'+',
         'NOTINSET',
         '+0+9+',
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END DE_EFT_DOM_PAYEE;

/*--------------------------------------------------------------------
 | NAME:
 |     P_DE_EFT_DOM_PMT
 |
 | PURPOSE:
 |    German domestic EFT payment validation
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
 PROCEDURE P_DE_EFT_DOM_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_payment_rec IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the payment record
     IBY_VALIDATIONSETS_PUB.initPaymentData(p_payment_id,l_payment_rec);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_payment_id;
     l_docErrorRec.transaction_type := 'PAYMENT';
     l_docErrorRec.calling_app_doc_unique_ref1 := p_payment_id;

     -- Validate payment amount
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PMT_AMOUNT',
         l_payment_rec.pmt_amount,
         'NOTEQUALTO',
         null,
         0,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END P_DE_EFT_DOM_PMT;

/*--------------------------------------------------------------------
 | NAME:
 |     DE_EFT_INT_INTERNAL_BANK
 |
 | PURPOSE:
 |     German international EFT internal bank validation
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
 PROCEDURE DE_EFT_INT_INTERNAL_BANK (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate user EFT number
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'INT_EFT_USER_NUMBER',
         l_document_rec.int_eft_user_number,
         'EXACTLENGTH',
         null,
         10,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate user bank account number
     -- by CE

     -- Validate user bank BLZ
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'INT_BANK_BRANCH_NUM',
         l_document_rec.int_bank_branch_num,
         'NOTNULL',
         null,
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'INT_BANK_BRANCH_NUM',
         '+'||substr(l_document_rec.int_bank_branch_num, 1, 1)||'+',
         'NOTINSET',
         '+0+9+',
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END DE_EFT_INT_INTERNAL_BANK;

/*--------------------------------------------------------------------
 | NAME:
 |     DE_EFT_INT_PAYEE
 |
 | PURPOSE:
 |    German international EFT payee validation
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
 PROCEDURE DE_EFT_INT_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate customer/supplier bank name
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_ACC_NAME',
         l_document_rec.ext_bank_acc_name,
         'NOTNULL',
         null,
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate customer/supplier bank account number
     -- by CE

     -- Validate document country
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PAYEE_PARTY_SITE_COUNTRY',
         l_document_rec.payee_party_country,
         'STRISNOT',
         l_document_rec.payer_le_country,
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END DE_EFT_INT_PAYEE;

/*--------------------------------------------------------------------
 | NAME:
 |     DE_EFT_INT_PAYER
 |
 | PURPOSE:
 |     German international EFT payer validation
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
 PROCEDURE DE_EFT_INT_PAYER (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

    /*-------------------------------------------------------------*/

    /*
     * Fix for bug 5439146:
     *
     * Germany EFT company number and LZB area validations
     * fall under the category of payment system specific
     * validations.
     *
     * Currently, the area of payment system specific
     * validations is under re-design. This is because
     * each payment system can be linked to a variable number
     * of validations, so a general approachs needs to
     * be defined on how these validations should be
     * implemented and how a meaningful error message
     * can be returned to the user.
     *
     * Until then comment out these validations.
     */

    /*
     -- Validate EFT company number
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'INT_BANK_ASSIGNED_ID2',
         l_document_rec.int_bank_assigned_id2,
         'NOTNULL',
         null,
         null,
         l_valResult,
         l_docErrorRec);

         IF (l_valResult = FALSE) THEN
            IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
            l_valid := 1;
         END IF;

     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'INT_BANK_ASSIGNED_ID2',
         l_document_rec.int_bank_assigned_id2,
         'MAXLENGTH',
         null,
         8,
         l_valResult,
         l_docErrorRec);

         IF (l_valResult = FALSE) THEN
            IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
            l_valid := 1;
         END IF;

     -- Validate EFT LZB area
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'INT_BANK_ASSIGNED_ID1',
         l_document_rec.int_bank_assigned_id1,
         'NOTNULL',
         null,
         null,
         l_valResult,
         l_docErrorRec);

         IF (l_valResult = FALSE) THEN
            IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
            l_valid := 1;
         END IF;

     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'INT_BANK_ASSIGNED_ID1',
         l_document_rec.int_bank_assigned_id1,
         'MAXLENGTH',
         null,
         2,
         l_valResult,
         l_docErrorRec);

         IF (l_valResult = FALSE) THEN
            IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
            l_valid := 1;
         END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;
    */
    /*-------------------------------------------------------------*/

     -- Return the Validation Result
     x_result := l_valid;

 END DE_EFT_INT_PAYER;

/*--------------------------------------------------------------------
 | NAME:
 |     P_DE_EFT_INT_PMT
 |
 | PURPOSE:
 |     German international EFT payment validation
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
 PROCEDURE P_DE_EFT_INT_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_payment_rec IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the payment record
     IBY_VALIDATIONSETS_PUB.initPaymentData(p_payment_id,l_payment_rec);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_payment_id;
     l_docErrorRec.transaction_type := 'PAYMENT';
     l_docErrorRec.calling_app_doc_unique_ref1 := p_payment_id;

     -- Validate payment amount
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PMT_AMOUNT',
         l_payment_rec.pmt_amount,
         'NOTEQUALTO',
         null,
         0,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate document country
     -- Not coded. The validation has been moved to the document level at payee validation.

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     -- The first parameter p_is_online_val takes hardcoded value 'N'.
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END P_DE_EFT_INT_PMT;

/*--------------------------------------------------------------------
 | NAME:
 |     DK_EFT_DOM_DOC
 |
 | PURPOSE:
 |     Danish domestic EFT document validation
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
 |    Bug 5569624: Added new document level validation set for Denmark
 |
 *---------------------------------------------------------------------*/
 PROCEDURE DK_EFT_DOM_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the payment record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate transaction code
     validate_uri_using_modulus10(
         l_document_rec.unique_remit_id_code,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END DK_EFT_DOM_DOC;

/*--------------------------------------------------------------------
 | NAME:
 |     CITI_DK_EFT_DOM_PAYEE
 |
 | PURPOSE:
 |     Citibank Danish domestic EFT payee validation
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
 PROCEDURE CITI_DK_EFT_DOM_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the payment record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate target bank account number
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_NUM',
         l_document_rec.ext_bank_num,
         'EXACTLENGTH',
         null,
         4,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_ACC_NUM',
         l_document_rec.ext_bank_acc_num,
         'MAXLENGTH',
         null,
         10,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END CITI_DK_EFT_DOM_PAYEE;

/*--------------------------------------------------------------------
 | NAME:
 |     CITI_DK_EFT_DOM_DOC
 |
 | PURPOSE:
 |     Citibank Danish domestic EFT document validation
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
 PROCEDURE CITI_DK_EFT_DOM_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the payment record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate transaction code
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'DELIVERY_CHANNEL_CODE',
         l_document_rec.delivery_channel_code,
         'INDELIV',
         'DK',
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END CITI_DK_EFT_DOM_DOC;

/*--------------------------------------------------------------------
 | NAME:
 |     P_CITI_DK_EFT_DOM_PMT
 |
 | PURPOSE:
 |     Citibank Danish domestic EFT payment validation
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
 PROCEDURE P_CITI_DK_EFT_DOM_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_payment_rec IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the payment record
     IBY_VALIDATIONSETS_PUB.initPaymentData(p_payment_id,l_payment_rec);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_payment_id;
     l_docErrorRec.transaction_type := 'PAYMENT';
     l_docErrorRec.calling_app_doc_unique_ref1 := p_payment_id;

     -- Validate transaction reference
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PMT_ID',
         l_payment_rec.pmt_id,
         'MAXLENGTH',
         null,
         8,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate transaction amount
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PMT_AMOUNT',
         l_payment_rec.pmt_amount,
         'MAXLENGTH',
         null,
         12,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate transaction currency
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PMT_CURRENCY',
         nvl(l_payment_rec.pmt_currency, 'DKK'),
         'STRIS',
         'DKK',
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERROR
     -- The first parameter p_is_online_val takes hardcoded value 'N'.
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END P_CITI_DK_EFT_DOM_PMT;

/*--------------------------------------------------------------------
 | NAME:
 |     CITI_ES_CHECK_DOM_PAYEE
 |
 | PURPOSE:
 |     Citibank Spanish domestic check payee validation
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
 PROCEDURE CITI_ES_CHECK_DOM_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate target name
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PAYEE_PARTY_NAME',
         l_document_rec.payee_party_name,
         'MAXLENGTH',
         null,
         35,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate target address line 1
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PAYEE_PARTY_SITE_ADDR1',
         l_document_rec.payee_party_addr1,
         'MAXLENGTH',
         null,
         35,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate target address line 2
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PAYEE_PARTY_SITE_CITY',
         l_document_rec.payee_party_city||l_document_rec.payee_party_postal,
         'MAXLENGTH',
         null,
         35,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END CITI_ES_CHECK_DOM_PAYEE;

/*--------------------------------------------------------------------
 | NAME:
 |     P_CITI_ES_CHECK_DOM_PMT
 |
 | PURPOSE:
 |     Citibank Spanish domestic check payment validation
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
 PROCEDURE P_CITI_ES_CHECK_DOM_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_payment_rec IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the payment record
     IBY_VALIDATIONSETS_PUB.initPaymentData(p_payment_id,l_payment_rec);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_payment_id;
     l_docErrorRec.transaction_type := 'PAYMENT';
     l_docErrorRec.calling_app_doc_unique_ref1 := p_payment_id;

     -- Validate transaction reference
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PMT_ID',
         l_payment_rec.pmt_id,
         'MAXLENGTH',
         null,
         12,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     -- The first parameter p_is_online_val takes hardcoded value 'N'.
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END P_CITI_ES_CHECK_DOM_PMT;

/*--------------------------------------------------------------------
 | NAME:
 |     CITI_ES_EFT_DOM_PAYEE
 |
 | PURPOSE:
 |     Citibank Spanish domestic EFT payee validation
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
 PROCEDURE CITI_ES_EFT_DOM_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate target name
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PAYEE_PARTY_NAME',
         l_document_rec.payee_party_name,
         'MAXLENGTH',
         null,
         35,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate target address line 1
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PAYEE_PARTY_SITE_ADDR1',
         l_document_rec.payee_party_addr1,
         'MAXLENGTH',
         null,
         35,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate target address line 2
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PAYEE_PARTY_SITE_CITY',
         l_document_rec.payee_party_city||l_document_rec.payee_party_postal,
         'MAXLENGTH',
         null,
         35,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate target bank code
     -- by CE

     -- Validate target bank account number
     -- by CE

     -- Validate target bank branch code
     -- by CE

     -- Validate target bank country code
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_BRANCH_COUNTRY',
         l_document_rec.ext_bank_branch_country,
         'STRIS',
         'ES',
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Insert errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END CITI_ES_EFT_DOM_PAYEE;

/*--------------------------------------------------------------------
 | NAME:
 |     CITI_ES_EFT_DOM_DOC
 |
 | PURPOSE:
 |     Citibank Spanish domestic EFT document validation
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
 PROCEDURE CITI_ES_EFT_DOM_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate transaction code
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'DELIVERY_CHANNEL_CODE',
         l_document_rec.delivery_channel_code,
         'INDELIV',
         'ES',
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END CITI_ES_EFT_DOM_DOC;

 /*--------------------------------------------------------------------
  | NAME:
  |     P_CITI_ES_EFT_DOM_PMT
  |
  | PURPOSE:
  |     Citibank Spanish domestic EFT payment validation
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
  PROCEDURE P_CITI_ES_EFT_DOM_PMT (
      p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
      p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
      p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
      p_is_online_val      IN VARCHAR2,
      x_result             OUT NOCOPY NUMBER)
  IS

  l_payment_rec IBY_VALIDATIONSETS_PUB.paymentRecType;
  l_valResult BOOLEAN;
  l_valid NUMBER := 0;
  l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
  l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

  BEGIN

      -- Initializing the payment record
      IBY_VALIDATIONSETS_PUB.initPaymentData(p_payment_id,l_payment_rec);

      l_docErrorRec.validation_set_code := p_validation_set_code;
      l_docErrorRec.transaction_id := p_payment_id;
      l_docErrorRec.transaction_type := 'PAYMENT';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_payment_id;

      -- Validate transaction reference
      IBY_VALIDATIONSETS_PUB.evaluateCondition(
          'PMT_ID',
          l_payment_rec.pmt_id,
          'MAXLENGTH',
          null,
          12,
          l_valResult,
          l_docErrorRec);

      IF (l_valResult = FALSE) THEN
         IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
         l_valid := 1;
      END IF;

      -- Inserting errors into IBY_TRANSACTION_ERRORS
      -- The first parameter p_is_online_val takes hardcoded value 'N'.
      IF (l_valid = 1) THEN
         IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);
      END IF;

      -- Return the Validation Result
      x_result := l_valid;

 END P_CITI_ES_EFT_DOM_PMT;

/*--------------------------------------------------------------------
 | NAME:
 |     CITI_FI_EFT_DOM_PAYEE
 |
 | PURPOSE:
 |     Citibank Finnish domestic EFT payee validation
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
 PROCEDURE CITI_FI_EFT_DOM_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate target name
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PAYEE_PARTY_NAME',
         l_document_rec.payee_party_name,
         'MAXLENGTH',
         null,
         30,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate target bank account number
     -- by CE

     -- Validate target bank country code
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_BRANCH_COUNTRY',
         l_document_rec.ext_bank_branch_country,
         'STRIS',
         'FI',
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Insert errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the validation result
     x_result := l_valid;

 END CITI_FI_EFT_DOM_PAYEE;

/*--------------------------------------------------------------------
 | NAME:
 |     CITI_FI_EFT_DOM_DOC
 |
 | PURPOSE:
 |     Citibank Finnish domestic EFT document validation
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
 PROCEDURE CITI_FI_EFT_DOM_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate transaction code
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'DELIVERY_CHANNEL_CODE',
         l_document_rec.delivery_channel_code,
         'INDELIV',
         'FI',
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Insert errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the validation result
     x_result := l_valid;

 END CITI_FI_EFT_DOM_DOC;

/*--------------------------------------------------------------------
 | NAME:
 |     P_CITI_FI_EFT_DOM_PMT
 |
 | PURPOSE:
 |     Citibank Finnish domestic EFT payment validation
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
 PROCEDURE P_CITI_FI_EFT_DOM_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_payment_id         IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_payment_rec IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the payment record
     IBY_VALIDATIONSETS_PUB.initPaymentData(p_payment_id,l_payment_rec);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_payment_id;
     l_docErrorRec.transaction_type := 'PAYMENT';
     l_docErrorRec.calling_app_doc_unique_ref1 := p_payment_id;

     -- Validate transaction amount
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PMT_AMOUNT',
         l_payment_rec.pmt_amount,
         'MAXLENGTH',
         null,
         12,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     -- The first parameter p_is_online_val takes hardcoded value 'N'.
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END P_CITI_FI_EFT_DOM_PMT;

/*--------------------------------------------------------------------
 | NAME:
 |     CITI_FR_EFT_DOM_PAYEE
 |
 | PURPOSE:
 |     Citibank French domestic EFT payee validation
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
 PROCEDURE CITI_FR_EFT_DOM_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id, l_document_rec, p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate target name
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PAYEE_PARTY_NAME',
         l_document_rec.payee_party_name,
         'MAXLENGTH',
         null,
         24,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate target bank code
     -- by CE

     -- Validate target bank branch code
     -- by CE

     -- Validate target bank account number
     -- by CE

     -- Validate target bank account check digits
     -- by CE

     -- Validate target bank country code
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_BRANCH_COUNTRY',
         l_document_rec.ext_bank_branch_country,
         'STRIS',
         'FR',
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END CITI_FR_EFT_DOM_PAYEE;

/*--------------------------------------------------------------------
 | NAME:
 |     CITI_FR_EFT_DOM_DOC
 |
 | PURPOSE:
 |     Citibank French domestic EFT document validation
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
 PROCEDURE CITI_FR_EFT_DOM_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate transaction code
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'DELIVERY_CHANNEL_CODE',
         l_document_rec.delivery_channel_code,
         'INDELIV',
         'FR',
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END CITI_FR_EFT_DOM_DOC;

/*--------------------------------------------------------------------
 | NAME:
 |     P_CITI_FR_EFT_DOM_PMT
 |
 | PURPOSE:
 |     Citibank French domestic EFT payment validation
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
 PROCEDURE P_CITI_FR_EFT_DOM_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_payment_rec IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 l_max_ach_amt NUMBER;

 BEGIN

     -- Initializing the payment record
     IBY_VALIDATIONSETS_PUB.initPaymentData(p_payment_id,l_payment_rec);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_payment_id;
     l_docErrorRec.transaction_type := 'PAYMENT';
     l_docErrorRec.calling_app_doc_unique_ref1 := p_payment_id;

     -- Validate transaction amount
     IBY_VALIDATIONSETS_PUB.getParamValue(
                            p_validation_assign_id,
                            p_validation_set_code,
                            'MAX_PAYMENT_AMOUNT',
                            l_max_ach_amt );

     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PMT_AMOUNT',
         l_payment_rec.pmt_amount,
         'LESSEQUAL',
         null,
         l_max_ach_amt,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     -- The first parameter p_is_online_val takes hardcoded value 'N'.
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END P_CITI_FR_EFT_DOM_PMT;

/*--------------------------------------------------------------------
 | NAME:
 |     CITI_GR_CHECK_DOMESTIC_PAYEE
 |
 | PURPOSE:
 |     Citibank Greek domestic check payee validation
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
 PROCEDURE CITI_GR_CHECK_DOM_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate target name
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PAYEE_PARTY_NAME',
         l_document_rec.payee_party_name,
         'MAXLENGTH',
         null,
         33,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate target bank name
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_NAME',
         l_document_rec.ext_bank_name,
         'MAXLENGTH',
         null,
         33,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate target bank code
     -- by CE

     -- Validate target bank branch code
     -- by CE

     -- Validate target bank account number
     -- by CE

     -- Insert errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the validation result
     x_result := l_valid;

 END CITI_GR_CHECK_DOM_PAYEE;

/*--------------------------------------------------------------------
 | NAME:
 |     CITI_GR_CHECK_DOM_DOC
 |
 | PURPOSE:
 |     Citibank Greek domestic check document validation
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
 PROCEDURE CITI_GR_CHECK_DOM_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate transaction code
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'DELIVERY_CHANNEL_CODE',
         l_document_rec.delivery_channel_code,
         'INDELIV',
         'GR',
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Insert errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the validation result
     x_result := l_valid;

 END CITI_GR_CHECK_DOM_DOC;

 /*--------------------------------------------------------------------
  | NAME:
  |     P_CITI_GR_CHECK_DOM_PMT
  |
  | PURPOSE:
  |    Citibank Greek domestic check payment validation
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
  PROCEDURE P_CITI_GR_CHECK_DOM_PMT (
      p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
      p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
      p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
      p_is_online_val      IN VARCHAR2,
      x_result             OUT NOCOPY NUMBER)
  IS

  l_payment_rec IBY_VALIDATIONSETS_PUB.paymentRecType;
  l_valResult BOOLEAN;
  l_valid NUMBER := 0;
  l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
  l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

  BEGIN

      -- Initializing the payment record
      IBY_VALIDATIONSETS_PUB.initPaymentData(p_payment_id,l_payment_rec);

      l_docErrorRec.validation_set_code := p_validation_set_code;
      l_docErrorRec.transaction_id := p_payment_id;
      l_docErrorRec.transaction_type := 'PAYMENT';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_payment_id;

      -- Validate transaction reference
      IBY_VALIDATIONSETS_PUB.evaluateCondition(
          'PMT_ID',
          l_payment_rec.pmt_id,
          'MAXLENGTH',
          null,
          16,
          l_valResult,
          l_docErrorRec);

      IF (l_valResult = FALSE) THEN
         IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
         l_valid := 1;
      END IF;

      -- Inserting errors into IBY_TRANSACTION_ERRORS
      -- The first parameter p_is_online_val takes hardcoded value 'N'.
      IF (l_valid = 1) THEN
         IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);
      END IF;

      -- Return the Validation Result
      x_result := l_valid;

  END P_CITI_GR_CHECK_DOM_PMT;

/*--------------------------------------------------------------------
 | NAME:
 |     CITI_GR_EFT_DOM_PAYEE
 |
 | PURPOSE:
 |     Citibank Greek domestic EFT payee validation
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
 PROCEDURE CITI_GR_EFT_DOM_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate target name
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PAYEE_PARTY_NAME',
         l_document_rec.payee_party_name,
         'MAXLENGTH',
         null,
         33,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate target bank code
     -- by CE

     -- Validate target bank branch code
     -- by CE

     -- Validate target bank account number
     -- by CE

     -- Insert errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the validation result
     x_result := l_valid;

 END CITI_GR_EFT_DOM_PAYEE;

/*--------------------------------------------------------------------
 | NAME:
 |     CITI_GR_EFT_DOM_DOC
 |
 | PURPOSE:
 |     Citibank Greek domestic EFT document validation
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
 PROCEDURE CITI_GR_EFT_DOM_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;
 l_validTrxnCodes VARCHAR2(100) := '0001, 0003, 0004';

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate transaction code
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'DELIVERY_CHANNEL_CODE',
         l_document_rec.delivery_channel_code,
         'INDELIV',
         'GR',
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Insert errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the validation result
     x_result := l_valid;

 END CITI_GR_EFT_DOM_DOC;

 /*--------------------------------------------------------------------
  | NAME:
  |     P_CITI_GR_EFT_DOM_PMT
  |
  | PURPOSE:
  |    Citibank Greek domestic EFT payment validation
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
  PROCEDURE P_CITI_GR_EFT_DOM_PMT (
      p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
      p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
      p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
      p_is_online_val      IN VARCHAR2,
      x_result             OUT NOCOPY NUMBER)
  IS

  l_payment_rec IBY_VALIDATIONSETS_PUB.paymentRecType;
  l_valResult BOOLEAN;
  l_valid NUMBER := 0;
  l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
  l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

  BEGIN

      -- Initializing the payment record
      IBY_VALIDATIONSETS_PUB.initPaymentData(p_payment_id,l_payment_rec);

      l_docErrorRec.validation_set_code := p_validation_set_code;
      l_docErrorRec.transaction_id := p_payment_id;
      l_docErrorRec.transaction_type := 'PAYMENT';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_payment_id;

      -- Validate transaction reference
      IBY_VALIDATIONSETS_PUB.evaluateCondition(
          'PMT_ID',
          l_payment_rec.pmt_id,
          'MAXLENGTH',
          null,
          16,
          l_valResult,
          l_docErrorRec);

      IF (l_valResult = FALSE) THEN
         IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
         l_valid := 1;
      END IF;

      -- Inserting errors into IBY_TRANSACTION_ERRORS
      -- The first parameter p_is_online_val takes hardcoded value 'N'.
      IF (l_valid = 1) THEN
         IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);
      END IF;

      -- Return the Validation Result
      x_result := l_valid;

  END P_CITI_GR_EFT_DOM_PMT;

/*--------------------------------------------------------------------
 | NAME:
 |     CITI_IE_EFT_DOM_PAYEE
 |
 | PURPOSE:
 |     Citibank Irish domestic EFT payee validation
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
 PROCEDURE CITI_IE_EFT_DOM_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate beneficiary name
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PAYEE_PARTY_NAME',
         l_document_rec.payee_party_name,
         'MAXLENGTH',
         null,
         18,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate target name
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PAYEE_PARTY_NAME',
         l_document_rec.payee_party_name,
         'MAXLENGTH',
         null,
         18,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate target bank account number
     -- by CE

     -- Validate target bank country code
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_BRANCH_COUNTRY',
         l_document_rec.ext_bank_branch_country,
         'STRIS',
         'IE',
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate target bank branch code
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_BRANCH_NUM',
         l_document_rec.ext_bank_branch_num,
         'EXACTLENGTH',
         null,
         6,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- by CE, validation on digits only.

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END CITI_IE_EFT_DOM_PAYEE;

/*--------------------------------------------------------------------
 | NAME:
 |     P_CITI_IE_EFT_DOM_PMT
 |
 | PURPOSE:
 |     Citibank Irish domestic EFT payment validation
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
 PROCEDURE P_CITI_IE_EFT_DOM_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_payment_rec IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the payment record
     IBY_VALIDATIONSETS_PUB.initPaymentData(p_payment_id,l_payment_rec);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_payment_id;
     l_docErrorRec.transaction_type := 'PAYMENT';
     l_docErrorRec.calling_app_doc_unique_ref1 := p_payment_id;

     -- Validate transactional reference
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PMT_ID',
         l_payment_rec.pmt_id,
         'MAXLENGTH',
         null,
         15,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate instruction currency code
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PMT_CURRENCY',
         l_payment_rec.pmt_currency,
         'MAXLENGTH',
         null,
         3,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate transaction amount
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PMT_AMOUNT',
         l_payment_rec.pmt_amount,
         'MAXLENGTH',
         null,
         12,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     -- The first parameter p_is_online_val takes hardcoded value 'N'.
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END P_CITI_IE_EFT_DOM_PMT;

 /*--------------------------------------------------------------------
 | NAME:
 |     CITI_IE_EFT_DOM_DOC
 |
 | PURPOSE:
 |     Citibank Irish domestic EFT document validation
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
 PROCEDURE CITI_IE_EFT_DOM_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate transaction code
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'DELIVERY_CHANNEL_CODE',
         l_document_rec.delivery_channel_code,
         'INDELIV',
         'IE',
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END CITI_IE_EFT_DOM_DOC;

/*--------------------------------------------------------------------
 | NAME:
 |     CITI_IT_EFT_DOM_PAYEE
 |
 | PURPOSE:
 |     Citibank Italian domestic EFT payee validation
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
 PROCEDURE CITI_IT_EFT_DOM_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate target name
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PAYEE_PARTY_NAME',
         l_document_rec.payee_party_name,
         'MAXLENGTH',
         null,
         30,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate target postal code
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PAYEE_PARTY_SITE_POSTAL',
         l_document_rec.payee_party_postal,
         'MAXLENGTH',
         null,
         5,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate target bank code
     -- by CE

     -- Validate target branch code
     -- by CE

     -- Validate target bank account number
     -- by CE

     -- Validate target bank account check digit
     -- by CE

     -- Validate target bank name
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_NAME',
         l_document_rec.ext_bank_name,
         'MAXLENGTH',
         null,
         30,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate target bank country code
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_BRANCH_COUNTRY',
         l_document_rec.ext_bank_branch_country,
         'STRIS',
         'IT',
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Insert errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the validation result
     x_result := l_valid;

 END CITI_IT_EFT_DOM_PAYEE;

/*--------------------------------------------------------------------
 | NAME:
 |     P_CITI_IT_EFT_DOM_PMT
 |
 | PURPOSE:
 |     Citibank Italian domestic EFT payment validation
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
 PROCEDURE P_CITI_IT_EFT_DOM_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_payment_rec IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the payment record
     IBY_VALIDATIONSETS_PUB.initPaymentData(p_payment_id,l_payment_rec);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_payment_id;
     l_docErrorRec.transaction_type := 'PAYMENT';
     l_docErrorRec.calling_app_doc_unique_ref1 := p_payment_id;

     -- Validate transaction reference
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PMT_ID',
         l_payment_rec.pmt_id,
         'MAXLENGTH',
         null,
         16,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate transaction amount
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PMT_AMOUNT',
         l_payment_rec.pmt_amount,
         'MAXLENGTH',
         null,
         13,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Insert errors into IBY_TRANSACTION_ERRORS
     -- The first parameter p_is_online_val takes hardcoded value 'N'.
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);
     END IF;

     -- Return the validation result
     x_result := l_valid;

 END P_CITI_IT_EFT_DOM_PMT;

/*--------------------------------------------------------------------
 | NAME:
 |     JP_EFT_ZENGIN_INTERNAL_BANK
 |
 | PURPOSE:
 |     Japanese Zengin EFT internal bank validation
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
 PROCEDURE JP_EFT_ZENGIN_INTERNAL_BANK (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id, l_document_rec, p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate internal bank code
     -- by CE

     -- Validate internal branch code
     -- by CE

     -- Validate internal bank kana name
     -- by CE

     -- Validate internal bank branch kana name
     -- by CE

     -- Validate internal bank account number
     -- by CE

     -- Validate internal bank account type
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'INT_BANK_ACC_TYPE',
         '+'||substr(l_document_rec.int_bank_acc_type, 1, 1)||'+',
         'INSET',
         '+1+2+4+9+',
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate internal bank account holder name alternate
     -- by CE

     -- Validate EFT requester id
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'INT_EFT_USER_NUMBER',
         l_document_rec.int_eft_user_number,
         'DIGITSONLY',
         null,
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Insert errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the validation result
     x_result := l_valid;

 END JP_EFT_ZENGIN_INTERNAL_BANK;

/*--------------------------------------------------------------------
 | NAME:
 |     JP_EFT_ZENGIN_PAYEE
 |
 | PURPOSE:
 |     Japanese Zengin EFT payee validation
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
 PROCEDURE JP_EFT_ZENGIN_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id, l_document_rec, p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate supplier bank account id
     -- not coded.

     -- Validate supplier bank code
     -- by CE

     -- Validate supplier bank branch code
     -- by CE

     -- Validate supplier bank kana name
     -- by CE

     -- Validate supplier bank branch kana name
     -- by CE

     -- Validate supplier bank account type
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_ACC_TYPE',
         '+'||substr(l_document_rec.ext_bank_acc_type, 1, 1)||'+',
         'INSET',
         '+1+2+4+9+',
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate supplier bank account number
     -- by CE

     -- Validate supplier bank account name alternate
     -- by CE

     -- Insert errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the validation result
     x_result := l_valid;

 END JP_EFT_ZENGIN_PAYEE;

 /*--------------------------------------------------------------------
  | NAME:
  |     NO_EFT_DOM_DOC
  |
  | PURPOSE:
  |     Norwegian domestic EFT document validation
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
  |     Bug 5571714: Unique Remittance Identifier (KID code) validation
  |                  for Norway.
  |
  *---------------------------------------------------------------------*/
  PROCEDURE NO_EFT_DOM_DOC (
      p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
      p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
      p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
      p_is_online_val      IN VARCHAR2,
      x_result             OUT NOCOPY NUMBER)
  IS

  l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
  l_valResult BOOLEAN;
  l_valid NUMBER := 0;
  l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
  l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

  BEGIN

      -- Initializing the document record
      IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

      l_docErrorRec.validation_set_code := p_validation_set_code;
      l_docErrorRec.transaction_id := p_document_id;
      l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
      l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
      l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
      l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

      -- Validate unique remittance identifier (KID Code)
      -- Bug 5571714: This function returns validity of the KID code. This
      -- code is picked up from /jedev/xxno/11.5/admin/sql/XXNOEC04.sql

      xxno_chk_mod_10_11( l_document_rec.unique_remit_id_code
                        , l_valResult
                        , l_docErrorRec);

      IF (l_valResult = FALSE) THEN
         IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec,l_docErrorTab);
         l_valid := 1;
      END IF;

      -- Inserting errors into IBY_TRANSACTION_ERRORS
      IF (l_valid = 1) THEN
         IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
      END IF;

      -- Return the Validation Result
      x_result := l_valid;

  END NO_EFT_DOM_DOC;

/*--------------------------------------------------------------------
 | NAME:
 |     CITI_NO_EFT_DOM_PAYEE
 |
 | PURPOSE:
 |     Citibank Norwegian domestic EFT payee validation
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
 PROCEDURE CITI_NO_EFT_DOM_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate target name
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PAYEE_PARTY_NAME',
         l_document_rec.payee_party_name,
         'MAXLENGTH',
         null,
         35,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate address line 3
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PAYEE_PARTY_SITE_POSTAL',
         l_document_rec.payee_party_postal,
         'NOTNULL',
         null,
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END CITI_NO_EFT_DOM_PAYEE;

 /*--------------------------------------------------------------------
  | NAME:
  |     CITI_NO_EFT_DOM_DOC
  |
  | PURPOSE:
  |     Citibank Norwegian domestic EFT document validation
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
  PROCEDURE CITI_NO_EFT_DOM_DOC (
      p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
      p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
      p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
      p_is_online_val      IN VARCHAR2,
      x_result             OUT NOCOPY NUMBER)
  IS

  l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
  l_valResult BOOLEAN;
  l_valid NUMBER := 0;
  l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
  l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

  BEGIN

      -- Initializing the document record
      IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

      l_docErrorRec.validation_set_code := p_validation_set_code;
      l_docErrorRec.transaction_id := p_document_id;
      l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
      l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
      l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
      l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

      -- Validate transaction code
      IBY_VALIDATIONSETS_PUB.evaluateCondition(
          'DELIVERY_CHANNEL_CODE',
          l_document_rec.delivery_channel_code,
          'INDELIV',
          'NO',
          null,
          l_valResult,
          l_docErrorRec);

      IF (l_valResult = FALSE) THEN
         IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec,l_docErrorTab);
         l_valid := 1;
      END IF;

/*
      -- Validate unique remittance identifier (KID Code)
      -- Bug 5571714: This function returns validity of the KID code. This
      -- code is picked up from /jedev/xxno/11.5/admin/sql/XXNOEC04.sql

      xxno_chk_mod_10_11( l_document_rec.unique_remit_id_code
                        , l_valResult
                        , l_docErrorRec);

      IF (l_valResult = FALSE) THEN
         IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec,l_docErrorTab);
         l_valid := 1;
      END IF;
*/

      -- Inserting errors into IBY_TRANSACTION_ERRORS
      IF (l_valid = 1) THEN
         IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
      END IF;

      -- Return the Validation Result
      x_result := l_valid;

  END CITI_NO_EFT_DOM_DOC;

/*--------------------------------------------------------------------
 | NAME:
 |     P_CITI_NO_EFT_DOM_PMT
 |
 | PURPOSE:
 |     Citibank Norwegian domestic EFT payment validation
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
 PROCEDURE P_CITI_NO_EFT_DOM_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_payment_rec IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the payment record
     IBY_VALIDATIONSETS_PUB.initPaymentData(p_payment_id,l_payment_rec);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_payment_id;
     l_docErrorRec.transaction_type := 'PAYMENT';
     l_docErrorRec.calling_app_doc_unique_ref1 := p_payment_id;

     -- Validate transaction reference
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PMT_ID',
         l_payment_rec.pmt_id,
         'MAXLENGTH',
         null,
         16,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     -- The first parameter p_is_online_val takes hardcoded value 'N'.
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END P_CITI_NO_EFT_DOM_PMT;

/*--------------------------------------------------------------------
 | NAME:
 |     CITI_PL_EFT_MTMS_INTERNAL_BANK
 |
 | PURPOSE:
 |     Citibank Polish MTMS EFT internal bank validation
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
 PROCEDURE CITI_PL_EFT_MTMS_INTERNAL_BANK (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record with the Document Payables information
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate payer bank account number
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'INT_BANK_ACC_IBAN',
         l_document_rec.int_bank_acc_iban,
         'NOTNULL',
         null,
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.evaluateCondition(
            'INT_BANK_ACC_NUM',
            l_document_rec.int_bank_acc_num,
            'EXACTLENGTH',
            null,
            10,
            l_valResult,
            l_docErrorRec);

        IF (l_valResult = FALSE) THEN
           IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
           l_valid := 1;
        END IF;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END CITI_PL_EFT_MTMS_INTERNAL_BANK;

/*--------------------------------------------------------------------
 | NAME:
 |     CITI_POLAND_EFT_MTMS_PAYEE
 |
 | PURPOSE:
 |     Citibank Polish MTMS EFT payee validation
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
 PROCEDURE CITI_PL_EFT_MTMS_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate supplier bank number
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_ACC_IBAN',
         l_document_rec.ext_bank_acc_iban,
         'NOTNULL',
         null,
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.evaluateCondition(
            'EXT_BANK_NUM',
            l_document_rec.ext_bank_num,
            'NOTNULL',
            null,
            null,
            l_valResult,
            l_docErrorRec);

        IF (l_valResult = FALSE) THEN
           IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
           l_valid := 1;
        END IF;
     END IF;

     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_ACC_IBAN',
         l_document_rec.ext_bank_acc_iban,
         'MAXLENGTH',
         null,
         8,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.evaluateCondition(
            'EXT_BANK_NUM',
            l_document_rec.ext_bank_num,
            'MAXLENGTH',
            null,
            8,
            l_valResult,
            l_docErrorRec);

        IF (l_valResult = FALSE) THEN
           IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
           l_valid := 1;
        END IF;
     END IF;

     -- Validate supplier name
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PAYEE_PARTY_NAME',
         l_document_rec.payee_party_name,
         'MAXLENGTH',
         null,
         35,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate supplier site address
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PAYEE_PARTY_SITE_ADDR1',
         l_document_rec.payee_party_addr1 || l_document_rec.payee_party_city ||
         		l_document_rec.payee_party_postal,
         'MAXLENGTH',
         null,
         35,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END CITI_PL_EFT_MTMS_PAYEE;

/*--------------------------------------------------------------------
 | NAME:
 |     P_CITI_PL_EFT_MTMS_PMT
 |
 | PURPOSE:
 |     Citibank Polish MTMS EFT payment validation
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
 PROCEDURE P_CITI_PL_EFT_MTMS_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_payment_rec IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 l_max_payment_amt number;

 BEGIN

     -- Initializing the payment record
     IBY_VALIDATIONSETS_PUB.initPaymentData(p_payment_id,l_payment_rec);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_payment_id;
     l_docErrorRec.transaction_type := 'PAYMENT';
     l_docErrorRec.calling_app_doc_unique_ref1 := p_payment_id;

     -- Validate payment amount
     IBY_VALIDATIONSETS_PUB.getParamValue(
                            p_validation_assign_id,
                            p_validation_set_code,
                            'MAX_PAYMENT_AMOUNT',
                            l_max_payment_amt );

     -- Validate transaction amount
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PMT_AMOUNT',
         l_payment_rec.pmt_amount,
         'LESSEQUAL',
         null,
         l_max_payment_amt,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate concatenated list of invoice numbers
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PMT_DETAIL',
         l_payment_rec.pmt_detail,
         'MAXLENGTH',
         null,
         140,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     -- The first parameter p_is_online_val takes hardcoded value 'N'.
     IF (l_valid = 1) THEN
         IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END P_CITI_PL_EFT_MTMS_PMT;

/*--------------------------------------------------------------------
 | NAME:
 |     PEKAO_PL_WIRE_TR_INTERNAL_BANK
 |
 | PURPOSE:
 |     Pekao Polish transfer wire internal bank validation
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
 PROCEDURE PEKAO_PL_WIRE_TR_INTERNAL_BANK (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record with the Document Payables information
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate payer bank account number
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'INT_BANK_ACC_IBAN',
         l_document_rec.int_bank_acc_iban,
         'NOTNULL',
         null,
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.evaluateCondition(
            'INT_BANK_ACC_NUM',
            l_document_rec.int_bank_acc_num,
            'MAXLENGTH',
            null,
            34,
            l_valResult,
            l_docErrorRec);

        IF (l_valResult = FALSE) THEN
           IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
           l_valid := 1;
        END IF;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END PEKAO_PL_WIRE_TR_INTERNAL_BANK;

/*--------------------------------------------------------------------
 | NAME:
 |     PEKAO_PL_WIRE_TR_PAYEE
 |
 | PURPOSE:
 |     PeKao Polish transfer wire payee validation
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
 PROCEDURE PEKAO_PL_WIRE_TR_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate supplier bank number
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_ACC_IBAN',
         l_document_rec.ext_bank_acc_iban,
         'NOTNULL',
         null,
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.evaluateCondition(
            'EXT_BANK_NUM',
            l_document_rec.ext_bank_num,
            'NOTNULL',
            null,
            null,
            l_valResult,
            l_docErrorRec);

        IF (l_valResult = FALSE) THEN
           IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
           l_valid := 1;
        END IF;
     END IF;

     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_ACC_IBAN',
         l_document_rec.ext_bank_acc_iban,
         'MAXLENGTH',
         null,
         35,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.evaluateCondition(
            'EXT_BANK_NUM',
            l_document_rec.ext_bank_num,
            'MAXLENGTH',
            null,
            35,
            l_valResult,
            l_docErrorRec);

        IF (l_valResult = FALSE) THEN
           IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
           l_valid := 1;
        END IF;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END PEKAO_PL_WIRE_TR_PAYEE;

/*--------------------------------------------------------------------
 | NAME:
 |     PEKAO_PL_WIRE_TR_DOC
 |
 | PURPOSE:
 |     Pekao Polish transfer wire document validation
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
 PROCEDURE PEKAO_PL_WIRE_TR_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record with the Document Payables information
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate invoice reference ...

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END PEKAO_PL_WIRE_TR_DOC;

/*--------------------------------------------------------------------
 | NAME:
 |     P_PEKAO_PL_WIRE_TR_PMT
 |
 | PURPOSE:
 |     PeKao Polish transfer wire payment validation
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
 PROCEDURE P_PEKAO_PL_WIRE_TR_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_payment_rec IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 l_max_payment_amt number;

 BEGIN

     -- Initializing the payment record
     IBY_VALIDATIONSETS_PUB.initPaymentData(p_payment_id,l_payment_rec);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_payment_id;
     l_docErrorRec.transaction_type := 'PAYMENT';
     l_docErrorRec.calling_app_doc_unique_ref1 := p_payment_id;

     -- Validate payment amount
     IBY_VALIDATIONSETS_PUB.getParamValue(
                            p_validation_assign_id,
                            p_validation_set_code,
                            'MAX_PAYMENT_AMOUNT',
                            l_max_payment_amt );

     -- Validate transaction amount
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PMT_AMOUNT',
         l_payment_rec.pmt_amount,
         'LESSEQUAL',
         null,
         l_max_payment_amt,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate concatenated list of invoice numbers
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PMT_DETAIL',
         l_payment_rec.pmt_detail,
         'MAXLENGTH',
         null,
         140,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     -- The first parameter p_is_online_val takes hardcoded value 'N'.
     IF (l_valid = 1) THEN
         IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END P_PEKAO_PL_WIRE_TR_PMT;

/*--------------------------------------------------------------------
 | NAME:
 |     PEKAO_PL_WIRE_ST_INTERNAL_BANK
 |
 | PURPOSE:
 |     Pekao Polish standard wire internal bank validation
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
 PROCEDURE PEKAO_PL_WIRE_ST_INTERNAL_BANK (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record with the Document Payables information
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate payer bank account number
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'INT_BANK_ACC_IBAN',
         l_document_rec.int_bank_acc_iban,
         'NOTNULL',
         null,
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.evaluateCondition(
            'INT_BANK_ACC_NUM',
            l_document_rec.int_bank_acc_num,
            'MAXLENGTH',
            null,
            34,
            l_valResult,
            l_docErrorRec);

        IF (l_valResult = FALSE) THEN
           IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
           l_valid := 1;
        END IF;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END PEKAO_PL_WIRE_ST_INTERNAL_BANK;

/*--------------------------------------------------------------------
 | NAME:
 |     PEKAO_PL_WIRE_ST_PAYEE
 |
 | PURPOSE:
 |     PeKao Polish standard wire payee validation
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
 PROCEDURE PEKAO_PL_WIRE_ST_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate supplier bank number
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_ACC_IBAN',
         l_document_rec.ext_bank_acc_iban,
         'NOTNULL',
         null,
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.evaluateCondition(
            'EXT_BANK_NUM',
            l_document_rec.ext_bank_num,
            'NOTNULL',
            null,
            null,
            l_valResult,
            l_docErrorRec);

        IF (l_valResult = FALSE) THEN
           IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
           l_valid := 1;
        END IF;
     END IF;

     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_ACC_IBAN',
         l_document_rec.ext_bank_acc_iban,
         'MAXLENGTH',
         null,
         35,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.evaluateCondition(
            'EXT_BANK_NUM',
            l_document_rec.ext_bank_num,
            'MAXLENGTH',
            null,
            35,
            l_valResult,
            l_docErrorRec);

        IF (l_valResult = FALSE) THEN
           IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
           l_valid := 1;
        END IF;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END PEKAO_PL_WIRE_ST_PAYEE;

/*--------------------------------------------------------------------
 | NAME:
 |     PEKAO_PL_WIRE_ST_DOC
 |
 | PURPOSE:
 |     Pekao Polish standard wire document validation
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
 PROCEDURE PEKAO_PL_WIRE_ST_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record with the Document Payables information
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate invoice document sequence numbers

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END PEKAO_PL_WIRE_ST_DOC;

/*--------------------------------------------------------------------
 | NAME:
 |     CITI_PT_EFT_DOM_PAYEE
 |
 | PURPOSE:
 |     Citibank Portuguese domestic EFT payee validation
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
 PROCEDURE CITI_PT_EFT_DOM_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate target name
     if l_document_rec.delivery_channel_code = '0050' then
        IBY_VALIDATIONSETS_PUB.evaluateCondition(
            'PAYEE_PARTY_NAME',
            l_document_rec.payee_party_name,
            'MAXLENGTH',
            null,
            35,
            l_valResult,
            l_docErrorRec);

        IF (l_valResult = FALSE) THEN
           IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
           l_valid := 1;
        END IF;
     else
        IBY_VALIDATIONSETS_PUB.evaluateCondition(
            'PAYEE_PARTY_NAME',
            l_document_rec.payee_party_name,
            'MAXLENGTH',
            null,
            27,
            l_valResult,
            l_docErrorRec);

        IF (l_valResult = FALSE) THEN
           IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
           l_valid := 1;
        END IF;
     end if;

     -- Validate target bank country code
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_BRANCH_COUNTRY',
         l_document_rec.ext_bank_branch_country,
         'STRIS',
         'PT',
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END CITI_PT_EFT_DOM_PAYEE;

 /*--------------------------------------------------------------------
  | NAME:
  |     CITI_PT_EFT_DOM_DOC
  |
  | PURPOSE:
  |     Citibank Portuguese domestic EFT document validation
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
  PROCEDURE CITI_PT_EFT_DOM_DOC (
      p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
      p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
      p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
      p_is_online_val      IN VARCHAR2,
      x_result             OUT NOCOPY NUMBER)
  IS

  l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
  l_valResult BOOLEAN;
  l_valid NUMBER := 0;
  l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
  l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

  BEGIN

      -- Initializing the document record
      IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

      l_docErrorRec.validation_set_code := p_validation_set_code;
      l_docErrorRec.transaction_id := p_document_id;
      l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
      l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
      l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
      l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

      -- Validate transaction code
      IBY_VALIDATIONSETS_PUB.evaluateCondition(
          'DELIVERY_CHANNEL_CODE',
          l_document_rec.delivery_channel_CODE,
          'INDELIV',
          'PT',
          null,
          l_valResult,
          l_docErrorRec);

      IF (l_valResult = FALSE) THEN
         IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
         l_valid := 1;
      END IF;

      -- Inserting errors into IBY_TRANSACTION_ERRORS
      IF (l_valid = 1) THEN
         IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
      END IF;

      -- Return the Validation Result
      x_result := l_valid;

  END CITI_PT_EFT_DOM_DOC;

/*--------------------------------------------------------------------
 | NAME:
 |     P_CITI_PT_EFT_DOM_PMT
 |
 | PURPOSE:
 |     Citibank Portuguese domestic EFT payment validation
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
 PROCEDURE P_CITI_PT_EFT_DOM_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_payment_rec IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the payment record
     IBY_VALIDATIONSETS_PUB.initPaymentData(p_payment_id,l_payment_rec);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_payment_id;
     l_docErrorRec.transaction_type := 'PAYMENT';
     l_docErrorRec.calling_app_doc_unique_ref1 := p_payment_id;

     -- Validate transaction amount
     if l_payment_rec.pmt_delivery_channel_code = '0050' then
        IBY_VALIDATIONSETS_PUB.evaluateCondition(
            'PMT_AMOUNT',
            l_payment_rec.pmt_amount,
            'MAXLENGTH',
            null,
            15,
            l_valResult,
            l_docErrorRec);

        IF (l_valResult = FALSE) THEN
           IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
           l_valid := 1;
        END IF;
      else
        IBY_VALIDATIONSETS_PUB.evaluateCondition(
            'PMT_AMOUNT',
            l_payment_rec.pmt_amount,
            'MAXLENGTH',
            null,
            11,
            l_valResult,
            l_docErrorRec);

        IF (l_valResult = FALSE) THEN
           IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
	   l_valid := 1;
        END IF;
       end if;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     -- The first parameter p_is_online_val takes hardcoded value 'N'.
     IF (l_valid = 1) THEN
         IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END P_CITI_PT_EFT_DOM_PMT;

/*--------------------------------------------------------------------
 | NAME:
 |     PT_CHECK_GEN
 |
 | PURPOSE:
 |     Portuguese check generic validation
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
 PROCEDURE PT_CHECK_GEN (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate first party office site
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PAYER_LE_NAME',
         l_document_rec.payer_le_name,
         'NOTNULL',
         null,
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Insert errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END PT_CHECK_GEN;

/*--------------------------------------------------------------------
 | NAME:
 |     CITI_SE_EFT_DOM_PAYEE
 |
 | PURPOSE:
 |     Citibank Swedish domestic EFT payee
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
 PROCEDURE CITI_SE_EFT_DOM_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate target name
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PAYEE_PARTY_NAME',
         l_document_rec.payee_party_name,
         'MAXLENGTH',
         null,
         35,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
           IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
           l_valid := 1;
     END IF;

     -- Validate target address line 1
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PAYEE_PARTY_SITE_ADDR1',
         l_document_rec.payee_party_addr1,
         'MAXLENGTH',
         null,
         35,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate target address line 2
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PAYEE_PARTY_SITE_POSTAL',
         l_document_rec.payee_party_postal,
         'MAXLENGTH',
         null,
         5,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PAYEE_PARTY_SITE_POSTAL',
         l_document_rec.payee_party_postal,
         'DIGITSONLY',
         null,
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PAYEE_PARTY_SITE_CITY',
         l_document_rec.payee_party_city,
         'NOTNULL',
         null,
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate target bank account number
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_ACC_NUM',
         l_document_rec.ext_bank_acc_num,
         'MAXLENGTH',
         null,
         12,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END CITI_SE_EFT_DOM_PAYEE;

 /*--------------------------------------------------------------------
  | NAME:
  |     CITI_SE_EFT_DOM_DOC
  |
  | PURPOSE:
  |     Citibank Swedish domestic EFT document validation
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
  PROCEDURE CITI_SE_EFT_DOM_DOC (
      p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
      p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
      p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
      p_is_online_val      IN VARCHAR2,
      x_result             OUT NOCOPY NUMBER)
  IS

  l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
  l_valResult BOOLEAN;
  l_valid NUMBER := 0;
  l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
  l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

  BEGIN

      -- Initializing the document record
      IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

      l_docErrorRec.validation_set_code := p_validation_set_code;
      l_docErrorRec.transaction_id := p_document_id;
      l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
      l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
      l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
      l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

      -- Validate transaction code
      IBY_VALIDATIONSETS_PUB.evaluateCondition(
          'DELIVERY_CHANNEL_CODE',
          l_document_rec.delivery_channel_CODE,
          'INDELIV',
          'SE',
          null,
          l_valResult,
          l_docErrorRec);

      IF (l_valResult = FALSE) THEN
         IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
         l_valid := 1;
      END IF;

      -- Inserting errors into IBY_TRANSACTION_ERRORS
      IF (l_valid = 1) THEN
         IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
      END IF;

      -- Return the Validation Result
      x_result := l_valid;

  END CITI_SE_EFT_DOM_DOC;

/*--------------------------------------------------------------------
 | NAME:
 |     P_CITI_SE_EFT_DOM_PMT
 |
 | PURPOSE:
 |     Citibank Swedish domestic EFT payment validation
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
 PROCEDURE P_CITI_SE_EFT_DOM_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_payment_rec IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the payment record
     IBY_VALIDATIONSETS_PUB.initPaymentData(p_payment_id,l_payment_rec);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_payment_id;
     l_docErrorRec.transaction_type := 'PAYMENT';
     l_docErrorRec.calling_app_doc_unique_ref1 := p_payment_id;

     -- Validate payment currency
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PMT_CURRENCY',
         l_payment_rec.pmt_currency,
         'STRIS',
         'SEK',
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate transaction reference
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PMT_ID',
         l_payment_rec.pmt_id,
         'MAXLENGTH',
         null,
         16,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     -- The first parameter p_is_online_val takes hardcoded value 'N'.
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END P_CITI_SE_EFT_DOM_PMT;

/*--------------------------------------------------------------------
 | NAME:
 |     SE_EFT_BANKGIRO_INLAND_DOC
 |
 | PURPOSE:
 |     Swedish Bankgiro Inland EFT document validation
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
 PROCEDURE SE_EFT_BANKGIRO_INLAND_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate payment currency
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'DOCUMENT_PAY_CURRENCY',
         l_document_rec.document_pay_currency,
         'STRIS',
         'SEK',
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.evaluateCondition(
	    'DOCUMENT_PAY_CURRENCY',
	    l_document_rec.document_pay_currency,
	    'STRIS',
	    'EUR',
	    null,
	    l_valResult,
        l_docErrorRec);
     END IF;

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate payment type
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'DELIVERY_CHANNEL_CODE',
         l_document_rec.delivery_channel_code,
         'STRISNOT',
         'CHECK',
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Insert errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END SE_EFT_BANKGIRO_INLAND_DOC;

/*--------------------------------------------------------------------
 | NAME:
 |     SE_EFT_BANKGIRO_UTLAND_DOC
 |
 | PURPOSE:
 |     Swedish Bankgiro Utland SISU EFT document validation
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
 PROCEDURE SE_EFT_BANKGIRO_UTLAND_SI_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate payment type
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'DELIVERY_CHANNEL_CODE',
         '+'||l_document_rec.delivery_channel_code||'+',
         'NOTINSET',
         '+KONTOAVI+AVI+GIRO+',
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Insert errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END SE_EFT_BANKGIRO_UTLAND_SI_DOC;

/*--------------------------------------------------------------------
 | NAME:
 |     SE_EFT_BANKGIRO_UTLAND_UT_DOC
 |
 | PURPOSE:
 |     Swedish Bankgiro Utland UTLI EFT document validation
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
 PROCEDURE SE_EFT_BANKGIRO_UTLAND_UT_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate payment type
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'DELIVERY_CHANNEL_CODE',
         '+'||l_document_rec.delivery_channel_code||'+',
         'NOTINSET',
         '+KONTOAVI+AVI+GIRO+',
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Insert errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END SE_EFT_BANKGIRO_UTLAND_UT_DOC;

/*--------------------------------------------------------------------
 | NAME:
 |     SE_EFT_POSTGIRO_INLAND_DOC
 |
 | PURPOSE:
 |     Swedish Postgiro Inland EFT document validation
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
 PROCEDURE SE_EFT_POSTGIRO_INLAND_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record with the Document Payables information
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate payment type
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'DELIVERY_CHANNEL_CODE',
         '+'||l_document_rec.delivery_channel_code||'+',
         'NOTINSET',
         '+KONTOAVI+CHECK+',
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Insert errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END SE_EFT_POSTGIRO_INLAND_DOC;

/*--------------------------------------------------------------------
 | NAME:
 |     SE_EFT_POSTGIRO_UTLAND_DOC
 |
 | PURPOSE:
 |     Swedish Postgiro Utland EFT document validation
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
 PROCEDURE SE_EFT_POSTGIRO_UTLAND_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record with the Document Payables information
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate payment type
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'DELIVERY_CHANNEL_CODE',
         l_document_rec.delivery_channel_code,
         'STRISNOT',
         'KONTOAVI',
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Insert errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END SE_EFT_POSTGIRO_UTLAND_DOC;

/*--------------------------------------------------------------------
 | NAME:
 |     CITI_GB_EFT_DOM_PAYEE
 |
 | PURPOSE:
 |     Citibank UK domestic EFT payee validation
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
 PROCEDURE CITI_GB_EFT_DOM_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate target name
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PAYEE_PARTY_NAME',
         l_document_rec.payee_party_name,
         'MAXLENGTH',
         null,
         18,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate target bank account number
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_ACC_NUM',
         l_document_rec.ext_bank_acc_num,
         'MAXLENGTH',
         null,
         10,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_ACC_NUM',
         l_document_rec.ext_bank_acc_num,
         'MINLENGTH',
         null,
         8,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate target bank branch code
     -- by CE

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END CITI_GB_EFT_DOM_PAYEE;

/*--------------------------------------------------------------------
 | NAME:
 |     CITI_GB_EFT_DOM_DOC
 |
 | PURPOSE:
 |     Citibank UK domestic EFT document validation
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
 PROCEDURE CITI_GB_EFT_DOM_DOC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id, l_document_rec, p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate transaction code
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'DELIVERY_CHANNEL_CODE',
         l_document_rec.delivery_channel_code,
         'INDELIV',
         'GB',
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END CITI_GB_EFT_DOM_DOC;

/*--------------------------------------------------------------------
 | NAME:
 |     P_CITI_GB_EFT_DOM_PMT
 |
 | PURPOSE:
 |     Citibank UK domestic EFT payment validation
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
 PROCEDURE P_CITI_GB_EFT_DOM_PMT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_payment_rec IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the payment record
     IBY_VALIDATIONSETS_PUB.initPaymentData(p_payment_id,l_payment_rec);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_payment_id;
     l_docErrorRec.transaction_type := 'PAYMENT';
     l_docErrorRec.calling_app_doc_unique_ref1 := p_payment_id;

     -- Validate transaction reference
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PMT_ID',
         l_payment_rec.pmt_id,
         'MAXLENGTH',
         null,
         15,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Validate instruction currency
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'PMT_CURRENCY',
         l_payment_rec.pmt_currency,
         'EXACTLENGTH',
         null,
         3,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     -- The first parameter p_is_online_val takes hardcoded value 'N'.
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END P_CITI_GB_EFT_DOM_PMT;

/*--------------------------------------------------------------------
 | NAME:
 |     US_NACHA_INTERNAL_BANK
 |
 | PURPOSE:
 |     US Nacha internal bank validation
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
 PROCEDURE US_NACHA_INTERNAL_BANK (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate originating bank routing number
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'INT_BANK_BRANCH_NUM',
         l_document_rec.int_bank_branch_num,
         'EXACTLENGTH',
         null,
         9,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Insert errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the validation result
     x_result := l_valid;

 END US_NACHA_INTERNAL_BANK;

/*--------------------------------------------------------------------
 | NAME:
 |     US_NACHA_PAYEE
 |
 | PURPOSE:
 |     US Nacha payee validation
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
 PROCEDURE US_NACHA_PAYEE (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate supplier bank routing number
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_BRANCH_NUM',
         l_document_rec.ext_bank_branch_num,
         'EXACTLENGTH',
         null,
         9,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Insert errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the validation result
     x_result := l_valid;

 END US_NACHA_PAYEE;

 /*--------------------------------------------------------------------
 | NAME:
 |     US_NACHA_PAYEE_ACCOUNT
 |
 | PURPOSE:
 |     US Nacha IAT Payee Bank Account Validation
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
 PROCEDURE US_NACHA_PAYEE_ACCOUNT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate supplier bank routing number
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_ACC_NUM',
         l_document_rec.ext_bank_acc_num,
         'NOTNULL',
         null,
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Insert errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the validation result
     x_result := l_valid;

 END US_NACHA_PAYEE_ACCOUNT;

/*--------------------------------------------------------------------
 | NAME:
 |     I_US_NACHA_INSTR
 |
 | PURPOSE:
 |     US Nacha payment instruction validation
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
 PROCEDURE I_US_NACHA_INSTR (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_instruction_id     IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_instruction_rec IBY_VALIDATIONSETS_PUB.instructionRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 l_max_nacha_amt NUMBER;

 BEGIN

     -- Initializing the payment record
     IBY_VALIDATIONSETS_PUB.initInstructionData(p_instruction_id,l_instruction_rec);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_instruction_id;
     l_docErrorRec.transaction_type := 'PAYMENT_INSTRUCTION';
     l_docErrorRec.calling_app_doc_unique_ref1 := p_instruction_id;

     -- Validate number of detail records
     IBY_VALIDATIONSETS_PUB.getParamValue(
                            p_validation_assign_id,
                            p_validation_set_code,
                            'MAX_PAYMENT_INSTR_AMOUNT',
                            l_max_nacha_amt );

     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'INS_AMOUNT',
         l_instruction_rec.ins_amount,
         'LESSEQUAL',
         null,
         l_max_nacha_amt,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     -- The first parameter p_is_online_val takes hardcoded value 'N'.
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors('N',l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END I_US_NACHA_INSTR;

/*--------------------------------------------------------------------
 | NAME:
 |     ECE_DOC
 |
 | PURPOSE:
 |     Transactional field validations for E-Commerce gateway format
 |     (EDI validations).
 |
 |     See ER for EDI validations: 5518630
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
 PROCEDURE ECE_DOC (
     p_validation_assign_id  IN
         IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN
         IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id           IN
         IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult    BOOLEAN;
 l_valid        NUMBER := 0;
 l_docErrorTab  IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec  IBY_TRANSACTION_ERRORS%ROWTYPE;

 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME || '.ECE_DOC';
 BEGIN

     /*
      * Initialize the document record
      */
     IBY_VALIDATIONSETS_PUB.initDocumentData(
         p_document_id, l_document_rec, p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id      := p_document_id;
     l_docErrorRec.transaction_type    := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id      := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code
                                       := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1
                                       := l_document_rec.calling_app_doc_id1;


     /*
      * Validate delivery channel code
      */
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'DELIVERY_CHANNEL_CODE',
         l_document_rec.delivery_channel_code,
         'NOTNULL',
         null,
         null,
         l_valResult,
         l_docErrorRec);


     IF (l_valResult = FALSE) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Error: Delivery channel code '
	             || 'should not be null for EDI payments [document id: '
	             || p_document_id
	             || ']'
	             );

         END IF;
        IBY_VALIDATIONSETS_PUB.
            insertIntoErrorTable(l_docErrorRec, l_docErrorTab);

        l_valid := 1;

     END IF;

     /*
      * Insert errors into IBY_TRANSACTION_ERRORS
      */
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.
            insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     /*
      * Return the validation result
      */
     x_result := l_valid;

 END ECE_DOC;

/*--------------------------------------------------------------------
 | NAME:
 |     ECE_INTERNAL_BANK
 |
 | PURPOSE:
 |     Internal bank account validations for E-Commerce gateway format.
 |     (EDI validations).
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
 PROCEDURE ECE_INTERNAL_BANK (
     p_validation_assign_id  IN
         IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN
         IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id           IN
         IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER)
 IS

 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME || '.ECE_INTERNAL_BANK';

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult    BOOLEAN;
 l_valid        NUMBER := 0;
 l_docErrorTab  IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec  IBY_TRANSACTION_ERRORS%ROWTYPE;

 l_bank_branch_type   CE_BANK_BRANCHES_V.bank_branch_type%TYPE;
 l_bank_edi_id_number HZ_CONTACT_POINTS.edi_id_number%TYPE;
 l_bank_name          CE_BANK_BRANCHES_V.bank_name%TYPE;
 l_bank_branch_name   CE_BANK_BRANCHES_V.bank_branch_name%TYPE;

 BEGIN

     /*
      * Initialize the document record
      */
     IBY_VALIDATIONSETS_PUB.initDocumentData(
         p_document_id, l_document_rec, p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id      := p_document_id;
     l_docErrorRec.transaction_type    := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id      := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code
                                       := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1
                                       := l_document_rec.calling_app_doc_id1;

     /*
      * Pick up the payer bank branch type.
      */
     BEGIN

         SELECT
             abb.BANK_BRANCH_TYPE,
             edi.EDI_ID_NUMBER,
             abb.BANK_NAME,
             abb.BANK_BRANCH_NAME
         INTO
             l_bank_branch_type,
             l_bank_edi_id_number,
             l_bank_name,
             l_bank_branch_name
         FROM
             IBY_DOCS_PAYABLE_ALL doc,
             CE_BANK_BRANCHES_V   abb,
             CE_BANK_ACCOUNTS     cba,
             HZ_CONTACT_POINTS    edi
         WHERE
             doc.document_payable_id      = p_document_id
         AND doc.internal_bank_account_id = cba.bank_account_id
         AND cba.bank_branch_id           = abb.branch_party_id
         AND edi.owner_table_id           = abb.branch_party_id
         AND edi.owner_table_name         = 'HZ_PARTIES'
         AND edi.contact_point_type       = 'EFT'
         ;

     EXCEPTION
         WHEN OTHERS THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Non-fatal: Exception occured '
	                 || 'when attempting to get payer bank branch type '
	                 || 'for document id: '
	                 || p_document_id
	                 );

	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);

             END IF;
     END;

     /*
      *  Validate payer bank branch type
      */
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'INT_BANK_BRANCH_TYPE',
         l_bank_branch_type,
         'NOTNULL',
         null,
         null,
         l_valResult,
         l_docErrorRec
         );

     IF (l_valResult = FALSE) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Error: Payer bank branch type '
	             || 'should not be null for EDI payments [document id: '
	             || p_document_id
	             || ', bank name: '
	             || l_bank_name
	             || ', branch name: '
	             || l_bank_branch_name
	             || ']'
	             );

         END IF;
        IBY_VALIDATIONSETS_PUB.
            insertIntoErrorTable(l_docErrorRec, l_docErrorTab);

        l_valid := 1;

     END IF;

     /*
      * Insert errors into IBY_TRANSACTION_ERRORS
      */
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.
            insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     /*
      *  Return the validation result
      */
     x_result := l_valid;

 END ECE_INTERNAL_BANK;

/*--------------------------------------------------------------------
 | NAME:
 |     ECE_PAYEE
 |
 | PURPOSE:
 |     Payee validations for E-Commerce gateway format.
 |     (EDI validations).
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
 PROCEDURE ECE_PAYEE (
     p_validation_assign_id  IN
         IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN
         IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id           IN
         IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER)
 IS

 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME || '.ECE_PAYEE';

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult    BOOLEAN;
 l_valid        NUMBER := 0;
 l_docErrorTab  IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec  IBY_TRANSACTION_ERRORS%ROWTYPE;

 l_bank_branch_type CE_BANK_BRANCHES_V.bank_branch_type%TYPE;
 l_trxn_handling    IBY_EXTERNAL_PAYEES_ALL.bank_instruction2_code%TYPE;
 l_edi_pmt_format   IBY_EXTERNAL_PAYEES_ALL.bank_instruction1_code%TYPE;

 BEGIN

     /*
      * Initialize the document record
      */
     IBY_VALIDATIONSETS_PUB.initDocumentData(
         p_document_id, l_document_rec, p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id      := p_document_id;
     l_docErrorRec.transaction_type    := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id      := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code
                                       := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1
                                       := l_document_rec.calling_app_doc_id1;

     /*
      * Retrieve supplier bank branch type.
      * Inactivating validation for bug 7192723
      *
     BEGIN

         SELECT
             cbb.bank_branch_type
         INTO
             l_bank_branch_type
         FROM
             IBY_DOCS_PAYABLE_ALL    doc,
             IBY_EXT_BANK_ACCOUNTS_V eba,
             CE_BANK_BRANCHES_V      cbb
         WHERE
             doc.document_payable_id      = p_document_id
         AND doc.external_bank_account_id = eba.ext_bank_account_id(+)
         AND eba.bank_party_id            = cbb.bank_party_id(+)
         AND eba.branch_party_id          = cbb.branch_party_id(+)
         ;

     EXCEPTION
         WHEN OTHERS THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Non-fatal: Exception occured '
	                 || 'when attempting to get payee bank branch type '
	                 || 'for document id: '
	                 || p_document_id
	                 );

	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);

             END IF;
     END;
      */

     /*
      * Validate payee bank branch type.
      *  Inactivating validation for bug 7192723
      *
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_BRANCH_TYPE',
         l_bank_branch_type,
         'NOTNULL',
         null,
         null,
         l_valResult,
         l_docErrorRec
         );

     IF (l_valResult = FALSE) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Error: Payee bank branch type '
	             || 'should not be null for EDI payments [document id: '
	             || p_document_id
	             || ']'
	             );

         END IF;
        IBY_VALIDATIONSETS_PUB.
            insertIntoErrorTable(l_docErrorRec, l_docErrorTab);

        l_valid := 1;

     END IF;
      */


     /*
      * Retrieve EDI transaction handling.
      */
     BEGIN

         SELECT
             ep.bank_instruction2_code
         INTO
             l_trxn_handling
         FROM
             IBY_DOCS_PAYABLE_ALL    doc,
             IBY_EXTERNAL_PAYEES_ALL ep
         WHERE
             doc.document_payable_id  = p_document_id
         AND doc.ext_payee_id         = ep.ext_payee_id
         ;

     EXCEPTION
         WHEN OTHERS THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Non-fatal: Exception occured '
	                 || 'when attempting to get payee transaction handling '
	                 || 'for document id: '
	                 || p_document_id
	                 );

	             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);

             END IF;
     END;

     /*
      * Validate EDI transaction handling.
      */
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_PAYEE_BANK_CD2',
         l_trxn_handling,
         'NOTNULL',
         null,
         null,
         l_valResult,
         l_docErrorRec
         );

     IF (l_valResult = FALSE) THEN

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Error: Payee bank instruction code 2 '
	             || 'should not be null for EDI payments (this field indicates '
	             || 'transaction handling). [document id: '
	             || p_document_id
	             || ']'
	             );

         END IF;
        IBY_VALIDATIONSETS_PUB.
            insertIntoErrorTable(l_docErrorRec, l_docErrorTab);

        l_valid := 1;

     END IF;

     /*
      * For EDI payments, the EDI payment format should not
      * be null if the payment method code is 'ACH'.
      */
     IF (l_document_rec.payment_method_cd = 'ACH') THEN

         /*
          * Retrieve EDI payment format.
          */
         BEGIN

             SELECT
                 ep.bank_instruction1_code
             INTO
                 l_edi_pmt_format
             FROM
                 IBY_DOCS_PAYABLE_ALL    doc,
                 IBY_EXTERNAL_PAYEES_ALL ep
             WHERE
                 doc.document_payable_id  = p_document_id
             AND doc.ext_payee_id         = ep.ext_payee_id
             ;

         EXCEPTION
             WHEN OTHERS THEN

                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 print_debuginfo(l_module_name, 'Non-fatal: Exception occured '
	                     || 'when attempting to get EDI payment format '
	                     || 'for document id: '
	                     || p_document_id
	                     );

	                 print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
	                 print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);

                 END IF;
         END;

         /*
          * Fix for bug 5557010:
          *
          * Moved this validation into the if block as
          * it is only applicable to ACH payment method.
          */

         /*
          * Validate EDI payment format.
          */
         IBY_VALIDATIONSETS_PUB.evaluateCondition(
             'EXT_PAYEE_BANK_CD1',
             l_edi_pmt_format,
             'NOTNULL',
             null,
             null,
             l_valResult,
             l_docErrorRec
             );

         IF (l_valResult = FALSE) THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo(l_module_name, 'Error: Payee bank instruction '
	                 || 'code 1 should not be null for EDI payments (this '
	                 || 'field indicates EDI payment format). [document id: '
	                 || p_document_id
	                 || ']'
	                 );

             END IF;
            IBY_VALIDATIONSETS_PUB.
                insertIntoErrorTable(l_docErrorRec, l_docErrorTab);

            l_valid := 1;

         END IF;

     END IF; -- if pmt method = 'ACH'

     /*
      * Insert errors into IBY_TRANSACTION_ERRORS
      */
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.
            insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     /*
      * Return the validation result
      */
     x_result := l_valid;

 END ECE_PAYEE;

 /*-----------------------------------------*/
 /*
  * Component Validations Section
  */
 /*-----------------------------------------*/
 /*--------------------------------------------------------------------
  | NAME:
  |     IS_NOT_NULL
  |
  | PURPOSE:
  |     Validate the field named is not null
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
  PROCEDURE IS_NOT_NULL (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_transaction_id        IN NUMBER,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_payment_rec IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_instruction_rec IBY_VALIDATIONSETS_PUB.instructionRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 l_field_name VARCHAR2(500);
 l_field_value VARCHAR2(500);

 BEGIN

   -- Get the field name
   IBY_VALIDATIONSETS_PUB.getParamValue(
                p_validation_assign_id,
   	        p_validation_set_code,
   	        'P_FIELD_NAME',
   	        l_field_name );

   -- if field name is null, the validation is skipped, i.e. nothing is validated
   if l_field_name is null then
      x_result := l_valid;
      return;
   end if;

   l_docErrorRec.validation_set_code := p_validation_set_code;
   l_docErrorRec.transaction_id := p_transaction_id;

   -- Payment instruction field
   if substr(l_field_name,1,3) = 'INS' then
      -- Initializing the payment instruction record
      IBY_VALIDATIONSETS_PUB.initInstructionData(p_transaction_id,l_instruction_rec);

      l_docErrorRec.transaction_type := 'PAYMENT_INSTRUCTION';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_transaction_id;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getInstructionFieldValue (l_field_name, l_instruction_rec, l_field_value);

   -- Payment field
   elsif substr(l_field_name,1,3) = 'PMT' then
      -- Initializing the payment record
      IBY_VALIDATIONSETS_PUB.initPaymentData(p_transaction_id,l_payment_rec);

      l_docErrorRec.transaction_type := 'PAYMENT';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_transaction_id;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getPaymentFieldValue (l_field_name, l_payment_rec, l_field_value);

   -- Document field
   else
      -- Intializing the document record
      IBY_VALIDATIONSETS_PUB.initDocumentData(p_transaction_id,l_document_rec,p_is_online_val);

      l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
      l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
      l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
      l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getDocumentFieldValue (l_field_name, l_document_rec, l_field_value);
   end if;

   -- Validate that the field is not null
   IBY_VALIDATIONSETS_PUB.evaluateCondition(
       l_field_name,
       l_field_value,
       'NOTNULL',
       null,
       null,
       l_valResult,
       l_docErrorRec);

   IF (l_valResult = FALSE) THEN
      IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
      l_valid := 1;
   END IF;

   IF (l_valid = 1) THEN
      IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
   END IF;

   -- Return the Validation Result
   x_result := l_valid;

 END IS_NOT_NULL;

 /*--------------------------------------------------------------------
  | NAME:
  |     IS_NULL
  |
  | PURPOSE:
  |     Validate the field named is not null
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
  PROCEDURE IS_NULL (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_transaction_id        IN NUMBER,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_payment_rec  IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_instruction_rec IBY_VALIDATIONSETS_PUB.instructionRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 l_field_name VARCHAR2(500);
 l_field_value VARCHAR2(500);

 BEGIN

   -- Get the field name
   IBY_VALIDATIONSETS_PUB.getParamValue(
                p_validation_assign_id,
   	        p_validation_set_code,
   	        'P_FIELD_NAME',
   	        l_field_name );

   -- if field name is null, the validation is skipped, i.e. nothing is validated
   if l_field_name is null then
      x_result := l_valid;
      return;
   end if;

   l_docErrorRec.validation_set_code := p_validation_set_code;
   l_docErrorRec.transaction_id := p_transaction_id;

   -- Payment instruction field
   if substr(l_field_name,1,3) = 'INS' then
      -- Initializing the payment instruction record
      IBY_VALIDATIONSETS_PUB.initInstructionData(p_transaction_id,l_instruction_rec);

      l_docErrorRec.transaction_type := 'PAYMENT_INSTRUCTION';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_transaction_id;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getInstructionFieldValue (l_field_name, l_instruction_rec, l_field_value);

   -- Payment field
   elsif substr(l_field_name,1,3) = 'PMT' then
      -- Initializing the payment record
      IBY_VALIDATIONSETS_PUB.initPaymentData(p_transaction_id,l_payment_rec);

      l_docErrorRec.transaction_type := 'PAYMENT';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_transaction_id;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getPaymentFieldValue (l_field_name, l_payment_rec, l_field_value);

   -- Document field
   else
      -- Intializing the document record
      IBY_VALIDATIONSETS_PUB.initDocumentData(p_transaction_id,l_document_rec,p_is_online_val);

      l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
      l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
      l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
      l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getDocumentFieldValue (l_field_name, l_document_rec, l_field_value);
   end if;

   -- Validate that the field is null
   IBY_VALIDATIONSETS_PUB.evaluateCondition(
       l_field_name,
       trim(l_field_value),
       'ISNULL',
       null,
       null,
       l_valResult,
       l_docErrorRec);

   IF (l_valResult = FALSE) THEN
      IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
      l_valid := 1;
   END IF;

   IF (l_valid = 1) THEN
      IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
   END IF;

   -- Return the Validation Result
   x_result := l_valid;

 END IS_NULL;

 /*--------------------------------------------------------------------
  | NAME:
  |     VALIDATE_LENGTH
  |
  | PURPOSE:
  |     Validate the length of a field
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
  PROCEDURE VALIDATE_LENGTH (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_transaction_id        IN NUMBER,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_payment_rec  IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_instruction_rec IBY_VALIDATIONSETS_PUB.instructionRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 l_field_name VARCHAR2(500);
 l_field_value VARCHAR2(500);
 l_min_length number;
 l_max_length number;

 BEGIN

   -- Get the field name
   IBY_VALIDATIONSETS_PUB.getParamValue(
                p_validation_assign_id,
   	        p_validation_set_code,
   	        'P_FIELD_NAME',
   	        l_field_name );

   -- if field name is null, the validation is skipped, i.e. nothing is validated
   if l_field_name is null then
      x_result := l_valid;
      return;
   end if;

   l_docErrorRec.validation_set_code := p_validation_set_code;
   l_docErrorRec.transaction_id := p_transaction_id;

   -- Payment instruction field
   if substr(l_field_name,1,3) = 'INS' then
      -- Initializing the payment instruction record
      IBY_VALIDATIONSETS_PUB.initInstructionData(p_transaction_id,l_instruction_rec);

      l_docErrorRec.transaction_type := 'PAYMENT_INSTRUCTION';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_transaction_id;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getInstructionFieldValue (l_field_name, l_instruction_rec, l_field_value);

   -- Payment field
   elsif substr(l_field_name,1,3) = 'PMT' then
      -- Initializing the payment record
      IBY_VALIDATIONSETS_PUB.initPaymentData(p_transaction_id,l_payment_rec);

      l_docErrorRec.transaction_type := 'PAYMENT';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_transaction_id;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getPaymentFieldValue (l_field_name, l_payment_rec, l_field_value);

   -- Document field
   else
      -- Intializing the document record
      IBY_VALIDATIONSETS_PUB.initDocumentData(p_transaction_id,l_document_rec,p_is_online_val);

      l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
      l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
      l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
      l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getDocumentFieldValue (l_field_name, l_document_rec, l_field_value);
   end if;

   IBY_VALIDATIONSETS_PUB.getParamValue(
              p_validation_assign_id,
   			  p_validation_set_code,
   			  'P_MIN_LENGTH',
   			  l_min_length );

   IBY_VALIDATIONSETS_PUB.getParamValue(
              p_validation_assign_id,
   			  p_validation_set_code,
   			  'P_MAX_LENGTH',
   			  l_max_length );

   -- Validate that the field length is between the min and max
   IBY_VALIDATIONSETS_PUB.evaluateCondition(
       l_field_name,
       l_field_value,
       'MINLENGTH',
       null,
       nvl(l_min_length,0),
       l_valResult,
       l_docErrorRec);

   IF (l_valResult = FALSE) THEN
      IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
      l_valid := 1;
   END IF;

   IBY_VALIDATIONSETS_PUB.evaluateCondition(
       l_field_name,
       l_field_value,
       'MAXLENGTH',
       null,
       nvl(l_max_length,1000000000000),
       l_valResult,
       l_docErrorRec);

   IF (l_valResult = FALSE) THEN
      IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
      l_valid := 1;
   END IF;

   IF (l_valid = 1) THEN
      IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
   END IF;

   -- Return the Validation Result
   x_result := l_valid;

 END VALIDATE_LENGTH;

 /*--------------------------------------------------------------------
  | NAME:
  |     DIGITS_ONLY
  |
  | PURPOSE:
  |     Validate the field name contains digits only
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
  PROCEDURE DIGITS_ONLY (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_transaction_id        IN NUMBER,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_payment_rec  IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_instruction_rec IBY_VALIDATIONSETS_PUB.instructionRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 l_field_name VARCHAR2(500);
 l_field_value VARCHAR2(500);

 BEGIN

   -- Get the field name
   IBY_VALIDATIONSETS_PUB.getParamValue(
                p_validation_assign_id,
   	        p_validation_set_code,
   	        'P_FIELD_NAME',
   	        l_field_name );

   -- if field name is null, the validation is skipped, i.e. nothing is validated
   if l_field_name is null then
      x_result := l_valid;
      return;
   end if;

   l_docErrorRec.validation_set_code := p_validation_set_code;
   l_docErrorRec.transaction_id := p_transaction_id;

   -- Payment instruction field
   if substr(l_field_name,1,3) = 'INS' then
      -- Initializing the payment instruction record
      IBY_VALIDATIONSETS_PUB.initInstructionData(p_transaction_id,l_instruction_rec);

      l_docErrorRec.transaction_type := 'PAYMENT_INSTRUCTION';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_transaction_id;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getInstructionFieldValue (l_field_name, l_instruction_rec, l_field_value);

   -- Payment field
   elsif substr(l_field_name,1,3) = 'PMT' then
      -- Initializing the payment record
      IBY_VALIDATIONSETS_PUB.initPaymentData(p_transaction_id,l_payment_rec);

      l_docErrorRec.transaction_type := 'PAYMENT';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_transaction_id;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getPaymentFieldValue (l_field_name, l_payment_rec, l_field_value);

   -- Document field
   else
      -- Intializing the document record
      IBY_VALIDATIONSETS_PUB.initDocumentData(p_transaction_id,l_document_rec,p_is_online_val);

      l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
      l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
      l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
      l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getDocumentFieldValue (l_field_name, l_document_rec, l_field_value);
   end if;

   -- Validate that the field contains digits only
   IBY_VALIDATIONSETS_PUB.evaluateCondition(
       l_field_name,
       l_field_value,
       'DIGITSONLY',
       null,
       null,
       l_valResult,
       l_docErrorRec);

   IF (l_valResult = FALSE) THEN
      IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
      l_valid := 1;
   END IF;

   IF (l_valid = 1) THEN
      IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
   END IF;

   -- Return the Validation Result
   x_result := l_valid;

 END DIGITS_ONLY;

 PROCEDURE IS_NUMERIC (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_transaction_id        IN NUMBER,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER)
 is
 begin
   -- To be added
   null;
 end IS_NUMERIC;

 /*--------------------------------------------------------------------
  | NAME:
  |     IS_STRING
  |
  | PURPOSE:
  |     Validate the field name
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
  PROCEDURE IS_STRING (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_transaction_id        IN NUMBER,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_payment_rec  IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_instruction_rec IBY_VALIDATIONSETS_PUB.instructionRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 l_field_name VARCHAR2(500);
 l_field_value VARCHAR2(500);

 l_string VARCHAR2(500);

 BEGIN

   -- Get the field name
   IBY_VALIDATIONSETS_PUB.getParamValue(
                p_validation_assign_id,
   	        p_validation_set_code,
   	        'P_FIELD_NAME',
   	        l_field_name );

   -- if field name is null, the validation is skipped, i.e. nothing is validated
   if l_field_name is null then
      x_result := l_valid;
      return;
   end if;

   l_docErrorRec.validation_set_code := p_validation_set_code;
   l_docErrorRec.transaction_id := p_transaction_id;

   -- Payment instruction field
   if substr(l_field_name,1,3) = 'INS' then
      -- Initializing the payment instruction record
      IBY_VALIDATIONSETS_PUB.initInstructionData(p_transaction_id,l_instruction_rec);

      l_docErrorRec.transaction_type := 'PAYMENT_INSTRUCTION';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_transaction_id;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getInstructionFieldValue (l_field_name, l_instruction_rec, l_field_value);

   -- Payment field
   elsif substr(l_field_name,1,3) = 'PMT' then
      -- Initializing the payment record
      IBY_VALIDATIONSETS_PUB.initPaymentData(p_transaction_id,l_payment_rec);

      l_docErrorRec.transaction_type := 'PAYMENT';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_transaction_id;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getPaymentFieldValue (l_field_name, l_payment_rec, l_field_value);

   -- Document field
   else
      -- Intializing the document record
      IBY_VALIDATIONSETS_PUB.initDocumentData(p_transaction_id,l_document_rec,p_is_online_val);

      l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
      l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
      l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
      l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getDocumentFieldValue (l_field_name, l_document_rec, l_field_value);
   end if;

   IBY_VALIDATIONSETS_PUB.getParamValue(
                  p_validation_assign_id,
      			  p_validation_set_code,
      			  'P_STRING',
   			  l_string );

   -- Validate that the field is same as the string
   IBY_VALIDATIONSETS_PUB.evaluateCondition(
       l_field_name,
       l_field_value,
       'STRIS',
       l_string,
       null,
       l_valResult,
       l_docErrorRec);

   IF (l_valResult = FALSE) THEN
      IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
      l_valid := 1;
   END IF;

   IF (l_valid = 1) THEN
      IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
   END IF;

   -- Return the Validation Result
   x_result := l_valid;

 END IS_STRING;

 /*--------------------------------------------------------------------
  | NAME:
  |     IS_NOT_STRING
  |
  | PURPOSE:
  |     Validate the field name
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
  PROCEDURE IS_NOT_STRING (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_transaction_id        IN NUMBER,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_payment_rec  IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_instruction_rec IBY_VALIDATIONSETS_PUB.instructionRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 l_field_name VARCHAR2(500);
 l_field_value VARCHAR2(500);

 l_string VARCHAR2(500);

 BEGIN

   -- Get the field name
   IBY_VALIDATIONSETS_PUB.getParamValue(
                p_validation_assign_id,
   	        p_validation_set_code,
   	        'P_FIELD_NAME',
   	        l_field_name );

   -- if field name is null, the validation is skipped, i.e. nothing is validated
   if l_field_name is null then
      x_result := l_valid;
      return;
   end if;

   l_docErrorRec.validation_set_code := p_validation_set_code;
   l_docErrorRec.transaction_id := p_transaction_id;

   -- Payment instruction field
   if substr(l_field_name,1,3) = 'INS' then
      -- Initializing the payment instruction record
      IBY_VALIDATIONSETS_PUB.initInstructionData(p_transaction_id,l_instruction_rec);

      l_docErrorRec.transaction_type := 'PAYMENT_INSTRUCTION';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_transaction_id;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getInstructionFieldValue (l_field_name, l_instruction_rec, l_field_value);

   -- Payment field
   elsif substr(l_field_name,1,3) = 'PMT' then
      -- Initializing the payment record
      IBY_VALIDATIONSETS_PUB.initPaymentData(p_transaction_id,l_payment_rec);

      l_docErrorRec.transaction_type := 'PAYMENT';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_transaction_id;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getPaymentFieldValue (l_field_name, l_payment_rec, l_field_value);

   -- Document field
   else
      -- Intializing the document record
      IBY_VALIDATIONSETS_PUB.initDocumentData(p_transaction_id,l_document_rec,p_is_online_val);

      l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
      l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
      l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
      l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getDocumentFieldValue (l_field_name, l_document_rec, l_field_value);
   end if;

   IBY_VALIDATIONSETS_PUB.getParamValue(
                  p_validation_assign_id,
      			  p_validation_set_code,
      			  'P_STRING',
   			      l_string );

   -- Validate that the field is not same as the string
   IBY_VALIDATIONSETS_PUB.evaluateCondition(
       l_field_name,
       l_field_value,
       'STRISNOT',
       l_string,
       null,
       l_valResult,
       l_docErrorRec);

   IF (l_valResult = FALSE) THEN
      IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
      l_valid := 1;
   END IF;

   IF (l_valid = 1) THEN
      IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
   END IF;

   -- Return the Validation Result
   x_result := l_valid;

 END IS_NOT_STRING;

 /*--------------------------------------------------------------------
  | NAME:
  |     IN_SET
  |
  | PURPOSE:
  |     Validate the field name
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
  PROCEDURE IN_SET (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_transaction_id        IN NUMBER,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_payment_rec  IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_instruction_rec IBY_VALIDATIONSETS_PUB.instructionRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 l_field_name VARCHAR2(500);
 l_field_value VARCHAR2(500);

 l_string_set VARCHAR2(500);

 BEGIN

   -- Get the field name
   IBY_VALIDATIONSETS_PUB.getParamValue(
                p_validation_assign_id,
   	        p_validation_set_code,
   	        'P_FIELD_NAME',
   	        l_field_name );

   -- if field name is null, the validation is skipped, i.e. nothing is validated
   if l_field_name is null then
      x_result := l_valid;
      return;
   end if;

   l_docErrorRec.validation_set_code := p_validation_set_code;
   l_docErrorRec.transaction_id := p_transaction_id;

   -- Payment instruction field
   if substr(l_field_name,1,3) = 'INS' then
      -- Initializing the payment instruction record
      IBY_VALIDATIONSETS_PUB.initInstructionData(p_transaction_id,l_instruction_rec);

      l_docErrorRec.transaction_type := 'PAYMENT_INSTRUCTION';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_transaction_id;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getInstructionFieldValue (l_field_name, l_instruction_rec, l_field_value);

   -- Payment field
   elsif substr(l_field_name,1,3) = 'PMT' then
      -- Initializing the payment record
      IBY_VALIDATIONSETS_PUB.initPaymentData(p_transaction_id,l_payment_rec);

      l_docErrorRec.transaction_type := 'PAYMENT';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_transaction_id;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getPaymentFieldValue (l_field_name, l_payment_rec, l_field_value);

   -- Document field
   else
      -- Intializing the document record
      IBY_VALIDATIONSETS_PUB.initDocumentData(p_transaction_id,l_document_rec,p_is_online_val);

      l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
      l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
      l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
      l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getDocumentFieldValue (l_field_name, l_document_rec, l_field_value);
   end if;

   IBY_VALIDATIONSETS_PUB.getParamValue(
              p_validation_assign_id,
      		  p_validation_set_code,
      		  'P_STRING_SET',
   			  l_string_set );

   -- Validate that the field is among the set of strings
   IBY_VALIDATIONSETS_PUB.evaluateCondition(
       l_field_name,
       l_field_value,
       'INSET',
       l_string_set,
       null,
       l_valResult,
       l_docErrorRec);

   IF (l_valResult = FALSE) THEN
      IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
      l_valid := 1;
   END IF;

   IF (l_valid = 1) THEN
      IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
   END IF;

   -- Return the Validation Result
   x_result := l_valid;

 END IN_SET;

 /*--------------------------------------------------------------------
  | NAME:
  |     NOT_IN_SET
  |
  | PURPOSE:
  |     Validate the field name
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
  PROCEDURE NOT_IN_SET (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_transaction_id        IN NUMBER,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_payment_rec  IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_instruction_rec IBY_VALIDATIONSETS_PUB.instructionRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 l_field_name VARCHAR2(500);
 l_field_value VARCHAR2(500);

 l_string_set VARCHAR2(500);

 BEGIN

   -- Get the field name
   IBY_VALIDATIONSETS_PUB.getParamValue(
                p_validation_assign_id,
   	        p_validation_set_code,
   	        'P_FIELD_NAME',
   	        l_field_name );

   -- if field name is null, the validation is skipped, i.e. nothing is validated
   if l_field_name is null then
      x_result := l_valid;
      return;
   end if;

   l_docErrorRec.validation_set_code := p_validation_set_code;
   l_docErrorRec.transaction_id := p_transaction_id;

   -- Payment instruction field
   if substr(l_field_name,1,3) = 'INS' then
      -- Initializing the payment instruction record
      IBY_VALIDATIONSETS_PUB.initInstructionData(p_transaction_id,l_instruction_rec);

      l_docErrorRec.transaction_type := 'PAYMENT_INSTRUCTION';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_transaction_id;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getInstructionFieldValue (l_field_name, l_instruction_rec, l_field_value);

   -- Payment field
   elsif substr(l_field_name,1,3) = 'PMT' then
      -- Initializing the payment record
      IBY_VALIDATIONSETS_PUB.initPaymentData(p_transaction_id,l_payment_rec);

      l_docErrorRec.transaction_type := 'PAYMENT';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_transaction_id;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getPaymentFieldValue (l_field_name, l_payment_rec, l_field_value);

   -- Document field
   else
      -- Intializing the document record
      IBY_VALIDATIONSETS_PUB.initDocumentData(p_transaction_id,l_document_rec,p_is_online_val);

      l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
      l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
      l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
      l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getDocumentFieldValue (l_field_name, l_document_rec, l_field_value);
   end if;

   IBY_VALIDATIONSETS_PUB.getParamValue(
              p_validation_assign_id,
      		  p_validation_set_code,
      		  'P_STRING_SET',
   			  l_string_set );

   -- Validate that the field is not among the set of strings
   IBY_VALIDATIONSETS_PUB.evaluateCondition(
       l_field_name,
       l_field_value,
       'NOTINSET',
       l_string_set,
       null,
       l_valResult,
       l_docErrorRec);

   IF (l_valResult = FALSE) THEN
      IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
      l_valid := 1;
   END IF;

   IF (l_valid = 1) THEN
      IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
   END IF;

   -- Return the Validation Result
   x_result := l_valid;

 END NOT_IN_SET;

 /*--------------------------------------------------------------------
  | NAME:
  |     START_WITH
  |
  | PURPOSE:
  |     Validate the field name
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
  PROCEDURE START_WITH (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_transaction_id        IN NUMBER,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_payment_rec  IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_instruction_rec IBY_VALIDATIONSETS_PUB.instructionRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 l_field_name VARCHAR2(500);
 l_field_value VARCHAR2(500);

 l_string VARCHAR2(500);

 BEGIN

   -- Get the field name
   IBY_VALIDATIONSETS_PUB.getParamValue(
                p_validation_assign_id,
   	        p_validation_set_code,
   	        'P_FIELD_NAME',
   	        l_field_name );

   -- if field name is null, the validation is skipped, i.e. nothing is validated
   if l_field_name is null then
      x_result := l_valid;
      return;
   end if;

   l_docErrorRec.validation_set_code := p_validation_set_code;
   l_docErrorRec.transaction_id := p_transaction_id;

   -- Payment instruction field
   if substr(l_field_name,1,3) = 'INS' then
      -- Initializing the payment instruction record
      IBY_VALIDATIONSETS_PUB.initInstructionData(p_transaction_id,l_instruction_rec);

      l_docErrorRec.transaction_type := 'PAYMENT_INSTRUCTION';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_transaction_id;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getInstructionFieldValue (l_field_name, l_instruction_rec, l_field_value);

   -- Payment field
   elsif substr(l_field_name,1,3) = 'PMT' then
      -- Initializing the payment record
      IBY_VALIDATIONSETS_PUB.initPaymentData(p_transaction_id,l_payment_rec);

      l_docErrorRec.transaction_type := 'PAYMENT';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_transaction_id;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getPaymentFieldValue (l_field_name, l_payment_rec, l_field_value);

   -- Document field
   else
      -- Intializing the document record
      IBY_VALIDATIONSETS_PUB.initDocumentData(p_transaction_id,l_document_rec,p_is_online_val);

      l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
      l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
      l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
      l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getDocumentFieldValue (l_field_name, l_document_rec, l_field_value);
   end if;

   IBY_VALIDATIONSETS_PUB.getParamValue(
              p_validation_assign_id,
      		  p_validation_set_code,
      		  'P_STRING',
   			  l_string );

   -- Validate that the field starts with the string
   IBY_VALIDATIONSETS_PUB.evaluateCondition(
       l_field_name,
       l_field_value,
       'STARTWITH',
       l_string,
       null,
       l_valResult,
       l_docErrorRec);

   IF (l_valResult = FALSE) THEN
      IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
      l_valid := 1;
   END IF;

   IF (l_valid = 1) THEN
      IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
   END IF;

   -- Return the Validation Result
   x_result := l_valid;

 END START_WITH;

 /*--------------------------------------------------------------------
  | NAME:
  |     NOT_START_WITH
  |
  | PURPOSE:
  |     Validate the field name
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
  PROCEDURE NOT_START_WITH (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_transaction_id        IN NUMBER,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_payment_rec  IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_instruction_rec IBY_VALIDATIONSETS_PUB.instructionRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 l_field_name VARCHAR2(500);
 l_field_value VARCHAR2(500);

 l_string VARCHAR2(500);

 BEGIN

   -- Get the field name
   IBY_VALIDATIONSETS_PUB.getParamValue(
                p_validation_assign_id,
   	        p_validation_set_code,
   	        'P_FIELD_NAME',
   	        l_field_name );

   -- if field name is null, the validation is skipped, i.e. nothing is validated
   if l_field_name is null then
      x_result := l_valid;
      return;
   end if;

   l_docErrorRec.validation_set_code := p_validation_set_code;
   l_docErrorRec.transaction_id := p_transaction_id;

   -- Payment instruction field
   if substr(l_field_name,1,3) = 'INS' then
      -- Initializing the payment instruction record
      IBY_VALIDATIONSETS_PUB.initInstructionData(p_transaction_id,l_instruction_rec);

      l_docErrorRec.transaction_type := 'PAYMENT_INSTRUCTION';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_transaction_id;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getInstructionFieldValue (l_field_name, l_instruction_rec, l_field_value);

   -- Payment field
   elsif substr(l_field_name,1,3) = 'PMT' then
      -- Initializing the payment record
      IBY_VALIDATIONSETS_PUB.initPaymentData(p_transaction_id,l_payment_rec);

      l_docErrorRec.transaction_type := 'PAYMENT';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_transaction_id;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getPaymentFieldValue (l_field_name, l_payment_rec, l_field_value);

   -- Document field
   else
      -- Intializing the document record
      IBY_VALIDATIONSETS_PUB.initDocumentData(p_transaction_id,l_document_rec,p_is_online_val);

      l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
      l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
      l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
      l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getDocumentFieldValue (l_field_name, l_document_rec, l_field_value);
   end if;

   IBY_VALIDATIONSETS_PUB.getParamValue(
              p_validation_assign_id,
      		  p_validation_set_code,
      		  'P_STRING',
   			  l_string );

   -- Validate that the field does not start with the string
   IBY_VALIDATIONSETS_PUB.evaluateCondition(
       l_field_name,
       l_field_value,
       'NOTSTARTWITH',
       l_string,
       null,
       l_valResult,
       l_docErrorRec);

   IF (l_valResult = FALSE) THEN
      IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
      l_valid := 1;
   END IF;

   IF (l_valid = 1) THEN
      IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
   END IF;

   -- Return the Validation Result
   x_result := l_valid;

 END NOT_START_WITH;

 /*--------------------------------------------------------------------
  | NAME:
  |     IS_IN_LOOKUP
  |
  | PURPOSE:
  |     Validate the field name
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
  PROCEDURE IS_IN_LOOKUP (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_transaction_id        IN NUMBER,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_payment_rec  IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_instruction_rec IBY_VALIDATIONSETS_PUB.instructionRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 l_field_name VARCHAR2(500);
 l_field_value VARCHAR2(500);

 l_lookup_type VARCHAR2(500);

 BEGIN

   -- Get the field name
   IBY_VALIDATIONSETS_PUB.getParamValue(
                p_validation_assign_id,
   	        p_validation_set_code,
   	        'P_FIELD_NAME',
   	        l_field_name );

   -- if field name is null, the validation is skipped, i.e. nothing is validated
   if l_field_name is null then
      x_result := l_valid;
      return;
   end if;

   l_docErrorRec.validation_set_code := p_validation_set_code;
   l_docErrorRec.transaction_id := p_transaction_id;

   -- Payment instruction field
   if substr(l_field_name,1,3) = 'INS' then
      -- Initializing the payment instruction record
      IBY_VALIDATIONSETS_PUB.initInstructionData(p_transaction_id,l_instruction_rec);

      l_docErrorRec.transaction_type := 'PAYMENT_INSTRUCTION';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_transaction_id;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getInstructionFieldValue (l_field_name, l_instruction_rec, l_field_value);

   -- Payment field
   elsif substr(l_field_name,1,3) = 'PMT' then
      -- Initializing the payment record
      IBY_VALIDATIONSETS_PUB.initPaymentData(p_transaction_id,l_payment_rec);

      l_docErrorRec.transaction_type := 'PAYMENT';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_transaction_id;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getPaymentFieldValue (l_field_name, l_payment_rec, l_field_value);

   -- Document field
   else
      -- Intializing the document record
      IBY_VALIDATIONSETS_PUB.initDocumentData(p_transaction_id,l_document_rec,p_is_online_val);

      l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
      l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
      l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
      l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getDocumentFieldValue (l_field_name, l_document_rec, l_field_value);
   end if;

   IBY_VALIDATIONSETS_PUB.getParamValue(
              p_validation_assign_id,
      		  p_validation_set_code,
      		  'P_LOOKUP_TYPE',
   			  l_lookup_type );

   -- Validate that the field is among the records in the lookup type
   IBY_VALIDATIONSETS_PUB.evaluateCondition(
       l_field_name,
       l_field_value,
       'INLOOKUPTYPE',
       l_lookup_type,
       null,
       l_valResult,
       l_docErrorRec);

   IF (l_valResult = FALSE) THEN
      IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
      l_valid := 1;
   END IF;

   IF (l_valid = 1) THEN
      IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
   END IF;

   -- Return the Validation Result
   x_result := l_valid;

 END IS_IN_LOOKUP;

 /*--------------------------------------------------------------------
  | NAME:
  |     GREATER_THAN
  |
  | PURPOSE:
  |     Validate the field name
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
  PROCEDURE GREATER_THAN (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_transaction_id        IN NUMBER,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_payment_rec  IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_instruction_rec IBY_VALIDATIONSETS_PUB.instructionRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 l_field_name VARCHAR2(500);
 l_field_value VARCHAR2(500);

 l_num_value number;

 BEGIN

   -- Get the field name
   IBY_VALIDATIONSETS_PUB.getParamValue(
                p_validation_assign_id,
   	        p_validation_set_code,
   	        'P_FIELD_NAME',
   	        l_field_name );

   -- if field name is null, the validation is skipped, i.e. nothing is validated
   if l_field_name is null then
      x_result := l_valid;
      return;
   end if;

   l_docErrorRec.validation_set_code := p_validation_set_code;
   l_docErrorRec.transaction_id := p_transaction_id;

   -- Payment instruction field
   if substr(l_field_name,1,3) = 'INS' then
      -- Initializing the payment instruction record
      IBY_VALIDATIONSETS_PUB.initInstructionData(p_transaction_id,l_instruction_rec);

      l_docErrorRec.transaction_type := 'PAYMENT_INSTRUCTION';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_transaction_id;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getInstructionFieldValue (l_field_name, l_instruction_rec, l_field_value);

   -- Payment field
   elsif substr(l_field_name,1,3) = 'PMT' then
      -- Initializing the payment record
      IBY_VALIDATIONSETS_PUB.initPaymentData(p_transaction_id,l_payment_rec);

      l_docErrorRec.transaction_type := 'PAYMENT';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_transaction_id;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getPaymentFieldValue (l_field_name, l_payment_rec, l_field_value);

   -- Document field
   else
      -- Intializing the document record
      IBY_VALIDATIONSETS_PUB.initDocumentData(p_transaction_id,l_document_rec,p_is_online_val);

      l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
      l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
      l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
      l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getDocumentFieldValue (l_field_name, l_document_rec, l_field_value);
   end if;

   IBY_VALIDATIONSETS_PUB.getParamValue(
              p_validation_assign_id,
      		  p_validation_set_code,
      		  'P_NUMBER',
   			  l_num_value );

   -- Validate that the field is greater than the value
   IBY_VALIDATIONSETS_PUB.evaluateCondition(
       l_field_name,
       l_field_value,
       'GRTTHAN',
       null,
       l_num_value,
       l_valResult,
       l_docErrorRec);

   IF (l_valResult = FALSE) THEN
      IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
      l_valid := 1;
   END IF;

   IF (l_valid = 1) THEN
      IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
   END IF;

   -- Return the Validation Result
   x_result := l_valid;

 END GREATER_THAN;

 /*--------------------------------------------------------------------
  | NAME:
  |     GREATER_THAN_EQUAL_TO
  |
  | PURPOSE:
  |     Validate the field name
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
  PROCEDURE GREATER_THAN_EQUAL_TO (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_transaction_id        IN NUMBER,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_payment_rec  IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_instruction_rec IBY_VALIDATIONSETS_PUB.instructionRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 l_field_name VARCHAR2(500);
 l_field_value VARCHAR2(500);

 l_num_value number;

 BEGIN

   -- Get the field name
   IBY_VALIDATIONSETS_PUB.getParamValue(
                p_validation_assign_id,
   	        p_validation_set_code,
   	        'P_FIELD_NAME',
   	        l_field_name );

   -- if field name is null, the validation is skipped, i.e. nothing is validated
   if l_field_name is null then
      x_result := l_valid;
      return;
   end if;

   l_docErrorRec.validation_set_code := p_validation_set_code;
   l_docErrorRec.transaction_id := p_transaction_id;

   -- Payment instruction field
   if substr(l_field_name,1,3) = 'INS' then
      -- Initializing the payment instruction record
      IBY_VALIDATIONSETS_PUB.initInstructionData(p_transaction_id,l_instruction_rec);

      l_docErrorRec.transaction_type := 'PAYMENT_INSTRUCTION';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_transaction_id;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getInstructionFieldValue (l_field_name, l_instruction_rec, l_field_value);

   -- Payment field
   elsif substr(l_field_name,1,3) = 'PMT' then
      -- Initializing the payment record
      IBY_VALIDATIONSETS_PUB.initPaymentData(p_transaction_id,l_payment_rec);

      l_docErrorRec.transaction_type := 'PAYMENT';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_transaction_id;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getPaymentFieldValue (l_field_name, l_payment_rec, l_field_value);

   -- Document field
   else
      -- Intializing the document record
      IBY_VALIDATIONSETS_PUB.initDocumentData(p_transaction_id,l_document_rec,p_is_online_val);

      l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
      l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
      l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
      l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getDocumentFieldValue (l_field_name, l_document_rec, l_field_value);
   end if;

   IBY_VALIDATIONSETS_PUB.getParamValue(
              p_validation_assign_id,
      		  p_validation_set_code,
      		  'P_NUMBER',
   			  l_num_value );

   -- Validate that the field is greater than or equal to the value
   IBY_VALIDATIONSETS_PUB.evaluateCondition(
       l_field_name,
       l_field_value,
       'GRTEQUAL',
       null,
       l_num_value,
       l_valResult,
       l_docErrorRec);

   IF (l_valResult = FALSE) THEN
      IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
      l_valid := 1;
   END IF;

   IF (l_valid = 1) THEN
      IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
   END IF;

   -- Return the Validation Result
   x_result := l_valid;

 END GREATER_THAN_EQUAL_TO;

 /*--------------------------------------------------------------------
  | NAME:
  |     LESS_THAN
  |
  | PURPOSE:
  |     Validate the field name
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
  PROCEDURE LESS_THAN (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_transaction_id        IN NUMBER,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_payment_rec  IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_instruction_rec IBY_VALIDATIONSETS_PUB.instructionRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 l_field_name VARCHAR2(500);
 l_field_value VARCHAR2(500);

 l_num_value number;

 BEGIN

   -- Get the field name
   IBY_VALIDATIONSETS_PUB.getParamValue(
                p_validation_assign_id,
   	        p_validation_set_code,
   	        'P_FIELD_NAME',
   	        l_field_name );

   -- if field name is null, the validation is skipped, i.e. nothing is validated
   if l_field_name is null then
      x_result := l_valid;
      return;
   end if;

   l_docErrorRec.validation_set_code := p_validation_set_code;
   l_docErrorRec.transaction_id := p_transaction_id;

   -- Payment instruction field
   if substr(l_field_name,1,3) = 'INS' then
      -- Initializing the payment instruction record
      IBY_VALIDATIONSETS_PUB.initInstructionData(p_transaction_id,l_instruction_rec);

      l_docErrorRec.transaction_type := 'PAYMENT_INSTRUCTION';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_transaction_id;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getInstructionFieldValue (l_field_name, l_instruction_rec, l_field_value);

   -- Payment field
   elsif substr(l_field_name,1,3) = 'PMT' then
      -- Initializing the payment record
      IBY_VALIDATIONSETS_PUB.initPaymentData(p_transaction_id,l_payment_rec);

      l_docErrorRec.transaction_type := 'PAYMENT';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_transaction_id;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getPaymentFieldValue (l_field_name, l_payment_rec, l_field_value);

   -- Document field
   else
      -- Intializing the document record
      IBY_VALIDATIONSETS_PUB.initDocumentData(p_transaction_id,l_document_rec,p_is_online_val);

      l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
      l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
      l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
      l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getDocumentFieldValue (l_field_name, l_document_rec, l_field_value);
   end if;

   IBY_VALIDATIONSETS_PUB.getParamValue(
              p_validation_assign_id,
      		  p_validation_set_code,
      		  'P_NUMBER',
   			  l_num_value );

   -- Validate that the field is less than the value
   IBY_VALIDATIONSETS_PUB.evaluateCondition(
       l_field_name,
       l_field_value,
       'LESSTHAN',
       null,
       l_num_value,
       l_valResult,
       l_docErrorRec);

   IF (l_valResult = FALSE) THEN
      IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
      l_valid := 1;
   END IF;

   IF (l_valid = 1) THEN
      IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
   END IF;

   -- Return the Validation Result
   x_result := l_valid;

 END LESS_THAN;

 /*--------------------------------------------------------------------
  | NAME:
  |     LESS_THAN_EQUAL_TO
  |
  | PURPOSE:
  |     Validate the field name
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
  PROCEDURE LESS_THAN_EQUAL_TO (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_transaction_id        IN NUMBER,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_payment_rec  IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_instruction_rec IBY_VALIDATIONSETS_PUB.instructionRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 l_field_name VARCHAR2(500);
 l_field_value VARCHAR2(500);

 l_num_value number;

 BEGIN

   -- Get the field name
   IBY_VALIDATIONSETS_PUB.getParamValue(
                p_validation_assign_id,
   	        p_validation_set_code,
   	        'P_FIELD_NAME',
   	        l_field_name );

   -- if field name is null, the validation is skipped, i.e. nothing is validated
   if l_field_name is null then
      x_result := l_valid;
      return;
   end if;

   l_docErrorRec.validation_set_code := p_validation_set_code;
   l_docErrorRec.transaction_id := p_transaction_id;

   -- Payment instruction field
   if substr(l_field_name,1,3) = 'INS' then
      -- Initializing the payment instruction record
      IBY_VALIDATIONSETS_PUB.initInstructionData(p_transaction_id,l_instruction_rec);

      l_docErrorRec.transaction_type := 'PAYMENT_INSTRUCTION';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_transaction_id;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getInstructionFieldValue (l_field_name, l_instruction_rec, l_field_value);

   -- Payment field
   elsif substr(l_field_name,1,3) = 'PMT' then
      -- Initializing the payment record
      IBY_VALIDATIONSETS_PUB.initPaymentData(p_transaction_id,l_payment_rec);

      l_docErrorRec.transaction_type := 'PAYMENT';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_transaction_id;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getPaymentFieldValue (l_field_name, l_payment_rec, l_field_value);

   -- Document field
   else
      -- Intializing the document record
      IBY_VALIDATIONSETS_PUB.initDocumentData(p_transaction_id,l_document_rec,p_is_online_val);

      l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
      l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
      l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
      l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getDocumentFieldValue (l_field_name, l_document_rec, l_field_value);
   end if;

   IBY_VALIDATIONSETS_PUB.getParamValue(
              p_validation_assign_id,
      		  p_validation_set_code,
      		  'P_NUMBER',
   			  l_num_value );

   -- Validate that the field is less than or equal to the value
   IBY_VALIDATIONSETS_PUB.evaluateCondition(
       l_field_name,
       l_field_value,
       'LESSEQUAL',
       null,
       l_num_value,
       l_valResult,
       l_docErrorRec);

   IF (l_valResult = FALSE) THEN
      IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
      l_valid := 1;
   END IF;

   IF (l_valid = 1) THEN
      IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
   END IF;

   -- Return the Validation Result
   x_result := l_valid;

 END LESS_THAN_EQUAL_TO;

 /*--------------------------------------------------------------------
  | NAME:
  |     EQUAL_TO
  |
  | PURPOSE:
  |     Validate the field name
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
  PROCEDURE EQUAL_TO (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_transaction_id        IN NUMBER,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_payment_rec  IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_instruction_rec IBY_VALIDATIONSETS_PUB.instructionRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 l_field_name VARCHAR2(500);
 l_field_value VARCHAR2(500);

 l_num_value number;

 BEGIN

   -- Get the field name
   IBY_VALIDATIONSETS_PUB.getParamValue(
                p_validation_assign_id,
   	        p_validation_set_code,
   	        'P_FIELD_NAME',
   	        l_field_name );

   -- if field name is null, the validation is skipped, i.e. nothing is validated
   if l_field_name is null then
      x_result := l_valid;
      return;
   end if;

   l_docErrorRec.validation_set_code := p_validation_set_code;
   l_docErrorRec.transaction_id := p_transaction_id;

   -- Payment instruction field
   if substr(l_field_name,1,3) = 'INS' then
      -- Initializing the payment instruction record
      IBY_VALIDATIONSETS_PUB.initInstructionData(p_transaction_id,l_instruction_rec);

      l_docErrorRec.transaction_type := 'PAYMENT_INSTRUCTION';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_transaction_id;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getInstructionFieldValue (l_field_name, l_instruction_rec, l_field_value);

   -- Payment field
   elsif substr(l_field_name,1,3) = 'PMT' then
      -- Initializing the payment record
      IBY_VALIDATIONSETS_PUB.initPaymentData(p_transaction_id,l_payment_rec);

      l_docErrorRec.transaction_type := 'PAYMENT';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_transaction_id;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getPaymentFieldValue (l_field_name, l_payment_rec, l_field_value);

   -- Document field
   else
      -- Intializing the document record
      IBY_VALIDATIONSETS_PUB.initDocumentData(p_transaction_id,l_document_rec,p_is_online_val);

      l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
      l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
      l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
      l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getDocumentFieldValue (l_field_name, l_document_rec, l_field_value);
   end if;

   IBY_VALIDATIONSETS_PUB.getParamValue(
              p_validation_assign_id,
      		  p_validation_set_code,
      		  'P_NUMBER',
   			  l_num_value );

   -- Validate that the field is equal to the value
   IBY_VALIDATIONSETS_PUB.evaluateCondition(
       l_field_name,
       l_field_value,
       'EQUALTO',
       null,
       l_num_value,
       l_valResult,
       l_docErrorRec);

   IF (l_valResult = FALSE) THEN
      IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
      l_valid := 1;
   END IF;

   IF (l_valid = 1) THEN
      IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
   END IF;

   -- Return the Validation Result
   x_result := l_valid;

 END EQUAL_TO;

 /*--------------------------------------------------------------------
  | NAME:
  |     NOT_EQUAL_TO
  |
  | PURPOSE:
  |     Validate the field name
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
  PROCEDURE NOT_EQUAL_TO (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_transaction_id        IN NUMBER,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_payment_rec  IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_instruction_rec IBY_VALIDATIONSETS_PUB.instructionRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

 l_field_name VARCHAR2(500);
 l_field_value VARCHAR2(500);

 l_num_value number;

 BEGIN

   -- Get the field name
   IBY_VALIDATIONSETS_PUB.getParamValue(
                p_validation_assign_id,
   	        p_validation_set_code,
   	        'P_FIELD_NAME',
   	        l_field_name );

   -- if field name is null, the validation is skipped, i.e. nothing is validated
   if l_field_name is null then
      x_result := l_valid;
      return;
   end if;

   l_docErrorRec.validation_set_code := p_validation_set_code;
   l_docErrorRec.transaction_id := p_transaction_id;

   -- Payment instruction field
   if substr(l_field_name,1,3) = 'INS' then
      -- Initializing the payment instruction record
      IBY_VALIDATIONSETS_PUB.initInstructionData(p_transaction_id,l_instruction_rec);

      l_docErrorRec.transaction_type := 'PAYMENT_INSTRUCTION';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_transaction_id;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getInstructionFieldValue (l_field_name, l_instruction_rec, l_field_value);

   -- Payment field
   elsif substr(l_field_name,1,3) = 'PMT' then
      -- Initializing the payment record
      IBY_VALIDATIONSETS_PUB.initPaymentData(p_transaction_id,l_payment_rec);

      l_docErrorRec.transaction_type := 'PAYMENT';
      l_docErrorRec.calling_app_doc_unique_ref1 := p_transaction_id;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getPaymentFieldValue (l_field_name, l_payment_rec, l_field_value);

   -- Document field
   else
      -- Intializing the document record
      IBY_VALIDATIONSETS_PUB.initDocumentData(p_transaction_id,l_document_rec,p_is_online_val);

      l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
      l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
      l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
      l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

      -- Get the field value
      IBY_VALIDATIONSETS_PUB.getDocumentFieldValue (l_field_name, l_document_rec, l_field_value);
   end if;

   IBY_VALIDATIONSETS_PUB.getParamValue(
              p_validation_assign_id,
      		  p_validation_set_code,
      		  'P_NUMBER',
   			  l_num_value );

   -- Validate that the field is not equal to the value
   IBY_VALIDATIONSETS_PUB.evaluateCondition(
       l_field_name,
       l_field_value,
       'NOTEQUALTO',
       null,
       l_num_value,
       l_valResult,
       l_docErrorRec);

   IF (l_valResult = FALSE) THEN
      IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
      l_valid := 1;
   END IF;

   IF (l_valid = 1) THEN
      IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
   END IF;

   -- Return the Validation Result
   x_result := l_valid;

 END NOT_EQUAL_TO;


 -- End of Section Component Validation

/*--------------------------------------------------------------------
 | NAME:
 |     performCharacterValidation
 |
 | PURPOSE:
 |     Procedure to validate character set.
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
 PROCEDURE performCharacterValidation(
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.
                                    validation_assignment_id%TYPE,
     p_validation_set_code   IN IBY_VALIDATION_SETS_VL.
                                    validation_set_code%TYPE,
     p_document_id           IN IBY_DOCS_PAYABLE_ALL.payment_id%TYPE,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER)
 IS

 l_charval_rec IBY_VALIDATIONSETS_PUB.charValRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;
 l_invalid_chars_list  VARCHAR2(3000);
 l_valid_chars_list    VARCHAR2(3000);

 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME ||
                                             '.performCharacterValidation';

 /*
  * The p_is_online_val input parameter has been added to the args list
  * only to make the method signature compatible with a validation set.
  *
  * All character validations are expected to be done as deferred
  * validations, hence p_is_online is ignored (always assumed to be 'N').
  */

 /*
  * Cursor to pick up the character set applicable to a particular
  * validation set and validation assignment entity.
  *
  * Note: This cursor is expected to only pick up one row
  */
 CURSOR c_charlist (p_val_set_id    IBY_VALIDATION_SETS_VL.
                                        validation_set_code%TYPE,
                    p_charlist_type IBY_VALIDATION_PARAMS_VL.
                                        validation_parameter_code%TYPE)
 IS
 SELECT
     val.val_param_varchar2_value
 FROM
     IBY_VALIDATION_VALUES     val,
     IBY_VALIDATION_PARAMS_VL  names,
     IBY_VALIDATION_SETS_VL    valsets,
     IBY_VAL_ASSIGNMENTS       asgns
 WHERE
     valsets.validation_set_code = p_val_set_id
 AND
     val.validation_set_code = valsets.validation_set_code
 AND
     names.validation_parameter_code = p_charlist_type
 AND
     val.validation_parameter_code = names.validation_parameter_code
 AND
     asgns.validation_assignment_id = p_validation_assign_id
 AND
     val.validation_assignment_id = asgns.validation_assignment_id;

 BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'ENTER');

	     print_debuginfo(l_module_name, 'Provided document id: '
	         || p_document_id
	         );

     END IF;
     /*
      * Get the fields from the document, payer, payee, payer bank
      * and payee bank for character validation.
      *
      * Since, in the build program, we don't know which of these
      * fields will be sent to the bank, we take the safer approach
      * and validate all of them.
      */
     IBY_VALIDATIONSETS_PUB.initCharValData(p_document_id, l_charval_rec);

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Checking document '
	         || l_charval_rec.document_id || ' for invalid characters');

     END IF;
     /*
      * Get list of valid characters associated with this validation set.
      */
     OPEN  c_charlist(p_validation_set_code, 'VALID_CHARS_LIST');
     FETCH c_charlist INTO l_valid_chars_list;
     CLOSE c_charlist;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'List of valid chars from parameters '
	         || 'table: '
	         || l_valid_chars_list);

     END IF;
     /*
      * Get list of invalid characters associated with this validation set.
      */
     OPEN  c_charlist(p_validation_set_code, 'INVALID_CHARS_LIST');
     FETCH c_charlist INTO l_invalid_chars_list;
     CLOSE c_charlist;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'List of invalid chars from parameters '
	         || 'table: '
	         || l_invalid_chars_list);

     END IF;
     /*
      * If list of valid chars and list of invalid chars are both
      * null, then we cannot perform character validation.
      *
      * We'll consider this as incomplete setup (not an error).
      * Write a warning to the log file the and exit.
      */
     IF (l_valid_chars_list IS NULL AND l_invalid_chars_list IS NULL) THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Neither list of invalid chars '
	             || ' nor list of valid chars were provided as validation '
	             || ' parameter for validation set '
	             || p_validation_set_code
	             || '. No character validation is possible. Exiting ..');
         END IF;
         x_result := l_valid;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'EXIT');
         END IF;
         RETURN;
     END IF;

     /*
      * The user may have provided both list of valid chars and
      * list of invalid chars. The list of valid chars takes
      * precedence in such a case, and the list of invalid chars
      * is ignored. Log this to warn user.
      */
     IF (l_valid_chars_list   IS NOT NULL  AND
         l_invalid_chars_list IS NOT NULL) THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Both list of invalid chars '
	             || ' and list of valid chars were provided as validation '
	             || ' parameter for validation set '
	             || p_validation_set_code
	             || '. Only list of valid characters will be used.');
         END IF;
     END IF;

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';

     l_docErrorRec.calling_app_id := l_charval_rec.ca_id;
     l_docErrorRec.pay_proc_trxn_type_code :=
         l_charval_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 :=
         l_charval_rec.calling_app_doc_id1;

     /*
      * Go through all the fields in the document record checking
      * if the fields have invalid characters.
      */
     iby_build_utils_pkg.checkForInvalidChars(
         'Document identification',
         l_charval_rec.document_id
             || l_charval_rec.ca_id
             || l_charval_rec.calling_app_doc_id1
             || l_charval_rec.ca_doc_ref_num,
         true,
         l_valid_chars_list, l_invalid_chars_list,
         l_docErrorRec, l_docErrorTab);

     iby_build_utils_pkg.checkForInvalidChars(
         'PO number',
         l_charval_rec.po_number, false,
         l_valid_chars_list, l_invalid_chars_list,
         l_docErrorRec, l_docErrorTab);

     iby_build_utils_pkg.checkForInvalidChars(
         'Unique remittance identifier',
         l_charval_rec.uri, false,
         l_valid_chars_list, l_invalid_chars_list,
         l_docErrorRec, l_docErrorTab);

     iby_build_utils_pkg.checkForInvalidChars(
         'Unique remittance identifier checkdigit',
         l_charval_rec.uri_checkdigit, false,
         l_valid_chars_list, l_invalid_chars_list,
         l_docErrorRec, l_docErrorTab);

     iby_build_utils_pkg.checkForInvalidChars(
         'Document description',
         l_charval_rec.doc_desc, false,
         l_valid_chars_list, l_invalid_chars_list,
         l_docErrorRec, l_docErrorTab);

     iby_build_utils_pkg.checkForInvalidChars(
         'Bank assigned ref code',
         l_charval_rec.bank_ref, false,
         l_valid_chars_list, l_invalid_chars_list,
         l_docErrorRec, l_docErrorTab);

     /*
      * Commented out because the bank account
      * debit code no longer exists in the latest
      * data model.
      */
     /*
     iby_build_utils_pkg.checkForInvalidChars(
         'Bank account debit code',
         l_charval_rec.bank_acct_debit_code, false,
         l_valid_chars_list, l_invalid_chars_list,
         l_docErrorRec, l_docErrorTab);
     */

     iby_build_utils_pkg.checkForInvalidChars(
         'Payment reason comments',
         l_charval_rec.pmt_reason_comments, false,
         l_valid_chars_list, l_invalid_chars_list,
         l_docErrorRec, l_docErrorTab);

     iby_build_utils_pkg.checkForInvalidChars(
         'Delivery channel code',
         l_charval_rec.delv_chnl_code, false,
         l_valid_chars_list, l_invalid_chars_list,
         l_docErrorRec, l_docErrorTab);

     iby_build_utils_pkg.checkForInvalidChars(
         'Payment reason',
         l_charval_rec.pmt_reason, false,
         l_valid_chars_list, l_invalid_chars_list,
         l_docErrorRec, l_docErrorTab);

     iby_build_utils_pkg.checkForInvalidChars(
         'Remittance message',
         l_charval_rec.remit_msg1
             || l_charval_rec.remit_msg2
             || l_charval_rec.remit_msg3,
         true,
         l_valid_chars_list, l_invalid_chars_list,
         l_docErrorRec, l_docErrorTab);

     iby_build_utils_pkg.checkForInvalidChars(
         'Document lines',
         l_charval_rec.ca_doc_line_cd
             || l_charval_rec.line_type
             || l_charval_rec.line_name
             || l_charval_rec.line_desc
             || l_charval_rec.line_uom
             || l_charval_rec.line_po_num,
         true,
         l_valid_chars_list, l_invalid_chars_list,
         l_docErrorRec, l_docErrorTab);

     iby_build_utils_pkg.checkForInvalidChars(
         'Payer identification',
         l_charval_rec.payer_number
             || l_charval_rec.payer_name
             || l_charval_rec.payer_legal_name,
         true,
         l_valid_chars_list, l_invalid_chars_list,
         l_docErrorRec, l_docErrorTab);

     iby_build_utils_pkg.checkForInvalidChars(
         'Payer tax id',
         l_charval_rec.payer_tax_id, false,
         l_valid_chars_list, l_invalid_chars_list,
         l_docErrorRec, l_docErrorTab);

     iby_build_utils_pkg.checkForInvalidChars(
         'Payer address',
         l_charval_rec.payer_add1
             || l_charval_rec.payer_add2
             || l_charval_rec.payer_add3
             || l_charval_rec.payer_city
             || l_charval_rec.payer_county
             || l_charval_rec.payer_state
             || l_charval_rec.payer_country
             || l_charval_rec.payer_postcode,
         true,
         l_valid_chars_list, l_invalid_chars_list,
         l_docErrorRec, l_docErrorTab);

     iby_build_utils_pkg.checkForInvalidChars(
         'Payer bank/branch details',
         l_charval_rec.payer_bank_name
             || l_charval_rec.payer_bank_number
             || l_charval_rec.payer_bank_branch_num
             || l_charval_rec.payer_bank_branch_name
             || l_charval_rec.payer_bank_acct_holder_name
             || l_charval_rec.payer_bank_acct_num
             || l_charval_rec.payer_bank_acct_name
             || l_charval_rec.payer_bank_acct_iban_num
             || l_charval_rec.payer_bank_swift_code
             || l_charval_rec.payer_bank_acct_checkdigits,
         true,
         l_valid_chars_list, l_invalid_chars_list,
         l_docErrorRec, l_docErrorTab);

     iby_build_utils_pkg.checkForInvalidChars(
         'Payer bank address',
         l_charval_rec.payer_bank_add1
             || l_charval_rec.payer_bank_add2
             || l_charval_rec.payer_bank_add3
             || l_charval_rec.payer_bank_city
             || l_charval_rec.payer_bank_county
             || l_charval_rec.payer_bank_state
             || l_charval_rec.payer_bank_country
             || l_charval_rec.payer_bank_postcode,
         true,
         l_valid_chars_list, l_invalid_chars_list,
         l_docErrorRec, l_docErrorTab);

     iby_build_utils_pkg.checkForInvalidChars(
         'Payee identification',
         l_charval_rec.payee_number
             || l_charval_rec.payee_name,
         true,
         l_valid_chars_list, l_invalid_chars_list,
         l_docErrorRec, l_docErrorTab);

     iby_build_utils_pkg.checkForInvalidChars(
         'Payee tax id',
         l_charval_rec.payee_tax_id, false,
         l_valid_chars_list, l_invalid_chars_list,
         l_docErrorRec, l_docErrorTab);

     iby_build_utils_pkg.checkForInvalidChars(
         'Payee address',
         l_charval_rec.payee_add1
             || l_charval_rec.payee_add2
             || l_charval_rec.payee_add3
             || l_charval_rec.payee_city
             || l_charval_rec.payee_county
             || l_charval_rec.payee_state
             || l_charval_rec.payee_country
             || l_charval_rec.payee_postcode,
         true,
         l_valid_chars_list, l_invalid_chars_list,
         l_docErrorRec, l_docErrorTab);

     iby_build_utils_pkg.checkForInvalidChars(
         'Payee bank/branch details',
         l_charval_rec.payee_bank_name
             || l_charval_rec.payee_bank_number
             || l_charval_rec.payee_bank_branch_num
             || l_charval_rec.payee_bank_branch_name
             || l_charval_rec.payee_bank_acct_holder_name
             || l_charval_rec.payee_bank_acct_num
             || l_charval_rec.payee_bank_acct_name
             || l_charval_rec.payee_bank_acct_iban_num
             || l_charval_rec.payee_bank_swift_code
             || l_charval_rec.payee_bank_acct_checkdigits,
         true,
         l_valid_chars_list, l_invalid_chars_list,
         l_docErrorRec, l_docErrorTab);

     iby_build_utils_pkg.checkForInvalidChars(
         'Payee bank address',
         l_charval_rec.payee_bank_add1
             || l_charval_rec.payee_bank_add2
             || l_charval_rec.payee_bank_add3
             || l_charval_rec.payee_bank_city
             || l_charval_rec.payee_bank_county
             || l_charval_rec.payee_bank_state
             || l_charval_rec.payee_bank_country
             || l_charval_rec.payee_bank_postcode,
         true,
         l_valid_chars_list, l_invalid_chars_list,
         l_docErrorRec, l_docErrorTab);

     /*
      * Insert errors into IBY_TRANSACTION_ERRORS table.
      */
     IF (l_docErrorTab.COUNT > 0) THEN

         l_valid := 1;
         IBY_VALIDATIONSETS_PUB.insert_transaction_errors(
             p_is_online_val, l_docErrorTab);

     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'EXIT');

     END IF;
     -- Return the validation result
     x_result := l_valid;

 END performCharacterValidation;

/*--------------------------------------------------------------------
 | NAME:
 |     validate_uri_using_modulus10
 |
 | PURPOSE:
 |     Bug 5569624 : This procedure validates the unique
 |     remittance identifier.
 |     The code is picked up from /jedev/11.5/je/resource/JE.pld
 |
 | PARAMETERS:
 |     IN
 |      s - Unique remittance identifier
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |     Bug 5569624: Danish unique remittance identifier validation
 *---------------------------------------------------------------------*/

PROCEDURE validate_uri_using_modulus10(s IN VARCHAR2,
     x_valResult   OUT NOCOPY BOOLEAN,
     x_docErrorRec IN OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE)
IS

   weight number := 0;
   check_digit number := 0;
   c number;

   l number ;
   l_error_msg VARCHAR2(2000);

BEGIN

   l := length(s);

   IF l > 0 THEN

      weight := mod(l + 1, 2) + 1;

      FOR i IN 1 .. l LOOP
        c := substr(s, i, 1);

        IF c BETWEEN '0' AND '9' THEN /* Check only digits. */

          check_digit := check_digit + mod(weight * to_number(c), 10) +
                                trunc((weight * to_number(c)) / 10);
          IF i < l THEN
                weight := mod(weight, 2) + 1;
          END IF;
        END IF;
      END LOOP;

      IF mod(check_digit, 10) <> 0 THEN
         IBY_VALIDATIONSETS_PUB.retrieveErrorMSG ('UNIQUE_REMIT_ID_CODE',
             'IBY_VALID_OBJ_INVALID', l_error_msg);
         x_docErrorRec.error_message := l_error_msg;
         x_docErrorRec.error_code := 'IBY_VALID_OBJ_INVALID';
	 x_valResult := FALSE;
      ELSE
         x_valResult := TRUE;
      END IF;

   ELSE
       x_valResult := TRUE;
   END IF;

END validate_uri_using_modulus10;


/*--------------------------------------------------------------------
 | NAME:
 |     VALIDATE_BANK_CHARGE_BEARER
 |
 | PURPOSE:
 |     Checking that Bank Charge Bearer is equal to 'L' (corresponding value in
 |     FND_LOOKUPS is 'SLEV') at document level
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

 PROCEDURE VALIDATE_BANK_CHARGE_BEARER(
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

BEGIN
     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     IBY_VALIDATIONSETS_PUB.evaluateCondition(
          'BANK_CHARGE_BEARER',
	  l_document_rec.bank_charge_bearer,
	  'STRIS',
          'L',
          null,
          l_valResult,
          l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END VALIDATE_BANK_CHARGE_BEARER;


/*--------------------------------------------------------------------
 | NAME:
 |     VALIDATE_PAYEE_BIC
 |
 | PURPOSE:
 |     Checking that Payee BIC is not null at document level
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
 PROCEDURE VALIDATE_PAYEE_BIC(
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)

 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     IBY_VALIDATIONSETS_PUB.evaluateCondition(
          'EXT_EFT_SWIFT_CODE',
	  l_document_rec.ext_eft_swift_code,
	  'NOTNULL',
          null,
          null,
          l_valResult,
          l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END VALIDATE_PAYEE_BIC;



/*--------------------------------------------------------------------
 | NAME:
 |     VALIDATE_PAYEE_IBAN
 |
 | PURPOSE:
 |     Checking that Payee IBAN is not null at document level
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
 PROCEDURE VALIDATE_PAYEE_IBAN(
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)

 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

BEGIN
-- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     IBY_VALIDATIONSETS_PUB.evaluateCondition(
          'EXT_BANK_ACC_IBAN',
	  l_document_rec.ext_bank_acc_iban,
	  'NOTNULL',
          null,
          null,
          l_valResult,
          l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END VALIDATE_PAYEE_IBAN;


/*--------------------------------------------------------------------
 | NAME:
 |     VALIDATE_PAYER_IBAN
 |
 | PURPOSE:
 |     Checking that Payer BIC is not null at Payment level
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
PROCEDURE VALIDATE_PAYER_IBAN(
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_payment_rec IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

BEGIN
-- Initializing the payment record
     IBY_VALIDATIONSETS_PUB.initPaymentData(p_payment_id,l_payment_rec);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_payment_id;
     l_docErrorRec.transaction_type := 'PAYMENT';
     l_docErrorRec.calling_app_doc_unique_ref1 := p_payment_id;

     -- Validate transaction reference
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
          'INT_BANK_ACC_IBAN',
	  l_payment_rec.int_bank_account_iban,
	  'NOTNULL',
          null,
          null,
          l_valResult,
          l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END VALIDATE_PAYER_IBAN;


/*--------------------------------------------------------------------
 | NAME:
 |     VALIDATE_PAYER_ADDRESS
 |
 | PURPOSE:
 |     Checking that Payer Address is not null at Payment level
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
 PROCEDURE VALIDATE_PAYER_ADDRESS(
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_payment_rec IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

BEGIN
-- Initializing the payment record
     IBY_VALIDATIONSETS_PUB.initPaymentData(p_payment_id,l_payment_rec);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_payment_id;
     l_docErrorRec.transaction_type := 'PAYMENT';
     l_docErrorRec.calling_app_doc_unique_ref1 := p_payment_id;

     -- Validate transaction reference
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
          'PARTY_ADDRESS_LINE1',
	  l_payment_rec.party_address_line1,
	  'NOTNULL',
          null,
          null,
          l_valResult,
          l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     /* Commenting City Validation w.r.t SEPA Credit Transfer 3.3 Bug 9437357*/
     /*IBY_VALIDATIONSETS_PUB.evaluateCondition(
          'PARTY_ADDRESS_CITY',
	  l_payment_rec.party_address_city,
	  'NOTNULL',
          null,
          null,
          l_valResult,
          l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;*/

     /*IBY_VALIDATIONSETS_PUB.evaluateCondition(
          'PARTY_ADDRESS_POSTAL_CODE',
	  l_payment_rec.party_address_postal_code,
	  'NOTNULL',
          null,
          null,
          l_valResult,
          l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;*/

     /*IBY_VALIDATIONSETS_PUB.evaluateCondition(
          'PMT_PAYER_LE_COUNTRY',
	  l_payment_rec.pmt_payer_le_country,
	  'NOTNULL',
          null,
          null,
          l_valResult,
          l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;*/

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

 END VALIDATE_PAYER_ADDRESS;

/*--------------------------------------------------------------------
 | NAME:
 |     xxno_chk_mod_10_11
 |
 | PURPOSE:
 |     Bug 5571714: This procedure validates the KID code. This
 |     code is picked up from /jedev/xxno/11.5/admin/sql/XXNOEC04.sql
 |
 | PARAMETERS:
 |     IN
 |      p_kid_nr - Unique remittance identifier
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE xxno_chk_mod_10_11 (
     p_kid_nr  IN  varchar2,
     x_valResult   OUT NOCOPY BOOLEAN,
     x_docErrorRec IN OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE)
 IS
      v_invoice_id  varchar2(50);
      v_kid_nr      varchar2(50);
      e_kid_feil    exception;
      v_kid         varchar2(25);
      v_kid_lengde  number(3);
      v_sum_11      number := 0;
      v_rest_11     number := 0;
      v_status_11   number := 0;
      v_sum_10      number := 0;
      v_rest_10     number := 0;
      v_status_10   number := 0;
      v_Weight      number := 2;
      v_Prod        number := 0;
      v_ProdDigit1  number := 0;
      v_ProdDigit2  number := 0;
      l_error_msg VARCHAR2(2000);

 BEGIN

        v_kid_lengde := 25;
	v_kid_nr := p_kid_nr;
        /* Controls the length of v_kid_nr */
        IF length(v_kid_nr) > v_kid_lengde THEN
          v_status_11:=1;
          v_status_10:=1;
          raise e_kid_feil;
        END IF;
	SELECT lpad(v_kid_nr,v_kid_lengde,0)
          INTO v_kid
          FROM dual;
--        uni_lpad_p(v_kid_nr, v_kid_lengde, v_kid);
        /* Modulus 10 control */
        /* Calculates product and digitsum for each digit,
           from right towards left */
        FOR i IN REVERSE 1..24 LOOP
          v_Prod       := TO_NUMBER(SUBSTR(v_kid,i,1)) * v_Weight;
          v_ProdDigit1 := TO_NUMBER(SUBSTR(TO_CHAR(v_Prod),1,1));
          if LENGTH(TO_CHAR(v_Prod)) = 2 then
            v_ProdDigit2 := TO_NUMBER(SUBSTR(TO_CHAR(v_Prod),2,1));
          else
            v_ProdDigit2 := 0;
          end if;
          v_sum_10 := v_sum_10 + v_ProdDigit1 + v_ProdDigit2;
        /* Alternates weighting between 1 and 2 */
          IF    v_Weight  = 2 THEN
            v_Weight := 1;
          ELSE
            v_Weight := 2;
          END IF;
        END LOOP;
        /* calculate mod 10 of v_sum_10 */
        WHILE v_sum_10 > 10 loop
          v_sum_10 := v_sum_10 - 10;
        END LOOP;
        v_rest_10 := 10 - v_sum_10;
        /* is residual unlike controldigit, the kid_nr is invalid */
        if ((substr(v_kid,25,1)) <> '-') then
          if (to_number(substr(v_kid,25,1)) <> v_rest_10) then
            v_status_10 := 1;
          end if;
        elsif ((substr(v_kid,25,1)) = '-') then
          v_status_10 := 1;
        end if;
        /* Modulus 11 control */
        /* Calculate productsum for kidnumber */
        v_sum_11 :=   (2 * to_number(substr(v_kid,24,1))
                    + (3 * to_number(substr(v_kid,23,1)))
                    + (4 * to_number(substr(v_kid,22,1)))
                    + (5 * to_number(substr(v_kid,21,1)))
                    + (6 * to_number(substr(v_kid,20,1)))
                    + (7 * to_number(substr(v_kid,19,1)))
                    + (2 * to_number(substr(v_kid,18,1)))
                    + (3 * to_number(substr(v_kid,17,1)))
                    + (4 * to_number(substr(v_kid,16,1)))
                    + (5 * to_number(substr(v_kid,15,1)))
                    + (6 * to_number(substr(v_kid,14,1)))
                    + (7 * to_number(substr(v_kid,13,1)))
                    + (2 * to_number(substr(v_kid,12,1)))
                    + (3 * to_number(substr(v_kid,11,1)))
                    + (4 * to_number(substr(v_kid,10,1)))
                    + (5 * to_number(substr(v_kid,9,1)))
                    + (6 * to_number(substr(v_kid,8,1)))
                    + (7 * to_number(substr(v_kid,7,1)))
                    + (2 * to_number(substr(v_kid,6,1)))
                    + (3 * to_number(substr(v_kid,5,1)))
                    + (4 * to_number(substr(v_kid,4,1)))
                    + (5 * to_number(substr(v_kid,3,1)))
                    + (6 * to_number(substr(v_kid,2,1)))
                    + (7 * to_number(substr(v_kid,1,1))));
        /* calculate mod 11 of v_sum_11 */
        while v_sum_11 > 11 loop
          v_sum_11 := v_sum_11 - 11;
        end loop;
        /* is residual like 1, must the kid ends with '-' */
        if (((v_sum_11 = 1)
        and (substr(v_kid,25,1) <> '-'))
        or ((v_sum_11 <> 1)
        and (substr(v_kid,25,1) = '-'))) then
          v_status_11 := 1;
        elsif ((substr(v_kid,25,1)) <> '-') then
          v_rest_11 := 11 - v_sum_11;
        /* is residual unlike control digit, the kid_nr is invalid */
          if (to_number(substr(v_kid,25,1)) <> v_rest_11) then
            v_status_11 := 1;
          end if;
        end if;
        if (v_status_11 = 1 and v_status_10 = 1) then
          raise e_kid_feil;
        end if;
	x_valResult := TRUE;
    exception
      when e_kid_feil then
         IBY_VALIDATIONSETS_PUB.retrieveErrorMSG ('UNIQUE_REMIT_ID_CODE',
             'IBY_VALID_OBJ_INVALID', l_error_msg);
         x_docErrorRec.error_message := l_error_msg;
         x_docErrorRec.error_code := 'IBY_VALID_OBJ_INVALID';
	 x_valResult := FALSE;
       when others then
         IBY_VALIDATIONSETS_PUB.retrieveErrorMSG ('UNIQUE_REMIT_ID_CODE',
             'IBY_VALID_OBJ_INVALID', l_error_msg);
         x_docErrorRec.error_message := l_error_msg;
         x_docErrorRec.error_code := 'IBY_VALID_OBJ_INVALID';
	 x_valResult := FALSE;
END xxno_chk_mod_10_11;


/*--------------------------------------------------------------------
 | NAME:
 |     VALIDATE_INT_BANK_ACC_CURR_IN
 |
 | PURPOSE:
 |     Validate whether Internal Bank Account currency exists in the
 |     parameter defined while assigning validation.
 |     PAYMENT LEVEL
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
 PROCEDURE VALIDATE_INT_BANK_ACC_CURR_IN (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
     IS

 l_payment_rec IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;
 l_int_bank_acct_curr varchar2(50);

BEGIN
-- Initializing the payment record
     IBY_VALIDATIONSETS_PUB.initPaymentData(p_payment_id,l_payment_rec);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_payment_id;
     l_docErrorRec.transaction_type := 'PAYMENT';
     l_docErrorRec.calling_app_doc_unique_ref1 := p_payment_id;

      IBY_VALIDATIONSETS_PUB.getParamValue(
                        p_validation_assign_id,
                        p_validation_set_code,
                        'INT_BANK_ACCOUNT_CURR',
                         l_int_bank_acct_curr);

     -- Validate transaction reference
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
          'INT_BANK_ACCT_CURR',
	  l_payment_rec.payer_bank_acc_cur_code,
	  'STRIS',
          l_int_bank_acct_curr,
          null,
          l_valResult,
          l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

  END VALIDATE_INT_BANK_ACC_CURR_IN;


/*--------------------------------------------------------------------
 | NAME:
 |     VALIDATE_DEL_CHN_FORMAT_VALUE
 |
 | PURPOSE:
 |    Validate whether delivery channel format value exists in the
 |    parameter defined while assigning validation.
 |    DOCUMENT LEVEL
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
 PROCEDURE VALIDATE_DEL_CHN_FORMAT_VALUE (
     p_validation_assign_id  IN
         IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN
         IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id           IN
         IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER
     )IS
 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;
 l_del_chn_fmt_val varchar2(100);

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     IBY_VALIDATIONSETS_PUB.getParamValue(
                  p_validation_assign_id,
                  p_validation_set_code,
                  'DELIVERY_CHANNEL_FORMAT_VALUE',
                  l_del_chn_fmt_val);
     -- Validate transaction code
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'DOC_DEL_CHN_FMT_VAL',
         l_document_rec.delivery_chn_format_val,
         'STRIS',
         l_del_chn_fmt_val,
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
         -- Inserting errors into IBY_TRANSACTION_ERRORS
         IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

  END VALIDATE_DEL_CHN_FORMAT_VALUE;

/*--------------------------------------------------------------------
 | NAME:
 |     VALIDATE_MAX_PAYMENT_AMOUNT
 |
 | PURPOSE:
 |    Validates the payment amount against the maximum limit defined
 |    with parameter while assigning validation.
 |    PAYMENT LEVEL
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
 PROCEDURE VALIDATE_MAX_PAYMENT_AMOUNT (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
     IS

 l_payment_rec IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;
 l_payment_amount varchar2(50);

BEGIN
-- Initializing the payment record
     IBY_VALIDATIONSETS_PUB.initPaymentData(p_payment_id,l_payment_rec);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_payment_id;
     l_docErrorRec.transaction_type := 'PAYMENT';
     l_docErrorRec.calling_app_doc_unique_ref1 := p_payment_id;

      IBY_VALIDATIONSETS_PUB.getParamValue(
                        p_validation_assign_id,
                        p_validation_set_code,
                        'MAX_PAYMENT_AMOUNT',
                         l_payment_amount);

     -- Validate transaction reference
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
          'PMT_AMOUNT',
	  l_payment_rec.pmt_amount,
	  'LESSEQUAL',
          null,
          l_payment_amount,
          l_valResult,
          l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

  END VALIDATE_MAX_PAYMENT_AMOUNT;

/*--------------------------------------------------------------------
 | NAME:
 |     VALIDATE_DOC_PMT_CURR
 |
 | PURPOSE:
 |    Validate whether document payment currency exists in the
 |    parameter defined while assigning validation.
 |    DOCUMENT LEVEL
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
 PROCEDURE VALIDATE_DOC_PMT_CURR (
     p_validation_assign_id  IN
         IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN
         IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id           IN
         IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER
     )IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;
 l_doc_pmt_curr varchar2(100);

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     IBY_VALIDATIONSETS_PUB.getParamValue(
                  p_validation_assign_id,
                  p_validation_set_code,
                  'DOCUMENT_PAYMENT_CURR',
                  l_doc_pmt_curr);
     -- Validate transaction code
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'DOCUMENT_PAY_CURRENCY',
         l_document_rec.document_pay_currency,
         'STRIS',
         l_doc_pmt_curr,
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
         -- Inserting errors into IBY_TRANSACTION_ERRORS
         IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Return the Validation Result
     x_result := l_valid;


  END VALIDATE_DOC_PMT_CURR;


/*--------------------------------------------------------------------
 | NAME:
 |     VALIDATE_PAYEE_BRC_COUNTRY_IN
 |
 | PURPOSE:
 |    Validate whether payee branch country exists in the list of
 |    values given with the parameter while assigning validation.
 |    DOCUMENT LEVEL
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
 PROCEDURE VALIDATE_PAYEE_BRC_COUNTRY_IN (
     p_validation_assign_id  IN
         IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN
         IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id           IN
         IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER
     )IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;
 l_payee_brc_country_list varchar2(500);

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     IBY_VALIDATIONSETS_PUB.getParamValue(
                  p_validation_assign_id,
                  p_validation_set_code,
                  'DOCUMENT_PAYEE_BRANCH_COUNTRY',
                  l_payee_brc_country_list);
     -- Validate transaction code
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'EXT_BANK_BRANCH_COUNTRY',
         l_document_rec.ext_bank_branch_country,
         'INSET',
         l_payee_brc_country_list,
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
         -- Inserting errors into IBY_TRANSACTION_ERRORS
         IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

  END VALIDATE_PAYEE_BRC_COUNTRY_IN;

/*--------------------------------------------------------------------
 | NAME:
 |     VALIDATE_DEL_CHN_NOT_IN
 |
 | PURPOSE:
 |    Validates whether delivery channel format value doesnt exists in
 |    the list of values with the parameter while assigning validation.
 |    DOCUMENT LEVEL
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
 PROCEDURE VALIDATE_DEL_CHN_NOT_IN (
     p_validation_assign_id  IN
         IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code   IN
         IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id           IN
         IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE,
     p_is_online_val         IN VARCHAR2,
     x_result                OUT NOCOPY NUMBER
     ) IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;
 l_del_chn_fmt_val_list varchar2(500);

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     IBY_VALIDATIONSETS_PUB.getParamValue(
                  p_validation_assign_id,
                  p_validation_set_code,
                  'DELIVERY_CHANNEL_FORMAT_VALUE',
                  l_del_chn_fmt_val_list);
     -- Validate transaction code
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'DOC_DEL_CHN_FMT_VAL',
         l_document_rec.delivery_chn_format_val,
         'NOTINSET',
         l_del_chn_fmt_val_list,
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
         -- Inserting errors into IBY_TRANSACTION_ERRORS
         IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
        l_valid := 1;
     END IF;

     -- Return the Validation Result
     x_result := l_valid;

  END VALIDATE_DEL_CHN_NOT_IN;


  /*--------------------------------------------------------------------
 | NAME:
 |     VALIDATE_FIN_URI
 |
 | PURPOSE:
 |    Validates the combination of URI and URI check digit for Finland
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
PROCEDURE VALIDATE_FIN_URI (
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
     p_document_id        IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER) IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;
 l_transaction_error_id IBY_TRANSACTION_ERRORS.transaction_error_id%TYPE;
 l_message fnd_new_messages.message_text%TYPE;
 l_uri_flag BOOLEAN := false;
 l_ck_flag BOOLEAN := false;

 BEGIN

     -- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

-- URI should have only digits

     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'UNIQUE_REMIT_ID_CODE',
         trim(l_document_rec.unique_remit_id_code),
         'DIGITSONLY',
         null,
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        l_uri_flag := TRUE;
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
         -- Inserting errors into IBY_TRANSACTION_ERRORS
         IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
        l_valid := 1;
     END IF;

-- URI check digit should have only digits

     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'URI_CHECK_DIGIT',
         trim(l_document_rec.URI_CHECK_DIGIT),
         'DIGITSONLY',
         null,
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        l_ck_flag := TRUE;
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
         -- Inserting errors into IBY_TRANSACTION_ERRORS
         IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
        l_valid := 1;
     END IF;

-- Length of URI should be 20 or less

     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'UNIQUE_REMIT_ID_CODE',
         trim(l_document_rec.unique_remit_id_code),
         'MAXLENGTH',
         null,
         20,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
         -- Inserting errors into IBY_TRANSACTION_ERRORS
         IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
        l_valid := 1;
     END IF;

--Combination of URI and check digit should be valid
     IF(l_document_rec.unique_remit_id_code is not null
        and l_document_rec.URI_CHECK_DIGIT is not null
        AND l_ck_flag=FALSE
        AND l_uri_flag= FALSE)
     then
     IF(FIN_URI_CHECK_DIGIT_VAL(lpad(trim(l_document_rec.unique_remit_id_code),20,'0'), lpad(trim(l_document_rec.URI_CHECK_DIGIT),2,'0')) = false)
     THEN
        l_docErrorRec.error_message  :='';

       FND_MESSAGE.SET_NAME('IBY', 'IBY_FIN_URI_CD_VAL_FAIL');
       l_message := fnd_message.get;


	l_docErrorRec.error_message := l_message;
	l_docErrorRec.error_code := 'IBY_VALID_OBJ_INVALID';


         SELECT
            IBY_TRANSACTION_ERRORS_S.NEXTVAL
        INTO
            l_transaction_error_id
        FROM
            DUAL
        ;

        l_docErrorRec.transaction_error_id := l_transaction_error_id;

        INSERT INTO IBY_TRXN_ERROR_TOKENS
        (TRANSACTION_ERROR_ID, TOKEN_NAME, TOKEN_VALUE, LOOKUP_TYPE_SOURCE,
         CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN, OBJECT_VERSION_NUMBER)
        VALUES
        (l_transaction_error_id, 'ERR_OBJECT', 'URI_CHECK_DIGIT', 'IBY_VALIDATION_FIELDS',
         fnd_global.user_id, sysdate, fnd_global.user_id, sysdate,
         fnd_global.user_id, 1);


	 IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
         -- Inserting errors into IBY_TRANSACTION_ERRORS
         IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
        l_valid :=1;
     END IF;
     end if;

     -- Return the Validation Result
     x_result := l_valid;

  END VALIDATE_FIN_URI;

FUNCTION FIN_URI_CHECK_DIGIT_VAL( uri IBY_DOCS_PAYABLE_ALL.unique_remittance_identifier%TYPE,
				   uri_check_digit IBY_DOCS_PAYABLE_ALL.URI_CHECK_DIGIT%TYPE)
				   RETURN BOOLEAN is
l_flag BOOLEAN := false;
l_ck  IBY_DOCS_PAYABLE_ALL.URI_CHECK_DIGIT%TYPE;
BEGIN
IF uri_check_digit = '00' THEN
l_ck := '10';
ELSE
l_ck := uri_check_digit;
END IF;

if(
to_number(l_ck)=
10-mod((
  to_number(substr(uri,19,1))*7+
  to_number(substr(uri,18,1))*3+
  to_number(substr(uri,17,1))*1+
  to_number(substr(uri,16,1))*7+
  to_number(substr(uri,15,1))*3+
  to_number(substr(uri,14,1))*1+
  to_number(substr(uri,13,1))*7+
  to_number(substr(uri,12,1))*3+
  to_number(substr(uri,11,1))*1+
  to_number(substr(uri,10,1))*7+
  to_number(substr(uri,9,1))*3+
  to_number(substr(uri,8,1))*1+
  to_number(substr(uri,7,1))*7+
  to_number(substr(uri,6,1))*3+
  to_number(substr(uri,5,1))*1+
  to_number(substr(uri,4,1))*7+
  to_number(substr(uri,3,1))*3+
  to_number(substr(uri,2,1))*1+
  to_number(substr(uri,1,1))*7),10) and
  to_number(substr(uri,20,1))=to_number(uri_check_digit)) then
  l_flag:= true;
  end if;
return l_flag;
END FIN_URI_CHECK_DIGIT_VAL;


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
     --
     -- Writing debug text to the concurrent manager log file.
     --
     iby_build_utils_pkg.print_debuginfo(p_module, p_debug_text);

 END print_debuginfo;

/* SEPA Credit Transfer Enhancement*/
PROCEDURE VALIDATE_INV_LEGAL_ENTITY_ID(
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_document_id           IN IBY_DOCS_PAYABLE_ALL.document_payable_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_document_rec IBY_VALIDATIONSETS_PUB.documentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          print_debuginfo('VALIDATE_INV_LEGAL_ENTITY_ID', 'ENTER');
     END IF;
-- Initializing the document record
     IBY_VALIDATIONSETS_PUB.initDocumentData(p_document_id,l_document_rec,p_is_online_val);

     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_document_id;
     l_docErrorRec.transaction_type := 'DOCUMENT_PAYABLE';
     --l_docErrorRec.calling_app_id := l_document_rec.calling_app_id;
     --l_docErrorRec.pay_proc_trxn_type_code := l_document_rec.pay_proc_trxn_type_cd;
     --l_docErrorRec.calling_app_doc_unique_ref1 := l_document_rec.calling_app_doc_id1;

     -- Validate Payer Tax Registration Number at Invoice Level
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'INVOICE_LE_IDENTIFICATION',
         l_document_rec.payer_tax_registration_number,
         'NOTNULL',
         null,
         null,
         l_valResult,
         l_docErrorRec);

     IF (l_valResult = FALSE) THEN
        -- If we reached here means Legal Entity Registration Does not exists for which invoice is created
        -- Validate Invoice Legal Entity Registration Number
        IBY_VALIDATIONSETS_PUB.evaluateCondition(
         'INVOICE_LE_IDENTIFICATION',
         l_document_rec.payer_registration_number,
         'NOTNULL',
         null,
         null,
         l_valResult,
         l_docErrorRec);

        IF (l_valResult = FALSE) THEN
           IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
           l_valid := 1;
        END IF;
     END IF;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          print_debuginfo('VALIDATE_INV_LEGAL_ENTITY_ID', 'EXIT');
     END IF;
 END VALIDATE_INV_LEGAL_ENTITY_ID;

PROCEDURE VALIDATE_PAYER_LEGAL_ENTITY_ID(
     p_validation_assign_id  IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
     p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%type,
     p_payment_id         IN IBY_PAYMENTS_ALL.payment_id%type,
     p_is_online_val      IN VARCHAR2,
     x_result             OUT NOCOPY NUMBER)
 IS

 l_payment_rec IBY_VALIDATIONSETS_PUB.paymentRecType;
 l_valResult BOOLEAN;
 l_valid NUMBER := 0;
 l_docErrorTab IBY_VALIDATIONSETS_PUB.docErrorTabType;
 l_docErrorRec IBY_TRANSACTION_ERRORS%ROWTYPE;

BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          print_debuginfo('VALIDATE_PAYER_LEGAL_ENTITY_ID', 'ENTER');
     END IF;
-- Initializing the payment record
     IBY_VALIDATIONSETS_PUB.initPaymentData(p_payment_id,l_payment_rec);
     l_docErrorRec.validation_set_code := p_validation_set_code;
     l_docErrorRec.transaction_id := p_payment_id;
     l_docErrorRec.transaction_type := 'PAYMENT';
     l_docErrorRec.calling_app_doc_unique_ref1 := p_payment_id;

     -- Validate Payer Legal Entity Tax Registration Number
     IBY_VALIDATIONSETS_PUB.evaluateCondition(
          'PAYER_LE_IDENTIFICATION',
	  l_payment_rec.PAYER_TAX_REGISTRATION_NUM,
	  'NOTNULL',
          null,
          null,
          l_valResult,
          l_docErrorRec);

     IF (l_valResult = FALSE) THEN
     -- Validate Payer Legal Entity Registration Number
         IBY_VALIDATIONSETS_PUB.evaluateCondition(
          'PAYER_LE_IDENTIFICATION',
	  l_payment_rec.PAYER_LE_REGISTRATION_NUM,
	  'NOTNULL',
          null,
          null,
          l_valResult,
          l_docErrorRec);
          IF (l_valResult = FALSE) THEN
             IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(l_docErrorRec, l_docErrorTab);
             l_valid := 1;
          END IF;
     END IF;

     -- Inserting errors into IBY_TRANSACTION_ERRORS
     IF (l_valid = 1) THEN
        IBY_VALIDATIONSETS_PUB.insert_transaction_errors(p_is_online_val,l_docErrorTab);
     END IF;

     -- Return the Validation Result
     x_result := l_valid;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          print_debuginfo('VALIDATE_PAYER_LEGAL_ENTITY_ID', 'EXIT');
     END IF;
 END VALIDATE_PAYER_LEGAL_ENTITY_ID;

 END IBY_VALIDATIONSETS_CALLS_PUB;

/
