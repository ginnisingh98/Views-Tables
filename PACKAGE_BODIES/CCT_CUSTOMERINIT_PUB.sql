--------------------------------------------------------
--  DDL for Package Body CCT_CUSTOMERINIT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_CUSTOMERINIT_PUB" as
/* $Header: cctcustb.pls 115.8 2003/08/23 01:12:34 gvasvani noship $ */


G_PKG_NAME CONSTANT VARCHAR2(30) := 'CCT_CUSTOMERINIT_PUB';

/*------------------------------------------------------------------------
     Group A : Customer Initialization Phase
*------------------------------------------------------------------------*/

/* -----------------------------------------------------------------------
1   Activity Name : WF_Customer_ID_exists (branch node)
     To check if the Customer ID already exists
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
    CUSTID   - the customer ID
*-----------------------------------------------------------------------*/
procedure WF_PartyIDExists (
	itemtype        in varchar2
	, itemkey       in varchar2
	, actid         in number
	, funmode       in varchar2
	, resultout     in out nocopy varchar2) IS

    l_proc_name     VARCHAR2(30) := 'WF_PartyIDExists';
    l_party_id   NUMBER;
    l_cct_party_name_key VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_NAME;
    l_cct_party_id_key VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_ID;
  BEGIN

    IF (funmode <> 'RUN') THEN
	resultout := wf_engine.eng_null;
	return;
    end if;

    -- set default result
    resultout := wf_engine.eng_completed || ':N';

    l_party_id  := WF_ENGINE.GetItemAttrNumber(itemtype,itemkey,upper(l_cct_party_id_key));
    --dbms_output.put_line('PartyIDExists?'||to_char(l_party_id));
    if (l_party_id IS NOT NULL) then
        resultout := wf_engine.eng_completed || ':Y';
    end if;

  EXCEPTION
    WHEN OTHERS THEN
      -- if the customer id is not found
      if (WF_CORE.Error_Name = 'WFENG_ITEM_ATTR') then
         WF_CORE.CLEAR;
         -- default result returned
         return;
      end if;

      -- for other errors
       WF_CORE.Context(G_PKG_NAME, l_proc_name,  itemtype,
                        itemkey, to_char(actid), funmode);
      RAISE;

end WF_PartyIDExists;


/* -----------------------------------------------------------------------
2   Activity Name : WF_Get_PartyID_From_ANI (branch node)

   To Check if the Customer ID can be derived from the ANI
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
    ANI       - the originating phone num
    CUSTID    - the customer ID
*-----------------------------------------------------------------------*/
procedure WF_PartyIDFromANI (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) IS

    l_proc_name	  VARCHAR2(64) := 'WF_PartyIDFromANI';
    l_app_object_value VARCHAR2(255);
    l_app_object_type VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_ANI;
    l_party_name VARCHAR2(255);
    l_Party_ID NUMBER;
    l_cct_party_name_key VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_NAME;
    l_cct_party_id_key VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_ID;
    l_cct_object_type VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_ANI;
  BEGIN
   -- set default result
    resultout := wf_engine.eng_completed || ':N';

    IF (funmode = 'RUN') THEN
      l_app_object_Value  := WF_ENGINE.GetItemAttrText(itemtype,itemkey,upper(l_cct_object_Type));

      --dbms_output.put_line('PartyIDfromANI? ANI='||l_app_object_value);
      if (l_app_object_Value IS NOT NULL) THEN
         -- Call the API provided by AST

		 AST_ROUTING_PUB.getPartyForObject(l_app_object_type,l_app_object_value
		                                  ,l_party_name,l_party_id);

           --dbms_output.put_line('PartyIDfromANI? partyid='||to_char(l_party_id));
         -- if a customer id is returned
         IF ((l_Party_ID <> AST_ROUTING_PUB.G_NO_PARTY) AND
             (l_party_id <> AST_ROUTING_PUB.G_MULTIPLE_PARTY)) THEN
             resultout := wf_engine.eng_completed || ':Y';

             WF_ENGINE.SetItemAttrNumber( itemtype,itemkey,upper(l_cct_party_id_key),
					l_Party_ID );
			 WF_ENGINE.SETITEMATTRTEXT(itemtype,itemkey,upper(l_cct_party_name_key),l_party_name);
         END IF;
      End IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context(G_PKG_NAME, l_proc_name,
      	      itemtype, itemkey, to_char(actid), funmode);
      RAISE;


END WF_PartyIDFromANI;

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
	, resultout 	in out nocopy varchar2)IS

    l_proc_name	  VARCHAR2(64) := 'WF_PartyIDFromANI_Multiple';
    l_app_object_value VARCHAR2(255);
    l_app_object_type VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_ANI;
    l_party_name VARCHAR2(255);
    l_Party_ID NUMBER;
    l_cct_party_name_key VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_NAME;
    l_cct_party_id_key VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_ID;
    l_cct_object_type VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_ANI;
  BEGIN
   -- set default result
    resultout := wf_engine.eng_completed || ':N';

    IF (funmode = 'RUN') THEN
      l_app_object_Value  := WF_ENGINE.GetItemAttrText(itemtype,itemkey,upper(l_cct_object_Type));

      if (l_app_object_Value IS NOT NULL) THEN
         -- Call the API provided by AST
	     l_party_ID:=CSC_ROUTING_UTL.Get_Customer_From_ANI
                    ( p_phone_number  => l_app_object_value  ) ;

         -- if a customer id is returned
         IF (l_Party_ID IS NOT NULL) THEN
             l_party_name:=CSC_ROUTING_UTL.Get_Name_Of_Customer
                             ( p_party_id => l_party_ID ) ;
             resultout := wf_engine.eng_completed || ':Y';
             WF_ENGINE.SetItemAttrNumber( itemtype,itemkey,upper(l_cct_party_id_key),
					l_Party_ID );
			 WF_ENGINE.SETITEMATTRTEXT(itemtype,itemkey,upper(l_cct_party_name_key),l_party_name);
         END IF;
      End IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context(G_PKG_NAME, l_proc_name,
      	      itemtype, itemkey, to_char(actid), funmode);
      RAISE;


END WF_PartyIDFromANI_Multiple;

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
	, resultout 	in out nocopy varchar2) IS

    l_proc_name	  VARCHAR2(64) := 'WF_PartyIDFromPartyNumber';
    l_app_object_Value VARCHAR2(32);
    l_app_object_type VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_PARTY_NUMBER;
    l_party_name VARCHAR2(255);
    l_Party_ID NUMBER;
    l_cct_party_name_key VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_NAME;
    l_cct_party_id_key VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_ID;
    l_cct_object_type VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_PARTY_NUMBER;
  BEGIN
    -- set default result
    resultout := wf_engine.eng_completed || ':N';

    --dbms_output.put_line('PartyNum2PartyID?start');
    IF (funmode = 'RUN') THEN
      l_app_object_Value  := WF_ENGINE.GetItemAttrText(itemtype,itemkey,upper(l_cct_object_Type));
	 --dbms_output.put_line('PartyNum2PartyID?PNum='||l_app_object_value);

      if (l_app_object_Value IS NOT NULL) THEN
         -- Call the API provided by AST

		 AST_ROUTING_PUB.getPartyForObject(l_app_object_type,l_app_object_value
		                                  ,l_party_name,l_party_id);

         -- if a customer id is returned
         IF ((l_Party_ID <> AST_ROUTING_PUB.G_NO_PARTY) AND
             (l_party_id <> AST_ROUTING_PUB.G_MULTIPLE_PARTY)) THEN
             resultout := wf_engine.eng_completed || ':Y';

             WF_ENGINE.SetItemAttrNumber( itemtype,itemkey,upper(l_cct_party_id_key),
					l_Party_ID );
			 WF_ENGINE.SETITEMATTRTEXT(itemtype,itemkey,upper(l_cct_party_name_key),l_party_name);
         END IF;
      End IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      --dbms_output.put_line('PartyNum2PartyID?exception'||sqlerrm);
      WF_CORE.Context(G_PKG_NAME, l_proc_name,
      	      itemtype, itemkey, to_char(actid), funmode);
      RAISE;


END WF_PartyIDFromPartyNumber;

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
	, resultout 	in out nocopy varchar2) IS

    l_proc_name	  VARCHAR2(64) := 'WF_PartyIDFromQuoteNumber';
    l_app_object_Value VARCHAR2(32);
    l_app_object_type VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_QUOTE_NUMBER;
    l_party_name VARCHAR2(255);
    l_Party_ID NUMBER;
    l_cct_party_name_key VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_NAME;
    l_cct_party_id_key VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_ID;
    l_cct_object_type VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_QUOTE_NUMBER;
  BEGIN
    -- set default result
    resultout := wf_engine.eng_completed || ':N';

    IF (funmode = 'RUN') THEN
      l_app_object_Value  := WF_ENGINE.GetItemAttrText(itemtype,itemkey,upper(l_cct_object_Type));

      if (l_app_object_Value IS NOT NULL) THEN
         -- Call the API provided by AST

		 AST_ROUTING_PUB.getPartyForObject(l_app_object_type,l_app_object_value
		                                  ,l_party_name,l_party_id);

         -- if a customer id is returned
         IF ((l_Party_ID <> AST_ROUTING_PUB.G_NO_PARTY) AND
             (l_party_id <> AST_ROUTING_PUB.G_MULTIPLE_PARTY)) THEN
             resultout := wf_engine.eng_completed || ':Y';

             WF_ENGINE.SetItemAttrNumber( itemtype,itemkey,upper(l_cct_party_id_key),
					l_Party_ID );
			 WF_ENGINE.SETITEMATTRTEXT(itemtype,itemkey,upper(l_cct_party_name_key),l_party_name);
         END IF;
      End IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context(G_PKG_NAME, l_proc_name,
      	      itemtype, itemkey, to_char(actid), funmode);
      RAISE;

END WF_PartyIDFromQuoteNumber;

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
procedure WF_PartyIDFromORDERNumber (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) IS

    l_proc_name	  VARCHAR2(64) := 'WF_PartyIDFromORDERNumber';
    l_app_object_Value VARCHAR2(32);
    l_cct_party_name_key VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_NAME;
    l_cct_party_id_key VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_ID;
    l_party_name VARCHAR2(255);
    l_Party_ID NUMBER;
    l_app_object_type VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_ORDER_NUMBER;
    l_cct_object_type VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_ORDER_NUMBER;
  BEGIN
    -- set default result
    resultout := wf_engine.eng_completed || ':N';

    IF (funmode = 'RUN') THEN
      l_app_object_Value  := WF_ENGINE.GetItemAttrText(itemtype,itemkey,upper(l_cct_object_Type));

      if (l_app_object_Value IS NOT NULL) THEN
         -- Call the API provided by AST

		 AST_ROUTING_PUB.getPartyForObject(l_app_object_type,l_app_object_value
		                                  ,l_party_name,l_party_id);

         -- if a customer id is returned
         IF ((l_Party_ID <> AST_ROUTING_PUB.G_NO_PARTY) AND
             (l_party_id <> AST_ROUTING_PUB.G_MULTIPLE_PARTY)) THEN
             resultout := wf_engine.eng_completed || ':Y';

             WF_ENGINE.SetItemAttrNumber( itemtype,itemkey,upper(l_cct_party_id_key),
					l_Party_ID );
			 WF_ENGINE.SETITEMATTRTEXT(itemtype,itemkey,upper(l_cct_party_name_key),l_party_name);
         END IF;
      End IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context(G_PKG_NAME, l_proc_name,
      	      itemtype, itemkey, to_char(actid), funmode);
      RAISE;

END WF_PartyIDFromORDERNumber;
/* -----------------------------------------------------------------------
5   Activity Name : WF_PartyIDFromCollateralRequestNumber (branch node)

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


procedure WF_PartyIDFromCollateralReq(
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) IS

    l_proc_name	  VARCHAR2(64) := 'WF_PartyIDFromCollateralRequestNumber';
    l_cct_party_name_key VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_NAME;
    l_cct_party_id_key VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_ID;
    l_app_object_Value VARCHAR2(32);
    l_app_object_type VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_COLLATERAL_REQUEST_NUMBER;
    l_cct_object_type VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_COLLATERAL_REQUEST_NUMBER;
    l_party_name VARCHAR2(255);
    l_Party_ID NUMBER;
  BEGIN
    -- set default result
    resultout := wf_engine.eng_completed || ':N';

    IF (funmode = 'RUN') THEN
      l_app_object_Value  := WF_ENGINE.GetItemAttrText(itemtype,itemkey,upper(l_cct_object_Type));

      if (l_app_object_Value IS NOT NULL) THEN
         -- Call the API provided by AST

		 AST_ROUTING_PUB.getPartyForObject(l_app_object_type,l_app_object_value
		                                  ,l_party_name,l_party_id);

         -- if a customer id is returned
         IF ((l_Party_ID <> AST_ROUTING_PUB.G_NO_PARTY) AND
             (l_party_id <> AST_ROUTING_PUB.G_MULTIPLE_PARTY)) THEN
             resultout := wf_engine.eng_completed || ':Y';

             WF_ENGINE.SetItemAttrNumber( itemtype,itemkey,upper(l_cct_party_id_key),
					l_Party_ID );
			 WF_ENGINE.SETITEMATTRTEXT(itemtype,itemkey,upper(l_cct_party_name_key),l_party_name);
         END IF;
      End IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context(G_PKG_NAME, l_proc_name,
      	      itemtype, itemkey, to_char(actid), funmode);
      RAISE;

END WF_PartyIDFromCollateralReq;

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
	, resultout 	in out nocopy varchar2) IS

    l_proc_name	  VARCHAR2(64) := 'WF_PartyIDFromAccountNumber';
    l_app_object_Value VARCHAR2(32);
    l_cct_party_name_key VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_NAME;
    l_cct_party_id_key VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_ID;
    l_party_name VARCHAR2(255);
    l_Party_ID NUMBER;
    l_app_object_type VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_ACCOUNT_NUMBER;
    l_cct_object_type VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_ACCOUNT_NUMBER;
  BEGIN
    -- set default result
    resultout := wf_engine.eng_completed || ':N';

    IF (funmode = 'RUN') THEN
      l_app_object_Value  := WF_ENGINE.GetItemAttrText(itemtype,itemkey,upper(l_cct_object_Type));

      if (l_app_object_Value IS NOT NULL) THEN
         -- Call the API provided by AST

		 AST_ROUTING_PUB.getPartyForObject(l_app_object_type,l_app_object_value
		                                  ,l_party_name,l_party_id);

         -- if a customer id is returned
         IF ((l_Party_ID <> AST_ROUTING_PUB.G_NO_PARTY) AND
             (l_party_id <> AST_ROUTING_PUB.G_MULTIPLE_PARTY)) THEN
             resultout := wf_engine.eng_completed || ':Y';

             WF_ENGINE.SetItemAttrNumber( itemtype,itemkey,upper(l_cct_party_id_key),
					l_Party_ID );
			 WF_ENGINE.SETITEMATTRTEXT(itemtype,itemkey,upper(l_cct_party_name_key),l_party_name);
         END IF;
      End IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context(G_PKG_NAME, l_proc_name,
      	      itemtype, itemkey, to_char(actid), funmode);
      RAISE;

END WF_PartyIDFromAccountNumber;

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
    EventCode - the originating Registration Code
    PartyID    - the customer/party ID
*-----------------------------------------------------------------------*/
procedure WF_PartyIDFromEventCode (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) IS

    l_proc_name	  VARCHAR2(64) := 'WF_PartyIDFromEventCode';
    l_app_object_Value VARCHAR2(32);
    l_cct_party_name_key VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_NAME;
    l_cct_party_id_key VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_ID;
    l_party_name VARCHAR2(255);
    l_Party_ID NUMBER;
    l_app_object_type VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_EVENT_REGISTRATION_CODE;
    l_cct_object_type VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_EVENT_REGISTRATION_CODE;
  BEGIN
    -- set default result
    resultout := wf_engine.eng_completed || ':N';

    IF (funmode = 'RUN') THEN
      l_app_object_Value  := WF_ENGINE.GetItemAttrText(itemtype,itemkey,upper(l_cct_object_Type));

      if (l_app_object_Value IS NOT NULL) THEN
         -- Call the API provided by AST

		 AST_ROUTING_PUB.getPartyForObject(l_app_object_type,l_app_object_value
		                                  ,l_party_name,l_party_id);

         -- if a customer id is returned
         IF ((l_Party_ID <> AST_ROUTING_PUB.G_NO_PARTY) AND
             (l_party_id <> AST_ROUTING_PUB.G_MULTIPLE_PARTY)) THEN
             resultout := wf_engine.eng_completed || ':Y';

             WF_ENGINE.SetItemAttrNumber( itemtype,itemkey,upper(l_cct_party_id_key),
					l_Party_ID );
			 WF_ENGINE.SETITEMATTRTEXT(itemtype,itemkey,upper(l_cct_party_name_key),l_party_name);
         END IF;
      End IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context(G_PKG_NAME, l_proc_name,
      	      itemtype, itemkey, to_char(actid), funmode);
      RAISE;

END WF_PartyIDFromEventCode;

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
	, resultout 	in out nocopy varchar2) IS

    l_proc_name	  VARCHAR2(64) := 'WF_PartyIDFromMarketingPIN';
    l_app_object_Value VARCHAR2(32);
    l_cct_party_name_key VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_NAME;
    l_cct_party_id_key VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_ID;
    l_party_name VARCHAR2(255);
    l_Party_ID NUMBER;
    l_app_object_type VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_MARKETING_PIN;
    l_cct_object_type VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_MARKETING_PIN;
  BEGIN
    -- set default result
    resultout := wf_engine.eng_completed || ':N';

    IF (funmode = 'RUN') THEN
      l_app_object_Value  := WF_ENGINE.GetItemAttrText(itemtype,itemkey,upper(l_cct_object_Type));

      if (l_app_object_Value IS NOT NULL) THEN
         -- Call the API provided by AST

		 AST_ROUTING_PUB.getPartyForObject(l_app_object_type,l_app_object_value
		                                  ,l_party_name,l_party_id);

         -- if a customer id is returned
         IF ((l_Party_ID <> AST_ROUTING_PUB.G_NO_PARTY) AND
             (l_party_id <> AST_ROUTING_PUB.G_MULTIPLE_PARTY)) THEN
             resultout := wf_engine.eng_completed || ':Y';

             WF_ENGINE.SetItemAttrNumber( itemtype,itemkey,upper(l_cct_party_id_key),
					l_Party_ID );
			 WF_ENGINE.SETITEMATTRTEXT(itemtype,itemkey,upper(l_cct_party_name_key),l_party_name);
         END IF;
      End IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context(G_PKG_NAME, l_proc_name,
      	      itemtype, itemkey, to_char(actid), funmode);
      RAISE;

END WF_PartyIDFromMarketingPIN;
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
	, resultout 	in out nocopy varchar2) IS
    l_proc_name	  VARCHAR2(64) := 'WF_PartyIDFromMarketingPIN';
    l_app_object_Value VARCHAR2(32);
    l_app_object_value2 VARCHAR2(32);
    l_cct_party_name_key VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_NAME;
    l_cct_party_id_key VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_ID;
    l_party_name VARCHAR2(255);
    l_Party_ID NUMBER;
    l_app_object_type VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CONTRACT_NUMBER;
    l_cct_object_type VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CONTRACT_NUMBER;
    l_cct_object_type2 VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CONTRACT_NUMBER_MODIFIER;
  BEGIN
    -- set default result
    resultout := wf_engine.eng_completed || ':N';

    IF (funmode = 'RUN') THEN
      l_app_object_Value  := WF_ENGINE.GetItemAttrText(itemtype,itemkey,upper(l_cct_object_Type));
      l_app_object_Value2  := WF_ENGINE.GetItemAttrText(itemtype,itemkey,upper(l_cct_object_Type2));

      if (l_app_object_Value IS NOT NULL) THEN
         -- Call the API provided by AST

		 AST_ROUTING_PUB.getPartyForObject(l_app_object_type,l_app_object_value,l_cct_object_type2,l_app_object_value2
		                                  ,l_party_name,l_party_id);

         -- if a customer id is returned
         IF ((l_Party_ID <> AST_ROUTING_PUB.G_NO_PARTY) AND
             (l_party_id <> AST_ROUTING_PUB.G_MULTIPLE_PARTY)) THEN
             resultout := wf_engine.eng_completed || ':Y';

             WF_ENGINE.SetItemAttrNumber( itemtype,itemkey,upper(l_cct_party_id_key),
					l_Party_ID );
			 WF_ENGINE.SETITEMATTRTEXT(itemtype,itemkey,upper(l_cct_party_name_key),l_party_name);
         END IF;
      End IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context(G_PKG_NAME, l_proc_name,
      	      itemtype, itemkey, to_char(actid), funmode);
      RAISE;

END;
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
	, resultout 	in out nocopy varchar2) IS

    l_proc_name	  VARCHAR2(64) := 'WF_PartyIDFromServiceKey';
    l_app_object_Value VARCHAR2(32);
    l_cct_party_name_key VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_NAME;
    l_cct_party_id_key VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_ID;
    l_party_name VARCHAR2(255);
    l_Party_ID NUMBER;
    l_app_object_type VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_SERVICE_KEY;
    l_cct_object_type VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_SERVICE_KEY;
  BEGIN
    -- set default result
    resultout := wf_engine.eng_completed || ':N';

    IF (funmode = 'RUN') THEN
      l_app_object_Value  := WF_ENGINE.GetItemAttrText(itemtype,itemkey,upper(l_cct_object_Type));

      if (l_app_object_Value IS NOT NULL) THEN
         -- Call the API provided by AST

		 AST_ROUTING_PUB.getPartyForObject(l_app_object_type,l_app_object_value
		                                  ,l_party_name,l_party_id);

         -- if a customer id is returned
         IF ((l_Party_ID <> AST_ROUTING_PUB.G_NO_PARTY) AND
             (l_party_id <> AST_ROUTING_PUB.G_MULTIPLE_PARTY)) THEN
             resultout := wf_engine.eng_completed || ':Y';

             WF_ENGINE.SetItemAttrNumber( itemtype,itemkey,upper(l_cct_party_id_key),
					l_Party_ID );
			 WF_ENGINE.SETITEMATTRTEXT(itemtype,itemkey,upper(l_cct_party_name_key),l_party_name);
         END IF;
      End IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context(G_PKG_NAME, l_proc_name,
      	      itemtype, itemkey, to_char(actid), funmode);
      RAISE;

END WF_PartyIDFromServiceKey;

/* -----------------------------------------------------------------------
5   Activity Name : WF_PartyIDFromServiceReqNum (branch node)

   To Check if the Customer ID can be derived from the Party Number
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
	, resultout 	in out nocopy varchar2) IS

    l_proc_name	  VARCHAR2(64) := 'WF_PartyIDFromServiceReqNum';
    l_app_object_Value VARCHAR2(32);
    l_cct_party_name_key VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_NAME;
    l_cct_party_id_key VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_ID;
    l_party_name VARCHAR2(255);
    l_Party_ID NUMBER;
    l_app_object_type VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_SERVICE_REQUEST_NUMBER;
    l_cct_object_type VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_SERVICE_REQUEST_NUMBER;
  BEGIN
    -- set default result
    resultout := wf_engine.eng_completed || ':N';

    IF (funmode = 'RUN') THEN
      l_app_object_Value  := WF_ENGINE.GetItemAttrText(itemtype,itemkey,upper(l_cct_object_Type));

      if (l_app_object_Value IS NOT NULL) THEN
         -- Call the API provided by AST

		 AST_ROUTING_PUB.getPartyForObject(l_app_object_type,l_app_object_value
		                                  ,l_party_name,l_party_id);

         -- if a customer id is returned
         IF ((l_Party_ID <> AST_ROUTING_PUB.G_NO_PARTY) AND
             (l_party_id <> AST_ROUTING_PUB.G_MULTIPLE_PARTY)) THEN
             resultout := wf_engine.eng_completed || ':Y';

             WF_ENGINE.SetItemAttrNumber( itemtype,itemkey,upper(l_cct_party_id_key),
					l_Party_ID );
			 WF_ENGINE.SETITEMATTRTEXT(itemtype,itemkey,upper(l_cct_party_name_key),l_party_name);
         END IF;
      End IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context(G_PKG_NAME, l_proc_name,
      	      itemtype, itemkey, to_char(actid), funmode);
      RAISE;

END WF_PartyIDFromServiceReqNum;

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
	, resultout 	in out nocopy varchar2)IS

    l_proc_name	  VARCHAR2(64) := 'WF_PartyIDFromInvoiceNum';
    l_app_object_Value VARCHAR2(32);
    l_cct_party_name_key VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_NAME;
    l_cct_party_id_key VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_ID;
    l_party_name VARCHAR2(255);
    l_Party_ID NUMBER;
    l_app_object_type VARCHAR2(64):='INVOICE_NUMBER';
    l_cct_object_type VARCHAR2(64):='INVOICENUM';
  BEGIN
    -- set default result
    resultout := wf_engine.eng_completed || ':N';

    IF (funmode = 'RUN') THEN
      l_app_object_Value  := WF_ENGINE.GetItemAttrText(itemtype,itemkey,upper(l_cct_object_Type));

      if (l_app_object_Value IS NOT NULL) THEN
         -- Call the API provided by CSC
		 l_party_ID:=CSC_ROUTING_UTL.Get_Customer_From_InvoiceNum
                        ( p_Invoice_Number => l_app_object_value ) ;

         -- if a customer id is returned
         IF (l_Party_ID is not null) THEN
             l_party_name:=CSC_ROUTING_UTL.Get_Name_Of_Customer
                             ( p_party_id => l_party_ID ) ;
             resultout := wf_engine.eng_completed || ':Y';
             WF_ENGINE.SetItemAttrNumber( itemtype,itemkey,upper(l_cct_party_id_key),
					l_Party_ID );
			 WF_ENGINE.SETITEMATTRTEXT(itemtype,itemkey,upper(l_cct_party_name_key),l_party_name);
         END IF;
      End IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context(G_PKG_NAME, l_proc_name,
      	      itemtype, itemkey, to_char(actid), funmode);
      RAISE;

END;

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
	, resultout 	in out nocopy varchar2)IS

    l_proc_name	  VARCHAR2(64) := 'WF_PartyIDFromSerialNum';
    l_app_object_Value VARCHAR2(32);
    l_cct_party_name_key VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_NAME;
    l_cct_party_id_key VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_ID;
    l_party_name VARCHAR2(255);
    l_Party_ID NUMBER;
    l_app_object_type VARCHAR2(64):='SERIAL_NUMBER';
    l_cct_object_type VARCHAR2(64):='SERIALNUM';
  BEGIN
    -- set default result
    resultout := wf_engine.eng_completed || ':N';

    IF (funmode = 'RUN') THEN
      l_app_object_Value  := WF_ENGINE.GetItemAttrText(itemtype,itemkey,upper(l_cct_object_Type));

      if (l_app_object_Value IS NOT NULL) THEN
         -- Call the API provided by CSC
		 l_party_ID:=CS_ROUTING_UTL.Get_Customer_From_SerialNum
                        ( p_Serial_Number => l_app_object_value ) ;

         -- if a customer id is returned
         IF (l_Party_ID is not null) THEN
             l_party_name:=CSC_ROUTING_UTL.Get_Name_Of_Customer
                             ( p_party_id => l_party_ID ) ;
             resultout := wf_engine.eng_completed || ':Y';
             WF_ENGINE.SetItemAttrNumber( itemtype,itemkey,upper(l_cct_party_id_key),
					l_Party_ID );
			 WF_ENGINE.SETITEMATTRTEXT(itemtype,itemkey,upper(l_cct_party_name_key),l_party_name);
         END IF;
      End IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context(G_PKG_NAME, l_proc_name,
      	      itemtype, itemkey, to_char(actid), funmode);
      RAISE;

END;

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
	, resultout 	in out nocopy varchar2)IS

    l_proc_name	  VARCHAR2(64) := 'WF_PartyIDFromSystemName';
    l_app_object_Value VARCHAR2(32);
    l_cct_party_name_key VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_NAME;
    l_cct_party_id_key VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_ID;
    l_party_name VARCHAR2(255);
    l_Party_ID NUMBER;
    l_app_object_type VARCHAR2(64):='SYSTEM_NAME';
    l_cct_object_type VARCHAR2(64):='SYSTEMNAME';
  BEGIN
    -- set default result
    resultout := wf_engine.eng_completed || ':N';

    IF (funmode = 'RUN') THEN
      l_app_object_Value  := WF_ENGINE.GetItemAttrText(itemtype,itemkey,upper(l_cct_object_Type));

      if (l_app_object_Value IS NOT NULL) THEN
         -- Call the API provided by CSC
		 l_party_ID:=CS_ROUTING_UTL.Get_Customer_From_System_Name
                        ( p_system_name => l_app_object_value ) ;

         -- if a customer id is returned
         IF (l_Party_ID is not null) THEN
             l_party_name:=CSC_ROUTING_UTL.Get_Name_Of_Customer
                             ( p_party_id => l_party_ID ) ;
             resultout := wf_engine.eng_completed || ':Y';
             WF_ENGINE.SetItemAttrNumber( itemtype,itemkey,upper(l_cct_party_id_key),
					l_Party_ID );
			 WF_ENGINE.SETITEMATTRTEXT(itemtype,itemkey,upper(l_cct_party_name_key),l_party_name);
         END IF;
      End IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context(G_PKG_NAME, l_proc_name,
      	      itemtype, itemkey, to_char(actid), funmode);
      RAISE;

END;

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
	, resultout 	in out nocopy varchar2)  IS
	l_proc_name	  VARCHAR2(64) := 'WF_PartyIDFromSystemName';
    l_app_object_Value VARCHAR2(32);
    l_cct_party_name_key VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_NAME;
    l_cct_party_id_key VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_ID;
    l_party_name VARCHAR2(255);
    l_Party_ID NUMBER;
    l_app_object_type VARCHAR2(64):='PARTY_ID';
    l_cct_object_type VARCHAR2(64):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_ID;
  BEGIN
    -- set default result
    resultout := wf_engine.eng_completed || ':N';

    IF (funmode = 'RUN') THEN
      l_app_object_Value  := WF_ENGINE.GetItemAttrText(itemtype,itemkey,upper(l_cct_object_Type));

      if (l_app_object_Value IS NOT NULL) THEN
		 l_party_id:=l_app_object_value;

         -- if a customer id is returned
         IF (l_Party_ID is not null) THEN
             l_party_name:=CSC_ROUTING_UTL.Get_Name_Of_Customer
                             ( p_party_id => l_party_ID ) ;
             resultout := wf_engine.eng_completed || ':Y';
             WF_ENGINE.SetItemAttrNumber( itemtype,itemkey,upper(l_cct_party_id_key),
					l_Party_ID );
			 WF_ENGINE.SETITEMATTRTEXT(itemtype,itemkey,upper(l_cct_party_name_key),l_party_name);
         END IF;
      End IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context(G_PKG_NAME, l_proc_name,
      	      itemtype, itemkey, to_char(actid), funmode);
      RAISE;

END;



END CCT_CUSTOMERINIT_PUB;

/
