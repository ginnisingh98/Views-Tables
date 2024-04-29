--------------------------------------------------------
--  DDL for Package XLA_ENTITY_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_ENTITY_TYPES_PKG" AUTHID CURRENT_USER AS
/* $Header: xlaamdee.pkh 120.3 2004/11/20 01:10:12 wychan ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_entity_types_pkg                                               |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Entity Types Package                                           |
|                                                                       |
| HISTORY                                                               |
|    01-May-01 Dimple Shah    Created                                   |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| event_classes_exist                                                   |
|                                                                       |
| Returns true if event classes exist for the entity                    |
|                                                                       |
+======================================================================*/
FUNCTION event_classes_exist
  (p_event                            IN VARCHAR2
  ,p_application_id                   IN NUMBER
  ,p_entity_code                      IN VARCHAR2)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| delete_entity_details                                                 |
|                                                                       |
| Deletes all details of the entity                                     |
|                                                                       |
+======================================================================*/

PROCEDURE delete_entity_details
  (p_application_id                   IN NUMBER
  ,p_entity_code                      IN VARCHAR2);

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| uncompile_definitions                                                 |
|                                                                       |
| Returns true if all the product rules for the entity are uncompiled   |
|                                                                       |
+======================================================================*/

FUNCTION uncompile_definitions
  (p_application_id                  IN NUMBER
  ,p_entity_code                     IN VARCHAR2
  ,x_product_rule_name               IN OUT NOCOPY VARCHAR2
  ,x_product_rule_type               IN OUT NOCOPY VARCHAR2
  ,x_event_class_name                IN OUT NOCOPY VARCHAR2
  ,x_event_type_name                 IN OUT NOCOPY VARCHAR2
  ,x_locking_status_flag             IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

END xla_entity_types_pkg;
 

/
