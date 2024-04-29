--------------------------------------------------------
--  DDL for Package Body OPI_DBI_WMS_CAPACITY_UTZ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_WMS_CAPACITY_UTZ_PKG" AS
/*$Header: OPIDEWCUTZB.pls 120.0 2005/05/24 18:25:37 appldev noship $ */


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

-- Truncate/sets up relevant tables
PROCEDURE setup_tables;


/**************************************************
 * Warehouse Capacity Related procedures
 **************************************************/

-- Extract locator capacities into the subinventory staging table
PROCEDURE extract_locator_capacities (p_wt_rep_uom_code IN VARCHAR2,
                                      p_vol_rep_uom_code IN VARCHAR2);

-- Summarize the locator capacities to the subinventory and
-- organization levels.
PROCEDURE summarize_capacities;

-- Report missing rates/errors
FUNCTION check_locator_setup_errors
    RETURN BOOLEAN;

/**************************************************
 * Item Storage Related procedures
 **************************************************/
-- Extract item storage details into the item fact table
PROCEDURE extract_item_storage (p_wt_rep_uom_code IN VARCHAR2,
                                p_vol_rep_uom_code IN VARCHAR2);


-- Report missing rates/errors
FUNCTION check_item_setup_errors
    RETURN BOOLEAN;

/**************************************************
 * Common Procedures Definitions
 **************************************************/

/*  global_setup

    Performs global setup of file scope variables and does any checking
    needed for global DBI setups.

    Parameters: None

    History:
    Date        Author              Action
    12/01/04    Dinkar Gupta        Defined function.

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
      WHERE measure_code = p_measure_code;

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
    12/08/04    Dinkar Gupta        Defined function.
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

/*  setup_tables

    Clean up tables related to the Current Capacity Utilization report.
    Currently, only need to truncate:
    1. opi_dbi_wms_curr_utz_sub_stg
    2. opi_dbi_wms_curr_utz_sub_f
    1. opi_dbi_wms_curr_utz_item_f

    History:
    Date        Author              Action
    12/08/04    Dinkar Gupta        Wrote Function.
*/
PROCEDURE setup_tables
IS

    l_proc_name CONSTANT VARCHAR2 (40) := 'setup_tables';
    l_stmt_id NUMBER;

BEGIN

    -- Initialization block
    l_stmt_id := 0;

    l_stmt_id := 10;
    -- Truncate OPI_DBI_WMS_CURR_UTZ_SUB_STG
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
                       'OPI_DBI_WMS_CURR_UTZ_SUB_STG');

    l_stmt_id := 20;
    -- Truncate OPI_DBI_WMS_CURR_UTZ_SUB_F
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
                       'OPI_DBI_WMS_CURR_UTZ_SUB_F');

    l_stmt_id := 30;
    -- Truncate OPI_DBI_WMS_CURR_UTZ_ITEM_F
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
                       'OPI_DBI_WMS_CURR_UTZ_ITEM_F');

    return;

EXCEPTION

    WHEN OTHERS THEN
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));
        RAISE TABLE_SETUP_FAILED;

END setup_tables;


/*  refresh_current_utilization

    Wrapper routine to refresh
    1. The weight/volume capacity of warehouses and their subinventories.
    2. The weight and volume of items stored currently in the
       warehouse's locators.

    Locator capacities:
    A locator may have a defined max weight and/or max volume capacity.
    Locators with neither values defined are ignored. Locators with
    only one of the quantities defined contribute to the corresponding
    measure for the subinventory to which they belong.

    Item Weights/volume:
    The item weight will be taken into account only if the locator
    it is present in has a defined weight capacity. Similar condition
    for the item volume. Item quantities present in locators with
    neither weight nor volume capacity defined are ignored.

    Errors are reported for all:
    1. Defined locator weight/volume capacities that cannot be
       converted to the weight/volume reporting UOM values.
    2. Defined item weights/volumes that cannot be converted
       into the weight/volume reporting UOM values.

    No data is collected for the report in case of errors, and the fact
    tables are left truncated.

    Warnings need to be generated for:
    1. All locators whose unit weight/volume capacities are undefined.
    2. All items whose unit weight/volume are undefined.
    Warnings are not generated here for performance reasons mainly.
    However there is a performance reason for it also, namely that if
    a user does not set up some item weight/volumes or locator capacities,
    reporting warnings in this program will always cause termination with
    warnings. A separate concurrent program will be provided with the
    explicit task of reporting setup warnings.

    Parameters:
        errbuf - error message on unsuccessful termination
        retcode - 0 on success, 1 on warning, -1 on error

    History:
    Date        Author              Action
    12/08/04    Dinkar Gupta        Wrote Function.
*/
PROCEDURE refresh_current_utilization (errbuf OUT NOCOPY VARCHAR2,
                                       retcode OUT NOCOPY NUMBER)
IS

    l_proc_name CONSTANT VARCHAR2 (40) := 'refresh_current_utilization';
    l_stmt_id NUMBER;

    -- Booleans to track errors
    l_locator_error BOOLEAN;
    l_item_error BOOLEAN;

BEGIN

    -- Initialization Block
    l_stmt_id := 10;
    l_locator_error := FALSE;
    l_item_error := FALSE;

    l_stmt_id := 10;
    -- Set up the global parameters
    global_setup ();
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 20;
    -- Set up the relevant tables
    setup_tables ();
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
    -- Capture Locator capacity info into the staging table.
    -- Errors will be reported off this table for starters.
    extract_locator_capacities (s_wt_rep_uom_code, s_vol_rep_uom_code);
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 50;
    -- Commit the information inserted into the staging table.
    commit;
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 60;
    -- Extract all the item level information into the item fact using
    -- the locator capacities in the staging table to determine if items
    -- need to be ignored.
    extract_item_storage (s_wt_rep_uom_code, s_vol_rep_uom_code);
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 70;
    -- Commit all item level information extracted so far.
    commit;
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 80;
    -- Report errors in reporting UOM conversions for the locator staging
    -- table. Track if any errors occurred.
    l_locator_error := check_locator_setup_errors ();
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 90;
    -- Report errors in reporting UOM conversions for the item weight/
    -- volume in the item fact. Track if any errors occurred.
    l_item_error := check_item_setup_errors ();
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 100;
    -- If any errors occurred, abort after cleaning out all the tables.
    IF (l_locator_error OR l_item_error) THEN

        -- Don't truncate the locator capacity staging table.
        -- The details in the table can be used for detail locator
        -- level error reporting in the standalone concurrent program,
        -- Report Warehouse Storage Utilized/Current Capacity Utilization
        -- UOM Conversion Rates Error Details.
        commit;

        -- exit
        RAISE PREMATURE_ABORT;

    END IF;
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 110;
    -- If got here, then no errors have occurred. So move all the
    -- locator data into the subinventory fact table.
    summarize_capacities ();
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 120;
    -- Commit all data
    Commit;
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 130;
    -- Everything successful so commit and truncate the staging table.
    commit;
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
                       'OPI_DBI_WMS_CURR_UTZ_SUB_STG');
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    errbuf := '';
    retcode := C_SUCCESS;
    BIS_COLLECTION_UTILITIES.PUT_LINE (C_SUCCESS_MESG);
    return;

EXCEPTION

    WHEN GLOBAL_SETUP_MISSING THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_CURR_UTZ_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (GLOBAL_SETUP_MISSING_MESG,
                                             l_proc_name, l_stmt_id));
        return;

    WHEN TABLE_SETUP_FAILED THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_CURR_UTZ_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (TABLE_SETUP_FAILED_MESG,
                                             l_proc_name, l_stmt_id));
        return;

    WHEN LOCATOR_CAP_CALC_FAILED THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_CURR_UTZ_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (LOCATOR_CAP_CALC_MESG,
                                             l_proc_name, l_stmt_id));
        return;

    WHEN NO_REP_UOMS_DEFINED THEN
        rollback;
        retcode := C_WARNING; -- ??? should this be success?
        errbuf := C_CURR_UTZ_LOAD_WARN_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (NO_REP_UOMS_DEFINED_MESG,
                                             l_proc_name, l_stmt_id));
        return;

    WHEN PREMATURE_ABORT THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_CURR_UTZ_LOAD_WARN_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (PREMATURE_ABORT_MESG,
                                             l_proc_name, l_stmt_id));
        return;

    WHEN ITEM_STOR_CALC_FAILED THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_CURR_UTZ_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (ITEM_STOR_CALC_FAILED_MESG,
                                             l_proc_name, l_stmt_id));
        return;

    WHEN LOCATOR_ERR_CHECK_FAILED THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_CURR_UTZ_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (LOCATOR_ERR_CHECK_FAILED_MESG,
                                             l_proc_name, l_stmt_id));
        return;

    WHEN ITEM_ERR_CHECK_FAILED THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_CURR_UTZ_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (ITEM_ERR_CHECK_FAILED_MESG,
                                             l_proc_name, l_stmt_id));
        return;

    WHEN OTHERS THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_CURR_UTZ_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));

        return;

END refresh_current_utilization;


/**************************************************
 * Warehouse Capacity Related procedures
 **************************************************/

/*  extract_locator_capacities

    Extract the locator weight and volume capacities in the
    staging table, OPI_DBI_WMS_CURR_UTZ_SUB_STG. The capacities
    should be stored in the reporting units of the measures.
    If the weight or volume capacity is null, store NULL.
    If the conversion is not defined in the reporting UOM table,
    OPI_DBI_REP_UOM_STD_CONV_F, store -1.

    Note also that one or both of the reporting units for weight
    and volume can be NULL. That is not an error condition.

    No committing of data here. The calling function handles that.

    Parameters:
    1. p_wt_rep_uom_code - Weight reporting UOM code
    2. p_vol_rep_uom_code - Volume reporting UOM code

    History:
    Date        Author              Action
    12/08/04    Dinkar Gupta        Wrote Function.

*/
PROCEDURE extract_locator_capacities (p_wt_rep_uom_code IN VARCHAR2,
                                      p_vol_rep_uom_code IN VARCHAR2)
IS
    l_proc_name CONSTANT VARCHAR2 (40) := 'extract_locator_capacities';
    l_stmt_id NUMBER;

    -- local copy of reporting UOMs
    l_wt_rep_uom_code VARCHAR2 (3);
    l_vol_rep_uom_code VARCHAR2 (3);

BEGIN

    -- Initialization block
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
    -- Compute the weight/volume capacities for locators in warehouse
    -- enabled organizations. No need to specifically filter out
    -- process organizations since their locator setup is not
    -- stored in MTL_ITEM_LOCATIONS.
    --
    -- The locator weight capacity, volume_capacity, weight_uom_code
    -- and volume_uom_code are stored in the MTL_ITEM_LOCATIONS table.
    --
    -- All possible conversions to the reporting UOMs are stored in
    -- the standard conversion rates table, OPI_DBI_REP_UOM_STD_CONV_F.
    -- The extraction program will join twice to this table, once
    -- for weight capacity conversions and once for volume capacity
    -- conversions. Since certain rows may not join to the conversion
    -- fact for one of the measures, use outer joins.
    --
    -- The following are possible pathological scenarios:
    --
    -- Capacity Setups:
    -- 1. Locator Weight capacity (value or UOM) might be missing.
    -- 2. Locator Volume capacity (value or UOM) might be missing.
    -- Either of the two above are not cause for error, and the corresponding
    -- capacity should be stored as NULL.
    -- The above conditions are detectable as the value of max_weight
    -- and max_cubic_area in MTL_ITEM_LOCATIONS will be NULL if the setup
    -- is missing.
    --
    -- If both capacities are NULL, then for conciseness don't store a
    -- row for that locator.
    --
    -- Missing Conversions:
    -- 1. Locator Weight capacity conversion to reporting weight UOM is
    --    invalid.
    -- 2. Locator Volume capacity conversion to reporting weight UOM is
    --    invalid.
    -- Either of the two above are error conditions and the corresponding
    -- capacities must therefore be flagged with a -1 so that it can be
    -- reported.
    -- The above conditions are detectable as the corresponding conversion
    -- rates will be negative in the standard conversion rates table,
    -- OPI_DBI_REP_UOM_STD_CONV_F.
    --
    -- Missing Reporting UOMs:
    -- 1. The Weight Reporting UOM can be missing.
    -- 2. The Volume Reporting UOM can be missing.
    -- Since both won't be missing, these are acceptable scenarios i.e.
    -- ones where customers do not care about one of the measures. Simply
    -- set that measure to NULL everywhere.
    --
    -- Weight/Volume UOM can be the same:
    -- 1. The locator's weight capacity and volume capacity UOM can be the
    --    same. This is acceptable. However, suppose this UOM is Kg, that
    --    needs to be converted to weight reporting UOM (lbs) and volume
    --    reporting UOM M3.
    --    Say the conversion rates table has a rate from Kg --> lbs, but
    --    nothing from Kg --> M3. To avoid filtering out rows for such
    --    locators and instead reporting errors for them, this SQL has
    --    to be written with an inline view which contains all the
    --    from and reporting UOMs, and an outer SQL that purely outer
    --    joins to the standard conversion rates tables based on these
    --    from and reporting UOMs.
    --
    INSERT /*+ append */
    INTO opi_dbi_wms_curr_utz_sub_stg (
        organization_id,
        subinventory_code,
        locator_id,
        weight_capacity_b,
        weight_uom_code,
        weight_capacity_rep,
        volume_capacity_b,
        volume_uom_code,
        volume_capacity_rep)
    SELECT /*+ parallel (loc) parallel (wt_conv) parallel (vol_conv)
               use_hash (loc, wt_conv, vol_conv) */
        loc.organization_id,
        loc.subinventory_code,
        loc.locator_id,
        loc.max_weight weight_capacity_b,
        decode (loc.weight_uom_code,
                C_DUMMY_UOM_CODE, NULL,
                loc.weight_uom_code) weight_uom_code,
        CASE  -- the order of conditions matters
            WHEN loc.max_weight IS NULL THEN
                -- Weight capacity is not setup up. Legitimate NULL case.
                NULL
            WHEN loc.wt_rep_uom_code = C_DUMMY_UOM_CODE THEN
                --  No weight reporting UOM defined. Acceptable.
                NULL
            WHEN loc.weight_uom_code = C_DUMMY_UOM_CODE AND
                 loc.max_weight IS NOT NULL THEN
                -- Setup error. Value defined, but no UOM.
                -- Ignore this locator.
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
                loc.max_weight * wt_conv.conversion_rate
            ELSE
                -- Why will we get here? Should really never.
                C_CONV_NOT_SETUP
        END weight_capacity_rep,
        loc.max_cubic_area volume_capacity_b,
        decode (loc.volume_uom_code,
                C_DUMMY_UOM_CODE, NULL,
                loc.volume_uom_code) volume_uom_code,
        CASE  -- the order of conditions matters
            WHEN loc.max_cubic_area IS NULL THEN
                -- Volume capacity is not setup up. Legitimate NULL case.
                NULL
            WHEN loc.vol_rep_uom_code = C_DUMMY_UOM_CODE THEN
                --  No volume reporting UOM defined. Acceptable.
                NULL
            WHEN loc.volume_uom_code = C_DUMMY_UOM_CODE AND
                 loc.max_cubic_area IS NOT NULL THEN
                -- Setup error. Value defined, but no UOM.
                -- Ignore this locator.
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
                loc.max_cubic_area * vol_conv.conversion_rate
            ELSE
                -- Why will we get here? Should really never.
                C_CONV_NOT_SETUP
        END volume_capacity_rep
      FROM
        (SELECT /*+ parallel (mil) parallel (mp) */
            mil.organization_id,
            mil.subinventory_code,
            mil.inventory_location_id locator_id,
            mil.max_weight max_weight,
            mil.max_cubic_area max_cubic_area,
            nvl (mil.location_weight_uom_code,
                 C_DUMMY_UOM_CODE) weight_uom_code,
            l_wt_rep_uom_code wt_rep_uom_code,
            nvl (mil.volume_uom_code, C_DUMMY_UOM_CODE) volume_uom_code,
            l_vol_rep_uom_code vol_rep_uom_code
          FROM  mtl_item_locations mil,
                mtl_parameters mp
          WHERE mp.wms_enabled_flag = 'Y'
            AND mil.organization_id = mp.organization_id
            -- filter out locators with neither capacity defined
            AND (   (    mil.max_weight IS NOT NULL
                     AND mil.location_weight_uom_code IS NOT NULL)
                 OR (    mil.max_cubic_area IS NOT NULL
                     AND mil.volume_uom_code IS NOT NULL)
                )
        ) loc,
        opi_dbi_rep_uom_std_conv_f wt_conv,
        opi_dbi_rep_uom_std_conv_f vol_conv
      WHERE loc.weight_uom_code = wt_conv.from_uom_code (+)
        AND loc.wt_rep_uom_code = wt_conv.rep_uom_code (+)
        AND loc.volume_uom_code = vol_conv.from_uom_code (+)
        AND loc.vol_rep_uom_code = vol_conv.rep_uom_code (+);

    return;

EXCEPTION

    -- Just report this in the wrapper. Shouldn't happen ever anyway.
    WHEN NO_REP_UOMS_DEFINED THEN
        RAISE;

    WHEN OTHERS THEN
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));
        RAISE LOCATOR_CAP_CALC_FAILED;

END extract_locator_capacities;


/*  Summarize_capacities

    Summarize the locator capacities to the subinventory and organization
    levels (much like a nested MV without the time dimension).
    The capacities summarized are in the reporting UOMs of the
    respective measures

    The aggregation levels (in keeping with the values used in other
    MVs etc):
    7 - Organization level records
    1 - Subinventory level records

    No committing of data here. The calling function handles that.

    History:
    Date        Author              Action
    12/08/04    Dinkar Gupta        Wrote Function.

*/
PROCEDURE summarize_capacities
IS

    l_proc_name CONSTANT VARCHAR2 (40) := 'summarize_capacities';
    l_stmt_id NUMBER;

BEGIN

    -- Initialization block
    l_stmt_id := 0;

    l_stmt_id := 10;
    -- Summarize the reporting UOM weight and volume capacity values
    -- stored in the staging table. Since the report needs to run
    -- only at the subinventory and organization levels, aggregate the
    -- data. The extra cost of aggregating to the organization level is
    -- minimal.
    --
    -- It is assumed that the data can simply be aggregated. Any errors
    -- that were recorded as negative capacities have been handled/
    -- resolved already (or this function is not called when such errors
    -- exist).
    INSERT /*+ append */
    INTO opi_dbi_wms_curr_utz_sub_f (
        organization_id,
        subinventory_code,
        aggregation_level_flag,
        weight_capacity,
        volume_capacity,
        creation_date,
        last_update_date,
        created_by,
        last_updated_by,
        last_update_login,
        program_id,
        program_login_id,
        program_application_id,
        request_id
    )
    SELECT /*+ parallel (stg) */
        stg.organization_id,
        decode (stg.subinventory_code,
                NULL, NULL,
                stg.subinventory_code || '-' || stg.organization_id)
          subinventory_code,
        decode (grouping_id (stg.organization_id,
                             decode (stg.subinventory_code,
                                     NULL, NULL,
                                     stg.subinventory_code || '-' ||
                                     stg.organization_id)),
                0, 1,
                1, 7,
                -1) aggregation_level_flag,
        sum (stg.weight_capacity_rep) weight_capacity_rep,
        sum (stg.volume_capacity_rep) volume_capacity_rep,
        sysdate,
        sysdate,
        s_user_id,
        s_user_id,
        s_login_id,
        s_program_id,
        s_program_login_id,
        s_program_application_id,
        s_request_id
      FROM opi_dbi_wms_curr_utz_sub_stg stg
      GROUP BY
        stg.organization_id,
        rollup (decode (stg.subinventory_code,
                        NULL, NULL,
                        stg.subinventory_code || '-' || stg.organization_id));


    return;

EXCEPTION

    WHEN OTHERS THEN
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));
        RAISE SUMMARIZE_CAP_FAILED;

END summarize_capacities;

/*  check_locator_setup_errors

    Report any invalid conversion rates found for locator weight
    and or volume capacities.

    History:
    Date        Author              Action
    12/30/04    Dinkar Gupta        Wrote Function.

*/
FUNCTION check_locator_setup_errors
    RETURN BOOLEAN

IS

    l_proc_name CONSTANT VARCHAR2 (40) := 'check_locator_setup_errors';
    l_stmt_id NUMBER;

    -- check if the header has been printed
    l_header_printed BOOLEAN;

    -- check whether to return errors
    l_errors BOOLEAN;

    -- Cursor for missing weight conversions.
    CURSOR wt_missing_rates_csr IS
    SELECT DISTINCT
        weight_uom_code uom_code
      FROM opi_dbi_wms_curr_utz_sub_stg
      WHERE weight_capacity_rep < 0;

    -- Cursor for missing volume conversions.
    CURSOR vol_missing_rates_csr IS
    SELECT DISTINCT
        volume_uom_code uom_code
      FROM opi_dbi_wms_curr_utz_sub_stg
      WHERE volume_capacity_rep < 0;

BEGIN

    -- Initialization block
    l_errors := FALSE;      -- no errors yet
    l_header_printed := FALSE;
    l_stmt_id := 0;

    -- Report missing weights.
    l_header_printed := FALSE;
    l_stmt_id := 10;
    FOR wt_missing_rates_rec IN wt_missing_rates_csr
    LOOP

        -- Print the header once if not done so yet.
        l_stmt_id := 20;
        IF (l_header_printed = FALSE) THEN

            OPI_DBI_REP_UOM_PKG.err_msg_header_spec ('WT', 'LOC');
            l_header_printed := TRUE;

        END IF;

        -- Print the missing rates.
        l_stmt_id := 30;
        OPI_DBI_REP_UOM_PKG.err_msg_missing_uoms (
            wt_missing_rates_rec.uom_code, s_wt_rep_uom_code);

        -- There is an error to report
        l_stmt_id := 40;
        l_errors := TRUE;

    END LOOP;

    -- Footer message.
    IF (l_header_printed = TRUE) THEN
        OPI_DBI_REP_UOM_PKG.err_msg_footer;
    END IF;

    -- Report missing weights.
    l_header_printed := FALSE;
    l_stmt_id := 50;
    FOR vol_missing_rates_rec IN vol_missing_rates_csr
    LOOP

        -- Print the header once if not done so yet.
        l_stmt_id := 60;
        IF (l_header_printed = FALSE) THEN

            OPI_DBI_REP_UOM_PKG.err_msg_header_spec ('VOL', 'LOC');
            l_header_printed := TRUE;

        END IF;

        -- Print the missing rates.
        l_stmt_id := 70;
        OPI_DBI_REP_UOM_PKG.err_msg_missing_uoms (
            vol_missing_rates_rec.uom_code, s_vol_rep_uom_code);

        -- There is an error to report
        l_stmt_id := 80;
        l_errors := TRUE;

    END LOOP;

    -- Footer message.
    IF (l_header_printed = TRUE) THEN
        OPI_DBI_REP_UOM_PKG.err_msg_footer;
    END IF;

    return l_errors;

EXCEPTION

    WHEN OTHERS THEN
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));
        RAISE LOCATOR_ERR_CHECK_FAILED;

END check_locator_setup_errors;


/**************************************************
 * Item Storage Related procedures
 **************************************************/

/*  extract_locator_capacities

    Extract the item storage in all locators of warehouses that
    have weight and/or volume capacities defined. The locator
    capacities are stored in the locator staging table,
    OPI_DBI_WMS_CURR_UTZ_SUB_STG. The item weights/volumes must
    be stored in the reporting UOM values. If a locator does
    not have weight capacity defined the item's weight in that
    locator is ignored. Same goes for the item volume. If the
    conversion rate for the weight/volume to the reporting UOMs
    is not defined, store negative error codes.



    Note also that one or both of the reporting units for weight
    and volume can be NULL. That is not an error condition.

    No committing of data here. The calling function handles that.

    Parameters:
    1. p_wt_rep_uom_code - Weight reporting UOM code
    2. p_vol_rep_uom_code - Volume reporting UOM code

    History:
    Date        Author              Action
    12/08/04    Dinkar Gupta        Wrote Function.

*/
PROCEDURE extract_item_storage (p_wt_rep_uom_code IN VARCHAR2,
                                p_vol_rep_uom_code IN VARCHAR2)

IS
    l_proc_name CONSTANT VARCHAR2 (40) := 'extract_item_storage';
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
    -- Extract the item storage details for all organizations that are
    -- WMS enabled. No need to specifically filter out
    -- process organizations since their locator setup is not
    -- stored in MTL_ONHAND_QUANTITIES.
    --
    -- Collecting 3 measures:
    -- 1. Quantity stored in any locator with weight or volume capacity
    --    defined.
    -- 2. Weight stored in all locators with weight capacity defined.
    -- 3. Volume stored in all locators with volume capacity defined.
    --
    -- The item setup form guarantees that a UOM be specified for the
    -- item weight/volume before a value is specified. So no need to
    -- worry about missing UOMs and specified values.
    --
    -- The subinventory capacity staging table, OPI_DBI_WMS_CURR_UTZ_SUB_STG,
    -- has all the locator level records. Use the values in the reporting
    -- UOM value columns of the staging table. NULL values in those
    -- columns indicate that the corresponding capacity was not specified
    -- for the measure on that locator.
    --
    -- For efficient report query retrieval, store the
    -- the data aggregated at the following levels, marked by the
    -- following aggregation level flag values:
    -- 7 - Organization
    -- 1 - Organization, Inventory Category, Subinventory
    -- 0 - Organization, Inventory Category, Subinventory, Item
    --
    -- All possible conversions to the reporting UOMs are stored in
    -- the standard conversion rates table, OPI_DBI_REP_UOM_STD_CONV_F.
    -- The extraction program will join twice to this table, once
    -- for weight capacity conversions and once for volume capacity
    -- conversions. Since certain rows may not join to the conversion
    -- fact for one of the measures, use outer joins.
    --
    -- The following pathalogical scenarios are possible:
    --
    -- Missing Setups:
    -- 1. Item Weight setup is missing.
    -- 2. Item Volume setup is missing.
    -- Either or both of the above are acceptable. In case of no setup,
    -- report NULL for the corresponding measure, and report a quantity
    -- for the item.
    --
    -- Missing locator setup:
    -- 1. Locator is missing weight capacity.
    -- 2. Locator is missing volume capacity.
    -- By design, both of the above conditions cannot be simultaneously true.
    -- Ignore the item's contribution to the measure whose capacity setup
    -- is missing on the locator by recording a NULL value.
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
    -- set that measure to NULL everywhere.
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
    INSERT /*+ append */
    INTO opi_dbi_wms_curr_utz_item_f (
        organization_id,
        item_org_id,
        uom_code,
        subinventory_code,
        inv_category_id,
        aggregation_level_flag,
        stored_qty,
        weight_qty,
        stored_weight,
        weight_uom_code,
        volume_qty,
        utilized_volume,
        volume_uom_code,
        creation_date,
        last_update_date,
        created_by,
        last_updated_by,
        last_update_login,
        program_id,
        program_login_id,
        program_application_id,
        request_id)
    SELECT /*+ parallel (onh) parallel (wt_conv) parallel (vol_conv)
               use_hash (onh, wt_conv, vol_conv) */
        onh.organization_id,
        (onh.inventory_item_id || '-' || onh.organization_id)
          item_org_id,
        onh.primary_uom_code uom_code,
        decode (onh.subinventory_code,
                NULL, NULL,
                (onh.subinventory_code || '-' || onh.organization_id))
          subinventory_code,
        nvl (onh.inv_category_id, -1) inv_category_id,
        grouping_id (onh.organization_id,
                     nvl (onh.inv_category_id, -1),
                     decode (onh.subinventory_code,
                             NULL, NULL,
                             (onh.subinventory_code || '-' ||
                              onh.organization_id)),
                     (onh.inventory_item_id || '-' ||
                      onh.organization_id))
          aggregation_level_flag,
        sum (onh.stored_qty) stored_qty,
        sum (onh.weight_qty) weight_qty,
        sum (
            CASE    -- order of conditions matters
                WHEN onh.unit_weight IS NULL THEN
                    -- Weight not setup. Acceptable.
                    NULL
                WHEN onh.wt_rep_uom_code = C_DUMMY_UOM_CODE THEN
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
                    onh.weight_qty * wt_conv.conversion_rate *
                    onh.unit_weight
                ELSE
                    -- Why will we get here? Should really never.
                    C_CONV_NOT_SETUP
            END
            ) stored_weight,
        onh.weight_uom_code,
        sum (onh.volume_qty) volume_qty,
        sum (
            CASE    -- order of conditions matters
                WHEN onh.unit_volume IS NULL THEN
                    -- Volume not setup. Acceptable.
                    NULL
                WHEN onh.vol_rep_uom_code = C_DUMMY_UOM_CODE THEN
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
                    onh.volume_qty * vol_conv.conversion_rate *
                    onh.unit_volume
                ELSE
                    -- Why will we get here? Should really never.
                    C_CONV_NOT_SETUP
            END
            ) utilized_volume,
        onh.volume_uom_code,
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
        (SELECT /*+ parallel (moq) parallel (mp) parallel (loc)
                    parallel (items) */
            moq.organization_id,
            moq.inventory_item_id,
            items.primary_uom_code,
            moq.subinventory_code,
            nvl (items.weight_uom_code, C_DUMMY_UOM_CODE) weight_uom_code,
            l_wt_rep_uom_code wt_rep_uom_code,
            nvl (items.volume_uom_code, C_DUMMY_UOM_CODE) volume_uom_code,
            l_vol_rep_uom_code vol_rep_uom_code,
            items.inv_category_id,
            items.unit_weight,
            items.unit_volume,
            sum (moq.transaction_quantity) stored_qty,
            sum (decode (weight_capacity_rep,
                         NULL, NULL,
                         moq.transaction_quantity)) weight_qty,
            sum (decode (volume_capacity_rep,
                         NULL, NULL,
                         moq.transaction_quantity)) volume_qty
          FROM
            mtl_onhand_quantities moq,
            mtl_parameters mp,
            opi_dbi_wms_curr_utz_sub_stg loc,
            eni_oltp_item_star items
          WHERE mp.wms_enabled_flag = 'Y'
            AND moq.organization_id = mp.organization_id
            AND moq.organization_id = items.organization_id
            AND moq.inventory_item_id = items.inventory_item_id
            AND moq.organization_id = loc.organization_id
            AND moq.subinventory_code = loc.subinventory_code
            AND moq.locator_id = loc.locator_id
          GROUP BY
            moq.organization_id,
            moq.inventory_item_id,
            items.primary_uom_code,
            moq.subinventory_code,
            nvl (items.weight_uom_code, C_DUMMY_UOM_CODE),
            nvl (items.volume_uom_code, C_DUMMY_UOM_CODE),
            items.inv_category_id,
            items.unit_weight,
            items.unit_volume
        ) onh,
        opi_dbi_rep_uom_std_conv_f wt_conv,
        opi_dbi_rep_uom_std_conv_f vol_conv
      WHERE onh.weight_uom_code = wt_conv.from_uom_code (+)
        AND onh.wt_rep_uom_code = wt_conv.rep_uom_code (+)
        AND onh.volume_uom_code = vol_conv.from_uom_code (+)
        AND onh.vol_rep_uom_code = vol_conv.rep_uom_code (+)
      GROUP BY
        onh.organization_id,
        rollup ( (nvl (onh.inv_category_id, -1),
                  decode (onh.subinventory_code,
                          NULL, NULL,
                          (onh.subinventory_code || '-' ||
                           onh.organization_id))),
                 ((onh.inventory_item_id || '-' ||
                   onh.organization_id),
                  onh.primary_uom_code,
                  onh.weight_uom_code,
                  onh.volume_uom_code) );

    return;

EXCEPTION

    -- Just report this in the wrapper. Shouldn't happen ever anyway.
    WHEN NO_REP_UOMS_DEFINED THEN
        RAISE;

    WHEN OTHERS THEN
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));
        RAISE ITEM_STOR_CALC_FAILED;

END extract_item_storage;

/*  check_item_setup_errors

    Report any invalid conversion rates found for item weight
    and or volume storage.

    History:
    Date        Author              Action
    12/30/04    Dinkar Gupta        Wrote Function.

*/
FUNCTION check_item_setup_errors
    RETURN BOOLEAN

IS

    l_proc_name CONSTANT VARCHAR2 (40) := 'check_item_setup_errors';
    l_stmt_id NUMBER;

    -- check if the header has been printed
    l_header_printed BOOLEAN;

    -- check whether to return errors
    l_errors BOOLEAN;

    -- Cursor for missing weight conversions at the non-aggregated levels.
    -- Use the fact the the quantity and weight should have the same
    -- sign.
    CURSOR wt_missing_rates_csr IS
    SELECT DISTINCT
        weight_uom_code uom_code
      FROM opi_dbi_wms_curr_utz_item_f
      WHERE stored_weight/weight_qty < 0
        AND aggregation_level_flag = 0;

    -- Cursor for missing volume conversions at the non-aggregated levels.
    -- Use the fact the the quantity and volume should have the same
    -- sign.
    CURSOR vol_missing_rates_csr IS
    SELECT DISTINCT
        volume_uom_code uom_code
      FROM opi_dbi_wms_curr_utz_item_f
      WHERE utilized_volume/volume_qty < 0
        AND aggregation_level_flag = 0;

BEGIN

    -- Initialization block
    l_errors := FALSE;      -- no errors yet
    l_header_printed := FALSE;
    l_stmt_id := 0;

    -- Report missing weights.
    l_header_printed := FALSE;
    l_stmt_id := 10;
    FOR wt_missing_rates_rec IN wt_missing_rates_csr
    LOOP

        -- Print the header once if not done so yet.
        l_stmt_id := 20;
        IF (l_header_printed = FALSE) THEN

            OPI_DBI_REP_UOM_PKG.err_msg_header_spec ('WT', 'ITEM');
            l_header_printed := TRUE;

        END IF;

        -- Print the missing rates.
        l_stmt_id := 30;
        OPI_DBI_REP_UOM_PKG.err_msg_missing_uoms (
            wt_missing_rates_rec.uom_code, s_wt_rep_uom_code);

        -- There is an error to report
        l_stmt_id := 40;
        l_errors := TRUE;

    END LOOP;

    -- Footer message.
    IF (l_header_printed = TRUE) THEN
        OPI_DBI_REP_UOM_PKG.err_msg_footer;
    END IF;

    -- Report missing weights.
    l_header_printed := FALSE;
    l_stmt_id := 50;
    FOR vol_missing_rates_rec IN vol_missing_rates_csr
    LOOP

        -- Print the header once if not done so yet.
        l_stmt_id := 60;
        IF (l_header_printed = FALSE) THEN

            OPI_DBI_REP_UOM_PKG.err_msg_header_spec ('VOL', 'ITEM');
            l_header_printed := TRUE;

        END IF;

        -- Print the missing rates.
        l_stmt_id := 70;
        OPI_DBI_REP_UOM_PKG.err_msg_missing_uoms (
            vol_missing_rates_rec.uom_code, s_vol_rep_uom_code);

        -- There is an error to report
        l_stmt_id := 80;
        l_errors := TRUE;

    END LOOP;

    -- Footer message.
    IF (l_header_printed = TRUE) THEN
        OPI_DBI_REP_UOM_PKG.err_msg_footer;
    END IF;

    return l_errors;

EXCEPTION

    WHEN OTHERS THEN
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));
        RAISE ITEM_ERR_CHECK_FAILED;

END check_item_setup_errors;



END opi_dbi_wms_capacity_utz_pkg;

/
