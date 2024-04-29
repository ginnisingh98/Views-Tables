--------------------------------------------------------
--  DDL for Package OE_SYS_PARAMETERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_SYS_PARAMETERS" AUTHID CURRENT_USER AS
/* $Header: OESYSPAS.pls 115.9 2003/10/20 06:48:01 appldev ship $ */


-- FUNCTION VALUE
-- Use this function to get the value of a system parameter.

FUNCTION VALUE
	(param_name 		IN VARCHAR2,
	p_org_id 		IN NUMBER DEFAULT NULL)
RETURN VARCHAR2;

-- FUNCTION VALUE_WNPS                                                          -- Use this function to get the value of a system parameter.
-- Since this function has pragma WNPS associated with it,
-- it can be used in where clauses of SQL statements.

FUNCTION VALUE_WNPS
	(param_name 		IN VARCHAR2,
	p_org_id 		IN NUMBER DEFAULT NULL)
RETURN VARCHAR2;

-- aksingh removed this retriction for the fix of bug1632598/1715969
--PRAGMA RESTRICT_REFERENCES(VALUE_WNPS, WNPS, RNPS);

END OE_Sys_Parameters;

 

/
