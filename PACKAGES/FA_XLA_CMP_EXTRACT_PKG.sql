--------------------------------------------------------
--  DDL for Package FA_XLA_CMP_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_XLA_CMP_EXTRACT_PKG" AUTHID CURRENT_USER AS
/* $Header: faxlaces.pls 120.0.12010000.2 2009/07/19 08:33:07 glchen ship $   */
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
|     for XLA extract package generation                                     |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     25-FEB-2006 bridgway      Created                                      |
+===========================================================================*/


--+==========================================================================+
--|                                                                          |
--| Private global type declarations                                         |
--|                                                                          |
--+==========================================================================+


--+==========================================================================+
--|                                                                          |
--| Private global constant or variable declarations                         |
--|                                                                          |
--+==========================================================================+


--+==========================================================================+
--|            Template  Package Name                                        |
--+==========================================================================+

C_PACKAGE_NAME             CONSTANT VARCHAR2(30):= 'FA_XLA_EXTRACT_$type$_PKG';

--+==========================================================================+
--|                                                                          |
--|                                                                          |
--| Global variables                                                         |
--|                                                                          |
--|                                                                          |
--+==========================================================================+

g_component_name          VARCHAR2(80);
g_component_appl          VARCHAR2(240);
g_owner                   VARCHAR2(30);


--+==========================================================================+
--| PUBLIC function                                                          |
--|    Compile                                                               |
--|                                                                          |
--| DESCRIPTION : generates the PL/SQL packages from the Product Accounting  |
--|               definition for depreciation.                               |
--|                                                                          |
--|                                                                          |
--|  RETURNS                                                                 |
--|   1. l_IsCompiled  : BOOLEAN, TRUE if the Extract definition has         |
--|                      been successfully created, FALSE otherwise.         |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+

FUNCTION Compile RETURN BOOLEAN;


END fa_xla_cmp_extract_pkg; -- end of package spec

/
