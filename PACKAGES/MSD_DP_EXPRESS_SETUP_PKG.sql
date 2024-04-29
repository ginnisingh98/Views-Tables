--------------------------------------------------------
--  DDL for Package MSD_DP_EXPRESS_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DP_EXPRESS_SETUP_PKG" AUTHID CURRENT_USER AS
/* $Header: msddpxss.pls 120.0 2005/05/25 17:59:36 appldev noship $ */

/* Public Procedures */

PROCEDURE LOAD_ROW(P_DEMAND_PLAN_NAME in varchar2
         ,P_ORGANIZATION_ID	in number
         ,P_SHARED_DB_PREFIX    in varchar2
         ,P_OWNER            in varchar2
	 ,P_LAST_UPDATE_DATE in varchar2
         ,P_CUSTOM_MODE in varchar2
	 );

END msd_dp_express_setup_pkg ;

 

/
