--------------------------------------------------------
--  DDL for Package Body CST_TPRICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_TPRICE_PVT" AS
/* $Header: CSTVTPAB.pls 120.5.12010000.2 2010/02/26 08:16:25 lchevala ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'CST_TPRICE_PVT';
G_DEBUG    CONSTANT VARCHAR(1) := NVL(FND_PROFILE.value('MRP_DEBUG'), 'N');

procedure Adjust_Acct(
  P_API_VERSION         IN      NUMBER,
  P_INIT_MSG_LIST       IN      VARCHAR2,
  P_COMMIT              IN      VARCHAR2,
  P_VALIDATION_LEVEL    IN      NUMBER,
  P_TPRICE_OPTION       IN      NUMBER,
  P_TXF_PRICE           IN      NUMBER,
  P_TXN_ID              IN      NUMBER,
  P_COST_GRP_ID         IN      NUMBER,
  P_TXF_COST_GRP        IN      NUMBER,
  P_ITEM_ID             IN      NUMBER,
  P_TXN_DATE            IN      DATE,
  P_QTY                 IN      NUMBER,
  P_SUBINV              IN      VARCHAR2,
  P_TXF_SUBINV          IN      VARCHAR2,
  P_TXN_ORG_ID          IN      NUMBER,
  P_TXF_ORG_ID          IN      NUMBER,
  P_TXF_TXN_ID          IN      NUMBER,
  P_TXF_COST            IN      NUMBER,
  P_TXN_ACT_ID          IN      NUMBER,
  P_TXN_SRC_ID          IN      NUMBER,
  P_SRC_TYPE_ID         IN      NUMBER,
  P_FOB_POINT           IN      NUMBER,
  P_USER_ID             IN      NUMBER,
  P_LOGIN_ID            IN      NUMBER,
  P_REQ_ID              IN      NUMBER,
  P_PRG_APPL_ID         IN      NUMBER,
  P_PRG_ID              IN      NUMBER,
  X_RETURN_STATUS       OUT NOCOPY VARCHAR2,
  X_MSG_COUNT           OUT NOCOPY NUMBER,
  X_MSG_DATA            OUT NOCOPY VARCHAR2,
  X_ERROR_NUM           OUT NOCOPY NUMBER,
  X_ERROR_CODE          OUT NOCOPY VARCHAR2,
  X_ERROR_MESSAGE       OUT NOCOPY VARCHAR2
) IS
  l_api_name    CONSTANT VARCHAR2(30) := 'Adjust_Acct';
  l_api_version CONSTANT NUMBER       := 1.0;

  l_from_org    NUMBER;
  l_to_org      NUMBER;
  l_std_from_org NUMBER;
  l_std_to_org  NUMBER;
  l_from_ou     NUMBER;
  l_to_ou       NUMBER;
  l_from_cg     NUMBER;
  l_to_cg       NUMBER;
  l_from_layer  NUMBER;
  l_to_layer    NUMBER;
  l_from_subinv MTL_SECONDARY_INVENTORIES.SECONDARY_INVENTORY_NAME%TYPE;
  l_to_subinv   MTL_SECONDARY_INVENTORIES.SECONDARY_INVENTORY_NAME%TYPE;
  l_snd_uom     MTL_UNITS_OF_MEASURE.UOM_CODE%TYPE;
  l_rcv_uom     MTL_UNITS_OF_MEASURE.UOM_CODE%TYPE;
  l_snd_qty     NUMBER;
  l_rcv_qty     NUMBER;
  l_snd_sob_id  NUMBER;
  l_snd_curr    GL_SETS_OF_BOOKS.CURRENCY_CODE%TYPE;
  l_rcv_sob_id  NUMBER;
  l_rcv_coa_id  NUMBER;
  l_rcv_curr    GL_SETS_OF_BOOKS.CURRENCY_CODE%TYPE;
  l_curr_type   GL_DAILY_CONVERSION_TYPES.CONVERSION_TYPE%TYPE;
  l_conv_rate   NUMBER;
  l_conv_date   DATE;
  l_acct        NUMBER;
  l_om_ccid     NUMBER;
  l_inv_ccid    NUMBER;
  l_rcv_count   NUMBER;
  l_pay_count   NUMBER;
  l_rcv_sum     NUMBER;
  l_pay_sum     NUMBER;
  l_line_id     NUMBER;
  l_header_id   NUMBER;
  l_cust_id     NUMBER;
  l_order_type  NUMBER;
  l_ship_num    MTL_MATERIAL_TRANSACTIONS.SHIPMENT_NUMBER%TYPE;
  l_req_line    NUMBER;
  l_prf         NUMBER;
  l_cost_element NUMBER;
  l_elem_cost   NUMBER;
  l_err_num     NUMBER;
  l_err_code    MTL_MATERIAL_TRANSACTIONS.ERROR_CODE%TYPE;
  l_err_msg     MTL_MATERIAL_TRANSACTIONS.ERROR_EXPLANATION%TYPE;
  l_stmt_num    NUMBER;
  l_concat_id   VARCHAR2(2000);
  l_concat_seg  VARCHAR2(2000);
  l_concat_desc VARCHAR2(2000);
  l_msg_count   NUMBER;
  l_msg_data    VARCHAR2(2000);
  l_acct_done   NUMBER;
  l_txf_txn_id  NUMBER;
  l_from_exp_item  NUMBER;
  process_error EXCEPTION;
  prf_inv_acct_err EXCEPTION;
  inv_exp_acct_err EXCEPTION;

  l_pd_txfr_ind  NUMBER; -- OPM INVCONV process/discrete xfer indicator
  l_io_invoicing NUMBER := to_number(fnd_profile.value('INV_INTERCOMPANY_INVOICE_INTERNAL_ORDER'));

BEGIN

  -- Standard start of API savepoint
  SAVEPOINT Adjust_Acct_PVT;

  -- Standard call to check for call compatibility
  l_stmt_num := 10;
  if NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) then
     raise FND_API.g_exc_unexpected_error;
  end if;

  -- Initialize message list if p_init_msg_list is set to TRUE
  l_stmt_num := 20;
  if FND_API.to_Boolean(p_init_msg_list) then
     FND_MSG_PUB.initialize;
  end if;

  -- Initialize API return status and local variables
  l_stmt_num := 30;
  x_return_status := FND_API.g_ret_sts_success;
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';

  /* OPM INVCONV sschinch check if this is a process discrete transfer */
  SELECT MOD(SUM(DECODE(MP.process_enabled_flag,'Y',1,2)), 2)
    INTO l_pd_txfr_ind
    FROM mtl_parameters mp
   WHERE mp.organization_id = p_txn_org_id
      OR mp.organization_id = p_txf_org_id;


  if (G_DEBUG = 'Y') then
     FND_FILE.put_line(FND_FILE.LOG, 'In procedure CST_TPRICE_PVT.Adjust_Acct');
     FND_FILE.put_line(FND_FILE.LOG, 'p_tprice_option = ' || p_tprice_option);
     FND_FILE.put_line(FND_FILE.LOG, 'p_txf_price = ' || p_txf_price);
     FND_FILE.put_line(FND_FILE.LOG, 'l_pd_txfr_ind = ' || l_pd_txfr_ind);
     FND_FILE.put_line(FND_FILE.LOG, 'p_txn_act_id = ' || p_txn_act_id);
     FND_FILE.put_line(FND_FILE.LOG, 'Internal Order invoicing = ' || l_io_invoicing);
  end if;

  if (p_txn_act_id in (21, 22)) then
     l_from_org := p_txn_org_id;
     l_to_org := p_txf_org_id;
     l_from_cg := p_cost_grp_id;
     l_to_cg := p_txf_cost_grp;
     l_from_subinv := p_subinv;
     l_to_subinv := p_txf_subinv;
  elsif (p_txn_act_id in (12, 15)) then
     l_from_org := p_txf_org_id;
     l_to_org := p_txn_org_id;
     l_from_cg := p_txf_cost_grp;
     l_to_cg := p_cost_grp_id;
     l_from_subinv := p_txf_subinv;
     l_to_subinv := p_subinv;
  end if;

  l_stmt_num := 40;

  if (l_pd_txfr_ind = 0) OR
     (l_pd_txfr_ind = 1 AND (p_txn_act_id = 21 or p_txn_act_id = 22))
  then
      SELECT count(*), sum(base_transaction_value)
      INTO l_rcv_count, l_rcv_sum
      FROM mtl_transaction_accounts
      WHERE transaction_id = p_txn_id
      AND organization_id = l_from_org
      AND accounting_line_type = 10;
  end if;

  l_stmt_num := 50;

  if (l_pd_txfr_ind = 0) OR
     (l_pd_txfr_ind = 1 AND (p_txn_act_id = 15 or p_txn_act_id = 12))
  then
      SELECT count(*), sum(base_transaction_value)
      INTO l_pay_count, l_pay_sum
      FROM mtl_transaction_accounts
      WHERE transaction_id = p_txn_id
      AND organization_id = l_to_org
      AND accounting_line_type = 9;
  end if;

  if (G_DEBUG = 'Y') then
     FND_FILE.put_line(FND_FILE.LOG, 'l_rcv_sum = ' || l_rcv_sum);
     FND_FILE.put_line(FND_FILE.LOG, 'l_pay_sum = ' || l_pay_sum);
  end if;


  /* OPM INVCONV: process/discrete xfers
   * Moved the following stmt here from inside the IF block
   */
  l_stmt_num := 70;

  SELECT to_number(org_information3)
  INTO   l_from_ou
  FROM   hr_organization_information
  WHERE  org_information_context = 'Accounting Information'
  AND    organization_id = l_from_org;

  l_stmt_num := 75;
  SELECT to_number(org_information3)
  INTO   l_to_ou
  FROM   hr_organization_information
  WHERE  org_information_context = 'Accounting Information'
  AND    organization_id = l_to_org;


  if (G_DEBUG = 'Y') then
    FND_FILE.put_line(FND_FILE.LOG,
	'p_src_type_id/l_from_ou/l_to_ou/l_io_invoicing/p_txn_act_id/l_rcv_count: ' ||
	p_src_type_id ||'/'|| l_from_ou ||'/'|| l_to_ou ||'/'|| l_io_invoicing ||'/'||
	p_txn_act_id ||'/'|| l_rcv_count );
  end if;

  -- The adjustment should be done after the accounting for both sending and
  -- receiving orgs is done, i.e., the interorg receivable and payable exist
  if ((l_pd_txfr_ind = 0 and l_rcv_count >= 1 and l_pay_count >= 1 and p_tprice_option <> 0)
      OR
      ((l_pd_txfr_ind  =  1) and
       (p_src_type_id  in (7, 8)) and
       (l_from_ou      <> l_to_ou) and
       (l_io_invoicing =  1) and
       ((p_txn_act_id  in (21, 22) and l_rcv_count >= 1) OR
        (p_txn_act_id  in (12, 15) and l_pay_count >= 1)))
     )
  then

     l_stmt_num := 60;

     l_std_from_org := CSTPAVCP.standard_cost_org(l_from_org);
     l_std_to_org := CSTPAVCP.standard_cost_org(l_to_org);

     -- Get the currency information for sending and receiving orgs
     l_stmt_num := 80;

     CSTPAVCP.get_snd_rcv_rate(p_txn_id, l_from_org, l_to_org,
                l_snd_sob_id, l_snd_curr, l_rcv_sob_id, l_rcv_curr,
                l_curr_type, l_conv_rate, l_conv_date,
                l_err_num, l_err_code, l_err_msg);

     if (l_err_num<>0) then
        raise process_error;
     end if;

     if (l_conv_date is null) then
        l_conv_date := p_txn_date;
     end if;

     l_stmt_num := 90;

     SELECT chart_of_accounts_id
     INTO l_rcv_coa_id
     FROM gl_sets_of_books
     WHERE set_of_books_id = l_rcv_sob_id;

     if (G_DEBUG = 'Y') then
        FND_FILE.put_line(FND_FILE.LOG, 'l_snd_curr = ' || l_snd_curr);
        FND_FILE.put_line(FND_FILE.LOG, 'l_rcv_curr = ' || l_rcv_curr);
        FND_FILE.put_line(FND_FILE.LOG, 'l_conv_rate = ' || l_conv_rate);
        FND_FILE.put_line(FND_FILE.LOG, 'l_rcv_coa_id = ' || l_rcv_coa_id);
     end if;

     -- Get the primary unit of measure for sending and receiving orgs
     l_stmt_num := 100;

     CSTPAVCP.get_snd_rcv_uom(p_item_id, l_from_org, l_to_org, l_snd_uom, l_rcv_uom,
                  l_err_num, l_err_code, l_err_msg);

     -- Get the sending and receiving primary quantity
     l_stmt_num := 110;

     if (l_from_org = p_txn_org_id) then
        l_snd_qty := -1 * abs(p_qty); -- doing this since for action_id = 22, qty is +ve in MMT
        l_rcv_qty := inv_convert.inv_um_convert
                                (p_item_id, NULL, -1 * l_snd_qty,
                                 l_snd_uom, l_rcv_uom, NULL, NULL);
     else
        l_rcv_qty := p_qty;
        l_snd_qty := inv_convert.inv_um_convert
                                (p_item_id, NULL, -1 * l_rcv_qty,
                                 l_rcv_uom, l_snd_uom, NULL, NULL);
     end if;

     if (l_err_num <> 0) then
        raise process_error;
     end if;

     if (G_DEBUG = 'Y') then
        FND_FILE.put_line(FND_FILE.LOG, 'l_snd_uom = ' || l_snd_uom);
        FND_FILE.put_line(FND_FILE.LOG, 'l_rcv_uom = ' || l_rcv_uom);
        FND_FILE.put_line(FND_FILE.LOG, 'l_snd_qty = ' || l_snd_qty);
        FND_FILE.put_line(FND_FILE.LOG, 'l_rcv_qty = ' || l_rcv_qty);
     end if;

     -- Get the internal order information from the shipment transaction
     -- OPM INVCONV: added action id 15
     --
     if (p_txn_act_id in (15, 21)) then
        l_stmt_num := 120;

        SELECT MMT.trx_source_line_id, OEH.header_id, OEH.sold_to_org_id, OEH.order_type_id
        INTO l_line_id, l_header_id, l_cust_id, l_order_type
        FROM mtl_material_transactions MMT, oe_order_headers_all OEH, oe_order_lines_all OEL
        WHERE MMT.transaction_id = p_txn_id
        AND   OEL.line_id = MMT.trx_source_line_id
        AND   OEL.header_id = OEH.header_id;
     --
     -- OPM INVCONV: added action id 15
     --
     elsif (p_txn_act_id in (12, 22)) then
        l_stmt_num := 130;

        SELECT MMT.shipment_number, RT.requisition_line_id,
	       -- Following change has been made since for action id 22, transfer_transaction_id
	       -- points to receiving txn, not the shipping txn, because it got created after
	       -- goods are received.
	       decode(l_pd_txfr_ind, 1, 0, nvl(MMT.transfer_transaction_id, 0))
        INTO l_ship_num, l_req_line, l_txf_txn_id
        FROM mtl_material_transactions MMT, rcv_transactions RT
        WHERE MMT.transaction_id = p_txn_id
        AND   RT.transaction_id = MMT.rcv_transaction_id;

        /* Bug 3482782: for R11i.10, we can find the sending txn based on the txf_txn_id;
           for R11i.9, we add 'ROWNUM = 1' to handle the situation where one delivery for
           an internal sales order line has multiple deliver details for the same item. */
        if (l_txf_txn_id <> 0) then
           l_stmt_num := 135;

           SELECT MMT.trx_source_line_id, OEH.header_id, OEH.sold_to_org_id, OEH.order_type_id
           INTO l_line_id, l_header_id, l_cust_id, l_order_type
           FROM mtl_material_transactions MMT, oe_order_headers_all OEH, oe_order_lines_all OEL
           WHERE MMT.transaction_id = l_txf_txn_id
           AND   MMT.trx_source_line_id = OEL.line_id
           AND   OEL.header_id = OEH.header_id;
        else
           l_stmt_num := 140;

           SELECT MMT.trx_source_line_id, OEH.header_id, OEH.sold_to_org_id, OEH.order_type_id
           INTO l_line_id, l_header_id, l_cust_id, l_order_type
           FROM mtl_material_transactions MMT, oe_order_headers_all OEH, oe_order_lines_all OEL
           WHERE MMT.transaction_action_id = 21
           AND   MMT.transaction_source_type_id = 8
           AND   MMT.organization_id = l_from_org
           AND   MMT.inventory_item_id = p_item_id
           AND   MMT.shipment_number = l_ship_num
           AND   MMT.trx_source_line_id = OEL.line_id
           AND   OEL.source_document_line_id = l_req_line
           AND   OEL.header_id = OEH.header_id
           AND   ROWNUM = 1;
        end if;
     end if;

     if (G_DEBUG = 'Y') then
        FND_FILE.put_line(FND_FILE.LOG, 'l_line_id = ' || l_line_id);
        FND_FILE.put_line(FND_FILE.LOG, 'l_header_id = ' || l_header_id);
        FND_FILE.put_line(FND_FILE.LOG, 'l_cust_id = ' || l_cust_id);
        FND_FILE.put_line(FND_FILE.LOG, 'l_order_type = ' || l_order_type);
     end if;

     -- Get the COGS account for the sending org from OE workflow, if not succeeded,
     -- default it to the item COGS
     l_stmt_num := 150;

     /* Commenting out the set_org_context API and using an equivalent another as the former would
        be obsoleted with R12 as part of MOAC Uptake */

     /*  FND_CLIENT_INFO.set_org_context(l_from_ou); */

     /* OPM INVCONV: Process/Discrete xfer
      * Get COGS only for logical intransit shipment.
      */
     if (l_pd_txfr_ind = 0) or
        (l_pd_txfr_ind = 1 and p_txn_act_id in (21, 22))
     then
       mo_global.set_policy_context('S',l_from_ou);

       if (OE_FLEX_COGS_PUB.start_process(1.0, l_line_id, l_om_ccid, l_concat_seg, l_concat_id,
                            l_concat_desc, l_msg_count, l_msg_data) <> FND_API.g_ret_sts_success) then
          l_stmt_num := 160;

          SELECT nvl(MSI.cost_of_sales_account, MP.cost_of_sales_account)
          INTO l_om_ccid
          FROM mtl_system_items MSI, mtl_parameters MP
          WHERE MSI.organization_id = l_from_org
          AND   MSI.inventory_item_id = p_item_id
          AND   MP.organization_id = MSI.organization_id;
       end if;

       if (G_DEBUG = 'Y') then
          FND_FILE.put_line(FND_FILE.LOG, 'l_om_ccid = ' || l_om_ccid);
       end if;

     end if;

     /* OPM INVCONV: Process/Discrete xfer
      * Get IC Expense account only for logical intransit receipt.
      */
     if (l_pd_txfr_ind = 0) or
        (l_pd_txfr_ind = 1 and p_txn_act_id in (12, 15))
     then

       -- Get the intercompany expense account from INV workflow
       l_stmt_num := 170;

       if NOT
          INV_WORKFLOW.call_generate_cogs(l_rcv_coa_id, l_cust_id, p_item_id, l_header_id, l_line_id,
                       l_order_type, l_to_ou, l_inv_ccid, l_concat_seg, l_msg_data, l_to_org)
       then
          raise inv_exp_acct_err;
       end if;

       if (G_DEBUG = 'Y') then
          FND_FILE.put_line(FND_FILE.LOG, 'l_inv_ccid = ' || l_inv_ccid);
       end if;

     end if;

     /* PAC Enhancements for R12: Stamp the COGS and Intercompany accrual accounts in MMT */
     l_stmt_num := 175;

     UPDATE mtl_material_transactions
     SET distribution_account_id = l_om_ccid,
         expense_account_id = l_inv_ccid
     WHERE transaction_id = p_txn_id;


     -- First adjustment: delete interorg receivable and payable.  They are not needed as the
     -- intercompany receivable and payable will be generated from intercompany invoice processors
     if (G_DEBUG = 'Y') then
        FND_FILE.put_line(FND_FILE.LOG, 'Start first adjustment');
     end if;

     l_stmt_num := 180;

     /*
      * OPM INVCONV: Process/Discrete xfer
      * -- Delete InterOrg Profit Account (LineType 34) also.
      */

     DELETE FROM mtl_transaction_accounts
     WHERE transaction_id = p_txn_id
     AND accounting_line_type in (9,10,34);

     -- Second adjustment: debit elemental COGS for the sending org
     if (G_DEBUG = 'Y') then
        FND_FILE.put_line(FND_FILE.LOG, 'Start second adjustment');
     end if;

     l_stmt_num := 185;

     SELECT decode(inventory_asset_flag, 'Y', 0, 1)
     INTO l_from_exp_item
     FROM mtl_system_items_b
     WHERE organization_id = l_from_org
     AND inventory_item_id = p_item_id;

     /* Bug 3551024: For an expense item in the sending org, no COGS accounting */
     /* OPM INVCONV: Process/Discrete Xfer
      * COGS only for Logical Intransit Shipment Txn
      */
     if ((l_from_exp_item <> 1) and
         ((l_pd_txfr_ind = 0) or (l_pd_txfr_ind = 1 and p_txn_act_id in (21, 22)))
	)
     then

     l_acct_done := 0;

     FOR l_cost_element IN 1..5 loop
         l_elem_cost := NULL;

         -- If the sending org is standard costing, get costs from CIC, otherwise from MCACD
         if (l_std_from_org <> 0) then
            l_stmt_num := 190;

            /* Bug 3239084: use cst_item_cost_details from the costing org to support cost sharing */
            SELECT sum(item_cost)
            INTO l_elem_cost
            FROM cst_item_cost_details
            WHERE inventory_item_id = p_item_id
            AND   cost_element_id = l_cost_element
            AND   cost_type_id = 1
            AND   organization_id =
                  (select cost_organization_id
                   from mtl_parameters
                   where organization_id = l_from_org);
         else
            l_stmt_num := 200;

            SELECT layer_id
            INTO l_from_layer
            FROM cst_quantity_layers
            WHERE inventory_item_id = p_item_id
            AND organization_id = l_from_org
            AND cost_group_id = l_from_cg;

            l_stmt_num := 210;

            SELECT sum(actual_cost)
            INTO l_elem_cost
            FROM mtl_cst_actual_cost_details
            WHERE transaction_id = p_txn_id
            AND organization_id = l_from_org
            AND cost_element_id = l_cost_element
            AND layer_id = l_from_layer;
         end if;

         l_stmt_num := 220;

         if (l_elem_cost is not NULL) then
            l_acct_done := 1;

            if (l_std_from_org <> 0) then    -- To see if there is COGS account from Hook
               l_acct := CSTPSCHK.std_get_account_id(l_from_org, p_txn_id, -1*sign(l_snd_qty), 2,
                                  l_cost_element, null, l_from_subinv, l_from_cg,
                                  0, 1, l_err_num, l_err_code, l_err_msg);
            else
	       /*BUG 8881927 ADDED 'l_from_cg' */
               l_acct := CSTPACHK.get_account_id(l_from_org, p_txn_id, -1*sign(l_snd_qty), 2,
                                  l_cost_element, null, l_from_subinv,
                                  0, 1, l_err_num, l_err_code, l_err_msg,l_from_cg);
            end if;

            if (l_err_num <> 0) then
               raise process_error;
            end if;

            if (l_acct = -1) then
               l_acct := l_om_ccid;
            end if;

            l_stmt_num := 230;

            CSTPACDP.insert_account(l_from_org, p_txn_id, p_item_id, -1*l_elem_cost*l_snd_qty,
                           -1*l_snd_qty, l_acct, l_snd_sob_id, 2, l_cost_element, NULL, p_txn_date,
                           p_txn_src_id, p_src_type_id, l_snd_curr, NULL, NULL,
                           NULL, NULL, 1, p_user_id, p_login_id, p_req_id,
                           p_prg_appl_id, p_prg_id, l_err_num, l_err_code, l_err_msg);

            if (l_err_num <> 0) then
               raise process_error;
            end if;
         end if;
     end loop;

     -- If no cost is defined, create zero debit entry for COGS
     if (l_acct_done = 0) then
        CSTPACDP.insert_account(l_from_org, p_txn_id, p_item_id, 0,
                       -1*l_snd_qty, l_om_ccid, l_snd_sob_id, 2, 1, NULL, p_txn_date,
                       p_txn_src_id, p_src_type_id, l_snd_curr, NULL, NULL,
                       NULL, NULL, 1, p_user_id, p_login_id, p_req_id,
                       p_prg_appl_id, p_prg_id, l_err_num, l_err_code, l_err_msg);
     end if;

     end if; -- if (l_from_exp_item <> 1)

     -- Third adjustment: credit intercompany expense for the receiving org
     if (G_DEBUG = 'Y') then
        FND_FILE.put_line(FND_FILE.LOG, 'Start third adjustment');
     end if;

     /* OPM INVCONV: Process/Discrete Xfer
      * IC Expense only for Logical Intransit Receipt Txn
      */
     if ((l_pd_txfr_ind = 0) or (l_pd_txfr_ind = 1 and p_txn_act_id in (12, 15)))
     then

       l_stmt_num := 240;

       if (l_std_to_org <> 0) then    -- To see if there is intercompany expense account from Hook
          l_acct := CSTPSCHK.std_get_account_id(l_to_org, p_txn_id, -1*sign(p_txf_price), 2,
                             null, null, l_to_subinv, l_to_cg,
                             0, 2, l_err_num, l_err_code, l_err_msg);
       else
          /*BUG 8881927 ADDED 'l_to_cg' */
          l_acct := CSTPACHK.get_account_id(l_to_org, p_txn_id, -1*sign(p_txf_price), 2,
                             null, null, l_to_subinv,
                             0, 2, l_err_num, l_err_code, l_err_msg,l_to_cg);
       end if;

       if (l_err_num <> 0) then
          raise process_error;
       end if;

       if (l_acct = -1) then
          l_acct := l_inv_ccid;
       end if;

       l_stmt_num := 250;

       CSTPACDP.insert_account(l_to_org, p_txn_id, p_item_id, -1*p_txf_price*l_rcv_qty,
                             -1*l_rcv_qty, l_acct, l_rcv_sob_id, 2, NULL, NULL, p_txn_date,
                             p_txn_src_id, p_src_type_id, l_rcv_curr, l_snd_curr, l_conv_date,
                             l_conv_rate, l_curr_type, 1, p_user_id, p_login_id, p_req_id,
                             p_prg_appl_id, p_prg_id, l_err_num, l_err_code, l_err_msg);

       if (l_err_num <> 0) then
          raise process_error;
       end if;
     end if;

     -- If the option is not to treat transfer price as incoming cost, need fourth adjustment:
     -- debit/credit profit in inventory for the receiving org
     if (p_tprice_option = 1) then
        if (G_DEBUG = 'Y') then
           FND_FILE.put_line(FND_FILE.LOG, 'Start fourth adjustment');
        end if;

        l_stmt_num := 260;

        SELECT -1.0*nvl(sum(MTA.base_transaction_value),0)
        INTO l_prf
        FROM mtl_transaction_accounts MTA
        WHERE organization_id = l_to_org
        AND transaction_id = p_txn_id;

        if (G_DEBUG = 'Y') then
           FND_FILE.put_line(FND_FILE.LOG, 'l_prf = ' || l_prf);
        end if;

        if (l_prf <> 0) then
           l_stmt_num := 270;

           if (l_std_to_org <> 0) then   -- To see if there is profit in inventory account from Hook
              l_acct := CSTPSCHK.std_get_account_id(l_to_org, p_txn_id, sign(l_prf), 30, null,
                                 null, l_to_subinv, l_to_cg, 0, 2, l_err_num, l_err_code, l_err_msg);
           else
	      /*BUG 8881927 ADDED 'l_to_cg' */
              l_acct := CSTPACHK.get_account_id(l_to_org, p_txn_id, sign(l_prf), 30, null,
                                 null, l_to_subinv, 0, 2, l_err_num, l_err_code, l_err_msg,l_to_cg);
           end if;

           if (l_err_num <> 0) then
              raise process_error;
           end if;

           if (l_acct = -1) then
              l_stmt_num := 280;

              SELECT profit_in_inv_account
              INTO l_acct
              FROM mtl_interorg_parameters
              WHERE from_organization_id = l_from_org
              AND to_organization_id = l_to_org;

              if (l_acct is NULL) then
                  raise prf_inv_acct_err;
              end if;
           end if;

           l_stmt_num := 290;

           CSTPACDP.insert_account(l_to_org, p_txn_id, p_item_id, l_prf, l_rcv_qty, l_acct,
                          l_rcv_sob_id, 30, NULL, NULL, p_txn_date, p_txn_src_id, p_src_type_id,
                          l_rcv_curr, l_snd_curr, l_conv_date, l_conv_rate, l_curr_type, 1,
                          p_user_id, p_login_id, p_req_id, p_prg_appl_id, p_prg_id,
                          l_err_num, l_err_code, l_err_msg);

           if (l_err_num <> 0) then
              raise process_error;
           end if;
        end if;
     end if;

  end if;

  -- Standard check of p_commit
  if FND_API.To_Boolean(p_commit) then
     COMMIT WORK;
  end if;

  -- Standard call to get message count and message info
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data);

  if (G_DEBUG = 'Y') then
     FND_FILE.put_line(FND_FILE.LOG, 'Out of procedure CST_TPRICE_PVT.Adjust_Acct');
  end if;

EXCEPTION

  when inv_exp_acct_err then
  rollback to Adjust_Acct_PVT;
  x_return_status := FND_API.g_ret_sts_error;
  x_error_num := 9999;
  x_error_code := 'CST_TPRICE_INV_ACCT_ERROR';
  FND_MESSAGE.set_name('BOM', 'CST_TPRICE_INV_ACCT_ERROR');
  x_error_message := FND_MESSAGE.Get;
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data);

  when prf_inv_acct_err then
  rollback to Adjust_Acct_PVT;
  x_return_status := FND_API.g_ret_sts_error;
  x_error_num := 9999;
  x_error_code := 'CST_NO_PROFIT_INV_ACCT';
  FND_MESSAGE.set_name('BOM', 'CST_NO_PROFIT_INV_ACCT');
  x_error_message := FND_MESSAGE.Get;
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data);

  when process_error then
  rollback to Adjust_Acct_PVT;
  x_return_status := FND_API.g_ret_sts_error;
  x_error_num := l_err_num;
  x_error_code := l_err_code;
  x_error_message := l_err_msg;
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data);

  when others then
  rollback to Adjust_Acct_PVT;
  x_return_status := FND_API.g_ret_sts_error;
  x_error_num := SQLCODE;
  x_error_message := 'CST_TPRICE.adjust_acct(' || to_char(l_stmt_num) || ') ' ||
                     substr(SQLERRM,1,180);
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data);

END Adjust_Acct;

END CST_TPRICE_PVT;

/
