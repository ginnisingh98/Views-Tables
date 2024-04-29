--------------------------------------------------------
--  DDL for Package MSD_DP_SCENARIO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DP_SCENARIO_PKG" AUTHID CURRENT_USER AS
/* $Header: msddpscs.pls 120.1 2006/03/31 07:12:34 brampall noship $ */

/* Public Procedures */

PROCEDURE LOAD_ROW(P_DEMAND_PLAN_NAME            in varchar2,
                           P_SCENARIO_NAME               in varchar2,
                           P_OWNER                       in varchar2,
                           P_DESCRIPTION                 in varchar2,
                           P_OUTPUT_PERIOD_TYPE          in varchar2,
                           P_HORIZON_START_DATE          in varchar2,
                           P_HORIZON_END_DATE            in varchar2,
                           P_FORECAST_DATE_USED          in varchar2,
                           P_FORECAST_BASED_ON           in varchar2,
                           P_SCENARIO_TYPE               in varchar2,
                           P_STATUS                      in varchar2,
                           P_HISTORY_START_DATE          in varchar2,
                           P_HISTORY_END_DATE            in varchar2,
                           P_PUBLISH_FLAG                in varchar2,
                           P_ENABLE_FLAG                 in varchar2,
                           P_PRICE_LIST_NAME             in varchar2,
                           P_LAST_REVISION               in varchar2,
                           P_PARAMETER_NAME              in varchar2,
                           P_CONSUME_FLAG                in varchar2,
                           P_ERROR_TYPE                  in varchar2,
                           P_DELETEABLE_FLAG             in varchar2,
			   									 P_LAST_UPDATE_DATE            in varchar2,
			   									 P_SUPPLY_PLAN_FLAG            in varchar2,
	                         P_ENABLE_NONSEED_FLAG         in VARCHAR2,
												   P_SCENARIO_DESIGNATOR         in VARCHAR2,
               		   			 P_CUSTOM_MODE                 in VARCHAR2,
               		   			 P_SC_TYPE										 in VARCHAR2,
               		   			 P_ASSOCIATE_PARAMETER				 in VARCHAR2
                           );

PROCEDURE TRANSLATE_ROW(P_DEMAND_PLAN_NAME in varchar2,
                        P_SCENARIO_NAME in varchar2,
                        P_DESCRIPTION in varchar2,
			P_OWNER  in varchar2);
PROCEDURE ADD_LANGUAGE;

END msd_dp_scenario_pkg ;

 

/
