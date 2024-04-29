--------------------------------------------------------
--  DDL for Package Body OPI_DBI_INV_VALUE_OPM_INIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_INV_VALUE_OPM_INIT_PKG" AS
/*$Header: OPIDIPIB.pls 120.1 2005/08/02 01:45:18 achandak noship $ */

g_user_id NUMBER := nvl(fnd_global.user_id, -1);
g_login_id NUMBER := nvl(fnd_global.login_id, -1);
g_inception_date DATE;
g_global_start_date DATE := SYSDATE;


g_opi_schema VARCHAR2(32);
g_opi_status VARCHAR2(32);
g_opi_industry VARCHAR2(32);
g_opi_appinfo BOOLEAN;


PROCEDURE Clean_OPM_Tables
IS
    l_stmt_num NUMBER;
    l_opi_schema      VARCHAR2(30);
    l_status          VARCHAR2(30);
    l_industry        VARCHAR2(30);
    l_err_num NUMBER;
    l_err_msg VARCHAR2(255);
BEGIN

    l_stmt_num := 10;
    IF fnd_installation.get_app_info( 'OPI', l_status, l_industry, l_opi_schema)
    THEN

        bis_collection_utilities.put_line('Initializing Tables:');

        l_stmt_num := 10;
        /* Truncating Staging Tables */
        execute immediate 'truncate table ' || l_opi_schema || '.OPI_DBI_OPM_INV_STG ';
        bis_collection_utilities.put_line('... OPI_DBI_OPM_INV_STG');

        l_stmt_num := 20;
        /* Truncating Base Table */
        DELETE FROM OPI_DBI_INV_VALUE_F WHERE source = 2;
        bis_collection_utilities.put_line('... OPI_DBI_INV_VALUE_F');

        l_stmt_num := 30;
        /* Truncating Log Table */
        DELETE FROM OPI_DBI_INV_VALUE_LOG log
        WHERE type IN ('GSL','OID');
        bis_collection_utilities.put_line('... OPI_DBI_INV_VALUE_LOG');

        l_stmt_num := 40;
        /* Truncating Conversion Rates Table */
        execute immediate 'truncate table ' || l_opi_schema || '.OPI_DBI_OPM_CONVERSION_RATES ';
        bis_collection_utilities.put_line('... OPI_DBI_OPM_CONVERSION_RATES');

        l_stmt_num := 50;
        /* Truncating OPM Inception Qtys */
        execute immediate 'truncate table ' || l_opi_schema || '.OPI_DBI_OPM_INCEPTION_QTY ';
        bis_collection_utilities.put_line('... OPI_DBI_OPM_INCEPTION_QTY');

        l_stmt_num := 60;
        /* Truncating OPM Current Permanent Subledger Rows */
        execute immediate 'truncate table ' || l_opi_schema || '.OPI_DBI_OPM_INV_LED_CURRENT ';
        bis_collection_utilities.put_line('... OPI_DBI_OPM_INV_LED_CURRENT');

        l_stmt_num := 70;
        /* Truncating OPM Current Test Subldger Rows */
        execute immediate 'truncate table ' || l_opi_schema || '.OPI_DBI_OPM_INV_TST_CURRENT ';
        bis_collection_utilities.put_line('... OPI_DBI_OPM_INV_TST_CURRENT');

        l_stmt_num := 80;
        /* Truncating OPM Prior Test Subledger Rows */
        execute immediate 'truncate table ' || l_opi_schema || '.OPI_DBI_OPM_INV_TST_PRIOR ';
        bis_collection_utilities.put_line('... OPI_DBI_OPM_INV_TST_PRIOR');

    END IF;

EXCEPTION
    WHEN OTHERS THEN
        l_err_msg := 'OPI_DBI_INV_VALUE_OPM_INIT_PKG.Clean_OPM_Tables (Error at statement '
                    || to_char(l_stmt_num)
                    || '): '
                    || substr(SQLERRM, 1,200);

        bis_collection_utilities.put_line('Error Message: ' || l_err_msg);

        RAISE;

END Clean_OPM_Tables;


PROCEDURE Get_OPM_Inception_Date(l_min_inception_date OUT NOCOPY DATE)
IS
    l_stmt_num NUMBER;

    CURSOR inception_date_cursor IS
    SELECT o.orgn_code co_code, log.transaction_date inception_date
    FROM opi_dbi_inv_value_log log, sy_orgn_mst o
    WHERE log.type= 'OID'
    AND o.organization_id = log.organization_id
    AND g_global_start_date > log.transaction_date;

BEGIN

    l_stmt_num := 10;
    SELECT BIS_COMMON_PARAMETERS.GET_GLOBAL_START_DATE INTO g_global_start_date FROM DUAL;

    l_stmt_num := 20;

/*
The following insert statement creates OPM Inception Balance rows in opi_dbi_inv_value_log, one for
each co_code represented in gl_subr_led.  Each purge will be for a single company, so this is the
right level of granularity.  If the global_start_date precedes the available data, it is important
that all of a company's rows be preserved.  In such a case, if one company has less history than another,
then we need to know the shortenned history so that the correct costing date is used.
*/
    INSERT  INTO opi_dbi_inv_value_log
    (
        organization_id,
        transaction_id,
        transaction_date,
        type,
        source,
        creation_date,
        last_update_date,
        created_by,
        last_updated_by,
        last_update_login
    )
    SELECT
        c.organization_id              organization_id,
        0                              transaction_id,
        TRUNC(MIN(led.gl_trans_date))  transaction_date,
        'OID'                          type,
        2                              source,
        SYSDATE                        creation_date,
        SYSDATE                        last_update_date,
        g_user_id                      created_by,
        g_user_id                      last_updated_by,
        g_login_id                     last_update_login
    FROM
        sy_orgn_mst c,
        gl_subr_led led
    WHERE
        c.orgn_code = led.co_code
    GROUP BY c.organization_id;

    bis_collection_utilities.put_line(TO_CHAR(sql%rowcount) || ' company inception date rows created.');

    fnd_stats.gather_table_stats(
        ownname => g_opi_schema,
        tabname => 'OPI_DBI_INV_VALUE_LOG',
        percent => 10);
/*
The following minimum inception date is calculated for two purposes:
(1) to assist in the quick determination of whether any data is clipped by the global_start_date
(2) to be returned by this procedure for passing to the daily activity collection, letting
    it know that it is being called in an initial mode.
*/
    SELECT MIN(transaction_date) INTO l_min_inception_date
    FROM opi_dbi_inv_value_log
    WHERE type = 'OID';

    bis_collection_utilities.put_line(TO_CHAR(sql%rowcount) || ' l_min_inception_date values determined.');

    IF g_global_start_date > l_min_inception_date
    THEN
        bis_collection_utilities.put_line('Warning: The Global Start Date (' || TO_CHAR(g_global_start_date) ||
                         ') is later than the earliest available transaction');
        bis_collection_utilities.put_line('This means that you are not going to extract all ' ||
                         'of the historic data that exists in your database.');
        bis_collection_utilities.put_line('This affects the following OPM companies:');
        bis_collection_utilities.put_line(
            RPAD('-',10,'-')     || ' ' || RPAD('-',15,'-')          || ' ' || RPAD('-',15,'-'));
        bis_collection_utilities.put_line(
            RPAD('Company',10) || ' ' || RPAD('Earliest Date', 15) || ' ' || 'Days Truncated');
        bis_collection_utilities.put_line(
            RPAD('-',10,'-')     || ' ' || RPAD('-',15,'-')          || ' ' || RPAD('-',15,'-'));

        FOR id IN inception_date_cursor
        LOOP
            bis_collection_utilities.put_line(RPAD(id.co_code,11) ||
                                 RPAD(TO_CHAR(id.inception_date),16) ||
                                 TO_CHAR(ROUND(g_global_start_date - id.inception_date))
                                );
        END LOOP;

        UPDATE opi_dbi_inv_value_log
        SET transaction_date = g_global_start_date
        WHERE type = 'OID'
        AND g_global_start_date > transaction_date;

        bis_collection_utilities.put_line(TO_CHAR(sql%rowcount) || ' inception dates shortened.');

    END IF;

    COMMIT;

EXCEPTION
    WHEN OTHERS
    THEN
        bis_collection_utilities.put_line ('Get_OPM_Inception_Date: '|| sqlerrm);
        RAISE;

END Get_OPM_Inception_Date;


PROCEDURE Get_OPM_Onhand_Balance(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
    l_stmt_num NUMBER;
    l_row_count NUMBER;
    l_err_num NUMBER;
    l_err_msg VARCHAR2(255);
BEGIN

    /* Insert Inception Balances Into its Staging table */
    l_stmt_num := 10;

    INSERT  INTO opi_dbi_opm_inception_qty
        (item_id, whse_code, type, quantity)
    SELECT
        item_id, whse_code, 1, SUM(onhand_qty) onhand_qty
    FROM
        (
        SELECT
            item_id, whse_code, loct_onhand onhand_qty
        FROM
            ic_loct_inv
        UNION ALL
        SELECT t.item_id, t.whse_code, -t.trans_qty
        FROM
            opi_dbi_inv_value_log sd,
            sy_orgn_mst o,
            ic_tran_pnd t
        WHERE
            sd.type = 'OID'
        AND o.organization_id = sd.organization_id
        AND t.co_code = o.orgn_code
        AND t.completed_ind = 1
        AND t.trans_date >= sd.transaction_date
        UNION ALL
        SELECT t.item_id, t.whse_code, -t.trans_qty
        FROM
            opi_dbi_inv_value_log sd,
            sy_orgn_mst o,
            ic_tran_cmp t
        WHERE
            sd.type = 'OID'
        AND o.organization_id = sd.organization_id
        AND t.co_code = o.orgn_code
        AND t.trans_date >= sd.transaction_date
        ) onh
    GROUP BY item_id, whse_code
    HAVING SUM(onhand_qty) <> 0;

    bis_collection_utilities.put_line(TO_CHAR(sql%rowcount) || ' Onhand Inception Quantity rows extracted.');

EXCEPTION
    WHEN OTHERS THEN

        l_err_num := SQLCODE;
        l_err_msg := 'OPI_DBI_INV_VALUE_OPM_INIT_PKG.Get_OPM_Onhand_Balance ('
                    || to_char(l_stmt_num) || '): ' || substr(SQLERRM, 1,200);

        bis_collection_utilities.put_line('OPI_DBI_INV_VALUE_OPM_INIT_PKG.Get_OPM_Onhand_Balance '
                    || '- Error at statement (' || to_char(l_stmt_num) || ')');
        bis_collection_utilities.put_line('Error Number: ' ||  to_char(l_err_num));
        bis_collection_utilities.put_line('Error Message: ' || l_err_msg);

        RAISE_APPLICATION_ERROR(-20000, errbuf);

END Get_OPM_Onhand_Balance;


PROCEDURE Cost_Inception_Quantities
IS
BEGIN

    INSERT  INTO opi_pmi_cost_param_gtmp
    (whse_code, orgn_code, item_id, trans_date)
    SELECT
        DISTINCT q.whse_code, w.orgn_code, q.item_id, id.transaction_date
    FROM
        opi_dbi_opm_inception_qty q,
        opi_dbi_inv_value_log id,
        ic_whse_mst w,
        sy_orgn_mst o,
        sy_orgn_mst c
    WHERE
        w.whse_code = q.whse_code
    AND o.orgn_code = w.orgn_code
    AND c.orgn_code = o.co_code
    AND id.type = 'OID'
    AND id.organization_id = c.organization_id;

    bis_collection_utilities.put_line(TO_CHAR(sql%rowcount) || ' cost parameter rows inserted.');

    opi_pmi_cost.get_cost;

EXCEPTION
    WHEN OTHERS
    THEN
        bis_collection_utilities.put_line ('Cost_Inception_Quantities: '|| sqlerrm);
        RAISE;

END Cost_Inception_Quantities;


PROCEDURE Create_Inception_Balances
IS
    l_row_count NUMBER;
BEGIN
    INSERT  INTO opi_dbi_opm_inv_stg
    (
        ORGANIZATION_ID,
        INVENTORY_ITEM_ID,
/* csheu added the following line */
        SUBINVENTORY_CODE,
        TRANSACTION_DATE,
        ONHAND_QTY,
        INTRANSIT_QTY,
        PRIMARY_UOM,
        ONHAND_VALUE_B,
        INTRANSIT_VALUE_B
    )
    SELECT
        msi.organization_id,
        msi.inventory_item_id,
/* csheu added the following line */
/*        w.whse_code subinventory_code, */
/* cdaly replaced it with the following line */
        '-1',  /* Key for Subinventory named Unassigned */
        c.trans_date,
        SUM(DECODE(q.type, 1, q.quantity, 0)) onhand_qty,
        SUM(DECODE(q.type, 2, q.quantity, 0)) intransit_qty,
        msi.primary_uom_code,
        SUM(DECODE(q.type, 1, q.quantity * c.total_cost, 0)) onhand_value_b,
        SUM(DECODE(q.type, 2, q.quantity * c.total_cost, 0)) intransit_value_b
    FROM
        opi_dbi_opm_inception_qty q,
        opi_pmi_cost_result_gtmp c,
        ic_item_mst_b iim,
        ic_whse_mst w,
        mtl_system_items_b msi
    WHERE
        q.type = 1
    AND c.whse_code = q.whse_code
    AND c.item_id = q.item_id
    AND iim.item_id = q.item_id
    AND iim.noninv_ind = 0
    AND w.whse_code = q.whse_code
    AND msi.segment1 = iim.item_no
    AND msi.organization_id = w.mtl_organization_id
    GROUP BY
        msi.organization_id,
        msi.inventory_item_id,
-- csheu added the following line
--        w.whse_code,
/* cdaly replaced it with the following line */
        '-1',  /* Key for Subinventory named Unassigned */
        c.trans_date,
        msi.primary_uom_code
;

    l_row_count := sql%rowcount;
    bis_collection_utilities.put_line(TO_CHAR(l_row_count) || ' Onhand and Intransit Inception Balances Costed.');

    -- SETUP/WRAPUP: take out wrapup api call, put log message here.
    bis_collection_utilities.put_line('FINISHED Onhand Inception Balances SUCCESSFULLY');

    COMMIT;

EXCEPTION
    WHEN OTHERS
    THEN
        bis_collection_utilities.put_line ('Create_Inception_Balances: '|| sqlerrm);
        RAISE;

END Create_Inception_Balances;


/*
 Get_OPM_Intransit_Balance

    Description -   Calculate the OPM inception intransit balances for all
                    orgs.

    Algorithm - Inception Intransit balance =
                    Total Intransit Activity - Current Intransit Activity
                Inception implies as of start of the collection date, i.e.
                the end of day value of the collection start date is the
                inception balance + all activity on collection start date.

                The granularity of the intransit balance is organization_id,
                inventory_item_id.

                Current Intransit Activity:
                    Contributions to the intransit current inventory are
                    made by:
                    1. inventory transfers - only those that have not
                       been completed yet i.e. transfer_status = 2
                    2. internal orders


                Total Intransit Activity:
                    Contributions to the total intransit inventory
                    are made by:
                    1. Inventory transfers - Consists of all subinventory
                       activity that was ever undertaken i.e. completed
                       or not completed. Since completed activity is
                       reported with the receiving warehouse's code,
                       make sure to join back and get the shipping warehouse
                       code.
                    2. Internal orders


    Parameters -errbuf
                retcode

    Error Handling -If collection fails, undoes everything done to make sure
                    no change is committed.

    Date                Author                  Action
    14 Oct, 2002        Dinkar Gupta            Prototyped
*/
PROCEDURE Get_OPM_Intransit_Balance (   errbuf in out NOCOPY varchar2,
                                        retcode in out NOCOPY varchar2)
IS
    proc_name VARCHAR2(40);

BEGIN
    proc_name  := 'Get_OPM_Intransit_Balance ' ;

    INSERT  INTO opi_dbi_opm_inception_qty
        (whse_code, item_id, type, quantity)
    SELECT whse, item, 2, sum (qty) qty
      FROM ( /* inception = current - total */
        SELECT whse, item, qty
          FROM ( /* current inventory transfers */
            -- Current intransit inventory transfer activity is determined by
            -- the transfer_status = 2 for a transfer_id in the
            -- transfer master  table, IC_XFER_MST. The transfer_id
            -- is the same as the doc_id in the pending transaction tables,
            -- IC_TRAN_PND. Since the FOB = 'Receipt'
            -- always, only the shipment lines in the transaction
            -- tables will contribute to the intransit inventory of the
            -- shipping warehouse.
            -- Note that incomplete inventory transfers (i.e. ones that have
            -- not been received and therefore contribute to current intransit
            -- balances) are found only in IC_TRAN_PND.
            -- The pnd tables store -ve quantities for shipments which increase
            -- intransit and positive quantities for receipts which decrease
            -- intransit inventory. So quantity signs need to be reversed.
            SELECT
                   pnd.whse_code whse,
                   pnd.item_id item,
                   (-1 * pnd.trans_qty) qty
              FROM
                   ic_tran_pnd pnd,
                   ic_xfer_mst xfer,
                   sy_orgn_mst o,
                   opi_dbi_inv_value_log sd
              WHERE
                    pnd.doc_id = xfer.transfer_id
                AND xfer.transfer_status = 2 -- not received yet
                AND pnd.doc_type = 'XFER' -- inventory transfer
                AND pnd.completed_ind = 1 -- not pending
                AND pnd.line_id = 1 -- shipping entry
                AND o.orgn_code = pnd.co_code
                AND sd.type = 'OID'
                AND sd.organization_id = o.organization_id
                AND pnd.trans_date >= sd.transaction_date
                                                -- collect only from global
                                                -- start date
            UNION ALL  /* current internal order activity*/
            -- Current intransit internal order activity is taken from the
            -- MTL_SUPPLY table that stores unfinished internal orders.
            -- Since this is the OPM extraction, need to ensure that
            -- the org corresponding the internal order is an OPM org i.e.
            -- PROCESS_ENABLED_FLAG = 'Y' in MTL_PARAMETERS.
            -- The owning org for internal orders is determined by the FOB
            -- which can be either receipt or shipment. We cannot use the
            -- intransit_owning_org_id field of MTL_SUPPLY since the FOB
            -- can be changed while the internal order is being processed.
            -- In addition, there is a bug with that field, as far as I can
            -- tell. The intransit_owning_org_id field is populated incorrectly
            -- as of 10/31/02.
            -- Since MTL supply stores the Quantity (quantity released by the
            -- shipping org in their primary UOM)
            -- and the to_org_primary_quantity
            -- (the primary quantity in the receiving org's primary UOM) we do
            -- not need any UOM conversions.
            SELECT whse_mst.whse_code whse,
                   ic_item.item_id item,
                   (decode (mip.fob_point,
                            2, nvl (sup.quantity,0),
                            1, nvl (sup.to_org_primary_quantity,0))) qty
              FROM mtl_supply sup,
                   mtl_parameters mp,
                   mtl_system_items_b msi,
                   ic_whse_mst whse_mst,
                   ic_item_mst_b ic_item,
                   mtl_interorg_parameters mip,
                   sy_orgn_mst o,
                   sy_orgn_mst c,
                   opi_dbi_inv_value_log sd
              WHERE supply_type_code in ('SHIPMENT' , 'RECEIVING')
                AND intransit_owning_org_id is not NULL -- necessary for
                                                        -- intransit
                AND mip.from_organization_id = sup.from_organization_id
                AND mip.to_organization_id = sup.to_organization_id
                AND nvl(mip.fob_point,-1) > 0
                AND whse_mst.mtl_organization_id =
                        decode(mip.fob_point,
                               1, sup.to_organization_id,  -- receipt
                               2, sup.from_organization_id, -- shipment
                               -1)
                AND mp.organization_id = whse_mst.mtl_organization_id
                AND mp.process_enabled_flag = 'Y' -- OPM org
                AND msi.inventory_item_id = sup.item_id -- to get OPM item_id
                AND msi.organization_id = whse_mst.mtl_organization_id
                AND msi.segment1 = ic_item.item_no
                AND nvl(msi.inventory_asset_flag,'N') = 'Y'
                                                    -- ignore expense items
                AND o.orgn_code = whse_mst.orgn_code
                AND c.orgn_code = o.co_code
                AND sd.organization_id = c.organization_id
                AND sd.type = 'OID'
                AND trunc (receipt_date) >= sd.transaction_date
                                                -- collect only from global
                                                -- start date
          ) current_intransit
        UNION ALL  /* (-) total intransit */
        -- The total quantity is the sum of all the internal transfer and
        -- internal order activity.
        -- Since inception quantity = total quantity - current quantity,
        -- we take the negative of the total quantity in the outer most
        -- select here.
        SELECT whse, item, (-1 * qty) qty
          FROM ( /* total inventory transfers */
            -- Total intransit inventory transfer activity is the sum of all
            -- inventory transfer transactions i.e. with doc_type = 'XFER'
            -- The transactions must be after the collection start date.
            -- Since the FOB = 'Receipt' always and receipt transactions
            -- i.e. those with line_type = 2, are associated with the receiving
            -- warehouse, we need to join to the transfer master, ic_xfer_mst,
            -- to figure out the shipping org whose intransit balance is
            -- affected. For consistency with the all other modules, we look
            -- at pending transactions where completed_ind = 1.
            -- The pnd/cmp tables store -ve quantities for shipments which
            -- increase intransit and positive quantities for receipts which
            -- decrease intransit inventory.
            -- So quantity signs need to be reversed.
            SELECT xfer.from_warehouse whse,
                   pnd.item_id item,
                   (-1 * pnd.trans_qty) qty
              FROM
                   ic_tran_vw1 pnd,
                   ic_xfer_mst xfer,
                   sy_orgn_mst o,
                   opi_dbi_inv_value_log sd
              WHERE pnd.completed_ind = 1 -- completed transfer
                                          -- view sets completed_ind to 1
                                          -- for everything in the ic_tran_cmp
                AND pnd.doc_type = 'XFER' -- inventory transfer
                AND pnd.doc_id = xfer.transfer_id
                AND o.orgn_code = pnd.co_code
                AND sd.type = 'OID'
                AND sd.organization_id = o.organization_id
                AND trunc (pnd.trans_date) >= sd.transaction_date
                                                -- collect only from global
                                                -- start date
            UNION ALL   /* total internal shipments */
            -- Total internal order intransit activity is given by the sum
            -- of all the completed shipment and receipt transactions i.e.
            -- transaction of type 'OMSO' or 'PORC'.
            -- To get the from and to organizations depending on what the FOB
            -- is, we need to join back to the purchase order requisition lines
            -- table, po_requisitions_lines_all.
            -- For shipments (doc_type = OMSO) this is achieved through the
            -- oe_order_lines_all table.
            -- For receipts (doc_type = PORC) this is achieved through the
            -- rcv_transactions table.
            SELECT whse_mst.whse_code whse,
                   ic_item.item_id item,
                   (-1 * ic_tran.trans_qty) qty
              FROM (SELECT doc_type, doc_id, line_id, co_code, whse_code, item_id,
                           sum(trans_qty) trans_qty, trans_um, gl_posted_ind,
                           trans_date, completed_ind
                      FROM ic_tran_pnd
                      WHERE doc_type = 'OMSO'
                      AND completed_ind = 1
                      GROUP BY doc_type, doc_id, line_id, co_code, whse_code, item_id,
                               trans_um, gl_posted_ind, trans_date,
                               completed_ind
                    UNION ALL
                    -- receipts into different lots can generate two lines
                    -- in ic_tran with same line_id so collapse based on
                    -- line_id
                    SELECT doc_type, doc_id, line_id, co_code, whse_code, item_id,
                           sum (trans_qty) trans_qty, trans_um, gl_posted_ind,
                           trans_date,
                           1 -- all transactions are completed in tran_cmp
                      FROM ic_tran_cmp
                      WHERE doc_type = 'OMSO'
                      GROUP BY doc_type, doc_id, line_id, co_code, whse_code, item_id,
                               trans_um, gl_posted_ind, trans_date, 1
                   ) ic_tran,
                   oe_order_lines_all oola,
                   po_requisition_lines_all req,
                   ic_whse_mst whse_mst,
                   mtl_system_items_b msi,
                   ic_item_mst_b ic_item,
                   mtl_interorg_parameters mip,
                   sy_orgn_mst o,
                   opi_dbi_inv_value_log sd
              WHERE ic_tran.completed_ind = 1 -- but complete
                AND ic_tran.doc_type = 'OMSO' -- internal sales order shipment
                AND ic_tran.line_id = oola.line_id -- get line id details
                AND oola.source_document_type_id = 10 --ensure this is internal
                                                      --order
                AND req.requisition_line_id = oola.source_document_line_id
                AND mip.from_organization_id = req.source_organization_id
                AND mip.to_organization_id = req.destination_organization_id
                AND whse_mst.mtl_organization_id  =
                        decode (mip.fob_point,   --FOB selects owning org
                                2, req.source_organization_id,
                                1, req.destination_organization_id)
                                    -- for warehouse
                AND msi.organization_id = whse_mst.mtl_organization_id
                AND msi.inventory_item_id = req.item_id -- for OPM item id
                AND ic_item.item_no = msi.segment1
                AND o.orgn_code = ic_tran.co_code
                AND sd.type = 'OID'
                AND sd.organization_id = o.organization_id
                AND trunc (ic_tran.trans_date) >= sd.transaction_date
                                                -- collect only from global
                                                -- start date
            UNION ALL    /* total internal receipts */
            SELECT whse_mst.whse_code whse,
                   ic_item.item_id item,
                   (-1 * ic_tran.trans_qty) qty
              FROM (SELECT doc_type, doc_id, line_id, co_code, whse_code, item_id,
                           sum(trans_qty) trans_qty, trans_um, gl_posted_ind,
                           trans_date, completed_ind
                      FROM ic_tran_pnd
                      WHERE doc_type = 'PORC'
                      AND completed_ind = 1
                      GROUP BY doc_type, doc_id, line_id, co_code, whse_code, item_id,
                               trans_um, gl_posted_ind, trans_date,
                               completed_ind
                    UNION ALL
                    -- receipts into different lots can generate two lines
                    -- in ic_tran with same line_id so collapse based on
                    -- line_id
                    SELECT doc_type, doc_id, line_id, co_code, whse_code, item_id,
                           sum (trans_qty) trans_qty, trans_um, gl_posted_ind,
                           trans_date,
                           1 -- all transactions are completed in tran_cmp
                      FROM ic_tran_cmp
                      WHERE doc_type = 'PORC'
                      GROUP BY doc_type, doc_id, line_id, co_code, whse_code, item_id,
                               trans_um, gl_posted_ind, trans_date, 1
                   ) ic_tran,
                   rcv_transactions rcv,
                   po_requisition_lines_all req,
                   ic_whse_mst whse_mst,
                   mtl_system_items_b msi,
                   ic_item_mst_b ic_item,
                   mtl_interorg_parameters mip,
                   sy_orgn_mst o,
                   opi_dbi_inv_value_log sd
              WHERE ic_tran.completed_ind = 1 -- but complete
                AND ic_tran.doc_type = 'PORC' -- internal sales order shipment
                AND rcv.transaction_id = ic_tran.line_id
                AND req.requisition_line_id = rcv.requisition_line_id
                AND req.destination_type_code = 'INVENTORY' -- internal order
                AND req.source_type_code = 'INVENTORY'  -- has source and
                                                        -- dest type as
                                                        -- INVENTORY
                AND mip.from_organization_id = req.source_organization_id
                AND mip.to_organization_id = req.destination_organization_id
                AND whse_mst.mtl_organization_id  =
                        decode (mip.fob_point,   --FOB selects owning org
                                2, req.source_organization_id,
                                1, req.destination_organization_id)
                AND msi.organization_id = whse_mst.mtl_organization_id
                AND msi.inventory_item_id = req.item_id -- for OPM item id
                AND ic_item.item_no = msi.segment1
                AND o.orgn_code = ic_tran.co_code
                AND sd.type = 'OID'
                AND sd.organization_id = o.organization_id
                AND trunc (ic_tran.trans_date) >= sd.transaction_date
                                                -- collect only from global
                                                -- start date
          ) tot_intransit
        ) inception_intransit
        GROUP BY whse, item;

    bis_collection_utilities.put_line(TO_CHAR(sql%rowcount) || ' Intransit Inception Quantity rows extracted.');

EXCEPTION

    WHEN OTHERS
    THEN
        bis_collection_utilities.put_line (proc_name || sqlerrm);

END Get_OPM_Intransit_Balance;



PROCEDURE Get_OPM_WIP_Balance(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
BEGIN

    INSERT  INTO opi_dbi_opm_inv_stg
    (
        ORGANIZATION_ID,
        INVENTORY_ITEM_ID,
        TRANSACTION_DATE,
        WIP_VALUE_B
    )
    SELECT
        msi.organization_id,
        msi.inventory_item_id,
        log.transaction_date,
        ib.wip_value_b
    FROM
        (
        SELECT
            led.whse_code,
            gmd.item_id,
            nvl(sum(led.amount_base * gmd.cost_alloc),0) wip_value_b
        FROM
            (
                select
                    l.doc_id, h.wip_whse_code whse_code,
                    sum(l.amount_base * l.debit_credit_sign) amount_base
                from
                    gl_subr_led l,
                    gme_batch_header h
                where
                    l.doc_type = 'PROD'
                and l.acct_ttl_type = 1530
                and l.doc_id = h.batch_id
                and h.gl_posted_ind = 0
                group by
                    l.doc_id, h.wip_whse_code
                UNION ALL
                select
                    l.doc_id, h.wip_whse_code whse_code,
                    -1 * sum(amount_base * debit_credit_sign) amount_base
                from
                    gl_subr_led l,
                    gme_batch_header h,
                    ic_whse_mst w,
                    sy_orgn_mst o,
                    opi_dbi_inv_value_log log
                where
                    l.doc_type = 'PROD'
                and l.acct_ttl_type = 1530
                and l.doc_id = h.batch_id
                and h.wip_whse_code = w.whse_code
                and o.orgn_code = l.co_code
                and log.organization_id = o.organization_id
                and log.type = 'OID'
                and l.gl_trans_date >= log.transaction_date
                group by
                    l.doc_id, h.wip_whse_code
            ) led,
            gme_material_details gmd
        WHERE
            led.doc_id = gmd.batch_id
        AND gmd.line_type = 1
        GROUP BY
            led.whse_code,
            gmd.item_id
        HAVING
            nvl(sum(led.amount_base * gmd.cost_alloc),0) <> 0
        ) ib,
        ic_whse_mst w,
        sy_orgn_mst o,
        sy_orgn_mst c,
        ic_item_mst_b i,
        mtl_system_items_b msi,
        opi_dbi_inv_value_log log
    WHERE
        w.whse_code = ib.whse_code
    AND i.item_id = ib.item_id
    AND msi.segment1 = i.item_no
    AND msi.organization_id = w.mtl_organization_id
    AND o.orgn_code = w.orgn_code
    AND c.orgn_code = o.co_code
    AND log.organization_id = c.organization_id
    AND log.type= 'OID';

    bis_collection_utilities.put_line(TO_CHAR(sql%rowcount) || ' WIP Inception Balances calculated.');

    COMMIT;

EXCEPTION
    WHEN OTHERS
    THEN
        bis_collection_utilities.put_line ('Get_OPM_WIP_Balance: '|| sqlerrm);
        RAISE;

END Get_OPM_WIP_Balance;


PROCEDURE initialize_high_water_mark
IS
BEGIN
    INSERT INTO opi_dbi_inv_value_log
    (
        organization_id,
        transaction_id,
        transaction_date,
        type,
        source,
        creation_date,
        last_update_date,
        created_by,
        last_updated_by,
        last_update_login
    )
    VALUES
    (
        0,
        0,
        g_global_start_date,
        'GSL',
        2,
        SYSDATE,
        SYSDATE,
        g_user_id,
        g_user_id,
        g_login_id
    );

    bis_collection_utilities.put_line(TO_CHAR(sql%rowcount) || ' high water mark log rows inserted.');

    fnd_stats.gather_table_stats(
        ownname => g_opi_schema,
        tabname => 'OPI_DBI_INV_VALUE_LOG',
        percent => 10);

    COMMIT;

EXCEPTION
    WHEN OTHERS
    THEN
        bis_collection_utilities.put_line ('Initialize_High_Water_Mark: '|| sqlerrm);
        RAISE;

END Initialize_High_Water_Mark;


PROCEDURE Get_OPM_Inception_Inv_Balance(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
BEGIN
    Clean_OPM_Tables;

    Get_OPM_Inception_Date(g_inception_date);

    Get_OPM_Onhand_Balance(errbuf, retcode);

    Get_OPM_Intransit_Balance(errbuf, retcode);

    fnd_stats.gather_table_stats(
            ownname => g_opi_schema,
            tabname => 'OPI_DBI_OPM_INCEPTION_QTY',
            percent => 10);

    Cost_Inception_Quantities;

    Create_Inception_Balances;

    fnd_stats.gather_table_stats(
            ownname => g_opi_schema,
            tabname => 'OPI_DBI_OPM_INV_STG',
            percent => 10);

    Get_OPM_WIP_Balance(errbuf, retcode);

    Initialize_High_Water_Mark;

EXCEPTION
    WHEN OTHERS THEN

        bis_collection_utilities.put_line('Error encounted in OPI_DBI_INV_VALUE_OPM_INIT_PKG.Get_OPM_Inception_Inv_Balance');
        bis_collection_utilities.put_line('Error Message: ' || SQLERRM);

        RAISE_APPLICATION_ERROR(-20000, errbuf);
        /*please note that this api will commit!!*/

END Get_OPM_Inception_Inv_Balance;


PROCEDURE Run_OPM_First_ETL(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
    l_stmt_num NUMBER;
    l_err_num  NUMBER;
    l_err_msg  VARCHAR2(255);
    l_list     dbms_sql.varchar2_table;
BEGIN
    l_stmt_num := 0;
    retcode    := 0;
    l_list(1) := 'BIS_PRIMARY_CURRENCY_CODE';
    l_list(2) := 'BIS_GLOBAL_START_DATE';

    IF (bis_common_parameters.check_global_parameters(l_list))
    THEN
        l_stmt_num := 10;
        bis_collection_utilities.put_line('< Starting Inception Balance Extraction >');
        --Get_OPM_Inception_Inv_Balance(errbuf, retcode);
        bis_collection_utilities.put_line('</ Finished Inception Balance Extraction >');

        l_stmt_num := 20;
        bis_collection_utilities.put_line('<  Starting Daily Activity Extraction >');
        opi_dbi_inv_value_opm_incr_pkg.Extract_OPM_Daily_Activity(errbuf, retcode, g_inception_date);
        bis_collection_utilities.put_line('</ Finished Daily Activity Extraction ');
    ELSE
        retcode := 1;
        bis_collection_utilities.put_line('Global Parameters are not setup.');
        bis_collection_utilities.put_line('Please check that the profile options: ' ||
            'BIS_PRIMARY_CURRENCY_CODE and BIS_GLOBAL_START_DATE are setup.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        retcode := 1;
        l_err_num := SQLCODE;
        l_err_msg := 'OPI_DBI_INV_VALUE_OPM_INIT_PKG.Run_OPM_First_ETL ('
                    || to_char(l_stmt_num)
                    || '): '
                    || substr(SQLERRM, 1,200);

        bis_collection_utilities.put_line('OPI_DBI_INV_VALUE_OPM_INIT_PKG.Run_OPM_First_ETL '
                    || '- Error at statement ('
                    || to_char(l_stmt_num)
                    || ')');

        bis_collection_utilities.put_line('Error Number: ' ||  to_char(l_err_num));
        bis_collection_utilities.put_line('Error Message: ' || l_err_msg);

END Run_OPM_First_ETL;


BEGIN
    g_opi_appinfo := fnd_installation.get_app_info
                      (
                       application_short_name => 'OPI',
                       status => g_opi_status,
                       industry => g_opi_industry,
                       oracle_schema => g_opi_schema
                       );

End OPI_DBI_INV_VALUE_OPM_INIT_PKG ;

/
