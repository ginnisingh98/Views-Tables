--------------------------------------------------------
--  DDL for Package Body OPI_DBI_JOBS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_JOBS_PKG" AS
/*$Header: OPIDJOBSB.pls 120.16 2007/04/04 05:28:57 sdiwakar ship $ */

-- Standard WHO column information
g_sysdate DATE;
g_user_id NUMBER;
g_login_id NUMBER;
g_program_id NUMBER;
g_program_login_id NUMBER;
g_program_application_id NUMBER;
g_request_id NUMBER;

-- currency types
g_global_rate_type VARCHAR2(15);
g_global_currency_code VARCHAR2(10);
g_secondary_rate_type VARCHAR2(15);
g_secondary_currency_code VARCHAR2(10);

-- Start date of Euro currency
g_euro_start_date CONSTANT DATE := to_date('01/01/1999','DD/MM/YYYY');

-- error codes
g_ok CONSTANT NUMBER(1) := 0;
g_warning CONSTANT NUMBER(1) := 1;
g_error CONSTANT NUMBER(1) := -1;

/*  Marker for secondary conv. rate if the primary and secondary curr codes
    and rate types are identical. Can't be -1, -2, -3 since the FII APIs
    return those values. */
C_PRI_SEC_CURR_SAME_MARKER CONSTANT NUMBER := -9999;

-- GL API returns -3 if EURO rate missing on 01-JAN-1999
C_EURO_MISSING_AT_START CONSTANT NUMBER := -3;

-- File scope variables
g_global_start_date DATE;
g_last_collection_date DATE;
g_opm_last_collection_date DATE;
g_number_max_value NUMBER;
g_degree NUMBER := 1;
g_r12_migration_date DATE;

/* get_conversion_rate

    Compute all the conversion rates for all distinct organization,
    transaction date pairs in the staging table. The date in the fact
    table is already without a timestamp i.e. trunc'ed.

    There are two conversion rates to be computed:
    1. Primary global
    2. Secondary global (if set up)

    The conversion rate work table was truncated during
    the initialization phase.

    Get the currency conversion rates based on the data in
    OPI_DBI_JOBS_STG using the fii_currency.get_global_rate_primary
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
    08/25/2004      Dinkar Gupta        Modified to provide secondary
                                        currency support.
*/
FUNCTION Get_Conversion_Rate (
    errbuf  IN OUT NOCOPY VARCHAR2,
    retcode IN OUT NOCOPY VARCHAR2
 )
    RETURN NUMBER
 IS

    -- Cursor to see if any rates are missing. See below for details
    CURSOR invalid_rates_exist_csr IS
        SELECT 1
          FROM opi_dbi_muv_conv_rates
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
    CURSOR get_missing_rates_c (p_pri_sec_curr_same NUMBER) IS
        SELECT DISTINCT
            report_order,
            curr_code,
            rate_type,
            completion_date,
            func_currency_code
          FROM (
           SELECT DISTINCT
                    g_global_currency_code curr_code,
                    g_global_rate_type rate_type,
                    1 report_order, -- ordering global currency first
                    mp.organization_code,
                    decode (conv.conversion_rate,
                            C_EURO_MISSING_AT_START, g_euro_start_date,
                            conv.transaction_date) completion_date,
                    conv.f_currency_code func_currency_code
              FROM opi_dbi_muv_conv_rates conv,
                   mtl_parameters mp,
                  (SELECT /*+ parallel (opi_dbi_jobs_stg) */
                   DISTINCT organization_id,
                            trunc (completion_date) completion_date
                     FROM opi_dbi_jobs_stg) to_conv
              WHERE nvl (conv.conversion_rate, -999) < 0 -- null is not fine
                AND mp.organization_id = to_conv.organization_id
                AND conv.transaction_date (+) = to_conv.completion_date
                AND conv.organization_id (+) = to_conv.organization_id
            UNION ALL
            SELECT DISTINCT
                    g_secondary_currency_code curr_code,
                    g_secondary_rate_type rate_type,
                    decode (p_pri_sec_curr_same,
                            1, 1,
                            2) report_order, --ordering secondary currency next
                    mp.organization_code,
                    decode (conv.sec_conversion_rate,
                            C_EURO_MISSING_AT_START, g_euro_start_date,
                            conv.transaction_date) completion_date,
                    conv.f_currency_code func_currency_code
              FROM opi_dbi_muv_conv_rates conv,
                   mtl_parameters mp,
                  (SELECT /*+ parallel (opi_dbi_jobs_stg) */
                   DISTINCT organization_id,
                            trunc (completion_date) completion_date
                     FROM opi_dbi_jobs_stg) to_conv
              WHERE nvl (conv.sec_conversion_rate, 999) < 0 -- null is fine
                AND mp.organization_id = to_conv.organization_id
                AND conv.transaction_date (+) = to_conv.completion_date
                AND conv.organization_id (+) = to_conv.organization_id)
          ORDER BY
                report_order ASC,
                completion_date,
                func_currency_code;

    l_stmt_num NUMBER;
    no_currency_rate_flag NUMBER;

    -- Flag to check if the primary and secondary currencies are the
    -- same
    l_pri_sec_curr_same NUMBER;

    -- old error reporting
    i_err_num NUMBER;
    i_err_msg VARCHAR2(255);


BEGIN

    l_stmt_num := 0;
    -- initialization block
    retcode := g_ok;
    no_currency_rate_flag := 0;
    l_pri_sec_curr_same := 0;


    l_stmt_num := 10;
    -- check if the primary and secondary currencies and rate types are
    -- identical.
    IF (g_global_currency_code = nvl (g_secondary_currency_code, '---') AND
        g_global_rate_type = nvl (g_secondary_rate_type, '---') ) THEN
        l_pri_sec_curr_same := 1;
    END IF;


    l_stmt_num := 20;
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
    INSERT /*+ append parallel(rates) */
    INTO opi_dbi_muv_conv_rates rates (
        organization_id,
        f_currency_code,
        transaction_date,
        conversion_rate,
        sec_conversion_rate,
        creation_date,
        last_update_date,
        created_by,
        last_updated_by,
        last_update_login,
        PROGRAM_ID,
	PROGRAM_LOGIN_ID,
	PROGRAM_APPLICATION_ID,
	REQUEST_ID )
    SELECT /*+ parallel (to_conv) parallel (curr_codes) */
        to_conv.organization_id,
        curr_codes.currency_code,
        to_conv.completion_date,
        decode (curr_codes.currency_code,
                g_global_currency_code, 1,
                fii_currency.get_global_rate_primary (
                                    curr_codes.currency_code,
                                    to_conv.completion_date) ),
        decode (g_secondary_currency_code,
                NULL, NULL,
                curr_codes.currency_code, 1,
                decode (l_pri_sec_curr_same,
                        1, C_PRI_SEC_CURR_SAME_MARKER,
                        fii_currency.get_global_rate_secondary (
                            curr_codes.currency_code,
                            to_conv.completion_date))),
        g_sysdate,
        g_sysdate,
        g_user_id,
        g_user_id,
        g_login_id,
        g_program_id,
	g_program_login_id,
	g_program_application_id,
	g_request_id
      FROM
        (SELECT /*+ parallel (opi_dbi_jobs_stg) */
         DISTINCT organization_id, trunc (completion_date) completion_date
           FROM opi_dbi_jobs_stg) to_conv,
        (SELECT /*+ leading (hoi) full (hoi) use_hash (gsob)
                    parallel (hoi) parallel (gsob)*/
         DISTINCT hoi.organization_id, gsob.currency_code
           FROM hr_organization_information hoi,
                gl_sets_of_books gsob
           WHERE hoi.org_information_context  = 'Accounting Information'
             AND hoi.org_information1  = to_char(gsob.set_of_books_id))
        curr_codes
      WHERE curr_codes.organization_id  = to_conv.organization_id;


    --Introduced commit because of append parallel in the insert stmt above.
    commit;


    l_stmt_num := 40;
    -- if the primary and secondary currency codes are the same, then
    -- update the secondary with the primary
    IF (l_pri_sec_curr_same = 1) THEN

        UPDATE /*+ parallel (opi_dbi_muv_conv_rates) */
        opi_dbi_muv_conv_rates
        SET sec_conversion_rate = conversion_rate;

        -- safe to commit, as before
        commit;

    END IF;


    -- report missing rate
    l_stmt_num := 50;

    OPEN invalid_rates_exist_csr;
    FETCH invalid_rates_exist_csr INTO invalid_rates_exist_rec;
    IF (invalid_rates_exist_csr%FOUND) THEN

        -- there are missing rates - prepare to report them.
        no_currency_rate_flag := 1;
        BIS_COLLECTION_UTILITIES.writeMissingRateHeader;

        l_stmt_num := 60;
        FOR get_missing_rates_rec IN get_missing_rates_c (l_pri_sec_curr_same)
        LOOP

            BIS_COLLECTION_UTILITIES.writemissingrate (
                get_missing_rates_rec.rate_type,
                get_missing_rates_rec.func_currency_code,
                get_missing_rates_rec.curr_code,
                get_missing_rates_rec.completion_date);

        END LOOP;

    END IF;
    CLOSE invalid_rates_exist_csr;


    l_stmt_num := 70; /* check no_currency_rate_flag  */
    IF (no_currency_rate_flag = 1) THEN /* missing rate found */
        bis_collection_utilities.put_line('ERROR: Please setup conversion rate for all missing rates reported');

        retcode := g_error;
    END IF;

   return retcode;

EXCEPTION
    WHEN OTHERS THEN
        rollback;
        i_err_num := SQLCODE;
        i_err_msg := 'OPI_DBI_JOBS_PKG.GET_CONVERSION_RATE ('
                    || to_char(l_stmt_num)
                    || '): '
                    || substr(SQLERRM, 1,200);

        BIS_COLLECTION_UTILITIES.put_line('OPI_DBI_JOBS_PKG.GET_CONVERSION_RATE - Error at statement ('
                    || to_char(l_stmt_num)
                    || ')');

        BIS_COLLECTION_UTILITIES.put_line('Error Number: ' ||  to_char(i_err_num));
        BIS_COLLECTION_UTILITIES.put_line('Error Message: ' || i_err_msg);

        retcode := g_error;
        return g_error;

END Get_Conversion_Rate;



FUNCTION Insert_into_Jobs_Fact RETURN NUMBER
IS
    l_row_count NUMBER;
BEGIN

    INSERT /*+ append parallel(f) */
    INTO opi_dbi_jobs_f f (
        organization_id,
        job_id,
        job_type,
        status,
        completion_date,
        assembly_item_id,
        start_quantity,
        actual_qty_completed,
        uom_code,
        conversion_rate,
        sec_conversion_rate,
        include_job,
        std_req_flag,
        std_res_flag,
        source,
        creation_date,
        last_update_date,
        created_by,
        last_updated_by,
        last_update_login,
        job_name,
        line_type,
        scheduled_completion_date,
        job_status_code,
        job_start_value,
        PROGRAM_ID,
	PROGRAM_LOGIN_ID,
	PROGRAM_APPLICATION_ID,
	REQUEST_ID)
    SELECT /*+ parallel (fstg)  parallel (conv) */
        fstg.organization_id,
        fstg.job_id,
        fstg.job_type,
        fstg.status,
        fstg.completion_date,
        fstg.assembly_item_id,
        fstg.start_quantity,
        fstg.actual_qty_completed,
        fstg.uom_code,
        conv.conversion_rate,
        conv.sec_conversion_rate,
        fstg.include_job,
        1,
        fstg.std_res_flag,
        fstg.source,
        fstg.creation_date,
        fstg.last_update_date,
        fstg.created_by,
        fstg.last_updated_by,
        fstg.last_update_login,
        fstg.job_name,
        fstg.line_type,
        fstg.scheduled_completion_date,
        fstg.job_status_code,
        fstg.job_start_value,
        fstg.PROGRAM_ID,
	fstg.PROGRAM_LOGIN_ID,
	fstg.PROGRAM_APPLICATION_ID,
	fstg.REQUEST_ID
      FROM  opi_dbi_jobs_stg fstg,
            opi_dbi_muv_conv_rates conv
      WHERE fstg.organization_id = conv.organization_id
        AND fstg.completion_date = conv.transaction_date;

    l_row_count := sql%rowcount;
    commit;

    RETURN l_row_count;

END Insert_into_Jobs_Fact;



FUNCTION Merge_into_Jobs_Fact
    RETURN NUMBER
IS
    l_row_count NUMBER;
BEGIN
    MERGE INTO OPI_DBI_JOBS_F f
    USING (
    SELECT
        fstg.organization_id,
        fstg.job_id,
        fstg.job_type,
        fstg.status,
        fstg.completion_date,
        fstg.assembly_item_id,
        fstg.start_quantity,
        fstg.actual_qty_completed,
        fstg.uom_code,
        conv.conversion_rate,
        conv.sec_conversion_rate,
        fstg.include_job,
        fstg.source,
        fstg.creation_date,
        fstg.last_update_date,
        fstg.created_by,
        fstg.last_updated_by,
        fstg.last_update_login,
        fstg.job_name,
        fstg.line_type,
        fstg.scheduled_completion_date,
        fstg.job_status_code,
        fstg.job_start_value,
        fstg.PROGRAM_ID PROGRAM_ID,
	fstg.PROGRAM_LOGIN_ID PROGRAM_LOGIN_ID,
	fstg.PROGRAM_APPLICATION_ID PROGRAM_APPLICATION_ID,
	fstg.REQUEST_ID REQUEST_ID
      FROM  opi_dbi_jobs_stg fstg,
            opi_dbi_muv_conv_rates conv
      WHERE fstg.organization_id = conv.organization_id
        AND fstg.completion_date = conv.transaction_date ) s
    ON (    f.Organization_id      = s.Organization_id
        and f.Job_id           = s.Job_id
        and f.Job_Type         = s.Job_Type
        and f.Assembly_Item_id = s.Assembly_Item_id
        and f.line_type        = s.line_type)
    WHEN MATCHED THEN
    UPDATE SET
        f.status = s.status
       ,f.job_name = s.job_name
       ,f.completion_date = s.completion_date
       ,f.start_quantity = s.start_quantity
       ,f.actual_qty_completed = s.actual_qty_completed
       ,f.uom_code = s.uom_code
       ,f.conversion_rate = s.conversion_rate
       ,f.include_job = s.include_job
       ,std_req_flag = (CASE
                        WHEN f.Status not in ( 'Closed', 'Complete - No Charges', 'Cancelled' )
                         AND s.Status in ( 'Closed', 'Complete - No Charges', 'Cancelled' ) THEN 1
                        WHEN s.Status in ( 'Closed', 'Complete - No Charges', 'Cancelled' )
                         AND s.Actual_Qty_Completed <> f.Actual_Qty_Completed THEN 1
                        WHEN s.Status in ( 'Closed', 'Complete - No Charges', 'Cancelled' )
                         AND s.Start_Quantity <> f.Start_Quantity THEN 1
                        WHEN s.Status in ( 'Closed', 'Complete - No Charges', 'Cancelled' )
                         AND trunc(s.Completion_date) <> trunc(f.Completion_date) THEN 1
                        ELSE 0
                        END)
       ,std_res_flag = (CASE
                        WHEN f.Status not in ( 'Closed', 'Complete - No Charges', 'Cancelled' )
                         AND s.Status in ( 'Closed', 'Complete - No Charges', 'Cancelled' ) THEN 1
                        WHEN s.Status in ( 'Closed', 'Complete - No Charges', 'Cancelled' )
                         AND s.Actual_Qty_Completed <> f.Actual_Qty_Completed THEN 1
                        WHEN s.Status in ( 'Closed', 'Complete - No Charges', 'Cancelled' )
                         AND s.Start_Quantity <> f.Start_Quantity THEN 1
                        WHEN s.Status in ( 'Closed', 'Complete - No Charges', 'Cancelled' )
                         AND trunc(s.Completion_date) <> trunc(f.Completion_date) THEN 1
                        ELSE 0
                        END)
       ,last_Update_Date = SYSDATE
       ,last_Updated_By = g_user_id
       ,last_Update_Login = g_login_id
       ,f.scheduled_completion_date = s.scheduled_completion_date
       ,f.job_status_code = s.job_status_code
       ,f.job_start_value = s.job_start_value
    WHEN NOT MATCHED THEN
    INSERT (
        organization_id,
        job_id,
        job_type,
        status,
        completion_date,
        assembly_item_id,
        start_quantity,
        actual_qty_completed,
        uom_code,
        conversion_rate,
        sec_conversion_rate,
        include_job,
        std_req_flag,
        std_res_flag,
        source,
        creation_date,
        last_update_date,
        created_by,
        last_updated_by,
        last_update_login,
        job_name,
        line_type,
        scheduled_completion_date,
        job_status_code,
        job_start_value,
        PROGRAM_ID,
	PROGRAM_LOGIN_ID,
	PROGRAM_APPLICATION_ID,
	REQUEST_ID)
    VALUES (
        s.organization_id,
        s.job_id,
        s.job_type,
        s.status,
        s.completion_date,
        s.assembly_item_id,
        s.start_quantity,
        s.actual_qty_completed,
        s.uom_code,
        s.conversion_rate,
        s.sec_conversion_rate,
        s.include_job,
        1,
        1,
        s.source,
        s.creation_date,
        s.last_update_date,
        s.created_by,
        s.last_updated_by,
        s.last_update_login,
        s.job_name,
        s.line_type,
        s.scheduled_completion_date,
        s.job_status_code,
        s.job_start_value,
        s.PROGRAM_ID,
	s.PROGRAM_LOGIN_ID,
	s.PROGRAM_APPLICATION_ID,
	s.REQUEST_ID);

    l_row_count := sql%rowcount;
    commit;


    RETURN l_row_count;

END Merge_into_Jobs_Fact;


PROCEDURE GET_JOBS_INITIAL_LOAD (errbuf in out NOCOPY varchar2,
                                 retcode in out NOCOPY varchar2)
IS
    l_stmt_num        NUMBER;
    l_row_count       NUMBER;
    l_ret_code        NUMBER;
    l_err_num     NUMBER;
    l_err_msg     VARCHAR2(255);
    l_proc_name   VARCHAR2(255);
    l_opi_schema      VARCHAR2(30);
    l_status          VARCHAR2(30);
    l_industry        VARCHAR2(30);
    l_list dbms_sql.varchar2_table;
    l_from_date OPI.OPI_DBI_RUN_LOG_CURR.FROM_BOUND_DATE%TYPE;
    l_to_date OPI.OPI_DBI_RUN_LOG_CURR.FROM_BOUND_DATE%TYPE;

    CURSOR OPI_DBI_RUN_LOG_CURR_CSR IS
    select
     	from_bound_date,
     	to_bound_date
    from
     	OPI_DBI_RUN_LOG_CURR
    where
     	ETL_ID = 4 and
 	source = 2;

BEGIN

    l_proc_name := 'OPI_DBI_JOBS_PKG.GET_JOBS_INITIAL_LOAD';
    BIS_COLLECTION_UTILITIES.PUT_LINE('Entering Procedure '|| l_proc_name);

    l_stmt_num := 2;
    --Calling Common Module Log
    opi_dbi_common_mod_init_pkg.run_common_module_init(errbuf,l_ret_code);
    retcode := to_char(l_ret_code);

    -- session parameters
    g_sysdate := SYSDATE;
    g_user_id := nvl(fnd_global.user_id, -1);
    g_login_id := nvl(fnd_global.login_id, -1);
    g_program_id := nvl (fnd_global.conc_program_id, -1);
    g_program_login_id := nvl (fnd_global.conc_login_id, -1);
    g_program_application_id := nvl (fnd_global.prog_appl_id,  -1);
    g_request_id := nvl (fnd_global.conc_request_id, -1);

    l_list(1) := 'BIS_PRIMARY_CURRENCY_CODE';
    l_list(2) := 'BIS_GLOBAL_START_DATE';
    l_list(3) := 'BIS_PRIMARY_RATE_TYPE';

    IF (bis_common_parameters.check_global_parameters(l_list)) THEN

        IF BIS_COLLECTION_UTILITIES.SETUP( 'OPI_DBI_JOBS_F' ) = FALSE THEN
            RAISE_APPLICATION_ERROR(-20000, errbuf);
        END IF;

        l_stmt_num := 8;
        --
        -- bug  3863905 - mv log is now dropped before initial load
        -- we shouldnt be truncating mv log anymore
        --
       IF fnd_installation.get_app_info('OPI', l_status,
                                         l_industry, l_opi_schema) THEN
            execute immediate 'truncate table ' || l_opi_schema ||
                              '.OPI_DBI_JOBS_STG';
            --execute immediate 'truncate table ' || l_opi_schema ||
            --                  '.MLOG$_OPI_DBI_JOBS_F';
            execute immediate 'truncate table ' || l_opi_schema ||
                              '.OPI_DBI_JOBS_F PURGE MATERIALIZED VIEW LOG';
            execute immediate 'truncate table ' || l_opi_schema ||
                              '.OPI_DBI_MUV_CONV_RATES';
       END IF;

        l_stmt_num := 10;
        -- GSD -- already checked if it is set up
        g_global_start_date := bis_common_parameters.get_global_start_date;

	l_stmt_num := 11;
        -- Global currency codes -- already checked if primary is set up
        g_global_currency_code := bis_common_parameters.get_currency_code;
        g_secondary_currency_code :=
                bis_common_parameters.get_secondary_currency_code;

	l_stmt_num := 12;
        -- Global rate types -- already checked if primary is set up
        g_global_rate_type := bis_common_parameters.get_rate_type;
        g_secondary_rate_type := bis_common_parameters.get_secondary_rate_type;

	l_stmt_num := 13;
        -- check that either both the secondary rate type and secondary
        -- rate are null, or that neither are null.
        IF (   (g_secondary_currency_code IS NULL AND
                g_secondary_rate_type IS NOT NULL)
            OR (g_secondary_currency_code IS NOT NULL AND
                g_secondary_rate_type IS NULL) ) THEN

            BIS_COLLECTION_UTILITIES.PUT_LINE ('The global secondary currency code setup is incorrect. The secondary currency code cannot be null when the secondary rate type is defined and vice versa.');

            RAISE_APPLICATION_ERROR(-20000, errbuf);

        END IF;

	--l_stmt_num := 14;
        -- Store current sysdate as the Last Collection Date.
        -- This one for OPI, and a later one for OPM
        --IF (opi_dbi_common_mod_incr_pkg.ETL_REPORT_SUCCESS(4,1) = FALSE) THEN
        --    BIS_COLLECTION_UTILITIES.put_line(
        --    'Failed to store current sysdate as the Last Collection Date.');
        --    RAISE_APPLICATION_ERROR(-20000, errbuf);
        --END IF;

        l_stmt_num :=15;
        OPEN OPI_DBI_RUN_LOG_CURR_CSR;
		FETCH OPI_DBI_RUN_LOG_CURR_CSR INTO l_from_date,l_to_date;

	l_stmt_num :=16;
	IF (OPI_DBI_RUN_LOG_CURR_CSR%NOTFOUND) THEN
	--{
		RAISE NO_DATA_FOUND;
	--}
	END IF;
    	CLOSE OPI_DBI_RUN_LOG_CURR_CSR;

    	l_stmt_num := 17;
	-- get R12 upgrade date
    	OPI_DBI_RPT_UTIL_PKG.get_inv_convergence_date(g_r12_migration_date);

        l_stmt_num := 18;
        /* Insert into Jobs Staging Table */

        /* OPI Jobs master extraction into Jobs Staging Table */
        INSERT /*+ APPEND PARALLEL(f) */
        INTO opi_dbi_jobs_stg f (
            organization_id,
            job_id,
            job_type,
            status,
            completion_date,
            assembly_item_id,
            start_quantity,
            actual_qty_completed,
            uom_code,
            include_job,
            std_req_flag,
            std_res_flag,
            source,
            creation_date,
            last_update_date,
            created_by,
            last_updated_by,
            last_update_login,
            job_name,
            scheduled_completion_date,
	    line_type,
	    job_status_code,
            job_start_value,
            PROGRAM_ID,
	    PROGRAM_LOGIN_ID,
	    PROGRAM_APPLICATION_ID,
	    REQUEST_ID)
        SELECT /*+ parallel(jobs) use_hash(msi) parallel(msi) */
            jobs.organization_id organization_id,
            job_id,
            job_type,
            job_status,
            trunc (completion_date) completion_date,
            assembly_item_id,
            start_quantity,
            actual_qty_completed,
            msi.primary_uom_code uom_code,
            include_job,
            1 std_req_flag,
            decode(job_status_code, 2, 1, 5, 1, 7, 1, 12, 1, 0) std_res_flag,
            1 source,
            g_sysdate creation_date,
            g_sysdate last_update_date,
            g_user_id created_by,
            g_user_id last_updated_by,
            g_login_id last_update_login,
            job_name,
            scheduled_completion_date,
	    line_type,
	    decode(job_type,3,decode (job_status_code,2,12,job_status_code),job_status_code),
            job_start_value,
            g_program_id,
	    g_program_login_id,
	    g_program_application_id,
	    g_request_id
          FROM
            (
             SELECT    /*+ use_hash(en) use_hash(ml1) use_hash(jobsinner)
                           parallel(en) parallel(ml1) parallel(jobsinner) */
                en.organization_id organization_id,
                decode (en.entity_type,
                        2, jobsinner.sch_id,
                        en.wip_entity_id) job_id,
                decode (en.entity_type,
                        2, 2,
                        4, 3,
                        8, 5,
                        5, 5,
                        1) job_type,
                ml1.meaning job_status,
                jobsinner.completion_date,
                en.primary_item_id assembly_item_id,
                jobsinner.start_quantity start_quantity,
                jobsinner.actual_qty_completed actual_qty_completed,
                1 include_job,
                decode(en.entity_type,1,en.wip_entity_name
                                     ,2,jobsinner.sch_id
				     ,3,en.wip_entity_name
				     ,8,en.wip_entity_name
				     ,5,en.wip_entity_name
                                     ,en.wip_entity_id) job_name,
                jobsinner.line_type line_type,
                jobsinner.start_quantity*itemcost.item_cost job_start_value,
                jobsinner.scheduled_completion_date,
                ml1.lookup_code job_status_code
              FROM
                (
                 SELECT /*+ use_hash(di) parallel(di) */
                    null sch_id,
                    nvl (nvl (di.date_closed, di.date_completed),
                         l_to_date) completion_date,
                    di.start_quantity start_quantity,
                    di.quantity_completed actual_qty_completed,
                    di.wip_entity_id wip_entity_id,
                    di.status_type lookup_code,
                    di.organization_id organization_id,
                    di.SCHEDULED_COMPLETION_DATE SCHEDULED_COMPLETION_DATE,
                    1 line_type
                  FROM  wip_discrete_jobs di
                  WHERE di.job_type = 1 AND -- only standard jobs
                        di.status_type in (3,4,5,6,7,12,14,15)   AND
                        --di.scheduled_start_date >= g_global_start_date
                        di.date_released >= g_global_start_date
                 UNION ALL
                 SELECT  /*+ use_hash(re) parallel(re) */
                    re.repetitive_schedule_id     sch_id,
                    nvl (nvl (re.date_closed, re.last_unit_completion_date),
                         l_to_date) completion_date,
                    re.daily_production_rate *
                        re.processing_work_days start_quantity,
                    re.quantity_completed actual_qty_completed,
                    re.wip_entity_id wip_entity_id,
                    re.status_type lookup_code,
                    re.organization_id organization_id,
                    re.last_unit_completion_date SCHEDULED_COMPLETION_DATE,
                    1 line_type
                  FROM  wip_repetitive_schedules re
                  WHERE re.status_type in (3,4,5,6,7,12,14,15) AND
                        --re.first_unit_start_date >= g_global_start_date
                        re.date_released >= g_global_start_date
                 UNION ALL
                 SELECT  /*+ use_hash(fl) parallel(fl) */
                    null sch_id,
                    nvl (nvl (fl.date_closed,fl.scheduled_completion_date),
                         l_to_date) completion_date,
                    fl.planned_quantity  start_quantity,
                    fl.quantity_completed actual_qty_completed,
                    fl.wip_entity_id wip_entity_id,
                    fl.status lookup_code,
                    fl.organization_id  organization_id,
                    fl.SCHEDULED_COMPLETION_DATE SCHEDULED_COMPLETION_DATE,
                    1 line_type
                  FROM  wip_flow_schedules fl
                  WHERE /*fl.status = 2
                    AND */fl.scheduled_start_date >= g_global_start_date
                ) jobsinner,
                wip_entities en,
                CST_ITEM_COSTS itemcost,
                mfg_lookups ml1
                 WHERE   ((en.entity_type in (1,2,3,5,8)
                AND ml1.lookup_type in ('WIP_JOB_STATUS')) OR
                          (en.entity_type in (4)
                AND ml1.lookup_type in ('WIP_FLOW_SCHEDULE_STATUS')))
                AND jobsinner.wip_entity_id = en.wip_entity_id
                AND ml1.lookup_code = jobsinner.lookup_code
                AND jobsinner.organization_id = en.organization_id and
                itemcost.cost_type_id in (1,2,5,6) and
                itemcost.organization_id = en.organization_id and
                itemcost.inventory_item_id = en.primary_item_id
                ) jobs,
            mtl_system_items_b msi
          WHERE msi.inventory_item_id = jobs.assembly_item_id
            AND msi.organization_id = jobs.organization_id;

        l_row_count := sql%rowcount;
        commit;

        BIS_COLLECTION_UTILITIES.PUT_LINE('Finished OPI Jobs Extraction into Staging Table: '|| l_row_count || ' rows inserted');

        -- Store current sysdate as the Last Collection Date.
        -- This one for OPM, and an earlier one for OPI
        --IF (opi_dbi_common_mod_incr_pkg.ETL_REPORT_SUCCESS(4,2) = FALSE) THEN
        --    BIS_COLLECTION_UTILITIES.put_line('Failed to store current sysdate as the Process Manufacturing Last Collection Date.');
        --    RAISE_APPLICATION_ERROR(-20000, errbuf);
        --END IF;

	/********* OPM Insert *********************************/
        INSERT /*+ APPEND PARALLEL(f) */ INTO OPI_DBI_JOBS_STG f
	        (
	        organization_id,
	        job_id,
	        job_type,
	        status,
	        completion_date,
	        assembly_item_id,
	        start_quantity,
	        actual_qty_completed,
	        uom_code,
	        conversion_rate,
	        include_job,
	        std_req_flag,
	        std_res_flag,
	        source,
	        creation_date,
	        last_update_date,
	        created_by,
	        last_updated_by,
	        last_update_login,
	        job_name,
	        line_type,
	        scheduled_completion_date,
	        job_status_code,
	        job_start_value,
	        PROGRAM_ID,
		PROGRAM_LOGIN_ID,
		PROGRAM_APPLICATION_ID,
		REQUEST_ID
	        )
	        SELECT /*+ parallel(dtl) parallel(hdr) */
	            hdr.organization_id organization_id,
	            hdr.batch_id job_id,
	            4 job_type,           /* process job */
	            decode (hdr.batch_status,
	                    4, 'Closed',
	                    3, 'Complete',
			            2, 'Released',
                        -1, 'Cancelled' ) Status,      --Made change for UT2 bug fix 4721820
	            trunc (nvl (hdr.Actual_Cmplt_Date,l_to_date)) Completion_date,
	            dtl.inventory_item_id Assembly_Item_ID,
	            sum (dtl.plan_qty) start_quantity,
	            sum (dtl.actual_qty) actual_qty_completed,
	            dtl.dtl_um           UOM_Code,
	            null conversion_rate,
	            decode (hdr.batch_status, 4, 1, 2) include_job,        /* include closed jobs only */
	            1 std_req_flag,
	            decode (hdr.batch_status, 4, 1, -1, 1, 0) std_res_flag,  -- Made change for bug 4713488
	            case when g_r12_migration_date>hdr.Actual_Cmplt_Date THEN
	            	3
	            	ELSE 2
	            END,
	            g_sysdate creation_date,
	            g_sysdate last_update_date,
	            g_user_id created_by,
	            g_user_id last_updated_by,
	            g_login_id last_update_login,
	            hdr.batch_no  job_name,
	            dtl.line_type line_type,
	            hdr.plan_cmplt_date scheduled_completion_date,
	            decode(hdr.batch_status, 1, 1,
	            			     2, 3,
	            			     3, 4,
	            			     4, 12,
                                 -1, 7) job_status_code,
	            sum (dtl.plan_qty) * OPI_DBI_JOBS_PKG.GET_OPM_ITEM_COST(hdr.organization_id,
  					 dtl.inventory_item_id,
  				         l_to_date) job_start_value,
  		    g_program_id,
		    g_program_login_id,
		    g_program_application_id,
		    g_request_id
	          FROM  gme_material_details dtl,
	                gme_batch_header     hdr
	          WHERE
		        hdr.batch_id       = dtl.batch_id
	            and dtl.line_type      in (1,2)     /* coproducts, by-products */
	            and batch_status       in (2,3,4,-1)        /* wip, completed, closed, cancelled  */
	            and nvl(actual_start_date, g_global_start_date)  >= g_global_start_date
	          GROUP BY
	                hdr.organization_id,
	                hdr.batch_id,
	                hdr.batch_status,
	                hdr.actual_cmplt_date,
	                hdr.plan_cmplt_date,
	                dtl.inventory_item_id,
	                dtl.dtl_um,
	                hdr.batch_no,
	                dtl.line_type,
	                hdr.plan_cmplt_date
        ;

        l_row_count := sql%rowcount;
        commit;

        BIS_COLLECTION_UTILITIES.PUT_LINE(
            'Finished OPM Jobs Extraction into Staging Table: '||
            l_row_count || ' rows inserted');

        l_stmt_num := 20;
        IF (Get_Conversion_Rate (errbuf, retcode) = -1) THEN
            BIS_COLLECTION_UTILITIES.put_line('Missing currency rate.');
            BIS_COLLECTION_UTILITIES.put_line('Please run this concurrent program again after fixing the missing currency rates.');
            retcode := g_error;
            return;
        END IF;

        l_stmt_num := 30;
        /* Once Conversion Rates process finishes successfully,
           Merge Conversion Rates and Jobs Staging table into Jobs Fact */
        l_row_count := Insert_into_Jobs_Fact;
        BIS_COLLECTION_UTILITIES.PUT_LINE(
            'Finished Jobs Extraction into Fact Table: '||
            l_row_count || ' rows inserted');


         l_stmt_num := 35;
	 --Store current sysdate as the Last Collection Date.
	 --This one for OPI, and a later one for OPM
	 IF (opi_dbi_common_mod_incr_pkg.ETL_REPORT_SUCCESS(4,1) = FALSE) THEN
	     BIS_COLLECTION_UTILITIES.put_line(
	    'Failed to store current sysdate as the Last Collection Date.');
	     RAISE_APPLICATION_ERROR(-20000, errbuf);
         END IF;

	 l_stmt_num := 40;
         -- Store current sysdate as the Last Collection Date.
	 -- This one for OPM, and an earlier one for OPI
	 IF (opi_dbi_common_mod_incr_pkg.ETL_REPORT_SUCCESS(4,2) = FALSE) THEN
	     BIS_COLLECTION_UTILITIES.put_line('Failed to store current sysdate as the Process Manufacturing Last Collection Date.');
	     RAISE_APPLICATION_ERROR(-20000, errbuf);
         END IF;

        BIS_COLLECTION_UTILITIES.WRAPUP(
            p_status => TRUE,
            p_count => l_row_count,
            p_message => 'Successfully loaded Jobs master table at ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')
        );

        BIS_COLLECTION_UTILITIES.PUT_LINE('Exiting Procedure '|| l_proc_name);

    ELSE
        retcode := g_error;
        BIS_COLLECTION_UTILITIES.PUT_LINE('Global Parameters are not setup.');
        BIS_COLLECTION_UTILITIES.PUT_LINE('Please check that the profile options: BIS_PRIMARY_CURRENCY_CODE, BIS_PRIMARY_RATE_TYPE and BIS_GLOBAL_START_DATE are setup.');
        BIS_COLLECTION_UTILITIES.PUT_LINE('Exiting Procedure '|| l_proc_name);

    END IF;

EXCEPTION

    WHEN OTHERS THEN
        rollback;

        l_err_num := SQLCODE;
        l_err_msg := 'OPI_DBI_JOBS_PKG.GET_JOBS_INITIAL_LOAD ('
                        || to_char(l_stmt_num)
                        || '): '
                        || substr(SQLERRM, 1,200);
        BIS_COLLECTION_UTILITIES.PUT_LINE('OPI_DBI_JOBS_PKG.GET_JOBS_INITIAL_LOAD - Error at statement ('
                        || to_char(l_stmt_num)
                        || ')');
        BIS_COLLECTION_UTILITIES.PUT_LINE('Error Number: ' ||  to_char(l_err_num));
        BIS_COLLECTION_UTILITIES.PUT_LINE('Error Message: ' || l_err_msg);
        BIS_COLLECTION_UTILITIES.WRAPUP(FALSE,
                                        l_row_count,
                                        'EXCEPTION '|| l_err_num||' : '||l_err_msg
                                  );
        retcode := SQLCODE;
        errbuf := SQLERRM;
        RAISE_APPLICATION_ERROR(-20000, errbuf);
        /*please note that this api will commit!!*/

END GET_JOBS_INITIAL_LOAD;



PROCEDURE GET_OPI_JOBS_INCR_LOAD(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
 l_stmt_num NUMBER;
 l_row_count NUMBER;
 l_err_num NUMBER;
 l_err_msg VARCHAR2(255);

 l_from_date OPI.OPI_DBI_RUN_LOG_CURR.FROM_BOUND_DATE%TYPE;
 l_to_date OPI.OPI_DBI_RUN_LOG_CURR.FROM_BOUND_DATE%TYPE;

 CURSOR OPI_DBI_RUN_LOG_CURR_CSR IS
 select
 	from_bound_date,
      	to_bound_date
 from
      	OPI_DBI_RUN_LOG_CURR
 where
      	ETL_ID = 4 and
 	source = 2;

BEGIN

 -- session parameters
 g_sysdate := SYSDATE;
 g_user_id := nvl(fnd_global.user_id, -1);
 g_login_id := nvl(fnd_global.login_id, -1);
 g_program_id := nvl (fnd_global.conc_program_id, -1);
 g_program_login_id := nvl (fnd_global.conc_login_id, -1);
 g_program_application_id := nvl (fnd_global.prog_appl_id,  -1);
 g_request_id := nvl (fnd_global.conc_request_id, -1);

 l_stmt_num :=3;
 OPEN OPI_DBI_RUN_LOG_CURR_CSR;
 FETCH OPI_DBI_RUN_LOG_CURR_CSR INTO l_from_date,l_to_date;

 l_stmt_num :=7;
 IF (OPI_DBI_RUN_LOG_CURR_CSR%NOTFOUND) THEN
 --{
	RAISE NO_DATA_FOUND;
 --}
 END IF;
 CLOSE OPI_DBI_RUN_LOG_CURR_CSR;

 /* Insert into Jobs Staging Table */

 l_stmt_num := 10;
 /* OPI Jobs master extraction into Jobs Staging Table */

 MERGE INTO OPI_DBI_JOBS_STG f USING
 (
 Select
  JOBS.ORGANIZATION_ID,
  JOB_ID,
  JOB_TYPE,
  STATUS,
  TRUNC(COMPLETION_DATE) COMPLETION_DATE,
  Assembly_Item_id,
  START_QUANTITY,
  ACTUAL_QTY_COMPLETED,
  MSI.PRIMARY_UOM_CODE UOM_Code,
  INCLUDE_JOB,
  1 Std_Req_Flag,
  1 Std_Res_Flag,
  1 SOURCE,
  g_sysdate  CREATION_DATE,
  g_sysdate  LAST_UPDATE_DATE,
  g_user_id  CREATED_BY,
  g_user_id  LAST_UPDATED_BY,
  g_login_id LAST_UPDATE_LOGIN,
  job_name   JOB_NAME,
  jobs.line_type LINE_TYPE,
  jobs.scheduled_completion_date SCHEDULED_COMPLETION_DATE,
  jobs.job_status_code,
  jobs.start_quantity*itemcost.item_cost JOB_START_VALUE,
  g_program_id PROGRAM_ID,
  g_program_login_id PROGRAM_LOGIN_ID,
  g_program_application_id PROGRAM_APPLICATION_ID,
  g_request_id REQUEST_ID
 FROM
 (
 SELECT
  EN.ORGANIZATION_ID ORGANIZATION_ID,
  EN.WIP_ENTITY_ID JOB_ID,
  decode(en.entity_type,8,5,5,5,1) JOB_TYPE,
  ML1.MEANING STATUS,
  DI.STATUS_TYPE JOB_STATUS_CODE,
  NVL(NVL(DI.DATE_CLOSED,DI.date_completed),l_to_date) COMPLETION_DATE,
  EN.PRIMARY_ITEM_ID Assembly_Item_id,
  DI.START_QUANTITY START_QUANTITY,
  DI.QUANTITY_COMPLETED ACTUAL_QTY_COMPLETED,
  1 INCLUDE_JOB,
  DI.LAST_UPDATE_DATE,
  EN.WIP_ENTITY_NAME JOB_NAME,
  1 line_type,
  DI.SCHEDULED_COMPLETION_DATE SCHEDULED_COMPLETION_DATE
 FROM WIP_ENTITIES EN, WIP_DISCRETE_JOBS DI, MFG_LOOKUPS ML1
 WHERE
   DI.WIP_ENTITY_ID = EN.WIP_ENTITY_ID AND DI.ORGANIZATION_ID = EN.ORGANIZATION_ID AND
   DI.JOB_TYPE = 1 AND  -- Only Standard Jobs
   EN.ENTITY_TYPE IN (1,3,5,8) AND  -- Discrete jobs and Closed discrete jobs
   ML1.LOOKUP_TYPE = 'WIP_JOB_STATUS' AND ML1.LOOKUP_CODE = DI.STATUS_TYPE AND
   --DI.SCHEDULED_START_DATE >= g_global_start_date
   DI.date_released >= g_global_start_date
 UNION ALL
 SELECT
  EN.ORGANIZATION_ID        ORGANIZATION_ID,
  RE.REPETITIVE_SCHEDULE_ID     JOB_ID,
  2 JOB_TYPE,
  ML1.MEANING JOB_STATUS,
  RE.STATUS_TYPE JOB_STATUS_CODE,
  NVL(NVL(RE.DATE_CLOSED,RE.last_unit_completion_date), l_to_date) COMPLETION_DATE,
  EN.PRIMARY_ITEM_ID Assembly_Item_id,
  RE.DAILY_PRODUCTION_RATE * RE.PROCESSING_WORK_DAYS START_QUANTITY,
  RE.QUANTITY_COMPLETED ACTUAL_QTY_COMPLETED,
  1 INCLUDE_JOB,
  RE.LAST_UPDATE_DATE,
  to_char(RE.REPETITIVE_SCHEDULE_ID) JOB_NAME,
  1 line_type,
  RE.last_unit_completion_date SCHEDULED_COMPLETION_DATE
 FROM
   WIP_ENTITIES EN, WIP_REPETITIVE_SCHEDULES RE, MFG_LOOKUPS ML1
 WHERE
  RE.WIP_ENTITY_ID = EN.WIP_ENTITY_ID AND RE.ORGANIZATION_ID = EN.ORGANIZATION_ID AND
  EN.ENTITY_TYPE = 2 AND -- Repetitive Schedules
  ML1.LOOKUP_TYPE = 'WIP_JOB_STATUS' AND ML1.LOOKUP_CODE = RE.STATUS_TYPE AND
  --RE.FIRST_UNIT_START_DATE >= g_global_start_date
  re.date_released >= g_global_start_date
 UNION ALL
 SELECT
  EN.ORGANIZATION_ID ORGANIZATION_ID,
  EN.WIP_ENTITY_ID JOB_ID,
  3 JOB_TYPE,
  ML1.MEANING JOB_STATUS,
  decode(FL.STATUS,2,12,FL.STATUS) JOB_STATUS_CODE,
  NVL(NVL(FL.DATE_CLOSED,FL.scheduled_completion_date), l_to_date) COMPLETION_DATE,
  EN.PRIMARY_ITEM_ID Assembly_Item_id,
  FL.PLANNED_QUANTITY  START_QUANTITY,
  FL.QUANTITY_COMPLETED ACTUAL_QTY_COMPLETED,
  1 INCLUDE_JOB,
  FL.LAST_UPDATE_DATE,
  to_char(EN.WIP_ENTITY_ID) JOB_NAME,
  1 line_type,
  FL.SCHEDULED_COMPLETION_DATE  SCHEDULED_COMPLETION_DATE
 FROM
  WIP_ENTITIES EN, WIP_FLOW_SCHEDULES FL, MFG_LOOKUPS ML1
 WHERE
  FL.WIP_ENTITY_ID = EN.WIP_ENTITY_ID AND FL.ORGANIZATION_ID = EN.ORGANIZATION_ID AND
  EN.ENTITY_TYPE = 4 AND -- Flow Schedules
  ML1.LOOKUP_TYPE = 'WIP_FLOW_SCHEDULE_STATUS' AND ML1.LOOKUP_CODE = FL.STATUS AND
  FL.SCHEDULED_START_DATE >= g_global_start_date
 ) JOBS,
 MTL_SYSTEM_ITEMS_B MSI,
 CST_ITEM_COSTS itemcost
 WHERE
  MSI.INVENTORY_ITEM_ID = JOBS.Assembly_Item_id AND
 MSI.ORGANIZATION_ID = JOBS.ORGANIZATION_ID AND
 itemcost.cost_type_id in (1,2,5,6) and
 itemcost.organization_id = jobs.organization_id and
 itemcost.inventory_item_id = jobs.Assembly_Item_id and
 ((NOT EXISTS (SELECT 'X' FROM OPI_DBI_JOBS_F WHERE JOB_ID = JOBS.JOB_ID AND JOB_TYPE = JOBS.JOB_TYPE)
               AND JOBS.JOB_STATUS_CODE IN (1,2,3,4,5,6,7,12,14,15)
  ) -- New jobs in any of the 3 statuses considered: Closed, Complete - No Charges, Cancelled
  OR (EXISTS (SELECT 'X' FROM OPI_DBI_JOBS_F WHERE JOB_ID = JOBS.JOB_ID AND JOB_TYPE = JOBS.JOB_TYPE) AND JOBS.LAST_UPDATE_DATE > g_last_collection_date)  ) -- Jobs in Jobs Master that have been updated
 ) s
 ON (f.Organization_id      = s.Organization_id
     and f.Job_id           = s.Job_id
     and f.Job_Type         = s.Job_Type
     and f.Assembly_Item_id = s.Assembly_Item_id)
 WHEN MATCHED THEN
     UPDATE SET
     f.Status = s.Status
    ,f.Completion_date = s.Completion_date
    ,f.Start_Quantity = s.Start_Quantity
    ,f.Actual_Qty_Completed = s.Actual_Qty_Completed
    ,f.UOM_Code = s.UOM_Code
    ,f.Include_Job = s.Include_Job
    ,f.Std_Req_Flag = s.Std_Req_Flag
    ,f.Std_Res_Flag = s.Std_Res_Flag
    ,f.Last_Update_Date = s.Last_Update_Date
    ,f.Last_Updated_By = s.Last_Updated_By
    ,f.Last_Update_Login = s.Last_Update_Login
    ,f.job_name = s.job_name
    ,f.line_type = s.line_type
    ,f.scheduled_completion_date = s.scheduled_completion_date
    ,f.job_status_code = s.job_status_code
    ,f.job_start_value = s.job_start_value
 WHEN NOT MATCHED THEN
     INSERT (ORGANIZATION_ID, JOB_ID, JOB_TYPE, STATUS, COMPLETION_DATE, Assembly_Item_id,
             START_QUANTITY, ACTUAL_QTY_COMPLETED, UOM_Code, CONVERSION_RATE, INCLUDE_JOB, Std_Req_Flag, Std_Res_Flag, SOURCE,
             CREATION_DATE, LAST_UPDATE_DATE, CREATED_BY, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, JOB_NAME,
             LINE_TYPE, SCHEDULED_COMPLETION_DATE, JOB_STATUS_CODE, JOB_START_VALUE,
             PROGRAM_ID,PROGRAM_LOGIN_ID,PROGRAM_APPLICATION_ID,REQUEST_ID)
     VALUES (s.ORGANIZATION_ID, s.JOB_ID, s.JOB_TYPE, s.STATUS, s.COMPLETION_DATE, s.Assembly_Item_id,
             s.START_QUANTITY, s.ACTUAL_QTY_COMPLETED, s.UOM_Code, null, s.INCLUDE_JOB, s.Std_Req_Flag, s.Std_Res_Flag, s.SOURCE,
             s.CREATION_DATE, s.LAST_UPDATE_DATE, s.CREATED_BY, s.LAST_UPDATED_BY, s.LAST_UPDATE_LOGIN, S.JOB_NAME,
             s.LINE_TYPE, S.SCHEDULED_COMPLETION_DATE, S.JOB_STATUS_CODE, S.JOB_START_VALUE,
             s.PROGRAM_ID,s.PROGRAM_LOGIN_ID,s.PROGRAM_APPLICATION_ID,s.REQUEST_ID);

 l_row_count := sql%rowcount;
 commit;

 BIS_COLLECTION_UTILITIES.PUT_LINE('Finished OPI Jobs Extraction into Staging Table: '|| l_row_count || ' rows inserted');


EXCEPTION
 WHEN OTHERS THEN
   rollback;

   l_err_num := SQLCODE;
   l_err_msg := 'OPI_DBI_JOBS_PKG.GET_OPI_JOBS_INCR_LOAD ('
                    || to_char(l_stmt_num)
                    || '): '
                    || substr(SQLERRM, 1,200);
   BIS_COLLECTION_UTILITIES.PUT_LINE('OPI_DBI_JOBS_PKG.GET_OPI_JOBS_INCR_LOAD - Error at statement ('
                    || to_char(l_stmt_num)
                    || ')');
   BIS_COLLECTION_UTILITIES.PUT_LINE('Error Number: ' ||  to_char(l_err_num));
   BIS_COLLECTION_UTILITIES.PUT_LINE('Error Message: ' || l_err_msg);
   BIS_COLLECTION_UTILITIES.WRAPUP( FALSE, l_row_count, 'EXCEPTION '|| l_err_num||' : '||l_err_msg );

   retcode := SQLCODE;
   errbuf := SQLERRM;

END GET_OPI_JOBS_INCR_LOAD;



PROCEDURE GET_OPM_JOBS_INCR_LOAD(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
 l_stmt_num NUMBER;
 l_row_count NUMBER;
 l_err_num NUMBER;
 l_err_msg VARCHAR2(255);

 l_from_date OPI.OPI_DBI_RUN_LOG_CURR.FROM_BOUND_DATE%TYPE;
 l_to_date OPI.OPI_DBI_RUN_LOG_CURR.FROM_BOUND_DATE%TYPE;

 CURSOR OPI_DBI_RUN_LOG_CURR_CSR IS
 select
  from_bound_date,
  to_bound_date
 from
  OPI_DBI_RUN_LOG_CURR
 where
  ETL_ID = 4 and
  source = 2;

BEGIN

 l_stmt_num :=3;
 OPEN OPI_DBI_RUN_LOG_CURR_CSR;
 FETCH OPI_DBI_RUN_LOG_CURR_CSR INTO l_from_date,l_to_date;

 l_stmt_num :=7;
 IF (OPI_DBI_RUN_LOG_CURR_CSR%NOTFOUND) THEN
 --{
	RAISE NO_DATA_FOUND;
 --}
 END IF;
 CLOSE OPI_DBI_RUN_LOG_CURR_CSR;

 l_stmt_num := 10;

MERGE INTO OPI_DBI_JOBS_STG f USING
 (
  select
  hdr.organization_id                              Organization_id,
  hdr.batch_id                                          Job_id,
  4                                                     Job_Type,           /* Process Job */
  Decode(hdr.batch_status, 4, 'Closed',
                           3, 'Complete',
			               2, 'Released',
                          -1, 'Cancelled')    Status,    --Change made for UT2 bug # 4723975
  trunc(nvl(hdr.Actual_Cmplt_Date,l_to_date))           Completion_date,
  dtl.inventory_item_id                                 Assembly_Item_ID,
  SUM(dtl.plan_qty)                                     Start_Quantity,
  SUM(dtl.actual_qty)                                   Actual_Qty_Completed,
  dtl.dtl_um                                            UOM_Code,
  NULL                                                  Conversion_Rate,
  Decode(hdr.batch_status, 4, 1, 2)                     Include_Job,        /* include closed jobs only */
  1                                                     Std_Req_Flag,
  decode (hdr.batch_status, 4, 1, -1, 1, 0)             Std_Res_Flag,
  2                                                     Source,             /* OPM */
  g_Sysdate                                             Creation_Date,
  g_Sysdate                                             Last_Update_Date,
  g_user_id                                             Created_By,
  g_user_id                                             Last_Updated_By,
  g_login_id                                            Last_Update_Login,
  hdr.batch_no                                          JOB_NAME,
  dtl.line_type 					line_type,
  hdr.plan_cmplt_date 					scheduled_completion_date,
  decode(hdr.batch_status, 1, 1,
                  	   2, 3,
  	            	   3, 4,
  	            	   4, 12,
                       -1, 7) 			job_status_code,
  sum (dtl.plan_qty*GET_OPM_ITEM_COST(hdr.organization_id,
  					 dtl.inventory_item_id,
  					 l_to_date) )job_start_value,
  g_program_id PROGRAM_ID,
  g_program_login_id PROGRAM_LOGIN_ID,
  g_program_application_id PROGRAM_APPLICATION_ID,
  g_request_id REQUEST_ID
 from gme_material_details dtl,
      gme_batch_header     hdr
 where hdr.batch_id       = dtl.batch_id
   and dtl.line_type      in (1,2)                      /* coproducts  and by-products*/
   and nvl(ACTUAL_START_DATE, g_global_start_date)  >= g_global_start_date
   and
   (    (NOT EXISTS (SELECT 'X' FROM OPI_DBI_JOBS_F WHERE JOB_ID = hdr.batch_ID AND JOB_TYPE = 4)
         and hdr.batch_status in (2,3,4,-1)  /* wip, completed, closed, cancelled */
  )
  OR   (EXISTS (SELECT 'X' FROM OPI_DBI_JOBS_F WHERE JOB_ID = hdr.batch_ID AND JOB_TYPE = 4)
       AND hdr.LAST_UPDATE_DATE > g_opm_last_collection_date)  ) -- Jobs in Jobs Master that have been updated
 group by
  hdr.organization_id,
  hdr.batch_id,
  hdr.batch_status,
  hdr.Actual_Cmplt_Date,
  dtl.inventory_item_id,
  dtl.dtl_um,
  hdr.batch_no,
  dtl.line_type,
  hdr.plan_cmplt_date
 ) s
 ON (f.Organization_id      = s.Organization_id
     and f.Job_id           = s.Job_id
     and f.Job_Type         = s.Job_Type
     and f.Assembly_Item_id = s.Assembly_Item_id)
 WHEN MATCHED THEN
     UPDATE SET
     f.Status = s.Status
    ,f.Completion_date = s.Completion_date
    ,f.Start_Quantity = s.Start_Quantity
    ,f.Actual_Qty_Completed = s.Actual_Qty_Completed
    ,f.UOM_Code = s.UOM_Code
    ,f.Include_Job = s.Include_Job
    ,f.Std_Req_Flag = s.Std_Req_Flag
    ,f.Std_Res_Flag = s.Std_Res_Flag
    ,f.Last_Update_Date = s.Last_Update_Date
    ,f.Last_Updated_By = s.Last_Updated_By
    ,f.Last_Update_Login = s.Last_Update_Login
    ,f.job_name = s.job_name
    ,f.line_type = s.line_type
    ,f.scheduled_completion_date = s.scheduled_completion_date
    ,f.job_status_code = s.job_status_code
    ,f.job_start_value = s.job_start_value
 WHEN NOT MATCHED THEN
     INSERT (ORGANIZATION_ID, JOB_ID, JOB_TYPE, STATUS, COMPLETION_DATE, Assembly_Item_id,
             START_QUANTITY, ACTUAL_QTY_COMPLETED, UOM_Code, CONVERSION_RATE, INCLUDE_JOB, Std_Req_Flag, Std_Res_Flag, SOURCE,
             CREATION_DATE, LAST_UPDATE_DATE, CREATED_BY, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, JOB_NAME, LINE_TYPE, SCHEDULED_COMPLETION_DATE,
             JOB_STATUS_CODE, JOB_START_VALUE, PROGRAM_ID, PROGRAM_LOGIN_ID, PROGRAM_APPLICATION_ID, REQUEST_ID)
     VALUES (s.ORGANIZATION_ID, s.JOB_ID, s.JOB_TYPE, s.STATUS, s.COMPLETION_DATE, s.Assembly_Item_id,
             s.START_QUANTITY, s.ACTUAL_QTY_COMPLETED, s.UOM_Code, null, s.INCLUDE_JOB, s.Std_Req_Flag, s.Std_Res_Flag, s.SOURCE,
             s.CREATION_DATE, s.LAST_UPDATE_DATE, s.CREATED_BY, s.LAST_UPDATED_BY, s.LAST_UPDATE_LOGIN, s.JOB_NAME, s.LINE_TYPE, s.SCHEDULED_COMPLETION_DATE,
             s.JOB_STATUS_CODE, s.JOB_START_VALUE,s.PROGRAM_ID,s.PROGRAM_LOGIN_ID,s.PROGRAM_APPLICATION_ID,s.REQUEST_ID);

 l_row_count := sql%rowcount;
 commit;

 BIS_COLLECTION_UTILITIES.PUT_LINE('Finished OPM Jobs Extraction into Staging Table: '|| l_row_count || ' rows inserted');

EXCEPTION
 WHEN OTHERS THEN
   rollback;

   l_err_num := SQLCODE;
   l_err_msg := 'OPI_DBI_JOBS_PKG.GET_OPM_JOBS_INCR_LOAD ('
                    || to_char(l_stmt_num)
                    || '): '
                    || substr(SQLERRM, 1,200);
   BIS_COLLECTION_UTILITIES.PUT_LINE('OPI_DBI_JOBS_PKG.GET_OPM_JOBS_INCR_LOAD - Error at statement ('
                    || to_char(l_stmt_num)
                    || ')');
   BIS_COLLECTION_UTILITIES.PUT_LINE('Error Number: ' ||  to_char(l_err_num));
   BIS_COLLECTION_UTILITIES.PUT_LINE('Error Message: ' || l_err_msg);
   BIS_COLLECTION_UTILITIES.WRAPUP( FALSE, l_row_count, 'EXCEPTION '|| l_err_num||' : '||l_err_msg );

   retcode := SQLCODE;
   errbuf := SQLERRM;

END GET_OPM_JOBS_INCR_LOAD;



PROCEDURE GET_JOBS_INCR_LOAD (errbuf in out NOCOPY varchar2,
                              retcode in out NOCOPY varchar2)
IS
    l_stmt_num NUMBER;
    l_row_count NUMBER;
    l_err_num NUMBER;
    l_ret_code NUMBER;
    l_err_msg VARCHAR2(255);
    l_proc_name VARCHAR2(255);
    l_opi_schema      VARCHAR2(30);
    l_status          VARCHAR2(30);
    l_industry        VARCHAR2(30);
    l_list dbms_sql.varchar2_table;
BEGIN

    l_proc_name := 'OPI_DBI_JOBS_PKG.GET_JOBS_INCR_LOAD';
    BIS_COLLECTION_UTILITIES.PUT_LINE('Entering Procedure '|| l_proc_name);

    l_stmt_num := 2;
    --Calling Common Module Log
    opi_dbi_common_mod_incr_pkg.run_common_module_incr(errbuf,l_ret_code);
    retcode := to_char(l_ret_code);

    -- session parameters
    g_sysdate := SYSDATE;
    g_user_id := nvl(fnd_global.user_id, -1);
    g_login_id := nvl(fnd_global.login_id, -1);

    l_list(1) := 'BIS_PRIMARY_CURRENCY_CODE';
    l_list(2) := 'BIS_GLOBAL_START_DATE';
    l_list(3) := 'BIS_PRIMARY_RATE_TYPE';

    IF (bis_common_parameters.check_global_parameters(l_list)) THEN

        IF BIS_COLLECTION_UTILITIES.SETUP( 'OPI_DBI_JOBS_F' ) = false then
            RAISE_APPLICATION_ERROR(-20000, errbuf);
        END IF;

        l_stmt_num := 10;
        -- GSD -- already checked if it is set up
        g_global_start_date := bis_common_parameters.get_global_start_date;

        -- Global currency codes -- already checked if primary is set up
        g_global_currency_code := bis_common_parameters.get_currency_code;
        g_secondary_currency_code :=
                bis_common_parameters.get_secondary_currency_code;

        -- Global rate types -- already checked if primary is set up
        g_global_rate_type := bis_common_parameters.get_rate_type;
        g_secondary_rate_type := bis_common_parameters.get_secondary_rate_type;

        -- check that either both the secondary rate type and secondary
        -- rate are null, or that neither are null.
        IF (   (g_secondary_currency_code IS NULL AND
                g_secondary_rate_type IS NOT NULL)
            OR (g_secondary_currency_code IS NOT NULL AND
                g_secondary_rate_type IS NULL) ) THEN

            BIS_COLLECTION_UTILITIES.PUT_LINE ('The global secondary currency code setup is incorrect. The secondary currency code cannot be null when the secondary rate type is defined and vice versa.');

            RAISE_APPLICATION_ERROR(-20000, errbuf);

        END IF;

        l_stmt_num := 20;
        BEGIN
            SELECT LAST_COLLECTION_DATE INTO g_last_collection_date FROM OPI_DBI_RUN_LOG_CURR
            WHERE ETL_ID = 4 AND SOURCE = 1;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                BIS_COLLECTION_UTILITIES.put_line('Last collection date is not available. Cannot proceed.');
                BIS_COLLECTION_UTILITIES.put_line(SQLERRM);
                retcode := SQLCODE;
                errbuf := SQLERRM;
                return;
        END;

        --l_stmt_num := 30;
        -- Store current sysdate as the Last Collection Date.
        -- This one for OPI, and a later one for OPM
        --IF (opi_dbi_common_mod_incr_pkg.ETL_REPORT_SUCCESS(4,1) = FALSE) THEN
        --    BIS_COLLECTION_UTILITIES.put_line('Failed to store current sysdate as the Last Collection Date.');
        --    RAISE_APPLICATION_ERROR(-20000, errbuf);
        --END IF;

        l_stmt_num := 35;
        IF fnd_installation.get_app_info ('OPI', l_status,
                                        l_industry, l_opi_schema) THEN
            execute immediate 'truncate table ' || l_opi_schema ||
                              '.OPI_DBI_MUV_CONV_RATES';

            execute immediate 'truncate table ' || l_opi_schema ||
	                      '.OPI_DBI_JOBS_STG';
        END IF;

        l_stmt_num := 40;
        GET_OPI_JOBS_INCR_LOAD(errbuf, retcode);

        l_stmt_num := 45;

        BEGIN
            SELECT LAST_COLLECTION_DATE INTO g_opm_last_collection_date FROM OPI_DBI_RUN_LOG_CURR
            WHERE ETL_ID = 4 AND SOURCE = 2;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                BIS_COLLECTION_UTILITIES.put_line('Process Manufacturing Last collection date is not available. Cannot proceed.');
                BIS_COLLECTION_UTILITIES.put_line(SQLERRM);
                retcode := SQLCODE;
                errbuf := SQLERRM;
                return;
        END;

        --l_stmt_num := 47;
        -- Store current sysdate as the Last Collection Date.
        -- This one for OPM, and an earlier one for OPI
        --IF (opi_dbi_common_mod_incr_pkg.ETL_REPORT_SUCCESS(4,2) = FALSE) THEN
        --    BIS_COLLECTION_UTILITIES.put_line('Failed to store current sysdate as the Process Manufacturing Last Collection Date.');
        --    RAISE_APPLICATION_ERROR(-20000, errbuf);
        --END IF;

        GET_OPM_JOBS_INCR_LOAD(errbuf, retcode);


        l_stmt_num := 50;
        IF (Get_Conversion_Rate (errbuf, retcode) = -1) THEN
            BIS_COLLECTION_UTILITIES.put_line('Missing currency rate.');
            BIS_COLLECTION_UTILITIES.put_line('Please run this concurrent program again after fixing the missing currency rates.');
            retcode := g_error;
            return;
        END IF;


        l_stmt_num := 60;
        /*  Once Conversion Rates process finishes successfully,
            Merge Conversion Rates and Jobs Staging table into Jobs Fact */
        l_row_count := Merge_into_Jobs_Fact;
        BIS_COLLECTION_UTILITIES.PUT_LINE(
            'Finished Jobs Extraction into Fact Table: '||
            l_row_count || ' rows inserted/updated');

        l_stmt_num := 65;
	-- Store current sysdate as the Last Collection Date.
	-- This one for OPI, and a later one for OPM
	IF (opi_dbi_common_mod_incr_pkg.ETL_REPORT_SUCCESS(4,1) = FALSE) THEN
	    BIS_COLLECTION_UTILITIES.put_line('Failed to store current sysdate as the Last Collection Date.');
	    RAISE_APPLICATION_ERROR(-20000, errbuf);
        END IF;

        l_stmt_num := 70;
	-- Store current sysdate as the Last Collection Date.
	-- This one for OPM, and an earlier one for OPI
	IF (opi_dbi_common_mod_incr_pkg.ETL_REPORT_SUCCESS(4,2) = FALSE) THEN
	    BIS_COLLECTION_UTILITIES.put_line('Failed to store current sysdate as the Process Manufacturing Last Collection Date.');
	    RAISE_APPLICATION_ERROR(-20000, errbuf);
        END IF;

        BIS_COLLECTION_UTILITIES.WRAPUP(
            p_status => TRUE,
            p_count => l_row_count,
            p_message => 'Successfully loaded Jobs master table at ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')
        );

        BIS_COLLECTION_UTILITIES.PUT_LINE('Exiting Procedure '|| l_proc_name);

    ELSE
        retcode := g_error;
        BIS_COLLECTION_UTILITIES.PUT_LINE('Global Parameters are not setup.');
        BIS_COLLECTION_UTILITIES.PUT_LINE('Please check that the profile options: BIS_PRIMARY_CURRENCY_CODE and BIS_GLOBAL_START_DATE are setup.');
        BIS_COLLECTION_UTILITIES.PUT_LINE('Exiting Procedure '|| l_proc_name);

    END IF;

EXCEPTION
    WHEN OTHERS THEN
        rollback;

        l_err_num := SQLCODE;
        l_err_msg := 'OPI_DBI_JOBS_PKG.GET_JOBS_INCR_LOAD ('
                        || to_char(l_stmt_num)
                        || '): '
                        || substr(SQLERRM, 1,200);
        BIS_COLLECTION_UTILITIES.PUT_LINE('OPI_DBI_JOBS_PKG.GET_JOBS_INCR_LOAD - Error at statement ('
                        || to_char(l_stmt_num)
                        || ')');
        BIS_COLLECTION_UTILITIES.PUT_LINE('Error Number: ' ||  to_char(l_err_num));
        BIS_COLLECTION_UTILITIES.PUT_LINE('Error Message: ' || l_err_msg);
        BIS_COLLECTION_UTILITIES.WRAPUP( FALSE, l_row_count, 'EXCEPTION '|| l_err_num||' : '||l_err_msg );

        retcode := SQLCODE;
        errbuf := SQLERRM;
        RAISE_APPLICATION_ERROR(-20000, errbuf);

END GET_JOBS_INCR_LOAD;

/*
  Function that is a wrapper around the GMF Cost API.

  Parameters:
    l_organization_id - Organization id
    l_inventory_item_id - inventory item id
    l_txn_date - date

  retruns unit cost

*/

FUNCTION GET_OPM_ITEM_COST( l_organization_id NUMBER,
			    l_inventory_item_id NUMBER,
			    l_txn_date DATE)
RETURN NUMBER
IS
x_total_cost NUMBER;
x_return_status VARCHAR2(1);
x_msg_count NUMBER;
x_msg_data VARCHAR2(2000);
x_cost_method cm_mthd_mst.cost_mthd_code%TYPE;
x_cost_component_class_id cm_cmpt_mst.cost_cmpntcls_id%TYPE;
x_cost_analysis_code cm_alys_mst.cost_analysis_code%TYPE;
x_no_of_rows NUMBER;
l_ret_value NUMBER;

BEGIN

	l_ret_value := GMF_CMCOMMON.Get_Process_Item_Cost
	   (
	     1.0
	   , FND_API.G_TRUE
	   , x_return_status
	   , x_msg_count
	   , x_msg_data
	   , l_inventory_item_id
	   , l_organization_id
	   , l_txn_date
	   , 1
	   , x_cost_method
	   , x_cost_component_class_id
	   , x_cost_analysis_code
	   , x_total_cost
	   , x_no_of_rows
	   );

	IF l_ret_value <> 1
	THEN
		return -1;
	ELSE
		return x_total_cost;
	END IF;

END GET_OPM_ITEM_COST;

FUNCTION GET_ODM_ITEM_COST(l_organization_id NUMBER,
			   l_inventory_item_id NUMBER)
RETURN NUMBER
IS
x_cost NUMBER := 0;

BEGIN
	select
		item_cost into x_cost
	from
		cst_item_costs
	where
		organization_id = l_organization_id and
		inventory_item_id = l_inventory_item_id and
		cost_type_id in (1,2,5,6);

	return x_cost;

EXCEPTION
	WHEN OTHERS THEN
		return x_cost;

END GET_ODM_ITEM_COST;


PROCEDURE REFRESH_MV(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
  l_stmt_num NUMBER;
  l_err_num NUMBER;
  l_err_msg VARCHAR2(255);
BEGIN

  l_stmt_num := 10;
  /* Refresh MV over Jobs fact */

  dbms_mview.refresh('OPI_CURR_PROD_DEL_001_MV',
                     'C',
                     '',        -- ROLLBACK_SEG
                     TRUE,      -- PUSH_DEFERRED_RPC
                     FALSE,     -- REFRESH_AFTER_ERRORS
                     0,         -- PURGE_OPTION
                     1,  -- PARALLELISM
                     0,         -- HEAP_SIZE
                     FALSE      -- ATOMIC_REFRESH
                    );

  BIS_COLLECTION_UTILITIES.PUT_LINE('MV over Jobs Fact Refresh finished ...');

 EXCEPTION
  WHEN OTHERS THEN

    l_err_num := SQLCODE;
    l_err_msg := 'OPI_DBI_JOBS_PKG.REFRESH_MV ('
                     || to_char(l_stmt_num)
                     || '): '
                     || substr(SQLERRM, 1,200);

    BIS_COLLECTION_UTILITIES.PUT_LINE('OPI_DBI_JOBS_PKG.REFRESH_MV - Error at statement ('
                     || to_char(l_stmt_num)
                     || ')');

    BIS_COLLECTION_UTILITIES.PUT_LINE('Error Number: ' ||  to_char(l_err_num));
    BIS_COLLECTION_UTILITIES.PUT_LINE('Error Message: ' || l_err_msg);

    RAISE_APPLICATION_ERROR(-20000, errbuf);
    /*please note that this api will commit!!*/

END REFRESH_MV;

End OPI_DBI_JOBS_PKG;

/
