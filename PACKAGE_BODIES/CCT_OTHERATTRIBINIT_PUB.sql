--------------------------------------------------------
--  DDL for Package Body CCT_OTHERATTRIBINIT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_OTHERATTRIBINIT_PUB" as
/* $Header: cctothrb.pls 120.0 2005/06/02 09:44:03 appldev noship $ */


G_PKG_NAME CONSTANT VARCHAR2(30) := 'CCT_OTHERATTRIBINIT_PUB';

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
	, resultout 	in  out nocopy  varchar2) IS

    l_proc_name     VARCHAR2(30) := 'WF_SR_Exists';
    l_party_id   NUMBER;
    l_cct_party_id_key VARCHAR2(64):='SERVICEREQUESTNUM';
  BEGIN

    IF (funmode <> 'RUN') THEN
	resultout := wf_engine.eng_null;
	return;
    end if;

    -- set default result
    resultout := wf_engine.eng_completed || ':N';

    l_party_id  := WF_ENGINE.GetItemAttrNumber(itemtype,itemkey,upper(l_cct_party_id_key));
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

end WF_SR_Exists;
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
	, resultout 	in  out nocopy  varchar2) IS

    l_proc_name     VARCHAR2(30) := 'WF_AccountNum_Exists';
    l_party_id   NUMBER;
    l_cct_party_id_key VARCHAR2(64):='ACCOUNTCODE';
  BEGIN

    IF (funmode <> 'RUN') THEN
	resultout := wf_engine.eng_null;
	return;
    end if;

    -- set default result
    resultout := wf_engine.eng_completed || ':N';

    l_party_id  := WF_ENGINE.GetItemAttrNumber(itemtype,itemkey,upper(l_cct_party_id_key));
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

end ;
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
	, resultout 	in  out nocopy  varchar2) IS

    l_proc_name     VARCHAR2(30) := 'WF_ANI_Exists';
    l_party_id   NUMBER;
    l_cct_party_id_key VARCHAR2(64):='OCCTANI';
  BEGIN

    IF (funmode <> 'RUN') THEN
	resultout := wf_engine.eng_null;
	return;
    end if;

    -- set default result
    resultout := wf_engine.eng_completed || ':N';

    l_party_id  := WF_ENGINE.GetItemAttrNumber(itemtype,itemkey,upper(l_cct_party_id_key));
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

end ;

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
	, resultout 	in  out nocopy  varchar2) IS

    l_proc_name     VARCHAR2(30) := 'WF_CollateralReqNum_Exists';
    l_party_id   NUMBER;
    l_cct_party_id_key VARCHAR2(64):='CollateralReq';
  BEGIN

    IF (funmode <> 'RUN') THEN
	resultout := wf_engine.eng_null;
	return;
    end if;

    -- set default result
    resultout := wf_engine.eng_completed || ':N';

    l_party_id  := WF_ENGINE.GetItemAttrNumber(itemtype,itemkey,upper(l_cct_party_id_key));
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

end ;
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
	, resultout 	in  out nocopy  varchar2)IS

    l_proc_name     VARCHAR2(30) := 'WF_ContractNum_Exists';
    l_party_id   NUMBER;
    l_cct_party_id_key VARCHAR2(64):='ContractNum';
  BEGIN

    IF (funmode <> 'RUN') THEN
	resultout := wf_engine.eng_null;
	return;
    end if;

    -- set default result
    resultout := wf_engine.eng_completed || ':N';

    l_party_id  := WF_ENGINE.GetItemAttrNumber(itemtype,itemkey,upper(l_cct_party_id_key));
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

end ;

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
	, resultout 	in  out nocopy  varchar2) IS
	    l_proc_name     VARCHAR2(30) := 'WF_EventCode_Exists';
    l_party_id   NUMBER;
    l_cct_party_id_key VARCHAR2(64):='EventCode';
  BEGIN

    IF (funmode <> 'RUN') THEN
	resultout := wf_engine.eng_null;
	return;
    end if;

    -- set default result
    resultout := wf_engine.eng_completed || ':N';

    l_party_id  := WF_ENGINE.GetItemAttrNumber(itemtype,itemkey,upper(l_cct_party_id_key));
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

end ;
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
	, resultout 	in  out nocopy  varchar2) IS
	l_proc_name     VARCHAR2(60) := 'WF_MarketingPIN_Exists';
    l_party_id   NUMBER;
    l_cct_party_id_key VARCHAR2(64):='MarketingPIN';
  BEGIN

    IF (funmode <> 'RUN') THEN
	resultout := wf_engine.eng_null;
	return;
    end if;

    -- set default result
    resultout := wf_engine.eng_completed || ':N';

    l_party_id  := WF_ENGINE.GetItemAttrNumber(itemtype,itemkey,upper(l_cct_party_id_key));
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

end ;

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
procedure WF_ORderNum_Exists (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in  out nocopy  varchar2) IS
	l_proc_name     VARCHAR2(60) := 'WF_OrderNum_Exists';
    l_party_id   NUMBER;
    l_cct_party_id_key VARCHAR2(64):='OrderNum';
  BEGIN

    IF (funmode <> 'RUN') THEN
	resultout := wf_engine.eng_null;
	return;
    end if;

    -- set default result
    resultout := wf_engine.eng_completed || ':N';

    l_party_id  := WF_ENGINE.GetItemAttrNumber(itemtype,itemkey,upper(l_cct_party_id_key));
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

end ;
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
	, resultout 	in  out nocopy  varchar2) IS
	l_proc_name     VARCHAR2(60) := 'WF_CustomerNum_Exists';
    l_party_id   NUMBER;
    l_cct_party_id_key VARCHAR2(64):='CustomerNum';
  BEGIN

    IF (funmode <> 'RUN') THEN
	resultout := wf_engine.eng_null;
	return;
    end if;

    -- set default result
    resultout := wf_engine.eng_completed || ':N';

    l_party_id  := WF_ENGINE.GetItemAttrNumber(itemtype,itemkey,upper(l_cct_party_id_key));
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

end ;
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
	, resultout 	in  out nocopy  varchar2) IS
	l_proc_name     VARCHAR2(60) := 'WF_QuoteNum_Exists';
    l_party_id   NUMBER;
    l_cct_party_id_key VARCHAR2(64):='QuoteNum';
  BEGIN

    IF (funmode <> 'RUN') THEN
	resultout := wf_engine.eng_null;
	return;
    end if;

    -- set default result
    resultout := wf_engine.eng_completed || ':N';

    l_party_id  := WF_ENGINE.GetItemAttrNumber(itemtype,itemkey,upper(l_cct_party_id_key));
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

end ;
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
	, resultout 	in  out nocopy  varchar2) IS
	l_proc_name     VARCHAR2(60) := 'WF_ServiceKey_Exists';
    l_party_id   NUMBER;
    l_cct_party_id_key VARCHAR2(64):='ServiceKey';
  BEGIN

    IF (funmode <> 'RUN') THEN
	resultout := wf_engine.eng_null;
	return;
    end if;

    -- set default result
    resultout := wf_engine.eng_completed || ':N';

    l_party_id  := WF_ENGINE.GetItemAttrNumber(itemtype,itemkey,upper(l_cct_party_id_key));
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

end ;
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
	, resultout 	in  out nocopy  varchar2) IS
	l_proc_name     VARCHAR2(60) := 'WF_SourceCode_Exists';
    l_source_code   VARCHAR2(255);
    l_cct_party_id_key VARCHAR2(64):='SourceCode';
  BEGIN

    IF (funmode <> 'RUN') THEN
	resultout := wf_engine.eng_null;
	return;
    end if;

    -- set default result
    resultout := wf_engine.eng_completed || ':N';

    l_source_code  := WF_ENGINE.GetItemAttrText(itemtype,itemkey,upper(l_cct_party_id_key));
    --dbms_output.put_line('SourceCodeexists?='||l_source_code);
    if (l_source_code IS NOT NULL) then
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

end ;
END CCT_OTHERATTRIBINIT_PUB;

/
