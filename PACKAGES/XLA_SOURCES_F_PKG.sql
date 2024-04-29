--------------------------------------------------------
--  DDL for Package XLA_SOURCES_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_SOURCES_F_PKG" AUTHID CURRENT_USER AS
/* $Header: xlathsou.pkh 120.19 2006/03/13 22:09:45 svjoshi ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_sources                                                        |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_sources                               |
|                                                                       |
| HISTORY                                                               |
|    Generated from XLAUTB.                                             |
|                                                                       |
+======================================================================*/



PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_source_code                      IN VARCHAR2
  ,x_source_type_code                 IN VARCHAR2
  ,x_plsql_function_name              IN VARCHAR2
  ,x_flex_value_set_id                IN NUMBER
  ,x_sum_flag                         IN VARCHAR2
  ,x_visible_flag                     IN VARCHAR2
  ,x_translated_flag                  IN VARCHAR2
  ,x_lookup_type                      IN VARCHAR2
  ,x_view_application_id              IN NUMBER
  ,x_datatype_code                    IN VARCHAR2
  ,x_enabled_flag                     IN VARCHAR2
  ,x_key_flexfield_flag               IN VARCHAR2
  ,x_segment_code                     IN VARCHAR2
  ,x_flexfield_application_id         IN NUMBER
  ,x_id_flex_code                     IN VARCHAR2
  ,x_name                             IN VARCHAR2
  ,x_description                      IN VARCHAR2
  ,x_source_column_name               IN VARCHAR2
  ,x_source_table_name                IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER);

PROCEDURE lock_row
  (x_application_id                   IN NUMBER
  ,x_source_code                      IN VARCHAR2
  ,x_source_type_code                 IN VARCHAR2
  ,x_plsql_function_name              IN VARCHAR2
  ,x_flex_value_set_id                IN NUMBER
  ,x_sum_flag                         IN VARCHAR2
  ,x_visible_flag                     IN VARCHAR2
  ,x_translated_flag                  IN VARCHAR2
  ,x_lookup_type                      IN VARCHAR2
  ,x_view_application_id              IN NUMBER
  ,x_datatype_code                    IN VARCHAR2
  ,x_enabled_flag                     IN VARCHAR2
  ,x_key_flexfield_flag               IN VARCHAR2
  ,x_segment_code                     IN VARCHAR2
  ,x_flexfield_application_id         IN NUMBER
  ,x_id_flex_code                     IN VARCHAR2
  ,x_name                             IN VARCHAR2
  ,x_description                      IN VARCHAR2);

PROCEDURE update_row
 (x_application_id                   IN NUMBER
 ,x_source_code                      IN VARCHAR2
 ,x_source_type_code                 IN VARCHAR2
 ,x_plsql_function_name              IN VARCHAR2
 ,x_flex_value_set_id                IN NUMBER
 ,x_sum_flag                         IN VARCHAR2
 ,x_visible_flag                     IN VARCHAR2
 ,x_translated_flag                  IN VARCHAR2
 ,x_lookup_type                      IN VARCHAR2
 ,x_view_application_id              IN NUMBER
 ,x_datatype_code                    IN VARCHAR2
 ,x_enabled_flag                     IN VARCHAR2
 ,x_key_flexfield_flag               IN VARCHAR2
 ,x_segment_code                     IN VARCHAR2
 ,x_flexfield_application_id         IN NUMBER
 ,x_id_flex_code                     IN VARCHAR2
 ,x_name                             IN VARCHAR2
 ,x_description                      IN VARCHAR2
 ,x_source_column_name               IN VARCHAR2
 ,x_source_table_name                IN VARCHAR2
 ,x_last_update_date                 IN DATE
 ,x_last_updated_by                  IN NUMBER
 ,x_last_update_login                IN NUMBER);

PROCEDURE delete_row
  (x_application_id                   IN NUMBER
  ,x_source_code                      IN VARCHAR2
  ,x_source_type_code                 IN VARCHAR2);
PROCEDURE add_language;

PROCEDURE load_row
  (p_appl_short_name                  IN VARCHAR2
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2
  ,p_datatype_code                    IN VARCHAR2
  ,p_plsql_function_name              IN VARCHAR2
  ,p_flex_value_set_name              IN VARCHAR2
  ,p_sum_flag                         IN VARCHAR2
  ,p_visible_flag                     IN VARCHAR2
  ,p_translated_flag                  IN VARCHAR2
  ,p_enabled_flag                     IN VARCHAR2
  ,p_view_appl_short_name             IN VARCHAR2
  ,p_lookup_type                      IN VARCHAR2
  ,p_key_flexfield_flag               IN VARCHAR2
  ,p_segment_code                     IN VARCHAR2
  ,p_flex_appl_short_name             IN VARCHAR2
  ,p_id_flex_code                     IN VARCHAR2
  ,p_name                             IN VARCHAR2
  ,p_description                      IN VARCHAR2
  ,p_owner                            IN VARCHAR2
  ,p_source_column_name               IN VARCHAR2
  ,p_source_table_name                IN VARCHAR2
  ,p_last_update_date                 IN VARCHAR2
  ,p_custom_mode                      IN VARCHAR2);

PROCEDURE translate_row
  (p_appl_short_name                  IN VARCHAR2
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2
  ,p_name                             IN VARCHAR2
  ,p_description                      IN VARCHAR2
  ,p_owner                            IN VARCHAR2
  ,p_last_update_date                 IN VARCHAR2
  ,p_custom_mode                      IN VARCHAR2);

END xla_sources_f_pkg;
 

/
