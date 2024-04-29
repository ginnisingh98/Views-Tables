--------------------------------------------------------
--  DDL for Package MSD_DP_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DP_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: msddpevs.pls 120.0 2005/05/25 20:07:51 appldev noship $ */

/* Public Procedures */


PROCEDURE LOAD_ROW(P_DEMAND_PLAN_NAME               in varchar2,
                   P_EVENT                          in varchar2,
                   P_OWNER                          in varchar2,
                   P_DELETEABLE_FLAG                in varchar2,
                   P_LAST_UPDATE_DATE               in varchar2,
                   P_ENABLE_NONSEED_FLAG             in VARCHAR2,
      		   P_CUSTOM_MODE                  in VARCHAR2
                   );

END msd_dp_event_pkg ;

 

/
