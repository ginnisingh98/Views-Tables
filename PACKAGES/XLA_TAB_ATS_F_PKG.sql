--------------------------------------------------------
--  DDL for Package XLA_TAB_ATS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_TAB_ATS_F_PKG" AUTHID CURRENT_USER AS
/* $Header: xlathtabats.pkh 120.0 2005/09/05 16:51:39 jlarre noship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_tab_ats_f_pkg                                                  |
|                                                                       |
| DESCRIPTION                                                           |
|    Plsql table handler for table xla_tab_acct_type_srcs               |
|                                                                       |
| HISTORY                                                               |
|   01-SEP-2005 Jorge Larre Initial Creation                            |
|                                                                       |
+======================================================================*/

PROCEDURE trace
  (p_msg                              IN VARCHAR2
  ,p_module                           IN VARCHAR2
  ,p_level                            IN NUMBER);

PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_account_type_code                IN VARCHAR2
  ,x_source_application_id            IN NUMBER
  ,x_source_type_code                 IN VARCHAR2
  ,x_source_code                      IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER);

PROCEDURE lock_row
  (x_application_id                   IN NUMBER
  ,x_account_type_code                IN VARCHAR2
  ,x_source_application_id            IN NUMBER
  ,x_source_type_code                 IN VARCHAR2
  ,x_source_code                      IN VARCHAR2);

PROCEDURE update_row
  (x_application_id                   IN NUMBER
  ,x_account_type_code                IN VARCHAR2
  ,x_source_application_id            IN NUMBER
  ,x_source_type_code                 IN VARCHAR2
  ,x_source_code                      IN VARCHAR2
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER);

PROCEDURE delete_row
  (x_application_id                   IN NUMBER
  ,x_account_type_code                IN VARCHAR2
  ,x_source_application_id            IN NUMBER
  ,x_source_type_code                 IN VARCHAR2
  ,x_source_code                      IN VARCHAR2);

PROCEDURE load_row
  (p_application_short_name           IN VARCHAR2
  ,p_account_type_code                IN VARCHAR2
  ,p_source_app_short_name            IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2
  ,p_source_code                      IN VARCHAR2
  ,p_owner                            IN VARCHAR2
  ,p_last_update_date                 IN VARCHAR2);

END xla_tab_ats_f_pkg;
 

/
