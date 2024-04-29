--------------------------------------------------------
--  DDL for Package Body PSA_BC_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSA_BC_UTIL_PKG" AS
-- $Header: PSABCUTB.pls 120.1 2006/04/20 10:30:48 kbhatt noship $


-------------------------------------------------------------------------------
--Start of Comments
--Purpose:
--  Save the start of procedure log info into conc. program log file
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE log_conc_start(
    p_pkg_name     IN    VARCHAR2
,   p_proc_name    IN    VARCHAR2
,   p_progress     IN    VARCHAR2 DEFAULT NULL
) IS
BEGIN
NULL;
END log_conc_start;




-------------------------------------------------------------------------------
--Start of Comments
--Purpose:
--  Save the end of procedure log info into conc. program log file
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE log_conc_end(
    p_pkg_name     IN    VARCHAR2
,   p_proc_name    IN    VARCHAR2
,   p_progress     IN    VARCHAR2 DEFAULT NULL
) IS
BEGIN
NULL;
END log_conc_end;




-------------------------------------------------------------------------------
--Start of Comments
--Purpose:
--  Save the variable information within conc. program procedure
--  into conc. program log file
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE log_conc_stmt(
    p_pkg_name     IN    VARCHAR2
,   p_proc_name    IN    VARCHAR2
,   p_progress     IN    VARCHAR2 DEFAULT NULL
,   p_name         IN    VARCHAR2 DEFAULT NULL
,   p_value        IN    VARCHAR2 DEFAULT NULL
) IS
BEGIN
NULL;
END log_conc_stmt;




-------------------------------------------------------------------------------
--Start of Comments
--Purpose:
--  Save the unexpected error information within conc. program procedure
--  into conc. program log file, it will contain the sqlerr message
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE log_conc_unexp(
    p_pkg_name     IN    VARCHAR2
,   p_proc_name    IN    VARCHAR2
,   p_progress     IN    VARCHAR2 DEFAULT NULL
) IS
BEGIN
NULL;
END log_conc_unexp;




-------------------------------------------------------------------------------
--Start of Comments
--Purpose:
--  Save the error information within conc. program procedure
--  into conc. program log file, it used for user given error message
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE log_conc_err(
    p_pkg_name     IN    VARCHAR2
,   p_proc_name    IN    VARCHAR2
,   p_progress     IN    VARCHAR2 DEFAULT NULL
,   p_msg          IN    VARCHAR2
) IS
BEGIN
NULL;
END log_conc_err;


END PSA_BC_UTIL_PKG;


/
