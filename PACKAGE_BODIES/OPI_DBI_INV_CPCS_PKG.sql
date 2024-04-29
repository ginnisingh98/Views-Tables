--------------------------------------------------------
--  DDL for Package Body OPI_DBI_INV_CPCS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_INV_CPCS_PKG" as
/* $Header: OPIDIVCPCSB.pls 120.2 2005/09/13 06:24:43 manokuma noship $ */

g_sysdate DATE;
g_created_by NUMBER;
g_last_update_login NUMBER;
g_last_updated_by NUMBER;
g_global_start_date DATE;
g_opi_cpcs_source CONSTANT NUMBER:= 4; -- R12 onwanrd for CPCS it will be 4. (also documented in etrm)
g_ok CONSTANT NUMBER(1) := 0;
g_warning CONSTANT NUMBER(1) := 1;
g_error CONSTANT NUMBER(1) := -1;


FUNCTION Clean_Staging_Table (
  errbuf  IN OUT NOCOPY VARCHAR2,
  retcode IN OUT NOCOPY VARCHAR2
)
  return NUMBER
IS
    l_opi_schema VARCHAR2(30);
    l_status VARCHAR2(30);
    l_industry VARCHAR2(30);
BEGIN

    BIS_COLLECTION_UTILITIES.put_line('Start of cleaning staging table.');

    IF (fnd_installation.get_app_info( 'OPI', l_status,
                                   l_industry, l_opi_schema)) THEN
        execute immediate 'truncate table ' || l_opi_schema ||
                          '.OPI_DBI_ONHAND_STG';
        BIS_COLLECTION_UTILITIES.put_line(
            'OPI_DBI_ONHAND_STG table truncated.');

        execute immediate 'truncate table ' || l_opi_schema ||
                          '.OPI_DBI_INTRANSIT_STG';
        BIS_COLLECTION_UTILITIES.put_line (
            'OPI_DBI_INTRANSIT_STG table truncated.');

        execute immediate 'truncate table ' || l_opi_schema ||
                          '.OPI_DBI_CONVERSION_RATES';
        BIS_COLLECTION_UTILITIES.put_line(
            'OPI_DBI_CONVERSION_RATES table truncated.');
    END IF;

    BIS_COLLECTION_UTILITIES.put_line('End of cleaning staging table');
    return g_ok;

EXCEPTION
    WHEN OTHERS THEN
        rollback;
        BIS_COLLECTION_UTILITIES.put_line(SQLERRM);
        retcode := SQLCODE;
        errbuf := SQLERRM;
        return g_error;
END Clean_Staging_Table;


FUNCTION Merge_Into_Summary (
  errbuf  IN OUT NOCOPY VARCHAR2,
  retcode IN OUT NOCOPY VARCHAR2
)
  return NUMBER
IS
  l_rows NUMBER := 0;
BEGIN

    INSERT /*+ append parallel(opi_dbi_inv_value_f) */ INTO opi_dbi_inv_value_f
    (operating_unit_id,
    organization_id,
    subinventory_code,
    inventory_item_id,
    transaction_date,
    primary_uom,
    onhand_value_b,
    intransit_value_b,
    wip_value_b,
    conversion_rate,
    sec_conversion_rate,
    source,
    created_by,
    last_update_login,
    creation_date,
    last_updated_by,
    last_update_date
    )
    SELECT /*+ use_hash(rate, s) parallel(s) parallel(rate) */
        NULL operating_unit_id,
        s.organization_id,
        s.subinventory_code,
        s.inventory_item_id,
        s.transaction_date,
        msi.primary_uom_code,
        s.onhand_value_b,
        s.intransit_value_b,
        s.wip_value_b,
        rate.conversion_rate,
        rate.sec_conversion_rate,
        g_opi_cpcs_source,
        g_created_by,
        g_last_update_login,
        g_sysdate,
        g_last_updated_by,
        g_sysdate
      FROM
        (SELECT /*+ parallel(adjustments) */
            organization_id,
            subinventory_code,
            inventory_item_id,
            transaction_date,
            sum(onhand_value_b) onhand_value_b,
            sum(intransit_value_b) intransit_value_b,
            sum(wip_value_b) wip_value_b
         FROM
            (SELECT  /*+ parallel(onhand_stg) */
                organization_id,
                subinventory_code,
                inventory_item_id,
                transaction_date,
                onhand_value_b,
                0 intransit_value_b,
                0 wip_value_b
              FROM opi_dbi_onhand_stg
              WHERE source = g_opi_cpcs_source
            UNION ALL
            SELECT /*+ parallel(intransit_stg) */
                organization_id,
                NULL,
                inventory_item_id,
                transaction_date,
                0 onhand_value_b,
                intransit_value_b,
                0 wip_value_b
              FROM opi_dbi_intransit_stg
              WHERE source = g_opi_cpcs_source
            ) adjustments
          GROUP BY
            organization_id,
            subinventory_code,
            inventory_item_id,
            transaction_date
        ) s,
        (SELECT /*+ no_merge parallel(rates) */
            organization_id,
            transaction_date,
            conversion_rate,
            sec_conversion_rate
          FROM opi_dbi_conversion_rates
        ) rate,
        mtl_system_items_b msi
      WHERE s.organization_id = rate.organization_id
        AND s.transaction_date = rate.transaction_date
        AND s.organization_id = msi.organization_id
        AND s.inventory_item_id = msi.inventory_item_id;

    l_rows := SQL%ROWCOUNT;


    -- Set the PCS rows as "Regular Adjustments Processed". Also,
    -- set the from_transaction_Date for next time as current
    -- transaction_date and the transaction_date as NULL.
    -- Since periods for different organizations can be closed
    -- at different times, we can only update rows for orgs that
    -- have been processed in this run i.e. ones with
    -- uncosted_trx_id = -99.
    UPDATE opi_dbi_inv_value_log
    SET uncosted_trx_id = NULL,
        from_transaction_date = transaction_date,
        transaction_date = NULL
    WHERE uncosted_trx_id = -99
      AND type = 'PCS'
      AND source = g_opi_cpcs_source;

    commit;

    return l_rows;

EXCEPTION
    WHEN OTHERS THEN
        rollback;
        BIS_COLLECTION_UTILITIES.put_line(SQLERRM);
        retcode := SQLCODE;
        errbuf := SQLERRM;
        return g_error;
END Merge_Into_Summary;



FUNCTION INSERT_ADJUSTMENTS (
    errbuf  IN OUT NOCOPY VARCHAR2,
    retcode IN OUT NOCOPY VARCHAR2
) RETURN NUMBER IS
    l_dbilog_rows NUMBER;
    l_status VARCHAR2(30);
    l_stmt_num NUMBER;
    l_err_num NUMBER;
    l_err_msg VARCHAR2(255);
BEGIN

    -- IF there are orgs that have inception balance calculated
    -- (MIF row in DBI Log table) but do not have a PCS row in
    -- DBI log table:
    -- We should execute the fisrt lump-sum process for those orgs.
    --  (New Orgs that will be created afterwards do not
    --   need the first lump-sum. Since they do not have inception
    --   to date rows in the fact table, but only MTA activity rows.
    --   So regular adjustments are sufficient for them.)
    BIS_COLLECTION_UTILITIES.put_line(
            'Start of Period Close Adjustments load.');

    -- For all organizations collected in Initial load of Inventory
    -- check if lump sum processing is done by CPCS or not.
    -- R12 Changes: Replaced opi_dbi_inv_value_log by conc_prog_run_log in outer select.
    BEGIN
        l_stmt_num := 5;
        SELECT 1
        INTO l_dbilog_rows
          FROM opi_dbi_conc_prog_run_log log
	      ,mtl_parameters mp
	  WHERE log.ETL_TYPE = 'INVENTORY'
	    AND log.load_type = 'INIT'
	    AND log.driving_table_code = 'MMT'
	    AND log.bound_level_entity_code = 'ORGANIZATION'
	    AND log.bound_level_entity_id = mp.organization_id
	    -- cpcs is only valid for discrete orgs. though log table
	    -- does not contain records for discrete orgs still putting
	    -- this additional filter.
	    AND nvl(mp.process_enabled_flag,'-1') <> 'Y'
            AND NOT EXISTS
                (SELECT 'x'
                  FROM opi_dbi_inv_value_log inlog
                  WHERE inlog.TYPE = 'PCS'
                    AND inlog.source = g_opi_cpcs_source
                    AND inlog.organization_id = log.bound_level_entity_id)
            AND rownum = 1;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_dbilog_rows := 0;
    END;

    -- If there are rows with inventory inception balances but no
    -- PCS rows, do first CPCS adjustment.
    IF l_dbilog_rows > 0 THEN

        l_stmt_num := 10;
        l_status := 'First Period Close adjustment';
        -- Insert into DBI Inventory Log the organizations
        -- that need first lump-sum adjustment ...
        INSERT INTO opi_dbi_inv_value_log
            (organization_id,
            transaction_id,
            transaction_date,
            uncosted_trx_id,
            type,
            source,
            creation_date,
            last_update_date,
            created_by,
            last_updated_by,
            last_update_login)
        SELECT /*+ use_hash(cpcs, oap)  parallel(cpcs) parallel(oap) */
            cpcs.organization_id,
            -99.99 transaction_id,
            trunc (min (oap.schedule_close_date)) transaction_date,
            -99, -- Indicates that the organization needs lump-sum adjustment processing
            'PCS' type,
            g_opi_cpcs_source source,
            g_sysdate creation_date,
            g_sysdate last_update_date,
            g_created_by created_by,
            g_last_updated_by last_updated_by,
            g_last_update_login last_update_login
          FROM  cst_period_close_summary cpcs,
                org_acct_periods oap
          WHERE cpcs.acct_period_id = oap.acct_period_id
            AND cpcs.organization_id = oap.organization_id
            AND oap.schedule_close_date >= g_global_start_date
            AND oap.summarized_flag ='Y'
            AND NOT EXISTS
                (SELECT 'x'
                  FROM opi_dbi_inv_value_log inlog
                  WHERE inlog.organization_id = cpcs.organization_id
                    AND inlog.type = 'PCS'
                    AND inlog.source = g_opi_cpcs_source)
          GROUP BY cpcs.organization_id;


        IF sql%rowcount = 0 THEN

            BIS_COLLECTION_UTILITIES.put_line ('No rows to process for the First Period Close Adjustment Load.');

        ELSE

            -- ... but remove Organizations that have:
            -- Backdated transactions after to_txn_date in DBI
            -- Inventory Log table and the backdated transaction
            -- lies within the first period close in CPCS
            l_stmt_num := 20;
            DELETE FROM opi_dbi_inv_value_log
              WHERE organization_id IN
                    (SELECT mmt.organization_id
                      FROM
                          mtl_material_transactions mmt,
                          opi_dbi_inv_value_log log2
		        WHERE log2.uncosted_trx_id = -99 -- Indicates that the organization needs lump-sum adjustment processing
                        AND log2.type = 'PCS'
                        AND log2.source = g_opi_cpcs_source
                        AND mmt.organization_id = log2.organization_id
			-- >= equal to is required because to_bound_id is first uncosted txn and not the last costed txn id
			AND mmt.transaction_id >= (select max(log1.to_bound_id)
			                           from opi_dbi_conc_prog_run_log log1
		                                  WHERE log1.load_type IN ('INIT','INCR')
			                            AND log1.etl_type = 'INVENTORY'
			                            AND log1.driving_table_code = 'MMT'
			                            AND log1.bound_level_entity_code = 'ORGANIZATION'
                                                    AND log1.bound_level_entity_id = log2.organization_id)
			-- the other condition of mmt.transaction_date <= log1.transaction_date is not required as
			-- mmt.transaction_date <= log2.transaction_date is sufficient.
			-- no need to add condition for process orgs inv_value_log cannot have it.
                        -- ... and the backdated transaction lies within the first period close in CPCS
                        AND mmt.transaction_date <= log2.transaction_date
			)
            and TYPE = 'PCS' and source = g_opi_cpcs_source;

            IF sql%rowcount > 0 THEN
                BIS_COLLECTION_UTILITIES.put_line('There are transactions related to a closed period, which ');
                BIS_COLLECTION_UTILITIES.put_line('have not been collected due to an uncosted transaction. ');
                BIS_COLLECTION_UTILITIES.put_line('Please ensure all transactions are costed and the data is collected again.');
            END IF;

            -- Commit data in the log table because we need to access it
            -- in parallel mode. This is due to bug 4285814.
            -- This should not affect anything because this branch of the
            -- code is only run in the initial load. Any errors will
            -- require the ETL to be run again. Hence there is no risk in
            -- committing early.
            -- There is known issue here. Suppose DBI initial load is run
            -- before at least one period has been closed for every org.
            -- Then the DBI initial load will not pick up initial
            -- adjustments for the orgs that have been defined prior to
            -- the DBI initial load run but have no 11.5.10 closed periods.
            -- The initial adjustment for those orgs will be picked up
            -- only during an incremental run once the first period is
            -- closed for that organization. During that incremental run
            -- if the program fails after this commit point, e.g. due to
            -- missing conversion rates, the initial adjustment will never
            -- get picked up for this org since the PCS row for this
            -- org has now been committed to the log table. For incrementals
            -- this issue has been taken care of with the new approach
            -- of using the transaction_date and from_transaction_date
            -- columns in the log. However no easy fix is available for the
            -- the initial adjustment. Of course, this is a corner case
            -- since it is unlikely that customers will be running this
            -- version of DBI with no closed 11.5.10 periods. The work-
            -- around is to run the initial load after the first period
            -- has been closed for all organizations.
            commit;

            -- Insert first lump-sum adjustments into
            -- onhand and intransit staging tables
            BIS_COLLECTION_UTILITIES.put_line(
                'Started First Period Close Adjustments load.');
            BIS_COLLECTION_UTILITIES.put_line('(First period closed with the FP "J"/115.10, period close process.)');

            l_stmt_num := 30;
            INSERT /*+ append parallel(opi_dbi_onhand_stg)
                       parallel(opi_dbi_intransit_stg) */
            ALL
            WHEN onhand_value_lump_Sum <> 0
                THEN INTO opi_dbi_onhand_stg
                    (organization_id, inventory_item_id, transaction_date,
                    onhand_value_b, source, subinventory_code,
                    creation_date, last_update_date, created_by,
                    last_updated_by, last_update_login)
                VALUES
                    (organization_id, inventory_item_id, transaction_date,
                    onhand_value_lump_sum, source, subinventory_code,
                    creation_date, last_update_date, created_by,
                    last_updated_by, last_update_login)
            WHEN intransit_value_lump_sum <> 0
                THEN INTO OPI_DBI_INTRANSIT_STG
                    (organization_id, inventory_item_id, transaction_date,
                    intransit_value_b, source,
                    creation_date, last_update_date, created_by,
                    last_updated_by, last_update_login)
                VALUES
                    (organization_id, inventory_item_id, transaction_date,
                    intransit_value_lump_sum, source,
                    creation_date, last_update_date, created_by,
                    last_updated_by, last_update_login)
            SELECT /*+ use_hash(cpcs_rbk, dbi_itd)
                       parallel(pcs_rbk) parallel(dbi_itd) */
                dbi_itd.organization_id,
                dbi_itd.subinventory_code,
                dbi_itd.inventory_item_id,
                dbi_itd.transaction_date,
                nvl (cpcs_onhand_value_b, 0) - dbi_onhand_value_b
                    onhand_value_lump_sum, -- Onhand First Lump-Sum adjustment
                nvl(cpcs_intransit_value_b, 0) - dbi_intransit_value_b
                    intransit_value_lump_sum, -- Intransit First Lump-Sum adjustment
                g_opi_cpcs_source source,
                g_sysdate creation_date,
                g_sysdate last_update_date,
                g_created_by created_by,
                g_last_updated_by last_updated_by,
                g_last_update_login last_update_login
              FROM
                (
                SELECT /*+ use_hash(cpcs, oap, invlog)
                           parallel(cpcs) parallel(oap) parallel(invlog) */
                    cpcs.organization_id,
                    nvl(cpcs.subinventory_code, -1) subinventory_code,
                    cpcs.inventory_item_id,
                    trunc(oap.schedule_close_date) transaction_date,
                    sum(rollback_onhand_value) cpcs_onhand_value_b,
                    sum(rollback_intransit_value)  cpcs_intransit_value_b
                  FROM
                    cst_period_close_summary cpcs,
                    org_acct_periods oap,
                    opi_dbi_inv_value_log invlog
                  WHERE cpcs.acct_period_id = oap.acct_period_id
                    AND cpcs.organization_id = oap.organization_id
                    AND oap.summarized_flag ='Y'
                    AND cpcs.organization_id = invlog.organization_id
                    AND oap.schedule_close_date = invlog.transaction_date
                    AND invlog.uncosted_trx_id = -99 -- Indicates that the organization needs lump-sum adjustment processing
                    AND invlog.type = 'PCS'
                    AND invlog.source = g_opi_cpcs_source
                  GROUP BY
                    cpcs.organization_id,
                    nvl(cpcs.subinventory_code, -1),
                    cpcs.inventory_item_id,
                    TRUNC(oap.SCHEDULE_CLOSE_DATE)
                ) cpcs_rbk,
                (
                SELECT /*+ use_hash(f, invlog) parallel(f) parallel(invlog) */
                    f.organization_id,
                    nvl(f.subinventory_code, -1) subinventory_code,
                    f.inventory_item_id,
                    invlog.transaction_date transaction_date,
                    sum(onhand_value_b) dbi_onhand_value_b,
                    sum(intransit_value_b) dbi_intransit_value_b
                  FROM
                    opi_dbi_inv_value_f f,
                    opi_dbi_inv_value_log invlog
                  WHERE f.organization_id = invlog.organization_id
                    AND f.transaction_date < invlog.transaction_date + 1 -- include all txns on CPCSD First Period close date too
                    AND invlog.uncosted_trx_id = -99 -- Indicates that the organization needs lump-sum adjustment processing
                    AND invlog.TYPE = 'PCS'
                    AND invlog.source = g_opi_cpcs_source
                  GROUP BY
                    f.organization_id,
                    nvl(f.subinventory_code, -1),
                    f.inventory_item_id,
                    invlog.transaction_date
                ) dbi_itd
              WHERE cpcs_rbk.organization_id (+) = dbi_itd.organization_id  /* Outer join for items that have a balance in DBI but not in CPCS */
                AND cpcs_rbk.subinventory_code (+) = dbi_itd.subinventory_code
                AND cpcs_rbk.inventory_item_id (+) = dbi_itd.inventory_item_id
                AND cpcs_rbk.transaction_date (+) = dbi_itd.transaction_date
                AND (nvl(cpcs_onhand_value_b, 0) - dbi_onhand_value_b
                        <> 0
                     OR
                     nvl(cpcs_intransit_value_b, 0) - dbi_intransit_value_b
                        <> 0);

            BIS_COLLECTION_UTILITIES.put_line(TO_CHAR(SQL%ROWCOUNT) || ' First Period Close Adjustment rows have been inserted into staging tables.');

            -- Set organizations to "lump-sum adjustment has been processed"
            -- status.
            -- Also, set the from_transaction_date to the be the
            -- transaction_Date, and make the transaction_Date null.
            -- We will use the from_transaction_date as the starting
            -- bound for all regular adjustments.
            -- See bug 4285814.
            UPDATE opi_dbi_inv_value_log
            SET uncosted_trx_id = null,
                from_transaction_date = transaction_date,
                transaction_date = NULL
              WHERE uncosted_trx_id = -99
              AND type = 'PCS'
              AND source = g_opi_cpcs_source;

            commit;

            BIS_COLLECTION_UTILITIES.put_line('Finished First Period Close Adjustments load.');
            -- First lump-sum adjustment has finished

        END IF;

    END IF;


    -- Regular adjustments process
    -- Update DBI INV log PCS rows for existing organizations
    -- Insert new DBI Inv log PCS rows for new organizations
    l_status := 'Regular adjustment';
    l_stmt_num := 40;
    MERGE INTO OPI_DBI_INV_VALUE_LOG log
    USING
    (
        SELECT
            cpcs.Organization_id,
            -99.99 transaction_id,
            trunc(max(oap.schedule_close_date)) transaction_date, -- To period end date
            trunc(min(oap.schedule_close_date)) from_transaction_date, -- From period end date
            'PCS' type,
            g_opi_cpcs_source source,
            g_sysdate creation_date,
            g_sysdate last_update_date,
            g_created_by created_by,
            g_last_updated_by last_updated_by,
            g_last_update_login last_update_login
        FROM
            cst_period_close_summary cpcs,
            org_acct_periods oap,
            OPI_DBI_INV_VALUE_LOG invlog
        WHERE
            cpcs.acct_period_id = oap.acct_period_id
        AND cpcs.organization_id = oap.organization_id
        AND oap.summarized_flag ='Y'
        AND cpcs.organization_id = invlog.organization_id (+)
        AND oap.schedule_close_date > nvl(invlog.from_transaction_date, oap.schedule_close_date - 1) -- periods after the last period processed
        AND invlog.type = 'PCS'
        AND invlog.source = g_opi_cpcs_source
        GROUP BY cpcs.Organization_id
    ) stg
    ON
        (log.organization_id = stg.organization_id
        and log.type = stg.type
        and log.source = stg.source)
    WHEN MATCHED THEN
    UPDATE SET
          log.transaction_date = stg.transaction_date,
          log.from_transaction_date = stg.from_transaction_date,
          log.last_update_date = stg.last_update_date,
          log.last_updated_by = stg.last_updated_by,
          log.last_update_login = stg.last_update_login,
          log.uncosted_trx_id = -99  -- Indicates Indicates that the organization needs regular adjustment processing
    WHEN NOT MATCHED THEN
    INSERT
         (organization_id,
          transaction_id,
          transaction_date,
          from_transaction_date,
          uncosted_trx_id,
          type,
          source,
          creation_date,
          last_update_date,
          created_by,
          last_updated_by,
          last_update_login)
    VALUES
         (
          stg.organization_id,
          stg.transaction_id,
          stg.transaction_date,
          stg.from_transaction_date,
          -99, -- indicates that the organization needs regular adjustment processing
          stg.type,
          stg.source,
          stg.creation_date,
          stg.last_update_date,
          stg.created_by,
          stg.last_updated_by,
          stg.last_update_login
         );

    -- Commit these bounds. The commit is required because of the parallel
    -- access of the inventory value log. Parallel slaves are separate
    -- sessions and can only see the table data once committed.
    -- See bug 4285814.
    -- However, we will update the from_transaction_date only after
    -- successfully inserting into the fact table so no date ranges
    -- will be ignored in case the program fails.
    commit;

    -- Figure out if there are any rows, from the SQL above, or from
    -- an errored out run from last time that require adjustments.
    l_dbilog_rows := 0;
    SELECT count (*)
    INTO l_dbilog_rows
      FROM opi_dbi_inv_value_log
      WHERE type = 'PCS'
        AND source = g_opi_cpcs_source
        AND uncosted_trx_id = -99;

    IF l_dbilog_rows > 0 THEN

        -- Insert new regular adjustments into
        -- inventory onhand and intransit staging tables
        l_stmt_num := 50;
        BIS_COLLECTION_UTILITIES.put_line('Started Period Close Regular Adjustments load.');

        INSERT ALL
        WHEN onhand_value_b <> 0
            THEN INTO opi_dbi_onhand_stg
                (organization_id, inventory_item_id, transaction_date,
                onhand_value_b, source, subinventory_code,
                creation_date, last_update_date, created_by,
                last_updated_by, last_update_login)
            VALUES
                (organization_id, inventory_item_id, transaction_date,
                onhand_value_b, source, subinventory_code,
                creation_date, last_update_date, created_by,
                LAST_UPDATED_BY, LAST_UPDATE_LOGIN)
        WHEN intransit_value_b <> 0
            THEN INTO opi_dbi_intransit_stg
                (organization_id, inventory_item_id, transaction_date,
                intransit_value_b, source,
                creation_date, last_update_date, created_by,
                last_updated_by, last_update_login)
            VALUES
                (organization_id, inventory_item_id, transaction_date,
                intransit_value_b, source,
                creation_date, last_update_date, created_by,
                last_updated_by, last_update_login)
        SELECT /*+ use_hash(cpcs, oap, invlog)
                   parallel(cpcs) parallel(oap) parallel(invlog) */
            cpcs.organization_id,
            nvl(cpcs.subinventory_code, -1) subinventory_code,
            cpcs.inventory_item_id,
            trunc(oap.SCHEDULE_CLOSE_DATE) transaction_date,
            sum(rollback_onhand_value - accounted_onhand_value)
                onhand_value_b,  -- Onhand adjustment
            sum(rollback_intransit_value - accounted_intransit_value)
                INTRANSIT_VALUE_B, -- Intransit adjustment
            g_opi_cpcs_source source,
            g_sysdate creation_date,
            g_sysdate last_update_date,
            g_created_by created_by,
            g_last_updated_by last_updated_by,
            g_last_update_login last_update_login
          FROM
             cst_period_close_summary cpcs,
             org_acct_periods oap,
             opi_dbi_inv_value_log invlog
          WHERE cpcs.acct_period_id = oap.acct_period_id
            AND cpcs.organization_id = oap.organization_id
            AND oap.summarized_flag ='Y'
            AND cpcs.organization_id = invlog.organization_id
            AND oap.schedule_close_date >= invlog.from_transaction_date
            AND oap.schedule_close_date <= invlog.transaction_date
            AND invlog.type = 'PCS'
            AND invlog.uncosted_trx_id = -99 -- Indicates that the organization needs regular adjustment processing
            AND invlog.source = g_opi_cpcs_source
            AND (   rollback_onhand_value - accounted_onhand_value <> 0
                 OR rollback_intransit_value - accounted_intransit_value <> 0)
          GROUP BY
             cpcs.organization_id,
             nvl(cpcs.SUBINVENTORY_CODE, -1),
             cpcs.inventory_item_id,
             trunc(oap.SCHEDULE_CLOSE_DATE)
          HAVING
             sum(rollback_onhand_value - accounted_onhand_value) <> 0
             or
             sum(rollback_intransit_value - accounted_intransit_value) <>0;

        BIS_COLLECTION_UTILITIES.put_line(TO_CHAR(SQL%ROWCOUNT) || ' Period Close Regular Adjustment rows have been inserted into staging tables.');
        BIS_COLLECTION_UTILITIES.put_line('Finished Period Close Regular Adjustments load.');

        -- Do not update bounds until data has been inserted into the fact.
        -- Basically bounds update and data merging to the fact must
        -- happen in the same database transaction.
        -- See procedure merge_into_summary in this file.

        commit;

    ELSE
        BIS_COLLECTION_UTILITIES.put_line(
            'There were no Regular Adjustments to load.');
    END IF;


    -- Finished Period Close Adjustment process
    BIS_COLLECTION_UTILITIES.put_line('End of Period Close Adjustments load.');
    return g_ok;

EXCEPTION
    WHEN OTHERS THEN
        rollback;
        BIS_COLLECTION_UTILITIES.put_line('Failed during collecting data for ' || l_status || '.');
        l_err_num := SQLCODE;
        BIS_COLLECTION_UTILITIES.PUT_LINE('Error Number: ' ||  to_char(l_err_num));
        l_err_msg := 'OPI_DBI_INV_CPCS_PKG.INSERT_ADJUSTMENTS - Error at statement ('
                         || to_char(l_stmt_num)
                         || '): '
                         || substr(SQLERRM, 1,200);
        BIS_COLLECTION_UTILITIES.PUT_LINE('Error Message: ' || l_err_msg);

        retcode := SQLCODE;
        errbuf := SQLERRM;
        return g_error;

END INSERT_ADJUSTMENTS;



PROCEDURE Run_Period_Close_Adjustment (
    errbuf  IN OUT NOCOPY VARCHAR2,
    retcode IN OUT NOCOPY VARCHAR2
)
IS
    l_rows1 NUMBER;
BEGIN

    l_rows1 := 0;
    retcode := 0;
    errbuf := NULL;

    -- Global variable initialization
    g_sysdate := sysdate;
    g_created_by := fnd_global.user_id;
    g_last_update_login := fnd_global.login_id;
    g_last_updated_by := fnd_global.user_id;
    g_global_start_date := SYSDATE;


    BIS_COLLECTION_UTILITIES.PUT_LINE('==================================================================================');
    BIS_COLLECTION_UTILITIES.put_line('Period Close Adjustments Collection started at ' || TO_CHAR(g_sysdate, 'DD-MON-YYYY HH24:MI:SS'));

    BEGIN
        SELECT BIS_COMMON_PARAMETERS.GET_GLOBAL_START_DATE
        INTO g_global_start_date
          FROM DUAL;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            BIS_COLLECTION_UTILITIES.put_line('Global start date is not available. Cannot proceed.');
            BIS_COLLECTION_UTILITIES.put_line(SQLERRM);
            retcode := SQLCODE;
            errbuf := SQLERRM;
            return;
    END;

    -- Period Close Adjustment process
    IF (Insert_Adjustments(errbuf, retcode) = g_error) THEN
        BIS_COLLECTION_UTILITIES.put_line('Failed to collect adjustments into staging tables.');
        INSERT INTO opi_dbi_inv_value_log
        (organization_id, transaction_id, transaction_date, type,
        source, creation_date, last_update_date, created_by,
        last_updated_by, last_update_login
        )
        VALUES
        (-1, -1, g_sysdate, 'ERR',
        g_opi_cpcs_source, g_sysdate, g_sysdate, g_created_by,
        g_last_updated_by, g_last_update_login);

        commit;
        return;
    ELSE
        DELETE
          FROM opi_dbi_inv_value_log
          WHERE type = 'ERR'
            AND source = g_opi_cpcs_source;
        commit;
    END IF;

    /* CPCS is called after conversion is done in inventory and also
     * after staging tables are cleaned up. So CPCS is on its own and
     * does not depend on inventory for conversion and Merge into
     * fact.
     */

    IF (OPI_DBI_INV_VALUE_UTL_PKG.Get_Conversion_Rate (errbuf, retcode) =
        g_error) THEN
        BIS_COLLECTION_UTILITIES.put_line('Missing currency rate.');
        BIS_COLLECTION_UTILITIES.put_line('Please run the concurrent program: Initial Load - Update Inventory Value and Turns Base Summary, after fixing missing currency rates.');

        -- If Incremental is run, the program will first try to fix the currency rates, then merge the stg tables into the summary table and then start the new incremental load
        retcode := g_error;
        return;
    ELSE
        BIS_COLLECTION_UTILITIES.put_line('All currency conversion rates were found.');
        commit;
    END IF;

    l_rows1 := Merge_Into_Summary (errbuf, retcode);
    IF (l_rows1 = g_error) THEN
        BIS_COLLECTION_UTILITIES.put_line(
            'Failed to merge data from staging table to base table.');
        BIS_COLLECTION_UTILITIES.put_line('Please run the concurrent program: Update Inventory Value and Turns Base Summary, to try finishing this process.');

        -- If Incremental is run, the program will and add rows to the stg tables, and at the end will merge old and new rows into the summary table
        BIS_COLLECTION_UTILITIES.put_line('Warning: If you decide to run the Initial Load - Update Inventory Value and Turns Base Summary again, the entire process will start over again.');
        return;
    END IF;

    IF (Clean_Staging_Table (errbuf, retcode) = g_error) THEN
        BIS_COLLECTION_UTILITIES.put_line('Failed to clean staging tables.');
        INSERT INTO opi_dbi_inv_value_log
        (organization_id, transaction_id, transaction_date, type,
         source, creation_date, last_update_date, created_by, last_updated_by,
         last_update_login
        )
        VALUES
        (-1, -1, g_sysdate, 'CLR', 1, g_sysdate, g_sysdate, g_created_by,
         g_last_updated_by, g_last_update_login);
        commit;
        return;
    END IF;

    commit;

    BIS_COLLECTION_UTILITIES.put_line(TO_CHAR(l_rows1) || ' rows have been inserted into fact table from discrete/manufacturing organizations.');
    BIS_COLLECTION_UTILITIES.put_line('Period Close Adjustments Collection finished at ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
    BIS_COLLECTION_UTILITIES.PUT_LINE('==================================================================================');
    return;

EXCEPTION
    WHEN OTHERS THEN
        BIS_COLLECTION_UTILITIES.put_line('Period close adjustments process failed.');
        BIS_COLLECTION_UTILITIES.put_line(SQLERRM);
        retcode := SQLCODE;
        errbuf := SQLERRM;
        RAISE_APPLICATION_ERROR(-20000,errbuf);

END Run_Period_Close_Adjustment;



END OPI_DBI_INV_CPCS_PKG;

/
