--------------------------------------------------------
--  DDL for Package MSD_DELETE_DEMAND_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DELETE_DEMAND_PLAN" AUTHID CURRENT_USER AS
/* $Header: msddpds.pls 115.7 2002/11/06 23:05:34 pinamati ship $ */

procedure Delete (errbuf out nocopy varchar2,
		  retcode out nocopy varchar2,
                  planId in varchar2,
		  can_Connect in varchar2,
		  Demand_Plan_Name in varchar2,
		  Shared_DB_Prefix in varchar2,
		  Code_Location in varchar2,
		  Shared_DB_Location in varchar2,
		  Express_Machine_Port in varchar2,
	  	  OWA_Virtual_Path_Name in varchar2,
		  EAD_Name in varchar2,
		  Express_Connect_String in varchar2,
		  DeleteAnyway in varchar2);

END MSD_DELETE_DEMAND_PLAN;

 

/
