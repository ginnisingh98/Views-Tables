--------------------------------------------------------
--  DDL for Package Body OPI_DBI_WIP_SCRAP_INIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_WIP_SCRAP_INIT_PKG" AS
/*$Header: OPIDSCRAPIB.pls 120.0 2005/05/24 17:52:42 appldev noship $ */


/*++++++++++++++++++++++++++++++++++++++++*/
/* Function and procedure declarations in this file but not in spec*/
/*++++++++++++++++++++++++++++++++++++++++*/

PROCEDURE collect_init_opi_wip_scrap (errbuf OUT NOCOPY VARCHAR2,
                                      retcode OUT NOCOPY NUMBER,
                                      p_global_start_date IN DATE);

PROCEDURE update_wip_scrap_fact_init (errbuf OUT NOCOPY VARCHAR2,
                                      retcode OUT NOCOPY NUMBER);


/*----------------------------------------*/

/*  All DBI ETLs have a numeric ETL ID for identification. For
    WIP SCRAP, the ID is 1. */
WIP_SCRAP_ETL CONSTANT NUMBER := 2;    -- WIP Scrap

/*  All ETLs can have one of two sources.
    However, currently WIP Scrap only has OPI content.
*/
OPI_SOURCE CONSTANT NUMBER := 1;
OPM_SOURCE CONSTANT NUMBER := 2;


/* Non planned items have an mrp_planning_code of 6 */
NON_PLANNED_ITEM CONSTANT NUMBER := 6;

/* The WIP valuation account is accouting line type 7 */
WIP_VALUATION_ACCT CONSTANT NUMBER := 7;

/* Standard Jobs have Job type of 1 */
WIP_DISCRETE_STANDARD_JOB CONSTANT NUMBER:= 1;

/* Following entity types need to be collected */
WIP_DISCRETE_JOB CONSTANT NUMBER := 1;
WIP_REPETITIVE_ASSEMBLY_JOB CONSTANT NUMBER := 2;
WIP_CLOSED_DISCRETE_JOB CONSTANT NUMBER := 3;
WIP_FLOW_SCHEDULE_JOB CONSTANT NUMBER := 4;

/* EURO currency became official on 1st Jan 1999 */
EURO_START_DATE CONSTANT DATE := to_date ('01/01/1999', 'mm/dd/yyyy');

/* GL API returns -3 if EURO rate missing on 01-JAN-1999 */
EURO_MISSING_AT_START NUMBER := -3;

/*  Marker for secondary conv. rate if the primary and secondary curr codes
    and rate types are identical. Can't be -1, -2, -3 since the FII APIs
    return those values. */
C_PRI_SEC_CURR_SAME_MARKER CONSTANT NUMBER := -9999;

/*++++++++++++++++++++++++++++++++++++++++*/
/* PACKAGE LEVEL CONSTANTS */
/*++++++++++++++++++++++++++++++++++++++++*/

s_pkg_name CONSTANT VARCHAR2 (50) := 'opi_dbi_wip_scrap_init_pkg';
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

-- exception to throw if user needs to run common module initial
-- load again - e.g. if bounds have not been set up correctly.
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

-- exception to raise if it is not time for the initial load to run
-- i.e. the incremental load has not been run yet
cannot_run_initial_load EXCEPTION;
PRAGMA EXCEPTION_INIT (cannot_run_initial_load, -20007);


-- exception to raise if DBI global currency code not found
global_rate_type_not_found EXCEPTION;
PRAGMA EXCEPTION_INIT (global_rate_type_not_found, -20008);

/*----------------------------------------*/

/*  collect_wip_scrap_init

    Wrapper routine for OPI WIP scrap data extraction for
    initial load. In fact, this wrapper is somewhat redundant, since
    we do not have any OPM data, but the availability of the wrapper
    makes that extension easier, if needed.

    To begin with, this routine truncates the staging table,
    OPI_DBI_WIP_SCRAP_STG and the fact table OPI_DBI_WIP_SCRAP_F.

    Both OPI collection first runs to the staging table level. If an error
    occurs, routine ends with error.

    If not, then conversion rates have to be calculated for
    all the data in the staging table.

    If all conversion rates are found, data is merged to the fact table,
    following which the staging table can be truncated.

    This wrapper will only commit data implicitly through the DDL that
    truncates the staging table. That way, it ensures that the merge is
    committed and the staging table is emptied simultaneously.
    This is consistent with the incremental load where we cannot
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
    04/29/2003      Dinkar Gupta        Wrote procedure
*/

PROCEDURE collect_wip_scrap_init (errbuf OUT NOCOPY VARCHAR2,
                                  retcode OUT NOCOPY NUMBER)
IS

    l_proc_name CONSTANT VARCHAR2 (60) := 'collect_wip_scrap_init';
    l_stmt_id NUMBER;

    l_opi_success BOOLEAN;     -- OPI extraction successful?

    l_global_start_date DATE;

BEGIN

    -- initialization block
    l_stmt_id := 0;
    l_opi_success := false;
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
    IF (NOT (check_global_setup ())) THEN
        RAISE global_setup_missing;
    END IF;

    -- truncate the fact and staging tables.
    l_stmt_id := 20;
    -- also truncate the MV log explicitly because the purge MV log
    -- directive on the fact is still causing a delete on the MV log
    --
    -- bug  3863905- mv log is now dropped before initial load
    -- we shouldnt be truncating mv log anymore
    --
    -- EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
    --                    'MLOG$_OPI_DBI_WIP_SCRAP_F');


    l_stmt_id := 25;
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
                       'OPI_DBI_WIP_SCRAP_F PURGE MATERIALIZED VIEW LOG');

    l_stmt_id := 30;
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
                       'OPI_DBI_WIP_SCRAP_STG');

    -- get the DBI global start date
    l_stmt_id := 40;
    l_global_start_date := trunc (bis_common_parameters.get_global_start_date);

    -- Collect the WIP Scrap for OPI
    BEGIN

        l_stmt_id := 50;
        -- COMMIT DATA AS NEEDED!!! WRAPPER WILL NOT COMMIT DATA FOR
        -- STAGING TABLE.
        collect_init_opi_wip_scrap (errbuf, retcode, l_global_start_date);
        -- OPI collection into staging table successful
        l_stmt_id := 60;
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
                                 'Unable to collect OPI WIP Scrap data in initial load into staging table.');

    END;

    -- If OPI extraction to staging table failed, then abort here
    l_stmt_id := 70;
    IF (NOT (l_opi_success)) THEN
        RAISE data_extraction_failed;
    END IF;

    -- Compute the conversions rates for all the data in the staging table.
    -- COMMIT DATA SO THAT THE ROLLBACK SEGMENT DOES BECOME TOO LARGE IN
    -- THE FUNCTION. WRAPPER ONLY COMMITS FOR FACT TABLE.
    l_stmt_id := 80;
    compute_wip_scrap_conv_rates (errbuf, retcode, s_opi_schema);

    -- Merge all the data to the fact table.
    -- DO NOT COMMIT DATA IN THIS ONE FUNCTION.
    -- LET THE WRAPPER COORDINATE THE LAST COMMIT.
    l_stmt_id := 90;
    update_wip_scrap_fact_init (errbuf, retcode);

    -- Finally truncate the staging table if we have got this far, because
    -- all data in the fact.
    -- The truncate will implicitly also commit data to the fact table.
    -- This is important because the staging table is "persistent" i.e.
    -- failures midway do not cause data stored in the staging table to be
    -- deleted and data once collected in staging table is not collected
    -- again. In the initial load this does not matter, but is consistent
    -- with the incremental load. In the incremental load, the staging
    -- table cannot be blindly truncated before every collection, so it is
    -- imperative the commit on the fact table and truncate on staging table
    -- happen as one operation.
    l_stmt_id := 100;
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
                       'OPI_DBI_WIP_SCRAP_STG');

    l_stmt_id := 110;
    BIS_COLLECTION_UTILITIES.PUT_LINE
        ('Scrap Initial load terminated successfully.');
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
                  'WIP Scrap ETL Initial Load failed to get OPI schema info.';
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
                  'WIP Scrap Initial Load could not find global setup of global start date and global currency code.';
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
                  'WIP Scrap Initial Load data extraction failed. Check previous messages for errors. ';
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
                  'WIP Scrap ETL Initial load Failed.';
        return;


END collect_wip_scrap_init;


/*  collect_init_opi_wip_scrap

    Initial collection of WIP Scrap data from MMT/MTA for discrete (OPI)
    organizations.

    Collections begin from the global start for every discrete organization
    for the transaction range recorded in the current log table,
    OPI_DBI_RUN_LOG_CURR. The collection therefore proceeds to extract
    every transaction per discrete org upto the first uncosted transaction.

    To ensure that the bounds are good, we call the init_end_bounds_setup API
    from the Common Module Initial load.

    Data is not committed to the staging table until the bounds in the
    current log table have been updated successfully using the Common Module
    API etl_report_success.

    WIP Scrap ETL needs to extract two types of transactions from
    MMT:

    90 - WIP Scrap transaction increases the quantity/value
         of WIP Scrap
    91 - Wip Return from Scrap transaction decreases the quantity/value of
         of WIP Scrap.

    The WIP valuation account has an accounting line type of 7 in MTA, but
    the WIP valuation account decreases on scrap transactions and increases
    on returns from scrap. Thus for every transaction, the corresponding
    value we pick is -1 * (sum of all accouting line type 7) because this
    ETL must report increased scrap value on scrap transactions and decreased
    value on scrap returns.


    Parameters:
    p_global_start_date - global start date for DBI collection.
                          Expect this to be trunc'ed

    Date            Author              Action
    04/29/2003      Dinkar Gupta        Wrote procedure

*/

PROCEDURE collect_init_opi_wip_scrap (errbuf OUT NOCOPY VARCHAR2,
                                      retcode OUT NOCOPY NUMBER,
                                      p_global_start_date IN DATE)
IS

    l_proc_name CONSTANT VARCHAR2 (60) := 'collect_init_opi_wip_scrap';
    l_stmt_id NUMBER;

BEGIN

    -- initialization block
    l_stmt_id := 0;

    -- Check if all the bounds have been properly set up
    l_stmt_id := 10;
    IF (NOT (opi_dbi_common_mod_init_pkg.init_end_bounds_setup
                (WIP_SCRAP_ETL, OPI_SOURCE))) THEN
        RAISE run_common_module;
    END IF;


    l_stmt_id := 15;
    -- check if it is ok to run initial load
    IF (NOT (opi_dbi_common_mod_init_pkg.run_initial_load
                (WIP_SCRAP_ETL, OPI_SOURCE))) THEN
        RAISE cannot_run_initial_load;
    END IF;


    -- If all bounds have been set up, extract all the data.
    -- The data is simply inserted into the staging table, since
    -- this is the initial load the staging table should be empty.
    --
    -- WIP scrap transactions (MMT type 90) cause WIP Scrap
    -- quantity/value to increase.
    -- Scrap return transactions (MMT type 91) cause WIP Scrap
    -- quantity/value to decrease.
    --
    -- MTA accounting line type 7 represents the WIP valuation account.
    -- Since the WIP account decreases on scrap and increases on
    -- scrap returns, we need to use -1 * value from MTA.
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
    INSERT /*+ append parallel(opi_dbi_wip_scrap_stg) */
    INTO opi_dbi_wip_scrap_stg (
        organization_id,
        inventory_item_id,
        transaction_date,
        scrap_quantity,
        scrap_value_b,
        uom_code,
        source,
        planned_item,
        creation_date,
        last_update_date,
        created_by,
        last_updated_by,
        last_update_login)
    SELECT /*+ use_hash(msi) use_hash(scrap) parallel(msi) parallel(scrap) */
        scrap.organization_id,
        scrap.inventory_item_id,
        scrap.trx_date,
        sum (scrap.mmt_quantity),
        sum (scrap.mta_value),
        msi.primary_uom_code,
        OPI_SOURCE,             -- Scrap is only for OPI orgs
        decode (msi.mrp_planning_code,
                NON_PLANNED_ITEM, 'N',
                'Y'),
        sysdate,
        sysdate,
        s_user_id,
        s_user_id,
        s_login_id
      FROM mtl_system_items_b msi,
        (SELECT /*+ use_hash(mmt) use_hash(mta) use_hash(we) use_hash(wdj) use_hash(log)
            parallel(mmt) parallel(mta) parallel(we) parallel(wdj) parallel(log) */
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
            AND log.etl_id = WIP_SCRAP_ETL
            AND mmt.organization_id = log.organization_id
            AND mmt.transaction_id >= log.start_txn_id
            AND mmt.transaction_id < log.next_start_txn_id
            AND mmt.transaction_date >= p_global_start_date  -- (date trunc'ed)
            AND mmt.transaction_type_id IN (90, 91)
            AND mta.transaction_id(+) = mmt.transaction_id
            AND nvl (mta.accounting_line_type, WIP_VALUATION_ACCT) =
                    WIP_VALUATION_ACCT
            AND we.wip_entity_id = mmt.transaction_source_id
            AND we.entity_type IN (WIP_DISCRETE_JOB,
                                   WIP_REPETITIVE_ASSEMBLY_JOB,
                                   WIP_CLOSED_DISCRETE_JOB,
                                   WIP_FLOW_SCHEDULE_JOB)
            AND wdj.wip_entity_id (+) = we.wip_entity_id
            AND nvl (wdj.job_type, WIP_DISCRETE_STANDARD_JOB) =
                    WIP_DISCRETE_STANDARD_JOB
          GROUP BY  mmt.organization_id,
                    mmt.inventory_item_id,
                    trunc (mmt.transaction_date),
                    mmt.primary_quantity,
                    mmt.transaction_id) scrap
      WHERE msi.organization_id = scrap.organization_id
        AND msi.inventory_item_id = scrap.inventory_item_id
      GROUP BY
        scrap.organization_id,
        scrap.inventory_item_id,
        scrap.trx_date,
        msi.primary_uom_code,
        decode (msi.mrp_planning_code,
                NON_PLANNED_ITEM, 'N',
                'Y');



    -- If the entire collection was successful, then try and report this
    -- success to the OPI_DBI_RUN_LOG_CURR.
    l_stmt_id := 30;
    IF (NOT (opi_dbi_common_mod_incr_pkg.etl_report_success
                (WIP_SCRAP_ETL, OPI_SOURCE))) THEN

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
                              'WIP Scrap ETL Initial load data extraction success could not be logged into log table. Aborting.');

        retcode := s_ERROR;
        errbuf := s_pkg_name || '.' || l_proc_name || ' ' || '#' ||
                  l_stmt_id || ': ' ||
                  'WIP Scrap ETL Initial load data extraction success could not be logged into log table. Aborting.';
        RAISE;  -- propagate exception to wrapper.


    WHEN cannot_run_initial_load THEN
        rollback;
        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id || ': ' ||
                                           'WIP Scrap initial load concurrent program should not be running.
Try running the incremental load request set if the initial request set has already been run. If not, you will need to run the initial load request set.');

        retcode := s_ERROR;
        errbuf := s_pkg_name || '.' || l_proc_name || ' ' || '#' ||
                  l_stmt_id || ': ' ||
                  'WIP Scrap initial load concurrent program should not be running. Try running the incremental load request set if the initial request set has already been run. If not, you will need to run the initial load request set.';
        RAISE;  -- propagate exception to wrapper.

    WHEN run_common_module THEN
        rollback;
        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id || ': ' ||
                              'WIP Scrap initial load concurrent program is running out of turn. Please submit the initial load request set for initial data collection.');

        retcode := s_ERROR;
        errbuf := s_pkg_name || '.' || l_proc_name || ' ' || '#' ||
                  l_stmt_id || ': ' ||
                  'WIP Scrap initial load concurrent program is running out of turn. Please submit the initial load request set for initial data collection.';
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
                  'WIP Scrap ETLs Initial load data extraction failed.';
        RAISE;  -- propagate exception to wrapper.

END collect_init_opi_wip_scrap;

/*  update_wip_scrap_fact_init

    Merge data from the staging table to the fact table. For the
    initial load, we are guaranteed that the fact table is empty,
    so the update of the fact table is actually a simple insert.

    The granularity of the staging table will item-org-transaction_date
    and implicitly the source, since an org is never discrete and
    process at the same time.

    THIS FUNCTION WILL NOT COMMIT ANY DATA, SINCE THE WRAPPER IS
    TAKING RESPONSIBILITY FOR COMMITTING DATA TO THE FACT TABLE.

    Date            Author              Action
    04/29/2003      Dinkar Gupta        Wrote procedure
    08/24/2004      Dinkar Gupta        Added secondary currency support.

*/

PROCEDURE update_wip_scrap_fact_init (errbuf OUT NOCOPY VARCHAR2,
                                      retcode OUT NOCOPY NUMBER)
IS

    l_proc_name CONSTANT VARCHAR2 (60) := 'update_wip_scrap_fact_init';
    l_stmt_id NUMBER;


BEGIN

    -- initialization block
    l_stmt_id := 0;

    -- Just insert everything in staging table into the fact table,
    -- grouping by item-org-transaction_date and source.
    --
    -- It is assumed that the date stored in the fact table has
    -- already been truncated at the start of the initial load.
    -- Depending on how the staging table extraction SQL has been written
    -- it might not be necessary to perform the group by operation here (at
    -- least not for initial load) but it is being done for consistency.
    l_stmt_id := 10;
    INSERT /*+ append parallel (opi_dbi_wip_scrap_f) */
    INTO opi_dbi_wip_scrap_f (
        organization_id,
        inventory_item_id,
        transaction_date,
        scrap_quantity,
        scrap_value_b,
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
    SELECT /*+ use_hash(stg conv) parallel(stg) parallel(conv) */
        stg.organization_id,
        stg.inventory_item_id,
        stg.transaction_date,
        sum (stg.scrap_quantity),
        sum (stg.scrap_value_b),
        stg.uom_code,
        conv.conversion_rate,
        conv.sec_conversion_rate,
        stg.source,
        stg.planned_item,
        sysdate,
        sysdate,
        s_user_id,
        s_user_id,
        s_login_id
      FROM opi_dbi_wip_scrap_stg stg,
           opi_dbi_wip_scrap_conv_rates conv
      WHERE stg.organization_id = conv.organization_id
        AND stg.transaction_date = conv.transaction_date
      GROUP BY  stg.organization_id,
                stg.inventory_item_id,
                stg.transaction_date,
                stg.uom_code,
                conv.conversion_rate,
                conv.sec_conversion_rate,
                stg.source,
                stg.planned_item;

    -- merge successful, so return
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
                  'WIP Scrap ETL Initial merge to fact table failed.';
        RAISE;  -- propagate exception to wrapper.

END update_wip_scrap_fact_init;


/*++++++++++++++++++++++++++++++++++++++++*/
/* Functions for initial and incremental load
/*++++++++++++++++++++++++++++++++++++++++*/


/*  compute_wip_scrap_conv_rates

    Compute all the conversion rates for all distinct organization,
    transaction date pairs in the staging table. The date in the fact
    table is already without a timestamp i.e. trunc'ed.

    There are two conversion rates to be computed:
    1. Primary global
    2. Secondary global (if set up)

    The conversion rate work table was truncated during
    the initialization phase.

    Get the currency conversion rates based on the data in
    OPI_DBI_WIP_SCRAP_STG using the fii_currency.get_global_rate_primary
    API for the primary global currency and
    fii_currency.get_global_rate_secondary for the secondary global currency.
    The primary currency API:
    1. finds the conversion rate if one exists.
    2. returns -1 if there is no conversion rate on that date.
    3. returns -2 if the currency code is not found.
    4. returns -3 if the transaction_date is prior to 01-JAN-1999,
       the functional currency code is EUR and there is no EUR to USD
       conversion rate defined on 01-JAN-1999.

    The secondary currency API:
    1. Finds the global secondary currency rate if one exists.
    2. Returns a rate of 1 if the secondary currency has not been set up.
    3. Returns -1, -2, -3 in the same way as the primary currency code API.

    If the global and secondary currency codes and rate types are identical,
    do not call the secondary currency API. Instead update the secondary
    rates from the primary.

    If the secondary currency has not been set up, set the conversion rate
    to null.

    If any primary conversion rates are missing, throw an exception.
    If any secondary currency rates are missing (after the secondary
    currency has been set up) throw an exception.

    Need to commit data here due to insert+append.

    Date            Author              Action
    04/29/2003      Dinkar Gupta        Wrote procedure
    06/03/2003      Dinkar Gupta        Added OPI schema parameter
*/

PROCEDURE compute_wip_scrap_conv_rates (errbuf OUT NOCOPY VARCHAR2,
                                        retcode OUT NOCOPY NUMBER,
                                        p_opi_schema IN VARCHAR2)
IS

    l_proc_name CONSTANT VARCHAR2 (60) := 'compute_wip_scrap_conv_rates';
    l_stmt_id NUMBER := 0;

    l_global_currency_code VARCHAR2 (10) := NULL;
    l_global_rate_type VARCHAR2(10) := NULL;

    l_secondary_currency_code VARCHAR2 (10);
    l_secondary_rate_type VARCHAR2(15);

    l_all_rates_found BOOLEAN := true;

    -- Flag to check if the primary and secondary currencies are the
    -- same
    l_pri_sec_curr_same NUMBER;

    -- Cursor to see if any rates are missing. See below for details
    CURSOR invalid_rates_exist_csr IS
        SELECT 1
          FROM opi_dbi_wip_scrap_conv_rates
          WHERE (   nvl (conversion_rate, -999) < 0
                 OR nvl (sec_conversion_rate, 999) < 0)
            AND rownum < 2;

    invalid_rates_exist_rec invalid_rates_exist_csr%ROWTYPE;

    -- Set up a cursor to get all the invalid rates.
    -- By the logic of the fii_currency.get_global_rate_primary
    -- and fii_currency.get_global_rate_secondary APIs, the returned value
    -- is -ve if no rate exists:
    -- -1 for dates with no rate.
    -- -2 for unrecognized conversion rates.
    -- -3 for missing EUR to USD rates on 01-JAN-1999 when the
    --    transaction_date is prior to 01-JAN-1999 (when the EUR
    --    officially went into circulation).
    --
    -- However, with the secondary currency, the null rate means it
    -- has not been setup and should therefore not be reported as an
    -- error.
    --
    -- Also, cross check with the org-date pairs in the staging table,
    -- in case some orgs never had a functional currency code defined.
    CURSOR get_missing_rates_c (p_pri_sec_curr_same NUMBER,
                                p_global_currency_code VARCHAR2,
                                p_global_rate_type VARCHAR2,
                                p_secondary_currency_code VARCHAR2,
                                p_secondary_rate_type VARCHAR2) IS
        SELECT DISTINCT
            report_order,
            curr_code,
            rate_type,
            transaction_date,
            func_currency_code
          FROM (
           SELECT DISTINCT
                    p_global_currency_code curr_code,
                    p_global_rate_type rate_type,
                    1 report_order, -- ordering global currency first
                    mp.organization_code,
                    decode (conv.conversion_rate,
                            EURO_MISSING_AT_START, EURO_START_DATE,
                            conv.transaction_date) transaction_date,
                    conv.base_currency_code func_currency_code
              FROM opi_dbi_wip_scrap_conv_rates conv,
                   mtl_parameters mp,
                  (SELECT /*+ index_ffs(opi_dbi_wip_scrap_stg) */
                   DISTINCT organization_id, transaction_date
                     FROM opi_dbi_wip_scrap_stg) to_conv
              WHERE nvl (conv.conversion_rate, -999) < 0 -- null is not fine
                AND mp.organization_id = to_conv.organization_id
                AND conv.transaction_date (+) = to_conv.transaction_date
                AND conv.organization_id (+) = to_conv.organization_id
            UNION ALL
            SELECT DISTINCT
                    p_secondary_currency_code curr_code,
                    p_secondary_rate_type rate_type,
                    decode (p_pri_sec_curr_same,
                            1, 1,
                            2) report_order, --ordering secondary currency next
                    mp.organization_code,
                    decode (conv.sec_conversion_rate,
                            EURO_MISSING_AT_START, EURO_START_DATE,
                            conv.transaction_date) transaction_date_date,
                    conv.base_currency_code func_currency_code
              FROM opi_dbi_wip_scrap_conv_rates conv,
                   mtl_parameters mp,
                  (SELECT /*+  index_ffs(opi_dbi_wip_scrap_stg) */
                   DISTINCT organization_id, transaction_date
                     FROM opi_dbi_wip_scrap_stg) to_conv
              WHERE nvl (conv.sec_conversion_rate, 999) < 0 -- null is fine
                AND mp.organization_id = to_conv.organization_id
                AND conv.transaction_date (+) = to_conv.transaction_date
                AND conv.organization_id (+) = to_conv.organization_id)
          ORDER BY
                report_order ASC,
                transaction_date,
                func_currency_code;

BEGIN

    -- initialization block
    l_stmt_id := 0;
    l_global_currency_code := NULL;
    l_global_rate_type := NULL;
    l_secondary_currency_code := NULL;
    l_secondary_rate_type := NULL;
    l_all_rates_found := true;
    l_pri_sec_curr_same := 0;


    -- Truncate the conversion rates work table
    l_stmt_id := 10;
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || p_opi_schema || '.' ||
                       'OPI_DBI_WIP_SCRAP_CONV_RATES');


    -- It is assumed that the setup of the global currency data has been
    -- validated at the start of the program by a call to the
    -- check_global_setup procedure.
    -- Global currency codes -- already checked if primary is set up
    l_stmt_id := 20;
    l_global_currency_code := bis_common_parameters.get_currency_code;
    l_secondary_currency_code :=
            bis_common_parameters.get_secondary_currency_code;

    -- Global rate types -- already checked if primary is set up
    l_stmt_id := 25;
    l_global_rate_type := bis_common_parameters.get_rate_type;
    l_secondary_rate_type := bis_common_parameters.get_secondary_rate_type;

    l_stmt_id := 27;
    -- check if the primary and secondary currencies and rate types are
    -- identical.
    IF (l_global_currency_code = nvl (l_secondary_currency_code, '---') AND
        l_global_rate_type = nvl (l_secondary_rate_type, '---') ) THEN
        l_pri_sec_curr_same := 1;
    END IF;

    -- By selecting distinct org and currency code from the gl_set_of_books
    -- and hr_organization_information, take care of duplicate codes.
    -- Use the fii_currency.get_global_rate_primary function to get the
    -- conversion rate given a currency code and a date.
    -- The function returns:
    -- rate if found
    -- -1 for dates for which there is no currency conversion rate
    -- -2 for unrecognized currency conversion rates
    -- -3 for missing EUR to USD rates on 01-JAN-1999 when the
    --    transaction_date is prior to 01-JAN-1999 (when the EUR
    --    officially went into circulation).

    -- Use the fii_currency.get_global_rate_secondary to get the secondary
    -- global rate. If the secondary currency has not been set up,
    -- make the rate null. If the secondary currency/rate types are the
    -- same as the primary, don't call the API but rather use an update
    -- statement followed by the insert.

    -- By selecting distinct org and currency code from the gl_set_of_books
    -- and hr_organization_information, take care of duplicate codes.

    INSERT /*+ append */
    INTO opi_dbi_wip_scrap_conv_rates rates (
        organization_id,
        base_currency_code,
        transaction_date,
        conversion_rate,
        sec_conversion_rate,
        last_update_date,
        creation_date,
        created_by,
        last_updated_by,
        last_update_login)
    SELECT
        to_conv.organization_id,
        curr_codes.currency_code,
        to_conv.transaction_date,
        decode (curr_codes.currency_code,
                l_global_currency_code, 1,
                fii_currency.get_global_rate_primary (
                                    curr_codes.currency_code,
                                    to_conv.transaction_date) ),
        decode (l_secondary_currency_code,
                NULL, NULL,
                curr_codes.currency_code, 1,
                decode (l_pri_sec_curr_same,
                        1, C_PRI_SEC_CURR_SAME_MARKER,
                        fii_currency.get_global_rate_secondary (
                            curr_codes.currency_code,
                            to_conv.transaction_date))),
        sysdate,
        sysdate,
        s_user_id,
        s_user_id,
        s_login_id
      FROM
        (SELECT /*+ index_ffs(opi_dbi_wip_scrap_stg) */
         DISTINCT organization_id, transaction_date
           FROM opi_dbi_wip_scrap_stg) to_conv,
        (SELECT
         DISTINCT hoi.organization_id, gsob.currency_code
           FROM hr_organization_information hoi,
                gl_sets_of_books gsob
           WHERE hoi.org_information_context  = 'Accounting Information'
             AND hoi.org_information1  = to_char(gsob.set_of_books_id))
        curr_codes
      WHERE curr_codes.organization_id  = to_conv.organization_id;


    --Introduced commit because of append parallel in the insert stmt above.
    commit;

    l_stmt_id := 40;
    -- if the primary and secondary currency codes are the same, then
    -- update the secondary with the primary
    IF (l_pri_sec_curr_same = 1) THEN

        UPDATE /*+ parallel (opi_dbi_wip_scrap_conv_rates) */
        opi_dbi_wip_scrap_conv_rates
        SET sec_conversion_rate = conversion_rate;

        -- safe to commit, as before
        commit;

    END IF;


    OPEN invalid_rates_exist_csr;
    FETCH invalid_rates_exist_csr INTO invalid_rates_exist_rec;
    IF (invalid_rates_exist_csr%FOUND) THEN

        -- there are missing rates - prepare to report them.
        l_all_rates_found := false;
        BIS_COLLECTION_UTILITIES.writeMissingRateHeader;

        l_stmt_id := 60;
        FOR get_missing_rates_rec IN get_missing_rates_c
                                        (l_pri_sec_curr_same,
                                         l_global_currency_code,
                                         l_global_rate_type,
                                         l_secondary_currency_code,
                                         l_secondary_rate_type)
        LOOP

            BIS_COLLECTION_UTILITIES.writemissingrate (
                get_missing_rates_rec.rate_type,
                get_missing_rates_rec.func_currency_code,
                get_missing_rates_rec.curr_code,
                get_missing_rates_rec.transaction_date);

        END LOOP;

    END IF;
    CLOSE invalid_rates_exist_csr;


    -- If all rates not found raise an exception
    l_stmt_id := 50;
    IF (l_all_rates_found = false) THEN
        RAISE missing_conversion_rates;
    END IF;

    l_stmt_id := 60;
    retcode := s_SUCCESS;
    errbuf := '';
    return;

EXCEPTION

    WHEN global_curr_code_not_found THEN
        rollback;

        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id || ': ' ||
                              'WIP Scrap ETL Initial load global currency code not found.');

        retcode := s_ERROR;
        errbuf := s_pkg_name || '.' || l_proc_name || ' ' || '#' ||
                  l_stmt_id || ': ' ||
                  'WIP Scrap ETL Initial load global currency code not found.';
        RAISE;  -- propagate exception to wrapper.

    WHEN global_rate_type_not_found THEN
        rollback;

        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id || ': ' ||
                              'WIP Scrap ETL Initial load global rate type not found.');

        retcode := s_ERROR;
        errbuf := s_pkg_name || '.' || l_proc_name || ' ' || '#' ||
                  l_stmt_id || ': ' ||
                  'WIP Scrap ETL Initial load global rate type not found.';
        RAISE;  -- propagate exception to wrapper.

   WHEN missing_conversion_rates THEN
        rollback;

        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id || ': ' ||
                              'WIP Scrap ETL Initial Load found missing currency rates.');

        retcode := s_ERROR;
        errbuf := s_pkg_name || '.' || l_proc_name || ' ' || '#' ||
                  l_stmt_id || ': ' ||
                  'WIP Scrap ETL Initial Load found missing currency rates.';

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
                  'WIP Scrap ETL Initial load conversion rate computation failed.';
        RAISE;  -- propagate exception to wrapper.

END compute_wip_scrap_conv_rates;



/*  check_global_setup

    Checks to see if basic global parameters are set up.
    Currently these include the:
    1. Global start date
    2. Global currency code

    Parameters: None

    Date        Author              Action
    04/23/03    Dinkar Gupta        Wrote Function
    08/24/04    Dinkar Gupta        Added checking for primary rate type
                                    and secondary currency setup.

*/
FUNCTION check_global_setup
    RETURN BOOLEAN
IS
    l_proc_name CONSTANT VARCHAR2 (60) := 'check_global_setup';
    l_stmt_id NUMBER;

    l_setup_good BOOLEAN;

    l_list dbms_sql.varchar2_table;

    l_secondary_currency_code VARCHAR2(10);
    l_secondary_rate_type VARCHAR2(15);

BEGIN

    -- initialization block
    l_stmt_id := 0;
    l_secondary_currency_code := NULL;
    l_secondary_rate_type := NULL;
    l_setup_good := false;

    -- Parameters we want to check for
    l_list(1) := 'BIS_PRIMARY_CURRENCY_CODE';
    l_list(2) := 'BIS_GLOBAL_START_DATE';
    l_list(3) := 'BIS_PRIMARY_RATE_TYPE';

    l_setup_good := bis_common_parameters.check_global_parameters(l_list);

    IF (NOT (l_setup_good)) THEN
        BIS_COLLECTION_UTILITIES.PUT_LINE (
                'Global setup is not correct. Please setup up the global start date, primary currency code and primary rate type.');
    END IF;

    -- check the secondary currency setup
    l_secondary_currency_code :=
            bis_common_parameters.get_secondary_currency_code;
    l_secondary_rate_type := bis_common_parameters.get_secondary_rate_type;

    -- check that either both the secondary rate type and secondary
    -- rate are null, or that neither are null.
    IF (   (l_secondary_currency_code IS NULL AND
            l_secondary_rate_type IS NOT NULL)
        OR (l_secondary_currency_code IS NOT NULL AND
            l_secondary_rate_type IS NULL) ) THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE ('The global secondary currency code setup is incorrect. The secondary currency code cannot be null when the secondary rate type is defined and vice versa.');

        l_setup_good := FALSE;

    END IF;

    return l_setup_good;

EXCEPTION

    WHEN OTHERS THEN
        rollback;

        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id ||
                                           ': ' || SQLERRM);

        l_setup_good := false;
        return l_setup_good;


END check_global_setup;


/*  refresh

    Refresh the scrap related MVs. By this time, all the data is clean,
    so we can commit after evey successful stage.

*/
PROCEDURE refresh (errbuf OUT NOCOPY VARCHAR2,
                   retcode OUT NOCOPY NUMBER)

IS
    l_proc_name CONSTANT VARCHAR2 (60) := 'refresh';
    l_stmt_id NUMBER;

BEGIN

    -- initialization block
    l_stmt_id := 0;

    -- refresh the first level MV: opi_comp_scr_mv
    l_stmt_id := 10;
    DBMS_MVIEW.REFRESH ('opi_comp_scr_mv', '?');
    commit;

    -- refresh the second level MV: opi_prod_scr_mv
    l_stmt_id := 20;
    DBMS_MVIEW.REFRESH ('opi_prod_scr_mv', '?');
    commit;

    -- refresh the third and nested level MV: opi_scrap_sum_mv
    l_stmt_id := 30;
    DBMS_MVIEW.REFRESH ('opi_scrap_sum_mv', '?');
    commit;

    -- return successfully
    BIS_COLLECTION_UTILITIES.PUT_LINE
        ('Scrap Summaries Refreshed successfully');
    retcode := s_SUCCESS;
    errbuf := '';

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
                  'Scrap MV refresh failed.';
        return;


END refresh;


END opi_dbi_wip_scrap_init_pkg;

/
