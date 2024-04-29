--------------------------------------------------------
--  DDL for Package EDW_POA_LN_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_POA_LN_TYPE_PKG" AUTHID CURRENT_USER AS
/* $Header: poafklts.pls 120.1 2005/06/13 12:50:29 sriswami noship $  */
VERSION			CONSTANT CHAR(80) := '$Header: poafklts.pls 120.1 2005/06/13 12:50:29 sriswami noship $';

-- ------------------------
-- Public Functions
-- ------------------------
Function line_type_fk(
	p_order_type			in VARCHAR2) return VARCHAR2;

PRAGMA RESTRICT_REFERENCES (Line_type_fk,WNDS, WNPS, RNPS);

end;

 

/
