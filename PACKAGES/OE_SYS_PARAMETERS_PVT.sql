--------------------------------------------------------
--  DDL for Package OE_SYS_PARAMETERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_SYS_PARAMETERS_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVSPMS.pls 115.2 2003/10/20 07:26:40 appldev ship $ */


-- FUNCTION VALUE
-- Use this function to get the value of a system parameter.
-- To be used with release 110510 and above

FUNCTION VALUE
	(p_param_code 		IN VARCHAR2,
	 p_org_id 		IN NUMBER DEFAULT NULL)
RETURN VARCHAR2;

FUNCTION Get_AR_Sys_Params
         (p_org_id IN NUMBER DEFAULT NULL)
RETURN AR_SYSTEM_PARAMETERS_ALL%ROWTYPE;

TYPE AR_Sys_Param_Tbl_Type IS TABLE OF AR_SYSTEM_PARAMETERS_ALL%ROWTYPE
     INDEX BY BINARY_INTEGER;

--G_AR_Sys_Param_Rec      AR_SYSTEM_PARAMETERS_ALL%ROWTYPE;
G_AR_Sys_Param_Tbl      AR_Sys_Param_Tbl_Type;

END OE_Sys_Parameters_Pvt;

 

/
