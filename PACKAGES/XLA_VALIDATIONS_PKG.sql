--------------------------------------------------------
--  DDL for Package XLA_VALIDATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_VALIDATIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: xlacmval.pkh 120.11 2005/07/05 03:32:10 masada ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_validations_pkg                                                |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Common Validations Package                                     |
|                                                                       |
| HISTORY                                                               |
|    22-May-02 Dimple Shah    Created                                   |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| object_name_is_valid                                                  |
|                                                                       |
| Checks whether an object name has valid alphanumeric characters       |
|                                                                       |
+======================================================================*/
FUNCTION  object_name_is_valid
  (p_object_name                  IN  VARCHAR2)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| get_product_rule_info                                                 |
|                                                                       |
| Get name and owner for the product rule                               |
|                                                                       |
+======================================================================*/
PROCEDURE  get_product_rule_info
  (p_application_id                  IN NUMBER
  ,p_amb_context_code                IN VARCHAR2
  ,p_product_rule_type_code          IN VARCHAR2
  ,p_product_rule_code               IN VARCHAR2
  ,p_application_name                IN OUT NOCOPY VARCHAR2
  ,p_product_rule_name               IN OUT NOCOPY VARCHAR2
  ,p_product_rule_type               IN OUT NOCOPY VARCHAR2);

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| get_description_info                                                  |
|                                                                       |
| Get name and owner for the description rule                           |
|                                                                       |
+======================================================================*/
PROCEDURE  get_description_info
  (p_application_id                 IN  NUMBER
  ,p_amb_context_code               IN VARCHAR2
  ,p_description_type_code          IN VARCHAR2
  ,p_description_code               IN VARCHAR2
  ,p_application_name               IN OUT NOCOPY VARCHAR2
  ,p_description_name               IN OUT NOCOPY VARCHAR2
  ,p_description_type               IN OUT NOCOPY VARCHAR2);

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| get_segment_rule_info                                                 |
|                                                                       |
| Get name and owner for the segment rule                               |
|                                                                       |
+======================================================================*/
PROCEDURE  get_segment_rule_info
  (p_application_id                  IN  NUMBER
  ,p_amb_context_code                IN VARCHAR2
  ,p_segment_rule_type_code          IN VARCHAR2
  ,p_segment_rule_code               IN VARCHAR2
  ,p_application_name                IN OUT NOCOPY VARCHAR2
  ,p_segment_rule_name               IN OUT NOCOPY VARCHAR2
  ,p_segment_rule_type               IN OUT NOCOPY VARCHAR2);


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| get_line_type_info                                                    |
|                                                                       |
| Get name and owner for the line type                                  |
|                                                                       |
+======================================================================*/
PROCEDURE  get_line_type_info
  (p_application_id                  IN  NUMBER
  ,p_amb_context_code                IN VARCHAR2
  ,p_entity_code                     IN VARCHAR2
  ,p_event_class_code                IN VARCHAR2
  ,p_accounting_line_type_code       IN VARCHAR2
  ,p_accounting_line_code            IN VARCHAR2
  ,p_application_name                IN OUT NOCOPY VARCHAR2
  ,p_accounting_line_type_name       IN OUT NOCOPY VARCHAR2
  ,p_accounting_line_type            IN OUT NOCOPY VARCHAR2);

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| get_event_class_info                                                  |
|                                                                       |
| Get name for the event class                                          |
|                                                                       |
+======================================================================*/
PROCEDURE  get_event_class_info
  (p_application_id                  IN  NUMBER
  ,p_entity_code                     IN VARCHAR2
  ,p_event_class_code                IN VARCHAR2
  ,p_event_class_name                IN OUT NOCOPY VARCHAR2);

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| get_event_type_info                                                   |
|                                                                       |
| Get name for the event type                                           |
|                                                                       |
+======================================================================*/
PROCEDURE  get_event_type_info
  (p_application_id                  IN  NUMBER
  ,p_entity_code                     IN VARCHAR2
  ,p_event_class_code                IN VARCHAR2
  ,p_event_type_code                 IN VARCHAR2
  ,p_event_type_name                 IN OUT NOCOPY VARCHAR2);

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| get_source_info                                                       |
|                                                                       |
| Get name for the source                                               |
|                                                                       |
+======================================================================*/
PROCEDURE  get_source_info
  (p_application_id                  IN NUMBER
  ,p_source_type_code                IN VARCHAR2
  ,p_source_code                     IN VARCHAR2
  ,p_source_name                     IN OUT NOCOPY VARCHAR2
  ,p_source_type                     IN OUT NOCOPY VARCHAR2);

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| get_analytical_criteria_info                                          |
|                                                                       |
| Get name for the analytical criteria                                  |
|                                                                       |
+======================================================================*/
PROCEDURE  get_analytical_criteria_info
  (p_amb_context_code                       IN VARCHAR2
  ,p_anal_criterion_type_code               IN VARCHAR2
  ,p_analytical_criterion_code              IN VARCHAR2
  ,p_analytical_criteria_name               IN OUT NOCOPY VARCHAR2
  ,p_analytical_criteria_type               IN OUT NOCOPY VARCHAR2);

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| get_accounting_method_info                                            |
|                                                                       |
| Get name and owner for the accounting method                          |
|                                                                       |
+======================================================================*/
PROCEDURE  get_accounting_method_info
  (p_accounting_method_type_code          IN VARCHAR2
  ,p_accounting_method_code               IN VARCHAR2
  ,p_accounting_method_name               IN OUT NOCOPY VARCHAR2
  ,p_accounting_method_type               IN OUT NOCOPY VARCHAR2);

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| get_application_name                                                  |
|                                                                       |
| Get name of the application                                           |
|                                                                       |
+======================================================================*/
PROCEDURE  get_application_name
  (p_application_id          IN NUMBER
  ,p_application_name        IN OUT NOCOPY VARCHAR2);

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| get_ledger_name                                                       |
|                                                                       |
| Get name of the ledger                                                |
|                                                                       |
+======================================================================*/
PROCEDURE  get_ledger_name
  (p_ledger_id          IN NUMBER
  ,p_ledger_name        IN OUT NOCOPY VARCHAR2);

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| get_trx_acct_def_info                                                 |
|                                                                       |
| Get name and owner for the transaction account definition             |
|                                                                       |
+======================================================================*/
PROCEDURE  get_trx_acct_def_info
  (p_application_id                  IN NUMBER
  ,p_amb_context_code                IN VARCHAR2
  ,p_account_definition_type_code    IN VARCHAR2
  ,p_account_definition_code         IN VARCHAR2
  ,p_application_name                IN OUT NOCOPY VARCHAR2
  ,p_trx_acct_def                    IN OUT NOCOPY VARCHAR2
  ,p_trx_acct_def_type               IN OUT NOCOPY VARCHAR2);

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| get_trx_acct_type_info                                                |
|                                                                       |
| Get name for the transaction account type                             |
|                                                                       |
+======================================================================*/
PROCEDURE  get_trx_acct_type_info
  (p_application_id                  IN  NUMBER
  ,p_account_type_code               IN VARCHAR2
  ,p_trx_acct_type                   IN OUT NOCOPY VARCHAR2);

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| table_name_is_valid                                                   |
|                                                                       |
| Checks whether an object exists in the database                       |
|                                                                       |
+======================================================================*/
FUNCTION  table_name_is_valid
  (p_table_name                  IN  VARCHAR2)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| reference_is_valid                                                    |
|                                                                       |
| Check if reference object is not used by other transaction            |
| objects within the same event class.                                  |
+======================================================================*/
FUNCTION  reference_is_valid
  (p_table_name                     IN  VARCHAR2
  ,p_event_class_code               IN  VARCHAR2)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| join_condition_is_valid                                               |
|                                                                       |
| Check if join condition is valid                                      |
|                                                                       |
+======================================================================*/
FUNCTION  join_condition_is_valid
  (p_trx_object_name    IN  VARCHAR2
  ,p_ref_object_name    IN  VARCHAR2
  ,p_join_condition     IN  VARCHAR2
  ,p_error_message      OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

END xla_validations_pkg;
 

/
