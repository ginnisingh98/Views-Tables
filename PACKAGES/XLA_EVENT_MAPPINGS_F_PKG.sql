--------------------------------------------------------
--  DDL for Package XLA_EVENT_MAPPINGS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_EVENT_MAPPINGS_F_PKG" AUTHID CURRENT_USER AS
/* $Header: xlathevm.pkh 120.13.12000000.2 2007/07/04 15:03:33 vkasina ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_event_mappings                                                 |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_event_mappings                        |
|                                                                       |
| HISTORY                                                               |
|    Generated from XLAUTB.                                             |
|                                                                       |
+======================================================================*/



PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_event_mapping_id                 IN NUMBER
  ,x_application_id                   IN NUMBER
  ,x_entity_code                      IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_user_sequence                    IN NUMBER
  ,x_column_name                      IN VARCHAR2
  ,x_column_title                     IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER);

PROCEDURE lock_row
  (x_event_mapping_id                 IN NUMBER
  ,x_application_id                   IN NUMBER
  ,x_entity_code                      IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_user_sequence                    IN NUMBER
  ,x_column_name                      IN VARCHAR2
  ,x_column_title                     IN VARCHAR2);

PROCEDURE update_row
 (x_event_mapping_id                 IN NUMBER
 ,x_application_id                   IN NUMBER
 ,x_entity_code                      IN VARCHAR2
 ,x_event_class_code                 IN VARCHAR2
 ,x_user_sequence                    IN NUMBER
 ,x_column_name                      IN VARCHAR2
 ,x_column_title                     IN VARCHAR2
 ,x_last_update_date                 IN DATE
 ,x_last_updated_by                  IN NUMBER
 ,x_last_update_login                IN NUMBER);

PROCEDURE delete_row
  (x_event_mapping_id                 IN NUMBER);

PROCEDURE add_language;

PROCEDURE load_row
(p_application_short_name             IN VARCHAR2
,p_entity_code                        IN VARCHAR2
,p_event_class_code                   IN VARCHAR2
,p_user_sequence                      IN VARCHAR2
,p_column_name                        IN VARCHAR2
,p_owner                              IN VARCHAR2
,p_last_update_date                   IN VARCHAR2
,p_column_title                       IN VARCHAR2);

PROCEDURE translate_row
  (p_application_short_name           IN VARCHAR2
  ,p_entity_code                      IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_user_sequence                    IN VARCHAR2
  ,p_column_name                      IN VARCHAR2
  ,p_column_title                     IN VARCHAR2
  ,p_owner                            IN VARCHAR2
  ,p_last_update_date                 IN VARCHAR2
  ,p_custom_mode                      IN VARCHAR2);

END xla_event_mappings_f_pkg;
 

/
