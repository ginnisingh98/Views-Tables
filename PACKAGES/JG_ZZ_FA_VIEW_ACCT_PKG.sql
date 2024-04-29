--------------------------------------------------------
--  DDL for Package JG_ZZ_FA_VIEW_ACCT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_FA_VIEW_ACCT_PKG" AUTHID CURRENT_USER as
/* $Header: jgzzfvas.pls 120.0 2005/06/09 23:07:26 appradha ship $ */

/*----------------------------------------------------------------------------*
 |   PUBLIC FUNCTIONS/PROCEDURES  					      |
 *----------------------------------------------------------------------------*/

FUNCTION is_JG_FA_view_acct
RETURN  BOOLEAN;
--PRAGMA RESTRICT_REFERENCES ( is_JG_FA_drilldown, WNDS, WNPS, RNPS);

END JG_ZZ_FA_VIEW_ACCT_PKG;

 

/
