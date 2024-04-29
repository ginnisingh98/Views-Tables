--------------------------------------------------------
--  DDL for Package OPI_COLLECTION_HOOK_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_COLLECTION_HOOK_P" AUTHID CURRENT_USER AS
	/*$Header: OPICOLLS.pls 115.6 2002/04/29 15:58:52 pkm ship     $ */
   Procedure POST_IPS_COLL(FACT_NAME IN Varchar2);
   Procedure POST_MARGIN_COLL(p_Base_fact_name VARCHAR2);
   PROCEDURE PRE_MARGIN_COLL;
   PROCEDURE POST_REVENUE_COLL;
   PROCEDURE POST_COGS_COLL;
   PROCEDURE GATHER_STATS(P_TABLE_NAME   VARCHAR2);
   PROCEDURE TURNC_TAB(P_TABLE_NAME   VARCHAR2);
End OPI_COLLECTION_HOOK_P;

 

/
