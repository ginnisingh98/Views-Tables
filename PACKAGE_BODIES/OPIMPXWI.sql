--------------------------------------------------------
--  DDL for Package Body OPIMPXWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPIMPXWI" AS
/*$Header: OPIMXWIB.pls 120.4 2006/07/27 21:47:18 julzhang noship $ */


/* Profile for calculating all the inventory measures like wip issue,
   po deliveries.
   We only want to calculate measures when the
   EDW_ENABLE_INV_ACTIVITY_MEASURES profile is set to Y. Otherwise do
   not calculate the measures that literally double the run time of the
   basic balance calculation.
*/
g_measures_profile VARCHAR2 (50) := 'EDW_ENABLE_INV_ACTIVITY_MEASURES';

-- ---------------------------------
-- PRIVATE PROCEDURES
-- ---------------------------------

/*
    get_cost_from_cic

    Description: return the cost for an item/org from the cst_item_costs (cic)
                 table.

    Parameters IN: p_org_id - organization id
                   p_item_id - inventory_item_id

    Return values: l_item_cost (NUMBER) - item cost in CIC

    Error Handling:
*/

FUNCTION get_cost_from_cic (p_org_id IN NUMBER, p_item_id IN NUMBER)
    RETURN NUMBER
IS

    -- procedure name
    proc_name VARCHAR2(20) := 'get_cost_from_cic';

    -- item cost from cic
    l_item_cost NUMBER;     -- no default needed since CIC must have some cost

    -- Cursor to get the item cost from the CIC (cst_item_costs). If there
    -- are no cost updates ever on the item, then the CIC stores the most
    -- historical cost.
    CURSOR cic_item_cost_cur (p_org_id NUMBER, p_item_id NUMBER)
    IS
        SELECT cic.item_cost item_cost
          FROM cst_item_costs cic
          WHERE cic.organization_id = p_org_id
            AND cic.inventory_item_id = p_item_id
        and cost_type_id=1;

BEGIN

    -- Fetch the cost from the CIC - should always get some cost
    OPEN cic_item_cost_cur (p_org_id, p_item_id);
    FETCH cic_item_cost_cur INTO l_item_cost;
    CLOSE cic_item_cost_cur;

    return nvl(l_item_cost,0);

EXCEPTION
    WHEN OTHERS
    THEN
        NULL;
--      DBMS_OUTPUT.PUT_LINE (proc_name || ':' || sqlerrm);
END get_cost_from_cic;


/*
    std_costing_org_item_cost

    Description: Gets the cost for an inventory item in a standard costing org
                 for a given date.

                 The mcacd (mtl_cst_actual_cost_details) does not store the
                 the new cost in the actual_cost column of a transaction ID
                 corresponding to a standard cost update (SCU). When we look
                 up the item cost for an item with a SCU which:
                 1. Was made prior to the start date of the collection program
                 2. Was the last transaction on the item before the start
                    date of the collection program,
                 we get the wrong cost from the actual_cost column of mcacd
                 as the starting cost for the collection program.

                 To correct this, we need to do the following:
                 1. Get the historical item cost from the csc (cst_standard_costs)
                    table. This table has the historical costs after an SCU is
                    made. We just need the latest cost prior to the start date.
                    If there is more than one SCU on the same day, use the latest
                    cost on that day.
                 2. If csc is has no data prior to the start date, but has data
                    after the start date,
                    ----Then use the cost in the mmt (mtl_material_transactions)
                        because the cic (cst_item_costs) no longer has the
                        historical cost.
                    ----Else use the cost in the CIC

    Parameters IN:  p_org_id - standard costing organization_id
                    p_item_id - inventory item id
                    p_date - date for which we need cost

    Return values: item_cost (NUMBER) - item cost

    Error Handling:

    Date                Author              Action
    25th Sept, 2002     Dinkar Gupta        Wrote function

*/
FUNCTION std_costing_org_item_cost (p_org_id IN NUMBER, p_item_id IN NUMBER,
                                    p_date IN DATE)
    RETURN NUMBER
IS

    -- procedure name
    proc_name VARCHAR2(30) := 'std_costing_org_item_cost';

    -- Cursor to get the historical cost from the cst_standard_costs (csc)
    -- table. Need the latest cost in the csc prior to the given date
    CURSOR latest_csc_cost_to_date_cur (p_org_id NUMBER, p_item_id NUMBER,
                                        p_cost_date DATE)
    IS
        SELECT csc.standard_cost unit_cost
          FROM cst_standard_costs csc
          WHERE csc.organization_id = p_org_id
            AND csc.inventory_item_id = p_item_id
            AND csc.standard_cost_revision_date =
                (SELECT max(csc2.standard_cost_revision_date)
                   FROM cst_standard_costs csc2
                   WHERE csc2.organization_id = p_org_id
                     AND csc2.inventory_item_id = p_item_id
                     AND csc2.standard_cost_revision_date <
                            trunc(p_cost_date) + 1);

    -- Cursor to get all the entries in the cst_standard_cost table for a
    -- given item/org. If the cost on date cursor returns nothing, then
    -- we need to know whether there have been cost updates after the
    -- the date in question.
    -- Since we have already checked for cost updates prior to the given
    -- date in the latest_csc_cost_to_date_cur, we only need to check if
    -- there were ever any cost updates on the item/org.

    CURSOR all_csc_costs_post_date_cur (p_org_id NUMBER, p_item_id NUMBER,
                                        p_cost_date DATE)
    IS
        SELECT csc.standard_cost unit_cost
          FROM cst_standard_costs csc
          WHERE csc.organization_id = p_org_id
            AND csc.inventory_item_id = p_item_id;

    -- Cursor to get the historical item cost from the
    -- mtl_material_transactions (mmt). If there are no cost updates prior
    -- to the date, but one after the given date, then the historical cost
    -- cannot be obtained from the csc or the cic. We need to go back to the
    -- mmt.
    -- digupta 07/10/02 -- filtered out certain transactions that do not
    -- affect inventory quantity or balance.
    CURSOR mmt_historical_cost_cur (p_org_id NUMBER, p_item_id NUMBER,
                                    p_cost_date DATE)
    IS
        SELECT actual_cost
          FROM mtl_material_transactions
          WHERE transaction_id =
                    (SELECT max(transaction_id)
                       FROM mtl_material_transactions
                       WHERE inventory_item_id = p_item_id
                         AND organization_id = p_org_id
                         AND actual_cost IS NOT NULL
                         AND transaction_type_id NOT IN
                            (73, 80, 25, 26, 28, 90, 91, 92,
                             55, 56, 57, 58, 87, 88, 89, 24)
             AND organization_id =  NVL(owning_organization_id, organization_id)
             AND NVL(OWNING_TP_TYPE,2) = 2
                         AND transaction_date =
                                (SELECT max(transaction_date)
                                   FROM mtl_material_transactions
                                   WHERE inventory_item_id = p_item_id
                                     AND organization_id = p_org_id
                                     AND (transaction_date) <
                                            trunc(p_cost_date) + 1
                                     AND actual_cost IS NOT NULL
                                     AND transaction_type_id NOT IN
                                            (73, 80, 25, 26, 28, 90, 91, 92,
                                             55, 56, 57, 58, 87, 88, 89, 24)));

    -- cost to return -- default to 0, though we are doing everything here
    -- to find the real cost, so a return value of 0 should be treated
    -- suspiciously.
    l_item_cost NUMBER := 0;

    l_cost_exists_csc NUMBER;

BEGIN

    OPEN latest_csc_cost_to_date_cur (p_org_id, p_item_id, p_date);

    --get the latest cost
    FETCH latest_csc_cost_to_date_cur INTO l_item_cost;

    IF (latest_csc_cost_to_date_cur%NOTFOUND)
    THEN

        -- if no latest cost was found, then check to see if there were
        -- any cost updates at all for this item.
        OPEN all_csc_costs_post_date_cur (p_org_id, p_item_id, p_date);
        FETCH all_csc_costs_post_date_cur INTO l_cost_exists_csc;

        -- If there are cost updates after the given date, then
        -- we must use the cost from the mmt
        IF (all_csc_costs_post_date_cur%FOUND)
        THEN

            -- get the cost from the mmt
            OPEN mmt_historical_cost_cur (p_org_id, p_item_id, p_date);
            FETCH mmt_historical_cost_cur INTO l_item_cost;

            IF (mmt_historical_cost_cur%NOTFOUND)
            THEN

                l_item_cost := 0;

            END IF; -- IF (mmt_historical_cost_cur%NOTFOUND)

            CLOSE mmt_historical_cost_cur;

        ELSE -- can simply get the cost from CIC since there have never
             -- been cost updates on this item/org

            l_item_cost := get_cost_from_cic (p_org_id, p_item_id);

        END IF;  -- IF (all_csc_costs_post_date_cur%FOUND)

        CLOSE all_csc_costs_post_date_cur;


    END IF;  -- IF (latest_csc_cost_to_date_cur%NOTFOUND)

    CLOSE latest_csc_cost_to_date_cur;

    return nvl(l_item_cost,0);


EXCEPTION

    WHEN OTHERS
    THEN
        NULL;
--        DBMS_OUTPUT.PUT_LINE (proc_name || ':' || sqlerrm);

END std_costing_org_item_cost;


/*
 avg_costing_org_item_cost

 Description: Return the item cost for an item in an average costing org.
              Average costing orgs store the cost in the
              mtl_cst_actual_cost_details tables. If there is no cost there,
              then return the cost to be 0.

 Arguments: p_organization_id - organization id
            p_item_id - inventory_item_id
            p_cost_date - date for which we want cost.
            p_cost_group_id - cost group of item passed in

 Return values: item_cost - cost of item on the given day.

 Error Handling:

 Date               Author          Action
 11/27/02           Dinkar Gupta    Wrote function
*/
FUNCTION avg_costing_org_item_cost (p_organization_id IN NUMBER,
                                    p_item_id IN NUMBER, p_cost_date IN DATE,
                                    p_cost_group_id IN NUMBER)
    RETURN NUMBER
IS
    proc_name VARCHAR2 (30) := 'avg_costing_org_item_cost';
    l_item_cost NUMBER := 0;
    l_trx_id NUMBER := NULL;

BEGIN

    -- digupta 07/10/02 -- filtered out certain transactions that do not
    -- affect inventory quantity or balance.
    -- ltong 01/20/2003. Filtered out consigned inventory.
    SELECT max (macd.transaction_id)
      INTO l_trx_id
      FROM mtl_cst_actual_cost_details macd,
           mtl_material_transactions mmt
      WHERE mmt.transaction_id = macd.transaction_id
        AND mmt.organization_id = p_organization_id
        AND mmt.inventory_item_id = p_item_id
        AND nvl (mmt.cost_group_id, -999) = nvl (p_cost_group_id, -999)
        AND mmt.transaction_type_id NOT IN
                (73, 80, 25, 26, 28, 90, 91, 92,
                 55, 56, 57, 58, 87, 88, 89, 24)
        AND MMT.organization_id =  NVL(MMT.owning_organization_id,MMT.organization_id)
        AND NVL(MMT.OWNING_TP_TYPE,2) = 2
        AND mmt.transaction_date = (
            SELECT transaction_date
              FROM
                (SELECT /*+ first_rows */ mt.transaction_date
                  FROM mtl_cst_actual_cost_details mcacd,
                       mtl_material_transactions mt
                  WHERE mt.transaction_id = mcacd.transaction_id
                    AND mt.transaction_date < p_cost_date + 1
                    AND mt.organization_id = p_organization_id
                    AND mt.inventory_item_id = p_item_id
                    AND mt.transaction_type_id NOT IN
                                (73, 80, 25, 26, 28, 90, 91, 92, 55, 56,
                                 57, 58, 87, 88, 89, 24)
                    AND nvl (mt.cost_group_id,-999) = nvl (p_cost_group_id,
                                                           -999)
                  ORDER BY mt.transaction_date DESC)
              WHERE rownum = 1);

    IF(l_trx_id IS NULL) THEN    -- {
        l_item_cost:=0;
    ELSE
        SELECT SUM(macd.new_cost)
          INTO l_item_cost
          FROM mtl_cst_actual_cost_details macd
          WHERE macd.transaction_id = l_trx_id
            AND macd.organization_id = p_organization_id; /* Bug 3661478 - add filter on organization_id*/

    END IF;  --} l_trx_id is null

    RETURN l_item_cost;

EXCEPTION
    WHEN NO_DATA_FOUND -- could not get a trx_id in mcacd
    THEN
        l_item_cost := 0;

    WHEN OTHERS
    THEN
        NULL;
        EDW_LOG.PUT_LINE (proc_name || ':' || sqlerrm);
--        DBMS_OUTPUT.PUT_LINE (proc_name || ':' || sqlerrm);

END avg_costing_org_item_cost;

-- ---------------------------------
-- PUBLIC PROCEDURES
-- ---------------------------------

-----------------------------------------------------------
--  PROCEDURE PUSH
-----------------------------------------------------------
PROCEDURE  opi_extract_ids(p_from_date IN   DATE,
                           p_to_date   IN   DATE,
                           p_org_code  IN   VARCHAR2) IS

    inv_from_date DATE;
    wip_from_date DATE;
    inv_trx_id    NUMBER;
    wip_trx_id    NUMBER;
    inv_trx_date  DATE;
    wip_trx_date  DATE;
    to_date       DATE;
    org_id        NUMBER;
    l_statement   NUMBER;
    l_errnum      NUMBER;
    l_retcode     VARCHAR2(100);
    l_errbuf      VARCHAR2(200);
    status        NUMBER;
    l_first_push  NUMBER;
    l_txn_flag    NUMBER;
    select_cursor NUMBER:=0;
    l_from_date   DATE;
    l_to_date     DATE;
    l_edw_start_date_org DATE := null;
    no_from_date  EXCEPTION;
    l_exit    NUMBER;
    l_print_date DATE;

    -- Cursor to fetch organizations that have MMT or WT transactions
    -- between the from and to date.

    cursor c_inv_org is
        select mp.organization_id
          from mtl_parameters mp
          where
               mp.process_enabled_flag <> 'Y' AND
           exists
                (select 'there are transactions'
                  from mtl_material_transactions mmt
                  where mmt.organization_id = mp.organization_id
                    and mmt.transaction_date between l_from_date and l_to_date)
            or exists
                (select 'there are transactions'
                  from wip_transactions wt
                  where wt.organization_id = mp.organization_id
                    and wt.transaction_date between l_from_date and l_to_date);



    -- Cursor to fetch organizations that have MMT or WT transactions
    -- between the from date and latest trx date in MMT and WT and the
    -- orgs in MOQ.

    cursor c_inv_org_first_push is
        select mp.organization_id from
        mtl_parameters mp,
        (select distinct organization_id
          from mtl_material_transactions
          where transaction_date >= l_from_date
        UNION
        select distinct organization_id
          from wip_transactions
          where transaction_date >= l_from_date
        UNION
        select distinct organization_id
          from mtl_onhand_quantities) mtl
        where mp.organization_id = mtl.organization_id and
              mp.process_enabled_flag <> 'Y';

    --testing purpose rjin
/*
    CURSOR c_inv_org IS
     SELECT mp.organization_id
       from mtl_parameters mp
       WHERE organization_id IN (606);

    CURSOR c_inv_org_first_push IS
      SELECT mp.organization_id
        from mtl_parameters mp
        WHERE organization_id IN (606);
*/
    -- Cursor to get the transaction dates from the latest push of each org.
    -- When a fetch is performed, the oldest of those dates will be selected
    -- to be used as default from date if none passed by the calling program.

    CURSOR c_txn_date is
        SELECT max(last_push_inv_txn_date) l_date
          FROM opi_ids_push_date_log
          GROUP BY organization_id
        UNION
        SELECT max(last_push_wip_txn_date) l_date
          FROM opi_ids_push_date_log
          GROUP BY organization_id
          ORDER BY 1;

   -- cursor to get all the periods spanned by this push
   CURSOR l_extraction_periods_csr ( p_organization_id NUMBER,
                                     p_from_date DATE, p_to_date DATE) IS
     SELECT  Trunc(period_start_date) start_date,
       Trunc(schedule_close_date) end_date
       FROM org_acct_periods
       WHERE organization_id = p_organization_id
       AND (( period_start_date between p_from_date
        and p_to_date )
        OR( schedule_close_date between p_from_date
        and p_to_date )
            OR
              ( (p_from_date between period_start_date and schedule_close_date)
                AND (p_to_date between period_start_date and schedule_close_date) )
        )
       ORDER BY start_date;

    l_extraction_periods_rec l_extraction_periods_csr%ROWTYPE;

BEGIN

   g_org_error := false;

/*--------------------------------------------------------
-- Looping thru cursor to process extraction for each org.
   The following steps are done for each org:
   . get process dates
   . purge previous push log data for closed periods
   . calculate inventory balances
   . calculate wip balances
   . write to opi_ids_push_date_log
   Process for each org is a commit cycle.  If an error occurs
   only data for that currently processed org is rolled back.
---------------------------------------------------------*/

    -- Make sure from and to date are not null

    EDW_LOG.PUT_LINE('At start EXTRACT IDS LOG');
    select sysdate into l_print_date from dual;
    EDW_LOG.PUT_LINE('Start time: ' ||
                      to_char (sysdate, 'DD-MON-YY HH24:MI:SS'));

    if p_from_date is null then     -- check from date
        l_statement := 10;

        open c_txn_date;
        fetch c_txn_date into l_from_date;

        if c_txn_date%NOTFOUND then    -- check row existence
            close c_txn_date;
            l_errnum := 0;
            l_retcode := 'No start date for process';
            l_errbuf := 'This is the first extract process, '
                     || 'you must enter a start date';
            raise no_from_date;
        end if;              -- end check row existence
        close c_txn_date;
    else
        l_from_date := p_from_date;
    end if;                        -- end check from date

    if p_to_date is null then
        l_to_date := sysdate;
    else
        l_to_date := p_to_date;
    end if;


    EDW_LOG.PUT_LINE('l_from_date'||to_char(l_from_date,'DD-MON-YYYY hh24:mi:ss'));
    EDW_LOG.PUT_LINE('l_to_date'||to_char(l_to_date,'DD-MON-YYYY hh24:mi:ss'));

    select sum(1)
      into select_cursor
      from opi_ids_push_date_log
      where rownum < 2;

    if (p_org_code IS NOT NULL) then
        BEGIN
            select mp.organization_id into org_id
              from mtl_parameters mp
              where organization_code = p_org_code
              and mp.process_enabled_flag <> 'Y';
            l_exit := 0;
        EXCEPTION
            when NO_DATA_FOUND then
                EDW_LOG.PUT_LINE('Invalid organization code, please verify.');
                l_errnum := 0;
                l_retcode := 'Invalid organization code.';
                l_errbuf := 'Please provide a valid inventory organization code.';
                return;
        END;
        EDW_LOG.PUT_LINE('Processing single org');
    else
        if (select_cursor > 1) then
            OPEN c_inv_org;
            EDW_LOG.PUT_LINE('Processing cursor c_inv_org');
        else
            OPEN c_inv_org_first_push;
            EDW_LOG.PUT_LINE('Processing cursor c_inv_org_first_push');
        end if;
    end if;

    /*-------------------------
    Start cursor loop
    -------------------------*/
    l_statement := 20;


    LOOP

        if (p_org_code IS NOT NULL) then
            if (l_exit = 1) then
                exit;
            end if;
            l_exit := 1;
        else
            if (select_cursor > 1) then
                FETCH c_inv_org into org_id;
                if (c_inv_org%NOTFOUND) then
                    CLOSE c_inv_org;
                    exit;
                end if;
            else
                FETCH c_inv_org_first_push into org_id;
                if (c_inv_org_first_push%NOTFOUND) then
                CLOSE c_inv_org_first_push;
                exit;
                end if;
            end if;
        end if;


        EDW_LOG.PUT_LINE('*********************************************');

        EDW_LOG.PUT_LINE('Start extraction process for organization: '
                         || to_char(org_id));

        SAVEPOINT sav_org;


        -- Get the EDW inception date for this org. We don't want to delete
        -- the inception rows unless this is a first push
        -- Get the EDW start date for this org, to check later whether we have
        -- backposted transactions on the inception date. If so, we do not want
        -- lose the beginning onhand quantities.
        BEGIN
            SELECT trunc (min (trx_date))    -- must drop time stamp timestamp.
              INTO l_edw_start_date_org
              FROM opi_ids_push_log
              WHERE organization_id = org_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;  -- l_edw_start_date_org would be NULL if no date found
                -- l_edw_start_date_org := NULL;  -- was the first push, so
                                               -- the ids_push_log is empty

        END;


        -- -----------------------------------------------------------------
        --  Get dates and last transaction id's to be processed for INV
        -- and WIP -- remove . for bug 3556719
        -- -----------------------------------------------------------------

        l_statement := 30;

        EDW_LOG.PUT_LINE('Calling OPIMPDAT.get_push_dates ...');
        select sysdate into l_print_date from dual;
        EDW_LOG.PUT_LINE('Start time: ' ||
                         to_char (sysdate, 'DD-MON-YY HH24:MI:SS'));

        OPIMPDAT.get_push_dates(
                org_id,
                trunc (p_from_date),
                trunc (p_to_date),
                trunc (l_from_date),
                inv_from_date,
                wip_from_date,
                inv_trx_id,
                wip_trx_id,
                inv_trx_date,
                wip_trx_date,
                to_date,
                l_first_push,
                l_errnum,
                l_retcode,
                l_errbuf,
                l_txn_flag);
        select sysdate into l_print_date from dual;
        EDW_LOG.PUT_LINE('End time: ' ||
                         to_char (sysdate, 'DD-MON-YY HH24:MI:SS'));

        if l_errnum <> 0 THEN
            IF l_errnum <> 9999 THEN
                process_error(l_statement,
                              l_errnum,
                              l_retcode,
                              l_errbuf);
            ELSE
                process_warning(l_statement,
                                l_errnum,
                                l_retcode,
                                l_errbuf);
            END IF;

            goto next_org;

        end if;

        EDW_LOG.PUT_LINE('inv_from_date: ' || to_char(inv_from_date,'DD-MON-YYYY hh24:mi:ss'));
        EDW_LOG.PUT_LINE('wip_from_date: ' || to_char(wip_from_date,'DD-MON-YYYY hh24:mi:ss'));
        EDW_LOG.PUT_LINE('to_date: ' || to_char(to_date,'DD-MON-YYYY hh24:mi:ss'));


        /*-------------------------------------------------------------------
        Purge old data in opi_ids_push_log table.
        For a specified org, all rows with transaction date in a closed period
        will be purged, EXCEPT rows with txn dates falling into a period
        start date or a period end date.  In addition, data in a closed period
        which include the lastest pushed transaction date will not be purged.
        --------------------------------------------------------------------*/
        l_statement := 40;
        EDW_LOG.PUT_LINE('Calling purge_opi_ids_push_log  ...');
        select sysdate into l_print_date from dual;
        EDW_LOG.PUT_LINE('Start time: ' ||
                         to_char (sysdate, 'DD-MON-YY HH24:MI:SS'));

        -- if we are running across periods, then we must not only recompute
        -- all the activity rows, but even the period start and end rows, so
        -- delete the old rows.
        -- SPECIAL CASE: Never delete the rows on the edw inception date.
        -- However, if this is the first push, the ids_push_log is empty, so
        -- don't bother to delete anything.
        IF ((l_first_push <= 0) AND (l_edw_start_date_org IS NOT NULL))
        THEN
            OPEN l_extraction_periods_csr (org_id, inv_from_date, to_date);
            FETCH l_extraction_periods_csr INTO l_extraction_periods_rec;
            FETCH l_extraction_periods_csr INTO l_extraction_periods_rec;
            IF l_extraction_periods_csr%FOUND THEN
                -- must have more than 1 period
                DELETE FROM opi_ids_push_log
                  WHERE trx_date BETWEEN inv_from_date AND to_date
                    AND trx_date <> l_edw_start_date_org
                    AND organization_id = org_id;
            END IF;
            CLOSE l_extraction_periods_csr;
        END IF;

        purge_opi_ids_push_log(org_id,
                               l_errnum,
                               l_retcode,
                               l_errbuf);

        select sysdate into l_print_date from dual;
        EDW_LOG.PUT_LINE('End time: ' ||
                         to_char (sysdate, 'DD-MON-YY HH24:MI:SS'));

        if l_errnum <> 0 then
            process_error(l_statement,
                          l_errnum,
                          l_retcode,
                          l_errbuf);
            goto next_org;
        end if;

        /*-------------------------------------------------------------------
        Calling Inventory procedures to populate the Inv Balance and Activities
        ---------------------------------------------------------------------*/

        if l_first_push > 0 then

            l_statement := 45;

            DECLARE
                CURSOR prd_start_date_csr IS
                  SELECT period_start_date
                    FROM org_acct_periods
                    WHERE organization_id = org_id
                      AND period_start_date <= p_from_date
                      AND schedule_close_date >= p_from_date;

                CURSOR prd_start_date_min_csr IS
                  SELECT MIN(period_start_date)
                    FROM org_acct_periods
                    WHERE organization_id = org_id
                      AND period_start_date BETWEEN p_from_date AND p_to_date;

            BEGIN
                OPEN prd_start_date_csr;
                FETCH prd_start_date_csr INTO inv_from_date;

                IF prd_start_date_csr%notfound THEN
                    CLOSE prd_start_date_csr;

                    OPEN prd_start_date_min_csr;
                    FETCH prd_start_date_min_csr INTO inv_from_date;

                    IF inv_from_date IS NULL THEN
                        CLOSE prd_start_date_min_csr;
                        EDW_LOG.PUT_LINE('No valid period during the date range specified for Org_id :' || org_id);
                        GOTO next_org;
                    ELSE
                        CLOSE prd_start_date_min_csr;
                    END IF;
                ELSE

                    CLOSE prd_start_date_csr;
                END IF;

                EDW_LOG.PUT_LINE(' first ever push, inv_from_date is '
                                || To_char(inv_from_date,'DD-MON-YYYY hh24:mi:ss') );

            END ;

            EDW_LOG.PUT_LINE('Calling calc_begin_inv  ...');
            select sysdate into l_print_date from dual;
            EDW_LOG.PUT_LINE('Start time: ' ||
                            to_char (sysdate, 'DD-MON-YY HH24:MI:SS'));

            calc_begin_inv(inv_from_date, org_id,status);
            select sysdate into l_print_date from dual;
            EDW_LOG.PUT_LINE('End time: ' ||
                             to_char (sysdate, 'DD-MON-YY HH24:MI:SS'));

            if status > 0 then
                l_errbuf := 'Error calling calc_begin_inv.  Org id: '
                            || to_char(org_id);

                process_error(l_statement,
                              l_errnum,
                              l_retcode,
                              l_errbuf);
                goto next_org;
            end if;

        end if;

        l_statement := 50;

        -- -------------------------------------------------------------------
        -- l_first_push = 2 means that there are no inv transaction for the Org
        -- in the date range specified. But we need to build the begin balance
        -- for them. So if l_first_push = 2  then only need to call the
        -- calc_begin_inv
        -- ------------------------------------------------------------------


        if (l_first_push = 2 or l_txn_flag = 2) then
            goto wip_calculation;
        end if;


        EDW_LOG.PUT_LINE('Calling calc_inv_balance ...');
        select sysdate into l_print_date from dual;
        EDW_LOG.PUT_LINE('Start time: ' ||
                        to_char (sysdate, 'DD-MON-YY HH24:MI:SS'));
        -- ------------------------------------------------------------------
        -- Calling calc_inv_balance to calculate the Inv daily balance
        -- for each organization
        --
        -- -----------------------------------------------------------------
        IF l_first_push > 0 THEN
            -- if this is the first push, then starting from inv_from_date+1
            --  since inv_from_date is handle in calc_beg_inv
            calc_inv_balance(inv_from_date+1,
                             to_date,org_id,
                             status);
        ELSE
            calc_inv_balance(inv_from_date,
                             to_date,org_id,
                             status);
        END IF;
        select sysdate into l_print_date from dual;
        EDW_LOG.PUT_LINE('End time: ' ||
                         to_char (sysdate, 'DD-MON-YY HH24:MI:SS'));

        if status > 0 then
            l_errbuf := 'Error calling calc_inv_balance.  Org id: '
                        || to_char(org_id);

            process_error(l_statement,
                          l_errnum,
                          l_retcode,
                          l_errbuf);
            goto next_org;
        end if;

        -- if the user wants to calculate all the measures of activity, he
        -- must have set the EDW_ENABLE_INV_ACTIVITY_MEASURES to Y. If so,
        -- calculate all the measures.
        -- For backward compatibility, if a customer has not implemented
        -- the profile, then these measures should get collected too.
        EDW_LOG.PUT_LINE ('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&');
        EDW_LOG.PUT_LINE ('PROFILE ' || g_measures_profile ||' = ' ||
                          NVL (FND_PROFILE.VALUE (g_measures_profile),
                          'NULL'));
        EDW_LOG.PUT_LINE ('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&');

        IF (NVL (FND_PROFILE.VALUE (g_measures_profile), 'Y') = 'Y') THEN

            -- --------------------------------------------------------------
            -- Calling procedures to calculate the Inv daily activities
            -- for each organization
            --
            -- --------------------------------------------------------------
            EDW_LOG.PUT_LINE ('Calling calc_wip_completion ....');
            select sysdate into l_print_date from dual;
            EDW_LOG.PUT_LINE('Start time: ' ||
                             to_char (sysdate, 'DD-MON-YY HH24:MI:SS'));
            OPIMPXIN.calc_wip_completion( l_errbuf,l_retcode,inv_from_date,to_date,org_id);
            select sysdate into l_print_date from dual;
            EDW_LOG.PUT_LINE('End time: ' ||
                             to_char (sysdate, 'DD-MON-YY HH24:MI:SS'));

            if l_retcode = '2' then
                l_errbuf := 'Error calling calc_wip_completion.  Org id: '
                            || to_char(org_id);

                process_error(l_statement,
                              l_errnum,
                              l_retcode,
                              l_errbuf);
                goto next_org;
            end if;



            EDW_LOG.PUT_LINE ('Calling calc_wip_issue ....');
            select sysdate into l_print_date from dual;
            EDW_LOG.PUT_LINE('Start time: ' ||
                             to_char (sysdate, 'DD-MON-YY HH24:MI:SS'));
            OPIMPXIN.calc_wip_issue(l_errbuf,l_retcode,inv_from_date,to_date,org_id);
            select sysdate into l_print_date from dual;
            EDW_LOG.PUT_LINE('End time: ' ||
                             to_char (sysdate, 'DD-MON-YY HH24:MI:SS'));

            if l_retcode = '2' then
                l_errbuf := 'Error calling calc_wip_issue.  Org id: '
                            || to_char(org_id);

                process_error(l_statement,
                              l_errnum,
                              l_retcode,
                              l_errbuf);
                goto next_org;
            end if;

            EDW_LOG.PUT_LINE ('Calling calc_assembly_return ....');
            select sysdate into l_print_date from dual;
            EDW_LOG.PUT_LINE('Start time: ' ||
                             to_char (sysdate, 'DD-MON-YY HH24:MI:SS'));
            OPIMPXIN.calc_assembly_return(l_errbuf,l_retcode,inv_from_date,to_date,org_id);
            select sysdate into l_print_date from dual;
            EDW_LOG.PUT_LINE('End time: ' ||
                             to_char (sysdate, 'DD-MON-YY HH24:MI:SS'));

            if l_retcode = '2' then
                l_errbuf := 'Error calling calc_assembly_return.  Org id: '
                            || to_char(org_id);

                process_error(l_statement,
                              l_errnum,
                              l_retcode,
                              l_errbuf);
                goto next_org;
            end if;

            EDW_LOG.PUT_LINE ('Calling calc_po_deliveries ....');
            select sysdate into l_print_date from dual;
            EDW_LOG.PUT_LINE('Start time: ' ||
                             to_char (sysdate, 'DD-MON-YY HH24:MI:SS'));
            OPIMPXIN.calc_po_deliveries(l_errbuf,l_retcode,inv_from_date,to_date,org_id);
            select sysdate into l_print_date from dual;
            EDW_LOG.PUT_LINE('End time: ' ||
                             to_char (sysdate, 'DD-MON-YY HH24:MI:SS'));

            if l_retcode = '2' then
                l_errbuf := 'Error calling calc_po_deliveries.  Org id: '
                            || to_char(org_id);

                process_error(l_statement,
                              l_errnum,
                              l_retcode,
                              l_errbuf);
                goto next_org;
            end if;

            EDW_LOG.PUT_LINE ('Calling calc_value_to_orgs ....');
            select sysdate into l_print_date from dual;
            EDW_LOG.PUT_LINE('Start time: ' ||
                             to_char (sysdate, 'DD-MON-YY HH24:MI:SS'));
            OPIMPXIN.calc_value_to_orgs(l_errbuf,l_retcode,inv_from_date,to_date,org_id);
            select sysdate into l_print_date from dual;
            EDW_LOG.PUT_LINE('End time: ' ||
                             to_char (sysdate, 'DD-MON-YY HH24:MI:SS'));

            if l_retcode = '2' then
                l_errbuf := 'Error calling calc_value_to_orgs.  Org id: '
                            || to_char(org_id);

                process_error(l_statement,
                              l_errnum,
                              l_retcode,
                              l_errbuf);
                goto next_org;
            end if;

            EDW_LOG.PUT_LINE ('Calling calc_value_from_orgs ....');
            select sysdate into l_print_date from dual;
            EDW_LOG.PUT_LINE('Start time: ' ||
                             to_char (sysdate, 'DD-MON-YY HH24:MI:SS'));
            OPIMPXIN.calc_value_from_orgs(l_errbuf,l_retcode,inv_from_date,to_date,org_id);
            select sysdate into l_print_date from dual;
            EDW_LOG.PUT_LINE('End time: ' ||
                             to_char (sysdate, 'DD-MON-YY HH24:MI:SS'));

            if l_retcode = '2' then
                l_errbuf := 'Error calling calc_value_from_orgs.  Org id: '
                                || to_char(org_id);

                process_error(l_statement,
                              l_errnum,
                              l_retcode,
                              l_errbuf);
                goto next_org;
            end if;

            EDW_LOG.PUT_LINE ('Calling calc_customer_shipment ....');
            select sysdate into l_print_date from dual;
            EDW_LOG.PUT_LINE('Start time: ' ||
                             to_char (sysdate, 'DD-MON-YY HH24:MI:SS'));
            OPIMPXIN.calc_customer_shipment(l_errbuf,l_retcode,inv_from_date,to_date,org_id);
            select sysdate into l_print_date from dual;
            EDW_LOG.PUT_LINE('End time: ' ||
                             to_char (sysdate, 'DD-MON-YY HH24:MI:SS'));

            if l_retcode = '2' then
                l_errbuf := 'Error calling calc_customer_shipment.  Org id: '
                            || to_char(org_id);

                process_error(l_statement,
                              l_errnum,
                              l_retcode,
                              l_errbuf);
                goto next_org;
            end if;

            EDW_LOG.PUT_LINE ('Calling calc_inv_adjustment ....');
            select sysdate into l_print_date from dual;
            EDW_LOG.PUT_LINE('Start time: ' ||
                             to_char (sysdate, 'DD-MON-YY HH24:MI:SS'));
            OPIMPXIN.calc_inv_adjustment(l_errbuf,l_retcode,inv_from_date,to_date,org_id);
            select sysdate into l_print_date from dual;
            EDW_LOG.PUT_LINE('End time: ' ||
                             to_char (sysdate, 'DD-MON-YY HH24:MI:SS'));

            if l_retcode = '2' then
                l_errbuf := 'Error calling calc_inv_adjustment.  Org id: '
                            || to_char(org_id);

                process_error(l_statement,
                              l_errnum,
                              l_retcode,
                              l_errbuf);
                goto next_org;
            end if;

            EDW_LOG.PUT_LINE ('Calling calc_total_issue ....');
            select sysdate into l_print_date from dual;
            EDW_LOG.PUT_LINE('Start time: ' ||
                             to_char (sysdate, 'DD-MON-YY HH24:MI:SS'));
            OPIMPXIN.calc_total_issue(l_errbuf,l_retcode,inv_from_date,to_date,org_id);
            select sysdate into l_print_date from dual;
            EDW_LOG.PUT_LINE('End time: ' ||
                             to_char (sysdate, 'DD-MON-YY HH24:MI:SS'));

            if l_retcode = '2' then
                l_errbuf := 'Error calling calc_total_issue.  Org id: '
                            || to_char(org_id);

                process_error(l_statement,
                              l_errnum,
                              l_retcode,
                              l_errbuf);
                goto next_org;
            end if;

            EDW_LOG.PUT_LINE ('Calling calc_total_receipt ....');
            select sysdate into l_print_date from dual;
            EDW_LOG.PUT_LINE('Start time: ' ||
                             to_char (sysdate, 'DD-MON-YY HH24:MI:SS'));
            OPIMPXIN.calc_total_receipt(l_errbuf,l_retcode,inv_from_date,to_date,org_id);
            select sysdate into l_print_date from dual;
            EDW_LOG.PUT_LINE('End time: ' ||
                             to_char (sysdate, 'DD-MON-YY HH24:MI:SS'));

            if l_retcode = '2' then
                l_errbuf := 'Error calling calc_total_receipt.  Org id: '
                            || to_char(org_id);

                 process_error(l_statement,
                               l_errnum,
                               l_retcode,
                               l_errbuf);
                goto next_org;
            end if;

        END IF; -- end of calculating activity measures based on profile option

        EDW_LOG.PUT_LINE ('Calling calc_intrst_balance ....');
        select sysdate into l_print_date from dual;
        EDW_LOG.PUT_LINE('Start time: ' ||
                         to_char (sysdate, 'DD-MON-YY HH24:MI:SS'));
        calc_intrst_balance(inv_from_date,to_date,org_id,status);
        select sysdate into l_print_date from dual;
        EDW_LOG.PUT_LINE('End time: ' ||
                         to_char (sysdate, 'DD-MON-YY HH24:MI:SS'));

        if status > 0 then
            l_errbuf := 'Error calling calc_intrst_balance.  Org id: '
                        || to_char(org_id);

            process_error(l_statement,
                          l_errnum,
                          l_retcode,
                          l_errbuf);
            goto next_org;
        end if;

        <<wip_calculation>>
        /*-------------------------------------------------------------------
        Calling WIP procedures to populate the WIP Balance and Activities
        ---------------------------------------------------------------------*/
        l_statement := 60;

        -- Call wip procedure regardless of l_txn_flag, because both MMT
        -- and WT must be accumulated for WIP balances.

        EDW_LOG.PUT_LINE('Calling OPIMPXWP.calc_wip_balance ...');
        select sysdate into l_print_date from dual;
        EDW_LOG.PUT_LINE('Start time: ' ||
                         to_char (sysdate, 'DD-MON-YY HH24:MI:SS'));
        OPIMPXWP.calc_wip_balance(org_id,
                                  inv_from_date,
                                  wip_from_date,
                                  inv_trx_id,
                                  wip_trx_id,
                                  to_date,
                                  l_first_push,
                                  l_errnum,
                                  l_retcode,
                                  l_errbuf);
        select sysdate into l_print_date from dual;
        EDW_LOG.PUT_LINE('End time: ' ||
                         to_char (sysdate, 'DD-MON-YY HH24:MI:SS'));

        if l_errnum <> 0 then
            process_error(l_statement,
                          l_errnum,
                          l_retcode,
                          l_errbuf);
            goto next_org;
        end if;

        -- ------------------------------------------------------------------
        -- Procedure calc_prd_start_end  to insert/update records for
        -- the last and first day of the period.
        --
        -- ------------------------------------------------------------------

        EDW_LOG.PUT_LINE ('Calling calc_prd_start_end ....');
        select sysdate into l_print_date from dual;
        EDW_LOG.PUT_LINE('Start time: ' ||
                         to_char (sysdate, 'DD-MON-YY HH24:MI:SS'));
        opi_edw_ids_calc.calc_prd_start_end ( inv_from_date,
                                              to_date,
                                              org_id,
                                              status);
        select sysdate into l_print_date from dual;
        EDW_LOG.PUT_LINE('End time: ' ||
                         to_char (sysdate, 'DD-MON-YY HH24:MI:SS'));

        if status > 0 then
            l_errbuf := 'Error calling calc_prd_start_end.  Org id: '
                        || to_char(org_id);

            process_error(l_statement,
                          l_errnum,
                          l_retcode,
                          l_errbuf);
            goto next_org;
        end if;

        insert into opi_ids_push_date_log
          (organization_id,
           last_push_date,
           last_push_inv_txn_id,
           last_push_inv_txn_date,
           last_push_wip_txn_id,
           last_push_wip_txn_date,
           creation_date,
           last_update_date)
        values
          (org_id,
           sysdate,
           inv_trx_id,
           trunc (inv_trx_date),
           wip_trx_id,
           trunc (wip_trx_date),
           sysdate,
           sysdate);

        commit;

        <<next_org>>        -- label

        EDW_LOG.PUT_LINE('Extraction completed for org '|| to_char(org_id));

    end loop;    -- end c_inv_org loop

    EDW_LOG.PUT_LINE ('Done with inv balance extraction in opi_extract_ids.'); -- Remove . for bug 3556719
    select sysdate into l_print_date from dual;
    EDW_LOG.PUT_LINE('End time: ' ||
                     to_char (sysdate, 'DD-MON-YY HH24:MI:SS'));

EXCEPTION

    WHEN no_from_date THEN
        EDW_LOG.PUT_LINE('OPIMPXWI.opi_extract_ids - Error at statement ('
                         || to_char(l_statement)
                         || ')');

        EDW_LOG.PUT_LINE('Error Number: ' ||  to_char(l_errnum));
        EDW_LOG.PUT_LINE('Error Code: ' || l_retcode);
        EDW_LOG.PUT_LINE('Error Message: ' || l_errbuf);

   WHEN others then
        rollback;
        l_errnum := SQLCODE;
        l_errbuf := 'OPIMXWI.opi_extract_ids ('
                    || to_char(l_statement)
                    || '): '
                    || substr(SQLERRM, 1,200);

        EDW_LOG.PUT_LINE('OPIMPXWI.opi_extract_ids - Error at statement ('
                         || to_char(l_statement)
                         || ')');

        EDW_LOG.PUT_LINE('Error Number: ' ||  to_char(l_errnum));
        EDW_LOG.PUT_LINE('Error Code: ' || l_retcode);
        EDW_LOG.PUT_LINE('Error Message: ' || l_errbuf);

END opi_extract_ids;


/*}{--------------------------------------------------------------
   PRIVATE PROCEDURE:  CALC_INV_BALANCE
-----------------------------------------------------------------*/


PROCEDURE calc_inv_balance(p_from_date   IN  Date,
                           p_to_date     IN  Date,
                           Org_id        IN  Number,
                           status       OUT  NOCOPY Number) IS ---- bug 3589921 added nocopy

   l_trx_date         DATE;
   l_organization_id  NUMBER;
   l_item_id          NUMBER;
   l_cost_group_id    NUMBER;
   l_revision         VARCHAR2(3);
   l_lot_number       VARCHAR2(30);
   l_subinventory     VARCHAR2(10);
   l_locator          NUMBER;
   l_item_status      VARCHAR2(10);
   l_item_type        VARCHAR2(30);
   l_base_uom         VARCHAR2(3);
   total_value        NUMBER;
   total_qty          NUMBER;
   trx_type           NUMBER;
   l_status           NUMBER;
   l_statement        NUMBER;
   l_edw_start_date_org DATE := null;

    -- digupta 07/10/02 -- filtered out certain transactions that do not
    -- affect inventory quantity or balance.
    -- ltong 01/20/2003. Filtered out consigned inventory.
    -- mochawla 10/29/2003. filtered out logical transactions from Daily onhand quantity
    CURSOR inv_balance_no_lot IS
    SELECT   trunc(mmt.TRANSACTION_DATE),
          mmt.ORGANIZATION_ID,
          mmt.INVENTORY_ITEM_ID,
          mmt.COST_GROUP_ID,
          mmt.REVISION,
          mmt.SUBINVENTORY_CODE,
          mmt.LOCATOR_ID,
          sum(mmt.PRIMARY_QUANTITY)
    FROM  MTL_MATERIAL_TRANSACTIONS mmt,
          MTL_SYSTEM_ITEMS  msi
    WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
      AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
      AND mmt.ORGANIZATION_ID=Org_id
      AND msi.LOT_CONTROL_CODE = 1
      AND mmt.transaction_date >= p_from_date
      AND mmt.transaction_date <= p_to_date
      AND mmt.transaction_type_id NOT IN (73, 80, 25, 26, 28, 90, 91, 92, 55, 56, 57, 58, 87, 88, 89, 24)
      AND MMT.organization_id =  NVL(MMT.owning_organization_id,MMT.organization_id)
      AND NVL(MMT.OWNING_TP_TYPE,2) = 2
      AND NVL(mmt.logical_transaction, 2) <> 1     /*11.5.10 changes*/
 GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,
      mmt.COST_GROUP_ID,mmt.REVISION,mmt.SUBINVENTORY_CODE,mmt.locator_id
      ORDER BY trunc(mmt.TRANSACTION_DATE);  -- added by rjin

    -- digupta 07/10/02 -- filtered out certain transactions that do not
    -- affect inventory quantity or balance.
    -- ltong 01/20/2003. Filtered out consigned inventory.
    -- mochawla 10/29/2003. filtered out logical transactions from Daily onhand quantity
    CURSOR inv_balance_with_lot IS
    SELECT trunc(mmt.TRANSACTION_DATE),
           mmt.ORGANIZATION_ID,
           mmt.INVENTORY_ITEM_ID,
           mmt.COST_GROUP_ID,
           mmt.REVISION,
       mtln.LOT_NUMBER,
           mmt.SUBINVENTORY_CODE,
           mmt.LOCATOR_ID,
       sum(mtln.PRIMARY_QUANTITY)
     FROM  MTL_MATERIAL_TRANSACTIONS mmt,
           MTL_SYSTEM_ITEMS  msi,
       MTL_TRANSACTION_LOT_NUMBERS mtln
    WHERE  mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
      AND  mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
      AND  mmt.ORGANIZATION_ID=Org_id
      AND  msi.LOT_CONTROL_CODE = 2
      AND  mmt.transaction_date >= p_from_date
      AND  mmt.transaction_date <= p_to_date
      AND  mmt.transaction_id = mtln.transaction_id
      AND  mmt.transaction_type_id NOT IN (73, 80, 25, 26, 28, 90, 91, 92,
                                           55, 56, 57, 58, 87, 88, 89, 24)
      AND MMT.organization_id =  NVL(MMT.owning_organization_id,MMT.organization_id)
      AND NVL(MMT.OWNING_TP_TYPE,2) = 2
      AND NVL(mmt.logical_transaction, 2) <> 1     /*11.5.10 changes*/
 GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,
                mmt.COST_GROUP_ID,mmt.REVISION,mtln.lot_number,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID
 ORDER BY trunc(mmt.TRANSACTION_DATE);


BEGIN

   EDW_LOG.PUT_LINE(' p_from_date= '||to_char(p_from_date,'DD-MON-YYYY hh24:mi:ss')||
            ' p_to_Date= '||to_char(p_to_date,'DD-MON-YYYY hh24:mi:ss')||' org= '||Org_id);


/*----------------------------------------------------------------------------------------
Get the total qty transacted for the group (date,item,org,cg,rev,lot,sub,locator) for
non lot control items.
-----------------------------------------------------------------------------------------*/

   OPEN inv_balance_no_lot;
   l_lot_number := null;


   -- Get the EDW start date for this org, to check later whether we have
   -- backposted transactions on the inception date. If so, we do not want
   -- lose the beginning onhand quantities.
   BEGIN
        SELECT trunc (min (trx_date))    -- must drop time stamp timestamp.
          INTO l_edw_start_date_org
          FROM opi_ids_push_log
          WHERE organization_id = org_id;
   EXCEPTION            -- don't expect to be here, because we should
                        -- are not doing a first push and at least the
                        -- EDW inception entries should be present. Just
                        -- being safe.
        WHEN NO_DATA_FOUND THEN
            NULL;  -- l_edw_start_date_org would be NULL if no date found
            -- l_edw_start_date_org := NULL;  -- was the first push, so
                                           -- the ids_push_log is empty
   END;

l_statement:=1;

   LOOP


      FETCH inv_balance_no_lot
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_subinventory,
            l_locator,
            total_qty;


     if(inv_balance_no_lot%NOTFOUND) then
        CLOSE inv_balance_no_lot;
        EXIT;
     end if;


/*
EDW_LOG.PUT_LINE('///////////////with no lot cursor, count is ' ||inv_balance_no_lot%rowcount );

EDW_LOG.PUT_LINE('l_trx_date='||l_trx_date);
EDW_LOG.PUT_LINE('l_item_id = ' || l_item_id );
EDW_LOG.PUT_LINE('l_cost_group_id='||to_char(l_cost_group_id));
EDW_LOG.PUT_LINE('l_revision='||l_revision);
EDW_LOG.PUT_LINE('l_lot_number='||l_lot_number);
EDW_LOG.PUT_LINE('l_subinventory='||l_subinventory);
EDW_LOG.PUT_LINE('total_qty='||to_char(total_qty));
*/


      SELECT INVENTORY_ITEM_STATUS_CODE,
             ITEM_TYPE,
             PRIMARY_UOM_CODE
    INTO l_item_status,
             l_item_type,
             l_base_uom
        FROM mtl_system_items
       WHERE inventory_item_id=l_item_id
     AND organization_id = l_organization_id;

l_statement:=2;

      Calculate_Balance( l_trx_date,
                         l_organization_id,
                         l_item_id,
                         l_cost_group_id,
                         l_edw_start_date_org,
                         l_revision,
                         l_lot_number,
                         l_subinventory,
                         l_locator,
                         l_item_status,
                         l_item_type,
                         l_base_uom,
                         total_qty,
                         l_status);

     if(l_status > 0) then
    status:=1;
    return;
     end if;

l_statement:=3;

   END LOOP;


/*----------------------------------------------------------------------------------------
Get the total qty transacted for the group (date,item,org,cg,rev,lot,sub,locator) for
non lot control items.
-----------------------------------------------------------------------------------------*/
l_statement:=4;

  open inv_balance_with_lot;

  LOOP

      FETCH inv_balance_with_lot
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_lot_number,
            l_subinventory,
            l_locator,
            total_qty;

l_statement:=5;


     if(inv_balance_with_lot%NOTFOUND) then
        CLOSE inv_balance_with_lot;
        EXIT;
    end if;


/*
EDW_LOG.PUT_LINE('/////within with_lot cursor count is ' ||inv_balance_with_lot%rowcount );

EDW_LOG.PUT_LINE('l_trx_date='||l_trx_date);
EDW_LOG.PUT_LINE('l_item_id = ' || l_item_id );

EDW_LOG.PUT_LINE('l_cost_group_id='||to_char(l_cost_group_id));
EDW_LOG.PUT_LINE('l_revision='||l_revision);
EDW_LOG.PUT_LINE('l_lot_number='||l_lot_number);
EDW_LOG.PUT_LINE('l_subinventory='||l_subinventory);

EDW_LOG.PUT_LINE('total_qty='||to_char(total_qty));
*/


      SELECT INVENTORY_ITEM_STATUS_CODE,
             ITEM_TYPE,
             PRIMARY_UOM_CODE
    INTO l_item_status,
             l_item_type,
             l_base_uom
        FROM mtl_system_items
       WHERE inventory_item_id=l_item_id
     AND organization_id = l_organization_id;

l_statement:=6;

      Calculate_Balance( l_trx_date,
                         l_organization_id,
                         l_item_id,
                         l_cost_group_id,
                         l_edw_start_date_org,
                         l_revision,
                         l_lot_number,
                         l_subinventory,
                         l_locator,
                         l_item_status,
                         l_item_type,
                         l_base_uom,
                         total_qty,
                         l_status);

      if(l_status > 0) then
    status:=1;
    return;
      end if;


l_statement:=7;

  END LOOP;

EXCEPTION
WHEN OTHERS THEN
   edw_log.put_line('Error in CALC_INV_BALANCE at statement= '||l_statement);
   edw_log.put_line('Error Code: ' || SQLCODE );
   edw_log.put_line('Error Msg:  ' || Sqlerrm );
   status := 2;

END CALC_INV_BALANCE;


/*------------------------------------------------------------------------------
    PROCEDURE CALCULATE_BALANCE:
    This procedure will calculate the start and end qty and value for a key.
---------------------------------------------------------------------------------*/

PROCEDURE Calculate_Balance( p_trx_date   IN DATE,
                p_organization_id  IN NUMBER,
                p_item_id          IN NUMBER,
                p_cost_group_id    IN NUMBER,
                p_edw_start_date   IN DATE,  -- first date for org in push log
                p_revision         IN VARCHAR2,
                p_lot_number       IN VARCHAR2,
                p_subinventory     IN VARCHAR2,
                p_locator          IN NUMBER,
                p_item_status      IN VARCHAR2,
                p_item_type        IN VARCHAR2,
                p_base_uom         IN VARCHAR2,
                p_total_qty        IN NUMBER,
                status             OUT NOCOPY NUMBER)  IS  -- bug 3589921 added nocopy

    l_trx_id         Number:=0;
    l_start_qty      Number:=0;
    l_end_qty        Number:=0;
    l_avg_qty        Number:=0;
    l_last_end_val   Number:=0;
    l_last_end_qty   Number:=0;
    l_start_val      Number:=0;
    l_end_val        Number:=0;
    l_avg_val        Number:=0;
    l_total_val      Number:=0;
    cost_method      Number;
    item_cost        Number:=0;
    prev_day_item_cost Number := 0;
    l_max_trx_date   Date := null;
    asset_sub        Number:=0;
    non_expense_item VARCHAR2(1); -- digupta 11/11/02
    l_statement      Number:=0;
    l_status         Number:=1;

   CURSOR last_trx is
   SELECT trunc(MAX(trx_date))
     FROM OPI_IDS_PUSH_LOG
    WHERE ORGANIZATION_ID            = p_organization_id
      AND  INVENTORY_ITEM_ID          = p_item_id
      AND  nvl(COST_GROUP_ID,-999)    = nvl(p_cost_group_id,-999)
      AND  nvl(REVISION,-999)         = nvl(p_revision,-999)
      AND  nvl(LOT_NUMBER,-999)       = nvl(p_lot_number,-999)
      AND  nvl(SUBINVENTORY_CODE,-999)= nvl(p_subinventory,-999)
      AND  nvl(project_locator_id, nvl(LOCATOR_ID,-999)) = nvl(p_locator,-999)  -- Suhasini Added project_locator_id,Forward port from 11.5.9.3
      AND  trx_date < p_trx_date;  -- added by rjin

   l_ids_key        VARCHAR2(240);
BEGIN

/*
EDW_LOG.PUT_LINE('total_qty='||to_char(p_total_qty));
*/

   SELECT primary_cost_method
    INTO cost_method
    FROM mtl_parameters
   WHERE Organization_id=p_organization_id;


   OPEN last_trx;

   FETCH last_trx
     INTO l_max_trx_date;


   l_statement := 1;



/*---------------------------------------------------------------------------------------
   The above cursor will find if the record is already existing in opi_ids_push_log for a
   particular item,org,costgroup,rev,lot,sub and locator. It not then the start qty and start
   value are 0, otherwise get the start value and qty for the last transacted record for that
   combination (last record) from opi_ids_push_log
   ------------------------------------------------------------------------------------------*/

     l_ids_key := l_max_trx_date||'-'||p_item_id||'-'||p_organization_id||'-'||p_cost_group_id||'-'||p_revision||'-'||p_lot_number||'-'||p_subinventory||'-'||p_locator;

   --EDW_LOG.PUT_LINE( ' ids_key ' || l_ids_key );

   IF(l_max_trx_date is null) THEN

       -- Since there are no entries in the push log for this item-org prior
       -- to this date, we just need to ensure that the  date being collected
       -- is not the EDW inception date for this org i.e. the first date
       -- on which any data was ever reported for this org. If it is, then
       -- we must have hit a backdated transaction for this date, and are
       -- recollecting the start date without calculating the inception
       -- balances. So we must not throw away the already calculated
       -- beginning onhand quantities for this item-org-date.
       -- Both, p_trx_date and p_edw_start_date, are trunc'ed.
       IF ((p_trx_date <> p_edw_start_date) OR
           (p_edw_start_date IS NULL)) -- could be NULL in case of first push
       THEN
            l_last_end_qty := 0;  -- really don't expect to be in here
            l_last_end_val := 0;  -- because we should not be running
                                  -- Calculate_Balance with a first push
                                  -- BE CAREFUL THOUGH - this means that
                                  -- we cannot delete the edw inception rows
                                  -- and run an incremental from that day
                                  -- all over again. So don't ever delete
                                  -- edw inception rows.
       ELSE -- trunc (p_trx_date) = p_edw_start_date

            l_ids_key := p_trx_date||'-'||p_item_id||'-'||p_organization_id||'-'||p_cost_group_id||'-'||p_revision||'-'||p_lot_number||'-'||p_subinventory||'-'||p_locator;
	    Begin                                               -- Suhasini Added exception handling, Forward port 11.5.9.3
            SELECT nvl(sum(nvl(beg_onh_qty, 0)),0),
                   nvl(sum(nvl(beg_onh_val_b, 0)),0)
                                            -- if nothing is found, then there
                                            -- must never have been an
                                            -- inception qty
          INTO l_last_end_qty, l_last_end_val
          FROM opi_ids_push_log
                 WHERE IDS_KEY = l_ids_key;
	   Exception
               when others  then
                    edw_log.put_line('ids key  - ' || l_ids_key );
                    Raise;
          end;

       END IF;
   ELSE
   	Begin						-- Suhasini Added exception handling, Forward port 11.5.9.3
       SELECT Nvl(end_onh_val_b,0), Nvl(end_onh_qty,0)
         INTO  l_last_end_val, l_last_end_qty
         FROM   OPI_IDS_PUSH_LOG
     WHERE  IDS_KEY = l_ids_key;
	   Exception
               when others  then
                    edw_log.put_line('ids key  - ' || l_ids_key );
                    Raise;
          end;
   END IF;

   CLOSE last_trx;


-- EDW_LOG.PUT_LINE('l_max_trx_date is ' || l_max_trx_date || 'l_last_end_qty is ' || l_last_end_qty || 'l_last_end_val is ' || l_last_end_val );

l_statement := 2;

/*--------------------------------------------------------------------------------------------------
We need to take qty into account for the expense subs but should not calculate the value for
Expense sub
---------------------------------------------------------------------------------------------------*/

  IF p_subinventory IS NOT NULL  THEN
    SELECT asset_inventory
      INTO asset_sub
      FROM mtl_secondary_inventories sub
     WHERE sub.SECONDARY_INVENTORY_NAME=p_subinventory
       AND sub.organization_id = p_organization_id;

      if (asset_sub<>1) then
      item_cost:=0;
      prev_day_item_cost := 0;
      end if;
  END IF;

  -- check if item is expense item
  SELECT inventory_asset_flag
    INTO non_expense_item
    FROM mtl_system_items
    WHERE organization_id = p_organization_id
      AND inventory_item_id = p_item_id;
/*---------------------------------------------------------------------------------------------------
Find the cost for the item as of last trx in the day for the key combination.
So we will look for the
-new_cost: for avg/fifo/lifo costing org
-actual_cost: for std costing org
for the max(transaction_id) for a day.
-----------------------------------------------------------------------------------------------------*/
  /* get the item cost if this is not an expense subinventory or an expense
     item */
  IF ((asset_sub = 1 OR p_subinventory is NULL)
      AND (non_expense_item = 'Y')) THEN   -- {
    IF (cost_method = 1) THEN  --  is a standard costing org

        -- get standard costing org cost specially since mcacd does
        -- not update the actual cost properly in a standard cost
        -- update scenario
        item_cost := std_costing_org_item_cost (p_organization_id, p_item_id,
                                                p_trx_date);
        -- item cost on previous day for starting balances
        prev_day_item_cost := std_costing_org_item_cost (p_organization_id,
                                                         p_item_id,
                                                         p_trx_date - 1);

    ELSE
        -- item cost at the end of the day of transaction
        item_cost := avg_costing_org_item_cost (p_organization_id, p_item_id,
                                                p_trx_date, p_cost_group_id);
        -- item cost at the start of the day i.e. item cost at the end
        -- of last day
        prev_day_item_cost := avg_costing_org_item_cost (p_organization_id,
                                                         p_item_id,
                                                         p_trx_date - 1,
                                                         p_cost_group_id);

    END IF; -- } cost_method = 1

  END IF;   -- } (asset_sub = 1 OR p_subinventory is NULL) AND
            --   (non_expense_item = 'Y')

l_statement := 3;


/*-------------------------------------------------------------------------------------------
Calculate the ending and average  value and qty  for the key
--------------------------------------------------------------------------------------------*/
  l_start_qty := l_last_end_qty;
  l_end_qty := l_start_qty + p_total_qty;
  l_avg_qty := (l_start_qty+l_end_qty)/2;

  IF (cost_method = 1) THEN -- standard costing org - we have a previous day
                            -- cost
      -- calculate values from costs
      l_start_val := l_start_qty * prev_day_item_cost;
      l_end_val := l_end_qty * item_cost;
  ELSE
      -- calculate values based on cost
      l_start_val := l_last_end_val;
      l_end_val := l_end_qty * item_cost;
  END IF;

  l_avg_val := (l_start_val+l_end_val)/2;

  /*  EDW_LOG.PUT_LINE('l_start_qty = '|| l_start_qty || ' l_end_qty = ' || l_end_qty || ' l_start_val = '|| l_start_val || 'l_total_val = ' || l_total_val || 'l_end_val = ' || l_end_val );  */


l_statement := 4;

  OPIMPXIN.Insert_update_push_log(
            p_trx_date => p_trx_date ,
            p_organization_id => p_organization_id,
            p_item_id         => p_item_id,
            p_cost_group_id   => p_cost_group_id,
            p_revision        => p_revision,
            p_lot_number      => p_lot_number,
            p_subinventory    => p_subinventory,
            p_locator         => p_locator,
            p_item_status     => p_item_status,
            p_item_type       => p_item_type,
            p_base_uom        => p_base_uom,
            p_col_name1       => 'beg_onh_qty',
            p_total1          => l_start_qty,
            p_col_name2       => 'beg_onh_val_b',
            p_total2          => l_start_val,
            p_col_name3       => 'end_onh_qty',
            p_total3          => l_end_qty,
            p_col_name4       => 'end_onh_val_b',
            p_total4          => l_end_val,
            p_col_name5       => 'avg_onh_val_b',
            p_total5          => l_avg_val,
            p_col_name6       => 'avg_onh_qty',
            p_total6          => l_avg_qty,
            selector          => 2,
            success           => l_status);

l_statement := 5;

  if( l_status > 0 ) then
      edw_log.put_line('Error in Insert_update_push_log');
      status := 1;
  else
      status := 0;
  end if;

EXCEPTION
WHEN OTHERS THEN
   edw_log.put_line('Error in Calculate_Balance at statement= '||l_statement);
   edw_log.put_line('Error Code: ' || SQLCODE );
   edw_log.put_line('Error Msg:  ' || Sqlerrm );
   status := 1;

END Calculate_Balance;

PROCEDURE purge_opi_ids_push_log(
                  i_org_id     IN   NUMBER,
                  o_errnum     OUT NOCOPY NUMBER, -- bug 3589921 added nocopy
                  o_retcode    OUT NOCOPY VARCHAR2, -- bug 3589921 added nocopy
                  o_errbuf     OUT NOCOPY VARCHAR2   -- bug 3589921 added nocopy
                 )IS

   l_errnum             number;
   l_retcode            varchar2(20);
   l_errbuf             varchar2(240);
   l_statement          number;
   l_purge_from_date    date;
   l_purge_to_date      date;
   l_last_push_inv_date date;
   l_last_push_wip_date   date;
   l_last_push_date       date;
   l_latest_push_date   date;
   no_purge             exception;

BEGIN

-- Initialize local variables
   l_errnum := 0;
   l_retcode := '';
   l_errbuf := '';
   l_purge_from_date := null;
   l_purge_to_date := null;
   l_last_push_inv_date := null;
   l_last_push_wip_date := null;
   l_last_push_date := null;
   l_latest_push_date := null;


-- Get the min date of opi_ids_push_log rows which are not period start
-- or period end dates.  Rows with that date would be the first ones to
-- be purged if they belong to an 'eligible' closed period, i.e. a
-- period that does not include the last push transaction date.

   l_statement := 10;
   select min(trx_date)
      into l_purge_from_date
      from opi_ids_push_log ipl
      where push_flag = 0                -- already pushed
        and period_flag is null          -- not start or end period rows
        and organization_id = i_org_id;

 if (l_purge_from_date is NOT NULL) then  --  {  We do not have any rows to purge. Return Success

   l_statement := 20;

-- Get the last Inv and WIP push for the org

   select max(last_push_inv_txn_date),max(last_push_wip_txn_date)
     into l_last_push_inv_date,
          l_last_push_wip_date
     from opi_ids_push_date_log
     where organization_id = i_org_id;

   --l_last_push_date :=  min(l_last_push_inv_date,l_last_push_wip_date);

   if (l_last_push_inv_date is NOT NULL AND l_last_push_wip_date IS NOT NULL)  THEN

      if l_last_push_inv_date <= l_last_push_wip_date then
        l_last_push_date := l_last_push_inv_date;
      else
        l_last_push_date := l_last_push_wip_date;
      end if;
   elsif (l_last_push_inv_date is NOT NULL) Then    --  If INV is not null and WIP is null
       l_last_push_date := l_last_push_inv_date;
   else
       l_last_push_date := l_last_push_wip_date;    -- If Inv is null OR both Inv and WIP are null
   end if;

-- Get the end date of the latest closed period which can be purged, i.e.
-- a closed period which does not include the last push date

 if(l_last_push_date is NOT NULL) THEN  --{
   l_statement := 40;
   select max(oap.schedule_close_date)
      into l_purge_to_date
      from org_acct_periods oap
      where oap.organization_id = i_org_id
         and oap.period_close_date is not null
         and oap.schedule_close_date < l_last_push_date;

-- Do not purge if the transaction date of the first eligible row is
-- beyond the the last date that purge can be done.
-- Otherwise, purge data between those two dates

   if(l_purge_to_date is NOT NULL) THEN
     if l_purge_from_date > l_purge_to_date then
        raise no_purge;
     else
        l_statement := 50;
        delete from opi_ids_push_log ipl
         where ipl.organization_id = i_org_id
           and ipl.trx_date between l_purge_from_date
                             and l_purge_to_date
           and ipl.push_flag = 0
        and ipl.period_flag is null;

      EDW_LOG.PUT_LINE('org id: '||i_org_id ||' from date ' ||
               To_char(l_purge_from_date, 'DD-MON-YYYY HH24:MI:SS') ||
               ' to date ' || To_char(l_purge_to_date, 'DD-MON-YYYY HH24:MI:SS')
               || ' delete rowcount ' || SQL%rowcount );
      end if;
   end if;

 end if;  -- } l_last_push_date is NOT NULL

end if; --- }
   o_errnum := l_errnum;
   o_retcode := l_retcode;
   o_errbuf := l_errbuf;

EXCEPTION
   WHEN no_purge then
        o_errnum := l_errnum;
        o_errbuf := l_errbuf;
        EDW_LOG.PUT_LINE('OPIMXWI.purge_opi_ids_push_log - no purge; ');
        EDW_LOG.PUT_LINE('Data can only be purged thru '
                          || to_char(l_purge_to_date));
   WHEN others then
        o_errnum := SQLCODE;
        o_errbuf := 'OPIMXWI.purge_opi_ids_push_log ('
                    || to_char(l_statement)
                    || '): '
                    || substr(SQLERRM, 1,200);

END purge_opi_ids_push_log;

PROCEDURE process_error(
          i_stmt_num     IN   NUMBER,
          i_errnum       IN   NUMBER,
          i_retcode      IN   VARCHAR2,
          i_errbuf       IN   VARCHAR2
         )IS

BEGIN

   rollback to sav_org;

   EDW_LOG.PUT_LINE('OPIMPXWI.opi_extract_ids - Error at statement ('
                    || to_char(i_stmt_num)
                    || ')');

   EDW_LOG.PUT_LINE('Error Number: ' ||  to_char(i_errnum));
   EDW_LOG.PUT_LINE('Error Code: ' || i_retcode);
   EDW_LOG.PUT_LINE('Error Message: ' || i_errbuf);

g_org_error := true;
END process_error;

PROCEDURE process_warning(
          i_stmt_num     IN   NUMBER,
          i_errnum       IN   NUMBER,
          i_retcode      IN   VARCHAR2,
          i_errbuf       IN   VARCHAR2) IS

         BEGIN

   rollback to sav_org;

   EDW_LOG.PUT_LINE('OPIMPXWI.opi_extract_ids - Warning at statement ('
                    || to_char(i_stmt_num)
                    || ')');

   EDW_LOG.PUT_LINE('Warning Number: ' ||  to_char(i_errnum));
   EDW_LOG.PUT_LINE('Warning Code: ' || i_retcode);
   EDW_LOG.PUT_LINE('Warning Message: ' || i_errbuf);

g_org_error := true;
END process_warning;

-- -------------------------------------------------------------------------------
-- Procedure  calc_begin_inv  to calculate the begin Balance for the first time
-- the PUSH is run.
-- ------------------------------------------------------------------------------

PROCEDURE  calc_begin_inv(p_from_date IN   DATE,
                              Org_id IN Number,
                              status OUT NOCOPY Number) IS -- bug 3589921 added nocopy

   cost_method  Number;
   l_item_id          NUMBER;
   l_cost_group_id    NUMBER;
   l_revision         VARCHAR2(3);
   l_lot_number       VARCHAR2(30);
   l_subinventory     VARCHAR2(10);
   l_locator          NUMBER;
   current_onhand_qty NUMBER;
   net_transacted_quantity NUMBER;
   beg_onh_qty NUMBER;
   beg_onh_val NUMBER;
   item_cost NUMBER;
   l_status NUMBER;
   l_item_status      VARCHAR2(10);
   l_item_type        VARCHAR2(30);
   l_base_uom         VARCHAR2(3);
   l_trx_id NUMBER;
   asset_sub        Number:=0;   -- digupta 10/08/02
   non_expense_item     VARCHAR2(1); -- digupta 11/11/02
   ctr1     NUMBER:=0;
   ctr2     NUMBER:=0;
   ctr3     NUMBER:=0;

   from_date_transacted_quantity NUMBER := 0;
   end_onh_qty NUMBER;
   end_onh_val NUMBER;
   avg_onh_qty NUMBER;
   avg_onh_val NUMBER;

 -- digupta 07/10/02 -- filtered out certain transactions that do not
 -- affect inventory quantity or balance.
 -- ltong 01/20/2003. Filtered out consigned inventory.
 -- mochawla 10/29/2003. filtered out logical transactions from quantity and balance
 CURSOR beg_inv_balance IS
    SELECT mmt.INVENTORY_ITEM_ID,
           mmt.COST_GROUP_ID,
           mmt.REVISION,
           decode(msi.LOT_CONTROL_CODE,2,nvl(mtln.LOT_NUMBER,'-99'),NULL) LOT_NUMBER, --bug 4561628 Forward ported
           mmt.SUBINVENTORY_CODE,
           mmt.LOCATOR_ID
     FROM  MTL_MATERIAL_TRANSACTIONS mmt,
           MTL_TRANSACTION_LOT_NUMBERS mtln,
       mtl_system_items msi
    WHERE  mmt.ORGANIZATION_ID=Org_id
      AND  mmt.transaction_date >= Trunc(p_from_date)
      AND  mmt.transaction_id = mtln.transaction_id (+)
      and  msi.organization_id = mmt.organization_id
      and  msi.inventory_item_id = mmt.inventory_item_id
      AND  mmt.transaction_type_id NOT IN (73, 80, 25, 26, 28, 90, 91, 92,
                                           55, 56, 57, 58, 87, 88, 89, 24)
      AND MMT.organization_id =  NVL(MMT.owning_organization_id,MMT.organization_id)
      AND NVL(MMT.OWNING_TP_TYPE,2) = 2
      AND NVL(mmt.logical_transaction, 2) <> 1     /*11.5.10 changes*/
 GROUP BY mmt.INVENTORY_ITEM_ID, mmt.COST_GROUP_ID,mmt.REVISION,mtln.lot_number,msi.LOT_CONTROL_CODE,
          mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID
    UNION
   SELECT INVENTORY_ITEM_ID,
          COST_GROUP_ID,
          REVISION,
          LOT_NUMBER,
          SUBINVENTORY_CODE,
          LOCATOR_ID
    FROM  mtl_onhand_quantities
   WHERE  ORGANIZATION_ID=Org_id
  GROUP BY INVENTORY_ITEM_ID,COST_GROUP_ID,REVISION,LOT_NUMBER,SUBINVENTORY_CODE,locator_id;


BEGIN

  SELECT primary_cost_method
    INTO cost_method
    FROM mtl_parameters
   WHERE Organization_id=Org_id;

  OPEN beg_inv_balance;

  LOOP

    -- by default, item cost = 0 at the start for every trx.
    item_cost := 0;

    FETCH beg_inv_balance
     INTO   l_item_id,
            l_cost_group_id,
            l_revision,
            l_lot_number,
            l_subinventory,
            l_locator;


    if(beg_inv_balance%NOTFOUND) then
        CLOSE beg_inv_balance;
        EXIT;
    end if;

if (l_lot_number <> '99') then       -- Forward port Bug 4561628
    ctr1:=ctr1+1;

    -- digupta 07/10/02 -- filtered out certain transactions that do not
    -- affect inventory quantity or balance.
    SELECT sum(TRANSACTION_QUANTITY)
      INTO current_onhand_qty
      FROM mtl_onhand_quantities
     WHERE INVENTORY_ITEM_ID = l_item_id
       AND ORGANIZATION_ID = Org_id
       AND SUBINVENTORY_CODE = l_subinventory
       AND nvl(REVISION,-999) = nvl(l_revision,-999)
       AND nvl(LOCATOR_ID,-999) = nvl(l_locator,-999)
       AND nvl(LOT_NUMBER,-999) = nvl(l_lot_number,-999)
       AND Nvl(cost_group_id,-999) = Nvl(l_cost_group_id,-999);

   IF (l_lot_number IS NULL) THEN

      -- digupta 07/10/02 -- filtered out certain transactions that do not
      -- affect inventory quantity or balance.
      -- mochawla 10/29/2003. filtered out logical transactions from net quantity
      SELECT sum(primary_quantity)
        INTO net_transacted_quantity
        FROM mtl_material_transactions
       WHERE INVENTORY_ITEM_ID = l_item_id
    AND ORGANIZATION_ID = Org_id
    AND Nvl(subinventory_code,-999) = Nvl(l_subinventory,-999)
    AND nvl(REVISION,-999) = nvl(l_revision,-999)
    AND nvl(LOCATOR_ID,-999) = nvl(l_locator,-999)
    AND Nvl(cost_group_id,-999) = Nvl(l_cost_group_id,-999)
    AND TRANSACTION_DATE >= Trunc(p_from_date+1)
    AND transaction_type_id NOT IN (73, 80, 25, 26, 28, 90, 91, 92, 55, 56, 57, 58, 87, 88, 89, 24)
    AND organization_id =  NVL(owning_organization_id, organization_id)
    AND NVL(OWNING_TP_TYPE,2) = 2
    AND NVL(logical_transaction, 2) <> 1;     /*11.5.10 changes*/

      -- digupta 07/10/02 -- filtered out certain transactions that do not
      -- affect inventory quantity or balance.
      -- mochawla 10/29/2003. filtered out logical transactions from transacted quantity
      SELECT sum(primary_quantity)
        INTO from_date_transacted_quantity
        FROM mtl_material_transactions
    WHERE INVENTORY_ITEM_ID = l_item_id
    AND ORGANIZATION_ID = Org_id
    AND Nvl(subinventory_code,-999) = Nvl(l_subinventory,-999)
    AND nvl(REVISION,-999) = nvl(l_revision,-999)
    AND nvl(LOCATOR_ID,-999) = nvl(l_locator,-999)
    AND Nvl(cost_group_id,-999) = Nvl(l_cost_group_id,-999)
    AND TRANSACTION_DATE >= Trunc(p_from_date)
    AND transaction_date < Trunc(p_from_date+1)
    AND transaction_type_id NOT IN (73, 80, 25, 26, 28, 90, 91, 92, 55, 56, 57, 58, 87, 88, 89, 24)
    AND organization_id =  NVL(owning_organization_id, organization_id)
    AND NVL(OWNING_TP_TYPE,2) = 2
    AND NVL(logical_transaction, 2) <> 1;     /*11.5.10 changes*/
    ELSE

      -- digupta 07/10/02 -- filtered out certain transactions that do not
      -- affect inventory quantity or balance.
      -- ltong 01/20/2003. Filtered out consigned inventory.
      -- mochawla 10/29/2003. filtered out logical transactions from net quantity
      SELECT sum(mtln.primary_quantity)
        INTO net_transacted_quantity
        FROM mtl_material_transactions mmt,
    MTL_TRANSACTION_LOT_NUMBERS mtln
    WHERE mmt.INVENTORY_ITEM_ID = l_item_id
    AND mmt.ORGANIZATION_ID = Org_id
    AND Nvl(mmt.subinventory_code,-999) = Nvl(l_subinventory,-999)
    AND nvl(REVISION,-999) = nvl(l_revision,-999)
    AND nvl(LOCATOR_ID,-999) = nvl(l_locator,-999)
    AND nvl(mtln.LOT_NUMBER,-999) = nvl(l_lot_number,-999)
    AND Nvl(mmt.cost_group_id,-999) = Nvl(l_cost_group_id,-999)
    AND mmt.TRANSACTION_DATE >= Trunc( p_from_date +1)
    AND mmt.transaction_id = mtln.transaction_id
    AND mmt.transaction_type_id NOT IN (73, 80, 25, 26, 28, 90, 91, 92, 55, 56, 57, 58, 87, 88, 89, 24)
    AND MMT.organization_id =  NVL(MMT.owning_organization_id,MMT.organization_id)
    AND NVL(MMT.OWNING_TP_TYPE,2) = 2
    AND NVL(mmt.logical_transaction, 2) <> 1;     /*11.5.10 changes*/

      -- digupta 07/10/02 -- filtered out certain transactions that do not
      -- affect inventory quantity or balance.
      -- ltong 01/20/2003. Filtered out consigned inventory.
      -- mochawla 10/29/2003. filtered out logical transactions from quantity
      SELECT sum(mtln.primary_quantity)
    INTO from_date_transacted_quantity
    FROM mtl_material_transactions mmt,
    MTL_TRANSACTION_LOT_NUMBERS mtln
    WHERE mmt.INVENTORY_ITEM_ID = l_item_id
    AND mmt.ORGANIZATION_ID = Org_id
    AND Nvl(mmt.subinventory_code,-999) = Nvl(l_subinventory,-999)
    AND nvl(REVISION,-999) = nvl(l_revision,-999)
    AND nvl(LOCATOR_ID,-999) = nvl(l_locator,-999)
    AND nvl(mtln.LOT_NUMBER,-999) = nvl(l_lot_number,-999)
    AND Nvl(mmt.cost_group_id,-999) = Nvl(l_cost_group_id,-999)
    AND mmt.TRANSACTION_DATE >= Trunc(p_from_date)
    AND mmt.transaction_date <  Trunc( p_from_date +1)
    AND mmt.transaction_id = mtln.transaction_id
    AND mmt.transaction_type_id NOT IN (73, 80, 25, 26, 28, 90, 91, 92, 55, 56, 57, 58, 87, 88, 89, 24)
    AND MMT.organization_id =  NVL(MMT.owning_organization_id,MMT.organization_id)
    AND NVL(MMT.OWNING_TP_TYPE,2) = 2
    AND NVL(mmt.logical_transaction, 2) <> 1;     /*11.5.10 changes*/

   END IF;

   beg_onh_qty :=  nvl(current_onhand_qty,0) - nvl(net_transacted_quantity,0)
     - Nvl(from_date_transacted_quantity,0);

   end_onh_qty := beg_onh_qty + Nvl(from_date_transacted_quantity, 0);
   avg_onh_qty := (beg_onh_qty + end_onh_qty) /2;

   /*
   edw_log.put_line('item_id ' || l_item_id || 'c_onhand_qty is ' || current_onhand_qty ||
            ' net_qty is ' || net_transacted_quantity ||
            ' from_qty is ' || from_date_transacted_quantity || 'beg_onh_qty ' || beg_onh_qty );
     */

     -- if beg_onh_qty > 0 OR end_onh_qty > 0 THEN
     -- there might be negative value allowed for inventory
     -- actually we can create the entry. If there is no activity/balance in this period,
     -- then the cleanup will be taken care in calc_prd_start_end  by rjin

           ctr2:=ctr2+1;

    /*-----------------------------------------------------------------------
    digupta 10/08/02
    We need to take qty into account for the expense subs but should not
    calculate the value for Expense sub. This is analogous to what we
    do in the calculate_balance procedure.
    -------------------------------------------------------------------*/

    IF l_subinventory IS NOT NULL  THEN
      SELECT asset_inventory
        INTO asset_sub
        FROM mtl_secondary_inventories sub
        WHERE sub.SECONDARY_INVENTORY_NAME=l_subinventory
          AND sub.organization_id = Org_id;

      if (asset_sub<>1) then
        item_cost:=0;
      end if;
    END IF;

    -- see if this is an expense item
    SELECT inventory_asset_flag
      INTO non_expense_item
      FROM mtl_system_items
      WHERE organization_id = org_id
        AND inventory_item_id = l_item_id;

    -- If this is not an expense sub or and expense item,
    -- then get the item cost
    IF ((asset_sub = 1 OR l_subinventory is NULL)
        AND (non_expense_item = 'Y')) THEN   -- {
        -- standard costing orgs need be treated differently
        IF (cost_method = 1) -- is a standard costing org
        THEN -- {
            -- get standard costing org cost specially since mcacd does
            -- not update the actual cost properly in a standard cost
            -- update scenario
            item_cost := std_costing_org_item_cost (org_id,
                                                    l_item_id,
                                                    p_from_date);

        ELSE
          -- digupta 07/10/02 -- filtered out certain transactions that do not
          -- affect inventory quantity or balance.
          -- ltong 01/20/2003. Filtered out consigned inventory.
            SELECT MAX(macd.transaction_id)
              INTO l_trx_id
              FROM mtl_cst_actual_cost_details macd,
                   mtl_material_transactions mmt
              WHERE mmt.transaction_id = macd.transaction_id
                AND mmt.ORGANIZATION_ID = Org_id
                AND mmt.INVENTORY_ITEM_ID = l_item_id
                AND Nvl(mmt.cost_group_id,-999) = Nvl(l_cost_group_id, -999)
                AND mmt.transaction_type_id NOT IN
                    (73, 80, 25, 26, 28, 90, 91, 92, 55, 56, 57, 58,
                     87, 88, 89, 24)
                AND MMT.organization_id =  NVL(MMT.owning_organization_id,
                                               MMT.organization_id)
                AND NVL(MMT.OWNING_TP_TYPE,2) = 2
                AND mmt.transaction_date =
                    (SELECT transaction_date
                       FROM
                        (SELECT /*+ first_rows */ mt.transaction_date
                          FROM mtl_cst_actual_cost_details mcacd,
                               mtl_material_transactions mt
                          WHERE mt.transaction_id = mcacd.transaction_id
                            AND mt.TRANSACTION_DATE < Trunc( p_from_date+1)
                            AND mt.ORGANIZATION_ID = Org_id
                            AND mt.INVENTORY_ITEM_ID = l_item_id
                            AND mt.transaction_type_id NOT IN
                                (73, 80, 25, 26, 28, 90, 91, 92, 55, 56,
                                 57, 58, 87, 88, 89, 24)
                            AND Nvl(mt.cost_group_id,-999) =
                                    Nvl(l_cost_group_id,-999)
                          ORDER BY mt.transaction_date DESC)
                        WHERE rownum = 1);

            SELECT sum(macd.NEW_cost)
              INTO item_cost
              FROM mtl_cst_actual_cost_details macd
              WHERE macd.transaction_id=l_trx_id
                AND macd.organization_id = Org_id; /* Bug 3661478 - add filter on organization_id*/


        END IF; --  cost_method = 1
    END IF;   -- } (asset_sub = 1 OR l_subinventory is NULL) AND
              --   (non_expense_item = 'Y')


     -- edw_log.put_line(' item_cost is ' || Nvl( item_cost,0) );

     beg_onh_val := beg_onh_qty * nvl(item_cost,0);
     end_onh_val := end_onh_qty * nvl(item_cost,0);
     avg_onh_val := (beg_onh_val + end_onh_val) /2;

         SELECT INVENTORY_ITEM_STATUS_CODE,
                ITEM_TYPE,
                PRIMARY_UOM_CODE
       INTO l_item_status,
                l_item_type,
                l_base_uom
           FROM mtl_system_items
          WHERE inventory_item_id=l_item_id
        AND organization_id = Org_id;

        OPIMPXIN.Insert_update_push_log(
            p_trx_date => p_from_date ,
            p_organization_id => Org_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_lot_number      => l_lot_number,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_item_status     => l_item_status,
            p_item_type       => l_item_type,
            p_base_uom        => l_base_uom,
            p_col_name1       => 'beg_onh_qty',
            p_total1          => beg_onh_qty,
            p_col_name2       => 'beg_onh_val_b',
            p_total2          => beg_onh_val,
            p_col_name3       => 'end_onh_qty',
            p_total3          => end_onh_qty,            -- Setting end_onh_qty same as beg_onh_qty. It will
            p_col_name4       => 'end_onh_val_b',        -- get changed if there are activities on that day.
            p_total4          => end_onh_val,
            p_col_name5       => 'avg_onh_val_b',
            p_total5          => avg_onh_val,
            p_col_name6       => 'avg_onh_qty',
            p_total6          => avg_onh_qty,
            selector          => 2,
            success           => l_status);

/*
EDW_LOG.PUT_LINE('Inserted '||to_char(p_from_date)||','||to_char(Org_id)||','||to_char(l_item_id)||','||to_char(l_cost_group_id)||','||l_revision||',');

EDW_LOG.PUT_LINE(l_lot_number||','||l_subinventory||','||to_char(l_locator)||','||to_char(beg_onh_qty)||','||to_char(beg_onh_val));
*/

         if( l_status > 0 ) then
            edw_log.put_line('Error in Insert_update_push_log');
            status := 1;
         else
            status := 0;
         end if;

/* --rjin
    else
      ctr3 := ctr3+1;
      beg_onh_val := 0;
      status := 0;
    end if;
      */
 end if;        -- Forward port Bug 4561628.
 end loop;

      edw_log.put_line('Begin Balance Processed ');
      edw_log.put_line('ctr1 '||to_char(ctr1));
      edw_log.put_line('ctr2 '||to_char(ctr1));
      edw_log.put_line('ctr3 '||to_char(ctr1));
EXCEPTION
  WHEN OTHERS THEN
      edw_log.put_line('Error in calc_begin_inv : ');
      edw_log.put_line('Error code: '|| to_char(SQLCODE));
      edw_log.put_line('Error message: '||substr(SQLERRM, 1,200));
      status := 1;
      return;

End calc_begin_inv;

PROCEDURE calc_intrst_balance(p_from_date   IN  Date,
                              p_to_date     IN  Date,
                              Org_id        IN  Number,
                              status       OUT NOCOPY Number) IS --bug 3589921 added no copy

    l_trx_date         DATE;
    l_max_trx_date     DATE;
    l_organization_id  NUMBER;
    xfr_org_id         NUMBER;
    l_item_id          NUMBER;
    l_cost_group_id    NUMBER;
    l_trx_action_id    NUMBER;
    l_fob_pt           NUMBER;
    l_row_exists       NUMBER;
    l_item_status      VARCHAR2(10);
    l_item_type        VARCHAR2(30);
    l_base_uom         VARCHAR2(3);
    l_pk               VARCHAR2(100);
    l_last_end_qty     NUMBER;
    l_last_end_val     NUMBER;
    l_beg_int_qty      NUMBER;
    l_beg_int_val_b    NUMBER;
    l_end_int_qty      NUMBER;
    l_end_int_val_b    NUMBER;
    l_avg_int_qty      NUMBER;
    l_avg_int_val_b    NUMBER;
    l_cost               NUMBER;
    total_value        NUMBER;
    total_qty          NUMBER;
    trx_type           NUMBER;
    l_status           NUMBER;
    l_statement        NUMBER;
    l_process_org     VARCHAR2(2);
    l_org_id           NUMBER;

    CURSOR intrst_balance IS
        SELECT trunc(mmt.TRANSACTION_DATE),
               mmt.organization_id,
               mmt.INVENTORY_ITEM_ID,
               mmt.COST_GROUP_ID,
               mmt.PRIMARY_QUANTITY,
               mmt.transaction_action_id,
               mmt.transfer_organization_id,
               mmt.actual_cost,
               msi.inventory_item_status_code,
               msi.item_type,
               msi.primary_uom_code
          FROM  MTL_MATERIAL_TRANSACTIONS mmt,
                mtl_system_items msi
          WHERE ( mmt.ORGANIZATION_ID=Org_id or mmt.transfer_organization_id =Org_id)
            AND mmt.organization_id=msi.organization_id
            AND mmt.inventory_item_id=msi.inventory_item_id
            AND mmt.transaction_action_id in (12,21)
            AND mmt.transaction_date >= p_from_date
            AND mmt.transaction_date <= p_to_date
          ORDER BY trunc(mmt.TRANSACTION_DATE),mmt.inventory_item_id;

    CURSOR row_exists IS
        SELECT 1
          FROM opi_ids_push_log
          WHERE IDS_KEY=l_pk;

    CURSOR last_trx is
        SELECT trunc(MAX(trx_date))
          FROM OPI_IDS_PUSH_LOG
          WHERE ORGANIZATION_ID            = l_organization_id
            AND  INVENTORY_ITEM_ID          = l_item_id
            AND  nvl(COST_GROUP_ID,-999)    = nvl(l_cost_group_id,-999)
            AND  REVISION is null
            AND  LOT_NUMBER is null
            AND  SUBINVENTORY_CODE is null
            AND  LOCATOR_ID is null
            AND  trx_date < l_trx_date;

BEGIN
--DBMS_OUTPUT.PUT_LINE(' p_from_date= '||to_char(p_from_date)||' p_to_Date= '||to_char(p_to_date)||' org= '||Org_id);


    OPEN intrst_balance;

    l_statement:=1;

    LOOP


        FETCH intrst_balance
          INTO  l_trx_date,
                l_org_id,
                l_item_id,
                l_cost_group_id,
                total_qty,
                l_trx_action_id,
                xfr_org_id,
                l_cost,
                l_item_status,
                l_item_type,
                l_base_uom;


        if(intrst_balance%NOTFOUND) then
            CLOSE intrst_balance;
            EXIT;
        end if;

        l_statement:=2;

        if(l_trx_action_id = 21 or l_trx_action_id = 22) then

            select fob_point
              into l_fob_pt
              from mtl_interorg_parameters
            where from_organization_id = l_org_id
              and to_organization_id = xfr_org_id;


            -- if the FOB point is NULL, then shipping network settings
            -- must have been changed. Ignore this transaction,
            -- and report this in the log. Program will still terminate
            -- normally.
            IF (l_fob_pt IS NULL) THEN

                EDW_LOG.PUT_LINE ('Error: Intransit from org ' || Org_id ||
                                  ' to org ' || xfr_org_id ||
                                  ' has NULL FOB point.' ||
                                  ' Intransit transactions between these orgs on '|| l_trx_date || ' cannot be collected. Ignoring transaction.' );

                goto next_intrst_trx;     -- skip this trx.
            END IF;


            if l_fob_pt = 1 then     -- 1 = FOB Ship   2 = FOB Rcpt
                l_organization_id := xfr_org_id;
                total_qty := (-1)*total_qty;


            elsif l_fob_pt = 2 then
                l_organization_id := Org_id;
                total_qty := (-1)*total_qty;
            end if;

        else

            --  -------------------------------------------------------------
            --  ---  For Intrasit receipt transactions, xfr_org_id stores
            --  ---  the from org and Org_id  stores the To  org.
            --  -------------------------------------------------------------

            select fob_point
              into l_fob_pt
              from mtl_interorg_parameters
              where from_organization_id = xfr_org_id
                and to_organization_id = l_org_id;

            -- if the FOB point is NULL, then shipping network settings
            -- must have been changed. Ignore this transaction,
            -- and report this in the log. Program will still terminate
            -- sucessfully.
            IF (l_fob_pt IS NULL) THEN

                EDW_LOG.PUT_LINE ('Error: Intransit from org ' ||
                                  xfr_org_id || ' to org ' || Org_id ||
                                  ' has NULL FOB point.' ||
                                  ' Intransit transactions between these orgs on '|| l_trx_date || ' cannot be collected. Ignoring transaction.' );
                goto next_intrst_trx;     -- skip this trx.
            END IF;

            if l_fob_pt = 1 then     -- 1 = FOB Ship   2 = FOB Rcpt
                l_organization_id := Org_id;
                total_qty := (-1)*total_qty;

            elsif l_fob_pt = 2 then
                l_organization_id := xfr_org_id;
                total_qty := (-1)*total_qty;
            end if;

        end if;

        l_pk := l_trx_date||'-'||l_item_id||'-'||l_organization_id||'-'||l_cost_group_id||'-'||'-'||'-'||'-';

        /*  edw_log.put_line('IU_push_log: IDSKEY= '||l_pk);  */

        l_statement:=3;
        OPEN row_exists ;

        FETCH row_exists
        INTO l_row_exists;

        if(row_exists%rowcount > 0) then
            l_statement:=4;
            UPDATE opi_ids_push_log
              SET end_int_qty = (end_int_qty + total_qty)
              WHERE IDS_KEY = l_pk;

        else

            l_statement:=5;
            OPEN last_trx;

            FETCH last_trx
            INTO l_max_trx_date;


            /*---------------------------------------------------------------
            The above cursor will find if the record is already existing
            in opi_ids_push_log for a particular item,org,costgroup.
            If not then the start int qty and start value are 0,
            otherwise get the start value and qty for the last
            transacted record for that combination (last record)
            from opi_ids_push_log
            -----------------------------------------------------------------*/

            IF(l_max_trx_date is null) THEN
                l_last_end_qty := 0;
                l_last_end_val := 0;
            ELSE
                SELECT Nvl(end_int_val_b,0), Nvl(end_int_qty,0)
                  INTO  l_last_end_val, l_last_end_qty
                  FROM   OPI_IDS_PUSH_LOG
                  WHERE  IDS_KEY = l_max_trx_date||'-'||l_item_id||'-'||l_organization_id||'-'||l_cost_group_id||'-'||'-'||'-'||'-';

            END IF;

            CLOSE last_trx;

            total_value := nvl(total_qty,0)*nvl(l_cost,0);
            l_beg_int_qty := nvl(l_last_end_qty,0);
            l_beg_int_val_b := nvl(l_last_end_val,0);
            l_end_int_qty := l_beg_int_qty + nvl(total_qty,0);
            l_end_int_val_b := l_beg_int_val_b + nvl(total_value,0);
            l_avg_int_qty := (l_beg_int_qty + l_end_int_qty)/2;
            l_avg_int_val_b := (l_beg_int_val_b + l_end_int_val_b)/2;

            select process_enabled_flag into l_process_org
            from mtl_parameters where organization_id = l_organization_id;

            if l_process_org <> 'Y' then
            INSERT INTO opi_ids_push_log
               (ids_key,
                cost_group_id,
                organization_id,
                inventory_item_id,
                trx_date,
                push_flag,
                beg_int_qty, beg_int_val_b,
                end_int_qty, end_int_val_b,
                avg_int_qty, avg_int_val_b,
                base_uom,
                item_status,
                item_type )
               VALUES
               (l_pk,
                l_cost_group_id,
                l_organization_id,
                l_item_id,
                l_trx_date,
                1,
                l_beg_int_qty,
                l_beg_int_val_b,
                l_end_int_qty,
                l_end_int_val_b,
                l_avg_int_qty,
                l_avg_int_val_b,
                l_base_uom,
                l_item_status,
                l_item_type );
            end if;

        end if;  --  row_exists > 1

        CLOSE row_exists;

        <<next_intrst_trx>>   -- label for next intransit transaction
        null;

    END LOOP;


    l_statement:=6;
    status := 0;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        edw_log.put_line('No intercompany Shipment network defined between Org'||to_char(Org_id)||' and '||to_char(xfr_org_id));
        edw_log.put_line('Error code: '|| to_char(SQLCODE));
        edw_log.put_line('Error message: '||substr(SQLERRM, 1,200));
        status := 1;
        return;

    WHEN OTHERS THEN
        edw_log.put_line('Error in calc_intrst_balance : ');
        edw_log.put_line('Error code: '|| to_char(SQLCODE));
        edw_log.put_line('Error message: '||substr(SQLERRM, 1,200));
        status := 1;
        return;

END CALC_INTRST_BALANCE;

END OPIMPXWI;

/
