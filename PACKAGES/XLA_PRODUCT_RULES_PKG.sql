--------------------------------------------------------
--  DDL for Package XLA_PRODUCT_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_PRODUCT_RULES_PKG" AUTHID CURRENT_USER AS
/* $Header: xlaampad.pkh 120.19 2006/02/22 22:35:17 dcshah ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_product_rules_pkg                                              |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Product Rules package                                          |
|                                                                       |
| HISTORY                                                               |
|    01-Sep-01 Dimple Shah    Created                                   |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| delete_product_rule_details                                           |
|                                                                       |
| Deletes all details of the Product Rule                               |
|                                                                       |
+======================================================================*/

PROCEDURE delete_product_rule_details
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_product_rule_type_code           IN VARCHAR2
  ,p_product_rule_code                IN VARCHAR2);

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| delete_prod_header_details                                            |
|                                                                       |
| Deletes all details of the event class and event type assignment      |
|                                                                       |
+======================================================================*/

PROCEDURE delete_prod_header_details
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_product_rule_type_code           IN VARCHAR2
  ,p_product_rule_code                IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2);

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| copy_product_rule_details                                             |
|                                                                       |
| Copies the details of the old product rule into the new product rule  |
|                                                                       |
+======================================================================*/

 PROCEDURE copy_product_rule_details
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_old_product_rule_type_code       IN VARCHAR2
  ,p_old_product_rule_code            IN VARCHAR2
  ,p_new_product_rule_type_code       IN VARCHAR2
  ,p_new_product_rule_code            IN VARCHAR2
  ,p_include_header_assignments       IN VARCHAR2
  ,p_include_line_assignments         IN VARCHAR2);

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| product_rule_in_use                                                   |
|                                                                       |
| Returns true if the rule is in use by accounting method               |
|                                                                       |
+======================================================================*/

FUNCTION product_rule_in_use
  (p_event                            IN VARCHAR2
  ,p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_product_rule_type_code           IN VARCHAR2
  ,p_product_rule_code                IN VARCHAR2
  ,p_accounting_method_name           IN OUT NOCOPY VARCHAR2
  ,p_accounting_method_type           IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| invalid_header_description                                            |
|                                                                       |
| Returns true if sources used in the description are invalid.          |
| Used in the lov for descriptions                                      |
|                                                                       |
+======================================================================*/

FUNCTION invalid_header_description
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_entity_code                      IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_description_type_code            IN VARCHAR2
  ,p_description_code                 IN VARCHAR2)
RETURN VARCHAR2;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| uncompile_product_rule                                                |
|                                                                       |
| Returns true if product rule gets uncompiled                          |
|                                                                       |
+======================================================================*/

FUNCTION uncompile_product_rule
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_product_rule_type_code           IN VARCHAR2
  ,p_product_rule_code                IN VARCHAR2)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| set_compile_status                                                    |
|                                                                       |
| Returns true if the compile status is changed as desired              |
|                                                                       |
+======================================================================*/

FUNCTION set_compile_status
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_product_rule_type_code           IN VARCHAR2
  ,p_product_rule_code                IN VARCHAR2
  ,p_status                           IN VARCHAR2)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| invalid_hdr_analytical                                                |
|                                                                       |
| Returns true if sources used in the analytical criteria are invalid   |
| Used in the lov for analytical criteria                               |
|                                                                       |
+======================================================================*/

 FUNCTION invalid_hdr_analytical
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_anal_criterion_type_code          IN VARCHAR2
  ,p_analytical_criterion_code         IN VARCHAR2)
RETURN VARCHAR2;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| create_accounting_attributes                                          |
|                                                                       |
| Returns true if accounting sources get created                        |
|                                                                       |
+======================================================================*/

PROCEDURE create_accounting_attributes
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_product_rule_type_code           IN VARCHAR2
  ,p_product_rule_code                IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
);

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| get_default_attr_assignment                                           |
|                                                                       |
| Gets the default source assignments for the accounting attribute      |
|                                                                       |
+======================================================================*/

PROCEDURE get_default_attr_assignment
  (p_application_id                   IN NUMBER
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_attribute_code        IN VARCHAR2
  ,p_source_application_id            IN OUT NOCOPY NUMBER
  ,p_source_type_code                 IN OUT NOCOPY VARCHAR2
  ,p_source_code                      IN OUT NOCOPY VARCHAR2
  ,p_source_name                      IN OUT NOCOPY VARCHAR2
  ,p_source_type_dsp                  IN OUT NOCOPY VARCHAR2);

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| uncompile_definitions                                                 |
|                                                                       |
| Uncompiles all AADs for an application                                |
|                                                                       |
+======================================================================*/

FUNCTION uncompile_definitions
  (p_application_id                  IN  NUMBER
  ,x_product_rule_name               IN OUT NOCOPY VARCHAR2
  ,x_product_rule_type               IN OUT NOCOPY VARCHAR2
  ,x_event_class_name                IN OUT NOCOPY VARCHAR2
  ,x_event_type_name                 IN OUT NOCOPY VARCHAR2
  ,x_locking_status_flag             IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

END xla_product_rules_pkg;
 

/
