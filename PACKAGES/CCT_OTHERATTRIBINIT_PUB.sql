--------------------------------------------------------
--  DDL for Package CCT_OTHERATTRIBINIT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_OTHERATTRIBINIT_PUB" AUTHID CURRENT_USER as
/* $Header: cctothrs.pls 120.0 2005/06/02 09:51:02 appldev noship $ */


/* -----------------------------------------------------------------------
1   Activity Name : WF_SR_Exists (branch node)
     To check if the Service Request Number already exists
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
    ServiceRequestNum   - the Service Request Number
*-----------------------------------------------------------------------*/
procedure WF_SR_Exists (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy  varchar2) ;

/* -----------------------------------------------------------------------
   Activity Name : WF_AccountNum_Exists (branch node)
     To check if the Account Number already exists
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
    AccountCode   - the Account Number
*-----------------------------------------------------------------------*/
procedure WF_AccountNum_Exists (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy  varchar2) ;

/* -----------------------------------------------------------------------
   Activity Name : WF_ANI_Exists (branch node)
     To check if the ANI already exists
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
    ANI   - the ANI
*-----------------------------------------------------------------------*/
procedure WF_ANI_Exists (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy  varchar2) ;

/* -----------------------------------------------------------------------
   Activity Name : WF_CollateralReqNum_Exists (branch node)
     To check if the Collateral Request Number already exists
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
   CollateralReqNum - Collateral Request Number
*-----------------------------------------------------------------------*/
procedure WF_CollateralReqNum_Exists (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy  varchar2) ;
/* -----------------------------------------------------------------------
   Activity Name : WF_ContractNum_Exists (branch node)
     To check if the Contract Number already exists
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
   ContractNum - Contract Number
*-----------------------------------------------------------------------*/
procedure WF_ContractNum_Exists (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy  varchar2) ;
/* -----------------------------------------------------------------------
   Activity Name : WF_EventCode_Exists (branch node)
     To check if the Event Registration Code already exists
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
   EventCode - Event Registration Code
*-----------------------------------------------------------------------*/
procedure WF_EventCode_Exists (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy  varchar2) ;

/* -----------------------------------------------------------------------
   Activity Name : WF_MarketingPIN_Exists (branch node)
     To check if the Event Registration Code already exists
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
   MarketingPIN
*-----------------------------------------------------------------------*/
procedure WF_MarketingPIN_Exists (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy  varchar2) ;
/* -----------------------------------------------------------------------
   Activity Name : WF_OrderNum_Exists (branch node)
     To check if the OrderNum already exists
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
  OrderNum
*-----------------------------------------------------------------------*/
procedure WF_OrderNum_Exists (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy  varchar2) ;
/* -----------------------------------------------------------------------
   Activity Name : WF_CustomerNum_Exists (branch node)
     To check if the Event Registration Code already exists
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
   CustomerNum
*-----------------------------------------------------------------------*/
procedure WF_CustomerNum_Exists (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy  varchar2) ;
/* -----------------------------------------------------------------------
   Activity Name : WF_QuoteNum_Exists (branch node)
     To check if the QuoteNum already exists
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
   QuoteNum
*-----------------------------------------------------------------------*/
procedure WF_QuoteNum_Exists (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy  varchar2) ;
/* -----------------------------------------------------------------------
   Activity Name : WF_ServiceKey_Exists (branch node)
     To check if the ServiceKey already exists
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
   ServiceKey
*-----------------------------------------------------------------------*/
procedure WF_ServiceKey_Exists (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy  varchar2) ;
/* -----------------------------------------------------------------------
   Activity Name : WF_SourceCode_Exists (branch node)
     To check if the Source Code already exists
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   Source Code
*-----------------------------------------------------------------------*/
procedure WF_SourceCode_Exists (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy  varchar2) ;

END CCT_OTHERATTRIBINIT_PUB;

 

/
