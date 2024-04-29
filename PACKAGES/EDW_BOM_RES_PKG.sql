--------------------------------------------------------
--  DDL for Package EDW_BOM_RES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_BOM_RES_PKG" AUTHID CURRENT_USER AS
/* $Header: ENIBRESS.pls 115.1 2004/01/30 20:45:28 sbag noship $  */
-- ------------------------
-- Public Functions
-- ------------------------
Function Resource_FK(
        p_dept_line_id             in NUMBER,
        p_resource_id              in NUMBER)
        				return VARCHAR2;

PRAGMA RESTRICT_REFERENCES (Resource_FK,WNDS, WNPS, RNPS);

end;

 

/
