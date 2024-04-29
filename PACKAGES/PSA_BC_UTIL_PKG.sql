--------------------------------------------------------
--  DDL for Package PSA_BC_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSA_BC_UTIL_PKG" AUTHID CURRENT_USER AS
--  $Header: PSABCUTS.pls 120.0 2005/06/15 12:58:37 pmamdaba noship $ $

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

END PSA_BC_UTIL_PKG;

 

/
