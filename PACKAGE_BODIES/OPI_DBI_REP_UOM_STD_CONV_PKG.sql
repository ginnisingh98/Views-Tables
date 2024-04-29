--------------------------------------------------------
--  DDL for Package Body OPI_DBI_REP_UOM_STD_CONV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_REP_UOM_STD_CONV_PKG" AS
/*$Header: OPIDEREPUMB.pls 120.0 2005/05/27 18:38:06 appldev noship $ */

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

-- Package level variables for the standard who columns
s_user_id                   NUMBER;
s_login_id                  NUMBER;
s_program_id                NUMBER;
s_program_login_id          NUMBER;
s_program_application_id    NUMBER;
s_request_id                NUMBER;


/**************************************************
* Common Procedures (to initial and incremental load)
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

-- Generate the standard intra-class conversion rates
PROCEDURE compute_std_intra_class_conv;

-- Generate the standard inter-class conversion rates
PROCEDURE compute_std_inter_class_conv;

-- Update the log table.
PROCEDURE update_log (p_run_date IN DATE);

/**************************************************
 * Initial Load Procedures
 *
 * File scope functions (not in spec)
 **************************************************/
-- Clean/Setup up tables for the initial load
PROCEDURE setup_tables_init;

-- Insert the new standard rates (i.e. new combinations not in fact table)
-- into the fact table.
PROCEDURE insert_std_rates_init (p_run_date IN DATE);

/**************************************************
 * Incremental Load Procedures
 *
 * File scope functions (not in spec)
 **************************************************/
-- Clean/Verify tables for the initial load
PROCEDURE setup_tables_incr;

-- Merge the rates found during the incremental load
-- into the fact table if the rate has changed.
PROCEDURE merge_std_rates_incr (p_run_date IN DATE);


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
    -- Get the global start date
    s_global_start_date := trunc (bis_common_parameters.get_global_start_date);
    IF (s_global_start_date IS NULL) THEN
        RAISE GLOBAL_START_DATE_NULL;
    END IF;

    l_stmt_id := 30;
    -- Package level variables for the user logged in
    s_user_id := nvl(fnd_global.user_id, -1);
    s_login_id := nvl(fnd_global.login_id, -1);
    s_program_id := nvl (fnd_global.conc_program_id, -1);
    s_program_login_id := nvl (fnd_global.conc_login_id, -1);
    s_program_application_id := nvl (fnd_global.prog_appl_id,  -1);
    s_request_id := nvl (fnd_global.conc_request_id, -1);

    l_stmt_id := 40;
    return;

EXCEPTION

    WHEN SCHEMA_INFO_NOT_FOUND THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (SCHEMA_INFO_NOT_FOUND_MESG,
                                             l_proc_name, l_stmt_id));
        RAISE GLOBAL_SETUP_MISSING;


    WHEN GLOBAL_START_DATE_NULL THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (GLOBAL_START_DATE_NULL_MESG,
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
    12/01/04    Dinkar Gupta        Defined function.
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


/* compute_std_intra_class_conv

    Compute the standard intra-class conversion rates.

    Rates will be computed for all UOMs belonging to the
    class(es) of the reporting UOM(s) of the the measure(s) specified
    in the p_measure_tbl input parameter.

    No commits done here. Calling function coordinates commit.

    History:
    Date        Author              Action
    12/06/04    Dinkar Gupta        Wrote Function.

*/
PROCEDURE compute_std_intra_class_conv
IS

    l_proc_name CONSTANT VARCHAR2(40) := 'compute_std_intra_class_conv';
    l_stmt_id NUMBER;

BEGIN

    -- initialization block
    l_stmt_id := 0;

    l_stmt_id := 20;
    -- Get all intra-class conversion rates.
    -- It is easier to get all rates since there are not too many rates.
    -- It is much trickier to figure out which rates have changed since the
    -- last run (in case of the initial load, all rates are considered
    -- "changed" since the last run). To figure out precisely which
    -- rates have changed, we'd have to look at all records and determine:
    -- 1. If the conversion of the reporting UOM to the base UOM has changed
    --    since the last run, then all intra class standard rates will
    --    be different.
    -- 2. If the conversion of any other rate to the base UOM has changed,
    --    then only that intra class standard rate has changed.
    -- However, given that there are only a few reporting UOMs, and that
    -- every class has about 8 to 10 UOMs, it is simpler to just
    -- find all intra-class standard rates to the reporting UOMs.
    --
    -- In case there are multiple measures tied to the same reporting UOM,
    -- we need to pick distinct reporting UOMs, irrespective of the measures.
    INSERT /*+ append */
    INTO opi_dbi_rep_uom_conv_stg (
        inventory_item_id,
        from_uom_code,
        from_uom_class,
        rep_uom_code,
        rep_uom_class,
        conversion_rate,
        conversion_type
    )
    SELECT
        C_STD_RATE_ITEM_ID,
        convs.uom_code,
        convs.uom_class,
        msr_mst.rep_uom_code,
        msr_mst.rep_uom_class,
        opi_dbi_rep_uom_pkg.uom_convert
                (C_STD_RATE_ITEM_ID, C_CONV_PRECISION, 1,
                 convs.uom_code, msr_mst.rep_uom_code),
        C_INTRA_CONV_TYPE
      FROM
        (SELECT
         DISTINCT
            rep_uom_code,
            rep_uom_class,
            base_rep_uom_code
          FROM opi_dbi_rep_uoms
          WHERE measure_code in ('WT', 'VOL')
            AND rep_uom_code IS NOT NULL) msr_mst,
        mtl_units_of_measure convs
      WHERE msr_mst.rep_uom_class = convs.uom_class;

    return;

EXCEPTION

    WHEN OTHERS THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));
        RAISE INTRA_STD_CONV_FAILED;


END compute_std_intra_class_conv;


/* compute_std_inter_class_conv

    Compute the standard inter-class conversion rates.

    Rates will be computed for all UOMs belonging to the
    class(es) whose base UOM(s) have a defined conversion to the
    base UOM(s) of the class(es) of the reporting UOM(s).

    No commits done here. Calling function coordinates commit.

    History:
    Date        Author              Action
    12/07/04    Dinkar Gupta        Wrote Function.

*/
PROCEDURE compute_std_inter_class_conv
IS

    l_proc_name CONSTANT VARCHAR2(40) := 'compute_std_inter_class_conv';
    l_stmt_id NUMBER;

BEGIN

    -- initialization block
    l_stmt_id := 0;

    l_stmt_id := 20;
    -- Get all inter-class conversion rates.
    -- It is easier to get all rates since there are not too many rates.
    -- It is much trickier to figure out which rates have changed since the
    -- last run (in case of the initial load, all rates are considered
    -- "changed" since the last run). To figure out precisely which
    -- rates have changed, we'd have to look at all records and determine:
    -- 1. If the conversion of the base UOM of a "from" class to the base UOM
    --    of the reporting class has changed, then rates for all UOMs
    --    from the "from" class will have to be recomputed.
    -- 2. If the conversion of the reporting class base UOM to the
    --    reporting UOM has changed, all rates will be different.
    -- 3. If the conversion from any non-reporting class UOM to the base
    --    UOM of that class has changed, then only that rate will be
    --    different.
    -- This complexity is a basic consequence of the 3 way conversion
    -- that happens internally for inter-class conversions: from the
    -- source UOM to the base UOM of that class, followed by the
    -- conversion between the base UOM of the source and target classes,
    -- followed by the conversion between the base UOM of the target class
    -- and the target UOM.
    --
    -- However, given that there are only a few reporting UOMs, and that
    -- every class has about 8 to 10 UOMs, it is simpler to just
    -- find all inter-class standard rates to the reporting UOMs.
    --
    -- In case there are multiple measures tied to the same reporting UOM,
    -- we need to pick distinct reporting UOMs, irrespective of the measures.
    INSERT /*+ append */
    INTO opi_dbi_rep_uom_conv_stg (
        inventory_item_id,
        from_uom_code,
        from_uom_class,
        rep_uom_code,
        rep_uom_class,
        conversion_rate,
        conversion_type
    )
    SELECT
        C_STD_RATE_ITEM_ID,
        from_uoms.uom_code,
        from_class.uom_class,
        from_rep_bases.rep_uom_code,
        from_rep_bases.rep_uom_class,
        opi_dbi_rep_uom_pkg.uom_convert
                (C_STD_RATE_ITEM_ID, C_CONV_PRECISION, 1,
                 from_uoms.uom_code, from_rep_bases.rep_uom_code),
        C_INTER_CONV_TYPE
      FROM
        (SELECT
         DISTINCT
            msr_mst.rep_uom_class,
            msr_mst.rep_uom_code,
            msr_mst.base_rep_uom_code,
            decode (msr_mst.base_rep_uom_code,
                    convs.to_base_uom_code, convs.from_base_uom_code,
                    convs.to_base_uom_code) base_from_uom_code
          FROM
            (SELECT
             DISTINCT
                rep_uom_code,
                rep_uom_class,
                base_rep_uom_code
              FROM opi_dbi_rep_uoms
              WHERE measure_code in ('WT', 'VOL')
                AND rep_uom_code IS NOT NULL) msr_mst,
            opi_dbi_uom_class_std_conv convs
          WHERE (   convs.from_base_uom_code = msr_mst.base_rep_uom_code
                 OR convs.to_base_uom_code = msr_mst.base_rep_uom_code))
        from_rep_bases,
        mtl_units_of_measure_vl from_class,
        mtl_units_of_measure_vl from_uoms
      WHERE from_rep_bases.base_from_uom_code = from_class.uom_code
        AND from_class.base_uom_flag = C_IS_BASE_UOM
        AND from_class.uom_class = from_uoms.uom_class;

    return;

EXCEPTION

    WHEN OTHERS THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));
        RAISE INTER_STD_CONV_FAILED;


END compute_std_inter_class_conv;


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
    12/07/04    Dinkar Gupta        Wrote Function.

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



/**************************************************
 * Initial Load Procedure Definitions
 **************************************************/

/* setup_tables_init

    Cleans up tables prior to the initial load run.

    Truncates:
    1. OPI_DBI_REP_UOM_STD_CONV_F
    2. OPI_DBI_REP_UOM_CONV_STG

    Deletes:
    1. Rows from OPI_DBI_CONC_PROG_RUN_LOG where row type = REP_UOM.

    Inserts:
    1. Row into OPI_DBI_CONC_PROG_RUN_LOG where row type = REP_UOM with a
       last run date that is very old (e.g. 1st Jan, 1950);

    History:
    Date        Author              Action
    12/06/04    Dinkar Gupta        Wrote Function.

*/
PROCEDURE setup_tables_init
IS

    l_proc_name CONSTANT VARCHAR2 (40) := 'setup_tables_init';
    l_stmt_id NUMBER;

BEGIN

    -- initialization block
    l_stmt_id := 0;


    l_stmt_id := 10;
    -- Truncate the fact table
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
                       'OPI_DBI_REP_UOM_STD_CONV_F');

    l_stmt_id := 20;
    -- Truncate the staging table
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
                       'OPI_DBI_REP_UOM_CONV_STG');

    l_stmt_id := 30;
    -- Delete all rows for this ETL from the log table
    DELETE
      FROM opi_dbi_conc_prog_run_log
      WHERE etl_type = C_ETL_TYPE;

    l_stmt_id := 40;
    commit;

    l_stmt_id := 50;
    -- insert a row into the run log with a very old run date.
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

    l_stmt_id := 50;
    commit;

    return;

EXCEPTION

    WHEN OTHERS THEN
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));
        RAISE TABLE_INIT_SETUP_FAILED;

END setup_tables_init;

/*  insert_std_rates_init

    Insert the new standard conversion rates found from the
    staging table to the fact table.

    No commits done here. Calling function coordinates commit.

    Using an append hint on the insert since this function is designed
    to be used after initial loads. Expect to commit after this function
    before querying from OPI_DBI_REP_UOM_STD_CONV_F.

    No commits done here. Calling function coordinates commit.

    Parameters:
    1. p_run_date - The run time date passed in from the wrapper routine.
                    Ensures that all records are created with the same
                    creation date as the logged run time of the program.

    History:
    Date        Author              Action
    12/07/04    Dinkar Gupta        Wrote Function.

*/
PROCEDURE insert_std_rates_init (p_run_date IN DATE)
IS

    l_proc_name CONSTANT VARCHAR2(40) := 'insert_std_rates_init';
    l_stmt_id NUMBER;

BEGIN

    -- Initialization block
    l_stmt_id := 0;

    -- Insert all standard rates where from UOM/reporting UOM combination
    -- is not in in the fact table.
    -- Standard rates have an item id of 0;
    INSERT /*+ append */
    INTO opi_dbi_rep_uom_std_conv_f (
        from_uom_code,
        from_uom_class,
        rep_uom_code,
        rep_uom_class,
        conversion_rate,
        conversion_type,
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
    SELECT
        stg.from_uom_code,
        stg.from_uom_class,
        stg.rep_uom_code,
        stg.rep_uom_class,
        stg.conversion_rate,
        stg.conversion_type,
        s_user_id,
        p_run_date,
        p_run_date,
        s_user_id,
        s_login_id,
        s_program_id,
        s_program_login_id,
        s_program_application_id,
        s_request_id
      FROM
        opi_dbi_rep_uom_conv_stg stg
      WHERE stg.inventory_item_id = C_STD_RATE_ITEM_ID;

    return;

EXCEPTION

    WHEN OTHERS THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));
        RAISE INSERT_NEW_RATES_FAILED;


END insert_std_rates_init;


/* populate_rep_uom_std_conv_init

    Wrapper routine for the initial load of the standard conversion
    rates program.

    Parameters:
        errbuf - error message on unsuccessful termination
        retcode - 0 on success, 1 on warning, -1 on error

    History:
    Date        Author              Action
    12/01/04    Dinkar Gupta        Wrote Function.
*/
PROCEDURE populate_rep_uom_std_conv_init (errbuf OUT NOCOPY VARCHAR2,
                                          retcode OUT NOCOPY NUMBER)

IS
    l_proc_name CONSTANT VARCHAR2 (40) := 'populate_rep_uom_std_conv_init';
    l_stmt_id NUMBER;

    l_run_date DATE;

BEGIN
    -- Initialization block
    l_stmt_id := 0;


    l_stmt_id := 5;
    -- This is the start of the run time of the program.
    l_run_date := sysdate;
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 10;
    -- Check the global setup
    global_setup ();
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 20;
    -- set/clean up the various program related tables
    setup_tables_init ();
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 40;
    -- Compute all intra-class standard conversion rates and put them
    -- in the staging table.
    compute_std_intra_class_conv ();
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 50;
    -- Commit intra-class rates to the staging table.
    commit;
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 60;
    -- Compute all inter-class standard conversion rates and put them
    -- in the staging table.
    compute_std_inter_class_conv ();
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 70;
    -- Commit inter-class rates to the staging table.
    commit;
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 80;
    -- Insert the new rates in the staging table.
    -- Do not commit until after update of log table.
    insert_std_rates_init (l_run_date);
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 90;
    -- Initial load, so now done. Just update log table.
    update_log (l_run_date);
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 100;
    -- Commit all data finally by truncating the staging table.
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
                       'OPI_DBI_REP_UOM_CONV_STG');
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    errbuf := '';
    retcode := C_SUCCESS;
    BIS_COLLECTION_UTILITIES.PUT_LINE (C_SUCCESS_MESG);
    return;

EXCEPTION

    WHEN GLOBAL_SETUP_MISSING THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_INIT_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (GLOBAL_START_DATE_NULL_MESG,
                                             l_proc_name, l_stmt_id));
        return;

    WHEN TABLE_INIT_SETUP_FAILED THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_INIT_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (TABLE_INIT_SETUP_FAILED_MESG,
                                             l_proc_name, l_stmt_id));
        return;

    WHEN MEASURE_LIST_SETUP_FAILED THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_INIT_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (MEASURE_LIST_SETUP_FAILED_MESG,
                                             l_proc_name, l_stmt_id));
        return;

    WHEN INTRA_STD_CONV_FAILED THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_INIT_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (INTRA_STD_CONV_FAILED_MESG,
                                             l_proc_name, l_stmt_id));
        return;

    WHEN INTER_STD_CONV_FAILED THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_INIT_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (INTER_STD_CONV_FAILED_MESG,
                                             l_proc_name, l_stmt_id));
        return;

    WHEN INSERT_NEW_RATES_FAILED THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_INIT_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (INSERT_NEW_RATES_FAILED_MESG,
                                             l_proc_name, l_stmt_id));
        return;

    WHEN LOG_UPDATE_FAILED THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_INIT_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (LOG_UPDATE_FAILED_MESG,
                                             l_proc_name, l_stmt_id));
        return;

    WHEN OTHERS THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_INIT_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));

        return;

END populate_rep_uom_std_conv_init;

/**************************************************
 * Incremental Load Procedure Definitions
 **************************************************/

/* setup_tables_incr

    Cleans up tables prior to the incremental load run.

    Truncates:
    1. OPI_DBI_REP_UOM_CONV_STG

    Verifies:
    1. There is exactly one row for this ETL in the run log.

    History:
    Date        Author              Action
    12/06/04    Dinkar Gupta        Wrote Function.

*/
PROCEDURE setup_tables_incr
IS

    l_proc_name CONSTANT VARCHAR2 (40) := 'setup_tables_incr';
    l_stmt_id NUMBER;

    l_cnt NUMBER;

BEGIN

    -- initialization block
    l_stmt_id := 0;
    l_cnt := 0;

    l_stmt_id := 10;
    -- Truncate the staging table
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
                       'OPI_DBI_REP_UOM_CONV_STG');

    l_stmt_id := 20;
    -- Delete all rows for this ETL from the log table
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

    WHEN LAST_RUN_RECORD_MISSING THEN
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (LAST_RUN_RECORD_MISSING_MESG,
                                             l_proc_name, l_stmt_id));
        RAISE TABLE_INIT_SETUP_FAILED;


    WHEN OTHERS THEN
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));
        RAISE TABLE_INIT_SETUP_FAILED;

END setup_tables_incr;


/*  merge_std_rates_incr

    Merge the rates during the incremental run of the program.
    Any new UOM combination related rates must be added to the fact.
    Any existing combinations must be updated
    only if the new rate is different from the old rate.
    Do not alter records that have not changed between the previous and
    current run.

    No commits done here. Calling function coordinates commit.

    Parameters:
    1. p_run_date - The run time date passed in from the wrapper routine.
                    Ensures that all records are created with the same
                    creation date as the logged run time of the program.

    History:
    Date        Author              Action
    12/07/04    Dinkar Gupta        Wrote Function.


*/
PROCEDURE merge_std_rates_incr (p_run_date IN DATE)
IS
    l_proc_name CONSTANT VARCHAR2 (40) := 'merge_std_rates_incr';
    l_stmt_id NUMBER;

BEGIN

    -- Initialization block
    l_stmt_id := 0;

    l_stmt_id := 10;
    -- Merge the existing rates into the fact table.
    -- If a combination does not exist in the fact table, then
    -- it needs to be added to it.
    -- If a combination exists and the rate is different in
    -- the fact and the staging table, the fact needs to be updated.
    -- If the combination and conversion rate in the fact and
    -- and the staging table is the same, the record should not be changed.
    MERGE INTO opi_dbi_rep_uom_std_conv_f base
    USING
        (SELECT
            from_uom_code,
            from_uom_class,
            rep_uom_code,
            rep_uom_class,
            conversion_rate,
            conversion_type,
            s_user_id created_by,
            p_run_date creation_date,
            p_run_date last_update_date,
            s_user_id last_updated_by,
            s_login_id last_update_login,
            s_program_id program_id,
            s_program_login_id program_login_id,
            s_program_application_id program_application_id,
            s_request_id request_id
          FROM  opi_dbi_rep_uom_conv_stg
          WHERE inventory_item_id = C_STD_RATE_ITEM_ID) new
    ON (    base.from_uom_code = new.from_uom_code
        AND base.rep_uom_code = new.rep_uom_code)
    WHEN MATCHED THEN UPDATE
    SET
        base.conversion_rate = decode
                                (base.conversion_rate,
                                 new.conversion_rate, base.conversion_rate,
                                 new.conversion_rate),
        base.last_update_date = decode
                                 (base.conversion_rate,
                                  new.conversion_rate, base.last_update_date,
                                  new.last_update_date),
        base.last_updated_by = decode
                                (base.conversion_rate,
                                 new.conversion_rate, base.last_updated_by,
                                 new.last_updated_by),
        base.last_update_login = decode
                                  (base.conversion_rate,
                                   new.conversion_rate,
                                    base.last_update_login,
                                   new.last_update_login),
        base.program_id = decode
                           (base.conversion_rate,
                            new.conversion_rate, base.program_id,
                            new.program_id),
        base.program_login_id = decode
                                 (base.conversion_rate,
                                  new.conversion_rate, base.program_login_id,
                                  new.program_login_id),
        base.program_application_id = decode
                                       (base.conversion_rate,
                                        new.conversion_rate,
                                         base.program_application_id,
                                        new.program_application_id),
        base.request_id = decode
                           (base.conversion_rate,
                            new.conversion_rate, base.request_id,
                            new.request_id)
    WHEN NOT MATCHED THEN INSERT (
        from_uom_code,
        from_uom_class,
        rep_uom_code,
        rep_uom_class,
        conversion_rate,
        conversion_type,
        created_by,
        creation_date,
        last_update_date,
        last_updated_by,
        last_update_login,
        program_id,
        program_login_id,
        program_application_id,
        request_id)
    VALUES (
        new.from_uom_code,
        new.from_uom_class,
        new.rep_uom_code,
        new.rep_uom_class,
        new.conversion_rate,
        new.conversion_type,
        new.created_by,
        new.creation_date,
        new.last_update_date,
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
        RAISE MERGE_STD_RATES_FAILED;

END merge_std_rates_incr;


/* populate_rep_uom_std_conv_incr

    Wrapper routine for the incremental load of the standard conversion
    rates program.

    Parameters:
        errbuf - error message on unsuccessful termination
        retcode - 0 on success, 1 on warning, -1 on error

    History:
    Date        Author              Action
    12/01/04    Dinkar Gupta        Wrote Function.
*/
PROCEDURE populate_rep_uom_std_conv_incr (errbuf OUT NOCOPY VARCHAR2,
                                          retcode OUT NOCOPY NUMBER)
IS
    l_proc_name CONSTANT VARCHAR2 (40) := 'populate_rep_uom_std_conv_incr';
    l_stmt_id NUMBER;

    l_run_date DATE;

BEGIN
    -- Initialization block
    l_stmt_id := 0;

    l_stmt_id := 5;
    -- This is the start of the run time of the program.
    l_run_date := sysdate;
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 10;
    -- Check the global setup
    global_setup ();
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 20;
    -- set/clean up the various program related tables
    setup_tables_incr ();
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 40;
    -- Compute all intra-class standard conversion rates and put them
    -- in the staging table.
    compute_std_intra_class_conv ();
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 50;
    -- Commit intra-class rates to the staging table.
    commit;
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 60;
    -- Compute all inter-class standard conversion rates and put them
    -- in the staging table.
    compute_std_inter_class_conv ();
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 70;
    -- Commit inter-class rates to the staging table.
    commit;
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 80;
    -- Merge the new rates into the staging table.
    -- Note that:
    -- 1. Need to insert new rates that are not presently in the fact, but
    --    are in the staging table.
    -- 2. Need to update rates for combinations in the fact and staging
    --    where the conversion rate in the staging table is different
    --    from that in the fact.
    -- 3. Need to not touch any other rates.
    -- Do not commit until after updating the log table.
    merge_std_rates_incr (l_run_date);
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 90;
    -- Update the run log with the run time of this run.
    update_log (l_run_date);
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 100;
    -- Commit all data finally by truncating the log table.
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
                       'OPI_DBI_REP_UOM_CONV_STG');
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    errbuf := '';
    retcode := C_SUCCESS;
    BIS_COLLECTION_UTILITIES.PUT_LINE (C_SUCCESS_MESG);
    return;

EXCEPTION

    WHEN GLOBAL_SETUP_MISSING THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_INCR_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (GLOBAL_START_DATE_NULL_MESG,
                                             l_proc_name, l_stmt_id));
        return;

    WHEN TABLE_INIT_SETUP_FAILED THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_INCR_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (TABLE_INIT_SETUP_FAILED_MESG,
                                             l_proc_name, l_stmt_id));
        return;

    WHEN INTRA_STD_CONV_FAILED THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_INCR_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (INTRA_STD_CONV_FAILED_MESG,
                                             l_proc_name, l_stmt_id));
        return;

    WHEN INTER_STD_CONV_FAILED THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_INCR_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (INTER_STD_CONV_FAILED_MESG,
                                             l_proc_name, l_stmt_id));
        return;

    WHEN MERGE_STD_RATES_FAILED THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_INCR_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (MERGE_STD_RATES_FAILED_MESG,
                                             l_proc_name, l_stmt_id));
        return;

    WHEN LOG_UPDATE_FAILED THEN
        rollback;
        retcode := C_ERROR;
        errbuf := C_INCR_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg
                                            (LOG_UPDATE_FAILED_MESG,
                                             l_proc_name, l_stmt_id));
        return;


    WHEN OTHERS THEN
        rollback;

        retcode := C_ERROR;
        errbuf := C_INCR_LOAD_ERROR_MESG;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));

        return;

END populate_rep_uom_std_conv_incr;

END opi_dbi_rep_uom_std_conv_pkg;

/
