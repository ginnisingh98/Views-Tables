--------------------------------------------------------
--  DDL for Package Body OPI_DBI_MTL_VARIANCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_MTL_VARIANCE_PKG" AS
/*$Header: OPIDMUVETLB.pls 120.24 2006/09/21 00:38:11 asparama noship $ */

-- DBI GSD
g_global_start_date DATE;
g_r12_migration_date DATE;

g_refresh_bmv BOOLEAN := TRUE;

-- For reporting rows touched by certain SQLs
g_row_count NUMBER;

-- WHO column information
g_sysdate DATE := SYSDATE;
g_user_id NUMBER := nvl(fnd_global.user_id, -1);
g_login_id NUMBER := nvl(fnd_global.login_id, -1);
g_last_collection_date DATE;
g_program_id NUMBER;
g_program_login_id NUMBER;
g_program_application_id NUMBER;
g_request_id NUMBER;

-- Currency code related file scope variables
g_global_currency_code VARCHAR2(10);
g_secondary_currency_code VARCHAR2 (10);
g_global_rate_type VARCHAR2(15);
g_secondary_rate_type VARCHAR2 (15);

-- Missing rate related constants
/*  Marker for secondary conv. rate if the primary and secondary curr codes
    and rate types are identical. Can't be -1, -2, -3 since the FII APIs
    return those values. */
C_PRI_SEC_CURR_SAME_MARKER CONSTANT NUMBER := -9999;

-- GL API returns -3 if EURO rate missing on 01-JAN-1999
C_EURO_MISSING_AT_START CONSTANT NUMBER := -3;

-- Start date of Euro currency
g_euro_start_date CONSTANT DATE := to_date('01/01/1999','DD/MM/YYYY');

-- Program return codes
g_ok CONSTANT NUMBER(1) := 0;
g_warning CONSTANT NUMBER(1) := 1;
g_error CONSTANT NUMBER(1) := -1;

-- OPI schema parameters
g_opi_schema     VARCHAR2(30);
g_opi_status     VARCHAR2(30);
g_opi_industry   VARCHAR2(30);

PROCEDURE CHECK_OPI_MFG_CST_VAR_SETUP(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2);



/* get_conversion_rate

    Compute all the conversion rates for all distinct organization,
    transaction date pairs in the staging table. The date in the fact
    table is already without a timestamp i.e. trunc'ed.

    There are two conversion rates to be computed:
    1. Primary global
    2. Secondary global (if set up)

    The conversion rate work table was truncated during
    the initialization phase.

    Get the currency conversion rates based on the organizations in the
    WIP_ENTITIES and IC_WHSE_MST tabls using the
    fii_currency.get_global_rate_primary API for the primary global
    currency and fii_currency.get_global_rate_secondary for the
    secondary global currency.
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
    08/30/2004      Dinkar Gupta        Modified to provide secondary
                                        currency support.
*/

FUNCTION get_conversion_rate (errbuf  in out NOCOPY VARCHAR2,
                              retcode in out NOCOPY VARCHAR2)
    RETURN NUMBER
IS

    -- Cursor to see if any rates are missing. See below for details
    CURSOR invalid_rates_exist_csr IS
        SELECT 1
          FROM opi_dbi_cuv_conv_rates
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
                                p_secondary_rate_type VARCHAR2,
                                p_sysdate DATE) IS
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
                            C_EURO_MISSING_AT_START, g_euro_start_date,
                            conv.transaction_date) transaction_date,
                    conv.f_currency_code func_currency_code
              FROM opi_dbi_cuv_conv_rates conv,
                   mtl_parameters mp,
                   (SELECT /*+ parallel_index(we) index_ffs(we) */
                    DISTINCT
                        organization_id,
                        p_sysdate transaction_date
                      FROM wip_entities we
                    ) to_conv
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
                            C_EURO_MISSING_AT_START, g_euro_start_date,
                            conv.transaction_date) transaction_date,
                    conv.f_currency_code func_currency_code
              FROM opi_dbi_cuv_conv_rates conv,
                   mtl_parameters mp,
                   (SELECT /*+ parallel_index(we) index_ffs(we) */
                    DISTINCT
                        organization_id,
                        p_sysdate transaction_date
                      FROM wip_entities we
                    ) to_conv
              WHERE nvl (conv.sec_conversion_rate, 999) < 0 -- null is fine
                AND mp.organization_id = to_conv.organization_id
                AND conv.transaction_date (+) = to_conv.transaction_date
                AND conv.organization_id (+) = to_conv.organization_id)
          ORDER BY
                report_order ASC,
                transaction_date,
                func_currency_code;

    -- position marker in function
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
    no_currency_rate_flag := 0;
    l_pri_sec_curr_same := 0;
    retcode := g_ok;

    l_stmt_num := 10;
    -- WHO column variable initialization
    g_sysdate := trunc (SYSDATE);
    g_user_id := nvl(fnd_global.user_id, -1);
    g_login_id := nvl(fnd_global.login_id, -1);


    l_stmt_num := 12;
    -- Global currency codes -- already checked if primary is set up
    g_global_currency_code := bis_common_parameters.get_currency_code;
    g_secondary_currency_code :=
            bis_common_parameters.get_secondary_currency_code;

    g_global_start_date := trunc (bis_common_parameters.get_global_start_date);

    l_stmt_num := 14;
    -- Global rate types -- already checked if primary is set up
    g_global_rate_type := bis_common_parameters.get_rate_type;
    g_secondary_rate_type := bis_common_parameters.get_secondary_rate_type;

    l_stmt_num := 16;
    -- check that either both the secondary rate type and secondary
    -- rate are null, or that neither are null.
    IF (   (g_secondary_currency_code IS NULL AND
            g_secondary_rate_type IS NOT NULL)
        OR (g_secondary_currency_code IS NOT NULL AND
            g_secondary_rate_type IS NULL) ) THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE ('The global secondary currency code setup is incorrect. The secondary currency code cannot be null when the secondary rate type is defined and vice versa.');

        RAISE_APPLICATION_ERROR(-20000, errbuf);

    END IF;


    l_stmt_num := 18;
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
    INTO opi_dbi_cuv_conv_rates rates (
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
   	REQUEST_ID)
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
                            to_conv.transaction_date))),
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
       (SELECT /*+ parallel_index(we) index_ffs(we) */
        DISTINCT
            organization_id,
            g_sysdate transaction_date
          FROM wip_entities we
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


    --Introduced commit because of append parallel in the insert stmt above.
    commit;

    l_stmt_num := 40;
    -- if the primary and secondary currency codes are the same, then
    -- update the secondary with the primary
    IF (l_pri_sec_curr_same = 1) THEN

        UPDATE /*+ parallel (opi_dbi_cuv_conv_rates) */
        opi_dbi_cuv_conv_rates
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
        FOR get_missing_rates_rec IN get_missing_rates_c
                                        (l_pri_sec_curr_same,
                                         g_global_currency_code,
                                         g_global_rate_type,
                                         g_secondary_currency_code,
                                         g_secondary_rate_type,
                                         g_sysdate)
        LOOP

            BIS_COLLECTION_UTILITIES.writemissingrate (
                get_missing_rates_rec.rate_type,
                get_missing_rates_rec.func_currency_code,
                get_missing_rates_rec.curr_code,
                get_missing_rates_rec.transaction_date);

        END LOOP;

    END IF;
    CLOSE invalid_rates_exist_csr;

    l_stmt_num := 70; /* check no_currency_rate_flag  */
    IF (no_currency_rate_flag = 1) THEN /* missing rate found */
        BIS_COLLECTION_UTILITIES.put_line('Please setup conversion rate for all missing rates reported');
        retcode := g_error; -- there are missing rates to report
    END IF;

    return retcode;

EXCEPTION
    WHEN OTHERS THEN
        rollback;
        i_err_num := SQLCODE;
        i_err_msg := 'OPI_DBI_MTL_VARIANCE_PKG.GET_CONVERSION_RATE ('
                        || to_char(l_stmt_num)
                        || '): '
                        || substr(SQLERRM, 1,200);

        BIS_COLLECTION_UTILITIES.put_line('OPI_DBI_MTL_VARIANCE_PKG.GET_CONVERSION_RATE - Error at statement ('
                        || to_char(l_stmt_num)
                        || ')');

        BIS_COLLECTION_UTILITIES.put_line('Error Number: ' ||  to_char(i_err_num));
        BIS_COLLECTION_UTILITIES.put_line('Error Message: ' || i_err_msg);

        return g_error;

END get_conversion_rate;

-- Replace standard costs with get_cost for rows where zero std cost
--   was caused by actual qty = 0 ans std qty <> 0
procedure Fix_OPM_Std_costs
is
l_stmt_num Number;
begin

    commit;

    l_stmt_num  := 61;

--Setup bulk costing parameter table

  insert into opi_pmi_cost_param_gtmp
  (
  ITEM_ID,
  WHSE_CODE,
  ORGN_CODE,
  TRANS_DATE
  )
  select distinct
    scaled.ITEM_ID   ,
    whse.WHSE_CODE ,
    whse.ORGN_CODE ,
    jobs.COMPLETION_DATE         TRANS_DATE
  from
    OPI_DBI_OPM_SCALED_MTL  scaled,
    ic_whse_mst             whse,
    OPI_DBI_JOBS_F          jobs
  where
        whse.mtl_organization_id = jobs.organization_id
    and jobs.job_id              = scaled.batch_id
    and jobs.job_type            = 4
    and scaled.actual_qty        = 0
    and scaled.plan_qty         <> 0;

  l_stmt_num  := 62;

  opi_pmi_cost.get_cost;

  l_stmt_num  := 63;


-- bulk costing results to update fact


  update /*+ parallel(f) */ OPI_DBI_JOB_MTL_DETAILS_F  f
    set STANDARD_VALUE_B =
      (select f.standard_quantity * costs.total_cost
      from opi_pmi_cost_result_gtmp costs,
           OPI_DBI_JOBS_F           jobs,
           ic_whse_mst              whse,
           ic_item_mst_b              item,
           mtl_System_items_b         msi
        where whse.mtl_organization_id = f.organization_id
          and whse.whse_code = costs.whse_code
          and whse.orgn_code = costs.orgn_code
          and trunc(jobs.completion_date) = trunc(costs.trans_date)
          and jobs.job_type = 4
          and jobs.job_id = f.job_id
          and jobs.organization_id = f.organization_id
          and jobs.assembly_item_id = f.assembly_item_id
          and f.component_item_id = msi.inventory_item_id
          and f.organization_id   = msi.organization_id
          and msi.segment1        = item.item_no
          and costs.item_id = item.item_id
      )
   where f.standard_value_b   = 0
     and f.actual_value_b     = 0
     and f.actual_quantity    = 0
     and f.standard_quantity <> 0
     and f.job_type= 4           -- OPM jobs
     and f.source = 2;           -- OPM source


end Fix_OPM_Std_costs;

/*

   Pre R12 OPM Extraction code will be called only if r12 migration date is
   less than GSD.

   Parameters:
     retcode - 0 on successful completion, -1 on error and 1 for warning.
     errbuf - empty on successful completion, message on error or warning

*/

PROCEDURE GET_MFG_CST_VAR_PRER12_INIT(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
 l_stmt_num NUMBER;
 l_row_count NUMBER;
 l_err_num NUMBER;
 l_err_msg VARCHAR2(255);
 l_proc_name VARCHAR2(255);
BEGIN

    l_proc_name := 'OPI_DBI_MTL_VARIANCE_PKG.GET_MFG_CST_VAR_PRER12_INIT';

    BIS_COLLECTION_UTILITIES.PUT_LINE('Entering Procedure '|| l_proc_name);

    l_stmt_num := 10;
    --Inserting Pre R12 OPM data
    INSERT /*+ append parallel(OPI_DBI_MFG_CST_VAR_F) */
    INTO OPI_DBI_MFG_CST_VAR_F
    (
    Organization_Id
    ,Job_Id
    ,Job_Type
    ,Assembly_Item_id
    ,Closed_date
    ,standard_value_b
    ,actual_value_b
    ,standard_value_g
    ,actual_value_g
    ,standard_value_sg
    ,actual_value_sg
    ,Actual_Qty_Completed
    ,UOM_Code
    ,Conversion_rate
    ,Sec_conversion_rate
    ,Source
    ,Creation_Date
    ,Last_Update_Date
    ,Created_By
    ,Last_Updated_By
    ,Last_Update_Login
    ,PROGRAM_ID
    ,PROGRAM_LOGIN_ID
    ,PROGRAM_APPLICATION_ID
    ,REQUEST_ID
    )
    SELECT
    	var.organization_id organization_id,
        var.job_id job_id,
        var.job_type job_type,
        var.assembly_item_id assembly_item_id,
        var.closed_date closed_date,
        sum (standard_value_b * nvl(dtl.cost_alloc, 0)) standard_value_b,
        sum (actual_value_b * nvl(dtl.cost_alloc, 0)) actual_value_b,
        sum (standard_value_b * nvl(dtl.cost_alloc, 0)*conversion_rate) standard_value_g,
        sum (standard_value_b * nvl(dtl.cost_alloc, 0)*sec_conversion_rate) standard_value_sg,
        sum (actual_value_b * nvl(dtl.cost_alloc, 0)*conversion_rate) actual_value_g,
        sum (actual_value_b * nvl(dtl.cost_alloc, 0)*sec_conversion_rate) actual_value_sg,
        sum (actual_qty_completed) actual_qty_completed,
        uom_code uom_code,
        conversion_rate conversion_rate,
        sec_conversion_rate sec_conversion_rate,
        3 source,
        g_sysdate creation_date,
        g_sysdate last_update_date,
        g_user_id created_by,
        g_user_id last_updated_by,
        g_login_id last_update_login,
        g_program_id PROGRAM_ID,
        g_program_login_id PROGRAM_LOGIN_ID,
        g_program_application_id PROGRAM_APPLICATION_ID,
        g_request_id REQUEST_ID
    FROM
        (
         SELECT
           led.Organization_id Organization_id,
           led.job_id job_id,
           led.job_type job_type,
           led.assembly_item_id assembly_item_id,
           led.completion_date closed_date,
           sum (led.actual_value_b) actual_value_b,
           sum (led.standard_value_b) standard_value_b,
           led.actual_qty_completed actual_qty_completed,
           led.uom_code uom_code,
           rates.conversion_rate conversion_rate,
           rates.sec_conversion_rate sec_conversion_rate
         FROM
           OPI_DBI_JOBS_F rates,
           (
           SELECT
             jobs.Organization_id,
             jobs.Job_Id,
             jobs.Job_Type,
             jobs.Assembly_Item_id,
             jobs.Completion_date,
             jobs.Actual_Qty_Completed,
             jobs.UOM_Code,
             gsl.doc_id,
             gsl.doc_type,
             gsl.gl_trans_date,
             gsl.line_id,
             -sum (decode (acct_ttl_type,1500,
                      decode (sub_event_type,50040 ,
      	            decode(jobs.line_type,2,gsl.amount_base*gsl.debit_credit_sign,0),
                      /* decode else */
                      gsl.amount_base * gsl.debit_credit_sign),
                   /* decode else */
                   gsl.amount_base * gsl.debit_credit_sign)) Actual_Value_B,
             sum (decode (acct_ttl_type, 1500,
                     decode (sub_event_type, 50040,
                         decode(jobs.line_type,1,gsl.amount_base * gsl.debit_credit_sign,0),
                      /* decode else */
                     0),
                  /* decode else */ 0 ) ) Standard_Value_B
           FROM
             GL_SUBR_LED    gsl,
             (
             select
      	       jobs.Organization_id,
               jobs.Job_Id,
               jobs.Job_Type,
               jobs.Assembly_Item_id,
               jobs.Completion_date,
               jobs.Actual_Qty_Completed,
               jobs.UOM_Code,
    	       gmd.line_type,
    	       gmd.material_detail_id line_id
             from
    	       OPI_DBI_JOBS_F jobs,
    	       GME_MATERIAL_DETAILS gmd
             where
    	       jobs.job_id = gmd.batch_id and
    	       jobs.status = 'Closed' and
    	       jobs.source = 3
             union all
             select
    	       jobs.Organization_id,
               jobs.Job_Id,
               jobs.Job_Type,
               jobs.Assembly_Item_id,
               jobs.Completion_date,
               jobs.Actual_Qty_Completed,
               jobs.UOM_Code,
               0,
               gbsr.batchstep_resource_id line_id
             from
    	       OPI_DBI_JOBS_F jobs,
    	       GME_BATCH_STEP_RESOURCES  gbsr
             where
    	       jobs.job_id = gbsr.batch_id and
    	       jobs.status = 'Closed' and
    	       jobs.source = 3) jobs
           WHERE
             gsl.doc_type = 'PROD'
             and gsl.line_id = jobs.line_id
             AND gsl.doc_id = jobs.job_id
             AND ((  gsl.acct_ttl_type   =  5400
                     and gsl.sub_event_type  in ( 50010, 50040, 50050 )
                 )
                 or
                 (   gsl.acct_ttl_type   =  1500
                     and gsl.sub_event_type  in ( 50010, 50040 )
                 ))
          GROUP BY
            jobs.Organization_id,
            jobs.Job_Id,
            jobs.Job_Type,
            jobs.Assembly_Item_id,
            jobs.Completion_date,
            jobs.Actual_Qty_Completed,
            jobs.UOM_Code,
            doc_id,
            doc_type,
            gl_trans_date,
            gsl.line_id ) led
        WHERE
          led.ORGANIZATION_ID = rates.organization_id and
          led.job_id = rates.job_id and
          led.job_type = rates.job_type and
          led.assembly_item_id = rates.assembly_item_id and
          rates.source = 3
        GROUP BY
          led.Organization_id,
          led.Job_Id,
          led.Job_Type,
          led.Assembly_Item_id,
          led.Completion_date,
          led.Actual_Qty_Completed,
          led.UOM_Code,
          rates.Conversion_Rate,
          rates.Sec_conversion_rate) var,
        gme_material_details   dtl
      where
        dtl.batch_id             = var.job_id
        AND dtl.line_type            = 1
        AND dtl.inventory_item_id    = var.assembly_item_id
        AND dtl.organization_id      = var.organization_id
      group by
        var.organization_id,
        var.job_id,
        var.job_type,
        var.assembly_item_id,
        var.closed_date,
        uom_code,
        conversion_rate,
    	sec_conversion_rate;

     l_row_count := sql%rowcount;

     BIS_COLLECTION_UTILITIES.PUT_LINE('Finished Pre R12 OPM Manufacturing Cost Variance load into Fact Table: '|| l_row_count || ' rows inserted');
     BIS_COLLECTION_UTILITIES.PUT_LINE('Exiting Procedure '|| l_proc_name);

END GET_MFG_CST_VAR_PRER12_INIT;

/*

Initial Load MCV.
This procedure extracts R12 OPM and ODM for MCV, also call to Pre R12 OPM is made if
R12 migration date is greater than global start date.

*/

PROCEDURE GET_MFG_CST_VAR_INIT(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
 l_stmt_num NUMBER;
 l_row_count NUMBER;
 l_err_num NUMBER;
 l_err_msg VARCHAR2(255);
 l_status          VARCHAR2(30);
 l_industry        VARCHAR2(30);
 l_opi_schema      VARCHAR2(30);
 l_proc_name VARCHAR2(255);
BEGIN

    l_proc_name := 'OPI_DBI_MTL_VARIANCE_PKG.GET_MFG_CST_VAR_INIT';
    BIS_COLLECTION_UTILITIES.PUT_LINE('Entering Procedure '|| l_proc_name);

    -- WHO column variable initialization
    g_sysdate := SYSDATE;
    g_user_id := nvl(fnd_global.user_id, -1);
    g_login_id := nvl(fnd_global.login_id, -1);
    g_program_id := nvl (fnd_global.conc_program_id, -1);
    g_program_login_id := nvl (fnd_global.conc_login_id, -1);
    g_program_application_id := nvl (fnd_global.prog_appl_id,  -1);
    g_request_id := nvl (fnd_global.conc_request_id, -1);


    /* Check For Setup */
    l_stmt_num := 10;
    CHECK_OPI_MFG_CST_VAR_SETUP(errbuf,retcode);

    /* Truncating Fact Table */
    l_stmt_num := 15;
    IF fnd_installation.get_app_info( 'OPI', l_status, l_industry, l_opi_schema) THEN
    --{
    	execute immediate 'truncate table ' || l_opi_schema || '.OPI_DBI_MFG_CST_VAR_F';
    --}
    END IF;

    execute immediate 'alter session enable parallel dml';

    /* Calling to populate temp table for mutli ledger/valuation_cost_type in gtv table */
    l_stmt_num := 17;
    BIS_COLLECTION_UTILITIES.PUT_LINE('Calling to populate temp table for mutli ledger/valuation_cost_type in gtv table');
    OPI_DBI_BOUNDS_PKG.load_opm_org_ledger_data;

    /* Insert OPI Manufacturing Cost Variances */
    l_stmt_num := 20;
    INSERT /*+ append parallel(OPI_DBI_MFG_CST_VAR_F) */
    INTO OPI_DBI_MFG_CST_VAR_F
    (
     Organization_Id
    ,Job_Id
    ,Job_Type
    ,Assembly_Item_id
    ,Closed_date
    ,standard_value_b
    ,actual_value_b
    ,standard_value_g
    ,actual_value_g
    ,standard_value_sg
    ,actual_value_sg
    ,Actual_Qty_Completed
    ,UOM_Code
    ,Conversion_rate
    ,Sec_conversion_rate
    ,Source
    ,Creation_Date
    ,Last_Update_Date
    ,Created_By
    ,Last_Updated_By
    ,Last_Update_Login
    ,PROGRAM_ID
    ,PROGRAM_LOGIN_ID
    ,PROGRAM_APPLICATION_ID
    ,REQUEST_ID
    )
    SELECT /*+ ordered use_hash(wpb) parallel(wpb) parallel(jobs)*/
        wpb.organization_id organization_id,
        jobs.job_id job_id,
        jobs.job_type job_type,
        jobs.assembly_item_id assembly_item_id,
        jobs.completion_date closed_date,
        sum (nvl(tl_material_out,0) + nvl(tl_material_overhead_out,0) +
             nvl(tl_resource_out,0) + nvl(tl_overhead_out,0) +
             nvl(tl_outside_processing_out,0) + nvl(tl_scrap_out,0) +
             nvl(pl_material_out,0) + nvl(pl_material_overhead_out,0) +
             nvl(pl_resource_out,0) + nvl(pl_overhead_out,0) +
             nvl(pl_outside_processing_out,0) ) standard_value_b,
        sum (nvl(tl_resource_in,0) + nvl(tl_overhead_in,0) +
             nvl(tl_outside_processing_in,0) + nvl(pl_material_in,0) +
             nvl(pl_material_overhead_in,0) + nvl(pl_resource_in,0) +
             nvl(pl_overhead_in,0) + nvl(pl_outside_processing_in,0) +
             nvl(tl_scrap_in,0)) actual_value_b,
        sum ((nvl(tl_material_out,0) + nvl(tl_material_overhead_out,0) +
	     nvl(tl_resource_out,0) + nvl(tl_overhead_out,0) +
	     nvl(tl_outside_processing_out,0) + nvl(tl_scrap_out,0) +
	     nvl(pl_material_out,0) + nvl(pl_material_overhead_out,0) +
	     nvl(pl_resource_out,0) + nvl(pl_overhead_out,0) +
             nvl(pl_outside_processing_out,0))*jobs.conversion_rate) standard_value_g,
        sum ((nvl(tl_resource_in,0) + nvl(tl_overhead_in,0) +
	     nvl(tl_outside_processing_in,0) + nvl(pl_material_in,0) +
	     nvl(pl_material_overhead_in,0) + nvl(pl_resource_in,0) +
	     nvl(pl_overhead_in,0) + nvl(pl_outside_processing_in,0) +
             nvl(tl_scrap_in,0))*jobs.conversion_rate) actual_value_g,
        sum ((nvl(tl_material_out,0) + nvl(tl_material_overhead_out,0) +
	     nvl(tl_resource_out,0) + nvl(tl_overhead_out,0) +
	     nvl(tl_outside_processing_out,0) + nvl(tl_scrap_out,0) +
	     nvl(pl_material_out,0) + nvl(pl_material_overhead_out,0) +
	     nvl(pl_resource_out,0) + nvl(pl_overhead_out,0) +
             nvl(pl_outside_processing_out,0))*jobs.sec_conversion_rate) standard_value_sg,
        sum ((nvl(tl_resource_in,0) + nvl(tl_overhead_in,0) +
	     nvl(tl_outside_processing_in,0) + nvl(pl_material_in,0) +
	     nvl(pl_material_overhead_in,0) + nvl(pl_resource_in,0) +
	     nvl(pl_overhead_in,0) + nvl(pl_outside_processing_in,0) +
             nvl(tl_scrap_in,0))*jobs.sec_conversion_rate) actual_value_sg,
        jobs.actual_qty_completed actual_qty_completed,
        jobs.uom_code uom_code,
        jobs.conversion_rate conversion_rate,
        jobs.sec_conversion_rate sec_conversion_rate,
        1 source,
        g_sysdate creation_date,
        g_sysdate last_update_date,
        g_user_id created_by,
        g_user_id last_updated_by,
        g_login_id last_update_login,
        g_program_id PROGRAM_ID,
	g_program_login_id PROGRAM_LOGIN_ID,
	g_program_application_id PROGRAM_APPLICATION_ID,
	g_request_id REQUEST_ID
      FROM
        OPI_DBI_JOBS_F jobs,
        WIP_PERIOD_BALANCES wpb
      WHERE jobs.Status = 'Closed'
        AND jobs.organization_id = wpb.organization_id
        AND jobs.job_id = decode (wpb.class_type,
                                  1, wpb.wip_entity_id,
                                  5, wpb.wip_entity_id,
                                  2, wpb.repetitive_schedule_id)
      GROUP BY
            wpb.organization_id,
            jobs.job_id,
            jobs.job_type,
            jobs.assembly_item_id,
            jobs.completion_date,
            jobs.actual_qty_completed,
            jobs.uom_code,
            jobs.conversion_rate,
            jobs.sec_conversion_rate
  /*Post R12 OPM Inert */
  UNION ALL
  SELECT  /*+ parallel(var) */
    var.organization_id organization_id,
    var.job_id job_id,
    var.job_type job_type,
    var.assembly_item_id assembly_item_id,
    var.closed_date closed_date,
    var.standard_value_b,
    var.actual_value_b,
    var.standard_value_b*var.conversion_rate standard_value_g,
    var.actual_value_b*var.conversion_rate actual_value_g,
    var.standard_value_b*var.sec_conversion_rate standard_value_sg,
    var.actual_value_b*var.sec_conversion_rate actual_value_sg,
    var.actual_qty_completed,
    var.uom_code uom_code,
    var.conversion_rate conversion_rate,
    var.sec_conversion_rate sec_conversion_rate,
    2 source,
    g_sysdate creation_date,
    g_sysdate last_update_date,
    g_user_id created_by,
    g_user_id last_updated_by,
    g_login_id last_update_login,
    g_program_id PROGRAM_ID,
    g_program_login_id PROGRAM_LOGIN_ID,
    g_program_application_id PROGRAM_APPLICATION_ID,
    g_request_id REQUEST_ID
  FROM
    (
       select /*+ use_hash(jobs) parallel(jobs) parallel(gtv) parallel(tmp) parallel(mtl_dtl) use_hash(gtv mtl_dtl) full(gtv)*/
		 job_id,
         job_type,
         jobs.assembly_item_id,
         jobs.organization_id,
         jobs.actual_qty_completed,
         jobs.uom_code,
         jobs.completion_date closed_date,
         jobs.conversion_rate,
         jobs.sec_conversion_rate,
         -sum(Decode(jobs.line_type,1,decode(jobs.line_id, mtl_dtl.material_detail_id,
         						-txn_base_value,0),0)) standard_Value_b,
         -sum(Decode(jobs.line_type,-1,txn_base_value*mtl_dtl.cost_alloc,
                                    2,txn_base_value*mtl_dtl.cost_alloc, 0)) actual_Value_b
       from
         GMF_TRANSACTION_VALUATION GTV,
         OPI_DBI_ORG_LE_TEMP tmp,
         GME_MATERIAL_DETAILS mtl_dtl,
         (
           select /*+ no_merge ordered use_hash(mtl_dtl) full(jobs) parallel(mtl_dtl) parallel(jobs) */
             jobs.Job_id,
             jobs.job_type,
             mtl_dtl.material_detail_id line_id,
             jobs.assembly_item_id,
             to_char(mtl_dtl.inventory_item_id) item_resource_id,
             jobs.actual_qty_completed,
             jobs.completion_date,
             jobs.uom_code,
             mtl_dtl.Line_type,
             jobs.organization_id,
             jobs.conversion_rate,
             jobs.sec_conversion_rate
           from
             OPI_DBI_JOBS_F jobs,
             GME_MATERIAL_DETAILS mtl_dtl
           where
             jobs.job_id = mtl_dtl.batch_id and
             jobs.organization_id = mtl_dtl.organization_id and
             mtl_dtl.line_type in (-1,1,2) and
             jobs.source = 2 and
             jobs.status in ('Closed') and
             jobs.line_type = 1
           union all
           select  /*+ ordered use_hash(GBSR) full(jobs) parallel(jobs) parallel(gbsr)*/
             jobs.job_id,
             jobs.job_type,
             gbsr.batchstep_resource_id line_id,
             jobs.assembly_item_id,
             gbsr.resources item_resource_id,
             jobs.actual_qty_completed,
             jobs.completion_date,
             jobs.uom_code,
             -1 Line_type,
             jobs.Organization_id,
             jobs.conversion_rate,
             jobs.sec_conversion_rate
           from
             OPI_DBI_JOBS_F jobs,
             GME_BATCH_STEP_RESOURCES gbsr
           where
             jobs.job_id = gbsr.batch_id and
             jobs.source = 2 and
             jobs.status in ('Closed') and
             jobs.line_type = 1) Jobs
       where
         jobs.organization_id = GTV.organization_id and
         jobs.job_id = GTV.doc_id and
         (jobs.item_resource_id = to_char(GTV.inventory_item_id)
          or jobs.item_resource_id = GTV.resources) and
         GTV.line_id = jobs.line_id and
         GTV.journal_line_type in ('INV','RCA') and
         GTV.event_class_code in ('BATCH_MATERIAL','BATCH_RESOURCE') and
         GTV.transaction_source = 'PRODUCTION' and
         jobs.job_id = mtl_dtl.batch_id and
         jobs.organization_id = mtl_dtl.organization_id and
         jobs.assembly_item_id = mtl_dtl.inventory_item_id and
         mtl_dtl.line_type = 1 and
         GTV.ledger_id = tmp.ledger_id and
         GTV.legal_entity_id = tmp.legal_entity_id and
	 GTV.valuation_cost_type_id = tmp.valuation_cost_type_id and
         GTV.organization_id = tmp. organization_id
       Group by
         jobs.job_id,
         jobs.job_type,
         jobs.organization_id,
         jobs.assembly_item_id,
         jobs.actual_qty_completed,
         jobs.uom_code,
         jobs.completion_date,
         jobs.conversion_rate,
         jobs.sec_conversion_rate) var;


    l_row_count := sql%rowcount;
    g_row_count := g_row_count + l_row_count;
    BIS_COLLECTION_UTILITIES.PUT_LINE('Finished OPI and OPM Manufacturing Cost Variance load into Fact Table: '|| l_row_count || ' rows inserted');

    commit;

    IF(g_r12_migration_date > g_global_start_date) THEN

    	GET_MFG_CST_VAR_PRER12_INIT(errbuf => errbuf, retcode => retcode);

    END IF;
    commit;
    execute immediate 'alter session disable parallel dml';

    /* Truncating Jobs Staging Table */
    l_stmt_num := 30;
    IF fnd_installation.get_app_info( 'OPI', l_status, l_industry, l_opi_schema) THEN
    --{
        execute immediate 'truncate table ' || l_opi_schema || '.OPI_DBI_JOBS_STG';
    --}
    END IF;

    BIS_COLLECTION_UTILITIES.PUT_LINE('Exiting Procedure '|| l_proc_name);

END GET_MFG_CST_VAR_INIT;

/*

Incremental Load MCV.
This procedure extracts R12 OPM and ODM for MCV.

*/

PROCEDURE GET_MFG_CST_VAR_INCR(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
 l_stmt_num NUMBER;
 l_row_count1 NUMBER;
 l_row_count2 NUMBER;
 l_err_num NUMBER;
 l_err_msg VARCHAR2(255);
 l_status          VARCHAR2(30);
 l_industry        VARCHAR2(30);
 l_opi_schema      VARCHAR2(30);
 l_proc_name VARCHAR2(255);
BEGIN

    l_proc_name := 'OPI_DBI_MTL_VARIANCE_PKG.GET_MFG_CST_VAR_INCR';
    BIS_COLLECTION_UTILITIES.PUT_LINE('Entering Procedure '|| l_proc_name);

    -- WHO column variable initialization
    g_sysdate := SYSDATE;
    g_user_id := nvl(fnd_global.user_id, -1);
    g_login_id := nvl(fnd_global.login_id, -1);
    g_program_id := nvl (fnd_global.conc_program_id, -1);
    g_program_login_id := nvl (fnd_global.conc_login_id, -1);
    g_program_application_id := nvl (fnd_global.prog_appl_id,  -1);
    g_request_id := nvl (fnd_global.conc_request_id, -1);

    /* Check For Setup */
    l_stmt_num := 10;
    CHECK_OPI_MFG_CST_VAR_SETUP(errbuf,retcode);

    /* Calling to populate temp table for mutli ledger/valuation_cost_type in gtv table */
    l_stmt_num := 15;
    BIS_COLLECTION_UTILITIES.PUT_LINE('Calling to populate temp table for mutli ledger/valuation_cost_type in gtv table');
    OPI_DBI_BOUNDS_PKG.load_opm_org_ledger_data;

    /* Insert OPI Manufacturing Cost Variances */
    l_stmt_num := 20;
    MERGE INTO OPI_DBI_MFG_CST_VAR_F f
    USING
    (
    SELECT
        wpb_Organization_id Organization_id,
        jobs.Job_Id Job_id,
        jobs.Job_Type Job_Type,
        jobs.Assembly_Item_id Assembly_Item_id,
        jobs.Completion_date Closed_date,
        sum (nvl(tl_material_out,0) + nvl(tl_material_overhead_out,0) +
             nvl(tl_resource_out,0) + nvl(tl_overhead_out,0) +
             nvl(tl_outside_processing_out,0) + nvl(tl_scrap_out,0) +
             nvl(pl_material_out,0) + nvl(pl_material_overhead_out,0) +
             nvl(pl_resource_out,0) + nvl(pl_overhead_out,0) +
             nvl(pl_outside_processing_out,0) ) Standard_Value_B,
        sum (nvl(tl_resource_in,0) + nvl(tl_overhead_in,0) +
             nvl(tl_outside_processing_in,0) + nvl(pl_material_in,0) +
             nvl(pl_material_overhead_in,0) + nvl(pl_resource_in,0) +
             nvl(pl_overhead_in,0) + nvl(pl_outside_processing_in,0) +
             nvl(tl_scrap_in,0)) Actual_Value_B,
        sum ((nvl(tl_material_out,0) + nvl(tl_material_overhead_out,0) +
	     nvl(tl_resource_out,0) + nvl(tl_overhead_out,0) +
	     nvl(tl_outside_processing_out,0) + nvl(tl_scrap_out,0) +
	     nvl(pl_material_out,0) + nvl(pl_material_overhead_out,0) +
	     nvl(pl_resource_out,0) + nvl(pl_overhead_out,0) +
             nvl(pl_outside_processing_out,0))*rates.Conversion_Rate) Standard_Value_G,
        sum ((nvl(tl_resource_in,0) + nvl(tl_overhead_in,0) +
	     nvl(tl_outside_processing_in,0) + nvl(pl_material_in,0) +
	     nvl(pl_material_overhead_in,0) + nvl(pl_resource_in,0) +
	     nvl(pl_overhead_in,0) + nvl(pl_outside_processing_in,0) +
             nvl(tl_scrap_in,0))*rates.Conversion_Rate) Actual_Value_G,
        sum ((nvl(tl_material_out,0) + nvl(tl_material_overhead_out,0) +
	     nvl(tl_resource_out,0) + nvl(tl_overhead_out,0) +
	     nvl(tl_outside_processing_out,0) + nvl(tl_scrap_out,0) +
	     nvl(pl_material_out,0) + nvl(pl_material_overhead_out,0) +
	     nvl(pl_resource_out,0) + nvl(pl_overhead_out,0) +
	     nvl(pl_outside_processing_out,0))*rates.sec_Conversion_Rate) Standard_Value_SG,
        sum ((nvl(tl_resource_in,0) + nvl(tl_overhead_in,0) +
	     nvl(tl_outside_processing_in,0) + nvl(pl_material_in,0) +
	     nvl(pl_material_overhead_in,0) + nvl(pl_resource_in,0) +
	     nvl(pl_overhead_in,0) + nvl(pl_outside_processing_in,0) +
             nvl(tl_scrap_in,0))*rates.sec_Conversion_Rate) Actual_Value_SG,
        jobs.Actual_Qty_Completed Actual_Qty_Completed,
        jobs.UOM_Code UOM_Code,
        rates.Conversion_Rate Conversion_Rate,
        rates.sec_Conversion_Rate sec_Conversion_Rate,
        1 SOURCE,
        g_sysdate                CREATION_DATE,
        g_sysdate                LAST_UPDATE_DATE,
        g_user_id                CREATED_BY,
        g_user_id                LAST_UPDATED_BY,
        g_login_id               LAST_UPDATE_LOGIN,
        g_program_id             PROGRAM_ID,
	g_program_login_id       PROGRAM_LOGIN_ID,
	g_program_application_id PROGRAM_APPLICATION_ID,
        g_request_id             REQUEST_ID
    FROM (SELECT WPB.ORGANIZATION_ID WPB_ORGANIZATION_ID
               , JOBS.ORGANIZATION_ID
               , JOBS.JOB_ID
               , JOBS.JOB_TYPE
               , JOBS.ASSEMBLY_ITEM_ID
               , JOBS.COMPLETION_DATE
               , JOBS.ACTUAL_QTY_COMPLETED
               , JOBS.UOM_CODE
               , JOBS.LINE_TYPE
               , JOBS.SOURCE
	      		   , WPB.PL_MATERIAL_IN
               , WPB.PL_MATERIAL_OUT
               , WPB.PL_MATERIAL_OVERHEAD_IN
               , WPB.PL_MATERIAL_OVERHEAD_OUT
               , WPB.PL_OUTSIDE_PROCESSING_IN
               , WPB.PL_OUTSIDE_PROCESSING_OUT
               , WPB.PL_OVERHEAD_IN
               , WPB.PL_OVERHEAD_OUT
               , WPB.PL_RESOURCE_IN
               , WPB.PL_RESOURCE_OUT
               , WPB.TL_MATERIAL_OUT
               , WPB.TL_MATERIAL_OVERHEAD_OUT
               , WPB.TL_OUTSIDE_PROCESSING_IN
               , WPB.TL_OUTSIDE_PROCESSING_OUT
               , WPB.TL_OVERHEAD_IN
               , WPB.TL_OVERHEAD_OUT
               , WPB.TL_RESOURCE_IN
               , WPB.TL_RESOURCE_OUT
               , WPB.TL_SCRAP_IN
               , WPB.TL_SCRAP_OUT
            FROM OPI_DBI_JOBS_STG jobs
               , WIP_PERIOD_BALANCES wpb
           WHERE jobs.Status = 'Closed'
        AND jobs.ORGANIZATION_ID = wpb.ORGANIZATION_ID
             AND wpb.CLASS_TYPE IN (1, 5)
             AND jobs.job_id = wpb.wip_entity_id
          UNION ALL
          SELECT WPB.ORGANIZATION_ID wpb_organization_id
               , JOBS.ORGANIZATION_ID
               , JOBS.JOB_ID
               , JOBS.JOB_TYPE
               , JOBS.ASSEMBLY_ITEM_ID
               , JOBS.COMPLETION_DATE
               , JOBS.ACTUAL_QTY_COMPLETED
               , JOBS.UOM_CODE
               , JOBS.LINE_TYPE
               , JOBS.SOURCE
               , WPB.PL_MATERIAL_IN
               , WPB.PL_MATERIAL_OUT
               , WPB.PL_MATERIAL_OVERHEAD_IN
               , WPB.PL_MATERIAL_OVERHEAD_OUT
               , WPB.PL_OUTSIDE_PROCESSING_IN
               , WPB.PL_OUTSIDE_PROCESSING_OUT
               , WPB.PL_OVERHEAD_IN
               , WPB.PL_OVERHEAD_OUT
               , WPB.PL_RESOURCE_IN
               , WPB.PL_RESOURCE_OUT
               , WPB.TL_MATERIAL_OUT
               , WPB.TL_MATERIAL_OVERHEAD_OUT
               , WPB.TL_OUTSIDE_PROCESSING_IN
               , WPB.TL_OUTSIDE_PROCESSING_OUT
               , WPB.TL_OVERHEAD_IN
               , WPB.TL_OVERHEAD_OUT
               , WPB.TL_RESOURCE_IN
               , WPB.TL_RESOURCE_OUT
               , WPB.TL_SCRAP_IN
               , WPB.TL_SCRAP_OUT
            FROM OPI_DBI_JOBS_STG jobs
               , WIP_PERIOD_BALANCES wpb
           WHERE jobs.Status = 'Closed'
        AND jobs.ORGANIZATION_ID = wpb.ORGANIZATION_ID
             AND wpb.CLASS_TYPE = 2
             AND jobs.Job_id = wpb.REPETITIVE_SCHEDULE_ID) jobs
       , OPI_DBI_JOBS_F rates
WHERE 1=1
        AND jobs.ORGANIZATION_ID = rates.organization_id
        AND jobs.job_id = rates.job_id
        AND jobs.job_type = rates.job_type
        AND jobs.line_type = rates.line_type
        AND jobs.assembly_item_id = rates.assembly_item_id
        AND jobs.source = rates.source
GROUP BY jobs.wpb_Organization_id
       , jobs.Job_Id
       , jobs.Job_Type
       , jobs.Assembly_Item_id
       , jobs.Completion_date
       , jobs.Actual_Qty_Completed
       , jobs.UOM_Code
       , rates.Conversion_Rate
       , rates.sec_Conversion_Rate
    ) v
    ON (    F.Organization_Id = V.Organization_Id AND F.Job_Id = V.Job_Id
        AND F.Job_Type = V.Job_Type
        AND F.Assembly_Item_id = V.Assembly_Item_id)
    WHEN MATCHED THEN
    UPDATE SET
         F.Closed_date = V.Closed_date
        ,F.Standard_Value_B = V.Standard_Value_B
        ,F.Actual_Value_B = V.Actual_Value_B
        ,F.Actual_Qty_Completed = V.Actual_Qty_Completed
        ,F.Conversion_rate = V.Conversion_rate
        ,F.Sec_Conversion_rate = V.Sec_Conversion_rate
        ,F.Last_Update_Date =  V.Last_Update_Date
        ,F.Last_Updated_By = V.Last_Updated_By
        ,F.Last_Update_Login = V.Last_Update_Login
    WHEN NOT MATCHED THEN
    INSERT (
        Organization_Id,
        Job_Id,
        Job_Type,
        Assembly_Item_id,
        Closed_date,
        Standard_Value_B,
        Actual_Value_B,
        Standard_Value_G,
        Actual_Value_G,
        Standard_Value_SG,
        Actual_Value_SG,
        Actual_Qty_Completed,
        UOM_Code,
        Conversion_rate,
        Sec_Conversion_rate,
        Source,
        Creation_Date,
        Last_Update_Date,
        Created_By,
        Last_Updated_By,
        Last_Update_Login,
        PROGRAM_ID,
        PROGRAM_LOGIN_ID,
        PROGRAM_APPLICATION_ID,
        REQUEST_ID)
    VALUES (
        V.Organization_Id,
        V.Job_Id,
        V.Job_Type,
        V.Assembly_Item_id,
        V.Closed_date,
        V.Standard_Value_B,
        V.Actual_Value_B,
        V.Standard_Value_G,
	V.Actual_Value_G,
	V.Standard_Value_SG,
        V.Actual_Value_SG,
        V.Actual_Qty_Completed,
        V.UOM_Code,
        V.Conversion_rate,
        V.Sec_Conversion_rate,
        V.Source,
        V.Creation_Date,
        V.Last_Update_Date,
        V.Created_By,
        V.Last_Updated_By,
        V.Last_Update_Login,
        V.PROGRAM_ID,
        V.PROGRAM_LOGIN_ID,
        V.PROGRAM_APPLICATION_ID,
        V.REQUEST_ID);


    l_row_count1 := sql%rowcount;

    /* OPM Big Merge here */

    l_stmt_num := 30;

    MERGE INTO OPI_DBI_MFG_CST_VAR_F f
    USING (
   SELECT
     var.organization_id organization_id,
     var.job_id job_id,
     var.job_type job_type,
     var.assembly_item_id assembly_item_id,
     var.closed_date closed_date,
     var.standard_value_b,
     var.actual_value_b,
     var.actual_qty_completed,
     var.uom_code uom_code,
     rates.conversion_rate conversion_rate,
     rates.sec_conversion_rate sec_conversion_rate,
     var.standard_value_b*rates.conversion_rate standard_value_g,
     var.actual_value_b*conversion_rate actual_value_g,
     var.standard_value_b*sec_conversion_rate standard_value_sg,
     var.actual_value_b*sec_conversion_rate actual_value_sg,
     2 source,
     g_sysdate creation_date,
     g_sysdate last_update_date,
     g_user_id created_by,
     g_user_id last_updated_by,
     g_login_id last_update_login,
     g_program_id PROGRAM_ID,
     g_program_login_id PROGRAM_LOGIN_ID,
     g_program_application_id PROGRAM_APPLICATION_ID,
     g_request_id REQUEST_ID
   FROM
     (
        select /*+ ordered use_nl(mtl_dtl) full(gtv)*/
          job_id,
          job_type,
          jobs.assembly_item_id,
          jobs.organization_id,
          jobs.actual_qty_completed,
          jobs.uom_code,
          jobs.completion_date closed_date,
          -sum(Decode(jobs.line_type,1,decode(jobs.line_id, mtl_dtl.material_detail_id,
         					-txn_base_value,0),0)) standard_Value_b,
          -sum(Decode(jobs.line_type,-1,txn_base_value*mtl_dtl.cost_alloc,
                                     2,txn_base_value*mtl_dtl.cost_alloc, 0)) actual_Value_b
        from
          (
            select /*+ ordered use_nl(mtl_dtl) index(mtl_dtl)*/
              jobs.Job_id,
              jobs.job_type,
              mtl_dtl.material_detail_id line_id,
              jobs.assembly_item_id,
              to_char(mtl_dtl.inventory_item_id) item_resource_id,
              jobs.actual_qty_completed,
              jobs.completion_date,
              jobs.uom_code,
              mtl_dtl.Line_type,
              jobs.organization_id
            from
              OPI_DBI_JOBS_STG jobs,
              GME_MATERIAL_DETAILS mtl_dtl
            where
              jobs.job_id = mtl_dtl.batch_id and
              jobs.organization_id = mtl_dtl.organization_id and
              mtl_dtl.line_type in (-1,1,2) and
              jobs.source = 2 and
              jobs.status in ('Closed') and
              jobs.line_type = 1
            union all
            select /*+ leading(jobs)*/
              jobs.job_id,
              jobs.job_type,
              gbsr.batchstep_resource_id line_id,
              jobs.assembly_item_id,
              gbsr.resources item_resource_id,
              jobs.actual_qty_completed,
              jobs.completion_date,
              jobs.uom_code,
              -1 Line_type,
              jobs.Organization_id
            from
              OPI_DBI_JOBS_STG jobs,
              GME_BATCH_STEP_RESOURCES gbsr
            where
              jobs.job_id = gbsr.batch_id and
              jobs.source = 2 and
              jobs.status in ('Closed') and
              jobs.line_type = 1
        ) Jobs ,
          GMF_TRANSACTION_VALUATION GTV,
          OPI_DBI_ORG_LE_TEMP tmp,
          GME_MATERIAL_DETAILS mtl_dtl
        where
          jobs.organization_id = GTV.organization_id and
          jobs.job_id = GTV.doc_id and
          (jobs.item_resource_id = to_char(GTV.inventory_item_id)
           or jobs.item_resource_id = GTV.resources) and
          GTV.line_id = jobs.line_id and
          GTV.journal_line_type in ('INV', 'RCA') and
          GTV.event_class_code in ('BATCH_MATERIAL', 'BATCH_RESOURCE') and
          GTV.transaction_source = 'PRODUCTION' and
          jobs.job_id = mtl_dtl.batch_id and
          jobs.organization_id = mtl_dtl.organization_id and
          jobs.assembly_item_id = mtl_dtl.inventory_item_id and
          mtl_dtl.line_type = 1 and
          GTV.ledger_id = tmp.ledger_id and
          GTV.legal_entity_id = tmp.legal_entity_id and
	  GTV.valuation_cost_type_id = tmp.valuation_cost_type_id and
          GTV.organization_id = tmp. organization_id
        Group by
          jobs.job_id,
          jobs.job_type,
          jobs.organization_id,
          jobs.assembly_item_id,
          jobs.actual_qty_completed,
          jobs.uom_code,
          jobs.completion_date) var,
     OPI_DBI_JOBS_F   rates
   where
     var.organization_id = rates.organization_id and
     var.job_id = rates.job_id and
     var.job_type = rates.job_type and
     var.assembly_item_id = rates.assembly_item_id and
     rates.line_type = 1
    ) v
    ON (    F.Organization_Id = V.Organization_Id
        AND F.Job_Id = V.Job_Id
        AND F.Job_Type = V.Job_Type
        AND F.Assembly_Item_id = V.Assembly_Item_id)
    WHEN MATCHED THEN
    UPDATE SET
         F.Closed_date = V.Closed_date
        ,F.Standard_Value_B = V.Standard_Value_B
        ,F.Actual_Value_B = V.Actual_Value_B
        ,F.Actual_Qty_Completed = V.Actual_Qty_Completed
        ,F.Conversion_rate = V.Conversion_rate
        ,F.Sec_Conversion_rate = V.Sec_Conversion_rate
        ,F.Last_Update_Date =  V.Last_Update_Date
        ,F.Last_Updated_By = V.Last_Updated_By
        ,F.Last_Update_Login = V.Last_Update_Login
    WHEN NOT MATCHED THEN
    INSERT (
        Organization_Id,
        Job_Id,
        Job_Type,
        Assembly_Item_id,
        Closed_date,
        Standard_Value_B,
        Actual_Value_B,
        Actual_Qty_Completed,
        UOM_Code,
        Conversion_rate,
        Sec_Conversion_rate,
        Source,
        Creation_Date,
        Last_Update_Date,
        Created_By,
        Last_Updated_By,
        Last_Update_Login,
        PROGRAM_ID,
	PROGRAM_LOGIN_ID,
	PROGRAM_APPLICATION_ID,
	REQUEST_ID)
    VALUES (
        V.Organization_Id,
        V.Job_Id,
        V.Job_Type,
        V.Assembly_Item_id,
        V.Closed_date,
        V.Standard_Value_B,
        V.Actual_Value_B,
        V.Actual_Qty_Completed,
        V.UOM_Code,
        V.Conversion_rate,
        V.Sec_Conversion_rate,
        V.Source,
        V.Creation_Date,
        V.Last_Update_Date,
        V.Created_By,
        V.Last_Updated_By,
        V.Last_Update_Login,
        V.PROGRAM_ID,
	V.PROGRAM_LOGIN_ID,
	V.PROGRAM_APPLICATION_ID,
	V.REQUEST_ID);


    l_row_count2 := sql%rowcount;

    g_row_count := g_row_count + l_row_count1 + l_row_count2;

    commit;

    BIS_COLLECTION_UTILITIES.PUT_LINE('Finished OPI Manufacturing Cost Variance load into Fact Table: '|| l_row_count1 || ' rows inserted');
    BIS_COLLECTION_UTILITIES.PUT_LINE('Finished OPM Manufacturing Cost Variance load into Fact Table: '|| l_row_count2 || ' rows inserted');

    /* Truncating Jobs Staging Table */
    l_stmt_num := 30;
    IF fnd_installation.get_app_info( 'OPI', l_status, l_industry, l_opi_schema) THEN
    --{
    	execute immediate 'truncate table ' || l_opi_schema || '.OPI_DBI_JOBS_STG';
    --}
    END IF;

    BIS_COLLECTION_UTILITIES.PUT_LINE('Exiting Procedure '|| l_proc_name);

END GET_MFG_CST_VAR_INCR;

/*

Procedure extracts CUV for OPM and ODM. No Pre R12 OPM data is collected.

*/


PROCEDURE GET_CURR_UNREC_VAR (errbuf in out NOCOPY varchar2,
                              retcode in out NOCOPY varchar2)
IS
    l_stmt_num NUMBER;
    l_row_count NUMBER;
    l_err_num NUMBER;
    l_err_msg VARCHAR2(255);
    l_opi_schema      VARCHAR2(30);
    l_status          VARCHAR2(30);
    l_industry        VARCHAR2(30);
    l_list dbms_sql.varchar2_table;
    l_proc_name VARCHAR2(255);

BEGIN

    l_proc_name := 'OPI_DBI_MTL_VARIANCE_PKG.GET_CURR_UNREC_VAR';

    BIS_COLLECTION_UTILITIES.PUT_LINE('Entering Procedure '|| l_proc_name);

    -- WHO column variable initialization
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

        IF BIS_COLLECTION_UTILITIES.SETUP( 'OPI_DBI_CURR_UNREC_VAR_F' ) = false then
            RAISE_APPLICATION_ERROR(-20000, errbuf);
        End if;

        /* Truncate Current Unrecognized Variances Fact Table */
        l_stmt_num := 10;
        IF fnd_installation.get_app_info( 'OPI', l_status, l_industry, l_opi_schema) THEN
            execute immediate 'truncate table ' || l_opi_schema || '.OPI_DBI_CURR_UNREC_VAR_F';
            execute immediate 'truncate table ' || l_opi_schema || '.OPI_DBI_CUV_CONV_RATES';
        END IF;

        l_stmt_num := 20;
        IF (Get_Conversion_Rate (errbuf, retcode) = -1) THEN
            BIS_COLLECTION_UTILITIES.put_line('Missing currency rate.');
            BIS_COLLECTION_UTILITIES.put_line('Please run this concurrent program again after fixing the missing currency rates.');
            retcode := g_error;
            return;
        END IF;

        /* Calling to populate temp table for mutli ledger/valuation_cost_type in gtv table */
	l_stmt_num := 25;
	BIS_COLLECTION_UTILITIES.PUT_LINE('Calling to populate temp table for mutli ledger/valuation_cost_type in gtv table');
    	OPI_DBI_BOUNDS_PKG.load_opm_org_ledger_data;


        /* Insert OPI Current Unrecognized Variances */
        l_stmt_num := 30;
        INSERT /*+ append parallel(OPI_DBI_CURR_UNREC_VAR_F) */
        INTO OPI_DBI_CURR_UNREC_VAR_F (
            organization_id
            ,inventory_item_id
            ,item_org_id
            ,inv_category_id
            ,standard_value_b
            ,standard_value_g
            ,standard_value_sg
            ,actual_value_b
            ,actual_value_g
            ,actual_value_sg
            ,actual_prd_qty
            ,uom_code
            ,source
            ,creation_date
            ,last_update_date
            ,created_by
            ,last_updated_by
            ,last_update_login
            ,job_id
            ,job_type
            ,PROGRAM_ID
	    ,PROGRAM_LOGIN_ID
	    ,PROGRAM_APPLICATION_ID
	    ,REQUEST_ID
        )
        SELECT /*+ parallel(cat) parallel(ACT_STD) parallel(MSI) parallel(conv) full(cat) full(msi)*/
		act_std.organization_id organization_id,
	        act_std.inventory_item_id inventory_item_id,
	        act_std.inventory_item_id||'-'||act_std.organization_id  item_org_id,
	        nvl(cat.inv_category_id,-1) inv_category_id,
	        act_std.std_val_b standard_value_b,
	        act_std.std_val_b * conv.conversion_rate standard_value_g,
	        act_std.std_val_b * conv.sec_conversion_rate standard_value_sg,
	        act_std.act_val_b actual_value_b,
	        act_std.act_val_b * conv.conversion_rate actual_value_g,
	        act_std.act_val_b * conv.sec_conversion_rate actual_value_sg,
	        act_std.act_prd_qty act_prd_qty,
	        msi.primary_uom_code uom_code,
	        1 source,
	        g_sysdate creation_date,
	        g_sysdate last_update_date,
	        g_user_id created_by,
	        g_user_id last_updated_by,
	        g_login_id last_update_login,
	        act_std.job_id,
	        act_std.job_type,
	        g_program_id PROGRAM_ID,
		g_program_login_id PROGRAM_LOGIN_ID,
		g_program_application_id PROGRAM_APPLICATION_ID,
		g_request_id REQUEST_ID
	 FROM
	 	(
	        SELECT /*+ no_merge parallel(x) */
	        	organization_id organization_id,
	                inventory_item_id inventory_item_id,
	                to_number(job_id) job_id,
	                to_number(job_type) job_type,
	                sum (act_cost_b) act_val_b,
	                sum (std_val_b) std_val_b,
	                sum (actual_qty_completed) act_prd_qty
	        FROM
	        	(
	                SELECT /*+ no_merge parallel(AC) parallel(Std_val_and_qty) */
	                    std_val_and_qty.organization_id organization_id,
	                    std_val_and_qty.inventory_item_id inventory_item_id,
	                    std_val_and_qty.job_id job_id,
	                    std_val_and_qty.job_type,
	                    ac.act_cost_b act_cost_b,
	                    std_val_and_qty.std_val_b std_val_b,
	                    actual_qty_completed
	                  FROM
	                    (
	                    SELECT /*+ no_merge parallel(not_cl_jobs) parallel(icosts) full(icosts) use_hash(icosts) use_hash(not_cl_jobs)*/
	                        not_cl_jobs.organization_id,
	                        not_cl_jobs.inventory_item_id,
	                        not_cl_jobs.job_idj,
	                        not_cl_jobs.job_id,
				not_cl_jobs.job_type,
	                        not_cl_jobs.status_type,
	                        CASE WHEN status_type IN (5, 4, 7) THEN
	                                actual_qty_completed * nvl(icosts.item_cost, 0)  -- Use complete qty when Complete, Complete-No charges and Cancelled
	                            ELSE
	                                greatest(start_qty, actual_qty_completed) *
	                                nvl(icosts.item_cost, 0)
	                        END std_val_b,
	                        actual_qty_completed
	                      FROM
	                        (
	                        SELECT /*+ no_merge  parallel(WDJ) parallel(WE) */
	                            wdj.organization_id organization_id,
	                            wdj.primary_item_id inventory_item_id,
	                            to_char (wdj.wip_entity_id) job_idj,
	                            to_char (wdj.wip_entity_id) job_id,
				    decode(we.entity_type,5,5,1) job_type,
	                            wdj.status_type status_type,
	                            wdj.start_quantity start_qty,
	                            wdj.quantity_completed actual_qty_completed
	                          FROM
	                            wip_discrete_jobs wdj,
	                            wip_entities we
	                          WHERE wdj.Status_Type <> 12  -- Not closed
	                            AND we.entity_type IN (1,3, 5)
	                            AND wdj.job_type = 1  -- Standard Jobs only
	                            AND wdj.wip_entity_id = we.wip_entity_id
	                            AND wdj.organization_id = we.organization_id
	                            AND wdj.date_released >= g_global_start_date
	                        UNION
	                        SELECT /*+ no_merge use_hash(WRS WE) parallel(WRS)
	                                   parallel(WE) */
	                            wrs.organization_id organization_id,
	                            we.primary_item_id inventory_item_id,
	                            wrs.wip_entity_id||'-'||wrs.repetitive_schedule_id
	                                job_idj,
	                            to_char(wrs.repetitive_schedule_id) job_id,
				    2 job_type,
	                            wrs.status_type status_type,
	                            wrs.daily_production_rate *
	                                wrs.processing_work_days start_qty,
	                            wrs.quantity_completed actual_qty_completed
	                          FROM
	                            wip_repetitive_schedules wrs,
	                            wip_entities we
	                          WHERE
	                                wrs.status_type <> 12  -- not closed
	                            AND we.entity_type = 2
	                            AND we.wip_entity_id = wrs.wip_entity_id
	                            AND we.organization_id = wrs.organization_id
	                            AND wrs.date_released >= g_global_start_date
	                        ) not_cl_jobs, -- Note: Flow schedules can only be overcharged when the schedule is Closed, hence no need to extract them here.
	                        cst_item_costs icosts
	                      WHERE
	                            not_cl_jobs.organization_id =
	                                    icosts.organization_id
	                        AND not_cl_jobs.inventory_item_id =
	                                icosts.inventory_item_id
	                        AND icosts.cost_type_id in (1,2,5,6)
	                    ) std_val_and_qty,  -- Standard Values and Start and Completed Quantities
	                    (
	                    SELECT /*+ no_merge parallel(WPB) */
	                        wpb.organization_id organization_id,
	                        wpb.wip_entity_id || decode(wpb.repetitive_schedule_id, null, null, '-'||wpb.repetitive_schedule_id) job_id,
				--decode(wpb.repetitive_schedule_id,null,1,2) job_type,
	                        sum( tl_resource_in + tl_overhead_in +
	                        tl_outside_processing_in + pl_material_in +
	                        pl_material_overhead_in + pl_resource_in +
	                        pl_overhead_in + pl_outside_processing_in) act_cost_b
	                      FROM
	                        wip_period_balances wpb
	                      GROUP BY
	                        wpb.organization_id,
	                        wpb.wip_entity_id,
				--decode(wpb.repetitive_schedule_id,null,1,2),
	                        wpb.repetitive_schedule_id
	                    ) AC  -- Actual Cost
	                  WHERE
	                        std_val_and_qty.organization_id = ac.organization_id
	                    AND std_val_and_qty.job_idj = ac.job_id
			    --AND std_val_and_qty.job_type = ac.job_type
	                    AND ac.act_cost_b > std_val_and_qty.std_val_b  -- filter cost charged greater than Std Cost
	                ) x
	              GROUP BY
	                organization_id,
	                inventory_item_id,
			to_number(job_id),
			to_number(job_type)
	            ) act_std,
	            mtl_system_items_b msi,
	            eni_oltp_item_star cat,
	            opi_dbi_cuv_conv_rates conv
	          WHERE
	                act_std.organization_id = msi.organization_id
	            AND act_std.inventory_item_id = msi.inventory_item_id
	            AND act_std.organization_id = cat.organization_id
	            AND act_std.inventory_item_id = cat.inventory_item_id
            AND act_std.organization_id = conv.organization_id
        /* OPM Big Insert Select has to union with OPIs here (limitation of Insert append) */
        UNION ALL
        select /*+ ordered full(cat) */
		var.organization_id,
		var.assembly_item_id,
		var.assembly_item_id||'-'||var.organization_id,
		cat.inv_category_id,
		standard_value_b,
		standard_value_b*conversion_rate standard_value_g,
		standard_value_b*sec_conversion_rate standard_value_sg,
		actual_value_b,
		actual_value_b*conversion_rate standard_value_g,
		actual_value_b*sec_conversion_rate standard_value_sg,
		var.actual_qty_completed,
		var.uom_code,
		2 source,
            	g_sysdate creation_date,
            	g_sysdate last_update_date,
            	g_user_id created_by,
            	g_user_id last_updated_by,
            	g_login_id last_update_login,
            	var.job_id,
		var.job_type,
	        g_program_id PROGRAM_ID,
		g_program_login_id PROGRAM_LOGIN_ID,
		g_program_application_id PROGRAM_APPLICATION_ID,
		g_request_id REQUEST_ID
        from
		OPI_DBI_CUV_CONV_RATES rates,
		(select /*+ full(gtv) use_hash(mtl_dtl) full(mtl_dtl) parallel(mtl_dtl) parallel(gtv) use_hash(jobs)*/
			jobs.organization_id,
			Jobs.assembly_item_id,
			jobs.job_id,
			jobs.job_type,
			jobs.status,
			OPI_DBI_JOBS_PKG.GET_OPM_ITEM_COST(
				jobs.organization_id,
				jobs.assembly_item_id,
				sysdate)*
				decode(jobs.status,'Complete',jobs.actual_qty_completed,
				greatest(Jobs.planned_qty,jobs.actual_qty_completed)) standard_value_b,
			Sum(Decode(jobs.line_type,-1,txn_base_value*mtl_dtl.cost_alloc,
		   		                  2,txn_base_value*mtl_dtl.cost_alloc, 0)) Actual_Value_b,
			jobs.planned_qty planned_qty,
			jobs.actual_qty_completed,
			jobs.uom_code
		from
			GMF_TRANSACTION_VALUATION GTV,
			OPI_DBI_ORG_LE_TEMP tmp,
			GME_MATERIAL_DETAILS MTL_DTL,
			(
			 select    /*+ no_merge ordered full(jobs) use_hash(mtl_dtl) full(mtl_dtl) */
			 	jobs.Job_id,
			  	jobs.assembly_item_id,
			  	jobs.job_type,
				jobs.status,
				jobs.uom_code,
			  	to_char(mtl_dtl.Inventory_item_id) item_resource_id,
				mtl_dtl.material_detail_id line_id,
			  	jobs.start_quantity planned_qty,
			  	jobs.actual_qty_completed,
		  		mtl_dtl.line_type line_type,
		  		jobs.Organization_id
		  	from
		  		OPI_DBI_JOBS_F jobs,
		  		GME_MATERIAL_DETAILS mtl_dtl
		  	where
	  	  	        jobs.source = 2 and
	  	  	        jobs.line_type = 1 and
		  		jobs.job_id = mtl_dtl.batch_id and
	  			mtl_dtl.line_type in (-1,2) and
	  			jobs.status in ('Released', 'WIP', 'Complete')
	  		union all
	  		select       /*+ no_merge ordered full(jobs) use_hash(gbsr) full(gbsr) */
	  			job_id,
	  			jobs.assembly_item_id,
	  			jobs.job_type,
				jobs.status,
    				jobs.uom_code,
	  			gbsr.resources item_resource_id,
				gbsr.batchstep_resource_id line_id,
	  			jobs.start_quantity planned_qty,
	  			jobs.actual_qty_completed,
			  	-1 line_type,
			  	jobs.Organization_id
			  from
			  	OPI_DBI_JOBS_F jobs,
			  	GME_BATCH_STEP_RESOURCES gbsr
			  where
			  	jobs.source = 2 and
			  	jobs.line_type = 1 and
			  	jobs.job_id = gbsr.batch_id and
			 	jobs.status in ('Released', 'WIP', 'Complete')
			 ) Jobs
		where
			 jobs.organization_id = GTV.organization_id and
			 jobs.job_id = GTV.doc_id and
		         (jobs.item_resource_id = to_char(GTV.inventory_item_id)
		           or jobs.item_resource_id = GTV.resources) and
		         GTV.line_id = jobs.line_id and
			 GTV.journal_line_type in ('WIP') and
			 GTV.event_class_code in ('BATCH_MATERIAL','BATCH_RESOURCE') and
			 jobs.job_id = mtl_dtl.batch_id and
		  	 jobs.organization_id = mtl_dtl.organization_id and
		 	 jobs.assembly_item_id = mtl_dtl.inventory_item_id and
		 	 mtl_dtl.line_type = 1 and
          		 GTV.ledger_id = tmp.ledger_id and
          		 GTV.legal_entity_id = tmp.legal_entity_id and
	  		 GTV.valuation_cost_type_id = tmp.valuation_cost_type_id and
          		 GTV.organization_id = tmp. organization_id
		Group by
		       	jobs.organization_id,
			jobs.job_id,
			jobs.job_type,
			jobs.assembly_item_id,
			jobs.status,
			jobs.uom_code,
			jobs.planned_qty,
			jobs.actual_qty_completed
		)var
                , eni_oltp_item_Star cat
	where
		var.organization_id = rates.organization_id and
		var.assembly_item_id = cat.inventory_item_id and
		var.organization_id = cat.organization_id and
		var.actual_value_b > var.standard_value_b;

   l_row_count := sql%rowcount;

   commit;

   BIS_COLLECTION_UTILITIES.PUT_LINE('Finished OPI and OPM Current Unrecognized Variance into Fact Table: '|| l_row_count || ' rows inserted');

   BIS_COLLECTION_UTILITIES.WRAPUP(
               p_status => TRUE,
               p_count => l_row_count,
               p_message => 'Successfully loaded Current Unrecognized Variance table at ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')
   );

   BIS_COLLECTION_UTILITIES.PUT_LINE('Exiting Procedure '|| l_proc_name);

 ELSE
     retcode := g_error;
     BIS_COLLECTION_UTILITIES.PUT_LINE('Global Parameters are not setup.');
     BIS_COLLECTION_UTILITIES.PUT_LINE('Please check that the profile option BIS_PRIMARY_CURRENCY_CODE is setup.');
     BIS_COLLECTION_UTILITIES.PUT_LINE('Exiting Procedure '|| l_proc_name);

 END IF;


EXCEPTION
 WHEN OTHERS THEN
   rollback;

   l_err_num := SQLCODE;
   l_err_msg := 'OPI_DBI_MTL_VARIANCE_PKG.GET_CURR_UNREC_VAR ('
                    || to_char(l_stmt_num)
                    || '): '
                    || substr(SQLERRM, 1,200);
   BIS_COLLECTION_UTILITIES.PUT_LINE('OPI_DBI_MTL_VARIANCE_PKG.GET_CURR_UNREC_VAR - Error at statement ('
                    || to_char(l_stmt_num)
                    || ')');
   BIS_COLLECTION_UTILITIES.PUT_LINE('Error Number: ' ||  to_char(l_err_num));
   BIS_COLLECTION_UTILITIES.PUT_LINE('Error Message: ' || l_err_msg);
   BIS_COLLECTION_UTILITIES.WRAPUP( FALSE, l_row_count, 'EXCEPTION '|| l_err_num||' : '||l_err_msg );

   retcode := SQLCODE;
   errbuf := SQLERRM;
   RAISE_APPLICATION_ERROR(-20000, errbuf);

END GET_CURR_UNREC_VAR;



PROCEDURE Refresh_Base_MV(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2, p_method in varchar2 DEFAULT '?')
IS
 l_stmt_num NUMBER;
 l_err_num NUMBER;
 l_err_msg VARCHAR2(255);
BEGIN

 l_stmt_num := 10;
 DBMS_MVIEW.REFRESH(
                list => 'OPI_MTL_VAR_MV_F',
                method => p_method,
                parallelism => 0);


 BIS_COLLECTION_UTILITIES.PUT_LINE('Refresh of Base Materialized View finished ...');


EXCEPTION
 WHEN OTHERS THEN

   l_err_num := SQLCODE;
   l_err_msg := 'OPI_DBI_MTL_VARIANCE_PKG.Refresh_Base_MV ('
                    || to_char(l_stmt_num)
                    || '): '
                    || substr(SQLERRM, 1,200);

   BIS_COLLECTION_UTILITIES.PUT_LINE('OPI_DBI_MTL_VARIANCE_PKG.Refresh_Base_MV - Error at statement ('
                    || to_char(l_stmt_num)
                    || ')');

   BIS_COLLECTION_UTILITIES.PUT_LINE('Error Number: ' ||  to_char(l_err_num));
   BIS_COLLECTION_UTILITIES.PUT_LINE('Error Message: ' || l_err_msg);

   RAISE_APPLICATION_ERROR(-20000, errbuf);

END Refresh_Base_MV;

PROCEDURE REFRESH_MV(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
 l_stmt_num NUMBER;
 l_err_num NUMBER;
 l_err_msg VARCHAR2(255);
BEGIN

 /*l_stmt_num := 10;*/
 /* Material Details MV Refresh */

 /*dbms_mview.refresh('OPI_MTL_VAR_SUM_MV',
                    '?',
                    '',        -- ROLLBACK_SEG
                    TRUE,      -- PUSH_DEFERRED_RPC
                    FALSE,     -- REFRESH_AFTER_ERRORS
                    0,         -- PURGE_OPTION
                    1,  -- PARALLELISM
                    0,         -- HEAP_SIZE
                    FALSE      -- ATOMIC_REFRESH
                   );

 BIS_COLLECTION_UTILITIES.PUT_LINE('Material Details MV Refresh finished ...');*/

 l_stmt_num := 20;
 /* MFG Cost Variance MV Refresh */

 dbms_mview.refresh('OPI_MFG_VAR_SUM_MV',
                    '?',
                    '',        -- ROLLBACK_SEG
                    TRUE,      -- PUSH_DEFERRED_RPC
                    FALSE,     -- REFRESH_AFTER_ERRORS
                    0,         -- PURGE_OPTION
                    1,  -- PARALLELISM
                    0,         -- HEAP_SIZE
                    FALSE      -- ATOMIC_REFRESH
                   );

 BIS_COLLECTION_UTILITIES.PUT_LINE('Manufacturing Cost Variance Refresh finished ...');

EXCEPTION
 WHEN OTHERS THEN

   l_err_num := SQLCODE;
   l_err_msg := 'OPI_DBI_MTL_VARIANCE_PKG.REFRESH_MV ('
                    || to_char(l_stmt_num)
                    || '): '
                    || substr(SQLERRM, 1,200);

   BIS_COLLECTION_UTILITIES.PUT_LINE('OPI_DBI_MTL_VARIANCE_PKG.REFRESH_MV - Error at statement ('
                    || to_char(l_stmt_num)
                    || ')');

   BIS_COLLECTION_UTILITIES.PUT_LINE('Error Number: ' ||  to_char(l_err_num));
   BIS_COLLECTION_UTILITIES.PUT_LINE('Error Message: ' || l_err_msg);

   RAISE_APPLICATION_ERROR(-20000, errbuf);
   /*please note that this api will commit!!*/

END REFRESH_MV;

/*
   Procedure checks for required setups.

   Parameters:
     retcode - 0 on successful completion, -1 on error and 1 for warning.
     errbuf - empty on successful completion, message on error or warning
*/

PROCEDURE CHECK_OPI_MFG_CST_VAR_SETUP(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
 l_stmt_num NUMBER;
 l_row_count NUMBER;
 l_err_num NUMBER;
 l_err_msg VARCHAR2(255);
 l_proc_name VARCHAR2(255);
 BEGIN

 	l_proc_name := 'OPI_DBI_MTL_VARIANCE_PKG.CHECK_OPI_MFG_CST_VAR_SETUP';

 	BIS_COLLECTION_UTILITIES.PUT_LINE('Entering Procedure '|| l_proc_name);

 	/* calling setup for all fact tables */
 	l_stmt_num := 10;

 	IF BIS_COLLECTION_UTILITIES.SETUP('OPI_DBI_MFG_CST_VAR_F') = false then
	        RAISE_APPLICATION_ERROR(-20000, errbuf);
        END IF;

        /* get global start date */
 	l_stmt_num := 20;
 	g_global_start_date := trunc (bis_common_parameters.get_global_start_date);
	IF (g_global_start_date IS NULL) THEN
	    BIS_COLLECTION_UTILITIES.PUT_LINE ('The global Start date Not Set.');

	    RAISE_APPLICATION_ERROR(-20000, errbuf);
        END IF;

        l_stmt_num := 30;
    	-- Global currency codes -- already checked if primary is set up
    	g_global_currency_code := bis_common_parameters.get_currency_code;
    	g_secondary_currency_code := bis_common_parameters.get_secondary_currency_code;

    	-- Global rate types -- already checked if primary is set up
    	g_global_rate_type := bis_common_parameters.get_rate_type;
    	g_secondary_rate_type := bis_common_parameters.get_secondary_rate_type;

    	-- check that either both the secondary rate type and secondary
    	-- rate are null, or that neither are null.
    	IF ((g_secondary_currency_code IS NULL AND
             g_secondary_rate_type IS NOT NULL)
            OR
            (g_secondary_currency_code IS NOT NULL AND
             g_secondary_rate_type IS NULL)
           ) THEN
        	BIS_COLLECTION_UTILITIES.PUT_LINE ('The global secondary currency code setup is incorrect. The secondary currency code cannot be null when the secondary rate type is defined and vice versa.');

                RAISE_APPLICATION_ERROR(-20000, errbuf);

    	END IF;

    	l_stmt_num := 40;
	-- get R12 upgrade date
    	OPI_DBI_RPT_UTIL_PKG.get_inv_convergence_date(g_r12_migration_date);

    	BIS_COLLECTION_UTILITIES.PUT_LINE('Exiting Procedure '|| l_proc_name);

EXCEPTION

    WHEN OTHERS THEN
    rollback;
    l_err_num := SQLCODE;
    l_err_msg := 'OPI_DBI_MTL_VARIANCE_PKG.CHECK_OPI_MFG_CST_VAR_SETUP ('
                        || to_char(l_stmt_num)
                        || '): '
                        || substr(SQLERRM, 1,200);
    BIS_COLLECTION_UTILITIES.PUT_LINE('OPI_DBI_MTL_VARIANCE_PKG.CHECK_OPI_MFG_CST_VAR_SETUP - Error at statement ('
                        || to_char(l_stmt_num)
                        || ')');
    BIS_COLLECTION_UTILITIES.PUT_LINE('Error Number: ' ||  to_char(l_err_num));
    BIS_COLLECTION_UTILITIES.PUT_LINE('Error Message: ' || l_err_msg);
    BIS_COLLECTION_UTILITIES.WRAPUP( FALSE, l_row_count, 'EXCEPTION '|| l_err_num||' : '||l_err_msg );

    retcode := SQLCODE;
    errbuf := SQLERRM;
    RAISE_APPLICATION_ERROR(-20000, errbuf);

 END CHECK_OPI_MFG_CST_VAR_SETUP;

END OPI_DBI_MTL_VARIANCE_PKG;

/
