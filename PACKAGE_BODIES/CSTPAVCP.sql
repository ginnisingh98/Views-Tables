--------------------------------------------------------
--  DDL for Package Body CSTPAVCP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPAVCP" AS
/* $Header: CSTAVCPB.pls 120.36.12010000.9 2010/02/26 09:05:50 lchevala ship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CSTPAVCP';
G_DEBUG CONSTANT VARCHAR2(1)     := NVL(FND_PROFILE.VALUE('MRP_DEBUG'),'N');
G_CST_APPLICATION_ID CONSTANT NUMBER       := 707;
G_INV_APPLICATION_ID CONSTANT NUMBER       := 401;

-- PROCEDURE
--  cost_processor	Costs inventory transactions
--
procedure cost_processor(
  I_ORG_ID		IN NUMBER,
  I_TXN_ID		IN NUMBER,
  I_LAYER_ID		IN NUMBER,
  I_COST_TYPE		IN NUMBER,
  I_COST_METHOD  	IN NUMBER,
  I_MAT_CT_ID		IN NUMBER,
  I_AVG_RATES_ID	IN NUMBER,
  I_ITEM_ID		IN NUMBER,
  I_TXN_QTY		IN NUMBER,
  I_TXN_ACTION_ID 	IN NUMBER,
  I_TXN_SRC_TYPE 	IN NUMBER,
  I_TXN_ORG_ID		IN NUMBER,
  I_TXFR_ORG_ID 	IN NUMBER,
  I_COST_GRP_ID 	IN NUMBER,
  I_TXFR_COST_GRP 	IN NUMBER,
  I_TXFR_LAYER_ID 	IN NUMBER,
  I_FOB_POINT		IN NUMBER,
  I_EXP_ITEM		IN NUMBER,
  I_EXP_FLAG		IN NUMBER,
  I_CITW_FLAG		IN NUMBER,
  I_FLOW_SCHEDULE	IN NUMBER,
  I_USER_ID		IN NUMBER,
  I_LOGIN_ID    	IN NUMBER,
  I_REQ_ID		IN NUMBER,
  I_PRG_APPL_ID		IN NUMBER,
  I_PRG_ID		IN NUMBER,
  I_TPRICE_OPTION       IN NUMBER,
  I_TXF_PRICE           IN NUMBER,
  O_Err_Num		OUT NOCOPY NUMBER,
  O_Err_Code		OUT NOCOPY VARCHAR2,
  O_Err_Msg		OUT NOCOPY VARCHAR2
) IS
  l_txn_qty		NUMBER;
  l_hook		NUMBER;
  l_new_cost		NUMBER;
  l_exp_flag		NUMBER;
  l_interorg_rec	NUMBER;
  l_no_update_mmt	NUMBER;
  l_layer_chg		NUMBER;
  l_txn_action_id	NUMBER;
  l_layer_id		NUMBER;
  l_org_id		NUMBER;
  l_err_num		NUMBER;
  l_err_code		VARCHAR2(240);
  l_err_msg		VARCHAR2(240);
  process_error		EXCEPTION;
  LOGICAL_SORECEIPT_ERROR EXCEPTION;
  l_stmt_num		NUMBER;
-- borrow/payback
  l_txn_type_id	        NUMBER;
-- borrow/paybackend

  /* OPM INVCONV umoogala */
  l_pd_txfr_ind         BINARY_INTEGER;  -- Process-Discrete Xfer Flag

  l_so_line_id          NUMBER; -- Revenue COGS Matching

BEGIN
  -- initialize local variables
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';
  l_txn_qty := i_txn_qty;
  l_org_id := i_org_id;
  l_no_update_mmt := 0;
  l_interorg_rec := 0;
  l_exp_flag := i_exp_flag;
  l_hook := 0;
  l_new_cost := 0;
  l_txn_action_id := 0;
  l_stmt_num := 0;

  if (g_debug = 'Y') then
    fnd_file.put_line(fnd_file.log,'>>In CSTPAVCP.cost_processor Cost Processor');
  end if;

  /* INVCONV sschinch Check if this transaction is a process discrete transfer */
  SELECT MOD(SUM(DECODE(mp.process_enabled_flag, 'Y', 1, 2)), 2)
    INTO l_pd_txfr_ind
    FROM mtl_parameters mp, mtl_material_transactions mmt
   WHERE mmt.transaction_id   = i_txn_id
     AND (mmt.organization_id = mp.organization_id
          OR mmt.transfer_organization_id = mp.organization_id);

  /*
      ((i_txn_action_id = 15) OR
       (i_txn_action_id = 12 AND i_fob_point = 2) OR
       (i_txn_action_id = 3 AND i_txn_qty > 0)))
  */
  if ((l_pd_txfr_ind = 1) AND
      ((i_txn_action_id IN (3, 15, 12, 21, 22)) OR
       (i_txn_src_type = 8 AND i_txn_action_id = 1)) -- Bug 5349860: Internal Order issues to exp
     )
  then

   --
   -- OPM INVCONV umoogala/sschinch Process-Discrete Transfers Enh.:
   -- Processing for
   --  1. Logical  Intransit Receipt
   --       This is a new transaction type introduced for p-d xfers enh. only.
   --  2. Physical Intransit Receipt and
   --  3. Direct Xfer receipt.
   --
   CSTPAVCP.cost_logical_itr_receipt(i_org_id,
			i_txn_id,
			i_layer_id,
			i_cost_type,
			i_item_id,
			i_txn_action_id,
 			i_txn_org_id,
			i_txfr_org_id,
			i_cost_grp_id,
			i_txfr_cost_grp,
			i_fob_point,
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
    if (l_err_num <> 0) then
      -- Error occured
      raise process_error;
    end if;


  elsif (i_txn_action_id in (3,12,21)) then
    -- The l_exp_flag determines if this is an expense item or the transaction
    -- involves an expense subinventory.

    -- If this is an interorg transfer transaction, call interorg procedure
    -- to figure out transfer cost and transaction cost.

    l_stmt_num := 10;

  if (g_debug = 'Y') then
    fnd_file.put_line(fnd_file.log,'>>Inter Org Transaction');
    fnd_file.put_line(fnd_file.log,'>>Calling CSTPACVP.interorg');
  end if;

    CSTPAVCP.interorg(i_org_id,
			i_txn_id,
			i_layer_id,
			i_cost_type,
			i_item_id,
			i_txn_action_id,
 			i_txn_org_id,
			i_txfr_org_id,
			i_cost_grp_id,
			i_txfr_cost_grp,
			i_fob_point,
			i_user_id,
			i_login_id,
			i_req_id,
			i_prg_appl_id,
			i_prg_id,
                        i_tprice_option,
                        i_txf_price,
			i_exp_item,
			l_txn_qty,
			l_interorg_rec,
			l_no_update_mmt,
			l_exp_flag,
			l_hook,
			l_err_num,
			l_err_code,
			l_err_msg);
    if (l_err_num <> 0) then
      -- Error occured
      raise process_error;
    end if;

  if (g_debug = 'Y') then
    fnd_file.put_line(fnd_file.log,'<<Returning from CSTPACVP.interorg');
  end if;

    -- Some transactions do not need to be cost processed and only need cost
    -- distribution!
    -- 1) The intransit shipment from standard to average with fob receipt
    -- 2) The intransit receipt to standard from average with fob shipment
    -- 3) The direct interorg shipment from standard to average
    -- 4) The direct interorg receipt from average to standard.
    -- 5) The intransit receipt from process to discrete
    l_stmt_num := 15;
    if ((i_txn_action_id = 21 and i_fob_point = 2 and i_txfr_org_id = i_org_id)
        OR
        (i_txn_action_id = 12 and i_fob_point = 1 and i_txfr_org_id = i_org_id)
        OR
        (i_txn_action_id = 3 and i_txfr_org_id = i_org_id and i_txn_qty < 0)
        OR
        (i_txn_action_id = 3 and i_txfr_org_id = i_org_id and i_txn_qty > 0)
        OR
        (i_txn_action_id = 12 and l_pd_txfr_ind = 1 and i_fob_point = 2)
         -- OPM INVCONV sschinch/umoogala
         -- For process-discrete xfers, we need not cost physical receipt since
         -- we compute the avg cost using logical txn i.e., using
         -- InterOrg Intransit Receipt (15) using new procedure
         -- CSTPAVCP.cost_logical_itr_receipt
        OR
        (i_txn_action_id = 21 and i_fob_point = 1 and l_pd_txfr_ind = 1 and i_org_id = i_txn_org_id))
        -- OPM INVCONV sschinch/umoogala
        -- For process-discrete xfers, this is a shipment line from discrete-to-process.
        -- So, no need to avg. Avg Cost is computed on the OPM side
       then
      return;
    end if;

  elsif (i_citw_flag = 1) then
  -- Common Issue to WIP is processed separately. There
  -- is no hook available for this transaction.

    -- Treat it as a subinventory transfer
    l_txn_action_id := 2;
    l_stmt_num := 20;

    if (g_debug = 'Y') then
      fnd_file.put_line(fnd_file.log,'>>Common Issue to WIP');
    end if;

    /* Added Bug#4259926 modified the code to change the layer id. */
        if (i_txn_action_id = 27 and  i_txn_src_type = 5 and i_citw_flag = 1 ) then
            l_layer_id := i_txfr_layer_id;
        else
            l_layer_id := i_layer_id;
        end if;

    l_new_cost := CSTPAVCP.compute_actual_cost(
				i_org_id,
				i_txn_id,
				l_layer_id, /* Bug#4259926 changed i_layer_id to l_layer_id */
				i_cost_type,
				i_mat_ct_id,
				i_avg_rates_id,
				i_item_id,
				l_txn_qty,
				l_txn_action_id,
				i_txn_src_type,
				l_interorg_rec,
				l_exp_flag,
				i_user_id,
				i_login_id,
				i_req_id,
				i_prg_appl_id,
				i_prg_id,
				l_err_num,
				l_err_code,
				l_err_msg);
    if (l_err_num <> 0) then
      -- Error occured
      raise process_error;
    end if;

    l_stmt_num := 30;

    CSTPAVCP.common_issue_to_wip(
			i_org_id,
			i_txn_id,
			i_layer_id,
			i_cost_type,
			i_item_id,
			l_txn_qty,
			l_txn_action_id,
			l_new_cost,
			i_txfr_layer_id,
			i_cost_method,
			i_avg_rates_id,
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
      -- Error occured
      raise process_error;
    end if;

    -- done
    return;

  elsif (i_txn_action_id = 24) then /*Removed i_txn_src_type_id = 15 for bug 6030287*/
    -- Average Cost Update is processed separately.  There
    -- is no hook available for this transaction.
    l_stmt_num := 40;

    if (g_debug = 'Y') then
      fnd_file.put_line(fnd_file.log,'>>Average Cost update');
    end if;

    average_cost_update(i_org_id,
			i_txn_id,
			i_layer_id,
			i_cost_type,
			i_item_id,
			i_txn_action_id,
			i_txn_qty,/*LCM*/
			l_exp_flag,
			i_user_id,
			i_login_id,
			i_req_id,
			i_prg_appl_id,
			i_prg_id,
			l_err_num,
			l_err_code,
			l_err_msg);
    if (l_err_num <> 0) then
      -- Error occured
      raise process_error;
    end if;

    -- done
    return;

  elsif (i_exp_item = 0) then
    -- Call the Actual Cost Hook for asset items
    l_stmt_num := 50;
    if (g_debug = 'Y') then
       fnd_file.put_line(fnd_file.log,'Actual Cost Hook invoked: CSTPACHK.actual_cost_hook');
    end if;
    l_hook := CSTPACHK.actual_cost_hook(i_org_id,
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
    IF (l_hook = 1) THEN
                IF g_debug = 'Y' THEN
                    fnd_file.put_line(fnd_file.log, '>>>>Hook has been used. Calling CSTPAVCP.validate_actual_cost_hook');
                END IF;

                CSTPAVCP.validate_actual_cost_hook(i_txn_id	=>	i_txn_id,
						   i_org_id     =>      i_org_id,
                                                   i_layer_id   =>      i_layer_id,
                                                   i_req_id     =>      i_req_id,
                                                   i_prg_appl_id=>      i_prg_appl_id,
                                                   i_prg_id     =>      i_prg_id,
                                                   o_err_num    =>      l_err_num,
                                                   o_err_code   =>      l_err_code,
                                                   o_err_msg    =>      l_err_msg);
    END IF;
    if (l_err_num <> 0) then
      -- Error occured
      raise process_error;
    end if;
  end if;
     if (g_debug = 'Y') then
        fnd_file.put_line(fnd_file.log,'l_hook: '||to_char(l_hook));
     end if;
  if (l_hook = 0) then
-- borrow /payback
-- if hook is not used and it is a payback transaction, we need to populate MCTCD
-- with the borrowed cost.
     l_stmt_num := 60;
     if (g_debug = 'Y') then
        fnd_file.put_line(fnd_file.log,'Actual Cost Hook not used');
     end if;

     /* Changes for VMI. Adding Planning Transfer Transaction */
     if i_txn_action_id IN (2,5,28,55) then
         l_stmt_num := 70;
         select transaction_type_id
         into l_txn_type_id
         from mtl_material_transactions
         where transaction_id = i_txn_id;

         if (l_txn_type_id = 68) and (i_layer_id <> i_txfr_layer_id) then
           -- if payback txn and txn involved different projects then populate MCTCD
           -- with the borrowed cost
            l_stmt_num := 80;
            if (g_debug = 'Y') then
                fnd_file.put_line(fnd_file.log,'Borrow Payback');
            end if;
            borrow_cost(i_org_id,
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
            -- Error occured
               raise process_error;
            end if;

         end if; -- l_txn_type_id = 68, if it is payback transaction
      end if;  -- i_txn_action_id = 2, if it is sub or staging transfer
-- borrow /paybackend


  /*
  Changes during Revenue / COGS Matching to make RMA Receipts Cost Owned -
  The following section will populate MCTCD for RMA Receipts. If the RMA Receipt
  references a Sales Order, the average cost of the Sales Order Issues will be used.
  If the RMA Receipt does not reference a Sales Order, MCTCD will not be populated
  and the RMA Receipt will be processed at the latest average cost (e.g. as a cost
  derived transaction)
  */

  -- Check if the transaction is an RMA receipt
  IF i_txn_action_id = 27 AND i_txn_src_type = 12 THEN
    -- Check if Sales Order is referenced
    l_stmt_num := 83;
    SELECT MIN(OOLA.reference_line_id)
    INTO   l_so_line_id
    FROM   mtl_material_transactions MMT,
           oe_order_lines_all OOLA
    WHERE  MMT.transaction_id = i_txn_id
    AND    OOLA.line_id = MMT.trx_source_line_id;

    IF l_so_line_id IS NOT NULL THEN

    --{BUG#8553255
      l_stmt_num := 87;
      --
      -- Cost owned transactions within the same ledger across inv org
      --
      INSERT  INTO   mtl_cst_txn_cost_details (
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
      FROM   oe_order_lines_all          OOLA,   /*BUG 5768680 Changes introduced to improve performance*/
             oe_order_headers_all        OOHA,   /* of the layer cost worker*/
             mtl_sales_orders            MSO,
             mtl_material_transactions   MMT,
             mtl_cst_actual_cost_details MCACD,
             cst_cogs_events             cce
      WHERE  OOLA.line_id                   = l_so_line_id
      AND    OOHA.header_id                 = OOLA.header_id
      AND    MSO.segment1                   = TO_CHAR(OOHA.order_number) -- extraneous MSOs are possible
      AND    MMT.trx_source_line_id         = l_so_line_id               -- filter MMTs corresponding to extraneous MSOs
      AND    OOLA.line_id                   = cce.cogs_om_line_id
      AND    cce.event_type                 = 1
      AND    mmt.transaction_id             = cce.mmt_transaction_id
      AND    MMT.transaction_source_id      = MSO.sales_order_id
      AND    MMT.transaction_action_id      IN (1,7)
      AND    MMT.transaction_source_type_id = 2
      AND    MMT.inventory_item_id          = i_item_id
      AND    MCACD.transaction_id           = MMT.transaction_id
      AND    EXISTS (SELECT NULL
                     FROM cst_acct_info_v v1,cst_acct_info_v v2
                     WHERE v1.organization_id = MMT.organization_id
                     AND   v2.organization_id = i_org_id
                     AND   v1.ledger_id       = v2.ledger_id)
      GROUP
      BY     MCACD.cost_element_id,
             MCACD.level_type;
      --}

      -- A Sales Order is referenced, use the average cost of the Sales Order Issues
      IF SQL%NOTFOUND THEN
      -- A Sales Order is referenced, use the average cost of the Sales Order Issues
      -- Try the old Code prevention of regression
	  l_stmt_num := 86;
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
      AND    MMT.transaction_action_id in (1,7)
      AND    MMT.transaction_source_type_id = 2
      AND    MMT.organization_id = i_org_id
      AND    MMT.inventory_item_id = i_item_id
      AND    MCACD.transaction_id = MMT.transaction_id
      GROUP
      BY     MCACD.cost_element_id,
             MCACD.level_type;
      END IF;
    END IF; -- Check if Sales Order is referenced
  END IF; -- Check if transaction is an RMA receipt


    -- when we process transfer org's txn(i.e. intransit txfr),
    -- we need to use txfr_layer_id instead.
    -- bug 2471598 also use txfr_layer_id when processing
    -- the receipt txn in the receipt org of an fob shipment txfr
    l_stmt_num := 90;
    if ((i_org_id <> i_txn_org_id) or
        (i_txn_action_id = 12 and i_fob_point = 1)) then
      l_layer_id := i_txfr_layer_id;
    else
      l_layer_id := i_layer_id;
    end if;

    l_stmt_num := 100;
    IF g_debug = 'Y' THEN
       fnd_file.put_line(fnd_file.log, '>>Calling CSTPAVCP.compute_actual_cost');
    END IF;
    l_new_cost := CSTPAVCP.compute_actual_cost(
				i_org_id,
				i_txn_id,
				l_layer_id,
				i_cost_type,
				i_mat_ct_id,
				i_avg_rates_id,
				i_item_id,
				l_txn_qty,
				i_txn_action_id,
				i_txn_src_type,
				l_interorg_rec,
				l_exp_flag,
				i_user_id,
				i_login_id,
				i_req_id,
				i_prg_appl_id,
				i_prg_id,
				l_err_num,
				l_err_code,
				l_err_msg);

    if (l_err_num <> 0) then
      -- Error occured
      raise process_error;
    end if;

    IF g_debug = 'Y' THEN
       fnd_file.put_line(fnd_file.log, '<<Returned from CSTPAVCP.compute_actual_cost');
    END IF;

  else
    -- user populated actual cost.
    l_new_cost := 1;
  end if;

  -- If this transaction is a subinventory or staging transfer then call the
  -- sub_transfer special function.  We treat interorg intransit
  -- shipment for FOB receipt and interorg intransit for FOB shipment
  -- as sub_transfer transactions.
  /* Changes for VMI. Adding Planning Transfer Transaction */
  if ((i_txn_action_id IN (2,5,28,55)) or
      (i_txn_action_id = 21 and i_org_id = i_txn_org_id and i_fob_point = 2) or
      (i_txn_action_id = 12 and i_org_id = i_txn_org_id and i_fob_point = 1))
	then
    l_stmt_num := 110;
    IF g_debug = 'Y' THEN
       fnd_file.put_line(fnd_file.log, '>>Calling from CSTPAVCP.sub_transfer');
    END IF;
    CSTPAVCP.sub_transfer(
			i_org_id,
			i_txn_id,
			i_layer_id,
			i_cost_type,
			i_item_id,
			l_txn_qty,
			i_txn_action_id,
			l_new_cost,
			l_hook,
			i_txfr_layer_id,
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
    IF g_debug = 'Y' THEN
       fnd_file.put_line(fnd_file.log, '<<Returned from CSTPAVCP.sub_transfer');
    END IF;

  -- If this transaction is using a new cost and it is not an
  -- expense item than we need to recalculate
  -- average cost
  elsif ((l_new_cost = 1) and (l_exp_flag <> 1) and
         (i_txn_action_id <> 30)) then

    -- when we process transfer org's txn(i.e. intransit txfr),
    -- we need to use txfr_layer_id instead.
    l_stmt_num := 120;
    if (i_org_id <> i_txn_org_id) then
      l_layer_id := i_txfr_layer_id;
      l_txn_qty := -1 * l_txn_qty;
    else
      l_layer_id := i_layer_id;
    end if;

    l_stmt_num := 130;
   IF g_debug = 'Y' THEN
       fnd_file.put_line(fnd_file.log, '>>Calling CSTPAVCP.calc_average_cost');
   END IF;
    CSTPAVCP.calc_average_cost(
				i_org_id,
				i_txn_id,
				l_layer_id,
				i_cost_type,
				i_item_id,
				l_txn_qty,
				i_txn_action_id,
				l_no_update_mmt,
				i_user_id,
				i_login_id,
				i_req_id,
				i_prg_appl_id,
				i_prg_id,
				l_err_num,
				l_err_code,
				l_err_msg);
    if (l_err_num <> 0) then
      -- Error occured
      raise process_error;
    end if;
   IF g_debug = 'Y' THEN
       fnd_file.put_line(fnd_file.log, '<<Returned from CSTPAVCP.calc_average_cost');
   END IF;
  else
    -- when we process transfer org's txn(i.e. intransit txfr),
    -- we need to use txfr_layer_id instead.
    if (i_org_id <> i_txn_org_id) then
      l_layer_id := i_txfr_layer_id;
      l_txn_qty := -1 * l_txn_qty;
      l_org_id := i_txn_org_id;
    else
      l_layer_id := i_layer_id;
      l_org_id := i_org_id;
    end if;

    l_stmt_num := 140;
    IF g_debug = 'Y' THEN
       fnd_file.put_line(fnd_file.log, '>>Calling CSTPAVCP.current_average_cost');
    END IF;
    CSTPAVCP.current_average_cost(
				l_org_id,
				i_txn_id,
				l_layer_id,
				i_cost_type,
				i_item_id,
				l_txn_qty,
				i_txn_action_id,
				l_exp_flag,
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
      -- Error occured
      raise process_error;
    end if;
   IF g_debug = 'Y' THEN
       fnd_file.put_line(fnd_file.log, '<<Returned from CSTPAVCP.current_average_cost');
   END IF;
    -- For Internal Order Issue transactons to Expense destinations,
    -- call Cost_LogicalSOReceipt API to cost the Receipt transaction.
    l_stmt_num := 150;

    select transaction_type_id
    into   l_txn_type_id
    from   mtl_material_transactions
    where  transaction_id = i_txn_id;

    l_stmt_num := 160;
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
        RAISE LOGICAL_SORECEIPT_ERROR;
      END IF;
    END IF;
  end if;
  if (g_debug = 'Y') then
    fnd_file.put_line(fnd_file.log,'>>Exiting Cost Processor');
  end if;

  EXCEPTION
    when process_error then
      o_err_num := l_err_num;
      o_err_code := l_err_code;
      o_err_msg := l_err_msg;
    when LOGICAL_SORECEIPT_ERROR then
      rollback;
      o_err_num := SQLCODE;
      o_err_msg := 'CSTPAVCP.Cost_Processor (' || to_char(l_stmt_num) || '): '
		|| 'Error in CSTPAVCP.Cost_LogicalReceipt';
    when OTHERS then
      rollback;
      o_err_num := SQLCODE;
      o_err_msg := 'CSTPAVCP.Cost_Processor (' || to_char(l_stmt_num) || '): '
		|| substr(SQLERRM,1,200);

END cost_processor;


-- PROCEDURE
--  average_cost_update		Cost process the average cost update
--				transaction.

procedure average_cost_update(
  I_ORG_ID	IN	NUMBER,
  I_TXN_ID	IN	NUMBER,
  I_LAYER_ID	IN	NUMBER,
  I_COST_TYPE	IN	NUMBER,
  I_ITEM_ID	IN	NUMBER,
  I_TXN_ACTION_ID IN	NUMBER,
  I_TXN_QTY     IN      NUMBER,/*LCM*/
  I_EXP_FLG	IN	NUMBER,
  I_USER_ID	IN	NUMBER,
  I_LOGIN_ID    IN	NUMBER,
  I_REQ_ID	IN	NUMBER,
  I_PRG_APPL_ID	IN	NUMBER,
  I_PRG_ID	IN 	NUMBER,
  O_Err_Num	OUT NOCOPY	NUMBER,
  O_Err_Code	OUT NOCOPY	VARCHAR2,
  O_Err_Msg	OUT NOCOPY	VARCHAR2
) IS
  neg_cost_error	EXCEPTION;
  l_neg_cost		NUMBER;
  l_mandatory_update    NUMBER;
  l_err_num		NUMBER;
  l_err_code		VARCHAR2(240);
  l_err_msg		VARCHAR2(240);
  l_stmt_num		NUMBER;
  process_error		EXCEPTION;
  l_num_cost_groups     NUMBER;
  l_layer_quantity      NUMBER;

BEGIN
  -- Initialize variables.
  l_neg_cost := 0;
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';

  if (g_debug = 'Y') then
       fnd_file.put_line(fnd_file.log,'Average Cost Update <<<');
  end if;

  l_stmt_num := 10;
  -- First insert records into mtl_cst_actual_cost_details.

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
	user_entered,
	onhand_variance_amount)
  select
	i_txn_id,
      	i_org_id,
	i_layer_id,
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
        decode(ctcd.new_average_cost,NULL,
	     decode(ctcd.percentage_change,NULL,
		  /* value change formula */
		  decode(sign(cql.layer_quantity),1,
		    decode(sign(i_txn_qty),1,
		     decode(sign(cql.layer_quantity-i_txn_qty),-1,
                         decode(sign(nvl(clcd.item_cost,0) * cql.layer_quantity +
			             (ctcd.value_change/i_txn_qty*cql.layer_quantity)),-1,
			    0,
			    (nvl(clcd.item_cost,0)*nvl(cql.layer_quantity,0) +
			     (ctcd.value_change/i_txn_qty*cql.layer_quantity))/nvl(cql.layer_quantity,-1)),
		       decode(sign(nvl(clcd.item_cost,0) * cql.layer_quantity + ctcd.value_change),-1,
			    0,
			    (nvl(clcd.item_cost,0)*nvl(cql.layer_quantity,0) +
			     ctcd.value_change)/nvl(cql.layer_quantity,-1))),
     		       decode(sign(nvl(clcd.item_cost,0) * cql.layer_quantity + ctcd.value_change),-1,
			    0,
			    (nvl(clcd.item_cost,0)*nvl(cql.layer_quantity,0) +
			     ctcd.value_change)/nvl(cql.layer_quantity,-1))),
		       nvl(clcd.item_cost,0)),
		   /* percentage change formula */
		   nvl(clcd.item_cost,0)*(1+ctcd.percentage_change/100)),
	     /* new average cost formula */
	     ctcd.new_average_cost),
      	nvl(clcd.item_cost,0),
        decode(ctcd.new_average_cost,NULL,
	     decode(ctcd.percentage_change,NULL,
		  /* value change formula */
  		  decode(sign(cql.layer_quantity),1,
		    decode(sign(i_txn_qty),1,
		     decode(sign(cql.layer_quantity-i_txn_qty),-1,
                         decode(sign(nvl(clcd.item_cost,0) * cql.layer_quantity +
			             (ctcd.value_change/i_txn_qty*cql.layer_quantity)),-1,
			    0,
			    (nvl(clcd.item_cost,0)*nvl(cql.layer_quantity,0) +
			     (ctcd.value_change/i_txn_qty*cql.layer_quantity))/nvl(cql.layer_quantity,-1)),
		       decode(sign(nvl(clcd.item_cost,0) * cql.layer_quantity + ctcd.value_change),-1,
			    0,
			    (nvl(clcd.item_cost,0)*nvl(cql.layer_quantity,0) +
			     ctcd.value_change)/nvl(cql.layer_quantity,-1))),
     		       decode(sign(nvl(clcd.item_cost,0) * cql.layer_quantity + ctcd.value_change),-1,
			    0,
			    (nvl(clcd.item_cost,0)*nvl(cql.layer_quantity,0) +
			     ctcd.value_change)/nvl(cql.layer_quantity,-1))),
		       nvl(clcd.item_cost,0)),
		   /* percentage change formula */
		   nvl(clcd.item_cost,0)*(1+ctcd.percentage_change/100)),
	     /* new average cost formula */
	     ctcd.new_average_cost),
      	'Y',
	decode(ctcd.value_change,NULL,
	     0,
	     decode(sign(cql.layer_quantity),1,
	        decode(sign(i_txn_qty),1,
		 decode(sign(cql.layer_quantity-i_txn_qty),-1,
  	          decode(sign(nvl(clcd.item_cost,0) * cql.layer_quantity + (ctcd.value_change/i_txn_qty*cql.layer_quantity)),-1,
		       (ctcd.value_change/i_txn_qty*cql.layer_quantity) + nvl(clcd.item_cost,0) * cql.layer_quantity,
		       0),
	          decode(sign(nvl(clcd.item_cost,0) * cql.layer_quantity + ctcd.value_change),-1,
		       ctcd.value_change + nvl(clcd.item_cost,0) * cql.layer_quantity,
		       0)),
       	          decode(sign(nvl(clcd.item_cost,0) * cql.layer_quantity + ctcd.value_change),-1,
		       ctcd.value_change + nvl(clcd.item_cost,0) * cql.layer_quantity,
		       0)),
		  ctcd.value_change)),
      	'N',
	/*LCM*/
    decode(ctcd.value_change,NULL,
           0,
	   decode(sign(i_txn_qty),1,
	          decode(sign(cql.layer_quantity),1,
		         decode(sign(cql.layer_quantity-i_txn_qty),-1,
			        ctcd.value_change*(1-cql.layer_quantity/i_txn_qty),
				0
			        ),
			 0
		         ),
		  0
	          )
           )
  FROM mtl_cst_txn_cost_details ctcd,
       cst_quantity_layers cql,
       cst_layer_cost_details clcd
  WHERE ctcd.transaction_id = i_txn_id
  AND ctcd.organization_id = i_org_id
  AND cql.layer_id = i_layer_id
  AND cql.inventory_item_id = ctcd.inventory_item_id
  AND cql.organization_id = ctcd.organization_id
  AND clcd.layer_id (+) = i_layer_id
  AND clcd.cost_element_id (+) = ctcd.cost_element_id
  AND clcd.level_type (+) = ctcd.level_type;
  -- Verify there are no negative costs!
  l_stmt_num := 20;

/*  select count(*)
  into l_neg_cost
  from mtl_cst_actual_cost_details
  where transaction_id = i_txn_id
  and organization_id = i_org_id
  and layer_id = i_layer_id
  and new_cost < 0;

  if (l_neg_cost > 0) then
    raise neg_cost_error;
  end if; */ -- removed for bug #4005770

 l_stmt_num  := 21 ;
/**************************************************
Issue : Bug 8652819
Added to include elemental level cost which are not present in
MCTCD or MCACD but present in CLCD.When first txn for any item is PO txn and not costed
and if immediately average cost update performs then average cost update transaction gets
populated before costing of PO txn as a result it does not contain cost_element 2 cost,which has been
introduced by PO.These changes are similarto change done for India localization case

Fix :
1) Following insert statement would ensure that existing costs against other CE/Level
should not lost
2) We have already changed the Average Cost update form (through bug6407296 ) to make
fields "LEVEL" and "COST ELEMENT" as a  non updatable fields

Above two changes will make behaviour consitent.

***************************************************/
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
        i_org_id,
        i_layer_id,
        clcd.cost_element_id,
        clcd.level_type,
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
        clcd.item_cost,
        clcd.item_cost,
        clcd.item_cost,
        'Y',
        0,
        'N'
  from cst_layer_cost_details clcd
  where layer_id = i_layer_id
  and not exists
        (select 'this detail is not in cacd already'
         from mtl_cst_actual_cost_details cacd
         where cacd.transaction_id = i_txn_id
         and cacd.organization_id = i_org_id
         and cacd.layer_id = i_layer_id
         and cacd.cost_element_id = clcd.cost_element_id
         and cacd.level_type = clcd.level_type);


/* Changes for bug 8649362 and 8652819 are over*/



  /********************************************************************
   ** Delete from cst_layer_cost_details and insert the new rows     **
   ** from mtl_cst_actual_cost_details.				     **
   ********************************************************************/
  l_stmt_num := 30;

  Delete from cst_layer_cost_details
  where layer_id = i_layer_id;

  l_stmt_num := 40;
  Insert into cst_layer_cost_details (
	layer_id,
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
	item_cost)
  select i_layer_id,
	cacd.cost_element_id,
	cacd.level_type,
	sysdate,
      	i_user_id,
      	sysdate,
      	i_user_id,
      	i_login_id,
      	i_req_id,
      	i_prg_appl_id,
      	i_prg_id,
      	sysdate,
	cacd.new_cost
  from mtl_cst_actual_cost_details cacd
  where cacd.transaction_id = i_txn_id
  and cacd.organization_id = i_org_id
  and cacd.layer_id = i_layer_id
  and cacd.insertion_flag = 'Y'
  and cacd.new_cost <> 0;

  if sql%rowcount  =  0 then
  Insert into cst_layer_cost_details (
	layer_id,
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
	item_cost)
  select i_layer_id,
	cacd.cost_element_id,
	cacd.level_type,
	sysdate,
      	i_user_id,
      	sysdate,
      	i_user_id,
      	i_login_id,
      	i_req_id,
      	i_prg_appl_id,
      	i_prg_id,
      	sysdate,
	cacd.new_cost
  from mtl_cst_actual_cost_details cacd
  where cacd.transaction_id = i_txn_id
  and cacd.organization_id = i_org_id
  and cacd.layer_id = i_layer_id
  and cacd.insertion_flag = 'Y'
  and cacd.cost_element_id = (select min(cost_element_id)
      from mtl_cst_actual_cost_details
      where transaction_id = i_txn_id
       and organization_id = i_org_id
       and layer_id = i_layer_id
       and insertion_flag = 'Y');
  end if;

  /********************************************************************
   ** Update cst_quanity_layers					     **
   ********************************************************************/
  l_stmt_num := 50;
  /* Used the Base Table instead of View Bug 4773025 */
  Update cst_quantity_layers cql
  Set (last_updated_by,
	last_update_date,
	last_update_login,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	update_transaction_id,
	pl_material,
	pl_material_overhead,
	pl_resource,
	pl_outside_processing,
	pl_overhead,
	tl_material,
	tl_material_overhead,
	tl_resource,
	tl_outside_processing,
	tl_overhead,
	material_cost,
	material_overhead_cost,
	resource_cost,
	outside_processing_cost,
	overhead_cost,
	pl_item_cost,
	tl_item_cost,
	item_cost,
	unburdened_cost,
	burden_cost) =
  (SELECT
        i_user_id,
        sysdate,
        i_login_id,
	i_req_id,
      	i_prg_appl_id,
      	i_prg_id,
      	sysdate,
	i_txn_id,
	SUM(DECODE(LEVEL_TYPE, 2, DECODE(COST_ELEMENT_ID, 1, ITEM_COST, 0), 0)),
        SUM(DECODE(LEVEL_TYPE, 2, DECODE(COST_ELEMENT_ID, 2, ITEM_COST, 0), 0)),
        SUM(DECODE(LEVEL_TYPE, 2, DECODE(COST_ELEMENT_ID, 3, ITEM_COST, 0), 0)),
        SUM(DECODE(LEVEL_TYPE, 2, DECODE(COST_ELEMENT_ID, 4, ITEM_COST, 0), 0)),
        SUM(DECODE(LEVEL_TYPE, 2, DECODE(COST_ELEMENT_ID, 5, ITEM_COST, 0), 0)),
        SUM(DECODE(LEVEL_TYPE, 1, DECODE(COST_ELEMENT_ID, 1, ITEM_COST, 0), 0)),
        SUM(DECODE(LEVEL_TYPE, 1,DECODE(COST_ELEMENT_ID, 2, ITEM_COST, 0), 0)),
        SUM(DECODE(LEVEL_TYPE, 1, DECODE(COST_ELEMENT_ID, 3, ITEM_COST, 0), 0)),
        SUM(DECODE(LEVEL_TYPE ,1, DECODE(COST_ELEMENT_ID ,4, ITEM_COST, 0), 0)),
        SUM(DECODE(LEVEL_TYPE, 1, DECODE(COST_ELEMENT_ID, 5, ITEM_COST, 0), 0)),
        SUM(DECODE(COST_ELEMENT_ID, 1, ITEM_COST, 0)),
        SUM(DECODE(COST_ELEMENT_ID, 2, ITEM_COST, 0)),
        SUM(DECODE(COST_ELEMENT_ID, 3, ITEM_COST, 0)),
        SUM(DECODE(COST_ELEMENT_ID, 4, ITEM_COST, 0)),
        SUM(DECODE(COST_ELEMENT_ID, 5, ITEM_COST, 0)),
        SUM(DECODE(LEVEL_TYPE, 2, ITEM_COST, 0)),
        SUM(DECODE(LEVEL_TYPE, 1, ITEM_COST, 0)),
        SUM(ITEM_COST),
        SUM(DECODE(COST_ELEMENT_ID, 2, DECODE(LEVEL_TYPE, 2, ITEM_COST, 0), ITEM_COST)),
        SUM(DECODE(COST_ELEMENT_ID, 2, DECODE(LEVEL_TYPE, 1, ITEM_COST, 0), 0))
   from CST_LAYER_COST_DETAILS clcd
   where clcd.layer_id = i_layer_id)
  where cql.layer_id = i_layer_id
  and exists
     (select 'there is detail cost'
      from cst_layer_cost_details clcd
      where clcd.layer_id = i_layer_id);

  l_stmt_num := 60;
  /********************************************************************
   ** Update Mtl_Material_Transactions				     **
   ********************************************************************/
  CSTPAVCP.update_mmt(
			i_org_id,
			i_txn_id,
			-1,		-- txfr_txn_id is not applicable
			i_layer_id,
			1,
			i_user_id,
			i_login_id,
			i_req_id,
			i_prg_appl_id,
			i_prg_id,
			l_err_num,
			l_err_code,
			l_err_msg);

  if (l_err_num <> 0) then
    -- Error occured
    raise process_error;
  end if;

  l_stmt_num := 70;
  /* 3509390

     If the item is held in only one cost group for the organization,
     it is okay to update CIC with the cost when quantity is 0.

     The default behavior is not to require mandatory update unless the
     above property (one cost group, zero quantity) is found to be true.
     When total layer quantity is positive, CIC is updated regardless of the
     value of l_mandatory_update.
  */

  l_mandatory_update := 0;

  SELECT count(*)
  INTO   l_num_cost_groups
  FROM   cst_quantity_layers
  WHERE  inventory_item_id = i_item_id
  AND    organization_id   = i_org_id;

  IF (l_num_cost_groups = 1) THEN
    SELECT layer_quantity
    INTO   l_layer_quantity
    FROM   cst_quantity_layers
    WHERE  inventory_item_id = i_item_id
    AND    organization_id   = i_org_id;

    IF (l_layer_quantity = 0) THEN
      l_mandatory_update := 1;
    END IF;
  END IF;

  l_stmt_num := 80;
  /********************************************************************
   ** Update Item Cost and Item Cost Details			     **
   ********************************************************************/
  CSTPAVCP.update_item_cost(
			i_org_id,
			i_txn_id,
			i_layer_id,
			i_cost_type,
			i_item_id,
			l_mandatory_update,
			i_user_id,
			i_login_id,
			i_req_id,
			i_prg_appl_id,
			i_prg_id,
			l_err_num,
			l_err_code,
  			l_err_msg);
  if (l_err_num <> 0) then
    -- Error occured
    raise process_error;
  end if;
  if (g_debug = 'Y') then
       fnd_file.put_line(fnd_file.log,'Average Cost Update >>>');
  end if;

  EXCEPTION
    when neg_cost_error then
      rollback;
      o_err_num := 9999;
      o_err_code := 'CST_NEG_ITEM_COST';
      FND_MESSAGE.set_name('BOM', 'CST_NEG_ITEM_COST');
      o_err_msg := FND_MESSAGE.Get;
    when process_error then
      o_err_num := l_err_num;
      o_err_code := l_err_code;
      o_err_msg := l_err_msg;
    when others then
      rollback;
      o_err_num := SQLCODE;
      o_err_msg := 'CSTPAVCP.average_cost_update (' || to_char(l_stmt_num) ||
                   '): '
		   || substr(SQLERRM, 1,200);
END average_cost_update;

-- PROCEDURE
--  sub_transfer		Cost process the subinventory transfer
--				transaction.

procedure sub_transfer(
  I_ORG_ID		IN NUMBER,
  I_TXN_ID		IN NUMBER,
  I_LAYER_ID		IN NUMBER,
  I_COST_TYPE		IN NUMBER,
  I_ITEM_ID		IN NUMBER,
  I_TXN_QTY		IN NUMBER,
  I_TXN_ACTION_ID 	IN NUMBER,
  I_NEW_COST		IN NUMBER,
  I_HOOK		IN NUMBER,
  I_TXFR_LAYER_ID 	IN NUMBER,
  I_CITW_FLAG		IN NUMBER,
  I_FLOW_SCHEDULE	IN NUMBER,
  I_USER_ID		IN NUMBER,
  I_LOGIN_ID    	IN NUMBER,
  I_REQ_ID		IN NUMBER,
  I_PRG_APPL_ID		IN NUMBER,
  I_PRG_ID		IN NUMBER,
  O_Err_Num		OUT NOCOPY NUMBER,
  O_Err_Code		OUT NOCOPY VARCHAR2,
  O_Err_Msg		OUT NOCOPY VARCHAR2
) IS
  l_layer_chg		NUMBER;
  l_exp_item		NUMBER;
  l_exp1		NUMBER;
  l_exp2		NUMBER;
  l_from_layer		NUMBER;
  l_to_layer		NUMBER;
  l_from_exp		NUMBER;
  l_to_exp		NUMBER;
  l_from_qty		NUMBER;
  l_ret_val		NUMBER;
  l_no_update_qty	NUMBER;
  l_new_cost		NUMBER;
  l_txf_txn_id          NUMBER;
  l_err_num		NUMBER;
  l_err_code		VARCHAR2(240);
  l_err_msg		VARCHAR2(240);
  l_stmt_num		NUMBER;
  process_error		EXCEPTION;
-- borrow payback
  l_txn_type_id		NUMBER;
  l_cur_cost            NUMBER;
-- borrow payback end
BEGIN
  -- initialize local variables
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';
  l_new_cost := i_new_cost;
  l_stmt_num := 0;

  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, 'Sub_Transfer <<<');
  END IF;

 /********************************************************************
  ** Figure out layer_change flag                                   **
  ** A layer change occurs when we transfer material between        **
  ** two different layers within the same org.                      **
  ********************************************************************/
-- borrow / payback
  l_stmt_num := 10;
  select transaction_type_id
    into l_txn_type_id
    from mtl_material_transactions
    where transaction_id = i_txn_id;
-- borrow / payback end

  l_stmt_num := 15;
  if ((i_txfr_layer_id is not NULL) and (i_txfr_layer_id <> i_layer_id)) then
    l_layer_chg := 1;
  else
    l_layer_chg := 0;
  end if;

  if (g_debug = 'Y') then
       fnd_file.put_line(fnd_file.log,'Layer change: ' || to_char(l_layer_chg));
  end if;

  l_stmt_num := 20;
  select decode(inventory_asset_flag, 'Y',0,1)
  into l_exp_item
  from mtl_system_items
  where inventory_item_id = i_item_id
  and organization_id = i_org_id;

  if (g_debug = 'Y') then
       fnd_file.put_line(fnd_file.log,'Expense Item: ' || to_char(l_exp_item));
  end if;

  l_stmt_num := 30;

  select decode(asset_inventory,1,0,1)
  into l_exp1
  from mtl_secondary_inventories msi
  , mtl_material_transactions mmt
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

  if (i_citw_flag = 1) then
    l_stmt_num := 42;
    if (g_debug = 'Y') then
        fnd_file.put_line(fnd_file.log,'Common Issue to WIP');
    end if;

    if(i_flow_schedule = 1) then
      -- cfm then use wip_flow_schedules
      -- class_type 1 and 3 : asset job, 4 : exp job
      l_stmt_num := 44;
      if (g_debug = 'Y') then
           fnd_file.put_line(fnd_file.log,'Flow Schedule');
      end if;

      select decode(wac.class_type, 1, 0,
                                    3, 0,
                                    6, 0,
                                    4, decode(l_exp1, 1, 1, 0))
      into   l_exp2
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
      -- non cfm then use wip_discrete_jobs
      -- class_type 1 and 3 : asset job, 4 : exp job
      select decode(wac.class_type, 1, 0,
                                    3, 0,
                                    6, 0,
                                    4, decode(l_exp1, 1, 1, 0))
      into   l_exp2
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
  /* Changes for VMI. Adding Planning Transfer Transaction */
  elsif (i_txn_action_id IN (2,5,28)) then
    l_stmt_num := 46;
    if (g_debug = 'Y') then
         fnd_file.put_line(fnd_file.log,'Transfer Subinventory asset flag : ' || to_char(l_exp2));
    end if;

    select decode(asset_inventory,1,0,1)
    into l_exp2
    from mtl_secondary_inventories msi
    , mtl_material_transactions mmt
    where msi.secondary_inventory_name = mmt.transfer_subinventory
    and msi.organization_id = i_org_id
    and mmt.transaction_id = i_txn_id
    and mmt.organization_id = i_org_id;
     elsif(i_txn_action_id = 55 ) then
    l_stmt_num := 47;
    l_exp2 := l_exp1; /* Txfr sub asset flag is equal to from sub asset flag in cost grp txfrs */
    if (g_debug = 'Y') then
         fnd_file.put_line(fnd_file.log,'Transfer Subinventory asset flag : '||to_char(l_exp2));
    end if;
  else
    l_stmt_num := 48;
    l_exp2 := 0;
  end if;

  /* Changes for VMI. Adding Planning Transfer Transaction */
  if (i_txn_action_id in (2,5,28,55,21)) then
    l_stmt_num := 50;
    l_from_layer := i_layer_id;
    l_to_layer := i_txfr_layer_id;
    l_from_exp := l_exp1;
    l_to_exp := l_exp2;
    l_from_qty := i_txn_qty;
  else
    l_stmt_num := 60;
    l_from_layer := i_txfr_layer_id;
    l_to_layer := i_layer_id;
    l_from_exp := l_exp2;
    l_to_exp := l_exp1;
    l_from_qty :=-1 * i_txn_qty;
  end if;

  if (g_debug = 'Y') then
         fnd_file.put_line(fnd_file.log,'From layer ID :' || to_char(l_from_layer));
         fnd_file.put_line(fnd_file.log,'To Layer ID : ' || to_char(l_to_layer));
         fnd_file.put_line(fnd_file.log,'From subinv Asset flag : ' || to_char(l_exp1));
         fnd_file.put_line(fnd_file.log,'To subinv Asset flag : ' || to_char(l_exp2));
  end if;
  -- Just in case i_txfr_layer_id is NULL, always set from and to layer
  -- to layer_id for same layer transfers.
  l_stmt_num := 70;
  if (l_layer_chg = 0) then
    l_from_layer := i_layer_id;
    l_to_layer := i_layer_id;
    if (g_debug = 'Y') then
          fnd_file.put_line(fnd_file.log,'No Layer change');
          fnd_file.put_line(fnd_file.log,'From Layer : ' || to_char(l_from_layer));
          fnd_file.put_line(fnd_file.log,'To Layer : ' || to_char(l_to_layer));
    end if;
  end if;

  -- If we are changing layers, then need to create another layer information
  -- in mtl_cst_actual_cost_details.
  l_stmt_num := 80;

  if (l_layer_chg = 1) then
    if (g_debug = 'Y') then
         fnd_file.put_line(fnd_file.log,'Layer change');
    end if;

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
      	cacd.cost_element_id,
      	cacd.level_type,
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
      	cacd.actual_cost,
      	cacd.actual_cost,
      	cacd.actual_cost,
      	'Y',
      	0,
      	'N'
    from mtl_cst_actual_cost_details cacd
    where transaction_id = i_txn_id
    and organization_id = i_org_id
    and layer_id = l_from_layer;

  end if;

  -- if the hook has been used and it is an asset to asset transfer for
  -- the same layer of an asset/expense item then ignore the hook.
  if (l_layer_chg = 0 and l_from_exp = 0 and l_to_exp = 0
      and l_new_cost = 1)
--borrow payback, the following stmt make sure it is not borrow payback txn
      and (l_txn_type_id <> 68 or (l_txn_type_id = 68 and l_layer_chg = 0))then

    l_stmt_num := 90;

    l_ret_val := CSTPAVCP.compute_actual_cost(
				i_org_id,
				i_txn_id,
				i_layer_id,
				NULL,
				NULL,
				NULL,
				i_item_id,
				i_txn_qty,
				i_txn_action_id,
				NULL,
				0,
				0,
				i_user_id,
				i_login_id,
				i_req_id,
				i_prg_appl_id,
				i_prg_id,
				l_err_num,
				l_err_code,
				l_err_msg);
    l_new_cost := 0;
  end if;

  -- For sub transfers of expense items and transfers into an expense
  -- subinventory and asset transfers within the same layer, the receiving
  -- layer has no qty or cost impact.
  -- Fix Bug 798970 by changing no_update_mmt flag to 0, so even if
  -- no cost/quantity change, the mmt will still be updated with
  -- current cost

  if (l_exp_item = 1 or l_to_exp = 1 or
      (l_from_exp = 0 and l_to_exp = 0 and l_layer_chg = 0))
--borrow payback, the following stmt make sure it is not borrow payback txn
      and (l_txn_type_id <> 68 or (l_txn_type_id = 68 and l_layer_chg = 0))then
    l_stmt_num := 100;

    CSTPAVCP.current_average_cost(
				i_org_id,
				i_txn_id,
				l_to_layer,
				i_cost_type,
				i_item_id,
				-1 * l_from_qty,
				i_txn_action_id,
				0,
				0,
				1,
				i_user_id,
				i_login_id,
				i_req_id,
				i_prg_appl_id,
				i_prg_id,
				l_err_num,
				l_err_code,
				l_err_msg);
    if (l_err_num <> 0) then
      -- Error occured
      raise process_error;
    end if;
  end if;

  if (l_new_cost = 1 and l_from_exp = 0)
--borrow payback, the following stmt make sure it is not borrow payback txn
      and (l_txn_type_id <> 68 or (l_txn_type_id = 68 and l_layer_chg = 0))then
    l_stmt_num := 110;

    CSTPAVCP.calc_average_cost(
				i_org_id,
				i_txn_id,
				l_from_layer,
				i_cost_type,
				i_item_id,
				l_from_qty,
				i_txn_action_id,
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
      -- Error occured
      raise process_error;
    end if;
  end if;

  if (l_new_cost = 0 and l_from_exp = 0 and
     (l_to_exp = 1 or (l_to_exp = 0 and l_layer_chg = 1)))
--borrow payback, the following stmt make sure it is not borrow payback txn
      and (l_txn_type_id <> 68 or (l_txn_type_id = 68 and l_layer_chg = 0))then
    l_stmt_num := 120;

    /* Added Bug#4259926 Do not call current_average_cost  */
       if (l_txn_type_id = 43 and i_citw_flag = 1 ) then
          NULL;
       else

           CSTPAVCP.current_average_cost(
				i_org_id,
				i_txn_id,
				l_from_layer,
				i_cost_type,
				i_item_id,
				l_from_qty,
				i_txn_action_id,
				0,
				0,
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
               -- Error occured
            raise process_error;
            end if;
        end if;
  end if;

  if ((l_to_exp = 0 and l_layer_chg = 1) or (l_new_cost =1 and l_to_exp = 0))
--borrow payback, the following stmt make sure it is not borrow payback txn
      and (l_txn_type_id <> 68 or (l_txn_type_id = 68 and l_layer_chg = 0)) then
    l_stmt_num := 130;

    /* Added Bug#4259926 */
       if (l_txn_type_id = 43 and i_citw_flag = 1) then
           l_from_qty :=l_from_qty;
       else
           l_from_qty := -1 * l_from_qty;
       end if;

    CSTPAVCP.calc_average_cost(
				i_org_id,
				i_txn_id,
				l_to_layer,
				i_cost_type,
				i_item_id,
				l_from_qty, /* Added Bug#4259926  */
				i_txn_action_id,
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
      -- Error occured
      raise process_error;
    end if;
  end if;

  if (l_from_exp = 1 and l_to_exp = 0 and l_layer_chg = 0)
      and (l_txn_type_id <> 68 or (l_txn_type_id = 68 and l_layer_chg = 0))then
--then
    l_stmt_num := 140;

    CSTPAVCP.current_average_cost(
				i_org_id,
				i_txn_id,
				l_to_layer,
				i_cost_type,
				i_item_id,
				-1 * l_from_qty,  -- increase qty
				i_txn_action_id,
				0,
				0,
				0,	-- exp to asset, thus update qty
				i_user_id,
				i_login_id,
				i_req_id,
				i_prg_appl_id,
				i_prg_id,
				l_err_num,
				l_err_code,
				l_err_msg);
    if (l_err_num <> 0) then
      -- Error occured
      raise process_error;
    end if;
  end if;

-- borrow payback
-- if it is payback transaction, and no hook is introduced then
  if (l_txn_type_id = 68) and (i_hook <> 1) and ( l_layer_chg = 1)then

-- update return sub with current cost
-- the MCACD for return sub was populated with borrowed cost at
-- the beginning of cost processor, however, we want to
-- store the current cost of the item (from CLCD) into the return sub.
--
  l_stmt_num := 150;

     delete from mtl_cst_actual_cost_details
      where transaction_id = i_txn_id
        and layer_id = l_from_layer;

  l_stmt_num := 160;
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
      	clcd.cost_element_id,
      	clcd.level_type,
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
      	clcd.item_cost,
      	clcd.item_cost,
      	clcd.item_cost,
      	'N',
      	0,
      	'N'
      from cst_layer_cost_details clcd
      where layer_id = l_from_layer;

-- bug 925262, need to update the layer quantity of the payback side

    CSTPAVCP.current_average_cost(
				i_org_id,
				i_txn_id,
				l_from_layer,
				i_cost_type,
				i_item_id,
				l_from_qty,
				i_txn_action_id,
				0,
				0,
				0,
				i_user_id,
				i_login_id,
				i_req_id,
				i_prg_appl_id,
				i_prg_id,
				l_err_num,
				l_err_code,
				l_err_msg);

-- if it is payback transaction, and hook is used then
  elsif ((l_txn_type_id = 68) and (i_hook = 1) and (l_layer_chg = 1)) then
-- if hook is used, need to update the TO SUB's MCACD with the borrow cost

            borrow_cost(i_org_id,
                        i_txn_id,
                        i_user_id,
                        i_login_id,
                        i_req_id,
                        i_prg_appl_id,
                        i_prg_id,
                        i_item_id,
                        1, -- hook is used
                        l_to_layer,
			l_err_num,
			l_err_code,
			l_err_msg);
            if (l_err_num <> 0) then
            -- Error occured
               raise process_error;
            end if;

-- since hook is introduced so we need to
-- reaverage the from sub and then figure out the variance

    -- update new cost and then find variance
    -- base on new cost
    CSTPAVCP.calc_average_cost(
				i_org_id,
				i_txn_id,
				l_from_layer,
				i_cost_type,
				i_item_id,
				l_from_qty,
				i_txn_action_id,
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
      -- Error occured
      raise process_error;
    end if;
  end if;  -- end borrow payback

-- if it is a borrow payback transaction with layer change
-- we need to store the variance in MCACD by calling
-- store_bp_variance, also we need to calculate the
-- new average cost for the to sub.
  if (l_txn_type_id = 68) and ( l_layer_chg = 1)then
    store_bp_variance(i_txn_id,
                      l_from_layer,
                      l_to_layer,
		      l_err_num,
		      l_err_code,
		      l_err_msg);
    if (l_err_num <> 0) then
      -- Error occured
      raise process_error;
    end if;


    CSTPAVCP.calc_average_cost(
				i_org_id,
				i_txn_id,
				l_to_layer,
				i_cost_type,
				i_item_id,
				-1 * l_from_qty,
				i_txn_action_id,
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
      -- Error occured
      raise process_error;
    end if;

  end if;
-- borrow payback end

--Borrow Payback Enhancements Bug 2665290
if (l_txn_type_id = 68 and l_layer_chg = 0) then

   payback_variance(
       i_org_id,
       i_txn_id,
       l_from_layer,
       i_user_id,
       i_login_id,
       i_req_id,
       i_prg_appl_id,
       i_prg_id,
       l_err_num,
       l_err_code,
       l_err_msg);

      if (l_err_num <> 0) then
      -- Error occured
      raise process_error;
    end if;

end if;

--Borrow Payback Enhancements

  if ((l_layer_chg = 1) or (l_from_exp <> l_to_exp)) then
    l_no_update_qty := 0;
  else
    l_no_update_qty := 1;
  end if;

  l_stmt_num := 180;

  /* Populate the cost columns in MMT for the receiving transactions */
  IF i_txn_action_id IN (2,5,28,55)
  THEN
    IF g_debug = 'Y'
    THEN
         fnd_file.put_line(fnd_file.log,'Update mmt for receiving side');
    END IF;

    l_stmt_num := 190;
    SELECT transfer_transaction_id
    INTO   l_txf_txn_id
    FROM   mtl_material_transactions
    WHERE  transaction_id = i_txn_id;

    l_stmt_num := 200;
    UPDATE mtl_material_transactions MMT
    SET    (
             last_update_date,
             last_updated_by,
             last_update_login,
             request_id,
             program_application_id,
             program_id,
             program_update_date,
             actual_cost,
             prior_cost,
             new_cost,
             variance_amount
           )
    =      (
             SELECT SYSDATE,
                    i_user_id,
                    i_login_id,
                    i_req_id,
                    i_prg_appl_id,
                    i_prg_id,
                    SYSDATE,
                    SUM(NVL(MCACD.actual_cost,0)),
                    SUM(NVL(MCACD.prior_cost,0)),
                    SUM(NVL(MCACD.new_cost,0)),
                    SUM(NVL(MCACD.variance_amount,0))
             FROM   mtl_cst_actual_cost_details MCACD
             WHERE  MCACD.transaction_id = i_txn_id
             AND    MCACD.layer_id = l_to_layer
           )
    WHERE  MMT.transaction_id = l_txf_txn_id
    AND    MMT.primary_quantity > 0;
  END IF;
  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, 'Sub_Transfer >>>');
  END IF;

  EXCEPTION
    when process_error then
      o_err_num := l_err_num;
      o_err_code := l_err_code;
      o_err_msg := l_err_msg;
    when others then
      rollback;
      o_err_num := SQLCODE;
      o_err_msg := 'CSTPAVCP.sub_transfer (' || to_char(l_stmt_num) ||
                   '): '
		   || substr(SQLERRM, 1,200);
END sub_transfer;


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
  l_new_cost		NUMBER;
  l_exp_flag		NUMBER;
  l_err_num		NUMBER;
  l_err_code		VARCHAR2(240);
  l_err_msg		VARCHAR2(240);
  l_stmt_num		NUMBER;
  /* Added Bug#4259926 */
  l_txn_action_id       NUMBER;
  l_src_type            NUMBER;
  l_layer_id            NUMBER;
  process_error		EXCEPTION;
BEGIN
  -- initialize local variables
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';

  l_txn_qty := i_txn_qty;

  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, 'Common_Issue_To_WIP <<<');
  END IF;

  -- No user entered new cost is allowed for common issue to wip
  l_new_cost := 0;

  l_stmt_num := 5;
  /* Added Bug#4259926 */
  select transaction_action_id, transaction_source_type_id
  into l_txn_action_id,l_src_type
  from mtl_material_transactions
  where transaction_id = i_txn_id;

  if ( l_txn_action_id = 27 and  I_CITW_FLAG = 1 and l_src_type = 5 ) then
       l_layer_id := i_txfr_layer_id;
  else
  l_layer_id := i_layer_id;
  end if;

-- item cost history, update the transfer_prior_costed_quantity
-- is necessary because we need both the from and the to information
-- in item cost history
	UPDATE mtl_material_transactions mmt
	SET TRANSFER_PRIOR_COSTED_QUANTITY =
	(SELECT
		layer_quantity
	FROM	cst_quantity_layers cql
	WHERE	cql.layer_id = l_layer_id)
	WHERE mmt.transaction_id = i_txn_id
	AND EXISTS (
			SELECT 'X'
			FROM cst_quantity_layers cql
			WHERE cql.layer_id = l_layer_id);

-- item cost history
  l_stmt_num := 10;

  -- We break down common issue to WIP transaction into two parts.
  --   1. common to project sub
  --      treat it as a subinventory transfer
  --   2. project sub to project job issue
  --      insert a separate row in MCACD and call wip cost processor
  --      and distribution processor

/* Added Bug#4259926 */
  if ( l_txn_action_id = 27 and  I_CITW_FLAG = 1 and l_src_type = 5 ) then

            CSTPAVCP.sub_transfer(
                           i_org_id,
                           i_txn_id,
                           i_txfr_layer_id,
                           i_cost_type,
                           i_item_id,
                           l_txn_qty,
                           i_txn_action_id,
                           l_new_cost,
                           NULL,
                           i_layer_id,
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
                   i_txfr_layer_id,
                   cacd.cost_element_id,
                   cacd.level_type,
                   27,
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
                   cacd.new_cost,
                   cacd.new_cost,
                   cacd.new_cost,
                   'N',                        -- check
                   0,
                   'N'
           from mtl_cst_actual_cost_details cacd
           where transaction_id = i_txn_id
           and organization_id = i_org_id
           and layer_id = i_txfr_layer_id
           and transaction_action_id = i_txn_action_id;
  else

     CSTPAVCP.sub_transfer(
			i_org_id,
			i_txn_id,
			i_layer_id,
			i_cost_type,
			i_item_id,
			l_txn_qty,
			i_txn_action_id,
			l_new_cost,
			NULL,
			i_txfr_layer_id,
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

     l_stmt_num := 20;

     -- insert a row in MCACD for WIP issue transaction
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
	   i_txfr_layer_id,
      	   cacd.cost_element_id,
      	   cacd.level_type,
	   1,			-- issue transaction
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
      	   cacd.new_cost,
      	   cacd.new_cost,
      	   cacd.new_cost,
      	   'N',			-- check
      	   0,
      	   'N'
     from mtl_cst_actual_cost_details cacd
     where transaction_id = i_txn_id
       and organization_id = i_org_id
       and layer_id = i_txfr_layer_id
       and transaction_action_id = i_txn_action_id;
  end if;

  l_stmt_num := 30;

  -- figure out project sub asset type, it depends on project job type and
  -- from subinventory asset type.
  if (i_flow_schedule = 1) then
    l_stmt_num := 33;
    select decode(wac.class_type, 1, 0,
                                  3, 0,
                                  6, 0,
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
                                  6, 0,
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

  -- Process WIP issue transaction
 /* Added Bug#4259926 */
 if ( l_txn_action_id = 27 and  i_citw_flag = 1 and l_src_type = 5) then
      NULL;
 else

  CSTPAVCP.current_average_cost(i_org_id,
				i_txn_id,
				i_txfr_layer_id,
				i_cost_type,
				i_item_id,
				l_txn_qty,
				1,		-- wip issue txn
				l_exp_flag,
				0,
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
      -- Error occured
    raise process_error;
    end if;
 end if;

  l_stmt_num := 50;

  CSTPACWP.cost_wip_trx(i_txn_id,
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
  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, 'Common_Issue_To_WIP >>>');
  END IF;

  EXCEPTION
    when process_error then
      o_err_num := l_err_num;
      o_err_code := l_err_code;
      o_err_msg := l_err_msg;
    when others then
      rollback;
      o_err_num := SQLCODE;
      o_err_msg := 'CSTPAVCP.common_issue_to_wip (' || to_char(l_stmt_num) ||
                   '): '
		   || substr(SQLERRM, 1,200);
END common_issue_to_wip;





-- FUNCTION
--  compute_actual_cost		Populate the actual cost details table
--
-- RETURN VALUES
--  integer		1	The actual cost is different from the
--				current average cost.
--			0	The actual cost is the same as the current
--				average cost.

function compute_actual_cost(
  I_ORG_ID	IN	NUMBER,
  I_TXN_ID	IN 	NUMBER,
  I_LAYER_ID	IN	NUMBER,
  I_COST_TYPE	IN	NUMBER,
  I_MAT_CT_ID	IN	NUMBER,
  I_AVG_RATES_ID IN	NUMBER,
  I_ITEM_ID	IN	NUMBER,
  I_TXN_QTY	IN	NUMBER,
  I_TXN_ACTION_ID IN	NUMBER,
  I_TXN_SRC_TYPE IN	NUMBER,
  I_INTERORG_REC IN	NUMBER,
  I_EXP_FLAG	IN	NUMBER,
  I_USER_ID	IN	NUMBER,
  I_LOGIN_ID    IN	NUMBER,
  I_REQ_ID	IN	NUMBER,
  I_PRG_APPL_ID	IN	NUMBER,
  I_PRG_ID	IN 	NUMBER,
  O_Err_Num	OUT NOCOPY	NUMBER,
  O_Err_Code	OUT NOCOPY	VARCHAR2,
  O_Err_Msg	OUT NOCOPY	VARCHAR2
)
return integer IS
  l_txn_cost_exist	NUMBER;
  l_cost_details	NUMBER;
  l_act_cost		NUMBER;
  l_cur_cost		NUMBER;
  l_qty			NUMBER;
  l_level		NUMBER;
  l_ret_val		NUMBER;
  l_err_num		NUMBER;
  l_err_code		VARCHAR2(240);
  l_err_msg		VARCHAR2(240);
  l_stmt_num		NUMBER;
  l_count		NUMBER;
  process_error		EXCEPTION;

  /* EAM Acct Enh Project */
  l_zero_cost_flag	NUMBER;
  l_return_status	VARCHAR2(1);
  l_msg_count		NUMBER;
  l_msg_data		VARCHAR2(8000);
  l_api_message		VARCHAR2(8000);

BEGIN
  -- initialize local variables
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';
  l_txn_cost_exist := 0;
  l_cost_details := 0;

  l_msg_data := NULL;
  l_msg_count := 0;

  l_return_status := fnd_api.g_ret_sts_success;

  l_zero_cost_flag := -1;

  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, '>>>Inside Compute_Actual_Cost');
  END IF;
  l_stmt_num := 10;

  --
  -- Make sure the transaction cost is positive
  --

  Select count(*)
  into l_txn_cost_exist
  from mtl_cst_txn_cost_details
  where transaction_id = i_txn_id
  and organization_id = i_org_id
  /* and transaction_cost >= 0 */; -- modified for bug#3835412

    if (g_debug = 'Y') then
         fnd_file.put_line(fnd_file.log,'>>>MCTCD: '||to_char(l_txn_cost_exist)||' i_txn_id: '||to_char(i_txn_id)||' i_org_id:'||to_char(i_org_id));
    end if;

  if (l_txn_cost_exist > 0) then

    l_ret_val := 1;
    l_stmt_num := 20;
    if (g_debug = 'Y') then
         fnd_file.put_line(fnd_file.log,'>>>Insert into MCACD using MCTCD values');
    end if;

    --
    -- Make sure the mcacd should not have any -ve cost
    --

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
      	i_org_id,
	i_layer_id,
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
      	0,
      	NULL,
      	'Y',
      	0,
      	'N'
    FROM mtl_cst_txn_cost_details ctcd
    WHERE ctcd.transaction_id = i_txn_id
    AND ctcd.organization_id = i_org_id
    /* AND ctcd.transaction_cost >= 0 */; -- modified for bug#3835412

if (g_debug = 'Y') then
    select count(*) into l_count
    from mtl_cst_actual_cost_details
    where transaction_id = i_txn_id
    and organization_id = i_org_id;
         fnd_file.put_line(fnd_file.log,'>>>MCACD: '||to_char(l_count)||' i_txn_id: '||to_char(i_txn_id)||' i_org_id:'||to_char(i_org_id));
end if;

  else
    /* no transaction cost details. copy actual cost from current avg. *
     * for scrap transactions, no transaction cost means 0 cost.       */

    l_ret_val := 0;
    /********************************************************************
     ** Create detail rows in MTL_CST_ACTUAL_COST_DETAILS based on     **
     ** records in CST_LAYER_COST_DETAILS.  Since we are using current **
     ** average the actual cost, prior cost and new cost are all the   **
     ** same.  If detail rows do not exist in CST_LAYER_COST_DETAILS,  **
     ** we will insert a TL material 0 cost layer.		       **
     ********************************************************************/
    if (g_debug = 'Y') then
         fnd_file.put_line(fnd_file.log,'>>>No Txn details in MCTCD');
    end if;

    l_stmt_num := 30;

    select count(*)
    into l_cost_details
    from cst_layer_cost_details
    where layer_id = i_layer_id;

    if ((l_cost_details > 0) and (i_txn_action_id <> 30)) then

      l_stmt_num := 35;
      /* EAM Acct Enh Project */
      CST_Utility_PUB.get_zeroCostIssue_flag (
	p_api_version		=>	1.0,
	x_return_status	=>	l_return_status,
	x_msg_count		=>	l_msg_count,
	x_msg_data		=>	l_msg_data,
	p_txn_id		=>	i_txn_id,
	x_zero_cost_flag	=>	l_zero_cost_flag
	);

      if (l_return_status <> fnd_api.g_ret_sts_success) then
	FND_FILE.put_line(FND_FILE.log, l_msg_data);
	l_api_message := 'get_zeroCostIssue_flag returned unexpected error';
	FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
	FND_MESSAGE.set_token('TEXT', l_api_message);
	FND_MSG_pub.add;
	raise fnd_api.g_exc_unexpected_error;
      end if;

      if (g_debug = 'Y') then
	FND_FILE.PUT_LINE(FND_FILE.LOG,'>>>Zero Cost Issue Flag:'|| to_char(l_zero_cost_flag));
      end if;

      l_stmt_num := 40;
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
	i_layer_id,
      	clcd.cost_element_id,
      	clcd.level_type,
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
      	decode(l_zero_cost_flag, 1, 0, clcd.item_cost),
      	clcd.item_cost,
      	clcd.item_cost,
      	'N',
      	0,
      	'N'
      from cst_layer_cost_details clcd
      where layer_id = i_layer_id;
    else
      l_stmt_num := 50;
      if (g_debug = 'Y') then
           fnd_file.put_line(fnd_file.log,'>>>No cost values, Inserting zero cost in MCACD');
      end if;

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
	i_layer_id,
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
      	0,
      	'N',
      	0,
      	'N');
    end if;
   end if;

  /* Apply material overhead to certain txns which are asset item and
     asset subinventory. */
  if ((i_exp_flag <> 1)
      AND
      ((i_txn_action_id = 27 and i_txn_src_type = 1) /* PO receipt */
      OR
       (i_txn_action_id = 6 and (i_txn_src_type =13 or i_txn_src_type = 1)) /*Change of ownership */
      OR
      (i_txn_action_id = 1 and i_txn_src_type = 1) /* RTV */
      OR
      (i_txn_action_id = 29 and i_txn_src_type = 1) /* Delivery Adj. */
      OR
      (i_txn_action_id = 31 and i_txn_src_type = 5)
	/* WIP completions */
      OR
      (i_txn_action_id = 32 and i_txn_src_type = 5) /* Assembly return */
      OR
      (i_interorg_rec = 1)
     )) then
    l_level := 1;


    apply_material_ovhd(i_org_id,
			i_txn_id,
			i_layer_id,
			i_cost_type,
			i_mat_ct_id,
			i_avg_rates_id,
			i_item_id,
			i_txn_qty,
			i_txn_action_id,
 			l_level,
			i_user_id,
			i_login_id,
			i_req_id,
			i_prg_appl_id,
			i_prg_id,
			l_err_num,
			l_err_code,
			l_err_msg);

    if (l_err_num <> 0) then
      -- Error occured
      raise process_error;
    end if;
    l_ret_val := 1;
  end if;

/*  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, 'Compute_Actual_Cost >>>');
  END IF;*/
  return l_ret_val;

  EXCEPTION
    when process_error then
      o_err_num := l_err_num;
      o_err_code := l_err_code;
      o_err_msg := l_err_msg;
      return l_ret_val;
    when OTHERS then
      rollback;
      o_err_num := SQLCODE;
      o_err_msg := 'CSTPAVCP.compute_actual_cost (' || to_char(l_stmt_num) ||
                   '): '
	           || substr(SQLERRM,1,200);
      return l_ret_val;
END compute_actual_cost;


-- PROCEDURE
--  apply_material_ovhd		Applying this level material overhead based
-- 				on the pre-defined rates in the material
--

procedure apply_material_ovhd(
  I_ORG_ID	IN	NUMBER,
  I_TXN_ID	IN 	NUMBER,
  I_LAYER_ID	IN	NUMBER,
  I_COST_TYPE	IN	NUMBER,
  I_MAT_CT_ID  	IN	NUMBER,
  I_AVG_RATES_ID IN	NUMBER,
  I_ITEM_ID	IN	NUMBER,
  I_TXN_QTY	IN	NUMBER,
  I_TXN_ACTION_ID IN	NUMBER,
  I_LEVEL	IN	NUMBER,
  I_USER_ID	IN	NUMBER,
  I_LOGIN_ID	IN	NUMBER,
  I_REQ_ID	IN	NUMBER,
  I_PRG_APPL_ID	IN	NUMBER,
  I_PRG_ID	IN	NUMBER,
  O_Err_Num	OUT NOCOPY	NUMBER,
  O_Err_Code	OUT NOCOPY	VARCHAR2,
  O_Err_Msg	OUT NOCOPY	VARCHAR2
) IS
  l_mat_ovhds 	NUMBER;
  l_item_cost	NUMBER;
  l_res_id	NUMBER;
  l_err_num		NUMBER;
  l_err_code		VARCHAR2(240);
  l_err_msg		VARCHAR2(240);
  l_stmt_num		NUMBER;
  overhead_error	EXCEPTION;
  avg_rates_no_ovhd	EXCEPTION;
  l_mcacd_ovhd  NUMBER;
  l_ovhd_cost   NUMBER;
  l_elemental_visible varchar2(1);
  l_from_org    NUMBER;
  l_to_org     	NUMBER;
  l_txn_org_id      NUMBER;
  l_txfr_org_id NUMBER;
  l_txn_qty     NUMBER;

  l_earn_moh    NUMBER;
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(240);
  moh_rules_error EXCEPTION;
  l_default_MOH_subelement NUMBER; ---------------Bug 3959770

BEGIN
  -- initialize local variables
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';

/* Added for bug 3959770*/
/* Get the Default MOH sub element of the organization*/

 select DEFAULT_MATL_OVHD_COST_ID
 into l_default_MOH_subelement
 from mtl_parameters
 where organization_id= I_ORG_ID;

  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, 'Apply_Material_Overhead <<<');
  END IF;
  l_earn_moh := 1;
  l_return_status := fnd_api.g_ret_sts_success;
  l_msg_count := 0;

  -- Applying material overhead on the sum(actual_cost) in CACD.  There should
  -- not be any material overhead rows! This check will need to be
  -- removed once we support freight and duty charges at PO receipt.  But right
  -- now if this transaction had this level materail overhead, I don't have
  -- subelement detail so must error out!
  -- When i_level is 1 this level material overhead only. 0 mean both
  -- previous and this level material.
  -- In the current implementation, the i_level will always be 1, meaning
  -- absorb only this level material overhead.

  l_stmt_num := 10;
/* Changes for MOH Absorption Rules engine */
   cst_mohRules_pub.apply_moh(
                              1.0,
                              p_organization_id => i_org_id,
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

  IF(l_earn_moh = 0) THEN

    IF g_debug = 'Y' THEN
      fnd_file.put_line(fnd_file.log, '---Material Overhead Absorption Overridden--');
    END IF;

  ELSE

  l_stmt_num := 11;


  select count(*)
  into l_mat_ovhds
  from mtl_cst_actual_cost_details cacd
  where transaction_id = i_txn_id
  and organization_id = i_org_id
  and layer_id = i_layer_id
  and cost_element_id = 2
  and level_type = decode(i_level,1,1,level_type);

  l_stmt_num := 12;

  select organization_id, transfer_organization_id, primary_quantity
  into l_txn_org_id, l_txfr_org_id, l_txn_qty
  from mtl_material_transactions
  where transaction_id = i_txn_id;

  -- Figure the from and to org for this transaction.
  if (i_txn_action_id = 21) then
     l_from_org := l_txn_org_id;
     l_to_org := l_txfr_org_id;
  elsif (i_txn_action_id = 12) then
     l_from_org := l_txfr_org_id;
     l_to_org := l_txn_org_id;
  elsif (i_txn_action_id =3 and l_txn_qty <0) then
     l_from_org := l_txn_org_id;
     l_to_org := l_txfr_org_id;
  else
     l_from_org := l_txfr_org_id;
     l_to_org := l_txn_org_id;
  end if;

  l_stmt_num := 14;
  -- do elemental visibility check for interorg transfer
  if (i_txn_action_id in (12,21,3)) then
     select NVL(elemental_visibility_enabled,'N')
     into l_elemental_visible
     from mtl_interorg_parameters
     where from_organization_id = l_from_org
     and to_organization_id = l_to_org;
  end if;

  -- this condition is added because we added the interorg transfer elemental
  -- costs visibility enhancement, for all interorg transactions
  -- it is possible that we have data in the material overhead row in MCACD
  -- that is why we don't need to check this for direct interorg transfer and intransit
  -- transactions.
  if not ((i_txn_action_id in (12,21,3)) and (l_elemental_visible = 'Y')) then -- do this check
                                                                               -- only if it is not
                                                                               -- interorg transaction
                                                                               -- with elemental visible
                                    -- because for interorg transaction with elemental visible,
                                    -- overhead might  already be inserted into MCACD.
     if (l_mat_ovhds > 0) then
       raise overhead_error;
     end if;

  end if;

  if (i_mat_ct_id <> i_cost_type) then /* Not average cost type */

    l_stmt_num := 20;

    select nvl(sum(actual_cost),0)
    into l_item_cost
    from mtl_cst_actual_cost_details cacd
    where transaction_id = i_txn_id
    and organization_id = i_org_id
    and layer_id = i_layer_id;

/* Added this check to keep the LIFO/FIFO costing and Average costing in sync.
  The check ensures that the resource ID is not null in CICD before inserting into the
  MACS. If it is null it replaces the value of resource_id for MOH with the default
  value for the same defined in the organization. */
/* Bug 3959770*/

       l_stmt_num := 25;
       select count(*)
       into l_res_id
       from cst_item_cost_details cicd
       where inventory_item_id = i_item_id
          and organization_id = i_org_id
          and cost_type_id = i_mat_ct_Id
          and basis_type in (1,2,5,6)
          and cost_element_id = 2
          and resource_id IS NULL;

       if (l_res_id > 0) then
	if (l_default_MOH_subelement IS NOT NULL) then
	       	update CST_ITEM_COST_DETAILS
	       	set resource_id = l_default_MOH_subelement
	       	where inventory_item_id = i_item_id
	        and organization_id = i_org_id
	        and cost_type_id = i_mat_ct_Id
	        and basis_type in (1,2,5,6)
	        and cost_element_id = 2
	        and resource_id IS NULL;
	else
                raise avg_rates_no_ovhd;
	end if;
       end if;

    l_stmt_num := 30;

    Insert into mtl_actual_cost_subelement(
	transaction_id,
	organization_id,
	layer_id,
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
    select i_txn_id,
	 i_org_id,
	 i_layer_id,
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
	 decode(cicd.basis_type, 1, cicd.usage_rate_or_amount,
			      	 2, cicd.usage_rate_or_amount/abs(i_txn_qty),
				 5, cicd.usage_rate_or_amount * l_item_cost,
				 6, cicd.usage_rate_or_amount * cicd.basis_factor,0),
	 'N'
    from cst_item_cost_details cicd
    where inventory_item_id = i_item_id
    and organization_id = i_org_id
    and cost_type_id = i_mat_ct_Id
    and basis_type in (1,2,5,6)
    and cost_element_id = 2
    and level_type = decode(i_level, 1,1,level_type);

  else /* material overhead cost type is average cost type */
    -- In this case we will charge the material overhead in the average
    -- cost type using the first material overhead in the average rates
    -- cost type.  This function will error out if material overhead
    -- exists in average cost type and none is defined in the average rates
    -- cost type.

    l_stmt_num := 40;
    select count(*)
    into l_mat_ovhds
    from cst_layer_cost_details
    where layer_id = i_layer_id
    and cost_element_id = 2
    and level_type = 1;

    if (l_mat_ovhds >0 ) then /* material overhead exists in the average
				 cost type */
      l_stmt_num := 50;
      select count(*)
      into l_res_id
      from cst_item_cost_details
      where cost_type_id = i_avg_rates_id
      and inventory_item_id = i_item_id
      and organization_id = i_org_id;

      if (l_res_id > 0) then
        l_stmt_num := 60;
        select resource_id
        into l_res_id
        from cst_item_cost_details
        where cost_type_id = i_avg_rates_id
        and inventory_item_id = i_item_id
        and organization_id = i_org_id
        and cost_element_id = 2
	and rownum = 1;
      end if;


   /* Changed this check for bug 3959770*/
	if (l_res_id = 0) then
		raise avg_rates_no_ovhd;
 	 elsif (l_res_id is NULL) then
		if (l_default_MOH_subelement IS NOT NULL) then
			l_res_id := l_default_MOH_subelement;

			update cst_item_cost_details
			set resource_id = l_default_MOH_subelement
			where cost_type_id = i_avg_rates_id
	                and inventory_item_id = i_item_id
	                and organization_id = i_org_id
	                and cost_element_id = 2
			and resource_id IS NULL
	                and rownum =1;
		else
			raise avg_rates_no_ovhd;
        	end if;
	end if ;


      l_stmt_num := 70;
      Insert into mtl_actual_cost_subelement(
	transaction_id,
	organization_id,
	layer_id,
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
      select i_txn_id,
	 i_org_id,
	 i_layer_id,
	 clcd.cost_element_id,
	 clcd.level_type,
	 l_res_id,
	 sysdate,
         i_user_id,
	 sysdate,
	 i_user_id,
   	 i_login_id,
      	 i_req_id,
      	 i_prg_appl_id,
      	 i_prg_id,
      	 sysdate,
	 clcd.item_cost,
	 'N'
      from cst_layer_cost_details clcd
      where layer_id = i_layer_id
      and cost_element_id = 2
      and level_type = 1;
    end if;
  end if;

  l_stmt_num := 80;
  select count(*)
  into l_mat_ovhds
  from mtl_actual_cost_subelement
  where transaction_id = i_txn_id
  and organization_id = i_org_id
  and layer_id = i_layer_id
  and cost_element_id = 2
  and level_type = decode(i_level, 1,1,level_type);


  -- because of the elemental costs visibility functionality
  -- we need to check interorg transfer specially.
  if i_txn_action_id in (12,21,3) and (l_elemental_visible = 'Y')then -- interorg transfer
  l_stmt_num := 83;

     -- check if there is data in material overhead for this transaction
     select count(*)
     into l_mcacd_ovhd
     from mtl_cst_actual_cost_details cacd
     where transaction_id = i_txn_id
     and organization_id = i_org_id
     and layer_id = i_layer_id
     and cost_element_id = 2
     and level_type = decode(i_level,1,1,level_type);

     -- if there is data is MACS then modify MCACD
     -- if there is no data in MACS then we don't need to do anything.
     if (l_mat_ovhds > 0) then
        -- if there is data in mcacd then do an update,
        -- in this case, with overhead data in mcacd,
        -- we added the actual_cost in cost element 2
        -- to the overhead cost and then update MCACD.
        if (l_mcacd_ovhd > 0) then --update mcacd
          l_stmt_num := 85;
          select sum(actual_cost)
          into l_ovhd_cost
          from mtl_actual_cost_subelement
          where transaction_id = i_txn_id
          and organization_id = i_org_id
          and layer_id = i_layer_id
          and cost_element_id = 2;

          l_stmt_num := 87;
          update mtl_cst_actual_cost_details mcacd
          set mcacd.actual_cost = mcacd.actual_cost + l_ovhd_cost
          where mcacd.transaction_id = i_txn_id
          and mcacd.organization_id = i_org_id
          and mcacd.layer_id = i_layer_id
          and mcacd.inventory_item_id = i_item_id
          and mcacd.level_type = 1
          and mcacd.cost_element_id = 2;
        -- if there is no data in MCACD but there is data in MACS then
        -- do an insert the sum of overhead cost into MCACD.
        else -- insert into MCACD.
          l_stmt_num := 89;
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
	     i_layer_id,
  	     2,
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
	     sum(actual_cost),
	     0,
	     NULL,
  	     'Y',
  	     0,
 	     'N'
          from mtl_actual_cost_subelement
          where transaction_id = i_txn_id
          and organization_id = i_org_id
          and layer_id = i_layer_id
          and cost_element_id = 2;
         end if;
      end if;
   else -- the else part handle all the non-interorg transfer
        -- or interorg txn with elemental visibility disabled
    l_stmt_num := 90;
    -- if there is data in MACS, then insert into MCACD.
    if (l_mat_ovhds > 0) then
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
	  i_layer_id,
  	  2,
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
	  sum(actual_cost),
	  0,
	  NULL,
  	  'Y',
  	  0,
 	  'N'
      from mtl_actual_cost_subelement
      where transaction_id = i_txn_id
      and organization_id = i_org_id
      and layer_id = i_layer_id
      and cost_element_id = 2;
    end if;
  end if;
 END IF;

  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, 'Apply_Material_Overhead >>>');
  END IF;

  EXCEPTION
    when avg_rates_no_ovhd then
      rollback;
      o_err_num := 9999;
      o_err_code := 'CST_NO_MAT_OVHDS';
      FND_MESSAGE.set_name('BOM', 'CST_NO_MAT_OVHDS');
      o_err_msg := FND_MESSAGE.Get;
    when overhead_error then
      rollback;
      o_err_num := 9999;
      o_err_code := 'CST_MAT_OVERHEAD';
      FND_MESSAGE.set_name('BOM', 'CST_MAT_OVERHEAD');
      o_err_msg := FND_MESSAGE.Get;
    when moh_rules_error then
      rollback;
      o_err_num := 9999;
      o_err_code := 'CST_RULES_ERROR';
      FND_MESSAGE.set_name('BOM', 'CST_RULES_ERROR');
      o_err_msg := FND_MESSAGE.Get;
    when others then
      rollback;
      o_err_num := SQLCODE;
      o_err_msg := 'CSTPAVCP.apply_material_ovhd (' || to_char(l_stmt_num) ||
                   '): '
		   || substr(SQLERRM, 1,200);

END apply_material_ovhd;

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
  I_TXN_ACTION_ID IN	NUMBER,
  I_NO_UPDATE_MMT IN	NUMBER,
  I_USER_ID	IN	NUMBER,
  I_LOGIN_ID	IN 	NUMBER,
  I_REQ_ID	IN	NUMBER,
  I_PRG_APPL_ID IN	NUMBER,
  I_PRG_ID	IN	NUMBER,
  O_Err_Num	OUT NOCOPY	NUMBER,
  O_Err_Code	OUT NOCOPY	VARCHAR2,
  O_Err_Msg	OUT NOCOPY	VARCHAR2
) IS
  l_txfr_txn_id	NUMBER;
  total_qty	NUMBER;
  l_cur_onhand	NUMBER;
  l_new_onhand	NUMBER;
  l_err_num		NUMBER;
  l_err_code		VARCHAR2(240);
  l_err_msg		VARCHAR2(240);
  l_stmt_num	NUMBER;
  process_error	EXCEPTION;
BEGIN
  -- initialize local variables
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';


  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, '>>>Inside Calc_Average_Cost');
  END IF;
  /********************************************************************
   ** Update mtl_cst_actual_cost_details and update the prior cost   **
   ** to the current average for the elements that exists and insert **
   ** in to mtl_cst_actual_cost_details the current average cost for **
   ** the elements that do not exist.                                **
   ********************************************************************/
  l_stmt_num := 5;

  Update mtl_cst_actual_cost_details cacd
  Set prior_cost = 0,
      new_cost = NULL
  Where transaction_id = i_txn_id
  and organization_id = i_org_id
  and layer_id = i_layer_id
  and transaction_action_id = i_txn_action_id;

  l_stmt_num := 10;

  Update mtl_cst_actual_cost_details cacd
  Set (prior_cost, insertion_flag) =
  (Select clcd.item_cost,
	  'N'
   From cst_layer_cost_details clcd
   Where clcd.layer_id = i_layer_id
   and clcd.cost_element_id = cacd.cost_element_id
   and clcd.level_type = cacd.level_type)
  Where cacd.transaction_id = i_txn_id
  and cacd.organization_id = i_org_id
  and cacd.layer_id = i_layer_id
  and cacd.transaction_action_id = i_txn_action_id
  and exists
	(select 'there is details in clcd'
	from cst_layer_cost_details clcd
	where clcd.layer_id = i_layer_id
	and clcd.cost_element_id = cacd.cost_element_id
	and clcd.level_type = cacd.level_type);

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
	i_org_id,
	i_layer_id,
	clcd.cost_element_id,
	clcd.level_type,
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
      	clcd.item_cost,
	NULL,
      	'N',
      	0,
      	'N'
  from cst_layer_cost_details clcd
  where layer_id = i_layer_id
  and not exists
	(select 'this detail is not in cacd already'
	 from mtl_cst_actual_cost_details cacd
	 where cacd.transaction_id = i_txn_id
	 and cacd.organization_id = i_org_id
	 and cacd.layer_id = i_layer_id
	 and cacd.cost_element_id = clcd.cost_element_id
	 and cacd.level_type = clcd.level_type);


  /********************************************************************
   ** Compute new average cost.					     **
   ********************************************************************/
  l_stmt_num := 20;

  select layer_quantity
  into l_cur_onhand
  from cst_quantity_layers cql
  where cql.layer_id = i_layer_id;

  l_new_onhand := l_cur_onhand + i_txn_qty;

  l_stmt_num := 30;

  Update mtl_cst_actual_cost_details cacd
  Set new_cost =
	decode(sign(l_cur_onhand),-1,
	       decode(sign(i_txn_qty), -1,
		      (cacd.prior_cost*l_cur_onhand + cacd.actual_cost*i_txn_qty)/l_new_onhand,
		      decode(sign(l_new_onhand),-1, cacd.prior_cost,
			     cacd.actual_cost)),
	       decode(sign(i_txn_qty), -1,
		      decode(sign(l_new_onhand), 1,
                            decode(sign((abs(cacd.prior_cost)*l_cur_onhand + abs(cacd.actual_cost)*i_txn_qty)/l_new_onhand),1,
		                   (cacd.prior_cost*l_cur_onhand + cacd.actual_cost*i_txn_qty)/l_new_onhand,
		                   0)
                             ,cacd.actual_cost),
		      (cacd.prior_cost*l_cur_onhand + cacd.actual_cost*i_txn_qty)/l_new_onhand)),
	-- variance amount
      variance_amount =
        decode(sign(l_cur_onhand),
               -1, decode(sign(i_txn_qty),
                          -1, 0,
		          decode(sign(l_new_onhand),
                                 -1, (cacd.actual_cost * i_txn_qty) - (cacd.prior_cost * i_txn_qty),
		      	         (cacd.actual_cost * abs(i_txn_qty)) - ((cacd.prior_cost * abs(l_cur_onhand)) + cacd.actual_cost *l_new_onhand)
                                )
                   ),
	       decode(sign(i_txn_qty),
                      -1, decode(sign(l_new_onhand),
                                 1, decode(sign(abs(cacd.actual_cost * i_txn_qty) - abs(cacd.prior_cost * l_cur_onhand)),
                                           1, (cacd.prior_cost * abs(l_cur_onhand)) - (cacd.actual_cost * abs(i_txn_qty)),
			                   0
                                          ),
		                 (cacd.prior_cost * l_cur_onhand) + (cacd.actual_cost * abs(l_new_onhand)) - (cacd.actual_cost * abs(i_txn_qty))
                                ),
                      0
                     )
              )
  where cacd.transaction_id = i_txn_id
  and cacd.organization_id = i_org_id
  and cacd.layer_id = i_layer_id
  and cacd.transaction_action_id = i_txn_action_id;

  l_stmt_num := 40;

  Update cst_layer_cost_details clcd
  set last_update_date = sysdate,
      last_updated_by = i_user_id,
      last_update_login = i_login_id,
      request_id = i_req_id,
      program_application_id = i_prg_appl_id,
      program_id = i_prg_id,
      program_update_date = sysdate,
      item_cost =
  	(select new_cost
   	from mtl_cst_actual_cost_details cacd
   	where cacd.transaction_id = i_txn_id
   	and cacd.organization_id = i_org_id
   	and cacd.layer_id = i_layer_id
   	and cacd.cost_element_id = clcd.cost_element_id
   	and cacd.level_type = clcd.level_type)
  where clcd.layer_id = i_layer_id;

  l_stmt_num := 50;

  Insert into cst_layer_cost_details(
	layer_id,
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
	item_cost)
  select i_layer_id,
	cacd.cost_element_id,
	cacd.level_type,
	sysdate,
      	i_user_id,
      	sysdate,
      	i_user_id,
      	i_login_id,
      	i_req_id,
      	i_prg_appl_id,
      	i_prg_id,
      	sysdate,
	cacd.new_cost
  from mtl_cst_actual_cost_details cacd
  where cacd.transaction_id = i_txn_id
  and cacd.organization_id = i_org_id
  and cacd.layer_id = i_layer_id
  and cacd.insertion_flag = 'Y';


  /********************************************************************
   ** Update Mtl_Material_Transactions				     **
   ** Need to update prior_costed_quantity now.			     **
   ********************************************************************/
  if (i_no_update_mmt = 0) then

    -- subinventory or staging transfer for receipt side, we need to pass
    -- txfr_txn_id to update proper transaction in MMT.
    /* Changes for VMI. Adding Planning Transfer Transaction */
    if (i_txn_action_id IN (2,5,28,55) and i_txn_qty > 0) then
      select transfer_transaction_id
      into l_txfr_txn_id
      from mtl_material_transactions
      where transaction_id = i_txn_id;
    else
      l_txfr_txn_id := -1;
    end if;

  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, '>>>Calling CSTPAVCP.update_mmt');
  END IF;
    CSTPAVCP.update_mmt(
			i_org_id,
			i_txn_id,
			l_txfr_txn_id,
			i_layer_id,
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
  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, '<<<Returned from CSTPAVCP.update_mmt');
  END IF;
  end if;

  /********************************************************************
   ** Update layer quantity and layer costs information		     **
   ********************************************************************/
  l_stmt_num := 60;
  /* Used the Base Table instead of View Bug 4773025 */
  Update cst_quantity_layers cql
  Set (last_updated_by,
	last_update_date,
	last_update_login,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	layer_quantity,
	update_transaction_id,
	pl_material,
	pl_material_overhead,
	pl_resource,
	pl_outside_processing,
	pl_overhead,
	tl_material,
	tl_material_overhead,
	tl_resource,
	tl_outside_processing,
	tl_overhead,
	material_cost,
	material_overhead_cost,
	resource_cost,
	outside_processing_cost,
	overhead_cost,
	pl_item_cost,
	tl_item_cost,
	item_cost,
	unburdened_cost,
	burden_cost) =
  (SELECT
        i_user_id,
        sysdate,
        i_login_id,
	i_req_id,
      	i_prg_appl_id,
      	i_prg_id,
      	sysdate,
	l_cur_onhand + i_txn_qty,
	i_txn_id,
	SUM(DECODE(LEVEL_TYPE, 2, DECODE(COST_ELEMENT_ID, 1, ITEM_COST, 0), 0)),
        SUM(DECODE(LEVEL_TYPE, 2, DECODE(COST_ELEMENT_ID, 2, ITEM_COST, 0), 0)),
        SUM(DECODE(LEVEL_TYPE, 2, DECODE(COST_ELEMENT_ID, 3, ITEM_COST, 0), 0)),
        SUM(DECODE(LEVEL_TYPE, 2, DECODE(COST_ELEMENT_ID, 4, ITEM_COST, 0), 0)),
        SUM(DECODE(LEVEL_TYPE, 2, DECODE(COST_ELEMENT_ID, 5, ITEM_COST, 0), 0)),
        SUM(DECODE(LEVEL_TYPE, 1, DECODE(COST_ELEMENT_ID, 1, ITEM_COST, 0), 0)),
        SUM(DECODE(LEVEL_TYPE, 1,DECODE(COST_ELEMENT_ID, 2, ITEM_COST, 0), 0)),
        SUM(DECODE(LEVEL_TYPE, 1, DECODE(COST_ELEMENT_ID, 3, ITEM_COST, 0), 0)),
        SUM(DECODE(LEVEL_TYPE ,1, DECODE(COST_ELEMENT_ID ,4, ITEM_COST, 0), 0)),
        SUM(DECODE(LEVEL_TYPE, 1, DECODE(COST_ELEMENT_ID, 5, ITEM_COST, 0), 0)),
        SUM(DECODE(COST_ELEMENT_ID, 1, ITEM_COST, 0)),
        SUM(DECODE(COST_ELEMENT_ID, 2, ITEM_COST, 0)),
        SUM(DECODE(COST_ELEMENT_ID, 3, ITEM_COST, 0)),
        SUM(DECODE(COST_ELEMENT_ID, 4, ITEM_COST, 0)),
        SUM(DECODE(COST_ELEMENT_ID, 5, ITEM_COST, 0)),
        SUM(DECODE(LEVEL_TYPE, 2, ITEM_COST, 0)),
        SUM(DECODE(LEVEL_TYPE, 1, ITEM_COST, 0)),
        SUM(ITEM_COST),
        SUM(DECODE(COST_ELEMENT_ID, 2, DECODE(LEVEL_TYPE, 2, ITEM_COST, 0), ITEM_COST)),
        SUM(DECODE(COST_ELEMENT_ID, 2, DECODE(LEVEL_TYPE, 1, ITEM_COST, 0), 0))
       from CST_LAYER_COST_DETAILS clcd
   where clcd.layer_id = i_layer_id)
  where cql.layer_id = i_layer_id
  and exists
      (select 'there is detail cost'
      from cst_layer_cost_details clcd
      where clcd.layer_id = i_layer_id);

  /********************************************************************
   ** Update Item Cost and Item Cost Details			     **
   ********************************************************************/
  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, '>>>Calling CSTPAVCP.update_item_cost');
  END IF;
  CSTPAVCP.update_item_cost(
			i_org_id,
			i_txn_id,
			i_layer_id,
			i_cost_type,
			i_item_id,
			0,          -- mandatory_update flag is not set
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

  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, '<<<Returned from CSTPAVCP.update_item_cost');
  END IF;
  EXCEPTION
    when process_error then
      o_err_num := l_err_num;
      o_err_code := l_err_code;
      o_err_msg := l_err_msg;
    when others then
      rollback;
      o_err_num := SQLCODE;
      o_err_msg := 'CSTPAVCP.calc_average_cost (' || to_char(l_stmt_num) ||
                   '): '
		   || substr(SQLERRM, 1,200);

END calc_average_cost;

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
  I_TXN_ACTION_ID IN	NUMBER,
  I_EXP_FLAG	IN	NUMBER,
  I_NO_UPDATE_MMT IN	NUMBER,
  I_NO_UPDATE_QTY IN	NUMBER,
  I_USER_ID	IN	NUMBER,
  I_LOGIN_ID	IN	NUMBER,
  I_REQ_ID	IN	NUMBER,
  I_PRG_APPL_ID IN	NUMBER,
  I_PRG_ID	IN	NUMBER,
  O_Err_Num	OUT NOCOPY	NUMBER,
  O_Err_Code	OUT NOCOPY	VARCHAR2,
  O_Err_Msg	OUT NOCOPY	VARCHAR2
) IS
  layer_qty	NUMBER;
  l_err_num		NUMBER;
  l_err_code		VARCHAR2(240);
  l_err_msg		VARCHAR2(240);
  l_stmt_num		NUMBER;
  process_error		EXCEPTION;

BEGIN
  -- initialize local variables
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';


  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, 'Current_Average_Cost <<<');
  END IF;
  /********************************************************************
   ** Update Mtl_Material_Transactions to set actual cost, prior     **
   ** cost, new cost and prior costed quantity.			     **
   ********************************************************************/
  if (i_no_update_mmt = 0) then
    CSTPAVCP.update_mmt(
			i_org_id,
			i_txn_id,
			-1,		-- txfr_txn_id is not applicable
			i_layer_id,
			0,
			i_user_id,
			i_login_id,
			i_req_id,
			i_prg_appl_id,
			i_prg_id,
			l_err_num,
			l_err_code,
			l_err_msg);
  -- handle error case.
    if (l_err_num <> 0) then
      raise process_error;
    end if;
  end if;

  /********************************************************************
   ** Update layer quantity information in cst_quantity_layers.      **
   ** There is no need to update the layer quantity for the 	     **
   ** following transactions:                                        **
   ** 1) wip scrap transactions 				     **
   ** 2) Expense flag = 1					     **
   ********************************************************************/
  if ((i_txn_action_id = 30) or (i_no_update_qty = 1) or (i_exp_flag = 1)
      ) then
    return;
  else

    l_stmt_num := 10;

    Update cst_quantity_layers cql
    set last_update_date = sysdate,
        last_updated_by = i_user_id,
        last_update_login = i_login_id,
        request_id = i_req_id,
        program_application_id = i_prg_appl_id,
        program_id = i_prg_id,
        program_update_date = sysdate,
        layer_quantity = (cql.layer_quantity + decode(i_txn_action_id, 22, -1*abs(i_txn_qty), i_txn_qty)),
        update_transaction_id = i_txn_id
    where layer_id = i_layer_id;
  end if;

  -- If qty is going to be positive, need to reflect item cost in
  -- cst_item_cost table.
  CSTPAVCP.update_item_cost(
			i_org_id,
			i_txn_id,
			i_layer_id,
			i_cost_type,
			i_item_id,
			0,                -- mandatory_update flag is not set
			i_user_id,
			i_login_id,
			i_req_id,
			i_prg_appl_id,
			i_prg_id,
			l_err_num,
			l_err_code,
  			l_err_msg);
  if (l_err_num <> 0) then
    -- Error occured
    raise process_error;
  end if;

  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, 'Current_Average_Cost >>>');
  END IF;

  EXCEPTION
    when process_error then
      o_err_num := l_err_num;
      o_err_code := l_err_code;
      o_err_msg := l_err_msg;
    when others then
      rollback;
      o_err_num := SQLCODE;
      o_err_msg := 'CSTPAVCP.current_average_cost (' || to_char(l_stmt_num) ||
                   '): '
		   || substr(SQLERRM, 1,200);

END current_average_cost;

-- PROCEDURE
--  Update_MMT
--
procedure update_mmt(
  I_ORG_ID	IN	NUMBER,
  I_TXN_ID	IN 	NUMBER,
  I_TXFR_TXN_ID	IN 	NUMBER,
  I_LAYER_ID	IN	NUMBER,
  I_COST_UPDATE	IN	NUMBER,
  I_USER_ID	IN	NUMBER,
  I_LOGIN_ID	IN	NUMBER,
  I_REQ_ID	IN	NUMBER,
  I_PRG_APPL_ID IN	NUMBER,
  I_PRG_ID	IN	NUMBER,
  O_Err_Num	OUT NOCOPY	NUMBER,
  O_Err_Code	OUT NOCOPY	VARCHAR2,
  O_Err_Msg	OUT NOCOPY	VARCHAR2
) IS
  layer_qty		NUMBER;
  l_txn_id		NUMBER;
  l_cost_exists		NUMBER;
  l_citw_flag		NUMBER;
  l_err_num		NUMBER;
  l_err_code		VARCHAR2(240);
  l_err_msg		VARCHAR2(240);
  l_stmt_num		NUMBER;
-- for item cost history
  l_transaction_action_id NUMBER;
  l_item_id             NUMBER;
  l_transfer_cost_grp_id NUMBER;
  l_transfer_txn_id     NUMBER;
  l_from_inv            NUMBER;
  l_to_inv              NUMBER;
-- for item cost history
 l_asset_item_flag     VARCHAR2(1);

BEGIN
  -- initialize local variables
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';

  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, '>>>>Inside Update_MMT');
  END IF;
-- for item cost history

  l_stmt_num := 5;
  Select transaction_action_id
  into   l_transaction_action_id
  from mtl_material_transactions
  where transaction_id = i_txn_id;
-- for item cost history

  -- Since we are processing shipment side of subinventory
  -- transfer, we need to use txfr_txn_id for receipt
  -- transaction in MMT.

  if (i_txfr_txn_id = -1) then
    l_txn_id := i_txn_id;
  else
    l_txn_id := i_txfr_txn_id;
  end if;

  l_stmt_num := 10;

  Select layer_quantity
  into layer_qty
  from cst_quantity_layers cql
  where cql.layer_id = i_layer_id;

  l_stmt_num := 20;

  select count(*)
  into l_cost_exists
  from mtl_cst_actual_cost_details cacd
  where cacd.transaction_id = i_txn_id
  and cacd.organization_id = i_org_id
  and cacd.layer_id = i_layer_id;

  if (l_cost_exists > 0) then
    l_stmt_num := 30;

    -- set common issue to wip flag
    /* Added  for Bug#4259926 check for transaction_action_id = 27 in decode */
    select decode(transaction_action_id, 1,
             decode(transaction_source_type_id, 5,
               decode(cost_group_id, NVL(transfer_cost_group_id, cost_group_id), 0, 1)
               ,0),
              27,decode(transaction_source_type_id, 5,
                          decode(cost_group_id, NVL(transfer_cost_group_id, cost_group_id), 0, 1),
                          0)
             ,0)
    into l_citw_flag
    from mtl_material_transactions
    where transaction_id = i_txn_id;

    -- Added for Bug# 5137993
      -- Actual cost should not be populated for expense item
      l_stmt_num := 33;

      SELECT inventory_asset_flag
        INTO l_asset_item_flag
        FROM mtl_system_items
       WHERE organization_id = i_org_id
         AND inventory_item_id = (SELECT inventory_item_id
                                    FROM mtl_material_transactions
                                   WHERE transaction_id = i_txn_id);
       -- end of changes for Bug# 5137993

    /* Added Bug#4259926 */
      If (i_txfr_txn_id is NULL and l_citw_flag=1 ) Then
          l_txn_id := i_txn_id;
      End if;

    l_stmt_num := 35;
    Update mtl_material_transactions mmt
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
	 variance_amount,
	 prior_costed_quantity,
	 quantity_adjusted) =
    (select sysdate,
	    i_user_id,
	    i_login_id,
	    i_req_id,
	    i_prg_appl_id,
	    i_prg_id,
	    sysdate,
            SUM(DECODE(l_asset_item_flag, 'N', 0, NVL(actual_cost,0))), -- Bug5137993
	    sum(nvl(prior_cost,0)),
	    sum(nvl(new_cost,0)),
	    sum(nvl(variance_amount,0)),
	    layer_qty,
	    decode(i_cost_update,1,layer_qty,NULL)
      from mtl_cst_actual_cost_details cacd
      where cacd.transaction_id = i_txn_id
      and cacd.organization_id = i_org_id
      and cacd.layer_id = i_layer_id
      and cacd.transaction_action_id =
          decode(l_citw_flag, 1, 2,		-- for citw, just select
                 cacd.transaction_action_id))	-- sub_txfr rows
    where mmt.transaction_id = l_txn_id;
  else
    l_stmt_num := 40;

    Update mtl_material_transactions mmt
    set	last_update_date = sysdate,
    	last_updated_by = i_user_id,
        last_update_login = i_login_id,
        request_id = i_req_id,
 	program_application_id = i_prg_appl_id,
	program_id = i_prg_id,
	program_update_date = sysdate,
        actual_cost = 0,
	prior_cost = 0,
 	new_cost = 0,
	variance_amount=0,
	prior_costed_quantity = layer_qty
    where mmt.transaction_id = l_txn_id;
  end if;
-- item cost history for citw, this part is added to fix the problem
-- for common issue to wip, the prior_costed_quantity is populated with
-- the transfer side qty instead of the from side, which is the qty from
-- common cost group

   IF (l_citw_flag = 1) then -- if this is common issue to wip
      l_stmt_num := 42;
      SELECT
         mmt.inventory_item_id
      INTO
         l_item_id
      FROM mtl_material_transactions mmt
      WHERE mmt.transaction_id = i_txn_id;

      l_stmt_num := 44;
      UPDATE mtl_material_transactions mmt
      SET    prior_costed_quantity = (
               SELECT cql.layer_quantity - mmt.primary_quantity
               FROM   cst_quantity_layers cql,
                     mtl_parameters mp
              WHERE  cql.organization_id = i_org_id
              AND    cql.inventory_item_id = l_item_id
              AND    cql.cost_group_id = mp.default_cost_group_id
              AND    mp.organization_id = i_org_id
            )
      WHERE mmt.transaction_id = i_txn_id
      AND   EXISTS (
	      SELECT 'X'
              FROM   cst_quantity_layers cql,
                     mtl_parameters mp
              WHERE  cql.organization_id = i_org_id
	      AND    cql.inventory_item_id = l_item_id
              AND    cql.cost_group_id = mp.default_cost_group_id
              AND    mp.organization_id = i_org_id
           );
   END IF;

-- the added part is mainly for item cost history,
-- for subinventory transfer from expense sub to asset sub
-- eg: from expense SUB A to asset SUB B
-- there will be 2 rows in mmt, say MMT_A for SUB A
-- and MMT_B for SUB B
-- the cost worker will only pick up row MMT_A to process
-- base on the above update statement, it will only update the prior_costed_quantity
-- for row MMT_A
-- however, in item cost history, MMT_B (the asset sub)
-- will use MMT_B.prior_costed_quantity
-- the following part is added to populate MMT_B.prior_costed_quantity
-- when expense to asset happens
-- item cost history stuff for sub transfer

  /* Changes for VMI. Adding Planning Transfer Transaction */
  if (l_transaction_action_id IN (2,5,28,55)) then
-- item cost history stuff
   l_stmt_num := 45;

   SELECT nvl(msi.asset_inventory,-9),
          mmt.transfer_transaction_id,
          mmt.inventory_item_id,
          mmt.transfer_cost_group_id
   INTO l_from_inv,
        l_transfer_txn_id,
        l_item_id,
        l_transfer_cost_grp_id
   FROM mtl_material_transactions mmt,
        mtl_secondary_inventories msi
   WHERE mmt.transaction_id = i_txn_id
   AND mmt.subinventory_code = msi.secondary_inventory_name
   AND mmt.organization_id = msi.organization_id;

   l_stmt_num := 55;
   SELECT nvl(msi.asset_inventory,-9)
   INTO l_to_inv
   FROM mtl_material_transactions mmt,
        mtl_secondary_inventories msi
   WHERE mmt.transaction_id = i_txn_id
   AND nvl(mmt.transfer_subinventory,mmt.subinventory_code) = msi.secondary_inventory_name
   AND mmt.organization_id = msi.organization_id;

-- item cost history stuff
-- from expense to asset sub-transfer
   IF ((l_from_inv = 2) and (l_to_inv = 1))then
        l_stmt_num := 60;
	UPDATE mtl_material_transactions mmt
	SET prior_costed_quantity =
	(SELECT
		layer_quantity
	FROM	cst_quantity_layers cql
	WHERE	cql.organization_id = i_org_id
	AND	cql.inventory_item_id = l_item_id
	AND	cql.cost_group_id = l_transfer_cost_grp_id)
	WHERE mmt.transaction_id = l_transfer_txn_id
	AND EXISTS (
			SELECT 'X'
			FROM cst_quantity_layers cql
			WHERE cql.organization_id = i_org_id
			AND   cql.inventory_item_id = l_item_id
                        AND   cql.cost_group_id = l_transfer_cost_grp_id);


	IF SQL%ROWCOUNT = 0 THEN
          update mtl_material_transactions mmt
		 set prior_costed_quantity = 0
          where  mmt.transaction_id = l_transfer_txn_id;
	END IF;
   END IF;

  END IF;

-- item cost history stuff for sub transfer


/*  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, 'Update_MMT >>>');
  END IF;*/
  EXCEPTION
    when OTHERS then
      rollback;
      o_err_num := SQLCODE;
      o_err_msg := 'CSTPAVCP.update_mmt (' || to_char(l_stmt_num) ||
                   '): '
	           || substr(SQLERRM,1,200);

END update_mmt;

-- PROCEDURE
--   update_item_cost
--
-- There are 3 cases for updating item cost in cicd :
-- 1. Total qty in cql > 0
--    The item cost in cicd = weighted average of item cost in clcd
--                            acrros different layer.
-- 2. Total qty in cql <= 0 and mandatory_update flag is not set (0)
--    Item cost in cicd will not be updated.
-- 3. Total qty in cql <= 0 and mandatory_update flag is set.
--    Item cost will be copied from clcd to cicd.
--    The caller must make sure that the item only exist in common
--    cost group. In other words, the org must have PJM flag disabled.
--    The average_cost_update() routine is the only routine that uses
--    this case. It's added to fix bug ? related to rollup issue.
--
-- bug 1756613, the cost will not be updated if qty is negative irrespective of the
-- organization being project references enabled

PROCEDURE update_item_cost(
  I_ORG_ID	IN	NUMBER,
  I_TXN_ID	IN	NUMBER,
  I_LAYER_ID	IN	NUMBER,
  I_COST_TYPE	IN	NUMBER,
  I_ITEM_ID	IN	NUMBER,
  I_MANDATORY_UPDATE    IN      NUMBER,
  I_USER_ID	IN	NUMBER,
  I_LOGIN_ID	IN	NUMBER,
  I_REQ_ID	IN	NUMBER,
  I_PRG_APPL_ID	IN	NUMBER,
  I_PRG_ID	IN	NUMBER,
  O_Err_Num	OUT NOCOPY	NUMBER,
  O_Err_Code	OUT NOCOPY	VARCHAR2,
  O_Err_Msg	OUT NOCOPY	VARCHAR2
) IS
  total_value   NUMBER;  -- Added for bug 4905189
  total_qty	NUMBER;
  l_err_num		NUMBER;
  l_err_code		VARCHAR2(240);
  l_err_msg		VARCHAR2(240);
  l_stmt_num		NUMBER;
  l_default_MOH_subelement NUMBER;

BEGIN
  -- initialize local variables
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';

 /* Get the Default MOH sub element of the organization*/

 select DEFAULT_MATL_OVHD_COST_ID
 into l_default_MOH_subelement
 from mtl_parameters
 where organization_id= I_ORG_ID;

  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, '>>>>Inside Update_Item_Cost');
  END IF;
  l_stmt_num := 10;

  -- Bug 4905189, added the calculation for total_value
  select nvl(sum(layer_quantity),0), nvl(sum(layer_quantity*nvl(item_cost,0)),0)
  into total_qty, total_value
  from cst_quantity_layers cql
  where cql.inventory_item_id = i_item_id
  and cql.organization_id = i_org_id;

  -- If total quantity is <= 0 and the mandatory_update flag is not set,
  -- don't update cic or cicd. This is case #2 (look explanation above).
  if ( (total_qty <= 0) and (i_mandatory_update = 0) ) then
    return;
  end if;

  -- Bug 4905189, do not allow negative item cost
  if ( (total_qty > 0) and (total_value < 0) ) then
     return;
  end if;

  l_stmt_num := 20;

  Delete from cst_item_cost_details
  where inventory_item_id = i_item_id
  and organization_id = i_org_id
  and cost_type_id = i_cost_type;

  l_stmt_num := 30;

  -- At this point, we left with case 1 and case 3.(look explanation above)
  -- For case 1, total qty > 0 means that sign(total_qty) = 1
  -- For case 3, total qty <= 0 means that sign(total_qty) = 0/-1
  -- Use the sign(total_qty) to differentiate those 2 cases.
  Insert into cst_item_cost_details (
	inventory_item_id,
	organization_id,
	cost_type_id,
	last_update_date,
	last_updated_by,
	creation_date,
	created_by,
	last_update_login,
	level_type,
	usage_rate_or_amount,
	basis_type,
	basis_factor,
	net_yield_or_shrinkage_factor,
	item_cost,
	cost_element_id,
	rollup_source_type,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	resource_id)	-----------------Bug 3959770
  select
	i_item_id,
	i_org_id,
	i_cost_type,
	sysdate,
	i_user_id,
	sysdate,
	i_user_id,
	i_login_id,
	clcd.level_type,
        (sum(clcd.item_cost*decode(sign(total_qty),1,cql.layer_quantity,1)))
           /decode(sign(total_qty),1,total_qty,1), -- modified for bug#3835412
	1,
	1,
	1,
        (sum(clcd.item_cost*decode(sign(total_qty),1,cql.layer_quantity,1)))
           /decode(sign(total_qty),1,total_qty,1), -- modified for bug#3835412
	clcd.cost_element_id,
	1,
	i_req_id,
      	i_prg_appl_id,
      	i_prg_id,
      	sysdate,
	decode(clcd.cost_element_id,2,l_default_MOH_subelement,NULL) --------------Bug 3959770
  from cst_layer_cost_details clcd,
       cst_quantity_layers cql
  where cql.organization_id = i_org_id
  and cql.inventory_item_id = i_item_id
  and cql.layer_id = clcd.layer_id
  group by cost_element_id, level_type;

  l_stmt_num := 40;
  /* Used the Base Table instead of View Bug 4773025 */
    Update cst_item_costs cic
  Set (last_updated_by,
	last_update_date,
	last_update_login,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	pl_material,
	pl_material_overhead,
	pl_resource,
	pl_outside_processing,
	pl_overhead,
	tl_material,
	tl_material_overhead,
	tl_resource,
	tl_outside_processing,
	tl_overhead,
	material_cost,
	material_overhead_cost,
	resource_cost,
	outside_processing_cost,
	overhead_cost,
	pl_item_cost,
	tl_item_cost,
	item_cost,
	unburdened_cost,
	burden_cost) =
  (SELECT
        i_user_id,
        sysdate,
        i_login_id,
	i_req_id,
      	i_prg_appl_id,
      	i_prg_id,
      	sysdate,
	SUM(DECODE(LEVEL_TYPE,2,DECODE(COST_ELEMENT_ID,1,ITEM_COST,0),0)),
        SUM(DECODE(LEVEL_TYPE,2,DECODE(COST_ELEMENT_ID,2,ITEM_COST,0),0)),
        SUM(DECODE(LEVEL_TYPE,2,DECODE(COST_ELEMENT_ID,3,ITEM_COST,0),0)),
        SUM(DECODE(LEVEL_TYPE,2,DECODE(COST_ELEMENT_ID,4,ITEM_COST,0),0)),
        SUM(DECODE(LEVEL_TYPE,2,DECODE(COST_ELEMENT_ID,5,ITEM_COST,0),0)),
        SUM(DECODE(LEVEL_TYPE,1,DECODE(COST_ELEMENT_ID,1,ITEM_COST,0),0)),
        SUM(DECODE(LEVEL_TYPE,1,DECODE(COST_ELEMENT_ID,2,ITEM_COST,0),0)),
        SUM(DECODE(LEVEL_TYPE,1,DECODE(COST_ELEMENT_ID,3,ITEM_COST,0),0)),
        SUM(DECODE(LEVEL_TYPE,1,DECODE(COST_ELEMENT_ID,4,ITEM_COST,0),0)),
        SUM(DECODE(LEVEL_TYPE,1,DECODE(COST_ELEMENT_ID,5,ITEM_COST,0),0)),
        SUM(DECODE(COST_ELEMENT_ID,1,ITEM_COST)),
        SUM(DECODE(COST_ELEMENT_ID,2,ITEM_COST)),
        SUM(DECODE(COST_ELEMENT_ID,3,ITEM_COST)),
        SUM(DECODE(COST_ELEMENT_ID,4,ITEM_COST)),
        SUM(DECODE(COST_ELEMENT_ID,5,ITEM_COST)),
        SUM(DECODE(LEVEL_TYPE,2,ITEM_COST,0)),
        SUM(DECODE(LEVEL_TYPE,1,ITEM_COST,0)),
        SUM(ITEM_COST),
        SUM(DECODE(COST_ELEMENT_ID, 2,DECODE(LEVEL_TYPE,2,ITEM_COST,0), ITEM_COST)),
        SUM(DECODE(COST_ELEMENT_ID, 2,DECODE(LEVEL_TYPE,1,ITEM_COST,0),0))
   from CST_ITEM_COST_DETAILS  cicd
   where cicd.inventory_item_id = i_item_id
   and cicd.organization_id = i_org_id
   and cicd.cost_type_id = i_cost_type)
  where cic.inventory_item_id = i_item_id
  and cic.organization_id = i_org_id
  and cic.cost_type_id = i_cost_type
  and exists
     (select 'there is detail cost'
      from cst_item_cost_details cicd
      where cicd.inventory_item_id = i_item_id
      and cicd.organization_id = i_org_id
      and cicd.cost_type_id = i_cost_type);

/*  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, 'Update_Item_Cost >>>');
  END IF;
*/
EXCEPTION
    when others then
      rollback;
      o_err_num := SQLCODE;
      o_err_msg := 'CSTPAVCP.update_item_cost (' || to_char(l_stmt_num) ||
                   '): '
		   || substr(SQLERRM, 1,200);

END update_item_cost;


-- PROCEDURE
--  Interorg
--  This procedure will compute the transfer cost of an intransit
--  interorg transaction.  It will also compute the transaction cost
--  of this transfer.
procedure interorg(
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
  I_EXP_ITEM       IN   NUMBER,
  O_TXN_QTY     IN OUT NOCOPY   NUMBER,
  O_INTERORG_REC IN OUT NOCOPY  NUMBER,
  O_NO_UPDATE_MMT IN OUT NOCOPY NUMBER,
  O_EXP_FLAG    IN OUT NOCOPY   NUMBER,
  O_HOOK_USED   OUT NOCOPY	NUMBER,
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
  l_std_cost_org        NUMBER;   /* bugfix 3048258 */
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
  l_from_layer_id       NUMBER;
  l_elemental_visible   varchar2(1);
-- elemental visibility
  l_um_rate             NUMBER;
  l_return_status       VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(240);
  l_earn_moh            NUMBER;
  moh_rules_error       EXCEPTION;

  -- Added for bug 2827548
  l_xfer_conv_rate      NUMBER;
  l_new_txn_cost        NUMBER;

  /* added for bug 3679625 */
  l_txfr_txn_id         NUMBER;
  l_txfr_std_exp        NUMBER;
  /* added for bug 3761538 */
  l_to_std_exp          NUMBER;

  /*Added for Actual Cost Enhancement for Inter Org*/
  l_test_mcacd 		NUMBER := 0;
  l_cost_hook_io	NUMBER := 0;
  l_test_clcd		NUMBER := 0;
  l_ave_to_ave          NUMBER := 0;
  no_mcacd_for_hook	EXCEPTION;

BEGIN
  -- initialize local variables
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';
  l_update_std := 0;
  l_snd_qty := o_txn_qty;
  l_std_exp := 0;
  o_hook_used := 0;
  l_ave_to_ave := 0;

  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, '>>>Inside CSTPAVCP.interorg Interorg');
  END IF;
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
  l_std_from_org := standard_cost_org(l_from_org);
  l_stmt_num := 4;
  l_std_to_org := standard_cost_org(l_to_org);

  l_stmt_num := 6;
  select NVL(elemental_visibility_enabled,'N')
  into l_elemental_visible
  from mtl_interorg_parameters
  where from_organization_id = l_from_org
  and to_organization_id = l_to_org;

  l_stmt_num := 7;
  select decode(primary_cost_method, 2,
  		(select decode(primary_cost_method, 2, 1, 0)
       		from mtl_parameters
       		where organization_id = l_from_org),
		0)
  into l_ave_to_ave
  from mtl_parameters
  where organization_id = l_to_org;

  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, '>>>Transaction action:'||to_char(i_txn_action_id)||' From Org:'||to_char(l_from_org)||' To Org:'||to_char(l_to_org));
    fnd_file.put_line(fnd_file.log, '>>>Elemental Visibility: '||to_char(l_elemental_visible));
  END IF;

  l_stmt_num := 10;

  /* Bug 2926258 - changed default to be -1 to support org_id=0 */
  select decode(l_std_from_org, 1, l_from_org,
    decode(l_std_to_org,1,l_to_org,-1))
  into l_std_org
  from dual;


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

  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, '>>>Calling Get_Snd_Rcv_UOM');
  END IF;

  get_snd_rcv_uom(i_item_id, l_from_org, l_to_org, l_snd_uom, l_rcv_uom,
      l_err_num, l_err_code, l_err_msg);
  if (l_err_num <> 0) then
    raise process_error;
  end if;

  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, '<<<Returning from Get_Snd_Rcv_UOM');
  END IF;

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

 IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, '>>>o_interorg_rec:'||to_char(o_interorg_rec));
  END IF;

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

  -- If this is an intransit shipment with FOB point receipt
  -- or if this is an interorg receipt transaction from
  -- another average cost org, or if this is a direct
  -- interorg receipt transaction, then we are all done!!!
  if ((i_txn_action_id = 21 and i_org_id = i_txn_org_id and i_fob_point = 2) or
      (o_interorg_rec = 1 and (i_txn_action_id = 3 or l_std_from_org <> 1)))
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
		-- if the receiving org is standard and item is expense in the std org,
		-- set l_to_std_exp = 1 to later insert into mcacd from mctcd.
		    l_stmt_num := 102;
			select decode(inventory_asset_flag, 'Y', 0, 1)
			into l_to_std_exp
			from mtl_system_items
			where inventory_item_id = i_item_id
			and organization_id = l_std_org;
	end if;
	if (l_to_std_exp = 1) then
	   if g_debug = 'Y' THEN
	     fnd_file.put_line(fnd_file.log, 'Item is Expense in Receiving Std. Org');
	   end if;
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
/* Changes for MOH Absorption engine */
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

          if g_debug = 'Y' THEN
            fnd_file.put_line(fnd_file.log, '--Material Overhead Absorption overridden--');
          end if;
        else
          if g_debug = 'Y' then
            FND_FILE.PUT_LINE(fnd_file.log, to_char(l_stmt_num) || 'Insert into MACS from CICD');
          end if;
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
          select
            -1,
            i_txn_id,
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
      end if;
     end if;

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
  -- in the transafer_transaction_id.

  if (i_txn_action_id = 3) then
    l_stmt_num := 100;

    select transfer_transaction_id
    into l_txn_update_id
    from mtl_material_transactions
    where transaction_id = i_txn_id;
  else
    l_txn_update_id := i_txn_id;
  end if;

  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, '>>>Transaction update id'||to_char(l_txn_update_id));
  END IF;


  -- If we are shipping from a standard cost org to an average cost org, the
  -- transaction cost must be computed at the time of the average cost worker
  -- for the receiving organization.  This is an exception to the general case
  -- where the shipping organization always figures out the transaction cost
  -- and populate the details rows for the receiving org.
  if ((i_txn_action_id = 21 and i_fob_point = 1 and l_to_org = i_org_id)
      OR
      (i_txn_action_id = 12 and i_fob_point = 2 and l_to_org = i_org_id)
      OR
      (i_txn_action_id = 3 and o_txn_qty <0 and l_std_org = i_txn_org_id)) then
    l_compute_txn_cost := l_std_from_org;
    l_cost_type_id := 1;
  elsif ((i_txn_action_id = 21 and i_fob_point = 1 and l_from_org = i_org_id)
         OR
         (i_txn_action_id = 12 and i_fob_point = 2 and l_from_org = i_org_id)
         OR
         (i_txn_action_id = 3 and o_txn_qty <0 and l_from_org = i_org_id))
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
-- get layer id first?
      l_stmt_num := 130;



/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Arrow Cost hook enhancement
We should be calling the actual_cost_hook if the transaction is one of the following:
Only in Average to Average transfers (l_std_org = -1)
Only for asset items (i_exp_item = 0)
FOB Shipment -- shipment    call hook when txn_org_id = org_id
FOB Receipt  -- receipt      call hook when txn_org_id is NOT the org_id
Direct Inter org -- quantity <0
We should always call the hook for the shipping org and NOT the receiving org
o_interorg_rec will need to be zero, it already contains the validations for this cases
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

      IF ((l_ave_to_ave = 1) and (o_interorg_rec=0) and (l_std_org = -1) and (i_txn_action_id IN (3,21,12)) and (i_exp_item = 0)) THEN
            IF g_debug = 'Y' THEN
              fnd_file.put_line(fnd_file.log, '>>>Conditions met to call the actual cost hook');
              fnd_file.put_line(fnd_file.log, '>>>Calling the actual cost hook');
            END IF;
              l_cost_hook_io := CSTPACHK.actual_cost_hook(i_org_id 	=>	i_org_id,
                                                       	  i_txn_id 	=>	i_txn_id,
                                                       	  i_layer_id 	=>	i_layer_id,
                                                       	  i_cost_type 	=>	i_cost_type,
                                                       	  i_cost_method	=>	2,
                                                       	  i_user_id	=>	i_user_id,
                                                      	  i_login_id	=>	i_login_id,
                                                       	  i_req_id	=>	i_req_id,
                                                       	  i_prg_appl_id =>	i_prg_appl_id,
                                                          i_prg_id	=>	i_prg_id,
                                                       	  o_err_num	=>	l_err_num,
                                                       	  o_err_code	=>	l_err_code,
                                                       	  o_err_msg	=>	l_err_msg);

          IF (l_cost_hook_io=1) THEN
                IF g_debug = 'Y' THEN
                    fnd_file.put_line(fnd_file.log, '>>>>Hook has been used. Calling CSTPAVCP.validate_actual_cost_hook');
                END IF;

                CSTPAVCP.validate_actual_cost_hook(i_txn_id	=>	i_txn_id,
						   i_org_id     =>      i_org_id,
                                                   i_layer_id   =>      i_layer_id,
                                                   i_req_id     =>      i_req_id,
                                                   i_prg_appl_id=>      i_prg_appl_id,
                                                   i_prg_id     =>      i_prg_id,
                                                   o_err_num    =>      l_err_num,
                                                   o_err_code   =>      l_err_code,
                                                   o_err_msg    =>      l_err_msg);
                IF (l_err_num <> 0) THEN
                    -- Error occured
                    raise process_error;
                END IF;

                IF g_debug = 'Y' THEN
                     fnd_file.put_line(fnd_file.log, '<<<<Calling CSTPAVCP.validate_actual_cost_hook');
                END IF;

                select sum(actual_cost), layer_id
                into l_snd_txn_cost, l_from_layer_id
                from mtl_cst_actual_cost_details
                where transaction_id= i_txn_id
                and   organization_id= i_org_id
		and   layer_id= i_layer_id
                group by layer_id;

          ELSE
                IF g_debug = 'Y' THEN
                  fnd_file.put_line(fnd_file.log, '>>>Hook not used');
                END IF;
                select item_cost, layer_id
                into l_snd_txn_cost, l_from_layer_id
                from cst_quantity_layers
                where organization_id = l_from_org
                and inventory_item_id = i_item_id
                and cost_group_id = l_from_cost_grp;
          END IF;
      ELSE
        IF g_debug = 'Y' THEN
           fnd_file.put_line(fnd_file.log, '>>>Hook not used');
        END IF;

        select item_cost, layer_id
        into l_snd_txn_cost, l_from_layer_id
        from cst_quantity_layers
        where organization_id = l_from_org
        and inventory_item_id = i_item_id
        and cost_group_id = l_from_cost_grp;
      END IF;
    end if;
  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, '>>>l_snd_txn_cost: '||l_snd_txn_cost||' layer_id: '||l_from_layer_id);
  END IF;

o_hook_used:=l_cost_hook_io;

    -- Get the conversion_rate.
    -- receiving_currency = sending_currency * conversion_rate
    l_stmt_num := 140;

  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, '>>>Calling Get_Snd_Rcv_Rate');
  END IF;

    get_snd_rcv_rate(i_txn_id, l_from_org, l_to_org,
         l_snd_sob_id, l_snd_curr, l_rcv_sob_id, l_rcv_curr,
         l_curr_type,
         l_conv_rate, l_conv_date, l_err_num, l_err_code,
         l_err_msg);

    if (l_err_num <> 0) then
      raise process_error;
    end if;

  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, '<<<Returning from Get_Snd_Rcv_Rate');
  END IF;


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

  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, '>>>Transfer cost: '||to_char(l_txfr_cost)||' Transportation cost: '||to_char(l_trans_cost)||' Sending quantity: '||to_char(l_snd_qty));
  END IF;

    /* TPRICE: If the transfer pricing option is yes, set transfer credit to be zero */
    if (i_tprice_option <> 0) then
       l_txfr_cost := 0;
         IF g_debug = 'Y' THEN
             fnd_file.put_line(fnd_file.log, '>>>Transfer price active setting transfer credit to zero');
         END IF;
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

  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, '>>>Receiving cost: '||to_char(l_rcv_txn_cost));
  END IF;

    /* TPRICE: If the transfter pricing option is to treat the price as the incoming cost,
               insert price into MCTCD */
    if (i_tprice_option = 2) then
       l_rcv_txn_cost := i_txf_price;
       l_elemental_visible := 'N';
 	  IF g_debug = 'Y' THEN
    	     fnd_file.put_line(fnd_file.log, '>>>Transfer price as incomming cost, hook will not be used');
  	  END IF;
    end if;

    if (l_elemental_visible = 'Y') then
 	  IF g_debug = 'Y' THEN
    	     fnd_file.put_line(fnd_file.log, '>>>Calling interorg_elemental_detail');
  	  END IF;   /*BUG 9311174 Modified the way we call inteorg_elemental_detail*/
		    /*            to rectify we call the signature correctly       */
       interorg_elemental_detail(	i_txn_id 		=> 	i_txn_id,
					i_compute_txn_cost 	=> 	l_compute_txn_cost,
				        i_cost_type_id		=>	l_cost_type_id,
					i_from_layer_id		=>	l_from_layer_id,
					i_item_id		=>	i_item_id,
               				i_txn_update_id		=>	l_txn_update_id,
					i_from_org		=>	l_from_org,
					i_to_org		=>	l_to_org,
               				i_snd_qty		=>	l_snd_qty,
					i_txfr_cost		=>	l_txfr_cost,
					i_trans_cost		=>	l_trans_cost,
					i_conv_rate		=>	l_conv_rate,
					i_um_rate		=>	l_um_rate,
              				i_user_id	 	=>	i_user_id,
					i_login_id		=>	i_login_id,
					i_req_id		=>	i_req_id,
					i_prg_appl_id		=>	i_prg_appl_id,
					i_prg_id		=>	i_prg_id,
					i_hook_used		=>	l_cost_hook_io,
					o_err_num		=>	l_err_num,
					o_err_code		=>	l_err_code,
					o_err_msg		=>	l_err_msg);
       if (l_err_num <> 0) then
         raise process_error;
       end if;
 	  IF g_debug = 'Y' THEN
    	     fnd_file.put_line(fnd_file.log, '<<<Returned interorg_elemental_detail');
  	  END IF;
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


  /* Added for Bug #3679625
   * To handle direct transfers from avg to std org, where item/sub is expense
   * in the receiving org */
  if (l_std_org = i_txfr_org_id and i_txn_action_id = 3) then
    l_stmt_num :=  170;
    select decode(inventory_asset_flag, 'Y', 0, 1)
    into l_txfr_std_exp
    from mtl_system_items
    where inventory_item_id = i_item_id
    and organization_id = l_std_org;

    l_stmt_num :=  180;
    select transfer_transaction_id
    into l_txfr_txn_id
    from mtl_material_transactions mmt
    where mmt.transaction_id = i_txn_id;

    l_stmt_num := 190;
    select decode(l_txfr_std_exp,1,1,decode(asset_inventory,1,0,1))
    into l_txfr_std_exp
    from mtl_secondary_inventories msi
        ,mtl_material_transactions mmt
    where mmt.transaction_id = l_txfr_txn_id
    and mmt.organization_id = l_std_org
    and msi.organization_id = l_std_org
    and msi.secondary_inventory_name = mmt.subinventory_code;

    if (l_txfr_std_exp = 1) then
      l_stmt_num :=  200;
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
      /* AND ctcd.transaction_cost >= 0 */; -- modified for bug#3835412

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
  /*end changes for 3679625 */

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
      /* AND ctcd.transaction_cost >= 0 */; -- modified for bug#3835412

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
    end if;

  end if;

/* begin bug 3761538
 * handle intransit interorg transfers with fob pt = shipment,
 * from average costing org to standard costing org
 * where item is expense in the receiving org.
 */
if (l_to_std_exp = 1) then
	if (i_txn_org_id = l_std_org) then
    	select transfer_transaction_id
    	into l_txfr_txn_id
    	from mtl_material_transactions mmt
    	where mmt.transaction_id = i_txn_id;
	end if;

	l_stmt_num :=  260;
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
	/* AND ctcd.transaction_cost >= 0 */; -- modified for bug#3835412

	-- update mmt if this is the receiving transaction id
	if (i_txn_org_id = l_std_org) then
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
/*  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, 'Interorg >>>');
  END IF;
*/

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
      o_err_msg := 'CSTPAVCP.interorg (' || to_char(l_stmt_num) ||
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

  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, '>>>>Inside Get_Snd_Rcv_Rate');
  END IF;
  l_stmt_num := 10;

/* The following FROM clause in the select statement has been commented out
   because we now have to refer CST_ORGANIZATION_DEFINITIONS as a result of the
   impact of the HR-PROFILE option  */

  select set_of_books_id
  into l_snd_sob_id
  /*from org_organization_definitions */
  from cst_organization_definitions
  where organization_id = i_from_org;

  l_stmt_num := 20;

  select currency_code
  into l_snd_curr
  from gl_sets_of_books
  where set_of_books_id = l_snd_sob_id;

  l_stmt_num := 30;

/* The following line in the FROM clause of the select statement has been
   commented out because it will now be refering to cst_organization_definitions   as an impact of the HR-PROFILE option */

  select set_of_books_id
  into l_rcv_sob_id
  /*from org_organization_definitions */
  from cst_organization_definitions
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

/*  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, 'Get_Snd_Rcv_Rate >>>');
  END IF; */
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
      o_err_msg := 'CSTPAVCP.get_snd_rcv_rate (' || to_char(l_stmt_num) ||
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
  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, '>>>>Inside Get_Snd_Rcv_UOM');
  END IF;

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

/*  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, 'Get_Snd_Rcv_UOM >>>');
  END IF; */

  EXCEPTION
    when others then
      rollback;
      o_err_num := SQLCODE;
      o_err_msg := 'CSTPAVCP.get_snd_rcv_uom (' || to_char(l_stmt_num) ||
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
-- the borrow_cost procedure is to find out the
-- average borrowed cost of several borrow transactions
-- and store it in MCTCD.
-- If hook is used, it'll update MCACD with the correct
-- payback cost other than the hook cost.

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
  l_total_bp_qty	NUMBER;
  l_err_num		NUMBER;
  l_err_code		VARCHAR2(240);
  l_err_msg		VARCHAR2(240);
  l_stmt_num		NUMBER;
  l_cost_element        t_cst_element;
  l_count               NUMBER;

BEGIN
  -- initialize local variables
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';

  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, 'Borrow_Cost <<<');
  END IF;
  l_stmt_num := 10;

-- initialize array with 0

   for l_index_counter in 1..10 loop
      l_temp_element_cost(l_index_counter):=0;
      if (l_index_counter <= 5) then
        l_cost_element(l_index_counter) := 0;
      end if;
   end loop;

-- loop through all the payaback txn to find the borrowing cost
-- from MCACD and sum it up.
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
            if c_mcacd_rec.cost_element_id = 1 then
                l_cost_element(1) :=1;
            elsif c_mcacd_rec.cost_element_id = 2 then
                l_cost_element(2) :=2;
            elsif c_mcacd_rec.cost_element_id = 3 then
                l_cost_element(3) :=3;
            elsif c_mcacd_rec.cost_element_id = 4 then
                l_cost_element(4) :=4;
            elsif c_mcacd_rec.cost_element_id = 5 then
                l_cost_element(5) :=5;
            End if;
         END LOOP; -- end looping c_mcacd_rec
         l_total_bp_qty := l_total_bp_qty + abs(c_payback_rec.payback_quantity);
      END LOOP; -- end looping c_payback_rec

-- do a division here to find out the average cost
      for l_index_counter in 1..10 loop
         l_temp_element_cost(l_index_counter):=l_temp_element_cost(l_index_counter) / l_total_bp_qty;
      end loop;

------- populate MCTCD from here
      for l_index_counter in 1..10 loop
         if l_index_counter < 6 then
            l_level_type := 1;
         else
            l_level_type := 2;
         end if;
--  populate mctcd
         if (i_hook = 0) then  -- if no hook is used then pouplate mctcd
            if l_temp_element_cost(l_index_counter) <> 0 then -- if element cost is not 0 then insert into MCTCD
               l_stmt_num := 20;
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
            end if;
             if l_index_counter = 5 then
                 l_count :=0;
                 Select count(*) into l_count
                 from mtl_cst_txn_cost_details
                 where transaction_id = i_txn_id;

                 if (l_count = 0) then
                    for i in 1..5 loop
                      if (l_cost_element(i) <> 0) then
                       /* Insert int MCTCD only if cost element exists in MCACD with zero transaction cost */
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
                               l_cost_element(i),
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
                               0);
                       End if;
                    End loop;
                 End if;
              End if;

         else -- if hook is used
            l_stmt_num := 30;
            if l_temp_element_cost(l_index_counter) <> 0 then -- if element cost <>0 then insert update MCACD
               update mtl_cst_actual_cost_details mcacd
                  set mcacd.actual_cost = l_temp_element_cost(l_index_counter)
                  where mcacd.transaction_id = i_txn_id
                  and mcacd.cost_element_id = decode(mod(l_index_counter,5),0,5,mod(l_index_counter,5))
                  and mcacd.level_type = l_level_type
                  and mcacd.layer_id = i_to_layer;
            else -- if the element cost == 0 then we need to delete MCACD.
               delete from mtl_cst_actual_cost_details mcacd
                where mcacd.transaction_id = i_txn_id
                and mcacd.cost_element_id = decode(mod(l_index_counter,5),0,5,mod(l_index_counter,5))
                and mcacd.level_type = l_level_type
                and mcacd.layer_id = i_to_layer;
            end if;

         end if; -- end checking hook
      end loop;  -- end for looping 10 elements
  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, 'Borrow_Cost >>>');
  END IF;
  EXCEPTION
    when others then
      rollback;
      o_err_num := SQLCODE;
      o_err_msg := 'CSTPAVCP.borrow_cost (' || to_char(l_stmt_num) ||
                   '): '
		   || substr(SQLERRM, 1,200);


END borrow_cost;


PROCEDURE store_bp_variance(
  I_TXN_ID	        IN	NUMBER,
  I_FROM_LAYER_ID	IN	NUMBER,
  I_TO_LAYER_ID         IN      NUMBER,
  O_Err_Num	OUT NOCOPY	NUMBER,
  O_Err_Code	OUT NOCOPY	VARCHAR2,
  O_Err_Msg	OUT NOCOPY	VARCHAR2
)IS
  l_err_num		NUMBER;
  l_err_code		VARCHAR2(240);
  l_err_msg		VARCHAR2(240);
  l_stmt_num		NUMBER;
  L_CUR_COST		NUMBER;
  L_BORROWED_COST	NUMBER;
  L_VARIANCE		NUMBER;

-- the store_bp_variance procedure figure out the
-- variance between the borrowed cost and payback cost
-- by checking the from layer and the to layer
-- from MCACD and store the variance
-- into the from layer's MCACD.

BEGIN
  -- initialize local variables
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';

  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, 'Store_BP_Variance <<<');
  END IF;



   for l_level_type in 1..2 loop
      for l_ce in 1..5 loop
         l_stmt_num := 10;
         select max(mcacd.actual_cost)
           into l_cur_cost
           from mtl_cst_actual_cost_details mcacd
           where mcacd.level_type = l_level_type
           and mcacd.cost_element_id = l_ce
           and mcacd.transaction_id = i_txn_id
           and mcacd.layer_id = i_from_layer_id;
         l_stmt_num := 20;
         select max(mcacd.actual_cost)
           into l_borrowed_cost
           from mtl_cst_actual_cost_details mcacd
           where mcacd.level_type = l_level_type
           and mcacd.cost_element_id = l_ce
           and mcacd.transaction_id = i_txn_id
           and mcacd.layer_id = i_to_layer_id;

            l_variance := nvl(l_cur_cost,0) - nvl(l_borrowed_cost,0);

-- update the variance_amount in MCACD for the from layer.
         l_stmt_num := 30;
         update mtl_cst_actual_cost_details mcacd
            set mcacd.payback_variance_amount = l_variance
            where mcacd.transaction_id = i_txn_id
            and mcacd.cost_element_id = l_ce
            and mcacd.level_type = l_level_type
            and mcacd.layer_id = i_from_layer_id;

      end loop; -- end cost element
   end loop; -- end level_type loop
  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, 'Store_BP_Variance >>>');
  END IF;
  EXCEPTION
    when others then
      rollback;
      o_err_num := SQLCODE;
      o_err_msg := 'CSTPAVCP.store_bp_variance (' || to_char(l_stmt_num) ||
                   '): '
		   || substr(SQLERRM, 1,200);

END store_bp_variance;

PROCEDURE interorg_elemental_detail(
  i_txn_id		IN NUMBER,
  i_compute_txn_cost	IN NUMBER,
  i_cost_type_id	IN NUMBER,
  i_from_layer_id	IN NUMBER,
  i_item_id		IN NUMBER,
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
  i_hook_used		IN NUMBER := 0,
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

  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, '>>>>Inside Interorg_Elemental_Detail');
  END IF;
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

  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, '>>>>From organization is a standard org');
  END IF;

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

  else

    l_stmt_num := 20;
	IF (i_hook_used = 0) THEN
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
	ELSE
  		IF g_debug = 'Y' THEN
    			fnd_file.put_line(fnd_file.log, '>>>>Hook has been used, inserting in MCTCD from MCACD');
  		END IF;
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
      		mcacd.actual_cost*i_conv_rate/i_um_rate,
      		0,
      		0,
      		0
    		from mtl_cst_actual_cost_details mcacd
    		where mcacd.layer_id = i_from_layer_id
		and mcacd.transaction_id = i_txn_id;
	END IF;

  end if;

--bug 4210943 - insert a dummy mctcd record for the transaction if there is no cost defined for the item in the sending org
  if SQL%ROWCOUNT = 0 then
        l_stmt_num := 25;
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
	      0,
	      0,
	      0,
	      0);
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
  /* change for bug 2827548 - currency conversion moved outside of this function */
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

  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, 'Interorg_Elemental_Detail >>>');
  END IF;
  EXCEPTION
    when process_error then
      o_err_num := l_err_num;
      o_err_code := l_err_code;
      o_err_msg := l_err_msg;
    when others then
      rollback;
      o_err_num := SQLCODE;
      o_err_msg := 'CSTPAVCP.interorg_elemental_detail (' || to_char(l_stmt_num)
		   || '): ' || substr(SQLERRM, 1,200);


END interorg_elemental_detail;

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

PROCEDURE Cost_Acct_Events (
                     p_api_version      IN  NUMBER,
                     /*p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,*/
                     p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                     p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                     p_debug            IN  VARCHAR2 ,

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
                     x_err_msg          OUT NOCOPY VARCHAR2) IS

 l_api_name    CONSTANT       VARCHAR2(30) := 'Cost_Acct_Events';
 l_api_version CONSTANT       NUMBER       := 1.0;

 l_msg_count                 NUMBER := 0;
 l_msg_data                  VARCHAR2(8000);

 l_exp_item                  NUMBER   := 0; --0 = asset item
 l_exp_flag                  NUMBER   := 0;
 l_parent_organization_id    NUMBER   := NULL;
 l_parent_transaction_type   NUMBER;
 l_log_in_phy                NUMBER   := 0;
 l_mctcd_count               NUMBER   := 0;

 l_stmt_num                  NUMBER   := 0;
 l_api_message               VARCHAR2(10000);
 l_layer_id                  NUMBER   := -1;
 l_error_num                 NUMBER   := 0;
 l_err_code                  VARCHAR2(240);
 l_err_msg                   VARCHAR2(240);

 l_trx_info                CST_XLA_PVT.t_xla_inv_trx_info;
 l_return_status           varchar2(1);


 CURSOR c_mmt_txns IS
    SELECT mmt.TRANSACTION_ID "TRANSACTION_ID",
           mmt.PRIMARY_QUANTITY "PRIMARY_QUANTITY",
           mmt.TRANSACTION_TYPE_ID "TRANSACTION_TYPE_ID",
           mmt.TRANSACTION_ACTION_ID "TRANSACTION_ACTION_ID",
           mmt.TRANSACTION_SOURCE_TYPE_ID "TRANSACTION_SOURCE_TYPE_ID",
           mmt.ORGANIZATION_ID "ORGANIZATION_ID",
           mmt.TRANSFER_ORGANIZATION_ID "TRANSFER_ORGANIZATION_ID",
           mmt.TRANSACTION_DATE "TRANSACTION_DATE",
           mmt.INVENTORY_ITEM_ID "INVENTORY_ITEM_ID",
           mmt.SUBINVENTORY_CODE "SUBINVENTORY_CODE",
           NVL(mmt.TRANSFER_COST_GROUP_ID,-1) "TRANSFER_COST_GROUP_ID",
           NVL(mmt.COST_GROUP_ID,mp.DEFAULT_COST_GROUP_ID) "COST_GROUP_ID",
           mmt.COSTED_FLAG "COSTED_FLAG",
           mmt.ACCT_PERIOD_ID "ACCT_PERIOD_ID",
           NVL(mmt.PARENT_TRANSACTION_ID, mmt.transaction_id) "PARENT_ID",
           mmt.transaction_quantity "TRANSACTION_QUANTITY",
           NVL(mmt.LOGICAL_TRX_TYPE_CODE, -1) "DROP_SHIP_FLAG",
           NVL(mmt.logical_transaction, 3) "LOGICAL_TRANSACTION",
           mp.primary_cost_method "PRIMARY_COST_METHOD",
           mp.cost_organization_id "COST_ORGANIZATION_ID",
           NVL(mmt.DISTRIBUTION_ACCOUNT_ID, -1) "DISTRIBUTION_ACCOUNT_ID",
           mp.primary_cost_method "COST_TYPE_ID", /* For use as cost_type_id */
           NVL(mp.AVG_RATES_COST_TYPE_ID, -1) "AVG_RATES_COST_TYPE_ID",
           decode(msi.INVENTORY_ASSET_FLAG,'Y',0,1) "EXP_ITEM"
    FROM   mtl_material_transactions mmt,
           mtl_parameters mp,
           mtl_system_items_b msi
    WHERE  mmt.organization_id = mp.organization_id
    AND    mmt.inventory_item_id = msi.inventory_item_id
    AND    mmt.organization_id = msi.organization_id
    AND    (( p_parent_id is not null and
                    mmt.parent_transaction_id = p_parent_id)
            or (p_parent_id is null and p_txn_id is not null and
                mmt.transaction_id = p_txn_id))
    ORDER BY mmt.transaction_id;

    BEGIN
    IF g_debug = 'Y' THEN
      fnd_file.put_line(fnd_file.log, 'Cost_Acct_Events <<<');
    END IF;

    -------------------------------------------------------------------------
    -- Establish savepoint
    -------------------------------------------------------------------------

    SAVEPOINT Cost_Acct_Events;

    -------------------------------------------------------------------------
    -- standard call to check for call compatibility
    -------------------------------------------------------------------------
    IF NOT fnd_api.compatible_api_call (
                              l_api_version,
                              p_api_version,
                              l_api_name,
                              G_PKG_NAME ) then

         RAISE fnd_api.g_exc_unexpected_error;

    END IF;

    -------------------------------------------------------------------------
    -- initialize api return status to success
    -------------------------------------------------------------------------
    x_err_num := 0;

    l_stmt_num := 10;

    -------------------------------------------------------------------------
    -- parent_id or txn_id should be non-null
    -------------------------------------------------------------------------

    if (p_parent_id is NULL and p_txn_id is NULL) then
        x_err_msg := 'Parent and Transaction Id are both null';

        RAISE FND_API.g_exc_error;

    end if;

    -------------------------------------------------------------------------
    -- Open cursor to get all transactions to be cost processed
    -------------------------------------------------------------------------

    FOR c_mmt_txn_rec IN c_mmt_txns LOOP
      l_layer_id := -1; -- Initialize layer ID

      l_stmt_num := 15;
    -------------------------------------------------------------------------
    -- Validate record details so far
    -------------------------------------------------------------------------

      if (c_mmt_txn_rec.distribution_account_id is NULL) then
        l_err_msg := 'No Account exists for txn: ' || c_mmt_txn_rec.transaction_id;
        RAISE FND_API.g_exc_error;
      end if;

      /* If a physical transaction, then it should be the parent */

      if (c_mmt_txn_rec.logical_transaction <> 1 and c_mmt_txn_rec.transaction_type_id <> 20 and
          nvl(c_mmt_txn_rec.parent_id, -1) <> c_mmt_txn_rec.transaction_id) then
        l_err_msg := 'Physical Transaction' ||
                        c_mmt_txn_rec.transaction_id || 'should be the parent';

        RAISE FND_API.g_exc_error;
      end if;


    -------------------------------------------------------------------------
    -- Figure out if an expense item
    -- Figure out if expense subinventory
    -------------------------------------------------------------------------
      l_stmt_num := 17;
      SELECT decode(INVENTORY_ASSET_FLAG,'Y',0,1)
        INTO   l_exp_item
      FROM   MTL_SYSTEM_ITEMS
      WHERE  INVENTORY_ITEM_ID = c_mmt_txn_rec.inventory_item_id
      AND    ORGANIZATION_ID = c_mmt_txn_rec.organization_id;

      if (c_mmt_txn_rec.subinventory_code is null) then
        l_exp_flag := l_exp_item;
        l_stmt_num := 20;
      else
        l_stmt_num := 25;
        SELECT decode(l_exp_item,1,1,decode(ASSET_INVENTORY,1,0,1))
        INTO   l_exp_flag
        FROM   MTL_SECONDARY_INVENTORIES
        WHERE  SECONDARY_INVENTORY_NAME = c_mmt_txn_rec.subinventory_code
        AND    ORGANIZATION_ID = c_mmt_txn_rec.organization_id;
      end if;

      l_stmt_num := 30;

    -------------------------------------------------------------------------
    -- Determine parent organization
    -- Determine type of parent
    -- Determine if this is a logical transaction in the physical organization
    -------------------------------------------------------------------------
      if (p_parent_id = c_mmt_txn_rec.transaction_id OR c_mmt_txn_rec.transaction_type_id = 20) then
        l_parent_organization_id := c_mmt_txn_rec.organization_id;
        if (c_mmt_txn_rec.logical_transaction <> 1) then
          l_parent_transaction_type := 1; -- physical transaction
        end if;
      else
        select organization_id, decode(nvl(logical_transaction, 2), 1, 0, 1)
        into l_parent_organization_id, l_parent_transaction_type
        from mtl_material_transactions
        where transaction_id = p_parent_id;
      end if;

      if (c_mmt_txn_rec.organization_id = l_parent_organization_id and
        c_mmt_txn_rec.logical_transaction = 1 and
        l_parent_transaction_type = 1) then
        l_log_in_phy := 1;
      else
        l_log_in_phy := 0;
      end if;

      if (g_debug = 'Y') then
        fnd_file.put_line (fnd_file.log, 'Parent transaction Type (1-physical, 2-logical):' || l_parent_transaction_type);
        fnd_file.put_line (fnd_file.log, 'Logical transaction in physical org (0-no 1=yes):' || l_log_in_phy );
      end if;

      l_stmt_num := 35;

    -------------------------------------------------------------------------
    --Populate MCACD
    --If MCTCD exists use that
    --If it is a logical transaction in the physical org (this case is possible
    --only for shipment flows) then call procedure compute_mcacd_costs to
    --populate mcacd
    --Ensure that MCACD is not created for SO Issue and RMA OF EXPENSE ITEMS!????
    -------------------------------------------------------------------------

    if (c_mmt_txn_rec.logical_transaction = 1 OR c_mmt_txn_rec.transaction_type_id = 20) then
      select count(*)
      into l_mctcd_count
      from mtl_cst_txn_cost_details
      where transaction_id = c_mmt_txn_rec.transaction_id;

      if (l_mctcd_count = 0) then
        if (c_mmt_txn_rec.transaction_type_id = 20) then
           --Retroactive Price Update
          l_err_msg := 'No details in MCTCD: ' || c_mmt_txn_rec.transaction_id;
          RAISE FND_API.g_exc_error;
        else
          if (l_log_in_phy = 1) then
             /* This is a logical transaction in the parent physical organization -
                that is the Logical Intercompany Shipment in the org where the Physical
                Sales Order Issue was performed */
            Compute_MCACD_Costs(
                     p_api_version      => 1.0,
                     p_org_id   =>   c_mmt_txn_rec.organization_id,
                     p_txn_id   =>  c_mmt_txn_rec.transaction_id ,
                     p_parent_txn_id    => p_parent_id,
                     p_cost_method  =>   c_mmt_txn_rec.primary_cost_method,
                     p_cost_org_id  =>  c_mmt_txn_rec.cost_organization_id,
                     p_cost_type_id  =>   c_mmt_txn_rec.cost_type_id,
                     p_item_id    =>       c_mmt_txn_rec.inventory_item_id,
                     p_txn_action_id   =>  c_mmt_txn_rec.transaction_action_id ,
                     p_exp_item =>  l_exp_item,
                     p_exp_flag   =>  l_exp_flag,
                     p_cost_group_id    =>  c_mmt_txn_rec.cost_group_id,
                     p_rates_cost_type =>  c_mmt_txn_rec.avg_rates_cost_type_id,
                     p_txn_qty    =>   c_mmt_txn_rec.transaction_quantity,
                     p_txn_src_type => c_mmt_txn_rec.transaction_source_type_id,
                     p_user_id    => p_user_id,
                     p_request_id  =>  p_request_id ,
                     p_prog_id  =>   p_prog_id  ,
                     p_prog_app_id  =>   p_prog_app_id ,
                     p_login_id   =>  p_login_id  ,
                     x_layer_id    => l_layer_id ,
                     x_err_num    =>   l_error_num,
                     x_err_code => l_err_code,
                     x_err_msg   =>   l_err_msg);

            if (l_error_num <> 0) then
              raise fnd_api.g_exc_error;
            end if;
          end if;
        end if;
      else
        l_stmt_num := 40;
        /* figure out layer_id */
        if (c_mmt_txn_rec.primary_cost_method <> 1) then
          l_layer_id := CSTPACLM.layer_id(c_mmt_txn_rec.organization_id,
                                       c_mmt_txn_rec.inventory_item_id,
                                       c_mmt_txn_rec.cost_group_id,
                                       l_error_num, l_err_code, l_err_msg);
          -- check error
          if (l_error_num <> 0) then
            raise fnd_api.g_exc_error;
          end if;

          -- create a layer
          if (l_layer_id = 0) then
              l_layer_id := CSTPACLM.create_layer(c_mmt_txn_rec.organization_id,
                                                  c_mmt_txn_rec.inventory_item_id,
                                                  c_mmt_txn_rec.cost_group_id, p_user_id,
                                                  p_request_id, p_prog_id,
                                                  p_prog_app_id,
                                                  c_mmt_txn_rec.transaction_id,
                                                  l_error_num, l_err_code, l_err_msg);
              -- check error
              if (l_layer_id = 0) then
                    raise fnd_api.g_exc_error;
              end if;
            end if;
          end if;

          if (g_debug = 'Y') then
            fnd_file.put_line (fnd_file.log, 'Layer id: ' || l_layer_id);
            fnd_file.put_line (fnd_file.log, 'Transaction id: ' || c_mmt_txn_rec.transaction_id);
          end if;
          l_stmt_num := 41;


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
                             c_mmt_txn_rec.transaction_id,
                             c_mmt_txn_rec.organization_id,
                             l_layer_id,
                             1,
                             1,
                             c_mmt_txn_rec.transaction_action_id,
                             sysdate,
                             p_user_id,
                             sysdate,
                             p_user_id,
                             p_login_id,
                             p_request_id,
                             p_prog_app_id,
                             p_prog_id,
                             sysdate,
                             c_mmt_txn_rec.inventory_item_id,
                             decode(c_mmt_txn_rec.transaction_type_id, 20, ctcd.value_change,ctcd.transaction_cost),
                             NULL,
                             NULL,
                             'N',
                             0,
                             'N'
          FROM mtl_cst_txn_cost_details ctcd
          WHERE transaction_id = c_mmt_txn_rec.transaction_id;

          if (g_debug = 'Y') then
                fnd_file.put_line (fnd_file.log, 'Inserted in mcacd:' || sql%rowcount);
          end if;

          /* Update MMT */

          l_stmt_num := 42;

          Update mtl_material_transactions mmt
            set (last_update_date,
	               last_updated_by,
	               last_update_login,
	               request_id,
	               program_application_id,
	               program_id,
	               program_update_date,
 	               actual_cost,
	               variance_amount) =
            ( select sysdate,
	               p_user_id,
	               p_login_id,
	               p_request_id,
	               p_prog_app_id,
	               p_prog_id,
	               sysdate,
                 sum(nvl(actual_cost,0)),
	               sum(nvl(variance_amount,0))
             from mtl_cst_actual_cost_details cacd
             where cacd.transaction_id = c_mmt_txn_rec.transaction_id)
             where mmt.transaction_id = c_mmt_txn_rec.transaction_id;

      end if; /* mctcd count = 0 */
   -------------------------------------------------------------------------
    -- Call the Distribution Processor
    -- It will not be called for physical parent transactions!!
    -------------------------------------------------------------------------
      l_stmt_num := 45;
      CSTPACDP.cost_txn(c_mmt_txn_rec.organization_id,
                    c_mmt_txn_rec.transaction_id,
                    l_layer_id,
                    0, --fob point
                    l_exp_item,
                    0, --citw_flag,
                    0, --flow_schedule,
                    p_user_id,
                    p_login_id,
                    p_request_id,
                    p_prog_app_id,
                    p_prog_id,
                    0, --tprice_option,
                    0, --txf_price,
                    l_error_num,
                    l_err_code,
                    l_err_msg);
                  l_stmt_num := 50;


      if (l_error_num <> 0 ) then
        if (g_debug = 'Y') then
          fnd_file.put_line (fnd_file.log, 'Error Calling cost_txn');
        end if;
        raise fnd_api.g_exc_error;
      end if;

    end if;  /* c_mmt_txn_rec.logical_transaction = 1 OR c_mmt_txn_rec.transaction_type_id = 20 */

    l_stmt_num := 50;

    /* Create the event in SLA */
    l_trx_info.TRANSACTION_ID       := c_mmt_txn_rec.transaction_id;
    l_trx_info.TRANSACTION_DATE     := c_mmt_txn_rec.transaction_date;
    l_trx_info.TXN_ACTION_ID        := c_mmt_txn_rec.transaction_action_id;
    l_trx_info.TXN_ORGANIZATION_ID  := c_mmt_txn_rec.organization_id;
    l_trx_info.TXN_SRC_TYPE_ID      := c_mmt_txn_rec.transaction_source_type_id;
    l_trx_info.TP                   := 'N';



   l_stmt_num := 60;
    CST_XLA_PVT.Create_INVXLAEvent (
      p_api_version       => 1.0,
      p_init_msg_list     => FND_API.G_FALSE,
      p_commit            => FND_API.G_FALSE,
      p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
      x_return_status     => l_return_status,
      x_msg_count         => l_msg_count,
      x_msg_data          => l_msg_data,
      p_trx_info          => l_trx_info
    );
    IF l_return_status <> 'S' THEN
      l_error_num := -1;
      l_err_code := 'Error raising SLA Event for transaction: '||to_char(c_mmt_txn_rec.transaction_id);
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

 END LOOP;



  /* Update Costed Flag */
  l_stmt_num := 70;
  -- Change to PL/SQL Logic for the performance Bug 4773025
    if (p_parent_id is not null) then
  update mtl_material_transactions
  set costed_flag = NULL
  WHERE parent_transaction_id = p_parent_id;
   else
  update mtl_material_transactions
  set costed_flag = NULL
  WHERE transaction_id = p_txn_id ;
  end if;


 IF g_debug = 'Y' THEN
   fnd_file.put_line(fnd_file.log, 'Cost_Acct_Events >>>');
 END IF;

 EXCEPTION
 when fnd_api.g_exc_error then
 x_err_num := -1;
 x_err_code := l_err_code;
 x_err_msg := 'CSTPAVCP.COST_ACCT_EVENTS:' || '(' || l_stmt_num || '):' ||
               l_err_msg || ':' ||  substr(SQLERRM,1,200);

/* Modified update statement for performance reasons. See bug#3585779*/
if (p_parent_id is null) then
update mtl_material_transactions
set costed_flag =  'E',
error_code = x_err_code,
error_explanation = x_err_msg
 where  (p_txn_id is not null
         and transaction_id = p_txn_id);

elsif (p_parent_id is not null) then
    /* Changed to PL/SQL Logic for performance Bug 4773025 */
    if(p_txn_id is not null) then
    update mtl_material_transactions
    set costed_flag = decode(transaction_id, p_parent_id, 'E', 'N'),
    error_code = x_err_code,
    error_explanation = x_err_msg
    where parent_transaction_id  = p_parent_id or
    (transaction_id = p_parent_id and parent_transaction_id is null) or
    (transaction_id = p_txn_id);
    else
    update mtl_material_transactions
    set costed_flag = decode(transaction_id, p_parent_id, 'E', 'N'),
    error_code = x_err_code,
    error_explanation = x_err_msg
    where parent_transaction_id  = p_parent_id or
    (transaction_id = p_parent_id and parent_transaction_id is null);
    end if;
end if;

 when others then
 x_err_num := -1;
 x_err_code := l_err_code;
 x_err_msg := 'CSTPAVCP.COST_ACCT_EVENTS:' || '(' || l_stmt_num || '):' ||
                substr(SQLERRM,1,200);

/* Modified update statement for performance reasons. See bug#3585779*/
if (p_parent_id is null) then
update mtl_material_transactions
set costed_flag =  'E',
error_code = x_err_code,
error_explanation = x_err_msg,
request_id = p_request_id
 where  (p_txn_id is not null
         and transaction_id = p_txn_id);

elsif (p_parent_id is not null) then
   /* Changed to PL/SQL Logic for performance Bug 4773025 */
   if (p_txn_id is not null) then
   update mtl_material_transactions
   set costed_flag = decode(transaction_id, p_parent_id, 'E', 'N'),
   error_code = x_err_code,
   error_explanation = x_err_msg,
   request_id = p_request_id
   where parent_transaction_id  = p_parent_id or
   (transaction_id = p_parent_id and parent_transaction_id is null) or
   (transaction_id = p_txn_id);
   else
   update mtl_material_transactions
   set costed_flag = decode(transaction_id, p_parent_id, 'E', 'N'),
   error_code = x_err_code,
   error_explanation = x_err_msg,
   request_id = p_request_id
   where parent_transaction_id  = p_parent_id or
   (transaction_id = p_parent_id and parent_transaction_id is null);
   end if;
end if;

 END Cost_Acct_Events;



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
--    08/07/07  vjavli Bug 6328273 fix: Logical I/C Sales Issue avoid     --
--                     zero by checking for shared costing and fetch      --
--                     item cost from parent organization if the current  --
--                     organization is shared costing organization        --
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
                     x_err_msg          OUT NOCOPY VARCHAR2) IS


l_stmt_num           NUMBER;
l_cost_hook          NUMBER := 0;
l_layer_id           NUMBER := -1;
l_count              NUMBER;
l_new_cost           NUMBER;


 l_error_num          NUMBER   := 0;
 l_err_code           VARCHAR2(240);
 l_err_msg            VARCHAR2(240);


BEGIN

 IF g_debug = 'Y' THEN
   fnd_file.put_line(fnd_file.log, 'Compute_MCACD_Costs <<<');
 END IF;

 l_err_code := '';
 l_err_msg  := '';

    -------------------------------------------------------------------------
    -- Initialize message list if p_init_msg_list is set to TRUE
    -------------------------------------------------------------------------

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -------------------------------------------------------------------------
    -- initialize api return status to success
    -------------------------------------------------------------------------
    l_error_num  := 0;

    l_layer_id := x_layer_id;

    l_stmt_num := 10;

    -------------------------------------------------------------------------
    -- Standard Costing Organizations
    -------------------------------------------------------------------------

    -- -----------------------------------------------------------------------------
    -- Bug 6328273 fix: Check for shared costing organization
    -- if p_org_id is equal to p_cost_org_id then it is not a shared std costing org
    -- if p_org_id is not equal to p_cost_org_id then it is a shared std costing org
    -- p_cost_method should be equal to 1 in both the cases
    -- -----------------------------------------------------------------------------
    if (p_cost_method = 1 AND p_org_id = p_cost_org_id) then

     l_stmt_num := 20;
       select count(*)
       into l_count
       from cst_item_cost_details
       where inventory_item_id = p_item_id
       and organization_id = p_org_id
       and cost_type_id = 1;

       if (l_count = 0) then
       /* Insert into MCACD using 0 cost for This Level Material */

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
          insertion_flag,
          variance_amount,
          user_entered)
          values ( p_txn_id,
          p_org_id,
          -1,
          1,
          1,
          p_txn_action_id,
          sysdate,
          p_user_id,
          sysdate,
          p_user_id,
          p_login_id,
          p_request_id,
          p_prog_app_id,
          p_prog_id,
          sysdate,
          p_item_id,
          0,
          'N',
          0,
          'N');

     else
     /* Insert into MCACD cost details from CICD */
      l_stmt_num := 30;
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
           insertion_flag,
           variance_amount,
           user_entered)
           select p_txn_id,
           p_org_id,
           -1,
           cicd.cost_element_id,
           cicd.level_type,
           p_txn_action_id,
           sysdate,
           p_user_id,
           sysdate,
           p_user_id,
           p_login_id,
           p_request_id,
           p_prog_app_id,
           p_prog_id,
           sysdate,
           p_item_id,
           nvl(sum(cicd.item_cost),0),
           'N',
           0,
           'N'
           from cst_item_cost_details cicd
           where organization_id = p_org_id
           and inventory_item_id = p_item_id
           and cost_type_id = 1
           group by cost_element_id, level_type;

       end if;

    -- ---------------------------------------------------------------
    -- Bug 6328273 fix: check for shared standard costing organization
    -- In the current organization, no recs can be found in CICD
    -- Get item cost from parent organization
    -- --------------------------------------------------------------
    elsif (p_cost_method = 1 AND p_org_id <> p_cost_org_id) then
     l_stmt_num := 34;
       select count(*)
       into l_count
       from cst_item_cost_details
       where inventory_item_id = p_item_id
       and organization_id = p_cost_org_id
       and cost_type_id = 1;

       if (l_count = 0) then
       /* Insert into MCACD using 0 cost for This Level Material */

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
          insertion_flag,
          variance_amount,
          user_entered)
          values ( p_txn_id,
          p_org_id,
          -1,
          1,
          1,
          p_txn_action_id,
          sysdate,
          p_user_id,
          sysdate,
          p_user_id,
          p_login_id,
          p_request_id,
          p_prog_app_id,
          p_prog_id,
          sysdate,
          p_item_id,
          0,
          'N',
          0,
          'N');

     else
     /* Insert into MCACD cost details from CICD */
      l_stmt_num := 38;
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
           insertion_flag,
           variance_amount,
           user_entered)
           select p_txn_id,
           p_org_id,
           -1,
           cicd.cost_element_id,
           cicd.level_type,
           p_txn_action_id,
           sysdate,
           p_user_id,
           sysdate,
           p_user_id,
           p_login_id,
           p_request_id,
           p_prog_app_id,
           p_prog_id,
           sysdate,
           p_item_id,
           nvl(sum(cicd.item_cost),0),
           'N',
           0,
           'N'
           from cst_item_cost_details cicd
           where organization_id = p_cost_org_id
           and inventory_item_id = p_item_id
           and cost_type_id = 1
           group by cost_element_id, level_type;

       end if;

   else /* Average or FIFO/LIFO organization */
    -------------------------------------------------------------------------
    -- Create layers against the physical transaction
    -------------------------------------------------------------------------

      l_stmt_num := 40;

      l_layer_id := CSTPACLM.layer_id(p_org_id,
                                      p_item_id,
                                      p_cost_group_id,
                                      l_error_num, l_err_code, l_err_msg);
       -- check error
       if (l_error_num <> 0) then
             raise fnd_api.g_exc_error;
       end if;

       -- create a layer
       if (l_layer_id = 0) then
              l_layer_id := CSTPACLM.create_layer(p_org_id,
                                                  p_item_id,
                                                  p_cost_group_id, p_user_id,
                                                  p_request_id, p_prog_id,
                                                  p_prog_app_id,
                                                  p_parent_txn_id,
                                                  l_error_num, l_err_code, l_err_msg);
                -- check error
                if (l_layer_id = 0) then
                    raise fnd_api.g_exc_error;
                end if;
        end if;


    l_stmt_num := 50;

    -------------------------------------------------------------------------
    -- Call cost hook for asset items
    -------------------------------------------------------------------------

     if(p_exp_item = 0 ) then

        l_cost_hook := CSTPACHK.actual_cost_hook(p_org_id,
                                                 p_txn_id,
                                                 l_layer_id,
                                                 p_cost_type_id,
                                                 p_cost_method,
                                                 p_user_id,
                                                 p_login_id,
                                                 p_request_id,
                                                 p_prog_app_id,
                                                 p_prog_id,
                                                 l_error_num,
                                                 l_err_code,
                                                 l_err_msg);
    IF (l_cost_hook = 1) THEN
                IF g_debug = 'Y' THEN
                    fnd_file.put_line(fnd_file.log, '>>>>Hook has been used. Calling CSTPAVCP.validate_actual_cost_hook');
                END IF;

                CSTPAVCP.validate_actual_cost_hook(i_txn_id	=>	p_txn_id,
						   i_org_id     =>      p_org_id,
                                                   i_layer_id   =>      l_layer_id,
                                                   i_req_id     =>      p_request_id,
                                                   i_prg_appl_id=>      p_prog_app_id,
                                                   i_prg_id     =>      p_prog_id,
                                                   o_err_num    =>      l_error_num,
                                                   o_err_code   =>      l_err_code,
                                                   o_err_msg    =>      l_err_msg);
    END IF;
        if (l_error_num <> 0) then
          raise fnd_api.g_exc_error;
        end if;
     end if;

    -------------------------------------------------------------------------
    -- Average Costing org
    -------------------------------------------------------------------------
     l_stmt_num := 60;

     if (p_cost_method = 2) then

        if (l_cost_hook = 0) then
             l_new_cost := compute_actual_cost( p_org_id,
                                p_txn_id,
                                l_layer_id,
                                p_cost_type_id,
                                p_rates_cost_type,
                                p_rates_cost_type,  -----CHECK THIS!
                                p_item_id,
                                p_txn_qty,
                                p_txn_action_id,
                                p_txn_src_type,
                                0,
                                p_exp_flag,
                                p_user_id,
                                p_login_id,
                                p_request_id,
                                p_prog_app_id,
                                p_prog_id,
                                l_error_num,
                                l_err_code,
                                l_err_msg);
              if (l_error_num <> 0) then
                      raise fnd_api.g_exc_error;
              end if;

         else
            l_new_cost := 1;

         end if;

         l_stmt_num := 70;

         if (l_new_cost = 1) then
             /* Reaverage Costs */
                 calc_average_cost(
                                p_org_id,
                                p_txn_id,
                                l_layer_id,
                                p_cost_type_id,
                                p_item_id,
                                p_txn_qty,
                                p_txn_action_id,
                                0,
                                p_user_id,
                                p_login_id,
                                p_request_id,
                                p_prog_app_id,
                                p_prog_id,
                                l_error_num,
                                l_err_code,
                                l_err_msg);

                  if (l_error_num <> 0) then
                        raise fnd_api.g_exc_error;
                  end if;
         else

         l_stmt_num := 80;
        /* use current costs */
                  current_average_cost(
                                p_org_id,
                                p_txn_id,
                                l_layer_id,
                                p_cost_type_id,
                                p_item_id,
                                p_txn_qty,
                                p_txn_action_id,
                                p_exp_flag,
                                0,--update mmt flag
                                0,
                                p_user_id,
                                p_login_id,
                                p_request_id,
                                p_prog_app_id,
                                p_prog_id,
                                l_error_num,
                                l_err_code,
                                l_err_msg);

                  if (l_error_num <> 0) then
                         raise fnd_api.g_exc_error;
                  end if;
       end if;

     elsif (p_cost_method in (5,6)) then
     l_stmt_num := 90;
       /* FIFO/LIFO cost method */

    -------------------------------------------------------------------------
    -- FIFO/LIFO Costing organizations
    -------------------------------------------------------------------------

           l_new_cost := CSTPLENG.compute_layer_actual_cost(
                                     p_org_id,
                                     p_cost_method,
                                     p_txn_id,
                                     l_layer_id,
                                     l_cost_hook,
                                     p_cost_type_id,
                                     p_rates_cost_type,
                                     P_rates_cost_type,
                                     p_item_id,
                                     p_txn_qty,
                                     p_txn_action_id,
                                     p_txn_src_type,
                                     NULL,
                                     p_exp_flag,
                                     p_user_id,
                                     p_login_id,
                                     p_request_id,
                                     p_prog_app_id,
                                     p_prog_id,
                                     l_error_num,
                                     l_err_code,
                                     l_err_msg);

            if (l_error_num <> 0) then
                raise fnd_api.g_exc_error;
            end if;

            l_stmt_num := 50;

            CSTPLENG.calc_layer_average_cost(p_org_id,
						p_txn_id,
						l_layer_id,
						p_cost_type_id,
						p_item_id,
						p_txn_qty,
						p_txn_action_id,
                                                l_cost_hook,
						0,
                                                0,
						p_user_id,
						p_login_id,
						p_request_id,
						p_prog_app_id,
						p_prog_id,
						l_error_num,
						l_err_code,
						l_err_msg);


             if (l_error_num <> 0) then
                    raise fnd_api.g_exc_error;
             end if;
    end if;

    l_stmt_num := 100;

    -------------------------------------------------------------------------
    -- Need to update the parent physical transaction im MMT.
    -- update prior_cost, ew_cost, variance_amount
    -- use the MMT of logical transacion to update corresponding parent.
    -------------------------------------------------------------------------

    Update mtl_material_transactions mmt
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
	 variance_amount,
	 prior_costed_quantity,
	 quantity_adjusted) =
    (select sysdate,
	    p_user_id,
	    p_login_id,
	    p_request_id,
	    p_prog_app_id,
	    p_prog_id,
	    sysdate,
	    mmt2.actual_cost,
	    mmt2.prior_cost,
	    mmt2.new_cost,
	    mmt2.variance_amount,
	    mmt2.prior_costed_quantity,
	    mmt2.quantity_adjusted
      from mtl_material_transactions mmt2
      where mmt2.transaction_id = p_txn_id
      and mmt2.organization_id = p_org_id)
    where mmt.transaction_id = p_parent_txn_id;


 end if;

    x_layer_id := l_layer_id ;


 IF g_debug = 'Y' THEN
   fnd_file.put_line(fnd_file.log, 'Compute_MCACD_Costs >>>');
 END IF;

EXCEPTION

when fnd_api.g_exc_error then
 x_err_num := -1;
 x_err_code := l_err_code;
 x_err_msg := 'CSTPAVCP.COMPUTE_MCACD_COSTS:' || '(' || l_stmt_num || '):' ||
               l_err_msg;


 when others then
 x_err_num := -1;
 x_err_code := l_err_code;
 x_err_msg := 'CSTPAVCP.COMPUTE_MCACD_COSTS:' || '(' || l_stmt_num || '):' ||
               l_err_msg;

END Compute_MCACD_Costs;

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


/* Borrow Payback Variance Enhancements */
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
  O_Err_Msg     OUT NOCOPY      VARCHAR2)
IS

cursor c_payback_txn(c_cur_txn_id number) is
       select pbp.borrow_transaction_id,
              pbp.payback_quantity
         from pjm_borrow_paybacks pbp
         where pbp.payback_transaction_id = c_cur_txn_id;

-- this cursor is to find out all the mcacd data
-- for a specific transaction_id
cursor c_mcacd_data (c_transaction_id number) is
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
       and mcacd.layer_id = i_from_layer;

  type t_cst_element is table of number
        index by binary_integer;

  l_temp_element_cost t_cst_element;
  l_level_type		NUMBER;
  l_total_bp_qty	NUMBER;
  l_err_num		NUMBER;
  l_err_code		VARCHAR2(240);
  l_err_msg		VARCHAR2(240);
  l_stmt_num		NUMBER;
  l_variance     NUMBER;
  l_cur_cost     NUMBER;
  l_borrowed_Cost  NUMBER;

BEGIN
  -- initialize local variables
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';

  l_stmt_num := 10;
 IF g_debug = 'Y' THEN
   fnd_file.put_line(fnd_file.log, 'Payback_Variance <<<');
 END IF;

-- initialize array with 0

   for l_index_counter in 1..10 loop
      l_temp_element_cost(l_index_counter):=0;
   end loop;

   l_stmt_num := 10;

-- loop through all the payaback txn to find the borrowing cost
-- from MCACD and sum it up.
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
         END LOOP; -- end looping c_mcacd_rec
         l_total_bp_qty := l_total_bp_qty + abs(c_payback_rec.payback_quantity);
      END LOOP; -- end looping c_payback_rec

      l_stmt_num := 20;

-- do a division here to find out the average cost
      for l_index_counter in 1..10 loop
         l_temp_element_cost(l_index_counter):=l_temp_element_cost(l_index_counter) / l_total_bp_qty;
      end loop;

      l_stmt_num := 30;

  for l_index_counter in 1..10 loop
        l_stmt_num := 40;

        if (l_index_counter < 6) then
           l_level_type :=1;
        else
           l_level_type :=2;
        end if;

         select max(mcacd.actual_cost)
           into l_cur_cost
           from mtl_cst_actual_cost_details mcacd
           where mcacd.level_type = l_level_type
           and mcacd.cost_element_id = decode(mod(l_index_counter,5),0,5,mod(l_index_counter,5))
           and mcacd.transaction_id = i_txn_id
           and mcacd.layer_id = i_from_layer;

           l_stmt_num := 20;

           select   l_temp_element_cost(l_index_counter)
           into l_borrowed_cost
           from dual;

          l_variance := nvl(l_cur_cost,0) - nvl(l_borrowed_cost,0);

          update mtl_cst_actual_cost_details mcacd
          set mcacd.payback_variance_amount = l_variance
          where mcacd.transaction_id = i_txn_id
          and mcacd.cost_element_id = decode(mod(l_index_counter,5),0,5,mod(l_index_counter,5))
          and mcacd.level_type = l_level_type
          and mcacd.layer_id = i_from_layer;
  end loop;

 IF g_debug = 'Y' THEN
   fnd_file.put_line(fnd_file.log, 'Payback_Variance >>>');
 END IF;
  EXCEPTION
    when others then
      rollback;
      o_err_num := SQLCODE;
      o_err_msg := 'CSTPAVCP.payback_variance (' || to_char(l_stmt_num) ||
                   '): '
		   || substr(SQLERRM, 1,200);


END payback_variance;
--------------------------------------------------------------------------
-- Procedure:
-- Cost_LogicalSOReceipt
--
-- Description:
-- Procedure to cost Logical Receipt Transaction that is created in the
-- Receiving Organization when there is a Internal Order Issue
-- transaction to an Expense destination.
-- This is called by the Cost workers of all cost methods to
-- insert the transaction details into MCACD which is later used
-- to create distributions and do cost collection if projects are
-- enabled.
--
-- Created:
-- 11i.10                 Vinit
---------------------------------------------------------------------------

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
            ) IS

l_actual_cost           NUMBER;
l_layer_id              NUMBER;
l_cost_method           NUMBER;
l_logical_txn_id        NUMBER;
l_logical_org_id        NUMBER;
l_parent_org_id         NUMBER;
l_logical_cost_group_id NUMBER;
l_item_id               NUMBER;
l_stmt_num              NUMBER;

l_primary_quantity      NUMBER;
l_txn_date              DATE;
l_txn_src_id            NUMBER;
l_txn_src_typ_id        NUMBER;
l_txn_typ_id            NUMBER;
l_txn_act_id            NUMBER;
l_alt_curr              VARCHAR2(15);
l_pri_curr              VARCHAR2(15);
l_curr_conv_rate        NUMBER;
l_curr_conv_date        DATE;
l_curr_conv_type        VARCHAR2(30);
l_debit_account         NUMBER;
l_credit_account        NUMBER;
l_set_of_books_id       NUMBER;
l_ou_id                 NUMBER;
l_encumbrance_flag FINANCIALS_SYSTEM_PARAMS_ALL.PURCH_ENCUMBRANCE_FLAG%TYPE;

l_enc_amount            NUMBER;
l_enc_account           NUMBER;
l_credit_line_type      NUMBER;
l_return_status         VARCHAR2(1);
l_return_message       VARCHAR2(1000);

l_conversion_rate       NUMBER;
l_conversion_type       VARCHAR2(30);
l_sending_curr          VARCHAR2(15);

l_exp_item              MTL_SYSTEM_ITEMS.INVENTORY_ASSET_FLAG%TYPE;
l_exp_flag              VARCHAR2(1);
l_subinventory_code     MTL_MATERIAL_TRANSACTIONS.SUBINVENTORY_CODE%TYPE;


l_err_num               NUMBER;
l_err_code              VARCHAR2(240);
l_err_msg               VARCHAR2(240);

/* FP Bug 6607845 fix */
l_dr_acct_line_type     NUMBER;
l_cr_acct_line_type     NUMBER;
l_db_account            NUMBER;
l_subinv_code           VARCHAR2(10);
l_exp_sub               NUMBER;


INSERT_ACCT_ERROR       EXCEPTION;
INSERT_MCACD_ERROR      EXCEPTION;
NO_CURR_CONV_RATE_FOUND EXCEPTION;
COST_HOOK_ACCOUNT_ERROR EXCEPTION;

-- Cursor to get expense or not expense sub inventory
CURSOR c_exp_sub(c_subinventory_code  VARCHAR2
                ,c_organization_id    NUMBER
                )
IS
SELECT
  DECODE(asset_inventory,1,0,1)
FROM mtl_secondary_inventories
WHERE secondary_inventory_name = c_subinventory_code
  AND organization_id = c_organization_id;


--
-- Start INVCONV umoogala
-- Bug 5349860: Internal Order issues to exp can also happen between
-- process and discrete orgs. If the receiving org is process org,
-- then do not do any accounting as it will be taken care by OPM.
--
l_parent_org_process_flag  VARCHAR2(1);
l_logical_org_process_flag VARCHAR2(1);
l_pd_xfer_ind              VARCHAR2(1);
l_transfer_price           NUMBER;
l_trx_info                 CST_XLA_PVT.t_xla_inv_trx_info; /* For SLA Event Creation */
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(8000);

BEGIN
  IF g_debug = 'Y' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'CSTPAVCP.Cost_LogicalSOReceipt <<<');
  END IF;

  -- Initialize Error Variables
  x_err_num  := 0;

  -- Get the Parent and Child transaction information from MMT

  l_stmt_num := 10;

  --
  -- Start INVCONV umoogala
  -- Bug 5349860: Internal Order issues to exp can also happen between
  -- process and discrete orgs. If the receiving org is process org,
  -- then do not do any accounting as it will be taken care by OPM.
  --
  SELECT
    mmt.inventory_item_id,
    mmt.subinventory_code,
    mmt.transfer_transaction_id,
    mmt.organization_id,
    mp.process_enabled_flag,
    mmt.transfer_organization_id,
    mpx.process_enabled_flag
  INTO
    l_item_id,
    l_subinventory_code,
    l_logical_txn_id,
    l_parent_org_id,
    l_parent_org_process_flag,
    l_logical_org_id,
    l_logical_org_process_flag
  FROM
    mtl_material_transactions mmt, mtl_parameters mpx, mtl_parameters mp
  WHERE
      mmt.transaction_id  = p_parent_txn_id
  AND mpx.organization_id = mmt.transfer_organization_id
  AND mp.organization_id  = mmt.organization_id
  ;

  --
  -- Start INVCONV umoogala
  -- Bug 5349860: Internal Order issues to exp can also happen between
  -- process and discrete orgs. If the receiving org is process org,
  -- then do not do any accounting as it will be taken care by OPM.
  --
  IF l_logical_org_process_flag <> l_parent_org_process_flag
  THEN
    l_pd_xfer_ind := 'Y';
  ELSE
    l_pd_xfer_ind := 'N';
  END IF;

  IF l_logical_org_process_flag = 'Y'
  THEN
    IF g_debug = 'Y' THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Receiving Org is Process Org. So, no accounting ' ||
                                      ' for receiving transaction.');
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'CSTPAVCP.Cost_LogicalSOReceipt >>>');
    END IF;
    RETURN;
  ELSIF l_pd_xfer_ind = 'Y'
  THEN
    IF g_debug = 'Y' THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Process/Discrete xfer: Receiving Org is Discrete Org.');
    END IF;
  END IF;
  -- End bug 5349860

  -- If the transfer transaction is not populated, the transaction
  -- was created prior to 11.5.10 and not costed before the upgrade
  -- For these transactions, exit out the procedure. These will
  -- be costed in a manner similar to before the upgrade.

  IF l_logical_txn_id IS NULL THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Logical Receipt Transaction not seeded');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Pre-upgrade transaction');
    IF g_debug = 'Y' THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'CSTPAVCP.Cost_LogicalSOReceipt >>>');
    END IF;
    RETURN;
  END IF;

  l_stmt_num := 12;
  SELECT INVENTORY_ASSET_FLAG
  INTO   l_exp_item
  FROM   MTL_SYSTEM_ITEMS
  WHERE  INVENTORY_ITEM_ID = l_item_id
  AND    ORGANIZATION_ID   = l_parent_org_id;

  if ( ( l_subinventory_code is null ) or
       ( l_exp_item = 'N' ) ) then
    l_exp_flag := 'Y';
  else
    l_stmt_num := 14;
    SELECT decode(ASSET_INVENTORY, 1, 'N', 'Y')
    INTO   l_exp_flag
    FROM   MTL_SECONDARY_INVENTORIES
    WHERE  SECONDARY_INVENTORY_NAME = l_subinventory_code
    AND    ORGANIZATION_ID          = l_parent_org_id;
  end if;


  /* If this is an expense item or an asset item
     issued from an expense sub in the sending org,
     the logical transaction is not accounted. Set
     the costed_flag and return */
  --
  -- Bug 5349860: umoogala
  -- For process/discrete xfer, we've to book exp and payables with transfer price.
  --
  IF l_pd_xfer_ind = 'N' AND -- Bug 5349860: umoogala
     l_exp_flag = 'Y' THEN
    l_stmt_num := 16;
    UPDATE
      MTL_MATERIAL_TRANSACTIONS
    SET
      COSTED_FLAG            = NULL,
      LAST_UPDATE_DATE       = sysdate,
      LAST_UPDATED_BY        = p_user_id,
      LAST_UPDATE_LOGIN      = p_login_id,
      REQUEST_ID             = p_request_id,
      PROGRAM_APPLICATION_ID = p_prog_app_id,
      PROGRAM_ID             = p_prog_id
    WHERE
      TRANSACTION_ID = l_logical_txn_id;
    IF g_debug = 'Y' THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'CSTPAVCP.Cost_LogicalSOReceipt >>>');
    END IF;
    RETURN;

  END IF;

  l_stmt_num := 20;

  -- Get Logical transaction details
  SELECT
    PRIMARY_QUANTITY,
    TRANSACTION_DATE,
    TRANSACTION_SOURCE_ID,
    TRANSACTION_SOURCE_TYPE_ID,
    TRANSACTION_TYPE_ID,
    TRANSACTION_ACTION_ID,
    CURRENCY_CODE,
    CURRENCY_CONVERSION_RATE,
    CURRENCY_CONVERSION_DATE,
    CURRENCY_CONVERSION_TYPE,
    DISTRIBUTION_ACCOUNT_ID,
    COST_GROUP_ID,
    TRANSFER_PRICE  -- Bug 5349860: umoogala
  INTO
    l_primary_quantity,
    l_txn_date,
    l_txn_src_id,
    l_txn_src_typ_id,
    l_txn_typ_id,
    l_txn_act_id,
    l_alt_curr,
    l_curr_conv_rate,
    l_curr_conv_date,
    l_curr_conv_type,
    l_debit_account,
    l_logical_cost_group_id,
    l_transfer_price  -- Bug 5349860: umoogala
  FROM
    MTL_MATERIAL_TRANSACTIONS
  WHERE
    TRANSACTION_ID = l_logical_txn_id;

  IF ( g_debug = 'Y' ) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Logical Receipt Txn: '||to_char(l_logical_txn_id));
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Receipt Org: '||to_char(l_logical_org_id));
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Receipt Cost Group: '||to_char(l_logical_cost_group_id));
  END IF;

-- Get Expense subinventory information
  -- 1 for expense; 0 for not expense
  OPEN c_exp_sub(l_subinv_code
                ,l_logical_org_id
                );

  FETCH c_exp_sub
   INTO l_exp_sub;

  CLOSE c_exp_sub;

  IF ( g_debug = 'Y' ) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Expense Subinventory: '||to_char(l_exp_sub));
  END IF;


    -- ===================================================================
    -- Call costing extension hook get_account_id for debit account
    -- i_acct_line_type is 2 account
    -- 1 for debit; -1 for credit
    -- 1 for sending org; 2 for receiving org
    -- 1 for expnese; 0 for not expense
    -- return values
    --  > 0  User selected account number
    --   -1  Use the default account for distribution
    --    0  Error
    -- ===================================================================
    l_dr_acct_line_type := 2;
    /*ADDED VARIABLE i_cost_group_id FOR BUG8881927 */

    l_db_account := CSTPACHK.get_account_id
                    (i_org_id               => l_logical_org_id
                    ,i_txn_id               => l_logical_txn_id
                    ,i_debit_credit         => 1
                    ,i_acct_line_type       => l_dr_acct_line_type
                    ,i_cost_element_id      => 1
                    ,i_resource_id          => NULL
                    ,i_subinv               => l_subinv_code
                    ,i_exp                  => l_exp_sub
                    ,i_snd_rcv_org          => 2
                    ,o_err_num              => l_err_num
                    ,o_err_code             => l_err_code
                    ,o_err_msg              => l_err_msg
                    ,i_cost_group_id        => NULL
                    );

    IF l_db_account = 0 THEN
      RAISE COST_HOOK_ACCOUNT_ERROR;
    END IF;

    IF l_db_account > 0  THEN
    -- costing extension hook is enabled
      l_debit_account := l_db_account;
    END IF;

    IF ( g_debug = 'Y' ) THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Debit Account: '||to_char(l_debit_account));
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Account Line Type: '||to_char(l_dr_acct_line_type));
    END IF;


  l_stmt_num := 30;

  SELECT
    PRIMARY_COST_METHOD
  INTO
    l_cost_method
  FROM
    MTL_PARAMETERS
  WHERE
    organization_id = l_logical_org_id;


  -- For non-Standard Orgs, Get layer information
  -- For Standard Costing Orgs, we use '-1' as the layer id in MCACD

  IF l_cost_method <> 1 THEN
    l_stmt_num := 40;

    l_layer_id := CSTPACLM.layer_id ( l_logical_org_id,
                                      l_item_id,
                                      l_logical_cost_group_id,
                                      l_err_num,
                                      l_err_code,
                                      l_err_msg );
    if (l_err_num <> 0) then
      raise fnd_api.g_exc_error;
    end if;

    -- Create a layer, if necessary
    if (l_layer_id = 0) then
      l_stmt_num := 50;
      l_layer_id := CSTPACLM.create_layer ( l_logical_org_id,
                                            l_item_id,
                                            l_logical_cost_group_id,
                                            p_user_id,
                                            p_request_id,
                                            p_prog_id,
                                            p_prog_app_id,
                                            l_logical_txn_id,
                                            l_err_num,
                                            l_err_code,
                                            l_err_msg );
      if (l_err_num <> 0) then
        raise fnd_api.g_exc_error;
      end if;
    end if;
  ELSE
    l_layer_id := -1;
  END IF;

  IF g_debug = 'Y' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Layer_ID: '||to_char(l_layer_id));
  END IF;

  -- Get Cost from parent transaction's MCACD.
  -- This is in parent org's primary currency

  l_stmt_num := 60;
  --
  -- Bug 5349860: umoogala
  -- For Process/Discrete xfer use transfer price, which is already in base currency.
  --
  IF l_pd_xfer_ind = 'N'
  THEN
    SELECT SUM(ACTUAL_COST)
    INTO   l_actual_cost
    FROM   MTL_CST_ACTUAL_COST_DETAILS
    WHERE  transaction_id = p_parent_txn_id;
  ELSE
    l_actual_cost := l_transfer_price;
  END IF;

  -- Get Primary Currency of Logixal Orgn
  l_stmt_num := 70;

  SELECT CURRENCY_CODE,
         SET_OF_BOOKS_ID,
	 OPERATING_UNIT
  INTO   l_pri_curr,
         l_set_of_books_id,
	 l_ou_id
  FROM   CST_ORGANIZATION_DEFINITIONS
  WHERE  ORGANIZATION_ID = l_logical_org_id;

  --------------------------------------------------------------------
  -- Internal Order Issue to Expense could be to the same organization
  -- In this case, the same debit and credit accounts are used for
  -- the receipt. I.E., If the organizations are same:
  -- Issue: Cr Inventory
  --          Dr Charge
  -- Receipt (This Txn): Cr Charge
  --                       Dr Charge
  -- Looks funny but it is a valid business practice to have such a
  -- scenario. The main part is in the cost collection of the receipt
  -- if it is project enabled
  --------------------------------------------------------------------

  IF l_parent_org_id <> l_logical_org_id THEN
    -- Do the currency conversions and obtain the converted amount
    -- Obtain the credit account from Interorg parameters

    --
    -- Bug 5349860: umoogala
    -- For process/discrete xfer, don't need to do any currency conversion
    -- as transfer price is already converted to receiving orgs base currency.
    --
    IF l_pd_xfer_ind = 'N'
    THEN

      -- Get Currency of Sending Organization
      l_stmt_num := 80;

      SELECT CURRENCY_CODE
      INTO   l_sending_curr
      FROM   CST_ORGANIZATION_DEFINITIONS
      WHERE  ORGANIZATION_ID = l_parent_org_id;


      -- Get the Conversion Type from the profile
      FND_PROFILE.get('CURRENCY_CONVERSION_TYPE', l_conversion_type);

      IF g_debug = 'Y' THEN
        fnd_file.put_line(fnd_file.log, 'Currency Conversion Type: '|| l_conversion_type);
      END IF;

      l_conversion_rate := GL_Currency_Api.Get_Rate(l_set_of_books_id,
                                                   l_sending_curr,
                                                   l_txn_date,
                                                   l_conversion_type);

      IF l_conversion_rate IS NULL THEN
        FND_FILE.put_line(FND_FILE.log, 'Currency Conversion Rate not defined: ');
        FND_FILE.put_line(FND_FILE.log, 'Currency From: '||l_sending_curr);
        FND_FILE.put_line(FND_FILE.log, 'Date: '||to_char(l_txn_date, 'DD-MON-YYYY'));
        FND_FILE.put_line(FND_FILE.log, 'Conversion Type: '||l_conversion_type);
        FND_FILE.put_line(FND_FILE.log, 'Please define the rate and resubmit transaction');
        RAISE NO_CURR_CONV_RATE_FOUND;
      END IF;

      l_actual_cost := l_actual_cost * l_conversion_rate;
    END IF;

   l_stmt_num := 85;
    -- ===================================================================
    -- Call costing extension hook get_account_id for credit account
    -- i_acct_line_type is 9 interorg payable account
    -- 1 for debit; -1 for credit
    -- 1 for expense; 0 for not expense
    -- 1 for sending org; 2 for receiving org
    -- ===================================================================
    l_cr_acct_line_type := 9;
    /*ADDED VARIABLE i_cost_group_id FOR BUG8881927 */
    l_credit_account := CSTPACHK.get_account_id
                        (i_org_id               => l_logical_org_id
                        ,i_txn_id               => l_logical_txn_id
                        ,i_debit_credit         => -1
                        ,i_acct_line_type       => l_cr_acct_line_type
                        ,i_cost_element_id      => 1
                        ,i_resource_id          => NULL
                        ,i_subinv               => l_subinv_code
                        ,i_exp                  => l_exp_sub
                        ,i_snd_rcv_org          => 2
                        ,o_err_num              => l_err_num
                        ,o_err_code             => l_err_code
                        ,o_err_msg              => l_err_msg
                        ,i_cost_group_id         => NULL);

    IF l_credit_account = 0 THEN
    -- costing hook extension error
      RAISE COST_HOOK_ACCOUNT_ERROR;
    END IF;

    IF g_debug = 'Y' THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Credit Account: '||to_char(l_credit_account));
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Account Line Type: '||to_char(l_cr_acct_line_type));
    END IF;

      IF l_credit_account = -1 THEN
      -- default account behavior

        -- Get the Interorg payables account for this Interorg relationship
        l_stmt_num := 90;

        SELECT
          INTERORG_PAYABLES_ACCOUNT
        INTO
          l_credit_account
        FROM
          MTL_INTERORG_PARAMETERS
        WHERE
          FROM_ORGANIZATION_ID = l_parent_org_id
        AND TO_ORGANIZATION_ID = l_logical_org_id;


      END IF; -- costing hook disabled

    ELSE -- Same Organizations
      l_credit_account := l_debit_account;
      l_cr_acct_line_type := 2; -- Account

    END IF;

  IF g_debug = 'Y' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Actual_Cost or transfer price for process/discrete xfer: '||to_char(l_actual_cost));
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Credit_account: '||to_char(l_credit_account));
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Debit_account: '||to_char(l_debit_account));
  END IF;

  -- Insert Logical Transaction details into MCACD

  l_stmt_num := 100;

  BEGIN
    INSERT INTO MTL_CST_ACTUAL_COST_DETAILS (
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
      insertion_flag,
      variance_amount,
      user_entered )
    VALUES (
      l_logical_txn_id,
      l_logical_org_id,
      l_layer_id,
      1, -- All Costs into MTL
      1, -- Level: TL
      decode(l_pd_xfer_ind, 'Y', 17, 1), -- Bug 5349860: umoogala
      sysdate,
      p_user_id,
      sysdate,
      p_user_id,
      p_login_id,
      p_request_id,
      p_prog_app_id,
      p_prog_id,
      sysdate,
      l_item_id,
      l_actual_cost,
      'N',
      0,
      'N');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE INSERT_MCACD_ERROR;
  END;
  -- Create Accounting Entries for the Logical Transaction
  -- Insert Debit Entry
  l_stmt_num := 110;

  IF g_debug = 'Y' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Dr Exp Account with ' || l_actual_cost * l_primary_quantity || ' ' || l_pri_curr);
  END IF;

  CSTPACDP.INSERT_ACCOUNT(
             l_logical_org_id,
             l_logical_txn_id,
             l_item_id,
             l_actual_cost * l_primary_quantity,
             l_primary_quantity,
             l_debit_account,
             l_set_of_books_id,
             l_dr_acct_line_type,  -- Accounting_Line_Type
             1,                    -- Cost_Element
             NULL,                 -- Resource_Id
             l_txn_date,
             l_txn_src_id,
             l_txn_src_typ_id,
             l_pri_curr,
             l_alt_curr,
             l_curr_conv_date,
             l_curr_conv_rate,
             l_curr_conv_type,
             1,
             p_user_id,
             p_login_id,
             p_request_id,
             p_prog_app_id,
             p_prog_id,
             l_err_num,
             l_err_code,
             l_err_msg );

  IF l_err_num <> 0 THEN
    RAISE INSERT_ACCT_ERROR;
  END IF;

  -- Insert Credit Entry
  l_stmt_num := 120;

  IF g_debug = 'Y' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Cr Payables Account with ' || -1 * l_actual_cost * l_primary_quantity || ' ' || l_pri_curr);
  END IF;

  CSTPACDP.INSERT_ACCOUNT(
             l_logical_org_id,
             l_logical_txn_id,
             l_item_id,
             -1 * l_actual_cost * l_primary_quantity,
             -1 * l_primary_quantity,
             l_credit_account,
             l_set_of_books_id,
             l_cr_acct_line_type,  -- Accounting_Line_Type
             1,                    -- Cost_Element
             NULL,                 -- Resource_Id
             l_txn_date,
             l_txn_src_id,
             l_txn_src_typ_id,
             l_pri_curr,
             l_alt_curr,
             l_curr_conv_date,
             l_curr_conv_rate,
             l_curr_conv_type,
             1,               -- Actual_Flag
             p_user_id,
             p_login_id,
             p_request_id,
             p_prog_app_id,
             p_prog_id,
             l_err_num,
             l_err_code,
             l_err_msg );

  IF l_err_num <> 0 THEN
    RAISE INSERT_ACCT_ERROR;
  END IF;


  l_stmt_num := 130;

  /* Compute Encumbrance Amount and create the reversal entry,
     if applicable */
  SELECT nvl(req_encumbrance_flag,'N') /*nvl(purch_encumbrance_flag, 'N')Bug 6469694*/
  INTO   l_encumbrance_flag
  FROM   FINANCIALS_SYSTEM_PARAMS_ALL
  WHERE  set_of_books_id = l_set_of_books_id
  AND    ( ( l_ou_id is not NULL AND org_id = l_ou_id ) OR
           ( l_ou_id is null ) );

  IF l_encumbrance_flag = 'Y' THEN

    l_stmt_num := 140;
    CompEncumbrance_IntOrdersExp (
      p_api_version         => 1.0,
      p_transaction_id      => l_logical_txn_id,
      x_encumbrance_amount  => l_enc_amount,
      x_encumbrance_account => l_enc_account,
      x_return_status       => l_return_status,
      x_return_message      => l_return_message );
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF ( l_enc_amount <> 0 AND l_enc_account is not null ) THEN
      l_stmt_num := 150;
      CSTPACDP.ENCUMBRANCE_ACCOUNT(
             l_logical_org_id,
             l_logical_txn_id,
             l_item_id,
             -1 * l_enc_amount,
             l_primary_quantity,
             l_enc_account,
             l_set_of_books_id,
             l_txn_date,
             l_txn_src_id,
             l_txn_src_typ_id,
             l_pri_curr,
             l_alt_curr,
             l_curr_conv_date,
             l_curr_conv_rate,
             l_curr_conv_type,
             p_user_id,
             p_login_id,
             p_request_id,
             p_prog_app_id,
             p_prog_id,
             l_err_num,
             l_err_code,
             l_err_msg );


      IF l_err_num <> 0 THEN
        RAISE INSERT_ACCT_ERROR;
      END IF;
    END IF; /* l_enc_amount <> 0 ... */
  END IF;   /* l_encumbrance_flag = 'Y' */

  -- Update MMT
  l_stmt_num := 160;
  UPDATE
    MTL_MATERIAL_TRANSACTIONS
  SET
    COSTED_FLAG            = NULL,
    transaction_group_id   = NULL,
    ENCUMBRANCE_AMOUNT     = l_enc_amount,
    ENCUMBRANCE_ACCOUNT    = l_enc_account,
    LAST_UPDATE_DATE       = sysdate,
    LAST_UPDATED_BY        = p_user_id,
    LAST_UPDATE_LOGIN      = p_login_id,
    REQUEST_ID             = p_request_id,
    PROGRAM_APPLICATION_ID = p_prog_app_id,
    PROGRAM_ID             = p_prog_id
  WHERE
    TRANSACTION_ID = l_logical_txn_id;


  IF g_debug = 'Y' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Creating XLA Event');
  END IF;

  --
  -- Bug 5349860: Process/Discrete Xfer
  -- Creating event for rct txn of Internal order issue to expense
  --

  /* Create Events in SLA */
  l_trx_info.TRANSACTION_ID       := l_logical_txn_id;
  l_trx_info.TXN_ACTION_ID        := 17;  -- Logical Expense Requisition Receipt
  l_trx_info.TXN_ORGANIZATION_ID  := l_logical_org_id;
  l_trx_info.TXN_SRC_TYPE_ID      := 7;   -- Internal requisition
  l_trx_info.TXFR_ORGANIZATION_ID := l_parent_org_id;
  l_trx_info.FOB_POINT            := NULL;
  l_trx_info.TRANSACTION_DATE     := l_txn_date;
  l_trx_info.PRIMARY_QUANTITY     := l_primary_quantity;

--{BUG#6611359 encumbrance flag
  l_trx_info.ENCUMBRANCE_FLAG  := l_encumbrance_flag;
--}

  IF l_pd_xfer_ind = 'Y'
  THEN
    l_trx_info.TP := 'Y';
  ELSE
    l_trx_info.TP := 'N';
  END IF;

  l_trx_info.attribute := NULL;

  l_stmt_num := 170;

  CST_XLA_PVT.Create_INVXLAEvent (
        p_api_version       => 1.0,
        p_init_msg_list     => FND_API.G_FALSE,
        p_commit            => FND_API.G_FALSE,
        p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
        x_return_status     => l_return_status,
        x_msg_count         => l_msg_count,
        x_msg_data          => l_msg_data,
        p_trx_info          => l_trx_info
      );

  IF l_return_status <> 'S' THEN
    x_err_num  := -1;
    x_err_code := 'Error raising SLA Event for transaction: '||to_char(l_trx_info.TRANSACTION_ID);
    x_err_msg  := 'CSTPAVCP.Cost_LogicalSOReceipt:('||l_stmt_num||'): '||x_err_code || '. Error Msg: ' || l_msg_data;

    IF g_debug = 'Y' THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'CSTPAVCP.Cost_LogicalSOReceipt >>>');
    END IF;

    RAISE FND_API.g_exc_unexpected_error;
  END IF;
  /* End bug 5349860 */

  IF g_debug = 'Y' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'CSTPAVCP.Cost_LogicalSOReceipt >>>');
  END IF;


EXCEPTION
  WHEN NO_CURR_CONV_RATE_FOUND THEN
    x_err_num := -1;
    x_err_code := 'Currency Conversion Rate not defined';
    x_err_msg := x_err_code;
  WHEN INSERT_MCACD_ERROR THEN
    x_err_num := -1;
    x_err_code := 'CSTPAVCP.Cost_LogicalSOReceipt( '||to_char(l_stmt_num)||' ): '||'Error Inserting into MCACD: '||SQLERRM;
    x_err_msg := x_err_code;
    FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_code);
  WHEN INSERT_ACCT_ERROR THEN
    x_err_num := -1;
    x_err_code := 'CSTPAVCP.Cost_LogicalSOReceipt( '||to_char(l_stmt_num)||' ): '||'Error in Insert_Account: ';
    x_err_msg := x_err_code;
    FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_code);

  WHEN COST_HOOK_ACCOUNT_ERROR THEN
    x_err_num  := l_err_num;
    x_err_code := 'CSTPAVCP.Cost_LogicalSOReceipt' || l_err_code || 'Error in cost hook get_account_id' ;
    x_err_msg  := l_err_msg;
    FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_code);
    FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);

  WHEN FND_API.g_exc_unexpected_error THEN
    rollback;
    UPDATE mtl_material_transactions
    SET    costed_flag = 'E',
           error_code = substrb(x_err_code,1,240),
           error_explanation = substrb(x_err_msg,1,240),
           request_id = p_request_id,
           program_application_id = p_prog_app_id,
           program_id = p_prog_id,
           program_update_date = sysdate
    WHERE  transaction_id = l_trx_info.TRANSACTION_ID;
    commit;

  WHEN OTHERS THEN
    x_err_num := -1;
    x_err_code := 'CSTPAVCP.Cost_LogicalSOReceipt( '||to_char(l_stmt_num)||' ): ';
    x_err_msg := x_err_code;
    FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_code);

END Cost_LogicalSOReceipt;

/* ===========================================================
   OPM INVCONV umoogala/sschinch
   This procedure computes cost for a logical receipt in
   receiving organizations for a process discrete transfer
   ===========================================================*/

PROCEDURE Cost_Logical_itr_receipt(
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
  l_from_layer_id	NUMBER;
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

BEGIN
  -- initialize local variables
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';
  l_update_std := 0;
  l_snd_qty := o_txn_qty;
  l_std_exp := 0;

  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, 'Cost_Logical_itr_receipt <<<');
    fnd_file.put_line(fnd_file.log, '- Process/Discrete Transfer -');
  END IF;

  l_earn_moh := 1;
  l_return_status := fnd_api.g_ret_sts_success;
  l_msg_count := 0;

  l_txfr_std_exp := 0;
  l_to_std_exp := 0;
  l_elemental_visible := 'N';


  -- l_from_org := i_txfr_org_id;
  -- l_to_org := i_txn_org_id;
  -- l_from_cost_grp := i_txfr_cost_grp;
  -- l_to_cost_grp := i_cost_grp_id;

  -- Figure the from and to org for this transaction.
  l_stmt_num := 5;
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
  elsif (i_txn_action_id = 1) then  -- Bug 5349860: internal order issue to expense destination
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


  --
  -- Bug 5021305/5677953
  -- The following are considered interorg receipt transactions.
  -- These are transactions where ownership changes and the current org
  -- is the receiving org.
  -- This flag is being used in compute_actual_cost before calling
  -- apply_material_ovhd.
  if ((i_txn_action_id = 3 and l_snd_qty > 0) OR
      (i_txn_action_id = 15) OR
      (i_txn_action_id = 12 and i_fob_point = 2))
  then
    o_interorg_rec := 1;
  else
    o_interorg_rec := 0;
  end if;


  -- item cost history stuff
  --
  -- For p-d xfers, in Avg Cost processor Org will always be Average Costin Org.
  -- Shipment to Std Orgs are being processed by Std Cost processor.
  --
  -- if (l_std_to_org = 0) then
  -- receiving org is average
  l_which_org := l_to_org;
  l_which_cst_grp := i_cost_grp_id;
  -- end if;

  if i_txn_action_id <> 1 and  -- Bug 5349860: exculding IO Issue to Exp Destination
     i_org_id = l_which_org then
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
  -- End of item cost history

   --
   -- Got rid of big chunck of code for standard costing org.
   -- For p-d xfers, in Avg Cost processor Org will always be Average Costin Org.
   -- Shipment to Std Orgs are being processed by Std Cost processor.
   --

   --
   -- Bug 5349860: transportation_cost should be zero for
   -- internal order issues to expense destination.
   --
   l_stmt_num := 30;
   IF i_txn_action_id <> 1
   THEN
   SELECT nvl(transportation_cost,0)
     INTO l_trans_cost
     FROM mtl_material_transactions
    WHERE transaction_id = i_txn_id;
   ELSE
     l_trans_cost := 0;
   END IF;

   --
   -- No need for any UOM or currency conversion as it is already done
   -- while creating MMT row for this logical transactions.
   -- For details refer to: INV_LOGICAL_TRANSACTIONS_PUB.create_opm_disc_logical_trx
   --
   IF g_debug = 'Y' THEN
     fnd_file.put_line(fnd_file.log, 'TxnOrg: ' || i_txn_org_id || ' Item: ' || i_item_id);
     fnd_file.put_line(fnd_file.log, 'fromOrg: ' || l_from_org || ' toOrg: ' || l_to_org);
     fnd_file.put_line(fnd_file.log, 'fromCG: ' || l_from_cost_grp || ' toCG: ' || l_to_cost_grp);
     fnd_file.put_line(fnd_file.log, 'Transaction Action: ' || i_txn_action_id);
     fnd_file.put_line(fnd_file.log, 'Transfer price options: ' || i_tprice_option ||
                ' Transfer Price: ' || i_txf_price ||
                ' Trp Cost: ' || l_trans_cost || ' Qty: ' || l_snd_qty);
   END IF;

   -- Bug 5450648: Should not add freight here since this is rcv_txn_cost is used to
   -- reaverage the cost.
   --
   -- Bug 5400992: Incorrect fix was done for the above bug 5450648.
   -- Following is the correct fix. Freight should be used in average costing only in case
   -- of FOB Shipment.
   --
   if ((i_txn_action_id = 12 and i_fob_point = 2) or (i_txn_action_id = 3 and o_txn_qty > 0)) then
     l_rcv_txn_cost := ((i_txf_price * abs(l_snd_qty)) ) / abs(l_snd_qty);
   else
     l_rcv_txn_cost := ((i_txf_price * abs(l_snd_qty)) + l_trans_cost) / abs(l_snd_qty);
   end if;

  if ((i_txn_action_id in (21,22)) OR
      (i_txn_action_id = 3 and l_snd_qty < 0))
  then

     l_stmt_num := 40;
     select item_cost, layer_id
       into l_snd_txn_cost, l_from_layer_id
       from cst_quantity_layers
      where organization_id = l_from_org
        and inventory_item_id = i_item_id
        and cost_group_id = l_from_cost_grp;

      l_new_txn_cost := (l_snd_txn_cost * abs(l_snd_qty)  + l_trans_cost) / abs(l_snd_qty);

      IF g_debug = 'Y' THEN
        fnd_file.put_line(fnd_file.log, 'Updating trx: ' || i_txn_id || ' with trxCost: ' || l_new_txn_cost);
      END IF;

      l_stmt_num := 50;
      Update mtl_material_transactions
      Set transaction_cost = l_new_txn_cost
      where transaction_id = i_txn_id;

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
         (i_txn_action_id = 3 and l_snd_qty > 0) OR
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

  -- Bug 5349860: Internal Order issues to exp can also happen between
  ELSIF (i_txn_action_id = 1)
  THEN

    NULL;
    /*
     * Bug 5631478: unique constraint violation because of this insert.
     * Same insert is being done in compute_actual_cost procedure
     *
    IF g_debug = 'Y' THEN
      fnd_file.put_line(fnd_file.log, 'inserting to MCACD for IO Issue to exp txn');
    END IF;

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
    i_layer_id,
    clcd.cost_element_id,
    clcd.level_type,
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
    clcd.item_cost,
    clcd.item_cost,
    clcd.item_cost,
    'N',
    0,
    'N'
    from cst_layer_cost_details clcd
    where layer_id = i_layer_id;
    */

  END IF;

  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, 'Cost Logical Intransit Receipt >>>');
  END IF;

  EXCEPTION
    when others then
      rollback;
      o_err_num := SQLCODE;
      o_err_msg := 'CSTPAVCP.Logical_itr_receipt(' || to_char(l_stmt_num) ||
                   '): ' || substr(SQLERRM, 1,200);

END Cost_Logical_itr_receipt;

PROCEDURE CompEncumbrance_IntOrdersExp (
            p_api_version     IN NUMBER,
	    p_transaction_id  IN MTL_MATERIAL_TRANSACTIONS.TRANSACTION_ID%TYPE,
            p_req_line_id     IN PO_REQUISITION_LINES_ALL.REQUISITION_LINE_ID%TYPE,
            p_item_id         IN MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE,
            p_organization_id IN MTL_PARAMETERS.ORGANIZATION_ID%TYPE,
            p_primary_qty     IN MTL_MATERIAL_TRANSACTIONS.PRIMARY_QUANTITY%TYPE,
            p_total_primary_qty   IN NUMBER,
            x_encumbrance_amount  OUT NOCOPY NUMBER,
            x_encumbrance_account OUT NOCOPY NUMBER,
            x_return_status       OUT NOCOPY VARCHAR,
            x_return_message      OUT NOCOPY VARCHAR2
 ) IS

l_doc_line_qty           PO_REQUISITION_LINES_ALL.QUANTITY%TYPE;
l_doc_unit_price         PO_REQUISITION_LINES_ALL.UNIT_PRICE%TYPE;
l_unit_price             PO_REQUISITION_LINES_ALL.UNIT_PRICE%TYPE;
l_conversion_rate        NUMBER;
l_primary_uom_code       MTL_UNITS_OF_MEASURE.UOM_CODE%TYPE;
l_doc_uom_code           MTL_UNITS_OF_MEASURE.UOM_CODE%TYPE;
l_uom_rate               NUMBER;
l_doc_primary_qty        NUMBER;
l_doc_rcv_qty            NUMBER;

l_stmt_num               NUMBER;
l_api_name               VARCHAR2(100) := 'CompEncumbrance_IntOrdersExp';
l_api_version            NUMBER := 1.0;
/* Bug 6405593*/
l_hook_used                  NUMBER;
l_non_recoverable_tax        NUMBER;
l_loc_non_recoverable_tax    NUMBER;
l_loc_recoverable_tax        NUMBER;
l_Err_Num                    NUMBER;
l_Err_Code                   NUMBER;
process_error		     EXCEPTION;
/* Bug 6405593*/

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  if g_debug = 'Y' then
    fnd_file.put_line(fnd_file.log, 'CompEncumbrance_IntOrdersExp << ');
  end if;

  l_stmt_num := 5;

  IF NOT FND_API.Compatible_API_Call (
                                       l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;




  /* 1. Get the budget_account, quantity ordered, and UOM from the Req */
  l_stmt_num := 10;
  SELECT um.uom_code,
         rl.quantity,
         rl.unit_price,
         rd.budget_account_id,
	 nvl(rd.nonrecoverable_tax,0) /* Bug 6405593 */
  INTO   l_doc_uom_code,
         l_doc_line_qty,
         l_unit_price,
         x_encumbrance_account,
         l_non_recoverable_tax  /* Bug 6405593 */
  FROM   po_req_distributions_all rd,
         po_requisition_lines_all rl,
         mtl_units_of_measure um
  WHERE  rd.requisition_line_id   = p_req_line_id
  and    rd.requisition_line_id   = rl.requisition_line_id
  and    rl.UNIT_MEAS_LOOKUP_CODE = um.unit_of_measure;

  if g_debug = 'Y' then
    fnd_file.put_line(fnd_file.log, 'Unit Price: '||l_unit_price||'Encumbrance Account: '||x_encumbrance_account);
  end if;

  /* Get UOM for this item/org from MSI */
  l_stmt_num := 30;
  SELECT primary_uom_code
  INTO   l_primary_uom_code
  FROM   mtl_system_items
  WHERE  organization_id   = p_organization_id
  AND    inventory_item_id = p_item_id;

  if g_debug = 'Y' then
    fnd_file.put_line(fnd_file.log, 'Primary UOM: '||l_primary_uom_code);
  end if;
  /* Convert the total_primary_quantity into source_doc_quantity */
  l_stmt_num := 40;
  INV_Convert.INV_UM_Conversion(
                          from_unit       => l_primary_uom_code,
                          to_unit         => l_doc_uom_code,
                          item_id         => p_item_id,
                          uom_rate        => l_uom_rate );
  IF ( l_uom_rate = -99999) THEN
    x_return_message := 'Inv_Convert.inv_um_conversion() failed to get the UOM rate';
    x_return_status  := FND_API.G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_doc_rcv_qty     := p_total_primary_qty * l_uom_rate;
  l_doc_primary_qty := p_primary_qty * l_uom_rate;
  if g_debug = 'Y' then
    fnd_file.put_line(fnd_file.log, 'Document Received Quantity: '||l_doc_rcv_qty||' Document Primary Quantity: '||l_doc_primary_qty);
    fnd_file.put_line(fnd_file.log, 'Calling CST_Common_hooks.Get_NRtax_amount for MMT-REQ Req_line_id '||p_req_line_id);
  end if;

      /* Bug 6405593 :Added hook call to override the recoverable and Non-Recoverable
                      taxes for ENCUMBRANCE REVERSAL*/
	l_stmt_num := 45;
         l_hook_used := CST_Common_hooks.Get_NRtax_amount(
	                I_ACCT_TXN_ID        =>p_transaction_id,
	                I_SOURCE_DOC_TYPE    =>'REQ',
	                I_SOURCE_DOC_ID      =>p_req_line_id,
	                I_ACCT_SOURCE        =>'MMT',
	                I_USER_ID            =>fnd_global.user_id,
	                I_LOGIN_ID           =>fnd_global.login_id,
	                I_REQ_ID             =>fnd_global.conc_request_id,
	                I_PRG_APPL_ID        =>fnd_global.prog_appl_id,
	                I_PRG_ID             =>fnd_global.conc_program_id,
	                O_DOC_NR_TAX         =>l_loc_non_recoverable_tax,
	                O_DOC_REC_TAX        =>l_loc_recoverable_tax,
	                O_Err_Num            =>l_Err_Num,
	                O_Err_Code           =>l_Err_Code,
	                O_Err_Msg            =>x_return_message
				   );
        IF l_hook_used <>0 THEN

	 IF (l_err_num <> 0) THEN
	      -- Error occured
              IF G_DEBUG = 'Y' THEN
                   fnd_file.put_line(fnd_file.log, 'Error getting Enc Tax in CST_Common_hooks.Get_NRtax_amount at statement :'||l_stmt_num);
                   fnd_file.put_line(fnd_file.log, 'Error Code :  '||l_err_code||' Error Message : '||x_return_message);
	      END IF;
              RAISE process_error;
	    END IF;


	IF G_DEBUG = 'Y' THEN
           fnd_file.put_line(fnd_file.log,'Hook Used  CST_Common_hooks.Get_NRtax_amount :'|| l_hook_used ||
	                     ' l_loc_recoverable_tax : '||l_loc_recoverable_tax||
                             ' l_loc_non_recoverable_tax : '||l_loc_non_recoverable_tax);
        END IF;

        l_non_recoverable_tax:=nvl(l_non_recoverable_tax,0)+nvl(l_loc_non_recoverable_tax,0);

       END IF;
      /* Bug 6405593 :Added hook call to override the recoverable and Non-Recoverable
                      taxes for ENCUMBRANCE_REVERSAL event */

  /* The Requisition is always in the funtional currency */
  /* No need of currency conversion */
  /* Commented for Bug 6405593 */
/*  IF ( l_doc_rcv_qty  >= l_doc_line_qty ) THEN
    x_encumbrance_amount := 0;
  ELSIF ( l_doc_rcv_qty + l_doc_primary_qty ) >= l_doc_line_qty THEN
    x_encumbrance_amount :=  l_unit_price *
                             ( l_doc_line_qty - l_doc_rcv_qty );
  ELSE
    x_encumbrance_amount :=  l_unit_price * l_doc_primary_qty;
  END IF; */

  /* Commented for Bug 6405593 */

  /* Added for Bug 6405593 */
  IF ( l_doc_rcv_qty  >= l_doc_line_qty ) THEN
    x_encumbrance_amount := 0;
  ELSIF ( l_doc_rcv_qty + l_doc_primary_qty ) >= l_doc_line_qty THEN
    x_encumbrance_amount :=  l_unit_price * ( l_doc_line_qty - l_doc_rcv_qty )
                            +nvl(l_non_recoverable_tax,0)*( l_doc_line_qty - l_doc_rcv_qty )/l_doc_line_qty;
  ELSE
    x_encumbrance_amount :=  l_unit_price * l_doc_primary_qty
                            +nvl(l_non_recoverable_tax,0)*(l_doc_primary_qty/l_doc_line_qty);
  END IF;
  /* Added for Bug 6405593 */

  if g_debug = 'Y' then
    fnd_file.put_line(fnd_file.log, 'Encumbrance Amount: '||x_encumbrance_amount);
    fnd_file.put_line(fnd_file.log, 'CompEncumbrance_IntOrdersExp >>');
  end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := fnd_api.g_ret_sts_error;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
  WHEN process_error THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    x_return_message := 'Error in CSTPAVCP.CompEncumbrance_IntOrdersExp('||l_stmt_num||')';
  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    x_return_message := 'Error in CST_UTIL_PUB.CompEncumbrance_IntOrdersExp('||l_stmt_num||')';

END CompEncumbrance_IntOrdersExp;

PROCEDURE CompEncumbrance_IntOrdersExp (
            p_api_version     IN NUMBER,
            p_transaction_id  IN MTL_MATERIAL_TRANSACTIONS.TRANSACTION_ID%TYPE,
            x_encumbrance_amount  OUT NOCOPY NUMBER,
            x_encumbrance_account OUT NOCOPY NUMBER,
            x_return_status       OUT NOCOPY VARCHAR,
            x_return_message      OUT NOCOPY VARCHAR2
 ) IS

l_total_primary_qty      NUMBER;
l_primary_qty            MTL_MATERIAL_TRANSACTIONS.PRIMARY_QUANTITY%TYPE;
l_organization_id        MTL_MATERIAL_TRANSACTIONS.ORGANIZATION_ID%TYPE;
l_trx_source_line_id     MTL_MATERIAL_TRANSACTIONS.TRX_SOURCE_LINE_ID%TYPE;
l_req_line_id            PO_REQUISITION_LINES_ALL.REQUISITION_LINE_ID%TYPE;
l_item_id                MTL_MATERIAL_TRANSACTIONS.INVENTORY_ITEM_ID%TYPE;
l_txn_action_id          MTL_MATERIAL_TRANSACTIONS.TRANSACTION_ACTION_ID%TYPE;
l_txn_src_type_id
MTL_MATERIAL_TRANSACTIONS.TRANSACTION_SOURCE_TYPE_ID%TYPE;
l_rcv_txn_id             MTL_MATERIAL_TRANSACTIONS.RCV_TRANSACTION_ID%TYPE;
l_txn_type_id            MTL_MATERIAL_TRANSACTIONS.TRANSACTION_TYPE_ID%TYPE;


l_stmt_num               NUMBER;
l_api_name               VARCHAR2(100) := 'CompEncumbrance_IntOrdersExp';
l_api_version            NUMBER := 1.0;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  if g_debug = 'Y' then
    fnd_file.put_line(fnd_file.log, 'CompEncumbrance_IntOrdersExp (T) <<');
  end if;
  l_stmt_num := 5;

  IF NOT FND_API.Compatible_API_Call (
                                       l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_stmt_num := 10;

  SELECT
    mmt.trx_source_line_id,
    mmt.primary_quantity,
    mmt.organization_id,
    mmt.inventory_item_id,
    mmt.transaction_action_id,
    mmt.transaction_source_type_id,
    mmt.transaction_type_id,
    mmt.rcv_transaction_id
  INTO
    l_trx_source_line_id,
    l_primary_qty,
    l_organization_id,
    l_item_id,
    l_txn_action_id,
    l_txn_src_type_id,
    l_txn_type_id,
    l_rcv_txn_id
  FROM
    MTL_MATERIAL_TRANSACTIONS mmt
  WHERE
    transaction_id = p_transaction_id;

  /* Get total received (and costed) quantity */

  l_stmt_num := 20;
  SELECT sum(primary_quantity)
  INTO   l_total_primary_qty
  from   mtl_material_transactions
  where  transaction_action_id      = l_txn_action_id
  and    transaction_source_type_id = l_txn_src_type_id
  and    transaction_type_id        = l_txn_type_id
  and    trx_source_line_id         = l_trx_source_line_id
  and    costed_flag IS NULL ;

  if g_debug = 'Y' then
    fnd_file.put_line(fnd_file.log, 'Total Received Primary Qty: '||l_total_primary_qty);
  end if;

  /* Get Requisition Line ID */
  /* For Internal Order Requisition Receipt, this is the MMT.TRX_SOURCE_LINE_ID
     Using above information, find the requisition_line_id */
  l_stmt_num := 25;

  IF ( l_txn_action_id       = 17
       AND l_txn_src_type_id = 7
       AND l_txn_type_id     = 27 ) THEN
    l_req_line_id := l_trx_source_line_id;
  ELSE

    /*
     * Internal Order Intransit Shipment (62, 21, 8),
     * Int Req Direct Org Xfr (95, 3, 7),
     * Int Order Direct Ship (54, 3, 8): TRX_SOURCE_LINE_ID = OE_ORDER_LINE_ID.LINE_ID
     * For Internal Req Intr Rcpt (61, 12, 7) and its adjustment (72, 29, 7):
     * TRANSACTION_SOURCE_ID = REQUISITION_HEADER_ID, also RCV_TRANSACTION_ID is populated
     * which provides the requisition_line_id from RCV_TRANSACTIONS  */
    IF ( ( l_txn_action_id   = 3
       AND l_txn_src_type_id = 7 ) OR
        ( l_txn_action_id    = 3
       AND l_txn_src_type_id = 8 ) OR
        ( l_txn_action_id           = 21
       AND l_txn_src_type_id = 8) ) THEN
      l_stmt_num := 27;
      SELECT
        oel.SOURCE_DOCUMENT_LINE_ID
      INTO
        l_req_line_id
      FROM
        OE_ORDER_LINES_ALL oel,
        cst_acct_info_v caiv
      WHERE
          oel.LINE_ID          = l_trx_source_line_id
      and oel.org_id           = caiv.operating_unit
      and caiv.organization_id = l_organization_id;

    ELSIF ( ( l_txn_action_id = 12
       AND l_txn_src_type_id  = 7) OR
            ( l_txn_action_id = 29
       AND l_txn_src_type_id  = 7 ) ) THEN
       SELECT
         REQUISITION_LINE_ID
       INTO
         l_req_line_id
       FROM
         RCV_TRANSACTIONS
       WHERE
         TRANSACTION_ID = l_rcv_txn_id;
    ELSE
      RETURN;
    END IF;
  END IF;
  if g_debug = 'Y' then
    fnd_file.put_line(fnd_file.log, 'Requisition Line ID: '||l_req_line_id);
  end if;

  l_primary_qty := abs(l_primary_qty);
  l_total_primary_qty := abs(l_total_primary_qty);

  if g_debug = 'Y' then
    fnd_file.put_line(fnd_file.log, 'Total Received Primary Qty: '||l_total_primary_qty);
  end if;
  l_stmt_num := 30;
  CompEncumbrance_IntOrdersExp (
            p_api_version         => 1.0,
	    p_transaction_id      => p_transaction_id,
            p_req_line_id         => l_req_line_id,
            p_item_id             => l_item_id,
            p_organization_id     => l_organization_id,
            p_primary_qty         => l_primary_qty,
            p_total_primary_qty   => l_total_primary_qty,

            x_encumbrance_amount  => x_encumbrance_amount,
            x_encumbrance_account => x_encumbrance_account,
            x_return_status       => x_return_status,
            x_return_message      => x_return_message
  );
  if g_debug = 'Y' then
    fnd_file.put_line(fnd_file.log, 'CompEncumbrance_IntOrdersExp (T) >>');
  end if;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    x_return_message := 'Error in CST_UTIL_PUB.CompEncumbrance_IntOrdersExp('||l_stmt_num||')';
  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    x_return_message := 'Error in CST_UTIL_PUB.CompEncumbrance_IntOrdersExp('||l_stmt_num||')';


END CompEncumbrance_IntOrdersExp;

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
O_err_num OUT NOCOPY NUMBER,
O_err_code OUT NOCOPY VARCHAR2,
O_err_msg OUT NOCOPY VARCHAR2
) IS
l_err_num NUMBER;
l_err_code VARCHAR2(240);
l_err_msg VARCHAR2(240);
l_stmt_num NUMBER;
l_test_mcacd NUMBER:=0;
l_test_clcd NUMBER:=0;
insertion_flag_in_mcacd EXCEPTION;
BEGIN

/* Verify if the hook was called, see if it has been used and check if there is data in MCACD*/
SELECT 	COUNT(*)
INTO 	l_test_mcacd
FROM 	MTL_CST_ACTUAL_COST_DETAILS MCACD
WHERE 	TRANSACTION_ID = i_txn_id
AND  	LAYER_ID = i_layer_id
AND     ORGANIZATION_ID = i_org_id;

IF (l_test_mcacd = 0) THEN
	raise no_data_found;
END IF;

/* There shouldn't be details in CLCD if the insertion flag in MCACD is set as Y
   for that cost element, it will suffice that one of the cost element violates
   this condition to error out                                                 */
SELECT  SUM(decode(MCACD.insertion_flag, 'Y', 1, 0))
INTO  	l_test_clcd
FROM 	MTL_CST_ACTUAL_COST_DETAILS MCACD
WHERE 	MCACD.transaction_id = i_txn_id
AND     MCACD.organization_id = i_org_id
AND 	MCACD.layer_id = i_layer_id
AND     EXISTS (SELECT 'X'
               FROM CST_LAYER_COST_DETAILS CLCD
               WHERE MCACD.layer_id = CLCD.layer_id
               AND   MCACD.cost_element_id = CLCD.cost_element_id
               AND   MCACD.level_type = CLCD.level_type)
GROUP BY MCACD.layer_id;

IF g_debug = 'Y' THEN
	fnd_file.put_line(fnd_file.log, '>>>i_txn_id: '||to_char(i_txn_id)||' MCACD: '||to_char(l_test_mcacd)||' Layer_id: '||to_char(i_layer_id));
END IF;


IF  (l_test_clcd <> 0) THEN
	fnd_file.put_line(fnd_file.log, 'There should not be details in CLCD if the insertion flag in MCACD is set to Y in the hook');
	raise insertion_flag_in_mcacd;
END IF;

EXCEPTION
WHEN  no_data_found THEN
      rollback;
      o_err_num := 9999;
      o_err_code := 'CST_NO_COST_HOOK_DATA';
      FND_MESSAGE.set_name('BOM', 'CST_NO_COST_HOOK_DATA');
      o_err_msg := FND_MESSAGE.Get;

      UPDATE mtl_material_transactions
      SET    costed_flag = 'E',
             error_code = substrb(o_err_code,1,240),
             error_explanation = substrb(o_err_msg,1,240),
             request_id = i_req_id,
             program_application_id = i_prg_appl_id,
             program_id = i_prg_id,
             program_update_date = sysdate
      WHERE  transaction_id = i_txn_id;
WHEN insertion_flag_in_mcacd THEN
      rollback;
      o_err_num := 9999;
      o_err_code := 'CST_CLCD_WITH_INS_FLAG';
      FND_MESSAGE.set_name('BOM','CST_CLCD_WITH_INS_FLAG');
      FND_MESSAGE.set_token('TXN_ID', i_txn_id);
      o_err_msg := FND_MESSAGE.Get;
      UPDATE mtl_material_transactions
      SET    costed_flag = 'E',
             error_code = substrb(o_err_code,1,240),
             error_explanation = substrb(o_err_msg,1,240),
             request_id = i_req_id,
             program_application_id = i_prg_appl_id,
             program_id = i_prg_id,
             program_update_date = sysdate
      WHERE  transaction_id = i_txn_id;
WHEN others THEN
      rollback;
      o_err_num:=SQLCODE;
      o_err_msg:='CSTPAVCP.validate_actual_cost_hook('||to_char(l_stmt_num)||'):'||substr(SQLERRM,1,200);
      UPDATE mtl_material_transactions
      SET    costed_flag = 'E',
             error_code = substrb(o_err_code,1,240),
             error_explanation = substrb(o_err_msg,1,240),
             request_id = i_req_id,
             program_application_id = i_prg_appl_id,
             program_id = i_prg_id,
             program_update_date = sysdate
      WHERE  transaction_id = i_txn_id;
END validate_actual_cost_hook;

END CSTPAVCP;

/
