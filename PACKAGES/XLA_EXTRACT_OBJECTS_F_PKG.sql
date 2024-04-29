--------------------------------------------------------
--  DDL for Package XLA_EXTRACT_OBJECTS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_EXTRACT_OBJECTS_F_PKG" AUTHID CURRENT_USER AS
/* $Header: xlatbexo.pkh 120.6 2004/09/24 21:51:28 wychan ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_extract_objects                                                |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_extract_objects                       |
|                                                                       |
| HISTORY                                                               |
|    Generated from XLAUTB.                                             |
|                                                                       |
+======================================================================*/



PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_entity_code                      IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_object_name                      IN VARCHAR2
  ,x_object_type_code                 IN VARCHAR2
  ,x_always_populated_flag             IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER);

PROCEDURE lock_row
  (x_application_id                   IN NUMBER
  ,x_entity_code                      IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_object_name                      IN VARCHAR2
  ,x_object_type_code                 IN VARCHAR2
  ,x_always_populated_flag             IN VARCHAR2);

PROCEDURE update_row
 (x_application_id                   IN NUMBER
 ,x_entity_code                      IN VARCHAR2
 ,x_event_class_code                 IN VARCHAR2
 ,x_object_name                      IN VARCHAR2
 ,x_object_type_code                 IN VARCHAR2
 ,x_always_populated_flag             IN VARCHAR2
 ,x_last_update_date                 IN DATE
 ,x_last_updated_by                  IN NUMBER
 ,x_last_update_login                IN NUMBER);

PROCEDURE delete_row
 (x_application_id                   IN NUMBER
 ,x_entity_code                      IN VARCHAR2
 ,x_event_class_code                 IN VARCHAR2
 ,x_object_name                      IN VARCHAR2);

PROCEDURE load_row
(p_application_short_name             IN VARCHAR2
,p_entity_code                        IN VARCHAR2
,p_event_class_code                   IN VARCHAR2
,p_object_name                        IN VARCHAR2
,p_object_type_code                   IN VARCHAR2
,p_always_populated_flag              IN VARCHAR2
,p_owner                              IN VARCHAR2
,p_last_update_date                   IN VARCHAR2);

END xla_extract_objects_f_pkg;
 

/
