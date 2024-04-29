--------------------------------------------------------
--  DDL for Package CSTPLVCP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPLVCP" AUTHID CURRENT_USER AS
/* $Header: CSTLVCPS.pls 120.1 2005/06/14 15:51:57 appldev  $ */

--  PROCEDURE
--  cost_processor	Costs inventory transactions for FIFO/LIFO
--
PROCEDURE cost_processor (
  I_ORG_ID		IN NUMBER,
  I_TXN_ID		IN NUMBER,
  I_LAYER_ID	IN NUMBER,
  I_COST_TYPE	IN NUMBER,
  I_COST_METHOD  	IN NUMBER,
  I_MAT_CT_ID	IN NUMBER,
  I_AVG_RATES_ID	IN NUMBER,
  I_ITEM_ID		IN NUMBER,
  I_TXN_QTY		IN NUMBER,
  I_TXN_ACTION_ID IN NUMBER,
  I_TXN_SRC_TYPE 	IN NUMBER,
  I_TXN_ORG_ID	IN NUMBER,
  I_TXFR_ORG_ID 	IN NUMBER,
  I_COST_GRP_ID 	IN NUMBER,
  I_TXFR_COST_GRP IN NUMBER,
  I_TXFR_LAYER_ID IN NUMBER,
  I_FOB_POINT	IN NUMBER,
  I_EXP_ITEM	IN NUMBER,
  I_EXP_FLAG	IN NUMBER,
  I_CITW_FLAG	IN NUMBER,
  I_FLOW_SCHEDULE	IN NUMBER,
  I_USER_ID		IN NUMBER,
  I_LOGIN_ID    	IN NUMBER,
  I_REQ_ID		IN NUMBER,
  I_PRG_APPL_ID	IN NUMBER,
  I_PRG_ID		IN NUMBER,
  I_TPRICE_OPTION IN      NUMBER,
  I_TXF_PRICE     IN      NUMBER,
  O_Err_Num		OUT NOCOPY NUMBER,
  O_Err_Code	OUT NOCOPY VARCHAR2,
  O_Err_Msg		OUT NOCOPY VARCHAR2
);

-- PROCEDURE
--  common_issue_to_wip
--  Cost process the common issue to wip transaction.

procedure common_issue_to_wip(
  I_ORG_ID		IN NUMBER,
  I_TXN_ID		IN NUMBER,
  I_LAYER_ID		IN NUMBER,
  I_COST_TYPE		IN NUMBER,
  I_ITEM_ID		IN NUMBER,
  I_TXN_QTY		IN NUMBER,
  I_TXN_ACTION_ID 	IN NUMBER,
  I_TXN_SRC_TYPE	IN NUMBER,
  I_NEW_COST	IN NUMBER,
  I_COST_HOOK		IN NUMBER,
  I_TXFR_LAYER_ID 	IN NUMBER,
  I_COST_METHOD         IN NUMBER,
  I_AVG_RATES_ID        IN NUMBER,
  I_MAT_CT_ID		IN NUMBER,
  I_COST_GRP_ID         IN NUMBER,
  I_TXFR_COST_GRP       IN NUMBER,
  I_EXP_FLAG            IN NUMBER,
  I_EXP_ITEM            IN NUMBER,
  I_CITW_FLAG           IN NUMBER,
  I_FLOW_SCHEDULE       IN NUMBER,
  I_USER_ID		IN NUMBER,
  I_LOGIN_ID    	IN NUMBER,
  I_REQ_ID		IN NUMBER,
  I_PRG_APPL_ID		IN NUMBER,
  I_PRG_ID		IN NUMBER,
  O_Err_Num		OUT NOCOPY NUMBER,
  O_Err_Code		OUT NOCOPY VARCHAR2,
  O_Err_Msg		OUT NOCOPY VARCHAR2
);

-- PROCEDURE
--  Interorg
--  This procedure will compute the transfer cost of an intransit
--  interorg transaction.  It will also compute the transaction cost
--  of this transfer.
procedure interorg(
  I_ORG_ID	IN	NUMBER,
  I_TXN_ID	IN 	NUMBER,
  I_COST_METHOD IN      NUMBER,
  I_LAYER_ID	IN	NUMBER,
  I_COST_TYPE	IN	NUMBER,
  I_ITEM_ID	IN	NUMBER,
  I_TXN_ACTION_ID IN	NUMBER,
  I_TXN_SRC_TYPE IN	NUMBER,
  I_TXN_ORG_ID 	IN	NUMBER,
  I_TXFR_ORG_ID  IN	NUMBER,
  I_COST_GRP_ID IN	NUMBER,
  I_TXFR_COST_GRP IN	NUMBER,
  I_FOB_POINT	IN	NUMBER,
  I_MAT_CT_ID	IN	NUMBER,
  I_AVG_RATES_ID  IN    NUMBER,
  I_USER_ID	IN	NUMBER,
  I_LOGIN_ID	IN	NUMBER,
  I_REQ_ID	IN	NUMBER,
  I_PRG_APPL_ID IN	NUMBER,
  I_PRG_ID 	IN	NUMBER,
  I_TPRICE_OPTION  IN   NUMBER,
  I_TXF_PRICE      IN   NUMBER,
  O_TXN_QTY	IN OUT NOCOPY	NUMBER,
  O_INTERORG_REC IN OUT NOCOPY	NUMBER,
  O_NO_UPDATE_MMT IN OUT NOCOPY	NUMBER,
  O_EXP_FLAG	IN OUT NOCOPY	NUMBER,
  O_Err_Num	OUT NOCOPY	NUMBER,
  O_Err_Code	OUT NOCOPY	VARCHAR2,
  O_Err_Msg	OUT NOCOPY	VARCHAR2
);

PROCEDURE get_snd_rcv_rate(
  I_TXN_ID	IN	NUMBER,
  I_FROM_ORG	IN	NUMBER,
  I_TO_ORG	IN	NUMBER,
  O_SND_SOB_ID	OUT NOCOPY	NUMBER,
  O_SND_CURR	OUT NOCOPY	VARCHAR2,
  O_RCV_SOB_ID	OUT NOCOPY	NUMBER,
  O_RCV_CURR	OUT NOCOPY	VARCHAR2,
  O_CURR_TYPE	OUT NOCOPY	VARCHAR2,
  O_CONV_RATE	OUT NOCOPY	NUMBER,
  O_CONV_DATE	OUT NOCOPY	DATE,
  O_Err_Num	OUT NOCOPY	NUMBER,
  O_Err_Code	OUT NOCOPY	VARCHAR2,
  O_Err_Msg	OUT NOCOPY	VARCHAR2
);

PROCEDURE get_snd_rcv_uom(
  I_ITEM_ID	IN	NUMBER,
  I_FROM_ORG	IN	NUMBER,
  I_TO_ORG	IN	NUMBER,
  O_SND_UOM	OUT NOCOPY	VARCHAR2,
  O_RCV_UOM	OUT NOCOPY	VARCHAR2,
  O_Err_Num	OUT NOCOPY	NUMBER,
  O_Err_Code	OUT NOCOPY	VARCHAR2,
  O_Err_Msg	OUT NOCOPY	VARCHAR2
);

FUNCTION standard_cost_org(
  I_ORG_ID      IN      NUMBER
) RETURN INTEGER;

PROCEDURE interorg_elemental_detail(
  i_org_id		IN	NUMBER,
  i_txn_id		IN	NUMBER,
  i_compute_txn_cost	IN NUMBER,
  i_cost_type_id	IN NUMBER,
  i_from_layer_id	IN NUMBER,
  i_item_id		IN NUMBER,
  i_exp_flag		IN NUMBER,
  i_txn_update_id	IN NUMBER,
  i_from_org		IN NUMBER,
  i_to_org		IN NUMBER,
  i_snd_qty		IN NUMBER,
  i_txfr_cost		IN NUMBER,
  i_trans_cost		IN NUMBER,
  i_conv_rate		IN NUMBER,
  i_um_rate		IN NUMBER,
  i_user_id		IN NUMBER,
  i_login_id		IN NUMBER,
  i_req_id		IN NUMBER,
  i_prg_appl_id		IN NUMBER,
  i_prg_id		IN NUMBER,
  o_err_num		OUT NOCOPY NUMBER,
  o_err_code		OUT NOCOPY VARCHAR2,
  o_err_msg		OUT NOCOPY VARCHAR2);

/*========================================================================
-- PROCEDURE
--    borrow_cost
--
-- DESCRIPTION
-- This procedure is duplicated from CSTPAVCP.borrow_cost procedure and
-- and revised for FIFO/LIFO costing
-- This  procedure will identify the cost of all borrow transactions
-- related to the specified payback transactions, compute the average cost
-- and store it in MCTCD.
-- If layer actual cost hook is used, it will error out
-- since user-entered actual cost is not allowed for payback transaction.

-- HISTORY
--    04/26/00     Dieu-Thuong Le          Creation

=========================================================================*/

PROCEDURE borrow_cost(
I_ORG_ID        IN      NUMBER,
I_TXN_ID        IN      NUMBER,
I_USER_ID       IN      NUMBER,
I_LOGIN_ID      IN      NUMBER,
I_REQ_ID        IN      NUMBER,
I_PRG_APPL_ID   IN      NUMBER,
I_PRG_ID        IN      NUMBER,
I_ITEM_ID       IN      NUMBER,
I_HOOK  IN      NUMBER,
I_TO_LAYER      IN      NUMBER,
O_Err_Num       OUT NOCOPY     NUMBER,
O_Err_Code      OUT NOCOPY     VARCHAR2,
O_Err_Msg       OUT NOCOPY     VARCHAR2
);

/*=========================================================================
-- PROCEDURE
--  sub_transfer
--
-- DESCRIPTION
-- This procedure costs the subinventory transfer for both the transfer
-- subinventory and the destination subinventory.
--
-- HISTORY
--   4/26/00     Dieu-Thuong Le          Creation

==========================================================================*/

procedure sub_transfer(
I_ORG_ID                IN NUMBER,
I_TXN_ID                IN NUMBER,
I_LAYER_ID              IN NUMBER,
I_COST_TYPE             IN NUMBER,
I_ITEM_ID               IN NUMBER,
I_TXN_QTY               IN NUMBER,
I_TXN_ACTION_ID         IN NUMBER,
I_TXN_SRC_TYPE		IN NUMBER,
I_NEW_COST              IN NUMBER,
I_HOOK                  IN NUMBER,
I_COST_METHOD		IN NUMBER,
I_TXFR_LAYER_ID         IN NUMBER,
I_CITW_FLAG             IN NUMBER,
I_FLOW_SCHEDULE         IN NUMBER,
I_MAT_CT_ID		IN NUMBER,
I_AVG_RATES_ID		IN NUMBER,
I_USER_ID               IN NUMBER,
I_LOGIN_ID              IN NUMBER,
I_REQ_ID                IN NUMBER,
I_PRG_APPL_ID           IN NUMBER,
I_PRG_ID                IN NUMBER,
O_Err_Num               OUT NOCOPY NUMBER,
O_Err_Code              OUT NOCOPY VARCHAR2,
O_Err_Msg               OUT NOCOPY VARCHAR2
);

/*========================================================================
-- PROCEDURE
--    payback_variance
--
-- DESCRIPTION
-- This procedure will be called for all Payback transactions across the
-- same cost group.
-- This  procedure will identify the cost of all borrow transactions
-- related to the specified payback transactions, compute the average cost
-- calculate the variance and update payback_variance_amount column of MCLACD.
--
-- If layer actual cost hook is used, it will error out
-- since user-entered actual cost is not allowed for payback transaction.

-- HISTORY
--    09/15/03     Anju Gupta          Design

=========================================================================*/

PROCEDURE payback_variance(
I_ORG_ID	IN	NUMBER,
I_TXN_ID	IN	NUMBER,
I_TXN_QTY   IN  NUMBER,
I_USER_ID	IN	NUMBER,
I_LOGIN_ID	IN	NUMBER,
I_REQ_ID	IN	NUMBER,
I_PRG_APPL_ID	IN	NUMBER,
I_PRG_ID	IN	NUMBER,
I_ITEM_ID	IN	NUMBER,
I_HOOK	IN	NUMBER,
I_FROM_LAYER	IN	NUMBER,
O_Err_Num	OUT NOCOPY	NUMBER,
O_Err_Code	OUT NOCOPY	VARCHAR2,
O_Err_Msg	OUT NOCOPY	VARCHAR2
);
/*========================================================================
-- PROCEDURE
--    Cost_Logical_itr_receipt
--
-- DESCRIPTION
--   This procedure is called from process discrete transfer for ALL
--   types of transfers (dir and intransit)

-- HISTORY
--    04/08/05     umoogala   Created
--      For OPM INVCONV Process-Discrete Transfers Enhancement.
=========================================================================*/

PROCEDURE Cost_Logical_itr_receipt(
  I_ORG_ID      IN      NUMBER,
  I_TXN_ID      IN      NUMBER,
  I_COST_METHOD IN      NUMBER,
  I_LAYER_ID    IN      NUMBER,
  I_COST_TYPE   IN      NUMBER,
  I_ITEM_ID     IN      NUMBER,
  I_TXN_ACTION_ID IN    NUMBER,
  I_TXN_SRC_TYPE IN     NUMBER,
  I_TXN_ORG_ID  IN      NUMBER,
  I_TXFR_ORG_ID  IN     NUMBER,
  I_COST_GRP_ID IN      NUMBER,
  I_TXFR_COST_GRP IN    NUMBER,
  I_FOB_POINT   IN      NUMBER,
  I_MAT_CT_ID   IN      NUMBER,
  I_AVG_RATES_ID  IN    NUMBER,
  I_USER_ID     IN      NUMBER,
  I_LOGIN_ID    IN      NUMBER,
  I_REQ_ID      IN      NUMBER,
  I_PRG_APPL_ID IN      NUMBER,
  I_PRG_ID      IN      NUMBER,
  I_TPRICE_OPTION  IN   NUMBER,
  I_TXF_PRICE      IN   NUMBER,
  O_TXN_QTY     IN OUT NOCOPY   NUMBER,
  O_INTERORG_REC IN OUT NOCOPY  NUMBER,
  O_NO_UPDATE_MMT IN OUT NOCOPY NUMBER,
  O_EXP_FLAG    IN OUT NOCOPY   NUMBER,
  O_Err_Num     OUT NOCOPY      NUMBER,
  O_Err_Code    OUT NOCOPY      VARCHAR2,
  O_Err_Msg     OUT NOCOPY      VARCHAR2
);

END CSTPLVCP;

 

/
