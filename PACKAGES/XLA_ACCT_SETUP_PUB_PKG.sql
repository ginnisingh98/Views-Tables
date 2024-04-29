--------------------------------------------------------
--  DDL for Package XLA_ACCT_SETUP_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_ACCT_SETUP_PUB_PKG" AUTHID CURRENT_USER AS
-- $Header: xlasuaop.pkh 120.1 2003/02/24 07:04:05 sasingha ship $
/*===========================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|    xla_acct_setup_pub_pkg                                                  |
|                                                                            |
| DESCRIPTION                                                                |
|    XLA Accounting Options Setup Public api                                 |
|                                                                            |
| HISTORY                                                                    |
|    06-Feb-03 Dimple Shah    Created                                        |
|                                                                            |
+===========================================================================*/

--=============================================================================
-- Sets up options for a ledger for all applications
--=============================================================================
PROCEDURE setup_ledger_options
       (p_primary_ledger_id          IN NUMBER
       ,p_ledger_id                  IN NUMBER);

--=============================================================================
-- Checks if the accounting method is valid for a ledger
--=============================================================================
PROCEDURE check_acctg_method_for_ledger
       (p_primary_ledger_id          IN NUMBER
       ,p_ledger_id                  IN NUMBER);

END xla_acct_setup_pub_pkg;
 

/
