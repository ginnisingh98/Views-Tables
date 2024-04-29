--------------------------------------------------------
--  DDL for Package Body CSTPPACQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPPACQ" AS
/* $Header: CSTPACQB.pls 120.22.12010000.10 2010/05/01 11:32:47 lchevala ship $ */

/* define the Global variable for Debug   */

G_DEBUG   CONSTANT VARCHAR2(1) := NVL(fnd_profile.value('MRP_DEBUG'),'N');

PROCEDURE acq_cost_processor(
  i_period        IN         NUMBER,
  i_start_date    IN        DATE,
  i_end_date      IN        DATE,
  i_cost_type_id  IN    NUMBER,
  i_cost_group_id IN    NUMBER,
  i_user_id       IN        NUMBER,
  i_login_id      IN        NUMBER,
  i_req_id        IN        NUMBER,
  i_prog_id       IN        NUMBER,
  i_prog_appl_id  IN    NUMBER,
  o_err_num       OUT NOCOPY     NUMBER,
  o_err_code      OUT NOCOPY     VARCHAR2,
  o_err_msg       OUT NOCOPY     VARCHAR2,
  i_source_flag   IN    NUMBER,  --DEFAULT 1
  i_receipt_no    IN    NUMBER,  --DEFAULT NULL
  i_invoice_no    IN    NUMBER,  --DEFAULT NULL
  i_adj_account   IN    NUMBER ) --DEFAULT NULL
IS

  ---------------------------------------------------------------
  -- 1.0 Get all receipts that
  --     took place in the period and cost type
  --     belong to org of the cost group passed in
  --     transaction_type = 'RECEIVE' and parent_transaction_id = -1
  --    indicates a RECEIVE transaction
  --     transaction_type = 'MATCH' indicates a match to UNORDERED receipt
  --    and is equivalent to a RECEIVE transaction
  --
  --    FP BUG 5845861 fix: dropship type_code means
  --    1 External Drop Shpmnt, Shpmnt Txn flow has new accounting flag checked.
  --    2 External Drop Shpmnt, Shpmnt Txn flow does not have new accounting flag check
  --    3 Not a Drop Shpmnt
  --    So exclude only 1 while picking receipts for dropshipment scenarios
  --    BUG 6748898 FP:11I10-12.0 c_receipts cursor split into separate cursors for
  --    c_receipts_source_flag_1 for periodic acquisition cost processor
  --    c_receipts_source_flag_2 for periodic acquisition cost adjustment processor
  ---------------------------------------------------------------------------------
  /* this select has to be executed only when i_source_flag=1,
   periodic acquisition cost processor */
  CURSOR  c_receipts_source_flag_1 (l_start_date IN DATE,
				    l_end_date   IN DATE,
				    i_receipt_no IN NUMBER,
				    i_invoice_no IN NUMBER) IS
  (SELECT
  distinct rt.transaction_id ,
           nvl(poll.lcm_flag,'N') lcm_flag
  FROM
  rcv_transactions rt,
  po_line_locations_all poll, -- Added for Complex work Procurement
  cst_cost_group_assignments ccga1
  WHERE rt.transaction_date BETWEEN i_start_date and i_end_date AND
  -- Added for Complex work Procurement
  rt.po_line_id = poll.po_line_id AND
  rt.po_line_location_id = poll.line_location_id AND
  poll.shipment_type <> 'PREPAYMENT' AND
  ccga1.cost_group_id = i_cost_group_id AND
  rt.organization_id = ccga1.organization_id AND
  rt.source_document_code = 'PO' AND
  NVL(rt.consigned_flag,'N') = 'N' AND
  NVL(rt.dropship_type_code,3) <> 1 AND -- FP bug 5845861 fix
  (   ( rt.parent_transaction_id = -1 AND
      rt.transaction_type = 'RECEIVE'
    )
    OR
    ( transaction_type = 'MATCH')
    )
  );

  -----------------------------------------------------------------------------
  -- 1.0 Get all receipts that
  --     took place in the period and cost type
  --     belong to org of the cost group passed in
  --     transaction_type = 'RECEIVE' and parent_transaction_id = -1
  --	indicates a RECEIVE transaction
  --     transaction_type = 'MATCH' indicates a match to UNORDERED receipt
  --	and is equivalent to a RECEIVE transaction
  --
  -- Bug 5563311: The dropship_type code means
  --     1 External Drop Shpmnt, Shpmnt Trxn Flow has new accounting flag checked.
  --     2  External Drop Shpmnt, Shpmnt Trxn Flow does not have new accounting flag checked.
  --     3  Not a Drop Shpmnt.
  --    So exclude only 1 while picking the rcpts for dropshipment scenarios
  -- Bug 6748898 fix: c_receipts cursor split into separate cursors for
  -- c_receipts_source_flag_1 for periodic acquisition cost processor
  -- c_receipts_source_flag_2 for periodic acquisition cost adjustment processor
  --
  -- FP Bug 7336698 fix: Hint OPTIMIZER_FEATURES_ENABLE('9.0.1') added
  -------------------------------------------------------------------------------
/* This cursor has to be executed only when i_source_flag is 2 for
   periodic acquisition cost adjustment processor
*/
-- ==============================================================================
-- Tracking bug 8355614 FP performance fix: c_receipts_source_flag_2 is split into
-- multiple cursors to avoid UNION and to execute only the necessary part of the
-- sql query based on input parameters i_receipt_no and i_invoice_no
-- -----------------------------------------------------------------------------
-- Cursor is executed only when i_invoice_no is entered in the input parameter
-- of periodic acq cost adjustment processor.
-- i_invoice_no is not null.  It is the invoice id
-- -----------------------------------------------------------------------------
CURSOR c_receipts_src_flag_2_invid(i_invoice_no IN NUMBER) IS
  Select distinct rcv_transaction_id
    from ap_invoice_distributions_all aida
   where aida.invoice_id = i_invoice_no
     and aida.rcv_transaction_id IS NOT NULL
     and aida.line_type_lookup_code = 'ITEM'
     and NOT EXISTS (SELECT 1 FROM rcv_transactions rt,rcv_accounting_events rae --add for dropshipment
                      WHERE rt.transaction_id = aida.rcv_transaction_id
                      AND rae.rcv_transaction_id = rt.transaction_id
                      AND rae.event_type_id = 1 -- RECEIVE
                      AND rae.trx_flow_header_id is not NULL)
      AND NOT EXISTS ( SELECT 1
                       FROM rcv_transactions rt,
                             po_distributions_all pod
                       WHERE rt.transaction_id    = aida.rcv_transaction_id
                       AND pod.line_location_id = rt.po_line_location_id
                       AND pod.destination_type_code = 'EXPENSE' )
       AND EXISTS (Select 1
                  from rcv_transactions rt2
                  where rt2.transaction_type in ('DELIVER')
                  START WITH rt2.transaction_id = aida.rcv_transaction_id
                  CONNECT BY
                  prior rt2.transaction_id = rt2.parent_transaction_id
                 );

-- ----------------------------------------------------------------------------
-- Cursor is executed only when i_receipt_no is entered in the input parameter
-- of periodic acq cost adjustment processor.
-- i_receipt_no is not null.  It is the receipt txn_id
-- ----------------------------------------------------------------------------
CURSOR c_receipts_src_flag_2_rcptid(i_receipt_no IN NUMBER) IS
  /*bug 5044215/5264793.Only pick up receipts that have delivers */
 Select transaction_id
   from rcv_transactions
  where transaction_type in ('DELIVER')
  START WITH transaction_id = i_receipt_no
  CONNECT BY
  prior transaction_id = parent_transaction_id;

-- ----------------------------------------------------------------------------
-- Cursor is executed only when i_invoice_no is null and
-- i_receipt_no is null
-- ----------------------------------------------------------------------------
CURSOR c_receipts_source_flag_2 (l_start_date IN DATE,
                                 l_end_date   IN DATE
                                )IS
  Select /*+ OPTIMIZER_FEATURES_ENABLE('9.0.1') */
         distinct aida.rcv_transaction_id transaction_id
    from ap_invoice_distributions_all aida
        ,ap_invoice_distributions_all aida2
   WHERE aida.invoice_distribution_id = aida2.charge_applicable_to_dist_id
     AND aida2.accounting_date between l_start_date and l_end_date
     AND aida2.posted_flag = 'Y'
     AND aida2.org_id = aida.org_id /* rgangara perf bug 7475729 */
     AND aida2.line_type_lookup_code <> 'REC_TAX'
     AND aida.rcv_transaction_id is not null
     AND EXISTS (select 1 from rcv_transactions rt,
                          po_line_locations_all poll,  -- Added for Complex work Procurement
                          cst_cost_group_assignments ccga
                  where rt.transaction_id = aida.rcv_transaction_id
               -- Added for Complex work Procurement
                    and rt.po_line_id = poll.po_line_id
                    and rt.po_line_location_id = poll.line_location_id
                    and poll.shipment_type <> 'PREPAYMENT'
                    and rt.transaction_date < l_start_date
                    AND ccga.cost_group_id = i_cost_group_id
                    AND rt.organization_id = ccga.organization_id
                    AND rt.source_document_code = 'PO'
                    AND NVL(rt.consigned_flag,'N') = 'N'
                    AND NVL(rt.dropship_type_code,3) = 3  --dropshipement project
                    AND ( ( rt.parent_transaction_id = -1
                    AND rt.transaction_type = 'RECEIVE')
                     OR
                    ( rt.transaction_type = 'MATCH'))
                 )
      AND NOT EXISTS ( SELECT 1
                       FROM   RCV_TRANSACTIONS RT,
                              PO_DISTRIBUTIONS_ALL POD
                       WHERE  RT.TRANSACTION_ID         = AIDA.RCV_TRANSACTION_ID
                       AND    POD.LINE_LOCATION_ID      = RT.PO_LINE_LOCATION_ID
                       AND    POD.DESTINATION_TYPE_CODE = 'EXPENSE'
                     )
      /*bug 5044215/5264793.Only pick up receipts that have delivers */
      AND EXISTS (Select 1
                  from rcv_transactions rt2
                  where rt2.transaction_type in ('DELIVER')
                  START WITH rt2.transaction_id = aida.rcv_transaction_id
                  CONNECT BY
                  prior rt2.transaction_id = rt2.parent_transaction_id
                 )
      /* Invoice Lines Project
         Removing reference to ap_chrg_allocations_all
      */
      AND NOT EXISTS (SELECT 1 FROM rcv_transactions rt,rcv_accounting_events rae --add for dropshipment
                      WHERE rt.transaction_id = aida.rcv_transaction_id
                      AND rae.rcv_transaction_id = rt.transaction_id
                      AND rae.event_type_id = 1 -- RECEIVE
                      AND rae.trx_flow_header_id is not NULL)
      UNION
      select distinct rcv_transaction_id from ap_invoice_distributions_all aida
      where aida.accounting_date between l_start_date and l_end_date
      and aida.posted_flag = 'Y'
      /* Invoice Lines Project, TAX is now REC_TAX and NONREC_TAX */
      and aida.line_type_lookup_code <> 'REC_TAX'
      and aida.rcv_transaction_id is NOT NULL
      and exists (select 1 from rcv_transactions rt,
                          po_line_locations_all poll,   -- Added for Complex work Procurement
                          cst_cost_group_assignments ccga
            where rt.transaction_id = aida.rcv_transaction_id
             -- Added for Complex work Procurement
            and rt.po_line_id = poll.line_location_id
            and rt.po_line_location_id = poll.line_location_id
            and poll.shipment_type <> 'PREPAYMENT'
            and rt.transaction_date < l_start_date
            AND ccga.cost_group_id = i_cost_group_id
            AND rt.organization_id = ccga.organization_id
            AND rt.source_document_code = 'PO'
            AND NVL(rt.consigned_flag,'N') = 'N'
            AND NVL(rt.dropship_type_code,3) = 3 --dropshipment project
            AND ( ( rt.parent_transaction_id = -1
                 AND rt.transaction_type = 'RECEIVE')
                  OR
                 ( rt.transaction_type = 'MATCH'))
            )
      AND NOT EXISTS ( SELECT 1
                       FROM   RCV_TRANSACTIONS RT,
                              PO_DISTRIBUTIONS_ALL POD
                       WHERE  RT.TRANSACTION_ID         = AIDA.RCV_TRANSACTION_ID
                       AND    POD.LINE_LOCATION_ID    = RT.PO_LINE_LOCATION_ID
                       AND    POD.DESTINATION_TYPE_CODE = 'EXPENSE' )
       /*bug 5044215/5264793.Only pick up receipts that have delivers */
      AND EXISTS (Select 1
                  from rcv_transactions rt2
                  where rt2.transaction_type in ('DELIVER')
                  START WITH rt2.transaction_id = aida.rcv_transaction_id
                  CONNECT BY
                  prior rt2.transaction_id = rt2.parent_transaction_id
                 )
      and NOT EXISTS (SELECT 1 FROM rcv_transactions rt,rcv_accounting_events rae --add for dropshipment
                      WHERE rt.transaction_id = aida.rcv_transaction_id
                      AND rae.rcv_transaction_id = rt.transaction_id
                      AND rae.event_type_id = 1 -- RECEIVE
                      AND rae.trx_flow_header_id is not NULL);


CURSOR c_lcm_adj (l_start_date IN DATE,
                  l_end_date   IN DATE)
 IS SELECT clat.rcv_transaction_id,
           clat.inventory_item_id,
	   clat.organization_id,
	   rp.receiving_account_id,
	   nvl(msi.inventory_asset_flag,'N') inventory_asset_flag,
	   rt.po_header_id,
	   rt.po_line_location_id line_location_id,
	   rt.po_line_id,
	   rt.unit_landed_cost,
	   msi.primary_uom_code,
	   (nvl(poll.price_override,0) + get_rcv_tax(rt.transaction_id)) po_unit_price,
	   decode(nvl(poll.match_option,'P'),
                        'P',get_po_rate(rt.transaction_id),
                        'R',rt.currency_conversion_rate) rate,
           poll.org_id,
	   rt.po_release_id,
	   nvl(rt.po_distribution_id,-1) po_distribution_id,
	   poll.quantity poll_quantity,
	   muom.unit_of_measure,
           max(clat.transaction_id) transaction_id
      FROM cst_lc_adj_transactions clat,
           cst_cost_group_assignments ccga1,
	   mtl_parameters mp,
	   rcv_transactions rt,
	   rcv_parameters rp,
	   mtl_system_items msi,
	   po_line_locations_all poll,
	   mtl_units_of_measure muom
     WHERE rt.transaction_date < l_start_date
       AND clat.transaction_date BETWEEN l_start_date and l_end_date
       AND clat.rcv_transaction_id = rt.transaction_id
       AND ccga1.cost_group_id = i_cost_group_id
       AND rt.organization_id = ccga1.organization_id
       AND mp.organization_id = ccga1.organization_id
       AND msi.organization_id = clat.organization_id
       AND clat.organization_id = rt.organization_id
       AND msi.inventory_item_id = clat.inventory_item_id
       AND mp.lcm_enabled_flag = 'Y'
       AND rp.organization_id = ccga1.organization_id
       AND poll.line_location_id = rt.po_line_location_id
       AND poll.lcm_flag = 'Y'
       AND muom.uom_code = msi.primary_uom_code
     GROUP BY clat.rcv_transaction_id,
           clat.inventory_item_id,
	   clat.organization_id,
	   rp.receiving_account_id,
	   nvl(msi.inventory_asset_flag,'N'),
	   rt.po_header_id,
	   rt.po_line_location_id,
	   rt.po_line_id,
	   rt.unit_landed_cost,
	   msi.primary_uom_code,
	   (nvl(poll.price_override,0) + get_rcv_tax(rt.transaction_id)),
	   decode(nvl(poll.match_option,'P'),
                        'P',get_po_rate(rt.transaction_id),
                        'R',rt.currency_conversion_rate),
	    poll.org_id,
	    rt.po_release_id,
	    nvl(rt.po_distribution_id,-1),
	    poll.quantity,
	    muom.unit_of_measure;

CURSOR c_lcm_del(p_rcv_transaction_id IN NUMBER,
                 p_valuation_date IN DATE,
		 p_organization_id IN NUMBER) IS
SELECT mmt.subinventory_code,
       nvl(mse.asset_inventory,2) asset_inventory,
       rt.po_distribution_id,
       sum(mmt.primary_quantity) primary_quantity
  FROM  ( SELECT po_distribution_id,
                 transaction_id,
                 organization_id
           FROM  rcv_transactions
           WHERE transaction_type IN ('DELIVER','RETURN TO RECEIVING','CORRECT')
             AND transaction_date < p_valuation_date
             AND organization_id =  p_organization_id
           START WITH transaction_id        =  p_rcv_transaction_id
           CONNECT BY parent_transaction_id  = PRIOR transaction_id
           ) rt,
        mtl_material_transactions mmt,
        mtl_secondary_inventories mse
 WHERE rt.transaction_id = mmt.rcv_transaction_id
   AND mse.secondary_inventory_name = mmt.subinventory_code
   AND mse.organization_id = mmt.organization_id
   AND mmt.organization_id = rt.organization_id
  GROUP BY mmt.subinventory_code,
       nvl(mse.asset_inventory,2),
       rt.po_distribution_id;

  l_err_num             NUMBER;
  l_err_code            VARCHAR2(240);
  l_err_msg             VARCHAR2(240);
  l_stmt_num            NUMBER := 0;
  l_hook                INTEGER;
  l_first_time_flag     NUMBER := 0;
  l_legal_entity        NUMBER := 0;
  l_start_date          DATE;
  l_end_date            DATE;
  l_res_flag            NUMBER := 0;
  l_details_nextvalue   NUMBER;
  l_priuom_cost         NUMBER;
  l_res_invoices        NUMBER;
  l_prev_period_id      NUMBER;

  l_chrg_present        NUMBER :=0;

  l_accounting_event_id NUMBER;
  l_rae_unit_price      NUMBER;
  l_sob_id              NUMBER;
  l_rae_trf_price_flag  rcv_accounting_events.INTERCOMPANY_PRICING_OPTION%TYPE;

  l_order_type_lookup_code VARCHAR2(20);

  -- FP BUG 8355614 performance fix variables
  l_rcpt_flag_2        VARCHAR2(1);
  l_rcpt_flag_2_rcptid VARCHAR2(1);
  l_rcpt_flag_2_invid  VARCHAR2(1);
  l_rec_transaction_id NUMBER;

  CST_FAIL_GET_NQR              EXCEPTION;
  CST_FAIL_ACQ_HOOK             EXCEPTION;
  CST_FAIL_LCM_HOOK             EXCEPTION;
  CST_FAIL_GET_CHARGE_ALLOCS    EXCEPTION;
  CST_FAIL_COMPUTE_ACQ_COST     EXCEPTION;
  CST_ACQ_NULL_RATE             EXCEPTION;
  CST_ACQ_NULL_TAX              EXCEPTION;
  PROCESS_ERROR                 EXCEPTION;
  -- Added for Perf Bug# 5214447
  l_recs_processed NUMBER; --counter
  l_commit_records_count NUMBER := 500; -- COMMIT to be issued every 500 records. Can be changed, if reqd.

  BEGIN
    IF g_debug = 'Y' THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Acq_Cost_Processor <<<');
    END IF;
    l_recs_processed := 0;
-----------------------------------------------------
-- Initialize error variables
-----------------------------------------------------

  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';
  o_err_num := 0;
  o_err_code := '';
  o_err_msg := '';

  /* Initialize the first time flag to 0  */

  l_first_time_flag := 0;

  ---------------------------------------------
  -- Call Hooks
  ---------------------------------------------

  l_stmt_num := 10;
  l_hook := CSTPPAHK.acq_cost_hook(
                        i_period,
                        i_start_date,
                        i_end_date,
                        i_cost_type_id,
                        i_cost_group_id,
                        i_user_id,
                        i_login_id,
                        i_req_id,
                        i_prog_id,
                        i_prog_appl_id,
                        l_err_num,
                        l_err_code,
                        l_err_msg);

  IF (l_err_num <> 0) THEN
    RAISE CST_FAIL_ACQ_HOOK;
  END IF;

  l_stmt_num := 15;
  IF l_hook = 0 THEN
    l_hook := CST_LandedCostHook_PUB.landed_cost_hook (
                        i_period,
                        i_start_date,
                        i_end_date,
                        i_cost_type_id,
                        i_cost_group_id,
                        i_user_id,
                        i_login_id,
                        i_req_id,
                        i_prog_id,
                        i_prog_appl_id,
                        l_err_num,
                        l_err_code,
                        l_err_msg );

    IF (l_err_num <> 0) THEN
      RAISE CST_FAIL_LCM_HOOK;
    END IF;
  END IF;

  l_stmt_num := 20;

  select legal_entity
  into   l_legal_entity
  from   cst_cost_groups
  where  cost_group_id = i_cost_group_id ;

-- If this package is called from the acquisition adjustment process, then
-- we will have to get the period start date


-- Check for restriction flag on Invoices. If it has been turned off,
-- then there is a chance that invoices in the next period may have been
-- picked up by the acquisition cost processor, in which case,the adjustment
-- processor must not pick them up(for the all receipts case)

  l_stmt_num := 30;

  select NVL(restrict_doc_flag, 2),
         set_of_books_id
  into   l_res_invoices,
         l_sob_id
  from cst_le_cost_types
  where legal_entity = l_legal_entity
  and   cost_type_id = i_cost_type_id;

  If i_source_flag = 2 then

     If l_res_invoices = 2 then /* not set */

        l_stmt_num := 40;
        BEGIN /* to handle the case of no prev pac periods */
          select NVL(MAX(pac_period_id), -1)
          into   l_prev_period_id
          from   cst_pac_periods
          where  legal_entity = l_legal_entity
          and    open_flag    = 'N'
          and    cost_type_id = i_cost_type_id ;

          select period_close_date,
                 i_end_date
          into   l_start_date,
                 l_end_date
          from   cst_pac_periods
          where  pac_period_id = l_prev_period_id
          and    legal_entity  = l_legal_entity
          and    cost_type_id  = i_cost_type_id;

        EXCEPTION
          when others then
             l_start_date := NULL;
             l_end_date := i_end_date;
        END;

     end If; -- l_res_invoices = 2

     If l_res_invoices = 1 OR l_start_date is NULL then

        l_stmt_num := 50;
        select period_start_date,
               i_end_date
        INTO   l_start_date,
               l_end_date
        FROM   cst_pac_periods cpp
        where  cpp.pac_period_id = i_period
        and    cpp.legal_entity  = l_legal_entity
        and    cpp.cost_type_id  = i_cost_type_id;

     end If; -- l_res_invoices = 1

  else -- l_source_flag <> 2
    l_start_date := i_start_date;
    l_end_date := i_end_date;
  end if;

  IF g_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Start date: ' || to_char(l_start_date,'DD-MON-RR'));
    fnd_file.put_line(fnd_file.log,'End Date: '  || to_char(l_end_date,'DD-MON-RR'));
  END IF;


  -- ==================================================================================
  -- FP BUG 6748898 fix
  -- Execute the cursor c_receipts_source_flag_1 when i_source_flag is 1
  -- Periodic Acquisition Cost Processor
  -- Execute the cursor c_receipts_source_flag_2 when i_source_flag is 2
  -- Periodic Acquisition Cost Adjustment Processor
  -- ==================================================================================
  IF i_source_flag = 1 THEN

  -------------------------------------------------------------------------------------
  -- 2.0 Loop for each receipt when source flag = 1 Periodic Acquisition Cost Processor
  -------------------------------------------------------------------------------------
  FOR c_rec IN c_receipts_source_flag_1(l_start_date,l_end_date,i_receipt_no,i_invoice_no) LOOP

    l_recs_processed := l_recs_processed + 1;
    IF (c_rec.lcm_flag <> 'Y') THEN
    DECLARE
    l_rec_ct            NUMBER := 0;
    l_nqr               rcv_transactions.quantity%TYPE := 0;
    l_inv_count         number;
    l_header            cst_rcv_acq_costs.header_id%TYPE;
    l_primary_uom       mtl_system_items.primary_uom_code%TYPE;
    l_po_uom            mtl_units_of_measure.uom_code%TYPE;
    l_po_uom_code       po_lines_all.unit_meas_lookup_code%TYPE;
    l_po_price          po_lines_all.unit_price%TYPE;
    l_rate              rcv_transactions.CURRENCY_CONVERSION_RATE%TYPE;
    l_po_line_loc       po_lines_all.po_line_id%TYPE;
    l_item_id           mtl_system_items.inventory_item_id%TYPE;
    l_org_id            rcv_transactions.organization_id%TYPE;
    l_poll_quantity     po_line_locations_all.quantity%TYPE;
    l_pri_poll_quantity po_line_locations_all.quantity%TYPE;
    l_po_count  NUMBER; -- remove this later
    l_nr_tax_rate       NUMBER;
    l_match_option      po_line_locations_all.match_option%TYPE;
    l_rec_uom_code      rcv_transactions.unit_of_measure%TYPE;
    l_rec_uom           mtl_units_of_measure.uom_code%TYPE;

    BEGIN
      If G_DEBUG ='Y' then
        fnd_file.put_line(fnd_file.log, 'Transaction: ' ||to_char(c_rec.transaction_id));
      end If;

      l_stmt_num := 60;

        SELECT count(rcv_transaction_id)
        INTO   l_rec_ct
        FROM   cst_rcv_acq_costs crac
        WHERE  crac.rcv_transaction_id = c_rec.transaction_id
        AND    crac.period_id          = i_period
        AND    crac.cost_type_id       = i_cost_type_id
        AND    crac.cost_group_id      = i_cost_group_id
        AND    ROWNUM < 2;


      IF l_rec_ct = 0 THEN

        -------------------------------------------------------------
        -- 2.1 Get net quantity received in primary uom
        -------------------------------------------------------------
        l_nqr := get_nqr(c_rec.transaction_id,i_source_flag,
                         l_start_date,l_end_date,l_res_invoices,l_err_num); -- in pri uom

        IF (l_err_num <> 0) THEN
          RAISE CST_FAIL_GET_NQR;
        END IF;

        l_stmt_num := 110;

        -----------------------------------------------------------
        -- Get next header id from sequence
        -----------------------------------------------------------
        SELECT cst_rcv_acq_costs_s.nextval
        INTO   l_header
        FROM   dual;

        /* begin changes for dropshipment project */
        /* Includes Changes for Service Line Types */
        l_stmt_num := 120;
        Begin
          Select rae.accounting_event_id,
                 DECODE(POLL.MATCHING_BASIS, -- Changed for Complex work Procurement
                            'AMOUNT', RAE.TRANSACTION_AMOUNT,
                            'QUANTITY',rae.unit_price),
                 INTERCOMPANY_PRICING_OPTION
          Into   l_accounting_event_id,
                 l_rae_unit_price,
                 l_rae_trf_price_flag
          From   rcv_accounting_events rae,
                  po_lines_all POL,
                  po_line_locations_all POLL,  -- Added for Complex work Procurement
                  po_distributions_all POD
           Where  rae.rcv_transaction_id = c_rec.transaction_id
           and    rae.event_type_id      = 1 -- RECEIVE
           and    rae.trx_flow_header_id is not null
           and    rae.po_distribution_id = pod.po_distribution_id
           and    pod.po_line_id         = pol.po_line_id
           and    poll.po_line_id        = pol.po_line_id
           and    rae.po_line_location_id= poll.line_location_id
           and    rownum<2 ; -- Added for Complex work Procurement

	   Exception
           When others then
            l_accounting_event_id:= 0;
            l_rae_unit_price := 0;
            l_rae_trf_price_flag := 1;
        End;

        If (l_rae_trf_price_flag <> 2) then
          l_nr_tax_rate := get_rcv_tax(c_rec.transaction_id);

          IF (l_nr_tax_rate is null) THEN
            RAISE CST_ACQ_NULL_TAX;
          END IF;
        Else
          l_nr_tax_rate := 0;
        End if;
        /* dropshipment end */

        -------------------------------------------------------------
        -- Get the match_option from po_line_locations_all
        -- If match_option is P then exch rate has to be the rate at the time of PO
        -- If match_option is R then exch rate has to be the rate at the time of Receipt
        -------------------------------------------------------------

        l_stmt_num := 130;

        SELECT nvl(poll.match_option,'P')
        INTO   l_match_option
        FROM   po_line_locations_all poll,
               rcv_transactions rt7
        WHERE
               poll.line_location_id = rt7.po_line_location_id
        AND    rt7.transaction_id    = c_rec.transaction_id;


        -------------------------------------------------------------
        -- if po_line_id in POLL does not exist in POL !!
        -- this is due to corrupted data of a line_id in POLL not being in POL
        -------------------------------------------------------------

        l_stmt_num := 140;

        SELECT count(rt2.transaction_id)
        INTO   l_po_count
        FROM   rcv_transactions rt2,
               po_lines_all pol1,
               po_line_locations_all poll1
        WHERE  rt2.transaction_id = c_rec.transaction_id
        AND    rt2.po_line_location_id = poll1.line_location_id
        AND    pol1.po_line_id = poll1.po_line_id
        AND    ROWNUM < 2;

        IF l_po_count = 0 THEN
          l_stmt_num := 150;

          SELECT
              decode(l_rae_trf_price_flag, 2, l_rae_unit_price, (nvl(poll2.price_override,0) + l_nr_tax_rate)),
              rt3.po_line_location_id,
              nvl(get_rcv_rate(rt3.transaction_id),1) ,
              rsl.item_id,
              nvl(poll2.unit_meas_lookup_code,rsl.unit_of_measure),
              poll2.quantity,
              rt3.organization_id,
              nvl(poll2.matching_basis,'QUANTITY')    /* Bug4762808 */
          INTO
              l_po_price,
              l_po_line_loc,
              l_rate,
              l_item_id,
              l_po_uom_code,
              l_poll_quantity,
              l_org_id,
              l_order_type_lookup_code
          FROM
              rcv_transactions rt3,
              rcv_shipment_lines rsl,
              po_line_locations_all poll2
          WHERE
              rt3.transaction_id      = c_rec.transaction_id
          AND rt3.po_line_location_id = poll2.line_location_id
          AND rsl.shipment_line_id    = rt3.shipment_line_id;

        ELSE  -- l_po_count
        ------------------------------------------------------------
        -- Get Per Unit PO Price in terms of PO UOM
        -- Get PO Line Location Id, Item id, PO UOM, PO Quantity, org
        ------------------------------------------------------------

        -- price_override is based on PO UOM
        -- non_recoverable_tax is based on PO UOM so divide by PO quantity
        -- price_override in po currency
        -- non_recoverable_tax in po currency
        -- po_price will not be converted into functional currency now
        -- because we want to use the exch rate at time of receipt

          l_stmt_num := 65;

          SELECT
-- J Changes ---------------------------------------------------------------
              DECODE(POLL3.MATCHING_BASIS,
                          'AMOUNT', 1 + l_nr_tax_rate,
                          'QUANTITY',decode(l_rae_trf_price_flag, 2, l_rae_unit_price, (nvl(poll3.price_override,0) + l_nr_tax_rate))),
----------------------------------------------------------------------------
              rt33.po_line_location_id,
              rt33.unit_of_measure ,
              nvl(pol2.item_id,-1),
              nvl(poll3.unit_meas_lookup_code,pol2.unit_meas_lookup_code),
              poll3.quantity,
              rt33.organization_id,
              decode(nvl(poll3.match_option,'P'),
                        'P',get_po_rate(rt33.transaction_id),
                        'R',get_rcv_rate(rt33.transaction_id)),
              nvl(poll3.matching_basis,'QUANTITY')  /* Bug4762808 */
          INTO
              l_po_price,
              l_po_line_loc,
              l_rec_uom_code,
              l_item_id,
              l_po_uom_code,
              l_poll_quantity,
              l_org_id,
              l_rate,
              l_order_type_lookup_code
          FROM
              po_lines_all pol2,
              po_line_locations_all poll3,
              rcv_transactions rt33
          WHERE
              rt33.transaction_id      = c_rec.transaction_id
          AND rt33.po_line_location_id = poll3.line_location_id
          AND pol2.po_line_id = poll3.po_line_id;

        END IF; -- l_po_count

              IF (l_rate is null OR l_rate = -1) THEN
                RAISE CST_ACQ_NULL_RATE;
              END IF;

              l_stmt_num := 67;


        /* Bug 4762808 - Service Line Type POs do not have UOM and quantity populated.*/

       If l_order_type_lookup_code <> 'AMOUNT' then
        ------------------------------------------------------
        -- Get UOM code for PO UOM and REC UOM
        ------------------------------------------------------

              SELECT
              mum1.uom_code
              INTO
              l_po_uom
              FROM
              mtl_units_of_measure mum1
              WHERE
              MUM1.UNIT_OF_measure = l_po_uom_code;

             l_stmt_num := 70;

              SELECT
              mum1.uom_code
              INTO
              l_rec_uom
              FROM
              mtl_units_of_measure mum1
              WHERE
              mum1.unit_of_measure = l_rec_uom_code;

              l_stmt_num := 30;

        ---------------------------------------------------------
        -- Get Primary UOM for the Item for the org
        ---------------------------------------------------------

              IF l_item_id = -1 THEN
                l_primary_uom := l_po_uom;
              ELSE

               l_stmt_num := 75;

                SELECT
                msi.primary_uom_code
                INTO
                l_primary_uom
                FROM
                mtl_system_items msi
                WHERE
                msi.inventory_item_id = l_item_id AND
                msi.organization_id = l_org_id;
              END IF;

        ---------------------------------------------------------
        -- Convert PO Quantity into Primary Quantity
        ---------------------------------------------------------

              l_stmt_num := 78;

              l_pri_poll_quantity := inv_convert.inv_um_convert(
                  l_item_id,
                  NULL,
                  l_poll_quantity, -- PO quantity
                  l_po_uom,        -- PO UOM
                  l_primary_uom,   -- pri uom
                  NULL,
                  NULL);

        ---------------------------------------------------------
        -- PO per unit price in POLL is based on PO UOM
        -- Convert the price based on Primary UOM
        ---------------------------------------------------------

              l_po_price := l_po_price * l_poll_quantity / l_pri_poll_quantity;
           End if;

        --------------------------------------------------------
        -- 2.2 Insert inTO cst_rcV_ACQ_COSTS a row for the receipt
        --     for cost type, period, cost group
        --     setting quantity_invoiced, quantity_at_po_price,
        --     total_invoice_amount, amount_at_po_price, total_amount,
        --     costed_quantity, acqcuisition_cost to NULL for now
        --     These values will be updated later with the right values.
        ----------------------------------------------------------

              l_stmt_num := 80;

              Insert_into_acqhdr_tables(
              l_header,
              i_cost_group_id,
              i_cost_type_id,
              i_period,
              c_rec.transaction_id,
              l_nqr,  -- in pri uom
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              l_po_line_loc,
              l_po_price,  -- in po currency based on pri uom
              l_primary_uom,
              l_rate,      -- rate at time of receipt
              SYSDATE,
              i_user_id,
              SYSDATE,
              i_user_id,
              i_req_id,
              i_prog_appl_id,
              i_prog_id,
              SYSDATE,
              i_login_id,
              i_source_flag,
              l_err_num,
              l_err_msg);


        if (l_accounting_event_id = 0) then  --added for dropshipment project
        -------------------------------------------------------------
        -- 2.3 Get all posted Invoice lines from AP_INVOICE_DISTRIBUTIONS_ALL
        --     which are matched to the receipt
        --------------------------------------------------------------

              l_stmt_num := 85;

             Select NVL(restrict_doc_flag,2) into l_res_flag
             from CST_LE_COST_TYPES
             where legal_entity = l_legal_entity
             and cost_type_id = i_cost_type_id;

             l_stmt_num := 90;

              SELECT count(rcv_transaction_id)
              INTO   l_inv_count
              FROM   ap_invoice_distributions_all ad1
              WHERE  ad1.rcv_transaction_id = c_rec.transaction_id AND
                ( (l_res_flag =1 AND ad1.accounting_date between i_start_date
		                                             and i_end_date
		  )
		 OR l_res_flag = 2
		)
		AND ad1.posted_flag = 'Y' AND
              /* Invoice Lines Project TAX is now REC_TAX and NONREC_TAX */
              ad1.line_type_lookup_code <> 'REC_TAX' AND
              ROWNUM < 2;

        else
          l_inv_count := 0;
        end if;
        --------------------------------------------------------------
        -- 2.4 If there are invoices
        --  2.4.1 loop for each invoice dist line
        ---------------------------------------------------------------

         IF l_inv_count > 0 THEN
                DECLARE

                  CURSOR c_invoices IS
                  SELECT
                  ad2.invoice_distribution_id,
                  ad2.invoice_id,
-- J Changes ------------------------------------------------------------------
                  nvl(DECODE(POLL.MATCHING_BASIS, -- Changed for Complex work Procurement
                                 'AMOUNT', AD2.AMOUNT,
                                  'QUANTITY',ad2.quantity_invoiced), 0 ) "QUANTITY_INVOICED",   -- Invoice UOM
-------------------------------------------------------------------------------
                  ad2.distribution_line_number,
                  ad2.line_type_lookup_code,
-- J Changes ------------------------------------------------------------------
                  nvl(DECODE(POLL.MATCHING_BASIS,  -- Changed for Complex work Procurement
                                 'AMOUNT', 1,
                                 'QUANTITY', ad2.unit_price), 0 ) unit_price,    -- Invoice Currency
--------------------------------------------------------------------------------
                  nvl(ad2.base_amount, nvl(ad2.amount, 0)) base_amount
                  FROM
                  ap_invoice_distributions_all ad2,
-- J Changes -----------------------------------------------------------
                  RCV_TRANSACTIONS RT,
                  PO_LINES_ALL POL,
                  PO_LINE_LOCATIONS_ALL POLL,  -- Added for Complex work Procurement
                  ap_invoices_all aia   /* bug 4352624 Added to ignore invoices of type prepayment */
------------------------------------------------------------------------
                  WHERE
                       ad2.rcv_transaction_id = c_rec.transaction_id
                  AND  ad2.posted_flag        = 'Y'
                  /* bug 4352624 Added to ignore invoices of type prepayment */
                  AND ad2.line_type_lookup_code <>'PREPAY'
                  AND aia.invoice_id = ad2.invoice_id
                  AND aia.invoice_type_lookup_code <>'PREPAYMENT'

-- J Changes -----------------------------------------------------------
                  AND  RT.TRANSACTION_ID      = AD2.RCV_TRANSACTION_ID
                  AND  POL.PO_LINE_ID         = RT.PO_LINE_ID
                  AND  RT.PO_LINE_LOCATION_ID = POLL.LINE_LOCATION_ID
                  AND  POLL.PO_LINE_ID        = POL.PO_LINE_ID ---- Added for Complex work Procurement
------------------------------------------------------------------------
                  AND  ( ( l_res_flag =1 AND ad2.accounting_date between i_start_date and i_end_date)
                       OR (l_res_flag = 2)
		       )
                  /* Invoice Lines Project TAX is now REC_TAX AND NONREC_TAX */
                  AND  ad2.line_type_lookup_code <> 'REC_TAX'
-- J Changes -------------------------------------------------------------
-- Ensure that Price corrections are not picked --
                  /* Invoice Lines Project root_distribution_id ->
                     corrected_invoice_dist_id */
                  AND  ad2.corrected_invoice_dist_id is null;
--------------------------------------------------------------------------
                  l_pri_quantity_invoiced NUMBER;

                  l_correction_amount     NUMBER;
                  l_corr_inv              NUMBER;
                  l_correction_tax_amount NUMBER;  /*Bug3891984*/
                  l_corr_invoice_id       NUMBER;  /*Bug3891984*/

            BEGIN
              FOR c_inv IN c_invoices LOOP
                    ---------------------------------------------------
                    -- Check if there are any Price Correction Invoices
                    -- And if so, get the correction amount
                    ---------------------------------------------------
                    IF G_DEBUG = 'Y' THEN
                      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Invoice: ' ||to_char(c_inv.INVOICE_DISTRIBUTION_ID));
                    END IF;
                    BEGIN
                      -----------------------------------------------------
                      -- The latest price correction invoice does not
                      -- have an Invoice of type 'ADJUSTMENT' that reverses
                      -- it out.
                      -- Refer AP HLD for Retroactive Pricing
                      -- Make sure that there are no distributions in AIDA
                      -- with xinv_parent_distribution_id = inv_dist_id of
                      -- of the price correction invoice
                      -----------------------------------------------------
                      -------------------------------------------------------------------
                      -- Bug 3891984 : Added the column invoice_id in the following select
                      -- statement. This invoice id will be required to pick up the
                      -- PO Price Adjustment invoices having LINE_TYPE_LOOKUP_CODE
                      -- as 'TAX' with TAX_RECOVERABLE_FLAG set to 'N'
                      -- =====================================================================
		      -- FP Bug 7671918 fix: AP invoice corrections can be created with
		      -- invoice type 'CREDIT', 'DEBIT', 'STANDARD' along with PO PRICE ADJUST
		      -- We should not restrict the query only to PO PRICE ADJUST invoice type.
		      -- Also, AIDA.DIST_MATCH_TYPE = 'PRICE_CORRECTION'
		      -- We can sum up for the total correction amount of all such price
		      -- price correction AP invoice transactions.
		      -- Other than Non Recoverable Tax portion
                      -- ======================================================================

                      SELECT SUM(NVL(AIDA.BASE_AMOUNT, NVL(AIDA.AMOUNT, 0)))
                      INTO   l_correction_amount
                      FROM   AP_INVOICE_DISTRIBUTIONS_ALL AIDA,
                             AP_INVOICES_ALL AP_INV
                      /* Invoice Lines Project
                         No root_distribution_id or xinv_parent_reversal_id
                         now it'll just be represented by corrected_invoice_dist_id
                       */
                      WHERE  AIDA.CORRECTED_INVOICE_DIST_ID  = c_inv.INVOICE_DISTRIBUTION_ID
                      AND    AIDA.INVOICE_ID                 = AP_INV.INVOICE_ID
		      AND    AIDA.DIST_MATCH_TYPE            = 'PRICE_CORRECTION'
		      AND    AIDA.LINE_TYPE_LOOKUP_CODE      <> 'NONREC_TAX';

		      IF G_DEBUG = 'Y' THEN
		        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Correction Amount (from Price Correction Invoices): '||to_char(l_correction_amount));
                      END IF;

                       /* Bug3891984 changes starts here */
		       --============================================================
		       -- Bug 7671918 fix: AP Invoice price correction transactions
		       -- for which SUM of non recoverable tax amount of all such
		       -- AP price correction documents matching to parent AP invoice
		       -- distribution id
		       -- ===========================================================
                        SELECT SUM(NVL(AIDA.BASE_AMOUNT, NVL(AIDA.AMOUNT, 0)))
                        INTO   l_correction_tax_amount
		        FROM   AP_INVOICE_DISTRIBUTIONS_ALL AIDA,
                               AP_INVOICES_ALL AP_INV
                        /* Invoice Lines Project
                           No root_distribution_id or xinv_parent_reversal_id
                           now it'll just be represented by corrected_invoice_dist_id
                         */
                        WHERE  AIDA.CORRECTED_INVOICE_DIST_ID  = c_inv.INVOICE_DISTRIBUTION_ID
                        AND    AIDA.INVOICE_ID                 = AP_INV.INVOICE_ID
		        AND    AIDA.DIST_MATCH_TYPE            = 'PRICE_CORRECTION'
		        AND    AIDA.LINE_TYPE_LOOKUP_CODE      = 'NONREC_TAX';

       		      IF G_DEBUG = 'Y' THEN
		        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Correction Tax Amount - Non Recoverable Tax(from Price Correction Invoices): '||to_char(l_correction_tax_amount));
                      END IF;

                      l_correction_amount:= nvl(l_correction_amount,0) + nvl(l_correction_tax_amount,0);

		    /* Bug3891984 ends here */
                    EXCEPTION
                      WHEN OTHERS THEN
                        l_correction_amount := 0;
			l_correction_tax_amount := 0;
			RAISE;

                    END;

                      IF G_DEBUG = 'Y' THEN
		        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Total Correction Amount including Non Recoverable Tax(from Price Correction Invoices): '||to_char(l_correction_amount));
                      END IF;


                BEGIN

                      --------------------------------------------------------------
                      -- Convert Invoice Quantity into Primary Units
                      --------------------------------------------------------------

                      l_stmt_num := 95;

                      l_pri_quantity_invoiced := inv_convert.inv_um_convert(
                                                l_item_id,
                                                NULL,
                                                c_inv.quantity_invoiced,
                                                l_rec_uom,  -- inv uom same as rec when matched to receipt
                                                l_primary_uom,
                                                NULL,
                                                NULL);

                      ---------------------------------------------------------------
                      -- 2.4.1.1 Insert into CST_RCV_ACQ_COST_DETAILS table
                      ---------------------------------------------------------------

                      l_stmt_num := 100;

                      /* bug fix for bug 3411774. The acquisition cost considers the TAX twice if there is a
                      rcv_transaction_id against it and also if it is allocated to the ITEM lines.
                      So we should prevent insertion into the details table from the c_reciepts cursor as it will be
                      inserted into the details table later from the chrg_allocations cursor */

                     l_chrg_present := 0;

                     BEGIN

                       /* Invoice Lines Project no more ap_chrg_allocations_all table */
                       Select count(*) into l_chrg_present
                         from  ap_invoice_distributions_all
                        where invoice_distribution_id = c_inv.invoice_distribution_id
                          and charge_applicable_to_dist_id is not null;

                     EXCEPTION
                       WHEN OTHERS THEN
                         l_chrg_present := 0;
                     END;

                If l_chrg_present = 0 then /* means that this has not been allocated */

                   select cst_rcv_acq_cost_details_s.nextval into l_details_nextvalue
                   from dual;

                   l_stmt_num := 105;

                   select decode(l_pri_quantity_invoiced,0,0,(c_inv.unit_price * c_inv.quantity_invoiced / l_pri_quantity_invoiced)) into l_priuom_cost
                   from dual;

                   l_stmt_num := 110;

                   Insert_into_acqdtls_tables (
                              l_header,
                              l_details_nextvalue,
                              'INVOICE',
                              NULL,
                              c_inv.invoice_distribution_id,
                              1,
                              0,
                              c_inv.invoice_distribution_id,
                              NULL,
                              NULL,
                              NULL,
                              c_inv.base_amount + l_correction_amount,  -- in func currency
                              l_pri_quantity_invoiced, -- in pri uom
                              l_priuom_cost,  -- convert to price based on pri uom
                              c_inv.line_type_lookup_code,
                              SYSDATE,
                              i_user_id,
                              SYSDATE,
                              i_user_id,
                              i_req_id,
                              i_prog_appl_id,
                              i_prog_id,
                              SYSDATE,
                              i_login_id,
			      i_source_flag,
			      l_err_num,
			      l_err_msg);

                End If; /* end of check for rows to be present in chrg allocations table */
                ------------------------------------------------------------
                -- 2.4.1.2 Get all special charge lines that are directly
                --         or indirectly allocated to the invoice lines
                --         (that are matched to the receipt)
                ------------------------------------------------------------
                              l_stmt_num := 115;

                              get_charge_allocs(
                                  l_header,
                                  c_inv.invoice_distribution_id,
                                  i_start_date,
                                  i_end_date,
                                  l_res_flag,
                                  i_user_id,
                                  i_login_id,
                                  i_req_id,
                                  i_prog_id,
                                  i_prog_appl_id,
                                  l_err_num,
                                  l_err_code,
                                  l_err_msg);

                              IF (l_err_num <> 0) THEN
                                RAISE CST_FAIL_GET_CHARGE_ALLOCS;
                              END IF;
                END;
              END LOOP;  -- Invoice loop
            END;
         END IF;   -- If Invoice count > 0

        --------------------------------------------------------
        -- 2.5 Compute the Acquisition Cost based on the info in CRACD
        --------------------------------------------------------
              l_stmt_num := 125;

              compute_acq_cost(
                  l_header,
                  l_nqr,
                  l_po_line_loc,
                  l_po_price,
                  l_primary_uom,
                  l_rate,
                  l_po_uom,
                  l_item_id,
                  i_user_id,
                  i_login_id,
                  i_req_id,
                  i_prog_id,
                  i_prog_appl_id,
                  l_err_num,
                  l_err_code,
                  l_err_msg);

              IF (l_err_num <> 0) THEN
                RAISE CST_FAIL_COMPUTE_ACQ_COST;
              END IF;
            END IF; -- if hook was used
          END;
          ELSE /*LCM enabled*/
	    DECLARE
             l_rct_landed_cost        NUMBER;
	     l_rec_ct                 NUMBER;
	     l_rct_adj_landed_cost    NUMBER;
	     l_lcm_acq_cost           NUMBER;
	     l_net_qty_rec            rcv_transactions.quantity%TYPE := 0;
	     l_header_id              cst_rcv_acq_costs.header_id%TYPE;
	     l_nr_tax_rate            NUMBER;
	     l_primary_uom       mtl_system_items.primary_uom_code%TYPE;
             l_po_uom            mtl_units_of_measure.uom_code%TYPE;
             l_po_uom_code       po_lines_all.unit_meas_lookup_code%TYPE;
             l_po_price          po_lines_all.unit_price%TYPE;
             l_rate              rcv_transactions.CURRENCY_CONVERSION_RATE%TYPE;
             l_po_line_loc       po_line_locations_all.line_location_id%TYPE;
             l_item_id           mtl_system_items.inventory_item_id%TYPE;
             l_org_id            rcv_transactions.organization_id%TYPE;
	    BEGIN
	       l_stmt_num := 1000;
	      SELECT count(rcv_transaction_id)
                 INTO   l_rec_ct
                FROM   cst_rcv_acq_costs crac
                 WHERE  crac.rcv_transaction_id = c_rec.transaction_id
                   AND    crac.period_id          = i_period
                   AND    crac.cost_type_id       = i_cost_type_id
                   AND    crac.cost_group_id      = i_cost_group_id
                   AND    ROWNUM < 2;


               IF l_rec_ct = 0 THEN /*Hook has not been used*/
	         l_stmt_num := 1010;
	         SELECT unit_landed_cost
		   INTO l_rct_landed_cost
		  FROM rcv_transactions
		 WHERE transaction_id = c_rec.transaction_id;
                 l_stmt_num := 1020;

		 SELECT nvl(Max(new_landed_cost),-1)
		  INTO l_rct_adj_landed_cost
                  FROM
                   (
                    SELECT new_landed_cost,transaction_id,
                     max(transaction_id) OVER ( PARTITION BY transaction_date)
                     max_transaction_id
                    FROM
                     (SELECT new_landed_cost,transaction_id,transaction_date,
                       max(transaction_date) OVER (PARTITION BY rcv_transaction_id)
                       max_transaction_date
                      FROM cst_lc_adj_transactions
                       WHERE rcv_transaction_id =  c_rec.transaction_id
		         AND transaction_date BETWEEN l_start_date
			                          AND l_end_date)
                      WHERE transaction_date = max_transaction_date
                      )
                    WHERE transaction_id = max_transaction_id;
		 IF ( l_rct_adj_landed_cost = -1) THEN
		   l_lcm_acq_cost := l_rct_landed_cost;
		 ELSE
		   l_lcm_acq_cost := l_rct_adj_landed_cost;
		 END IF;
		 l_stmt_num := 1030;
                 l_net_qty_rec := get_nqr(i_transaction_id => c_rec.transaction_id,
		                          i_source_flag => i_source_flag,
                                          i_start_date => l_start_date,
					  i_end_date => l_end_date,
					  i_res_flag => 1,
					  o_err_num =>l_err_num);

		 IF (l_err_num <> 0) THEN
                     RAISE CST_FAIL_GET_NQR;
                 END IF;

                 l_stmt_num := 1040;
                 SELECT cst_rcv_acq_costs_s.nextval
                   INTO   l_header_id
                 FROM   dual;

		 l_stmt_num := 1050;

		 l_nr_tax_rate := get_rcv_tax(c_rec.transaction_id);

		 l_stmt_num := 1060;

		 SELECT
                    (nvl(poll3.price_override,0) + l_nr_tax_rate),
                    rt33.po_line_location_id,
                    nvl(pol2.item_id,-1),
                    nvl(poll3.unit_meas_lookup_code,
		        pol2.unit_meas_lookup_code),
                    rt33.organization_id,
                    decode(nvl(poll3.match_option,'P'),
                        'P',get_po_rate(rt33.transaction_id),
                        'R',rt33.currency_conversion_rate)
                   INTO
                   l_po_price,
                   l_po_line_loc,
                   l_item_id,
                   l_po_uom_code,
                   l_org_id,
                   l_rate
                 FROM
                   po_lines_all pol2,
                   po_line_locations_all poll3,
                   rcv_transactions rt33
                 WHERE rt33.transaction_id     = c_rec.transaction_id
                  AND rt33.po_line_location_id = poll3.line_location_id
                  AND pol2.po_line_id          = poll3.po_line_id;

		 l_stmt_num := 1060;

		  SELECT mum1.uom_code
                    INTO l_po_uom
		  FROM mtl_units_of_measure mum1
                  WHERE MUM1.UNIT_OF_measure = l_po_uom_code;

                  IF l_item_id = -1 THEN
                    l_primary_uom := l_po_uom;
                  ELSE
		   l_stmt_num := 1070;
                    SELECT msi.primary_uom_code
                      INTO l_primary_uom
                    FROM mtl_system_items msi
                    WHERE msi.inventory_item_id = l_item_id
		      AND msi.organization_id = l_org_id;
                  END IF;

	         l_stmt_num := 1080;
                 Insert_into_acqhdr_tables(
                     i_header_id                =>  l_header_id,
                     i_cost_group_id            =>  i_cost_group_id,
                     i_cost_type_id             =>  i_cost_type_id,
                     i_period_id                =>  i_period,
                     i_rcv_transaction_id       =>  c_rec.transaction_id,
                     i_net_quantity_received    =>  l_net_qty_rec,
                     i_total_quantity_invoiced  =>  NULL,
                     i_quantity_at_po_price     =>  0,
                     i_total_invoice_amount     =>  NULL,
                     i_amount_at_po_price       =>  0,
                     i_total_amount             =>  l_net_qty_rec*l_lcm_acq_cost,
                     i_costed_quantity          =>  l_net_qty_rec,
                     i_acquisition_cost         =>  l_lcm_acq_cost,
                     i_po_line_location_id      =>  l_po_line_loc,
                     i_po_unit_price            =>  l_po_price,
                     i_primary_uom              =>  l_primary_uom,
                     i_rec_exchg_rate           =>  l_rate,
                     i_last_update_date         =>  SYSDATE,
                     i_last_updated_by          =>  i_user_id,
                     i_creation_date            =>  SYSDATE,
                     i_created_by               =>  i_user_id,
                     i_request_id               =>  i_req_id,
                     i_program_application_id   =>  i_prog_appl_id,
                     i_program_id               =>  i_prog_id,
                     i_program_update_date      =>  SYSDATE,
                     i_last_update_login        =>  i_login_id,
                     i_source_flag              =>  i_source_flag,
                     o_err_num                  =>  l_err_num,
                     o_err_msg                  =>  l_err_msg );

		    l_stmt_num := 1090;
		    INSERT INTO cst_rcv_acq_cost_details (
                    HEADER_ID,
                    DETAIL_ID,
                    SOURCE_TYPE,
                    PO_LINE_LOCATION_ID,
                    PARENT_DISTRIBUTION_ID,
                    DISTRIBUTION_NUM,
                    LEVEL_NUM,
                    INVOICE_DISTRIBUTION_ID,
                    PARENT_INVOICE_DIST_ID,
                    ALLOCATED_AMOUNT,
                    PARENT_AMOUNT,
                    AMOUNT,
                    QUANTITY,
                    PRICE,
                    LINE_TYPE,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY,
                    REQUEST_ID,
                    PROGRAM_APPLICATION_ID,
                    PROGRAM_ID,
                    PROGRAM_UPDATE_DATE,
                    LAST_UPDATE_LOGIN
                    )
                    VALUES (
                    l_header_id,
                    cst_rcv_acq_cost_details_s.nextval,
                    'LCM',
                    l_po_line_loc,
                    NULL,
                    -1,
                    0,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    l_net_qty_rec*l_lcm_acq_cost,
                    l_net_qty_rec,
                    l_lcm_acq_cost,
                    NULL,
                    SYSDATE,
                    i_user_id,
                    SYSDATE,
                    i_user_id,
                    i_req_id,
                    i_prog_appl_id,
                    i_prog_id,
                    SYSDATE,
                    i_login_id);

	       END IF;
	    END;

	  END IF;/*LCM enabled*/
	 -- Added Perf bug# 5214447. Issuing intermediate commits after processing preset No. of rows.

	        IF l_recs_processed >= l_commit_records_count THEN
		        IF g_debug = 'Y' THEN
 	             fnd_file.put_line(fnd_file.LOG, ' 500 txns processed.... Issuing Commit ');
		        END IF;
 	            l_recs_processed := 0;
 	            COMMIT;
 	        END IF;

	END LOOP; -- Receipts loop for acquisition cost processor


	/*LCM Adjustment*/
	DECLARE
	 l_qty_del_exp_sub          NUMBER;
	 l_qty_del_asset_sub        NUMBER;
	 l_tot_qty_received         NUMBER;
	 l_lcm_abs_acct_id          NUMBER;
	 l_lcm_var_acct_id          NUMBER;
	 l_rcv_insp_acct_id         NUMBER;
	 l_exp_acct_id              NUMBER;
	 l_new_landed_cost          NUMBER;
	 l_prior_landed_cost        NUMBER;
	 l_prior_period             NUMBER;
	 l_header_id                cst_rcv_acq_costs.header_id%TYPE;
         l_exp_account_id           NUMBER;
         l_transaction_id           NUMBER;
	 l_rcv_accounting_event_id  NUMBER;
         l_dr_flag                  BOOLEAN;
         l_uom_control              NUMBER;
	 l_master_org_id            NUMBER;
	 l_avcu_txn_date            DATE;
	 l_um_rate                  NUMBER;
	 l_master_uom_code          mtl_system_items.Primary_UOM_CODE%TYPE;
	BEGIN
	l_stmt_num := 1095;
	 SELECT nvl(max(LANDED_COST_VAR_ACCOUNT),-1),
	        nvl(max(LANDED_COST_ABS_ACCOUNT),-1)
	   INTO l_lcm_var_acct_id,
	        l_lcm_abs_acct_id
	 FROM CST_ORG_COST_GROUP_ACCOUNTS
	  WHERE legal_entity_id = l_legal_entity
	    AND cost_type_id = i_cost_type_id
	    AND cost_group_id = i_cost_group_id;

          l_stmt_num := 1097;

          SELECT mia.control_level,
	         ccg.organization_id
            INTO l_uom_control,l_master_org_id
          FROM mtl_item_attributes mia,
	       cst_cost_groups ccg
          WHERE mia.attribute_name = 'MTL_SYSTEM_ITEMS.PRIMARY_UNIT_OF_MEASURE'
	    AND ccg.cost_group_id = i_cost_group_id;

          l_avcu_txn_date := least(l_end_date,sysdate);

	 FOR c_rec IN c_lcm_adj(l_start_date,l_end_date) LOOP
	 l_recs_processed := l_recs_processed + 1;
	   l_stmt_num := 1100;
	   Delete from mtl_pac_txn_cost_details mptcd
            where mptcd.transaction_id IN ( SELECT mmt.transaction_id
	                                      FROM mtl_material_transactions mmt,
					           cst_rcv_acq_costs_adj craca
	                                     WHERE mmt.rcv_transaction_id
					           = c_rec.rcv_transaction_id
					       AND mmt.transaction_source_id
					          = craca.header_id
					       AND craca.rcv_transaction_id
					           = c_rec.rcv_transaction_id
                                               AND craca.cost_group_id
					           = i_cost_group_id
                                               AND craca.period_id = i_period
                                               AND craca.cost_type_id
					           = i_cost_type_id
					       AND mmt.transaction_action_id = 24
					       AND mmt.transaction_type_id = 26
          				       AND mmt.transaction_source_type_id = 14);

           l_stmt_num := 1110;
           Delete from mtl_material_transactions mmt
           where mmt.rcv_transaction_id = c_rec.rcv_transaction_id
	    AND mmt.transaction_action_id = 24
            AND mmt.transaction_type_id = 26
            AND mmt.transaction_source_type_id = 14
	    AND mmt.transaction_source_id IN ( select craca.header_id
                                           from cst_rcv_acq_costs_adj craca
                                          where craca.period_id = i_period
                                            and craca.cost_group_id = i_cost_group_id
                                            and craca.rcv_transaction_id = c_rec.rcv_transaction_id
                                            and craca.cost_type_id = i_cost_type_id );

           l_stmt_num := 1120;
	   Delete from rcv_accounting_events rae
	    WHERE rae.event_type_id IN (18,19,20)
	      AND rae.rcv_transaction_id = c_rec.rcv_transaction_id
	      AND rae.event_source_id IN ( select header_id from cst_rcv_acq_costs_adj craca
                                     where craca.rcv_transaction_id = c_rec.rcv_transaction_id
                                     and cost_group_id = i_cost_group_id
                                     and period_id = i_period
                                     and cost_type_id = i_cost_type_id
	                                  );
           l_stmt_num := 1125;
           Delete from cst_rcv_acq_cost_details_adj cracda
           where cracda.header_id = (select header_id from cst_rcv_acq_costs_adj craca
                                     where craca.rcv_transaction_id = c_rec.rcv_transaction_id
                                     and cost_group_id = i_cost_group_id
                                     and period_id = i_period
                                     and cost_type_id = i_cost_type_id);

           l_stmt_num := 1130;

           Delete from cst_rcv_acq_costs_adj crac
           where crac.rcv_transaction_id = c_rec.rcv_transaction_id
           and cost_group_id = i_cost_group_id
           and period_id = i_period
           and cost_type_id = i_cost_type_id;

           l_stmt_num := 1140;

           l_tot_qty_received := get_nqr(i_transaction_id => c_rec.rcv_transaction_id,
	                                 i_source_flag => 2,
                                         i_start_date => l_start_date,
					 /*passing this as start date as we want total received prior to this period*/
					 i_end_date => l_start_date,
					 i_res_flag => l_res_invoices,
					 o_err_num => l_err_num); -- in pri uom
           IF (l_err_num <> 0) THEN
             RAISE CST_FAIL_GET_NQR;
           END IF;

           /* GET NEW LANDED COST*/
	   l_stmt_num := 1160;
           /*SELECT new_landed_cost
	    INTO l_new_landed_cost
	   FROM cst_lc_adj_transactions
	   WHERE transaction_id = c_rec.transaction_id;*/
	   SELECT Max(new_landed_cost)
		  INTO l_new_landed_cost
                  FROM
                   (
                    SELECT new_landed_cost,transaction_id,
                     max(transaction_id) OVER ( PARTITION BY transaction_date)
                     max_transaction_id
                    FROM
                     (SELECT new_landed_cost,transaction_id,transaction_date,
                       max(transaction_date) OVER (PARTITION BY rcv_transaction_id)
                       max_transaction_date
                      FROM cst_lc_adj_transactions
                       WHERE rcv_transaction_id =  c_rec.rcv_transaction_id
		         AND organization_id = c_rec.organization_id
		         AND transaction_date BETWEEN l_start_date
			                          AND l_end_date)
                      WHERE transaction_date = max_transaction_date
                      )
                    WHERE transaction_id = max_transaction_id;
           /* GET PRIOR LANDED COST*/
	   l_stmt_num := 1170;
	   /*SELECT nvl(max(period_id),-1)
	    INTO l_prior_period
	    FROM cst_rcv_acq_costs_adj
	    WHERE rcv_transaction_id = c_rec.rcv_transaction_id
	      AND cost_group_id = i_cost_group_id
              AND cost_type_id = i_cost_type_id;
	    IF (l_prior_period <> -1) THEN
	      l_stmt_num := 1180;
	      SELECT craca.acquisition_cost
	        INTO l_prior_landed_cost
              FROM cst_rcv_acq_costs_adj craca
	      WHERE craca.rcv_transaction_id = c_rec.rcv_transaction_id
		AND craca.cost_type_id = i_cost_type_id
		AND craca.cost_group_id = i_cost_group_id
		AND craca.period_id = l_prior_period;
	    */
	    select nvl(max(acquisition_cost),-1)
             into l_prior_landed_cost
            from (
                  select craca.acquisition_cost,
                         craca.period_id,
                         max(craca.period_id) OVER (PARTITION BY craca.rcv_transaction_id)
                         max_period_id
                    from cst_rcv_acq_costs_adj craca
                  WHERE craca.rcv_transaction_id = c_rec.rcv_transaction_id
                    AND craca.cost_type_id = i_cost_type_id
                    AND craca.cost_group_id = i_cost_group_id)
              where period_id = max_period_id;
	    IF (l_prior_landed_cost = -1) THEN
             l_stmt_num := 1190;
	     SELECT nvl(max(crac3.acquisition_cost),-1)
              INTO  l_prior_landed_cost
             FROM cst_rcv_acq_costs crac3
            WHERE crac3.cost_type_id = i_cost_type_id
	      AND crac3.cost_group_id = i_cost_group_id
	      AND crac3.rcv_transaction_id = c_rec.rcv_transaction_id;

	      IF (l_prior_landed_cost = -1) THEN
	       l_stmt_num := 1200;
	       /* SELECT nvl(max(clat1.new_landed_cost),-1)
		 INTO l_prior_landed_cost
		FROM cst_lc_adj_transactions clat1
		 WHERE clat1.rcv_transaction_id = c_rec.rcv_transaction_id
		   AND clat1.transaction_date < l_start_date
		   AND clat1.transaction_id = ( SELECT max(clat2.transaction_id)
		                                 FROM cst_lc_adj_transactions clat2
						 WHERE clat2.rcv_transaction_id =
						       c_rec.rcv_transaction_id
						   AND clat2.transaction_date <
                                                       l_start_date
		                               );*/
                 SELECT nvl(Max(new_landed_cost),-1)
		  INTO l_prior_landed_cost
                  FROM
                   (
                    SELECT new_landed_cost,transaction_id,
                     max(transaction_id) OVER ( PARTITION BY transaction_date)
                     max_transaction_id
                    FROM
                     (SELECT new_landed_cost,transaction_id,transaction_date,
                       max(transaction_date) OVER (PARTITION BY rcv_transaction_id)
                       max_transaction_date
                      FROM cst_lc_adj_transactions
                       WHERE rcv_transaction_id =  c_rec.rcv_transaction_id
		         AND transaction_date < l_start_date
		       )
                      WHERE transaction_date = max_transaction_date
                      )
                    WHERE transaction_id = max_transaction_id;
                 IF l_prior_landed_cost = -1 THEN
		   l_prior_landed_cost := c_rec.unit_landed_cost;
		 END IF;
	      END IF;
	    END IF;
	 IF (l_prior_landed_cost <> l_new_landed_cost) THEN
	    l_stmt_num := 1210;
             SELECT cst_rcv_acq_costs_s.nextval
                INTO   l_header_id
              FROM   dual;

            l_stmt_num := 1220;

	      Insert_into_acqhdr_tables(
                     i_header_id                =>  l_header_id,
                     i_cost_group_id            =>  i_cost_group_id,
                     i_cost_type_id             =>  i_cost_type_id,
                     i_period_id                =>  i_period,
                     i_rcv_transaction_id       =>  c_rec.rcv_transaction_id,
                     i_net_quantity_received    =>  l_tot_qty_received,
                     i_total_quantity_invoiced  =>  NULL,
                     i_quantity_at_po_price     =>  0,
                     i_total_invoice_amount     =>  NULL,
                     i_amount_at_po_price       =>  0,
                     i_total_amount             =>  l_tot_qty_received*l_new_landed_cost,
                     i_costed_quantity          =>  l_tot_qty_received,
                     i_acquisition_cost         =>  l_new_landed_cost,
                     i_po_line_location_id      =>  c_rec.line_location_id,
                     i_po_unit_price            =>  c_rec.po_unit_price,
                     i_primary_uom              =>  c_rec.primary_uom_code,
                     i_rec_exchg_rate           =>  c_rec.rate,
                     i_last_update_date         =>  SYSDATE,
                     i_last_updated_by          =>  i_user_id,
                     i_creation_date            =>  SYSDATE,
                     i_created_by               =>  i_user_id,
                     i_request_id               =>  i_req_id,
                     i_program_application_id   =>  i_prog_appl_id,
                     i_program_id               =>  i_prog_id,
                     i_program_update_date      =>  SYSDATE,
                     i_last_update_login        =>  i_login_id,
                     i_source_flag              =>  2,
                     o_err_num                  =>  l_err_num,
                     o_err_msg                  =>  l_err_msg );

                 l_stmt_num := 1230;
		     INSERT INTO cst_rcv_acq_cost_details_adj (
                        HEADER_ID,
                        DETAIL_ID,
                        SOURCE_TYPE,
                        PO_LINE_LOCATION_ID,
                        PARENT_DISTRIBUTION_ID,
                        DISTRIBUTION_NUM,
                        LEVEL_NUM,
                        INVOICE_DISTRIBUTION_ID,
                        PARENT_INVOICE_DIST_ID,
                        ALLOCATED_AMOUNT,
                        PARENT_AMOUNT,
                        AMOUNT,
                        QUANTITY,
                        PRICE,
                        LINE_TYPE,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        REQUEST_ID,
                        PROGRAM_APPLICATION_ID,
                        PROGRAM_ID,
                        PROGRAM_UPDATE_DATE,
                        LAST_UPDATE_LOGIN
                        )
                        VALUES (
                        l_header_id,
                        cst_rcv_acq_cost_details_s.nextval,
                        'LCM',
                        c_rec.line_location_id,
                        NULL,
                        -1,
                        0,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        l_tot_qty_received*l_new_landed_cost,
                        l_tot_qty_received,
                        l_new_landed_cost,
                        NULL,
                        SYSDATE,
                        i_user_id,
                        SYSDATE,
                        i_user_id,
                        i_req_id,
                        i_prog_appl_id,
                        i_prog_id,
                        SYSDATE,
                        i_login_id);
                   l_stmt_num := 1240;
		   /* Insert PAC LCM ADJUST RECEIVE INTO RAE */
                IF (c_rec.po_distribution_id <> -1) THEN
		INSERT into RCV_ACCOUNTING_EVENTS(
                 accounting_event_id,
                 last_update_date,
                 last_updated_by,
                 last_update_login,
                 creation_date,
                 created_by,
                 request_id,
                 program_application_id,
                 program_id,
                 program_udpate_date,
                 rcv_transaction_id,
                 event_type_id,
                 event_source,
                 event_source_id,
                 set_of_books_id,
                 org_id,
                 organization_id,
                 debit_account_id,
                 credit_account_id,
                 transaction_date,
                 source_doc_quantity,
                 transaction_quantity,
                 primary_quantity,
                 source_doc_unit_of_measure,
                 transaction_unit_of_measure,
                 primary_unit_of_measure,
                 po_header_id,
                 po_release_id,
                 po_line_id,
                 po_line_location_id,
                 po_distribution_id,
                 inventory_item_id,
                 unit_price,
                 prior_unit_price,
		 currency_conversion_rate)
          (SELECT
           rcv_accounting_event_s.NEXTVAL,
           sysdate,
           i_user_id,
           i_login_id,
           sysdate,
           i_user_id,
           i_req_id,
           i_prog_appl_id,
           i_prog_id,
           sysdate,
           c_rec.rcv_transaction_id,
           18,
           'PAC_LCM_ADJ_REC' ,
           l_header_id,
           l_sob_id,
           c_rec.org_id,
           c_rec.organization_id,
           decode(sign(l_tot_qty_received*
	              (l_new_landed_cost-l_prior_landed_cost)),-1,
		      l_lcm_abs_acct_id,
		  c_rec.receiving_account_id),
           decode(sign(l_tot_qty_received*
	              (l_new_landed_cost-l_prior_landed_cost)),-1,
	              c_rec.receiving_account_id,
		  l_lcm_abs_acct_id),
           l_avcu_txn_date,
           l_tot_qty_received  ,
           l_tot_qty_received  ,
           l_tot_qty_received  ,
           c_rec.unit_of_measure,
           c_rec.unit_of_measure,
           c_rec.unit_of_measure,
           c_rec.po_header_id,
           c_rec.po_release_id,
           c_rec.po_line_id,
           c_rec.line_location_id,
           c_rec.po_distribution_id,
           c_rec.inventory_item_id,
           l_new_landed_cost unit_price,
           l_prior_landed_cost,
	   1
        FROM DUAL);
       ELSE
       l_stmt_num := 1245;
       INSERT into RCV_ACCOUNTING_EVENTS(
                 accounting_event_id,
                 last_update_date,
                 last_updated_by,
                 last_update_login,
                 creation_date,
                 created_by,
                 request_id,
                 program_application_id,
                 program_id,
                 program_udpate_date,
                 rcv_transaction_id,
                 event_type_id,
                 event_source,
                 event_source_id,
                 set_of_books_id,
                 org_id,
                 organization_id,
                 debit_account_id,
                 credit_account_id,
                 transaction_date,
                 source_doc_quantity,
                 transaction_quantity,
                 primary_quantity,
                 source_doc_unit_of_measure,
                 transaction_unit_of_measure,
                 primary_unit_of_measure,
                 po_header_id,
                 po_release_id,
                 po_line_id,
                 po_line_location_id,
                 po_distribution_id,
                 inventory_item_id,
                 unit_price,
                 prior_unit_price,
		 currency_conversion_rate)
          (SELECT
           rcv_accounting_event_s.NEXTVAL,
           sysdate,
           i_user_id,
           i_login_id,
           sysdate,
           i_user_id,
           i_req_id,
           i_prog_appl_id,
           i_prog_id,
           sysdate,
           c_rec.rcv_transaction_id,
           18,
           'PAC_LCM_ADJ_REC' ,
           l_header_id,
           l_sob_id,
           c_rec.org_id,
           c_rec.organization_id,
           decode(sign(l_tot_qty_received*
	              (l_new_landed_cost-l_prior_landed_cost)),-1,
		      l_lcm_abs_acct_id,
		  c_rec.receiving_account_id),
           decode(sign(l_tot_qty_received*
	              (l_new_landed_cost-l_prior_landed_cost)),-1,
	              c_rec.receiving_account_id,
		  l_lcm_abs_acct_id),
           l_avcu_txn_date,
           l_tot_qty_received*POD.quantity_ordered/c_rec.poll_quantity  source_doc_quantity,
           l_tot_qty_received*POD.quantity_ordered/c_rec.poll_quantity  transaction_quantity,
           l_tot_qty_received*POD.quantity_ordered/c_rec.poll_quantity  primary_quantity,
           c_rec.unit_of_measure,
           c_rec.unit_of_measure,
           c_rec.unit_of_measure,
           c_rec.po_header_id,
           c_rec.po_release_id,
           c_rec.po_line_id,
           c_rec.line_location_id,
           pod.po_distribution_id,
           c_rec.inventory_item_id,
           l_new_landed_cost unit_price,
           l_prior_landed_cost,
	   1
        FROM po_distributions_all pod
	 WHERE pod.line_location_id = c_rec.line_location_id);
       END IF;
	/* NOW INSERT THE RAE FOR DELIVERY */
           FOR C_REC2 IN c_lcm_del(c_rec.rcv_transaction_id,
                                   l_start_date,
		                   c_rec.organization_id ) LOOP
	     IF (C_REC2.asset_inventory = 1
	         AND C_REC.inventory_asset_flag ='Y' ) THEN
               l_stmt_num := 1250;
	       INSERT into RCV_ACCOUNTING_EVENTS(
                 accounting_event_id,
                 last_update_date,
                 last_updated_by,
                 last_update_login,
                 creation_date,
                 created_by,
                 request_id,
                 program_application_id,
                 program_id,
                 program_udpate_date,
                 rcv_transaction_id,
                 event_type_id,
                 event_source,
                 event_source_id,
                 set_of_books_id,
                 org_id,
                 organization_id,
                 debit_account_id,
                 credit_account_id,
                 transaction_date,
                 source_doc_quantity,
                 transaction_quantity,
                 primary_quantity,
                 source_doc_unit_of_measure,
                 transaction_unit_of_measure,
                 primary_unit_of_measure,
                 po_header_id,
                 po_release_id,
                 po_line_id,
                 po_line_location_id,
                 po_distribution_id,
                 inventory_item_id,
                 unit_price,
                 prior_unit_price,
		 currency_conversion_rate)
		 VALUES
             (
              rcv_accounting_event_s.NEXTVAL,
              sysdate,
              i_user_id,
              i_login_id,
              sysdate,
              i_user_id,
              i_req_id,
              i_prog_appl_id,
              i_prog_id,
              sysdate,
              c_rec.rcv_transaction_id,
              19,
              'PAC_LCM_ADJ_DEL_ASSET' ,
              l_header_id,
              l_sob_id,
              c_rec.org_id,
              c_rec.organization_id,
              decode(sign(c_rec2.primary_quantity*
	                 (l_new_landed_cost-l_prior_landed_cost)),-1,
		         c_rec.receiving_account_id,
		     l_lcm_abs_acct_id),
              decode(sign(c_rec2.primary_quantity*
	                 (l_new_landed_cost-l_prior_landed_cost)),-1,
	                 l_lcm_abs_acct_id,
		     c_rec.receiving_account_id),
               l_avcu_txn_date,
               c_rec2.primary_quantity  ,
               c_rec2.primary_quantity  ,
               c_rec2.primary_quantity  ,
               c_rec.unit_of_measure,
               c_rec.unit_of_measure,
               c_rec.unit_of_measure,
               c_rec.po_header_id,
               c_rec.po_release_id,
               c_rec.po_line_id,
               c_rec.line_location_id,
               c_rec2.po_distribution_id,
               c_rec.inventory_item_id,
               l_new_landed_cost ,
               l_prior_landed_cost,
	       1
               )
	       Returning accounting_event_id INTO l_rcv_accounting_event_id;
               l_stmt_num := 1260;
	       select MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL
               into l_transaction_id
               from dual;
	       l_stmt_num := 1265;
	         l_um_rate := 1;
	         CSTPPINV.get_um_rate(
                          i_txn_org_id         => c_rec.organization_id,
                          i_master_org_id      => l_master_org_id,
                          i_txn_cost_group_id  => i_cost_group_id,
                          i_txfr_cost_group_id => -1,
                          i_txn_action_id      => 24,
                          i_item_id            => c_rec.inventory_item_id,
                          i_uom_control        => l_uom_control,
                          i_user_id            => i_user_id,
                          i_login_id           => i_login_id,
                          i_request_id         => i_req_id,
                          i_prog_id            => i_prog_id,
                          i_prog_appl_id       => i_prog_appl_id,
                          o_um_rate            => l_um_rate,
                          o_err_num            => l_err_num,
                          o_err_code           => l_err_code,
                          o_err_msg            => l_err_msg
                          );
               IF (l_err_num <> 0) THEN
                  RAISE PROCESS_ERROR;
               END IF;
               l_stmt_num := 1268;
                 SELECT msi.primary_uom_code
		  INTO l_master_uom_code
		 FROM mtl_system_items msi
		  WHERE msi.organization_id = l_master_org_id
		    AND msi.inventory_item_id = c_rec.inventory_item_id;
               l_stmt_num := 1270;
               INSERT INTO MTL_MATERIAL_TRANSACTIONS
          (transaction_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           inventory_item_id,
           organization_id,
           transaction_type_id,
           transaction_action_id,
           transaction_source_type_id,
           transaction_quantity,
           transaction_uom,
           primary_quantity,
           transaction_date,
           value_change,
           material_account,
           material_overhead_account,
           resource_account,
           outside_processing_account,
           overhead_account,
           costed_flag,
           org_cost_group_id,
           cost_type_id,
           source_code,
           source_line_id,
	   expense_account_id,
	   rcv_transaction_id,
	   transaction_source_id,
	   subinventory_code)
           VALUES (
                 l_transaction_id,
                 sysdate,
                 i_user_id,
                 sysdate,
                 i_user_id,
                 c_rec.inventory_item_id,
                 l_master_org_id,
                 26,
                 24,
                 14,
		 c_rec2.primary_quantity* l_um_rate,
                 l_master_uom_code,
		 c_rec2.primary_quantity* l_um_rate,
                 l_avcu_txn_date,
                 (c_rec2.primary_quantity*
		  (l_new_landed_cost-l_prior_landed_cost)),
                 l_lcm_abs_acct_id,
                 l_lcm_abs_acct_id,
                 l_lcm_abs_acct_id,
                 l_lcm_abs_acct_id,
                 l_lcm_abs_acct_id,
                 NULL,
                 i_cost_group_id,
                 i_cost_type_id,
                 'PACLCMADJ',
                 l_rcv_accounting_event_id,
		 l_lcm_var_acct_id,
                 c_rec.rcv_transaction_id,
		 l_header_id,
		 c_rec2.subinventory_code
               );

          /* insert into MPTCD */
               l_stmt_num := 1280;
          Insert into mtl_pac_txn_cost_details
                (cost_group_id,
                 transaction_id,
                 pac_period_id,
                 cost_type_id,
                 cost_element_id,
                 level_type,
                 inventory_item_id,
                 value_change,
                 transaction_cost,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by )
         Values (i_cost_group_id,
                 l_transaction_id,
                 i_period,
                 i_cost_type_id,
                 1, -- cost element ID
                 1, -- THis level
                 c_rec.inventory_item_id,
                 (c_rec2.primary_quantity*
		  (l_new_landed_cost-l_prior_landed_cost)),
                 l_prior_landed_cost/l_um_rate,
                 sysdate,
                 i_user_id,
                 sysdate,
                 i_user_id);

	     ELSE
	      l_stmt_num := 1300;
        IF (sign(c_rec2.primary_quantity*(l_new_landed_cost-l_prior_landed_cost)) = -1 ) THEN
         l_dr_flag :=  "FALSE";
        ELSE
         l_dr_flag := "TRUE";
        END IF;

	      l_exp_account_id := CSTPAPHK.get_account_id (
                                        c_rec.rcv_transaction_id,
                                        l_legal_entity,
                                        i_cost_type_id,
                                        i_cost_group_id,
                                        l_dr_flag,
                                        2,
                                        1,
                                        NULL,
                                        c_rec2.subinventory_code,
                                        "TRUE",
                                        l_err_num,
                                        l_err_code,
                                        l_err_msg);
                IF (l_err_num<>0 AND
		    l_err_num is not null) then
                  RAISE process_error;
                END IF;
	       IF (l_exp_account_id = -1) THEN
	         l_stmt_num := 1310;
	         SELECT  nvl(expense_account, -1)
                   INTO l_exp_account_id
                  FROM mtl_fiscal_cat_accounts
                  WHERE legal_entity_id = l_legal_entity
                    AND cost_type_id    = i_cost_type_id
                    AND cost_group_id   = i_cost_group_id
                    AND category_id     = (SELECT mic.category_id
                                            FROM mtl_item_categories mic
                                             WHERE mic.inventory_item_id =
			                           c_rec.inventory_item_id
                                               AND mic.organization_id =
			                           c_rec.organization_id
                                               AND  mic.category_set_id =
			                           (SELECT category_set_id
                                                     FROM mtl_default_category_sets
                                                     WHERE functional_area_id = 5)
                                            );
	       END IF;
	       l_stmt_num := 1320;
	       INSERT into RCV_ACCOUNTING_EVENTS(
                 accounting_event_id,
                 last_update_date,
                 last_updated_by,
                 last_update_login,
                 creation_date,
                 created_by,
                 request_id,
                 program_application_id,
                 program_id,
                 program_udpate_date,
                 rcv_transaction_id,
                 event_type_id,
                 event_source,
                 event_source_id,
                 set_of_books_id,
                 org_id,
                 organization_id,
                 debit_account_id,
                 credit_account_id,
                 transaction_date,
                 source_doc_quantity,
                 transaction_quantity,
                 primary_quantity,
                 source_doc_unit_of_measure,
                 transaction_unit_of_measure,
                 primary_unit_of_measure,
                 po_header_id,
                 po_release_id,
                 po_line_id,
                 po_line_location_id,
                 po_distribution_id,
                 inventory_item_id,
                 unit_price,
                 prior_unit_price,
		 currency_conversion_rate)
             (   SELECT
              rcv_accounting_event_s.NEXTVAL,
              sysdate,
              i_user_id,
              i_login_id,
              sysdate,
              i_user_id,
              i_req_id,
              i_prog_appl_id,
              i_prog_id,
              sysdate,
              c_rec.rcv_transaction_id,
              20,
              'PAC_LCM_ADJ_DEL_EXP' ,
              l_header_id,
              l_sob_id,
              c_rec.org_id,
              c_rec.organization_id,
              decode(sign(c_rec2.primary_quantity*
	                 (l_new_landed_cost-l_prior_landed_cost)),-1,
		         c_rec.receiving_account_id,
		     l_exp_account_id),
              decode(sign(c_rec2.primary_quantity*
	                 (l_new_landed_cost-l_prior_landed_cost)),-1,
	                 l_exp_account_id,
		     c_rec.receiving_account_id),
               l_avcu_txn_date,
               c_rec2.primary_quantity  source_doc_quantity,
               c_rec2.primary_quantity  transaction_quantity,
               c_rec2.primary_quantity  primary_quantity,
               c_rec.unit_of_measure,
               c_rec.unit_of_measure,
               c_rec.unit_of_measure,
               c_rec.po_header_id,
               c_rec.po_release_id,
               c_rec.po_line_id,
               c_rec.line_location_id,
               c_rec2.po_distribution_id,
               c_rec.inventory_item_id,
               l_new_landed_cost unit_price,
               l_prior_landed_cost,
	       1
               FROM DUAL);
	     END IF;
	   END LOOP;
	    IF l_recs_processed >= l_commit_records_count THEN
	      IF g_debug = 'Y' THEN
 	         fnd_file.put_line(fnd_file.LOG, ' 500 txns processed.... Issuing Commit ');
	      END IF;
 	     l_recs_processed := 0;
 	     COMMIT;
 	    END IF;
	   END IF; /*prior landed cost <> new landed cost*/
	 END LOOP;
	 /* Update the primary_quantity of the MMT with total adjusted QTY */
	 l_stmt_num := 1330;
	 UPDATE mtl_material_transactions mmt
	  SET (primary_quantity,
	       transaction_quantity)
	    =            ( SELECT sum(mmt2.primary_quantity),
	                          sum(mmt2.transaction_quantity)
	                             FROM mtl_material_transactions mmt2
				    WHERE mmt2.inventory_item_id =
				          mmt.inventory_item_id
				      AND mmt2.transaction_action_id = 24
	                              AND mmt2.transaction_type_id = 26
	                              AND mmt2.transaction_source_type_id = 14
	                              AND mmt2.transaction_date = l_avcu_txn_date
	                              AND mmt2.source_code = 'PACLCMADJ'
	                              AND mmt2.org_cost_group_id = i_cost_group_id
	                              AND mmt2.cost_type_id = i_cost_type_id
				      AND mmt2.organization_id = l_master_org_id
	                          )
	 WHERE mmt.transaction_action_id = 24
	   AND mmt.transaction_type_id = 26
	   AND mmt.transaction_source_type_id = 14
	   AND mmt.transaction_date = l_avcu_txn_date
	   AND mmt.source_code = 'PACLCMADJ'
	   AND mmt.org_cost_group_id = i_cost_group_id
	   AND mmt.cost_type_id = i_cost_type_id
	   AND mmt.organization_id = l_master_org_id;

	END;
        /*LCM Adjustment*/
	IF g_debug = 'Y' THEN
		FND_FILE.PUT_LINE(FND_FILE.LOG, 'Acq_Cost_Processor >>>');
	END IF;

  ELSIF i_source_flag = 2 THEN
    -------------------------------------------------------------------------------------
    -- 2.0 Loop for each receipt when source flag = 2
    -- Periodic Acquisition Cost Adjustment Processor
    -------------------------------------------------------------------------------------
    -- Reset the receipt cursor flags
    l_rcpt_flag_2 := 'N';
    l_rcpt_flag_2_rcptid := 'N';
    l_rcpt_flag_2_invid := 'N';

    IF i_receipt_no IS NULL AND i_invoice_no IS NULL THEN

      OPEN c_receipts_source_flag_2(l_start_date,l_end_date);
      FETCH c_receipts_source_flag_2
       INTO l_rec_transaction_id;

      IF c_receipts_source_flag_2%FOUND THEN
        l_rcpt_flag_2 := 'Y';
      ELSE
        l_rcpt_flag_2 := 'N';
      END IF;

    ELSIF i_receipt_no IS NOT NULL THEN
       OPEN c_receipts_src_flag_2_rcptid(i_receipt_no);
       FETCH c_receipts_src_flag_2_rcptid
        INTO l_rec_transaction_id;

       IF c_receipts_src_flag_2_rcptid%FOUND THEN
         l_rcpt_flag_2_rcptid := 'Y';
       ELSE
         l_rcpt_flag_2_rcptid := 'N';
       END IF;

    ELSIF i_invoice_no IS NOT NULL THEN
       OPEN c_receipts_src_flag_2_invid(i_invoice_no);
       FETCH c_receipts_src_flag_2_invid
        INTO l_rec_transaction_id;

       IF c_receipts_src_flag_2_invid%FOUND THEN
          l_rcpt_flag_2_invid := 'Y';
       ELSE
          l_rcpt_flag_2_invid := 'N';
       END IF;

    END IF;


  WHILE l_rcpt_flag_2 = 'Y' OR l_rcpt_flag_2_rcptid = 'Y' OR l_rcpt_flag_2_invid = 'Y' LOOP

    l_recs_processed := l_recs_processed + 1;
    DECLARE
    l_rec_ct            NUMBER := 0;
    l_nqr               rcv_transactions.quantity%TYPE := 0;
    l_inv_count         number;
    l_header            cst_rcv_acq_costs.header_id%TYPE;
    l_primary_uom       mtl_system_items.primary_uom_code%TYPE;
    l_po_uom            mtl_units_of_measure.uom_code%TYPE;
    l_po_uom_code       po_lines_all.unit_meas_lookup_code%TYPE;
    l_po_price          po_lines_all.unit_price%TYPE;
    l_rate              rcv_transactions.CURRENCY_CONVERSION_RATE%TYPE;
    l_po_line_loc       po_lines_all.po_line_id%TYPE;
    l_item_id           mtl_system_items.inventory_item_id%TYPE;
    l_org_id            rcv_transactions.organization_id%TYPE;
    l_poll_quantity     po_line_locations_all.quantity%TYPE;
    l_pri_poll_quantity po_line_locations_all.quantity%TYPE;
    l_po_count  NUMBER; -- remove this later
    l_nr_tax_rate       NUMBER;
    l_match_option      po_line_locations_all.match_option%TYPE;
    l_rec_uom_code      rcv_transactions.unit_of_measure%TYPE;
    l_rec_uom           mtl_units_of_measure.uom_code%TYPE;

    BEGIN
      If G_DEBUG ='Y' then
        fnd_file.put_line(fnd_file.log, 'Transaction: ' ||to_char(l_rec_transaction_id));
      end If;

      -- Delete from MMT and MPTCD transactions that were created for the
      -- previous run for this receipt and then delete from craca and cracda*/

        l_stmt_num := 71;
        Delete from mtl_pac_txn_cost_details mptcd
        where mptcd.transaction_id IN ( select craca.mmt_transaction_id
                                          from cst_rcv_acq_costs_adj craca
                                         where craca.mmt_transaction_id is not null
                                           and craca.period_id = i_period
                                           and craca.cost_group_id = i_cost_group_id
                                           and craca.rcv_transaction_id = l_rec_transaction_id
                                           and craca.cost_type_id = i_cost_type_id );

        Delete from mtl_material_transactions mmt
        where mmt.transaction_id IN ( select craca.mmt_transaction_id
                                        from cst_rcv_acq_costs_adj craca
                                       where craca.mmt_transaction_id is not null
                                         and craca.period_id = i_period
                                         and craca.cost_group_id = i_cost_group_id
                                         and craca.rcv_transaction_id = l_rec_transaction_id
                                         and craca.cost_type_id = i_cost_type_id );

        l_stmt_num := 81;

        Delete from cst_rcv_acq_cost_details_adj cracda
        where cracda.header_id = (select header_id from cst_rcv_acq_costs_adj craca
                                  where craca.rcv_transaction_id = l_rec_transaction_id
                                  and cost_group_id = i_cost_group_id
                                  and period_id = i_period
                                  and cost_type_id = i_cost_type_id);

        l_stmt_num := 91;

        Delete from cst_rcv_acq_costs_adj crac
        where crac.rcv_transaction_id = l_rec_transaction_id
        and cost_group_id = i_cost_group_id
        and period_id = i_period
        and cost_type_id = i_cost_type_id;

        If l_first_time_flag = 0 then
           l_first_time_flag := 1;
           l_stmt_num := 101;

           CSTPPPUR.purge_period_data(i_period,
                                      l_legal_entity,
                                      i_cost_group_id,
                                      0,
                                      i_user_id,
                                      i_login_id,
                                      i_req_id,
                                      i_prog_id,
                                      i_prog_appl_id,
                                      l_err_num,
                                      l_err_code,
                                      l_err_msg);
        end if;  -- l_first_time_flag

        l_rec_ct := 0;


      IF l_rec_ct = 0 THEN

        -------------------------------------------------------------
        -- 2.1 Get net quantity received in primary uom
        -------------------------------------------------------------
        l_nqr := get_nqr(l_rec_transaction_id,i_source_flag,
                         l_start_date,l_end_date,l_res_invoices,l_err_num); -- in pri uom

        IF (l_err_num <> 0) THEN
          RAISE CST_FAIL_GET_NQR;
        END IF;

        l_stmt_num := 111;

        -----------------------------------------------------------
        -- Get next header id from sequence
        -----------------------------------------------------------
        SELECT cst_rcv_acq_costs_s.nextval
        INTO   l_header
        FROM   dual;

        /* begin changes for dropshipment project */
        /* Includes Changes for Service Line Types */
        l_stmt_num := 121;
        Begin
          Select rae.accounting_event_id,
                 DECODE(POLL.MATCHING_BASIS, -- Changed for Complex work Procurement
                            'AMOUNT', RAE.TRANSACTION_AMOUNT,
                            'QUANTITY',rae.unit_price),
                 INTERCOMPANY_PRICING_OPTION
          Into   l_accounting_event_id,
                 l_rae_unit_price,
                 l_rae_trf_price_flag
          From   rcv_accounting_events rae,
                  po_lines_all POL,
                  po_line_locations_all POLL,  -- Added for Complex work Procurement
                  po_distributions_all POD
           Where  rae.rcv_transaction_id = l_rec_transaction_id
           And    rae.event_type_id      = 1 -- RECEIVE
           And    rae.trx_flow_header_id is not null
           AND    RAE.PO_DISTRIBUTION_ID = POD.PO_DISTRIBUTION_ID
           AND    POD.PO_LINE_ID         = POL.PO_LINE_ID
           AND    POLL.PO_LINE_ID        = POL.PO_LINE_ID; -- Added for Complex work Procurement
        Exception
          When others then
            l_accounting_event_id:= 0;
            l_rae_unit_price := 0;
            l_rae_trf_price_flag := 1;
        End;

        If (l_rae_trf_price_flag <> 2) then
          l_nr_tax_rate := get_rcv_tax(l_rec_transaction_id);

          IF (l_nr_tax_rate is null) THEN
            RAISE CST_ACQ_NULL_TAX;
          END IF;
        Else
          l_nr_tax_rate := 0;
        End if;
        /* dropshipment end */

        -------------------------------------------------------------
        -- Get the match_option from po_line_locations_all
        -- If match_option is P then exch rate has to be the rate at the time of PO
        -- If match_option is R then exch rate has to be the rate at the time of Receipt
        -------------------------------------------------------------

        l_stmt_num := 131;

        SELECT nvl(poll.match_option,'P')
        INTO   l_match_option
        FROM   po_line_locations_all poll,
               rcv_transactions rt7
        WHERE
               poll.line_location_id = rt7.po_line_location_id
        AND    rt7.transaction_id    = l_rec_transaction_id;


        -------------------------------------------------------------
        -- if po_line_id in POLL does not exist in POL !!
        -- this is due to corrupted data of a line_id in POLL not being in POL
        -------------------------------------------------------------

        l_stmt_num := 141;

        SELECT count(rt2.transaction_id)
        INTO   l_po_count
        FROM   rcv_transactions rt2,
               po_lines_all pol1,
               po_line_locations_all poll1
        WHERE  rt2.transaction_id = l_rec_transaction_id
        AND    rt2.po_line_location_id = poll1.line_location_id
        AND    pol1.po_line_id = poll1.po_line_id
        AND    ROWNUM < 2;

        IF l_po_count = 0 THEN
          l_stmt_num := 151;

          SELECT
              decode(l_rae_trf_price_flag, 2, l_rae_unit_price, (nvl(poll2.price_override,0) + l_nr_tax_rate)),
              rt3.po_line_location_id,
              nvl(get_rcv_rate(rt3.transaction_id),1) ,
              rsl.item_id,
              nvl(poll2.unit_meas_lookup_code,rsl.unit_of_measure),
              poll2.quantity,
              rt3.organization_id,
              nvl(poll2.matching_basis,'QUANTITY')    /* Bug4762808 */
          INTO
              l_po_price,
              l_po_line_loc,
              l_rate,
              l_item_id,
              l_po_uom_code,
              l_poll_quantity,
              l_org_id,
              l_order_type_lookup_code
          FROM
              rcv_transactions rt3,
              rcv_shipment_lines rsl,
              po_line_locations_all poll2
          WHERE
              rt3.transaction_id      = l_rec_transaction_id
          AND rt3.po_line_location_id = poll2.line_location_id
          AND rsl.shipment_line_id    = rt3.shipment_line_id;

        ELSE  -- l_po_count
        ------------------------------------------------------------
        -- Get Per Unit PO Price in terms of PO UOM
        -- Get PO Line Location Id, Item id, PO UOM, PO Quantity, org
        ------------------------------------------------------------

        -- price_override is based on PO UOM
        -- non_recoverable_tax is based on PO UOM so divide by PO quantity
        -- price_override in po currency
        -- non_recoverable_tax in po currency
        -- po_price will not be converted into functional currency now
        -- because we want to use the exch rate at time of receipt

          l_stmt_num := 66;

          SELECT
-- J Changes ---------------------------------------------------------------
              DECODE(POLL3.MATCHING_BASIS,
                          'AMOUNT', 1 + l_nr_tax_rate,
                          'QUANTITY',decode(l_rae_trf_price_flag, 2, l_rae_unit_price, (nvl(poll3.price_override,0) + l_nr_tax_rate))),
----------------------------------------------------------------------------
              rt33.po_line_location_id,
              rt33.unit_of_measure ,
              nvl(pol2.item_id,-1),
              nvl(poll3.unit_meas_lookup_code,pol2.unit_meas_lookup_code),
              poll3.quantity,
              rt33.organization_id,
              decode(nvl(poll3.match_option,'P'),
                        'P',get_po_rate(rt33.transaction_id),
                        'R',get_rcv_rate(rt33.transaction_id)),
              nvl(poll3.matching_basis,'QUANTITY')  /* Bug4762808 */
          INTO
              l_po_price,
              l_po_line_loc,
              l_rec_uom_code,
              l_item_id,
              l_po_uom_code,
              l_poll_quantity,
              l_org_id,
              l_rate,
              l_order_type_lookup_code
          FROM
              po_lines_all pol2,
              po_line_locations_all poll3,
              rcv_transactions rt33
          WHERE
              rt33.transaction_id      = l_rec_transaction_id
          AND rt33.po_line_location_id = poll3.line_location_id
          AND pol2.po_line_id = poll3.po_line_id;

        END IF; -- l_po_count

              IF (l_rate is null OR l_rate = -1) THEN
                RAISE CST_ACQ_NULL_RATE;
              END IF;

              l_stmt_num := 68;


        /* Bug 4762808 - Service Line Type POs do not have UOM and quantity populated.*/

       If l_order_type_lookup_code <> 'AMOUNT' then
        ------------------------------------------------------
        -- Get UOM code for PO UOM and REC UOM
        ------------------------------------------------------

              SELECT
              mum1.uom_code
              INTO
              l_po_uom
              FROM
              mtl_units_of_measure mum1
              WHERE
              MUM1.UNIT_OF_measure = l_po_uom_code;

             l_stmt_num := 71;

              SELECT
              mum1.uom_code
              INTO
              l_rec_uom
              FROM
              mtl_units_of_measure mum1
              WHERE
              mum1.unit_of_measure = l_rec_uom_code;

              l_stmt_num := 31;

        ---------------------------------------------------------
        -- Get Primary UOM for the Item for the org
        ---------------------------------------------------------

              IF l_item_id = -1 THEN
                l_primary_uom := l_po_uom;
              ELSE

               l_stmt_num := 76;

                SELECT
                msi.primary_uom_code
                INTO
                l_primary_uom
                FROM
                mtl_system_items msi
                WHERE
                msi.inventory_item_id = l_item_id AND
                msi.organization_id = l_org_id;
              END IF;

        ---------------------------------------------------------
        -- Convert PO Quantity into Primary Quantity
        ---------------------------------------------------------

              l_stmt_num := 79;

              l_pri_poll_quantity := inv_convert.inv_um_convert(
                  l_item_id,
                  NULL,
                  l_poll_quantity, -- PO quantity
                  l_po_uom,        -- PO UOM
                  l_primary_uom,   -- pri uom
                  NULL,
                  NULL);

        ---------------------------------------------------------
        -- PO per unit price in POLL is based on PO UOM
        -- Convert the price based on Primary UOM
        ---------------------------------------------------------

              l_po_price := l_po_price * l_poll_quantity / l_pri_poll_quantity;
           End if;

        --------------------------------------------------------
        -- 2.2 Insert inTO cst_rcV_ACQ_COSTS a row for the receipt
        --     for cost type, period, cost group
        --     setting quantity_invoiced, quantity_at_po_price,
        --     total_invoice_amount, amount_at_po_price, total_amount,
        --     costed_quantity, acqcuisition_cost to NULL for now
        --     These values will be updated later with the right values.
        ----------------------------------------------------------

              l_stmt_num := 81;

              Insert_into_acqhdr_tables(
              l_header,
              i_cost_group_id,
              i_cost_type_id,
              i_period,
              l_rec_transaction_id,
              l_nqr,  -- in pri uom
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              l_po_line_loc,
              l_po_price,  -- in po currency based on pri uom
              l_primary_uom,
              l_rate,      -- rate at time of receipt
              SYSDATE,
              i_user_id,
              SYSDATE,
              i_user_id,
              i_req_id,
              i_prog_appl_id,
              i_prog_id,
              SYSDATE,
              i_login_id,
              i_source_flag,
              l_err_num,
              l_err_msg);


        if (l_accounting_event_id = 0) then  --added for dropshipment project
        -------------------------------------------------------------
        -- 2.3 Get all posted Invoice lines from AP_INVOICE_DISTRIBUTIONS_ALL
        --     which are matched to the receipt
        --------------------------------------------------------------

              l_stmt_num := 86;

             Select NVL(restrict_doc_flag,2) into l_res_flag
             from CST_LE_COST_TYPES
             where legal_entity = l_legal_entity
             and cost_type_id = i_cost_type_id;

             l_stmt_num := 91;

              SELECT count(rcv_transaction_id)
              INTO   l_inv_count
              FROM   ap_invoice_distributions_all ad1
              WHERE  ad1.rcv_transaction_id = l_rec_transaction_id
	        AND  ad1.accounting_date <= l_end_date
		AND  ad1.posted_flag = 'Y' AND
              /* Invoice Lines Project TAX is now REC_TAX and NONREC_TAX */
              ad1.line_type_lookup_code <> 'REC_TAX' AND
              ROWNUM < 2;

        else
          l_inv_count := 0;
        end if;
        --------------------------------------------------------------
        -- 2.4 If there are invoices
        --  2.4.1 loop for each invoice dist line
        ---------------------------------------------------------------

         IF l_inv_count > 0 THEN
                DECLARE

                  CURSOR c_invoices IS
                  SELECT
                  ad2.invoice_distribution_id,
                  ad2.invoice_id,
-- J Changes ------------------------------------------------------------------
                  nvl(DECODE(POLL.MATCHING_BASIS, -- Changed for Complex work Procurement
                                 'AMOUNT', AD2.AMOUNT,
                                  'QUANTITY',ad2.quantity_invoiced), 0 ) "QUANTITY_INVOICED",   -- Invoice UOM
-------------------------------------------------------------------------------
                  ad2.distribution_line_number,
                  ad2.line_type_lookup_code,
-- J Changes ------------------------------------------------------------------
                  nvl(DECODE(POLL.MATCHING_BASIS,  -- Changed for Complex work Procurement
                                 'AMOUNT', 1,
                                 'QUANTITY', ad2.unit_price), 0 ) unit_price,    -- Invoice Currency
--------------------------------------------------------------------------------
                  nvl(ad2.base_amount, nvl(ad2.amount, 0)) base_amount
                  FROM
                  ap_invoice_distributions_all ad2,
-- J Changes -----------------------------------------------------------
                  RCV_TRANSACTIONS RT,
                  PO_LINES_ALL POL,
                  PO_LINE_LOCATIONS_ALL POLL,  -- Added for Complex work Procurement
                  ap_invoices_all aia   /* bug 4352624 Added to ignore invoices of type prepayment */
------------------------------------------------------------------------
                  WHERE
                       ad2.rcv_transaction_id = l_rec_transaction_id
                  AND  ad2.posted_flag        = 'Y'
                  /* bug 4352624 Added to ignore invoices of type prepayment */
                  AND ad2.line_type_lookup_code <>'PREPAY'
                  AND aia.invoice_id = ad2.invoice_id
                  AND aia.invoice_type_lookup_code <>'PREPAYMENT'

-- J Changes -----------------------------------------------------------
                  AND  RT.TRANSACTION_ID      = AD2.RCV_TRANSACTION_ID
                  AND  POL.PO_LINE_ID         = RT.PO_LINE_ID
                  AND  RT.PO_LINE_LOCATION_ID = POLL.LINE_LOCATION_ID
                  AND  POLL.PO_LINE_ID        = POL.PO_LINE_ID ---- Added for Complex work Procurement
------------------------------------------------------------------------
                  AND  ad2.accounting_date <= l_end_date
                  /* Invoice Lines Project TAX is now REC_TAX AND NONREC_TAX */
                  AND  ad2.line_type_lookup_code <> 'REC_TAX'
-- J Changes -------------------------------------------------------------
-- Ensure that Price corrections are not picked --
                  /* Invoice Lines Project root_distribution_id ->
                     corrected_invoice_dist_id */
                  AND  ad2.corrected_invoice_dist_id is null;
--------------------------------------------------------------------------
                  l_pri_quantity_invoiced NUMBER;
                  l_correction_amount     NUMBER;
                  l_corr_inv              NUMBER;
                  l_correction_tax_amount NUMBER;  /*Bug3891984*/
                  l_corr_invoice_id       NUMBER;  /*Bug3891984*/

         BEGIN
           FOR c_inv IN c_invoices LOOP
                    ---------------------------------------------------
                    -- Check if there are any Price Correction Invoices
                    -- And if so, get the correction amount
                    ---------------------------------------------------
                    IF G_DEBUG = 'Y' THEN
                      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Invoice: ' ||to_char(c_inv.INVOICE_DISTRIBUTION_ID));
                    END IF;

                    BEGIN
                      -----------------------------------------------------
                      -- The latest price correction invoice does not
                      -- have an Invoice of type 'ADJUSTMENT' that reverses
                      -- it out.
                      -- Refer AP HLD for Retroactive Pricing
                      -- Make sure that there are no distributions in AIDA
                      -- with xinv_parent_distribution_id = inv_dist_id of
                      -- of the price correction invoice
                      -----------------------------------------------------
                     -------------------------------------------------------------------
                      -- Bug 3891984 : Added the column invoice_id in the following select
                      -- statement. This invoice id will be required to pick up the
                      -- PO Price Adjustment invoices having LINE_TYPE_LOOKUP_CODE
                      -- as 'TAX' with TAX_RECOVERABLE_FLAG set to 'N'
                      -------------------------------------------------------------------

		      -- =====================================================================
		      -- FP Bug 7671918 fix: AP invoice corrections can be created with
		      -- invoice type 'CREDIT', 'DEBIT', 'STANDARD' along with PO PRICE ADJUST
		      -- We should not restrict the query only to PO PRICE ADJUST invoice type.
		      -- Also, AIDA.DIST_MATCH_TYPE = 'PRICE_CORRECTION'
		      -- We can sum up for the total correction amount of all such price
		      -- price correction AP invoice transactions.
		      -- Other than Non Recoverable Tax portion
                      -- ======================================================================

		      l_correction_amount := 0;

                      SELECT SUM(NVL(AIDA.BASE_AMOUNT, NVL(AIDA.AMOUNT, 0)))
                      INTO   l_correction_amount
                      FROM   AP_INVOICE_DISTRIBUTIONS_ALL AIDA,
                             AP_INVOICES_ALL AP_INV
                      /* Invoice Lines Project
                         No root_distribution_id or xinv_parent_reversal_id
                         now it'll just be represented by corrected_invoice_dist_id
                       */
                      WHERE  AIDA.CORRECTED_INVOICE_DIST_ID  = c_inv.INVOICE_DISTRIBUTION_ID
                      AND    AIDA.INVOICE_ID                 = AP_INV.INVOICE_ID
		      AND    AIDA.DIST_MATCH_TYPE            = 'PRICE_CORRECTION'
		      AND    AIDA.LINE_TYPE_LOOKUP_CODE      <> 'NONREC_TAX';

                      IF G_DEBUG = 'Y' THEN
		        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Correction Amount (from Price Correction Invoices): '||to_char(l_correction_amount));
                      END IF;

		       --============================================================
		       -- Bug 7671918 fix: AP Invoice price correction transactions
		       -- for which SUM of non recoverable tax amount of all such
		       -- AP price correction documents matching to parent AP invoice
		       -- distribution id
		       -- ===========================================================
                       l_correction_tax_amount := 0;
                        SELECT SUM(NVL(AIDA.BASE_AMOUNT, NVL(AIDA.AMOUNT, 0)))
                        INTO   l_correction_tax_amount
		        FROM   AP_INVOICE_DISTRIBUTIONS_ALL AIDA,
                               AP_INVOICES_ALL AP_INV
                        /* Invoice Lines Project
                           No root_distribution_id or xinv_parent_reversal_id
                           now it'll just be represented by corrected_invoice_dist_id
                         */
                        WHERE  AIDA.CORRECTED_INVOICE_DIST_ID  = c_inv.INVOICE_DISTRIBUTION_ID
                        AND    AIDA.INVOICE_ID                 = AP_INV.INVOICE_ID
		        AND    AIDA.DIST_MATCH_TYPE            = 'PRICE_CORRECTION'
		        AND    AIDA.LINE_TYPE_LOOKUP_CODE      = 'NONREC_TAX';

       		        IF G_DEBUG = 'Y' THEN
		          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Correction Tax Amount - Non Recoverable Tax(from Price Correction Invoices): '||to_char(l_correction_tax_amount));
                        END IF;

                        l_correction_amount:= nvl(l_correction_amount,0) + nvl(l_correction_tax_amount,0);

                    EXCEPTION
                      WHEN OTHERS THEN
                        l_correction_amount := 0;
			l_correction_tax_amount := 0;
		        RAISE;

                    END;

                    IF G_DEBUG = 'Y' THEN
		      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Total Correction Amount including Non Recoverable Tax(from Price Correction Invoices): '||to_char(l_correction_amount));
                    END IF;



             BEGIN

                    --------------------------------------------------------------
                    -- Convert Invoice Quantity into Primary Units
                    --------------------------------------------------------------

                      l_stmt_num := 96;

                      l_pri_quantity_invoiced := inv_convert.inv_um_convert(
                                                l_item_id,
                                                NULL,
                                                c_inv.quantity_invoiced,
                                                l_rec_uom,  -- inv uom same as rec when matched to receipt
                                                l_primary_uom,
                                                NULL,
                                                NULL);

                    ---------------------------------------------------------------
                    -- 2.4.1.1 Insert into CST_RCV_ACQ_COST_DETAILS table
                    ---------------------------------------------------------------

                      l_stmt_num := 101;

		    /* bug fix for bug 3411774. The acquisition cost considers the TAX twice if there is a
		    rcv_transaction_id against it and also if it is allocated to the ITEM lines.
		    So we should prevent insertion into the details table from the c_reciepts cursor as it will be
		    inserted into the details table later from the chrg_allocations cursor */

              l_chrg_present := 0;

              BEGIN

                /* Invoice Lines Project no more ap_chrg_allocations_all table */
                Select count(*) into l_chrg_present
                from  ap_invoice_distributions_all
                where invoice_distribution_id = c_inv.invoice_distribution_id
                and charge_applicable_to_dist_id is not null;

                EXCEPTION
                 WHEN OTHERS THEN
                 l_chrg_present := 0;

              END;

                If l_chrg_present = 0 then /* means that this has not been allocated */

                   select cst_rcv_acq_cost_details_s.nextval into l_details_nextvalue
                   from dual;

                   l_stmt_num := 106;

                   select decode(l_pri_quantity_invoiced,0,0,(c_inv.unit_price * c_inv.quantity_invoiced / l_pri_quantity_invoiced)) into l_priuom_cost
                   from dual;

                   l_stmt_num := 111;

                   Insert_into_acqdtls_tables (
                              l_header,
                              l_details_nextvalue,
                              'INVOICE',
                              NULL,
                              c_inv.invoice_distribution_id,
                              1,
                              0,
                              c_inv.invoice_distribution_id,
                              NULL,
                              NULL,
                              NULL,
                              c_inv.base_amount + l_correction_amount,  -- in func currency
                              l_pri_quantity_invoiced, -- in pri uom
			      l_priuom_cost,  -- convert to price based on pri uom
			      c_inv.line_type_lookup_code,
			      SYSDATE,
			      i_user_id,
			      SYSDATE,
			      i_user_id,
			      i_req_id,
			      i_prog_appl_id,
			      i_prog_id,
			      SYSDATE,
			      i_login_id,
			      i_source_flag,
			      l_err_num,
			      l_err_msg);

                End If; /* end of check for rows to be present in chrg allocations table */
                ------------------------------------------------------------
                -- 2.4.1.2 Get all special charge lines that are directly
                --         or indirectly allocated to the invoice lines
                --         (that are matched to the receipt)
                ------------------------------------------------------------

                      l_stmt_num := 121;

                      get_charge_allocs_for_acqadj(
                          l_header,
                          c_inv.invoice_distribution_id,
                          l_start_date,
                          l_end_date,
                          i_user_id,
                          i_login_id,
                          i_req_id,
                          i_prog_id,
                          i_prog_appl_id,
                          l_err_num,
                          l_err_code,
                          l_err_msg);

                      IF (l_err_num <> 0) THEN
                        RAISE CST_FAIL_GET_CHARGE_ALLOCS;
                      END IF;
             END;
           END LOOP;  -- Invoice loop
         END;
         END IF;   -- If Invoice count > 0

        --------------------------------------------------------
        -- 2.5 Compute the Acquisition Cost based on the info in CRACD
        --------------------------------------------------------

              l_stmt_num := 131;

              compute_acq_cost_acqadj(
                  l_header,
                  l_nqr,
                  l_po_line_loc,
                  l_po_price,
                  l_primary_uom,
                  l_rate,
                  l_po_uom,
                  l_item_id,
                  i_period,
                  i_cost_group_id,
                  l_org_id,
                  i_cost_type_id,
                  i_adj_account,
                  i_user_id,
                  i_login_id,
                  i_req_id,
                  i_prog_id,
                  i_prog_appl_id,
                  l_err_num,
                  l_err_code,
                  l_err_msg);


              IF (l_err_num <> 0) THEN
                RAISE CST_FAIL_COMPUTE_ACQ_COST;
              END IF;

            END IF; -- if hook was used

         END;


	 -- Added Perf bug# 5214447. Issuing intermediate commits after processing preset No. of rows.

	        IF l_recs_processed >= l_commit_records_count THEN
		        IF g_debug = 'Y' THEN
 	             fnd_file.put_line(fnd_file.LOG, ' 500 txns processed.... Issuing Commit ');
		        END IF;
 	            l_recs_processed := 0;
 	            COMMIT;
 	         END IF;

    -- Corresponding cursor fetch logic
    IF l_rcpt_flag_2 = 'Y'  THEN
      FETCH c_receipts_source_flag_2
       INTO l_rec_transaction_id;
         IF c_receipts_source_flag_2%FOUND THEN
           l_rcpt_flag_2 := 'Y';
         ELSE
           l_rcpt_flag_2 := 'N';
         END IF;
    ELSIF l_rcpt_flag_2_rcptid = 'Y' THEN
      FETCH c_receipts_src_flag_2_rcptid
       INTO l_rec_transaction_id;
         IF c_receipts_src_flag_2_rcptid%FOUND THEN
           l_rcpt_flag_2_rcptid := 'Y';
         ELSE
           l_rcpt_flag_2_rcptid := 'N';
         END IF;
    ELSIF l_rcpt_flag_2_invid = 'Y' THEN
      FETCH c_receipts_src_flag_2_invid
       INTO l_rec_transaction_id;
         IF c_receipts_src_flag_2_invid%FOUND THEN
           l_rcpt_flag_2_invid := 'Y';
         ELSE
           l_rcpt_flag_2_invid := 'N';
         END IF;
    END IF;

  END LOOP; -- Receipts loop for acquisition cost adjustment processor

  -- close the open cursors
    IF c_receipts_source_flag_2%ISOPEN THEN
      CLOSE c_receipts_source_flag_2;
    ELSIF c_receipts_src_flag_2_rcptid%ISOPEN THEN
      CLOSE c_receipts_src_flag_2_rcptid;
    ELSIF c_receipts_src_flag_2_invid%ISOPEN THEN
      CLOSE c_receipts_src_flag_2_invid;
    END IF;

    IF g_debug = 'Y' THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Acq_Cost_Adjustment_Processor >>>');
    END IF;

END IF; -- i_source_flag check


EXCEPTION
        WHEN CST_FAIL_GET_NQR THEN
          o_err_num := 30005;
          o_err_code := SQLCODE;
          FND_MESSAGE.set_name('BOM', 'CST_FAIL_GET_NQR');
          o_err_msg := FND_MESSAGE.Get;
        WHEN CST_FAIL_GET_CHARGE_ALLOCS THEN
          o_err_num := 30007;
          o_err_code := SQLCODE;
          FND_MESSAGE.set_name('BOM', 'CST_FAIL_GET_CHARGE_ALLOCS');
          o_err_msg := FND_MESSAGE.Get;
          o_err_msg := l_err_msg||' : ' ||o_err_msg;
        WHEN CST_FAIL_COMPUTE_ACQ_COST THEN
          o_err_num := 30008;
          o_err_code := SQLCODE;
          FND_MESSAGE.set_name('BOM', 'CST_FAIL_COMPUTE_ACQ_COST');
          o_err_msg := FND_MESSAGE.Get;
          o_err_msg := l_err_msg||' : ' ||o_err_msg;
        WHEN CST_FAIL_ACQ_HOOK THEN
          o_err_num := 30004;
          o_err_code := SQLCODE;
          FND_MESSAGE.set_name('BOM', 'CST_FAIL_ACQ_HOOK');
          o_err_msg := FND_MESSAGE.Get;
        WHEN CST_FAIL_LCM_HOOK THEN
          o_err_num := 30015;
          o_err_code := SQLCODE;
          FND_MESSAGE.set_name('BOM', 'CST_FAIL_LCM_HOOK');
          o_err_msg := FND_MESSAGE.Get;
        WHEN CST_ACQ_NULL_RATE THEN
          o_err_num := 30010;
          o_err_code := SQLCODE;
          FND_MESSAGE.set_name('BOM', 'CST_ACQ_NULL_RATE');
          o_err_msg := FND_MESSAGE.Get;
        WHEN CST_ACQ_NULL_TAX THEN
          o_err_num := 30011;
          o_err_code := SQLCODE;
          FND_MESSAGE.set_name('BOM', 'CST_ACQ_NULL_TAX');
          o_err_msg := FND_MESSAGE.Get;
	WHEN PROCESS_ERROR THEN
	  o_err_num := l_err_num;
	  o_err_code := l_err_code;
	  o_err_msg := l_err_msg;
        WHEN OTHERS THEN
          o_err_num := 30009;
          o_err_code := SQLCODE;
          o_err_msg := SUBSTR('CSTPPACQ.acq_cost_processor('
                        ||to_char(l_stmt_num)
                        ||'):'
                        ||SQLERRM,1,240);

END acq_cost_processor;


------------------------------------------------------------
-- FUNCTION
--   Get_Nqr
-- DESCRIPTION
--   Function returns the Net Quantity Received taking into
--   account returns, corrections etc for a parent receipt.
--
--   Modified 11i.10 to support Service Line Types.
--   Function now returns net Quantity or Amount for a given
--   transaction depending on the PO line type associated
--   with the transaction.
-------------------------------------------------------------

FUNCTION get_nqr(
        i_transaction_id        IN         NUMBER,
        i_source_flag           IN      NUMBER,
        i_start_date            IN      DATE,
        i_end_date              IN      DATE,
        i_res_flag              IN      NUMBER,
        o_err_num               OUT NOCOPY        NUMBER)
RETURN NUMBER
IS
----------------------------------------------------
-- Get all child transactions level by level
-----------------------------------------------------

 CURSOR c_net_amount IS
   SELECT RT.TRANSACTION_ID,
          RT.TRANSACTION_TYPE,
          RT.AMOUNT,
          RT.PARENT_TRANSACTION_ID
   FROM   RCV_TRANSACTIONS RT
   WHERE  ( (   (i_source_flag = 1)
            AND ( (   (i_res_flag =1)
                  AND (rt.transaction_date between i_start_date and i_end_date))
                OR  (i_res_flag = 2)))
          OR ( ( i_source_flag = 2 ) AND (rt.transaction_date <= i_end_date ) ) )
   START WITH
   RT.transaction_id       = i_transaction_id
   CONNECT BY
   PRIOR RT.transaction_id = RT.parent_transaction_id;

  CURSOR c_nqr is
  SELECT
         rt4.transaction_id,
         rt4.transaction_type,
         rt4.primary_quantity,
         rt4.quantity,/* ADDED FOR #BUG6697382*/
         rt4.parent_transaction_id
  FROM
         rcv_transactions rt4
  WHERE
        (((i_source_flag = 1) AND (((i_res_flag =1) AND (rt4.transaction_date between i_start_date and i_end_date)) OR (i_res_flag = 2))) OR ((i_source_flag = 2 ) AND (rt4.transaction_date <= i_end_date)))
  START WITH
        rt4.transaction_id = i_transaction_id
  CONNECT BY
        prior rt4.transaction_id = rt4.parent_transaction_id;

  l_nqr                 NUMBER := 0;
  l_actual_nqr          NUMBER:=0;/* ADDED FOR #BUG6679382*/
  l_po_line_type_code   VARCHAR2(25);
  l_parent_type         rcv_transactions.transaction_type%TYPE;
  l_stmt_num            NUMBER := 0;
BEGIN

        ---------------------------------------------------------
        -- Initialize error variable
        ---------------------------------------------------------

        o_err_num := 0;

        IF g_debug = 'Y' THEN
           FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_NQR <<< ');
        END IF;
        -------------------------------------------
        -- Determine if PO is for Service Line Type
        -------------------------------------------

        l_stmt_num := 10;

        SELECT NVL(POLL.MATCHING_BASIS, POL.MATCHING_BASIS)  -- Changed for Complex work Procurement
        INTO   L_PO_LINE_TYPE_CODE
        FROM   PO_LINES_ALL POL,
               PO_LINE_LOCATIONS_ALL POLL, -- Added for Complex work Procurement
               RCV_TRANSACTIONS RT
        WHERE  POL.PO_LINE_ID    = RT.PO_LINE_ID
        AND    POLL.LINE_LOCATION_ID   = RT.PO_LINE_LOCATION_ID-- Added for Complex work Procurement
        AND    RT.TRANSACTION_ID = I_TRANSACTION_ID;

        IF L_PO_LINE_TYPE_CODE = 'AMOUNT'  THEN
          -- Service Line Types
          FOR c_amount_rec in c_net_amount loop
            IF c_amount_rec.transaction_id <> i_transaction_id THEN

              l_stmt_num := 20;

              SELECT transaction_type
              INTO   l_parent_type
              FROM   rcv_transactions
              WHERE  transaction_id = c_amount_rec.parent_transaction_id;
            END IF;

            IF c_amount_rec.transaction_id = i_transaction_id THEN
              l_nqr := l_nqr + c_amount_rec.amount;
            ELSIF c_amount_rec.transaction_type = 'CORRECT' then
              IF l_parent_type = 'RECEIVE' OR
                 l_parent_type = 'MATCH' THEN
                l_nqr := l_nqr + c_amount_rec.amount;
              ELSIF l_parent_type = 'RETURN TO VENDOR' then
                l_nqr := l_nqr - c_amount_rec.amount;
              END IF;
            ELSIF c_amount_rec.transaction_type = 'RETURN TO VENDOR' then
              l_nqr := l_nqr - c_amount_rec.amount;
            END IF;
          END LOOP; -- child txns loop

        ELSE -- Other Line Types (Not Service)
          --------------------------------------------------------
          -- For each child transaction loop
          --------------------------------------------------------
          FOR c_nqr_rec in c_nqr loop
          --------------------------------------------------------
          --  If it is not the parent (that was passed in) transaction itself
          --------------------------------------------------------
            IF c_nqr_rec.transaction_id <> i_transaction_id THEN
              ----------------------------------------------------------
              --  Get the parent transaction type
              ----------------------------------------------------------
              l_stmt_num := 30;
              SELECT
              rt5.transaction_type
              INTO
              l_parent_type
              FROM
              rcv_transactions rt5
              WHERE
              rt5.transaction_id = c_nqr_rec.parent_transaction_id;
            END IF;

            ------------------------------------------------------------
            -- If it is the parent receive or match transaction
            -- then add the quantity to l_nqr
            ------------------------------------------------------------
            l_stmt_num := 30;

            IF c_nqr_rec.transaction_id = i_transaction_id THEN
              l_nqr := l_nqr + c_nqr_rec.primary_quantity;
              l_actual_nqr := l_actual_nqr + c_nqr_rec.quantity;/* ADDED FOR #BUG6697382*/
              -----------------------------------------------------------
              -- If the transaction is CORRECT,
              -- If parent is receive or match txn, then add the corrected qty
              -- If parent is return, then subtract the corrected qty
              -----------------------------------------------------------
            ELSIF c_nqr_rec.transaction_type = 'CORRECT' then
              IF l_parent_type = 'RECEIVE' OR
                 l_parent_type = 'MATCH' THEN
                l_nqr := l_nqr + c_nqr_rec.primary_quantity;
                l_actual_nqr := l_actual_nqr + c_nqr_rec.quantity;/* ADDED FOR #BUG6697382*/
              ELSIF l_parent_type = 'RETURN TO VENDOR' then
                l_nqr := l_nqr - c_nqr_rec.primary_quantity;
                l_actual_nqr := l_actual_nqr - c_nqr_rec.quantity;/* ADDED FOR #BUG6697382*/
              END IF;
            ----------------------------------------------------------
            -- If transaction is return transaction, then subtract returned qty
            ----------------------------------------------------------
            ELSIF c_nqr_rec.transaction_type = 'RETURN TO VENDOR' then
              l_nqr := l_nqr - c_nqr_rec.primary_quantity;
	      l_actual_nqr := l_actual_nqr - c_nqr_rec.quantity;/* ADDED FOR #BUG6697382*/

            END IF;
          END LOOP; -- child txns loop

         /* ADDED If condition for  #BUG6697382*/
           IF(l_actual_nqr=0) THEN
                l_nqr:=0;
           END IF;
        END IF; -- Line Types
        --------------------------------------------------------
        -- Return the net quantity received as calculated
        --------------------------------------------------------

        IF g_debug = 'Y' THEN
           FND_FILE.PUT_LINE(FND_FILE.LOG, 'Net Quantity/Amount: '||to_char(l_nqr));
           FND_FILE.PUT_LINE(FND_FILE.LOG, 'GET_NQR >>> ');
        END IF;
        RETURN (l_nqr);
EXCEPTION
        WHEN OTHERS THEN
          o_err_num := 30006;
END get_nqr;

PROCEDURE get_charge_allocs (
        i_hdr           IN         NUMBER,
        i_item_dist     IN         NUMBER,
        i_start_date    IN      DATE,
        i_end_date      IN      DATE,
        i_res_flag      IN      NUMBER,
        i_user_id       IN        NUMBER,
        i_login_id      IN        NUMBER,
        i_req_id        IN        NUMBER,
        i_prog_id       IN        NUMBER,
        i_prog_appl_id  IN        NUMBER,
        o_err_num               OUT NOCOPY     NUMBER,
        o_err_code              OUT NOCOPY     VARCHAR2,
        o_err_msg               OUT NOCOPY     VARCHAR2)
IS
        l_imm_parent    NUMBER;
        l_factor        NUMBER := 1;
        l_prev_weight   NUMBER;
        l_chg_count     NUMBER;
        l_stmt_num      NUMBER := 0;
BEGIN

        -----------------------------------------------------
        -- Initialize error variables
        ----------------------------------------------------

        o_err_num := 0;
        o_err_code := '';
        o_err_msg := '';

        l_stmt_num := 10;

        -------------------------------------------------------
        -- Check if any allocations (both parent and child should be posted)
        -------------------------------------------------------
        /* Invoice Lines Project
            No more ap_chrg_allocations_all table.  Now need to get all information
            through ap_invoice_distributions_all.  To determine if a distribution is a
            charge, just examine whether the charge_applicable_to_dist_id is not null
         */
        SELECT  count(1)
        INTO    l_chg_count
        FROM    ap_invoice_distributions_all aida
        WHERE   aida.posted_flag = 'Y'
          AND   (((i_res_flag = 1)
                AND (aida.accounting_date BETWEEN i_start_date AND i_end_Date))
                 OR (i_res_flag = 2))
          AND   aida.line_type_lookup_code <> 'REC_TAX'
          AND EXISTS (
          SELECT 'X'
          FROM ap_invoice_distributions_all aida2
          WHERE aida2.invoice_distribution_id = aida.charge_applicable_to_dist_id
          AND   aida2.posted_flag = 'Y'
          AND   (((i_res_flag = 1)
                AND (aida2.accounting_date BETWEEN i_start_date AND i_end_Date))
                 OR (i_res_flag = 2))
          AND   aida2.line_type_lookup_code <> 'REC_TAX'
          )
          START WITH
          aida.charge_applicable_to_dist_id = i_item_dist
          CONNECT BY
          prior aida.invoice_distribution_id  = aida.charge_applicable_to_dist_id;

        ----------------------------------------------------------
        -- If any, then process
        ---------------------------------------------------------

        IF l_chg_count > 0 THEN

          l_stmt_num := 20;

        -------------------------------------------------------------
        -- Insert into CRACD all allocations level by level
        -------------------------------------------------------------
        /* Invoice Lines Project
            No more ap_chrg_allocations_all table.  Now need to get all information
            through ap_invoice_distributions_all.  To determine if a distribution is a
            charge, just examine whether the charge_applicable_to_dist_id is not null
         */

          INSERT INTO
          cst_rcv_acq_cost_details  (  -- cracd2
          HEADER_ID,
          DETAIL_ID,
          SOURCE_TYPE,
          PO_LINE_LOCATION_ID,
          PARENT_DISTRIBUTION_ID,
          DISTRIBUTION_NUM,
          LEVEL_NUM,
          INVOICE_DISTRIBUTION_ID,
          PARENT_INVOICE_DIST_ID,
          ALLOCATED_AMOUNT,
          PARENT_AMOUNT,
          AMOUNT,
          QUANTITY,
          PRICE,
          LINE_TYPE,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          REQUEST_ID,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          PROGRAM_UPDATE_DATE,
          LAST_UPDATE_LOGIN
          )
          SELECT
          i_hdr,
          cst_rcv_acq_cost_details_s.nextval,
          'INVOICE',
          NULL,
          i_item_dist,
          rownum + 1,
          LEVEL,
          aida.invoice_distribution_id,
          aida.charge_applicable_to_dist_id,
          nvl(aida.base_amount,nvl(aida.amount,0)) base_amount,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          SYSDATE,
          i_user_id,
          SYSDATE,
          i_user_id,
          i_req_id,
          i_prog_appl_id,
          i_prog_id,
          SYSDATE,
          i_login_id
          FROM
          ap_invoice_distributions_all aida
          WHERE aida.posted_flag = 'Y'
          AND   (((i_res_flag = 1) AND (aida.accounting_date BETWEEN i_start_date AND i_end_Date))
                 OR (i_res_flag = 2))
          AND   aida.line_type_lookup_code <> 'REC_TAX'
          AND EXISTS (
          SELECT 'X'
          FROM ap_invoice_distributions_all aida2
          WHERE aida2.invoice_distribution_id = aida.charge_applicable_to_dist_id
          AND   aida2.posted_flag = 'Y'
          AND   (((i_res_flag = 1) AND (aida2.accounting_date BETWEEN i_start_date AND i_end_Date))
                 OR (i_res_flag = 2))
          AND   aida2.line_type_lookup_code <> 'REC_TAX'
          )
          START WITH
          aida.charge_applicable_to_dist_id = i_item_dist
          CONNECT BY
          prior aida.invoice_distribution_id  = aida.charge_applicable_to_dist_id;

          l_stmt_num := 30;

        ----------------------------------------------------------
        -- Get the parent amount from the AP_INVOICE_DISTRIBUTIONS_ALL table
        -- and also the LINE TYPE
        -- and update the CRACD rows just created
        ----------------------------------------------------------

          UPDATE
          cst_rcv_acq_cost_details cracd3
          SET
          cracd3.parent_amount = (
            SELECT
            nvl(ad7.base_amount,nvl(ad7.amount,0))
            FROM
            ap_invoice_distributions_all ad7
            WHERE
            ad7.invoice_distribution_id = cracd3.parent_invoice_dist_id) ,
          cracd3.line_type = (
            SELECT
            ad8.line_type_lookup_code
            FROM
            ap_invoice_distributions_all ad8
            WHERE
            ad8.invoice_distribution_id = cracd3.invoice_distribution_id)
          WHERE
          cracd3.parent_invoice_dist_id IS NOT NULL AND
          cracd3.invoice_distribution_id IS NOT NULL AND
          cracd3.parent_distribution_id = i_item_dist AND
          cracd3.header_id = i_hdr;

          l_stmt_num := 40;

        -----------------------------------------------------------
        -- Set amount as allocated amount for the level 1 lines
        -- since the whole allocated amount goes to level 0
        -- for other levels, the portion that goes to previous level
        -- is determined by the number of parents it has
        -----------------------------------------------------------
          /* Invoice Lines Project
                In the new model, all charges are 100% allocated to its parent so
                the amount and allocated amount columns are identical
           */

/* bug 4965847  changed query to join with parent_invoice_dist_id rather than parent_distribution_id*/

          UPDATE
          cst_rcv_acq_cost_details cracd4
          SET
          cracd4.amount = cracd4.allocated_amount -- amount in func curr
          WHERE
          cracd4.header_id = i_hdr AND
          cracd4.PARENT_INVOICE_DIST_ID = i_item_dist;

        -------------------------------------------------------
        -- Loop for all the rows inserted
        ------------------------------------------------------
  /*      Invoice Lines Project
          The rest of this code tries to figure out the allocation percentages of charges
          to their parents.  In the new model, charges are 100% allocated to their parent so
          there is no need to perform these calculations */
        END IF; -- If charge allocations exist

EXCEPTION
        WHEN OTHERS THEN
        o_err_num := 30001;
        o_err_code := SQLCODE;
        o_err_msg := SUBSTR('CSTPPACQ.get_charge_allocs('
                        ||to_char(l_stmt_num)
                        ||'):'
                        ||SQLERRM,1,240);
END get_charge_allocs;



Procedure get_charge_allocs_for_acqadj(
        i_hdr           IN         NUMBER,
        i_item_dist     IN         NUMBER,
        l_start_date    IN      DATE,
        l_end_date      IN      DATE,
        i_user_id       IN        NUMBER,
        i_login_id      IN        NUMBER,
        i_req_id        IN        NUMBER,
        i_prog_id       IN        NUMBER,
        i_prog_appl_id  IN        NUMBER,
        o_err_num               OUT NOCOPY     NUMBER,
        o_err_code              OUT NOCOPY     VARCHAR2,
        o_err_msg               OUT NOCOPY     VARCHAR2)
IS
        l_imm_parent    NUMBER;
        l_factor        NUMBER := 1;
        l_prev_weight   NUMBER;
        l_chg_count     NUMBER;
        l_stmt_num      NUMBER := 0;
BEGIN

        -----------------------------------------------------
        -- Initialize error variables
        ----------------------------------------------------

        o_err_num := 0;
        o_err_code := '';
        o_err_msg := '';

        l_stmt_num := 10;

        -------------------------------------------------------
        -- Check if any allocations (both parent and child should be posted)
        -------------------------------------------------------
        /* Invoice Lines Project
            No more ap_chrg_allocations_all table.  Now need to get all information
            through ap_invoice_distributions_all.  To determine if a distribution is a
            charge, just examine whether the charge_applicable_to_dist_id is not null
         */

        SELECT
        count(1)
        INTO
        l_chg_count
        FROM
        ap_invoice_distributions_all aida
        WHERE   aida.posted_flag = 'Y'
          AND   aida.accounting_date <= l_end_date
          AND   aida.line_type_lookup_code <> 'REC_TAX'
          AND EXISTS (
          SELECT 'X'
          FROM ap_invoice_distributions_all aida2
          WHERE aida2.invoice_distribution_id = aida.charge_applicable_to_dist_id
          AND   aida2.posted_flag = 'Y'
          AND   aida2.accounting_date <= l_end_date
          AND   aida2.line_type_lookup_code <> 'REC_TAX'
          )
          START WITH
          aida.charge_applicable_to_dist_id = i_item_dist
          CONNECT BY
          prior aida.invoice_distribution_id  = aida.charge_applicable_to_dist_id;

        ----------------------------------------------------------
        -- If any, then process
        ---------------------------------------------------------


        IF l_chg_count > 0 THEN

          l_stmt_num := 20;

        -------------------------------------------------------------
        -- Insert into CRACD all allocations level by level
        -------------------------------------------------------------
        /* Invoice Lines Project
            No more ap_chrg_allocations_all table.  Now need to get all information
            through ap_invoice_distributions_all.  To determine if a distribution is a
            charge, just examine whether the charge_applicable_to_dist_id is not null
         */

          INSERT INTO
          cst_rcv_acq_cost_details_adj  (  -- cracd2
          HEADER_ID,
          DETAIL_ID,
          SOURCE_TYPE,
          PO_LINE_LOCATION_ID,
          PARENT_DISTRIBUTION_ID,
          DISTRIBUTION_NUM,
          LEVEL_NUM,
          INVOICE_DISTRIBUTION_ID,
          PARENT_INVOICE_DIST_ID,
          ALLOCATED_AMOUNT,
          PARENT_AMOUNT,
          AMOUNT,
          QUANTITY,
          PRICE,
          LINE_TYPE,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          REQUEST_ID,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          PROGRAM_UPDATE_DATE,
          LAST_UPDATE_LOGIN
          )
          SELECT
          i_hdr,
          cst_rcv_acq_cost_details_s.nextval,
          'INVOICE',
          NULL,
          i_item_dist,
          rownum + 1,
          LEVEL,
          aida.invoice_distribution_id,
          aida.charge_applicable_to_dist_id,
          nvl(aida.base_amount,nvl(aida.amount,0)) base_amount,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          SYSDATE,
          i_user_id,
          SYSDATE,
          i_user_id,
          i_req_id,
          i_prog_appl_id,
          i_prog_id,
          SYSDATE,
          i_login_id
          FROM
          ap_invoice_distributions_all aida
          WHERE aida.posted_flag = 'Y'
          AND   aida.accounting_date <= l_end_date
          AND   aida.line_type_lookup_code <> 'REC_TAX'
          AND EXISTS (
          SELECT 'X'
          FROM ap_invoice_distributions_all aida2
          WHERE aida2.invoice_distribution_id = aida.charge_applicable_to_dist_id
          AND   aida2.posted_flag = 'Y'
          AND   aida2.accounting_date <= l_end_date
          AND   aida2.line_type_lookup_code <> 'REC_TAX'
          )
          START WITH
          aida.charge_applicable_to_dist_id = i_item_dist
          CONNECT BY
          prior aida.invoice_distribution_id  = aida.charge_applicable_to_dist_id;

          l_stmt_num := 30;

        ----------------------------------------------------------
        -- Get the parent amount from the AP_INVOICE_DISTRIBUTIONS_ALL table
        -- and also the LINE TYPE
        -- and update the CRACD rows just created
        ----------------------------------------------------------


          UPDATE
          cst_rcv_acq_cost_details_adj cracd3
          SET
          cracd3.parent_amount = (
            SELECT
            nvl(ad7.base_amount,nvl(ad7.amount,0))
            FROM
            ap_invoice_distributions_all ad7
            WHERE
            ad7.invoice_distribution_id = cracd3.parent_invoice_dist_id) ,
          cracd3.line_type = (
            SELECT
            ad8.line_type_lookup_code
            FROM
            ap_invoice_distributions_all ad8
            WHERE
            ad8.invoice_distribution_id = cracd3.invoice_distribution_id)
          WHERE
          cracd3.parent_invoice_dist_id IS NOT NULL AND
          cracd3.invoice_distribution_id IS NOT NULL AND
          cracd3.parent_distribution_id = i_item_dist AND
          cracd3.header_id = i_hdr;

          l_stmt_num := 40;

        -----------------------------------------------------------
        -- Set amount as allocated amount for the level 1 lines
        -- since the whole allocated amount goes to level 0
        -- for other levels, the portion that goes to previous level
        -- is determined by the number of parents it has
        -----------------------------------------------------------
          /* Invoice Lines Project
                In the new model, all charges are 100% allocated to its parent so
                the amount and allocated amount columns are identical
           */

/* bug 4965847  changed query to join with parent_invoice_dist_id rather than parent_distribution_id*/

          UPDATE
          cst_rcv_acq_cost_details_adj cracd4
          SET
          cracd4.amount = cracd4.allocated_amount -- amount in func curr
          WHERE
          cracd4.header_id = i_hdr AND
          cracd4.PARENT_INVOICE_DIST_ID = i_item_dist;

        -------------------------------------------------------
        -- Loop for all the rows inserted
        ------------------------------------------------------
  /*      Invoice Lines Project
          The rest of this code tries to figure out the allocation percentages of charges
          to their parents.  In the new model, charges are 100% allocated to their parent so
          there is no need to perform these calculations */
        END IF; -- If charge allocations exist

EXCEPTION
        WHEN OTHERS THEN
        o_err_num := 30001;
        o_err_code := SQLCODE;
        o_err_msg := SUBSTR('CSTPPACQ.get_charge_allocs_for_acqadj('
                        ||to_char(l_stmt_num)
                        ||'):'
                        ||SQLERRM,1,240);
END get_charge_allocs_for_acqadj;



PROCEDURE compute_acq_cost (
        i_header        IN         NUMBER,
        i_nqr           IN         NUMBER,
        i_po_line_loc   IN        NUMBER,
        i_po_price      IN        NUMBER,
        i_primary_uom   IN        VARCHAR2,
        i_rate          IN        NUMBER,
        i_po_uom        IN        VARCHAR2,
        i_item          IN        NUMBER,
        i_user_id       IN        NUMBER,
        i_login_id      IN        NUMBER,
        i_req_id        IN        NUMBER,
        i_prog_id       IN        NUMBER,
        i_prog_appl_id  IN        NUMBER,
        o_err_num               OUT NOCOPY     NUMBER,
        o_err_code              OUT NOCOPY     VARCHAR2,
        o_err_msg               OUT NOCOPY     VARCHAR2)
IS
        l_total_invoice_amount  cst_rcv_acq_cost_details.amount%TYPE;
        l_qty_invoiced          cst_rcv_acq_cost_details.quantity%TYPE;
        l_qty_at_po             cst_rcv_acq_cost_details.quantity%TYPE;
        l_costed_quantity       cst_rcv_acq_cost_details.quantity%TYPE;
        l_amount_at_po          cst_rcv_acq_cost_details.amount%TYPE;
        l_total_amount          cst_rcv_acq_cost_details.amount%TYPE;
        l_acq_cost              cst_rcv_acq_costs.acquisition_cost%TYPE;
        l_cracd_count           NUMBER := 0;
        l_stmt_num              NUMBER := 0;
        CST_NULL_ACQ_COST       EXCEPTION;
BEGIN

        --------------------------------------------------------
        -- Initialize error variables
        ---------------------------------------------------------

        o_err_num := 0;
        o_err_code := '';
        o_err_msg := '';

        l_stmt_num := 10;

        ---------------------------------------------------------
        -- Check if any rows in CRACD for the header
        -- If there are none, that means no invoices were matched to receipt
        -- acq cost will be PO price
        -- If there are some, then invoices were matched and acq cost will
        -- be a combination of PO and invoice price
        -----------------------------------------------------------

        SELECT count(header_id)
        INTO   l_cracd_count
        FROM   cst_rcv_acq_cost_details cracd9
        WHERE  cracd9.header_id = i_header
        AND    ROWNUM < 2;

        -------------------------------------------------------------
        -- If invoices were matched
        ------------------------------------------------------------

        IF l_cracd_count > 0 THEN

          l_stmt_num := 20;

        ----------------------------------------------------------
        -- Get total invoice amount
        ---------------------------------------------------------

          SELECT
          SUM(cracd10.amount)
          INTO
          l_total_invoice_amount
          FROM
          cst_rcv_acq_cost_details cracd10
          WHERE
          cracd10.header_id = i_header;

        ----------------------------------------------------------
        -- Get total invoice quantity
        ---------------------------------------------------------

          l_stmt_num := 25;

          SELECT
          SUM(nvl(cracd11.quantity,0))
          INTO
          l_qty_invoiced
          FROM
          cst_rcv_acq_cost_details cracd11
          WHERE
          cracd11.header_id = i_header;

        ELSE

        --------------------------------------------------------------
        -- Set Total Invoice amount and quantity to zero
        --------------------------------------------------------------

          l_total_invoice_amount := 0;
          l_qty_invoiced := 0;

        END IF;

        -------------------------------------------------------------
        -- If total invoice quantity is greater than the net qty recd,
        -- then acq cost is to be calculated based on invoice quantity
        -- else acq cost is to be calculated based on net qty recd
        -------------------------------------------------------------
        IF l_qty_invoiced > i_nqr THEN
          l_qty_at_po := 0;
          l_costed_quantity := l_qty_invoiced;
        ELSE
          l_qty_at_po := i_nqr - l_qty_invoiced;
          l_costed_quantity := i_nqr;
        END IF;

        --------------------------------------------------------------
        -- Calculate amount at po, total amount and acq cost
        --------------------------------------------------------------

        l_amount_at_po := l_qty_at_po * i_po_price * i_rate; -- po price in pri
        l_total_amount := l_total_invoice_amount + l_amount_at_po;
        IF l_costed_quantity = 0 THEN
          l_acq_cost := i_po_price * i_rate;  /* changed for bug 3090599 */
        ELSE
          l_acq_cost := l_total_amount / l_costed_quantity;
        END IF;

        l_stmt_num := 30;


        ----------------------------------------------------------------
        -- Check if acquisition cost is null
        ---------------------------------------------------------------

        IF (l_acq_cost is null) THEN
          RAISE CST_NULL_ACQ_COST;
        END IF;
        -----------------------------------------------------------------
        -- update CRACD with the calculated values
        ----------------------------------------------------------------

        l_stmt_num := 28;

        UPDATE
        cst_rcv_acq_costs crac2
        SET
        crac2.total_invoice_amount = l_total_invoice_amount,
        crac2.total_quantity_invoiced = l_qty_invoiced,
        crac2.quantity_at_po_price = l_qty_at_po,
        crac2.amount_at_po_price = l_amount_at_po,
        crac2.total_amount = l_total_amount,
        crac2.costed_quantity = l_costed_quantity,
        crac2.acquisition_cost = l_acq_cost
        WHERE
        crac2.header_id = i_header;

        --------------------------------------------------------------
        -- If the qty at po was not zero, then insert a row for source type PO
        --------------------------------------------------------------

        IF l_qty_at_po <> 0 THEN

          l_stmt_num := 40;

          INSERT INTO
          cst_rcv_acq_cost_details (   --cracd12
          HEADER_ID,
          DETAIL_ID,
          SOURCE_TYPE,
          PO_LINE_LOCATION_ID,
          PARENT_DISTRIBUTION_ID,
          DISTRIBUTION_NUM,
          LEVEL_NUM,
          INVOICE_DISTRIBUTION_ID,
          PARENT_INVOICE_DIST_ID,
          ALLOCATED_AMOUNT,
          PARENT_AMOUNT,
          AMOUNT,
          QUANTITY,
          PRICE,
          LINE_TYPE,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          REQUEST_ID,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          PROGRAM_UPDATE_DATE,
          LAST_UPDATE_LOGIN
          )
          VALUES (
          i_header,
          cst_rcv_acq_cost_details_s.nextval,
          'PO',
          i_po_line_loc,
          NULL,
          -1,
          0,
          NULL,
          NULL,
          NULL,
          NULL,
          l_amount_at_po,
          l_qty_at_po,
          i_po_price,
          NULL,
          SYSDATE,
          i_user_id,
          SYSDATE,
          i_user_id,
          i_req_id,
          i_prog_appl_id,
          i_prog_id,
          SYSDATE,
          i_login_id);
        END IF;

EXCEPTION
        WHEN CST_NULL_ACQ_COST THEN
        o_err_num := 30014;
        o_err_code := SQLCODE;
        FND_MESSAGE.set_name('BOM', 'CST_NULL_ACQ_COST');
        o_err_msg := FND_MESSAGE.Get;
        WHEN OTHERS THEN
        o_err_num := 30002;
        o_err_code := SQLCODE;
        o_err_msg := SUBSTR('CSTPPACQ.compute_acq_cost('
                        ||to_char(l_stmt_num)
                        ||'):'
                        ||SQLERRM,1,240);

END compute_acq_cost;


Procedure compute_acq_cost_acqadj(
        i_header        IN      NUMBER,
        i_nqr           IN      NUMBER,
        i_po_line_loc   IN      NUMBER,
        i_po_price      IN      NUMBER,
        i_primary_uom   IN      VARCHAR2,
        i_rate          IN      NUMBER,
        i_po_uom        IN      VARCHAR2,
        i_item          IN      NUMBER,
        i_pac_period_id IN      NUMBER,
        i_cost_group_id IN      NUMBER,
        i_org_id        IN      NUMBER,
        i_cost_type_id  IN      NUMBER,
        i_adj_account   IN      NUMBER,
        i_user_id       IN      NUMBER,
        i_login_id      IN      NUMBER,
        i_req_id        IN      NUMBER,
        i_prog_id       IN      NUMBER,
        i_prog_appl_id  IN      NUMBER,
        o_err_num               OUT NOCOPY     NUMBER,
        o_err_code              OUT NOCOPY     VARCHAR2,
        o_err_msg               OUT NOCOPY     VARCHAR2)
IS
        l_total_invoice_amount  cst_rcv_acq_cost_details_adj.amount%TYPE;
        l_qty_invoiced          cst_rcv_acq_cost_details_adj.quantity%TYPE;
        l_qty_at_po             cst_rcv_acq_cost_details_adj.quantity%TYPE;
        l_costed_quantity       cst_rcv_acq_cost_details_adj.quantity%TYPE;
        l_amount_at_po          cst_rcv_acq_cost_details_adj.amount%TYPE;
        l_total_amount          cst_rcv_acq_cost_details_adj.amount%TYPE;
        l_acq_cost              cst_rcv_acq_costs_adj.acquisition_cost%TYPE;
        l_cracd_count           NUMBER := 0;
        l_stmt_num              NUMBER := 0;
        l_acq_adjustment_amount NUMBER := 0;
        l_old_increments        NUMBER :=0;
        l_legal_entity          NUMBER;
        l_prev_period_id        NUMBER;
        l_ori_acq_amount          NUMBER;
        l_prior_period_quantity  NUMBER;
        l_prior_period_cost     NUMBER;
        l_legal_entity_id       NUMBER;
        l_transaction_id        NUMBER;
        l_period_close_date     DATE;
        l_least_date            DATE;
        l_material_account            NUMBER(15);
        l_material_overhead_account   NUMBER(15);
        l_outside_processing_account  NUMBER(15);
        l_resource_account            NUMBER(15);
        l_overhead_account            NUMBER(15);
        l_rcv_txn_id             NUMBER;
        l_original_acq_cost      NUMBER :=0;
        l_rcv_txn_date           DATE;
        l_rtv_qty                NUMBER :=0;
        l_rtv_adj_amount         NUMBER :=0;
        l_net_qty_received       NUMBER :=0;
        l_original_qty_received  NUMBER :=0;
        l_item                   NUMBER;
        l_wip_entity_id          NUMBER;




        CST_NULL_ACQ_COST       EXCEPTION;
        CONC_STATUS             BOOLEAN;
BEGIN

        --------------------------------------------------------
        -- Initialize error variables
        ---------------------------------------------------------
        o_err_num := 0;
        o_err_code := '';
        o_err_msg := '';

        l_stmt_num := 10;

        ---------------------------------------------------------
        -- Check if any rows in CRACD for the header
        -- If there are none, that means no invoices were matched to receipt
        -- acq cost will be PO price
        -- If there are some, then invoices were matched and acq cost will
        -- be a combination of PO and invoice price
        -----------------------------------------------------------

        SELECT count(header_id)
        INTO   l_cracd_count
        FROM   cst_rcv_acq_cost_details_adj cracd9
        WHERE  cracd9.header_id = i_header
        AND    ROWNUM < 2;

        -------------------------------------------------------------
        -- If invoices were matched
        ------------------------------------------------------------

        IF l_cracd_count > 0 THEN

          l_stmt_num := 20;

        ----------------------------------------------------------
        -- Get total invoice amount
        ---------------------------------------------------------
          SELECT
          SUM(cracd10.amount)
          INTO
          l_total_invoice_amount
          FROM
          cst_rcv_acq_cost_details_adj cracd10
          WHERE
          cracd10.header_id = i_header;

        ----------------------------------------------------------
        -- Get total invoice quantity
        ---------------------------------------------------------

          l_stmt_num := 25;

          SELECT
          SUM(nvl(cracd11.quantity,0))
          INTO
          l_qty_invoiced
          FROM
          cst_rcv_acq_cost_details_adj cracd11
          WHERE
          cracd11.header_id = i_header;

        ELSE

        --------------------------------------------------------------
        -- Set Total Invoice amount and quantity to zero
        --------------------------------------------------------------

          l_total_invoice_amount := 0;
          l_qty_invoiced := 0;

        END IF;

        -------------------------------------------------------------
        -- If total invoice quantity is greater than the net qty recd,
        -- then acq cost is to be calculated based on invoice quantity
        -- else acq cost is to be calculated based on net qty recd
        -------------------------------------------------------------
        IF l_qty_invoiced > i_nqr THEN
          l_qty_at_po := 0;
          l_costed_quantity := l_qty_invoiced;
        ELSE
          l_qty_at_po := i_nqr - l_qty_invoiced;
          l_costed_quantity := i_nqr;
        END IF;

        --------------------------------------------------------------
        -- Calculate amount at po, total amount and acq cost
        --------------------------------------------------------------

        l_amount_at_po := l_qty_at_po * i_po_price * i_rate; -- po price in pri
        l_total_amount := l_total_invoice_amount + l_amount_at_po;
        IF l_costed_quantity = 0 THEN
          l_acq_cost := i_po_price * i_rate;  /* changed for bug 3090599 */
        ELSE
          l_acq_cost := l_total_amount / l_costed_quantity;
        END IF;

        l_stmt_num := 30;


        ----------------------------------------------------------------
        -- Check if acquisition cost is null
        ---------------------------------------------------------------

        IF (l_acq_cost is null) THEN
          RAISE CST_NULL_ACQ_COST;
        END IF;
        -----------------------------------------------------------------
        -- update CRACD with the calculated values
        ----------------------------------------------------------------
        UPDATE
        cst_rcv_acq_costs_adj crac2
        SET
        crac2.total_invoice_amount = l_total_invoice_amount,
        crac2.total_quantity_invoiced = l_qty_invoiced,
        crac2.quantity_at_po_price = l_qty_at_po,
        crac2.amount_at_po_price = l_amount_at_po,
        crac2.total_amount = l_total_amount,
        crac2.costed_quantity = l_costed_quantity,
        crac2.acquisition_cost = l_acq_cost
        WHERE
        crac2.header_id = i_header;

        --------------------------------------------------------------
        -- If the qty at po was not zero, then insert a row for source type PO
        --------------------------------------------------------------

        IF l_qty_at_po <> 0 THEN

          l_stmt_num := 40;

          INSERT INTO
          cst_rcv_acq_cost_details_adj (   --cracd12
          HEADER_ID,
          DETAIL_ID,
          SOURCE_TYPE,
          PO_LINE_LOCATION_ID,
          PARENT_DISTRIBUTION_ID,
          DISTRIBUTION_NUM,
          LEVEL_NUM,
          INVOICE_DISTRIBUTION_ID,
          PARENT_INVOICE_DIST_ID,
          ALLOCATED_AMOUNT,
          PARENT_AMOUNT,
          AMOUNT,
          QUANTITY,
          PRICE,
          LINE_TYPE,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          REQUEST_ID,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          PROGRAM_UPDATE_DATE,
          LAST_UPDATE_LOGIN
          )
          VALUES (
          i_header,
          cst_rcv_acq_cost_details_s.nextval,
          'PO',
          i_po_line_loc,
          NULL,
          -1,
          0,
          NULL,
          NULL,
          NULL,
          NULL,
          l_amount_at_po,
          l_qty_at_po,
          i_po_price,
          NULL,
          SYSDATE,
          i_user_id,
          SYSDATE,
          i_user_id,
          i_req_id,
          i_prog_appl_id,
          i_prog_id,
          SYSDATE,
          i_login_id);
        END IF;

/* now calculate the amount to be posted as the adjustment amount   */

       If G_DEBUG = 'Y' then

       fnd_file.put_line(fnd_file.log,'Calculating the Adjustment amount');
       fnd_file.put_line(fnd_file.log,'Header ID : ' || to_char(i_header));

       End If;

        l_stmt_num := 45;

     /* bug fix for bug 3439082.Added joins on the cost group and cost type */


        BEGIN /* bail out exception that occurs coz there is no row in crac */

        select NVL((crac.net_quantity_received * crac.acquisition_cost),0),
               crac.rcv_transaction_id, nvl(crac.acquisition_cost,0),
               nvl(crac.net_quantity_received,0)
        INTO l_ori_acq_amount, l_rcv_txn_id, l_original_acq_cost,
             l_original_qty_received
        FROM cst_rcv_acq_costs crac, cst_rcv_acq_costs_adj craca
        WHERE craca.header_id = i_header
        AND crac.rcv_transaction_id = craca.rcv_transaction_id
        AND crac.cost_type_id = i_cost_type_id
        AND crac.cost_group_id = i_cost_group_id;

        EXCEPTION
        WHEN NO_DATA_FOUND then
         l_ori_acq_amount := 0;
         l_rcv_txn_id := -99;

        END;

       If G_DEBUG = 'Y' then

        fnd_file.put_line(fnd_file.log,'Original Acq cost:'|| l_ori_acq_amount);
       End If;

 /* now get the SUM of all the incremental amounts posted to MMT so far in the          previous periods */

        l_stmt_num := 50;

       /* bug fix for bug 3439082.Added joins on the cost group and cost type */

        select NVL(SUM(NVL(value_change,0)),0) into l_old_increments
        from mtl_material_transactions mmt, cst_rcv_acq_costs_adj craca
        where mmt.transaction_id = craca.mmt_transaction_id
        and craca.mmt_transaction_id is NOT NULL
        and craca.cost_group_id = i_cost_group_id
        and craca.cost_type_id = i_cost_type_id
        and craca.rcv_transaction_id = (select rcv_transaction_id
                                        from cst_rcv_acq_costs_adj craca2
                                        where craca2.header_id = i_header);


 fnd_file.put_line(fnd_file.log,'old increment :' || to_char(l_old_increments));

       select nvl(net_quantity_received,0)
       into l_net_qty_received
       from cst_rcv_acq_costs_adj
       where header_id = i_header;

/* Bug 2741945 */

 /* Get the RTV/Correction qty and amount to be adjusted */

       l_rtv_qty := nvl(abs(l_net_qty_received - l_original_qty_received),0);

       l_rtv_adj_amount := l_rtv_qty * l_original_acq_cost;

       fnd_file.put_line(fnd_file.log,'RTV Adjustment amount : ' || to_char(l_rtv_adj_amount));

fnd_file.put_line(fnd_file.log,'Current acq cost : ' || to_char(l_acq_cost));



        l_acq_adjustment_amount := (NVL(l_acq_cost,0) * l_net_qty_received)
                          - l_ori_acq_amount - l_old_increments + l_rtv_adj_amount;

        fnd_file.put_line(fnd_file.log,'Adjustment amount : ' || to_char(l_acq_adjustment_amount));

/* Now check if the amount to be posted is greater than 0.If it is then post an entry into MMT.Otherwise dont */

   IF l_acq_adjustment_amount <> 0  then

     /* now start geting the details that are required to insert into MMT */

     /* first get the legal entity for the cost group */

        l_stmt_num := 55;

        select legal_entity into l_legal_entity
        from cst_cost_groups
        where cost_group_id = i_cost_group_id ;

     /* Now get the prior period quantity */

        l_stmt_num := 60;

        select NVL(MAX(pac_period_id), -1) into l_prev_period_id
        from cst_pac_periods
        where legal_entity = l_legal_entity
        and open_flag = 'N'
        and cost_type_id = i_cost_type_id;

        /* bug 5044215/5264793.Check if the deliveries against this receipt is to shopfloor.If it is then the
           adjustment amount needs to be posted against the assembly item on the job */

          select wip_entity_id
           into l_wip_entity_id
           from
          (
          Select distinct wip_entity_id
          from rcv_transactions rt2
          where rt2.transaction_type in ('DELIVER')
          START WITH
          rt2.transaction_id = (select rcv_transaction_id
                                 from  cst_rcv_acq_costs_adj craca2
                                 where craca2.header_id = i_header)
          CONNECT BY
          prior rt2.transaction_id = rt2.parent_transaction_id
          )
          where rownum = 1;

          If l_wip_entity_id is not NULL then
            Select primary_item_id
              into l_item
             from wip_entities
             where wip_entity_id = l_wip_entity_id ;
          else
           l_item := i_item ;
          end if;

         If l_prev_period_id = -1 then
           l_prior_period_quantity := 0;
           l_prior_period_cost := 0;
         else

          l_stmt_num := 65;

        BEGIN
          select NVL(total_layer_quantity,0),NVL(item_cost,0)
          into l_prior_period_quantity,l_prior_period_cost
          from cst_pac_item_costs
          where pac_period_id = l_prev_period_id
          and cost_group_id = i_cost_group_id
          and inventory_item_id = l_item ;

        EXCEPTION
          WHEN OTHERS THEN
           l_prior_period_quantity := 0;
           l_prior_period_cost := 0;
        END;

         end if;

     /* Now get the accounts for all the cost elements */

          l_stmt_num := 70;

        fnd_file.put_line(fnd_file.log,'item id : ' || to_char(l_item));
        fnd_file.put_line(fnd_file.log,'org_id  : ' || to_char(i_org_id));


        select MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL into l_transaction_id
        from dual;

    /* get the period close date for the current open period */

        l_stmt_num := 80;

        select NVL(period_end_date,sysdate) into l_period_close_date
        from CST_PAC_PERIODS
        where pac_period_id = i_pac_period_id
        and legal_entity = l_legal_entity
        and cost_type_id = i_cost_type_id;

     /* Now insert stuff into MMT */

        select LEAST(l_period_close_date,sysdate) into l_least_date
        from dual;

        l_stmt_num := 90;

        /* bug 4322574. CHanged the Costed_flag to NULL from 'N' so that the perpetual cost worker does not try and
           pick it up for costing */


        INSERT INTO MTL_MATERIAL_TRANSACTIONS
          (transaction_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           inventory_item_id,
           organization_id,
           transaction_type_id,
           transaction_action_id,
           transaction_source_type_id,
           transaction_quantity,
           transaction_uom,
           primary_quantity,
           transaction_date,
           value_change,
           material_account,
           material_overhead_account,
           resource_account,
           outside_processing_account,
           overhead_account,
           costed_flag,
           org_cost_group_id,
           cost_type_id,
           source_code,
           source_line_id)
        VALUES (
                 l_transaction_id,
                 sysdate,
                 i_user_id,
                 sysdate,
                 i_user_id,
                 l_item,
                 i_org_id,
                 26,
                 24,
                 14,
                 --l_prior_period_quantity,
		 0,
                 i_primary_uom,
                 --l_prior_period_quantity,
		 0,
                 l_least_date, --- transaction_date is sysdate
                 l_acq_adjustment_amount,
                 i_adj_account,
                 i_adj_account,
                 i_adj_account,
                 i_adj_account,
                 i_adj_account,
                 NULL,
                 i_cost_group_id,
                 i_cost_type_id,
                 'ACQADJ',
                 l_rcv_txn_id
               );

    /* insert into MPTCD */

          Insert into mtl_pac_txn_cost_details
                (cost_group_id,
                 transaction_id,
                 pac_period_id,
                 cost_type_id,
                 cost_element_id,
                 level_type,
                 inventory_item_id,
                 value_change,
                 transaction_cost,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by )
         Values (i_cost_group_id,
                 l_transaction_id,
                 i_pac_period_id,
                 i_cost_type_id,
                 1, -- cost element ID
                 1, -- THis level
                 l_item,
                 l_acq_adjustment_amount,
                 l_prior_period_cost,
                 sysdate,
                 i_user_id,
                 sysdate,
                 i_user_id);



   /* Now update the entry in CRACA with the new transaction ID of MMT */

       l_stmt_num := 100;

       Update cst_rcv_acq_costs_adj set
        mmt_transaction_id = l_transaction_id
        where header_id = i_header;


   END IF; -- there is something to post into MMT



EXCEPTION
        WHEN CST_NULL_ACQ_COST THEN
        o_err_num := 30014;
        o_err_code := SQLCODE;
        FND_MESSAGE.set_name('BOM', 'CST_NULL_ACQ_COST');
        o_err_msg := FND_MESSAGE.Get;
        WHEN OTHERS THEN
        o_err_num := 30002;
        o_err_code := SQLCODE;
        o_err_msg := SUBSTR('CSTPPACQ.compute_acq_cost_adj('
                        ||to_char(l_stmt_num)
                        ||'):'
                        ||SQLERRM,1,240);

END compute_acq_cost_acqadj;



PROCEDURE get_acq_cost (
        i_cost_group_id         IN         NUMBER,
        i_txn_id                IN         NUMBER,
        i_cost_type_id          IN         NUMBER,
        i_wip_inv_flag          IN        VARCHAR2,
        o_acq_cost              OUT NOCOPY        NUMBER,
        o_err_num               OUT NOCOPY      NUMBER,
        o_err_code              OUT NOCOPY      VARCHAR2,
        o_err_msg               OUT NOCOPY      VARCHAR2)
IS
        l_rcv_txn               NUMBER;
        l_rec_cost              NUMBER;
        l_par_txn               NUMBER;
        l_stmt_num              NUMBER := 0;
        l_err_msg               VARCHAR2(240);
	l_lcm_adj_period        NUMBER;
        l_lcm_flag              VARCHAR2(1);

        CST_FAIL_PAR_ERROR      EXCEPTION;
        CST_NO_ACQ_COST         EXCEPTION;
        CST_NULL_ACQ_COST       EXCEPTION;
        CST_FAIL_MMT_TXN        EXCEPTION;
        CST_FAIL_WIP_TXN        EXCEPTION;
BEGIN

        ------------------------------------------------------------
        -- Initialize variables
        ------------------------------------------------------------

        o_err_num := 0;
        o_err_code := '';
        o_err_msg := '';

        l_err_msg := NULL;
        ---------------------------------------------------------------
        -- If the function is called from Inventory part of PAC processor,
        -- the flag will be 'I' and it is a MMT transaction
        -- If the function is called from WIP part of PAC processor,
        -- the flag will be 'W' and it is a WT transaction
        ---------------------------------------------------------------

        IF i_wip_inv_flag = 'I' THEN

          l_stmt_num := 10;

        ---------------------------------------------------------------
        -- Get correspoding rcv_txn from MMT
        ---------------------------------------------------------------

          SELECT
          rcv_transaction_id
          INTO
          l_rcv_txn
          FROM
          mtl_material_transactions mmt
          WHERE
          mmt.transaction_id = i_txn_id AND
          mmt.organization_id in (
            SELECT
            ccga2.organization_id
            FROM
            cst_cost_group_assignments ccga2
            WHERE
            ccga2.cost_group_id = i_cost_group_id);

        ELSIF i_wip_inv_flag = 'W' THEN

          l_stmt_num := 20;

        -----------------------------------------------------------------
        -- Get correspoding rcv_txn from WT
        -----------------------------------------------------------------

        -----------------------------------------------------------------
        -- Fix for bug 1758901
        -- source_line_id of wip_transactions corresponds to
        -- transaction_id of rcv_transactions;
        -- rcv_transaction_id of wip_transactions corresponds to
        -- interface_transaction_id of rcv_transactions
        -----------------------------------------------------------------
        /* Reversed above fix
           Source_line_id in WT corresponds to interface_transaction_id
           in rcv_transactions and rcv_transaction_id corresponds to the
           transaction_id in rcv_transactions.
           Bugfix 2541821
         */

          SELECT
          rcv_transaction_id
          INTO
          l_rcv_txn
          FROM
          wip_transactions wt
          WHERE
          wt.transaction_id = i_txn_id AND
          wt.organization_id in (
            SELECT
            ccga3.organization_id
            FROM
            cst_cost_group_assignments ccga3
            WHERE
            ccga3.cost_group_id = i_cost_group_id);
        ELSE
                RAISE CST_FAIL_PAR_ERROR;
        END IF;


-- if no data found, then either the rcv txn is incorrect or the org is incorrect

        l_stmt_num := 30;

        ------------------------------------------------------------
        -- Get the parent receive or match txn from RCV_TRANSACTIONS
        ------------------------------------------------------------

        SELECT
        rt6.transaction_id,
	nvl(poll.lcm_flag,'N')
        INTO
        l_par_txn,
	l_lcm_flag
        FROM
        rcv_transactions rt6,
	po_line_locations_all poll
        WHERE
        rt6.transaction_type in ('RECEIVE','MATCH')
	AND poll.line_location_id = rt6.po_line_location_id
        START WITH
        rt6.transaction_id = l_rcv_txn
        CONNECT BY
        rt6.transaction_id = prior rt6.parent_transaction_id;

        l_stmt_num := 40;

        Declare
          l_hook_cost number;
          l_hook_err  number;
        Begin
          l_hook_cost :=0;
          l_hook_err  :=0;

          l_stmt_num := 45;
          IF (l_lcm_flag = 'N') THEN
          SELECT
          nvl(crac3.acquisition_cost,-1)
          INTO
          l_rec_cost
          FROM
          cst_rcv_acq_costs crac3
          WHERE
          crac3.cost_type_id = i_cost_type_id AND
          crac3.cost_group_id = i_cost_group_id AND
          crac3.rcv_transaction_id = l_par_txn;

          IF SQL%ROWCOUNT = 0 THEN
            RAISE CST_NO_ACQ_COST;
          END IF;

          IF (l_rec_cost = -1) then
            RAISE CST_NULL_ACQ_COST;
          END IF;
          ELSE /*LCM enabled*/
	    l_stmt_num := 50;
	    SELECT
              nvl(max(crac3.acquisition_cost),-1)
            INTO
             l_rec_cost
            FROM
            cst_rcv_acq_costs crac3
            WHERE
            crac3.cost_type_id = i_cost_type_id AND
            crac3.cost_group_id = i_cost_group_id AND
            crac3.rcv_transaction_id = l_par_txn;
	    l_stmt_num := 60;
	    SELECT nvl(max(craca.period_id),-1)
             INTO l_lcm_adj_period
	    FROM cst_rcv_acq_costs_adj craca
	     WHERE craca.rcv_transaction_id = l_par_txn
	       AND craca.cost_type_id = i_cost_type_id
	       AND craca.cost_group_id = i_cost_group_id;

	    IF (l_lcm_adj_period <> -1) THEN
              l_stmt_num := 70;
	      SELECT craca.acquisition_cost
	        INTO l_rec_cost
              FROM cst_rcv_acq_costs_adj craca
	      WHERE craca.rcv_transaction_id = l_par_txn
		AND craca.cost_type_id = i_cost_type_id
		AND craca.cost_group_id = i_cost_group_id
		AND craca.period_id = l_lcm_adj_period;
	    ELSIF ( l_rec_cost = -1 AND l_lcm_adj_period = -1) THEN
	       RAISE no_data_found;
	    END IF;
	  END IF;
        Exception
          WHEN no_data_found then
            l_err_msg := '';
            CSTPPAHK.acq_receipt_cost_hook(
                        i_cost_type_id,
                        i_cost_group_id,
                        l_par_txn,
                        l_hook_cost,
                        l_hook_err,
                        l_err_msg);
            if l_hook_err < 0 then
               raise;
            else
               l_rec_cost := l_hook_cost;
            end if;

          WHEN others then
            Raise;
        End;

        -------------------------------------------------------------
        -- set output parameter to acq cost
        -------------------------------------------------------------

        o_acq_cost := l_rec_cost;
--until AP objects are built, whole code needs to be commented out.
--return a dummy cost of 1 for now.

        --o_acq_cost := 1;

-- if no data, then acq cost does not exist for the CT, period
EXCEPTION
        WHEN CST_FAIL_PAR_ERROR THEN
        o_err_num := 30010;
        o_err_code := SQLCODE;
        o_err_msg := 'CSTPPACQ.get_acq_cost : Wrong Parameter Value';

        WHEN CST_FAIL_MMT_TXN THEN
        o_err_num := 30011;
        o_err_code := SQLCODE;
        FND_MESSAGE.set_name('BOM', 'CST_FAIL_MMT_TXN');
        o_err_msg := FND_MESSAGE.Get;

        WHEN CST_FAIL_WIP_TXN THEN
        o_err_num := 30012;
        o_err_code := SQLCODE;
        FND_MESSAGE.set_name('BOM', 'CST_FAIL_WIP_TXN');
        o_err_msg := FND_MESSAGE.Get;

        WHEN CST_NO_ACQ_COST THEN
        o_err_num := 30013;
        o_err_code := SQLCODE;
        FND_MESSAGE.set_name('BOM', 'CST_NO_ACQ_COST');
        o_err_msg := FND_MESSAGE.Get;

        WHEN CST_NULL_ACQ_COST THEN
        o_err_num := 30014;
        o_err_code := SQLCODE;
        FND_MESSAGE.set_name('BOM', 'CST_NULL_ACQ_COST');
        o_err_msg := FND_MESSAGE.Get;

        WHEN OTHERS THEN
        o_err_num := 30003;
        o_err_code := SQLCODE;
        o_err_msg := SUBSTR(l_err_msg||'CSTPPACQ.get_acq_cost('
                        ||to_char(l_stmt_num)
                        ||'):'
                        ||SQLERRM,1,240);
END get_acq_cost;

FUNCTION get_rcv_tax (
        i_rcv_txn_id    IN         NUMBER)
RETURN NUMBER
IS
        l_tot_tax               NUMBER;
        l_stmt_num              NUMBER;
BEGIN

/* This function is also called from the CSTRAIVR.rdf main query. */

l_stmt_num := 10;

SELECT
  nvl((SUM(NVL(nonrecoverable_tax,0))
     /SUM(DECODE(PLL.MATCHING_BASIS,
                'AMOUNT', POD.AMOUNT_ORDERED,
                'QUANTITY', POD.quantity_ordered ) ) ), 0 )
 INTO
   l_tot_tax
 FROM
   po_distributions_all pod,
   rcv_transactions rcv,
   po_line_locations_all pll
 WHERE RCV.TRANSACTION_ID = i_rcv_txn_id
   AND POD.LINE_LOCATION_ID = RCV.PO_LINE_LOCATION_ID
   AND PLL.LINE_LOCATION_ID = RCV.PO_LINE_LOCATION_ID
        AND (
             (    RCV.PO_DISTRIBUTION_ID IS NOT NULL
              AND RCV.PO_DISTRIBUTION_ID = POD.PO_DISTRIBUTION_ID
             )
             OR
             (    RCV.PO_DISTRIBUTION_ID IS NULL
              AND RCV.PO_LINE_LOCATION_ID = POD.LINE_LOCATION_ID
             )
            );

        return l_tot_tax;


EXCEPTION
        WHEN OTHERS THEN
          return -1;

END get_rcv_tax;

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  BUG 9495449
  In Global Procuremnt scenario,currency conversion is not
  happening when matched to receipt. Created fucntion
  get_rcv_rate ,such that it will consider the rate from
  Rcv_accounting_events for event_type_id=1(receipt)
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

FUNCTION get_rcv_rate (i_rcv_txn_id  IN NUMBER)
RETURN NUMBER
IS
        l_rcv_rate              NUMBER;
        l_stmt_num              NUMBER;
        l_rsl_exists            NUMBER;
        l_trx_flow              NUMBER := 1;
        l_org_id                NUMBER;
BEGIN

        l_stmt_num := 10;

         IF g_debug = 'Y' THEN
            fnd_file.put_line(fnd_file.log,'in get_rcv_rate');
            fnd_file.put_line(fnd_file.log,'i_rcv_txn_id'||i_rcv_txn_id);
         END IF;


        SELECT count(rcv_transaction_id)
        INTO   l_rsl_exists
        FROM   rcv_receiving_sub_ledger rsl
        WHERE  rsl.rcv_transaction_id = i_rcv_txn_id
        AND    rsl.accounted_cr IS NOT NULL
        AND    rsl.accounted_cr <> 0
        AND    ROWNUM < 2;


        l_stmt_num := 15;
        IF (l_rsl_exists <> 0) THEN

          Begin
                 Select
                 TRX_FLOW_HEADER_ID,
                 organization_id
                 Into
                 l_trx_flow,
                 l_org_id
          From   rcv_accounting_events rae,
                  po_lines_all POL,
                  po_distributions_all POD
           Where  rae.rcv_transaction_id =  i_rcv_txn_id
           And    rae.event_type_id      = 1 -- RECEIVE
           And    rae.trx_flow_header_id is not null
           AND    RAE.PO_DISTRIBUTION_ID = POD.PO_DISTRIBUTION_ID
           AND    POD.PO_LINE_ID         = POL.PO_LINE_ID
           AND    ROWNUM<2;

        Exception
          When others then
            l_trx_flow := -1;
            l_org_id := -1;
        End;


        if (l_trx_flow > 0) then
            /*  If this is a global procurement with a transaction flow
             * then it's possible that there are rsl entries for each organization
             * in the flow for the same rcv_txn_id. In that case, we need to join on
             * RAE to pick up the proper org.
             */

               SELECT
                 SUM(rsl.accounted_cr) / SUM(rsl.entered_cr)
               INTO
                 l_rcv_rate
               FROM
                 rcv_receiving_sub_ledger rsl,
                 rcv_accounting_events rae
               WHERE
                 rsl.rcv_transaction_id = i_rcv_txn_id AND
                 rsl.accounted_cr is not null AND
                 rsl.accounted_cr <> 0 and
                 rsl.accounting_event_id = rae.accounting_event_id and
                 rae.event_type_id =1
                 and rae.organization_id = l_org_id;


        else

               SELECT
                 SUM(rsl.accounted_cr) / SUM(rsl.entered_cr)
               INTO
                 l_rcv_rate
               FROM
                 rcv_receiving_sub_ledger rsl
               WHERE
                 rsl.rcv_transaction_id = i_rcv_txn_id AND
                 rsl.accounted_cr is not null AND
                 rsl.accounted_cr <> 0;


        end if;

      ELSE

          l_stmt_num := 17;


        SELECT
             nvl(rt.currency_conversion_rate,1)
        INTO
             l_rcv_rate
        FROM
              po_lines_all pol,
              po_line_locations_all poll,
              rcv_transactions rt
         WHERE
              rt.transaction_id      = i_rcv_txn_id
          AND rt.po_line_location_id = poll.line_location_id
          AND pol.po_line_id = poll.po_line_id;


     END IF;

     IF g_debug = 'Y' THEN
            fnd_file.put_line(fnd_file.log,'l_rcv_rate_'||  l_rcv_rate);
     END IF;

     return l_rcv_rate;

EXCEPTION
        WHEN OTHERS THEN
          return -1;

END get_rcv_rate;


FUNCTION get_po_rate (
        i_rcv_txn_id    IN         NUMBER)
RETURN NUMBER
IS
        l_po_rate               NUMBER;
        l_stmt_num              NUMBER;
        l_rsl_exists            NUMBER;
        l_trx_flow                NUMBER := 1;
        l_org_id                NUMBER;
BEGIN

/* This function is also called from the CSTRAIVR.rdf main query. */

        l_stmt_num := 10;

        SELECT count(rcv_transaction_id)
        INTO   l_rsl_exists
        FROM   rcv_receiving_sub_ledger rsl
        WHERE  rsl.rcv_transaction_id = i_rcv_txn_id
        AND    rsl.accounted_cr IS NOT NULL
        AND    rsl.accounted_cr <> 0
        AND    ROWNUM < 2;

        l_stmt_num := 15;
       IF (l_rsl_exists <> 0) THEN

        /* Bug 3427884: eliminate any adjust event accounting if this is a
           Global Procurement scenario using transfer pricing option */

         Begin
                 Select
                 TRX_FLOW_HEADER_ID,
                 organization_id
                 Into
                 l_trx_flow,
                 l_org_id
          From   rcv_accounting_events rae,
                  po_lines_all POL,
                  po_distributions_all POD
           Where  rae.rcv_transaction_id =  i_rcv_txn_id
           And    rae.event_type_id      = 1 -- RECEIVE
           And    rae.trx_flow_header_id is not null
           AND    RAE.PO_DISTRIBUTION_ID = POD.PO_DISTRIBUTION_ID
           AND    POD.PO_LINE_ID         = POL.PO_LINE_ID
           AND    ROWNUM<2;

        Exception
          When others then
            l_trx_flow := -1;
            l_org_id := -1;
        End;

        if (l_trx_flow > 0) then
            /* bug 3421589 - If this is a global procurement with a transaction flow
             * then it's possible that there are rsl entries for each organization
             * in the flow for the same rcv_txn_id. In that case, we need to join on
             * RAE to pick up the proper org.
             */

               SELECT
                 SUM(rsl.accounted_cr) / SUM(rsl.entered_cr)
               INTO
                 l_po_rate
               FROM
                 rcv_receiving_sub_ledger rsl,
                 rcv_accounting_events rae
               WHERE
                 rsl.rcv_transaction_id = i_rcv_txn_id AND
                 rsl.accounted_cr is not null AND
                 rsl.accounted_cr <> 0 and
                 rsl.accounting_event_id = rae.accounting_event_id and
                 rae.event_type_id =1
                 and rae.organization_id = l_org_id;

        else

               SELECT
                 SUM(rsl.accounted_cr) / SUM(rsl.entered_cr)
               INTO
                 l_po_rate
               FROM
                 rcv_receiving_sub_ledger rsl
               WHERE
                 rsl.rcv_transaction_id = i_rcv_txn_id AND
                 rsl.accounted_cr is not null AND
                 rsl.accounted_cr <> 0;
        end if;

      ELSE

          l_stmt_num := 17;

          SELECT
          SUM(DECODE(POLL.MATCHING_BASIS, 'AMOUNT', POD.AMOUNT_ORDERED, POD.QUANTITY_ORDERED)*nvl(pod.rate,1))
                /SUM(DECODE(POLL.MATCHING_BASIS, 'AMOUNT', POD.AMOUNT_ORDERED, POD.QUANTITY_ORDERED))
          INTO
          l_po_rate
          FROM
          PO_DISTRIBUTIONS_ALL POD,
          RCV_TRANSACTIONS RT,
          PO_LINE_LOCATIONS_ALL POLL
          WHERE
                RT.TRANSACTION_ID = i_rcv_txn_id
            AND (
                 (     RT.PO_DISTRIBUTION_ID IS NOT NULL
                   AND RT.PO_DISTRIBUTION_ID = POD.PO_DISTRIBUTION_ID
                 )
                 OR
                 (     RT.PO_DISTRIBUTION_ID IS NULL
                   AND RT.PO_LINE_LOCATION_ID = POD.LINE_LOCATION_ID
                 )
                )
            AND POLL.LINE_LOCATION_ID = POD.LINE_LOCATION_ID;

        END IF;


        return l_po_rate;

EXCEPTION
        WHEN OTHERS THEN
          return -1;

END get_po_rate;

FUNCTION get_net_undel_qty(
        i_transaction_id        IN         NUMBER,
        i_end_date              IN        DATE)
RETURN NUMBER
IS
        ----------------------------------------------------
        -- Get all child transactions level by level
        -----------------------------------------------------
        CURSOR c_nqud is
        SELECT
        rt4.transaction_id,
        rt4.transaction_type,
        rt4.primary_quantity,
        rt4.parent_transaction_id
        FROM
        rcv_transactions rt4
        WHERE
        rt4.transaction_date < i_end_date
        START WITH
        rt4.transaction_id = i_transaction_id
        CONNECT BY
        prior rt4.transaction_id = rt4.parent_transaction_id;
        l_nqud          NUMBER := 0;
        l_parent_type   rcv_transactions.transaction_type%TYPE;
        l_stmt_num      NUMBER := 0;
BEGIN
        ---------------------------------------------------------
        -- Initialize error variable
        ---------------------------------------------------------
        ---------------------------------------------------------
        -- For each child transaction loop
        --------------------------------------------------------
        FOR c_nqud_rec in c_nqud loop
        --------------------------------------------------------
        -- If it is not the parent (that was passed in) transaction itself
        --------------------------------------------------------
          IF c_nqud_rec.transaction_id <> i_transaction_id THEN
            l_stmt_num := 10;
        ----------------------------------------------------------
        -- Get the parent transaction type
        ----------------------------------------------------------
            SELECT
            rt5.transaction_type
            INTO
            l_parent_type
            FROM
            rcv_transactions rt5
            WHERE
            rt5.transaction_id = c_nqud_rec.parent_transaction_id;
          END IF;
        ------------------------------------------------------------
        -- If it is the parent receive or match transaction
        -- then add the quantity to l_nqud
        ------------------------------------------------------------
          IF c_nqud_rec.transaction_id = i_transaction_id THEN
            l_nqud := l_nqud + c_nqud_rec.primary_quantity;
        -----------------------------------------------------------
        -- If the transaction is CORRECT,
        -- If parent is receive or match txn, then add the corrected qty
        -- If parent is return, then subtract the corrected qty
        -----------------------------------------------------------
          ELSIF c_nqud_rec.transaction_type = 'CORRECT' then
            IF l_parent_type = 'RECEIVE' OR
                l_parent_type = 'MATCH' THEN
              l_nqud := l_nqud + c_nqud_rec.primary_quantity;
            ELSIF l_parent_type = 'RETURN TO VENDOR' then
              l_nqud := l_nqud - c_nqud_rec.primary_quantity;
            ELSIF l_parent_type = 'DELIVER' then
              l_nqud := l_nqud - c_nqud_rec.primary_quantity;
            ELSIF l_parent_type = 'RETURN TO RECEIVING' then
              l_nqud := l_nqud + c_nqud_rec.primary_quantity;
            END IF;
        ----------------------------------------------------------
        -- If transaction is return transaction, then subtract returned qty
        ----------------------------------------------------------
          ELSIF c_nqud_rec.transaction_type = 'RETURN TO VENDOR' then
            l_nqud := l_nqud - c_nqud_rec.primary_quantity;
          ELSIF c_nqud_rec.transaction_type = 'DELIVER' then
            l_nqud := l_nqud - c_nqud_rec.primary_quantity;
          ELSIF c_nqud_rec.transaction_type = 'RETURN TO RECEIVING' then
            l_nqud := l_nqud + c_nqud_rec.primary_quantity;
          END IF;
        END LOOP; -- child txns loop
        --------------------------------------------------------
        -- Return the net quantity received as calculated
        --------------------------------------------------------
        RETURN (l_nqud);
EXCEPTION
        WHEN OTHERS THEN
        RETURN(NULL);
END get_net_undel_qty;


Procedure Insert_into_acqhdr_tables(
              i_header_id                IN  NUMBER,
              i_cost_group_id            IN  NUMBER,
              i_cost_type_id             IN  NUMBER,
              i_period_id                IN  NUMBER,
              i_rcv_transaction_id       IN  NUMBER,
              i_net_quantity_received    IN  NUMBER,
              i_total_quantity_invoiced  IN  NUMBER,
              i_quantity_at_po_price     IN  NUMBER,
              i_total_invoice_amount     IN  NUMBER,
              i_amount_at_po_price       IN  NUMBER,
              i_total_amount             IN  NUMBER,
              i_costed_quantity          IN  NUMBER,
              i_acquisition_cost         IN  NUMBER,
              i_po_line_location_id      IN  NUMBER,
              i_po_unit_price            IN  NUMBER,
              i_primary_uom              IN VARCHAR2,
              i_rec_exchg_rate           IN  NUMBER,
              i_last_update_date         IN  DATE,
              i_last_updated_by          IN  NUMBER,
              i_creation_date            IN  DATE,
              i_created_by               IN  NUMBER,
              i_request_id               IN  NUMBER,
              i_program_application_id   IN  NUMBER,
              i_program_id               IN  NUMBER,
              i_program_update_date      IN  DATE,
              i_last_update_login        IN  NUMBER,
              i_source_flag              IN  NUMBER,
              o_err_num                 OUT NOCOPY  NUMBER,
              o_err_msg                 OUT NOCOPY VARCHAR2 ) IS

l_stmt_no    NUMBER := 10;

BEGIN

   If i_source_flag = 1 then

   INSERT INTO cst_rcv_acq_costs (
              HEADER_ID,
              COST_GROUP_ID,
              COST_TYPE_ID,
              PERIOD_ID,
              RCV_TRANSACTION_ID,
              NET_QUANTITY_RECEIVED,
              TOTAL_QUANTITY_INVOICED,
              QUANTITY_AT_PO_PRICE,
              TOTAL_INVOICE_AMOUNT,
              AMOUNT_AT_PO_PRICE,
              TOTAL_AMOUNT,
              COSTED_QUANTITY,
              ACQUISITION_COST,
              PO_LINE_LOCATION_ID,
              PO_UNIT_PRICE,
              PRIMARY_UOM,
              REC_EXCHG_RATE,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY,
              CREATION_DATE,
              CREATED_BY,
              REQUEST_ID,
              PROGRAM_APPLICATION_ID,
              PROGRAM_ID,
              PROGRAM_UPDATE_DATE,
              LAST_UPDATE_LOGIN
              )
       values(i_header_id,
              i_cost_group_id,
              i_cost_type_id,
              i_period_id,
              i_rcv_transaction_id,
              i_net_quantity_received,
              i_total_quantity_invoiced,
              i_quantity_at_po_price,
              i_total_invoice_amount,
              i_amount_at_po_price,
              i_total_amount,
              i_costed_quantity,
              i_acquisition_cost,
              i_po_line_location_id,
              i_po_unit_price,
              i_primary_uom,
              i_rec_exchg_rate,
              i_last_update_date,
              i_last_updated_by,
              i_creation_date,
              i_created_by,
              i_request_id,
              i_program_application_id,
              i_program_id,
              i_program_update_date,
              i_last_update_login );

   elsif i_source_flag = 2 then

    l_stmt_no := 20;

   INSERT INTO cst_rcv_acq_costs_adj (
              HEADER_ID,
              COST_GROUP_ID,
              COST_TYPE_ID,
              PERIOD_ID,
              RCV_TRANSACTION_ID,
              NET_QUANTITY_RECEIVED,
              TOTAL_QUANTITY_INVOICED,
              QUANTITY_AT_PO_PRICE,
              TOTAL_INVOICE_AMOUNT,
              AMOUNT_AT_PO_PRICE,
              TOTAL_AMOUNT,
              COSTED_QUANTITY,
              ACQUISITION_COST,
              PO_LINE_LOCATION_ID,
              PO_UNIT_PRICE,
              PRIMARY_UOM,
              REC_EXCHG_RATE,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY,
              CREATION_DATE,
              CREATED_BY,
              REQUEST_ID,
              PROGRAM_APPLICATION_ID,
              PROGRAM_ID,
              PROGRAM_UPDATE_DATE,
              LAST_UPDATE_LOGIN
              )
       values(i_header_id,
              i_cost_group_id,
              i_cost_type_id,
              i_period_id,
              i_rcv_transaction_id,
              i_net_quantity_received,
              i_total_quantity_invoiced,
              i_quantity_at_po_price,
              i_total_invoice_amount,
              i_amount_at_po_price,
              i_total_amount,
              i_costed_quantity,
              i_acquisition_cost,
              i_po_line_location_id,
              i_po_unit_price,
              i_primary_uom,
              i_rec_exchg_rate,
              i_last_update_date,
              i_last_updated_by,
              i_creation_date,
              i_created_by,
              i_request_id,
              i_program_application_id,
              i_program_id,
              i_program_update_date,
              i_last_update_login );
    END IF;

EXCEPTION
   when others then
          o_err_msg := SUBSTR('CSTPPACQ.Insert_into_acqhdr_tables('
                        ||to_char(l_stmt_no)
                        ||'):'
                        ||SQLERRM,1,240);
          o_err_num := -1;

end Insert_into_acqhdr_tables;


Procedure Insert_into_acqdtls_tables (
                      i_header_id                   IN  NUMBER,
                      i_detail_id                   IN  NUMBER,
                      i_source_type                 IN  VARCHAR2,
                      i_po_line_location_id         IN  NUMBER,
                      i_parent_distribution_id      IN  NUMBER,
                      i_distribution_num            IN  NUMBER,
                      i_level_num                   IN  NUMBER,
                      i_invoice_distribution_id     IN  NUMBER,
                      i_parent_inv_distribution_id  IN  NUMBER,
                      i_allocated_amount            IN  NUMBER,
                      i_parent_amount               IN  NUMBER,
                      i_amount                      IN  NUMBER,
                      i_quantity                    IN  NUMBER,
                      i_price                       IN  NUMBER,
                      i_line_type                   IN  VARCHAR2,
                      i_last_update_date            IN  DATE,
                      i_last_updated_by             IN  NUMBER,
                      i_creation_date               IN  DATE,
                      i_created_by                  IN  NUMBER,
                      i_request_id                  IN  NUMBER,
                      i_program_application_id      IN  NUMBER,
                      i_program_id                  IN  NUMBER,
                      i_program_update_date         IN  DATE,
                      i_last_update_login           IN  NUMBER,
                      i_source_flag                 IN  NUMBER,
                      o_err_num                     OUT NOCOPY NUMBER,
                      o_err_msg                     OUT NOCOPY VARCHAR2) IS


   l_stmt_no    NUMBER := 10;

BEGIN

   IF i_source_flag = 1 then

   Insert into cst_rcv_acq_cost_details(
                      HEADER_ID,
                      DETAIL_ID,
                      SOURCE_TYPE,
                      PO_LINE_LOCATION_ID,
                      PARENT_DISTRIBUTION_ID,
                      DISTRIBUTION_NUM,
                      LEVEL_NUM,
                      INVOICE_DISTRIBUTION_ID,
                      PARENT_INVOICE_DIST_ID,
                      ALLOCATED_AMOUNT,
                      PARENT_AMOUNT,
                      AMOUNT,
                      QUANTITY,
                      PRICE,
                      LINE_TYPE,
                      LAST_UPDATE_DATE,
                      LAST_UPDATED_BY,
                      CREATION_DATE,
                      CREATED_BY,
                      REQUEST_ID,
                      PROGRAM_APPLICATION_ID,
                      PROGRAM_ID,
                      PROGRAM_UPDATE_DATE,
                      LAST_UPDATE_LOGIN
                      )
               values(
                      i_header_id,
                      i_detail_id,
                      i_source_type,
                      i_po_line_location_id,
                      i_parent_distribution_id,
                      i_distribution_num,
                      i_level_num,
                      i_invoice_distribution_id,
                      i_parent_inv_distribution_id,
                      i_allocated_amount,
                      i_parent_amount,
                      i_amount,
                      i_quantity,
                      i_price,
                      i_line_type,
                      i_last_update_date,
                      i_last_updated_by,
                      i_creation_date,
                      i_created_by,
                      i_request_id,
                      i_program_application_id,
                      i_program_id,
                      i_program_update_date,
                      i_last_update_login
                      );

   ELSIF i_source_flag = 2 then

     l_stmt_no := 20;

     Insert into cst_rcv_acq_cost_details_adj(
                      HEADER_ID,
                      DETAIL_ID,
                      SOURCE_TYPE,
                      PO_LINE_LOCATION_ID,
                      PARENT_DISTRIBUTION_ID,
                      DISTRIBUTION_NUM,
                      LEVEL_NUM,
                      INVOICE_DISTRIBUTION_ID,
                      PARENT_INVOICE_DIST_ID,
                      ALLOCATED_AMOUNT,
                      PARENT_AMOUNT,
                      AMOUNT,
                      QUANTITY,
                      PRICE,
                      LINE_TYPE,
                      LAST_UPDATE_DATE,
                      LAST_UPDATED_BY,
                      CREATION_DATE,
                      CREATED_BY,
                      REQUEST_ID,
                      PROGRAM_APPLICATION_ID,
                      PROGRAM_ID,
                      PROGRAM_UPDATE_DATE,
                      LAST_UPDATE_LOGIN
                      )
                values(
                      i_header_id,
                      i_detail_id,
                      i_source_type,
                      i_po_line_location_id,
                      i_parent_distribution_id,
                      i_distribution_num,
                      i_level_num,
                      i_invoice_distribution_id,
                      i_parent_inv_distribution_id,
                      i_allocated_amount,
                      i_parent_amount,
                      i_amount,
                      i_quantity,
                      i_price,
                      i_line_type,
                      i_last_update_date,
                      i_last_updated_by,
                      i_creation_date,
                      i_created_by,
                      i_request_id,
                      i_program_application_id,
                      i_program_id,
                      i_program_update_date,
                      i_last_update_login
                      );

   END IF;

EXCEPTION
   when others then
          o_err_msg := SUBSTR('CSTPPACQ.Insert_into_acqdtls_tables('
                        ||to_char(l_stmt_no)
                        ||'):'
                        ||SQLERRM,1,240);
          o_err_num := -1;

END Insert_into_acqdtls_tables;

Procedure Acquisition_cost_adj_processor(
        ERRBUF          OUT NOCOPY     VARCHAR2,
        RETCODE         OUT NOCOPY     NUMBER,
        i_legal_entity  IN      NUMBER,
        i_cost_type_id  IN      NUMBER,
        i_period        IN         NUMBER,
        i_end_date      IN        VARCHAR2,
        i_cost_group_id IN      NUMBER,
        i_source_flag   IN      NUMBER,
        i_run_option    IN      NUMBER,
        i_receipt_dummy IN      VARCHAR2,
        i_receipt_no    IN      NUMBER,
        i_invoice_dummy IN      VARCHAR2,
        i_invoice_no    IN      NUMBER,
        i_chart_of_ac_id IN     NUMBER,
        i_adj_account_dummy IN NUMBER,
        i_adj_account   IN      NUMBER
        ) IS

CST_INVALID_EXCEPTION EXCEPTION;
CONC_STATUS  BOOLEAN;
l_err_num NUMBER;
l_err_code VARCHAR2(2000);
l_err_msg VARCHAR2(2000);
l_receipt_no NUMBER;
l_invoice_no NUMBER;
l_end_date   DATE;
l_stmt_num NUMBER;


BEGIN

   l_err_code := '';
   l_err_msg := '';

   If i_run_option = 1 then
       l_receipt_no := NULL;
       l_invoice_no := NULL;
   elsif i_run_option = 3 then
       l_receipt_no := i_receipt_no;
       l_invoice_no := NULL;
   elsif i_run_option = 2 then
       l_receipt_no := NULL;
       l_invoice_no := i_invoice_no;
   end if;

      l_end_date := to_date(i_end_date,'RR/MM/DD HH24:MI:SS');

   If G_DEBUG = 'Y' then

     fnd_file.put_line(fnd_file.log,'date is : '|| to_char(l_end_date,'DD-MON-RR'));

   End If;

      l_stmt_num := 10;


/* start printing out the Parameters */

      fnd_file.put_line(fnd_file.log,'Legal Entity        : '|| to_char(i_legal_entity));
      fnd_file.put_line(fnd_file.log,'Cost Type           : '|| to_char(i_cost_type_id));
      fnd_file.put_line(fnd_file.log,'Period              : '|| to_char(i_period));
      fnd_file.put_line(fnd_file.log,'Process Upto date   : '|| to_char(to_date(i_end_date,'RR/MM/DD HH24:MI:SS'),'DD-MON-RR'));
      fnd_file.put_line(fnd_file.log,'Cost Group          : '|| to_char(i_cost_group_id));
      fnd_file.put_line(fnd_file.log,'Source              : '|| to_char(i_source_flag));
      fnd_file.put_line(fnd_file.log,'Run Option          : '|| to_char(i_run_option));
      fnd_file.put_line(fnd_file.log,'Receipt No          : '|| to_char(i_receipt_no));
      fnd_file.put_line(fnd_file.log,'Invoice No          : '|| to_char(i_invoice_no));

/* call the same Acquisition Cost Processor code with the new modified parameters */

      l_stmt_num := 20;

       Acq_cost_processor(
        i_period,
        NULL,  --i_start_date will be computed as the period start date
        l_end_date,
        i_cost_type_id,
        i_cost_group_id,
        FND_GLOBAL.USER_ID,
        FND_GLOBAL.LOGIN_ID,
        FND_GLOBAL.CONC_REQUEST_ID,
        FND_GLOBAL.CONC_PROGRAM_ID,
        FND_GLOBAL.PROG_APPL_ID,
        l_err_num,
        l_err_code,
        l_err_msg,
        2, -- source_flag
        l_receipt_no,
        l_invoice_no,
        i_adj_account);

  IF l_err_code is NOT NULL then
    RAISE CST_INVALID_EXCEPTION;

  END IF;

  COMMIT;

EXCEPTION

      WHEN others then

         fnd_file.put_line(fnd_file.log,'Exception occured in Acquisition_cost_adj_processor : ' || l_err_code || ' ' || l_err_msg);

         ROLLBACK;

          CONC_STATUS := fnd_concurrent.set_completion_status ('ERROR','CST_INVALID_EXCEPTION');
          return;

END Acquisition_cost_adj_processor;

END CSTPPACQ;

/
