--------------------------------------------------------
--  DDL for Package FA_XLA_CMP_LOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_XLA_CMP_LOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: faxlacos.pls 120.0.12010000.2 2009/07/19 08:43:12 glchen ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     fa_xla_cmp_load_pkg                                                    |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a FA private package, which contains all the APIs required     |
|     for to create main load extract for each extract type                  |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     25-JUN-2002 BRIDGWAY      Created                                      |
|                                                                            |
+===========================================================================*/


FUNCTION GenerateLoadExtract
      (p_extract_type                 IN VARCHAR2,
       p_package_body                 OUT NOCOPY DBMS_SQL.VARCHAR2S) RETURN BOOLEAN;

END fa_xla_cmp_load_pkg;

/
