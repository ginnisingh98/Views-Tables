--------------------------------------------------------
--  DDL for Package CSTPLENG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPLENG" AUTHID CURRENT_USER AS
/* $Header: CSTLENGS.pls 115.11 2004/07/21 00:35:59 rthng ship $ */

TYPE cst_layer_rec_type IS RECORD(inv_layer_id	NUMBER,
				  table_header	VARCHAR2(30),
				  layer_quantity  NUMBER);
TYPE cst_layer_tbl_type IS TABLE OF cst_layer_rec_type;

TYPE LayerCurType IS REF CURSOR;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   compute_layer_actual_cost                                            --
--                                                                        --
-- DESCRIPTION                                                            --
--   This procedure is analogous to the compute_layer_actual_cost( ) in   --
--   average costing. It is called by the cost processor for each         --
--   transaction, so that MCLACD can be populated, and                    --
--   FIFO/LIFO layers consumed or created as necessary                    --
--                                                                        --
-- PURPOSE:                                                               --
--   FIFO/LIFO layer cost processing for Oracle Applications Rel 11i.2    --
--                                                                        --
-- PARAMETERS:                                                            --
--            i_org_id	      : worker organization ID		          --
--            i_layer_id      : layer ID from CQL                         --
--                              (for organization, item, cost group)      --
--            i_cost_method   : FIFO or LIFO cost method                  --
--            i_cost_hook     : presence of actual cost hook              --
--                                                                        --
-- HISTORY:                                                               --
--    04/20/00     Anitha B       Created                                 --
----------------------------------------------------------------------------

FUNCTION compute_layer_actual_cost(
				i_org_id 		IN	NUMBER,
				i_cost_method		IN	NUMBER,
                        	i_txn_id 		IN	NUMBER,
                        	i_layer_id 		IN	NUMBER,
				i_cost_hook		IN	NUMBER,
                        	i_cost_type 		IN	NUMBER,
                        	i_mat_ct_id 		IN	NUMBER,
			  	i_avg_rates_id		IN	NUMBER,
				i_item_id		IN	NUMBER,
				i_txn_qty		IN	NUMBER,
				i_txn_action_id		IN	NUMBER,
				i_txn_src_type		IN	NUMBER,
				i_interorg_rec		IN	NUMBER,
				i_exp_flag		IN	NUMBER,
				i_user_id		IN	NUMBER,
				i_login_id		IN	NUMBER,
				i_req_id		IN	NUMBER,
				i_prg_appl_id		IN	NUMBER,
				i_prg_id		IN	NUMBER,
				o_err_num		OUT NOCOPY	NUMBER,
				o_err_code		OUT NOCOPY	VARCHAR2,
				o_err_msg		OUT NOCOPY	VARCHAR2
)
return integer;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   consume_create_layers                                                --
--                                                                        --
-- DESCRIPTION                                                            --
--   This procedure determines whether to create or consume inventory     --
--   layers depending on the transaction  action and primary quantity     --
--                                                                        --
-- PURPOSE:                                                               --
--   * Differentiate consumption and receipt transactions                 --
--   * For scrap transactions, it merely populates MCACD, since no        --
--     inventory layers are involved                                      --
--   * If expense flag is 1, then pick up current cost from CQL (similar  --
--     to average costing). Only MCACD is populated since no inventory    --
--     layers are involved.                                               --
--                                                                        --
-- PARAMETERS:                                                            --
--            i_org_id	      : organization ID			          --
--            i_layer_id      : layer ID from CQL                         --
--                              (for organization, item, cost group)      --
--            i_txn_action_id : Transaction action ID                     --
--            i_txn_qty       : primary quantity                          --
--            i_exp_flag      : Expense flag for item/subinventory        --
--                                                                        --
-- HISTORY:                                                               --
--    04/20/00     Anitha B       Created                                 --
----------------------------------------------------------------------------

PROCEDURE consume_create_layers(
				i_org_id		IN	NUMBER,
				i_txn_id		IN	NUMBER,
				i_layer_id		IN	NUMBER,
 				i_cost_hook		IN	NUMBER,
				i_item_id		IN	NUMBER,
				i_txn_qty		IN	NUMBER,
				i_cost_method		IN	NUMBER,
				i_txn_src_type		IN	NUMBER,
				i_txn_action_id 	IN	NUMBER,
				i_interorg_rec		IN	NUMBER,
				i_cost_type		IN	NUMBER,
				i_mat_ct_id		IN	NUMBER,
				i_avg_rates_id		IN	NUMBER,
				i_exp_flag		IN	NUMBER,
				i_user_id		IN	NUMBER,
				i_login_id		IN	NUMBER,
				i_req_id		IN	NUMBER,
				i_prg_appl_id		IN	NUMBER,
				i_prg_id		IN	NUMBER,
				o_err_num		OUT NOCOPY	NUMBER,
				o_err_code		OUT NOCOPY	VARCHAR2,
 				o_err_msg		OUT NOCOPY	VARCHAR2
				);

----------------------------------------------------------------------------
-- FUNCTION                                                               --
--   get_source_number	                                                  --
--                                                                        --
-- DESCRIPTION                                                            --
--   This function is used to obtain the transaction source               --
--  for user identification of each transaction that creates an inventory --
--  layer                                                                 --
--    The transaction_source is identified based on the transaction       --
--  source type. It defaults to the transaction_id                        --
--                                                                        --
-- PURPOSE:                                                               --
--   obtain user identifiable transaction source to identify inventory    --
--   layers  								  --
--                                                                        --
-- PARAMETERS:                                                            --
--    i_txn_id   :  transaction id					  --
--    i_src_id   :  transaction source id 				  --
--    i_src_type : transaction source type                                --
--            								  --
--                                                                        --
-- HISTORY:                                                               --
--    04/20/00     Anitha B       Created                                 --
----------------------------------------------------------------------------

FUNCTION get_source_number (i_txn_id	 IN	NUMBER,			    				i_txn_src_type 	 IN	NUMBER,
		       i_src_id	 	IN	NUMBER
			)
return VARCHAR2;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   insert_mclacd                                                        --
--                                                                        --
-- DESCRIPTION                                                            --
--   * Based on the actual_cost_table flag, this procedure picks up costs --
--     from the view cst_layer_actual_costs_v and inserts the cost        --
--     details into MCLACD                                                --
--   * The view is built on top of MCACD,MCTCD and CILCD, with a table    --
--     flag that indicates which portion of the UNION clause needs to be  --
--     execuated during each select against the view.                     --
--                                                                        --
-- PURPOSE:                                                               --
--   A single function used to insert transaction cost details into       --
--    MCLACD. 								  --
--                                                                        --
-- PARAMETERS:                                                            --
--      i_actual_cost_table : table from which actual costs are obtained  --
--      i_layer_cost_table  : table from which layers costs are obtained  --
--      i_cur_layer_id      : the inventory layer inserted into MCLACD    --
--      i_actual_layer_id   : inventory layer whose costs are used        --
--      i_mode              : (CREATE,CONSUME,REPLENISH), determines if   --
--                            outer join is required                      --
--                                                                        --
-- HISTORY:                                                               --
--    04/20/00     Anitha B       Created                                 --
----------------------------------------------------------------------------

PROCEDURE insert_mclacd (
			i_txn_id		IN	NUMBER,
			i_org_id		IN	NUMBER,
			i_item_id		IN	NUMBER,
			i_layer_id		IN	NUMBER,
			i_cur_layer_id		IN	NUMBER,
			i_qty			IN	NUMBER,
			i_txn_action_id		IN	NUMBER,
			i_user_id		IN	NUMBER,
			i_login_id		IN	NUMBER,
			i_req_id		IN	NUMBER,
			i_prg_id		IN	NUMBER,
			i_prg_appl_id		IN	NUMBER,
			i_actual_cost_table 	IN	VARCHAR2,
			i_layer_cost_table	IN	VARCHAR2,
			i_actual_layer_id	IN	NUMBER,
                        i_mode			IN	VARCHAR2,
			o_err_num 		OUT NOCOPY	NUMBER,
			o_err_code		OUT NOCOPY	VARCHAR2,
			o_err_msg		OUT NOCOPY	VARCHAR2
			);

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   create_layers                                                        --
--                                                                        --
-- DESCRIPTION                                                            --
--   * Create inventory layers for i_txn_qty (maybe negative)             --
--       insert into CIL,CILCD,MCLACD using costs from MCACD(cost hook),  --
--       MCTCD(if available), CILCD(latest layer cost,the layer may or    --
--       may not have positive qty), 0 cost if no costs available         --
--                                                                        --
--       update CIL layer cost, burden cost and unburdened cost           --
--   * If layer created has positive quantity, then replenish all         --
--     negative inventory layers                                          --
--                                                                        --
-- PURPOSE:                                                               --
--     create inventory layers using the sequence cst_inv_layers_s        --
--                                                                        --
-- PARAMETERS:                                                            --
--      i_txn_qty      : primary quantity                                 --
--      i_interorg_rec : interorg shimpment (= 0),                        --
--                       interorg receipt (= 1)                           --
--                       subinv transfer with no layer change (= 3)       --
--                       otherwise (= null)                               --
--                                                                        --
-- HISTORY:                                                               --
--    04/20/00     Anitha B       Created                                 --
----------------------------------------------------------------------------

PROCEDURE create_layers(
 			i_org_id		IN	NUMBER,
			i_txn_id		IN	NUMBER,
			i_layer_id		IN	NUMBER,
			i_item_id		IN	NUMBER,
			i_txn_qty		IN	NUMBER,
			i_cost_method		IN	NUMBER,
			i_txn_src_type		IN	NUMBER,
                  	i_txn_action_id   	IN    	NUMBER,
                  	i_cost_hook		IN	NUMBER,
			i_interorg_rec		IN	NUMBER,
			i_cost_type		IN	NUMBER,
			i_mat_ct_id		IN	NUMBER,
			i_avg_rates_id		IN	NUMBER,
			i_exp_flag		IN	NUMBER,
			i_user_id		IN	NUMBER,
			i_login_id		IN	NUMBER,
			i_req_id		IN	NUMBER,
			i_prg_appl_id		IN	NUMBER,
			i_prg_id		IN	NUMBER,
			o_err_num		OUT NOCOPY	NUMBER,
			o_err_code		OUT NOCOPY	VARCHAR2,
			o_err_msg		OUT NOCOPY	VARCHAR2
                  );

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   consume_layers                                                       --
--                                                                        --
-- DESCRIPTION                                                            --
--   * Consume inventory layer, insert into MCLACD using inventory layer  --
--     cost. If cost hook or MCTCD is present, then drive to variance     --
--   * Uses inventory layer table to insert costs and update layer qty    --
--                                                                        --
-- PURPOSE:                                                               --
--   consumption of inventory layers                                      --
--                                                                        --
-- PARAMETERS:                                                            --
--      i_txn_qty      : primary quantity                                 --
--      i_interorg_rec : interorg shimpment (= 0),                        --
--                       interorg receipt (= 1)                           --
--                       subinv transfer with no layer change (= 3)       --
--                       otherwise (= null)                               --
--                                                                        --
-- HISTORY:                                                               --
--    04/20/00     Anitha B       Created                                 --
----------------------------------------------------------------------------

PROCEDURE consume_layers(
 			i_org_id		IN	NUMBER,
			i_txn_id		IN	NUMBER,
			i_layer_id		IN	NUMBER,
			i_item_id		IN	NUMBER,
			i_txn_qty		IN	NUMBER,
			i_cost_method		IN	NUMBER,
			i_txn_src_type		IN	NUMBER,
                  	i_txn_action_id   	IN    	NUMBER,
                  	i_cost_hook		IN	NUMBER,
                        i_interorg_rec		IN	NUMBER,
			i_cost_type		IN	NUMBER,
			i_mat_ct_id		IN	NUMBER,
			i_avg_rates_id		IN	NUMBER,
			i_exp_flag		IN	NUMBER,
			i_user_id		IN	NUMBER,
			i_login_id		IN	NUMBER,
			i_req_id		IN	NUMBER,
			i_prg_appl_id		IN	NUMBER,
			i_prg_id		IN	NUMBER,
			o_err_num		OUT NOCOPY	NUMBER,
			o_err_code		OUT NOCOPY	VARCHAR2,
			o_err_msg		OUT NOCOPY	VARCHAR2
                  );
----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   get_layers_consumed                                                  --
--                                                                        --
-- DESCRIPTION                                                            --
--   This procedure builds the select statement that needs to be executed --
--  for each transaction type, (layer specific, regular FIFO/LIFO,        --
--  driving last layer negative) and returns the PL/SQL consumption table --
--  to the consume_layers function for consumption                        --
--                                                                        --
-- PURPOSE:                                                               --
--  a procedure that can return a PL/SQL table of all inventory layers    --
--  and the quantity that should eb consuemd from that layer, for a given --
--  transaction quantity                                                  --
--                                                                        --
-- PARAMETERS:                                                            --
--       i_txn_qty     :  priamry quantity, that needs to be consumed     --
--       i_cost_method : FIFO/LIFO consumption logic                      --
--       i_layer_id    : cost group layer ID                              --
--       consume_mode  : SPECIFIC(for layer hook, RTV, assembly           --
--                       completion), NORMAL (otherwise)                  --
--       l_inv_layer_table : PL/SQL table, IN OUT variable                --
--       i_layer_hook  : if layer hook is present                         --
--       i_src_id      : for RTV and assembly completion, ignored         --
--                       otherwise                                        --
----------------------------------------------------------------------------
PROCEDURE get_layers_consumed (
  i_txn_qty         IN            NUMBER,
  i_cost_method     IN            NUMBER,
  i_layer_id	    IN  	  NUMBER,
  consume_mode      IN            VARCHAR2,
  i_layer_hook      IN            NUMBER DEFAULT NULL,
  i_src_id          IN            NUMBER DEFAULT NULL,
  i_txn_id          IN            NUMBER DEFAULT NULL,
  l_inv_layer_table IN OUT NOCOPY cst_layer_tbl_type,
  o_err_num         OUT NOCOPY    NUMBER,
  o_err_code        OUT NOCOPY    VARCHAR2,
  o_err_msg         OUT NOCOPY    VARCHAR2
);

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   populate_layer_table                                                 --
--                                                                        --
-- DESCRIPTION                                                            --
--   * This procedure loops through the records fetched by the layer      --
--     cursor (IN parameter), and populates the PL/SQL table with the     --
--     inventory layer ID and the quantity that needs to be consumed      --
--     from that layer                                                    --
--   * If no layers are fetched, the procedure issues a return            --
--                                                                        --
-- PURPOSE:                                                               --
--   a single function to loop through records fetched by the inventory   --
--   layer cursor and populate the PL/SQL table with the inv layer ID     --
--   and the quantity to be consuemd from that layer                      --
--                                                                        --
-- PARAMETERS:                                                            --
--     l_inv_layer_table  :  PL/SQL parameter that is populated           --
--     inv_layer_cursor   : cursor that is used to fetch inventory layers --
--     i_qty_required     : total quantity left to be consumed            --
----------------------------------------------------------------------------
PROCEDURE populate_layer_table(l_inv_layer_table IN OUT NOCOPY cst_layer_tbl_type,
                                         inv_layer_cursor IN LayerCurType,
                                         i_qty_required IN OUT NOCOPY NUMBER,
                                         o_err_num      OUT NOCOPY NUMBER,
                                         o_err_code OUT NOCOPY VARCHAR2,
                                         o_err_msg  OUT NOCOPY VARCHAR2);

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   insert_record                                                        --
--                                                                        --
-- DESCRIPTION                                                            --
--   This procedure extends the PL/SQL table and inserts a new record     --
--                                                                        --
-- PURPOSE:                                                               --
--   This procedure extends the PL/SQL table and inserts a new record     --
--                                                                        --
-- PARAMETERS:                                                            --
--       l_inv_layer_rec   : record to be inserted                        --
--       l_inv_layer_table : PL/SQL table into which record is inserted   --
----------------------------------------------------------------------------
PROCEDURE insert_record(l_inv_layer_rec IN cst_layer_rec_type,
                                l_inv_layer_table IN OUT NOCOPY cst_layer_tbl_type,
                                o_err_num       OUT NOCOPY      NUMBER,
                                o_err_code  OUT NOCOPY  VARCHAR2,
                                o_err_msg   OUT NOCOPY  VARCHAR2);

----------------------------------------------------------------------------
-- PROCEDURE apply_layer_material_ovh
-- created by Dieu-Thuong Le  21-Apr-2000

-- This procedure will compute material overheads based on the rates
-- defined in the rate cost type specified for the current costing org.
-- The computed movh will be applied to this level material overhead of
-- the specified inventory layer.
-- This procedure will insert MACS rows for each applicable material
-- overhead and insert or update MCLACD.
--     Inserting MCLACD: populate both layer_cost and actual_cost with the
--                       total costs of all MACS rows created for tranx.
--     Updating MCLACD:  add MACS costs to actual_cost, layer_cost will
--                       not be touched.
-- Assumption:  when this procedure is called, MCLACD material row should
-- already be inserted for the transaction.
-----------------------------------------------------------------------------

procedure apply_layer_material_ovhd(
  I_ORG_ID        IN      NUMBER,
  I_TXN_ID        IN      NUMBER,
  I_LAYER_ID      IN      NUMBER,
  I_INV_LAYER_ID  IN      NUMBER,
  I_LAYER_QTY     IN      NUMBER,
  I_COST_TYPE     IN      NUMBER,
  I_MAT_CT_ID     IN      NUMBER,
  I_AVG_RATES_ID  IN      NUMBER,
  I_ITEM_ID       IN      NUMBER,
  I_TXN_QTY       IN      NUMBER,
  I_TXN_ACTION_ID IN      NUMBER,
  I_LEVEL         IN      NUMBER,
  I_USER_ID       IN      NUMBER,
  I_LOGIN_ID      IN      NUMBER,
  I_REQ_ID        IN      NUMBER,
  I_PRG_APPL_ID   IN      NUMBER,
  I_PRG_ID        IN      NUMBER,
  I_INTERORG_REC  IN      NUMBER, --bug 2280515
  O_Err_Num       OUT NOCOPY     NUMBER,
  O_Err_Code      OUT NOCOPY     VARCHAR2,
  O_Err_Msg       OUT NOCOPY     VARCHAR2
);

/*********************************************************************************
** PROCEDURE                                                                    **
**     calc_layer_average_cost                                                  **
**                                                                              **
** DESCRIPTION                                                                  **
** It main function is to perform the following for the specified transaction:  **
**      . insert into MCACD with MCLACD's summarized costs                      **
**      . update CLCD with CILCD's summarized costs                             **
**      . update CQL's costs from CLCD                                          **
**      . update CICD's costs from CLCD                                         **
**      . update CIC's costs from CICD                                          **
** This procedure assumes that all MCLACD rows have already been inserted by    **
** calling program.                                                             **
** Set I_NO_UPDATE_MMT = 1 if the calling program does not want mmt to be       **
**                       update; otherwise, set it to 0                         **
** Set I_NO_UPDATE_QTY = 1 if clcd, cql, cic and cicd should not be updated;    **
**                       otherwise, set it to 0                                 **
**                                                                              **
** HISTORY                                                                      **
**   4/24/00     Dieu-Thuong Le              Creation                           **
**                                                                              **
*********************************************************************************/

procedure calc_layer_average_cost(
  I_ORG_ID	   IN	NUMBER,
  I_TXN_ID	   IN 	NUMBER,
  I_LAYER_ID	   IN	NUMBER,
  I_COST_TYPE	   IN	NUMBER,
  I_ITEM_ID	   IN	NUMBER,
  I_TXN_QTY	   IN	NUMBER,
  I_TXN_ACTION_ID  IN	NUMBER,
  I_COST_HOOK      IN   NUMBER,
  I_NO_UPDATE_MMT  IN	NUMBER,
  I_NO_UPDATE_QTY  IN   NUMBER,
  I_USER_ID	   IN	NUMBER,
  I_LOGIN_ID	   IN 	NUMBER,
  I_REQ_ID	   IN	NUMBER,
  I_PRG_APPL_ID    IN	NUMBER,
  I_PRG_ID	   IN	NUMBER,
  O_Err_Num	   OUT NOCOPY	NUMBER,
  O_Err_Code	   OUT NOCOPY	VARCHAR2,
  O_Err_Msg	   OUT NOCOPY	VARCHAR2
);

/************************************************************************
**  PROCEDURE                                                          **
**     layer_cost_update                                               **
**                                                                     **
**  DESCRIPTION                                                        **
**     This function is called to update inventory layer cost.         **
**     It will determine the new elemental costs of the layer based    **
**     on user-enter values and compute the adjustment amounts to      **
**     inventory valuation.                                            **
**     MTL_CST_LAYER_ACT_COST_DETAILS will be populated and the other  **
**     cost tables (CILCD, CIL, CLCD, CQL, CICD, CIC) will be updated  **
**     accordingly with the new cost information.                      **
**     This function is duplicated from CSTPAVCP.average_cost_update.  **
**                                                                     **
**  HISTORY                                                            **
**     12-MAY-2000        Dieu-Thuong Le          Creation             **
**                                                                     **
************************************************************************/
PROCEDURE layer_cost_update(
  I_ORG_ID      IN      NUMBER,
  I_TXN_ID      IN      NUMBER,
  I_LAYER_ID    IN      NUMBER,
  I_COST_TYPE   IN      NUMBER,
  I_ITEM_ID     IN      NUMBER,
  I_TXN_QTY     IN      NUMBER,
  I_TXN_ACT_ID  IN      NUMBER,
  I_USER_ID     IN      NUMBER,
  I_LOGIN_ID    IN      NUMBER,
  I_REQ_ID      IN      NUMBER,
  I_PRG_APPL_ID IN      NUMBER,
  I_PRG_ID      IN      NUMBER,
  O_Err_Num     OUT NOCOPY     NUMBER,
  O_Err_Code    OUT NOCOPY     VARCHAR2,
  O_Err_Msg     OUT NOCOPY     VARCHAR2
);

----------------------------------------------------------------------------
-- FUNCTION
--  get_current_layer
--  This function is called to return the inv layer id whose cost needs to be
--  used if a issue is done. It is called from WIP to create layers when there
--  are no layers at all in WIP. In that case WIP needs to know which layer cost--  has to be used.
--
-- INPUT PARAMETERS
--  I_ORG_ID
--  I_TXN_ID
--  I_LAYER_ID
--  I_ITEM_ID
--  I_TXN_ACT_ID
--
-- RETURN VALUES
--  integer             1       Successful
--                      0       Error
-----------------------------------------------------------------------------
function get_current_layer(
  I_ORG_ID      IN      NUMBER,
  I_TXN_ID      IN      NUMBER,
  I_LAYER_ID    IN      NUMBER,
  I_ITEM_ID     IN      NUMBER,
  I_USER_ID     IN      NUMBER,
  I_LOGIN_ID    IN      NUMBER,
  I_REQ_ID      IN      NUMBER,
  I_PRG_APPL_ID IN      NUMBER,
  I_PRG_ID      IN      NUMBER,
  I_TXN_SRC_TYPE_ID IN  NUMBER,
  I_TXN_SRC_ID  IN      NUMBER,
  O_Err_Num     OUT NOCOPY     NUMBER,
  O_Err_Code    OUT NOCOPY     VARCHAR2,
  O_Err_Msg     OUT NOCOPY     VARCHAR2
)
return integer;

----------------------------------------------------------------------------
--  layer_cost_det_move
--      This procedure inserts into MCTCD for Layer Cost Update through
--   open interface
----------------------------------------------------------------------------
procedure layer_cost_det_move (
  i_txn_id                  in number,
  i_txn_interface_id        in number,
  i_txn_action_id           in number,
  i_org_id                  in number,
  i_item_id                 in number,
  i_cost_group_id           in number,
  i_inv_layer_id            in number,
  i_txn_cost                in number,
  i_new_avg_cost            in number,
  i_per_change              in number,
  i_val_change              in number,
  i_mat_accnt               in number,
  i_mat_ovhd_accnt          in number,
  i_res_accnt               in number,
  i_osp_accnt               in number,
  i_ovhd_accnt              in number,
  i_user_id                 in number,
  i_login_id                in number,
  i_request_id              in number,
  i_prog_appl_id            in number,
  i_prog_id                 in number,
  o_err_num                 out NOCOPY number,
  o_err_code                out NOCOPY varchar2,
  o_err_msg                 out NOCOPY varchar2
);

--------------------------------------------------------------------------
--  PROCEDURE layer_cost_det_new_insert
--     procedure used by layer cost update through open interface
--------------------------------------------------------------------------
procedure layer_cost_det_new_insert (
  i_txn_id                  in number,
  i_txn_action_id           in number,
  i_org_id                  in number,
  i_item_id                 in number,
  i_cost_group_id           in number,
  i_inv_layer_id            in number,
  i_txn_cost                in number,
  i_new_avg_cost            in number,
  i_per_change              in number,
  i_val_change              in number,
  i_mat_accnt               in number,
  i_mat_ovhd_accnt          in number,
  i_res_accnt               in number,
  i_osp_accnt               in number,
  i_ovhd_accnt              in number,
  i_user_id                 in number,
  i_login_id                in number,
  i_request_id              in number,
  i_prog_appl_id            in number,
  i_prog_id                 in number,
  o_err_num                 out NOCOPY number,
  o_err_code                out NOCOPY varchar2,
  o_err_msg                 out NOCOPY varchar2
);

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   layer_cost_update_dist                                               --
--                                                                        --
-- DESCRIPTION                                                            --
--   This procedure is called by CSTPLCIN package for layer cost update   --
--  transaction, since distributions need o be done using layer cost      --
--  from MCLACD rather than MCLACD                                        --
--                                                                        --
-- PURPOSE:                                                               --
--   Post distributions into MTA for layer cost update transactions       --
--                                                                        --
-- PARAMETERS:                                                            --
--   all transaction related details                                      --
----------------------------------------------------------------------------
procedure layer_cost_update_dist(
  I_ORG_ID              IN      NUMBER,
  I_TXN_ID              IN      NUMBER,
  I_LAYER_ID            IN      NUMBER,
  I_EXP_ITEM            IN      NUMBER,
  I_USER_ID             IN      NUMBER,
  I_LOGIN_ID            IN      NUMBER,
  I_REQ_ID              IN      NUMBER,
  I_PRG_APPL_ID         IN      NUMBER,
  I_PRG_ID              IN      NUMBER,
  O_Error_Num           OUT NOCOPY     NUMBER,
  O_Error_Code          OUT NOCOPY     VARCHAR2,
  O_Error_Message       OUT NOCOPY     VARCHAR2
);

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   update_inv_layer_cost                                                --
--                                                                        --
-- DESCRIPTION                                                            --
--   This procedure is called by the Define Items form (INVIDITM), to     --
-- set costs as zero, when an item is changed from asset to expense       --
--                                                                        --
-- PURPOSE:                                                               --
--   FIFO/LIFO layer cost processing for Oracle Applications Rel 11i.2    --
--                                                                        --
-- PARAMETERS:                                                            --
--            i_org_id          : organization ID                         --
--            i_item_id         : inventory_item_id for the item whose    --
--                                expense flag is changed                 --
--                                                                        --
-- HISTORY:                                                               --
--    04/20/00     Anitha B       Created                                 --
----------------------------------------------------------------------------

PROCEDURE update_inv_layer_cost (i_org_id IN NUMBER,
                                i_item_id IN NUMBER,
                                i_userid IN NUMBER,
                                i_login_id IN NUMBER);

END CSTPLENG;

 

/
