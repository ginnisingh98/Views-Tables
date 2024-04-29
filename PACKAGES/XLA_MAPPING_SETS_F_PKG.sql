--------------------------------------------------------
--  DDL for Package XLA_MAPPING_SETS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_MAPPING_SETS_F_PKG" AUTHID CURRENT_USER AS
/* $Header: xlathmps.pkh 120.22 2005/05/05 23:08:31 wychan ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_mapping_sets                                                   |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_mapping_sets                          |
|                                                                       |
| HISTORY                                                               |
|    Generated from XLAUTB.                                             |
|                                                                       |
+======================================================================*/



PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_mapping_set_code                 IN VARCHAR2
  ,x_amb_context_code                 IN VARCHAR2
  ,x_view_application_id              IN NUMBER
  ,x_lookup_type                      IN VARCHAR2
  ,x_accounting_coa_id                IN NUMBER
  ,x_value_set_id                     IN NUMBER
  ,x_flexfield_assign_mode_code       IN VARCHAR2
  ,x_flexfield_segment_code           IN VARCHAR2
  ,x_enabled_flag                     IN VARCHAR2
  ,x_flex_value_set_id                IN NUMBER
  ,x_name                             IN VARCHAR2
  ,x_description                      IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER);

PROCEDURE lock_row
  (x_mapping_set_code                 IN VARCHAR2
  ,x_amb_context_code                 IN VARCHAR2
  ,x_view_application_id              IN NUMBER
  ,x_lookup_type                      IN VARCHAR2
  ,x_accounting_coa_id                IN NUMBER
  ,x_value_set_id                     IN NUMBER
  ,x_flexfield_assign_mode_code       IN VARCHAR2
  ,x_flexfield_segment_code           IN VARCHAR2
  ,x_enabled_flag                     IN VARCHAR2
  ,x_flex_value_set_id                IN NUMBER
  ,x_name                             IN VARCHAR2
  ,x_description                      IN VARCHAR2);

PROCEDURE update_row
 (x_mapping_set_code                 IN VARCHAR2
 ,x_amb_context_code                 IN VARCHAR2
 ,x_view_application_id              IN NUMBER
 ,x_lookup_type                      IN VARCHAR2
 ,x_accounting_coa_id                IN NUMBER
 ,x_value_set_id                     IN NUMBER
 ,x_flexfield_assign_mode_code       IN VARCHAR2
 ,x_flexfield_segment_code           IN VARCHAR2
 ,x_enabled_flag                     IN VARCHAR2
 ,x_flex_value_set_id                IN NUMBER
 ,x_name                             IN VARCHAR2
 ,x_description                      IN VARCHAR2
 ,x_last_update_date                 IN DATE
 ,x_last_updated_by                  IN NUMBER
 ,x_last_update_login                IN NUMBER);

PROCEDURE delete_row
  (x_mapping_set_code                 IN VARCHAR2
  ,x_amb_context_code                 IN VARCHAR2);

PROCEDURE add_language;

PROCEDURE translate_row
  (p_amb_context_code       IN VARCHAR2
  ,p_mapping_set_code       IN VARCHAR2
  ,p_name                   IN VARCHAR2
  ,p_description            IN VARCHAR2
  ,p_owner                  IN VARCHAR2
  ,p_last_update_date       IN VARCHAR2
  ,p_custom_mode            IN VARCHAR2);

END xla_mapping_sets_f_pkg;
 

/
