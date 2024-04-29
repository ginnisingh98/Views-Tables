--------------------------------------------------------
--  DDL for Package Body FUN_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_UTIL" AS
--  $Header: FUNVUTLB.pls 120.1 2005/07/14 10:38:40 bsilveir noship $




-------------------------------------------------------------------------------
--Start of Comments
--Function:
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
    FND_FILE.put_line(
        FND_FILE.log
    ,   p_pkg_name || '.' || p_proc_name || '.' || 'start'
     );
END log_conc_start;




-------------------------------------------------------------------------------
--Start of Comments
--Function:
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
    FND_FILE.put_line(
        FND_FILE.log
    ,   p_pkg_name || '.' || p_proc_name || '.' || 'end'
     );
END log_conc_end;




-------------------------------------------------------------------------------
--Start of Comments
--Function:
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
    FND_FILE.put_line(
        FND_FILE.log
    ,   p_pkg_name || '.' || p_proc_name || '.' || 'progress at ' ||
        p_progress || '.' || p_name || ' = ' || p_value
    );
END log_conc_stmt;




-------------------------------------------------------------------------------
--Start of Comments
--Function:
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
    FND_FILE.put_line(
        FND_FILE.log
    ,   p_pkg_name || '.' || p_proc_name || '.' || 'exception at ' ||
        p_progress || '.' || SQLERRM(sqlcode)
    );
END log_conc_unexp;




-------------------------------------------------------------------------------
--Start of Comments
--Function:
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
    FND_FILE.put_line(
        FND_FILE.log
    ,   p_pkg_name || '.' || p_proc_name || '.' || 'error at ' ||
        p_progress || '.' || p_msg
    );
END log_conc_err;


FUNCTION get_account_segment_value (
    p_ledger_id      IN gl_ledgers.ledger_id%TYPE,
    p_ccid           IN gl_code_combinations.code_combination_id%TYPE,
    p_segment_type   IN VARCHAR2 )
 RETURN VARCHAR2

IS
   l_account_value 	VARCHAR2(30);
   l_segment       	VARCHAR2(30);
   l_cursor_hANDle   	NUMBER;

   l_sel_stmt           VARCHAR2(1024) ;
   l_sel_cursor       	NUMBER;
   l_sel_column		VARCHAR2(30);
   l_sel_rows		NUMBER;
   l_sel_execute	VARCHAR2(1024);

BEGIN

    SELECT application_column_name
    INTO   l_segment
    FROM   fnd_segment_attribute_values ,
           gl_ledgers sob
    WHERE  id_flex_code                    = 'GL#'
    AND    attribute_value                 = 'Y'
    AND    segment_attribute_type          = p_segment_type
    AND    application_id                  = 101
    AND    sob.chart_of_accounts_id        = id_flex_num
    AND    sob.ledger_id                   = p_ledger_id;

    EXECUTE IMMEDIATE ' SELECT '|| l_segment ||
                      ' FROM gl_code_combinations  WHERE code_combination_id = :p_ccid '
             INTO l_sel_column USING IN p_ccid;

    RETURN  l_sel_column;


EXCEPTION
  WHEN OTHERS THEN
       RETURN NULL ;
END get_account_segment_value;

END FUN_UTIL;


/
