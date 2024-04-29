--------------------------------------------------------
--  DDL for Package XLA_TAB_ACCT_DEFS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_TAB_ACCT_DEFS_PKG" AUTHID CURRENT_USER AS
/* $Header: xlatabtad.pkh 120.0 2003/08/20 23:05:51 dcshah noship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_tab_acct_defs_pkg                                              |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Tab Account Definitions package                                |
|                                                                       |
| HISTORY                                                               |
|    01-Sep-01 Dimple Shah    Created                                   |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| invalid_seg_rule                                                      |
|                                                                       |
| Returns true if sources used in the seg rule are invalid              |
| Used in the lov for descriptions                                      |
|                                                                       |
+======================================================================*/

FUNCTION invalid_segment_rule
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_account_type_code                IN VARCHAR2
  ,p_segment_rule_type_code           IN VARCHAR2
  ,p_segment_rule_code                IN VARCHAR2)
RETURN VARCHAR2;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| uncompile_tran_acct_def                                               |
|                                                                       |
| Returns true if the transaction account definition is uncompiled      |
|                                                                       |
+======================================================================*/

FUNCTION uncompile_tran_acct_def
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_account_definition_type_code     IN VARCHAR2
  ,p_account_definition_code          IN VARCHAR2)
RETURN BOOLEAN;


END xla_tab_acct_defs_pkg;
 

/
