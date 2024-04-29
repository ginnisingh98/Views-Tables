--------------------------------------------------------
--  DDL for Package MSD_TEMPLATE_ATTRIBUTE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_TEMPLATE_ATTRIBUTE_PKG" AUTHID CURRENT_USER AS
/* $Header: msddptas.pls 120.0 2005/05/25 18:12:15 appldev noship $ */

/* Public Procedures */

PROCEDURE LOAD_ROW(P_DEMAND_PLAN_NAME in varchar2
         ,P_ATTRIBUTE_NAME	in varchar2
         ,P_ATTRIBUTE_TYPE          in varchar2
         ,P_OWNER  in varchar2
         ,P_ENABLED_FLAG      in varchar2
         ,P_DISPLAYED_FLAG     in varchar2
         ,P_ATTRIBUTE_PROMPT     in varchar2
         ,P_LOV_NAME in varchar2
         ,P_INSERT_ALLOWED_FLAG   in varchar2
	 ,P_LAST_UPDATE_DATE in varchar2
         ,P_ENABLE_NONSEED_FLAG  in VARCHAR2
         ,P_CUSTOM_MODE in varchar2
	 );


END msd_template_attribute_pkg ;

 

/
