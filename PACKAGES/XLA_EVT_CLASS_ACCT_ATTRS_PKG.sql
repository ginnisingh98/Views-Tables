--------------------------------------------------------
--  DDL for Package XLA_EVT_CLASS_ACCT_ATTRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_EVT_CLASS_ACCT_ATTRS_PKG" AUTHID CURRENT_USER AS
/* $Header: xlaamaaa.pkh 120.2 2006/06/28 00:08:59 svjoshi ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_evt_class_acct_attrs_pkg                                       |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Event Class accounting attributes Package                      |
|                                                                       |
| HISTORY                                                               |
|    01-May-01 Dimple Shah    Created                                   |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| insert_jlt_assignments                                                |
|                                                                       |
| Inserts accounting accounting attributes                              |
| in the line types for the event class                                 |
|                                                                       |
+======================================================================*/
FUNCTION insert_jlt_assignments
  (p_application_id                   IN NUMBER
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_attribute_code        IN VARCHAR2
  ,p_source_application_id            IN NUMBER
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2
  ,p_default_flag                     IN VARCHAR2
  ,p_product_rule_name                IN OUT NOCOPY VARCHAR2
  ,p_product_rule_type                IN OUT NOCOPY VARCHAR2
  ,p_event_class_name                 IN OUT NOCOPY VARCHAR2
  ,p_event_type_name                  IN OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                      |
|                                                                       |
| update_jlt_assignments                                                |
|                                                                       |
| Updates accounting accounting attributes                              |
| in the line types for the event class                                 |
|                                                                       |
+======================================================================*/
FUNCTION update_jlt_assignments
  (p_application_id                   IN NUMBER
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_attribute_code        IN VARCHAR2
  ,p_source_application_id            IN NUMBER
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2
  ,p_default_flag                     IN VARCHAR2
  ,p_product_rule_name                IN OUT NOCOPY VARCHAR2
  ,p_product_rule_type                IN OUT NOCOPY VARCHAR2
  ,p_event_class_name                 IN OUT NOCOPY VARCHAR2
  ,p_event_type_name                  IN OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                      |
|                                                                       |
| delete_jlt_assignments                                                |
|                                                                       |
| Deletes accounting accounting attributes                              |
| in the line types for the event class                                 |
|                                                                       |
+======================================================================*/
Function delete_jlt_assignments
  (p_application_id                   IN NUMBER
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_attribute_code        IN VARCHAR2
  ,p_source_application_id            IN NUMBER
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2
  ,p_product_rule_name                IN OUT NOCOPY VARCHAR2
  ,p_product_rule_type                IN OUT NOCOPY VARCHAR2
  ,p_event_class_name                 IN OUT NOCOPY VARCHAR2
  ,p_event_type_name                  IN OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                      |
|                                                                       |
| insert_aad_assignments                                                |
|                                                                       |
| Inserts accounting accounting attributes                              |
| in the AADs for the event class                                       |
|                                                                       |
+======================================================================*/
Function insert_aad_assignments
  (p_application_id                   IN NUMBER
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_attribute_code        IN VARCHAR2
  ,p_source_application_id            IN NUMBER
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2
  ,p_default_flag                     IN VARCHAR2
  ,p_product_rule_name                IN OUT NOCOPY VARCHAR2
  ,p_product_rule_type                IN OUT NOCOPY VARCHAR2
  ,p_event_class_name                 IN OUT NOCOPY VARCHAR2
  ,p_event_type_name                  IN OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                      |
|                                                                       |
| update_aad_assignments                                                |
|                                                                       |
| Updates accounting accounting attributes                              |
| in the AADs for the event class                                       |
|                                                                       |
+======================================================================*/
Function update_aad_assignments
  (p_application_id                   IN NUMBER
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_attribute_code        IN VARCHAR2
  ,p_source_application_id            IN NUMBER
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2
  ,p_default_flag                     IN VARCHAR2
  ,p_product_rule_name                IN OUT NOCOPY VARCHAR2
  ,p_product_rule_type                IN OUT NOCOPY VARCHAR2
  ,p_event_class_name                 IN OUT NOCOPY VARCHAR2
  ,p_event_type_name                  IN OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                      |
|                                                                       |
| delete_aad_assignments                                                |
|                                                                       |
| Deletes accounting accounting attributes                              |
| in the AADs for the event class                                       |
|                                                                       |
+======================================================================*/
Function delete_aad_assignments
  (p_application_id                   IN NUMBER
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_attribute_code        IN VARCHAR2
  ,p_source_application_id            IN NUMBER
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2
  ,p_product_rule_name                IN OUT NOCOPY VARCHAR2
  ,p_product_rule_type                IN OUT NOCOPY VARCHAR2
  ,p_event_class_name                 IN OUT NOCOPY VARCHAR2
  ,p_event_type_name                  IN OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| uncompile_evt_class_aads                                              |
|                                                                       |
| Uncompile AADs using event class.                                     |
|                                                                       |
+======================================================================*/
  FUNCTION uncompile_evt_class_aads
  (p_application_id                  IN NUMBER
  ,p_event_class_code                IN VARCHAR2
  ,x_product_rule_name               IN OUT NOCOPY VARCHAR2
  ,x_product_rule_type               IN OUT NOCOPY VARCHAR2
  ,x_event_class_name                IN OUT NOCOPY VARCHAR2
  ,x_event_type_name                 IN OUT NOCOPY VARCHAR2
  ,x_locking_status_flag             IN OUT NOCOPY VARCHAR2
  ,x_validation_status_code          IN OUT NOCOPY VARCHAR2
  )
RETURN BOOLEAN;
END xla_evt_class_acct_attrs_pkg;
 

/
