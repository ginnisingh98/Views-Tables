--------------------------------------------------------
--  DDL for Package XLA_CMP_LOCK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_CMP_LOCK_PKG" AUTHID CURRENT_USER AS
/* $Header: xlacplck.pkh 120.0 2004/06/02 11:53:50 aquaglia ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_cmp_lock_pkg                                                   |
|                                                                       |
| DESCRIPTION                                                           |
|    Locking logic for AMB and TAB objects                              |
|                                                                       |
| HISTORY                                                               |
|    28-JAN-04 A.Quaglia      Created                                   |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/



/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| lock_tats_and_sources                                                 |
|                                                                       |
| This program locks the database records related to the enabled        |
| Transaction Account Types defined for the specified application       |
| and the associated sources.                                           |
|                                                                       |
| It returns a BOOLEAN value.                                           |
|     TRUE  means that the locking was successful.                      |
|     FALSE means that errors were encountered and that the locking     |
|           was unsuccessful.                                           |
|                                                                       |
+======================================================================*/
FUNCTION lock_tats_and_sources
                           ( p_application_id       IN         NUMBER
                           )
RETURN BOOLEAN
;







/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| lock_tad                                                              |
|                                                                       |
| This program locks the database records related to the specified      |
| Transaction Account Definition.                                       |
| It locks recursively the details, the Account Derivation Rules,       |
| the conditions, the mapping sets and the sources.                     |
|                                                                       |
| It returns a BOOLEAN value.                                           |
|     TRUE  means that the locking was successful.                      |
|     FALSE means that errors were encountered and that the locking     |
|           was unsuccessful.                                           |
|                                                                       |
+======================================================================*/
FUNCTION lock_tad
            (
              p_application_id                 IN NUMBER
             ,p_account_definition_code        IN VARCHAR2
             ,p_account_definition_type_code   IN VARCHAR2
             ,p_amb_context_code               IN VARCHAR2
            )

RETURN BOOLEAN
;


END xla_cmp_lock_pkg;
 

/
