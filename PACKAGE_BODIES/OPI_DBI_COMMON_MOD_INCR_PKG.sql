--------------------------------------------------------
--  DDL for Package Body OPI_DBI_COMMON_MOD_INCR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_COMMON_MOD_INCR_PKG" AS
/*$Header: OPIDCMODRB.pls 120.2 2005/08/16 01:36:32 sberi noship $ */

/*++++++++++++++++++++++++++++++++++++++++*/
/* Function and procedure declarations in this file but not in spec*/
/*++++++++++++++++++++++++++++++++++++++++*/

PROCEDURE compute_incr_etl_bounds (errbuf OUT NOCOPY VARCHAR2,
                                   retcode OUT NOCOPY NUMBER);

PROCEDURE compute_incr_end_bounds (errbuf OUT NOCOPY VARCHAR2,
                                   retcode OUT NOCOPY NUMBER);

FUNCTION txn_id_success (p_etl_id IN NUMBER, p_source IN NUMBER,
                         p_completion_date IN DATE)
    RETURN BOOLEAN;

FUNCTION collect_date_success (p_etl_id IN NUMBER, p_source IN NUMBER,
                               p_completion_date IN DATE)
    RETURN BOOLEAN;


FUNCTION txn_id_incr_setup (p_etl_id IN NUMBER, p_source IN NUMBER)
    RETURN BOOLEAN;

FUNCTION collect_date_incr_setup (p_etl_id IN NUMBER, p_source IN NUMBER)
    RETURN BOOLEAN;

/*----------------------------------------*/


/*++++++++++++++++++++++++++++++++++++++++*/
/* PACKAGE LEVEL CONSTANTS */
/*++++++++++++++++++++++++++++++++++++++++*/

s_pkg_name CONSTANT VARCHAR2 (50) := 'opi_dbi_common_mod_incr_pkg';
s_ERROR CONSTANT NUMBER := -1;   -- concurrent manager error code
s_WARNING CONSTANT NUMBER := 1;  -- concurrent manager warning code
s_SUCCESS CONSTANT NUMBER := 0;  -- concurrent manager success code

/*  All DBI ETLs have a numeric ETL ID for identification. The ETL
    functionality to etl_id mapping is defined as: */

/* Get these constants from the init load package, but rewrite them
   so they dont have to be invoked with package name.
*/

-- Job Transactions Staging
JOB_TXN_ETL CONSTANT NUMBER :=
    opi_dbi_common_mod_init_pkg.JOB_TXN_ETL;

-- Actual Resource Usage
ACTUAL_RES_ETL CONSTANT NUMBER :=
    opi_dbi_common_mod_init_pkg.ACTUAL_RES_ETL;

-- Resource Variance
RESOURCE_VAR_ETL CONSTANT NUMBER :=
    opi_dbi_common_mod_init_pkg.RESOURCE_VAR_ETL;

-- Job Master
JOB_MASTER_ETL CONSTANT NUMBER :=
    opi_dbi_common_mod_init_pkg.JOB_MASTER_ETL;

/*  All ETLs can have one of two sources: */
OPI_SOURCE CONSTANT NUMBER :=
    opi_dbi_common_mod_init_pkg.OPI_SOURCE;

OPM_SOURCE CONSTANT NUMBER :=
    opi_dbi_common_mod_init_pkg.OPM_SOURCE;

/*  ETLs can have to stop for multiple reasons. The stop reason
    codes are defined as follows: */
STOP_UNCOSTED CONSTANT NUMBER :=
    opi_dbi_common_mod_init_pkg.STOP_UNCOSTED;

STOP_ALL_COSTED CONSTANT NUMBER :=
    opi_dbi_common_mod_init_pkg.STOP_ALL_COSTED;

/*----------------------------------------*/


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

s_user_id NUMBER := nvl(fnd_global.user_id, -1);
s_login_id NUMBER := nvl(fnd_global.login_id, -1);
s_program_id NUMBER:= nvl (fnd_global.conc_program_id, -1);
s_program_login_id NUMBER := nvl (fnd_global.conc_login_id, -1);
s_program_application_id NUMBER := nvl (fnd_global.prog_appl_id,  -1);
s_request_id NUMBER := nvl (fnd_global.conc_request_id, -1);

/*----------------------------------------*/

/*++++++++++++++++++++++++++++++++++++++++*/
/*  Package level exceptions defined for
    clearer error handling. */
/*++++++++++++++++++++++++++++++++++++++++*/

-- exception to raise if unable to get schema information
schema_info_not_found EXCEPTION;
PRAGMA EXCEPTION_INIT (schema_info_not_found, -20000);

-- exception to raise if unable to ge
txn_id_bounds_missing EXCEPTION;
PRAGMA EXCEPTION_INIT (txn_id_bounds_missing, -20001);

-- exception to raise if unable find NULL collection dates
collect_date_bounds_missing EXCEPTION;
PRAGMA EXCEPTION_INIT (collect_date_bounds_missing, -20002);

-- exception to raise if global parameters such as global
-- start date and global currency code are not available
global_setup_missing EXCEPTION;
PRAGMA EXCEPTION_INIT (global_setup_missing, -20003);

-- Stage failure.
stage_failure EXCEPTION;
PRAGMA EXCEPTION_INIT (stage_failure, -20004);

-- Common Module Initial Load has not been run
run_common_mod_init EXCEPTION;
PRAGMA EXCEPTION_INIT (run_common_mod_init, -20005);

-- Found a null global start date
global_start_date_null EXCEPTION;
PRAGMA EXCEPTION_INIT (global_start_date_null, -20006);

/*----------------------------------------*/

/*  run_common_module_incr


    This function does not return with an exception in case of error
    but ends with a retcode of error. However helper functions are
    expected to throw exceptions. We do not look at the retcode/errbuf
    for helper functions. If a helper function fails, it is expected
    to write a error message to the log and to throw an exception
    back to this wrapper function.

    Date        Author              Action
    04/21/03    Dinkar Gupta        Wrote Function
    07/01/05    Sandeep Beri        Modified Procedure for R12
				    Commom Module does not call WIP
				    Completions and Job Master after
				    its successful completion.
*/

PROCEDURE run_common_module_incr (errbuf OUT NOCOPY VARCHAR2,
                                  retcode OUT NOCOPY NUMBER)
IS

    l_proc_name VARCHAR2 (60) := 'run_common_module_incr';
    l_stmt_id NUMBER := 0;
    l_bounds_warning BOOLEAN := false;

    l_run_log_size NUMBER := 0;
BEGIN

    execute immediate 'alter session set events ''10046 trace name context forever, level 8''';

    -- ensure that the initial common module has been run once
    l_stmt_id := 5;
    BEGIN
        SELECT 1
        INTO l_run_log_size
          FROM opi_dbi_run_log_curr
          WHERE rownum = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE run_common_mod_init;
    END;


    -- get session parameters
    l_stmt_id := 10;
    IF (NOT (fnd_installation.get_app_info('OPI', s_status, s_industry,
                                           s_opi_schema))) THEN
        RAISE schema_info_not_found;
    END IF;

    -- check if the global set up is good
    -- Use the initial load package
    l_stmt_id := 20;
    IF (NOT (opi_dbi_common_mod_init_pkg.check_global_setup ())) THEN
        RAISE global_setup_missing;
    END IF;



    -- compute the incremental bounds for the ETLs as needed
    l_stmt_id := 30;
    compute_incr_etl_bounds (errbuf, retcode);

    -- check if stage succeeded
    l_stmt_id := 31;
    IF (retcode = s_ERROR) THEN
        RAISE stage_failure;
    END IF;

    -- check if some bounds are uncosted before calling any other
    -- procedure that can wipe out the stop reason code
    l_stmt_id := 40;
    l_bounds_warning := opi_dbi_common_mod_init_pkg.bounds_uncosted ();


    -- Print the discrete org collection bounds
    l_stmt_id := 50;
    opi_dbi_common_mod_init_pkg.print_opi_org_bounds;

    -- if uncosted transactions were found, return a warning.
    l_stmt_id := 80;
    IF (l_bounds_warning) THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE
            ('Common Module Incremental Load terminated with warnings.');
        retcode := s_WARNING;
        errbuf := 'Common Module Incremental Load Found Uncosted Transactions.';
    ELSE
        -- terminate successfully
        BIS_COLLECTION_UTILITIES.PUT_LINE
            ('Common Module Incremental Load terminated successfully.');
        retcode := s_SUCCESS;
        errbuf := '';
    END IF;

EXCEPTION

    WHEN run_common_mod_init THEN
        rollback;

        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id ||
                                           ': ' ||
                                'Manufacturing Page common module Initial load has not been run. Please run the initial load (Initial Load - Update Job Details Base Summary) first.');

        retcode := s_ERROR;
        errbuf := s_pkg_name || '.' || l_proc_name || ' ' || '#' ||
                  l_stmt_id || ': ' ||
                  'Manufacturing Page common module Initial load has not been run. Please run the initial load (Initial Load - Update Job Details Base Summary) first.';
        return;


    WHEN schema_info_not_found THEN
        rollback;

        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' || l_proc_name || ' ' ||
                              '#' || l_stmt_id || ': ' ||  SQLERRM);

        retcode := s_ERROR;
        errbuf := s_pkg_name || '.' || l_proc_name || ' ' || '#' ||
                  l_stmt_id || ': ' ||
                  'Common Module Incremental Load failed to get OPI schema info.';
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
                  'Common Module Incremental Load could not find global setup of global start date and global currency code.';
        return;

    WHEN stage_failure THEN
        rollback;

        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id ||
                                           ': ' ||  SQLERRM);
        retcode := s_ERROR;
        errbuf := s_pkg_name || '.' || l_proc_name || ' ' || '#' ||
                  l_stmt_id || ': ' ||
                  'Common Module Incremental Load failed.';
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
                  'Common Module Incremental Load Failed.';
        return;

END run_common_module_incr;


/*  compute_incr_etl_bounds

    Computing the incremental bounds for the Job Transactions ETL and Actual resource usage ETL

    Job Transaction ETL includes:
        WIP Completions
        Scrap
        Material Usage Variance


    Compute the end bounds for all the rows corresponding to these ETLs
    in the current log table, OPI_DBI_RUN_LOG_CURR

    Data is committed at the end of this procedure but not in any
    of it's helper routines.

    Parameters:
    None.

    Date        Author              Action
    04/21/03    Dinkar Gupta        Wrote Function
*/


PROCEDURE compute_incr_etl_bounds (errbuf OUT NOCOPY VARCHAR2,
                                   retcode OUT NOCOPY NUMBER)
IS
    l_proc_name VARCHAR2 (60) := 'compute_incr_etl_bounds';
    l_stmt_id NUMBER := 0;

BEGIN

    -- compute the termination bounds for the different ETLs as needed
    l_stmt_id := 10;
    compute_incr_end_bounds (errbuf, retcode);

    -- success so far, then commit everything in one shot
    l_stmt_id := 20;
    commit;

    -- terminate successfully
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
        errbuf := s_pkg_name || '.' || l_proc_name || ' ' ||
                  '#' || l_stmt_id || ': ' ||
                  'Failed to compute bounds for the initial load.';
        RAISE;  -- propagate exception to wrapper

END compute_incr_etl_bounds;

/*  compute_incr_end_bounds

    Termination bounds need to be computed for:
        Job Transactions ETL which includes the following
	     WIP Completions
             Scrap
             Material Usage
        Actual Resource Variance.

OPI Sourced rows:
    For Job Transaction ETL:
         Every row either gets the first uncosted transaction for
         that organization_id in MMT, or 1 past the highest row
         in MMT. Do this in 1 SQL.
    For Actual Resource Usage:
        Pick the highest transaction_id + 1 in WT.

OPM Sourced Rows:
        All OPM Rows for all ETL's would be populated in one SQL which
	would set the to bound date as the sysdate snapshot. From bound date
	would be the to bound date of the previous initial/incremental run.

  -- Commit after computing the temp bounds and then the final bounds

    The choice of +1 over the highest transaction_id's is to ensure
    that the upper bound is strictly higher than all transactions to be
    collected.

    For the initial load, we need not worry about finding newly defined orgs
    in MTL_PARAMETERS for the discrete org rows of the Material transactions,
    because the data was seeded a few minutes ago.

    Date        Author              Action
    04/21/03    Dinkar Gupta        Wrote Function
    07/01/05	Sandeep Beri	    Modified OPM bound logic for R12. All
                                    OPM ETL bounds and OPI resource variance and
				    job master bounds would be date based.

*/

PROCEDURE compute_incr_end_bounds (errbuf OUT NOCOPY VARCHAR2,
                                   retcode OUT NOCOPY NUMBER)
IS
    l_proc_name VARCHAR2 (60) := 'compute_incr_end_bounds';
    l_stmt_id NUMBER := 0;

    -- the highest transaction in MMT + 1.
    l_max_mmt_plus_one NUMBER := NULL;

    -- the highest transaction in WT + 1.
    l_max_wt_plus_one NUMBER := NULL;

    -- the lowest starting transaction_id for OPI orgs doing
    -- WIP completions, Scrap or Material Usage variance (Job Activity ETL)
    l_min_start_id_opi_orgs NUMBER := NULL;

    -- global start date
    l_global_start_date DATE := NULL;

    -- Date Type Variable to hold the sysdate for upper bound
    l_to_bound_date DATE;

BEGIN

    -- All the following SQLs select the max transaction_id's from
    -- certain transaction tables. These id columns are primary keys
    -- and unique indexes on these tables. Therefore these statements
    -- are not full table scans but min-max index scans.

    -- Note that for all bounds, we pick max + 1. That is because the
    -- the upper bound is meant to be strictly higher than the
    -- id's to be collected. Since all the id sequences are discrete
    -- and increasing, just adding +1 ensures that if we start next time
    -- at the max + 1 of this run, then no transaction_id will be
    -- ignored.
    -- Also, max + 1 is not a real transaction_id and may never be.
    --
    -- For empty tables, we are keeping the start and end at 0.

    /* Truncate temp table */
    l_stmt_id := 5;
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' ||
                       s_opi_schema || '.opi_dbi_run_log_curr_tmp');

    l_stmt_id := 10;
    SELECT nvl (max (transaction_id), -1) + 1
      INTO l_max_mmt_plus_one
      FROM mtl_material_transactions;

    l_stmt_id := 30;
    SELECT nvl (max (transaction_id), -1) + 1
      INTO l_max_wt_plus_one
      FROM wip_transactions;

    -- Storing sysdate in a local variable for updating the log as we do not want to miss any
    -- horizon between OPM and OPI updates.
    l_stmt_id := 35;
    SELECT sysdate
    INTO l_to_bound_date
    FROM DUAL;

    -- It is possible that a new discrete org was defined in
    -- MTL_PARAMETERS since the last incremental run. This org must
    -- get a record in current log table, OPI_DBI_RUN_LOG_CURR so that
    -- it can be picked up in subsequent extractions. This need only be
    -- done for OPI orgs.

    -- The new org can start with least of the starting id's because
    -- that is a lower bound to the transaction not collected yet.
    -- This SELECT .. INTO .. need not be put in a BEGIN .. EXCEPTION
    -- block because we never expected a NULL value here in the
    -- incremental load.
    l_stmt_id := 48;
    SELECT  min (start_txn_id)
      INTO l_min_start_id_opi_orgs
      FROM opi_dbi_run_log_curr
      WHERE source = OPI_SOURCE
        AND etl_id = JOB_TXN_ETL;

    -- Get the global start date which will be used as the last collection
    -- date for the new orgs. This is important because the run_incr_bounds
    -- API checks to make sure that all orgs have non-null
    -- last_collection_date before running the incremental load.
    l_stmt_id := 45;
    l_global_start_date := trunc (bis_common_parameters.get_global_start_date);
    IF (l_global_start_date IS NULL) THEN
        RAISE global_start_date_null;
    END IF;


    -- Note that all distinct orgs in OPI_DBI_RUN_LOG_CURR can be queried
    -- by looking at all the orgs for Material ETL with OPI source
    -- (we look at the JOBH_TXN_ETL below). This is because
    -- we have exactly one row per discrete org for the Job Txn ETL
    -- Note that we are making the last_collection_date for new orgs
    -- to be the global start date so that the run_incr_bounds API
    -- performs correctly.
    l_stmt_id := 50;
    INSERT INTO opi_dbi_run_log_curr (
        organization_id,
        source,
        last_collection_date,
        start_txn_id,
        next_start_txn_id,
	from_bound_date,
	to_bound_date,
        etl_id,
        last_update_date,
        creation_date,
        last_updated_by,
        created_by,
        last_update_login,
	program_id,
        program_login_id,
        program_application_id,
        request_id)
    SELECT  new_orgs.organization_id,
            OPI_SOURCE,
            l_global_start_date,        -- never collected yet
            l_min_start_id_opi_orgs,    -- least collected transaction id
            NULL,                       -- no next_start_txn_id yet
	    NULL,
	    NULL,
            etls.etl_id,                -- All material ETLs
            sysdate,
            sysdate,
            s_user_id,
            s_user_id,
            s_login_id,
	    s_program_id,
            s_program_login_id,
            s_program_application_id,
            s_request_id
      FROM (SELECT JOB_TXN_ETL etl_id FROM dual
            ) etls,
           (SELECT organization_id
              FROM mtl_parameters
              WHERE process_enabled_flag <> 'Y'  -- not OPM org
            MINUS
            SELECT organization_id       -- all distinct orgs
              FROM opi_dbi_run_log_curr
              WHERE etl_id = JOB_TXN_ETL
                AND source = OPI_SOURCE) new_orgs;

    -- For Job Transactions ETL the OPI sourced
    -- rows either have a next_start_txn_id as the first
    -- uncosted transaction in MMT or the max + 1 of mmt.
    -- The uncosted transaction for has be to past the global start date,
    -- and at the moment in the initial load, every org has a start_txn_id
    -- So we can use this transaction_id limit the scan on MMT.
    -- Do not update the last transaction date here. That should only
    -- be done when the ETL reports success using the ETL report success
    -- API.
    -- Set the last transaction_date to sysdate and then
    -- update it for the OPI sourced MMT ETLs

    l_stmt_id := 60;
    INSERT /*+ append */
    INTO opi_dbi_run_log_curr_tmp
    (ORGANIZATION_ID,
     ETL_ID, SOURCE,
     NEXT_START_TXN_ID,
     STOP_REASON_CODE,
     LAST_TRANSACTION_DATE)
    SELECT /*+ use_nl(curr mmt_bounds) */
       curr_log.organization_id,
       curr_log.etl_id,
       curr_log.source,
       nvl (mmt_bounds.next_start_txn_id,
            l_max_mmt_plus_one) next_start_txn_id,
       decode (mmt_bounds.next_start_txn_id,
               NULL, STOP_ALL_COSTED,
               STOP_UNCOSTED) stop_reason_code,
       decode (mmt_bounds.next_start_txn_id,
               NULL, sysdate,
               mmt_bounds.last_transaction_date) last_transaction_date
     FROM
               (SELECT /*+ use_nl(uncosted mmt1)
                           index(mmt1, MTL_MATERIAL_TRANSACTIONS_U1) */
                        uncosted.organization_id,
                        uncosted.etl_id,
                        uncosted.source,
                        uncosted.uncosted_id next_start_txn_id,
                        max (mmt1.transaction_date) last_transaction_date
                  FROM (SELECT /*+ index(log, OPI_DBI_RUN_LOG_CURR_N1)
                                   leading(log) use_nl(log mmt) */
                               min (mmt.transaction_id) uncosted_id,
                               log.organization_id,
                               log.etl_id,
                               log.source,
                               log.start_txn_id
                        FROM mtl_material_transactions mmt,
                          (SELECT organization_id,
                                  etl_id,
                                  source,
                                  start_txn_id
                            FROM opi_dbi_run_log_curr
                            WHERE source = OPI_SOURCE
                              AND etl_id = JOB_TXN_ETL) log
                     WHERE mmt.costed_flag IN ('N', 'E')
                       AND mmt.transaction_id >= log.start_txn_id
                       AND mmt.organization_id = log.organization_id
                     GROUP BY
                        log.organization_id,
                        log.etl_id,
                        log.source,
                        log.start_txn_id) uncosted,
                    mtl_material_transactions mmt1
               WHERE mmt1.organization_id+0 = uncosted.organization_id
                 AND mmt1.transaction_id BETWEEN uncosted.start_txn_id
                                         AND uncosted.uncosted_id
               GROUP BY
                    uncosted.organization_id,
                    uncosted.etl_id,
                    uncosted.source,
                    uncosted.uncosted_id) mmt_bounds,
              (SELECT organization_id, etl_id, source, start_txn_id
                 FROM opi_dbi_run_log_curr
                 WHERE source = OPI_SOURCE
                   AND etl_id = JOB_TXN_ETL) curr_log
            WHERE curr_log.organization_id = mmt_bounds.organization_id (+)
              AND curr_log.etl_id = mmt_bounds.etl_id (+)
              AND curr_log.source = mmt_bounds.source (+);

    -- commit the temp table
    l_stmt_id := 62;
    commit;

    l_stmt_id := 65;

    UPDATE /*+ index(opi_curr_log, opi_dbi_run_log_curr_n1) */
    opi_dbi_run_log_curr opi_curr_log
       SET last_update_date = sysdate,
           (next_start_txn_id, stop_reason_code, last_transaction_date) =
        (SELECT next_start_txn_id,
            stop_reason_code,
            last_transaction_date
          FROM opi_dbi_run_log_curr_tmp bounds
        WHERE bounds.organization_id = opi_curr_log.organization_id
          AND bounds.etl_id = opi_curr_log.etl_id
          AND bounds.source = opi_curr_log.source)
       WHERE opi_curr_log.source = OPI_SOURCE
         AND opi_curr_log.etl_id = JOB_TXN_ETL;


    -- For all OPM ETL's, we would have to set the to_bound_date as the sysdate.
    -- By default, everything is costed
    l_stmt_id := 70;
    UPDATE opi_dbi_run_log_curr log
      SET last_update_date = sysdate,
          last_transaction_date = sysdate,
	  to_bound_date = l_to_bound_date
      WHERE log.source = OPM_SOURCE;

    -- For Actual Resource Usage the next_start_txn_id for:
    -- 1. OPI sourced row needs max + 1 from WT.
    -- By default, everything is costed.
    l_stmt_id := 80;
    UPDATE opi_dbi_run_log_curr log
      SET last_update_date = sysdate,
          last_transaction_date = sysdate,
          next_start_txn_id = l_max_wt_plus_one
          WHERE log.source = OPI_SOURCE
	  AND log.etl_id = ACTUAL_RES_ETL;

    -- For OPI Job Master and Resource Availibility ETL's, we would have to set the to_bound_date as the sysdate.
    l_stmt_id := 90;
    UPDATE opi_dbi_run_log_curr log
      SET last_update_date = sysdate,
          last_transaction_date = sysdate,
	  to_bound_date = l_to_bound_date
      WHERE log.source = OPI_SOURCE
      AND log.etl_id IN (RESOURCE_VAR_ETL, JOB_MASTER_ETL);

    -- commit all the computed bounds
    l_stmt_id := 90;
    commit;

    -- terminate successfully
    retcode := s_SUCCESS;
    errbuf := '';

EXCEPTION

    WHEN global_start_date_null THEN
        rollback;

        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id ||
                                           ': ' ||
                                           'Global Start date was null');

        retcode := s_ERROR;
        errbuf := s_pkg_name || '.' || l_proc_name || ' ' ||
                  '#' || l_stmt_id || ': ' ||
                  'Failed to compute incremental termination bounds because global start date is null.';
        RAISE;    -- propagate exception to wrapper


    WHEN OTHERS THEN
        rollback;

        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id ||
                                           ': ' ||  SQLERRM);

        retcode := s_ERROR;
        errbuf := s_pkg_name || '.' || l_proc_name || ' ' ||
                  '#' || l_stmt_id || ': ' ||
                  'Failed to compute incremental termination bounds.';
        RAISE;    -- propagate exception to wrapper

END compute_incr_end_bounds;


/*  etl_report_success

    Interface API for all ETLs that have collected data for the bounds
    stored in the log table OPI_DBI_RUN_LOG_CURR.

    This API is an indication from the ETL that its current rows in the
    OPI_DBI_RUN_LOG_CURR should be copied into the history table,
    OPI_DBI_RUN_LOG_AUDIT and then updated so that they can be populated
    with new bounds when the common module runs again.

    There are 4 different ETLs that can call the API:
    Job Transactions ETL - WIP Completions, Scrap and Material Usage
    Actual Resource Usage
    Resource Variance
    Job Master

    Each of the ETLs can have an OPI or OPM source. The behaviour of
    the API depends on both the invoking ETL and the source.

    The general behaviour is that all rows for the ETL-source pair
    get a last_collection_date of when this API is invoked and are copied
    to the audit table. Then for the ETLs that use transaction_id's the
    start and next_start txn_id's are updated.

    In particular, the following types of behaviours can occur:
    1. txn_id_success - For transaction_id based highwatermark ETLs:
                        Job Transactions ETL and OPI Source,
                        Actual Resource Usage and OPI Source.
                        Sets the last_collection_date to when this API
                        is called and copies all rows for the etl-source
                        pair to the audit table. The start and next_start
                        txn_id columns are updated.
    2. collect_date_success -   For last_collection_date based highwatermark
                                ETLs: Resource Usage and Job Master and all OPM ETL's.
                                Sets the last_collection_date to when this API
                                is called and copies all rows for the
                                etl-source pair to the audit table.
				Also sets the from and to bound dates.

    DO NOT COMMIT ANY DATA IN THIS API. IT IS THE RESPONSIBILITY OF THE
    MODULE INVOKING THIS API TO COMMIT!!!!

    Parameters:
    p_etl_id - ETL id of the ETL invoking API.
    p_source - data source of ETL (1 = OPI, 2 = OPM).

    Return Value:
    l_retval - true if the function returns with no errors.
               false otherwise.

    Date        Author              Action
    04/21/03    Dinkar Gupta        Wrote Function
    07/01/05    Sandeep Beri	    Modified the IF conditions to the
				    transaction id set uo check call as
				    in R12, no OPM ETL would have txn id bounds.

*/
FUNCTION etl_report_success (p_etl_id IN NUMBER, p_source IN NUMBER)
    RETURN BOOLEAN
IS
    l_proc_name VARCHAR2 (60) := 'etl_report_success';
    l_stmt_id NUMBER := 0;

    l_retval BOOLEAN := false;
    l_now DATE := sysdate;

BEGIN

    l_stmt_id := 10;
    IF ( ((p_etl_id = JOB_TXN_ETL) OR
          (p_etl_id = ACTUAL_RES_ETL)) AND p_source = OPI_SOURCE) THEN
        --{
	l_retval := txn_id_success (p_etl_id, p_source, l_now);
        --}
    -- For Resource Variance and Job Master and all OPM ETL's, the behaviour is
    -- based on last collection date.
    ELSE
        --{
        l_retval := collect_date_success (p_etl_id, p_source, l_now);
	--}
    END IF;


    -- success
    return l_retval;

EXCEPTION

    WHEN OTHERS THEN
        rollback;

        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id ||
                                           ': ' ||  SQLERRM);

        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id || ': ' ||
                                           'Failed to log successful collection for ETL #' ||
                                           p_etl_id || ' source #' ||
                                           p_source || '.');

        return false;

END etl_report_success;

/*  txn_id_success

    Log success for an ETL that uses transaction_id's as the high watermark.

    The behaviour is simple. Copy out all rows in the current log table,
    OPI_DBI_RUN_LOG_CURR with the same ETL_id-source values,
    and copy them to the audit table with the
    last_collection_date set to the completion date passed in.

    Then for all existing rows in OPI_DBI_RUN_LOG_CURR with the same ETL_id-
    source pairs as passed as arguments:
    Set the start_txn_id to the next_start_txn_id because for the next
    run we need to start at where we stopped this time.
    Set the next_start_txn_id to NULL since it will have to be recomputed.
    Set the last_collection_date to the completion date passed in.

    DO NOT COMMIT ANYTHING HERE. THAT WILL BE THE RESPONSIBILITY OF THE
    CALLING FUNCTIONS !!!

    Parameters:
    p_etl_id - ETL id of the ETL invoking API.
    p_source - data source of ETL (1 = OPI, 2 = OPM).
    p_completion_date - date on which the ETL completed.

    Return Value:
    l_retval - true if the function returns with no errors.
               false otherwise.

    Date        Author              Action
    04/21/03    Dinkar Gupta        Wrote Function

*/
FUNCTION txn_id_success (p_etl_id IN NUMBER, p_source IN NUMBER,
                         p_completion_date IN DATE)
    RETURN BOOLEAN
IS
    l_proc_name VARCHAR2 (60) := 'txn_id_success';
    l_stmt_id NUMBER := 0;

    l_retval BOOLEAN := true;

BEGIN

    -- copy all the rows for that ETL and source into
    -- the audit table with the last_collection_date set
    -- to the completion date
    l_stmt_id := 10;
    INSERT INTO opi_dbi_run_log_audit (
        organization_id,
        source,
        last_collection_date,
        start_txn_id,
        next_start_txn_id,
	from_bound_date,
	to_bound_date,
        etl_id,
        stop_reason_code,
        last_transaction_date,
        last_update_date,
        creation_date,
        last_updated_by,
        created_by,
        last_update_login,
	program_id,
        program_login_id,
        program_application_id,
        request_id
    )
    SELECT
        organization_id,
        p_source,
        p_completion_date,
        start_txn_id,
        next_start_txn_id,
	from_bound_date,
	to_bound_date,
        p_etl_id,
        stop_reason_code,
        last_transaction_date,
        sysdate,
        sysdate,
        s_user_id,
        s_user_id,
        s_login_id,
	s_program_id,
        s_program_login_id,
        s_program_application_id,
        s_request_id
      FROM opi_dbi_run_log_curr
      WHERE etl_id = p_etl_id
        AND source = p_source;


    -- update the start_txn_id to the next_start_txn_id and
    -- the last_collection_date to the completion date in the
    -- OPI_DBI_RUN_LOG_CURR.
    -- update the next_start_txn_id
    -- since they must be recomputed when the common module runs
    -- again.
    -- Do not change the stop reason code since PTP will need it later.
    -- Performance change (09/09/2003): Merged previous two updates into one.

    l_stmt_id := 20;
    UPDATE opi_dbi_run_log_curr log
    SET last_collection_date = p_completion_date,
        start_txn_id = next_start_txn_id,
        next_start_txn_id = NULL
      WHERE log.source = p_source
        AND log.etl_id = p_etl_id;

    return l_retval;

EXCEPTION

    WHEN OTHERS THEN
        rollback;

        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id ||
                                           ': ' ||  SQLERRM);

        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id || ': ' ||
                                           'Failed to log transaction id success for ETL #' ||
                                           p_etl_id || ' source #' ||
                                           p_source || '.');

        return false;

END txn_id_success;


/*  collect_date_success

    Log success for an ETL that uses from and to bound dates as the high watermark.

    The behaviour is simple. Copy out all rows in the current log table,
    OPI_DBI_RUN_LOG_CURR with the same ETL_id-source values,
    and copy them to the audit table with the
    last_collection_date set to the completion date passed in.

    Then for all existing rows in OPI_DBI_RUN_LOG_CURR with the same ETL_id-
    source pairs as passed as arguments:
    Set the last_collection_date to the completion date passed in.

    DO NOT COMMIT ANYTHING HERE. THAT WILL BE THE RESPONSIBILITY OF THE
    CALLING FUNCTIONS !!!

    Parameters:
    p_etl_id - ETL id of the ETL invoking API.
    p_source - data source of ETL (1 = OPI, 2 = OPM).
    p_completion_date - date on which the ETL completed.

    Return Value:
    l_retval - true if the function returns with no errors.
               false otherwise.

    Date        Author              Action
    04/21/03    Dinkar Gupta        Wrote Function
    07/01/05	Sandeep Beri	    Set the from bound date of the next
                                    run to the to bound date of this run.
				    And set to bound date as NULL.

*/
FUNCTION collect_date_success (p_etl_id IN NUMBER, p_source IN NUMBER,
                               p_completion_date IN DATE)
    RETURN BOOLEAN
IS
    l_proc_name VARCHAR2 (60) := 'collect_date_success';
    l_stmt_id NUMBER := 0;

    l_retval BOOLEAN := true;

BEGIN

    -- copy all the rows for that ETL and source into
    -- the audit table with the last_collection_date set
    -- to the completion date
    l_stmt_id := 10;
    INSERT INTO opi_dbi_run_log_audit (
        organization_id,
        source,
        last_collection_date,
        start_txn_id,
        next_start_txn_id,
	from_bound_date,
	to_bound_date,
        etl_id,
        stop_reason_code,
        last_update_date,
        creation_date,
        last_updated_by,
        created_by,
        last_update_login,
	program_id,
        program_login_id,
        program_application_id,
        request_id
    )
    SELECT
        organization_id,
        p_source,
        p_completion_date,
        start_txn_id,
        next_start_txn_id,
	from_bound_date,
	to_bound_date,
        p_etl_id,
        stop_reason_code,
        sysdate,
        sysdate,
        s_user_id,
        s_user_id,
        s_login_id,
	s_program_id,
        s_program_login_id,
        s_program_application_id,
        s_request_id
      FROM opi_dbi_run_log_curr
      WHERE etl_id = p_etl_id
        AND source = p_source;

    -- update the last_collection_date to the completion date in the
    -- OPI_DBI_RUN_LOG_CURR.
    -- Also set the stop_reason_code to NULL for consistency.
    -- Also set the from_bound_date of the to_bound_date of this run
    -- and set the to_bound_date to NULL as it would be computed in the
    -- next run.
    l_stmt_id := 20;
    UPDATE opi_dbi_run_log_curr log
    SET last_collection_date = p_completion_date,
        from_bound_date = to_bound_date,
	to_bound_date = NULL,
        stop_reason_code = NULL
      WHERE log.source = p_source
        AND log.etl_id = p_etl_id;

    return l_retval;

EXCEPTION

    WHEN OTHERS THEN
        rollback;

        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id ||
                                           ': ' ||  SQLERRM);

        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id || ': ' ||
                              'Failed to log collection date success for ETL #' ||
                                           p_etl_id || ' source #' ||
                                           p_source || '.');

        return false;

END collect_date_success;

/*  incr_end_bounds_setup

    API called by ETLs to ensure that the bounds they are running for are
    set up correctly.

    For the Material and Actual Resource Usage ETLs for OPI,
    this requires checking if all the next_start_txn_id values are not null
    for the given ETL and the source.

    For the Resource and Job variance ETLs in OPI and all OPM ETL's, need to ensure that the
    last_collection_date is NOT NULL sice this is the incremental extraction.
    Parameters:
    p_etl_id - etl_id of ETL invoking API.
    p_source - 1 for OPI, 2 for OPM

    Return:
    l_bounds_valid - true if the bounds are valid
                     false o.w.

    Date        Author              Action
    04/23/03    Dinkar Gupta        Wrote Function

*/
FUNCTION incr_end_bounds_setup (p_etl_id IN NUMBER, p_source IN NUMBER)
    RETURN BOOLEAN
IS

    l_proc_name VARCHAR2 (60) := 'incr_end_bounds_setup';
    l_stmt_id NUMBER := 0;

    l_exists NUMBER := NULL;
    l_bounds_valid BOOLEAN := true;

BEGIN

    -- Ensure the log table is not empty
    l_stmt_id := 5;
    BEGIN
        SELECT 1
        INTO l_exists
        FROM dual
        WHERE (EXISTS (SELECT source
                         FROM opi_dbi_run_log_curr
                         WHERE rownum = 1));

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE run_common_mod_init;

    END;


    -- For Discrete Job Transactions ETL
    -- and Actual Resource Usage, the behaviour is based on transaction
    -- id's
    l_stmt_id := 10;
    IF ( ((p_etl_id = JOB_TXN_ETL) OR
         (p_etl_id = ACTUAL_RES_ETL)) AND p_source = OPI_SOURCE ) THEN
   --{
        l_bounds_valid := txn_id_incr_setup (p_etl_id, p_source);
   --}
   ELSE
   --{
        l_bounds_valid := collect_date_incr_setup (p_etl_id, p_source);
   --}
    END IF;


    return l_bounds_valid;

EXCEPTION

    WHEN run_common_mod_init THEN
        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id ||
                                           ': ' || 'The initial load request set has not been run yet. Please run the initial load request set before running the incremental load request set.');

        l_bounds_valid := false;
        return l_bounds_valid;


    WHEN OTHERS THEN
        rollback;

        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id ||
                                           ': ' || SQLERRM);

        l_bounds_valid := false;
        return l_bounds_valid;

END incr_end_bounds_setup;

/*  txn_id_incr_setup

    Ensure that all the txn_id bounds are correctly setup for
    the incremental load of the ETL with the source passed in as arguments.

    Right now, this requires checking that the start_txn_id
    and next_start_txn_id columns are non-null for all the rows of the ETL
    and source.

    Parameters:
    p_etl_id - etl_id of ETL invoking API.
    p_source - 1 for OPI, 2 for OPM

    Return:
    l_bounds_valid - true if the bounds are valid
                     false o.w.

    Date        Author              Action
    04/23/03    Dinkar Gupta        Wrote Function

*/
FUNCTION txn_id_incr_setup (p_etl_id IN NUMBER, p_source IN NUMBER)
    RETURN BOOLEAN
IS

    l_proc_name VARCHAR2 (60) := 'txn_id_incr_setup';
    l_stmt_id NUMBER := 0;

    l_bounds_valid BOOLEAN := true;

    l_exists NUMBER := NULL;

BEGIN

    -- Ensure that all the start_txn_id's are non-null
    l_stmt_id := 10;
    BEGIN
        SELECT 1
        INTO l_exists
        FROM dual
        WHERE (EXISTS (SELECT start_txn_id
                         FROM opi_dbi_run_log_curr
                         WHERE start_txn_id IS NULL
                           AND source = p_source
                           AND etl_id = p_etl_id));

        RAISE txn_id_bounds_missing; -- found a missing next_start_txn_id

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_bounds_valid := true;
    END;

    -- Ensure that all the next_start_txn_id's are non-null
    l_stmt_id := 20;
    BEGIN
        SELECT 1
        INTO l_exists
        FROM opi_dbi_run_log_curr
          WHERE next_start_txn_id IS NULL
            AND source = p_source
            AND etl_id = p_etl_id
            AND rownum = 1;

        RAISE txn_id_bounds_missing; -- found a missing start_txn_id

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_bounds_valid := true;
    END;


    return l_bounds_valid;

EXCEPTION

    WHEN txn_id_bounds_missing THEN
        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id || ': ' ||
                                           'Found missing transaction_id bounds for ETL ' ||
                                           p_etl_id || ' source ' ||
                                           p_source || '. This means that some concurrent program is running out of turn. Please run the incremental load request set.');
        l_bounds_valid := false;
        return l_bounds_valid;

    WHEN OTHERS THEN
        rollback;

        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id ||
                                           ': ' || SQLERRM);

        l_bounds_valid := false;
        return l_bounds_valid;

END txn_id_incr_setup;

/*  collect_date_incr_setup

    Ensure that all the collection date bounds are correctly setup for
    the initial load of the ETL with the source passed in as arguments.

    Right now, this requires checking that the last_collection_date is
    not NULL. And even the to and the from date bounds are not null.

    Parameters:
    p_etl_id - etl_id of ETL invoking API.
    p_source - 1 for OPI, 2 for OPM

    Return:
    l_bounds_valid - true if the bounds are valid
                     false o.w.

    Date        Author              Action
    04/23/03    Dinkar Gupta        Wrote Function

*/
FUNCTION collect_date_incr_setup (p_etl_id IN NUMBER, p_source IN NUMBER)
    RETURN BOOLEAN
IS

    l_proc_name VARCHAR2 (60) := 'collect_date_incr_setup';
    l_stmt_id NUMBER := 0;

    l_bounds_valid BOOLEAN := true;

    l_exists NUMBER := NULL;

BEGIN

    -- Ensure that all the last_collection_date's are non-null
    l_stmt_id := 10;
    BEGIN
        SELECT 1
        INTO l_exists
        FROM opi_dbi_run_log_curr
          WHERE last_collection_date IS NULL
            AND source = p_source
            AND etl_id = p_etl_id
            AND rownum = 1;

        -- found a null last_collection_date
        RAISE collect_date_bounds_missing;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_bounds_valid := true;
    END;
     -- Ensure that the from_bound_date's are non null
    l_stmt_id := 20;
    BEGIN
        SELECT 1
        INTO l_exists
        FROM dual
        WHERE (EXISTS (SELECT from_bound_date
                         FROM opi_dbi_run_log_curr
                         WHERE from_bound_date IS NULL
                           AND source = p_source
                           AND etl_id = p_etl_id));

        RAISE collect_date_bounds_missing; -- found a null from bound date

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_bounds_valid := true;
    END;

    -- Ensure that the to_bound_date's are non null
    l_stmt_id := 30;
    BEGIN
        SELECT 1
        INTO l_exists
        FROM dual
        WHERE (EXISTS (SELECT to_bound_date
                         FROM opi_dbi_run_log_curr
                         WHERE to_bound_date IS NULL
                           AND source = p_source
                           AND etl_id = p_etl_id));

        RAISE collect_date_bounds_missing; -- found a null to bound date

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_bounds_valid := true;
    END;

    return l_bounds_valid;

EXCEPTION

    WHEN collect_date_bounds_missing THEN
        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id || ': ' ||
                                           'Found null last_collection_date for ETL ' ||
                                           p_etl_id || ' source ' ||
                                           p_source ||
                                           ' which means initial loads were never run. Please run initial load request set before running the incremental request set.');
        l_bounds_valid := false;
        return l_bounds_valid;

    WHEN OTHERS THEN
        rollback;

        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id ||
                                           ': ' || SQLERRM);

        l_bounds_valid := false;
        return l_bounds_valid;

END collect_date_incr_setup;


/*  run_incr_load

    API for ETL incremntal loads to that they are mean to run and not the
    incremental loads.

    The incremental load of an ETL should call this which when it returns true
    indicates that it is time to run the initial load and when it returns
    false indicates that it is time to run the incremental load
 */
FUNCTION run_incr_load (p_etl_id IN NUMBER, p_source IN NUMBER)
    RETURN BOOLEAN
IS

    l_proc_name VARCHAR2 (60) := 'run_incr_load';
    l_stmt_id NUMBER := 0;

    l_run_incr BOOLEAN := false;
    l_num_non_incr_rows NUMBER := -1;

BEGIN

    -- All that needs to be done is to ensure that for all rows, the last
    -- collection date is not NULL. If any row does not match is condition,
    -- then the incremental load cannot be run.
    l_stmt_id := 10;
    SELECT sum (1)
    INTO l_num_non_incr_rows
    FROM opi_dbi_run_log_curr
    WHERE source = p_source
      AND etl_id = p_etl_id
      AND last_collection_date IS NULL;


    l_stmt_id := 20;
    IF (l_num_non_incr_rows IS NULL) THEN
        l_run_incr := true;
    ELSE
        l_run_incr := false;
        BIS_COLLECTION_UTILITIES.PUT_LINE ('The incremental request set cannot be run because ' || l_num_non_incr_rows || ' rows in the runtime bounds log indicate that the initial load has not been run.');
        BIS_COLLECTION_UTILITIES.PUT_LINE (' Please run the initial load request set before running the incremental load request set.');

    END IF;

    l_stmt_id := 30;
    return l_run_incr;

EXCEPTION

    WHEN OTHERS THEN
        rollback;

        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id ||
                                           ': ' || SQLERRM);

        l_run_incr := false;
        return l_run_incr;

END run_incr_load;


END opi_dbi_common_mod_incr_pkg;

/
