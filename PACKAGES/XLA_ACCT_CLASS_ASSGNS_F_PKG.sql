--------------------------------------------------------
--  DDL for Package XLA_ACCT_CLASS_ASSGNS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_ACCT_CLASS_ASSGNS_F_PKG" AUTHID CURRENT_USER AS
/* $Header: xlatbaca.pkh 120.0 2005/05/24 21:47:14 dcshah noship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_acct_class_assgns                                           |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_acct_class_assgns                  |
|                                                                       |
| HISTORY                                                               |
|    Generated from XLAUTB.                                             |
|                                                                       |
+======================================================================*/

PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_program_code                     IN VARCHAR2
  ,x_program_owner_code               IN VARCHAR2
  ,x_assignment_code                  IN VARCHAR2
  ,x_assignment_owner_code            IN VARCHAR2
  ,x_accounting_class_code            IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER);

PROCEDURE lock_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_program_code                     IN VARCHAR2
  ,x_program_owner_code               IN VARCHAR2
  ,x_assignment_code                  IN VARCHAR2
  ,x_assignment_owner_code            IN VARCHAR2
  ,x_accounting_class_code            IN VARCHAR2);

PROCEDURE delete_row
  (x_program_code                     IN VARCHAR2
  ,x_program_owner_code               IN VARCHAR2
  ,x_assignment_code                  IN VARCHAR2
  ,x_assignment_owner_code            IN VARCHAR2
  ,x_accounting_class_code            IN VARCHAR2);

PROCEDURE load_row
(p_program_code                     IN VARCHAR2
,p_program_owner_code               IN VARCHAR2
,p_assignment_code                  IN VARCHAR2
,p_assignment_owner_code            IN VARCHAR2
,p_accounting_class_code            IN VARCHAR2
,p_owner                            IN VARCHAR2
,p_last_update_date                 IN VARCHAR2);

END xla_acct_class_assgns_f_pkg;
 

/
