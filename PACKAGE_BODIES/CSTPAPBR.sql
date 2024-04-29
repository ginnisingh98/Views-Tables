--------------------------------------------------------
--  DDL for Package Body CSTPAPBR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPAPBR" AS
/* $Header: CSTAPBRB.pls 120.48.12010000.9 2010/03/18 01:20:03 hyu ship $ */

g_debug_flag VARCHAR2(1) := NVL(fnd_profile.value('MRP_DEBUG'), 'N'); /* Bug 4586534 */

/*============================================================================+
| This procedure is called by the Accounting Package for the Accounting Lib.  |
| It first gets the details of the transaction from either                    |
| MTL_MATERIAL_TRANSACTIONS or WIP_TRANSACTIONS depending on the type of txn  |
| that is being processed. The appropriate procedure is then called to create |
| the accounting entry lines in the form of a PL/SQL table.                   |
|============================================================================*/

PROCEDURE create_acct_lines (
        i_legal_entity          IN      NUMBER,
        i_cost_type_id          IN      NUMBER,
        i_cost_group_id         IN      NUMBER,
        i_period_id             IN      NUMBER,
        i_transaction_id        IN      NUMBER,
        i_event_type_id         IN      VARCHAR2,
        i_txn_type_flag         IN      VARCHAR2, --Bug 4586534
        o_err_num                OUT NOCOPY        NUMBER,
        o_err_code                OUT NOCOPY        VARCHAR2,
        o_err_msg                OUT NOCOPY        VARCHAR2
)IS
        l_ae_txn_rec            CSTPALTY.CST_AE_TXN_REC_TYPE;
        l_ae_line_rec_tbl       CSTPALTY.CST_AE_LINE_TBL_TYPE := CSTPALTY.CST_AE_LINE_TBL_TYPE();
        l_ae_err_rec            CSTPALTY.CST_AE_ERR_REC_TYPE;
        l_cost_type_name        VARCHAR2(10);
        l_cost_group_name        VARCHAR2(10);
        l_period_name                VARCHAR2(15);
        l_operating_unit        NUMBER;
        l_txn_cost_group_id     NUMBER;
        l_xfer_cg_exists        NUMBER;
        l_stmt_num                NUMBER;
        CST_TXN_TYPE_FAIL        EXCEPTION;
        CST_DIST_PKG_ERROR        EXCEPTION;
BEGIN

  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log, 'CSTPAPBR.Create_acct_lines <<');
    fnd_file.put_line(fnd_file.log, 'i_transaction_id: ' || i_transaction_id);
  END IF;

  l_stmt_num := 10;
  o_err_num := 0;

  ------------------------------------------------------------------------------
  -- Determine the transaction type based on the event type
  -- the event type is a concatenated string of the form
  -- <txn type id>-<txn action id>-<txn source type id> for INV
  -- <txn type id>                                      for WIP
  -----------------------------------------------------------------------------

    /* Bug 4586534 */
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
  -----------------------------------------------------------------------------
  -- Get the set of books id
  -----------------------------------------------------------------------------

  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Event type: '||(i_event_type_id));
  END IF;

  l_stmt_num := 15;
  SELECT
  set_of_books_id
  INTO
  l_ae_txn_rec.set_of_books_id
  FROM
  cst_le_cost_types clct
  WHERE
  clct.legal_entity = i_legal_entity AND
  clct.cost_type_id = i_cost_type_id;

  ----------------------------------------------------------------------------
  -- If the txn type is INV, then get transaction data from MMT
  -- If WIP, then get transaction data from WT
  ----------------------------------------------------------------------------

  IF (l_ae_txn_rec.txn_type_flag = 'INV') THEN

    l_ae_txn_rec.source_table := 'MMT';
    l_ae_txn_rec.source_id := i_transaction_id;

    l_stmt_num := 20;

    SELECT
    i_event_type_id,
    mmt.transaction_action_id,
    mmt.transaction_source_type_id,
    nvl(mmt.transaction_source_id,-1),
    mmt.transaction_type_id,
    null,
    mmt.transaction_id,
    mmt.inventory_item_id,
    i_legal_entity,
    i_cost_type_id,
    i_cost_group_id,
    nvl(mmt.periodic_primary_quantity,mmt.primary_quantity),
    mmt.subinventory_code,
    mmt.transfer_organization_id,
    mmt.transfer_subinventory,
    mmt.transfer_transaction_id,
    nvl(mmt.distribution_account_id,-1),
    mmt.currency_code,
    mmt.currency_conversion_type,
    nvl(mmt.currency_conversion_date,transaction_date),
    nvl(mmt.currency_conversion_rate,-1),
    'MTL',
    i_period_id,
    mmt.transaction_date,
    mmt.organization_id,
    nvl(mmt.material_account, -1),
    nvl(mmt.material_overhead_account, -1),
    nvl(mmt.resource_account, -1),
    nvl(mmt.outside_processing_account, -1),
    nvl(mmt.overhead_account, -1),
    decode(mmt.flow_schedule,'Y',1,0),
    decode(msi.inventory_asset_flag,'Y',0,1),
    mmt.repetitive_line_id,
    nvl(mmt.encumbrance_account, -1),
    nvl(mmt.encumbrance_amount, 0),
    -- Reveue / COGS Matching
    nvl(mmt.so_issue_account_type,0),
    mmt.trx_source_line_id,
    mmt.cogs_recognition_percent,
    nvl(mmt.expense_account_id,-1)
    INTO
    l_ae_txn_rec.event_type_id,
    l_ae_txn_rec.txn_action_id,
    l_ae_txn_rec.txn_src_type_id,
    l_ae_txn_rec.txn_src_id,
    l_ae_txn_rec.txn_type_id,
    --l_ae_txn_rec.wip_txn_type,
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
    l_ae_txn_rec.encum_account,
    l_ae_txn_rec.encum_amount,
    -- Revenue / COGS Matching
    l_ae_txn_rec.so_issue_acct_type,
    l_ae_txn_rec.om_line_id,
    l_ae_txn_rec.cogs_percentage,
    l_ae_txn_rec.expense_account_id
    FROM
    mtl_material_transactions mmt,
    mtl_system_items msi
    WHERE
    mmt.inventory_item_id = msi.inventory_item_id AND
    mmt.organization_id = msi.organization_id AND
    mmt.transaction_id = i_transaction_id;

    l_stmt_num := 25;
    select
    transaction_type_name
    into
    l_ae_txn_rec.description
    from
    mtl_transaction_types
    where transaction_type_id = l_ae_txn_rec.txn_type_id;

    IF (NVL(l_ae_txn_rec.txn_src_id,-1) > 0 AND
                           l_ae_txn_rec.txn_src_type_id = 5) THEN
      l_stmt_num := 27;
      SELECT  entity_type
      INTO    l_ae_txn_rec.wip_entity_type
      FROM    wip_entities we
      WHERE   we.wip_entity_id = l_ae_txn_rec.txn_src_id;

    ELSE

      l_ae_txn_rec.wip_entity_type := NULL;

    END IF;

    IF (l_ae_txn_rec.txn_src_type_id in (1,7,8) ) THEN

/* The following Select statement has already been commented out.
   The Select statement will still however be made to refer to the
   CST_ORGANIZATION_DEFINITIONS as an impact of the HR-PROFILE option */


/* this new SELECT query below has been comented out because the above query had
  been commented out.The only change being this new query refers to
  cst_organization_definitions.In the future if this above query needs to be
  uncommented,please DO NOT uncomment the above query.Instead uncomment
  this below query*/

     l_stmt_num := 28;
     IF (l_ae_txn_rec.txn_src_type_id = 1) THEN

       SELECT NVL(operating_unit,-1)
       INTO l_operating_unit
       FROM cst_organization_definitions
       WHERE organization_id = l_ae_txn_rec.organization_id;

     ELSIF (l_ae_txn_rec.txn_src_type_id IN (7,8)) THEN /* Internal req/internal order */

       /* Get cost group of the transaction org */
       BEGIN
           SELECT NVL(cost_group_id, -1)
           INTO   l_txn_cost_group_id
           FROM   cst_cost_group_assignments
           WHERE  organization_id = l_ae_txn_rec.organization_id;
       EXCEPTION
           WHEN no_data_found THEN
             l_txn_cost_group_id := -1;
       END;

       /* Select the operating unit of the org belonging to the processing cost group */
       SELECT NVL(operating_unit,-1)
       INTO l_operating_unit
       FROM cst_organization_definitions
       WHERE organization_id = decode(i_cost_group_id,
                                         l_txn_cost_group_id, l_ae_txn_rec.organization_id,
                                                                         l_ae_txn_rec.xfer_organization_id);
         END IF;

     IF g_debug_flag = 'Y' THEN
       fnd_file.put_line(fnd_file.log,'Operating Unit: '||to_char(l_operating_unit));
     END IF;

       l_stmt_num := 29;
       SELECT decode(l_ae_txn_rec.txn_src_type_id,
                     1,g1.ENCUMBRANCE_TYPE_ID,
                     g2.ENCUMBRANCE_TYPE_ID)
       INTO   l_ae_txn_rec.encum_type_id
       FROM   gl_encumbrance_types g1, gl_encumbrance_types g2
       WHERE  g1.encumbrance_type_key = 'Obligation' AND
              g2.encumbrance_type_key = 'Commitment';

    END IF;


  ELSIF (l_ae_txn_rec.txn_type_flag = 'WIP') THEN

    l_ae_txn_rec.source_table := 'WT';
    l_ae_txn_rec.source_id := i_transaction_id;

    l_stmt_num := 30;
    select
    i_event_type_id,
    null,
    null,
    wt.wip_entity_id,
    --null,  moved to after transaction_type to populate transaction_type
    wt.transaction_type,  -- assign to transaction_type_id
    null,
    wt.transaction_id,
    wt.primary_item_id,
    i_legal_entity,
    i_cost_type_id,
    i_cost_group_id,
    null,
    wt.primary_quantity,
    null,
    null,
    null,
    null,
    null,
    wt.currency_code,
    wt.currency_conversion_type,
    nvl(wt.currency_conversion_date,transaction_date),
    nvl(wt.currency_conversion_rate,-1),
    'WIP',
    i_period_id,
    wt.transaction_date,
    wt.organization_id,
    null,
    null,
    null,
    null,
    null,
    0,
    wt.line_id,
 /* added decode on wt.primary_item_id for non-std jobs - fix 3179823 */
    DECODE(transaction_type,6,0, decode(wt.primary_item_id,NULL,-1,1))
--{BUG#9356654
, ENCUMBRANCE_TYPE_ID
, ENCUMBRANCE_CCID
, ENCUMBRANCE_AMOUNT
--}
    INTO
    l_ae_txn_rec.event_type_id,
    l_ae_txn_rec.txn_action_id,
    l_ae_txn_rec.txn_src_type_id,
    l_ae_txn_rec.txn_src_id,
    l_ae_txn_rec.txn_type_id,
    --l_ae_txn_rec.wip_txn_type,
    l_ae_txn_rec.txn_type,
    l_ae_txn_rec.transaction_id,
    l_ae_txn_rec.inventory_item_id,
    l_ae_txn_rec.legal_entity_id,
    l_ae_txn_rec.cost_type_id,
    l_ae_txn_rec.cost_group_id      ,
    l_ae_txn_rec.xfer_cost_group_id,
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
    l_ae_txn_rec.line_id,
    l_ae_txn_rec.exp_item
--{BUG#9356654
,    l_ae_txn_rec.encum_type_id
,    l_ae_txn_rec.encum_account
,    l_ae_txn_rec.encum_amount
--}
    FROM
    wip_transactions wt
    WHERE
    wt.transaction_id = i_transaction_id;

    SELECT  entity_type
    INTO    l_ae_txn_rec.wip_entity_type
    FROM    wip_entities we
    WHERE   we.wip_entity_id = l_ae_txn_rec.txn_src_id;

    if (l_ae_txn_rec.exp_item = 1) then
    select
    decode(msi.inventory_asset_flag,'Y',0,1)
    INTO
    l_ae_txn_rec.exp_item
    FROM
    mtl_system_items msi,
    wip_transactions wt
    WHERE
    msi.inventory_item_id = wt.primary_item_id AND
    wt.organization_id = msi.organization_id AND
    wt.transaction_id = i_transaction_id;
    end if;

    select
    meaning
    into
    l_ae_txn_rec.description
    from
    mfg_lookups
    where
    lookup_type = 'WIP_TRANSACTION_TYPE'
    and lookup_code = l_ae_txn_rec.txn_type_id;
    --and lookup_code = l_ae_txn_rec.wip_txn_type;




  ELSE
    RAISE CST_TXN_TYPE_FAIL;
  END IF;

  SELECT
  cost_type
  INTO
  l_cost_type_name
  FROM
  cst_cost_types
  WHERE
  cost_type_id = i_cost_type_id;

  SELECT
  cost_group
  INTO
  l_cost_group_name
  FROM
  cst_cost_groups
  WHERE
  cost_group_id = i_cost_group_id;

  SELECT
  period_name
  INTO
  l_period_name
  FROM
  cst_pac_periods
  WHERE
  pac_period_id = i_period_id;

  l_ae_txn_rec.description := l_ae_txn_rec.description ||' : '||l_cost_type_name||' : '||l_cost_group_name||' : '||l_period_name;


  l_stmt_num := 40;


  -----------------------------------------------------------------------------
  -- Get the transfer organization and cost group (if any)
  -----------------------------------------------------------------------------
  SELECT
  count(organization_id)
  INTO
  l_xfer_cg_exists
  FROM
  cst_cost_group_assignments
  WHERE
  organization_id = nvl(l_ae_txn_rec.xfer_organization_id,-1)
  AND rownum < 2; /* bug 4586534 added rownum=1 for performance as its only existence check. */

  IF (l_xfer_cg_exists = 0) THEN
    l_ae_txn_rec.xfer_cost_group_id := NULL;
  ELSE
    SELECT
    DECODE (l_ae_txn_rec.xfer_organization_id,NULL,NULL,cost_group_id)
    INTO
    l_ae_txn_rec.xfer_cost_group_id
    FROM
    cst_cost_group_assignments
    WHERE
    organization_id = nvl(l_ae_txn_rec.xfer_organization_id,organization_id);
  END IF;

  -----------------------------------------------------------------------------
  -- Get the period name for the period being processed
  -----------------------------------------------------------------------------

  l_stmt_num := 50;
  SELECT
  period_name
  INTO
  l_ae_txn_rec.accounting_period_name
  FROM
  cst_pac_periods
  WHERE
  pac_period_id = l_ae_txn_rec.accounting_period_id AND
  cost_type_id = l_ae_txn_rec.cost_type_id AND
  legal_entity = l_ae_txn_rec.legal_entity_id;

  l_stmt_num := 60;
  -----------------------------------------------------------------------------
  -- Get the category for the item for the org
  -- This will be used later to determine the category accounts from MFCA
  -----------------------------------------------------------------------------

  IF ((l_ae_txn_rec.txn_type_id = 6 and l_ae_txn_rec.txn_type_flag = 'WIP')
       or (l_ae_txn_rec.inventory_item_id is NULL and l_ae_txn_rec.txn_type_flag = 'WIP')) THEN
    -- For Non Standard Jobs, the Assembly Item ID may be NULL
    ----------------------------------------------------------------
    -- For job close transactions, there is no item, set category to NULL
    ----------------------------------------------------------------

    l_ae_txn_rec.category_id := NULL;

  ELSE

    /* Added as bugfix 2045870:
       modified the check on functional_area_id from 1(inventory) to 5 (costing) */
    SELECT
    category_id
    INTO
    l_ae_txn_rec.category_id
    FROM
    mtl_item_categories mic
    WHERE
    mic.inventory_item_id = l_ae_txn_rec.inventory_item_id
    AND
    mic.organization_id = l_ae_txn_rec.organization_id
    AND
    mic.category_set_id = (SELECT category_set_id
                           FROM mtl_default_category_sets
                           WHERE functional_area_id = 5);

  END IF;


  l_stmt_num := 80;

  -----------------------------------------------------------------------------
  -- Call the INV procedure if txn type is INV
  -- Call the WIP procedure if txn type is WIP
  -----------------------------------------------------------------------------

  IF (l_ae_txn_rec.txn_type_flag = 'INV') THEN
     create_inv_ae_lines(
        l_ae_txn_rec,
        l_ae_line_rec_tbl,
        l_ae_err_rec);
  ELSIF (l_ae_txn_rec.txn_type_flag = 'WIP') THEN
     create_wip_ae_lines(
        l_ae_txn_rec,
        l_ae_line_rec_tbl,
        l_ae_err_rec);
  END IF;

  IF (l_ae_err_rec.l_err_num <> 0 and l_ae_err_rec.l_err_num is not null) THEN
    RAISE CST_DIST_PKG_ERROR;
  END IF;


  -----------------------------------------------------------------------------
  -- If accounting entry lines were returned by the procedure , insert into the
  -- accounting tables
  -----------------------------------------------------------------------------

  IF (l_ae_err_rec.l_err_num IS NULL OR l_ae_err_rec.l_err_num = 0) THEN
    IF (l_ae_line_rec_tbl.EXISTS(1)) THEN
    CSTPALBR.insert_ae_lines(
        l_ae_txn_rec,
        l_ae_line_rec_tbl,
        l_ae_err_rec);
    END IF;
  END IF;

  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log, 'Create_acct_lines >>');
  END IF;


EXCEPTION
WHEN CST_DIST_PKG_ERROR THEN
        o_err_num := 30001;
        o_err_code := SQLCODE;
        o_err_msg :=  to_char(l_ae_err_rec.l_err_num)||l_ae_err_rec.l_err_msg;

WHEN CST_TXN_TYPE_FAIL THEN
        o_err_num := 30002;
        o_err_code := SQLCODE;
        o_err_msg :=  'CSTPAPBR.create_acct_lines :Invalid Transaction Type Code';

WHEN OTHERS THEN
  o_err_num := SQLCODE;
  o_err_code := '';
  o_err_msg := 'CSTPAPBR.create_acct_lines : ' || to_char(l_stmt_num) || ':'||
  substr(SQLERRM,1,180);


END create_acct_lines;

/*============================================================================+
| This procedure processes the transaction data and creates accounting entry  |
| lines in the form of PL/SQL table and returns to the main procedure.        |
|============================================================================*/

PROCEDURE create_inv_ae_lines(
  i_ae_txn_rec          IN     CSTPALTY.cst_ae_txn_rec_type,
  o_ae_line_rec_tbl     OUT NOCOPY    CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec          OUT NOCOPY    CSTPALTY.cst_ae_err_rec_type
) IS
  l_ae_line_tbl                CSTPALTY.cst_ae_line_tbl_type := CSTPALTY.cst_ae_line_tbl_type();
  l_curr_rec                   CSTPALTY.cst_ae_curr_rec_type;
  l_err_rec                    CSTPALTY.cst_ae_err_rec_type;
  l_ae_txn_rec1                CSTPALTY.CST_AE_TXN_REC_TYPE;

  /* Drop Ship/Global Proc changes */
  l_logical_transaction   NUMBER;

  l_curr_from_org         NUMBER;
  l_curr_to_org           NUMBER;

  l_txn_cost_group_id     NUMBER;
  l_fob_point             NUMBER;
  l_enc_rev                    NUMBER;
  l_hook                       NUMBER;
  l_stmt_num                   NUMBER := 0;

  -- FP 12.1.1 bug 7346244 fix
  l_enc_amount                 NUMBER;
  l_enc_account                NUMBER;

  process_error                EXCEPTION;

  l_api_name   CONSTANT VARCHAR2(30)    := 'CSTPAPBR.create_inv_ae_lines';

BEGIN

  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ': begin <<'
                           || ' transaction_id: ' || i_ae_txn_rec.transaction_id);
  END IF;

  l_ae_line_tbl := CSTPALTY.cst_ae_line_tbl_type();
--l_ae_line_tbl := CSTPALBR.cst_ae_line_tbl_type();

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

  /* Changes for INVCONV Bug 5337465 */
  IF (i_ae_txn_rec.txn_action_id in (3,12,21,15,22)) THEN /* Direct and Intransit Transfers */
        l_stmt_num := 11;

        IF (i_ae_txn_rec.txn_action_id IN (12,21,15,22)) THEN -- INVCONV

          BEGIN
            SELECT NVL(cost_group_id, -1)
            INTO   l_txn_cost_group_id
            FROM   cst_cost_group_assignments
            WHERE  organization_id = i_ae_txn_rec.organization_id;
          EXCEPTION
            WHEN no_data_found THEN
              l_txn_cost_group_id := -1;
          END;

          IF (i_ae_txn_rec.txn_action_id in (12,15)) THEN -- INVCONV

            l_stmt_num := 12;
            SELECT nvl(mmt.fob_point,mip.fob_point)
            INTO l_fob_point
            FROM mtl_material_transactions mmt,mtl_interorg_parameters mip
            WHERE mmt.transaction_id = i_ae_txn_rec.transaction_id
            AND   mip.from_organization_id = i_ae_txn_rec.xfer_organization_id
            AND   mip.to_organization_id = i_ae_txn_rec.organization_id;

           END IF;

        END IF;

        /* Currency conversion is only required during an ownership change. */
        IF ( (i_ae_txn_rec.txn_action_id = 3 AND i_ae_txn_rec.primary_quantity > 0) /* direct rcpt processed by rcv CG */
              OR (i_ae_txn_rec.txn_action_id = 21 AND i_ae_txn_rec.cost_group_id <> l_txn_cost_group_id) /*intransit ship, FOB ship, processed by rcv CG */
              OR (i_ae_txn_rec.txn_action_id = 12 AND i_ae_txn_rec.cost_group_id = l_txn_cost_group_id AND l_fob_point = 2) /*intransit rcpt, FOB rcpt, processed by rcv CG */
              OR (i_ae_txn_rec.txn_action_id = 15 AND l_fob_point = 1) /* Logical intransit rcpt, FOB shpmt, INVCONV */
           ) THEN
              l_stmt_num := 13;

              SELECT currency_code
              INTO   l_curr_rec.alt_currency -- currency of the sending org
              FROM   cst_organization_definitions
              WHERE  organization_id = decode(i_ae_txn_rec.txn_action_id,
                                                21, i_ae_txn_rec.organization_id,
                                                i_ae_txn_rec.xfer_organization_id);

              l_curr_rec.currency_conv_date := i_ae_txn_rec.currency_conv_date;
              l_curr_rec.currency_conv_type := i_ae_txn_rec.currency_conv_type;

              l_stmt_num := 14;
              /* Get_Snd_Rcv_Rate returns the GL Daily Rate for the transaction date.
                 This should usually be the same as i_ae_txn_rec.currency_conv_rate,
                 which stores MMT.currency_conversion_rate.  However, in the corner
                 case that the daily rate is different (ex. if user changes the GL
                 daily rate after the transaction), we use the GL Daily Rate
                 (always from the sending org currency to the receiving org currency) */
             IF (i_ae_txn_rec.txn_action_id = 21 AND i_ae_txn_rec.cost_group_id <> l_txn_cost_group_id) THEN
               l_curr_from_org := i_ae_txn_rec.organization_id;
               l_curr_to_org := i_ae_txn_rec.xfer_organization_id;
             ELSE
               l_curr_from_org := i_ae_txn_rec.xfer_organization_id;
               l_curr_to_org := i_ae_txn_rec.organization_id;
             END IF;
             CSTPPINV.Get_Snd_Rcv_Rate( i_ae_txn_rec.transaction_id,
                                         l_curr_from_org,
                                         l_curr_to_org,
                                         l_curr_rec.currency_conv_rate,
                                         l_err_rec.l_err_num,
                                         l_err_rec.l_err_code,
                                         l_err_rec.l_err_msg);

              IF (l_err_rec.l_err_num <> 0) THEN
                raise process_error;
              END IF;

        ELSE
              l_stmt_num := 15;
           /* no ownership change */
              l_curr_rec.alt_currency := NULL;
              l_curr_rec.currency_conv_date := NULL;
              l_curr_rec.currency_conv_type := NULL;
              l_curr_rec.currency_conv_rate := NULL;
        END IF;
  ELSE   /* non-interorg transactions */
    l_stmt_num := 16;
    l_curr_rec.alt_currency := i_ae_txn_rec.currency_code;
    l_curr_rec.currency_conv_date := i_ae_txn_rec.currency_conv_date;
    l_curr_rec.currency_conv_type := i_ae_txn_rec.currency_conv_type;
    l_curr_rec.currency_conv_rate := i_ae_txn_rec.currency_conv_rate;
  END IF;

  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num ||
                                    ': l_curr_rec.pri_currency = ' || l_curr_rec.pri_currency ||
                                    '; l_curr_rec.alt_currency = ' || l_curr_rec.alt_currency);
  END IF;

  if (l_curr_rec.alt_currency is not NULL and l_curr_rec.currency_conv_rate = -1) then
    if (l_curr_rec.alt_currency <> l_curr_rec.pri_currency) then
      if (l_curr_rec.currency_conv_type is NULL) then
        FND_PROFILE.get('CURRENCY_CONVERSION_TYPE', l_curr_rec.currency_conv_type);
      end if;
      l_stmt_num := 16;
      l_curr_rec.currency_conv_rate := gl_currency_api.get_rate(i_ae_txn_rec.set_of_books_id,
                                                                l_curr_rec.alt_currency,
                                                                i_ae_txn_rec.accounting_date,
                                                                l_curr_rec.currency_conv_type);
    end if;
  end if;

  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num ||
                        ': l_curr_rec.currency_conv_rate = ' || l_curr_rec.currency_conv_rate);
  END IF;

  /* Determine if a logical transaction
   It is assumed that a parent physical transaction is never passed to this
   procedure */

  select nvl(logical_transaction, 2)
  into l_logical_transaction
  from mtl_material_transactions
  where transaction_id = i_ae_txn_rec.transaction_id;

-- Calling procedures, depending on transaction_source_type_id and transaction_action_id.
-- --------------------------------------------------------------------------------------
  /*******************************************************************
   **   break down the inventory transactions into 5 categories:    **
   ** 1) WIP Cost transactions                                      **
   ** 2) subinventory transfers                                                     **
   ** 3) interorg transfers                                                             **
   ** 4) Periodic cost update                                                       **
   ** 5) rest of inventory transactions                                         **
   ** 6) Logical Accounting Events                                  **
   ** 7) Consigned Price Update                                     **
   *******************************************************************/
  if (i_ae_txn_rec.txn_src_type_id = 5 and i_ae_txn_rec.txn_action_id <> 2) then

-- WIP transaction
-- These always occur in base currency, so set alt currency as null.
-- -----------------------------------------------------------------
     l_curr_rec.alt_currency := NULL;
     l_curr_rec.currency_conv_date := NULL;
     l_curr_rec.currency_conv_type := NULL;
     l_curr_rec.currency_conv_rate := NULL;

     l_stmt_num := 20;
     CSTPAPBR.wip_cost_txn (i_ae_txn_rec,
                           l_curr_rec,
                           l_ae_line_tbl,
                           l_err_rec);
     -- check error;
     if(l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
        raise process_error;
     end if;
  /* Changes for VMI. Adding Planning Transfer transaction */
  elsif (i_ae_txn_rec.txn_action_id in (2,5,28)) then

-- Subinventory transfer.
-- ----------------------
     l_stmt_num := 30;
     CSTPAPBR.sub_cost_txn (i_ae_txn_rec,
                           l_curr_rec,
                           l_ae_line_tbl,
                           l_err_rec);
     -- check error;
     if(l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
        raise process_error;
     end if;
  elsif (i_ae_txn_rec.txn_action_id in (3,12,21,15,22)) then -- INVCONV sikhanna

-- Interorg transfers.
-- -------------------
     l_stmt_num := 40;
     CSTPAPBR.interorg_cost_txn (i_ae_txn_rec,
                                l_curr_rec,
                                l_ae_line_tbl,
                                l_err_rec);
     -- check error;
     if(l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
        raise process_error;
     end if;
  elsif (i_ae_txn_rec.txn_action_id = 24 and i_ae_txn_rec.txn_src_type_id = 14) then

-- Cost Update.
-- ------------
     l_stmt_num := 50;
     CSTPAPBR.pcu_cost_txn (i_ae_txn_rec,
                            l_curr_rec,
                            l_ae_line_tbl,
                            l_err_rec);
     -- check error;
     if(l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
        raise process_error;
     end if;

  --Call the logical procedure if a logical transaction
  elsif (l_logical_transaction = 1 and i_ae_txn_rec.txn_action_id <> 17) then -- Bug 5485387

    l_stmt_num := 55;
    CSTPAPBR.cost_logical_txn (i_ae_txn_rec,
                           l_curr_rec,
                           l_ae_line_tbl,
                           l_err_rec);
     if(l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
        raise process_error;
     end if;

  --For consigned price update transaction
  elsif (i_ae_txn_rec.txn_action_id = 25 and i_ae_txn_rec.txn_src_type_id = 1) then
    l_stmt_num := 57;
    CSTPAPBR.cost_consigned_update_txn(i_ae_txn_rec,
                           l_curr_rec,
                           l_ae_line_tbl,
                           l_err_rec);
     if(l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
        raise process_error;
     end if;

  -- For Internal Order Issue and Logical Expense Requisition Bug 5485387
  elsif ((i_ae_txn_rec.txn_action_id = 1 and i_ae_txn_rec.txn_src_type_id = 8)
          OR i_ae_txn_rec.txn_action_id = 17) then

     l_stmt_num := 58;

     CSTPAPBR.cost_internal_order_exp_txn(i_ae_txn_rec,
                                          l_curr_rec,
                                          l_ae_line_tbl,
                                          l_err_rec);

      if(l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
         raise process_error;
      end if;

  else

-- Rest of inventory transactions.
-- -------------------------------
     l_stmt_num := 60;
     CSTPAPBR.inv_cost_txn (i_ae_txn_rec,
                           l_curr_rec,
                           l_ae_line_tbl,
                           l_err_rec);
     -- check error;
     if(l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
        raise process_error;
     end if;
  end if;

-- Take care of rounding errors.
-- -----------------------------
  l_stmt_num := 70;
  balance_account (l_ae_line_tbl,
                   l_err_rec);

  -- check error
  if(l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
      raise process_error;
  end if;

/********************************************************************************
FP 12.1.1 bug 7346244 fix:
 Changes for Encumbrance accounting for Logical Expense receipt
    - Excluded the Internal order issue transaction from the following
      and added another piece of code for handling that.
 if (i_ae_txn_rec.txn_src_type_id in (1,7,8))  then
 ********************************************************************************/

   select
   encumbrance_reversal_flag
   into
   l_enc_rev
   from
   mtl_parameters
   where organization_id = i_ae_txn_rec.organization_id;

  IF g_debug_flag = 'Y' THEN
   fnd_file.put_line(fnd_file.log,'Organization_id : '||(i_ae_txn_rec.organization_id));
   fnd_file.put_line(fnd_file.log,'l_enc_rev : '||(l_enc_rev));
   fnd_file.put_line(fnd_file.log,'transaction_id : '||(i_ae_txn_rec.transaction_id));
   fnd_file.put_line(fnd_file.log,'txn_action_id : '||(i_ae_txn_rec.txn_action_id));
  END IF;

 if ((i_ae_txn_rec.txn_src_type_id = 1) OR (i_ae_txn_rec.txn_src_type_id in (7,8) AND i_ae_txn_rec.txn_action_id NOT IN (1,17) ))  then

   if (l_enc_rev = 1 and i_ae_txn_rec.encum_amount <> 0) THEN
      encumbrance_account
                         (i_ae_txn_rec,
                          l_curr_rec,
                          l_ae_line_tbl,
                          l_err_rec);
     -- check error;
     if(l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
        raise process_error;
     end if;

   end if;
 end if;

-- FP 12.1.1 bug 7346244 fix
if (l_enc_rev = 1 AND i_ae_txn_rec.txn_action_id = 17) then

  IF g_debug_flag = 'Y' THEN
   fnd_file.put_line(fnd_file.log,'CompEncumbrance_IntOrdersExp << : ');
  END IF;

    CompEncumbrance_IntOrdersExp (
      p_api_version         => 1.0,
      p_transaction_id      => i_ae_txn_rec.transaction_id,
      x_encumbrance_amount  => l_enc_amount,
      x_encumbrance_account => l_enc_account,
      o_ae_err_rec          => l_err_rec);

     if(l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
        raise process_error;
     end if;

      l_ae_txn_rec1:=i_ae_txn_rec;
      l_ae_txn_rec1.encum_amount      :=l_enc_amount;
      l_ae_txn_rec1.encum_account     :=l_enc_account;

  IF g_debug_flag = 'Y' THEN
   fnd_file.put_line(fnd_file.log,'encum_amount << : '||l_ae_txn_rec1.encum_amount);
   fnd_file.put_line(fnd_file.log,'encum_account << : '||l_ae_txn_rec1.encum_account);
  END IF;

   if (l_enc_rev = 1 and l_ae_txn_rec1.encum_amount <> 0) THEN

      encumbrance_account
                         (l_ae_txn_rec1,
                          l_curr_rec,
                          l_ae_line_tbl,
                          l_err_rec);
   end if;

End if; /* End CompEncumbrance_IntOrdersExp IF */


-- Return the lines pl/sql table.
-- ------------------------------
  l_stmt_num := 80;
  o_ae_line_rec_tbl := l_ae_line_tbl;

  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ': return >>');
  END IF;

EXCEPTION

  when process_error then
  o_ae_err_rec.l_err_num := l_err_rec.l_err_num;
  o_ae_err_rec.l_err_code := l_err_rec.l_err_code;
  o_ae_err_rec.l_err_msg := l_err_rec.l_err_msg;

  when others then
  o_ae_err_rec.l_err_num := SQLCODE;
  o_ae_err_rec.l_err_code := '';
  o_ae_err_rec.l_err_msg := 'CSTPAPBR.create_inv_ae_lines : ' || to_char(l_stmt_num) || ':'||
  substr(SQLERRM,1,180);

END create_inv_ae_lines;

-- ===================================================================
-- WIP transactions.
-- ===================================================================
procedure wip_cost_txn(
  i_ae_txn_rec                IN        CSTPALTY.cst_ae_txn_rec_type,
  i_ae_curr_rec               IN        CSTPALTY.cst_ae_curr_rec_type,
  l_ae_line_tbl               IN OUT NOCOPY    CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec                OUT NOCOPY        CSTPALTY.cst_ae_err_rec_type
  --i_ae_txn_rec                IN              CSTPALBR.cst_ae_txn_rec_type,
  --i_ae_curr_rec               IN              CSTPALBR.cst_ae_curr_rec_type,
  --l_ae_line_tbl               IN OUT    CSTPALBR.cst_ae_line_tbl_type,
  --o_ae_err_rec                OUT             CSTPALBR.cst_ae_err_rec_type
) IS
  l_exp_sub                             NUMBER;
  l_exp_acct                            NUMBER;
  l_exp_job                             NUMBER;
  l_ovhd_absp                           NUMBER;
  l_mat_ovhd_exists                     NUMBER;
  l_rep_sched_id                        NUMBER;
  l_cost                                NUMBER;
  l_err_rec                             CSTPALTY.cst_ae_err_rec_type;
  l_acct_rec                            CSTPALTY.cst_ae_acct_rec_type;
  --l_err_rec                           CSTPALBR.cst_ae_err_rec_type;
  --l_acct_rec                          CSTPALBR.cst_ae_acct_rec_type;
  l_acct_class                          VARCHAR2(10);
  l_acct_line_type                      NUMBER;
  l_elemental                           NUMBER;
  l_dr_flag                             BOOLEAN;
  l_exp_flag                            BOOLEAN;
  l_stmt_num                            NUMBER;
  process_error                         EXCEPTION;

BEGIN

  IF g_debug_flag ='Y' THEN
    fnd_file.put_line(fnd_file.log, 'Wip_cost_txn <<');
  END IF;
-- Initialize variables.
-- ---------------------
  l_err_rec.l_err_num := 0;
  l_err_rec.l_err_code := '';
  l_err_rec.l_err_msg := '';
  l_ovhd_absp := 0;
  l_mat_ovhd_exists := '';

-- There are no cost distributions for expense items.
-- --------------------------------------------------
  if (i_ae_txn_rec.exp_item = 1) then
    IF g_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'No accounting for Expense item');
    END IF;
    return;
  end if;


-- Figure out accts, expense subinventory and expense job flags.
-- -------------------------------------------------------------

      -- repetitive schedules

      IF (i_ae_txn_rec.wip_entity_type = 2) THEN
        IF g_debug_flag = 'Y' THEN
          fnd_file.put_line(fnd_file.log, 'Repetitive Schedule: ');
        END IF;

        l_stmt_num := 10;

        SELECT MAX(wrs.repetitive_schedule_id)
        INTO   l_rep_sched_id
        FROM   wip_repetitive_schedules wrs
        WHERE  wrs.line_id = i_ae_txn_rec.line_id;

        l_stmt_num := 15;

        SELECT material_account,
               material_overhead_account,
               resource_account,
               overhead_account,
               outside_processing_account
        INTO   l_acct_rec.mat_account,
               l_acct_rec.mat_ovhd_account,
               l_acct_rec.res_account,
           l_acct_rec.ovhd_account,
               l_acct_rec.osp_account
        FROM   wip_repetitive_schedules wrs
        WHERE  wrs.repetitive_schedule_id = l_rep_sched_id;

        SELECT
        class_code
        INTO
        l_acct_class
        FROM
        wip_repetitive_items wri
        WHERE
        wri.wip_entity_id = i_ae_txn_rec.txn_src_id AND
        wri.line_id = i_ae_txn_rec.line_id AND
        wri.organization_id = i_ae_txn_rec.organization_id;

      -- flow schedules
      ELSIF (i_ae_txn_rec.wip_entity_type = 4) THEN
        IF g_debug_flag = 'Y' THEN
          fnd_file.put_line(fnd_file.log,'Flow Schedule: ');
        END IF;

        SELECT
        material_account,
        material_overhead_account,
        resource_account,
        outside_processing_account,
        overhead_account,
        class_code
        INTO
        l_acct_rec.mat_account,
        l_acct_rec.mat_ovhd_account,
        l_acct_rec.res_account,
        l_acct_rec.osp_account,
        l_acct_rec.ovhd_account,
        l_acct_class
        FROM wip_flow_schedules
        WHERE organization_id = i_ae_txn_rec.organization_id
        AND wip_entity_id = i_ae_txn_rec.txn_src_id;
      ELSE
        -- discrete jobs
        IF g_debug_flag = 'Y' THEN
          fnd_file.put_line(fnd_file.log,'Discrete Job: ');
        END IF;
        l_stmt_num := 17;
        select
        material_account,
        material_overhead_account,
        resource_account,
        outside_processing_account,
        overhead_account,
        class_code
        into
        l_acct_rec.mat_account,
        l_acct_rec.mat_ovhd_account,
        l_acct_rec.res_account,
        l_acct_rec.osp_account,
        l_acct_rec.ovhd_account,
        l_acct_class
        from wip_discrete_jobs
        where organization_id = i_ae_txn_rec.organization_id
        and wip_entity_id = i_ae_txn_rec.txn_src_id;
      END IF;

  l_stmt_num := 20;

  select decode(class_type, 4,1,0)
  into l_exp_job
  from wip_accounting_classes
  where class_code = l_acct_class
  and organization_id = i_ae_txn_rec.organization_id;

  l_stmt_num := 30;

-- Scrap transactions do not have inventory impact!!
-- -------------------------------------------------
  if (i_ae_txn_rec.txn_action_id <> 30) then
    IF g_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'Scrap txn: ');
    END IF;
    select decode(asset_inventory,1,0,1)
    into l_exp_sub
    from mtl_secondary_inventories
    where secondary_inventory_name = i_ae_txn_rec.subinventory_code
    and organization_id = i_ae_txn_rec.organization_id;

-- Transactions between expense subinventories and expense jobs are
-- not distributed.
-- ----------------------------------------------------------------
    if (l_exp_sub = 1 and l_exp_job = 1) then
      IF g_debug_flag = 'Y' THEN
        fnd_file.put_line(fnd_file.log,'No accounting for Expense Sub or Expense Job');
      END IF;
      return;
    end if;
    if (l_exp_sub = 1) then
       l_acct_rec.account := -1;
    end if;
  end if;

-- Debit/Credit WIP accounts.
-- --------------------------

-- Material overhead absorption happens for the assembly completion
-- and asembly return transactions.
-- ----------------------------------------------------------------

  if (i_ae_txn_rec.txn_action_id in (31,32)) then
    IF g_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'Assembly completion/return');
    END IF;
    l_stmt_num := 40;
    select count(transaction_id) /* Bug No. 4586534 */
    into l_mat_ovhd_exists
    from mtl_pac_actual_cost_details
    where transaction_id = i_ae_txn_rec.transaction_id
    and pac_period_id = i_ae_txn_rec.accounting_period_id
    and cost_group_id = i_ae_txn_rec.cost_group_id
    and cost_element_id = 2
    and level_type = 1;
    if (l_mat_ovhd_exists > 0) then
       l_ovhd_absp := 1;
    end if;
  end if;

  if (i_ae_txn_rec.txn_action_id in (31,27,33,1,34,32)) then
     if (i_ae_txn_rec.txn_action_id in (31,27,33)) then
       l_dr_flag := "TRUE"; -- debit
     else
       l_dr_flag := "FALSE"; -- credit
     end if;

     /* Bug 3293554: should use the expense account if it is non-asset subinventory */
     if (l_exp_sub = 1) then
        l_exp_flag := "TRUE";
     else
        l_exp_flag := "FALSE";
        l_acct_rec.account := '';
     end if;

     inventory_accounts(i_ae_txn_rec,
                       i_ae_curr_rec,
                       l_exp_flag,
                       l_acct_rec.account,
                       l_dr_flag,
                       l_ae_line_tbl,
                       l_err_rec);
     if (l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
       raise process_error;
     end if;

-- Toggle the Debit Flag.
-- ----------------------
     l_dr_flag := not l_dr_flag;

     l_acct_rec.account := '';

     l_acct_line_type := 7;
     l_elemental := 1;

     --------------------------------------------------------------------
     -- Call WIP_accounts procedure to Cr/Dr WIP valuation accounts
     -- In case of negative Job balance also Cr/dr WIP variance accounts
     --------------------------------------------------------------------
      WIP_accounts(i_ae_txn_rec,
                   i_ae_curr_rec,
                   l_acct_line_type,
                   l_ovhd_absp,
                   l_dr_flag,
                   l_acct_rec,
                   l_ae_line_tbl,
                   l_err_rec);

     if (l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
        raise process_error;
     end if;

     if (l_ovhd_absp = 1) then
       ovhd_accounts(i_ae_txn_rec,
                     i_ae_curr_rec,
                     l_dr_flag,
                     l_ae_line_tbl,
                     l_err_rec);
       if (l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
          raise process_error;
       end if;

     end if;
  elsif (i_ae_txn_rec.txn_action_id = 30) then

     -----------------------------------------------------------------------------
     -- For Assembly Scrap Credit the WIP Valuation => Set the l_dr_flag to FALSE
     -- For Assembly Scrap Return Debit WIP Valuation => Set the l_dr_flag to TRUE
     -----------------------------------------------------------------------------
     IF (i_ae_txn_rec.primary_quantity > 0 ) THEN
        l_dr_flag := "FALSE";
     ELSE
        l_dr_flag := "TRUE";
     END IF;

     l_acct_rec.account := '';
     l_acct_line_type := 7;
     l_elemental := 1;
     --------------------------------------------------------------------
     -- Call WIP_accounts procedure to Cr/Dr WIP valuation accounts
     -- In case of negative Job balance also Cr/dr WIP variance accounts
     --------------------------------------------------------------------
     WIP_accounts(i_ae_txn_rec,
                  i_ae_curr_rec,
                  l_acct_line_type,
                  l_ovhd_absp,
                  l_dr_flag,
                  l_acct_rec,
                  l_ae_line_tbl,
                  l_err_rec);

     if (l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
        raise process_error;
     end if;

-- Toggle the Debit Flag.
-- ----------------------
     l_dr_flag := not l_dr_flag;

     -- For Flow Schedules, If Scrap Account is not mentioned then use Variance Accounts
     IF (i_ae_txn_rec.wip_entity_type = 4) AND (i_ae_txn_rec.dist_acct_id = -1) THEN
        select material_variance_account,
               material_variance_account,
               resource_variance_account,
               outside_proc_variance_account,
               overhead_variance_account
          into l_acct_rec.mat_account,
               l_acct_rec.mat_ovhd_account,
               l_acct_rec.res_account,
               l_acct_rec.osp_account,
               l_acct_rec.ovhd_account
          from wip_flow_schedules
         where organization_id = i_ae_txn_rec.organization_id
           and wip_entity_id = i_ae_txn_rec.txn_src_id;
     ELSE
        l_acct_rec.mat_account := i_ae_txn_rec.dist_acct_id;
        l_acct_rec.mat_ovhd_account := i_ae_txn_rec.dist_acct_id;
        l_acct_rec.res_account := i_ae_txn_rec.dist_acct_id;
        l_acct_rec.osp_account := i_ae_txn_rec.dist_acct_id;
        l_acct_rec.ovhd_account := i_ae_txn_rec.dist_acct_id;
        l_acct_rec.account := i_ae_txn_rec.dist_acct_id;
     END IF;

     l_acct_line_type := 2;
     l_elemental := 1;

     offset_accounts(i_ae_txn_rec,
                     i_ae_curr_rec,
                     l_acct_line_type,
                     l_elemental,
                     l_ovhd_absp,
                     l_dr_flag,
                     l_acct_rec,
                     l_ae_line_tbl,
                     l_err_rec);
     if (l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
        raise process_error;
     end if;

  end if;
  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Wip_cost_txn >>');
  END IF;

 EXCEPTION

  when process_error then
  o_ae_err_rec.l_err_num := l_err_rec.l_err_num;
  o_ae_err_rec.l_err_code := l_err_rec.l_err_code;
  o_ae_err_rec.l_err_msg := l_err_rec.l_err_msg;

  when others then
  o_ae_err_rec.l_err_num := SQLCODE;
  o_ae_err_rec.l_err_code := '';
  o_ae_err_rec.l_err_msg := 'CSTPAPBR.wip_cost_txn' || to_char(l_stmt_num) ||
  substr(SQLERRM,1,180);

END wip_cost_txn;

-- ===================================================================
-- Subinventory transfer transactions.
-- ===================================================================
procedure sub_cost_txn(
  i_ae_txn_rec                IN        CSTPALTY.cst_ae_txn_rec_type,
  i_ae_curr_rec               IN        CSTPALTY.cst_ae_curr_rec_type,
  l_ae_line_tbl               IN OUT NOCOPY    CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec                OUT NOCOPY        CSTPALTY.cst_ae_err_rec_type
) IS
  l_subinv                                    VARCHAR2(10);
  l_exp_sub1                             NUMBER;
  l_exp_acct1                           NUMBER;
  l_exp_sub2                            NUMBER;
  l_exp_acct2                           NUMBER;
  l_exp_sub                                   NUMBER;
  l_exp_acct                            NUMBER;
  l_stmt_num                            NUMBER;
  process_error                         EXCEPTION;
  l_dr_flag                             BOOLEAN;
  l_exp_flag                            BOOLEAN;
  l_err_rec                             CSTPALTY.cst_ae_err_rec_type;
  l_acct_rec                            CSTPALTY.cst_ae_acct_rec_type;
BEGIN

  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Sub_cost_txn <<');
  END IF;

-- Initialize variables.
-- ---------------------
  l_err_rec.l_err_num := 0;
  l_err_rec.l_err_code := '';
  l_err_rec.l_err_msg := '';

-- There are no cost distributions for expense items.
-- --------------------------------------------------
  if (i_ae_txn_rec.exp_item = 1) then
    IF g_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'No accounting for Expense Item');
    END IF;
    return;
  end if;

-- Figure out expense subinventory for both from and to.
-- -----------------------------------------------------
  l_stmt_num := 10;

  select decode(asset_inventory,1,0,1)
  into l_exp_sub1
  from mtl_secondary_inventories
  where secondary_inventory_name = i_ae_txn_rec.subinventory_code
  and organization_id = i_ae_txn_rec.organization_id;

  l_stmt_num := 20;
  select decode(asset_inventory,1,0,1)
  into l_exp_sub2
  from mtl_secondary_inventories
  where secondary_inventory_name = i_ae_txn_rec.xfer_subinventory
  and organization_id = i_ae_txn_rec.organization_id;

-- If expense to expense transfer or asset to asset then no accounting entries.
-- ----------------------------------------------------------------------------
  if (l_exp_sub1 = 1 and l_exp_sub2 = 1) or
     (l_exp_sub1 = 0 and l_exp_sub2 = 0)
  then
    IF g_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'No accounting for Expense to Expense or Asset to Asset');
    END IF;
    return;
  end if;

-- Do distribution for both subs.
-- ------------------------------
  if (l_exp_sub1=1 or i_ae_txn_rec.exp_item = 1) then
     l_exp_flag := "TRUE";
     l_acct_rec.account := -1;
  else
     /* Bug 2517809: Reset l_exp_flag */
     l_exp_flag := "FALSE";
  end if;
  l_dr_flag := "FALSE";
  inventory_accounts(i_ae_txn_rec,
                     i_ae_curr_rec,
                     l_exp_flag,
                     l_acct_rec.account,
                     l_dr_flag,
                     l_ae_line_tbl,
                     l_err_rec);
  if (l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
    raise process_error;
  end if;

  if (l_exp_sub2=1 or i_ae_txn_rec.exp_item = 1) then
     l_exp_flag := "TRUE";
     l_acct_rec.account := -1;
  else
     /* Bug 2517809: Reset l_exp_flag */
     l_exp_flag := "FALSE";
  end if;
  l_dr_flag := "TRUE";
  inventory_accounts(i_ae_txn_rec,
                     i_ae_curr_rec,
                     l_exp_flag,
                     l_acct_rec.account,
                     l_dr_flag,
                     l_ae_line_tbl,
                     l_err_rec);
  if (l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
    raise process_error;
  end if;
  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Sub_cost_txn >>');
  END IF;

 EXCEPTION

  when process_error then
  o_ae_err_rec.l_err_num := l_err_rec.l_err_num;
  o_ae_err_rec.l_err_code := l_err_rec.l_err_code;
  o_ae_err_rec.l_err_msg := l_err_rec.l_err_msg;

  when others then
  o_ae_err_rec.l_err_num := SQLCODE;
  o_ae_err_rec.l_err_code := '';
  o_ae_err_rec.l_err_msg := 'CSTPAPBR.sub_cost_txn' || to_char(l_stmt_num) ||
  substr(SQLERRM,1,180);

END sub_cost_txn;


/* ===================================================================
   Procedure for Inter Org Transfer: interorg_cost_txn()
   ===================================================================
This procedure creates distributions for Interorg transactions.

Below is the algorithm followed for interorg txns across cost groups:
This also includes the changes made for OPM Inventory Convergence R12 Project.

|-IF (shipment txn) THEN
|   |- IF (Internal Order AND FOB-S AND Include Process-Discrete Internal Orders) THEN
|   |   |- IF (sending CG) THEN
|   |   |   |- Credit Inventory-OnHand at MPACD Cost
|   |   |   |- Debit COGS at MPACD Cost (PWAC Cost during shipment)
|   |   |- ELSE  (Receiving CG) -- For Process-Discrete Transfers, Profile=2 always
|   |   |   |- IF (CST:Transfer Price Option = Yes, Price As Incoming Cost;2) THEN
|   |   |   |   |- Credit Intercompany Accrual at MPACD Cost (Transfer Price)
|   |   |   |   |- Debit Inventory-Intransit at MPACD Cost (Transfer Price) THEN
|   |   |   |  ELSE (CST:Transfer Price Option = Yes, Price Not As Incoming Cost;1)
|   |   |   |   |- Credit Intercompany Accrual at MMT Transfer Price
|   |   |   |   |- Debit Inventory-Intransit at MPACD Cost (Estimated sending CG cost)
|   |   |   |  END IF;
|   |   |- END IF;
|   |- ELSIF (Internal Order AND FOB-R) THEN
|   |   |    This can only be the sending CG
|   |   |   |- Credit Inventory-OnHand at MPACD Cost(PWAC Cost during shipment)
|   |   |   |- Debit Inventory-Intransit at MPACD Cost
|   |- ELSE  (Ordinary Interorg Shipments)
|   |   |- IF (FOB-S AND sending CG) THEN
|   |   |   |- IF (Discrete-Discrete Org Transfer) THEN
|   |   |   |   |- Credit Inventory-OnHand at MPACD Cost (PWAC Cost during shipment)
|   |   |   |   |- Debit Receivables at (CPIC/Perpetual/Prior Period PWAC Cost)
|   |   |   |   |-  + Transfer Cost(If PACP is not used)
|   |   |   |- ELSE (this is Process Discrete Transfer)
|   |   |   |   |- Debit Receivables at Transfer Price
|   |   |   |   |- Credit Inventory at PWAC
|   |   |   |- END IF;
|   |   |- ELSIF (FOB-S AND receiving CG) THEN
|   |   |   |- Credit Payables at MPACD Cost
|   |   |   |- Debit Inventory-Intransit at MPACD Cost
|   |   |   |- Credit Freight Expense Account at transportation Cost
|   |   |- ELSIF (FOB-R) THEN (Can be only sending CG) THEN
|   |   |   |- Credit Inventory-OnHand at MPACD Cost(PWAC Cost during shipment)
|   |   |   |- Debit Inventory-Intransit at MPACD Cost
|   |   |- ELSIF (Direct Interorg) THEN
|   |   |   |- IF (Discrete-Discrete Transfers) THEN
|   |   |   |   |- Debit Receivables at (CPIC/Perpetual/Prior Period PWAC Cost +
|   |   |   |   |  transportation Cost + Transfer Cost)
|   |   |   |   |- Credit InterOrg Transfer Credit at Transfer Cost
|   |   |   |   |- Credit Freight Expense Account at transportation Cost
|   |   |   |   |- Credit Inventory at MPACD Cost (PWAC Cost during Shipment)
|   |   |   |   |- Debit/Credit Transfer Variance at ABS(Receivable's Cost - MPACD Cost)
|   |   |   |- ELSE (Process-Discrete Transfers)
|   |   |   |   |- Debit Receivables at Transfer Price
|   |   |   |   |- Credit Freight Expense Account at transportation Cost
|   |   |   |   |- Credit Inventory at MPACD Cost (PWAC Cost during Shipment)
|   |   |   |- END IF;
|   |   |- END IF;
|   |- END IF;
|- ELSE (Receipt Transactions AND Include Process-Discrete Internal Orders)
|   |- IF (Internal Order AND FOB-R) THEN
|   |   |- IF (sending CG) THEN
|   |   |   |- Credit Intransit at MPACD Cost (PWAC Cost during Receipt)
|   |   |   |- Debit COGS at MPACD Cost
|   |   |- ELSE (Receiving CG) -- For Process-Discrete Transfers, Profile=2 always
|   |   |   |- IF (CST:Transfer Price Option = Yes, Price As Incoming Cost;2) THEN
|   |   |   |   |- Credit Intercompany Accrual at MPACD Cost (Transfer Price)
|   |   |   |   |- Debit On-hand Inventory at PWAC Cost
|   |   |   |  ELSE (CST:Transfer Price Option = Yes, Price Not As Incoming Cost;1)
|   |   |   |   |- Credit Intercompany Accrual at MMT Transfer Price
|   |   |   |   |- Debit On-hand Inventory at PWAC Cost
|   |   |   |  END IF;
|   |   |- END IF;
|   |- ELSIF (Internal Order AND FOB-S) THEN
|   |   |   This can only be the receiving CG
|   |   |   |- Credit Inventory-Intransit at MPACD Cost
|   |   |   |- Debit Inventory-OnHand at MPACD Cost
|   |- ELSE  (Ordinary Interorg Receipts)
|   |   |- IF (FOB-R AND receiving CG) THEN
|   |   |   |- IF (Discrete-Discrete Transfer) THEN
|   |   |   |   |- Credit Payables at MPACD Cost
|   |   |   |   |- Debit Inventory at MPACD Cost
|   |   |   |- ELSE (Process-Discrete Transfers)
|   |   |   |   |- Credit Payables at transfer Price Cost
|   |   |   |   |- Debit Inventory at transfer Price Cost
|   |   |   |  END IF;
|   |   |- ELSIF (FOB-R AND sending CG) THEN
|   |   |   |- Debit Receivables at (CPIC/Perpetual/Prior Period PWAC Cost +
|   |   |   |  transportation Cost + Transfer Cost)
|   |   |   |- Credit Inventory-Intransit at MPACD Cost
|   |   |   |- Credit InterOrg Transfer Credit at Transfer Cost
|   |   |   |- Credit Freight Expense Account at transportation
|   |   |   |  Cost
|   |   |   |- Debit/Credit Transfer Variance at ABS(Receivable's Cost - MPACD
|   |   |   |  Cost)
|   |   |- ELSIF (FOB-S) THEN  (Can be only receiving CG)
|   |   |   |- IF (Discrete-Discrete Transfer) THEN
|   |   |   |   |- Credit Inventory-Intransit at MPACD Cost
|   |   |   |   |- Debit Inventory-OnHand at MPACD Cost
|   |   |   |  ELSE (Process-Discrete Transfer)
|   |   |   |   |- Credit Inventory-Intransit at Transfer price + Freight Cost
|   |   |   |   |- Debit Inventory-OnHand at Transfer price + Freight Cost
|   |   |   |  END IF;
|   |   |- ELSIF (Direct Interorg) THEN
|   |   |   |- Credit Payables at MPACD Cost
|   |   |   |- Debit Inventory-OnHand at MPACD Cost
|   |   |- END IF;
|   |- END IF;
|- END IF;
|- IF (Logical Receipt for OPM-Disc and not Internal Order)
|   |- Credit Interorg Payables at Transfer Price
|   |- Credit Freight at Freight cost
|   |- Debit Intransit-Inventory  at Transfer price + Freight Cost
|- ELSIF (Logical Shipment for OPM-Disc and not Internal Order)
|   |- Credit Intransit-Inventory at PWAC cost
|   |- Credit Freight at Freight cost
|   |- Debit InterOrg Receivables at Transfer Price
|- END IF;


For same cost group transfers, regardless of whether the transfer is
direct or intransit, we make a debit/credit to an offset account and
a debit/credit to inventory account (if asset sub) or expense account
(if expense sub).

   ===================================================================
   =================================================================== */

  procedure interorg_cost_txn(
    i_ae_txn_rec                IN              CSTPALTY.cst_ae_txn_rec_type,
    i_ae_curr_rec               IN              CSTPALTY.cst_ae_curr_rec_type,
    l_ae_line_tbl               IN OUT NOCOPY    CSTPALTY.cst_ae_line_tbl_type,
    o_ae_err_rec                OUT NOCOPY      CSTPALTY.cst_ae_err_rec_type
  ) IS
    l_exp_sub1                  NUMBER;
    l_exp_sub2                  NUMBER;
    l_exp_sub                   NUMBER;
    l_dr_flag                   BOOLEAN;
    l_acct_exist                NUMBER;
    l_stmt_num                  NUMBER := 0;
    l_acct_rec                  CSTPALTY.cst_ae_acct_rec_type;
    l_err_rec                   CSTPALTY.cst_ae_err_rec_type;
    l_txn_cost_group_id         NUMBER;
    l_txfr_txn_cost_group_id    NUMBER;

    process_error               EXCEPTION;
    no_cg_acct_error            EXCEPTION;
    l_exp_flg                   BOOLEAN ;
    l_exp_account               NUMBER;
    l_fob_point                 NUMBER;

    l_processing_cg_id      NUMBER;
    l_tprice_option         NUMBER;
    l_io_rcv_acct           NUMBER;
    l_io_freight_acct       NUMBER;
    l_io_pay_acct           NUMBER;
    l_io_txfr_cr_acct       NUMBER;
    l_io_txfr_var_acct      NUMBER;
    l_io_intransit_acct     NUMBER;
    l_transfer_cost_flag    VARCHAR2(1);
    l_txfr_legal_entity     NUMBER;
    l_txfr_cost_group_id    NUMBER;
    l_same_le_ct            NUMBER;
    l_pacp_pwac_cost        NUMBER;
    l_prev_period_id        NUMBER;
    l_prev_period_pwac_cost NUMBER;
    l_txfr_percent          NUMBER;
    l_txfr_credit           NUMBER;
    l_txfr_cost             NUMBER;
    l_trp_cost              NUMBER;
    l_io_rcv_value          NUMBER;
    l_io_pay_value          NUMBER;
    l_mpacd_cost            NUMBER;
    l_txfr_var_value        NUMBER;
    l_mat_ovhd              NUMBER;
    l_other_ele_costs       NUMBER;
    l_txfr_txn_id           NUMBER;
    l_shipping_cg_id        NUMBER;
    l_conv_rate             NUMBER;
    l_mat_account           NUMBER;
    l_mat_ovhd_account      NUMBER;
    l_cogs_account          NUMBER;
    l_accrual_account       NUMBER;

    l_profit_in_inv_account NUMBER;
    l_profit_in_inv_value   NUMBER;
    l_transfer_price        NUMBER;
    l_txfr_txn_qty          NUMBER;

    l_mat_ovhd_exists       NUMBER;
    l_mat_ovhd_cost         NUMBER;
    l_ovhd_absp             NUMBER;
    l_mptcd_cost            NUMBER;

    l_ae_line_rec       CSTPALTY.cst_ae_line_rec_type;

    -- INVCONV sikhanna, Variables added for OPM Convergence project
    l_pwac_cost            NUMBER;
    l_profit_or_loss       NUMBER;
    l_pe_flag              VARCHAR2(1);
    l_pd_txfr_ind          NUMBER := 0;
    no_mfca_acct_error     EXCEPTION;
    no_interorg_profit_acct_error EXCEPTION;
    no_profit_in_inv_acct_error EXCEPTION;

    l_perp_ship_value         NUMBER;
    l_use_prev_period_cost   NUMBER;
    l_cg_exp_item            NUMBER;
    l_api_name   CONSTANT VARCHAR2(30)          := 'CSTPAPBR.interorg_cost_txn';

  BEGIN

        IF g_debug_flag = 'Y' THEN
          fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ': begin <<'
                            || ' transaction_id: ' || i_ae_txn_rec.transaction_id);
        END IF;

        -- Initialize variables.
        -- ---------------------
        l_err_rec.l_err_num := 0;
        l_err_rec.l_err_code := '';
        l_err_rec.l_err_msg := '';

        l_exp_flg := FALSE;
        l_transfer_cost_flag := 'N';

        l_mat_ovhd_exists  := 0;
        l_mat_ovhd_cost    := 0;
        l_ovhd_absp        := 0;

        l_stmt_num := 10;

        IF i_ae_txn_rec.subinventory_code IS NULL THEN
            l_exp_sub1:=0; -- If subInv code is missing, as in case of Logical Intransit Receipt
                           -- Treat it as asset subInv
        ELSE
            SELECT decode(asset_inventory,1,0,1)
            INTO  l_exp_sub1
            FROM  mtl_secondary_inventories
            WHERE secondary_inventory_name = i_ae_txn_rec.subinventory_code
            AND   organization_id = i_ae_txn_rec.organization_id;
        END IF;

        l_stmt_num := 15;
        BEGIN
           SELECT nvl(expense_account, -1)
           INTO  l_exp_account
           FROM  mtl_fiscal_cat_accounts
           WHERE legal_entity_id = i_ae_txn_rec.legal_entity_id
           AND   cost_type_id    = i_ae_txn_rec.cost_type_id
           AND   cost_group_id   = i_ae_txn_rec.cost_group_id
           AND   category_id     = i_ae_txn_rec.category_id;
        EXCEPTION
           WHEN no_data_found THEN
             fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num ||
               ': Category : '||to_char(i_ae_txn_rec.category_id) ||' has no accounts defined');
             raise no_mfca_acct_error;
        END;

        l_stmt_num := 20;

        /* Get FOB Point */
        IF (i_ae_txn_rec.txn_action_id IN (12,21,15,22)) THEN -- INVCONV sikhanna
            SELECT nvl(mmt.fob_point,mip.fob_point)
            INTO l_fob_point
            FROM mtl_material_transactions mmt,mtl_interorg_parameters mip
            WHERE mmt.transaction_id = i_ae_txn_rec.transaction_id
            AND   mip.from_organization_id = decode(i_ae_txn_rec.txn_action_id,
                                                    21,i_ae_txn_rec.organization_id,
                                                    22,i_ae_txn_rec.organization_id, -- INVCONV sikhanna
                                                    i_ae_txn_rec.xfer_organization_id)
            AND   mip.to_organization_id = decode(i_ae_txn_rec.txn_action_id,
                                                  21,i_ae_txn_rec.xfer_organization_id,
                                                  22,i_ae_txn_rec.xfer_organization_id, -- INVCONV sikhanna
                                                  i_ae_txn_rec.organization_id);
        END IF;


        l_stmt_num := 22;

        /* To determine whether this is a same cost group transfer or
                         cross cost group transfer, we need to compare the transaction org
                         cost group with the transfer transaction org cost group */
        BEGIN
           SELECT NVL(cost_group_id, -1)
           INTO   l_txn_cost_group_id
           FROM   cst_cost_group_assignments
           WHERE  organization_id = i_ae_txn_rec.organization_id;
        EXCEPTION
           WHEN no_data_found THEN
             l_txn_cost_group_id := -1;
        END;

        l_txfr_txn_cost_group_id := NVL(i_ae_txn_rec.xfer_cost_group_id, -1);

        IF g_debug_flag = 'Y' THEN
            fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                              ': cost_group_id = ' || i_ae_txn_rec.cost_group_id ||
                              ': txn_cost_group_id ' || l_txn_cost_group_id ||
                              ': txfr_txn_cost_group_id ' || l_txfr_txn_cost_group_id);
        END IF;


        /* If the transaction org cost group = the transfer transaction org cost group,
                         the transfer is within the same cost group */

        IF (l_txn_cost_group_id = l_txfr_txn_cost_group_id) THEN /* Same Cost Group Transfer */

          IF g_debug_flag = 'Y' THEN
            fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ': Transfer Within Same Cost Group');
          END IF;

          /* Do not create accounting for same cost group transfers of expense items */
          IF i_ae_txn_rec.exp_item = 1 THEN
            l_stmt_num := 23;
            IF g_debug_flag = 'Y' THEN
              fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ': return >> ' ||
                '(No accounting for Expense item)');
            END IF;
            RETURN;
          END IF;

          -- Figure out asset and expense subinventory for both sending and receiving.
          -- -------------------------------------------------------------------------
          IF (i_ae_txn_rec.txn_action_id = 3) THEN

                 l_stmt_num := 25;

                 IF g_debug_flag = 'Y' THEN
                   fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ': Direct Transfer');
                 END IF;

                 SELECT decode(asset_inventory,1,0,1)
                 INTO l_exp_sub2
                 FROM mtl_secondary_inventories
                 WHERE secondary_inventory_name = i_ae_txn_rec.xfer_subinventory
                 AND organization_id = i_ae_txn_rec.xfer_organization_id;

                 IF (l_exp_sub1 = 0 AND l_exp_sub2 = 0) OR
                    (l_exp_sub1 = 1 AND l_exp_sub2 = 1)
                 THEN
                   IF g_debug_flag = 'Y' THEN
                   fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ': return >> '
                                                        || 'No accounting for Expense to Expense or Asset to Asset Subs');
                   END IF;
                   RETURN;
                 END IF;

                 IF (l_exp_sub1 = 0) THEN
                    l_dr_flag := TRUE;
                 ELSIF (l_exp_sub2 = 0) THEN
                    l_dr_flag := FALSE;
                 END IF;
          ELSE
                 l_stmt_num := 30;

                 IF g_debug_flag = 'Y' THEN
                   fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ': Intransit Transfer');
                 END IF;

                 IF (i_ae_txn_rec.txn_action_id = 21) THEN
                   l_dr_flag := TRUE;
                 ELSE
                   l_dr_flag := FALSE;
                 END IF;

                 IF (l_exp_sub1 = 1) THEN
                     l_exp_flg := TRUE;
                 END IF;

          END IF; /* end IF (i_ae_txn_rec.txn_action_id = 3)  */

          -- Create accounting for same cost group transfers
          ---------------------------------------------------
          l_stmt_num := 31;

          IF g_debug_flag = 'Y' THEN
            fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ': Create Accounting for same cost group transfer');
          END IF;

          -- In R12, the Inventory Offset Account field has been removed from
          -- the Periodic Account Assignments form, so cst_org_cost_group_accounts.
          -- inventory_offset_account will not be set up.  Instead, we will use the
          -- expense account from mtl_fiscal_cat_accounts as the offset account.

          l_acct_rec.account := l_exp_account;

          -- For same cost group transfers, regardless of whether the transfer is
          -- direct or intransit, we make a debit/credit to an offset account and
          -- a debit/credit to inventory account (if asset sub) or expense account
          -- (if expense sub).

          -- Call Offset Accounts
          ------------------------
          l_stmt_num := 32;
          CSTPAPBR.offset_accounts(i_ae_txn_rec,
                                   i_ae_curr_rec,
                                   2, -- Accounting Line Type
                                   0, -- Elemental Flag
                                   0, -- Overhead Flag
                                   l_dr_flag,
                                   l_acct_rec,
                                   l_ae_line_tbl,
                                   l_err_rec);

          -- Check error
          if (l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
            raise process_error;
          end if;

          -- Toggle the Debit Flag
          ------------------------
          l_dr_flag := not l_dr_flag;

          -- Call Inventory Accounts
          --------------------------
          l_stmt_num := 33;
          if (l_exp_flg) then
             CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                          i_ae_curr_rec,
                                          l_exp_flg, -- Exp Flag
                                          l_exp_account, -- Exp Acct
                                          l_dr_flag,
                                          l_ae_line_tbl,
                                          l_err_rec);
          else
             CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                          i_ae_curr_rec,
                                          "FALSE", -- Exp Flag
                                          null, -- Exp Acct
                                          l_dr_flag,
                                          l_ae_line_tbl,
                                          l_err_rec);
          end if;

          -- Check Error
          if (l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
              raise process_error;
          end if;

          if (g_debug_flag = 'Y') then
              fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ': Interorg_cost_txn >>');
          end if;

          return; -- done processing same cost group transfers

        ELSE   /* Different Cost Group Transfer */

              l_stmt_num := 35;

              IF g_debug_flag = 'Y' THEN
                fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ': Transfer across different cost groups');
              END IF;

              /* Select the expense item status of the item in the org belonging
                 to the cost group currently being processed.  This may be different
                 than the cost group of the transaction org. */
              IF (i_ae_txn_rec.cost_group_id <> l_txn_cost_group_id) THEN
                SELECT decode(inventory_asset_flag, 'Y', 0, 1)
                INTO l_cg_exp_item
                FROM mtl_system_items
                WHERE organization_id = i_ae_txn_rec.xfer_organization_id
                AND inventory_item_id = i_ae_txn_rec.inventory_item_id;
              ELSE
                l_cg_exp_item := i_ae_txn_rec.exp_item;
              END IF;

              IF (l_exp_sub1 = 1 OR l_cg_exp_item = 1) THEN
                /* Prior to R12, the code would return and not create accounting
                 * for expense subs or for expense items.
                 * Starting in R12, we should be creating accounting for expense items and
                 * subs, using the expense account when creating entries for On-hand.
                 */
                l_exp_flg := TRUE;
              END IF;

              IF (i_ae_txn_rec.txn_action_id = 3 and i_ae_txn_rec.primary_quantity < 0)
                  OR (i_ae_txn_rec.txn_action_id in (21,15)) THEN -- INVCONV sikhanna
                l_dr_flag := TRUE;
              ELSE
                l_dr_flag := FALSE;
              END IF;
        END IF;

        l_stmt_num := 40;

        /* currency conversion rate in i_ae_curr_rec is always from the sending org to the receiving org */
        l_conv_rate := i_ae_curr_rec.currency_conv_rate;

        IF g_debug_flag = 'Y' THEN
           fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ': Currency conversion rate: ' || l_conv_rate);
        END IF;

        /* Get transfer transaction id for receipt transactions */
        IF ( i_ae_txn_rec.txn_action_id in (12,22)
             OR (i_ae_txn_rec.txn_action_id = 3 AND sign(i_ae_txn_rec.primary_quantity) = 1) ) THEN

            l_stmt_num := 43;
            SELECT transfer_transaction_id
            INTO l_txfr_txn_id
            FROM mtl_material_transactions
            WHERE transaction_id = i_ae_txn_rec.transaction_id;

        END IF;

            /* Get shipment CG */
            l_stmt_num := 45;
            -- changed as a bug found during testing.
            BEGIN
                SELECT cost_group_id
                INTO l_shipping_cg_id
                FROM cst_cost_group_assignments
                WHERE organization_id = (SELECT decode(i_ae_txn_rec.txn_action_id,
                                                        21, organization_id,
                                                        22, organization_id, -- Logical Shipping txn
                                                        12, transfer_organization_id,
                                                        15, transfer_organization_id, -- Logical Receipt txn
                                                        3, decode(sign(i_ae_txn_rec.primary_quantity),
                                                                    1, transfer_organization_id,
                                                                        organization_id),
                                                          NULL)
                                        FROM mtl_material_transactions
                                        WHERE transaction_id = i_ae_txn_rec.transaction_id);
            EXCEPTION
            WHEN no_data_found THEN
                l_shipping_cg_id := -1;
            END;

        /* Process Shipment transactions */

        IF ( i_ae_txn_rec.txn_action_id in (21,15) or (i_ae_txn_rec.txn_action_id = 3 and i_ae_txn_rec.primary_quantity < 0) ) THEN

           l_stmt_num := 50;

           /* Get profile status for internal sales orders */
           BEGIN
               /* Change the Query for the performance. Bug 4586534 */
               SELECT nvl(fnd_profile.value('CST_TRANSFER_PRICING_OPTION'), 0)
               INTO   l_tprice_option
               FROM   mtl_intercompany_parameters MIP
               WHERE  fnd_profile.value('INV_INTERCOMPANY_INVOICE_INTERNAL_ORDER') = 1
               AND (select  count(1)
                          from    hr_organization_information HOI
                          where   HOI.organization_id = decode(i_ae_txn_rec.txn_action_id,
                                                   21, i_ae_txn_rec.organization_id,
                                                   i_ae_txn_rec.xfer_organization_id)
                          AND    HOI.org_information_context = 'Accounting Information'
                          AND    MIP.ship_organization_id = to_number(HOI.org_information3)
                          AND    ROWNUM < 2) >0
               AND ( select  count(1)
                           from    hr_organization_information HOI2
                           where   HOI2.organization_id = decode(i_ae_txn_rec.txn_action_id,
                                                    21, i_ae_txn_rec.xfer_organization_id,
                                                    i_ae_txn_rec.organization_id)
                            AND    HOI2.org_information_context = 'Accounting Information'
                            AND    MIP.sell_organization_id = to_number(HOI2.org_information3)
                            AND    ROWNUM < 2)>0
               AND    MIP.flow_type = 1;

           EXCEPTION
           WHEN NO_DATA_FOUND THEN
               l_tprice_option := -1; /* Chenged it to be -1, will toggle to 0 later */
           END;

            -- Processing the process-discrete txns
            -- INVCONV sikhanna START
            l_stmt_num := 52;
            SELECT MOD(SUM(DECODE(process_enabled_flag,'Y',1,2)), 2)
            INTO l_pd_txfr_ind
            FROM MTL_PARAMETERS MP
            WHERE MP.ORGANIZATION_ID = i_ae_txn_rec.xfer_organization_id
            OR MP.ORGANIZATION_ID    = i_ae_txn_rec.organization_id;

            /* Process-Discrete X-fers set the profile to 2 if ICR relations setup and in diff OU */
            /* l_tprice_option=-1 only when ICR is not set up and exception is thrown, then continue as normal */
            IF (l_pd_txfr_ind=1 and l_tprice_option <> -1) THEN -- OPM ST BUG 5351896

               l_stmt_num := 54;

               l_tprice_option := 2; /* Make it 2 to ignore the CST Transfer Price profile */

               IF g_debug_flag = 'Y' THEN
                  fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ' ICR Set up:process-discrete xfer');
               END IF;

            END IF;

            IF l_tprice_option = -1 THEN
               l_tprice_option := 0; /* Toggle it to 0 as 0 is used later */
            END IF;
            -- INVCONV sikhanna END

            IF g_debug_flag = 'Y' THEN
                       fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                                    ': l_tprice_option:  ' || l_tprice_option || ', process-discrete xfer: ' || l_pd_txfr_ind);
            END IF;

            l_stmt_num := 55;

            -- INVCONV sikhanna, process Internal sales order for OPM conv here
            IF ((i_ae_txn_rec.txn_src_type_id IN (7,8)) AND (l_tprice_option IN (1,2))) THEN    /* Process Internal Orders */

                IF g_debug_flag = 'Y' THEN
                       fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                                    ': Shipment txn of Internal Order Transfer');
                END IF;
           /* Internal Sales Order with transfer price specified and profiles set.
              CST_TRANSFER_PRICING_OPTION is set to: Yes,Price as Incoming Cost or Yes, Price Not as Incoming Cost.
              For other values of this profile,the transaction is treated as an ordinary interorg transfer */

                IF (l_fob_point = 1) THEN   /* FOB - Shipment */

                   IF (i_ae_txn_rec.cost_group_id = l_shipping_cg_id) THEN /* This is the sending CG */

                       l_stmt_num := 57;

                       IF g_debug_flag = 'Y' THEN
                         fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                                      ': Shipment txn of Internal Order FOB Shipment - Sending Cost Group');
                       END IF;

                          IF g_debug_flag = 'Y' THEN
                            fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                                           ': Discrete-Discrete Transfer');
                          END IF;

                       IF (l_cg_exp_item <> 1) THEN
                          /* Credit On-Hand and Debit COGS */ -- only if the item is not expense in the sending org

                          -- Bug 5573993 - Derive the COGS account to break dependency on perpetual
                          -- code as if the trxn is not costed, mmt has incorrect account stamped

                          IF g_debug_flag = 'Y' THEN
                             fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                                       'Deriving COGS account');
                          END IF;

                          l_stmt_num := 61;

                          l_cogs_account := get_intercompany_account (i_ae_txn_rec => i_ae_txn_rec,
                                                                      o_ae_err_rec => l_err_rec);

                          IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                              RAISE process_error;
                          END IF;

                          IF g_debug_flag = 'Y' THEN
                             fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                                       'COGS Account ID: ' || l_cogs_account);
                          END IF;

                          -- Stamp all elemental accounts with the COGS account
                          l_acct_rec.mat_account := l_cogs_account;
                          l_acct_rec.mat_ovhd_account := l_cogs_account;
                          l_acct_rec.res_account := l_cogs_account;
                          l_acct_rec.osp_account := l_cogs_account;
                          l_acct_rec.ovhd_account := l_cogs_account;
                          l_acct_rec.account := l_cogs_account;

                          l_dr_flag := TRUE;

                          -- Debit COGS
                          -- ----------
                          l_stmt_num := 62;

                          CSTPAPBR.offset_accounts (i_ae_txn_rec,
                                                   i_ae_curr_rec,
                                                   2,    --- Acct Line Type
                                                   0,    --- Elemental Flag
                                                   0,    --- Ovhd Flag
                                                   l_dr_flag,
                                                   l_acct_rec,
                                                   l_ae_line_tbl,
                                                   l_err_rec);
                          -- check error
                          IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                              RAISE process_error;
                          END IF;

                          l_dr_flag := not l_dr_flag;

                          l_stmt_num := 64;

                          -- Credit On-hand (if expense, then use expense account)
                          -- -----------------------------------------------------
                          IF (l_exp_flg) THEN
                               CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                                            i_ae_curr_rec,
                                                            l_exp_flg, -- Exp Flag
                                                            l_exp_account, -- Exp Acct
                                                            l_dr_flag,
                                                            l_ae_line_tbl,
                                                            l_err_rec);
                          ELSE
                               CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                                            i_ae_curr_rec,
                                                            "FALSE", -- Exp Flag
                                                            null, -- Exp Acct
                                                            l_dr_flag,
                                                            l_ae_line_tbl,
                                                            l_err_rec);
                          END IF;

                          -- check error
                          IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                              RAISE process_error;
                          END IF;

                       END IF; /* IF (l_cg_exp_item <> 1) THEN  */

                   ELSE /* This is the receiving CG */

                         l_stmt_num := 65;

                         IF g_debug_flag = 'Y' THEN
                           fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                                    ': Shipment txn of Internal Order FOB Shipment - Receiving Cost Group');
                         END IF;

                         /* Credit Intercompany Accrual and Debit Intransit */

                         /* Get Intercompany Accrual Account */

                         -- Bug 5573993 - Derive the Intercompany account to break dependency on perpetual
                         -- code as if the trxn is not costed, mmt has incorrect or no account stamped

                         IF g_debug_flag = 'Y' THEN
                            fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                                       'Deriving intercompany account');
                         END IF;

                         l_accrual_account := get_intercompany_account (i_ae_txn_rec => i_ae_txn_rec,
                                                                        o_ae_err_rec => l_err_rec);

                         IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                             RAISE process_error;
                         END IF;

                         IF g_debug_flag = 'Y' THEN
                            fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                                       'Intercompany Account ID: ' || l_accrual_account);
                         END IF;


                         l_dr_flag := FALSE;

                         /* Absorb MOH if exists */
                         l_stmt_num := 67;
                         select count(transaction_id)
                         into l_mat_ovhd_exists
                         from mtl_pac_actual_cost_details
                         where transaction_id = i_ae_txn_rec.transaction_id
                         and pac_period_id = i_ae_txn_rec.accounting_period_id
                         and cost_group_id = i_ae_txn_rec.cost_group_id
                         and cost_element_id = 2
                         and level_type = 1;

                         l_stmt_num := 68;
                         if (l_mat_ovhd_exists > 0) then
                            ovhd_accounts(i_ae_txn_rec,
                                          i_ae_curr_rec,
                                          l_dr_flag,
                                          l_ae_line_tbl,
                                          l_err_rec);
                           -- check error
                           if (l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
                             raise process_error;
                           end if;
                         end if;

                         -- Credit Intercompany accrual @ transfer price
                         -- --------------------------------------------
                            l_stmt_num := 69;

                            /* 5638994: For txn_axn 15, Logical Intr Rcpt, the transfer price
                               is already in base currency. No currency conv needed */
                            IF (i_ae_txn_rec.txn_action_id = 15) THEN

                                SELECT  NVL(mmt.transfer_price,0)
                                INTO    l_transfer_price
                                FROM    mtl_material_transactions MMT
                                WHERE   MMT.transaction_id = i_ae_txn_rec.transaction_id;

                            ELSE

                                SELECT  NVL(mmt.transfer_price,0) * l_conv_rate
                                INTO    l_transfer_price
                                FROM    mtl_material_transactions MMT
                                WHERE   MMT.transaction_id = i_ae_txn_rec.transaction_id;

                            END IF;

                            IF g_debug_flag = 'Y' THEN
                               fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                               ': Cr Intercompany Accrual @ : ' || l_transfer_price);
                            END IF;

                            l_ae_line_rec.account := l_accrual_account;
                            l_ae_line_rec.transaction_value := abs(i_ae_txn_rec.primary_quantity) * l_transfer_price;
                            l_ae_line_rec.resource_id := NULL;
                            l_ae_line_rec.cost_element_id := NULL;
                            l_ae_line_rec.ae_line_type := 2;

                            insert_account (i_ae_txn_rec,
                                           i_ae_curr_rec,
                                           l_dr_flag,
                                           l_ae_line_rec,
                                           l_ae_line_tbl,
                                           l_err_rec);

                            -- check error
                            IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                                RAISE process_error;
                            END IF;

                         IF (l_tprice_option = 2) THEN

                           IF g_debug_flag = 'Y' THEN
                              fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                               ': CST:Transfer Price Option = Yes, Price As Incoming Cost');
                            END IF;

                         ELSIF (l_tprice_option = 1) THEN

                             IF g_debug_flag = 'Y' THEN
                                fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                  ': CST:Transfer Price Option = Yes, Price Not As Incoming Cost');
                             END IF;

                            -- Debit/Credit Profit in Inventory
                            l_stmt_num := 80;

                            SELECT sum(nvl(transaction_cost,0))
                            INTO   l_mptcd_cost
                            FROM   mtl_pac_txn_cost_details
                            WHERE  transaction_id = i_ae_txn_rec.transaction_id
                            AND    pac_period_id = i_ae_txn_rec.accounting_period_id
                            AND    cost_group_id = i_ae_txn_rec.cost_group_id;

                            l_profit_in_inv_value := l_mptcd_cost - l_transfer_price;

                            IF (sign(l_profit_in_inv_value) = 1) THEN
                                l_dr_flag := FALSE;
                            ELSIF (sign(l_profit_in_inv_value) = -1) THEN
                                l_dr_flag := TRUE;
                            ELSE
                                l_dr_flag := NULL;
                            END IF;

                            l_profit_in_inv_value := abs(l_profit_in_inv_value);

                            IF (l_dr_flag IS NOT NULL) THEN

                                    l_stmt_num := 84;
                                    SELECT nvl(profit_in_inv_account, -1)
                                    INTO   l_profit_in_inv_account
                                    FROM   mtl_interorg_parameters
                                    WHERE  from_organization_id = i_ae_txn_rec.organization_id
                                    AND    to_organization_id = i_ae_txn_rec.xfer_organization_id;

                                    IF (l_profit_in_inv_account = -1) THEN
                                       RAISE no_profit_in_inv_acct_error;
                                    END IF;

                                    /* Profit in Inventory entry */
                                    l_ae_line_rec.account := l_profit_in_inv_account;
                                    l_ae_line_rec.transaction_value := l_profit_in_inv_value  * abs(i_ae_txn_rec.primary_quantity);
                                    l_ae_line_rec.resource_id := NULL;
                                    l_ae_line_rec.cost_element_id := NULL;
                                    l_ae_line_rec.ae_line_type := 30;   -- Profit in Inventory

                                    l_stmt_num := 86;

                                    insert_account (i_ae_txn_rec,
                                                    i_ae_curr_rec,
                                                    l_dr_flag,
                                                    l_ae_line_rec,
                                                    l_ae_line_tbl,
                                                    l_err_rec);

                                    -- check error
                                    IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                                        RAISE process_error;
                                    END IF;

                            END IF; /* (l_dr_flag IS NOT NULL) */

                         END IF; /* (l_tprice_option = 2) */


                         -- Debit Intransit (or Expense if an expense item in the receiving CG)
                         ----------------------------------------------------------------------
                         l_dr_flag := TRUE;

                         /* If the item is expense in the receiving CG, hit the expense account instead of Intransit */
                         IF (l_cg_exp_item = 1) THEN
                           /* Debit Expense */
                           CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                                       i_ae_curr_rec,
                                                       l_exp_flg, -- Exp Flag
                                                       l_exp_account, -- Exp Acct
                                                       l_dr_flag,
                                                       l_ae_line_tbl,
                                                       l_err_rec);
                         ELSE
                           /* Debit Inventory - Intransit */
                           CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                                     i_ae_curr_rec,
                                                     "FALSE",   --- Exp Flag
                                                      null,      --- Exp Acct
                                                      l_dr_flag,
                                                      l_ae_line_tbl,
                                                      l_err_rec,
                                                      1);
                        END IF;

                        -- check error
                        IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                           RAISE process_error;
                        END IF;

                   END IF;

                ELSIF (l_fob_point = 2) THEN /* Internal Order FOBR */

                        l_stmt_num := 90;
                        /* This can only be the sending CG */

                         IF g_debug_flag = 'Y' THEN
                           fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                         ': Shipment txn of Internal Order FOB Receipt - Shipping Cost Group');
                         END IF;

                     IF (l_cg_exp_item <> 1) THEN
                        /*   Debit Intransit and Credit OnHand - only if this is not an expense item */

                        l_dr_flag := TRUE;

                        -- Debit Intransit
                        ------------------
                       CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                                    i_ae_curr_rec,
                                                    "FALSE",   --- Exp Flag
                                                    null,      --- Exp Acct
                                                    l_dr_flag,
                                                    l_ae_line_tbl,
                                                    l_err_rec,
                                                    1);

                          -- check error
                          IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                              RAISE process_error;
                          END IF;

                       l_dr_flag := not l_dr_flag;

                       -- Credit On-hand (if expense, then use expense account)
                       -- -----------------------------------------------------
                       IF (l_exp_flg) THEN
                          CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                                       i_ae_curr_rec,
                                                       l_exp_flg, -- Exp Flag
                                                       l_exp_account, -- Exp Acct
                                                       l_dr_flag,
                                                       l_ae_line_tbl,
                                                       l_err_rec);
                       ELSE
                          CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                                       i_ae_curr_rec,
                                                       "FALSE", -- Exp Flag
                                                       null, -- Exp Acct
                                                       l_dr_flag,
                                                       l_ae_line_tbl,
                                                       l_err_rec);
                       END IF;

                       -- check error
                       IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                           RAISE process_error;
                       END IF;

                    END IF; /* IF (l_cg_exp_item <> 1) THEN  */

                 END IF;

            /* Ignore OPM-Discrete Logical txns; to be processed at the end */
            ELSIF (i_ae_txn_rec.txn_action_id not in (15,22)) THEN /* Ordinary Interorg shipments */

                 l_stmt_num := 92;
                 IF g_debug_flag = 'Y' THEN
                    fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                          ': Interorg Shipment transaction');
                 END IF;

                 IF ((i_ae_txn_rec.cost_group_id = l_shipping_cg_id) AND l_fob_point = 1) THEN /* This is the sending CG for FOBS */

                     l_stmt_num := 94;
                     IF g_debug_flag = 'Y' THEN
                        fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                              ': Shipment txn of FOB Shipment - Shipping Cost Group');
                     END IF;


                   l_dr_flag := FALSE;
                   IF (l_cg_exp_item <> 1) THEN
                     /* Credit OnHand at PWAC Cost */

                     -- Credit On-hand (if expense, then use expense account)
                     -- -----------------------------------------------------
                     IF (l_exp_flg) THEN
                        CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                                     i_ae_curr_rec,
                                                     l_exp_flg, -- Exp Flag
                                                     l_exp_account, -- Exp Acct
                                                     l_dr_flag,
                                                     l_ae_line_tbl,
                                                     l_err_rec);
                     ELSE
                        CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                                     i_ae_curr_rec,
                                                     "FALSE", -- Exp Flag
                                                     null, -- Exp Acct
                                                     l_dr_flag,
                                                     l_ae_line_tbl,
                                                     l_err_rec);
                     END IF;
                   END IF; /* IF (l_cg_exp_item <> 1) THEN      */

                    /* Debit Receivables at estimated cost: This can be CPIC cost/previous period cost/MTA cost */

                   l_dr_flag := not l_dr_flag;

                    l_stmt_num := 96;

                    /* Get relevant accounts */
                    SELECT mip.interorg_receivables_account,
                           mmt.transportation_dist_account,
                           mip.interorg_transfer_cr_account,
                           nvl(mip.interorg_profit_account, -1)
                    INTO   l_io_rcv_acct,
                           l_io_freight_acct,
                           l_io_txfr_cr_acct,
                           l_io_txfr_var_acct
                    FROM   mtl_interorg_parameters mip,
                           mtl_material_transactions mmt
                    WHERE  mip.from_organization_id = i_ae_txn_rec.organization_id
                    AND    mip.to_organization_id = i_ae_txn_rec.xfer_organization_id
                    AND    mmt.transaction_id = i_ae_txn_rec.transaction_id;

                    l_ae_line_rec.account := l_io_rcv_acct;

                    l_stmt_num := 98;

                    /* Get prior period id */
                    SELECT nvl(max(cpp.pac_period_id), -1)
                    INTO  l_prev_period_id
                    FROM  cst_pac_periods cpp
                    WHERE cpp.cost_type_id = i_ae_txn_rec.cost_type_id
                    AND   cpp.legal_entity = i_ae_txn_rec.legal_entity_id
                    AND   cpp.pac_period_id < i_ae_txn_rec.accounting_period_id;

                    l_stmt_num := 100;

                    /* The flag selected below indicates if PACP is used or not */
                    SELECT TRANSFER_COST_FLAG
                    INTO   l_transfer_cost_flag
                    FROM   CST_LE_COST_TYPES
                    WHERE  LEGAL_ENTITY = i_ae_txn_rec.legal_entity_id
                    AND    COST_TYPE_ID = i_ae_txn_rec.cost_type_id;

                    l_stmt_num := 102;

                    SELECT NVL(MAX(cost_group_id),-1)
                    INTO   l_txfr_cost_group_id
                    FROM   cst_cost_group_assignments
                    WHERE  organization_id = i_ae_txn_rec.xfer_organization_id;

                    l_stmt_num := 104;

                   /* Get legal entity of the other cost group,if available */
                    BEGIN
                        SELECT legal_entity
                        INTO l_txfr_legal_entity
                        FROM cst_cost_groups
                        WHERE cost_group_id = l_txfr_cost_group_id;
                    EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        l_txfr_legal_entity := NULL;
                    END;

                   /* See if i_cost_type_id is attached to the transfer LE as well */
                   l_stmt_num := 106;
                   SELECT count(*)
                   INTO   l_same_le_ct
                   FROM   cst_le_cost_types
                   WHERE  legal_entity = l_txfr_legal_entity
                   AND    cost_type_id = i_ae_txn_rec.cost_type_id;

                   /* Check for the same LE/CT combination */
                   IF (i_ae_txn_rec.legal_entity_id = l_txfr_legal_entity AND l_same_le_ct > 0 AND l_transfer_cost_flag = 'Y') THEN

                    --  IF (l_transfer_cost_flag = 'Y') THEN

                           /* PACP used:
                              The estimated cost is available in CPICD */
                           l_stmt_num := 110;

                           SELECT NVL(CPIC.item_cost,0)
                           INTO   l_pacp_pwac_cost
                           FROM   CST_PAC_ITEM_COSTS CPIC
                           WHERE  CPIC.INVENTORY_ITEM_ID = i_ae_txn_rec.inventory_item_id
                           AND    CPIC.COST_GROUP_ID     = i_ae_txn_rec.cost_group_id
                           AND    CPIC.PAC_PERIOD_ID     = i_ae_txn_rec.accounting_period_id;

                           IF g_debug_flag = 'Y' THEN
                              fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                         ': Using PAC Absorption Cost: ' || l_pacp_pwac_cost);
                           END IF;

                           /* Get transfer credit information */
                           l_stmt_num := 112;
                           SELECT nvl(transfer_percentage,0),nvl(transfer_cost,0)
                           INTO   l_txfr_percent,l_txfr_cost
                           FROM   mtl_material_transactions
                           WHERE  transaction_id = i_ae_txn_rec.transaction_id;

                           IF (l_txfr_percent <> 0) THEN
                               l_txfr_credit := (l_txfr_percent * l_pacp_pwac_cost / 100);
                           ELSIF (l_txfr_cost <> 0) THEN
                               l_txfr_credit := l_txfr_cost / abs(i_ae_txn_rec.primary_quantity);
                           ELSE
                               l_txfr_credit := 0;
                           END IF;

                           l_io_rcv_value := (l_pacp_pwac_cost + l_txfr_credit);

                           l_ae_line_rec.transaction_value := l_io_rcv_value * abs(i_ae_txn_rec.primary_quantity);
                           l_ae_line_rec.resource_id := NULL;
                           l_ae_line_rec.cost_element_id := NULL;
                           l_ae_line_rec.ae_line_type := 10;  -- Receivables

                           l_stmt_num := 114;
                           insert_account (i_ae_txn_rec,
                                           i_ae_curr_rec,
                                           l_dr_flag,
                                           l_ae_line_rec,
                                           l_ae_line_tbl,
                                           l_err_rec);

                          -- check error
                          IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                              RAISE process_error;
                          END IF;

                           /* Create entries for transfer credit*/
                           /* No need to create transfer variance entry since estimated sending CG cost = sending CG PMAC in CPIC */

                           l_dr_flag := FALSE;

                           l_ae_line_rec.account := l_io_txfr_cr_acct;
                           l_ae_line_rec.transaction_value := l_txfr_credit * abs(i_ae_txn_rec.primary_quantity);
                           l_ae_line_rec.resource_id := NULL;
                           l_ae_line_rec.cost_element_id := NULL;
                           l_ae_line_rec.ae_line_type := 11;  -- Transfer Credit

                           IF (l_ae_line_rec.transaction_value <> 0) THEN

                                insert_account (i_ae_txn_rec,
                                                i_ae_curr_rec,
                                                l_dr_flag,
                                                l_ae_line_rec,
                                                l_ae_line_tbl,
                                                l_err_rec);
                                -- check error
                                IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                                    RAISE process_error;
                                END IF;

                           END IF;
                  ELSE

                     IF (i_ae_txn_rec.legal_entity_id = l_txfr_legal_entity AND l_same_le_ct > 0 AND l_prev_period_id <> -1) THEN

                           l_stmt_num := 115;
                           l_use_prev_period_cost := 1;

                           /* Get prior period PWAC Cost */
                                BEGIN
                                    SELECT nvl(CPIC.item_cost,0)
                                      INTO l_prev_period_pwac_cost
                                      FROM CST_PAC_ITEM_COSTS CPIC
                                     WHERE CPIC.INVENTORY_ITEM_ID = i_ae_txn_rec.inventory_item_id
                                       AND CPIC.COST_GROUP_ID     = i_ae_txn_rec.cost_group_id
                                       AND CPIC.PAC_PERIOD_ID     = l_prev_period_id;
                                EXCEPTION
                                when no_data_found then
                                    /* Use perpetual cost if prior period cost is not available */
                                    l_use_prev_period_cost := 0;
                                END;
                     ELSE
                       /* Use perpetual cost if prior period cost is not available or if the cost groups are not in the same LE/CT. */
                           l_use_prev_period_cost := 0;
                     END IF;

                     IF (l_use_prev_period_cost = 1) THEN

                           IF g_debug_flag = 'Y' THEN
                              fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                                             ': Using prior period PWAC cost: ' || l_prev_period_pwac_cost);
                           END IF;

                           /* Get transfer credit information */
                           l_stmt_num := 117;
                           SELECT nvl(transfer_percentage,0),nvl(transfer_cost,0)
                           INTO   l_txfr_percent,l_txfr_cost
                           FROM   mtl_material_transactions
                           WHERE  transaction_id = i_ae_txn_rec.transaction_id;

                           IF (l_txfr_percent <> 0) THEN
                               l_txfr_credit := (l_txfr_percent * l_prev_period_pwac_cost / 100);
                           ELSIF (l_txfr_cost <> 0) THEN
                               l_txfr_credit := l_txfr_cost / abs(i_ae_txn_rec.primary_quantity);
                           ELSE
                               l_txfr_credit := 0;
                           END IF;

                           l_io_rcv_value := (l_prev_period_pwac_cost + l_txfr_credit);

                           l_ae_line_rec.transaction_value := l_io_rcv_value * abs(i_ae_txn_rec.primary_quantity);
                           l_ae_line_rec.resource_id := NULL;
                           l_ae_line_rec.cost_element_id := NULL;
                           l_ae_line_rec.ae_line_type := 10;  -- Receivables

                           l_stmt_num := 118;
                           insert_account (i_ae_txn_rec,
                                           i_ae_curr_rec,
                                           l_dr_flag,
                                           l_ae_line_rec,
                                           l_ae_line_tbl,
                                           l_err_rec);

                           -- check error
                           IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                               RAISE process_error;
                           END IF;

                           /* Create entries for transfer credit and transfer variance */
                           l_stmt_num := 120;

                           l_dr_flag := FALSE;

                           l_ae_line_rec.account := l_io_txfr_cr_acct;
                           l_ae_line_rec.transaction_value := l_txfr_credit * abs(i_ae_txn_rec.primary_quantity);
                           l_ae_line_rec.resource_id := NULL;
                           l_ae_line_rec.cost_element_id := NULL;
                           l_ae_line_rec.ae_line_type := 11;  -- Transfer Credit

                           IF (l_ae_line_rec.transaction_value <> 0) THEN

                                insert_account (i_ae_txn_rec,
                                                i_ae_curr_rec,
                                                l_dr_flag,
                                                l_ae_line_rec,
                                                l_ae_line_tbl,
                                                l_err_rec);
                                -- check error
                                IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                                    RAISE process_error;
                                END IF;

                           END IF;

                           l_stmt_num := 122;
                           SELECT sum(nvl(actual_cost,0))
                           INTO   l_mpacd_cost
                           FROM   mtl_pac_actual_cost_details
                           WHERE  transaction_id = i_ae_txn_rec.transaction_id
                           AND    pac_period_id = i_ae_txn_rec.accounting_period_id
                           AND    cost_group_id = i_ae_txn_rec.cost_group_id;

                           l_stmt_num := 125;

                           l_txfr_var_value := l_io_rcv_value - (l_mpacd_cost + l_txfr_credit);

                           IF (sign(l_txfr_var_value) = 1) THEN
                              l_dr_flag := FALSE;
                           ELSIF (sign(l_txfr_var_value) = -1) THEN
                              l_dr_flag := TRUE;
                           ELSE
                              l_dr_flag := NULL;
                           END IF;

                           l_txfr_var_value := abs(l_txfr_var_value);

                           IF (l_dr_flag IS NOT NULL) THEN

                             IF (l_io_txfr_var_acct = -1) THEN
                               RAISE no_interorg_profit_acct_error;
                             END IF;

                             /* Transfer variance entry */
                             l_ae_line_rec.account := l_io_txfr_var_acct;
                             l_ae_line_rec.transaction_value := l_txfr_var_value * abs(i_ae_txn_rec.primary_quantity);
                             l_ae_line_rec.resource_id := NULL;
                             l_ae_line_rec.cost_element_id := NULL;
                             l_ae_line_rec.ae_line_type := 34;   -- Interorg profit in inventory

                             insert_account (i_ae_txn_rec,
                                             i_ae_curr_rec,
                                             l_dr_flag,
                                             l_ae_line_rec,
                                             l_ae_line_tbl,
                                             l_err_rec);

                             -- check error
                             IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                                RAISE process_error;
                             END IF;

                           END IF;

                     ELSE /* MTA Entries to be used */ /* Not same LE/CT, INVCONV processed here */
                                                       /* or same LE/CT where there is no prior period cost */
                       l_stmt_num := 130;

                       -- Processing the process-discrete txns
                       -- INVCONV sikhanna
                       SELECT MOD(SUM(DECODE(process_enabled_flag,'Y',1,2)), 2)
                       INTO l_pd_txfr_ind
                       FROM MTL_PARAMETERS MP
                       WHERE MP.ORGANIZATION_ID = i_ae_txn_rec.xfer_organization_id
                       OR MP.ORGANIZATION_ID    = i_ae_txn_rec.organization_id;


                       l_stmt_num := 135;

                       IF (l_pd_txfr_ind = 0) THEN -- Discrete-Discrete X-fers

                            IF g_debug_flag = 'Y' THEN
                              fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                         ': Discrete-Discrete Transfer: Using MTA cost');
                            END IF;

                            BEGIN
                              SELECT nvl(SUM(ABS(NVL(base_transaction_value, 0))),0)
                              INTO l_perp_ship_value
                              FROM mtl_transaction_accounts mta
                              WHERE mta.transaction_id = i_ae_txn_rec.transaction_id
                              and mta.organization_id = i_ae_txn_rec.organization_id
                              and mta.accounting_line_type IN (1,2,14)
                              and mta.base_transaction_value < 0;
                            EXCEPTION
                              WHEN no_data_found THEN
                                 l_perp_ship_value := 0;
                            END;

                            IF g_debug_flag = 'Y' THEN
                              fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                         ': l_perp_ship_value = ' || l_perp_ship_value);
                            END IF;

                            l_stmt_num := 145;

                            SELECT nvl(transfer_percentage,0),nvl(transfer_cost,0)
                            INTO l_txfr_percent,l_txfr_cost
                            FROM mtl_material_transactions
                            WHERE transaction_id = i_ae_txn_rec.transaction_id;

                            IF (l_txfr_percent <> 0) THEN
                                l_txfr_credit := (l_txfr_percent * (l_perp_ship_value)/ (100 * abs(i_ae_txn_rec.primary_quantity)));
                            elsif (l_txfr_cost <> 0) THEN
                                l_txfr_credit := l_txfr_cost / abs(i_ae_txn_rec.primary_quantity);
                            ELSE
                                l_txfr_credit := 0;
                            END IF;

                            IF g_debug_flag = 'Y' THEN
                              fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                         ': l_txfr_credit = ' || l_txfr_credit);
                            END IF;

                            l_stmt_num := 150;

                            l_io_rcv_value := l_txfr_credit + (l_perp_ship_value / abs(i_ae_txn_rec.primary_quantity));

                            IF g_debug_flag = 'Y' THEN
                              fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                         ': l_io_rcv_value = ' || l_io_rcv_value);
                            END IF;

                            l_ae_line_rec.transaction_value := l_io_rcv_value * abs(i_ae_txn_rec.primary_quantity);
                            l_ae_line_rec.account := l_io_rcv_acct;
                            l_ae_line_rec.resource_id := NULL;
                            l_ae_line_rec.cost_element_id := NULL;
                            l_ae_line_rec.ae_line_type := 10;  -- Receivables

                            l_stmt_num := 155;

                            /* Debit Receivables */
                            insert_account (i_ae_txn_rec,
                                            i_ae_curr_rec,
                                            l_dr_flag,
                                            l_ae_line_rec,
                                            l_ae_line_tbl,
                                            l_err_rec);

                            -- check error
                            IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                                RAISE process_error;
                            END IF;

                            /* Create entries for transfer credit and transfer variance */
                            l_stmt_num := 160;

                            l_dr_flag := FALSE;

                            l_ae_line_rec.account := l_io_txfr_cr_acct;
                            l_ae_line_rec.transaction_value := l_txfr_credit * abs(i_ae_txn_rec.primary_quantity);
                            l_ae_line_rec.resource_id := NULL;
                            l_ae_line_rec.cost_element_id := NULL;
                            l_ae_line_rec.ae_line_type := 11;   -- Transfer Credit

                            IF (l_ae_line_rec.transaction_value <> 0) THEN

                                insert_account (i_ae_txn_rec,
                                                i_ae_curr_rec,
                                                l_dr_flag,
                                                l_ae_line_rec,
                                                l_ae_line_tbl,
                                                l_err_rec);
                                -- check error
                                IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                                    RAISE process_error;
                                END IF;

                            END IF;

                            l_stmt_num := 165;

                            SELECT sum(nvl(actual_cost,0))
                            INTO   l_mpacd_cost
                            FROM   mtl_pac_actual_cost_details
                            WHERE  transaction_id = i_ae_txn_rec.transaction_id
                            AND    pac_period_id = i_ae_txn_rec.accounting_period_id
                            AND    cost_group_id = i_ae_txn_rec.cost_group_id;

                            l_txfr_var_value := l_io_rcv_value - (l_mpacd_cost + l_txfr_credit);

                            IF (sign(l_txfr_var_value) = 1) THEN
                              l_dr_flag := FALSE;
                            ELSIF (sign(l_txfr_var_value) = -1) THEN
                              l_dr_flag := TRUE;
                            ELSE
                              l_dr_flag := NULL;
                            END IF;

                            l_txfr_var_value := abs(l_txfr_var_value);

                            IF g_debug_flag = 'Y' THEN
                              fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                         ': l_txfr_var_value = ' || l_txfr_var_value);
                            END IF;

                            l_stmt_num := 170;

                            IF (l_dr_flag IS NOT NULL) THEN

                              IF (l_io_txfr_var_acct = -1) THEN
                                RAISE no_interorg_profit_acct_error;
                              END IF;

                              /* transfer variance entry */
                              l_ae_line_rec.account := l_io_txfr_var_acct;
                              l_ae_line_rec.transaction_value := l_txfr_var_value * abs(i_ae_txn_rec.primary_quantity);
                              l_ae_line_rec.resource_id := NULL;
                              l_ae_line_rec.cost_element_id := NULL;
                              l_ae_line_rec.ae_line_type := 34;  -- Interorg profit in inventory

                              l_stmt_num := 175;

                              insert_account (i_ae_txn_rec,
                                              i_ae_curr_rec,
                                              l_dr_flag,
                                              l_ae_line_rec,
                                              l_ae_line_tbl,
                                              l_err_rec);

                              -- check error
                              IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                                 RAISE process_error;
                              END IF;

                            END IF;

                       ELSE  /* Org is process enabled */

                            l_stmt_num := 180;

                            IF g_debug_flag = 'Y' THEN
                              fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                         ': Process-Discrete Transfer');
                            END IF;

                            SELECT mip.interorg_receivables_account,
                                   mmt.transportation_dist_account,
                                   nvl(mip.interorg_profit_account, -1),
                                   nvl(mmt.transfer_price,0),
                                   nvl(mmt.transportation_cost,0)
                            INTO   l_io_rcv_acct,
                                   l_io_freight_acct,
                                   l_io_txfr_var_acct,
                                   l_txfr_cost, -- transfer price
                                   l_trp_cost   -- transportation cost
                            FROM   mtl_interorg_parameters mip,mtl_material_transactions mmt
                            WHERE  mip.from_organization_id = i_ae_txn_rec.organization_id
                            AND    mip.to_organization_id = i_ae_txn_rec.xfer_organization_id
                            AND    mmt.transaction_id = i_ae_txn_rec.transaction_id;

                            IF (l_io_txfr_var_acct = -1) THEN
                              RAISE no_interorg_profit_acct_error;
                            END IF;

                            l_stmt_num := 185;

                            SELECT NVL(CPIC.item_cost,0)
                            INTO   l_pwac_cost
                            FROM   CST_PAC_ITEM_COSTS CPIC
                            WHERE  CPIC.INVENTORY_ITEM_ID = i_ae_txn_rec.inventory_item_id
                            AND    CPIC.COST_GROUP_ID     = i_ae_txn_rec.cost_group_id
                            AND    CPIC.PAC_PERIOD_ID     = i_ae_txn_rec.accounting_period_id;

                            l_dr_flag := TRUE;

                            l_stmt_num := 190;

                            l_ae_line_rec.transaction_value := l_txfr_cost * abs(i_ae_txn_rec.primary_quantity); -- Receivables only at transfer price
                            l_ae_line_rec.account := l_io_rcv_acct;
                            l_ae_line_rec.resource_id := NULL;
                            l_ae_line_rec.cost_element_id := NULL;
                            l_ae_line_rec.ae_line_type := 10;  -- Receivables

                            l_stmt_num := 195;

                            insert_account (i_ae_txn_rec,
                                            i_ae_curr_rec,
                                            l_dr_flag,
                                            l_ae_line_rec,
                                            l_ae_line_tbl,
                                            l_err_rec);

                            -- check error
                            IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                                RAISE process_error;
                            END IF;

                            l_profit_or_loss := l_pwac_cost - l_txfr_cost;

                            IF l_profit_or_loss <> 0 THEN

                                IF l_profit_or_loss < 0 THEN
                                    l_dr_flag := not l_dr_flag; -- If -ve then Credit interorg profit
                                END IF;

                                l_stmt_num := 200;

                                l_ae_line_rec.transaction_value := abs(l_profit_or_loss * i_ae_txn_rec.primary_quantity);
                                l_ae_line_rec.account := l_io_txfr_var_acct;
                                l_ae_line_rec.resource_id := NULL;
                                l_ae_line_rec.cost_element_id := NULL;
                                l_ae_line_rec.ae_line_type := 34;   -- interorg profit account

                                l_stmt_num := 205;

                                insert_account (i_ae_txn_rec,
                                                i_ae_curr_rec,
                                                l_dr_flag,
                                                l_ae_line_rec,
                                                l_ae_line_tbl,
                                                l_err_rec);

                                -- check error
                                IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                                    RAISE process_error;
                                END IF;

                            END IF;

                     END IF;  /* (l_pd_txfr_ind = 0) */ -- End INVCONV check sikhanna

                    END IF; /* IF (l_use_prev_period_cost = 1) THEN*/
                  END IF; /* (i_ae_txn_rec.legal_entity_id = l_txfr_legal_entity AND l_same_le_ct > 0) */ -- End of LE/CT check

                 ELSIF ((i_ae_txn_rec.cost_group_id <> l_shipping_cg_id) AND l_fob_point = 1) THEN /* This is the receiving CG for FOBS */

                       l_stmt_num := 210;

                       IF g_debug_flag = 'Y' THEN
                         fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                         ': Shipment txn of FOB Shipment - Receiving Cost Group');
                       END IF;

                       SELECT mip.interorg_payables_account,
                              mmt.transportation_dist_account
                       INTO   l_io_pay_acct,
                              l_io_freight_acct
                       FROM   mtl_interorg_parameters mip,
                              mtl_material_transactions mmt
                       WHERE  mip.from_organization_id = i_ae_txn_rec.organization_id
                       AND    mip.to_organization_id = i_ae_txn_rec.xfer_organization_id
                       AND    mmt.transaction_id = i_ae_txn_rec.transaction_id;

                       /* Debit Intransit or Expense if an expense item */

                       l_dr_flag := TRUE;

                       /* If the item is expense in the receiving CG, hit the expense account instead of Intransit */
                       IF (l_cg_exp_item = 1) THEN
                           /* Debit Expense */
                           CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                                       i_ae_curr_rec,
                                                       l_exp_flg, -- Exp Flag
                                                       l_exp_account, -- Exp Acct
                                                       l_dr_flag,
                                                       l_ae_line_tbl,
                                                       l_err_rec);
                       ELSE
                           /* Debit Inventory - Intransit */
                          CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                                    i_ae_curr_rec,
                                                    "FALSE",   --- Exp Flag
                                                    null,      --- Exp Acct
                                                    l_dr_flag,
                                                    l_ae_line_tbl,
                                                    l_err_rec,
                                                    1);

                       END IF;

                       -- check error
                       IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                           RAISE process_error;
                       END IF;

                       l_dr_flag := not l_dr_flag;

                       /* Credit freight account */

                           l_stmt_num := 215;

                           SELECT nvl(transportation_cost,0) * l_conv_rate /* convert from shipping org currency to receiving org currency */
                           INTO l_trp_cost
                           FROM mtl_material_transactions
                           WHERE transaction_id = i_ae_txn_rec.transaction_id;

                            l_ae_line_rec.transaction_value := l_trp_cost;
                            l_ae_line_rec.account := l_io_freight_acct;
                            l_ae_line_rec.resource_id := NULL;
                            l_ae_line_rec.cost_element_id := NULL;
                            l_ae_line_rec.ae_line_type := 12;

                           IF (l_ae_line_rec.transaction_value <> 0) THEN

                                insert_account (i_ae_txn_rec,
                                                i_ae_curr_rec,
                                                l_dr_flag,
                                                l_ae_line_rec,
                                                l_ae_line_tbl,
                                                l_err_rec);

                                -- check error
                                IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                                    RAISE process_error;
                                END IF;

                           END IF;

                         /* Absorb MOH if exists */
                         l_stmt_num := 217;
                         select count(transaction_id)
                         into l_mat_ovhd_exists
                         from mtl_pac_actual_cost_details
                         where transaction_id = i_ae_txn_rec.transaction_id
                         and pac_period_id = i_ae_txn_rec.accounting_period_id
                         and cost_group_id = i_ae_txn_rec.cost_group_id
                         and cost_element_id = 2
                         and level_type = 1;

                         l_stmt_num := 220;

                         l_mat_ovhd_cost := 0;

                         if (l_mat_ovhd_exists > 0) then
                            ovhd_accounts(i_ae_txn_rec,
                                          i_ae_curr_rec,
                                          l_dr_flag,
                                          l_ae_line_tbl,
                                          l_err_rec);
                           -- check error
                           if (l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
                             raise process_error;
                           end if;

                           l_stmt_num := 222;

                           select sum(nvl(actual_cost,0))
                           into   l_mat_ovhd_cost
                           from mtl_pac_cost_subelements
                           where transaction_id = i_ae_txn_rec.transaction_id
                           and cost_group_id = i_ae_txn_rec.cost_group_id
                           and pac_period_id = i_ae_txn_rec.accounting_period_id
                           and cost_type_id = i_ae_txn_rec.cost_type_id
                           and cost_element_id = 2;

                         end if;

                       /* Credit Payables */
                       l_stmt_num := 224;

                       SELECT sum(nvl(transaction_cost,0))
                       INTO l_mptcd_cost
                       FROM mtl_pac_txn_cost_details
                       WHERE transaction_id = i_ae_txn_rec.transaction_id
                       AND pac_period_id = i_ae_txn_rec.accounting_period_id
                       AND cost_group_id = i_ae_txn_rec.cost_group_id;

                       l_ae_line_rec.transaction_value := (l_mptcd_cost * abs(i_ae_txn_rec.primary_quantity)) - l_trp_cost;

                       l_ae_line_rec.account := l_io_pay_acct;
                       l_ae_line_rec.resource_id := NULL;
                       l_ae_line_rec.cost_element_id := NULL;
                       l_ae_line_rec.ae_line_type := 9;  -- Payables

                       insert_account (i_ae_txn_rec,
                                       i_ae_curr_rec,
                                       l_dr_flag,
                                       l_ae_line_rec,
                                       l_ae_line_tbl,
                                       l_err_rec);

                       -- check error
                       IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                           RAISE process_error;
                       END IF;

                 ELSIF (l_fob_point = 2) THEN /* FOBR - This can only be the shipping CG */

                        l_stmt_num := 225;

                        IF g_debug_flag = 'Y' THEN
                          fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                         ': Shipment txn of FOB Receipt - Shipping Cost Group');
                        END IF;

                     IF (l_cg_exp_item <> 1) THEN
                        /* Debit Intransit and Credit OnHand */

                        l_dr_flag := TRUE;

                       -- Debit Intransit
                       -- ---------------
                       CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                                    i_ae_curr_rec,
                                                    "FALSE",   --- Exp Flag
                                                     null,      --- Exp Acct
                                                    l_dr_flag,
                                                    l_ae_line_tbl,
                                                    l_err_rec,
                                                    1);

                       -- check error
                       IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                           RAISE process_error;
                       END IF;

                       l_dr_flag := not l_dr_flag;

                       -- Credit On-hand (if expense, then use expense account)
                       -- -----------------------------------------------------
                       IF (l_exp_flg) THEN
                          CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                                       i_ae_curr_rec,
                                                       l_exp_flg, -- Exp Flag
                                                       l_exp_account, -- Exp Acct
                                                       l_dr_flag,
                                                       l_ae_line_tbl,
                                                       l_err_rec);
                       ELSE
                          CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                                       i_ae_curr_rec,
                                                       "FALSE", -- Exp Flag
                                                       null, -- Exp Acct
                                                       l_dr_flag,
                                                       l_ae_line_tbl,
                                                       l_err_rec);
                       END IF;

                       -- check error
                       IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                           RAISE process_error;
                       END IF;
                    END IF; /*  IF (l_cg_exp_item <> 1) THEN */

                 ELSIF (i_ae_txn_rec.txn_action_id = 3) THEN /* Direct Interorg */

                        l_stmt_num := 230;

                        IF g_debug_flag = 'Y' THEN
                          fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                         ': Shipment txn of Direct Interorg - Shipping Cost Group');
                        END IF;

                        /* Credit Onhand inventory */

                        l_dr_flag := FALSE;

                     IF (l_cg_exp_item <> 1) THEN
                        -- Credit On-hand (if expense, then use expense account)
                        -- -----------------------------------------------------
                        IF (l_exp_flg) THEN
                           CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                                        i_ae_curr_rec,
                                                        l_exp_flg, -- Exp Flag
                                                        l_exp_account, -- Exp Acct
                                                        l_dr_flag,
                                                        l_ae_line_tbl,
                                                        l_err_rec);
                        ELSE
                           CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                                        i_ae_curr_rec,
                                                        "FALSE", -- Exp Flag
                                                        null, -- Exp Acct
                                                        l_dr_flag,
                                                        l_ae_line_tbl,
                                                        l_err_rec);
                        END IF;

                        -- check error
                        IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                            RAISE process_error;
                        END IF;

                     END IF; /*  IF (l_cg_exp_item <> 1) THEN */

                        l_dr_flag := not l_dr_flag;

                        /* Create entries for Receivables, Transfer Credit, Transportation, etc. */

                        l_stmt_num := 235;

                        /* Get relevant accounts */
                        SELECT mip.interorg_receivables_account,
                               mmt.transportation_dist_account,
                               mip.interorg_transfer_cr_account,
                               nvl(mip.interorg_profit_account, -1)
                        INTO   l_io_rcv_acct,
                               l_io_freight_acct,
                               l_io_txfr_cr_acct,
                               l_io_txfr_var_acct
                        FROM   mtl_interorg_parameters mip,mtl_material_transactions mmt
                        WHERE  mip.from_organization_id = i_ae_txn_rec.organization_id
                        AND    mip.to_organization_id = i_ae_txn_rec.xfer_organization_id
                        AND    mmt.transaction_id = i_ae_txn_rec.transaction_id;

                        IF (l_io_txfr_var_acct = -1) THEN
                              RAISE no_interorg_profit_acct_error;
                        END IF;

                        l_ae_line_rec.account := l_io_rcv_acct;

                        l_stmt_num := 240;

                        SELECT TRANSFER_COST_FLAG
                        INTO   l_transfer_cost_flag
                        FROM   CST_LE_COST_TYPES
                        WHERE  LEGAL_ENTITY = i_ae_txn_rec.legal_entity_id
                        AND    COST_TYPE_ID = i_ae_txn_rec.cost_type_id;

                        l_stmt_num := 245;

                        /* Prior period id */
                        SELECT nvl(max(cpp.pac_period_id), -1)
                        INTO   l_prev_period_id
                        FROM   cst_pac_periods cpp
                        WHERE  cpp.cost_type_id = i_ae_txn_rec.cost_type_id
                        AND    cpp.legal_entity = i_ae_txn_rec.legal_entity_id
                        AND    cpp.pac_period_id < i_ae_txn_rec.accounting_period_id;

                        l_stmt_num := 250;

                        SELECT NVL(MAX(cost_group_id),-1)
                        INTO   l_txfr_cost_group_id
                        FROM   cst_cost_group_assignments
                        WHERE  organization_id = i_ae_txn_rec.xfer_organization_id;

                        l_stmt_num := 255;

                        BEGIN
                            SELECT legal_entity
                            INTO l_txfr_legal_entity
                            FROM cst_cost_groups
                            WHERE cost_group_id = l_txfr_cost_group_id;

                            EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                               l_txfr_legal_entity := NULL;
                        END;

                        l_stmt_num := 260;

                        /* Check for the same LE/CT combination */
                        SELECT count(*)
                        INTO   l_same_le_ct
                        FROM   cst_le_cost_types
                        WHERE  legal_entity = l_txfr_legal_entity
                        AND    cost_type_id = i_ae_txn_rec.cost_type_id;

                        l_stmt_num := 265;

                        IF (i_ae_txn_rec.legal_entity_id = l_txfr_legal_entity AND l_same_le_ct > 0 AND l_transfer_cost_flag = 'Y') THEN

                               /* PACP used: Use CPIC cost */
                               l_stmt_num := 270;

                                SELECT NVL(CPIC.item_cost,0)
                                INTO   l_pacp_pwac_cost
                                FROM   CST_PAC_ITEM_COSTS CPIC
                                WHERE  CPIC.INVENTORY_ITEM_ID = i_ae_txn_rec.inventory_item_id
                                AND    CPIC.COST_GROUP_ID     = i_ae_txn_rec.cost_group_id
                                AND    CPIC.PAC_PERIOD_ID     = i_ae_txn_rec.accounting_period_id;

                                IF g_debug_flag = 'Y' THEN
                                   fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                         ': Using PAC Absorption Cost: ' || l_pacp_pwac_cost);
                                END IF;

                                l_stmt_num := 272;
                                SELECT nvl(transfer_percentage,0),
                                       nvl(transfer_cost,0),
                                       nvl(transportation_cost,0)
                                INTO   l_txfr_percent,
                                       l_txfr_cost,
                                       l_trp_cost
                                FROM   mtl_material_transactions
                                WHERE  transaction_id = i_ae_txn_rec.transaction_id;

                                IF (l_txfr_percent <> 0) THEN
                                    l_txfr_credit := (l_txfr_percent * l_pacp_pwac_cost / 100);
                                ELSIF (l_txfr_cost <> 0) THEN
                                    l_txfr_credit := l_txfr_cost / abs(i_ae_txn_rec.primary_quantity);
                                ELSE
                                    l_txfr_credit := 0;
                                END IF;

                                l_stmt_num := 274;

                                /* Debit Receivables */
                                l_io_rcv_value := (l_pacp_pwac_cost +
                                                  (((l_trp_cost / abs(i_ae_txn_rec.primary_quantity))+ l_txfr_credit)));

                                l_ae_line_rec.transaction_value := l_io_rcv_value * abs(i_ae_txn_rec.primary_quantity);
                                l_ae_line_rec.resource_id := NULL;
                                l_ae_line_rec.cost_element_id := NULL;
                                l_ae_line_rec.ae_line_type := 10;    -- Receivables

                                insert_account (i_ae_txn_rec,
                                                i_ae_curr_rec,
                                                l_dr_flag,
                                                l_ae_line_rec,
                                                l_ae_line_tbl,
                                                l_err_rec);

                                -- check error
                                IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                                    RAISE process_error;
                                END IF;


                                l_stmt_num := 276;
                                /* Create entries for transfer credit and freight */

                                l_dr_flag := FALSE;

                                l_ae_line_rec.transaction_value := l_trp_cost;
                                l_ae_line_rec.account := l_io_freight_acct;
                                l_ae_line_rec.resource_id := NULL;
                                l_ae_line_rec.cost_element_id := NULL;
                                l_ae_line_rec.ae_line_type := 12;  -- freight account

                                /* Freight account entry */
                                IF (l_ae_line_rec.transaction_value <> 0) THEN

                                    insert_account (i_ae_txn_rec,
                                                    i_ae_curr_rec,
                                                    l_dr_flag,
                                                    l_ae_line_rec,
                                                    l_ae_line_tbl,
                                                    l_err_rec);

                                    -- check error
                                    IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                                        RAISE process_error;
                                    END IF;

                                END IF;

                                l_ae_line_rec.account := l_io_txfr_cr_acct;
                                l_ae_line_rec.transaction_value := (l_txfr_credit * abs(i_ae_txn_rec.primary_quantity));
                                l_ae_line_rec.resource_id := NULL;
                                l_ae_line_rec.cost_element_id := NULL;
                                l_ae_line_rec.ae_line_type := 11;  -- transfer credit

                                l_stmt_num := 278;

                                /* Transfer credit entry */
                                IF (l_ae_line_rec.transaction_value <> 0) THEN

                                    insert_account (i_ae_txn_rec,
                                                    i_ae_curr_rec,
                                                    l_dr_flag,
                                                    l_ae_line_rec,
                                                    l_ae_line_tbl,
                                                    l_err_rec);

                                    -- check error
                                    IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                                        RAISE process_error;
                                    END IF;

                                END IF;

                       ELSE /*  IF (i_ae_txn_rec.legal_entity_id = l_txfr_legal_entity AND l_same_le_ct > 0 AND l_transfer_cost_flag = 'Y') THEN */

                         IF (i_ae_txn_rec.legal_entity_id = l_txfr_legal_entity AND l_same_le_ct > 0 AND l_prev_period_id <> -1) THEN

                           l_stmt_num := 280;
                           l_use_prev_period_cost := 1;

                           /* Get prior period PWAC Cost */
                                BEGIN
                                    SELECT nvl(CPIC.item_cost,0)
                                      INTO l_prev_period_pwac_cost
                                      FROM CST_PAC_ITEM_COSTS CPIC
                                     WHERE CPIC.INVENTORY_ITEM_ID = i_ae_txn_rec.inventory_item_id
                                       AND CPIC.COST_GROUP_ID     = i_ae_txn_rec.cost_group_id
                                       AND CPIC.PAC_PERIOD_ID     = l_prev_period_id;
                                EXCEPTION
                                when no_data_found then
                                    /* Use perpetual cost if prior period cost is not available */
                                    l_use_prev_period_cost := 0;
                                END;
                         ELSE
                         /* Use perpetual cost if prior period cost is not available or if the cost groups are not in the same LE/CT. */
                           l_use_prev_period_cost := 0;
                         END IF;

                         IF (l_use_prev_period_cost = 1) THEN
                                l_stmt_num := 282;

                                IF g_debug_flag = 'Y' THEN
                                   fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                                        ': Using prior period PWAC cost: ' || l_prev_period_pwac_cost);
                                END IF;

                                l_stmt_num := 285;

                                SELECT nvl(transfer_percentage,0),
                                       nvl(transfer_cost,0),
                                       nvl(transportation_cost,0)
                                INTO   l_txfr_percent,
                                       l_txfr_cost,
                                       l_trp_cost
                                FROM   mtl_material_transactions
                                WHERE  transaction_id = i_ae_txn_rec.transaction_id;

                                IF (l_txfr_percent <> 0) THEN
                                    l_txfr_credit := (l_txfr_percent * l_prev_period_pwac_cost / 100);
                                ELSIF (l_txfr_cost <> 0) THEN
                                    l_txfr_credit := l_txfr_cost / abs(i_ae_txn_rec.primary_quantity);
                                ELSE
                                    l_txfr_credit := 0;
                                END IF;

                                l_stmt_num := 290;

                                /* Debit Receivables */
                                l_io_rcv_value := (l_prev_period_pwac_cost +
                                                  (((l_trp_cost / abs(i_ae_txn_rec.primary_quantity))+ l_txfr_credit)));

                                l_ae_line_rec.transaction_value := l_io_rcv_value * abs(i_ae_txn_rec.primary_quantity);
                                l_ae_line_rec.resource_id := NULL;
                                l_ae_line_rec.cost_element_id := NULL;
                                l_ae_line_rec.ae_line_type := 10;   -- Receivables

                                l_stmt_num := 295;

                                insert_account (i_ae_txn_rec,
                                                i_ae_curr_rec,
                                                l_dr_flag,
                                                l_ae_line_rec,
                                                l_ae_line_tbl,
                                                l_err_rec);

                                -- check error
                                IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                                    RAISE process_error;
                                END IF;

                                l_stmt_num := 300;

                                /* Create entries for transfer credit,freight and transfer variance */

                                l_dr_flag := FALSE;

                                l_ae_line_rec.transaction_value := l_trp_cost;
                                l_ae_line_rec.account := l_io_freight_acct;
                                l_ae_line_rec.resource_id := NULL;
                                l_ae_line_rec.cost_element_id := NULL;
                                l_ae_line_rec.ae_line_type := 12;  -- freight account

                                /* Freight account entry */
                                IF (l_ae_line_rec.transaction_value <> 0) THEN

                                    insert_account (i_ae_txn_rec,
                                                    i_ae_curr_rec,
                                                    l_dr_flag,
                                                    l_ae_line_rec,
                                                    l_ae_line_tbl,
                                                    l_err_rec);

                                    -- check error
                                    IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                                        RAISE process_error;
                                    END IF;

                                    l_stmt_num := 305;

                                END IF;

                                l_ae_line_rec.account := l_io_txfr_cr_acct;
                                l_ae_line_rec.transaction_value := (l_txfr_credit * abs(i_ae_txn_rec.primary_quantity));
                                l_ae_line_rec.resource_id := NULL;
                                l_ae_line_rec.cost_element_id := NULL;
                                l_ae_line_rec.ae_line_type := 11;  -- transfer credit

                                l_stmt_num := 310;

                                /* Transfer credit entry */
                                IF (l_ae_line_rec.transaction_value <> 0) THEN

                                    insert_account (i_ae_txn_rec,
                                                    i_ae_curr_rec,
                                                    l_dr_flag,
                                                    l_ae_line_rec,
                                                    l_ae_line_tbl,
                                                    l_err_rec);

                                    -- check error
                                    IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                                        RAISE process_error;
                                    END IF;

                                END IF;

                                l_stmt_num := 315;

                                SELECT sum(nvl(actual_cost,0))
                                INTO   l_mpacd_cost
                                FROM   mtl_pac_actual_cost_details
                                WHERE  transaction_id = i_ae_txn_rec.transaction_id
                                AND    pac_period_id = i_ae_txn_rec.accounting_period_id
                                AND    cost_group_id = i_ae_txn_rec.cost_group_id;

                                l_txfr_var_value := l_io_rcv_value - (l_mpacd_cost + l_txfr_credit + l_trp_cost/abs(i_ae_txn_rec.primary_quantity));

                                IF (sign(l_txfr_var_value) = 1) THEN
                                  l_dr_flag := FALSE;
                                ELSIF (sign(l_txfr_var_value) = -1) THEN
                                  l_dr_flag := TRUE;
                                ELSE
                                  l_dr_flag := NULL;
                                END IF;

                                l_txfr_var_value := abs(l_txfr_var_value);

                                IF (l_dr_flag IS NOT NULL) THEN

                                    IF (l_io_txfr_var_acct = -1) THEN
                                      RAISE no_interorg_profit_acct_error;
                                    END IF;

                                    /* Transfer variance entry */
                                    l_ae_line_rec.account := l_io_txfr_var_acct;
                                    l_ae_line_rec.transaction_value := l_txfr_var_value  * abs(i_ae_txn_rec.primary_quantity);
                                    l_ae_line_rec.resource_id := NULL;
                                    l_ae_line_rec.cost_element_id := NULL;
                                    l_ae_line_rec.ae_line_type := 34;   -- Interorg profit in inventory

                                    l_stmt_num := 320;

                                    insert_account (i_ae_txn_rec,
                                                    i_ae_curr_rec,
                                                    l_dr_flag,
                                                    l_ae_line_rec,
                                                    l_ae_line_tbl,
                                                    l_err_rec);

                                    -- check error
                                    IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                                        RAISE process_error;
                                    END IF;

                                END IF; /* (l_dr_flag IS NOT NULL) */

                        ELSE /* IF (l_use_prev_period_cost = 1) THEN */
                           /* Different LE/CT, or No Prior Period - Perpetual side:MTA Entries to be used */

                          -- Processing the process-discrete txns
                          -- INVCONV sikhanna
                          l_stmt_num := 322;
                          SELECT MOD(SUM(DECODE(process_enabled_flag,'Y',1,2)), 2)
                          INTO l_pd_txfr_ind
                          FROM MTL_PARAMETERS MP
                          WHERE MP.ORGANIZATION_ID = i_ae_txn_rec.xfer_organization_id
                          OR MP.ORGANIZATION_ID    = i_ae_txn_rec.organization_id;

                          l_stmt_num := 324;

                          IF (l_pd_txfr_ind = 1) THEN -- Process-Discrete X-fers

                            IF g_debug_flag = 'Y' THEN
                              fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                         ': Process-Discrete X-fers: ');
                            END IF;

                            SELECT mip.interorg_receivables_account,
                                   mmt.transportation_dist_account,
                                   mip.interorg_transfer_cr_account,
                                   nvl(mip.interorg_profit_account, -1)
                            INTO   l_io_rcv_acct,
                                   l_io_freight_acct,
                                   l_io_txfr_cr_acct,
                                   l_io_txfr_var_acct
                            FROM   mtl_interorg_parameters mip,mtl_material_transactions mmt
                            WHERE  mip.from_organization_id = i_ae_txn_rec.organization_id -- INVCONV condition is opposite
                            AND    mip.to_organization_id = i_ae_txn_rec.xfer_organization_id
                            AND    mmt.transaction_id = i_ae_txn_rec.transaction_id;

                            IF (l_io_txfr_var_acct = -1) THEN
                              RAISE no_interorg_profit_acct_error;
                            END IF;

                            l_stmt_num := 326;

                            SELECT nvl(transfer_price,0),
                                   nvl(transportation_cost,0)
                            INTO   l_txfr_cost, -- transfer price
                                   l_trp_cost   -- transportation cost
                            FROM   mtl_material_transactions mmt
                            WHERE  mmt.transaction_id = i_ae_txn_rec.transaction_id;

                            l_stmt_num := 328;
                            /* create debit entries */

                            l_dr_flag := true;

                            /* Debit Receivables at Transfer Price */
                            l_ae_line_rec.transaction_value := (l_txfr_cost  * abs(i_ae_txn_rec.primary_quantity));
                            l_ae_line_rec.account := l_io_rcv_acct;
                            l_ae_line_rec.resource_id := NULL;
                            l_ae_line_rec.cost_element_id := NULL;
                            l_ae_line_rec.ae_line_type := 10;  -- Receivables

                            l_stmt_num := 330;

                            insert_account (i_ae_txn_rec,
                                            i_ae_curr_rec,
                                            l_dr_flag,
                                            l_ae_line_rec,
                                            l_ae_line_tbl,
                                            l_err_rec);
                            -- check error
                            IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                             RAISE process_error;
                            END IF;

                            l_stmt_num := 332;

                            /* create credit entries */

                            l_dr_flag := NOT l_dr_flag;

                            l_ae_line_rec.transaction_value := l_trp_cost;
                            l_ae_line_rec.account := l_io_freight_acct;
                            l_ae_line_rec.resource_id := NULL;
                            l_ae_line_rec.cost_element_id := NULL;
                            l_ae_line_rec.ae_line_type := 12;   -- freight account

                            l_stmt_num := 334;

                            /* freight account entry */
                            IF (l_ae_line_rec.transaction_value <> 0) THEN

                                insert_account (i_ae_txn_rec,
                                                i_ae_curr_rec,
                                                l_dr_flag,
                                                l_ae_line_rec,
                                                l_ae_line_tbl,
                                                l_err_rec);
                                -- check error
                                IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                                 RAISE process_error;
                                END IF;

                            END IF;

                            l_stmt_num := 336;

                            SELECT NVL(CPIC.item_cost,0)
                            INTO   l_pwac_cost
                            FROM   CST_PAC_ITEM_COSTS CPIC
                            WHERE  CPIC.INVENTORY_ITEM_ID = i_ae_txn_rec.inventory_item_id
                            AND    CPIC.COST_GROUP_ID     = i_ae_txn_rec.cost_group_id
                            AND    CPIC.PAC_PERIOD_ID     = i_ae_txn_rec.accounting_period_id;

                            l_profit_or_loss := l_txfr_cost - (l_pwac_cost + (l_trp_cost / abs(i_ae_txn_rec.primary_quantity)));

                            IF l_profit_or_loss <> 0 THEN

                                IF l_profit_or_loss < 0 THEN -- Making a loss
                                    l_dr_flag := not l_dr_flag; -- Debit interorg profit
                                END IF;

                                l_stmt_num := 338;

                                l_ae_line_rec.transaction_value := abs(l_profit_or_loss) * abs(i_ae_txn_rec.primary_quantity);
                                l_ae_line_rec.account := l_io_txfr_var_acct;
                                l_ae_line_rec.resource_id := NULL;
                                l_ae_line_rec.cost_element_id := NULL;
                                l_ae_line_rec.ae_line_type := 34;   -- interorg profit account

                                insert_account (i_ae_txn_rec,
                                                i_ae_curr_rec,
                                                l_dr_flag,
                                                l_ae_line_rec,
                                                l_ae_line_tbl,
                                                l_err_rec);
                                -- check error
                                IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                                 RAISE process_error;
                                END IF;

                              END IF;


                          ELSE /* Discrete-Discrete X-Fers */


                            l_stmt_num := 340;
                            IF g_debug_flag = 'Y' THEN
                              fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                         ': Using MTA cost: ');
                            END IF;


                            BEGIN
                             SELECT nvl(SUM(ABS(NVL(base_transaction_value, 0))),0)
                             INTO l_perp_ship_value
                             FROM mtl_transaction_accounts mta
                             WHERE mta.transaction_id = i_ae_txn_rec.transaction_id
                             and mta.organization_id = i_ae_txn_rec.organization_id
                             and mta.accounting_line_type IN (1,2,14)
                             and mta.base_transaction_value < 0;
                            EXCEPTION
                             WHEN no_data_found THEN
                                 l_perp_ship_value := 0;
                            END;

                            l_stmt_num := 342;

                            SELECT nvl(transfer_percentage,0),nvl(transfer_cost,0),nvl(transportation_cost,0)
                            INTO l_txfr_percent,l_txfr_cost,l_trp_cost
                            FROM mtl_material_transactions
                            WHERE transaction_id = i_ae_txn_rec.transaction_id;

                            IF (l_txfr_percent <> 0) THEN
                                l_txfr_credit := (l_txfr_percent * l_perp_ship_value) / (100 * abs(i_ae_txn_rec.primary_quantity));
                            ELSIF (l_txfr_cost <> 0) THEN
                                l_txfr_credit := l_txfr_cost / abs(i_ae_txn_rec.primary_quantity);
                            ELSE
                                l_txfr_credit := 0;
                            END IF;

                            l_io_rcv_value := l_txfr_credit + (l_perp_ship_value + l_trp_cost)/abs(i_ae_txn_rec.primary_quantity);
--((l_other_ele_costs / abs(i_ae_txn_rec.primary_quantity)) +
--                                               ((((l_mat_ovhd + l_trp_cost)/ abs(i_ae_txn_rec.primary_quantity)) + l_txfr_credit)));

                            l_ae_line_rec.transaction_value := l_io_rcv_value  * abs(i_ae_txn_rec.primary_quantity);
                            l_ae_line_rec.account := l_io_rcv_acct;
                            l_ae_line_rec.resource_id := NULL;
                            l_ae_line_rec.cost_element_id := NULL;
                            l_ae_line_rec.ae_line_type := 10;  -- Receivables

                            l_stmt_num := 344;

                            /* Debit receivables */
                            insert_account (i_ae_txn_rec,
                                            i_ae_curr_rec,
                                            l_dr_flag,
                                            l_ae_line_rec,
                                            l_ae_line_tbl,
                                            l_err_rec);

                            -- check error
                            IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                                RAISE process_error;
                            END IF;

                            /* Create entries for transfer credit,freight and transfer variance */

                            l_dr_flag := FALSE;

                            l_ae_line_rec.transaction_value := l_trp_cost;
                            l_ae_line_rec.account := l_io_freight_acct;
                            l_ae_line_rec.resource_id := NULL;
                            l_ae_line_rec.cost_element_id := NULL;
                            l_ae_line_rec.ae_line_type := 12;   -- freight account

                            l_stmt_num := 345;

                            /* Freight account entry */
                            IF (l_ae_line_rec.transaction_value <> 0) THEN

                                 insert_account (i_ae_txn_rec,
                                                 i_ae_curr_rec,
                                                 l_dr_flag,
                                                 l_ae_line_rec,
                                                 l_ae_line_tbl,
                                                 l_err_rec);

                                -- check error
                                IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                                    RAISE process_error;
                                END IF;

                            END IF;

                            l_ae_line_rec.account := l_io_txfr_cr_acct;
                            l_ae_line_rec.transaction_value := (l_txfr_credit * abs(i_ae_txn_rec.primary_quantity));
                            l_ae_line_rec.resource_id := NULL;
                            l_ae_line_rec.cost_element_id := NULL;
                            l_ae_line_rec.ae_line_type := 11;   -- transfer credit

                            l_stmt_num := 350;

                            /* transfer credit entry */
                            IF (l_ae_line_rec.transaction_value <> 0) THEN

                                 insert_account (i_ae_txn_rec,
                                                 i_ae_curr_rec,
                                                 l_dr_flag,
                                                 l_ae_line_rec,
                                                 l_ae_line_tbl,
                                                 l_err_rec);
                                -- check error
                                IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                                    RAISE process_error;
                                END IF;

                            END IF;

                            l_stmt_num := 355;
                            SELECT sum(nvl(actual_cost,0))
                            INTO   l_mpacd_cost
                            FROM   mtl_pac_actual_cost_details
                            WHERE  transaction_id = i_ae_txn_rec.transaction_id
                            AND    pac_period_id = i_ae_txn_rec.accounting_period_id
                            AND    cost_group_id = i_ae_txn_rec.cost_group_id;

                            /* Transfer variance */

                            l_txfr_var_value := l_io_rcv_value - (l_mpacd_cost + l_txfr_credit + l_trp_cost/abs(i_ae_txn_rec.primary_quantity));

                            IF (sign(l_txfr_var_value) = 1) THEN
                              l_dr_flag := FALSE;
                            ELSIF (sign(l_txfr_var_value) = -1) THEN
                              l_dr_flag := TRUE;
                            ELSE
                              l_dr_flag := NULL;
                            END IF;

                            l_txfr_var_value := abs(l_txfr_var_value);

                            IF (l_dr_flag IS NOT NULL) THEN

                                 IF (l_io_txfr_var_acct = -1) THEN
                                   RAISE no_interorg_profit_acct_error;
                                 END IF;

                                 /* transfer variance entry */
                                 l_ae_line_rec.account := l_io_txfr_var_acct;
                                 l_ae_line_rec.transaction_value := l_txfr_var_value  * abs(i_ae_txn_rec.primary_quantity);
                                 l_ae_line_rec.resource_id := NULL;
                                 l_ae_line_rec.cost_element_id := NULL;
                                 l_ae_line_rec.ae_line_type := 34; -- Interorg profit in inventory

                                 l_stmt_num := 360;

                                 insert_account (i_ae_txn_rec,
                                                 i_ae_curr_rec,
                                                 l_dr_flag,
                                                 l_ae_line_rec,
                                                 l_ae_line_tbl,
                                                 l_err_rec);
                                -- check error
                                IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                                    RAISE process_error;
                                END IF;

                                 l_stmt_num := 365;

                            END IF;

                          END IF; /* (l_pd_txfr_ind = 1); Process-Discrete X-fers */

                        END IF; /* IF (l_use_prev_period_cost = 1) */

                      END IF; /*  IF (i_ae_txn_rec.legal_entity_id = l_txfr_legal_entity AND l_same_le_ct > 0 AND l_transfer_cost_flag = 'Y') THEN */

                 END IF; /*All cases of ordinary interorg shipments handled */

            END IF; /* End for interorg shipments */

        /* Else - Receipt transactions */
        ELSIF ( i_ae_txn_rec.txn_action_id in (12,22) OR (i_ae_txn_rec.txn_action_id = 3 AND i_ae_txn_rec.primary_quantity > 0)) THEN

           l_stmt_num := 370;

           BEGIN
               /* Change the Query for the performance. Bug 4586534 */
               SELECT nvl(fnd_profile.value('CST_TRANSFER_PRICING_OPTION'), 0)
               INTO   l_tprice_option
               FROM   mtl_intercompany_parameters MIP
               WHERE  fnd_profile.value('INV_INTERCOMPANY_INVOICE_INTERNAL_ORDER') = 1
               AND  ( select  count(1)
                            FROM hr_organization_information HOI
                            where   HOI.organization_id = decode(i_ae_txn_rec.txn_action_id, 21,
                                                                 i_ae_txn_rec.organization_id,
                                                                 i_ae_txn_rec.xfer_organization_id)
                            AND    HOI.org_information_context = 'Accounting Information'
                            AND    MIP.ship_organization_id = to_number(HOI.org_information3)
                            AND    ROWNUM < 2) > 0

               AND  (select  count(1)
                           FROM hr_organization_information HOI2
                           WHERE HOI2.organization_id = decode(i_ae_txn_rec.txn_action_id, 21,
                                                               i_ae_txn_rec.xfer_organization_id,
                                                               i_ae_txn_rec.organization_id)
                           AND    HOI2.org_information_context = 'Accounting Information'
                           AND    MIP.sell_organization_id = to_number(HOI2.org_information3)
                           AND    ROWNUM < 2) > 0
               AND    MIP.flow_type = 1;

               EXCEPTION
               WHEN NO_DATA_FOUND THEN
               l_tprice_option := -1; /* Chenged it to be -1, will toggle to 0 later */
           END;

            -- Processing the process-discrete txns
            -- INVCONV sikhanna START
            l_stmt_num := 372;
            SELECT MOD(SUM(DECODE(process_enabled_flag,'Y',1,2)), 2)
            INTO l_pd_txfr_ind
            FROM MTL_PARAMETERS MP
            WHERE MP.ORGANIZATION_ID = i_ae_txn_rec.xfer_organization_id
            OR MP.ORGANIZATION_ID    = i_ae_txn_rec.organization_id;

            /* Process-Discrete X-fers set the profile to 2 if ICR relations setup and in diff OU */
            /* l_tprice_option=-1 only when ICR is not set up and exception is thrown, then continue as normal */
            IF (l_pd_txfr_ind=1 and l_tprice_option <> -1) THEN -- OPM ST BUG 5351896

               l_stmt_num := 374;

               l_tprice_option := 2; /* Make it 2 to ignore the CST Transfer Price profile */

               IF g_debug_flag = 'Y' THEN
                  fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ' ICR Set up:process-discrete xfer');
               END IF;

            END IF;

            IF l_tprice_option = -1 THEN
               l_stmt_num := 376;
               l_tprice_option := 0; /* Toggle it to 0 as 0 is used later */
            END IF;
            -- INVCONV sikhanna END

            l_stmt_num := 378;

           /* Process Internal Orders */

           IF ((i_ae_txn_rec.txn_src_type_id IN (7,8)) AND (l_tprice_option IN (1,2))) THEN

              IF (l_fob_point = 2) THEN

                  IF (i_ae_txn_rec.cost_group_id = l_shipping_cg_id) THEN /* This is the sending CG */

                       l_stmt_num := 380;

                       IF g_debug_flag = 'Y' THEN
                          fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                   ': Receipt txn of Internal Order FOB Receipt - Sending Cost Group');
                       END IF;

                     IF (l_cg_exp_item <> 1) THEN

                       /* Debit COGS and credit Intransit */

                       l_stmt_num := 382;
                       -- Bug 5573993 - Derive the COGS account to break dependency on perpetual
                       -- code as if the trxn is not costed, mmt has incorrect account stamped

                       IF g_debug_flag = 'Y' THEN
                          fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                                    'Deriving COGS account');
                       END IF;

                       l_stmt_num := 61;

                       l_cogs_account := get_intercompany_account (i_ae_txn_rec => i_ae_txn_rec,
                                                                   o_ae_err_rec => l_err_rec);

                       IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                           RAISE process_error;
                       END IF;

                       IF g_debug_flag = 'Y' THEN
                          fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                                    'COGS Account ID: ' || l_cogs_account);
                       END IF;

                       -- Stamp all elemental accounts with the COGS account
                       l_acct_rec.mat_account := l_cogs_account;
                       l_acct_rec.mat_ovhd_account := l_cogs_account;
                       l_acct_rec.res_account := l_cogs_account;
                       l_acct_rec.osp_account := l_cogs_account;
                       l_acct_rec.ovhd_account := l_cogs_account;
                       l_acct_rec.account := l_cogs_account;

                       l_dr_flag := TRUE;

                       -- Debit COGS
                       -- ----------
                       l_stmt_num := 385;

                       CSTPAPBR.offset_accounts (i_ae_txn_rec,
                                                 i_ae_curr_rec,
                                                 2,    --- Acct Line Type
                                                 0,    --- Elemental Flag
                                                 0,    --- Ovhd Flag
                                                 l_dr_flag,
                                                 l_acct_rec,
                                                 l_ae_line_tbl,
                                                 l_err_rec);
                       -- check error
                       IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                           raise process_error;
                       END IF;

                       l_dr_flag := NOT l_dr_flag;

                       -- Credit Intransit
                       -- ----------------
                       l_stmt_num := 390;

                       CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                                    i_ae_curr_rec,
                                                    "FALSE",   --- Exp Flag
                                                     null,      --- Exp Acct
                                                     l_dr_flag,
                                                     l_ae_line_tbl,
                                                     l_err_rec,
                                                     1);
                        -- check error
                        IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                            RAISE process_error;
                        END IF;

                     END IF; /*  IF (l_cg_exp_item <> 1) THEN */

                  ELSE /* This is the receiving CG */

                         l_stmt_num := 395;

                         IF g_debug_flag = 'Y' THEN
                           fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                   ': Receipt txn of Internal Order FOB Receipt - Receiving Cost Group');
                         END IF;

                         /* Credit Intercompany Accrual Account */

                         SELECT nvl(expense_account_id,-1)
                         INTO   l_accrual_account
                         FROM   mtl_material_transactions
                         WHERE  transaction_id = i_ae_txn_rec.transaction_id;

                         l_stmt_num := 396;
                         -- Bug 5573993 - Derive the Intercompany account to break dependency on perpetual
                         -- code as if the trxn is not costed, mmt has incorrect or no account stamped

                         IF g_debug_flag = 'Y' THEN
                           fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                                  'Deriving intecompany account');
                         END IF;

                         l_accrual_account := get_intercompany_account (i_ae_txn_rec => i_ae_txn_rec,
                                                                        o_ae_err_rec => l_err_rec);

                         if (l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
                           raise process_error;
                         end if;

                         IF g_debug_flag = 'Y' THEN
                           fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                                    'Intercompany Account ID: ' || l_accrual_account);
                         END IF;

                         l_dr_flag := FALSE;

                         l_stmt_num := 397;
                         select count(transaction_id)
                         into l_mat_ovhd_exists
                         from mtl_pac_actual_cost_details
                         where transaction_id = i_ae_txn_rec.transaction_id
                         and pac_period_id = i_ae_txn_rec.accounting_period_id
                         and cost_group_id = i_ae_txn_rec.cost_group_id
                         and cost_element_id = 2
                         and level_type = 1;

                         if (l_mat_ovhd_exists > 0) then
                            l_stmt_num := 400;
                            ovhd_accounts(i_ae_txn_rec,
                                          i_ae_curr_rec,
                                          l_dr_flag,
                                          l_ae_line_tbl,
                                          l_err_rec);
                           -- check error
                           if (l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
                             raise process_error;
                           end if;
                         end if;

                           -- Credit Intercompany Accrual
                           l_stmt_num := 401;

                           SELECT  NVL(mmt.transfer_price,0)
                           INTO    l_transfer_price
                           FROM    mtl_material_transactions MMT
                           WHERE   MMT.transaction_id = i_ae_txn_rec.transaction_id;

                           IF g_debug_flag = 'Y' THEN
                              fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                ': Cr Intercompany Accrual @ : ' || l_transfer_price);
                           END IF;

                           l_ae_line_rec.account := l_accrual_account;
                           l_ae_line_rec.transaction_value := abs(i_ae_txn_rec.primary_quantity) * l_transfer_price;
                           l_ae_line_rec.resource_id := NULL;
                           l_ae_line_rec.cost_element_id := NULL;
                           l_ae_line_rec.ae_line_type := 2;

                           insert_account (i_ae_txn_rec,
                                           i_ae_curr_rec,
                                           l_dr_flag,
                                           l_ae_line_rec,
                                           l_ae_line_tbl,
                                           l_err_rec);

                           -- check error
                           IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                               RAISE process_error;
                           END IF;

                         IF (l_tprice_option = 2) THEN
                            l_stmt_num := 402;

                            IF g_debug_flag = 'Y' THEN
                               fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                           ': CST: Transfer Price Option = Yes, Price As Incoming Cost');
                            END IF;

                          ELSIF (l_tprice_option = 1) THEN
                            l_stmt_num := 404;
                            IF g_debug_flag = 'Y' THEN
                               fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                 ': CST: Transfer Price Option = Yes, Price Not As Incoming Cost');
                            END IF;

                           -- Debit/Credit Profit in Inventory
                           l_stmt_num := 412;

                           SELECT sum(nvl(transaction_cost,0))
                           INTO   l_mptcd_cost
                           FROM   mtl_pac_txn_cost_details
                           WHERE  transaction_id = i_ae_txn_rec.transaction_id
                           AND    pac_period_id = i_ae_txn_rec.accounting_period_id
                           AND    cost_group_id = i_ae_txn_rec.cost_group_id;

                           l_profit_in_inv_value := l_mptcd_cost - l_transfer_price;

                           IF (sign(l_profit_in_inv_value) = 1) THEN
                                l_dr_flag := FALSE;
                            ELSIF (sign(l_profit_in_inv_value) = -1) THEN
                                l_dr_flag := TRUE;
                            ELSE
                                l_dr_flag := NULL;
                            END IF;

                            l_profit_in_inv_value := abs(l_profit_in_inv_value);

                            IF (l_dr_flag IS NOT NULL) THEN

                                    l_stmt_num := 417;
                                    SELECT nvl(profit_in_inv_account, -1)
                                    INTO   l_profit_in_inv_account
                                    FROM   mtl_interorg_parameters
                                    WHERE  from_organization_id = i_ae_txn_rec.xfer_organization_id
                                    AND    to_organization_id = i_ae_txn_rec.organization_id;

                                    IF (l_profit_in_inv_account = -1) THEN
                                       RAISE no_profit_in_inv_acct_error;
                                    END IF;

                                    /* Profit in Inventory entry */
                                    l_ae_line_rec.account := l_profit_in_inv_account;
                                    l_ae_line_rec.transaction_value := l_profit_in_inv_value  * abs(i_ae_txn_rec.primary_quantity);
                                    l_ae_line_rec.resource_id := NULL;
                                    l_ae_line_rec.cost_element_id := NULL;
                                    l_ae_line_rec.ae_line_type := 30;   -- Profit in Inventory

                                    l_stmt_num := 419;

                                    insert_account (i_ae_txn_rec,
                                                    i_ae_curr_rec,
                                                    l_dr_flag,
                                                    l_ae_line_rec,
                                                    l_ae_line_tbl,
                                                    l_err_rec);

                                    -- check error
                                    IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                                        RAISE process_error;
                                    END IF;

                            END IF; /* (l_dr_flag IS NOT NULL) */

                         END IF; /* (l_tprice_option = 2) */

                        l_dr_flag := TRUE;

                       /* Debit Inventory - OnHand */

                        l_stmt_num := 420;

                        -- Debit On-hand (if expense, then use expense account)
                        -- -----------------------------------------------------
                        IF (l_exp_flg) THEN
                           CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                                        i_ae_curr_rec,
                                                        l_exp_flg, -- Exp Flag
                                                        l_exp_account, -- Exp Acct
                                                        l_dr_flag,
                                                        l_ae_line_tbl,
                                                        l_err_rec);
                        ELSE
                           CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                                        i_ae_curr_rec,
                                                        "FALSE", -- Exp Flag
                                                        null, -- Exp Acct
                                                        l_dr_flag,
                                                        l_ae_line_tbl,
                                                        l_err_rec);
                        END IF;

                        -- check error
                        IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                            RAISE process_error;
                        END IF;

                  END IF;

              ELSIF (l_fob_point = 1) THEN /* Internal Order FOBS */

                    l_stmt_num := 422;

                    IF g_debug_flag = 'Y' THEN
                           fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                   ': Receipt txn of Internal Order FOB Shipment - Receiving Cost Group');
                    END IF;


                  IF (l_cg_exp_item <> 1) THEN
                     /* This can only be the receiving CG
                        Debit OnHand and Credit Intransit */

                    l_dr_flag := TRUE;

                    -- Debit On-hand (if expense, then use expense account)
                    -- -----------------------------------------------------
                    IF (l_exp_flg) THEN
                        CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                                     i_ae_curr_rec,
                                                     l_exp_flg, -- Exp Flag
                                                     l_exp_account, -- Exp Acct
                                                     l_dr_flag,
                                                     l_ae_line_tbl,
                                                     l_err_rec);
                    ELSE
                        CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                                     i_ae_curr_rec,
                                                     "FALSE", -- Exp Flag
                                                     null, -- Exp Acct
                                                     l_dr_flag,
                                                     l_ae_line_tbl,
                                                     l_err_rec);
                    END IF;

                    -- check error
                    IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                        RAISE process_error;
                    END IF;

                    l_dr_flag := not l_dr_flag;

                    -- Credit Intransit
                    -- ----------------
                    l_stmt_num := 424;

                    CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                                 i_ae_curr_rec,
                                                 "FALSE",   --- Exp Flag
                                                  null,      --- Exp Acct
                                                 l_dr_flag,
                                                 l_ae_line_tbl,
                                                 l_err_rec,
                                                 1);
                    -- check error
                    IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                        RAISE process_error;
                    END IF;

                  END IF; /* IF (l_cg_exp_item <> 1) THEN */

              END IF;

                -- INVCONV sikhanna : exclude logical txns. Taken care at the end.
           ELSIF (i_ae_txn_rec.txn_action_id not in (15,22)) THEN /* Ordinary Interorg receipts */

                l_stmt_num := 426;

                IF g_debug_flag = 'Y' THEN
                   fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                   ': Interorg Receipt transaction');
                END IF;

                IF ((i_ae_txn_rec.cost_group_id <> l_shipping_cg_id) AND l_fob_point = 2) THEN /* This is the receiving CG for FOBR */

                     l_stmt_num := 428;

                     IF g_debug_flag = 'Y' THEN
                        fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                   ': Receipt txn of FOB Receipt - Receiving Cost Group');
                     END IF;

                     -- Processing the process-discrete txns
                     -- INVCONV sikhanna
                     SELECT MOD(SUM(DECODE(process_enabled_flag,'Y',1,2)), 2)
                     INTO   l_pd_txfr_ind
                     FROM   MTL_PARAMETERS MP
                     WHERE  MP.ORGANIZATION_ID = i_ae_txn_rec.xfer_organization_id
                            OR MP.ORGANIZATION_ID    = i_ae_txn_rec.organization_id;

                     IF g_debug_flag = 'Y' THEN
                           fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                     ': Process-isc Ind: ' || l_pd_txfr_ind);
                     END IF;

                     /* Process OPM-Discrete transfers here as the accouting distribution template is same INVCONV*/

                      /* Credit Payables and debit OnHand Inventory */

                      l_dr_flag := TRUE;

                      -- Debit On-hand (if expense, then use expense account)
                      -- -----------------------------------------------------
                         IF (l_exp_flg) THEN
                            CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                                        i_ae_curr_rec,
                                                        l_exp_flg, -- Exp Flag
                                                        l_exp_account, -- Exp Acct
                                                        l_dr_flag,
                                                        l_ae_line_tbl,
                                                        l_err_rec);
                         ELSE
                            CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                                        i_ae_curr_rec,
                                                        "FALSE", -- Exp Flag
                                                        null, -- Exp Acct
                                                        l_dr_flag,
                                                        l_ae_line_tbl,
                                                        l_err_rec);
                         END IF;

                         -- check error
                         IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                             RAISE process_error;
                         END IF;

                         l_dr_flag := not l_dr_flag;

                         l_stmt_num := 430;

                         /* Absorb MOH if exists */

                         select count(transaction_id)
                         into l_mat_ovhd_exists
                         from mtl_pac_actual_cost_details
                         where transaction_id = i_ae_txn_rec.transaction_id
                         and pac_period_id = i_ae_txn_rec.accounting_period_id
                         and cost_group_id = i_ae_txn_rec.cost_group_id
                         and cost_element_id = 2
                         and level_type = 1;

                         l_stmt_num := 432;
                         if (l_mat_ovhd_exists > 0) then
                            ovhd_accounts(i_ae_txn_rec,
                                          i_ae_curr_rec,
                                          l_dr_flag,
                                          l_ae_line_tbl,
                                          l_err_rec);
                           -- check error
                           if (l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
                             raise process_error;
                           end if;
                         end if;

                         l_stmt_num := 434;
                         SELECT mip.interorg_payables_account
                         INTO   l_io_pay_acct
                         FROM   mtl_interorg_parameters mip
                         WHERE  mip.from_organization_id = i_ae_txn_rec.xfer_organization_id
                         AND    mip.to_organization_id = i_ae_txn_rec.organization_id;

                         l_stmt_num := 435;

                         SELECT sum(nvl(transaction_cost,0))
                         INTO l_mptcd_cost
                         FROM mtl_pac_txn_cost_details
                         WHERE transaction_id = i_ae_txn_rec.transaction_id
                         AND pac_period_id = i_ae_txn_rec.accounting_period_id
                         AND cost_group_id = i_ae_txn_rec.cost_group_id;

                         l_ae_line_rec.account := l_io_pay_acct;
                         l_ae_line_rec.transaction_value := (l_mptcd_cost * abs(i_ae_txn_rec.primary_quantity));
                         l_ae_line_rec.resource_id := NULL;
                         l_ae_line_rec.cost_element_id := NULL;
                         l_ae_line_rec.ae_line_type := 9;  -- Payables

                         l_stmt_num := 440;

                         /* Credit Payables */
                         insert_account (i_ae_txn_rec,
                                         i_ae_curr_rec,
                                         l_dr_flag,
                                         l_ae_line_rec,
                                         l_ae_line_tbl,
                                         l_err_rec);
                         -- check error
                         IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                             RAISE process_error;
                         END IF;

                ELSIF ((i_ae_txn_rec.cost_group_id = l_shipping_cg_id) AND l_fob_point = 2) THEN /* This is the sending CG for FOBR */

                       l_stmt_num := 445;

                       IF g_debug_flag = 'Y' THEN
                        fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                   ': Receipt txn of FOB Receipt - Shipping Cost Group');
                       END IF;

                       SELECT mip.interorg_receivables_account,
                              mmt.transportation_dist_account,
                              mip.interorg_transfer_cr_account,
                              nvl(mip.interorg_profit_account, -1)
                       INTO   l_io_rcv_acct,
                              l_io_freight_acct,
                              l_io_txfr_cr_acct,
                              l_io_txfr_var_acct
                       FROM   mtl_interorg_parameters mip,mtl_material_transactions mmt
                       WHERE  mip.from_organization_id = i_ae_txn_rec.xfer_organization_id
                       AND    mip.to_organization_id = i_ae_txn_rec.organization_id
                       AND    mmt.transaction_id = i_ae_txn_rec.transaction_id;

                       IF (l_io_txfr_var_acct = -1) THEN
                              RAISE no_interorg_profit_acct_error;
                       END IF;

                       /* Debit Receivables and Credit Intransit */

                        /* Credit Intransit */

                        l_stmt_num := 450;

                        l_dr_flag := FALSE;

                        IF (l_cg_exp_item = 1) THEN
                           /* Credit Expense */
                           CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                                       i_ae_curr_rec,
                                                       l_exp_flg, -- Exp Flag
                                                       l_exp_account, -- Exp Acct
                                                       l_dr_flag,
                                                       l_ae_line_tbl,
                                                       l_err_rec);
                        ELSE
                           /* Credit Inventory - Intransit */
                          CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                                    i_ae_curr_rec,
                                                    "FALSE",   --- Exp Flag
                                                    null,      --- Exp Acct
                                                    l_dr_flag,
                                                    l_ae_line_tbl,
                                                    l_err_rec,
                                                    1);

                        END IF;

                        -- check error
                        IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                            RAISE process_error;
                        END IF;

                       l_stmt_num := 455;

                       SELECT TRANSFER_COST_FLAG
                       INTO l_transfer_cost_flag
                       FROM CST_LE_COST_TYPES
                       WHERE LEGAL_ENTITY = i_ae_txn_rec.legal_entity_id
                       AND COST_TYPE_ID = i_ae_txn_rec.cost_type_id;

                       l_stmt_num := 460;

                       SELECT nvl(max(cpp.pac_period_id), -1)
                       INTO   l_prev_period_id
                       FROM   cst_pac_periods cpp
                       WHERE  cpp.cost_type_id = i_ae_txn_rec.cost_type_id
                       AND    cpp.legal_entity = i_ae_txn_rec.legal_entity_id
                       AND    cpp.pac_period_id < i_ae_txn_rec.accounting_period_id;

                       l_stmt_num := 465;

                       SELECT NVL(MAX(cost_group_id),-1)
                       INTO   l_txfr_cost_group_id
                       FROM   cst_cost_group_assignments
                       WHERE  organization_id = i_ae_txn_rec.organization_id;

                       l_stmt_num := 470;

                       BEGIN
                         SELECT legal_entity
                         INTO l_txfr_legal_entity
                         FROM cst_cost_groups
                         WHERE cost_group_id = l_txfr_cost_group_id;
                       EXCEPTION
                       WHEN no_data_found THEN
                            l_txfr_legal_entity := NULL;
                       END;

                       /* Check for the same LE/CT combination */
                       l_stmt_num := 475;

                       SELECT count(*)
                       INTO   l_same_le_ct
                       FROM   cst_le_cost_types
                       WHERE  legal_entity = l_txfr_legal_entity
                       AND    cost_type_id = i_ae_txn_rec.cost_type_id;

                       l_stmt_num := 480;

                       l_ae_line_rec.account := l_io_rcv_acct;

                       l_dr_flag := TRUE;

                       /* Debit Receivables at CPIC/Perpetual/Prior Period PWAC */
                       l_stmt_num := 485;

                         IF (i_ae_txn_rec.legal_entity_id = l_txfr_legal_entity AND l_same_le_ct > 0 AND l_transfer_cost_flag = 'Y') THEN

                        --    IF l_transfer_cost_flag = 'Y' THEN    /* PACP used */

                                   l_stmt_num := 490;

                                    /* Use CPIC cost */
                                    SELECT sum(NVL(CPIC.item_cost,0))
                                    INTO   l_pacp_pwac_cost
                                    FROM   CST_PAC_ITEM_COSTS CPIC
                                    WHERE  CPIC.INVENTORY_ITEM_ID = i_ae_txn_rec.inventory_item_id
                                    AND    CPIC.COST_GROUP_ID     = i_ae_txn_rec.cost_group_id
                                    AND    CPIC.PAC_PERIOD_ID     = i_ae_txn_rec.accounting_period_id;

                                    IF g_debug_flag = 'Y' THEN
                                        fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                                      ': Using PAC Absorption Cost: ' || l_pacp_pwac_cost);
                                    END IF;

                                   l_stmt_num := 492;
                                   SELECT nvl(transfer_percentage,0),nvl(transfer_cost,0),nvl(transportation_cost,0),primary_quantity
                                   INTO   l_txfr_percent,l_txfr_cost,l_trp_cost,l_txfr_txn_qty
                                   FROM   mtl_material_transactions
                                   WHERE  transaction_id = l_txfr_txn_id;

                                   IF (l_txfr_percent <> 0) THEN
                                       l_txfr_credit := (l_txfr_percent * l_pacp_pwac_cost / 100);
                                   ELSIF (l_txfr_cost <> 0) THEN
                                       l_txfr_credit := l_txfr_cost / abs(l_txfr_txn_qty);
                                   ELSE
                                       l_txfr_credit := 0;
                                   END IF;

                                   l_io_rcv_value := (l_pacp_pwac_cost +
                                                     (((l_trp_cost / abs(l_txfr_txn_qty))+ l_txfr_credit)));

                                   l_ae_line_rec.transaction_value := l_io_rcv_value * abs(i_ae_txn_rec.primary_quantity);
                                    l_ae_line_rec.resource_id := NULL;
                                    l_ae_line_rec.cost_element_id := NULL;
                                    l_ae_line_rec.ae_line_type := 10;  -- Receivables

                                    l_stmt_num := 495;

                                    /* Debit receivables */
                                    insert_account (i_ae_txn_rec,
                                                    i_ae_curr_rec,
                                                    l_dr_flag,
                                                    l_ae_line_rec,
                                                    l_ae_line_tbl,
                                                    l_err_rec);
                                    -- check error
                                    IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                                        RAISE process_error;
                                    END IF;

                                   /* Create entries for transfer credit and freight expense */

                                   l_dr_flag := not l_dr_flag;

                                   l_ae_line_rec.account := l_io_txfr_cr_acct;
                                   l_ae_line_rec.transaction_value := l_txfr_credit * abs(i_ae_txn_rec.primary_quantity);
                                   l_ae_line_rec.resource_id := NULL;
                                   l_ae_line_rec.cost_element_id := NULL;
                                   l_ae_line_rec.ae_line_type := 11;   -- transfer credit

                                   l_stmt_num := 496;

                                   IF (l_ae_line_rec.transaction_value <> 0) THEN

                                       insert_account (i_ae_txn_rec,
                                                       i_ae_curr_rec,
                                                       l_dr_flag,
                                                       l_ae_line_rec,
                                                       l_ae_line_tbl,
                                                       l_err_rec);
                                       -- check error
                                       IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                                           RAISE process_error;
                                       END IF;

                                   END IF;

                                   l_stmt_num := 497;

                                   l_ae_line_rec.transaction_value := l_trp_cost;
                                   l_ae_line_rec.account := l_io_freight_acct;
                                   l_ae_line_rec.resource_id := NULL;
                                   l_ae_line_rec.cost_element_id := NULL;
                                   l_ae_line_rec.ae_line_type := 12;   -- freight account

                                   l_stmt_num := 498;

                                   /* Freight account */
                                   IF (l_ae_line_rec.transaction_value <> 0) THEN

                                       insert_account (i_ae_txn_rec,
                                                       i_ae_curr_rec,
                                                       l_dr_flag,
                                                       l_ae_line_rec,
                                                       l_ae_line_tbl,
                                                       l_err_rec);

                                       -- check error
                                       IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                                           RAISE process_error;
                                       END IF;

                                   END IF;

                         ELSE /* PACP not used */

                            IF (i_ae_txn_rec.legal_entity_id = l_txfr_legal_entity AND l_same_le_ct > 0 AND l_prev_period_id <> -1) THEN

                              l_stmt_num := 500;
                              l_use_prev_period_cost := 1;

                           /* Get prior period PWAC Cost */
                                BEGIN
                                    SELECT nvl(CPIC.item_cost,0)
                                      INTO l_prev_period_pwac_cost
                                      FROM CST_PAC_ITEM_COSTS CPIC
                                     WHERE CPIC.INVENTORY_ITEM_ID = i_ae_txn_rec.inventory_item_id
                                       AND CPIC.COST_GROUP_ID     = i_ae_txn_rec.cost_group_id
                                       AND CPIC.PAC_PERIOD_ID     = l_prev_period_id;
                                EXCEPTION
                                when no_data_found then
                                    /* Use perpetual cost if prior period cost is not available */
                                    l_use_prev_period_cost := 0;
                                END;
                            ELSE
                             /* Use perpetual cost if prior period cost is not available or if the cost groups are not in the same LE/CT. */
                               l_use_prev_period_cost := 0;
                            END IF;

                            IF (l_use_prev_period_cost = 1) THEN

                                   IF g_debug_flag = 'Y' THEN
                                        fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                                      ': Using prior period PWAC cost: ' || l_prev_period_pwac_cost);
                                   END IF;

                                   l_stmt_num := 505;

                                   SELECT nvl(transfer_percentage,0),nvl(transfer_cost,0),nvl(transportation_cost,0),primary_quantity
                                   INTO   l_txfr_percent,l_txfr_cost,l_trp_cost,l_txfr_txn_qty
                                   FROM   mtl_material_transactions
                                   WHERE  transaction_id = l_txfr_txn_id;

                                   IF (l_txfr_percent <> 0) THEN
                                       l_txfr_credit := (l_txfr_percent * l_prev_period_pwac_cost / 100);
                                   ELSIF (l_txfr_cost <> 0) THEN
                                       l_txfr_credit := l_txfr_cost / abs(l_txfr_txn_qty);
                                   ELSE
                                       l_txfr_credit := 0;
                                   END IF;

                                   l_io_rcv_value := (l_prev_period_pwac_cost +
                                                     (((l_trp_cost / abs(l_txfr_txn_qty))+ l_txfr_credit)));

                                   l_ae_line_rec.transaction_value := l_io_rcv_value * abs(i_ae_txn_rec.primary_quantity);
                                   l_ae_line_rec.resource_id := NULL;
                                   l_ae_line_rec.cost_element_id := NULL;
                                   l_ae_line_rec.ae_line_type := 10;   -- Receivables

                                   l_stmt_num := 510;

                                   /* Debit receivables */
                                   insert_account (i_ae_txn_rec,
                                                   i_ae_curr_rec,
                                                   l_dr_flag,
                                                   l_ae_line_rec,
                                                   l_ae_line_tbl,
                                                   l_err_rec);
                                   -- check error
                                   IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                                       RAISE process_error;
                                   END IF;

                                   l_stmt_num := 515;

                                   /* Create entries for transfer credit and freight expense */

                                   l_dr_flag := not l_dr_flag;

                                   l_ae_line_rec.account := l_io_txfr_cr_acct;
                                   l_ae_line_rec.transaction_value := l_txfr_credit * abs(i_ae_txn_rec.primary_quantity);
                                   l_ae_line_rec.resource_id := NULL;
                                   l_ae_line_rec.cost_element_id := NULL;
                                   l_ae_line_rec.ae_line_type := 11;   -- transfer credit

                                   l_stmt_num := 520;

                                   IF (l_ae_line_rec.transaction_value <> 0) THEN

                                       insert_account (i_ae_txn_rec,
                                                       i_ae_curr_rec,
                                                       l_dr_flag,
                                                       l_ae_line_rec,
                                                       l_ae_line_tbl,
                                                       l_err_rec);
                                       -- check error
                                       IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                                           RAISE process_error;
                                       END IF;

                                   END IF;

                                   l_stmt_num := 525;

                                   l_ae_line_rec.transaction_value := l_trp_cost;
                                   l_ae_line_rec.account := l_io_freight_acct;
                                   l_ae_line_rec.resource_id := NULL;
                                   l_ae_line_rec.cost_element_id := NULL;
                                   l_ae_line_rec.ae_line_type := 12;   -- freight account

                                   l_stmt_num := 530;

                                   /* Freight account */
                                   IF (l_ae_line_rec.transaction_value <> 0) THEN

                                       insert_account (i_ae_txn_rec,
                                                       i_ae_curr_rec,
                                                       l_dr_flag,
                                                       l_ae_line_rec,
                                                       l_ae_line_tbl,
                                                       l_err_rec);

                                       -- check error
                                       IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                                           RAISE process_error;
                                       END IF;

                                   END IF;

                                  /* Transfer Variance */
                                  l_stmt_num := 535;

                                  SELECT sum(nvl(actual_cost,0))
                                  INTO l_mpacd_cost
                                  FROM mtl_pac_actual_cost_details
                                  WHERE transaction_id = i_ae_txn_rec.transaction_id
                                  AND pac_period_id = i_ae_txn_rec.accounting_period_id
                                  AND cost_group_id = i_ae_txn_rec.cost_group_id;

                                  l_stmt_num := 537;

                                  l_txfr_var_value := l_io_rcv_value - (l_mpacd_cost + l_txfr_credit + l_trp_cost/abs(l_txfr_txn_qty));

                                  IF (sign(l_txfr_var_value) = 1) THEN
                                     l_dr_flag := FALSE;
                                  ELSIF (sign(l_txfr_var_value) = -1) THEN
                                     l_dr_flag := TRUE;
                                  ELSE
                                     l_dr_flag := NULL;
                                  END IF;

                                  l_txfr_var_value := abs(l_txfr_var_value);

                                  IF (l_dr_flag IS NOT NULL) THEN

                                    IF (l_io_txfr_var_acct = -1) THEN
                                      RAISE no_interorg_profit_acct_error;
                                    END IF;

                                    /* Transfer variance entry */
                                    l_ae_line_rec.account := l_io_txfr_var_acct;
                                    l_ae_line_rec.transaction_value := l_txfr_var_value * abs(i_ae_txn_rec.primary_quantity);
                                    l_ae_line_rec.resource_id := NULL;
                                    l_ae_line_rec.cost_element_id := NULL;
                                    l_ae_line_rec.ae_line_type := 34;   -- Interorg profit in inventory

                                    insert_account (i_ae_txn_rec,
                                            i_ae_curr_rec,
                                            l_dr_flag,
                                            l_ae_line_rec,
                                            l_ae_line_tbl,
                                            l_err_rec);

                                    -- check error
                                    IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                                       RAISE process_error;
                                    END IF;

                                  END IF;

                         ELSE /* MTA Entries to be used */

                             l_stmt_num := 540;

                             IF g_debug_flag = 'Y' THEN
                                    fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                              ': Using MTA cost');
                             END IF;

                             /* Debit Receivables */

                            BEGIN
                             SELECT nvl(SUM(ABS(NVL(base_transaction_value, 0))),0)
                             INTO l_perp_ship_value
                             FROM mtl_transaction_accounts mta
                             WHERE mta.transaction_id = l_txfr_txn_id
                             and mta.organization_id = i_ae_txn_rec.xfer_organization_id
                             and mta.accounting_line_type IN (1,2,14)
                             and mta.base_transaction_value < 0;
                            EXCEPTION
                             WHEN no_data_found THEN
                                 l_perp_ship_value := 0;
                            END;

                             l_stmt_num := 550;

                             /* Select transfer cost and transportation cost from the transfer transaction (shipment txn).
                                We also need the shipment transaction quantity since this is the quantity we'll
                                need to divide by to get the unit transfer and transportation cost. */
                             SELECT nvl(transfer_percentage,0),nvl(transfer_cost,0),nvl(transportation_cost,0),primary_quantity
                             INTO l_txfr_percent,l_txfr_cost,l_trp_cost,l_txfr_txn_qty
                             FROM mtl_material_transactions
                             WHERE transaction_id = l_txfr_txn_id;

                             IF (l_txfr_percent <> 0) THEN
                                 l_txfr_credit := (l_txfr_percent * (l_perp_ship_value)/ (100 * abs(l_txfr_txn_qty)));
                             ELSIF (l_txfr_cost <> 0) THEN
                                 l_txfr_credit := l_txfr_cost / abs(l_txfr_txn_qty);
                             ELSE
                                 l_txfr_credit := 0;
                             END IF;

                             l_io_rcv_value :=  ((l_perp_ship_value + l_trp_cost) / abs(l_txfr_txn_qty)) + l_txfr_credit;

                             l_ae_line_rec.transaction_value := l_io_rcv_value  * abs(i_ae_txn_rec.primary_quantity);
                             l_ae_line_rec.account := l_io_rcv_acct;
                             l_ae_line_rec.resource_id := NULL;
                             l_ae_line_rec.cost_element_id := NULL;
                             l_ae_line_rec.ae_line_type := 10;  -- Receivables

                             l_stmt_num := 555;

                             insert_account (i_ae_txn_rec,
                                              i_ae_curr_rec,
                                              l_dr_flag,
                                              l_ae_line_rec,
                                              l_ae_line_tbl,
                                              l_err_rec);
                             -- check error
                             IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                                 RAISE process_error;
                             END IF;

                             /* Create entries for transfer credit and freight expense */

                             l_dr_flag := not l_dr_flag;

                             l_ae_line_rec.account := l_io_txfr_cr_acct;
                             l_ae_line_rec.transaction_value := l_txfr_credit * abs(i_ae_txn_rec.primary_quantity);
                             l_ae_line_rec.resource_id := NULL;
                             l_ae_line_rec.cost_element_id := NULL;
                             l_ae_line_rec.ae_line_type := 11;   -- transfer credit

                             l_stmt_num := 560;

                             /* transfer credit entry */
                             IF (l_ae_line_rec.transaction_value <> 0) THEN

                                 insert_account (i_ae_txn_rec,
                                                  i_ae_curr_rec,
                                                  l_dr_flag,
                                                  l_ae_line_rec,
                                                  l_ae_line_tbl,
                                                  l_err_rec);
                                 -- check error
                                 IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                                     RAISE process_error;
                                 END IF;

                             END IF;

                             /* l_trp_cost is the total freight charge for the shipment transaction quantity,
                                so we need to convert it to the receipt transaction quantity. */
                             l_ae_line_rec.transaction_value := (l_trp_cost / abs(l_txfr_txn_qty)) * abs(i_ae_txn_rec.primary_quantity);
                             l_ae_line_rec.account := l_io_freight_acct;
                             l_ae_line_rec.resource_id := NULL;
                             l_ae_line_rec.cost_element_id := NULL;
                             l_ae_line_rec.ae_line_type := 12;   -- freight account

                             l_stmt_num := 565;

                             /* freight account entry */
                             IF (l_ae_line_rec.transaction_value <> 0) THEN

                                insert_account (i_ae_txn_rec,
                                                  i_ae_curr_rec,
                                                  l_dr_flag,
                                                  l_ae_line_rec,
                                                  l_ae_line_tbl,
                                                  l_err_rec);
                                -- check error
                                IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                                    RAISE process_error;
                                END IF;

                             END IF;

                             /* Transfer Variance */
                             l_stmt_num := 567;

                             SELECT sum(nvl(actual_cost,0))
                             INTO l_mpacd_cost
                             FROM mtl_pac_actual_cost_details
                             WHERE transaction_id = i_ae_txn_rec.transaction_id
                             AND pac_period_id = i_ae_txn_rec.accounting_period_id
                             AND cost_group_id = i_ae_txn_rec.cost_group_id;

                             l_stmt_num := 570;

                             l_txfr_var_value := l_io_rcv_value - (l_mpacd_cost + l_txfr_credit + l_trp_cost/abs(l_txfr_txn_qty));

                             IF (sign(l_txfr_var_value) = 1) THEN
                                 l_dr_flag := FALSE;
                             ELSIF (sign(l_txfr_var_value) = -1) THEN
                                 l_dr_flag := TRUE;
                             ELSE
                                 l_dr_flag := NULL;
                             END IF;

                             l_txfr_var_value := abs(l_txfr_var_value);

                             IF (l_dr_flag IS NOT NULL) THEN

                                IF (l_io_txfr_var_acct = -1) THEN
                                  RAISE no_interorg_profit_acct_error;
                                END IF;

                                /* Transfer variance entry */
                                l_ae_line_rec.account := l_io_txfr_var_acct;
                                l_ae_line_rec.transaction_value := l_txfr_var_value * abs(i_ae_txn_rec.primary_quantity);
                                l_ae_line_rec.resource_id := NULL;
                                l_ae_line_rec.cost_element_id := NULL;
                                l_ae_line_rec.ae_line_type := 34;   -- Interorg profit in inventory

                                insert_account (i_ae_txn_rec,
                                        i_ae_curr_rec,
                                        l_dr_flag,
                                        l_ae_line_rec,
                                        l_ae_line_tbl,
                                        l_err_rec);

                                -- check error
                                IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                                   RAISE process_error;
                                END IF;

                             END IF; /* IF l_dr_flag IS NOT NULL */

                         END IF; /* IF (l_use_prev_period_cost = 1) THEN */
                    END IF;

                ELSIF (l_fob_point = 1) THEN /* FOBS - Can only be the receiving CG */

                     l_stmt_num := 575;

                     IF g_debug_flag = 'Y' THEN
                       fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                              ': Receipt txn of FOB Shipment - Receiving Cost Group');
                     END IF;

                     -- Processing the process-discrete txns
                     -- INVCONV sikhanna
                     SELECT MOD(SUM(DECODE(process_enabled_flag,'Y',1,2)), 2)
                     INTO   l_pd_txfr_ind
                     FROM   MTL_PARAMETERS MP
                     WHERE  MP.ORGANIZATION_ID = i_ae_txn_rec.xfer_organization_id
                            OR MP.ORGANIZATION_ID    = i_ae_txn_rec.organization_id;

                     IF g_debug_flag = 'Y' THEN
                           fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                     ': Process-isc Ind: ' || l_pd_txfr_ind);
                     END IF;

                     IF (l_cg_exp_item <> 1) THEN

                       /* Debit OnHand and Credit Intransit */

                       l_dr_flag := TRUE;

                       -- Debit On-hand (if expense, then use expense account)
                       -- -----------------------------------------------------
                       IF (l_exp_flg) THEN
                          CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                                      i_ae_curr_rec,
                                                      l_exp_flg, -- Exp Flag
                                                      l_exp_account, -- Exp Acct
                                                      l_dr_flag,
                                                      l_ae_line_tbl,
                                                      l_err_rec);
                       ELSE
                          CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                                      i_ae_curr_rec,
                                                      "FALSE", -- Exp Flag
                                                      null, -- Exp Acct
                                                      l_dr_flag,
                                                      l_ae_line_tbl,
                                                      l_err_rec);
                       END IF;

                       -- check error
                       IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                           RAISE process_error;
                       END IF;

                       l_dr_flag := not l_dr_flag;

                       -- Credit Intransit
                       -- ----------------
                       l_stmt_num := 580;

                       CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                                    i_ae_curr_rec,
                                                    "FALSE",   --- Exp Flag
                                                    null,      --- Exp Acct
                                                    l_dr_flag,
                                                    l_ae_line_tbl,
                                                    l_err_rec,
                                                    1);
                       -- check error
                       IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                           RAISE process_error;
                       END IF;

                     END IF; /* IF (l_cg_exp_item <> 1) THEN */

                ELSIF (i_ae_txn_rec.txn_action_id = 3) THEN   /* Direct interorg receipt */

                       l_stmt_num := 585;

                       IF g_debug_flag = 'Y' THEN
                          fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                              ': Direct Interorg Receipt - Receiving Cost Group');
                       END IF;

                       /* Debit On-Hand and credit Payables */

                       l_dr_flag := TRUE;

                       -- Debit On-hand (if expense, then use expense account)
                       -- -----------------------------------------------------
                       IF (l_exp_flg) THEN
                          CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                                       i_ae_curr_rec,
                                                       l_exp_flg, -- Exp Flag
                                                       l_exp_account, -- Exp Acct
                                                       l_dr_flag,
                                                       l_ae_line_tbl,
                                                       l_err_rec);
                       ELSE
                          CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                                       i_ae_curr_rec,
                                                       "FALSE", -- Exp Flag
                                                       null, -- Exp Acct
                                                       l_dr_flag,
                                                       l_ae_line_tbl,
                                                       l_err_rec);
                       END IF;

                       -- check error
                       IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                           RAISE process_error;
                       END IF;

                       l_dr_flag := not l_dr_flag;

                         /* Absorb MOH if exists */
                         l_stmt_num := 587;
                         select count(transaction_id)
                         into l_mat_ovhd_exists
                         from mtl_pac_actual_cost_details
                         where transaction_id = i_ae_txn_rec.transaction_id
                         and pac_period_id = i_ae_txn_rec.accounting_period_id
                         and cost_group_id = i_ae_txn_rec.cost_group_id
                         and cost_element_id = 2
                         and level_type = 1;

                         l_stmt_num := 590;
                         if (l_mat_ovhd_exists > 0) then
                            ovhd_accounts(i_ae_txn_rec,
                                          i_ae_curr_rec,
                                          l_dr_flag,
                                          l_ae_line_tbl,
                                          l_err_rec);
                           -- check error
                           if (l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
                             raise process_error;
                           end if;
                         end if;

                       l_stmt_num := 592;

                       SELECT mip.interorg_payables_account
                       INTO   l_io_pay_acct
                       FROM   mtl_interorg_parameters mip
                       WHERE  mip.from_organization_id = i_ae_txn_rec.xfer_organization_id
                       AND    mip.to_organization_id = i_ae_txn_rec.organization_id;

                       l_stmt_num := 595;


                       SELECT sum(nvl(transaction_cost,0))
                       INTO l_mptcd_cost
                       FROM mtl_pac_txn_cost_details
                       WHERE transaction_id = i_ae_txn_rec.transaction_id
                       AND pac_period_id = i_ae_txn_rec.accounting_period_id
                       AND cost_group_id = i_ae_txn_rec.cost_group_id;

                       l_ae_line_rec.account := l_io_pay_acct;
                       l_ae_line_rec.transaction_value := (l_mptcd_cost * abs(i_ae_txn_rec.primary_quantity));
                       l_ae_line_rec.resource_id := NULL;
                       l_ae_line_rec.cost_element_id := NULL;
                       l_ae_line_rec.ae_line_type := 9;   -- Payables

                       l_stmt_num := 600;

                       -- Credit Payables
                       -- ---------------
                       insert_account (i_ae_txn_rec,
                                       i_ae_curr_rec,
                                       l_dr_flag,
                                       l_ae_line_rec,
                                       l_ae_line_tbl,
                                       l_err_rec);
                       -- check error
                       IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                           RAISE process_error;
                       END IF;

                END IF; /* End for all ordinary interorg receipts */

           END IF; /* End for all receipts */

        END IF; /* END  Process Shipment transactions */

        /* INVCONV sikhanna - Create distributions for OPM-Discrete Logical txns other than Internal Orders */
        IF (i_ae_txn_rec.txn_src_type_id NOT IN (7,8) OR l_tprice_option <> 2) THEN

            /* Logical Receipt -- INVCONV sikhanna */ /* Do not process the logical txns for Internal Orders if ICR were setup */
            IF (i_ae_txn_rec.txn_action_id = 15 and l_fob_point = 1 ) THEN

                l_stmt_num := 605;

                IF g_debug_flag = 'Y' THEN
                    fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                  ': OPM-Discrete Logical Receipt');
                END IF;

                SELECT mip.interorg_payables_account,
                       mmt.transportation_dist_account
                INTO   l_io_pay_acct,
                       l_io_freight_acct
                FROM   mtl_interorg_parameters mip,
                       mtl_material_transactions mmt
                WHERE  mip.from_organization_id = i_ae_txn_rec.xfer_organization_id
                AND    mip.to_organization_id = i_ae_txn_rec.organization_id
                AND    mmt.transaction_id = i_ae_txn_rec.transaction_id;

                l_stmt_num := 610;

                /* Debit Intransit */

                l_dr_flag := TRUE;

                IF (l_cg_exp_item = 1) THEN /* When Item is expense Bug:5337446 */
                   /* Debit Expense */
                   CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                                i_ae_curr_rec,
                                                l_exp_flg, -- Exp Flag
                                                l_exp_account, -- Exp Acct
                                                l_dr_flag,
                                                l_ae_line_tbl,
                                                l_err_rec);
                ELSE
                   /* Debit Intransit */
                   CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                                i_ae_curr_rec,
                                                "FALSE", -- Exp Flag
                                                null, -- Exp Acct
                                                l_dr_flag,
                                                l_ae_line_tbl,
                                                l_err_rec,
                                                1);
                END IF;

                -- check error
                IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                 RAISE process_error;
                END IF;

                l_stmt_num := 615;

                /* Create Credit entries */

                l_dr_flag := not l_dr_flag;

                SELECT nvl(transfer_price,0),
                       nvl(transportation_cost,0)
                INTO   l_txfr_cost, -- transfer price
                       l_trp_cost   -- transportation cost
                FROM   mtl_material_transactions mmt
                WHERE  mmt.transaction_id = i_ae_txn_rec.transaction_id;

                /* Credit freight account */

                l_stmt_num := 620;

                l_ae_line_rec.transaction_value := l_trp_cost;
                l_ae_line_rec.account := l_io_freight_acct;
                l_ae_line_rec.resource_id := NULL;
                l_ae_line_rec.cost_element_id := NULL;
                l_ae_line_rec.ae_line_type := 12; -- freight account

                l_stmt_num := 625;

                IF (l_ae_line_rec.transaction_value <> 0) THEN

                    insert_account (i_ae_txn_rec,
                                    i_ae_curr_rec,
                                    l_dr_flag,
                                    l_ae_line_rec,
                                    l_ae_line_tbl,
                                    l_err_rec);
                    -- check error
                    IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                     RAISE process_error;
                    END IF;

                END IF;

                l_stmt_num := 630;

                /* Absorb MOH if exists */

                select count(transaction_id)
                into l_mat_ovhd_exists
                from mtl_pac_actual_cost_details
                where transaction_id = i_ae_txn_rec.transaction_id
                and pac_period_id = i_ae_txn_rec.accounting_period_id
                and cost_group_id = i_ae_txn_rec.cost_group_id
                and cost_element_id = 2
                and level_type = 1;

                if (l_mat_ovhd_exists > 0) then

                   l_stmt_num := 632;

                   ovhd_accounts(i_ae_txn_rec,
                                 i_ae_curr_rec,
                                 l_dr_flag,
                                 l_ae_line_tbl,
                                 l_err_rec);
                  -- check error
                  if (l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
                    raise process_error;
                  end if;
                end if;

                SELECT sum(nvl(actual_cost,0))
                INTO  l_txfr_cost
                FROM  mtl_pac_actual_cost_details
                WHERE transaction_id = i_ae_txn_rec.transaction_id
                AND   pac_period_id = i_ae_txn_rec.accounting_period_id
                AND   cost_group_id = i_ae_txn_rec.cost_group_id;

                /* Subtract MOH if already absorbed */
                l_mat_ovhd_cost := 0;
                if (l_mat_ovhd_exists > 0) then

                   l_stmt_num := 635;

                   select sum(nvl(actual_cost,0))
                   into   l_mat_ovhd_cost
                   from mtl_pac_cost_subelements
                   where transaction_id = i_ae_txn_rec.transaction_id
                   and cost_group_id = i_ae_txn_rec.cost_group_id
                   and pac_period_id = i_ae_txn_rec.accounting_period_id
                   and cost_type_id = i_ae_txn_rec.cost_type_id
                   and cost_element_id = 2;

                   if l_mat_ovhd_cost is NULL then
                    /*Bug: 5456009 This will be the case when moh is not earned by moh rules.
                      MOH is transportation cost in the transfer, so no record in mpcs */
                     l_mat_ovhd_cost := 0;
                   end if;

                end if;

                /* Credit Payables */

                /* MOH absorption */
                l_ae_line_rec.transaction_value := ((l_txfr_cost - l_mat_ovhd_cost) * abs(i_ae_txn_rec.primary_quantity)) - l_trp_cost;
                l_ae_line_rec.account := l_io_pay_acct;
                l_ae_line_rec.resource_id := NULL;
                l_ae_line_rec.cost_element_id := NULL;
                l_ae_line_rec.ae_line_type := 9;  -- Payables

                l_stmt_num := 637;

                insert_account (i_ae_txn_rec,
                                i_ae_curr_rec,
                                l_dr_flag,
                                l_ae_line_rec,
                                l_ae_line_tbl,
                                l_err_rec);
                -- check error
                IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                 RAISE process_error;
                END IF;

                l_stmt_num := 640;

            /* Logical Shipment -- INVCONV sikhanna */
            ELSIF (i_ae_txn_rec.txn_action_id = 22 and l_fob_point = 2) THEN

                l_stmt_num := 645;
                IF g_debug_flag = 'Y' THEN
                    fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                  ': OPM-Discrete Logical Shipment');
                END IF;

                SELECT mip.interorg_receivables_account,
                       mmt.transportation_dist_account,
                       mip.interorg_transfer_cr_account,
                       nvl(mip.interorg_profit_account, -1)
                INTO   l_io_rcv_acct,
                       l_io_freight_acct,
                       l_io_txfr_cr_acct,
                       l_io_txfr_var_acct
                FROM   mtl_interorg_parameters mip,mtl_material_transactions mmt
                WHERE  mip.from_organization_id = i_ae_txn_rec.organization_id -- INVCONV condition is opposite
                AND    mip.to_organization_id = i_ae_txn_rec.xfer_organization_id
                AND    mmt.transaction_id = i_ae_txn_rec.transaction_id;

                IF (l_io_txfr_var_acct = -1) THEN
                     RAISE no_interorg_profit_acct_error;
                END IF;

                l_stmt_num := 650;

                SELECT nvl(transfer_price,0),
                       nvl(transportation_cost,0)
                INTO   l_txfr_cost, -- transfer price
                       l_trp_cost   -- transportation cost
                FROM   mtl_material_transactions mmt
                WHERE  mmt.transaction_id = i_ae_txn_rec.transaction_id;

                l_stmt_num := 655;
                /* create debit entries */

                l_dr_flag := true;

                /* Debit Receivables */
                l_ae_line_rec.transaction_value := l_txfr_cost  * abs(i_ae_txn_rec.primary_quantity);
                l_ae_line_rec.account := l_io_rcv_acct;
                l_ae_line_rec.resource_id := NULL;
                l_ae_line_rec.cost_element_id := NULL;
                l_ae_line_rec.ae_line_type := 10;  -- Receivables

                l_stmt_num := 660;

                insert_account (i_ae_txn_rec,
                                i_ae_curr_rec,
                                l_dr_flag,
                                l_ae_line_rec,
                                l_ae_line_tbl,
                                l_err_rec);
                -- check error
                IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                 RAISE process_error;
                END IF;

                l_stmt_num := 665;

                /* create credit entries */

                l_dr_flag := NOT l_dr_flag;

                l_ae_line_rec.transaction_value := l_trp_cost;
                l_ae_line_rec.account := l_io_freight_acct;
                l_ae_line_rec.resource_id := NULL;
                l_ae_line_rec.cost_element_id := NULL;
                l_ae_line_rec.ae_line_type := 12;   -- freight account

                l_stmt_num := 670;

                /* freight account entry */
                IF (l_ae_line_rec.transaction_value <> 0) THEN

                    insert_account (i_ae_txn_rec,
                                    i_ae_curr_rec,
                                    l_dr_flag,
                                    l_ae_line_rec,
                                    l_ae_line_tbl,
                                    l_err_rec);
                    -- check error
                    IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                     RAISE process_error;
                    END IF;

                END IF;

                l_stmt_num := 675;

                IF (l_cg_exp_item <> 1) THEN /* Create Credit entries only if item is not expense */

                    /* Removed the code for shipping from Exp subInv 5474899 */
                    /* Credit Intransit */
                    CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                                 i_ae_curr_rec,
                                                 "FALSE", -- Exp Flag
                                                 null, -- Exp Acct
                                                 l_dr_flag,
                                                 l_ae_line_tbl,
                                                 l_err_rec,
                                                 1);

                    -- check error
                    IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                     RAISE process_error;
                    END IF;

                END IF; /* (l_cg_exp_item <> 1) */

                l_stmt_num := 680;

                SELECT NVL(CPIC.item_cost,0)
                INTO   l_pwac_cost
                FROM   CST_PAC_ITEM_COSTS CPIC
                WHERE  CPIC.INVENTORY_ITEM_ID = i_ae_txn_rec.inventory_item_id
                AND    CPIC.COST_GROUP_ID     = i_ae_txn_rec.cost_group_id
                AND    CPIC.PAC_PERIOD_ID     = i_ae_txn_rec.accounting_period_id;

                l_profit_or_loss := l_trp_cost + (l_pwac_cost - l_txfr_cost) * abs(i_ae_txn_rec.primary_quantity);

                IF l_profit_or_loss <> 0 THEN

                    IF l_profit_or_loss > 0 THEN
                        l_dr_flag := not l_dr_flag; -- If -ve then Debit interorg profit
                    END IF;

                    l_stmt_num := 685;

                    l_ae_line_rec.transaction_value := abs(l_profit_or_loss * i_ae_txn_rec.primary_quantity);
                    l_ae_line_rec.account := l_io_txfr_var_acct;
                    l_ae_line_rec.resource_id := NULL;
                    l_ae_line_rec.cost_element_id := NULL;
                    l_ae_line_rec.ae_line_type := 34;   -- interorg profit account

                    l_stmt_num := 690;

                    insert_account (i_ae_txn_rec,
                                    i_ae_curr_rec,
                                    l_dr_flag,
                                    l_ae_line_rec,
                                    l_ae_line_tbl,
                                    l_err_rec);
                    -- check error
                    IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                     RAISE process_error;
                    END IF;

                END IF; /* l_profit_or_loss <> 0 */

            END IF; /* END Logical Receipt -- INVCONV sikhanna */

        END IF; /* END (i_ae_txn_rec.txn_src_type_id NOT IN (7,8) OR l_tprice_option <> 2) */

        l_stmt_num := 700;

        IF g_debug_flag = 'Y' THEN
          fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ': return >>');
        END IF;

  EXCEPTION

    when no_mfca_acct_error then -- INVCONV
    fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ': Error processing transaction ' || i_ae_txn_rec.transaction_id);
    o_ae_err_rec.l_err_num := 30005;
    o_ae_err_rec.l_err_code := 'CST_PAC_NO_MFCA_ACCTS';
    FND_MESSAGE.set_name('BOM', 'CST_PAC_NO_MFCA_ACCTS');
    o_ae_err_rec.l_err_msg := FND_MESSAGE.Get;

    when no_interorg_profit_acct_error then
    fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ': Error processing transaction ' || i_ae_txn_rec.transaction_id);
    o_ae_err_rec.l_err_num := 30005;
    o_ae_err_rec.l_err_code := 'CST_NO_INTERORG_PROFIT_ACCT';
    FND_MESSAGE.set_name('BOM', 'CST_NO_INTERORG_PROFIT_ACCT');
    o_ae_err_rec.l_err_msg := FND_MESSAGE.Get;

    when no_profit_in_inv_acct_error then
    fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ': Error processing transaction ' || i_ae_txn_rec.transaction_id);
    o_ae_err_rec.l_err_num := 30005;
    o_ae_err_rec.l_err_code := 'CST_NO_PROFIT_INV_ACCT';
    FND_MESSAGE.set_name('BOM', 'CST_NO_PROFIT_INV_ACCT');
    o_ae_err_rec.l_err_msg := FND_MESSAGE.Get;

    when no_cg_acct_error then
    o_ae_err_rec.l_err_num := 30003;
    o_ae_err_rec.l_err_code := 'CST_PAC_NO_CG_ACCTS';
    FND_MESSAGE.set_name('BOM', 'CST_PAC_NO_CG_ACCTS');
    o_ae_err_rec.l_err_msg := FND_MESSAGE.Get;

    when process_error then
    o_ae_err_rec.l_err_num := l_err_rec.l_err_num;
    o_ae_err_rec.l_err_code := l_err_rec.l_err_code;
    o_ae_err_rec.l_err_msg := l_err_rec.l_err_msg;

    when others then
    o_ae_err_rec.l_err_num := SQLCODE;
    o_ae_err_rec.l_err_code := '';
    o_ae_err_rec.l_err_msg := 'CSTPAPBR.interorg_cost_txn' || to_char(l_stmt_num) ||
    substr(SQLERRM,1,180);

  END interorg_cost_txn;


-- ===================================================================
-- Cost Update Transactions.
-- ===================================================================
procedure pcu_cost_txn(
  i_ae_txn_rec                IN        CSTPALTY.cst_ae_txn_rec_type,
  i_ae_curr_rec               IN        CSTPALTY.cst_ae_curr_rec_type,
  l_ae_line_tbl               IN OUT NOCOPY    CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec                OUT NOCOPY        CSTPALTY.cst_ae_err_rec_type
  --i_ae_txn_rec                IN              CSTPALBR.cst_ae_txn_rec_type,
  --i_ae_curr_rec               IN              CSTPALBR.cst_ae_curr_rec_type,
  --l_ae_line_tbl               IN OUT    CSTPALBR.cst_ae_line_tbl_type,
  --o_ae_err_rec                OUT             CSTPALBR.cst_ae_err_rec_type
) IS
  l_cost                                NUMBER;
  l_var                                 NUMBER;
  l_var_total                           NUMBER;
  l_acct_exist                                NUMBER;
  l_ele_exist                                 NUMBER;
  l_dr_flag                             BOOLEAN;
  l_loop_count                          NUMBER := 0;
  l_ae_line_rec                         CSTPALTY.cst_ae_line_rec_type;
  l_acct_rec                            CSTPALTY.cst_ae_acct_rec_type;
  l_err_rec                             CSTPALTY.cst_ae_err_rec_type;
  --l_ae_line_rec                       CSTPALBR.cst_ae_line_rec_type;
  --l_acct_rec                          CSTPALBR.cst_ae_acct_rec_type;
  --l_err_rec                           CSTPALBR.cst_ae_err_rec_type;
  l_txn_ce_bal_account                  NUMBER;  -- Bug 4586534
  l_stmt_num                                   NUMBER;
  l_value_change_flag                   NUMBER;
  l_onhand_var                          NUMBER;
  l_cost_method                         NUMBER;
  no_cg_acct_error                      EXCEPTION;
  no_mfca_acct_error                    EXCEPTION;
  no_txn_det_error                      EXCEPTION;
  process_error                                EXCEPTION;
BEGIN

  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Pcu_cost_txn <<');
  END IF;

-- Initialize variables.
-- ---------------------
  l_stmt_num := 10;
  l_err_rec.l_err_num := 0;
  l_err_rec.l_err_code := '';
  l_err_rec.l_err_msg := '';


-- Check if there are Fiscal Cat Accounts.
-- ---------------------------------------
  l_stmt_num := 15;
   select count(legal_entity_id) /* Bug 4586534 */
  into l_acct_exist
  from mtl_fiscal_cat_accounts
  where legal_entity_id = i_ae_txn_rec.legal_entity_id
    and cost_type_id    = i_ae_txn_rec.cost_type_id
    and cost_group_id   = i_ae_txn_rec.cost_group_id
    and category_id     = i_ae_txn_rec.category_id;

  if (l_acct_exist = 0) then
    fnd_file.put_line(fnd_file.log,'Category: '||to_char(i_ae_txn_rec.category_id) || ' has no accounts defined');
    raise no_mfca_acct_error;
  end if;

-- Get the accounts from MFCA.
-- ---------------------------
  l_stmt_num := 20;
  select nvl(material_account,-1),
         nvl(material_overhead_account,-1),
         nvl(resource_account,-1),
         nvl(outside_processing_account,-1),
         nvl(overhead_account,-1)
    into l_acct_rec.mat_account,
         l_acct_rec.mat_ovhd_account,
         l_acct_rec.res_account,
         l_acct_rec.osp_account,
         l_acct_rec.ovhd_account
    from mtl_fiscal_cat_accounts
   where legal_entity_id = i_ae_txn_rec.legal_entity_id
     and cost_type_id    = i_ae_txn_rec.cost_type_id
     and cost_group_id   = i_ae_txn_rec.cost_group_id
     and category_id     = i_ae_txn_rec.category_id;

   l_stmt_num := 22;
   SELECT nvl(max(primary_cost_method),-1)
    INTO  l_cost_method
   FROM cst_le_cost_types clct
    WHERE clct.legal_entity = i_ae_txn_rec.legal_entity_id
      AND clct.cost_type_id = i_ae_txn_rec.cost_type_id;

-- Check if there are Cost Details.
-- --------------------------------
  l_stmt_num := 25;
  select count(transaction_id) /* Bug 4586534 */
  into l_ele_exist
  from mtl_pac_actual_cost_details mpacd
  where mpacd.transaction_id = i_ae_txn_rec.transaction_id
  and mpacd.pac_period_id = i_ae_txn_rec.accounting_period_id
  and mpacd.cost_group_id = i_ae_txn_rec.cost_group_id
  and rownum < 2; /* 4586534 added rownum filter for perf as its only existence check */

  if (l_ele_exist = 0) then
    raise no_txn_det_error;
  end if;

-- Get the total variance.
-- -----------------------
  l_stmt_num := 27;
  select sum(nvl(variance_amount,0))
  into l_var_total
  from mtl_pac_actual_cost_details mpacd
  where mpacd.transaction_id = i_ae_txn_rec.transaction_id
  and mpacd.pac_period_id = i_ae_txn_rec.accounting_period_id
  and mpacd.cost_group_id = i_ae_txn_rec.cost_group_id;

-- Find out if this is a value change cost update
-- -----------------------------------------------
  l_stmt_num := 30;
  select count (1)
  into l_value_change_flag
  from mtl_pac_txn_cost_details mptcd
  where mptcd.transaction_id = i_ae_txn_rec.transaction_id
  and mptcd.pac_period_id = i_ae_txn_rec.accounting_period_id
  and mptcd.cost_group_id = i_ae_txn_rec.cost_group_id
  and mptcd.value_change is not null
  and rownum < 2;

  if(l_cost_method <> 3) then
    l_value_change_flag := 0;
  end if;
-- For each Cost Element.
-- ----------------------
  FOR cost_element IN 1..5 loop
l_txn_ce_bal_account := -1; -- bug4586534 added new. initializing to use it for all cost elements.
-- Get the difference and the variance.
-- ------------------------------------
    l_stmt_num := 30;
    select decode (l_value_change_flag,
                   0, (sum(nvl(new_cost,0)) - sum(nvl(prior_cost,0))),
                   sum (nvl(actual_cost, 0))),
           sum(nvl(variance_amount,0)),
	   sum(nvl(onhand_variance_amount,0))
    into l_cost,
         l_var,
	 l_onhand_var
    from mtl_pac_actual_cost_details
    where transaction_id = i_ae_txn_rec.transaction_id
    and pac_period_id = i_ae_txn_rec.accounting_period_id
    and cost_group_id = i_ae_txn_rec.cost_group_id
    and cost_element_id = cost_element;


-- Process only if exists cost for the element.
-- --------------------------------------------
    if (l_cost is not null) then
      l_stmt_num := 32;
       -- Bug 4586534. Get the balancing account.
       IF cost_element = 1 THEN
         l_txn_ce_bal_account := i_ae_txn_rec.mat_account;
       ELSIF cost_element = 2 THEN
         l_txn_ce_bal_account := i_ae_txn_rec.mat_ovhd_account;
       ELSIF cost_element = 3 THEN
         l_txn_ce_bal_account := i_ae_txn_rec.res_account;
       ELSIF cost_element = 4 THEN
         l_txn_ce_bal_account := i_ae_txn_rec.osp_account;
       ELSIF cost_element = 5 THEN
         l_txn_ce_bal_account := i_ae_txn_rec.ovhd_account;
       END IF;
         /*Bug 4586534. Condition added to stop creating distributions for a cost element
         if associated cost is zero and account is -1 (not provided) */
      IF (l_cost <> 0 OR (l_cost=0 AND l_txn_ce_bal_account <> -1)) THEN
-- Get the corresponding Cost Element Account.
-- -------------------------------------------
        l_stmt_num := 35;
        l_ae_line_rec.account := CSTPAPHK.get_account_id (
                                        i_ae_txn_rec.transaction_id,
                                        i_ae_txn_rec.legal_entity_id,
                                        i_ae_txn_rec.cost_type_id,
                                        i_ae_txn_rec.cost_group_id,
                                        l_dr_flag,
                                        l_ae_line_rec.ae_line_type,
                                        cost_element,
                                        NULL,
                                        i_ae_txn_rec.subinventory_code,
                                        "FALSE", ----i_exp_flag
                                        l_err_rec.l_err_num,
                                        l_err_rec.l_err_code,
                                        l_err_rec.l_err_msg);
       -- check error
       if(l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null) then
       raise process_error;
       end if;

       l_ae_line_rec.cost_element_id := cost_element;

       if (l_ae_line_rec.account = -1) then
          l_stmt_num := 40;
          /* Bug# 4586534. Replaced select statement from dual to PL/SQL based logic.
          select decode(cost_element, 1, l_acct_rec.mat_account,
                                      2, l_acct_rec.mat_ovhd_account,
                                      3, l_acct_rec.res_account,
                                      4, l_acct_rec.osp_account,
                                      5, l_acct_rec.ovhd_account)
          into l_ae_line_rec.account
          from dual;
          */
          IF cost_element = 1 THEN
            l_ae_line_rec.account := l_acct_rec.mat_account;
          ELSIF cost_element = 2 THEN
            l_ae_line_rec.account := l_acct_rec.mat_ovhd_account;
          ELSIF cost_element = 3 THEN
            l_ae_line_rec.account := l_acct_rec.res_account;
          ELSIF cost_element = 4 THEN
            l_ae_line_rec.account := l_acct_rec.osp_account;
          ELSIF cost_element = 5 THEN
            l_ae_line_rec.account := l_acct_rec.ovhd_account;
          END IF;
       end if;

-- If the new cost > prior cost, we have DEBIT, otherwise CREDIT.
-- --------------------------------------------------------------
       if ( (l_cost >= 0 AND l_value_change_flag = 0)
            OR (l_value_change_flag <> 0 AND (l_cost-l_var)>=0)
	   )then
          l_dr_flag := "TRUE";
       else
          l_dr_flag := "FALSE";
       end if;

-- Create AE line.
-- ---------------
       l_stmt_num := 45;
       l_ae_line_rec.ae_line_type := 1;
/* Propagating fix for bug 2287547 */
       /*l_ae_line_rec.transaction_value := abs(i_ae_txn_rec.primary_quantity) * l_cost;*/

       if (l_value_change_flag = 0) then
       l_ae_line_rec.transaction_value := abs(i_ae_txn_rec.primary_quantity * l_cost);
       else
         l_ae_line_rec.transaction_value := abs(l_cost-l_var);/*BUG 6895314*/

       end if;

       CSTPAPBR.insert_account (i_ae_txn_rec,
                               i_ae_curr_rec,
                               l_dr_flag,
                               l_ae_line_rec,
                               l_ae_line_tbl,
                               l_err_rec);

       -- check error
       if(l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null) then
       raise process_error;
       end if;

-- Toggle the Debit Flag.
-- ----------------------
       /*l_dr_flag := not l_dr_flag;*/
       if ( ((l_cost+l_onhand_var) < 0 AND l_value_change_flag <> 0)
            OR (l_value_change_flag = 0
	        AND (-1*i_ae_txn_rec.primary_quantity * l_cost - l_var)>0)
	   )then
          l_dr_flag := "TRUE";
       else
          l_dr_flag := "FALSE";
       end if;

-- Get the corresponding MSI Elemental Account
-- -------------------------------------------
       l_stmt_num := 47;
    /*  Bug 4586534. Modified to PL/SQL logic based instead of using select from dual and
    moved up (stmt 32) to include validation that no distribution for the cost element would be
    done if cost is zero and no account is provided for the cost element.

       select decode(cost_element, 1, i_ae_txn_rec.mat_account,
                                   2, i_ae_txn_rec.mat_ovhd_account,
                                   3, i_ae_txn_rec.res_account,
                                   4, i_ae_txn_rec.osp_account,
                                   5, i_ae_txn_rec.ovhd_account)
       into l_ae_line_rec.account
       from dual;
      */
    l_ae_line_rec.account := l_txn_ce_bal_account; -- added for bug# 4586534

-- Create AE line.
-- ---------------
       l_stmt_num := 50;
       l_ae_line_rec.ae_line_type := 2;
/* Propagating fix for bug 2287547 */
       /* l_ae_line_rec.transaction_value := (abs(i_ae_txn_rec.primary_quantity) * l_cost) - l_var;*/
       if (l_value_change_flag = 0) then
       l_ae_line_rec.transaction_value := abs(-1*i_ae_txn_rec.primary_quantity * l_cost - l_var);
       else
         l_ae_line_rec.transaction_value := abs(l_cost+l_onhand_var); /*BUG 6895314*/
       end if;

       CSTPAPBR.insert_account (i_ae_txn_rec,
                               i_ae_curr_rec,
                               l_dr_flag,
                               l_ae_line_rec,
                               l_ae_line_tbl,
                               l_err_rec);

       -- check error
       if(l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null) then
       raise process_error;
       end if;
     /* the l_dr_flag will have to be toggled again so that the variance account is credited or debited correctly.*/
         /* The toggling is removed  for the bug No. 4586534 */
       /* the l_dr_flag will have to be toggled again so that the variance account is credited or debited correctly.*/
        ELSE
         fnd_file.put_line(fnd_file.log,'No distributions created for Cost element ' || cost_element || ' as the associated cost is zero and Account is -1');
        END IF; -- for l_cost <> 0 or (l_cost=0 and account id exists)
        IF(l_onhand_var <> 0) THEN
	  if (l_onhand_var > 0) then
	   l_dr_flag := "TRUE";
	  else
          l_dr_flag := "FALSE";
          end if;
          l_ae_line_rec.ae_line_type := 20;
	  l_stmt_num := 65;
          l_ae_line_rec.account := CSTPAPHK.get_account_id (
                                        i_ae_txn_rec.transaction_id,
                                        i_ae_txn_rec.legal_entity_id,
                                        i_ae_txn_rec.cost_type_id,
                                        i_ae_txn_rec.cost_group_id,
                                        l_dr_flag,
                                        l_ae_line_rec.ae_line_type,
                                        cost_element,
                                        NULL,
                                        i_ae_txn_rec.subinventory_code,
                                        "FALSE", ----i_exp_flag
                                        l_err_rec.l_err_num,
                                        l_err_rec.l_err_code,
                                        l_err_rec.l_err_msg);
          -- check error
         if(l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null) then
          raise process_error;
         end if;
         if(l_ae_line_rec.account = -1) then
	  l_ae_line_rec.account := i_ae_txn_rec.expense_account_id;
	 end if;
         l_ae_line_rec.transaction_value := abs(l_onhand_var);
         l_stmt_num := 70;
         CSTPAPBR.insert_account (i_ae_txn_rec,
                               i_ae_curr_rec,
                               l_dr_flag,
                               l_ae_line_rec,
                               l_ae_line_tbl,
                               l_err_rec);
	 if(l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null) then
          raise process_error;
         end if;
	END IF;
      ELSE
      l_loop_count := l_loop_count + 1;
      IF g_debug_flag = 'Y' THEN
          fnd_file.put_line(fnd_file.log,'No cost for element ....');
      END IF;
    END IF;
  END LOOP;

  if l_var_total <> 0 then

-- Check if there are COCA Accounts.
-- ---------------------------------
     l_stmt_num := 35;
     select count(legal_entity_id) /* Bug No. 4586534 */
     into l_acct_exist
     from cst_org_cost_group_accounts
     where legal_entity_id = i_ae_txn_rec.legal_entity_id
       and cost_type_id    = i_ae_txn_rec.cost_type_id
       and cost_group_id   = i_ae_txn_rec.cost_group_id;
     if (l_acct_exist = 0) then
       raise no_cg_acct_error;
     end if;

/*Check if there was anything inserted into the adjustment accounts at all.If not then drive everything to variance and debit the Material account */

   If l_loop_count = 5 then

       If l_var_total < 0 then
        l_dr_flag := "TRUE";
       else
        l_dr_flag := "FALSE";
       end If;

       l_ae_line_rec.ae_line_type := 2;
       l_ae_line_rec.transaction_value := abs(l_var_total);

    /* bug 4586534. changed to PL/SQL logic based instead of select from dual
       select i_ae_txn_rec.mat_account
       into l_ae_line_rec.account
       from dual;
      */
      l_ae_line_rec.account := i_ae_txn_rec.mat_account;
       CSTPAPBR.insert_account (i_ae_txn_rec,
                               i_ae_curr_rec,
                               l_dr_flag,
                               l_ae_line_rec,
                               l_ae_line_tbl,
                               l_err_rec);

       /*l_dr_flag := not l_dr_flag;*/

       -- check error
       if(l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null) then
       raise process_error;
       end if;

   End If; /* end of posting the debit to adjustment account */

-- Get Cost Variance Account.
-- --------------------------
     l_stmt_num := 40;
     select nvl(cost_variance_account,-1)
       into l_ae_line_rec.account
       from cst_org_cost_group_accounts
     where legal_entity_id = i_ae_txn_rec.legal_entity_id
       and cost_type_id    = i_ae_txn_rec.cost_type_id
       and cost_group_id   = i_ae_txn_rec.cost_group_id;

-- Create AE line.
-- ---------------
     l_stmt_num := 55;

     l_ae_line_rec.ae_line_type := 13;
     l_ae_line_rec.transaction_value := abs(l_var_total);
     if (l_var_total > 0) then
	   l_dr_flag := "TRUE";
     else
         l_dr_flag := "FALSE";
     end if;

     CSTPAPBR.insert_account (i_ae_txn_rec,
                             i_ae_curr_rec,
                             l_dr_flag,
                             l_ae_line_rec,
                             l_ae_line_tbl,
                             l_err_rec);

     -- check error
     if(l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null) then
     raise process_error;
     end if;

  end if;
  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Pcu_cost_txn <<');
  END IF;

EXCEPTION

  when no_cg_acct_error then
  o_ae_err_rec.l_err_num := 30004;
  o_ae_err_rec.l_err_code := 'CST_PAC_NO_CG_ACCTS';
  FND_MESSAGE.set_name('BOM', 'CST_PAC_NO_CG_ACCTS');
  o_ae_err_rec.l_err_msg := FND_MESSAGE.Get;

  when no_mfca_acct_error then
  o_ae_err_rec.l_err_num := 30005;
  o_ae_err_rec.l_err_code := 'CST_PAC_NO_MFCA_ACCTS';
  FND_MESSAGE.set_name('BOM', 'CST_PAC_NO_MFCA_ACCTS');
  o_ae_err_rec.l_err_msg := FND_MESSAGE.Get;

  when no_txn_det_error then
  o_ae_err_rec.l_err_num := 30006;
  o_ae_err_rec.l_err_code := 'CST_NO_TXN_DET';
  FND_MESSAGE.set_name('BOM', 'CST_NO_TXN_DET');
  o_ae_err_rec.l_err_msg := FND_MESSAGE.Get;

  when process_error then
  o_ae_err_rec.l_err_num := l_err_rec.l_err_num;
  o_ae_err_rec.l_err_code := l_err_rec.l_err_code;
  o_ae_err_rec.l_err_msg := l_err_rec.l_err_msg;

  when others then
  o_ae_err_rec.l_err_num := SQLCODE;
  o_ae_err_rec.l_err_code := '';
  o_ae_err_rec.l_err_msg := 'CSTPAPBR.pcu_cost_txn' || to_char(l_stmt_num) ||
  substr(SQLERRM,1,180);

END pcu_cost_txn;

-- ===================================================================
-- Rest of inventory transactions.
-- ===================================================================
procedure inv_cost_txn(
  i_ae_txn_rec                IN        CSTPALTY.cst_ae_txn_rec_type,
  i_ae_curr_rec               IN        CSTPALTY.cst_ae_curr_rec_type,
  l_ae_line_tbl               IN OUT NOCOPY    CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec                OUT NOCOPY        CSTPALTY.cst_ae_err_rec_type
) IS
  l_exp_sub                             NUMBER;
  l_dropship_type_code      NUMBER;
  l_elemental                             NUMBER;
  l_acct_line_type                      NUMBER;
  l_ovhd_absp                             NUMBER;
  l_mat_ovhd_exists                     NUMBER;
  l_stmt_num                              NUMBER;
  l_dr_flag                             BOOLEAN;
  l_exp_flag                            BOOLEAN;
  process_error                           EXCEPTION;
  l_err_rec                             CSTPALTY.cst_ae_err_rec_type;
  l_acct_rec                            CSTPALTY.cst_ae_acct_rec_type;

  l_ref_om_line_id          NUMBER; -- Revenue / COGS Matching
BEGIN

  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Inv_cost_txn <<');
  END IF;
-- Initialize variables.
-- ---------------------
  l_err_rec.l_err_num := 0;
  l_err_rec.l_err_code := '';
  l_err_rec.l_err_msg := '';

-- Figure out expense subinventory.
-- --------------------------------
  l_stmt_num := 10;

  select decode(asset_inventory,1,0,1)
  into l_exp_sub
  from mtl_secondary_inventories
  where secondary_inventory_name = i_ae_txn_rec.subinventory_code
  and organization_id = i_ae_txn_rec.organization_id;

  -- No accounting entries posted for any transaction involving an expense
  -- item or expense subinventory except in the case of PO receipt, PO
  -- return and PO delivery adjustments.

  if ((i_ae_txn_rec.exp_item = 1 or l_exp_sub = 1) and (i_ae_txn_rec.txn_src_type_id <>1)) then
    IF g_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'Expense item or expense sub - No accounting ');
    END IF;
    return;
  end if;

  if ( l_exp_sub = 1 OR i_ae_txn_rec.exp_item = 1 ) then
    l_exp_flag := "TRUE";
    -- Expense account is derived in the Inventory_Accounts procedure
    l_acct_rec.account := -1;
/* Bug 3123936: Propogation of 2896193 */
  else
    l_exp_flag := "FALSE";
    l_acct_rec.account := -1;
  end if;

-- First post to the elemental inventory accounts.
-- -----------------------------------------------
  if ((i_ae_txn_rec.txn_action_id = 27) or
      (i_ae_txn_rec.txn_action_id = 6 and i_ae_txn_rec.txn_src_type_id = 1)) then
     l_dr_flag := "TRUE";
  elsif ((i_ae_txn_rec.txn_action_id = 1) or
         (i_ae_txn_rec.txn_action_id = 6 and i_ae_txn_rec.txn_src_type_id = 13)) then
     l_dr_flag := "FALSE";
  elsif (i_ae_txn_rec.txn_action_id in (29,4,8)) then
     if i_ae_txn_rec.primary_quantity < 0 then
        l_dr_flag := "FALSE";
     elsif i_ae_txn_rec.primary_quantity > 0 then
        l_dr_flag := "TRUE";
     end if;
  end if;

  inventory_accounts(i_ae_txn_rec,
                     i_ae_curr_rec,
                     l_exp_flag,
                     l_acct_rec.account,
                     l_dr_flag,
                     l_ae_line_tbl,
                     l_err_rec);
  -- check error
  if (l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
    raise process_error;
  end if;

-- Toggle the Debit Flag.
-- ----------------------
  l_dr_flag := not l_dr_flag;

-- Get acct_line_type, elemental flag, ovhd flag and acct_id.
-- ----------------------------------------------------------
  l_acct_rec.mat_account := '';
  l_acct_rec.mat_ovhd_account := '';
  l_acct_rec.res_account := '';
  l_acct_rec.osp_account := '';
  l_acct_rec.ovhd_account := '';

  if (i_ae_txn_rec.txn_action_id in (4,8)) then
     IF g_debug_flag = 'Y' THEN
       fnd_file.put_line(fnd_file.log,'Cycle Count or Physical Inv Adjustment');
     END IF;

    /* cycle count adjustment and physical inventory adjustment */
    /* Use the distribution account id as stated in mmt. */

    l_acct_rec.account := i_ae_txn_rec.dist_acct_id;
    l_acct_line_type := 2;
    l_elemental := 0;
    l_ovhd_absp := 0;

  elsif (i_ae_txn_rec.txn_action_id in (1,27,29) and i_ae_txn_rec.txn_src_type_id = 1) then

    /* PO Issue, Receipt, delivery adjustments. */
    IF g_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'PO Issue, Receipt, delivery adjustments');
    END IF;

    l_acct_rec.account := i_ae_txn_rec.dist_acct_id;
    l_elemental := 0;
    l_ovhd_absp := 1;

    /* Patchset J change: All External Drop ship PO Receipts will use the Clearing
    Account */

    select nvl(rt.dropship_type_code, 3)
    into l_dropship_type_code
    from rcv_transactions rt, mtl_material_transactions mmt
    where mmt.rcv_transaction_id = rt.transaction_id
    and mmt.transaction_id = i_ae_txn_rec.transaction_id;

    if (l_dropship_type_code = 1 or l_dropship_type_code = 2) then
     l_acct_line_type := 31; -- Clearing
    else
     l_acct_line_type := 5;
    end if;

  elsif (i_ae_txn_rec.txn_action_id in (1,27) and i_ae_txn_rec.txn_src_type_id in (2,12)) then
    l_elemental := 1;
    l_ovhd_absp := 0;

    l_stmt_num := 30;
    -- For RMAs only:
    -- Get the original sales order issue OM line ID, and check
    -- whether the original sales order issue was inserted into
    -- the Revenue / COGS Matching data model.
    SELECT max(ool.reference_line_id)
    INTO l_ref_om_line_id
    FROM oe_order_lines_all ool,
         cst_revenue_cogs_match_lines crcml
    WHERE ool.line_id = i_ae_txn_rec.om_line_id
    AND   ool.reference_line_id = crcml.cogs_om_line_id
    AND   crcml.pac_cost_type_id = i_ae_txn_rec.cost_type_id
    AND   i_ae_txn_rec.txn_src_type_id = 12;

    IF (i_ae_txn_rec.txn_src_type_id = 12 AND l_ref_om_line_id IS NOT NULL) then

       /* RMAs with Deferred COGS */
    IF g_debug_flag = 'Y' THEN
         fnd_file.put_line(fnd_file.log,'RMA with Deferred COGS');
       END IF;

       l_stmt_num := 35;
       -- Create the credit distributions to COGS and/or Deferred COGS
       CST_RevenueCogsMatch_PVT.Process_PacRmaReceipt(
                  i_ae_txn_rec,
                  i_ae_curr_rec,
                  l_dr_flag,
                  l_ref_om_line_id,
                  l_ae_line_tbl,
                  l_err_rec);

       -- check error
       if (l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
          raise process_error;
       end if;

       -- Processing is complete for these RMAs, go to end of procedure
       GOTO inv_cost_txn_end;
    ELSIF (i_ae_txn_rec.txn_src_type_id = 2 AND i_ae_txn_rec.so_issue_acct_type = 2) THEN

       /* Sales order issue with Deferred COGS */
       IF g_debug_flag = 'Y' THEN
          fnd_file.put_line(fnd_file.log,'Sales order issue ');
       END IF;

       l_stmt_num := 40;
       -- Get the Deferred COGS account
       SELECT deferred_cogs_acct_id
       INTO l_acct_rec.account
       FROM cst_revenue_cogs_match_lines
       WHERE cogs_om_line_id = i_ae_txn_rec.om_line_id
       AND  pac_cost_type_id = i_ae_txn_rec.cost_type_id;

       l_acct_rec.mat_account := l_acct_rec.account;
       l_acct_rec.mat_ovhd_account := l_acct_rec.account;
       l_acct_rec.res_account := l_acct_rec.account;
       l_acct_rec.osp_account := l_acct_rec.account;
       l_acct_rec.ovhd_account := l_acct_rec.account;

       l_acct_line_type := 36; -- Deferred COGS line type

    ELSE
       /* Sales orders and RMAs with no deferred COGS */
       IF g_debug_flag = 'Y' THEN
         fnd_file.put_line(fnd_file.log,'Sales order, RMA and Rejection of RMA ');
    END IF;

    l_acct_rec.account := i_ae_txn_rec.dist_acct_id;
    if (l_acct_rec.account = -1) then

         l_stmt_num := 45;

      select nvl(msi.cost_of_sales_account, mp.cost_of_sales_account)
      into l_acct_rec.account
      from mtl_system_items msi,
           mtl_parameters mp
      where msi.organization_id = i_ae_txn_rec.organization_id
      and msi.inventory_item_id = i_ae_txn_rec.inventory_item_id
      and mp.organization_id = msi.organization_id;

    end if;

    l_stmt_num := 50;

    l_acct_rec.mat_account := l_acct_rec.account;
    l_acct_rec.mat_ovhd_account := l_acct_rec.account;
    l_acct_rec.res_account := l_acct_rec.account;
    l_acct_rec.osp_account := l_acct_rec.account;
    l_acct_rec.ovhd_account := l_acct_rec.account;

       l_acct_line_type := 35;
    END IF;

  elsif (i_ae_txn_rec.txn_action_id in (1,27,29) and i_ae_txn_rec.txn_src_type_id = 3) then

    /* Account */
    IF g_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'Account txn');
    END IF;

    l_acct_rec.account := i_ae_txn_rec.txn_src_id;
    l_acct_line_type := 2;
    l_elemental := 0;
    l_ovhd_absp := 0;

  elsif (i_ae_txn_rec.txn_action_id in (1,27,29) and i_ae_txn_rec.txn_src_type_id = 6) then

    /* Account Alias*/
    IF g_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'Account Alias txn ');
    END IF;

    l_stmt_num := 60;

    select distribution_account
    into l_acct_rec.account
    from mtl_generic_dispositions
    where disposition_id = i_ae_txn_rec.txn_src_id
    and organization_id = i_ae_txn_rec.organization_id;

    l_acct_line_type := 2;
    l_elemental := 0;
    l_ovhd_absp := 0;

  elsif (i_ae_txn_rec.txn_action_id = 6 and i_ae_txn_rec.txn_src_type_id in (1, 13)) then

    /* Transfer to regular/consigned */
    IF g_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'Transfer to regular/consigned');
    END IF;

    l_acct_rec.account := i_ae_txn_rec.dist_acct_id;
    l_acct_line_type := 16;
    l_elemental := 0;
    l_ovhd_absp := 1;

  else

    /* Misc issue, receipt, default*/
    IF g_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'Misc issue, receipt');
    END IF;

    l_acct_rec.account := i_ae_txn_rec.dist_acct_id;
    l_acct_line_type := 2;
    l_elemental := 0;
    l_ovhd_absp := 0;

  end if;


-- Then post to the offsetting accounts.
-- -------------------------------------
  offset_accounts(i_ae_txn_rec,
                  i_ae_curr_rec,
                  l_acct_line_type,
                  l_elemental,
                  l_ovhd_absp,
                  l_dr_flag,
                  l_acct_rec,
                  l_ae_line_tbl,
                  l_err_rec);
  -- check error
  if (l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
     raise process_error;
  end if;


-- If ovhd flag is on then call ovhd procedure.
-- --------------------------------------------
  l_stmt_num := 70;
  if (l_ovhd_absp = 1) then
     select count(transaction_id) /* Changed for the bug No . 4586534 */
    into l_mat_ovhd_exists
    from mtl_pac_actual_cost_details
    where transaction_id = i_ae_txn_rec.transaction_id
    and pac_period_id = i_ae_txn_rec.accounting_period_id
    and cost_group_id = i_ae_txn_rec.cost_group_id
    and cost_element_id = 2
    and level_type = 1;

    if (l_mat_ovhd_exists > 0) then
       ovhd_accounts(i_ae_txn_rec,
                     i_ae_curr_rec,
                     l_dr_flag,
                     l_ae_line_tbl,
                     l_err_rec);
      -- check error
      if (l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
        raise process_error;
      end if;


    end if;
  end if;

<<inv_cost_txn_end>>
  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Inv_cost_txn >> ');
  END IF;

EXCEPTION

  when process_error then
  o_ae_err_rec.l_err_num := l_err_rec.l_err_num;
  o_ae_err_rec.l_err_code := l_err_rec.l_err_code;
  o_ae_err_rec.l_err_msg := l_err_rec.l_err_msg;

  when others then
  o_ae_err_rec.l_err_num := SQLCODE;
  o_ae_err_rec.l_err_code := '';
  o_ae_err_rec.l_err_msg := 'CSTPAPBR.inv_cost_txn' || to_char(l_stmt_num) ||
  substr(SQLERRM,1,180);

END inv_cost_txn;


-- ===================================================================
-- Logical Transactions
-- This procedure accounts for the logical transaction
--
-- 20-Jul-03   Anju   Creation
-- ===================================================================
procedure cost_logical_txn(
  i_ae_txn_rec                IN        CSTPALTY.cst_ae_txn_rec_type,
  i_ae_curr_rec               IN        CSTPALTY.cst_ae_curr_rec_type,
  l_ae_line_tbl               IN OUT NOCOPY    CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec                OUT NOCOPY        CSTPALTY.cst_ae_err_rec_type
 ) IS
  l_exp_sub                             NUMBER;
  l_exp_acct                              NUMBER;
  l_elemental                             NUMBER;
  l_acct_line_type                      NUMBER;
  l_ovhd_absp                             NUMBER;
  l_stmt_num                              NUMBER;
  l_dr_flag                             BOOLEAN;
  l_exp_flag                            BOOLEAN;
  process_error                           EXCEPTION;
  l_err_rec                             CSTPALTY.cst_ae_err_rec_type;
  l_acct_rec                            CSTPALTY.cst_ae_acct_rec_type;

  l_ref_om_line_id          NUMBER; -- Revenue / COGS Matching

BEGIN

  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Cost_logical_txn <<');
  END IF;
-- Initialize variables.
-- ---------------------
  l_err_rec.l_err_num := 0;
  l_err_rec.l_err_code := '';
  l_err_rec.l_err_msg := '';

-- First process the COGS Recognition Transaction since it does not hit Inventory accounts
-- ---------------------------------------------------------------------------------------
  l_stmt_num := 5;
  IF (i_ae_txn_rec.txn_src_type_id = 2 AND i_ae_txn_rec.txn_action_id = 36) THEN
     CST_RevenueCogsMatch_PVT.Process_PacCogsRecTxn(
                                  i_ae_txn_rec,
                                  i_ae_curr_rec,
                                  l_ae_line_tbl,
                                  l_err_rec);
     -- check error
     if (l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
        raise process_error;
     else
        GOTO cost_logical_txn_end; -- End of processing for COGS Recognition Txns
     end if;

  END IF;


-- Figure out expense subinventory.
-- --------------------------------
  l_stmt_num := 10;

  if (i_ae_txn_rec.subinventory_code is not null) then

    select decode(asset_inventory,1,0,1)
    into l_exp_sub
    from mtl_secondary_inventories
    where secondary_inventory_name = i_ae_txn_rec.subinventory_code
    and organization_id = i_ae_txn_rec.organization_id;
  else
    l_exp_sub := 0;
  end if;

  -- No accounting entries posted for an expense
  -- item or expense subinventory against a logical SO Issue or
  -- Logical RMA Receipt

  if ((i_ae_txn_rec.exp_item = 1 or l_exp_sub = 1) and
       ((i_ae_txn_rec.txn_action_id = 26 and i_ae_txn_rec.txn_src_type_id = 12) OR
        (i_ae_txn_rec.txn_action_id = 7 and i_ae_txn_rec.txn_src_type_id = 2))) then
    IF g_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'Expense item or expense sub - No accounting ');
    END IF;
    return;
  end if;

  if ( l_exp_sub = 1 OR i_ae_txn_rec.exp_item = 1 )  then
    l_exp_flag := "TRUE";
    -- Expense account is derived in the Inventory_Accounts procedure
    l_acct_rec.account := -1;
  else
    /* Bug 3123936: Prop og 2896193 */
    l_exp_flag := "FALSE";
    l_acct_rec.account := -1;
  end if;

-- First post to the elemental inventory accounts.
-- -----------------------------------------------
-- for all logical transactions, -ve qty means a credit to Inventory
  if (i_ae_txn_rec.primary_quantity < 0) then
     l_dr_flag := "FALSE";
  else
     l_dr_flag := "TRUE";
  end if;

  inventory_accounts(i_ae_txn_rec,
                     i_ae_curr_rec,
                     l_exp_flag,
                     l_acct_rec.account,
                     l_dr_flag,
                     l_ae_line_tbl,
                     l_err_rec);
  -- check error
  if (l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
    raise process_error;
  end if;


-- Toggle the Debit Flag.
-- ----------------------
  l_dr_flag := not l_dr_flag;

-- Get acct_line_type, elemental flag, ovhd flag and acct_id.
-- ----------------------------------------------------------
  l_acct_rec.mat_account := '';
  l_acct_rec.mat_ovhd_account := '';
  l_acct_rec.res_account := '';
  l_acct_rec.osp_account := '';
  l_acct_rec.ovhd_account := '';

  l_acct_rec.account := i_ae_txn_rec.dist_acct_id;
  l_ovhd_absp := 0;

  if (i_ae_txn_rec.txn_type_id in (19,39,69,22,23)) then
    l_acct_line_type := 31; -- clearing line type
    l_elemental := 0;

  elsif (i_ae_txn_rec.txn_type_id in (11,14))then
    l_acct_line_type := 2; -- account line type (I/C COGS)
    l_elemental := 1;

    l_acct_rec.mat_account := l_acct_rec.account;
    l_acct_rec.mat_ovhd_account := l_acct_rec.account;
    l_acct_rec.res_account := l_acct_rec.account;
    l_acct_rec.osp_account := l_acct_rec.account;
    l_acct_rec.ovhd_account := l_acct_rec.account;

  elsif (i_ae_txn_rec.txn_type_id in (10,13))then
    l_acct_line_type := 16; -- accrual line type (I/C accrual)
    l_elemental := 0;
  elsif (i_ae_txn_rec.txn_type_id in (30,16)) then -- Logical SO Issue or Logical RMA Receipt

    l_stmt_num := 30;
    -- For RMAs only:
    -- Get the original sales order issue OM line ID, and check
    -- whether the original sales order issue was inserted into
    -- the Revenue / COGS Matching data model.
    SELECT max(ool.reference_line_id)
    INTO l_ref_om_line_id
    FROM oe_order_lines_all ool,
         cst_revenue_cogs_match_lines crcml
    WHERE ool.line_id = i_ae_txn_rec.om_line_id
    AND   ool.reference_line_id = crcml.cogs_om_line_id
    AND   crcml.pac_cost_type_id = i_ae_txn_rec.cost_type_id
    AND   i_ae_txn_rec.txn_src_type_id = 12;

    IF (i_ae_txn_rec.txn_type_id = 16 AND l_ref_om_line_id IS NOT NULL) then

       /* RMAs with Deferred COGS */
       IF g_debug_flag = 'Y' THEN
         fnd_file.put_line(fnd_file.log,'RMA with Deferred COGS');
       END IF;

       l_stmt_num := 40;
       -- Create the credit distributions to COGS and/or Deferred COGS
       CST_RevenueCogsMatch_PVT.Process_PacRmaReceipt(
                  i_ae_txn_rec,
                  i_ae_curr_rec,
                  l_dr_flag,
                  l_ref_om_line_id,
                  l_ae_line_tbl,
                  l_err_rec);

       -- check error
       if (l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
          raise process_error;
       end if;

       -- Processing is complete for these RMAs, go to end of procedure
       GOTO cost_logical_txn_end;
    ELSIF (i_ae_txn_rec.txn_type_id = 30 AND i_ae_txn_rec.so_issue_acct_type = 2) THEN

       /* Sales order issue with Deferred COGS */
       IF g_debug_flag = 'Y' THEN
          fnd_file.put_line(fnd_file.log,'Sales order issue ');
       END IF;

       l_stmt_num := 50;
       -- Get the Deferred COGS account
       SELECT deferred_cogs_acct_id
       INTO l_acct_rec.account
       FROM cst_revenue_cogs_match_lines
       WHERE cogs_om_line_id = i_ae_txn_rec.om_line_id
       AND  pac_cost_type_id = i_ae_txn_rec.cost_type_id;

       l_acct_line_type := 36; -- Deferred COGS line type

    ELSE
       /* Logical Sales orders and RMAs with no deferred COGS */
       IF g_debug_flag = 'Y' THEN
         fnd_file.put_line(fnd_file.log,'Logical Sales order, RMA and Rejection of RMA ');
       END IF;

       l_acct_rec.account := i_ae_txn_rec.dist_acct_id;
       l_acct_line_type := 35;

    END IF;

    l_acct_rec.mat_account := l_acct_rec.account;
    l_acct_rec.mat_ovhd_account := l_acct_rec.account;
    l_acct_rec.res_account := l_acct_rec.account;
    l_acct_rec.osp_account := l_acct_rec.account;
    l_acct_rec.ovhd_account := l_acct_rec.account;

    l_elemental := 1;

  else
    -- invalid transaction type
    raise process_error;
  end if;

-- Then post to the offsetting accounts.
-- -------------------------------------
  offset_accounts(i_ae_txn_rec,
                  i_ae_curr_rec,
                  l_acct_line_type,
                  l_elemental,
                  l_ovhd_absp,
                  l_dr_flag,
                  l_acct_rec,
                  l_ae_line_tbl,
                  l_err_rec);
  -- check error
  if (l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
     raise process_error;
  end if;

<<cost_logical_txn_end>>

  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'cost_logical_txn out ');
  END IF;

EXCEPTION

  when process_error then
  o_ae_err_rec.l_err_num := l_err_rec.l_err_num;
  o_ae_err_rec.l_err_code := l_err_rec.l_err_code;
  o_ae_err_rec.l_err_msg := l_err_rec.l_err_msg;

  when others then
  o_ae_err_rec.l_err_num := SQLCODE;
  o_ae_err_rec.l_err_code := '';
  o_ae_err_rec.l_err_msg := 'CSTPAPBR.cost_logical_txn' ||
                    to_char(l_stmt_num) || substr(SQLERRM,1,180);

END cost_logical_txn;


-- ===================================================================
-- Consigned Price Update Transaction
-- This procedure accounts for consigned price update transaction
--
-- 20-Jul-03   Anju   Creation
-- ===================================================================
procedure cost_consigned_update_txn(
  i_ae_txn_rec                IN        CSTPALTY.cst_ae_txn_rec_type,
  i_ae_curr_rec               IN        CSTPALTY.cst_ae_curr_rec_type,
  l_ae_line_tbl               IN OUT NOCOPY    CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec                OUT NOCOPY        CSTPALTY.cst_ae_err_rec_type
 ) IS
  l_exp_sub                             NUMBER;
  l_qty                     NUMBER;
  l_exp_acct                              NUMBER;
  l_ovhd_absp               NUMBER;
  l_elemental                             NUMBER;
  l_acct_line_type          NUMBER;
  l_stmt_num                              NUMBER;
  l_dr_flag                 BOOLEAN;
  l_ele_exist               NUMBER;
  l_cost                    NUMBER;
  process_error                           EXCEPTION;
  no_txn_det_error          EXCEPTION;
  l_err_rec                 CSTPALTY.cst_ae_err_rec_type;
  l_acct_rec                CSTPALTY.cst_ae_acct_rec_type;
  l_ae_line_rec             CSTPALTY.cst_ae_line_rec_type;

BEGIN

  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Cost_consigned_txn <<');
  END IF;
-- Initialize variables.
-- ---------------------
  l_err_rec.l_err_num := 0;
  l_err_rec.l_err_code := '';
  l_err_rec.l_err_msg := '';

--consigned price update transaction quantity is stored in mmt.quantity_adjusted
--update i_ae_txn_rec.

  select nvl(quantity_adjusted, 0)
  into l_qty
  from mtl_material_transactions
  where transaction_id = i_ae_txn_rec.transaction_id;

-- Figure out Retroactive price update account.
-- ---------------------------------------------
  l_stmt_num := 10;

  select nvl(retroprice_adj_account_id,-1)
  into l_acct_rec.account
  from rcv_parameters
  where organization_id = i_ae_txn_rec.organization_id;

  if (i_ae_txn_rec.primary_quantity < 0) then
     l_dr_flag := "FALSE";
  else
     l_dr_flag := "TRUE";
  end if;

  l_acct_line_type := 31;

  select count(*)
  into l_ele_exist
  from mtl_pac_actual_cost_details mpacd
  where mpacd.transaction_id = i_ae_txn_rec.transaction_id
  and mpacd.pac_period_id = i_ae_txn_rec.accounting_period_id
  and mpacd.cost_group_id = i_ae_txn_rec.cost_group_id;

  if (l_ele_exist = 0) then
    raise no_txn_det_error;
  end if;

  l_stmt_num := 40;

  select sum(nvl(actual_cost,0))
  into l_cost
  from mtl_pac_actual_cost_details
  where transaction_id = i_ae_txn_rec.transaction_id
  and pac_period_id = i_ae_txn_rec.accounting_period_id
  and cost_group_id = i_ae_txn_rec.cost_group_id;

  l_stmt_num := 56;

  l_ae_line_rec.transaction_value := abs(l_qty) * l_cost;
  l_ae_line_rec.resource_id := NULL;
  l_ae_line_rec.cost_element_id := 1;
  l_ae_line_rec.ae_line_type := 31;
  l_ae_line_rec.account := l_acct_rec.account;


  insert_account (i_ae_txn_rec,
                  i_ae_curr_rec,
                  l_dr_flag,
                  l_ae_line_rec,
                  l_ae_line_tbl,
                  l_err_rec);



      -- check error
      if(l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null) then
      raise process_error;
      end if;

-- Toggle the Debit Flag.
-- ----------------------
  l_dr_flag := not l_dr_flag;

-- Get acct_line_type, elemental flag, ovhd flag and acct_id.
-- ----------------------------------------------------------
  l_acct_rec.mat_account := '';
  l_acct_rec.mat_ovhd_account := '';
  l_acct_rec.res_account := '';
  l_acct_rec.osp_account := '';
  l_acct_rec.ovhd_account := '';

  l_acct_rec.account := i_ae_txn_rec.dist_acct_id;
  l_elemental := 0;
  l_ovhd_absp := 0;
  l_acct_line_type := 16;

-- Then post to the offsetting accounts.
-- -------------------------------------
  offset_accounts(i_ae_txn_rec,
                  i_ae_curr_rec,
                  l_acct_line_type,
                  l_elemental,
                  l_ovhd_absp,
                  l_dr_flag,
                  l_acct_rec,
                  l_ae_line_tbl,
                  l_err_rec);
  -- check error
  if (l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
     raise process_error;
  end if;


  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Cost_consigned_update_txn >> ');
  END IF;

EXCEPTION

  when process_error then
  o_ae_err_rec.l_err_num := l_err_rec.l_err_num;
  o_ae_err_rec.l_err_code := l_err_rec.l_err_code;
  o_ae_err_rec.l_err_msg := l_err_rec.l_err_msg;

  when no_txn_det_error then
  o_ae_err_rec.l_err_num := 30010;
  o_ae_err_rec.l_err_code := 'CST_NO_TXN_DET';
  FND_MESSAGE.set_name('BOM', 'CST_NO_TXN_DET');
  o_ae_err_rec.l_err_msg := FND_MESSAGE.Get;

  when others then
  o_ae_err_rec.l_err_num := SQLCODE;
  o_ae_err_rec.l_err_code := '';
  o_ae_err_rec.l_err_msg := 'CSTPAPBR.inv_cost_txn' || to_char(l_stmt_num) ||
  substr(SQLERRM,1,180);

END cost_consigned_update_txn;




procedure encumbrance_account(
  i_ae_txn_rec                IN        CSTPALTY.cst_ae_txn_rec_type,
  i_ae_curr_rec               IN        CSTPALTY.cst_ae_curr_rec_type,
  l_ae_line_tbl               IN OUT NOCOPY    CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec                OUT NOCOPY       CSTPALTY.cst_ae_err_rec_type
) IS
  l_acct        NUMBER;
  l_acct_line_type NUMBER;
  l_ae_line_rec                 CSTPALTY.cst_ae_line_rec_type;
  l_stmt_num    NUMBER;
  l_dr_flag                             BOOLEAN;
  process_error exception;
  l_err_rec                             CSTPALTY.cst_ae_err_rec_type;
BEGIN
  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Encumbrance_account <<');
  END IF;
-- Initialize variables.
-- ---------------------
  l_err_rec.l_err_num := 0;
  l_err_rec.l_err_code := '';
  l_err_rec.l_err_msg := '';

  l_stmt_num := 10;

  IF (i_ae_txn_rec.encum_amount < 0) THEN
    l_dr_flag := TRUE;
  ELSE
    l_dr_flag := FALSE;
  END IF;

      l_acct_line_type := 15;
      l_ae_line_rec.transaction_value := abs(i_ae_txn_rec.encum_amount);
      l_ae_line_rec.resource_id := NULL;
      l_ae_line_rec.cost_element_id := NULL;
      l_ae_line_rec.actual_flag := 'E';
      l_ae_line_rec.encum_type_id := i_ae_txn_rec.encum_type_id;
      l_ae_line_rec.ae_line_type := 15;
      l_ae_line_rec.account := i_ae_txn_rec.encum_account;
      insert_account (i_ae_txn_rec,
                      i_ae_curr_rec,
                      l_dr_flag,
                      l_ae_line_rec,
                      l_ae_line_tbl,
                      l_err_rec);

      -- check error
      if(l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null) then
      raise process_error;
      end if;

  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Encumbrance_account <<');
  END IF;

EXCEPTION

  when process_error then
  o_ae_err_rec.l_err_num := l_err_rec.l_err_num;
  o_ae_err_rec.l_err_code := l_err_rec.l_err_code;
  o_ae_err_rec.l_err_msg := l_err_rec.l_err_msg;

  when others then
  o_ae_err_rec.l_err_num := SQLCODE;
  o_ae_err_rec.l_err_code := '';
  o_ae_err_rec.l_err_msg := 'CSTPAPBR.inv_cost_txn' || to_char(l_stmt_num) ||
  substr(SQLERRM,1,180);

END encumbrance_account;


-- ===================================================================
-- Inventory Accounts.
-- ===================================================================

-- Expense Account should be from Category Accounts assigned to
-- Legal Entity-CG-CT and Item Category. Ignore the account passed
-- since this used to be from Subinventory

procedure inventory_accounts(
  i_ae_txn_rec          IN            CSTPALTY.cst_ae_txn_rec_type,
  i_ae_curr_rec         IN            CSTPALTY.cst_ae_curr_rec_type,
  i_exp_flag            IN            BOOLEAN,
  i_exp_account         IN      NUMBER,
  i_dr_flag             IN            BOOLEAN,
  l_ae_line_tbl         IN OUT NOCOPY  CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec          OUT NOCOPY           CSTPALTY.cst_ae_err_rec_type,
  i_intransit_flag      IN NUMBER
) IS
  l_cost                        NUMBER;
  l_ae_line_rec                 CSTPALTY.cst_ae_line_rec_type;
  l_ele_exist                         NUMBER;
  l_acct_exist                  NUMBER;
  l_stmt_num                          NUMBER := 0;
  l_api_name   CONSTANT VARCHAR2(30)    := 'CSTPAPBR.inventory_accounts';

  l_expense_account             NUMBER;

  l_err_rec                     CSTPALTY.cst_ae_err_rec_type;
  l_acct_rec                    CSTPALTY.cst_ae_acct_rec_type;

  /* Bug 3123936: Propogation of 2896193 */
  l_dr_flag                     BOOLEAN;
  l_var                         NUMBER;

  process_error                       EXCEPTION;
  no_cg_acct_error              EXCEPTION;
  no_mfca_acct_error            EXCEPTION;
  no_txn_det_error              EXCEPTION;
BEGIN

  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ': begin <<');
  END IF;
-- initialize variables.
-- ---------------------
  l_err_rec.l_err_num := 0;
  l_err_rec.l_err_code := '';
  l_err_rec.l_err_msg := '';
  l_cost := '';

  l_stmt_num := 15;

 select count(legal_entity_id) /* changed for bug no. 4586534 */
  into l_acct_exist
  from mtl_fiscal_cat_accounts
  where legal_entity_id = i_ae_txn_rec.legal_entity_id
    and cost_type_id    = i_ae_txn_rec.cost_type_id
    and cost_group_id   = i_ae_txn_rec.cost_group_id
    and category_id     = i_ae_txn_rec.category_id;

  if (l_acct_exist = 0) then
    fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num ||
           ': Category : '||to_char(i_ae_txn_rec.category_id) ||' has no accounts defined');
    raise no_mfca_acct_error;
  end if;

  l_stmt_num := 20;

  select nvl(material_account,-1),
         nvl(material_overhead_account,-1),
         nvl(resource_account,-1),
         nvl(outside_processing_account,-1),
         nvl(overhead_account,-1),
         nvl(expense_account, -1)
    into l_acct_rec.mat_account,
         l_acct_rec.mat_ovhd_account,
         l_acct_rec.res_account,
         l_acct_rec.osp_account,
         l_acct_rec.ovhd_account,
         l_expense_account
    from mtl_fiscal_cat_accounts
  where legal_entity_id = i_ae_txn_rec.legal_entity_id
    and cost_type_id    = i_ae_txn_rec.cost_type_id
    and cost_group_id   = i_ae_txn_rec.cost_group_id
    and category_id     = i_ae_txn_rec.category_id;

  l_stmt_num := 25;

  /* PAC Enhancements for R12: Include intransit line type as well */
  if i_exp_flag then
    l_ae_line_rec.ae_line_type := 2;
  elsif (i_intransit_flag = 1) then
    l_ae_line_rec.ae_line_type := 14;
  else
    l_ae_line_rec.ae_line_type := 1;
  end if;

  l_stmt_num := 30;

  select count(transaction_id)
  into l_ele_exist
  from mtl_pac_actual_cost_details mpacd
  where mpacd.transaction_id = i_ae_txn_rec.transaction_id
  and mpacd.pac_period_id = i_ae_txn_rec.accounting_period_id
  and mpacd.cost_group_id = i_ae_txn_rec.cost_group_id
   and rownum < 2; /* 4586534 added rownum filter for perf as its only existence check */

  if (l_ele_exist = 0) then
    raise no_txn_det_error;
  end if;

  FOR cost_element IN 1..5 loop

    l_stmt_num := 40;
    select sum(nvl(actual_cost,0)),
    sum(nvl(variance_amount,0)) /* Bug 3123936: Prop of 2896193 */
    into l_cost, l_var
    from mtl_pac_actual_cost_details
    where transaction_id = i_ae_txn_rec.transaction_id
    and pac_period_id = i_ae_txn_rec.accounting_period_id
    and cost_group_id = i_ae_txn_rec.cost_group_id
    and cost_element_id = cost_element;

    if (l_cost is not null) then  /* IF THERE EXISTS A COST FOR THE COST ELEMENT */

      l_stmt_num := 45;
      l_ae_line_rec.account := CSTPAPHK.get_account_id (
                                        i_ae_txn_rec.transaction_id,
                                        i_ae_txn_rec.legal_entity_id,
                                        i_ae_txn_rec.cost_type_id,
                                        i_ae_txn_rec.cost_group_id,
                                        i_dr_flag,
                                        l_ae_line_rec.ae_line_type,
                                        cost_element,
                                        NULL,
                                        i_ae_txn_rec.subinventory_code,
                                        i_exp_flag,
                                        l_err_rec.l_err_num,
                                        l_err_rec.l_err_code,
                                        l_err_rec.l_err_msg);
      -- check error
      if(l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null) then
      raise process_error;
      end if;

      if (l_ae_line_rec.account = -1) then

          l_stmt_num := 50;

          if i_exp_flag then
             l_ae_line_rec.account := l_expense_account;
             IF g_debug_flag = 'Y' THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,  l_api_name || ': ' || l_stmt_num || ': Expense Account: '||to_char(l_expense_account));
             END IF;
          else
            /* changed for bug no. 4586534 */
             IF cost_element = 1 THEN
                l_ae_line_rec.account :=  l_acct_rec.mat_account;
             ELSIF cost_element = 2 THEN
                l_ae_line_rec.account :=  l_acct_rec.mat_ovhd_account;
             ELSIF cost_element = 3 THEN
                l_ae_line_rec.account :=  l_acct_rec.res_account;
             ELSIF cost_element = 4 THEN
                l_ae_line_rec.account :=  l_acct_rec.osp_account;
             ELSIF cost_element = 5 THEN
                l_ae_line_rec.account :=  l_acct_rec.ovhd_account;
             END IF;
          end if;

      end if;

      l_stmt_num := 56;


      /* Bug 3213936: Propogation of 2896193
         Consider any variance when determining transaction_value */
      l_ae_line_rec.transaction_value := abs(i_ae_txn_rec.primary_quantity * l_cost - l_var);
      l_ae_line_rec.resource_id := NULL;
      l_ae_line_rec.cost_element_id := cost_element;

      IF g_debug_flag = 'Y' THEN
        fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ': Insert element ' || cost_element);
      END IF;

      insert_account (i_ae_txn_rec,
                      i_ae_curr_rec,
                      i_dr_flag,
                      l_ae_line_rec,
                      l_ae_line_tbl,
                      l_err_rec);

      -- check error
      if(l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null) then
        raise process_error;
      end if;

    else
      IF g_debug_flag = 'Y' THEN
        fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ': No cost for element ' || cost_element);
      END IF;
    end if;

  end loop;

/* Bug 3213936: Propogation of 2896193 : Start */

    select sum(nvl(variance_amount,0))
    into l_var
    from mtl_pac_actual_cost_details
    where transaction_id = i_ae_txn_rec.transaction_id
    and pac_period_id = i_ae_txn_rec.accounting_period_id
    and cost_group_id = i_ae_txn_rec.cost_group_id;

    IF (l_var <> 0 AND (NOT i_exp_flag)) THEN
            fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ': Creating Variance Entry');
            l_stmt_num := 60;
            l_ae_line_rec.ae_line_type := 13;

            IF (l_var > 0)
            THEN l_dr_flag := "TRUE";
            ELSE l_dr_flag := "FALSE";
            END IF;

            l_stmt_num := 70;

            /* Bug 3123936: Propogation of 3367784
               Added filter on legal_entity_id and cost_Type_id */

            SELECT nvl(cost_variance_account,-1)
              INTO l_ae_line_rec.account
              FROM cst_org_cost_group_accounts
             WHERE cost_group_id=i_ae_txn_rec.cost_group_id
              AND  legal_entity_id = i_ae_txn_rec.legal_entity_id
              AND cost_type_id = i_ae_txn_rec.cost_type_id;

           l_stmt_num := 80;
            l_ae_line_rec.transaction_value := abs(l_var);
            l_ae_line_rec.resource_id := NULL;
            l_ae_line_rec.cost_element_id := NULL;
            insert_account (i_ae_txn_rec,
                            i_ae_curr_rec,
                            l_dr_flag,
                            l_ae_line_rec,
                            l_ae_line_tbl,
                            l_err_rec);
     END if;
/* Bug 3213936 : End */


  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ': return >>');
  END IF;

EXCEPTION

  when process_error then
  o_ae_err_rec.l_err_num := l_err_rec.l_err_num;
  o_ae_err_rec.l_err_code := l_err_rec.l_err_code;
  o_ae_err_rec.l_err_msg := l_err_rec.l_err_msg;

  when no_cg_acct_error then
  o_ae_err_rec.l_err_num := 30007;
  o_ae_err_rec.l_err_code := 'CST_PAC_NO_CG_ACCTS';
  FND_MESSAGE.set_name('BOM', 'CST_PAC_NO_CG_ACCTS');
  o_ae_err_rec.l_err_msg := FND_MESSAGE.Get;

  when no_mfca_acct_error then
  o_ae_err_rec.l_err_num := 30008;
  o_ae_err_rec.l_err_code := 'CST_PAC_NO_MFCA_ACCTS';
  FND_MESSAGE.set_name('BOM', 'CST_PAC_NO_MFCA_ACCTS');
  o_ae_err_rec.l_err_msg := FND_MESSAGE.Get;

  when no_txn_det_error then
  o_ae_err_rec.l_err_num := 30009;
  o_ae_err_rec.l_err_code := 'CST_NO_TXN_DET';
  FND_MESSAGE.set_name('BOM', 'CST_NO_TXN_DET');
  o_ae_err_rec.l_err_msg := FND_MESSAGE.Get;

  when others then
  o_ae_err_rec.l_err_num := SQLCODE;
  o_ae_err_rec.l_err_code := '';
  o_ae_err_rec.l_err_msg := 'CSTPAPBR.inventory_accounts' || to_char(l_stmt_num) ||
  substr(SQLERRM,1,180);

END inventory_accounts;

-- ===================================================================
-- Offset Accounts.
-- ===================================================================
procedure offset_accounts(
   i_ae_txn_rec     IN          CSTPALTY.cst_ae_txn_rec_type,
   i_ae_curr_rec    IN          CSTPALTY.cst_ae_curr_rec_type,
   --i_ae_txn_rec     IN        CSTPALBR.cst_ae_txn_rec_type,
   --i_ae_curr_rec    IN        CSTPALBR.cst_ae_curr_rec_type,
   i_acct_line_type IN          NUMBER,
   i_elemental      IN          NUMBER,
   i_ovhd_absp      IN          NUMBER,
   i_dr_flag        IN          BOOLEAN,
   i_ae_acct_rec    IN          CSTPALTY.cst_ae_acct_rec_type,
   l_ae_line_tbl    IN OUT NOCOPY      CSTPALTY.cst_ae_line_tbl_type,
   o_ae_err_rec     OUT NOCOPY          CSTPALTY.cst_ae_err_rec_type
   --i_ae_acct_rec    IN        CSTPALBR.cst_ae_acct_rec_type,
   --l_ae_line_tbl    IN OUT      CSTPALBR.cst_ae_line_tbl_type,
   --o_ae_err_rec     OUT       CSTPALBR.cst_ae_err_rec_type
)IS
  l_ae_line_rec                 CSTPALTY.cst_ae_line_rec_type;
  --l_ae_line_rec               CSTPALBR.cst_ae_line_rec_type;
  l_ele_exist                   NUMBER;
  l_cost                            NUMBER;
  l_stmt_num                        NUMBER := 0;
  l_err_rec                     CSTPALTY.cst_ae_err_rec_type;
  l_acct_rec                    CSTPALTY.cst_ae_acct_rec_type;
  --l_err_rec                   CSTPALBR.cst_ae_err_rec_type;
  --l_acct_rec                  CSTPALBR.cst_ae_acct_rec_type;
  process_error                     EXCEPTION;
  no_txn_det_error              EXCEPTION;
  l_api_name   CONSTANT VARCHAR2(30)    := 'CSTPAPBR.offset_accounts';
BEGIN
  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ': begin << ');
    FND_FILE.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ': Elemental flag: ' ||to_char(i_elemental));
  END IF;
-- initialize variables.
-- ---------------------
  l_err_rec.l_err_num := 0;
  l_err_rec.l_err_code := '';
  l_err_rec.l_err_msg := '';

  if(i_elemental = 1) then

    l_stmt_num := 10;

    select count(transaction_id)
    into l_ele_exist
    from mtl_pac_actual_cost_details
    where transaction_id = i_ae_txn_rec.transaction_id
    and pac_period_id = i_ae_txn_rec.accounting_period_id
    and cost_group_id = i_ae_txn_rec.cost_group_id
    and rownum < 2; /* 4586534 added rownum filter for perf as its only existence check */

    if (l_ele_exist = 0) then
      raise no_txn_det_error;
    end if;

    FOR cost_element IN 1..5 loop

-- i_ovhd_absp indicates which level of material overhead we are
-- absorbtion and therefore need to go in an absorption account.
-- 2 means both levels and 1 means this level only.
-- -------------------------------------------------------------
      l_stmt_num := 20;

      select sum(nvl(actual_cost,0))
      into l_cost
      from mtl_pac_actual_cost_details
      where transaction_id = i_ae_txn_rec.transaction_id
      and pac_period_id = i_ae_txn_rec.accounting_period_id
      and cost_group_id = i_ae_txn_rec.cost_group_id
      and cost_element_id = cost_element
      and (cost_element_id <> 2
           OR
           (cost_element_id = 2
            and level_type = decode(i_ovhd_absp,1,2,2,0,level_type)));

      if (l_cost is not null) then

        l_stmt_num := 30;
        l_ae_line_rec.account := CSTPAPHK.get_account_id (
                                        i_ae_txn_rec.transaction_id,
                                        i_ae_txn_rec.legal_entity_id,
                                        i_ae_txn_rec.cost_type_id,
                                        i_ae_txn_rec.cost_group_id,
                                        i_dr_flag,
                                        i_acct_line_type,
                                        cost_element,
                                        NULL,
                                        i_ae_txn_rec.subinventory_code,
                                        "FALSE", ---  i_exp_flag
                                        l_err_rec.l_err_num,
                                        l_err_rec.l_err_code,
                                        l_err_rec.l_err_msg);
        -- check error
        if(l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null) then
        raise process_error;
        end if;

        if (l_ae_line_rec.account = -1) then
            l_stmt_num := 40;
          /* Changed for Bug No 4586534
          select decode(cost_element, 1, i_ae_acct_rec.mat_account,
                                  2, i_ae_acct_rec.mat_ovhd_account,
                                  3, i_ae_acct_rec.res_account,
                                  4, i_ae_acct_rec.osp_account,
                                  5, i_ae_acct_rec.ovhd_account)
          into l_ae_line_rec.account
          from dual;
          */
          IF cost_element = 1 THEN
                     l_ae_line_rec.account := i_ae_acct_rec.mat_account;
                   ELSIF cost_element = 2 THEN
                     l_ae_line_rec.account := i_ae_acct_rec.mat_ovhd_account;
                   ELSIF cost_element = 3 THEN
                     l_ae_line_rec.account := i_ae_acct_rec.res_account;
                   ELSIF cost_element = 4 THEN
                     l_ae_line_rec.account := i_ae_acct_rec.osp_account;
                   ELSIF cost_element = 5 THEN
                     l_ae_line_rec.account := i_ae_acct_rec.ovhd_account;
          END IF;
        end if;

        l_ae_line_rec.transaction_value := abs(i_ae_txn_rec.primary_quantity) * l_cost;
        l_ae_line_rec.resource_id := NULL;
        l_ae_line_rec.cost_element_id := cost_element;
        l_ae_line_rec.ae_line_type := i_acct_line_type;

        insert_account (i_ae_txn_rec,
                        i_ae_curr_rec,
                        i_dr_flag,
                        l_ae_line_rec,
                        l_ae_line_tbl,
                        l_err_rec);
        -- check error
        if(l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null) then
        raise process_error;
        end if;

      else
        IF g_debug_flag = 'Y' THEN
          fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || 'No cost for element ' || cost_element);
        END IF;
      end if;
    end loop;
  else
    l_stmt_num := 50;

    select nvl(sum(nvl(actual_cost,0)),0)
    into l_cost
    from mtl_pac_actual_cost_details
    where transaction_id = i_ae_txn_rec.transaction_id
    and pac_period_id = i_ae_txn_rec.accounting_period_id
    and cost_group_id = i_ae_txn_rec.cost_group_id
    and (cost_element_id <> 2
         OR
         (cost_element_id = 2
          and level_type = decode(i_ovhd_absp,1,2,2,0,level_type)));
    if (l_cost is not null) then

       l_stmt_num := 60;
       l_ae_line_rec.account := CSTPAPHK.get_account_id (
                                        i_ae_txn_rec.transaction_id,
                                        i_ae_txn_rec.legal_entity_id,
                                        i_ae_txn_rec.cost_type_id,
                                        i_ae_txn_rec.cost_group_id,
                                        i_dr_flag,
                                        i_acct_line_type,
                                        NULL,    --- cost_element
                                        NULL,
                                        i_ae_txn_rec.subinventory_code,
                                        "FALSE", --- i_exp_flag
                                        l_err_rec.l_err_num,
                                        l_err_rec.l_err_code,
                                        l_err_rec.l_err_msg);
       -- check error
       if(l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null) then
         raise process_error;
       end if;

       if (l_ae_line_rec.account = -1) then
        l_ae_line_rec.account := i_ae_acct_rec.account;
       end if;

       l_stmt_num := 70;

       l_ae_line_rec.transaction_value := abs(i_ae_txn_rec.primary_quantity) * l_cost;
       l_ae_line_rec.resource_id := NULL;
       l_ae_line_rec.cost_element_id := NULL;
       l_ae_line_rec.ae_line_type := i_acct_line_type;

       insert_account (i_ae_txn_rec,
                       i_ae_curr_rec,
                       i_dr_flag,
                       l_ae_line_rec,
                       l_ae_line_tbl,
                       l_err_rec);
       -- check error
       if(l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null) then
          raise process_error;
       end if;
    else
      IF g_debug_flag = 'Y' THEN
        fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || 'No Cost');
      END IF;
    end if;
  end if;
  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ': return >>');
  END IF;

  EXCEPTION

  when no_txn_det_error then
  o_ae_err_rec.l_err_num := 30010;
  o_ae_err_rec.l_err_code := 'CST_NO_TXN_DET';
  FND_MESSAGE.set_name('BOM', 'CST_NO_TXN_DET');
  o_ae_err_rec.l_err_msg := FND_MESSAGE.Get;

  when process_error then
  o_ae_err_rec.l_err_num := l_err_rec.l_err_num;
  o_ae_err_rec.l_err_code := l_err_rec.l_err_code;
  o_ae_err_rec.l_err_msg := l_err_rec.l_err_msg;

  when others then
  o_ae_err_rec.l_err_num := SQLCODE;
  o_ae_err_rec.l_err_code := '';
  o_ae_err_rec.l_err_msg := 'CSTPAPBR.offset_accounts' || to_char(l_stmt_num) ||
  substr(SQLERRM,1,180);

end offset_accounts;

-- ===================================================================
-- Overhead.
-- ===================================================================
procedure ovhd_accounts(
  i_ae_txn_rec    IN     CSTPALTY.cst_ae_txn_rec_type,
  i_ae_curr_rec   IN     CSTPALTY.cst_ae_curr_rec_type,
  i_dr_flag       IN     BOOLEAN,
  l_ae_line_tbl   IN OUT NOCOPY CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec    OUT NOCOPY    CSTPALTY.cst_ae_err_rec_type
)IS
  l_ae_line_rec         CSTPALTY.cst_ae_line_rec_type;
  l_err_rec             CSTPALTY.cst_ae_err_rec_type;
  l_res_id              NUMBER;
  l_cost                NUMBER;
  l_stmt_num            NUMBER;
  l_txn_cost_group_id   NUMBER;
  process_error         EXCEPTION;

  cursor mat_ovhds is
    select resource_id, actual_cost
    from mtl_pac_cost_subelements
    where transaction_id = i_ae_txn_rec.transaction_id
    and cost_group_id = i_ae_txn_rec.cost_group_id
    and pac_period_id = i_ae_txn_rec.accounting_period_id
    and cost_type_id = i_ae_txn_rec.cost_type_id
    and cost_element_id = 2;


BEGIN
  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Ovhd_accounts << ');
  END IF;

-- Initialize variables.
-- ---------------------
  l_err_rec.l_err_num := 0;
  l_err_rec.l_err_code := '';
  l_err_rec.l_err_msg := '';

  BEGIN
    l_stmt_num := 5;

    SELECT NVL(cost_group_id, -1)
    INTO   l_txn_cost_group_id
    FROM   cst_cost_group_assignments
    WHERE  organization_id = i_ae_txn_rec.organization_id;
  EXCEPTION
    WHEN no_data_found THEN
      l_txn_cost_group_id := -1;
  END;

  open mat_ovhds;

  loop
    fetch mat_ovhds into l_res_id, l_cost;
    exit when mat_ovhds%NOTFOUND;

    l_stmt_num := 10;
    l_ae_line_rec.account := CSTPAPHK.get_account_id (
                                        i_ae_txn_rec.transaction_id,
                                        i_ae_txn_rec.legal_entity_id,
                                        i_ae_txn_rec.cost_type_id,
                                        i_ae_txn_rec.cost_group_id,
                                        i_dr_flag,
                                        l_ae_line_rec.ae_line_type,
                                        2,       --- cost_element
                                        NULL,
                                        i_ae_txn_rec.subinventory_code,
                                        "FALSE", --- i_exp_flag
                                        l_err_rec.l_err_num,
                                        l_err_rec.l_err_code,
                                        l_err_rec.l_err_msg);
    -- check error
    if(l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null) then
      raise process_error;
    end if;

    if (l_ae_line_rec.account = -1) then

      if (i_ae_txn_rec.txn_action_id = 21 and l_txn_cost_group_id <> i_ae_txn_rec.cost_group_id) then

         -- Interorg shipment transaction, processed by receiving cost group: pick account from
         -- transfer organization
         l_stmt_num := 15;

         select nvl(absorption_account,-1)
         into l_ae_line_rec.account
         from bom_resources
         where resource_id = l_res_id
         and organization_id = i_ae_txn_rec.xfer_organization_id;
      else
         l_stmt_num := 20;

         select nvl(absorption_account,-1)
         into l_ae_line_rec.account
         from bom_resources
         where resource_id = l_res_id
         and organization_id = i_ae_txn_rec.organization_id;
      end if;

    end if;

    l_ae_line_rec.transaction_value := abs(i_ae_txn_rec.primary_quantity) * l_cost;
    l_ae_line_rec.ae_line_type := 3;
    l_ae_line_rec.cost_element_id := 2;
    l_ae_line_rec.resource_id := l_res_id;

    l_stmt_num := 25;
    insert_account (i_ae_txn_rec,
                    i_ae_curr_rec,
                    i_dr_flag,
                    l_ae_line_rec,
                    l_ae_line_tbl,
                    l_err_rec);

    -- check error
    if(l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null) then
       raise process_error;
    end if;

  end loop;
  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Ovhd_accounts >>');
  END IF;

  EXCEPTION

  when process_error then
  o_ae_err_rec.l_err_num := l_err_rec.l_err_num;
  o_ae_err_rec.l_err_code := l_err_rec.l_err_code;
  o_ae_err_rec.l_err_msg := l_err_rec.l_err_msg;

  when others then
  o_ae_err_rec.l_err_num := SQLCODE;
  o_ae_err_rec.l_err_code := '';
  o_ae_err_rec.l_err_msg := 'CSTPAPBR.ovhd_accounts' || to_char(l_stmt_num) ||
  substr(SQLERRM,1,180);

END ovhd_accounts;

-- ===================================================================
-- Insert Account.
-- ===================================================================
PROCEDURE insert_account(
  i_ae_txn_rec          IN      CSTPALTY.cst_ae_txn_rec_type,
  i_ae_curr_rec         IN      CSTPALTY.cst_ae_curr_rec_type,
  --i_ae_txn_rec          IN            CSTPALBR.cst_ae_txn_rec_type,
  --i_ae_curr_rec         IN            CSTPALBR.cst_ae_curr_rec_type,
  i_dr_flag             IN      BOOLEAN,
  i_ae_line_rec         IN      CSTPALTY.cst_ae_line_rec_type,
  l_ae_line_tbl         IN OUT NOCOPY  CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec          OUT NOCOPY      CSTPALTY.cst_ae_err_rec_type)
  --i_ae_line_rec         IN            CSTPALBR.cst_ae_line_rec_type,
  --l_ae_line_tbl         IN OUT  CSTPALBR.cst_ae_line_tbl_type,
  --o_ae_err_rec          OUT           CSTPALBR.cst_ae_err_rec_type)
IS
  l_err_rec                     CSTPALTY.cst_ae_err_rec_type;
  --l_err_rec                   CSTPALBR.cst_ae_err_rec_type;
  l_entered_value               NUMBER;
  l_accounted_value             NUMBER;
  l_exp_sub1                    NUMBER;
  l_stmt_num                         NUMBER := 0;
  next_record_avail             NUMBER;
  invalid_acct_error            EXCEPTION;

  l_api_name   CONSTANT VARCHAR2(30)    := 'CSTPAPBR.insert_account';

BEGIN
  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ': begin << ');
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
  l_ae_line_tbl(next_record_avail).ae_line_type := i_ae_line_rec.ae_line_type;

  l_stmt_num := 20;
  select
  meaning
  into
  l_ae_line_tbl(next_record_avail).description
  from
  mfg_lookups
  where lookup_type = 'CST_ACCOUNTING_LINE_TYPE'
  and lookup_code = l_ae_line_tbl(next_record_avail).ae_line_type;

  l_ae_line_tbl(next_record_avail).account :=
     i_ae_line_rec.account;

  l_stmt_num := 30;
   /* Bug 4586534. changed to PL/SQL logic based instead of select from dual
  select
  nvl(i_ae_curr_rec.alt_currency,i_ae_curr_rec.pri_currency)
  into l_ae_line_tbl(next_record_avail).currency_code
  from dual;
  */
  l_ae_line_tbl(next_record_avail).currency_code := nvl(i_ae_curr_rec.alt_currency,i_ae_curr_rec.pri_currency);

  l_stmt_num := 40;
  /*select
  decode(i_ae_curr_rec.alt_currency,
           i_ae_curr_rec.pri_currency,NULL,
         i_ae_curr_rec.currency_conv_date)
  into l_ae_line_tbl(next_record_avail).currency_conv_date
  from dual;
  */

  l_stmt_num := 50;
  /*select
  decode(i_ae_curr_rec.alt_currency,
  i_ae_curr_rec.pri_currency,NULL,
  decode(i_ae_curr_rec.currency_conv_rate,-1,NULL,i_ae_curr_rec.currency_conv_rate))
  into l_ae_line_tbl(next_record_avail).currency_conv_rate
  from dual;
   */
   IF i_ae_curr_rec.alt_currency = i_ae_curr_rec.pri_currency THEN
      l_ae_line_tbl(next_record_avail).currency_conv_date := NULL;
      l_ae_line_tbl(next_record_avail).currency_conv_rate := NULL;
      l_ae_line_tbl(next_record_avail).currency_conv_type := NULL;

   ELSE
      IF i_ae_curr_rec.currency_conv_rate = -1 THEN
         l_ae_line_tbl(next_record_avail).currency_conv_rate := NULL;
      ELSE
         l_ae_line_tbl(next_record_avail).currency_conv_rate := i_ae_curr_rec.currency_conv_rate;
      END IF;

      l_ae_line_tbl(next_record_avail).currency_conv_date := i_ae_curr_rec.currency_conv_date;
      l_ae_line_tbl(next_record_avail).currency_conv_type := i_ae_curr_rec.currency_conv_type;
   END IF;

  l_stmt_num := 60;
  /*select
  decode(i_ae_curr_rec.alt_currency,
         i_ae_curr_rec.pri_currency,NULL,
         i_ae_curr_rec.currency_conv_type)
  into l_ae_line_tbl(next_record_avail).currency_conv_type
  from dual;
  */
  l_stmt_num := 70;
  select decode(i_ae_curr_rec.alt_currency,NULL, NULL,
                i_ae_curr_rec.pri_currency, NULL,
                decode(c2.minimum_accountable_unit,
                       NULL,
                       round(i_ae_line_rec.transaction_value/nvl(i_ae_curr_rec.currency_conv_rate,1),
                       c2.precision),
                round(i_ae_line_rec.transaction_value/nvl(i_ae_curr_rec.currency_conv_rate,1)
                      /c2.minimum_accountable_unit)
                      * c2.minimum_accountable_unit )),
         decode(c1.minimum_accountable_unit,
                NULL, round(i_ae_line_rec.transaction_value, c1.precision),
                round(i_ae_line_rec.transaction_value/c1.minimum_accountable_unit)
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



  if (i_dr_flag) then

      l_ae_line_tbl(next_record_avail).entered_dr        := nvl(l_entered_value,l_accounted_value);
      l_ae_line_tbl(next_record_avail).entered_cr      := NULL;
      l_ae_line_tbl(next_record_avail).accounted_dr      := l_accounted_value;
      l_ae_line_tbl(next_record_avail).accounted_cr    := NULL;

      IF g_debug_flag = 'Y' THEN
        fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ': Debit: ' ||
                                l_ae_line_tbl(next_record_avail).description || ' ' || l_accounted_value);
      END IF;
  else
      l_ae_line_tbl(next_record_avail).entered_cr        := nvl(l_entered_value,l_accounted_value);
      l_ae_line_tbl(next_record_avail).entered_dr      := NULL;
      l_ae_line_tbl(next_record_avail).accounted_cr      := l_accounted_value;
      l_ae_line_tbl(next_record_avail).accounted_dr    := NULL;

      IF g_debug_flag = 'Y' THEN
        fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ': Credit: ' ||
                                l_ae_line_tbl(next_record_avail).description || ' ' || l_accounted_value);
      END IF;

  end if;

  l_ae_line_tbl(next_record_avail).source_table  := i_ae_txn_rec.source_table;
  l_ae_line_tbl(next_record_avail).source_id := i_ae_txn_rec.transaction_id;

  l_stmt_num := 80;
  /*
  select  decode(i_ae_txn_rec.primary_quantity,0,0,
  abs(i_ae_line_rec.transaction_value/i_ae_txn_rec.primary_quantity))
  into l_ae_line_tbl(next_record_avail).rate_or_amount
  from dual;
  */

  IF (i_ae_txn_rec.primary_quantity = 0) THEN
    l_ae_line_tbl(next_record_avail).rate_or_amount := 0;
  ELSE
    l_ae_line_tbl(next_record_avail).rate_or_amount := abs(i_ae_line_rec.transaction_value/i_ae_txn_rec.primary_quantity);
  END IF;

  IF g_debug_flag = 'Y' THEN
     fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ': Rate or amount: ' ||
                                l_ae_line_tbl(next_record_avail).rate_or_amount);
  END IF;

  l_ae_line_tbl(next_record_avail).basis_type    := 1;
  l_ae_line_tbl(next_record_avail).resource_id   :=
  i_ae_line_rec.resource_id;
  l_ae_line_tbl(next_record_avail).cost_element_id :=
  i_ae_line_rec.cost_element_id;

  l_ae_line_tbl(next_record_avail).activity_id   := NULL;
  l_ae_line_tbl(next_record_avail).repetitive_schedule_id := NULL;
  l_ae_line_tbl(next_record_avail).overhead_basis_factor         := NULL;
  l_ae_line_tbl(next_record_avail).basis_resource_id := NULL;
  l_ae_line_tbl(next_record_avail).actual_flag := i_ae_line_rec.actual_flag;
  l_ae_line_tbl(next_record_avail).encum_type_id := i_ae_line_rec.encum_type_id;
  l_ae_line_tbl(next_record_avail).wip_entity_id := i_ae_line_rec.wip_entity_id;

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

  if (i_ae_txn_rec.txn_action_id = 3) then
    if (i_ae_txn_rec.cost_group_id = i_ae_txn_rec.xfer_cost_group_id) then
      select decode(asset_inventory,1,0,1)
      into l_exp_sub1
      from mtl_secondary_inventories
      where secondary_inventory_name = i_ae_txn_rec.subinventory_code
      and organization_id = i_ae_txn_rec.organization_id;
      if (l_exp_sub1 = 1) then
        l_ae_line_tbl(next_record_avail).reference2 := i_ae_txn_rec.xfer_organization_id;
      end if;
    end if;
  end if;

  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ': return >> ');
  END IF;

  EXCEPTION

  when invalid_acct_error then
  o_ae_err_rec.l_err_num := 30011;
  o_ae_err_rec.l_err_code := 'CST_NO_TXN_INVALID_ACCOUNT';
  FND_MESSAGE.set_name('BOM', 'CST_NO_TXN_INVALID_ACCOUNT');
  o_ae_err_rec.l_err_msg := FND_MESSAGE.Get;

  when others then
  o_ae_err_rec.l_err_num := SQLCODE;
  o_ae_err_rec.l_err_code := '';
  o_ae_err_rec.l_err_msg := 'CSTPAPBR.insert_account' || to_char(l_stmt_num) ||
  substr(SQLERRM,1,180);

end insert_account;

-- ===================================================================
-- Balance Account.
-- ===================================================================
procedure balance_account (
   l_ae_line_tbl               IN OUT NOCOPY    CSTPALTY.cst_ae_line_tbl_type,
   o_ae_err_rec                OUT NOCOPY       CSTPALTY.cst_ae_err_rec_type)
  --(l_ae_line_tbl               IN OUT    CSTPALBR.cst_ae_line_tbl_type,
   --o_ae_err_rec                OUT       CSTPALBR.cst_ae_err_rec_type)
IS
  l_ent_value                   NUMBER := 0;
  l_acc_value                   NUMBER := 0;
  l_last_rec                    NUMBER;
  l_stmt_num                    NUMBER := 0;
  l_api_name   CONSTANT VARCHAR2(30)    := 'CSTPAPBR.balance_account';
BEGIN
  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ': begin << ');
  END IF;

  if (l_ae_line_tbl.exists(1)) then
     l_stmt_num := 10;
     For i in l_ae_line_tbl.FIRST .. l_ae_line_tbl.LAST loop
       l_ent_value := l_ent_value + nvl(l_ae_line_tbl(i).entered_dr,0) - nvl(l_ae_line_tbl(i).entered_cr,0);
       l_acc_value := l_acc_value + nvl(l_ae_line_tbl(i).accounted_dr,0) - nvl(l_ae_line_tbl(i).accounted_cr,0);
     end loop;

     if (l_ent_value = 0 and l_acc_value = 0) then
        IF g_debug_flag = 'Y' THEN
           fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ': return >> No balancing done.');
        END IF;
        return;
     end if;

     l_stmt_num := 20;
     l_last_rec := l_ae_line_tbl.LAST;
     if l_ae_line_tbl(l_last_rec).accounted_dr is not NULL then
       l_ae_line_tbl(l_last_rec).accounted_dr :=
        l_ae_line_tbl(l_last_rec).accounted_dr - l_acc_value;
       l_ae_line_tbl(l_last_rec).entered_dr :=
        l_ae_line_tbl(l_last_rec).entered_dr - l_ent_value;
        IF g_debug_flag = 'Y' THEN
           fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ': adjust debit by: ' || l_acc_value);
        END IF;
     elsif l_ae_line_tbl(l_last_rec).accounted_cr is not NULL then
       l_ae_line_tbl(l_last_rec).accounted_cr :=
        l_ae_line_tbl(l_last_rec).accounted_cr + l_acc_value;
       l_ae_line_tbl(l_last_rec).entered_cr :=
        l_ae_line_tbl(l_last_rec).entered_cr + l_ent_value;
        IF g_debug_flag = 'Y' THEN
           fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ': adjust credit by: ' || l_acc_value);
        END IF;
     end if;
  end if;

  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ': return >> ');
  END IF;

EXCEPTION

  when others then
  o_ae_err_rec.l_err_num := SQLCODE;
  o_ae_err_rec.l_err_code := '';
  o_ae_err_rec.l_err_msg := 'CSTPAPBR.balance_account' || to_char(l_stmt_num) ||
  substr(SQLERRM,1,180);

END balance_account;

/* currency stuff !! */
/* dont have material ovhd variance account, so using material variance acct */

-- ===================================================================
-- Controls line creation for WIP transactions.
-- ===================================================================
procedure create_wip_ae_lines(
  --i_ae_txn_rec          IN     CSTPALBR.cst_ae_txn_rec_type,
  --o_ae_line_rec_tbl     OUT    CSTPALBR.cst_ae_line_tbl_type,
  --o_ae_err_rec          OUT    CSTPALBR.cst_ae_err_rec_type
  i_ae_txn_rec          IN     CSTPALTY.cst_ae_txn_rec_type,
  o_ae_line_rec_tbl     OUT NOCOPY    CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec          OUT NOCOPY    CSTPALTY.cst_ae_err_rec_type
) IS
  l_ae_line_tbl                CSTPALTY.cst_ae_line_tbl_type := CSTPALTY.cst_ae_line_tbl_type();
  l_ae_curr_rec                CSTPALTY.cst_ae_curr_rec_type;

  l_ae_enc_curr_rec            CSTPALTY.cst_ae_curr_rec_type;  -- BUG#9356654

  l_ae_line_rec                CSTPALTY.cst_ae_line_rec_type;
  l_ae_err_rec                 CSTPALTY.cst_ae_err_rec_type;
  --l_ae_line_tbl                CSTPALBR.cst_ae_line_tbl_type := CSTPALBR.cst_ae_line_tbl_type();
  --l_ae_curr_rec                CSTPALBR.cst_ae_curr_rec_type;
  --l_ae_line_rec                CSTPALBR.cst_ae_line_rec_type;
  --l_ae_err_rec                 CSTPALBR.cst_ae_err_rec_type;
  l_acct_id1                   NUMBER;
  l_acct_id2                   NUMBER;
  l_dr_flag                    BOOLEAN;
  l_stmt_num                   NUMBER;
  l_ele_exist                  NUMBER;
  l_actual_value               NUMBER;
  l_actual_cost                NUMBER;
  process_error                EXCEPTION;
  no_txn_det_error             EXCEPTION;

-- Variables for eAM support in PAC

  l_return_status        VARCHAR(1)  := FND_API.G_RET_STS_SUCCESS;
  l_msg_return_status    VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count            NUMBER := 0;
  l_msg_data             VARCHAR2(8000) := '';
  l_api_message          VARCHAR2(1000) := '';
  l_cost_element         NUMBER;
  l_maint_cost_category  NUMBER;
  l_operation_dept_id    NUMBER;
  l_owning_dept_id       NUMBER;
  l_enc_rev              NUMBER;  --HYU

  Cursor  get_resource_id (l_transaction_id     number ,
                           l_accounting_period_id number ,
                           l_cost_group_id      number ,
                           l_cost_element       number)
  IS
          select distinct resource_id /* added distinct for bug 3116821 */
          from   wip_pac_actual_cost_details
          where  transaction_id = l_transaction_id
          and    pac_period_id  = l_accounting_period_id
          and    cost_group_id  = l_cost_group_id
          and    cost_element_id = l_cost_element;

BEGIN
  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Create_wip_lines << ');
    fnd_file.put_line(fnd_file.log,'Transaction type: '||to_char(i_ae_txn_rec.txn_type_id));
  END IF;

-- Initialize local variables.
-- ---------------------------
  l_ae_err_rec.l_err_num := 0;
  l_ae_err_rec.l_err_code := '';
  l_ae_err_rec.l_err_msg := '';

-- Populate the Currency Record Type.
-- ----------------------------------

  l_stmt_num := 10;
  select currency_code
  into l_ae_curr_rec.pri_currency
  from gl_sets_of_books
  where set_of_books_id = i_ae_txn_rec.set_of_books_id;

  l_ae_curr_rec.alt_currency := i_ae_txn_rec.currency_code;
  l_ae_curr_rec.currency_conv_date := i_ae_txn_rec.currency_conv_date;
  l_ae_curr_rec.currency_conv_type := i_ae_txn_rec.currency_conv_type;
  l_ae_curr_rec.currency_conv_rate := i_ae_txn_rec.currency_conv_rate;

  if (l_ae_curr_rec.alt_currency is not NULL and l_ae_curr_rec.currency_conv_rate = -1) then
    if (l_ae_curr_rec.alt_currency <> l_ae_curr_rec.pri_currency) then
      if (l_ae_curr_rec.currency_conv_type is NULL) then
        FND_PROFILE.get('CURRENCY_CONVERSION_TYPE', l_ae_curr_rec.currency_conv_type);
      end if;
      l_ae_curr_rec.currency_conv_rate := gl_currency_api.get_rate(i_ae_txn_rec.set_of_books_id,
                                                                l_ae_curr_rec.alt_currency,
                                                                i_ae_txn_rec.accounting_date,
                                                                l_ae_curr_rec.currency_conv_type);
    end if;
  end if;

-- Check if there are Cost Details.
-- --------------------------------
  l_stmt_num := 20;
  select count(transaction_id)
  into l_ele_exist
  from wip_pac_actual_cost_details mpacd
  where mpacd.transaction_id = i_ae_txn_rec.transaction_id
  and mpacd.pac_period_id = i_ae_txn_rec.accounting_period_id
  and mpacd.cost_group_id = i_ae_txn_rec.cost_group_id
  and rownum < 2; /* 4586534 added rownum filter for perf as its only existence check */

  if (l_ele_exist = 0) then
    raise no_txn_det_error;
  end if;

  select
         we.wip_entity_id
  into
       l_ae_line_rec.wip_entity_id
  from wip_transactions wt,
       wip_entities we
  where we.wip_entity_id = wt.wip_entity_id
  and wt.transaction_id = i_ae_txn_rec.transaction_id;

   /* Check if there are Cost Details. */

    IF (i_ae_txn_rec.txn_type_id = 17) THEN
    /* eAM support in PAC Enh - Direct Items */
        l_stmt_num := 30;

        SELECT  nvl(actual_value ,0) ,
                nvl(actual_cost ,0)
        INTO    l_actual_value,
                l_actual_cost
        FROM    wip_pac_actual_cost_details
        WHERE   transaction_id = i_ae_txn_rec.transaction_id
        AND     pac_period_id = i_ae_txn_rec.accounting_period_id
        AND     cost_group_id = i_ae_txn_rec.cost_group_id;

        /* Get the cost element for direct item */

        CST_EAMCOST_PUB.get_CostEle_for_DirectItem (
                    p_api_version       =>  1.0,
                    x_return_status     =>  l_return_status,
                    x_msg_count         =>  l_msg_count,
                    x_msg_data          =>  l_msg_data,
                    p_txn_id            =>  i_ae_txn_rec.transaction_id,
                    p_mnt_or_mfg        =>  2,
                    p_pac_or_perp       =>  1,
                    x_cost_element_id   =>  l_cost_element
            );

        IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
            FND_FILE.put_line(FND_FILE.log, l_msg_data);
            l_api_message := 'get_CostEle_for_DirectItem returned unexpected error';
            FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
            FND_MESSAGE.set_token('TEXT', l_api_message);
            FND_MSG_pub.add;
            raise fnd_api.g_exc_unexpected_error;
        END IF;

        IF (g_debug_flag = 'Y') THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'mfg cost_element_id: '||
            to_char(l_cost_element));
        END IF;

        l_stmt_num := 40;

        /* Bug: 5604125 Get the account from WDJ for the direct item cost element */
        SELECT  decode(l_cost_element, 1, nvl(material_account,-1),
                3, nvl(resource_account, -1),
                4, nvl(outside_processing_account, -1), -1)
        INTO    l_ae_line_rec.account
        FROM    wip_discrete_jobs
        WHERE   wip_entity_id = l_ae_line_rec.wip_entity_id;

        /* Set Debit Flag properly.
        -- ------------------------   */
        l_dr_flag := "TRUE";

        /* Set the other fields we will need in Insert_Account procedure.
        -- --------------------------------------------------------------*/

        l_stmt_num := 70;
        l_ae_line_rec.ae_line_type := 7;
        l_ae_line_rec.cost_element_id := l_cost_element;

        l_stmt_num := 80;
        l_ae_line_rec.transaction_value := l_actual_value;

        /* Call Insert Account.
        -- --------------------*/
        l_stmt_num := 90;
        CSTPAPBR.insert_account (i_ae_txn_rec,
                    l_ae_curr_rec,
                    l_dr_flag,
                    l_ae_line_rec,
                    l_ae_line_tbl,
                    l_ae_err_rec);

        /* check error */
        IF(l_ae_err_rec.l_err_num<>0
           AND l_ae_err_rec.l_err_num IS NOT NULL) THEN
            raise process_error;
        END IF;

        /* Toggle Debit Flag.
        -- ------------------ */
        l_stmt_num := 100;
        l_dr_flag := not l_dr_flag;

        /* Set the fields we will need in next Insert_Account calling.
        -- ----------------------------------------------------------- */
        l_stmt_num := 110;

        l_ae_line_rec.ae_line_type := 5;
        /* Accounting line type for credit will be Receiving Inspection */

        SELECT  RCV.receiving_account_id
        INTO    l_ae_line_rec.account
        FROM    rcv_parameters RCV , wip_transactions WT
        WHERE   WT.transaction_id = i_ae_txn_rec.transaction_id
        AND     WT.organization_id = RCV.organization_id;

        /* Call Insert Account.
        -- -------------------- */
        l_stmt_num := 120;
        CSTPAPBR.insert_account (i_ae_txn_rec,
                    l_ae_curr_rec,
                    l_dr_flag,
                    l_ae_line_rec,
                    l_ae_line_tbl,
                    l_ae_err_rec);

        IF(l_ae_err_rec.l_err_num<>0
           AND l_ae_err_rec.l_err_num IS NOT NULL) THEN
            raise process_error;
        END IF;

    ELSE -- Normal processing

-- For each Cost Element.
-- ----------------------
  FOR cost_element IN 1..5 loop

/*  Added cost element 5 to txn_type 1 to account for
    resouce based overheads
    Bug 2250142
*/
    if (i_ae_txn_rec.txn_type_id = 1 and (cost_element = 3 or cost_element = 5)) or
       (i_ae_txn_rec.txn_type_id = 2 and cost_element = 5) or
       (i_ae_txn_rec.txn_type_id = 3 and (cost_element = 4 or cost_element = 5)) or
       (i_ae_txn_rec.txn_type_id = 6)
    then

    Open get_resource_id( i_ae_txn_rec.transaction_id ,
                        i_ae_txn_rec.accounting_period_id ,
                        i_ae_txn_rec.cost_group_id ,
                        cost_element );
    loop
       fetch get_resource_id into l_ae_line_rec.resource_id ;
       exit  when get_resource_id%NOTFOUND;

-- Get the cost.
-- -------------
       If  i_ae_txn_rec.txn_type_id <> 2 then
       l_stmt_num := 130;
        select sum(nvl(actual_value,0)),
              sum(nvl(actual_cost,0))
        into l_actual_value,
            l_actual_cost
        from wip_pac_actual_cost_details
        where transaction_id = i_ae_txn_rec.transaction_id
        and pac_period_id = i_ae_txn_rec.accounting_period_id
        and cost_group_id = i_ae_txn_rec.cost_group_id
        and cost_element_id = cost_element
        and nvl(resource_id,-999) = nvl(l_ae_line_rec.resource_id,-999);
       Else
       l_stmt_num := 140;
        select  nvl(actual_value ,0) ,
                nvl(actual_cost ,0)
        into    l_actual_value,
                l_actual_cost
        from    wip_pac_actual_cost_details
        where   transaction_id = i_ae_txn_rec.transaction_id
        and     pac_period_id = i_ae_txn_rec.accounting_period_id
        and     cost_group_id = i_ae_txn_rec.cost_group_id
        and     cost_element_id = cost_element
        and     resource_id = l_ae_line_rec.resource_id ;
       End if ;

-- Process only if exists cost for the element.
-- --------------------------------------------
       if (i_ae_txn_rec.txn_type_id <> 6 and l_actual_value is not null) or
          (i_ae_txn_rec.txn_type_id = 6 and l_actual_cost is not null) then


-- Get the corresponding Accounts.
-- -------------------------------

          l_stmt_num := 145;
          l_ae_line_rec.account := CSTPAPHK.get_account_id (
                                        i_ae_txn_rec.transaction_id,
                                        i_ae_txn_rec.legal_entity_id,
                                        i_ae_txn_rec.cost_type_id,
                                        i_ae_txn_rec.cost_group_id,
                                        l_dr_flag,
                                        l_ae_line_rec.ae_line_type,
                                        cost_element,
                                        NULL,
                                        i_ae_txn_rec.subinventory_code,
                                        "FALSE", --- i_exp_flag
                                        l_ae_err_rec.l_err_num,
                                        l_ae_err_rec.l_err_code,
                                        l_ae_err_rec.l_err_msg);
          -- check error
          if(l_ae_err_rec.l_err_num<>0 and l_ae_err_rec.l_err_num is not null) then
          raise process_error;
          end if;

          if (l_ae_line_rec.account = -1) then
             l_stmt_num := 150;
             l_ae_line_rec.cost_element_id := cost_element;
             CSTPAPBR.get_accts (i_ae_txn_rec,
                                 l_ae_line_rec,
                                 l_ae_line_tbl,
                                 l_acct_id1,
                                 l_acct_id2,
                                 l_ae_err_rec);
             if (l_ae_err_rec.l_err_num <> 0 and l_ae_err_rec.l_err_num is not null) then
                 raise process_error;
             end if;
          end if;

-- Set Debit Flag properly.
-- ------------------------
          l_stmt_num := 160;
          if (i_ae_txn_rec.txn_type_id <> 6 and i_ae_txn_rec.primary_quantity > 0) or
             (i_ae_txn_rec.txn_type_id = 6 and l_actual_cost < 0) then
             l_dr_flag := "TRUE";
          else
             l_dr_flag := "FALSE";
          end if;

-- Set the other fields we will need in Insert_Account procedure.
-- --------------------------------------------------------------
          l_stmt_num := 170;
          l_ae_line_rec.ae_line_type := 7;
          l_ae_line_rec.account := l_acct_id1;
          l_ae_line_rec.cost_element_id := cost_element;

          l_stmt_num := 180;
          select decode(i_ae_txn_rec.txn_type_id, 6, abs(l_actual_cost), abs(l_actual_value))
          into l_ae_line_rec.transaction_value
          from dual;

-- Call Insert Account.
-- --------------------
          l_stmt_num := 190;
          CSTPAPBR.insert_account (i_ae_txn_rec,
                                  l_ae_curr_rec,
                                  l_dr_flag,
                                  l_ae_line_rec,
                                  l_ae_line_tbl,
                                  l_ae_err_rec);

          -- check error
          if(l_ae_err_rec.l_err_num<>0 and l_ae_err_rec.l_err_num is not null) then
          raise process_error;
          end if;

-- Toggle Debit Flag.
-- ------------------
          l_stmt_num := 200;
          l_dr_flag := not l_dr_flag;

-- Set the fields we will need in next Insert_Account calling.
-- -----------------------------------------------------------
          l_stmt_num := 210;
          select decode(i_ae_txn_rec.txn_type_id, 1, 4, 2, 3, 3, 4, 6, 8)
          into l_ae_line_rec.ae_line_type
          from dual;

          l_ae_line_rec.account := l_acct_id2;

-- Call Insert Account.
-- --------------------
          l_stmt_num := 220;
          CSTPAPBR.insert_account (i_ae_txn_rec,
                                  l_ae_curr_rec,
                                  l_dr_flag,
                                  l_ae_line_rec,
                                  l_ae_line_tbl,
                                  l_ae_err_rec);

          -- check error
          if(l_ae_err_rec.l_err_num<>0 and l_ae_err_rec.l_err_num is not null) then
          raise process_error;
          end if;
       end if;

      end loop ; -- get_resource_id

      close get_resource_id ;

    end if; -- i_ae_txn_rec.txn_type_id and cost_element combn check
  end loop; -- for cost_element 1 ..5

    END IF; -- eAM check

-- Take care of rounding errors.
-- -----------------------------
  l_stmt_num := 230;
  CSTPAPBR.balance_account (l_ae_line_tbl,
                           l_ae_err_rec);

  -- check error
  if(l_ae_err_rec.l_err_num <> 0 and l_ae_err_rec.l_err_num is not null) then
      raise process_error;
  end if;



/********************************************************************************
FP 12.1.3 bug 9356654 fix:
 ********************************************************************************/

--{BUG#9356654
   select
   encumbrance_reversal_flag
   into
   l_enc_rev
   from
   mtl_parameters
   where organization_id = i_ae_txn_rec.organization_id;

  IF g_debug_flag = 'Y' THEN
   fnd_file.put_line(fnd_file.log,'Organization_id : '||(i_ae_txn_rec.organization_id));
   fnd_file.put_line(fnd_file.log,'l_enc_rev : '||(l_enc_rev));
   fnd_file.put_line(fnd_file.log,'transaction_id : '||(i_ae_txn_rec.transaction_id));
  END IF;

  if (l_enc_rev = 1 and nvl(i_ae_txn_rec.encum_amount,0) <> 0) THEN
       l_ae_enc_curr_rec.pri_currency := l_ae_curr_rec.pri_currency;
       BEGIN
       SELECT currency_code
          ,   currency_conversion_date
          ,   currency_conversion_type
          ,   currency_conversion_rate
        INTO
              l_ae_enc_curr_rec.alt_currency
             ,l_ae_enc_curr_rec.currency_conv_date
             ,l_ae_enc_curr_rec.currency_conv_type
             ,l_ae_enc_curr_rec.currency_conv_rate
        FROM wip_transaction_accounts
        WHERE transaction_id = i_ae_txn_rec.transaction_id
        AND   accounting_line_type = 15;
        EXCEPTION
          WHEN no_data_found THEN
           l_ae_enc_curr_rec := l_ae_curr_rec;
        END;

      encumbrance_account
                         (i_ae_txn_rec,
                          l_ae_enc_curr_rec,
                          l_ae_line_tbl,
                          l_ae_err_rec);
     -- check error;
     if(l_ae_err_rec.l_err_num <> 0 and l_ae_err_rec.l_err_num is not null) then
        raise process_error;
     end if;

  end if;

--}

-- Return the lines pl/sql table.
-- ------------------------------
  l_stmt_num := 240;
  o_ae_line_rec_tbl := l_ae_line_tbl;
  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Create_wip_ae_lines >>');
  END IF;

EXCEPTION

  when no_txn_det_error then
  o_ae_err_rec.l_err_num := 30012;
  o_ae_err_rec.l_err_code := 'CST_NO_TXN_DET';
  FND_MESSAGE.set_name('BOM', 'CST_NO_TXN_DET');
  o_ae_err_rec.l_err_msg := FND_MESSAGE.Get;

  when process_error then
  o_ae_err_rec.l_err_num := l_ae_err_rec.l_err_num;
  o_ae_err_rec.l_err_code := l_ae_err_rec.l_err_code;
  o_ae_err_rec.l_err_msg := l_ae_err_rec.l_err_msg;

  when others then
  o_ae_err_rec.l_err_num := SQLCODE;
  o_ae_err_rec.l_err_code := '';
  o_ae_err_rec.l_err_msg := 'CSTPAPBR.create_wip_ae_lines : ' || to_char(l_stmt_num) ||' : '||
  substr(SQLERRM,1,180);

END create_wip_ae_lines;

-- ===================================================================
-- Get Account from the entities (Used in WIP transactions).
-- ===================================================================
procedure get_accts(
  i_ae_txn_rec                IN        CSTPALTY.cst_ae_txn_rec_type,
  i_ae_line_rec               IN        CSTPALTY.cst_ae_line_rec_type,
  l_ae_line_tbl               IN OUT NOCOPY    CSTPALTY.cst_ae_line_tbl_type,
  --i_ae_txn_rec                IN        CSTPALBR.cst_ae_txn_rec_type,
  --i_ae_line_rec               IN        CSTPALBR.cst_ae_line_rec_type,
  --l_ae_line_tbl               IN OUT    CSTPALBR.cst_ae_line_tbl_type,
  o_acct_id1                  OUT NOCOPY       NUMBER,
  o_acct_id2                  OUT NOCOPY       NUMBER,
  o_ae_err_rec                OUT NOCOPY       CSTPALTY.cst_ae_err_rec_type
  --o_ae_err_rec                OUT       CSTPALBR.cst_ae_err_rec_type
) IS
  l_stmt_num                            NUMBER;
  l_entity_type                         NUMBER;
  l_wip_entity_id                       NUMBER;
  l_line_id                             NUMBER;
  l_res_id                              NUMBER;
  l_acct_exist                                NUMBER;
  l_ae_err_rec                          CSTPALTY.cst_ae_err_rec_type;
  --l_ae_err_rec                          CSTPALBR.cst_ae_err_rec_type;
  no_dj_acct_error                      EXCEPTION;
  no_abs_acct_error                     EXCEPTION;
  no_wrs_acct_error                     EXCEPTION;
  no_wfs_acct_error                     EXCEPTION;
  process_error                         EXCEPTION;
BEGIN

  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Get_accts <<');
  END IF;

  IF i_ae_txn_rec.txn_type_id <> 6 THEN

    -- Get Absorption Account.
    -- -----------------------
    l_stmt_num := 10;
 select count(resource_id)
    into l_acct_exist
    from bom_resources
    where resource_id = i_ae_line_rec.resource_id
    and organization_id = i_ae_txn_rec.organization_id
    and rownum < 2; /* 4586534 added rownum filter for perf as its only existence check */

    if (l_acct_exist = 0) then
      raise no_abs_acct_error;
    end if;

    l_stmt_num := 20;
    select nvl(absorption_account,-1)
    into o_acct_id2
    from bom_resources
    where resource_id = i_ae_line_rec.resource_id
    and organization_id = i_ae_txn_rec.organization_id;

  END IF; -- check for i_ae_txn_rec.txn_type_id <> 6


-- Get Entity Type and Entity Id.
-- ------------------------------
-- Entity Types:
-- 1 - Discrete Jobs
-- 2 - Repetitive Assembly
-- 3 - Closed Discrete Jobs
-- 4 - Flow Schedule

  l_stmt_num := 30;
  select we.entity_type,
         we.wip_entity_id,
         wt.line_id
  into l_entity_type,
       l_wip_entity_id,
       l_line_id
  from wip_transactions wt,
       wip_entities we
  where we.wip_entity_id = wt.wip_entity_id
  and wt.transaction_id = i_ae_txn_rec.transaction_id;

  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log, 'Entity Type: ' ||to_char(l_entity_type));
  END IF;

  /* Bug 6937298 - Modified the If condition below to include lot-based jobs
  if (i_ae_txn_rec.txn_type_id <> 6 and l_entity_type in (1,3, 6, 7)) or
     (i_ae_txn_rec.txn_type_id = 6 and l_entity_type in (1,3, 6, 7)) then   -- Include eAM jobs also*/
  if l_entity_type in (1,3,5,6,7,8) then

-- Get Elemental Accounts from WDJ. For wip_txn_type = 6, get Elemental Variance Accounts, as well.
-- ------------------------------------------------------------------------------------------------
     l_stmt_num := 40;
     select count(wip_entity_id) /* Changed for Bug No. 4586534 */
     into l_acct_exist
     from wip_discrete_jobs
     where wip_entity_id = l_wip_entity_id;

     if (l_acct_exist = 0) then
       raise no_dj_acct_error;
     end if;

     l_stmt_num := 50;
     select decode(i_ae_line_rec.cost_element_id,
                      1, nvl(material_account,-1),
                      2, nvl(material_overhead_account,-1),
                      3, nvl(resource_account,-1),
                      4, nvl(outside_processing_account,-1),
                      5, nvl(overhead_account,-1)),
            --decode(i_ae_txn_rec.wip_txn_type,
            decode(i_ae_txn_rec.txn_type_id,
                      6,decode(i_ae_line_rec.cost_element_id,
                                  1, nvl(material_variance_account,-1),
                                  2, nvl(material_variance_account,-1),
                                  3, nvl(resource_variance_account,-1),
                                  4, nvl(outside_proc_variance_account,-1),
                                  5, nvl(overhead_variance_account,-1)),
                        o_acct_id2)
     into o_acct_id1,
          o_acct_id2
     from wip_discrete_jobs
     where wip_entity_id = l_wip_entity_id;
  elsif l_entity_type = 2 then

-- Get Elemental Accounts from WRS.
-- --------------------------------

     l_stmt_num := 60;
    select count(wip_entity_id) /* Changed for bug No 4586534 */
     into l_acct_exist
     from wip_repetitive_schedules
     where wip_entity_id = l_wip_entity_id
     and line_id = l_line_id
     and rownum  < 2; /* 4586534 added rownum check as its only existence check */

     if (l_acct_exist = 0) then
       raise no_wrs_acct_error;
     end if;

     l_stmt_num := 70;
     select decode(i_ae_line_rec.cost_element_id,
                      1, nvl(material_account,-1),
                      2, nvl(material_overhead_account,-1),
                      3, nvl(resource_account,-1),
                      4, nvl(outside_processing_account,-1),
                      5, nvl(overhead_account,-1))
     into o_acct_id1
     from wip_repetitive_schedules
     where wip_entity_id = l_wip_entity_id
     and line_id = l_line_id
     and rownum = 1;
  elsif l_entity_type = 4 then

-- Get Elemental Accounts from WFS.
-- --------------------------------

     l_stmt_num := 80;
     select count(wip_entity_id) /* Changed For bug No. 4586534 */
     into l_acct_exist
     from wip_flow_schedules
     where wip_entity_id = l_wip_entity_id;

     if (l_acct_exist = 0) then
       raise no_wfs_acct_error;
     end if;

     l_stmt_num := 90;
     select decode(i_ae_line_rec.cost_element_id,
                      1, nvl(material_account,-1),
                      2, nvl(material_overhead_account,-1),
                      3, nvl(resource_account,-1),
                      4, nvl(outside_processing_account,-1),
                      5, nvl(overhead_account,-1)),
            decode(i_ae_txn_rec.txn_type_id,
                      6,decode(i_ae_line_rec.cost_element_id,
                                  1, nvl(material_variance_account,-1),
                                  2, nvl(material_variance_account,-1),
                                  3, nvl(resource_variance_account,-1),
                                  4, nvl(outside_proc_variance_account,-1),
                                  5, nvl(overhead_variance_account,-1)),
                        o_acct_id2)
     into o_acct_id1,
          o_acct_id2
     from wip_flow_schedules
     where wip_entity_id = l_wip_entity_id;
  end if;
  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Get_accts >>');
  END IF;

EXCEPTION

  when no_abs_acct_error then
  o_ae_err_rec.l_err_num := 30013;
  o_ae_err_rec.l_err_code := 'CST_PAC_NO_TXN_ACCTS';
  FND_MESSAGE.set_name('BOM', 'CST_PAC_NO_TXN_ACCTS');
  o_ae_err_rec.l_err_msg := FND_MESSAGE.Get;

  when no_wrs_acct_error then
  o_ae_err_rec.l_err_num := 30014;
  o_ae_err_rec.l_err_code := 'CST_PAC_NO_TXN_ACCTS';
  FND_MESSAGE.set_name('BOM', 'CST_PAC_NO_TXN_ACCTS');
  o_ae_err_rec.l_err_msg := FND_MESSAGE.Get;

  when no_wfs_acct_error then
  o_ae_err_rec.l_err_num := 30015;
  o_ae_err_rec.l_err_code := 'CST_PAC_NO_TXN_ACCTS';
  FND_MESSAGE.set_name('BOM', 'CST_PAC_NO_TXN_ACCTS');
  o_ae_err_rec.l_err_msg := FND_MESSAGE.Get;

  when no_dj_acct_error then
  o_ae_err_rec.l_err_num := 30016;
  o_ae_err_rec.l_err_code := 'CST_PAC_NO_TXN_ACCTS';
  FND_MESSAGE.set_name('BOM', 'CST_PAC_NO_TXN_ACCTS');
  o_ae_err_rec.l_err_msg := FND_MESSAGE.Get;

  when process_error then
  o_ae_err_rec.l_err_num := l_ae_err_rec.l_err_num;
  o_ae_err_rec.l_err_code := l_ae_err_rec.l_err_code;
  o_ae_err_rec.l_err_msg := l_ae_err_rec.l_err_msg;

  when others then
  o_ae_err_rec.l_err_num := SQLCODE;
  o_ae_err_rec.l_err_code := '';
  o_ae_err_rec.l_err_msg := 'CSTPAPBR.get_accts ' || to_char(l_stmt_num) ||' '||
  substr(SQLERRM,1,180);

END get_accts;

-- ===================================================================
-- WIP Accounts.
-- ===================================================================
procedure WIP_accounts(
   i_ae_txn_rec     IN          CSTPALTY.cst_ae_txn_rec_type,
   i_ae_curr_rec    IN          CSTPALTY.cst_ae_curr_rec_type,
   i_acct_line_type IN          NUMBER,
   i_ovhd_absp      IN          NUMBER,
   i_dr_flag        IN          BOOLEAN,
   i_ae_acct_rec    IN          CSTPALTY.cst_ae_acct_rec_type,
   l_ae_line_tbl    IN OUT NOCOPY      CSTPALTY.cst_ae_line_tbl_type,
   o_ae_err_rec     OUT NOCOPY          CSTPALTY.cst_ae_err_rec_type
)IS
  l_ae_line_rec                 CSTPALTY.cst_ae_line_rec_type;
  l_ele_exist                   NUMBER;
  l_cost                        NUMBER;
  l_dr_flag                     BOOLEAN;
  l_wip_variance                NUMBER;
  l_stmt_num                    NUMBER;
  l_err_rec                     CSTPALTY.cst_ae_err_rec_type;
  l_acct_rec                    CSTPALTY.cst_ae_acct_rec_type;
  process_error                 EXCEPTION;
  no_txn_det_error              EXCEPTION;
BEGIN
  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'WIP_accounts << ');
  END IF;
-- initialize variables.
-- ---------------------
  l_err_rec.l_err_num := 0;
  l_err_rec.l_err_code := '';
  l_err_rec.l_err_msg := '';

     l_stmt_num := 10;
     SELECT COUNT(*)
     INTO   l_ele_exist
     FROM   MTL_PAC_ACTUAL_COST_DETAILS
     WHERE  transaction_id = i_ae_txn_rec.transaction_id
     AND    pac_period_id = i_ae_txn_rec.accounting_period_id
     AND    cost_group_id = i_ae_txn_rec.cost_group_id;

     IF (l_ele_exist = 0) THEN
       raise no_txn_det_error;
     END IF;

     FOR cost_element IN 1..5 LOOP

        ----------------------------------------------------------------------------
        -- wip_variance column value is NULL for txns otherthan Assembly Completion,
        -- Assembly Return,Assembly Scrap and Assembly Scrap returns.

        -- For Assembly Completion txn => wip_variance is non zero then,
        -- Following entries are created in WIP_accounts procedure
        --
        -- Account Name               Dr                   Cr
        -- ------------              ----                 ---
        -- WIP Variance               wip_variance
        -- WIP Valuation                                   wip_variance

        -- For Assembly Return txn => wip_variance is non zero then,
        -- Following entries are created  in WIP_accounts procedure
        --
        -- Account Name               Dr                   Cr
        -- ------------              ----                 ---
        -- WIP Variance                                   wip_variance
        -- WIP Valuation            wip_variance
        --
        -- For Assembly Scrap txn => wip_variance is non zero then,
        -- Following entries are created in WIP_accounts procedure
        --
        -- Account Name               Dr                   Cr
        -- ------------              ----                 ---
        -- WIP Valuation                                   wip_variance
        -- Scrap Account              0
        -- WIP variance Account       wip_variance


        -- For Scrap returns txn => wip_variance is non zero then,
        -- Following entries are created in WIP_accounts procedure
        --
        -- Account Name               Dr                   Cr
        -- ------------              ----                 ---
        -- WIP Valuation              wip_variance
        -- Scrap Account                                    0
        -- WIP variance Account                         wip_variance
        --
        ----------------------------------------------------------------------------
         -- i_ovhd_absp indicates which level of material overhead we are
        -- absorbtion and therefore need to go in an absorption account.
        -- 2 means both levels and 1 means this level only.
        -- -------------------------------------------------------------
              l_stmt_num := 20;
              SELECT SUM(nvl(actual_cost,0)) ,
                     SUM(nvl(wip_variance,0))
              INTO   l_cost,
                     l_wip_variance
              FROM   mtl_pac_actual_cost_details
              WHERe  transaction_id = i_ae_txn_rec.transaction_id
              AND    pac_period_id = i_ae_txn_rec.accounting_period_id
              AND cost_group_id = i_ae_txn_rec.cost_group_id
              AND cost_element_id = cost_element
              AND (cost_element_id <> 2
                   OR
                   (cost_element_id = 2
                    and level_type = decode(i_ovhd_absp,1,2,2,0,level_type)));

              IF (l_cost is not null) then

                l_stmt_num := 30;
                l_ae_line_rec.account := CSTPAPHK.get_account_id (
                                                i_ae_txn_rec.transaction_id,
                                                i_ae_txn_rec.legal_entity_id,
                                                i_ae_txn_rec.cost_type_id,
                                                i_ae_txn_rec.cost_group_id,
                                                i_dr_flag,
                                                i_acct_line_type,
                                                cost_element,
                                                NULL,
                                                i_ae_txn_rec.subinventory_code,
                                                "FALSE", ---  i_exp_flag
                                                l_err_rec.l_err_num,
                                                l_err_rec.l_err_code,
                                                l_err_rec.l_err_msg);
                -- check error
                if(l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null) then
                raise process_error;
                end if;

                IF (l_ae_line_rec.account = -1) then
                   l_stmt_num := 40;
                   select decode(cost_element, 1, i_ae_acct_rec.mat_account,
                                          2, i_ae_acct_rec.mat_ovhd_account,
                                          3, i_ae_acct_rec.res_account,
                                          4, i_ae_acct_rec.osp_account,
                                          5, i_ae_acct_rec.ovhd_account)
                   into l_ae_line_rec.account
                   from dual;
                END IF;

                l_ae_line_rec.resource_id := NULL;
                l_ae_line_rec.cost_element_id := cost_element;
                l_ae_line_rec.ae_line_type := i_acct_line_type;
                l_ae_line_rec.transaction_value := abs(i_ae_txn_rec.primary_quantity) * l_cost + l_wip_variance;

                insert_account (i_ae_txn_rec,
                                i_ae_curr_rec,
                                i_dr_flag,
                                l_ae_line_rec,
                                l_ae_line_tbl,
                                l_err_rec);
                -- check error
                IF(l_err_rec.l_err_num<>0 and l_err_rec.l_err_num is not null) THEN
                   RAISE process_error;
                END IF;
              ELSE
                 IF g_debug_flag = 'Y' THEN
                    fnd_file.put_line(fnd_file.log,'No Cost for element...');
                END IF;
              END IF;

            ---------------------------------------------------------------------------------------
            -- Execute the below code only
            -- If wip_variance is less than zero and only for Discrete Jobs and Repetitiveschedules
            ---------------------------------------------------------------------------------------
            IF ( l_wip_variance is NOT NULL AND l_wip_variance < 0) THEN
                  ------------------------------------------------------------------------------------------------
                  -- Get WIP Variance Accounts only If txn is AssemblyCompletion/AssemblyReturn/Scrap/ScrapReturn
                  ------------------------------------------------------------------------------------------------
                    l_stmt_num := 58;
                   -------------------------------------------------------------------------
                   -- Get the Variance Accounts based Job type
                   -- If Job type is Repetitive then get from table WIP_REPETITIVE_SCHEDULES
                   -- If Job type is Discrete then get from table WIP_DISCRETE_JOBS
                   -------------------------------------------------------------------------
                   IF ((i_ae_txn_rec.wip_entity_type = 1) OR (i_ae_txn_rec.wip_entity_type = 3)) THEN

                       SELECT decode(cost_element, 1, material_variance_account,
                                                   2, material_variance_account, -- Using Material Variance acct for cost element 2 also
                                                   3, resource_variance_account,
                                                   4, outside_proc_variance_account,
                                                   5, overhead_variance_account)
                       INTO  l_ae_line_rec.account
                       FROM  WIP_DISCRETE_JOBS
                       WHERE organization_id = i_ae_txn_rec.organization_id
                       AND   wip_entity_id = i_ae_txn_rec.txn_src_id;
                   ELSE
                       SELECT decode(cost_element, 1, material_variance_account,
                                                   2, material_variance_account, -- Using Material Variance acct for cost element 2 also
                                                   3, resource_variance_account,
                                                   4, outside_proc_variance_account,
                                                   5, overhead_variance_account)
                       INTO  l_ae_line_rec.account
                       FROM  WIP_REPETITIVE_SCHEDULES
                       WHERE organization_id = i_ae_txn_rec.organization_id
                       AND   wip_entity_id = i_ae_txn_rec.txn_src_id;
                   END IF;

                   l_stmt_num := 59;
                   ----------------------------------------------------
                   -- Flip the i_dr_flag.
                   -- For Assembly Completion WIP valuation  Cr
                   --     Assembly Completion WIP Variance   Dr
                   -------- --------------------------------------------
                   l_dr_flag := NOT i_dr_flag;

                   -----------------------------------------------
                   -- Set the accounting line type to WIP Variance
                   -----------------------------------------------
                   l_ae_line_rec.ae_line_type := 8;
                   l_ae_line_rec.transaction_value := l_wip_variance;
                   l_ae_line_rec.resource_id := NULL;
                   l_ae_line_rec.cost_element_id := cost_element;
                   ---------------------------------------------------
                   -- Insert the transaction details into PL/SQL table
                   ---------------------------------------------------
                   insert_account (i_ae_txn_rec,
                                   i_ae_curr_rec,
                                   l_dr_flag,
                                   l_ae_line_rec,
                                   l_ae_line_tbl,
                                   l_err_rec);
                   -- check error
                   IF(l_err_rec.l_err_num<>0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                     RAISE process_error;
                   END IF;
               END IF; -- End of IF l_wip_variance <> 0
    END LOOP;

  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'WIP_accounts >>');
  END IF;

  EXCEPTION

  when no_txn_det_error then
  o_ae_err_rec.l_err_num := 30010;
  o_ae_err_rec.l_err_code := 'CST_NO_TXN_DET';
  FND_MESSAGE.set_name('BOM', 'CST_NO_TXN_DET');
  o_ae_err_rec.l_err_msg := FND_MESSAGE.Get;

  when process_error then
  o_ae_err_rec.l_err_num := l_err_rec.l_err_num;
  o_ae_err_rec.l_err_code := l_err_rec.l_err_code;
  o_ae_err_rec.l_err_msg := l_err_rec.l_err_msg;

  when others then
  o_ae_err_rec.l_err_num := SQLCODE;
  o_ae_err_rec.l_err_code := '';
  o_ae_err_rec.l_err_msg := 'CSTPAPBR.offset_accounts' || to_char(l_stmt_num) ||
  substr(SQLERRM,1,180);

end WIP_accounts;

-- ========================================================================
-- GET Intercompany Account For Transfer Pricing.
-- This Procedure uses the same logic as in CST_TPRICE_PVT.Adjust_acct
-- to get the intercompany accrual account id
-- ========================================================================
Function Get_Intercompany_account(
   i_ae_txn_rec     IN          CSTPALTY.cst_ae_txn_rec_type,
   o_ae_err_rec     OUT NOCOPY  CSTPALTY.cst_ae_err_rec_type) RETURN NUMBER
IS
   l_snd_sob_id     NUMBER;
   l_snd_curr       GL_SETS_OF_BOOKS.CURRENCY_CODE%TYPE;
   l_rcv_sob_id     NUMBER;
   l_rcv_coa_id     NUMBER;
   l_rcv_curr       GL_SETS_OF_BOOKS.CURRENCY_CODE%TYPE;
   l_curr_type      MTL_MATERIAL_TRANSACTIONS.CURRENCY_CONVERSION_TYPE%TYPE;
   l_conv_rate      NUMBER;
   l_conv_date      DATE;
   l_err_rec        CSTPALTY.cst_ae_err_rec_type;
   l_from_org       NUMBER;
   l_to_org         NUMBER;
   l_from_ou        NUMBER;
   l_to_ou          NUMBER;
   l_line_id        NUMBER;
   l_header_id      NUMBER;
   l_cust_id        NUMBER;
   l_order_type     OE_ORDER_HEADERS_ALL.ORDER_TYPE_ID%TYPE;
   l_ship_num       NUMBER;
   l_req_line       NUMBER;
   l_stmt_num       NUMBER;
   l_pd_txfr_ind    NUMBER;
   l_inv_ccid       NUMBER;
   l_concat_seg     GL_CODE_COMBINATIONS_KFV.CONCATENATED_SEGMENTS%TYPE;
   /* OPM CONV Bug: 5478266. Vars needed to get COGS account*/
   l_cogs_ccid      NUMBER;
   l_concat_id      VARCHAR2(2000);
   l_concat_desc    VARCHAR2(2000);
   l_msg_count      NUMBER;
   l_msg_data       VARCHAR2(2000);
   l_acct_ccid      NUMBER;
   l_txf_txn_id     NUMBER;

   process_error    EXCEPTION;
   inv_exp_acct_err EXCEPTION;
   no_txn_det_error EXCEPTION;

   l_shipping_cg_id NUMBER;

BEGIN

  l_inv_ccid := -1;

  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Get_Intercompany_account << ');
  END IF;

  l_stmt_num := 5;
  SELECT MOD(SUM(DECODE(MP.process_enabled_flag,'Y',1,2)), 2)
    INTO l_pd_txfr_ind
    FROM mtl_parameters mp
   WHERE mp.organization_id = i_ae_txn_rec.organization_id
      OR mp.organization_id = i_ae_txn_rec.xfer_organization_id;

  IF g_debug_flag = 'Y' THEN
    FND_FILE.put_line(FND_FILE.LOG, 'l_pd_txfr_ind:' ||  l_pd_txfr_ind);
  END IF;

  l_stmt_num := 7;

  BEGIN
    SELECT cost_group_id
    INTO l_shipping_cg_id
    FROM cst_cost_group_assignments
    WHERE organization_id = (SELECT decode(i_ae_txn_rec.txn_action_id,
                                            21, organization_id,
                                            22, organization_id, -- Logical Shipping txn
                                            12, transfer_organization_id,
                                            15, transfer_organization_id, -- Logical Receipt txn
                                            3, decode(sign(i_ae_txn_rec.primary_quantity),
                                                        1, transfer_organization_id,
                                                            organization_id),
                                              NULL)
                            FROM mtl_material_transactions
                            WHERE transaction_id = i_ae_txn_rec.transaction_id);
    EXCEPTION
    WHEN no_data_found THEN
      l_shipping_cg_id := -1;
  END;

  IF g_debug_flag = 'Y' THEN
    FND_FILE.put_line(FND_FILE.LOG, 'l_shipping_cg_id:' ||  l_shipping_cg_id);
  END IF;

  if (i_ae_txn_rec.txn_action_id in (21, 22)) then
     l_from_org := i_ae_txn_rec.organization_id;
     l_to_org := i_ae_txn_rec.xfer_organization_id;
  elsif (i_ae_txn_rec.txn_action_id in (12, 15)) then
     l_from_org := i_ae_txn_rec.xfer_organization_id;
     l_to_org := i_ae_txn_rec.organization_id;
  end if;

  l_stmt_num := 10;
  CSTPAVCP.get_snd_rcv_rate  (I_TXN_ID     => i_ae_txn_rec.transaction_id,
                              I_FROM_ORG   => l_from_org,
                              I_TO_ORG     => l_to_org,
                              O_SND_SOB_ID => l_snd_sob_id,
                              O_SND_CURR   => l_snd_curr,
                              O_RCV_SOB_ID => l_rcv_sob_id,
                              O_RCV_CURR   => l_rcv_curr,
                              O_CURR_TYPE  => l_curr_type,
                              O_CONV_RATE  => l_conv_rate,
                              O_CONV_DATE  => l_conv_date,
                              O_Err_Num    => l_err_rec.l_err_num,
                              O_Err_Code   => l_err_rec.l_err_code,
                              O_Err_Msg    => l_err_rec.l_err_msg);

   if (l_err_rec.l_err_num <> 0) then
      raise process_error;
   end if;

  l_stmt_num := 20;
  SELECT chart_of_accounts_id
  INTO   l_rcv_coa_id
  FROM   gl_sets_of_books
  WHERE  set_of_books_id = l_rcv_sob_id;

  l_stmt_num := 30;
  SELECT to_number(org_information3)
  INTO   l_from_ou
  FROM   hr_organization_information
  WHERE  org_information_context = 'Accounting Information'
  AND    organization_id = l_from_org;

  l_stmt_num := 35;
  SELECT to_number(org_information3)
  INTO   l_to_ou
  FROM   hr_organization_information
  WHERE  org_information_context = 'Accounting Information'
  AND    organization_id = l_to_org;

  if (g_debug_flag = 'Y') then
      FND_FILE.put_line(FND_FILE.LOG, 'l_from_ou = ' || l_from_ou ||
                 ' l_to_ou = ' || l_to_ou || ' l_rcv_coa_id = ' || l_rcv_coa_id);
  end if;

  if (i_ae_txn_rec.txn_action_id in (15, 21)) then
     l_stmt_num := 40;

     SELECT MMT.trx_source_line_id, OEH.header_id, OEH.sold_to_org_id, OEH.order_type_id
     INTO   l_line_id, l_header_id, l_cust_id, l_order_type
     FROM   mtl_material_transactions MMT, oe_order_headers_all OEH, oe_order_lines_all OEL
     WHERE  MMT.transaction_id = i_ae_txn_rec.transaction_id
     AND    OEL.line_id = MMT.trx_source_line_id
     AND    OEL.header_id = OEH.header_id;

  elsif (i_ae_txn_rec.txn_action_id in (12, 22)) then

      l_stmt_num := 50;

      SELECT MMT.shipment_number, RT.requisition_line_id,
      -- For action id 22, transfer_transaction_id points to receiving txn, not the shipping txn,
      -- because it got created after goods are received, so goto else part...
      decode(l_pd_txfr_ind, 1, 0, nvl(MMT.transfer_transaction_id, 0))
      INTO l_ship_num, l_req_line, l_txf_txn_id
      FROM mtl_material_transactions MMT, rcv_transactions RT
      WHERE MMT.transaction_id = i_ae_txn_rec.transaction_id
      AND   RT.transaction_id = MMT.rcv_transaction_id;


     if (l_txf_txn_id <> 0) then

        l_stmt_num := 60;

        SELECT MMT.trx_source_line_id, OEH.header_id, OEH.sold_to_org_id, OEH.order_type_id
        INTO   l_line_id, l_header_id, l_cust_id, l_order_type
        FROM   mtl_material_transactions MMT, oe_order_headers_all OEH, oe_order_lines_all OEL
        WHERE  MMT.transaction_id = i_ae_txn_rec.xfer_transaction_id
        AND    MMT.trx_source_line_id = OEL.line_id
        AND    OEL.header_id = OEH.header_id;

     else

        l_stmt_num := 70;

        SELECT MMT.trx_source_line_id, OEH.header_id, OEH.sold_to_org_id, OEH.order_type_id
        INTO   l_line_id, l_header_id, l_cust_id, l_order_type
        FROM   mtl_material_transactions MMT, oe_order_headers_all OEH, oe_order_lines_all OEL
        WHERE  MMT.transaction_action_id = 21
        AND    MMT.transaction_source_type_id = 8
        AND    MMT.organization_id = l_from_org
        AND    MMT.inventory_item_id = i_ae_txn_rec.inventory_item_id
        AND    MMT.shipment_number = l_ship_num
        AND    MMT.trx_source_line_id = OEL.line_id
        AND    OEL.source_document_line_id = l_req_line
        AND    OEL.header_id = OEH.header_id
        AND    ROWNUM = 1;

     end if;
  end if;

  /* For Discrete-Discrete transfers, derive COGS account if called for
     Shipping CG else derive accrual account if called for receiving CG */

  /* OPM CONV Bug: 5478266. Code to get COGS account*/
  if (((l_pd_txfr_ind = 0) and (i_ae_txn_rec.cost_group_id = l_shipping_cg_id))
      OR ((l_pd_txfr_ind = 1) and (i_ae_txn_rec.txn_action_id in (21, 22)))) then

    l_stmt_num := 80;

    mo_global.set_policy_context('S',l_from_ou);

    if (OE_FLEX_COGS_PUB.start_process(1.0,
                                       l_line_id,
                                       l_cogs_ccid,
                                       l_concat_seg,
                                       l_concat_id,
                                       l_concat_desc,
                                       l_msg_count,
                                       l_msg_data) <> FND_API.g_ret_sts_success) then
      l_stmt_num := 90;

      SELECT nvl(MSI.cost_of_sales_account, MP.cost_of_sales_account)
      INTO   l_cogs_ccid
      FROM   mtl_system_items MSI, mtl_parameters MP
      WHERE  MSI.organization_id = l_from_org
      AND    MSI.inventory_item_id = i_ae_txn_rec.inventory_item_id
      AND    MP.organization_id = MSI.organization_id;

    end if;

    if (g_debug_flag = 'Y') then
      FND_FILE.put_line(FND_FILE.LOG, 'l_cogs_ccid = ' || l_cogs_ccid);
    end if;

    /* Return COGS Account */
    l_acct_ccid := l_cogs_ccid;

  end if;

  if (((l_pd_txfr_ind = 0) and (i_ae_txn_rec.cost_group_id <> l_shipping_cg_id))
      OR ((l_pd_txfr_ind = 1) and (i_ae_txn_rec.txn_action_id in (12, 15))))  then

    l_stmt_num := 100;

    IF NOT INV_WORKFLOW.call_generate_cogs(l_rcv_coa_id,
                                           l_cust_id,
                                           i_ae_txn_rec.inventory_item_id,
                                           l_header_id,
                                           l_line_id,
                                           l_order_type,
                                           l_to_ou,
                                           l_inv_ccid,
                                           l_concat_seg,
                                           l_err_rec.l_err_msg)
    THEN
       RAISE inv_exp_acct_err;
    END IF;

    if (g_debug_flag = 'Y') then
       FND_FILE.put_line(FND_FILE.LOG, 'l_inv_ccid = ' || l_inv_ccid);
    end if;

    /* Return IC Accrual Account */
    l_acct_ccid := l_inv_ccid;

  end if;


  IF g_debug_flag = 'Y' THEN
    FND_FILE.put_line(FND_FILE.LOG, 'l_acct_ccid = ' || l_acct_ccid);
    fnd_file.put_line(fnd_file.log,'Get_Intercompany_account >>');
  END IF;

  return l_acct_ccid;

  EXCEPTION

  when no_txn_det_error then
  o_ae_err_rec.l_err_num := 30010;
  o_ae_err_rec.l_err_code := 'CST_NO_TXN_DET';
  FND_MESSAGE.set_name('BOM', 'CST_NO_TXN_DET');
  o_ae_err_rec.l_err_msg := FND_MESSAGE.Get;

  when process_error then
  o_ae_err_rec.l_err_num := l_err_rec.l_err_num;
  o_ae_err_rec.l_err_code := l_err_rec.l_err_code;
  o_ae_err_rec.l_err_msg := l_err_rec.l_err_msg;

  when others then
  o_ae_err_rec.l_err_num := SQLCODE;
  o_ae_err_rec.l_err_code := '';
  o_ae_err_rec.l_err_msg := 'CSTPAPBR.Get_Intercompany_account ' || to_char(l_stmt_num) ||
  substr(SQLERRM,1,180);
END Get_Intercompany_account;


/* --=======================================================================
-- Internal Order Issue to Expense and Logical Expense Requisition Rcpt trxn
-- This Procedure creates distributions for Internal Order Issue trxn 34-1-8
-- and Logical Expense Requisition Receipt trxn 27-17-7
-- Discrete-Discrete and OPM-Discrete X-fers are handled in the procedure

-- Case I Dis-Dis, same CG, treat as SubInv transfer (Done)
-- Internal Order Issue 34-1-8 :
--   Dr. Expense @ PWAC
--    Cr. Inv Val @ PWAC
-- Logical Exp 27-17-7 :
--   NO accounting

-- Case II Dis-Dis, across CG. Sending CG
-- Internal Order Issue 34-1-8 :
--   Dr. Receivables Sending Org cost (from CPIC/Prior Prd PWAC/PerpMTA)
--    Cr. Inv Val @ PWAC
--    Cr. InterOrg Profit @ PWAC-(Prior Prd/PerpMTA)

-- Case III Dis-Dis, across CG. Receiving CG
-- Logical Exp 27-17-7 :
--   Dr. Expense @ Sending Org cost (from CPIC/Prior Prd PWAC/PerpMTA)
--    Cr. Payables @ Sending Org cost (from CPIC/Prior Prd PWAC/PerpMTA)

-- Case IV Dis-OPM Xfer, Discrete is Sending CG (Done)
-- Internal Order Issue 34-1-8 :
--   Dr. Receivables @ Transfer Price
--    Cr. Inv Val @ PWAC
--    Cr. Inter-org Profit @ TP-PWAC

-- Case V OPM-Dis Xfer, Discrete is Receiving CG (Done)
-- Logical Exp 27-17-7 :
--   Dr. Expense @ Transfer price
--    Cr. Payables @ Transfer price

-- =======================================================================*/
PROCEDURE cost_internal_order_exp_txn(
  i_ae_txn_rec       IN             CSTPALTY.cst_ae_txn_rec_type,
  i_ae_curr_rec      IN             CSTPALTY.cst_ae_curr_rec_type,
  l_ae_line_tbl      IN OUT NOCOPY  CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec       OUT NOCOPY     CSTPALTY.cst_ae_err_rec_type
)
IS
  l_exp_sub                     NUMBER;
  l_exp_flag                    BOOLEAN;
  l_dr_flag                     BOOLEAN;
  l_stmt_num                    NUMBER := 0;
  l_acct_rec                    CSTPALTY.cst_ae_acct_rec_type;
  l_err_rec                     CSTPALTY.cst_ae_err_rec_type;
  l_ae_line_rec                 CSTPALTY.cst_ae_line_rec_type;
  l_txn_cost_group_id           NUMBER;
  l_txfr_txn_cost_group_id      NUMBER;

  l_mfa_exp_account             NUMBER;
  l_mmt_exp_account             NUMBER;

  l_io_rcv_acct                 NUMBER;
  l_io_pay_acct                 NUMBER;
  l_io_rcv_value                NUMBER;
  l_io_pay_value                NUMBER;
  l_io_txfr_cr_acct             NUMBER;
  l_io_txfr_var_acct            NUMBER;
  l_txfr_legal_entity           NUMBER;
  l_txfr_cost_group_id          NUMBER;
  l_same_le_ct                  NUMBER;
  l_mpacd_cost                  NUMBER;
  l_txfr_var_value              NUMBER;
  l_pwac_cost                   NUMBER;
  l_profit_or_loss              NUMBER;

  l_transfer_price              NUMBER;
  l_pd_txfr_ind                 NUMBER := 0;

  l_pacp_flag                   NUMBER;
  l_pacp_pwac_cost              NUMBER;
  l_prev_period_flag            NUMBER;
  l_prev_period_pwac_cost       NUMBER;
  l_perp_ship_flag              NUMBER;
  l_perp_ship_value             NUMBER;
  l_txfr_credit                 NUMBER;

  process_error                 EXCEPTION;
  no_mfca_acct_error            EXCEPTION;
  no_interorg_profit_acct_error EXCEPTION;

  l_api_name   CONSTANT VARCHAR2(240) := 'CSTPAPBR.cost_internal_order_exp_txn';

BEGIN

  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ': begin <<'
                      || ' transaction_id: ' || i_ae_txn_rec.transaction_id);
  END IF;

  -- Initialize variables.
  -- ---------------------
  l_err_rec.l_err_num := 0;
  l_err_rec.l_err_code := '';
  l_err_rec.l_err_msg := '';

  IF i_ae_txn_rec.exp_item = 1 THEN

    l_stmt_num := 10;

    IF g_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ': return >> ' ||
              '(No accounting for Expense item)');
    END IF;

    RETURN;
  END IF;

  l_stmt_num := 20;

  IF (i_ae_txn_rec.subinventory_code IS NULL) THEN

    l_stmt_num := 30;

    l_exp_sub:=0; -- If subInv code is missing, as in case of Logical Intransit Receipt
                     -- Treat it as asset subInv
  ELSE

    l_stmt_num := 40;

    SELECT decode(asset_inventory,1,0,1)
    INTO  l_exp_sub
    FROM  mtl_secondary_inventories
    WHERE secondary_inventory_name = i_ae_txn_rec.subinventory_code
    AND   organization_id = i_ae_txn_rec.organization_id;

  END IF;

  IF (l_exp_sub = 1) THEN
    l_exp_flag := TRUE;
  ELSE
    l_exp_flag := FALSE;
  END IF;

  l_stmt_num := 50;

  BEGIN
    l_stmt_num := 60;
    SELECT nvl(expense_account, -1)
    INTO  l_mfa_exp_account
    FROM  mtl_fiscal_cat_accounts
    WHERE legal_entity_id = i_ae_txn_rec.legal_entity_id
    AND   cost_type_id    = i_ae_txn_rec.cost_type_id
    AND   cost_group_id   = i_ae_txn_rec.cost_group_id
    AND   category_id     = i_ae_txn_rec.category_id;
  EXCEPTION
    WHEN no_data_found THEN
      l_stmt_num := 70;
      fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num ||
              ': Category : '||to_char(i_ae_txn_rec.category_id) ||' has no accounts defined');
      RAISE no_mfca_acct_error;
  END;


  /* To determine whether this is a same cost group transfer or
     cross cost group transfer, we need to compare the transaction org
     cost group with the transfer transaction org cost group */
  BEGIN
    l_stmt_num := 80;
    SELECT NVL(cost_group_id, -1)
    INTO   l_txn_cost_group_id
    FROM   cst_cost_group_assignments
    WHERE  organization_id = i_ae_txn_rec.organization_id;
  EXCEPTION
    WHEN no_data_found THEN
      l_txn_cost_group_id := -1;
  END;

  l_txfr_txn_cost_group_id := NVL(i_ae_txn_rec.xfer_cost_group_id, -1);

  l_stmt_num := 90;

  IF g_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                        ': cost_group_id = ' || i_ae_txn_rec.cost_group_id ||
                        ': txn_cost_group_id ' || l_txn_cost_group_id ||
                        ': txfr_txn_cost_group_id ' || l_txfr_txn_cost_group_id);
  END IF;


  /* If the transaction org cost group = the transfer transaction org cost group,
     the transfer is within the same cost group */
  IF (l_txn_cost_group_id = l_txfr_txn_cost_group_id) THEN /* Same Cost Group Transfer */

      l_stmt_num := 100;

      IF g_debug_flag = 'Y' THEN
        fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ': Transfer Within Same Cost Group');
      END IF;

        -- Case I Dis-Dis, same CG, treat as SubInv transfer
        -- Internal Order Issue 34-1-8 :
        --   Dr. Expense @ PWAC
        --    Cr. Inv Val @ PWAC
        -- Logical Exp 27-17-7 :
        --   NO accounting
        IF (i_ae_txn_rec.txn_action_id = 1) then

            l_stmt_num := 110;

            IF g_debug_flag = 'Y' THEN
                fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ': 34-1-8 Dr Expense and Cr Inv');
            END IF;

            l_dr_flag := TRUE;


            /* Debit Expense account of the Logical Exp Req receipt at PWAC */

            SELECT NVL(CPIC.item_cost,0)
            INTO   l_pwac_cost
            FROM   CST_PAC_ITEM_COSTS CPIC
            WHERE  CPIC.INVENTORY_ITEM_ID = i_ae_txn_rec.inventory_item_id
            AND    CPIC.COST_GROUP_ID     = i_ae_txn_rec.cost_group_id
            AND    CPIC.PAC_PERIOD_ID     = i_ae_txn_rec.accounting_period_id;

            /* Use the Logical trxn (27-17-7) to get the Expense acct
               of Receiving CG stamped in MMT in distribution_account_id.
               This cannot be NULL as it is stamped by INV Manager and not
               during Cost Processing in CSTPAVCP.Cost_LogicalSOReceipt */
            SELECT distribution_account_id
            INTO   l_mmt_exp_account
            FROM   mtl_material_transactions mmt
            WHERE  mmt.transaction_id = i_ae_txn_rec.xfer_transaction_id;

            l_stmt_num := 120;

            l_dr_flag := TRUE;

            l_ae_line_rec.transaction_value := l_pwac_cost * abs(i_ae_txn_rec.primary_quantity);
            l_ae_line_rec.account := l_mmt_exp_account;
            l_ae_line_rec.resource_id := NULL;
            l_ae_line_rec.cost_element_id := NULL;
            l_ae_line_rec.ae_line_type := 2;  -- Expense

            l_stmt_num := 130;

            insert_account (i_ae_txn_rec,
                            i_ae_curr_rec,
                            l_dr_flag,
                            l_ae_line_rec,
                            l_ae_line_tbl,
                            l_err_rec);

            l_stmt_num := 140;

            -- check error
            IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
              RAISE process_error;
            END IF;

            l_dr_flag := FALSE;

            -- Credit On-hand (if expense, then use expense account)
            -- -----------------------------------------------------
            IF (l_exp_flag) THEN
              CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                           i_ae_curr_rec,
                                           l_exp_flag, -- Exp Flag
                                           l_mfa_exp_account, -- Exp Acct
                                           l_dr_flag,
                                           l_ae_line_tbl,
                                           l_err_rec);

              l_stmt_num := 150;
            ELSE
              CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                           i_ae_curr_rec,
                                           "FALSE", -- Exp Flag
                                           null, -- Exp Acct
                                           l_dr_flag,
                                           l_ae_line_tbl,
                                           l_err_rec);

              l_stmt_num := 160;
            END IF;

            -- Check error
            if (l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
               raise process_error;
            end if;

        ELSIF (i_ae_txn_rec.txn_action_id = 17) then

            l_stmt_num := 170;

            IF g_debug_flag = 'Y' THEN
              fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ': 27-17-7 No accounting');
            END IF;

        END IF;

  ELSE /* Transfer across CG */

      l_stmt_num := 180;

      IF g_debug_flag = 'Y' THEN
        fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ': Transfer across Cost Group');
      END IF;

      /* Check if it is a transfer between Process and Discrete Orgs */
      SELECT MOD(SUM(DECODE(process_enabled_flag,'Y',1,2)), 2)
      INTO l_pd_txfr_ind
      FROM MTL_PARAMETERS MP
      WHERE MP.ORGANIZATION_ID = i_ae_txn_rec.xfer_organization_id
      OR MP.ORGANIZATION_ID    = i_ae_txn_rec.organization_id;

      l_stmt_num := 190;

      IF (l_pd_txfr_ind = 0) THEN /* Discrete-Discrete X-fer */

          l_stmt_num := 200;

          IF g_debug_flag = 'Y' THEN
            fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ': Discrete-Discrete X-fer');
          END IF;

          IF (i_ae_txn_rec.txn_action_id = 1) then
          -- Case II Dis-Dis, across CG. Sending CG
          -- Internal Order Issue 34-1-8 :
          --   Dr. Receivables Sending Org cost (from CPIC/Prior Prd PWAC/PerpMTA)
          --    Cr. Inv Val @ PWAC
          --    Cr. InterOrg Profit @ PWAC-(Prior Prd/PerpMTA)

              l_dr_flag := FALSE;

              /* Credit OnHand at PWAC Cost */

              -- Credit On-hand (if expense, then use expense account)
              -- -----------------------------------------------------
              IF (l_exp_flag) THEN
                CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                             i_ae_curr_rec,
                                             l_exp_flag, -- Exp Flag
                                             l_mfa_exp_account, -- Exp Acct
                                             l_dr_flag,
                                             l_ae_line_tbl,
                                             l_err_rec);

                l_stmt_num := 210;
              ELSE
                CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                             i_ae_curr_rec,
                                             "FALSE", -- Exp Flag
                                             null, -- Exp Acct
                                             l_dr_flag,
                                             l_ae_line_tbl,
                                             l_err_rec);

                l_stmt_num := 220;
              END IF;

               -- Check error
              if (l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
                 raise process_error;
              end if;


              /* Debit Receivables at estimated cost: This can be CPIC cost/previous period cost/MTA cost */

              /* Get relevant accounts */
              SELECT mip.interorg_receivables_account,
                     mip.interorg_transfer_cr_account,
                     nvl(mip.interorg_profit_account, -1)
              INTO   l_io_rcv_acct,
                     l_io_txfr_cr_acct,
                     l_io_txfr_var_acct
              FROM   mtl_interorg_parameters mip,
                     mtl_material_transactions mmt
              WHERE  mip.from_organization_id = i_ae_txn_rec.organization_id
              AND    mip.to_organization_id = i_ae_txn_rec.xfer_organization_id
              AND    mmt.transaction_id = i_ae_txn_rec.transaction_id;

              l_stmt_num := 230;

              get_pacp_priorPrd_mta_cost (i_ae_txn_rec            => i_ae_txn_rec,
                                          i_ae_curr_rec           => i_ae_curr_rec,
                                          l_ae_line_tbl           => l_ae_line_tbl,
                                          o_ae_err_rec            => l_err_rec,
                                          o_pacp_flag             => l_pacp_flag,
                                          o_pacp_pwac_cost        => l_pacp_pwac_cost,
                                          o_prev_period_flag      => l_prev_period_flag,
                                          o_prev_period_pwac_cost => l_prev_period_pwac_cost,
                                          o_perp_ship_flag        => l_perp_ship_flag,
                                          o_perp_ship_value       => l_perp_ship_value,
                                          o_txfr_credit           => l_txfr_credit);

              l_stmt_num := 240;
               -- Check error
              if (l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
                 raise process_error;
              end if;

              IF (l_pacp_flag = 1) THEN
                  l_stmt_num := 250;
                  IF g_debug_flag = 'Y' THEN
                    fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                               ': Using PAC Absorption Cost: ');
                  END IF;

                  l_io_rcv_value := l_pacp_pwac_cost;

              ELSIF (l_prev_period_flag = 1) THEN
                  l_stmt_num := 260;
                  IF g_debug_flag = 'Y' THEN
                    fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                                   ': Using prior period PWAC cost: ');
                  END IF;

                  l_io_rcv_value := l_prev_period_pwac_cost;

              ELSIF (l_perp_ship_flag = 1) THEN
                  l_stmt_num := 270;
                  IF g_debug_flag = 'Y' THEN
                    fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                               ': Using MTA cost');
                  END IF;

                  l_io_rcv_value := (l_perp_ship_value / abs(i_ae_txn_rec.primary_quantity));

              ELSE /* This is error situation, one of 3 cases above should be true */

                  l_stmt_num := 280;

                  IF g_debug_flag = 'Y' THEN
                    fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ': PACP/PriorPrd/MTA value not returned');
                  END IF;

                  raise process_error;
              END IF; /* (l_pacp_flag = 1) */

              l_stmt_num := 290;

              l_dr_flag := TRUE;

              IF g_debug_flag = 'Y' THEN
                fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                           ': l_io_rcv_value = ' || l_io_rcv_value);
              END IF;

              l_ae_line_rec.account := l_io_rcv_acct;
              l_ae_line_rec.transaction_value := l_io_rcv_value * abs(i_ae_txn_rec.primary_quantity);
              l_ae_line_rec.resource_id := NULL;
              l_ae_line_rec.cost_element_id := NULL;
              l_ae_line_rec.ae_line_type := 10;  -- Receivables

              l_stmt_num := 300;
              insert_account (i_ae_txn_rec,
                              i_ae_curr_rec,
                              l_dr_flag,
                              l_ae_line_rec,
                              l_ae_line_tbl,
                              l_err_rec);

              l_stmt_num := 310;
              -- check error
              IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                  RAISE process_error;
              END IF;

              IF (l_pacp_flag <> 1) THEN /* In this case Inter-Org profit has to be hit */

                  l_stmt_num := 320;
                  SELECT sum(nvl(actual_cost,0))
                  INTO   l_mpacd_cost
                  FROM   mtl_pac_actual_cost_details
                  WHERE  transaction_id = i_ae_txn_rec.transaction_id
                  AND    pac_period_id = i_ae_txn_rec.accounting_period_id
                  AND    cost_group_id = i_ae_txn_rec.cost_group_id;

                  l_stmt_num := 330;

                  l_txfr_var_value := l_io_rcv_value - l_mpacd_cost;

                  IF (sign(l_txfr_var_value) = 1) THEN
                    l_dr_flag := FALSE;
                  ELSIF (sign(l_txfr_var_value) = -1) THEN
                    l_dr_flag := TRUE;
                  ELSE
                    l_dr_flag := NULL;
                  END IF;

                  l_txfr_var_value := abs(l_txfr_var_value);

                  IF (l_dr_flag IS NOT NULL) THEN

                     l_stmt_num := 340;

                     IF (l_io_txfr_var_acct = -1) THEN
                        RAISE no_interorg_profit_acct_error;
                     END IF;

                     /* Transfer variance entry */
                     l_ae_line_rec.account := l_io_txfr_var_acct;
                     l_ae_line_rec.transaction_value := l_txfr_var_value * abs(i_ae_txn_rec.primary_quantity);
                     l_ae_line_rec.resource_id := NULL;
                     l_ae_line_rec.cost_element_id := NULL;
                     l_ae_line_rec.ae_line_type := 34;   -- Interorg profit in inventory

                     l_stmt_num := 350;

                     insert_account (i_ae_txn_rec,
                                     i_ae_curr_rec,
                                     l_dr_flag,
                                     l_ae_line_rec,
                                     l_ae_line_tbl,
                                     l_err_rec);

                     l_stmt_num := 360;
                     -- check error
                     IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                        RAISE process_error;
                     END IF;

                  END IF; /* (l_dr_flag IS NOT NULL) */

              END IF; /* (l_pacp_flag <> 1) */

          ELSIF (i_ae_txn_rec.txn_action_id = 17) then
          -- Case III Dis-Dis, across CG. Receiving CG
          -- Logical Exp 27-17-7 :
          --   Dr. Expense @ Sending Org cost (from CPIC/Prior Prd PWAC/PerpMTA)
          --    Cr. Payables @ Sending Org cost (from CPIC/Prior Prd PWAC/PerpMTA)

              l_stmt_num := 370;
              IF g_debug_flag = 'Y' THEN
                 fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ': 27-17-7 Dr Exp and Cr Paybls');
              END IF;

              SELECT mip.interorg_payables_account,
                     distribution_account_id
              INTO   l_io_pay_acct,
                     l_mmt_exp_account
              FROM   mtl_interorg_parameters mip,
                     mtl_material_transactions mmt
              WHERE  mip.from_organization_id = i_ae_txn_rec.xfer_organization_id
              AND    mip.to_organization_id = i_ae_txn_rec.organization_id
              AND    mmt.transaction_id = i_ae_txn_rec.transaction_id;

              l_stmt_num := 380;

              get_pacp_priorPrd_mta_cost (i_ae_txn_rec            => i_ae_txn_rec,
                                          i_ae_curr_rec           => i_ae_curr_rec,
                                          l_ae_line_tbl           => l_ae_line_tbl,
                                          o_ae_err_rec            => l_err_rec,
                                          o_pacp_flag             => l_pacp_flag,
                                          o_pacp_pwac_cost        => l_pacp_pwac_cost,
                                          o_prev_period_flag      => l_prev_period_flag,
                                          o_prev_period_pwac_cost => l_prev_period_pwac_cost,
                                          o_perp_ship_flag        => l_perp_ship_flag,
                                          o_perp_ship_value       => l_perp_ship_value,
                                          o_txfr_credit           => l_txfr_credit);

              l_stmt_num := 390;
              -- Check error
              if (l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
                 raise process_error;
              end if;

              IF (l_pacp_flag = 1) THEN
                  l_stmt_num := 400;
                  IF g_debug_flag = 'Y' THEN
                    fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                               ': Using PAC Absorption Cost: ');
                  END IF;

                  l_io_pay_value := l_pacp_pwac_cost;

              ELSIF (l_prev_period_flag = 1) THEN
                  l_stmt_num := 410;
                  IF g_debug_flag = 'Y' THEN
                    fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                                   ': Using prior period PWAC cost: ');
                  END IF;

                  l_io_pay_value := l_prev_period_pwac_cost;

              ELSIF (l_perp_ship_flag = 1) THEN
                  l_stmt_num := 420;
                  IF g_debug_flag = 'Y' THEN
                    fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                               ': Using MTA cost');
                  END IF;

                  l_io_pay_value := (l_perp_ship_value / abs(i_ae_txn_rec.primary_quantity));

              ELSE /* This is error situation, one of 3 cases above should be true */

                  l_stmt_num := 430;

                  IF g_debug_flag = 'Y' THEN
                    fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ': PACP/PriorPrd/MTA value not returned');
                  END IF;

                  RAISE process_error;

              END IF; /* (l_pacp_flag = 1) */

              l_stmt_num := 440;

              l_dr_flag := FALSE;

              IF g_debug_flag = 'Y' THEN
                fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                           ': l_io_pay_value = ' || l_io_pay_value);
              END IF;

              l_ae_line_rec.account := l_io_pay_acct;
              l_ae_line_rec.transaction_value := (l_io_pay_value * abs(i_ae_txn_rec.primary_quantity));
              l_ae_line_rec.resource_id := NULL;
              l_ae_line_rec.cost_element_id := NULL;
              l_ae_line_rec.ae_line_type := 9;   -- Payables

              l_stmt_num := 450;

              -- Credit Payables
              -- ---------------
              insert_account (i_ae_txn_rec,
                              i_ae_curr_rec,
                              l_dr_flag,
                              l_ae_line_rec,
                              l_ae_line_tbl,
                              l_err_rec);

              l_stmt_num := 460;
              -- check error
              IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                 RAISE process_error;
              END IF;

              l_dr_flag := TRUE;

              l_stmt_num := 470;

              l_ae_line_rec.transaction_value := l_io_pay_value * abs(i_ae_txn_rec.primary_quantity);
              l_ae_line_rec.account := l_mmt_exp_account;
              l_ae_line_rec.resource_id := NULL;
              l_ae_line_rec.cost_element_id := NULL;
              l_ae_line_rec.ae_line_type := 2;  -- Expense

              l_stmt_num := 480;

              /* Debit Expense */
              insert_account (i_ae_txn_rec,
                              i_ae_curr_rec,
                              l_dr_flag,
                              l_ae_line_rec,
                              l_ae_line_tbl,
                              l_err_rec);

              l_stmt_num := 490;

              -- check error
              IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                 RAISE process_error;
              END IF;

          END IF; /* (i_ae_txn_rec.txn_action_id = 1) */

      ELSE /* OPM-Discrete X-fers */

          l_stmt_num := 500;

          IF g_debug_flag = 'Y' THEN
            fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ': Process-Discrete X-fer');
          END IF;

          IF (i_ae_txn_rec.txn_action_id = 1) then
          -- Case IV Dis-OPM Xfer, Discrete is Sending CG
          -- Internal Order Issue 34-1-8 :
          --   Dr. Receivables @ Transfer Price
          --    Cr. Inv Val @ PWAC
          --    Cr. Inter-org Profit @ TP-PWAC

              l_stmt_num := 510;

              IF g_debug_flag = 'Y' THEN
                  fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ': 34-1-8 Dr Rcv and Cr Inv');
              END IF;

              /* Debit Receivables @ Transfer Price */

              SELECT mip.interorg_receivables_account,
                     nvl(mip.interorg_profit_account, -1),
                     nvl(mmt.transfer_price,0)
              INTO   l_io_rcv_acct,
                     l_io_txfr_var_acct,
                     l_transfer_price -- transfer price
              FROM   mtl_interorg_parameters mip,mtl_material_transactions mmt
              WHERE  mip.from_organization_id = i_ae_txn_rec.organization_id
              AND    mip.to_organization_id = i_ae_txn_rec.xfer_organization_id
              AND    mmt.transaction_id = i_ae_txn_rec.transaction_id;

              l_stmt_num := 520;

              IF (l_io_txfr_var_acct = -1) THEN
                 RAISE no_interorg_profit_acct_error;
              END IF;

              l_stmt_num := 530;

              SELECT NVL(CPIC.item_cost,0)
              INTO   l_pwac_cost
              FROM   CST_PAC_ITEM_COSTS CPIC
              WHERE  CPIC.INVENTORY_ITEM_ID = i_ae_txn_rec.inventory_item_id
              AND    CPIC.COST_GROUP_ID     = i_ae_txn_rec.cost_group_id
              AND    CPIC.PAC_PERIOD_ID     = i_ae_txn_rec.accounting_period_id;

              l_dr_flag := TRUE;

              l_stmt_num := 540;

              l_ae_line_rec.transaction_value := l_transfer_price * abs(i_ae_txn_rec.primary_quantity); -- Receivables only at transfer price
              l_ae_line_rec.account := l_io_rcv_acct;
              l_ae_line_rec.resource_id := NULL;
              l_ae_line_rec.cost_element_id := NULL;
              l_ae_line_rec.ae_line_type := 10;  -- Receivables

              l_stmt_num := 550;

              insert_account (i_ae_txn_rec,
                              i_ae_curr_rec,
                              l_dr_flag,
                              l_ae_line_rec,
                              l_ae_line_tbl,
                              l_err_rec);

              l_stmt_num := 560;

              -- check error
              IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                 RAISE process_error;
              END IF;


              /* Credit On-hand @ PWAC (if shipping from expense sub, then use expense account) */

              l_dr_flag := FALSE;

              IF (l_exp_flag) THEN
                CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                             i_ae_curr_rec,
                                             l_exp_flag, -- Exp Flag
                                             l_mfa_exp_account, -- Exp Acct
                                             l_dr_flag,
                                             l_ae_line_tbl,
                                             l_err_rec);
                l_stmt_num := 570;

              ELSE
                CSTPAPBR.inventory_accounts (i_ae_txn_rec,
                                             i_ae_curr_rec,
                                             "FALSE", -- Exp Flag
                                             null, -- Exp Acct
                                             l_dr_flag,
                                             l_ae_line_tbl,
                                             l_err_rec);
                l_stmt_num := 580;

              END IF;

              -- check error
              IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                 RAISE process_error;
              END IF;


              l_profit_or_loss := l_transfer_price - l_pwac_cost;

              IF (l_profit_or_loss <> 0) THEN

                  IF l_profit_or_loss < 0 THEN
                      l_dr_flag := not l_dr_flag; -- If -ve then Debit interorg profit
                  END IF;

                  l_stmt_num := 590;

                  l_ae_line_rec.transaction_value := abs(l_profit_or_loss * i_ae_txn_rec.primary_quantity);
                  l_ae_line_rec.account := l_io_txfr_var_acct;
                  l_ae_line_rec.resource_id := NULL;
                  l_ae_line_rec.cost_element_id := NULL;
                  l_ae_line_rec.ae_line_type := 34;   -- interorg profit account

                  l_stmt_num := 600;

                  insert_account (i_ae_txn_rec,
                                  i_ae_curr_rec,
                                  l_dr_flag,
                                  l_ae_line_rec,
                                  l_ae_line_tbl,
                                  l_err_rec);

                  l_stmt_num := 610;

                  -- check error
                  IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                      RAISE process_error;
                  END IF;

              END IF; /* l_profit_or_loss <> 0 */

          ELSIF (i_ae_txn_rec.txn_action_id = 17) then
          -- Case V OPM-Dis Xfer, Discrete is Receiving CG
          -- Logical Exp Requisition Receipt 27-17-7 :
          --   Dr. Expense @ Transfer price
          --    Cr. Payables @ Transfer price

              l_stmt_num := 620;

              IF g_debug_flag = 'Y' THEN
                 fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ': 27-17-7 Dr Exp and Cr Paybls');
              END IF;

              SELECT mip.interorg_payables_account,
                     distribution_account_id,
                     nvl(transfer_price,0)
              INTO   l_io_pay_acct,
                     l_mmt_exp_account,
                     l_transfer_price -- transfer price
              FROM   mtl_interorg_parameters mip,
                     mtl_material_transactions mmt
              WHERE  mip.from_organization_id = i_ae_txn_rec.xfer_organization_id
              AND    mip.to_organization_id = i_ae_txn_rec.organization_id
              AND    mmt.transaction_id = i_ae_txn_rec.transaction_id;

              l_stmt_num := 630;

              l_dr_flag := TRUE;

              l_ae_line_rec.transaction_value := l_transfer_price * abs(i_ae_txn_rec.primary_quantity);
              l_ae_line_rec.account := l_mmt_exp_account;
              l_ae_line_rec.resource_id := NULL;
              l_ae_line_rec.cost_element_id := NULL;
              l_ae_line_rec.ae_line_type := 2;  -- Expense

              l_stmt_num := 640;

              insert_account (i_ae_txn_rec,
                              i_ae_curr_rec,
                              l_dr_flag,
                              l_ae_line_rec,
                              l_ae_line_tbl,
                              l_err_rec);

              l_stmt_num := 650;

              -- check error
              IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                 RAISE process_error;
              END IF;

              l_dr_flag := FALSE;

              l_ae_line_rec.transaction_value := l_transfer_price * abs(i_ae_txn_rec.primary_quantity);
              l_ae_line_rec.account := l_io_pay_acct;
              l_ae_line_rec.resource_id := NULL;
              l_ae_line_rec.cost_element_id := NULL;
              l_ae_line_rec.ae_line_type := 9;  -- Payables

              l_stmt_num := 660;

              insert_account (i_ae_txn_rec,
                              i_ae_curr_rec,
                              l_dr_flag,
                              l_ae_line_rec,
                              l_ae_line_tbl,
                              l_err_rec);

              l_stmt_num := 670;

              -- check error
              IF (l_err_rec.l_err_num <> 0 AND l_err_rec.l_err_num IS NOT NULL) THEN
                 RAISE process_error;
              END IF;

          END IF; /* i_ae_txn_rec.txn_action_id = 1 */

      END IF; /* l_pd_txfr_ind = 0 */

  END IF; /* (l_txn_cost_group_id = l_txfr_txn_cost_group_id) */

  l_stmt_num := 680;

  IF g_debug_flag = 'Y' THEN
     fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ': return >>');
  END IF;

  EXCEPTION

    when no_mfca_acct_error then -- INVCONV
    fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ': Error processing transaction ' || i_ae_txn_rec.transaction_id);
    o_ae_err_rec.l_err_num := 30005;
    o_ae_err_rec.l_err_code := 'CST_PAC_NO_MFCA_ACCTS';
    FND_MESSAGE.set_name('BOM', 'CST_PAC_NO_MFCA_ACCTS');
    o_ae_err_rec.l_err_msg := FND_MESSAGE.Get;

    when no_interorg_profit_acct_error then
    fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ': Error processing transaction ' || i_ae_txn_rec.transaction_id);
    o_ae_err_rec.l_err_num := 30005;
    o_ae_err_rec.l_err_code := 'CST_NO_INTERORG_PROFIT_ACCT';
    FND_MESSAGE.set_name('BOM', 'CST_NO_INTERORG_PROFIT_ACCT');
    o_ae_err_rec.l_err_msg := FND_MESSAGE.Get;

    when process_error then
    o_ae_err_rec.l_err_num := l_err_rec.l_err_num;
    o_ae_err_rec.l_err_code := l_err_rec.l_err_code;
    o_ae_err_rec.l_err_msg := l_err_rec.l_err_msg;

    when others then
    o_ae_err_rec.l_err_num := SQLCODE;
    o_ae_err_rec.l_err_code := '';
    o_ae_err_rec.l_err_msg := l_api_name || ':' || to_char(l_stmt_num) ||
    substr(SQLERRM,1,180);

END cost_internal_order_exp_txn;



/* --======================================================================
-- In case of a transfer across cost groups, the receivables needs to be
-- valued at the cost at Shipping Org. Due to limitations in PAC, we get an
-- estimate as follows:
--
-- If both CG as under same LE then
--  |-- If PACP (Iterative PAC)is enabled, get the CPIC cost
--  |-- Else get the Prior Period PWAC cost
-- Else the cost at perpetual side (MTA transaction value)
--
-- For Internal Order to Non-Inventory (Expense) Destination we also call
-- this procedure to get the value for Expense and Payables while creating
-- distributions for Logical Expense Destination Receipt trxn.
-- ======================================================================*/

Procedure get_pacp_priorPrd_mta_cost (
  i_ae_txn_rec       IN             CSTPALTY.cst_ae_txn_rec_type,
  i_ae_curr_rec      IN             CSTPALTY.cst_ae_curr_rec_type,
  l_ae_line_tbl      IN OUT NOCOPY  CSTPALTY.cst_ae_line_tbl_type,
  o_ae_err_rec       OUT NOCOPY     CSTPALTY.cst_ae_err_rec_type,
  o_pacp_flag              OUT NOCOPY NUMBER,
  o_pacp_pwac_cost         OUT NOCOPY NUMBER,
  o_prev_period_flag       OUT NOCOPY NUMBER,
  o_prev_period_pwac_cost  OUT NOCOPY NUMBER,
  o_perp_ship_flag         OUT NOCOPY NUMBER,
  o_perp_ship_value        OUT NOCOPY NUMBER,
  o_txfr_credit            OUT NOCOPY NUMBER
)
IS
  l_stmt_num              NUMBER := 0;
  l_txfr_legal_entity     NUMBER;
  l_txfr_cost_group_id    NUMBER;
  l_same_le_ct            NUMBER;
  l_prev_period_id        NUMBER;
  l_txfr_percent          NUMBER;
  l_txfr_cost             NUMBER;
  l_use_prev_period_cost  NUMBER;
  l_transfer_cost_flag    VARCHAR2(1);

  l_err_rec               CSTPALTY.cst_ae_err_rec_type;

  l_api_name CONSTANT VARCHAR2(240) := 'CSTPAPBR.get_pacp_priorPrd_mta_cost';

BEGIN

  IF g_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log, l_api_name || ': ' || l_stmt_num || ': begin <<<'
                      || ' transaction_id: ' || i_ae_txn_rec.transaction_id);
  END IF;

  -- Initialize variables.
  -- ---------------------
  l_err_rec.l_err_num := 0;
  l_err_rec.l_err_code := '';
  l_err_rec.l_err_msg := '';


  /* Initialize the variables */
  o_pacp_flag             := 0;
  o_pacp_pwac_cost        := 0;
  o_prev_period_flag      := 0;
  o_prev_period_pwac_cost := 0;
  o_perp_ship_flag        := 0;
  o_perp_ship_value       := 0;
  o_txfr_credit           := 0;

  l_stmt_num := 100;

  /* In case of Logical Expense Req Receipt, for Across CG, Same LE/CT transfer,
     we need to pick the prior period cost of the sending org. */

  /* Get transfer credit information */
  SELECT nvl(transfer_percentage,0),nvl(transfer_cost,0)
  INTO   l_txfr_percent,l_txfr_cost
  FROM   mtl_material_transactions
  WHERE  transaction_id = i_ae_txn_rec.transaction_id;

  l_stmt_num := 110;

  /* Get prior period id */
  SELECT nvl(max(cpp.pac_period_id), -1)
  INTO  l_prev_period_id
  FROM  cst_pac_periods cpp
  WHERE cpp.cost_type_id = i_ae_txn_rec.cost_type_id
  AND   cpp.legal_entity = i_ae_txn_rec.legal_entity_id
  AND   cpp.pac_period_id < i_ae_txn_rec.accounting_period_id;

  l_stmt_num := 120;

  /* The flag selected below indicates if PACP is used or not */
  SELECT TRANSFER_COST_FLAG
  INTO   l_transfer_cost_flag
  FROM   CST_LE_COST_TYPES
  WHERE  LEGAL_ENTITY = i_ae_txn_rec.legal_entity_id
  AND    COST_TYPE_ID = i_ae_txn_rec.cost_type_id;

  l_stmt_num := 130;

  SELECT NVL(MAX(cost_group_id),-1)
  INTO   l_txfr_cost_group_id
  FROM   cst_cost_group_assignments
  WHERE  organization_id = i_ae_txn_rec.xfer_organization_id;

  l_stmt_num := 140;

 /* Get legal entity of the other cost group,if available */
  BEGIN
      SELECT legal_entity
      INTO l_txfr_legal_entity
      FROM cst_cost_groups
      WHERE cost_group_id = l_txfr_cost_group_id;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
      l_txfr_legal_entity := NULL;
  END;

  /* See if i_cost_type_id is attached to the transfer LE as well */
  l_stmt_num := 150;
  SELECT count(*)
  INTO   l_same_le_ct
  FROM   cst_le_cost_types
  WHERE  legal_entity = l_txfr_legal_entity
  AND    cost_type_id = i_ae_txn_rec.cost_type_id;

  /* Check for the same LE/CT combination */
  IF (i_ae_txn_rec.legal_entity_id = l_txfr_legal_entity
      AND l_same_le_ct > 0
      AND l_transfer_cost_flag = 'Y') THEN /* Begin (Same LE PACP available) */

    /* PACP used: The estimated cost is available in CPICD */
    l_stmt_num := 160;

    o_pacp_flag := 1;

    SELECT NVL(CPIC.item_cost,0)
    INTO   o_pacp_pwac_cost
    FROM   CST_PAC_ITEM_COSTS CPIC
    WHERE  CPIC.INVENTORY_ITEM_ID = i_ae_txn_rec.inventory_item_id
    AND    CPIC.COST_GROUP_ID     = i_ae_txn_rec.cost_group_id
    AND    CPIC.PAC_PERIOD_ID     = i_ae_txn_rec.accounting_period_id;

    IF g_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                 ': Using PAC Absorption Cost: ');
    END IF;

    IF (l_txfr_percent <> 0) THEN
       o_txfr_credit := (l_txfr_percent * o_pacp_pwac_cost / 100);
    ELSIF (l_txfr_cost <> 0) THEN
       o_txfr_credit := l_txfr_cost / abs(i_ae_txn_rec.primary_quantity);
    ELSE
       o_txfr_credit := 0;
    END IF;

 ELSE

    IF (i_ae_txn_rec.legal_entity_id = l_txfr_legal_entity
        AND l_same_le_ct > 0
        AND l_prev_period_id <> -1) THEN /* Begin (Same LE Prior Prd available) */

        l_stmt_num := 170;
        l_use_prev_period_cost := 1;

        /* Get prior period PWAC Cost */
        IF (i_ae_txn_rec.txn_action_id = 17) THEN /* Logical Exp Req Rcpt, Take sending Cost Group Cost */
            l_stmt_num := 180;
            BEGIN
              SELECT nvl(CPIC.item_cost,0)
              INTO   o_prev_period_pwac_cost
              FROM   CST_PAC_ITEM_COSTS CPIC
              WHERE  CPIC.INVENTORY_ITEM_ID = i_ae_txn_rec.inventory_item_id
              AND    CPIC.COST_GROUP_ID     = l_txfr_cost_group_id
              AND    CPIC.PAC_PERIOD_ID     = l_prev_period_id;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                /* Use perpetual cost if prior period cost is not available */
                l_use_prev_period_cost := 0;
            END;
        ELSE /* Get Prior Period PWAC cost */
            l_stmt_num := 190;
            BEGIN
              SELECT nvl(CPIC.item_cost,0)
              INTO   o_prev_period_pwac_cost
              FROM   CST_PAC_ITEM_COSTS CPIC
              WHERE  CPIC.INVENTORY_ITEM_ID = i_ae_txn_rec.inventory_item_id
              AND    CPIC.COST_GROUP_ID     = i_ae_txn_rec.cost_group_id
              AND    CPIC.PAC_PERIOD_ID     = l_prev_period_id;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                /* Use perpetual cost if prior period cost is not available */
                l_use_prev_period_cost := 0;
            END;
        END IF;

    ELSE

        /* Use perpetual cost if prior period cost is not available
           or if the cost groups are not in the same LE/CT. */
        l_use_prev_period_cost := 0;

    END IF; /* End (Same LE Prior Prd available) */

    IF (l_use_prev_period_cost = 1) THEN

        o_prev_period_flag := 1;

        IF g_debug_flag = 'Y' THEN
          fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                                         ': Using prior period PWAC cost: ');
        END IF;

        l_stmt_num := 200;

        IF (l_txfr_percent <> 0) THEN
           o_txfr_credit := (l_txfr_percent * o_prev_period_pwac_cost / 100);
        ELSIF (l_txfr_cost <> 0) THEN
           o_txfr_credit := l_txfr_cost / abs(i_ae_txn_rec.primary_quantity);
        ELSE
           o_txfr_credit := 0;
        END IF;

    ELSE /* MTA Entries to be used */ /* or same LE/CT where there is no prior period cost */
        l_stmt_num := 210;

        o_perp_ship_flag := 1;

        IF g_debug_flag = 'Y' THEN
          fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num ||
                                     ': Using MTA cost');
        END IF;

        BEGIN
          IF (i_ae_txn_rec.txn_action_id = 17) THEN

              l_stmt_num := 220;

              SELECT nvl(SUM(ABS(NVL(base_transaction_value, 0))),0)
              INTO o_perp_ship_value
              FROM mtl_transaction_accounts mta
              WHERE mta.transaction_id = i_ae_txn_rec.transaction_id
              and mta.organization_id = i_ae_txn_rec.organization_id
              and mta.accounting_line_type IN (1,2,14)
              and mta.base_transaction_value > 0;

          ELSE

            l_stmt_num := 230;

            SELECT nvl(SUM(ABS(NVL(base_transaction_value, 0))),0)
            INTO o_perp_ship_value
            FROM mtl_transaction_accounts mta
            WHERE mta.transaction_id = i_ae_txn_rec.transaction_id
            and mta.organization_id = i_ae_txn_rec.organization_id
            and mta.accounting_line_type IN (1,2,14)
            and mta.base_transaction_value < 0;

          END IF;

        EXCEPTION
          WHEN no_data_found THEN
             l_stmt_num := 240;
             o_perp_ship_value := 0;
        END;

        l_stmt_num := 250;

        IF (l_txfr_percent <> 0) THEN
            o_txfr_credit := (l_txfr_percent * (o_perp_ship_value)/ (100 * abs(i_ae_txn_rec.primary_quantity)));
        elsif (l_txfr_cost <> 0) THEN
            o_txfr_credit := l_txfr_cost / abs(i_ae_txn_rec.primary_quantity);
        ELSE
            o_txfr_credit := 0;
        END IF;

    END IF; /* (l_use_prev_period_cost = 1) */

  END IF; /* End Same LE PACP available */

  l_stmt_num := 260;
  IF g_debug_flag = 'Y' THEN
     fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num
                              || ': o_pacp_flag :'             || o_pacp_flag
                              || ': o_pacp_pwac_cost :'        || o_pacp_pwac_cost
                              || ': o_prev_period_flag :'      || o_prev_period_flag
                              || ': o_prev_period_pwac_cost :' || o_prev_period_pwac_cost
                              || ': o_perp_ship_flag :'        || o_perp_ship_flag
                              || ': o_perp_ship_value :'       || o_perp_ship_value
                              || ': o_txfr_credit :'           || o_txfr_credit);
     fnd_file.put_line(fnd_file.log,l_api_name || ': ' || l_stmt_num || ': return >>>' );
  END IF;

EXCEPTION

    when others then
    o_ae_err_rec.l_err_num := SQLCODE;
    o_ae_err_rec.l_err_code := '';
    o_ae_err_rec.l_err_msg := l_api_name || ' : ' || to_char(l_stmt_num) ||
    substr(SQLERRM,1,180);

END get_pacp_priorPrd_mta_cost;


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
            o_ae_err_rec          OUT NOCOPY CSTPALTY.cst_ae_err_rec_type
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
l_non_recoverable_tax    NUMBER;

l_hook_used              NUMBER;
l_loc_non_recoverable_tax    NUMBER;
l_loc_recoverable_tax        NUMBER;
l_Err_Num                NUMBER;
l_Err_Code               NUMBER;
process_error		EXCEPTION;

l_stmt_num               NUMBER;
l_api_name               VARCHAR2(100) := 'CompEncumbrance_IntOrdersExp';
l_api_version            NUMBER := 1.0;

l_err_rec                 CSTPALTY.cst_ae_err_rec_type;


BEGIN
-- Initialize local variables.
  l_err_rec.l_err_num := 0;
  l_err_rec.l_err_code := '';
  l_err_rec.l_err_msg := '';

  l_hook_used     :=0;
  l_stmt_num := 5;

  IF g_debug_flag= 'Y' THEN
    FND_FILE.PUT_LINE( FND_FILE.log, 'CompEncumbrance_IntOrdersExp <<< ');
    FND_FILE.PUT_LINE( FND_FILE.log, 'Req Line Identifier: '||p_req_line_id);
    FND_FILE.PUT_LINE( FND_FILE.log, 'Primary Quantity Encumbered before: '||p_total_primary_qty );
  END IF;

  /* 1. Get the budget_account, quantity ordered, and UOM from the Req */
  l_stmt_num := 10;
  SELECT um.uom_code,
         rl.quantity,
         rl.unit_price,
         rd.budget_account_id,
         nvl(rd.nonrecoverable_tax,0) /* Bug 6033153 */
  INTO   l_doc_uom_code,
         l_doc_line_qty,
         l_unit_price,
         x_encumbrance_account,
	 l_non_recoverable_tax  /* Bug 6033153 */
  FROM   po_req_distributions_all rd,
         po_requisition_lines_all rl,
         mtl_units_of_measure um
  WHERE  rd.requisition_line_id   = p_req_line_id
  and    rd.requisition_line_id   = rl.requisition_line_id
  and    rl.UNIT_MEAS_LOOKUP_CODE = um.unit_of_measure;

  if g_debug_flag= 'Y' then
    fnd_file.put_line(fnd_file.log, 'Unit Price: '||l_unit_price||'Encumbrance Account: '||x_encumbrance_account);
  end if;

  /* Get UOM for this item/org from MSI */
  l_stmt_num := 30;
  SELECT primary_uom_code
  INTO   l_primary_uom_code
  FROM   mtl_system_items
  WHERE  organization_id   = p_organization_id
  AND    inventory_item_id = p_item_id;

  /* Convert the total_primary_quantity into source_doc_quantity */
  l_stmt_num := 40;
  INV_Convert.INV_UM_Conversion(
                          from_unit       => l_primary_uom_code,
                          to_unit         => l_doc_uom_code,
                          item_id         => p_item_id,
                          uom_rate        => l_uom_rate );
  IF ( l_uom_rate = -99999) THEN
    fnd_file.put_line(fnd_file.log,'Inv_Convert.inv_um_conversion() failed to get the UOM rate');
    RAISE process_error;
  END IF;

  if g_debug_flag= 'Y' then
    fnd_file.put_line(fnd_file.log, 'Primary UOM: '||l_primary_uom_code);
  end if;
  l_doc_rcv_qty     := p_total_primary_qty * l_uom_rate;
  l_doc_primary_qty := p_primary_qty * l_uom_rate;

  if g_debug_flag= 'Y' then
    fnd_file.put_line(fnd_file.log, 'Document Received Quantity: '||l_doc_rcv_qty||' Document Primary Quantity: '||l_doc_primary_qty);
  end if;

  /* The Requisition is always in the funtional currency */
  /* No need of currency conversion */

  IF ( l_doc_rcv_qty  >= l_doc_line_qty ) THEN
    x_encumbrance_amount := 0;
  ELSIF ( l_doc_rcv_qty + l_doc_primary_qty ) >= l_doc_line_qty THEN
    x_encumbrance_amount :=  l_unit_price * ( l_doc_line_qty - l_doc_rcv_qty )
                            +nvl(l_non_recoverable_tax,0)*( l_doc_line_qty - l_doc_rcv_qty )/l_doc_line_qty;
  ELSE
    x_encumbrance_amount :=  l_unit_price * l_doc_primary_qty
                            +nvl(l_non_recoverable_tax,0)*(l_doc_primary_qty/l_doc_line_qty);
  END IF;


  IF g_debug_flag= 'Y' THEN
    fnd_file.put_line(fnd_file.log, 'Encumbrance Amount: '||x_encumbrance_amount);
    FND_FILE.PUT_LINE( FND_FILE.log, 'CompEncumbrance_IntOrdersExp >>>');
  END IF;

EXCEPTION
  when process_error then
  o_ae_err_rec.l_err_num := l_err_rec.l_err_num;
  o_ae_err_rec.l_err_code := l_err_rec.l_err_code;
  o_ae_err_rec.l_err_msg := l_err_rec.l_err_msg;

  when others then
  o_ae_err_rec.l_err_num := SQLCODE;
  o_ae_err_rec.l_err_code := '';
  o_ae_err_rec.l_err_msg := 'CompEncumbrance_IntOrdersExp' || to_char(l_stmt_num) ||
  substr(SQLERRM,1,180);

END CompEncumbrance_IntOrdersExp;

PROCEDURE CompEncumbrance_IntOrdersExp (
            p_api_version     IN NUMBER,
            p_transaction_id  IN MTL_MATERIAL_TRANSACTIONS.TRANSACTION_ID%TYPE,
            x_encumbrance_amount  OUT NOCOPY NUMBER,
            x_encumbrance_account OUT NOCOPY NUMBER,
            o_ae_err_rec          OUT NOCOPY CSTPALTY.cst_ae_err_rec_type
) IS

l_total_primary_qty      NUMBER;
l_primary_qty            MTL_MATERIAL_TRANSACTIONS.PRIMARY_QUANTITY%TYPE;
l_organization_id        MTL_MATERIAL_TRANSACTIONS.ORGANIZATION_ID%TYPE;
l_trx_source_line_id     MTL_MATERIAL_TRANSACTIONS.TRX_SOURCE_LINE_ID%TYPE;
l_req_line_id            PO_REQUISITION_LINES_ALL.REQUISITION_LINE_ID%TYPE;
l_item_id                MTL_MATERIAL_TRANSACTIONS.INVENTORY_ITEM_ID%TYPE;
l_txn_action_id          MTL_MATERIAL_TRANSACTIONS.TRANSACTION_ACTION_ID%TYPE;
l_txn_src_type_id MTL_MATERIAL_TRANSACTIONS.TRANSACTION_SOURCE_TYPE_ID%TYPE;
l_rcv_txn_id             MTL_MATERIAL_TRANSACTIONS.RCV_TRANSACTION_ID%TYPE;
l_txn_type_id            MTL_MATERIAL_TRANSACTIONS.TRANSACTION_TYPE_ID%TYPE;
l_txn_date               MTL_MATERIAL_TRANSACTIONS.TRANSACTION_DATE%TYPE;

l_stmt_num               NUMBER;
l_api_name               VARCHAR2(100) := 'CompEncumbrance_IntOrdersExp';
l_api_version            NUMBER := 1.0;
l_err_rec                CSTPALTY.cst_ae_err_rec_type;
process_error            EXCEPTION;

BEGIN
-- Initialize local variables.
  l_err_rec.l_err_num := 0;
  l_err_rec.l_err_code := '';
  l_err_rec.l_err_msg := '';

  l_stmt_num := 5;
  if g_debug_flag= 'Y' then
    fnd_file.put_line(fnd_file.log, 'CompEncumbrance_IntOrdersExp (T) <<');
  end if;
  l_stmt_num := 10;

  SELECT
    mmt.trx_source_line_id,
    mmt.primary_quantity,
    mmt.organization_id,
    mmt.inventory_item_id,
    mmt.transaction_action_id,
    mmt.transaction_source_type_id,
    mmt.transaction_type_id,
    mmt.rcv_transaction_id,
    mmt.transaction_date
  INTO
    l_trx_source_line_id,
    l_primary_qty,
    l_organization_id,
    l_item_id,
    l_txn_action_id,
    l_txn_src_type_id,
    l_txn_type_id,
    l_rcv_txn_id,
    l_txn_date
  FROM
    MTL_MATERIAL_TRANSACTIONS mmt
  WHERE
    transaction_id = p_transaction_id;

  --  Get total received quantity so far just before processing the current receipt transaction
  --  this is to ensure that encumbrance reversal accounting entries are generated for each receipt transaction as long as
  --  total receipt quantity of all the receipts is less than corresponding requisition quantity.
  l_stmt_num := 20;
  SELECT sum(primary_quantity)
  INTO   l_total_primary_qty
  from   mtl_material_transactions
  where  transaction_action_id      = l_txn_action_id
  and    transaction_source_type_id = l_txn_src_type_id
  and    transaction_type_id        = l_txn_type_id
  and    trx_source_line_id         = l_req_line_id
  and    organization_id            = l_organization_id
  and    ( transaction_date < l_txn_date or (transaction_date = l_txn_date and transaction_id < p_transaction_id));

  if g_debug_flag= 'Y' then
    fnd_file.put_line(fnd_file.log, 'Total Received Primary Qty just before current receipt transaction: '||l_total_primary_qty);
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
        OE_ORDER_LINES_ALL oel
      WHERE
          oel.LINE_ID          = l_trx_source_line_id;

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
  if g_debug_flag= 'Y' then
    fnd_file.put_line(fnd_file.log, 'Requisition Line ID: '||l_req_line_id);
  end if;

  l_primary_qty := abs(l_primary_qty);
  l_total_primary_qty := abs(l_total_primary_qty);

  if g_debug_flag= 'Y' then
    fnd_file.put_line(fnd_file.log, 'Total Received Primary Qty so far just before current receipt transaction: '||l_total_primary_qty);
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
            o_ae_err_rec         => l_err_rec );

  if g_debug_flag= 'Y' then
    fnd_file.put_line(fnd_file.log, 'CompEncumbrance_IntOrdersExp (T) >>');
  end if;
    if(l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) then
        raise process_error;
    end if;

EXCEPTION
  when process_error then
  o_ae_err_rec.l_err_num := l_err_rec.l_err_num;
  o_ae_err_rec.l_err_code := l_err_rec.l_err_code;
  o_ae_err_rec.l_err_msg := l_err_rec.l_err_msg;

  when others then
  o_ae_err_rec.l_err_num := SQLCODE;
  o_ae_err_rec.l_err_code := '';
  o_ae_err_rec.l_err_msg := 'CompEncumbrance_IntOrdersExp' || to_char(l_stmt_num) ||
  substr(SQLERRM,1,180);

END CompEncumbrance_IntOrdersExp;


END CSTPAPBR;

/
