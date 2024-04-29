--------------------------------------------------------
--  DDL for Package MSD_DP_SEEDED_DOCUMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DP_SEEDED_DOCUMENT_PKG" AUTHID CURRENT_USER AS
/* $Header: msddpsds.pls 120.0 2005/05/25 17:59:36 appldev noship $ */

/* Public Procedures */

PROCEDURE LOAD_ROW(P_DEMAND_PLAN_NAME in varchar2
         ,P_DOCUMENT_NAME	in varchar2
         ,P_OWNER            in varchar2
         ,P_DESCRIPTION       in varchar2
         ,P_TYPE              in varchar2
         ,P_OPEN_ON_STARTUP   in varchar2
         ,P_SCRIPT_CLEANUP    in varchar2
         ,P_SCRIPT_INIT       in varchar2
         ,P_SCRIPT_PREPAGE    in varchar2
         ,P_SCRIPT_POSTPAGE   in varchar2
         ,P_VALID_FLAG        in varchar2
 	 ,P_LAST_UPDATE_DATE  in varchar2
	 ,P_SUB_TYPE          in varchar2
         ,P_CUSTOM_MODE     in varchar2
	 );

END msd_dp_seeded_document_pkg ;

 

/
