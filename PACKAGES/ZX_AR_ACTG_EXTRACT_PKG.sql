--------------------------------------------------------
--  DDL for Package ZX_AR_ACTG_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_AR_ACTG_EXTRACT_PKG" AUTHID CURRENT_USER AS
/* $Header: zxriractgextpvts.pls 120.1 2005/07/29 12:35:40 skorrapa ship $ */
--
-----------------------------------------
--Public Variable Declarations
-----------------------------------------
--

  TYPE SQL_STATEMENT_TABTYPE IS TABLE OF VARCHAR2(32600)
     INDEX BY BINARY_INTEGER;


-----------------------------------------
--Public Methods Declarations
-----------------------------------------
/*===========================================================================+
 | PROCEDURE                                                                 |
 |   EXTRACT_AR_TRX_INFO                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure takes the input parameters from ZX_EXTRACT_PKG          |
 |    and builds  dynamic SQL statement clauses based on the parameters      |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |   11-Jan-2005 Srinivasa Rao Korrapati Created                             |
 |                                                                           |
 +===========================================================================*/

PROCEDURE INSERT_TAX_DATA (
  P_MRC_SOB_TYPE             IN            VARCHAR2,
  P_TRL_GLOBAL_VARIABLES_REC IN OUT NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE
) ;

END ZX_AR_ACTG_EXTRACT_PKG;

 

/
