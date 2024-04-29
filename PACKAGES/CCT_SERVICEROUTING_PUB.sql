--------------------------------------------------------
--  DDL for Package CCT_SERVICEROUTING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_SERVICEROUTING_PUB" AUTHID CURRENT_USER as
/* $Header: cctrwcss.pls 120.0 2005/06/02 09:52:15 appldev noship $ */

/*------------------------------------------------------------------------
   Service Routing Workflow Activities
*------------------------------------------------------------------------*/



/* -----------------------------------------------------------------------
3  Activity Name : Set_Customer_Filter (filter node)
     To filter the agents by Customer ID
   Prerequisites : The Customer initialization phase must be completed
     before using this filter
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    No output
   ITEM ATTRIBUTES REFERENCED
    CUSTID    - the customer ID
    CUST-F    - the customer filter flag
    CALLID    - the call ID
*-----------------------------------------------------------------------*/
procedure Set_Customer_Filter (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) ;












/* -----------------------------------------------------------------------
20 Activity Name : Set_Product_Filter (Filter node)

   To filter the agents by Product ID.
   Prerequisites: The Product initialization phase must be completed before
                  using this filter.
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    no output
   ITEM ATTRIBUTES REFERENCED
    CALLID   - the call ID
    PRODID   - the product ID
    PROD-F   - the product filter flag

Implementation: No working output is expected from this function.
The CS API returns the number of agents.
The lsit of agents is returned by the CS API as a PL*SQL table.
Loop through the table and insert each agent into the CCT_TEMPAGENTS table.
*-----------------------------------------------------------------------*/
procedure Set_Product_Filter (
 itemtype  in varchar2
 , itemkey in varchar2
 , actid   in number
 , funmode in varchar2
 , resultout in out nocopy varchar2) ;

/* -----------------------------------------------------------------------
   Activity Name : Set_Request_Owner_Filter (filter node)
     To filter the agents by Request Number
   Prerequisites :
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    No output
   ITEM ATTRIBUTES REFERENCED
    CUSTID      - the customer ID
    REQ-OWNER-F - the request owner filter flag
*-----------------------------------------------------------------------*/
procedure Set_Request_Owner_Filter (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) ;


END CCT_ServiceRouting_PUB;

 

/
