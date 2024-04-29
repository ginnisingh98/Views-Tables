--------------------------------------------------------
--  DDL for Package Body OPI_DBI_WMS_STORAGE_UTZ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_WMS_STORAGE_UTZ_PKG" AS
/*$Header: OPIDEWSTORB.pls 120.1 2006/02/14 01:45:16 achandak noship $ */


/**************************************************
* File scope variables
**************************************************/

-- Package level variables for session info-
-- including schema name for truncating and
-- collecting stats. Initialized in check_global_setup.
s_opi_schema      VARCHAR2(30);
s_status          VARCHAR2(30);
s_industry        VARCHAR2(30);

-- Package level variables for the standard who columns
s_user_id                   NUMBER;
s_login_id                  NUMBER;
s_program_id                NUMBER;
s_program_login_id          NUMBER;
s_program_application_id    NUMBER;
s_request_id                NUMBER;

-- Weight and Volume reporting UOMs
s_wt_rep_uom_code VARCHAR2 (3);
s_vol_rep_uom_code VARCHAR2 (3);

/**************************************************
* Common Procedures (to locator capacity and item storage computations)
*
* File scope functions (not in spec)
**************************************************/

-- Global variable setup and verification
PROCEDURE global_setup;

-- Print out error message in a consistent manner
FUNCTION err_mesg (p_mesg IN VARCHAR2,
                   p_proc_name IN VARCHAR2,
                   p_stmt_id IN NUMBER)
    RETURN VARCHAR2;

-- Print stage done message
PROCEDURE print_stage_done_mesg (p_proc_name IN VARCHAR2,
                                 p_stmt_id IN NUMBER);

-- Update the log table.
PROCEDURE update_log (p_run_date IN DATE);

-- Check for missing rates
FUNCTION check_missing_rates (p_table_name IN VARCHAR2)
    RETURN BOOLEAN;

-- Transfer fact table records into the staging table.
PROCEDURE transfer_fact_to_staging;


/**************************************************
* Initial load procedures
**************************************************/
-- Setup/clean up relevant tables
PROCEDURE setup_tables_init;

-- Compute the conversion rates for weight/volume for
-- all items for the initial load
PROCEDURE compute_conv_rates_init (p_wt_rep_uom_code IN VARCHAR2,
                                   p_vol_rep_uom_code IN VARCHAR2);

/**************************************************
* Incremental load procedures
**************************************************/
-- Setup/clean up relevant tables
PROCEDURE setup_tables_incr;

-- Compute the conversion rates for weight/volume for
-- all items for the incremental runs
PROCEDURE compute_conv_rates_incr (p_wt_rep_uom_code IN VARCHAR2,
                                   p_vol_rep_uom_code IN VARCHAR2);


/**************************************************
 * Common Procedures Definitions
 **************************************************/

/*  global_setup

    Performs global setup of file scope variables and does any checking
    needed for global DBI setups.

    Parameters: None

    History:
    Date        Author              Action
    12/13/04    Dinkar Gupta        Defined function.

*/
PROCEDURE global_setup
IS
    l_proc_name CONSTANT VARCHAR2 (40) := 'global_setup';
    l_stmt_id NUMBER;


    -- Cursor to get the reporting UOM for a certain measure code.
    -- Can be null if not set up.
    CURSOR get_rep_uom_csr (p_measure_code VARCHAR2)
    IS
    SELECT rep_uom_code
      FROM opi_dbi_rep_uoms
      WHERE measure_code = p_measure_code
        AND rep_uom_code IS NOT NULL;

BEGIN

    -- Initialization block
    l_stmt_id := 0;

    l_stmt_id := 10;
    -- Obtain the OPI schema name to allow truncation of various tables
    -- get session parameters
    IF (NOT (fnd_installation.get_app_info('OPI', s_status, s_industry,
                                           s_opi_schema))) THEN
        RAISE SCHEMA_INFO_NOT_FOUND;
    END IF;

    l_stmt_id := 20;
    -- Package level variables for the user logged in
    s_user_id := nvl(fnd_global.user_id, -1);
    s_login_id := nvl(fnd_global.login_id, -1);
    s_program_id := nvl (fnd_global.conc_program_id, -1);
    s_program_login_id := nvl (fnd_global.conc_login_id, -1);
    s_program_application_id := nvl (fnd_global.prog_appl_id,  -1);
    s_request_id := nvl (fnd_global.conc_request_id, -1);

    l_stmt_id := 30;
    -- Get the weight reporting UOM.
    OPEN get_rep_uom_csr (C_WT_MEASURE_CODE);
    FETCH get_rep_uom_csr INTO s_wt_rep_uom_code;
    IF (get_rep_uom_csr%NOTFOUND) THEN
        s_wt_rep_uom_code := NULL;
    END IF;

    CLOSE get_rep_uom_csr;

    l_stmt_id := 40;
    -- Get the volume reporting UOM.
    OPEN get_rep_uom_csr (C_VOL_MEASURE_CODE);
    FETCH get_rep_uom_csr INTO s_vol_rep_uom_code;
    IF (get_rep_uom_csr%NOTFOUND) THEN
        s_vol_rep_uom_code := NULL;
    END IF;

    CLOSE get_rep_uom_csr;

    return;

EXCEPTION

    WHEN SCHEMA_INFO_NOT_FOUND THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (SCHEMA_INFO_NOT_FOUND_MESG,
                                             l_proc_name, l_stmt_id));
        RAISE GLOBAL_SETUP_MISSING;


    WHEN OTHERS THEN
        rollback;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));
        RAISE GLOBAL_SETUP_MISSING;

END global_setup;



/*  err_mesg

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
    12/13/04    Dinkar Gupta        Defined function.
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

/*  print_stage_done_mesg

    Print a message of 'Done' for whatever procedure/statement called.

    Parameters:
    p_proc_name - name of procedure that should be printed in the message
    p_stmt_id - step in procedure at which error occurred

    History:
    Date        Author              Action
    12/13/04    Dinkar Gupta        Defined function.
*/

PROCEDURE print_stage_done_mesg (p_proc_name IN VARCHAR2,
                                 p_stmt_id IN NUMBER)
IS

    l_proc_name CONSTANT VARCHAR2 (60) := 'print_stage_done_mesg';
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
                                   to_char (p_stmt_id) || ': ' || 'Done.'),
                                   1, C_ERRBUF_SIZE);

    BIS_COLLECTION_UTILITIES.PUT_LINE (l_formatted_message);

    return;

EXCEPTION

    WHEN OTHERS THEN
        -- the exception happened in the print function
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));

        RAISE; -- on to wrapper

END print_stage_done_mesg;

/*  update_log

    Update the log table for the reporting UOM conversion rates ETL
    with the run date provided as a parameter.

    Parameters:
    1. p_run_date - run date of the program, provided by the wrapper. This
                    is the start time of the program, which can be used
                    as a marker between incremental runs.

    No commits done here. Calling function coordinates commit.

    History:
    Date        Author              Action
    12/13/04    Dinkar Gupta        Wrote Function.

*/
PROCEDURE update_log (p_run_date IN DATE)
IS

    l_proc_name CONSTANT VARCHAR2 (40) := 'update_log';
    l_stmt_id NUMBER;

BEGIN

    -- Initialization block
    l_stmt_id := 10;

    -- Update the row for this ETL. It is assumed that there is only
    -- one such row.
    UPDATE opi_dbi_conc_prog_run_log
    SET last_run_date = p_run_date,
        last_update_date = sysdate,
        last_updated_by = s_user_id,
        last_update_login = s_login_id,
        request_id = s_request_id,
        program_application_id = s_program_application_id,
        program_id = s_program_id,
        program_login_id = s_program_login_id
      WHERE etl_type = C_ETL_TYPE;

    return;

EXCEPTION

    WHEN OTHERS THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));
        RAISE LOG_UPDATE_FAILED;

END update_log;

/*  check_missing_rates

    Check if there are any rates that are missing.

    Report a summary of the rates missing, and whether they are
    inter or intra class.

    Parameters:
        p_table_name - opi_dbi_wms_stor_item_conv_f for fact table,
                       opi_dbi_wms_stor_item_conv_stg for staging table.

    Return:
    TRUE - if rates are missing.
    FALSE - if no rates are missing.

    No commits done here. Calling function coordinates commit.

    History:
    Date        Author              Action
    12/20/04    Dinkar Gupta        Wrote Function.

*/
FUNCTION check_missing_rates (p_table_name IN VARCHAR2)
    RETURN BOOLEAN
IS

    l_proc_name CONSTANT VARCHAR2 (40) := 'check_missing_rates';
    l_stmt_id NUMBER;

    -- Check if missing rates were found
    l_missing_rates BOOLEAN;

    -- Print the header only once.
    l_header_printed BOOLEAN;

    -- Record type to fetch missing rates records into
    TYPE err_rec_type IS RECORD (uom_code VARCHAR2 (3));
    l_err_rec err_rec_type;

    -- Missing rates cursors
    TYPE err_curr_type IS REF CURSOR;
    wt_missing_rates_csr err_curr_type;
    vol_missing_rates_csr err_curr_type;

BEGIN

    -- Initialization block
    l_stmt_id := 0;
    l_missing_rates := FALSE;   -- nothing missing so far
    l_header_printed := FALSE;

    -- Open the two cursors for the different conversion errors.
    -- Ignore NULL rates - only care about errors.
    l_stmt_id := 10;
    OPEN wt_missing_rates_csr FOR
    'SELECT DISTINCT unit_weight_uom_code
      FROM ' || p_table_name || '
      WHERE weight_conv_rate < 0';

    l_stmt_id := 20;
    OPEN vol_missing_rates_csr FOR
    'SELECT DISTINCT unit_volume_uom_code
      FROM ' || p_table_name || '
      WHERE volume_conv_rate < 0';

    -- Leverage a lot of the basic functionality in the reporting UOM package.

    -- Print the header for weight missing rates.
    l_header_printed := FALSE;

    -- Report the weight missing rates first.
    l_stmt_id := 30;
    FETCH wt_missing_rates_csr INTO l_err_rec;
    WHILE wt_missing_rates_csr%FOUND
    LOOP

        -- Print the header once
        l_stmt_id := 20;
        IF (l_header_printed = FALSE) THEN

            OPI_DBI_REP_UOM_PKG.err_msg_header_spec ('WT', 'ITEM');
            l_header_printed := TRUE;

        END IF;

        -- Print the missing rates.
        l_stmt_id := 30;
        OPI_DBI_REP_UOM_PKG.err_msg_missing_uoms (
            l_err_rec.uom_code, s_wt_rep_uom_code);

        -- Found at least one bad rate
        l_stmt_id := 40;
        l_missing_rates := TRUE;

        FETCH wt_missing_rates_csr INTO l_err_rec;

    END LOOP;

    -- Footer message.
    IF (l_header_printed = TRUE) THEN
        OPI_DBI_REP_UOM_PKG.err_msg_footer;
    END IF;

    -- Print the header for volume missing rates again.
    l_header_printed := FALSE;

    -- Report volume missing rates.
    l_stmt_id := 40;
    FETCH vol_missing_rates_csr INTO l_err_rec;
    WHILE vol_missing_rates_csr%FOUND
    LOOP

        -- Print the header once
        l_stmt_id := 20;
        IF (l_header_printed = FALSE) THEN

            OPI_DBI_REP_UOM_PKG.err_msg_header_spec ('VOL', 'ITEM');
            l_header_printed := TRUE;

        END IF;

        -- Print the missing rates.
        l_stmt_id := 30;
        OPI_DBI_REP_UOM_PKG.err_msg_missing_uoms (
            l_err_rec.uom_code, s_vol_rep_uom_code);

        -- Found at least one bad rate
        l_stmt_id := 40;
        l_missing_rates := TRUE;

        FETCH vol_missing_rates_csr INTO l_err_rec;

    END LOOP;

    -- Footer message.
    IF (l_header_printed = TRUE) THEN
        OPI_DBI_REP_UOM_PKG.err_msg_footer;
    END IF;

    -- Finally!
    return l_missing_rates;

EXCEPTION

    WHEN OTHERS THEN
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));
        RAISE CONV_RATES_CHECK_FAILED;

END check_missing_rates;

/*  transfer_fact_to_staging

    Transfer all fact table records to the staging table. Used in the
    initial load in case of errors, because the initial load directly
    loads the fact table. However in case of errors, the fact
    will be truncated and the data will be left in the staging table
    for detailed reporting.

    No commits done here. Calling function coordinates commit.

    History:
    Date        Author              Action
    11/01/05    Dinkar Gupta        Wrote Function.

*/
PROCEDURE transfer_fact_to_staging

IS

    l_proc_name CONSTANT VARCHAR2 (40) := 'check_missing_rates';
    l_stmt_id NUMBER;

BEGIN

    -- Initialization block
    l_stmt_id := 0;

    -- Move all data from the fact to the staging table.
    -- Not responsible for truncating staging table.
    l_stmt_id := 10;
    INSERT INTO opi_dbi_wms_stor_item_conv_stg (
        organization_id,
        inventory_item_id,
        unit_weight_uom_code,
        weight_conv_rate,
        weight_conv_rate_type,
        unit_volume_uom_code,
        volume_conv_rate,
        volume_conv_rate_type
    )
    SELECT
        organization_id,
        inventory_item_id,
        unit_weight_uom_code,
        weight_conv_rate,
        weight_conv_rate_type,
        unit_volume_uom_code,
        volume_conv_rate,
        volume_conv_rate_type
      FROM  opi_dbi_wms_stor_item_conv_f;

    return;

EXCEPTION

    WHEN OTHERS THEN
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));
        RAISE TRX_STG_TO_FACT_FAILED;


END transfer_fact_to_staging;



/**************************************************
 * Initial Load functions
 **************************************************/

/*  setup_tables_init

    Truncate the following tables:
    1. opi_dbi_wms_stor_item_conv_f
    2. opi_dbi_wms_stor_item_conv_stg

    Clean up the run log table, OPI_DBI_CONC_PROG_RUN_LOG
    and seed in a new row.


    History:
    Date        Author              Action
    12/13/04    Dinkar Gupta        Wrote Function.


*/
PROCEDURE setup_tables_init
IS

    l_proc_name CONSTANT VARCHAR2 (40) := 'setup_tables_init';
    l_stmt_id NUMBER;

BEGIN

    -- Initialization block
    l_stmt_id := 0;

    l_stmt_id := 10;
    -- Truncate the fact table
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
                       'MLOG$_OPI_DBI_WMS_STOR_ITE');

    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
                       'OPI_DBI_WMS_STOR_ITEM_CONV_F');

    l_stmt_id := 20;
    -- Truncate the staging table
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
                       'OPI_DBI_WMS_STOR_ITEM_CONV_STG');


    l_stmt_id := 30;
    -- Delete all rows from the log table for this ETL.
    DELETE
      FROM opi_dbi_conc_prog_run_log
      WHERE etl_type = C_ETL_TYPE;

    l_stmt_id := 40;
    -- Record the delete
    commit;

    l_stmt_id := 50;
    -- Create a new row for the ETL in the run log, with a last
    -- run date set to a very log time ago.
    INSERT INTO opi_dbi_conc_prog_run_log (
        etl_type,
        last_run_date,
        created_by,
        creation_date,
        last_update_date,
        last_updated_by,
        last_update_login,
        program_id,
        program_login_id,
        program_application_id,
        request_id
    )
    VALUES (C_ETL_TYPE,
            C_START_RUN_DATE,
            s_user_id,
            sysdate,
            sysdate,
            s_user_id,
            s_login_id,
            s_program_id,
            s_program_login_id,
            s_program_application_id,
            s_request_id);

    l_stmt_id := 60;
    -- Record this new row.
    commit;

    l_stmt_id := 70;
    -- Alter the Session variables for good Performance
    execute immediate 'alter session set hash_area_size=100000000';
    execute immediate 'alter session set sort_area_size=100000000';

    return;

EXCEPTION

    WHEN OTHERS THEN
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));
        RAISE TABLE_SETUP_FAILED;

END setup_tables_init;


/*  compute_conv_rates_init

    Extract the item weight/volume conversions to the corresponding
    reporting UOMS. The item information is stored in the inventory value
    fact. Only interested in the items of WMS enabled discrete organizations.
    (This set of items is generally smaller than all the items for all
    organizations).

    If the conversion rate for the weight/volume to the reporting UOMs
    is not defined, store negative error codes.



    Note also that one or both of the reporting units for weight
    and volume can be NULL. That is not an error condition.

    No committing of data here. The calling function handles that.

    Parameters:
    1. p_wt_rep_uom_code - Weight reporting UOM code
    2. p_vol_rep_uom_code - Volume reporting UOM code

    History:
    Date        Author              Action
    12/13/04    Dinkar Gupta        Wrote Function.

*/
PROCEDURE compute_conv_rates_init (p_wt_rep_uom_code IN VARCHAR2,
                                   p_vol_rep_uom_code IN VARCHAR2)

IS
    l_proc_name CONSTANT VARCHAR2 (40) := 'compute_conv_rates_init';
    l_stmt_id NUMBER;

    -- local copy of reporting UOMs
    l_wt_rep_uom_code VARCHAR2 (3);
    l_vol_rep_uom_code VARCHAR2 (3);

BEGIN

    -- initialization block
    l_stmt_id := 0;
    l_wt_rep_uom_code := NULL;
    l_vol_rep_uom_code := NULL;

    l_stmt_id := 10;
    -- If both reporting UOMs are undefined, return. Wrapper routine
    -- should ensure this doesn't happen, but check just in case.
    IF (p_wt_rep_uom_code IS NULL AND
        p_vol_rep_uom_code IS NULL) THEN
        RAISE NO_REP_UOMS_DEFINED;
    END IF;

    l_stmt_id := 20;
    -- Set the reporting UOM's to the dummy code, to avoid handling
    -- the condition that one of them can be NULL in the SQL below.
    l_wt_rep_uom_code := nvl (p_wt_rep_uom_code, C_DUMMY_UOM_CODE);
    l_vol_rep_uom_code := nvl (p_vol_rep_uom_code, C_DUMMY_UOM_CODE);

    l_stmt_id := 30;
    -- Extract the weight/volume conversion rates for all
    -- distinct item/org pairs that belong to WMS enabled discrete
    -- manufacturing organizations and that are already present in the
    -- inventory value fact, OPI_DBI_INV_VALUE_F. Need to specifically
    -- filter out process organizations here, because we only
    -- join to the inventory value fact which has data from both, discrete
    -- and process organizations.
    --
    -- Collecting 2 measures:
    -- 1. Conversion rate from the item weight UOM code to the weight
    --    reporting UOM code.
    -- 2. Conversion rate from the item volume UOM code to the volume
    --    reporting UOM code.
    --
    -- The item setup form guarantees that a UOM be specified for the
    -- item weight/volume before a value is specified. So no need to
    -- worry about missing UOMs and specified values.
    --
    -- All possible conversions to the reporting UOMs are stored in
    -- the standard conversion rates table, OPI_DBI_REP_UOM_STD_CONV_F.
    -- The extraction program will join twice to this table, once
    -- for weight conversions and once for volume conversions.
    -- Since certain rows may not join to the conversion fact for
    -- one of the measures, use outer joins.
    --
    -- The following pathalogical scenarios are possible:
    --
    -- Missing Setups:
    -- 1. Item Weight setup is missing.
    -- 2. Item Volume setup is missing.
    -- Either or both of the above are acceptable. In case of no setup,
    -- report NULL for the corresponding measure.
    --
    -- Missing conversion rates:
    -- 1. Item weight cannot be converted into the reporting weight UOM.
    -- 2. Item volume cannot be converted into the reporting volume UOM.
    -- This will be recorded as a negative number, given the negative
    -- error codes for missing rates. Store that for the moment, and
    -- report errors later. If no conversion rate is found, record a
    -- negative number.
    --
    -- Missing Reporting UOMs:
    -- 1. The Weight Reporting UOM can be missing.
    -- 2. The Volume Reporting UOM can be missing.
    -- Since both won't be missing, these are acceptable scenarios i.e.
    -- ones where customers do not care about one of the measures. Simply
    -- set the conversion rate for that measure to NULL everywhere.
    --
    -- Weight/Volume UOM can be the same:
    -- 1. The item's weight capacity and volume UOM can be the
    --    same. This is acceptable. However, suppose this UOM is Kg, that
    --    needs to be converted to weight reporting UOM (lbs) and volume
    --    reporting UOM M3.
    --    Say the conversion rates table has a rate from Kg --> lbs, but
    --    nothing from Kg --> M3. To avoid filtering out rows for such
    --    items and instead reporting errors for them, this SQL has
    --    to be written with an inline view which contains all the
    --    from and reporting UOMs, and an outer SQL that purely outer
    --    joins to the standard conversion rates tables based on these
    --    from and reporting UOMs.
    --
    INSERT /*+ append parallel (opi_dbi_wms_stor_item_conv_f) */
    INTO opi_dbi_wms_stor_item_conv_f (
        organization_id,
        inventory_item_id,
        unit_weight_uom_code,
        weight_conv_rate,
        weight_conv_rate_type,
        unit_volume_uom_code,
        volume_conv_rate,
        volume_conv_rate_type,
        creation_date,
        last_update_date,
        created_by,
        last_updated_by,
        last_update_login,
        program_id,
        program_login_id,
        program_application_id,
        request_id)
    SELECT /*+ use_hash (items, wt_conv, vol_conv)
               parallel (items) parallel (wt_conv) parallel (vol_conv) */
        items.organization_id,
        items.inventory_item_id,
        decode (items.weight_uom_code,
                C_DUMMY_UOM_CODE, NULL,
                items.weight_uom_code) unit_weight_uom_code,
        CASE    -- order of conditions matters
            WHEN items.unit_weight IS NULL THEN
                -- Weight not setup. Acceptable.
                NULL
            WHEN items.wt_rep_uom_code = C_DUMMY_UOM_CODE THEN
                -- Weight reporting UOM not set up. Acceptable
                NULL
            WHEN wt_conv.conversion_rate IS NULL THEN
                -- Row created from pure outer join i.e. it is a valid
                -- combination with non-null UOMs and there is
                -- no conv. rate for this combination.
                -- From_uom_code and rep_uom_code
                -- will be null in the wt_conv table for this row also.
                C_CONV_NOT_SETUP
            WHEN wt_conv.conversion_rate < 0 THEN
                -- Error found in conversion rates table.
                C_CONV_NOT_SETUP
            WHEN wt_conv.conversion_rate >= 0 THEN
                -- Valid conv. rate found.
                -- Note: allowing conv. rate = 0.
                wt_conv.conversion_rate
            ELSE
                -- Why will we get here? Should really never.
                C_CONV_NOT_SETUP
        END weight_conv_rate,
        wt_conv.conversion_type weight_conv_rate_type,
        decode (items.volume_uom_code,
                C_DUMMY_UOM_CODE, NULL,
                items.volume_uom_code) unit_volume_uom_code,
        CASE    -- order of conditions matters
            WHEN items.unit_volume IS NULL THEN
                -- Volume not setup. Acceptable.
                NULL
            WHEN items.vol_rep_uom_code = C_DUMMY_UOM_CODE THEN
                -- Volume reporting UOM not set up. Acceptable
                NULL
            WHEN vol_conv.conversion_rate IS NULL THEN
                -- Row created from pure outer join i.e. it is a valid
                -- combination with non-null UOMs and there is
                -- no conv. rate for this combination.
                -- From_uom_code and rep_uom_code
                -- will be null in the vol_conv table for this row also.
                C_CONV_NOT_SETUP
            WHEN vol_conv.conversion_rate < 0 THEN
                -- Error found in conversion rates table.
                C_CONV_NOT_SETUP
            WHEN vol_conv.conversion_rate >= 0 THEN
                -- Valid conv. rate found.
                -- Note: allowing conv. rate = 0.
                vol_conv.conversion_rate
            ELSE
                -- Why will we get here? Should really never.
                C_CONV_NOT_SETUP
        END volume_conv_rate,
        vol_conv.conversion_type volume_conv_rate_type,
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
        (SELECT /*+ parallel (conv_items) parallel (item_attr)
                    use_hash (conv_items, item_attr) */
         DISTINCT
            conv_items.organization_id,
            conv_items.inventory_item_id,
            item_attr.primary_uom_code,
            nvl (item_attr.weight_uom_code, C_DUMMY_UOM_CODE) weight_uom_code,
            l_wt_rep_uom_code wt_rep_uom_code,
            nvl (item_attr.volume_uom_code, C_DUMMY_UOM_CODE) volume_uom_code,
            l_vol_rep_uom_code vol_rep_uom_code,
            item_attr.unit_weight,
            item_attr.unit_volume
          FROM
            (SELECT /*+ parallel (fact) parallel (mp)
                        use_hash (fact, mp) */
             DISTINCT
                fact.organization_id,
                fact.inventory_item_id
              FROM  opi_dbi_inv_value_f fact,
                    mtl_parameters mp
              WHERE mp.wms_enabled_flag = 'Y'
                AND fact.organization_id = mp.organization_id
                AND fact.source = C_DISCRETE_ORGS
            ) conv_items,
            eni_oltp_item_star item_attr
          WHERE conv_items.organization_id = item_attr.organization_id
            AND conv_items.inventory_item_id = item_attr.inventory_item_id
        ) items,
        opi_dbi_rep_uom_std_conv_f wt_conv,
        opi_dbi_rep_uom_std_conv_f vol_conv
      WHERE items.weight_uom_code = wt_conv.from_uom_code (+)
        AND items.wt_rep_uom_code = wt_conv.rep_uom_code (+)
        AND items.volume_uom_code = vol_conv.from_uom_code (+)
        AND items.vol_rep_uom_code = vol_conv.rep_uom_code (+);

    return;

EXCEPTION

    -- Just report this in the wrapper. Shouldn't happen ever anyway.
    WHEN NO_REP_UOMS_DEFINED THEN
        RAISE;

    WHEN OTHERS THEN
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));
        RAISE CONV_RATE_CALC_FAILED;

END compute_conv_rates_init;


/*  wt_vol_init_load

    Set up conversion rates in the reporting UOM conversion rates facts
    for the weight and volume measures.

    The conversion rates are set up for all items in the inventory
    value fact, OPI_DBI_INV_VALUE_F, for WMS enabled, discrete
    manufacturing organizations.

    Currently only interested in conversion rates for weights/volumes.

    History:
    Date        Author              Action
    12/13/04    Dinkar Gupta        Wrote Function.

*/
PROCEDURE wt_vol_init_load (errbuf OUT NOCOPY VARCHAR2,
                            retcode OUT NOCOPY NUMBER)
IS

    l_proc_name CONSTANT VARCHAR2 (40) := 'wt_vol_init_load';
    l_stmt_id NUMBER;

    -- Check if missing conversion rates
    l_missing_rates BOOLEAN;

    -- Run date of the program
    l_run_date DATE;

BEGIN

    -- Initialization block.
    l_stmt_id := 0;
    l_missing_rates := FALSE;

    l_stmt_id := 5;
    -- Capture the running start time of the program
    l_run_date := sysdate;
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 10;
    -- Set up the global parameters
    global_setup ();
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 20;
    -- Set up the relevant tables
    setup_tables_init ();
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 30;
    -- Ensure that we only do something if at least one of the
    -- reporting UOMs is set up. Otherwise just return.
    IF (s_wt_rep_uom_code IS NULL AND
        s_vol_rep_uom_code IS NULL) THEN
        RAISE NO_REP_UOMS_DEFINED;
    END IF;
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 40;
    -- Compute the item specific conversion rates.
    -- Insert them into the fact table directly.
    compute_conv_rates_init (s_wt_rep_uom_code, s_vol_rep_uom_code);
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 50;
    -- Commit the rates found so far.
    commit;
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 60;
    -- Determine if there are any missing rates, and report them.
    l_missing_rates := check_missing_rates ('opi_dbi_wms_stor_item_conv_f');
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 70;
    -- If there are missing rates, transfer the data
    -- from the fact to the staging table, and error out.
    -- Don't truncate the staging table.
    -- The details in the table can be used for detail item
    -- level error reporting in the standalone concurrent program,
    -- Report Warehouse Storage Utilized/Current Capacity Utilization
    -- UOM Conversion Rates Error Details.
    IF (l_missing_rates = TRUE) THEN

        l_stmt_id := 72;
        -- Transfer the fact table to the staging table that is
        -- currently empty.
        transfer_fact_to_staging;

        l_stmt_id := 76;
        -- Commit all data by truncating the fact table.
        EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
                           'OPI_DBI_WMS_STOR_ITEM_CONV_F');

        RAISE MISSING_RATES_FOUND;

    END IF;
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 70;
    -- Update the log table
    update_log (l_run_date);
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 80;
    -- Commit all data by truncating the staging table.
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
                       'OPI_DBI_WMS_STOR_ITEM_CONV_STG');
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    errbuf := '';
    retcode := C_SUCCESS;
    BIS_COLLECTION_UTILITIES.PUT_LINE (C_SUCCESS_MESG);
    return;

EXCEPTION

    WHEN GLOBAL_SETUP_MISSING THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_STOR_INIT_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (GLOBAL_SETUP_MISSING_MESG,
                                             l_proc_name, l_stmt_id));
        return;

    WHEN TABLE_SETUP_FAILED THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_STOR_INIT_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (TABLE_SETUP_FAILED_MESG,
                                             l_proc_name, l_stmt_id));
        return;

    WHEN NO_REP_UOMS_DEFINED THEN
        rollback;
        retcode := C_WARNING;
        errbuf := C_STOR_INIT_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (NO_REP_UOMS_DEFINED_MESG,
                                             l_proc_name, l_stmt_id));
        return;

    WHEN CONV_RATE_CALC_FAILED THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_STOR_INIT_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (CONV_RATE_CALC_FAILED_MESG,
                                             l_proc_name, l_stmt_id));
        return;

    WHEN CONV_RATES_CHECK_FAILED THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_STOR_INIT_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (CONV_RATES_CHECK_FAILED_MESG,
                                             l_proc_name, l_stmt_id));
        return;

    WHEN MISSING_RATES_FOUND THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_STOR_INIT_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (MISSING_RATES_FOUND_MESG,
                                             l_proc_name, l_stmt_id));
        return;

    WHEN LOG_UPDATE_FAILED THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_STOR_INIT_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (LOG_UPDATE_FAILED_MESG,
                                             l_proc_name, l_stmt_id));
        return;

    WHEN TRX_STG_TO_FACT_FAILED THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_STOR_INIT_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (TRX_STG_TO_FACT_FAILED_MESG,
                                             l_proc_name, l_stmt_id));
        return;


    WHEN OTHERS THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_STOR_INIT_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));

        return;

END wt_vol_init_load;


/**************************************************
 * Incremental Load functions
 **************************************************/

/*  setup_tables_incr

    Truncate the following tables:
    2. opi_dbi_wms_stor_item_conv_stg



    History:
    Date        Author              Action
    12/13/04    Dinkar Gupta        Wrote Function.


*/
PROCEDURE setup_tables_incr
IS

    l_proc_name CONSTANT VARCHAR2 (40) := 'setup_tables_incr';
    l_stmt_id NUMBER;

    l_cnt NUMBER;

BEGIN

    -- Initialization block
    l_stmt_id := 0;
    l_cnt := NULL;

    l_stmt_id := 10;
    -- Truncate the staging table
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
                       'OPI_DBI_WMS_STOR_ITEM_CONV_STG');

    l_stmt_id := 20;
    -- Check all rows for this ETL from the log table
    SELECT count (1)
    INTO l_cnt
      FROM opi_dbi_conc_prog_run_log
      WHERE etl_type = C_ETL_TYPE;


    l_stmt_id := 30;
    IF (l_cnt <> 1) THEN
        RAISE LAST_RUN_RECORD_MISSING;
    END IF;

    return;

EXCEPTION

    WHEN OTHERS THEN
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));
        RAISE TABLE_SETUP_FAILED;

END setup_tables_incr;

/*  compute_conv_rates_incr

    Extract the item weight/volume conversions to the corresponding
    reporting UOMS. The item information is stored in the inventory value
    fact. Only interested in the items of WMS enabled discrete organizations.
    (This set of items is generally smaller than all the items for all
    organizations).

    Collect only for items that have changed since the fact should be
    updated as little as possible to maintain effective fast
    refreshability of MVs built on top of it.

    If the conversion rate for the weight/volume to the reporting UOMs
    is not defined, store negative error codes.



    Note also that one or both of the reporting units for weight
    and volume can be NULL. That is not an error condition.

    No committing of data here. The calling function handles that.

    Parameters:
    1. p_wt_rep_uom_code - Weight reporting UOM code
    2. p_vol_rep_uom_code - Volume reporting UOM code

    History:
    Date        Author              Action
    12/13/04    Dinkar Gupta        Wrote Function.

*/
PROCEDURE compute_conv_rates_incr (p_wt_rep_uom_code IN VARCHAR2,
                                   p_vol_rep_uom_code IN VARCHAR2)

IS
    l_proc_name CONSTANT VARCHAR2 (40) := 'compute_conv_rates_incr';
    l_stmt_id NUMBER;

    -- local copy of reporting UOMs
    l_wt_rep_uom_code VARCHAR2 (3);
    l_vol_rep_uom_code VARCHAR2 (3);

BEGIN

    -- initialization block
    l_stmt_id := 0;
    l_wt_rep_uom_code := NULL;
    l_vol_rep_uom_code := NULL;

    l_stmt_id := 10;
    -- If both reporting UOMs are undefined, return. Wrapper routine
    -- should ensure this doesn't happen, but check just in case.
    IF (p_wt_rep_uom_code IS NULL AND
        p_vol_rep_uom_code IS NULL) THEN
        RAISE NO_REP_UOMS_DEFINED;
    END IF;

    l_stmt_id := 20;
    -- Set the reporting UOM's to the dummy code, to avoid handling
    -- the condition that one of them can be NULL in the SQL below.
    l_wt_rep_uom_code := nvl (p_wt_rep_uom_code, C_DUMMY_UOM_CODE);
    l_vol_rep_uom_code := nvl (p_vol_rep_uom_code, C_DUMMY_UOM_CODE);

    l_stmt_id := 30;
    -- Extract the weight/volume conversion rates for all
    -- distinct item/org pairs that belong to WMS enabled discrete
    -- manufacturing organizations and that are already present in the
    -- inventory value fact, OPI_DBI_INV_VALUE_F. Need to specifically
    -- filter out process organizations here, because we only
    -- join to the inventory value fact which has data from both, discrete
    -- and process organizations.
    --
    -- Collecting 2 measures:
    -- 1. Conversion rate from the item weight UOM code to the weight
    --    reporting UOM code.
    -- 2. Conversion rate from the item volume UOM code to the volume
    --    reporting UOM code.
    --
    -- The item setup form guarantees that a UOM be specified for the
    -- item weight/volume before a value is specified. So no need to
    -- worry about missing UOMs and specified values.
    --
    -- All possible conversions to the reporting UOMs are stored in
    -- the standard conversion rates table, OPI_DBI_REP_UOM_STD_CONV_F.
    -- The extraction program will join twice to this table, once
    -- for weight conversions and once for volume conversions.
    -- Since certain rows may not join to the conversion fact for
    -- one of the measures, use outer joins.
    --
    -- The following pathalogical scenarios are possible:
    --
    -- Missing Setups:
    -- 1. Item Weight setup is missing.
    -- 2. Item Volume setup is missing.
    -- Either or both of the above are acceptable. In case of no setup,
    -- report NULL for the corresponding measure.
    --
    -- Missing conversion rates:
    -- 1. Item weight cannot be converted into the reporting weight UOM.
    -- 2. Item volume cannot be converted into the reporting volume UOM.
    -- This will be recorded as a negative number, given the negative
    -- error codes for missing rates. Store that for the moment, and
    -- report errors later. If no conversion rate is found, record a
    -- negative number.
    --
    -- Missing Reporting UOMs:
    -- 1. The Weight Reporting UOM can be missing.
    -- 2. The Volume Reporting UOM can be missing.
    -- Since both won't be missing, these are acceptable scenarios i.e.
    -- ones where customers do not care about one of the measures. Simply
    -- set the conversion rate for that measure to NULL everywhere.
    --
    -- Weight/Volume UOM can be the same:
    -- 1. The item's weight capacity and volume UOM can be the
    --    same. This is acceptable. However, suppose this UOM is Kg, that
    --    needs to be converted to weight reporting UOM (lbs) and volume
    --    reporting UOM M3.
    --    Say the conversion rates table has a rate from Kg --> lbs, but
    --    nothing from Kg --> M3. To avoid filtering out rows for such
    --    items and instead reporting errors for them, this SQL has
    --    to be written with an inline view which contains all the
    --    from and reporting UOMs, and an outer SQL that purely outer
    --    joins to the standard conversion rates tables based on these
    --    from and reporting UOMs.
    --
    --
    -- It seems like overkill to compute conversion rates for all
    -- item/orgs in the inventory value fact. The reasons for this
    -- decision are the following:
    -- 1.   Having a separate staging table to hold just incremental rows
    --      collected by the inventory value fact requires addressing
    --      all sorts of synchronization issues between the inventory
    --      value and WMS ETLs. Who populates the data? Who truncates the
    --      table? What if the two programs are running simultaneously?
    --      Should the inventory ETL only populate this table once WMS has
    --      been implemented?
    --
    -- 2.   Users could change the weight and/or volume UOM of an item.
    --      In that case, it will not be sufficient to look only at new
    --      conversion rates that have changed and new items. We would
    --      have to look at setups of existing items also. Given the
    --      lack of indexes on the last_update_date column on
    --      all the tables involved, all such queries would result in
    --      full table scans.
    -- 3.   The inventory fact does not grow terribly quickly. Hence a
    --      full scan of distinct item/orgs in it will not be too expensive.
    INSERT /*+ append */
    INTO opi_dbi_wms_stor_item_conv_stg (
        organization_id,
        inventory_item_id,
        unit_weight_uom_code,
        weight_conv_rate,
        weight_conv_rate_type,
        unit_volume_uom_code,
        volume_conv_rate,
        volume_conv_rate_type)
    SELECT /*+ use_hash (all_rates, existing) */
        all_rates.organization_id,
        all_rates.inventory_item_id,
        all_rates.unit_weight_uom_code,
        all_rates.weight_conv_rate,
        all_rates.weight_conv_rate_type,
        all_rates.unit_volume_uom_code,
        all_rates.volume_conv_rate,
        all_rates.volume_conv_rate_type
      FROM
        (SELECT /*+ use_hash (items, wt_conv, vol_conv) */
            items.organization_id,
            items.inventory_item_id,
            decode (items.weight_uom_code,
                    C_DUMMY_UOM_CODE, NULL,
                    items.weight_uom_code) unit_weight_uom_code,
            CASE    -- order of conditions matters
                WHEN items.unit_weight IS NULL THEN
                    -- Weight not setup. Acceptable.
                    NULL
                WHEN items.wt_rep_uom_code = C_DUMMY_UOM_CODE THEN
                    -- Weight reporting UOM not set up. Acceptable
                    NULL
                WHEN wt_conv.conversion_rate IS NULL THEN
                    -- Row created from pure outer join i.e. it is a valid
                    -- combination with non-null UOMs and there is
                    -- no conv. rate for this combination.
                    -- From_uom_code and rep_uom_code
                    -- will be null in the wt_conv table for this row also.
                    C_CONV_NOT_SETUP
                WHEN wt_conv.conversion_rate < 0 THEN
                    -- Error found in conversion rates table.
                    C_CONV_NOT_SETUP
                WHEN wt_conv.conversion_rate >= 0 THEN
                    -- Valid conv. rate found.
                    -- Note: allowing conv. rate = 0.
                    wt_conv.conversion_rate
                ELSE
                    -- Why will we get here? Should really never.
                    C_CONV_NOT_SETUP
            END weight_conv_rate,
            wt_conv.conversion_type weight_conv_rate_type,
            decode (items.volume_uom_code,
                    C_DUMMY_UOM_CODE, NULL,
                    items.volume_uom_code) unit_volume_uom_code,
            CASE    -- order of conditions matters
                WHEN items.unit_volume IS NULL THEN
                    -- Volume not setup. Acceptable.
                    NULL
                WHEN items.vol_rep_uom_code = C_DUMMY_UOM_CODE THEN
                    -- Volume reporting UOM not set up. Acceptable
                    NULL
                WHEN vol_conv.conversion_rate IS NULL THEN
                    -- Row created from pure outer join i.e. it is a valid
                    -- combination with non-null UOMs and there is
                    -- no conv. rate for this combination.
                    -- From_uom_code and rep_uom_code
                    -- will be null in the vol_conv table for this row also.
                    C_CONV_NOT_SETUP
                WHEN vol_conv.conversion_rate < 0 THEN
                    -- Error found in conversion rates table.
                    C_CONV_NOT_SETUP
                WHEN vol_conv.conversion_rate >= 0 THEN
                    -- Valid conv. rate found.
                    -- Note: allowing conv. rate = 0.
                    vol_conv.conversion_rate
                ELSE
                    -- Why will we get here? Should really never.
                    C_CONV_NOT_SETUP
            END volume_conv_rate,
            vol_conv.conversion_type volume_conv_rate_type
          FROM
            (SELECT /*+ use_hash (conv_items, item_attr) */
                conv_items.organization_id,
                conv_items.inventory_item_id,
                item_attr.primary_uom_code,
                nvl (item_attr.weight_uom_code, C_DUMMY_UOM_CODE) weight_uom_code,
                l_wt_rep_uom_code wt_rep_uom_code,
                nvl (item_attr.volume_uom_code, C_DUMMY_UOM_CODE) volume_uom_code,
                l_vol_rep_uom_code vol_rep_uom_code,
                item_attr.unit_weight,
                item_attr.unit_volume
              FROM
                (SELECT /*+ use_hash (fact, mp) */
                 DISTINCT
                    fact.organization_id,
                    fact.inventory_item_id
                  FROM  opi_dbi_inv_value_f fact,
                        mtl_parameters mp
                  WHERE mp.wms_enabled_flag = 'Y'
                    AND fact.organization_id = mp.organization_id
                    AND fact.source = C_DISCRETE_ORGS
                ) conv_items,
                eni_oltp_item_star item_attr
              WHERE conv_items.organization_id = item_attr.organization_id
                AND conv_items.inventory_item_id = item_attr.inventory_item_id
            ) items,
            opi_dbi_rep_uom_std_conv_f wt_conv,
            opi_dbi_rep_uom_std_conv_f vol_conv
          WHERE items.weight_uom_code = wt_conv.from_uom_code (+)
            AND items.wt_rep_uom_code = wt_conv.rep_uom_code (+)
            AND items.volume_uom_code = vol_conv.from_uom_code (+)
            AND items.vol_rep_uom_code = vol_conv.rep_uom_code (+)
        ) all_rates,
        opi_dbi_wms_stor_item_conv_f existing
      WHERE all_rates.organization_id = existing.organization_id (+)
        AND all_rates.inventory_item_id = existing.inventory_item_id (+)
        AND (   (    existing.organization_id IS NULL
                 AND existing.inventory_item_id IS NULL )
             OR nvl (all_rates.unit_weight_uom_code, C_DUMMY_UOM_CODE) <>
                    nvl (existing.unit_weight_uom_code, C_DUMMY_UOM_CODE)
             OR nvl (all_rates.weight_conv_rate, -1) <>
                    nvl (existing.weight_conv_rate, -1)
             OR nvl (all_rates.weight_conv_rate_type, -1) <>
                    nvl (existing.weight_conv_rate_type, -1)
             OR nvl (all_rates.unit_volume_uom_code, C_DUMMY_UOM_CODE) <>
                    nvl (existing.unit_volume_uom_code, C_DUMMY_UOM_CODE)
             OR nvl (all_rates.volume_conv_rate, -1)<>
                    nvl (existing.volume_conv_rate, -1)
             OR nvl (all_rates.volume_conv_rate_type, -1) <>
                    nvl (existing.volume_conv_rate_type, -1)
            );

    return;

EXCEPTION

    -- Just report this in the wrapper. Shouldn't happen ever anyway.
    WHEN NO_REP_UOMS_DEFINED THEN
        RAISE;

    WHEN OTHERS THEN
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));
        RAISE CONV_RATE_CALC_FAILED;

END compute_conv_rates_incr;


/*  merge_rates_into_fact

    Merge all the rates computed in the staging table for the incremental
    load into the fact table.

    The staging table only has those records that have been modified
    between incremental loads, or are brand new.

    History:
    Date        Author              Action
    12/13/04    Dinkar Gupta        Wrote Function.
*/
PROCEDURE merge_rates_into_fact
IS

    l_proc_name CONSTANT VARCHAR2 (40) := 'merge_rates_into_fact';
    l_stmt_id NUMBER;

BEGIN

    -- Initialization block
    l_stmt_id := 0;

    l_stmt_id := 10;
    -- Merge all data into the fact table.
    MERGE INTO opi_dbi_wms_stor_item_conv_f base
    USING
        (SELECT
            organization_id,
            inventory_item_id,
            unit_weight_uom_code,
            weight_conv_rate,
            weight_conv_rate_type,
            unit_volume_uom_code,
            volume_conv_rate,
            volume_conv_rate_type,
            sysdate creation_date,
            sysdate last_update_date,
            s_user_id created_by,
            s_user_id last_updated_by,
            s_login_id last_update_login,
            s_program_id program_id,
            s_program_login_id program_login_id,
            s_program_application_id program_application_id,
            s_request_id request_id
          FROM  opi_dbi_wms_stor_item_conv_stg) new
    ON (    base.organization_id = new.organization_id
        AND base.inventory_item_id = new.inventory_item_id)
    WHEN MATCHED THEN UPDATE
    SET
        base.unit_weight_uom_code = new.unit_weight_uom_code,
        base.weight_conv_rate = new.weight_conv_rate,
        base.weight_conv_rate_type = new.weight_conv_rate_type,
        base.unit_volume_uom_code = new.unit_volume_uom_code,
        base.volume_conv_rate = new.volume_conv_rate,
        base.volume_conv_rate_type = new.volume_conv_rate_type,
        base.last_update_date = new.last_update_date,
        base.last_updated_by = new.last_updated_by,
        base.last_update_login = new.last_update_login,
        base.program_id = new.program_id,
        base.program_login_id = new.program_login_id,
        base.program_application_id = new.program_application_id,
        base.request_id = new.request_id
    WHEN NOT MATCHED THEN
    INSERT (
        organization_id,
        inventory_item_id,
        unit_weight_uom_code,
        weight_conv_rate,
        weight_conv_rate_type,
        unit_volume_uom_code,
        volume_conv_rate,
        volume_conv_rate_type,
        creation_date,
        last_update_date,
        created_by,
        last_updated_by,
        last_update_login,
        program_id,
        program_login_id,
        program_application_id,
        request_id)
    VALUES (
        new.organization_id,
        new.inventory_item_id,
        new.unit_weight_uom_code,
        new.weight_conv_rate,
        new.weight_conv_rate_type,
        new.unit_volume_uom_code,
        new.volume_conv_rate,
        new.volume_conv_rate_type,
        new.creation_date,
        new.last_update_date,
        new.created_by,
        new.last_updated_by,
        new.last_update_login,
        new.program_id,
        new.program_login_id,
        new.program_application_id,
        new.request_id);

    return;

EXCEPTION

    WHEN OTHERS THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));
        RAISE MERGE_RATES_FAILED;


END merge_rates_into_fact;

/*  wt_vol_incr_load

    Set up conversion rates in the reporting UOM conversion rates facts
    for the weight and volume measures.

    The conversion rates are set up for all items in the inventory
    value fact, OPI_DBI_INV_VALUE_F, for WMS enabled, discrete
    manufacturing organizations.

    Currently only interested in conversion rates for weights/volumes.

    During the incremental load, consider only those items/orgs that
    have been added during incremental runs of the inventory program
    after the previous run of the WMS conversion rates program.

    History:
    Date        Author              Action
    12/13/04    Dinkar Gupta        Wrote Function.

*/
PROCEDURE wt_vol_incr_load (errbuf OUT NOCOPY VARCHAR2,
                            retcode OUT NOCOPY NUMBER)
IS

    l_proc_name CONSTANT VARCHAR2 (40) := 'wt_vol_incr_load';
    l_stmt_id NUMBER;

    -- Check if missing conversion rates
    l_missing_rates BOOLEAN;

    -- Run date of the program
    l_run_date DATE;

BEGIN

    -- Initialization block.
    l_stmt_id := 0;
    l_missing_rates := FALSE;

    l_stmt_id := 5;
    -- Capture the running start time of the program
    l_run_date := sysdate;
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 10;
    -- Set up the global parameters
    global_setup ();
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 20;
    -- Set up the relevant tables
    setup_tables_incr ();
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 30;
    -- Ensure that we only do something if at least one of the
    -- reporting UOMs is set up. Otherwise just return.
    IF (s_wt_rep_uom_code IS NULL AND
        s_vol_rep_uom_code IS NULL) THEN
        RAISE NO_REP_UOMS_DEFINED;
    END IF;
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 40;
    -- Compute the item specific conversion rates.
    -- Insert them into the staging table.
    compute_conv_rates_incr (s_wt_rep_uom_code, s_vol_rep_uom_code);
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 50;
    -- Commit data to the staging table.
    commit;
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    -- Check for missing rates.
    l_stmt_id := 60;
    l_missing_rates := check_missing_rates ('opi_dbi_wms_stor_item_conv_stg');
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 70;
    -- If there are missing rates commit the staging table
    -- and error out.
    IF (l_missing_rates = TRUE) THEN

        l_stmt_id := 74;
        -- Don't truncate the staging table.
        -- The details in the table can be used for detail item
        -- level error reporting in the standalone concurrent program,
        -- Report Warehouse Storage Utilized/Current Capacity Utilization
        -- UOM Conversion Rates Error Details.
        commit;

        RAISE MISSING_RATES_FOUND;

    END IF;
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 80;
    -- Merge all rates into the conversion rates fact table.
    merge_rates_into_fact ();
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 90;
    -- Update log table with run date of this program.
    update_log (l_run_date);
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 100;
    -- Commit all data by truncating the staging table.
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
                       'OPI_DBI_WMS_STOR_ITEM_CONV_STG');
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    errbuf := '';
    retcode := C_SUCCESS;
    BIS_COLLECTION_UTILITIES.PUT_LINE (C_SUCCESS_MESG);
    return;

EXCEPTION

    WHEN GLOBAL_SETUP_MISSING THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_STOR_INCR_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (GLOBAL_SETUP_MISSING_MESG,
                                             l_proc_name, l_stmt_id));
        return;

    WHEN TABLE_SETUP_FAILED THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_STOR_INCR_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (TABLE_SETUP_FAILED_MESG,
                                             l_proc_name, l_stmt_id));
        return;

    WHEN LAST_RUN_RECORD_MISSING THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_STOR_INCR_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (LAST_RUN_RECORD_MISSING_MESG,
                                             l_proc_name, l_stmt_id));
        return;

    WHEN LOG_UPDATE_FAILED THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_STOR_INCR_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (LOG_UPDATE_FAILED_MESG,
                                             l_proc_name, l_stmt_id));
        return;

    WHEN NO_REP_UOMS_DEFINED THEN
        rollback;
        retcode := C_WARNING;
        errbuf := C_STOR_INCR_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (NO_REP_UOMS_DEFINED_MESG,
                                             l_proc_name, l_stmt_id));
        return;

    WHEN CONV_RATE_CALC_FAILED THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_STOR_INCR_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (CONV_RATE_CALC_FAILED_MESG,
                                             l_proc_name, l_stmt_id));
        return;

    WHEN CONV_RATES_CHECK_FAILED THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_STOR_INCR_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (CONV_RATES_CHECK_FAILED_MESG,
                                             l_proc_name, l_stmt_id));
        return;

    WHEN MISSING_RATES_FOUND THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_STOR_INCR_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (MISSING_RATES_FOUND_MESG,
                                             l_proc_name, l_stmt_id));
        return;

    WHEN MERGE_RATES_FAILED THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_STOR_INCR_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (MERGE_RATES_FAILED_MESG,
                                             l_proc_name, l_stmt_id));
        return;

    WHEN OTHERS THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_STOR_INCR_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));

        return;

END wt_vol_incr_load;



END opi_dbi_wms_storage_utz_pkg;

/
