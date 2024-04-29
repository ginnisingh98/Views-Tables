--------------------------------------------------------
--  DDL for Package Body CSTPLVCP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPLVCP" AS
/* $Header: CSTLVCPB.pls 120.15 2007/11/30 21:37:41 ipineda ship $ */

-- PROCEDURE
--  cost_processor	Costs inventory transactions for FIFO/LIFO
--

G_PKG_NAME    CONSTANT VARCHAR2(30) := 'CSTPLVCP';
G_DEBUG       CONSTANT VARCHAR2(1)     := NVL(FND_PROFILE.VALUE('MRP_DEBUG'),'N');

l_pd_txfr_ind NUMBER := 0; -- OPM INVCONV sschinch

procedure cost_processor(
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
  I_TPRICE_OPTION       IN NUMBER,
  I_TXF_PRICE           IN NUMBER,
  O_Err_Num		OUT NOCOPY NUMBER,
  O_Err_Code	OUT NOCOPY VARCHAR2,
  O_Err_Msg		OUT NOCOPY VARCHAR2
) IS
  l_txn_qty		NUMBER;
  l_cost_hook		NUMBER;
  l_new_cost	NUMBER;
  l_exp_flag	NUMBER;
  l_interorg_rec	NUMBER;
  l_no_update_mmt	NUMBER;
  l_layer_chg	NUMBER;
  l_txn_action_id	NUMBER;
  l_layer_id	NUMBER;
  l_org_id		NUMBER;
  l_err_num		NUMBER;
  l_err_code	VARCHAR2(240);
  l_err_msg		VARCHAR2(240);
  process_error	EXCEPTION;
  l_stmt_num	NUMBER;
  l_so_line_id  NUMBER;

  /* Borrow Payback */
  l_txn_type_id	NUMBER;

  -- Added for bug 3679625
  l_to_std_exp 		NUMBER;
  l_std_org			NUMBER;
  l_to_method		NUMBER;

  -- l_pd_txfr_ind NUMBER := 0; -- OPM INVCONV sschinch


BEGIN
  -- initialize local variables
  l_err_num := 0;
  l_txn_qty := i_txn_qty;	/* mmt.primary quantity */
  l_org_id := i_org_id;
  l_no_update_mmt := 0;
  l_interorg_rec := 0;
  l_exp_flag := i_exp_flag;	/* Expense item or expense subinventory*/
  l_cost_hook := 0;
  l_new_cost := 0;
  l_txn_action_id := 0;

  -- Added for bug 3679625
  l_to_std_exp := 0;

  -- The l_exp_flag determines if this is an expense item or the transaction
  -- involves an expense subinventory.

  /* OPM INVCONV sschinch Check if this transaction is a process discrete transfer */
  SELECT MOD(SUM(DECODE(mp.process_enabled_flag, 'Y', 1, 2)), 2)
    INTO l_pd_txfr_ind
    FROM mtl_parameters mp, mtl_material_transactions mmt
   WHERE mmt.transaction_id   = i_txn_id
     AND (mmt.organization_id = mp.organization_id
          OR mmt.transfer_organization_id = mp.organization_id);

  if ((l_pd_txfr_ind = 1) AND (i_txn_action_id in (3, 15, 12, 21, 22))) then

    --
    -- OPM INVCONV umoogala/sschinch Process-Discrete Transfers Enh.:
    -- Processing for
    --  1. Logical  Intransit Receipt
    --       This is a new transaction type introduced for p-d xfers enh. only.
    --  2. Physical Intransit Receipt and
    --  3. Direct Xfer receipt.
    --
    CSTPLVCP.cost_logical_itr_receipt(
          i_org_id,
          i_txn_id,
          i_cost_method,
          i_layer_id,
          i_cost_type,
          i_item_id,
          i_txn_action_id,
          i_txn_src_type,
          i_txn_org_id,
          i_txfr_org_id,
          i_cost_grp_id,
          i_txfr_cost_grp,
          i_fob_point,
          i_mat_ct_id,
          i_avg_rates_id,
          i_user_id,
          i_login_id,
          i_req_id,
          i_prg_appl_id,
          i_prg_id,
          i_tprice_option,
          i_txf_price,
          l_txn_qty,
          l_interorg_rec,
          l_no_update_mmt,
          l_exp_flag,
          l_err_num,
          l_err_code,
          l_err_msg);

    IF g_debug = 'Y' THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'cost_logical_itr_receipt(): interorg_rec: ' || to_char(l_interorg_rec));
    END IF;

    if (l_err_num <> 0) then
      raise process_error;
    end if;

  /* If this is an interorg transfer transaction, call interorg procedure
     to figure out transfer cost and transaction cost.
     INTERORG  TRANSFER TXN
  */

  elsif (i_txn_action_id in (3,12,21)) then
        /* Called for all orgs. If sending org, then populate MCTCD
           for receiving org populate MCACD for std org, if applicable,
           else no processing  */

    l_stmt_num := 10;

    CSTPLVCP.interorg ( i_org_id,
   	      	        i_txn_id,
			i_cost_method,
			i_layer_id,
			i_cost_type,
			i_item_id,
			i_txn_action_id,
                        i_txn_src_type,
 			i_txn_org_id,
			i_txfr_org_id,
			i_cost_grp_id,
			i_txfr_cost_grp,
			i_fob_point,
			i_mat_ct_id,
			i_avg_rates_id,
			i_user_id,
			i_login_id,
			i_req_id,
			i_prg_appl_id,
			i_prg_id,
                        i_tprice_option,
                        i_txf_price,
			l_txn_qty,
			l_interorg_rec,
			l_no_update_mmt,
			l_exp_flag,
			l_err_num,
			l_err_code,
			l_err_msg);
    IF g_debug = 'Y' THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'interorg(): interorg_rec: ' || to_char(l_interorg_rec));
    END IF;
    if (l_err_num <> 0) then
      raise process_error;
    end if;
    /* Some transactions do not need to be cost processed and only need cost
       distribution!
       1) The intransit shipment from standard to average with fob receipt
       2) The intransit receipt to standard from average with fob shipment
       3) The direct interorg shipment from standard to average/FIFO/LIFO
       4) The direct interorg receipt from average/FIFO/LIFO to standard. */

    l_stmt_num := 20;

    if ((i_txn_action_id = 21 and i_fob_point = 2 and i_txfr_org_id = i_org_id)
        OR
        (i_txn_action_id = 12 and i_fob_point = 1 and i_txfr_org_id = i_org_id)
        OR
        (i_txn_action_id = 3 and i_txfr_org_id = i_org_id and i_txn_qty < 0)
        OR
        (i_txn_action_id = 3 and i_txfr_org_id = i_org_id and i_txn_qty > 0)) then
      return;
    end if;
    /*  END INTERORG TRANSFER TXN  */

  elsif (i_citw_flag = 1) then
    /* Common Issue to WIP is processed separately. There is no cost hook
       available for this transaction. Check for layer hook at the time of consume_layers()

       Treat it as a subinventory transfer */
    l_txn_action_id := 2;

    /* Call WIP processor for the component issue */
    l_stmt_num := 30;

    CSTPLVCP.common_issue_to_wip(
				i_org_id,
				i_txn_id,
				i_layer_id,
				i_cost_type,
				i_item_id,
				l_txn_qty,
				i_txn_action_id,
				i_txn_src_type,
				l_new_cost,
				0,
				i_txfr_layer_id,
				i_cost_method,
				i_avg_rates_id,
				i_mat_ct_id,
				i_cost_grp_id,
				i_txfr_cost_grp,
				l_exp_flag,
				i_exp_item,
				i_citw_flag,
				i_flow_schedule,
				i_user_id,
				i_login_id,
				i_req_id,
				i_prg_appl_id,
				i_prg_id,
				l_err_num,
				l_err_code,
				l_err_msg);
    if (l_err_num <> 0) then
      raise process_error;
    end if;

    return;

  elsif (i_txn_action_id = 24) then /*Removed condition i_txn_src_type = 15 for Bug 6030287*/
    /* Layer Cost Update is processed separately.  There is no hook
       available for this transaction. In contrast with average cost
       update this function inserts distributions into MTA, and not
       through the distribution processor
    */

    l_stmt_num := 40;

    CSTPLENG.layer_cost_update(
				i_org_id,
				i_txn_id,
				i_layer_id,
				i_cost_type,
				i_item_id,
                                i_txn_qty,
				i_txn_action_id,
				i_user_id,
				i_login_id,
				i_req_id,
				i_prg_appl_id,
				i_prg_id,
				l_err_num,
				l_err_code,
				l_err_msg);
    if (l_err_num <> 0) then
      raise process_error;
    end if;

    /* no more processing */
    return;

  elsif (i_exp_item = 0) then
    /* Call the Actual Cost Hook for asset items */

    l_stmt_num := 50;

    l_cost_hook := CSTPACHK.actual_cost_hook (  i_org_id,
						i_txn_id,
						i_layer_id,
						i_cost_type,
						i_cost_method,
						i_user_id,
						i_login_id,
						i_req_id,
						i_prg_appl_id,
						i_prg_id,
						l_err_num,
						l_err_code,
						l_err_msg);
    if (l_err_num <> 0) then
      raise process_error;
    end if;
  end if;

  if (l_cost_hook = 0) then
    /*       BORROW  PAYBACK   */
    /*  If hook is not used and it is a payback transaction,
        we need to populate MCTCD with the borrowed cost.  */

    /* Changes for VMI. Adding planning transfer transaction */

    if i_txn_action_id IN (2,5,28,55) then
      l_stmt_num := 60;

      select transaction_type_id
      into l_txn_type_id
      from mtl_material_transactions
      where transaction_id = i_txn_id;

      if (l_txn_type_id = 68) and (i_layer_id <> i_txfr_layer_id) then
        /* if payback txn and txn involved different projects
           then populate MCTCD with the borrowed cost */

        l_stmt_num := 70;

        CSTPLVCP.borrow_cost(   i_org_id,
                       		i_txn_id,
                       		i_user_id,
                       		i_login_id,
                       		i_req_id,
                       		i_prg_appl_id,
                       		i_prg_id,
                       		i_item_id,
                       		0, -- hook is not used
                       		i_txfr_layer_id,
				l_err_num,
				l_err_code,
				l_err_msg);
        if (l_err_num <> 0) then
          raise process_error;
        end if;

      end if; -- l_txn_type_id = 68, if it is payback transaction
    end if;  -- i_txn_action_id IN (2,28,55), if it is sub/staging transfer

    /* when we process transfer org's txn(i.e. intransit txfr),
       we need to use txfr_layer_id instead. */
    if (i_org_id <> i_txn_org_id) then
      l_layer_id := i_txfr_layer_id;
    else
      l_layer_id := i_layer_id;
    end if;
  end if;

  /*
  The following section will populate MCTCD for RMA Receipts. If the RMA Receipt
  references a Sales Order, the average cost of the Sales Order Issues will be used.
  If the RMA Receipt does not reference a Sales Order and there exist positive
  layers, the cost of the earliest positive layer will be used in FIFO. If no
  positive layer exists or if the cost method is LIFO, MCTCD will not be populated
  and the RMA Receipt will be processed at the latest layer cost (e.g. as a cost
  derived transaction)
  */

  -- Check if the transaction is an RMA receipt
  IF i_txn_action_id = 27 AND i_txn_src_type = 12 THEN
    -- Check if Sales Order is referenced
    l_stmt_num := 72;
    SELECT MIN(OOLA.reference_line_id)
    INTO   l_so_line_id
    FROM   mtl_material_transactions MMT,
           oe_order_lines_all OOLA
    WHERE  MMT.transaction_id = i_txn_id
    AND    OOLA.line_id = MMT.trx_source_line_id;

    IF l_so_line_id IS NOT NULL THEN
      -- A Sales Order is referenced, use the average cost of the Sales Order Issues
      l_stmt_num := 74;
      INSERT
      INTO   mtl_cst_txn_cost_details (
               transaction_id,
               organization_id,
               inventory_item_id,
               cost_element_id,
               level_type,
               transaction_cost,
               last_update_date,
               last_updated_by,
               creation_date,
               created_by,
               last_update_login,
               request_id,
               program_application_id,
               program_id,
               program_update_date
             )
      SELECT i_txn_id,
             i_org_id,
             i_item_id,
             MCACD.cost_element_id,
             MCACD.level_type,
             SUM(MMT.primary_quantity*MCACD.actual_cost)/SUM(MMT.primary_quantity),
             SYSDATE,
             i_user_id,
             SYSDATE,
             i_user_id,
             i_login_id,
             i_req_id,
             i_prg_appl_id,
             i_prg_id,
             SYSDATE
      FROM   oe_order_lines_all OOLA,   /*BUG 5768680 Changes introduced to improve performance*/
             oe_order_headers_all OOHA, /* of the layer cost worker*/
             mtl_sales_orders MSO,
	     mtl_material_transactions MMT,
             mtl_cst_actual_cost_details MCACD
      WHERE  OOLA.line_id = l_so_line_id
      AND    OOHA.header_id = OOLA.header_id
      AND    MSO.segment1 = TO_CHAR(OOHA.order_number) -- extraneous MSOs are possible
      AND    MMT.transaction_source_id = MSO.sales_order_id
      AND    MMT.trx_source_line_id = l_so_line_id -- filter MMTs corresponding to extraneous MSOs
      AND    MMT.transaction_action_id IN (1,7)
      AND    MMT.transaction_source_type_id = 2
      AND    MMT.organization_id = i_org_id
      AND    MMT.inventory_item_id = i_item_id
      AND    MCACD.transaction_id = MMT.transaction_id
      GROUP
      BY     MCACD.cost_element_id,
             MCACD.level_type;
    ELSIF i_cost_method = 5 THEN
      -- No Sales Order is referenced and the cost method is FIFO, use the cost of
      -- earliest positive layer if one exists
      l_stmt_num := 76;
      INSERT
      INTO   mtl_cst_txn_cost_details (
               transaction_id,
               organization_id,
               inventory_item_id,
               cost_element_id,
               level_type,
               transaction_cost,
               last_update_date,
               last_updated_by,
               creation_date,
               created_by,
               last_update_login,
               request_id,
               program_application_id,
               program_id,
               program_update_date
             )
      SELECT i_txn_id,
             i_org_id,
             i_item_id,
             CILCD.cost_element_id,
             CILCD.level_type,
             CILCD.layer_cost,
             SYSDATE,
             i_user_id,
             SYSDATE,
             i_user_id,
             i_login_id,
             i_req_id,
             i_prg_appl_id,
             i_prg_id,
             SYSDATE
      FROM   cst_inv_layer_cost_details CILCD
      WHERE  CILCD.inv_layer_id = (
               SELECT MIN(inv_layer_id)
               FROM   cst_inv_layers
               WHERE  layer_id = l_layer_id
               AND    layer_quantity > 0
               AND    creation_date = (
                 SELECT MIN(creation_date)
                 FROM   cst_inv_layers
                 WHERE  layer_id = l_layer_id
                 AND    layer_quantity > 0
               )
             );
    END IF; -- Check if Sales Order is referenced
  END IF; -- Check if transaction is an RMA receipt

  /* Call compute_layer_actual_cost for all transactions,
     so that MCACD and MCLACD can be updated, contrary to average
     costing where the function is called only if the cost hook
     does not exist */

  /* Changes for VMI. Adding planning transfer transaction */
  if (i_txn_action_id NOT IN (2,5,3,12,21,28,55)) then
    l_stmt_num := 80;

    l_new_cost := CSTPLENG.compute_layer_actual_cost(
						  i_org_id,
						  i_cost_method,
                        		          i_txn_id,
		                                  i_layer_id,
						  l_cost_hook,
                                            	  i_cost_type,
		                               	  i_mat_ct_id,
		                                  i_avg_rates_id,
            		                    	  i_item_id,
                        		          i_txn_qty,
		                                  i_txn_action_id,
            		                    	  i_txn_src_type,
                        		          null,
		                                  i_exp_flag,
            		                          i_user_id,
                        		          i_login_id,
		                                  i_req_id,
      		                                  i_prg_appl_id,
                  		                  i_prg_id,
                              		          l_err_num,
		                                  l_err_code,
            		                    	  l_err_msg);


    if (l_err_num <> 0) then
      raise process_error;
    end if;
  end if;

  /* If this transaction is a subinventory transfer then call the
     sub_transfer special function.  We treat interorg intransit
     shipment for FOB receipt and interorg intransit for FOB shipment
     as sub_transfer transactions.  */
  /* Changes for VMI. Adding planning transfer transaction */
  if ((i_txn_action_id IN (2,5,28,55)) or
      (i_txn_action_id = 21 and i_org_id = i_txn_org_id and i_fob_point = 2) or
      (i_txn_action_id = 12 and i_org_id = i_txn_org_id and i_fob_point = 1)) then
    l_stmt_num := 90;
    CSTPLVCP.sub_transfer(
			i_org_id,
			i_txn_id,
			i_layer_id,
			i_cost_type,
			i_item_id,
			l_txn_qty,
			i_txn_action_id,
			i_txn_src_type,
			l_new_cost,
			l_cost_hook,
			i_cost_method,
			i_txfr_layer_id,
			i_citw_flag,
			i_flow_schedule,
			i_mat_ct_id,
			i_avg_rates_id,
			i_user_id,
			i_login_id,
			i_req_id,
			i_prg_appl_id,
			i_prg_id,
			l_err_num,
			l_err_code,
			l_err_msg);

    if (l_err_num <> 0) then
      raise process_error;
    end if;
    /* Update the layer costs, CQL, CLCD and item costs for
       processed transactions */
  elsif (i_exp_item <> 1) then
    /* when we process transfer org's txn(i.e. intransit txfr),
       we need to use txfr_layer_id instead. */
    if (i_org_id <> i_txn_org_id) then
      l_layer_id := i_txfr_layer_id;
      l_txn_qty := -1 * l_txn_qty;
      l_org_id := i_txn_org_id;
    else
      l_layer_id := i_layer_id;
      l_org_id := i_org_id;
    end if;

    l_stmt_num := 100;

    /* begin fix for bug 3679625 */
    if (i_txn_action_id = 3 and i_org_id <> i_txn_org_id) then
       -- for the receiving transaction of a direct interorg transfer,
       -- if the receiving org is standard and item or sub is expense in the std org,
       -- do not call calc_layer_average_cost
      select primary_cost_method
      into l_to_method
      from mtl_parameters
      where organization_id = i_txn_org_id;

      if (l_to_method = 1) then
        l_std_org := i_txn_org_id;
        l_stmt_num := 102;
        select decode(inventory_asset_flag, 'Y', 0, 1)
        into l_to_std_exp
        from mtl_system_items
        where inventory_item_id = i_item_id
        and organization_id = l_std_org;

        l_stmt_num := 103;
        select decode(l_to_std_exp,1,1,decode(asset_inventory,1,0,1))
        into l_to_std_exp
        from mtl_secondary_inventories msi,
             mtl_material_transactions mmt
        where mmt.transaction_id = i_txn_id
        and mmt.organization_id = l_std_org
        and msi.organization_id = l_std_org
        and msi.secondary_inventory_name = mmt.subinventory_code;
      end if;
    end if;

    if (i_org_id = i_txn_org_id or i_txn_action_id <> 3 or l_to_std_exp <> 1)  then
      l_stmt_num := 104;
      CSTPLENG.calc_layer_average_cost (i_org_id,
					i_txn_id,
					l_layer_id,
					i_cost_type,
					i_item_id,
                                        l_txn_qty,
                                        i_txn_action_id,
                                        l_cost_hook,
					l_no_update_mmt,
                                        0,
					i_user_id,
					i_login_id,
					i_req_id,
					i_prg_appl_id,
					i_prg_id,
					l_err_num,
					l_err_code,
					l_err_msg);
      if (l_err_num <> 0) then
        raise process_error;
      end if;
    end if;
  end if;

  -- For Internal Order Issue transactons to Expense destinations,
  -- call Cost_LogicalSOReceipt API to cost the Receipt transaction.
  l_stmt_num := 110;

  select transaction_type_id
  into   l_txn_type_id
  from   mtl_material_transactions
  where  transaction_id = i_txn_id;

  l_stmt_num := 120;
  IF ( I_TXN_ACTION_ID = 1 AND L_TXN_TYPE_ID = 34 AND I_TXN_SRC_TYPE = 8) THEN
    CSTPAVCP.Cost_LogicalSOReceipt (
      p_parent_txn_id => i_txn_id,
      p_user_id       => i_user_id,
      p_request_id    => i_req_id,
      p_prog_id       => i_prg_id,
      p_prog_app_id   => i_prg_appl_id,
      p_login_id      => i_login_id,
      x_err_num       => l_err_num,
      x_err_code      => l_err_code,
      x_err_msg       => l_err_msg
    );
    IF l_err_num <> 0 THEN
      RAISE PROCESS_ERROR;
    END IF;
  END IF;

  EXCEPTION
    when process_error then
      o_err_num := l_err_num;
      o_err_code := l_err_code;
      o_err_msg := l_err_msg;
    when OTHERS then
      rollback;
      o_err_num := SQLCODE;
      o_err_msg := 'CSTPLVCP.Cost_Processor (' || to_char(l_stmt_num) || '): '
		|| substr(SQLERRM,1,200);
END cost_processor;

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
  I_NEW_COST		IN NUMBER,
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
) IS
  l_txn_qty		NUMBER;
  l_new_cost	NUMBER;
  l_exp_flag	NUMBER;
  l_err_num		NUMBER;
  l_err_code	VARCHAR2(240);
  l_err_msg		VARCHAR2(240);
  l_stmt_num	NUMBER;
  process_error	EXCEPTION;
BEGIN
  -- initialize local variables
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';

  l_txn_qty := i_txn_qty;

  l_stmt_num := 10;
-- item cost history, update the transfer_prior_costed_quantity
-- is necessary because we need both the from and the to information
-- in item cost history
	UPDATE mtl_material_transactions mmt
	SET TRANSFER_PRIOR_COSTED_QUANTITY =
	(SELECT
		layer_quantity
	FROM	cst_quantity_layers cql
	WHERE	cql.layer_id = i_txfr_layer_id)
	WHERE mmt.transaction_id = i_txn_id
	AND EXISTS (
			SELECT 'X'
			FROM cst_quantity_layers cql
			WHERE cql.layer_id = i_txfr_layer_id);

-- item cost history
  l_stmt_num := 20;

  -- We break down common issue to WIP transaction into two parts.
  --   1. common to project sub
  --      treat it as a subinventory transfer
  --   2. project sub to project job issue
  --      insert a separate row in MCACD and call wip cost processor
  --      and distribution processor

  CSTPLVCP.sub_transfer(
			i_org_id,
			i_txn_id,
			i_layer_id,
			i_cost_type,
			i_item_id,
			l_txn_qty,
			i_txn_action_id,
			i_txn_src_type,
			l_new_cost,
			NULL,
                        i_cost_method,
			i_txfr_layer_id,
			i_citw_flag,
			i_flow_schedule,
			i_mat_ct_id,
			i_avg_rates_id,
			i_user_id,
			i_login_id,
			i_req_id,
			i_prg_appl_id,
			i_prg_id,
			l_err_num,
			l_err_code,
			l_err_msg);

  if (l_err_num <> 0) then
    raise process_error;
  end if;

  l_stmt_num := 30;

  -- figure out project sub asset type, it depends on project job type and
  -- from subinventory asset type.
  if (i_flow_schedule = 1) then
    l_stmt_num := 35;
    select decode(wac.class_type, 1, 0,
                                  3, 0,
                                  4, decode(i_exp_flag, 1, 1, 0))
    into   l_exp_flag
    from   mtl_material_transactions mmt,
           wip_flow_schedules wfs,
           wip_accounting_classes wac
    where  mmt.transaction_id = i_txn_id
    and    mmt.organization_id = i_org_id
    and    wfs.organization_id = i_org_id
    and    wfs.wip_entity_id = mmt.transaction_source_id
    and    wac.organization_id = i_org_id
    and    wac.class_code = wfs.class_code;
  else
    l_stmt_num := 37;
    select decode(wac.class_type, 1, 0,
                                  3, 0,
                                  4, decode(i_exp_flag, 1, 1, 0))
    into   l_exp_flag
    from   mtl_material_transactions mmt,
           wip_discrete_jobs wdj,
           wip_accounting_classes wac
    where  mmt.transaction_id = i_txn_id
    and    mmt.organization_id = i_org_id
    and    wdj.organization_id = i_org_id
    and    wdj.wip_entity_id = mmt.transaction_source_id
    and    wac.organization_id = i_org_id
    and    wac.class_code = wdj.class_code;
  end if;

  l_stmt_num := 40;

  CSTPLCWP.cost_wip_trx(i_txn_id,
			i_citw_flag,
			i_cost_type,
			i_cost_method,
			i_avg_rates_id,
        		i_cost_grp_id,
			i_txfr_cost_grp,
			l_exp_flag,
			i_exp_item,
			i_flow_schedule,
			i_user_id,
			i_login_id,
			i_req_id,
			i_prg_id,
			i_prg_appl_id,
			l_err_num,
			l_err_code,
			l_err_msg);


  if (l_err_num <> 0) then
    raise process_error;
  end if;

  EXCEPTION
    when process_error then
      o_err_num := l_err_num;
      o_err_code := l_err_code;
      o_err_msg := l_err_msg;
    when others then
      rollback;
      o_err_num := SQLCODE;
      o_err_msg := 'CSTPLVCP.common_issue_to_wip (' || to_char(l_stmt_num) ||
                   '): '
		   || substr(SQLERRM, 1,200);
END common_issue_to_wip;

-- PROCEDURE
--  Interorg
--  This procedure will compute the transfer cost of an intransit
--  interorg transaction.  It will also compute the transaction cost
--  of this transfer.
procedure interorg(
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
) IS
  l_err_num     NUMBER;
  l_err_code    VARCHAR2(240);
  l_err_msg     VARCHAR2(240);
  l_stmt_num    NUMBER;
  process_error EXCEPTION;
  l_txn_update_id NUMBER;
  l_compute_txn_cost NUMBER;
  l_from_org    NUMBER;
  l_to_org      NUMBER;
  l_from_cost_grp NUMBER;
  l_to_cost_grp NUMBER;
  l_cost_type_id NUMBER;
  l_snd_txn_cost        NUMBER;
  l_rcv_txn_cost        NUMBER;
  l_txn_cost    NUMBER;
  l_txfr_cost   NUMBER;
  l_trans_cost  NUMBER;
  l_std_from_org        NUMBER;
  l_std_to_org          NUMBER;
  l_std_org             NUMBER;
  l_std_cost_org        NUMBER;  /* bugfix 3048258 */
  l_std_exp             NUMBER;
  l_update_std          NUMBER;
  l_snd_sob_id          NUMBER;
  l_snd_curr            VARCHAR2(10);
  l_rcv_sob_id          NUMBER;
  l_rcv_curr            VARCHAR2(10);
  l_curr_type           VARCHAR2(30);
  l_conv_rate           NUMBER;
  l_conv_date           DATE;
  l_snd_uom             VARCHAR2(3);
  l_rcv_uom             VARCHAR2(3);
  l_snd_qty             NUMBER;
  l_count               NUMBER;
-- item cost history stuff
  l_which_org           NUMBER;
  l_which_cst_grp       NUMBER;
-- item cost history stuff
-- elemental visibility
  l_movh                NUMBER;
  l_movh_cost           NUMBER;
  l_rec_movh_cost       NUMBER;
  l_mctcd_ovhd          NUMBER;
  l_from_layer_id       NUMBER;
  l_elemental_visible   varchar2(1);
-- elemental visibility
  l_um_rate          NUMBER;
  l_new_cost         NUMBER;
-- FIFO/LIFO
  l_from_method     NUMBER;
  l_to_method       NUMBER;
  l_from_layer      NUMBER;
  l_to_layer        NUMBER;
  l_mclacd_exists   NUMBER;
  l_create_layers   NUMBER;
  l_debug           VARCHAR2(80);
/* moh variables */
  l_return_status   VARCHAR2(1);
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(240);
  l_earn_moh        NUMBER;
  moh_rules_error   EXCEPTION;

  -- Added for bug 2827548
  l_xfer_conv_rate  NUMBER;
  l_new_txn_cost    NUMBER;

  -- Added for bug 3679625
  l_txfr_txn_id         NUMBER;
  l_txfr_std_exp        NUMBER;
  -- Added for bug 3761538
  l_to_std_exp          NUMBER;
  l_interorg_elem_exp_flag  NUMBER;

BEGIN
  -- initialize local variables
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';
  l_update_std := 0;
  l_snd_qty := o_txn_qty;
  l_std_exp := 0;
  l_from_layer := 0;
  l_to_layer := 0;
  l_create_layers := 1;
  l_debug := FND_PROFILE.value('MRP_DEBUG');

  l_earn_moh := 1;
  l_return_status := fnd_api.g_ret_sts_success;
  l_msg_count := 0;

  l_txfr_std_exp := 0;
  l_to_std_exp := 0;

  -- Figure the from and to org for this transaction.
  if (i_txn_action_id = 21) then
    l_from_org := i_txn_org_id;
    l_to_org := i_txfr_org_id;
    l_from_cost_grp := i_cost_grp_id;
    l_to_cost_grp := i_txfr_cost_grp;
  elsif (i_txn_action_id = 12) then
    l_from_org := i_txfr_org_id;
    l_to_org := i_txn_org_id;
    l_from_cost_grp := i_txfr_cost_grp;
    l_to_cost_grp := i_cost_grp_id;
  elsif (i_txn_action_id =3 and o_txn_qty <0) then
    l_from_org := i_txn_org_id;
    l_to_org := i_txfr_org_id;
    l_from_cost_grp := i_cost_grp_id;
    l_to_cost_grp := i_txfr_cost_grp;
  else
    l_from_org := i_txfr_org_id;
    l_to_org := i_txn_org_id;
    l_from_cost_grp := i_txfr_cost_grp;
    l_to_cost_grp := i_cost_grp_id;
  end if;

  l_stmt_num := 2;
  select primary_cost_method
  into l_from_method
  from mtl_parameters
  where organization_id = l_from_org;

  select primary_cost_method
  into l_to_method
  from mtl_parameters
  where organization_id = l_to_org;

  l_stmt_num := 3;
  if ((l_from_method NOT IN (5,6)) and (l_to_method NOT IN (5,6))) then
        raise process_error;
  end if;

  l_stmt_num := 6;
  select NVL(elemental_visibility_enabled,'N')
  into l_elemental_visible
  from mtl_interorg_parameters
  where from_organization_id = l_from_org
  and to_organization_id = l_to_org;

  l_stmt_num := 10;

 /* Bug 2926258 - default l_std_org to -1 to support org_id=0 */
 if (l_from_method = 1) then
      l_std_org := l_from_org;
      l_std_from_org := 1;
      l_std_to_org := 0;
  elsif (l_to_method = 1) then
      l_std_org := l_to_org;
      l_std_from_org := 0;
      l_std_to_org := 1;
  else
      l_std_org := -1;
      l_std_from_org := 0;
      l_std_to_org := 0;
  end if;


  FND_FILE.PUT_LINE(FND_FILE.LOG,'Standard costing org : ' || to_char(l_std_org));

  if(l_debug = 'Y') then
     fnd_file.put_line(fnd_file.log, 'In interorg(..)');
     fnd_file.put_line(fnd_file.log, 'l_std_org' || l_std_org);
     fnd_file.put_line(fnd_file.log, 'l_std_from_org' || l_std_from_org);
     fnd_file.put_line(fnd_file.log, 'l_std_to_org' || l_std_to_org);
     fnd_file.put_line(fnd_file.log, 'i_fob_point' || i_fob_point);
  end if;

  /* bug 3048258: For std costing, item cost from cost organization should be used */
  l_stmt_num := 15;
  IF ( l_std_from_org = 1 OR l_std_to_org = 1 ) THEN
     select cost_organization_id
       into l_std_cost_org
       from mtl_parameters
      where organization_id = l_std_org;
  END IF;

  if (l_std_org = i_txn_org_id) then
    l_stmt_num :=  20;
    select decode(inventory_asset_flag, 'Y', 0, 1)
    into l_std_exp
    from mtl_system_items
    where inventory_item_id = i_item_id
    and organization_id = l_std_org;

    l_stmt_num := 30;
    select decode(l_std_exp,1,1,decode(asset_inventory,1,0,1))
    into l_std_exp
    from mtl_secondary_inventories msi
        ,mtl_material_transactions mmt
    where mmt.transaction_id = i_txn_id
    and mmt.organization_id = l_std_org
    and msi.organization_id = l_std_org
    and msi.secondary_inventory_name = mmt.subinventory_code;
  end if;

  get_snd_rcv_uom(i_item_id, l_from_org, l_to_org, l_snd_uom, l_rcv_uom,
      l_err_num, l_err_code, l_err_msg);
  if (l_err_num <> 0) then
    raise process_error;
  end if;

  -- If the transaction organization id is not the organization id of this
  -- cost worker then we have to make sure this transaction record in mmt
  -- does not get updated. Most likely this is an intrasit interorg transaction
  -- and we are processing either the shipping or the receiving side. For the
  -- same reason we cannot rely on the expense flag since it is based on
  -- the current record's subinventory code.
  --
  if ((i_org_id <> i_txn_org_id)  and (i_txn_action_id in (12,21))) then
    o_no_update_mmt := 1;
    if (l_from_org = i_org_id) then
      o_txn_qty := inv_convert.inv_um_convert
        (i_item_id, NULL, o_txn_qty,
           l_rcv_uom, l_snd_uom, NULL, NULL);
      l_snd_qty := o_txn_qty;
    else
      o_txn_qty := inv_convert.inv_um_convert
        (i_item_id, NULL, o_txn_qty,
           l_snd_uom, l_rcv_uom, NULL, NULL);
    end if;

    l_stmt_num := 40;

    select decode(inventory_asset_flag, 'Y',0,1)
    into o_exp_flag
    from mtl_system_items
    where inventory_item_id = i_item_id
    and organization_id = i_org_id;
  end if;

  -- The following are considered interorg receipt transactions.
  -- These are transactions where ownership changes and the current org
  -- is the receiving org.
  if ((i_txn_action_id = 3 and o_txn_qty > 0 and i_txn_org_id = i_org_id) OR
      (i_txn_action_id = 21 and i_txfr_org_id = i_org_id and i_fob_point = 1)
     OR (i_txn_action_id = 12 and i_txn_org_id = i_org_id and i_fob_point = 2))
     then
    o_interorg_rec := 1;
  else
    o_interorg_rec :=0;
  end if;

-- item cost history stuff

  if( ( (i_txn_action_id = 21) and (i_fob_point = 1) and (l_std_to_org = 0) ) OR
      ( (i_txn_action_id = 12) and (i_fob_point = 1) and (l_std_to_org = 0) ) OR
      ( (i_txn_action_id = 21) and (i_fob_point = 2) and (l_std_from_org = 0) ) OR
      ( (i_txn_action_id = 12) and (i_fob_point = 2) and (l_std_to_org = 0) ) ) then
    -- intransit ship, fob ship, receiving org is avg org.
    if ( (i_txn_action_id = 21) and (i_fob_point = 1) and (l_std_to_org = 0) ) then
      l_which_org := l_to_org;
      l_which_cst_grp := i_txfr_cost_grp;
    -- intransit receipt, fob ship, receiving org is avg org.
    elsif ( (i_txn_action_id = 12) and (i_fob_point = 1) and (l_std_to_org = 0) ) then
      l_which_org := l_to_org;
      l_which_cst_grp := i_cost_grp_id;
    -- intransit ship, fob receipt, sending org is avg org.
    -- bug 729138
    elsif ( (i_txn_action_id = 21) and (i_fob_point = 2) and (l_std_from_org = 0) ) then
      l_which_org := l_from_org;
      l_which_cst_grp := i_txfr_cost_grp;
    -- intransit receipt, fob receipt, receiving org is avg org.
    elsif ( (i_txn_action_id = 12) and (i_fob_point = 2) and (l_std_to_org = 0) ) then
      l_which_org := l_from_org;
      l_which_cst_grp := i_txfr_cost_grp;
    end if;

    if i_org_id = l_which_org then  -- this takes care the case R/R,
                                    -- cost worker will process the same mmt
                                    -- transaction twice
        l_stmt_num := 50;
  UPDATE mtl_material_transactions mmt
  SET TRANSFER_PRIOR_COSTED_QUANTITY =
  (SELECT
    layer_quantity
  FROM  cst_quantity_layers cql
  WHERE cql.organization_id = l_which_org
  AND   cql.inventory_item_id = i_item_id
  AND   cql.cost_group_id = l_which_cst_grp)
  WHERE mmt.transaction_id = i_txn_id
  AND EXISTS (
      SELECT 'X'
      FROM cst_quantity_layers cql
      WHERE cql.organization_id = l_which_org
      AND   cql.inventory_item_id = i_item_id
                        AND   cql.cost_group_id = l_which_cst_grp);

  IF SQL%ROWCOUNT = 0 THEN
          update mtl_material_transactions mmt
     set TRANSFER_PRIOR_COSTED_QUANTITY = 0
          where  mmt.transaction_id = i_txn_id;
  END IF;
    end if;
  end if;

---- end for item cost history

  -- bug 2827548 - took following IF condition out of the one that follows it because we
  -- need to update txn_cost of receit txn before returning if shipment is already costed
  if  (i_txn_action_id = 12 and i_org_id = i_txn_org_id and i_fob_point = 1) then
    UPDATE mtl_material_transactions mmt
    SET mmt.transaction_cost = (select (mmt1.transaction_cost * mmt1.currency_conversion_rate)
                                from mtl_material_transactions mmt1
                                where mmt1.transaction_id = mmt.transfer_transaction_id
                                and mmt1.costed_flag is null)
    WHERE mmt.transaction_id = i_txn_id
    AND nvl(mmt.transaction_cost,0) = 0;
    return;
  end if;

  -- If this is an intransit shipment with FOB point receipt or intransit
  -- receipt with FOB point shipment or if this is an interorg receipt
  -- transaction from another average cost org, or if this is a direct
  -- interorg receipt transaction, then we are all done!!!
  if (i_txn_action_id = 21 and i_org_id = i_txn_org_id and i_fob_point = 2) then

            return;
/* Consume or create layers as necessary */
--  elsif (o_exp_flag <> 1) then
    else
      if ((i_txn_action_id = 3 and o_txn_qty > 0)
    OR (i_txn_action_id = 12 and i_org_id = i_txn_org_id and i_fob_point = 2)
          OR (i_txn_action_id = 21 and i_org_id = i_txfr_org_id and i_fob_point = 1)) then
    if (l_to_method <> 1) then
               select nvl(layer_id,0) into l_to_layer from cst_quantity_layers
                     where organization_id = l_to_org and inventory_item_id = i_item_id
                     and cost_group_id = l_to_cost_grp;
                end if;


FND_FILE.PUT_LINE(FND_FILE.LOG,'----------l_to_method---------');
FND_FILE.PUT_LINE(FND_FILE.LOG,'=' || l_to_method);

     FND_FILE.PUT_LINE(FND_FILE.LOG,'Interorg transfer receiving org: (create layers) ...');
           FND_FILE.PUT_LINE(FND_FILE.LOG,to_char(i_txn_org_id) || ':' || to_char(l_to_method));
     FND_FILE.PUT_LINE(FND_FILE.LOG,to_char(i_txn_id) || ':' || to_char(l_to_layer));

             /* Bug #2352604, 2362306.
                Call create_layers when :
                        Direct Interorg transfers
                        Intransit shipment, FOB shipment from non-std to LIFO
                        Intransit receipt, FOB receipt from non-std to LIFO
             */
             if ((l_to_method IN (5,6)) and (l_from_method <> 1 or i_txn_action_id = 3)) then
                 CSTPLENG.create_layers(
          i_org_id,
          i_txn_id,
          l_to_layer,
          i_item_id,
          abs(o_txn_qty),
          i_cost_method,
          i_txn_src_type,
          i_txn_action_id,
          0,
          o_interorg_rec, --bug 2280515 (anjgupta)
          i_cost_type,
          i_mat_ct_id,
          i_avg_rates_id,
          o_exp_flag,
          i_user_id,
          i_login_id,
          i_req_id,
          i_prg_appl_id,
          i_prg_id,
          l_err_num,
          l_err_code,
          l_err_msg);
              end if;
   elsif ((i_txn_action_id = 3 and o_txn_qty < 0)
    OR (i_txn_action_id = 12 and i_org_id = i_txfr_org_id and i_fob_point = 2)
    OR (i_txn_action_id = 21 and i_org_id = i_txn_org_id and i_fob_point = 1)) then
                      if (l_from_method <> 1) then
            select nvl(layer_id,0)
            into l_from_layer
            from cst_quantity_layers
            where organization_id = l_from_org
            and inventory_item_id = i_item_id
            and cost_group_id = l_from_cost_grp;
             end if;

                        FND_FILE.PUT_LINE(FND_FILE.LOG,'Interorg transfer send org: (consume layers) ...');
      FND_FILE.PUT_LINE(FND_FILE.LOG,to_char(i_txn_org_id) || ':' || to_char(l_from_method));
                  FND_FILE.PUT_LINE(FND_FILE.LOG,to_char(i_txn_id) || ':' || to_char(l_from_layer));
                    if (l_from_method IN (5,6)) then
      CSTPLENG.consume_layers(
          i_org_id,
          i_txn_id,
          l_from_layer,
          i_item_id,
          -1*abs(o_txn_qty),
          i_cost_method,
          i_txn_src_type,
          i_txn_action_id,
          0,
          o_interorg_rec, --bug 2280515
          i_cost_type,
          i_mat_ct_id,
          i_avg_rates_id,
          o_exp_flag,
          i_user_id,
          i_login_id,
          i_req_id,
          i_prg_appl_id,
          i_prg_id,
          l_err_num,
          l_err_code,
          l_err_msg);
                      end if;
    end if;


   if (l_err_num <> 0) then
              raise process_error;
       end if;
   end if;


    if (o_interorg_rec = 1 and (i_txn_action_id = 3 or l_std_from_org <> 1))
    then
    return;
  end if;

  /***********************************************************************
   ** In the following conditions we will be doing distribution for the **
   ** standard org, so need populate mtl_cst_actual_cost_details with   **
   ** the standard costs.                                               **
   ** 1. intransit interorg and one of the orgs is standard.            **
   ** 2. direct interorg and the txn_org_id is standard.                **
   ***********************************************************************/
  if ((i_txn_action_id = 3 and l_std_org = i_txn_org_id) OR
      (i_txn_action_id in (12,21) and
       (l_std_from_org = 1 or l_std_to_org = 1))) then

/* for bug 3761538 */
  if (i_txn_action_id in (12,21) and i_fob_point = 1 and l_std_to_org = 1) then
    -- for the receiving transaction of a intransit fob shipment interorg transfer,
    -- if the receiving org is standard and item is expense in the std org, set l_to_std_exp
    -- = 1 to later insert into mcacd from mcacd.
        l_stmt_num := 102;
      select decode(inventory_asset_flag, 'Y', 0, 1)
      into l_to_std_exp
      from mtl_system_items
      where inventory_item_id = i_item_id
      and organization_id = l_std_org;
  end if;
  if (l_to_std_exp = 1) then
    fnd_file.put_line(fnd_file.log, 'item is expense in receiving std org');
  elsif
/* end for bug 3671538 */
   ((l_std_exp <> 1) or (l_std_from_org = 1) or
        (l_std_to_org = 1 and i_txn_action_id = 12 and i_fob_point = 1))
       then

       /* Use standard costs only for non-expense or not interorg shipements*/
       /* Need to use sending org cost for expense interorg receipts */
      l_stmt_num := 60;

      l_count := 0;

      select count(*)
      into l_count
      from cst_item_cost_details
      where /* organization_id = l_std_org : bugfix 3048258 */
            organization_id = l_std_cost_org
      and cost_type_id = 1
      and inventory_item_id = i_item_id;

      l_stmt_num := 70;
      /* If no rows exist in cicd (item hasn't been costed), insert into */
      /* mcacd using 0 value of this level material */
      if (l_count > 0) then
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Insert into MCACD for std org using cost from CICD');
        insert into mtl_cst_actual_cost_details (
    transaction_id,
    organization_id,
    layer_id,
    cost_element_id,
    level_type,
    transaction_action_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    request_id,
    program_application_id,
    program_id,
    program_update_date,
    inventory_item_id,
    actual_cost,
    prior_cost,
    new_cost,
    insertion_flag,
    variance_amount,
    user_entered)
        select i_txn_id,
    l_std_org,
    -1,
    cicd.cost_element_id,
    cicd.level_type,
    i_txn_action_id,
    sysdate,
          i_user_id,
          sysdate,
          i_user_id,
          i_login_id,
          i_req_id,
          i_prg_appl_id,
          i_prg_id,
          sysdate,
    i_item_id,
          nvl(sum(cicd.item_cost),0),
          NULL,
    NULL,
          'N',
          0,
          'N'
        from cst_item_cost_details cicd
        where /* organization_id = l_std_org : bugfix 3048258 */
              organization_id = l_std_cost_org
        and cost_type_id = 1
        and inventory_item_id = i_item_id
        group by cost_element_id, level_type;
      else
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Insert into MCACD for std org using 0 cost');
        insert into mtl_cst_actual_cost_details (
    transaction_id,
    organization_id,
    layer_id,
    cost_element_id,
    level_type,
    transaction_action_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    request_id,
    program_application_id,
    program_id,
    program_update_date,
    inventory_item_id,
    actual_cost,
    prior_cost,
    new_cost,
    insertion_flag,
    variance_amount,
    user_entered)
        values ( i_txn_id,
    l_std_org,
    -1,
    1,
    1,
    i_txn_action_id,
    sysdate,
          i_user_id,
          sysdate,
          i_user_id,
          i_login_id,
          i_req_id,
          i_prg_appl_id,
          i_prg_id,
          sysdate,
    i_item_id,
          0,
          NULL,
    NULL,
          'N',
          0,
          'N');
      end if;

      -- Need to apply material overheads if standard org is receiving
      if (l_std_to_org =1) then
        l_stmt_num := 80;
     /* Changes for MOH Absorption */
          cst_mohRules_pub.apply_moh(
                              1.0,
                              p_organization_id => l_std_org,
                              p_earn_moh =>l_earn_moh,
                              p_txn_id => i_txn_id,
                              p_item_id => i_item_id,
                              x_return_status => l_return_status,
                              x_msg_count => l_msg_count,
                              x_msg_data => l_msg_data);

         IF l_return_status <> FND_API.g_ret_sts_success THEN

              CST_UTILITY_PUB.writelogmessages
                          ( p_api_version   => 1.0,
                            p_msg_count     => l_msg_count,
                            p_msg_data      => l_msg_data,
                            x_return_status => l_return_status);
              RAISE moh_rules_error;
        END IF;

         if (l_earn_moh = 0 ) then
              FND_FILE.put_line(fnd_file.log, '--Material Overhead Absorption Overridden--');
         else

        Insert into mtl_actual_cost_subelement(
    layer_id,
    transaction_id,
    organization_id,
    cost_element_id,
    level_type,
    resource_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    request_id,
    program_application_id,
    program_id,
    program_update_date,
    actual_cost,
    user_entered)
        select -1, i_txn_id,
     l_std_org,
     cicd.cost_element_id,
     cicd.level_type,
     cicd.resource_id,
     sysdate,
           i_user_id,
     sysdate,
     i_user_id,
       i_login_id,
           i_req_id,
           i_prg_appl_id,
           i_prg_id,
           sysdate,
     cicd.item_cost,
     'N'
        from cst_item_cost_details cicd
        where inventory_item_id = i_item_id
        and /* organization_id = l_std_org : bugfix 3048258 */
            organization_id = l_std_cost_org
        and cost_type_id = 1
       and cost_element_id = 2
       and level_type = 1;
/* Bug 2277950 - Earn only THIS level Material Overhead */
      end if;
    END IF;

      if (i_txn_org_id = l_std_org) then
      -- update actual cost column of mmt.
        l_stmt_num := 90;

        update mtl_material_transactions mmt
        set (last_update_date,
     last_updated_by,
     last_update_login,
     request_id,
     program_application_id,
         program_id,
     program_update_date,
     actual_cost) =
        (select sysdate,
    i_user_id,
    i_login_id,
    i_req_id,
    i_prg_appl_id,
    i_prg_id,
    sysdate,
    nvl(sum(actual_cost),0)
         from mtl_cst_actual_cost_details cacd
         where cacd.transaction_id = i_txn_id
         and cacd.organization_id = l_std_org
   and cacd.layer_id = -1)
        where mmt.transaction_id = i_txn_id;
      end if;
    else
      l_update_std := 1;
    end if;
  end if;

  -- If this is a direct interorg transfer then we need to update the
  -- transaction cost and transaction cost details using the transaction_id
  -- in the transfer_transaction_id.

  if (i_txn_action_id = 3) then
    l_stmt_num := 100;

    select transfer_transaction_id
    into l_txn_update_id
    from mtl_material_transactions
    where transaction_id = i_txn_id;
  else
    l_txn_update_id := i_txn_id;
  end if;

  -- If we are shipping from a standard cost org to an average cost org, the
  -- transaction cost must be computed at the time of the average cost worker
  -- for the receiving organization.  This is an exception to the general case
  -- where the shipping organization always figures out the transaction cost
  -- and populate the details rows for the receiving org.
  if ((i_txn_action_id = 21 and i_fob_point = 1 and l_to_org = i_org_id)
      OR
      (i_txn_action_id = 12 and i_fob_point = 2 and l_to_org = i_org_id)
      OR
      (i_txn_action_id = 3 and o_txn_qty < 0 and l_std_org = i_txn_org_id)) then
    l_compute_txn_cost := l_std_from_org;
    l_cost_type_id := 1;
  elsif ((i_txn_action_id = 21 and i_fob_point = 1 and l_from_org = i_org_id)
         OR
         (i_txn_action_id = 12 and i_fob_point = 2 and l_from_org = i_org_id)
         OR
         (i_txn_action_id = 3 and o_txn_qty < 0 and l_from_org = i_org_id))
        then
    l_compute_txn_cost := 2;
    l_cost_type_id := i_cost_type;
  else
    l_compute_txn_cost := 0;
  end if;

  -- compute transfer cost and compute transaction cost.
  if (l_compute_txn_cost > 0) then
    -- Figure out the transaction cost from the sending org.
    if (l_compute_txn_cost = 1) then
      l_stmt_num := 110;
      /* Exception block inserted for bug 1399079, (non costed items) */
      BEGIN
         select item_cost, -1
         into l_snd_txn_cost, l_from_layer_id
         from cst_item_costs
         where cost_type_id = l_cost_type_id
         and inventory_item_id = i_item_id
         /* and organization_id = l_from_org; : bugfix 3048258 */
         and organization_id = l_std_cost_org;
      EXCEPTION
         when no_data_found then
            l_snd_txn_cost := 0;
            l_from_layer_id := -1;
      END;

    else
      l_stmt_num := 115;
      select count(*) into l_mclacd_exists
      from mtl_cst_layer_act_cost_details
      where transaction_id = i_txn_id
      and organization_id = i_org_id
      and layer_id = l_from_layer;

      l_stmt_num :=120;
      if ((o_exp_flag = 1) and (l_mclacd_exists = 0)) then
        select item_cost, layer_id
        into l_snd_txn_cost, l_from_layer_id
        from cst_quantity_layers
        where organization_id = l_from_org
        and inventory_item_id = i_item_id
        and cost_group_id = l_from_cost_grp;

      else
        l_stmt_num := 130;

        select NVL(abs(sum(mclacd.actual_cost * mclacd.layer_quantity) / abs(o_txn_qty)),0)
        into l_snd_txn_cost
        from mtl_cst_layer_act_cost_details mclacd
        where transaction_id = i_txn_id
        and organization_id = i_org_id
        and layer_id = l_from_layer;

        l_from_layer_id := i_layer_id;
      end if;
    end if;

    -- Get the conversion_rate.
    -- receiving_currency = sending_currency * conversion_rate
    l_stmt_num := 140;
    get_snd_rcv_rate(i_txn_id, l_from_org, l_to_org,
         l_snd_sob_id, l_snd_curr, l_rcv_sob_id, l_rcv_curr,
         l_curr_type,
         l_conv_rate, l_conv_date, l_err_num, l_err_code,
         l_err_msg);
    if (l_err_num <> 0) then
      raise process_error;
    end if;

    -- Need to get UOM conversion
    -- l_snd_uom = l_um_rate * l_rcv_uom
    -- 1 Dozen = 12 * 1 each
    l_um_rate := inv_convert.inv_um_convert(i_item_id, NULL, 1,
                                            l_snd_uom, l_rcv_uom, NULL, NULL);

    -- Added for bug 2827548
    if (i_txn_action_id = 12 and i_fob_point = 2) then -- receiving txn for FOB receipt
      l_xfer_conv_rate := l_conv_rate;
    else
      l_xfer_conv_rate := 1;
    end if;

    -- the transfer cost is always in shipping UOM and currency
    -- For FOB receipt, need to convert the primary_quantity (in receiving UOM)
    -- to sending primary quantity.
    l_stmt_num := 150;
    Update mtl_material_transactions
    Set transfer_cost =
     (select decode(nvl(transfer_percentage, -999),-999, transfer_cost,
                   (transfer_percentage * l_snd_txn_cost *
        decode(i_txn_action_id, 12, abs(primary_quantity)/l_um_rate,
                    abs(primary_quantity)))*l_xfer_conv_rate/100) -- bug 2827548-added l_xfer_conv_rate
      from mtl_material_transactions
      where transaction_id = i_txn_id)
    where transaction_id = i_txn_id
       or (transaction_id = decode(i_txn_action_id,3,l_txn_update_id,-1));

    -- Get transfer cost and transportation cost from mmt which is in sending currency.
    l_stmt_num := 160;

    select nvl(transfer_cost,0), nvl(transportation_cost,0),
           decode(i_txn_action_id,12,(primary_quantity / l_um_rate),primary_quantity)
    into l_txfr_cost, l_trans_cost, l_snd_qty
    from mtl_material_transactions
    where transaction_id = i_txn_id;

    /* TPRICE: If the transfer pricing option is yes, set transfer credit to be zero */
    if (i_tprice_option <> 0) then
       l_txfr_cost := 0;
    end if;

    -- change for bug 2827548
    if (i_txn_action_id = 12 and i_fob_point = 2) then
      l_rcv_txn_cost := ( ((l_snd_txn_cost * abs(l_snd_qty)) * l_conv_rate / l_um_rate) +
                            l_txfr_cost + l_trans_cost) / abs(l_snd_qty);
      l_new_txn_cost := l_rcv_txn_cost;
    elsif ((i_txn_action_id = 12 and i_fob_point = 1) or (i_txn_action_id = 3 and o_txn_qty > 0)) then
      l_rcv_txn_cost := ( ((l_snd_txn_cost * abs(l_snd_qty)) + l_txfr_cost + l_trans_cost) *
                            l_conv_rate / l_um_rate) / abs(l_snd_qty);
      l_new_txn_cost := l_rcv_txn_cost;
    else
      l_new_txn_cost := (l_snd_txn_cost * abs(l_snd_qty) + l_txfr_cost +
                         l_trans_cost) / abs(l_snd_qty);
      l_rcv_txn_cost := l_new_txn_cost * l_conv_rate / l_um_rate;
    end if;
    if (i_txn_action_id<>12 or i_fob_point<>2) then
      l_trans_cost := l_trans_cost * l_conv_rate;
      l_txfr_cost := l_txfr_cost * l_conv_rate;
    end if;

    /* TPRICE: If the transfter pricing option is to treat the price as the incoming cost,
               insert price into MCTCD */
    if (i_tprice_option = 2) then
       l_rcv_txn_cost := i_txf_price;
       l_elemental_visible := 'N';
    end if;

    if (l_elemental_visible = 'Y') then
       if ((o_exp_flag = 1) and (l_mclacd_exists = 0)) then
          l_interorg_elem_exp_flag := 1;
       else
          l_interorg_elem_exp_flag := 0;
       end if;

       interorg_elemental_detail(i_org_id,i_txn_id,l_compute_txn_cost,
           l_cost_type_id, l_from_layer_id, i_item_id, l_interorg_elem_exp_flag,
           l_txn_update_id,l_from_org, l_to_org,
           l_snd_qty,l_txfr_cost,l_trans_cost,l_conv_rate,l_um_rate,
           i_user_id,i_login_id,i_req_id,i_prg_appl_id,i_prg_id,
           l_err_num,l_err_code,l_err_msg);
       if (l_err_num <> 0) then
         raise process_error;
       end if;
    else
       insert into mtl_cst_txn_cost_details (
          transaction_id,
          organization_id,
        cost_element_id,
        level_type,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        inventory_item_id,
        transaction_cost,
        new_average_cost,
        percentage_change,
        value_change)
          values (l_txn_update_id,
        l_to_org,
        1,
          1,
        sysdate,
              i_user_id,
              sysdate,
              i_user_id,
              i_login_id,
              i_req_id,
              i_prg_appl_id,
              i_prg_id,
              sysdate,
              i_item_id,
              l_rcv_txn_cost,
        0,
        0,
        0);
    END IF;

    /* If sending org is a standard costign org, then create layers in the receiving org, only
       after MCTCD is populated */
       if ((l_to_method IN (5,6)) and (l_from_method = 1)) then
             /* Bug #2352604, 2362306.
                Call create_layers when :
                        No Direct Interorg transfers! This is called for receiving transaction.
                        Intransit shipment, FOB shipment from std to LIFO
                        Intransit receipt, FOB receipt from std to LIFO
             */

   if(o_interorg_rec=1 and i_txn_action_id <> 3) then
             FND_FILE.PUT_LINE(FND_FILE.LOG,'Creating layers when sending org is std costing org');

             -- Fix for bug 1872444
             -- Populate l_to_layer before calling CSTPLENG.create_layers
             -- for direct interorg transactions
             -- Also, the second argument was changed from i_txn_id to
             -- l_txn_update_id

             if (i_txn_action_id = 3) then
                select nvl(layer_id,0) into l_to_layer from cst_quantity_layers
                where organization_id = l_to_org and inventory_item_id = i_item_id
                and cost_group_id = l_to_cost_grp;
             end if;

             if(l_debug = 'Y') then
                fnd_file.put_line(fnd_file.log, 'Calling createlayers for the std org' || i_org_id || ': interorg rec : '|| o_interorg_rec || ':txn_update_id :'|| l_txn_update_id );
             end if;


             CSTPLENG.create_layers(
                                  i_org_id,
                                  l_txn_update_id,
                                  l_to_layer,
                                  i_item_id,
                                  abs(o_txn_qty),
                                  i_cost_method,
                                  i_txn_src_type,
                                  i_txn_action_id,
                                  0,
                                  o_interorg_rec, --2280515 (anjgupta)
                                  i_cost_type,
                                  i_mat_ct_id,
                                  i_avg_rates_id,
                                  o_exp_flag,
                                  i_user_id,
                                  i_login_id,
                                  i_req_id,
                                  i_prg_appl_id,
                                  i_prg_id,
                                  l_err_num,
                                  l_err_code,
                                  l_err_msg);
  end if; -- Bug #2352604
    end if;

    -- Update the transaction cost column if appropriate.
    /* Begin changes and additions for bug 2827548 */
    Update mtl_material_transactions
    Set transaction_cost = l_new_txn_cost
    where transaction_id = i_txn_id;

    if (i_txn_action_id = 3) then
      Update mtl_material_transactions
      Set transaction_cost = l_rcv_txn_cost
      where transaction_id = l_txn_update_id;
    end if;

    -- Update the transaction_cost column for receipt txn w/ fob shipment
    -- in the receiving org's currency
    if (i_txn_action_id = 21 and i_fob_point = 1) then
      update mtl_material_transactions mmt
      set mmt.transaction_cost = l_rcv_txn_cost
      where mmt.transfer_transaction_id = i_txn_id
      and mmt.transaction_action_id = 12;
    -- Update the transaction_cost column for shipment txn w/ fob receipt
    -- in the sending org's currency
    elsif (i_txn_action_id = 12 and i_fob_point = 2) then
      update mtl_material_transactions mmt
      set mmt.transaction_cost = l_snd_txn_cost
      where mmt.transaction_id =
        (select mmt1.transfer_transaction_id
         from mtl_material_transactions mmt1
         where mmt1.transaction_id = i_txn_id)
      and mmt.transaction_action_id = 21
      and nvl(mmt.transaction_cost,0) = 0;
    end if;

    /* End changes for bug 2827548 */

    if (l_update_std = 1) then
       /*  the receiving org is standard exp. */
      l_stmt_num := 210;
      -- if the receiving org is std exp, copy the txn info
      -- into MCACD from MCTCD.

      insert into mtl_cst_actual_cost_details (
    transaction_id,
    organization_id,
        layer_id,
    cost_element_id,
    level_type,
    transaction_action_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    request_id,
    program_application_id,
    program_id,
    program_update_date,
    inventory_item_id,
    actual_cost,
    prior_cost,
    new_cost,
    insertion_flag,
    variance_amount,
    user_entered)
      select
    i_txn_id,
          l_std_org,
    -1,
          decode(l_elemental_visible,'Y',ctcd.cost_element_id,1),
          decode(l_elemental_visible,'Y',ctcd.level_type,1),
    i_txn_action_id,
          sysdate,
          i_user_id,
          sysdate,
          i_user_id,
          i_login_id,
          i_req_id,
          i_prg_appl_id,
          i_prg_id,
          sysdate,
          ctcd.inventory_item_id,
          decode(l_elemental_visible,'Y',ctcd.transaction_cost,l_rcv_txn_cost),
          NULL,
          NULL,
          'N',
          0,
          'N'
      FROM mtl_cst_txn_cost_details ctcd
      WHERE ctcd.transaction_id = l_txn_update_id
      AND ctcd.organization_id = l_std_org
      /* AND ctcd.transaction_cost >= 0 */; -- modified for bug #3835412

      if (l_std_org = i_txn_org_id or i_txn_action_id = 3) then
        l_stmt_num := 220;

        update mtl_material_transactions mmt
        set (last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      actual_cost) =
        (select sysdate,
      i_user_id,
      i_login_id,
      i_req_id,
      i_prg_appl_id,
      i_prg_id,
      sysdate,
      nvl(sum(actual_cost),0)
      from mtl_cst_actual_cost_details cacd
      where cacd.transaction_id = l_txn_update_id
      and cacd.organization_id = l_std_org
    and cacd.layer_id = -1)
    where mmt.transaction_id = l_txn_update_id;
  end if;
 /* begin: fix for bug 3679625 for DIRECT TRANSFERS - on the sending transaction
  * of a direct transfer where receiving org is standard costing org and item/sub
  * is expense in receiving org, we need to insert into MCACD from MCTCD and update MMT.
  */
 elsif (i_txn_action_id = 3 and l_std_org = i_txfr_org_id) then

    l_stmt_num := 230;
    select decode(inventory_asset_flag, 'Y', 0, 1)
    into l_txfr_std_exp
    from mtl_system_items
    where inventory_item_id = i_item_id
    and organization_id = l_std_org;

    l_stmt_num :=  240;
    select transfer_transaction_id
    into l_txfr_txn_id
    from mtl_material_transactions mmt
    where mmt.transaction_id = i_txn_id;

    l_stmt_num := 250;
    select decode(l_txfr_std_exp,1,1,decode(asset_inventory,1,0,1))
    into l_txfr_std_exp
    from mtl_secondary_inventories msi
        ,mtl_material_transactions mmt
    where mmt.transaction_id = l_txfr_txn_id
    and mmt.organization_id = l_std_org
    and msi.organization_id = l_std_org
    and msi.secondary_inventory_name = mmt.subinventory_code;

    if (l_txfr_std_exp = 1) then
    l_stmt_num :=  260;
    FND_FILE.PUT_LINE(FND_FILE.LOG, to_char(l_stmt_num) || ' insert into MCACD from MCTCD with l_txfr_std_exp = 1');
    insert into mtl_cst_actual_cost_details (
          transaction_id,
          organization_id,
          layer_id,
          cost_element_id,
          level_type,
          transaction_action_id,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          request_id,
          program_application_id,
          program_id,
          program_update_date,
          inventory_item_id,
          actual_cost,
          prior_cost,
          new_cost,
          insertion_flag,
          variance_amount,
          user_entered)
    select
          l_txfr_txn_id,
          l_std_org,
          -1,
          decode(l_elemental_visible,'Y',ctcd.cost_element_id,1),
          decode(l_elemental_visible,'Y',ctcd.level_type,1),
          i_txn_action_id,
          sysdate,
          i_user_id,
          sysdate,
          i_user_id,
          i_login_id,
          i_req_id,
          i_prg_appl_id,
          i_prg_id,
          sysdate,
          ctcd.inventory_item_id,
          decode(l_elemental_visible,'Y',ctcd.transaction_cost,l_rcv_txn_cost),
          NULL,
          NULL,
          'N',
          0,
          'N'
		FROM mtl_cst_txn_cost_details ctcd
		WHERE ctcd.transaction_id = l_txn_update_id
		AND ctcd.organization_id = l_std_org
		/* AND ctcd.transaction_cost >= 0 */; -- modified for bug #3835412

		FND_FILE.PUT_LINE(FND_FILE.LOG, to_char(l_stmt_num) || ' update MMT from MCACD with l_txfr_std_exp = 1');
		update mtl_material_transactions mmt
		set (last_update_date,
			last_updated_by,
			last_update_login,
			request_id,
			program_application_id,
			program_id,
			program_update_date,
			actual_cost) =
        	(select sysdate,
			i_user_id,
			i_login_id,
			i_req_id,
			i_prg_appl_id,
			i_prg_id,
			sysdate,
			nvl(sum(actual_cost),0)
			from mtl_cst_actual_cost_details cacd
			where cacd.transaction_id = l_txn_update_id
			and cacd.organization_id = l_std_org
			and cacd.layer_id = -1)
		where mmt.transaction_id = l_txn_update_id;
    end if;
 /* end bug 3679625 */
  end if;
end if;

/* begin bug 3761538
 * for intransit interorg transfers where receiving org is standard costing org
 * and item is expense in receiving org, insert into MCACD from MCTCD on both the
 * sending and receiving transactions and update MMT on the receiving transaction.
 */
if (l_to_std_exp = 1) then

	if (i_txn_org_id = l_std_org) then
    	select transfer_transaction_id
    	into l_txfr_txn_id
    	from mtl_material_transactions mmt
    	where mmt.transaction_id = i_txn_id;
	end if;

	l_stmt_num :=  270;
	FND_FILE.PUT_LINE(FND_FILE.LOG, to_char(l_stmt_num) || ' insert into MCACD from MCTCD with l_to_std_exp = 1');
	insert into mtl_cst_actual_cost_details (
          transaction_id,
          organization_id,
          layer_id,
          cost_element_id,
          level_type,
          transaction_action_id,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          request_id,
          program_application_id,
          program_id,
          program_update_date,
          inventory_item_id,
          actual_cost,
          prior_cost,
          new_cost,
          insertion_flag,
          variance_amount,
          user_entered)
  select
          i_txn_id,
          l_std_org,
          -1,
          ctcd.cost_element_id,
          ctcd.level_type,
          i_txn_action_id,
          sysdate,
          i_user_id,
          sysdate,
          i_user_id,
          i_login_id,
          i_req_id,
          i_prg_appl_id,
          i_prg_id,
          sysdate,
          ctcd.inventory_item_id,
          ctcd.transaction_cost,
          NULL,
          NULL,
          'N',
          0,
          'N'
	FROM mtl_cst_txn_cost_details ctcd
	WHERE ctcd.transaction_id = decode(i_txn_org_id, l_std_org, l_txfr_txn_id, l_txn_update_id) -- sending txn id
	AND ctcd.organization_id = l_std_org
	/* AND ctcd.transaction_cost >= 0 */; -- modified for bug #3835412

	-- update mmt if this is the receiving transaction id
	if (i_txn_org_id = l_std_org) then
		FND_FILE.PUT_LINE(FND_FILE.LOG, to_char(l_stmt_num) || ' update MMT from MCACD with l_to_std_exp = 1');
		update mtl_material_transactions mmt
		set (last_update_date,
			last_updated_by,
			last_update_login,
			request_id,
			program_application_id,
			program_id,
			program_update_date,
			actual_cost) =
        	(select sysdate,
			i_user_id,
			i_login_id,
			i_req_id,
			i_prg_appl_id,
			i_prg_id,
			sysdate,
			nvl(sum(actual_cost),0)
			from mtl_cst_actual_cost_details cacd
			where cacd.transaction_id = l_txn_update_id
			and cacd.organization_id = l_std_org
			and cacd.layer_id = -1)
		where mmt.transaction_id = l_txn_update_id;
	end if;
end if;
/* end bug 3761538 */

  EXCEPTION
    when process_error then
      o_err_num := l_err_num;
      o_err_code := l_err_code;
      o_err_msg := l_err_msg;
    when moh_rules_error then
      o_err_num := 9999;
      o_err_code := 'CST_RULES_ERROR';
      FND_MESSAGE.set_name('BOM', 'CST_RULES_ERROR');
      o_err_msg := FND_MESSAGE.Get;
    when others then
      rollback;
      o_err_num := SQLCODE;
      o_err_msg := 'CSTPLVCP.interorg (' || to_char(l_stmt_num) ||
                   '): '
       || substr(SQLERRM, 1,200);

END interorg;

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
)IS
  l_snd_sob_id	NUMBER;
  l_snd_curr	VARCHAR2(10);
  l_rcv_sob_id	NUMBER;
  l_rcv_curr	VARCHAR2(10);
  l_curr_type   VARCHAR2(30);
  l_conv_rate	NUMBER;
  l_conv_date	DATE;
  l_txn_date	DATE;
  l_err_num		NUMBER;
  l_err_code		VARCHAR2(240);
  l_err_msg		VARCHAR2(240);
  l_stmt_num		NUMBER;

BEGIN
  -- initialize local variables
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';

  l_stmt_num := 10;

  select ledger_id
  into l_snd_sob_id
  /*from org_organization_definitions */
  from cst_acct_info_v
  where organization_id = i_from_org;

  l_stmt_num := 20;

  select currency_code
  into l_snd_curr
  from gl_sets_of_books
  where set_of_books_id = l_snd_sob_id;

  l_stmt_num := 30;

  select ledger_id
  into l_rcv_sob_id
  /*from org_organization_definitions*/
  from cst_acct_info_v
  where organization_id = i_to_org;

  l_stmt_num := 40;

  select currency_code
  into l_rcv_curr
  from gl_sets_of_books
  where set_of_books_id = l_rcv_sob_id;

  l_stmt_num := 50;

  select currency_conversion_type, TRUNC(transaction_date)
  into l_curr_type, l_txn_date
  from mtl_material_transactions
  where transaction_id = i_txn_id;

  if (l_curr_type is NULL) then
    FND_PROFILE.get('CURRENCY_CONVERSION_TYPE', l_curr_type);
  end if;

  if (l_rcv_curr <> l_snd_curr) then
    l_stmt_num := 60;

 /* --- replacing gl table hit by gl currency api

    select conversion_rate, conversion_date
    into l_conv_rate, l_conv_date
    from gl_daily_conversion_rates
    where set_of_books_id = l_rcv_sob_id
    and from_currency_code = l_snd_curr
    and conversion_type = l_curr_type
    and conversion_date =
	  (select max(conversion_date)
	   from gl_daily_conversion_rates
	   where set_of_books_id = l_rcv_sob_id
	   and from_currency_code = l_snd_curr
	   and conversion_type = l_curr_type
	   and conversion_date <= l_txn_date);
 -------------------------------------------------------------*/

   l_conv_rate := gl_currency_api.get_rate(l_rcv_sob_id,l_snd_curr,l_txn_date,
                                           l_curr_type);
  else
    l_conv_rate := 1;
  end if;

  o_snd_sob_id := l_snd_sob_id;
  o_snd_curr := l_snd_curr;
  o_rcv_sob_id := l_rcv_sob_id;
  o_rcv_curr := l_rcv_curr;
  o_curr_type := l_curr_type;
  o_conv_rate := l_conv_rate;
  o_conv_date := l_conv_date;

  EXCEPTION

 when gl_currency_api.NO_RATE then
 rollback;
 O_err_num := 9999;
 O_err_code := 'CST_NO_GL_RATE';
 FND_MESSAGE.set_name('BOM', 'CST_NO_GL_RATE');
 O_err_msg := FND_MESSAGE.Get;

    when others then
      rollback;
      o_err_num := SQLCODE;
      o_err_msg := 'CSTPLVCP.get_snd_rcv_rate (' || to_char(l_stmt_num) ||
                   '): '
		   || substr(SQLERRM, 1,200);

END get_snd_rcv_rate;

PROCEDURE get_snd_rcv_uom(
  I_ITEM_ID	IN	NUMBER,
  I_FROM_ORG	IN	NUMBER,
  I_TO_ORG	IN	NUMBER,
  O_SND_UOM	OUT NOCOPY	VARCHAR2,
  O_RCV_UOM	OUT NOCOPY	VARCHAR2,
  O_Err_Num	OUT NOCOPY	NUMBER,
  O_Err_Code	OUT NOCOPY	VARCHAR2,
  O_Err_Msg	OUT NOCOPY	VARCHAR2
)IS
  l_err_num		NUMBER;
  l_err_code		VARCHAR2(240);
  l_err_msg		VARCHAR2(240);
  l_stmt_num		NUMBER;

BEGIN
  -- initialize local variables
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';

  l_stmt_num := 10;

  select primary_uom_code
  into o_snd_uom
  from mtl_system_items
  where organization_id = i_from_org
  and inventory_item_id = i_item_id;

  l_stmt_num := 20;

  select primary_uom_code
  into o_rcv_uom
  from mtl_system_items
  where organization_id = i_to_org
  and inventory_item_id = i_item_id;

  EXCEPTION
    when others then
      rollback;
      o_err_num := SQLCODE;
      o_err_msg := 'CSTPLVCP.get_snd_rcv_uom (' || to_char(l_stmt_num) ||
                   '): '
		   || substr(SQLERRM, 1,200);

END get_snd_rcv_uom;

FUNCTION standard_cost_org(
  I_ORG_ID	IN	NUMBER
) RETURN INTEGER IS
  l_ret_val	NUMBER;
BEGIN
  select decode(primary_cost_method,1,1,0)
  into l_ret_val
  from mtl_parameters
  where organization_id = i_org_id;

  return l_ret_val;
END standard_cost_org;

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
  o_err_msg		OUT NOCOPY VARCHAR2)
IS
  l_err_num     NUMBER;
  l_err_code    VARCHAR2(240);
  l_err_msg     VARCHAR2(240);
  l_stmt_num    NUMBER;
  process_error EXCEPTION;

  l_movh_cnt	NUMBER;
  l_rcv_movh	NUMBER;
  l_rcv_qty	NUMBER;
  l_trp_trf	NUMBER;
  l_from_cost_org  NUMBER; /* bugfix 3048258 */
BEGIN

  -- Insert detail elemental cost into mctcd.
  -- Based on the from_org :
  -- * If from_org is a standard org (l_compute_txn_cost=1),
  --   insert detail cost from cicd
  -- * If from_org is an avg org (l_compute_txn_cost=2),
  --   insert detail cost from clcd
  -- Need to convert the cost into the receiving org cost in receiving org
  -- currenct and UOM.
  -- Suppose that : * This level material in from org is 12 USD with UOM of DZ.
  --		    * Receiving org is in SGD and UOM of EA
  --                * i_conv_rate = 2 (from USD to SGD),
  --                * i_um_rate = 12 (from DZ to EA).
  --		    * In the mctcd of receiving org, we insert :
  --	              this level material cost as : 12 * 2 / 12 = 2 SGD/EA
  if (i_compute_txn_cost = 1) then
    l_stmt_num := 10;

    /* Added for bugfix 3048258 */
    select cost_organization_id
      into l_from_cost_org
      from mtl_parameters
     where organization_id = i_from_org;

    insert into mtl_cst_txn_cost_details (
      transaction_id,
      organization_id,
      cost_element_id,
      level_type,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      inventory_item_id,
      transaction_cost,
      new_average_cost,
      percentage_change,
      value_change)
    select
      i_txn_update_id,
      i_to_org,
      cost_element_id,
      level_type,
      sysdate,
      i_user_id,
      sysdate,
      i_user_id,
      i_login_id,
      i_req_id,
      i_prg_appl_id,
      i_prg_id,
      sysdate,
      i_item_id,
      sum(item_cost)*i_conv_rate/i_um_rate,
      0,
      0,
      0
    from cst_item_cost_details cicd
    where cicd.cost_type_id = i_cost_type_id
      and cicd.inventory_item_id = i_item_id
      /* and cicd.organization_id = i_from_org : bugfix 3048258 */
      and cicd.organization_id = l_from_cost_org
    group by cicd.cost_element_id,cicd.level_type;

  elsif (i_exp_flag = 1) then
    l_stmt_num := 15;

    insert into mtl_cst_txn_cost_details (
      transaction_id,
      organization_id,
      cost_element_id,
      level_type,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      inventory_item_id,
      transaction_cost,
      new_average_cost,
      percentage_change,
      value_change)
      select
      i_txn_update_id,
      i_to_org,
      cost_element_id,
      level_type,
      sysdate,
      i_user_id,
      sysdate,
      i_user_id,
      i_login_id,
      i_req_id,
      i_prg_appl_id,
      i_prg_id,
      sysdate,
      i_item_id,
      clcd.item_cost*i_conv_rate/i_um_rate,
      0,
      0,
      0
    from cst_layer_cost_details clcd
    where clcd.layer_id = i_from_layer_id;

  else

    l_stmt_num := 20;
    insert into mtl_cst_txn_cost_details (
      transaction_id,
      organization_id,
      cost_element_id,
      level_type,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      inventory_item_id,
      transaction_cost,
      new_average_cost,
      percentage_change,
      value_change)
    select
      i_txn_update_id,
      i_to_org,
      cost_element_id,
      level_type,
      sysdate,
      i_user_id,
      sysdate,
      i_user_id,
      i_login_id,
      i_req_id,
      i_prg_appl_id,
      i_prg_id,
      sysdate,
      i_item_id,
      NVL((sum(mclacd.actual_cost * abs(mclacd.layer_quantity)) / abs(i_snd_qty)),0)*i_conv_rate/i_um_rate, -- modified for bug #3835412
      0,
      0,
      0
    from mtl_cst_layer_act_cost_details mclacd
    where organization_id = i_org_id
    and transaction_id = i_txn_id
    group by cost_element_id,level_type;

  end if;

  l_stmt_num := 30;
  -- Find out if there is already exist this level material overhead in mctcd.
  select count(*)
  into l_movh_cnt
  from mtl_cst_txn_cost_details mctcd
  where mctcd.transaction_id = i_txn_update_id
    and mctcd.organization_id = i_to_org
    and mctcd.inventory_item_id = i_item_id
    and mctcd.level_type = 1
    and mctcd.cost_element_id = 2;

  if (l_movh_cnt > 0) then
    l_stmt_num := 40;
    select NVL(mctcd.transaction_cost,0)
    into l_rcv_movh
    from mtl_cst_txn_cost_details mctcd
    where mctcd.transaction_id = i_txn_update_id
      and mctcd.organization_id = i_to_org
      and mctcd.inventory_item_id = i_item_id
      and mctcd.level_type = 1
      and mctcd.cost_element_id = 2;
  else
    l_rcv_movh := 0;
  end if;

  -- Convert the i_snd_qty in the receiving org UOM
  l_rcv_qty := abs(i_snd_qty) * i_um_rate;

    -- The transportation and transfer cost is a total cost in sending currency.
    -- Thus we need to convert it to recv currency.
  /* change for bug 2827548 - moved currency conversion outside of this function */
  l_trp_trf := (i_txfr_cost+i_trans_cost);

  -- Add in the trp and trf cost as the this level material overhead
  l_rcv_movh := (l_rcv_movh*l_rcv_qty + l_trp_trf)/l_rcv_qty;

  -- The new material overhead (l_rcv_movh) includes :
  -- * This level material overhead of the sending org item cost,
  -- * Transportation and transfer cost
  -- The new material overhead cost has been converted into recv org currency
  -- and UOM.
  -- If there already exist movh in mctcd, then update mctcd with new movhd
  -- value. Otherwise insert the new movhd into mctcd
  if (l_movh_cnt > 0) then
    l_stmt_num := 50;
    update mtl_cst_txn_cost_details mctcd
    set mctcd.transaction_cost = l_rcv_movh
    where mctcd.transaction_id = i_txn_update_id
      and mctcd.organization_id = i_to_org
      and mctcd.inventory_item_id = i_item_id
      and mctcd.level_type = 1
      and mctcd.cost_element_id = 2;
  elsif (l_rcv_movh > 0) then
    l_stmt_num := 60;
    insert into mtl_cst_txn_cost_details (
      transaction_id,
      organization_id,
      cost_element_id,
      level_type,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      inventory_item_id,
      transaction_cost,
      new_average_cost,
      percentage_change,
      value_change)
    values (
      i_txn_update_id,
      i_to_org,
      2,
      1,
      sysdate,
      i_user_id,
      sysdate,
      i_user_id,
      i_login_id,
      i_req_id,
      i_prg_appl_id,
      i_prg_id,
      sysdate,
      i_item_id,
      l_rcv_movh,
      0,
      0,
      0);
  end if;

  EXCEPTION
    when process_error then
      o_err_num := l_err_num;
      o_err_code := l_err_code;
      o_err_msg := l_err_msg;
    when others then
      rollback;
      o_err_num := SQLCODE;
      o_err_msg := 'CSTPLVCP.interorg_elemental_detail (' || to_char(l_stmt_num)
		   || '): ' || substr(SQLERRM, 1,200);


END interorg_elemental_detail;


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
I_ORG_ID	IN	NUMBER,
I_TXN_ID	IN	NUMBER,
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
)IS

-- this cursor is to find out all the related
-- borrow transactions for a specific payback
-- transaction
cursor c_payback_txn(c_cur_txn_id number) is
select pbp.borrow_transaction_id,
      pbp.payback_quantity
 from pjm_borrow_paybacks pbp
 where pbp.payback_transaction_id = c_cur_txn_id;

-- this cursor is to find out all the mcacd data
-- for a specific transaction_id
cursor c_mcacd_data (c_transaction_id number)is
select mcacd.transaction_id,
       mcacd.cost_element_id,
       mcacd.level_type,
       mcacd.inventory_item_id,
       mcacd.actual_cost,
       mcacd.prior_cost,
       mcacd.new_cost,
       mcacd.layer_id
   from mtl_cst_actual_cost_details mcacd
   where mcacd.transaction_id = c_transaction_id
     and mcacd.layer_id = i_to_layer;

type t_cst_element is table of number
index by binary_integer;

l_temp_element_cost t_cst_element;
l_level_type		NUMBER;
l_total_bp_qty  	NUMBER;
l_err_num		NUMBER;
l_err_code		VARCHAR2(240);
l_err_msg		VARCHAR2(240);
l_stmt_num		NUMBER;
cst_no_hook_allowed     EXCEPTION;

BEGIN
-- initialize local variables
l_err_num := 0;
l_err_code := '';
l_err_msg := '';

l_stmt_num := 10;

-- initialize array with 0

for l_index_counter in 1..10 loop
    l_temp_element_cost(l_index_counter):=0;
end loop;

-- check for actual cost hook used.
l_stmt_num := 15;

if i_hook = 1 then
   raise cst_no_hook_allowed;
end if;

-- loop through all the payaback txn to find the borrowing cost
-- from MCACD and sum it up.
l_stmt_num := 20;

l_total_bp_qty := 0;

for c_payback_rec in c_payback_txn(i_txn_id) loop
   for c_mcacd_rec in c_mcacd_data(c_payback_rec.borrow_transaction_id) LOOP
       if c_mcacd_rec.level_type =1 then
          l_temp_element_cost(c_mcacd_rec.cost_element_id):=
          l_temp_element_cost(c_mcacd_rec.cost_element_id) +
          c_mcacd_rec.actual_cost * abs(c_payback_rec.payback_quantity);
       elsif c_mcacd_rec.level_type = 2 then
          l_temp_element_cost(c_mcacd_rec.cost_element_id + 5):=
          l_temp_element_cost(c_mcacd_rec.cost_element_id + 5) +
          c_mcacd_rec.actual_cost * abs(c_payback_rec.payback_quantity);
       end if;
   end loop; -- end looping c_mcacd_rec
   l_total_bp_qty := l_total_bp_qty + abs(c_payback_rec.payback_quantity);
end loop; -- end looping c_payback_rec

-- do a division here to find out the average cost
for l_index_counter in 1..10 loop
   l_temp_element_cost(l_index_counter):= l_temp_element_cost(l_index_counter)
	       			          / l_total_bp_qty;
end loop;

--  populate MCTCD from here
for l_index_counter in 1..10 loop
   if l_index_counter < 6 then
      l_level_type := 1;
   else
      l_level_type := 2;
   end if;

--  populate mctcd
if (i_hook = 0) then  -- if no hook is used then populate mctcd
   if l_temp_element_cost(l_index_counter) <> 0 then
      l_stmt_num := 25;
      insert into mtl_cst_txn_cost_details(
	   TRANSACTION_ID,
	   ORGANIZATION_ID,
	   COST_ELEMENT_ID,
	   LEVEL_TYPE,
	   LAST_UPDATE_DATE,
	   LAST_UPDATED_BY,
	   CREATION_DATE,
	   CREATED_BY,
	   LAST_UPDATE_LOGIN,
	   REQUEST_ID,
	   PROGRAM_APPLICATION_ID,
	   PROGRAM_ID,
	   PROGRAM_UPDATE_DATE,
	   INVENTORY_ITEM_ID,
	   TRANSACTION_COST)
       values(
	      i_txn_id,
	      i_org_id,
	      decode(mod(l_index_counter,5),0,5,mod(l_index_counter,5)),
	      l_level_type,
	      sysdate,
	      i_user_id,
	      sysdate,
	      i_user_id,
	      i_login_id,
	      i_req_id,
	      i_prg_appl_id,
	      i_prg_id,
	      sysdate,
	      i_item_id,
	      l_temp_element_cost(l_index_counter));
       end if; -- end for checking existence of elemental cost
    end if;    -- end for checking for cost hook
end loop;  -- end for looping 10 elements

EXCEPTION
when cst_no_hook_allowed then
     rollback;
     o_err_num := 24020;
     o_err_code := substr('CSTPLVCP.borrow_cost('
	         ||to_char(l_stmt_num)
	         || '): '
	         || l_err_msg
	         || '.',1,240);
     fnd_message.set_name('BOM', 'CST_NO_HOOK_ALLOWED');
     o_err_msg := fnd_message.get;
     o_err_msg := substr(o_err_msg,1,240);
when others then
     rollback;
     o_err_num := SQLCODE;
     o_err_msg := 'CSTPLVCP.borrow_cost (' || to_char(l_stmt_num) ||
	          '): '
	          || substr(SQLERRM, 1,200);

END borrow_cost;

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
--   9/05/00     Dieu-Thuong Le          Bugfix 1393484: For payback trxn,
--                                       MCLACD.actual_cost for return('from')
--                                       sub should be the same as layer_cost.

==========================================================================*/

procedure sub_transfer(
I_ORG_ID		IN NUMBER,
I_TXN_ID		IN NUMBER,
I_LAYER_ID		IN NUMBER,
I_COST_TYPE		IN NUMBER,
I_ITEM_ID		IN NUMBER,
I_TXN_QTY		IN NUMBER,
I_TXN_ACTION_ID 	IN NUMBER,
I_TXN_SRC_TYPE		IN NUMBER,
I_NEW_COST		IN NUMBER,
I_HOOK		        IN NUMBER,
I_COST_METHOD		IN NUMBER,
I_TXFR_LAYER_ID 	IN NUMBER,
I_CITW_FLAG		IN NUMBER,
I_FLOW_SCHEDULE	        IN NUMBER,
I_MAT_CT_ID		IN NUMBER,
I_AVG_RATES_ID		IN NUMBER,
I_USER_ID		IN NUMBER,
I_LOGIN_ID      	IN NUMBER,
I_REQ_ID		IN NUMBER,
I_PRG_APPL_ID	        IN NUMBER,
I_PRG_ID		IN NUMBER,
O_Err_Num		OUT NOCOPY NUMBER,
O_Err_Code		OUT NOCOPY VARCHAR2,
O_Err_Msg		OUT NOCOPY VARCHAR2
) IS
l_layer_chg		NUMBER;
l_exp_item		NUMBER;
l_exp1	        	NUMBER;
l_exp2		        NUMBER;
l_from_layer		NUMBER;
l_to_layer		NUMBER;
l_from_exp		NUMBER;
l_to_exp		NUMBER;
l_from_qty		NUMBER;
l_to_qty                NUMBER;
l_ret_val		NUMBER;
l_no_update_qty	        NUMBER;
l_new_cost		NUMBER;
l_txf_txn_id            NUMBER;
l_txn_type_id	        NUMBER;
l_cur_cost              NUMBER;
l_interorg_rec          NUMBER;
l_txn_cost_exist        NUMBER;
l_inv_layer_id          NUMBER;
l_err_num		NUMBER;
l_err_code		VARCHAR2(240);
l_err_msg		VARCHAR2(240);
l_debug                 VARCHAR2(80);
l_stmt_num		NUMBER;
l_exp_flag              NUMBER;
l_src_id                NUMBER;/* For bug 4523417*/
l_src_number            VARCHAR2(240);/*For Bug4523417*/
process_error	        EXCEPTION;
cst_no_hook_allowed     EXCEPTION;

BEGIN
-- initialize local variables
l_err_num := 0;
l_err_code := '';
l_err_msg := '';
l_new_cost := i_new_cost;
l_interorg_rec := '';
l_exp_flag := 0;
l_txn_cost_exist := 0;
l_debug := FND_PROFILE.VALUE('MRP_DEBUG');

/********************************************************************
** Figure out layer_change flag                                   **
** A layer change occurs when we transfer material between        **
** two different layers within the same org.                      **
********************************************************************/
l_stmt_num := 10;
select transaction_type_id
   into l_txn_type_id
   from mtl_material_transactions
   where transaction_id = i_txn_id;

if ((i_txfr_layer_id is not NULL) and (i_txfr_layer_id <> i_layer_id)) then
   l_layer_chg := 1;
else
   l_layer_chg := 0;
end if;

-- check if item is an expense item.
l_stmt_num := 20;

select decode(inventory_asset_flag, 'Y',0,1)
   into l_exp_item
   from mtl_system_items
   where inventory_item_id = i_item_id
     and organization_id = i_org_id;

-- check if subinventory is an expense sub.
l_stmt_num := 30;

select decode(asset_inventory,1,0,1)
   into l_exp1
   from mtl_secondary_inventories msi,
        mtl_material_transactions mmt
   where msi.secondary_inventory_name = mmt.subinventory_code
     and msi.organization_id = i_org_id
     and mmt.transaction_id = i_txn_id
     and mmt.organization_id = i_org_id;

l_stmt_num := 40;

-- the nature of project sub is the same as project job, except
-- asset common to expense project job issue case.
--
-- Common	Proj Sub	Proj Job
--  asset	 asset		 asset
--  asset	 asset *	 exp *		<= special case
--  exp	 asset		 asset
--  exp	 exp		 exp

-- we divide into three cases to figure out the type of txfr sub.
--  1. common issue to wip
--  2. normal subinventory txfr
--  3. others

l_stmt_num := 50;

if (i_citw_flag = 1) then
   if(i_flow_schedule = 1) then
   -- cfm then use wip_flow_schedules
   -- class_type 1 and 3 : asset job, 4 : exp job
      select decode(wac.class_type, 1, 0,
	       		            3, 0,
			            4, decode(l_exp1, 1, 1, 0))
         into l_exp2
         from mtl_material_transactions mmt,
	      wip_flow_schedules wfs,
	      wip_accounting_classes wac
         where mmt.transaction_id = i_txn_id
           and mmt.organization_id = i_org_id
           and wfs.organization_id = i_org_id
           and wfs.wip_entity_id = mmt.transaction_source_id
           and wac.organization_id = i_org_id
           and wac.class_code = wfs.class_code;
   else
   -- non cfm then use wip_discrete_jobs
   -- class_type 1 and 3 : asset job, 4 : exp job
      select decode(wac.class_type, 1, 0,
	   		            3, 0,
			            4, decode(l_exp1, 1, 1, 0))
         into l_exp2
         from mtl_material_transactions mmt,
	      wip_discrete_jobs wdj,
	      wip_accounting_classes wac
         where mmt.transaction_id = i_txn_id
           and mmt.organization_id = i_org_id
           and wdj.organization_id = i_org_id
           and wdj.wip_entity_id = mmt.transaction_source_id
           and wac.organization_id = i_org_id
           and wac.class_code = wdj.class_code;
   end if;
/* Changes for VMI. Adding planning transfer transaction */
elsif (i_txn_action_id IN (2,5,28)) then
   select decode(asset_inventory,1,0,1)
      into l_exp2
      from mtl_secondary_inventories msi,
           mtl_material_transactions mmt
      where msi.secondary_inventory_name = mmt.transfer_subinventory
        and msi.organization_id = i_org_id
        and mmt.transaction_id = i_txn_id
        and mmt.organization_id = i_org_id;
elsif (i_txn_action_id = 55) then
   l_exp2 := l_exp1;
else
   l_exp2 := 0;
end if;

/* Changes for VMI. Adding planning transfer transaction */
if (i_txn_action_id in (2,5,28,55,21)) then
   l_from_layer := i_layer_id;
   l_to_layer := i_txfr_layer_id;
   l_from_exp := l_exp1;
   l_to_exp := l_exp2;
   l_from_qty := i_txn_qty;
   l_to_qty := -1 * i_txn_qty;
else
   l_from_layer := i_txfr_layer_id;
   l_to_layer := i_layer_id;
   l_from_exp := l_exp2;
   l_to_exp := l_exp1;
   l_from_qty :=-1 * i_txn_qty;
   l_to_qty := i_txn_qty;
end if;

-- Just in case i_txfr_layer_id is NULL, always set from and to layer
-- to layer_id for same layer transfers.
if (l_layer_chg = 0) then
   l_from_layer := i_layer_id;
   l_to_layer := i_layer_id;
end if;

-- Do not allow actual cost hook if it's a payback transaction or if
-- it is an asset to asset transfer for the same layer.
-- Error out.

l_stmt_num := 60;
if (i_hook = 1) and
   ((l_layer_chg = 0 and l_from_exp = 0 and l_to_exp = 0)
   or l_txn_type_id = 68) then
      raise cst_no_hook_allowed;
end if;

l_stmt_num := 65;
-- Check for existing mctcd.  For example, if it's a payback transaction
-- mctcd will be created before sub_transfer is called.

   select count(*)
      into l_txn_cost_exist
      from mtl_cst_txn_cost_details
      where transaction_id = i_txn_id
        and organization_id = i_org_id;

l_stmt_num := 70;
-- get latest layer id regardless of the remaining layer quantity
-- or if the cost method is FIFO or LIFO

      select nvl(max(inv_layer_id), 0)
         into l_inv_layer_id
         from cst_inv_layers
         where layer_id = l_from_layer;

 if l_debug = 'Y' then
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Transaction: ' || to_char(i_txn_id)
                    ||',layer change: '|| to_char(l_layer_chg));
   FND_FILE.PUT_LINE(FND_FILE.LOG,'From layer: '|| to_char(l_from_layer)
                               || 'From qty: '|| to_char(l_from_qty));
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'To layer: '|| to_char(l_to_layer)
                                || 'To qty: '|| to_char(l_to_qty));
 end if;

/************************************************************
** Compute actual cost for the from subinventory           **
************************************************************/

/* Set l_exp_flag for the from subinventory.  Set flag to 1 if it's
   an expense item or if the 'from' sub is an expense sub.          */

   if l_exp_item = 1 or
      l_from_exp = 1 then
         l_exp_flag := 1;
   end if;

-- If from subinventory is an expense sub, cost at latest layer cost
-- and do not consume inventory layer. Exception: Exp to asset will be
-- handled when we process to subinventory.
-- Asset to asset subtransfer in the same layer should be costed using
-- the FIFO/LIFO consumption logic, but will not actually consume
-- inventory layer.

if (l_from_exp = 1) then
 if (l_layer_chg = 1 or
     (l_layer_chg = 0 and l_to_exp = 1)) then
      if i_hook = 0 then     -- insert MCACD only if there is no cost hook

   l_stmt_num := 80;

   if l_inv_layer_id = 0 then        -- no layer cost
      insert into mtl_cst_actual_cost_details(
	 transaction_id,
	 organization_id,
	 layer_id,
	 cost_element_id,
	 level_type,
	 transaction_action_id,
	 last_update_date,
	 last_updated_by,
	 creation_date,
	 created_by,
	 last_update_login,
	 request_id,
	 program_application_id,
	 program_id,
	 program_update_date,
	 inventory_item_id,
	 actual_cost,
	 prior_cost,
	 new_cost,
	 insertion_flag,
	 variance_amount,
	 user_entered)
       values(
	 i_txn_id,
	 i_org_id,
	 l_from_layer,
	 1,
	 1,
	 i_txn_action_id,
	 sysdate,
	 i_user_id,
	 sysdate,
	 i_user_id,
	 i_login_id,
	 i_req_id,
	 i_prg_appl_id,
	 i_prg_id,
	 sysdate,
	 i_item_id,
	 0,
	 0,
	 0,
	 'N',
	 0,
	 'N');
  else           -- has layer cost
     insert into mtl_cst_actual_cost_details(
	    transaction_id,
	    organization_id,
	    layer_id,
	    cost_element_id,
	    level_type,
	    transaction_action_id,
	    last_update_date,
	    last_updated_by,
	    creation_date,
	    created_by,
	    last_update_login,
	    request_id,
	    program_application_id,
	    program_id,
	    program_update_date,
	    inventory_item_id,
	    actual_cost,
	    prior_cost,
	    new_cost,
	    insertion_flag,
	    variance_amount,
	    user_entered)
	  select
	    i_txn_id,
	    i_org_id,
	    l_from_layer,
	    cilcd.cost_element_id,
	    cilcd.level_type,
	    i_txn_action_id,
	    sysdate,
	    i_user_id,
	    sysdate,
	    i_user_id,
	    i_login_id,
	    i_req_id,
	    i_prg_appl_id,
	    i_prg_id,
	    sysdate,
	    i_item_id,
	    cilcd.layer_cost,
	    0,
	    NULL,
	    'N',
	    0,
	    'N'
	  from cst_inv_layer_cost_details cilcd
	  where layer_id = l_from_layer
	    and inv_layer_id = l_inv_layer_id;
    end if;     --- i checking layer cost and inserting MCACD

   if l_debug = 'Y' then
      FND_FILE.PUT_LINE(FND_FILE.LOG,'MCACD inserted for trxn '
                         || to_char(i_txn_id)
                         || ':' || to_char(l_stmt_num));
   end if;

    -- update MMT with cost information
       l_stmt_num := 85;

	  CSTPAVCP.update_mmt(
		i_org_id,
		i_txn_id,
		-1,                --  i_txfr_txn_id
		i_layer_id,
		0,                 --  i_cost_update
		i_user_id,
		i_login_id,
		i_req_id,
		i_prg_appl_id,
		i_prg_id,
		l_err_num,
		l_err_code,
		l_err_msg);
	   if (l_err_num <> 0) then
	      raise process_error;
	   end if;
   end if;    -- end having cost hook
  end if;  -- layer_chg of 1
 else    -- from asset sub
   if (l_to_exp = 0 and l_layer_chg = 0) then
      l_interorg_rec := 3;    -- compute layer cost and insert mclacd only
                              -- otherwise, compute cost and consume layers
   /* Added the following if condition to create an inventory layer
      for bug 4523417
   */

     if(l_inv_layer_id = 0) then
      l_stmt_num := 86;
        SELECT  cst_inv_layers_s.nextval
         INTO   l_inv_layer_id
         FROM   dual;
      l_stmt_num :=87;
        SELECT transaction_source_id
         INTO   l_src_id
         FROM   mtl_material_transactions
         WHERE  transaction_id = i_txn_id;
      l_stmt_num :=88;
        l_src_number := CSTPLENG.GET_SOURCE_NUMBER(i_txn_id,i_txn_src_type,l_src_id);
      l_stmt_num :=89;
       INSERT
        INTO    cst_inv_layers (
                        layer_id,
                        inv_layer_id,
                        organization_id,
                        inventory_item_id,
                        creation_quantity,
                        layer_quantity,
                        layer_cost,
                        create_transaction_id,
                        transaction_source_id,
                        transaction_action_id,
                        transaction_source_type_id,
                        transaction_source,
                        unburdened_cost,
                        burden_cost,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date)
                VALUES (l_from_layer,
                        l_inv_layer_id,
                        i_org_id,
                        i_item_id,
                        0,
                        0,
                        0,
                        i_txn_id,
                        l_src_id,
                        i_txn_action_id,
                        i_txn_src_type,
                        l_src_number,
                        0,
                        0,
                        sysdate,
                        i_user_id,
                        sysdate,
                        i_user_id,
                        i_login_id,
                        i_req_id,
                        i_prg_appl_id,
                        i_prg_id,
                        sysdate);

        IF (l_debug = 'Y') THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Inventory layer created');
        END IF;

    /* Delete cost details for the inventory layer from CILCD.
       No rows should be present. Just a safety check
    */

    DELETE
     FROM  cst_inv_layer_cost_details
     WHERE inv_layer_id = l_inv_layer_id;


    INSERT
    INTO cst_inv_layer_cost_details (
                        layer_id,
                        inv_layer_id,
                        level_type,
                        cost_element_id,
                        layer_cost,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date)
                VALUES( l_from_layer,
                        l_inv_layer_id,
                        1,
                        1,
                        0,
                        sysdate,
                        i_user_id,
                        sysdate,
                        i_user_id,
                        i_login_id,
                        i_req_id,
                        i_prg_appl_id,
                        i_prg_id,
                        sysdate );
     end if;
   end if;

   l_stmt_num := 90;

   l_new_cost := CSTPLENG.compute_layer_actual_cost(
		     i_org_id,
		     i_cost_method,
		     i_txn_id,
		     l_from_layer,   --i_layer_id,
		     i_hook,
		     i_cost_type,
		     i_mat_ct_id,
		     i_avg_rates_id,
		     i_item_id,
		     l_from_qty,             -- i_txn_qty
		     i_txn_action_id,
		     i_txn_src_type,
		     l_interorg_rec,
		     l_exp_flag,      -- i_exp_flag
		     i_user_id,
		     i_login_id,
		     i_req_id,
		     i_prg_appl_id,
		     i_prg_id,
		     l_err_num,
		     l_err_code,
		     l_err_msg);
   if (l_err_num <> 0) then
       raise process_error;
   end if;

   if l_debug = 'Y' then
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Compute_layer_actual_cost completed for txn '
                         || to_char(i_txn_id)
                         || ':' || to_char(l_stmt_num));
   end if;
   /* Borrow Payback Enhancement Bug#2325290 */
   if (l_txn_type_id = 68) and (l_layer_chg = 0) then

   if l_debug = 'Y' then
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Calling payback_variance() ');
   end if;

     payback_variance(
     i_org_id,
     i_txn_id,
     i_txn_qty,
     i_user_id,
     i_login_id,
     i_req_id,
     i_prg_appl_id,
     i_prg_id,
     i_item_id,
     i_hook,
     l_from_layer,
     l_err_num,
     l_err_code,
     l_err_msg);

end if;



/* Bug Fix 1393484 */
   -- Payback transaction:
   -- mclacd of from sub is populated with the borrow cost by compute_layer_actual_cost
   -- due to the existence of mctcd with borrow cost.
   -- However, we want to store the current inv layer cost instead of borrow cost
   -- for the from sub.

   l_stmt_num := 92;

   if (l_txn_type_id = 68) and (i_hook <> 1) and (l_layer_chg = 1)  then
      update mtl_cst_layer_act_cost_details mclacd
         set actual_cost = layer_cost
             where mclacd.transaction_id = i_txn_id
               and mclacd.organization_id = i_org_id
               and mclacd.layer_id = l_from_layer;
   end if;
/* End bug fix 1393484 */

   -- update layer average cost
   if l_interorg_rec = 3 then
      l_no_update_qty := 1;
   else
      l_no_update_qty := 0;
   end if;

   l_stmt_num := 95;
   CSTPLENG.calc_layer_average_cost(
	  i_org_id,
	  i_txn_id,
	  l_from_layer,
	  i_cost_type,
	  i_item_id,
	  l_from_qty,              -- i_txn_qty
	  i_txn_action_id,
	  i_hook,
	  0,                              -- i_no_update_mmt
	  l_no_update_qty,
	  i_user_id,
	  i_login_id,
	  i_req_id,
	  i_prg_appl_id,
	  i_prg_id,
	  l_err_num,
	  l_err_code,
	  l_err_msg);
   if (l_err_num <> 0) then
      raise process_error;
   end if;

   if l_debug = 'Y' then
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Calc_layer_average_cost completed for txn '
                         || to_char(i_txn_id)
                         || ':' || to_char(l_stmt_num));
   end if;
end if;      -- end from asset sub

/************************************************************
** Compute inventory layers for the to  subinventory       **
************************************************************/

/* If it's an expense item, there is no cost impact on 'to' sub.
   Three scenarios where we need to process cost of asset item for 'to' sub:
   1. Layer change and to expense sub: insert MCACD using 'from' layer's MCACD.
      No layer consumption or layer cost impact.
   2. Layer change and to asset sub: create MCTCD using 'from' layer's MCACD
      then call API's to create new layer and to insert MCACD for 'to' layer
   3. No layer change and to asset sub: create MCTCD using latest layer cost
      of 'from' layer then call API's to create new layer and to insert
      MCACD for 'to' layer.
*/

/*-------------------------------------------------------------
  Scenario 1: Layer change and transfer to an expense sub
  ------------------------------------------------------------*/
/* Set l_exp_flag for the 'to' subinventory   */
   if l_exp_item = 1 or
      l_to_exp = 1  then
         l_exp_flag := 1;
   else
      l_exp_flag := 0;
   end if;

l_stmt_num := 100;

if (l_exp_item = 0 and l_layer_chg = 1 and l_to_exp = 1 and i_hook = 0) then
      insert into mtl_cst_actual_cost_details(
         transaction_id,
         organization_id,
         layer_id,
         cost_element_id,
         level_type,
         transaction_action_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         request_id,
         program_application_id,
         program_id,
         program_update_date,
         inventory_item_id,
         actual_cost,
         prior_cost,
         new_cost,
         insertion_flag,
         variance_amount,
         user_entered)
       select
         i_txn_id,
         i_org_id,
         l_to_layer,
         mcacd.cost_element_id,
         mcacd.level_type,
         i_txn_action_id,
         sysdate,
         i_user_id,
         sysdate,
         i_user_id,
         i_login_id,
         i_req_id,
         i_prg_appl_id,
         i_prg_id,
         sysdate,
         i_item_id,
         mcacd.actual_cost,
         mcacd.actual_cost,
         mcacd.actual_cost,
         'N',
         0,
         'N'
       from mtl_cst_actual_cost_details mcacd
       where transaction_id = i_txn_id
         and organization_id = i_org_id
         and layer_id = l_from_layer;

     if l_debug = 'Y' then
          FND_FILE.PUT_LINE(FND_FILE.LOG,'MCTCD inserted for txn  '
                   || to_char(i_txn_id)
                   || ',to layer '|| to_char(l_from_layer)
                   || ',stmt ' || to_char(l_stmt_num));
     end if;
end if;    -- end of scenario 1

/*------------------------------------------------------------
  Scenario 2: Layr change and transfer to an asset sub
  ------------------------------------------------------------*/
l_stmt_num := 110;

-- If cost hook is on, no need to populate MCTCD because
-- compute_layer_actual_cost will look for user-populated MCACD.

if (l_exp_item = 0 and l_layer_chg = 1 and l_to_exp = 0) then
   if i_hook = 0  then     -- no cost hook
      select count(*)                 -- check for existing mctcd
	 into l_txn_cost_exist
	 from mtl_cst_txn_cost_details
	 where transaction_id = i_txn_id
	  and organization_id = i_org_id;
       if l_txn_cost_exist = 0 then     -- populate mctcd if it does not exist
	  insert into mtl_cst_txn_cost_details(
	     transaction_id,
	     organization_id,
	     cost_element_id,
	     level_type,
	     last_update_date,
	     last_updated_by,
	     creation_date,
	     created_by,
	     last_update_login,
	     request_id,
	     program_application_id,
	     program_id,
	     program_update_date,
	     inventory_item_id,
	     transaction_cost)
	   select
	     i_txn_id,
	     i_org_id,
	     mcacd.cost_element_id,
	     mcacd.level_type,
	     sysdate,
	     i_user_id,
	     sysdate,
	     i_user_id,
	     i_login_id,
	     i_req_id,
	     i_prg_appl_id,
	     i_prg_id,
	     sysdate,
	     i_item_id,
	     mcacd.actual_cost
	   from mtl_cst_actual_cost_details mcacd
	   where transaction_id = i_txn_id
	     and organization_id = i_org_id
	     and layer_id = l_from_layer;

       if l_debug = 'Y' then
          FND_FILE.PUT_LINE(FND_FILE.LOG,'MCTCD inserted for txn  '
                   || to_char(i_txn_id)
                   || ',to layer '|| to_char(l_from_layer)
                   || ',stmt ' || to_char(l_stmt_num));
       end if;

     end if;    -- end checking for mctcd
   end if;    -- end checking for cost hook

   -- create inventory layer

   l_stmt_num := 120;

   CSTPLENG.create_layers(
		     i_org_id,
		     i_txn_id,
		     l_to_layer,
		     i_item_id,
		     l_to_qty,
		     i_cost_method,
		     i_txn_src_type,
		     i_txn_action_id,
		     i_hook,
		     NULL,            -- i_interorg_rec
		     i_cost_type,
		     i_mat_ct_id,
		     i_avg_rates_id,
		     l_exp_flag,      -- i_exp_flag
		     i_user_id,
		     i_login_id,
		     i_req_id,
		     i_prg_appl_id,
		     i_prg_id,
		     l_err_num,
		     l_err_code,
		     l_err_msg);
   if (l_err_num <> 0) then
      raise process_error;
   end if;

       if l_debug = 'Y' then
          FND_FILE.PUT_LINE(FND_FILE.LOG,'created_layer called for txn  '
                   || to_char(i_txn_id)
                   || ',to layer '|| to_char(l_to_layer)
                   || ',stmt ' || to_char(l_stmt_num));
       end if;

   l_stmt_num := 125;

   CSTPLENG.calc_layer_average_cost(
          i_org_id,
          i_txn_id,
          l_to_layer,
          i_cost_type,
          i_item_id,
          l_to_qty,              -- i_txn_qty
          i_txn_action_id,
          i_hook,
          0,                              -- i_no_update_mmt
          0,                              -- i_no_update_qty
          i_user_id,
          i_login_id,
          i_req_id,
          i_prg_appl_id,
          i_prg_id,
          l_err_num,
          l_err_code,
          l_err_msg);
   if (l_err_num <> 0) then
      raise process_error;
   end if;

       if l_debug = 'Y' then
          FND_FILE.PUT_LINE(FND_FILE.LOG,'calc_layer_avg_cost called for txn  '
                   || to_char(i_txn_id)
                   || ',to layer '|| to_char(l_to_layer)
                   || ',stmt ' || to_char(l_stmt_num));
       end if;

end if;      -- end scenario 2

/*----------------------------------------------------------------
  Scenario 3: No layer change and transfer of asset item from
  expense sub to asset sub.
  ----------------------------------------------------------------*/

l_stmt_num := 130;

if (l_exp_item = 0 and l_layer_chg = 0 and l_from_exp = 1 and l_to_exp = 0)  then
   if i_hook = 0 and l_txn_cost_exist = 0  then    -- no cost hook and no mctcd
      if l_inv_layer_id = 0  then           -- no layer cost
	  insert into mtl_cst_txn_cost_details(
	     transaction_id,
	     organization_id,
	     cost_element_id,
	     level_type,
	     last_update_date,
	     last_updated_by,
	     creation_date,
	     created_by,
	     last_update_login,
	     request_id,
	     program_application_id,
	     program_id,
	     program_update_date,
	     inventory_item_id,
	     transaction_cost)
	   values(
             i_txn_id,
	     i_org_id,
	     1,          -- material cost element
	     1,          -- this level
	     sysdate,
	     i_user_id,
	     sysdate,
	     i_user_id,
	     i_login_id,
	     i_req_id,
	     i_prg_appl_id,
	     i_prg_id,
	     sysdate,
	     i_item_id,
	     0);
      else        -- has layer cost
          insert into mtl_cst_txn_cost_details(
             transaction_id,
             organization_id,
             cost_element_id,
             level_type,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login,
             request_id,
             program_application_id,
             program_id,
             program_update_date,
             inventory_item_id,
             transaction_cost)
           select
             i_txn_id,
             i_org_id,
	     cilcd.cost_element_id,
	     cilcd.level_type,
	     sysdate,
	     i_user_id,
	     sysdate,
	     i_user_id,
	     i_login_id,
	     i_req_id,
	     i_prg_appl_id,
	     i_prg_id,
	     sysdate,
	     i_item_id,
	     cilcd.layer_cost
	   from cst_inv_layer_cost_details cilcd
           where layer_id = l_from_layer
             and inv_layer_id = l_inv_layer_id;
      end if;     -- end checking for layer cost

       if l_debug = 'Y' then
          FND_FILE.PUT_LINE(FND_FILE.LOG,'MCTCD inserted for txn  '
                   || to_char(i_txn_id)
                   || ',to layer '|| to_char(l_to_layer)
                   || ',stmt ' || to_char(l_stmt_num));
       end if;

   end if;     -- end for no cost hook and no mctcd

   -- create inventory layer

   l_stmt_num := 140;

   CSTPLENG.create_layers(
		     i_org_id,
		     i_txn_id,
		     l_to_layer,
		     i_item_id,
		     l_to_qty,
		     i_cost_method,
		     i_txn_src_type,
		     i_txn_action_id,
		     i_hook,
		     NULL,            -- i_interorg_rec
		     i_cost_type,
		     i_mat_ct_id,
		     i_avg_rates_id,
		     l_exp_flag,      -- i_exp_flag
		     i_user_id,
		     i_login_id,
		     i_req_id,
		     i_prg_appl_id,
		     i_prg_id,
		     l_err_num,
		     l_err_code,
		     l_err_msg);
   if (l_err_num <> 0) then
      raise process_error;
   end if;

       if l_debug = 'Y' then
          FND_FILE.PUT_LINE(FND_FILE.LOG,'created_layer called for txn  '
                   || to_char(i_txn_id)
                   || ',to layer '|| to_char(l_to_layer)
                   || ',stmt ' || to_char(l_stmt_num));
       end if;

   l_stmt_num := 150;

   CSTPLENG.calc_layer_average_cost(
          i_org_id,
          i_txn_id,
          l_to_layer,
          i_cost_type,
          i_item_id,
          l_to_qty,              -- i_txn_qty
          i_txn_action_id,
          i_hook,
          0,                              -- i_no_update_mmt
          0,                              -- i_no_update_qty
          i_user_id,
          i_login_id,
          i_req_id,
          i_prg_appl_id,
          i_prg_id,
          l_err_num,
          l_err_code,
          l_err_msg);
   if (l_err_num <> 0) then
      raise process_error;
   end if;

       if l_debug = 'Y' then
          FND_FILE.PUT_LINE(FND_FILE.LOG,'calc_layer_avg_cost called for txn  '
                   || to_char(i_txn_id)
                   || ',to layer '|| to_char(l_to_layer)
                   || ',stmt ' || to_char(l_stmt_num));
       end if;

end if;      -- end scenario 3

-- Update the recv side mmt for subinventory transfer
-- It updates actual_cost, new_cost, prior_cost and variance
-- of the receiving with the shipment side values
/* Bug 3613854
 * regardless of whether those values are null in the receiving side,
 * and from mcacd instead of mmt to account for transfers within
 * and across cost groups.
 */
l_stmt_num := 160;

/* Changes for VMI. Adding planning transfer transaction */
if (i_txn_action_id IN (2,5,28,55)) then

   select transfer_transaction_id
      into l_txf_txn_id
      from mtl_material_transactions
   where transaction_id = i_txn_id;

   l_stmt_num := 170;

   update mtl_material_transactions mmt1
      set (last_update_date,
         last_updated_by,
         last_update_login,
         request_id,
         program_application_id,
         program_id,
         program_update_date,
         actual_cost,
         prior_cost,
         new_cost,
         variance_amount) =
           (select sysdate,
               i_user_id,
               i_login_id,
               i_req_id,
               i_prg_appl_id,
               i_prg_id,
               sysdate,
               SUM(NVL(mcacd.actual_cost, 0)),
               SUM(NVL(mcacd.prior_cost, 0)),
               SUM(NVL(mcacd.new_cost, 0)),
               SUM(NVL(mcacd.variance_amount, 0))
            from mtl_cst_actual_cost_details mcacd
            where mcacd.transaction_id = i_txn_id
              and mcacd.layer_id = l_to_layer)
         where mmt1.transaction_id = l_txf_txn_id
           and mmt1.primary_quantity > 0;
end if;

EXCEPTION
   when cst_no_hook_allowed then
        rollback;
        o_err_num := 24030;
        o_err_code := substr('CSTPLVCP.sub_transfer('
	            ||to_char(l_stmt_num)
	            || '): '
	            || l_err_msg
	            || '.',1,240);
        fnd_message.set_name('BOM', 'CST_NO_HOOK_ALLOWED');
        o_err_msg := fnd_message.get;
        o_err_msg := substr(o_err_msg,1,240);

   when process_error then
        o_err_num := l_err_num;
        o_err_code := l_err_code;
        o_err_msg := l_err_msg;

   when others then
        rollback;
        o_err_num := SQLCODE;
        o_err_msg := 'CSTPLVCP.sub_transfer (' || to_char(l_stmt_num)
        	     || '): '
	             || substr(SQLERRM, 1,240);
END sub_transfer;

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
)IS

-- this cursor is to find out all the related
-- borrow transactions for a specific payback
-- transaction
cursor c_payback_txn(c_cur_txn_id number) is
select pbp.borrow_transaction_id,
      pbp.payback_quantity
 from pjm_borrow_paybacks pbp
 where pbp.payback_transaction_id = c_cur_txn_id;

-- this cursor is to find out all the mcacd data
-- for a specific transaction_id
cursor c_mclacd_data (c_transaction_id number)is
select mclacd.transaction_id,
       mclacd.cost_element_id,
       mclacd.level_type,
       mclacd.inventory_item_id,
       mclacd.actual_cost,
       mclacd.layer_id,
       mclacd.layer_quantity
   from mtl_cst_layer_act_cost_details mclacd
   where mclacd.transaction_id = c_transaction_id
   and mclacd.layer_id = i_from_layer;

type t_cst_element is table of number
index by binary_integer;

l_temp_borrow_cost t_cst_element;
l_temp_payback_cost t_cst_element;
l_level_type		NUMBER;
l_total_borrow_qty  NUMBER;
l_count             NUMBER;
l_loan_quantity     NUMBER;
l_variance          NUMBER;
mclacd_variance     NUMBER;
l_err_num		NUMBER;
l_err_code		VARCHAR2(240);
l_err_msg		VARCHAR2(240);
l_stmt_num		NUMBER;
cst_no_hook_allowed     EXCEPTION;

BEGIN
-- initialize local variables
l_err_num := 0;
l_err_code := '';
l_err_msg := '';

l_stmt_num := 10;

-- initialize array with 0

for l_index_counter in 1..10 loop
    l_temp_borrow_cost(l_index_counter):=0;
    l_temp_payback_cost(l_index_counter):=0;
end loop;

-- check for actual cost hook used.
l_stmt_num := 15;

if i_hook = 1 then
   raise cst_no_hook_allowed;
end if;

-- loop through all the payaback txn to find the borrowing cost
-- from MCACD and sum it up.
l_stmt_num := 20;

l_total_borrow_qty := 0;

for c_payback_rec in c_payback_txn(i_txn_id) loop
   for c_mclacd_rec in c_mclacd_data(c_payback_rec.borrow_transaction_id) LOOP
       if c_mclacd_rec.level_type =1 then
          l_temp_borrow_cost(c_mclacd_rec.cost_element_id):=
          l_temp_borrow_cost(c_mclacd_rec.cost_element_id) +
          c_mclacd_rec.actual_cost * abs(c_mclacd_rec.layer_quantity);
       elsif c_mclacd_rec.level_type = 2 then
          l_temp_borrow_cost(c_mclacd_rec.cost_element_id + 5):=
          l_temp_borrow_cost(c_mclacd_rec.cost_element_id + 5) +
          c_mclacd_rec.actual_cost * abs(c_mclacd_rec.layer_quantity);
       end if;
   end loop; -- end looping c_mclacd_rec
   select loan_quantity
   into l_loan_quantity
   from pjm_borrow_transactions
   where borrow_transaction_id = c_payback_rec.borrow_transaction_id;

   l_total_borrow_qty := l_total_borrow_qty + abs(l_loan_quantity);
end loop; -- end looping c_payback_rec

   fnd_file.put_line(fnd_file.log, 'borrow quantity' || l_total_borrow_qty);

l_stmt_num := 30;
/* Figure out the payback cost */
for c_mclacd_rec in c_mclacd_data(i_txn_id) LOOP
       if c_mclacd_rec.level_type =1 then
          l_temp_payback_cost(c_mclacd_rec.cost_element_id):=
          l_temp_payback_cost(c_mclacd_rec.cost_element_id) +
          c_mclacd_rec.actual_cost * abs(c_mclacd_rec.layer_quantity);
       elsif c_mclacd_rec.level_type = 2 then
          l_temp_payback_cost(c_mclacd_rec.cost_element_id + 5):=
          l_temp_payback_cost(c_mclacd_rec.cost_element_id + 5) +
          c_mclacd_rec.actual_cost * abs(c_mclacd_rec.layer_quantity);
       end if;
end loop; -- end looping c_mcacd_rec

l_stmt_num := 40;

-- do a division here to find out the borrow and payback unit cost
for l_index_counter in 1..10 loop
   l_temp_payback_cost(l_index_counter):= l_temp_payback_cost(l_index_counter)
	       			          / abs(i_txn_qty);
   l_temp_borrow_cost(l_index_counter):= l_temp_borrow_cost(l_index_counter)
	       			          / l_total_borrow_qty;
end loop;

l_stmt_num := 50;

for l_index_counter in 1..10 loop
   if l_index_counter < 6 then
      l_level_type := 1;
   else
      l_level_type := 2;
   end if;

           select count(*)
           into l_count
           from mtl_cst_layer_act_cost_details mcacd
           where mcacd.level_type = l_level_type
           and mcacd.cost_element_id = decode(mod(l_index_counter,5),0,5,mod(l_index_counter,5))
           and mcacd.transaction_id = i_txn_id
           and mcacd.layer_id = i_from_layer;

           l_stmt_num := 60;

          if (l_count) <> 0 then

          --payback varaince
          l_variance := l_temp_payback_cost(l_index_counter) - l_temp_borrow_cost(l_index_counter);

          --variance to be updated in mclacd
          mclacd_variance := l_variance * abs(i_txn_qty) / l_count;

          update mtl_cst_layer_act_cost_details mcacd
          set mcacd.payback_variance_amount = mclacd_variance
          where mcacd.transaction_id = i_txn_id
          and mcacd.cost_element_id = decode(mod(l_index_counter,5),0,5,mod(l_index_counter,5))
          and mcacd.level_type = l_level_type
          and mcacd.layer_id = i_from_layer;
          end if;
end loop;

EXCEPTION
when cst_no_hook_allowed then
     rollback;
     o_err_num := 24020;
     o_err_code := substr('CSTPLVCP.payback_variance('
	         ||to_char(l_stmt_num)
	         || '): '
	         || l_err_msg
	         || '.',1,240);
     fnd_message.set_name('BOM', 'CST_NO_HOOK_ALLOWED');
     o_err_msg := fnd_message.get;
     o_err_msg := substr(o_err_msg,1,240);
when others then
     rollback;
     o_err_num := SQLCODE;
     o_err_msg := 'CSTPLVCP.payback_variance (' || to_char(l_stmt_num) ||
	          '): '
	          || substr(SQLERRM, 1,200);

END payback_variance;

/* ===========================================================
   OPM INVCONV  umoogala  Process-Discrete trasnfers Enh
   This procedure computes cost for a logical receipt in
   receiving organizations for a process discrete transfer
   ===========================================================*/

PROCEDURE Cost_Logical_itr_receipt(
  I_ORG_ID	IN	NUMBER,
  I_TXN_ID	IN 	NUMBER,
  I_COST_METHOD IN	NUMBER,
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
) IS

  l_err_num	NUMBER;
  l_err_code	VARCHAR2(240);
  l_err_msg	VARCHAR2(240);
  l_stmt_num	NUMBER;
  process_error	EXCEPTION;
  l_txn_update_id NUMBER;
  l_compute_txn_cost NUMBER;
  l_from_org	NUMBER;
  l_to_org	NUMBER;
  l_from_cost_grp NUMBER;
  l_to_cost_grp	NUMBER;
  l_cost_type_id NUMBER;
  l_snd_txn_cost	NUMBER;
  l_rcv_txn_cost	NUMBER;
  l_new_txn_cost        NUMBER;
  l_txn_cost	NUMBER;
  l_txfr_cost	NUMBER;
  l_trans_cost	NUMBER;
  l_std_from_org	NUMBER;
  l_std_to_org		NUMBER;
  l_std_org		NUMBER;
  l_std_cost_org        NUMBER;
  l_std_exp		NUMBER;
  l_update_std		NUMBER;
  l_snd_sob_id		NUMBER;
  l_snd_curr		VARCHAR2(10);
  l_rcv_sob_id		NUMBER;
  l_rcv_curr		VARCHAR2(10);
  l_curr_type		VARCHAR2(30);
  l_conv_rate		NUMBER;
  l_conv_date		DATE;
  l_snd_uom		VARCHAR2(3);
  l_rcv_uom		VARCHAR2(3);
  l_snd_qty		NUMBER;
  l_count		NUMBER;
-- item cost history stuff
  l_transfer_layer_id   NUMBER;
  l_transfer_layer_qty  NUMBER;
  l_which_org           NUMBER;
  l_which_cst_grp       NUMBER;
-- item cost history stuff
-- elemental visibility
  l_movh                NUMBER;
  l_movh_cost           NUMBER;
  l_rec_movh_cost       NUMBER;
  l_mctcd_ovhd          NUMBER;
  l_from_layed	        NUMBER;
  l_elemental_visible   varchar2(1);
-- elemental visibility
  l_um_rate             NUMBER;
  l_return_status       VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(240);
  l_earn_moh            NUMBER;
  moh_rules_error       EXCEPTION;

  l_to_std_exp			NUMBER;
  l_txfr_std_exp		NUMBER;

  l_from_method         NUMBER;
  l_to_method           NUMBER;
  l_from_layer          NUMBER;
  l_to_layer            NUMBER;

  l_procedure_name      VARCHAR2(60);

BEGIN
  -- initialize local variables
  l_procedure_name := 'Cost_Logical_itr_receipt';
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';
  l_update_std := 0;
  l_snd_qty := o_txn_qty;
  l_std_exp := 0;

  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, l_procedure_name || ' <<<');
  END IF;

  l_earn_moh := 1;
  l_return_status := fnd_api.g_ret_sts_success;
  l_msg_count := 0;

  l_txfr_std_exp := 0;
  l_to_std_exp := 0;
  l_elemental_visible := 'N';


  -- Figure the from and to org for this transaction.
  l_stmt_num := 1;
  if (i_txn_action_id IN (21,22)) then
    l_from_org := i_txn_org_id;
    l_to_org := i_txfr_org_id;
    l_from_cost_grp := i_cost_grp_id;
    l_to_cost_grp := i_txfr_cost_grp;
  elsif (i_txn_action_id = 12) then
    l_from_org := i_txfr_org_id;
    l_to_org := i_txn_org_id;
    l_from_cost_grp := i_txfr_cost_grp;
    l_to_cost_grp := i_cost_grp_id;
  elsif (i_txn_action_id =3 and o_txn_qty <0) then
    l_from_org := i_txn_org_id;
    l_to_org := i_txfr_org_id;
    l_from_cost_grp := i_cost_grp_id;
    l_to_cost_grp := i_txfr_cost_grp;
  else
    l_from_org := i_txfr_org_id;
    l_to_org := i_txn_org_id;
    l_from_cost_grp := i_txfr_cost_grp;
    l_to_cost_grp := i_cost_grp_id;
  end if;

  l_stmt_num := 2;
  select primary_cost_method
  into l_from_method
  from mtl_parameters
  where organization_id = l_from_org;

  l_stmt_num := 3;
  select primary_cost_method
  into l_to_method
  from mtl_parameters
  where organization_id = l_to_org;

  --
  -- Bug 5702988: This flag was set to 1 in cmllcw.lpc when receiving
  -- sub is expense sub. For fob shipment, we have to treat subinv as
  -- asset sub. Just go by item flag only.
  -- This flag is being passed to create_layers procedure and
  -- incorrect accounting (MOH not earned) was being done.
  --
  -- We have to overwrite this flag here as it was done in
  -- interorg procedure for discrete/discrete orgs.
  -- Comments from discrete code:
  -- If the transaction organization id is not the organization id of this
  -- cost worker then we have to make sure this transaction record in mmt
  -- does not get updated. Most likely this is an intrasit interorg transaction
  -- and we are processing either the shipping or the receiving side. For the
  -- same reason we cannot rely on the expense flag since it is based on
  -- the current record's subinventory code.
  --
  if (i_txn_action_id = 22 or i_txn_action_id = 15)
  then
    select decode(inventory_asset_flag, 'Y',0,1)
      into o_exp_flag
      from mtl_system_items
     where inventory_item_id = i_item_id
       and organization_id = i_org_id;
  end if;

  -- item cost history stuff
  --
  -- For p-d xfers, in Avg Cost processor Org will always be Average Costin Org.
  -- Shipment to Std Orgs are being processed by Std Cost processor.
  --
  if( ( (i_txn_action_id = 21) and (i_fob_point = 1) and (l_std_to_org = 0) ) OR
      ( (i_txn_action_id = 12) and (i_fob_point = 1) and (l_std_to_org = 0) ) OR
      ( (i_txn_action_id = 21) and (i_fob_point = 2) and (l_std_from_org = 0) ) OR
      ( (i_txn_action_id = 12) and (i_fob_point = 2) and (l_std_to_org = 0) ) ) then

    l_which_org := l_to_org;
    l_which_cst_grp := i_cost_grp_id;

    if i_org_id = l_which_org then
        l_stmt_num := 10;
        UPDATE mtl_material_transactions mmt
        SET TRANSFER_PRIOR_COSTED_QUANTITY =
        (SELECT
                layer_quantity
        FROM	cst_quantity_layers cql
        WHERE	cql.organization_id = l_which_org
        AND	cql.inventory_item_id = i_item_id
        AND	cql.cost_group_id = l_which_cst_grp)
        WHERE mmt.transaction_id = i_txn_id
        AND EXISTS (
                        SELECT 'X'
                        FROM cst_quantity_layers cql
                        WHERE cql.organization_id = l_which_org
                        AND   cql.inventory_item_id = i_item_id
                        AND   cql.cost_group_id = l_which_cst_grp);

        IF SQL%ROWCOUNT = 0 THEN
          l_stmt_num := 20;
          update mtl_material_transactions mmt
                 set TRANSFER_PRIOR_COSTED_QUANTITY = 0
          where  mmt.transaction_id = i_txn_id;
        END IF;
    end if;
  end if;
  -- End of item cost history

  --
  -- Got rid of big chunck of code for standard costing org.
  -- For p-d xfers, in Avg Cost processor Org will always be Average Costin Org.
  -- Shipment to Std Orgs are being processed by Std Cost processor.
  --

  l_stmt_num := 30;
  SELECT nvl(transportation_cost,0)
    INTO l_trans_cost
    FROM mtl_material_transactions
   WHERE transaction_id = i_txn_id;

  --
  -- No need for any UOM or currency conversion as it is already done
  -- while creating MMT row for this logical transactions.
  -- For details refer to: INV_LOGICAL_TRANSACTIONS_PUB.create_opm_disc_logical_trx
  --

  -- For process to discrete transfers all qtys and costs are properly converted to the
  -- owning orgs units.
  -- So, i_txf_price and l_trans_cost are in base currency and txn_qty is in primary qty
  --

  /* INVCONV Bug#5461814 ANTHIYAG 17-Aug-2006 Start */
  ---l_rcv_txn_cost := ((i_txf_price * abs(o_txn_qty)) + l_trans_cost) / abs(o_txn_qty);
  if ((i_txn_action_id = 12 and i_fob_point = 2) or (i_txn_action_id = 3 and o_txn_qty > 0)) then
    l_rcv_txn_cost := ((i_txf_price * abs(o_txn_qty))) / abs(o_txn_qty);
  else
    l_rcv_txn_cost := ((i_txf_price * abs(o_txn_qty)) + l_trans_cost) / abs(o_txn_qty);
  end if;
  /* INVCONV Bug#5461814 ANTHIYAG 17-Aug-2006 End */

  -- The following are considered interorg receipt transactions.
  -- These are transactions where ownership changes and the current org
  -- is the receiving org.
  if ((i_txn_action_id = 3 and o_txn_qty > 0) OR
      (i_txn_action_id = 15) OR
      (i_txn_action_id = 12 and i_fob_point = 2))
     then
    o_interorg_rec := 1;
  else
    o_interorg_rec := 0;
  end if;

  IF g_debug = 'Y' THEN
     fnd_file.put_line(fnd_file.log, 'TxnOrg: ' || i_txn_org_id || ' Item: ' || i_item_id);
     fnd_file.put_line(fnd_file.log, 'fromOrg: ' || l_from_org || ' toOrg: ' || l_to_org);
     fnd_file.put_line(fnd_file.log, 'fromCG: ' || l_from_cost_grp || ' toCG: ' || l_to_cost_grp);
     fnd_file.put_line(fnd_file.log, 'Transaction Action: ' || i_txn_action_id);
     fnd_file.put_line(fnd_file.log, 'Transfer price options: ' || i_tprice_option ||
                ' Transfer Price: ' || i_txf_price ||
                ' Trp Cost: ' || l_trans_cost || ' Qty: ' || o_txn_qty);
     fnd_file.put_line(fnd_file.log, 'trx: ' || i_txn_id || ' trxCost: ' || l_rcv_txn_cost);
     fnd_file.put_line(fnd_file.log, 'o_interorg_rec: ' || o_interorg_rec);
  END IF;


  if ((i_txn_action_id in (21,22)) OR
      (i_txn_action_id = 3 and o_txn_qty < 0))
  then

     l_stmt_num := 40;

     if (l_from_method <> 1) then
       select item_cost, layer_id
         into l_snd_txn_cost, l_from_layer
         from cst_quantity_layers
        where organization_id = l_from_org
          and inventory_item_id = i_item_id
          and cost_group_id = l_from_cost_grp;
      end if;

      IF g_debug = 'Y' THEN
        fnd_file.put_line(fnd_file.log, 'Updating trx: ' || i_txn_id || ' with trxCost: ' || l_rcv_txn_cost);
      END IF;

      l_stmt_num := 50;
      Update mtl_material_transactions
      Set transaction_cost = l_rcv_txn_cost
      where transaction_id = i_txn_id;


      IF g_debug = 'Y' THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Interorg transfer send org: (consume layers) ...');
        FND_FILE.PUT_LINE(FND_FILE.LOG,to_char(i_txn_org_id) || ':' || to_char(l_from_method));
        FND_FILE.PUT_LINE(FND_FILE.LOG,to_char(i_txn_id) || ':' || to_char(l_from_layer));
      END IF;

       --
       -- Bug 5222084: consume_layers layer should be called only for the following txns.
       --
      if ((i_txn_action_id = 3 and o_txn_qty < 0)
           OR (i_txn_action_id = 22)
	   OR (i_txn_action_id = 21 and i_org_id = i_txn_org_id and i_fob_point = 1)) then

        if (l_from_method IN (5,6)) then
          l_stmt_num := 50;
          CSTPLENG.consume_layers(
                    i_org_id,
                    i_txn_id,
                    l_from_layer,
                    i_item_id,
                    -1*abs(o_txn_qty),
                    i_cost_method,
                    i_txn_src_type,
                    i_txn_action_id,
                    0,
                    o_interorg_rec,
                    i_cost_type,
                    i_mat_ct_id,
                    i_avg_rates_id,
                    o_exp_flag,
                    i_user_id,
                    i_login_id,
                    i_req_id,
                    i_prg_appl_id,
                    i_prg_id,
                    l_err_num,
                    l_err_code,
                    l_err_msg);
        end if;

      end if;

  elsif (i_txn_action_id = 12 AND i_fob_point = 1)
  then

      IF g_debug = 'Y' THEN
        fnd_file.put_line(fnd_file.log, 'Updating trx: ' || i_txn_id || ' with trxCost: ' || l_rcv_txn_cost);
      END IF;

      l_stmt_num := 70;
      Update mtl_material_transactions
      Set transaction_cost = l_rcv_txn_cost
      where transaction_id = i_txn_id;

  elsif ((i_txn_action_id = 15) OR
         (i_txn_action_id = 3 and o_txn_qty > 0) OR
         (i_txn_action_id = 12 AND i_fob_point = 2))
  then

    IF g_debug = 'Y' THEN
      fnd_file.put_line(fnd_file.log, 'inserting to MCTCD for txn: ' || i_txn_id || '. trxCost: ' || l_rcv_txn_cost);
    END IF;

   l_stmt_num := 80;
   insert into mtl_cst_txn_cost_details (
   	      transaction_id,
   	      organization_id,
	      cost_element_id,
	      level_type,
	      last_update_date,
	      last_updated_by,
	      creation_date,
	      created_by,
	      last_update_login,
	      request_id,
	      program_application_id,
	      program_id,
	      program_update_date,
	      inventory_item_id,
	      transaction_cost,
	      new_average_cost,
	      percentage_change,
	      value_change)
          values (i_txn_id,
	      l_to_org,
	      1,
  	      1,
	      sysdate,
      	      i_user_id,
      	      sysdate,
      	      i_user_id,
      	      i_login_id,
      	      i_req_id,
      	      i_prg_appl_id,
      	      i_prg_id,
      	      sysdate,
      	      i_item_id,
      	      l_rcv_txn_cost,
	      0,
	      0,
	      0);

    l_stmt_num := 90;
    -- Update the transaction cost column if appropriate.
    Update mtl_material_transactions
    Set transaction_cost = l_rcv_txn_cost
    where transaction_id = i_txn_id;

    if (l_to_method <> 1) then
      select nvl(layer_id,0)
        into l_to_layer
        from cst_quantity_layers
       where organization_id = l_to_org
         and inventory_item_id = i_item_id
         and cost_group_id = l_to_cost_grp;
    end if;


    IF g_debug = 'Y' THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, l_procedure_name || ': Interorg transfer receiving org: (create layers) ...');
      FND_FILE.PUT_LINE(FND_FILE.LOG,to_char(i_txn_org_id) || ':' || to_char(l_to_method));
      FND_FILE.PUT_LINE(FND_FILE.LOG,to_char(i_txn_id) || ':' || to_char(l_to_layer));
    END IF;

    /* Call create_layers when :
         Direct Interorg transfers
         Intransit shipment, FOB shipment from non-std to LIFO
         Intransit receipt, FOB receipt from non-std to LIFO
    */
    --
    -- Bug 5391121: we need to create layers
    -- if (l_to_method IN (5,6) or (i_txn_action_id = 3))
    -- then
    CSTPLENG.create_layers(
        i_org_id,
        i_txn_id,
        l_to_layer,
        i_item_id,
        abs(o_txn_qty),
        i_cost_method,
        i_txn_src_type,
        i_txn_action_id,
        0,
        o_interorg_rec,
        i_cost_type,
        i_mat_ct_id,
        i_avg_rates_id,
        o_exp_flag,
        i_user_id,
        i_login_id,
        i_req_id,
        i_prg_appl_id,
        i_prg_id,
        l_err_num,
        l_err_code,
        l_err_msg)
      ;
    -- end if;

  END IF;

  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, l_procedure_name || ' >>>');
  END IF;

EXCEPTION
    when others then
      rollback;
      o_err_num := SQLCODE;
      o_err_msg := 'CSTPAVCP.Logical_itr_receipt(' || to_char(l_stmt_num) ||
                   '): ' || substr(SQLERRM, 1,200);

END Cost_Logical_itr_receipt;

END CSTPLVCP;

/
