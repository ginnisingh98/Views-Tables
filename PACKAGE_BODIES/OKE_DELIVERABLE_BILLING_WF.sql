--------------------------------------------------------
--  DDL for Package Body OKE_DELIVERABLE_BILLING_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_DELIVERABLE_BILLING_WF" AS
/* $Header: OKEWDVBB.pls 120.1 2005/06/24 10:36:53 ausmani noship $ */
--
--  Name          : Create_Billing_Event
--  Pre-reqs      : None
--  Function      : This procedure creates a billing event in PA from
--                  Workflow
--
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT           : ResultOut
--
--  Returns       : None
--
PROCEDURE Create_Billing_Event
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT     NOCOPY        VARCHAR2
) IS

L_Deliverable_ID  NUMBER;
L_Return_Status   VARCHAR2(1);
L_Msg_Count       NUMBER;
L_Msg_Data        VARCHAR2(2000);
L_Event_ID        NUMBER;
L_Event_Num       NUMBER;
X_Event_ID        NUMBER;

BEGIN

  IF ( FuncMode = 'RUN' ) THEN

    L_Event_ID := WF_Engine.GetItemAttrNumber
                        ( ItemType => ItemType
                        , ItemKey  => ItemKey
                        , AName    => 'EVENT_ID'
                        );

    OKE_DELIVERABLE_BILLING_PVT.Create_Billing_Event
    ( P_Commit          => FND_API.G_TRUE
    , P_Event_ID  	=> L_Event_ID
    , X_Event_ID        => X_Event_ID
    , X_Event_Num       => L_Event_Num
    , X_Return_Status   => L_Return_Status
    , X_Msg_Count       => L_Msg_Count
    , X_Msg_Data        => L_Msg_Data
    );

    IF ( L_Return_Status <> FND_API.G_RET_STS_SUCCESS ) THEN
      WF_Engine.SetItemAttrText
      ( ItemType => ItemType
      , ItemKey  => ItemKey
      , AName    => 'ERRORTEXT'
      , AValue   => FND_MSG_PUB.Get(1 , p_encoded => FND_API.G_FALSE)
      );

      ResultOut := 'COMPLETE:F';
    ELSE
      ResultOut := 'COMPLETE:T';
    END IF;

    RETURN;

  END IF;

  IF ( FuncMode = 'CANCEL' ) THEN

    ResultOut := '';
    RETURN;

  END IF;

  IF ( FuncMode = 'TIMEOUT' ) THEN

    ResultOut := '';
    RETURN;

  END IF;

EXCEPTION
WHEN OTHERS THEN
  ResultOut := 'ERROR';
  WF_Core.Context( 'OKE_DELIVERABLE_BILLING_WF'
                 , 'CREATE_BILLING_EVENT'
                 , ItemType , ItemKey , to_char(ActID) , FuncMode , ResultOut );
  RAISE;

END Create_Billing_Event;


PROCEDURE Launch_Process
( P_Deliverable_ID             IN      NUMBER
, P_Event_ID		       IN      NUMBER
, P_Deliverable_Num            IN      VARCHAR2
, P_Event_Type                 IN      VARCHAR2
, P_Event_Date                 IN      DATE
, P_Project_Num                IN      VARCHAR2
, P_Task_Num                   IN      VARCHAR2
, P_Organization               IN      VARCHAR2
, P_Description                IN      VARCHAR2
, P_Bill_Currency_Code         IN      VARCHAR2
, P_Unit_Price                 IN      NUMBER
, P_Bill_Quantity              IN      NUMBER
, P_UOM_Code                   IN      VARCHAR2
, P_Bill_Amount                IN      NUMBER
, P_Revenue_Amount             IN      NUMBER
, P_Item_Number                IN      VARCHAR2
, P_Doc_Type                   IN      VARCHAR2
, P_Contract_Num               IN      VARCHAR2
, P_Order_Num                  IN      VARCHAR2
, P_Line_Num                   IN      VARCHAR2
, P_Chg_Request_Num            IN      VARCHAR2
, P_Bill_Of_Lading             IN      VARCHAR2
, P_Serial_Num                 IN      VARCHAR2
, P_Fund_Ref1                  IN      VARCHAR2
, P_Fund_Ref2                  IN      VARCHAR2
, P_Fund_Ref3                  IN      VARCHAR2
) IS

L_WF_Item_Type VARCHAR2(8)   := 'OKEDLVBL';
L_WF_Item_Key  VARCHAR2(240) := NULL;
L_WF_User_Key  VARCHAR2(240) := NULL;
L_Format_Mask  VARCHAR2(80);
l_org_id       NUMBER;

cursor c_org is select authoring_org_id
                from oke_k_headers_v h,oke_k_deliverables_b dts
             where h.k_header_id=dts.k_header_id
             and deliverable_id=p_deliverable_id;
BEGIN

  L_WF_Item_Key := P_Event_ID || ':' ||
                   to_char(sysdate , 'DDMONRRHH24MISS');

  L_Format_Mask := FND_CURRENCY.Get_Format_Mask( P_Bill_Currency_Code , 38 );

  WF_Engine.CreateProcess( ItemType => L_WF_Item_Type
                         , ItemKey  => L_WF_Item_Key
                         , Process  => 'OKE_DELIVERABLE_BILLING'
                         );

  WF_Engine.SetItemOwner( ItemType => L_WF_Item_Type
                        , ItemKey  => L_WF_Item_Key
                        , Owner    => FND_GLOBAL.User_Name
                        );

  WF_Engine.SetItemUserKey( ItemType => L_WF_Item_Type
                          , ItemKey  => L_WF_Item_Key
                          , UserKey  => L_WF_Item_Key
                          );

  open c_org;
  fetch c_org into l_org_id;
  close c_org;

  WF_ENGINE.SetItemAttrNumber( ItemType => L_WF_Item_Type
                             , ItemKey  => L_WF_Item_Key
                             , AName    => 'ORG_ID'
                             , AValue   => l_org_id );

  WF_ENGINE.SetItemAttrNumber( ItemType => L_WF_Item_Type
                             , ItemKey  => L_WF_Item_Key
                             , AName    => 'DELIVERABLE_ID'
                             , AValue   => P_Deliverable_ID );

  WF_ENGINE.SetItemAttrNumber( ItemType => L_WF_Item_Type
                             , ItemKey  => L_WF_Item_Key
                             , AName    => 'EVENT_ID'
                             , AValue   => P_Event_ID );

  WF_ENGINE.SetItemAttrText( ItemType => L_WF_Item_Type
                           , ItemKey  => L_WF_Item_Key
                           , AName    => 'DELIVERABLE_NUM'
                           , AValue   => P_Deliverable_Num );

  WF_ENGINE.SetItemAttrText( ItemType => L_WF_Item_Type
                           , ItemKey  => L_WF_Item_Key
                           , AName    => 'PROJECT_NUM'
                           , AValue   => P_Project_Num );

  WF_ENGINE.SetItemAttrText( ItemType => L_WF_Item_Type
                           , ItemKey  => L_WF_Item_Key
                           , AName    => 'TASK_NUM'
                           , AValue   => P_Task_Num );

  WF_ENGINE.SetItemAttrText( ItemType => L_WF_Item_Type
                           , ItemKey  => L_WF_Item_Key
                           , AName    => 'BILL_ORGANIZATION'
                           , AValue   => P_Organization );

  WF_ENGINE.SetItemAttrText( ItemType => L_WF_Item_Type
                           , ItemKey  => L_WF_Item_Key
                           , AName    => 'BILL_CURRENCY_CODE'
                           , AValue   => P_Bill_Currency_Code );

  WF_ENGINE.SetItemAttrText( ItemType => L_WF_Item_Type
                           , ItemKey  => L_WF_Item_Key
                           , AName    => 'UOM'
                           , AValue   => P_UOM_Code );

  WF_ENGINE.SetItemAttrNumber( ItemType => L_WF_Item_Type
                             , ItemKey  => L_WF_Item_Key
                             , AName    => 'UNIT_PRICE'
                             , AValue   => P_Unit_Price );

  --
  -- The following attribute is currency formatted for notifications only
  --
  WF_ENGINE.SetItemAttrText( ItemType => L_WF_Item_Type
                           , ItemKey  => L_WF_Item_Key
                           , AName    => 'UNIT_PRICE_FMT'
                           , AValue   => to_char( P_Unit_Price , L_Format_Mask ) );

  WF_ENGINE.SetItemAttrNumber( ItemType => L_WF_Item_Type
                             , ItemKey  => L_WF_Item_Key
                             , AName    => 'BILL_AMOUNT'
                             , AValue   => P_Bill_Amount );

  --
  -- The following attribute is currency formatted for notifications only
  --
  WF_ENGINE.SetItemAttrText( ItemType => L_WF_Item_Type
                           , ItemKey  => L_WF_Item_Key
                           , AName    => 'BILL_AMOUNT_FMT'
                           , AValue   => to_char( P_Bill_Amount , L_Format_Mask ) );

  WF_ENGINE.SetItemAttrNumber( ItemType => L_WF_Item_Type
                             , ItemKey  => L_WF_Item_Key
                             , AName    => 'REVENUE_AMOUNT'
                             , AValue   => P_Revenue_Amount );

  --
  -- The following attribute is currency formatted for notifications only
  --
  WF_ENGINE.SetItemAttrText( ItemType => L_WF_Item_Type
                           , ItemKey  => L_WF_Item_Key
                           , AName    => 'REVENUE_AMOUNT_FMT'
                           , AValue   => to_char( P_Revenue_Amount , L_Format_Mask ) );

  WF_ENGINE.SetItemAttrNumber( ItemType => L_WF_Item_Type
                             , ItemKey  => L_WF_Item_Key
                             , AName    => 'BILL_QTY'
                             , AValue   => P_Bill_Quantity );

  WF_ENGINE.SetItemAttrText( ItemType => L_WF_Item_Type
                           , ItemKey  => L_WF_Item_Key
                           , AName    => 'ITEM_NUM'
                           , AValue   => P_Item_Number );

  WF_ENGINE.SetItemAttrText( ItemType => L_WF_Item_Type
                           , ItemKey  => L_WF_Item_Key
                           , AName    => 'DOC_TYPE'
                           , AValue   => P_Doc_Type );

  WF_ENGINE.SetItemAttrText( ItemType => L_WF_Item_Type
                           , ItemKey  => L_WF_Item_Key
                           , AName    => 'DOC_NUM'
                           , AValue   => P_Contract_Num );

  WF_ENGINE.SetItemAttrText( ItemType => L_WF_Item_Type
                           , ItemKey  => L_WF_Item_Key
                           , AName    => 'ORDER_NUM'
                           , AValue   => P_Order_Num );

  --
  -- Doc_Num_Dsp is a concatenation of Contract Number and Order
  -- Number if applicable.
  -- This attribute is for notifications only
  --
  IF ( P_Order_Num IS NULL ) THEN
    WF_ENGINE.SetItemAttrText( ItemType => L_WF_Item_Type
                             , ItemKey  => L_WF_Item_Key
                             , AName    => 'DOC_NUM_DSP'
                             , AValue   => P_Contract_Num );
  ELSE
    WF_ENGINE.SetItemAttrText( ItemType => L_WF_Item_Type
                             , ItemKey  => L_WF_Item_Key
                             , AName    => 'DOC_NUM_DSP'
                             , AValue   => P_Contract_Num || '/' || P_Order_Num );
  END IF;

  WF_ENGINE.SetItemAttrText( ItemType => L_WF_Item_Type
                           , ItemKey  => L_WF_Item_Key
                           , AName    => 'LINE_NUM'
                           , AValue   => P_Line_Num );

  WF_ENGINE.SetItemAttrText( ItemType => L_WF_Item_Type
                           , ItemKey  => L_WF_Item_Key
                           , AName    => 'ITEM_DESCRIPTION'
                           , AValue   => P_Description );

  WF_ENGINE.SetItemAttrText( ItemType => L_WF_Item_Type
                           , ItemKey  => L_WF_Item_Key
                           , AName    => 'FUND_REF1'
                           , AValue   => P_Fund_Ref1 );

  WF_ENGINE.SetItemAttrText( ItemType => L_WF_Item_Type
                           , ItemKey  => L_WF_Item_Key
                           , AName    => 'FUND_REF2'
                           , AValue   => P_Fund_Ref2 );

  WF_ENGINE.SetItemAttrText( ItemType => L_WF_Item_Type
                           , ItemKey  => L_WF_Item_Key
                           , AName    => 'FUND_REF3'
                           , AValue   => P_Fund_Ref3 );

  WF_ENGINE.SetItemAttrDate( ItemType => L_WF_Item_Type
                           , ItemKey  => L_WF_Item_Key
                           , AName    => 'EVENT_DATE'
                           , AValue   => P_Event_Date );

  WF_ENGINE.SetItemAttrText( ItemType => L_WF_Item_Type
                           , ItemKey  => L_WF_Item_Key
                           , AName    => 'REQUESTOR'
                           , AValue   => FND_GLOBAL.User_Name );

  WF_ENGINE.SetItemAttrText( ItemType => L_WF_Item_Type
                           , ItemKey  => L_WF_Item_Key
                           , AName    => 'RECIPIENT'
                           , AValue   => FND_GLOBAL.User_Name );

  --
  -- Start the Workflow Process
  --
  WF_ENGINE.StartProcess( ItemType => L_WF_Item_Type
                        , ItemKey  => L_WF_Item_Key );


END Launch_Process;

END OKE_DELIVERABLE_BILLING_WF;

/
