--------------------------------------------------------
--  DDL for Package MSDWF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSDWF" AUTHID CURRENT_USER AS
/* $Header: msddpwfs.pls 115.3 2002/03/05 10:10:34 pkm ship     $ */


/* Public Procedures */
procedure DOEXPRESS (itemtype in varchar2,
	itemkey  in varchar2,
	actid    in number,
	funcmode in varchar2,
	resultout   out varchar2);
--
--
procedure STARTPRO (WorkflowProcess in varchar2,
	 iteminput in varchar2,
         inputkey in varchar2,
	 inowner in varchar2,
	 inrole in varchar2,
         inplan in varchar2,
         inCDate  in varchar2);
--
--
PROCEDURE LAUNCH (itemtype in varchar2,
	  itemkey  in varchar2,
	  actid    in number,
	  funcmode in varchar2,
          resultout   out varchar2);
--
--
PROCEDURE GOVERNOR (itemtype in varchar2,
	  itemkey  in varchar2,
	  actid    in number,
	  funcmode in varchar2,
          resultout   out varchar2);
--
--
PROCEDURE StartConcProc (WFProcess in varchar2,
				 itemtype in varchar2,
				 itemkey in varchar2,
				 owner  in  varchar2,
                         inplan   in varchar2,
				 cost_itemKey in varchar2);
--
--
PROCEDURE ConcLoop(errbuf out varchar2,
		       retcode out number,
			 itemtype in varchar2,
		       itemkey  in varchar2);

--
--
PROCEDURE RunConcLoop(errbuf out varchar2,
                      retcode out number,
			    ItemType in varchar2,
                      cost_ItemKey in varchar2);
--
--
procedure Selector(itemtype in varchar2,
		  	 itemkey  in varchar2,
		  	 actid    in number,
		  	 command  in varchar2,
                   resultout   out varchar2);
--
--
procedure SetColDate (itemtype in varchar2,
 	  itemkey  in varchar2,
 	  actid    in number,
 	  funcmode in varchar2,
        resultout   out varchar2);
--
--
procedure StartMaster(errbuf out varchar2,
                retcode out number,
      	    PlanName in varchar2,
                NumDays_to_collect in varchar2);


end MSDWF;

 

/
