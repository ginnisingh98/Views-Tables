--------------------------------------------------------
--  DDL for Package XLA_DESCRIPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_DESCRIPTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: xlaamdad.pkh 120.9 2005/02/26 01:53:45 weshen ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_descriptions_pkg                                               |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Descriptions package                                           |
|                                                                       |
| HISTORY                                                               |
|    01-May-01 Dimple Shah    Created                                   |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| delete_description_details                                            |
|                                                                       |
| Deletes all details of the description                                |
|                                                                       |
+======================================================================*/

PROCEDURE delete_description_details
  (p_application_id                  IN NUMBER
  ,p_amb_context_code                IN VARCHAR2
  ,p_description_type_code           IN VARCHAR2
  ,p_description_code                IN VARCHAR2);

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| copy_description_details                                              |
|                                                                       |
| Copies the details of the old description into the new description    |
|                                                                       |
+======================================================================*/

PROCEDURE copy_description_details
  (p_application_id                  IN NUMBER
  ,p_amb_context_code                IN VARCHAR2
  ,p_old_description_type_code       IN VARCHAR2
  ,p_old_description_code            IN VARCHAR2
  ,p_new_description_type_code       IN VARCHAR2
  ,p_new_description_code            IN VARCHAR2
  ,p_old_transaction_coa_id          IN NUMBER
  ,p_new_transaction_coa_id          IN NUMBER);

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| rule_in_use                                                           |
|                                                                       |
| Returns true if the rule is in use by an accounting line type         |
|                                                                       |
+======================================================================*/

FUNCTION rule_in_use
  (p_event                            IN VARCHAR2
  ,p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_description_type_code            IN VARCHAR2
  ,p_description_code                 IN VARCHAR2
  ,x_product_rule_name                IN OUT NOCOPY VARCHAR2
  ,x_product_rule_type                IN OUT NOCOPY VARCHAR2
  ,x_event_class_name                 IN OUT NOCOPY VARCHAR2
  ,x_line_definition_name             IN OUT NOCOPY VARCHAR2
  ,x_line_definition_owner            IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| rule_is_invalid                                                       |
|                                                                       |
| Returns true if the rule is invalid                                   |
|                                                                       |
+======================================================================*/

FUNCTION rule_is_invalid
  (p_application_id                   IN  NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_description_type_code            IN  VARCHAR2
  ,p_description_code                 IN  VARCHAR2
  ,p_message_name                     OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| description_is_locked                                                 |
|                                                                       |
| Returns true if the description is being used by a locked product rule|
|                                                                       |
+======================================================================*/

FUNCTION description_is_locked
  (p_application_id                   IN  NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_description_type_code            IN  VARCHAR2
  ,p_description_code                 IN  VARCHAR2)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| uncompile_definitions                                                 |
|                                                                       |
| Returns true if the application accounting definitions and journal    |
| line definitions using the description get uncompiled                 |
|                                                                       |
+======================================================================*/

FUNCTION uncompile_definitions
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_description_type_code            IN VARCHAR2
  ,p_description_code                 IN VARCHAR2
  ,x_product_rule_name                IN OUT NOCOPY VARCHAR2
  ,x_product_rule_type                IN OUT NOCOPY VARCHAR2
  ,x_event_class_name                 IN OUT NOCOPY VARCHAR2
  ,x_event_type_name                  IN OUT NOCOPY VARCHAR2
  ,x_locking_status_flag              IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| check_copy_description_details                                        |
|                                                                       |
| Checks if description can be copied                                   |
|                                                                       |
+======================================================================*/

FUNCTION check_copy_description_details
  (p_application_id                  IN NUMBER
  ,p_amb_context_code                IN VARCHAR2
  ,p_old_description_type_code       IN VARCHAR2
  ,p_old_description_code            IN VARCHAR2
  ,p_old_transaction_coa_id          IN NUMBER
  ,p_new_transaction_coa_id          IN NUMBER
  ,p_message                          IN OUT NOCOPY VARCHAR2
  ,p_token_1                          IN OUT NOCOPY VARCHAR2
  ,p_value_1                          IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

END xla_descriptions_pkg;
 

/
