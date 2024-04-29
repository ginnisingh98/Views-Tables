--------------------------------------------------------
--  DDL for Package ECE_PO_ARCHIVE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECE_PO_ARCHIVE_PKG" AUTHID CURRENT_USER AS
-- $Header: ECEPOARS.pls 120.2 2005/09/28 11:51:47 arsriniv ship $

-- ============================================================================
--  Name: porarchive
--  Desc: Archving cover routine
--  Args: IN: p_document_type
--            p_document_subtype
--            p_document_id
--            p_process        - Process that called this routine
--                                     'PRINT' or 'APPROVE'.
--  Err : Any value other than 0 in p_error_code indicates an oracle error
--        occurred.  Currently the only errors that are raised are oracle
--        errors.  No other error codes are reserved for special meanings.
--        The Oracle Error Message is given in p_error_buf and the context
--        or call stack is in p_error_stack.
--
--        Conditions for archiving:
--             archive_external_revision code in PO_DOCUMENT_TYPES
--             (PRINT or APPROVE) of given document type must be the same
--             as process (PRINT or APPROVE).
--  Note: Routine does NOT do a commit, this must be done in the calling
--        routine!
-- ============================================================================

PROCEDURE PORARCHIVE (
                      P_DOCUMENT_TYPE IN VARCHAR2,
                      P_DOCUMENT_SUBTYPE IN VARCHAR2,
                      P_DOCUMENT_ID IN NUMBER,
                      P_PROCESS IN VARCHAR2,
		      P_ERROR_CODE OUT NOCOPY NUMBER,
		      P_ERROR_BUF OUT NOCOPY VARCHAR2,
		      P_ERROR_STACK OUT NOCOPY VARCHAR2);

END ECE_PO_ARCHIVE_PKG;


/* ================================================================
   The following allows capturing compile error during AutoInstall
   by intentionally causing an ORA-01858 error if there are records
   in user_errors.

   show errors package ECE_PO_ARCHIVE_PKG

   select to_date( 'SQLERROR') from user_errors
   where type = 'PACKAGE'
   and name = 'ECE_PO_ARCHIVE_PKG'

   ================================================================
*/

 

/
