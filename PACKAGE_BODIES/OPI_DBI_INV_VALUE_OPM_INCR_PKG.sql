--------------------------------------------------------
--  DDL for Package Body OPI_DBI_INV_VALUE_OPM_INCR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_INV_VALUE_OPM_INCR_PKG" as
/* $Header: OPIDIPRB.pls 120.1 2005/08/02 01:46:47 achandak noship $ */

g_user_id NUMBER := nvl(fnd_global.user_id, -1);
g_login_id NUMBER := nvl(fnd_global.login_id, -1);

g_sysdate DATE;
g_created_by NUMBER;
g_last_update_login NUMBER;
g_last_updated_by NUMBER;
g_global_start_date DATE;
g_inception_date DATE := NULL;
global_currency_code VARCHAR2(10);
-- csheu change 09/02/03 --
g_global_rate_type VARCHAR2(15);

g_global_sec_currency_code VARCHAR2(10);
g_global_sec_rate_type VARCHAR2(15);

C_PRI_SEC_CURR_SAME_MARKER CONSTANT NUMBER := -9999;

g_opi_schema VARCHAR2(32);
g_opi_status VARCHAR2(32);
g_opi_industry VARCHAR2(32);
g_opi_appinfo BOOLEAN;


FUNCTION dsql_date(p_date DATE)
RETURN VARCHAR2
IS
BEGIN
RETURN 'TO_DATE(''' || TO_CHAR(p_date,'DD-MON-YYYY HH24:MI:SS') || ''', ''DD-MON-YYYY HH24:MI:SS'')';
END;

Function initial_load
RETURN BOOLEAN
IS
BEGIN
   IF g_inception_date IS NOT NULL
   THEN
       RETURN TRUE;
   ELSE
       RETURN FALSE;
   END IF;
END;

Function incremental_load
RETURN BOOLEAN
IS
BEGIN
    RETURN NOT initial_load;
END;

Procedure Refresh_ONH_LED_Current
(
   from_transaction_id NUMBER,
   to_transaction_id NUMBER
  )
IS
  lv_sql VARCHAR2(32767);
  lv_led_hint VARCHAR2(32);
BEGIN
  IF initial_load
  THEN
      lv_led_hint := '/*+ full(led) */';
  ELSE
      lv_led_hint := '';
  END IF;

  lv_sql :=
  'INSERT  INTO opi_dbi_opm_inv_led_current
  (
   whse_code,
   item_id,
   transaction_date,
   onhand_qty,
   onhand_value_b
  )
  SELECT
      t.whse_code,
      t.item_id,
      t.trans_date,
      SUM(whse_line_trans_qty),
      SUM(DECODE(line_trans_qty, 0, 0,
             led.amount_base*(whse_line_trans_qty/line_trans_qty))) activity_val_b
  FROM
      (
         SELECT ' || lv_led_hint || '
             led.doc_type, led.doc_id, led.line_id,
             TRUNC(led.gl_trans_date) gl_trans_date,
             SUM(led.amount_base * led.debit_credit_sign) amount_base
         FROM gl_subr_led led
         WHERE
             led.acct_ttl_type = 1500
         AND led.subledger_id BETWEEN :1 AND :2
         AND led.gl_trans_date >= :3
         GROUP BY doc_type, doc_id, line_id, TRUNC(gl_trans_date)
      ) led,
      (
         SELECT
             doc_type, doc_id, line_id,
             trans_date, item_id, whse_code,
             SUM(trans_qty) whse_line_trans_qty,
             SUM(SUM(trans_qty))
               OVER (PARTITION BY doc_type, doc_id, line_id) line_trans_qty
         FROM
             (SELECT doc_type, doc_id, line_id, item_id, whse_code,
                  trunc(trans_date) trans_date, trans_qty
              FROM ic_tran_pnd
              WHERE completed_ind = 1 AND gl_posted_ind = decode(doc_type, ''RECV'', gl_posted_ind, 1)
              AND trans_date >= :4
              UNION ALL
              SELECT doc_type, doc_id, line_id, item_id, whse_code,
                  trunc(trans_date) trans_date, trans_qty
              FROM ic_tran_cmp
              WHERE gl_posted_ind = 1
              AND trans_date >= :5
              )
         GROUP BY
             doc_type, doc_id, line_id, trans_date, item_id, whse_code
         HAVING  SUM(trans_qty) <> 0
      ) t
  WHERE
      led.doc_type = t.doc_type
  AND led.doc_id = DECODE(led.doc_type, ''XFER'', t.doc_id, led.doc_id)
  AND led.gl_trans_date = t.trans_date
  AND led.line_id = t.line_id
  GROUP BY
      t.whse_code,
      t.item_id,
      t.trans_date';

  EXECUTE IMMEDIATE lv_sql USING from_transaction_id, to_transaction_id, g_global_start_date,
                                 g_global_start_date, g_global_start_date;

  bis_collection_utilities.put_line(TO_CHAR(sql%rowcount) || ' Onhand transactions collected from permanent subledger.');
  COMMIT;

EXCEPTION
    WHEN OTHERS
    THEN
        bis_collection_utilities.put_line ('Refresh_ONH_LED_Current error: '|| sqlerrm);
        RAISE;

END Refresh_ONH_LED_Current;

/* Refresh_RVAL_LED_Current

    Description -   Extracts Inventory Cost Revaluation data from the
                    permanent subledger and puts it in the current subledger
                    work table, opi_dbi_opm_onhled_current.

                    Cost Revaluation  entries are
                    made in the subledgers with an acct_ttl_type = 6250.

                    The granularity of the data extracted is:
                    organization_id, inventory_item_id, transaction_date.

                    Since this is the permanent subledger, we will extract
                    based on a high watermark approach. The
                    subledger_ids to extract between will be passed in as
                    arguments

    Parameters - from_subledger_id - subledger id to start collecting from
                 to_subledger_id - subledger id to collect upto

    Algorithm - Add rows to the opi_dbi_opm_onhled_current table
                by extracting all the test rows corresponding to
                Cost Revaluation Variance (acct_ttl_type = 6250):


    Error Handling - Commited data in work tables will be truncated when the
                     procedure is rerun aafter an unhandled exception stops the
                     exraction.

    Date            Author              Action
    01 Oct, 2003    Christopher Daly    Wrote routine

*/



Procedure Refresh_RVAL_LED_Current
(
   from_transaction_id NUMBER,
   to_transaction_id NUMBER
  )
IS
  lv_sql VARCHAR2(32767);
  lv_led_hint VARCHAR2(32);
BEGIN
  IF initial_load
  THEN
      lv_led_hint := '/*+ full(led) */';
  ELSE
      lv_led_hint := '';
  END IF;

  lv_sql :=
  'INSERT  INTO opi_dbi_opm_inv_led_current
  (
   whse_code,
   item_id,
   transaction_date,
   onhand_qty,
   onhand_value_b
  )
  SELECT
      whse.whse_code        whse_code,
      led.line_id           item_id,
      led.gl_doc_date + 1   transaction_date,   -- Add one to date to prevent transaction from
                                                -- being counted for morning of last day of period
      0                     onhand_qty,         -- Transaction did not affect quantities, only value
      -sum(led.amount_base)  onhand_value_b
  FROM
      (
         SELECT ' || lv_led_hint || '
             led.doc_id,
             led.line_id,
             TRUNC(led.gl_doc_date) gl_doc_date,
             SUM(led.amount_base * led.debit_credit_sign) amount_base
         FROM gl_subr_led led
         WHERE
             led.acct_ttl_type = 6250   -- IRV ACCT
         AND led.subledger_id BETWEEN :1 AND :2
         AND led.gl_doc_date >= :3
         AND DOC_TYPE = ''RVAL''
         GROUP BY doc_id, line_id, TRUNC(gl_doc_date)
      ) led,
      IC_WHSE_MST  WHSE
  WHERE
      led.doc_id = whse.mtl_organization_id
  GROUP BY
      whse.whse_code,
      led.line_id,   --item_id from subledger line_id column
      led.gl_doc_date';

  EXECUTE IMMEDIATE lv_sql USING from_transaction_id, to_transaction_id, g_global_start_date;

  bis_collection_utilities.put_line(TO_CHAR(sql%rowcount) || ' Onhand Inventory Revaluation transactions collected from permanent subledger.');
  COMMIT;

EXCEPTION
    WHEN OTHERS
    THEN
        bis_collection_utilities.put_line ('Refresh_RVAL_LED_Current error: '|| sqlerrm);
        RAISE;

END Refresh_RVAL_LED_Current;


/* Refresh_ITR_LED_Current

    Description -   Extracts intransit data from the permanent subledger and
                    puts it in the current test subledger table,
                    opi_dbi_opm_intled_current.

                    In-transit activity happens due to inventory transfers
                    and internal orders. Inventory transfer entries are
                    made in the ledgers with an acct_ttl_type = 1570.
                    Internal orders are entered into the subledger with
                    an acct_ttl_type = 1590.

                    The granularity of the data extracted is:
                    organization_id, inventory_item_id, transaction_date.

                    Since this is the permanent subledger, we will extract
                    based on a high watermark approach. The
                    subledger_ids to extract between will be passed in as
                    arguments

                    This routine will extract all inventory transfers
                    (shipments and receipts) that affect the intransit
                    activity of the org passed in as the argument that
                    is present in the permanent subledger.

    Parameters - p_whse_code - warehouse for which to collect data
                 p_from_subledger_id - subledger id to start collecting from
                 p_to_subledger_id - subledger id to collect upto

    Algorithm - Truncate the opi_dbi_opm_intled_current table.

                Extract all the test subledger rows corresponding to
                inventory transfers (acct_ttl_type = 1570):
                    -- extract shipment entries: join to ic_tran_pnd
                    -- extract receipt entries: join to ic_tran_pnd
                    -- extract shipment entries: join to ic_tran_cmp
                    -- extract receipt entries: join to ic_tran_cmp.

    Error Handling - ???

    Date            Author              Action
    16 Oct, 2002    Dinkar Gupta        Wrote routine

*/
PROCEDURE Refresh_ITR_LED_Current       (p_from_subledger_id IN NUMBER,
                                         p_to_subledger_id IN NUMBER)
IS

    proc_name VARCHAR2 (30) ;
    lv_sql VARCHAR2(32767);
    lv_led_hint VARCHAR2(32);

BEGIN
     proc_name  := 'extract_permanent_subledger ';
        /*
        For inventory transfers, we can join back between
        the test subledgers using the doc_id, doc_type and
        line_id.
        Since the FOB point is always 'RECEIPT' currently,
        the subledger stores the shipment lines (line_id = 1)
        as a credit (+ve) and receipt lines as (-ve). Since
        only the intransit of shipping warehouse is affected,
        we need to find the shipping warehouse corresponding
        to the receipt entry in the subledgers. This can
        done by joining back on the doc_id, doc_type and
        line_id.

        The transactions can be in the ic_tran_pnd or the ic_tran_cmp.
        Shipping quantities for shipments must be qualified with a -1
        because they are increases to intransit.
        Intransit account entries have acct_ttl_type = 1570 -- we need this
        because there is an adjusting entry to every 1570 to the account
        type 1500 and we need to ignore that.

        The ic_tran tables have a gl_posted_ind column. The column is
        0 when a transaction has not been posted into the permanent
        subledger and is 1 if it has been posted to the permanent subledger.
        Therefore, when extracting data from the perm. subledger, we need
        to ensure that gl_posted_ind = 1.
        No need to check for the completed_ind in the pending tables here,
        since gl_posted_ind = 1 ==> completed_ind = 1

        */
  IF initial_load
  THEN
      lv_led_hint := '/*+ full(led) */';
  ELSE
      lv_led_hint := '';
  END IF;

    lv_sql :=
    'INSERT  INTO opi_dbi_opm_inv_led_current
    (
     whse_code,
     item_id,
     transaction_date,
     intransit_qty,
     intransit_value_b
    )
        (SELECT whse_code, item_id, trans_date, sum (qty) qty, sum (val) val
          FROM (
            SELECT ' || lv_led_hint || '
                   whse_mst.whse_code,
                   ic_item.item_id,
                   trunc (led.gl_trans_date) trans_date,
                   pnd.trans_qty qty,
                   sum (led.debit_credit_sign * led.amount_base *
                        decode (pnd.line_id, -- check if need exchange rate
                                1, 1, -- shipment does not need exchange rate,
                                      -- so default to 1
                                2, decode (nvl (led.mul_div_sign, 0),
                                           -- if there is no mul_div_sign,
                                           -- there will be no exchange rate,
                                           -- so we return 1 i.e. no exchange
                                           -- rate.
                                           -- Else if mul_div_sign = 0,
                                           -- multiply by exchange rate
                                           0, nvl(led.exchange_rate, 1),
                                           -- if mul_div_sign = 2, divide
                                           -- by exchange rate
                                           1, 1/(nvl (led.exchange_rate, 1))))
                       ) val
              FROM
                   -- there can be a many to many mapping between the
                   -- ic_tran and subledger, so we sum up all quantities
                   -- for a given doc and line id before matching it
                   -- up to subledger.
                   -- Note the -ve sign on the quantities
                   (SELECT doc_type, doc_id, line_id, whse_code, item_id,
                           sum (-1 * trans_qty) trans_qty,
                           trans_um, gl_posted_ind,
                           completed_ind
                      FROM ic_tran_pnd
                      WHERE doc_type = ''XFER''
                        AND completed_ind = 1 -- completed transaction
                        AND gl_posted_ind = 1 -- and posted to perm ledger
                        GROUP BY doc_type, doc_id, line_id, whse_code, item_id,
                                 trans_um, gl_posted_ind, completed_ind
                    UNION ALL
                    SELECT doc_type, doc_id, line_id, whse_code, item_id,
                           sum (-1 * trans_qty) trans_qty, trans_um,
                           gl_posted_ind,
                           1 -- all transactions are completed in tran_cmp
                      FROM ic_tran_cmp
                      WHERE doc_type = ''XFER''
                        AND gl_posted_ind = 1 -- completed+posted transaction
                        GROUP BY doc_type, doc_id, line_id, whse_code, item_id,
                                 trans_um, gl_posted_ind, 1
                   ) pnd,
                   gl_subr_led led,
                   ic_whse_mst whse_mst,
                   mtl_system_items_b msi,
                   ic_item_mst_b ic_item,
                   ic_xfer_mst xfer
              WHERE pnd.doc_id = led.doc_id
                AND pnd.doc_type = led.doc_type
                AND pnd.doc_id = xfer.transfer_id
                AND led.acct_ttl_type = 1570 -- intransit account
                                             -- ignore acct. type 1500 entries
                AND pnd.line_id = led.line_id
                AND led.subledger_id BETWEEN :1
                                         AND :2
                AND trunc(led.gl_trans_date) >= :3
                AND xfer.from_warehouse = whse_mst.whse_code -- for org_id
                                                        -- fob = receipt
                AND ic_item.item_id = pnd.item_id -- for inventory_item_id
                AND msi.segment1 = ic_item.item_no
                AND msi.organization_id = whse_mst.mtl_organization_id
              GROUP BY whse_mst.whse_code, ic_item.item_id,
                       trunc (led.gl_trans_date), pnd.trans_qty,
                       pnd.doc_id, pnd.line_id
                                    -- grouping by line_id and doc_id
                                    -- important if we are summing up
                                    -- multiple lines in ic_tran with same
                                    -- doc_id
            ) inv_intransit_led_led
          GROUP BY whse_code, item_id, trans_date)';

    EXECUTE IMMEDIATE lv_sql USING p_from_subledger_id, p_to_subledger_id, g_global_start_date;

    bis_collection_utilities.put_line(TO_CHAR(sql%rowcount) || ' intransit transactions collected from permanent subledger.');
    COMMIT;

EXCEPTION
    WHEN OTHERS
    THEN
        bis_collection_utilities.put_line ('Refresh_ITR_LED_Current: '|| sqlerrm);
        RAISE;

END Refresh_ITR_LED_Current;


/* Refresh_IOR_LED_Current

    Description -   Extracts internal order intransit from the permanent
                    subledger and
                    puts it in the current test subledger table,
                    opi_dbi_opm_intled_current.

                    Internal orders are entered into the subledger with
                    an acct_ttl_type = 1590.
                    Internal orders have an associated FOB and this
                    has to be taken into account.

                    The granularity of the data extracted is:
                    organization_id, inventory_item_id, transaction_date.

                    Since this is the permanent subledger, we can use the
                    high watermark technique on the extraction.

                    This routine will extract all internal orders (shipments
                    and receipts) that affect the intransit activity of
                    the org passed in as the argument that is present in the
                    permanent subledger.

    Algorithm - Extract all the previously unextracted permanent
                subledger rows corresponding to
                internal orders (acct_ttl_type = 1590):
                    -- extract shipment entries: join to ic_tran_pnd
                    -- extract receipt entries: join to ic_tran_pnd
                    -- extract shipment entries: join to ic_tran_cmp
                    -- extract receipt entries: join to ic_tran_cmp.

    Parameters - p_whse_code - whse_code for which to collect data
                 p_from_subledger_id - subledger id to start collecting from
                 p_to_subledger_id - subledger id to collect upto

    Error Handling - ???

    Date            Author              Action
    29 Oct, 2002    Dinkar Gupta        Wrote package



*/
PROCEDURE Refresh_IOR_LED_Current     (p_from_subledger_id IN NUMBER,
                                       p_to_subledger_id IN NUMBER)
IS
    proc_name VARCHAR2 (50) ;
    lv_sql VARCHAR2(32767);
    lv_led_hint VARCHAR2(32);
BEGIN
         proc_name  := 'extract_led_subr_int_orders ';
    -- Cursor to extract all internal orders from the permanent subledger.
    -- Internal order shipment entries have a doc_type = 'OMSO'
    -- and receipt entries have doc_type = 'PORC'.
    -- Internal orders are qualified by acct_ttl_type = 1590 in the
    -- subledgers.
    -- The doc_type, line_id and completed_ind give a 1-1 mapping between
    -- the ic_tran_pnd/cmp and the subledgers (for cmp table, completed_ind
    -- is always 1).
    --
    -- For tran tables, we need to look at all entries with gl_posted_ind
    -- = 1.
    --
    -- For internal orders, the FOB determines who owns the intransit
    -- inventory. We find the FOB and shipment/receipt orgs from the
    -- oe_order_lines_all table that has one line per line in the
    -- requisition that created the internal order. The mapping from
    -- the ic_tran record to the oe_order_lines record is given by the
    -- line_id.
    --
    -- Shipment entry quantities are always recorded as -ve numbers, though
    -- shipments always increase intransit inventories. Receipts always
    -- decrease intransit but are recorded as +ve quantities in the
    -- ic_tran_tables. So we will have to take the negative of the
    -- quantities in the tran tables.
    --
    -- The ic_tran tables have a gl_posted_ind column. The column is
    -- 0 when a transaction has not been posted into the permanent
    -- subledger and is 1 if it has been posted to the permanent subledger.
    -- Therefore, when extracting data from the test subledger, we need
    -- to ensure that gl_posted_ind = 0 since we do not want to double count.
    -- Additionally, for the pnd table, we need to pick up only completed
    -- transactions, i.e. ones with completed_ind = 1
    --
    -- Why does the ic_tran_pnd/cmp have to be collapsed before matching to
    -- gl_subr_led?
    -- Why do we not need a date join between the ic_tran_pnd/cmp and
    -- gl_subr_led?
    -- There can be a N-N mapping between the tran tables and the ledger.
    -- The N in the ledger can be because of some adjustment accounts etc.
    -- where one line in the tran tables generates multiple lines in the
    -- ledger. So far, all but one such multiple lines I have seen have a
    -- value of 0, but we cannot be sure of this.
    -- The N in the tran tables happen for both shipments and receipts:
    --
    -- Shipments: If a line to be shipped is split into N lines, (where
    -- each such line can be shipped from any valid lot), and any M out of
    -- these N lines are ship confirmed at the same time, all these M
    -- lines get the same line_id, doc_type, doc_id, and trans_date
    -- (including timestamp).
    -- The remaining L = N - M lines, if ship confirmed separately, will get
    -- a different line_id from the M lines. Correspondingly, the ledger will
    -- have one (or more than 1 if there are adjustments etc.) lines for the
    -- M lines with the same line_id, and other entry[ies] for the remaining
    -- lines.
    -- Incidentally, the date of a shipment is the sysdate i.e.
    -- the date at which the order shipped out using the forms, not any
    -- shipment date etc... pre-specified in any of the forms. This means that
    -- all lines with the same line_id will be picked simultaneously to be
    -- posted into the ledger.
    --
    -- Receipts: No item can be over-received - the forms ensure this.
    -- A shipment can be partially received i.e. any of the lines can be
    -- received with any quantity less than or equal to the quantity shipped.
    -- If any receipt line is received into multiple lots,
    -- all the transaction table entries get the same line id. Two separate
    -- lines of receipt get separate line ids. The date can be specified in
    -- the receipt header as any date beyond (or including) the ship date
    -- and before (or including) the sysdate. The dates are trunc'ed, which
    -- means that all entries for a line id get posted to one of the ledgers,
    -- but not both, at the same time.
    -- If a shipped line is received in 2 or more separate receipts i.e.
    -- partial quantity once and partial quantity another time, then
    -- the two lines get separate line ids.
    -- If a shipped line was split, the receipt of the two shipped lines,
    -- even if done simultaneously, gets two separate line_ids. So again,
    -- no risk of ever getting something for the same line id in the future.
    -- The only case for using a date filter would be if some transactions
    -- for a line id have been posted to the ledger, and then some more
    -- transactions for the same line id are entered but not posted.
    -- Then we could mismatch the quantities, but for OMSO and PORC, this
    -- should never happen.

  IF initial_load
  THEN
      lv_led_hint := '/*+ full(subr) */';
  ELSE
      lv_led_hint := '';
  END IF;

    lv_sql :=
    'INSERT  INTO opi_dbi_opm_inv_led_current
    (
     whse_code,
     item_id,
     transaction_date,
     intransit_qty,
     intransit_value_b
    )
        SELECT whse_code, item_id, trans_date, sum (qty) qty, sum (val) val
          FROM
           -- to get the from and to organizations depending on what the FOB
           -- is, we need to join back to the purchase order requisition lines
           -- table, po_requisitions_lines_all.
           -- For shipments (doc_type = OMSO) this is achieved through the
           -- oe_order_lines_all table.
           -- For receipts (doc_type = PORC) this is achieved through the
           -- rcv_transactions table.
           (SELECT w.whse_code,
                   ic_tran.item_id,
                   led.gl_trans_date trans_date,
                   ic_tran.trans_qty qty,
                   sum (led.amount_base * led.debit_credit_sign *
                        decode (mip.fob_point, -- check if need exchange rate
                                2, 1, -- FOB = receipt ==> shipping org is
                                      -- owner. Since this is doc_type
                                      -- OMSO, no exchange rate needed.
                                      -- If FOB =  shipment, then need
                                      -- exchange rate to get shipping org
                                      -- value
                                1, decode (nvl (led.mul_div_sign, 0),
                                           -- if there is no mul_div_sign,
                                           -- there will be no exchange rate,
                                           -- so we return 1 i.e. no exchange
                                           -- rate.
                                           -- Else if mul_div_sign = 0,
                                           -- multiply by exchange rate
                                           0, nvl(led.exchange_rate, 1),
                                           -- if mul_div_sign = 2, divide
                                           -- by exchange rate
                                           1, 1/(nvl (led.exchange_rate, 1))))
                       ) val
              FROM (SELECT doc_type, doc_id, line_id, whse_code, item_id,
                           sum(-1 * trans_qty) trans_qty, trans_um,
                           gl_posted_ind,
                           completed_ind
                      FROM ic_tran_pnd
                      WHERE doc_type = ''OMSO''
                        AND completed_ind = 1   -- completed and
                        AND gl_posted_ind = 1   -- posted to perm ledger
                      GROUP BY doc_type, doc_id, line_id, whse_code, item_id,
                               trans_um, gl_posted_ind, completed_ind
                    UNION ALL
                    -- receipts into different lots can generate two lines
                    -- in ic_tran with same line_id so collapse based on
                    -- line_id
                    SELECT doc_type, doc_id, line_id, whse_code, item_id,
                           sum (-1 * trans_qty) trans_qty, trans_um,
                           gl_posted_ind,
                           1 -- all transactions are completed in tran_cmp
                      FROM ic_tran_cmp
                      WHERE doc_type = ''OMSO''
                        AND gl_posted_ind = 1 -- posted to perm ledger
                      GROUP BY doc_type, doc_id, line_id, whse_code, item_id,
                               trans_um, gl_posted_ind, 1
                   ) ic_tran,
                   oe_order_lines_all oola,
                   po_requisition_lines_all req,
                   mtl_interorg_parameters mip,
                   -- some transactions generate two entries in gl, so
                   -- make sure to collapse gl by line_id, doc_type ...
                   (SELECT ' || lv_led_hint || '
                           trunc (gl_trans_date) gl_trans_date, doc_id,
                           doc_type, line_id, acct_ttl_type,
                           amount_base, debit_credit_sign, exchange_rate,
                           mul_div_sign
                      FROM gl_subr_led subr
                      WHERE subledger_id BETWEEN :1
                                         AND :2
                        AND trunc(subr.gl_trans_date) >= :3
                        AND acct_ttl_type = 1590
                   ) led,
                   ic_whse_mst w
              WHERE ic_tran.doc_type = led.doc_type
                AND ic_tran.line_id = led.line_id
                AND ic_tran.line_id = oola.line_id -- get line id details
                AND oola.source_document_type_id = 10 --ensure this is internal
                                                      --order
                AND req.requisition_line_id = oola.source_document_line_id
                AND mip.from_organization_id = req.source_organization_id
                AND mip.to_organization_id = req.destination_organization_id
                AND w.mtl_organization_id =
                        decode (mip.fob_point,   --FOB selects owning org
                               2, req.source_organization_id,
                               1, req.destination_organization_id)
              GROUP BY w.whse_code,
                       ic_tran.item_id,
                       led.gl_trans_date,
                       ic_tran.trans_qty,
                       ic_tran.line_id
            UNION ALL
            SELECT w.whse_code,
                   ic_tran.item_id,
                   led.gl_trans_date trans_date,
                   ic_tran.trans_qty qty,
                   sum(led.amount_base * led.debit_credit_sign *
                        decode (mip.fob_point, -- check if need exchange rate
                                1, 1, -- FOB = shipping ==> receiving org is
                                      -- owner. Since this is doc_type
                                      -- PORC, no exchange rate needed.
                                      -- If FOB = receipt, then need
                                      -- exchange rate to get shipping org
                                      -- value
                                2, decode (nvl (led.mul_div_sign, 0),
                                           -- if there is no mul_div_sign,
                                           -- there will be no exchange rate,
                                           -- so we return 1 i.e. no exchange
                                           -- rate.
                                           -- Else if mul_div_sign = 0,
                                           -- multiply by exchange rate
                                           0, nvl(led.exchange_rate, 1),
                                           -- if mul_div_sign = 2, divide
                                           -- by exchange rate
                                           1, 1/(nvl (led.exchange_rate, 1))))
                      ) val
              FROM (SELECT doc_type, doc_id, line_id, whse_code, item_id,
                           sum(-1 * trans_qty) trans_qty, trans_um,
                           gl_posted_ind, completed_ind
                      FROM ic_tran_pnd
                      WHERE doc_type = ''PORC''
                        AND completed_ind = 1   -- completed and
                        AND gl_posted_ind = 1   -- posted to perm ledger
                      GROUP BY doc_type, doc_id, line_id, whse_code, item_id,
                               trans_um, gl_posted_ind, completed_ind
                    UNION ALL
                    -- receipts into different lots can generate two lines
                    -- in ic_tran with same line_id so collapse based on
                    -- line_id
                    SELECT doc_type, doc_id, line_id, whse_code, item_id,
                           sum (-1 * trans_qty) trans_qty, trans_um,
                           gl_posted_ind,
                           1 -- all transactions are completed in tran_cmp
                      FROM ic_tran_cmp
                      WHERE doc_type = ''PORC''
                        AND gl_posted_ind = 1 -- posted to perm ledger
                      GROUP BY doc_type, doc_id, line_id, whse_code, item_id,
                               trans_um, gl_posted_ind, 1
                   ) ic_tran,
                   rcv_transactions rcv,
                   po_requisition_lines_all req,
                   mtl_interorg_parameters mip,
                   -- some transactions generate two entries in gl, so
                   -- make sure to collapse gl by line_id, doc_type ...
                   (SELECT ' || lv_led_hint || '
                           trunc (gl_trans_date) gl_trans_date, doc_id,
                           doc_type, line_id, acct_ttl_type,
                           amount_base, debit_credit_sign, exchange_rate,
                           mul_div_sign
                      FROM gl_subr_led subr
                      WHERE subledger_id BETWEEN :4
                                         AND :5
                        AND trunc(subr.gl_trans_date) >= :6
                        AND acct_ttl_type = 1590  -- internal order account
                   ) led,
                   ic_whse_mst w
              WHERE ic_tran.doc_type = led.doc_type
                AND ic_tran.line_id = led.line_id
                AND rcv.transaction_id = led.line_id
                AND req.requisition_line_id = rcv.requisition_line_id
                AND req.destination_type_code = ''INVENTORY'' -- internal order
                AND req.source_type_code = ''INVENTORY''  -- has source and
                                                        -- dest type as
                                                        -- INVENTORY
                AND mip.from_organization_id = req.source_organization_id
                AND mip.to_organization_id = req.destination_organization_id
                AND w.mtl_organization_id =
                        decode (mip.fob_point,   --FOB selects owning org
                               2, req.source_organization_id,
                               1, req.destination_organization_id)
              GROUP BY w.whse_code,
                       ic_tran.item_id,
                       led.gl_trans_date,
                       ic_tran.trans_qty,
                       ic_tran.line_id
            ) int_order_in_transit
          GROUP BY whse_code, item_id, trans_date';


    EXECUTE IMMEDIATE lv_sql USING p_from_subledger_id,
                                   p_to_subledger_id,
                                   g_global_start_date,
                                   p_from_subledger_id,
                                   p_to_subledger_id,
                   g_global_start_date;

    bis_collection_utilities.put_line(TO_CHAR(sql%rowcount) || ' Internal Order transactions collected from permanent subledger.');
    COMMIT;

EXCEPTION
    WHEN OTHERS
    THEN
        bis_collection_utilities.put_line ('Refresh_IOR_LED_Current: '|| sqlerrm);
        RAISE;

END Refresh_IOR_LED_Current;



Procedure Refresh_WIP_LED_Current
(
   from_transaction_id NUMBER,
   to_transaction_id NUMBER
  )
IS
    lv_sql VARCHAR2(32767);
    lv_led_hint VARCHAR2(32);
BEGIN
  IF initial_load
  THEN
      lv_led_hint := '/*+ full(l) */';
  ELSE
      lv_led_hint := '';
  END IF;

    lv_sql :=
    'INSERT  INTO opi_dbi_opm_inv_led_current
    (
        whse_code,
        item_id,
        transaction_date,
        wip_value_b
    )
    SELECT
        led.whse_code,
        gmd.item_id,
        led.transaction_date,
        SUM(led.amount_base * gmd.cost_alloc) wip_val_b
    FROM
        (
            SELECT ' || lv_led_hint || '
                doc_id, h.wip_whse_code whse_code,
                TRUNC(l.gl_trans_date) transaction_date,
                SUM(l.amount_base * l.debit_credit_sign) amount_base
            FROM gl_subr_led l, gme_batch_header h
            WHERE
                l.doc_type = ''PROD''
            AND l.acct_ttl_type = 1530
            AND l.doc_id = h.batch_id
            AND l.subledger_id BETWEEN :1 AND :2
        AND trunc(l.gl_trans_date) >= :3

            GROUP BY l.doc_id, h.wip_whse_code, TRUNC(l.gl_trans_date)
        ) led,
        gme_material_details gmd
    WHERE
        led.doc_id = gmd.batch_id
    AND gmd.line_type = 1
    GROUP BY
        led.whse_code,
        gmd.item_id,
        led.transaction_date';

    EXECUTE IMMEDIATE lv_sql USING from_transaction_id, to_transaction_id, g_global_start_date;

    bis_collection_utilities.put_line(TO_CHAR(sql%rowcount) || ' WIP transactions collected from permanent subledger.');
    COMMIT;

EXCEPTION
    WHEN OTHERS
    THEN
        bis_collection_utilities.put_line ('Refresh_WIP_LED_Current: '|| sqlerrm);
        RAISE;

END Refresh_WIP_LED_Current;



Procedure Put_Net_Activity_to_Stg
IS
BEGIN
  insert  into OPI_DBI_OPM_INV_STG
  (
    organization_id,
/* csheu added the following line */
    subinventory_code,
    inventory_item_id,
    transaction_date,
    onhand_qty,
    intransit_qty,
    primary_uom,
    onhand_value_b,
    intransit_value_b,
    wip_value_b
  )
  SELECT
      whse.mtl_organization_id,
/* csheu added the following line */
/*      stg.whse_code,   */
/* cdaly replaced itwith the following line */
        '-1',  /* Key for Subinventory named Unassigned */
      msi.inventory_item_id,
      stg.transaction_date,
      stg.onhand_qty,
      stg.intransit_qty,
      msi.primary_uom_code,
      stg.onhand_value_b,
      stg.intransit_value_b,
      stg.wip_value_b
  FROM
      (
      SELECT
          item_id                item_id,
          whse_code              whse_code,
          transaction_date       transaction_date,
          SUM(onhand_qty)        onhand_qty,
          SUM(intransit_qty)     intransit_qty,
          SUM(onhand_value_b)    onhand_value_b,
          SUM(intransit_value_b) intransit_value_b,
          SUM(wip_value_b)       wip_value_b
      FROM
          (
          SELECT
              item_id,
              whse_code,
              transaction_date,
              onhand_qty,
              intransit_qty,
              onhand_value_b,
              intransit_value_b,
              wip_value_b
          FROM
              opi_dbi_opm_inv_tst_current c
       --   UNION ALL
       --   SELECT
       --       item_id,
       --       whse_code,
       --       transaction_date,
       --       -onhand_qty,
       --       -intransit_qty,
       --       -onhand_value_b,
       --       -intransit_value_b,
       --       -wip_value_b
       --   FROM
       --       opi_dbi_opm_inv_tst_prior p
          UNION ALL
          SELECT
              item_id,
              whse_code,
              transaction_date,
              onhand_qty,
              intransit_qty,
              onhand_value_b,
              intransit_value_b,
              wip_value_b
          FROM
              opi_dbi_opm_inv_led_current led
          )
      GROUP BY
          item_id,
          whse_code,
          transaction_date
      HAVING
          SUM(onhand_qty)        <> 0
      OR  SUM(intransit_qty)     <> 0
      OR  SUM(onhand_value_b)    <> 0
      OR  SUM(intransit_value_b) <> 0
      OR  SUM(wip_value_b)       <> 0
      ) stg,
      ic_item_mst_b iim,
      ic_whse_mst whse,
      mtl_system_items_b msi
  WHERE
      iim.item_id = stg.item_id
  AND whse.whse_code = stg.whse_code
  AND msi.organization_id = whse.mtl_organization_id
  AND msi.segment1 = iim.item_no
;

  bis_collection_utilities.put_line(TO_CHAR(SQL%ROWCOUNT) || ' Subledger Net Change rows identified.');

  fnd_stats.gather_table_stats(
            ownname => g_opi_schema,
            tabname => 'OPI_DBI_OPM_INV_STG',
            percent => 10);

  COMMIT;

EXCEPTION
    WHEN OTHERS
    THEN
        bis_collection_utilities.put_line ('Put_Net_Activity_to_Stg: '|| sqlerrm);
        RAISE;

END Put_Net_Activity_to_Stg;


FUNCTION Get_OPM_Net_Activity (
  errbuf  IN OUT NOCOPY VARCHAR2,
  retcode IN OUT NOCOPY VARCHAR2
)
  return NUMBER
IS
  l_from_transaction_id NUMBER;
  l_to_transaction_id NUMBER;

  l_status VARCHAR2(20);
  l_return NUMBER;

BEGIN
    bis_collection_utilities.put_line('Start of collecting daily activity.');
    l_return := 0;

    BEGIN
/*        SELECT
            log.transaction_id + 1 from_transaction_id,
            led.to_transaction_id
        INTO
            l_from_transaction_id,
            l_to_transaction_id
        FROM
            (
                SELECT /*+ NO_MERGE   MAX(subledger_id) to_transaction_id
                FROM gl_subr_led
            ) led,
            opi_dbi_inv_value_log log
        WHERE
            log.type = 'GSL'
        AND log.organization_id = 0
        AND log.source = 2;*/

        select    MAX(subledger_id),MIN(subledger_id)  into   l_to_transaction_id , l_from_transaction_id
                FROM gl_subr_led
        where gl_trans_date > g_global_start_date;


    EXCEPTION
    WHEN OTHERS THEN
        bis_collection_utilities.put_line('Missing log record indicates that Initial Load of Inventory did not complete successfully.');
        bis_collection_utilities.put_line('Please verify the successful completion of Initial Load before submitting Incremental Load.');
        RAISE;
    END;

     bis_collection_utilities.put_line('Starting Transaction_ID = ' || to_char(l_from_transaction_id));
     bis_collection_utilities.put_line('Ending Transaction_ID = ' || to_char(l_to_transaction_id));
     IF (l_to_transaction_id is not NULL AND  l_from_transaction_id is not null) THEN
         Refresh_ONH_LED_Current(l_from_transaction_id, l_to_transaction_id);
         Refresh_RVAL_LED_Current(l_from_transaction_id, l_to_transaction_id);
         Refresh_ITR_LED_Current(l_from_transaction_id, l_to_transaction_id);
         Refresh_IOR_LED_Current(l_from_transaction_id, l_to_transaction_id);
         Refresh_WIP_LED_Current(l_from_transaction_id, l_to_transaction_id);

      --   Refresh_ONH_TST_Current;
       --  Refresh_RVAL_TST_Current;
       --  Refresh_ITR_TST_Current;
       --  Refresh_IOR_TST_Current;
        -- Refresh_WIP_TST_Current;

         Put_Net_Activity_to_Stg;
     END IF;
    --Move_ONH_TST_Current_to_Prior;

--put call for log

    bis_collection_utilities.put_line('End of collecting daily activity.');
    commit;

    return l_return;

EXCEPTION
    WHEN OTHERS
    THEN
        bis_collection_utilities.put_line ('Get_OPM_Net_Activity: '|| sqlerrm);
        RAISE;

END Get_OPM_Net_Activity;




PROCEDURE OPM_Refresh
(
    errbuf  IN OUT NOCOPY VARCHAR2,
    retcode IN OUT NOCOPY VARCHAR2
)
IS
    l_list dbms_sql.varchar2_table;
    l_from_date DATE;
    l_has_missing_date BOOLEAN;
    l_staging NUMBER;
    l_count NUMBER;
    l_rows1 NUMBER;
    l_rows2 NUMBER;
BEGIN

    l_list(1) := 'BIS_GLOBAL_START_DATE';
    l_list(2) := 'BIS_PRIMARY_CURRENCY_CODE';
    IF (NOT BIS_COMMON_PARAMETERS.CHECK_GLOBAL_PARAMETERS(l_list))
    THEN
        bis_collection_utilities.put_line(
          'Missing global parameters. ' ||
          'Please setup global_start_date and primary_currency_code first.');
        retcode := 1;
        return;
    END IF;



    -- If initial load hasn't been run yet, exit and warn.

    -- set global variables
    bis_collection_utilities.put_line('Set global variables.');
    l_rows1 := 0;
    l_rows2 := 0;
    g_sysdate := sysdate;
    g_created_by := fnd_global.user_id;
    g_last_update_login := fnd_global.login_id;
    g_last_updated_by := fnd_global.user_id;

    bis_collection_utilities.put_line('Collection started at ' || TO_CHAR(g_sysdate, 'DD-MON-YYYY HH24:MI:SS'));

    select BIS_COMMON_PARAMETERS.GET_GLOBAL_START_DATE into g_global_start_date from DUAL;
    IF g_global_start_date IS NULL
    THEN
        bis_collection_utilities.put_line('Global start date is not available. Can not proceed.');
        return;
    END IF;




    -- collect new activity
    IF (Get_OPM_Net_Activity (errbuf, retcode) = -1)
    THEN
        bis_collection_utilities.put_line('Fail to collect daily activity into staging table.');
    ELSE
        COMMIT;
    END IF;

    -- SETUP/WRAPUP: take out wrapup api call, to be safe, put a commit, log message here.
    commit;
    bis_collection_utilities.put_line('Successfully refreshed inventory value base table at ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
    bis_collection_utilities.put_line(TO_CHAR(l_rows1 + l_rows2) || ' rows have been inserted from OPM');
    return;

EXCEPTION
    WHEN OTHERS THEN
      bis_collection_utilities.put_line('Failed in refreshing inventory value base table.');
      bis_collection_utilities.put_line(SQLERRM);
      retcode := SQLCODE;
      errbuf := SQLERRM;
      RAISE_APPLICATION_ERROR(-20000,errbuf);
      RETURN;

END OPM_Refresh;


PROCEDURE Extract_OPM_Daily_Activity
(
    errbuf  IN OUT NOCOPY VARCHAR2,
    retcode IN OUT NOCOPY VARCHAR2,
    l_min_inception_date IN DATE
)
IS
BEGIN

    g_inception_date := l_min_inception_date;
    OPM_Refresh(errbuf, retcode);

END Extract_OPM_Daily_Activity;

BEGIN
    g_opi_appinfo := fnd_installation.get_app_info
                      (
                       application_short_name => 'OPI',
                       status => g_opi_status,
                       industry => g_opi_industry,
                       oracle_schema => g_opi_schema
                       );

END OPI_DBI_INV_VALUE_OPM_INCR_PKG;

/
