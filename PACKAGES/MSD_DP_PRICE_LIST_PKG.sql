--------------------------------------------------------
--  DDL for Package MSD_DP_PRICE_LIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DP_PRICE_LIST_PKG" AUTHID CURRENT_USER AS
/* $Header: msddppls.pls 120.0 2005/05/25 17:38:36 appldev noship $ */

/* Public Procedures */

PROCEDURE LOAD_ROW(P_DEMAND_PLAN_NAME          in varchar2,
                   P_PRICE_LIST_NAME           in varchar2,
                   P_OWNER                     in varchar2,
                   P_DELETEABLE_FLAG           in varchar2,
		   P_LAST_UPDATE_DATE	     in date,
                   P_ENABLE_NONSEED_FLAG             in VARCHAR2,
      		   P_CUSTOM_MODE             in VARCHAR2
                   );

END msd_dp_price_list_pkg ;

 

/
