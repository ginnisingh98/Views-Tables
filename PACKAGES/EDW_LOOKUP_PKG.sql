--------------------------------------------------------
--  DDL for Package EDW_LOOKUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_LOOKUP_PKG" AUTHID CURRENT_USER AS
/* $Header: poafklks.pls 120.1 2005/06/13 12:44:11 sriswami noship $  */

-- ------------------------
-- Public Functions
-- ------------------------
Function Lookup_code_fk(
	p_lookup_table			in VARCHAR2,
	p_lookup_type			in VARCHAR2,
	p_lookup_code			in VARCHAR2) return VARCHAR2;

PRAGMA RESTRICT_REFERENCES (Lookup_code_fk,WNDS, WNPS, RNPS);
--PRAGMA RESTRICT_REFERENCES (Lookup_code_fk,WNDS);

Function Lookup_code_fk(
	p_lookup_table			in VARCHAR2,
	p_lookup_type			in VARCHAR2,
	p_lookup_code			in NUMBER) return VARCHAR2;

PRAGMA RESTRICT_REFERENCES (Lookup_code_fk,WNDS, WNPS, RNPS);

end EDW_LOOKUP_PKG;

 

/
