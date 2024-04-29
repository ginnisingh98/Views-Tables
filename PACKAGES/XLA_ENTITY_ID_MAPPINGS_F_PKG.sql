--------------------------------------------------------
--  DDL for Package XLA_ENTITY_ID_MAPPINGS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_ENTITY_ID_MAPPINGS_F_PKG" AUTHID CURRENT_USER AS
/* $Header: xlatheim.pkh 120.0 2004/09/24 21:55:10 wychan noship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_entity_id_mappings_f_pkg                                       |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_entity_id_mappings                    |
|                                                                       |
| HISTORY                                                               |
|    09/24/04 W Chan     Created                                        |
|                                                                       |
+======================================================================*/



PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_entity_code                      IN VARCHAR2
  ,x_transaction_id_col_name_1        IN VARCHAR2
  ,x_transaction_id_col_name_2        IN VARCHAR2
  ,x_transaction_id_col_name_3        IN VARCHAR2
  ,x_transaction_id_col_name_4        IN VARCHAR2
  ,x_source_id_col_name_1             IN VARCHAR2
  ,x_source_id_col_name_2             IN VARCHAR2
  ,x_source_id_col_name_3             IN VARCHAR2
  ,x_source_id_col_name_4             IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER);

PROCEDURE lock_row
  (x_application_id                   IN NUMBER
  ,x_entity_code                      IN VARCHAR2
  ,x_transaction_id_col_name_1        IN VARCHAR2
  ,x_transaction_id_col_name_2        IN VARCHAR2
  ,x_transaction_id_col_name_3        IN VARCHAR2
  ,x_transaction_id_col_name_4        IN VARCHAR2
  ,x_source_id_col_name_1             IN VARCHAR2
  ,x_source_id_col_name_2             IN VARCHAR2
  ,x_source_id_col_name_3             IN VARCHAR2
  ,x_source_id_col_name_4             IN VARCHAR2);

PROCEDURE update_row
 (x_application_id                   IN NUMBER
 ,x_entity_code                      IN VARCHAR2
 ,x_transaction_id_col_name_1        IN VARCHAR2
 ,x_transaction_id_col_name_2        IN VARCHAR2
 ,x_transaction_id_col_name_3        IN VARCHAR2
 ,x_transaction_id_col_name_4        IN VARCHAR2
 ,x_source_id_col_name_1             IN VARCHAR2
 ,x_source_id_col_name_2             IN VARCHAR2
 ,x_source_id_col_name_3             IN VARCHAR2
 ,x_source_id_col_name_4             IN VARCHAR2
 ,x_last_update_date                 IN DATE
 ,x_last_updated_by                  IN NUMBER
 ,x_last_update_login                IN NUMBER);

PROCEDURE delete_row
  (x_application_id                   IN NUMBER
  ,x_entity_code                      IN VARCHAR2);

PROCEDURE load_row
(p_application_short_name             IN VARCHAR2
,p_entity_code                        IN VARCHAR2
,p_transaction_id_col_name_1          IN VARCHAR2
,p_transaction_id_col_name_2          IN VARCHAR2
,p_transaction_id_col_name_3          IN VARCHAR2
,p_transaction_id_col_name_4          IN VARCHAR2
,p_source_id_col_name_1               IN VARCHAR2
,p_source_id_col_name_2               IN VARCHAR2
,p_source_id_col_name_3               IN VARCHAR2
,p_source_id_col_name_4               IN VARCHAR2
,p_owner                              IN VARCHAR2
,p_last_update_date                   IN VARCHAR2);

END xla_entity_id_mappings_f_pkg;
 

/
