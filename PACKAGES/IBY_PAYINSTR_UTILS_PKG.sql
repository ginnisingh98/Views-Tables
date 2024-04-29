--------------------------------------------------------
--  DDL for Package IBY_PAYINSTR_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_PAYINSTR_UTILS_PKG" AUTHID CURRENT_USER AS
/*$Header: ibypiuts.pls 120.3 2005/10/04 16:28:44 rameshsh noship $*/

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
     );

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
     p_ins_id       IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE,
     p_ins_status   IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_status%TYPE,
     p_error_code   IN IBY_TRANSACTION_ERRORS.error_code%TYPE
                           DEFAULT NULL,
     p_error_msg    IN IBY_TRANSACTION_ERRORS.error_message%TYPE
                           DEFAULT NULL,
     p_override_flag IN IBY_TRANSACTION_ERRORS.
                            override_allowed_on_error_flag%TYPE
                            DEFAULT 'N',
     --x_docErrorRec  IN OUT NOCOPY IBY_VALIDATIONSETS_PUB.docErrorRecType
     x_docErrorRec  IN OUT NOCOPY IBY_TRANSACTION_ERRORS%ROWTYPE
     );

END IBY_PAYINSTR_UTILS_PKG;

 

/
