--------------------------------------------------------
--  DDL for Package Body CSTPAPPR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPAPPR" AS
/* $Header: CSTAPPRB.pls 120.15.12010000.8 2010/05/01 11:33:55 lchevala ship $ */

l_debug_flag  constant VARCHAR2(1) := FND_PROFILE.VALUE('MRP_DEBUG');


/*============================================================================+
| This procedure is called by the Accounting Package for the Accounting Lib.  |
| It first gets the details of the transaction from RCV_TRANSACTIONS          |
| for the txn that is being processed. The appropriate procedure is then      |
| called to create the accounting entry lines in the form of a PL/SQL table   |
|                                                                             |
| Logic :                                                                     |
|                                                                             |
| For the transaction passed in, get the txn details from RCV_TRANSACTIONS    |
| If the current txn is period end accrual txn , call create_per_end_ae_lines |
| If the current txn is accrual txn, call create_rcv_ae_lines                 |
| Period End Accrual :                                                        |
|     If current transaction is not receive or match, return                  |
|     Get the acquisition cost, net quantity received                         |
|     Get the document level (Shipment or Distribution)                       |
|     If document level is Shipment, get all distributions against the shipmnt|
|     If document level is Distribution, get the distribution                 |
|     Loop for each distribution                                              |
|        Get the PO Price for the shipment                                    |
|        Find out the quantity Ordered at the document level                  |
|        Find out the quantity received                                       |
|        Find out the quantity invoiced                                       |
|        Find out the quantity to accrue for the current transaction (based   |
|                                        on the uninvoiced quantity)          |
|        Find out the quantity to reverse encumber (based on the uninvoiced   |
|                                       quantity and excess received quantity)|
|        Compute the amount to accrue and reverse encumber using the po price,|
|                                           nonrecoverable tax and exchg rate |
|        Debit the Expense account for the amount   to accrue                 |
|        Credit the Accrual account for the amount   to accrue                |
|        If encumbrance is on,                                                |
|          Credit the Encumbrance account for the amount to reverse encumber  |
|     Return the accounting entries created in the form of PL/SQL table       |
| On Receipt Accruals :                                                       |
|     Find out the parent transaction for transactions which are not receive  |
|                                                                  or match   |
|     Find out the Acquisition Cost and the net quantity received             |
|     Find out if current transaction is stage 1 or stage 2                   |
|                The receiving process can be divided into 2 stages:          |
|                Stage 1 : Receiving from the supplier into the receiving dock|
|                Stage 2 : Delivering to the final destination                |
|     Find out the net effect of the transaction                              |
|                Depending on the quantity, the effective action              |
|                can either be a increase in the receive/deliver direction    |
|                or an increase in the return direction                       |
|     Find out the document level of the transaction                          |
|     If document level is Shipment, get all distributions against the shipmnt|
|     If document level is Distribution, get the distribution                 |
|     Loop for each distribution                                              |
|        Get the PO Price for the shipment                                    |
|        If the destination type is not expense                               |
|           If stage 1 transaction                                            |
|               If net action is positive in receive direction                |
|                  Dr. Receiving Inspection qty@Acq_cost                      |
|                     Cr. Accrual qty@po                                      |
|                     Cr. IPV                                                 |
|                     Cr. ERV                                                 |
|                     Cr. Special Charges                                     |
|               else                                                          |
|                   Opposite of above                                         |
|           else                                                              |
|               return                                                        |
|           end if                                                            |
|        else (if expense)                                                    |
|           If stage 1 transaction                                            |
|               If net action is positive in receive direction                |
|                   Dr. Receiving Inspection qty@po                           |
|                      Cr. Accrual qty@po                                     |
|               else                                                          |
|                   Opposite of above                                         |
|           else                                                              |
|               If net action is positive in receive direction                |
|                   Dr. Expense qty@po                                        |
|                      Cr. Receiving Inspection qty@po                        |
|               else                                                          |
|                   Opposite of above                                         |
|               end if                                                        |
|               If encumbrance is on                                          |
|                   Get quantity delivered upto the current transaction       |
|                   Find out the quantity invoiced                            |
|                   Compute the quantity to reverse encumber                  |
|                   If net action is positive in receive direction            |
|                       Cr. Encumbrance <amount>                              |
|                   else                                                      |
|                       Dr. Encumbrance <amount>                              |
|                   end if                                                    |
|                end if                                                       |
|           end if                                                            |
|        end if                                                               |
|     Return the accounting entries created in the form of PL/SQL table       |
|  Call the API to insert headers and lines                                   |
|============================================================================*/

PROCEDURE create_acct_lines (
        i_legal_entity          IN      NUMBER,
        i_cost_type_id          IN      NUMBER,
        i_cost_group_id         IN      NUMBER,
        i_period_id             IN      NUMBER,
        i_transaction_id        IN      NUMBER,
        i_event_type_id         IN      VARCHAR2,
        i_txn_type_flag         IN      VARCHAR2, --Bug 4586534
        o_err_num               OUT NOCOPY      NUMBER,
        o_err_code              OUT NOCOPY      VARCHAR2,
        o_err_msg               OUT NOCOPY      VARCHAR2
)IS
        l_ae_txn_rec            CSTPALTY.CST_AE_TXN_REC_TYPE;
        l_ae_line_rec_tbl       CSTPALTY.CST_AE_LINE_TBL_TYPE := CSTPALTY.CST_AE_LINE_TBL_TYPE();
        l_ae_err_rec            CSTPALTY.CST_AE_ERR_REC_TYPE;
        l_cost_type_name        VARCHAR2(10);
        l_cost_group_name       VARCHAR2(10);
        l_period_name           VARCHAR2(15);
        l_period_end_date       DATE;
        l_xfer_cg_exists        NUMBER;
        l_po_line_count         NUMBER;
        CST_TXN_TYPE_FAIL       EXCEPTION;
        CST_DIST_PKG_ERROR      EXCEPTION;
        CST_NO_RCV_LINE         EXCEPTION;
        CST_INSERT_ERROR        EXCEPTION;

        l_stmt_num              NUMBER;
BEGIN

  l_stmt_num := 10;
  IF l_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Create_Acct_Lines <<< ');
  END IF;
  ------------------------------------------------------------------------------
  -- Determine the transaction type (Period end or on Receipt) based on the event type
  -- the event type is a concatenated string of the form
  -- Receipt transaction type
  -----------------------------------------------------------------------------
  l_stmt_num := 10;
  l_ae_txn_rec.txn_type_flag :=  i_txn_type_flag ;
  /*
  SELECT
  transaction_type_flag
  INTO
  l_ae_txn_rec.txn_type_flag
  FROM
  cst_accounting_event_types_v caet
  WHERE
  caet.event_type = i_event_type_id;
  */

  IF l_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Event type: '||(l_ae_txn_rec.txn_type_flag));
  END IF;

  IF (l_ae_txn_rec.txn_type_flag in ('RCV','ACR')) THEN

    l_ae_txn_rec.source_table := 'RT';
    l_ae_txn_rec.source_id := i_transaction_id;

    l_stmt_num := 20;

    SELECT
    count(rt.po_line_id) -- change for the bug 4968702
    INTO
    l_po_line_count
    FROM
    po_lines_all pol,
    rcv_transactions rt
    WHERE
    pol.po_line_id = rt.po_line_id AND
    rt.transaction_id = i_transaction_id;

    IF (l_po_line_count = 0) THEN
      RAISE CST_NO_RCV_LINE;
    END IF;

    l_stmt_num := 30;

    SELECT
    i_event_type_id,
    null,
    null,
    null,
    null,
    rt.transaction_type,
    rt.transaction_id,
    pol.item_id,
    i_legal_entity,
    i_cost_type_id,
    i_cost_group_id,
-- J Changes -------------------------------------------------------------------
    DECODE(POLL.MATCHING_BASIS, 'AMOUNT', rt.amount,  -- Changed for Complex work procurement
                                'QUANTITY', rt.primary_quantity),
--------------------------------------------------------------------------------
    rt.subinventory,
    null,
    null,
    null,
    null,
    rt.currency_code,
    rt.currency_conversion_type,
    nvl(rt.currency_conversion_date,transaction_date),
    nvl(rt.currency_conversion_rate,1),
    l_ae_txn_rec.txn_type_flag,
    i_period_id,
    rt.transaction_date,
    rt.organization_id,
    null,
    null,
    null,
    null,
    null,
    null,
    1,          -----  inventory_asset_flag - is not used for this package
    null,
    nvl(poll.lcm_flag,'N')
    INTO
    l_ae_txn_rec.event_type_id,
    l_ae_txn_rec.txn_action_id,
    l_ae_txn_rec.txn_src_type_id,
    l_ae_txn_rec.txn_src_id,
    l_ae_txn_rec.txn_type_id,
    l_ae_txn_rec.txn_type,
    l_ae_txn_rec.transaction_id,
    l_ae_txn_rec.inventory_item_id,
    l_ae_txn_rec.legal_entity_id,
    l_ae_txn_rec.cost_type_id,
    l_ae_txn_rec.cost_group_id,
    l_ae_txn_rec.primary_quantity,
    l_ae_txn_rec.subinventory_code,
    l_ae_txn_rec.xfer_organization_id,
    l_ae_txn_rec.xfer_subinventory,
    l_ae_txn_rec.xfer_transaction_id,
    l_ae_txn_rec.dist_acct_id,
    l_ae_txn_rec.currency_code,
    l_ae_txn_rec.currency_conv_type,
    l_ae_txn_rec.currency_conv_date,
    l_ae_txn_rec.currency_conv_rate,
    l_ae_txn_rec.ae_category,
    l_ae_txn_rec.accounting_period_id,
    l_ae_txn_rec.accounting_date,
    l_ae_txn_rec.organization_id,
    l_ae_txn_rec.mat_account,
    l_ae_txn_rec.mat_ovhd_account,
    l_ae_txn_rec.res_account,
    l_ae_txn_rec.osp_account,
    l_ae_txn_rec.ovhd_account,
    l_ae_txn_rec.flow_schedule,
    l_ae_txn_rec.exp_item ,
    l_ae_txn_rec.line_id,
    l_ae_txn_rec.lcm_flag
    FROM
    rcv_transactions rt,
    po_lines_all pol,
    po_line_locations_all poll -- Added for Complex work procurement
    WHERE
         rt.po_line_id     = pol.po_line_id
    AND  rt.transaction_id = i_transaction_id
    AND  poll.line_location_id = rt.po_line_location_id; -- Added for Complex work procurement

    l_stmt_num := 40;
    select
    displayed_field
    into
    l_ae_txn_rec.description
    from
    po_lookup_codes
    where lookup_code = l_ae_txn_rec.txn_type AND
    lookup_type = 'RCV TRANSACTION TYPE';

    l_ae_txn_rec.wip_entity_type := NULL;

--- Retro Changes ---------------------------------------------------------------
  ELSIF l_ae_txn_rec.txn_type_flag = 'ADJ' THEN
    IF l_debug_flag = 'Y' THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'RetroActive Price Adjust Event');
    END IF;
  -- Populate the transaction details from RCV_ACCOUNTING_EVENTS
    l_ae_txn_rec.source_table         := 'RAE';
    l_ae_txn_rec.source_id            := i_transaction_id;
    l_ae_txn_rec.cost_group_id        := i_cost_group_id;
    l_ae_txn_rec.legal_entity_id      := i_legal_entity;
    l_ae_txn_rec.cost_type_id         := i_cost_type_id;
    l_ae_txn_rec.accounting_period_id := i_period_id;
    l_ae_txn_rec.event_type_id        := i_event_type_id;

    -- Should selection be done from tables given that we are dealing
    -- with only one transaction type (Adjust_Receive)? NO

    l_ae_txn_rec.ae_category          := 'ADJ'; -- Transaction_Type_Flag
    l_ae_txn_rec.description          := 'Adjust Receive';

    l_stmt_num := 50;

    SELECT
      ACCOUNTING_EVENT_ID,
      TRANSACTION_DATE,
      UNIT_PRICE,
      PRIOR_UNIT_PRICE,
      PRIMARY_QUANTITY,
      CURRENCY_CODE,
      CURRENCY_CONVERSION_DATE,
      CURRENCY_CONVERSION_RATE,
      CURRENCY_CONVERSION_TYPE,
      CREDIT_ACCOUNT_ID,
      ORGANIZATION_ID,
      PO_DISTRIBUTION_ID
    INTO
      l_ae_txn_rec.transaction_id,
      l_ae_txn_rec.accounting_date,
      l_ae_txn_rec.unit_price,
      l_ae_txn_rec.prior_unit_price,
      l_ae_txn_rec.primary_quantity,
      l_ae_txn_rec.currency_code,
      l_ae_txn_rec.currency_conv_date,
      l_ae_txn_rec.currency_conv_rate,
      l_ae_txn_rec.currency_conv_type,
      l_ae_txn_rec.credit_account,
      l_ae_txn_rec.organization_id,
      l_ae_txn_rec.po_distribution_id
    FROM
      RCV_ACCOUNTING_EVENTS
    WHERE
      ACCOUNTING_EVENT_ID = i_transaction_id;

    -- Rest of the fields in l_ae_txn_rec are NULL.. Is initialization to NULL
    -- necessary

  /* changes for Global Procurement */
    /* changes for Global Procurement */
  ELSIF (l_ae_txn_rec.txn_type_flag = 'RAE') THEN

    l_ae_txn_rec.source_table := 'RAE';
    l_ae_txn_rec.source_id := i_transaction_id;

    l_stmt_num := 45;

    SELECT
    count(*)
    INTO
    l_po_line_count
    FROM
    po_lines_all pol,
    rcv_transactions rt,
    rcv_accounting_events rae
    WHERE
    pol.po_line_id = rt.po_line_id AND
    rt.transaction_id = rae.rcv_transaction_id AND
    rae.accounting_event_id = i_transaction_id;

    IF (l_po_line_count = 0) THEN
      RAISE CST_NO_RCV_LINE;
    END IF;

    l_stmt_num := 50;

    SELECT
    i_event_type_id,
    null,
    null,
    null,
    null,
    decode(rae.event_type_id, 9, 'Logical Receive', 10, 'Logical Return to Vendor'),
    rae.accounting_event_id,
    RAE.INVENTORY_ITEM_ID,
    i_legal_entity,
    i_cost_type_id,
    i_cost_group_id,
    -- Service Line Type Changes ------------------------------------------------
    -- For Services, Transaction_Value = TRANSACTION_AMOUNT
    -- To fit into existing formula, Transaction_Value = Primary_Qty * Unit_Price,
    -- we use: Primary_Quantity = TRANSACTION_AMOUNT, UNIT_PRICE = 1 in this case
    DECODE (POLL.MATCHING_BASIS, 'AMOUNT', RAE.TRANSACTION_AMOUNT,  -- Changed for Complex work procurement
                                  'QUANTITY', RAE.source_doc_quantity),
    -----------------------------------------------------------------------------
    NULL, --subinventory code Verify if reqd especially for drop ship scenarios!!
    null,
    null,
    null,
    null,
    rae.currency_code,
    rae.currency_conversion_type,
    nvl(rae.currency_conversion_date, rae.transaction_date),
    nvl(rae.currency_conversion_rate,1),
    l_ae_txn_rec.txn_type_flag,
    i_period_id,
    rae.transaction_date,
    rae.organization_id,
    null,
    null,
    null,
    null,
    null,
    null,
    1,  -----  inventory_asset_flag - is not used for this package
    null
    INTO
    l_ae_txn_rec.event_type_id,
    l_ae_txn_rec.txn_action_id,
    l_ae_txn_rec.txn_src_type_id,
    l_ae_txn_rec.txn_src_id,
    l_ae_txn_rec.txn_type_id,
    l_ae_txn_rec.txn_type,
    l_ae_txn_rec.transaction_id,
    l_ae_txn_rec.inventory_item_id,
    l_ae_txn_rec.legal_entity_id,
    l_ae_txn_rec.cost_type_id,
    l_ae_txn_rec.cost_group_id,
    l_ae_txn_rec.primary_quantity,
    l_ae_txn_rec.subinventory_code,
    l_ae_txn_rec.xfer_organization_id,
    l_ae_txn_rec.xfer_subinventory,
    l_ae_txn_rec.xfer_transaction_id,
    l_ae_txn_rec.dist_acct_id,
    l_ae_txn_rec.currency_code,
    l_ae_txn_rec.currency_conv_type,
    l_ae_txn_rec.currency_conv_date,
    l_ae_txn_rec.currency_conv_rate,
    l_ae_txn_rec.ae_category,
    l_ae_txn_rec.accounting_period_id,
    l_ae_txn_rec.accounting_date,
    l_ae_txn_rec.organization_id,
    l_ae_txn_rec.mat_account,
    l_ae_txn_rec.mat_ovhd_account,
    l_ae_txn_rec.res_account,
    l_ae_txn_rec.osp_account,
    l_ae_txn_rec.ovhd_account,
    l_ae_txn_rec.flow_schedule,
    l_ae_txn_rec.exp_item ,
    l_ae_txn_rec.line_id
    FROM
    rcv_accounting_events rae,
    po_lines_all pol,
    po_line_locations_all poll -- Added for Complex work procurement
    WHERE
    pol.po_line_id = RAE.PO_LINE_ID AND
    poll.po_line_id = pol.po_line_id AND
    poll.line_location_id = rae.po_line_location_id AND-- Added for Complex work procurement
    rae.accounting_event_id = i_transaction_id;

    l_stmt_num := 60;
    l_ae_txn_rec.description := l_ae_txn_rec.txn_type;

  ELSIF l_ae_txn_rec.txn_type_flag = 'LC ADJ' THEN
    IF l_debug_flag = 'Y' THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Landed Cost Adjust Event');
    END IF;
  -- Populate the transaction details from RCV_ACCOUNTING_EVENTS
    l_ae_txn_rec.source_table         := 'RAE';
    l_ae_txn_rec.source_id            := i_transaction_id;
    l_ae_txn_rec.cost_group_id        := i_cost_group_id;
    l_ae_txn_rec.legal_entity_id      := i_legal_entity;
    l_ae_txn_rec.cost_type_id         := i_cost_type_id;
    l_ae_txn_rec.accounting_period_id := i_period_id;
    l_ae_txn_rec.event_type_id        := i_event_type_id;
    l_ae_txn_rec.ae_category          := 'LC ADJ'; -- Transaction_Type_Flag
    l_ae_txn_rec.description          := i_event_type_id;

    l_stmt_num := 65;

    SELECT
      ACCOUNTING_EVENT_ID,
      TRANSACTION_DATE,
      UNIT_PRICE,
      PRIOR_UNIT_PRICE,
      PRIMARY_QUANTITY,
      CURRENCY_CODE,
      CURRENCY_CONVERSION_DATE,
      CURRENCY_CONVERSION_RATE,
      CURRENCY_CONVERSION_TYPE,
      CREDIT_ACCOUNT_ID,
      DEBIT_ACCOUNT_ID,
      ORGANIZATION_ID,
      PO_DISTRIBUTION_ID
    INTO
      l_ae_txn_rec.transaction_id,
      l_ae_txn_rec.accounting_date,
      l_ae_txn_rec.unit_price,
      l_ae_txn_rec.prior_unit_price,
      l_ae_txn_rec.primary_quantity,
      l_ae_txn_rec.currency_code,
      l_ae_txn_rec.currency_conv_date,
      l_ae_txn_rec.currency_conv_rate,
      l_ae_txn_rec.currency_conv_type,
      l_ae_txn_rec.credit_account,
      l_ae_txn_rec.debit_account,
      l_ae_txn_rec.organization_id,
      l_ae_txn_rec.po_distribution_id
    FROM
      RCV_ACCOUNTING_EVENTS
    WHERE
      ACCOUNTING_EVENT_ID = i_transaction_id;
  ELSE
    RAISE CST_TXN_TYPE_FAIL;
  END IF;

  l_stmt_num := 70;

  SELECT
  cost_type
  INTO
  l_cost_type_name
  FROM
  cst_cost_types
  WHERE
  cost_type_id = i_cost_type_id;

  l_stmt_num := 75;

  SELECT
  cost_group
  INTO
  l_cost_group_name
  FROM
  cst_cost_groups
  WHERE
  cost_group_id = i_cost_group_id;

  l_stmt_num := 80;

  SELECT
  period_name
  INTO
  l_period_name
  FROM
  cst_pac_periods
  WHERE
  pac_period_id = i_period_id;


  l_ae_txn_rec.description := l_ae_txn_rec.description ||' : '||l_cost_type_name||' : '||l_cost_group_name||' : '||l_period_name;


  -----------------------------------------------------------------------------
  -- Get the period name for the period being processed
  -----------------------------------------------------------------------------

  /* Get the PERIOD_END_DATE for this period. This will
     be used as the ACCOUNTING_DATE if the transaction is to be accrued at
     period end */

  l_stmt_num := 90;

  SELECT
  period_name,
  period_end_date
  INTO
  l_ae_txn_rec.accounting_period_name,
  l_period_end_date
  FROM
  cst_pac_periods
  WHERE
  pac_period_id = l_ae_txn_rec.accounting_period_id AND
  cost_type_id = l_ae_txn_rec.cost_type_id AND
  legal_entity = l_ae_txn_rec.legal_entity_id;


    l_ae_txn_rec.category_id := NULL;


  l_stmt_num := 100;

  -----------------------------------------------------------------------------
  -- Get the set of books id
  -----------------------------------------------------------------------------

  SELECT
  set_of_books_id
  INTO
  l_ae_txn_rec.set_of_books_id
  FROM
  cst_le_cost_types clct
  WHERE
  clct.legal_entity = l_ae_txn_rec.legal_entity_id AND
  clct.cost_type_id = l_ae_txn_rec.cost_type_id;

  l_stmt_num := 110;

  -----------------------------------------------------------------------------
  -- Call the Receiving procedure if txn type is RCV
  -- Call the Period End procedure if txn type is ACR
  -----------------------------------------------------------------------------

  IF (l_ae_txn_rec.txn_type_flag = 'RCV') THEN
     create_rcv_ae_lines(
        l_ae_txn_rec,
        l_ae_line_rec_tbl,
        l_ae_err_rec);
  ELSIF (l_ae_txn_rec.txn_type_flag = 'ACR') THEN
     l_ae_txn_rec.accounting_date := l_period_end_date;
     create_per_end_ae_lines(
        l_ae_txn_rec,
        l_ae_line_rec_tbl,
        l_ae_err_rec);
  ELSIF (l_ae_txn_rec.txn_type_flag = 'ADJ') THEN
     create_adj_ae_lines(
        l_ae_txn_rec,
        l_ae_line_rec_tbl,
        l_ae_err_rec);
  ELSIF (l_ae_txn_rec.txn_type_flag = 'RAE') THEN
    create_rae_ae_lines(
        l_ae_txn_rec,
        l_ae_line_rec_tbl,
        l_ae_err_rec);
  ELSIF (l_ae_txn_rec.txn_type_flag = 'LC ADJ') THEN
    create_lc_adj_ae_lines(
        l_ae_txn_rec,
        l_ae_line_rec_tbl,
        l_ae_err_rec);
  END IF;
  IF (l_ae_err_rec.l_err_num <> 0) THEN
    RAISE CST_DIST_PKG_ERROR;
  END IF;


  -----------------------------------------------------------------------------
  -- If accounting entry lines were returned by the procedure , insert into the
  -- accounting tables
  -----------------------------------------------------------------------------

  IF (l_ae_err_rec.l_err_num IS NULL OR l_ae_err_rec.l_err_num = 0) THEN
    IF (l_ae_line_rec_tbl.EXISTS(1)) THEN
    l_stmt_num := 120;
    CSTPALPC.insert_ae_lines(
        l_ae_txn_rec,
        l_ae_line_rec_tbl,
        l_ae_err_rec);
    END IF;
    IF (l_ae_err_rec.l_err_num <> 0) THEN
      RAISE CST_INSERT_ERROR;
    END IF;
  END IF;

  IF l_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Create_Acct_Lines >>> ');
  END IF;
EXCEPTION
WHEN CST_DIST_PKG_ERROR THEN
        o_err_num := 30001;
        o_err_code := SQLCODE;
        o_err_msg :=  l_ae_err_rec.l_err_msg;

WHEN CST_TXN_TYPE_FAIL THEN
        o_err_num := 30002;
        o_err_code := SQLCODE;
        o_err_msg :=  'CSTPAPPR.create_acct_lines :Invalid Transaction Type Code';

WHEN CST_NO_RCV_LINE THEN
        o_err_num := 30003;
        o_err_code := SQLCODE;
        FND_MESSAGE.set_name('BOM', 'CST_NO_RCV_LINE');
        o_err_msg := FND_MESSAGE.Get;

WHEN CST_INSERT_ERROR THEN
        o_err_num  := 30004;
        o_err_code := SQLCODE;
        o_err_msg  := 'CSTPAPPR.create_acct_lines : ' || to_char(l_stmt_num) || ':'|| substr(SQLERRM,1,180);

WHEN OTHERS THEN
  o_err_num := SQLCODE;
  o_err_code := '';
  o_err_msg := 'CSTPAPPR.create_acct_lines : ' || to_char(l_stmt_num) || ':'||
  substr(SQLERRM,1,180);

END create_acct_lines;


/*============================================================================+
| This procedure processes the transaction data and creates accounting entry  |
| lines in the form of PL/SQL table and returns to the main procedure.        |
| This procedure processes the logical accounting events                      |
|                                                                             |
| 20-Jul-03          Anju                    Creation                         |
|============================================================================*/

PROCEDURE create_rae_ae_lines(
  i_ae_txn_rec          IN     CSTPALTY.cst_ae_txn_rec_type,
  o_ae_line_rec_tbl     OUT NOCOPY    CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec          OUT NOCOPY    CSTPALTY.cst_ae_err_rec_type
) IS
  l_ae_line_tbl            CSTPALTY.CST_AE_LINE_TBL_TYPE;
  l_ae_line_rec                CSTPALTY.CST_AE_LINE_REC_TYPE;
  l_curr_rec               CSTPALTY.cst_ae_curr_rec_type;
  l_err_rec                CSTPALTY.cst_ae_err_rec_type;

  l_dr_flag                    BOOLEAN;
  l_hook                   NUMBER;
  l_stmt_num           NUMBER;
  l_debit_acct_id      NUMBER;
  l_credit_acct_id     NUMBER;
  l_po_dist_id         NUMBER;
  l_unit_price         NUMBER;
  l_rec_tax            NUMBER;
  l_nr_tax             NUMBER;
  l_rae_event          NUMBER;

  process_error        EXCEPTION;

BEGIN

if (l_debug_flag = 'Y') then
  fnd_file.put_line(fnd_file.log,'Create_Rae_Ae_Lines <<< ');
end if;

l_ae_line_tbl := CSTPALTY.cst_ae_line_tbl_type();

-- Initialize local variables.
-- ---------------------------
  l_err_rec.l_err_num := 0;
  l_err_rec.l_err_code := '';
  l_err_rec.l_err_msg := '';

-- Populate the Currency Record Type
-- ---------------------------------
  l_stmt_num := 10;


  select currency_code
  into l_curr_rec.pri_currency
  from gl_sets_of_books
  where set_of_books_id = i_ae_txn_rec.set_of_books_id;
  l_curr_rec.alt_currency := i_ae_txn_rec.currency_code;
  l_curr_rec.currency_conv_date := i_ae_txn_rec.currency_conv_date;
  l_curr_rec.currency_conv_type := i_ae_txn_rec.currency_conv_type;

  l_stmt_num := 15;

  -- J Changes --
  -- For Service Line Types, UNIT_PRICE in RAE is NULL
  -- Set L_UNIT_PRICE = 1, since PRIMARY_QTY above has been
  -- set to TRANSACTION_AMOUNT (See Note)

  select rae.debit_account_id, rae.credit_account_id,
         rae.po_distribution_id,
         DECODE(POLL.MATCHING_BASIS, 'AMOUNT', 1,  -- Changed for Complex work procurement
                                     'QUANTITY', rae.unit_price)
  into   l_debit_acct_id, l_credit_acct_id,
         l_po_dist_id,
         l_unit_price
  from rcv_accounting_events rae,
       PO_LINE_LOCATIONS_ALL POLL -- Changed for Complex work procurement
  where rae.accounting_event_id = i_ae_txn_rec.transaction_id
  and   RAE.PO_LINE_LOCATION_ID          = POLL.LINE_LOCATION_ID; -- Changed for Complex work procurement

  l_ae_line_rec.actual_flag := NULL;
  l_ae_line_rec.po_distribution_id := l_po_dist_id;

  l_stmt_num := 20;

  if(i_ae_txn_rec.txn_type = 'Logical Receive') then
    l_rae_event := 9;
    l_ae_line_rec.ae_line_type := 31;
  elsif (i_ae_txn_rec.txn_type = 'Logical Return to Vendor') then
    l_rae_event := 10;
    l_ae_line_rec.ae_line_type := 16;
  end if;

  l_dr_flag := TRUE;
  l_ae_line_rec.account := l_debit_acct_id;
  l_ae_line_rec.transaction_value := l_unit_price * i_ae_txn_rec.primary_quantity;

  l_curr_rec.currency_conv_rate := i_ae_txn_rec.currency_conv_rate;
  l_curr_rec.currency_conv_date := i_ae_txn_rec.currency_conv_date;
  l_curr_rec.currency_conv_type := i_ae_txn_rec.currency_conv_type;

   if (l_debug_flag = 'Y') then
     if (l_rae_event = 9) then
        fnd_file.put_line(fnd_file.log, 'DR Clearing: '||to_char( l_ae_line_rec.transaction_value *  l_curr_rec.currency_conv_rate ));
   elsif (l_rae_event = 10) then
        fnd_file.put_line(fnd_file.log, 'DR Accrual: '||to_char( l_ae_line_rec.transaction_value *  l_curr_rec.currency_conv_rate ));
     end if;
   end if;

    IF ( i_ae_txn_rec.primary_quantity = 0 ) THEN
         l_ae_line_rec.rate_or_amount := 0;
    ELSE
         l_ae_line_rec.rate_or_amount := l_ae_line_rec.transaction_value * l_curr_rec.currency_conv_rate / i_ae_txn_rec.primary_quantity ;
    END IF;

    l_stmt_num := 30;

    CSTPAPPR.insert_account (i_ae_txn_rec,
                                      l_curr_rec,
                                      l_dr_flag,
                                      l_ae_line_rec,
                                      l_ae_line_tbl,
                                      l_err_rec);

    if (l_err_rec.l_err_num <>0 and l_err_rec.l_err_num is not null) then
        raise process_error;
    end if;

             -------------------------------------------
             -- Toggle the debit flag
             -------------------------------------------

          l_dr_flag := not l_dr_flag;

          l_stmt_num := 40;


                 l_ae_line_rec.account := l_credit_acct_id;

            if(l_rae_event = 9) then
                     l_ae_line_rec.ae_line_type := 16;
            elsif ( l_rae_event = 10) then
                     l_ae_line_rec.ae_line_type := 31;
             end if;

        l_ae_line_rec.transaction_value := l_unit_price * i_ae_txn_rec.primary_quantity;

        l_curr_rec.currency_conv_rate := i_ae_txn_rec.currency_conv_rate;
            l_curr_rec.currency_conv_date := i_ae_txn_rec.currency_conv_date;
        l_curr_rec.currency_conv_type := i_ae_txn_rec.currency_conv_type;

        l_stmt_num := 50;
      if (l_debug_flag = 'Y') then
          if (l_rae_event = 9) then
               fnd_file.put_line(fnd_file.log,'CR Accrual: '||to_char( l_ae_line_rec.transaction_value *  l_curr_rec.currency_conv_rate ));
             ELSE
               fnd_file.put_line(fnd_file.log,'CR Accrual: '||to_char( l_ae_line_rec.transaction_value *  l_curr_rec.currency_conv_rate ));
             END IF;
      end if;

             IF ( i_ae_txn_rec.primary_quantity = 0) THEN
               l_ae_line_rec.rate_or_amount := 0;
             ELSE
               l_ae_line_rec.rate_or_amount := l_ae_line_rec.transaction_value * l_curr_rec.currency_conv_rate / i_ae_txn_rec.primary_quantity ;
             END IF;

             CSTPAPPR.insert_account (i_ae_txn_rec,
                                      l_curr_rec,
                                      l_dr_flag,
                                      l_ae_line_rec,
                                      l_ae_line_tbl,
                                      l_err_rec);
             IF (l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
                raise process_error;
             END IF;


-- Take care of rounding errors.
-- -----------------------------
    l_stmt_num := 80;
    balance_account (l_ae_line_tbl,
                     l_err_rec);

    -- check error
    if (l_err_rec.l_err_num <> 0) then
        raise process_error;
    end if;


  -- Return the lines pl/sql table.
  -- ------------------------------
    l_stmt_num := 90;
    o_ae_line_rec_tbl := l_ae_line_tbl;

    if (l_debug_flag = 'Y') then
      fnd_file.put_line(fnd_file.log,'Create_Rae_Ae_Lines >>>');
    end if;

EXCEPTION

  when process_error then
  o_ae_err_rec.l_err_num := l_err_rec.l_err_num;
  o_ae_err_rec.l_err_code := l_err_rec.l_err_code;
  o_ae_err_rec.l_err_msg := l_err_rec.l_err_msg;

  when others then
  o_ae_err_rec.l_err_num := SQLCODE;
  o_ae_err_rec.l_err_code := '';
  o_ae_err_rec.l_err_msg := 'CSTPAPPR.create_rae_ae_lines : ' || to_char(l_stmt_num) || ':'||
  substr(SQLERRM,1,180);

END create_rae_ae_lines;

/*============================================================================+
| This procedure processes the transaction data and creates accounting entry  |
| lines in the form of PL/SQL table and returns to the main procedure.        |
| This procedure processes the normal receiving transactions (not period end  |
| accruals)                                                                   |
|============================================================================*/

PROCEDURE create_rcv_ae_lines(
  i_ae_txn_rec          IN     CSTPALTY.cst_ae_txn_rec_type,
  o_ae_line_rec_tbl     OUT NOCOPY    CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec          OUT NOCOPY    CSTPALTY.cst_ae_err_rec_type
) IS
  l_ae_line_tbl                CSTPALTY.CST_AE_LINE_TBL_TYPE;
  l_ae_line_rec                CSTPALTY.CST_AE_LINE_REC_TYPE;
  l_curr_rec                   CSTPALTY.cst_ae_curr_rec_type;
  l_err_rec                    CSTPALTY.cst_ae_err_rec_type;
  l_par_rcv_txn                NUMBER;
  l_stage                      NUMBER;
  l_par_txn_type               VARCHAR2(20);
  l_par_txn                    NUMBER;
  l_net_receipt                NUMBER;
  l_doc_level                  VARCHAR2(1);
  l_doc_id                     NUMBER;
  l_dist_count                 NUMBER;
  l_acq_exists                 NUMBER;
  l_nqr                        NUMBER;
  l_costed_quantity            NUMBER;
  l_acq_cost                   NUMBER;
  l_acq_cost_ent_inv           NUMBER;
  l_acq_cost_ent_po            NUMBER;
  l_acq_cost_ent               NUMBER;
  l_quantity_invoiced          NUMBER;
  l_encum_amount               NUMBER;
  l_application_id             NUMBER;
  l_purch_encumbrance_type_id  NUMBER;
  l_purch_encumbrance_flag     VARCHAR2(1);
  l_match_option               VARCHAR2(25);
  l_quantity_ordered           NUMBER;
  l_tot_nqr                    NUMBER;
  l_enc_flag                   VARCHAR2(1);
  l_bud_enc_flag               VARCHAR2(1);
  l_dr_flag                    BOOLEAN;
  l_po_rate                    NUMBER;
  l_po_rate_date               DATE;
  l_po_price                   NUMBER;
  l_hook                       NUMBER;
  l_stmt_num                   NUMBER;

  l_correct_ipv_amount         NUMBER;
  l_total_ipv                  NUMBER;

  l_receive   CONSTANT VARCHAR2(30) := 'RECEIVE';
  l_correct   CONSTANT VARCHAR2(30) := 'CORRECT';
  l_rtv       CONSTANT VARCHAR2(30) := 'RETURN TO VENDOR';
  l_rtr       CONSTANT VARCHAR2(30) := 'RETURN TO RECEIVING';
  l_match     CONSTANT VARCHAR2(30) := 'MATCH';
  l_deliver   CONSTANT VARCHAR2(30) := 'DELIVER';
  l_quantity_delivered         NUMBER;
  l_dropship_type_code         NUMBER := 0; -- FP Bug 5845861

  l_debit_account              number;
  l_credit_account             number;
  process_error                EXCEPTION;
  CST_NO_PO_DIST               EXCEPTION;

  l_po_ou_id                   NUMBER; /* Bug 5555888 */
  l_rcv_ou_id                  NUMBER; /* Bug 5555888 */
  l_ledger_id                  NUMBER; /* BUG 9113487 */
BEGIN

  IF l_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Create_Rcv_Ae_Lines <<< ');
  END IF;
l_ae_line_tbl := CSTPALTY.cst_ae_line_tbl_type();

-- Initialize local variables.
-- ---------------------------
  l_err_rec.l_err_num := 0;
  l_err_rec.l_err_code := '';
  l_err_rec.l_err_msg := '';

-- Populate the Currency Record Type
-- ---------------------------------
  l_stmt_num := 10;


  select currency_code
  into l_curr_rec.pri_currency
  from gl_sets_of_books
  where set_of_books_id = i_ae_txn_rec.set_of_books_id;

   /* BUG 9113487 */
  l_stmt_num := 15;

  SELECT ledger_id
  into l_ledger_id
  FROM  cst_acct_info_v  WHERE
  organization_id=i_ae_txn_rec.organization_id;

  l_curr_rec.alt_currency := i_ae_txn_rec.currency_code;
  l_curr_rec.currency_conv_date := i_ae_txn_rec.currency_conv_date;
  l_curr_rec.currency_conv_type := i_ae_txn_rec.currency_conv_type;

    --------------------------------------------------------
    -- First set the parent transaction id as the transaction id itself
    --------------------------------------------------------

    l_par_rcv_txn := i_ae_txn_rec.transaction_id;

    ----------------------------------------------------------
    -- If the transaction type is NOT receive or MATCH,
    -- then it has a parent
    ----------------------------------------------------------

    IF (i_ae_txn_rec.txn_type <> l_receive) AND (i_ae_txn_rec.txn_type <> l_match) THEN

       l_stmt_num := 20;

       SELECT
       rt6.transaction_id
       INTO
       l_par_rcv_txn
       FROM
       rcv_transactions rt6
       WHERE
       rt6.transaction_type in (l_receive,l_match)
       START WITH
       rt6.transaction_id = i_ae_txn_rec.transaction_id
       CONNECT BY
       rt6.transaction_id = prior rt6.parent_transaction_id;


       IF l_debug_flag = 'Y' THEN
         fnd_file.put_line(fnd_file.log,'Parent Receive Txn: '||to_char(l_par_rcv_txn));
       END IF;

    END IF; /*end if receipt or match*/

    ------------------------------------------------------
    -- Get the acquisition cost for the transaction
    ------------------------------------------------------

    l_stmt_num := 30;

    SELECT
    count(rcv_transaction_id) -- change for the bug 4968702
    INTO
    l_acq_exists
    FROM
    cst_rcv_acq_costs crac
    WHERE
    crac.rcv_transaction_id = l_par_rcv_txn AND
    crac.cost_type_id = i_ae_txn_rec.cost_type_id AND
    crac.cost_group_id = i_ae_txn_rec.cost_group_id;

    IF (l_acq_exists > 0) THEN


       l_stmt_num := 32;

       SELECT
       crac.net_quantity_received,
       crac.costed_quantity,
       crac.acquisition_cost
       INTO
       l_nqr,
       l_costed_quantity,
       l_acq_cost
       from cst_rcv_acq_costs crac
       where crac.rcv_transaction_id = l_par_rcv_txn AND
       crac.cost_type_id = i_ae_txn_rec.cost_type_id AND
       crac.cost_group_id = i_ae_txn_rec.cost_group_id;

       IF (l_nqr = 0 AND nvl(i_ae_txn_rec.lcm_flag,'N') = 'N' ) THEN
         IF l_debug_flag = 'Y' THEN
           fnd_file.put_line(fnd_file.log, 'The Net Quantity Received is Zero');
         END IF;
         return;
       END IF;

       -------------------------------------------------
       -- Get the acquisition cost in the entered currency
       -- Bug # 1054868
       -------------------------------------------------

       -------------------------------------------------
       -- Joining with ap_invoices_all in order to get the
       -- exchange rate.  This is a result of AP's Invoice
       -- Lines Project
       -------------------------------------------------

       l_stmt_num := 33;

       select
       sum(cracd.amount/NVL(aia.exchange_rate,1))
       into
       l_acq_cost_ent_inv
       from
       cst_rcv_acq_cost_details cracd,
       ap_invoice_distributions_all aida,
       ap_invoices_all aia
       where
       aida.invoice_distribution_id = cracd.invoice_distribution_id
       and aia.invoice_id = aida.invoice_id
       and aia.org_id = aida.org_id
       and cracd.header_id = (select header_id
         from cst_rcv_acq_costs crac
         where rcv_transaction_id = l_par_rcv_txn
       AND
       crac.cost_type_id = i_ae_txn_rec.cost_type_id AND
       crac.cost_group_id = i_ae_txn_rec.cost_group_id)
       and cracd.source_type = 'INVOICE';

       l_stmt_num := 34;

       select
       sum(cracd.amount/ decode(poll.match_option,
                                'P',CSTPPACQ.get_po_rate(rt.transaction_id),
                                'R',CSTPPACQ.get_rcv_rate(rt.transaction_id)))
       into
       l_acq_cost_ent_po
       from
       cst_rcv_acq_cost_details cracd,
       po_line_locations_all poll,
       rcv_transactions rt
       where
       poll.line_location_id = cracd.po_line_location_id
       and cracd.header_id = (select header_id
         from cst_rcv_acq_costs crac
         where rcv_transaction_id = rt.transaction_id
       AND
       crac.cost_type_id = i_ae_txn_rec.cost_type_id AND
       crac.cost_group_id = i_ae_txn_rec.cost_group_id)
       and rt.transaction_id = l_par_rcv_txn
       and rt.po_line_location_id = poll.line_location_id
       and cracd.source_type = 'PO';
       IF (l_acq_cost_ent_po < 0) THEN
         IF l_debug_flag = 'Y' THEN
           fnd_file.put_line(fnd_file.log,'Error: No Acquisition Rate');
         END IF;
         l_err_rec.l_err_num := 999;
         raise process_error;
       END IF;
       /* Added nvl as fix for bug 2265867 */
       IF (l_costed_quantity <> 0) THEN
       l_acq_cost_ent := (nvl(l_acq_cost_ent_inv,0) + nvl(l_acq_cost_ent_po,0))/l_costed_quantity;
       ELSE
       l_acq_cost_ent := 0;
       END IF;
    ELSE
         IF l_debug_flag = 'Y' THEN
           fnd_file.put_line(fnd_file.log,'No Acquisition Cost');
         END IF;
       return;
    END IF;


    ----------------------------------------------------------------
    -- The receiving process can be divided into 2 stages:
    -- Stage 1 : Receiving from the supplier into the receiving dock
    -- Stage 2 : Delivering to the final destination
    -- Stage 1 transactions are :
    --     RECEIVE
    --     CORRECTION TO RECEIVE
    --     MATCH
    --     RETURN TO VENDOR
    --     CORRECTION TO RETURN TO VENDOR
    -- Stage 2 transactions are :
    --     DELIVER
    --     CORRECTION TO DELIVER
    --     RETURN TO RECEIVING
    --     CORRECTION TO RETURN TO RECEIVING
    -----------------------------------------------------------------

    -----------------------------------------------------------------
    -- First set the stage flag to 0
    -- Then determine the stage for the current transaction
    -----------------------------------------------------------------

    l_stage := 0;

    IF (i_ae_txn_rec.txn_type in (l_receive,l_match,l_rtv)) THEN
       l_stage := 1;
    ELSIF (i_ae_txn_rec.txn_type in (l_deliver,l_rtr)) THEN
       l_stage := 2;
    END IF;


    IF (i_ae_txn_rec.txn_type = l_correct) THEN

          l_stmt_num := 50;

          SELECT
          rt1.transaction_id,
          rt1.transaction_type
          INTO
          l_par_txn,
          l_par_txn_type
          FROM
          rcv_transactions rt1
          WHERE
          rt1.transaction_id = (select rt2.parent_transaction_id
          FROM
          rcv_transactions rt2
          WHERE
          rt2.transaction_id = i_ae_txn_rec.transaction_id);

     END IF;

 ------------------------------------------------------------------------------
 -- Depending on the quantity, the effective action of the current transaction
 -- can either be a increase in the receive/deliver direction
 -- or an increase in the return direction
 -- The following are increase in the receive/deliver direction :
 -- RECEIVE/MATCH
 -- DELIVER
 -- POSITIVE CORRECTION TO RECEIVE/DELIVER/MATCH
 -- NEGATIVE CORRECTION TO RTV/RTR
 -- The following are increase in the return direction :
 -- RETURN TO VENDOR
 -- RETURN TO RECEIVING
 -- POSITIVE CORRECTION TO RTV/RTR
 -- NEGATIVE CORRECTION TO RECEIVE/DELIVER/MATCH
 ------------------------------------------------------------------------------

    IF (i_ae_txn_rec.txn_type = l_correct) THEN
         IF l_debug_flag = 'Y' THEN
          fnd_file.put_line(fnd_file.log,'Parent of Correct: '||l_par_txn_type);
          fnd_file.put_line(fnd_file.log,'Quantity: '||to_char(i_ae_txn_rec.primary_quantity));
         END IF;

          IF (l_par_txn_type in (l_receive,l_match,l_rtv)) THEN
             l_stage := 1;
          ELSE
             l_stage := 2;
          END IF;
          IF (l_par_txn_type in (l_receive,l_match,l_deliver) and i_ae_txn_rec.primary_quantity > 0) OR (l_par_txn_type in (l_rtv,l_rtr) and  i_ae_txn_rec.primary_quantity < 0) THEN
            l_net_receipt := 1;
          ELSE
            l_net_receipt := -1;
          END IF;

    ELSIF (i_ae_txn_rec.txn_type in (l_rtv,l_rtr)) THEN
          l_net_receipt := -1;
    ELSE
          l_net_receipt := 1;
    END IF;
    IF l_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'Net Receipt or Return: '||to_char(l_net_receipt));
    END IF;
    ------------------------------------------------------------
    -- A receipt can be at the shipment level or the distribution level:
    -- When receiving and delivering in one step, it is at the distribution level
    -- When receiving and delivering as two different steps, it is shipment level
    -- Get the document level as 'S' for shipment and 'D' for distribution
    ------------------------------------------------------------


    l_stmt_num := 60;

    SELECT
    decode(rt.po_distribution_id, NULL, 'S', 'D'),
    nvl(rt.po_distribution_id, rt.po_line_location_id)
    INTO
    l_doc_level,
    l_doc_id
    FROM
    rcv_transactions rt
    WHERE
    rt.transaction_id = i_ae_txn_rec.transaction_id;

    IF l_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'Document Level: '||l_doc_level);
      fnd_file.put_line(fnd_file.log,'Document ID: '||to_char(l_doc_id));
      fnd_file.put_line(fnd_file.log,'Quantity: '||to_char(i_ae_txn_rec.primary_quantity));
    END IF;

    SELECT
    count(*)
    into
    l_dist_count
    FROM
    po_distributions_all
    WHERE
-- begin fix for perf bug 2581067
    (
      (l_doc_level = 'D' AND po_distribution_id = l_doc_id)
      OR (l_doc_level = 'S' AND line_location_id = l_doc_id)
    )
    AND rownum <= 1;
-- end fix for perf bug 2581067. replaced the following:

    IF (l_dist_count = 0) THEN
      IF l_debug_flag = 'Y' THEN
        fnd_file.put_line(fnd_file.log,'Error: No Distributions for Document: '||to_char(l_doc_id));
      END IF;
      RAISE CST_NO_PO_DIST;
    END IF;


    ------------------------------------------------------------------
    -- If the document level is Shipment, get all the distributions
    -- for the Shipment, against which the receipt occurred.
    -- If the document level is Distribution, get the distribution
    -- Loop for each distribution that is accrue at receipt
    ------------------------------------------------------------------

    DECLARE
      CURSOR c_receive_dists IS
        SELECT
        decode (poll.match_option,'R',i_ae_txn_rec.currency_conv_rate,nvl(pod.rate,decode(l_acq_cost_ent,0,1,l_acq_cost/l_acq_cost_ent))) "EXCHG_RATE",
        decode (poll.match_option,'R',i_ae_txn_rec.currency_conv_date,pod.rate_date) "EXCHG_DATE",
-- J Changes -------------------------------------------------------------------------
        DECODE(POLL.MATCHING_BASIS, 'AMOUNT', 1,   -- Changed for Complex work procurement
                                    'QUANTITY', 0 ) "SERVICE_FLAG",
--------------------------------------------------------------------------------------
        POD.po_distribution_id "PO_DISTRIBUTION_ID",
        POLL.line_location_id "PO_LINE_LOCATION_ID",
        POD.code_combination_id "EXPENSE_ACCOUNT_ID",
        POD.destination_type_code "DESTINATION_TYPE_CODE",
        decode(l_dropship_type_code, 2, RP.clearing_account_id, RP.receiving_account_id) "RECEIVING_ACCOUNT_ID", -- FP Bug 5845861 fix: pickup the clearing account for DS with old accounting
        POD.accrual_account_id "ACCRUAL_ACCOUNT_ID",
        nvl(POD.budget_account_id,-1) "ENCUMBRANCE_ACCOUNT_ID",
        decode(l_doc_level,'D', 1, DECODE(POLL.MATCHING_BASIS,  -- Changed for Complex work procurement
                                             'AMOUNT', POD.AMOUNT_ORDERED/POLL.AMOUNT,
                                             'QUANTITY',POD.QUANTITY_ORDERED/POLL.QUANTITY))
               * i_ae_txn_rec.primary_quantity "DIST_QUANTITY",
-- J Changes ----------------------------------------------------------------------------
        (po_tax_sv.get_tax('PO',pod.po_distribution_id) /
                                DECODE(POLL.MATCHING_BASIS, 'AMOUNT', POD.AMOUNT_ORDERED, -- Changed for Complex work procurement
                                                            'QUANTITY',POD.QUANTITY_ORDERED) ) "TAX"
-----------------------------------------------------------------------------------------
        FROM
        po_distributions_all pod,
        po_line_locations_all poll,
-- J Changes ----------------------------------------------------------------------------
        PO_LINES_ALL POL,
-----------------------------------------------------------------------------------------
        rcv_parameters rp
        WHERE
-- begin fix for perf bug 2581067
        (
           (l_doc_level = 'D' AND pod.po_distribution_id = l_doc_id)
        OR (l_doc_level = 'S' AND poll.line_location_id = l_doc_id)
        )
-- end fix for perf bug 2581067
        and pod.line_location_id                 = poll.line_location_id
-- J Changes ----------------------------------------------------------------------------
        AND POLL.PO_LINE_ID                      = POL.PO_LINE_ID
-----------------------------------------------------------------------------------------
        and rp.organization_id                   = pod.destination_organization_id
        and pod.destination_type_code            in ('INVENTORY', 'SHOP FLOOR')
        and nvl(POLL.accrue_on_receipt_flag,'N') = 'Y'
/* and nvl(POD.accrue_on_receipt_flag,'N')  = 'Y' */;

        l_lcm_adj_period   NUMBER;
	l_landed_cost_abs_account NUMBER;

    BEGIN
        SELECT nvl(max(LANDED_COST_ABS_ACCOUNT),-1)
	INTO l_landed_cost_abs_account
	 FROM CST_ORG_COST_GROUP_ACCOUNTS coga
	 WHERE coga.legal_entity_id = i_ae_txn_rec.legal_entity_id
	   AND coga.cost_type_id = i_ae_txn_rec.cost_type_id
	   AND coga.cost_group_id = i_ae_txn_rec.cost_group_id;

        FOR c_receipts_rec IN c_receive_dists LOOP
          l_stmt_num := 62;
          l_ae_line_rec.actual_flag := NULL;
          l_ae_line_rec.po_distribution_id := c_receipts_rec.po_distribution_id;

          ---------------------------------------------------------
          -- The PO Price is in terms of the PO UOM
          -- Convert it in terms of the primary UOM for the item
          ---------------------------------------------------------

          SELECT
-- J Changes ----------------------------------------------------------------------------
          DECODE(C_RECEIPTS_REC.SERVICE_FLAG, 1, 1,
                 (poll.price_override * rt.source_doc_quantity / rt.primary_quantity))
-----------------------------------------------------------------------------------------
          INTO
          l_po_price
          FROM
          rcv_transactions rt,
          po_line_locations_all poll
          WHERE
          rt.transaction_id = i_ae_txn_rec.transaction_id
          AND rt.po_line_location_id = poll.line_location_id;



          --------------------------------------------------------------------
          -- For Expense destinations, both stage 1 and stage 2 transactions are processed
          -- For Inventory and Shop floor, only stage 1 transactions are processed
          --       the stage 2 transactions are populated in the MMT and WT tables
          --       and are processed by the INV and WIP processor
          --------------------------------------------------------------------

          --IF (c_receipts_rec.destination_type_code <> 'EXPENSE') THEN

            IF (l_stage = 1) THEN
              IF (nvl(i_ae_txn_rec.lcm_flag,'N') = 'Y') THEN
	     /*LCM PO
	     -- If net action is receive, the following accounting
	     -- needs to be generated
             --   Dr. Receiving Inspection qty@Acq_cost
             --     Cr. Accrual qty@po
             --   Dr./Cr. Landed Cost Absorption
             -- If net action is returns, the following accounting
	     -- needs to be generated
             --   Dr. Accrual qty@po
             --     Cr. Receiving Inspection qty@acq_cost
             --   Dr./Cr. Landed Cost Absorption
             */
	        l_curr_rec.currency_conv_rate := c_receipts_rec.exchg_rate;
                l_curr_rec.currency_conv_date := c_receipts_rec.exchg_date;
                l_curr_rec.currency_conv_type := i_ae_txn_rec.currency_conv_type;

		IF (l_net_receipt = 1) THEN
                  l_dr_flag := FALSE;
                ELSE
                  l_dr_flag := TRUE;
                END IF;

                l_ae_line_rec.ae_line_type := 16;
		l_ae_line_rec.account := c_receipts_rec.accrual_account_id;
                l_ae_line_rec.transaction_value := c_receipts_rec.dist_quantity * (l_po_price + c_receipts_rec.tax);
                /* Accrual entries need to be rounded in receiving currency
		   first to match the invoicing logic.
		*/
		l_stmt_num := 1000;
                SELECT decode(c2.minimum_accountable_unit,
                              NULL,round(l_ae_line_rec.transaction_value,c2.precision),
                             round(l_ae_line_rec.transaction_value/c2.minimum_accountable_unit)
                                  * c2.minimum_accountable_unit )
		 INTO l_ae_line_rec.transaction_value
		FROM fnd_currencies c2
	        WHERE c2.currency_code = decode(l_curr_rec.alt_currency, NULL,
                                                l_curr_rec.pri_currency,
                                                l_curr_rec.alt_currency);



               IF l_debug_flag = 'Y' THEN
                 IF (l_dr_flag) THEN
                   fnd_file.put_line(fnd_file.log,'DR Accrual: '||to_char( l_ae_line_rec.transaction_value *  l_curr_rec.currency_conv_rate ));
                 ELSE
                 fnd_file.put_line(fnd_file.log,'CR Accrual: '||to_char( l_ae_line_rec.transaction_value *  l_curr_rec.currency_conv_rate ));
                 END IF;
               END IF;

               IF ( c_receipts_rec.dist_quantity = 0 ) THEN
                 l_ae_line_rec.rate_or_amount := 0;
               ELSE
                 l_ae_line_rec.rate_or_amount := l_ae_line_rec.transaction_value * l_curr_rec.currency_conv_rate / c_receipts_rec.dist_quantity ;
               END IF;

               l_stmt_num := 1010;
               CSTPAPPR.insert_account (i_ae_txn_rec,
                                        l_curr_rec,
                                        l_dr_flag,
                                        l_ae_line_rec,
                                        l_ae_line_tbl,
                                        l_err_rec);
               IF (l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null) then
                  raise process_error;
               END IF;

               l_dr_flag := not l_dr_flag;
               l_stmt_num := 1020;
		SELECT nvl(max(craca.period_id),-1)
		 INTO l_lcm_adj_period
		FROM cst_rcv_acq_costs_adj craca
		 WHERE craca.rcv_transaction_id = l_par_rcv_txn
		   AND craca.cost_type_id = i_ae_txn_rec.cost_type_id
		   AND craca.cost_group_id = i_ae_txn_rec.cost_group_id;

		IF (l_lcm_adj_period <> -1) THEN
                 l_stmt_num := 1030;
		  SELECT craca.acquisition_cost
		   INTO l_acq_cost
                  FROM cst_rcv_acq_costs_adj craca
		 WHERE craca.rcv_transaction_id = l_par_rcv_txn
		   AND craca.cost_type_id = i_ae_txn_rec.cost_type_id
		   AND craca.cost_group_id = i_ae_txn_rec.cost_group_id
		   AND craca.period_id = l_lcm_adj_period;

		END IF;
                l_acq_cost_ent := l_acq_cost/c_receipts_rec.exchg_rate;
                l_ae_line_rec.account := c_receipts_rec.receiving_account_id;
                l_ae_line_rec.ae_line_type := 5;
                l_ae_line_rec.transaction_value := c_receipts_rec.dist_quantity * l_acq_cost_ent;
                l_stmt_num := 1040;
		SELECT decode(c2.minimum_accountable_unit,
                              NULL,round(l_ae_line_rec.transaction_value,c2.precision),
                             round(l_ae_line_rec.transaction_value/c2.minimum_accountable_unit)
                                  * c2.minimum_accountable_unit )
		 INTO l_ae_line_rec.transaction_value
		FROM fnd_currencies c2
	        WHERE c2.currency_code = decode(l_curr_rec.alt_currency, NULL,
                                                l_curr_rec.pri_currency,
                                                l_curr_rec.alt_currency);

                IF l_debug_flag = 'Y' THEN
                   IF (l_dr_flag) THEN
                    fnd_file.put_line(fnd_file.log,'DR RI: '||to_char( l_ae_line_rec.transaction_value *  l_curr_rec.currency_conv_rate ));
                   ELSE
                    fnd_file.put_line(fnd_file.log,'CR RI: '||to_char( l_ae_line_rec.transaction_value *  l_curr_rec.currency_conv_rate ));
                   END IF;
                END IF;

                IF ( c_receipts_rec.dist_quantity = 0 ) THEN
                   l_ae_line_rec.rate_or_amount := 0;
                ELSE
                   l_ae_line_rec.rate_or_amount := l_ae_line_rec.transaction_value * l_curr_rec.currency_conv_rate / c_receipts_rec.dist_quantity ;
                END IF;
                l_stmt_num := 1050;
                CSTPAPPR.insert_account (i_ae_txn_rec,
                                         l_curr_rec,
                                         l_dr_flag,
                                         l_ae_line_rec,
                                         l_ae_line_tbl,
                                         l_err_rec);
                if (l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null) then
                    raise process_error;
                end if;

                IF ( l_acq_cost_ent<>(l_po_price + c_receipts_rec.tax)) THEN
		  IF ((l_po_price + c_receipts_rec.tax)>l_acq_cost_ent) THEN
		    IF (l_net_receipt = 1) THEN
                      l_dr_flag := TRUE;
		     ELSE
		      l_dr_flag := FALSE;
		     END IF;
                  ELSE
		    IF (l_net_receipt = 1) THEN
                      l_dr_flag := FALSE;
		    ELSE
		      l_dr_flag := TRUE;
		    END IF;
                  END IF;
                  l_ae_line_rec.account := l_landed_cost_abs_account;
                  l_ae_line_rec.ae_line_type := 38;
                  l_ae_line_rec.transaction_value := abs(c_receipts_rec.dist_quantity *
		                                        ((l_po_price + c_receipts_rec.tax)-l_acq_cost_ent)) ;
                  l_stmt_num := 1060;
		  SELECT decode(c2.minimum_accountable_unit,
                                NULL,round(l_ae_line_rec.transaction_value,c2.precision),
                               round(l_ae_line_rec.transaction_value/c2.minimum_accountable_unit)
                                    * c2.minimum_accountable_unit )
		   INTO l_ae_line_rec.transaction_value
		  FROM fnd_currencies c2
	          WHERE c2.currency_code = decode(l_curr_rec.alt_currency, NULL,
                                                  l_curr_rec.pri_currency,
                                                  l_curr_rec.alt_currency);

                IF l_debug_flag = 'Y' THEN
                   IF (l_dr_flag) THEN
                    fnd_file.put_line(fnd_file.log,'DR Landed Cost Abs: '||to_char( l_ae_line_rec.transaction_value *  l_curr_rec.currency_conv_rate ));
                   ELSE
                    fnd_file.put_line(fnd_file.log,'CR Landed Cost Abs: '||to_char( l_ae_line_rec.transaction_value *  l_curr_rec.currency_conv_rate ));
                   END IF;
                END IF;

                IF ( c_receipts_rec.dist_quantity = 0 ) THEN
                   l_ae_line_rec.rate_or_amount := 0;
                ELSE
                   l_ae_line_rec.rate_or_amount := l_ae_line_rec.transaction_value * l_curr_rec.currency_conv_rate / c_receipts_rec.dist_quantity ;
                END IF;
                l_stmt_num := 1070;
                CSTPAPPR.insert_account (i_ae_txn_rec,
                                         l_curr_rec,
                                         l_dr_flag,
                                         l_ae_line_rec,
                                         l_ae_line_tbl,
                                         l_err_rec);

                  if (l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null) then
                    raise process_error;
                  end if;

		END IF;

	      ELSE
             ----------------------------------------------------------
             -- If net action is receive, the following accounting needs to be generated
             --   Dr. Receiving Inspection qty@Acq_cost
             --     Cr. Accrual qty@po
             --   Dr./Cr. IPV
             --   Dr./Cr. Special charges
             --   Dr./Cr. ERV
             -- If net action is returns, the following accounting needs to be generated
             --   Dr. Accrual qty@po
             --     Cr. Receiving Inspection qty@acq_cost
             --   Dr./Cr. IPV
             --   Dr./Cr. Special charges
             --   Dr./Cr. ERV
             --
             -- Example :
             --
             -- PO Shipment qty = 100 po price $10 each
             -- PO Distributions :
             --              40  tax = $40  p.u.tax = 40/40=1
             --              60  tax = $30 p.u.tax = 30/60=0.5
             -- Receive 50 against shipment
             -- Invoice 10@12 against Receipt
             --        + Tax $10  p.u.tax=10/10=1
             --        + Freight $40
             --          + Tax on Freight $2
             --     POD #1
             --        Dr. Accrual 0.4*10*(10+1)=44
             --          Cr. Liability 0.4*(120+10+40+2)=68.8
             --        Dr. IPV 0.4*10*(12-10) = 8
             --        Dr. Tax IPV 0.4*10*(1-1)=0
             --        Dr. Freight Expense 0.4*40=16
             --        Dr. Tax Expense 0.4*2=0.8
             --     POD #2
             --        Dr. Accrual 0.6*10*(10+0.5)=63
             --          Cr. Liability 0.6*(120+10+40+5)=103.2
             --        Dr. IPV 0.6*10*(12-10) = 12
             --        Dr. Tax IPV 0.6*10*(1-0.5)=3
             --        Dr. Freight Expense 0.6*40=24
             --        Dr. Tax Expense 0.6*2=1.2
             -- Acquisition Cost = (10*12 + 10 + 40 + 2 + 40*11*0.4 + 40*10.5*0.6)/50 =
             -- 12
             --
             -- For each distribution :
             -- POD #1 :
             -- Dr. RI 50*40/100*12 = 240
             --   Cr. Accrual 50*40/100*(10 + 1) = 220
             --   Cr. IPV (8/50)*50=8
             --   Cr. Tax IPV (0/50)*50=0
             --   Cr. Freight Expense (16/50)*50=16
             --   Cr. Tax Expense (0.8/50)*50=0.8
             -- POD #2 :
             -- Dr. RI 50*60/100*12 = 360
             --   Cr. Accrual 50*60/100*(10 + 0.5) = 315
             --   Cr. IPV (12/50)*50*=12
             --   Cr. Tax IPV (3/50)*50=3
             --   Cr. Freight Expense (24/50)*50=24
             --   Cr. Tax Expense (1.2/50)*50=1.2
             -- Total Debits : 600
             -- Total Credits : 600
             ----------------------------------------------------------

             IF (l_net_receipt = 1) THEN
               l_dr_flag := TRUE;
             ELSE
               l_dr_flag := FALSE;
             END IF;

             l_ae_line_rec.account := c_receipts_rec.receiving_account_id;
             l_ae_line_rec.ae_line_type := 5;
             l_ae_line_rec.transaction_value := c_receipts_rec.dist_quantity * l_acq_cost_ent;

             IF (l_acq_cost_ent = 0) THEN
               l_curr_rec.currency_conv_rate := 1;
             ELSE
               l_curr_rec.currency_conv_rate := l_acq_cost/l_acq_cost_ent;
             END IF;

             l_curr_rec.currency_conv_date := null;
             l_curr_rec.currency_conv_type := null;
                        --acq cost is a combination of po and invoice rate and is in functional currency

             IF l_debug_flag = 'Y' THEN
               IF (l_dr_flag) THEN
                 fnd_file.put_line(fnd_file.log,'DR RI: '||to_char( l_ae_line_rec.transaction_value *  l_curr_rec.currency_conv_rate ));
               ELSE
                 fnd_file.put_line(fnd_file.log,'CR RI: '||to_char( l_ae_line_rec.transaction_value *  l_curr_rec.currency_conv_rate ));
               END IF;
             END IF;

             /* Bug 2686598. Use the quantity in the po_distribution to calcualte rate_or_amount
                not the primary quantity on the transaction */
             IF ( c_receipts_rec.dist_quantity = 0 ) THEN
               l_ae_line_rec.rate_or_amount := 0;
             ELSE
               l_ae_line_rec.rate_or_amount := l_ae_line_rec.transaction_value * l_curr_rec.currency_conv_rate / c_receipts_rec.dist_quantity ;
             END IF;

             CSTPAPPR.insert_account (i_ae_txn_rec,
                                      l_curr_rec,
                                      l_dr_flag,
                                      l_ae_line_rec,
                                      l_ae_line_tbl,
                                      l_err_rec);
             if (l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null) then
                raise process_error;
             end if;

             -------------------------------------------
             -- Toggle the debit flag
             -------------------------------------------

             l_dr_flag := not l_dr_flag;

             l_stmt_num := 70;

             /* Bug 3421141: Drop Shipment and Global Procureemnt Changes */

            /* For Global Procurement receipts a credit needs to be made to the
               I/C Accrual account, rather than the supplier accrual account.

               Instead of determining if the current transaction is in the
               context of global procureemnt by figuring out the PO OU and the
               receiving OU, I'm getting the account information from RAE, which
               will always store the correct account */

             begin
                   select credit_account_id, debit_account_id
                   into l_credit_Account, l_debit_account
                   from rcv_accounting_events
                   where rcv_transaction_id = i_ae_txn_rec.transaction_id
                   and organization_id = i_ae_txn_rec.organization_id
                   and rownum = 1;

                   if(l_dr_flag) then
                        l_ae_line_rec.account := l_debit_account;
                   else
                        l_ae_line_rec.account := l_credit_account;
                   end if;

             exception
                   when others then
                   l_ae_line_rec.account := c_receipts_rec.accrual_account_id;
             end;

             l_stmt_num := 750;


             /* Bug 5555888 : For Global Procurement scenario (PO OU is diff from Rcv OU), the Accrual
                should also be hit at the acq cost (PO price or Transfer price as per setup). Also,
                in this case the tax/Invoice/IPV etc is also not there as acq price is binding price.
                For Normal receits do it at the PO price as before. */

             select org_id
             into l_po_ou_id /* Get the OU where PO is created */
             from po_headers_all
             where po_header_id = (select po_header_id
                                   from   rcv_transactions
                                   where transaction_id = i_ae_txn_rec.transaction_id);

             l_stmt_num := 751;

             select to_number(org_information3)
             into   l_rcv_ou_id /* Get OU where Receiving is done */
             from   hr_organization_information
             where  org_information_context = 'Accounting Information'
             and    organization_id = i_ae_txn_rec.organization_id;

             l_stmt_num := 752;

             IF l_debug_flag = 'Y' THEN
                  fnd_file.put_line(fnd_file.log,'PO OU / Rcv OU '|| l_po_ou_id ||' / '|| l_rcv_ou_id);
             END IF;

             l_stmt_num := 753;

             l_ae_line_rec.ae_line_type := 16;

             IF (l_po_ou_id <> l_rcv_ou_id) THEN /* Global Procurement Scenario */

                 l_stmt_num := 754;

                 IF l_debug_flag = 'Y' THEN
                     fnd_file.put_line(fnd_file.log,'GP scenario. Trxn val: '||to_char(c_receipts_rec.dist_quantity * l_acq_cost_ent));
                 END IF;

                 l_ae_line_rec.transaction_value := c_receipts_rec.dist_quantity * l_acq_cost_ent;

                 IF (l_acq_cost_ent = 0) THEN
                   l_curr_rec.currency_conv_rate := 1;
                 ELSE
                   l_curr_rec.currency_conv_rate := l_acq_cost/l_acq_cost_ent;
                 END IF;

                 l_curr_rec.currency_conv_date := null;
                 l_curr_rec.currency_conv_type := null;
                 --acq cost is a combination of po and invoice rate and is in functional currency

             ELSE

                 l_stmt_num := 755;

                 IF l_debug_flag = 'Y' THEN
                     fnd_file.put_line(fnd_file.log,'Normal Receipt. Trxn val: '||to_char(c_receipts_rec.dist_quantity * (l_po_price + c_receipts_rec.tax)));
                 END IF;

                 l_ae_line_rec.transaction_value := c_receipts_rec.dist_quantity * (l_po_price + c_receipts_rec.tax);

                 l_curr_rec.currency_conv_rate := c_receipts_rec.exchg_rate;
                 l_curr_rec.currency_conv_date := c_receipts_rec.exchg_date;
                 l_curr_rec.currency_conv_type := i_ae_txn_rec.currency_conv_type;

             END IF; /* (l_po_ou_id <> l_rcv_ou_id) */

             l_stmt_num := 756;

             IF l_debug_flag = 'Y' THEN
               IF (l_dr_flag) THEN
                 fnd_file.put_line(fnd_file.log,'DR Accrual: '||to_char( l_ae_line_rec.transaction_value *  l_curr_rec.currency_conv_rate ));
               ELSE
                 fnd_file.put_line(fnd_file.log,'CR Accrual: '||to_char( l_ae_line_rec.transaction_value *  l_curr_rec.currency_conv_rate ));
               END IF;
             END IF;

             /* Bug 2686598. Use the quantity in the po_distribution to calcualte rate_or_amount
                not the primary quantity on the transaction */
             IF ( c_receipts_rec.dist_quantity = 0 ) THEN
               l_ae_line_rec.rate_or_amount := 0;
             ELSE
               l_ae_line_rec.rate_or_amount := l_ae_line_rec.transaction_value * l_curr_rec.currency_conv_rate / c_receipts_rec.dist_quantity ;
             END IF;

             l_stmt_num := 757;

             CSTPAPPR.insert_account (i_ae_txn_rec,
                                      l_curr_rec,
                                      l_dr_flag,
                                      l_ae_line_rec,
                                      l_ae_line_tbl,
                                      l_err_rec);
             IF (l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null) then
                raise process_error;
             END IF;

             l_stmt_num := 758;

             ------------------------------------------------------
             -- All the invoice distribution lines of type TAX/FREIGHT/MISCELLANEOUS
             -- that do not have IPV should be charged to the Special charge account
             -- that is specified at the time of invoice creation
             ---------------------------------------------------------------

             -------------------------------------------------
             -- Joining with ap_invoices_all in order to get the
             -- exchange rate.  Also, the code needs to check for
             -- more than just ITEM when looking at the lookup code
             -- This is a result of AP's Invoice Lines Project
             -------------------------------------------------



	    /*-----------------------------------------------------------------+
            | BUG 9113487                                                |
	    | In R12,final account used for Exchange Rate Variance,            |
	    | Invoice Price Variance  and other charges is derived using       |
	    | Account derivation Rule defined in SLA.Hence if SLA data exists  |
	    | for invoice accounting derive account from SLA Accounting tables |
	    | else derive it from AP tables.                                   |
             +-----------------------------------------------------------------*/

             DECLARE


               CURSOR xla_charges is
               SELECT
               cracd.amount/nvl(aia.exchange_rate,1) "AMOUNT",
               nvl(aia.exchange_rate,1) "EXCHANGE_RATE",
               aia.exchange_date "EXCHANGE_DATE",
               aia.exchange_rate_type "EXCHANGE_RATE_TYPE",
               xal.code_combination_id "CODE_COMBINATION_ID"
               FROM
               cst_rcv_acq_cost_details cracd,
               cst_rcv_acq_costs crac,
	       xla_distribution_links xdl,
               xla_ae_lines xal,
               xla_ae_headers xae,
	       ap_invoice_distributions_all aida ,
               ap_invoices_all aia
               WHERE
               cracd.line_type NOT IN ('ITEM','ACCRUAL','IPV','ERV','NONREC_TAX') AND
               crac.rcv_transaction_id = l_par_rcv_txn AND
               crac.cost_type_id = i_ae_txn_rec.cost_type_id AND
               crac.cost_group_id = i_ae_txn_rec.cost_group_id AND
               cracd.header_id = crac.header_id AND
               cracd.source_type = 'INVOICE' AND
               cracd.invoice_distribution_id = aida.invoice_distribution_id
	       AND xae.event_id=aida.accounting_event_id
               AND xae.ae_header_id=xdl.ae_header_id
               AND xae.ae_header_id=xal.ae_header_id
	       AND xae.accounting_entry_status_code='F'
               AND xae.application_id=200
               AND xae.ledger_id=l_ledger_id
               AND xal.ae_header_id=xdl.ae_header_id
               AND xal.application_id=200
               AND xal.ledger_id=l_ledger_id
               AND xdl.application_id=200
	       AND xdl.SOURCE_DISTRIBUTION_TYPE='AP_INV_DIST'
               AND xdl.ae_line_num=xal.ae_line_num
	       AND xdl.source_distribution_id_num_1=aida.invoice_distribution_id
	       AND  xal.accounting_class_code not in ('LIABILITY','ITEM','ACCRUAL',
                                              'IPV','EXCHANGE_RATE_VARIANCE' ,'NONRECOVERABLE TAX')
	       AND aia.invoice_id = aida.invoice_id
	       AND aia.org_id = aida.org_id
	       AND NOT EXISTS (
                SELECT '1' FROM ap_invoice_distributions_all aida2
                WHERE aida2.related_id = aida.invoice_distribution_id
                AND aida2.line_type_lookup_code = 'IPV');


               CURSOR c_charges IS
               SELECT
               cracd.amount/nvl(aia.exchange_rate,1) "AMOUNT",
               nvl(aia.exchange_rate,1) "EXCHANGE_RATE",
               aia.exchange_date "EXCHANGE_DATE",
               aia.exchange_rate_type "EXCHANGE_RATE_TYPE",
               aida.dist_code_combination_id "CODE_COMBINATION_ID"
               FROM
               cst_rcv_acq_cost_details cracd,
               cst_rcv_acq_costs crac,
               ap_invoice_distributions_all aida,
               ap_invoices_all aia
               WHERE
               cracd.line_type NOT IN ('ITEM','ACCRUAL','IPV','ERV','NONREC_TAX') AND
               crac.rcv_transaction_id = l_par_rcv_txn AND
               crac.cost_type_id = i_ae_txn_rec.cost_type_id AND
               crac.cost_group_id = i_ae_txn_rec.cost_group_id AND
               cracd.header_id = crac.header_id AND
               cracd.source_type = 'INVOICE' AND
               cracd.invoice_distribution_id = aida.invoice_distribution_id AND
               aia.invoice_id = aida.invoice_id AND
               aia.org_id = aida.org_id AND
               NOT EXISTS (
                SELECT '1' FROM ap_invoice_distributions_all aida2
                WHERE aida2.related_id = aida.invoice_distribution_id
                AND aida2.line_type_lookup_code = 'IPV'
               );



               xla_count NUMBER:=0;
               c_chg_rec c_charges%ROWTYPE;


           BEGIN

               OPEN xla_charges;
               FETCH xla_charges INTO c_chg_rec;

                  IF(xla_charges%FOUND) THEN
                     xla_count:=1;
                  ELSE
                     xla_count:=0;
                  END IF;

               CLOSE xla_charges;

               IF(xla_count=1) THEN
                 OPEN xla_charges;
                ELSE
                 OPEN c_charges;
               END IF ;

            LOOP

                 IF  (xla_count=1) THEN
                   FETCH xla_charges  INTO c_chg_rec;
                   EXIT WHEN  xla_charges%notfound;
                 ELSE
                   FETCH c_charges INTO c_chg_rec;
                   EXIT WHEN  c_charges%notfound;
                 END IF;

                 IF (l_net_receipt = 1 and c_chg_rec.amount > 0) OR (l_net_receipt = -1 and c_chg_rec.amount < 0) THEN
                    l_dr_flag := FALSE;
                 ELSE
                    l_dr_flag := TRUE;
                 END IF;

                 l_ae_line_rec.account := c_chg_rec.code_combination_id;
                 l_ae_line_rec.ae_line_type := 19;
                 --l_ae_line_rec.transaction_value := c_chg_rec.amount * (c_receipts_rec.dist_quantity / l_costed_quantity);
                 l_ae_line_rec.transaction_value := c_chg_rec.amount * (i_ae_txn_rec.primary_quantity / l_costed_quantity);

                 -- also populate type date etc
                 l_curr_rec.currency_conv_rate := c_chg_rec.exchange_rate;
                 l_curr_rec.currency_conv_date := c_chg_rec.exchange_date;
                 l_curr_rec.currency_conv_type := c_chg_rec.exchange_rate_type;

                 IF l_debug_flag = 'Y' THEN
                   IF (l_dr_flag) THEN
                     fnd_file.put_line(fnd_file.log,'DR Special Charges: '||to_char( l_ae_line_rec.transaction_value *  l_curr_rec.currency_conv_rate ));
                   ELSE
                     fnd_file.put_line(fnd_file.log,'CR Special Charges: '||to_char( l_ae_line_rec.transaction_value *  l_curr_rec.currency_conv_rate ));
                   END IF;
                 END IF;

                /* Bug 2686598. Use the quantity in the po_distribution to calcualte rate_or_amount
                   not the primary quantity on the transaction */
                 IF (i_ae_txn_rec.primary_quantity = 0) THEN
                   l_ae_line_rec.rate_or_amount := 0;
                 ELSE
                   l_ae_line_rec.rate_or_amount := l_ae_line_rec.transaction_value * l_curr_rec.currency_conv_rate / i_ae_txn_rec.primary_quantity;
                 END IF;

                 CSTPAPPR.insert_account (i_ae_txn_rec,
                                          l_curr_rec,
                                          l_dr_flag,
                                          l_ae_line_rec,
                                          l_ae_line_tbl,
                                          l_err_rec);
                 IF (l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null)                 THEN
                   raise process_error;
                 END IF;

               END LOOP; /* c_charges loop */
             EXCEPTION
               when process_error then
               o_ae_err_rec.l_err_num := l_err_rec.l_err_num;
               o_ae_err_rec.l_err_code := l_err_rec.l_err_code;
               o_ae_err_rec.l_err_msg := l_err_rec.l_err_msg;

	        IF(xla_count=1) THEN
                CLOSE xla_charges;
               ELSE
                CLOSE  c_charges;
               END IF ;


             END;

             ---------------------------------------------------------------
             -- The invoice distribution lines that have IPV
             ---------------------------------------------------------------

             ---------------------------------------------------------------
             -- Invoice Lines Project
             -- {base_}invoice_price_variance will be obsolete in 11.5.11
             -- also.  Instead a separate distribution will be created for IPV
             -- Consult Invoice lines documentation (AP and/or Costing) for
             -- more information.  In addition  exchange rate needs to
             -- come from ap_invoice_all
             ---------------------------------------------------------------

             DECLARE

	       CURSOR xla_ipv is
	       SELECT aida.base_amount/nvl(aia.exchange_rate,1) "INVOICE_PRICE_VARIANCE",
	       nvl(aia.exchange_rate,1) "EXCHANGE_RATE",
	       aia.exchange_date "EXCHANGE_DATE",
	       aia.exchange_rate_type "EXCHANGE_RATE_TYPE",
	       xal.code_combination_id "CODE_COMBINATION_ID",
	       aida.related_id  "INVOICE_DISTRIBUTION_ID"
	       FROM
	       cst_rcv_acq_cost_details cracd,
	       cst_rcv_acq_costs crac,
	       xla_distribution_links xdl,
	       xla_ae_lines xal,
	       xla_ae_headers xae,
	       ap_invoice_distributions_all aida,
	       ap_invoices_all aia
	       WHERE
	       crac.rcv_transaction_id = l_par_rcv_txn  AND
	       crac.cost_type_id =i_ae_txn_rec.cost_type_id AND
	       crac.cost_group_id = i_ae_txn_rec.cost_group_id AND
	       cracd.header_id = crac.header_id AND
	       cracd.source_type = 'INVOICE' AND
	       cracd.invoice_distribution_id =aida.related_id
	       AND xae.event_id=aida.accounting_event_id
	       AND xae.ae_header_id=xdl.ae_header_id
	       AND xae.ae_header_id=xal.ae_header_id
	       AND xae.accounting_entry_status_code='F'
	       AND xae.application_id=200
	       AND xae.ledger_id=l_ledger_id
	       AND xal.ae_header_id=xdl.ae_header_id
	       AND xal.application_id=200
	       AND xal.ledger_id=l_ledger_id
	       AND xal.accounting_class_code ='IPV'
	       AND xdl.application_id=200
	       AND xdl.SOURCE_DISTRIBUTION_TYPE='AP_INV_DIST'
	       AND xdl.source_distribution_id_num_1=aida.invoice_distribution_id
	       AND xdl.ae_line_num=xal.ae_line_num
	       AND aia.invoice_id = aida.invoice_id
	       AND aia.org_id = aida.org_id
	       AND aida.line_type_lookup_code = 'IPV'
	       AND aida.amount <> 0
	       AND aida.posted_flag = 'Y';

               CURSOR c_ipv IS
               SELECT
               aida.base_amount/nvl(aia.exchange_rate,1) "INVOICE_PRICE_VARIANCE",
               nvl(aia.exchange_rate,1) "EXCHANGE_RATE",
               aia.exchange_date "EXCHANGE_DATE",
               aia.exchange_rate_type "EXCHANGE_RATE_TYPE",
               aida.dist_code_combination_id "CODE_COMBINATION_ID",
               -- Retroactive Pricing Enhancements
               -- Need Invoice Distribution to find correction invoices
               aida.related_id "INVOICE_DISTRIBUTION_ID"
               FROM
               cst_rcv_acq_cost_details cracd,
               cst_rcv_acq_costs crac,
               ap_invoice_distributions_all aida,
               ap_invoices_all aia
               WHERE
               crac.rcv_transaction_id = l_par_rcv_txn AND
               crac.cost_type_id = i_ae_txn_rec.cost_type_id AND
               crac.cost_group_id = i_ae_txn_rec.cost_group_id AND
               cracd.header_id = crac.header_id AND
               cracd.source_type = 'INVOICE' AND
               cracd.invoice_distribution_id = aida.related_id AND
               aia.invoice_id = aida.invoice_id AND
               aia.org_id = aida.org_id AND
               aida.line_type_lookup_code = 'IPV' AND
               aida.amount <> 0 AND
               aida.posted_flag = 'Y'; --Added for bug 4773085


             xla_count NUMBER:=0;
               c_ipv_rec c_ipv%ROWTYPE;


             BEGIN

		OPEN xla_ipv;
		FETCH xla_ipv INTO c_ipv_rec;

		     IF(xla_ipv%FOUND) THEN
			xla_count:=1;
		     ELSE
			xla_count:=0;
		     END IF;

	        CLOSE xla_ipv;

		IF(xla_count=1) THEN
		    OPEN xla_ipv;
		ELSE
		    OPEN c_ipv;
		END IF ;

	     LOOP

		 IF  (xla_count=1) THEN
		   FETCH xla_ipv  INTO c_ipv_rec;
		   EXIT WHEN  xla_ipv%notfound;
		 ELSE
		   FETCH c_ipv INTO c_ipv_rec;
		    EXIT WHEN  c_ipv%notfound;
		 END IF;


                 IF (l_net_receipt = 1 and c_ipv_rec.invoice_price_variance > 0) OR (l_net_receipt = -1 and c_ipv_rec.invoice_price_variance < 0) THEN
                   l_dr_flag := FALSE;
                 ELSE
                   l_dr_flag := TRUE;
                 END IF;

             -- IPV account stamped on the Price correction Invoices is the same as the
             -- one on the original Invoice
             -- Get the sum of IPV amounts on the price correction invoices and add them to
             -- the IPV on the original invoice
             -- If there is a Price Correction Invoice, the IPV reverses and the net
             -- IPV SHOULD be 0.

             -- As a result of Invoice Lines Project, IPV is a separate distribution
             -- and retropricing is handled through corrected_invoice_dist_id column
                 l_stmt_num := 71;
                 BEGIN
                   SELECT
                     NVL(AIDA.BASE_AMOUNT/NVL(AP_INV.EXCHANGE_RATE,1), 0)
                   INTO
                     l_correct_ipv_amount
                   FROM
                     AP_INVOICE_DISTRIBUTIONS_ALL AIDA,
                     AP_INVOICES_ALL AP_INV
                   WHERE
                          AIDA.CORRECTED_INVOICE_DIST_ID = c_ipv_rec.INVOICE_DISTRIBUTION_ID
                   AND    AIDA.LINE_TYPE_LOOKUP_CODE = 'IPV'
                   AND    AIDA.INVOICE_ID                 = AP_INV.INVOICE_ID
                   AND    AP_INV.INVOICE_TYPE_LOOKUP_CODE = 'PO PRICE ADJUST';
                 EXCEPTION
                   WHEN OTHERS THEN
                     l_correct_ipv_amount := 0;
                 END;

                 IF l_debug_flag = 'Y' THEN
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Original IPV: '||to_char(c_ipv_rec.invoice_price_variance));
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'IPV - Price Correction Invoice: '||to_char(l_correct_ipv_amount));
                 END IF;

                 l_total_ipv := c_ipv_rec.invoice_price_variance + l_correct_ipv_amount;

                 -- Create IPV line only if there is a net IPV

                 IF l_total_ipv <> 0 THEN

                   l_ae_line_rec.account := c_ipv_rec.code_combination_id;
                   l_ae_line_rec.ae_line_type := 17;
                   l_ae_line_rec.transaction_value := c_ipv_rec.invoice_price_variance * (i_ae_txn_rec.primary_quantity / l_costed_quantity);

                   l_curr_rec.currency_conv_rate := c_ipv_rec.exchange_rate;
                   l_curr_rec.currency_conv_date := c_ipv_rec.exchange_date;
                   l_curr_rec.currency_conv_type := c_ipv_rec.exchange_rate_type;

                   IF l_debug_flag = 'Y' THEN
                     IF (l_dr_flag) THEN
                       fnd_file.put_line(fnd_file.log,'DR IPV: '||to_char( l_ae_line_rec.transaction_value *  l_curr_rec.currency_conv_rate ));
                     ELSE
                       fnd_file.put_line(fnd_file.log,'CR IPV: '||to_char( l_ae_line_rec.transaction_value *  l_curr_rec.currency_conv_rate ));
                     END IF;
                   END IF;

                   /* Bug 2686598. Use the quantity in the po_distribution to calcualte rate_or_amount
                      not the primary quantity on the transaction */
                   IF (i_ae_txn_rec.primary_quantity = 0) THEN
                     l_ae_line_rec.rate_or_amount := 0;
                   ELSE
                     l_ae_line_rec.rate_or_amount := l_ae_line_rec.transaction_value * l_curr_rec.currency_conv_rate / i_ae_txn_rec.primary_quantity;
                   END IF;

                   CSTPAPPR.insert_account (i_ae_txn_rec,
                                            l_curr_rec,
                                            l_dr_flag,
                                            l_ae_line_rec,
                                            l_ae_line_tbl,
                                            l_err_rec);
                   IF (l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null) THEN
                     raise process_error;
                   END IF;

                 END IF; -- l_total_ipv <> 0

               END LOOP;
             EXCEPTION
               when process_error then
               o_ae_err_rec.l_err_num := l_err_rec.l_err_num;
               o_ae_err_rec.l_err_code := l_err_rec.l_err_code;
               o_ae_err_rec.l_err_msg := l_err_rec.l_err_msg;

	        IF(xla_count=1) THEN
                 CLOSE xla_ipv;
               ELSE
                 CLOSE  c_ipv;
               END IF ;


             END;


             ----------------------------------------------------------------
             -- The invoice distribution lines that have ERV
             -- For the invoice lines project, ERV columns are obsolete and
             -- are separte distributions. This is previously described in a
             -- similar situation involving IPV as well as AP's documentation
             ----------------------------------------------------------------

             DECLARE

	       CURSOR xla_erv is
               select
	       aida.base_amount "EXCHANGE_RATE_VARIANCE",
               xal.code_combination_id "CODE_COMBINATION_ID"
               from
               xla_distribution_links xdl,
               xla_ae_lines xal,
               xla_ae_headers xae,
               cst_rcv_acq_cost_details cracd,
               cst_rcv_acq_costs  crac,
	       ap_invoice_distributions_all aida
	       where  crac.rcv_transaction_id =l_par_rcv_txn
               AND crac.cost_type_id=i_ae_txn_rec.cost_type_id
               AND crac.cost_group_id=i_ae_txn_rec.cost_group_id
               AND cracd.header_id = crac.header_id
               AND cracd.source_type = 'INVOICE'
               AND cracd.invoice_distribution_id =aida.related_id
               AND xae.event_id=aida.accounting_event_id
               AND xae.ae_header_id=xdl.ae_header_id
               AND xae.ae_header_id=xal.ae_header_id
	       AND xae.accounting_entry_status_code='F'
               AND xae.application_id=200
               AND xae.ledger_id=l_ledger_id
               AND xal.ae_header_id=xdl.ae_header_id
               AND xal.application_id=200
               AND xal.ledger_id=l_ledger_id
               AND xal.accounting_class_code ='EXCHANGE_RATE_VARIANCE'
	       AND xdl.application_id=200
	       AND xdl.SOURCE_DISTRIBUTION_TYPE='AP_INV_DIST'
               AND xdl.ae_line_num=xal.ae_line_num
	       AND xdl.source_distribution_id_num_1=aida.invoice_distribution_id
               AND aida.line_type_lookup_code = 'ERV'
               AND aida.posted_flag = 'Y'
               AND aida.base_amount<>0 ;

               CURSOR c_erv IS
               SELECT
               aida.base_amount "EXCHANGE_RATE_VARIANCE",
               aida.dist_code_combination_id "CODE_COMBINATION_ID"
               FROM
               cst_rcv_acq_cost_details cracd,
               cst_rcv_acq_costs crac,
               ap_invoice_distributions_all aida
               WHERE
               crac.rcv_transaction_id = l_par_rcv_txn AND
               crac.cost_type_id = i_ae_txn_rec.cost_type_id AND
               crac.cost_group_id = i_ae_txn_rec.cost_group_id AND
               cracd.header_id = crac.header_id AND
               cracd.source_type = 'INVOICE' AND
               cracd.invoice_distribution_id = aida.related_id AND
               aida.line_type_lookup_code = 'ERV' AND
               aida.base_amount <> 0 AND
               aida.posted_flag = 'Y';-- Added for bug 4773085

              xla_count NUMBER:=0;
               c_erv_rec c_erv%ROWTYPE;


            BEGIN

	       OPEN xla_erv;
	       FETCH xla_erv INTO c_erv_rec;

	          IF(xla_erv%FOUND) THEN
                    xla_count:=1;
	          ELSE
	           xla_count:=0;
	          END IF;

	       CLOSE xla_erv;

	       IF(xla_count=1) THEN
	          OPEN xla_erv;
	       ELSE
	          OPEN c_erv;
	       END IF ;

	    LOOP

		 IF  (xla_count=1) THEN
		    FETCH xla_erv  INTO c_erv_rec;
		    EXIT WHEN  xla_erv%notfound;
		 ELSE
		   FETCH c_erv INTO c_erv_rec;
		   EXIT WHEN  c_erv%notfound;
		 END IF;

                 IF (l_net_receipt = 1 and c_erv_rec.exchange_rate_variance > 0) OR (l_net_receipt = -1 and c_erv_rec.exchange_rate_variance < 0) THEN
                   l_dr_flag := FALSE;
                 ELSE
                   l_dr_flag := TRUE;
                 END IF;

                 l_ae_line_rec.account := c_erv_rec.code_combination_id;
                 l_ae_line_rec.ae_line_type := 18;
                 --l_ae_line_rec.transaction_value := c_erv_rec.exchange_rate_variance * (c_receipts_rec.dist_quantity / l_costed_quantity);
                 l_ae_line_rec.transaction_value := c_erv_rec.exchange_rate_variance * (i_ae_txn_rec.primary_quantity / l_costed_quantity);

                 -- also populate type date etc
                 l_curr_rec.currency_conv_rate := 1;
                 l_curr_rec.currency_conv_date := null;
                 l_curr_rec.currency_conv_type := null;

                 IF l_debug_flag = 'Y' THEN
                   IF (l_dr_flag) THEN
                     fnd_file.put_line(fnd_file.log,'DR ERV: '||to_char( l_ae_line_rec.transaction_value *  l_curr_rec.currency_conv_rate ));
                   ELSE
                     fnd_file.put_line(fnd_file.log,'CR ERV: '||to_char( l_ae_line_rec.transaction_value *  l_curr_rec.currency_conv_rate ));
                   END IF;
                 END IF;

                /* Bug 2686598. Use the quantity in the po_distribution to calcualte rate_or_amount
                   not the primary quantity on the transaction */
                 IF (i_ae_txn_rec.primary_quantity = 0) THEN
                   l_ae_line_rec.rate_or_amount := 0;
                 ELSE
                   l_ae_line_rec.rate_or_amount := l_ae_line_rec.transaction_value * l_curr_rec.currency_conv_rate / i_ae_txn_rec.primary_quantity;
                 END IF;

                 CSTPAPPR.insert_account (i_ae_txn_rec,
                                          l_curr_rec,
                                          l_dr_flag,
                                          l_ae_line_rec,
                                          l_ae_line_tbl,
                                          l_err_rec);
                 IF (l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null)                 THEN
                   raise process_error;
                 END IF;

               END LOOP;
             EXCEPTION
               when process_error then
               o_ae_err_rec.l_err_num := l_err_rec.l_err_num;
               o_ae_err_rec.l_err_code := l_err_rec.l_err_code;
               o_ae_err_rec.l_err_msg := l_err_rec.l_err_msg;

	       IF(xla_count=1) THEN
                 CLOSE xla_erv;
               ELSE
                 CLOSE  c_erv;
               END IF ;

             END;
             END IF;
            END IF;
    END LOOP;  /*not expense*/
    EXCEPTION
     when process_error then
      o_ae_err_rec.l_err_num := l_err_rec.l_err_num;
      o_ae_err_rec.l_err_code := l_err_rec.l_err_code;
      o_ae_err_rec.l_err_msg := l_err_rec.l_err_msg;

    END;

-- Take care of rounding errors.
-- -----------------------------
    l_stmt_num := 80;
    balance_account (l_ae_line_tbl,
                     l_err_rec);

    -- check error
    if (l_err_rec.l_err_num <> 0) then
        raise process_error;
    end if;


    DECLARE
      CURSOR c_receive_dists IS
        SELECT
        decode (poll.match_option,'R',i_ae_txn_rec.currency_conv_rate,nvl(pod.rate,1)) "EXCHG_RATE",
        decode (poll.match_option,'R',i_ae_txn_rec.currency_conv_date,pod.rate_date) "EXCHG_DATE",
-- J Changes --------------------------------------------------------------------------------------
        DECODE (POLL.MATCHING_BASIS, 'AMOUNT', 1,  -- Changed for Complex work procurement
                                     'QUANTITY', 0)"SERVICE_FLAG",
---------------------------------------------------------------------------------------------------
        POD.po_distribution_id "PO_DISTRIBUTION_ID",
        POLL.line_location_id "PO_LINE_LOCATION_ID",
        POD.code_combination_id "EXPENSE_ACCOUNT_ID",
        POD.destination_type_code "DESTINATION_TYPE_CODE",
        RP.receiving_account_id "RECEIVING_ACCOUNT_ID",
        POD.accrual_account_id "ACCRUAL_ACCOUNT_ID",
        nvl(POD.budget_account_id,-1) "ENCUMBRANCE_ACCOUNT_ID",
-- J Changes --------------------------------------------------------------------------------------
        decode(l_doc_level,'D', 1, DECODE(POLL.MATCHING_BASIS,  -- Changed for Complex work procurement
                                           'AMOUNT', POD.AMOUNT_ORDERED/POLL.AMOUNT,
                                            'QUANTITY',pod.quantity_ordered/poll.quantity))
        * i_ae_txn_rec.primary_quantity "DIST_QUANTITY",
        po_tax_sv.get_tax('PO',pod.po_distribution_id) /
                          DECODE(POLL.MATCHING_BASIS,  -- Changed for Complex work procurement
                                     'AMOUNT', POD.AMOUNT_ORDERED,
                                     'QUANTITY',POD.QUANTITY_ORDERED) "TAX"
---------------------------------------------------------------------------------------------------
        FROM
        po_distributions_all pod,
        po_line_locations_all poll,
-- J Changes --------------------------------------------------------------------------------------
        PO_LINES_ALL POL,
---------------------------------------------------------------------------------------------------
        rcv_parameters rp
        WHERE
-- begin fix for perf bug 2581067
        (
          (l_doc_level = 'D' AND pod.po_distribution_id = l_doc_id)
          OR (l_doc_level = 'S' AND poll.line_location_id = l_doc_id)
        )
-- end fix for perf bug 2581067.
        and pod.line_location_id                 = poll.line_location_id
-- J Changes --------------------------------------------------------------------------------------
        AND POLL.PO_LINE_ID                      = POL.PO_LINE_ID
---------------------------------------------------------------------------------------------------
        and rp.organization_id                   = pod.destination_organization_id
        and pod.destination_type_code            in ('EXPENSE')
        and nvl(POLL.accrue_on_receipt_flag,'N') = 'Y'
/*      and nvl(POD.accrue_on_receipt_flag,'N')  = 'Y' */;
    BEGIN
        FOR c_receipts_rec IN c_receive_dists LOOP
    l_stmt_num := 62;
          l_ae_line_rec.actual_flag := NULL;
          l_ae_line_rec.po_distribution_id := c_receipts_rec.po_distribution_id;

          ---------------------------------------------------------
          -- The PO Price is in terms of the PO UOM
          -- Convert it in terms of the primary UOM for the item
          ---------------------------------------------------------

          SELECT
          DECODE(C_RECEIPTS_REC.SERVICE_FLAG, 1, 1,
                 poll.price_override * rt.source_doc_quantity / rt.primary_quantity)
          INTO
          l_po_price
          FROM
          rcv_transactions rt,
          po_line_locations_all poll
          WHERE
          rt.transaction_id = i_ae_txn_rec.transaction_id
          AND rt.po_line_location_id = poll.line_location_id;



              l_ae_line_rec.transaction_value := c_receipts_rec.dist_quantity * (l_po_price + c_receipts_rec.tax);
              l_curr_rec.currency_conv_rate := c_receipts_rec.exchg_rate;
              l_curr_rec.currency_conv_date := c_receipts_rec.exchg_date;
              l_curr_rec.currency_conv_type := i_ae_txn_rec.currency_conv_type;

              IF (l_stage = 1) THEN

                ---------------------------------------------------------
                -- For expense destinations, stage 1 accounting is as follows:
                -- Dr. Receiving Inspection qty@po
                --   Cr. Accrual  qty@po
                ---------------------------------------------------------

                IF (l_net_receipt = 1) THEN
                  l_dr_flag := TRUE;
                ELSE
                  l_dr_flag := FALSE;
                END IF;

                l_ae_line_rec.account := c_receipts_rec.receiving_account_id;
                l_ae_line_rec.ae_line_type := 5;

                IF l_debug_flag = 'Y' THEN
                  IF (l_dr_flag) THEN
                    fnd_file.put_line(fnd_file.log,'DR RI: '||to_char( l_ae_line_rec.transaction_value *  l_curr_rec.currency_conv_rate ));
                  ELSE
                    fnd_file.put_line(fnd_file.log,'CR RI: '||to_char( l_ae_line_rec.transaction_value *  l_curr_rec.currency_conv_rate ));
                  END IF;
                END IF;

                /* Bug 2686598. Use the quantity in the po_distribution to calcualte rate_or_amount
                   not the primary quantity on the transaction */
                 IF (c_receipts_rec.dist_quantity = 0) THEN
                   l_ae_line_rec.rate_or_amount := 0;
                 ELSE
                   l_ae_line_rec.rate_or_amount := l_ae_line_rec.transaction_value * l_curr_rec.currency_conv_rate / c_receipts_rec.dist_quantity;
                 END IF;

                CSTPAPPR.insert_account (i_ae_txn_rec,
                                         l_curr_rec,
                                         l_dr_flag,
                                         l_ae_line_rec,
                                         l_ae_line_tbl,
                                         l_err_rec);
                 IF (l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null)
                 THEN
                   raise process_error;
                 END IF;


                l_dr_flag := not l_dr_flag;
                l_ae_line_rec.account := c_receipts_rec.accrual_account_id;
                l_ae_line_rec.ae_line_type := 16;

                IF l_debug_flag = 'Y' THEN
                  IF (l_dr_flag) THEN
                    fnd_file.put_line(fnd_file.log,'DR Accrual: '||to_char( l_ae_line_rec.transaction_value * l_curr_rec.currency_conv_rate ));
                  ELSE
                    fnd_file.put_line(fnd_file.log,'CR Accrual: '||to_char( l_ae_line_rec.transaction_value *  l_curr_rec.currency_conv_rate ));
                  END IF;
                END IF;

                /* Bug 2686598. Use the quantity in the po_distribution to calcualte rate_or_amount
                   not the primary quantity on the transaction */
                 IF (c_receipts_rec.dist_quantity = 0) THEN
                   l_ae_line_rec.rate_or_amount := 0;
                 ELSE
                   l_ae_line_rec.rate_or_amount := l_ae_line_rec.transaction_value * l_curr_rec.currency_conv_rate / c_receipts_rec.dist_quantity;
                 END IF;



                CSTPAPPR.insert_account (i_ae_txn_rec,
                                         l_curr_rec,
                                         l_dr_flag,
                                         l_ae_line_rec,
                                         l_ae_line_tbl,
                                         l_err_rec);

               -- Take care of rounding errors.
               -- -----------------------------
                   l_stmt_num := 80;
                   balance_account (l_ae_line_tbl,
                                    l_err_rec);

                   -- check error
                   if (l_err_rec.l_err_num <> 0) then
                       raise process_error;
                   end if;


              ELSE  /*if stage <> 1*/

                ------------------------------------------------------------
                -- For Expense destinations, stage 2 accounting is as follows :
                -- Dr. Expense qty@po
                --   Cr. Receiving Inspection qty@po
                ------------------------------------------------------------

                IF (l_net_receipt = 1) THEN
                  l_dr_flag := TRUE;
                ELSE
                  l_dr_flag := FALSE;
                END IF;

                l_ae_line_rec.account := c_receipts_rec.expense_account_id;
                l_ae_line_rec.ae_line_type := 20;

                IF (c_receipts_rec.dist_quantity = 0) THEN
                  l_ae_line_rec.rate_or_amount := 0;
                ELSE
                  l_ae_line_rec.rate_or_amount := l_ae_line_rec.transaction_value * l_curr_rec.currency_conv_rate / c_receipts_rec.dist_quantity;
                END IF;

                IF l_debug_flag = 'Y' THEN
                  IF (l_dr_flag) THEN
                    fnd_file.put_line(fnd_file.log,'DR Expense: '||to_char( l_ae_line_rec.transaction_value * l_curr_rec.currency_conv_rate ));
                  ELSE
                    fnd_file.put_line(fnd_file.log,'CR Expense: '||to_char( l_ae_line_rec.transaction_value *  l_curr_rec.currency_conv_rate ));
                  END IF;
                END IF;


                CSTPAPPR.insert_account (i_ae_txn_rec,
                                         l_curr_rec,
                                         l_dr_flag,
                                         l_ae_line_rec,
                                         l_ae_line_tbl,
                                         l_err_rec);

                 IF (l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null)
                 THEN
                   raise process_error;
                 END IF;

                l_dr_flag := not l_dr_flag;
                l_ae_line_rec.account := c_receipts_rec.receiving_account_id;
                l_ae_line_rec.ae_line_type := 5;
                IF (c_receipts_rec.dist_quantity = 0) THEN
                  l_ae_line_rec.rate_or_amount := 0;
                ELSE
                  l_ae_line_rec.rate_or_amount := l_ae_line_rec.transaction_value * l_curr_rec.currency_conv_rate / c_receipts_rec.dist_quantity;
                END IF;

                IF l_debug_flag = 'Y' THEN
                  IF (l_dr_flag) THEN
                    fnd_file.put_line(fnd_file.log,'DR RI: '||to_char( l_ae_line_rec.transaction_value *  l_curr_rec.currency_conv_rate ));
                  ELSE
                    fnd_file.put_line(fnd_file.log,'CR RI: '||to_char( l_ae_line_rec.transaction_value *  l_curr_rec.currency_conv_rate ));
                  END IF;
                END IF;

                CSTPAPPR.insert_account (i_ae_txn_rec,
                                         l_curr_rec,
                                         l_dr_flag,
                                         l_ae_line_rec,
                                         l_ae_line_tbl,
                                         l_err_rec);
                 IF (l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null)
                 THEN
                   raise process_error;
                 END IF;

-- Take care of rounding errors.
-- -----------------------------
                 l_stmt_num := 80;
                 balance_account (l_ae_line_tbl,
                                  l_err_rec);

                 -- check error
                 if (l_err_rec.l_err_num <> 0) then
                     raise process_error;
                 end if;

                 l_stmt_num := 85;
                 -----------------------------------------------------------
                 -- Encumbrance entries
                 -- First check if encumbrance is on
                 -- Get the encumbrance type flag and budget account
                 -----------------------------------------------------------

                 -- If the budget account was not specified at PO creation
                 -- no encumbrance reversal is necessary

                 IF (c_receipts_rec.encumbrance_account_id = -1) THEN
                   IF l_debug_flag = 'Y' THEN
                     fnd_file.put_line(fnd_file.log,'No Encumbrance account at PO level');
                   END IF;
                 ELSE

                 CSTPAPPR.check_encumbrance(
                 i_transaction_id => i_ae_txn_rec.transaction_id,
                 i_set_of_books_id => i_ae_txn_rec.set_of_books_id,
                 i_period_name => i_ae_txn_rec.accounting_period_name,
                 i_encumbrance_account_id => c_receipts_rec.encumbrance_account_id,
                 o_enc_flag => l_enc_flag,
                 o_purch_encumbrance_type_id => l_purch_encumbrance_type_id,
                 o_purch_encumbrance_flag => l_purch_encumbrance_flag,
                 o_ae_err_rec => l_err_rec);
                 if (l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null)
                     then
                   raise process_error;
                 end if;

                 /* Commented and replaced for forward port bug 5768550
                 IF (l_enc_flag = 'Y' and l_purch_encumbrance_flag = 'Y') then*/
                 IF l_purch_encumbrance_flag = 'Y' THEN

                 ------------------------------------------------------------------
                 -- For encumbrance :
                 -- At the time of PO creation, if encumbrance is turned on,
                 -- encumbrance is created for the quantity ordered @po price
                 -- At the time of delivery , if the reversal flag is turned on,
                 -- reversing entries need to be generated for the quantity delivered
                 -- but not exceeding the quantity encumbered.
                 -------------------------------------------------------------------

                 -------------------------------------------------------------------
                 -- Get the quantity delivered before the current transaction
                 -- This quantity will be used to determine the amount that has
                 -- been reversed and the quantity available to unencumber.
                 -------------------------------------------------------------------

                   l_quantity_delivered := CSTPAPPR.get_net_del_qty(
                                             c_receipts_rec.po_distribution_id,
                                             i_ae_txn_rec.transaction_id);
                   IF l_debug_flag = 'Y' THEN
                     fnd_file.put_line(fnd_file.log,'Delivered Quantity: '||to_char(l_quantity_delivered));
                   END IF;

                   l_stmt_num := 86;

                 ------------------------------------------------------------------
                 -- cases possible:
                 -- I. current transaction is a net deliver transaction
                 --     a. quantity ordered > quantity delivered
                 --          1. quantity delivered after the current txn becomes > ordered
                 --                 qty to unencumber = (ordered - delivered)
                 --          2. quantity delivered after the current txn remains < ordered
                 --                 qty to unencumber = qty of current txn
                 --     b. quantity ordered < quantity delivered
                 --          1. quantity delivered remains > ordered
                 --                 qty to unencumber = 0
                 -- II. current transaction is a net return transaction
                 --     a. quantity ordered > quantity delivered
                 --          1. quantity delivered remains < quantity delivered
                 --                 qty to unencumber = qty of current txn
                 --     b. quantity ordered < quantity delivered
                 --          1. quantity delivered after current txn becomes < ordered
                 --                 qty to unencumber = qty of current txn - (qty del - qty ord)
                 --          2. quantity delivered after current txn remains > ordered
                 --                 qty to unencumber = 0
                 -- Finally, Convert the quantity into Primary UOM
                 ---------------------------------------------------------------------------------
-- J Changes ---------------------------------------------------------------------------
-- Compute Net Delivered Amount for Service Line Types
                   IF C_RECEIPTS_REC.SERVICE_FLAG <> 1 THEN
                     SELECT
                     decode (l_net_receipt,
                           1,
                           least(
                             abs(rt.source_doc_quantity),
                             greatest(POD.quantity_ordered-l_quantity_delivered,0)
                           ),
                           -1,
                           greatest(
                             (least(POD.quantity_ordered-l_quantity_delivered,0) + abs(rt.source_doc_quantity)),
                             0
                           ),
                           0
                          ) * rt.primary_quantity/rt.source_doc_quantity * l_po_price,
                       nvl(POD.rate, 1),
                       pod.rate_date
                       INTO
                       l_encum_amount,
                       l_po_rate,
                       l_po_rate_date
                       FROM
                       po_headers_all                POH,
                       po_lines_all                  POL,
                       po_line_locations_all         POLL,
                       po_distributions_all          POD,
                       rcv_transactions              RT
                       WHERE
                       POH.po_header_id = POD.po_header_id AND
                       POL.po_line_id   = POD.po_line_id AND
                       POLL.line_location_id = POD.line_location_id AND
                       POD.po_distribution_id = c_receipts_rec.po_distribution_id AND
                       nvl(POLL.accrue_on_receipt_flag,'N') = 'Y' AND
                       /*nvl(POD.accrue_on_receipt_flag,'N') = 'Y' AND     */
                       RT.transaction_id = i_ae_txn_rec.transaction_id AND
                       POD.destination_type_code = 'EXPENSE';

                     ELSE -- Service Line Types
                       SELECT
                       decode (l_net_receipt,
                           1,
                           least(
                             abs(RT.AMOUNT),
                             greatest(POD.AMOUNT_ORDERED - L_QUANTITY_DELIVERED, 0)
                           ),
                           -1,
                           greatest(
                             (least(POD.AMOUNT_ORDERED - L_QUANTITY_DELIVERED, 0) + abs(rt.AMOUNT)),
                             0
                           ),
                           0
                          ) * l_po_price,
                       nvl(POD.rate, 1),
                       pod.rate_date
                       INTO
                       l_encum_amount,
                       l_po_rate,
                       l_po_rate_date
                       FROM
                       po_headers_all                POH,
                       po_lines_all                  POL,
                       po_line_locations_all         POLL,
                       po_distributions_all          POD,
                       rcv_transactions              RT
                       WHERE
                            POH.po_header_id                     = POD.po_header_id
                       AND  POL.po_line_id                       = POD.po_line_id
                       AND  POLL.line_location_id                = POD.line_location_id
                       AND  POD.po_distribution_id               = c_receipts_rec.po_distribution_id
                       AND  nvl(POLL.accrue_on_receipt_flag,'N') = 'Y'
                       /*AND  nvl(POD.accrue_on_receipt_flag,'N')  = 'Y'  */
                       AND  RT.transaction_id                    = i_ae_txn_rec.transaction_id
                       AND  POD.destination_type_code            = 'EXPENSE';
                     END IF;
----------------------------------------------------------------------------------------------

                     IF (l_net_receipt = 1) then
                       l_dr_flag := FALSE;
                     ELSE
                       l_dr_flag := TRUE;
                     END IF;
                     l_curr_rec.currency_conv_rate := l_po_rate;
                     l_curr_rec.currency_conv_date := l_po_rate_date;
                     l_ae_line_rec.transaction_value := l_encum_amount;
                     l_ae_line_rec.account := c_receipts_rec.encumbrance_account_id;
                     l_ae_line_rec.ae_line_type := 15;
                     l_ae_line_rec.actual_flag := 'E';
                     l_ae_line_rec.encum_type_id := l_purch_encumbrance_type_id;

                     IF l_debug_flag = 'Y' THEN
                       IF (l_dr_flag) THEN
                         fnd_file.put_line(fnd_file.log,'DR Enc: '||to_char( l_ae_line_rec.transaction_value *  l_curr_rec.currency_conv_rate ));
                       ELSE
                         fnd_file.put_line(fnd_file.log,'CR Enc: '||to_char( l_ae_line_rec.transaction_value *  l_curr_rec.currency_conv_rate ));
                       END IF;
                     END IF;
                    /* Bug 2686598. Use the quantity in the po_distribution to calcualte rate_or_amount
                       not the primary quantity on the transaction */
                     IF (c_receipts_rec.dist_quantity = 0) THEN
                       l_ae_line_rec.rate_or_amount := 0;
                     ELSE
                       l_ae_line_rec.rate_or_amount := l_ae_line_rec.transaction_value * l_curr_rec.currency_conv_rate / c_receipts_rec.dist_quantity;
                     END IF;

                     CSTPAPPR.insert_account (i_ae_txn_rec,
                                              l_curr_rec,
                                              l_dr_flag,
                                              l_ae_line_rec,
                                              l_ae_line_tbl,
                                              l_err_rec);
                    IF (l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null)
                    THEN
                      raise process_error;
                    END IF;


                 END IF;  /* if enc on */

                 END IF; /* if po budget acct specified */

              END IF; /*stage if*/
          --END IF; /* expense if*/
        END LOOP;
    EXCEPTION
      when process_error then
      o_ae_err_rec.l_err_num := l_err_rec.l_err_num;
      o_ae_err_rec.l_err_code := l_err_rec.l_err_code;
      o_ae_err_rec.l_err_msg := l_err_rec.l_err_msg;

    END;


    -- Return the lines pl/sql table.
    -- ------------------------------
    l_stmt_num := 90;
    o_ae_line_rec_tbl := l_ae_line_tbl;
  IF l_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Create_Rcv_Ae_Lines >>> ');
  END IF;

EXCEPTION

  when process_error then
  o_ae_err_rec.l_err_num := l_err_rec.l_err_num;
  o_ae_err_rec.l_err_code := l_err_rec.l_err_code;
  o_ae_err_rec.l_err_msg := l_err_rec.l_err_msg;

  when cst_no_po_dist then
  o_ae_err_rec.l_err_num := l_err_rec.l_err_num;
  o_ae_err_rec.l_err_code := l_err_rec.l_err_code;
  FND_MESSAGE.set_name('BOM', 'CST_NO_RCV_LINE');
  o_ae_err_rec.l_err_msg := FND_MESSAGE.Get;

  when others then
  o_ae_err_rec.l_err_num := SQLCODE;
  o_ae_err_rec.l_err_code := '';
  o_ae_err_rec.l_err_msg := 'CSTPAPPR.create_rcv_ae_lines : ' || to_char(l_stmt_num) || ':'||
  substr(SQLERRM,1,180);

END create_rcv_ae_lines;

-- Retro Changes--------------------------------------------------------------
PROCEDURE create_adj_ae_lines(
  p_ae_txn_rec            IN         CSTPALTY.cst_ae_txn_rec_type,
  x_ae_line_rec_tbl       OUT NOCOPY CSTPALTY.cst_ae_line_tbl_type,
  x_ae_err_rec            OUT NOCOPY CSTPALTY.cst_ae_err_rec_type
) IS
  l_ae_line_tbl  CSTPALTY.CST_AE_LINE_TBL_TYPE;
  l_ae_line_rec  CSTPALTY.CST_AE_LINE_REC_TYPE;
  l_curr_rec     CSTPALTY.cst_ae_curr_rec_type;
  l_err_rec      CSTPALTY.cst_ae_err_rec_type;
  l_dr_flag      BOOLEAN;

  -- Retroactive Pricing --
  l_current_transaction_value NUMBER;
  l_prior_transaction_value   NUMBER;

  l_current_entered_value     NUMBER;
  l_prior_entered_value       NUMBER;

  l_current_accounted_value   NUMBER;
  l_prior_accounted_value     NUMBER;
  -------------------------


  l_stmt_num      NUMBER := 0;
  l_debit_account NUMBER;
  INVALID_RETRO_ADJ_ACCOUNT    EXCEPTION;
  PROCESS_ERROR                EXCEPTION;

BEGIN

  IF l_debug_flag = 'Y' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Create_Adj_Ae_Lines <<<');
  END IF;

  -- Initialize the collection
  l_ae_line_tbl := CSTPALTY.cst_ae_line_tbl_type();

  -- Populate the Currency Structure
  l_stmt_num := 10;

  select
    currency_code
  into
    l_curr_rec.pri_currency
  from
    gl_sets_of_books
  where
    set_of_books_id = p_ae_txn_rec.set_of_books_id;

  l_stmt_num := 20;

  l_curr_rec.alt_currency       := p_ae_txn_rec.currency_code;
  l_curr_rec.currency_conv_date := p_ae_txn_rec.currency_conv_date;
  l_curr_rec.currency_conv_type := p_ae_txn_rec.currency_conv_type;
  l_curr_rec.currency_conv_rate := p_ae_txn_rec.currency_conv_rate;


  IF l_debug_flag = 'Y' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, l_curr_rec.pri_currency || ' '||l_curr_rec.alt_currency);
  END IF;

  -- Populate the Accounting Line Record

  -- For ADJUST_RECEIVE events, the accounting is as follows:
  -- Dr Periodic Retroactive Adjustment Account
  --   Cr Accrual

  l_stmt_num := 30;

  -- Get the debit account
  SELECT
    nvl(RETRO_PRICE_ADJ_ACCOUNT, -1)
  INTO
    l_debit_account
  FROM
    CST_ORG_COST_GROUP_ACCOUNTS
  WHERE
      LEGAL_ENTITY_ID = P_AE_TXN_REC.LEGAL_ENTITY_ID
  AND COST_TYPE_ID    = P_AE_TXN_REC.COST_TYPE_ID
  AND COST_GROUP_ID   = P_AE_TXN_REC.COST_GROUP_ID;

  IF l_debug_flag = 'Y' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Debit Account: '||to_char(l_debit_account));
  END IF;

  IF l_debit_account = -1 THEN
    RAISE INVALID_RETRO_ADJ_ACCOUNT;
  END IF;

  l_stmt_num := 40;
  -- Debit

  l_dr_flag := TRUE;
  -- The Line Type is seeded in MFG_LOOKUPS (CST_ACCOUNTING_LINE_TYPE)
  l_ae_line_rec.ae_line_type       := 32;

  l_ae_line_rec.account            := l_debit_account;

  l_current_transaction_value      := p_ae_txn_rec.primary_quantity * p_ae_txn_rec.unit_price;
  l_prior_transaction_value        := p_ae_txn_rec.primary_quantity * p_ae_txn_rec.prior_unit_price;

  -- Adjustment Amount is computed as:
  -- Round(Round(unit_price * qty) * rate) - Round(Round(prior_unit_price*qty) * rate)

  -- Rounding is done using the Minimum accounting unit or currency precision
  -- Rounded Current_Transaction Value
  select
         decode(l_curr_rec.alt_currency,NULL, NULL,
                l_curr_rec.pri_currency, NULL,
                decode(c2.minimum_accountable_unit,
                       NULL,
                       round(l_current_transaction_value, c2.precision),
                       round(l_current_transaction_value /c2.minimum_accountable_unit)
                      * c2.minimum_accountable_unit )),
         decode(c1.minimum_accountable_unit,
                NULL, round(l_current_transaction_value * l_curr_rec.currency_conv_rate, c1.precision),
                round(l_current_transaction_value * l_curr_rec.currency_conv_rate/c1.minimum_accountable_unit)
                * c1.minimum_accountable_unit ),
         decode(l_curr_rec.alt_currency,NULL, NULL,
                l_curr_rec.pri_currency, NULL,
                decode(c2.minimum_accountable_unit,
                       NULL,
                       round(l_prior_transaction_value, c2.precision),
                       round(l_prior_transaction_value /c2.minimum_accountable_unit)
                      * c2.minimum_accountable_unit )),
         decode(c1.minimum_accountable_unit,
                NULL, round(l_prior_transaction_value * l_curr_rec.currency_conv_rate, c1.precision),
                round(l_prior_transaction_value * l_curr_rec.currency_conv_rate/c1.minimum_accountable_unit)
                * c1.minimum_accountable_unit )
  into
      l_current_entered_value,
      l_current_accounted_value,
      l_prior_entered_value,
      l_prior_accounted_value
  from
      fnd_currencies c1,
      fnd_currencies c2
  where
      c1.currency_code = l_curr_rec.pri_currency
      and c2.currency_code = decode(l_curr_rec.alt_currency, NULL,
                                                                l_curr_rec.pri_currency,
                                                                l_curr_rec.alt_currency);

  l_ae_line_rec.accounted_value  := l_current_accounted_value - l_prior_accounted_value;
  l_ae_line_rec.entered_value    := l_current_entered_value - l_prior_entered_value;

  l_ae_line_rec.transaction_value := l_ae_line_rec.accounted_value;

  IF l_debug_flag = 'Y' THEN
    FND_FILE.PUT_LINE(FND_FILE.log, 'l_ae_line_rec.accounted_value: '||to_char(l_ae_line_rec.accounted_value));
  END IF;

  l_ae_line_rec.source_table       := 'RAE';
  l_ae_line_rec.source_id          := p_ae_txn_rec.transaction_id;

  IF p_ae_txn_rec.primary_quantity <> 0 THEN
    l_ae_line_rec.rate_or_amount     := p_ae_txn_rec.unit_price * l_curr_rec.currency_conv_rate;
  ELSE
    l_ae_line_rec.rate_or_amount     := 0 ;
  END IF;

  l_ae_line_rec.po_distribution_id := p_ae_txn_rec.po_distribution_id;

  l_stmt_num := 50;

  CSTPAPPR.insert_account (p_ae_txn_rec,
                           l_curr_rec,
                           l_dr_flag,
                           l_ae_line_rec,
                           l_ae_line_tbl,
                           l_err_rec);

  IF (l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null) THEN
    raise process_error;
  END IF;

  -- Credit
  -- Credit Account is the accrual account (stamped as Credit_Account on the
  -- transaction
  l_stmt_num := 60;

  l_dr_flag := NOT l_dr_flag;

  l_ae_line_rec.account      := p_ae_txn_rec.credit_account;
  l_ae_line_rec.ae_line_type := 16;
  IF l_debug_flag = 'Y' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Credit Account: '||to_char(l_ae_line_rec.account));
  END IF;

  l_stmt_num := 70;

  CSTPAPPR.insert_account (p_ae_txn_rec,
                           l_curr_rec,
                           l_dr_flag,
                           l_ae_line_rec,
                           l_ae_line_tbl,
                           l_err_rec);

  IF (l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null) THEN
    raise process_error;
  END IF;

  -- Copy the local structure to the Output
  x_ae_line_rec_tbl := l_ae_line_tbl;

  IF l_debug_flag = 'Y' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Create_Adj_Ae_Lines >>>');
  END IF;

EXCEPTION
  WHEN INVALID_RETRO_ADJ_ACCOUNT THEN
    l_err_rec.l_err_num  := SQLCODE;
    l_err_rec.l_err_code := 'No Periodic Retroactive Adjustment Account Specified';
    l_err_rec.l_err_msg  := 'CSTPAPPR:( '||to_char(l_stmt_num)||' ): ' || l_err_rec.l_err_code;
    x_ae_err_rec         := l_err_rec;
    FND_FILE.PUT_LINE(FND_FILE.LOG, l_err_rec.l_err_msg);

  WHEN PROCESS_ERROR THEN
    x_ae_err_rec         := l_err_rec;
    FND_FILE.PUT_LINE(FND_FILE.LOG, l_err_rec.l_err_msg);

  WHEN OTHERS THEN
    l_err_rec.l_err_num  := SQLCODE;
    l_err_rec.l_err_code := '';
    l_err_rec.l_err_msg  := 'CSTPAPPR:( '||to_char(l_stmt_num)||' ): ' || to_char(SQLCODE);
    x_ae_err_rec         := l_err_rec;
    FND_FILE.PUT_LINE(FND_FILE.LOG, l_err_rec.l_err_msg);

END create_adj_ae_lines;

/*LCM CHANGES */

PROCEDURE create_lc_adj_ae_lines(
  p_ae_txn_rec            IN         CSTPALTY.cst_ae_txn_rec_type,
  x_ae_line_rec_tbl       OUT NOCOPY CSTPALTY.cst_ae_line_tbl_type,
  x_ae_err_rec            OUT NOCOPY CSTPALTY.cst_ae_err_rec_type
) IS
  l_ae_line_tbl  CSTPALTY.CST_AE_LINE_TBL_TYPE;
  l_ae_line_rec  CSTPALTY.CST_AE_LINE_REC_TYPE;
  l_curr_rec     CSTPALTY.cst_ae_curr_rec_type;
  l_err_rec      CSTPALTY.cst_ae_err_rec_type;
  l_dr_flag      BOOLEAN;


  l_current_transaction_value NUMBER;
  l_prior_transaction_value   NUMBER;

  l_stmt_num      NUMBER := 0;
  PROCESS_ERROR                EXCEPTION;

BEGIN

  IF l_debug_flag = 'Y' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Create_LC_Adj_Ae_Lines <<<');
  END IF;

  -- Initialize the collection
  l_ae_line_tbl := CSTPALTY.cst_ae_line_tbl_type();

  -- Populate the Currency Structure
  l_stmt_num := 10;

  select
    currency_code
  into
    l_curr_rec.pri_currency
  from
    gl_sets_of_books
  where
    set_of_books_id = p_ae_txn_rec.set_of_books_id;

  l_stmt_num := 20;

  l_curr_rec.alt_currency       := p_ae_txn_rec.currency_code;
  l_curr_rec.currency_conv_date := p_ae_txn_rec.currency_conv_date;
  l_curr_rec.currency_conv_type := p_ae_txn_rec.currency_conv_type;
  l_curr_rec.currency_conv_rate := p_ae_txn_rec.currency_conv_rate;


  IF l_debug_flag = 'Y' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, l_curr_rec.pri_currency || ' '||l_curr_rec.alt_currency);
  END IF;

  l_stmt_num := 30;

  l_dr_flag := TRUE;
  l_ae_line_rec.account            := p_ae_txn_rec.debit_account;
  l_current_transaction_value      := p_ae_txn_rec.primary_quantity * p_ae_txn_rec.unit_price;
  l_prior_transaction_value        := p_ae_txn_rec.primary_quantity * p_ae_txn_rec.prior_unit_price;
  l_ae_line_rec.transaction_value := l_current_transaction_value - l_prior_transaction_value;
  IF( p_ae_txn_rec.event_type_id = 'PAC LC ADJ REC') THEN
    IF (l_ae_line_rec.transaction_value>=0) THEN
       l_ae_line_rec.ae_line_type       := 5;
    ELSE
       l_ae_line_rec.ae_line_type       := 38;
    END IF;
  ELSIF( p_ae_txn_rec.event_type_id = 'PAC LC ADJ DEL ASSET') THEN
    IF (l_ae_line_rec.transaction_value>=0) THEN
       l_ae_line_rec.ae_line_type       := 38;
    ELSE
       l_ae_line_rec.ae_line_type       := 5;
    END IF;
  ELSIF( p_ae_txn_rec.event_type_id = 'PAC LC ADJ DEL EXP') THEN
    IF (l_ae_line_rec.transaction_value>=0) THEN
       l_ae_line_rec.ae_line_type       := 2;
    ELSE
       l_ae_line_rec.ae_line_type       := 5;
    END IF;
  END IF;


  IF l_debug_flag = 'Y' THEN
    FND_FILE.PUT_LINE(FND_FILE.log, 'l_ae_line_rec.accounted_value: '||to_char(l_ae_line_rec.accounted_value));
  END IF;

  l_ae_line_rec.source_table       := 'RAE';
  l_ae_line_rec.source_id          := p_ae_txn_rec.transaction_id;

  IF p_ae_txn_rec.primary_quantity <> 0 THEN
    l_ae_line_rec.rate_or_amount     := p_ae_txn_rec.unit_price * l_curr_rec.currency_conv_rate;
  ELSE
    l_ae_line_rec.rate_or_amount     := 0 ;
  END IF;

  l_ae_line_rec.po_distribution_id := p_ae_txn_rec.po_distribution_id;

  l_stmt_num := 50;

  CSTPAPPR.insert_account (p_ae_txn_rec,
                           l_curr_rec,
                           l_dr_flag,
                           l_ae_line_rec,
                           l_ae_line_tbl,
                           l_err_rec);

  IF (l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null) THEN
    raise process_error;
  END IF;

 l_stmt_num := 60;

  l_dr_flag := NOT l_dr_flag;

  l_ae_line_rec.account      := p_ae_txn_rec.credit_account;
  IF( p_ae_txn_rec.event_type_id = 'PAC LC ADJ REC') THEN
    IF (l_ae_line_rec.transaction_value>=0) THEN
       l_ae_line_rec.ae_line_type       := 38;
    ELSE
       l_ae_line_rec.ae_line_type       := 5;
    END IF;
  ELSIF( p_ae_txn_rec.event_type_id = 'PAC LC ADJ DEL ASSET') THEN
    IF (l_ae_line_rec.transaction_value>=0) THEN
       l_ae_line_rec.ae_line_type       := 5;
    ELSE
       l_ae_line_rec.ae_line_type       := 38;
    END IF;
  ELSIF( p_ae_txn_rec.event_type_id = 'PAC LC ADJ DEL EXP') THEN
    IF (l_ae_line_rec.transaction_value>=0) THEN
       l_ae_line_rec.ae_line_type       := 5;
    ELSE
       l_ae_line_rec.ae_line_type       := 2;
    END IF;
  END IF;

  IF l_debug_flag = 'Y' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Credit Account: '||to_char(l_ae_line_rec.account));
  END IF;

  l_stmt_num := 70;

  CSTPAPPR.insert_account (p_ae_txn_rec,
                           l_curr_rec,
                           l_dr_flag,
                           l_ae_line_rec,
                           l_ae_line_tbl,
                           l_err_rec);

  IF (l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null) THEN
    raise process_error;
  END IF;

  -- Copy the local structure to the Output
  x_ae_line_rec_tbl := l_ae_line_tbl;

  IF l_debug_flag = 'Y' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Create_LC_Adj_Ae_Lines >>>');
  END IF;

EXCEPTION
  WHEN PROCESS_ERROR THEN
    x_ae_err_rec         := l_err_rec;
    FND_FILE.PUT_LINE(FND_FILE.LOG, l_err_rec.l_err_msg);

  WHEN OTHERS THEN
    l_err_rec.l_err_num  := SQLCODE;
    l_err_rec.l_err_code := '';
    l_err_rec.l_err_msg  := 'CSTPAPPR:( '||to_char(l_stmt_num)||' ): ' || to_char(SQLCODE);
    x_ae_err_rec         := l_err_rec;
    FND_FILE.PUT_LINE(FND_FILE.LOG, l_err_rec.l_err_msg);

END create_lc_adj_ae_lines;
/*============================================================================+
| This procedure processes the transaction data and creates accounting entry  |
| lines in the form of PL/SQL table and returns to the main procedure.        |
| This procedure processes the period end accruals                            |
| This is called during the period close process                              |
|============================================================================*/

PROCEDURE create_per_end_ae_lines(
  i_ae_txn_rec          IN     CSTPALTY.cst_ae_txn_rec_type,
  o_ae_line_rec_tbl     OUT NOCOPY    CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec          OUT NOCOPY    CSTPALTY.cst_ae_err_rec_type
) IS
  l_ae_line_tbl                CSTPALTY.CST_AE_LINE_TBL_TYPE;
  l_ae_line_rec                CSTPALTY.CST_AE_LINE_REC_TYPE;
  l_curr_rec                   CSTPALTY.cst_ae_curr_rec_type;
  l_err_rec                    CSTPALTY.cst_ae_err_rec_type;

  l_doc_level                  VARCHAR2(1);
  l_doc_id                     NUMBER;
  l_dist_count                 NUMBER;
  l_purch_encumbrance_type_id  NUMBER;
  l_purch_encumbrance_flag     VARCHAR2(1);
  l_enc_flag                   VARCHAR2(1);
  l_bud_enc_flag               VARCHAR2(1);
  l_dr_flag                    BOOLEAN;

  l_stmt_num                   NUMBER;

  l_po_uom_factor              NUMBER;
  l_rcv_uom_factor             NUMBER;
  l_period_end_date            DATE;
  l_accrual_qty                NUMBER;
  l_encum_qty                  NUMBER;

  l_return_status              VARCHAR2(1);
  l_msg_count                  NUMBER;
  l_msg_data                   VARCHAR2(240);

  process_error                EXCEPTION;
  CST_NO_PO_DIST               EXCEPTION;

BEGIN

  IF l_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Create_Per_End_Ae_Lines <<<');
  END IF;

  --  Initialize API return status to success
  l_return_status := FND_API.G_RET_STS_SUCCESS;

  l_ae_line_tbl := CSTPALTY.cst_ae_line_tbl_type();

-- Initialize local variables.
-- ---------------------------
  l_err_rec.l_err_num := 0;
  l_err_rec.l_err_code := '';
  l_err_rec.l_err_msg := '';

-- Populate the Currency Record Type
-- ---------------------------------
  l_stmt_num := 10;

  select currency_code
  into l_curr_rec.pri_currency
  from gl_sets_of_books
  where set_of_books_id = i_ae_txn_rec.set_of_books_id;

  l_curr_rec.alt_currency := i_ae_txn_rec.currency_code;
  l_curr_rec.currency_conv_date := i_ae_txn_rec.currency_conv_date;
  l_curr_rec.currency_conv_type := i_ae_txn_rec.currency_conv_type;

  l_stmt_num := 30;

    ------------------------------------------------------------
    -- A receipt can be at the shipment level or the distribution level:
    -- When receiving and delivering in one step, it is at the distribution level
    -- When receiving and delivering as two different steps, it is shipment level
    -- Get the document level as 'S' for shipment and 'D' for distribution
    ------------------------------------------------------------
    -- Get the level

    l_stmt_num := 60;

    SELECT
    decode(rt.po_distribution_id, NULL, 'S', 'D'),
    nvl(rt.po_distribution_id, rt.po_line_location_id)
    INTO
    l_doc_level,
    l_doc_id
    FROM
    rcv_transactions rt
    WHERE
    rt.transaction_id = i_ae_txn_rec.transaction_id;

    IF l_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'Document Level: '||l_doc_level);
      fnd_file.put_line(fnd_file.log,'Document ID: '||to_char(l_doc_id));
      fnd_file.put_line(fnd_file.log,'Quantity: '||to_char(i_ae_txn_rec.primary_quantity));
    END IF;

    SELECT
    count(*)
    into
    l_dist_count
    FROM
    po_distributions_all
    WHERE
    (
      (l_doc_level = 'D' AND po_distribution_id = l_doc_id)
      OR (l_doc_level = 'S' AND line_location_id = l_doc_id)
    )
    AND rownum <= 1;

    IF (l_dist_count = 0) THEN
      IF l_debug_flag = 'Y' THEN
        fnd_file.put_line(fnd_file.log,'Error: No distributions for the Document: '||to_char(l_doc_id));
      END IF;
      RAISE CST_NO_PO_DIST;
    END IF;

    ------------------------------------------------------------------
    -- If the document level is Shipment, get all the distributions
    -- for the Shipment, against which the receipt occurred.
    -- If the document level is Distribution, get the distribution
    -- Loop for each distribution that is NOT accrued at receipt
    ------------------------------------------------------------------

    DECLARE
    ------------------------------------------------------------------
    -- Complex Work Procurement changes
    -- Whether the shipment is quantity based or amount based, is determined
    -- by poll.matching_basis = 'QUANTITY' or poll.matching_basis = 'AMOUNT'
    ------------------------------------------------------------------
      CURSOR c_receive_dists IS
        SELECT
        decode (poll.match_option,'R',i_ae_txn_rec.currency_conv_rate,nvl(pod.rate,1)) "EXCHG_RATE",
        decode (poll.match_option,'R',i_ae_txn_rec.currency_conv_date,pod.rate_date) "EXCHG_DATE",
        DECODE (poll.matching_basis, 'AMOUNT', 1, 0) "SERVICE_FLAG",
        POD.po_distribution_id "PO_DISTRIBUTION_ID",
        nvl(POD.rate,1) "PO_RATE",
        pod.rate_date "PO_DATE",
        POLL.line_location_id "PO_LINE_LOCATION_ID",
        POD.code_combination_id "EXPENSE_ACCOUNT_ID",
        POD.destination_type_code "DESTINATION_TYPE_CODE",
        RP.receiving_account_id "RECEIVING_ACCOUNT_ID",
        POD.accrual_account_id "ACCRUAL_ACCOUNT_ID",
        nvl(POD.budget_account_id,-1) "ENCUMBRANCE_ACCOUNT_ID",
        decode(poll.matching_basis,
               'AMOUNT', poll.amount - NVL(poll.amount_cancelled,0),
               poll.quantity - NVL(poll.quantity_cancelled,0)) "SHIPMENT_QUANTITY",
        decode(poll.matching_basis,
              'AMOUNT', pod.amount_ordered - NVL(pod.amount_cancelled, 0),
           pod.quantity_ordered - NVL(pod.quantity_cancelled, 0)) "DIST_QUANTITY",
        decode(poll.matching_basis,
               'AMOUNT', 1,
                NVL(poll.price_override, pol.unit_price)) +
                   (po_tax_sv.get_tax( 'PO', pod.po_distribution_id) /
                         decode(poll.matching_basis,
                               'AMOUNT', pod.amount_ordered,
                               pod.quantity_ordered)) "UNIT_PRICE",
        NVL(poll.match_option,'P') "MATCH_OPTION"
        FROM
        po_distributions_all pod,
        po_line_locations_all poll,
        po_lines_all pol,
        rcv_parameters rp
        WHERE
        (
          (l_doc_level = 'D' AND pod.po_distribution_id = l_doc_id)
          OR (l_doc_level = 'S' AND poll.line_location_id = l_doc_id)
        )
        and pod.line_location_id                  = poll.line_location_id
        and poll.po_line_id                       = pol.po_line_id
        and rp.organization_id                    = pod.destination_organization_id
        and pod.destination_type_code             = 'EXPENSE'
        and  nvl(POLL.accrue_on_receipt_flag,'N') = 'N'
        and nvl(POD.accrue_on_receipt_flag,'N')   = 'N'
	  /*BUG 8302671
 	           Only accrue if Ordered Quantity - Cancelled Quantity is > 0 */
 	         and  DECODE (poll.matching_basis,
 	                                 'AMOUNT',  pod.amount_ordered - NVL(pod.amount_cancelled, 0),
 	                                  pod.quantity_ordered - NVL(pod.quantity_cancelled, 0))  > 0
 	                  AND DECODE(poll.matching_basis,
 	                                 'AMOUNT',  poll.amount - NVL(poll.amount_cancelled, 0),
 	                                 poll.quantity - NVL(poll.quantity_cancelled,0)) > 0;

    BEGIN
        l_stmt_num := 70;

        FOR c_receipts_rec IN c_receive_dists LOOP

          l_ae_line_rec.actual_flag := NULL;
          l_ae_line_rec.po_distribution_id := c_receipts_rec.po_distribution_id;

          l_period_end_date := i_ae_txn_rec.accounting_date + 0.99999;

          -------------------------------------------------------------------
          -- Period End Accrual rewrite changes
          -- The procedure CST_PerEndAccruals_PVT.Calculate_AccrualAmount
          -- returns the accrual_amount and encum_amount along with quantity_received
          -- and quantity_invoiced against the po_distribution_id.
          -------------------------------------------------------------------
          l_stmt_num := 80;
          CST_PerEndAccruals_PVT.Calculate_AccrualAmount(
              p_api_version               => 1.0,
              p_init_msg_list             => FND_API.G_FALSE,
              p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
              x_return_status             => l_return_status,
              x_msg_count                 => l_msg_count,
              x_msg_data                  => l_msg_data,
              p_match_option              => c_receipts_rec.match_option,
              p_distribution_id           => c_receipts_rec.po_distribution_id,
              p_shipment_id               => c_receipts_rec.po_line_location_id,
              p_transaction_id            => i_ae_txn_rec.transaction_id,
              p_service_flag              => c_receipts_rec.service_flag,
              p_dist_qty                  => c_receipts_rec.dist_quantity,
              p_shipment_qty              => c_receipts_rec.shipment_quantity,
              p_end_date                  => l_period_end_date,
              x_accrual_qty               => l_accrual_qty,
              x_encum_qty                 => l_encum_qty
              );

            -- If return status is not success, raise exception
            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
                l_err_rec.l_err_num := 20001 ;
                l_err_rec.l_err_msg := l_msg_data;
                raise process_error;
            END IF;


            l_ae_line_rec.transaction_value := l_accrual_qty * c_receipts_rec.unit_price;
            l_ae_line_rec.rate_or_amount := c_receipts_rec.unit_price * c_receipts_rec.exchg_rate;

            l_curr_rec.currency_conv_rate := c_receipts_rec.exchg_rate;
            l_curr_rec.currency_conv_date := c_receipts_rec.exchg_date;
            l_curr_rec.currency_conv_type := i_ae_txn_rec.currency_conv_type;

            l_dr_flag := TRUE;

            l_ae_line_rec.account := c_receipts_rec.expense_account_id;
            l_ae_line_rec.ae_line_type := 20;
            IF l_debug_flag = 'Y' THEN
              IF (l_dr_flag) THEN
                fnd_file.put_line(fnd_file.log,'DR Expense: '||to_char( l_ae_line_rec.transaction_value * l_curr_rec.currency_conv_rate ));
              ELSE
                fnd_file.put_line(fnd_file.log,'CR Expense: '||to_char( l_ae_line_rec.transaction_value *  l_curr_rec.currency_conv_rate ));
              END IF;
            END IF;

            CSTPAPPR.insert_account (i_ae_txn_rec,
                                     l_curr_rec,
                                     l_dr_flag,
                                     l_ae_line_rec,
                                     l_ae_line_tbl,
                                     l_err_rec);
            IF (l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null)
            THEN
               raise process_error;
            END IF;

            l_dr_flag := not l_dr_flag;

            l_ae_line_rec.account := c_receipts_rec.accrual_account_id;
            l_ae_line_rec.ae_line_type := 16;

            IF l_debug_flag = 'Y' THEN
              IF (l_dr_flag) THEN
                fnd_file.put_line(fnd_file.log,'DR Accrual: '||to_char( l_ae_line_rec.transaction_value * l_curr_rec.currency_conv_rate ));
              ELSE
                fnd_file.put_line(fnd_file.log,'CR Accrual: '||to_char( l_ae_line_rec.transaction_value *  l_curr_rec.currency_conv_rate ));
              END IF;
            END IF;
            CSTPAPPR.insert_account (i_ae_txn_rec,
                                     l_curr_rec,
                                     l_dr_flag,
                                     l_ae_line_rec,
                                     l_ae_line_tbl,
                                     l_err_rec);
            IF (l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null)
            THEN
              raise process_error;
            END IF;


            -- Take care of rounding errors.
            -- -----------------------------
            l_stmt_num := 80;
            balance_account (l_ae_line_tbl,
                             l_err_rec);

            -- check error
            if (l_err_rec.l_err_num <> 0) then
                raise process_error;
            end if;

            -- encumbrance
            l_stmt_num := 110;

            -- If the budget account was not specified at PO creation
            -- no encumbrance reversal is necessary

            IF (c_receipts_rec.encumbrance_account_id = -1) THEN
              IF l_debug_flag = 'Y' THEN
                fnd_file.put_line(fnd_file.log,'No Encumbrance account at PO level');
              END IF;
            ELSE

            CSTPAPPR.check_encumbrance(
            i_transaction_id => i_ae_txn_rec.transaction_id,
            i_set_of_books_id => i_ae_txn_rec.set_of_books_id,
            i_period_name => i_ae_txn_rec.accounting_period_name,
            i_encumbrance_account_id => c_receipts_rec.encumbrance_account_id,
            o_enc_flag => l_enc_flag,
            o_purch_encumbrance_type_id => l_purch_encumbrance_type_id,
            o_purch_encumbrance_flag => l_purch_encumbrance_flag,
            o_ae_err_rec => l_err_rec);
            if (l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null)
              then
              raise process_error;
            end if;

            /* Commented and replaced for forward port bug 5768550
            IF (l_enc_flag = 'Y' and l_purch_encumbrance_flag = 'Y') then*/
            IF l_purch_encumbrance_flag = 'Y' THEN

              l_ae_line_rec.transaction_value := l_encum_qty * c_receipts_rec.unit_price;
              l_curr_rec.currency_conv_rate := c_receipts_rec.po_rate;
              l_curr_rec.currency_conv_date := c_receipts_rec.po_date;

              l_dr_flag := FALSE;

              l_ae_line_rec.account := c_receipts_rec.encumbrance_account_id;
              l_ae_line_rec.ae_line_type := 15;
              l_ae_line_rec.actual_flag := 'E';
              l_ae_line_rec.encum_type_id := l_purch_encumbrance_type_id;

              IF l_debug_flag = 'Y' THEN
                IF (l_dr_flag) THEN
                  fnd_file.put_line(fnd_file.log,'DR Encumbrance: '||to_char( l_ae_line_rec.transaction_value * l_curr_rec.currency_conv_rate ));
                ELSE
                  fnd_file.put_line(fnd_file.log,'CR Encumbrance: '||to_char( l_ae_line_rec.transaction_value *  l_curr_rec.currency_conv_rate ));
                END IF;
              END IF;
              CSTPAPPR.insert_account (i_ae_txn_rec,
                                      l_curr_rec,
                                      l_dr_flag,
                                      l_ae_line_rec,
                                      l_ae_line_tbl,
                                      l_err_rec);
             IF (l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null)
             THEN
               raise process_error;
             END IF;
            END IF; /*if enc on*/
            END IF; /*if budget acct specified */
        END LOOP;
    EXCEPTION
      when process_error then
      o_ae_err_rec.l_err_num := l_err_rec.l_err_num;
      o_ae_err_rec.l_err_code := l_err_rec.l_err_code;
      o_ae_err_rec.l_err_msg := l_err_rec.l_err_msg;

    END;


    -- Return the lines pl/sql table.
    -- ------------------------------
    l_stmt_num := 90;
    o_ae_line_rec_tbl := l_ae_line_tbl;
    IF l_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'Create_Per_End_Ae_Lines >>>');
    END IF;

EXCEPTION

  when process_error then
  o_ae_err_rec.l_err_num := l_err_rec.l_err_num;
  o_ae_err_rec.l_err_code := l_err_rec.l_err_code;
  o_ae_err_rec.l_err_msg := l_err_rec.l_err_msg;

  when cst_no_po_dist then
  o_ae_err_rec.l_err_num := l_err_rec.l_err_num;
  o_ae_err_rec.l_err_code := l_err_rec.l_err_code;
  FND_MESSAGE.set_name('BOM', 'CST_NO_RCV_LINE');
  o_ae_err_rec.l_err_msg := FND_MESSAGE.Get;

  when others then
  o_ae_err_rec.l_err_num := SQLCODE;
  o_ae_err_rec.l_err_code := '';
  o_ae_err_rec.l_err_msg := 'CSTPAPPR.create_per_end_ae_lines : ' || to_char(l_stmt_num) || ':'|| substr(SQLERRM,1,180);

END create_per_end_ae_lines;

PROCEDURE check_encumbrance(
  i_transaction_id      IN      NUMBER,
  i_set_of_books_id     IN      NUMBER,
  i_period_name         IN      VARCHAR2,   --???
  i_encumbrance_account_id      IN      NUMBER,
  o_enc_flag            OUT NOCOPY      VARCHAR2,
  o_purch_encumbrance_type_id   OUT NOCOPY      NUMBER,
  o_purch_encumbrance_flag OUT NOCOPY     VARCHAR2,
  o_ae_err_rec          OUT NOCOPY    CSTPALTY.cst_ae_err_rec_type
)
IS
  l_application_id             NUMBER;
  l_functional_currency_code   VARCHAR2(5);
  l_accrual_effect_date        DATE;
  l_accrual_cutoff_date        DATE;
  l_bud_enc_flag               VARCHAR2(1);
  l_stmt_num                   NUMBER;
  l_operating_unit             NUMBER;
  cst_no_enc_account           exception;

BEGIN
  IF l_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Check_Encumbrance <<<');
    fnd_file.put_line(fnd_file.log,'Encumbrance Account: '||to_char(i_encumbrance_account_id));
  END IF;

    l_stmt_num := 10;
    SELECT
    decode(status,'I',101,201)
    INTO
    l_application_id
    FROM
    fnd_product_installations
    WHERE
    application_id = 101;

    l_stmt_num := 20;


    SELECT
    NVL(org_id,-1)
    into
    l_operating_unit
    FROM
    po_headers_all
    WHERE
    po_header_id = (select po_header_id from rcv_transactions
        where transaction_id = i_transaction_id);


    l_stmt_num := 30;
    SELECT
    SOB.currency_code,
    nvl(FSP.purch_encumbrance_flag, 'N'),
    nvl(GET.encumbrance_type_id, 0)
    INTO
    l_functional_currency_code,
    o_purch_encumbrance_flag,
    o_purch_encumbrance_type_id
    FROM
    GL_PERIOD_STATUSES ACR,
    GL_PERIOD_TYPES GLPT,
    FINANCIALS_SYSTEM_PARAMS_ALL FSP,
    GL_ENCUMBRANCE_TYPES GET,
    GL_SETS_OF_BOOKS SOB
    WHERE
    GLPT.period_type = ACR.period_type AND
    ACR.application_id =  l_application_id AND
    ACR.set_of_books_id = i_set_of_books_id AND
    ACR.period_name = i_period_name AND
    FSP.set_of_books_id = SOB.set_of_books_id AND
    NVL(FSP.org_id,-1) = l_operating_unit AND
    GET.encumbrance_type_key = 'Obligation';

/*
Bug 5768550(FP of bug 5722537):- The following code is commented.
    l_stmt_num := 40;

    IF (o_purch_encumbrance_flag = 'Y') THEN
      -- Get profile CREATE_BUDGETARY_ENCUMBRANCES
      FND_PROFILE.get('CREATE_BUDGETARY_ENCUMBRANCES', l_bud_enc_flag);
      o_enc_flag := nvl(l_bud_enc_flag,'N');
    END IF;

    IF (o_enc_flag = 'Y' and o_purch_encumbrance_flag = 'Y' and i_encumbrance_account_id = -1) THEN
        raise cst_no_enc_account;
    END IF;
*/

  IF l_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Check_Encumbrance >>>');
  END IF;
EXCEPTION
WHEN CST_NO_ENC_ACCOUNT THEN
  o_ae_err_rec.l_err_num := 30010;
  o_ae_err_rec.l_err_code := 'CST_NO_ENC_ACCOUNT';
  FND_MESSAGE.set_name('BOM', 'CST_NO_ENC_ACCOUNT');
  o_ae_err_rec.l_err_msg := FND_MESSAGE.Get;

WHEN OTHERS THEN
  o_ae_err_rec.l_err_num := SQLCODE;
  o_ae_err_rec.l_err_code := '';
  o_ae_err_rec.l_err_msg := 'CSTPAPPR.check_encumbrance : ' || to_char(l_stmt_num) || ':'|| substr(SQLERRM,1,180);


END check_encumbrance;

-- ===================================================================
-- Insert Account.
-- ===================================================================
PROCEDURE insert_account(
  i_ae_txn_rec          IN      CSTPALTY.cst_ae_txn_rec_type,
  i_ae_curr_rec         IN      CSTPALTY.cst_ae_curr_rec_type,
  i_dr_flag             IN      BOOLEAN,
  i_ae_line_rec         IN      CSTPALTY.cst_ae_line_rec_type,
  l_ae_line_tbl         IN OUT NOCOPY  CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec          OUT NOCOPY      CSTPALTY.cst_ae_err_rec_type)
IS
  l_err_rec                     CSTPALTY.cst_ae_err_rec_type;
  l_entered_value               NUMBER;
  l_accounted_value             NUMBER;
  l_stmt_num                    NUMBER;
  next_record_avail             NUMBER;
  invalid_acct_error            EXCEPTION;

BEGIN

  IF l_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Insert_Account <<< ');
  END IF;
-- Initialize variables.
-- ---------------------
  l_err_rec.l_err_num := 0;
  l_err_rec.l_err_code := '';
  l_err_rec.l_err_msg := '';

  if (i_ae_line_rec.account = -1) then
    raise invalid_acct_error;
  end if;

  l_stmt_num := 10;
  next_record_avail := nvl(l_ae_line_tbl.LAST,0) ;
  l_ae_line_tbl.extend;
  next_record_avail := nvl(l_ae_line_tbl.LAST,0) ;
  l_ae_line_tbl(next_record_avail).ae_line_type :=
     i_ae_line_rec.ae_line_type;

  l_stmt_num := 20;

  select meaning
  into l_ae_line_tbl(next_record_avail).description
  from mfg_lookups
  where lookup_type = 'CST_ACCOUNTING_LINE_TYPE'
  and   lookup_code = l_ae_line_tbl(next_record_avail).ae_line_type;

  l_ae_line_tbl(next_record_avail).account := i_ae_line_rec.account;

  l_stmt_num := 30;

  IF l_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Alt Currency : '||i_ae_curr_rec.alt_currency);
    fnd_file.put_line(fnd_file.log,'Pri Currency : '||i_ae_curr_rec.pri_currency);
    fnd_file.put_line(fnd_file.log,'Currency Rate: '||to_char(i_ae_curr_rec.currency_conv_rate));
  END IF;

  select
  nvl(i_ae_curr_rec.alt_currency,i_ae_curr_rec.pri_currency)
  into l_ae_line_tbl(next_record_avail).currency_code
  from dual;

  l_stmt_num := 40;
  select
  decode(i_ae_curr_rec.alt_currency,
           i_ae_curr_rec.pri_currency,NULL,
         i_ae_curr_rec.currency_conv_date)
  into l_ae_line_tbl(next_record_avail).currency_conv_date
  from dual;

  l_stmt_num := 50;
  select
  decode(i_ae_curr_rec.alt_currency,
  i_ae_curr_rec.pri_currency,1,
  decode(i_ae_curr_rec.currency_conv_rate,-1,1,i_ae_curr_rec.currency_conv_rate))
  into l_ae_line_tbl(next_record_avail).currency_conv_rate
  from dual;

  l_stmt_num := 60;
  select
  decode(i_ae_curr_rec.alt_currency,
         i_ae_curr_rec.pri_currency,NULL,
         i_ae_curr_rec.currency_conv_type)
  into l_ae_line_tbl(next_record_avail).currency_conv_type
  from dual;


  l_stmt_num := 70;

  -- For Adjust Events, the accounted and entered values are computed by the calling routine,
  -- Create_Adj_Ae_Lines

  IF (i_ae_txn_rec.txn_type_flag = 'ADJ') THEN
    l_entered_value   := i_ae_line_rec.entered_value;
    l_accounted_value := i_ae_line_rec.accounted_value;

  ELSE
    select decode(i_ae_curr_rec.alt_currency,NULL, NULL,
                  i_ae_curr_rec.pri_currency, NULL,
                  decode(c2.minimum_accountable_unit,
                         NULL,
                         round(i_ae_line_rec.transaction_value, c2.precision),
                         round(i_ae_line_rec.transaction_value /c2.minimum_accountable_unit)
                        * c2.minimum_accountable_unit )),
           decode(c1.minimum_accountable_unit,
                  NULL, round(i_ae_line_rec.transaction_value * i_ae_curr_rec.currency_conv_rate, c1.precision),
                  round(i_ae_line_rec.transaction_value * i_ae_curr_rec.currency_conv_rate/c1.minimum_accountable_unit)
                  * c1.minimum_accountable_unit )
    into
        l_entered_value,
        l_accounted_value
    from
        fnd_currencies c1,
        fnd_currencies c2
    where
        c1.currency_code = i_ae_curr_rec.pri_currency
        and c2.currency_code = decode(i_ae_curr_rec.alt_currency, NULL,
                                                                  i_ae_curr_rec.pri_currency,
                                                                  i_ae_curr_rec.alt_currency);

  END IF;

  IF l_debug_flag = 'Y' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Accounted_Value: '||to_char(l_accounted_value));
  END IF;

  -- ERV does not have an entered amount.
  if (l_ae_line_tbl(next_record_avail).ae_line_type = 18) then
    l_entered_value := 0;
  end if;

/* 9166177: FP of Bug 9155316
In case of retroprice adjustment in order to have minimum accountign accounting impact
we follow TUMB rule that "Dr Retroprice account and CR accrual account".Hence
there is possiblity that Accounted Dr can have -ive value.As a result while creating
adjustmentent entries for Retroprice  abs values should not be inserted.
*/
  IF (i_ae_txn_rec.txn_type_flag = 'ADJ') THEN

  if (i_dr_flag) then
      l_ae_line_tbl(next_record_avail).entered_dr        := nvl(l_entered_value,l_accounted_value);
      l_ae_line_tbl(next_record_avail).entered_cr      := NULL;
      l_ae_line_tbl(next_record_avail).accounted_dr      := l_accounted_value;
      l_ae_line_tbl(next_record_avail).accounted_cr    := NULL;
  else
      l_ae_line_tbl(next_record_avail).entered_cr        := nvl(l_entered_value,l_accounted_value);
      l_ae_line_tbl(next_record_avail).entered_dr      := NULL;
      l_ae_line_tbl(next_record_avail).accounted_cr      := l_accounted_value;
      l_ae_line_tbl(next_record_avail).accounted_dr    := NULL;
  end if;

  ELSE

  if (i_dr_flag) then
      l_ae_line_tbl(next_record_avail).entered_dr        := nvl(abs(l_entered_value),abs(l_accounted_value));
      l_ae_line_tbl(next_record_avail).entered_cr      := NULL;
      l_ae_line_tbl(next_record_avail).accounted_dr      := abs(l_accounted_value);
      l_ae_line_tbl(next_record_avail).accounted_cr    := NULL;
  else
      l_ae_line_tbl(next_record_avail).entered_cr        := nvl(abs(l_entered_value),abs(l_accounted_value));
      l_ae_line_tbl(next_record_avail).entered_dr      := NULL;
      l_ae_line_tbl(next_record_avail).accounted_cr      := abs(l_accounted_value);
      l_ae_line_tbl(next_record_avail).accounted_dr    := NULL;
  end if;

  END IF;
 /*9166177 :Changes for bug 9155316 ends */

  l_ae_line_tbl(next_record_avail).source_table  := i_ae_txn_rec.source_table;
  l_ae_line_tbl(next_record_avail).source_id := i_ae_txn_rec.transaction_id;

  /* Bug 2686598. Rate_or_amount now calculated in calling function */
  l_ae_line_tbl(next_record_avail).rate_or_amount := i_ae_line_rec.rate_or_amount;

  l_ae_line_tbl(next_record_avail).basis_type    := to_number(null);
  l_ae_line_tbl(next_record_avail).resource_id   :=  null;
  l_ae_line_tbl(next_record_avail).cost_element_id :=  null;
  l_ae_line_tbl(next_record_avail).activity_id   := NULL;
  l_ae_line_tbl(next_record_avail).repetitive_schedule_id := NULL;
  l_ae_line_tbl(next_record_avail).overhead_basis_factor         := NULL;
  l_ae_line_tbl(next_record_avail).basis_resource_id := NULL;
  l_ae_line_tbl(next_record_avail).actual_flag := i_ae_line_rec.actual_flag;
  l_ae_line_tbl(next_record_avail).encum_type_id := i_ae_line_rec.encum_type_id;
  l_ae_line_tbl(next_record_avail).po_distribution_id := i_ae_line_rec.po_distribution_id;

  l_ae_line_tbl(next_record_avail).reference1 := NULL;
  l_ae_line_tbl(next_record_avail).reference2 := i_ae_txn_rec.organization_id;
  l_ae_line_tbl(next_record_avail).reference3 := i_ae_txn_rec.transaction_id;
  l_ae_line_tbl(next_record_avail).reference4 := NULL;
  l_ae_line_tbl(next_record_avail).reference5 := NULL;
  l_ae_line_tbl(next_record_avail).reference6 := NULL;
  l_ae_line_tbl(next_record_avail).reference7 := NULL;
  l_ae_line_tbl(next_record_avail).reference8 := NULL;
  l_ae_line_tbl(next_record_avail).reference9 := NULL;
  l_ae_line_tbl(next_record_avail).reference10 := NULL;

  IF l_debug_flag = 'Y' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'No. of Records: '||to_char(l_ae_line_tbl.COUNT));
    fnd_file.put_line(fnd_file.log,'Insert_Account >>> ');
  END IF;

  EXCEPTION

  when invalid_acct_error then
  o_ae_err_rec.l_err_num := 9999;
  o_ae_err_rec.l_err_code := 'CST_NO_TXN_INVALID_ACCOUNT';
  FND_MESSAGE.set_name('BOM', 'CST_NO_TXN_INVALID_ACCOUNT');
  o_ae_err_rec.l_err_msg := FND_MESSAGE.Get;

  when others then
  o_ae_err_rec.l_err_num := SQLCODE;
  o_ae_err_rec.l_err_code := '';
  o_ae_err_rec.l_err_msg := 'CSTPAPPR.insert_account' || to_char(l_stmt_num) ||
  substr(SQLERRM,1,180);

end insert_account;

FUNCTION get_net_del_qty(
        i_po_distribution_id    IN      NUMBER,
        i_transaction_id        IN      NUMBER)
RETURN NUMBER
IS
        ----------------------------------------------------
        -- Get all child transactions level by level
        -----------------------------------------------------
        CURSOR c_nqd is
        SELECT
        rt4.transaction_id,
        rt4.transaction_type,
-- J Changes -------------------------------------------------------------
-- Bug 3588765 --
--        DECODE(POL.ORDER_TYPE_LOOKUP_CODE,
--                   'RATE', rt4.AMOUNT,
--                   'FIXED PRICE', rt4.AMOUNT,
--                   RT4.PRIMARY_QUANTITY) "PRIMARY_QUANTITY",
-- End of Bug 3588765
----------------------------------------------------------------------------
        rt4.parent_transaction_id
        FROM
        rcv_transactions rt4
-- J Changes -------------------------------------------------------------
-- Bug 3588765 --
--        PO_LINES_ALL POL
-- End of Bug 3588765
--------------------------------------------------------------------------
        WHERE
        rt4.transaction_id < i_transaction_id
-- J Changes -------------------------------------------------------------
-- Bug 3588765 --
        AND   EXISTS (SELECT 1 FROM PO_LINES_ALL POL WHERE RT4.PO_LINE_ID= POL.PO_LINE_ID)
--        AND   RT4.PO_LINE_ID        = POL.PO_LINE_ID
-- End of Bug 3588765
--------------------------------------------------------------------------
        START WITH
        rt4.po_distribution_id      = i_po_distribution_id
        and transaction_type        = 'DELIVER'
        CONNECT BY
        prior rt4.transaction_id = rt4.parent_transaction_id
        AND  rt4.po_line_location_id = PRIOR rt4.po_line_location_id; -- Change for the bug 4968702

        l_nqd          NUMBER := 0;
        l_parent_type   rcv_transactions.transaction_type%TYPE;
        l_stmt_num      NUMBER := 0;
-- Bug 3588765 --
        l_primary_quantity NUMBER := 0;
-- End of Bug 3588765
BEGIN
        ---------------------------------------------------------
        -- Initialize error variable
        ---------------------------------------------------------
        ---------------------------------------------------------
        -- For each child transaction loop
        --------------------------------------------------------
        FOR c_nqd_rec in c_nqd loop

-- Bug 3588765 -----------------------------
          l_stmt_num := 20;
          SELECT DECODE(POLL1.MATCHING_BASIS,  -- Changed for Complex work procurement
                            'AMOUNT', rt6.AMOUNT,
                            'QUANTITY', RT6.PRIMARY_QUANTITY) "PRIMARY_QUANTITY"
          INTO l_primary_quantity
          FROM rcv_transactions rt6,
               PO_LINE_LOCATIONS_ALL POLL1  -- Changed for Complex work procurement
          WHERE rt6.transaction_id=c_nqd_rec.transaction_id
          AND RT6.PO_LINE_LOCATION_ID= POLL1.LINE_LOCATION_ID; -- Changed for Complex work procurement
-- End of Bug 3588765 ----------------------

        --------------------------------------------------------
        -- If it is not the parent (that was passed in) transaction itself
        --------------------------------------------------------
          IF c_nqd_rec.transaction_type <> 'DELIVER' THEN
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
            rt5.transaction_id = c_nqd_rec.parent_transaction_id;
          END IF;
        ------------------------------------------------------------
        -- If it is the parent receive or match transaction
        -- then add the quantity to l_nqd
        ------------------------------------------------------------
          IF c_nqd_rec.transaction_type = 'DELIVER' THEN
            l_nqd := l_nqd + l_primary_quantity;
        -----------------------------------------------------------
        -- If the transaction is CORRECT,
        -- If parent is receive or match txn, then add the corrected qty
        -- If parent is return, then subtract the corrected qty
        -----------------------------------------------------------
          ELSIF c_nqd_rec.transaction_type = 'CORRECT' then
            IF l_parent_type = 'DELIVER' then
              l_nqd := l_nqd + l_primary_quantity;
            ELSIF l_parent_type = 'RETURN TO RECEIVING' then
              l_nqd := l_nqd - l_primary_quantity;
            END IF;
        ----------------------------------------------------------
        -- If transaction is return transaction, then subtract returned qty
        ----------------------------------------------------------
          ELSIF c_nqd_rec.transaction_type = 'RETURN TO RECEIVING' then
            l_nqd := l_nqd - l_primary_quantity;
          END IF;

        END LOOP; -- child txns loop
        --------------------------------------------------------
        -- Return the net quantity received as calculated
        --------------------------------------------------------
        RETURN (l_nqd);
EXCEPTION
        WHEN OTHERS THEN
        RETURN(NULL);
END get_net_del_qty;




-- ===================================================================
-- Balance Account.
-- ===================================================================
procedure balance_account (
   l_ae_line_tbl               IN OUT NOCOPY    CSTPALTY.cst_ae_line_tbl_type,
   o_ae_err_rec                OUT NOCOPY       CSTPALTY.cst_ae_err_rec_type)
IS
  l_ent_value                   NUMBER := 0;
  l_acc_value                   NUMBER := 0;
  l_last_rec                    NUMBER;
  l_stmt_num                    NUMBER;
  l_ipv_line_flag               NUMBER := 0;  /*to find out if there is ipv line */
BEGIN
  IF l_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Balance_Account <<<');
  END IF;
  if (l_ae_line_tbl.exists(1)) then
     l_stmt_num := 10;
     For i in l_ae_line_tbl.FIRST .. l_ae_line_tbl.LAST loop
       IF (l_ae_line_tbl(i).actual_flag = 'E') THEN
         null;
       else
         if (l_ae_line_tbl(i).ae_line_type = 17) then
            l_ipv_line_flag := 1;   /* indicates that ipv line does exist */
         end if;
         l_ent_value := l_ent_value + nvl(l_ae_line_tbl(i).entered_dr,0) - nvl(l_ae_line_tbl(i).entered_cr,0);
         l_acc_value := l_acc_value + nvl(l_ae_line_tbl(i).accounted_dr,0) - nvl(l_ae_line_tbl(i).accounted_cr,0);
       END IF;
     end loop;

     if (l_ent_value = 0 and l_acc_value = 0) then
        return;
     end if;

     l_stmt_num := 20;
     l_last_rec := l_ae_line_tbl.LAST;


     -- Any rounding errors should be balanced out and put to the IPV account
     -- Bug 930582 workaround : any discrepancies with regard to accrual not including tax
     --    should be put into ipv.

     while true
     loop
        if (l_ae_line_tbl(l_last_rec).actual_flag = 'E') OR
           (l_ipv_line_flag = 1 and l_ae_line_tbl(l_last_rec).ae_line_type <> 17) then
          l_last_rec := l_last_rec - 1;
        else
          exit;
        end if;
     end loop;


     if l_ae_line_tbl(l_last_rec).accounted_dr is not NULL then
       IF l_debug_flag = 'Y' THEN
         fnd_file.put_line(fnd_file.log,'Balancing Dr: '||to_char(l_ae_line_tbl(l_last_rec).entered_dr));
       END IF;
       l_ae_line_tbl(l_last_rec).accounted_dr :=
        l_ae_line_tbl(l_last_rec).accounted_dr - l_acc_value;
       l_ae_line_tbl(l_last_rec).entered_dr :=
        l_ae_line_tbl(l_last_rec).entered_dr - l_ent_value;
     elsif l_ae_line_tbl(l_last_rec).accounted_cr is not NULL then
       IF l_debug_flag = 'Y' THEN
         fnd_file.put_line(fnd_file.log,'Balancing Cr: '||to_char(l_ae_line_tbl(l_last_rec).entered_cr));
       END IF;
       l_ae_line_tbl(l_last_rec).accounted_cr :=
        l_ae_line_tbl(l_last_rec).accounted_cr + l_acc_value;
       l_ae_line_tbl(l_last_rec).entered_cr :=
        l_ae_line_tbl(l_last_rec).entered_cr + l_ent_value;
     end if;

  end if;
  IF l_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Balance_Account >>>');
  END IF;

EXCEPTION

  when others then
  o_ae_err_rec.l_err_num := SQLCODE;
  o_ae_err_rec.l_err_code := '';
  o_ae_err_rec.l_err_msg := 'CSTPAPPR.balance_account' || to_char(l_stmt_num) ||
  substr(SQLERRM,1,180);

END balance_account;

end CSTPAPPR;

/
