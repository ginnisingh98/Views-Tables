--------------------------------------------------------
--  DDL for Package MSD_DP_SCENARIO_OUTPUT_LVL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DP_SCENARIO_OUTPUT_LVL_PKG" AUTHID CURRENT_USER AS
/* $Header: msddpsols.pls 120.0 2005/05/25 18:53:00 appldev noship $ */

/* Public Procedures */

PROCEDURE LOAD_ROW(P_DEMAND_PLAN_NAME    in varchar2,
                                        P_SCENARIO_NAME        in varchar2,
                                        P_LEVEL_ID             in varchar2,
                                        P_OWNER                in varchar2,
                                        P_DELETEABLE_FLAG      in varchar2,
                                        P_LAST_UPDATE_DATE     in varchar2,
                                        P_ENABLE_NONSEED_FLAG  in VARCHAR2,
                                        P_CUSTOM_MODE        in VARCHAR2
                                        );

END msd_dp_scenario_output_lvl_pkg ;

 

/
