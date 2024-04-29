--------------------------------------------------------
--  DDL for Package MSD_DEMAND_PLAN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DEMAND_PLAN_PKG" AUTHID CURRENT_USER AS
/* $Header: msddplns.pls 120.1 2006/03/31 08:22:55 brampall noship $ */

/* Public Procedures */

PROCEDURE LOAD_ROW(P_DEMAND_PLAN_NAME           in VARCHAR2,
                            P_OWNER                      in VARCHAR2,
                            P_DESCRIPTION                in VARCHAR2,
                            P_BASE_UOM                   in VARCHAR2,
                            P_LOWEST_PERIOD_TYPE         in VARCHAR2,
                            P_LAST_UPDATE_DATE           in VARCHAR2,
                            P_VALID_FLAG                 in VARCHAR2,
                            P_ENABLE_FCST_EXPLOSION      in VARCHAR2,
                            P_ROUNDOFF_THREASHOLD        in VARCHAR2,
                            P_ROUNDOFF_DECIMAL_PLACES    in VARCHAR2,
                            P_AMT_THRESHOLD              in VARCHAR2,
                            P_AMT_DECIMAL_PLACES         in VARCHAR2,
                            P_G_MIN_TIM_LVL_ID           in VARCHAR2,
                            P_M_MIN_TIM_LVL_ID           in VARCHAR2,
                            P_F_MIN_TIM_LVL_ID           in VARCHAR2,
                            P_C_MIN_TIM_LVL_ID           in VARCHAR2,
                            P_USE_ORG_SPECIFIC_BOM_FLAG  in VARCHAR2,
                            P_TEMPLATE_FLAG              in VARCHAR2,
			    P_ORGANIZATION_ID            in VARCHAR2,
			    P_SR_INSTANCE_ID             in VARCHAR2,
			    P_PLAN_TYPE                  in VARCHAR2,
                            P_DEFAULT_TEMPLATE           in VARCHAR2,
                            P_STRIPE_STREAM_NAME				 in VARCHAR2,
			    P_CUSTOM_MODE              in VARCHAR2);

PROCEDURE TRANSLATE_ROW(P_DEMAND_PLAN_NAME in varchar2,
                        P_DESCRIPTION in varchar2,
			P_OWNER  in varchar2);
PROCEDURE ADD_LANGUAGE;

END msd_demand_plan_pkg ;

 

/
