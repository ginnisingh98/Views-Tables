--------------------------------------------------------
--  DDL for Package XLA_ACCTG_METHOD_RULES_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_ACCTG_METHOD_RULES_F_PKG" AUTHID CURRENT_USER AS
/* $Header: xlatbsap.pkh 120.5 2003/03/18 00:38:49 dcshah ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_acctg_method_rules_f_pkg                                       |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_acctg_method_rules                    |
|                                                                       |
| HISTORY                                                               |
|   Manually created                                                    |
|                                                                       |
+======================================================================*/

PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_acctg_method_rule_id             IN OUT NOCOPY NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_accounting_method_type_code      IN VARCHAR2
  ,x_accounting_method_code           IN VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_product_rule_type_code           IN VARCHAR2
  ,x_product_rule_code                IN VARCHAR2
  ,x_start_date_active                IN DATE
  ,x_end_date_active                  IN DATE
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER);

PROCEDURE lock_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_acctg_method_rule_id             IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_accounting_method_type_code      IN VARCHAR2
  ,x_accounting_method_code           IN VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_product_rule_type_code           IN VARCHAR2
  ,x_product_rule_code                IN VARCHAR2
  ,x_start_date_active                IN DATE
  ,x_end_date_active                  IN DATE);

PROCEDURE update_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_acctg_method_rule_id             IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_accounting_method_type_code      IN VARCHAR2
  ,x_accounting_method_code           IN VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_product_rule_type_code           IN VARCHAR2
  ,x_product_rule_code                IN VARCHAR2
  ,x_start_date_active                IN DATE
  ,x_end_date_active                  IN DATE
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER);

PROCEDURE delete_row
  (x_acctg_method_rule_id             IN NUMBER);

END xla_acctg_method_rules_f_pkg;
 

/
