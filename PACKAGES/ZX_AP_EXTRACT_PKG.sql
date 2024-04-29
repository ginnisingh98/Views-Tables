--------------------------------------------------------
--  DDL for Package ZX_AP_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_AP_EXTRACT_PKG" AUTHID CURRENT_USER AS
/* $Header: zxripextractpvts.pls 120.0 2005/02/28 22:58:28 skorrapa noship $ */


-----------------------------------------
--Public Methods Declarations
-----------------------------------------
/*===========================================================================+
 | PROCEDURE                                                                 |
 |   INSERT_TAX_DATA                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure takes the input parameters from ARP_TAX_EXTRACT         |
 |    and builds a dynamic SQL statement clauses based on the parameters     |
 |    supplies them as output parameters.                                    |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |   11-Jan-2005i       Srinivasa Rao Korrapati  Created                     |
 |                                                                           |
 +===========================================================================*/

PROCEDURE INSERT_TAX_DATA (
  P_TRL_GLOBAL_VARIABLES_REC IN OUT NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE
  );

END ZX_AP_EXTRACT_PKG;

 

/
