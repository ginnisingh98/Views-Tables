--------------------------------------------------------
--  DDL for Package XLA_CONTEXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_CONTEXT_PKG" AUTHID CURRENT_USER AS
-- $Header: xlacmctx.pkh 120.3 2006/06/27 20:32:37 masada ship $
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| FILENAME                                                                   |
|    xlacmctx.pkh                                                            |
|                                                                            |
| PACKAGE NAME                                                               |
|    xla_context_pkg                                                         |
|                                                                            |
| DESCRIPTION                                                                |
|    This context package is used to set the attribute values for the        |
|    application context namespace "XLA"                                     |
|                                                                            |
| HISTORY                                                                    |
|    23-Jan-03  S. Singhania       Created                                   |
|    17-Apr-03  S. Singhania       Added specifications for the following:   |
|                                    - set_acct_err_context                  |
|                                    - get_acct_err_context                  |
|                                    - clear_acct_err_context                |
|    12-Oct-05  A.Wan              4645092 - MPA report changes              |
|                                                                            |
+===========================================================================*/

PROCEDURE set_security_context
       (p_security_group             IN  VARCHAR2);

PROCEDURE set_acct_err_context
       (p_error_count                IN NUMBER
       ,p_client_id                  IN VARCHAR2);

FUNCTION get_acct_err_context
RETURN NUMBER;

PROCEDURE clear_acct_err_context
       (p_client_id                  IN VARCHAR2);

---------------------------------------------------------------------
-- 4262811 MPA-Accrual context
---------------------------------------------------------------------
PROCEDURE set_mpa_accrual_context
       (p_mpa_accrual_exists         IN VARCHAR2
       ,p_client_id                  IN VARCHAR2 DEFAULT NULL);

FUNCTION get_mpa_accrual_context
RETURN VARCHAR2;

PROCEDURE clear_mpa_accrual_context
       (p_client_id                  IN VARCHAR2);

---------------------------------------------------------------------
-- 4865292 Event context
---------------------------------------------------------------------
PROCEDURE set_event_count_context
       (p_event_count                IN NUMBER
       ,p_client_id                  IN VARCHAR2 DEFAULT NULL);

FUNCTION get_event_count_context
RETURN NUMBER;

PROCEDURE set_event_nohdr_context
       (p_nohdr_extract_flag         IN VARCHAR2
       ,p_client_id                  IN VARCHAR2 DEFAULT NULL);

FUNCTION get_event_nohdr_context
RETURN VARCHAR2;

PROCEDURE clear_event_context
       (p_client_id                  IN VARCHAR2);

END xla_context_pkg;
 

/
