--------------------------------------------------------
--  DDL for Package XLA_ACCTG_METHODS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_ACCTG_METHODS_F_PKG" AUTHID CURRENT_USER AS
/* $Header: xlathagm.pkh 120.15 2005/06/06 21:07:48 dcshah ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_acctg_methods                                                  |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_acctg_methods                         |
|                                                                       |
| HISTORY                                                               |
|    Generated from XLAUTB.                                             |
|                                                                       |
+======================================================================*/



PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_accounting_method_type_code      IN VARCHAR2
  ,x_accounting_method_code           IN VARCHAR2
  ,x_transaction_coa_id               IN NUMBER
  ,x_accounting_coa_id                IN NUMBER
  ,x_enabled_flag                     IN VARCHAR2
  ,x_name                             IN VARCHAR2
  ,x_description                      IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER);

PROCEDURE lock_row
  (x_accounting_method_type_code      IN VARCHAR2
  ,x_accounting_method_code           IN VARCHAR2
  ,x_transaction_coa_id               IN NUMBER
  ,x_accounting_coa_id                IN NUMBER
  ,x_enabled_flag                     IN VARCHAR2
  ,x_name                             IN VARCHAR2
  ,x_description                      IN VARCHAR2);

PROCEDURE update_row
 (x_accounting_method_type_code      IN VARCHAR2
 ,x_accounting_method_code           IN VARCHAR2
 ,x_transaction_coa_id               IN NUMBER
 ,x_accounting_coa_id                IN NUMBER
 ,x_enabled_flag                     IN VARCHAR2
 ,x_name                             IN VARCHAR2
 ,x_description                      IN VARCHAR2
 ,x_last_update_date                 IN DATE
 ,x_last_updated_by                  IN NUMBER
 ,x_last_update_login                IN NUMBER);

PROCEDURE delete_row
  (x_accounting_method_type_code      IN VARCHAR2
  ,x_accounting_method_code           IN VARCHAR2);

PROCEDURE add_language;

PROCEDURE translate_row
  (p_accounting_method_type_code IN VARCHAR2
  ,p_accounting_method_code      IN VARCHAR2
  ,p_name                        IN VARCHAR2
  ,p_description                 IN VARCHAR2
  ,p_owner                       IN VARCHAR2
  ,p_last_update_date            IN VARCHAR2
  ,p_custom_mode                 IN VARCHAR2);

PROCEDURE load_row
  (p_accounting_method_type_code IN VARCHAR2
  ,p_accounting_method_code      IN VARCHAR2
  ,p_enabled_flag                IN VARCHAR2
  ,p_name                        IN VARCHAR2
  ,p_description                 IN VARCHAR2
  ,p_owner                       IN VARCHAR2
  ,p_last_update_date            IN VARCHAR2);

END xla_acctg_methods_f_pkg;
 

/
