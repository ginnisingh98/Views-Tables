--------------------------------------------------------
--  DDL for Package CCT_PRODUCTINIT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_PRODUCTINIT_PUB" AUTHID CURRENT_USER as
/* $Header: cctprods.pls 120.0 2005/06/02 09:08:30 appldev noship $ */

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
 , resultout in out nocopy  varchar2) ;

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
    ServiceReqNum    - the originating Service Request Number
    CPID      - the customer product ID
*-----------------------------------------------------------------------*/
procedure WF_ProductFromServiceReqNum (
 itemtype  in varchar2
 , itemkey in varchar2
 , actid   in number
 , funmode in varchar2
 , resultout in out nocopy  varchar2) ;

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
 , resultout in out nocopy  varchar2) ;

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
 , resultout in out nocopy  varchar2) ;

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
 , resultout in out nocopy  varchar2) ;

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
 , resultout in out nocopy  varchar2) ;

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
 , resultout in out nocopy  varchar2) ;

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
 , resultout in out nocopy  varchar2) ;

END CCT_PRODUCTINIT_PUB;

 

/
