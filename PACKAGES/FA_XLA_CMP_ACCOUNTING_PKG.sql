--------------------------------------------------------
--  DDL for Package FA_XLA_CMP_ACCOUNTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_XLA_CMP_ACCOUNTING_PKG" AUTHID CURRENT_USER AS
/* $Header: faxlacas.pls 120.0.12010000.2 2009/07/19 08:32:10 glchen ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     fa_xla_cmp_extract_pkg                                                 |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a FA private package, which contains all the APIs required     |
|     for XLA extract package body generation                                |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     25-FEB-2006 bridgway      Created                                      |
+===========================================================================*/


--+==========================================================================+
--| PUBLIC procedure                                                         |
--|    Compile                                                               |
--|                                                                          |
--| DESCRIPTION : generates the PL/SQL packages from the Product Accounting  |
--|               definition for Assets                                      |
--|                                                                          |
--+==========================================================================+

PROCEDURE compile;

END fa_xla_cmp_accounting_pkg;

/
