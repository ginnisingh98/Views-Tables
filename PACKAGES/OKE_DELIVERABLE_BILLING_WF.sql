--------------------------------------------------------
--  DDL for Package OKE_DELIVERABLE_BILLING_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_DELIVERABLE_BILLING_WF" AUTHID CURRENT_USER AS
/* $Header: OKEWDVBS.pls 115.6 2002/11/21 20:27:15 tweichen ship $ */

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
);

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
, ResultOut           OUT     NOCOPY  VARCHAR2
);

END OKE_DELIVERABLE_BILLING_WF;

 

/
