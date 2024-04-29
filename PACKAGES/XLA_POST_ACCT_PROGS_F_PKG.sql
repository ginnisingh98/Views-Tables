--------------------------------------------------------
--  DDL for Package XLA_POST_ACCT_PROGS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_POST_ACCT_PROGS_F_PKG" AUTHID CURRENT_USER AS
/* $Header: xlathprg.pkh 120.0 2005/05/24 21:42:26 dcshah noship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_post_acct_progs                                                  |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_post_acct_progs                         |
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
  ,x_application_id                   IN NUMBER
  ,x_name                             IN VARCHAR2
  ,x_description                      IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER);

PROCEDURE lock_row
  (x_program_code                     IN VARCHAR2
  ,x_program_owner_code               IN VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_name                             IN VARCHAR2
  ,x_description                      IN VARCHAR2);

PROCEDURE update_row
 ( x_program_code                     IN VARCHAR2
  ,x_program_owner_code               IN VARCHAR2
  ,x_application_id                   IN NUMBER
 ,x_name                             IN VARCHAR2
 ,x_description                      IN VARCHAR2
 ,x_last_update_date                 IN DATE
 ,x_last_updated_by                  IN NUMBER
 ,x_last_update_login                IN NUMBER);

PROCEDURE delete_row
  (x_program_code                     IN VARCHAR2
  ,x_program_owner_code               IN VARCHAR2);

PROCEDURE add_language;

PROCEDURE load_row
(p_application_short_name             IN VARCHAR2
,p_program_code                       IN VARCHAR2
,p_program_owner_code                 IN VARCHAR2
,p_owner                              IN VARCHAR2
,p_last_update_date                   IN VARCHAR2
,p_name                               IN VARCHAR2
,p_description                        IN VARCHAR2);

PROCEDURE translate_row
  (p_program_code                       IN VARCHAR2
  ,p_program_owner_code                 IN VARCHAR2
  ,p_name                             IN VARCHAR2
  ,p_description                      IN VARCHAR2
  ,p_owner                            IN VARCHAR2
  ,p_last_update_date                 IN VARCHAR2
  ,p_custom_mode                      IN VARCHAR2);

END xla_post_acct_progs_f_pkg;
 

/
