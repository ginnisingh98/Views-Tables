--------------------------------------------------------
--  DDL for Package CCT_CUSTOMERINIT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_CUSTOMERINIT_PUB" AUTHID CURRENT_USER as
/* $Header: cctcusts.pls 120.0 2005/06/02 09:41:26 appldev noship $ */

/*------------------------------------------------------------------------
   Customer Initiation Routing Workflow Activities
*------------------------------------------------------------------------*/

/*------------------------------------------------------------------------
     Group : Customer Initialization Phase
*------------------------------------------------------------------------*/

/* -----------------------------------------------------------------------
1   Activity Name : WF_PartyID_Exists (branch node)
     To check if the Party ID already exists
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
    PartyID   - the party ID
*-----------------------------------------------------------------------*/
procedure WF_PartyIDExists (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) ;

/* -----------------------------------------------------------------------
2a   Activity Name : WF_Get_PartyID_From_ANI (branch node)

   To Check if the Party ID can be derived from the ANI
   If multiple matches exist then this does not derive the PartyID.
   Used by TeleSales application
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
    ANI       - the originating phone num
    PARTYID    - the customer ID
*-----------------------------------------------------------------------*/
procedure WF_PartyIDFromANI (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) ;


/* -----------------------------------------------------------------------


2b   Activity Name : WF_PartyIDFromANI_Multiple  (branch node)

   To Check if the Party ID can be derived from the ANI. If multiple
   matches exist then this derives the first PartyID that matches.
   Used by Teleservice application
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
    ANI       - the originating phone num
    PARTYID    - the PARTY ID
*-----------------------------------------------------------------------*/
procedure WF_PartyIDFromANI_Multiple (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) ;


/* -----------------------------------------------------------------------
3   Activity Name : WF_PartyIDFromPartyNumber (branch node)

   To Check if the Customer ID can be derived from the Party Number
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
    Party Number - the originating party number
    PartyID    - the customer/party ID
*-----------------------------------------------------------------------*/

procedure WF_PartyIDFromPartyNumber (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) ;

/* -----------------------------------------------------------------------
3   Activity Name : WF_PartyIDFromQuoteNumber (branch node)

   To Check if the Customer ID can be derived from the Party Number
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
    Quote Number - the originating quote number
    PartyID    - the customer/party ID
*-----------------------------------------------------------------------*/

procedure WF_PartyIDFromQuoteNumber (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) ;

/* -----------------------------------------------------------------------
4   Activity Name : WF_PartyIDFromOrderNumber (branch node)

   To Check if the Customer ID can be derived from the Party Number
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
    ORDER Number - the originating ORDER number
    PartyID    - the customer/party ID
*-----------------------------------------------------------------------*/

procedure WF_PartyIDFromOrderNumber (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) ;

/* -----------------------------------------------------------------------
5   Activity Name : WF_PartyIDFromCollateralReq (branch node)

   To Check if the Customer ID can be derived from the Party Number
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
    CollateralRequestNumber - the originating Collateral Request number
    PartyID    - the customer/party ID
*-----------------------------------------------------------------------*/

procedure WF_PartyIDFromCollateralReq (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) ;


/* -----------------------------------------------------------------------
5   Activity Name : WF_PartyIDFromAccountNumber (branch node)

   To Check if the Customer ID can be derived from the Party Number
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
    AccountNumber - the originating Account number
    PartyID    - the customer/party ID
*-----------------------------------------------------------------------*/

procedure WF_PartyIDFromAccountNumber (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) ;

/* -----------------------------------------------------------------------
5   Activity Name : WF_PartyIDFromEventCode (branch node)

   To Check if the Customer ID can be derived from the Party Number
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
    EventCode - the originating Event Registration Code
    PartyID    - the customer/party ID
*-----------------------------------------------------------------------*/

procedure WF_PartyIDFromEventCode (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) ;

/* -----------------------------------------------------------------------
5   Activity Name : WF_PartyIDFromMarketingPIN (branch node)

   To Check if the Customer ID can be derived from the Party Number
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
    MarketingPIN - the originating Marketing PIN
    PartyID    - the customer/party ID
*-----------------------------------------------------------------------*/

procedure WF_PartyIDFromMarketingPIN (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) ;

/* -----------------------------------------------------------------------
5   Activity Name : WF_PartyIDFromContractNum (branch node)

   To Check if the Customer ID can be derived from the Contract Number
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
    ContractNum - the originating ContractNumber
    ContractNumModifier - the originating Contract Number Modifier
    PartyID    - the customer/party ID
*-----------------------------------------------------------------------*/

procedure WF_PartyIDFromContractNum (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) ;

/* -----------------------------------------------------------------------
5   Activity Name : WF_PartyIDFromServiceKey (branch node)

   To Check if the Customer ID can be derived from the Party Number
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
    ServiceKey - the originating Service Key
    PartyID    - the customer/party ID
*-----------------------------------------------------------------------*/

procedure WF_PartyIDFromServiceKey (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) ;

/* -----------------------------------------------------------------------
5   Activity Name : WF_PartyIDFromServiceReqNum (branch node)

   To Check if the Party ID can be derived from the Service Request Number
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
    ServiceRequestNumber- the originating ServiceRequestNumber
    PartyID    - the customer/party ID
*-----------------------------------------------------------------------*/

procedure WF_PartyIDFromServiceReqNum (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) ;

/* -----------------------------------------------------------------------
5   Activity Name : WF_PartyIDFromInvoiceNum (branch node)

   To Check if the Party ID can be derived from the Invoice Number
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
    InvoiceNumber- the originating InvoiceNumber
    PartyID    - the customer/party ID
*-----------------------------------------------------------------------*/

procedure WF_PartyIDFromInvoiceNum (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) ;

/* -----------------------------------------------------------------------
   Activity Name : WF_PartyIDFromSerialNum (branch node)

   To Check if the Party ID can be derived from the Serial Number
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
    SerialNumber- the originating SerialNumber
    PartyID    - the customer/party ID
*-----------------------------------------------------------------------*/

procedure WF_PartyIDFromSerialNum (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) ;

/* -----------------------------------------------------------------------
   Activity Name : WF_PartyIDFromSystemName (branch node)

   To Check if the Party ID can be derived from the System Name
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
    System Name- the originating System Name
    PartyID    - the customer/party ID
*-----------------------------------------------------------------------*/

procedure WF_PartyIDFromSystemName (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) ;

/* -----------------------------------------------------------------------
   Activity Name : WF_PartyNameFromPartyID (branch node)

   To Check if the Party Name can be derived from the Party ID
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
    PartyID    - the customer/party ID
    Party Name - the customer/party name
*-----------------------------------------------------------------------*/

procedure WF_PartyNameFromPartyID (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) ;


END CCT_CUSTOMERINIT_PUB;

 

/
