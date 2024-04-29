--------------------------------------------------------
--  DDL for Package XLA_LINE_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_LINE_TYPES_PKG" AUTHID CURRENT_USER AS
/* $Header: xlaamdlt.pkh 120.16 2006/02/15 19:51:32 dcshah ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_line_types_pkg                                                 |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Line Types package                                             |
|                                                                       |
| HISTORY                                                               |
|    01-May-01 Dimple Shah    Created                                   |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| delete_line_type_details                                              |
|                                                                       |
| Deletes all details of the line type                                  |
|                                                                       |
+======================================================================*/

PROCEDURE delete_line_type_details
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_entity_code                      IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_line_type_code        IN VARCHAR2
  ,p_accounting_line_code             IN VARCHAR2);

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| copy_line_type_details                                                |
|                                                                       |
| Copies the details of the old line type into the new line type        |
|                                                                       |
+======================================================================*/

 PROCEDURE copy_line_type_details
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_entity_code                      IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_old_accting_line_type_code       IN VARCHAR2
  ,p_old_accounting_line_code         IN VARCHAR2
  ,p_new_accting_line_type_code       IN VARCHAR2
  ,p_new_accounting_line_code         IN VARCHAR2
  ,p_old_transaction_coa_id           IN NUMBER
  ,p_new_transaction_coa_id           IN NUMBER);

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| line_type_in_use                                                      |
|                                                                       |
| Returns true if the rule is in use by an accounting line type         |
|                                                                       |
+======================================================================*/

FUNCTION line_type_in_use
  (p_event                            IN VARCHAR2
  ,p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_line_type_code        IN VARCHAR2
  ,p_accounting_line_code             IN VARCHAR2
  ,x_line_definition_name             IN OUT NOCOPY VARCHAR2
  ,x_line_definition_owner            IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| line_type_is_invalid                                                  |
|                                                                       |
| Returns true if the line type is invalid                              |
|                                                                       |
+======================================================================*/

FUNCTION line_type_is_invalid
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_entity_code                      IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_line_type_code        IN VARCHAR2
  ,p_accounting_line_code             IN VARCHAR2
  ,p_message_name                     IN OUT NOCOPY VARCHAR2
  ,p_accounting_attribute_name        IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| line_type_is_locked                                                   |
|                                                                       |
| Returns true if the line type is used by a locked product rule        |
|                                                                       |
+======================================================================*/

FUNCTION line_type_is_locked
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_entity_code                      IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_line_type_code        IN VARCHAR2
  ,p_accounting_line_code             IN VARCHAR2)
RETURN BOOLEAN;

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
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_line_type_code        IN VARCHAR2
  ,p_accounting_line_code             IN VARCHAR2
  ,p_side_code                        IN VARCHAR2
  ,p_business_method_code             IN VARCHAR2
);

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| uncompile_definitions                                                 |
|                                                                       |
| Returns true if all the application accounting definitions and        |
| journal line definitions using this journal line type are uncompiled  |
|                                                                       |
+======================================================================*/
FUNCTION uncompile_definitions
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_line_type_code        IN VARCHAR2
  ,p_accounting_line_code             IN VARCHAR2
  ,x_product_rule_name                IN OUT NOCOPY VARCHAR2
  ,x_product_rule_type                IN OUT NOCOPY VARCHAR2
  ,x_event_class_name                 IN OUT NOCOPY VARCHAR2
  ,x_event_type_name                  IN OUT NOCOPY VARCHAR2
  ,x_locking_status_flag              IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

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
| check_copy_line_type_details                                          |
|                                                                       |
| Checks if the line type can be copied                                 |
|                                                                       |
+======================================================================*/

 FUNCTION check_copy_line_type_details
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_entity_code                      IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_old_accting_line_type_code       IN VARCHAR2
  ,p_old_accounting_line_code         IN VARCHAR2
  ,p_old_transaction_coa_id          IN NUMBER
  ,p_new_transaction_coa_id          IN NUMBER
  ,p_message                          IN OUT NOCOPY VARCHAR2
  ,p_token_1                          IN OUT NOCOPY VARCHAR2
  ,p_value_1                          IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;


FUNCTION non_gain_acct_attrs_exists
(p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_line_type_code        IN VARCHAR2
  ,p_accounting_line_code             IN VARCHAR2)
return boolean;

PROCEDURE insert_non_gain_acct_attrs(
p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_line_type_code        IN VARCHAR2
  ,p_accounting_line_code             IN VARCHAR2);


PROCEDURE delete_non_gain_acct_attrs(
p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_line_type_code        IN VARCHAR2
  ,p_accounting_line_code             IN VARCHAR2);

PROCEDURE update_acct_attrs(
   p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_line_type_code        IN VARCHAR2
  ,p_accounting_line_code             IN VARCHAR2
  ,p_business_method_code             IN VARCHAR2);

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| mpa_line_type_in_use                                                  |
|                                                                       |
| Returns true if the line is in used by a JLD                          |
|                                                                       |
+======================================================================*/

FUNCTION mpa_line_type_in_use
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_line_type_code        IN VARCHAR2
  ,p_accounting_line_code             IN VARCHAR2
  ,x_mpa_option_code                  IN OUT NOCOPY VARCHAR2
  ,x_line_definition_name             IN OUT NOCOPY VARCHAR2
  ,x_line_definition_owner            IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

END xla_line_types_pkg;
 

/
