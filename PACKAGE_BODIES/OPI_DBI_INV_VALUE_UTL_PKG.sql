--------------------------------------------------------
--  DDL for Package Body OPI_DBI_INV_VALUE_UTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_INV_VALUE_UTL_PKG" as
/* $Header: OPIDIVUB.pls 120.2 2005/08/22 23:57:01 achandak noship $ */

g_sysdate DATE;
g_created_by NUMBER;
g_last_update_login NUMBER;
g_last_updated_by NUMBER;

/*  Marker for secondary conv. rate if the primary and secondary curr codes
    and rate types are identical. Can't be -1, -2, -3 since the FII APIs
    return those values. */
C_PRI_SEC_CURR_SAME_MARKER CONSTANT NUMBER := -9999;

-- Euro rates came into effect from 1999
C_EURO_START_DATE CONSTANT DATE := to_date ('01/01/1999', 'DD/MM/YYYY');

-- GL API returns -3 if EURO rate missing on 01-JAN-1999
C_EURO_MISSING_AT_START CONSTANT NUMBER := -3;

-- Conversion rate related variables: global currency code and rate type
s_global_curr_code  VARCHAR2(10);
s_global_rate_type  VARCHAR2(15);

-- secondary global currency
s_secondary_curr_code  VARCHAR2(10);
s_secondary_rate_type  VARCHAR2(15);



FUNCTION Get_Conversion_Rate (errbuf  IN OUT NOCOPY VARCHAR2,
                              retcode IN OUT NOCOPY VARCHAR2)
    RETURN NUMBER
IS

    -- for cleaning out the conversion rates table, since we insert/append
    -- now
    l_opi_schema VARCHAR2(30);
    l_status VARCHAR2(30);
    l_industry VARCHAR2(30);

    l_proc_name CONSTANT VARCHAR2(40) := 'get_conversion_name';
    l_stmt_id NUMBER;

    -- Cursor to see if any rates are missing. See below for details
    CURSOR invalid_rates_exist_csr IS
        SELECT 1
          FROM opi_dbi_conversion_rates
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
            transaction_date,
            f_currency_code
          FROM (
            SELECT DISTINCT
                    s_global_curr_code curr_code,
                    s_global_rate_type rate_type,
                    1 report_order, -- ordering global currency first
                    mp.organization_code,
                    decode (conv.conversion_rate,
                            C_EURO_MISSING_AT_START, C_EURO_START_DATE,
                            conv.transaction_date) transaction_date,
                    conv.f_currency_code
              FROM opi_dbi_conversion_rates conv,
                   mtl_parameters mp,
                  (SELECT /*+ parallel (opi_dbi_onhand_stg) */
                   DISTINCT organization_id, transaction_date
                     FROM opi_dbi_onhand_stg
                   UNION
                   SELECT /*+ parallel (opi_dbi_intransit_stg) */
                   DISTINCT organization_id, transaction_date
                     FROM opi_dbi_intransit_stg
                   UNION
                   SELECT /*+ parallel (opi_dbi_wip_stg) */
                   DISTINCT organization_id, transaction_date
                   FROM opi_dbi_wip_stg
                   UNION
                   SELECT /*+ parallel (opi_dbi_inv_beg_stg) */
                   DISTINCT organization_id, transaction_date
                   FROM opi_dbi_inv_beg_stg
                   UNION
                   SELECT /*+ parallel (opi_dbi_onh_qty_stg) */
                   DISTINCT organization_id, transaction_date
                   FROM opi_dbi_onh_qty_stg
                   WHERE transaction_source ='MMT'
                   UNION
                   SELECT /*+ parallel (opi_dbi_opm_inv_stg) */
                   DISTINCT organization_id, transaction_date
                     FROM opi_dbi_opm_inv_stg) to_conv -- Only change
              WHERE nvl (conv.conversion_rate, -999) < 0 -- null is not fine
                AND mp.organization_id = to_conv.organization_id
                AND conv.transaction_date (+) = to_conv.transaction_date
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
                            conv.transaction_date) transaction_date,
                    conv.f_currency_code
              FROM opi_dbi_conversion_rates conv,
                   mtl_parameters mp,
                  (SELECT /*+ parallel (opi_dbi_onhand_stg) */
                   DISTINCT organization_id, transaction_date
                     FROM opi_dbi_onhand_stg
                   UNION
                   SELECT /*+ parallel (opi_dbi_intransit_stg) */
                   DISTINCT organization_id, transaction_date
                     FROM opi_dbi_intransit_stg
                   UNION
                   SELECT /*+ parallel (opi_dbi_wip_stg) */
                   DISTINCT organization_id, transaction_date
                     FROM opi_dbi_wip_stg
                   UNION
                   SELECT /*+ parallel (opi_dbi_inv_beg_stg) */
                   DISTINCT organization_id, transaction_date
                   FROM opi_dbi_inv_beg_stg
                   UNION
                   SELECT /*+ parallel (opi_dbi_onh_qty_stg) */
                   DISTINCT organization_id, transaction_date
                   FROM opi_dbi_onh_qty_stg
                   WHERE transaction_source ='MMT'
                   UNION
                   SELECT /*+ parallel (opi_dbi_opm_inv_stg) */
                   DISTINCT organization_id, transaction_date
                     FROM opi_dbi_opm_inv_stg) to_conv
              WHERE nvl (conv.sec_conversion_rate, 999) < 0 -- null is fine
                AND mp.organization_id = to_conv.organization_id
                AND conv.transaction_date (+) = to_conv.transaction_date
                AND conv.organization_id (+) = to_conv.organization_id)
          ORDER BY
                report_order ASC,
                transaction_date,
                f_currency_code;


    -- Flag to ensure all rates have been found.
    l_all_rates_found BOOLEAN;

    -- Boolean to check if the primary and secondary currencies are the
    -- same
    l_pri_sec_curr_same NUMBER;

    -- for exception reporting
    i_err_num NUMBER;
    i_err_msg VARCHAR2(255);

BEGIN

    BIS_COLLECTION_UTILITIES.PUT_LINE ('Get_conversion_rates: #0: Computing conversion rates for the inventory data extraction.');

    -- initialization block
    l_stmt_id := 0;
    l_all_rates_found := true;
    l_pri_sec_curr_same := 0;
    g_sysdate := sysdate;
    g_created_by := fnd_global.user_id;
    g_last_update_login := fnd_global.login_id;
    g_last_updated_by := fnd_global.user_id;

    IF (NOT (fnd_installation.get_app_info
                ('OPI', l_status, l_industry, l_opi_schema)) ) THEN
        return -1;
    END IF;
    EXECUTE IMMEDIATE   'truncate table ' || l_opi_schema ||
                        '.OPI_DBI_CONVERSION_RATES';
    BIS_COLLECTION_UTILITIES.put_line (
        'OPI_DBI_CONVERSION_RATES table truncated.');


    l_stmt_id := 10;
    -- get the global currency code/rate types
    s_global_curr_code := bis_common_parameters.get_currency_code;
    s_secondary_curr_code := bis_common_parameters.get_secondary_currency_code;
    s_global_rate_type := bis_common_parameters.get_rate_type;
    s_secondary_rate_type := bis_common_parameters.get_secondary_rate_type;

    l_stmt_id := 20;
    -- global currency and rate type must be set up
    IF (s_global_curr_code IS NULL OR s_global_rate_type IS NULL) THEN
        BIS_COLLECTION_UTILITIES.PUT_LINE (
            l_proc_name || ':# ' || l_stmt_id || ': ' ||
            'Please set up the global currency and global rate type before running any DBI collection.');
        return -1;
    END IF;

    l_stmt_id := 30;
    -- Cannot of just one of secondary currency and secondary rate type
    -- as null.
    IF (    (s_secondary_curr_code IS NULL AND
             s_secondary_rate_type IS NOT NULL)
         OR (s_secondary_curr_code IS NOT NULL AND
             s_secondary_rate_type IS NULL) ) THEN
        BIS_COLLECTION_UTILITIES.PUT_LINE (
            l_proc_name || ':# ' || l_stmt_id || ': ' ||
            'Please make sure that both the secondary currency and rate type are defined, or that neither is defined.');
        return -1;
    END IF;

    l_stmt_id := 40;
    -- check if the primary and secondary currencies and rate types are
    -- identical.
    IF (s_global_curr_code = nvl (s_secondary_curr_code, '---') AND
        s_global_rate_type = nvl (s_secondary_rate_type, '---') ) THEN
        l_pri_sec_curr_same := 1;
    END IF;


    l_stmt_id := 50;
    -- compute the conversion rates
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
    --
    -- Since OPM uses it's own currency conversion rate logic,
    -- just filter out rows with source = 2.
    INSERT /*+ append parallel (opi_dbi_conversion_rates) */
    INTO opi_dbi_conversion_rates (
        organization_id,
        f_currency_code,
        transaction_date,
        conversion_rate,
        sec_conversion_rate,
        creation_date,
        last_update_date,
        created_by,
        last_updated_by,
        last_update_login)
    SELECT /*+ parallel (to_conv) parallel (curr_codes) */
        to_conv.organization_id,
        curr_codes.currency_code f_currency_code,
        to_conv.transaction_date,
        decode (curr_codes.currency_code,
                s_global_curr_code, 1,
                fii_currency.get_global_rate_primary (
                                    curr_codes.currency_code,
                                    to_conv.transaction_date) )
            conversion_rate,
        decode (s_secondary_curr_code,
                NULL, NULL,
                curr_codes.currency_code, 1,
                decode (l_pri_sec_curr_same,
                        1, C_PRI_SEC_CURR_SAME_MARKER,
                        fii_currency.get_global_rate_secondary (
                            curr_codes.currency_code,
                            to_conv.transaction_date)))
            sec_conversion_rate,
        sysdate,
        sysdate,
        g_created_by,
        g_last_updated_by,
        g_last_update_login
      FROM
        (SELECT /*+ parallel (opi_dbi_onhand_stg) */
         DISTINCT organization_id, transaction_date
           FROM opi_dbi_onhand_stg
         UNION
         SELECT /*+ parallel (opi_dbi_intransit_stg) */
         DISTINCT organization_id, transaction_date
           FROM opi_dbi_intransit_stg
         UNION
         SELECT /*+ parallel (opi_dbi_wip_stg) */
         DISTINCT organization_id, transaction_date
           FROM opi_dbi_wip_stg
        UNION
        SELECT /*+ parallel (opi_dbi_inv_beg_stg) */
         DISTINCT organization_id, transaction_date
         FROM opi_dbi_inv_beg_stg
        UNION
        SELECT /*+ parallel (opi_dbi_onh_qty_stg) */
         DISTINCT organization_id, transaction_date
         FROM opi_dbi_onh_qty_stg
         WHERE transaction_source ='MMT'
        UNION
        SELECT /*+ parallel (opi_dbi_opm_inv_stg) */
        DISTINCT organization_id, transaction_date
          FROM opi_dbi_opm_inv_stg
        ) to_conv,
        (SELECT /*+ leading (hoi) full (hoi) use_hash (gsob)
                    parallel (hoi) parallel (gsob)*/
         DISTINCT hoi.organization_id, gsob.currency_code
           FROM hr_organization_information hoi,
                gl_sets_of_books gsob
           WHERE hoi.org_information_context  = 'Accounting Information'
             AND hoi.org_information1  = to_char(gsob.set_of_books_id))
        curr_codes
      WHERE curr_codes.organization_id  = to_conv.organization_id;



    l_stmt_id := 55;
    commit;   -- due to insert+append

    l_stmt_id := 60;
    -- if the primary and secondary currency codes are the same, then
    -- update the secondary with the primary
    IF (l_pri_sec_curr_same = 1) THEN

        l_stmt_id := 70;
        UPDATE /*+ parallel (opi_dbi_conversion_rates) */
        opi_dbi_conversion_rates
        SET sec_conversion_rate = conversion_rate;

        -- safe to commit, as before
        l_stmt_id := 80;
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
               invalid_rate_rec.f_currency_code,
               invalid_rate_rec.curr_code,
               invalid_rate_rec.transaction_date);

        END LOOP;
    END IF;

    l_stmt_id := 55;
    CLOSE invalid_rates_exist_csr;

    -- If all rates not found raise an exception
    l_stmt_id := 60;
    IF (l_all_rates_found = FALSE) THEN
        RETURN -1;
    END IF;

    RETURN 0;

EXCEPTION
    WHEN OTHERS THEN
        rollback;
        i_err_num := SQLCODE;
        i_err_msg := 'OPI_DBI_INV_VALUE_UTL_PKG.GET_CONVERSION_RATE ('
                    || to_char(l_stmt_id)
                    || '): '
                    || substr(SQLERRM, 1,200);

        BIS_COLLECTION_UTILITIES.put_line('OPI_DBI_INV_VALUE_UTL_PKG.GET_CONVERSION_RATE - Error at statement ('
                    || to_char(l_stmt_id)
                    || ')');

        BIS_COLLECTION_UTILITIES.put_line('Error Number: ' ||  to_char(i_err_num));
        BIS_COLLECTION_UTILITIES.put_line('Error Message: ' || i_err_msg);

        RETURN -1;

END Get_Conversion_Rate;


-- This procedure is no more used in R12
FUNCTION  Check_Intransit_Availability (
  p_org_id IN NUMBER)
  return NUMBER
IS
  /* return 0 -> Is not an intransit inventory */
  /* return 3 -> Is a Intransit enabled intransit inventory */
  retcode NUMBER;
  ret NUMBER;

 /* cursor intransit_org(x_org_id NUMBER) IS
    select 1
      from mtl_interorg_parameters
     where ((TO_ORGANIZATION_ID = x_org_id)
        or (FROM_ORGANIZATION_ID = x_org_id))
       and NVL(FOB_POINT,-99) in (1,2)
       and rownum = 1;*/
BEGIN
  ret := 0;
  retcode := 0;
 /* OPEN intransit_org(p_org_id);
  FETCH intransit_org INTO ret;
    IF intransit_org%NOTFOUND THEN
      retcode := 0;
    ELSE
      retcode := 3;
    END IF;
  CLOSE intransit_org;*/
  Null;


  RETURN (retcode);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return (retcode);
END Check_Intransit_Availability;


End OPI_DBI_INV_VALUE_UTL_PKG;

/
