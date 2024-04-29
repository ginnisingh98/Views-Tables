--------------------------------------------------------
--  DDL for Package OKE_DTS_INTEGRATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_DTS_INTEGRATION_PKG" AUTHID CURRENT_USER AS
/* $Header: OKEINTGS.pls 120.2 2007/12/21 10:56:58 neerakum ship $ */

G_PKG_NAME	CONSTANT VARCHAR2(200) := 'OKE_DTS_INTEGRATION_PKG';
G_WSH_SOURCE_CODE CONSTANT VARCHAR2(30) := 'OKE';

PROCEDURE Set_WF_Attributes
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY     VARCHAR2
);


PROCEDURE Create_Event
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY     VARCHAR2
);


PROCEDURE Launch_Process
( P_ACTION		       IN      VARCHAR2
, P_API_VERSION                IN      NUMBER
, P_COUNTRY_OF_ORIGIN_CODE     IN      VARCHAR2
, P_CURRENCY_CODE              IN      VARCHAR2
, P_DELIVERABLE_ID             IN      NUMBER
, P_DELIVERABLE_NUM            IN      VARCHAR2
, P_INIT_MSG_LIST	       IN      VARCHAR2
, P_INSPECTION_REQED	       IN      VARCHAR2
, P_ITEM_DESCRIPTION           IN      VARCHAR2
, P_ITEM_ID		       IN      NUMBER
, P_ITEM_NUM		       IN      VARCHAR2
, P_K_HEADER_ID  	       IN      NUMBER
, P_K_NUMBER		       IN      VARCHAR2
, P_LINE_NUMBER		       IN      VARCHAR2
, P_MPS_TRANSACTION_ID	       IN      NUMBER
, P_ORGANIZATION	       IN      VARCHAR2
, P_ORGANIZATION_ID	       IN      NUMBER
, P_PROJECT_ID		       IN      NUMBER
, P_PROJECT_NUM                IN      VARCHAR2
, P_QUANTITY    	       IN      NUMBER
, P_SCHEDULE_DATE              IN      DATE
, P_SCHEDULE_DESIGNATOR        IN      VARCHAR2
, P_SHIP_TO_LOCATION           IN      VARCHAR2
, P_TASK_ID      	       IN      NUMBER
, P_TASK_NUM                   IN      VARCHAR2
, P_UNIT_NUMBER                IN      VARCHAR2
, P_UOM_CODE                   IN      VARCHAR2
, P_WORK_DATE		       IN      DATE
, P_REQUESTOR                  IN      VARCHAR2 := NULL
);

FUNCTION Charge_Account ( P_Item_ID NUMBER, P_Org_ID NUMBER) RETURN NUMBER;


PROCEDURE Get_Charge_Account
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY     VARCHAR2
);

PROCEDURE create_mds_entry(
P_DELIVERABLE_ID		IN      NUMBER,
X_OUT_ID			OUT NOCOPY	NUMBER,
X_RETURN_STATUS			OUT NOCOPY	VARCHAR2);

  FUNCTION Get_WSH_Allowed_Cancel_Qty (
    P_DELIVERABLE_ID    IN NUMBER
   ) RETURN NUMBER;

   PROCEDURE Cancel_Shipping(
     P_DELIVERABLE_ID            IN      NUMBER,
     X_CANCELLED_QTY                     OUT NOCOPY        NUMBER,
     X_RETURN_STATUS                     OUT NOCOPY        VARCHAR2
   );

END OKE_DTS_INTEGRATION_PKG;

/
