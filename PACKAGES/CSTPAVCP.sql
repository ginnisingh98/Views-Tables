--------------------------------------------------------
--  DDL for Package CSTPAVCP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPAVCP" AUTHID CURRENT_USER AS
/* $Header: CSTAVCPS.pls 120.5.12010000.4 2008/12/01 01:41:46 ipineda ship $ */

-- PROCEDURE
--  cost_processor	Costs inventory transactions
--
procedure cost_processor(
I_ORG_ID	IN	NUMBER,
I_TXN_ID	IN 	NUMBER,
I_LAYER_ID	IN	NUMBER,
I_COST_TYPE	IN	NUMBER,		-- The valuation cost type
I_COST_METHOD   IN	NUMBER,
I_MAT_CT_ID	IN	NUMBER,		-- The material overhead cost type
I_AVG_RATES_ID	IN	NUMBER,		-- The average rates cost type
I_ITEM_ID	IN	NUMBER,
I_TXN_QTY	IN 	NUMBER,
I_TXN_ACTION_ID	IN	NUMBER,
I_TXN_SRC_TYPE	IN	NUMBER,
I_TXN_ORG_ID	IN	NUMBER,
I_TXFR_ORG_ID	IN	NUMBER,
I_COST_GRP_ID	IN	NUMBER,
I_TXFR_COST_GRP IN	NUMBER,
I_TXFR_LAYER_ID IN	NUMBER,
I_FOB_POINT	IN	NUMBER,
I_EXP_ITEM	IN	NUMBER,
I_EXP_FLAG	IN	NUMBER,		-- Either expense item or sub
I_CITW_FLAG	IN	NUMBER,
I_FLOW_SCHEDULE	IN	NUMBER,		-- 1 for cfm and 0 for non-cfm
I_USER_ID	IN	NUMBER,
I_LOGIN_ID    	IN	NUMBER,
I_REQ_ID	IN	NUMBER,
I_PRG_APPL_ID	IN	NUMBER,
I_PRG_ID	IN 	NUMBER,
I_TPRICE_OPTION IN      NUMBER,
I_TXF_PRICE     IN      NUMBER,
O_Err_Num	OUT NOCOPY	NUMBER,
O_Err_Code	OUT NOCOPY	VARCHAR2,
O_Err_Msg	OUT NOCOPY	VARCHAR2
);

-- PROCEDURE
--  average_cost_update		Cost process the averge cost update
--				transaction.
procedure average_cost_update(
  I_ORG_ID	IN	NUMBER,
  I_TXN_ID	IN	NUMBER,
  I_LAYER_ID	IN	NUMBER,
  I_COST_TYPE	IN	NUMBER,
  I_ITEM_ID	IN	NUMBER,
  I_TXN_ACTION_ID IN	NUMBER,
  I_TXN_QTY     IN      NUMBER,
  I_EXP_FLG	IN	NUMBER,
  I_USER_ID	IN	NUMBER,
  I_LOGIN_ID    IN	NUMBER,
  I_REQ_ID	IN	NUMBER,
  I_PRG_APPL_ID	IN	NUMBER,
  I_PRG_ID	IN 	NUMBER,
  O_Err_Num	OUT NOCOPY	NUMBER,
  O_Err_Code	OUT NOCOPY	VARCHAR2,
  O_Err_Msg	OUT NOCOPY	VARCHAR2
);

-- PROCEDURE
--  sub_transfer		Cost process the subinventory transfer
--				transaction.

procedure sub_transfer(
  I_ORG_ID	IN	NUMBER,
  I_TXN_ID	IN	NUMBER,
  I_LAYER_ID	IN	NUMBER,
  I_COST_TYPE	IN	NUMBER,
  I_ITEM_ID	IN	NUMBER,
  I_TXN_QTY	IN	NUMBER,
  I_TXN_ACTION_ID IN	NUMBER,
  I_NEW_COST	IN	NUMBER,
  I_HOOK 	IN	NUMBER,
  I_TXFR_LAYER_ID IN	NUMBER,
  I_CITW_FLAG	IN	NUMBER,
  I_FLOW_SCHEDULE IN	NUMBER,
  I_USER_ID	IN	NUMBER,
  I_LOGIN_ID    IN	NUMBER,
  I_REQ_ID	IN	NUMBER,
  I_PRG_APPL_ID	IN	NUMBER,
  I_PRG_ID	IN 	NUMBER,
  O_Err_Num	OUT NOCOPY	NUMBER,
  O_Err_Code	OUT NOCOPY	VARCHAR2,
  O_Err_Msg	OUT NOCOPY	VARCHAR2
);


-- PROCEDURE
--  common_issue_to_wip		Cost process the common issue to wip
--				transaction.

procedure common_issue_to_wip(
  I_ORG_ID		IN NUMBER,
  I_TXN_ID		IN NUMBER,
  I_LAYER_ID		IN NUMBER,
  I_COST_TYPE		IN NUMBER,
  I_ITEM_ID		IN NUMBER,
  I_TXN_QTY		IN NUMBER,
  I_TXN_ACTION_ID 	IN NUMBER,
  I_NEW_COST		IN NUMBER,
  I_TXFR_LAYER_ID 	IN NUMBER,
  I_COST_METHOD         IN NUMBER,
  I_AVG_RATES_ID        IN NUMBER,
  I_COST_GRP_ID         IN NUMBER,
  I_TXFR_COST_GRP       IN NUMBER,
  I_EXP_FLAG            IN NUMBER,
  I_EXP_ITEM            IN NUMBER,
  I_CITW_FLAG           IN NUMBER,
  I_FLOW_SCHEDULE	IN NUMBER,
  I_USER_ID		IN NUMBER,
  I_LOGIN_ID    	IN NUMBER,
  I_REQ_ID		IN NUMBER,
  I_PRG_APPL_ID		IN NUMBER,
  I_PRG_ID		IN NUMBER,
  O_Err_Num		OUT NOCOPY NUMBER,
  O_Err_Code		OUT NOCOPY VARCHAR2,
  O_Err_Msg		OUT NOCOPY VARCHAR2
);


-- FUNCTION
--  compute_actual_cost		Populate the actual cost details table
--
--
-- RETURN VALUES
--  integer		1	The actual cost is different from the
--				current average cost.
--			0	The actual cost is the same as the current
--				average cost.

function  compute_actual_cost(
I_ORG_ID	IN	NUMBER,
I_TXN_ID	IN 	NUMBER,
I_LAYER_ID	IN	NUMBER,
I_COST_TYPE	IN	NUMBER,
I_MAT_CT_ID	IN	NUMBER,
I_AVG_RATES_ID	IN	NUMBER,
I_ITEM_ID	IN	NUMBER,
I_TXN_QTY	IN	NUMBER,
I_TXN_ACTION_ID	IN	NUMBER,
I_TXN_SRC_TYPE	IN	NUMBER,
I_INTERORG_REC	IN	NUMBER,
I_EXP_FLAG	IN	NUMBER,
I_USER_ID	IN	NUMBER,
I_LOGIN_ID    	IN	NUMBER,
I_REQ_ID	IN	NUMBER,
I_PRG_APPL_ID	IN	NUMBER,
I_PRG_ID	IN 	NUMBER,
O_Err_Num	OUT NOCOPY	NUMBER,
O_Err_Code	OUT NOCOPY	VARCHAR2,
O_Err_Msg	OUT NOCOPY	VARCHAR2
)
return integer;


-- PROCEDURE
--  apply_material_ovhd		Applying this level material overhead based
-- 				on the pre-defined rates in the average
--				rates cost type.
--

procedure apply_material_ovhd(
I_ORG_ID	IN	NUMBER,
I_TXN_ID	IN 	NUMBER,
I_LAYER_ID	IN	NUMBER,
I_COST_TYPE	IN	NUMBER,
I_MAT_CT_ID	IN	NUMBER,
I_AVG_RATES_ID	IN	NUMBER,
I_ITEM_ID	IN	NUMBER,
I_TXN_QTY	IN	NUMBER,
I_TXN_ACTION_ID	IN	NUMBER,
I_LEVEL		IN	NUMBER,
I_USER_ID	IN	NUMBER,
I_LOGIN_ID	IN	NUMBER,
I_REQ_ID	IN	NUMBER,
I_PRG_APPL_ID	IN	NUMBER,
I_PRG_ID	IN	NUMBER,
O_Err_Num	OUT NOCOPY	NUMBER,
O_Err_Code	OUT NOCOPY	VARCHAR2,
O_Err_Msg	OUT NOCOPY	VARCHAR2
);

-- PROCEDURE
--  calc_average_cost		Compute new average cost.
--

procedure calc_average_cost(
I_ORG_ID	IN	NUMBER,
I_TXN_ID	IN 	NUMBER,
I_LAYER_ID	IN	NUMBER,
I_COST_TYPE	IN	NUMBER,
I_ITEM_ID	IN	NUMBER,
I_TXN_QTY	IN	NUMBER,
I_TXN_ACTION_ID	IN	NUMBER,
I_NO_UPDATE_MMT IN	NUMBER,
I_USER_ID	IN	NUMBER,
I_LOGIN_ID	IN	NUMBER,
I_REQ_ID	IN	NUMBER,
I_PRG_APPL_ID	IN	NUMBER,
I_PRG_ID	IN	NUMBER,
O_Err_Num	OUT NOCOPY	NUMBER,
O_Err_Code	OUT NOCOPY	VARCHAR2,
O_Err_Msg	OUT NOCOPY	VARCHAR2
);

-- PROCEDURE
--  current_average_cost	Using current average cost for the transaction.
--

procedure current_average_cost(
I_ORG_ID	IN	NUMBER,
I_TXN_ID	IN 	NUMBER,
I_LAYER_ID	IN	NUMBER,
I_COST_TYPE	IN	NUMBER,
I_ITEM_ID	IN	NUMBER,
I_TXN_QTY	IN	NUMBER,
I_TXN_ACTION_ID	IN	NUMBER,
I_EXP_FLAG	IN	NUMBER,
I_NO_UPDATE_MMT	IN	NUMBER,
I_NO_UPDATE_QTY IN	NUMBER,
I_USER_ID	IN	NUMBER,
I_LOGIN_ID	IN	NUMBER,
I_REQ_ID	IN	NUMBER,
I_PRG_APPL_ID	IN	NUMBER,
I_PRG_ID	IN	NUMBER,
O_Err_Num	OUT NOCOPY	NUMBER,
O_Err_Code	OUT NOCOPY	VARCHAR2,
O_Err_Msg	OUT NOCOPY	VARCHAR2
);

-- PROCEDURE
-- Update_MMT	Updating denormalized data in mtl_material_transactions
--

procedure update_mmt(
I_ORG_ID	IN	NUMBER,
I_TXN_ID	IN 	NUMBER,
I_TXFR_TXN_ID	IN	NUMBER,
I_LAYER_ID	IN	NUMBER,
I_COST_UPDATE	IN	NUMBER,
I_USER_ID	IN	NUMBER,
I_LOGIN_ID	IN	NUMBER,
I_REQ_ID	IN	NUMBER,
I_PRG_APPL_ID	IN	NUMBER,
I_PRG_ID	IN	NUMBER,
O_Err_Num	OUT NOCOPY	NUMBER,
O_Err_Code	OUT NOCOPY	VARCHAR2,
O_Err_Msg	OUT NOCOPY	VARCHAR2
);

-- PROCEDURE
--  update_item_cost
PROCEDURE update_item_cost(
  I_ORG_ID	IN	NUMBER,
  I_TXN_ID	IN	NUMBER,
  I_LAYER_ID	IN	NUMBER,
  I_COST_TYPE	IN	NUMBER,
  I_ITEM_ID	IN	NUMBER,
  I_MANDATORY_UPDATE IN	NUMBER,
  I_USER_ID	IN	NUMBER,
  I_LOGIN_ID	IN	NUMBER,
  I_REQ_ID	IN	NUMBER,
  I_PRG_APPL_ID	IN	NUMBER,
  I_PRG_ID	IN	NUMBER,
  O_Err_Num	OUT NOCOPY	NUMBER,
  O_Err_Code	OUT NOCOPY	VARCHAR2,
  O_Err_Msg	OUT NOCOPY	VARCHAR2
);

-- PROCEDURE
--  Interorg
--  This procedure will compute the transfer cost of an intransit
--  interorg transaction.  It will also compute the transaction cost
--  of this transfer.

procedure interorg(
  I_ORG_ID	IN	NUMBER,
  I_TXN_ID	IN 	NUMBER,
  I_LAYER_ID	IN	NUMBER,
  I_COST_TYPE	IN	NUMBER,
  I_ITEM_ID	IN	NUMBER,
  I_TXN_ACTION_ID IN	NUMBER,
  I_TXN_ORG_ID 	IN	NUMBER,
  I_TXFR_ORG_ID  IN	NUMBER,
  I_COST_GRP_ID IN	NUMBER,
  I_TXFR_COST_GRP IN	NUMBER,
  I_FOB_POINT	IN	NUMBER,
  I_USER_ID	IN	NUMBER,
  I_LOGIN_ID	IN	NUMBER,
  I_REQ_ID	IN	NUMBER,
  I_PRG_APPL_ID	IN	NUMBER,
  I_PRG_ID	IN	NUMBER,
  I_TPRICE_OPTION  IN   NUMBER,
  I_TXF_PRICE      IN   NUMBER,
  I_EXP_ITEM	   IN 	NUMBER,
  O_TXN_QTY	IN OUT NOCOPY	NUMBER,
  O_INTERORG_REC IN OUT NOCOPY	NUMBER,
  O_NO_UPDATE_MMT IN OUT NOCOPY	NUMBER,
  O_EXP_FLAG	IN OUT NOCOPY	NUMBER,
  O_HOOK_USED	OUT NOCOPY	NUMBER,
  O_Err_Num	OUT NOCOPY	NUMBER,
  O_Err_Code	OUT NOCOPY	VARCHAR2,
  O_Err_Msg	OUT NOCOPY	VARCHAR2
);

-- PROCEDURE
-- get_snd_rcv_rate
-- This procedure will return the conversion rate between the sending
-- org's currency and receiving org's currency.
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

-- PROCEDURE
-- get_snd_rcv_uom
-- This procedure will return the sending org and receiving org's unit
-- of measure.
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

-- FUNCTION
-- standard_cost_org
-- This function will return 1 if the organization uses stardard cost method.
FUNCTION standard_cost_org(
  I_ORG_ID	IN	NUMBER
) RETURN integer;

-- PROCEDURE
--  borrow_cost 		Find out the borrowing cost for borrow payback txn

procedure borrow_cost(
  I_ORG_ID	IN	NUMBER,
  I_TXN_ID	IN 	NUMBER,
  I_USER_ID	IN	NUMBER,
  I_LOGIN_ID	IN	NUMBER,
  I_REQ_ID	IN	NUMBER,
  I_PRG_APPL_ID	IN	NUMBER,
  I_PRG_ID	IN	NUMBER,
  I_ITEM_ID	IN	NUMBER,
  I_HOOK	IN	NUMBER,
  I_TO_LAYER	IN	NUMBER,
  O_Err_Num	OUT NOCOPY	NUMBER,
  O_Err_Code	OUT NOCOPY	VARCHAR2,
  O_Err_Msg	OUT NOCOPY	VARCHAR2
);

-- PROCEDURE
--  store_bp_variance 		Find out the difference between the current cost
--                              and the borrow cost and store it in variance.

procedure store_bp_variance(
 I_TXN_ID	IN 	NUMBER,
 I_FROM_LAYER_ID	IN	NUMBER,
 I_TO_LAYER_ID	IN	NUMBER,
 O_Err_Num	OUT NOCOPY	NUMBER,
 O_Err_Code	OUT NOCOPY	VARCHAR2,
 O_Err_Msg	OUT NOCOPY	VARCHAR2
);

PROCEDURE interorg_elemental_detail(
  i_txn_id		IN NUMBER,
  i_compute_txn_cost    IN NUMBER,
  i_cost_type_id        IN NUMBER,
  i_from_layer_id       IN NUMBER,
  i_item_id             IN NUMBER,
  i_txn_update_id       IN NUMBER,
  i_from_org            IN NUMBER,
  i_to_org              IN NUMBER,
  i_snd_qty             IN NUMBER,
  i_txfr_cost           IN NUMBER,
  i_trans_cost          IN NUMBER,
  i_conv_rate           IN NUMBER,
  i_um_rate             IN NUMBER,
  i_user_id             IN NUMBER,
  i_login_id            IN NUMBER,
  i_req_id              IN NUMBER,
  i_prg_appl_id         IN NUMBER,
  i_prg_id              IN NUMBER,
  i_hook_used		IN NUMBER := 0,
  o_err_num             OUT NOCOPY NUMBER,
  o_err_code            OUT NOCOPY VARCHAR2,
  o_err_msg             OUT NOCOPY VARCHAR2);


--------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   Cost_Acct_Events                                                     --
--                                                                        --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API costs logical events that are created as part of Global     --
--   Procurement or Drop Shipment Transactions. These events are known by --
--   non-null parent_id.                                                  --
--   The consigned price update transcation, introduced as part of        --
--   Retroactive Pricing Project is also cost processed using this API.   --
--   This transaction does not have a parent_id.                          --
--                                                                        --
--   This API is common between all cost methods to process Accounting    --
--   Events and the Retroactive Price Update transaction.                 --

--   It is called from inltcp.lpc for Std. Costing and from actual and    --
--   layer cost workers for Average Costing and FIDO/LIFO orgs            --
--   respectively.                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.10                                       --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    06/22/03     Anju G       Created                                   --
----------------------------------------------------------------------------

PROCEDURE cost_acct_events (
                  p_api_version      IN  NuMBER,
                  /*p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,*/
                  p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                  p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
                  p_debug            IN  VARCHAR2,

                  p_org_id           IN  NUMBER,
                  p_txn_id           IN  NUMBER,
                  p_parent_id        IN  NUMBER,

                  p_user_id          IN  NUMBER,
                  p_request_id       IN  NUMBER,
                  p_prog_id          IN  NUMBER,
                  p_prog_app_id      IN  NUMBER,
                  p_login_id         IN  NUMBER,

                  x_err_num          OUT NOCOPY VARCHAR2,
                  x_err_code         OUT NOCOPY VARCHAR2,
                  x_err_msg          OUT NOCOPY VARCHAR2);

--------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   Compute_MCACD_Costs                                                  --
--                                                                        --
--                                                                        --
-- DESCRIPTION                                                            --
--   This procedure determines the costs of logical transactions in       --
--   physical organizations.                                              --
--   The costs are determined as follows:                                 --
--   Standard Costing org: Standard cost of item                          --
--   Average Costing org: actual cost of item                             --
--   FIFO/FIFO org: From MCLACD of parent transaction                     --
--                                                                        --
--   This procedure should be called only for logical transactions in the --
--   physical event owing organization - essentially orgs where physical  --
--   SO Issue or RMAs are done.                                           --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.10                                       --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    06/22/03     Anju G       Created                                   --
--    07/07/07  vjavli  FP 11i-12.0 Bug 6328273 fix: add p_cost_org_id to --
--                      facilitate logic for shared standard costing org  --
----------------------------------------------------------------------------


PROCEDURE Compute_MCACD_Costs(
                     p_api_version      IN  NUMBER,
                     p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                     p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                     p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,

                     p_org_id           IN  NUMBER,
                     p_txn_id           IN  NUMBER,
                     p_parent_txn_id    IN  NUMBER,
                     p_cost_method      IN  NUMBER,
                     p_cost_org_id      IN  NUMBER,
                     p_cost_type_id     IN  NUMBER,
                     p_item_id          IN  NUMBER,
                     p_txn_action_id    IN  NUMBER,
                     p_exp_item         IN  NUMBER,
                     p_exp_flag         IN  NUMBER,
                     p_cost_group_id    IN  NUMBER,
                     p_rates_cost_type  IN  NUMBER,
                     p_txn_qty          IN  NUMBER,
                     p_txn_src_type     IN  NUMBER,

                     p_user_id          IN  NUMBER,
                     p_request_id       IN  NUMBER,
                     p_prog_id          IN  NUMBER,
                     p_prog_app_id      IN  NUMBER,
                     p_login_id         IN  NUMBER,


                     x_layer_id         IN OUT NOCOPY NUMBER,
                     x_err_num          OUT NOCOPY VARCHAR2,
                     x_err_code         OUT NOCOPY VARCHAR2,
                     x_err_msg          OUT NOCOPY VARCHAR2);

/* Bug 2665290 */
/*========================================================================
-- PROCEDURE
--    payback_variance
--
-- DESCRIPTION
-- This procedure will be called for all Payback transactions across the
-- same cost group.
-- This  procedure will identify the cost of all borrow transactions
-- related to the specified payback transactions, compute the average cost
-- calculate the variance and update payback_variance_amount column of MCACD.
--

-- HISTORY
--    08/20/03     Anju Gupta          Creation

=========================================================================*/

PROCEDURE payback_variance(
  I_ORG_ID      IN      NUMBER,
  I_TXN_ID      IN      NUMBER,
  I_FROM_LAYER  IN      NUMBER,
  I_USER_ID     IN      NUMBER,
  I_LOGIN_ID    IN      NUMBER,
  I_REQ_ID      IN      NUMBER,
  I_PRG_APPL_ID IN      NUMBER,
  I_PRG_ID      IN      NUMBER,
  O_Err_Num     OUT NOCOPY      NUMBER,
  O_Err_Code    OUT NOCOPY      VARCHAR2,
  O_Err_Msg     OUT NOCOPY      VARCHAR2);


PROCEDURE Cost_LogicalSOReceipt (
            p_parent_txn_id  IN NUMBER,
            p_user_id        IN NUMBER,
            p_request_id     IN NUMBER,
            p_prog_id        IN NUMBER,
            p_prog_app_id    IN NUMBER,
            p_login_id       IN NUMBER,

            x_err_num        OUT NOCOPY NUMBER,
            x_err_code       OUT NOCOPY VARCHAR2,
            x_err_msg        OUT NOCOPY VARCHAR2
            );

--
-- OPM INVCONV  Process-Discrete Enh.
-- Added following procedure to cost new logical Intransit Receipt (15)
--
PROCEDURE Cost_Logical_itr_receipt(
  I_ORG_ID      IN      NUMBER,
  I_TXN_ID      IN      NUMBER,
  I_LAYER_ID    IN      NUMBER,
  I_COST_TYPE   IN      NUMBER,
  I_ITEM_ID     IN      NUMBER,
  I_TXN_ACTION_ID IN    NUMBER,
  I_TXN_ORG_ID  IN      NUMBER,
  I_TXFR_ORG_ID  IN     NUMBER,
  I_COST_GRP_ID IN      NUMBER,
  I_TXFR_COST_GRP IN    NUMBER,
  I_FOB_POINT   IN      NUMBER,
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

/*--------------------------------------------------------------------------
 * Procedure: CompEncumbrance_IntOrdersExp
 *
 * Description:
 *           The procedure computes the encumbrance amount for a Logical
 *           Expense Requisition Receipt transaction
 *           It also returns the budget account ( x_encumbrance_account )
 * Parameters:
 *           p_req_line_id     : Requisition Line Identifier of the Originating
 *           Requisition
 *           p_organization_id : Organization (MMT.ORGANIZATION_ID)
 *           p_item_id         : Inventory Item (MMT.INVENTORY_ITEM_ID)
 *           p_primary_qty     : Primary Quantity of the Receipt Txn
 *                               (MMT.PRIMARY_QUANTITY)
 *           p_total_primary_qty: Total Quantity received (and costed) for
 *                                the order so far.
 * ------------------------------------------------------------------------*/
PROCEDURE CompEncumbrance_IntOrdersExp (
            p_api_version         IN NUMBER,
	    p_transaction_id      IN MTL_MATERIAL_TRANSACTIONS.TRANSACTION_ID%TYPE,
            p_req_line_id         IN PO_REQUISITION_LINES_ALL.REQUISITION_LINE_ID%TYPE,
            p_item_id             IN MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE,
            p_organization_id     IN MTL_PARAMETERS.ORGANIZATION_ID%TYPE,
            p_primary_qty         IN MTL_MATERIAL_TRANSACTIONS.PRIMARY_QUANTITY%TYPE,
            p_total_primary_qty   IN NUMBER,
            x_encumbrance_amount  OUT NOCOPY NUMBER,
            x_encumbrance_account OUT NOCOPY NUMBER,
            x_return_status       OUT NOCOPY VARCHAR,
            x_return_message      OUT NOCOPY VARCHAR2
            );
/*--------------------------------------------------------------------------
 * Procedure: CompEncumbrance_IntOrdersExp
 *
 * Description:
 *           The procedure computes the encumbrance amount for an Internal
 *           Order related material transaction
 *           It also returns the budget account ( x_encumbrance_account )
 * Parameters:
 *           p_transaction_id   : Transaction Identifier (from MMT)
 *
 * ------------------------------------------------------------------------*/
PROCEDURE CompEncumbrance_IntOrdersExp (
            p_api_version     IN NUMBER,
            p_transaction_id  IN MTL_MATERIAL_TRANSACTIONS.TRANSACTION_ID%TYPE,

            x_encumbrance_amount  OUT NOCOPY NUMBER,
            x_encumbrance_account OUT NOCOPY NUMBER,
            x_return_status       OUT NOCOPY VARCHAR,
            x_return_message      OUT NOCOPY VARCHAR2
            );
/*===========================================================================
|  Procedure:   validate_actual_cost_hook                                    |
|  Author:      Ivan Pineda                                                  |
|  Date:        November 29, 2008                                            |
|  Description: This procedure will be called  after  the  actual_cost_hook  |
|               client extension has been called to validate the data .  We  |
|               will raise two different errors. If the hook is called  and  |
|               there is no data in MCACD for that transaction then we will  |
|               raise exception no_mcacd_for_hook. If the data inserted  in  |
|               MCACD has the insertion flag as 'Y' and there  are  details  |
|               in CLCD we will raise exception insertion_flag_in_mcacd      |
|                                                                            |
|  Parameters:  i_txn_id: Transaction id                                     |
|               i_org_id: Organization id                                    |
|               i_layer_id: Layer id                                         |
|                                                                            |
|                                                                            |
|===========================================================================*/
PROCEDURE validate_actual_cost_hook(
	i_txn_id IN NUMBER,
	i_org_id IN NUMBER,
	i_layer_id IN NUMBER,
        i_req_id IN NUMBER,
        i_prg_appl_id IN NUMBER,
        i_prg_id IN NUMBER,
	o_err_num OUT NOCOPY NUMBER,
	o_err_code OUT NOCOPY VARCHAR2,
	o_err_msg OUT NOCOPY VARCHAR2
	);

END CSTPAVCP;

/
