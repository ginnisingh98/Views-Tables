--------------------------------------------------------
--  DDL for Package Body CSTPPINV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPPINV" AS
/* $Header: CSTPINVB.pls 120.27.12010000.5 2010/01/08 11:01:56 lchevala ship $ */

l_debug CONSTANT VARCHAR2(1) := FND_PROFILE.VALUE('MRP_DEBUG');


PROCEDURE cost_inv_txn (
  i_pac_period_id           IN  NUMBER,
  i_legal_entity            IN  NUMBER,
  i_cost_type_id            IN  NUMBER,
  i_cost_group_id           IN  NUMBER,
  i_cost_method             IN  NUMBER,
  i_txn_id                  IN  NUMBER,
  i_txn_action_id           IN  NUMBER,
  i_txn_src_type_id         IN  NUMBER,
  i_item_id                 IN  NUMBER,
  i_txn_qty                 IN  NUMBER,
  i_txn_org_id              IN  NUMBER,
  i_txfr_org_id             IN  NUMBER,
  i_subinventory_code       IN  VARCHAR2,
  i_exp_flag                IN  NUMBER,
  i_exp_item                IN  NUMBER,
  i_pac_rates_id            IN  NUMBER,
  i_process_group           IN  NUMBER,
  i_master_org_id           IN  NUMBER,
  i_uom_control             IN  NUMBER,
  i_user_id                 IN  NUMBER,
  i_login_id                IN  NUMBER,
  i_request_id              IN  NUMBER,
  i_prog_id                 IN  NUMBER,
  i_prog_appl_id            IN  NUMBER,
  i_txn_category            IN  NUMBER,
  i_transfer_price_pd       IN  NUMBER, -- := 0 INVCONV for process-discrete txfer
  o_err_num                 OUT NOCOPY NUMBER,
  o_err_code                OUT NOCOPY VARCHAR2,
  o_err_msg                 OUT NOCOPY VARCHAR2
)
IS
  l_err_num                 NUMBER;
  l_err_code                VARCHAR2(240);
  l_err_msg                 VARCHAR2(240);
  l_cost_layer_id           NUMBER;
  l_quantity_layer_id       NUMBER;
  l_txn_cost_group_id       NUMBER;
  l_txfr_cost_group_id      NUMBER;
  l_fob_point               NUMBER;
  l_count                   NUMBER;
  l_txn_cost                NUMBER;
  l_um_rate                 NUMBER;
  l_converted_txn_qty       NUMBER;
  l_dropship_type_code      NUMBER;
  l_parent_ds_type_code     NUMBER; --These 3 variables added for bug 3907495
  l_parent_rcv_txn_id       NUMBER;
  l_grandpa_rcv_txn_id      NUMBER;
  l_already_processed       NUMBER;
  l_stmt_num                NUMBER := 0;
  PROCESS_ERROR             EXCEPTION;

  -- Revenue / COGS Matching Enhancement
  l_prior_period_shipment   NUMBER := 0;
  l_so_line_id              NUMBER := NULL;
  l_return_status           VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);
  l_api_name   CONSTANT VARCHAR2(30)   	:= 'CSTPPINV.cost_inv_txn';

begin
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';

  IF l_debug = 'Y' THEN
      fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ': begin <<'
                            || ' transaction_id: ' || i_txn_id
                                                        || ', cost group id: ' || i_cost_group_id
                                                        || ', cost type id: ' || i_cost_type_id
                                                        || ', pac period id: ' || i_pac_period_id
                                                        || ', legal entity: ' || i_legal_entity);
  END IF;

  l_stmt_num := 10;
  -- check the existence of layer
  CSTPPCLM.layer_id(i_pac_period_id, i_legal_entity, i_item_id,
                    i_cost_group_id, l_cost_layer_id, l_quantity_layer_id,
                    l_err_num, l_err_code, l_err_msg);
  IF (l_err_num <> 0) THEN
    raise PROCESS_ERROR;
  END IF;

  l_stmt_num := 20;
  -- create a layer if not exist
  IF (l_cost_layer_id = 0) THEN
    CSTPPCLM.create_layer(i_pac_period_id, i_legal_entity, i_item_id,
                          i_cost_group_id, i_user_id, i_login_id, i_request_id,
                          i_prog_id, i_prog_appl_id,
                          l_cost_layer_id, l_quantity_layer_id,
                          l_err_num, l_err_code, l_err_msg);

    IF (l_err_num <> 0) THEN
      raise PROCESS_ERROR;
    END IF;
  END IF;

  -- Obtain some parameters needed by cost processor

  IF (i_txn_action_id IN (3,12,21,15,22)) THEN -- normal processing -- INVCONV

    l_stmt_num := 30;
    SELECT NVL(MAX(cost_group_id),-1)
    INTO l_txn_cost_group_id
    FROM cst_cost_group_assignments
    WHERE organization_id = i_txn_org_id;

    l_stmt_num := 40;
    SELECT NVL(MAX(cost_group_id),-1)
    INTO l_txfr_cost_group_id
    FROM cst_cost_group_assignments
    WHERE organization_id = i_txfr_org_id;

    -- Modified for fob stamping project
    l_stmt_num := 50;
    IF (i_txn_action_id in( 21,22)) THEN -- INVCONV sikhanna
      SELECT nvl(MMT.fob_point, MIP.fob_point)
      INTO l_fob_point
      FROM mtl_interorg_parameters MIP, mtl_material_transactions MMT
      WHERE MIP.from_organization_id = i_txn_org_id
        AND MIP.to_organization_id = i_txfr_org_id
        AND MMT.transaction_id = i_txn_id;
    ELSIF (i_txn_action_id in (12,15)) THEN
      SELECT nvl(MMT.fob_point, MIP.fob_point)
      INTO l_fob_point
      FROM mtl_interorg_parameters MIP, mtl_material_transactions MMT
      WHERE MIP.from_organization_id = i_txfr_org_id
        AND MIP.to_organization_id = i_txn_org_id
        AND MMT.transaction_id = i_txn_id;
    ELSE
      l_fob_point := 0;
    END IF;
  ELSE
    l_txn_cost_group_id := i_cost_group_id;
    l_txfr_cost_group_id := -1;
    l_fob_point := 0;
  END IF;

/*---------------------------------------------------------------------------
| Get the um conversion rate.
| uom_of_txn_qty = l_um_rate * uom_of_converted_txn_qty
| e.g. : DZ = 12 EACH
---------------------------------------------------------------------------*/
  l_stmt_num := 55;

  get_um_rate(i_txn_org_id, i_master_org_id, l_txn_cost_group_id,
              l_txfr_cost_group_id,
              i_txn_action_id, i_item_id, i_uom_control,
              i_user_id, i_login_id, i_request_id, i_prog_id, i_prog_appl_id,
              l_um_rate, l_err_num, l_err_code, l_err_msg);
  IF (l_err_num <> 0) THEN
    raise PROCESS_ERROR;
  END IF;

  l_converted_txn_qty := i_txn_qty * l_um_rate;

/* Update mmt with quantity in the master org um */
/* Bug 6751847 fix to prevent update from both shipping as well as
   receiving cost groups,to avoid lock and hold when run in
   parallel for multiple Cost Groups */

  UPDATE mtl_material_transactions
  SET periodic_primary_quantity = l_converted_txn_qty
  WHERE transaction_id = i_txn_id
    AND organization_id = i_txn_org_id
    AND EXISTS ( SELECT 'x'
                   FROM cst_cost_group_assignments ccga
                  WHERE ccga.cost_group_id = i_cost_group_id
                    AND ccga.organization_id = i_txn_org_id);


/*---------------------------------------------------------------------------
| Insert into mptcd if necessary.
| Five cases :
| - Interorg Accross CG with ownership change (group 1).
|   Calculate the txn cost using data from mtl_transaction_accounts,
|   , then insert that into mptcd elementally.
| - PO related txns (group 1 and i_txn_src_type_id = 1 and i_txn_action_id <> 6).
|   Obtain the transaction cost from po table, then insert that into mptcd.
|   i_txn_action_id of 6 is an ownership txfr, which has no acquisition cost.
|   Therefore these fall into "Other cost owned txns" below.
| - Periodic Cost Update.
|   Update the period id into current period id. This value might be null
|   when it's inserted by the form, because the period might not yet
|   open at the time of form insertion.
| - Other cost owned txns (group 1).
|   Copy from mctcd into mptcd.
| - Other txns
|   No insertion into mptcd is done.
---------------------------------------------------------------------------*/
  IF (i_process_group = 1 AND i_txn_action_id IN (3,12,21,15)) THEN -- INVCONV sikhanna 22 (removed)
    l_stmt_num := 60;
    get_interorg_cost(i_legal_entity, i_pac_period_id, i_cost_type_id,
                      i_cost_group_id,l_txn_cost_group_id, l_txfr_cost_group_id,
                      i_txn_id, i_txn_action_id, i_item_id, l_converted_txn_qty,
                      i_txn_org_id,i_txfr_org_id, i_user_id, i_login_id,
                      i_request_id, i_prog_id, i_prog_appl_id, i_transfer_price_pd, -- INVCONV sikhanna
                      l_err_num, l_err_code, l_err_msg);
    IF (l_err_num <> 0) THEN
      raise PROCESS_ERROR;
    END IF;

  ELSIF (i_process_group = 1 AND i_txn_src_type_id = 1 OR
        (i_txn_action_id = 6 AND i_txn_src_type_id = 13)) THEN

   l_stmt_num := 63;

  /* propogation of bug 4385294.Consigned ownership txfrs do not have rcv_txn_id stamped on them */

   IF (i_txn_action_id = 6) then

    Select mmt.transaction_cost into l_txn_cost
     from  mtl_material_transactions mmt
    where mmt.transaction_id = i_txn_id ;

   ELSE

   l_stmt_num := 65;

  -- Patchset J change: External DropShipments do not have any acquisition cost,
  -- they come in at PO price

   select nvl(rt.dropship_type_code, 3), mmt.transaction_cost, rt.parent_transaction_id
   into l_dropship_type_code, l_txn_cost, l_parent_rcv_txn_id
   from rcv_transactions rt, mtl_material_transactions mmt
   where mmt.transaction_id = i_txn_id
   and mmt.rcv_transaction_id = rt.transaction_id;

   END IF; /* end of check for consigned txfrs */

   -- added for bug 3907495
   -- For RTVs corresponding to true dropship receipts, there is no acquisition
   -- cost.  In this case, we should get the hypothetical acquisition cost from
   -- the unit_price of the forward flow Receive or Match (whatever the parent
   -- is), and make sure we don't call the get_acq_cost procedure.
   if (i_txn_action_id = 1 and i_txn_src_type_id = 1) then -- RTVs
     l_stmt_num := 66;
--"transaction_type = 'MATCH'" is added for bug 4892685, for non-dropship RTVs (unordered->Match->Deliver->RTV)
     select dropship_type_code, transaction_id
     into l_parent_ds_type_code, l_grandpa_rcv_txn_id
     from rcv_transactions
     where (transaction_type = 'RECEIVE' -- 'MATCH' cannot be parent because
     and parent_transaction_id = -1)
     OR transaction_type = 'MATCH'-- there won't be one in a true dropship
     start with transaction_id = l_parent_rcv_txn_id
     connect by transaction_id = prior parent_transaction_id;

     if (l_parent_ds_type_code = 1) then -- external drop ship in the forward flow
       l_stmt_num := 67;

       BEGIN
         select unit_price
         into l_txn_cost
         from rcv_accounting_events
         where rcv_transaction_id = l_grandpa_rcv_txn_id;
       EXCEPTION
         when others then
           NULL; -- if no row exists in RAE, just use MMT.transaction_cost
       END;

       l_dropship_type_code := 1;
     end if;
   end if;
   -- end of additions for bug 3907495

    l_stmt_num := 70;

    /* FP BUG 5845861 fix - For External Dropshipments also include code 2 */
    if (l_dropship_type_code in (2,3) and i_txn_action_id <> 6  AND nvl(l_parent_ds_type_code,3) = 3)   then
      CSTPPACQ.get_acq_cost(i_cost_group_id, i_txn_id, i_cost_type_id, 'I',
                          l_txn_cost, l_err_num, l_err_code, l_err_msg);
      IF (l_err_num <> 0) THEN
        raise PROCESS_ERROR;
      END IF;
    end if;

    INSERT INTO mtl_pac_txn_cost_details (
      transaction_id,
      pac_period_id,
      cost_type_id,
      cost_group_id,
      cost_element_id,
      level_type,
      inventory_item_id,
      transaction_cost,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      last_update_login)
    VALUES(
      i_txn_id,
      i_pac_period_id,
      i_cost_type_id,
      i_cost_group_id,
      1,
      1,
      i_item_id,
      l_txn_cost/l_um_rate,
      SYSDATE,
      i_user_id,
      SYSDATE,
      i_user_id,
      i_request_id,
      i_prog_appl_id,
      i_prog_id,
      SYSDATE,
      i_login_id);

  ELSIF (i_process_group = 1 AND i_txn_action_id = 24) THEN

    UPDATE mtl_pac_txn_cost_details
    SET pac_period_id = i_pac_period_id,
        last_update_date = SYSDATE
    WHERE transaction_id = i_txn_id
      AND cost_type_id = i_cost_type_id
      AND cost_group_id = i_cost_group_id;

  ELSIF (i_process_group = 1 AND i_txn_action_id = 27 AND i_txn_src_type_id = 12) THEN
    -- Revenue / COGS Matching enhancement
    -- If this RMA references a sales order issue, then this query
    -- will return the line ID of that sales order.  Else NULL
    l_stmt_num := 80;
    /* Bug 8236035 */
    SELECT Min(RMA.reference_line_id)
    INTO   l_so_line_id
    FROM   mtl_material_transactions MMT,
           oe_order_lines_all RMA
    WHERE  MMT.transaction_id = i_txn_id
    AND    RMA.line_id = MMT.trx_source_line_id
    /* Bug 8236035 */
    AND    EXISTS (SELECT 1
           FROM cst_cost_group_assignments CCGA
          WHERE CCGA.cost_group_id = i_cost_group_id
            AND CCGA.organization_id = MMT.organization_id);

    -- If the RMA references a sales order issue, and if the
    -- sales order is in a prior period, this will return # > 0
    IF (l_so_line_id IS NOT NULL) THEN
       l_stmt_num := 90;
      SELECT count(*)
      INTO l_prior_period_shipment
      FROM cst_pac_periods cpp,
           oe_order_lines_all SO
      WHERE cpp.pac_period_id = i_pac_period_id
      AND cpp.period_start_date > SO.ACTUAL_SHIPMENT_DATE
      AND SO.line_id = l_so_line_id;

      IF (l_prior_period_shipment > 0) THEN
         -- check if the SO has been processed in this PAC cost type
         l_stmt_num := 100;
          /* Removed for bug 9146453: SELECT count(*)
         INTO   l_already_processed
         FROM   cst_revenue_cogs_match_lines
         WHERE  pac_cost_type_id = i_cost_type_id
         AND    cogs_om_line_id = l_so_line_id;*/

	   /* Added for bug 9146453*/
	  SELECT count(*)
	  INTO   l_already_processed
	  FROM   mtl_material_transactions MMT,
		 mtl_pac_actual_cost_details MPACD
	  WHERE  MMT.transaction_action_id = 1
	  AND    MMT.transaction_source_type_id = 2
	  AND    EXISTS (SELECT 1
		 FROM cst_cost_group_assignments CCGA
		WHERE CCGA.cost_group_id = i_cost_group_id
		  AND CCGA.organization_id = MMT.organization_id)
	  AND    MMT.inventory_item_id = i_item_id
	  AND    MMT.trx_source_line_id = l_so_line_id
	  AND    MPACD.transaction_id = MMT.transaction_id
	  AND    MPACD.cost_type_id = i_cost_type_id;

         IF (l_already_processed >0) THEN
          l_stmt_num := 110;
         -- Use the PAC cost of the Sales Order Issue
         INSERT INTO   mtl_pac_txn_cost_details (
             transaction_id,
             pac_period_id,
             cost_type_id,
             cost_group_id,
             cost_element_id,
             level_type,
             inventory_item_id,
             transaction_cost,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             request_id,
             program_application_id,
             program_id,
             program_update_date,
             last_update_login
             )
         SELECT i_txn_id,
             i_pac_period_id,
             i_cost_type_id,
             i_cost_group_id,
             MPACD.cost_element_id,
             MPACD.level_type,
             i_item_id,
             (SUM(MMT.primary_quantity*MPACD.actual_cost)/SUM(MMT.primary_quantity))/l_um_rate,
             SYSDATE,
             i_user_id,
             SYSDATE,
             i_user_id,
             i_request_id,
             i_prog_appl_id,
             i_prog_id,
             SYSDATE,
             i_login_id
         FROM   mtl_material_transactions MMT,
                mtl_pac_actual_cost_details MPACD
         WHERE  MMT.transaction_action_id = 1
         AND    MMT.transaction_source_type_id = 2
         /* Bug 8236035
	 AND    MMT.organization_id = i_txn_org_id*/
         AND    EXISTS (SELECT 1
                FROM cst_cost_group_assignments CCGA
               WHERE CCGA.cost_group_id = i_cost_group_id
                 AND CCGA.organization_id = MMT.organization_id)
         AND    MMT.inventory_item_id = i_item_id
         AND    MMT.trx_source_line_id = l_so_line_id
         AND    MPACD.transaction_id = MMT.transaction_id
         AND    MPACD.cost_type_id = i_cost_type_id
         GROUP BY
             MPACD.cost_element_id,
             MPACD.level_type;
         ELSE
         -- Create MPTCD for this cost-owned RMA receipt using the perpetual cost
          l_stmt_num := 120;

         INSERT INTO   mtl_pac_txn_cost_details (
             transaction_id,
             pac_period_id,
             cost_type_id,
             cost_group_id,
             cost_element_id,
             level_type,
             inventory_item_id,
             transaction_cost,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             request_id,
             program_application_id,
             program_id,
             program_update_date,
             last_update_login
             )
         SELECT i_txn_id,
             i_pac_period_id,
             i_cost_type_id,
             i_cost_group_id,
             MCACD.cost_element_id,
             MCACD.level_type,
             i_item_id,
             (SUM(MMT.primary_quantity*MCACD.actual_cost)/SUM(MMT.primary_quantity))/l_um_rate,
             SYSDATE,
             i_user_id,
             SYSDATE,
             i_user_id,
             i_request_id,
             i_prog_appl_id,
             i_prog_id,
             SYSDATE,
             i_login_id
         FROM   mtl_material_transactions MMT,
                mtl_cst_actual_cost_details MCACD
         WHERE  MMT.transaction_action_id = 1
         AND    MMT.transaction_source_type_id = 2
         /* Bug 8236035
	 AND    MMT.organization_id = i_txn_org_id*/
         AND    EXISTS (SELECT 1
                FROM cst_cost_group_assignments CCGA
               WHERE CCGA.cost_group_id = i_cost_group_id
                 AND CCGA.organization_id = MMT.organization_id)
         AND    MMT.inventory_item_id = i_item_id
         AND    MMT.trx_source_line_id = l_so_line_id
         AND    MCACD.transaction_id = MMT.transaction_id
         GROUP BY
             MCACD.cost_element_id,
             MCACD.level_type;

	 l_stmt_num := 130;
 	/*Bug 9146453: MCACD can be missing for zero cost items in a std costing org*/
 	 IF SQL%ROWCOUNT = 0 THEN
 	  return;
 	 END IF;

        END IF;
      ELSE  -- RMA points to a sales order in the same period
         return; -- process the RMA the 2nd time it gets passed up - cost derived receipts
      END IF;
    ELSE -- RMA does not reference a sales order
       return; -- process the RMA the 2nd time it gets passed up - cost derived receipts
    END IF;

  ELSIF (i_process_group = 2 AND i_txn_action_id = 27 AND i_txn_src_type_id = 12) THEN
   -- If transaction has been already processed during first pass (i_process_group = 1)
   -- then return without further processing
   -- performance bug fix 6751847 fix: removed cst_pc_txn_history
   -- instead of use mtl_pac_txn_cost_details
    l_stmt_num := 140;
    SELECT count(1)
    INTO   l_already_processed
    FROM   mtl_pac_txn_cost_details
    WHERE  pac_period_id = i_pac_period_id
    AND    cost_group_id = i_cost_group_id
    AND    transaction_id = i_txn_id;

    IF (l_already_processed > 0) THEN
      return;
    END IF;

  ELSIF (i_process_group = 1) THEN
    l_stmt_num := 150;
    INSERT INTO mtl_pac_txn_cost_details (
      transaction_id,
      pac_period_id,
      cost_type_id,
      cost_group_id,
      cost_element_id,
      level_type,
      inventory_item_id,
      transaction_cost,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      last_update_login)
    SELECT
      transaction_id,
      i_pac_period_id,
      i_cost_type_id,
      i_cost_group_id,
      cost_element_id,
      level_type,
      inventory_item_id,
      transaction_cost/l_um_rate,
      SYSDATE,
      i_user_id,
      SYSDATE,
      i_user_id,
      i_request_id,
      i_prog_appl_id,
      i_prog_id,
      SYSDATE,
      i_login_id
    FROM
      mtl_cst_txn_cost_details mctcd
    WHERE
      mctcd.transaction_id = i_txn_id;
  END IF;

  l_stmt_num := 160;
  CSTPPWAC.cost_processor( i_legal_entity, i_pac_period_id, i_txn_org_id,
                           i_cost_group_id, l_txn_cost_group_id,
                           l_txfr_cost_group_id, i_cost_type_id, i_cost_method,
                           i_process_group, i_txn_id, l_quantity_layer_id,
                           l_cost_layer_id, i_pac_rates_id, i_item_id,
                           l_converted_txn_qty, i_txn_action_id,
                           i_txn_src_type_id,
                           l_fob_point, i_exp_item, i_exp_flag, -1, i_user_id,
                           i_login_id, i_request_id, i_prog_appl_id, i_prog_id,
                           i_txn_category, l_err_num, l_err_code, l_err_msg);

  IF (l_err_num <> 0) THEN
    raise PROCESS_ERROR;
  END IF;

  l_stmt_num := 170;
  IF (i_txn_src_type_id = 2 AND i_txn_action_id = 1) THEN  -- Revenue / COGS Matching
    -- cost derived sales order issue
  l_stmt_num := 180;
    CST_RevenueCogsMatch_PVT.Insert_PacSoIssue( p_api_version => 1.0,
                                                x_return_status => l_return_status,
                                                x_msg_count => l_msg_count,
                                                x_msg_data => l_msg_data,
                                                p_transaction_id => i_txn_id,
                                                p_layer_id => l_cost_layer_id,
                                                p_cost_type_id => i_cost_type_id,
                                                p_cost_group_id => i_cost_group_id,
                                                p_user_id => i_user_id,
                                                p_login_id => i_login_id,
                                                p_request_id => i_request_id,
                                                p_pgm_app_id => i_prog_appl_id,
                                                p_pgm_id => i_prog_id);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       l_err_num := -1;
      IF (l_msg_count = 1) THEN
          l_err_msg := substr(l_msg_data,1,240);
       ELSE
          l_err_msg := 'Failure in procedure CST_RevenueCogsMatch_PVT.Insert_PacSoIssue()';
       END IF;
       raise PROCESS_ERROR;
    END IF;
  END IF;

  l_stmt_num := 200;
  IF l_debug = 'Y' THEN
      fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ': return >>');
  END IF;


EXCEPTION
  when PROCESS_ERROR then
    o_err_num := l_err_num;
    o_err_code := l_err_code;
    o_err_msg := 'CSTPPINV.COST_INV_TXN:' || l_err_msg;
  when OTHERS then
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPPINV.COST_INV_TXN: (' || to_char(l_stmt_num) || '): '
                || substr(SQLERRM,1,150);

end cost_inv_txn;


/*---------------------------------------------------------------------------
|  Procedure get_interorg_cost()
|
|  This routine is called for interorg transactions involving an ownership
|  change.
|
|  There are 3 cases in which the ownership changes, and rows need
|  to be inserted into MPTCD :
|  1. Direct Transfer - Rcv txn , processed by the Rcv CG
|  2. FOB Shipment    - Shipment txn , processed by the Rcv CG
|  3. FOB Receipt     - Rcv txn , processed by the Rcv CG
|
|  Algorithm followed for inserting into MPTCD:
|  |-IF (FOB SHIPMENT/RECEIPT and Internal Order with Transfer Pricing) THEN
|  |   |- Create MPTCD (cost element 1) using the transfer price from MMT
|  |   |       stamped on shipment txn)
|  |
|  |-ELSE  --FOB or DIRECT interorg
|  |   |-IF (both send and receiving CGs implemented in same LE/CT) THEN
|  |   |   |- IF (PACP iterative process was used) THEN
|  |   |   |   |- create MPTCD with sending CG cost from CPIC
|  |   |   |   |- if sending CG cost from CPIC not available, default to prior period cost
|  |   |   |   |- if no prior period cost exists, default to perpetual shipment cost
|  |   |   |- ELSE  --PACP not used
|  |   |   |   |- create MPTCD w/sending CG PWAC cost in prior period
|  |   |   |   |- if no prior period cost exists, default to perpetual shipment cost
|  |   |   |- END IF;
|  |   |- ELSE   --send and receiving not implemented in same LE/CT
|  |   |   |- create MPTCD with sending org perpetual shipment cost
|  |   |- END IF;
|  |
|  |-END IF;

|  Appropriate currency conversion done before stamping into MPTCD.
|
---------------------------------------------------------------------------*/

PROCEDURE get_interorg_cost(
            i_legal_entity       IN       NUMBER,
            i_pac_period_id      IN       NUMBER,
            i_cost_type_id       IN       NUMBER,
            i_cost_group_id      IN       NUMBER,
            i_txn_cost_group_id  IN       NUMBER,
            i_txfr_cost_group_id IN       NUMBER,
            i_txn_id             IN       NUMBER,
            i_txn_action_id      IN       NUMBER,
            i_item_id            IN       NUMBER,
            i_txn_qty            IN       NUMBER,
            i_txn_org_id         IN       NUMBER,
            i_txfr_org_id        IN       NUMBER,
            i_user_id            IN       NUMBER,
            i_login_id           IN       NUMBER,
            i_request_id         IN       NUMBER,
            i_prog_id            IN       NUMBER,
            i_prog_appl_id       IN       NUMBER,
            i_transfer_price_pd  IN       NUMBER, -- := 0 INVCONV for process-discrete txfer
            o_err_num            OUT NOCOPY      NUMBER,
            o_err_code           OUT NOCOPY      VARCHAR2,
            o_err_msg            OUT NOCOPY      VARCHAR2
          )
          IS
            l_stmt_num          NUMBER := 0;
            l_from_org          NUMBER;
            l_to_org            NUMBER;
            l_trp_cost          NUMBER;
            l_txfr_credit       NUMBER;
            l_txn_id            NUMBER;
            l_conv_rate         NUMBER;

            l_err_num           NUMBER;
            l_err_code          VARCHAR2(240);
            l_err_msg           VARCHAR2(240);
            process_error       EXCEPTION;

            l_fob_point         NUMBER;
            l_transfer_cost_flag        VARCHAR2(1);

            l_cost_source_cost_group   NUMBER;
            l_shipment_txn_id           NUMBER;
            l_tprice_option             NUMBER;
            l_txfr_price                NUMBER;
            l_same_le_ct                NUMBER;
            l_prev_period_id            NUMBER;
            l_pacp_used                 NUMBER;
            l_include_txfr_txp_costs NUMBER := 1;
            l_sending_cg_cost           NUMBER;
            l_ovhd_cost         NUMBER;

            l_txn_src_type_id           NUMBER;
            l_txfr_legal_entity         NUMBER;

            l_pe_flag                   VARCHAR2(1); -- INVCONV
            l_pd_txfr_ind               NUMBER := 0; -- INVCONV

            l_api_name   CONSTANT VARCHAR2(30)   	:= 'CSTPPINV.get_interorg_cost';

    BEGIN

            IF l_debug = 'Y' THEN
               fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ': begin <<'
                            || ' transaction_id: ' || i_txn_id);
            END IF;

            -- initialize local variables
            l_err_num := 0;
            l_err_code := '';
            l_err_msg := '';

            l_stmt_num := 5;

            IF (i_txn_qty < 0) THEN
              l_from_org := i_txn_org_id;
              l_to_org := i_txfr_org_id;
            ELSE
              l_from_org := i_txfr_org_id;
              l_to_org := i_txn_org_id;
            END IF;

            l_stmt_num := 10;

            /* Get currency conversion rate */
            Get_Snd_Rcv_Rate (i_txn_id,
                              l_from_org,
                              l_to_org,
                              l_conv_rate,
                              l_err_num,
                              l_err_code,
                              l_err_msg);

            IF (l_err_num <> 0) THEN
              raise process_error;
            END IF;

            IF l_debug = 'Y' THEN
               fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ':'
                            || ' l_conv_rate: ' || l_conv_rate);
            END IF;

            /* Get shipment transaction_id */
            /* Get trp cost for process-discrete transfer */
            SELECT decode(i_txn_action_id,
                          21, transaction_id,
                          22, transaction_id, -- INVCONV sikhanna
                          transfer_transaction_id),
                  transaction_source_type_id,
                  /*decode(i_txn_action_id,
                         3, decode(sign(i_txn_qty),
                                   1,transfer_transaction_id,
                                   transaction_id),
                         transaction_id),*/
                 nvl(transportation_cost,0) -- INVCONV sikhanna
            INTO l_shipment_txn_id,
                 l_txn_src_type_id,
                 /*l_txn_id,*/
                 l_trp_cost -- INVCONV
            FROM mtl_material_transactions
            WHERE transaction_id = i_txn_id;

            IF l_debug = 'Y' THEN
               fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ':'
                            || ' l_shipment_txn_id: ' || l_shipment_txn_id
                            || ', l_txn_src_type_id: ' || l_txn_src_type_id
                         /*   || ', l_txn_id: ' || l_txn_id */
                            || ', l_trp_cost: ' || l_trp_cost);
            END IF;

            l_stmt_num := 15;

            /* Get FOB Point */
            SELECT nvl(mmt.fob_point,mip.fob_point)
            INTO   l_fob_point
            FROM   mtl_material_transactions mmt,
                   mtl_interorg_parameters mip
            WHERE  mmt.transaction_id = i_txn_id
            AND    mip.from_organization_id = l_from_org
            AND    mip.to_organization_id = l_to_org;

            IF l_debug = 'Y' THEN
               fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ':'
                            || ' l_fob_point: ' || l_fob_point);
            END IF;

            l_stmt_num := 20;

            /* Get the profile status for Internal Sales Order. */
            BEGIN
                SELECT nvl(fnd_profile.value('CST_TRANSFER_PRICING_OPTION'), 0)
                INTO   l_tprice_option
                FROM   mtl_intercompany_parameters MIP
                WHERE  fnd_profile.value('INV_INTERCOMPANY_INVOICE_INTERNAL_ORDER') = 1
                AND    MIP.flow_type = 1
                AND    MIP.ship_organization_id = (SELECT to_number(HOI.org_information3)
                                                     FROM hr_organization_information HOI
                                                    WHERE HOI.organization_id = l_from_org
                                         AND HOI.org_information_context = 'Accounting Information')
                AND    MIP.sell_organization_id = (SELECT to_number(HOI2.org_information3)
                                                     FROM hr_organization_information HOI2
                                                    WHERE HOI2.organization_id = l_to_org
                                         AND HOI2.org_information_context = 'Accounting Information');
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_tprice_option := -1; /* Chenged it to be -1, will toggle to 0 later */
            END;

            -- Processing the process-discrete txns
            -- INVCONV sikhanna
            SELECT MOD(SUM(DECODE(process_enabled_flag,'Y',1,2)), 2)
            INTO l_pd_txfr_ind
            FROM MTL_PARAMETERS MP
            WHERE MP.ORGANIZATION_ID = i_txn_org_id
            OR MP.ORGANIZATION_ID    = i_txfr_org_id;

            /* Process-Discrete X-fers set the profile to 2 if ICR relations setup and in diff OU */
            IF (l_pd_txfr_ind=1 and l_tprice_option <> -1) THEN
                 l_tprice_option := 2; -- Make it 2 to ignore the profile.
            END IF;

            IF l_tprice_option = -1 THEN
               l_tprice_option := 0; /* Toggle it to 0 as 0 is used later */
            END IF;
            -- INVCONV sikhanna END

            l_stmt_num := 22;

            IF l_debug = 'Y' THEN
               fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ':'
                            || ' l_tprice_option: ' || l_tprice_option || ', process-discrete xfer: ' || l_pd_txfr_ind);
            END IF;

            IF ((l_tprice_option = 2)
                AND ((i_txn_action_id in (21,22) AND l_txn_src_type_id = 8)
                      OR (i_txn_action_id in (12,15) AND l_txn_src_type_id = 7))) THEN

                     /* Internal Sales Order with transfer price specified and profiles set.
                        CST_TRANSFER_PRICING_OPTION is set to: Yes,Price as Incoming Cost.
                        For other values of this profile, the incoming cost populated into
                        MPTCD will follow the same rules as in the case of ordinary interorg
                        transfers */

                       l_stmt_num := 25;

                       /* Get transfer price from MMT */
                       SELECT transfer_price
                       INTO   l_txfr_price
                       FROM   mtl_material_transactions
                       WHERE  transaction_id = l_shipment_txn_id;

                       IF (l_txfr_price is NULL) THEN
                          fnd_file.put_line(fnd_file.log,'Transfer Price not available');
                          l_err_msg := 'CSTPPINV.get_interorg_cost : ' || to_char(l_stmt_num) ||' : '|| ' Transfer Price not available';
                          l_err_num := 9999;
                          raise process_error;
                       END IF;

                       IF l_debug = 'Y' THEN
                          fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ':'
                            || ' l_txfr_price: ' || l_txfr_price);
                       END IF;

                       l_stmt_num := 30;

                       /* Insert transfer price into MPTCD with cost element 1 */

                       CSTPPINV.insert_elemental_cost(
                               i_pac_period_id      => i_pac_period_id,
                               i_cost_type_id       => i_cost_type_id,
                               i_cost_group_id      => i_cost_group_id,
                               i_txn_id             => i_txn_id,
                               i_item_id            => i_item_id,
                               i_cost_element_id    => 1,
                               i_level_type         => 1,
                               i_cost               => l_txfr_price * l_conv_rate,
                               i_user_id            => i_user_id,
                               i_login_id           => i_login_id,
                               i_request_id         => i_request_id,
                               i_prog_id            => i_prog_id,
                               i_prog_appl_id       => i_prog_appl_id,
                               o_err_num            => l_err_num,
                               o_err_code           => l_err_code,
                               o_err_msg            => l_err_msg
                          );

           ELSIF (l_pd_txfr_ind <> 1) THEN  /* Not a transfer pricing situation - Ordinary Interorg transfers */

                   l_stmt_num := 32;

                   -- discrete-discrete interorg transfer

                   IF l_debug = 'Y' THEN
                      fnd_file.put_line(fnd_file.log,' Regular Interorg Transfer:' || ' discrete-discrete xfer: ');
                   END IF;

                   IF ((l_tprice_option = 1)
                      AND ((i_txn_action_id in (21,22) AND l_txn_src_type_id = 8)
                          OR (i_txn_action_id in (12,15) AND l_txn_src_type_id = 7))) THEN
                   /* This is a case of internal sales order with
                      CST:Transfer Pricing Option = Yes, Price NOT as Incoming Cost.
                      In this case, although we populate MPTCD with the same sending CG
                      cost as if this were a regular interorg transfer, we should NOT
                      be adding the transfer credit and transportation charge
                      to the sending CG cost.  This is to be consistent with
                      the functionality in perpetual costing. */
                       l_include_txfr_txp_costs := 0;
                   ELSE
                   /* In all other cases, including internal sales order with
                      CST:Transfer Pricing Option = No, we should add the transfer
                      credit and transportation charge to the sending CG cost. */
                       l_include_txfr_txp_costs := 1;
                   END IF;


                   l_stmt_num := 35;

                   /* Get legal entity of the other cost group,if available */

                   BEGIN
                       SELECT legal_entity
                       INTO l_txfr_legal_entity
                       FROM cst_cost_groups
                       WHERE cost_group_id = decode(i_txn_action_id,
                                                21,decode(l_fob_point,
                                                          1,i_txn_cost_group_id,
                                                          i_txfr_cost_group_id),
                                                i_txfr_cost_group_id);
                   EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                       l_txfr_legal_entity := -1;
                   END;

                   /* See if i_cost_type_id is attached to the transfer LE as well */
                   SELECT count(*)
                   INTO   l_same_le_ct
                   FROM   cst_le_cost_types
                   WHERE  legal_entity = l_txfr_legal_entity
                   AND    cost_type_id = i_cost_type_id;

                   l_stmt_num := 40;

                   /* The transfer_cost_flag status indicates if PACP is used */
                   SELECT TRANSFER_COST_FLAG
                   INTO   l_transfer_cost_flag
                   FROM   CST_LE_COST_TYPES
                   WHERE  LEGAL_ENTITY = i_legal_entity
                   AND    COST_TYPE_ID = i_cost_type_id;

                   IF l_debug = 'Y' THEN
                      fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ':'
                            || ' l_txfr_legal_entity: ' || l_txfr_legal_entity
                            || ', l_same_le_ct: ' || l_same_le_ct
                            || ', l_transfer_cost_flag (PACP): ' || l_transfer_cost_flag);
                   END IF;

                   l_stmt_num := 45;

                   /* Check for the same LE/CT combination */
                   IF (i_legal_entity = l_txfr_legal_entity AND l_same_le_ct > 0) THEN

                   /* Find the Cost group to get the estimated sending CG cost from.
                      For direct interorgs, the sending CG is the transfer CG.
                      For the shipment transaction of FOB shipment processed by the
                      receiving CG, the sending CG is the transaction CG.
                      For the receipt transaction of FOB receipt processed by
                      the receiving CG, the sending CG is the transfer CG. */

                       l_stmt_num := 49;

                       IF ( I_TXN_ACTION_ID = 21 AND L_FOB_POINT = 1 ) THEN
                            L_COST_SOURCE_COST_GROUP := I_TXN_COST_GROUP_ID;
                       ELSE
                            L_COST_SOURCE_COST_GROUP := I_TXFR_COST_GROUP_ID;
                       END IF;

                       IF l_debug = 'Y' THEN
                          fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ':'
                            || ' l_cost_source_cost_group: ' || l_cost_source_cost_group);
                       END IF;

                       IF (l_transfer_cost_flag = 'Y') THEN

                           IF l_debug = 'Y' THEN
                              fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ':'
                                 || ' Same LE/CT Transfer with PACP enabled');
                           END IF;

                           /*  Use PACP cost if available */
                           l_stmt_num := 50;

                           CSTPPINV.get_pacp_cost(
                             i_cost_source_cost_group => l_cost_source_cost_group,
                             i_pac_period_id => i_pac_period_id,
                             i_cost_type_id => i_cost_type_id,
                             i_cost_group_id => i_cost_group_id,
                             i_txn_id => i_txn_id,
                             i_item_id => i_item_id,
                             i_conv_rate => l_conv_rate,
                             i_user_id => i_user_id,
                             i_login_id => i_login_id,
                             i_request_id => i_request_id,
                             i_prog_id => i_prog_id,
                             i_prog_appl_id => i_prog_appl_id,
                             x_pacp_used => l_pacp_used,
                             x_pacp_cost => l_sending_cg_cost,
                             o_err_num => l_err_num,
                             o_err_code => l_err_code,
                             o_err_msg => l_err_msg);

                           IF (l_err_num <> 0) THEN
                             raise process_error;
                           END IF;

                           IF (l_pacp_used = -1) THEN

                            /* There is no PACP cost, so no costs were inserted into MPTCD.
                               Insert perpetual shipment cost instead. */

                               CSTPPINV.get_perp_ship_cost(
                                  i_pac_period_id => i_pac_period_id,
                                  i_cost_type_id => i_cost_type_id,
                                  i_cost_group_id => i_cost_group_id,
                                  i_txn_id => i_txn_id,
                                  i_mta_txn_id => l_shipment_txn_id,
                                  i_item_id => i_item_id,
                                  i_from_org => l_from_org,
                                  i_conv_rate => l_conv_rate,
                                  i_user_id => i_user_id,
                                  i_login_id => i_login_id,
                                  i_request_id  => i_request_id,
                                  i_prog_id => i_prog_id,
                                  i_prog_appl_id => i_prog_appl_id,
                                  x_perp_ship_cost => l_sending_cg_cost,
                                  o_err_num => l_err_num,
                                  o_err_code => l_err_code,
                                  o_err_msg => l_err_msg
                               );

                              IF (l_err_num <> 0) THEN
                                 raise process_error;
                              END IF;

                           END IF; /* IF (l_pacp_used = -1) THEN */

                        ELSE   /* PACP is not enabled */

                           l_stmt_num := 80;

                           IF l_debug = 'Y' THEN
                              fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ':'
                                || ' Same LE/CT Transfer with PACP not enabled');
                           END IF;

                          /* PACP is not enabled. Use prior period sending CG PWAC Cost */

                           CSTPPINV.get_prev_period_cost(
                              i_legal_entity => i_legal_entity,
                              i_cost_source_cost_group => l_cost_source_cost_group,
                              i_pac_period_id => i_pac_period_id,
                              i_cost_type_id => i_cost_type_id,
                              i_cost_group_id => i_cost_group_id,
                              i_txn_id => i_txn_id,
                              i_item_id => i_item_id,
                              i_conv_rate => l_conv_rate,
                              i_user_id => i_user_id,
                              i_login_id => i_login_id,
                              i_request_id  => i_request_id,
                              i_prog_id => i_prog_id,
                              i_prog_appl_id => i_prog_appl_id,
                              x_prev_period_id => l_prev_period_id,
                              x_prev_period_cost => l_sending_cg_cost,
                              o_err_num => l_err_num,
                              o_err_code => l_err_code,
                              o_err_msg => l_err_msg
                           );

                           IF (l_err_num <> 0) THEN
                              raise process_error;
                           END IF;

                           IF (l_prev_period_id = -1) THEN

                             /* There is no prior period cost, so no costs were inserted into MPTCD.
                                Insert perpetual shipment cost instead. */

                               CSTPPINV.get_perp_ship_cost(
                                 i_pac_period_id => i_pac_period_id,
                                 i_cost_type_id => i_cost_type_id,
                                 i_cost_group_id => i_cost_group_id,
                                 i_txn_id => i_txn_id,
                                 i_mta_txn_id => l_shipment_txn_id,
                                 i_item_id => i_item_id,
                                 i_from_org => l_from_org,
                                 i_conv_rate => l_conv_rate,
                                 i_user_id => i_user_id,
                                 i_login_id => i_login_id,
                                 i_request_id  => i_request_id,
                                 i_prog_id => i_prog_id,
                                 i_prog_appl_id => i_prog_appl_id,
                                 x_perp_ship_cost => l_sending_cg_cost,
                                 o_err_num => l_err_num,
                                 o_err_code => l_err_code,
                                 o_err_msg => l_err_msg
                               );

                               IF (l_err_num <> 0) THEN
                                  raise process_error;
                               END IF;

                           END IF; /* IF (l_prev_period_id = -1) THEN */

                       END IF; /* End for IF l_transfer_cost_flag */

                   ELSE   /* Not in same LE/CT */

                       l_stmt_num := 120;

                       IF l_debug = 'Y' THEN
                          fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ':' || ' Different LE/CT Transfer:');
                       END IF;

                       /* Sending and Receiving Orgs not in the same LE/CT
                          Use MTA Cost */

                       CSTPPINV.get_perp_ship_cost(
                         i_pac_period_id => i_pac_period_id,
                         i_cost_type_id => i_cost_type_id,
                         i_cost_group_id => i_cost_group_id,
                         i_txn_id => i_txn_id,
                         i_mta_txn_id => l_shipment_txn_id,
                         i_item_id => i_item_id,
                         i_from_org => l_from_org,
                         i_conv_rate => l_conv_rate,
                         i_user_id => i_user_id,
                         i_login_id => i_login_id,
                         i_request_id  => i_request_id,
                         i_prog_id => i_prog_id,
                         i_prog_appl_id => i_prog_appl_id,
                         x_perp_ship_cost => l_sending_cg_cost,
                         o_err_num => l_err_num,
                         o_err_code => l_err_code,
                         o_err_msg => l_err_msg
                       );

                       IF (l_err_num <> 0) THEN
                           raise process_error;
                       END IF;

                   END IF; /* IF (i_legal_entity = l_txfr_legal_entity AND l_same_le_ct > 0) THEN */

                   IF l_debug = 'Y' THEN
                      fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ':'
                            || ' l_sending_cg_cost: ' || l_sending_cg_cost);
                   END IF;


                  IF (l_include_txfr_txp_costs = 1) THEN
                     /* Add transfer credit and transportation charges on top of the sending CG cost. */
                     l_stmt_num := 130;

                     CSTPPINV.get_txfr_trp_cost(
                        i_source_txn_id => l_shipment_txn_id,
                        i_source_cost => (l_sending_cg_cost),
                        x_txfr_credit => l_txfr_credit,
                        x_trp_cost => l_trp_cost,
                        o_err_num => l_err_num,
                        o_err_code => l_err_code,
                        o_err_msg => l_err_msg
                     );

                     IF (l_err_num <> 0) THEN
                       raise process_error;
                     END IF;

                    l_ovhd_cost :=  (l_trp_cost + l_txfr_credit) * l_conv_rate;
                    fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ': l_ovhd_cost = ' || l_ovhd_cost);

                    IF (l_ovhd_cost > 0) THEN
                      CSTPPINV.add_elemental_cost(
                         i_pac_period_id      => i_pac_period_id,
                         i_cost_type_id       => i_cost_type_id,
                         i_cost_group_id      => i_cost_group_id,
                         i_txn_id             => i_txn_id,
                         i_item_id            => i_item_id,
                         i_cost_element_id    => 2,
                         i_level_type         => 1,
                         i_incr_cost          => l_ovhd_cost,
                         i_user_id            => i_user_id,
                         i_login_id           => i_login_id,
                         i_request_id         => i_request_id,
                         i_prog_id            => i_prog_id,
                         i_prog_appl_id       => i_prog_appl_id,
                         o_err_num            => l_err_num,
                         o_err_code           => l_err_code,
                         o_err_msg            => l_err_msg
                      );

                      IF (l_err_num <> 0) THEN
                        raise process_error;
                      END IF;
                    END IF; /* IF (l_ovhd_cost > 0) THEN */

                 END IF; /* IF (i_include_txfr_txp_costs = 1) THEN */

           ELSE -- INVCONV Process-Discrete Transfer.

                        IF l_debug = 'Y' THEN
                            fnd_file.put_line(fnd_file.log,' INVCONV process-discrete xfer');
                        END IF;

                        l_stmt_num := 145;

                         --INVCONV sikhanna
                         -- From organization is a process org. just get transaction cost
                         -- trp cost and conv rate is selected in the begining itself

                         INSERT INTO mtl_pac_txn_cost_details (
                          transaction_id,
                          pac_period_id,
                          cost_type_id,
                          cost_group_id,
                          cost_element_id,
                          level_type,
                          inventory_item_id,
                          transaction_cost,
                          last_update_date,
                          last_updated_by,
                          creation_date,
                          created_by,
                          request_id,
                          program_application_id,
                          program_id,
                          program_update_date,
                          last_update_login)
                        VALUES(
                          i_txn_id,
                          i_pac_period_id,
                          i_cost_type_id,
                          i_cost_group_id,
                          1,
                          1,
                          i_item_id,
                          i_transfer_price_pd,
                          SYSDATE,
                          i_user_id,
                          SYSDATE,
                          i_user_id,
                          i_request_id,
                          i_prog_appl_id,
                          i_prog_id,
                          SYSDATE,
                          i_login_id);

                        l_stmt_num := 150;

                        IF l_debug = 'Y' THEN
                            fnd_file.put_line(fnd_file.log,' transfer price stamped: ' || i_transfer_price_pd);
                            fnd_file.put_line(fnd_file.log,' txn_axn_id/qty: ' || i_txn_action_id || '/' || i_txn_qty);
                        END IF;

                        /* Don't earn overhead for Transportation Cost for Direct Interorg Receipt */
                        /* Also transfer cost=transfer price for receiving org, intransit rcpt, fob rcpt */
                        IF ((i_txn_action_id = 3 and i_txn_qty > 0) or (i_txn_action_id=12 and l_fob_point=2)) THEN

                          IF l_debug = 'Y' THEN
                              fnd_file.put_line(fnd_file.log,' No MOH earned: ');
                          END IF;

                        ELSE -- Earn MOH in all other cases

                            INSERT INTO mtl_pac_txn_cost_details (
                              transaction_id,
                              pac_period_id,
                              cost_type_id,
                              cost_group_id,
                              cost_element_id,
                              level_type,
                              inventory_item_id,
                              transaction_cost,
                              last_update_date,
                              last_updated_by,
                              creation_date,
                              created_by,
                              request_id,
                              program_application_id,
                              program_id,
                              program_update_date,
                              last_update_login)
                            VALUES (
                              i_txn_id,
                              i_pac_period_id,
                              i_cost_type_id,
                              i_cost_group_id,
                              2,
                              1,
                              i_item_id,
                              l_trp_cost / abs(i_txn_qty) * decode(i_txn_action_id,
                                                                   15, 1,
                                                                   22, 1,
                                                                   12, decode(l_fob_point,
                                                                              2, 1,
                                                                              l_conv_rate),
                                                                   l_conv_rate),
                              SYSDATE,
                              i_user_id,
                              SYSDATE,
                              i_user_id,
                              i_request_id,
                              i_prog_appl_id,
                              i_prog_id,
                              SYSDATE,
                              i_login_id);

                              IF l_debug = 'Y' THEN
                                  fnd_file.put_line(fnd_file.log,' transportation cost as MOH stamped: ' || l_trp_cost);
                              END IF;

                        END IF; /* IF ((i_txn_action_id = 3 and i_txn_qty > 0) or (i_txn_action_id=12 and l_fob_point=2)) THEN */

           END IF;  /* IF internal sales order ... */

        l_stmt_num := 200;

    IF l_debug = 'Y' THEN
          fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ': return >>');
    END IF;

    EXCEPTION

     when process_error then
       o_err_num := l_err_num;
       o_err_code := l_err_code;
       o_err_msg := l_err_msg;

     when OTHERS then
       o_err_num := SQLCODE;
       o_err_msg := 'CSTPPINV.get_interorg_cost (' || to_char(l_stmt_num) ||
                      '): ' || substr(SQLERRM,1,200);
       fnd_file.put_line(fnd_file.log, o_err_msg);

END get_interorg_cost;

/*---------------------------------------------------------------------------
|  Procedure get_txfr_trp_cost()
|
|  This routine returns the unit transfer credit and transportation charge
|  for interorg transactions involving an ownership change, given
|  the transaction from which to obtain the transfer percentage, transfer cost,
|  and transportation charge, and i_source_cost, which is the unit cost upon which
|  a transfer percentage should be applied.  i_source_cost should be in the
|  currency of the source_txn_id org.  x_txfr_credit and x_trp_cost will be
|  unit costs returned in the currency of the source_txn_id org
|
|
---------------------------------------------------------------------------*/

PROCEDURE get_txfr_trp_cost(
  i_source_txn_id   IN   NUMBER,
  i_source_cost     IN   NUMBER,
  x_txfr_credit        OUT NOCOPY      NUMBER,
  x_trp_cost           OUT NOCOPY      NUMBER,
  o_err_num            OUT NOCOPY      NUMBER,
  o_err_code           OUT NOCOPY      VARCHAR2,
  o_err_msg            OUT NOCOPY      VARCHAR2
)
IS
  l_stmt_num          NUMBER := 0;
  l_err_num           NUMBER;
  l_err_code          VARCHAR2(240);
  l_err_msg           VARCHAR2(240);

  l_trp_cost          NUMBER;
  l_txfr_percent      NUMBER;
  l_txfr_cost         NUMBER;

  l_txfr_credit       NUMBER;
  l_shipment_txn_qty  NUMBER;

  l_api_name   CONSTANT VARCHAR2(30)   	:= 'CSTPPINV.get_txfr_trp_cost';

BEGIN

      IF l_debug = 'Y' THEN
         fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ': begin <<'
                            || ' source_transaction_id: ' || i_source_txn_id
                            || ' source_cost: ' || i_source_cost);
      END IF;

      -- initialize local variables
      l_err_num := 0;
      l_err_code := '';
      l_err_msg := '';

      l_stmt_num := 10;

    /* Pick up transfer credit and transportation charge from the shipment txn */
    SELECT nvl(transfer_percentage,0),
           nvl(transfer_cost,0),
           nvl(transportation_cost,0),
           primary_quantity
    INTO   l_txfr_percent,
           l_txfr_cost,
           l_trp_cost,
           l_shipment_txn_qty
    FROM mtl_material_transactions
    WHERE transaction_id = i_source_txn_id;

    IF l_debug = 'Y' THEN
       fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ':'
                            || ' l_txfr_percent: ' || l_txfr_percent
                            || ', l_txfr_cost: ' || l_txfr_cost
                            || ', l_trp_cost: ' || l_trp_cost
                            || ', l_shipment_txn_qty: ' || l_shipment_txn_qty);
    END IF;

    l_stmt_num := 20;

    IF (l_txfr_percent <> 0) THEN
        l_txfr_credit := (l_txfr_percent * i_source_cost / 100);
    ELSIF (l_txfr_cost <> 0) THEN
        l_txfr_credit := l_txfr_cost / abs(l_shipment_txn_qty);
    ELSE
        l_txfr_credit := 0;
    END IF;

    l_stmt_num := 30;
    x_txfr_credit := l_txfr_credit;
    x_trp_cost := l_trp_cost / abs(l_shipment_txn_qty);

    IF l_debug = 'Y' THEN
       fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ':'
                            || ' x_txfr_credit: ' || x_txfr_credit
                            || ', x_trp_cost: ' || x_trp_cost);
    END IF;

    l_stmt_num := 40;

    IF l_debug = 'Y' THEN
          fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ': return >>');
    END IF;

EXCEPTION

     when OTHERS then
       o_err_num := SQLCODE;
       o_err_msg := 'CSTPPINV.get_txfr_trp_cost (' || to_char(l_stmt_num) ||
                      '): ' || substr(SQLERRM,1,200);
       fnd_file.put_line(fnd_file.log, o_err_msg);

END get_txfr_trp_cost;

/*---------------------------------------------------------------------------
|  Procedure add_elemental_cost()
|
|  This routine inserts the specified incremental cost
|  (parameter i_incr_cost) into the given cost element of MCTCD if
|  the element does not yet exist, or updates the cost element
|  with the incremental cost if the cost element already exists.
|
|  The i_incr_cost is assumed to already be in the proper currency.
|
---------------------------------------------------------------------------*/

PROCEDURE add_elemental_cost(
            i_pac_period_id     IN   NUMBER,
            i_cost_type_id       IN       NUMBER,
            i_cost_group_id      IN       NUMBER,
            i_txn_id             IN       NUMBER,
            i_item_id            IN       NUMBER,
            i_cost_element_id    IN       NUMBER,
            i_level_type         IN       NUMBER,
            i_incr_cost          IN       NUMBER,
            i_user_id            IN       NUMBER,
            i_login_id           IN       NUMBER,
            i_request_id         IN       NUMBER,
            i_prog_id            IN       NUMBER,
            i_prog_appl_id       IN       NUMBER,
            o_err_num            OUT NOCOPY      NUMBER,
            o_err_code           OUT NOCOPY      VARCHAR2,
            o_err_msg            OUT NOCOPY      VARCHAR2
)
IS
  l_stmt_num          NUMBER := 0;
  l_err_num           NUMBER;
  l_err_code          VARCHAR2(240);
  l_err_msg           VARCHAR2(240);

  process_error       EXCEPTION;
  l_elem_cnt          NUMBER;
  l_api_name   CONSTANT VARCHAR2(30)   	:= 'CSTPPINV.add_elemental_cost';

BEGIN

                IF l_debug = 'Y' THEN
                   fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ': begin <<'
                            || ' i_txn_id: ' || i_txn_id);
                END IF;

                -- initialize local variables
                l_err_num := 0;
                l_err_code := '';
                l_err_msg := '';

                l_stmt_num := 10;

                SELECT count(*)
                INTO  l_elem_cnt
                FROM  mtl_pac_txn_cost_details
                WHERE transaction_id =  I_TXN_ID
                AND   pac_period_id = I_PAC_PERIOD_ID
                AND   cost_type_id = I_COST_TYPE_ID
                AND   cost_group_id = I_COST_GROUP_ID
                AND   cost_element_id = i_cost_element_id
                AND   level_type = i_level_type;

                IF l_elem_cnt > 0 THEN

                    l_stmt_num := 20;

                    UPDATE MTL_PAC_TXN_COST_DETAILS
                    SET    transaction_cost = (transaction_cost + i_incr_cost)
                    WHERE  transaction_id =  I_TXN_ID
                    AND    pac_period_id = I_PAC_PERIOD_ID
                    AND    cost_type_id = I_COST_TYPE_ID
                    AND    cost_group_id = I_COST_GROUP_ID
                    AND    cost_element_id = i_cost_element_id
                    AND    level_type = i_level_type;

                ELSE

                    l_stmt_num := 30;

                    CSTPPINV.insert_elemental_cost(
                         i_pac_period_id      => i_pac_period_id,
                         i_cost_type_id       => i_cost_type_id,
                         i_cost_group_id      => i_cost_group_id,
                         i_txn_id             => i_txn_id,
                         i_item_id            => i_item_id,
                         i_cost_element_id    => i_cost_element_id,
                         i_level_type         => i_level_type,
                         i_cost               => i_incr_cost,
                         i_user_id            => i_user_id,
                         i_login_id           => i_login_id,
                         i_request_id         => i_request_id,
                         i_prog_id            => i_prog_id,
                         i_prog_appl_id       => i_prog_appl_id,
                         o_err_num            => l_err_num,
                         o_err_code           => l_err_code,
                         o_err_msg            => l_err_msg
                      );

                     IF (l_err_num <> 0) THEN
                       raise process_error;
                     END IF;

                END IF;  /* (l_incr_cnt > 0) */

                l_stmt_num := 40;

                IF l_debug = 'Y' THEN
                   fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ': return >>');
                END IF;

EXCEPTION

     when process_error then
       o_err_num := l_err_num;
       o_err_code := l_err_code;
       o_err_msg := l_err_msg;

     when OTHERS then
       o_err_num := SQLCODE;
       o_err_msg := 'CSTPPINV.add_elemental_cost (' || to_char(l_stmt_num) ||
                      '): ' || substr(SQLERRM,1,200);
       fnd_file.put_line(fnd_file.log, o_err_msg);
END add_elemental_cost;

/*---------------------------------------------------------------------------
|  Procedure insert_elemental_cost()
|
|  This routine inserts the specified cost
|  (parameter i_incr_cost) into the given cost element of MCTCD.
|
|  The i_cost is assumed to already be in the proper currency.
|
---------------------------------------------------------------------------*/

PROCEDURE insert_elemental_cost(
            i_pac_period_id     IN   NUMBER,
            i_cost_type_id       IN       NUMBER,
            i_cost_group_id      IN       NUMBER,
            i_txn_id             IN       NUMBER,
            i_item_id            IN       NUMBER,
            i_cost_element_id    IN       NUMBER,
            i_level_type         IN       NUMBER,
            i_cost               IN       NUMBER,
            i_user_id            IN       NUMBER,
            i_login_id           IN       NUMBER,
            i_request_id         IN       NUMBER,
            i_prog_id            IN       NUMBER,
            i_prog_appl_id       IN       NUMBER,
            o_err_num            OUT NOCOPY      NUMBER,
            o_err_code           OUT NOCOPY      VARCHAR2,
            o_err_msg            OUT NOCOPY      VARCHAR2
)
IS
  l_stmt_num          NUMBER := 0;
  l_err_num           NUMBER;
  l_err_code          VARCHAR2(240);
  l_err_msg           VARCHAR2(240);

  l_elem_cnt          NUMBER;
  l_api_name   CONSTANT VARCHAR2(30)   	:= 'CSTPPINV.insert_elemental_cost';

BEGIN

                IF l_debug = 'Y' THEN
                   fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ': begin <<'
                            || ' i_txn_id: ' || i_txn_id);
                END IF;

                -- initialize local variables
                l_err_num := 0;
                l_err_code := '';
                l_err_msg := '';

                l_stmt_num := 10;


                    INSERT INTO MTL_PAC_TXN_COST_DETAILS (
                           transaction_id,
                           pac_period_id,
                           cost_type_id,
                           cost_group_id,
                           cost_element_id,
                           level_type,
                           inventory_item_id,
                           transaction_cost,
                           last_update_date,
                           last_updated_by,
                           creation_date,
                           created_by,
                           request_id,
                           program_application_id,
                           program_id,
                           program_update_date,
                           last_update_login )
                     VALUES(
                           I_TXN_ID,
                           I_PAC_PERIOD_ID,
                           I_COST_TYPE_ID,
                           I_COST_GROUP_ID,
                           i_cost_element_id,
                           i_level_type,
                           i_item_id,
                           (i_cost),
                           sysdate,
                           i_user_id,
                           sysdate,
                           i_user_id,
                           i_request_id,
                           i_prog_appl_id,
                           i_prog_id,
                           sysdate,
                           i_login_id);


                l_stmt_num := 20;

                IF l_debug = 'Y' THEN
                   fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ': return >>');
                END IF;

EXCEPTION
     when OTHERS then
       o_err_num := SQLCODE;
       o_err_msg := 'CSTPPINV.insert_elemental_cost (' || to_char(l_stmt_num) ||
                      '): ' || substr(SQLERRM,1,200);
       fnd_file.put_line(fnd_file.log, o_err_msg);
END insert_elemental_cost;


/*---------------------------------------------------------------------------
|  Procedure get_pacp_cost()
|
|  This is a helper routine to get_interorg_cost.
|  It inserts the PACP cost of i_cost_source_cost_group from CPIC into MPTCD
|  plus any transfer and transportation charges as appropriate.
|
|  Returns x_pacp_used = -1, if no costs were inserted into MPTCD.
---------------------------------------------------------------------------*/
PROCEDURE get_pacp_cost(
            i_cost_source_cost_group     IN     NUMBER,
            i_pac_period_id      IN       NUMBER,
            i_cost_type_id       IN       NUMBER,
            i_cost_group_id      IN       NUMBER,
            i_txn_id             IN       NUMBER,
            i_item_id            IN       NUMBER,
            i_conv_rate          IN       NUMBER,
            i_user_id            IN       NUMBER,
            i_login_id           IN       NUMBER,
            i_request_id         IN       NUMBER,
            i_prog_id            IN       NUMBER,
            i_prog_appl_id       IN       NUMBER,
            x_pacp_used          OUT NOCOPY      NUMBER,
            x_pacp_cost          OUT NOCOPY      NUMBER,
            o_err_num            OUT NOCOPY      NUMBER,
            o_err_code           OUT NOCOPY      VARCHAR2,
            o_err_msg            OUT NOCOPY      VARCHAR2
)
    IS
      l_stmt_num          NUMBER := 0;
      l_err_num           NUMBER;
      l_err_code          VARCHAR2(240);
      l_err_msg           VARCHAR2(240);

      l_pacp_pwac_cost    NUMBER;
      l_api_name   CONSTANT VARCHAR2(30)   	:= 'CSTPPINV.get_pacp_cost';

    BEGIN

         IF l_debug = 'Y' THEN
            fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ': begin <<'
                            || ' i_txn_id: ' || i_txn_id);
         END IF;

         -- initialize local variables
         l_err_num := 0;
         l_err_code := '';
         l_err_msg := '';

         l_stmt_num := 10;

         BEGIN
          /* Get PACP cost from CPICD */
           SELECT NVL(CPIC.item_cost,0)
           INTO  l_pacp_pwac_cost
           FROM  CST_PAC_ITEM_COSTS CPIC
           WHERE CPIC.INVENTORY_ITEM_ID = i_item_id
           AND   CPIC.COST_GROUP_ID     = i_cost_source_cost_group
           AND   CPIC.PAC_PERIOD_ID     = i_pac_period_id;

         EXCEPTION
           WHEN no_data_found THEN
              x_pacp_used := -1;
              x_pacp_cost := NULL;
              return;
         END;

         l_stmt_num := 20;

         INSERT INTO MTL_PAC_TXN_COST_DETAILS (
                          transaction_id,
                          pac_period_id,
                          cost_type_id,
                          cost_group_id,
                          cost_element_id,
                          level_type,
                          inventory_item_id,
                          transaction_cost,
                          last_update_date,
                          last_updated_by,
                          creation_date,
                          created_by,
                          request_id,
                          program_application_id,
                          program_id,
                          program_update_date,
                          last_update_login )
         SELECT
                          I_TXN_ID,
                          I_PAC_PERIOD_ID,
                          I_COST_TYPE_ID,
                          I_COST_GROUP_ID,
                          CPICD.cost_element_id,
                          CPICD.level_type,
                          i_item_id,
                          (CPICD.item_cost * i_conv_rate),
                          sysdate,
                          i_user_id,
                          sysdate,
                          i_user_id,
                          i_request_id,
                          i_prog_appl_id,
                          i_prog_id,
                          sysdate,
                          i_login_id
         FROM  CST_PAC_ITEM_COSTS CPIC,
               CST_PAC_ITEM_COST_DETAILS CPICD
         WHERE CPICD.COST_LAYER_ID    = CPIC.COST_LAYER_ID
         AND   CPIC.INVENTORY_ITEM_ID = i_item_id
         AND   CPIC.COST_GROUP_ID     = i_cost_source_cost_group
         AND   CPIC.PAC_PERIOD_ID     = I_PAC_PERIOD_ID;

         l_stmt_num := 30;
         x_pacp_used := 1;
         x_pacp_cost := l_pacp_pwac_cost;

         IF l_debug = 'Y' THEN
              fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ':'
                            || ' x_pacp_used: ' || x_pacp_used
                            || ', x_pacp_cost: ' || x_pacp_cost);
         END IF;

         l_stmt_num := 110;

         IF l_debug = 'Y' THEN
            fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ': return >>');
         END IF;

EXCEPTION

     when OTHERS then
       o_err_num := SQLCODE;
       o_err_msg := 'CSTPPINV.get_pacp_cost (' || to_char(l_stmt_num) ||
                      '): ' || substr(SQLERRM,1,200);
       fnd_file.put_line(fnd_file.log, o_err_msg);

END get_pacp_cost;

/*---------------------------------------------------------------------------
|  Procedure get_prev_period_cost()
|
|  This is a helper routine for get_interorg_cost.
|  It inserts the prior period cost from CPIC into MPTCD
|  plus any transfer and transportation charges as appropriate.
|
|  Returns x_prev_period_id = -1, if no costs were inserted into MPTCD.
---------------------------------------------------------------------------*/
PROCEDURE get_prev_period_cost(
            i_legal_entity       IN       NUMBER,
            i_cost_source_cost_group     IN     NUMBER,
            i_pac_period_id      IN       NUMBER,
            i_cost_type_id       IN       NUMBER,
            i_cost_group_id      IN       NUMBER,
            i_txn_id             IN       NUMBER,
            i_item_id            IN       NUMBER,
            i_conv_rate          IN       NUMBER,
            i_user_id            IN       NUMBER,
            i_login_id           IN       NUMBER,
            i_request_id         IN       NUMBER,
            i_prog_id            IN       NUMBER,
            i_prog_appl_id       IN       NUMBER,
            x_prev_period_id     OUT NOCOPY      NUMBER,
            x_prev_period_cost   OUT NOCOPY      NUMBER,
            o_err_num            OUT NOCOPY      NUMBER,
            o_err_code           OUT NOCOPY      VARCHAR2,
            o_err_msg            OUT NOCOPY      VARCHAR2
)
    IS
      l_stmt_num          NUMBER := 0;
      l_err_num           NUMBER;
      l_err_code          VARCHAR2(240);
      l_err_msg           VARCHAR2(240);

      l_prev_period_id            NUMBER;
      l_prev_period_pwac_cost     NUMBER;
      l_prev_period_pwac_cnt      NUMBER := 0;


      l_api_name   CONSTANT VARCHAR2(30)   	:= 'CSTPPINV.get_prev_period_cost';


    BEGIN

      IF l_debug = 'Y' THEN
         fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ': begin <<'
                            || ' transaction_id: ' || i_txn_id);
      END IF;

      -- initialize local variables
      l_err_num := 0;
      l_err_code := '';
      l_err_msg := '';

      l_stmt_num := 10;

      /* Get prior period id */
      SELECT nvl(max(cpp.pac_period_id), -1)
      INTO   l_prev_period_id
      FROM   cst_pac_periods cpp
      WHERE  cpp.cost_type_id = i_cost_type_id
      AND    cpp.legal_entity = i_legal_entity
      AND    cpp.pac_period_id < i_pac_period_id;

      l_stmt_num := 20;
   /* In addition to checking whether a prior period exists,
      also need to check whether the item itself has a cost
      in the prior period.  It may not have a prior period cost
      if, for example, it was created after the close of the
      prior period. */
      SELECT count(*)
      INTO   l_prev_period_pwac_cnt
      FROM   cst_pac_item_costs cpic
      WHERE  CPIC.INVENTORY_ITEM_ID = i_item_id
      AND CPIC.COST_GROUP_ID     = i_cost_source_cost_group
      AND CPIC.PAC_PERIOD_ID     = l_prev_period_id;

      l_stmt_num := 30;

      IF (l_prev_period_id <> -1 AND l_prev_period_pwac_cnt > 0) THEN

          /* Prior period exists */

          l_stmt_num := 40;

          INSERT INTO MTL_PAC_TXN_COST_DETAILS (
                    transaction_id,
                    pac_period_id,
                    cost_type_id,
                    cost_group_id,
                    cost_element_id,
                    level_type,
                    inventory_item_id,
                    transaction_cost,
                    last_update_date,
                    last_updated_by,
                    creation_date,
                    created_by,
                    request_id,
                    program_application_id,
                    program_id,
                    program_update_date,
                    last_update_login)
           SELECT
                    I_TXN_ID,
                    I_PAC_PERIOD_ID,
                    I_COST_TYPE_ID,
                    I_COST_GROUP_ID,
                    CPICD.cost_element_id,
                    CPICD.level_type,
                    i_item_id,
                    (CPICD.item_cost * i_conv_rate),
                    sysdate,
                    i_user_id,
                    sysdate,
                    i_user_id,
                    i_request_id,
                    i_prog_appl_id,
                    i_prog_id,
                    sysdate,
                    i_login_id
           FROM  CST_PAC_ITEM_COSTS CPIC,
                 CST_PAC_ITEM_COST_DETAILS CPICD
           WHERE CPICD.COST_LAYER_ID    = CPIC.COST_LAYER_ID
           AND   CPIC.INVENTORY_ITEM_ID = i_item_id
           AND   CPIC.COST_GROUP_ID     = i_cost_source_cost_group
           AND   CPIC.PAC_PERIOD_ID     = l_prev_period_id;

           l_stmt_num := 50;

           /* Get prior period PWAC Cost */
           SELECT nvl(CPIC.item_cost,0)
           INTO  l_prev_period_pwac_cost
           FROM  CST_PAC_ITEM_COSTS CPIC
           WHERE CPIC.INVENTORY_ITEM_ID = i_item_id
           AND CPIC.COST_GROUP_ID     = i_cost_source_cost_group
           AND CPIC.PAC_PERIOD_ID     = l_prev_period_id;

           l_stmt_num := 60;

            x_prev_period_id := l_prev_period_id;
            x_prev_period_cost := l_prev_period_pwac_cost;

      ELSE  /* There is no prior period cost */

            l_stmt_num := 100;
            x_prev_period_id := -1;
            x_prev_period_cost := NULL;

      END IF;  /* (l_prev_period_id <> -1) */

      l_stmt_num := 200;

      IF l_debug = 'Y' THEN
         fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ': return >>');
      END IF;

    EXCEPTION

     when OTHERS then
       o_err_num := SQLCODE;
       o_err_msg := 'CSTPPINV.get_prev_period_cost (' || to_char(l_stmt_num) ||
                      '): ' || substr(SQLERRM,1,200);
       fnd_file.put_line(fnd_file.log, o_err_msg);

END get_prev_period_cost;

/*---------------------------------------------------------------------------
|  Procedure get_perp_ship_cost()
|
|  This is a helper routine for get_interorg_cost.
|  Given the shipment transaction id, this procedure inserts the perpetual
|  shipment cost from MTA into MPTCD,
|  plus any transfer and transportation charges as appropriate.
|
---------------------------------------------------------------------------*/
PROCEDURE get_perp_ship_cost(
            i_pac_period_id      IN       NUMBER,
            i_cost_type_id       IN       NUMBER,
            i_cost_group_id      IN       NUMBER,
            i_txn_id             IN       NUMBER,
            i_mta_txn_id         IN       NUMBER,
            i_item_id            IN       NUMBER,
            i_from_org           IN       NUMBER,
            i_conv_rate          IN       NUMBER,
            i_user_id            IN       NUMBER,
            i_login_id           IN       NUMBER,
            i_request_id         IN       NUMBER,
            i_prog_id            IN       NUMBER,
            i_prog_appl_id       IN       NUMBER,
            x_perp_ship_cost     OUT NOCOPY      NUMBER,
            o_err_num            OUT NOCOPY      NUMBER,
            o_err_code           OUT NOCOPY      VARCHAR2,
            o_err_msg            OUT NOCOPY      VARCHAR2
)
    IS
            l_stmt_num          NUMBER := 0;
            l_err_num           NUMBER;
            l_err_code          VARCHAR2(240);
            l_err_msg           VARCHAR2(240);

            l_perp_ship_cost            NUMBER;
            l_mta_txn_qty               NUMBER;

            l_api_name   CONSTANT VARCHAR2(30)   	:= 'CSTPPINV.get_perp_ship_cost';

    BEGIN

            IF l_debug = 'Y' THEN
               fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ': begin <<'
                            || ' transaction_id: ' || i_txn_id
                            || ' i_mta_txn_id: ' || i_mta_txn_id);
            END IF;

            -- initialize local variables
            l_err_num := 0;
            l_err_code := '';
            l_err_msg := '';

            l_stmt_num := 10;

            SELECT primary_quantity
            INTO   l_mta_txn_qty
            FROM   mtl_material_transactions
            WHERE  transaction_id = i_mta_txn_id;

           IF l_debug = 'Y' THEN
             fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ': l_mta_txn_qty = ' || l_mta_txn_qty);
           END IF;

           /* Select the perpetual accounted value for the sending org's credit
              to On-hand (either Inventory or Expense accounting line type). */
           BEGIN
            SELECT nvl(SUM(ABS(NVL(base_transaction_value, 0)))/abs(l_mta_txn_qty),0)
            INTO l_perp_ship_cost
            FROM mtl_transaction_accounts mta
            WHERE mta.transaction_id = i_mta_txn_id
            and mta.organization_id = i_from_org
            and mta.accounting_line_type IN (1,2)
            and mta.base_transaction_value < 0;
           EXCEPTION
           WHEN no_data_found THEN
            l_perp_ship_cost := 0;
           END;

           IF l_debug = 'Y' THEN
             fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ': l_perp_ship_cost = ' || l_perp_ship_cost);
           END IF;

           IF l_perp_ship_cost <> 0 THEN
             /* Insert all cost elements */
             INSERT INTO mtl_pac_txn_cost_details (
                          transaction_id,
                          pac_period_id,
                          cost_type_id,
                          cost_group_id,
                          cost_element_id,
                          level_type,
                          inventory_item_id,
                          transaction_cost,
                          last_update_date,
                          last_updated_by,
                          creation_date,
                          created_by,
                          request_id,
                          program_application_id,
                          program_id,
                          program_update_date,
                          last_update_login)
             SELECT
                          i_txn_id,
                          i_pac_period_id,
                          i_cost_type_id,
                          i_cost_group_id,
                          NVL(mta.cost_element_id, 1),
                          1,
                          i_item_id,
                          i_conv_rate*abs(mta.base_transaction_value/abs(l_mta_txn_qty)),
                          SYSDATE,
                          i_user_id,
                          SYSDATE,
                          i_user_id,
                          i_request_id,
                          i_prog_appl_id,
                          i_prog_id,
                          SYSDATE,
                          i_login_id
             FROM
                          mtl_transaction_accounts mta
             WHERE
                          mta.transaction_id = i_mta_txn_id
                          and mta.organization_id = i_from_org
                          and mta.accounting_line_type IN (1,2)
                          and mta.base_transaction_value < 0;

           ELSE
             /* Insert 0 Material Cost into MPTCD only. */
                      CSTPPINV.insert_elemental_cost(
                         i_pac_period_id      => i_pac_period_id,
                         i_cost_type_id       => i_cost_type_id,
                         i_cost_group_id      => i_cost_group_id,
                         i_txn_id             => i_txn_id,
                         i_item_id            => i_item_id,
                         i_cost_element_id    => 1,
                         i_level_type         => 1,
                         i_cost               => 0,
                         i_user_id            => i_user_id,
                         i_login_id           => i_login_id,
                         i_request_id         => i_request_id,
                         i_prog_id            => i_prog_id,
                         i_prog_appl_id       => i_prog_appl_id,
                         o_err_num            => l_err_num,
                         o_err_code           => l_err_code,
                         o_err_msg            => l_err_msg
                      );
           END IF;

            l_stmt_num := 30;
            x_perp_ship_cost := l_perp_ship_cost;

            IF l_debug = 'Y' THEN
               fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ': return >>');
            END IF;

    EXCEPTION

     when OTHERS then
       o_err_num := SQLCODE;
       o_err_msg := 'CSTPPINV.get_perp_ship_cost (' || to_char(l_stmt_num) ||
                      '): ' || substr(SQLERRM,1,200);
       fnd_file.put_line(fnd_file.log, o_err_msg);

END get_perp_ship_cost;



/*---------------------------------------------------------------------------
|  Procedure get_snd_rcv_rate()
|
|  Returns the currency conversion rate from i_from_org to i_to_org for
|  the currency conversion type stamped on i_txn_id.
---------------------------------------------------------------------------*/
PROCEDURE get_snd_rcv_rate(
  i_txn_id      IN      NUMBER,
  i_from_org    IN      NUMBER,
  i_to_org      IN      NUMBER,
  o_conv_rate   OUT NOCOPY     NUMBER,
  o_err_num     OUT NOCOPY     NUMBER,
  o_err_code    OUT NOCOPY     VARCHAR2,
  o_err_msg     OUT NOCOPY     VARCHAR2
)
IS
  l_snd_sob_id  NUMBER;
  l_snd_curr    VARCHAR2(10);
  l_rcv_sob_id  NUMBER;
  l_rcv_curr    VARCHAR2(10);
  l_curr_type   VARCHAR2(30);
  l_conv_rate   NUMBER;
  l_conv_date   DATE;
  l_txn_date    DATE;
  l_err_num     NUMBER;
  l_err_code    VARCHAR2(240);
  l_err_msg     VARCHAR2(240);
  l_stmt_num    NUMBER;

BEGIN
  -- initialize local variables
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';

  l_stmt_num := 10;

  SELECT org_information1
  INTO l_snd_sob_id
  FROM hr_organization_information
  WHERE organization_id = i_from_org
  and   org_information_context = 'Accounting Information';

  l_stmt_num := 20;

  SELECT currency_code
  INTO l_snd_curr
  FROM gl_sets_of_books
  WHERE set_of_books_id = l_snd_sob_id;

  l_stmt_num := 30;

  SELECT org_information1
  INTO l_rcv_sob_id
  FROM hr_organization_information
  WHERE organization_id = i_to_org
  and   org_information_context = 'Accounting Information';

  l_stmt_num := 40;

  SELECT currency_code
  INTO l_rcv_curr
  FROM gl_sets_of_books
  WHERE set_of_books_id = l_rcv_sob_id;

  l_stmt_num := 50;

  SELECT currency_conversion_type, TRUNC(transaction_date)
  INTO l_curr_type, l_txn_date
  FROM mtl_material_transactions
  WHERE transaction_id = i_txn_id;

  if (l_curr_type is NULL) then
    FND_PROFILE.get('CURRENCY_CONVERSION_TYPE', l_curr_type);
  end if;

  if (l_rcv_curr <> l_snd_curr) then
    l_stmt_num := 60;
    l_conv_rate := gl_currency_api.get_rate(l_rcv_sob_id,l_snd_curr,l_txn_date,
                                           l_curr_type);
  else
    l_conv_rate := 1;
  end if;

  o_conv_rate := l_conv_rate;

  EXCEPTION

  when gl_currency_api.NO_RATE then
    O_err_num := 9999;
    O_err_code := 'CST_NO_GL_RATE';
    FND_MESSAGE.set_name('BOM', 'CST_NO_GL_RATE');
    O_err_msg := FND_MESSAGE.Get;

  when others then
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPPINV.get_snd_rcv_rate (' || to_char(l_stmt_num) ||
                   '): ' || substr(SQLERRM, 1,200);

END get_snd_rcv_rate;

PROCEDURE get_from_to_uom(
  i_item_id     IN      NUMBER,
  i_from_org    IN      NUMBER,
  i_to_org      IN      NUMBER,
  o_from_uom    OUT NOCOPY     VARCHAR2,
  o_to_uom      OUT NOCOPY     VARCHAR2,
  o_err_num     OUT NOCOPY     NUMBER,
  o_err_code    OUT NOCOPY     VARCHAR2,
  o_err_msg     OUT NOCOPY     VARCHAR2
)
IS
  l_stmt_num            NUMBER;

BEGIN
  l_stmt_num := 10;

  SELECT primary_uom_code
  INTO o_from_uom
  FROM mtl_system_items
  WHERE organization_id = i_from_org
    AND inventory_item_id = i_item_id;

  l_stmt_num := 20;

  SELECT primary_uom_code
  INTO o_to_uom
  FROM mtl_system_items
  WHERE organization_id = i_to_org
    AND inventory_item_id = i_item_id;

  EXCEPTION
  when others then
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPPINV.get_from_to_uom (' || to_char(l_stmt_num) ||
                   '): ' || substr(SQLERRM, 1,200);

END get_from_to_uom;

/*--------------------------------------------------------------------------
|
| Cases :
| - Non inter-org or inter-org within cost group transactions having control
|   at master will have conversion of 1.
| - Non inter-org transactions.
|   Conversion is done from transaction org to the master org of
|   that cost group.
|-----------------------------------------------------------------------------*/
PROCEDURE get_um_rate(
  i_txn_org_id         IN       NUMBER,
  i_master_org_id      IN       NUMBER,
  i_txn_cost_group_id  IN       NUMBER,
  i_txfr_cost_group_id IN       NUMBER,
  i_txn_action_id      IN       NUMBER,
  i_item_id            IN       NUMBER,
  i_uom_control        IN       NUMBER,
  i_user_id            IN       NUMBER,
  i_login_id           IN       NUMBER,
  i_request_id         IN       NUMBER,
  i_prog_id            IN       NUMBER,
  i_prog_appl_id       IN       NUMBER,
  o_um_rate            OUT NOCOPY      NUMBER,
  o_err_num            OUT NOCOPY      NUMBER,
  o_err_code           OUT NOCOPY      VARCHAR2,
  o_err_msg            OUT NOCOPY      VARCHAR2
)
IS
  l_txn_org_uom         VARCHAR2(3);
  l_master_org_uom      VARCHAR2(3);
  l_err_num             NUMBER;
  l_err_code            VARCHAR2(240);
  l_err_msg             VARCHAR2(240);
  process_error         EXCEPTION;
  conversion_error      EXCEPTION;
BEGIN

  IF ( (i_uom_control = 1) AND ((i_txn_action_id NOT IN (3,12,21)) OR
  (i_txn_cost_group_id = i_txfr_cost_group_id)) ) THEN
--    dbms_output.put_line('No Conversion');
    o_um_rate := 1;
    return;
  END IF;

  get_from_to_uom (i_item_id, i_txn_org_id, i_master_org_id,
                   l_txn_org_uom,l_master_org_uom,l_err_num, l_err_code, l_err_msg);
  IF (l_err_num <> 0) THEN
    raise process_error;
  END IF;

--  dbms_output.put_line('convert from '||i_txn_org_id||'_'||l_txn_org_uom||' to '
--                                      ||i_master_org_id||'_'||l_master_org_uom);
  o_um_rate := inv_convert.inv_um_convert (i_item_id, NULL, 1,
               l_txn_org_uom, l_master_org_uom, NULL, NULL);
  IF (o_um_rate < 0) THEN
    raise conversion_error;
  END IF;


  EXCEPTION

  when process_error then
    o_err_num := l_err_num;
    o_err_code := l_err_code;
    o_err_msg := l_err_msg;

  when conversion_error then
    o_err_num := 9999;
    o_err_code := 'INV_NO_CONVERSIONS';
    FND_MESSAGE.set_name('INV', 'INV_NO_CONVERSIONS');
    o_err_msg := FND_MESSAGE.Get;

END get_um_rate;

/*--------------------------------------------------------------------------
|  Drop Ship Global Procurement transactions
|  Consigned price update transaction
|
|  This procedure is used to cost process the logical transactions.
|
|  19-Jul-03  Anju   Creation
|-----------------------------------------------------------------------------*/
PROCEDURE cost_acct_events(
  i_pac_period_id           IN  NUMBER,
  i_legal_entity            IN  NUMBER,
  i_cost_type_id            IN  NUMBER,
  i_cost_group_id           IN  NUMBER,
  i_cost_method             IN  NUMBER,
  i_txn_id                  IN  NUMBER,
  i_item_id                 IN  NUMBER,
  i_txn_qty                 IN  NUMBER,
  i_txn_org_id              IN  NUMBER,
  i_master_org_id           IN  NUMBER,
  i_uom_control             IN  NUMBER,
  i_user_id                 IN  NUMBER,
  i_login_id                IN  NUMBER,
  i_request_id              IN  NUMBER,
  i_prog_id                 IN  NUMBER,
  i_prog_appl_id            IN  NUMBER,
  o_err_num                 OUT NOCOPY NUMBER,
  o_err_code                OUT NOCOPY VARCHAR2,
  o_err_msg                 OUT NOCOPY VARCHAR2
) IS

  l_err_num                 NUMBER;
  l_err_code                VARCHAR2(240);
  l_err_msg                 VARCHAR2(240);
  l_parent_transaction_id   NUMBER := -1;
  l_logical_transaction     NUMBER := 3;
  l_parent_organization_id  NUMBER := -1;
  l_um_rate                 NUMBER := 1;
  l_txn_src_type_id         MTL_MATERIAL_TRANSACTIONS.TRANSACTION_SOURCE_TYPE_ID%TYPE;
  l_txn_action_id           MTL_MATERIAL_TRANSACTIONS.TRANSACTION_ACTION_ID%TYPE;
  l_cost_layer_id           CST_PAC_ITEM_COSTS.COST_LAYER_ID%TYPE;
  l_quantity_layer_id       CST_PAC_QUANTITY_LAYERS.COST_LAYER_ID%TYPE;
  l_converted_txn_qty       NUMBER;
  l_stmt_num                NUMBER;
  l_return_status           VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);

  PROCESS_ERROR     EXCEPTION;
begin
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';

  l_stmt_num := 10;
  fnd_file.put_line(fnd_file.log,'In Cost_Acct_Events: Txn ID:' ||
                                 to_char(i_txn_id));

  /* Determine parent transaction id and parent_transaction organization id */

  select nvl(parent_transaction_id, -1),
         transaction_source_type_id,
         transaction_action_id
  into   l_parent_transaction_id,
         l_txn_src_type_id,
         l_txn_action_id
  from   mtl_material_transactions
  where  transaction_id = i_txn_id;

  if (l_parent_transaction_id <> -1 ) then

  select organization_id,
         nvl(logical_transaction, 3)
  into   l_parent_organization_id,
         l_logical_transaction
  from mtl_material_transactions
  where transaction_id = l_parent_transaction_id;

  end if;

 /*If the parent is a physical transaction, use parent's details in mptcd, mpacd
   for cost processing this logical transaction
   Else use mctcd to cost process the logical transaction */

  if (l_parent_organization_id = i_txn_org_id and
      l_logical_transaction = 2 ) then

      l_stmt_num := 20;

      /* update mmt.periodic_quantity */
      /* Bug 6751847 fix: to prevent execution twice from both
         shipping and receiving cost groups,to avoid lock when run in
         parallel for multiple CGs  */

       UPDATE mtl_material_transactions
       SET periodic_primary_quantity = (select mmt2.periodic_primary_quantity
                                          from mtl_material_transactions mmt2
                                         where mmt2.transaction_id =
                                                      l_parent_transaction_id)
       WHERE transaction_id = i_txn_id
       AND organization_id = i_txn_org_id
       AND EXISTS (SELECT 'x'
                    FROM cst_cost_group_assignments ccga
                   WHERE ccga.cost_group_id   = i_cost_group_id
                     AND ccga.organization_id = i_txn_org_id);


       l_stmt_num := 30;

    /* insert into mpacd */
  l_stmt_num := 40;

  INSERT INTO mtl_pac_actual_cost_details (
        transaction_id,
        pac_period_id,
        cost_type_id,
        cost_group_id,
        cost_layer_id,
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
        actual_cost,
        prior_cost,
        prior_buy_cost,
        prior_make_cost,
        new_cost,
        new_buy_cost,
        new_make_cost,
        insertion_flag,
        user_entered,
        transaction_costed_date)
  SELECT i_txn_id,
        i_pac_period_id,
        i_cost_type_id,
        i_cost_group_id,
        cost_layer_id,
        cost_element_id,
        level_type,
        sysdate,
        i_user_id,
        sysdate,
        i_user_id,
        i_login_id,
        i_request_id,
        i_prog_appl_id,
        i_prog_id,
        sysdate,
        inventory_item_id,
        actual_cost,
        prior_cost,
        prior_buy_cost,
        prior_make_cost,
        new_cost,
        new_buy_cost,
        new_make_cost,
        insertion_flag,
        user_entered,
        sysdate
  FROM mtl_pac_actual_cost_details
  WHERE transaction_id = l_parent_transaction_id
  AND   pac_period_id  = i_pac_period_id
  AND   cost_group_id  = i_cost_group_id;

  /* Delete the MPACD row of the parent */

  Delete from mtl_pac_actual_cost_details
  where transaction_id = l_parent_transaction_id
  AND   pac_period_id  = i_pac_period_id
  AND   cost_group_id  = i_cost_group_id;

  else
    l_stmt_num := 50;

    /* Update mmt with quantity in the master org um */
    /* BUG 6751847 fix: to prevent execution twice
       for both shipping and receiving cost group, to avoid
       lock when run in parallel for CGs */
    UPDATE mtl_material_transactions
       SET periodic_primary_quantity = i_txn_qty
     WHERE transaction_id = i_txn_id
       AND organization_id = i_txn_org_id
       AND EXISTS (SELECT 'x'
                   FROM cst_cost_group_assignments ccga
                  WHERE ccga.cost_group_id = i_cost_group_id
                    AND ccga.organization_id = i_txn_org_id);


    l_stmt_num := 60;

    INSERT INTO mtl_pac_txn_cost_details (
      transaction_id,
      pac_period_id,
      cost_type_id,
      cost_group_id,
      cost_element_id,
      level_type,
      inventory_item_id,
      transaction_cost,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      last_update_login)
    SELECT
      transaction_id,
      i_pac_period_id,
      i_cost_type_id,
      i_cost_group_id,
      cost_element_id,
      level_type,
      inventory_item_id,
      transaction_cost/l_um_rate,
      SYSDATE,
      i_user_id,
      SYSDATE,
      i_user_id,
      i_request_id,
      i_prog_appl_id,
      i_prog_id,
      SYSDATE,
      i_login_id
    FROM
      mtl_cst_txn_cost_details mctcd
    WHERE
      mctcd.transaction_id = i_txn_id;

    /* For logical transactions, values from mptcd can be directly copied into
       mpacd */

    l_stmt_num := 70;

    INSERT INTO mtl_pac_actual_cost_details (
        transaction_id,
        pac_period_id,
        cost_type_id,
        cost_group_id,
        cost_layer_id,
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
        actual_cost,
        insertion_flag,
        user_entered,
        transaction_costed_date)
    SELECT i_txn_id,
        i_pac_period_id,
        cost_type_id,
        i_cost_group_id,
        -1,
        cost_element_id,
        level_type,
        sysdate,
        i_user_id,
        sysdate,
        i_user_id,
        i_login_id,
        i_request_id,
        i_prog_appl_id,
        i_prog_id,
        sysdate,
        inventory_item_id,
        transaction_cost,
        'Y',
        'N',
        sysdate
    FROM mtl_pac_txn_cost_details
    WHERE transaction_id = i_txn_id
    AND   pac_period_id  = i_pac_period_id
    AND   cost_group_id  = i_cost_group_id;

    IF (l_txn_src_type_id = 2 AND l_txn_action_id = 7) THEN  -- Revenue / COGS Matching

      l_stmt_num := 80;
      -- check the existence of layer
      CSTPPCLM.layer_id(i_pac_period_id, i_legal_entity, i_item_id,
                        i_cost_group_id, l_cost_layer_id, l_quantity_layer_id,
                        l_err_num, l_err_code, l_err_msg);
      IF (l_err_num <> 0) THEN
        raise PROCESS_ERROR;
      END IF;

      l_stmt_num := 90;
      -- create a layer if not exist
      IF (l_cost_layer_id = 0) THEN
        CSTPPCLM.create_layer(i_pac_period_id, i_legal_entity, i_item_id,
                              i_cost_group_id, i_user_id, i_login_id, i_request_id,
                              i_prog_id, i_prog_appl_id,
                              l_cost_layer_id, l_quantity_layer_id,
                              l_err_num, l_err_code, l_err_msg);

        IF (l_err_num <> 0) THEN
          raise PROCESS_ERROR;
        END IF;
      END IF;

      l_stmt_num := 100;
      -- logical sales order issue from customer facing org
      CST_RevenueCogsMatch_PVT.Insert_PacSoIssue( p_api_version => 1.0,
                                                  x_return_status => l_return_status,
                                                  x_msg_count => l_msg_count,
                                                  x_msg_data => l_msg_data,
                                                  p_transaction_id => i_txn_id,
                                                  p_layer_id => l_cost_layer_id,
                                                  p_cost_type_id => i_cost_type_id,
                                                  p_cost_group_id => i_cost_group_id,
                                                  p_user_id => i_user_id,
                                                  p_login_id => i_login_id,
                                                  p_request_id => i_request_id,
                                                  p_pgm_app_id => i_prog_appl_id,
                                                  p_pgm_id => i_prog_id);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        l_err_num := -1;
        IF (l_msg_count = 1) THEN
          l_err_msg := substr(l_msg_data,1,240);
        ELSE
          l_err_msg := 'Failure in procedure CST_RevenueCogsMatch_PVT.Insert_PacSoIssue()';
        END IF;
        raise PROCESS_ERROR;
      END IF;
    END IF;
  end if;

EXCEPTION

  when PROCESS_ERROR then
    rollback;
    o_err_num := l_err_num;
    o_err_code := l_err_code;
    o_err_msg := 'CSTPPINV.COST_ACCT_EVENTS(' || l_stmt_num || ')' || l_err_msg;
  when OTHERS then
    rollback;
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPPINV.COST_ACCT_EVENTS: (' || to_char(l_stmt_num) || '): '
                || substr(SQLERRM,1,150);



End cost_acct_events;


/* Added procedure get_exp_flag BUG 6751847 performance fix */
PROCEDURE get_exp_flag(
  i_item_id			IN  NUMBER,
  i_txn_org_id			IN  NUMBER,
  i_subinventory_code		IN  VARCHAR2,
  o_exp_item			OUT NOCOPY	NUMBER,
  o_exp_flag			OUT NOCOPY	NUMBER,
  o_err_num			OUT NOCOPY      NUMBER,
  o_err_code			OUT NOCOPY     VARCHAR2,
  o_err_msg			OUT NOCOPY     VARCHAR2
  )
  IS
    l_stmt_num            NUMBER;
    l_asset_item          VARCHAR2(10);
  BEGIN
    l_stmt_num := 10;


    SELECT inventory_asset_flag
    INTO l_asset_item
    FROM mtl_system_items
    WHERE inventory_item_id = i_item_id AND organization_id =  i_txn_org_id;


    IF (l_asset_item = 'Y') THEN
       o_exp_item := 0;
       o_exp_flag := 0;   -- assignment

       SELECT decode(asset_inventory,1,0,1)
       INTO o_exp_flag
       FROM mtl_secondary_inventories
       WHERE secondary_inventory_name = i_subinventory_code
       AND organization_id =  i_txn_org_id;
    ELSE
       o_exp_item := 1;
       o_exp_flag := 1;
    END IF;

 EXCEPTION
  when others then
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPPINV.get_exp_flag (' || to_char(l_stmt_num) ||
                   '): ' || substr(SQLERRM, 1,200);

END get_exp_flag;

-- ===================================================================================================
-- Added procedure "cost_interorg_txn_grp1 " for  perf. BUG6751847 to  process Inter-Org transactions
-- across cost groups - cost owned transactions
-- ===================================================================================================
 PROCEDURE cost_interorg_txn_grp1 (
  i_pac_period_id           IN  NUMBER,
  i_legal_entity            IN  NUMBER,
  i_cost_type_id            IN  NUMBER,
  i_cost_group_id           IN  NUMBER,
  i_cost_method             IN  NUMBER,
  i_start_date              IN  VARCHAR2,
  i_end_date                IN  VARCHAR2,
  i_pac_rates_id	    IN  NUMBER,
  i_process_group           IN  NUMBER,
  i_master_org_id           IN  NUMBER,
  i_uom_control             IN  NUMBER,
  i_user_id                 IN  NUMBER,
  i_login_id                IN  NUMBER,
  i_request_id              IN  NUMBER,
  i_prog_id                 IN  NUMBER,
  i_prog_appl_id            IN  NUMBER,
  o_err_num                 OUT NOCOPY NUMBER,
  o_err_code                OUT NOCOPY VARCHAR2,
  o_err_msg                 OUT NOCOPY VARCHAR2
)
IS
  l_error_num               NUMBER;
  l_error_code              VARCHAR2(240);
  l_error_msg               VARCHAR2(240);
  l_count		    NUMBER;
  l_stmt_num		    NUMBER;
  l_exp_flag                NUMBER;
  l_exp_item                NUMBER;
  i_txn_id                  NUMBER;
  i_txn_action_id           NUMBER;
  i_txn_src_type_id         NUMBER;
  i_item_id                 NUMBER;
  i_txn_qty                 NUMBER;
  i_txn_org_id              NUMBER;
  i_txfr_org_id             NUMBER;
  i_subinventory_code       VARCHAR2(240);
  i_trf_price               NUMBER;

  PROCESS_ERROR	            EXCEPTION;
  EXP_FLAG_ERROR            EXCEPTION;
  CPPB_ERROR                EXCEPTION;

  l_start_date            date;
  l_end_date              date;
  l_rec_count            NUMBER;

  g_bulk_limit   NUMBER := 5000;

  TYPE num_type_tab  IS TABLE OF NUMBER;
  TYPE char_type_tab IS TABLE OF VARCHAR2(100);


  txn_id_tab       num_type_tab;
  txn_act_id_tab   num_type_tab;
  txn_src_type_tab num_type_tab;
  item_id_tab      num_type_tab;
  primary_qty_tab  num_type_tab;
  org_id_tab       num_type_tab;
  trf_org_id_tab   num_type_tab;
  sub_inv_code_tab char_type_tab;
  trf_price_tab    num_type_tab;

  -- Phase 5 Group 1 Interorg transactions across cost groups
  CURSOR inter_trx  is
  SELECT /*+ LEADING (mmt) */
       /* Modified for fob stamping project */
      mmt.transaction_id,
      mmt.transaction_action_id,
      mmt.transaction_source_type_id,
      mmt.inventory_item_id,
      mmt.primary_quantity,
      mmt.organization_id,
      nvl(mmt.transfer_organization_id,-1),
      mmt.subinventory_code,
      nvl(mmt.transfer_price,0) -- INVCONV
    FROM
      mtl_material_transactions mmt,
      mtl_parameters mp    --INVCONV sikhanna changes
    WHERE
      transaction_date between l_start_date AND l_end_date
      AND mmt.organization_id = nvl(mmt.owning_organization_id, mmt.organization_id)
      AND nvl(mmt.owning_tp_type,2) = 2
      AND mmt.organization_id = mp.organization_id
      AND nvl(mp.process_enabled_flag,'N') = 'N'  --INVCONV sikhanna
      AND NOT EXISTS ( SELECT 'X'
                       FROM  cst_cost_group_assignments c1, cst_cost_group_assignments c2
                       WHERE c1.organization_id = mmt.organization_id
                         AND c2.organization_id = mmt.transfer_organization_id
                         AND c1.cost_group_id = c2.cost_group_id)
      AND (
          (mmt.transaction_action_id = 3
           AND EXISTS ( SELECT 'X'
                        FROM  cst_cost_group_assignments ccga1
                        WHERE ccga1.cost_group_id = i_cost_group_id
                          AND ccga1.organization_id = mmt.organization_id
                          AND mmt.primary_quantity > 0))
        OR (mmt.transaction_action_id = 21
            AND EXISTS ( SELECT 'X'
                         FROM  mtl_interorg_parameters mip,
                               cst_cost_group_assignments ccga2
                         WHERE mip.from_organization_id = mmt.organization_id
                           AND mip.to_organization_id = mmt.transfer_organization_id
                           AND NVL(mmt.fob_point,mip.fob_point) = 1
                           AND ccga2.organization_id = mip.to_organization_id
                           AND ccga2.cost_group_id = i_cost_group_id))
        OR (mmt.transaction_action_id = 12
            AND EXISTS ( SELECT 'X'
                         FROM  mtl_interorg_parameters mip,
                               cst_cost_group_assignments ccga2
                         WHERE mip.from_organization_id = mmt.transfer_organization_id
                           AND mip.to_organization_id = mmt.organization_id
                           AND NVL(mmt.fob_point,mip.fob_point) = 2
                           AND ccga2.organization_id = mip.to_organization_id
                           AND ccga2.cost_group_id = i_cost_group_id))
        /* Logical Intransit Receipt  for receiving organization cost group */ -- INVCONV sikhanna
        OR (mmt.transaction_action_id = 15
           AND EXISTS ( SELECT 'X'
                        FROM  cst_cost_group_assignments ccga0
                        WHERE  ccga0.organization_id = mmt.organization_id
                          AND ccga0.cost_group_id = i_cost_group_id))
          )
      ORDER BY inventory_item_id;

 BEGIN
 -- initialize local variables
 l_error_num := 0;
 l_error_code := '';
 l_error_msg := '';
 l_start_date:=to_date(i_start_date, 'YYYY/MM/DD HH24:MI:SS') ;
 l_end_date  :=to_date(i_end_date, 'YYYY/MM/DD HH24:MI:SS') + 0.99999;

 l_count :=0;

 fnd_file.put_line(fnd_file.LOG, ' Start Processing group 1 - interorg txns across cost groups... '
                   || TO_CHAR(sysdate, 'DD-MON-RRRR HH24:MI:SS'));

 l_stmt_num := 10;

 OPEN inter_trx;

  LOOP

    FETCH inter_trx BULK COLLECT
     INTO
      txn_id_tab,
      txn_act_id_tab,
      txn_src_type_tab,
      item_id_tab,
      primary_qty_tab,
      org_id_tab,
      trf_org_id_tab,
      sub_inv_code_tab,
      trf_price_tab
      LIMIT g_bulk_limit;

      l_rec_count := item_id_tab.COUNT;

      IF l_rec_count > 0   then
        FOR i in 1.. l_rec_count LOOP
           i_txn_id            := txn_id_tab(i);
           i_txn_action_id     := txn_act_id_tab(i);
           i_txn_src_type_id   := txn_src_type_tab(i);
           i_item_id           := item_id_tab(i);
           i_txn_qty           := primary_qty_tab(i);
           i_txn_org_id        := org_id_tab(i);
           i_txfr_org_id       := trf_org_id_tab(i);
           i_subinventory_code := sub_inv_code_tab(i);
           i_trf_price         := trf_price_tab(i);

          fnd_file.put_line(fnd_file.log,'txn_id:'||i_txn_id);
          fnd_file.put_line(fnd_file.log,'txn_action_id:'||i_txn_action_id);
          fnd_file.put_line(fnd_file.log,'txn_source_type_id:'||i_txn_src_type_id);
          fnd_file.put_line(fnd_file.log,'item_id:'||i_item_id);

	  /* Any intransit shipments in this cursor are FOB shipment processed by receiving CG,
           so we should be passing in the txfr_txn_org_id to determine expense status.
           Since this step hits receiving org's intransit, it is assumed to be asset sub,
           so we pass in i_subinventory_code = -1  */
	  IF (i_txn_action_id = 21) THEN
	    get_exp_flag(i_item_id, i_txfr_org_id, i_subinventory_code, l_exp_item,
	                  l_exp_flag, l_error_num, l_error_code, l_error_msg);
	  ELSE
	    get_exp_flag(i_item_id, i_txn_org_id, i_subinventory_code, l_exp_item,
	                 l_exp_flag, l_error_num, l_error_code, l_error_msg);
	  END IF;

	  /*BUG 7415281*/

 	            l_error_num  := NVL(l_error_num, 0);
 	            l_error_code := NVL(l_error_code, 'No Error');
 	            l_error_msg  := NVL(l_error_msg, 'No Error');

          IF (l_error_num <> 0) THEN
	    raise EXP_FLAG_ERROR;
	  END IF;

          l_stmt_num := 20;

	  IF (CSTPPINV.l_item_id_tbl.COUNT >= 1000 AND i_cost_method <> 4) THEN
            CSTPPWAC.insert_into_cppb(i_pac_period_id  => i_pac_period_id,
                                      i_cost_group_id  => i_cost_group_id,
                                      i_txn_category   => 3,   /* Cost Owned Transactions */
                                      i_user_id        => i_user_id,
                                      i_login_id       => i_login_id,
                                      i_request_id     => i_request_id,
                                      i_prog_id        => i_prog_id,
                                      i_prog_appl_id   => i_prog_appl_id,
                                      o_err_num        => l_error_num,
                                      o_err_code       => l_error_code,
                                      o_err_msg        => l_error_msg);

		 l_error_num  := NVL(l_error_num, 0);
                 l_error_code := NVL(l_error_code, 'No Error');
                 l_error_msg  := NVL(l_error_msg, 'No Error');

               IF (l_error_num <> 0) THEN
	         raise CPPB_ERROR;
	       END IF;

          END IF;

	  l_stmt_num := 30;

          IF l_error_num = 0 THEN
	    CSTPPINV.cost_inv_txn(i_pac_period_id       => i_pac_period_id,
                                  i_legal_entity        => i_legal_entity,
                                  i_cost_type_id        => i_cost_type_id,
                                  i_cost_group_id       => i_cost_group_id,
                                  i_cost_method         => i_cost_method,
                                  i_txn_id              => i_txn_id,
                                  i_txn_action_id       => i_txn_action_id,
                                  i_txn_src_type_id     => i_txn_src_type_id,
                                  i_item_id             => i_item_id,
                                  i_txn_qty             => i_txn_qty,
                                  i_txn_org_id          => i_txn_org_id,
                                  i_txfr_org_id         => i_txfr_org_id,
                                  i_subinventory_code   => i_subinventory_code,
                                  i_exp_flag            => l_exp_flag,
                                  i_exp_item            => l_exp_item,
                                  i_pac_rates_id        => i_pac_rates_id,
                                  i_process_group       => i_process_group,
                                  i_master_org_id       => i_master_org_id,
                                  i_uom_control         => i_uom_control,
                                  i_user_id             => i_user_id,
                                  i_login_id            => i_login_id,
                                  i_request_id          => i_request_id,
                                  i_prog_id             => i_prog_id,
                                  i_prog_appl_id        => i_prog_appl_id,
                                  i_txn_category        => 3,  /* Cost Owned Transactions */
                                  i_transfer_price_pd   => i_trf_price,
                                  o_err_num             => l_error_num,
                                  o_err_code            => l_error_code,
                                  o_err_msg             => l_error_msg);

	        l_error_num  := NVL(l_error_num, 0);
                l_error_code := NVL(l_error_code, 'No Error');
                l_error_msg  := NVL(l_error_msg, 'No Error');

		  IF (l_error_num <> 0) THEN
		    raise PROCESS_ERROR;
		  END IF;
	  END IF;

        END LOOP;

	l_count := l_count + l_rec_count;

      END IF;
      EXIT WHEN inter_trx%NOTFOUND;
      END LOOP;
      CLOSE inter_trx;

      fnd_file.put_line(fnd_file.LOG, 'COMPLETE Processing group 1 - interorg txns across cost groups:'
                         ||l_count||'txns...'|| TO_CHAR(sysdate, 'DD-MON-RRRR HH24:MI:SS'));


      l_error_num := 0;

        IF (CSTPPINV.l_item_id_tbl.COUNT > 0 AND i_cost_method <> 4)  THEN
	  /* more records left out in the PL/SQL tables, Move them to permanent tables
	   and clear PL/SQL tables */
          CSTPPWAC.insert_into_cppb(i_pac_period_id     => i_pac_period_id
                                   ,i_cost_group_id     => i_cost_group_id
                                   ,i_txn_category      => 3  /* cost owned transactions */
                                   ,i_user_id           => i_user_id
                                   ,i_login_id          => i_login_id
                                   ,i_request_id        => i_request_id
                                   ,i_prog_id           => i_prog_id
                                   ,i_prog_appl_id      => i_prog_appl_id
                                   ,o_err_num           => l_error_num
                                   ,o_err_code          => l_error_code
                                   ,o_err_msg           => l_error_msg
                                   );

            l_error_num  := NVL(l_error_num, 0);
            l_error_code := NVL(l_error_code, 'No Error');
            l_error_msg  := NVL(l_error_msg, 'No Error');

	    IF (l_error_num <> 0) THEN
	      raise CPPB_ERROR;
	    END IF;

	 END IF;

	IF (l_error_num = 0 AND i_cost_method <> 4 and l_count > 0) THEN
          /* l_count > 0 implies that there has been atleast one cost owned
           transaction processed upto this point in inter_trx cursor */

           CSTPPWAC.update_cppb(i_pac_period_id  => i_pac_period_id,
                                i_cost_group_id  => i_cost_group_id,
                                i_txn_category   => 3, /* Cost Owned Transactions */
                                i_low_level_code => -2,
                                i_user_id        => i_user_id,
                                i_login_id       => i_login_id,
                                i_request_id     => i_request_id,
                                i_prog_id        => i_prog_id,
                                i_prog_appl_id   => i_prog_appl_id,
                                o_err_num        => l_error_num,
                                o_err_code       => l_error_code,
                                o_err_msg        => l_error_msg);

               l_error_num := nvl(l_error_num, 0);
               l_error_msg := nvl(l_error_msg, 'No Error');
               l_error_code := nvl(l_error_code, 'No Error');

	       IF l_error_num <> 0 THEN
	         raise CPPB_ERROR;
	       END IF;

	 END IF;


EXCEPTION
  WHEN PROCESS_ERROR THEN
    o_err_num := l_error_num;
    o_err_code := l_error_code;
    o_err_msg := 'CSTPPINV.COST_INV_TXN:' || l_error_msg;
    fnd_file.put_line(fnd_file.log,'Errored out txns in CSTPPINV inter_trx');
    fnd_file.put_line(fnd_file.log,'txn_id'||i_txn_id);

  WHEN CPPB_ERROR THEN
    o_err_num := l_error_num;
    o_err_code := l_error_code;
    o_err_msg := 'CSTPPINV:' || l_error_msg;
    fnd_file.put_line(fnd_file.log,'Errored out txns in CSTPPINV while insert or update CPPB');

  WHEN EXP_FLAG_ERROR THEN
    o_err_num := l_error_num;
    o_err_code := l_error_code;
    o_err_msg := 'CSTPPINV.get_exp_flag:' || l_error_msg;
    fnd_file.put_line(fnd_file.log,'Errored out txns in CSTPPINV.get_exp_flag');
    fnd_file.put_line(fnd_file.log,'item id:'||i_item_id || ' txn action id:' || i_txn_action_id
                   || ' organization id:' || i_txn_org_id || ' transfer org id:' || i_txfr_org_id);

  WHEN OTHERS THEN
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPPINV (' || to_char(l_stmt_num) || '): '
    || substr(SQLERRM,1,150);
    fnd_file.put_line(fnd_file.log,'Errored out txns in CSTPPINV.cost_interorg_txn_grp1');
    fnd_file.put_line(fnd_file.log,'txn_id'||i_txn_id);

END cost_interorg_txn_grp1;

-- ===================================================================================================
-- Added procedure "cost_interorg_txn_grp2 " for  perf. BUG6751847 to  process Inter-Org transactions
-- across cost groups - cost derived transactions */
-- ===================================================================================================
PROCEDURE cost_interorg_txn_grp2 (
  i_pac_period_id           IN  NUMBER,
  i_legal_entity            IN  NUMBER,
  i_cost_type_id            IN  NUMBER,
  i_cost_group_id           IN  NUMBER,
  i_cost_method             IN  NUMBER,
  i_start_date              IN  VARCHAR2,
  i_end_date                IN  VARCHAR2,
  i_pac_rates_id	    IN  NUMBER,
  i_process_group           IN  NUMBER,
  i_master_org_id           IN  NUMBER,
  i_uom_control             IN  NUMBER,
  i_user_id                 IN  NUMBER,
  i_login_id                IN  NUMBER,
  i_request_id              IN  NUMBER,
  i_prog_id                 IN  NUMBER,
  i_prog_appl_id            IN  NUMBER,
  o_err_num                 OUT NOCOPY NUMBER,
  o_err_code                OUT NOCOPY VARCHAR2,
  o_err_msg                 OUT NOCOPY VARCHAR2
)
IS
  l_error_num               NUMBER;
  l_error_code              VARCHAR2(240);
  l_error_msg               VARCHAR2(240);
  l_count		    NUMBER;
  l_stmt_num		    NUMBER;
  l_exp_flag                NUMBER;
  l_exp_item                NUMBER;
  i_txn_id                  NUMBER;
  i_txn_action_id           NUMBER;
  i_txn_src_type_id         NUMBER;
  i_item_id                 NUMBER;
  i_txn_qty                 NUMBER;
  i_txn_org_id              NUMBER;
  i_txfr_org_id             NUMBER;
  i_subinventory_code       VARCHAR2(240);
  i_trf_price               NUMBER;

  PROCESS_ERROR	            EXCEPTION;
  EXP_FLAG_ERROR            EXCEPTION;
  CPPB_ERROR                EXCEPTION;

  l_start_date            date;
  l_end_date              date;
  l_rec_count            NUMBER;

  g_bulk_limit   NUMBER := 5000;

  TYPE num_type_tab  IS TABLE OF NUMBER;
  TYPE char_type_tab IS TABLE OF VARCHAR2(100);


  txn_id_tab       num_type_tab;
  txn_act_id_tab   num_type_tab;
  txn_src_type_tab num_type_tab;
  item_id_tab      num_type_tab;
  primary_qty_tab  num_type_tab;
  org_id_tab       num_type_tab;
  trf_org_id_tab   num_type_tab;
  sub_inv_code_tab char_type_tab;
  trf_price_tab    num_type_tab;


-- ====================================================================
-- Phase 5 Group 2 - no completion , InterOrg txns across CG
-- ====================================================================
CURSOR group2_interorg_trx  is
  SELECT /*+ LEADING (mmt) */
    mmt.transaction_id,
    mmt.transaction_action_id,
    mmt.transaction_source_type_id,
    mmt.inventory_item_id,
    mmt.primary_quantity,
    mmt.organization_id,
    nvl(mmt.transfer_organization_id,-1),
    mmt.subinventory_code,
    nvl(mmt.transfer_price,0) -- INVCONV
    FROM
      mtl_material_transactions mmt,
      mtl_parameters mp -- INCONV sikhanna
    WHERE
      transaction_date between l_start_date AND l_end_date
      AND mmt.organization_id = nvl(mmt.owning_organization_id, mmt.organization_id)
      AND nvl(mmt.owning_tp_type,2) = 2
      AND mmt.organization_id = mp.organization_id
      AND nvl(mp.process_enabled_flag,'N') = 'N'
      AND ((transaction_action_id in (3,12,21)
         AND EXISTS (SELECT 'EXISTS'
                       FROM cst_cost_group_assignments ccga
                      WHERE  ccga.cost_group_id = i_cost_group_id
                        AND (ccga.organization_id = mmt.organization_id OR
                             ccga.organization_id = mmt.transfer_organization_id)))
          /* Logical Intransit Shipment  for shipping organization cost group */ -- INVCONV sikhanna
          OR (mmt.transaction_action_id = 22
              AND EXISTS ( SELECT 'X'
                           FROM  cst_cost_group_assignments ccga0
                           WHERE  ccga0.organization_id = mmt.organization_id
                            AND ccga0.cost_group_id = i_cost_group_id)))
      AND (transaction_action_id IN (3,12,21,22)
        AND NOT EXISTS (
          SELECT 'X'
          FROM cst_cost_group_assignments c1, cst_cost_group_assignments c2
          WHERE c1.organization_id = mmt.organization_id
            AND c2.organization_id = mmt.transfer_organization_id
            AND c1.cost_group_id = c2.cost_group_id)
        AND (
          (mmt.transaction_action_id = 3
            AND EXISTS (
              SELECT 'X'
              FROM cst_cost_group_assignments ccga1
              WHERE ccga1.cost_group_id = i_cost_group_id
                AND ccga1.organization_id = mmt.organization_id
                AND mmt.primary_quantity < 0))
          OR (mmt.transaction_action_id = 21
            AND EXISTS (
              SELECT 'X'
              FROM cst_cost_group_assignments ccga2
              WHERE ccga2.organization_id = mmt.organization_id
                AND ccga2.cost_group_id = i_cost_group_id))
          OR (mmt.transaction_action_id = 12
            AND EXISTS (
              SELECT 'X'
              FROM mtl_interorg_parameters mip
              WHERE mip.from_organization_id = mmt.transfer_organization_id
                AND mip.to_organization_id = mmt.organization_id
                AND (
                  (NVL(mmt.fob_point,mip.fob_point) = 1 AND EXISTS (
                    SELECT 'X'
                    FROM cst_cost_group_assignments ccga2
                    WHERE ccga2.organization_id = mip.to_organization_id
                      AND ccga2.cost_group_id = i_cost_group_id ))
                  Or (NVL(mmt.fob_point,mip.fob_point) = 2 AND EXISTS (
                    SELECT 'X'
                    FROM cst_cost_group_assignments ccga3
                    WHERE ccga3.organization_id = mip.from_organization_id
                      AND ccga3.cost_group_id = i_cost_group_id )))))
          /* Logical Intransit Shipment  for shipping organization cost group */
          OR (mmt.transaction_action_id = 22
              AND EXISTS ( SELECT 'X'
                           FROM  cst_cost_group_assignments ccga0
                           WHERE  ccga0.organization_id = mmt.organization_id
                            AND ccga0.cost_group_id = i_cost_group_id))
        ))
    AND NOT EXISTS (
      SELECT 'X'
      FROM cst_pac_low_level_codes cpllc
      WHERE cpllc.inventory_item_id = mmt.inventory_item_id
        AND cpllc.pac_period_id = i_pac_period_id
        AND cpllc.cost_group_id = i_cost_group_id)
    ORDER BY inventory_item_id;

 BEGIN
 -- initialize local variables
 l_error_num := 0;
 l_error_code := '';
 l_error_msg := '';
 l_start_date:=to_date(i_start_date, 'YYYY/MM/DD HH24:MI:SS') ;
 l_end_date  :=to_date(i_end_date, 'YYYY/MM/DD HH24:MI:SS') + 0.99999;

 l_count :=0;

 fnd_file.put_line(fnd_file.LOG, ' Start Processing group 2 - interorg txns across cost groups... '
                   || TO_CHAR(sysdate, 'DD-MON-RRRR HH24:MI:SS'));

 l_stmt_num := 10;

 OPEN group2_interorg_trx;

  LOOP

    FETCH group2_interorg_trx BULK COLLECT
     INTO
      txn_id_tab,
      txn_act_id_tab,
      txn_src_type_tab,
      item_id_tab,
      primary_qty_tab,
      org_id_tab,
      trf_org_id_tab,
      sub_inv_code_tab,
      trf_price_tab
      LIMIT g_bulk_limit;

    l_rec_count := item_id_tab.COUNT;

      IF l_rec_count > 0   then
        FOR i in 1.. l_rec_count LOOP
           i_txn_id            := txn_id_tab(i);
           i_txn_action_id     := txn_act_id_tab(i);
           i_txn_src_type_id   := txn_src_type_tab(i);
           i_item_id           := item_id_tab(i);
           i_txn_qty           := primary_qty_tab(i);
           i_txn_org_id        := org_id_tab(i);
           i_txfr_org_id       := trf_org_id_tab(i);
           i_subinventory_code := sub_inv_code_tab(i);
           i_trf_price         := trf_price_tab(i);

          fnd_file.put_line(fnd_file.log,'txn_id:'||i_txn_id);
          fnd_file.put_line(fnd_file.log,'txn_action_id:'||i_txn_action_id);
          fnd_file.put_line(fnd_file.log,'txn_source_type_id:'||i_txn_src_type_id);
          fnd_file.put_line(fnd_file.log,'item_id:'||i_item_id);

	  get_exp_flag(i_item_id, i_txn_org_id, i_subinventory_code, l_exp_item,
	               l_exp_flag, l_error_num, l_error_code, l_error_msg);

          /*BUG7415281*/

 	            l_error_num  := NVL(l_error_num, 0);
 	            l_error_code := NVL(l_error_code, 'No Error');
 	            l_error_msg  := NVL(l_error_msg, 'No Error');

          IF (l_error_num <> 0) THEN
	    raise EXP_FLAG_ERROR;
	  END IF;

          l_stmt_num := 20;

	  IF (CSTPPINV.l_item_id_tbl.COUNT >= 1000 AND i_cost_method <> 4) THEN
            CSTPPWAC.insert_into_cppb(i_pac_period_id  => i_pac_period_id,
                                      i_cost_group_id  => i_cost_group_id,
                                      i_txn_category   => 9,   /* Cost Derived Transactions */
                                      i_user_id        => i_user_id,
                                      i_login_id       => i_login_id,
                                      i_request_id     => i_request_id,
                                      i_prog_id        => i_prog_id,
                                      i_prog_appl_id   => i_prog_appl_id,
                                      o_err_num        => l_error_num,
                                      o_err_code       => l_error_code,
                                      o_err_msg        => l_error_msg);

		 l_error_num  := NVL(l_error_num, 0);
                 l_error_code := NVL(l_error_code, 'No Error');
                 l_error_msg  := NVL(l_error_msg, 'No Error');

               IF (l_error_num <> 0) THEN
	         raise CPPB_ERROR;
	       END IF;

          END IF;

	  l_stmt_num := 30;

          IF l_error_num = 0 THEN
	    CSTPPINV.cost_inv_txn(i_pac_period_id       => i_pac_period_id,
                                  i_legal_entity        => i_legal_entity,
                                  i_cost_type_id        => i_cost_type_id,
                                  i_cost_group_id       => i_cost_group_id,
                                  i_cost_method         => i_cost_method,
                                  i_txn_id              => i_txn_id,
                                  i_txn_action_id       => i_txn_action_id,
                                  i_txn_src_type_id     => i_txn_src_type_id,
                                  i_item_id             => i_item_id,
                                  i_txn_qty             => i_txn_qty,
                                  i_txn_org_id          => i_txn_org_id,
                                  i_txfr_org_id         => i_txfr_org_id,
                                  i_subinventory_code   => i_subinventory_code,
                                  i_exp_flag            => l_exp_flag,
                                  i_exp_item            => l_exp_item,
                                  i_pac_rates_id        => i_pac_rates_id,
                                  i_process_group       => i_process_group,
                                  i_master_org_id       => i_master_org_id,
                                  i_uom_control         => i_uom_control,
                                  i_user_id             => i_user_id,
                                  i_login_id            => i_login_id,
                                  i_request_id          => i_request_id,
                                  i_prog_id             => i_prog_id,
                                  i_prog_appl_id        => i_prog_appl_id,
                                  i_txn_category        => 9,  /* Cost Derived Transactions */
                                  i_transfer_price_pd   => i_trf_price,
                                  o_err_num             => l_error_num,
                                  o_err_code            => l_error_code,
                                  o_err_msg             => l_error_msg);

	        l_error_num  := NVL(l_error_num, 0);
                l_error_code := NVL(l_error_code, 'No Error');
                l_error_msg  := NVL(l_error_msg, 'No Error');

		  IF (l_error_num <> 0) THEN
		    raise PROCESS_ERROR;
		  END IF;
	  END IF;

        END LOOP;

	l_count := l_count + l_rec_count;

      END IF;
      EXIT WHEN group2_interorg_trx%NOTFOUND;
      END LOOP;
      CLOSE group2_interorg_trx;

      fnd_file.put_line(fnd_file.LOG, 'COMPLETE Processing group 2 - interorg txns across cost groups:'
                         ||l_count||'txns...'|| TO_CHAR(sysdate, 'DD-MON-RRRR HH24:MI:SS'));


      l_error_num := 0;

        IF (CSTPPINV.l_item_id_tbl.COUNT > 0 AND i_cost_method <> 4)  THEN
	  /* more records left out in the PL/SQL tables, Move them to permanent tables
	   and clear PL/SQL tables */
          CSTPPWAC.insert_into_cppb(i_pac_period_id     => i_pac_period_id
                                   ,i_cost_group_id     => i_cost_group_id
                                   ,i_txn_category      => 9  /* cost derived transactions */
                                   ,i_user_id           => i_user_id
                                   ,i_login_id          => i_login_id
                                   ,i_request_id        => i_request_id
                                   ,i_prog_id           => i_prog_id
                                   ,i_prog_appl_id      => i_prog_appl_id
                                   ,o_err_num           => l_error_num
                                   ,o_err_code          => l_error_code
                                   ,o_err_msg           => l_error_msg
                                   );

            l_error_num  := NVL(l_error_num, 0);
            l_error_code := NVL(l_error_code, 'No Error');
            l_error_msg  := NVL(l_error_msg, 'No Error');

	    IF (l_error_num <> 0) THEN
	      raise CPPB_ERROR;
	    END IF;

	 END IF;

	IF (l_error_num = 0 AND i_cost_method <> 4 and l_count > 0) THEN
          /* l_count > 0 implies that there has been atleast one cost derived
           transaction processed upto this point in group2_interorg_trx cursor */

           CSTPPWAC.update_cppb(i_pac_period_id  => i_pac_period_id,
                                i_cost_group_id  => i_cost_group_id,
                                i_txn_category   => 9, /* Cost Derived Transactions */
                                i_low_level_code => -1, /* No completions */
                                i_user_id        => i_user_id,
                                i_login_id       => i_login_id,
                                i_request_id     => i_request_id,
                                i_prog_id        => i_prog_id,
                                i_prog_appl_id   => i_prog_appl_id,
                                o_err_num        => l_error_num,
                                o_err_code       => l_error_code,
                                o_err_msg        => l_error_msg);

               l_error_num := nvl(l_error_num, 0);
               l_error_msg := nvl(l_error_msg, 'No Error');
               l_error_code := nvl(l_error_code, 'No Error');

	       IF l_error_num <> 0 THEN
	         raise CPPB_ERROR;
	       END IF;

	 END IF;


EXCEPTION
  WHEN PROCESS_ERROR THEN
    o_err_num := l_error_num;
    o_err_code := l_error_code;
    o_err_msg := 'CSTPPINV.COST_INV_TXN:' || l_error_msg;
    fnd_file.put_line(fnd_file.log,'Errored out txns in CSTPPINV group2_interorg_trx');
    fnd_file.put_line(fnd_file.log,'txn_id'||i_txn_id);

  WHEN CPPB_ERROR THEN
    o_err_num := l_error_num;
    o_err_code := l_error_code;
    o_err_msg := 'CSTPPINV:' || l_error_msg;
    fnd_file.put_line(fnd_file.log,'Errored out txns in CSTPPINV while insert or update CPPB');

  WHEN EXP_FLAG_ERROR THEN
    o_err_num := l_error_num;
    o_err_code := l_error_code;
    o_err_msg := 'CSTPPINV.get_exp_flag:' || l_error_msg;
    fnd_file.put_line(fnd_file.log,'Errored out txns in CSTPPINV.get_exp_flag');
    fnd_file.put_line(fnd_file.log,'item id:'||i_item_id || ' txn action id:' || i_txn_action_id
                   || ' organization id:' || i_txn_org_id || ' transfer org id:' || i_txfr_org_id);

  WHEN OTHERS THEN
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPPINV (' || to_char(l_stmt_num) || '): '
    || substr(SQLERRM,1,150);
    fnd_file.put_line(fnd_file.log,'Errored out txns in CSTPPINV.cost_interorg_txn_grp2');
    fnd_file.put_line(fnd_file.log,'txn_id'||i_txn_id);

END cost_interorg_txn_grp2;

-- ===================================================================================================
-- Added procedure "cost_txn_grp2 " for  perf. BUG6751847 to  process Inter-Org transactions within
-- same cost group and other non-interorg transactions - no completion - cost derived transactions
-- ===================================================================================================
PROCEDURE cost_txn_grp2 (
  i_pac_period_id           IN  NUMBER,
  i_legal_entity            IN  NUMBER,
  i_cost_type_id            IN  NUMBER,
  i_cost_group_id           IN  NUMBER,
  i_cost_method             IN  NUMBER,
  i_start_date              IN  VARCHAR2,
  i_end_date                IN  VARCHAR2,
  i_pac_rates_id	    IN  NUMBER,
  i_process_group           IN  NUMBER,
  i_master_org_id           IN  NUMBER,
  i_uom_control             IN  NUMBER,
  i_mat_relief_algo         IN  NUMBER,
  i_user_id                 IN  NUMBER,
  i_login_id                IN  NUMBER,
  i_request_id              IN  NUMBER,
  i_prog_id                 IN  NUMBER,
  i_prog_appl_id            IN  NUMBER,
  o_err_num                 OUT NOCOPY NUMBER,
  o_err_code                OUT NOCOPY VARCHAR2,
  o_err_msg                 OUT NOCOPY VARCHAR2
)
IS
 l_error_num               NUMBER;
  l_error_code              VARCHAR2(240);
  l_error_msg               VARCHAR2(240);
  l_count		    NUMBER;
  l_stmt_num		    NUMBER;
  l_exp_flag                NUMBER;
  l_exp_item                NUMBER;
  i_txn_id                  NUMBER;
  i_txn_action_id           NUMBER;
  i_txn_src_type_id         NUMBER;
  i_item_id                 NUMBER;
  i_txn_qty                 NUMBER;
  i_txn_org_id              NUMBER;
  i_txfr_org_id             NUMBER;
  i_subinventory_code       VARCHAR2(240);

  PROCESS_ERROR	            EXCEPTION;
  EXP_FLAG_ERROR            EXCEPTION;
  CPPB_ERROR                EXCEPTION;
  CHARGE_WIP_ERROR          EXCEPTION;

  l_start_date            date;
  l_end_date              date;
  l_rec_count             NUMBER;
  l_hook_used             NUMBER;

  g_bulk_limit   NUMBER := 5000;

  TYPE num_type_tab  IS TABLE OF NUMBER;
  TYPE char_type_tab IS TABLE OF VARCHAR2(100);


  txn_id_tab       num_type_tab;
  txn_act_id_tab   num_type_tab;
  txn_src_type_tab num_type_tab;
  item_id_tab      num_type_tab;
  primary_qty_tab  num_type_tab;
  org_id_tab       num_type_tab;
  trf_org_id_tab   num_type_tab;
  sub_inv_code_tab char_type_tab;

-- =========================================================================
-- Phase 5 processing - Group 2 txns of items having no completion
-- Interorg transactions within same cost group as cost derived transactions
-- Other non-interorg transactions as cost derived transactions
-- NOTE: Interorg transactions across cost groups as group 2 are processed
-- through a separate procedure.
-- ==========================================================================

/* gwu: Performance fix for BUG 1866168
   Split the cursor into two sections, one
   for interorg and one for non-interorg transactions
   NOTE: This code assumes that relevant MMT.transfer_organization_id
   is populated only for transaction_action_id 3,12,21 (interorg)

Bug 1987364 - Cursor group2_trx modified for inter-org txns to avoid
   duplicate rows getting returned for same txn id .
   Join between ccga and mmt replaced with EXISTS clause
Modified for fob stamping project
Modified for Drop Shipment projects */
CURSOR group2_trx  is
  SELECT /*+ LEADING (mmt) */
     mmt.transaction_id,
     mmt.transaction_action_id,
     mmt.transaction_source_type_id,
     mmt.inventory_item_id,
     mmt.primary_quantity,
     mmt.organization_id,
     nvl(mmt.transfer_organization_id,-1),
     mmt.subinventory_code
    FROM
      mtl_material_transactions mmt
    WHERE
      transaction_date between l_start_date AND l_end_date
      AND mmt.organization_id = nvl(mmt.owning_organization_id, mmt.organization_id)
      AND nvl(mmt.owning_tp_type,2) = 2
      and transaction_action_id in (3,12,21)
      AND EXISTS (SELECT 'EXISTS'
                    FROM cst_cost_group_assignments ccga
                   WHERE  ccga.cost_group_id = i_cost_group_id
                     AND (ccga.organization_id = mmt.organization_id OR
                          ccga.organization_id = mmt.transfer_organization_id))
      AND
        (
          (transaction_action_id IN (12,21)
            OR (transaction_action_id = 3 AND primary_quantity < 0))
          AND EXISTS (
            SELECT 'X'
            FROM cst_cost_group_assignments c1, cst_cost_group_assignments c2
            WHERE c1.organization_id = mmt.organization_id
              AND c2.organization_id = mmt.transfer_organization_id
              AND c1.cost_group_id = c2.cost_group_id))
      AND NOT EXISTS (
        SELECT 'X'
        FROM cst_pac_low_level_codes cpllc
        WHERE cpllc.inventory_item_id = mmt.inventory_item_id
          AND cpllc.pac_period_id = i_pac_period_id
          AND cpllc.cost_group_id = i_cost_group_id)
union all
    SELECT /*+ LEADING (mmt) */
      mmt.transaction_id,
      mmt.transaction_action_id,
      mmt.transaction_source_type_id,
      mmt.inventory_item_id,
      mmt.primary_quantity,
      mmt.organization_id,
      nvl(mmt.transfer_organization_id,-1),
      mmt.subinventory_code
    FROM
      mtl_material_transactions mmt,
      cst_cost_group_assignments ccga
    WHERE
      transaction_date between l_start_date AND l_end_date
      AND transaction_action_id in (4,8,28,33,34,1,2,5,27) /* Added VMI Planning Transfer */
      AND mmt.organization_id = nvl(mmt.owning_organization_id, mmt.organization_id)
      AND nvl(mmt.owning_tp_type,2) = 2
      AND ccga.cost_group_id = i_cost_group_id
      AND ccga.organization_id = mmt.organization_id
      AND nvl(mmt.logical_transactions_created, 1) <> 2
      AND nvl(mmt.logical_transaction, 3) <> 1
      AND (transaction_action_id IN (4,8,33,34)
           OR (transaction_action_id IN (2,5) AND primary_quantity < 0)
           OR ( transaction_action_id = 28 AND
               ((transaction_source_type_id = 8 AND primary_quantity < 0)
                OR
                 transaction_source_type_id <> 8))
           OR (transaction_action_id in (1, 27)
               AND transaction_source_type_id IN (3,6,13)
               AND transaction_cost IS NULL)
           OR (transaction_action_id in (1,27)
               AND transaction_source_type_id NOT IN (1,3,6,13)) )
      AND NOT EXISTS (
        SELECT 'X'
        FROM cst_pac_low_level_codes cpllc
        WHERE cpllc.inventory_item_id = mmt.inventory_item_id
          AND cpllc.pac_period_id = i_pac_period_id
          AND cpllc.cost_group_id = i_cost_group_id)
      ORDER BY 4;  /* order by inventory item id */

BEGIN
 -- initialize local variables
 l_error_num := 0;
 l_error_code := '';
 l_error_msg := '';
 l_start_date:=to_date(i_start_date, 'YYYY/MM/DD HH24:MI:SS') ;
 l_end_date  :=to_date(i_end_date, 'YYYY/MM/DD HH24:MI:SS') + 0.99999;

 l_count :=0;

 fnd_file.put_line(fnd_file.LOG, ' Start Processing group 2 - interorg txns within same cost group and non-interorg txns ... '
                   || TO_CHAR(sysdate, 'DD-MON-RRRR HH24:MI:SS'));

 l_stmt_num := 10;

 OPEN group2_trx;

  LOOP

    FETCH group2_trx BULK COLLECT
     INTO
      txn_id_tab,
      txn_act_id_tab,
      txn_src_type_tab,
      item_id_tab,
      primary_qty_tab,
      org_id_tab,
      trf_org_id_tab,
      sub_inv_code_tab
      LIMIT g_bulk_limit;


    l_rec_count := item_id_tab.COUNT;

      IF l_rec_count > 0   then
        FOR i in 1.. l_rec_count LOOP
           i_txn_id            := txn_id_tab(i);
           i_txn_action_id     := txn_act_id_tab(i);
           i_txn_src_type_id   := txn_src_type_tab(i);
           i_item_id           := item_id_tab(i);
           i_txn_qty           := primary_qty_tab(i);
           i_txn_org_id        := org_id_tab(i);
           i_txfr_org_id       := trf_org_id_tab(i);
           i_subinventory_code := sub_inv_code_tab(i);

          fnd_file.put_line(fnd_file.log,'txn_id:'||i_txn_id);
          fnd_file.put_line(fnd_file.log,'txn_action_id:'||i_txn_action_id);
          fnd_file.put_line(fnd_file.log,'txn_source_type_id:'||i_txn_src_type_id);
          fnd_file.put_line(fnd_file.log,'item_id:'||i_item_id);

	  l_stmt_num := 20;
	  get_exp_flag(i_item_id, i_txn_org_id, i_subinventory_code, l_exp_item,
	               l_exp_flag, l_error_num, l_error_code, l_error_msg);

          /*BUG 7415281*/

 	            l_error_num  := NVL(l_error_num, 0);
 	            l_error_code := NVL(l_error_code, 'No Error');
 	            l_error_msg  := NVL(l_error_msg, 'No Error');

          IF (l_error_num <> 0) THEN
	    raise EXP_FLAG_ERROR;
	  END IF;

	  /* Bug 1855971: Exclude the txn_action_id of 2 */
          IF ((i_txn_src_type_id = 5) AND (i_txn_action_id <> 2)) THEN

              l_stmt_num := 30;

	      IF (CSTPPINV.l_item_id_tbl.COUNT >= 1000 AND i_cost_method <> 4) THEN
                l_stmt_num := 40;
		CSTPPWAC.insert_into_cppb(i_pac_period_id  => i_pac_period_id,
			                  i_cost_group_id  => i_cost_group_id,
				          i_txn_category   => 9,   /* Cost Derived Transactions */
                                          i_user_id        => i_user_id,
                                          i_login_id       => i_login_id,
                                          i_request_id     => i_request_id,
                                          i_prog_id        => i_prog_id,
                                          i_prog_appl_id   => i_prog_appl_id,
                                          o_err_num        => l_error_num,
                                          o_err_code       => l_error_code,
                                          o_err_msg        => l_error_msg);

		   l_error_num  := NVL(l_error_num, 0);
                   l_error_code := NVL(l_error_code, 'No Error');
                   l_error_msg  := NVL(l_error_msg, 'No Error');

                 IF (l_error_num <> 0) THEN
	           raise CPPB_ERROR;
	         END IF;

              END IF;

	       IF l_error_num = 0 THEN
	         l_stmt_num := 50;
	         CSTPPWMT.charge_wip_material( p_pac_period_id             =>  i_pac_period_id,
                                               p_cost_group_id             =>  i_cost_group_id,
                                               p_txn_id                    =>  i_txn_id,
                                               p_exp_item                  =>  l_exp_item,
                                               p_exp_flag                  =>  l_exp_flag,
                                               p_legal_entity              =>  i_legal_entity,
                                               p_cost_type_id              =>  i_cost_type_id,
                                               p_cost_method               =>  i_cost_method,
                                               p_pac_rates_id              =>  i_pac_rates_id,
                                               p_master_org_id             =>  i_master_org_id,
                                               p_material_relief_algorithm =>  i_mat_relief_algo,
                                               p_uom_control               =>  i_uom_control,
                                               p_user_id                   =>  i_user_id,
                                               p_login_id                  =>  i_login_id,
                                               p_request_id                =>  i_request_id,
                                               p_prog_id                   =>  i_prog_id,
                                               p_prog_app_id               =>  i_prog_appl_id,
                                               p_txn_category              =>  9,  /* Cost Derived Transactions */
                                               x_cost_method_hook          =>  l_hook_used,
                                               x_err_num                   =>  l_error_num,
                                               x_err_code                  =>  l_error_code,
                                               x_err_msg                   =>  l_error_msg );

			l_error_num := nvl(l_error_num, 0);
			l_error_msg := nvl(l_error_msg, 'No Error');
			l_error_code := nvl(l_error_code, 'No Error');
			l_hook_used := nvl(l_hook_used, -1);

			IF l_error_num <> 0 THEN
			  raise CHARGE_WIP_ERROR;
			END IF;
               END IF;


               /* Custom hook used */
               IF l_hook_used <> -1 THEN
	         fnd_file.put_line(fnd_file.log,'Hook is used');
	       END IF;

          ELSE
            /* other than wip source */
	    IF (CSTPPINV.l_item_id_tbl.COUNT >= 1000 AND i_cost_method <> 4) THEN
	        l_stmt_num := 60;
              CSTPPWAC.insert_into_cppb(i_pac_period_id  => i_pac_period_id,
                                        i_cost_group_id  => i_cost_group_id,
                                        i_txn_category   => 9,   /* Cost Derived Transactions */
                                        i_user_id        => i_user_id,
                                        i_login_id       => i_login_id,
                                        i_request_id     => i_request_id,
                                        i_prog_id        => i_prog_id,
                                        i_prog_appl_id   => i_prog_appl_id,
                                        o_err_num        => l_error_num,
                                        o_err_code       => l_error_code,
                                        o_err_msg        => l_error_msg);

		   l_error_num  := NVL(l_error_num, 0);
                   l_error_code := NVL(l_error_code, 'No Error');
                   l_error_msg  := NVL(l_error_msg, 'No Error');

                 IF (l_error_num <> 0) THEN
	           raise CPPB_ERROR;
	         END IF;

            END IF;

	    IF l_error_num = 0 THEN
	      l_stmt_num := 60;
	      CSTPPINV.cost_inv_txn(i_pac_period_id       => i_pac_period_id,
                                    i_legal_entity        => i_legal_entity,
                                    i_cost_type_id        => i_cost_type_id,
                                    i_cost_group_id       => i_cost_group_id,
                                    i_cost_method         => i_cost_method,
                                    i_txn_id              => i_txn_id,
                                    i_txn_action_id       => i_txn_action_id,
                                    i_txn_src_type_id     => i_txn_src_type_id,
                                    i_item_id             => i_item_id,
                                    i_txn_qty             => i_txn_qty,
                                    i_txn_org_id          => i_txn_org_id,
                                    i_txfr_org_id         => i_txfr_org_id,
                                    i_subinventory_code   => i_subinventory_code,
                                    i_exp_flag            => l_exp_flag,
                                    i_exp_item            => l_exp_item,
                                    i_pac_rates_id        => i_pac_rates_id,
                                    i_process_group       => i_process_group,
                                    i_master_org_id       => i_master_org_id,
                                    i_uom_control         => i_uom_control,
                                    i_user_id             => i_user_id,
                                    i_login_id            => i_login_id,
                                    i_request_id          => i_request_id,
                                    i_prog_id             => i_prog_id,
                                    i_prog_appl_id        => i_prog_appl_id,
                                    i_txn_category        => 9,  /* Cost Derived Transactions */
                                    i_transfer_price_pd   => 0,
                                    o_err_num             => l_error_num,
                                    o_err_code            => l_error_code,
                                    o_err_msg             => l_error_msg);

	          l_error_num  := NVL(l_error_num, 0);
                  l_error_code := NVL(l_error_code, 'No Error');
                  l_error_msg  := NVL(l_error_msg, 'No Error');

		    IF (l_error_num <> 0) THEN
		      raise PROCESS_ERROR;
		    END IF;
	    END IF;

          END IF; -- txn src type check

        END LOOP;

	l_count := l_count + l_rec_count;

      END IF;
      EXIT WHEN group2_trx%NOTFOUND;
      END LOOP;
      CLOSE group2_trx;

      fnd_file.put_line(fnd_file.LOG, 'COMPLETE Processing group 2 - interorg txns within same cost group and non-interorg txns:'
                         ||l_count||'txns...'|| TO_CHAR(sysdate, 'DD-MON-RRRR HH24:MI:SS'));


      l_error_num := 0;

        IF (CSTPPINV.l_item_id_tbl.COUNT > 0 AND i_cost_method <> 4)  THEN
	  /* more records left out in the PL/SQL tables, Move them to permanent tables
	   and clear PL/SQL tables */
          l_stmt_num := 70;
          CSTPPWAC.insert_into_cppb(i_pac_period_id     => i_pac_period_id
                                   ,i_cost_group_id     => i_cost_group_id
                                   ,i_txn_category      => 9  /* cost derived transactions */
                                   ,i_user_id           => i_user_id
                                   ,i_login_id          => i_login_id
                                   ,i_request_id        => i_request_id
                                   ,i_prog_id           => i_prog_id
                                   ,i_prog_appl_id      => i_prog_appl_id
                                   ,o_err_num           => l_error_num
                                   ,o_err_code          => l_error_code
                                   ,o_err_msg           => l_error_msg
                                   );

            l_error_num  := NVL(l_error_num, 0);
            l_error_code := NVL(l_error_code, 'No Error');
            l_error_msg  := NVL(l_error_msg, 'No Error');

	    IF (l_error_num <> 0) THEN
	      raise CPPB_ERROR;
	    END IF;

	 END IF;

	IF (l_error_num = 0 AND i_cost_method <> 4 and l_count > 0) THEN
          /* l_count > 0 implies that there has been atleast one cost derived
           transaction processed upto this point in group2_trx cursor */
	   l_stmt_num := 80;
           CSTPPWAC.update_cppb(i_pac_period_id  => i_pac_period_id,
                                i_cost_group_id  => i_cost_group_id,
                                i_txn_category   => 9, /* Cost Derived Transactions */
                                i_low_level_code => -1, /* No completions */
                                i_user_id        => i_user_id,
                                i_login_id       => i_login_id,
                                i_request_id     => i_request_id,
                                i_prog_id        => i_prog_id,
                                i_prog_appl_id   => i_prog_appl_id,
                                o_err_num        => l_error_num,
                                o_err_code       => l_error_code,
                                o_err_msg        => l_error_msg);

               l_error_num := nvl(l_error_num, 0);
               l_error_msg := nvl(l_error_msg, 'No Error');
               l_error_code := nvl(l_error_code, 'No Error');

	       IF l_error_num <> 0 THEN
	         raise CPPB_ERROR;
	       END IF;

	 END IF;


EXCEPTION
  WHEN PROCESS_ERROR THEN
    o_err_num := l_error_num;
    o_err_code := l_error_code;
    o_err_msg := 'CSTPPINV.COST_INV_TXN:' || l_error_msg;
    fnd_file.put_line(fnd_file.log,'Errored out txns in CSTPPINV group2_trx');
    fnd_file.put_line(fnd_file.log,'txn_id'||i_txn_id);

  WHEN CPPB_ERROR THEN
    o_err_num := l_error_num;
    o_err_code := l_error_code;
    o_err_msg := 'CSTPPINV:' || l_error_msg;
    fnd_file.put_line(fnd_file.log,'Errored out txns in CSTPPINV group2_trx while insert or update CPPB');

  WHEN EXP_FLAG_ERROR THEN
    o_err_num := l_error_num;
    o_err_code := l_error_code;
    o_err_msg := 'CSTPPINV.get_exp_flag:' || l_error_msg;
    fnd_file.put_line(fnd_file.log,'Errored out txns in CSTPPINV.get_exp_flag');
    fnd_file.put_line(fnd_file.log,'item id:'||i_item_id || ' txn action id:' || i_txn_action_id
                   || ' organization id:' || i_txn_org_id || ' transfer org id:' || i_txfr_org_id);

  WHEN CHARGE_WIP_ERROR THEN
    o_err_num := l_error_num;
    o_err_code := l_error_code;
    o_err_msg := 'CSTPPINV.charge_wip_material:' || l_error_msg;
    fnd_file.put_line(fnd_file.log,'Errored out txns in CSTPPINV.charge_wip_material');
    fnd_file.put_line(fnd_file.log,'item id:'||i_item_id || ' txn action id:' || i_txn_action_id
                   || ' organization id:' || i_txn_org_id || ' Material Relief Algorithm:' || i_mat_relief_algo);
    fnd_file.put_line(fnd_file.log,' Expense Item:' || l_exp_item || ' Expense Flag:' || l_exp_flag);

  WHEN OTHERS THEN
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPPINV (' || to_char(l_stmt_num) || '): '
    || substr(SQLERRM,1,150);
    fnd_file.put_line(fnd_file.log,'Errored out txns in CSTPPINV.cost_txn_grp2');
    fnd_file.put_line(fnd_file.log,'txn_id'||i_txn_id);

END cost_txn_grp2;


end CSTPPINV;

/
