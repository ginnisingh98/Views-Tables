--------------------------------------------------------
--  DDL for Package ISC_EDW_O2C_DRILL_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_EDW_O2C_DRILL_P" AUTHID CURRENT_USER AS
/* $Header: ISCO2CDS.pls 115.2 2002/01/23 16:51:03 pkm ship      $ */

 PROCEDURE drill_across_wk(pParameter1 IN NUMBER);
 PROCEDURE drill_across_qtd(pParameter1 IN NUMBER);

END isc_edw_o2c_drill_p;

 

/
