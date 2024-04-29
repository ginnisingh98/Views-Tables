--------------------------------------------------------
--  DDL for Package CCT_TELESALESROUTING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_TELESALESROUTING_PUB" AUTHID CURRENT_USER as
/* $Header: ccttswfs.pls 120.0 2005/06/02 10:16:42 appldev noship $ */




/*------------------------------------------------------------------------
   TeleSales Routing Workflow Activities
*------------------------------------------------------------------------*/

/* -----------------------------------------------------------------------
  Activity Name : WF_TeleSalesAgentForParty_FIL
  To filter the agents by Party ID
	Prerequisites : The Customer initialization phase(CCT_CUSTOMER_INIT)
    must be completed before using this filter
	IN
     itemtype  - item type
	 itemkey   - item key
      actid     - process activity instance id
	 funmode   - execution mode
	OUT
	 No output
	ITEM ATTRIBUTES REFERENCED
	  PARTYID    - the customer ID
	  MEDIAITEMID    - the MediaItem ID
*-----------------------------------------------------------------------*/

procedure WF_TeleSalesAgentForParty_FIL (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) ;


/* -----------------------------------------------------------------------
  Activity Name : WF_SalesAgentForSourceCode_FIL
  To filter the agents by Source Code
	Prerequisite : Source Code must exist
	IN
     itemtype  - item type
	 itemkey   - item key
      actid     - process activity instance id
	 funmode   - execution mode
	OUT
	 No output
	ITEM ATTRIBUTES REFERENCED
	  SOURCECODE    - the Source Code
	  MEDIAITEMID    - the MediaItem ID
*-----------------------------------------------------------------------*/

procedure WF_SalesAgentForSourceCode_FIL (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) ;


END CCT_TeleSalesRouting_PUB;

 

/
