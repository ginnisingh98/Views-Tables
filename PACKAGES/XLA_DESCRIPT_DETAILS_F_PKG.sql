--------------------------------------------------------
--  DDL for Package XLA_DESCRIPT_DETAILS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_DESCRIPT_DETAILS_F_PKG" AUTHID CURRENT_USER AS
/* $Header: xlathded.pkh 120.16 2005/05/18 23:21:00 wychan ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_descript_details                                               |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_descript_details                      |
|                                                                       |
| HISTORY                                                               |
|    Generated from XLAUTB.                                             |
|                                                                       |
+======================================================================*/



PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_description_detail_id            IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_flexfield_segment_code           IN VARCHAR2
  ,x_display_description_flag         IN VARCHAR2
  ,x_description_prio_id              IN NUMBER
  ,x_user_sequence                    IN NUMBER
  ,x_value_type_code                  IN VARCHAR2
  ,x_source_application_id            IN NUMBER
  ,x_source_type_code                 IN VARCHAR2
  ,x_source_code                      IN VARCHAR2
  ,x_literal                          IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER);

PROCEDURE lock_row
  (x_description_detail_id            IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_flexfield_segment_code           IN VARCHAR2
  ,x_display_description_flag         IN VARCHAR2
  ,x_description_prio_id              IN NUMBER
  ,x_user_sequence                    IN NUMBER
  ,x_value_type_code                  IN VARCHAR2
  ,x_source_application_id            IN NUMBER
  ,x_source_type_code                 IN VARCHAR2
  ,x_source_code                      IN VARCHAR2
  ,x_literal                          IN VARCHAR2);

PROCEDURE update_row
 (x_description_detail_id            IN NUMBER
 ,x_amb_context_code                 IN VARCHAR2
 ,x_flexfield_segment_code           IN VARCHAR2
 ,x_display_description_flag         IN VARCHAR2
 ,x_description_prio_id              IN NUMBER
 ,x_user_sequence                    IN NUMBER
 ,x_value_type_code                  IN VARCHAR2
 ,x_source_application_id            IN NUMBER
 ,x_source_type_code                 IN VARCHAR2
 ,x_source_code                      IN VARCHAR2
 ,x_literal                          IN VARCHAR2
 ,x_last_update_date                 IN DATE
 ,x_last_updated_by                  IN NUMBER
 ,x_last_update_login                IN NUMBER);

PROCEDURE delete_row
  (x_description_detail_id            IN NUMBER);

PROCEDURE add_language;

PROCEDURE translate_row
  (p_application_short_name      IN VARCHAR2
  ,p_amb_context_code            IN VARCHAR2
  ,p_description_type_code       IN VARCHAR2
  ,p_description_code            IN VARCHAR2
  ,p_priority_num                IN VARCHAR2
  ,p_user_sequence               IN VARCHAR2
  ,p_literal                     IN VARCHAR2
  ,p_owner                       IN VARCHAR2
  ,p_last_update_date            IN VARCHAR2
  ,p_custom_mode                 IN VARCHAR2);

END xla_descript_details_f_pkg;
 

/
