--------------------------------------------------------
--  DDL for Package EDW_DEMAND_CLASS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_DEMAND_CLASS_PKG" AUTHID CURRENT_USER AS
/*$Header: ISCSCA0S.pls 115.4 2002/12/13 21:11:57 kxliu ship $*/
FUNCTION get_demand_class_fk (
	p_demand_class_code in VARCHAR2,
	p_instance_code in VARCHAR2 := NULL)	RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (get_demand_class_fk, WNDS, WNPS, RNPS);
END edw_demand_class_pkg;

 

/
