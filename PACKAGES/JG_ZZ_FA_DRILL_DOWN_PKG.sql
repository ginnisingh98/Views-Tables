--------------------------------------------------------
--  DDL for Package JG_ZZ_FA_DRILL_DOWN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_FA_DRILL_DOWN_PKG" AUTHID CURRENT_USER as
/* $Header: jgzzfdds.pls 120.2 2005/08/25 23:25:15 cleyvaol ship $ */

/*----------------------------------------------------------------------------*
 |   PUBLIC FUNCTIONS/PROCEDURES  					      |
 *----------------------------------------------------------------------------*/

FUNCTION is_JG_FA_drilldown
          ( p_je_header_id             NUMBER,
            p_je_source                VARCHAR2,
            p_je_category              VARCHAR2
          )
RETURN  BOOLEAN;
--PRAGMA RESTRICT_REFERENCES ( is_JG_FA_drilldown, WNDS, WNPS, RNPS);

END JG_ZZ_FA_DRILL_DOWN_PKG;

 

/
