--------------------------------------------------------
--  DDL for Package Body OPI_DBI_INV_CCA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_INV_CCA_PKG" AS
/*$Header: OPIDEICCAB.pls 120.9 2006/03/28 21:33:43 visgupta noship $ */


/**************************************************
* File scope variables
**************************************************/

-- Package level variables for session info-
-- including schema name for truncating and
-- collecting stats. Initialized in check_global_setup.
s_opi_schema      VARCHAR2(30);
s_status          VARCHAR2(30);
s_industry        VARCHAR2(30);

-- DBI Global start date
s_global_start_date DATE;
s_r12_migration_date DATE;

-- Conversion rate related variables: global currency code and rate type
s_global_curr_code  VARCHAR2(10);
s_global_rate_type  VARCHAR2(15);

-- secondary global currency
s_secondary_curr_code  VARCHAR2(10);
s_secondary_rate_type  VARCHAR2(15);

-- Package level variables for the user logged in
s_user_id    NUMBER;
s_login_id   NUMBER;
s_program_id NUMBER;
s_program_login_id NUMBER;
s_program_application_id NUMBER;
s_request_id NUMBER;

/**************************************************
* Common Procedures (to initial and incremental load)
*
* File scope functions (not in spec)
**************************************************/

-- Check for primary currency code and global start date
FUNCTION check_global_setup
    RETURN BOOLEAN;

-- Print out error message in a consistent manner
FUNCTION err_mesg (p_mesg IN VARCHAR2,
                   p_proc_name IN VARCHAR2,
                   p_stmt_id IN NUMBER)
    RETURN VARCHAR2;

/**************************************************
* Initial Load Procedures
*
* File scope functions (not in spec)
**************************************************/

-- Initialization
PROCEDURE cca_initialize_init;

-- Extract all MMT Cyclecount transactions into a staging table
PROCEDURE extract_cca_mmt_init;

-- Extract Discrete adjustment entry data
PROCEDURE extract_discrete_adj_init (p_global_start_date IN DATE);

-- Extract Process adjustment entry data
PROCEDURE extract_process_adj_init (p_global_start_date IN DATE);

-- Extract the exact match entry data
PROCEDURE extract_exact_matches_init;

-- Compute the conversion rates
PROCEDURE compute_cca_conv_rates_init (p_global_curr_code IN VARCHAR2,
                                       p_global_rate_type IN VARCHAR2);

-- Populate the data into the fact table
PROCEDURE populate_fact_init;


/**************************************************
* Incremental Load Procedures
*
* File scope functions (not in spec)
**************************************************/

-- Initialization
PROCEDURE cca_initialize_incr;

-- Extract Discrete adjustment entry data
PROCEDURE extract_discrete_adj_incr (p_global_start_date IN DATE);

-- Extract Process adjustment entry data
PROCEDURE extract_process_adj_incr (p_global_start_date IN DATE);

-- Extract the exact match entry data
PROCEDURE extract_exact_matches_incr;

-- Compute the conversion rates
PROCEDURE compute_cca_conv_rates_incr (p_global_curr_code IN VARCHAR2,
                                       p_global_rate_type IN VARCHAR2);

-- Populate the data into the fact table
PROCEDURE populate_fact_incr;

/**************************************************
* Common Procedures Definitions
**************************************************/

/*  check_global_setup

    Checks to see if basic global parameters are set up.
    Currently these include the:
    1. Global start date
    2. Global currency code

    Parameters: None

    History:
    Date        Author              Action
    01/12/04    Dinkar Gupta        Defined function.
    06/07/04    Dinkar Gupta        Added initialization of all file scope
                                    variables to this function for new
                                    GSCC standard that does not like
                                    initialization outside BEGIN/END block.
*/
FUNCTION check_global_setup
    RETURN BOOLEAN
IS
    l_proc_name CONSTANT VARCHAR2 (40) := 'check_global_setup';
    l_stmt_id NUMBER;

    l_setup_good BOOLEAN;

    l_list dbms_sql.varchar2_table;

BEGIN

    -- Initialization block
    l_setup_good := false;
    l_stmt_id := 0;

    -- Initialize file scope static variables
    -- Package level variables for session info-
    -- including schema name for truncating and
    -- collecting stats
    s_opi_schema := NULL;
    s_status := NULL;
    s_industry := NULL;

    -- DBI Global start date
    s_global_start_date := NULL;

    -- Conversion rate related variables: global currency code and rate type
    s_global_curr_code := NULL;
    s_global_rate_type := NULL;
    s_secondary_curr_code := NULL;
    s_secondary_rate_type := NULL;

    -- Package level variables for the user logged in
    s_user_id := nvl(fnd_global.user_id, -1);
    s_login_id := nvl(fnd_global.login_id, -1);
    s_program_id := nvl(fnd_global.conc_program_id, -1);
    s_program_login_id := nvl(fnd_global.conc_login_id , -1);
    s_program_application_id := nvl(fnd_global.prog_appl_id , -1);
    s_request_id := nvl(fnd_global.conc_request_id, -1);

    -- Parameters we want to check for
    l_list(1) := 'BIS_PRIMARY_CURRENCY_CODE';
    l_list(2) := 'BIS_GLOBAL_START_DATE';

    l_stmt_id := 10;
    l_setup_good := bis_common_parameters.check_global_parameters(l_list);
    return l_setup_good;

EXCEPTION

    WHEN OTHERS THEN
        rollback;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));

        l_setup_good := false;
        return l_setup_good;


END check_global_setup;


/* err_mesg
    Return a C_ERRBUF_SIZE character long, properly formatted error
    message with the package name, procedure name and message.

    Parameters:
    p_mesg - Actual message to be printed
    p_proc_name - name of procedure that should be printed in the message
     (optional)
    p_stmt_id - step in procedure at which error occurred
     (optional)

    History:
    Date        Author              Action
    01/12/04    Dinkar Gupta        Defined function.
*/

FUNCTION err_mesg (p_mesg IN VARCHAR2,
                   p_proc_name IN VARCHAR2,
                   p_stmt_id IN NUMBER)
    RETURN VARCHAR2
IS

    l_proc_name CONSTANT VARCHAR2 (60) := 'err_mesg';
    l_stmt_id NUMBER;

    -- The variable declaration cannot take C_ERRBUF_SIZE (a defined constant)
    -- as the size of the declaration. I have to put 300 here.
    l_formatted_message VARCHAR2 (300);

BEGIN

    -- initialization block
    l_stmt_id := 0;

    -- initialization block
    l_formatted_message := NULL;

    l_stmt_id := 10;
    l_formatted_message := substr ((C_PKG_NAME || '.' || p_proc_name || ' #' ||
                                   to_char (p_stmt_id) || ': ' || p_mesg),
                                   1, C_ERRBUF_SIZE);

    commit;

    return l_formatted_message;

EXCEPTION

    WHEN OTHERS THEN
        -- the exception happened in the exception reporting function !!
        -- return with ERROR.
        l_formatted_message := substr ((C_PKG_NAME || '.' || l_proc_name ||
                                       ' #' ||
                                        to_char (l_stmt_id) || ': ' ||
                                       SQLERRM),
                                       1, C_ERRBUF_SIZE);

        l_formatted_message := 'Error in error reporting.';
        return l_formatted_message;

END err_mesg;


/**************************************************
* Initial Load Procedure Definitions
**************************************************/

/* run_initial_load

    Wrapper routine for the initial load of the cycle count accuracy ETL.

    Parameters:
    retcode - 0 on successful completion, -1 on error and 1 for warning.
    errbuf - empty on successful completion, message on error or warning


    R12 Changes
    -----------
    Made changes to calling of procedures and commit.
    -------------------------------


    History:
    Date        Author              Action
    01/12/04    Dinkar Gupta        Defined procedure.
    03/04/04    Dinkar Gupta        Added call to OPM package.
    07/05/05    Vishal Gupta        Made Changes for R12.

*/

PROCEDURE run_initial_load (errbuf OUT NOCOPY VARCHAR2,
                            retcode OUT NOCOPY NUMBER)
IS

    l_proc_name CONSTANT VARCHAR2 (40) := 'run_initial_load';
    l_stmt_id NUMBER;


BEGIN

    -- initialization block
    l_stmt_id := 0;

    l_stmt_id := 10;
    -- Check for DBI global parameter setup, initialize file scope variables,
    -- check for bounds and truncate tables.
    BIS_COLLECTION_UTILITIES.PUT_LINE ('Initializing cycle count initial load ...');
    cca_initialize_init ();

    l_stmt_id := 20;
    -- Set up the bounds for Cycle Count accuracy in the log table.
    -- Commit will be done
    BIS_COLLECTION_UTILITIES.PUT_LINE (
        'Setting up bounds for Process and Discrete ...');
    OPI_DBI_BOUNDS_PKG.MAINTAIN_OPI_DBI_LOGS (	p_etl_type=> C_ETL_TYPE,
						p_load_type=> C_LOAD_INIT);


    l_stmt_id := 30;
    -- Make a call to the OPM extraction for PreR12. Do this within
    -- a begin/end block and throw a custom exception if the
    -- OPM code ends with an error.
    -- first check R12 migration date > GSD
    BIS_COLLECTION_UTILITIES.PUT_LINE ('R12 Migration Date ...' || s_r12_migration_date);

    -- R12 date will not be null. There will be some suitable date returned by
    -- opi_dbi_rpt_util_pkg.get_inv_convergence_date
    IF (s_r12_migration_date > s_global_start_date) THEN
    --{
        BIS_COLLECTION_UTILITIES.PUT_LINE (
                'Extracting data for Pre R12 rocess manufacturing organizations ....');
        BEGIN

                opi_dbi_inv_cca_opm_pkg.run_initial_load_opm (errbuf, retcode);
                commit;  -- commit if successful


        EXCEPTION

                WHEN OTHERS THEN
                RAISE OPM_EXTRACTION_ERROR;

        END;
    --}
    ELSE
    --{
        BIS_COLLECTION_UTILITIES.PUT_LINE (
        'Migration date is less than GSD. Skipping PreR12 Process Cycle Count Extraction ....');
    --}
    END IF;


    l_stmt_id := 40;
    -- Extract all Cycle count transactions from MMT inot a staging table
    BIS_COLLECTION_UTILITIES.PUT_LINE (
        'Extracting cycle count trasnactions into a staging table ...');
    extract_cca_mmt_init ();

    l_stmt_id := 50;
    --
    commit;

    l_stmt_id := 55;
    -- Call API to load ledger data into Global temp table
    -- This temp table will be joined to extract process adjustments
    BIS_COLLECTION_UTILITIES.PUT_LINE (
        'Loading Ledger data into temp table ...');
    OPI_DBI_BOUNDS_PKG.load_opm_org_ledger_data;

     l_stmt_id := 57;
    -- Committing the data. Since the temp table is made with On Commit preserve rows
    -- there will be no problem.
    commit;

    l_stmt_id := 60;
    -- Extract the adjustment entry data from MMT/MTA using the
    -- bounds just set up.
    BIS_COLLECTION_UTILITIES.PUT_LINE (
        'Extracting cycle count adjustment information for discrete manufacturing orgs ...');
    extract_discrete_adj_init (s_global_start_date);

     l_stmt_id := 70;
    -- Due to the bulk insert in parallel mode, commit before
    -- inputting more data to the staging table.
    commit;

    l_stmt_id := 80;
    -- Extract the adjustment entry data from MMT/MTA using the
    -- bounds just set up.
    BIS_COLLECTION_UTILITIES.PUT_LINE (
        'Extracting cycle count adjustment information for Process manufacturing orgs ...');
    extract_process_adj_init (s_global_start_date);

    l_stmt_id := 90;
    -- Due to the bulk insert in parallel mode, commit before
    -- inputting more data to the staging table.
    commit;

    l_stmt_id := 100;
    -- Extract the exact matches entry data from MCCE. Collect all rows
    -- with last_update_date greater than the global start date.
    BIS_COLLECTION_UTILITIES.PUT_LINE (
        'Extracting cycle count exact match information for discrete manufacturing organizations ...');
    extract_exact_matches_init ();

    l_stmt_id := 110;
    -- Due to the bulk insert in parallel mode, commit before
    -- moving ahead.
    commit;

    l_stmt_id := 120;
    -- Compute the conversion rates for all org/date pairs in the
    -- staging table. This API will now commit, due to an
    -- insert+append hint.
    BIS_COLLECTION_UTILITIES.PUT_LINE (
        'Computing conversion rates for all extracted cycle counting data ...');
    compute_cca_conv_rates_init (s_global_curr_code, s_global_rate_type);

    l_stmt_id := 130;
    -- Commit the conversion rates found before finally merging all
    -- data to the fact table.
    commit;

    l_stmt_id := 140;
    -- Insert all the data into the fact table in one shot.
    BIS_COLLECTION_UTILITIES.PUT_LINE ('Inserting data into the fact table ...');
    populate_fact_init ();

    l_stmt_id := 150;
    -- Update the bounds table
    BIS_COLLECTION_UTILITIES.PUT_LINE ('Updating run time bounds for next run ...');
    OPI_DBI_BOUNDS_PKG.SET_LOAD_SUCCESSFUL(C_ETL_TYPE, C_LOAD_INIT);

    l_stmt_id := 160;
    -- Truncate the staging table, commit the data to the fact table
    -- and update the CCA related bounds in one database transaction
    -- for consistency.
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
                       'opi_dbi_inv_cca_stg');

    l_stmt_id := 170;
    -- Truncate the MMT staging table, commit the data to the fact table
    -- and update the CCA related bounds in one database transaction
    -- for consistency.
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
                       'opi_dbi_mmt_cca_stg');


    -- return successfully
    retcode := C_SUCCESS;
    errbuf := '';

    BIS_COLLECTION_UTILITIES.PUT_LINE ('Cycle count data extracted into the fact table successfully.');

    RETURN;

EXCEPTION


    WHEN INITIALIZATION_ERROR THEN

        rollback;

        -- report the error
        retcode := C_ERROR;
        errbuf := 'Inventory Cycle Count Accuracy ETL initial load terminated with errors. Please check the concurrent program log file for errors.';
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (INITIALIZATION_ERROR_MESG,
                                             l_proc_name, l_stmt_id));
        RETURN;

    WHEN BOUNDS_SETUP_ERROR THEN

        rollback;

        -- report the error
        retcode := C_ERROR;
        errbuf := 'Inventory Cycle Count Accuracy ETL initial load terminated with errors. Please check the concurrent program log file for errors.';
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (BOUNDS_SETUP_ERROR_MESG,
                                             l_proc_name, l_stmt_id));
        RETURN;


    WHEN ADJUSTMENT_EXTR_ERROR THEN

        rollback;

        -- report the error
        retcode := C_ERROR;
        errbuf := 'Inventory Cycle Count Accuracy ETL initial load terminated with errors. Please check the concurrent program log file for errors.';
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (ADJUSTMENT_EXTR_ERROR_MESG,
                                             l_proc_name, l_stmt_id));
        RETURN;


    WHEN EXACT_MATCH_EXTR_ERROR THEN

        rollback;

        -- report the error
        retcode := C_ERROR;
        errbuf := 'Inventory Cycle Count Accuracy ETL initial load terminated with errors. Please check the concurrent program log file for errors.';
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (EXACT_MATCH_EXTR_ERROR_MESG,
                                             l_proc_name, l_stmt_id));
        RETURN;

    WHEN BOUNDS_UPDATE_ERROR THEN

        rollback;

        -- report the error
        retcode := C_ERROR;
        errbuf := 'Inventory Cycle Count Accuracy ETL initial load terminated with errors. Please check the concurrent program log file for errors.';
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (BOUNDS_UPDATE_ERROR_MESG,
                                             l_proc_name, l_stmt_id));
        RETURN;


    WHEN CONV_RATES_ERROR THEN

        rollback;

        -- report the error
        retcode := C_ERROR;
        errbuf := 'Inventory Cycle Count Accuracy ETL initial load terminated with errors. Please check the concurrent program log file for errors.';
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (CONV_RATES_ERROR_MESG,
                                             l_proc_name, l_stmt_id));
        RETURN;


    WHEN FACT_MERGE_ERROR THEN

        rollback;

        -- report the error
        retcode := C_ERROR;
        errbuf := 'Inventory Cycle Count Accuracy ETL initial load terminated with errors. Please check the concurrent program log file for errors.';
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (FACT_MERGE_ERROR_MESG,
                                             l_proc_name, l_stmt_id));
        RETURN;


    WHEN OPM_EXTRACTION_ERROR THEN

        rollback;

        -- report the error
        retcode := C_ERROR;
        errbuf := 'Inventory Cycle Count Accuracy ETL initial load terminated with errors. Please check the concurrent program log file for errors.';
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (OPM_EXTRACTION_ERROR_MESG,
                                             l_proc_name, l_stmt_id));
        RETURN;

    WHEN OTHERS THEN

        rollback;

        -- report the error
        retcode := C_ERROR;
        errbuf := 'Inventory Cycle Count Accuracy ETL initial load terminated with errors. Please check the concurrent program log file for errors.';

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));

        RETURN;


END run_initial_load;


/* cca_initialize_init

    Check that the primary currency code and global start date have been
    set up.

    Get the OPI schema info.

    Check if the log table has rows created by the Inventory Value ETL.

    Truncate all the needed tables for the initial load.

    Note: Do not check to see if this initial load has been run previously.

    History:
    Date        Author              Action
    01/12/04    Dinkar Gupta        Defined procedure.
    04/13/04    Dinkar Gupta        Changed procedure so that it does not
                                    throw an exception in case no MMT/MIF
                                    rows are found in the log. The behaviour
                                    can happen in case of purely process
                                    manufacturing instances.
    05/14/04    Dinkar Gupta        Added hints to alter SQL hash and sort
                                    area sizes based on perf team
                                    recommendation.
    08/17/04    Dinkar Gupta        Added Secondary Currency support.

    07/05/05    Vishal Gupta        Made changes for R12. No check
                                    pertaining to logs
*/

PROCEDURE cca_initialize_init
IS

    l_proc_name CONSTANT VARCHAR2 (40) := 'cca_initialize_init';
    l_stmt_id NUMBER;


BEGIN

    -- initialization block
    l_stmt_id := 0;

    l_stmt_id := 10;
    -- Check for the primary currency code and global start date setup.
    -- These two parameters must be set up prior to any DBI load.
    IF (NOT (check_global_setup ())) THEN
        RAISE GLOBAL_SETUP_MISSING;
    END IF;

    l_stmt_id := 20;
    -- Obtain the OPI schema name to allow truncation of various tables
    -- get session parameters
    IF (NOT (fnd_installation.get_app_info('OPI', s_status, s_industry,
                                           s_opi_schema))) THEN
        RAISE SCHEMA_INFO_NOT_FOUND;
    END IF;


    -- Get the global start date
    l_stmt_id := 30;
    s_global_start_date := trunc (bis_common_parameters.get_global_start_date);
    IF (s_global_start_date IS NULL) THEN
        RAISE GLOBAL_START_DATE_NULL;
    END IF;


    l_stmt_id := 40;
    -- Get the DBI global currency code
    s_global_curr_code := bis_common_parameters.get_currency_code;

    l_stmt_id := 50;
    IF (s_global_curr_code IS NULL) THEN
        RAISE NO_GLOBAL_CURR_CODE;
    END IF;


    l_stmt_id := 60;
    -- Get the DBI Global rate type
    s_global_rate_type := bis_common_parameters.get_rate_type;

    l_stmt_id := 70;
    IF (s_global_rate_type IS NULL) THEN
        RAISE NO_GLOBAL_RATE_TYPE;
    END IF;

    l_stmt_id := 80;
    -- Get the DBI secondary currency code
    s_secondary_curr_code := bis_common_parameters.get_secondary_currency_code;

    l_stmt_id := 90;
    -- Get the DBI Global rate type
    s_secondary_rate_type := bis_common_parameters.get_secondary_rate_type;

    l_stmt_id := 100;
    IF (    (s_secondary_curr_code IS NULL AND
             s_secondary_rate_type IS NOT NULL)
         OR (s_secondary_curr_code IS NOT NULL AND
             s_secondary_rate_type IS NULL) ) THEN
        RAISE SEC_CURR_SETUP_INVALID;
    END IF;


    -- Truncate the following tables (in case of exceptions, nothing
    -- special to do here because it is a database error):

    l_stmt_id := 120;
    -- Staging table
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
                       'opi_dbi_inv_cca_stg');

    l_stmt_id := 130;
    -- Staging table
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
                       'opi_dbi_mmt_cca_stg');

    l_stmt_id := 140;
    -- Conversion rates table
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
                       'opi_dbi_inv_cca_conv');


    l_stmt_id := 150;
    -- MV Log on the fact table, because the purge directive on the
    -- fact table does not work.
    --EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
    --                 'mlog$_opi_dbi_inv_cca_f' );


    l_stmt_id := 160;
    -- Fact table including the MV log on the table, for efficiency
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
                       'opi_dbi_inv_cca_f PURGE MATERIALIZED VIEW LOG');


    -- Not using
    l_stmt_id := 170;
    -- Temp table for bounds computation
    -- EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
       --                'opi_dbi_inv_value_log_tmp');


    l_stmt_id := 180;
    -- User and login id's
    s_user_id := nvl(fnd_global.user_id, -1);
    s_login_id := nvl(fnd_global.login_id, -1);
    s_program_id := nvl(fnd_global.conc_program_id, -1);
    s_program_login_id := nvl(fnd_global.conc_login_id , -1);
    s_program_application_id := nvl(fnd_global.prog_appl_id , -1);
    s_request_id := nvl(fnd_global.conc_request_id, -1);

    l_stmt_id := 190;
    -- Initial load requires lots of memory for OLTP table
    -- hash joins. Performance team recommends the following
    -- 2 alter session commands.
    EXECUTE IMMEDIATE ('ALTER SESSION SET SORT_AREA_SIZE=100000000');
    EXECUTE IMMEDIATE ('ALTER SESSION SET HASH_AREA_SIZE=100000000');

    l_stmt_id := 200;
    -- R12 Migration date
    -- will be uncommented when this package is available
    opi_dbi_rpt_util_pkg.get_inv_convergence_date (s_r12_migration_date);

    RETURN;

EXCEPTION

    WHEN GLOBAL_SETUP_MISSING THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (GLOBAL_SETUP_MISSING_MESG,
                                                     l_proc_name, l_stmt_id));
        RAISE INITIALIZATION_ERROR;

    WHEN SCHEMA_INFO_NOT_FOUND THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (SCHEMA_INFO_NOT_FOUND_MESG,
                                             l_proc_name, l_stmt_id));
        RAISE INITIALIZATION_ERROR;

    WHEN INIT_BOUNDS_MISSING THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (INIT_BOUNDS_MISSING_MESG,
                                             l_proc_name, l_stmt_id));
        RAISE INITIALIZATION_ERROR;

    WHEN GLOBAL_START_DATE_NULL THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (GLOBAL_START_DATE_NULL_MESG,
                                             l_proc_name, l_stmt_id));
        RAISE INITIALIZATION_ERROR;


    WHEN NO_GLOBAL_CURR_CODE THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (NO_GLOBAL_CURR_CODE_MESG,
                                             l_proc_name, l_stmt_id));
        RAISE INITIALIZATION_ERROR;


    WHEN NO_GLOBAL_RATE_TYPE THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (NO_GLOBAL_RATE_TYPE_MESG,
                                             l_proc_name, l_stmt_id));
        RAISE INITIALIZATION_ERROR;


    WHEN SEC_CURR_SETUP_INVALID THEN
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (SEC_CURR_SETUP_INVALID_MESG,
                                             l_proc_name, l_stmt_id));

        RAISE INITIALIZATION_ERROR;

    WHEN OTHERS THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));

        RAISE INITIALIZATION_ERROR;


END cca_initialize_init;

/* extract_cca_mmt_init

   Extract Cycle count type of transactions from MMT which are after Global
   start date. For this transaction_source_type_id = 9 . This contains 2
   type of Cycle count transactions :
   Transaction_type_id = 4  Cycle Count Adjustments
   Trasnaction_type_id = 5  Cycle Count Subinventory Transfer

*/

PROCEDURE extract_cca_mmt_init
IS
        l_stmt_id       NUMBER;
        l_proc_name     VARCHAR2(40) := 'Extract_cca_mmt_init';

BEGIN

    l_stmt_id :=0 ;


    Insert /*+ append parallel (opi_dbi_mmt_cca_stg) */
    into OPI_DBI_MMT_CCA_STG
            (TRANSACTION_ID,
            ORGANIZATION_ID,
            INVENTORY_ITEM_ID,
            CYCLE_COUNT_ID,
            SUBINVENTORY_CODE,
            TRANSFER_SUBINVENTORY,
            TRANSACTION_DATE,
            TRANSACTION_TYPE_ID,
            PRIMARY_QUANTITY)
    Select TRANSACTION_ID,
            ORGANIZATION_ID,
            INVENTORY_ITEM_ID,
            CYCLE_COUNT_ID,
            SUBINVENTORY_CODE,
            TRANSFER_SUBINVENTORY,
            TRANSACTION_DATE,
            TRANSACTION_TYPE_ID,
            PRIMARY_QUANTITY
    From   MTL_MATERIAL_TRANSACTIONS
    Where Transaction_date >= s_global_start_date
    and   Transaction_source_type_id = 9 ;


    -- commit will handled in wrapper


    RETURN;

EXCEPTION

    WHEN OTHERS THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));

        RAISE CCA_MMT_STG_ERROR;

END extract_cca_mmt_init;


/* extract_discrete_adj_init

    Extract discrete adjustment entry data from MTL_CYCLE_COUNT_ENTRIES (MCCE),
    MMT and MTA. Adjustments can get costed well after approval and
    interim cost updates may cause the values recorded in MCCE to
    be different. Thus we need to get the cost associated to the item
    using the value in MTA so that the reported adjustments match
    the MTA reported value.

    However, due to issues with layered costing in LIFO/FIFO orgs, the
    system inventory value is computed using the cost at the time when
    the entry was made. Thus the reported system inventory value
    matches the one reported in Oracle Forms.

    We are only interested in entries completed after the global start
    date (i.e. entry_status_code = 5 and approval_date > global start date).
    But it is not possible mmt_mta join to return records where cycle count
    entries are not completed.

    The only MTA rows we are interested in are those that affect the
    inventory account (accounting line type = 1).

    MTA does not store rows for expense items, or items in expense
    subinventories. Thus the join between MMT and MTA will have to
    be an outer join. Rows with no matches will be assigned an
    item cost of 0.

    MCCE does not store quantities in the primary uom_code. If the
    transaction uom is not the same as the primary uom, all
    quantities will have to be converted to the primary uom.

    There is a need to check for adjustment quantity = 0 serial item counts
    can have count level matches, but serial number level adjustments,
    To handle this, make four enhancements:
    1. Declare exact matches if the sum of the MMT primary quantity is 0.
    2. Pick the MCCE item_unit_cost if the quantity is 0 (check for expense
       subs before that).
    3. Set the tolerance to 0 if there is an adjustment in another
       subinventory that the one counted. This will automatically
       make any adjustments against it misses.
    4. The system_inventory_qty for the other subinventory is the negative
       of the adjustment quantity, so that the sum of the adjustment
       and system quantity is always 0.

    We will only be scanning MMT rows between the transaction ranges
    in the log table.

    Also, since the fact table is at a cycle count entry level,
    it is impossible for the sum (mmt.primary_quantity) to be 0. Thus
    the item_cost formula of sum (value)/sum (quantity) is always
    valid and we need not worry about sum (quantity) being 0 or NULL.

    Since the join conditions between MCCE - MMT - MTA is one to many
    to many, join MMT/MTA on transaction_id first.

    Also, to handle serial item adjustments where the adjustment
    automatically issues an item from a sub to move it to the next,
    use the subinventory_code from MMT, not MCCE.

    There cannot be an entry in MMT and MTA for which cycle count has not been approved.
    ie entry_status_code = 5.

    -------- R12 Changes
    1> Subinventory Transfer type of transaction (MMT.transaction_type_id = 5)
       is seen in Cycle Count. This case occurs when a LPN is received in
       say subinv. BULK, and cycle count is done in say subinv. CASE for a specific LPN.
       This type of transaction has 2 rows in MMT, one for issue transaction
       and other for receipt transaction. But the MTA has no rows for receipt
       transaction while it has 2 entries differing only in MTA.primary_quantity.

       The subinventory for issue transaction where mta.primary_quantity is -ve and
       transfer_subinventory for issue transaction where mta.primary_quantity is
       positive.
       This case will not be encountered for Expense item as LPN cannot be made
       for expense item.
       Such transactions can only be done through Warehouse mobile.


       Currently for such transactions MMT.cycle_count_id is not populated.
       Bug # 4392340 has been logged for the same.

    2> Changes to log table and columns.

    3> mmt staging table is introduced to collect all mmt transactions
       for discrete and process orgs at one go. Here as we are joining
       with bounds table which has bounds for discrete orgs by
       transaction_id we do not need to put any filters to get only
       discrete organizations. For process there is one single record in
       bounds table which has bound_level_entity_id as NULL and hence mmt
       records for process orgs will not be selected in the extract
       below.


    ----------------------


    Do not commit data. Let the wrapper coordinate committing of data.

    Paramters:
    IN:
        p_global_start_date - DBI global start date

    History:
    Date        Author              Action
    01/14/04    Dinkar Gupta        Defined procedure.
    02/10/04    Dinkar Gupta        Added group by transaction_id
                                    in the mmt/mta join.
                                    Used MMT subinventory_code
                                    to handle serial item issues.
    02/18/04    Dinkar Gupta        Added condition to handle
                                    cases where MMT quantity is 0 for
                                    serial items.
                                    Also added condition to report miss
                                    for adjustments against any other
                                    sub than the one being counted.
    03/10/04    Dinkar Gupta        Used item_cost from MCCE for system
                                    inventory value for LIFO/FIFO org
                                    issue.
    06/22/05    Vishal Gupta        Refer to R12 Changes in the above
                                    header.


*/
PROCEDURE extract_discrete_adj_init (p_global_start_date IN DATE)
IS
    l_proc_name         CONSTANT VARCHAR2 (40) := 'extract_adjustments_init';
    l_stmt_id           NUMBER;

BEGIN

    -- initialization block
    l_stmt_id := 0;

    l_stmt_id := 10;
    -- This procedure only inserts all adjustment entry data into the
    -- staging table. For an explanation of the logic, please refer to the
    -- procedure header.

    -- Join condition justifications
    --
    -- to MCCC - on org, header and abc_class. The org is redundant,
    -- but this should allow use of U1 index on MCCC.
    --
    -- to MCCI - on header and item. This should allow use of U1 index
    -- on MCCI.
    --
    -- to MCCH - on header. This should allow use of U1 index.
    --
    -- to MCCE - on entry. This should allow use of U1 index.
    --
    -- to MSI - on org and item. This should allow use of the U1 index.
    --
    -- to SUBS - on org and subinventory code
    INSERT /*+ append parallel (opi_dbi_inv_cca_stg) */
    INTO opi_dbi_inv_cca_stg (
        organization_id,
        inventory_item_id,
        cycle_count_header_id,
        abc_class_id,
        subinventory_code,
        cycle_count_entry_id,
        source,
        approval_date,
        uom_code,
        system_inventory_qty,
        positive_adjustment_qty,
        negative_adjustment_qty,
        item_unit_cost,
        item_adj_unit_cost,
        hit_miss_pos,
        hit_miss_neg,
        exact_match)
    SELECT /*+ parallel(mcce) parallel(mcch) parallel(mcci)
               parallel(mccc) parallel(msi) parallel(subs)
               parallel(mmt_mta)
               use_hash(mcce mcch mcci mccc msi subs) */
        mcce.organization_id,
        mcce.inventory_item_id,
        mcce.cycle_count_header_id,
        to_char (mccc.abc_class_id),
        mmt_mta.subinventory_code,
        to_char (mcce.cycle_count_entry_id),
        C_OPI_SOURCE,
        trunc (mcce.approval_date),
        msi.primary_uom_code,
        decode (mcce.count_uom_current,
                msi.primary_uom_code,
                decode (mmt_mta.subinventory_code,
                        mcce.subinventory, mcce.system_quantity_current,
                        -1 * sum (mmt_mta.primary_quantity)),
                decode (mmt_mta.subinventory_code,
                        mcce.subinventory,
                        inv_convert.inv_um_convert
                            (mcce.inventory_item_id, C_MMT_PRECISION,
                             mcce.system_quantity_current,
                             mcce.count_uom_current,
                             msi.primary_uom_code, NULL, NULL),
                        inv_convert.inv_um_convert
                            (mcce.inventory_item_id, C_MMT_PRECISION,
                             -1 * sum (mmt_mta.primary_quantity),
                             mcce.count_uom_current,
                             msi.primary_uom_code, NULL, NULL))),
        CASE WHEN sum (mmt_mta.primary_quantity) > 0 THEN
                    sum (mmt_mta.primary_quantity)
             ELSE   0
             END,
        CASE WHEN sum (mmt_mta.primary_quantity) < 0 THEN
                    -1 * sum (mmt_mta.primary_quantity)
             ELSE   0
             END,
        decode (subs.asset_inventory,
                C_EXPENSE_SUBINVENTORY, 0,
                mcce.item_unit_cost),
        decode (sum (mmt_mta.primary_quantity),
                0, decode (subs.asset_inventory,
                           C_EXPENSE_SUBINVENTORY, 0,
                           mcce.item_unit_cost),
                nvl (sum (mmt_mta.base_transaction_value)/
                     sum (mmt_mta.primary_quantity), 0)),
        decode (mmt_mta.subinventory_code,
                mcce.subinventory, nvl (mccc.hit_miss_tolerance_positive,
                                        mcch.hit_miss_tolerance_positive),
                0),
        decode (mmt_mta.subinventory_code,
                mcce.subinventory, nvl (mccc.hit_miss_tolerance_negative,
                                        mcch.hit_miss_tolerance_negative),
                0),
        decode (sum (mmt_mta.primary_quantity),
                0, C_EXACT_MATCH,
                C_NO_MATCH)
      FROM  mtl_cycle_count_entries mcce,
            mtl_cycle_count_headers mcch,
            mtl_cycle_count_items mcci,
            mtl_cycle_count_classes mccc,
            mtl_system_items_b msi,
            mtl_secondary_inventories subs,
            (SELECT /*+ no_merge
                        parallel(mmt) parallel(mta) parallel(log)
                        use_hash(mmt mta log)*/
                mmt.organization_id,
                mmt.inventory_item_id,
                mmt.transaction_date,
                mmt.cycle_count_id,
                decode (mmt.transaction_type_id,
                        5, decode(sign(nvl(mta.primary_quantity,0)),
                                  1, 0,
                                  mmt.primary_quantity),
                        mmt.primary_quantity)   primary_quantity,
                decode (mmt.transaction_type_id,
                        5, decode(sign(nvl(mta.primary_quantity,0)),
                                  1, mmt.transfer_subinventory,
                                  mmt.subinventory_code),
                        mmt.subinventory_code)  subinventory_code,
                sum (mta.base_transaction_value) base_transaction_value
              FROM opi_dbi_mmt_cca_stg mmt,
                   mtl_transaction_accounts mta,
                   opi_dbi_conc_prog_run_log log
              WHERE log.etl_type = C_ETL_TYPE
                AND log.driving_table_code = C_LOG_MMT_DRV_TBL
                AND log.load_type = C_LOAD_INIT
                AND mmt.organization_id = log.bound_level_entity_id
                AND mmt.transaction_id >= log.from_bound_id
                AND mmt.transaction_id <  log.to_bound_id
                AND mmt.transaction_date >= p_global_start_date
         --     AND mmt.transaction_type_id = C_MMT_CYCLE_COUNT_ADJ
                AND mmt.transaction_id = mta.transaction_id (+)
                AND nvl (mta.accounting_line_type, C_INVENTORY_ACCOUNT) =
                        C_INVENTORY_ACCOUNT -- 1
              GROUP BY
                    mmt.organization_id,
                    mmt.inventory_item_id,
                    mmt.transaction_date,
                    mmt.cycle_count_id,
                    decode (mmt.transaction_type_id,
                        5, decode(sign(nvl(mta.primary_quantity,0)),
                                  1, 0,
                                  mmt.primary_quantity),
                        mmt.primary_quantity),
                    decode (mmt.transaction_type_id,
                        5, decode(sign(nvl(mta.primary_quantity,0)),
                                  1, mmt.transfer_subinventory,
                                  mmt.subinventory_code),
                        mmt.subinventory_code),
                    mmt.transaction_id) mmt_mta
      WHERE mmt_mta.organization_id = msi.organization_id
        AND mmt_mta.inventory_item_id = msi.inventory_item_id
        AND mmt_mta.cycle_count_id = mcce.cycle_count_entry_id
        AND mcce.entry_status_code = C_COMPLETED_CCA_ENTRY
        AND mcce.cycle_count_header_id = mcch.cycle_count_header_id
        AND mcce.cycle_count_header_id = mcci.cycle_count_header_id
        AND mcce.inventory_item_id = mcci.inventory_item_id
        AND mcce.organization_id = mccc.organization_id
        AND mcce.cycle_count_header_id = mccc.cycle_count_header_id
        AND mcci.abc_class_id = mccc.abc_class_id
        AND mmt_mta.organization_id = subs.organization_id
        AND mmt_mta.subinventory_code = subs.secondary_inventory_name
      GROUP BY
        mcce.organization_id,
        mcce.inventory_item_id,
        mcce.cycle_count_header_id,
        mccc.abc_class_id,
        mmt_mta.subinventory_code,
        mcce.cycle_count_entry_id,
        trunc (mcce.approval_date),
        msi.primary_uom_code,
        mcce.count_uom_current,
        mcce.system_quantity_current,
        subs.asset_inventory,
        mcce.item_unit_cost,
        mcce.subinventory,
        mccc.hit_miss_tolerance_positive,
        mcch.hit_miss_tolerance_positive,
        mcce.subinventory,
        mccc.hit_miss_tolerance_negative,
        mcch.hit_miss_tolerance_negative;

    RETURN;

EXCEPTION

    WHEN OTHERS THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));

        RAISE ADJUSTMENT_EXTR_ERROR;

END extract_discrete_adj_init;



/* extract_process_adj_init
   Extract process adjustment entry data from MTL_CYCLE_COUNT_ENTRIES (MCCE),
    MMT and GTV. The transactions in GTV can be either in Draft, New or Final Mode.
    We will only consider Draft and Final Mode of transactions only.

    For initial load there will not be any separate bounds for Final and Draft
    transaction.

    Subinventory Transafer type of transaction for Cycle Count is considered. There
    is no change from discrete.

        1> Subinventory Transfer type of transaction (MMT.transaction_type_id = 5)
       is seen in Cycle Count. This case occurs when a LPN is received in
       say BULK, and cycle count is done in say CASE for a specific LPN.
       This type of transaction has 2 rows in MMT, one for issue transaction
       and other for receipt transaction. But the GTV has no rows for receipt
       transaction while it has 2 entries differing only in GTV.subinventory_code.
       GTV.subinventory_code will have issue subinventory_code for one of two rows in GTV
       pertianing to issue transaction in MMT. The other row will have
       MMT.transfer_subinventory in GTV.subinventory_code.


       Currently for such transactions MMT.cycle_count_id is not populated.
       Bug # 4392340 has been logged for the same.

    The bounds for Process is applied same for all organization. The driving table
    will be GTV.
    To isolate cycle count transaction in GTV following is required:
    EVENT_CLASS_CODE = 'MISC_TXN' and 'SUBINV_XFER'
    EVENT_TYPE_CODE = 'CYCLE_COUNT_ADJ'	 and 'CYCLE_COUNT_XFER'
    JOURNAL_LINE_TYPE = 'INV'
    TRANSACTION_SOURCE = 'INVENTORY'

    We are only interested in entries completed after the global start
    date (i.e. entry_status_code = 5 and approval_date > global start date).

    Unlike the case with MTA, GTV has rows for expense items, or items in
    expense subinventories. Hence also no outer join is required.

    For item_unit_cost, adjustments can get costed well after approval and interim
    cost updates may cause the values recorded in MCCE to be different. Thus
    we need to get the cost associated to the item using the value in GTV so
    that the reported adjustments match the GTV reported value.

    However, due to issues with layered costing in LIFO/FIFO orgs, the
    system inventory value is computed using the cost at the time when
    the entry was made. Thus the reported system inventory value
    matches the one reported in Oracle Forms.

    MCCE does not store quantities in the primary uom_code. If the
    transaction uom is not the same as the primary uom, all
    quantities will have to be converted to the primary uom.

    Also, since the fact table is at a cycle count entry level,
    it is impossible for the sum (mmt.primary_quantity) to be 0. Thus
    the item_cost formula of sum (value)/sum (quantity) is always
    valid and we need not worry about sum (quantity) being 0 or NULL.

    Since the join conditions between MCCE - MMT - GTV is one to many
    to many, join GTV/MMT on transaction_id first.

    IMPORTANT NOTE R12:
    -------------------
    draft and permanent quantity/value is not handled separately as in
    other ETLs as its assumed that either all the MMT-GTV records are
    in draft or permanent status for one cycle count entries.

    Now, as we relook at all the draft records in every ETL its
    possible that same draft records are collected again. But as our
    fact is at cycle_count_entry level its assumed that either all or
    none of MMT-GTV for a cycle count entry are collected. Hence in
    Merge of cycle count values are only replaced and not added.

    Do not commit data. Let the wrapper coordinate committing of data.

    Paramters:
    IN:
        p_global_start_date - DBI global start date

    History:
    Date        Author              Action
    06/22/05    Vishal Gupta        New Procedure. To collect data for
                                    Post R12 Process cycle counting,


*/
PROCEDURE extract_process_adj_init (p_global_start_date IN DATE)
IS
    l_proc_name         CONSTANT VARCHAR2 (40) := 'extract_adjustments_init';
    l_stmt_id           NUMBER;

    l_from_bound_date   OPI_DBI_CONC_PROG_RUN_LOG.from_bound_date%type;
    l_to_bound_date     OPI_DBI_CONC_PROG_RUN_LOG.to_bound_date%type;

BEGIN

    -- initialization block
    l_stmt_id := 0;

    SELECT from_bound_date, to_bound_date
    INTO l_from_bound_date, l_to_bound_date
    FROM OPI_DBI_CONC_PROG_RUN_LOG
    WHERE driving_table_code = C_LOG_GTV_DRV_TBL
      AND etl_type = C_ETL_TYPE
      AND load_type = C_LOAD_INIT;


    l_stmt_id := 10;
    -- This procedure only inserts all adjustment entry data into the
    -- staging table. For an explanation of the logic, please refer to the
    -- procedure header.

    -- Join condition justifications
    --
    -- to MCCC - on org, header and abc_class. The org is redundant,
    -- but this should allow use of U1 index on MCCC.
    --
    -- to MCCI - on header and item. This should allow use of U1 index
    -- on MCCI.
    --
    -- to MCCH - on header. This should allow use of U1 index.
    --
    -- to MCCE - on entry. This should allow use of U1 index.
    --
    -- to MSI - on org and item. This should allow use of the U1 index.
    --
    -- to SUBS - on org and subinventory code


     INSERT /*+ append parallel (opi_dbi_inv_cca_stg) */
     INTO opi_dbi_inv_cca_stg (
        organization_id,
        inventory_item_id,
        cycle_count_header_id,
        abc_class_id,
        subinventory_code,
        cycle_count_entry_id,
        source,
        approval_date,
        uom_code,
        system_inventory_qty,
        positive_adjustment_qty,
        negative_adjustment_qty,
        item_unit_cost,
        item_adj_unit_cost,
        hit_miss_pos,
        hit_miss_neg,
        exact_match   )
     SELECT  mcce.organization_id,
      mcce.inventory_item_id,
      mcce.cycle_count_header_id,
      to_char (mccc.abc_class_id),
      mmt_gtv.subinventory_code,
      to_char (mcce.cycle_count_entry_id),
      C_OPM_SOURCE,
      trunc (mcce.approval_date),
      msi.primary_uom_code,
      decode (mcce.count_uom_current,
      msi.primary_uom_code,
      mcce.system_quantity_current,
      inv_convert.inv_um_convert (      mcce.inventory_item_id,
                                        C_MMT_PRECISION,
                                        mcce.system_quantity_current,
                                        mcce.count_uom_current,
                                        msi.primary_uom_code,
                                        NULL,
                                        NULL)) system_inventory_qty,
      CASE WHEN sum (mmt_gtv.primary_quantity) > 0 THEN
                sum (mmt_gtv.primary_quantity)
           ELSE   0
      END          positive_adjustment_qty,
      CASE WHEN sum (mmt_gtv.primary_quantity) < 0 THEN
                -1 * sum (mmt_gtv.primary_quantity)
      ELSE   0
      END          negative_adjustment_qty ,
      decode (subs.asset_inventory,
                C_EXPENSE_SUBINVENTORY, 0,
                mcce.item_unit_cost)        item_unit_cost,
      decode (sum (mmt_gtv.primary_quantity),
                0, decode (subs.asset_inventory,
                                C_EXPENSE_SUBINVENTORY, 0,
                                mcce.item_unit_cost),
                nvl (sum (mmt_gtv.transaction_base_value)/
                        sum (mmt_gtv.primary_quantity), 0))        item_adj_unit_cost,
      decode (mmt_gtv.subinventory_code,
              mcce.subinventory, nvl (mccc.hit_miss_tolerance_positive,
                                      mcch.hit_miss_tolerance_positive),
              0),
      decode (mmt_gtv.subinventory_code,
              mcce.subinventory, nvl (mccc.hit_miss_tolerance_negative,
                                      mcch.hit_miss_tolerance_negative),
              0),
      decode (sum (mmt_gtv.primary_quantity),
              0, C_EXACT_MATCH,
              C_NO_MATCH)          exact_match
    FROM    mtl_cycle_count_entries mcce,
        mtl_cycle_count_headers mcch,
        mtl_cycle_count_items mcci,
        mtl_cycle_count_classes mccc,
        mtl_system_items_b msi,
        mtl_secondary_inventories subs,
	-- below select is grouped at transaction_id, quantity level so that
	-- quantity is summed correctly and then it can be joined with
	-- mcce and other tables outside.
        (SELECT  mmt.organization_id,
                mmt.transaction_id,
                mmt.inventory_item_id,
                mmt.cycle_count_id,
                DECODE (mmt.transaction_type_id ,
                    5 , DECODE(GTV.subinventory_code,
                        MMT.subinventory_code, MMT.primary_quantity,
                        mmt.transfer_subinventory, -1* MMT.primary_quantity),mmt.primary_quantity)   primary_quantity,
                DECODE (mmt.transaction_type_id ,
                    5 ,GTV.subinventory_code,
                    mmt.subinventory_code)  subinventory_code,
                SUM (gtv.txn_base_value) transaction_base_value
        FROM    mtl_material_transactions mmt ,
                (SELECT gt.*
                FROM gmf_transaction_valuation gt,
                opi_dbi_org_le_temp olt
                WHERE olt.organization_id = gt.organization_id
                AND olt.ledger_id = gt.ledger_id
                AND olt.legal_entity_id = gt.legal_entity_id
                AND olt.valuation_cost_type_id = gt.valuation_cost_type_id) gtv
        WHERE   gtv.event_class_code in ('MISC_TXN' , 'SUBINV_XFER')
         AND    gtv.event_type_code in ('CYCLE_COUNT_ADJ' , 'CYCLE_COUNT_XFER')
         AND    gtv.journal_line_type = 'INV'
         AND    gtv.transaction_source = 'INVENTORY'
         AND    gtv.transaction_date >= l_from_bound_date
	 -- for final posted records consider within the bounds
	 -- for draft posted records consider all the txns
         AND    DECODE( accounted_flag,
                        NULL, gtv.final_posting_date,
                       'D',s_global_start_date) < l_to_bound_date
         and    gtv.transaction_id = mmt.transaction_id
        GROUP BY
                mmt.organization_id,
                mmt.inventory_item_id,
                mmt.cycle_count_id,
                DECODE (mmt.transaction_type_id ,
                    5 , DECODE(GTV.subinventory_code,
                        MMT.subinventory_code, MMT.primary_quantity,
                        mmt.transfer_subinventory, -1* MMT.primary_quantity),mmt.primary_quantity),
                DECODE (mmt.transaction_type_id ,
                    5 ,GTV.subinventory_code,
                    mmt.subinventory_code) ,
                mmt.transaction_id) mmt_gtv
    WHERE   mmt_gtv.organization_id = msi.organization_id
      AND   mmt_gtv.inventory_item_id = msi.inventory_item_id
      AND   mmt_gtv.cycle_count_id = mcce.cycle_count_entry_id
      -- mmt records are created only after cycle count is approved
      -- hence its not possible that entry_status_code is not approved.
      -- it is ensured that all costed txns are collected
      AND   mcce.entry_status_code = C_COMPLETED_CCA_ENTRY -- 5
      AND   mcce.cycle_count_header_id = mcch.cycle_count_header_id
      AND   mcce.cycle_count_header_id = mcci.cycle_count_header_id
      AND   mcce.inventory_item_id = mcci.inventory_item_id
      AND   mcce.organization_id = mccc.organization_id
      AND   mcce.cycle_count_header_id = mccc.cycle_count_header_id
      AND   mcci.abc_class_id = mccc.abc_class_id
      AND   mmt_gtv.organization_id = subs.organization_id
      AND   mmt_gtv.subinventory_code = subs.secondary_inventory_name
    GROUP BY
            mcce.organization_id,
            mcce.inventory_item_id,
            mcce.cycle_count_header_id,
            mccc.abc_class_id,
            mmt_gtv.subinventory_code,
            mcce.cycle_count_entry_id,
            trunc (mcce.approval_date),
            msi.primary_uom_code,
            mcce.count_uom_current,
            mcce.system_quantity_current,
            subs.asset_inventory,
            mcce.item_unit_cost,
            mcce.subinventory,
            mccc.hit_miss_tolerance_positive,
            mcch.hit_miss_tolerance_positive,
            mcce.subinventory,
            mccc.hit_miss_tolerance_negative,
            mcch.hit_miss_tolerance_negative;



   RETURN;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));

        RAISE ADJUSTMENT_EXTR_ERROR;


    WHEN OTHERS THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));

        RAISE ADJUSTMENT_EXTR_ERROR;

END extract_process_adj_init;



/* extract_exact_matches_init

    Extract the exact match entry data from the MTL_CYCLE_COUNT_ENTRIES
    table. Exact match data is easier to handle than adjustment entries
    because exact matches are approved on creation and there are no
    other transaction tables that need to be visited.

    We are only interested in entries completed after the global start
    date (i.e. entry_status_code = 5 and approval_date > global start date).

    The adjustment quantity is always 0 and hit/miss tolerances are not
    needed since all entries are, by definition, hits. We still need to join
    to MTL_CYCLE_COUNT_CLASSES to get the count and count class information.

    No need to join to MTL_CYCLE_COUNT_HEADERS as we don't need to
    get any tolerances.

    MCCE does not store quantities in the primary uom_code. If the
    transaction uom is not the same as the primary uom, all
    quantities will have to be converted to the primary uom.

    The date range being extracted is specified in the log table.

    However, since we are dealing with last_update_dates, we need to
    be sure that the dates in the log tables have timestamps so that
    we do not collect partially collected days again.

    The one special case is that we need to identify expense
    subinventories and set the item cost to 0 for all entries
    bearing those subinventory codes.

    ------------ R12 Changes
    Since Process exact matches will be extrracted in the same insert.
    Date bounds speific to organization based on first uncosted transaction
    cannot be applied. Hence we will use date bounds that are being used for
    the process adjustments. ie Collect all the exact matches for which
    MCCE.approval_date (MCCE.last_update_date) is between global
    start date and the initial program start date.

    Discrete Adjustments are collected only upto first uncosted transaction
    date. Hence exact matches and discrete cycle cout adjustments will be
    out of sync if there are uncosted transactions. Please refer bug 4395280.


    ------------


    Do not commit data. Let the wrapper coordinate committing of data.

    Parameters:
    None.

    History:
    Date        Author              Action
    01/15/04    Dinkar Gupta        Defined procedure.
    02/05/04    Dinkar Gupta        Added logic to join to the from and to
                                    transaction dates in the log table.
    06/22/05    Vishal Gupta	    Made changes on bounds.

*/
PROCEDURE extract_exact_matches_init
IS
    l_proc_name         CONSTANT VARCHAR2 (40) := 'extract_exact_matches_init';
    l_stmt_id	        NUMBER;
    l_from_bound_date   OPI_DBI_CONC_PROG_RUN_LOG.from_bound_date%type;
    l_to_bound_date     OPI_DBI_CONC_PROG_RUN_LOG.to_bound_date%type;

BEGIN

    -- initialization block
    l_stmt_id := 0;

    SELECT from_bound_date, to_bound_date
    INTO l_from_bound_date, l_to_bound_date
    FROM OPI_DBI_CONC_PROG_RUN_LOG
    WHERE driving_table_code = C_LOG_GTV_DRV_TBL
      AND etl_type = C_ETL_TYPE
      AND load_type = C_LOAD_INIT;


    l_stmt_id := 10;
    -- This procedure will extract all all exact match data from MCCE
    -- and insert it into the staging table. For SQL logic, please refer
    -- to the procedure header

    -- Join condition justifications
    --
    -- to MCCC - on org, header and abc_class. The org is redundant,
    -- but this should allow use of U1 index on MCCC.
    -- Note the explicit check for the 0 adjustment quantity. This should
    -- ideally not be required but we found an example (which we have not
    -- been able to recreate) where there was an adjustment on a serialized
    -- item but the adjustment date was null in MCCE and
    -- MTL_CC_SERIAL_NUMBERS. To filter that case, we filter explicitly on
    -- on the quantity. Most likely, this is an OLTP bug that will be
    -- fixed.
    --
    -- to MCCI - on header and item. This should allow use of U1 index
    -- on MCCI.
    --
    -- to MCCE - on entry. This should allow use of U1 index.
    --  On entry_status_code. This is the leading column of the N6 index.
    --  Filter on last_update_date. This should use the newly created
    --  N8 (?) index.
    --
    -- no join needed to log - as we can extract GTV date bounds into variables
    -- .



    INSERT /*+ append parallel (opi_dbi_inv_cca_stg) */
    INTO opi_dbi_inv_cca_stg (
        organization_id,
        inventory_item_id,
        cycle_count_header_id,
        abc_class_id,
        subinventory_code,
        cycle_count_entry_id,
        source,
        approval_date,
        uom_code,
        system_inventory_qty,
        positive_adjustment_qty,
        negative_adjustment_qty,
        item_unit_cost,
        item_adj_unit_cost,
        hit_miss_pos,
        hit_miss_neg,
        exact_match)
    SELECT /*+ parallel(mcce) parallel(mcci) parallel(mccc)
               parallel(msi) parallel(subs) parallel(log)
               use_hash(mcci mccc msi subs) */
        mcce.organization_id,
        mcce.inventory_item_id,
        mcce.cycle_count_header_id,
        to_char (mccc.abc_class_id),
        mcce.subinventory,
        to_char (mcce.cycle_count_entry_id),
        decode(mp.process_enabled_flag,
                'Y',C_OPM_SOURCE,
                C_OPI_SOURCE )  source,
        trunc (mcce.approval_date),
        msi.primary_uom_code,
        decode (mcce.count_uom_current,
                msi.primary_uom_code, mcce.system_quantity_current,
                inv_convert.inv_um_convert
                    (mcce.inventory_item_id, C_MMT_PRECISION,
                     mcce.system_quantity_current, mcce.count_uom_current,
                     msi.primary_uom_code, NULL, NULL)),
        0,
        0,
        decode (subs.asset_inventory,
                C_EXPENSE_SUBINVENTORY, 0,
                mcce.item_unit_cost),
        0,
        NULL,
        NULL,
        C_EXACT_MATCH
      FROM  mtl_cycle_count_entries mcce,
            mtl_cycle_count_items mcci,
            mtl_cycle_count_classes mccc,
            mtl_system_items_b msi,
            mtl_secondary_inventories subs,
            mtl_parameters mp
      -- exact matches are approved at the time entry is completed
      -- hence it is not possible that status of a cycle count entry
      -- changes once the load is collected for that date range.
      WHERE mcce.last_update_date >= l_from_bound_date
        AND mcce.last_update_date < l_to_bound_date
        AND mcce.entry_status_code = C_COMPLETED_CCA_ENTRY
        AND mcce.organization_id = mp.organization_id
        AND mcce.adjustment_date IS NULL
        AND mcce.adjustment_quantity = 0
        AND mcce.cycle_count_header_id = mcci.cycle_count_header_id
        AND mcce.inventory_item_id = mcci.inventory_item_id
        AND mcce.organization_id = mccc.organization_id
        AND mcce.cycle_count_header_id = mccc.cycle_count_header_id
        AND mcci.abc_class_id = mccc.abc_class_id
        AND mcce.organization_id = msi.organization_id
        AND mcce.inventory_item_id = msi.inventory_item_id
        AND mcce.organization_id = subs.organization_id
        AND mcce.subinventory = subs.secondary_inventory_name;


        -- Do not commit here. Let the wrapper handle commit operations.

        RETURN;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));

        RAISE EXACT_MATCH_EXTR_ERROR;

    WHEN OTHERS THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));

        RAISE EXACT_MATCH_EXTR_ERROR;

END extract_exact_matches_init;

/*  compute_cca_conv_rates_init

    Compute all the conversion rates for all distinct organization,
    transaction date pairs in the staging table. The date in the fact
    table is already without a timestamp i.e. trunc'ed.

    There are two conversion rates to be computed:
    1. Primary global
    2. Secondary global (if set up)

    The conversion rate work table was truncated during
    the initialization phase.

    Get the currency conversion rates based on the data in
    OPI_DBI_INV_CCA_STG using the fii_currency.get_global_rate_primary
    API for the primary global currency and
    fii_currency.get_global_rate_secondary for the secondary global currency.
    The primary currency API:
    1. finds the conversion rate if one exists.
    2. 'USD' always has a conversion rate of 1 (since it is global currency).
    3. returns -1 if there is no conversion rate on that date.
    4. returns -2 if the currency code is not found.
    5. returns -3 if the transaction_date is prior to 01-JAN-1999,
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

    History:
    Date        Author              Action
    01/15/04    Dinkar Gupta        Defined procedure.
    05/11/04    Dinkar Gupta        Specializing this procedure for initial
                                    load.
    08/17/04    Dinkar Gupta        Added secondary currency support

*/

PROCEDURE compute_cca_conv_rates_init (p_global_curr_code IN VARCHAR2,
                                       p_global_rate_type IN VARCHAR2)

IS

    l_proc_name CONSTANT VARCHAR2 (60) := 'compute_cca_conv_rates_init';
    l_stmt_id NUMBER;

    -- Cursor to see if any rates are missing. See below for details
    CURSOR invalid_rates_exist_csr IS
        SELECT 1
          FROM opi_dbi_inv_cca_conv
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
    CURSOR invalid_rates_csr (p_pri_sec_curr_same NUMBER) IS
        SELECT /*+ parallel (compare) */
        DISTINCT
            report_order,
            curr_code,
            rate_type,
            approval_date,
            func_currency_code
          FROM (
                SELECT /*+ parallel (conv) parallel (mp) parallel (to_conv) */
                DISTINCT
                    s_global_curr_code curr_code,
                    s_global_rate_type rate_type,
                    1 report_order, -- ordering global currency first
                    mp.organization_code,
                    decode (conv.conversion_rate,
                            C_EURO_MISSING_AT_START, C_EURO_START_DATE,
                            conv.approval_date) approval_date,
                    conv.func_currency_code
              FROM opi_dbi_inv_cca_conv conv,
                   mtl_parameters mp,
                  (SELECT /*+ parallel (opi_dbi_inv_cca_stg) */
                   DISTINCT organization_id, approval_date
                     FROM opi_dbi_inv_cca_stg) to_conv
              WHERE nvl (conv.conversion_rate, -999) < 0 -- null is not fine
                AND mp.organization_id = to_conv.organization_id
                AND conv.approval_date (+) = to_conv.approval_date
                AND conv.organization_id (+) = to_conv.organization_id
            UNION ALL
            SELECT /*+ parallel (conv) parallel (mp) parallel (to_conv) */
            DISTINCT
                    s_secondary_curr_code curr_code,
                    s_secondary_rate_type rate_type,
                    decode (p_pri_sec_curr_same,
                            1, 1,
                            2) report_order, --ordering secondary currency next
                    mp.organization_code,
                    decode (conv.sec_conversion_rate,
                            C_EURO_MISSING_AT_START, C_EURO_START_DATE,
                            conv.approval_date) approval_date,
                    conv.func_currency_code
              FROM opi_dbi_inv_cca_conv conv,
                   mtl_parameters mp,
                  (SELECT /*+ parallel (opi_dbi_inv_cca_stg) */
                   DISTINCT organization_id, approval_date
                     FROM opi_dbi_inv_cca_stg) to_conv
              WHERE nvl (conv.sec_conversion_rate, 999) < 0 -- null is fine
                AND mp.organization_id = to_conv.organization_id
                AND conv.approval_date (+) = to_conv.approval_date
                AND conv.organization_id (+) = to_conv.organization_id)
          compare
          ORDER BY
                report_order ASC,
                approval_date,
                func_currency_code;


    -- Flag to ensure all rates have been found.
    l_all_rates_found BOOLEAN;

    -- Boolean to check if the primary and secondary currencies are the
    -- same
    l_pri_sec_curr_same NUMBER;

BEGIN

    -- initialization block
    l_stmt_id := 0;
    l_all_rates_found := true;
    l_pri_sec_curr_same := 0;

    l_stmt_id := 5;
    -- check if the primary and secondary currencies and rate types are
    -- identical.
    IF (s_global_curr_code = nvl (s_secondary_curr_code, '---') AND
        s_global_rate_type = nvl (s_secondary_rate_type, '---') ) THEN
        l_pri_sec_curr_same := 1;
    END IF;


    l_stmt_id := 10;
    -- Get all the distinct organization and date pairs and the
    -- base currency codes for the orgs into the conversion rates
    -- work table.

    -- Use the fii_currency.get_global_rate_primary function to get the
    -- conversion rate given a currency code and a date.
    -- The function returns:
    -- 1 for currency code of 'USD' which is the global currency
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

    INSERT /*+ append parallel (opi_dbi_inv_cca_conv) */
    INTO opi_dbi_inv_cca_conv (
        organization_id,
        func_currency_code,
        approval_date,
        conversion_rate,
        sec_conversion_rate)
    SELECT /*+ parallel (to_conv) parallel (curr_codes) */
        to_conv.organization_id,
        curr_codes.currency_code,
        to_conv.approval_date,
        decode (curr_codes.currency_code,
                s_global_curr_code, 1,
                fii_currency.get_global_rate_primary (
                                    curr_codes.currency_code,
                                    to_conv.approval_date) ),
        decode (s_secondary_curr_code,
                NULL, NULL,
                curr_codes.currency_code, 1,
                decode (l_pri_sec_curr_same,
                        1, C_PRI_SEC_CURR_SAME_MARKER,
                        fii_currency.get_global_rate_secondary (
                            curr_codes.currency_code,
                            to_conv.approval_date)))
      FROM
        (SELECT /*+ parallel (opi_dbi_inv_cca_stg) */
         DISTINCT organization_id, approval_date
           FROM opi_dbi_inv_cca_stg) to_conv,
        (SELECT /*+ leading (hoi) full (hoi) use_hash (gsob)
                    parallel (hoi) parallel (gsob)*/
         DISTINCT hoi.organization_id, gsob.currency_code
           FROM hr_organization_information hoi,
                gl_sets_of_books gsob
           WHERE hoi.org_information_context  = 'Accounting Information'
             AND hoi.org_information1  = to_char(gsob.set_of_books_id))
        curr_codes
      WHERE curr_codes.organization_id  = to_conv.organization_id;

    l_stmt_id := 15;
    commit;   -- due to insert+append

    l_stmt_id := 20;
    -- if the primary and secondary currency codes are the same, then
    -- update the secondary with the primary
    IF (l_pri_sec_curr_same = 1) THEN

        l_stmt_id := 30;
        UPDATE /*+ parallel (opi_dbi_inv_cca_conv) */ opi_dbi_inv_cca_conv
        SET sec_conversion_rate = conversion_rate;

        -- safe to commit, as before
        l_stmt_id := 40;
        commit;

    END IF;

    -- Check that all rates have been found and are non-negative.
    -- If there is a problem, notify user.
    l_stmt_id := 50;
    OPEN invalid_rates_exist_csr;
    FETCH invalid_rates_exist_csr INTO invalid_rates_exist_rec;
    IF (invalid_rates_exist_csr%FOUND) THEN

        -- print the header out
        BIS_COLLECTION_UTILITIES.writeMissingRateHeader;

        -- all rates not found
        l_all_rates_found := false;


        FOR invalid_rate_rec IN invalid_rates_csr (l_pri_sec_curr_same)
        LOOP

            BIS_COLLECTION_UTILITIES.writeMissingRate(
               invalid_rate_rec.rate_type,
               invalid_rate_rec.func_currency_code,
               invalid_rate_rec.curr_code,
               invalid_rate_rec.approval_date);

        END LOOP;
    END IF;

    l_stmt_id := 55;
    CLOSE invalid_rates_exist_csr;

    -- If all rates not found raise an exception
    l_stmt_id := 60;
    IF (l_all_rates_found = FALSE) THEN
        RAISE MISSING_CONV_RATES;
    END IF;

    RETURN;

EXCEPTION

    WHEN MISSING_CONV_RATES THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (MISSING_CONV_RATES_MESG,
                                             l_proc_name, l_stmt_id));
        RAISE CONV_RATES_ERROR;


    WHEN OTHERS THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));

        RAISE CONV_RATES_ERROR;


END compute_cca_conv_rates_init;


/* populate_fact_init

    Move all the staging table data into the fact table. The granularity
    of the data remains the same as the staging table i.e. the
    cycle count entry level.

    The fact joins to the conversion rates table to compute the values
    in both the functional currency and global currency.

    Quantities in the staging table are already the primary UOM.

    Adjustment values are computed using the item_adj_unit_cost which
    is derived from the MTA base_transaction_value. Thus reported
    adjustment values always match MTA.

    System inventory values are computed using the item_unit_cost which
    is the cost of the item at the time when the entry was first entered.
    Thus system inventory value matches that reported in Oracle Forms.
    This is to work around the issues of layered costing in LIFO/FIFO
    orgs (bug 3471888).

    Use the absolute value of system quantity to compute hit/miss because
    the system quantity can be negative. The tolerances however are
    defined as positive numbers. The sign and value of the adjustment
    are otherwise correct to allow for using absolute value of
    system quantity.

    The computation of whether an entry is a hit or a miss is done in
    this step.
    1. If the entry is an exact match, it is a hit.
    2. If the +ve and -ve hit/miss tolerances are null, it is a hit.
    3. If the system_inventory_qty is 0:
        - if the adjustment_qty is non zero, it is a miss.
        - else it is a hit.
    4. If the adjustment is +ve:
        - if the +ve tolerance is null, it is a hit.
        - else (adjustment_qty/system_inventory_qty) <=
            (+ve tolerance)/100, it is a hit.
        This check handles the divide by 0 case.
    5. If the adjustment is -ve:
        - if the -ve tolerance is null, it is a hit.
        - else (adjustment_qty/system_inventory_qty) <=
            (-ve tolerance)/100, it is a hit. [since both the negative
            adjustment quantities and tolerances are reported as
            positive numbers.]
    6. Any other case is a miss.

    Do not commit anything in this step. Let the wrapper handle that.

    History:
    Date        Author              Action
    01/15/04    Dinkar Gupta        Defined procedure.
    02/09/04    Dinkar Gupta        Used absolute value of
                                    system inventory quantity
                                    to compute hit/miss.
    03/10/04    Dinkar Gupta        Used item_cost from MCCE for system
                                    inventory value and cost from MTA
                                    for adjustment value to account for
                                    for LIFO/FIFO org layered costing.
    08/17/04    Dinkar Gupta        Added secondary currency support
*/

PROCEDURE populate_fact_init
IS

    l_proc_name CONSTANT VARCHAR2(40) := 'populate_fact_init';
    l_stmt_id NUMBER;

BEGIN

    -- initialization block
    l_stmt_id := 0;

    l_stmt_id := 10;
    -- Insert data into the fact table. For explanation of logic,
    -- see procedure header.
    INSERT /*+ append parallel(opi_dbi_inv_cca_f) */
    INTO opi_dbi_inv_cca_f (
        organization_id,
        inventory_item_id,
        cycle_count_header_id,
        abc_class_id,
        subinventory_code,
        cycle_count_entry_id,
        source,
        approval_date,
        uom_code,
        system_inventory_qty,
        system_inventory_val_b,
        system_inventory_val_g,
        system_inventory_val_sg,
        positive_adjustment_qty,
        positive_adjustment_val_b,
        positive_adjustment_val_g,
        positive_adjustment_val_sg,
        negative_adjustment_qty,
        negative_adjustment_val_b,
        negative_adjustment_val_g,
        negative_adjustment_val_sg,
        conversion_rate,
        sec_conversion_rate,
        item_unit_cost,
        hit_or_miss,
        exact_match,
        last_update_date,
        last_updated_by,
        last_update_login,
        creation_date,
        created_by,
        request_id,
        program_application_id,
        program_id,
        program_update_date)
    SELECT /*+ parallel(stg) parallel (conv) use_hash (stg conv)*/
        stg.organization_id,
        stg.inventory_item_id,
        stg.cycle_count_header_id,
        stg.abc_class_id,
        stg.subinventory_code,
        stg.cycle_count_entry_id,
        stg.source,
        stg.approval_date,
        stg.uom_code,
        stg.system_inventory_qty,
        stg.system_inventory_qty * stg.item_unit_cost,
        stg.system_inventory_qty * stg.item_unit_cost *
            conv.conversion_rate,
        stg.system_inventory_qty * stg.item_unit_cost *
            conv.sec_conversion_rate,
        stg.positive_adjustment_qty,
        stg.positive_adjustment_qty * stg.item_adj_unit_cost,
        stg.positive_adjustment_qty * stg.item_adj_unit_cost *
            conv.conversion_rate,
        stg.positive_adjustment_qty * stg.item_adj_unit_cost *
            conv.sec_conversion_rate,
        stg.negative_adjustment_qty,
        stg.negative_adjustment_qty * stg.item_adj_unit_cost,
        stg.negative_adjustment_qty * stg.item_adj_unit_cost *
            conv.conversion_rate,
        stg.negative_adjustment_qty * stg.item_adj_unit_cost *
            conv.sec_conversion_rate,
        conv.conversion_rate,
        conv.sec_conversion_rate,
        stg.item_unit_cost,
        CASE
            WHEN stg.exact_match = C_EXACT_MATCH THEN
                C_HIT
            WHEN stg.hit_miss_pos IS NULL AND stg.hit_miss_neg IS NULL THEN
                C_HIT
            WHEN stg.hit_miss_pos IS NULL AND
                 stg.positive_adjustment_qty > 0 THEN
                C_HIT
            WHEN stg.hit_miss_neg IS NULL AND
                 stg.negative_adjustment_qty > 0 THEN
                C_HIT
            WHEN stg.system_inventory_qty = 0 THEN
                CASE
                    WHEN stg.positive_adjustment_qty = 0 AND
                         stg.negative_adjustment_qty = 0 THEN
                        C_HIT
                    ELSE
                        C_MISS
                END
            WHEN stg.positive_adjustment_qty > 0 AND
                 (stg.positive_adjustment_qty/
                  abs (stg.system_inventory_qty)) <=
                 (stg.hit_miss_pos/100) THEN
                C_HIT
            WHEN stg.negative_adjustment_qty > 0 AND
                 (stg.negative_adjustment_qty/
                  abs (stg.system_inventory_qty)) <=
                 (stg.hit_miss_neg/100) THEN
                C_HIT
            ELSE
                C_MISS
            END,
        stg.exact_match,
        sysdate,
        s_user_id,
        s_login_id,
        sysdate,
        s_user_id,
        s_request_id,
        s_program_application_id,
        s_program_id,
        sysdate
      FROM  opi_dbi_inv_cca_stg stg,
            opi_dbi_inv_cca_conv conv
      WHERE stg.organization_id = conv.organization_id
        AND stg.approval_date = conv.approval_date;

    -- Do not commit here. Let the wrapper handle that.

    RETURN;

EXCEPTION

    WHEN OTHERS THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));

        RAISE FACT_MERGE_ERROR;

END populate_fact_init;




/**************************************************
* Incremental Load Procedure Definitions
**************************************************/

/* run_incr_load

    Wrapper routine for the incremental load of the cycle count accuracy ETL.

    Parameters:
    retcode - 0 on successful completion, -1 on error and 1 for warning.
    errbuf - empty on successful completion, message on error or warning

    History:
    Date        Author              Action
    01/12/04    Dinkar Gupta        Defined procedure.
    03/04/04    Dinkar Gupta        Added call to OPM package.
*/
PROCEDURE run_incr_load (errbuf OUT NOCOPY VARCHAR2,
                         retcode OUT NOCOPY NUMBER)

IS
    l_proc_name CONSTANT VARCHAR2 (40) := 'run_incr_load';
    l_stmt_id NUMBER;

BEGIN

    -- initialization block
    l_stmt_id := 0;

    l_stmt_id := 10;
    -- Check for DBI global parameter setup, initialize file scope variables,
    -- check for bounds and truncate the needed tables.
    BIS_COLLECTION_UTILITIES.PUT_LINE ('Initializing cycle count incremental load ...');
    cca_initialize_incr ();

    l_stmt_id := 20;
    -- Set up the bounds for Cycle Count accuracy in the log table.
    BIS_COLLECTION_UTILITIES.PUT_LINE (
        'Setting up bounds for discrete manufacturing organzations ...');
    -- return status not speified in the procedure
    OPI_DBI_BOUNDS_PKG.MAINTAIN_OPI_DBI_LOGS (	p_etl_type=> C_ETL_TYPE,
						p_load_type=> C_LOAD_INCR);
    l_stmt_id := 30;
    -- Extract the adjustment entry data from MMT/MTA using the
    -- bounds just set up.
    BIS_COLLECTION_UTILITIES.PUT_LINE (
        'Extracting cycle count adjustment information for discrete manufacturing orgs ...');
    extract_discrete_adj_incr (s_global_start_date);

    l_stmt_id := 40;
    -- Due to the bulk insert, commit before
    -- inputting more data to the staging table.
    commit;

    l_stmt_id := 45;
    -- Call API to load ledger data into Global temp table
    -- This temp table will be joined to extract process adjustments
    BIS_COLLECTION_UTILITIES.PUT_LINE (
        'Loading Ledger data into temp table ...');
    OPI_DBI_BOUNDS_PKG.load_opm_org_ledger_data;

     l_stmt_id := 47;
    -- Committing the data. Since the temp table is made with On Commit preserve rows
    -- there will be no problem.
    commit;

    l_stmt_id := 50;
    -- Extract the adjustment entry data from MMT/MTA using the
    -- bounds just set up.
    BIS_COLLECTION_UTILITIES.PUT_LINE (
        'Extracting cycle count adjustment information for process manufacturing orgs ...');
    extract_process_adj_incr (s_global_start_date);

    l_stmt_id := 60;
    -- Due to the bulk insert, commit before
    -- inputting more data to the staging table.
    commit;

    l_stmt_id := 70;
    -- Extract the exact matches entry data from MCCE. Collect all rows
    -- with last_update_date greater than the global start date.
    BIS_COLLECTION_UTILITIES.PUT_LINE (
        'Extracting cycle count exact match information for discrete and process manufacturing organizations ...');
    extract_exact_matches_incr ();

    l_stmt_id := 80;
    -- Due to the bulk insert, commit before moving ahead.
    commit;

    l_stmt_id := 90;
    -- Compute the conversion rates for all org/date pairs in the
    -- staging table. This API will now commit, due to an
    -- insert+append hint.
    BIS_COLLECTION_UTILITIES.PUT_LINE (
        'Computing conversion rates for all extracted cycle counting data ...');
    compute_cca_conv_rates_incr (s_global_curr_code, s_global_rate_type);

    l_stmt_id := 100;
    -- Commit the conversion rates found before finally merging all
    -- data to the fact table.
    commit;

    l_stmt_id := 110;
    -- Insert all the data into the fact table in one shot.
    BIS_COLLECTION_UTILITIES.PUT_LINE ('Inserting data into the fact table ...');
    populate_fact_incr ();


    l_stmt_id := 120;
    -- Update the bounds table
    BIS_COLLECTION_UTILITIES.PUT_LINE ('Updating run time bounds for next run ...');
    -- return status not speified in the procedure
    OPI_DBI_BOUNDS_PKG.SET_LOAD_SUCCESSFUL(C_ETL_TYPE, C_LOAD_INCR);


    l_stmt_id := 130;
    -- Truncate the staging table, commit the data to the fact table
    -- and update the bounds related to cycle counts in one database
    -- transaction for consistency.
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
                       'opi_dbi_inv_cca_stg');


    -- return successfully
    retcode := C_SUCCESS;
    errbuf := '';

    BIS_COLLECTION_UTILITIES.PUT_LINE ('Cycle count data extracted into the fact table successfully.');

    RETURN;

EXCEPTION



    WHEN INITIALIZATION_ERROR THEN

        rollback;

        -- report the error
        retcode := C_ERROR;
        errbuf := 'Inventory Cycle Count Accuracy ETL incremental load terminated with errors. Please check the concurrent program log file for errors.';
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (INITIALIZATION_ERROR_MESG,
                                             l_proc_name, l_stmt_id));
        RETURN;


    WHEN BOUNDS_SETUP_ERROR THEN

        rollback;

        -- report the error
        retcode := C_ERROR;
        errbuf := 'Inventory Cycle Count Accuracy ETL incremental load terminated with errors. Please check the concurrent program log file for errors.';
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (BOUNDS_SETUP_ERROR_MESG,
                                             l_proc_name, l_stmt_id));
        RETURN;


    WHEN ADJUSTMENT_EXTR_ERROR THEN

        rollback;

        -- report the error
        retcode := C_ERROR;
        errbuf := 'Inventory Cycle Count Accuracy ETL incremental load terminated with errors. Please check the concurrent program log file for errors.';
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (ADJUSTMENT_EXTR_ERROR_MESG,
                                             l_proc_name, l_stmt_id));
        RETURN;


    WHEN EXACT_MATCH_EXTR_ERROR THEN

        rollback;

        -- Truncate the staging table because extraction failed midway.
        -- In the next run, all previously extracted and
        -- adjustment entry data will be re-extracted.
        EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
                           'opi_dbi_inv_cca_stg');

        -- report the error
        retcode := C_ERROR;
        errbuf := 'Inventory Cycle Count Accuracy ETL incremental load terminated with errors. Please check the concurrent program log file for errors.';
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (EXACT_MATCH_EXTR_ERROR_MESG,
                                             l_proc_name, l_stmt_id));
        RETURN;


    WHEN BOUNDS_UPDATE_ERROR THEN

        rollback;

        -- Truncate the staging table because extraction failed midway.
        -- In the next run, all previously extracted exact match and
        -- adjustment entry data will be re-extracted.
        EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
                           'opi_dbi_inv_cca_stg');

        -- report the error
        retcode := C_ERROR;
        errbuf := 'Inventory Cycle Count Accuracy ETL incremental load terminated with errors. Please check the concurrent program log file for errors.';
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (BOUNDS_UPDATE_ERROR_MESG,
                                             l_proc_name, l_stmt_id));
        RETURN;



    WHEN CONV_RATES_ERROR THEN

        rollback;

        -- report the error
        retcode := C_ERROR;
        errbuf := 'Inventory Cycle Count Accuracy ETL incremental load terminated with errors. Please check the concurrent program log file for errors.';
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (CONV_RATES_ERROR_MESG,
                                             l_proc_name, l_stmt_id));
        RETURN;


    WHEN FACT_MERGE_ERROR THEN

        rollback;

        -- report the error
        retcode := C_ERROR;
        errbuf := 'Inventory Cycle Count Accuracy ETL incremental load terminated with errors. Please check the concurrent program log file for errors.';
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (FACT_MERGE_ERROR_MESG,
                                             l_proc_name, l_stmt_id));
        RETURN;

    WHEN OPM_EXTRACTION_ERROR THEN

        rollback;

        -- report the error
        retcode := C_ERROR;
        errbuf := 'Inventory Cycle Count Accuracy ETL incremental load terminated with errors. Please check the concurrent program log file for errors.';
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (OPM_EXTRACTION_ERROR_MESG,
                                             l_proc_name, l_stmt_id));
        RETURN;

    WHEN OTHERS THEN

        rollback;

        -- report the error
        retcode := C_ERROR;
        errbuf := 'Inventory Cycle Count Accuracy ETL incremental load terminated with errors. Please check the concurrent program log file for errors.';

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));

        RETURN;

END run_incr_load;


/* cca_initialize_incr

    Check that the primary currency code and global start date have been
    set up.

    Get the OPI schema info.

    Check if the log table has rows created for type = 'CCA' to determine
    if at least the initial load has already been run.

    Truncate all the conversion rates table.

    If the transaction_id bounds are not null for all orgs, then
    an error occurred during the extraction in the previous run. If so,
    truncate the staging table as the partial extraction from last time
    will be redone all over again in this run.

    Note: Do not check to see if this initial load has been run previously.

    History:
    Date        Author              Action
    01/19/04    Dinkar Gupta        Defined procedure.
    04/08/04    Dinkar Gupta        Changed the bounds checking logic to
                                    only look for rows with missing
                                    from_transaction_ids. In case MMT was
                                    empty in the initial load, this will
                                    still behave properly.
    08/17/04    Dinkar Gupta        Added Secondary Currency support.
*/

PROCEDURE cca_initialize_incr
IS

    l_proc_name CONSTANT VARCHAR2 (40) := 'cca_initialize_incr';
    l_stmt_id NUMBER;


BEGIN

    -- initialization block
    l_stmt_id := 0;


    l_stmt_id := 10;
    -- Check for the primary currency code and global start date setup.
    -- These two parameters must be set up prior to any DBI load.
    IF (NOT (check_global_setup ())) THEN
        RAISE GLOBAL_SETUP_MISSING;
    END IF;

    l_stmt_id := 20;
    -- Obtain the OPI schema name to allow truncation of various tables
    -- get session parameters
    IF (NOT (fnd_installation.get_app_info('OPI', s_status, s_industry,
                                           s_opi_schema))) THEN
        RAISE SCHEMA_INFO_NOT_FOUND;
    END IF;


    -- Get the global start date
    l_stmt_id := 30;
    s_global_start_date := trunc (bis_common_parameters.get_global_start_date);
    IF (s_global_start_date IS NULL) THEN
        RAISE GLOBAL_START_DATE_NULL;
    END IF;


    l_stmt_id := 40;
    -- Get the DBI global currency code
    s_global_curr_code := bis_common_parameters.get_currency_code;

    l_stmt_id := 50;
    IF (s_global_curr_code IS NULL) THEN
        RAISE NO_GLOBAL_CURR_CODE;
    END IF;


    l_stmt_id := 60;
    -- Get the DBI Global rate type
    s_global_rate_type := bis_common_parameters.get_rate_type;

    l_stmt_id := 70;
    IF (s_global_rate_type IS NULL) THEN
        RAISE NO_GLOBAL_RATE_TYPE;
    END IF;

    l_stmt_id := 80;
    -- Get the DBI secondary currency code
    s_secondary_curr_code := bis_common_parameters.get_secondary_currency_code;

    l_stmt_id := 90;
    -- Get the DBI Global rate type
    s_secondary_rate_type := bis_common_parameters.get_secondary_rate_type;

    l_stmt_id := 100;
    IF (    (s_secondary_curr_code IS NULL AND
             s_secondary_rate_type IS NOT NULL)
         OR (s_secondary_curr_code IS NOT NULL AND
             s_secondary_rate_type IS NULL) ) THEN
        RAISE SEC_CURR_SETUP_INVALID;
    END IF;

    l_stmt_id := 110;
    -- Since bounds are now being updated only when the merge to
    -- the fact is complete and are being committed using the truncate
    -- on the staging table, just ensure that the staging table is
    -- truncated.
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
                       'opi_dbi_inv_cca_stg');


    -- Truncate the following tables (in case of exceptions, nothing
    -- special to do here because it is a database error):

    l_stmt_id := 120;
    -- Conversion rates table
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
                       'opi_dbi_inv_cca_conv');

    -- Not using
    l_stmt_id := 130;
    -- Temp table for bounds computation
    --EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
     --                  'opi_dbi_inv_value_log_tmp');


    l_stmt_id := 140;
    -- User and login id's
    s_user_id := nvl(fnd_global.user_id, -1);
    s_login_id := nvl(fnd_global.login_id, -1);
    s_program_id := nvl(fnd_global.conc_program_id, -1);
    s_program_login_id := nvl(fnd_global.conc_login_id , -1);
    s_program_application_id := nvl(fnd_global.prog_appl_id , -1);
    s_request_id := nvl(fnd_global.conc_request_id, -1);

    RETURN;

EXCEPTION

    WHEN GLOBAL_SETUP_MISSING THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (GLOBAL_SETUP_MISSING_MESG,
                                                     l_proc_name, l_stmt_id));
        RAISE INITIALIZATION_ERROR;

    WHEN SCHEMA_INFO_NOT_FOUND THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (SCHEMA_INFO_NOT_FOUND_MESG,
                                             l_proc_name, l_stmt_id));
        RAISE INITIALIZATION_ERROR;


    WHEN GLOBAL_START_DATE_NULL THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (GLOBAL_START_DATE_NULL_MESG,
                                             l_proc_name, l_stmt_id));
        RAISE INITIALIZATION_ERROR;


    WHEN NO_GLOBAL_CURR_CODE THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (NO_GLOBAL_CURR_CODE_MESG,
                                             l_proc_name, l_stmt_id));
        RAISE INITIALIZATION_ERROR;


    WHEN NO_GLOBAL_RATE_TYPE THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (NO_GLOBAL_RATE_TYPE_MESG,
                                             l_proc_name, l_stmt_id));
        RAISE INITIALIZATION_ERROR;


    WHEN SEC_CURR_SETUP_INVALID THEN
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (SEC_CURR_SETUP_INVALID_MESG,
                                             l_proc_name, l_stmt_id));

        RAISE INITIALIZATION_ERROR;

    WHEN OTHERS THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));

        RAISE INITIALIZATION_ERROR;


END cca_initialize_incr;


/* extract_discrete_adj_incr

    Extract discrete adjustment entry data from MTL_CYCLE_COUNT_ENTRIES (MCCE),
    MMT and MTA. Adjustments can get costed well after approval and
    interim cost updates may cause the values recorded in MCCE to
    be different. Thus we need to get the cost associated to the item
    using the value in MTA so that the reported adjustments match
    the MTA reported value.

    However, due to issues with layered costing in LIFO/FIFO orgs, the
    system inventory value is computed using the cost at the time when
    the entry was made. Thus the reported system inventory value
    matches the one reported in Oracle Forms.

    We are only interested in entries completed after the global start
    date (i.e. entry_status_code = 5 and approval_date > global start date).

    The only MTA rows we are interested in are those that affect the
    inventory account (accounting line type = 1).

    MTA does not store rows for expense items, or items in expense
    subinventories. Thus the join between MMT and MTA will have to
    be an outer join. Rows with no matches will be assigned an
    item cost of 0.

    MCCE does not store quantities in the primary uom_code. If the
    transaction uom is not the same as the primary uom, all
    quantities will have to be converted to the primary uom.

    There is a need to check for adjustment quantity = 0 serial item counts
    can have count level matches, but serial number level adjustments,
    To handle this, make four enhancements:
    1. Declare exact matches if the sum of the MMT primary quantity is 0.
    2. Pick the MCCE item_unit_cost if the quantity is 0 (check for expense
       subs before that).
    3. Set the tolerance to 0 if there is an adjustment in another
       subinventory that the one counted. This will automatically
       make any adjustments against it misses.
    4. The system_inventory_qty for the other subinventory is the negative
       of the adjustment quantity, so that the sum of the adjustment
       and system quantity is always 0.

    We will only be scanning MMT rows between the transaction ranges
    in the log table.

    Also, since the fact table is at a cycle count entry level,
    it is impossible for the sum (mmt.primary_quantity) to be 0. Thus
    the item_cost formula of sum (value)/sum (quantity) is always
    valid and we need not worry about sum (quantity) being 0 or NULL.

    Since the join conditions between MCCE - MMT - MTA is one to many
    to many, join MMT/MTA on transaction_id first.

    Also, to handle serial item adjustments where the adjustment
    automatically issues an item from a sub to move it to the next,
    use the subinventory_code from MMT, not MCCE.

    -------- R12 Changes
    1> Subinventory Transfer type of transaction (MMT.transaction_type_id = 5)
       is seen in Cycle Count. This case occurs when a LPN is received in
       say BULK, and cycle count is done in say CASE for a specific LPN.
       This type of transaction has 2 rows in MMT, one for issue transaction
       and other for receipt transaction. But the MTA has no rows for receipt
       transaction while it has 2 entries differing only in MTA.primary_quantity.
       Can be done through Warehouse mobile.

       Currently for such transactions MMT.cycle_count_id is not populated.
       Bug # 4392340 has been logged for the same.

    2> Changes to log table and columns.

    ----------------------


    Do not commit data. Let the wrapper coordinate committing of data.

    Paramters:
    IN:
        p_global_start_date - DBI global start date


    History:
    Date        Author              Action
    01/19/04    Dinkar Gupta        Defined procedure.
    02/10/04    Dinkar Gupta        Added group by transaction_id
                                    in the mmt/mta join.
                                    Used MMT subinventory_code
                                    to handle serial item issues.
    02/18/04    Dinkar Gupta        Added condition to handle
                                    cases where MMT quantity is 0 for
                                    serial items.
                                    Also added condition to report miss
                                    for adjustments against any other
                                    sub than the one being counted.
    03/10/04    Dinkar Gupta        Used item_cost from MCCE for system
                                    inventory value for LIFO/FIFO org
                                    issue.


    06/22/05    Vishal Gupta        Refer to R12 Changes in the above
                                    header.


*/
PROCEDURE extract_discrete_adj_incr (p_global_start_date IN DATE)
IS
    l_proc_name         CONSTANT VARCHAR2 (40) := 'extract_adjustments_init';
    l_stmt_id           NUMBER;

BEGIN

    -- initialization block
    l_stmt_id := 0;

    l_stmt_id := 10;
    -- This procedure only inserts all adjustment entry data into the
    -- staging table. For an explanation of the logic, please refer to the
    -- procedure header.

    -- Join condition justifications
    --
    -- to MCCC - on org, header and abc_class. The org is redundant,
    -- but this should allow use of U1 index on MCCC.
    --
    -- to MCCI - on header and item. This should allow use of U1 index
    -- on MCCI.
    --
    -- to MCCH - on header. This should allow use of U1 index.
    --
    -- to MCCE - on entry. This should allow use of U1 index.
    --
    -- to MSI - on org and item. This should allow use of the U1 index.
    --
    -- to SUBS - on org and subinventory code
    INSERT
    INTO opi_dbi_inv_cca_stg (
        organization_id,
        inventory_item_id,
        cycle_count_header_id,
        abc_class_id,
        subinventory_code,
        cycle_count_entry_id,
        source,
        approval_date,
        uom_code,
        system_inventory_qty,
        positive_adjustment_qty,
        negative_adjustment_qty,
        item_unit_cost,
        item_adj_unit_cost,
        hit_miss_pos,
        hit_miss_neg,
        exact_match)
    SELECT
        mcce.organization_id,
        mcce.inventory_item_id,
        mcce.cycle_count_header_id,
        to_char (mccc.abc_class_id),
        mmt_mta.subinventory_code,
        to_char (mcce.cycle_count_entry_id),
        C_OPI_SOURCE,
        trunc (mcce.approval_date),
        msi.primary_uom_code,
        decode (mcce.count_uom_current,
                msi.primary_uom_code,
                decode (mmt_mta.subinventory_code,
                        mcce.subinventory, mcce.system_quantity_current,
                        -1 * sum (mmt_mta.primary_quantity)),
                decode (mmt_mta.subinventory_code,
                        mcce.subinventory,
                        inv_convert.inv_um_convert
                            (mcce.inventory_item_id, C_MMT_PRECISION,
                             mcce.system_quantity_current,
                             mcce.count_uom_current,
                             msi.primary_uom_code, NULL, NULL),
                        inv_convert.inv_um_convert
                            (mcce.inventory_item_id, C_MMT_PRECISION,
                             -1 * sum (mmt_mta.primary_quantity),
                             mcce.count_uom_current,
                             msi.primary_uom_code, NULL, NULL))),
        CASE WHEN sum (mmt_mta.primary_quantity) > 0 THEN
                    sum (mmt_mta.primary_quantity)
             ELSE   0
             END,
        CASE WHEN sum (mmt_mta.primary_quantity) < 0 THEN
                    -1 * sum (mmt_mta.primary_quantity)
             ELSE   0
             END,
        decode (subs.asset_inventory,
                C_EXPENSE_SUBINVENTORY, 0,
                mcce.item_unit_cost),
        decode (sum (mmt_mta.primary_quantity),
                0, decode (subs.asset_inventory,
                           C_EXPENSE_SUBINVENTORY, 0,
                           mcce.item_unit_cost),
                nvl (sum (mmt_mta.base_transaction_value)/
                     sum (mmt_mta.primary_quantity), 0)),
        decode (mmt_mta.subinventory_code,
                mcce.subinventory, nvl (mccc.hit_miss_tolerance_positive,
                                        mcch.hit_miss_tolerance_positive),
                0),
        decode (mmt_mta.subinventory_code,
                mcce.subinventory, nvl (mccc.hit_miss_tolerance_negative,
                                        mcch.hit_miss_tolerance_negative),
                0),
        decode (sum (mmt_mta.primary_quantity),
                0, C_EXACT_MATCH,
                C_NO_MATCH)
      FROM  mtl_cycle_count_entries mcce,
            mtl_cycle_count_headers mcch,
            mtl_cycle_count_items mcci,
            mtl_cycle_count_classes mccc,
            mtl_system_items_b msi,
            mtl_secondary_inventories subs,
            (SELECT
                mmt.organization_id,
                mmt.inventory_item_id,
                mmt.transaction_date,
                mmt.cycle_count_id,
                decode (mmt.transaction_type_id,
                        5, decode(sign(nvl(mta.primary_quantity,0)),
                                  1, 0,
                                  mmt.primary_quantity),
                        mmt.primary_quantity)   primary_quantity,
                decode (mmt.transaction_type_id,
                        5, decode(sign(nvl(mta.primary_quantity,0)),
                                  1, mmt.transfer_subinventory,
                                  mmt.subinventory_code),
                        mmt.subinventory_code)  subinventory_code,
                sum (mta.base_transaction_value) base_transaction_value
              FROM mtl_material_transactions mmt,
                   mtl_transaction_accounts mta,
                   opi_dbi_conc_prog_run_log log
              WHERE log.etl_type = C_ETL_TYPE
                AND log.driving_table_code = C_LOG_MMT_DRV_TBL
                AND log.load_type = C_LOAD_INCR
                AND mmt.organization_id = log.bound_level_entity_id
                AND mmt.transaction_id >= log.from_bound_id
                AND mmt.transaction_id <  log.to_bound_id
                AND mmt.transaction_date > p_global_start_date
                AND mmt.transaction_source_type_id = 9
                AND mmt.transaction_type_id in ( C_MMT_CYCLE_COUNT_ADJ, 5)
                --AND mmt.transaction_type_id = C_MMT_CYCLE_COUNT_ADJ
                AND mmt.transaction_id = mta.transaction_id (+)
                AND nvl (mta.accounting_line_type, C_INVENTORY_ACCOUNT) =
                        C_INVENTORY_ACCOUNT
              GROUP BY
                    mmt.organization_id,
                    mmt.inventory_item_id,
                    mmt.transaction_date,
                    mmt.cycle_count_id,
                    decode (mmt.transaction_type_id,
                        5, decode(sign(nvl(mta.primary_quantity,0)),
                                  1, 0,
                                  mmt.primary_quantity),
                        mmt.primary_quantity),
                    decode (mmt.transaction_type_id,
                        5, decode(sign(nvl(mta.primary_quantity,0)),
                                  1, mmt.transfer_subinventory,
                                  mmt.subinventory_code),
                        mmt.subinventory_code),
                    mmt.transaction_id) mmt_mta
      WHERE mmt_mta.organization_id = msi.organization_id
        AND mmt_mta.inventory_item_id = msi.inventory_item_id
        AND mmt_mta.cycle_count_id = mcce.cycle_count_entry_id
        AND mcce.entry_status_code = C_COMPLETED_CCA_ENTRY
        AND mcce.cycle_count_header_id = mcch.cycle_count_header_id
        AND mcce.cycle_count_header_id = mcci.cycle_count_header_id
        AND mcce.inventory_item_id = mcci.inventory_item_id
        AND mcce.organization_id = mccc.organization_id
        AND mcce.cycle_count_header_id = mccc.cycle_count_header_id
        AND mcci.abc_class_id = mccc.abc_class_id
        AND mmt_mta.organization_id = subs.organization_id
        AND mmt_mta.subinventory_code = subs.secondary_inventory_name
      GROUP BY
        mcce.organization_id,
        mcce.inventory_item_id,
        mcce.cycle_count_header_id,
        mccc.abc_class_id,
        mmt_mta.subinventory_code,
        mcce.cycle_count_entry_id,
        trunc (mcce.approval_date),
        msi.primary_uom_code,
        mcce.count_uom_current,
        mcce.system_quantity_current,
        subs.asset_inventory,
        mcce.item_unit_cost,
        mcce.subinventory,
        mccc.hit_miss_tolerance_positive,
        mcch.hit_miss_tolerance_positive,
        mcce.subinventory,
        mccc.hit_miss_tolerance_negative,
        mcch.hit_miss_tolerance_negative;

    RETURN;

EXCEPTION

    WHEN OTHERS THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));

        RAISE ADJUSTMENT_EXTR_ERROR;

END extract_discrete_adj_incr;



/* extract_process_adj_incr

    Extract process adjustment entry data from MTL_CYCLE_COUNT_ENTRIES (MCCE),
    MMT and GTV. The transactions in GTV can be either in Draft, New or Final Mode.
    We will only consider Draft and Final Mode of transactions only.

    For initial load there will not be any separate bounds for Final and Draft
    transaction.

    Subinventory Transafer type of transaction for Cycle Count is considered. There
    is no change from discrete.

        1> Subinventory Transfer type of transaction (MMT.transaction_type_id = 5)
       is seen in Cycle Count. This case occurs when a LPN is received in
       say BULK, and cycle count is done in say CASE for a specific LPN.
       This type of transaction has 2 rows in MMT, one for issue transaction
       and other for receipt transaction. But the GTV has no rows for receipt
       transaction while it has 2 entries differing only in GTV.subinventory_code.
       GTV.subinventory_code will have issue subinventory_code for one of two rows in GTV
       pertianing to issue transaction in MMT. The other row will have
       MMT.transfer_subinventory in GTV.subinventory_code.


       Currently for such transactions MMT.cycle_count_id is not populated.
       Bug # 4392340 has been logged for the same.

    The bounds for Process is applied same for all organization. The driving table
    will be GTV.
    To isolate cycle count transaction in GTV following is required:
    EVENT_CLASS_CODE = 'MISC_TXN' and 'SUBINV_XFER'
    EVENT_TYPE_CODE = 'CYCLE_COUNT_ADJ'	and 'CYCLE_COUNT_XFER'
    JOURNAL_LINE_TYPE = 'INV'
    TRANSACTION_SOURCE = 'INVENTORY'

    We are only interested in entries completed after the global start
    date (i.e. entry_status_code = 5 and approval_date > global start date).

    Unlike the case with MTA, GTV has rows for expense items, or items in
    expense subinventories. Hence also no outer join is required.

    Adjustments can get costed well after approval and interim cost updates may
    cause the values recorded in MCCE to be different. Thus we need to get the
    cost associated to the item using the value in GTV so that the reported
    adjustments match the GTV reported value.

    However, due to issues with layered costing in LIFO/FIFO orgs, the
    system inventory value is computed using the cost at the time when
    the entry was made. Thus the reported system inventory value
    matches the one reported in Oracle Forms.

    MCCE does not store quantities in the primary uom_code. If the
    transaction uom is not the same as the primary uom, all
    quantities will have to be converted to the primary uom.

    Also, since the fact table is at a cycle count entry level,
    it is impossible for the sum (mmt.primary_quantity) to be 0. Thus
    the item_cost formula of sum (value)/sum (quantity) is always
    valid and we need not worry about sum (quantity) being 0 or NULL.

    Since the join conditions between MCCE - MMT - GTV is one to many
    to many, join GTV/MMT on transaction_id first.

    Do not commit data. Let the wrapper coordinate committing of data.

    Paramters:
    IN:
        p_global_start_date - DBI global start date

    History:
    Date        Author              Action
    06/22/05    Vishal Gupta        New Procedure. To collect data for
                                    Post R12 Process cycle counting,


*/
PROCEDURE extract_process_adj_incr (p_global_start_date IN DATE)
IS
    l_proc_name         CONSTANT VARCHAR2 (40) := 'extract_adjustments_init';
    l_stmt_id           NUMBER;
    l_from_bound_date   OPI_DBI_CONC_PROG_RUN_LOG.from_bound_date%type;
    l_to_bound_date     OPI_DBI_CONC_PROG_RUN_LOG.to_bound_date%type;

BEGIN

    -- initialization block
    l_stmt_id := 0;

    SELECT from_bound_date, to_bound_date
    INTO l_from_bound_date, l_to_bound_date
    FROM OPI_DBI_CONC_PROG_RUN_LOG
    WHERE driving_table_code = C_LOG_GTV_DRV_TBL
      AND etl_type = C_ETL_TYPE
      AND load_type = C_LOAD_INCR;


    l_stmt_id := 10;
    -- This procedure only inserts all adjustment entry data into the
    -- staging table. For an explanation of the logic, please refer to the
    -- procedure header.

    -- Join condition justifications
    --
    -- to MCCC - on org, header and abc_class. The org is redundant,
    -- but this should allow use of U1 index on MCCC.
    --
    -- to MCCI - on header and item. This should allow use of U1 index
    -- on MCCI.
    --
    -- to MCCH - on header. This should allow use of U1 index.
    --
    -- to MCCE - on entry. This should allow use of U1 index.
    --
    -- to MSI - on org and item. This should allow use of the U1 index.
    --
    -- to SUBS - on org and subinventory code


     INSERT
     INTO opi_dbi_inv_cca_stg (
        organization_id,
        inventory_item_id,
        cycle_count_header_id,
        abc_class_id,
        subinventory_code,
        cycle_count_entry_id,
        source,
        approval_date,
        uom_code,
        system_inventory_qty,
        positive_adjustment_qty,
        negative_adjustment_qty,
        item_unit_cost,
        item_adj_unit_cost,
        hit_miss_pos,
        hit_miss_neg,
        exact_match   )
     SELECT  mcce.organization_id,
      mcce.inventory_item_id,
      mcce.cycle_count_header_id,
      to_char (mccc.abc_class_id),
      mmt_gtv.subinventory_code,
      to_char (mcce.cycle_count_entry_id),
      C_OPM_SOURCE,
      trunc (mcce.approval_date),
      msi.primary_uom_code,
      decode (mcce.count_uom_current,
      msi.primary_uom_code,
      mcce.system_quantity_current,
      inv_convert.inv_um_convert (      mcce.inventory_item_id,
                                        C_MMT_PRECISION,
                                        mcce.system_quantity_current,
                                        mcce.count_uom_current,
                                        msi.primary_uom_code,
                                        NULL,
                                        NULL)) system_inventory_qty,
      CASE WHEN sum (mmt_gtv.primary_quantity) > 0 THEN
                sum (mmt_gtv.primary_quantity)
           ELSE   0
      END          positive_adjustment_qty,
      CASE WHEN sum (mmt_gtv.primary_quantity) < 0 THEN
                -1 * sum (mmt_gtv.primary_quantity)
      ELSE   0
      END          negative_adjustment_qty ,
      decode (subs.asset_inventory,
                C_EXPENSE_SUBINVENTORY, 0,
                mcce.item_unit_cost)        item_unit_cost,
      decode (sum (mmt_gtv.primary_quantity),
                0, decode (subs.asset_inventory,
                                C_EXPENSE_SUBINVENTORY, 0,
                                mcce.item_unit_cost),
                nvl (sum (mmt_gtv.transaction_base_value)/
                        sum (mmt_gtv.primary_quantity), 0))        item_adj_unit_cost,
      decode (mmt_gtv.subinventory_code,
              mcce.subinventory, nvl (mccc.hit_miss_tolerance_positive,
                                      mcch.hit_miss_tolerance_positive),
              0),
      decode (mmt_gtv.subinventory_code,
              mcce.subinventory, nvl (mccc.hit_miss_tolerance_negative,
                                      mcch.hit_miss_tolerance_negative),
              0),
      decode (sum (mmt_gtv.primary_quantity),
              0, C_EXACT_MATCH,
              C_NO_MATCH)          exact_match
    FROM    mtl_cycle_count_entries mcce,
        mtl_cycle_count_headers mcch,
        mtl_cycle_count_items mcci,
        mtl_cycle_count_classes mccc,
        mtl_system_items_b msi,
        mtl_secondary_inventories subs,
	-- as MMT to GTV is one to many relation grouping is done
	-- by transaction_id and primary_quantity level.
        (SELECT  mmt.organization_id,
                mmt.transaction_id,
                mmt.inventory_item_id,
                mmt.cycle_count_id,
                DECODE (mmt.transaction_type_id ,
                    5 , DECODE(GTV.subinventory_code,
                        MMT.subinventory_code, MMT.primary_quantity,
                        mmt.transfer_subinventory, -1* MMT.primary_quantity),mmt.primary_quantity)   primary_quantity,
                DECODE (mmt.transaction_type_id ,
                    5 ,GTV.subinventory_code,
                    mmt.subinventory_code)  subinventory_code,
                SUM (gtv.txn_base_value) transaction_base_value
        FROM    mtl_material_transactions mmt ,
                (SELECT gt.*
                FROM gmf_transaction_valuation gt,
                opi_dbi_org_le_temp olt
                WHERE olt.organization_id = gt.organization_id
                AND olt.ledger_id = gt.ledger_id
                AND olt.legal_entity_id = gt.legal_entity_id
                AND olt.valuation_cost_type_id = gt.valuation_cost_type_id) gtv
        WHERE   gtv.event_class_code in ( 'MISC_TXN','SUBINV_XFER')
         AND    gtv.event_type_code in ('CYCLE_COUNT_ADJ','CYCLE_COUNT_XFER')
         AND    gtv.journal_line_type = 'INV'
         AND    gtv.transaction_source = 'INVENTORY'
         AND    gtv.transaction_date >= l_from_bound_date
	 -- all draft rows are considered in every incremental run
         AND    DECODE( accounted_flag,
                        NULL, gtv.final_posting_date,
                       'D',s_global_start_date) < l_to_bound_date
         and    gtv.transaction_id = mmt.transaction_id
        GROUP BY
                mmt.organization_id,
                mmt.inventory_item_id,
                mmt.cycle_count_id,
                DECODE (mmt.transaction_type_id ,
                    5 , DECODE(GTV.subinventory_code,
                        MMT.subinventory_code, MMT.primary_quantity,
                        mmt.transfer_subinventory, -1* MMT.primary_quantity),mmt.primary_quantity),
                DECODE (mmt.transaction_type_id ,
                    5 ,GTV.subinventory_code,
                    mmt.subinventory_code) ,
                mmt.transaction_id) mmt_gtv
    WHERE   mmt_gtv.organization_id = msi.organization_id
      AND   mmt_gtv.inventory_item_id = msi.inventory_item_id
      AND   mmt_gtv.cycle_count_id = mcce.cycle_count_entry_id
      AND   mcce.entry_status_code = C_COMPLETED_CCA_ENTRY -- 5
      AND   mcce.cycle_count_header_id = mcch.cycle_count_header_id
      AND   mcce.cycle_count_header_id = mcci.cycle_count_header_id
      AND   mcce.inventory_item_id = mcci.inventory_item_id
      AND   mcce.organization_id = mccc.organization_id
      AND   mcce.cycle_count_header_id = mccc.cycle_count_header_id
      AND   mcci.abc_class_id = mccc.abc_class_id
      AND   mmt_gtv.organization_id = subs.organization_id
      AND   mmt_gtv.subinventory_code = subs.secondary_inventory_name
    GROUP BY
            mcce.organization_id,
            mcce.inventory_item_id,
            mcce.cycle_count_header_id,
            mccc.abc_class_id,
            mmt_gtv.subinventory_code,
            mcce.cycle_count_entry_id,
            trunc (mcce.approval_date),
            msi.primary_uom_code,
            mcce.count_uom_current,
            mcce.system_quantity_current,
            subs.asset_inventory,
            mcce.item_unit_cost,
            mcce.subinventory,
            mccc.hit_miss_tolerance_positive,
            mcch.hit_miss_tolerance_positive,
            mcce.subinventory,
            mccc.hit_miss_tolerance_negative,
            mcch.hit_miss_tolerance_negative;



   RETURN;

EXCEPTION

    WHEN OTHERS THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));

        RAISE ADJUSTMENT_EXTR_ERROR;

END extract_process_adj_incr;




/* extract_exact_matches_incr

    Extract the exact match entry data from the MTL_CYCLE_COUNT_ENTRIES
    table. Exact match data is easier to handle than adjustment entries
    because exact matches are approved on creation and there are no
    other transaction tables that need to be visited.

    We are only interested in entries completed after the global start
    date (i.e. entry_status_code = 5 and approval_date > global start date).

    The adjustment quantity is always 0 and hit/miss tolerances are not
    needed since all entries are, by definition, hits. We still need to join
    to MTL_CYCLE_COUNT_CLASSES to get the count and count class information.

    No need to join to MTL_CYCLE_COUNT_HEADERS as we don't need to
    get any tolerances.

    MCCE does not store quantities in the primary uom_code. If the
    transaction uom is not the same as the primary uom, all
    quantities will have to be converted to the primary uom.

    The date range being extracted is specified in the log table.

    However, since we are dealing with last_update_dates, we need to
    be sure that the dates in the log tables have timestamps so that
    we do not collect partially collected days again.

    The one special case is that we need to identify expense
    subinventories and set the item cost to 0 for all entries
    bearing those subinventory codes.


    ------------ R12 Changes
    Since Process exact matches will be extracted in the same insert.
    Date bounds speific to organization based on first uncosted transaction
    cannot be applied. Hence we will use date bounds as that for GTV.
    ie Collect all the exact matches between global start date and the initial
    program run date.
    ------------

    Do not commit data. Let the wrapper coordinate committing of data.

    Parameters:
    None.

    History:
    Date        Author              Action
    01/19/04    Dinkar Gupta        Defined procedure.
    02/05/04    Dinkar Gupta        Added logic to join to the from and to
                                    transaction dates in the log table.
    06/22/05    Vishal Gupta        Refer to R12 Changes in the above header.

*/

PROCEDURE extract_exact_matches_incr
IS
    l_proc_name         CONSTANT VARCHAR2 (40) := 'extract_exact_matches_incr';
    l_stmt_id	        NUMBER;
    l_from_bound_date   OPI_DBI_CONC_PROG_RUN_LOG.from_bound_date%type;
    l_to_bound_date     OPI_DBI_CONC_PROG_RUN_LOG.to_bound_date%type;

BEGIN

    -- initialization block
    l_stmt_id := 0;

    SELECT from_bound_date, to_bound_date
    INTO l_from_bound_date, l_to_bound_date
    FROM OPI_DBI_CONC_PROG_RUN_LOG
    WHERE driving_table_code = C_LOG_GTV_DRV_TBL
      AND etl_type = C_ETL_TYPE
      AND load_type = C_LOAD_INCR;


    l_stmt_id := 10;
    -- This procedure will extract all all exact match data from MCCE
    -- and insert it into the staging table. For SQL logic, please refer
    -- to the procedure header

    -- Join condition justifications
    --
    -- to MCCC - on org, header and abc_class. The org is redundant,
    -- but this should allow use of U1 index on MCCC.
    -- Note the explicit check for the 0 adjustment quantity. This should
    -- ideally not be required but we found an example (which we have not
    -- been able to recreate) where there was an adjustment on a serialized
    -- item but the adjustment date was null in MCCE and
    -- MTL_CC_SERIAL_NUMBERS. To filter that case, we filter explicitly on
    -- on the quantity. Most likely, this is an OLTP bug that will be
    -- fixed.
    --
    -- to MCCI - on header and item. This should allow use of U1 index
    -- on MCCI.
    --
    -- to MCCE - on entry. This should allow use of U1 index.
    --  On entry_status_code. This is the leading column of the N6 index.
    --  Filter on last_update_date. This should use the newly created
    --  N8 (?) index.
    --
    -- no join needed to log - as we can extract GTV date bounds into variables
    -- .


    INSERT
    INTO opi_dbi_inv_cca_stg (
        organization_id,
        inventory_item_id,
        cycle_count_header_id,
        abc_class_id,
        subinventory_code,
        cycle_count_entry_id,
        source,
        approval_date,
        uom_code,
        system_inventory_qty,
        positive_adjustment_qty,
        negative_adjustment_qty,
        item_unit_cost,
        item_adj_unit_cost,
        hit_miss_pos,
        hit_miss_neg,
        exact_match)
    SELECT
        mcce.organization_id,
        mcce.inventory_item_id,
        mcce.cycle_count_header_id,
        to_char (mccc.abc_class_id),
        mcce.subinventory,
        to_char (mcce.cycle_count_entry_id),
        decode(mp.process_enabled_flag,
                'Y',C_OPM_SOURCE,
                C_OPI_SOURCE )  source,
        trunc (mcce.approval_date),
        msi.primary_uom_code,
        decode (mcce.count_uom_current,
                msi.primary_uom_code, mcce.system_quantity_current,
                inv_convert.inv_um_convert
                    (mcce.inventory_item_id, C_MMT_PRECISION,
                     mcce.system_quantity_current, mcce.count_uom_current,
                     msi.primary_uom_code, NULL, NULL)),
        0,
        0,
        decode (subs.asset_inventory,
                C_EXPENSE_SUBINVENTORY, 0,
                mcce.item_unit_cost),
        0,
        NULL,
        NULL,
        C_EXACT_MATCH
      FROM  mtl_cycle_count_entries mcce,
            mtl_cycle_count_items mcci,
            mtl_cycle_count_classes mccc,
            mtl_system_items_b msi,
            mtl_secondary_inventories subs,
            mtl_parameters mp
      WHERE mcce.last_update_date >= l_from_bound_date
        AND mcce.last_update_date < l_to_bound_date
        AND mcce.organization_id = mp.organization_id
        AND mcce.entry_status_code = C_COMPLETED_CCA_ENTRY  -- 5
        AND mcce.adjustment_date IS NULL
        AND mcce.adjustment_quantity = 0
        AND mcce.cycle_count_header_id = mcci.cycle_count_header_id
        AND mcce.inventory_item_id = mcci.inventory_item_id
        AND mcce.organization_id = mccc.organization_id
        AND mcce.cycle_count_header_id = mccc.cycle_count_header_id
        AND mcci.abc_class_id = mccc.abc_class_id
        AND mcce.organization_id = msi.organization_id
        AND mcce.inventory_item_id = msi.inventory_item_id
        AND mcce.organization_id = subs.organization_id
        AND mcce.subinventory = subs.secondary_inventory_name;


        -- Do not commit here. Let the wrapper handle commit operations.

        RETURN;

EXCEPTION

    WHEN OTHERS THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));

        RAISE EXACT_MATCH_EXTR_ERROR;

END extract_exact_matches_incr;


/*  compute_cca_conv_rates_incr

    Compute all the conversion rates for all distinct organization,
    transaction date pairs in the staging table. The date in the fact
    table is already without a timestamp i.e. trunc'ed.

    There are two conversion rates to be computed:
    1. Primary global
    2. Secondary global (if set up)

    The conversion rate work table was truncated during
    the initialization phase.

    Get the currency conversion rates based on the data in
    OPI_DBI_INV_CCA_STG using the fii_currency.get_global_rate_primary
    API for the primary global currency and
    fii_currency.get_global_rate_secondary for the secondary global currency.
    The primary currency API:
    1. finds the conversion rate if one exists.
    2. 'USD' always has a conversion rate of 1 (since it is global currency).
    3. returns -1 if there is no conversion rate on that date.
    4. returns -2 if the currency code is not found.
    5. returns -3 if the transaction_date is prior to 01-JAN-1999,
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

    History:
    Date        Author              Action
    01/15/04    Dinkar Gupta        Defined procedure.
    05/11/04    Dinkar Gupta        Specializing this procedure for incr.
                                    load.
    08/16/04    Dinkar Gupta        Added secondary currency support.
*/

PROCEDURE compute_cca_conv_rates_incr (p_global_curr_code IN VARCHAR2,
                                       p_global_rate_type IN VARCHAR2)

IS

    l_proc_name CONSTANT VARCHAR2 (60) := 'compute_cca_conv_rates_incr';
    l_stmt_id NUMBER;

    -- Cursor to see if any rates are missing. See below for details
    CURSOR invalid_rates_exist_csr IS
        SELECT 1
          FROM opi_dbi_inv_cca_conv
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
    CURSOR invalid_rates_csr (p_pri_sec_curr_same NUMBER) IS
        SELECT DISTINCT
            report_order,
            curr_code,
            rate_type,
            approval_date,
            func_currency_code
          FROM (
                SELECT DISTINCT
                    s_global_curr_code curr_code,
                    s_global_rate_type rate_type,
                    1 report_order, -- ordering global currency first
                    mp.organization_code,
                    decode (conv.conversion_rate,
                            C_EURO_MISSING_AT_START, C_EURO_START_DATE,
                            conv.approval_date) approval_date,
                    conv.func_currency_code
              FROM opi_dbi_inv_cca_conv conv,
                   mtl_parameters mp,
                  (SELECT
                   DISTINCT organization_id, approval_date
                     FROM opi_dbi_inv_cca_stg) to_conv
              WHERE nvl (conv.conversion_rate, -999) < 0 -- null is not fine
                AND mp.organization_id = to_conv.organization_id
                AND conv.approval_date (+) = to_conv.approval_date
                AND conv.organization_id (+) = to_conv.organization_id
            UNION ALL
            SELECT DISTINCT
                    s_secondary_curr_code curr_code,
                    s_secondary_rate_type rate_type,
                    decode (p_pri_sec_curr_same,
                            1, 1,
                            2) report_order, --ordering secondary currency next
                    mp.organization_code,
                    decode (conv.sec_conversion_rate,
                            C_EURO_MISSING_AT_START, C_EURO_START_DATE,
                            conv.approval_date) approval_date,
                    conv.func_currency_code
              FROM opi_dbi_inv_cca_conv conv,
                   mtl_parameters mp,
                  (SELECT
                   DISTINCT organization_id, approval_date
                     FROM opi_dbi_inv_cca_stg) to_conv
              WHERE nvl (conv.sec_conversion_rate, 999) < 0 -- null is fine
                AND mp.organization_id = to_conv.organization_id
                AND conv.approval_date (+) = to_conv.approval_date
                AND conv.organization_id (+) = to_conv.organization_id)
          ORDER BY
                report_order ASC,
                approval_date,
                func_currency_code;


    -- Boolean to ensure all rates have been found.
    l_all_rates_found BOOLEAN;

    -- Boolean to check if the primary and secondary currencies are the
    -- same
    l_pri_sec_curr_same NUMBER;

BEGIN

    -- initialization block
    l_stmt_id := 0;
    l_all_rates_found := true;
    l_pri_sec_curr_same := 0;

    l_stmt_id := 5;
    -- check if the primary and secondary currencies and rate types are
    -- identical.
    IF (s_global_curr_code = nvl (s_secondary_curr_code, '---') AND
        s_global_rate_type = nvl (s_secondary_rate_type, '---') ) THEN
        l_pri_sec_curr_same := 1;
    END IF;


    l_stmt_id := 10;
    -- Get all the distinct organization and date pairs and the
    -- base currency codes for the orgs into the conversion rates
    -- work table.

    -- Use the fii_currency.get_global_rate_primary function to get the
    -- conversion rate given a currency code and a date.
    -- The function returns:
    -- 1 for currency code of 'USD' which is the global currency
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
    INTO opi_dbi_inv_cca_conv (
        organization_id,
        func_currency_code,
        approval_date,
        conversion_rate,
        sec_conversion_rate)
    SELECT
        to_conv.organization_id,
        curr_codes.currency_code,
        to_conv.approval_date,
        decode (curr_codes.currency_code,
                s_global_curr_code, 1,
                fii_currency.get_global_rate_primary (
                                    curr_codes.currency_code,
                                    to_conv.approval_date) ),
        decode (s_secondary_curr_code,
                NULL, NULL,
                curr_codes.currency_code, 1,
                decode (l_pri_sec_curr_same,
                        1, C_PRI_SEC_CURR_SAME_MARKER,
                        fii_currency.get_global_rate_secondary (
                            curr_codes.currency_code,
                            to_conv.approval_date)))
      FROM
        (SELECT
         DISTINCT organization_id, approval_date
           FROM opi_dbi_inv_cca_stg) to_conv,
        (SELECT
         DISTINCT hoi.organization_id, gsob.currency_code
           FROM hr_organization_information hoi,
                gl_sets_of_books gsob
           WHERE hoi.org_information_context  = 'Accounting Information'
             AND hoi.org_information1  = to_char(gsob.set_of_books_id))
        curr_codes
      WHERE curr_codes.organization_id  = to_conv.organization_id;

    l_stmt_id := 15;
    commit;   -- due to insert+append

    l_stmt_id := 20;
    -- if the primary and secondary currency codes are the same, then
    -- update the secondary with the primary
    IF (l_pri_sec_curr_same = 1) THEN

        l_stmt_id := 30;
        UPDATE /*+ parallel (opi_dbi_inv_cca_conv) */ opi_dbi_inv_cca_conv
        SET sec_conversion_rate = conversion_rate;

        -- safe to commit, as before
        l_stmt_id := 40;
        commit;

    END IF;

    -- Check that all rates have been found and are non-negative.
    -- If there is a problem, notify user.
    l_stmt_id := 50;
    OPEN invalid_rates_exist_csr;
    FETCH invalid_rates_exist_csr INTO invalid_rates_exist_rec;
    IF (invalid_rates_exist_csr%FOUND) THEN

        -- print the header out
        BIS_COLLECTION_UTILITIES.writeMissingRateHeader;

        -- all rates not found
        l_all_rates_found := false;

        FOR invalid_rate_rec IN invalid_rates_csr (l_pri_sec_curr_same)
        LOOP

            BIS_COLLECTION_UTILITIES.writeMissingRate(
               invalid_rate_rec.rate_type,
               invalid_rate_rec.func_currency_code,
               invalid_rate_rec.curr_code,
               invalid_rate_rec.approval_date);

        END LOOP;
    END IF;

    l_stmt_id := 55;
    CLOSE invalid_rates_exist_csr;

    -- If all rates not found raise an exception
    l_stmt_id := 60;
    IF (l_all_rates_found = FALSE) THEN
        RAISE MISSING_CONV_RATES;
    END IF;

    RETURN;

EXCEPTION

    WHEN MISSING_CONV_RATES THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (MISSING_CONV_RATES_MESG,
                                             l_proc_name, l_stmt_id));
        RAISE CONV_RATES_ERROR;


    WHEN OTHERS THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));

        RAISE CONV_RATES_ERROR;


END compute_cca_conv_rates_incr;


/* populate_fact_incr

    Move all the staging table data into the fact table. The granularity
    of the data remains the same as the staging table i.e. the
    cycle count entry level.

    The fact joins to the conversion rates table to compute the values
    in both the functional currency and global currency.

    Quantities in the staging table are already the primary UOM.

    Adjustment values are computed using the item_adj_unit_cost which
    is derived from the MTA base_transaction_value. Thus reported
    adjustment values always match MTA.

    System inventory values are computed using the item_unit_cost which
    is the cost of the item at the time when the entry was first entered.
    Thus system inventory value matches that reported in Oracle Forms.
    This is to work around the issues of layered costing in LIFO/FIFO
    orgs (bug 3471888).

    Use the absolute value of system quantity to compute hit/miss because
    the system quantity can be negative. The tolerances however are
    defined as positive numbers. The sign and value of the adjustment
    are otherwise correct to allow for using absolute value of
    system quantity.

    The computation of whether an entry is a hit or a miss is done in
    this step.
    1. If the entry is an exact match, it is a hit.
    2. If the +ve and -ve hit/miss tolerances are null, it is a hit.
    3. If the adjustment is +ve:
        - if the +ve tolerance is null, it is a hit.
        - else (adjustment_qty/system_inventory_qty) <=
            (+ve tolerance)/100, it is a hit.
    4. If the adjustment is +ve:
        - if the +ve tolerance is null, it is a hit.
        - else (adjustment_qty/system_inventory_qty) <=
            (+ve tolerance)/100, it is a hit.
        This check handles the divide by 0 case.
    5. If the adjustment is -ve:
        - if the -ve tolerance is null, it is a hit.
        - else (adjustment_qty/system_inventory_qty) <=
            (-ve tolerance)/100, it is a hit. [since both the negative
            adjustment quantities and tolerances are reported as
            positive numbers.]
    6. Any other case is a miss.

    The only thing to be careful of in this step is the condition on the
    merge. In case the merge condition needs to insert, there is no
    complication. Insert as in the initial load.
    In case the merge condition needs to update, the type of entry matters.
    For exact matches, the entry can be simply updated.
    For adjustments, the entry needs to be appended because of the case
    where serial adjustments can create multiple MMT transactions. In that
    case, it is possible for one of the transactions to be uncosted. In
    next run, these will get picked up and need to be appended to the
    previous values. The hit/miss calculations will have to be done
    based on the new appended values too.

    Do not commit anything in this step. Let the wrapper handle that.

    History:
    Date        Author              Action
    01/19/04    Dinkar Gupta        Defined procedure.
    02/09/04    Dinkar Gupta        Used absolute value of
                                    system inventory quantity
                                    to compute hit/miss.
    03/10/04    Dinkar Gupta        Used item_cost from MCCE for system
                                    inventory value and cost from MTA
                                    for adjustment value to account for
                                    for LIFO/FIFO org layered costing.
    08/17/04    Dinkar Gupta        Added secondary currency support
*/

PROCEDURE populate_fact_incr
IS

    l_proc_name CONSTANT VARCHAR2(40) := 'populate_fact_incr';
    l_stmt_id NUMBER;

BEGIN

    -- initialization block
    l_stmt_id := 0;

    l_stmt_id := 10;
    -- Merge data into the fact table. For an explanation of the logic
    -- see the procedure header.
    MERGE INTO opi_dbi_inv_cca_f base
    USING
    (SELECT
        stg.organization_id,
        stg.inventory_item_id,
        stg.cycle_count_header_id,
        stg.abc_class_id,
        stg.subinventory_code,
        stg.cycle_count_entry_id,
        stg.source,
        stg.approval_date,
        stg.uom_code,
        stg.system_inventory_qty,
        (stg.system_inventory_qty * stg.item_unit_cost)
            system_inventory_val_b,
        (stg.system_inventory_qty * stg.item_unit_cost *
            conv.conversion_rate) system_inventory_val_g,
        (stg.system_inventory_qty * stg.item_unit_cost *
            conv.sec_conversion_rate) system_inventory_val_sg,
        stg.positive_adjustment_qty,
        (stg.positive_adjustment_qty * stg.item_adj_unit_cost)
            positive_adjustment_val_b,
        (stg.positive_adjustment_qty * stg.item_adj_unit_cost *
            conv.conversion_rate) positive_adjustment_val_g,
        (stg.positive_adjustment_qty * stg.item_adj_unit_cost *
            conv.sec_conversion_rate) positive_adjustment_val_sg,
        stg.negative_adjustment_qty,
        (stg.negative_adjustment_qty * stg.item_adj_unit_cost)
            negative_adjustment_val_b,
        (stg.negative_adjustment_qty * stg.item_adj_unit_cost *
            conv.conversion_rate) negative_adjustment_val_g,
        (stg.negative_adjustment_qty * stg.item_adj_unit_cost *
            conv.sec_conversion_rate) negative_adjustment_val_sg,
        conv.conversion_rate,
        conv.sec_conversion_rate,
        stg.item_unit_cost,
        CASE
            WHEN stg.exact_match = C_EXACT_MATCH THEN
                C_HIT
            WHEN stg.hit_miss_pos IS NULL AND stg.hit_miss_neg IS NULL THEN
                C_HIT
            WHEN stg.hit_miss_pos IS NULL AND
                 stg.positive_adjustment_qty > 0 THEN
                C_HIT
            WHEN stg.hit_miss_neg IS NULL AND
                 stg.negative_adjustment_qty > 0 THEN
                C_HIT
            WHEN stg.system_inventory_qty = 0 THEN
                CASE
                    WHEN stg.positive_adjustment_qty = 0 AND
                         stg.negative_adjustment_qty = 0 THEN
                        C_HIT
                    ELSE
                        C_MISS
                END
            WHEN stg.positive_adjustment_qty > 0 AND
                 (stg.positive_adjustment_qty/
                  abs (stg.system_inventory_qty)) <=
                 (stg.hit_miss_pos/100) THEN
                C_HIT
            WHEN stg.negative_adjustment_qty > 0 AND
                 (stg.negative_adjustment_qty/
                  abs (stg.system_inventory_qty)) <=
                 (stg.hit_miss_neg/100) THEN
                C_HIT
            ELSE
                C_MISS
            END hit_or_miss,
        stg.exact_match,
        stg.hit_miss_pos,
        stg.hit_miss_neg,
        sysdate last_update_date,
        s_user_id last_updated_by,
        s_login_id last_update_login,
        sysdate creation_date,
        s_user_id created_by,
        s_request_id request_id,
        s_program_application_id program_application_id,
        s_program_id program_id,
        sysdate program_update_date
      FROM  opi_dbi_inv_cca_stg stg,
            opi_dbi_inv_cca_conv conv
      WHERE stg.organization_id = conv.organization_id
        AND stg.approval_date = conv.approval_date) new
    ON (
            base.cycle_count_entry_id = new.cycle_count_entry_id
        AND base.subinventory_code = new.subinventory_code
        AND base.source = new.source)
    WHEN MATCHED THEN UPDATE
    SET
        system_inventory_qty = new.system_inventory_qty,
        system_inventory_val_b = new.system_inventory_val_b,
        system_inventory_val_g = new.system_inventory_val_g,
        system_inventory_val_sg = new.system_inventory_val_sg,
        positive_adjustment_qty =
            CASE WHEN new.exact_match = C_EXACT_MATCH OR
                      new.source = C_OPM_SOURCE THEN
                    new.positive_adjustment_qty
                 ELSE new.positive_adjustment_qty +
                      base.positive_adjustment_qty
            END,
        positive_adjustment_val_b =
            CASE WHEN new.exact_match = C_EXACT_MATCH OR
                      new.source = C_OPM_SOURCE THEN
                    new.positive_adjustment_val_b
                 ELSE new.positive_adjustment_val_b +
                      base.positive_adjustment_val_b
            END,
        positive_adjustment_val_g =
            CASE WHEN new.exact_match = C_EXACT_MATCH OR
                      new.source = C_OPM_SOURCE THEN
                    new.positive_adjustment_val_g
                 ELSE new.positive_adjustment_val_g +
                      base.positive_adjustment_val_g
            END,
        positive_adjustment_val_sg =
            CASE WHEN new.exact_match = C_EXACT_MATCH OR
                      new.source = C_OPM_SOURCE THEN
                    new.positive_adjustment_val_sg
                 ELSE new.positive_adjustment_val_sg +
                      base.positive_adjustment_val_sg
            END,
        negative_adjustment_qty =
            CASE WHEN new.exact_match = C_EXACT_MATCH OR
                      new.source = C_OPM_SOURCE THEN
                    new.negative_adjustment_qty
                 ELSE new.negative_adjustment_qty +
                      base.negative_adjustment_qty
            END,
        negative_adjustment_val_b =
            CASE WHEN new.exact_match = C_EXACT_MATCH OR
                      new.source = C_OPM_SOURCE THEN
                    new.negative_adjustment_val_b
                 ELSE new.negative_adjustment_val_b +
                      base.negative_adjustment_val_b
            END,
        negative_adjustment_val_g =
            CASE WHEN new.exact_match = C_EXACT_MATCH OR
                      new.source = C_OPM_SOURCE THEN
                    new.negative_adjustment_val_g
                 ELSE new.negative_adjustment_val_g +
                      base.negative_adjustment_val_g
            END,
        negative_adjustment_val_sg =
            CASE WHEN new.exact_match = C_EXACT_MATCH OR
                      new.source = C_OPM_SOURCE THEN
                    new.negative_adjustment_val_sg
                 ELSE new.negative_adjustment_val_sg +
                      base.negative_adjustment_val_sg
            END,
        hit_or_miss =
        CASE
            WHEN new.source = C_OPM_SOURCE THEN
                new.hit_or_miss
            WHEN new.exact_match = C_EXACT_MATCH THEN
                C_HIT
            WHEN new.hit_miss_pos IS NULL AND new.hit_miss_neg IS NULL THEN
                C_HIT
            WHEN new.source = C_OPI_SOURCE THEN
                CASE
                    WHEN new.hit_miss_pos IS NULL AND
                         base.positive_adjustment_qty +
                         new.positive_adjustment_qty > 0 THEN
                        C_HIT
                    WHEN new.hit_miss_neg IS NULL AND
                         base.negative_adjustment_qty +
                         new.negative_adjustment_qty > 0 THEN
                        C_HIT
                    WHEN new.system_inventory_qty +
                         base.system_inventory_qty = 0 THEN
                        CASE
                            WHEN new.positive_adjustment_qty +
                                 base.positive_adjustment_qty = 0 AND
                                 new.negative_adjustment_qty +
                                 base.negative_adjustment_qty = 0 THEN
                                C_HIT
                            ELSE
                                C_MISS
                        END
                    WHEN new.positive_adjustment_qty > 0 AND
                         ((new.positive_adjustment_qty +
                           base.positive_adjustment_qty)/
                           abs (new.system_inventory_qty)) <=
                         (new.hit_miss_pos/100) THEN
                        C_HIT
                    WHEN new.negative_adjustment_qty > 0 AND
                         ((new.negative_adjustment_qty +
                           base.negative_adjustment_qty)/
                           abs (new.system_inventory_qty)) <=
                         (new.hit_miss_neg/100) THEN
                        C_HIT
                    ELSE
                        C_MISS
                END
            ELSE
                C_MISS  -- should never get here!!
        END,
        exact_match = new.exact_match,
        last_update_date = new.last_update_date,
        last_updated_by = new.last_updated_by,
        last_update_login = new.last_update_login,
        creation_date = new.creation_date,
        created_by = new.created_by,
        request_id = new.request_id,
        program_application_id = new.program_application_id,
        program_id = new.program_id,
        program_update_date = new.program_update_date
    WHEN NOT MATCHED THEN INSERT (
        organization_id,
        inventory_item_id,
        cycle_count_header_id,
        abc_class_id,
        subinventory_code,
        cycle_count_entry_id,
        source,
        approval_date,
        uom_code,
        system_inventory_qty,
        system_inventory_val_b,
        system_inventory_val_g,
        system_inventory_val_sg,
        positive_adjustment_qty,
        positive_adjustment_val_b,
        positive_adjustment_val_g,
        positive_adjustment_val_sg,
        negative_adjustment_qty,
        negative_adjustment_val_b,
        negative_adjustment_val_g,
        negative_adjustment_val_sg,
        conversion_rate,
        sec_conversion_rate,
        item_unit_cost,
        hit_or_miss,
        exact_match,
        last_update_date,
        last_updated_by,
        last_update_login,
        creation_date,
        created_by,
        request_id,
        program_application_id,
        program_id,
        program_update_date)
    VALUES (
        new.organization_id,
        new.inventory_item_id,
        new.cycle_count_header_id,
        new.abc_class_id,
        new.subinventory_code,
        new.cycle_count_entry_id,
        new.source,
        new.approval_date,
        new.uom_code,
        new.system_inventory_qty,
        new.system_inventory_val_b,
        new.system_inventory_val_g,
        new.system_inventory_val_sg,
        new.positive_adjustment_qty,
        new.positive_adjustment_val_b,
        new.positive_adjustment_val_g,
        new.positive_adjustment_val_sg,
        new.negative_adjustment_qty,
        new.negative_adjustment_val_b,
        new.negative_adjustment_val_g,
        new.negative_adjustment_val_sg,
        new.conversion_rate,
        new.sec_conversion_rate,
        new.item_unit_cost,
        new.hit_or_miss,
        new.exact_match,
        new.last_update_date,
        new.last_updated_by,
        new.last_update_login,
        new.creation_date,
        new.created_by,
        new.request_id,
        new.program_application_id,
        new.program_id,
        new.program_update_date);


    -- Do not commit here. Let the wrapper handle that.

    RETURN;

EXCEPTION

    WHEN OTHERS THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));

        RAISE FACT_MERGE_ERROR;

END populate_fact_incr;


END opi_dbi_inv_cca_pkg;

/
