--------------------------------------------------------
--  DDL for Package XLA_ASSIGNMENT_DEFNS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_ASSIGNMENT_DEFNS_F_PKG" AUTHID CURRENT_USER AS
/* $Header: xlathasd.pkh 120.0 2005/05/24 21:45:02 dcshah noship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_assignment_defns                                                  |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_assignment_defns                         |
|                                                                       |
| HISTORY                                                               |
|    Generated from XLAUTB.                                             |
|    09/23/04 W Chan     Add API load_row and translate_row for FNDLOAD |
|                                                                       |
+======================================================================*/



PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_program_code                     IN VARCHAR2
  ,x_program_owner_code               IN VARCHAR2
  ,x_assignment_code                  IN VARCHAR2
  ,x_assignment_owner_code            IN VARCHAR2
  ,x_ledger_id                        IN NUMBER
  ,x_enabled_flag                     IN VARCHAR2
  ,x_name                             IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER);

PROCEDURE lock_row
  (x_program_code                     IN VARCHAR2
  ,x_program_owner_code               IN VARCHAR2
  ,x_assignment_code                  IN VARCHAR2
  ,x_assignment_owner_code            IN VARCHAR2
  ,x_ledger_id                        IN NUMBER
  ,x_enabled_flag                     IN VARCHAR2
  ,x_name                             IN VARCHAR2);

PROCEDURE update_row
 ( x_program_code                     IN VARCHAR2
  ,x_program_owner_code               IN VARCHAR2
  ,x_assignment_code                  IN VARCHAR2
  ,x_assignment_owner_code            IN VARCHAR2
  ,x_ledger_id                        IN NUMBER
  ,x_enabled_flag                     IN VARCHAR2
  ,x_name                             IN VARCHAR2
 ,x_last_update_date                 IN DATE
 ,x_last_updated_by                  IN NUMBER
 ,x_last_update_login                IN NUMBER);

PROCEDURE delete_row
  (x_program_code                     IN VARCHAR2
  ,x_program_owner_code               IN VARCHAR2
  ,x_assignment_code                  IN VARCHAR2
  ,x_assignment_owner_code            IN VARCHAR2);

PROCEDURE add_language;

PROCEDURE load_row
(p_program_code                       IN VARCHAR2
,p_program_owner_code                 IN VARCHAR2
,p_assignment_code                    IN VARCHAR2
,p_assignment_owner_code              IN VARCHAR2
,p_enabled_flag                       IN VARCHAR2
,p_ledger_short_name                  IN VARCHAR2
,p_owner                              IN VARCHAR2
,p_last_update_date                   IN VARCHAR2
,p_name                               IN VARCHAR2);

PROCEDURE translate_row
  (p_program_code                     IN VARCHAR2
  ,p_program_owner_code               IN VARCHAR2
  ,p_assignment_code                  IN VARCHAR2
  ,p_assignment_owner_code            IN VARCHAR2
  ,p_name                             IN VARCHAR2
  ,p_owner                            IN VARCHAR2
  ,p_last_update_date                 IN VARCHAR2
  ,p_custom_mode                      IN VARCHAR2);

END xla_assignment_defns_f_pkg;
 

/
