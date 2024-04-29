--------------------------------------------------------
--  DDL for Package MSD_DP_FORMULA_PARAMETER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DP_FORMULA_PARAMETER_PKG" AUTHID CURRENT_USER AS
/* $Header: msddpfps.pls 120.1 2006/03/31 08:28:50 brampall noship $ */

/* Public Procedures */

PROCEDURE LOAD_ROW(P_DEMAND_PLAN_NAME in varchar2
         ,P_FORMULA_NAME	in varchar2
         ,P_WHERE_USED          in varchar2
         ,P_PARAMETER_SEQUENCE  in varchar2
         ,P_OWNER             in varchar2
         ,P_ENABLED_FLAG       in varchar2
         ,P_MANDATORY_FLAG     in varchar2
         ,P_PARAMETER_TYPE     in varchar2
         ,P_PARAMETER_COMPONENT in varchar2
         ,P_PARAMETER_VALUE    in varchar2
         ,P_SUPPLY_PLAN_FLAG   in varchar2
         ,P_SUPPLY_PLAN_NAME   in varchar2
	 ,P_LAST_UPDATE_DATE in varchar2
         ,P_CUSTOM_MODE in varchar2
	 );

END msd_dp_formula_parameter_pkg ;

 

/
