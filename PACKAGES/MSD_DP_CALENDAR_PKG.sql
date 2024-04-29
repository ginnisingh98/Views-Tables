--------------------------------------------------------
--  DDL for Package MSD_DP_CALENDAR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DP_CALENDAR_PKG" AUTHID CURRENT_USER AS
/* $Header: msddpcls.pls 120.0 2005/05/25 17:39:11 appldev noship $ */

/* Public Procedures */

PROCEDURE LOAD_ROW(P_DEMAND_PLAN_NAME            in VARCHAR2,
                           P_CALENDAR_TYPE               in VARCHAR2,
                           P_CALENDAR_CODE               in VARCHAR2,
                           P_OWNER                       in VARCHAR2,
                           P_LAST_UPDATE_DATE            in VARCHAR2,
                           P_DELETEABLE_FLAG             in VARCHAR2,
                           P_ENABLE_NONSEED_FLAG             in VARCHAR2,
			   P_CUSTOM_MODE               in VARCHAR2
			   );


END msd_dp_calendar_pkg ;

 

/
