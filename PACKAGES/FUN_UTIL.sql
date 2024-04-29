--------------------------------------------------------
--  DDL for Package FUN_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_UTIL" AUTHID CURRENT_USER AS
--  $Header: FUNVUTLS.pls 120.1 2005/07/14 10:38:18 bsilveir noship $

PROCEDURE log_conc_start(
    p_pkg_name     IN    VARCHAR2
,   p_proc_name    IN    VARCHAR2
,   p_progress     IN    VARCHAR2 DEFAULT NULL
);


PROCEDURE log_conc_end(
    p_pkg_name     IN    VARCHAR2
,   p_proc_name    IN    VARCHAR2
,   p_progress     IN    VARCHAR2 DEFAULT NULL
);

PROCEDURE log_conc_stmt(
    p_pkg_name     IN    VARCHAR2
,   p_proc_name    IN    VARCHAR2
,   p_progress     IN    VARCHAR2 DEFAULT NULL
,   p_name         IN    VARCHAR2 DEFAULT NULL
,   p_value        IN    VARCHAR2 DEFAULT NULL
);

PROCEDURE log_conc_unexp(
    p_pkg_name     IN    VARCHAR2
,   p_proc_name    IN    VARCHAR2
,   p_progress     IN    VARCHAR2 DEFAULT NULL
);

PROCEDURE log_conc_err(
    p_pkg_name     IN    VARCHAR2
,   p_proc_name    IN    VARCHAR2
,   p_progress     IN    VARCHAR2 DEFAULT NULL
,   p_msg          IN    VARCHAR2
);

FUNCTION get_account_segment_value (
    p_ledger_id      IN gl_ledgers.ledger_id%TYPE,
    p_ccid           IN gl_code_combinations.code_combination_id%TYPE,
    p_segment_type   IN VARCHAR2 )
 RETURN VARCHAR2 ;


END FUN_UTIL;

 

/
