--------------------------------------------------------
--  DDL for Package Body OPI_DBI_COMMON_MOD_INIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_COMMON_MOD_INIT_PKG" AS
/*$Header: OPIDCMODIB.pls 120.1 2005/08/10 01:59:36 sberi noship $ */

/*++++++++++++++++++++++++++++++++++++++++*/
/* Function and procedure declarations in this file but not in spec*/
/*++++++++++++++++++++++++++++++++++++++++*/

PROCEDURE seed_run_log_initial (errbuf OUT NOCOPY VARCHAR2,
                                retcode OUT NOCOPY NUMBER,
                                p_global_start_date IN DATE);

FUNCTION txn_id_init_setup (p_etl_id IN NUMBER, p_source IN NUMBER)
    RETURN BOOLEAN;

FUNCTION collect_date_init_setup (p_etl_id IN NUMBER, p_source IN NUMBER)
    RETURN BOOLEAN;

/*----------------------------------------*/


/*++++++++++++++++++++++++++++++++++++++++*/
/* PACKAGE LEVEL CONSTANTS */
/*++++++++++++++++++++++++++++++++++++++++*/

s_pkg_name CONSTANT VARCHAR2 (50) := 'opi_dbi_common_mod_init_pkg';
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

/*----------------------------------------*/

/*  run_common_module_init

    The common Module initial load is responsible for:
    1. Computing ETL bounds for the first time

    This function does not return with an exception in case of error
    but ends with a retcode of error. However helper functions are
    expected to throw exceptions. We do not look at the retcode/errbuf
    for helper functions. If a helper function fails, it is expected
    to write a error message to the log and to throw an exception
    back to this wrapper function.

    Date        Author              Action
    04/17/03    Dinkar Gupta        Wrote Function
    07/01/05	Sandeep Beri	    Modified Procedure for R12
				    Commom Module does not call WIP
				    Completions and Job Master after
				    its successful completion.
*/

PROCEDURE run_common_module_init (errbuf OUT NOCOPY VARCHAR2,
                                  retcode OUT NOCOPY NUMBER)
IS

    l_proc_name VARCHAR2 (60) := 'run_common_module_init';
    l_stmt_id NUMBER := 0;

    l_global_start_date DATE := NULL;

    l_bounds_warning BOOLEAN := false;

BEGIN

    -- get session parameters
    l_stmt_id := 10;
    IF (NOT (fnd_installation.get_app_info('OPI', s_status, s_industry,
                                           s_opi_schema))) THEN
        RAISE schema_info_not_found;
    END IF;

    -- check if the global set up is good
    l_stmt_id := 20;
    IF (NOT (check_global_setup ())) THEN
        RAISE global_setup_missing;
    END IF;

    -- get the DBI global start date
    l_stmt_id := 30;
    l_global_start_date := trunc (bis_common_parameters.get_global_start_date);

    -- compute the ETL bounds for the first time.
    l_stmt_id := 40;
    compute_initial_etl_bounds (errbuf, retcode, l_global_start_date,
                                s_opi_schema);

    -- check if stage succeeded
    l_stmt_id := 41;
    IF (retcode = s_ERROR) THEN
        RAISE stage_failure;
    END IF;

    -- check if some bounds are uncosted before calling any other
    -- procedure that can wipe out the stop reason code
    l_stmt_id := 50;
    l_bounds_warning := bounds_uncosted ();

    -- Print the discrete org collection bounds
    l_stmt_id := 60;
    print_opi_org_bounds;

    -- if uncosted transactions were found, return a warning.
    l_stmt_id := 70;
    IF (l_bounds_warning) THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE
            ('Common Module Initial Load terminated with warnings.');
        retcode := s_WARNING;
        errbuf := 'Common Module Initial Load Found Uncosted Transactions. ';

    ELSE
        -- terminate successfully
        BIS_COLLECTION_UTILITIES.PUT_LINE
            ('Common Module Initial Load terminated successfully.');
        retcode := s_SUCCESS;
        errbuf := '';
    END IF;

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
                  'Common Module Initial Load failed to get OPI schema info.';
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
                  'Common Module Initial Load could not find global setup of global start date and global currency code.';
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
                  'Common Module Initial Load failed.';
        return;

    WHEN OTHERS THEN
        rollback;

        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id ||
                                           ': ' ||  SQLERRM);

        retcode := s_ERROR;
        errbuf := s_pkg_name || '.' || l_proc_name || ' ' || '#' ||
                  l_stmt_id || ': ' || 'Common Module Initial Load Failed.';
        return;

END run_common_module_init;


/*  compute_initial_etl_bounds

    Computing the initial bounds for the all the ETLs.

    These include:
        Job Transactions ETL - WIP Completions, Actual Usage and Scrap
        Actual Resource Usage
        Resource Variance
        Job Master

    The computation can be broken down into the following stages:

    1.  Truncate the log and audit tables, OPI_DBI_RUN_LOG_CURR and
        OPI_DBI_RUN_LOG_AUDIT respectively.
    2.  Populate the initial data for all the different ETLs in the
        current log table OPI_DBI_RUN_LOG_CURR.
    3.  Compute the end bounds for all the rows in the current log table,
        OPI_DBI_RUN_LOG_CURR.

    Data is committed when all steps are successful.

    Parameters:
    p_global_start_date - DBI global start date. Expecting it to be
                          trunc'ed already.
    p_opi_schema - Schema name for OPI.

    Date        Author              Action
    04/17/03    Dinkar Gupta        Wrote Function
    08/14/03    Dinkar Gupta        Changed the bounds computation to
                                    perform only inserts for the initial load.
                                    All updates removed on recommendation
                                    of performance team.
*/


PROCEDURE compute_initial_etl_bounds (errbuf OUT NOCOPY VARCHAR2,
                                      retcode OUT NOCOPY NUMBER,
                                      p_global_start_date IN DATE,
                                      p_opi_schema IN VARCHAR2)
IS
    l_proc_name VARCHAR2 (60) := 'compute_initial_etl_bounds';
    l_stmt_id NUMBER := 0;


BEGIN

    -- initial load requires clean tables.
    l_stmt_id := 10;
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || p_opi_schema || '.' ||
                       'OPI_DBI_RUN_LOG_AUDIT');

    l_stmt_id := 20;
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || p_opi_schema || '.' ||
                       'OPI_DBI_RUN_LOG_CURR');

    -- Create all the data for all the different MAnufacuturing Management
    -- ETLs in OPI_DBI_RUN_LOG_CURR
    l_stmt_id := 30;
    seed_run_log_initial (errbuf, retcode, p_global_start_date);

    -- success so far, then commit everything in one shot
    l_stmt_id := 50;
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
        RAISE;   -- propagate exception to wrapper

END compute_initial_etl_bounds;


/* seed_run_log_initial

    The following ETL bounds need to be computed and seeded in the
    OPI_DBI_RUN_LOG_CURR table:

    1. Job Transaction ETL  (WIP Completions, Actual Usage and Scrap)
            OPI sourced rows --
                One row per discrete org with the start_txn_id as the first
                transaction id in MMT after global start date.

            OPM sourced rows --
                One row with the from bound date as Global Start Date and to
		bound date as the sysdate with date and time taken during the
		run of this program. The organization id for thsi one row would
		be NULL.

    4. Actual Resource Usage ETL
            OPI sourced rows --
                One row with start_txn_id as the first transaction id
                in WT after global start date.

	    OPM sourced rows --
                One row with the from bound date as Global Start Date and to
		bound date as the sysdate with date and time taken during the
		run of this program. The organization id for thsi one row would
		be NULL.

    5. Resource Variance  ETL
            OPI sourced rows --
                One row with the from bound date as Global Start Date and to
		bound date as the sysdate with date and time taken during the
		run of this program.

            OPM sourced rows --
                One row with the from bound date as Global Start Date and to
		bound date as the sysdate with date and time taken during the
		run of this program.

    6. Resource Variance  ETL
            OPI sourced rows --
                One row with the from bound date as Global Start Date and to
		bound date as the sysdate with date and time taken during the
		run of this program.

            OPM sourced rows --
                One row with the from bound date as Global Start Date and to
		bound date as the sysdate with date and time taken during the
		run of this program.


    The goal of one centralized seeding function is to minimize the
    number of SQLs to populate the data.

    Thus for OPI sourced rows:
        The Job Transactions ETL -Scrap, WIP Completion and Actual Usage
        rows will be populated in the one SQL from MMT.

        The Actual Resource ETL row will be populated in one SQL from WT.

    For the OPM rows:
        All OPM Rows for all ETL's would be populated in one SQL which would set
	the from bound date as the Global Start Date and the to bound date as
	the sysdate.

    Comment on max bounds on tables (OPI):
    Note that for all bounds, we pick max + 1. That is because the
    the upper bound is meant to be strictly higher than the
    id's to be collected. Since all the id sequences are discrete
    and increasing, just adding +1 ensures that if we start next time
    at the max + 1 of this run, then no transaction_id will be
    ignored.
    Also, max + 1 is not a real transaction_id and may never be.
    Since the bounds should never be NULL, and the start id's are
    always seeded to be 0, next_Start must be 0 for empty tables.


    DO NOT COMMIT ANY DATA HERE!!! LEAVE THAT FOR THE CALLING FUNCTION.

    Paramters:
    p_global_start_date - DBI global start date. Expect it to be
                          trunc'ed already.

    Date        Author              Action
    04/17/03    Dinkar Gupta        Wrote Function
    07/01/05    Sandeep Beri	    Modified OPM logic of computing bounds
				    Bounds for all OPM ETL's are now date bounds.
				    Store GSD (trunc'd) as the from bound date
				    and a snapshot of the sysdate(with date time)
				    as the to bound date. OPM bounds no longer come
				    from GL_SUBR_LED.
*/


PROCEDURE seed_run_log_initial (errbuf OUT NOCOPY VARCHAR2,
                                retcode OUT NOCOPY NUMBER,
                                p_global_start_date IN DATE)
IS

    l_proc_name VARCHAR2 (60) := 'seed_run_log_initial';
    l_stmt_id NUMBER := 0;

    -- the highest transaction in MMT + 1.
    l_max_mmt_plus_one NUMBER := NULL;

    -- the first transaction in MMT past global start date
    l_mmt_start_txn_id NUMBER := NULL;

    -- the highest transaction in WT + 1.
    l_max_wt_plus_one NUMBER := NULL;

    -- the first transaction in WT past global start date
    l_wt_start_txn_id NUMBER := NULL;

    -- Snapshotting sysdate with date time in a local variable
    l_to_bound_date DATE;

 BEGIN

    -- Select the max transaction id from MMT
    -- for the transaction id bounds.
    -- If the table is empty, then make the start at transaction id 0.

    l_stmt_id := 10;
    SELECT nvl (max (transaction_id), -1) + 1
      INTO l_max_mmt_plus_one
      FROM mtl_material_transactions;

    -- Storing sysdate in a local variable for insertion into log as we do not want to miss any
    -- horizon between OPM and OPI inserts.
    l_stmt_id := 20;
    SELECT sysdate
    INTO l_to_bound_date
    FROM DUAL;

    -- Select the start transaction id's in MMT
    -- past the global start date.
    -- If there are no transactions past the global start date,
    -- then just pick a transaction_id one higher than the max of
    -- of MMT.

    l_stmt_id := 30;
    SELECT /*+ parallel(mtl_material_transactions) */
        nvl (min (transaction_id), l_max_mmt_plus_one)
      INTO l_mmt_start_txn_id
      FROM mtl_material_transactions
      WHERE transaction_date >= p_global_start_date;

    -- Create a row for each discrete org for the Job Transactions ETL
    --(Scrap, WIP completions, Material Usage) with the start
    -- transaction_id set to the first transaction in MMT after the
    -- global_start_date.
    -- Note the last_transaction_date here, it is computed for PTP etl.
    -- Note that this is max transaction date between the start and stop
    -- transactions, because the last transaction itself could have been
    -- backdated.

    l_stmt_id := 50;
    INSERT /*+ append parallel (opi_dbi_run_log_curr) */
    INTO opi_dbi_run_log_curr (
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
        request_id)
    SELECT /*+ parallel (bounds) parallel (etls) */
        bounds.organization_id,
        OPI_SOURCE,         -- OPI rows
        NULL,
        bounds.start_txn_id,
        bounds.next_start_txn_id,
	NULL,
	NULL,
        JOB_TXN_ETL,
        bounds.stop_reason_code,
        decode (bounds.stop_reason_code,
                STOP_UNCOSTED, bounds.last_transaction_date,
                sysdate),
        sysdate,
        sysdate,
        s_user_id,
        s_user_id,
        s_login_id,
	s_program_id,
        s_program_login_id,
        s_program_application_id,
        s_request_id
      FROM
        (SELECT /*+ parallel (mmt_bounds) parallel (mmt) */
               mmt_bounds.organization_id,
               mmt_bounds.start_txn_id,
               mmt_bounds.next_start_txn_id,
               trunc (max (mmt.transaction_date))
               last_transaction_date,
               mmt_bounds.stop_reason_code
          FROM
            (SELECT /* parallel (uncosted) parallel (orgs) */
                    orgs.organization_id,
                    l_mmt_start_txn_id start_txn_id,
                    nvl (uncosted.uncosted_id, l_max_mmt_plus_one)
                    next_start_txn_id,
                    decode (uncosted.uncosted_id,
                            NULL, STOP_ALL_COSTED,
                            STOP_UNCOSTED) stop_reason_code
              FROM (SELECT /*+ PARALLEL (mtl_material_transactions) */
                           min (transaction_id) uncosted_id,
                           organization_id
                     FROM mtl_material_transactions
                     WHERE costed_flag IN ('N', 'E')
                     AND transaction_id > l_mmt_start_txn_id
                     GROUP BY organization_id) uncosted,
                  (SELECT /*+ parallel (mtl_parameters) */
                          organization_id
                     FROM mtl_parameters
                     WHERE process_enabled_flag <> 'Y') orgs
              WHERE orgs.organization_id = uncosted.organization_id (+))
             mmt_bounds,
             mtl_material_transactions mmt
          WHERE mmt_bounds.organization_id = mmt.organization_id (+)
            AND (mmt.transaction_id BETWEEN mmt_bounds.start_txn_id AND
                                       mmt_bounds.next_start_txn_id
                 OR mmt.transaction_id IS NULL)
          GROUP BY
                mmt_bounds.organization_id,
                mmt_bounds.start_txn_id,
                mmt_bounds.next_start_txn_id,
                mmt_bounds.stop_reason_code) bounds;

    -- commit due to insert append
    l_stmt_id := 52;
    commit;

    -- Create a row for process for each ETL with the
    -- from bound date set to the GSD and the to bound
    -- date as the date time snapshot taken above in
    -- the local variable l_to_bound_date.
    -- Organization id would be null for such OPM rows.
    l_stmt_id := 60;
    INSERT INTO opi_dbi_run_log_curr (
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
        request_id)
    SELECT
        NULL,
        OPM_SOURCE,         -- OPM rows
        NULL,
        NULL,
        NULL,
        p_global_start_date,
        l_to_bound_date,
        etls.etl_id,
        NULL,
        sysdate,
        sysdate,
        sysdate,
        s_user_id,
        s_user_id,
        s_login_id,
	s_program_id,
        s_program_login_id,
        s_program_application_id,
        s_request_id
      FROM
        (SELECT JOB_TXN_ETL etl_id FROM dual
         UNION ALL
         SELECT ACTUAL_RES_ETL FROM dual
	 UNION ALL
         SELECT RESOURCE_VAR_ETL FROM dual
	 UNION ALL
         SELECT JOB_MASTER_ETL FROM dual) etls;


    -- Max bounds for the Actual Resource Utilization ETL
    l_stmt_id := 70;
    SELECT nvl (max (transaction_id), -1) + 1
      INTO l_max_wt_plus_one
      FROM wip_transactions;

    -- start bound for actual resource utilization ETL
    l_stmt_id := 90;
    SELECT /*+ index_ffs(wip_transactions) parallel_index(wip_transactions) */
        nvl (min (transaction_id), l_max_wt_plus_one)
      INTO l_wt_start_txn_id
      FROM wip_transactions
      WHERE transaction_date >= p_global_start_date;

    -- For the Actual Resource Usage create a row:
    -- for OPI with start_txn_id as the first transaction past global
    -- start date in WT. There cannot be any uncosted resource transactions.

        l_stmt_id := 110;
    INSERT INTO opi_dbi_run_log_curr (
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
        request_id)
    SELECT
        NULL,
        src.source_type,
        NULL,
	l_wt_start_txn_id,
	l_max_wt_plus_one,
        NULL,
	NULL,
        ACTUAL_RES_ETL,
        NULL,
        sysdate,
        sysdate,
        sysdate,
        s_user_id,
        s_user_id,
        s_login_id,
	s_program_id,
        s_program_login_id,
        s_program_application_id,
        s_request_id
      FROM
        (SELECT OPI_SOURCE source_type FROM dual
        ) src;


    -- For Resource and Job Master ETLs, we need from bound date
    -- and to bound date for OPI also.

    l_stmt_id := 120;

     INSERT INTO opi_dbi_run_log_curr (
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
        request_id)
    SELECT
        NULL,
        OPI_SOURCE,         -- OPI rows
        NULL,
        NULL,
        NULL,
        p_global_start_date,
        l_to_bound_date,
        etls.etl_id,
        NULL,
        sysdate,
        sysdate,
        sysdate,
        s_user_id,
        s_user_id,
        s_login_id,
	s_program_id,
        s_program_login_id,
        s_program_application_id,
        s_request_id
      FROM
        (SELECT RESOURCE_VAR_ETL etl_id FROM dual
	 UNION ALL
         SELECT JOB_MASTER_ETL FROM dual) etls;
        -- terminate successfully
    l_stmt_id := 130;
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
                  'Failed to seed initial data into the run log tables.';
        RAISE;    -- propagate exception to wrapper


END seed_run_log_initial;


/*  init_end_bounds_setup

    API called by ETLs to ensure that the bounds they are running for are
    set up correctly.

    OPI : For the Material and Actual Resource Usage ETLs,
    This requires checking if all the next_start_txn_id values are not null
    for the given ETL and the source.

    OPM : All ETL's and OPI: Job Master and Resource Variance
    This requires checking if all the dates voz. from_bound_date,
    to_bound_date and last_collection_date are set up correctly or not.

    Parameters:
    p_etl_id - etl_id of ETL invoking API.
    p_source - 1 for OPI, 2 for OPM

    Return:
    l_bounds_valid - true if the bounds are valid
                     false o.w.

    Date        Author              Action
    04/23/03    Dinkar Gupta        Wrote Function
    07/01/05	Sandeep Beri	    Modified the IF conditions to the
				    transaction id set uo check call as
				    in R12, no OPM ETL would have txn id bounds.
*/
FUNCTION init_end_bounds_setup (p_etl_id IN NUMBER, p_source IN NUMBER)
    RETURN BOOLEAN
IS

    l_proc_name VARCHAR2 (60) := 'init_end_bounds_setup';
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

    -- For the Job Transactions ETL
    -- and Actual Resource Usage (OPI), the behaviour is based on transaction
    -- id's
    l_stmt_id := 10;
    IF ( ((p_etl_id = JOB_TXN_ETL) OR
         (p_etl_id = ACTUAL_RES_ETL)) AND p_source = OPI_SOURCE) THEN
       --{
       l_bounds_valid := txn_id_init_setup (p_etl_id, p_source);
       --}

    -- For Resource Variance and Job Master in OPI and all OPM ETL's, the behaviour is
    -- based on dates.
    ELSE
    --{
        l_bounds_valid := collect_date_init_setup (p_etl_id, p_source);
    --}
    END IF;


    return l_bounds_valid;

EXCEPTION


    WHEN run_common_mod_init THEN
        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id ||
                                           ': ' || 'Run time bounds have not been set up. Please run the initial load request set.');

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

END init_end_bounds_setup;

/*  txn_id_init_setup

    Ensure that all the txn_id bounds are correctly setup for
    the initial load of the ETL with the source passed in as arguments.

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
    07/23/03    Dinkar Gupta        Also make sure that the common
                                    module log table is not empty i.e.
                                    the basic data has been seeded.
*/
FUNCTION txn_id_init_setup (p_etl_id IN NUMBER, p_source IN NUMBER)
    RETURN BOOLEAN
IS

    l_proc_name VARCHAR2 (60) := 'txn_id_init_setup';
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
        FROM dual
        WHERE (EXISTS (SELECT next_start_txn_id
                         FROM opi_dbi_run_log_curr
                         WHERE next_start_txn_id IS NULL
                           AND source = p_source
                           AND etl_id = p_etl_id));

        RAISE txn_id_bounds_missing; -- found a missing start_txn_id

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_bounds_valid := true;
    END;


    return l_bounds_valid;

EXCEPTION

    WHEN txn_id_bounds_missing THEN
        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' || l_proc_name || ' ' ||
                              '#' || l_stmt_id || ': ' ||
                              'Found missing transaction_id bounds for ETL ' ||
                              p_etl_id || ' source ' || p_source || '.');
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

END txn_id_init_setup;

/*  collect_date_init_setup

    Ensure that all the collection date bounds are correctly setup for
    the initial load of the ETL with the source passed in as arguments.

    This requires checking that the last_collection_date is
    NULL. Also it checks that the from_bound_date and the to_bound_date
    are not null.

    Parameters:
    p_etl_id - etl_id of ETL invoking API.
    p_source - 1 for OPI, 2 for OPM

    Return:
    l_bounds_valid - true if the bounds are valid
                     false o.w.

    Date        Author              Action
    04/23/03    Dinkar Gupta        Wrote Function

*/
FUNCTION collect_date_init_setup (p_etl_id IN NUMBER, p_source IN NUMBER)
    RETURN BOOLEAN
IS

    l_proc_name VARCHAR2 (60) := 'collect_date_init_setup';
    l_stmt_id NUMBER := 0;

    l_bounds_valid BOOLEAN := true;

    l_exists NUMBER := NULL;

BEGIN

    -- Ensure that all the last_collection_date's are null
    l_stmt_id := 10;
    BEGIN
        SELECT 1
        INTO l_exists
          FROM opi_dbi_run_log_curr
          WHERE last_collection_date IS NOT NULL
            AND source = p_source
            AND etl_id = p_etl_id
            AND rownum = 1;

        -- found a non-null last_collection_date
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
                                           'Found missing dates for ETL ' ||
                                            p_etl_id || ' source ' ||
                                            p_source ||
                                           ' before initial load was run.');
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

END collect_date_init_setup;


/*  run_initial_load

    API for ETL initial loads to that they are mean to run and not the
    incremental loads.

    The initial load of an ETL should call this which when it returns true
    indicates that it is time to run the initial load and when it returns
    false indicates that it is time to run the incremental load
 */
FUNCTION run_initial_load (p_etl_id IN NUMBER, p_source IN NUMBER)
    RETURN BOOLEAN
IS

    l_proc_name VARCHAR2 (60) := 'run_initial_load';
    l_stmt_id NUMBER := 0;

    l_run_init BOOLEAN := false;
    l_num_non_init_rows NUMBER := -1;

BEGIN

    -- All that needs to be done is to ensure that the last collection
    -- date is NULL everywhere. If any row does not match is condition, then
    -- the initial load cannot be run.
    l_stmt_id := 10;
    SELECT sum (1)
    INTO l_num_non_init_rows
    FROM opi_dbi_run_log_curr
    WHERE source = p_source
      AND etl_id = p_etl_id
      AND last_collection_date IS NOT NULL;


    l_stmt_id := 20;
    IF (l_num_non_init_rows IS NULL) THEN
        l_run_init := true;
    ELSE
        l_run_init := false;
        BIS_COLLECTION_UTILITIES.PUT_LINE ('The initial load of this concurrent program cannot be run independently. Please run the initial load request set if it has not already been run successfully.');
        BIS_COLLECTION_UTILITIES.PUT_LINE (' Alternatively, run the incremental load request set if the initial load request set has already run.');

    END IF;

    l_stmt_id := 30;
    return l_run_init;

EXCEPTION

    WHEN OTHERS THEN
        rollback;

        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id ||
                                           ': ' || SQLERRM);

        l_run_init := false;
        return l_run_init;

END run_initial_load;


/*  check_global_setup

    Checks to see if basic global parameters are set up.
    Currently these include the:
    1. Global start date
    2. Global currency code

    Parameters: None

    Date        Author              Action
    04/23/03    Dinkar Gupta        Wrote Function
*/
FUNCTION check_global_setup
    RETURN BOOLEAN
IS
    l_proc_name VARCHAR2 (60) := 'check_global_setup';
    l_stmt_id NUMBER := 0;

    l_setup_good BOOLEAN := false;

    l_list dbms_sql.varchar2_table;

BEGIN

    -- Parameters we want to check for
    l_list(1) := 'BIS_PRIMARY_CURRENCY_CODE';
    l_list(2) := 'BIS_GLOBAL_START_DATE';

    l_setup_good := bis_common_parameters.check_global_parameters(l_list);
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


/*  bounds_uncosted

    Return true if some rows have bounds that show uncosted transactions.
    This can only happen for OPI sourced Material ETLs.

    Such rows will be distinguished by the fact that their stop reason
    code will be STOP_UNCOSTED. This means that the stop reason code
    must not have been wiped out by the etl_report_success API

    Date        Author              Action
    04/23/03    Dinkar Gupta        Wrote Function

*/
FUNCTION bounds_uncosted
    RETURN BOOLEAN
IS

    l_proc_name VARCHAR2 (60) := 'bounds_uncosted';
    l_stmt_id NUMBER := 0;
    l_bounds_uncosted BOOLEAN := false;
    l_warning NUMBER := s_SUCCESS;

BEGIN

    -- check if any row has uncosted transactions
    l_stmt_id := 10;
    BEGIN
        SELECT s_WARNING
        INTO l_warning
          FROM OPI_DBI_RUN_LOG_CURR
          WHERE stop_reason_code = STOP_UNCOSTED
          AND rownum = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_warning := s_SUCCESS;
    END;

    -- If there are uncosted transactions, return true
    l_stmt_id := 20;
    IF (l_warning = s_WARNING) THEN
        l_bounds_uncosted := true;
    END IF;

    RETURN l_bounds_uncosted;

END bounds_uncosted;


/*  print_opi_org_bounds

    Print the MMT bounds before which the OPI discrete orgs stopped, and the
    reason for stopping
*/
PROCEDURE print_opi_org_bounds
IS

    l_proc_name VARCHAR2 (60) := 'bounds_uncosted';
    l_stmt_id NUMBER := 0;

    -- Cursor for all the org bounds
    CURSOR opi_org_bounds_csr IS
        SELECT /*+ index(log, OPI_DBI_RUN_LOG_CURR_N1) use_nl(log mp)*/
               mp.organization_code,
               log.next_start_txn_id,
               decode (log.stop_reason_code,
                       STOP_ALL_COSTED, 'All Costed',
                       STOP_UNCOSTED, 'Uncosted',
                       'Data Issue?') stop_reason,
               nvl (mmt.transaction_date, sysdate) data_until
          FROM opi_dbi_run_log_curr log,
               mtl_parameters mp,
               mtl_material_transactions mmt
          WHERE source = OPI_SOURCE
            AND etl_id = JOB_TXN_ETL  -- any ETL is good enough
            AND log.next_start_txn_id = mmt.transaction_id (+)
            AND log.organization_id = mp.organization_id;
BEGIN

    -- print the header
    l_stmt_id := 10;

    BIS_COLLECTION_UTILITIES.PUT_LINE (
            RPAD ('Organization Code', 20) ||
            RPAD ('Txn Id Stopped Before', 25) ||
            RPAD ('Data Collected Until', 25) ||
            RPAD ('Reason Stopped', 20));


    BIS_COLLECTION_UTILITIES.PUT_LINE (
            RPAD ('-----------------', 20) ||
            RPAD ('---------------------', 25) ||
            RPAD ('--------------------', 25) ||
            RPAD ('--------------', 20));


    -- just print all the bounds
    l_stmt_id := 20;
    FOR opi_org_bounds_rec IN opi_org_bounds_csr
    LOOP

        BIS_COLLECTION_UTILITIES.PUT_LINE (
                RPAD (opi_org_bounds_rec.organization_code, 20) ||
                RPAD (opi_org_bounds_rec.next_start_txn_id, 25) ||
                RPAD (opi_org_bounds_rec.data_until, 25) ||
                RPAD (opi_org_bounds_rec.stop_reason, 20));

    END LOOP;


    -- print table end
    l_stmt_id := 30;
    BIS_COLLECTION_UTILITIES.PUT_LINE (LPAD ('', 90, '-'));

    RETURN;

EXCEPTION

    WHEN OTHERS THEN
        rollback;

        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           'Error when printing org bounds.');

        RAISE;    -- propagate exception to wrapper


END print_opi_org_bounds;


END opi_dbi_common_mod_init_pkg;

/
