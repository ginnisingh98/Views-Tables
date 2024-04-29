--------------------------------------------------------
--  DDL for Package XLA_REFERENCE_OBJECTS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_REFERENCE_OBJECTS_F_PKG" AUTHID CURRENT_USER AS
/* $Header: xlatbrfo.pkh 120.3.12010000.2 2009/10/09 11:49:27 karamakr ship $ */
/*==========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                    |
|                       Redwood Shores, CA, USA                             |
|                         All rights reserved.                              |
+===========================================================================+
| PACKAGE NAME                                                              |
|    xla_reference_objects_f_pkg                                            |
|                                                                           |
| DESCRIPTION                                                               |
|    Forms PL/SQL Wrapper for xla_reference_objects                         |
|                                                                           |
| HISTORY                                                                   |
|    2005/03/20   M. Asada  Created.                                        |
|                                                                           |
+==========================================================================*/

PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_entity_code                      IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_object_name                      IN VARCHAR2
  ,x_reference_object_appl_id         IN NUMBER
  ,x_reference_object_name            IN VARCHAR2
  ,x_linked_to_ref_obj_appl_id        IN NUMBER
  ,x_linked_to_ref_obj_name           IN VARCHAR2
  ,x_join_condition                   IN VARCHAR2
  ,x_always_populated_flag            IN VARCHAR2
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
  ,x_reference_object_appl_id         IN NUMBER
  ,x_reference_object_name            IN VARCHAR2
  ,x_linked_to_ref_obj_appl_id        IN NUMBER
  ,x_linked_to_ref_obj_name           IN VARCHAR2
  ,x_join_condition                   IN VARCHAR2
  ,x_always_populated_flag            IN VARCHAR2);

PROCEDURE update_row
  (x_application_id                   IN NUMBER
  ,x_entity_code                      IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_object_name                      IN VARCHAR2
  ,x_reference_object_appl_id         IN NUMBER
  ,x_reference_object_name            IN VARCHAR2
  ,x_linked_to_ref_obj_appl_id        IN NUMBER    DEFAULT NULL
  ,x_linked_to_ref_obj_name           IN VARCHAR2  DEFAULT NULL
  ,x_join_condition                   IN VARCHAR2
  ,x_always_populated_flag            IN VARCHAR2
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER);

PROCEDURE delete_row
  (x_application_id                   IN NUMBER
  ,x_entity_code                      IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_object_name                      IN VARCHAR2
  ,x_reference_object_appl_id         IN NUMBER
  ,x_reference_object_name            IN VARCHAR2);

PROCEDURE load_row
  (p_application_short_name             IN VARCHAR2
  ,p_entity_code                        IN VARCHAR2
  ,p_event_class_code                   IN VARCHAR2
  ,p_object_name                        IN VARCHAR2
  ,p_reference_object_appl_id           IN NUMBER
  ,p_reference_object_name              IN VARCHAR2
  ,p_linked_to_ref_obj_appl_id          IN NUMBER
  ,p_linked_to_ref_obj_name             IN VARCHAR2
  ,p_join_condition                     IN VARCHAR2
  ,p_always_populated_flag              IN VARCHAR2
  ,p_owner                              IN VARCHAR2
  ,p_last_update_date                   IN VARCHAR2);

END xla_reference_objects_f_pkg;

/
