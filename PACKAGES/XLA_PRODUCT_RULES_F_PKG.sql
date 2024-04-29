--------------------------------------------------------
--  DDL for Package XLA_PRODUCT_RULES_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_PRODUCT_RULES_F_PKG" AUTHID CURRENT_USER AS
/* $Header: xlathpdr.pkh 120.16 2005/05/05 23:00:08 wychan ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_product_rules                                                  |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_product_rules                         |
|                                                                       |
| HISTORY                                                               |
|    Generated from XLAUTB.                                             |
|                                                                       |
+======================================================================*/



PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_product_rule_type_code           IN VARCHAR2
  ,x_product_rule_code                IN VARCHAR2
  ,x_enabled_flag                     IN VARCHAR2
  ,x_request_id                       IN NUMBER
  ,x_product_rule_version             IN VARCHAR2
  ,x_transaction_coa_id               IN NUMBER
  ,x_accounting_coa_id                IN NUMBER
  ,x_product_rule_hash_id             IN NUMBER
  ,x_compile_status_code              IN VARCHAR2
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
  ,x_product_rule_type_code           IN VARCHAR2
  ,x_product_rule_code                IN VARCHAR2
  ,x_enabled_flag                     IN VARCHAR2
  ,x_request_id                       IN NUMBER
  ,x_product_rule_version             IN VARCHAR2
  ,x_transaction_coa_id               IN NUMBER
  ,x_accounting_coa_id                IN NUMBER
  ,x_product_rule_hash_id             IN NUMBER
  ,x_compile_status_code              IN VARCHAR2
  ,x_name                             IN VARCHAR2
  ,x_description                      IN VARCHAR2);

PROCEDURE update_row
 (x_application_id                   IN NUMBER
 ,x_amb_context_code                 IN VARCHAR2
 ,x_product_rule_type_code           IN VARCHAR2
 ,x_product_rule_code                IN VARCHAR2
 ,x_enabled_flag                     IN VARCHAR2
 ,x_request_id                       IN NUMBER
 ,x_product_rule_version             IN VARCHAR2
 ,x_transaction_coa_id               IN NUMBER
 ,x_accounting_coa_id                IN NUMBER
 ,x_product_rule_hash_id             IN NUMBER
 ,x_compile_status_code              IN VARCHAR2
 ,x_name                             IN VARCHAR2
 ,x_description                      IN VARCHAR2
 ,x_last_update_date                 IN DATE
 ,x_last_updated_by                  IN NUMBER
 ,x_last_update_login                IN NUMBER);

PROCEDURE delete_row
  (x_application_id                   IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_product_rule_type_code           IN VARCHAR2
  ,x_product_rule_code                IN VARCHAR2);

PROCEDURE add_language;

PROCEDURE translate_row
  (p_application_short_name       IN VARCHAR2
  ,p_amb_context_code             IN VARCHAR2
  ,p_product_rule_type_code       IN VARCHAR2
  ,p_product_rule_code            IN VARCHAR2
  ,p_name                         IN VARCHAR2
  ,p_description                  IN VARCHAR2
  ,p_owner                        IN VARCHAR2
  ,p_last_update_date             IN VARCHAR2
  ,p_custom_mode                  IN VARCHAR2);

END xla_product_rules_f_pkg;
 

/
