--------------------------------------------------------
--  DDL for Package ZX_CORE_REP_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_CORE_REP_EXTRACT_PKG" AUTHID CURRENT_USER AS
/* $Header: zxricoreplugpvts.pls 120.1 2005/09/22 18:15:54 skorrapa ship $ */


--
-----------------------------------------
--Public Type Declarations
-----------------------------------------
--

--
-----------------------------------------
--Public Variable Declarations
-----------------------------------------
--

-----------------------------------------
--Private Methods Declarations
-----------------------------------------

-----------------------------------------
--Public Methods Declarations
-----------------------------------------

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   POPULATE_CORE_AP                                                  |
 |   Type       : Public                                                     |
 |   Pre-req    : None                                                       |
 |   Function   :                                                            |
 |    This procedure filters tax lines on Detail Table.                     |
 |    And insert tax lines into zx_rep_trx_jl_ext_t Table if necessary       |
 |                                                                           |
 |    Called from ZX_EXTRACT_PKG                                             |
 |                                                                           |
 +===========================================================================*/


PROCEDURE POPULATE_CORE_AP(
          P_TRL_GLOBAL_VARIABLES_REC     IN      ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE
          );

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   POPULATE_CORE_AR                                                  |
 |   Type       : Public                                                     |
 |   Pre-req    : None                                                       |
 |   Function   :                                                            |
 |    This procedure filters tax lines on Detail Table.                     |
 |    And insert tax lines into zx_rep_trx_jl_ext_t Table if necessary       |
 |    US Sales Tax Report Plugin is included in this procedure               |
 |                                                                           |
 |    Called from ZX_EXTRACT_PKG                                             |
 |                                                                           |
 +===========================================================================*/


PROCEDURE POPULATE_CORE_AR(
          P_TRL_GLOBAL_VARIABLES_REC     IN      ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE
          );

END ZX_CORE_REP_EXTRACT_PKG;

 

/
