--------------------------------------------------------
--  DDL for Package XLA_TAB_ACCT_TYPES_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_TAB_ACCT_TYPES_F_PKG" AUTHID CURRENT_USER AS
/* $Header: xlathtabact.pkh 120.5 2005/09/02 18:15:19 jlarre noship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_tab_acct_types                                                 |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_tab_acct_types                        |
|                                                                       |
| HISTORY                                                               |
|    Generated from XLAUTB.                                             |
|    01-SEP-2005 Jorge Larre                                            |
|       Add procedure translate_row and load_row to use with FNDLOAD in |
|       conjunction with the file xlatabseed.lct. Bug 4590464.          |
|                                                                       |
+======================================================================*/

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ACCOUNT_TYPE_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_RULE_ASSIGNMENT_CODE in VARCHAR2,
  X_COMPILE_STATUS_CODE in VARCHAR2,
  X_OBJECT_NAME_AFFIX in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ACCOUNT_TYPE_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_RULE_ASSIGNMENT_CODE in VARCHAR2,
  X_COMPILE_STATUS_CODE in VARCHAR2,
  X_OBJECT_NAME_AFFIX in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);

procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ACCOUNT_TYPE_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_RULE_ASSIGNMENT_CODE in VARCHAR2,
  X_COMPILE_STATUS_CODE in VARCHAR2,
  X_OBJECT_NAME_AFFIX in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ACCOUNT_TYPE_CODE in VARCHAR2
);

procedure ADD_LANGUAGE;

PROCEDURE trace
  (p_msg                        IN VARCHAR2
  ,p_module                     IN VARCHAR2
  ,p_level                      IN NUMBER);

PROCEDURE translate_row
  (p_application_short_name      IN VARCHAR2
  ,p_account_type_code           IN VARCHAR2
  ,p_name                        IN VARCHAR2
  ,p_description                 IN VARCHAR2
  ,p_owner                       IN VARCHAR2
  ,p_last_update_date            IN VARCHAR2
  ,p_custom_mode                 IN VARCHAR2);

PROCEDURE load_row
  (p_application_short_name      IN VARCHAR2
  ,p_account_type_code           IN VARCHAR2
  ,p_enabled_flag                IN VARCHAR2
  ,p_rule_assignment_code        IN VARCHAR2
  ,p_compile_status_code         IN VARCHAR2
  ,p_object_name_affix           IN VARCHAR2
  ,p_name                        IN VARCHAR2
  ,p_description                 IN VARCHAR2
  ,p_owner                       IN VARCHAR2
  ,p_last_update_date            IN VARCHAR2);


END xla_tab_acct_types_f_pkg;
 

/
