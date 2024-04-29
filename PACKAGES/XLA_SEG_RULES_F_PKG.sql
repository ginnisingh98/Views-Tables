--------------------------------------------------------
--  DDL for Package XLA_SEG_RULES_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_SEG_RULES_F_PKG" AUTHID CURRENT_USER AS
/* $Header: xlathsgr.pkh 120.18 2005/05/05 23:04:41 wychan ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_seg_rules                                                      |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_seg_rules                             |
|                                                                       |
| HISTORY                                                               |
|    Generated from XLAUTB.                                             |
|                                                                       |
+======================================================================*/



PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_segment_rule_type_code           IN VARCHAR2
  ,x_segment_rule_code                IN VARCHAR2
  ,x_transaction_coa_id               IN NUMBER
  ,x_accounting_coa_id                IN NUMBER
  ,x_flexfield_assign_mode_code       IN VARCHAR2
  ,x_flexfield_segment_code           IN VARCHAR2
  ,x_enabled_flag                     IN VARCHAR2
  ,x_flex_value_set_id                IN NUMBER
  ,x_name                             IN VARCHAR2
  ,x_description                      IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER);

PROCEDURE lock_row
  (x_application_id                   IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_segment_rule_type_code           IN VARCHAR2
  ,x_segment_rule_code                IN VARCHAR2
  ,x_transaction_coa_id               IN NUMBER
  ,x_accounting_coa_id                IN NUMBER
  ,x_flexfield_assign_mode_code       IN VARCHAR2
  ,x_flexfield_segment_code           IN VARCHAR2
  ,x_enabled_flag                     IN VARCHAR2
  ,x_flex_value_set_id                IN NUMBER
  ,x_name                             IN VARCHAR2
  ,x_description                      IN VARCHAR2);

PROCEDURE update_row
 (x_application_id                   IN NUMBER
 ,x_amb_context_code                 IN VARCHAR2
 ,x_segment_rule_type_code           IN VARCHAR2
 ,x_segment_rule_code                IN VARCHAR2
 ,x_transaction_coa_id               IN NUMBER
 ,x_accounting_coa_id                IN NUMBER
 ,x_flexfield_assign_mode_code       IN VARCHAR2
 ,x_flexfield_segment_code           IN VARCHAR2
 ,x_enabled_flag                     IN VARCHAR2
 ,x_flex_value_set_id                IN NUMBER
 ,x_name                             IN VARCHAR2
 ,x_description                      IN VARCHAR2
 ,x_last_update_date                 IN DATE
 ,x_last_updated_by                  IN NUMBER
 ,x_last_update_login                IN NUMBER);

PROCEDURE delete_row
  (x_application_id                   IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_segment_rule_type_code           IN VARCHAR2
  ,x_segment_rule_code                IN VARCHAR2);
PROCEDURE add_language;

PROCEDURE translate_row
  (p_application_short_name       IN VARCHAR2
  ,p_amb_context_code             IN VARCHAR2
  ,p_event_class_code             IN VARCHAR2
  ,p_event_type_code              IN VARCHAR2
  ,p_segment_rule_type_code       IN VARCHAR2
  ,p_segment_rule_code            IN VARCHAR2
  ,p_name                         IN VARCHAR2
  ,p_description                  IN VARCHAR2
  ,p_owner                        IN VARCHAR2
  ,p_last_update_date             IN VARCHAR2
  ,p_custom_mode                  IN VARCHAR2);

END xla_seg_rules_f_pkg;
 

/
