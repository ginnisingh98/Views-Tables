--------------------------------------------------------
--  DDL for Package Body IBY_BUILD_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_BUILD_UTILS_PKG" AS
/*$Header: ibyblutb.pls 120.25.12010000.7 2009/02/27 14:29:29 visundar ship $*/

 /*
  * Declare global variables
  */
 G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBY_BUILD_UTILS_PKG';

 --
 -- List of document statuses that are used / set in this
 -- module.
 --
 DOC_STATUS_VALIDATED    CONSTANT VARCHAR2(100) := 'VALIDATED';
 DOC_STATUS_FAIL_VALID   CONSTANT VARCHAR2(100) := 'FAILED_VALIDATION';
 DOC_STATUS_PAY_CREATED  CONSTANT VARCHAR2(100) := 'PAYMENT_CREATED';
 DOC_STATUS_CA_FAILED    CONSTANT VARCHAR2(100) := 'FAILED_BY_CALLING_APP';
 DOC_STATUS_RELN_FAIL    CONSTANT VARCHAR2(100) := 'FAILED_BY_RELATED_DOCUMENT';
 DOC_STATUS_PAY_VAL_FAIL CONSTANT VARCHAR2(100) := 'PAYMENT_FAILED_VALIDATION';
 DOC_STATUS_FAIL_BY_REJLVL CONSTANT VARCHAR2(100)
                                                := 'FAILED_BY_REJECTION_LEVEL';

 --
 -- List of payment statuses that are used / set in this
 -- module.
 --
 PAY_STATUS_FAIL_VALID     CONSTANT VARCHAR2(100) := 'FAILED_VALIDATION';
 PAY_STATUS_CREATED        CONSTANT VARCHAR2(100) := 'CREATED';
 PAY_STATUS_CA_FAILED      CONSTANT VARCHAR2(100) := 'FAILED_BY_CALLING_APP';
 PAY_STATUS_FAIL_BY_REJLVL CONSTANT VARCHAR2(100)
                                        := 'FAILED_BY_REJECTION_LEVEL';
 PAY_STATUS_MODIFIED       CONSTANT VARCHAR2(100) := 'MODIFIED';

 --
 -- Lookups for profile applicablility types (from IBY_PMT_PROF_LOV_APL_TYPES)
 --
 APL_TYPE_ORG            CONSTANT VARCHAR2(100) := 'PAYER_ORG';
 APL_TYPE_PMT_METHOD     CONSTANT VARCHAR2(100) := 'PAYMENT_METHOD';
 APL_TYPE_PMT_CURRENCY   CONSTANT VARCHAR2(100) := 'CURRENCY_CODE';
 APL_TYPE_INT_BANK_ACCT  CONSTANT VARCHAR2(100) := 'INTERNAL_BANK_ACCOUNT';

 --
 -- List of transaction error statuses that are used / set in this
 -- module.
 --
 TRXN_ERROR_ACTIVE         CONSTANT VARCHAR2(100) := 'ACTIVE';

TYPE l_prof_der_rec_type IS RECORD(
     l_profile_id        IBY_DOCS_PAYABLE_ALL.payment_profile_id%TYPE,
     l_valid_flag       VARCHAR2(1)
);

TYPE l_prof_der_tbl_type IS TABLE OF l_prof_der_rec_type INDEX BY VARCHAR2(2000);
l_prof_der_tbl  l_prof_der_tbl_type;

TYPE l_prof_val_tbl_type IS TABLE OF VARCHAR2(2000) INDEX BY VARCHAR2(2000);
l_prof_val_tbl  l_prof_val_tbl_type;

TYPE profile_cod_tbl_type is table of IBY_PAYMENT_PROFILES.system_profile_code%TYPE index by BINARY_INTEGER;
      l_profile_cod_tbl       profile_cod_tbl_type;


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
     )
 IS
 l_default_debug_level VARCHAR2(200) := FND_LOG.LEVEL_STATEMENT;
 PRAGMA AUTONOMOUS_TRANSACTION;

 BEGIN

     /*
      * Set the debug level to the value passed in
      * (provided this value is not null).
      */
     IF (p_debug_level IS NOT NULL) THEN
         l_default_debug_level := p_debug_level;
     END IF;

     /*
      * Write immediate validation messages to the common
      * application logs. Write deferred validation messages
      * to the concurrent manager log file.
      *
      * If FND_GLOBAL.conc_request_id is -1, it implies that
      * this method has not been invoked via the concurrent
      * manager (online validation case; write to apps log).
      */
     IF (l_default_debug_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

         IF (FND_GLOBAL.conc_request_id = -1) THEN

             /*
              * OPTION I:
              * Write debug text to the common application log file.
              */
             --IBY_DEBUG_PUB.add(
             --    substr(RPAD(p_module,55) || ' : ' || p_debug_text, 0, 150),
             --    FND_LOG.G_CURRENT_RUNTIME_LEVEL,
             --    'iby.plsql.IBY_VALIDATIONSETS_PUB'
             --    );

             FND_LOG.STRING(
                 l_default_debug_level,
                 'iby.plsql.IBY_VALIDATIONSETS_PUB',
                 substr(RPAD(p_module, 55) || ' : ' || p_debug_text, 0, 150)
                 );

             /*
              * OPTION II:
              * Write debug text to DBMS output file.
              */
             --DBMS_OUTPUT.PUT_LINE(substr(RPAD(p_module,40)||' : '||
             --    p_debug_text, 0, 150));

             /*
              * OPTION III:
              * Write debug text to temporary table.
              */

             /*
              * Use this script to create a debug table.
              *
              * CREATE TABLE TEMP_IBY_LOGS(TEXT VARCHAR2(4000), TIME DATE);
              */

             /* uncomment these two lines for debugging */
             --INSERT INTO TEMP_IBY_LOGS VALUES (p_module || ': '
             --    || p_debug_text, sysdate);
             --COMMIT;

         ELSE

             /*
              * OPTION I:
              * Write debug text to the concurrent manager log file.
              */
             FND_FILE.PUT_LINE(FND_FILE.LOG, p_module || ': ' || p_debug_text);

             /*
              * OPTION II:
              * Write debug text to DBMS output file.
              */
             --DBMS_OUTPUT.PUT_LINE(substr(RPAD(p_module,40)||' : '||
             --    p_debug_text, 0, 150));

             /*
              * OPTION III:
              * Write debug text to temporary table.
              */

             /*
              * Use this script to create a debug table.
              *
              * CREATE TABLE TEMP_IBY_LOGS(TEXT VARCHAR2(4000), TIME DATE);
              */

             /* uncomment these two lines for debugging */
             --INSERT INTO TEMP_IBY_LOGS VALUES (p_module || ': '
             --    || p_debug_text, sysdate);
             --COMMIT;

         END IF; -- if not a conc request

     END IF; -- if current debug level greater than runtime debug level

 EXCEPTION
     WHEN OTHERS THEN

     ROLLBACK;

 END print_debuginfo;

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
     p_xml_clob   IN CLOB)
 IS

 l_xmlstr VARCHAR2(32767);
 l_line   VARCHAR2(2000);
 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME || '.printXMLClob';

 BEGIN

     print_debuginfo(l_module_name, 'ENTER');

     /*
      * Do not attempt to print XML clob unless it contains
      * CR-LFs.
      */
     IF (DBMS_LOB.INSTR(p_xml_clob, fnd_global.local_chr(10)) = 0) THEN

         print_debuginfo(l_module_name, 'Clob does not contain '
             || 'CR-LFs; cannot print entire XML Clob, '
             || 'printing a snippet ..'
             );

         print_debuginfo(l_module_name, TO_CHAR(p_xml_clob));
         print_debuginfo(l_module_name, 'EXIT');

         RETURN;

     END IF;


     /*
      * Print the clob as an XML fragment.
      */
     l_xmlstr := dbms_lob.substr(p_xml_clob, 32767);
     LOOP

         EXIT WHEN l_xmlstr IS NULL;

         l_line := SUBSTR(l_xmlstr,1,INSTR(l_xmlstr,
                       fnd_global.local_chr(10))-1);

         IF (l_line IS NOT NULL) THEN

             print_debuginfo('', l_line);

             l_xmlstr := SUBSTR(l_xmlstr,INSTR(l_xmlstr,
                           fnd_global.local_chr(10))+1);

         ELSE

             /*
              * Fix for bug 5550778:
              *
              * Print the last chunk and set the
              * xml string to null so that we do
              * not go into an infinite loop
              * in case we cannot find a '\n'
              * in the XML clob.
              */
             print_debuginfo('', l_xmlstr);

             l_xmlstr := NULL;

         END IF;

     END LOOP;

     print_debuginfo(l_module_name, 'EXIT');

 END printXMLClob;

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
         )
 IS
 l_error_code   VARCHAR2(100);
 l_error_msg    VARCHAR2(500);

 l_module_name  CONSTANT VARCHAR2(200) := G_PKG_NAME || '.checkForInvalidChars';

 /*
  * This dummy string is used as the third argument to the TRANSLATE()
  * function. Only used if invalid chars list is provided.
  *
  * The value of the string does not matter. It is used as a mask;
  * translate() will substitute any invalid chars in the field value
  * with a dummy value from this string. We will diff these two strings
  * to find the invalid characters.
  */
 l_inv_mask VARCHAR2(200) :=
     'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

 /*
  * Dummy string used as mask for checking valid characters. Only used
  * if valid chars list is provided.
  */
 l_val_mask VARCHAR2(20) := ' ';

 l_translated_value VARCHAR2(200);
 l_invalid_chars_found VARCHAR2(200);
 l_error_string  VARCHAR2(1000);

 BEGIN

     print_debuginfo(l_module_name, 'ENTER');

     /*
      * Don't do anything if the given value is null.
      */
     IF (p_fieldValue IS NULL) THEN
         print_debuginfo(l_module_name, 'Value provided for field '''
             || p_fieldName
             || ''' is null. Skipping character validation'
             );
         print_debuginfo(l_module_name, 'EXIT');
         RETURN;
     ELSE
         print_debuginfo(l_module_name, 'Value provided for field '''
             || p_fieldName || ''' is '
             || p_fieldValue
             );
     END IF;

     /*
      * MAIN CHARACTER VALIDATION LOGIC
      */
     /* character validation using valid chars list */
     IF (p_validCharsList IS NOT NULL) THEN

         print_debuginfo(l_module_name, 'Checking using valid chars list..');

         /*
          * HOW DOES IT WORK?
          *
          * Given a list of valid characters, we call translate like this:
          *
          * translate(
          *     -- given string
          *     'Oracle 9i',
          *     -- valid chars list
          *     'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
          *     -- mask
          *     ' '
          *     );
          *
          * This returns '9'. And so we caught the invalid character.
          */

         /*
          * Call translate() to filter out the invalid chars.
          */
         SELECT translate(p_fieldValue, p_validCharsList, l_val_mask)
         INTO l_translated_value
         FROM DUAL;

         /* strip spaces */
         l_translated_value := LTRIM(l_translated_value);
         l_translated_value := RTRIM(l_translated_value);

         /*
          * This means that all characters in the field value were
          * found in the valid char list. So the value contains
          * only valid characters. No invalid chars; Exit at this point.
          */
         IF (l_translated_value IS NULL) THEN
             print_debuginfo(l_module_name, 'EXIT');
             RETURN;
         ELSE
             /*
              * This means that some characters were present in the
              * field value that could not be found in the valid char
              * list. Therefore, invalid characters are present in this
              * field.
              */
             l_invalid_chars_found := l_translated_value;
         END IF;

     ELSE
         /* character validation using invalid chars list */
         print_debuginfo(l_module_name, 'Checking using invalid chars list..');

         /*
          * HOW DOES IT WORK?
          *
          * Given a list of invalid characters, we call translate like this:
          *
          * translate(
          *     -- given string
          *     'ramesh@oracle.com',
          *     -- invalid chars list
          *     '@#$'
          *     -- mask
          *     'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
          *     );
          *
          * This returns 'rameshaoracle.com'.
          *
          * We diff the input string and the translated string to get '@'
          * as the invalid character.
          */

         /*
          * Call translate to substitute any invalid chars in
          * the given string with dummy ones.
          */
         SELECT translate(p_fieldValue, p_invalidCharsList, l_inv_mask)
         INTO l_translated_value
         FROM DUAL;

         /*
          * If the translated value is not equal to the original
          * field value, it means that there were some invalid
          * characters in the field value.
          *
          * Diff the original and translated values to get the
          * invalid characters.
          */
         IF (p_fieldValue <> l_translated_value) THEN
             l_invalid_chars_found := diffStrings(p_fieldValue,
                                          l_translated_value);
         END IF;

     END IF; -- valid chars list is not null

     IF (l_invalid_chars_found IS NOT NULL) THEN

         /*
          * Do not show the field value for composite fields.
          */
         IF (p_isComposite = true) THEN

             l_error_string := 'Found invalid char(s) '
                 || '''' || l_invalid_chars_found  || ''''
                 || ' in field '
                 || '''' || p_fieldName || ''''
                 ;

             l_error_code := 'IBY_FOUND_INVALID_CHARS';
             FND_MESSAGE.set_name('IBY', l_error_code);

             FND_MESSAGE.SET_TOKEN('INV_CHARS',
                 l_invalid_chars_found,
                 FALSE);

             FND_MESSAGE.SET_TOKEN('FIELD_NAME',
                 p_fieldName,
                 FALSE);

         ELSE

             l_error_string := 'Found invalid char(s) '
                 || '''' || l_invalid_chars_found  || ''''
                 || ' in field '
                 || '''' || p_fieldName || ''''
                 || ' with value '
                 || '''' || p_fieldValue || ''''
                 ;

             l_error_code := 'IBY_INVALID_CHARS_IN_DATA';
             FND_MESSAGE.set_name('IBY', l_error_code);

             FND_MESSAGE.SET_TOKEN('INV_CHARS',
                 l_invalid_chars_found,
                 FALSE);

             FND_MESSAGE.SET_TOKEN('FIELD_NAME',
                 p_fieldName,
                 FALSE);

             FND_MESSAGE.SET_TOKEN('FIELD_VALUE',
                 p_fieldValue,
                 FALSE);

         END IF;

         print_debuginfo(l_module_name, l_error_string);

         /*
          * Add error code and error message to the
          * validation errors table
          */
         x_docErrorRec.error_code    := l_error_code;
         x_docErrorRec.error_message := FND_MESSAGE.get;

         IBY_VALIDATIONSETS_PUB.insertIntoErrorTable(
             x_docErrorRec, x_docErrorTab);

     END IF;

     print_debuginfo(l_module_name, 'EXIT');

 END checkForInvalidChars;

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
         RETURN VARCHAR2
 IS
 l_char VARCHAR2(1);
 BEGIN

     l_char := SUBSTR(p_string, p_index, 1);
     RETURN l_char;

 END getChar;

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
         RETURN VARCHAR2
 IS
 l_orgChar      VARCHAR2(1);
 l_compChar     VARCHAR2(1);
 l_diffString   VARCHAR2(2000);
 l_length       NUMBER(10);
 BEGIN

     IF (p_originalString = p_compareString) THEN
         RETURN NULL;
     END IF;

     /*
      * Compare the strings char-by-char and store the
      * differences
      */
     l_diffString := '';
     l_length := LEAST(length(p_originalString), length(p_compareString));

     FOR i in 1 .. l_length LOOP

         l_orgChar  := SUBSTR(p_originalString, i, 1);
         l_compChar := SUBSTR(p_compareString,  i, 1);

         IF (l_orgChar <> l_compChar) THEN
             l_diffString := l_diffString || l_orgChar;
         END IF;

     END LOOP;

     /*
      * Return NULL if we were unable to find
      * any differences.
      */
     IF (l_diffString = '') THEN
         l_diffString := NULL;
     END IF;

     RETURN l_diffString;

 END diffStrings;

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
     p_ca_doc_id1   IN IBY_DOCS_PAYABLE_ALL.
                           calling_app_doc_unique_ref1%TYPE,
     p_ca_doc_id2   IN IBY_DOCS_PAYABLE_ALL.
                           calling_app_doc_unique_ref2%TYPE,
     p_ca_doc_id3   IN IBY_DOCS_PAYABLE_ALL.
                           calling_app_doc_unique_ref3%TYPE,
     p_ca_doc_id4   IN IBY_DOCS_PAYABLE_ALL.
                           calling_app_doc_unique_ref4%TYPE,
     p_ca_doc_id5   IN IBY_DOCS_PAYABLE_ALL.
                           calling_app_doc_unique_ref5%TYPE,
     p_pp_tt_cd     IN IBY_DOCS_PAYABLE_ALL.pay_proc_trxn_type_code%TYPE,
     x_docErrorRec  IN OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE,
     x_docTokenTab  IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.trxnErrTokenTabType,
     p_rel_doc_id   IN IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE
                           DEFAULT NULL,
     p_error_code   IN VARCHAR2 DEFAULT NULL
     )
 IS
 l_module_name  CONSTANT VARCHAR2(200) := G_PKG_NAME || '.createErrorRecord';
 l_error_code   VARCHAR2(100);
 l_error_msg    VARCHAR2(500);

 l_token_rec    IBY_TRXN_ERROR_TOKENS%ROWTYPE;

 BEGIN

     print_debuginfo(l_module_name, 'ENTER');
     print_debuginfo(l_module_name, 'Transaction type: '   || p_trxn_type);
     print_debuginfo(l_module_name, 'Transaction status: ' || p_doc_status);

     x_docErrorRec.validation_set_code := 'CORE_PAYMENT_VALIDATION';
     x_docErrorRec.transaction_type    := p_trxn_type;

     /*
      * Fix for bug 5085226:
      *
      * Initialize the transaction error id to null for
      * the error record, each time we enter this method.
      *
      * This prevents the previously set transaction error
      * id from persisting in the x_docErrorRec for a
      * new record.
      */
     x_docErrorRec.transaction_error_id
                                       := NULL;

     x_docErrorRec.transaction_id      := p_doc_id;
     x_docErrorRec.calling_app_id      := p_ca_id;
     x_docErrorRec.calling_app_doc_unique_ref1
                                       := p_ca_doc_id1;
     x_docErrorRec.calling_app_doc_unique_ref2
                                       := p_ca_doc_id2;
     x_docErrorRec.calling_app_doc_unique_ref3
                                       := p_ca_doc_id3;
     x_docErrorRec.calling_app_doc_unique_ref4
                                       := p_ca_doc_id4;
     x_docErrorRec.calling_app_doc_unique_ref5
                                       := p_ca_doc_id5;
     x_docErrorRec.pay_proc_trxn_type_code
                                       := p_pp_tt_cd;
     x_docErrorRec.error_date          := sysdate;
     x_docErrorRec.error_status        := TRXN_ERROR_ACTIVE;

     /*
      * Error codes are mapped for certain document/payment
      * statuses. Get the error code corresponding to the
      * document/payment status.
      */
     IF (p_error_code IS NULL) THEN

         CASE p_doc_status
             WHEN DOC_STATUS_CA_FAILED THEN
                 l_error_code := 'IBY_DOC_FAILED_BY_CALL_APP';
             WHEN DOC_STATUS_RELN_FAIL THEN
                 l_error_code := 'IBY_DOC_FAILED_BY_RELATED_DOC';
             WHEN DOC_STATUS_PAY_VAL_FAIL THEN
                 l_error_code := 'IBY_DOC_FAILED_BY_PARENT_PMT';
             WHEN DOC_STATUS_FAIL_BY_REJLVL THEN
                 l_error_code := 'IBY_DOC_FAILED_BY_REJ_LVL';
             WHEN PAY_STATUS_FAIL_VALID THEN
                 l_error_code := 'IBY_PMT_FAILED_VALIDATION';
             WHEN PAY_STATUS_CA_FAILED THEN
                 l_error_code := 'IBY_PMT_FAILED_BY_CALL_APP';
             WHEN PAY_STATUS_FAIL_BY_REJLVL THEN
                 l_error_code := 'IBY_PMT_FAILED_BY_REJ_LVL';
             ELSE
                 /* generic error message */
                 l_error_code := 'IBY_GENERIC_ERROR_MSG';
         END CASE;

         print_debuginfo(l_module_name, 'Error code derived from '
             || 'doc/pmt status: '
             || l_error_code);
     ELSE

         l_error_code := p_error_code;

         print_debuginfo(l_module_name, 'Error code based on input param: '
             || l_error_code
             );

     END IF;

     FND_MESSAGE.set_name('IBY', l_error_code);

     /*
      * Error tokens are mapped for certain error messages.
      */
     CASE l_error_code
         WHEN 'IBY_DOC_FAILED_BY_RELATED_DOC' THEN
             FND_MESSAGE.SET_TOKEN('RELDOC', p_rel_doc_id, FALSE);
             l_token_rec.token_name  := 'RELDOC';
             l_token_rec.token_value := p_rel_doc_id;
         WHEN 'IBY_DOC_FAILED_BY_REJ_LVL' THEN
             FND_MESSAGE.SET_TOKEN('TRGDOC', p_rel_doc_id, FALSE);
             l_token_rec.token_name  := 'TRGDOC';
             l_token_rec.token_value := p_rel_doc_id;
         WHEN 'IBY_PMT_FAILED_BY_REJ_LVL' THEN
             FND_MESSAGE.SET_TOKEN('TRGPMT', p_rel_doc_id, FALSE);
             l_token_rec.token_name  := 'TRGPMT';
             l_token_rec.token_value := p_rel_doc_id;
         ELSE
             /* do nothing */
             NULL;
     END CASE;

     l_error_msg := FND_MESSAGE.get;

     print_debuginfo(l_module_name, 'Error message derived from error code: '
         || l_error_msg);

     x_docErrorRec.error_code    := l_error_code;
     x_docErrorRec.error_message := l_error_msg;

     /*
      * If we created a token record, add it to the token
      * records table.
      */
     IF (l_token_rec.token_name IS NOT NULL) THEN
         x_docTokenTab(x_docTokenTab.COUNT + 1) := l_token_rec;
     END IF;

     print_debuginfo(l_module_name, 'EXIT');

 END createErrorRecord;

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
     )
 IS

 l_module_name  VARCHAR2(200) := G_PKG_NAME || '.createPmtErrorRecord';

 BEGIN

     print_debuginfo(l_module_name, 'ENTER');

     x_docErrorRec.validation_set_code := 'CORE_PAYMENT_VALIDATION';
     x_docErrorRec.transaction_type    := 'PAYMENT';

     x_docErrorRec.transaction_id      := p_pmt_id;

     x_docErrorRec.error_date          := sysdate;
     x_docErrorRec.error_status        := TRXN_ERROR_ACTIVE;

     x_docErrorRec.error_code          := p_error_code;
     x_docErrorRec.error_message       := p_error_msg;

     x_docErrorRec.override_allowed_on_error_flag
                                       := 'N';

     print_debuginfo(l_module_name, 'EXIT');

 END createPmtErrorRecord;

PROCEDURE getProfListFromProfileDrivers(
     p_pmt_method_cd     IN IBY_DOCS_PAYABLE_ALL.payment_method_code%TYPE,
     p_org_id            IN IBY_DOCS_PAYABLE_ALL.org_id%TYPE,
     p_org_type          IN IBY_DOCS_PAYABLE_ALL.org_type%TYPE,
     p_pmt_currency      IN IBY_DOCS_PAYABLE_ALL.payment_currency_code%TYPE,
     p_int_bank_acct_id  IN IBY_DOCS_PAYABLE_ALL.internal_bank_account_id%TYPE,
     p_profile_id       IN OUT NOCOPY IBY_DOCS_PAYABLE_ALL.payment_profile_id%TYPE,
     p_valid_flag       OUT NOCOPY VARCHAR2
     )
 IS
 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME ||
                                             '.getProfListFromProfileDrivers';
 l_prof_val_indx       VARCHAR2(2000);
 l_prof_der_indx       VARCHAR2(2000);

 BEGIN

     print_debuginfo(l_module_name, 'ENTER');

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

     print_debuginfo(l_module_name, 'ENTER');


     IF(p_profile_id is not null) THEN
     l_prof_val_indx := p_profile_id||'$'||p_org_id||'$'||p_org_type||'$'||p_pmt_method_cd||'$'||p_pmt_currency||'$'||p_int_bank_acct_id;
       IF(l_prof_val_indx is not null) THEN
           IF(l_prof_val_tbl.EXISTS(l_prof_val_indx)) THEN
           print_debuginfo(l_module_name, 'Fetching the value from Cache Structure l_prof_val_tbl' || l_prof_val_indx);
           p_valid_flag := l_prof_val_tbl(l_prof_val_indx);
           ELSE
           print_debuginfo(l_module_name, 'Fetching the value from the DB for l_prof_val_tbl' || l_prof_val_indx);
             BEGIN
               SELECT
                 'Y'
                 INTO p_valid_flag
                 FROM
                     IBY_APPLICABLE_PMT_PROFS app1,
                     IBY_APPLICABLE_PMT_PROFS app2,
                     IBY_APPLICABLE_PMT_PROFS app3,
                     IBY_APPLICABLE_PMT_PROFS app4,
                     IBY_SYS_PMT_PROFILES_B   sys_prof,
                     IBY_ACCT_PMT_PROFILES_B  acct_prof
                 WHERE
                     /*
                      * org id is a special case; since each org id has meaning
                      * only within an org type, we need to always use
                      * (org id, org type) as a combination.
                      *
                      * This means that both org id and org type need to be
                      * stored in the same row. In order to simplify matters,
                      * the org type field will be stored in the 'applicable
                      * value from' column wherever org id is stored.
                      *
                      * If org id is null, do not check org type - special case.
                      */
                     (app1.applicable_type_code=APL_TYPE_ORG AND
                         (app1.applicable_value_to IS NULL) OR
                         (app1.applicable_value_to=TO_CHAR(p_org_id) AND
                             app1.applicable_value_from=p_org_type))
                 AND (app2.applicable_type_code=APL_TYPE_PMT_METHOD AND
                         (app2.applicable_value_to=p_pmt_method_cd OR
                             app2.applicable_value_to IS NULL))
                 AND (app3.applicable_type_code=APL_TYPE_PMT_CURRENCY AND
                         (app3.applicable_value_to=p_pmt_currency OR
                             app3.applicable_value_to IS NULL))
                 AND (app4.applicable_type_code=APL_TYPE_INT_BANK_ACCT AND
                         (app4.applicable_value_to=TO_CHAR(p_int_bank_acct_id) OR
                             app4.applicable_value_to IS NULL))
                 AND
                     app1.system_profile_code=app2.system_profile_code
                 AND
                     app2.system_profile_code=app3.system_profile_code
                 AND
                     app3.system_profile_code=app4.system_profile_code
                 AND
                     app4.system_profile_code=app1.system_profile_code
                 AND
                     app1.system_profile_code=sys_prof.system_profile_code
                 AND
                     sys_prof.system_profile_code=acct_prof.system_profile_code(+)
                 /*
                  * Fix for bug 5929889:
                  *
                  * Filter profiles by inactive date so that we do not
                  * pick up end-dated profiles.
                  */
                 AND NVL(sys_prof.inactive_date, SYSDATE + 1) > SYSDATE
                 AND acct_prof.payment_profile_id = p_profile_id;
              EXCEPTION
                 WHEN TOO_MANY_ROWS THEN
                 print_debuginfo(l_module_name, 'Modifying the value of the p_valid_flag when the Exception is TOO_MANY_ROWS for l_prof_val_tbl');
                 p_valid_flag := 'Y';
                 WHEN OTHERS THEN
                 print_debuginfo(l_module_name, 'Modifying the value of the p_valid_flag when the Exception is OTHERS for l_prof_val_tbl');
                 p_valid_flag := 'N';
             END;
             l_prof_val_tbl(l_prof_val_indx) := p_valid_flag;
           END IF;
        END IF;
     ELSE
     l_prof_der_indx := p_org_id||'$'||p_org_type||'$'||p_pmt_method_cd||'$'||p_pmt_currency||'$'||p_int_bank_acct_id;
        IF(l_prof_der_indx is not null) THEN
           IF(l_prof_der_tbl.EXISTS(l_prof_der_indx)) THEN
           print_debuginfo(l_module_name, 'Fetching the value from Cache Structure l_prof_der_tbl' || l_prof_der_indx);
           p_profile_id := l_prof_der_tbl(l_prof_der_indx).l_profile_id;
           p_valid_flag := l_prof_der_tbl(l_prof_der_indx).l_valid_flag;
           ELSE
           print_debuginfo(l_module_name, 'Fetching the value from the DB for l_prof_der_tbl' || l_prof_der_indx);
             BEGIN
               SELECT
                 acct_prof.payment_profile_id, 'Y'
                 INTO p_profile_id, p_valid_flag
                 FROM
                     IBY_APPLICABLE_PMT_PROFS app1,
                     IBY_APPLICABLE_PMT_PROFS app2,
                     IBY_APPLICABLE_PMT_PROFS app3,
                     IBY_APPLICABLE_PMT_PROFS app4,
                     IBY_SYS_PMT_PROFILES_B   sys_prof,
                     IBY_ACCT_PMT_PROFILES_B  acct_prof
                 WHERE
                     /*
                      * org id is a special case; since each org id has meaning
                      * only within an org type, we need to always use
                      * (org id, org type) as a combination.
                      *
                      * This means that both org id and org type need to be
                      * stored in the same row. In order to simplify matters,
                      * the org type field will be stored in the 'applicable
                      * value from' column wherever org id is stored.
                      *
                      * If org id is null, do not check org type - special case.
                      */
                     (app1.applicable_type_code=APL_TYPE_ORG AND
                         (app1.applicable_value_to IS NULL) OR
                         (app1.applicable_value_to=TO_CHAR(p_org_id) AND
                             app1.applicable_value_from=p_org_type))
                 AND (app2.applicable_type_code=APL_TYPE_PMT_METHOD AND
                         (app2.applicable_value_to=p_pmt_method_cd OR
                             app2.applicable_value_to IS NULL))
                 AND (app3.applicable_type_code=APL_TYPE_PMT_CURRENCY AND
                         (app3.applicable_value_to=p_pmt_currency OR
                             app3.applicable_value_to IS NULL))
                 AND (app4.applicable_type_code=APL_TYPE_INT_BANK_ACCT AND
                         (app4.applicable_value_to=TO_CHAR(p_int_bank_acct_id) OR
                             app4.applicable_value_to IS NULL))
                 AND
                     app1.system_profile_code=app2.system_profile_code
                 AND
                     app2.system_profile_code=app3.system_profile_code
                 AND
                     app3.system_profile_code=app4.system_profile_code
                 AND
                     app4.system_profile_code=app1.system_profile_code
                 AND
                     app1.system_profile_code=sys_prof.system_profile_code
                 AND
                     sys_prof.system_profile_code=acct_prof.system_profile_code(+)
                 /*
                  * Fix for bug 5929889:
                  *
                  * Filter profiles by inactive date so that we do not
                  * pick up end-dated profiles.
                  */
                 AND NVL(sys_prof.inactive_date, SYSDATE + 1) > SYSDATE;
              EXCEPTION
                 WHEN TOO_MANY_ROWS THEN
                 print_debuginfo(l_module_name, 'Modifying the value of the p_valid_flag when the Exception is TOO_MANY_ROWS for  l_prof_der_tbl');
                 p_valid_flag := 'M';
                 p_profile_id := -1;
                 WHEN OTHERS THEN
                 print_debuginfo(l_module_name, 'Modifying the value of the p_valid_flag when the Exception is OTHERS for  l_prof_der_tbl');
                 p_valid_flag := 'N';
                 p_profile_id := -1;
             END;
             l_prof_der_tbl(l_prof_der_indx).l_valid_flag := p_valid_flag;
             l_prof_der_tbl(l_prof_der_indx).l_profile_id := p_profile_id;
           END IF;
        END IF;
     END IF;

 EXCEPTION
     WHEN OTHERS THEN
         print_debuginfo(l_module_name, 'Non-Fatal: Exception when '
             || 'attempting to get payment profile for given (payment '
             || 'method, org, currency, int bank acct) '
             || 'combination.'
             );
         print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
         print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);

         print_debuginfo(l_module_name, 'EXIT');

 END getProfListFromProfileDrivers;


/*--------------------------------------------------------------------
 | NAME:
 |     getProfListFromProfileDrivers
 |
 | PURPOSE:
 |     Derives the payment profile for the given (payment method,
 |     org, payment currency, internal bank acct)
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
     x_profilesTab       IN OUT NOCOPY pmtProfTabType
     )
 IS
 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME ||
                                             '.getProfListFromProfileDrivers';

 /*
  * We need to select payment profiles that are applicable to
  * given (payment method, org, currency, int bank account).
  *
  *
  *     |  Profiles      |
  *     |  applicable to |
  *     |  given pmt     |    Profiles applicable to
  *     |  method        |    given payment currency
  *     |                |     /
  *     |     |          |    /
  *     |     V          |  L
  *     |                |
  *     |----------------|--------------------------
  *     |/              \|            Profiles
  *     |                |            applicable to
  *     |  Intersection  |     <--    given
  *     |                |            org id and org type
  *     |\              /|
  *     |----------------|--------------------------
  *     |                |
  *     |                |  .__
  *     |                |  |\
  *     |                |    \
  *     |                |
  *     |                |   Profiles applicable to
  *     |                |   given internal bank
  *     |                |   account
  *     |                |
  *     |                |
  *
  * We need the intersection of (profiles applicable to
  * a given payment method) and (profiles applicable to
  * a given org) and (profiles applicable to given payment
  * currency) and (profiles applicable to given internal
  * bank account) as shown in the graphic.
  *
  * Therefore, we need to join with the IBY_APPLICABLE_PMT_PROFS
  * four times - once to get the profiles for the method, once to get
  * the profiles for the org, and once to get the profiles for the
  * currency etc. If we are able to get a non-null intersect for these
  * five queries, it means that there is a profile that matches the
  * (org, method, currency, bank acct) combination.
  *
  * If the 'applicable_value_to' is set to NULL, it means that the
  * profile is applicable to 'all orgs' | 'all methods' |
  * 'all formats' etc., depending upon the applicable_type_code.
  * Therefore, we need to factor this condition in the join.
  */

  /*
   * Redundant joins of the form where a=b=c=a execute faster than
   * where a=b=c joins. That's why this select has a redundant join.
   */
  CURSOR c_profiles(
             p_pmt_method_cd     IN IBY_DOCS_PAYABLE_ALL.
                                        payment_method_code%TYPE,
             p_org_id            IN IBY_DOCS_PAYABLE_ALL.org_id%TYPE,
             p_org_type          IN IBY_DOCS_PAYABLE_ALL.org_type%TYPE,
             p_pmt_currency      IN IBY_DOCS_PAYABLE_ALL.
                                        payment_currency_code%TYPE,
             p_int_bank_acct_id  IN IBY_DOCS_PAYABLE_ALL.
                                        internal_bank_account_id%TYPE
             )
 IS
 SELECT
     acct_prof.payment_profile_id
 FROM
     IBY_APPLICABLE_PMT_PROFS app1,
     IBY_APPLICABLE_PMT_PROFS app2,
     IBY_APPLICABLE_PMT_PROFS app3,
     IBY_APPLICABLE_PMT_PROFS app4,
     IBY_SYS_PMT_PROFILES_B   sys_prof,
     IBY_ACCT_PMT_PROFILES_B  acct_prof
 WHERE
     /*
      * org id is a special case; since each org id has meaning
      * only within an org type, we need to always use
      * (org id, org type) as a combination.
      *
      * This means that both org id and org type need to be
      * stored in the same row. In order to simplify matters,
      * the org type field will be stored in the 'applicable
      * value from' column wherever org id is stored.
      *
      * If org id is null, do not check org type - special case.
      */
     (app1.applicable_type_code=APL_TYPE_ORG AND
         (app1.applicable_value_to IS NULL) OR
         (app1.applicable_value_to=TO_CHAR(p_org_id) AND
             app1.applicable_value_from=p_org_type))
 AND (app2.applicable_type_code=APL_TYPE_PMT_METHOD AND
         (app2.applicable_value_to=p_pmt_method_cd OR
             app2.applicable_value_to IS NULL))
 AND (app3.applicable_type_code=APL_TYPE_PMT_CURRENCY AND
         (app3.applicable_value_to=p_pmt_currency OR
             app3.applicable_value_to IS NULL))
 AND (app4.applicable_type_code=APL_TYPE_INT_BANK_ACCT AND
         (app4.applicable_value_to=TO_CHAR(p_int_bank_acct_id) OR
             app4.applicable_value_to IS NULL))
 AND
     app1.system_profile_code=app2.system_profile_code
 AND
     app2.system_profile_code=app3.system_profile_code
 AND
     app3.system_profile_code=app4.system_profile_code
 AND
     app4.system_profile_code=app1.system_profile_code
 AND
     app1.system_profile_code=sys_prof.system_profile_code
 AND
     sys_prof.system_profile_code=acct_prof.system_profile_code(+)
 /*
  * Fix for bug 5929889:
  *
  * Filter profiles by inactive date so that we do not
  * pick up end-dated profiles.
  */
 AND NVL(sys_prof.inactive_date, SYSDATE + 1) > SYSDATE
 ;

 BEGIN

     print_debuginfo(l_module_name, 'ENTER');

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

     print_debuginfo(l_module_name, 'ENTER');

     OPEN  c_profiles(p_pmt_method_cd,
               p_org_id,
               p_org_type,
               p_pmt_currency,
               p_int_bank_acct_id
               );
     FETCH c_profiles BULK COLLECT INTO x_profilesTab;
     CLOSE c_profiles;

    IF (x_profilesTab.COUNT = 0) THEN

        print_debuginfo(l_module_name, 'No applicable payment profiles '
            || 'were found.');

    ELSE

        print_debuginfo(l_module_name, 'Count of applicable payment profiles: '
            || x_profilesTab.COUNT);

    END IF;

    print_debuginfo(l_module_name, 'EXIT');

 EXCEPTION
     WHEN OTHERS THEN
         print_debuginfo(l_module_name, 'Non-Fatal: Exception when '
             || 'attempting to get payment profile for given (payment '
             || 'method, org, currency, int bank acct) '
             || 'combination.'
             );
         print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
         print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);

         print_debuginfo(l_module_name, 'EXIT');

 END getProfListFromProfileDrivers;

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
     )
 IS
 l_module_name  CONSTANT VARCHAR2(200) := G_PKG_NAME || '.getProfileMap';

 /*
  * Cursor to pick up mapping between a profile id and a
  * profile code.
  */
 CURSOR c_profile_map
 IS
 SELECT
     payment_profile_id,
     system_profile_code
 FROM
     IBY_PAYMENT_PROFILES;

 BEGIN

     print_debuginfo(l_module_name, 'ENTER');

     /*
      * Pick up profile mapping.
      */
     OPEN  c_profile_map;
     FETCH c_profile_map BULK COLLECT INTO x_profileMap;
     CLOSE c_profile_map;


     print_debuginfo(l_module_name, 'Profile map contains '
         || x_profileMap.COUNT
         || ' records.'
         );

     print_debuginfo(l_module_name, 'EXIT');

 END getProfileMap;


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
     ) RETURN VARCHAR2
 IS
 l_profile_code IBY_PAYMENT_PROFILES.system_profile_code%TYPE;
 l_profil_id_index      NUMBER(20);

 BEGIN


      /*
      * Adding Caching Logic to avoid database hits for the same input
      * combination.
      *
      */
      l_profil_id_index := p_profile_id;

      IF (l_profile_cod_tbl.EXISTS(l_profil_id_index)) THEN
         RETURN l_profile_cod_tbl(l_profil_id_index);
      END IF;


     IF (p_profileMap.COUNT = 0) THEN
         l_profile_code := NULL;
         RETURN l_profile_code;
     END IF;

     l_profile_code := NULL;
     FOR i IN p_profileMap.FIRST .. p_profileMap.LAST LOOP
         IF (p_profileMap(i).pmt_profile_id = p_profile_id) THEN
             l_profile_code := p_profileMap(i).pmt_profile_cd;

	     /* Caching before exiting */
	     l_profile_cod_tbl(l_profil_id_index) := l_profile_code;

             EXIT;
         END IF;
     END LOOP;

     RETURN l_profile_code;

 END getProfileCodeFromId;

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
     )
 IS

 l_chunk    VARCHAR2(80);
 l_length  NUMBER := 1;

 BEGIN

     WHILE(length(p_string) >= l_length) LOOP

         l_chunk := substrb(p_string, l_length, 75);

         l_chunk := ltrim(l_chunk);
         l_chunk := rtrim(l_chunk);

         print_debuginfo(' ', l_chunk);

         l_length := (l_length + 75);

     END LOOP;

 END printWrappedString;

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
     )
 IS
 l_module_name  CONSTANT VARCHAR2(200) := G_PKG_NAME || '.inactivateOldErrors';

 BEGIN

     print_debuginfo(l_module_name, 'ENTER');

     print_debuginfo(l_module_name, 'Inactivating old errors for '
         || p_trxn_type
         || ' id: '
         || p_trxn_id
         );

     /*
      * Set the error status to inactive in the IBY_TRANSACTION_ERRORS
      * table for all rows that contain errors against this
      * transaction.
      */
     UPDATE
         IBY_TRANSACTION_ERRORS err
     SET
         err.error_status     = 'INACTIVE',
         err.last_update_date = sysdate,
         err.last_updated_by  = fnd_global.user_id
     WHERE
         err.transaction_id   = p_trxn_id           AND
         err.transaction_type = p_trxn_type
     ;

     /*
      * Fix for bug 5742548:
      *
      * When inactivating payment errors, remember to
      * inactivate errors on underlying documents payable
      * as well.
      */
     IF (p_trxn_type = 'PAYMENT') THEN

         print_debuginfo(l_module_name, 'Inactivating old errors for '
             || 'child documents of payment id: '
             || p_trxn_id
             );

         UPDATE
             IBY_TRANSACTION_ERRORS err
         SET
             err.error_status     = 'INACTIVE',
             err.last_update_date = sysdate,
             err.last_updated_by  = fnd_global.user_id
         WHERE
             err.transaction_id   IN
                 (
                 SELECT
                     document_payable_id
                 FROM
                     IBY_DOCS_PAYABLE_ALL
                 WHERE
                     payment_id = p_trxn_id
                 )
             AND
             err.transaction_type = 'DOCUMENT_PAYABLE'
         ;

     END IF;

     /*
      * Reset the transaction status to a success / neutral
      * status. The transaction status will get updated to a
      * failure status in case the transaction fails validation
      * later.
      */
     IF (p_trxn_type = 'DOCUMENT_PAYABLE') THEN

         print_debuginfo(l_module_name, 'Resetting status of doc'
             || ' id: '
             || p_trxn_id
             || ' to '
             || DOC_STATUS_VALIDATED
             );

         UPDATE
             IBY_DOCS_PAYABLE_ALL doc
         SET
             doc.document_status = DOC_STATUS_VALIDATED
         WHERE
             doc.document_payable_id = p_trxn_id
         ;

     ELSIF (p_trxn_type = 'PAYMENT') THEN

         print_debuginfo(l_module_name, 'Resetting status of pmt'
             || ' id: '
             || p_trxn_id
             || ' to '
             || PAY_STATUS_CREATED
             );

         UPDATE
             IBY_PAYMENTS_ALL pmt
         SET
             pmt.payment_status = PAY_STATUS_CREATED
         WHERE
             pmt.payment_id = p_trxn_id
         ;

     END IF;

     print_debuginfo(l_module_name, 'EXIT');

     /*
      * Any exceptions that occur in this method are non-fatal.
      */
     EXCEPTION
         WHEN OTHERS THEN

             print_debuginfo(l_module_name, 'Non Fatal: Exception occured '
                 || 'when attempting to update error status to inactive '
                 || 'for transaction.'
                 );

             print_debuginfo(l_module_name, 'SQL code: '   || SQLCODE);
             print_debuginfo(l_module_name, 'SQL err msg: '|| SQLERRM);

             print_debuginfo(l_module_name, 'EXIT');

 END inactivateOldErrors;

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
     )
 IS
 l_module_name  CONSTANT VARCHAR2(200) := G_PKG_NAME || '.resetPaymentErrors';

 BEGIN

     print_debuginfo(l_module_name, 'ENTER');

     /*
      * STEP 1:
      *
      * Delete the existing errors stored against the payments
      * of the PPR.
      *
      * We are going to revalidate these payments, so old errors
      * need not be persisted at this point.
      */
     DELETE
         IBY_TRANSACTION_ERRORS err
     WHERE
         err.transaction_type = 'PAYMENT' AND
         err.transaction_id IN
         (
           SELECT
               payment_id
           FROM
               IBY_PAYMENTS_ALL
           WHERE
               payment_service_request_id = p_payment_request_id AND
               payment_status IN
               (
               PAY_STATUS_CREATED,
               PAY_STATUS_MODIFIED,
               PAY_STATUS_FAIL_VALID
               )
         )
     ;

     /*
      * STEP 2:
      *
      * Delete existing errors against documents that
      * were failed because their parent payment
      * failed validation.
      *
      * Fix for bug 5742548:
      *
      * When deleting payment errors, remember to
      * delete errors on underlying documents payable
      * as well.
      */
     DELETE
         IBY_TRANSACTION_ERRORS err
     WHERE
         err.transaction_type = 'DOCUMENT_PAYABLE' AND
         err.transaction_id IN
         (
           SELECT
               docs.document_payable_id
           FROM
               IBY_DOCS_PAYABLE_ALL docs
           WHERE
               docs.document_status = DOC_STATUS_PAY_VAL_FAIL AND
               docs.payment_service_request_id = p_payment_request_id
         )
     ;


     /*
      * STEP 3:
      *
      * Reset the status of payments that are to be re-validated to
      * 'CREATED'.
      */
     UPDATE
         IBY_PAYMENTS_ALL
     SET
         payment_status = PAY_STATUS_CREATED
     WHERE
         payment_service_request_id = p_payment_request_id AND
         payment_status IN
         (
          PAY_STATUS_MODIFIED,
          PAY_STATUS_FAIL_VALID
         )
     ;

     print_debuginfo(l_module_name, 'EXIT');

 END resetPaymentErrors;


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
     )
 IS
 l_module_name  CONSTANT VARCHAR2(200) := G_PKG_NAME || '.resetDocumentErrors';

 BEGIN

     print_debuginfo(l_module_name, 'ENTER');

     /*
      * STEP 1:
      *
      * Delete existing errors against documents payable that
      * are to be re-validated
      */
     DELETE
         IBY_TRANSACTION_ERRORS err
     WHERE
         err.transaction_type = 'DOCUMENT_PAYABLE' AND
         err.transaction_id IN
         (
           SELECT
               document_payable_id
           FROM
               IBY_DOCS_PAYABLE_ALL
           WHERE
               payment_service_request_id = p_payment_request_id AND
               document_status = DOC_STATUS_FAIL_VALID
         )
     ;

     /*
      * Reset the status of documents that are to be re-validated to
      * 'VALIDATED'.
      */
     UPDATE
         IBY_DOCS_PAYABLE_ALL
     SET
         document_status = DOC_STATUS_VALIDATED
     WHERE
         payment_service_request_id = p_payment_request_id AND
         document_status = DOC_STATUS_FAIL_VALID
     ;

     print_debuginfo(l_module_name, 'EXIT');

 END resetDocumentErrors;

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
     )
 IS
 l_module_name  CONSTANT VARCHAR2(200) := G_PKG_NAME || '.resetPaymentInstructionErrors';

 BEGIN

     print_debuginfo(l_module_name, 'ENTER');

     /*
      * Delete existing errors against the payment instruction
      * that is to be re-validated
      *
      * There is no need to delete the errors against any
      * child elements (like payments) etc. because these
      * are untouched by the PICP.
      */
     DELETE
         IBY_TRANSACTION_ERRORS err
     WHERE
         err.transaction_type = 'PAYMENT_INSTRUCTION' AND
         err.transaction_id = p_instr_id
     ;

     print_debuginfo(l_module_name, 'EXIT');

 END resetPaymentInstructionErrors;

END IBY_BUILD_UTILS_PKG;

/
