--------------------------------------------------------
--  DDL for Package XLA_ACCT_LINE_TYPES_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_ACCT_LINE_TYPES_F_PKG" AUTHID CURRENT_USER AS
/* $Header: xlathalt.pkh 120.25 2006/03/31 02:22:54 weshen ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_acct_line_types                                                |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_acct_line_types                       |
|                                                                       |
| HISTORY                                                               |
|    Generated from XLAUTB.                                             |
|                                                                       |
|    05-Apr-05  eklau    Added new parameter mpa_option_code to insert  |
|                        and update procedure header.                   |
+======================================================================*/



PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_entity_code                      IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_accounting_line_type_code        IN VARCHAR2
  ,x_accounting_line_code             IN VARCHAR2
  ,x_transaction_coa_id               IN NUMBER
  ,x_accounting_entry_type_code       IN VARCHAR2
  ,x_natural_side_code                IN VARCHAR2
  ,x_gl_transfer_mode_code            IN VARCHAR2
  ,x_switch_side_flag                 IN VARCHAR2
  ,x_gain_or_loss_flag                IN VARCHAR2
  ,x_merge_duplicate_code             IN VARCHAR2
  ,x_enabled_flag                     IN VARCHAR2
  ,x_accounting_class_code            IN VARCHAR2
  ,x_rounding_class_code              IN VARCHAR2
  ,x_business_method_code             IN VARCHAR2
  ,x_business_class_code              IN VARCHAR2
  ,x_name                             IN VARCHAR2
  ,x_description                      IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER
  ,x_mpa_option_code                  IN VARCHAR2
  ,x_encumbrance_type_id              IN NUMBER);

PROCEDURE lock_row
  (x_application_id                   IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_entity_code                      IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_accounting_line_type_code        IN VARCHAR2
  ,x_accounting_line_code             IN VARCHAR2
  ,x_transaction_coa_id               IN NUMBER
  ,x_accounting_entry_type_code       IN VARCHAR2
  ,x_natural_side_code                IN VARCHAR2
  ,x_gl_transfer_mode_code            IN VARCHAR2
  ,x_switch_side_flag                 IN VARCHAR2
  ,x_gain_or_loss_flag                IN VARCHAR2
  ,x_merge_duplicate_code             IN VARCHAR2
  ,x_enabled_flag                     IN VARCHAR2
  ,x_accounting_class_code            IN VARCHAR2
  ,x_rounding_class_code              IN VARCHAR2
  ,x_business_method_code             IN VARCHAR2
  ,x_business_class_code              IN VARCHAR2
  ,x_name                             IN VARCHAR2
  ,x_description                      IN VARCHAR2
  ,x_mpa_option_code                  IN VARCHAR2
  ,x_encumbrance_type_id              IN NUMBER);

PROCEDURE update_row
 (x_application_id                   IN NUMBER
 ,x_amb_context_code                 IN VARCHAR2
 ,x_entity_code                      IN VARCHAR2
 ,x_event_class_code                 IN VARCHAR2
 ,x_accounting_line_type_code        IN VARCHAR2
 ,x_accounting_line_code             IN VARCHAR2
 ,x_transaction_coa_id               IN NUMBER
 ,x_accounting_entry_type_code       IN VARCHAR2
 ,x_natural_side_code                IN VARCHAR2
 ,x_gl_transfer_mode_code            IN VARCHAR2
 ,x_switch_side_flag                 IN VARCHAR2
  ,x_gain_or_loss_flag                IN VARCHAR2
 ,x_merge_duplicate_code             IN VARCHAR2
 ,x_enabled_flag                     IN VARCHAR2
 ,x_accounting_class_code            IN VARCHAR2
 ,x_rounding_class_code              IN VARCHAR2
 ,x_business_method_code             IN VARCHAR2
 ,x_business_class_code              IN VARCHAR2
 ,x_name                             IN VARCHAR2
 ,x_description                      IN VARCHAR2
 ,x_last_update_date                 IN DATE
 ,x_last_updated_by                  IN NUMBER
 ,x_last_update_login                IN NUMBER
 ,x_mpa_option_code                  IN VARCHAR2
 ,x_encumbrance_type_id              IN NUMBER);

PROCEDURE delete_row
  (x_application_id                   IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_entity_code                      IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_accounting_line_type_code        IN VARCHAR2
  ,x_accounting_line_code             IN VARCHAR2);

PROCEDURE add_language;

PROCEDURE translate_row
  (p_application_short_name          IN VARCHAR2
  ,p_amb_context_code                IN VARCHAR2
  ,p_event_class_code                IN VARCHAR2
  ,p_accounting_line_type_code       IN VARCHAR2
  ,p_accounting_line_code            IN VARCHAR2
  ,p_name                            IN VARCHAR2
  ,p_description                     IN VARCHAR2
  ,p_owner                           IN VARCHAR2
  ,p_last_update_date                IN VARCHAR2
  ,p_custom_mode                     IN VARCHAR2);

END xla_acct_line_types_f_pkg;
 

/
