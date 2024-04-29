--------------------------------------------------------
--  DDL for Package Body OPI_DBI_RES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_RES_PKG" AS
/* $Header: OPIDRESB.pls 120.26 2007/03/12 06:57:25 hyadaval ship $ */

/*========================================
    Package Level Variables
=========================================*/
-- Standard who columns
g_user_id                   NUMBER;
g_login_id                  NUMBER;
g_program_id                NUMBER;
g_program_login_id          NUMBER;
g_program_application_id    NUMBER;
g_request_id                NUMBER;

-- DBI global start date
g_global_start_date         DATE;

-- Conversion rate related variables
g_global_currency_code      VARCHAR2(10);
g_global_rate_type          VARCHAR2(15);
g_secondary_currency_code   VARCHAR2(10);
g_secondary_rate_type       VARCHAR2 (15);

g_hr_uom                    sy_uoms_mst_v.um_code%TYPE;


/*========================================
    Package Level Constants
=========================================*/

g_ok CONSTANT NUMBER(1)  := 0;
g_warning CONSTANT NUMBER(1)  := 1;
g_error CONSTANT NUMBER(1)  := -1;

OPI_SOURCE CONSTANT NUMBER := 1;
OPM_SOURCE              CONSTANT NUMBER := 2;
PRE_R12_OPM_SOURCE      CONSTANT NUMBER := 3;


--ETL ID for OPI_DBI_RUN_LOG_CURR

-- Actual Resource Usage
ACTUAL_RES_ETL CONSTANT NUMBER :=
    opi_dbi_common_mod_init_pkg.ACTUAL_RES_ETL;

-- Resource Availability
RESOURCE_VAR_ETL CONSTANT NUMBER :=
    opi_dbi_common_mod_init_pkg.RESOURCE_VAR_ETL;

-- start date of euro currency.
G_EURO_START_DATE CONSTANT DATE := to_date('01/01/1999','DD/MM/YYYY');


-- Marker for secondary conv. rate if the primary and secondary curr codes
-- and rate types are identical. Can't be -1, -2, -3 since the FII APIs
-- return those values.
C_PRI_SEC_CURR_SAME_MARKER CONSTANT NUMBER := -9999;

-- GL API returns -3 if EURO rate missing on 01-JAN-1999
C_EURO_MISSING_AT_START CONSTANT NUMBER := -3;


/*===============================================================
    This procedure gather statistics of a table.

    Parameters:
    - p_table_name: table name
================================================================*/

PROCEDURE gather_stats (p_table_name    VARCHAR2) IS

    l_table_owner  VARCHAR2(32);

BEGIN
    bis_collection_utilities.put_line('Enter gather_stats() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    -- Find owner of the table passed to procedure

    SELECT  table_owner
    INTO    l_table_owner
    FROM    user_synonyms
    WHERE   synonym_name = p_table_name;

    --   Gather table statistics these stats will be used by CBO
    --   for query optimization.

    FND_STATS.GATHER_TABLE_STATS(l_table_owner,P_TABLE_NAME,
                        PERCENT=>10,DEGREE=>4,CASCADE=>TRUE);

    bis_collection_utilities.put_line('Exit gather_stats() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));
END gather_stats;

/*===============================================================
    This procedure sets up global parameters, such as the global
    start date, globla/secondary currencies, WHO column variables.

    Parameters:
    - errbuf:   error buffer
    - retcode:  return code
=================================================================*/

PROCEDURE check_setup_globals ( errbuf  IN OUT NOCOPY VARCHAR2,
                                retcode IN OUT NOCOPY VARCHAR2)
IS

    l_list dbms_sql.varchar2_table;

    l_from_date  DATE;
    l_to_date    DATE;
    l_missing_day_flag BOOLEAN;
    l_err_num    NUMBER;
    l_err_msg    VARCHAR2(255);
    l_min_miss_date DATE;
     l_max_miss_date DATE;

BEGIN

    bis_collection_utilities.put_line('Enter check_setup_globals() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    -- initialization block
    l_missing_day_flag := false;
    retcode   := g_ok;

    -- package level variables
    g_hr_uom := fnd_profile.value( 'BOM:HOUR_UOM_CODE');

    g_user_id := nvl(fnd_global.user_id, -1);
    g_login_id := nvl(fnd_global.login_id, -1);
    g_program_id := nvl (fnd_global.conc_program_id, -1);
    g_program_login_id := nvl (fnd_global.conc_login_id, -1);
    g_program_application_id := nvl (fnd_global.prog_appl_id,  -1);
    g_request_id := nvl (fnd_global.conc_request_id, -1);


    IF (g_global_rate_type IS NULL) THEN
    --{
       g_global_rate_type := bis_common_parameters.get_rate_type;
    --}
    END IF;

    l_list(1) := 'BIS_PRIMARY_CURRENCY_CODE';
    l_list(2) := 'BIS_GLOBAL_START_DATE';
    l_list(3) := 'BIS_PRIMARY_RATE_TYPE';

    IF (bis_common_parameters.check_global_parameters(l_list)) THEN
    --{
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
        --{
            retcode := g_error;
            errbuf := 'Please check log file for details.';
            bis_collection_utilities.put_line ('The global secondary currency code setup is incorrect.' ||
                                  'The secondary currency code cannot be null when the ' ||
                                  'secondary rate type is defined and vice versa.');
        --}
        END IF;

        -- check_missing_dates in time dimension
        select sysdate into l_to_date from dual;
        fii_time_api.check_missing_date (g_global_start_date,
                                         l_to_date,
                                         l_missing_day_flag,
                                         l_min_miss_date, l_max_miss_date);

        IF l_missing_day_flag THEN
        --{
            retcode := g_error;
            errbuf  := 'Please check log file for details. ';
            bis_collection_utilities.put_line( 'There are missing date in Time Dimension.');

            bis_collection_utilities.put_line ( 'The range is from ' || l_min_miss_date
                                    ||' to ' || l_max_miss_date );
        --}
        END IF;
    --}
    ELSE
    --{
        retcode := g_error;
        errbuf  := 'Please check log file for details. ';
        bis_collection_utilities.put_line('Global Parameters are not setup.');

        bis_collection_utilities.put_line('Please check that the profile options: BIS_PRIMARY_CURRENCY_CODE and BIS_GLOBAL_START_DATE are setup.');
    --}
    END  IF;

    bis_collection_utilities.put_line('Exit check_setup_globals() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

EXCEPTION
    WHEN OTHERS THEN
    --{
        retcode := SQLCODE;
        errbuf :=   'ERROR in OPI_DBI_RES_PKG.CHECK_SETUP_GLOBALS ' ||
                    substr(SQLERRM, 1,200);
         bis_collection_utilities.put_line('Error Number: ' ||  retcode);
        bis_collection_utilities.put_line('Error Message: ' || errbuf);
    --}
END check_setup_globals;


/*========================================================================
 get_res_conversion_rate


    Compute all the conversion rates for all distinct organization,
    transaction date pairs in the staging table. The date in the fact
    table is already without a timestamp i.e. trunc'ed.

    There are two conversion rates to be computed:
    1. Primary global
    2. Secondary global (if set up)

    The conversion rate work table was truncated during
    the initialization phase.

    Get the currency conversion rates based on the data in
    OPI_DBI_RES_ACTUAL_STG using the fii_currency.get_global_rate_primary
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

     In the previous version, there were no commits in this function.
    However, there was a commit right after this function's call
    everywhere. So it is safe to change the insert to an insert+append
    and commit inside the function.

    Date            Author              Action
    08/26/2004      Dinkar Gupta        Modified to provide secondary
                                        currency support.
===============================================================================*/

PROCEDURE get_res_conversion_rate ( errbuf  IN OUT NOCOPY VARCHAR2,
                                    retcode IN OUT NOCOPY VARCHAR2 )
IS

    -- Cursor to see if any rates are missing. See below for details
    CURSOR invalid_rates_exist_csr IS
        SELECT  1
        FROM    opi_dbi_res_conv_rates
        WHERE   (nvl (conversion_rate, -999) < 0
                 OR nvl (sec_conversion_rate, 999) < 0)
        AND     rownum < 2;

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
     SELECT  DISTINCT
            report_order,
            curr_code,
            rate_type,
            transaction_date,
            func_currency_code
    FROM (
           SELECT /*+ parallel (to_conv) parallel (conv) parallel (mp) */
                    DISTINCT
                    p_global_currency_code  curr_code,
                    p_global_rate_type  rate_type,
                    1 report_order, -- ordering global currency first
                    mp.organization_code,
                    decode (conv.conversion_rate,
                            C_EURO_MISSING_AT_START, G_EURO_START_DATE,
                            conv.transaction_date) transaction_date,
                    conv.f_currency_code func_currency_code
            FROM    opi_dbi_res_conv_rates conv,
                    mtl_parameters mp,
                    (
                    SELECT /*+ parallel (opi_dbi_res_actual_stg) */
                            DISTINCT
                            organization_id,
                            transaction_date
                    FROM    opi_dbi_res_actual_stg
                    UNION
                    SELECT /*+ parallel (opi_dbi_res_avail_stg) */
                            DISTINCT
                            organization_id,
                            transaction_date
                    FROM    opi_dbi_res_avail_stg)  to_conv
            WHERE   nvl (conv.conversion_rate, -999) < 0 -- null is not fine
            AND     mp.organization_id = to_conv.organization_id
            AND     conv.transaction_date (+) = to_conv.transaction_date
            AND     conv.organization_id (+) = to_conv.organization_id
            UNION ALL
            SELECT /*+ parallel (to_conv) parallel (conv) parallel (mp) */
                    DISTINCT
                    p_secondary_currency_code curr_code,
                    p_secondary_rate_type rate_type,
                    decode (p_pri_sec_curr_same,
                            1, 1,
                            2) report_order, --ordering secondary currency next
                    mp.organization_code,
                    decode (conv.sec_conversion_rate,
                            C_EURO_MISSING_AT_START, G_EURO_START_DATE,
                            conv.transaction_date) transaction_date_date,
                    conv.f_currency_code func_currency_code
             FROM    opi_dbi_res_conv_rates conv,
                    mtl_parameters mp,
                    (
                    SELECT /*+ parallel (opi_dbi_res_actual_stg) */
                            DISTINCT
                            organization_id,
                            transaction_date
                    FROM    opi_dbi_res_actual_stg
                    UNION
                    SELECT /*+ parallel (opi_dbi_res_avail_stg) */
                            DISTINCT
                            organization_id,
                            transaction_date
                    FROM    opi_dbi_res_avail_stg)  to_conv
            WHERE   nvl (conv.sec_conversion_rate, 999) < 0 -- null is fine
            AND     mp.organization_id = to_conv.organization_id
            AND     conv.transaction_date (+) = to_conv.transaction_date
            AND     conv.organization_id (+) = to_conv.organization_id)
     ORDER BY
            report_order ASC,
            transaction_date,
            func_currency_code;


    -- mark location in procedure
    l_stmt_num NUMBER;

    -- Flag to check if the primary and secondary currencies are the same
    l_pri_sec_curr_same NUMBER;

    no_currency_rate_flag NUMBER;


BEGIN


    bis_collection_utilities.put_line('Enter get_res_conversion_rate() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    -- initialization block
    l_pri_sec_curr_same := 0;
    no_currency_rate_flag := 0;
    retcode := g_ok;

    l_stmt_num := 10;
    -- check if the primary and secondary currencies and rate types are same
    IF (g_global_currency_code = nvl (g_secondary_currency_code, '---') AND
        g_global_rate_type = nvl (g_secondary_rate_type, '---') ) THEN
    --{
        l_pri_sec_curr_same := 1;
    --}
    END IF;

   l_stmt_num := 10;
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
    INTO    opi_dbi_res_conv_rates rates (
            organization_id,
            f_currency_code,
            transaction_date,
            conversion_rate,
            sec_conversion_rate)
    SELECT /*+ parallel (to_conv) parallel (curr_codes) */
            to_conv.organization_id,
            curr_codes.currency_code,
            to_conv.transaction_date,
            decode (curr_codes.currency_code,
                    g_global_currency_code, 1,
                    fii_currency.get_global_rate_primary (
                                     curr_codes.currency_code,
                                    to_conv.transaction_date) ),
            decode (g_secondary_currency_code,
                    NULL, NULL,
                    curr_codes.currency_code, 1,
                    decode (l_pri_sec_curr_same,
                            1, C_PRI_SEC_CURR_SAME_MARKER,
                            fii_currency.get_global_rate_secondary (
                                curr_codes.currency_code,
                                to_conv.transaction_date)))
    FROM
            (SELECT /*+ parallel (opi_dbi_res_actual_stg) */
                    DISTINCT
                    organization_id,
                    trunc (transaction_date) transaction_date
            FROM    opi_dbi_res_actual_stg
            UNION
            SELECT /*+ parallel (opi_dbi_res_avail_stg) */
                    DISTINCT
                    organization_id,
                    trunc (transaction_date) transaction_date
            FROM    opi_dbi_res_avail_stg)     to_conv,
            (SELECT /*+ leading (hoi) full (hoi) use_hash (gsob)
                    parallel (hoi) parallel (gsob)*/
                    DISTINCT
                    hoi.organization_id,
                    gsob.currency_code
            FROM    hr_organization_information hoi,
                    gl_sets_of_books gsob
            WHERE   hoi.org_information_context  = 'Accounting Information'
            AND     hoi.org_information1  = to_char(gsob.set_of_books_id)) curr_codes
    WHERE   curr_codes.organization_id  = to_conv.organization_id;



    --Introduced commit because of append parallel in the insert stmt above.
    commit;

    l_stmt_num := 40;
    -- if the primary and secondary currency codes are the same, then
    -- update the secondary with the primary
    IF (l_pri_sec_curr_same = 1) THEN
    --{
        UPDATE /*+ parallel (opi_dbi_res_conv_rates) */
        opi_dbi_res_conv_rates
        SET sec_conversion_rate = conversion_rate;

        -- safe to commit, as before
        commit;
    --}
    END IF;

     -- report missing rate
    l_stmt_num := 50;

    OPEN invalid_rates_exist_csr;
    FETCH invalid_rates_exist_csr INTO invalid_rates_exist_rec;
    IF (invalid_rates_exist_csr%FOUND) THEN
    --{
        -- there are missing rates - prepare to report them.
        no_currency_rate_flag := 1;
        BIS_COLLECTION_UTILITIES.writeMissingRateHeader;

        l_stmt_num := 60;
        FOR get_missing_rates_rec IN get_missing_rates_c (
                                            l_pri_sec_curr_same,
                                            g_global_currency_code,
                                            g_global_rate_type,
                                            g_secondary_currency_code,
                                            g_secondary_rate_type)
        LOOP

            BIS_COLLECTION_UTILITIES.writemissingrate (
                get_missing_rates_rec.rate_type,
                get_missing_rates_rec.func_currency_code,
                get_missing_rates_rec.curr_code,
                get_missing_rates_rec.transaction_date);

        END LOOP;
    --}
    END IF;
    CLOSE invalid_rates_exist_csr;


    l_stmt_num := 70; /* check no_currency_rate_flag  */
    IF (no_currency_rate_flag = 1) THEN /* missing rate found */
    --{
        bis_collection_utilities.put_line('ERROR: Please setup conversion rate for all missing rates reported');

        retcode := g_error;
    --}
    END IF;

    bis_collection_utilities.put_line('Exit get_res_conversion_rate() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));
    return;

EXCEPTION
    WHEN OTHERS THEN
    --{
        rollback;
        retcode := SQLCODE;
        errbuf  := 'REPORT_MISSING_RATE (' || to_char(l_stmt_num)
                    || '): '|| substr(SQLERRM, 1,200);

        bis_collection_utilities.put_line('opi_dbi_res_pkg.get_res_conversion_rate - Error at statement ('
                    || to_char(l_stmt_num) || ')');

        bis_collection_utilities.put_line('Error Number: ' ||  retcode );
        bis_collection_utilities.put_line('Error Message: ' || errbuf  );
    --}
END get_res_conversion_rate;



/*===============================================================
    This procedure extracts resource availability data into
    the staging table for initial load.

    Parameters:
    - p_start_date: lower run bound
    - p_end_date:   upper run bound
    - errbuf:   error buffer
    - retcode:  return code
================================================================*/

PROCEDURE initial_opi_res_avail  (p_start_date  IN DATE,
                                  p_end_date    IN DATE,
                                  errbuf    IN OUT NOCOPY VARCHAR2,
                                  retcode   IN OUT NOCOPY VARCHAR2) IS
    l_stmt_num  NUMBER;
    l_count     NUMBER;

BEGIN

    bis_collection_utilities.put_line('Enter initial_opi_res_avail() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    retcode := g_ok;
    l_stmt_num := 10;

    -- populate availability for 24 hr available resource

    INSERT /*+ append parallel(e) */ INTO opi_dbi_res_avail_stg (
            resource_id,
            department_id,
            organization_id,
            transaction_date,
            uom,
            avail_qty,
            avail_qty_g,
            avail_val_b,
            source)
    SELECT /*+  use_hash(m) use_hash(bd) use_hash(bdr) use_hash(br)  use_hash(mp)
                use_hash(crc) parallel(m) full(bcd) use_hash(bcd) parallel(br) parallel(bd)
                parallel(bdr) parallel(bcd) use_hash(m2) parallel(m2) */
            br.resource_id,
            bdr.department_id,
            br.organization_id,
            bcd.calendar_date               transaction_date,
            br.unit_of_measure              uom,
            24* bdr.capacity_units/m2.conversion_rate  avail_qty,
            24* bdr.capacity_units          avail_qty_g,
            24* bdr.capacity_units/m2.conversion_rate  * crc.resource_rate avail_val_b,
            OPI_SOURCE                      source
    FROM    bom_resources                   br,
            bom_departments                 bd,
            bom_department_resources        bdr,
            bom_calendar_dates              bcd,
            mtl_parameters                  mp,
            mtl_uom_conversions             m,
            mtl_uom_conversions             m2,
            cst_resource_costs              crc
    WHERE   bdr.available_24_hours_flag = 1  -- 24 hr available
    AND     bdr.share_from_dept_id IS NULL     -- owing dept
    AND     br.resource_id = bdr.resource_id
    AND     m.inventory_item_id  = 0
    AND     m.uom_code           = g_hr_uom
    AND     m2.uom_code          = br.unit_of_measure
    AND     m2.uom_class         = m.uom_class
    AND     m2.inventory_item_id  = 0
    AND     bd.department_id = bdr.department_id
    AND     bd.organization_id = mp.organization_id
    AND     bcd.calendar_code  = mp.calendar_code
    AND     bcd.exception_set_id = mp.calendar_exception_set_id
    AND     bcd.seq_num IS NOT NULL           -- scheduled to be on
    AND     bcd.calendar_date between p_start_date AND p_end_date
    AND     ( bd.disable_date IS NULL OR bcd.calendar_date < bd.disable_date)
    AND     ( br.disable_date IS NULL OR bcd.calendar_date < br.disable_date)
    AND     bcd.calendar_date > ( bdr.creation_date - 1)
    AND     crc.resource_id      = br.resource_id
    AND     crc.organization_id  = mp.organization_id
    AND     ( (mp.primary_cost_method = 1 AND crc.cost_type_id = 1)
            OR (mp.primary_cost_method in (2,5,6) AND crc.cost_type_id =mp.AVG_RATES_COST_TYPE_ID ) )
     ;

     l_count := sql%rowcount;

     commit;

     bis_collection_utilities.put_line('24 hr available resource '|| l_count ||
                    ' rows into stg, completed at ' ||
                       To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

     l_stmt_num   := 20;
     -- populate availability for shift based resource

    INSERT /*+ append */ INTO opi_dbi_res_avail_stg (
            resource_id,
            department_id,
            organization_id,
            transaction_date,
            uom,
            avail_qty,
            avail_qty_g,
            avail_val_b,
            source)
    SELECT  br.resource_id,
            bd.department_id,
            br.organization_id,
            Trunc(bsd.shift_date) transaction_date,
            br.unit_of_measure,
            sum(case when (bst.to_time >= bst.from_time) then
            ( (bst.to_time - bst.from_time)/3600*bdr.capacity_units
            /m2.conversion_rate * m.conversion_rate )
            else ( ( 86400 - bst.from_time + bst.to_time)/3600*bdr.capacity_units
            /m2.conversion_rate * m.conversion_rate ) end ) avail_qty,
            sum(case when (bst.to_time >= bst.from_time) then
            ( (bst.to_time - bst.from_time)/3600*bdr.capacity_units )
            else ( ( 86400 - bst.from_time + bst.to_time)/3600*bdr.capacity_units)
            end )           avail_qty_g,
            sum(case when (bst.to_time >= bst.from_time) then
            ( (bst.to_time - bst.from_time)/3600*bdr.capacity_units
                /m2.conversion_rate * m.conversion_rate * crc.resource_rate )
            else ( ( 86400 - bst.from_time + bst.to_time)/3600*bdr.capacity_units
            /m2.conversion_rate * m.conversion_rate * crc.resource_rate )
            end )           avail_val_b,
            OPI_SOURCE  source
     FROM   bom_resources                   br,
            bom_departments                 bd,
            bom_department_resources        bdr,
            bom_resource_shifts             brs,
            bom_shift_dates                 bsd,
            bom_shift_times                 bst,
            mtl_parameters                  mp,
            mtl_uom_conversions             m,
            mtl_uom_conversions             m2,
            cst_resource_costs              crc
     WHERE  bdr.available_24_hours_flag = 2   -- shift based
     AND    bdr.share_from_dept_id IS NULL      -- owning dept
     AND    br.resource_id = bdr.resource_id
     AND    m.inventory_item_id  = 0
     AND    m.uom_code           = g_hr_uom
     AND    m2.uom_code          = br.unit_of_measure
     AND    m2.uom_class         = m.uom_class
     AND    m2.inventory_item_id  = 0
     AND    bd.department_id = bdr.department_id
     AND    bd.organization_id = mp.organization_id
     AND    brs.department_id = bd.department_id
     AND    brs.resource_id   = br.resource_id
     AND    bsd.calendar_code = mp.calendar_code
     AND    bsd.exception_set_id = mp.calendar_exception_set_id
     AND    bsd.shift_num     = brs.shift_num
     AND    bsd.seq_num IS NOT NULL               -- schedule to be available
     AND    bsd.shift_date BETWEEN p_start_date AND p_end_date
     AND    ( bd.disable_date IS NULL OR bsd.shift_date < bd.disable_date)
     AND    ( br.disable_date IS NULL OR bsd.shift_date < br.disable_date)
     AND    bsd.shift_date > ( bdr.creation_date - 1)
     AND    bst.calendar_code = mp.calendar_code
     AND    bst.shift_num     = brs.shift_num
     AND    crc.resource_id      = br.resource_id
     AND    crc.organization_id  = mp.organization_id
     AND     ( (mp.primary_cost_method = 1 AND crc.cost_type_id = 1)
            OR (mp.primary_cost_method =2 AND crc.cost_type_id = mp.AVG_RATES_COST_TYPE_ID ) )
     GROUP BY
            br.organization_id, bd.department_id,
            br.resource_id, br.unit_of_measure,
            bsd.shift_date;

     l_count := sql%rowcount;

     COMMIT;
     bis_collection_utilities.put_line('shift based available resource '||
                l_count ||' rows into stg, completed at ' ||
                To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    bis_collection_utilities.put_line('initial_opi_res_avail() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

EXCEPTION WHEN OTHERS THEN
    --{
    Errbuf:= Sqlerrm;
    Retcode:= SQLCODE;

    ROLLBACK;

    bis_collection_utilities.put_line('Exception in initial_opi_res_avail ' || errbuf );
    --}
END initial_opi_res_avail;


/*===============================================================
    This procedure extracts actual resource usage  data into
    the staging table for initial load.

    Parameters:
    - errbuf:   error buffer
    - retcode:  return code
================================================================*/

PROCEDURE initial_opi_res_actual  (errbuf   IN OUT NOCOPY VARCHAR2,
                                   retcode  IN OUT NOCOPY VARCHAR2) IS
    l_stmt_num  NUMBER;
    l_count     number;

BEGIN

    bis_collection_utilities.put_line('Enter initial_opi_res_actual() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    retcode := g_ok;

    INSERT /*+ append parallel(a) */ INTO opi_dbi_res_actual_stg a (
            resource_id,
            department_id,
            organization_id,
            transaction_date,
            actual_qty_draft,
            actual_qty,
            actual_qty_g_draft,
            actual_qty_g,
            uom,
            actual_val_b_draft,
            actual_val_b,
            source,
            job_id,
            job_type,
            assembly_item_id)
    SELECT   /*+ parallel(we) parallel(bdr) parallel(wt) parallel(wta)
            use_hash(wt) use_hash(we) use_hash(wta)*/
            wt.resource_id,
            nvl(bdr.share_from_dept_id,wt.department_id),
            wt.organization_id,
            Trunc(wt.transaction_date)      transaction_date,
            0                               actual_qty_draft,
            SUM(wt.primary_quantity)        actual_qty,
            0                               actual_qty_g_draft,
            SUM(wt.primary_quantity*m2.conversion_rate/m.conversion_rate) actual_qty_g,
            wt.primary_uom                  uom,
            0                               actual_val_b_draft,
            SUM(wta.base_transaction_value * -1)    actual_val_b,
            OPI_SOURCE                      source,
            nvl( wta.repetitive_schedule_id, wta.wip_entity_id )    job_id,
            Decode(we.entity_type, 1, 1, 2, 2, 3, 1, 4, 3, 5, 5, 8, 5, 0)        job_type,
            wt.primary_item_id              assembly_item_id
     FROM    wip_transactions                wt,
            wip_transaction_accounts        wta,
            wip_entities                    we,
            mtl_uom_conversions             m,
            mtl_uom_conversions             m2,
            opi_dbi_run_log_curr            rlc,
            bom_department_resources        bdr
    WHERE
     -- 1->resource trx   3-> outside processing,
     -- both involve resource, other types don't have resource_id
            Rlc.etl_id = ACTUAL_RES_ETL
    AND     Rlc.source = 1
    AND     wt.transaction_id >= Rlc.start_txn_id
    AND     wt.transaction_id < Rlc.next_start_txn_id
    AND     wt.transaction_type IN (1,3)
    AND     wta.transaction_id  = wt.transaction_id
    AND     wta.accounting_line_type = 4
    AND     we.wip_entity_id = wt.wip_entity_id
    AND     m.inventory_item_id = 0
    AND     m.uom_code          = g_hr_uom
    AND     m2.uom_code = wt.primary_uom
    AND     m2.inventory_item_id = 0
    AND     m2.uom_class = m.uom_class
    and     bdr.resource_id     = wt.resource_id
    and     bdr.department_id   = wt.department_id
    GROUP BY
            wt.resource_id,
            nvl( bdr.share_from_dept_id,wt.department_id),
            wt.organization_id,
            Trunc(wt.transaction_date),
            wt.primary_uom,
            wta.repetitive_schedule_id,
            wta.wip_entity_id ,
            we.entity_type,
            wt.primary_item_id;

    l_count := sql%rowcount;

    bis_collection_utilities.put_line('resource actual '|| l_count ||
                ' rows into stg, completed at ' ||
                To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    bis_collection_utilities.put_line('Exit initial_opi_res_actual() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    COMMIT;

EXCEPTION WHEN OTHERS THEN
--{
    Errbuf:= Sqlerrm;
    Retcode:= SQLCODE;

    ROLLBACK;

    bis_collection_utilities.put_line('Exception in initial_opi_res_actual ' || errbuf );
--}

END initial_opi_res_actual;


/*===============================================================
    This procedure extracts resource availability data into
    the staging table for incremental load.

    Parameters:
    - p_start_date: lower run bound
    - p_end_date:   upper run bound
    - errbuf:   error buffer
    - retcode:  return code
================================================================*/

PROCEDURE incremental_opi_res_avail  (p_start_date  IN DATE,
                                      p_end_date    IN DATE,
                                      errbuf    IN OUT NOCOPY VARCHAR2,
                                      retcode   IN OUT NOCOPY VARCHAR2) IS
    l_stmt_num  NUMBER;
    l_count     number;

    l_start_date date;
    l_end_date   date;

BEGIN

    bis_collection_utilities.put_line('Enter incremental_opi_res_avail() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    retcode := g_ok;

    l_start_date := p_start_date;
    l_end_date := p_end_date;

    l_stmt_num := 10;

    -- if from_date is not to_date, start from the day after from_date
    IF (l_start_date <> l_end_date) THEN
    --{
        l_start_date := l_start_date + 1;
    --}
    END IF;


    -- populate availability for 24 hr available resource
    INSERT INTO opi_dbi_res_avail_stg (
            resource_id,
            department_id,
            organization_id,
            transaction_date,
            uom,
            avail_qty,
            avail_qty_g,
            avail_val_b,
            source)
    SELECT  br.resource_id,
            bd.department_id,
            br.organization_id,
            bcd.calendar_date               transaction_date,
            br.unit_of_measure           uom,
            24* bdr.capacity_units/m2.conversion_rate  avail_qty,
            24* bdr.capacity_units          avail_qty_g,
            24* bdr.capacity_units/m2.conversion_rate  * crc.resource_rate avail_val_b,
            OPI_SOURCE  source
    FROM    bom_resources                   br,
            bom_departments                 bd,
            bom_department_resources        bdr,
            bom_calendar_dates              bcd,
            mtl_parameters                  mp,
            mtl_uom_conversions             m,
            mtl_uom_conversions             m2,
            cst_resource_costs              crc
    WHERE   bdr.available_24_hours_flag = 1  -- 24 hr available
    AND     bdr.share_from_dept_id IS NULL     -- owing dept
    AND     br.resource_id = bdr.resource_id
    AND     m.inventory_item_id  = 0
    AND     m.uom_code           =g_hr_uom
    AND     m2.uom_code          = br.unit_of_measure
    AND     m2.uom_class         = m.uom_class
    AND     m2.inventory_item_id  = 0
    AND     bd.department_id = bdr.department_id
    AND     bd.organization_id = mp.organization_id
    AND     bcd.calendar_code  = mp.calendar_code
    AND     bcd.exception_set_id = mp.calendar_exception_set_id
    AND     bcd.seq_num IS NOT NULL           -- scheduled to be on
    AND     bcd.calendar_date between l_start_date AND l_end_date
    AND     ( bd.disable_date IS NULL OR bcd.calendar_date < bd.disable_date)
    AND     ( br.disable_date IS NULL OR bcd.calendar_date < br.disable_date)
    and     bcd.calendar_date > ( bdr.creation_date - 1)
    AND     crc.resource_id      = br.resource_id
    AND     crc.organization_id  = mp.organization_id
    AND     ( (mp.primary_cost_method = 1 AND crc.cost_type_id = 1)
            OR (mp.primary_cost_method =2 AND crc.cost_type_id =mp.AVG_RATES_COST_TYPE_ID ) )
    ;

    l_count := sql%rowcount;

    bis_collection_utilities.put_line('24 hr available resource '|| l_count ||
                ' rows into stg, completed at ' ||
                   To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    l_stmt_num   := 20;
    -- populate availability for shift based resource

    INSERT INTO opi_dbi_res_avail_stg (
            resource_id,
            department_id,
            organization_id,
            transaction_date,
            uom,
            avail_qty,
            avail_qty_g,
            avail_val_b,
            source)
     SELECT  br.resource_id,
            bd.department_id,
            br.organization_id,
            Trunc(bsd.shift_date) transaction_date,
            br.unit_of_measure,
            sum(case when (bst.to_time >= bst.from_time) then
            ( (bst.to_time - bst.from_time)/3600*bdr.capacity_units
            /m2.conversion_rate * m.conversion_rate )
            else ( ( 86400 - bst.from_time + bst.to_time)/3600*bdr.capacity_units
            /m2.conversion_rate * m.conversion_rate ) end ) avail_qty,
            sum(case when (bst.to_time >= bst.from_time) then
            ( (bst.to_time - bst.from_time)/3600*bdr.capacity_units )
            else ( ( 86400 - bst.from_time + bst.to_time)/3600*bdr.capacity_units)
            end  ) avail_qty_g,
            sum(case when (bst.to_time >= bst.from_time) then
            ( (bst.to_time - bst.from_time)/3600*bdr.capacity_units
            /m2.conversion_rate * m.conversion_rate * crc.resource_rate )
            else ( ( 86400 - bst.from_time + bst.to_time)/3600*bdr.capacity_units
            /m2.conversion_rate * m.conversion_rate * crc.resource_rate )
            end ) avail_val_b,
            OPI_SOURCE source
     FROM   bom_resources                   br,
            bom_departments                 bd,
            bom_department_resources        bdr,
            bom_resource_shifts             brs,
            bom_shift_dates                 bsd,
            bom_shift_times                 bst,
            mtl_parameters                  mp,
            mtl_uom_conversions             m,
            mtl_uom_conversions             m2,
            cst_resource_costs              crc
    WHERE   bdr.available_24_hours_flag = 2   -- shift based
    AND     bdr.share_from_dept_id IS NULL      -- owning dept
    AND     br.resource_id = bdr.resource_id
    AND     m.inventory_item_id  = 0
    AND     m.uom_code           = g_hr_uom
    AND     m2.uom_code          = br.unit_of_measure
    AND     m2.uom_class         = m.uom_class
    AND     m2.inventory_item_id  = 0
    AND     bd.department_id = bdr.department_id
    AND     bd.organization_id = mp.organization_id
    AND     brs.department_id = bd.department_id
    AND     brs.resource_id   = br.resource_id
    AND     bsd.calendar_code = mp.calendar_code
    AND     bsd.exception_set_id = mp.calendar_exception_set_id
    AND     bsd.shift_num     = brs.shift_num
    AND     bsd.seq_num IS NOT NULL               -- schedule to be available
    AND     bsd.shift_date BETWEEN l_start_date AND l_end_date
    AND     ( bd.disable_date IS NULL OR bsd.shift_date < bd.disable_date)
    AND     ( br.disable_date IS NULL OR bsd.shift_date < br.disable_date)
    AND     bsd.shift_date > ( bdr.creation_date - 1)
    AND     bst.calendar_code = mp.calendar_code
    AND     bst.shift_num     = brs.shift_num
    AND     crc.resource_id      = br.resource_id
    AND     crc.organization_id  = mp.organization_id
    AND     ( (mp.primary_cost_method = 1 AND crc.cost_type_id = 1)
            OR (mp.primary_cost_method in (2,5,6) AND crc.cost_type_id = mp.AVG_RATES_COST_TYPE_ID ) )
    GROUP BY
            br.organization_id, bd.department_id,
            br.resource_id, br.unit_of_measure,
            bsd.shift_date;

    l_count := sql%rowcount;

    bis_collection_utilities.put_line('shift based available resource '||
                 l_count ||' rows into stg, completed at ' ||
                 To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    bis_collection_utilities.put_line('Exit incremental_opi_res_avail() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

EXCEPTION WHEN OTHERS THEN
--{
    Errbuf:= Sqlerrm;
    Retcode:= SQLCODE;

    ROLLBACK;

    bis_collection_utilities.put_line('Exception in incremental_opi_res_avail ' || errbuf );
--}
END incremental_opi_res_avail;


/*===============================================================
    This procedure extracts actual resource usage  data into
    the staging table for incremental load.

    Parameters:
    - errbuf:   error buffer
    - retcode:  return code
================================================================*/

PROCEDURE incremental_opi_res_actual  (errbuf   IN OUT NOCOPY VARCHAR2,
                                       retcode  IN OUT NOCOPY VARCHAR2) IS
    l_stmt_num  NUMBER;
    l_transaction_id NUMBER;
    l_count     number;

BEGIN

    bis_collection_utilities.put_line('Enter incremental_opi_res_actual() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    retcode := g_ok;

    INSERT INTO opi_dbi_res_actual_stg (
            resource_id,
            department_id,
            organization_id,
            transaction_date,
            actual_qty_draft,
            actual_qty,
            actual_qty_g_draft,
            actual_qty_g,
            uom,
            actual_val_b_draft,
            actual_val_b,
            source,
            job_id,
            job_type,
            assembly_item_id)
    SELECT  /*+ ordered use_nl(rlc wt) index(rlc, OPI_DBI_RUN_LOG_CURR_N1)
            index(wt, WIP_TRANSACTIONS_U1) index(wta, WIP_TRANSACTION_ACCOUNTS_N1)
            use_nl(we) index(we, WE_C1) index(bdr, BOM_DEPARTMENT_RESOURCES_U1)
            use_nl(bdr) use_nl(m) use_nl(m2) */
            wt.resource_id,
            nvl(bdr.share_from_dept_id, wt.department_id ),
            wt.organization_id,
            Trunc(wt.transaction_date)  transaction_date,
            0                           actual_qty_draft,
            SUM(wt.primary_quantity)    actual_qty,
            0                           actual_qty_g_draft,
            SUM(wt.primary_quantity*m2.conversion_rate/m.conversion_rate) actual_qty_g,
            wt.primary_uom              uom,
            0                           actual_val_b_draft,
            SUM(wta.base_transaction_value * -1)  actual_val_b,
            OPI_SOURCE                  source,
            nvl( wta.repetitive_schedule_id, wta.wip_entity_id )    job_id,
            Decode(we.entity_type, 1, 1, 2, 2, 3, 1, 4, 3, 5, 5, 8, 5, 0)        job_type,
             wt.primary_item_id          assembly_item_id
    FROM    wip_transactions                wt,
            wip_transaction_accounts        wta,
            wip_entities                    we,
            opi_dbi_run_log_curr            rlc,
            bom_department_resources        bdr,
            mtl_uom_conversions             m,
            mtl_uom_conversions             m2
    WHERE
     -- 1->resource trx   3-> outside processing,
     -- both involve resource, other types don't have resource_id
            Rlc.etl_id = ACTUAL_RES_ETL
    AND     Rlc.source = 1
    AND     wt.transaction_id >= Rlc.start_txn_id
    AND     wt.transaction_id < Rlc.next_start_txn_id
    AND     wt.transaction_type IN (1,3)
    AND     wta.transaction_id  = wt.transaction_id
    AND     wta.accounting_line_type = 4
    AND     we.wip_entity_id = wt.wip_entity_id
    AND     m.inventory_item_id = 0
    AND     m.uom_code = g_hr_uom
    AND     m2.uom_code = wt.primary_uom
    AND     m2.inventory_item_id = 0
    AND     m2.uom_class = m.uom_class
    AND     bdr.resource_id     = wt.resource_id
    AND     bdr.department_id   = wt.department_id
    GROUP BY
            wt.resource_id,
            nvl(bdr.share_from_dept_id,wt.department_id),
            wt.organization_id,
            Trunc(wt.transaction_date),
            wt.primary_uom,
            wta.repetitive_schedule_id,
            wta.wip_entity_id,
            we.entity_type,
            wt.primary_item_id;

    l_count := sql%rowcount;

    bis_collection_utilities.put_line('incremental load of actual resource '||
                 l_count ||' rows into stg, completed at ' ||
                 To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    bis_collection_utilities.put_line('Exit incremental_opi_res_actual() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

EXCEPTION WHEN OTHERS THEN
--{
    Errbuf:= Sqlerrm;
    Retcode:= SQLCODE;

    ROLLBACK;

    bis_collection_utilities.put_line('Exception in incremental_opi_res_actual ' || errbuf );
--}
END incremental_opi_res_actual;



/*======================================================
    This procedure extracts actual resource usage data
    into the staging table for initial load.

    Parameters:
    - errbuf: error buffer
    - retcode: return code
=======================================================*/

PROCEDURE initial_opm_res_actual  (errbuf   IN OUT NOCOPY VARCHAR2,
                                   retcode  IN OUT NOCOPY VARCHAR2) IS
   l_stmt_num  NUMBER;
   l_rowcount NUMBER;

BEGIN

    bis_collection_utilities.put_line('Enter initial_opm_res_actual() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    retcode := g_ok;

    INSERT /*+ APPEND */ INTO opi_dbi_res_actual_stg (
            resource_id,
            organization_id,
            transaction_date,
            uom,
            actual_qty_draft,
            actual_qty,
            actual_qty_g_draft,
            actual_qty_g,
            actual_val_b_draft,
            actual_val_b,
            source,
            job_id,
            job_type,
            assembly_item_id,
            department_id)
    SELECT  rdtl.resource_id                resource_id,
            rtran.organization_id              organization_id,
            trunc(rtran.trans_date)         transaction_date,
            rtran.trans_qty_um                  uom,
            sum(decode(gtv.accounted_flag, 'D', rtran.resource_usage * prod.cost_alloc, 0)) actual_qty_draft,
            sum(decode(gtv.accounted_flag, 'D', 0, rtran.resource_usage * prod.cost_alloc)) actual_qty,
            sum(decode(gtv.accounted_flag, 'D',
              rtran.resource_usage * prod.cost_alloc * hruom.std_factor/ruom.std_factor, 0)) actual_qty_g_draft,
            sum(decode(gtv.accounted_flag, 'D', 0,
              rtran.resource_usage * prod.cost_alloc * hruom.std_factor/ruom.std_factor))   actual_qty_g,
            sum(decode(gtv.accounted_flag, 'D', gtv.txn_base_value * prod.cost_alloc, 0))     actual_val_b_draft,
            sum(decode(gtv.accounted_flag, 'D', 0, gtv.txn_base_value * prod.cost_alloc)) actual_val_b,
            OPM_SOURCE                      source,
            rtran.doc_id                    job_id,
            4                               job_type,
            prod.inventory_item_id           assembly_item_id,
            rmst.resource_class             department_id
    FROM    sy_uoms_mst                 hruom,
            sy_uoms_mst                 ruom,
            gme_resource_txns           rtran,
            cr_rsrc_dtl                 rdtl,
            cr_rsrc_mst_b               rmst,
            gme_material_details        prod,
            (
            SELECT  gtv.transaction_id,
                    gtv.accounted_flag,
                    gtv.txn_base_value
            FROM    gmf_transaction_valuation   gtv,
                    opi_dbi_run_log_curr        log,
                    opi_dbi_org_le_temp         tmp
            WHERE   nvl(gtv.accounted_flag, 'F') <> 'N'
            AND     gtv.journal_line_type = 'WIP'
            AND     gtv.event_class_code = 'BATCH_RESOURCE'
            AND     gtv.transaction_date >= g_global_start_date
            AND     nvl(gtv.final_posting_date, log.from_bound_date) >= log.from_bound_date
            AND     nvl(gtv.final_posting_date, log.from_bound_date) < log.to_bound_date
            AND     log.etl_id = ACTUAL_RES_ETL
            AND     log.source = OPM_SOURCE
            AND     gtv.ledger_id = tmp.ledger_id
            AND     gtv.legal_entity_id = tmp.legal_entity_id
            AND     gtv.valuation_cost_type_id = tmp.valuation_cost_type_id
            AND     gtv.organization_id = tmp.organization_id) gtv
    WHERE   hruom.uom_code = g_hr_uom
    AND     ruom.uom_code = rtran.trans_qty_um
    AND     gtv.transaction_id = rtran.poc_trans_id
    AND     rtran.completed_ind = 1
    AND     rdtl.organization_id = rtran.organization_id
    AND     rdtl.resources = rtran.resources
    AND     rmst.resources = rdtl.resources
    AND     prod.batch_id = rtran.doc_id
    AND     prod.line_type = 1
    GROUP BY
            prod.inventory_item_id,
            rtran.doc_id,
            rdtl.resource_id,
            rmst.resource_class,
            trunc(rtran.trans_date),
            rtran.trans_qty_um,
            rtran.organization_id;

    commit;
    l_rowcount := sql%rowcount;

    bis_collection_utilities.put_line('OPM Resource Actual: ' ||
             l_rowcount || ' rows initially collected into staging table at '||
             to_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    bis_collection_utilities.put_line('Exit initial_opm_res_actual() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));


EXCEPTION WHEN OTHERS THEN
--{
   Errbuf:= Sqlerrm;
   Retcode:= SQLCODE;

   ROLLBACK;

   bis_collection_utilities.put_line('Exception in initial_opm_res_actual ' || errbuf );
--}
END initial_opm_res_actual;



/*======================================================
    This procedure extracts resource availability data
    into the staging table for initial load.

    Parameters:
    - p_start_date: lower run bound
    - p_end_date:   upper run bound
    - errbuf: error buffer
    - retcode: return code
=======================================================*/

PROCEDURE initial_opm_res_avail  (p_start_date  IN DATE,
                                  p_end_date    IN DATE,
                                  errbuf        IN OUT NOCOPY VARCHAR2,
                                  retcode       IN OUT NOCOPY VARCHAR2)
IS
    l_stmt_num  NUMBER;
    l_rowcount NUMBER;

BEGIN

    bis_collection_utilities.put_line('Enter initial_opm_res_avail() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    retcode := g_ok;
    l_stmt_num := 10;

    -- populate availability for opm resource

     INSERT /*+ APPEND */ INTO opi_dbi_res_avail_stg (
            resource_id,
            organization_id,
            department_id,
            transaction_date,
            uom,
            avail_qty,
            avail_qty_g,
            avail_val_b,
            source)
    SELECT
            r.resource_id           resource_id,
            r.organization_id       organization_id,
            r.department_id         department_id,
            r.shift_date            transaction_date,
            r.usage_uom              uom,
            SUM(r.shift_hours * hruom.std_factor / ruom.std_factor)
                                avail_qty,
            SUM(r.shift_hours)      avail_qty_g, -- availability in hours
            SUM(r.shift_hours * hruom.std_factor / rcostuom.std_factor * rcost.nominal_cost)
                                avail_val_b,
            OPM_SOURCE                       source
    FROM
    (
            SELECT
                    mp.organization_id,
                    rdtl.resources,
                    rdtl.resource_id,
                    rmst.resource_class department_id,
                    rdtl.usage_uom,
                    pol.cost_type_id,
                    cmm.default_lot_cost_type_id,
                    pol.legal_entity_id,
                    ravail.shift_date,
                    sum((ravail.to_time - ravail.from_time)*ravail.resource_units/3600) shift_hours
            FROM    cr_rsrc_dtl         rdtl,
                    cr_rsrc_mst_b       rmst,
                    gmf_fiscal_policies pol,
                    mtl_parameters      mp,
                    gmp_resource_avail  ravail,
                    org_organization_definitions    org_def,
                    cm_mthd_mst cmm
            WHERE   rmst.resources = rdtl.resources
            AND     rdtl.organization_id = org_def.organization_id
            AND     org_def.legal_entity = pol.legal_entity_id
            AND     ravail.calendar_code = mp.calendar_code
            AND     ravail.organization_id = mp.organization_id
            AND     ravail.organization_id = rdtl.organization_id
            AND     ravail.resource_id = rdtl.resource_id
            AND     nvl(ravail.instance_id,0) = 0 -- resource level row
            AND     NVL(ravail.resource_instance_id,0) = 0 -- exclude individual resource instances
            AND     ravail.shift_date BETWEEN p_start_date AND p_end_date
            AND     ravail.shift_date >= trunc(rdtl.creation_date)
            AND     pol.cost_type_id = cmm.cost_type_id
            GROUP BY
                    rdtl.resources,
                    rdtl.resource_id,
                    rmst.resource_class,
                    rdtl.usage_uom,
                    pol.cost_type_id,
                    pol.legal_entity_id,
                    mp.organization_id,
                    ravail.shift_date,
                    cmm.default_lot_cost_type_id
            ) r,
            (
            SELECT  period.cost_type_id,
                    period.legal_entity_id,
                    period.period_id,
                    period.start_date,
                    period.end_date
            FROM    gmf_period_statuses period
            WHERE   period.end_date >= p_start_date
            AND     period.start_date <= p_end_date
            ) cal,
            sy_uoms_mst_v ruom,
            sy_uoms_mst_v rcostuom,
            sy_uoms_mst_v hruom,
            cm_rsrc_dtl rcost
    WHERE   cal.cost_type_id in (r.cost_type_id, r.default_lot_cost_type_id)
    AND     r.legal_entity_id = cal.legal_entity_id
    AND     r.shift_date BETWEEN cal.start_date AND cal.end_date
    AND     rcost.organization_id = r.organization_id
    AND     rcost.resources = r.resources
    AND     rcost.cost_type_id = cal.cost_type_id
    AND     rcost.period_id = cal.period_id
    AND     hruom.uom_code = g_hr_uom
    AND     ruom.uom_code = r.usage_uom
    AND     rcostuom.uom_code = rcost.usage_uom
    GROUP BY
            r.resource_id,
            r.organization_id,
            r.department_id,
            r.shift_date,
            r.usage_uom;

    l_rowcount := sql%rowcount;

    COMMIT;

    bis_collection_utilities.put_line('OPM Resource Availability: ' ||
             l_rowcount || ' rows initially collected into staging table at '||
             to_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    bis_collection_utilities.put_line('Exit initial_opm_res_avail() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

EXCEPTION WHEN OTHERS THEN
--{
   errbuf:= Sqlerrm;
   retcode:= SQLCODE;

   ROLLBACK;

   bis_collection_utilities.put_line('Exception in initial_opm_res_avail ' || errbuf );
--}
END initial_opm_res_avail;


/*======================================================
    This procedure extracts actual resource usage data
    into the staging table for incremental load.

    Parameters:
    - errbuf: error buffer
    - retcode: return code
=======================================================*/

PROCEDURE incremental_opm_res_actual  ( errbuf  IN OUT NOCOPY VARCHAR2,
                                        retcode IN OUT NOCOPY VARCHAR2) IS
    l_stmt_num  NUMBER;
    l_rowcount NUMBER;

BEGIN

    bis_collection_utilities.put_line('Enter incremental_opm_res_actual() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    retcode := g_ok;

    INSERT /*+ APPEND */ INTO opi_dbi_res_actual_stg (
            resource_id,
            organization_id,
            transaction_date,
            uom,
            actual_qty_draft,
            actual_qty,
            actual_qty_g_draft,
            actual_qty_g,
            actual_val_b_draft,
            actual_val_b,
            source,
            job_id,
            job_type,
            assembly_item_id,
            department_id)
    SELECT  rdtl.resource_id                resource_id,
            rtran.organization_id              organization_id,
            trunc(rtran.trans_date)         transaction_date,
            rtran.trans_qty_um                  uom,
            sum(decode(gtv.accounted_flag, 'D', rtran.resource_usage * prod.cost_alloc, 0)) actual_qty_draft,
            sum(decode(gtv.accounted_flag, 'D', 0, rtran.resource_usage * prod.cost_alloc)) actual_qty,
            sum(decode(gtv.accounted_flag, 'D',
              rtran.resource_usage * prod.cost_alloc * hruom.std_factor/ruom.std_factor, 0)) actual_qty_g_draft,
            sum(decode(gtv.accounted_flag, 'D', 0,
              rtran.resource_usage * prod.cost_alloc * hruom.std_factor/ruom.std_factor))   actual_qty_g,
            sum(decode(gtv.accounted_flag, 'D', gtv.txn_base_value * prod.cost_alloc, 0))  actual_val_b_draft,
            sum(decode(gtv.accounted_flag, 'D', 0, gtv.txn_base_value * prod.cost_alloc))  actual_val_b,
            OPM_SOURCE                      source,
            rtran.doc_id                    job_id,
            4                               job_type,
            prod.inventory_item_id           assembly_item_id,
            rmst.resource_class             department_id
    FROM    sy_uoms_mst                 hruom,
            sy_uoms_mst                 ruom,
            gme_resource_txns           rtran,
            cr_rsrc_dtl                 rdtl,
            cr_rsrc_mst_b               rmst,
            gme_material_details        prod,
            (
            SELECT  gtv.transaction_id,
                    gtv.accounted_flag,
                    gtv.txn_base_value
            FROM    gmf_transaction_valuation   gtv,
                    opi_dbi_run_log_curr        log,
                    opi_dbi_org_le_temp         tmp
            WHERE   gtv.accounted_flag is NULL
            AND     gtv.journal_line_type = 'WIP'
            AND     gtv.event_class_code = 'BATCH_RESOURCE'
            AND     gtv.transaction_date >= g_global_start_date
            AND     gtv.final_posting_date >= log.from_bound_date
            AND     gtv.final_posting_date < log.to_bound_date
            AND     log.etl_id = ACTUAL_RES_ETL
            AND     log.source = OPM_SOURCE
            AND     gtv.ledger_id = tmp.ledger_id
            AND     gtv.legal_entity_id = tmp.legal_entity_id
            AND     gtv.valuation_cost_type_id = tmp.valuation_cost_type_id
            AND     gtv.organization_id = tmp.organization_id
            UNION ALL
            SELECT  gtv.transaction_id,
                    gtv.accounted_flag,
                    gtv.txn_base_value
            FROM    gmf_transaction_valuation gtv,
                    opi_dbi_org_le_temp     tmp
            WHERE   gtv.accounted_flag = 'D'
            AND     gtv.journal_line_type = 'WIP'
            AND     gtv.event_class_code = 'BATCH_RESOURCE'
            AND     gtv.transaction_date >= g_global_start_date
            AND     gtv.ledger_id = tmp.ledger_id
            AND     gtv.legal_entity_id = tmp.legal_entity_id
            AND     gtv.valuation_cost_type_id = tmp.valuation_cost_type_id
            AND     gtv.organization_id = tmp.organization_id) gtv
    WHERE   hruom.uom_code = g_hr_uom
    AND     ruom.uom_code = rtran.trans_qty_um
    AND     gtv.transaction_id = rtran.poc_trans_id
    AND     rtran.completed_ind = 1
    AND     rdtl.organization_id = rtran.organization_id
    AND     rdtl.resources = rtran.resources
    AND     rmst.resources = rdtl.resources
    AND     prod.batch_id = rtran.doc_id
    AND     prod.line_type = 1
    GROUP BY
            prod.inventory_item_id,
            rtran.doc_id,
            rdtl.resource_id,
            rmst.resource_class,
            trunc(rtran.trans_date),
            rtran.trans_qty_um,
            rtran.organization_id;

    l_rowcount := sql%rowcount;

    COMMIT;

    bis_collection_utilities.put_line('OPM resource actuals: ' ||
               l_rowcount || ' rows incrementally collected into staging table at ' ||
               To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    bis_collection_utilities.put_line('Exit incremental_opm_res_actual() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

EXCEPTION WHEN OTHERS THEN
--{
   errbuf:= Sqlerrm;
   retcode:= SQLCODE;

   ROLLBACK;

   bis_collection_utilities.put_line('Exception in incremental_opm_res_actual ' || errbuf );
--}
END incremental_opm_res_actual;


/*======================================================
    This procedure extracts resource availability data
    into the staging table for incremental load.

    Parameters:
    - p_start_date: lower run bound
    - p_end_date:   upper run bound
    - errbuf: error buffer
    - retcode: return code
=======================================================*/

PROCEDURE incremental_opm_res_avail  (p_start_date  IN DATE,
                                      p_end_date    IN DATE,
                                      errbuf        IN OUT NOCOPY VARCHAR2,
                                      retcode       IN OUT NOCOPY VARCHAR2)
IS

    l_stmt_num  NUMBER;
    l_rowcount  NUMBER;
    l_start_date DATE;
    l_end_date   DATE;

BEGIN

    bis_collection_utilities.put_line('Enter incremental_opm_res_avail() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    retcode := g_ok;
    l_stmt_num := 10;

    l_start_date := p_start_date;
    l_end_date := p_end_date;

    -- if start_date is not end_date,
    -- start from the day after start_date

    IF (l_start_date <> l_end_date) THEN
    --{
        l_start_date := l_start_date + 1;
    --}
    END IF;


    -- populate availability for opm resource

     INSERT INTO opi_dbi_res_avail_stg (
            resource_id,
            organization_id,
            department_id,
            transaction_date,
            uom,
            avail_qty,
            avail_qty_g,
            avail_val_b,
            source)
    SELECT  r.resource_id            resource_id,
            r.organization_id        organization_id,
            r.department_id          department_id,
            r.shift_date             transaction_date,
            r.usage_uom               uom,
            SUM(r.shift_hours * hruom.std_factor / ruom.std_factor)
                                avail_qty,
            SUM(r.shift_hours) avail_qty_g, -- availability in hours
            SUM(r.shift_hours * hruom.std_factor / rcostuom.std_factor * rcost.nominal_cost)
                                 avail_val_b,
            OPM_SOURCE                         source
    FROM    (
            SELECT  mp.organization_id,
                    rdtl.resources,
                    rdtl.resource_id,
                    rmst.resource_class department_id,
                    rdtl.usage_uom,
                    pol.cost_type_id,
                    cmm.default_lot_cost_type_id,
                    pol.legal_entity_id,
                    ravail.shift_date,
                    SUM((ravail.to_time - ravail.from_time)*ravail.resource_units/3600) shift_hours
            FROM    cr_rsrc_dtl     rdtl,
                    cr_rsrc_mst_b   rmst,
                    gmf_fiscal_policies pol,
                    gmp_resource_avail  ravail,
                    mtl_parameters              mp,
                    org_organization_definitions    org_def,
                    cm_mthd_mst cmm
            WHERE   rmst.resources = rdtl.resources
            AND     rdtl.organization_id = org_def.organization_id
            AND     org_def.legal_entity = pol.legal_entity_id
            AND     ravail.calendar_code = mp.calendar_code
            AND     ravail.organization_id = mp.organization_id
            AND     ravail.organization_id = rdtl.organization_id
            AND     ravail.resource_id = rdtl.resource_id
            AND     nvl(ravail.instance_id,0) = 0 -- resource level row
            AND     NVL(ravail.resource_instance_id,0) = 0 -- exclude individual resource instances
            AND     ravail.shift_date BETWEEN l_start_date AND l_end_date
            AND     ravail.shift_date >= trunc(rdtl.creation_date)
            AND     pol.cost_type_id = cmm.cost_type_id
            GROUP BY
                    rdtl.resources,
                    rdtl.resource_id,
                    rmst.resource_class,
                    rdtl.usage_uom,
                    pol.cost_type_id,
                    pol.legal_entity_id,
                    mp.organization_id,
                    ravail.shift_date,
                    cmm.default_lot_cost_type_id
            ) r,
              (
            SELECT  period.cost_type_id,
                    period.legal_entity_id,
                    period.period_id,
                    period.start_date,
                    period.end_date
            FROM    gmf_period_statuses period
            WHERE   period.end_date >= l_start_date
            AND     period.start_date <= l_end_date
            ) cal,
            sy_uoms_mst_v ruom,
            sy_uoms_mst_v rcostuom,
            sy_uoms_mst_v hruom,
            cm_rsrc_dtl rcost
    WHERE   cal.cost_type_id in (r.cost_type_id, r.default_lot_cost_type_id)
    AND     r.legal_entity_id = cal.legal_entity_id
    AND     r.shift_date BETWEEN cal.start_date AND cal.end_date
    AND     rcost.organization_id = r.organization_id
    AND     rcost.resources = r.resources
    AND     rcost.cost_type_id = cal.cost_type_id
    AND     rcost.period_id = cal.period_id
    AND     hruom.uom_code = g_hr_uom
    AND     ruom.uom_code = r.usage_uom
    AND     rcostuom.uom_code = rcost.usage_uom
    GROUP BY
            r.resource_id,
            r.organization_id,
            r.department_id,
            r.shift_date,
            r.usage_uom;

    l_rowcount := sql%rowcount;

    COMMIT;

    bis_collection_utilities.put_line('OPM resource availability: ' ||
               l_rowcount || ' rows incrementally collected into staging table at ' ||
               To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

     bis_collection_utilities.put_line('Exit incremental_opm_res_avail() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

EXCEPTION WHEN OTHERS THEN
--{
    errbuf:= Sqlerrm;
    retcode:= SQLCODE;

   ROLLBACK;

   bis_collection_utilities.put_line('Exception in incremental_opm_res_avail ' || errbuf );
--}
END incremental_opm_res_avail;



/*======================================================
    This procedure extracts standard resource usage data
    into the staging table for initial load.

    Parameters:
    - errbuf: error buffer
    - retcode: return code
=======================================================*/

PROCEDURE initial_opm_res_std  (errbuf  IN OUT NOCOPY VARCHAR2,
                                retcode IN OUT NOCOPY VARCHAR2,
                                p_degree IN NUMBER    ) IS
    l_stmt_num NUMBER;
    l_rowcount NUMBER;

BEGIN

    bis_collection_utilities.put_line('Enter initial_opm_res_std() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    INSERT INTO opi_dbi_res_std_f (
            resource_id,
            organization_id,
            transaction_date,
            std_usage_qty,
            uom,
            std_usage_qty_g,
            std_usage_val_b,
            std_usage_val_g,
            std_usage_val_sg,
            job_id,
            job_type,
            assembly_item_id,
            department_id,
            source,
            creation_date,
            last_update_date,
            created_by,
            last_updated_by,
            last_update_login,
            program_id,
            program_login_id,
            program_application_id,
            request_id)
    SELECT  /*+ LEADING(CAL) */
            jobres.resource_id                      resource_id,
            jobitem.organization_id                 organization_id,
            jobitem.completion_date                 transaction_date,
            sum(DECODE( jobres.scale_type, 0, jobres.plan_rsrc_usage * jobitem.cost_alloc,
                        DECODE(jobitem.plan_qty,0,0,((jobres.plan_rsrc_usage * jobitem.cost_alloc) / jobitem.plan_qty)) * jobitem.actual_qty))                                      std_usage_qty,
            jobres.usage_uom                         uom,
   sum(DECODE( jobres.scale_type, 0, jobres.plan_rsrc_usage_g * jobitem.cost_alloc,
                        DECODE(jobitem.plan_qty,0,0,((jobres.plan_rsrc_usage_g * jobitem.cost_alloc) / jobitem.plan_qty)) * jobitem.actual_qty))                                    std_usage_qty_g,
            sum(DECODE(jobres.scale_type, 0, jobres.plan_rsrc_usage_g * jobitem.cost_alloc,
                        DECODE(jobitem.plan_qty,0,0,((jobres.plan_rsrc_usage_g * jobitem.cost_alloc) / jobitem.plan_qty)) * jobitem.actual_qty) * jobres_uom.std_factor / rescost_uom.std_factor * rescost.nominal_cost)
                                                    std_usage_val_b,
            sum(DECODE(jobres.scale_type,
               0, jobres.plan_rsrc_usage_g * jobitem.cost_alloc,
                DECODE(jobitem.plan_qty,0,0,((jobres.plan_rsrc_usage_g * jobitem.cost_alloc) / jobitem.plan_qty)) * jobitem.actual_qty
               ) * jobres_uom.std_factor / rescost_uom.std_factor * rescost.nominal_cost
                 * jobitem.conversion_rate)         std_usage_val_g,
            sum(DECODE(jobres.scale_type,
               0, jobres.plan_rsrc_usage_g * jobitem.cost_alloc,
                DECODE(jobitem.plan_qty,0,0,((jobres.plan_rsrc_usage_g * jobitem.cost_alloc) / jobitem.plan_qty)) * jobitem.actual_qty
               ) * jobres_uom.std_factor / rescost_uom.std_factor * rescost.nominal_cost
                 * jobitem.sec_conversion_rate)     std_usage_val_sg,
            jobitem.job_id                          job_id,
            jobitem.job_type                        job_type,
            jobitem.assembly_item_id                assembly_item_id,
            jobres.department_id                    department_id,
            jobitem.source                          source,
            sysdate,
            sysdate,
            g_user_id,
            g_user_id,
            g_login_id,
            g_program_id,
            g_program_login_id,
            g_program_application_id,
            g_request_id
    FROM
        (
            SELECT  job.organization_id,
                    job.assembly_item_id,
                    bmatl.plan_qty,
                    bmatl.actual_qty,
                    bmatl.cost_alloc,
                    job.job_id,
                    job.completion_date,
                    job.conversion_rate,
                    job.sec_conversion_rate,
                    job.job_type,
                    job.source
            FROM    opi_dbi_jobs_f job,
                    mtl_system_items_b msi,
                    gme_material_details bmatl
            WHERE   job.job_type = 4
            AND     job.std_res_flag = 1
            AND     bmatl.batch_id = job.job_id
            AND     bmatl.line_type = 1                    -- coproducts
            AND     msi.inventory_item_id = job.assembly_item_id
            AND     msi.organization_id = job.organization_id
            AND     bmatl.inventory_item_id = msi.inventory_item_id
        ) jobitem,
        (
            SELECT
                    job.job_id,
                    job.assembly_item_id,
                    bres.scale_type,
                    resdtl.usage_uom,
                    resdtl.resource_id,
                    resdtl.organization_id,
                    resdtl.resources,
                    resmst.resource_class department_id,
                    bres.plan_rsrc_usage * bresuom.std_factor / ruom.std_factor  plan_rsrc_usage,
                    bres.plan_rsrc_usage * bresuom.std_factor / hruom.std_factor plan_rsrc_usage_g,
                    pol.cost_type_id,
                    cmm.default_lot_cost_type_id,
                    pol.legal_entity_id
            FROM    opi_dbi_jobs_f job,
                    gme_batch_header bhdr,
                    gme_batch_steps bstep,
                    gme_batch_step_resources bres,
                    cr_rsrc_dtl resdtl,
                    cr_rsrc_mst_b resmst,
                    gmf_fiscal_policies pol,
                    sy_uoms_mst_v bresuom,
                    sy_uoms_mst_v ruom,
                    sy_uoms_mst_v hruom,
                    org_organization_definitions org_def,
                    cm_mthd_mst cmm
            WHERE
                    job.std_res_flag = 1
            AND     job.job_type = 4
            AND     bhdr.batch_id = job.job_id
            AND     bstep.batch_id = job.job_id
            AND     bres.batchstep_id = bstep.batchstep_id
            AND     resdtl.organization_id= bhdr.organization_id
            AND     resdtl.resources = bres.resources
            AND     resmst.resources = resdtl.resources
            AND     bresuom.uom_code = bres.usage_um
            AND     ruom.uom_code = resdtl.usage_uom
            AND     hruom.uom_code = g_hr_uom
            AND     bhdr.organization_id = org_def.organization_id
            AND     org_def.legal_entity = pol.legal_entity_id
            AND     pol.cost_type_id = cmm.cost_type_id
        ) jobres,
         (
            SELECT  period.cost_type_id,
                    period.legal_entity_id,
                    period.period_id,
                    period.start_date,
                    period.end_date
            FROM    gmf_period_statuses period
            WHERE   period.end_date >= g_global_start_date
            AND     period.start_date <= sysdate
            ) cal,
        cm_rsrc_dtl     rescost,
        sy_uoms_mst_v     jobres_uom,
        sy_uoms_mst_v     rescost_uom
    WHERE   jobres.job_id = jobitem.job_id -- combine all batch resources with all batch coproducts
    AND     jobres.assembly_item_id = jobitem.assembly_item_id
    AND     cal.cost_type_id in (jobres.cost_type_id, jobres.default_lot_cost_type_id)
    AND     cal.legal_entity_id = jobres.legal_entity_id
    AND     jobitem.completion_date BETWEEN cal.start_date AND cal.end_date
    AND     rescost.resources = jobres.resources
    AND     rescost.organization_id = jobres.organization_id
    AND     rescost.period_id = cal.period_id
    AND     rescost.cost_type_id = cal.cost_type_id
    AND     jobres_uom.uom_code = jobres.usage_uom
    AND     rescost_uom.uom_code = rescost.usage_uom
    GROUP BY
            jobitem.organization_id,
            jobres.department_id,
            jobitem.job_id,
            jobitem.job_type,
            jobitem.assembly_item_id,
            jobres.usage_uom,
            jobres.resource_id,
            jobitem.completion_date,
            jobitem.source;

    l_rowcount := SQL%ROWCOUNT;

    COMMIT;

     bis_collection_utilities.put_line('OPM resource std: ' ||
               l_rowcount || ' rows initially collected into fact table at ' ||
               To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    bis_collection_utilities.put_line('Exit initial_opm_res_std() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

EXCEPTION WHEN OTHERS THEN

    errbuf:= Sqlerrm;
    retcode:= SQLCODE;

    ROLLBACK;
    bis_collection_utilities.wrapup(p_status => FALSE,
                                    p_count => 0,
                                    p_message => 'Failed in initial_opm_res_std.');

    RAISE_APPLICATION_ERROR(-20000,errbuf);

END initial_opm_res_std;


/*======================================================
    This procedure extracts standard resource usage data
    into the staging table for incremental load.

    Parameters:
    - errbuf: error buffer
    - retcode: return code
=======================================================*/
PROCEDURE incremental_opm_res_std  (errbuf IN OUT NOCOPY varchar2,
                                    retcode in out NOCOPY VARCHAR2  ) IS
    l_stmt_num NUMBER;
    l_rowcount NUMBER;


BEGIN

    bis_collection_utilities.put_line('Enter incremental_opm_res_std() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    DELETE  opi_dbi_res_std_f std
    WHERE   (job_id, job_type)
    IN      (SELECT job_id,
                    job_type
            FROM    opi_dbi_jobs_f
            WHERE   std_res_flag = 1
            AND     job_type = 4); -- need to extract again

     INSERT INTO opi_dbi_res_std_f
        (resource_id,
        organization_id,
        transaction_date,
        std_usage_qty,
        uom,
        std_usage_qty_g,
        std_usage_val_b,
        std_usage_val_g,
        std_usage_val_sg,
        job_id,
        job_type,
        assembly_item_id,
        department_id,
        source,
        creation_date,
        last_update_date,
        created_by,
        last_updated_by,
        last_update_login,
        program_id,
        program_login_id,
        program_application_id,
        request_id)
    SELECT /*+ LEADING(CAL) */
        jobres.resource_id                       resource_id,
        jobitem.organization_id                  organization_id,
        jobitem.completion_date                  transaction_date,
        sum(DECODE(jobres.scale_type,
          0, jobres.plan_rsrc_usage * jobitem.cost_alloc,
           DECODE(jobitem.plan_qty,0,0,((jobres.plan_rsrc_usage * jobitem.cost_alloc) / jobitem.plan_qty)) * jobitem.actual_qty
          ))                                      std_usage_qty,
        jobres.usage_uom                          uom,
        sum(DECODE(jobres.scale_type,
          0, jobres.plan_rsrc_usage_g * jobitem.cost_alloc,
           DECODE(jobitem.plan_qty,0,0,((jobres.plan_rsrc_usage_g * jobitem.cost_alloc) / jobitem.plan_qty)) * jobitem.actual_qty
          ))                                      std_usage_qty_g,
        sum(DECODE(jobres.scale_type,
               0, jobres.plan_rsrc_usage_g * jobitem.cost_alloc,
            DECODE(jobitem.plan_qty,0,0,((jobres.plan_rsrc_usage_g * jobitem.cost_alloc) / jobitem.plan_qty)) * jobitem.actual_qty
               ) * jobres_uom.std_factor / rescost_uom.std_factor * rescost.nominal_cost)
                                                 std_usage_val_b,
        sum(DECODE(jobres.scale_type,
               0, jobres.plan_rsrc_usage_g * jobitem.cost_alloc,
            DECODE(jobitem.plan_qty,0,0,((jobres.plan_rsrc_usage_g * jobitem.cost_alloc) / jobitem.plan_qty)) * jobitem.actual_qty
         ) * jobres_uom.std_factor / rescost_uom.std_factor * rescost.nominal_cost
                 * jobitem.conversion_rate)       std_usage_val_g,
        sum(DECODE(jobres.scale_type,
               0, jobres.plan_rsrc_usage_g * jobitem.cost_alloc,
             DECODE(jobitem.plan_qty,0,0,((jobres.plan_rsrc_usage_g * jobitem.cost_alloc) / jobitem.plan_qty)) * jobitem.actual_qty
               ) * jobres_uom.std_factor / rescost_uom.std_factor * rescost.nominal_cost
                 * jobitem.sec_conversion_rate)       std_usage_val_sg,
        jobitem.job_id                           job_id,
        jobitem.job_type                         job_type,
        jobitem.assembly_item_id                 assembly_item_id,
        jobres.department_id                     department_id,
        jobitem.source                           source,
        sysdate,
        sysdate,
        g_user_id,
        g_user_id,
        g_login_id,
        g_program_id,
        g_program_login_id,
        g_program_application_id,
        g_request_id
  FROM
        (
            SELECT
                job.organization_id,
                job.assembly_item_id,
                bmatl.plan_qty,
                bmatl.actual_qty,
                bmatl.cost_alloc,
                job.job_id,
                job.completion_date,
                job.conversion_rate,
                job.sec_conversion_rate,
                job.job_type,
                job.source
            FROM
                opi_dbi_jobs_f job,
                mtl_system_items_b msi,
                gme_material_details bmatl
            WHERE
                job.job_type = 4
            AND job.std_res_flag = 1
            AND bmatl.batch_id = job.job_id
            AND bmatl.line_type = 1                    -- coproducts
            AND msi.inventory_item_id = job.assembly_item_id
            AND msi.organization_id = job.organization_id
            AND bmatl.inventory_item_id = msi.inventory_item_id
        ) jobitem,
        (
            SELECT
                job.job_id,
                job.assembly_item_id,
                bres.scale_type,
                resdtl.usage_uom,
                resdtl.resource_id,
                resdtl.organization_id,
                resdtl.resources,
                resmst.resource_class department_id,
                bres.plan_rsrc_usage * bresuom.std_factor / ruom.std_factor  plan_rsrc_usage,
                bres.plan_rsrc_usage * bresuom.std_factor / hruom.std_factor plan_rsrc_usage_g,
                pol.cost_type_id,
                cmm.default_lot_cost_type_id,
                pol.legal_entity_id
            FROM
                opi_dbi_jobs_f job,
                gme_batch_header bhdr,
                gme_batch_steps bstep,
                gme_batch_step_resources bres,
                cr_rsrc_dtl resdtl,
                cr_rsrc_mst_b resmst,
                gmf_fiscal_policies pol,
                sy_uoms_mst_v bresuom,
                sy_uoms_mst_v ruom,
                sy_uoms_mst_v hruom,
                org_organization_definitions org_def,
                cm_mthd_mst cmm
            WHERE
                job.std_res_flag = 1
            AND job.job_type = 4
            AND bhdr.batch_id = job.job_id
            AND bstep.batch_id = job.job_id
            AND bres.batchstep_id = bstep.batchstep_id
            AND resdtl.organization_id = bhdr.organization_id
            AND resdtl.resources = bres.resources
            AND resmst.resources = resdtl.resources
            AND bresuom.uom_code = bres.usage_um
            AND ruom.uom_code = resdtl.usage_uom
            AND hruom.uom_code = g_hr_uom
            AND bhdr.organization_id = org_def.organization_id
            AND org_def.legal_entity = pol.legal_entity_id
            AND pol.cost_type_id = cmm.cost_type_id
        ) jobres,
        (
            SELECT  period.cost_type_id,
                    period.legal_entity_id,
                    period.period_id,
                    period.start_date,
                    period.end_date
            FROM    gmf_period_statuses period
            WHERE   period.end_date >= g_global_start_date
            AND     period.start_date <= sysdate
            ) cal,
        cm_rsrc_dtl rescost,
        sy_uoms_mst_v jobres_uom,
        sy_uoms_mst_v rescost_uom
    WHERE
        jobres.job_id = jobitem.job_id -- combine all batch resources with all batch coproducts
    AND jobres.assembly_item_id = jobitem.assembly_item_id
    AND cal.cost_type_id in (jobres.cost_type_id, jobres.default_lot_cost_type_id)
    AND cal.legal_entity_id = jobres.legal_entity_id
    AND jobitem.completion_date BETWEEN cal.start_date AND cal.end_date
    AND rescost.resources = jobres.resources
    AND rescost.organization_id = jobres.organization_id
    AND rescost.period_id = cal.period_id
    AND rescost.cost_type_id = cal.cost_type_id
    AND jobres_uom.uom_code = jobres.usage_uom
    AND rescost_uom.uom_code = rescost.usage_uom
    GROUP BY
       jobitem.organization_id,
       jobres.department_id,
       jobitem.job_id,
       jobitem.job_type,
       jobitem.assembly_item_id,
       jobres.usage_uom,
       jobres.resource_id,
       jobitem.completion_date,
       jobitem.source;

    l_rowcount := sql%rowcount;

    bis_collection_utilities.put_line('OPM resource std: ' ||
               l_rowcount || ' rows incrementally collected into staging table at ' ||
               to_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    bis_collection_utilities.put_line('Exit incremental_opm_res_std() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

EXCEPTION WHEN OTHERS THEN
--{
    errbuf:= Sqlerrm;
    retcode:= SQLCODE;

    ROLLBACK;
    bis_collection_utilities.wrapup(p_status => FALSE,
                   p_count => 0,
                   p_message => 'Failed in incremental_opm_res_std.'
                   );

    RAISE_APPLICATION_ERROR(-20000,errbuf);
--}
END incremental_opm_res_std;



/*======================================================================
    This is the wrapper procedure for Resource initial load which extracts
    actual resource usage and resource availability data for discrete
    and process organizations.

    Parameters:
    - errbuf: error buffer
    - retcode: return code
    - p_degree: degree
=======================================================================*/

PROCEDURE initial_load_res_utl (errbuf  IN OUT NOCOPY VARCHAR2,
                                retcode IN OUT NOCOPY VARCHAR2,
                                p_degree       NUMBER     ) IS
    l_stmt_num NUMBER;
    l_row_count NUMBER;
    l_err_num NUMBER;
    l_err_msg VARCHAR2(255);
    l_error_flag  BOOLEAN;

    l_opi_schema      VARCHAR2(30);
    l_status          VARCHAR2(30);
    l_industry        VARCHAR2(30);

    l_comm_opi_avail_flag   BOOLEAN;
    l_comm_opm_avail_flag   BOOLEAN;
    l_comm_opi_actual_flag   BOOLEAN;
    l_comm_opm_actual_flag   BOOLEAN;

    l_opi_start_date    DATE;
    l_opi_end_date      DATE;

    l_opm_start_date    opi_dbi_run_log_curr.from_bound_date%type;
    l_opm_end_date      opi_dbi_run_log_curr.to_bound_date%type;

    l_r12_mgr_date      opi_dbi_conc_prog_run_log.last_run_date%type;

    SCHEMA_INFO_NOT_FOUND   exception;
BEGIN

    -- initialization block
    l_error_flag := FALSE;
    l_comm_opi_avail_flag := FALSE;
    l_comm_opm_avail_flag := FALSE;
    l_comm_opi_actual_flag := FALSE;
    l_comm_opm_actual_flag := FALSE;

    IF BIS_COLLECTION_UTILITIES.SETUP( 'OPI_DBI_RES_AVAIL_F' ) = false then
    --{
        RAISE_APPLICATION_ERROR(-20000, errbuf);
    --}
    END IF;

    -- Performance tuning change
    execute immediate 'alter session set hash_area_size=100000000 ';
    execute immediate 'alter session set sort_area_size=100000000 ';

    bis_collection_utilities.put_line('Initial Load starts at  '
                     || To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    -- setup globals
    bis_collection_utilities.put_line('Setup Global Parameters ....');
    l_stmt_num :=10;
    check_setup_globals(errbuf => errbuf, retcode => retcode);

    IF retcode <> 0 THEN
    --{
        RETURN ;
    --}
    END IF;

     -- common clean up
    l_stmt_num := 20;

    IF fnd_installation.get_app_info( 'OPI', l_status, l_industry, l_opi_schema) THEN
    --{
        execute immediate 'truncate table ' || l_opi_schema
        || '.opi_dbi_res_conv_rates ';

        execute immediate 'truncate table ' || l_opi_schema
        || '.opi_dbi_res_avail_stg ';

        execute immediate 'truncate table ' || l_opi_schema
        || '.opi_dbi_res_actual_stg ';

        execute immediate 'truncate table ' || l_opi_schema
        || '.opi_dbi_res_avail_f PURGE MATERIALIZED VIEW LOG  ';

         execute immediate 'truncate table ' || l_opi_schema
        || '.opi_dbi_res_actual_f PURGE MATERIALIZED VIEW LOG ';
    --}
    ELSE
    --{
        RAISE SCHEMA_INFO_NOT_FOUND;
    --}
    END IF;


    /*** Collect Actual Resource Usage Data ***/

    -- Load discrete actual data to Staging table
    bis_collection_utilities.put_line('Load discrete resource actual into staging ...');

    l_stmt_num := 30;
    initial_opi_res_actual(errbuf => errbuf, retcode => retcode);

    IF retcode <> 0 THEN
    --{
        l_error_flag := TRUE;
    --}
    END IF;

    -- Get R12 migration date.  If GSD < R12 migration date,
    -- get OPM data from Pre R12 data model

    BEGIN
        SELECT  last_run_date
        INTO    l_r12_mgr_date
        FROM    opi_dbi_conc_prog_run_log
        WHERE   etl_type = 'R12_MIGRATION';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        --{
            l_r12_mgr_date := g_global_start_date;
        --}
    END;

    IF (g_global_start_date < l_r12_mgr_date) THEN
    --{
        bis_collection_utilities.put_line('Load process pre-r12 resource actual into staging ... ');
        opi_dbi_pre_r12_res_pkg.pre_r12_opm_res_actual(errbuf => errbuf, retcode => retcode);
    --}
    END IF;

    -- get OPM data from R12 data model
    l_stmt_num := 35;

    -- Call API to load ledger data into Global temp table
    -- This temp table will be joined to extract process adjustments
    bis_collection_utilities.put_line('Loading Ledger data into temp table');
    opi_dbi_bounds_pkg.load_opm_org_ledger_data;

    -- Committing the data. Since the temp table is made with On Commit preserve rows
    -- there will be no problem.
    commit;

    l_stmt_num := 40;
    bis_collection_utilities.put_line('Load process resource actual into staging ... ');
    initial_opm_res_actual(errbuf => errbuf, retcode => retcode);

    IF retcode <> 0 THEN
    --{
        l_error_flag := TRUE;
    --}
    END IF;


    /*** Collect Resource Availability Data ***/

    -- Get discrete and process availability date bounds
    l_stmt_num := 50;


    BEGIN
        SELECT  trunc(from_bound_date), trunc(to_bound_date)
        INTO    l_opi_start_date, l_opi_end_date
        FROM    opi_dbi_run_log_curr
        WHERE   etl_id = RESOURCE_VAR_ETL
        AND     source = OPI_SOURCE;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        --{
            RAISE NO_DATA_FOUND;
        --}
    END;

    BEGIN
        SELECT  trunc(from_bound_date), trunc(to_bound_date)
        INTO    l_opm_start_date, l_opm_end_date
        FROM    opi_dbi_run_log_curr
        WHERE   etl_id = RESOURCE_VAR_ETL
        AND     source = OPM_SOURCE;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        --{
            RAISE NO_DATA_FOUND;
        --}
    END;


    -- Load discrete availability data into Staging table
    bis_collection_utilities.put_line('Load discrete res avail into staging ');

     l_stmt_num := 60;
    initial_opi_res_avail(p_start_date => l_opi_start_date,
                          p_end_date => l_opi_end_date,
                          errbuf => errbuf,
                          retcode => retcode);

    IF retcode <> 0 THEN
    --{
        l_error_flag := TRUE;
    --}
    END IF;


    -- Load process availability data into Staging table
    bis_collection_utilities.put_line('Load process res avail into staging ');

    l_stmt_num := 70;
    initial_opm_res_avail(p_start_date => l_opm_start_date,
                          p_end_date => l_opm_end_date,
                          errbuf => errbuf,
                          retcode => retcode);

    IF retcode <> 0 THEN
    --{
        l_error_flag := TRUE;
    --}
    END IF;


    -- For improve perf, need to commit in stg/conversion rate tables
    -- and gather statistics
    commit;

    gather_stats(p_table_name => 'OPI_DBI_RES_ACTUAL_STG');

    gather_stats(p_table_name => 'OPI_DBI_RES_AVAIL_STG');

    get_res_conversion_rate(errbuf => errbuf, retcode => retcode );

    commit;

    --gather_stats(p_table_name => 'OPI_DBI_RES_CONV_RATES');


    IF l_error_flag <> TRUE THEN
    --{
        -- load Actual data into Fact
        l_stmt_num := 80;

        bis_collection_utilities.put_line('Initially load actual data from staging to actual fact ...');

        INSERT /*+ append parallel(c) */
        INTO opi_dbi_res_actual_f c (
            resource_id,
            department_id,
            organization_id,
            uom,
            actual_qty_draft,
            actual_qty,
            actual_qty_g_draft,
            actual_qty_g,
            actual_val_b_draft,
            actual_val_b,
            actual_val_g,
            actual_val_sg,
            job_id,
            job_type,
            assembly_item_id,
            source,
            creation_date,
            last_update_date,
            created_by,
            last_updated_by,
            last_update_login,
            program_id,
            program_login_id,
            program_application_id,
            request_id )
        SELECT   /*+ use_hash(stg) parallel(stg)
                     use_hash(rate) parallel(rate) */
            stg.resource_id,
            stg.department_id,
            stg.organization_id,
            stg.uom,
            sum (stg.actual_qty_draft)                      actual_qty_draft,
            sum (stg.actual_qty_draft + stg.actual_qty)     actual_qty,
            sum (stg.actual_qty_g_draft)                    actual_qty_g_draft,
            sum (stg.actual_qty_g_draft + stg.actual_qty_g) actual_qty_g,
            sum (stg.actual_val_b_draft)                    actual_val_b_draft,
            sum (stg.actual_val_b_draft + stg.actual_val_b) actual_val_b,
            sum ((stg.actual_val_b_draft  + stg.actual_val_b)
                * rate.conversion_rate)                     actual_val_g,
            sum ((stg.actual_val_b_draft + stg.actual_val_b)
                * rate.sec_conversion_rate)                 actual_val_sg,
            stg.job_id,
            stg.job_type,
            stg.assembly_item_id,
            stg.source,
            sysdate,
            sysdate,
            g_user_id,
            g_user_id,
            g_login_id,
            g_program_id,
            g_program_login_id,
             g_program_application_id,
            g_request_id
        FROM
            opi_dbi_res_actual_stg      stg,
            opi_dbi_res_conv_rates rate
        WHERE
            stg.organization_id = rate.organization_id
        AND stg.transaction_date  = rate.transaction_date
        GROUP BY
                stg.resource_id,
                stg.department_id,
                stg.organization_id,
                stg.job_id,
                stg.job_type,
                stg.assembly_item_id,
                stg.source,
                stg.uom;

        l_row_count := sql%rowcount;

        bis_collection_utilities.put_line('Load res actual ' || l_row_count ||
                    ' rows into FACT '
                    || To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));
     --}
    ELSE
    --{
        bis_collection_utilities.put_line('Failed to load res actual data to fact');
    -->
    END IF;



    -- Load Actual and Availability data in to Fact table
    IF l_error_flag <> TRUE THEN
    --{
        l_stmt_num := 90;

        bis_collection_utilities.put_line('Initially load actual and avail data from staging to avail fact ...');

        INSERT /*+ append parallel(b) */
        INTO opi_dbi_res_avail_f b (
                resource_id,
                department_id,
                organization_id,
                transaction_date,
                uom,
                avail_qty,
                avail_qty_g,
                avail_val_b,
                avail_val_g,
                avail_val_sg,
                actual_qty_draft,
                actual_qty,
                actual_qty_g_draft,
                actual_qty_g,
                actual_val_b_draft,
                actual_val_b,
                actual_val_g,
                actual_val_sg,
                source,
                creation_date,
                last_update_date,
                created_by,
                last_updated_by,
                last_update_login,
                program_id,
                program_login_id,
                program_application_id,
                request_id)
        SELECT  res.resource_id,
                res.department_id,
                res.organization_id,
                res.transaction_date,
                max (res.uom),
                sum (res.avail_qty),
                sum (res.avail_qty_g),
                sum (res.avail_val_b),
                sum (res.avail_val_g),
                sum (res.avail_val_sg),
                sum (res.actual_qty_draft),
                sum (res.actual_qty),
                sum (res.actual_qty_g_draft),
                sum (res.actual_qty_g),
                sum (res.actual_val_b_draft),
                sum (res.actual_val_b),
                sum (res.actual_val_g),
                sum (res.actual_val_sg),
                max (res.source),
                sysdate,
                sysdate,
                g_user_id,
                g_user_id,
                g_login_id,
                g_program_id,
                g_program_login_id,
                g_program_application_id,
                g_request_id
        FROM
                (SELECT  /*+ use_hash(stg) parallel(stg)
                         use_hash(rate) parallel(rate) */
                        stg.resource_id,
                        stg.department_id,
                        stg.organization_id,
                         stg.transaction_date,
                        MAX (stg.uom)   uom,
                        NULL avail_qty,
                        NULL avail_qty_g,
                        NULL avail_val_b,
                        NULL avail_val_g,
                        NULL avail_val_sg,
                        SUM (stg.actual_qty_draft)                      actual_qty_draft,
                        SUM (stg.actual_qty_draft + stg.actual_qty)     actual_qty,
                        SUM (stg.actual_qty_g_draft)                    actual_qty_g_draft,
                        SUM (stg.actual_qty_g_draft + stg.actual_qty_g) actual_qty_g,
                        SUM (stg.actual_val_b_draft)                    actual_val_b_draft,
                        SUM (stg.actual_val_b_draft + stg.actual_val_b) actual_val_b,
                        SUM ((stg.actual_val_b_draft + stg.actual_val_b)
                            * rate.conversion_rate)                     actual_val_g,
                        sum ((stg.actual_val_b_draft + stg.actual_val_b)
                            * rate.sec_conversion_rate)                 actual_val_sg,
                        MAX (stg.source) source
                FROM    opi_dbi_res_actual_stg stg,
                        opi_dbi_res_conv_rates rate
                WHERE   stg.organization_id = rate.organization_id
                AND     stg.transaction_date  = rate.transaction_date
                GROUP BY
                        stg.resource_id,
                        stg.department_id,
                        stg.organization_id,
                        stg.transaction_date
                UNION ALL
                SELECT /*+ use_hash(stg) parallel(stg)
                        use_hash(rate) parallel(rate) */
                        stg.resource_id,
                        stg.department_id,
                        stg.organization_id,
                        stg.transaction_date,
                        stg.uom,
                        stg.avail_qty,
                        stg.avail_qty_g,
                        stg.avail_val_b,
                        stg.avail_val_b * rate.conversion_rate avail_val_g,
                        stg.avail_val_b * rate.sec_conversion_rate avail_val_sg,
                        NULL actual_qty_draft,
                        NULL actual_qty,
                        NULL actual_qty_g_draft,
                        NULL actual_qty_g,
                        NULL actual_val_b_draft,
                        NULL actual_val_b,
                        NULL actual_val_g,
                        NULL actual_val_sg,
                        stg.source
                 FROM   opi_dbi_res_avail_stg stg,
                        opi_dbi_res_conv_rates rate
                WHERE   stg.organization_id = rate.organization_id
                AND     stg.transaction_date  = rate.transaction_date
                ) res
          GROUP BY
                res.resource_id,
                res.department_id,
                res.organization_id,
                res.transaction_date;

        l_row_count := SQL%rowcount;
        bis_collection_utilities.put_line('Load res avail into FACT ' ||
                l_row_count || ' rows, completed at '
                || To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));


        -- update common modules for OPI
        l_comm_opi_avail_flag := opi_dbi_common_mod_incr_pkg.etl_report_success(p_etl_id => RESOURCE_VAR_ETL,
                                                                                p_source => 1);
        l_comm_opm_avail_flag := opi_dbi_common_mod_incr_pkg.etl_report_success(p_etl_id => RESOURCE_VAR_ETL,
                                                                                p_source => 2);

        l_comm_opi_actual_flag := opi_dbi_common_mod_incr_pkg.etl_report_success(p_etl_id => ACTUAL_RES_ETL,
                                                                                 p_source => 1);
        l_comm_opm_actual_flag := opi_dbi_common_mod_incr_pkg.etl_report_success(p_etl_id => ACTUAL_RES_ETL,
                                                                                 p_source => 2);

        IF l_comm_opi_avail_flag AND l_comm_opm_avail_flag
            AND l_comm_opi_actual_flag AND l_comm_opm_actual_flag THEN
        --{
            COMMIT;

            execute immediate 'truncate table ' || l_opi_schema
                              || '.opi_dbi_res_conv_rates ';

            execute immediate 'truncate table ' || l_opi_schema
                              || '.opi_dbi_res_avail_stg ';

            execute immediate 'truncate table ' || l_opi_schema
                              || '.opi_dbi_res_actual_stg ';

            bis_collection_utilities.WRAPUP(p_status => TRUE,
                                            p_count => l_row_count,
                                            p_message => 'successful in initial_load_res_utl.');
        --}
        ELSE
        --{
            retcode := g_error ;
            errbuf  := 'Error in report to common modules. Please check log file for details.';

            rollback;

            bis_collection_utilities.put_line('Error in initial_load_res_utl at ' || l_stmt_num);
            bis_collection_utilities.wrapup(p_status => FALSE,
                 p_count => 0,
                   p_message => 'failed in initial_load_res_utl.'
                   );
        --}
        END IF;
    ELSE
    --{
        rollback;
        retcode := g_error ;
        errbuf  := 'Please check log file for details.';
        bis_collection_utilities.put_line('Error in initial_load_res_utl at ' || l_stmt_num);
        bis_collection_utilities.wrapup(p_status => FALSE,
                   p_count => 0,
                   p_message => 'failed in initial_load_res_utl.');
    --}
    END IF;

    bis_collection_utilities.put_line('Exit initial_load_res_utl() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));


EXCEPTION
--{
    WHEN SCHEMA_INFO_NOT_FOUND THEN
    --{
        bis_collection_utilities.put_line('Schema information was not found.');
    --}
    WHEN OTHERS THEN
    --{
    Errbuf:= Sqlerrm;
    Retcode:= SQLCODE;
    ROLLBACK;
    bis_collection_utilities.put_line('Error in initial_load_res_utl at ' || l_stmt_num);
    bis_collection_utilities.wrapup(p_status => FALSE,
                   p_count => 0,
                   p_message => 'failed in initial_load_res_utl.'
                   );

    RAISE_APPLICATION_ERROR(-20000,errbuf);
    --}
--}
END initial_load_res_utl;


/*======================================================================
    This is the incremental procedure to extract resource standard usage
    data for discrete organizations.

    Parameters:
    - errbuf: error buffer
    - retcode: return code
=======================================================================*/

PROCEDURE incremental_opi_res_std (errbuf   IN OUT NOCOPY VARCHAR2,
                                   retcode  IN OUT NOCOPY VARCHAR2  ) IS
    l_count number;

BEGIN

    bis_collection_utilities.put_line('Enter incremental_opi_res_std() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    retcode := 0;

    DELETE  opi_dbi_res_std_f std
    WHERE   (job_id, job_type)
    IN      (SELECT job_id,
                    job_type
            FROM    opi_dbi_jobs_f
            WHERE   std_res_flag = 1 -- need to extract again
            AND     source = OPI_SOURCE);

    INSERT INTO opi_dbi_res_std_f (
        resource_id,
        department_id,
        organization_id,
        transaction_date,
        uom,
        std_usage_qty,
        std_usage_qty_g,
        std_usage_val_b,
        std_usage_val_g,
        std_usage_val_sg,
        job_id,
        job_type,
        assembly_item_id,
        source,
        creation_date,
        last_update_date,
        created_by,
        last_updated_by,
        last_update_login,
        program_id,
        program_login_id,
        program_application_id,
        request_id)
    SELECT
        wor.resource_id,
        nvl(bdr.share_from_dept_id, wo.department_id),
        job.organization_id,
        trunc (job.completion_date) transaction_date,
        br.unit_of_measure uom,
        SUM (Decode (basis_type,
                     1, wor.usage_rate_or_amount * job.actual_qty_completed,
                      2, wor.usage_rate_or_amount ) )  std_usage_qty,
        SUM (Decode (basis_type,
                     1, wor.usage_rate_or_amount * job.actual_qty_completed,
                     2, wor.usage_rate_or_amount )/
            m.conversion_rate * m2.conversion_rate ) std_usage_qty_g,
        SUM (Decode (basis_type,
                     1, wor.usage_rate_or_amount * job.actual_qty_completed,
                     2, wor.usage_rate_or_amount ) * crc.resource_rate )
            std_usage_val_b,
        SUM (Decode (basis_type,
                     1, wor.usage_rate_or_amount * job.actual_qty_completed,
                     2, wor.usage_rate_or_amount ) * crc.resource_rate *
            job.conversion_rate )  std_usage_val_g,
        SUM (Decode (basis_type,
                     1, wor.usage_rate_or_amount * job.actual_qty_completed,
                     2, wor.usage_rate_or_amount ) * crc.resource_rate *
            job.sec_conversion_rate )  std_usage_val_sg,
        job.job_id,
        job.job_type,
        job.assembly_item_id,
        OPI_SOURCE source,
        sysdate,
        sysdate,
        g_user_id,
        g_user_id,
        g_login_id,
        g_program_id,
        g_program_login_id,
        g_program_application_id,
        g_request_id
      FROM  wip_operation_resources wor,
            wip_operations wo,
            opi_dbi_jobs_f job,
            bom_resources br,
            mtl_parameters mp,
            mtl_uom_conversions m,
            mtl_uom_conversions m2,
            cst_resource_costs crc,
            bom_department_resources bdr
      WHERE job.job_type IN (1,2,5) -- Discrete and Repetitive also OSFM
        AND job.std_res_flag = 1
        AND job.source = 1
        AND wor.organization_id = job.organization_id
        AND job.job_id = Nvl(wor.repetitive_schedule_id, wor.wip_entity_id)
        AND br.resource_id = wor.resource_id
        AND wo.organization_id = wor.organization_id
        AND wo.wip_entity_id = wor.wip_entity_id
        AND wo.operation_seq_num = wor.operation_seq_num
        AND nvl (wo.repetitive_schedule_id, -999) =
                    nvl (wor.repetitive_schedule_id, -999)
        AND m.inventory_item_id = 0
        AND m.uom_code = g_hr_uom
         AND m2.uom_code          = br.unit_of_measure
        AND m2.uom_class         = m.uom_class
        AND m2.inventory_item_id  = 0
        AND mp.organization_id   = wor.organization_id
        AND crc.resource_id      = br.resource_id
        AND crc.organization_id  = mp.organization_id
        AND bdr.resource_id      = wor.resource_id
        AND bdr.department_id    = wo.department_id
        AND (   (mp.primary_cost_method = 1 AND crc.cost_type_id = 1)
             OR (mp.primary_cost_method in (2,5,6) AND crc.cost_type_id =
                        mp.AVG_RATES_COST_TYPE_ID ) )
      GROUP BY
            job.organization_id,
            nvl(bdr.share_from_dept_id,wo.department_id),
            job.job_id,
            job.job_type,
            job.assembly_item_id,
            br.unit_of_measure,
            wor.resource_id,
            trunc(job.completion_date);


    l_count := sql%rowcount;

    bis_collection_utilities.put_line('Load OPI res std into FACT ' ||
                l_count || ' rows, completed at '
                || To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    bis_collection_utilities.put_line('Exit incremental_opi_res_std() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

EXCEPTION WHEN OTHERS THEN
--{
    Errbuf:= Sqlerrm;
    Retcode:= SQLCODE;

    bis_collection_utilities.put_line('Exception in incremental_opi_res_std ' || sqlerrm );
--}
END incremental_opi_res_std;


/*======================================================================
    This is the wrapper procedure for Resource incremental load which extracts
    actual resource usage, resource availability, and resource standare usage
    data for discrete and process organizations.

    Parameters:
    - errbuf: error buffer
    - retcode: return code
=======================================================================*/

PROCEDURE incremental_load_res_utl (errbuf  IN OUT NOCOPY VARCHAR2,
                                    retcode IN OUT NOCOPY VARCHAR2 ) IS
    l_stmt_num NUMBER;
    l_row_count NUMBER;
    l_err_num NUMBER;
    l_err_msg VARCHAR2(255);
    l_error_flag  BOOLEAN;

    l_opi_schema      VARCHAR2(30);
    l_status          VARCHAR2(30);
    l_industry        VARCHAR2(30);

    l_last_collection_date DATE;
    l_comm_opi_avail_flag   BOOLEAN;
    l_comm_opm_avail_flag   BOOLEAN;
    l_comm_opi_actual_flag   BOOLEAN;
    l_comm_opm_actual_flag   BOOLEAN;

    l_count number;

    l_opi_start_date    DATE;
    l_opi_end_date      DATE;

    l_opm_start_date    opi_dbi_run_log_curr.from_bound_date%type;
    l_opm_end_date      opi_dbi_run_log_curr.to_bound_date%type;

    SCHEMA_INFO_NOT_FOUND   exception;
    NO_DATA_FOUND           exception;

BEGIN

    bis_collection_utilities.put_line('Enter incremental_load_res_utl() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    -- initialization block
    l_error_flag := FALSE;
    l_comm_opi_avail_flag := FALSE;
    l_comm_opm_avail_flag := FALSE;
    l_comm_opi_actual_flag := FALSE;
    l_comm_opm_actual_flag := FALSE;


    IF bis_collection_utilities.setup( 'OPI_DBI_RES_AVAIL_F' ) = false THEN
    --{
        RAISE_APPLICATION_ERROR(-20000, errbuf);
    --}
    END IF;


    -- setup globals
    bis_collection_utilities.put_line('Setup global parameters ...');

    l_stmt_num := 10;

    check_setup_globals(errbuf => errbuf, retcode => retcode);

    IF retcode <> 0 THEN
    --{
        RETURN ;
    --}
    END IF;

    -- Found this issue with the code during secondary currency fix UT.
    -- The conversion rates table is not cleaned up if the incremental
    -- load errors out. As a result, it starts accumulating duplicate rows.
    -- The worst case is when the program errors out due to missing rates,
    -- because then some of the rates in the table are actually the
    -- negative error codes returned by the FII API.


    l_stmt_num := 20;
    -- conversion rate table cleanup
    IF fnd_installation.get_app_info( 'OPI', l_status, l_industry, l_opi_schema) THEN
    --{

        execute immediate 'truncate table ' || l_opi_schema
         || '.opi_dbi_res_conv_rates ';
    --}
    ELSE
    --{
        retcode := g_error;
        RAISE SCHEMA_INFO_NOT_FOUND;
    --}
    END IF;


    /*** Collect Standard Resource Usage ***/

    -- Incrementally load resource standard usage fact for discrete
    bis_collection_utilities.put_line('Load discrete resource std into staging ...');
    l_stmt_num := 30;

    incremental_opi_res_std(errbuf => errbuf, retcode => retcode);

    IF retcode <> 0 THEN
    --{
        l_error_flag := TRUE;
    --}
    END IF;


    -- Incrementally load resource standard usage fact for process
    bis_collection_utilities.put_line('Load process resource std into staging ...');
    l_stmt_num := 40;

    incremental_opm_res_std(errbuf => errbuf, retcode => retcode);

     IF retcode <> 0 THEN
    --{
        l_error_flag := TRUE;
    --}
    END IF;

     --  update Job master's flag, for source 2
    UPDATE  opi_dbi_jobs_f
    SET     std_res_flag = 0,
            last_update_date = sysdate,
            last_updated_by = g_user_id,
            last_update_login = g_login_id
    WHERE   std_res_flag = 1;

    l_stmt_num := 50;



    /*** Collect Actual Resource Usage ***/

    -- Load discrete resource actual data into Staging table

    bis_collection_utilities.put_line('Load discrete res actual into staging ... ');
    l_stmt_num := 60;
    incremental_opi_res_actual(errbuf => errbuf, retcode => retcode);

    IF retcode <> 0 THEN
    --{
        l_error_flag := TRUE;
    --}
    END IF;



    -- Load process resource actual data into Staging table

    l_stmt_num := 65;

    -- Call API to load ledger data into Global temp table
    -- This temp table will be joined to extract process adjustments
    bis_collection_utilities.put_line ('Loading Ledger data into temp table');
    opi_dbi_bounds_pkg.load_opm_org_ledger_data;

    -- Committing the data. Since the temp table is made with On Commit preserve rows
    -- there will be no problem.
    commit;

    bis_collection_utilities.put_line('Load process res actual into staging ... ');
    l_stmt_num := 70;
    incremental_opm_res_actual(errbuf => errbuf, retcode => retcode);

    IF retcode <> 0 THEN
    --{
        l_error_flag := TRUE;
    --}
    END IF;


    /*** Collect Resource Availability Data ***/

    -- Get discrete and process availability date bounds
    l_stmt_num := 80;

    BEGIN
        SELECT  trunc(from_bound_date), trunc(to_bound_date)
        INTO    l_opi_start_date, l_opi_end_date
        FROM    opi_dbi_run_log_curr
        WHERE   etl_id = RESOURCE_VAR_ETL
        AND     source = OPI_SOURCE;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        --{
            RAISE NO_DATA_FOUND;
        --}
    END;

    BEGIN
        SELECT  trunc(from_bound_date), trunc(to_bound_date)
        INTO    l_opm_start_date, l_opm_end_date
        FROM    opi_dbi_run_log_curr
        WHERE   etl_id = RESOURCE_VAR_ETL
        AND     source = OPM_SOURCE;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        --{
            RAISE NO_DATA_FOUND;
        --}
    END;

    -- If the resource ETL is run more than once on the same day, wipe off
    -- data for the current date and re-extract
    l_stmt_num := 90;

    IF (l_opi_start_date = l_opi_end_date) THEN
    --{
        UPDATE  opi_dbi_res_avail_f
        SET     avail_qty = NULL,
                uom = NULL,
                avail_qty_g = NULL,
                avail_val_b = NULL,
                avail_val_g = NULL,
                avail_val_sg = NULL,
                last_update_date    = sysdate,
                last_updated_by     = g_user_id,
                last_update_login   = g_login_id
        WHERE   transaction_date =  l_opi_start_date
        AND     source = OPI_SOURCE;
    --}
    END IF;

     -- Load discrete availability data into Staging table
    bis_collection_utilities.put_line('Load discrete res avail into staging ...  ');
     l_stmt_num := 100;

    incremental_opi_res_avail(p_start_date => l_opi_start_date,
                              p_end_date => l_opi_end_date,
                              errbuf => errbuf,
                              retcode => retcode);

    IF retcode <> 0 THEN
    --{
        l_error_flag := TRUE;
    --}
    END IF;


    -- Load process availability data into Staging table
    bis_collection_utilities.put_line('Load process res avail into staging ...  ');
    l_stmt_num := 110;

    incremental_opm_res_avail(p_start_date => l_opm_start_date,
                              p_end_date => l_opm_end_date,
                              errbuf => errbuf,
                              retcode => retcode);

    IF retcode <> 0 THEN
    --{
        l_error_flag := TRUE;
    --}
    END IF;


    -- For improve perf, need to commit in stg/conversion rate tables
    -- and gather statistics
    commit;

    gather_stats(p_table_name => 'OPI_DBI_RES_ACTUAL_STG');

    gather_stats(p_table_name => 'OPI_DBI_RES_AVAIL_STG');

    get_res_conversion_rate(errbuf => errbuf, retcode => retcode );

    commit;

    --gather_stats(p_table_name => 'OPI_DBI_RES_CONV_RATES');



    -- Incrementally load data into Actual Fact
    IF l_error_flag <> TRUE THEN
    --{
        bis_collection_utilities.put_line('Merge res actual from staging to actual fact ...');
        l_stmt_num := 120;

         MERGE INTO opi_dbi_res_actual_f f
        USING (
        SELECT
            stg.resource_id,
            stg.department_id,
            stg.organization_id,
            stg.uom,
            sum (stg.actual_qty_draft)      actual_qty_draft,
            sum (stg.actual_qty)            actual_qty,
            sum (stg.actual_qty_g_draft)    actual_qty_g_draft,
            sum (stg.actual_qty_g)          actual_qty_g,
            sum (stg.actual_val_b_draft)    actual_val_b_draft,
            sum (stg.actual_val_b)          actual_val_b,
            min(rate.conversion_rate)           conversion_rate,
            min(rate.sec_conversion_rate)       sec_conversion_rate,
            stg.job_id,
            stg.job_type,
            stg.assembly_item_id,
            stg.source
          FROM  opi_dbi_res_actual_stg stg,
                opi_dbi_res_conv_rates rate
          WHERE stg.organization_id = rate.organization_id
          AND   stg.transaction_date  = rate.transaction_date
          GROUP BY
                stg.resource_id,
                stg.department_id,
                stg.organization_id,
                stg.uom,
                stg.job_id,
                stg.job_type,
                stg.assembly_item_id,
                stg.source
        ) stg
        ON (    f.resource_id = stg.resource_id
            AND nvl(f.department_id, -999) = nvl(stg.department_id, -999)
            AND f.organization_id = stg.organization_id
            AND f.job_id = stg.job_id
            AND f.job_type = stg.job_type
            AND f.assembly_item_id = stg.assembly_item_id
            AND f.source = stg.source)
        WHEN MATCHED THEN UPDATE
        SET
            f.actual_qty_draft = stg.actual_qty_draft,
            f.actual_qty = nvl(f.actual_qty,0) - nvl(f.actual_qty_draft,0) + nvl(stg.actual_qty_draft,0) + nvl(stg.actual_qty,0),

            f.actual_qty_g_draft = stg.actual_qty_g_draft,
            f.actual_qty_g = nvl(f.actual_qty_g,0) - nvl(f.actual_qty_g_draft,0) + nvl(stg.actual_qty_g_draft,0) + nvl(stg.actual_qty_g,0),

            f.actual_val_b_draft = stg.actual_val_b_draft,
            f.actual_val_b  = nvl(f.actual_val_b,0) - nvl(f.actual_val_b_draft,0) + nvl(stg.actual_val_b_draft,0) + nvl(stg.actual_val_b,0),
             f.actual_val_g  = (nvl(f.actual_val_b,0) - nvl(f.actual_val_b_draft,0) + nvl(stg.actual_val_b_draft,0) + nvl(stg.actual_val_b,0))
                                * stg.conversion_rate,
            f.actual_val_sg  = (nvl(f.actual_val_b,0) - nvl(f.actual_val_b_draft,0) + nvl(stg.actual_val_b_draft,0) + nvl(stg.actual_val_b,0))
                                 * stg.sec_conversion_rate,

            f.last_update_date  = sysdate,
            f.last_updated_by   = g_user_id,
            f.last_update_login = g_login_id
        WHEN NOT MATCHED THEN
        INSERT (
            f.resource_id,
            f.department_id,
            f.organization_id,
            f.uom,
            f.actual_qty_draft,
            f.actual_qty,
            f.actual_qty_g_draft,
            f.actual_qty_g,
            f.actual_val_b_draft,
            f.actual_val_b,
            f.actual_val_g,
            f.actual_val_sg,
            f.job_id,
            f.job_type,
            f.assembly_item_id,
            f.source,
            f.creation_date,
            f.last_update_date,
            f.created_by,
            f.last_updated_by,
            f.last_update_login,
            f.program_id,
            f.program_login_id,
            f.program_application_id,
            f.request_id)
        VALUES (
            stg.resource_id,
            stg.department_id,
            stg.organization_id,
            stg.uom,
            stg.actual_qty_draft,
            nvl(stg.actual_qty_draft,0) + nvl(stg.actual_qty,0),
            stg.actual_qty_g_draft,
            nvl(stg.actual_qty_g_draft,0) + nvl(stg.actual_qty_g,0),
            stg.actual_val_b_draft,
            nvl(stg.actual_val_b_draft,0) + nvl(stg.actual_val_b,0),
            (nvl(stg.actual_val_b_draft,0) + nvl(stg.actual_val_b,0)) * stg.conversion_rate,
            (nvl(stg.actual_val_b_draft,0) + nvl(stg.actual_val_b,0)) * stg.sec_conversion_rate,
            stg.job_id,
            stg.job_type,
            stg.assembly_item_id,
            stg.source,
            sysdate,
            sysdate,
            g_user_id,
            g_user_id,
            g_login_id,
            g_program_id,
            g_program_login_id,
            g_program_application_id,
            g_request_id);

        l_count := sql%rowcount;

        bis_collection_utilities.put_line('Load resource actual into FACT ' ||
                l_count || ' rows, completed at '
                    || To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));
    --}
    END IF;


     -- Merge Avail and Actual data in to Avail Fact
    IF l_error_flag <> TRUE THEN
    --{
        bis_collection_utilities.put_line('Merge res actual and avail from staging to avail fact ...');
        l_stmt_num := 130;

        MERGE /*+ index(f, OPI_DBI_RES_AVAIL_F_N1) */
        INTO opi_dbi_res_avail_f f
        USING (
        SELECT
            res.resource_id,
            res.department_id,
            res.organization_id,
            res.transaction_date,
            res.uom,
            SUM (res.avail_qty)     avail_qty,
            SUM (avail_qty_g)       avail_qty_g,
            SUM (res.avail_val_b)   avail_val_b,
            SUM (res.avail_val_g)   avail_val_g,
            SUM (res.avail_val_sg)  avail_val_sg,
            SUM (res.actual_qty_draft)      actual_qty_draft,
            SUM (res.actual_qty)            actual_qty,
            SUM (res.actual_qty_g_draft)    actual_qty_g_draft,
            SUM (res.actual_qty_g)          actual_qty_g,
            SUM (res.actual_val_b_draft)    actual_val_b_draft,
            SUM (res.actual_val_b)          actual_val_b,
            min(res.conversion_rate)        conversion_rate,
            min(res.sec_conversion_rate)    sec_conversion_rate,
            res.source source
        FROM
            (SELECT
                stg.resource_id,
                stg.department_id,
                stg.organization_id,
                stg.transaction_date,
                MAX (stg.uom)   uom,
                NULL    avail_qty,
                NULL    avail_qty_g,
                NULL    avail_val_b,
                NULL    avail_val_g,
                NULL    avail_val_sg,
                SUM (stg.actual_qty_draft)      actual_qty_draft,
                SUM (stg.actual_qty)            actual_qty,
                SUM (stg.actual_qty_g_draft)    actual_qty_g_draft,
                SUM (stg.actual_qty_g)          actual_qty_g,
                SUM (stg.actual_val_b_draft)    actual_val_b_draft,
                SUM (stg.actual_val_b)          actual_val_b,
                min(rate.conversion_rate)           conversion_rate,
                min(rate.sec_conversion_rate)       sec_conversion_rate,
                stg.source                      source
            FROM
                opi_dbi_res_actual_stg stg,
                opi_dbi_res_conv_rates rate
            WHERE
                stg.organization_id = rate.organization_id
            AND stg.transaction_date  = rate.transaction_date
            GROUP BY
                stg.resource_id,
                stg.department_id,
                stg.organization_id,
                stg.transaction_date,
                stg.source,
                stg.uom
            UNION ALL   -- from avail staging
            SELECT
                stg.resource_id,
                stg.department_id,
                stg.organization_id,
                stg.transaction_date,
                stg.uom,
                stg.avail_qty,
                stg.avail_qty_g,
                stg.avail_val_b,
                stg.avail_val_b * rate.conversion_rate avail_val_g,
                stg.avail_val_b * rate.sec_conversion_rate avail_val_sg,
                NULL actual_qty_draft,
                NULL actual_qty,
                NULL actual_qty_g_draft,
                NULL actual_qty_g,
                NULL actual_val_b_draft,
                NULL actual_val_b,
                rate.conversion_rate    conversion_rate,
                rate.sec_conversion_rate sec_conversion_rate,
                stg.source
            FROM
                opi_dbi_res_avail_stg stg,
                opi_dbi_res_conv_rates rate
            WHERE
                stg.organization_id = rate.organization_id
            AND stg.transaction_date  = rate.transaction_date
            ) res
        GROUP BY
             res.resource_id,
            res.department_id,
            res.organization_id,
            res.transaction_date,
            res.source,
            res.uom
        ) stg
        ON (
            f.organization_id = stg.organization_id
            AND f.transaction_date = stg.transaction_date
            AND nvl(f.department_id, -999) = nvl(stg.department_id, -999)
            AND f.resource_id = stg.resource_id )
        WHEN matched THEN UPDATE SET
            f.uom           = stg.uom,
            f.avail_qty     = nvl(stg.avail_qty, f.avail_qty),
            f.avail_qty_g   = nvl(stg.avail_qty_g, f.avail_qty_g),
            f.avail_val_b   = nvl(stg.avail_val_b, f.avail_val_b),
            f.avail_val_g   = nvl(stg.avail_val_g, f.avail_val_g),
            f.avail_val_sg  = nvl(stg.avail_val_sg, f.avail_val_sg),
            f.source        = stg.source,
            f.actual_qty_draft   = nvl(stg.actual_qty_draft, f.actual_qty_draft),
            f.actual_qty         = nvl(f.actual_qty,0) - nvl(f.actual_qty_draft,0) + nvl(stg.actual_qty_draft,0) + nvl(stg.actual_qty,0),
            f.actual_qty_g_draft = nvl(stg.actual_qty_g_draft, f.actual_qty_g_draft),
            f.actual_qty_g       = nvl(f.actual_qty_g,0) - nvl(f.actual_qty_g_draft,0) + nvl(stg.actual_qty_g_draft,0) + nvl(stg.actual_qty_g,0),
            f.actual_val_b_draft = nvl(stg.actual_val_b_draft, f.actual_val_b_draft),
            f.actual_val_b       = nvl(f.actual_val_b,0) - nvl(f.actual_val_b_draft,0) + nvl(stg.actual_val_b_draft,0) + nvl(stg.actual_val_b,0),
            f.actual_val_g       = (nvl(f.actual_val_b,0) - nvl(f.actual_val_b_draft,0) + nvl(stg.actual_val_b_draft,0) + nvl(stg.actual_val_b,0))
                                    * stg.conversion_rate,
            f.actual_val_sg      = (nvl(f.actual_val_b,0) - nvl(f.actual_val_b_draft,0) + nvl(stg.actual_val_b_draft,0) + nvl(stg.actual_val_b,0))
                                   * stg.sec_conversion_rate,
            f.last_update_date   = sysdate,
            f.last_updated_by    = g_user_id,
            f.last_update_login  = g_login_id
        WHEN NOT matched THEN
        INSERT (
            f.resource_id,
            f.department_id,
            f.organization_id,
            f.transaction_date,
            f.uom,
            f.avail_qty,
            f.avail_qty_g,
            f.avail_val_b,
            f.avail_val_g,
            f.avail_val_sg,
            f.actual_qty_draft,
            f.actual_qty,
            f.actual_qty_g_draft,
            f.actual_qty_g,
            f.actual_val_b_draft,
            f.actual_val_b,
            f.actual_val_g,
            f.actual_val_sg,
            f.source,
            f.creation_date,
            f.last_update_date,
            f.created_by,
            f.last_updated_by,
            f.last_update_login,
            f.program_id,
            f.program_login_id,
            f.program_application_id,
            f.request_id)
        VALUES (
            stg.resource_id,
            stg.department_id,
            stg.organization_id,
            stg.transaction_date,
            stg.uom,
            stg.avail_qty,
            stg.avail_qty_g,
            stg.avail_val_b,
            stg.avail_val_g,
            stg.avail_val_sg,
            stg.actual_qty_draft,
            nvl(stg.actual_qty_draft,0) + nvl(stg.actual_qty,0),
            stg.actual_qty_g_draft,
            nvl(stg.actual_qty_g_draft,0) + nvl(stg.actual_qty_g,0),
            stg.actual_val_b_draft,
            nvl(stg.actual_val_b_draft,0) + nvl(stg.actual_val_b,0),
            (nvl(stg.actual_val_b_draft,0) + nvl(stg.actual_val_b,0)) * stg.conversion_rate,
            (nvl(stg.actual_val_b_draft,0) + nvl(stg.actual_val_b,0)) * stg.sec_conversion_rate,
            stg.source,
            Sysdate,
            Sysdate,
            g_user_id,
            g_user_id,
            g_login_id,
            g_program_id,
            g_program_login_id,
            g_program_application_id,
            g_request_id);

        l_count := SQL%rowcount;

        bis_collection_utilities.put_line('Load resource avail into FACT ' || l_count || ' rows, completed at '
                             || To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

         -- update common modules for OPI
        l_comm_opi_avail_flag := opi_dbi_common_mod_incr_pkg.etl_report_success(p_etl_id => RESOURCE_VAR_ETL,
                                                                                p_source => 1);
        l_comm_opm_avail_flag := opi_dbi_common_mod_incr_pkg.etl_report_success(p_etl_id => RESOURCE_VAR_ETL,
                                                                                p_source => 2);

        l_comm_opi_actual_flag := opi_dbi_common_mod_incr_pkg.etl_report_success(p_etl_id => ACTUAL_RES_ETL,
                                                                                 p_source => 1);
        l_comm_opm_actual_flag := opi_dbi_common_mod_incr_pkg.etl_report_success(p_etl_id => ACTUAL_RES_ETL,
                                                                                 p_source => 2);

        IF l_comm_opi_avail_flag AND l_comm_opm_avail_flag
            AND l_comm_opi_actual_flag AND l_comm_opm_actual_flag THEN
        --{
            COMMIT;

            -- common clean up

            execute immediate 'truncate table ' || l_opi_schema
                    || '.opi_dbi_res_conv_rates ';

            execute immediate 'truncate table ' || l_opi_schema
                    || '.opi_dbi_res_avail_stg ';

            execute immediate 'truncate table ' || l_opi_schema
                    || '.opi_dbi_res_actual_stg ';


            bis_collection_utilities.WRAPUP( p_status => TRUE,
                    p_count => l_row_count,
                    p_message => 'successful in incremental_load_res_utl.'
                    );
        --}
        ELSE
        --{
            rollback;
            retcode := g_error ;
            errbuf  := 'Error in report to common modules. Please check log file for details.';

            bis_collection_utilities.put_line('Error in incremental_load_res_utl at ' || l_stmt_num);
            bis_collection_utilities.wrapup(p_status => FALSE,
                   p_count => 0,
                   p_message => 'failed in incremental_load_res_utl.'
                   );
        --}
        END IF;
    --}
    ELSE
    --{
        rollback;
        retcode := g_error;
        errbuf  := 'Please check log file for details.';

        bis_collection_utilities.put_line('Error in incremental_load_res_utl at ' || l_stmt_num);
        bis_collection_utilities.wrapup(p_status => FALSE,
                   p_count => 0,
                   p_message => 'failed in incremental_load_res_utl.'
                   );
    --}
    END IF;

    bis_collection_utilities.put_line('Exit incremental_load_res_utl() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

EXCEPTION
--{
    WHEN SCHEMA_INFO_NOT_FOUND THEN
    --{
        bis_collection_utilities.put_line('Schema Information was not found.');
        errbuf := Sqlerrm;
        Retcode := g_ERROR;
    --}
    WHEN OTHERS THEN
    --{
    Errbuf:= Sqlerrm;
    Retcode:= SQLCODE;

    ROLLBACK;

    bis_collection_utilities.put_line('Error in incremental_load_res_utl at ' || l_stmt_num);
    bis_collection_utilities.wrapup(p_status => FALSE,
                   p_count => 0,
                   p_message => 'failed in incremental_load_res_utl.'
                   );

    RAISE_APPLICATION_ERROR(-20000,errbuf);
    --}
--}
END incremental_load_res_utl;


/*======================================================================
    This procedure extracts Resource Standard Usage for initial loads.

    Parameters:
    - errbuf: error buffer
    - retcode: return code
    - p_degree: degree
=======================================================================*/

PROCEDURE initial_load_res_std (errbuf  IN OUT NOCOPY VARCHAR2,
                                retcode IN OUT NOCOPY VARCHAR2,
                                p_degree    IN    NUMBER    ) IS
    l_stmt_num NUMBER;
    l_row_count NUMBER;
    l_err_num NUMBER;
    l_err_msg VARCHAR2(255);
    l_error_flag  BOOLEAN;

    l_opi_schema      VARCHAR2(30);
    l_status          VARCHAR2(30);
    l_industry        VARCHAR2(30);

    SCHEMA_INFO_NOT_FOUND   exception;

BEGIN

    bis_collection_utilities.put_line('Enter initial_load_res_std() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    -- initialization block
    l_error_flag := FALSE;

    IF bis_collection_utilities.setup( 'OPI_DBI_RES_STD_F' ) = false THEN
    --{
        RAISE_APPLICATION_ERROR(-20000, errbuf);
    --}
    END IF;

    -- Performance tuning change
    execute immediate 'alter session set hash_area_size=100000000 ';
    execute immediate 'alter session set sort_area_size=100000000 ';


    -- setup globals
    l_stmt_num := 10;
    bis_collection_utilities.put_line('Setup global parameters ...');

    check_setup_globals(errbuf => errbuf, retcode => retcode);

    IF retcode <> 0 THEN
    --{
        RETURN ;
    --}
    END IF;


    -- common clean up
    l_stmt_num := 20;
    IF fnd_installation.get_app_info( 'OPI', l_status, l_industry, l_opi_schema) THEN
    --{
        execute immediate 'truncate table ' || l_opi_schema
        || '.opi_dbi_res_std_f PURGE MATERIALIZED VIEW LOG';
    --}
    ELSE
    --{
        RAISE SCHEMA_INFO_NOT_FOUND;
    --}
    END IF;

    -- If no errors, load discrete data to fact table
    IF l_error_flag = FALSE THEN
    --{
        bis_collection_utilities.put_line('Load discrete res std into staging ...');

        INSERT /*+ append parallel(opi_dbi_res_std_f) */
        INTO opi_dbi_res_std_f (
            resource_id,
            department_id,
            organization_id,
            transaction_date,
            uom,
            std_usage_qty,
            std_usage_qty_g,
            std_usage_val_b,
            std_usage_val_g,
            std_usage_val_sg,
            job_id,
            job_type,
            assembly_item_id,
            source,
            creation_date,
            last_update_date,
            created_by,
            last_updated_by,
            last_update_login,
            program_id,
            program_login_id,
            program_application_id,
            request_id )
        SELECT  /*+ use_hash(wor) use_hash(wo) use_hash(job)
                    use_hash(br) use_hash(mp)
                    use_hash(m) use_hash(m2) use_hash(crc) use_hash(bdr)
                    parallel(wor) parallel(wo) parallel(job) parallel(br)
                    parallel(mp) parallel(m) parallel(m2) parallel(crc)
                    parallel(bdr) */
            wor.resource_id,
            nvl (bdr.share_from_dept_id, wo.department_id),
            job.organization_id,
            Trunc (job.completion_date) transaction_date,
            br.unit_of_measure uom,
            SUM (Decode (basis_type,
                         1, wor.usage_rate_or_amount *
                            job.actual_qty_completed,
                          2, wor.usage_rate_or_amount ) )  std_usage_qty,
            SUM (Decode (basis_type,
                         1, wor.usage_rate_or_amount *
                            job.actual_qty_completed,
                         2, wor.usage_rate_or_amount )/
                m.conversion_rate * m2.conversion_rate) std_usage_qty_g,
            SUM (Decode (basis_type,
                         1, wor.usage_rate_or_amount *
                            job.actual_qty_completed,
                         2, wor.usage_rate_or_amount ) * crc.resource_rate)
                std_usage_val_b,
            SUM (Decode (basis_type,
                         1, wor.usage_rate_or_amount *
                            job.actual_qty_completed,
                         2, wor.usage_rate_or_amount ) * crc.resource_rate *
                job.conversion_rate )  std_usage_val_g,
            SUM (Decode (basis_type,
                         1, wor.usage_rate_or_amount *
                            job.actual_qty_completed,
                         2, wor.usage_rate_or_amount ) * crc.resource_rate *
                job.sec_conversion_rate )  std_usage_val_sg,
            job.job_id,
            job.job_type,
            job.assembly_item_id,
            OPI_SOURCE source,
            sysdate,
            sysdate,
            g_user_id,
            g_user_id,
            g_login_id,
            g_program_id,
            g_program_login_id,
            g_program_application_id,
            g_request_id
          FROM  wip_operation_resources     wor,
                wip_operations                   wo,
                opi_dbi_jobs_f               job,
                bom_resources              br,
                mtl_parameters                  mp,
                mtl_uom_conversions             m,
                mtl_uom_conversions             m2,
                cst_resource_costs              crc,
                bom_department_resources        bdr
          WHERE job.job_type IN (1,2,5) -- Discrete and Repetitive also OSFM
            AND job.std_res_flag = 1
            AND wor.organization_id = job.organization_id
            AND job.job_id = Nvl(wor.repetitive_schedule_id, wor.wip_entity_id)
            AND br.resource_id      = wor.resource_id
            AND wo.organization_id   = wor.organization_id
            AND wo.wip_entity_id     = wor.wip_entity_id
            AND wo.operation_seq_num = wor.operation_seq_num
            AND nvl(wo.repetitive_schedule_id, -999) =
                    nvl(wor.repetitive_schedule_id, -999)
             AND m.inventory_item_id  = 0
            AND m.uom_code           = g_hr_uom
            AND m2.uom_code          = br.unit_of_measure
            AND m2.uom_class         = m.uom_class
            AND m2.inventory_item_id  = 0
            AND mp.organization_id   = wor.organization_id
            AND crc.resource_id      = br.resource_id
            AND crc.organization_id  = mp.organization_id
            AND bdr.resource_id      = wor.resource_id
            AND bdr.department_id    = wo.department_id
            AND (   (mp.primary_cost_method = 1 AND crc.cost_type_id = 1)
                 OR (mp.primary_cost_method in (2,5,6) AND
                     crc.cost_type_id = mp.AVG_RATES_COST_TYPE_ID ) )
          GROUP BY
                job.organization_id,
                nvl(bdr.share_from_dept_id,wo.department_id),
                job.job_id,
                job.job_type,
                job.assembly_item_id,
                br.unit_of_measure,
                wor.resource_id,
                trunc(job.completion_date);

        l_row_count := SQL%rowcount;

        COMMIT;

        bis_collection_utilities.put_line('Load OPI resource standard into FACT ' ||
                l_row_count || ' rows, completed at '
                || To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));


        -- load opm res std table
        bis_collection_utilities.put_line('Load process res std into staging ...');

        initial_opm_res_std (errbuf => errbuf,
                             retcode => retcode,
                             p_degree => p_degree);

         -- Update std_res_flag in Job Master to 0 where std_res_flag = 1
        UPDATE  opi_dbi_jobs_f
        SET     std_res_flag = 0,
                last_update_date = sysdate,
                last_updated_by = g_user_id,
                last_update_login = g_login_id
        WHERE   std_res_flag = 1;

        COMMIT;
    --}
    END IF ;

    bis_collection_utilities.WRAPUP( p_status => TRUE,
                                      p_count => l_row_count,
                                     p_message => 'successful in initial_load_res_std.');


EXCEPTION
--{
    WHEN SCHEMA_INFO_NOT_FOUND THEN
    --{
        bis_collection_utilities.put_line('Schema information was not found.');
    --}
    WHEN OTHERS THEN
    --{
    Errbuf:= Sqlerrm;
    Retcode:= SQLCODE;

    ROLLBACK;
    bis_collection_utilities.put_line('Error in initial_load_res_std at ' || l_stmt_num);
    bis_collection_utilities.wrapup(p_status => FALSE,
                   p_count => 0,
                   p_message => 'failed in initial_load_res_std'
                   );

    RAISE_APPLICATION_ERROR(-20000,errbuf);
    --}
--}
END initial_load_res_std;

END opi_dbi_res_pkg;

/
