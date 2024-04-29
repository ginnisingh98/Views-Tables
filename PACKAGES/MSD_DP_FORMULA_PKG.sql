--------------------------------------------------------
--  DDL for Package MSD_DP_FORMULA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DP_FORMULA_PKG" AUTHID CURRENT_USER AS
/* $Header: msddpfs.pls 120.2 2005/12/21 23:18:45 amitku noship $ */

/* Public Procedures */

PROCEDURE LOAD_ROW(P_DEMAND_PLAN_NAME in varchar2
         ,P_FORMULA_NAME	in varchar2
         ,P_OWNER            in varchar2
         ,P_CREATION_SEQUENCE in varchar2
         ,P_FORMULA_DESC      in varchar2
         ,P_CUSTOM_TYPE       in varchar2
         ,P_EQUATION          in varchar2
         ,P_CUSTOM_FIELD1     in varchar2
         ,P_CUSTOM_FIELD2     in varchar2
         ,P_CUSTOM_SUBTYPE    in varchar2
         ,P_CUSTOM_ADDTLCALC  in varchar2
         ,P_ISBY              in varchar2
         ,P_VALID_FLAG        in varchar2
         ,P_NUMERATOR         in varchar2
         ,P_DENOMINATOR       in varchar2
         ,P_SUPPLY_PLAN_FLAG  in varchar2
         ,P_SUPPLY_PLAN_NAME  in varchar2
         ,P_UPLOAD_FORMULA_ID in varchar2
	 ,P_LAST_UPDATE_DATE  in varchar2
	 ,P_FORMAT            in varchar2       --Added a new coulumn in MSD_DP_FORMULAS table (Bug#4373422)
	 ,P_START_PERIOD      in varchar2
         ,P_CUSTOM_MODE       in varchar2


	 );

END msd_dp_formula_pkg ;

 

/
