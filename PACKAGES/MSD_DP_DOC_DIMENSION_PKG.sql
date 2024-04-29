--------------------------------------------------------
--  DDL for Package MSD_DP_DOC_DIMENSION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DP_DOC_DIMENSION_PKG" AUTHID CURRENT_USER AS
/* $Header: msddpsdds.pls 120.0 2005/05/25 17:46:50 appldev noship $ */

/* Public Procedures */

PROCEDURE LOAD_ROW(P_DEMAND_PLAN_NAME in varchar2
         ,P_DOCUMENT_NAME	in varchar2
         ,P_DIMENSION_CODE	in varchar2
         ,P_OWNER             in varchar2
         ,P_SEQUENCE_NUMBER    in varchar2
         ,P_AXIS               in varchar2
         ,P_HIERARCHY_ID       in varchar2
         ,P_SELECTION_TYPE     in varchar2
         ,P_SELECTION_SCRIPT   in varchar2
         ,P_ENABLED_FLAG       in varchar2
         ,P_MANDATORY_FLAG     in varchar2
	 ,P_LAST_UPDATE_DATE  in varchar2
         ,P_CUSTOM_MODE  in varchar2
         );

END msd_dp_doc_dimension_pkg;

 

/
