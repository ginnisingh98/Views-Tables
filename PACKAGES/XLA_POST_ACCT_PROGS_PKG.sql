--------------------------------------------------------
--  DDL for Package XLA_POST_ACCT_PROGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_POST_ACCT_PROGS_PKG" AUTHID CURRENT_USER AS
/* $Header: xlaamprg.pkh 120.0 2005/05/24 21:38:59 dcshah noship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_post_acct_progs_pkg                                            |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Post Accounting Programs Package                               |
|                                                                       |
| HISTORY                                                               |
|    01-May-01 Dimple Shah    Created                                   |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| delete_program_details                                                |
|                                                                       |
| Deletes all details of the post accounting program                    |
|                                                                       |
+======================================================================*/

PROCEDURE delete_program_details
  (p_program_code                   IN VARCHAR2
  ,p_program_owner_code             IN VARCHAR2);

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| delete_assignment_details                                             |
|                                                                       |
| Deletes all details of the Assignment Definition                      |
|                                                                       |
+======================================================================*/

PROCEDURE delete_assignment_details
  (p_program_code                   IN VARCHAR2
  ,p_program_owner_code             IN VARCHAR2
  ,p_assignment_code                IN VARCHAR2
  ,p_assignment_owner_code          IN VARCHAR2);

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| copy_assignment_details                                               |
|                                                                       |
| Copies all details of the Assignment Definition                       |
|                                                                       |
+======================================================================*/

PROCEDURE copy_assignment_details
  (p_program_code                   IN VARCHAR2
  ,p_program_owner_code             IN VARCHAR2
  ,p_old_assignment_code            IN VARCHAR2
  ,p_old_assignment_owner_code      IN VARCHAR2
  ,p_new_assignment_code            IN VARCHAR2
  ,p_new_assignment_owner_code      IN VARCHAR2);

END xla_post_acct_progs_pkg;
 

/
