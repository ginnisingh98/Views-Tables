--------------------------------------------------------
--  DDL for Package AR_BUS_EVENT_SUB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_BUS_EVENT_SUB_PVT" AUTHID CURRENT_USER AS
/* $Header: ARBESUBS.pls 120.5.12010000.2 2010/04/16 13:16:51 mraymond ship $*/

/* 5690748 */
TYPE generic_id_type IS TABLE OF number
 INDEX BY BINARY_INTEGER;

TYPE  currency_type IS TABLE OF ra_customer_trx_all.invoice_currency_code%type
 INDEX BY BINARY_INTEGER;

FUNCTION Inv_Complete
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION Inv_InComplete
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION Inv_Modify
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION Inv_DepositApply
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION CM_Complete
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION CM_InComplete
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION CM_Modify
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION DM_Complete
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION DM_InComplete
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION DM_Modify
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION Dep_Complete
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION Dep_InComplete
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION Dep_Modify
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION CB_Create
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION CB_Modify
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION Guar_Complete
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION Guar_InComplete
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION Guar_Modify
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION CashReceipt_Create
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION CashReceipt_Reverse
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION CashReceipt_Modify
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION CashReceipt_Approve
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION CashReceipt_Confirm
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION CashReceipt_Unconfirm
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION CashReceipt_DMReversal
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION CashReceipt_Delete
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION CreditMemoApp_Apply
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;


FUNCTION CreditMemoApp_UnApply
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION CashApp_Apply
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION CashApp_UnApply
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION AdjCreate
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION AdjApprove
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION AutoInv_Run
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION AutoRcpt_Run
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION AutoAdj_Run
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION QuickCash_PostBatch
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION Aging_PastDue
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION Recurr_Invoice
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

FUNCTION CopyInv_Run
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

-- The following has been added for RAMC
-- Please refer to Bug # 3085672 for details.

FUNCTION events_manager (
  p_subscription_guid IN RAW,
  p_event IN OUT NOCOPY WF_EVENT_T)
  RETURN VARCHAR2;

/* 5690748 */
PROCEDURE refresh_counts(
   p_customer_id_tab IN ar_bus_event_sub_pvt.generic_id_type,
   p_site_use_id_tab IN ar_bus_event_sub_pvt.generic_id_type,
   p_currency_tab    IN ar_bus_event_sub_pvt.currency_type,
   p_org_id_tab      IN ar_bus_event_sub_pvt.generic_id_type);

/* 9363502 */
PROCEDURE refresh_at_risk_value(
   p_customer_id_tab IN ar_bus_event_sub_pvt.generic_id_type,
   p_site_use_id_tab IN ar_bus_event_sub_pvt.generic_id_type,
   p_currency_tab    IN ar_bus_event_sub_pvt.currency_type,
   p_org_id_tab      IN ar_bus_event_sub_pvt.generic_id_type);

END AR_BUS_EVENT_SUB_PVT; -- Package spec

/
