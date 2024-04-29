--------------------------------------------------------
--  DDL for Package MSD_SOP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_SOP" AUTHID CURRENT_USER AS
/* $Header: msdspwfs.pls 120.0 2005/05/25 19:54:15 appldev noship $ */

procedure Start_SOP_Master(
		    errbuf out NOCOPY varchar2,
                retcode out NOCOPY number,
      	    PlanName in varchar2,
		    NumDays_to_delayDist in varchar2,
                NumDays_to_collect in varchar2,
		    NumDays_to_delayUpld in varchar2);
--
--

procedure Set_Master_Attributes(
		    errbuf out NOCOPY varchar2,
                retcode out NOCOPY number,
      	    PlanName in varchar2,
                Days_tocollect in varchar2,
		    Days_delayUpld in varchar2,
		    ProcessName in varchar2);
--
--

procedure Launch_ASCP_Plan(
		  	itemtype in varchar2,
 		  	itemkey  in varchar2,
 		  	actid    in number,
 		  	funcmode in varchar2,
              	resultout out NOCOPY varchar2);


--
--


end MSD_SOP;

 

/
