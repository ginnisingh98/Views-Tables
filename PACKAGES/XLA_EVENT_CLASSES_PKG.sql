--------------------------------------------------------
--  DDL for Package XLA_EVENT_CLASSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_EVENT_CLASSES_PKG" AUTHID CURRENT_USER AS
/* $Header: xlaamdec.pkh 120.3 2004/11/20 01:08:29 wychan ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_event_classes_pkg                                              |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Event Classes Package                                          |
|                                                                       |
| HISTORY                                                               |
|    01-May-01 Dimple Shah    Created                                   |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| class_details_exist                                                   |
|                                                                       |
| Returns true if details of the class exist                            |
|                                                                       |
+======================================================================*/
FUNCTION class_details_exist
  (p_event                            IN VARCHAR2
  ,p_application_id                   IN NUMBER
  ,p_entity_code                      IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| delete_class_details                                                  |
|                                                                       |
| Deletes all details of the class                                      |
|                                                                       |
+======================================================================*/

PROCEDURE delete_class_details
  (p_application_id                   IN NUMBER
  ,p_entity_code                      IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2);

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| uncompile_definitions                                                 |
|                                                                       |
| Returns true if all the application accounting definitions and        |
| journal line definitions using this segment rule are uncompiled       |
|                                                                       |
+======================================================================*/

FUNCTION uncompile_definitions
  (p_application_id                  IN  NUMBER
  ,p_event_class_code                IN  VARCHAR2
  ,x_product_rule_name               IN OUT NOCOPY VARCHAR2
  ,x_product_rule_type               IN OUT NOCOPY VARCHAR2
  ,x_event_class_name                IN OUT NOCOPY VARCHAR2
  ,x_event_type_name                 IN OUT NOCOPY VARCHAR2
  ,x_locking_status_flag             IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| event_class_is_locked                                                 |
|                                                                       |
| Returns true if the line type is used by a frozen line definition     |
|                                                                       |
+======================================================================*/

FUNCTION event_class_is_locked
  (p_application_id                   IN NUMBER
  ,p_event_class_code                 IN VARCHAR2)
RETURN BOOLEAN;

END xla_event_classes_pkg;
 

/
