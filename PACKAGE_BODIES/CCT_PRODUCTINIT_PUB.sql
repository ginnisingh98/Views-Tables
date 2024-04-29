--------------------------------------------------------
--  DDL for Package Body CCT_PRODUCTINIT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_PRODUCTINIT_PUB" as
/* $Header: cctprodb.pls 120.0 2005/06/02 09:51:36 appldev noship $ */

/* -----------------------------------------------------------------------
   Activity Name : WF_ProductFromReferenceNum (branch node)

   To Check if the Customer Product ID can be derived from the reference num
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   out nocopy
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
    REFNUM    - the originating reference num
    CPID      - the customer product ID
*-----------------------------------------------------------------------*/
procedure WF_ProductFromReferenceNum (
 itemtype  in varchar2
 , itemkey in varchar2
 , actid   in number
 , funmode in varchar2
 , resultout in out nocopy  varchar2)IS
    l_proc_name     VARCHAR2(64) := 'WF_ProductFromReferenceNum';
    l_app_object_value VARCHAR2(255);
    l_party_name VARCHAR2(255);
    l_prod_ID NUMBER;
    l_cct_prod_id_key VARCHAR2(64):='CUSTOMERPRODUCTID';
    l_cct_object_type VARCHAR2(64):='REFERENCENUM';
BEGIN
    -- set default result
    resultout := wf_engine.eng_completed || ':N';
    IF (funmode = 'RUN') THEN
      l_app_object_value := WF_ENGINE.GetItemAttrText(itemtype,itemkey,l_cct_object_type);
      IF (l_app_object_value IS NOT NULL) THEN
        l_prod_id:=CSC_ROUTING_UTL.Get_CP_From_ReferenceNum(p_Reference_Number=>l_app_object_value) ;
        IF (l_prod_id IS NOT NULL) THEN
            resultout := wf_engine.eng_completed || ':Y';
          	WF_ENGINE.SetItemAttrNumber(itemtype,itemkey,l_cct_prod_id_key,l_prod_id );
         END IF;
      END IF;

    END IF;
END;

/* -----------------------------------------------------------------------
  Activity Name : WF_ProductFromServiceReqNum (branch node)

   To Check if the Customer Product ID can be derived from the reference num
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
    ServiceRequestNum    - the originating Service Request Number
    CPID      - the customer product ID
*-----------------------------------------------------------------------*/
procedure WF_ProductFromServiceReqNum (
 itemtype  in varchar2
 , itemkey in varchar2
 , actid   in number
 , funmode in varchar2
 , resultout in out nocopy  varchar2) IS
    l_proc_name     VARCHAR2(64) := 'WF_ProductFromServiceReqNum';
    l_app_object_value VARCHAR2(255);
    l_party_name VARCHAR2(255);
    l_prod_ID NUMBER;
    l_cct_prod_id_key VARCHAR2(64):='CUSTOMERPRODUCTID';
    l_cct_object_type VARCHAR2(64):='SERVICEREQUESTNUM';
BEGIN
    -- set default result
    resultout := wf_engine.eng_completed || ':N';
    IF (funmode = 'RUN') THEN
      l_app_object_value := WF_ENGINE.GetItemAttrText(itemtype,itemkey,l_cct_object_type);
      IF (l_app_object_value IS NOT NULL) THEN
        l_prod_id:=CS_ROUTING_UTL.Get_CP_From_RequestNum
                        (p_Request_Number =>l_app_object_value) ;
        IF (l_prod_id IS NOT NULL) THEN
            resultout := wf_engine.eng_completed || ':Y';
          	WF_ENGINE.SetItemAttrNumber(itemtype,itemkey,l_cct_prod_id_key,l_prod_id );
         END IF;
      END IF;

    END IF;
END;

/* -----------------------------------------------------------------------
  Activity Name : WF_ProductFromSerialNum (branch node)

   To Check if the Customer Product ID can be derived from the Serial number
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
    SerialNum    - the originating Serial Number
    CPID      - the customer product ID
*-----------------------------------------------------------------------*/
procedure WF_ProductFromSerialNum (
 itemtype  in varchar2
 , itemkey in varchar2
 , actid   in number
 , funmode in varchar2
 , resultout in out nocopy  varchar2) IS
    l_proc_name     VARCHAR2(64) := 'WF_ProductFromSerialNum';
    l_app_object_value VARCHAR2(255);
    l_party_name VARCHAR2(255);
    l_prod_ID NUMBER;
    l_cct_prod_id_key VARCHAR2(64):='CUSTOMERPRODUCTID';
    l_cct_object_type VARCHAR2(64):='SERIALNUM';
BEGIN
    -- set default result
    resultout := wf_engine.eng_completed || ':N';
    IF (funmode = 'RUN') THEN
      l_app_object_value := WF_ENGINE.GetItemAttrText(itemtype,itemkey,l_cct_object_type);
      IF (l_app_object_value IS NOT NULL) THEN
        l_prod_id:=CS_ROUTING_UTL.Get_CP_From_SerialNum
                           ( p_Serial_Number  =>l_app_object_value) ;
        IF (l_prod_id IS NOT NULL) THEN
            resultout := wf_engine.eng_completed || ':Y';
          	WF_ENGINE.SetItemAttrNumber(itemtype,itemkey,l_cct_prod_id_key,l_prod_id );
         END IF;
      END IF;

    END IF;
END;
/* -----------------------------------------------------------------------
  Activity Name : WF_InventoryItemFromRefNum (branch node)

   To Check if the Inventory Item ID can be derived from the Reference number
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
    ReferenceNum    - the originating Serial Number
    InventoryItemID      - the product ID
*-----------------------------------------------------------------------*/
procedure WF_InventoryItemFromRefNum (
 itemtype  in varchar2
 , itemkey in varchar2
 , actid   in number
 , funmode in varchar2
 , resultout in out nocopy  varchar2) IS
    l_proc_name     VARCHAR2(64) := 'WF_InventoryItemFromRefNum';
    l_app_object_value VARCHAR2(255);
    l_party_name VARCHAR2(255);
    l_prod_ID NUMBER;
    l_cct_prod_id_key VARCHAR2(64):='INVENTORYITEMID';
    l_cct_object_type VARCHAR2(64):='REFERENCENUM';
BEGIN
    -- set default result
    resultout := wf_engine.eng_completed || ':N';
    IF (funmode = 'RUN') THEN
      l_app_object_value := WF_ENGINE.GetItemAttrText(itemtype,itemkey,l_cct_object_type);
      IF (l_app_object_value IS NOT NULL) THEN
        l_prod_id:= CSC_ROUTING_UTL.Get_Product_From_ReferenceNum (
                        p_Reference_Number  =>l_app_object_value) ;
        IF (l_prod_id IS NOT NULL) THEN
            resultout := wf_engine.eng_completed || ':Y';
          	WF_ENGINE.SetItemAttrNumber(itemtype,itemkey,l_cct_prod_id_key,l_prod_id );
         END IF;
      END IF;

    END IF;
END;
/* -----------------------------------------------------------------------
  Activity Name : WF_InventoryItemFromSR (branch node)

   To Check if the Inventory Item ID can be derived from the Reference number
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
    SR   - the originating Service Request Number
    InventoryItemID      - the product ID
*-----------------------------------------------------------------------*/
procedure WF_InventoryItemFromSR (
 itemtype  in varchar2
 , itemkey in varchar2
 , actid   in number
 , funmode in varchar2
 , resultout in out nocopy  varchar2) IS
    l_proc_name     VARCHAR2(64) := 'WF_InventoryItemFromSR';
    l_app_object_value VARCHAR2(255);
    l_party_name VARCHAR2(255);
    l_prod_ID NUMBER;
    l_cct_prod_id_key VARCHAR2(64):='INVENTORYITEMID';
    l_cct_object_type VARCHAR2(64):='SERVICEREQUESTNUM';
BEGIN
    -- set default result
    resultout := wf_engine.eng_completed || ':N';
    IF (funmode = 'RUN') THEN
      l_app_object_value := WF_ENGINE.GetItemAttrText(itemtype,itemkey,l_cct_object_type);
      IF (l_app_object_value IS NOT NULL) THEN
        l_prod_id:= CS_ROUTING_UTL.Get_Product_From_RequestNum
                                     (p_Request_Number  =>l_app_object_value) ;
        IF (l_prod_id IS NOT NULL) THEN
            resultout := wf_engine.eng_completed || ':Y';
          	WF_ENGINE.SetItemAttrNumber(itemtype,itemkey,l_cct_prod_id_key,l_prod_id );
         END IF;
      END IF;

    END IF;
END;

/* -----------------------------------------------------------------------
  Activity Name : WF_InventoryItemFromSerNum (branch node)

   To Check if the Inventory Item ID can be derived from the Reference number
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
    SerNum  - the originating Serial Number
    InventoryItemID      - the product ID
*-----------------------------------------------------------------------*/
procedure WF_InventoryItemFromSerNum (
 itemtype  in varchar2
 , itemkey in varchar2
 , actid   in number
 , funmode in varchar2
 , resultout in out nocopy  varchar2) IS
    l_proc_name     VARCHAR2(64) := 'WF_InventoryItemFromSerNum';
    l_app_object_value VARCHAR2(255);
    l_party_name VARCHAR2(255);
    l_prod_ID NUMBER;
    l_cct_prod_id_key VARCHAR2(64):='INVENTORYITEMID';
    l_cct_object_type VARCHAR2(64):='SERIALNUM';
BEGIN
    -- set default result
    resultout := wf_engine.eng_completed || ':N';
    IF (funmode = 'RUN') THEN
      l_app_object_value := WF_ENGINE.GetItemAttrText(itemtype,itemkey,l_cct_object_type);
      IF (l_app_object_value IS NOT NULL) THEN
        l_prod_id:= CS_ROUTING_UTL.Get_Product_From_SerialNum
                  (p_Serial_Number  =>l_app_object_value) ;
        IF (l_prod_id IS NOT NULL) THEN
            resultout := wf_engine.eng_completed || ':Y';
          	WF_ENGINE.SetItemAttrNumber(itemtype,itemkey,l_cct_prod_id_key,l_prod_id );
         END IF;
      END IF;

    END IF;
END;

/* -----------------------------------------------------------------------
  Activity Name : WF_ProductID_Exists (branch node)

   To Check if the Customer Product ID Exists.
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
   CustomerProductID      - the product ID
*-----------------------------------------------------------------------*/
procedure WF_ProductID_Exists (
 itemtype  in varchar2
 , itemkey in varchar2
 , actid   in number
 , funmode in varchar2
 , resultout in out nocopy  varchar2) IS
    l_proc_name     VARCHAR2(64) := 'WF_ProductID_Exists';
    l_app_object_value VARCHAR2(255);
    l_party_name VARCHAR2(255);
    l_prod_ID NUMBER;
    l_cct_prod_id_key VARCHAR2(64):='CUSTOMERPRODUCTID';
    l_cct_object_type VARCHAR2(64):='CUSTOMERPRODUCTID';

BEGIN
    -- set default result
    resultout := wf_engine.eng_completed || ':N';
    IF (funmode = 'RUN') THEN
      l_app_object_value := WF_ENGINE.GetItemAttrText(itemtype,itemkey,l_cct_object_type);
      IF (l_app_object_value IS NOT NULL) THEN
            resultout := wf_engine.eng_completed || ':Y';
      END IF;

    END IF;
END;
/* -----------------------------------------------------------------------
  Activity Name : WF_InventoryItemID_Exists (branch node)

   To Check if the InventoryItem ID Exists.
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
   InventoryItemID      - the product ID
*-----------------------------------------------------------------------*/
procedure WF_InventoryItemID_Exists (
 itemtype  in varchar2
 , itemkey in varchar2
 , actid   in number
 , funmode in varchar2
 , resultout in out nocopy  varchar2) IS
     l_proc_name     VARCHAR2(64) := 'WF_InventoryItemID_Exists';
    l_app_object_value VARCHAR2(255);
    l_party_name VARCHAR2(255);
    l_prod_ID NUMBER;
    l_cct_prod_id_key VARCHAR2(64):='INVENTORYITEMID';
    l_cct_object_type VARCHAR2(64):='INVENTORYITEMID';

BEGIN
    -- set default result
    resultout := wf_engine.eng_completed || ':N';
    IF (funmode = 'RUN') THEN
      l_app_object_value := WF_ENGINE.GetItemAttrText(itemtype,itemkey,l_cct_object_type);
      IF (l_app_object_value IS NOT NULL) THEN
            resultout := wf_engine.eng_completed || ':Y';
      END IF;

    END IF;
END;

END CCT_PRODUCTINIT_PUB;

/
