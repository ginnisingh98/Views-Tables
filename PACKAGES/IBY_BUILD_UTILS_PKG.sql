--------------------------------------------------------
--  DDL for Package IBY_BUILD_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_BUILD_UTILS_PKG" AUTHID CURRENT_USER AS
/*$Header: ibybluts.pls 120.12.12010000.3 2009/02/25 10:13:40 bkjain ship $*/

 --
 -- Payment profile record
 --
 TYPE pmtProfRecType IS RECORD (
     profile_id   IBY_DOCS_PAYABLE_ALL.payment_profile_id%TYPE
     );

 --
 -- Payment profiles table
 --
 TYPE pmtProfTabType IS TABLE OF pmtProfRecType
     INDEX BY BINARY_INTEGER;

 --
 -- Utility record to map a payment profile id on a payment instruction
 -- to a payment profile code on instr creation rules record.
 --
 -- Multiple payment profile ids can be mapped to the same payment
 -- profile code.
 --
 TYPE profileIdToCodeMap IS RECORD (
     pmt_profile_id     IBY_PAYMENT_PROFILES.payment_profile_id%TYPE,
     pmt_profile_cd     IBY_PAYMENT_PROFILES.system_profile_code%TYPE
     );

 --
 -- Table of payment profile code maps.
 --
 TYPE profileIdToCodeMapTabType IS TABLE OF profileIdToCodeMap
     INDEX BY BINARY_INTEGER;


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
 PROCEDURE print_debuginfo(p_module IN VARCHAR2,
     p_debug_text  IN VARCHAR2,
     p_debug_level IN VARCHAR2  DEFAULT FND_LOG.LEVEL_STATEMENT
     );

/*--------------------------------------------------------------------
 | NAME:
 |     printXMLClob
 |
 | PURPOSE:
 |     Prints out the XML data contained within the given clob; to be
 |     used for testing purposes.
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
 PROCEDURE printXMLClob(
     p_xml_clob IN CLOB);

/*--------------------------------------------------------------------
 | NAME:
 |     checkForInvalidChars
 |
 | PURPOSE:
 |     Given an input string and a string of invalid characters, this
 |     procedure checks if any of the invalid characters are present
 |     in the given input string.
 |
 |     If any of the invalid characters are found, an error message is
 |     inserted into the error table identifying the invalid character.
 |
 |     If no invalid characters are found in the input string, this
 |     procedure simply returns.
 |
 | PARAMETERS:
 |     IN
 |     p_fieldName  - The name  of the input field (used for logging)
 |     p_fieldValue - The value of the input field
 |     p_isComposite - Indidicates that the field is a composite
 |                     field created by appending multiple individual
 |                     fields. For composite fields, the field value
 |                     will not be printed in the error message.
 |     p_invalid_chars_list - List of invalid characters that
 |                    should not be present in the field value
 |     OUT
 |     x_docErrorRec - Error message record. This should contain the
 |                     document id when coming into this method.
 |     x_docErrorTab - Error messages table. An error message will be
 |                     added to this table if the input field value
 |                     contains an invalid char.
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE checkForInvalidChars(
         p_fieldName          IN VARCHAR2,
         p_fieldValue         IN VARCHAR2,
         p_isComposite        IN BOOLEAN,
         p_validCharsList     IN VARCHAR2,
         p_invalidCharsList   IN VARCHAR2,
         x_docErrorRec        IN OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
         x_docErrorTab        IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.
                                                docErrorTabType
         );

/*--------------------------------------------------------------------
 | NAME:
 |     getChar
 |
 | PURPOSE:
 |     Returns the character at a given position of a given string.
 |     Similar to ChatAt(index) in Java.
 |
 |     Note that in PLSQL indexes are 1 based i.e., the very first
 |     character in the string has index 1 (as opposed to 0 based
 |     indexes in C and Java).
 |
 |     Therefore, if the given string is 'I am the walrus', then
 |     getChar(str, 10) will return 'w'.
 |
 |     NULL will be returned if the index is out-of-bounds.
 |
 | PARAMETERS:
 |     IN
 |     p_string - The name  of the input field (used for logging)
 |     p_index - The value of the input field
 |
 |     OUT
 |
 | RETURNS:
 |
 |     VARCHAR2(1) - the character at the given index on the given string
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 FUNCTION getChar(
         p_string      IN VARCHAR2,
         p_index       IN VARCHAR2
         )
         RETURN VARCHAR2;

/*--------------------------------------------------------------------
 | NAME:
 |     diffStrings
 |
 | PURPOSE:
 |     Given two strings, this method performs a diff on them
 |     and returns their differences.
 |
 |     The two args are not expected to be completely arbitary;
 |     instead arg2 is expected to be similar to arg1 with some
 |     differences. For this reason, both strings are expected to
 |     be of the same length.
 |
 |     Whenever there are differences, the value from arg1 is added
 |     to the diff list. The value from arg2 is ignored.
 |
 | PARAMETERS:
 |     IN
 |     p_originalString - The original string
 |     p_compareString  - The changed string
 |
 |     OUT
 |
 | RETURNS:
 |
 |     VARCHAR2 - the difference between the two strings
 |     NULL will be returned if both strings are the same
 |
 | NOTES:
 |     Comparison between the two strings will only take place uptil the
 |     length of the original string.
 |
 *---------------------------------------------------------------------*/
 FUNCTION diffStrings(
         p_originalString      IN VARCHAR2,
         p_compareString       IN VARCHAR2
         )
         RETURN VARCHAR2;

/*--------------------------------------------------------------------
 | NAME:
 |     createErrorRecord
 |
 | PURPOSE:
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
 PROCEDURE createErrorRecord(
     p_trxn_type    IN IBY_TRANSACTION_ERRORS.transaction_type%TYPE,
     p_doc_id       IN IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE,
     p_doc_status   IN IBY_DOCS_PAYABLE_ALL.document_status%TYPE,
     p_ca_id        IN IBY_DOCS_PAYABLE_ALL.calling_app_id%TYPE,
     p_ca_doc_id1    IN IBY_DOCS_PAYABLE_ALL.
                           calling_app_doc_unique_ref1%TYPE,
     p_ca_doc_id2    IN IBY_DOCS_PAYABLE_ALL.
                           calling_app_doc_unique_ref2%TYPE,
     p_ca_doc_id3    IN IBY_DOCS_PAYABLE_ALL.
                           calling_app_doc_unique_ref3%TYPE,
     p_ca_doc_id4    IN IBY_DOCS_PAYABLE_ALL.
                           calling_app_doc_unique_ref4%TYPE,
     p_ca_doc_id5    IN IBY_DOCS_PAYABLE_ALL.
                           calling_app_doc_unique_ref5%TYPE,
     p_pp_tt_cd     IN IBY_DOCS_PAYABLE_ALL.pay_proc_trxn_type_code%TYPE,
     x_docErrorRec  IN OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
     x_docTokenTab  IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.trxnErrTokenTabType,
     p_rel_doc_id   IN IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE
                           DEFAULT NULL,
     p_error_code   IN VARCHAR2 DEFAULT NULL
     );

/*--------------------------------------------------------------------
 | NAME:
 |     createPmtErrorRecord
 |
 | PURPOSE:
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
 PROCEDURE createPmtErrorRecord(
     p_pmt_id        IN IBY_PAYMENTS_ALL.payment_id%TYPE,
     p_pmt_status    IN IBY_PAYMENTS_ALL.
                            payment_status%TYPE,
     p_error_code    IN IBY_TRANSACTION_ERRORS.error_code%TYPE
                           DEFAULT NULL,
     p_error_msg     IN IBY_TRANSACTION_ERRORS.error_message%TYPE
                           DEFAULT NULL,
     x_docErrorRec   IN OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE
     );

/*--------------------------------------------------------------------
 | NAME:
 |     getProfListFromProfileDrivers
 |
 | PURPOSE:
 |     Derives the payment profile for the given (payment method,
 |     payment format, org, payment currency, internal bank acct)
 |     combination.
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
 | NOTES: Mark For Removal
 |
 *---------------------------------------------------------------------*/
 PROCEDURE getProfListFromProfileDrivers(
     p_pmt_method_cd     IN IBY_DOCS_PAYABLE_ALL.payment_method_code%TYPE,
     p_org_id            IN IBY_DOCS_PAYABLE_ALL.org_id%TYPE,
     p_org_type          IN IBY_DOCS_PAYABLE_ALL.org_type%TYPE,
     p_pmt_currency      IN IBY_DOCS_PAYABLE_ALL.payment_currency_code%TYPE,
     p_int_bank_acct_id  IN IBY_DOCS_PAYABLE_ALL.internal_bank_account_id%TYPE,
     x_profilesTab       IN OUT NOCOPY pmtProfTabType
     );


/*--------------------------------------------------------------------
 | NAME:
 |     getProfListFromProfileDrivers
 |
 | PURPOSE:
 |     Derives the payment profile for the given (payment method,
 |     payment format, org, payment currency, internal bank acct)
 |     combination.
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
 PROCEDURE getProfListFromProfileDrivers(
     p_pmt_method_cd     IN IBY_DOCS_PAYABLE_ALL.payment_method_code%TYPE,
     p_org_id            IN IBY_DOCS_PAYABLE_ALL.org_id%TYPE,
     p_org_type          IN IBY_DOCS_PAYABLE_ALL.org_type%TYPE,
     p_pmt_currency      IN IBY_DOCS_PAYABLE_ALL.payment_currency_code%TYPE,
     p_int_bank_acct_id  IN IBY_DOCS_PAYABLE_ALL.internal_bank_account_id%TYPE,
     p_profile_id       IN OUT NOCOPY IBY_DOCS_PAYABLE_ALL.payment_profile_id%TYPE,
     p_valid_flag       OUT NOCOPY VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     getProfileMap
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
 PROCEDURE getProfileMap(
     x_profileMap     IN OUT NOCOPY profileIdToCodeMapTabType
     );

/*--------------------------------------------------------------------
 | NAME:
 |     getProfileCodeFromId
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
 FUNCTION getProfileCodeFromId(
     p_profile_id     IN IBY_PAY_INSTRUCTIONS_ALL.payment_profile_id%TYPE,
     p_profileMap     IN profileIdToCodeMapTabType
     ) RETURN VARCHAR2;

/*--------------------------------------------------------------------
 | NAME:
 |     printWrappedString
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
 PROCEDURE printWrappedString(
     p_string     IN VARCHAR2
     );

/*--------------------------------------------------------------------
 | NAME:
 |     inactivateOldErrors
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
 PROCEDURE inactivateOldErrors(
     p_trxn_id    IN IBY_TRANSACTION_ERRORS.transaction_id%TYPE,
     p_trxn_type  IN IBY_TRANSACTION_ERRORS.transaction_type%TYPE
     );

 /*--------------------------------------------------------------------
 | NAME:
 |     resetPaymentErrors
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
 PROCEDURE resetPaymentErrors(
     p_payment_request_id  IN IBY_PAY_SERVICE_REQUESTS.
                                  payment_service_request_id%TYPE
     );

/*--------------------------------------------------------------------
 | NAME:
 |     resetDocumentErrors
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
 PROCEDURE resetDocumentErrors(
     p_payment_request_id  IN IBY_PAY_SERVICE_REQUESTS.
                                  payment_service_request_id%TYPE
     );

/*--------------------------------------------------------------------
 | NAME:
 |     resetPaymentInstructionErrors
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
 PROCEDURE resetPaymentInstructionErrors(
     p_instr_id  IN IBY_PAY_INSTRUCTIONS_ALL.
                        payment_instruction_id%TYPE
     );

END IBY_BUILD_UTILS_PKG;

/
