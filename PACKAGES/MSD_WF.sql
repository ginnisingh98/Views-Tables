--------------------------------------------------------
--  DDL for Package MSD_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_WF" AUTHID CURRENT_USER AS
/* $Header: msddpwfs.pls 115.16 2003/12/08 22:28:15 ziahmed ship $ */


/* Public Procedures */
procedure DOEXPRESS (itemtype in varchar2,
	itemkey  in varchar2,
	actid    in number,
	funcmode in varchar2,
	resultout   out NOCOPY varchar2);
--
--
procedure STARTPRO (WorkflowProcess in varchar2,
	 	iteminput in varchar2,
         	inputkey in varchar2,
	 	inowner in varchar2,
	 	inrole in varchar2,
         	inplan in varchar2,
         	inCDate  in varchar2,
		inCodeDB in varchar2);
--
--
PROCEDURE LAUNCH (itemtype in varchar2,
	  itemkey  in varchar2,
	  actid    in number,
	  funcmode in varchar2,
          resultout   out NOCOPY varchar2);
--
--
PROCEDURE GOVERNOR (itemtype in varchar2,
	  itemkey  in varchar2,
	  actid    in number,
	  funcmode in varchar2,
          resultout   out NOCOPY varchar2);
--
--
PROCEDURE StartConcProc(itemtype in varchar2,
                        itemkey in varchar2);

--
PROCEDURE ConcLoop(errbuf out NOCOPY  varchar2,
		       retcode out NOCOPY number,
			 itemtype in varchar2,
		       itemkey  in varchar2);

--
--
PROCEDURE RunConcLoop(errbuf out NOCOPY varchar2,
                      retcode out NOCOPY number,
			    ItemType in varchar2,
                      cost_ItemKey in varchar2);
--
--
procedure SetColDate (itemtype in varchar2,
 	  itemkey  in varchar2,
 	  actid    in number,
 	  funcmode in varchar2,
        resultout   out NOCOPY varchar2);
--
--
procedure  SetUpldDate (itemtype in varchar2,
		  itemkey  in varchar2,
		  actid    in number,
		  funcmode in varchar2,
              resultout   out NOCOPY varchar2);
--
--
procedure StartMaster(errbuf out NOCOPY varchar2,
                retcode out NOCOPY number,
      	    PlanName in varchar2,
                NumDays_to_collect in varchar2,
		    NumDays_to_delayUpld in varchar2);

procedure setowner(p_owner in varchar2);

procedure execute_dml(p_actentry varchar2, p_planid varchar2, p_dbname varchar2,
                      p_SharedLoc varchar2, p_owner varchar2, p_role varchar2, p_itemkey varchar2,
                      p_master varchar2, p_process varchar2,
                      p_retcode out NOCOPY varchar2, p_rettext out NOCOPY varchar2,
                      p_retval out NOCOPY varchar2, p_reterr out NOCOPY varchar2);

--
--
procedure  SET_ATTRIBUTES (itemtype in varchar2,
 		  itemkey  in varchar2,
 		  actid    in number,
 		  funcmode in varchar2,
              resultout out NOCOPY varchar2);
--
--

PROCEDURE DISTRIBUTE (errbuf out NOCOPY varchar2,
                      retcode out NOCOPY number,
	                itemkey  in varchar2);
--
--

procedure execute_dml2(p_actentry varchar2, p_planid varchar2, p_dbname varchar2,
                      p_SharedLoc varchar2, p_owner varchar2, p_role varchar2, p_itemkey varchar2,
                      p_master varchar2, p_process varchar2,
                      p_retcode out NOCOPY varchar2, p_rettext out NOCOPY varchar2,
                      p_retval out NOCOPY varchar2, p_reterr out NOCOPY varchar2);

--
--

end MSD_WF;

 

/
