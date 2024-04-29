--------------------------------------------------------
--  DDL for Package MSD_DP_DOC_DIM_SELECTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DP_DOC_DIM_SELECTION_PKG" AUTHID CURRENT_USER AS
/* $Header: msddpddss.pls 120.0 2005/05/25 20:38:51 appldev noship $ */

/* Public Procedures */

PROCEDURE LOAD_ROW(P_DEMAND_PLAN_NAME in varchar2
         ,P_DOCUMENT_NAME	in varchar2
         ,P_DIMENSION_CODE	in varchar2
         ,P_SELECTION_SEQUENCE	in varchar2
         ,P_OWNER            in varchar2
         ,P_ENABLED_FLAG      in varchar2
         ,P_MANDATORY_FLAG    in varchar2
         ,P_SELECTION_TYPE    in varchar2
         ,P_SELECTION_COMPONENT in varchar2
         ,P_SELECTION_VALUE   in varchar2
         ,P_SUPPLY_PLAN_FLAG  in varchar2
         ,P_SUPPLY_PLAN_NAME  in varchar2
	 ,P_LAST_UPDATE_DATE in varchar2
         ,P_CUSTOM_MODE in varchar2
	 );

END msd_dp_doc_dim_selection_pkg ;

 

/
