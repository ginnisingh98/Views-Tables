--------------------------------------------------------
--  DDL for Package XLA_SEG_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_SEG_RULES_PKG" AUTHID CURRENT_USER AS
/* $Header: xlaamadr.pkh 120.14 2006/01/19 21:09:58 dcshah ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_seg_rules_pkg                                                  |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Segment Rules package                                          |
|                                                                       |
| HISTORY                                                               |
|    01-May-01 Dimple Shah    Created                                   |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| delete_seg_rule_details                                               |
|                                                                       |
| Deletes all details of the segment rule                               |
|                                                                       |
+======================================================================*/

PROCEDURE delete_seg_rule_details
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_segment_rule_type_code           IN VARCHAR2
  ,p_segment_rule_code                IN VARCHAR2);

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| copy_seg_rule_details                                                 |
|                                                                       |
| Copies the details of the old segment rule into the new segment rule  |
|                                                                       |
+======================================================================*/

PROCEDURE copy_seg_rule_details
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_old_segment_rule_type_code       IN VARCHAR2
  ,p_old_segment_rule_code            IN VARCHAR2
  ,p_new_segment_rule_type_code       IN VARCHAR2
  ,p_new_segment_rule_code            IN VARCHAR2
  ,p_old_transaction_coa_id           IN NUMBER
  ,p_new_transaction_coa_id           IN NUMBER);

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
  ,p_segment_rule_type_code           IN VARCHAR2
  ,p_segment_rule_code                IN VARCHAR2
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
  ,p_segment_rule_type_code           IN  VARCHAR2
  ,p_segment_rule_code                IN  VARCHAR2
  ,p_message_name                     OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| seg_rule_is_locked                                                    |
|                                                                       |
| Returns true if the seg rule is being used by a locked journal line   |
| definitions                                                           |
|                                                                       |
+======================================================================*/

FUNCTION seg_rule_is_locked
  (p_application_id                   IN  NUMBER
  ,p_amb_context_code                 IN  VARCHAR2
  ,p_segment_rule_type_code           IN  VARCHAR2
  ,p_segment_rule_code                IN  VARCHAR2)
RETURN BOOLEAN;

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
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_segment_rule_type_code           IN VARCHAR2
  ,p_segment_rule_code                IN VARCHAR2
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
| rule_in_use_by_tab                                                    |
|                                                                       |
| Returns true if the rule is in use by a transaction account definition|
|                                                                       |
+======================================================================*/

FUNCTION rule_in_use_by_tab
  (p_event                            IN VARCHAR2
  ,p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_segment_rule_type_code           IN VARCHAR2
  ,p_segment_rule_code                IN VARCHAR2
  ,p_trx_acct_def                     IN OUT NOCOPY VARCHAR2
  ,p_trx_acct_def_type                IN OUT NOCOPY VARCHAR2
  ,p_trx_acct_type                    IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| uncompile_tran_acct_def                                               |
|                                                                       |
| Returns true if all the transaction account definitions using         |
| the segment rule are uncompiled                                       |
|                                                                       |
+======================================================================*/

FUNCTION uncompile_tran_acct_def
  (p_application_id                   IN  NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_segment_rule_type_code           IN  VARCHAR2
  ,p_segment_rule_code                IN  VARCHAR2
  ,p_application_name                 IN OUT NOCOPY VARCHAR2
  ,p_trx_acct_def                     IN OUT NOCOPY VARCHAR2
  ,p_trx_acct_def_type                IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| check_copy_seg_rule_details                                           |
|                                                                       |
| Checks if the segment rule details can be copied into the new one     |
|                                                                       |
+======================================================================*/

FUNCTION check_copy_seg_rule_details
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_old_segment_rule_type_code       IN VARCHAR2
  ,p_old_segment_rule_code            IN VARCHAR2
  ,p_old_transaction_coa_id           IN NUMBER
  ,p_new_transaction_coa_id           IN NUMBER
  ,p_old_flex_value_set_id            IN NUMBER
  ,p_new_flex_value_set_id            IN NUMBER
  ,p_message                          IN OUT NOCOPY VARCHAR2
  ,p_token_1                          IN OUT NOCOPY VARCHAR2
  ,p_value_1                          IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| rule_in_use_by_adr                                                    |
|                                                                       |
| Checks if the segment rule is used by another ADR                     |
|                                                                       |
+======================================================================*/
FUNCTION rule_in_use_by_adr
  (p_event                            IN  VARCHAR2
  ,p_application_id                   IN  NUMBER
  ,p_amb_context_code                 IN  VARCHAR2
  ,p_segment_rule_type_code           IN  VARCHAR2
  ,p_segment_rule_code                IN  VARCHAR2
  ,p_parent_seg_rule_appl_name        IN OUT NOCOPY VARCHAR2
  ,p_parent_segment_rule_type         IN OUT NOCOPY VARCHAR2
  ,p_parent_segment_rule_name         IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| parent_seg_rule_is_locked                                             |
|                                                                       |
| Checks if the segment rule is used by a locked ADR                    |
|                                                                       |
+======================================================================*/
FUNCTION parent_seg_rule_is_locked
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_segment_rule_type_code           IN VARCHAR2
  ,p_segment_rule_code                IN VARCHAR2)
RETURN BOOLEAN;

END xla_seg_rules_pkg;
 

/
