--------------------------------------------------------
--  DDL for Package MSD_DP_PARAMETER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DP_PARAMETER_PKG" AUTHID CURRENT_USER AS
/* $Header: msddpips.pls 120.1 2006/03/31 07:09:51 brampall noship $ */

/* Public Procedures */


PROCEDURE LOAD_ROW(P_DEMAND_PLAN_NAME           in VARCHAR2,
	                    P_PARAMETER_TYPE             in VARCHAR2,
                            P_PARAMETER_NAME             in VARCHAR2,
                            P_OWNER                      in VARCHAR2,
                            P_START_DATE                 in VARCHAR2,
                            P_END_DATE                   in VARCHAR2,
                            P_INPUT_SCENARIO             in VARCHAR2,
                            P_FORECAST_DATE_USED         in VARCHAR2,
                            P_FORECAST_BASED_ON          in VARCHAR2,
                            P_QUANTITY_USED              in VARCHAR2,
                            P_AMOUNT_USED                in VARCHAR2,
                            P_FORECAST_USED              in varchar2,
                            P_PERIOD_TYPE                in varchar2,
                            P_FACT_TYPE                  in varchar2,
                            P_VIEW_NAME                  in varchar2,
                            P_ALLO_AGG_BASIS_STREAM_ID   in varchar2,
                            P_NUMBER_OF_PERIOD           in varchar2,
                            P_EXCLUDE_FROM_ROLLING_CYCLE in varchar2,
                            P_ROUNDING_FLAG              in varchar2,
                            P_DELETEABLE_FLAG            in varchar2,
			    P_LAST_UPDATE_DATE           in varchar2,
			    P_CAPACITY_USAGE_RATIO       in VARCHAR2,
              	            P_SUPPLY_PLAN_FLAG           in VARCHAR2,
                            P_ENABLE_NONSEED_FLAG        in VARCHAR2,
			    P_PRICE_LIST_NAME            in VARCHAR2,
 			    P_CUSTOM_MODE               in VARCHAR2,
 			    									P_STREAM_TYPE  							 in VARCHAR2,
 			    									P_EQUATION									 in VARCHAR2,
 			    									P_CALCULATED_ORDER					 in VARCHAR2,
 			    									P_POST_CALCULATION           in VARCHAR2,
 			    									P_ARCHIVED_FOR_PARAMETER     in VARCHAR2
	                    );


END msd_dp_parameter_pkg ;

 

/
