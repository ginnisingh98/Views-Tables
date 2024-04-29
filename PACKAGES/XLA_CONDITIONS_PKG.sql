--------------------------------------------------------
--  DDL for Package XLA_CONDITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_CONDITIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: xlaamcon.pkh 120.2.12000000.1 2007/01/16 21:02:47 appldev ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_conditions_pkg                                                 |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Conditions package                                             |
|                                                                       |
| HISTORY                                                               |
|    01-May-01 Dimple Shah    Created                                   |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| delete_condition                                                      |
|                                                                       |
| Deletes all conditions attached to the parent                         |
|                                                                       |
+======================================================================*/

PROCEDURE delete_condition
  (p_context                          IN VARCHAR2
  ,p_application_id                   IN NUMBER    DEFAULT NULL
  ,p_amb_context_code                 IN VARCHAR2  DEFAULT NULL
  ,p_entity_code                      IN VARCHAR2  DEFAULT NULL
  ,p_event_class_code                 IN VARCHAR2  DEFAULT NULL
  ,p_accounting_line_type_code        IN VARCHAR2  DEFAULT NULL
  ,p_accounting_line_code             IN VARCHAR2  DEFAULT NULL
  ,p_segment_rule_detail_id           IN NUMBER    DEFAULT NULL
  ,p_description_prio_id              IN NUMBER    DEFAULT NULL);

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| display_condition                                                     |
|                                                                       |
| Returns the entire condition for the parent                           |
|                                                                       |
+======================================================================*/

FUNCTION display_condition
  (p_application_id                   IN NUMBER    DEFAULT NULL
  ,p_amb_context_code                 IN VARCHAR2  DEFAULT NULL
  ,p_entity_code	              IN VARCHAR2  DEFAULT NULL
  ,p_event_class_code                 IN VARCHAR2  DEFAULT NULL
  ,p_accounting_line_type_code        IN VARCHAR2  DEFAULT NULL
  ,p_accounting_line_code             IN VARCHAR2  DEFAULT NULL
  ,p_segment_rule_detail_id           IN NUMBER    DEFAULT NULL
  ,p_description_prio_id              IN NUMBER    DEFAULT NULL
  ,p_chart_of_accounts_id             IN NUMBER    DEFAULT NULL
  ,p_context                          IN VARCHAR2)
RETURN VARCHAR2;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| desc_condition_is_invalid                                             |
|                                                                       |
| Returns true if condition is invalid                                  |
|                                                                       |
+======================================================================*/

FUNCTION desc_condition_is_invalid
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_description_type_code            IN VARCHAR2
  ,p_description_code                 IN VARCHAR2
  ,p_message_name                     IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| seg_condition_is_invalid                                              |
|                                                                       |
| Returns true if condition is invalid                                  |
|                                                                       |
+======================================================================*/

FUNCTION seg_condition_is_invalid
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_segment_rule_type_code           IN VARCHAR2
  ,p_segment_rule_code                IN VARCHAR2
  ,p_message_name                     IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| acct_condition_is_invalid                                             |
|                                                                       |
| Returns true if condition is invalid                                  |
|                                                                       |
+======================================================================*/

FUNCTION acct_condition_is_invalid
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_entity_code	              IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_line_type_code        IN VARCHAR2
  ,p_accounting_line_code             IN VARCHAR2
  ,p_message_name                     IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

END xla_conditions_pkg;
 

/
