--------------------------------------------------------
--  DDL for Package Body ENI_DBI_UCO_LOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_DBI_UCO_LOAD_PKG" AS
/* $Header: ENIUCOLB.pls 120.1 2006/03/21 02:10:28 lparihar noship $ */

g_eni_schema    VARCHAR2(30);
l_status              VARCHAR2(30);
l_industry            VARCHAR2(30);

-- Populate Temporary Rates table
PROCEDURE populate_rates_table(p_refresh_flag VARCHAR2)
IS
   l_err_num NUMBER;
   l_err_msg VARCHAR2(255);
   l_prim_rate_type VARCHAR2(15);
   l_prim_currency_code VARCHAR2(15);
   l_sec_rate_type VARCHAR2(15);
   l_sec_currency_code VARCHAR2(15);
BEGIN

   -- Setting Up the global_rate_type and the global_start_date
   l_prim_rate_type := bis_common_parameters.get_rate_type;
   l_prim_currency_code := bis_common_parameters.get_currency_code;
   l_sec_rate_type := bis_common_parameters.get_secondary_rate_type;
   l_sec_currency_code := bis_common_parameters.get_secondary_currency_code;

  IF (p_refresh_flag = 'INITIAL')
  THEN
   INSERT INTO eni_currency_conv_rates_stg
   (currency_code,
   effective_date,
   primary_rate,
   secondary_rate)
   SELECT currency_code,
    effective_date,
    decode(l_prim_currency_code, NULL, TO_NUMBER(NULL),
        fii_currency.get_rate(currency_code, l_prim_currency_code,
              effective_date, l_prim_rate_type)) primary_rate,
    decode(l_sec_currency_code, NULL, TO_NUMBER(NULL),
        fii_currency.get_rate(currency_code, l_sec_currency_code,
              effective_date, l_sec_rate_type)) secondary_rate
   FROM (SELECT /*+ PARALLEL(tmp) */ DISTINCT currency_code ,
    effective_date  FROM eni_dbi_item_cost_stg tmp);

  ELSIF (p_refresh_flag = 'INCREMENTAL')
  THEN
   INSERT INTO eni_currency_conv_rates_stg
   (currency_code,
   effective_date,
   primary_rate,
   secondary_rate)
   SELECT currency_code,
    effective_date,
    decode(l_prim_currency_code, NULL, TO_NUMBER(NULL),
        fii_currency.get_rate(currency_code, l_prim_currency_code,
              effective_date, l_prim_rate_type)) primary_rate,
    decode(l_sec_currency_code, NULL, TO_NUMBER(NULL),
        fii_currency.get_rate(currency_code, l_sec_currency_code,
              effective_date, l_sec_rate_type)) secondary_rate
   FROM (SELECT DISTINCT currency_code ,
    effective_date  FROM eni_dbi_item_cost_stg);
  END IF;

  eni_dbi_util_pkg.log('Inserted ' ||sql%ROWCOUNT || ' currency rates into rates table');

  commit;

 EXCEPTION
   WHEN OTHERS THEN
   rollback;
   l_err_num := SQLCODE;
   l_err_msg := 'POPULATE_RATES_TABLE: ' || substr(l_err_num, 1,200);

   eni_dbi_util_pkg.log('Error Number: ' ||  to_char(l_err_num));
   eni_dbi_util_pkg.log('Error Message: ' || l_err_msg);
   RAISE;
END populate_rates_table;


-- Initial collection of the cost fact
PROCEDURE initial_item_cost_collect
( o_error_msg OUT NOCOPY VARCHAR2,
  o_error_code OUT NOCOPY VARCHAR2,
  p_start_date IN VARCHAR2,
  p_end_date IN VARCHAR2
) IS

l_start_date date := null;
l_end_date date := null;
l_exists_sc_orgs number;
l_exists_ac_orgs number;

l_application_user_id number;
l_report_missing_rate number;
l_processed_txn_id    number;
l_processed_cost_id   number;
BEGIN

 IF(FND_INSTALLATION.GET_APP_INFO('ENI', l_status, l_industry, g_eni_schema))
  THEN NULL;
  END IF;

  eni_dbi_util_pkg.log('Truncating the cost staging, rates staging and cost fact tables');
  execute immediate 'TRUNCATE TABLE '||g_eni_schema||'.eni_dbi_item_cost_f';
  execute immediate 'TRUNCATE TABLE '||g_eni_schema||'.eni_dbi_item_cost_stg';
  execute immediate 'TRUNCATE TABLE '||g_eni_schema||'.eni_currency_conv_rates_stg';

  l_start_date := trunc (bis_common_parameters.get_global_start_date);
  l_end_date   := trunc (SYSDATE);
  /** COMMENTING these parameter values
      Bug: 4956685 Initial load should pick all records from global start date to sysdate
    l_start_date := trunc(TO_DATE(p_start_date, 'YYYY/MM/DD HH24:MI:SS'));
    l_end_date   := trunc(TO_DATE(p_end_date, 'YYYY/MM/DD HH24:MI:SS'));
  **/
  eni_dbi_util_pkg.log('The date range for Initial cost collection is ' || l_start_date || ' to ' || l_end_date);

  if BIS_COLLECTION_UTILITIES.SETUP(
                  p_object_name => 'eni_dbi_item_cost_f',
                  p_parallel => 1) = false then
    RAISE_APPLICATION_ERROR(-20000,o_error_msg);
  end if;

l_exists_sc_orgs := 0;
l_exists_ac_orgs := 0;

-- Find out if there are any standard costing orgs
select nvl(max(1),0)
into l_exists_sc_orgs
from sys.dual
where exists (
               select 'There are standard costing orgs'
               from  mtl_parameters
               where primary_cost_method = 1
              );

-- Find out if there are any Avg/LIFO/FIFO orgs
select nvl(max(1),0)
into l_exists_ac_orgs
from sys.dual
where exists (
               select 'There are Avg/LIFO/FIFO costing orgs'
               from  mtl_parameters
               where primary_cost_method <> 1
              );

select FND_GLOBAL.USER_ID
into l_application_user_id
from sys.dual;

-- Get the cost history for standard costing orgs from cst_elemental_costs
if (l_exists_sc_orgs = 1) then
  eni_dbi_util_pkg.log('There are Standard Costing orgs, hence starting initial cost collection into stage table for them');

insert /*+ append parallel(a) */ into eni_dbi_item_cost_stg a
      (effective_date,
        inventory_item_id,
        organization_id,
        item_cost,
        material_cost,
        material_overhead_cost,
        resource_cost,
        outside_processing_cost,
        overhead_cost,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        currency_code,
        conversion_rate)
 select effective_date,
        inventory_item_id,
        organization_id,
        sum(standard_cost) item_cost,
        nvl(sum(decode(cost_element_id, 1, standard_cost)), 0) material_cost,
        nvl(sum(decode(cost_element_id, 2, standard_cost)), 0) material_overhead_cost,
        nvl(sum(decode(cost_element_id, 3, standard_cost)), 0) resource_cost,
        nvl(sum(decode(cost_element_id, 4, standard_cost)), 0) outside_processing_cost,
        nvl(sum(decode(cost_element_id, 5, standard_cost)), 0) overhead_cost,
        sysdate last_update_date,
        l_application_user_id last_updated_by,
        sysdate creation_date,
        l_application_user_id created_by,
        l_application_user_id last_update_login,
        currency_code,
        null --fii_currency.get_global_rate_primary(currency_code, effective_date) conversion_rate
   from (
         select /*+ parallel(cec) parallel(hoi) */
                cec.inventory_item_id,
                cec.organization_id,
                trunc(cec.last_update_date) effective_date,
                gsob.currency_code,
                cec.cost_element_id,
                cec.standard_cost,
                rank() over (partition by cec.inventory_item_id, cec.organization_id, trunc(cec.last_update_date),
                gsob.currency_code order by cec.cost_update_id desc) r
           from cst_elemental_costs cec,
                hr_organization_information hoi,
                gl_sets_of_books gsob
          where cec.organization_id = hoi.organization_id
            and hoi.org_information_context = 'Accounting Information'
            and hoi.org_information1 = to_char (gsob.set_of_books_id)
            and cec.last_update_date >= l_start_date
            and cec.last_update_date - 0 <= l_end_date + 0.99999
           )
 where r = 1
 group by effective_date, inventory_item_id, organization_id, currency_code;


end if;

 commit;  -- commit the standard costing data into staging table.


-- Get the cost history for average/LIFO/FIFO costing orgs from mtl_cst_actual_cost_details.
if (l_exists_ac_orgs = 1) then

eni_dbi_util_pkg.log('There are Avg/LIFO/FIFO Costing orgs, hence starting initial cost collection into stage table for them');

insert /*+ append parallel(a) */ into eni_dbi_item_cost_stg a
(effective_date,
        inventory_item_id, organization_id, item_cost, material_cost,
        material_overhead_cost, resource_cost, outside_processing_cost,
        overhead_cost, last_update_date, last_updated_by, creation_date,
        created_by, last_update_login, currency_code, conversion_rate)
 select /*+ parallel (x) parallel (mcacd) use_hash (mcacd, hoi, gsob)
        swap_join_inputs (gsob) pq_distribute (mcacd, hash, hash)
pq_distribute
        (gsob, none, broadcast) */
        trunc(x.asofdate),
        mcacd.inventory_item_id,
        mcacd.organization_id,
        sum (mcacd.new_cost),
        nvl(sum(decode(mcacd.cost_element_id, 1, mcacd.new_cost)), 0) mtl,
        nvl(sum(decode(mcacd.cost_element_id, 2, mcacd.new_cost)), 0) mtl_ovh,
        nvl(sum(decode(mcacd.cost_element_id, 3, mcacd.new_cost)), 0) res,
        nvl(sum(decode(mcacd.cost_element_id, 4, mcacd.new_cost)), 0) osp,
        nvl(sum(decode(mcacd.cost_element_id, 5, mcacd.new_cost)), 0) ovhd,
        sysdate,
        1,
        sysdate,
        1,
        1,
        gsob.currency_code,
        null --fii_currency.get_global_rate_primary (gsob.currency_code,trunc(x.asofdate))
   from (
        select /*+ no_merge parallel(mmt) parallel(cql) parallel(mp) full(mmt)
               swap_join_inputs(cql) */ mmt.inventory_item_id,
mmt.organization_id,
               cql.layer_id, max(mmt.transaction_id) transaction_id,
               trunc (mmt.transaction_date) asofdate
          from mtl_material_transactions mmt,
               cst_quantity_layers cql,
               mtl_parameters mp
         where mp.primary_cost_method <> 1
           and mp.default_cost_group_id = mmt.cost_group_id
           and mp.organization_id = mmt.organization_id
           and mmt.transaction_date >= l_start_date
           and mmt.transaction_date - 0 <= l_end_date + 0.99999
           and mmt.inventory_item_id = cql.inventory_item_id
           and mmt.organization_id = cql.organization_id
           and mmt.cost_group_id = cql.cost_group_id
         group by mmt.inventory_item_id, mmt.organization_id,
cql.layer_id,
               trunc (mmt.transaction_date)) x,
        mtl_cst_actual_cost_details mcacd,
        hr_organization_information hoi,
        gl_sets_of_books gsob
  where mcacd.transaction_id = x.transaction_id
    and mcacd.organization_id = x.organization_id
    and mcacd.layer_id = x.layer_id
    and x.organization_id = hoi.organization_id
    and hoi.org_information_context = 'Accounting Information'
    and hoi.org_information1 = to_char (gsob.set_of_books_id)
  group by trunc (x.asofdate), mcacd.inventory_item_id,
mcacd.organization_id,
        gsob.currency_code;


end if;

   eni_dbi_util_pkg.log('Committing initial cost collection into staging table');
   COMMIT;

   eni_dbi_util_pkg.log('Retreiving currency conversion rates into rates table');
   populate_rates_table('INITIAL');

   eni_dbi_util_pkg.log('Checking if any missing conversion rates are present');

   l_report_missing_rate := report_missing_rate();

   IF (l_report_missing_rate = 0) THEN -- initial collection completed normally.

       insert /*+ append parallel(a) */ into eni_dbi_item_cost_f a
              (effective_date,
               inventory_item_id,
               organization_id,
               item_cost,
               material_cost,
               material_overhead_cost,
               resource_cost,
               outside_processing_cost,
               overhead_cost,
               primary_currency_rate,
               secondary_currency_rate,
               last_update_date,
               last_updated_by,
               creation_date,
               created_by,
               last_update_login)
       select  /*+ parallel(edicstg) parallel(eccrstg) */
               edicstg.effective_date,
               edicstg.inventory_item_id,
               edicstg.organization_id,
               edicstg.item_cost,
               edicstg.material_cost,
               edicstg.material_overhead_cost,
               edicstg.resource_cost,
               edicstg.outside_processing_cost,
               edicstg.overhead_cost,
               eccrstg.primary_rate,
               eccrstg.secondary_rate,
               edicstg.last_update_date,
               edicstg.last_updated_by,
               edicstg.creation_date,
               edicstg.created_by,
               edicstg.last_update_login
       from eni_dbi_item_cost_stg edicstg, eni_currency_conv_rates_stg eccrstg
       where edicstg.currency_code = eccrstg.currency_code
       and edicstg.effective_date = eccrstg.effective_date;

       COMMIT;


       eni_dbi_util_pkg.log('Initial cost collection Complete and Successful');
       o_error_code := 0;
       o_error_msg := 'Initial Cost Collection is Complete and Successful';
       execute immediate 'TRUNCATE TABLE '||g_eni_schema||'.eni_dbi_item_cost_stg';
       execute immediate 'TRUNCATE TABLE '||g_eni_schema||'.eni_currency_conv_rates_stg';
       COMMIT;

       /* Bug: 4956685
          Store the max transaction_id from mmt into bis_refresh_log table
          We are simply picking the max transaction id as the end date is defaulted
          to SYSDATE now and the mmt table rows are not updated once inserted.
       */
       SELECT Max(TRANSACTION_ID)
       INTO   l_processed_txn_id
       FROM   MTL_MATERIAL_TRANSACTIONS mmt;

       /* Bug: 4936377
          Store the max cost_update_id from cec into bis_refresh_log table
          We are simply picking the max cost update id as the end date is defaulted
          to SYSDATE now and the cec table rows are not updated once inserted.
       */
       SELECT Max(COST_UPDATE_ID)
       INTO   l_processed_cost_id
       FROM   cst_elemental_costs cec;

       BIS_COLLECTION_UTILITIES.WRAPUP(
                  p_status => true,
                  p_period_from => l_start_date,
                  p_period_to   => l_end_date,
                  p_attribute1  => 'mtl_material_transactions',
                  p_attribute2  => l_processed_txn_id,
                  p_attribute3  => 'cst_elemental_costs',
                  p_attribute4  => l_processed_cost_id
                   );

   ELSE
       eni_dbi_util_pkg.log('Initial cost collection has completed with errors in the conversion rates.');
       eni_dbi_util_pkg.log('Please modify the conversion rates and execute the incremental collection.');
       execute immediate 'TRUNCATE TABLE '||g_eni_schema||'.eni_currency_conv_rates_stg';
       o_error_code := 1;
       o_error_msg := 'Initial Cost Collection has completed with conversion rate errors';
   END IF;

EXCEPTION

  WHEN OTHERS THEN

    o_error_code := sqlcode;
    o_error_msg := sqlerrm;

    eni_dbi_util_pkg.log('An error prevented the initial cost collection from completing successfully');
    eni_dbi_util_pkg.log(o_error_code||':'||o_error_msg);
    Rollback;
        BIS_COLLECTION_UTILITIES.WRAPUP(
                  p_status => false,
                  p_period_from => l_start_date,
                  p_period_to => l_end_date
                  );
        RAISE_APPLICATION_ERROR(-20000,o_error_msg);

END initial_item_cost_collect;

FUNCTION Report_Missing_Rate return NUMBER  IS
   cursor get_missing_rate_c is
        SELECT effective_date,
          currency_code,
          primary_rate conversion_rate,
          secondary_rate conversion_rate_s--,
--        decode(primary_rate, -1, 'RATE NOT AVAILABLE', -2, 'INVALID CURRENCY') PRIMARY_STATUS,
--        decode(secondary_rate, -1, 'RATE NOT AVAILABLE', -2, 'INVALID CURRENCY') SECONDARY_STATUS
        FROM eni_currency_conv_rates_stg
        WHERE (nvl(primary_rate,99) < 0 OR nvl(secondary_rate,99) < 0)
        AND effective_date IS NOT NULL;

   /* cursor get_missing_rate_c is
      select distinct currency_code, effective_date, conversion_rate, conversion_rate_s
        from eni_dbi_item_cost_stg
        where (NVL(conversion_rate,-99) < 0
                OR NVL(conversion_rate_s,-99) < 0)
        AND effective_date IS NOT NULL;*/

   get_missing_rate_rec    get_missing_rate_c%ROWTYPE;

   l_stmt_num NUMBER;
   l_no_currency_rate_flag NUMBER := 0;
   l_err_num NUMBER;
   l_err_msg VARCHAR2(255);
   l_prim_euro_beg NUMBER;  /* Flag to indicate if the 01-JAN-99 issue has been encountered */
   l_sec_euro_beg NUMBER;  /* Flag to indicate if the 01-JAN-99 issue has been encountered */
   l_prim_rate_type VARCHAR2(15);
   l_prim_currency_code VARCHAR2(15);
   l_sec_rate_type VARCHAR2(15);
   l_sec_currency_code VARCHAR2(15);
   l_start_date DATE;
   l_euro_start_date DATE := to_date('01/01/1999','DD/MM/YYYY');
BEGIN

   l_prim_euro_beg := 0;
   l_sec_euro_beg := 0;

   l_stmt_num := 20; /* call api to get get_global_rate_primary */

   -- Setting Up the global_rate_type and the global_start_date
   l_prim_rate_type := bis_common_parameters.get_rate_type;
   l_stmt_num := 21;
   l_prim_currency_code := bis_common_parameters.get_currency_code;
   l_stmt_num := 22;
   l_sec_rate_type := bis_common_parameters.get_secondary_rate_type;
   l_stmt_num := 23;
   l_sec_currency_code := bis_common_parameters.get_secondary_currency_code;
   l_stmt_num:=24;
   l_start_date := bis_common_parameters.get_global_start_date;

   -- If no global currency code was defined
   -- do not try reporting missing secondary currency conversion rates

   IF (l_prim_currency_code IS NULL)
   THEN
        eni_dbi_util_pkg.log('Primary currency code has not been setup, so not checking for missing primary currency conversion rates');
   END IF;

   IF (l_sec_currency_code IS NULL)
   THEN
        eni_dbi_util_pkg.log('Secondary currency code has not been setup, so not checking for missing secondary currency conversion rates');
   END IF;

   --  Logging all the Missing Rates into the Output file.

   l_stmt_num := 25;

   OPEN get_missing_rate_c;
   LOOP
     l_stmt_num:=26;
     FETCH get_missing_rate_c into get_missing_rate_rec;
     l_stmt_num:=27;
     EXIT WHEN get_missing_rate_c%notfound;

     l_stmt_num:=28;
     IF (l_no_currency_rate_flag = 0) THEN
         l_no_currency_rate_flag := 1;
         l_stmt_num:=29;
         BIS_COLLECTION_UTILITIES.writeMissingRateHeader;
     END IF;

     -- Report missing conversion rates for primary currency
     IF (l_prim_currency_code IS NOT NULL) AND
        (get_missing_rate_rec.conversion_rate = -3) AND (l_prim_euro_beg = 0)
     THEN
        l_stmt_num:=30;

       BIS_COLLECTION_UTILITIES.writemissingrate
        (l_prim_rate_type,
        get_missing_rate_rec.currency_code,
        l_prim_currency_code,
        l_euro_start_date);
        -- Missing rate on the Start of Euro Date has been encountered
        l_prim_euro_beg := 1;

     ELSIF (l_prim_currency_code IS NOT NULL) AND
           (get_missing_rate_rec.conversion_rate < 0)
     THEN
        l_stmt_num:=31;
        BIS_COLLECTION_UTILITIES.writemissingrate
          (l_prim_rate_type,
           get_missing_rate_rec.currency_code,
           l_prim_currency_code,
           get_missing_rate_rec.effective_date);
     END IF;

     -- Report missing conversion rates for secondary currency
     IF (l_sec_currency_code IS NOT NULL) AND
        (get_missing_rate_rec.conversion_rate_s = -3) AND (l_sec_euro_beg = 0)
     THEN
        l_stmt_num:=32;
        BIS_COLLECTION_UTILITIES.writemissingrate
        (l_sec_rate_type,
        get_missing_rate_rec.currency_code,
        l_sec_currency_code,
        l_euro_start_date);
        -- Missing rate on the Start of Euro Date has been encountered
        l_sec_euro_beg := 1;

     ELSIF (l_sec_currency_code IS NOT NULL) AND
           (get_missing_rate_rec.conversion_rate_s < 0)
     THEN
        l_stmt_num:=33;
        BIS_COLLECTION_UTILITIES.writemissingrate
        (l_sec_rate_type,
        get_missing_rate_rec.currency_code,
        l_sec_currency_code,
        get_missing_rate_rec.effective_date);
     END IF;
   END LOOP;

   CLOSE get_missing_rate_c;

   l_stmt_num := 34; /* check l_no_currency_rate_flag  */
   IF (l_no_currency_rate_flag = 1) THEN /* missing rate found */
    eni_dbi_util_pkg.log('Please setup conversion rate for all missing rates reported in the output file');
    return (-1);
   END IF;
  return (0);

EXCEPTION
 WHEN OTHERS THEN
   rollback;
   l_err_num := SQLCODE;
   l_err_msg := 'REPORT_MISSING_RATE (' || to_char(l_stmt_num)
     || '): '|| substr(l_err_num, 1,200);

--   eni_dbi_util_pkg.log('ENI_DBI_UCO_LOAD_PKG.REPORT_MISSING_RATE - Error at statement ('
  --           || to_char(l_stmt_num)  || ')');

   eni_dbi_util_pkg.log('Error Number: ' ||  to_char(l_err_num));
   eni_dbi_util_pkg.log('Error Message: ' || l_err_msg);
   RAISE;

END REPORT_MISSING_RATE ;

-- Incremental collection of cost
PROCEDURE incremental_item_cost_collect
(
  o_error_msg OUT NOCOPY VARCHAR2,
  o_error_code OUT NOCOPY VARCHAR2
) IS

  l_last_run_to_date_char varchar2(50);
  l_last_run_to_date date;
  l_exists_sc_orgs number;
  l_exists_ac_orgs number;
  l_application_user_id number;
  l_login_id number;
  rows_in_stage number;
  run_incremental boolean := FALSE;
  L_REPORT_MISSING_RATE number;
  l_processed_txn_id    number;
  l_processed_cost_id   number;
BEGIN

 IF(FND_INSTALLATION.GET_APP_INFO('ENI', l_status, l_industry, g_eni_schema))
  THEN NULL;
  END IF;


   if BIS_COLLECTION_UTILITIES.SETUP(
                  p_object_name => 'eni_dbi_item_cost_f',
                  p_parallel => 1) = false then
    RAISE_APPLICATION_ERROR(-20000,o_error_msg);
  end if;

  l_last_run_to_date_char := BIS_COLLECTION_UTILITIES.get_last_refresh_period('eni_dbi_item_cost_f');
  l_last_run_to_date := trunc(fnd_date.displayDT_to_date(BIS_COLLECTION_UTILITIES.get_last_refresh_period('eni_dbi_item_cost_f')));
  /** Bug: 4956685, 4936377
      Fetch the last Processed transaction id and cost update id from bis refresh log table.
  **/
  SELECT  MAX(decode(brl.attribute1,'mtl_material_transactions',attribute2,NULL))
         ,MAX(decode(brl.attribute3,'cst_elemental_costs'      ,attribute4,NULL))
  INTO   l_processed_txn_id, l_processed_cost_id
  FROM   bis_refresh_log brl
  WHERE  brl.object_name = 'eni_dbi_item_cost_f';

   eni_dbi_util_pkg.log('End Period of last cost collection was  ' || to_char(l_last_run_to_date));
   eni_dbi_util_pkg.log('Incremental cost collection will collect records on and after the above date');
   eni_dbi_util_pkg.log('Last processed transaction_id from mtl_material_transactions table as stored in bis_refresh_log table is:' || l_processed_txn_id);
   eni_dbi_util_pkg.log('Last processed cost update_id from cst_elemental_costs table as stored in bis_refresh_log table is:' || l_processed_cost_id);

--eni_dbi_util_pkg.log('End Period of last cost collection was  ' || to_char(l_last_run_to_date));
--eni_dbi_util_pkg.log('Incremental cost collection will collect records on and after the above date');
select FND_GLOBAL.USER_ID
into l_application_user_id
from sys.dual;

select FND_GLOBAL.LOGiN_ID
into l_login_id
from sys.dual;

select NVL(max(1),0)
into rows_in_stage
from eni_dbi_item_cost_stg;

IF (rows_in_stage = 0) THEN
   run_incremental := TRUE;
ELSE
   eni_dbi_util_pkg.log('The initial collection in the previous runs did not
   complete successfully. Hence at first shot, trying to collect the initial collection information');

   -- Calling if any of the conversion rates are still erroneous.

   eni_dbi_util_pkg.log('Retreiving currency conversion rates into rates table');
   populate_rates_table('INITIAL');

   l_report_missing_Rate := report_missing_rate();

   IF (l_report_missing_rate = 0) THEN -- initial collection completed normally.
       insert into /*+ append parallel(a) +*/ eni_dbi_item_cost_f
              (effective_date,
               inventory_item_id,
               organization_id,
               item_cost,
               material_cost,
               material_overhead_cost,
               resource_cost,
               outside_processing_cost,
               overhead_cost,
               primary_currency_rate,
               secondary_currency_rate,
               last_update_date,
               last_updated_by,
               creation_date,
               created_by,
               last_update_login)
       select  /*+ parallel(edicstg) parallel(eccrstg) */
               edicstg.effective_date,
               edicstg.inventory_item_id,
               edicstg.organization_id,
               edicstg.item_cost,
               edicstg.material_cost,
               edicstg.material_overhead_cost,
               edicstg.resource_cost,
               edicstg.outside_processing_cost,
               edicstg.overhead_cost,
               eccrstg.primary_rate,
               eccrstg.secondary_rate,
               edicstg.last_update_date,
               edicstg.last_updated_by,
               edicstg.creation_date,
               edicstg.created_by,
               edicstg.last_update_login
       from eni_dbi_item_cost_stg edicstg, eni_currency_conv_rates_stg eccrstg
       where edicstg.currency_code = eccrstg.currency_code
       and edicstg.effective_date = eccrstg.effective_date;
       --group by
       --        edicstg.effective_date,
       --        edicstg.inventory_item_id,
       --        edicstg.organization_id;

       COMMIT;
       eni_dbi_util_pkg.log('Initial cost collection Complete and Successful');
       execute immediate 'TRUNCATE TABLE '||g_eni_schema||'.eni_dbi_item_cost_stg';
-- Bug#3994228 This table should be truncated too
       execute immediate 'TRUNCATE TABLE '||g_eni_schema||'.eni_currency_conv_rates_stg';
       COMMIT;
   ELSIF (l_report_missing_rate = -1) THEN -- there were missing rates.
       execute immediate 'TRUNCATE TABLE '||g_eni_schema||'.eni_currency_conv_rates_stg';
       eni_dbi_util_pkg.log('Initial cost collection of previous runs has completed with errors.');
       eni_dbi_util_pkg.log('Please modify the conversion rates and execute the incremental collection again');
       o_error_code := 1;
       o_error_msg := 'Initial Cost Collection has completed with conversion rate errors';
       RETURN;
   END IF;
END IF;

-- Running the actual incremental collection
l_exists_sc_orgs := 0;
l_exists_ac_orgs := 0;

-- Find out if there are any standard costing orgs
select nvl(max(1),0)
into l_exists_sc_orgs
from sys.dual
where exists  (
               select 'There are standard costing orgs'
               from  mtl_parameters
               where primary_cost_method = 1
              );

-- Find out if there are any Avg/LIFO/FIFO orgs
select nvl(max(1),0)
into l_exists_ac_orgs
from sys.dual
where exists (
               select 'There are Avg/LIFO/FIFO costing orgs'
               from  mtl_parameters
               where primary_cost_method <> 1
              );

-- Get the cost history for standard costing orgs from cst_elemental_costs
if (l_exists_sc_orgs = 1) then
  eni_dbi_util_pkg.log('There are Standard Costing orgs, hence starting incremental cost collection for them');

 -- Inserting the changed records into stage
 /**
   Bug: 4936377 If the last Processed cost id cannot be queried from bis_refresh_log table compute it
   from cec table.
 **/
 IF l_processed_cost_id IS NULL THEN
   SELECT NVL( MAX( cost_update_id), 0)
   INTO   l_processed_cost_id
   FROM   cst_elemental_costs cec
   WHERE  cec.last_update_date  < l_last_run_to_date;
 END IF; -- l_processed_cost_id

 eni_dbi_util_pkg.log('Processing cst_elemental_costs.cost_update_id greater than ' || l_processed_cost_id);

 insert /*+ append parallel(a) */ into eni_dbi_item_cost_stg a
      (effective_date,
        inventory_item_id,
        organization_id,
        item_cost,
        material_cost,
        material_overhead_cost,
        resource_cost,
        outside_processing_cost,
        overhead_cost,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        currency_code,
        conversion_rate)
 select effective_date,
        inventory_item_id,
        organization_id,
        sum(standard_cost) item_cost,
        nvl(sum(decode(cost_element_id, 1, standard_cost)), 0) material_cost,
        nvl(sum(decode(cost_element_id, 2, standard_cost)), 0) material_overhead_cost,
        nvl(sum(decode(cost_element_id, 3, standard_cost)), 0) resource_cost,
        nvl(sum(decode(cost_element_id, 4, standard_cost)), 0) outside_processing_cost,
        nvl(sum(decode(cost_element_id, 5, standard_cost)), 0) overhead_cost,
        sysdate last_update_date,
        l_application_user_id last_updated_by,
        sysdate creation_date,
        l_application_user_id created_by,
        l_application_user_id last_update_login,
        currency_code,
        null --fii_currency.get_global_rate_primary(currency_code, effective_date) conversion_rate
   from (
         select
                cec.inventory_item_id,
                cec.organization_id,
                trunc(cec.last_update_date) effective_date,
                gsob.currency_code,
                cec.cost_element_id,
                cec.standard_cost,
                rank() over (partition by cec.inventory_item_id, cec.organization_id, trunc(cec.last_update_date),
                gsob.currency_code order by cec.cost_update_id desc) r
           from cst_elemental_costs cec,
                hr_organization_information hoi,
                gl_sets_of_books gsob
          where cec.organization_id = hoi.organization_id
            and hoi.org_information_context = 'Accounting Information'
            and hoi.org_information1 = to_char (gsob.set_of_books_id)
            and cec.cost_update_id >= l_processed_cost_id
           )
 where r = 1
 group by effective_date, inventory_item_id, organization_id, currency_code;

 end if;

commit;  -- commit the standard costing data into the staging.

-- Get the cost changes for average/LIFO/FIFO costing orgs from mtl_cst_actual_cost_details.
if (l_exists_ac_orgs = 1) then

    eni_dbi_util_pkg.log('There are Avg/LIFO/FIFO Costing orgs, hence starting incremental cost collection for them');

 -- Inserting the changed records into stage
     /**
     Bug: 4956685 If the last Processed txn id cannot be queried from bis_refresh_log table compute it
     from mmt table.
     **/
     IF l_processed_txn_id IS NULL THEN
        SELECT NVL( MAX( transaction_id), 0)
        INTO   l_processed_txn_id
        FROM   mtl_material_transactions mmt
        WHERE  mmt.transaction_date  < l_last_run_to_date;
     END IF; -- l_processed_txn_id

     /**
     Bug: 4956685 We have the last Processed transaction_id from mmt table
     This modified query will have a different nested query on the mmt table
     with a predicate on transaction_id instead of last_run_date
     */
     eni_dbi_util_pkg.log('Processing mtl_material_transactions.transaction_id greater than ' || l_processed_txn_id);

     insert /*+ append parallel(a) */ into eni_dbi_item_cost_stg a
     (effective_date,
     inventory_item_id, organization_id, item_cost, material_cost,
     material_overhead_cost, resource_cost, outside_processing_cost,
     overhead_cost, last_update_date, last_updated_by, creation_date,
     created_by, last_update_login, currency_code, conversion_rate)
     select /*+ parallel (x) parallel (mcacd) use_hash (mcacd, hoi, gsob)
     swap_join_inputs (gsob) pq_distribute (mcacd, hash, hash)
     pq_distribute
     (gsob, none, broadcast) */
     trunc(x.asofdate),
     mcacd.inventory_item_id,
     mcacd.organization_id,
     sum (mcacd.new_cost),
     nvl(sum(decode(mcacd.cost_element_id, 1, mcacd.new_cost)), 0) mtl,
     nvl(sum(decode(mcacd.cost_element_id, 2, mcacd.new_cost)), 0) mtl_ovh,
     nvl(sum(decode(mcacd.cost_element_id, 3, mcacd.new_cost)), 0) res,
     nvl(sum(decode(mcacd.cost_element_id, 4, mcacd.new_cost)), 0) osp,
     nvl(sum(decode(mcacd.cost_element_id, 5, mcacd.new_cost)), 0) ovhd,
     sysdate,
     1,
     sysdate,
     1,
     1,
     gsob.currency_code,
     null --fii_currency.get_global_rate_primary (gsob.currency_code,trunc(x.asofdate))
     from (
     select /*+ no_merge parallel(mmt) parallel(cql) parallel(mp)
            swap_join_inputs(cql) */ mmt.inventory_item_id,
     mmt.organization_id,
            cql.layer_id, max(mmt.transaction_id) transaction_id,
            trunc (mmt.transaction_date) asofdate
       from mtl_material_transactions mmt,
            cst_quantity_layers cql,
            mtl_parameters mp
      where mp.primary_cost_method <> 1
        and mp.default_cost_group_id = mmt.cost_group_id
        and mp.organization_id = mmt.organization_id
        and mmt.transaction_id  > l_processed_txn_id
        and mmt.inventory_item_id = cql.inventory_item_id
        and mmt.organization_id = cql.organization_id
        and mmt.cost_group_id = cql.cost_group_id
      group by mmt.inventory_item_id, mmt.organization_id,
     cql.layer_id,
            trunc (mmt.transaction_date)) x,
     mtl_cst_actual_cost_details mcacd,
     hr_organization_information hoi,
     gl_sets_of_books gsob
     where mcacd.transaction_id = x.transaction_id
     and mcacd.organization_id = x.organization_id
     and mcacd.layer_id = x.layer_id
     and x.organization_id = hoi.organization_id
     and hoi.org_information_context = 'Accounting Information'
     and hoi.org_information1 = to_char (gsob.set_of_books_id)
     group by trunc (x.asofdate), mcacd.inventory_item_id,
     mcacd.organization_id,
     gsob.currency_code;


end if;

commit;

   eni_dbi_util_pkg.log('Retreiving currency conversion rates into rates table');
   populate_rates_table('INCREMENTAL');

   eni_dbi_util_pkg.log('Checking if any missing conversion rates are present');
   l_report_missing_rate := report_missing_rate();
   IF (l_report_missing_rate = 0) THEN -- initial collection completed normally.
       merge into eni_dbi_item_cost_f old_costs
       using
       (select
               edicstg.effective_date,
               edicstg.inventory_item_id,
               edicstg.organization_id,
               edicstg.item_cost item_cost,
               edicstg.material_cost material_cost,
               edicstg.material_overhead_cost material_overhead_cost,
               edicstg.resource_cost resource_cost,
               edicstg.outside_processing_cost outside_processing_cost,
               edicstg.overhead_cost overhead_cost,
               eccrstg.primary_rate primary_rate,
               eccrstg.secondary_rate secondary_rate,
               edicstg.last_update_date last_update_date,
               edicstg.last_updated_by last_updated_by,
               edicstg.creation_date creation_date,
               edicstg.created_by created_by,
               edicstg.last_update_login last_update_login
        from eni_dbi_item_cost_stg edicstg, eni_currency_conv_rates_stg eccrstg
       where edicstg.currency_code = eccrstg.currency_code
       and edicstg.effective_date = eccrstg.effective_date
--        group by
  --             effective_date,
    --           inventory_item_id,
      --         organization_id
       ) new_costs
       on
          (old_costs.inventory_item_id = new_costs.inventory_item_id and
           old_costs.organization_id = new_costs.organization_id and
           old_costs.effective_date = new_costs.effective_date)
    when matched then
      update set old_costs.item_cost = new_costs.item_cost,
                 old_costs.material_cost = new_costs.material_cost,
                 old_costs.material_overhead_cost = new_costs.material_overhead_cost,
                 old_costs.resource_cost = new_costs.resource_cost,
                 old_costs.outside_processing_cost = new_costs.outside_processing_cost,
                 old_costs.overhead_cost = new_costs.overhead_cost,
                 old_costs.primary_currency_rate = new_costs.primary_rate,
                 old_costs.secondary_currency_rate = new_costs.secondary_rate,
                 old_costs.last_update_date = sysdate,
                 old_costs.last_updated_by = l_application_user_id,
                 old_costs.last_update_login = l_application_user_id
    when not matched then
      insert     (old_costs.effective_date
                   , old_costs.inventory_item_id
                   , old_costs.organization_id
                   , old_costs.item_cost
                   , old_costs.material_cost
                   , old_costs.material_overhead_cost
                   , old_costs.resource_cost
                   , old_costs.outside_processing_cost
                   , old_costs.overhead_cost
                   , old_costs.primary_currency_rate
                   , old_costs.secondary_currency_rate
                   , old_costs.last_update_date
                   , old_costs.last_updated_by
                   , old_costs.creation_date
                   , old_costs.created_by
                   , old_costs.last_update_login)
       values    ( new_costs.effective_date
                   , new_costs.inventory_item_id
                   , new_costs.organization_id
                   , new_costs.item_cost
                   , new_costs.material_cost
                   , new_costs.material_overhead_cost
                   , new_costs.resource_cost
                   , new_costs.outside_processing_cost
                   , new_costs.overhead_cost
                   , new_costs.primary_rate
                   , new_costs.secondary_rate
                   , sysdate
                   , l_application_user_id
                   , sysdate
                   , l_application_user_id
                   , l_application_user_id
                   );
       COMMIT;
       eni_dbi_util_pkg.log('Incremental cost collection is Complete and Successful');
       o_error_code := 0;
       o_error_msg := 'Incremental Cost Collection is Complete and Successful';

       --Bug: 4956685 Query the max txn id from mmt table
       SELECT Max(TRANSACTION_ID)
       INTO   l_processed_txn_id
       FROM   MTL_MATERIAL_TRANSACTIONS;

       --Bug: 4936377 Query the max cost update id from cec table
       SELECT Max(COST_UPDATE_ID)
       INTO   l_processed_cost_id
       FROM   cst_elemental_costs;

       BIS_COLLECTION_UTILITIES.WRAPUP(
                  p_status => true,
                  p_period_from => l_last_run_to_date,
                  p_period_to   => sysdate,
                  p_attribute1  => 'mtl_material_transactions',
                  p_attribute2  => l_processed_txn_id,
                  p_attribute3  => 'cst_elemental_costs',
                  p_attribute4  => l_processed_cost_id
                  );
   --execute immediate 'TRUNCATE TABLE '||g_eni_schema||'.eni_dbi_item_cost_stg';
   --execute immediate 'TRUNCATE TABLE '||g_eni_schema||'.eni_currency_conv_rates_stg';

   ELSE
       eni_dbi_util_pkg.log('Incremental cost collection has completed with errors in the conversion rates.');
       eni_dbi_util_pkg.log('Please modify the conversion rates and execute the incremental collection again.');
       o_error_code := 1;
       o_error_msg := 'Incremental Cost Collection has completed with conversion rate errors';
   END IF;

   execute immediate 'TRUNCATE TABLE '||g_eni_schema||'.eni_dbi_item_cost_stg';
   execute immediate 'TRUNCATE TABLE '||g_eni_schema||'.eni_currency_conv_rates_stg';
   COMMIT;

EXCEPTION

 WHEN OTHERS THEN

    o_error_code := sqlcode;
    o_error_msg := sqlerrm;

    eni_dbi_util_pkg.log('An error prevented the incremental cost collection from completing successfully');
    eni_dbi_util_pkg.log(o_error_code||':'||o_error_msg);
    Rollback;
        BIS_COLLECTION_UTILITIES.WRAPUP(
                  p_status => false,
                  p_period_from => l_last_run_to_date,
                  p_period_to => l_last_run_to_date
                  );
        RAISE_APPLICATION_ERROR(-20000,o_error_msg);

END incremental_item_cost_collect;

END ENI_DBI_UCO_LOAD_PKG;

/
