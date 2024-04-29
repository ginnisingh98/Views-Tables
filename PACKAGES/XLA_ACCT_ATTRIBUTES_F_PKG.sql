--------------------------------------------------------
--  DDL for Package XLA_ACCT_ATTRIBUTES_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_ACCT_ATTRIBUTES_F_PKG" AUTHID CURRENT_USER AS
/* $Header: xlathess.pkh 120.4 2005/03/17 22:37:28 dcshah ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_acct_attributes                                                |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_acct_attributes                       |
|                                                                       |
| HISTORY                                                               |
|    Generated from XLAUTB.                                             |
|                                                                       |
+======================================================================*/



PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_accounting_attribute_code        IN VARCHAR2
  ,x_assignment_required_code         IN VARCHAR2
  ,x_assignment_group_code            IN VARCHAR2
  ,x_datatype_code                    IN VARCHAR2
  ,x_journal_entry_level_code         IN VARCHAR2
  ,x_assignment_extensible_flag       IN VARCHAR2
  ,x_assignment_level_code            IN VARCHAR2
  ,x_inherited_flag                   IN VARCHAR2
  ,x_name                             IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER);

PROCEDURE lock_row
  (x_accounting_attribute_code        IN VARCHAR2
  ,x_assignment_required_code         IN VARCHAR2
  ,x_assignment_group_code            IN VARCHAR2
  ,x_datatype_code                    IN VARCHAR2
  ,x_journal_entry_level_code         IN VARCHAR2
  ,x_assignment_extensible_flag       IN VARCHAR2
  ,x_assignment_level_code            IN VARCHAR2
  ,x_inherited_flag                   IN VARCHAR2
  ,x_name                             IN VARCHAR2);

PROCEDURE update_row
 (x_accounting_attribute_code        IN VARCHAR2
 ,x_assignment_required_code         IN VARCHAR2
 ,x_assignment_group_code            IN VARCHAR2
 ,x_datatype_code                    IN VARCHAR2
 ,x_journal_entry_level_code         IN VARCHAR2
 ,x_assignment_extensible_flag       IN VARCHAR2
 ,x_assignment_level_code            IN VARCHAR2
 ,x_inherited_flag                   IN VARCHAR2
 ,x_name                             IN VARCHAR2
 ,x_last_update_date                 IN DATE
 ,x_last_updated_by                  IN NUMBER
 ,x_last_update_login                IN NUMBER);

PROCEDURE delete_row
  (x_accounting_attribute_code       IN VARCHAR2);
PROCEDURE add_language;

PROCEDURE load_row
  (p_accounting_attribute_code        IN VARCHAR2
  ,p_journal_entry_level_code         IN VARCHAR2
  ,p_datatype_code                    IN VARCHAR2
  ,p_assignment_required_code         IN VARCHAR2
  ,p_assignment_group_code            IN VARCHAR2
  ,p_assignment_extensible_flag       IN VARCHAR2
  ,p_assignment_level_code            IN VARCHAR2
  ,p_inherited_flag                   IN VARCHAR2
  ,p_name                             IN VARCHAR2
  ,p_owner                            IN VARCHAR2
  ,p_last_update_date                 IN VARCHAR2
  ,p_custom_mode                      IN VARCHAR2);

PROCEDURE translate_row
  (p_accounting_attribute_code        IN VARCHAR2
  ,p_name                             IN VARCHAR2
  ,p_owner                            IN VARCHAR2
  ,p_last_update_date                 IN VARCHAR2
  ,p_custom_mode                      IN VARCHAR2);

END xla_acct_attributes_f_pkg;
 

/
