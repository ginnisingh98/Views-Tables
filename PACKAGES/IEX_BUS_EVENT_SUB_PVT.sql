--------------------------------------------------------
--  DDL for Package IEX_BUS_EVENT_SUB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_BUS_EVENT_SUB_PVT" AUTHID CURRENT_USER AS
/* $Header: iexbsubs.pls 120.0.12000000.1 2007/05/02 07:07:21 appldev noship $*/

--Function For Transactions Events. Passes trx_id
FUNCTION SYNC_SUMMARY
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;
--Function For Receipts Events. Passes Payment_schedule_id
FUNCTION SYNC_CASHRECEIPT
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

--Function For Credit Memo and Cash Apply. Both these events pass receivables_application_id
FUNCTION SYNC_CM
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

--Function For Adjustment Events. Passes adjustment_id
FUNCTION SYNC_ADJ
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

--Function For Auto Adjustment. Passes request_id
FUNCTION SYNC_AUTOADJ
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

--Function For AutoReceipts. Passes request_id
FUNCTION SYNC_AUTOREC
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

--Function For AutoInvoice. Passes request_id.

FUNCTION SYNC_AUTOINV
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

--Main Function that will Synchronize IEX and AR.
FUNCTION UPDATE_SUMMARY
(id_val   IN NUMBER
,l_org_id IN NUMBER
,trx_type IN VARCHAR2
)
RETURN VARCHAR2;

END IEX_BUS_EVENT_SUB_PVT; -- Package spec

 

/
