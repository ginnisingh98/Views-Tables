--------------------------------------------------------
--  DDL for Package Body IBY_PAYINSTR_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_PAYINSTR_UTILS_PKG" AS
/*$Header: ibypiutb.pls 120.5 2006/01/06 21:34:00 rameshsh noship $*/

 /*
  * Declare global variables
  */
 G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBY_PAYINSTR_UTILS_PKG';

 --
 -- List of instruction statuses that are used / set in this
 -- module.
 --
 INS_STATUS_CREATED        CONSTANT VARCHAR2(100) := 'CREATED';
 INS_STATUS_FAIL_VALID     CONSTANT VARCHAR2(100) := 'FAILED_VALIDATION';
 INS_STATUS_CREAT_ERROR    CONSTANT VARCHAR2(100) := 'CREATION_ERROR';

 --
 -- List of transaction error statuses that are used / set in this
 -- module.
 --
 TRXN_ERROR_ACTIVE         CONSTANT VARCHAR2(100) := 'ACTIVE';

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
     p_debug_text IN VARCHAR2
     )
 IS

 BEGIN

     /*
      * Write the debug message to the concurrent manager log file.
      */
     iby_build_utils_pkg.print_debuginfo(p_module, p_debug_text);

 END print_debuginfo;

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
     p_ins_id        IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE,
     p_ins_status    IN IBY_PAY_INSTRUCTIONS_ALL.
                            payment_instruction_status%TYPE,
     p_error_code    IN IBY_TRANSACTION_ERRORS.error_code%TYPE
                           DEFAULT NULL,
     p_error_msg     IN IBY_TRANSACTION_ERRORS.error_message%TYPE
                           DEFAULT NULL,
     p_override_flag IN IBY_TRANSACTION_ERRORS.
                            override_allowed_on_error_flag%TYPE
                            DEFAULT 'N',
     x_docErrorRec   IN OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE
     )
 IS

 l_module_name  VARCHAR2(200) := G_PKG_NAME || '.createErrorRecord';

 BEGIN

     print_debuginfo(l_module_name, 'ENTER');

     x_docErrorRec.validation_set_code := 'CORE_INSTRUCTION_VALIDATION';
     x_docErrorRec.transaction_type    := 'PAYMENT_INSTRUCTION';

     x_docErrorRec.transaction_id      := p_ins_id;

     x_docErrorRec.error_date          := sysdate;
     x_docErrorRec.error_status        := TRXN_ERROR_ACTIVE;

     x_docErrorRec.error_code          := p_error_code;
     x_docErrorRec.error_message       := p_error_msg;

     x_docErrorRec.override_allowed_on_error_flag := p_override_flag;

     print_debuginfo(l_module_name, 'EXIT');

 END createErrorRecord;

END IBY_PAYINSTR_UTILS_PKG;

/
