--------------------------------------------------------
--  DDL for Package XLA_TAB_ACCT_DEFS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_TAB_ACCT_DEFS_F_PKG" AUTHID CURRENT_USER AS
/* $Header: xlathtabacd.pkh 120.2 2003/10/02 01:57:59 dcshah noship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_tab_acct_defs                                                  |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_tab_acct_defs                         |
|                                                                       |
| HISTORY                                                               |
|    Generated from XLAUTB.                                             |
|                                                                       |
+======================================================================*/

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_AMB_CONTEXT_CODE in VARCHAR2,
  X_ACCOUNT_DEFINITION_TYPE_CODE in VARCHAR2,
  X_ACCOUNT_DEFINITION_CODE in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_CHART_OF_ACCOUNTS_ID in NUMBER,
  X_COMPILE_STATUS_CODE in VARCHAR2,
  X_LOCKING_STATUS_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_AMB_CONTEXT_CODE in VARCHAR2,
  X_ACCOUNT_DEFINITION_TYPE_CODE in VARCHAR2,
  X_ACCOUNT_DEFINITION_CODE in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_CHART_OF_ACCOUNTS_ID in NUMBER,
  X_COMPILE_STATUS_CODE in VARCHAR2,
  X_LOCKING_STATUS_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);

procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_AMB_CONTEXT_CODE in VARCHAR2,
  X_ACCOUNT_DEFINITION_TYPE_CODE in VARCHAR2,
  X_ACCOUNT_DEFINITION_CODE in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_CHART_OF_ACCOUNTS_ID in NUMBER,
  X_COMPILE_STATUS_CODE in VARCHAR2,
  X_LOCKING_STATUS_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_AMB_CONTEXT_CODE in VARCHAR2,
  X_ACCOUNT_DEFINITION_TYPE_CODE in VARCHAR2,
  X_ACCOUNT_DEFINITION_CODE in VARCHAR2
);

procedure ADD_LANGUAGE;

END xla_tab_acct_defs_f_pkg;
 

/
