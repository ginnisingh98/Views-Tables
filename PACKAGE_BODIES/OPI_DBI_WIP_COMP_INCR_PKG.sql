--------------------------------------------------------
--  DDL for Package Body OPI_DBI_WIP_COMP_INCR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_WIP_COMP_INCR_PKG" AS
/*$Header: OPIDCOMPLRB.pls 120.0 2005/05/24 18:25:23 appldev noship $ */

/*++++++++++++++++++++++++++++++++++++++++*/
/* Function and procedure declarations in this file but not in spec*/
/*++++++++++++++++++++++++++++++++++++++++*/

PROCEDURE collect_incr_opi_wip_comp (errbuf OUT NOCOPY VARCHAR2,
                                     retcode OUT NOCOPY NUMBER,
                                     p_global_start_date IN DATE);

PROCEDURE update_wip_comp_fact_incr (errbuf OUT NOCOPY VARCHAR2,
                                     retcode OUT NOCOPY NUMBER);

/*----------------------------------------*/

/*  All DBI ETLs have a numeric ETL ID for identification. For
    WIP Completions, the ID is 1. */
WIP_COMPLETION_ETL CONSTANT NUMBER := 1;    -- WIP completions

/*  All ETLs can have one of two sources: */
OPI_SOURCE CONSTANT NUMBER := 1;
OPM_SOURCE CONSTANT NUMBER := 2;


/* Non planned items have an mrp_planning_code of 6 */
NON_PLANNED_ITEM CONSTANT NUMBER := 6;

/* The WIP valuation account is accouting line type 7 */
WIP_VALUATION_ACCT CONSTANT NUMBER := 7;

/* Standard Jobs have Job type of 1 */
WIP_DISCRETE_STANDARD_JOB CONSTANT NUMBER := 1;

/* Following entity types need to be collected */
WIP_DISCRETE_JOB CONSTANT NUMBER := 1;
WIP_REPETITIVE_ASSEMBLY_JOB CONSTANT NUMBER := 2;
WIP_CLOSED_DISCRETE_JOB CONSTANT NUMBER := 3;
WIP_FLOW_SCHEDULE_JOB CONSTANT NUMBER := 4;

/*++++++++++++++++++++++++++++++++++++++++*/
/* PACKAGE LEVEL CONSTANTS */
/*++++++++++++++++++++++++++++++++++++++++*/

s_pkg_name CONSTANT VARCHAR2 (50) := 'opi_dbi_wip_comp_incr_pkg';
s_ERROR CONSTANT NUMBER := -1;   -- concurrent manager error code
s_WARNING CONSTANT NUMBER := 1;  -- concurrent manager warning code
s_SUCCESS CONSTANT NUMBER := 0;  -- concurrent manager success code


/*++++++++++++++++++++++++++++++++++++++++*/
/*  Package level variables for session info-
    including schema name for truncating and
    collecting stats */
/*++++++++++++++++++++++++++++++++++++++++*/

s_opi_schema      VARCHAR2(30);
s_status          VARCHAR2(30);
s_industry        VARCHAR2(30);

/*----------------------------------------*/

/*++++++++++++++++++++++++++++++++++++++++*/
/*  Package level variables for the logged
    in user.
/*++++++++++++++++++++++++++++++++++++++++*/

s_user_id NUMBER;
s_login_id NUMBER;

/*----------------------------------------*/

/*++++++++++++++++++++++++++++++++++++++++*/
/*  Package level exceptions defined for
    clearer error handling. */
/*++++++++++++++++++++++++++++++++++++++++*/

-- exception to raise if unable to get schema information
schema_info_not_found EXCEPTION;
PRAGMA EXCEPTION_INIT (schema_info_not_found, -20000);

-- exception to raise if one or both of OPI and OPM data extraction
-- fails
data_extraction_failed EXCEPTION;
PRAGMA EXCEPTION_INIT (data_extraction_failed, -20001);

-- exception to throw if user needs to run common module incremental
-- or initial load again - e.g. if bounds have not been set up correctly.
run_common_module EXCEPTION;
PRAGMA EXCEPTION_INIT (run_common_module, -20002);

-- exception to raise if DBI global currency code not found
global_curr_code_not_found EXCEPTION;
PRAGMA EXCEPTION_INIT (global_curr_code_not_found, -20003);

-- exception to raise if missing conversion rates exist
missing_conversion_rates EXCEPTION;
PRAGMA EXCEPTION_INIT (missing_conversion_rates, -20004);

-- exception to raise unable to log successful data extraction to
-- log table.
could_not_log_success EXCEPTION;
PRAGMA EXCEPTION_INIT (could_not_log_success, -20005);

-- exception to raise if global parameters such as global
-- start date and global currency code are not available
global_setup_missing EXCEPTION;
PRAGMA EXCEPTION_INIT (global_setup_missing, -20006);

-- exception to raise if it is not time for the incremental load to run
-- i.e. the initial load has not been run yet
cannot_run_incr_load EXCEPTION;
PRAGMA EXCEPTION_INIT (cannot_run_incr_load, -20007);


/*----------------------------------------*/

/*  collect_wip_completions_incr

    Wrapper routine for OPI + OPM wip completion data extraction for
    incremental load.

    When this routine runs, the staging table is not guaranteed to be
    empty, because there might be data left over from an errored-out
    incremental run. So do not truncate any tables at start.

    Both OPI and OPM ETLs can run independently upto the staging table level,
    even if the other fails. That way, errors found in extracting OPI and OPM
    data in the incremental run can be reported simultaneously.

    If either OPI or OPM fails before the staging table level, then the
    routine ends with error.

    If not, then conversion rates have to be calculated for
    all the OPI and OPM data in the staging table.

    If all conversion rates are found, data is merged to the fact table,
    following which the staging table can be truncated.

    This wrapper will only commit data implicitly through the DDL that
    truncates the staging table. That way, it ensures that the merge is
    committed and the staging table is emptied simultaneously. We cannot
    avoid this by truncating the staging table at the start of the function,
    since it might have data from a previous run that failed half way. That
    data will never be recollected and should not be thrown away.

    This function does not return with an exception in case of error
    but ends with a retcode of error. However helper functions are
    expected to throw exceptions. We do not look at the retcode/errbuf
    for helper functions. If a helper function fails, it is expected
    to write a error message to the log and to throw an exception
    back to this wrapper function.

    Date            Author              Action
    04/23/2003      Dinkar Gupta        Wrote procedure

*/

PROCEDURE collect_wip_completions_incr (errbuf OUT NOCOPY VARCHAR2,
                                        retcode OUT NOCOPY NUMBER)
IS

    l_proc_name CONSTANT VARCHAR2 (60) := 'collect_wip_completions_incr';
    l_stmt_id NUMBER;

    l_opi_success BOOLEAN;     -- OPI extraction successful?
    l_opm_success BOOLEAN;     -- OPM extraction successful?

    l_global_start_date DATE;

BEGIN

    -- initialization block
    l_stmt_id := 0;
    l_opi_success := false;
    l_opm_success := false;
    l_global_start_date := NULL;

    -- session parameters
    l_stmt_id := 5;
    s_user_id := nvl(fnd_global.user_id, -1);
    s_login_id := nvl(fnd_global.login_id, -1);


    -- get session parameters
    l_stmt_id := 10;
    IF (NOT (fnd_installation.get_app_info('OPI', s_status, s_industry,
                                           s_opi_schema))) THEN
        RAISE schema_info_not_found;
    END IF;

    -- check if the global set up is good
    l_stmt_id := 11;
    IF (NOT (opi_dbi_wip_comp_init_pkg.check_global_setup ())) THEN
        RAISE global_setup_missing;
    END IF;

    -- get the DBI global start date
    l_stmt_id := 20;
    l_global_start_date := trunc (bis_common_parameters.get_global_start_date);

    -- Collect the WIP completions for OPI
    BEGIN

        l_stmt_id := 30;
        -- COMMIT DATA AS NEEDED!!! WRAPPER WILL NOT COMMIT DATA FOR
        -- STAGING TABLE.
        collect_incr_opi_wip_comp (errbuf, retcode, l_global_start_date);
        -- OPI collection into staging table successful
        l_stmt_id := 40;
        l_opi_success := true;

    EXCEPTION

        WHEN OTHERS THEN
            rollback;

            -- opi data was not found successfully
            l_opi_success := false;

            BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                               l_proc_name || ' ' ||
                                               '#' || l_stmt_id ||
                                               ': ' ||  SQLERRM);
            BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                               l_proc_name || ' ' ||
                                               '#' || l_stmt_id || ': ' ||
                                 'Unable to collect OPI WIP completions data in incremental load into staging table.');

    END;

    -- Collect the WIP completions for OPM
    BEGIN


        l_stmt_id := 50;
        -- COMMIT DATA AS NEEDED!!! WRAPPER WILL NOT COMMIT DATA FOR
        -- STAGING TABLE.
        opi_dbi_wip_comp_opm_pkg.collect_incr_opm_wip_comp (errbuf, retcode,
                                                          l_global_start_date);
        -- OPM collection into staging table successful
        l_stmt_id := 60;
        l_opm_success := true;

    EXCEPTION

        WHEN OTHERS THEN
            rollback;

            -- opm data was not found successfully
            l_opm_success := false;

            BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                               l_proc_name || ' ' ||
                                               '#' || l_stmt_id ||
                                               ': ' ||  SQLERRM);
            BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                               l_proc_name || ' ' ||
                                               '#' || l_stmt_id || ': ' ||
                                 'Unable to collect OPM WIP completions data in incremental load into staging table.');

    END;


    -- If either OPI or OPM failed, then abort here
    l_stmt_id := 70;
    IF (NOT (l_opi_success AND l_opm_success)) THEN
        RAISE data_extraction_failed;
    END IF;

    -- Compute the conversions rates for all the data in the staging table.
    -- Use the same function as the initial load since conversion rate
    -- computation is identical.
    -- COMMIT DATA SO THAT THE ROLLBACK SEGMENT DOES BECOME TOO LARGE IN
    -- THE FUNCTION. WRAPPER ONLY COMMITS FOR FACT TABLE.
    l_stmt_id :=80;
    opi_dbi_wip_comp_init_pkg.compute_wip_comp_conv_rates (errbuf, retcode,
                                                           s_opi_schema);

    -- Merge all the data to the fact table.
    -- DO NOT COMMIT DATA IN THIS ONE FUNCTION.
    -- LET THE WRAPPER COORDINATE THE LAST COMMIT.
    l_stmt_id := 90;
    update_wip_comp_fact_incr (errbuf, retcode);

    -- Finally truncate the staging table if we have got this far, because
    -- all data in the fact.
    -- The truncate will implicitly also commit data to the fact table.
    -- This is important because the staging table is "persistent" i.e.
    -- failures midway do not cause data stored in the staging table to be
    -- deleted and data once collected in staging table is not collected
    -- again. So it is imperative the commit on the fact table and
    -- truncate on staging table happen as one operation.
    l_stmt_id := 100;
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
                       'OPI_DBI_WIP_COMP_STG');

    l_stmt_id := 110;
    BIS_COLLECTION_UTILITIES.PUT_LINE
        ('WIP Completions Incremental load terminated successfully.');
    retcode := s_SUCCESS;
    errbuf := '';
    return;

EXCEPTION

    WHEN schema_info_not_found THEN
        rollback;

        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id ||
                                           ': ' ||  SQLERRM);

        retcode := s_ERROR;
        errbuf := s_pkg_name || '.' || l_proc_name || ' ' || '#' ||
                  l_stmt_id || ': ' ||
                  'WIP Completion ETL Incremental Load failed to get OPI schema info.';
        return;

    WHEN global_setup_missing THEN
        rollback;

        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id ||
                                           ': ' ||  SQLERRM);

        retcode := s_ERROR;
        errbuf := s_pkg_name || '.' || l_proc_name || ' ' || '#' ||
                  l_stmt_id || ': ' ||
                  'WIP Completions Incremental Load could not find global setup of global start date and global currency code.';
        return;

    WHEN data_extraction_failed THEN
        rollback;

        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id ||
                                           ': ' ||  SQLERRM);

        retcode := s_ERROR;
        errbuf := s_pkg_name || '.' || l_proc_name || ' ' || '#' ||
                  l_stmt_id || ': ' ||
                  'WIP Completion Incremental Load data extraction failed for OPI, OPM or both. Check previous messages for errors. ';
        return;

    WHEN OTHERS THEN
        rollback;

        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id ||
                                           ': ' ||  SQLERRM);

        retcode := s_ERROR;
        errbuf := s_pkg_name || '.' || l_proc_name || ' ' || '#' ||
                  l_stmt_id || ': ' ||
                  'WIP Completion ETLs Incremental load Failed.';
        return;


END collect_wip_completions_incr;


/*  collect_incr_opi_wip_comp

    Incremental collection of WIP completion data from MMT/MTA for discrete
    (OPI) organizations.

    Collected transactions must be past the global start for every discrete
    organization and lie in the  transaction range recorded in the current
    log table,  OPI_DBI_RUN_LOG_CURR. The collection therefore proceeds to
    extract every transaction per discrete org upto the first uncosted
    transaction.

    To ensure that the bounds are good, we call the incr_end_bounds_setup API
    from the Common Module Incremental load.

    Data is not committed to the staging table until the bounds in the
    current log table have been updated successfully using the Common Module
    API etl_report_success.

    WIP Completions ETL needs to extract two types of transactions from
    MMT:

    44 - WIP completion transaction increases the quantity/value
         of WIP completions
    17 - Assembly return transaction decreases the quantity/value of
         of WIP completions.

    The WIP valuation account has an accounting line type of 7 in MTA, but
    the WIP valuation account decreases on WIP completions and increases
    on assembly returns. Thus for every transaction, the corresponding
    value we pick is -1 * (sum of all accouting line type 7) because this
    ETL must report increases completion value on completions and decreased
    value on returns.


    Parameters:
    p_global_start_date - global start date for DBI collection.
                          Expect this to be trunc'ed

    Date            Author              Action
    04/23/2003      Dinkar Gupta        Wrote procedure

*/

PROCEDURE collect_incr_opi_wip_comp (errbuf OUT NOCOPY VARCHAR2,
                                     retcode OUT NOCOPY NUMBER,
                                     p_global_start_date IN DATE)
IS

    l_proc_name CONSTANT VARCHAR2 (60) := 'collect_incr_opi_wip_comp';
    l_stmt_id NUMBER;

BEGIN

    -- initialization block
    l_stmt_id := 0;

    -- Check if all the bounds have been properly set up
    l_stmt_id := 10;
    IF (NOT (opi_dbi_common_mod_incr_pkg.incr_end_bounds_setup
                (WIP_COMPLETION_ETL, OPI_SOURCE))) THEN
        RAISE run_common_module;
    END IF;

    l_stmt_id := 15;
    -- check if it is ok to run incremental load
    IF (NOT (opi_dbi_common_mod_incr_pkg.run_incr_load
                (WIP_COMPLETION_ETL, OPI_SOURCE))) THEN
        RAISE cannot_run_incr_load;
    END IF;

    -- If all bounds have been set up, extract all the data.
    -- The data is simply inserted into the staging table,
    -- which means that the org-item-date key may no longer remain unique
    -- if there was data from an prior run that errored out too
    -- after extracting data.
    --
    -- WIP completions transactions (MMT type 44) cause WIP completion
    -- quantity/value to increase.
    -- Assembly return transactions (MMT type 17) cause WIP completion
    -- quantity/value to decrease.
    --
    -- MTA accounting line type 7 represents the WIP valuation account.
    -- Since the WIP account decreases on completions and increases on
    -- returns, we need to use -1 * value from MTA.
    --
    -- The join to MTA has to be an outer join since MTA does not
    -- have any rows for expense items.
    --
    -- Note also that the inner query groups on mmt.transaction_id.
    -- This is to ensure that all MTA rows for an MMT entry are
    -- summed before quantity is summed, else we miscount quantity.
    --
    -- In addition, exclude all non standard discrete jobs. Discrete jobs
    -- have an entity_type = 1 and standard jobs have a job_type = 1.
    -- entity_type and job_type are both not null columns, so it is safe
    -- to outer join and NVL to them.
    --
    -- Because of OSFM etc. we pick only the following types of jobs:
    -- Discrete Jobs
    -- Repetitive Assemblies
    -- Closed discrete Jobs
    -- Flow Schedules.

    l_stmt_id := 20;
    INSERT /*+ append */
    INTO opi_dbi_wip_comp_stg (
        organization_id,
        inventory_item_id,
        transaction_date,
        completion_quantity,
        completion_value_b,
        uom_code,
        source,
        planned_item,
        creation_date,
        last_update_date,
        created_by,
        last_updated_by,
        last_update_login)
    SELECT
        compl.organization_id,
        compl.inventory_item_id,
        compl.trx_date,
        sum (compl.mmt_quantity),
        sum (compl.mta_value),
        msi.primary_uom_code,
        OPI_SOURCE,             -- this is only for OPI orgs
        decode (msi.mrp_planning_code,
                NON_PLANNED_ITEM, 'N',
                'Y'),
        sysdate,
        sysdate,
        s_user_id,
        s_user_id,
        s_login_id
      FROM mtl_system_items_b msi,
        (SELECT /*+ leading(log) use_nl(log mmt) index(log, OPI_DBI_RUN_LOG_CURR_N1) index(mmt, mtl_material_transactions_u1) */
            mmt.organization_id,
            mmt.inventory_item_id,
            trunc (mmt.transaction_date) trx_date,
            mmt.primary_quantity mmt_quantity,
            -1 * sum (nvl (mta.base_transaction_value, 0)) mta_value
          FROM  mtl_material_transactions mmt,
                mtl_transaction_accounts mta,
                wip_entities we,
                wip_discrete_jobs wdj,
                opi_dbi_run_log_curr log
          WHERE log.source = OPI_SOURCE
            AND log.etl_id = WIP_COMPLETION_ETL
            AND mmt.organization_id = log.organization_id
            AND mmt.transaction_id >= log.start_txn_id
            AND mmt.transaction_id < log.next_start_txn_id
            AND mmt.transaction_date >= p_global_start_date  -- (date trunc'ed)
            AND mmt.transaction_type_id IN (44, 17)
            AND mta.transaction_id(+) = mmt.transaction_id
            AND nvl (mta.accounting_line_type, WIP_VALUATION_ACCT) =
                WIP_VALUATION_ACCT
            AND we.wip_entity_id = mmt.transaction_source_id
            AND we.entity_type IN (WIP_DISCRETE_JOB,
                                   WIP_REPETITIVE_ASSEMBLY_JOB,
                                   WIP_CLOSED_DISCRETE_JOB,
                                   WIP_FLOW_SCHEDULE_JOB)
            AND wdj.wip_entity_id(+) = we.wip_entity_id
            AND nvl (wdj.job_type, WIP_DISCRETE_STANDARD_JOB) =
                    WIP_DISCRETE_STANDARD_JOB
          GROUP BY  mmt.organization_id,
                    mmt.inventory_item_id,
                    trunc (mmt.transaction_date),
                    mmt.primary_quantity,
                    mmt.transaction_id) compl
      WHERE msi.organization_id = compl.organization_id
        AND msi.inventory_item_id = compl.inventory_item_id
      GROUP BY
        compl.organization_id,
        compl.inventory_item_id,
        compl.trx_date,
        msi.primary_uom_code,
        decode (msi.mrp_planning_code,
                NON_PLANNED_ITEM, 'N',
                'Y');

    -- If the entire collection was successful, then try and report this
    -- success to the OPI_DBI_RUN_LOG_CURR.
    l_stmt_id := 30;
    IF (NOT (opi_dbi_common_mod_incr_pkg.etl_report_success
                (WIP_COMPLETION_ETL, OPI_SOURCE))) THEN

        RAISE could_not_log_success;
    END IF;

    -- Since data pushed to staging table and success logged, commit
    -- everything
    l_stmt_id := 40;
    commit;

    -- all done, so return successfully.
    l_stmt_id := 50;
    retcode := s_SUCCESS;
    errbuf := '';
    return;

EXCEPTION

    WHEN could_not_log_success THEN
        rollback;

        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id || ': ' ||
                              'WIP Completion ETLs Incremental load OPI data extraction success could not be logged into log table. Aborting.');

        retcode := s_ERROR;
        errbuf := s_pkg_name || '.' || l_proc_name || ' ' || '#' ||
                  l_stmt_id || ': ' ||
                  'WIP Completion ETLs Incremental load OPI data extraction success could not be logged into log table. Aborting.';
        RAISE;  -- propagate exception to wrapper.


    WHEN cannot_run_incr_load THEN
        rollback;
        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id || ': ' ||
                              'WIP Completion incremental load concurrent program should not be running.
If the initial load request set has already been run successfully, please submit the incremental load request set. If not, please run the initial load request set.');

        retcode := s_ERROR;
        errbuf := s_pkg_name || '.' || l_proc_name || ' ' || '#' ||
                  l_stmt_id || ': ' ||
                  'WIP Completion incremental load concurrent program should not be running.
If the initial load request set has already been run successfully, please submit the incremental load request set. If not, please run the initial load request set.';
        RAISE;  -- propagate exception to wrapper.

    WHEN run_common_module THEN
        rollback;
        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id || ': ' ||
                              'WIP Completions incremental load concurrent program is running out of turn. Please submit the incremental load request set for incremental data collection.');

        retcode := s_ERROR;
        errbuf := s_pkg_name || '.' || l_proc_name || ' ' || '#' ||
                  l_stmt_id || ': ' ||
                  'WIP Completions incremental load concurrent program is running out of turn. Please submit the incremental load request set for incremental data collection.';
        RAISE;  -- propagate exception to wrapper.


    WHEN OTHERS THEN
        rollback;

        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id ||
                                           ': ' ||  SQLERRM);

        retcode := s_ERROR;
        errbuf := s_pkg_name || '.' || l_proc_name || ' ' || '#' ||
                  l_stmt_id || ': ' ||
                  'WIP Completion ETLs Incremental load OPI data extraction failed.';
        RAISE;  -- propagate exception to wrapper.

END collect_incr_opi_wip_comp;

/*  update_wip_comp_fact_incr

    MERGE data from the staging table to the fact table since the fact
    table already has some data in it.


    The granularity of the staging table will item-org-transaction_date
    and implicitly the source, since an org is never discrete and
    process at the same time.

    The item-org-date key will be unique at the fact level.

    THIS FUNCTION WILL NOT COMMIT ANY DATA, SINCE THE WRAPPER IS
    TAKING RESPONSIBILITY FOR COMMITTING DATA TO THE FACT TABLE.

    Date            Author              Action
    04/23/2003      Dinkar Gupta        Wrote procedure
    08/25/2004      Dinkar Gupta        Secondary Currency Support
*/

PROCEDURE update_wip_comp_fact_incr (errbuf OUT NOCOPY VARCHAR2,
                                     retcode OUT NOCOPY NUMBER)
IS

    l_proc_name CONSTANT VARCHAR2 (60) := 'update_wip_comp_fact_incr';
    l_stmt_id NUMBER;


BEGIN

    -- initialization block
    l_stmt_id := 0;

    -- Merge data into fact table while
    -- grouping by item-org-transaction_date and source.
    --
    -- The merge is essential because there is already data in
    -- the fact table from previous runs, and backdated transactions
    -- could mean that the staging table has the same item-org-date
    -- combination of an existing row in the fact table.
    l_stmt_id := 10;
    MERGE INTO opi_dbi_wip_comp_f base
    USING
        (SELECT /*+ use_nl(stg, conv) */
            stg.organization_id,
            stg.inventory_item_id,
            stg.transaction_date,
            sum (stg.completion_quantity) completion_qty,
            sum (stg.completion_value_b) completion_val,
            stg.uom_code,
            conv.conversion_rate,
            conv.sec_conversion_rate,
            stg.source,
            stg.planned_item,
            sysdate creation_date,
            sysdate update_date,
            s_user_id creator,
            s_user_id updator,
            s_login_id  update_login
          FROM opi_dbi_wip_comp_stg stg,
               opi_dbi_wip_comp_conv_rates conv
          WHERE stg.organization_id = conv.organization_id
            AND stg.transaction_date = conv.transaction_date
          GROUP BY  stg.organization_id,
                    stg.inventory_item_id,
                    stg.transaction_date,
                    stg.uom_code,
                    conv.conversion_rate,
                    conv.sec_conversion_rate,
                    stg.source,
                    stg.planned_item) new
    ON
        (    base.organization_id = new.organization_id
         AND base.inventory_item_id = new.inventory_item_id
         AND base.transaction_date = new.transaction_date
         AND base.source = new.source)
    WHEN MATCHED THEN UPDATE
        SET base.completion_value_b = base.completion_value_b +
                                      new.completion_val,
            base.completion_quantity = base.completion_quantity +
                                       new.completion_qty,
            base.last_update_date = new.update_date,
            base.last_updated_by = new.updator,
            base.last_update_login = new.update_login
    WHEN NOT MATCHED THEN INSERT(
            organization_id,
            inventory_item_id,
            transaction_date,
            completion_quantity,
            completion_value_b,
            uom_code,
            conversion_rate,
            sec_conversion_rate,
            source,
            planned_item,
            creation_date,
            last_update_date,
            created_by,
            last_updated_by,
            last_update_login)
        VALUES (
            new.organization_id,
            new.inventory_item_id,
            new.transaction_date,
            new.completion_qty,
            new.completion_val,
            new.uom_code,
            new.conversion_rate,
            new.sec_conversion_rate,
            new.source,
            new.planned_item,
            new.creation_date,
            new.update_date,
            new.creator,
            new.updator,
            new.update_login);

    -- merge successful, so return
    l_stmt_id := 20;
    retcode := s_SUCCESS;
    errbuf := '';
    return;

EXCEPTION

    WHEN OTHERS THEN
        rollback;

        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id ||
                                           ': ' ||  SQLERRM);

        retcode := s_ERROR;
        errbuf := s_pkg_name || '.' || l_proc_name || ' ' || '#' ||
                  l_stmt_id || ': ' ||
                  'WIP Completion ETLs Incremental merge to fact table failed.';
        RAISE;  -- propagate exception to wrapper.

END update_wip_comp_fact_incr;

END opi_dbi_wip_comp_incr_pkg;

/
