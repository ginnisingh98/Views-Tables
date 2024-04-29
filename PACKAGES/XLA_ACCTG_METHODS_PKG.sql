--------------------------------------------------------
--  DDL for Package XLA_ACCTG_METHODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_ACCTG_METHODS_PKG" AUTHID CURRENT_USER AS
/* $Header: xlaamsam.pkh 120.2 2003/01/23 22:27:06 dcshah ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_acctg_methods_pkg                                              |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Subledger Accounting Methods Package                           |
|                                                                       |
| HISTORY                                                               |
|    01-Sep-01 Dimple Shah    Created                                   |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| delete_method_details                                                 |
|                                                                       |
| Deletes all details of the Accounting Method                          |
|                                                                       |
+======================================================================*/

PROCEDURE delete_method_details
  (p_accounting_method_type_code      IN VARCHAR2
  ,p_accounting_method_code           IN VARCHAR2);

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| copy_method_details                                                   |
|                                                                       |
| Copies the details of the old product rule into the new product rule  |
|                                                                       |
+======================================================================*/

 PROCEDURE copy_method_details
  (p_old_accting_meth_type_code     IN VARCHAR2
  ,p_old_accting_meth_code          IN VARCHAR2
  ,p_new_accting_meth_type_code     IN VARCHAR2
  ,p_new_accting_meth_code          IN VARCHAR2);

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| method_in_use                                                         |
|                                                                       |
| Returns true if the accounting method is in use by ledger             |
|                                                                       |
+======================================================================*/

FUNCTION method_in_use
  (p_event                            IN VARCHAR2
  ,p_accounting_method_type_code      IN VARCHAR2
  ,p_accounting_method_code           IN VARCHAR2
  ,p_ledger_name                      IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| method_is_invalid                                                     |
|                                                                       |
| Returns true if the accounting method is invalid                      |
|                                                                       |
+======================================================================*/

FUNCTION method_is_invalid
  (p_accounting_method_type_code      IN VARCHAR2
  ,p_accounting_method_code           IN VARCHAR2
  ,p_message_name                    OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

END xla_acctg_methods_pkg;
 

/
