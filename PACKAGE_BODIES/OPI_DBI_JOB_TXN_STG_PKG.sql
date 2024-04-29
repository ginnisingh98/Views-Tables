--------------------------------------------------------
--  DDL for Package Body OPI_DBI_JOB_TXN_STG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_JOB_TXN_STG_PKG" AS
/*$Header: OPIDJOBTRB.pls 120.34 2006/09/20 23:58:22 asparama noship $*/

/* Non planned items have an mrp_planning_code of 6 */
NON_PLANNED_ITEM CONSTANT NUMBER := 6;


s_user_id    NUMBER := nvl(fnd_global.user_id, -1);
s_login_id   NUMBER := nvl(fnd_global.login_id, -1);
s_global_start_date DATE := NULL;
s_r12_migration_date DATE := NULL;
s_sysdate DATE := NULL;
s_program_id NUMBER:= nvl (fnd_global.conc_program_id, -1);
s_program_login_id NUMBER := nvl (fnd_global.conc_login_id, -1);
s_program_application_id NUMBER := nvl (fnd_global.prog_appl_id,  -1);
s_request_id NUMBER := nvl (fnd_global.conc_request_id, -1);

-- currency types
g_global_rate_type VARCHAR2(15);
g_global_currency_code VARCHAR2(10);
g_secondary_rate_type VARCHAR2(15);
g_secondary_currency_code VARCHAR2(10);

-- Start date of Euro currency
g_euro_start_date CONSTANT DATE := to_date('01/01/1999','DD/MM/YYYY');

g_warning CONSTANT NUMBER(1) := 1;
g_error CONSTANT NUMBER(1) := -1;
g_ok CONSTANT NUMBER(1) := 0;
g_refresh_bmv BOOLEAN := TRUE;

/*  Marker for secondary conv. rate if the primary and secondary curr codes
    and rate types are identical. Can't be -1, -2, -3 since the FII APIs
    return those values. */
C_PRI_SEC_CURR_SAME_MARKER CONSTANT NUMBER := -9999;

-- GL API returns -3 if EURO rate missing on 01-JAN-1999
C_EURO_MISSING_AT_START CONSTANT NUMBER := -3;


/*
    Populate Conversion rates for transaction dates.

    Parameters:
       retcode - 0 on successful completion, -1 on error and 1 for warning.
       errbuf - empty on successful completion, message on error or warning
       returns retcode.
*/

FUNCTION GET_OPI_JOB_TXN_CRATES (errbuf  IN OUT NOCOPY VARCHAR2,retcode IN OUT NOCOPY VARCHAR2)
    RETURN NUMBER
IS

	CURSOR invalid_rates_exist_csr IS
	        SELECT 1
 	        FROM opi_dbi_muv_conv_rates
                WHERE (nvl (conversion_rate, -999) < 0
	               OR nvl (sec_conversion_rate, 999) < 0)
                       AND rownum < 2;

        invalid_rates_exist_rec invalid_rates_exist_csr%ROWTYPE;

        CURSOR get_missing_rates_c (p_pri_sec_curr_same NUMBER) IS
		SELECT DISTINCT
	            report_order,
	            curr_code,
	            rate_type,
	            transaction_date,
	            func_currency_code
	        FROM (
	           SELECT DISTINCT
	                    g_global_currency_code curr_code,
	                    g_global_rate_type rate_type,
	                    1 report_order, -- ordering global currency first
	                    mp.organization_code,
	                    decode (conv.conversion_rate,
	                            C_EURO_MISSING_AT_START, g_euro_start_date,
	                            conv.transaction_date) transaction_date,
	                    conv.f_currency_code func_currency_code
	              FROM opi_dbi_muv_conv_rates conv,
	                   mtl_parameters mp,
	                  (SELECT
	                   DISTINCT organization_id,
	                            trunc (transaction_date) transaction_date
	                     FROM OPI_DBI_JOBS_TXN_STG) to_conv
	              WHERE nvl (conv.conversion_rate, -999) < 0 -- null is not fine
	                AND mp.organization_id = to_conv.organization_id
	                AND conv.transaction_date (+) = to_conv.transaction_date
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
	                            conv.transaction_date) transaction_date,
	                    conv.f_currency_code func_currency_code
	              FROM opi_dbi_muv_conv_rates conv,
	                   mtl_parameters mp,
	                  (SELECT
	                   DISTINCT organization_id,
	                            trunc (transaction_date) transaction_date
	                     FROM OPI_DBI_JOBS_TXN_STG) to_conv
	              WHERE nvl (conv.sec_conversion_rate, 999) < 0 -- null is fine
	                AND mp.organization_id = to_conv.organization_id
	                AND conv.transaction_date (+) = to_conv.transaction_date
	                AND conv.organization_id (+) = to_conv.organization_id)
	          ORDER BY
	                report_order ASC,
	                transaction_date,
                	func_currency_code;

    l_stmt_num NUMBER;
    l_status VARCHAR2(30);
    l_industry VARCHAR2(30);
    l_opi_schema VARCHAR2(30);
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

    l_stmt_num := 20;
    -- check if the primary and secondary currencies and rate types are
    -- identical.
    IF (g_global_currency_code = nvl (g_secondary_currency_code, '---') AND
        g_global_rate_type = nvl (g_secondary_rate_type, '---') ) THEN
    --{
        l_pri_sec_curr_same := 1;
    --}
    END IF;


    l_stmt_num := 30;
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
   	REQUEST_ID
        )
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
        s_sysdate,
        s_sysdate,
        s_user_id,
        s_user_id,
        s_login_id,
        s_program_id,
	s_program_login_id,
	s_program_application_id,
	s_request_id
      FROM
        (SELECT
         DISTINCT organization_id, trunc (transaction_date) transaction_date
         FROM OPI_DBI_JOBS_TXN_STG
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
    --{

        UPDATE /*+ parallel (opi_dbi_muv_conv_rates) */
        opi_dbi_muv_conv_rates
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
    	FOR get_missing_rates_rec IN get_missing_rates_c (l_pri_sec_curr_same)
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

   return retcode;

EXCEPTION
    WHEN OTHERS THEN
        rollback;
        i_err_num := SQLCODE;
        i_err_msg := 'OPI_DBI_JOB_TXN_STG_PKG.GET_OPI_JOB_TXN_CRATES ('
                    || to_char(l_stmt_num)
                    || '): '
                    || substr(SQLERRM, 1,200);

        BIS_COLLECTION_UTILITIES.put_line('OPI_DBI_JOB_TXN_STG_PKG.GET_OPI_JOB_TXN_CRATES - Error at statement ('
                    || to_char(l_stmt_num)
                    || ')');

        BIS_COLLECTION_UTILITIES.put_line('Error Number: ' ||  to_char(i_err_num));
        BIS_COLLECTION_UTILITIES.put_line('Error Message: ' || i_err_msg);

        retcode := g_error;
        return g_error;

END GET_OPI_JOB_TXN_CRATES;

/* Function to format printing of error messages */

FUNCTION err_mesg (p_mesg IN VARCHAR2,
                   p_proc_name IN VARCHAR2 DEFAULT NULL,
                   p_stmt_id IN NUMBER DEFAULT -1)
    RETURN VARCHAR2
IS

    l_proc_name VARCHAR2 (60);
    l_stmt_id NUMBER;
    l_buffer_size NUMBER;

    -- The variable declaration cannot take C_ERRBUF_SIZE (a defined constant)
    -- as the size of the declaration. I have to put 300 here.
    l_formatted_message VARCHAR2 (300) := NULL;

BEGIN

    l_proc_name  := 'err_mesg';
    l_stmt_id  := 0;
    l_buffer_size := 300;

    l_stmt_id := 10;
    l_formatted_message := substr (('OPI_DBI_JOB_TXN_STG_PKG' || '.' || p_proc_name || ' #' ||
                                   to_char (p_stmt_id) || ': ' || p_mesg),
                                   1, l_buffer_size);

    commit;

    return l_formatted_message;

EXCEPTION

    WHEN OTHERS THEN
        -- the exception happened in the exception reporting function !!
        -- return with ERROR.
        l_formatted_message := substr (('C_PKG_OPI_DBI_JOB_TXN_STG_PKG' || '.' || l_proc_name ||
                                       ' #' ||
                                        to_char (l_stmt_id) || ': ' ||
                                       SQLERRM),
                                       1, l_buffer_size);

        l_formatted_message := 'Error in error reporting.';
        return l_formatted_message;

END err_mesg;

/*
   Refresh MUV base MV

   Parameters:
      retcode - 0 on successful completion, -1 on error and 1 for warning.
      errbuf - empty on successful completion, message on error or warning
      p_method

*/

PROCEDURE REFRESH_BASE_MV(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2, p_method in varchar2 DEFAULT '?')
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
   l_err_msg := 'OPI_DBI_JOB_TXN_STG_PKG.REFRESH_BASE_MV ('
                    || to_char(l_stmt_num)
                    || '): '
                    || substr(SQLERRM, 1,200);

   BIS_COLLECTION_UTILITIES.PUT_LINE('OPI_DBI_JOB_TXN_STG_PKG.REFRESH_BASE_MV - Error at statement ('
                    || to_char(l_stmt_num)
                    || ')');

   BIS_COLLECTION_UTILITIES.PUT_LINE('Error Number: ' ||  to_char(l_err_num));
   BIS_COLLECTION_UTILITIES.PUT_LINE('Error Message: ' || l_err_msg);

   RAISE_APPLICATION_ERROR(-20000, errbuf);

END REFRESH_BASE_MV;


/* Procedure Populates the MMT Staging table, will be used only in the
   initial load.

   Parameters:
   retcode - 0 on successful completion, -1 on error and 1 for warning.
   errbuf - empty on successful completion, message on error or warning

*/

PROCEDURE GET_OPI_JOB_TXN_MMT_STG(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
 l_stmt_num NUMBER;
 l_row_count NUMBER;
 l_err_num NUMBER;
 l_err_msg VARCHAR2(255);
 l_proc_name VARCHAR2(255);
 l_status VARCHAR2(30);
 l_industry VARCHAR2(30);
 l_opi_schema VARCHAR2(30);

BEGIN

    l_proc_name := 'OPI_DBI_JOB_TXN_STG_PKG.GET_OPI_JOB_TXN_MMT_STG';

    BIS_COLLECTION_UTILITIES.PUT_LINE('Entering Procedure '|| l_proc_name);

    BIS_COLLECTION_UTILITIES.PUT_LINE('Extracting MMT Staging Load Start Time - ' ||
                                       TO_CHAR(SYSDATE, 'hh24:mi:ss'));

    /* Insert MMT data into staging */
    l_stmt_num := 20;

INSERT /*+ APPEND parallel(stg) */ INTO OPI_DBI_JOBS_TXN_MMT_STG stg
            (transaction_id
           , organization_id
           , inventory_item_id
           , transaction_date
           , primary_quantity
           , transaction_source_id
           , transaction_source_type_id
           , transaction_action_id
           , reason_id
           , costed_flag
           , process_enabled_flag
           , creation_date
           , last_update_date
           , created_by
           , last_updated_by
           , last_update_login
           , PROGRAM_ID
           , PROGRAM_LOGIN_ID
           , PROGRAM_APPLICATION_ID
           , REQUEST_ID
    )
 /* For Discrete Orgs, collect between transaction id range */
SELECT /*+ ordered use_hash(mtp) swap_join_inputs(mtp) parallel(mmt) full(LOG) full(mmt) parallel(mtp) parallel(log)*/
       MMT.transaction_id
     , MMT.organization_id
     , MMT.inventory_item_id
     , MMT.transaction_date
     , MMT.primary_quantity
     , MMT.transaction_source_id
     , MMT.transaction_source_type_id
     , MMT.transaction_action_id
     , MMT.reason_id
     , MMT.costed_flag
     , 'N'
     , s_sysdate
     , s_sysdate
     , s_user_id
     , s_user_id
     , s_login_id
     , s_program_id
     , s_program_login_id
     , s_program_application_id
     , s_request_id
  FROM OPI_DBI_RUN_LOG_CURR LOG
     , MTL_MATERIAL_TRANSACTIONS MMT
     , MTL_PARAMETERS mtp
 WHERE 1 = 1
   AND MMT.transaction_action_id IN (1, 27, 31, 32, 30) -- Issue, Receipt, Completion, Return,Scrap
   AND MMT.transaction_source_type_id = 5 -- Jobs abd Schedules
   AND MMT.ORGANiZATION_ID = mtp.organization_id
   AND mtp.process_enabled_flag = 'N'
   AND mmt.organization_id = LOG.organization_id
   AND LOG.organization_id IS NOT NULL
   AND LOG.etl_id = 1
   AND LOG.SOURCE = 1
   AND mmt.transaction_id >= LOG.start_txn_id
   AND mmt.transaction_id <= LOG.next_start_txn_id
UNION ALL
    	  /* For process orgs, collect from global start date */
SELECT /*+ ordered use_hash(mtp) swap_join_inputs(mtp) parallel(mmt) full(LOG) full(mmt) parallel(mtp) parallel(log)*/
       MMT.transaction_id
     , MMT.organization_id
     , MMT.inventory_item_id
     , MMT.transaction_date
     , MMT.primary_quantity
     , MMT.transaction_source_id
     , MMT.transaction_source_type_id
     , MMT.transaction_action_id
     , MMT.reason_id
     , MMT.costed_flag
     , 'Y'
     , s_sysdate
     , s_sysdate
     , s_user_id
     , s_user_id
     , s_login_id
     , s_program_id
     , s_program_login_id
     , s_program_application_id
     , s_request_id
  FROM OPI_DBI_RUN_LOG_CURR LOG
     , MTL_MATERIAL_TRANSACTIONS MMT
     , MTL_PARAMETERS mtp
 WHERE 1 = 1
   AND MMT.transaction_action_id IN (1, 27, 31, 32, 30) -- Issue, Receipt, Completion, Return,Scrap
   AND MMT.transaction_source_type_id = 5 -- Jobs abd Schedules
   AND MMT.ORGANiZATION_ID = mtp.organization_id
   AND mtp.process_enabled_flag = 'Y'
   --AND mmt.organization_id = LOG.organization_id
   AND LOG.organization_id IS NULL
   AND LOG.etl_id = 1
   AND LOG.SOURCE = 2
   AND MMT.transaction_date >= LOG.from_bound_date;

    l_row_count := sql%rowcount;

    commit;

    BIS_COLLECTION_UTILITIES.PUT_LINE('Extracting MMT Staging Load End Time - ' ||
                                       TO_CHAR(SYSDATE, 'hh24:mi:ss'));
    BIS_COLLECTION_UTILITIES.PUT_LINE('Finished extraction of MMT Staging Table: '|| l_row_count || ' rows inserted');
    BIS_COLLECTION_UTILITIES.PUT_LINE('Exiting Procedure '|| l_proc_name);

EXCEPTION

    WHEN OTHERS THEN

       BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,l_stmt_num));

       retcode := SQLCODE;
       errbuf := SQLERRM;

END GET_OPI_JOB_TXN_MMT_STG;

/*
   Procedure Populates the Jobs Transaction Staging table for ODM, Initial load
   procedure

   Parameters:
   retcode - 0 on successful completion, -1 on error and 1 for warning.
   errbuf - empty on successful completion, message on error or warning
*/

PROCEDURE GET_OPI_JOB_TXN_ODM_INIT(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
 l_stmt_num NUMBER;
 l_row_count NUMBER;
 l_err_num NUMBER;
 l_err_msg VARCHAR2(255);
 l_proc_name VARCHAR2(255);
 l_status VARCHAR2(30);
 l_industry VARCHAR2(30);
 l_opi_schema VARCHAR2(30);

BEGIN

    l_proc_name := 'OPI_DBI_JOB_TXN_STG_PKG.GET_OPI_JOB_TXN_ODM_INIT';

    BIS_COLLECTION_UTILITIES.PUT_LINE('Entering Procedure '|| l_proc_name);

    /* Insert ODM data into Staging */
    /* mta and mmta are joined to give the transaction value and mmt gives the transaction value */
    l_stmt_num := 20;
    INSERT  /*+ APPEND PARALLEL(STG) */
    INTO OPI_DBI_JOBS_TXN_STG STG
    (
    	job_id,
    	job_type,
    	organization_id,
    	assembly_item_id,
    	component_item_id,
    	uom_code,
    	line_type,
    	transaction_date,
    	primary_quantity,
    	primary_quantity_draft,
    	transaction_value_b,
    	transaction_value_draft_b,
    	scrap_reason,
    	planned_item,
    	etl_type_id,
    	source,
    	creation_date,
    	last_update_date,
	created_by,
	last_updated_by,
    	last_update_login,
    	PROGRAM_ID,
	PROGRAM_LOGIN_ID,
	PROGRAM_APPLICATION_ID,
	REQUEST_ID
    )
    select
        mmt1.JOB_ID,
        DECODE(WE.ENTITY_TYPE,1,1,2,2,4,3,3,1,8,5,5,5,5),
    	mta1.ORGANIZATION_ID,
    	WE.PRIMARY_ITEM_ID,
    	mta1.INVENTORY_ITEM_ID,
    	mmt1.PRIMARY_UOM_CODE,
    	decode(mmt1.etl_type_id, 1, -1, 1),
    	mmt1.transaction_date,
    	mmt1.TXN_QTY * -1,
    	0,
    	mta1.BASE_TRANSACTION_VALUE,
    	0,
    	nvl(mmt1.reason_id,-1),
    	MMT1.PLANNED_ITEM,
    	MMT1.ETL_TYPE_ID,
    	1,
    	s_sysdate,
	s_sysdate,
	s_user_id,
	s_user_id,
    	s_login_id,
    	s_program_id,
	s_program_login_id,
	s_program_application_id,
	s_request_id
    from
    	(
    	  select
    	    mta.ORGANIZATION_ID,
    	    mta.INVENTORY_ITEM_ID,
    	    mta.transaction_source_id,
    	    mmta.REPETITIVE_SCHEDULE_ID,
    	    trunc(mta.transaction_date) transaction_date,
    	    mta.transaction_id,
    	    decode(mmta.REPETITIVE_SCHEDULE_ID, null,
    	    		SUM(mta.BASE_TRANSACTION_VALUE),
    	                SUM(mta.BASE_TRANSACTION_VALUE) * decode(sum(mmta.tot_primary_quantity), 0,
    	                null, sum(mmta.primary_quantity) / sum(mmta.tot_primary_quantity))) BASE_TRANSACTION_VALUE
    	  from
    	    (select
    	    	mtain.ORGANIZATION_ID,
    	    	mtain.INVENTORY_ITEM_ID,
    	    	mtain.transaction_source_id,
    	    	mtain.transaction_id,
    	    	mtain.transaction_date,
    	    	SUM(mtain.BASE_TRANSACTION_VALUE) BASE_TRANSACTION_VALUE
    	    from
    	    	mtl_transaction_accounts mtain,
    	    	OPI_DBI_RUN_LOG_CURR log
    	    where
    	    	mtain.accounting_line_type = 7 /* WIP valuation */ and
    	    	mtain.transaction_source_type_id = 5  /* Job or schedule */ and
    	    	log.source = 1 and
    	    	log.etl_id = 1 and
    	    	mtain.organization_id = log.organization_id and
    	    	mtain.transaction_id >= log.Start_txn_id and
    	    	mtain.transaction_id < log.Next_start_txn_id
    	    group by
    	    	mtain.ORGANIZATION_ID,
    	    	mtain.INVENTORY_ITEM_ID,
    	    	mtain.transaction_source_id,
    	    	mtain.transaction_id,
    	    	mtain.transaction_date
    	    )mta, /* For repetitive schedules: An mtl txn can span across multiple repetitive schedules */
    	    (
    	     select
    	     	mmtain.organization_id,
    	     	mmtain.repetitive_schedule_id,
    	     	mmtain.transaction_id,
    	     	mmtain.transaction_date,
    	     	sum(primary_quantity) primary_quantity,
    	     	sum(sum(primary_quantity)) over
    	     		(partition by mmtain.organization_id, mmtain.transaction_id) tot_primary_quantity
    	    from
    	     	mtl_material_txn_allocations mmtain,
    	     	OPI_DBI_RUN_LOG_CURR log
    	     where
    	     	log.source = 1    and
    	     	log.etl_id = 1    and
    	     	mmtain.organization_id = log.organization_id    and
    	     	mmtain.transaction_id >= log.Start_txn_id    and
    	     	mmtain.transaction_id < log.Next_start_txn_id
    	     group by
    	     	mmtain.organization_id,
    	     	mmtain.repetitive_schedule_id,
    	     	mmtain.transaction_id,
    	     	mmtain.transaction_date
    	    )mmta
    	  where
    	    mta.organization_id = mmta.organization_id (+) and
    	    mta.transaction_id = mmta.transaction_id (+)
    	  group by
    	    mta.INVENTORY_ITEM_ID,
    	    mta.ORGANIZATION_ID,
    	    mta.transaction_source_id,
    	    mmta.REPETITIVE_SCHEDULE_ID,
    	    mta.transaction_id,
    	    mta.transaction_date
    	)mta1,
    	(
    	  select
    	    mmt.transaction_id,
    	    mmt.ORGANIZATION_ID,
    	    mmt.INVENTORY_ITEM_ID,
    	    mmt.transaction_source_id,
    	    decode(sum(mmta.primary_quantity), null, mmt.transaction_source_id,mmta.repetitive_schedule_id) JOB_ID,
    	    decode(sum(mmta.primary_quantity), null, 1, 2) JOB_TYPE,  -- Here 1 is for Discrete and Flow.
    	    msi.PRIMARY_UOM_CODE,
    	    decode(sum(mmta.primary_quantity), null, sum(mmt.primary_quantity),sum(mmta.primary_quantity)) TXN_QTY,
    	    trunc(mmt.transaction_date) transaction_date,
    	    mmt.reason_id,
    	    decode (msi.mrp_planning_code,
	                    NON_PLANNED_ITEM, 'N',
                                              'Y') PLANNED_ITEM,
    	    decode(mmt.transaction_action_id,1,1,
    	                                     27,1,
    	                                     31,2,
    	                                     32,2,
    	                                     30,3) ETL_TYPE_ID
    	  from
    	    OPI_DBI_JOBS_TXN_MMT_STG mmt,
    	    mtl_material_txn_allocations mmta,
    	    mtl_system_items_b msi,
    	    OPI_DBI_RUN_LOG_CURR log
    	  where
    	    mmt.organization_id = msi.organization_id and
    	    mmt.inventory_item_id = msi.inventory_item_id and
    	    mmt.transaction_action_id in (1, 27,31,32,30) and --  Issue, Receipt, Completion, Return,Scrap
    	    mmt.transaction_source_type_id = 5  and    --  Jobs abd Schedules
    	    mmt.transaction_id = mmta.transaction_id (+) and
    	    mmt.organization_id = log.organization_id and
    	    mmt.transaction_id >= log.Start_txn_id and
    	    mmt.transaction_id < log.Next_start_txn_id and
    	    log.etl_id = 1 and
    	    log.source = 1
    	  group by
    	    mmt.ORGANIZATION_ID,
    	    mmt.INVENTORY_ITEM_ID,
    	    mmt.transaction_source_id,
    	    mmta.repetitive_schedule_id,
    	    msi.PRIMARY_UOM_CODE,
    	    mmt.transaction_date,
    	    mmt.transaction_id,
    	    mmt.reason_id,
    	    mmt.transaction_action_id,
    	    msi.mrp_planning_code
    	)mmt1,
    	WIP_ENTITIES we,
    	WIP_DISCRETE_JOBS wdj
    where
        mta1.transaction_id = mmt1.transaction_id and
    	mta1.organization_id = mmt1.organization_id and
    	mta1.inventory_item_id = mmt1.inventory_item_id and
    	mta1.transaction_source_id = mmt1.transaction_source_id and
    	mta1.transaction_date = mmt1.transaction_date and
    	(we.ENTITY_TYPE in (1,3,4,5,8) OR (we.ENTITY_TYPE = 2 and mta1.REPETITIVE_SCHEDULE_ID = mmt1.JOB_ID)) and
    	(mmt1.TXN_QTY <> 0 or mta1.BASE_TRANSACTION_VALUE <> 0)  and
    	mta1.ORGANIZATION_ID = we.ORGANIZATION_ID and
    	mta1.transaction_source_id = WE.WIP_ENTITY_ID and
    	we.PRIMARY_ITEM_ID IS NOT NULL and
    	we.WIP_ENTITY_ID = wdj.WIP_ENTITY_ID (+) and
    	nvl (wdj.JOB_TYPE, 1) =1;

    	l_row_count := sql%rowcount;

	commit;

	BIS_COLLECTION_UTILITIES.PUT_LINE('Finished extraction of ODM Txn Staging Table: '|| l_row_count || ' rows inserted');
	BIS_COLLECTION_UTILITIES.PUT_LINE('Exiting Procedure '|| l_proc_name);


EXCEPTION

    WHEN OTHERS THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,l_stmt_num));

        retcode := SQLCODE;
   	errbuf := SQLERRM;

END GET_OPI_JOB_TXN_ODM_INIT;

/*
   Procedure popultaes the Jobs Transaction Staging table for ODM, Incremental
   load procedure

   Parameters:
   retcode - 0 on successful completion, -1 on error and 1 for warning.
   errbuf - empty on successful completion, message on error or warning
*/

PROCEDURE GET_OPI_JOB_TXN_ODM_INCR(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
 l_stmt_num NUMBER;
 l_row_count NUMBER;
 l_err_num NUMBER;
 l_err_msg VARCHAR2(255);
 l_proc_name VARCHAR2(255);
 l_status VARCHAR2(30);
 l_industry VARCHAR2(30);
 l_opi_schema VARCHAR2(30);

BEGIN

    l_proc_name := 'OPI_DBI_JOB_TXN_STG_PKG.GET_OPI_JOB_TXN_ODM_INCR';

    BIS_COLLECTION_UTILITIES.PUT_LINE('Entering Procedure '|| l_proc_name);

    /* Insert ODM data into Staging*/
    /* mta and mmta are joined to give the transaction value and mmt gives the transaction value */
    l_stmt_num := 20;
    INSERT
    INTO OPI_DBI_JOBS_TXN_STG
    (
    	job_id,
    	job_type,
    	organization_id,
    	assembly_item_id,
    	component_item_id,
    	uom_code,
    	line_type,
    	transaction_date,
    	primary_quantity,
    	primary_quantity_draft,
    	transaction_value_b,
    	transaction_value_draft_b,
    	scrap_reason,
    	planned_item,
    	etl_type_id,
    	source,
    	creation_date,
    	last_update_date,
	created_by,
	last_updated_by,
    	last_update_login,
    	PROGRAM_ID,
	PROGRAM_LOGIN_ID,
	PROGRAM_APPLICATION_ID,
	REQUEST_ID
    )
    select
        mmt1.JOB_ID,
        DECODE(WE.ENTITY_TYPE,1,1,2,2,4,3,3,1,8,5,5,5,5),
    	mta1.ORGANIZATION_ID,
    	WE.PRIMARY_ITEM_ID,
    	mta1.INVENTORY_ITEM_ID,
    	mmt1.PRIMARY_UOM_CODE,
    	decode(mmt1.etl_type_id, 1, -1, 1),
    	mmt1.transaction_date,
    	mmt1.TXN_QTY * -1,
    	0,
    	mta1.BASE_TRANSACTION_VALUE,
    	0,
    	nvl(mmt1.reason_id,-1),
    	MMT1.PLANNED_ITEM,
    	MMT1.ETL_TYPE_ID,
    	1,
    	s_sysdate,
	s_sysdate,
	s_user_id,
	s_user_id,
    	s_login_id,
    	s_program_id,
	s_program_login_id,
	s_program_application_id,
	s_request_id
    from
    	(
    	  select
    	    mta.ORGANIZATION_ID,
    	    mta.INVENTORY_ITEM_ID,
    	    mta.transaction_source_id,
    	    mmta.REPETITIVE_SCHEDULE_ID,
    	    trunc(mta.transaction_date) transaction_date,
    	    mta.transaction_id transaction_id,
    	    decode(mmta.REPETITIVE_SCHEDULE_ID, null,
    	    		SUM(mta.BASE_TRANSACTION_VALUE),
    	                SUM(mta.BASE_TRANSACTION_VALUE) * decode(sum(mmta.tot_primary_quantity), 0,
    	                null, sum(mmta.primary_quantity) / sum(mmta.tot_primary_quantity))) BASE_TRANSACTION_VALUE
    	  from
    	    (select
    	    	mtain.ORGANIZATION_ID,
    	    	mtain.INVENTORY_ITEM_ID,
    	    	mtain.transaction_source_id,
    	    	mtain.transaction_id,
    	    	mtain.transaction_date,
    	    	SUM(mtain.BASE_TRANSACTION_VALUE) BASE_TRANSACTION_VALUE
    	    from
    	    	mtl_transaction_accounts mtain,
    	    	OPI_DBI_RUN_LOG_CURR log
    	    where
    	    	mtain.accounting_line_type = 7 /* WIP valuation */ and
    	    	mtain.transaction_source_type_id = 5  /* Job or schedule */ and
    	    	log.source = 1 and
    	    	log.etl_id = 1 and
    	    	mtain.organization_id = log.organization_id and
    	    	mtain.transaction_id >= log.Start_txn_id and
    	    	mtain.transaction_id < log.Next_start_txn_id
    	    group by
    	    	mtain.ORGANIZATION_ID,
    	    	mtain.INVENTORY_ITEM_ID,
    	    	mtain.transaction_source_id,
    	    	mtain.transaction_id,
    	    	mtain.transaction_date
    	    )mta,
    	    (
    	     select
    	     	mmtain.organization_id,
    	     	mmtain.REPETITIVE_SCHEDULE_ID,
    	     	mmtain.transaction_id,
    	     	mmtain.transaction_date,
    	     	sum(primary_quantity) primary_quantity,
    	     	sum(sum(primary_quantity)) over
    	     		(partition by mmtain.organization_id, mmtain.transaction_id) tot_primary_quantity
    	    from
    	     	mtl_material_txn_allocations mmtain,
    	     	OPI_DBI_RUN_LOG_CURR log
    	     where
    	     	log.source = 1 and
    	     	log.etl_id = 1 and
    	     	mmtain.organization_id = log.organization_id and
    	     	mmtain.transaction_id >= log.Start_txn_id and
    	     	mmtain.transaction_id < log.Next_start_txn_id
    	     group by
    	     	mmtain.organization_id,
    	     	mmtain.repetitive_schedule_id,
    	     	mmtain.transaction_id,
    	     	mmtain.transaction_date
    	    )mmta
    	  where
    	    mta.organization_id = mmta.organization_id (+) and
    	    mta.transaction_id = mmta.transaction_id (+)
    	  group by
    	    mta.INVENTORY_ITEM_ID,
    	    mta.ORGANIZATION_ID,
    	    mta.transaction_source_id,
    	    mmta.REPETITIVE_SCHEDULE_ID,
    	    mta.transaction_id,
    	    mta.transaction_date
    	)mta1,
    	(
    	  select
    	    mmt.transaction_id,
    	    mmt.ORGANIZATION_ID,
    	    mmt.INVENTORY_ITEM_ID,
    	    mmt.transaction_source_id,
    	    decode(sum(mmta.primary_quantity), null, mmt.transaction_source_id,mmta.repetitive_schedule_id) JOB_ID,
    	    decode(sum(mmta.primary_quantity), null, 1, 2) JOB_TYPE,  -- Here 1 is for Discrete and Flow.
    	    msi.PRIMARY_UOM_CODE,
    	    decode(sum(mmta.primary_quantity), null, sum(mmt.primary_quantity),sum(mmta.primary_quantity)) TXN_QTY,
    	    trunc(mmt.transaction_date) transaction_date,
    	    mmt.reason_id,
    	    decode (msi.mrp_planning_code,
	                    NON_PLANNED_ITEM, 'N',
                                              'Y') PLANNED_ITEM,
    	    decode(mmt.transaction_action_id,1,1,
    	                                     27,1,
    	                                     31,2,
    	                                     32,2,
    	                                     30,3) ETL_TYPE_ID
    	  from
    	    MTL_MATERIAL_TRANSACTIONS mmt,
    	    mtl_material_txn_allocations mmta,
    	    mtl_system_items_b msi,
    	    OPI_DBI_RUN_LOG_CURR log
    	  where
    	    mmt.organization_id = msi.organization_id and
    	    mmt.inventory_item_id = msi.inventory_item_id and
    	    mmt.transaction_action_id in (1, 27,31,32,30) and --  Issue, Receipt, Completion, Return,Scrap
    	    mmt.transaction_source_type_id = 5  and    --  Jobs abd Schedules
    	    mmt.transaction_id = mmta.transaction_id (+) and
    	    mmt.organization_id = log.organization_id and
    	    mmt.transaction_id >= log.Start_txn_id and
    	    mmt.transaction_id < log.Next_start_txn_id and
    	    log.etl_id = 1 and
    	    log.source = 1
    	  group by
    	    mmt.ORGANIZATION_ID,
    	    mmt.INVENTORY_ITEM_ID,
    	    mmt.transaction_source_id,
    	    mmta.repetitive_schedule_id,
    	    msi.PRIMARY_UOM_CODE,
    	    mmt.transaction_date,
    	    mmt.transaction_id,
    	    mmt.reason_id,
    	    mmt.transaction_action_id,
    	    msi.mrp_planning_code
    	)mmt1,
    	WIP_ENTITIES we,
    	WIP_DISCRETE_JOBS wdj
    where
        mta1.transaction_id = mmt1.transaction_id and
    	mta1.organization_id = mmt1.organization_id and
    	mta1.inventory_item_id = mmt1.inventory_item_id and
    	mta1.transaction_source_id = mmt1.transaction_source_id and
    	mta1.transaction_date = mmt1.transaction_date and
    	(we.ENTITY_TYPE in (1,3,4,5,8) OR (we.ENTITY_TYPE = 2 and mta1.REPETITIVE_SCHEDULE_ID = mmt1.JOB_ID)) and
    	(mmt1.TXN_QTY <> 0 or mta1.BASE_TRANSACTION_VALUE <> 0)  and
    	mta1.ORGANIZATION_ID = we.ORGANIZATION_ID and
    	mta1.transaction_source_id = WE.WIP_ENTITY_ID and
    	we.PRIMARY_ITEM_ID IS NOT NULL and
    	we.WIP_ENTITY_ID = wdj.WIP_ENTITY_ID (+) and
    	nvl (wdj.JOB_TYPE, 1) =1;

    	l_row_count := sql%rowcount;

	commit;

	BIS_COLLECTION_UTILITIES.PUT_LINE('Finished extraction of ODM Txn Staging Table: '|| l_row_count || ' rows inserted');
	BIS_COLLECTION_UTILITIES.PUT_LINE('Exiting Procedure '|| l_proc_name);

EXCEPTION

    WHEN OTHERS THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,l_stmt_num));

        retcode := SQLCODE;
   	errbuf := SQLERRM;

END GET_OPI_JOB_TXN_ODM_INCR;

/*
   Procedure populates the Jobs Transactio Staging Table for OPM, Initial Load
   procedure

   Parameters:
      retcode - 0 on successful completion, -1 on error and 1 for warning.
      errbuf - empty on successful completion, message on error or warning
*/

PROCEDURE GET_OPI_JOB_TXN_OPM_INIT(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
 l_stmt_num NUMBER;
 l_row_count NUMBER;
 l_err_num NUMBER;
 l_err_msg VARCHAR2(255);
 l_proc_name VARCHAR2(255);
 l_from_date OPI_DBI_RUN_LOG_CURR.FROM_BOUND_DATE%TYPE;
 l_to_date OPI_DBI_RUN_LOG_CURR.FROM_BOUND_DATE%TYPE;
 l_status VARCHAR2(30);
 l_industry VARCHAR2(30);
 l_opi_schema VARCHAR2(30);

 CURSOR OPI_DBI_RUN_LOG_CURR_CSR IS
 	select
 		from_bound_date,
 		to_bound_date
 	from
 		OPI_DBI_RUN_LOG_CURR
 	where
 		ETL_ID = 1 and
 		source = 2;

BEGIN

    l_proc_name := 'OPI_DBI_JOB_TXN_STG_PKG.GET_OPI_JOB_TXN_OPM_INIT';

    BIS_COLLECTION_UTILITIES.PUT_LINE('Entering Procedure '|| l_proc_name);

    l_stmt_num := 10;
    OPEN OPI_DBI_RUN_LOG_CURR_CSR;
        FETCH OPI_DBI_RUN_LOG_CURR_CSR INTO l_from_date,l_to_date;

    l_stmt_num :=15;
    IF (OPI_DBI_RUN_LOG_CURR_CSR%NOTFOUND) THEN
    --{
             RAISE NO_DATA_FOUND;
    --}
        END IF;
    CLOSE OPI_DBI_RUN_LOG_CURR_CSR;

     /* GTV is summarised and joined with MMT Staging. GTV gives the transaction value while
     MMT Staging gives the quantity. Join with GME_MATERIAL_DETAILS is required to get the
     cost alloc factor for products. */
    l_stmt_num := 20;
    INSERT
    INTO OPI_DBI_JOBS_TXN_STG
    (
        job_id,
        job_type,
        organization_id,
        assembly_item_id,
        component_item_id,
        uom_code,
        line_type,
        transaction_date,
        primary_quantity,
        primary_quantity_draft,
        transaction_value_b,
        transaction_value_draft_b,
        scrap_reason,
        planned_item,
        etl_type_id,
        source,
        creation_date,
        last_update_date,
    	created_by,
    	last_updated_by,
        last_update_login,
        PROGRAM_ID,
	PROGRAM_LOGIN_ID,
	PROGRAM_APPLICATION_ID,
	REQUEST_ID
    )
    SELECT
    	MTL_DTL.batch_id,
    	4,
    	MTL_DTL.organization_id,
    	MTL_DTL.inventory_item_id,
    	GTV.inventory_item_id,
    	msi.PRIMARY_UOM_CODE,
    	GTV.line_type,
    	GTV.transaction_date,
    	-sum(decode(GTV.accounted_flag,'F',
    		MMT_STG.primary_quantity*decode(GTV.line_type,1,
    			decode(MTL_DTL.inventory_item_id,GTV.inventory_item_id,1,0),
    					              2,
    			MTL_DTL.cost_alloc,
    	  				             -1,
    			MTL_DTL.cost_alloc),0)) primary_quantity,
        -sum(decode(GTV.accounted_flag,'D',
        	MMT_STG.primary_quantity*decode(GTV.line_type,1,
        		decode(MTL_DTL.inventory_item_id,GTV.inventory_item_id,1,0),
        					      2,
                        MTL_DTL.cost_alloc,
                        			     -1,
                        MTL_DTL.cost_alloc),0)) primary_quantity_draft,
        -sum(decode(GTV.accounted_flag,'F',
        	GTV.txn_base_value*decode(GTV.line_type,1,
        		decode(MTL_DTL.inventory_item_id,GTV.inventory_item_id,1,0),
        						2,
        		MTL_DTL.cost_alloc,
        						-1,
        		MTL_DTL.cost_alloc),0)) transaction_value_b,
        -sum(decode(GTV.accounted_flag,'D',
        	GTV.txn_base_value*decode(GTV.line_type,1,
        		decode(MTL_DTL.inventory_item_id,GTV.inventory_item_id,1,0),
        						2,
        		MTL_DTL.cost_alloc,
        						-1,
        		MTL_DTL.cost_alloc),0)) transaction_value_draft_b,
        -1,
        decode (msi.mrp_planning_code,
		NON_PLANNED_ITEM, 'N',
                                  'Y') PLANNED_ITEM,
        decode(GTV.line_type,-1,1,
        		      2,1,
        		      1,decode(gtv.inventory_item_id,mtl_dtl.inventory_item_id,2,-1))
        		      ETL_TYPE_ID,
        2,
        s_sysdate,
	s_sysdate,
	s_user_id,
	s_user_id,
    	s_login_id,
    	s_program_id,
	s_program_login_id,
	s_program_application_id,
	s_request_id
    FROM
    (
    	select
    		gtv.transaction_id,
    		gtv.organization_id,
    		gtv.doc_id,
    		gtv.inventory_item_id,
    		gtv.line_type,
    		gtv.transaction_date,
    		nvl(gtv.accounted_flag,'F') accounted_flag,
    		sum(gtv.txn_base_value) txn_base_value
    	from
    		gmf_transaction_valuation gtv,
    		OPI_DBI_ORG_LE_TEMP tmp
    	where
    		gtv.journal_line_type in ('INV') and
    		--gtv.txn_source = 'PRODUCTION' and
    		gtv.event_class_code = 'BATCH_MATERIAL' and
    		gtv.transaction_date>= s_global_start_date and
    		( gtv.accounted_flag = 'D' OR -- All draft rows
    		  ( nvl(gtv.accounted_flag,'N') = 'N' and
    		    gtv.final_posting_date between l_from_date and l_to_date
    		  )
    		) and
          	gtv.ledger_id = tmp.ledger_id and
          	gtv.legal_entity_id = tmp.legal_entity_id and
	  	gtv.valuation_cost_type_id = tmp.valuation_cost_type_id and
          	gtv.organization_id = tmp. organization_id
    	group by
    		gtv.transaction_id,
    		gtv.organization_id,
    		gtv.doc_id,
    		gtv.inventory_item_id,
    		gtv.line_type,
    		gtv.transaction_date,
    		gtv.accounted_flag
    ) GTV,
    	GME_MATERIAL_DETAILS MTL_DTL,
    	OPI_DBI_JOBS_TXN_MMT_STG MMT_STG,
    	mtl_system_items_b msi
    where
    	GTV.organization_id = MTL_DTL.organization_id and
    	GTV.doc_id = MTL_DTL.batch_id and
    	MTL_DTL.line_type = 1 and --Product
    	GTV.transaction_id = MMT_STG.transaction_id and
    	MMT_STG.process_enabled_flag = 'Y' and
    	msi.organization_id = GTV.organization_id and
    	msi.inventory_item_id = GTV.inventory_item_id
    group by
    	MTL_DTL.batch_id,
    	MTL_DTL.organization_id,
    	MTL_DTL.inventory_item_id,
    	GTV.inventory_item_id,
    	msi.PRIMARY_UOM_CODE,
    	GTV.line_type,
    	GTV.transaction_date,
    	msi.mrp_planning_code;

    	l_row_count := sql%rowcount;

	commit;

	BIS_COLLECTION_UTILITIES.PUT_LINE('Finished extraction of OPM Txn Staging Table: '|| l_row_count || ' rows inserted');
	BIS_COLLECTION_UTILITIES.PUT_LINE('Exiting Procedure '|| l_proc_name);

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE ('No rows in Log Table, Run Initial Load again');
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,l_stmt_num));
        retcode := SQLCODE;
   	errbuf := SQLERRM;

    WHEN OTHERS THEN

	BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,l_stmt_num));

	retcode := SQLCODE;
   	errbuf := SQLERRM;

END GET_OPI_JOB_TXN_OPM_INIT;

/*
   Procedure populates the Jobs Transactio Staging Table for OPM, Incremental Load
   procedure

   Parameters:
   retcode - 0 on successful completion, -1 on error and 1 for warning.
   errbuf - empty on successful completion, message on error or warning
*/

PROCEDURE GET_OPI_JOB_TXN_OPM_INCR(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
 l_stmt_num NUMBER;
 l_row_count NUMBER;
 l_err_num NUMBER;
 l_err_msg VARCHAR2(255);
 l_proc_name VARCHAR2(255);
 l_from_date OPI_DBI_RUN_LOG_CURR.FROM_BOUND_DATE%TYPE;
 l_to_date OPI_DBI_RUN_LOG_CURR.FROM_BOUND_DATE%TYPE;
 l_status VARCHAR2(30);
 l_industry VARCHAR2(30);
 l_opi_schema VARCHAR2(30);

 CURSOR OPI_DBI_RUN_LOG_CURR_CSR IS
 	select
 		from_bound_date,
 		to_bound_date
 	from
 		OPI_DBI_RUN_LOG_CURR
 	where
 		ETL_ID = 1 and
 		source = 2;

BEGIN

    l_proc_name := 'OPI_DBI_JOB_TXN_STG_PKG.GET_OPI_JOB_TXN_OPM_INCR';

    BIS_COLLECTION_UTILITIES.PUT_LINE('Entering Procedure '|| l_proc_name);

    l_stmt_num := 10;
    OPEN OPI_DBI_RUN_LOG_CURR_CSR;
        FETCH OPI_DBI_RUN_LOG_CURR_CSR INTO l_from_date,l_to_date;

    l_stmt_num :=15;
    IF (OPI_DBI_RUN_LOG_CURR_CSR%NOTFOUND) THEN
    --{
        RAISE NO_DATA_FOUND;
    --}
    END IF;
    CLOSE OPI_DBI_RUN_LOG_CURR_CSR;

     /* GTV is summarised and joined with MMT. GTV gives the transaction value while
        MMT gives the quantity. Join with GME_MATERIAL_DETAILS is required to get the
        cost alloc factor for products. */
    l_stmt_num := 20;
    INSERT
    INTO OPI_DBI_JOBS_TXN_STG
    (
        job_id,
        job_type,
        organization_id,
        assembly_item_id,
        component_item_id,
        uom_code,
        line_type,
        transaction_date,
        primary_quantity,
        primary_quantity_draft,
        transaction_value_b,
        transaction_value_draft_b,
        scrap_reason,
        planned_item,
        etl_type_id,
        source,
        creation_date,
        last_update_date,
    	created_by,
    	last_updated_by,
        last_update_login,
        PROGRAM_ID,
	PROGRAM_LOGIN_ID,
	PROGRAM_APPLICATION_ID,
	REQUEST_ID
    )
    SELECT
    	MTL_DTL.batch_id,
    	4,
    	MTL_DTL.organization_id,
    	MTL_DTL.inventory_item_id,
    	GTV.inventory_item_id,
    	msi.PRIMARY_UOM_CODE,
    	GTV.line_type,
    	GTV.transaction_date,
    	-sum(decode(GTV.accounted_flag,'F',
    		MMT_STG.primary_quantity*decode(GTV.line_type,1,
    			decode(MTL_DTL.inventory_item_id,GTV.inventory_item_id,1,0),
    						       2,
    			MTL_DTL.cost_alloc,
    						      -1,
    			MTL_DTL.cost_alloc),0)) primary_quantity,
        -sum(decode(GTV.accounted_flag,'D',
        	MMT_STG.primary_quantity*decode(GTV.line_type,1,
        		decode(MTL_DTL.inventory_item_id,GTV.inventory_item_id,1,0),
        					      2,
                        MTL_DTL.cost_alloc,
                        			     -1,
                        MTL_DTL.cost_alloc),0)) primary_quantity_draft,
        -sum(decode(GTV.accounted_flag,'F',
        	GTV.txn_base_value*decode(GTV.line_type,1,
        		decode(MTL_DTL.inventory_item_id,GTV.inventory_item_id,1,0),
        						2,
        		MTL_DTL.cost_alloc,
        						-1,
        		MTL_DTL.cost_alloc),0)) transaction_value_b,
        -sum(decode(GTV.accounted_flag,'D',
               	GTV.txn_base_value*decode(GTV.line_type,1,
        		decode(MTL_DTL.inventory_item_id,GTV.inventory_item_id,1,0),
        						2,
        		MTL_DTL.cost_alloc,
        						-1,
        		MTL_DTL.cost_alloc),0)) transaction_value_draft_b,
        -1,
        decode (msi.mrp_planning_code,
		NON_PLANNED_ITEM, 'N',
                                  'Y') PLANNED_ITEM,
        decode(GTV.line_type,-1,1,
        		      2,1,
        		      1,decode(gtv.inventory_item_id,mtl_dtl.inventory_item_id,2,-1))
        		      ETL_TYPE_ID,
        2,
        s_sysdate,
	s_sysdate,
	s_user_id,
	s_user_id,
    	s_login_id,
    	s_program_id,
	s_program_login_id,
	s_program_application_id,
	s_request_id
    FROM
    (
    	select
    		gtv.transaction_id,
    		gtv.organization_id,
    		gtv.doc_id,
    		gtv.inventory_item_id,
    		gtv.line_type,
    		gtv.transaction_date,
    		nvl(gtv.accounted_flag,'F') accounted_flag,
    		sum(gtv.txn_base_value) txn_base_value
    	from
    		gmf_transaction_valuation gtv,
    		OPI_DBI_ORG_LE_TEMP tmp
    	where
    		gtv.journal_line_type in ('INV') and
    		--gtv.txn_source = 'PRODUCTION' and
    		gtv.event_class_code = 'BATCH_MATERIAL' and
    		gtv.transaction_date>= s_global_start_date and
    		( gtv.accounted_flag = 'D' OR -- All draft rows
		  ( nvl(gtv.accounted_flag,'N') = 'N' and
		    gtv.final_posting_date between l_from_date and l_to_date
		  )
    		) and
          	gtv.ledger_id = tmp.ledger_id and
          	gtv.legal_entity_id = tmp.legal_entity_id and
	  	gtv.valuation_cost_type_id = tmp.valuation_cost_type_id and
          	gtv.organization_id = tmp. organization_id
    	group by
    		gtv.transaction_id,
    		gtv.organization_id,
    		gtv.doc_id,
    		gtv.inventory_item_id,
    		gtv.line_type,
    		gtv.transaction_date,
    		gtv.accounted_flag
    ) GTV,
    	GME_MATERIAL_DETAILS MTL_DTL,
    	MTL_MATERIAL_TRANSACTIONS MMT_STG,
    	mtl_system_items_b msi
    where
    	GTV.organization_id = MTL_DTL.organization_id and
    	GTV.doc_id = MTL_DTL.batch_id and
    	MTL_DTL.line_type = 1 and  -- Products
    	GTV.transaction_id = MMT_STG.transaction_id and
    	--MMT_STG.process_enabled_flag = 'Y' and
    	msi.organization_id = GTV.organization_id and
    	msi.inventory_item_id = GTV.inventory_item_id
    group by
    	MTL_DTL.batch_id,
    	MTL_DTL.organization_id,
    	MTL_DTL.inventory_item_id,
    	GTV.inventory_item_id,
    	msi.PRIMARY_UOM_CODE,
    	GTV.line_type,
    	GTV.transaction_date,
    	msi.mrp_planning_code;

    	l_row_count := sql%rowcount;

	commit;

	BIS_COLLECTION_UTILITIES.PUT_LINE('Finished extraction of OPM Txn Staging Table: '|| l_row_count || ' rows inserted');
	BIS_COLLECTION_UTILITIES.PUT_LINE('Exiting Procedure '|| l_proc_name);

EXCEPTION

    WHEN OTHERS THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,l_stmt_num));

        retcode := SQLCODE;
   	errbuf := SQLERRM;

END GET_OPI_JOB_TXN_OPM_INCR;

/*
   Procedure populates the Jobs Transactio Staging Table for Pre R12 OPM, Initial Load
   procedure called only if the GSD < R12 Upgrade date

   Parameters:
   retcode - 0 on successful completion, -1 on error and 1 for warning.
   errbuf - empty on successful completion, message on error or warning
*/

PROCEDURE GET_OPI_JOB_TXN_PR12OPM_INIT(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
 l_stmt_num NUMBER;
 l_row_count NUMBER;
 l_err_num NUMBER;
 l_err_msg VARCHAR2(255);
 l_proc_name VARCHAR2(255);
 l_status VARCHAR2(30);
 l_industry VARCHAR2(30);
 l_opi_schema VARCHAR2(30);

BEGIN

    l_proc_name := 'OPI_DBI_JOB_TXN_STG_PKG.GET_OPI_JOB_TXN_PR12OPM_INIT';

    BIS_COLLECTION_UTILITIES.PUT_LINE('Entering Procedure '|| l_proc_name);

    /* Inserting Pre R12 OPM MU Actuals to Jobs Transaction Staging */
    l_stmt_num := 10;
    INSERT
    INTO OPI_DBI_JOBS_TXN_STG
    (
        job_id,
        job_type,
        organization_id,
        assembly_item_id,
        component_item_id,
        uom_code,
        line_type,
        transaction_date,
        primary_quantity,
        primary_quantity_draft,
        transaction_value_b,
        transaction_value_draft_b,
        scrap_reason,
        planned_item,
        etl_type_id,
        source,
        creation_date,
        last_update_date,
        created_by,
        last_updated_by,
        last_update_login,
        PROGRAM_ID,
	PROGRAM_LOGIN_ID,
	PROGRAM_APPLICATION_ID,
	REQUEST_ID
    )
    select
        scaled.batch_id,
        scaled.job_type,
    	scaled.Organization_Id,
    	scaled.coproduct_id,
    	scaled.item_id,
    	scaled.item_um,
    	scaled.line_type,
    	itp.trans_date,
    	sum(itp.trans_qty * coprod.cost_alloc),
    	0,
    	-sum(led.amount_base * coprod.cost_alloc),
    	0,
    	null,
    	null,
    	1,
    	3,
    	s_sysdate,
	s_sysdate,
	s_user_id,
	s_user_id,
    	s_login_id,
    	s_program_id,
	s_program_login_id,
	s_program_application_id,
	s_request_id
    from
    	OPI_DBI_OPM_SCALED_MTL  scaled,
    	gme_material_details    coprod,
    	gl_subr_led led,
    	(
    	SELECT
    		jobs.Organization_id,
    		jobs.Job_Id,
    		jobs.Job_Type,
    		jobs.Assembly_Item_id,
    		itp.trans_qty,
    		itp.doc_type,
    		itp.doc_id,
    		itp.line_id,
    		itp.trans_date,
    		itp.line_type
    	FROM
    		OPI_DBI_JOBS_F jobs,
    		IC_TRAN_PND   itp
    	WHERE
    		jobs.source = 3 AND
    		itp.completed_ind = 1 AND
    		itp.doc_type = 'PROD' AND
    		itp.doc_id = jobs.job_id
    	GROUP BY
    		jobs.Organization_id,
    		jobs.Job_Id,
    		jobs.Job_Type,
    		jobs.Assembly_Item_id,
		doc_type,
    		doc_id,
    		line_id,
    		trans_date,
    		trans_qty,
    		itp.line_type
    	)itp
    	where
    		coprod.line_type in (1) and
    		scaled.line_type in (-1, 2) and
    		coprod.organization_id = scaled.organization_id and
    		coprod.batch_id = scaled.batch_id and
    		coprod.inventory_item_id = scaled.coproduct_id and
    		itp.organization_id = scaled.organization_id and
    		itp.job_id = scaled.batch_id and
    		itp.assembly_item_id = scaled.coproduct_id and
    		led.doc_id = itp.job_id and
    		led.line_id = itp.line_id and
    		led.doc_type = 'PROD' and
    		led.acct_ttl_type = 1500 and
    		led.sub_event_type in (50010,50040)
    	group by
    		scaled.Organization_Id,
    		scaled.batch_id,
    		scaled.job_type,
    		scaled.coproduct_id,
    		scaled.item_id,
    		scaled.item_um,
    		scaled.line_type,
    		itp.trans_date;

    /* Inserting Pre R12 OPM WIP Completions to Jobs Transaction Staging */
    l_stmt_num := 20;
    INSERT
    INTO OPI_DBI_JOBS_TXN_STG
    (
    	job_id,
        job_type,
        organization_id,
        assembly_item_id,
        component_item_id,
        uom_code,
        line_type,
        transaction_date,
        primary_quantity,
        primary_quantity_draft,
        transaction_value_b,
        transaction_value_draft_b,
        scrap_reason,
        planned_item,
        etl_type_id,
        source,
        creation_date,
        last_update_date,
        created_by,
        last_updated_by,
        last_update_login,
        PROGRAM_ID,
	PROGRAM_LOGIN_ID,
	PROGRAM_APPLICATION_ID,
	REQUEST_ID
    )
    SELECT
        itp.doc_id job_id,
        4,
    	mtl_dtl.organization_id,
    	mtl_dtl.inventory_item_id,
    	mtl_dtl.inventory_item_id,
    	mtl_dtl.dtl_um,
    	mtl_dtl.line_type,
    	led.gl_trans_date,
    	-sum (itp.trans_qty),
    	0,
    	-sum (led.amount_base),
    	0,
    	null,
    	decode (msi.mrp_planning_code,NON_PLANNED_ITEM,
    			'N',
                        'Y') PLANNED_ITEM,

    	2,
    	3,
    	s_sysdate,
	s_sysdate,
	s_user_id,
	s_user_id,
    	s_login_id,
    	s_program_id,
	s_program_login_id,
	s_program_application_id,
	s_request_id
    FROM
    	(SELECT
    		doc_type,
    		doc_id,
    		line_id,
    		TRUNC(trans_date) trans_date,
    		orgn_code,
    		item_id,
    		SUM(trans_qty) trans_qty
    	FROM
    		ic_tran_pnd
    	WHERE
    		doc_type = 'PROD' AND
    		line_type IN (1,2) AND
    		completed_ind = 1 AND
    		gl_posted_ind = 1 AND
    		trans_date >= s_global_start_date
    	GROUP BY
    		doc_type,
    		doc_id,
    		line_id,
    		TRUNC(trans_date),
    		orgn_code,
    		item_id
    	)itp,
    	(SELECT
    		sub.doc_type,
    		sub.doc_id,
    		sub.line_id,
    		TRUNC(sub.gl_trans_date) gl_trans_date,
    		SUM(sub.amount_base * sub.debit_credit_sign) amount_base
    	FROM
    		gl_subr_led sub
    	WHERE
    		sub.gl_trans_date >= s_global_start_date AND
    		sub.acct_ttl_type = 1500 AND
    		sub.doc_type = 'PROD'
    	GROUP BY
    		sub.doc_type,
    		sub.doc_id,
    		sub.line_id,
    		TRUNC(sub.gl_trans_date)
    	) led,
    	GME_MATERIAL_DETAILS mtl_dtl,
    	mtl_system_items_b msi
    WHERE
    	itp.doc_type = led.doc_type AND
    	itp.doc_id = led.doc_id AND
    	itp.line_id = led.line_id AND
    	itp.trans_date = led.gl_trans_date AND
    	mtl_dtl.batch_id = itp.doc_id AND
    	mtl_dtl.material_detail_id = itp.line_id AND
    	msi.inventory_item_id = mtl_dtl.inventory_item_id AND
	msi.organization_id = mtl_dtl.organization_id
    GROUP BY
    	mtl_dtl.organization_id,
    	itp.doc_id,
    	mtl_dtl.inventory_item_id,
    	mtl_dtl.dtl_um,
        mtl_dtl.line_type,
    	led.gl_trans_date,
    	msi.mrp_planning_code;

    l_row_count := sql%rowcount;

    commit;

    BIS_COLLECTION_UTILITIES.PUT_LINE('Finished extraction Pre R12 OPM to Jobs Txn Staging: '|| l_row_count || ' rows inserted');
    BIS_COLLECTION_UTILITIES.PUT_LINE('Exiting Procedure '|| l_proc_name);

EXCEPTION

    WHEN OTHERS THEN

    	BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,l_stmt_num));

        retcode := SQLCODE;
   	errbuf := SQLERRM;

END GET_OPI_JOB_TXN_PR12OPM_INIT;

/*
  Procedure populates the Material Usage Actuals Fact from Jobs Transaction Staging for OPM and ODM, Initial
  Load procedure

  Parameters:
    retcode - 0 on successful completion, -1 on error and 1 for warning.
    errbuf - empty on successful completion, message on error or warning
*/

PROCEDURE GET_OPI_MTL_USAGE_ACT_INIT(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
 l_stmt_num NUMBER;
 l_row_count NUMBER;
 l_err_num NUMBER;
 l_err_msg VARCHAR2(255);
 l_proc_name VARCHAR2(255);
 l_status VARCHAR2(30);
 l_industry VARCHAR2(30);
 l_opi_schema VARCHAR2(30);

BEGIN

    l_proc_name := 'OPI_DBI_JOB_TXN_STG_PKG.GET_OPI_MTL_USAGE_ACT_INIT';

    BIS_COLLECTION_UTILITIES.PUT_LINE('Entering Procedure '|| l_proc_name);

    /* Extraction of MTL Usage Actuals fact */
    l_stmt_num := 20;
    INSERT
    INTO OPI_DBI_JOB_MTL_DETAILS_F
    (
	organization_id,
	job_id,
	job_type,
	assembly_item_id,
	component_item_id,
	uom_code,
	line_type,
	transaction_date,
	standard_value_b,
	actual_value_b,
	actual_value_draft_b,
	standard_quantity,
	actual_quantity,
	actual_quantity_draft,
	source,
	creation_date,
	last_update_date,
	created_by,
	last_updated_by,
        last_update_login,
        actual_value_g,
	actual_value_draft_g,
	actual_value_sg,
	actual_value_draft_sg,
	PROGRAM_ID,
	PROGRAM_LOGIN_ID,
	PROGRAM_APPLICATION_ID,
	REQUEST_ID
    )
    select
    	jobs_txn.organization_id,
    	job_id,
	job_type,
	assembly_item_id,
	component_item_id,
	uom_code,
	line_type,
	trunc(jobs_txn.transaction_date),
	0,
	sum(transaction_value_b+transaction_value_draft_b),
        sum(transaction_value_draft_b),
        0, /* This fact will no more hold Stabdard Value and Standard Qty and hence 0 */
	sum(primary_quantity+primary_quantity_draft),
	sum(primary_quantity_draft),
	source,
	s_sysdate,
	s_sysdate,
	s_user_id,
	s_user_id,
    	s_login_id,
        sum((transaction_value_b+transaction_value_draft_b)*crates.conversion_rate),
        sum(transaction_value_draft_b*crates.conversion_rate),
        sum((transaction_value_b+transaction_value_draft_b)*crates.sec_conversion_rate),
        sum(transaction_value_draft_b*crates.sec_conversion_rate),
        s_program_id,
	s_program_login_id,
	s_program_application_id,
	s_request_id
    from
    	OPI_DBI_JOBS_TXN_STG jobs_txn,
    	opi_dbi_muv_conv_rates crates
    where
    	etl_type_id = 1 and
    	crates.organization_id = jobs_txn.organization_id and
    	trunc(jobs_txn.transaction_date) = crates.transaction_date
    group by
    	jobs_txn.organization_id,
    	job_id,
	job_type,
	assembly_item_id,
	component_item_id,
	uom_code,
	line_type,
	trunc(jobs_txn.transaction_date),
	source;

    l_row_count := sql%rowcount;

    BIS_COLLECTION_UTILITIES.PUT_LINE('Finished extraction of MTL USAGE ACTUALS Table: '|| l_row_count || ' rows inserted');
    BIS_COLLECTION_UTILITIES.PUT_LINE('Exiting Procedure '|| l_proc_name);

EXCEPTION

    WHEN OTHERS THEN

    	rollback;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,l_stmt_num));

	retcode := SQLCODE;
   	errbuf := SQLERRM;

END GET_OPI_MTL_USAGE_ACT_INIT;

/*
   Procedure Merges the Material Usage Fact from the Jobs Transaction Staging table for OPM and ODM,
   Incremental Load procedure

   Parameters:
   retcode - 0 on successful completion, -1 on error and 1 for warning.
   errbuf - empty on successful completion, message on error or warning
*/

PROCEDURE GET_OPI_MTL_USAGE_ACT_INCR(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
 l_stmt_num NUMBER;
 l_row_count NUMBER;
 l_err_num NUMBER;
 l_err_msg VARCHAR2(255);
 l_proc_name VARCHAR2(255);
 l_status VARCHAR2(30);
 l_industry VARCHAR2(30);
 l_opi_schema VARCHAR2(30);

BEGIN

    l_proc_name := 'OPI_DBI_JOB_TXN_STG_PKG.GET_OPI_MTL_USAGE_ACT_INCR';

    BIS_COLLECTION_UTILITIES.PUT_LINE('Entering Procedure '|| l_proc_name);

    /* Extraction of MTL Usage Actuals fact */
    l_stmt_num := 20;
    MERGE
    INTO OPI_DBI_JOB_MTL_DETAILS_F fact USING
    (
    select
       jobs_txn.organization_id organization_id,
       job_id job_id,
       job_type job_type,
       assembly_item_id assembly_item_id,
       component_item_id component_item_id,
       uom_code uom_code,
       line_type line_type,
       trunc(jobs_txn.transaction_date) transaction_date,
       0 standard_value_b,
       sum(transaction_value_b+transaction_value_draft_b) actual_value_b,
       sum(transaction_value_draft_b) actual_value_draft_b,
       0 standard_quantity,
       sum(primary_quantity+primary_quantity_draft) actual_quantity,
       sum(primary_quantity_draft) actual_quantity_draft,
       source source,
       s_sysdate creation_date,
       s_sysdate last_update_date,
       s_user_id created_by,
       s_user_id last_updated_by,
       s_login_id last_update_login,
       sum((transaction_value_b+transaction_value_draft_b)*crates.conversion_rate) actual_value_g,
       sum(transaction_value_draft_b*crates.conversion_rate) actual_value_draft_g,
       sum((transaction_value_b+transaction_value_draft_b)*crates.sec_conversion_rate) actual_value_sg,
       sum(transaction_value_draft_b*crates.sec_conversion_rate) actual_value_draft_sg,
       s_program_id PROGRAM_ID,
       s_program_login_id PROGRAM_LOGIN_ID,
       s_program_application_id PROGRAM_APPLICATION_ID,
       s_request_id REQUEST_ID
    from
       OPI_DBI_JOBS_TXN_STG jobs_txn,
       opi_dbi_muv_conv_rates crates
    where
       etl_type_id = 1 and
       crates.organization_id = jobs_txn.organization_id and
       trunc(jobs_txn.transaction_date) = crates.transaction_date
    group by
       jobs_txn.organization_id,
       job_id,
       job_type,
       assembly_item_id,
       component_item_id,
       uom_code,
       line_type,
       trunc(jobs_txn.transaction_date),
       source
    )stg
    ON
    (
    	fact.organization_id = stg.organization_id and
    	fact.job_id = stg.job_id and
    	fact.job_type = stg.job_type and
    	fact.assembly_item_id = stg.assembly_item_id and
    	fact.component_item_id = stg.component_item_id and
    	fact.line_type = stg.line_type and
    	fact.transaction_date = stg.transaction_date and
    	fact.uom_code = stg.uom_code and
    	fact.source = stg.source
    )
    WHEN MATCHED THEN
    	UPDATE SET
    	fact.actual_quantity = fact.actual_quantity + stg.actual_quantity - fact.actual_quantity_draft,
    	fact.actual_quantity_draft = stg.actual_quantity_draft,
    	fact.actual_value_b = fact.actual_value_b + stg.actual_value_b - fact.actual_value_draft_b,
    	fact.actual_value_draft_b = stg.actual_value_draft_b,
    	fact.actual_value_g = fact.actual_value_g + stg.actual_value_g - fact.actual_value_draft_g,
    	fact.actual_value_draft_g = stg.actual_value_draft_g,
    	fact.actual_value_sg = fact.actual_value_sg + stg.actual_value_b - fact.actual_value_draft_sg,
    	fact.actual_value_draft_sg = stg.actual_value_draft_sg,
    	fact.creation_date = stg.creation_date,
    	fact.last_update_date = stg.last_update_date,
    	fact.created_by = stg.created_by,
    	fact.last_updated_by = stg.last_updated_by,
    	fact.last_update_login = stg.last_update_login,
    	fact.PROGRAM_ID = stg.PROGRAM_ID,
	fact.PROGRAM_LOGIN_ID = stg.PROGRAM_LOGIN_ID,
	fact.PROGRAM_APPLICATION_ID = stg.PROGRAM_APPLICATION_ID,
	fact.REQUEST_ID = stg.REQUEST_ID
     WHEN NOT MATCHED THEN
     INSERT(
        organization_id,
	job_id,
	job_type,
	assembly_item_id,
	component_item_id,
	uom_code,
	line_type,
	transaction_date,
	standard_value_b,
	actual_value_b,
	actual_value_draft_b,
	standard_quantity,
	actual_quantity,
	actual_quantity_draft,
	source,
	creation_date,
	last_update_date,
	created_by,
	last_updated_by,
        last_update_login,
        actual_value_g,
	actual_value_draft_g,
	actual_value_sg,
	actual_value_draft_sg,
	PROGRAM_ID,
	PROGRAM_LOGIN_ID,
	PROGRAM_APPLICATION_ID,
	REQUEST_ID
     )
     VALUES
     (
        stg.organization_id,
     	stg.job_id,
     	stg.job_type,
     	stg.assembly_item_id,
     	stg.component_item_id,
     	stg.uom_code,
     	stg.line_type,
     	stg.transaction_date,
     	stg.standard_value_b,
     	stg.actual_value_b,
     	stg.actual_value_draft_b,
     	stg.standard_quantity,
     	stg.actual_quantity,
     	stg.actual_quantity_draft,
     	stg.source,
     	stg.creation_date,
     	stg.last_update_date,
     	stg.created_by,
     	stg.last_updated_by,
        stg.last_update_login,
        stg.actual_value_g,
     	stg.actual_value_draft_g,
     	stg.actual_value_sg,
	stg.actual_value_draft_sg,
	stg.PROGRAM_ID,
	stg.PROGRAM_LOGIN_ID,
	stg.PROGRAM_APPLICATION_ID,
	stg.REQUEST_ID
     );

    l_row_count := sql%rowcount;

    BIS_COLLECTION_UTILITIES.PUT_LINE('Finished extraction of MTL USAGE ACTUALS Table: '|| l_row_count || ' rows inserted/updated');
    BIS_COLLECTION_UTILITIES.PUT_LINE('Exiting Procedure '|| l_proc_name);


EXCEPTION

    WHEN OTHERS THEN

    	rollback;

       	BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,l_stmt_num));

	retcode := SQLCODE;
   	errbuf := SQLERRM;

END GET_OPI_MTL_USAGE_ACT_INCR;

/*
   Procedure populates the Material Usage Standards Fact from the Material Usage Actuals fact
   for ODM, Initial Load procedure

   Parameters:
   retcode - 0 on successful completion, -1 on error and 1 for warning.
   errbuf - empty on successful completion, message on error or warning
*/

PROCEDURE GET_OPI_ODM_MTL_USAGE_STD_INIT(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
 l_stmt_num NUMBER;
 l_row_count NUMBER;
 l_err_num NUMBER;
 l_err_msg VARCHAR2(255);
 l_proc_name VARCHAR2(255);
 l_status VARCHAR2(30);
 l_industry VARCHAR2(30);
 l_opi_schema VARCHAR2(30);

BEGIN

    l_proc_name := 'OPI_DBI_JOB_TXN_STG_PKG.GET_OPI_ODM_MTL_USAGE_STD_INIT';

    BIS_COLLECTION_UTILITIES.PUT_LINE('Entering Procedure '|| l_proc_name);

    /* ODM insert into temp table */
    l_stmt_num := 20;
    INSERT
    INTO OPI_DBI_JOB_MTL_STD_QTY_TMP
    (ORGANIZATION_ID,
     INVENTORY_ITEM_ID,
     JOB_ID,
     JOB_TYPE,
     Standard_Quantity
    )
     SELECT
     	ORGANIZATION_ID,
        INVENTORY_ITEM_ID,
        JOB_ID,
        JOB_TYPE,
        Standard_Quantity
     FROM
     (
     	SELECT /* Standard Quantities for Discrete */
     	   WRO.ORGANIZATION_ID,
           WRO.INVENTORY_ITEM_ID,
           WRO.WIP_ENTITY_ID JOB_ID,
           decode(WE.ENTITY_TYPE,5,5,8,5,1) JOB_TYPE,
           SUM(WRO.REQUIRED_QUANTITY) Standard_Quantity
        FROM
           WIP_ENTITIES WE,
           WIP_REQUIREMENT_OPERATIONS WRO
        WHERE
           WRO.ORGANIZATION_ID = WE.ORGANIZATION_ID AND
           WRO.WIP_ENTITY_ID = WE.WIP_ENTITY_ID AND
           WE.ENTITY_TYPE in (1,3,5,8) AND
           WE.WIP_ENTITY_ID in (SELECT JOB_ID FROM OPI_DBI_JOBS_F WHERE Std_Req_Flag=1 AND JOB_TYPE in (1,5))
        GROUP BY
           WRO.ORGANIZATION_ID,
           WRO.INVENTORY_ITEM_ID,
           WRO.WIP_ENTITY_ID,
           WE.ENTITY_TYPE
        UNION ALL
        SELECT /* Standard Quantities for Repetitive */
           WRO.ORGANIZATION_ID,
           WRO.INVENTORY_ITEM_ID,
           WRO.REPETITIVE_SCHEDULE_ID JOB_ID,
           2 JOB_TYPE,
           SUM(WRO.REQUIRED_QUANTITY) Standard_Quantity
        FROM
           WIP_ENTITIES WE,
           WIP_REQUIREMENT_OPERATIONS WRO
        WHERE
           WRO.ORGANIZATION_ID = WE.ORGANIZATION_ID AND
           WRO.WIP_ENTITY_ID = WE.WIP_ENTITY_ID AND
           WE.ENTITY_TYPE = 2 AND
           WRO.REPETITIVE_SCHEDULE_ID in (SELECT JOB_ID FROM OPI_DBI_JOBS_F WHERE Std_Req_Flag=1 AND JOB_TYPE=2)
        GROUP BY
           WRO.ORGANIZATION_ID,
           WRO.INVENTORY_ITEM_ID,
           WRO.REPETITIVE_SCHEDULE_ID
        UNION ALL
        SELECT /* Standard Quantities for Flow
                  Standard Qty for each component in BOM is multiplied with the planned
                  qty from wfs for the assembly to get the standard qty for each component.
                */
           wfs.organization_id,
           bom_join.component_item_id inventory_item_id,
           wfs.wip_entity_id JOB_ID,
           3 JOB_TYPE,
           SUM(bom_join.Standard_Quantity) * wfs.PLANNED_QUANTITY  Standard_Quantity
        FROM
           ( select  /*+ index(bb) */
             	bb.organization_id organization_id,
                bb.assembly_item_id assembly_item_id,
                bic.component_item_id component_item_id,
                bic.effectivity_date effectivity_date,
                bb.alternate_bom_designator alternate_bom_designator,
                bic.disable_date disable_date,
                nvl(lead(bic.effectivity_date) OVER
                	(partition by bb.organization_id,
                	              bb.assembly_item_id,
                                      bb.alternate_bom_designator,
                                      bic.component_item_id,
                                      bic.operation_seq_num
                         order by effectivity_date), sysdate) last_rev,
                bic.component_quantity Standard_Quantity
             from
                bom_bill_of_materials bb,
                bom_inventory_components bic
             where
                bb.COMMON_BILL_SEQUENCE_ID = bic.bill_sequence_id and
                bic.implementation_date is not null
            ) bom_join,
            wip_flow_schedules wfs
        WHERE
            EFFECTIVITY_DATE <= wfs.scheduled_completion_date and
            last_rev > decode (sign(wfs.scheduled_completion_date - nvl(wfs.date_closed,wfs.scheduled_completion_date)),1,wfs.date_closed,wfs.scheduled_completion_date)  and
            decode (sign(wfs.scheduled_completion_date - nvl(wfs.date_closed,wfs.scheduled_completion_date)),1,wfs.date_closed,wfs.scheduled_completion_date)  < nvl(bom_join.disable_date, sysdate) and
            wfs.organization_id = bom_join.organization_id and
            wfs.PRIMARY_ITEM_ID = bom_join.assembly_item_id and
            nvl(wfs.alternate_bom_designator,1) = nvl(bom_join.alternate_bom_designator,1) and
            WFS.WIP_ENTITY_ID in (SELECT JOB_ID FROM OPI_DBI_JOBS_F WHERE Std_Req_Flag=1 AND
            			  JOB_TYPE=3)
        GROUP BY
            wfs.organization_id,
            bom_join.component_item_id,
            wfs.wip_entity_id,
            wfs.PLANNED_QUANTITY);

    /* ODM Standards insert into fact table */
    l_stmt_num := 30;
    INSERT
    INTO OPI_DBI_JOB_MTL_DTL_STD_F
    (
    	organization_id,
    	job_id,
    	job_type,
    	assembly_item_id,
    	component_item_id,
    	line_type,
    	standard_quantity,
    	standard_value_b,
    	source,
    	creation_date,
	last_update_date,
	created_by,
	last_updated_by,
    	last_update_login,
    	PROGRAM_ID,
	PROGRAM_LOGIN_ID,
	PROGRAM_APPLICATION_ID,
	REQUEST_ID
    )
    select
        actuals.organization_id,
        actuals.job_id,
        actuals.job_type,
        actuals.assembly_item_id,
        actuals.component_item_id,
        actuals.line_type,
        tmp.standard_quantity,
        Decode(actuals.actual_quantity, 0,
          tmp.standard_quantity*OPI_DBI_JOBS_PKG.GET_ODM_ITEM_COST
                                        (actuals.organization_id,
        			         actuals.component_item_id),
          tmp.standard_quantity*(actual_value_b/actual_quantity)),
        actuals.source,
        s_sysdate,
	s_sysdate,
	s_user_id,
	s_user_id,
    	s_login_id,
    	s_program_id,
	s_program_login_id,
	s_program_application_id,
	s_request_id
    from
    	OPI_DBI_JOB_MTL_STD_QTY_TMP tmp,
    	(select
    		job_id,
    		job_type,
    		organization_id,
    		assembly_item_id,
    		component_item_id,
    		line_type,
    		source,
    		sum(actual_quantity) actual_quantity,
    		sum(actual_value_b) actual_value_b
         from
         	OPI_DBI_JOB_MTL_DETAILS_F
         where
         	source = 1
         group by
         	organization_id,
         	job_id,
         	assembly_item_id,
         	component_item_id,
         	line_type,
         	job_type,
         	source
         )actuals
    where
    	tmp.organization_id = actuals.organization_id and
    	tmp.job_id = actuals.job_id and
    	tmp.inventory_item_id = actuals.component_item_id and
    	tmp.job_type = actuals.job_type;

    l_row_count := sql%rowcount;

    BIS_COLLECTION_UTILITIES.PUT_LINE('Finished extraction of ODM MTL USAGE Standards Table: '|| l_row_count || ' rows inserted');
    BIS_COLLECTION_UTILITIES.PUT_LINE('Exiting Procedure '|| l_proc_name);

EXCEPTION

    WHEN OTHERS THEN

    	rollback;

       	BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,l_stmt_num));

	retcode := SQLCODE;
        errbuf := SQLERRM;

 END GET_OPI_ODM_MTL_USAGE_STD_INIT;

 /*
    Procedure populates the Material Usage Standards Fact from the Material Usage Actuals fact
    for ODM, Incremental Load procedure

    Parameters:
      retcode - 0 on successful completion, -1 on error and 1 for warning.
      errbuf - empty on successful completion, message on error or warning
*/

PROCEDURE GET_OPI_ODM_MTL_USAGE_STD_INCR(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
 l_stmt_num NUMBER;
 l_row_count NUMBER;
 l_err_num NUMBER;
 l_err_msg VARCHAR2(255);
 l_proc_name VARCHAR2(255);
 l_status VARCHAR2(30);
 l_industry VARCHAR2(30);
 l_opi_schema VARCHAR2(30);

BEGIN

    l_proc_name := 'OPI_DBI_JOB_TXN_STG_PKG.GET_OPI_ODM_MTL_USAGE_STD_INCR';

    BIS_COLLECTION_UTILITIES.PUT_LINE('Entering Procedure '|| l_proc_name);

    /* ODM insert into temp table */
    l_stmt_num := 20;
    INSERT
    INTO OPI_DBI_JOB_MTL_STD_QTY_TMP
    (ORGANIZATION_ID,
     INVENTORY_ITEM_ID,
     JOB_ID,
     JOB_TYPE,
     Standard_Quantity
    )
     SELECT
     	ORGANIZATION_ID,
        INVENTORY_ITEM_ID,
        JOB_ID,
        JOB_TYPE,
        Standard_Quantity
     FROM
     (
     	SELECT /* Standard Quantities for Discrete */
     	   WRO.ORGANIZATION_ID,
           WRO.INVENTORY_ITEM_ID,
           WRO.WIP_ENTITY_ID JOB_ID,
           decode(WE.ENTITY_TYPE,5,5,8,5,1) JOB_TYPE,
           SUM(WRO.REQUIRED_QUANTITY) Standard_Quantity
        FROM
           WIP_ENTITIES WE,
           WIP_REQUIREMENT_OPERATIONS WRO
        WHERE
           WRO.ORGANIZATION_ID = WE.ORGANIZATION_ID AND
           WRO.WIP_ENTITY_ID = WE.WIP_ENTITY_ID AND
           WE.ENTITY_TYPE in (1,3,5,8) AND
           WE.WIP_ENTITY_ID in (SELECT JOB_ID FROM OPI_DBI_JOBS_F WHERE Std_Req_Flag=1 AND JOB_TYPE in (1,5))
        GROUP BY
           WRO.ORGANIZATION_ID,
           WRO.INVENTORY_ITEM_ID,
           WRO.WIP_ENTITY_ID,
           WE.ENTITY_TYPE
        UNION ALL
        SELECT /* Standard Quantities for Repetitive */
           WRO.ORGANIZATION_ID,
           WRO.INVENTORY_ITEM_ID,
           WRO.REPETITIVE_SCHEDULE_ID JOB_ID,
           2 JOB_TYPE,
           SUM(WRO.REQUIRED_QUANTITY) Standard_Quantity
        FROM
           WIP_ENTITIES WE,
           WIP_REQUIREMENT_OPERATIONS WRO
        WHERE
           WRO.ORGANIZATION_ID = WE.ORGANIZATION_ID AND
           WRO.WIP_ENTITY_ID = WE.WIP_ENTITY_ID AND
           WE.ENTITY_TYPE = 2 AND
           WRO.REPETITIVE_SCHEDULE_ID in (SELECT JOB_ID FROM OPI_DBI_JOBS_F WHERE Std_Req_Flag=1 AND JOB_TYPE=2)
        GROUP BY
           WRO.ORGANIZATION_ID,
           WRO.INVENTORY_ITEM_ID,
           WRO.REPETITIVE_SCHEDULE_ID
        UNION ALL
        SELECT /* Standard Quantities for Flow */
           wfs.organization_id,
           t.component_item_id inventory_item_id,
           wfs.wip_entity_id JOB_ID,
           3 JOB_TYPE,
           SUM(t.Standard_Quantity) * wfs.PLANNED_QUANTITY  Standard_Quantity
        FROM
           ( select  /*+ index(bb) */
             	bb.organization_id organization_id,
                bb.assembly_item_id assembly_item_id,
                bic.component_item_id component_item_id,
                bic.effectivity_date effectivity_date,
                bb.alternate_bom_designator alternate_bom_designator,
                bic.disable_date disable_date,
                nvl(lead(bic.effectivity_date) OVER
                	(partition by bb.organization_id,
                	              bb.assembly_item_id,
                                      bb.alternate_bom_designator,
                                      bic.component_item_id,
                                      bic.operation_seq_num
                         order by effectivity_date), sysdate) last_rev,
                bic.component_quantity Standard_Quantity
             from
                bom_bill_of_materials bb,
                bom_inventory_components bic
             where
                bb.COMMON_BILL_SEQUENCE_ID = bic.bill_sequence_id and
                bic.implementation_date is not null
            ) t,
            wip_flow_schedules wfs
        WHERE
            EFFECTIVITY_DATE <= wfs.scheduled_completion_date and
            last_rev > decode (sign(wfs.scheduled_completion_date - nvl(wfs.date_closed,wfs.scheduled_completion_date)),1,wfs.date_closed,wfs.scheduled_completion_date)  and
            decode (sign(wfs.scheduled_completion_date - nvl(wfs.date_closed,wfs.scheduled_completion_date)),1,wfs.date_closed,wfs.scheduled_completion_date)  < nvl(t.disable_date, sysdate) and
            wfs.organization_id = t.organization_id and
            wfs.PRIMARY_ITEM_ID = t.assembly_item_id and
            nvl(wfs.alternate_bom_designator,1) = nvl(t.alternate_bom_designator,1) and
            WFS.WIP_ENTITY_ID in (SELECT JOB_ID FROM OPI_DBI_JOBS_F WHERE Std_Req_Flag=1 AND
            			  JOB_TYPE=3)
        GROUP BY
            wfs.organization_id,
            t.component_item_id,
            wfs.wip_entity_id,
            wfs.PLANNED_QUANTITY);

    /* ODM Standards merge into fact table */
    l_stmt_num := 30;
    MERGE
    INTO OPI_DBI_JOB_MTL_DTL_STD_F fact using
    (
    	select
            actuals.organization_id organization_id,
            actuals.job_id job_id,
            actuals.job_type job_type,
            actuals.assembly_item_id assembly_item_id,
            actuals.component_item_id component_item_id,
            actuals.line_type line_type,
            tmp.standard_quantity standard_quantity,
            Decode(actuals.actual_quantity, 0,
              tmp.standard_quantity*OPI_DBI_JOBS_PKG.GET_ODM_ITEM_COST
              				   (actuals.organization_id,
            	                            actuals.component_item_id),
              tmp.standard_quantity*(actual_value_b/actual_quantity))
            			standard_value_b,
            actuals.source source,
            s_sysdate creation_date,
    	    s_sysdate last_update_date,
            s_user_id created_by,
            s_user_id last_updated_by,
            s_login_id last_update_login,
            s_program_id PROGRAM_ID,
	    s_program_login_id PROGRAM_LOGIN_ID,
	    s_program_application_id PROGRAM_APPLICATION_ID,
	    s_request_id REQUEST_ID
        from
     	    OPI_DBI_JOB_MTL_STD_QTY_TMP tmp,
            (select
       		job_id,
       		job_type,
       		organization_id,
       		assembly_item_id,
       		component_item_id,
       		line_type,
       		source,
       		sum(actual_quantity) actual_quantity,
       		sum(actual_value_b) actual_value_b
             from
             	OPI_DBI_JOB_MTL_DETAILS_F
             where
             	source = 1
             group by
             	organization_id,
             	job_id,
             	assembly_item_id,
             	component_item_id,
             	line_type,
             	job_type,
             	source
             )actuals
        where
       	   tmp.organization_id = actuals.organization_id and
           tmp.job_id = actuals.job_id and
           tmp.inventory_item_id = actuals.component_item_id and
    	   tmp.job_type = actuals.job_type
    )stg
    ON
    (
    	fact.organization_id = stg.organization_id and
    	fact.job_id = stg.job_id and
    	fact.job_type = stg.job_type and
    	fact.assembly_item_id = stg.assembly_item_id and
    	fact.component_item_id = stg.component_item_id and
    	fact.line_type = stg.line_type and
    	fact.source = stg.source
    )
    WHEN MATCHED THEN
    UPDATE SET
    	fact.standard_quantity = stg.standard_quantity,
    	fact.standard_value_b = stg.standard_value_b,
    	fact.creation_date = stg.creation_date,
    	fact.last_update_date = stg.last_update_date,
    	fact.created_by = stg.created_by,
    	fact.last_updated_by = stg.last_updated_by,
    	fact.last_update_login = stg.last_update_login,
    	fact.PROGRAM_ID = stg.PROGRAM_ID,
    	fact.PROGRAM_LOGIN_ID = stg.PROGRAM_LOGIN_ID,
    	fact.PROGRAM_APPLICATION_ID = stg.PROGRAM_APPLICATION_ID,
    	fact.REQUEST_ID = stg.REQUEST_ID
    WHEN NOT MATCHED THEN
    INSERT
    (
    	organization_id,
       	job_id,
       	job_type,
       	assembly_item_id,
       	component_item_id,
       	line_type,
       	standard_quantity,
       	standard_value_b,
       	source,
       	creation_date,
    	last_update_date,
    	created_by,
    	last_updated_by,
    	last_update_login,
    	PROGRAM_ID,
	PROGRAM_LOGIN_ID,
	PROGRAM_APPLICATION_ID,
	REQUEST_ID
    )
    VALUES
    (
    	stg.organization_id,
       	stg.job_id,
       	stg.job_type,
       	stg.assembly_item_id,
       	stg.component_item_id,
       	stg.line_type,
       	stg.standard_quantity,
       	stg.standard_value_b,
       	stg.source,
       	stg.creation_date,
    	stg.last_update_date,
    	stg.created_by,
    	stg.last_updated_by,
    	stg.last_update_login,
    	stg.PROGRAM_ID,
	stg.PROGRAM_LOGIN_ID,
	stg.PROGRAM_APPLICATION_ID,
	stg.REQUEST_ID
    );

    l_row_count := sql%rowcount;

    BIS_COLLECTION_UTILITIES.PUT_LINE('Finished extraction of ODM MTL USAGE Standards Table: '|| l_row_count || ' rows inserted');
    BIS_COLLECTION_UTILITIES.PUT_LINE('Exiting Procedure '|| l_proc_name);

EXCEPTION

    WHEN OTHERS THEN

        rollback;

   	BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,l_stmt_num));

	retcode := SQLCODE;
   	errbuf := SQLERRM;

 END GET_OPI_ODM_MTL_USAGE_STD_INCR;

/*
   Procedure populates the Material Usage Standards Fact from the Material Usage Actuals fact
   for OPM, Initial Load procedure

   Parameters:
     retcode - 0 on successful completion, -1 on error and 1 for warning.
     errbuf - empty on successful completion, message on error or warning
*/

PROCEDURE GET_OPI_OPM_MTL_USAGE_STD_INIT(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
 l_stmt_num NUMBER;
 l_row_count NUMBER;
 l_err_num NUMBER;
 l_err_msg VARCHAR2(255);
 l_proc_name VARCHAR2(255);
 l_status VARCHAR2(30);
 l_industry VARCHAR2(30);
 l_opi_schema VARCHAR2(30);

BEGIN

    l_proc_name := 'OPI_DBI_JOB_TXN_STG_PKG.GET_OPI_OPM_MTL_USAGE_STD_INIT';

    BIS_COLLECTION_UTILITIES.PUT_LINE('Entering Procedure '|| l_proc_name);

/* OPM Standards insert into fact table */
/* Actuals fact which is at transaction date level is summarised and joined with the
   scaled mtl table, standard value is calculated as actual-value* std_qty/actual_qty */
    l_stmt_num  := 40;
    INSERT
    INTO OPI_DBI_JOB_MTL_DTL_STD_F
    (
    	organization_id,
       	job_id,
       	job_type,
       	assembly_item_id,
       	component_item_id,
       	line_type,
       	standard_quantity,
       	standard_value_b,
       	source,
       	creation_date,
    	last_update_date,
    	created_by,
    	last_updated_by,
    	last_update_login,
    	PROGRAM_ID,
	PROGRAM_LOGIN_ID,
	PROGRAM_APPLICATION_ID,
	REQUEST_ID
    )
    select
    	tmp.organization_id,
    	tmp.batch_id,
    	tmp.job_type,
    	tmp.coproduct_id,
    	tmp.item_id,
    	actuals.line_type,
    	sum(tmp.scaled_plan_qty*decode(actuals.line_type,2,-1,1)),
    	sum(decode(actuals.actual_qty,0,
    		OPI_DBI_JOBS_PKG.GET_OPM_ITEM_COST(tmp.organization_id,
    				        	   tmp.item_id,
    				                   tmp.completion_date),
                actuals.actual_value_b*tmp.scaled_plan_qty/actuals.actual_qty)
                *decode(actuals.line_type,2,-1,1)),
        actuals.source,
        s_sysdate,
	s_sysdate,
	s_user_id,
	s_user_id,
    	s_login_id,
    	s_program_id,
	s_program_login_id,
	s_program_application_id,
	s_request_id
    from
    	OPI_DBI_OPM_SCALED_MTL tmp,
    	(
    	select
    		job_id,
    		job_type,
    		organization_id,
    		assembly_item_id,
    		component_item_id,
    		line_type,
    		source,
    		sum(actual_quantity) actual_qty,
    		sum(actual_value_b) actual_value_b
    	from
    		OPI_DBI_JOB_MTL_DETAILS_F
    	where
    		source in(2,3)
    	group by
    		job_id,
    		job_type,
    		organization_id,
    		assembly_item_id,
    		component_item_id,
    		line_type,
    		source
    	)actuals
    where
    	tmp.organization_id = actuals.organization_id and
    	tmp.batch_id = actuals.job_id and
    	tmp.job_type = actuals.job_type and
    	tmp.coproduct_id = actuals.assembly_item_id and
    	tmp.item_id = actuals.component_item_id and
    	tmp.line_type = actuals.line_type
    group by
    	tmp.organization_id,
    	tmp.batch_id,
    	tmp.job_type,
    	tmp.coproduct_id,
    	tmp.item_id,
    	actuals.line_type,
    	actuals.source;

    l_row_count := sql%rowcount;

    BIS_COLLECTION_UTILITIES.PUT_LINE('Finished extraction of OPM MTL USAGE Standards Table: '|| l_row_count || ' rows inserted');
    BIS_COLLECTION_UTILITIES.PUT_LINE('Exiting Procedure '|| l_proc_name);

EXCEPTION

    WHEN OTHERS THEN

        rollback;

    	BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,l_stmt_num));

	retcode := SQLCODE;
   	errbuf := SQLERRM;

END GET_OPI_OPM_MTL_USAGE_STD_INIT;

/*
   Procedure populates the Material Usage Standards Fact from the Material Usage Actuals fact
   for OPM, Incremental Load procedure

   Parameters:
      retcode - 0 on successful completion, -1 on error and 1 for warning.
      errbuf - empty on successful completion, message on error or warning
*/

PROCEDURE GET_OPI_OPM_MTL_USAGE_STD_INCR(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
 l_stmt_num NUMBER;
 l_row_count NUMBER;
 l_err_num NUMBER;
 l_err_msg VARCHAR2(255);
 l_proc_name VARCHAR2(255);
 l_status VARCHAR2(30);
 l_industry VARCHAR2(30);
 l_opi_schema VARCHAR2(30);

BEGIN

    l_proc_name := 'OPI_DBI_JOB_TXN_STG_PKG.GET_OPI_OPM_MTL_USAGE_STD_INCR';

    BIS_COLLECTION_UTILITIES.PUT_LINE('Entering Procedure '|| l_proc_name);

/* OPM Standards insert into fact table */
    l_stmt_num  := 40;
    MERGE
    INTO OPI_DBI_JOB_MTL_DTL_STD_F fact using
    (
    select
       	tmp.organization_id organization_id,
       	tmp.batch_id job_id,
       	tmp.job_type job_type,
       	tmp.coproduct_id assembly_item_id,
       	tmp.item_id component_item_id,
       	actuals.line_type line_type,
       	sum(tmp.scaled_plan_qty*decode(actuals.line_type,2,-1,1)) standard_quantity,
       	sum(decode(actuals.actual_qty,0,
       		OPI_DBI_JOBS_PKG.GET_OPM_ITEM_COST(tmp.organization_id,
       				        	   tmp.item_id,
       				                   tmp.completion_date),
        	actuals.actual_value_b*tmp.scaled_plan_qty/actuals.actual_qty)
        	*decode(actuals.line_type,2,-1,1)) standard_value_b,
        actuals.source source,
        s_sysdate creation_date,
    	s_sysdate last_update_date,
    	s_user_id created_by,
    	s_user_id last_updated_by,
      	s_login_id last_update_login,
      	s_program_id PROGRAM_ID,
	s_program_login_id PROGRAM_LOGIN_ID,
	s_program_application_id PROGRAM_APPLICATION_ID,
	s_request_id REQUEST_ID
    from
      	OPI_DBI_OPM_SCALED_MTL tmp,
      	(
       	select
    	  job_id,
       	  job_type,
       	  organization_id,
       	  assembly_item_id,
          component_item_id,
          line_type,
          source,
          sum(actual_quantity) actual_qty,
          sum(actual_value_b) actual_value_b
        from
          OPI_DBI_JOB_MTL_DETAILS_F
        where
          source in(2,3)
        group by
          job_id,
          job_type,
          organization_id,
          assembly_item_id,
          component_item_id,
          line_type,
          source
        )actuals
    where
       	tmp.organization_id = actuals.organization_id and
       	tmp.batch_id = actuals.job_id and
       	tmp.job_type = actuals.job_type and
       	tmp.coproduct_id = actuals.assembly_item_id and
       	tmp.item_id = actuals.component_item_id and
       	tmp.line_type = actuals.line_type
    group by
       	tmp.organization_id,
       	tmp.batch_id,
       	tmp.job_type,
       	tmp.coproduct_id,
       	tmp.item_id,
       	actuals.line_type,
    	actuals.source
    )stg
    ON
    (	fact.organization_id = stg.organization_id and
    	fact.job_id = stg.job_id and
    	fact.job_type = stg.job_type and
    	fact.assembly_item_id = stg.assembly_item_id and
    	fact.component_item_id = stg.component_item_id and
    	fact.line_type = stg.line_type and
    	fact.source = stg.source
    )
    WHEN MATCHED THEN
    UPDATE SET
    	fact.standard_quantity =  stg.standard_quantity,
    	fact.standard_value_b = stg.standard_value_b,
    	fact.last_update_date = stg.last_update_date,
	fact.last_updated_by = stg.last_updated_by,
	fact.last_update_login = stg.last_update_login
    WHEN NOT MATCHED THEN
    INSERT
    (
    	organization_id,
       	job_id,
       	job_type,
       	assembly_item_id,
       	component_item_id,
       	line_type,
       	standard_quantity,
       	standard_value_b,
       	source,
       	creation_date,
    	last_update_date,
    	created_by,
    	last_updated_by,
    	last_update_login,
    	PROGRAM_ID,
	PROGRAM_LOGIN_ID,
	PROGRAM_APPLICATION_ID,
	REQUEST_ID
    )
    VALUES
    (
    	stg.organization_id,
       	stg.job_id,
       	stg.job_type,
       	stg.assembly_item_id,
       	stg.component_item_id,
       	stg.line_type,
       	stg.standard_quantity,
       	stg.standard_value_b,
       	stg.source,
       	stg.creation_date,
      	stg.last_update_date,
       	stg.created_by,
       	stg.last_updated_by,
    	stg.last_update_login,
    	stg.PROGRAM_ID,
	stg.PROGRAM_LOGIN_ID,
	stg.PROGRAM_APPLICATION_ID,
	stg.REQUEST_ID
    );

    l_row_count := sql%rowcount;

    BIS_COLLECTION_UTILITIES.PUT_LINE('Finished extraction of OPM MTL USAGE Standards Table: '|| l_row_count || ' rows inserted');
    BIS_COLLECTION_UTILITIES.PUT_LINE('Exiting Procedure '|| l_proc_name);

EXCEPTION

    WHEN OTHERS THEN

        rollback;

    	BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,l_stmt_num));

	retcode := SQLCODE;
   	errbuf := SQLERRM;

END GET_OPI_OPM_MTL_USAGE_STD_INCR;

/*
   Procedure populates temp table OPI_DBI_OPM_SCALED_MTL used to get the planned_qty for OPM,
   Initial Load procedure

   Parameters:
   retcode - 0 on successful completion, -1 on error and 1 for warning.
   errbuf - empty on successful completion, message on error or warning
*/

PROCEDURE GET_OPI_SCALED_MTL_INIT(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
 l_stmt_num NUMBER;
 l_line_count     number;
 l_row_count NUMBER;
 l_err_num NUMBER;
 l_err_msg VARCHAR2(255);
 l_proc_name VARCHAR2(255);
 l_status VARCHAR2(30);
 l_industry VARCHAR2(30);
 l_opi_schema VARCHAR2(30);
 l_batch_id NUMBER;
 l_org_id NUMBER;
 l_item_id NUMBER;
 l_cost_alloc NUMBER;
 l_coproduct_id   NUMBER;
 i NUMBER;
 j NUMBER;
 k NUMBER;
 x_scale_factor   number;
 x_return_status  VARCHAR2 (80);
 l_scale_tab      gmd_common_scale.scale_tab;
 x_scale_tab      gmd_common_scale.scale_tab;
 empty_scale_tab  gmd_common_scale.scale_tab;

 cursor cur_get_batch
 is
 	select
 		jobs.job_id job_id,
 		jobs.organization_id organization_id,
 		jobs.assembly_item_id,
 		mtl_dtl.cost_alloc cost_alloc
 	from
 		opi_dbi_jobs_f jobs,
 		gme_material_details mtl_dtl
 	where
 		jobs.source in (2,3) and
 		jobs.job_type = 4 and
 		jobs.status = 'Closed' and
 		jobs.line_type = 1 and
 		jobs.organization_id = mtl_dtl.organization_id and
 		jobs.job_id = mtl_dtl.batch_id and
 		jobs.assembly_item_id = mtl_dtl.inventory_item_id and
 		mtl_dtl.line_type = 1;


 cursor cur_get_mtl(job_id_in IN NUMBER, org_id_in IN NUMBER,
 		     item_id_in IN NUMBER, cost_alloc_in IN NUMBER)
 is
 	select
          job.Organization_Id            Organization_Id,
          job.job_type                   Job_Type,
          dtl.batch_id,
          job.completion_date		 completion_date,
          job.assembly_item_id           coproduct_id,
          dtl.material_detail_id         material_detail_id,
          job.start_quantity             coproduct_plan_qty,
          job.actual_qty_completed       coproduct_actual_qty,
          NULL                           scaled_plan_qty,
          dtl.actual_qty,
          dtl.dtl_um,
          dtl.scale_type,
          dtl.contribute_yield_ind,
          dtl.scale_multiple,
          dtl.scale_rounding_variance,
          dtl.rounding_direction,
          dtl.line_no,
          dtl.line_type,
          dtl.inventory_item_id ,
          dtl.plan_qty,
          cost_alloc_in
        from
          OPI_DBI_JOBS_F       job,
          gme_material_details dtl
        where
          job.job_id           = dtl.batch_id
          and job.status          = 'Closed'
          and dtl.line_type in (-1,2)
          and job.job_id = job_id_in
          and job.organization_id = org_id_in
          and job.assembly_item_id = item_id_in
          and job.line_type = 1
        order by
          dtl.batch_id,
          job.assembly_item_id,
          dtl.line_type;

    type dtl_type is table of cur_get_mtl%ROWTYPE index by binary_integer;
    dtl_tab   dtl_type;
    temp_dtl  cur_get_mtl%ROWTYPE;
    l_scale_qty number;

    gmd_common_scale_error  EXCEPTION;

BEGIN

    l_proc_name := 'OPI_DBI_JOB_TXN_STG_PKG.GET_OPI_SCALED_MTL_INIT';

    BIS_COLLECTION_UTILITIES.PUT_LINE('Entering Procedure '|| l_proc_name);

     IF fnd_installation.get_app_info( 'OPI', l_status, l_industry, l_opi_schema) THEN
     --{
    	execute immediate 'truncate table ' || l_opi_schema || '.OPI_DBI_OPM_SCALED_MTL';
     --}
     END IF;

    l_stmt_num := 10;
    k := 1;
    FOR get_rec1 in cur_get_batch LOOP
    --{
        l_stmt_num := 1000+k;
    	l_batch_id := get_rec1.job_id;
    	l_org_id := get_rec1.organization_id;
    	l_item_id := get_rec1.assembly_item_id;
    	l_cost_alloc := get_rec1.cost_alloc;

    	i := 1;
    	FOR get_rec2 in cur_get_mtl(l_batch_id, l_org_id, l_item_id, l_cost_alloc) LOOP
    	--{
    		l_stmt_num := 2000 + i;
    		l_scale_tab (i).line_no                 := get_rec2.line_no;
    		l_scale_tab (i).detail_uom              := get_rec2.DTL_UM;
		    l_scale_tab (i).scale_type              := get_rec2.scale_type;
		    l_scale_tab (i).contribute_yield_ind    := get_rec2.contribute_yield_ind;
		    l_scale_tab (i).scale_multiple          := get_rec2.scale_multiple;
		    l_scale_tab (i).scale_rounding_variance := get_rec2.scale_rounding_variance;
		    l_scale_tab (i).rounding_direction      := get_rec2.rounding_direction;
		    l_scale_tab (i).line_no                 := get_rec2.line_no;
		    l_scale_tab (i).line_type               := get_rec2.line_type;
		    l_scale_tab (i).inventory_item_id       := get_rec2.inventory_item_id;
            l_scale_tab (i).qty                     := get_rec2.plan_qty;

            if get_rec2.coproduct_plan_qty <> 0 then
            --{
		      	x_scale_factor := get_rec2.coproduct_actual_qty/get_rec2.coproduct_plan_qty;
		    --}
            else
            --{
		       	x_scale_factor := 1;
            --}
            end if;

            if l_scale_tab(i).scale_type <> 0 then -- call gmd_common_scale.sale only if ing is scalable
            --{
                gmd_common_scale.scale( p_scale_tab     => l_scale_tab
		                            ,p_orgn_id          => l_org_id
		                            ,p_scale_factor     => x_scale_factor
		                            ,p_primaries        => 'OUTPUT'
		                            ,x_scale_tab        => x_scale_tab
                                    ,x_return_status    => x_return_status);

                if x_return_status = 'S' then
                    l_scale_qty := x_scale_tab(i).qty;
                else
                    raise gmd_common_scale_error;
                end if;

            --}
            else -- ingredient is not scalable, just return planned qty not scaled
            --{
                l_scale_qty := l_scale_tab(i).qty;
            --}
            end if;


            INSERT INTO  OPI_DBI_OPM_SCALED_MTL
			(
			ORGANIZATION_ID ,
			JOB_TYPE,
			BATCH_ID,
			COPRODUCT_ID,
			MATERIAL_DETAIL_ID,
			COPRODUCT_PLAN_QTY,
			COPRODUCT_ACTUAL_QTY,
			SCALED_PLAN_QTY ,
			ACTUAL_QTY,
			ITEM_UM,
			SCALE_TYPE,
			CONTRIBUTE_YIELD_IND,
			SCALE_MULTIPLE,
			SCALE_ROUNDING_VARIANCE,
			ROUNDING_DIRECTION,
			LINE_NO,
			LINE_TYPE,
			item_id,
			PLAN_QTY,
			COMPLETION_DATE)
			values
			(
			 get_rec2.ORGANIZATION_ID,
			 get_rec2.JOB_TYPE,
			 get_rec2.BATCH_ID,
			 get_rec2.COPRODUCT_ID,
			 get_rec2.MATERIAL_DETAIL_ID,
			 get_rec2.COPRODUCT_PLAN_QTY,
			 get_rec2.COPRODUCT_ACTUAL_QTY,
			 l_scale_qty*l_cost_alloc,
			 get_rec2.ACTUAL_QTY,
			 get_rec2.DTL_UM,
			 get_rec2.SCALE_TYPE,
			 get_rec2.CONTRIBUTE_YIELD_IND,
			 get_rec2.SCALE_MULTIPLE,
			 get_rec2.SCALE_ROUNDING_VARIANCE,
			 get_rec2.ROUNDING_DIRECTION,
			 get_rec2.LINE_NO,
			 get_rec2.LINE_TYPE,
			 get_rec2.inventory_item_id,
			 get_rec2.PLAN_QTY,
			 get_rec2.COMPLETION_DATE);


            i := i + 1;

    	--}
    	END LOOP;

	k := k + 1;
	l_scale_tab := empty_scale_tab;

    --}
    END LOOP;

    commit;

    select count(*) into l_row_count from OPI_DBI_OPM_SCALED_MTL;

    BIS_COLLECTION_UTILITIES.PUT_LINE('Finished extraction of OPM Scaled Extraction: '|| l_row_count || ' rows inserted');
    BIS_COLLECTION_UTILITIES.PUT_LINE('Exiting Procedure '|| l_proc_name);


EXCEPTION
    WHEN gmd_common_scale_error THEN
        rollback;
        BIS_COLLECTION_UTILITIES.PUT_LINE('Error: gmd_common_scale.scale completed with error status at statement' || l_stmt_num);

    WHEN OTHERS THEN
        rollback;
    	BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,l_stmt_num));

	retcode := SQLCODE;
   	errbuf := SQLERRM;

END GET_OPI_SCALED_MTL_INIT;

/*
   Procedurr populates temp table OPI_DBI_OPM_SCALED_MTL used to get the planned_qty for OPM,
   Incremental Load procedure

   Parameters:
   retcode - 0 on successful completion, -1 on error and 1 for warning.
   errbuf - empty on successful completion, message on error or warning
*/

PROCEDURE GET_OPI_SCALED_MTL_INCR(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
 l_stmt_num NUMBER;
  l_line_count     number;
  l_row_count NUMBER;
  l_err_num NUMBER;
  l_err_msg VARCHAR2(255);
  l_proc_name VARCHAR2(255);
  l_status VARCHAR2(30);
  l_industry VARCHAR2(30);
  l_opi_schema VARCHAR2(30);
  l_batch_id NUMBER;
  l_org_id NUMBER;
  l_item_id NUMBER;
  l_cost_alloc NUMBER;
  l_coproduct_id   NUMBER;
  i NUMBER;
  j NUMBER;
  k NUMBER;
  x_scale_factor   number;
  x_return_status  VARCHAR2 (80);
  l_scale_tab      gmd_common_scale.scale_tab;
  x_scale_tab      gmd_common_scale.scale_tab;
  empty_scale_tab  gmd_common_scale.scale_tab;

  cursor cur_get_batch
  is
  	select
 		jobs.job_id job_id,
 		jobs.organization_id organization_id,
 		jobs.assembly_item_id,
 		mtl_dtl.cost_alloc cost_alloc
 	from
 		opi_dbi_jobs_stg jobs,
 		gme_material_details mtl_dtl
 	where
 		jobs.source in (2,3) and
 		jobs.job_type = 4 and
 		jobs.status = 'Closed' and
 		jobs.line_type = 1 and
 		jobs.organization_id = mtl_dtl.organization_id and
 		jobs.job_id = mtl_dtl.batch_id and
 		jobs.assembly_item_id = mtl_dtl.inventory_item_id and
 		mtl_dtl.line_type = 1;


  cursor cur_get_mtl(job_id_in IN NUMBER, org_id_in IN NUMBER,
  		     item_id_in IN NUMBER, cost_alloc_in IN NUMBER)
  is
  	select
           job.Organization_Id            Organization_Id,
           job.job_type                   Job_Type,
           dtl.batch_id,
           job.completion_date		 completion_date,
           job.assembly_item_id           coproduct_id,
           dtl.material_detail_id         material_detail_id,
           job.start_quantity             coproduct_plan_qty,
           job.actual_qty_completed       coproduct_actual_qty,
           NULL                           scaled_plan_qty,
           dtl.actual_qty,
           dtl.dtl_um,
           dtl.scale_type,
           dtl.contribute_yield_ind,
           dtl.scale_multiple,
           dtl.scale_rounding_variance,
           dtl.rounding_direction,
           dtl.line_no,
           dtl.line_type,
           dtl.inventory_item_id ,
           dtl.plan_qty,
           cost_alloc_in
         from
           OPI_DBI_JOBS_F       job,
           gme_material_details dtl
         where
           job.job_id           = dtl.batch_id
           and job.status          = 'Closed'
           and dtl.line_type in (-1,2)
           and job.job_id = job_id_in
           and job.organization_id = org_id_in
           and job.assembly_item_id = item_id_in
           and job.line_type = 1
         order by
           dtl.batch_id,
           job.assembly_item_id,
           dtl.line_type;

    type dtl_type is table of cur_get_mtl%ROWTYPE index by binary_integer;
    dtl_tab   dtl_type;
    temp_dtl  cur_get_mtl%ROWTYPE;
    l_scale_qty number;

    gmd_common_scale_error  EXCEPTION;


 BEGIN

     l_proc_name := 'OPI_DBI_JOB_TXN_STG_PKG.GET_OPI_SCALED_MTL_INCR';

     BIS_COLLECTION_UTILITIES.PUT_LINE('Entering Procedure '|| l_proc_name);

     IF fnd_installation.get_app_info( 'OPI', l_status, l_industry, l_opi_schema) THEN
     --{
       	execute immediate 'truncate table ' || l_opi_schema || '.OPI_DBI_OPM_SCALED_MTL';
     --}
     END IF;

     l_stmt_num := 10;
     k := 1;
     FOR get_rec1 in cur_get_batch LOOP
     --{
         l_stmt_num := 1000+k;
     	l_batch_id := get_rec1.job_id;
     	l_org_id := get_rec1.organization_id;
     	l_item_id := get_rec1.assembly_item_id;
     	l_cost_alloc := get_rec1.cost_alloc;

     	i := 1;
     	FOR get_rec2 in cur_get_mtl(l_batch_id, l_org_id, l_item_id, l_cost_alloc) LOOP
     	--{
     		l_stmt_num := 2000 + i;
     		l_scale_tab (i).line_no                 := get_rec2.line_no;
     		l_scale_tab (i).detail_uom              := get_rec2.DTL_UM;
 		    l_scale_tab (i).scale_type              := get_rec2.scale_type;
 		    l_scale_tab (i).contribute_yield_ind    := get_rec2.contribute_yield_ind;
 		    l_scale_tab (i).scale_multiple          := get_rec2.scale_multiple;
 		    l_scale_tab (i).scale_rounding_variance := get_rec2.scale_rounding_variance;
 		    l_scale_tab (i).rounding_direction      := get_rec2.rounding_direction;
 		    l_scale_tab (i).line_no                 := get_rec2.line_no;
 		    l_scale_tab (i).line_type               := get_rec2.line_type;
 		    l_scale_tab (i).inventory_item_id       := get_rec2.inventory_item_id;
            l_scale_tab (i).qty                     := get_rec2.plan_qty;

            if get_rec2.coproduct_plan_qty <> 0 then
            --{
 		      	x_scale_factor := get_rec2.coproduct_actual_qty/get_rec2.coproduct_plan_qty;
 		    --}
            else
            --{
 		       	x_scale_factor := 1;
            --}
            end if;

             if l_scale_tab(i).scale_type <> 0 then -- call gmd_common_scale.sale only if ing is scalable
            --{
                gmd_common_scale.scale( p_scale_tab     => l_scale_tab
                                    ,p_orgn_id          => l_org_id
                                    ,p_scale_factor     => x_scale_factor
                                    ,p_primaries        => 'OUTPUT'
                                    ,x_scale_tab        => x_scale_tab
                                    ,x_return_status    => x_return_status);

                if x_return_status = 'S' then
                    l_scale_qty := x_scale_tab(i).qty;
                else
                    raise gmd_common_scale_error;
                end if;

            --}
            else -- ingredient is not scalable, just return planned qty not scaled
            --{
                l_scale_qty := l_scale_tab(i).qty;
            --}
            end if;

           	INSERT INTO  OPI_DBI_OPM_SCALED_MTL
 			(
 			ORGANIZATION_ID ,
 			JOB_TYPE,
 			BATCH_ID,
 			COPRODUCT_ID,
 			MATERIAL_DETAIL_ID,
 			COPRODUCT_PLAN_QTY,
 			COPRODUCT_ACTUAL_QTY,
 			SCALED_PLAN_QTY ,
 			ACTUAL_QTY,
 			ITEM_UM,
 			SCALE_TYPE,
 			CONTRIBUTE_YIELD_IND,
 			SCALE_MULTIPLE,
 			SCALE_ROUNDING_VARIANCE,
 			ROUNDING_DIRECTION,
 			LINE_NO,
 			LINE_TYPE,
 			item_id,
 			PLAN_QTY,
 			COMPLETION_DATE)
 			values
 			(
 			 get_rec2.ORGANIZATION_ID,
 			 get_rec2.JOB_TYPE,
 			 get_rec2.BATCH_ID,
 			 get_rec2.COPRODUCT_ID,
 			 get_rec2.MATERIAL_DETAIL_ID,
 			 get_rec2.COPRODUCT_PLAN_QTY,
 			 get_rec2.COPRODUCT_ACTUAL_QTY,
 			 l_scale_qty*l_cost_alloc,
 			 get_rec2.ACTUAL_QTY,
 			 get_rec2.DTL_UM,
 			 get_rec2.SCALE_TYPE,
 			 get_rec2.CONTRIBUTE_YIELD_IND,
 			 get_rec2.SCALE_MULTIPLE,
 			 get_rec2.SCALE_ROUNDING_VARIANCE,
 			 get_rec2.ROUNDING_DIRECTION,
 			 get_rec2.LINE_NO,
 			 get_rec2.LINE_TYPE,
 			 get_rec2.inventory_item_id,
 			 get_rec2.PLAN_QTY,
 			 get_rec2.COMPLETION_DATE);


            i := i + 1;

     	--}
     	END LOOP;

 	k := k + 1;
 	l_scale_tab := empty_scale_tab;

     --}
     END LOOP;

     commit;

     select count(*) into l_row_count from OPI_DBI_OPM_SCALED_MTL;

     BIS_COLLECTION_UTILITIES.PUT_LINE('Finished extraction of OPM Scaled Extraction: '|| l_row_count || ' rows inserted');
     BIS_COLLECTION_UTILITIES.PUT_LINE('Exiting Procedure '|| l_proc_name);


 EXCEPTION

    WHEN gmd_common_scale_error THEN
        rollback;
        BIS_COLLECTION_UTILITIES.PUT_LINE('Error: gmd_common_scale.scale completed with error status at statement' || l_stmt_num);

    WHEN OTHERS THEN
        rollback;
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,l_stmt_num));

 	retcode := SQLCODE;
   	errbuf := SQLERRM;

END GET_OPI_SCALED_MTL_INCR;

/*
   Procedure populates WIP Completions fact for OPM and ODM from Jobs Transaction Staging
   table, Initial Load procedure

   Parameters:
   retcode - 0 on successful completion, -1 on error and 1 for warning.
   errbuf - empty on successful completion, message on error or warning
*/

PROCEDURE GET_OPI_WIP_COMP_INIT(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
 l_stmt_num NUMBER;
 l_row_count NUMBER;
 l_err_num NUMBER;
 l_err_msg VARCHAR2(255);
 l_proc_name VARCHAR2(255);
 l_status VARCHAR2(30);
 l_industry VARCHAR2(30);
 l_opi_schema VARCHAR2(30);

BEGIN

    l_proc_name := 'OPI_DBI_JOB_TXN_STG_PKG.GET_OPI_WIP_COMP_INIT';

    BIS_COLLECTION_UTILITIES.PUT_LINE('Entering Procedure '|| l_proc_name);

    /* Extraction of WIP Completions fact */
    l_stmt_num := 20;
    INSERT
    INTO OPI_DBI_WIP_COMP_F
    (
    organization_id,
    inventory_item_id,
    transaction_date,
    completion_quantity,
    completion_value_b,
    uom_code,
    conversion_rate,
    planned_item,
    source,
    creation_date,
    last_update_date,
    created_by,
    last_updated_by,
    last_update_login,
    sec_conversion_rate,
    job_id,
    job_type,
    line_type,
    completion_quantity_draft,
    completion_value_draft_b,
    completion_value_g,
    completion_value_draft_g,
    completion_value_sg,
    completion_value_draft_sg,
    PROGRAM_ID,
    PROGRAM_LOGIN_ID,
    PROGRAM_APPLICATION_ID,
    REQUEST_ID
    )
    select
    	jobs_txn.organization_id,
    	assembly_item_id,
    	trunc(jobs_txn.transaction_date),
    	-sum(primary_quantity+primary_quantity_draft),
    	-sum(transaction_value_b+transaction_value_draft_b),
    	uom_code,
    	crates.conversion_rate,
    	planned_item,
    	source,
    	s_sysdate,
	s_sysdate,
	s_user_id,
	s_user_id,
    	s_login_id,
    	crates.sec_conversion_rate,
    	job_id,
    	job_type,
    	line_type,
    	-sum(primary_quantity_draft),
    	-sum(transaction_value_draft_b),
    	-sum((transaction_value_b+transaction_value_draft_b)*crates.conversion_rate),
    	-sum(transaction_value_draft_b*crates.conversion_rate),
    	-sum((transaction_value_b+transaction_value_draft_b)*crates.sec_conversion_rate),
    	-sum(transaction_value_draft_b*crates.sec_conversion_rate),
    	s_program_id,
	s_program_login_id,
	s_program_application_id,
	s_request_id
    from
    	OPI_DBI_JOBS_TXN_STG jobs_txn,
    	opi_dbi_muv_conv_rates crates
    where
    	jobs_txn.etl_type_id = 2 and
    	jobs_txn.organization_id = crates.organization_id and
    	trunc(jobs_txn.transaction_date) = crates.transaction_date
    group by
    	jobs_txn.organization_id,
    	jobs_txn.job_id,
    	jobs_txn.job_type,
    	jobs_txn.assembly_item_id,
    	jobs_txn.component_item_id,
    	jobs_txn.uom_code,
    	jobs_txn.line_type,
    	trunc(jobs_txn.transaction_date),
    	jobs_txn.source,
    	crates.conversion_rate,
    	crates.sec_conversion_rate,
    	planned_item;

    l_row_count := sql%rowcount;

    BIS_COLLECTION_UTILITIES.PUT_LINE('Finished extraction of WIP Completions Fact Table: '|| l_row_count || ' rows inserted');
    BIS_COLLECTION_UTILITIES.PUT_LINE('Exiting Procedure '|| l_proc_name);

EXCEPTION

    WHEN OTHERS THEN

        rollback;

       	BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,l_stmt_num));

	retcode := SQLCODE;
   	errbuf := SQLERRM;

END GET_OPI_WIP_COMP_INIT;

/*
   Procedure Merges WIP Completions fact for OPM and ODM from Jobs Transaction Staging
   table, Incremental Load procedure

   Parameters:
   retcode - 0 on successful completion, -1 on error and 1 for warning.
   errbuf - empty on successful completion, message on error or warning
*/

PROCEDURE GET_OPI_WIP_COMP_INCR(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
 l_stmt_num NUMBER;
 l_row_count NUMBER;
 l_err_num NUMBER;
 l_err_msg VARCHAR2(255);
 l_proc_name VARCHAR2(255);
 l_status VARCHAR2(30);
 l_industry VARCHAR2(30);
 l_opi_schema VARCHAR2(30);

BEGIN

    l_proc_name := 'OPI_DBI_JOB_TXN_STG_PKG.GET_OPI_WIP_COMP_INCR';

    BIS_COLLECTION_UTILITIES.PUT_LINE('Entering Procedure '|| l_proc_name);

    /* Extraction of WIP Completions fact */
    l_stmt_num := 20;
    MERGE
    INTO OPI_DBI_WIP_COMP_F fact USING
    (
     select
    	jobs_txn.organization_id organization_id,
    	assembly_item_id inventory_item_id,
    	trunc(jobs_txn.transaction_date) transaction_date,
    	-sum(primary_quantity+primary_quantity_draft) completion_quantity,
    	-sum(transaction_value_b+transaction_value_draft_b) completion_value_b,
    	uom_code uom_code,
    	crates.conversion_rate conversion_rate,
    	planned_item planned_item,
    	source source,
    	s_sysdate creation_date,
    	s_sysdate last_update_date,
    	s_user_id created_by,
    	s_user_id last_updated_by,
    	s_login_id last_update_login,
    	sec_conversion_rate sec_conversion_rate,
    	job_id job_id,
    	job_type job_type,
    	line_type line_type,
    	-sum(primary_quantity_draft) completion_quantity_draft,
    	-sum(transaction_value_draft_b) completion_value_draft_b,
    	-sum((transaction_value_b+transaction_value_draft_b)*crates.conversion_rate) completion_value_g,
    	-sum(transaction_value_draft_b*crates.conversion_rate) completion_value_draft_g,
    	-sum((transaction_value_b+transaction_value_draft_b)*crates.sec_conversion_rate) completion_value_sg,
    	-sum(transaction_value_draft_b*crates.sec_conversion_rate) completion_value_draft_sg,
    	s_program_id PROGRAM_ID,
	s_program_login_id PROGRAM_LOGIN_ID,
	s_program_application_id PROGRAM_APPLICATION_ID,
	s_request_id REQUEST_ID
    from
        OPI_DBI_JOBS_TXN_STG jobs_txn,
        opi_dbi_muv_conv_rates crates
    where
        jobs_txn.etl_type_id = 2 and
        jobs_txn.organization_id = crates.organization_id and
        trunc(jobs_txn.transaction_date) = crates.transaction_date
    group by
        jobs_txn.organization_id,
        jobs_txn.job_id,
        jobs_txn.job_type,
        jobs_txn.assembly_item_id,
        jobs_txn.component_item_id,
        jobs_txn.uom_code,
        jobs_txn.line_type,
        trunc(jobs_txn.transaction_date),
    	jobs_txn.source,
    	crates.conversion_rate,
    	crates.sec_conversion_rate,
    	planned_item
    )stg
    ON
    (
     	fact.organization_id = stg.organization_id and
     	fact.job_id = stg.job_id and
     	fact.job_type = stg.job_type and
     	fact.inventory_item_id = stg.inventory_item_id and
     	fact.transaction_date = stg.transaction_date and
     	fact.line_type = stg.line_type and
     	fact.uom_code = stg.uom_code and
     	fact.source = stg.source
    )
    WHEN MATCHED THEN
    	UPDATE SET
    	fact.completion_quantity = fact.completion_quantity + stg.completion_quantity - fact.completion_quantity_draft,
    	fact.completion_quantity_draft = stg.completion_quantity_draft,
    	fact.completion_value_b = fact.completion_value_b + stg.completion_value_b - fact.completion_value_draft_b,
    	fact.completion_value_draft_b = stg.completion_value_draft_b,
    	fact.completion_value_g = fact.completion_value_g + stg.completion_value_g - fact.completion_value_draft_g,
    	fact.completion_value_draft_g = stg.completion_value_draft_g,
    	fact.completion_value_sg = fact.completion_value_sg + stg.completion_value_sg - fact.completion_value_draft_sg,
    	fact.completion_value_draft_sg = stg.completion_value_draft_sg,
    	fact.last_update_date = stg.last_update_date,
	fact.last_updated_by = stg.last_updated_by,
	fact.last_update_login = stg.last_update_login
    WHEN NOT MATCHED THEN
    	INSERT
    	(organization_id,
    	inventory_item_id,
    	transaction_date,
    	completion_quantity,
    	completion_value_b,
    	uom_code,
    	conversion_rate,
    	planned_item,
    	source,
    	creation_date,
    	last_update_date,
    	created_by,
    	last_updated_by,
    	last_update_login,
    	sec_conversion_rate,
    	job_id,
    	job_type,
    	line_type,
    	completion_quantity_draft,
    	completion_value_draft_b,
    	completion_value_g,
    	completion_value_draft_g,
    	completion_value_sg,
    	completion_value_draft_sg,
    	PROGRAM_ID,
	PROGRAM_LOGIN_ID,
	PROGRAM_APPLICATION_ID,
	REQUEST_ID
    	)
    	VALUES
    	(
    	stg.organization_id,
	stg.inventory_item_id,
	stg.transaction_date,
	stg.completion_quantity,
	stg.completion_value_b,
	stg.uom_code,
	stg.conversion_rate,
	stg.planned_item,
	stg.source,
	stg.creation_date,
	stg.last_update_date,
	stg.created_by,
	stg.last_updated_by,
	stg.last_update_login,
	stg.sec_conversion_rate,
	stg.job_id,
        stg.job_type,
	stg.line_type,
	stg.completion_quantity_draft,
	stg.completion_value_draft_b,
	stg.completion_value_g,
	stg.completion_value_draft_g,
	stg.completion_value_sg,
    	stg.completion_value_draft_sg,
    	stg.PROGRAM_ID,
	stg.PROGRAM_LOGIN_ID,
	stg.PROGRAM_APPLICATION_ID,
	stg.REQUEST_ID
    	);

    l_row_count := sql%rowcount;

    BIS_COLLECTION_UTILITIES.PUT_LINE('Finished extraction of WIP Completions Fact Table: '|| l_row_count || ' rows inserted');
    BIS_COLLECTION_UTILITIES.PUT_LINE('Exiting Procedure '|| l_proc_name);

EXCEPTION

    WHEN OTHERS THEN

        rollback;

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,l_stmt_num));

	retcode := SQLCODE;
   	errbuf := SQLERRM;

END GET_OPI_WIP_COMP_INCR;

/*
   Procedure populates Scrap fact for ODM from Jobs Transaction Staging
   table, Initial Load procedure

   Parameters:
   retcode - 0 on successful completion, -1 on error and 1 for warning.
   errbuf - empty on successful completion, message on error or warning
*/

PROCEDURE GET_OPI_WIP_SCRAP_INIT(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
 l_stmt_num NUMBER;
 l_row_count NUMBER;
 l_err_num NUMBER;
 l_err_msg VARCHAR2(255);
 l_proc_name VARCHAR2(255);
 l_status VARCHAR2(30);
 l_industry VARCHAR2(30);
 l_opi_schema VARCHAR2(30);

BEGIN

    l_proc_name := 'OPI_DBI_JOB_TXN_STG_PKG.GET_OPI_WIP_SCRAP_INIT';

    BIS_COLLECTION_UTILITIES.PUT_LINE('Entering Procedure '|| l_proc_name);

    /* Extraction of Scrap fact */
    l_stmt_num := 20;
    INSERT
    INTO OPI_DBI_WIP_SCRAP_F
    (
      	 organization_id,
       	 inventory_item_id,
         transaction_date,
         scrap_quantity,
         scrap_value_b,
         uom_code,
         conversion_rate,
         source,
         planned_item,
         creation_date,
         last_update_date,
         created_by,
         last_updated_by,
         last_update_login,
         sec_conversion_rate,
         job_id,
         job_type,
    	 scrap_reason_id,
    	 scrap_value_g,
    	 scrap_value_sg,
    	 PROGRAM_ID,
	 PROGRAM_LOGIN_ID,
	 PROGRAM_APPLICATION_ID,
	 REQUEST_ID
    )
    select
    	jobs_txn.organization_id  organization_id,
    	assembly_item_id inventory_item_id,
    	jobs_txn.transaction_date transaction_date,
    	-sum(primary_quantity) scrap_quantity,
    	-sum(transaction_value_b) scrap_value_b,
    	uom_code uom_code,
    	crates.conversion_rate conversion_rate,
    	source source,
    	planned_item planned_item,
    	s_sysdate creation_date,
    	s_sysdate last_update_date,
    	s_user_id created_by,
    	s_user_id last_updated_by,
    	s_login_id last_update_login,
    	crates.sec_conversion_rate sec_conversion_rate,
    	job_id   job_id,
    	job_type   job_type,
    	scrap_reason scrap_reason_id,
    	-sum(transaction_value_b*crates.conversion_rate) scrap_value_g,
    	-sum(transaction_value_b*crates.sec_conversion_rate) scrap_value_sg,
    	s_program_id PROGRAM_ID,
	s_program_login_id PROGRAM_LOGIN_ID,
	s_program_application_id PROGRAM_APPLICATION_ID,
	s_request_id REQUEST_ID
    FROM
       	OPI_DBI_JOBS_TXN_STG jobs_txn,
       	opi_dbi_muv_conv_rates crates
    WHERE
      	etl_type_id = 3 and
       	jobs_txn.organization_id = crates.organization_id and
    	trunc(jobs_txn.transaction_date) = crates.transaction_date
    GROUP BY
    	jobs_txn.organization_id,
    	assembly_item_id,
    	jobs_txn.transaction_date,
    	uom_code,
    	crates.conversion_rate,
    	source,
    	planned_item,
    	crates.sec_conversion_rate,
    	job_id,
    	job_type,
    	scrap_reason;

    l_row_count := sql%rowcount;

    BIS_COLLECTION_UTILITIES.PUT_LINE('Finished extraction of Scrap Fact Table: '|| l_row_count || ' rows inserted');
    BIS_COLLECTION_UTILITIES.PUT_LINE('Exiting Procedure '|| l_proc_name);

EXCEPTION

    WHEN OTHERS THEN

       	BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,l_stmt_num));

	retcode := SQLCODE;
   	errbuf := SQLERRM;

END GET_OPI_WIP_SCRAP_INIT;

/*
   Procedure Merges Scrap fact for ODM from Jobs Transaction Staging
   table, Incremental Load procedure

   Parameters:
   retcode - 0 on successful completion, -1 on error and 1 for warning.
   errbuf - empty on successful completion, message on error or warning
*/

PROCEDURE GET_OPI_WIP_SCRAP_INCR(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
 l_stmt_num NUMBER;
 l_row_count NUMBER;
 l_err_num NUMBER;
 l_err_msg VARCHAR2(255);
 l_proc_name VARCHAR2(255);
 l_status VARCHAR2(30);
 l_industry VARCHAR2(30);
 l_opi_schema VARCHAR2(30);

BEGIN

    l_proc_name := 'OPI_DBI_JOB_TXN_STG_PKG.GET_OPI_WIP_SCRAP_INCR';

    BIS_COLLECTION_UTILITIES.PUT_LINE('Entering Procedure '|| l_proc_name);

    /* Extraction of Scrap fact */
    l_stmt_num := 20;
    MERGE
    INTO OPI_DBI_WIP_SCRAP_F fact USING
    (
    select
    	jobs_txn.organization_id  organization_id,
    	assembly_item_id inventory_item_id,
    	jobs_txn.transaction_date transaction_date,
    	-sum(primary_quantity) scrap_quantity,
    	-sum(transaction_value_b) scrap_value_b,
    	uom_code uom_code,
    	crates.conversion_rate conversion_rate,
    	source source,
    	planned_item planned_item,
    	s_sysdate creation_date,
    	s_sysdate last_update_date,
    	s_user_id created_by,
    	s_user_id last_updated_by,
    	s_login_id last_update_login,
    	crates.sec_conversion_rate sec_conversion_rate,
    	job_id   job_id,
    	job_type   job_type,
    	scrap_reason scrap_reason_id,
    	-sum(transaction_value_b*crates.conversion_rate) scrap_value_g,
    	-sum(transaction_value_b*crates.sec_conversion_rate) scrap_value_sg,
    	s_program_id PROGRAM_ID,
	s_program_login_id PROGRAM_LOGIN_ID,
	s_program_application_id PROGRAM_APPLICATION_ID,
	s_request_id REQUEST_ID
    FROM
       	OPI_DBI_JOBS_TXN_STG jobs_txn,
       	opi_dbi_muv_conv_rates crates
    WHERE
      	etl_type_id = 3 and
       	jobs_txn.organization_id = crates.organization_id and
    	trunc(jobs_txn.transaction_date) = crates.transaction_date
    GROUP BY
    	jobs_txn.organization_id,
    	assembly_item_id,
    	jobs_txn.transaction_date,
    	uom_code,
	crates.conversion_rate,
	source,
	planned_item,
	crates.sec_conversion_rate,
	job_id,
	job_type,
    	scrap_reason
    )stg
    ON
    (	fact.organization_id = stg.organization_id and
    	fact.job_id = stg.job_id and
    	fact.job_type = stg.job_type and
    	fact.inventory_item_id = stg.inventory_item_id and
    	fact.transaction_date = stg.transaction_date and
    	fact.uom_code = stg.uom_code and
    	fact.scrap_reason_id = stg.scrap_reason_id and
    	fact.source = stg.source
    )
    WHEN MATCHED THEN
    	UPDATE SET
    	fact.scrap_quantity = stg.scrap_quantity,
    	fact.scrap_value_b = stg.scrap_value_b,
    	fact.scrap_value_g = stg.scrap_value_g,
    	fact.scrap_value_sg = stg.scrap_value_sg,
    	fact.last_update_date = stg.last_update_date,
    	fact.last_updated_by = stg.last_updated_by,
    	fact.last_update_login = stg.last_update_login
    WHEN NOT MATCHED THEN
    	INSERT
    	(organization_id,
    	 inventory_item_id,
    	 transaction_date,
    	 scrap_quantity,
    	 scrap_value_b,
    	 uom_code,
    	 conversion_rate,
    	 source,
    	 planned_item,
    	 creation_date,
    	 last_update_date,
    	 created_by,
    	 last_updated_by,
    	 last_update_login,
    	 sec_conversion_rate,
    	 job_id,
    	 job_type,
    	 scrap_reason_id,
    	 scrap_value_g,
    	 scrap_value_sg,
    	 PROGRAM_ID,
	 PROGRAM_LOGIN_ID,
	 PROGRAM_APPLICATION_ID,
	 REQUEST_ID
    	)
    	VALUES
    	(
    	 stg.organization_id,
    	 stg.inventory_item_id,
    	 stg.transaction_date,
    	 stg.scrap_quantity,
    	 stg.scrap_value_b,
    	 stg.uom_code,
    	 stg.conversion_rate,
    	 stg.source,
    	 stg.planned_item,
    	 stg.creation_date,
    	 stg.last_update_date,
    	 stg.created_by,
    	 stg.last_updated_by,
    	 stg.last_update_login,
    	 stg.sec_conversion_rate,
    	 stg.job_id,
    	 stg.job_type,
    	 stg.scrap_reason_id,
    	 stg.scrap_value_g,
    	 stg.scrap_value_sg,
    	 stg.PROGRAM_ID,
	 stg.PROGRAM_LOGIN_ID,
 	 stg.PROGRAM_APPLICATION_ID,
	 stg.REQUEST_ID
    	);

    l_row_count := sql%rowcount;

    BIS_COLLECTION_UTILITIES.PUT_LINE('Finished extraction of Scrap Fact Table: '|| l_row_count || ' rows inserted');
    BIS_COLLECTION_UTILITIES.PUT_LINE('Exiting Procedure '|| l_proc_name);

EXCEPTION

    WHEN OTHERS THEN

       	BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,l_stmt_num));

	retcode := SQLCODE;
   	errbuf := SQLERRM;

END GET_OPI_WIP_SCRAP_INCR;

/*
   Procedure to truncate all temp and staging tables

   Parameters:
     retcode - 0 on successful completion, -1 on error and 1 for warning.
     errbuf - empty on successful completion, message on error or warning
*/

PROCEDURE OPI_TRUNC_TEMP_TBLS(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
 l_stmt_num NUMBER;
 l_row_count NUMBER;
 l_err_num NUMBER;
 l_err_msg VARCHAR2(255);
 l_proc_name VARCHAR2(255);
 l_status VARCHAR2(30);
 l_industry VARCHAR2(30);
 l_opi_schema VARCHAR2(30);

BEGIN

      l_proc_name := 'OPI_DBI_JOB_TXN_STG_PKG.OPI_TRUNC_TEMP_TBLS';

     BIS_COLLECTION_UTILITIES.PUT_LINE('Entering Procedure '|| l_proc_name);

     /* truncate all tables */
     l_stmt_num := 10;
     IF fnd_installation.get_app_info( 'OPI', l_status, l_industry, l_opi_schema) THEN
     --{
	--execute immediate 'truncate table ' || l_opi_schema || '.OPI_DBI_OPM_SCALED_MTL';
	execute immediate 'truncate table ' || l_opi_schema || '.OPI_DBI_JOB_MTL_STD_QTY_TMP';
	execute immediate 'truncate table ' || l_opi_schema || '.OPI_DBI_JOBS_TXN_STG';
	execute immediate 'truncate table ' || l_opi_schema || '.OPI_DBI_JOBS_TXN_MMT_STG';
	execute immediate 'truncate table ' || l_opi_schema || '.opi_dbi_muv_conv_rates';
     --}
     END IF;

     BIS_COLLECTION_UTILITIES.PUT_LINE('Exiting Procedure '|| l_proc_name);

EXCEPTION

     WHEN OTHERS THEN

       	BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,l_stmt_num));

     	retcode := SQLCODE;
   	errbuf := SQLERRM;

END OPI_TRUNC_TEMP_TBLS;

/*
   Procedure to truncate all fact tables

   Parameters:
     retcode - 0 on successful completion, -1 on error and 1 for warning.
     errbuf - empty on successful completion, message on error or warning
*/

PROCEDURE OPI_TRUNC_MFG_FACT_TBLS(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
 l_stmt_num NUMBER;
 l_row_count NUMBER;
 l_err_num NUMBER;
 l_err_msg VARCHAR2(255);
 l_proc_name VARCHAR2(255);
 l_status VARCHAR2(30);
 l_industry VARCHAR2(30);
 l_opi_schema VARCHAR2(30);

BEGIN

     l_proc_name := 'OPI_DBI_JOB_TRN_STG_PKG.OPI_TRUNC_MFG_FACT_TBLS';

     BIS_COLLECTION_UTILITIES.PUT_LINE('Entering Procedure '|| l_proc_name);

     /* truncate all tables */
     l_stmt_num := 10;
     IF fnd_installation.get_app_info( 'OPI', l_status, l_industry, l_opi_schema) THEN
     --{
	execute immediate 'truncate table ' || l_opi_schema || '.OPI_DBI_JOB_MTL_DETAILS_F';
	execute immediate 'truncate table ' || l_opi_schema || '.OPI_DBI_JOB_MTL_DTL_STD_F';
	execute immediate 'truncate table ' || l_opi_schema || '.OPI_DBI_WIP_COMP_F';
	execute immediate 'truncate table ' || l_opi_schema || '.OPI_DBI_WIP_SCRAP_F';

	execute immediate 'truncate table ' || l_opi_schema || '.OPI_DBI_JOB_MTL_DETAILS_F PURGE MATERIALIZED VIEW LOG';
	execute immediate 'truncate table ' || l_opi_schema || '.OPI_DBI_JOB_MTL_DTL_STD_F PURGE MATERIALIZED VIEW LOG';
	execute immediate 'truncate table ' || l_opi_schema || '.OPI_DBI_WIP_COMP_F PURGE MATERIALIZED VIEW LOG';
	execute immediate 'truncate table ' || l_opi_schema || '.OPI_DBI_WIP_SCRAP_F PURGE MATERIALIZED VIEW LOG';
     --}
     END IF;

     BIS_COLLECTION_UTILITIES.PUT_LINE('Exiting Procedure '|| l_proc_name);

EXCEPTION

     WHEN OTHERS THEN

       	BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,l_stmt_num));

     	retcode := SQLCODE;
   	errbuf := SQLERRM;

END OPI_TRUNC_MFG_FACT_TBLS;

/*
   Procedure Wrapup called after successful collection in all fact tables.

   Parameters:
     retcode - 0 on successful completion, -1 on error and 1 for warning.
     errbuf - empty on successful completion, message on error or warning
*/

PROCEDURE OPI_JOB_TXN_WRAPUP(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
 l_stmt_num NUMBER;
 l_row_count NUMBER;
 l_err_num NUMBER;
 l_err_msg VARCHAR2(255);
 l_proc_name VARCHAR2(255);
 BEGIN

 	l_proc_name := 'OPI_DBI_JOB_TXN_STG_PKG.OPI_JOB_TXN_WRAPUP';

 	BIS_COLLECTION_UTILITIES.PUT_LINE('Entering Procedure '|| l_proc_name);

 	l_stmt_num := 10;
 	IF(opi_dbi_common_mod_incr_pkg.ETL_REPORT_SUCCESS(1,1) = FALSE
 	   OR opi_dbi_common_mod_incr_pkg.ETL_REPORT_SUCCESS(1,2) = FALSE) THEN
 	--{
	       BIS_COLLECTION_UTILITIES.put_line('Failed to store current run time bounds and new run time bounds for next run.');
	       RAISE_APPLICATION_ERROR(-20000, errbuf);
	--}
    	END IF;

    	/* Access MMT and obtain the list of jobs that have WIP material transactions
	   after the first uncosted transaction and use this list of jobs and update
           Include_Jobs in Jobs Table with 2 and leave the rest with 1 */
        l_stmt_num := 20;
        UPDATE /*+ parallel(f) */ OPI_DBI_JOBS_F f
	SET
	   Include_Job = 2
	WHERE
           JOB_ID IN (
           	SELECT /*+ ordered use_nl(mmt,mmta) index(log) parallel(mmt) parallel(mmta) */
	           distinct decode(mmta.primary_quantity, null, mmt.transaction_source_id, mmta.repetitive_schedule_id) JOB_ID
	        FROM
	           MTL_MATERIAL_TRANSACTIONS MMT,
	           mtl_material_txn_allocations mmta,
	           OPI_DBI_RUN_LOG_CURR log
	        WHERE
	            MMT.TRANSACTION_ID >= log.Next_start_txn_id
	            and mmt.transaction_action_id in (1, 27)
	            and mmt.transaction_source_type_id = 5
	            and mmt.transaction_id = mmta.transaction_id (+)
	            and mmt.organization_id = log.organization_id
	            and log.source = 1
	            and log.etl_id = 1
	                 )
           AND SOURCE <> 2;    /* Do not update OPM Jobs here */

        l_stmt_num := 30;
        commit;

        l_stmt_num := 40;
        UPDATE /*+ parallel(f) */ OPI_DBI_JOBS_F f
	    SET Std_Req_Flag = 0
	    WHERE Std_Req_Flag = 1 AND SOURCE=1;
	commit;

	 /* VB I forgot the reason why we are refreshing the MV in our code rather than in the RS like other MVs - please review and document here */
	/* Refresh base MV for MUV*/
	l_stmt_num := 50;
	--REFRESH_BASE_MV(errbuf,retcode,'C');

EXCEPTION

    WHEN OTHERS THEN
    rollback;
    l_err_num := SQLCODE;
    l_err_msg := 'OPI_DBI_JOB_TXN_STG_PKG.OPI_JOB_TXN_WRAPUP ('
                        || to_char(l_stmt_num)
                        || '): '
                        || substr(SQLERRM, 1,200);
    BIS_COLLECTION_UTILITIES.PUT_LINE('OPI_DBI_JOB_TXN_STG_PKG.OPI_JOB_TXN_WRAPUP - Error at statement ('
                        || to_char(l_stmt_num)
                        || ')');
    BIS_COLLECTION_UTILITIES.PUT_LINE('Error Number: ' ||  to_char(l_err_num));
    BIS_COLLECTION_UTILITIES.PUT_LINE('Error Message: ' || l_err_msg);
    BIS_COLLECTION_UTILITIES.WRAPUP( FALSE, l_row_count, 'EXCEPTION '|| l_err_num||' : '||l_err_msg );

    retcode := SQLCODE;
    errbuf := SQLERRM;
    RAISE_APPLICATION_ERROR(-20000, errbuf);

END OPI_JOB_TXN_WRAPUP;

/*
   Procedure checks for required setups.

   Parameters:
     retcode - 0 on successful completion, -1 on error and 1 for warning.
     errbuf - empty on successful completion, message on error or warning
*/

PROCEDURE CHECK_OPI_JOB_TXN_SETUP(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2,
			          init_incr in NUMBER)
IS
 l_stmt_num NUMBER;
 l_row_count NUMBER;
 l_err_num NUMBER;
 l_err_msg VARCHAR2(255);
 l_proc_name VARCHAR2(255);
 BEGIN

 	l_proc_name := 'OPI_DBI_JOB_TXN_STG_PKG.CHECK_OPI_JOB_TXN_SETUP';

 	BIS_COLLECTION_UTILITIES.PUT_LINE('Entering Procedure '|| l_proc_name);

 	/* calling setup for all fact tables */
 	l_stmt_num := 10;

 	IF BIS_COLLECTION_UTILITIES.SETUP('OPI_DBI_JOB_MTL_DETAILS_F') = false then
	        RAISE_APPLICATION_ERROR(-20000, errbuf);
        END IF;

        IF BIS_COLLECTION_UTILITIES.SETUP('OPI_DBI_JOB_MTL_DTL_STD_F') = false then
	        RAISE_APPLICATION_ERROR(-20000, errbuf);
        END IF;

        IF BIS_COLLECTION_UTILITIES.SETUP('OPI_DBI_WIP_COMP_F') = false then
	        RAISE_APPLICATION_ERROR(-20000, errbuf);
        END IF;

        IF BIS_COLLECTION_UTILITIES.SETUP('OPI_DBI_WIP_SCRAP_F') = false then
	        RAISE_APPLICATION_ERROR(-20000, errbuf);
        END IF;

        /* calling common modules bounds check */
 	l_stmt_num := 20;
        IF (init_incr = 1) THEN
        --{
        	IF (opi_dbi_common_mod_init_pkg.init_end_bounds_setup (1, 1) = FALSE OR
		    opi_dbi_common_mod_init_pkg.init_end_bounds_setup (1, 2) = FALSE) THEN
		--{

		    BIS_COLLECTION_UTILITIES.put_line('Initial load concurrent program is running out of turn. ');
		    BIS_COLLECTION_UTILITIES.put_line('Please submit the initial load request set for initial data collection. ');

		    BIS_COLLECTION_UTILITIES.put_line(SQLERRM);
		    retcode := SQLCODE;
		    errbuf := SQLERRM;
		    RAISE_APPLICATION_ERROR(-20000, errbuf);
		--}
		END IF;
	--}
	ELSE
	--{
		l_stmt_num := 22;
		IF opi_dbi_common_mod_incr_pkg.incr_end_bounds_setup  (1, 1) = FALSE OR
		opi_dbi_common_mod_incr_pkg.incr_end_bounds_setup  (1, 2) = FALSE THEN
	        --{
		    BIS_COLLECTION_UTILITIES.put_line('Incremental load concurrent program is running out of turn. ');
	            BIS_COLLECTION_UTILITIES.put_line('Please submit the incremental load request set for incremental data collection. ');

	            BIS_COLLECTION_UTILITIES.put_line(SQLERRM);
	            retcode := SQLCODE;
	            errbuf := SQLERRM;
	            RAISE_APPLICATION_ERROR(-20000, errbuf);
	        --}
                END IF;
        --}
        END IF;

	l_stmt_num := 25;
	IF (init_incr = 1) THEN
	--{
		IF (opi_dbi_common_mod_init_pkg.run_initial_load (1, 1) = FALSE OR
		    opi_dbi_common_mod_init_pkg.run_initial_load (1, 2) = FALSE) THEN
		--{
		    BIS_COLLECTION_UTILITIES.put_line('Initial load concurrent program should not be running. ');
		    BIS_COLLECTION_UTILITIES.put_line('Try running the incremental load request set if the initial request set has already been run. ');
		    BIS_COLLECTION_UTILITIES.put_line('If not, you will need to run the initial load request set.');

		    BIS_COLLECTION_UTILITIES.put_line(SQLERRM);
		    retcode := SQLCODE;
		    errbuf := SQLERRM;
		    RAISE_APPLICATION_ERROR(-20000, errbuf);
		--}
        	END IF;
        --}
        ELSE
        --{
        	l_stmt_num := 27;
        	IF opi_dbi_common_mod_incr_pkg.run_incr_load (1, 1) = FALSE OR
		    opi_dbi_common_mod_incr_pkg.run_incr_load (1, 2) = FALSE THEN
		--{
		    BIS_COLLECTION_UTILITIES.put_line('Incremental load concurrent program should not be running.  ');
		    BIS_COLLECTION_UTILITIES.put_line('If the initial load request set has already been run successfully, please submit the incremental load request set. ');
		    BIS_COLLECTION_UTILITIES.put_line('If not, please run the initial load request set. ');

		    BIS_COLLECTION_UTILITIES.put_line(SQLERRM);
		    retcode := SQLCODE;
		    errbuf := SQLERRM;
		    RAISE_APPLICATION_ERROR(-20000, errbuf);
		--}
 		END IF;
 	--}
 	END IF;

        /* get global start date */
 	l_stmt_num := 30;
 	s_global_start_date := trunc (bis_common_parameters.get_global_start_date);
	IF (s_global_start_date IS NULL) THEN
	    BIS_COLLECTION_UTILITIES.PUT_LINE ('The global Start date Not Set.');

	    RAISE_APPLICATION_ERROR(-20000, errbuf);
        END IF;

        BIS_COLLECTION_UTILITIES.PUT_LINE('Global Start Date:'||s_global_start_date);

        l_stmt_num := 40;
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
        --{
        	BIS_COLLECTION_UTILITIES.PUT_LINE ('The global secondary currency code setup is incorrect. The secondary currency code cannot be null when the secondary rate type is defined and vice versa.');

                RAISE_APPLICATION_ERROR(-20000, errbuf);
        --}
    	END IF;

    	l_stmt_num := 50;
    	-- get R12 upgrade date
    	/* If Migration Sate is not setup the api will return sysdate */
    	OPI_DBI_RPT_UTIL_PKG.get_inv_convergence_date(s_r12_migration_date);

    	BIS_COLLECTION_UTILITIES.PUT_LINE('R12 Migration Date: '|| s_r12_migration_date);

    	BIS_COLLECTION_UTILITIES.PUT_LINE('Exiting Procedure '|| l_proc_name);

EXCEPTION

    WHEN OTHERS THEN
    rollback;
    l_err_num := SQLCODE;
    l_err_msg := 'OPI_DBI_JOB_TXN_STG_PKG.CHECK_OPI_JOB_TXN_SETUP ('
                        || to_char(l_stmt_num)
                        || '): '
                        || substr(SQLERRM, 1,200);
    BIS_COLLECTION_UTILITIES.PUT_LINE('OPI_DBI_JOB_TXN_STG_PKG.CHECK_OPI_JOB_TXN_SETUP - Error at statement ('
                        || to_char(l_stmt_num)
                        || ')');
    BIS_COLLECTION_UTILITIES.PUT_LINE('Error Number: ' ||  to_char(l_err_num));
    BIS_COLLECTION_UTILITIES.PUT_LINE('Error Message: ' || l_err_msg);
    BIS_COLLECTION_UTILITIES.WRAPUP( FALSE, l_row_count, 'EXCEPTION '|| l_err_num||' : '||l_err_msg );

    retcode := SQLCODE;
    errbuf := SQLERRM;
    RAISE_APPLICATION_ERROR(-20000, errbuf);

 END CHECK_OPI_JOB_TXN_SETUP;

 /*
   Public Procedure to refresh MUV, Scrap, and WIP Completions MV

   Parameters:
     retcode - 0 on successful completion, -1 on error and 1 for warning.
     errbuf - empty on successful completion, message on error or warning
     p_method
 */

 PROCEDURE REFRESH_MV(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
 IS
  l_stmt_num NUMBER;
  l_err_num NUMBER;
  l_err_msg VARCHAR2(255);
 BEGIN

  l_stmt_num := 10;
  /* Material Details MV Refresh */

  /* VB WHy are we refresing MVs here rather than in RSG */
  DBMS_MVIEW.REFRESH ('OPI_MTL_VAR_ACT_MV_F', '?');

  dbms_mview.refresh('OPI_MTL_VAR_SUM_MV',
                     '?',
                     '',        -- ROLLBACK_SEG
                     TRUE,      -- PUSH_DEFERRED_RPC
                     FALSE,     -- REFRESH_AFTER_ERRORS
                     0,         -- PURGE_OPTION
                     1,  -- PARALLELISM
                     0,         -- HEAP_SIZE
                     FALSE      -- ATOMIC_REFRESH
                    );

  BIS_COLLECTION_UTILITIES.PUT_LINE('Material Details MV Refresh finished ...');

  l_stmt_num := 20;
  /* Scrap MV Refresh */

  -- First Level MV
  DBMS_MVIEW.REFRESH ('opi_comp_scr_mv', '?');

  l_stmt_num := 24;
  -- Second Level MV
  DBMS_MVIEW.REFRESH ('opi_prod_scr_mv', '?');

  l_stmt_num := 28;
  -- Third Level MV
  DBMS_MVIEW.REFRESH ('opi_scrap_sum_mv', '?');

  BIS_COLLECTION_UTILITIES.PUT_LINE('Scrap Refresh finished ...');

  l_stmt_num := 32;
  /* Refresh MV over WIP Completions fact for On Time production */
  dbms_mview.refresh('OPI_ONTIME_PROD_OO1_MV',
                       '?',
                       '',        -- ROLLBACK_SEG
                       TRUE,      -- PUSH_DEFERRED_RPC
                       FALSE,     -- REFRESH_AFTER_ERRORS
                       0,         -- PURGE_OPTION
                       1,  -- PARALLELISM
                       0,         -- HEAP_SIZE
                       FALSE      -- ATOMIC_REFRESH
                       );

  BIS_COLLECTION_UTILITIES.PUT_LINE('WIP Completions Refresh finished ...');

 EXCEPTION
  WHEN OTHERS THEN

    l_err_num := SQLCODE;
    l_err_msg := 'OPI_DBI_JOB_TXN_STG_PKG.REFRESH_MV ('
                     || to_char(l_stmt_num)
                     || '): '
                     || substr(SQLERRM, 1,200);

    BIS_COLLECTION_UTILITIES.PUT_LINE('OPI_DBI_JOB_TXN_STG_PKG.REFRESH_MV - Error at statement ('
                     || to_char(l_stmt_num)
                     || ')');

    BIS_COLLECTION_UTILITIES.PUT_LINE('Error Number: ' ||  to_char(l_err_num));
    BIS_COLLECTION_UTILITIES.PUT_LINE('Error Message: ' || l_err_msg);

    RAISE_APPLICATION_ERROR(-20000, errbuf);
    /*please note that this api will commit!!*/

END REFRESH_MV;

/*
   Public Procedure Wrapper routine for Initial Load

   Parameters:
     retcode - 0 on successful completion, -1 on error and 1 for warning.
     errbuf - empty on successful completion, message on error or warning
*/

PROCEDURE GET_OPI_JOB_TXN_MUV_INIT(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
 l_stmt_num NUMBER;
 l_row_count NUMBER;
 l_err_num NUMBER;
 l_err_msg VARCHAR2(255);
 l_proc_name VARCHAR2(255);
 r12upgrade_date DATE;

BEGIN

    l_proc_name := 'OPI_DBI_JOB_TXN_STG_PKG.GET_OPI_JOB_TXN_MUV_INIT';

    BIS_COLLECTION_UTILITIES.PUT_LINE('Entering Procedure '|| l_proc_name);

    -- WHO column variable initialization
    l_stmt_num := 0;
    s_sysdate := SYSDATE;
    s_user_id := nvl(fnd_global.user_id, -1);
    s_login_id := nvl(fnd_global.login_id, -1);

    --Check Setup
    l_stmt_num := 5;
    CHECK_OPI_JOB_TXN_SETUP(errbuf => errbuf,retcode => retcode, init_incr => 1);

    l_stmt_num := 7;
    --Truncate all temp, staging and fact tables.
    OPI_TRUNC_TEMP_TBLS(errbuf => errbuf,retcode => retcode);
    OPI_TRUNC_MFG_FACT_TBLS(errbuf => errbuf,retcode => retcode);

    --Populate MMT Staging
    l_stmt_num := 10;
    GET_OPI_JOB_TXN_MMT_STG(errbuf => errbuf,retcode => retcode);

    --Calling to populate temp table for mutli ledger/valuation_cost_type in gtv table
    l_stmt_num := 15;
    BIS_COLLECTION_UTILITIES.PUT_LINE('Calling to populate temp table for mutli ledger/valuation_cost_type in gtv table');
    OPI_DBI_BOUNDS_PKG.load_opm_org_ledger_data;

    --Populate Jobs Txn Staging with ODM data
    l_stmt_num := 20;
    GET_OPI_JOB_TXN_ODM_INIT(errbuf => errbuf,retcode => retcode);

    --Populate Jobs Txn Staging with OPM data
    l_stmt_num := 30;
    GET_OPI_JOB_TXN_OPM_INIT(errbuf => errbuf,retcode => retcode);

    --Populate Scaled MTL Table for OPM
    l_stmt_num := 40;
    GET_OPI_SCALED_MTL_INIT(errbuf => errbuf,retcode => retcode);

    --Populate Jobs Txn Staging Table for Pre R12 Data
    l_stmt_num := 50;
    IF s_r12_migration_date > s_global_start_date
    THEN
    --{

    	GET_OPI_JOB_TXN_PR12OPM_INIT(errbuf => errbuf,retcode => retcode);

    --}
    END IF;

    --Check For Missing Currency Rates
    l_stmt_num := 60;
    IF(GET_OPI_JOB_TXN_CRATES(errbuf,retcode) = -1 ) THEN
    --{
    	BIS_COLLECTION_UTILITIES.put_line('Missing currency rate.');
        BIS_COLLECTION_UTILITIES.put_line('Please run this concurrent program again after fixing the missing currency rates.');
        RAISE_APPLICATION_ERROR(-20000, errbuf);
    --}
    END IF;

    --Populate MU Actuals to fact Table
    l_stmt_num := 70;
    GET_OPI_MTL_USAGE_ACT_INIT(errbuf => errbuf,retcode => retcode);

    --Populate ODM MU Standards to fact Table
    l_stmt_num := 80;
    GET_OPI_ODM_MTL_USAGE_STD_INIT(errbuf => errbuf,retcode => retcode);

    --Populate OPM MU Standards to fact Table
    l_stmt_num := 90;
    GET_OPI_OPM_MTL_USAGE_STD_INIT(errbuf => errbuf,retcode => retcode);

    --Populate WIP Completions Fact
    l_stmt_num := 100;
    GET_OPI_WIP_COMP_INIT(errbuf => errbuf,retcode => retcode);

    --Populate Scrap Completions Fact
    l_stmt_num := 110;
    GET_OPI_WIP_SCRAP_INIT(errbuf => errbuf,retcode => retcode);

    --Truncate all temp and staging tables
    l_stmt_num := 120;
    OPI_TRUNC_TEMP_TBLS(errbuf => errbuf,retcode => retcode);

    --Calling Wrapup procedure
    l_stmt_num := 130;
    OPI_JOB_TXN_WRAPUP(errbuf => errbuf,retcode => retcode);

    commit;

    BIS_COLLECTION_UTILITIES.PUT_LINE('Exiting Procedure '|| l_proc_name);

EXCEPTION

    WHEN OTHERS THEN
    	rollback;
    	l_err_num := SQLCODE;
	l_err_msg := 'OPI_DBI_JOB_TXN_STG_PKG.GET_OPI_JOB_TXN_MUV_INIT ('
	                        || to_char(l_stmt_num)
	                        || '): '
	                        || substr(SQLERRM, 1,200);
	BIS_COLLECTION_UTILITIES.PUT_LINE('OPI_DBI_JOB_TXN_STG_PKG.GET_OPI_JOB_TXN_MUV_INIT - Error at statement ('
	                        || to_char(l_stmt_num)
	                        || ')');
	BIS_COLLECTION_UTILITIES.PUT_LINE('Error Number: ' ||  to_char(l_err_num));
	BIS_COLLECTION_UTILITIES.PUT_LINE('Error Message: ' || l_err_msg);
	BIS_COLLECTION_UTILITIES.WRAPUP( FALSE, l_row_count, 'EXCEPTION '|| l_err_num||' : '||l_err_msg );

	retcode := SQLCODE;
	errbuf := SQLERRM;
        RAISE_APPLICATION_ERROR(-20000, errbuf);

END GET_OPI_JOB_TXN_MUV_INIT;

/*
   Public Procedure Wrapper routine for Initial Load

   Parameters:
     retcode - 0 on successful completion, -1 on error and 1 for warning.
     errbuf - empty on successful completion, message on error or warning
*/

PROCEDURE GET_OPI_JOB_TXN_MUV_INCR(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
 l_stmt_num NUMBER;
 l_row_count NUMBER;
 l_err_num NUMBER;
 l_err_msg VARCHAR2(255);
 l_proc_name VARCHAR2(255);

BEGIN

    l_proc_name := 'OPI_DBI_JOB_TXN_STG_PKG.GET_OPI_JOB_TXN_MUV_INCR';

    BIS_COLLECTION_UTILITIES.PUT_LINE('Entering Procedure '|| l_proc_name);

    -- WHO column variable initialization
    l_stmt_num := 0;
    s_sysdate := SYSDATE;
    s_user_id := nvl(fnd_global.user_id, -1);
    s_login_id := nvl(fnd_global.login_id, -1);

    --Check Setup
    l_stmt_num := 10;
    CHECK_OPI_JOB_TXN_SETUP(errbuf => errbuf,retcode => retcode, init_incr => 2);

    l_stmt_num := 15;
    --Truncate all temp, staging tables.
    OPI_TRUNC_TEMP_TBLS(errbuf => errbuf,retcode => retcode);

    --Calling to populate temp table for mutli ledger/valuation_cost_type in gtv table
    l_stmt_num := 17;
    BIS_COLLECTION_UTILITIES.PUT_LINE('Calling to populate temp table for mutli ledger/valuation_cost_type in gtv table');
    OPI_DBI_BOUNDS_PKG.load_opm_org_ledger_data;

    --Populate Jobs Txn Staging with ODM data
    l_stmt_num := 20;
    GET_OPI_JOB_TXN_ODM_INCR(errbuf => errbuf,retcode => retcode);

    --Populate Jobs Txn Staging with OPM data
    l_stmt_num := 30;
    GET_OPI_JOB_TXN_OPM_INCR(errbuf => errbuf,retcode => retcode);

    --Populate Scaled MTL Table for OPM
    l_stmt_num := 40;
    GET_OPI_SCALED_MTL_INCR(errbuf => errbuf,retcode => retcode);

    --Check For Missing Currency Rates
    l_stmt_num := 60;
    IF(GET_OPI_JOB_TXN_CRATES(errbuf => errbuf,retcode => retcode) = -1 ) THEN
    --{
            BIS_COLLECTION_UTILITIES.put_line('Missing currency rate.');
            BIS_COLLECTION_UTILITIES.put_line('Please run this concurrent program again after fixing the missing currency rates.');
            RAISE_APPLICATION_ERROR(-20000, errbuf);
    --}
    END IF;

    --Populate MU Actuals to fact Table
    l_stmt_num := 70;
    GET_OPI_MTL_USAGE_ACT_INCR(errbuf => errbuf,retcode => retcode);

    --Populate ODM MU Standards to fact Table
    l_stmt_num := 80;
    GET_OPI_ODM_MTL_USAGE_STD_INCR(errbuf => errbuf,retcode => retcode);

    --Populate OPM MU Standards to fact Table
    l_stmt_num := 90;
    GET_OPI_OPM_MTL_USAGE_STD_INCR(errbuf => errbuf,retcode => retcode);

    --Populate WIP Completions Fact
    l_stmt_num := 100;
    GET_OPI_WIP_COMP_INCR(errbuf => errbuf,retcode => retcode);

    --Populate Scrap Completions Fact
    l_stmt_num := 110;
    GET_OPI_WIP_SCRAP_INCR(errbuf => errbuf,retcode => retcode);

    --Truncate all temp and staging tables
    l_stmt_num := 120;
    OPI_TRUNC_TEMP_TBLS(errbuf => errbuf,retcode => retcode);

    --Calling Wrapup procedure
    l_stmt_num := 130;
    OPI_JOB_TXN_WRAPUP(errbuf => errbuf,retcode => retcode);

    commit;

    BIS_COLLECTION_UTILITIES.PUT_LINE('Exiting Procedure '|| l_proc_name);

EXCEPTION

    WHEN OTHERS THEN
    	rollback;
    	l_err_num := SQLCODE;
	l_err_msg := 'OPI_DBI_JOB_TXN_STG_PKG.GET_OPI_JOB_TXN_MUV_INCR ('
	                        || to_char(l_stmt_num)
	                        || '): '
	                        || substr(SQLERRM, 1,200);
	BIS_COLLECTION_UTILITIES.PUT_LINE('OPI_DBI_JOB_TXN_STG_PKG.GET_OPI_JOB_TXN_MUV_INCR - Error at statement ('
	                        || to_char(l_stmt_num)
	                        || ')');
	BIS_COLLECTION_UTILITIES.PUT_LINE('Error Number: ' ||  to_char(l_err_num));
	BIS_COLLECTION_UTILITIES.PUT_LINE('Error Message: ' || l_err_msg);
	BIS_COLLECTION_UTILITIES.WRAPUP( FALSE, l_row_count, 'EXCEPTION '|| l_err_num||' : '||l_err_msg );

	retcode := SQLCODE;
	errbuf := SQLERRM;
        RAISE_APPLICATION_ERROR(-20000, errbuf);

END GET_OPI_JOB_TXN_MUV_INCR;

END OPI_DBI_JOB_TXN_STG_PKG;

/
