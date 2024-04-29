--------------------------------------------------------
--  DDL for Package MSD_DPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DPE" AUTHID CURRENT_USER AS
/* $Header: msddpprs.pls 120.0 2005/05/25 20:34:33 appldev noship $ */

--

procedure Purge ( errbuf out nocopy varchar2,
                  retcode out nocopy varchar2,
                  PlanID in varchar2,
		  Demand_Plan_Name in varchar2,
		  Shared_DB_Prefix in varchar2,
		  Code_Location in varchar2,
		  Shared_DB_Location in varchar2,
		  Express_Machine_Port in varchar2,
	  	  OWA_Virtual_Path_Name in varchar2,
		  EAD_Name in varchar2,
		  Express_Connect_String in varchar2,
		  DelIfWFActive in varchar2,
                  DelIfConFail in varchar2);

procedure Purge ( errbuf out nocopy varchar2,
                  retcode out nocopy varchar2,
                  PlanID in varchar2,
		  Demand_Plan_Name in varchar2,
		  Shared_DB_Prefix in varchar2,
		  Code_Location in varchar2,
		  Shared_DB_Location in varchar2,
		  Express_Machine_Port in varchar2,
	  	  OWA_Virtual_Path_Name in varchar2,
		  EAD_Name in varchar2,
		  Express_Connect_String in varchar2,
		  DelIfWFActive in varchar2);


procedure ActivityTest (errbuf out nocopy varchar2,
			retcode out nocopy varchar2,
                        inPlan  in number);

procedure DeleteBuildDBS (errbuf out nocopy varchar2,
		    	  actText out nocopy varchar2,
		    	  retcode out nocopy varchar2,
    		    	  inPlan  in number,
			  Demand_Plan_Name in varchar2,
		    	  Shared_DB_Prefix in varchar2,
		    	  Code_Location in varchar2,
		    	  Shared_DB_Location in varchar2,
		    	  Express_Machine_Port in varchar2,
	  	    	  OWA_Virtual_Path_Name in varchar2,
		    	  EAD_Name in varchar2,
		    	  Express_Connect_String in varchar2);

procedure DeleteWorkflow (errbuf out nocopy varchar2,
		    	 retcode out nocopy varchar2,
                   	 inPlan  in number);

Procedure display_message(p_text in varchar2,
		  msg_type in varchar2);

Procedure show_message(p_text in varchar2);

Procedure CallDelWF(inPlan  in number);

Procedure display_error_warning(errbuf in varchar2, retText in varchar2);


end MSD_DPE;

 

/
