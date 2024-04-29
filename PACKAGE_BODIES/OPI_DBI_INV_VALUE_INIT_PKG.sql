--------------------------------------------------------
--  DDL for Package Body OPI_DBI_INV_VALUE_INIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_INV_VALUE_INIT_PKG" AS
/*$Header: OPIDIVIB.pls 120.31 2008/03/07 09:18:26 sdiwakar noship $ */

g_sysdate                 CONSTANT DATE   := SYSDATE;
g_user_id                 CONSTANT NUMBER := nvl(fnd_global.user_id, -1);
g_login_id                CONSTANT NUMBER := nvl(fnd_global.login_id, -1);
g_inception_date          DATE;
g_global_start_date       DATE;
g_global_curr_code        VARCHAR2(10);
g_global_sec_curr_code    VARCHAR2(10);
g_global_rate_type        VARCHAR2(32);
g_global_sec_rate_type    VARCHAR2(32);
g_R12_date                DATE;
g_pkg_name                CONSTANT VARCHAR2(200)  := 'OPI_DBI_INV_VALUE_INIT_PKG';
g_opi_schema              VARCHAR2(10);
--OPI_DBI_RPT_UTIL_PKG.g_pk_uom_conversion          number;
-- User Defined Exceptions

INITIALIZATION_ERROR EXCEPTION;
PRAGMA EXCEPTION_INIT (INITIALIZATION_ERROR, -20900);
UOM_CONV_ERROR EXCEPTION;
PRAGMA EXCEPTION_INIT (UOM_CONV_ERROR, -20901);

--RUN_FIRST_ETL
--     -->OPI_DBI_INV_VALUE_INIT_PKG.SEED_INV_TYPE_CODE
--
--     -->RUN_DISCRETE_FIRST_ETL
--          --->clean_staging_tables
--          --->OPI_DBI_BOUNDS_PKG.MAINTAIN_OPI_DBI_LOGS
--          --->EXTRACT_INVENTORY_TXN_QTY
--          --->EXTRACT_INVENTORY_TXN_VALUE
--          --->GET_INTRANSIT_INITIAL_LOAD
--                  ---->> INTRANSIT_SETUP
--
--     -->OPI_DBI_INV_VALUE_OPM_INIT_PKG.RUN_OPM_FIRST_ETL
--        --->OPI_DBI_INV_VALUE_OPM_INCR_PKG.EXTRACT_OPM_DAILY_ACTIVITY
--             ---->>OPI_DBI_INV_VALUE_OPM_INCR_PKG.OPM_REFRESH
--                  ----->>OPI_DBI_INV_VALUE_OPM_INCR_PKG.Get_OPM_Net_Activity
--                         ------>>>REFRESH_ONH_LED_CURRENT
--                         ------>>>REFRESH_RVAL_LED_CURRENT
--                         ------>>>REFRESH_ITR_LED_CURRENT
--                         ------>>>REFRESH_IOR_LED_CURRENT
--                         ------>>>REFRESH_WIP_LED_CURRENT
--                         ------>>>PUT_NET_ACTIVITY_TO_STG
--     -->GET_INCEPTION_INV_BALANCE
--          --->GET_ONHAND_BALANCE
--          --->GET_INTRANSIT_BALANCE
--          --->GET_WIP_BALANCE
--          --->COST_DISCRETE_INCEPTION_QTY
--          --->COST_OPM_INCEPTION_QUANTITY
--     -->GET_CONVERSION_RATE
--     -->MERGE_INITIAL_LOAD
--     -->clean_staging_tablesS
--     -->OPI_DBI_INV_CPCS_PKG.Run_Period_Close_Adjustment
--     -->OPI_DBI_BOUNDS_PKG.bounds_uncosted
--     -->OPI_DBI_BOUNDS_PKG.print_opi_org_bounds
--     -->OPI_DBI_BOUNDS_PKG.SET_LOAD_SUCCESSFUL


--   Design Highlights
-- 1.  Data Flow is different in Initial and Incremental Loads. One of the
   --main reasons for this is that we want to extract all our data once
   --for activity collection and calculating beginning balance in initial load.
-- 2.  In the initial load we extract quantity and value separately.
   --Quantity for process and discrete organizations are extracted at
   --once from MMt. Value from various tables like MTA, GTV and WTA
   --are extracted together for process and discrete organizations.
   --Other data is also extracted from WPB and MOQ is also
   --extracted at the same time to ensure read consistency.
-- 3.  For Value MTA is hit once to get Onhand as well as WIP Value
   --because MTA is accessed for same transaction_id range for these
   --two measures. This is the reason as why OPI_DBI_ONHAND_STG
   --now has Onhand AND WIP value columns both.
-- 4.  In the incremental load the quantity and value are extracted together
   --once for discrete organization and then for process organizations.
-- 5.  In initial load PUSH_TO_FACT_FLAG is used in order to distinguish
   --between the records which are within the bounds and those which are
   --outside the bound. Data is collected outside the bound in order to
   --compute beginning balance. Consideration is taken to have extracts
   --in same union all in order to maintain the read consistency.
-- 6.  In the staging table and fact there are two columns for quantity and
   --value measures. E.g. ONHAND_QTY and ONHAND_QTY_DRAFT. There is a
   --difference the way data is hold in staging tables and in the fact.
   --In the Staging table _DRAFT column stores data coming from MMT which
   --are draft posted. The column without _DRAFT holds data coming from
   --records posted to final ledger. But in the Fact _DRAFT contains same
   --data but the column without _DRAFT holds sum of total
   --final posted data and draft posted data.
-- 7.  DRAFT columns are used only for process organizations.
   --For discrete orgs these will hold zero/null values.
   --Purpose of having DRAFT columns is to know the draft posted value  in
   --last run as incremental loads re-collect all the draft posted records.
-- 8.  LOG table maintenance is centralized.
   --There is one record for INVENTORY etl for each driving table
   --i.e. MMT, GTV and WTA.
-- 9.  For MMT bounds are based on transaction_id.
     --Process stops at first uncosted txn id found.
     --At the same time date is stamped for GTV upto which data from GTV
     --is collected. From GTV data is selected based on
     --final_posted_date < bound_date or accounted_flag = 'D'.
     --So this is possible that there are some new transactions in between
     --the time when quantity from MMT is extracted and value from GTV is
     --extracted and are posted to Draft ledger. So the quantity and value
     --could be little out of synch. But this would be corrected whenever next
     -- incremental load is run.
-- 10. Similar to the point above, at the same time when first uncosted txn id
   -- is found the max transaction_id from WTA is taken and this is set as
   --bound for extraction from WTA. So it is possible that material txns
   --collected and resource txns collected are not in synch as there could be
   --few uncosted material txns.
-- 11. Data is collect from OPM old data model in case GSD < R12 installation
   --date . This data is also used to rollback to the beginning balance.
-- 12. Inception To Date is GSD for all organizations.
   --Beginning balance record will have transaction date as GSD.


-------------------------------------------------------------------------------
--This procedure will populate value for global variables
-- like GSD, currency codes and rates



PROCEDURE CHECK_INITIAL_LOAD_SETUP
IS
     l_proc_name    VARCHAR2 (40);
     l_stmt_num     NUMBER;
     l_setup_good   BOOLEAN;
     l_status       VARCHAR2(30) := NULL;
     l_industry     VARCHAR2(30) := NULL;
     l_debug_msg    VARCHAR2(200);
BEGIN
     -- Initialization
     l_proc_name := 'CHECK_INITIAL_LOAD_SETUP';
     l_stmt_num := 0;

     -- Check for the global start date setup.
     -- These parameter must be set up prior to any DBI load.
     g_global_start_date       := trunc(bis_common_parameters.get_global_start_date);
     g_global_curr_code        := bis_common_parameters.get_currency_code;
     g_global_sec_curr_code    := bis_common_parameters.get_secondary_currency_code;
     g_global_rate_type        := bis_common_parameters.get_rate_type;
     g_global_sec_rate_type    := bis_common_parameters.get_secondary_rate_type;

     IF (g_global_start_date IS NULL) THEN
           l_debug_msg := 'Global start date is not defined';
           RAISE INITIALIZATION_ERROR;
     END IF;

     IF (g_global_curr_code IS NULL) THEN
           l_debug_msg := 'Global currency code is not defined';
           RAISE INITIALIZATION_ERROR;
     END IF;

     IF (g_global_rate_type IS NULL) THEN
           l_debug_msg := 'Global rate type is not defined';
           RAISE INITIALIZATION_ERROR;
     END IF;

     IF (g_global_sec_curr_code IS NOT NULL AND g_global_sec_rate_type IS NULL) THEN
           l_debug_msg := 'Global secondary rate type is not defined';
           RAISE INITIALIZATION_ERROR;
     END IF;

     IF (g_global_sec_rate_type IS NOT NULL AND g_global_sec_curr_code IS NULL) THEN
           l_debug_msg := 'Global secondary curr code is not defined';
           RAISE INITIALIZATION_ERROR;
     END IF;

     l_setup_good := fnd_installation.get_app_info('OPI', l_status, l_industry, g_opi_schema);
     IF (l_setup_good = FALSE OR g_opi_schema IS NULL) THEN
           l_debug_msg := 'could not find OPI schema';
           RAISE INITIALIZATION_ERROR;
     END IF;
EXCEPTION
WHEN INITIALIZATION_ERROR THEN
     OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);
     RAISE;

    WHEN OTHERS THEN
    l_debug_msg := 'Failed with errror '  ||  SQLcode || ' -  ' ||SQLERRM;
    OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);
     RAISE;

END CHECK_INITIAL_LOAD_SETUP;


-------------------------------------------------------------------------------
-- Truncates all the staging Tables, LOG Table and the FACT Tables as well.
-- As these are truncate statements this procedure does a commit.
--   Common/Misc Tables:
--   OPI_DBI_OPM_INV_LED_CURRENT
--   OPI_DBI_OPM_INV_STG
--   OPI_DBI_CONVERSION_RATES
--   OPI_DBI_INV_ITEM_COSTS_TMP
--   OPI_PMI_COST_PARAM_GTMP
--   OPI_DBI_INV_VALUE_LOG -- added as part of CPCS Change.
--   Note: OPI_DBI_INV_TYPE_CODES is not cleaned anywhere.
--   Intransit Tables:
--   OPI_DBI_INTR_SUP_TMP
--   OPI_DBI_INTR_MMT_TMP
--   OPI_DBI_INTR_MIP_TMP
--   OPI_DBI_INTRANSIT_STG
--   WIP Tables
--   OPI_DBI_WIP_STG
--   Onhand WIP Tables
--   OPI_DBI_ONH_QTY_STG
--   OPI_DBI_INV_BEG_STG
--   OPI_DBI_ONHAND_STG
--   IF p_stage = 'PRE_INIT' THEN
--      Cleanup the OPI_DBI_INV_VALUE_F
PROCEDURE clean_staging_tables(p_stage varchar2)
IS
     l_stmt_num      NUMBER;
     l_debug_msg     VARCHAR2(1000);
     l_proc_name     VARCHAR2 (60);
     l_debug_mode    VARCHAR2(1);
     l_module_name   VARCHAR2(30);
BEGIN
     l_proc_name     :=  'clean_staging_tables';
     l_debug_mode    :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
     l_module_name   :=  FND_PROFILE.value('AFLOG_MODULE');

     l_stmt_num := 0;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Start of cleaning staging table';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     l_stmt_num := 10;
     execute immediate 'truncate table ' || g_opi_schema || '.OPI_DBI_OPM_INV_LED_CURRENT';

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'OPI_DBI_OPM_INV_LED_CURRENT table truncated';
          OPI_DBI_BOUNDS_PKG.write (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     l_stmt_num := 20;
     execute immediate 'truncate table ' || g_opi_schema || '.OPI_DBI_OPM_INV_STG';

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'OPI_DBI_OPM_INV_STG table truncated';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     l_stmt_num := 30;
     execute immediate 'truncate table ' || g_opi_schema || '.OPI_DBI_CONVERSION_RATES';

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'OPI_DBI_CONVERSION_RATES table truncated';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     -- Added opi_dbi_inv_value_log truncate for CPCS. This table should not be truncated in incremental load.
     -- This log table is only used in CPCS code line.
     l_stmt_num := 40;
     execute immediate 'truncate table ' || g_opi_schema || '.OPI_DBI_INV_VALUE_LOG';

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'OPI_DBI_INV_VALUE_LOG table truncated';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     -- l_stmt_num := 40;
     -- as we are not using OPM costing API we need not truncate this table
     -- execute immediate 'truncate table ' || g_opi_schema || '.OPI_DBI_INV_ITEM_COSTS_TMP';

     -- l_stmt_num := 50;
     -- not required to be truncated. used only in old code
     -- execute immediate 'truncate table ' || g_opi_schema || '.OPI_PMI_COST_PARAM_GTMP';

     l_stmt_num := 60;
     execute immediate 'truncate table ' || g_opi_schema || '.OPI_DBI_INTR_SUP_TMP';

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'OPI_DBI_INTR_SUP_TMP table truncated.';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     l_stmt_num := 70;
     execute immediate 'truncate table ' || g_opi_schema || '.OPI_DBI_INTR_MMT_TMP';

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'OPI_DBI_INTR_MMT_TMP table truncated.';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg);
     END IF;

     l_stmt_num := 80;
     execute immediate 'truncate table ' || g_opi_schema || '.OPI_DBI_INTR_MIP_TMP';

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'OPI_DBI_INTR_MIP_TMP table truncated.';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     l_stmt_num := 90;
     execute immediate 'truncate table ' || g_opi_schema || '.OPI_DBI_INTRANSIT_STG';

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'OPI_DBI_INTRANSIT_STG table truncated.';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     l_stmt_num := 100;
     execute immediate 'truncate table ' || g_opi_schema || '.OPI_DBI_WIP_STG';

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'OPI_DBI_WIP_STG table truncated.';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     l_stmt_num := 110;
     execute immediate 'truncate table ' || g_opi_schema || '.OPI_DBI_ONH_QTY_STG';

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'OPI_DBI_ONH_QTY_STG table truncated.';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     l_stmt_num := 120;
     execute immediate 'truncate table ' || g_opi_schema || '.OPI_DBI_INV_BEG_STG';

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'OPI_DBI_INV_BEG_STG table truncated.';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     l_stmt_num := 130;
     execute immediate 'truncate table ' || g_opi_schema || '.OPI_DBI_ONHAND_STG';

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'OPI_DBI_ONHAND_STG table truncated.';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     IF p_stage = 'PRE_INIT' THEN

          l_stmt_num := 150;
          execute immediate 'truncate table ' || g_opi_schema || '.OPI_DBI_INV_VALUE_F';

          IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
               l_debug_msg := 'OPI_DBI_INV_VALUE_F table truncated.';
               OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
          END IF;

     END IF;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'End of cleaning staging table';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;
EXCEPTION
    WHEN OTHERS THEN
         l_debug_msg := 'Failed with errror '  ||  SQLcode || ' - ' ||SQLERRM;
         OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);
         RAISE;
END clean_staging_tables;


-------------------------------------------------------------------------------

PROCEDURE COST_DISCRETE_INCEPTION_QTY
IS
     l_stmt_num     NUMBER;
     l_debug_msg    VARCHAR2(1000);
     l_proc_name    VARCHAR2 (60);
     l_debug_mode   VARCHAR2(1);
     l_module_name  VARCHAR2(30);

BEGIN
     l_proc_name    :=  'COST_DISCRETE_INCEPTION_QTY';
     l_debug_mode   :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
     l_module_name  := FND_PROFILE.value('AFLOG_MODULE');

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Entered Into COST_DISCRETE_INCEPTION_QTY  ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;


    -- Get costs as of the inception date.
    --
    -- For standard costing orgs, get the cost as of the
    -- last cost update prior to the global start date.
    --
    -- For layer costing orgs, get the first transaction from MMT after the
    -- global start date for each org, item, cost group and pick the
    -- prior cost of the transaction.
    --
    -- The cost method for all orgs is a non-null column of the
    -- mtl_parameters table.
    --
    -- Since we want cost group information, use the non-null default
    -- cost group id from mtl_parameters for standard costing orgs. For
    -- layer costing orgs, get the cost group from MMT and if that is
    -- null, then replace it with default cost group.

          l_stmt_num :=10;
          IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
               l_debug_msg := 'Inserting data into OPI_DBI_INV_BEG_STG from inception date less than gsd';
               OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
               l_debug_msg := 'for standard costing organization';
               OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
          END IF;


          UPDATE OPI_DBI_INV_BEG_STG  fact
                  SET (onhand_value_b ,intransit_value_b) =
              (SELECT  /*+ ordered use_hash(csc2, csc) parallel(csc2) parallel(csc)*/
            -- ideally max is not required as standard cost
            -- revision date is timestamp.
                  max(csc.standard_cost) *onhand_qty onhand_value_b,
                  max(csc.standard_cost) *intransit_qty intransit_value_b
               FROM   (
                       SELECT  /*+ use_hash(p csc) parallel(csc)
                                   parallel(mtl_parameters) */
                          csc.organization_id,
                          csc.inventory_item_id,
                 -- this is a a timestamp hence max would
                 -- give unique record.
                          max(standard_cost_revision_date) standard_cost_revision_date,
                          p.primary_cost_method cost_method,
                          NULL cost_group_id          -- RS:  Bug fix 5219487 p.default_cost_group_id cost_group_id
                         FROM mtl_parameters p,
                              cst_standard_costs csc
                -- not using <= below because txns are
                -- collected from GSD onward. hence if there is
                -- any cost update as of GSD additional 24 txns
                -- will come in separately.
                         WHERE standard_cost_revision_date < g_global_start_date
                           AND p.primary_cost_method = 1
                           AND p.organization_id = csc.organization_id
                         GROUP BY csc.organization_id,
                                  csc.inventory_item_id,
                                  p.primary_cost_method,
                                  p.default_cost_group_id
                      ) csc2,
                      cst_standard_costs csc
                WHERE csc.organization_id = csc2.organization_id
                  AND csc.inventory_item_id = csc2.inventory_item_id
                  AND csc.standard_cost_revision_date = csc2.standard_cost_revision_date
                  and fact.organization_id = csc2.organization_id
                  and fact.inventory_item_id =csc2.inventory_item_id
              --  and fact.cost_group_id =csc2.cost_group_id        -- RS:  Bug fix 5219487
              --  and fact.cost_method =csc.cost_method
                GROUP BY csc.organization_id,
                         csc.inventory_item_id,
                         csc2.cost_method,
                         csc2.cost_group_id)
          where ( nvl(fact.onhand_qty,0) <> 0 or   nvl(fact.intransit_qty,0) <> 0 );

          l_debug_msg := 'Updated into staging table OPI_DBI_INV_BEG_STG for ODM - ' || SQL%ROWCOUNT || ' rows. ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);

          l_stmt_num := 20;
          IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
               l_debug_msg := 'Updated staging table OPI_DBI_INV_BEG_STG from inception date greater than gsd';
               OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
               l_debug_msg := 'for standard costing organization';
               OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
          END IF;


      -- if cost is not found after earlier step (which means there
      -- are no cost updates prior to GSD, we try to see if there are
      -- any cost updates post GSD. In case there are cost updates
      -- after GSD then take the cost from first MMT inventory txn to
      -- know the item cost as of GSD.

      -- We have to look into MMT here because CSC does not store
      -- the prior cost in case a cost revision is done and we would
      -- have lost the cost as of GSD from CIC as well.

      -- as the cost is not available on the txns following txns
      -- are excluded from here. scrap, lot merge, lot split, logical
      -- and lot qty update. Avg cost and layer cost updates,
      -- container pack, unpack, split.

         UPDATE OPI_DBI_INV_BEG_STG  fact
                  SET (onhand_value_b ,intransit_value_b) =
          (SELECT  /*+ NO_MERGE, leading(mmt1) */
             mmt2.prior_cost * onhand_qty onhand_value_b,
             mmt2.prior_cost *intransit_qty intransit_value_b
           FROM  (
                 SELECT  /*+ leading (stg1) */
                     mmt.organization_id,
                     mmt.inventory_item_id,
                     NULL  cost_group_id, --RS: Bug fix 5219487 nvl (mmt.cost_group_id, p.default_cost_group_id) cost_group_id,
                     min(mmt.transaction_id) trx_id
                   FROM  mtl_material_transactions mmt,
                         OPI_DBI_INV_BEG_STG stg,
                         mtl_parameters p
                   WHERE primary_cost_method = 1
                     AND stg.organization_id = p.organization_id
                     AND stg.inventory_item_id = mmt.inventory_item_id
                     AND stg.organization_id = mmt.organization_id
                     AND mmt.transaction_date >=g_global_start_date
                     And mmt.transaction_type_id not in (73,25,26,90,91,92,55,56,57,58,87,88,89)
                     AND nvl(mmt.logical_transaction,0) <> 1
                     AND nvl(mmt.owning_tp_type, 2) = 2
                     AND mmt.organization_id =  NVL (mmt.owning_organization_id,
                                                     mmt.organization_id)
                     and mmt.costed_flag is null
                     AND new_cost is not null
                     AND ((stg.onhand_value_b is null and nvl(stg.onhand_qty,0) <> 0 )
                         OR  (stg.intransit_value_b is null and nvl(stg.intransit_qty,0) <> 0 ))
                     and  exists
                           (select 1 from cst_standard_costs csc
                           where stg.inventory_item_id = csc.inventory_item_id
                              AND stg.organization_id = csc.organization_id
                                and standard_cost_revision_date >= g_global_start_date)
                   GROUP BY mmt.organization_id,
                            mmt.inventory_item_id  -- ,
                            -- nvl (mmt.cost_group_id, p.default_cost_group_id),  --RS: Bug fix 5219487
                            -- p.primary_cost_method
                 ) mmt1,
                 mtl_material_transactions mmt2
           WHERE mmt2.transaction_id = mmt1.trx_id
             and fact.organization_id = mmt1.organization_id
             and fact.inventory_item_id =mmt1.inventory_item_id
            -- and fact.cost_group_id =mmt1.cost_group_id        -- RS:  Bug fix 5219487
             and ((fact.onhand_value_b is null and nvl(fact.onhand_qty,0) <> 0)
                    or  (fact.intransit_value_b is null and  nvl(fact.intransit_qty,0) <> 0 ))
             )
             where ((fact.onhand_value_b is null and nvl(fact.onhand_qty,0) <> 0)
                    or  (fact.intransit_value_b is null and  nvl(fact.intransit_qty,0) <> 0 ));

          l_debug_msg := 'Updating staging table table OPI_DBI_INV_BEG_STG for ODM - ' || SQL%ROWCOUNT || ' rows. ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);

          l_stmt_num := 30;
          IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
               l_debug_msg := 'updated data into OPI_DBI_INV_BEG_STG for standard costing organization';
               OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
               l_debug_msg := 'form cst_item_costs for which cost is not found till now';
               OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
          END IF;


          -- step 3 for standard costing org items.
       -- as mentioned in step2 for the items where there are no
       -- cost updates prior and post GSD the item cost is available
       -- in CIC. Hence for such items update the cost.

          UPDATE OPI_DBI_INV_BEG_STG  fact
                  SET (onhand_value_b ,intransit_value_b) =
         (SELECT  /*+ ordered use_hash(csc2, csc) parallel(csc2) parallel(csc)*/
            nvl(csc.item_cost,0) *onhand_qty onhand_value_b,
            nvl(csc.item_cost,0) *intransit_qty intransit_value_b
          FROM   cst_item_costs csc
           WHERE csc.organization_id = fact.organization_id
             AND csc.inventory_item_id = fact.inventory_item_id
             And csc.cost_type_id =1 )
          WHERE ((fact.onhand_value_b is null and nvl(fact.onhand_qty,0) <> 0)
                  or  (fact.intransit_value_b is null and nvl(fact.intransit_qty,0) <> 0 ));

          l_debug_msg := 'updated into staging table OPI_DBI_INV_BEG_STG for ODM - ' || SQL%ROWCOUNT || ' rows. ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);

          l_stmt_num := 40;
          IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
               l_debug_msg := 'updating data into OPI_DBI_INV_BEG_STG for Non standard costing organization';
               OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
          END IF;


          -- Cost update for average costing orgs.
       -- get a txn after GSD and prior cost on this txn is the
       -- item cost as of the GSD for average costing org.
          UPDATE OPI_DBI_INV_BEG_STG  fact
                  SET (onhand_value_b ,intransit_value_b) =
          (SELECT  /*+ NO_MERGE, leading(mmt1) */
             mmt2.prior_cost * onhand_qty onhand_value_b,
             mmt2.prior_cost *intransit_qty intransit_value_b
           FROM  (
                 SELECT  /*+ leading (stg1) */
                     mmt.organization_id,
                     mmt.inventory_item_id,
                     nvl (mmt.cost_group_id, p.default_cost_group_id) cost_group_id,
                     p.primary_cost_method cost_method,
                     min(mmt.transaction_id) trx_id
                   FROM  mtl_material_transactions mmt,
                         OPI_DBI_INV_BEG_STG stg,
                         mtl_parameters p
                   WHERE primary_cost_method <> 1
                     AND stg.organization_id = p.organization_id
                     AND stg.inventory_item_id = mmt.inventory_item_id
                     AND stg.organization_id = mmt.organization_id
                     AND mmt.transaction_date >= g_global_start_date
                     AND mmt.organization_id =  NVL (mmt.owning_organization_id,mmt.organization_id)
                     AND nvl(mmt.owning_tp_type, 2) = 2
                     AND new_cost is not null
                     AND ((stg.onhand_value_b is null and nvl(stg.onhand_qty,0) <> 0 )
                         OR  (stg.intransit_value_b is null and nvl(stg.intransit_qty,0) <> 0 ))
                   GROUP BY mmt.organization_id,
                            mmt.inventory_item_id,
                            nvl (mmt.cost_group_id, p.default_cost_group_id),
                            p.primary_cost_method
                 ) mmt1,
                 mtl_material_transactions mmt2
           WHERE mmt2.transaction_id = mmt1.trx_id
             and fact.organization_id = mmt1.organization_id
             and fact.inventory_item_id =mmt1.inventory_item_id
             and fact.cost_group_id =mmt1.cost_group_id
             --and fact.cost_method =mmt2.cost_method
             and ((fact.onhand_value_b is null and nvl(fact.onhand_qty,0) <> 0)
             or  (fact.intransit_value_b is null and nvl(fact.intransit_qty,0) <> 0 ))
             )
          WHERE ((fact.onhand_value_b is null and nvl(fact.onhand_qty,0) <> 0)
                  or  (fact.intransit_value_b is null and nvl(fact.intransit_qty,0) <> 0 ));

          l_debug_msg := 'updated into staging table OPI_DBI_INV_BEG_STG for ODM - ' || SQL%ROWCOUNT || ' rows. ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);

          l_stmt_num := 50;
          IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
               l_debug_msg := 'updating data into OPI_DBI_INV_BEG_STG for Non standard costing organization';
               OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
          END IF;



     -- In case there is no txn found in MMT after GSD then get the
     -- cost from CQL Table as this mean there are no cost updates
     -- after GSD.
     -- item, org and cost_group is unique in this table.
          UPDATE OPI_DBI_INV_BEG_STG  fact
               SET (onhand_value_b ,intransit_value_b) =
               (SELECT
                    nvl(cst.item_cost,0) * onhand_qty onhand_value_b,
                    nvl(cst.item_cost,0) * intransit_qty intransit_value_b
                     FROM  cst_quantity_layers cst,
                         mtl_parameters mp
                     WHERE mp.organization_id = fact.organization_id
                      AND primary_cost_method <> 1
                       AND cst.organization_id = fact.organization_id
                       AND cst.cost_group_id  = fact.cost_group_id
                       AND cst.inventory_item_id = fact.inventory_item_id
                       AND ((fact.onhand_value_b is null and nvl(fact.onhand_qty,0) <> 0 )
                         OR  (fact.intransit_value_b is null and nvl(fact.intransit_qty,0) <> 0 ))
                     )
          WHERE ((fact.onhand_value_b is null and nvl(fact.onhand_qty,0) <> 0 )
               OR  (fact.intransit_value_b is null and nvl(fact.intransit_qty,0) <> 0 ));


          l_debug_msg := 'updated into staging table OPI_DBI_INV_BEG_STG for ODM - ' || SQL%ROWCOUNT || ' rows. ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);

     commit;


     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Exit from COST_DISCRETE_INCEPTION_QTY  ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

    -- 11.5.10 change to match costing team's method for obtaining
    -- standard costs for an item. Added items with no standard cost
    -- before global start date. For these items, we are adding the
    -- earliest cost after or on the global start date

EXCEPTION
     WHEN OTHERS THEN
     l_debug_msg := 'Failed with errror '  ||  SQLcode || ' - ' ||SQLERRM;
     OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);
     RAISE;

END COST_DISCRETE_INCEPTION_QTY;
-------------------------------------------------------------------------------
FUNCTION GET_OPM_ITEM_COST( l_organization_id NUMBER,
                   l_inventory_item_id NUMBER,
                   l_txn_date DATE)
RETURN NUMBER
IS
     x_total_cost NUMBER;
     x_no_cost NUMBER;
     x_return_status VARCHAR2(1);
     x_msg_count NUMBER;
     x_msg_data VARCHAR2(2000);
     x_cost_method cm_mthd_mst.cost_mthd_code%TYPE;
     x_cost_component_class_id cm_cmpt_mst.cost_cmpntcls_id%TYPE;
     x_cost_analysis_code cm_alys_mst.cost_analysis_code%TYPE;
     x_no_of_rows NUMBER;
     l_ret_value NUMBER;
     l_stmt_num     NUMBER;
     l_debug_msg    VARCHAR2(1000);
     l_proc_name    VARCHAR2 (60);
     l_debug_mode   VARCHAR2(1);
     l_module_name  VARCHAR2(30);

BEGIN
     l_proc_name    :=  'GET_OPM_ITEM_COST';
     l_debug_mode   :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
     l_module_name  := FND_PROFILE.value('AFLOG_MODULE');
     x_no_cost      := NULL;

     l_ret_value := GMF_CMCOMMON.Get_Process_Item_Cost
        (
           P_API_VERSION     =>        1.0
          ,P_INIT_MSG_LIST   =>        FND_API.G_FALSE
          ,X_RETURN_STATUS   =>        x_return_status
          ,X_MSG_COUNT       =>        x_msg_count
          ,X_MSG_DATA         =>       x_msg_data
          ,P_INVENTORY_ITEM_ID =>      l_inventory_item_id
          ,P_ORGANIZATION_ID   =>      l_organization_id
          ,P_TRANSACTION_DATE  =>      l_txn_date
          ,P_DETAIL_FLAG       =>      1
          ,P_COST_METHOD       =>      x_cost_method
          ,P_COST_COMPONENT_CLASS_ID => x_cost_component_class_id
          ,P_COST_ANALYSIS_CODE  =>    x_cost_analysis_code
          ,X_TOTAL_COST          =>    x_total_cost
          ,X_NO_OF_ROWS          =>    x_no_of_rows
        );

     IF l_ret_value <> 1
     THEN
          return x_no_cost;
     ELSE
          return x_total_cost;
     END IF;
EXCEPTION
     WHEN OTHERS THEN
     l_debug_msg := 'Failed with errror '  ||  SQLcode || ' - ' ||SQLERRM;
     OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);
     RAISE;

END GET_OPM_ITEM_COST;

-------------------------------------------------------------------------------
--This proceudure will cost OPM inception data
PROCEDURE COST_OPM_INCEPTION_QTY
IS
     l_stmt_num     NUMBER;
     l_debug_msg    VARCHAR2(1000);
     l_proc_name    VARCHAR2 (60);
     l_debug_mode   VARCHAR2(1);
     l_module_name  VARCHAR2(30);
     l_opm_cost     NUMBER;
     l_row_count    NUMBER;
     CURSOR opm_org_cost_csr
     IS
        SELECT distinct
               fact.organization_id,
               fact.inventory_item_id,
               fact.transaction_date
        FROM OPI_DBI_INV_BEG_STG fact,
             mtl_parameters p
        WHERE fact.organization_id = p.organization_id
          AND p.process_enabled_flag ='Y'
        ORDER BY fact.organization_id ,
               fact.inventory_item_id,
               fact.transaction_date;

BEGIN

     l_proc_name    :=  'COST_OPM_INCEPTION_QTY';
     l_debug_mode   :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
     l_module_name  := FND_PROFILE.value('AFLOG_MODULE');
     l_row_count    := 0;

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Entered Into COST_OPM_INCEPTION_QTY  ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     l_stmt_num :=10;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Inserting data into OPI_DBI_INV_BEG_STG for Process costing organization';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     /*UPDATE OPI_DBI_INV_BEG_STG  fact
             SET (onhand_value_b ,intransit_value_b, COST_FOUND_FLAG) =
     (SELECT onhand_qty * GET_OPM_ITEM_COST(fact.organization_id, fact.inventory_item_id,fact.transaction_date) onhand_value_b,
             intransit_qty * GET_OPM_ITEM_COST(fact.organization_id, fact.inventory_item_id,fact.transaction_date) intransit_value_b,
             NULL
          FROM dual, mtl_parameters mp
     WHERE mp.organization_id =fact .organization_id
     AND mp.process_enabled_flag ='Y'
     );*/
     FOR opm_org_cost_info IN opm_org_cost_csr
     LOOP
          l_opm_cost := GET_OPM_ITEM_COST(l_organization_id => opm_org_cost_info.organization_id,
                                          l_inventory_item_id => opm_org_cost_info.inventory_item_id,
                                           l_txn_date => opm_org_cost_info.transaction_date);

          UPDATE OPI_DBI_INV_BEG_STG  fact
                  SET onhand_value_b =onhand_qty * l_opm_cost
                     ,intransit_value_b = intransit_qty * l_opm_cost
             where fact.organization_id =opm_org_cost_info.organization_id
           AND fact.inventory_item_id =opm_org_cost_info.inventory_item_id;

          l_row_count := l_row_count + SQL%ROWCOUNT ;

     END LOOP;

     l_debug_msg := 'Updated staging table OPI_DBI_INV_BEG_STG for OPM - ' || l_row_count || ' rows. ';
     OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);

     commit;


     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Exit from COST_OPM_INCEPTION_QTY  ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

EXCEPTION
     WHEN OTHERS THEN
     l_debug_msg := 'Failed with errror '  ||  SQLcode || ' - ' ||SQLERRM;
     OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);
     RAISE;

END COST_OPM_INCEPTION_QTY;


-------------------------------------------------------------------------------
--This procedure will provide on hand values
-- in table OPI_DBI_INV_BEG_STG

PROCEDURE GET_ONHAND_BALANCE
IS
     l_stmt_num     NUMBER;
     l_debug_msg    VARCHAR2(1000);
     l_proc_name    VARCHAR2 (60);
     l_debug_mode   VARCHAR2(1);
     l_module_name  VARCHAR2(30);

BEGIN

     l_proc_name    :=  'GET_ONHAND_BALANCE';
     l_debug_mode   :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
     l_module_name  := FND_PROFILE.value('AFLOG_MODULE');

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Entered Into GET_ONHAND_BALANCE  ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     l_stmt_num :=10;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Inserting data into OPI_DBI_INV_BEG_STG ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     INSERT INTO OPI_DBI_INV_BEG_STG
     (organization_id
     ,subinventory_code
     ,cost_group_id
     ,inventory_item_id
     ,transaction_date
     ,onhand_qty
     )
     SELECT balance.organization_id
           ,balance.subinventory_code
           ,balance.cost_group_id
           ,balance.inventory_item_id
           ,g_global_start_date
           ,sum(balance.onhand_qty)
      FROM (SELECT stg1.organization_id
                  ,stg1.subinventory_code
                  ,stg1.cost_group_id
                  ,stg1.inventory_item_id
                  -- beginning balance = current balance from moq - all activities from MMT
                  -- it is assumed that there are no draft quantities as of GSD
                  ,decode(stg1.transaction_source,'MOQ',stg1.onhand_qty
                                            ,'MMT',-1*(stg1.onhand_qty+stg1.onhand_qty_draft)
                                            ,0) onhand_qty
              FROM opi_dbi_onh_qty_stg stg1
             WHERE transaction_source IN ('MMT','MOQ')
             UNION ALL
             SELECT stg2.organization_id
                   ,stg2.subinventory_code
                   ,-1 cost_group_id -- there is no cost_group_id required for opm items for finding cost
                   ,stg2.inventory_item_id
                   ,-1*stg2.onhand_qty
               FROM opi_dbi_opm_inv_stg stg2) balance
      GROUP BY balance.organization_id
               ,balance.subinventory_code
               ,balance.cost_group_id
               ,balance.inventory_item_id;

     l_debug_msg := 'Inserted into staging table OPI_DBI_INV_BEG_STG - ' || SQL%ROWCOUNT || ' rows. ';
     OPI_DBI_BOUNDS_PKG.write(g_pkg_name, l_proc_name,l_stmt_num, l_debug_msg);

     commit;

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Exit from GET_ONHAND_BALANCE  ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     --execute immediate 'alter session disable parallel query';

EXCEPTION
    WHEN OTHERS THEN
    l_debug_msg := 'Failed with errror '  ||  SQLcode || ' - ' ||SQLERRM;
    OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);
    RAISE;
END GET_ONHAND_BALANCE;

-------------------------------------------------------------------------------
--This Procedure will collect data into temp table required for Intransit
--Initial Load
--In opi_dbi_intr_mip_tmp , which contains shipping network information for
--discrete organization till now(Pre R12), shipping network between all
--type of organization will be collected along with
--process enabled flag info
--Data from MMT which has been moved to opi_dbi_intr_mmt_tmp for discrete
--organization ,pre r12.
--After R12 this table will also contains the information for process
--organization.
--Get MMT Data in opi_dbi_intr_mmt_tmp. We will collect following
--transaction actions
--             12 -Intransit Receipt
--             21 - Intransit Shipment
--             24 - Cost Update ODM
--             15 - Logical Intransit Receipt
--             22 - Logical Intransit Shipment
--While collecting data we will map it with MTL_Parameters. To get cost
--group Id for discrete Organization and Process Enabled flag for

PROCEDURE INTRANSIT_SETUP(p_mode varchar2)
IS
     l_stmt_num    NUMBER;
     l_debug_msg   VARCHAR2(1000);
     l_proc_name   VARCHAR2 (60);
     l_debug_mode  VARCHAR2(1);
     l_module_name Varchar2 (30);
BEGIN
     l_proc_name     :=  'GET_INTRANSIT_INITIAL_LOAD';
     l_debug_mode    :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
     l_module_name   := FND_PROFILE.value('AFLOG_MODULE');

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Entered into INTRANSIT_SETUP ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;
     -- Setup the intransit shipping network parameters.
     -- FOB = 1 = Shipment i.e. the to_org is the owning_org.
     -- FOB = 2 = Receipt i.e. the from_org is the owning_org.
     -- For shipments, the from_org is the from_org in MIP and the
     -- to_org is the to_org in MIP.
     -- For receipts, the roles of the orgs are reversed.
     IF p_mode = 'INIT' or p_mode = 'INCR' THEN
          l_stmt_num :=10;
          IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
               l_debug_msg := 'Insert Data into opi_dbi_intr_mip_tmp ';
               OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
          END IF;

          INSERT /*+append parallel(opi_dbi_intr_mip_tmp) */
          INTO opi_dbi_intr_mip_tmp (
               from_organization_id,
               to_organization_id,
               owning_organization_id,
               owning_org_process_flag,
               transaction_action_id,
               fob_point)
          select from_organization_id,
               to_organization_id,
               owning_organization_id,
               -- Because of wrong setup value 1 is there for some of the discrete org,
               -- Customers might have this too
               DECODE(mp.process_enabled_flag,'1','N',mp.process_enabled_flag),
               transaction_action_id,    -- intransit shipment
               fob_point
               from MTL_PARAMETERS mp,
               (SELECT /*+ parallel(mip) */
                    from_organization_id,
                    to_organization_id,
                    DECODE(fob_point,1,to_organization_id,
                                     2,from_organization_id) owning_organization_id,
                    21 transaction_action_id,    -- intransit shipment
                    fob_point
               FROM MTL_INTERORG_PARAMETERS mip
               WHERE NVL(fob_point,-1) in (1,2)
               UNION ALL
               SELECT /*+ parallel(mip) */
                    to_organization_id,
                    from_organization_id,
                    DECODE(fob_point,1,to_organization_id,
                                     2,from_organization_id) owning_organization_id,
                    12 transaction_action_id,    -- intransit receipt
                    fob_point
               FROM MTL_INTERORG_PARAMETERS mip
               WHERE NVL(fob_point,-1) in (1,2)) mip_outer
         WHERE mip_outer.owning_organization_id =mp.organization_id
          ;

          l_debug_msg := 'Inserted into staging table opi_dbi_intr_mip_tmp - ' || SQL%ROWCOUNT || ' rows. ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);

          commit;
     END IF;

     IF p_mode = 'INIT'  THEN
          l_stmt_num :=20;
          IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
               l_debug_msg := 'Insert Data into opi_dbi_intr_mmt_tmp. ';
               OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
          END IF;
          -- Select all intransit data from MMT into a temp table.
          --
          --
          -- Additionally, pick up a cost group associated with each
          -- transaction. For standard costing orgs, use the default
          -- cost group associated with the organization in MTL_PARAMETERS.
          -- As of 11i, the default_cost_group_id is guaranteed to be
          -- non-null, so no nvl is needed on the selection of that column.

          INSERT /*append parallel(opi_dbi_intr_mmt_tmp) */
          INTO OPI_DBI_INTR_MMT_TMP (
               transaction_id,
               organization_id,
               organization_process_flag,
               transfer_organization_id,
               transfer_org_process_flag,
               inventory_item_id,
               transaction_action_id,
               cost_group_id,
               transfer_cost_group_id,
               primary_quantity,
               transaction_date)
          SELECT /*+ use_hash(mmt) use_hash(p) use_hash(p1) parallel(mmt) parallel(p) parallel(p1)*/
               mmt.transaction_id,
               mmt.organization_id,
               -- Setup issue some discrete organization can have value 1.
               DECODE(p.process_enabled_flag
                                   ,'1','N',
                                   p.process_enabled_flag),
               transfer_organization_id,
               DECODE(p1.process_enabled_flag,
                                   '1','N',
                                   p1.process_enabled_flag),
               inventory_item_id,
               transaction_action_id,
               NVL (mmt.cost_group_id,
                         p.default_cost_group_id) cost_group_id,
               NVL (mmt.transfer_cost_group_id,
                         p1.default_cost_group_id) transfer_cost_group_id,
               DECODE (mmt.transaction_action_id,
                                   24, 0,
                                   mmt.primary_quantity),
               transaction_date
          FROM  MTL_MATERIAL_TRANSACTIONS mmt,
                MTL_PARAMETERS p,
                MTL_PARAMETERS p1
          WHERE mmt.transaction_action_id in (12,21,24,15,22)
               AND mmt.transaction_date >= g_global_start_date
               AND p.organization_id = mmt.organization_id
               AND p1.organization_id = mmt.transfer_organization_id
          --AND mmt.transaction_type_id IN (12,21,61,62,24,80,26,28) -- Removed in r12
          ;

          l_debug_msg := 'Inserted into staging table opi_dbi_intr_mmt_tmp - ' || SQL%ROWCOUNT || ' rows. ';
          OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);
          commit;

          l_stmt_num :=30;
          IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
               l_debug_msg := 'Insert into opi_dbi_intr_sup_tmp. ';
               OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
          END IF;
          -- Extract all data from mtl_supply into a temp table.
          -- Make sure that the primary quantity used is that
          -- of the intransit_owning_org.

          -- Bug 4760492
          -- MTL supply contains Transaction qty for from/shipping organization.
          -- It might not be same as primary quantity.
          -- code has been changed for this
          INSERT /*append parallel(opi_dbi_intr_sup_tmp) */
          INTO OPI_DBI_INTR_SUP_TMP (
               intransit_owning_org_id,
               from_organization_id,
               to_organization_id,
               qty,
               item_id,
               cost_group_id)
          SELECT /*+ ordered use_hash(sup) parallel(sup)*/
               intransit_owning_org_id,
               from_organization_id,
               to_organization_id,
               sum (DECODE (intransit_owning_org_id,
               sup.from_organization_id, NVL(inv_convert.inv_um_convert(sup.item_id,
                                        5,sup.quantity,
                                        um.uom_code,msi_fm.primary_uom_code,
                                        NULL,NULL), 0),
               NVL(to_org_primary_quantity, 0))) qty,
              item_id,
               cost_group_id
          FROM MTL_SUPPLY sup,MTL_SYSTEM_ITEMS msi_fm,mtl_units_of_measure um
          WHERE supply_type_code in ('SHIPMENT' , 'RECEIVING')
               AND intransit_owning_org_id IS NOT NULL
               AND msi_fm.organization_id = sup.from_organization_id
               AND msi_fm.inventory_item_id = sup.item_id
               AND um.unit_of_measure = sup.unit_of_measure
          GROUP BY
               intransit_owning_org_id,
               from_organization_id,
               to_organization_id,
               item_id,
               cost_group_id;

          --Old code
          /*SELECT
               intransit_owning_org_id,
               from_organization_id,
               to_organization_id,
               sum (DECODE (intransit_owning_org_id,
               sup.from_organization_id, NVL(quantity, 0),
               NVL(to_org_primary_quantity, 0))) qty,
               item_id,
               cost_group_id
          FROM MTL_SUPPLY sup
          WHERE supply_type_code in ('SHIPMENT' , 'RECEIVING')
               AND intransit_owning_org_id IS NOT NULL
          GROUP BY
               intransit_owning_org_id,
               from_organization_id,
               to_organization_id,
               item_id,
               cost_group_id;
      */
          l_debug_msg :='Inserted into staging table opi_dbi_intr_sup_tmp - ' || SQL%ROWCOUNT || ' rows. ';
          opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name,l_stmt_num,l_debug_msg);

          commit;
     END IF;

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Exit from INTRANSIT_SETUP ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

EXCEPTION
    WHEN OTHERS THEN
    l_debug_msg := 'Failed with errror '  ||  SQLcode || ' - ' ||SQLERRM;
    OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);
    RAISE;
END INTRANSIT_SETUP;

-------------------------------------------------------------------------------
--In This procedure, Inception Quantities for Intransit Inventory is collected
--In Procedure Intransit setup, data have been collceted into
--following tables
--   opi_dbi_intr_mip_tmp,
--   opi_dbi_intr_mmt_tmp
--   and opi_dbi_intr_sup_tmp,
--which are in sync(approx) with each other.
--We will use these three tables to collect data for inception quantities.
--For Pre R12 OPM data , we will use opi_dbi_intr_sup_tmp table
--Data collection is similar to initial Load; here only quantities are
--collected on inception date.
--No bound are used for inception load. Also all uncosted transaction are
--considered.
--As only quantities need to be collected, only physical transaction will
--be collected. Action type 12, 21
--UOM conversion is required whenever UOM of transfer organization and
--receiving organization is different and UOM is not in term of owning
--organization. Ex. For FOB shipping, Intransit is own by receiving
--organization. Now if UOM of from (transfer) organization and to(receiving
--) organization is not same. Then for shipping transaction (when item is
--shipped) , we need to do UOM conversion.

PROCEDURE GET_INTRANSIT_BALANCE
IS

     l_stmt_num      NUMBER;
     l_debug_msg     VARCHAR2(1000);
     l_proc_name     VARCHAR2 (60);
     l_debug_mode    VARCHAR2(1);
     l_module_name   VARCHAR2 (30);
BEGIN

     l_proc_name  :=  'GET_INTRANSIT_BALANCE';
     l_debug_mode    :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
     l_module_name   := FND_PROFILE.value('AFLOG_MODULE');

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Entered Into GET_INTRANSIT_BALANCE';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     l_stmt_num := 10;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Inserting data into OPI_DBI_INV_BEG_STG for Intransit Inception load ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     OPI_DBI_RPT_UTIL_PKG.g_pk_uom_conversion := 1;

    INSERT /*+ append parallel(opi_dbi_intransit_stg) */
     INTO OPI_DBI_INV_BEG_STG
     (    organization_id ,
          inventory_item_id,
          subinventory_code,
          Cost_group_id,
          intransit_qty ,
          transaction_date
          )     --Gets inventory_item, org_id, cost group combos with qty sums.
     SELECT
          xy.organization_id,
          xy.inventory_item_id,
          NULL subinventory_code,
          xy.cost_group_id,
          sum(xy.tot_prim_qty) tot_prim_qty,
          g_global_start_date
     FROM (
          SELECT
               mip.owning_organization_id organization_id,
               mmt1.inventory_item_id inventory_item_id,
            -- intransit balance = current intransit - activities.
            -- here quantities are not negated because intransit
            -- sign is already reverse on MMT w.r.t intransit
            -- quantity.
               sum (decode (msi_fm.primary_uom_code,
                           msi_to.primary_uom_code,
                           decode(mmt1.transaction_action_id,
                                        22,  mmt1.primary_quantity, --??Not needed
                                        15, -1 * mmt1.primary_quantity,
                              mmt1.primary_quantity), --Bug 4878458
                           decode (mmt1.transaction_action_id,
                             21,decode (mip.fob_point,
                                   2, mmt1.primary_quantity,
                                    OPI_DBI_RPT_UTIL_PKG.OPI_UM_CONVERT(mmt1.inventory_item_id,mmt1.primary_quantity , msi_fm.primary_uom_code,msi_to.primary_uom_code)),
                             12,decode (mip.fob_point,
                                   2,OPI_DBI_RPT_UTIL_PKG.OPI_UM_CONVERT(mmt1.inventory_item_id, mmt1.primary_quantity , msi_fm.primary_uom_code,msi_to.primary_uom_code),
                             mmt1.primary_quantity)))) tot_prim_qty,
               decode(Mip.owning_org_process_flag -- this need only for cost group id, As For OPM it is -1
                    ,'N',decode (mmt1.transaction_action_id,
                              21,decode (mip.fob_point,
                                   2, mmt1.cost_group_id,
                                   mmt1.transfer_cost_group_id),
                              12,decode (mip.fob_point,
                                   2,mmt1.transfer_cost_group_id,
                                   mmt1.cost_group_id)
                              ),-1) cost_group_id
               FROM OPI_DBI_INTR_MMT_TMP mmt1,
                    OPI_DBI_INTR_MIP_TMP mip,
                    MTL_PARAMETERS mp,
                    MTL_SYSTEM_ITEMS msi_fm,
                    MTL_SYSTEM_ITEMS msi_to
          WHERE mmt1.organization_id = mip.from_organization_id
            AND mmt1.transfer_organization_id = mip.to_organization_id
            AND mmt1.transaction_action_id = mip.transaction_action_id
         -- not collecting action id  24
         -- as we are only collecting quantities
         -- not looking at logical txns as well as looking at only
         -- quantity and it comes correct from all physical txns
         -- alone.
            AND mmt1.transaction_action_id in (21,12)
            AND mip.owning_organization_id = mp.organization_id
            AND msi_fm.organization_id = mip.from_organization_id
            AND msi_fm.inventory_item_id = mmt1.inventory_item_id
            AND msi_to.organization_id = mip.to_organization_id
            AND msi_to.inventory_item_id = mmt1.inventory_item_id
          GROUP BY mip.owning_organization_id,
               mmt1.inventory_item_id,
              decode(Mip.owning_org_process_flag
                    ,'N', mp.primary_cost_method,-1),
               decode (mip.fob_point,
                              2,decode (mip.transaction_action_id,
                                21, msi_fm.primary_uom_code,
                                msi_to.primary_uom_code),
                              decode (mip.transaction_action_id,
                                12,msi_to.primary_uom_code,
                                   msi_fm.primary_uom_code)),
               decode(Mip.owning_org_process_flag -- this need only for cost group id, As For OPM it is -1
                    ,'N',decode (mmt1.transaction_action_id,
                              21,decode (mip.fob_point,
                                   2, mmt1.cost_group_id,
                                   mmt1.transfer_cost_group_id),
                              12,decode (mip.fob_point,
                                   2,mmt1.transfer_cost_group_id,
                                   mmt1.cost_group_id)
                              ),-1)
          UNION ALL
          SELECT sup.intransit_owning_org_id
               organization_id,
               sup.item_id inventory_item_id,
               sum(sup.qty) tot_prim_qty,
               nvl (sup.cost_group_id, p.default_cost_group_id)
               cost_group_id
          FROM OPI_DBI_INTR_SUP_TMP sup,
               MTL_SYSTEM_ITEMS msi,
               MTL_PARAMETERS p
          WHERE sup.intransit_owning_org_id = msi.organization_id
            AND p.organization_id = msi.organization_id
            AND sup.item_id = msi.inventory_item_id
          GROUP BY sup.intransit_owning_org_id,
               sup.item_id,
               p.primary_cost_method,
               nvl (sup.cost_group_id, p.default_cost_group_id),'N'
          UNION ALL
          SELECT organization_id,
               inventory_item_id,
               -1 * intransit_qty tot_prim_qty,
               -1 cost_group_id
          FROM OPI_DBI_OPM_INV_STG) xy
     GROUP BY inventory_item_id,
              organization_id,
              cost_group_id,
              g_global_start_date
     HAVING SUM(xy.tot_prim_qty) <>0  ;

     if OPI_DBI_RPT_UTIL_PKG.g_pk_uom_conversion <>1 then
          Raise UOM_CONV_ERROR;
     end if;
     l_debug_msg := 'Inserted into staging table OPI_DBI_INV_BEG_STG - ' || SQL%ROWCOUNT || ' rows. ';
     OPI_DBI_BOUNDS_PKG.write(g_pkg_name, l_proc_name,l_stmt_num, l_debug_msg);

     commit;

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Exit from  GET_INTRANSIT_BALANCE';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;


EXCEPTION
    WHEN UOM_CONV_ERROR then
    l_debug_msg := 'UOM conversion not found '  ||  SQLcode || ' - ' ||SQLERRM;
    OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);
    RAISE;

    WHEN OTHERS THEN
    l_debug_msg := 'Failed with errror '  ||  SQLcode || ' - ' ||SQLERRM;
    OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);
    RAISE;

END GET_INTRANSIT_BALANCE;

-------------------------------------------------------------------------------

PROCEDURE GET_WIP_BALANCE
IS
     l_stmt_num     NUMBER;
     l_debug_msg    VARCHAR2(1000);
     l_proc_name    VARCHAR2 (60);
     l_debug_mode   VARCHAR2(1);
     l_module_name  VARCHAR2(30);
BEGIN
     l_proc_name    :=  'GET_WIP_BALANCE';
     l_debug_mode   :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
     l_module_name  := FND_PROFILE.value('AFLOG_MODULE');

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Entered Into GET_WIP_BALANCE  ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     l_stmt_num :=10;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Inserting data into OPI_DBI_INV_BEG_STG ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

    INSERT INTO OPI_DBI_INV_BEG_STG
     (organization_id
     ,subinventory_code
     ,cost_group_id
     ,inventory_item_id
     ,transaction_date
     ,wip_value_b
     )
     SELECT balance.organization_id
           ,balance.subinventory_code
           ,balance.cost_group_id
           ,balance.inventory_item_id
           ,g_global_start_date
           ,sum(balance.wip_value_b)
      FROM (SELECT stg1.organization_id
                  ,stg1.subinventory_code
                  ,-1 cost_group_id -- as wip is value and not qty no costing done. hence no cost group id required.
                  ,stg1.inventory_item_id
                  ,sum((decode(stg1.transaction_source,'WTA',-1*stg1.wip_value_b
                                                     ,'MTA',-1*stg1.wip_value_b
                                                     ,'GTV',-1*(nvl(wip_value_b,0)+nvl(wip_value_b_draft,0))
                                                     ,'WPB',wip_value_b
                                                     ,'OPJ',nvl(wip_value_b,0)+nvl(wip_value_b_draft,0)
                                                     ,0))) wip_value_b
              FROM opi_dbi_onhand_stg stg1
             WHERE transaction_source IN ('WTA','MTA','GTV','WPB','OPJ')
             group by stg1.organization_id
                     ,stg1.subinventory_code
                     ,-1
                     ,stg1.inventory_item_id
             -- for preR12 data. it is already grouped by org, sub,
          -- item hence no additional group by here.
             UNION ALL
             SELECT stg2.organization_id
                   ,stg2.subinventory_code
                   ,-1 cost_group_id
                   ,stg2.inventory_item_id
                   ,-1*stg2.wip_value_b
               FROM opi_dbi_opm_inv_stg stg2) balance
      GROUP BY balance.organization_id
               ,balance.subinventory_code
               ,balance.cost_group_id
               ,balance.inventory_item_id;

     l_debug_msg := 'Inserted into staging table OPI_DBI_INV_BEG_STG - ' || SQL%ROWCOUNT || ' rows. ';
     OPI_DBI_BOUNDS_PKG.write(g_pkg_name, l_proc_name,l_stmt_num, l_debug_msg);

     commit;

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Exit from GET_WIP_BALANCE  ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;


EXCEPTION
    WHEN OTHERS THEN
    l_debug_msg := 'Failed with errror '  ||  SQLcode || ' - ' ||SQLERRM;
    OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);
    RAISE;

END GET_WIP_BALANCE;

-------------------------------------------------------------------------------
-- This procedure will call onhand, intransit and wip (value)procedures to collect
-- inception qunatities .
-- For onhand and intransit it will also call discrete and OPM costing procedures
-- to get intransit and onhand values on inception date
PROCEDURE GET_INCEPTION_INV_BALANCE
IS
     l_stmt_num      NUMBER;
     l_debug_msg     VARCHAR2(1000);
     l_proc_name     VARCHAR2 (60);
     l_debug_mode    VARCHAR2(1);
     l_module_name   VARCHAR2 (30);
BEGIN

     l_proc_name    := 'GET_INCEPTION_INV_BALANCE';
     l_debug_mode   := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
     l_module_name  := FND_PROFILE.value('AFLOG_MODULE');

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Entered Into GET_INCEPTION_INV_BALANCE';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     g_inception_date := g_global_start_date ;

     l_stmt_num := 10;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Extracting On Hand Inception Balances into its staging table ...';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;
     -- collect on hand inception balance
    OPI_DBI_INV_VALUE_INIT_PKG.get_onhand_balance;

     l_stmt_num := 20;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Extracting InTransit Inception Balances into its staging table ...';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;
    -- collect intransit inception balance
    OPI_DBI_INV_VALUE_INIT_PKG.get_intransit_balance;

     l_stmt_num := 30;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Extracting Work In Process Inception Balances into its staging table ...';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;
     -- collect WIP inception balance
     OPI_DBI_INV_VALUE_INIT_PKG.get_wip_balance;

     l_stmt_num := 40;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Costing Inception balances ODM  ...';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;
     -- cost discrete inception onhand and intransit quantities
     OPI_DBI_INV_VALUE_INIT_PKG.cost_discrete_inception_qty;

     l_stmt_num := 50;
          IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Costing Inception balances OPM  ...';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;
     -- cost OPM inception onhand and intransit quantities
     OPI_DBI_INV_VALUE_INIT_PKG.cost_opm_inception_qty;

     commit;

     --execute immediate 'alter session disable parallel query';
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Exit from GET_INCEPTION_INV_BALANCE';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

EXCEPTION
    WHEN OTHERS THEN
    l_debug_msg := 'Failed with errror '  ||  SQLcode || ' - ' ||SQLERRM;
    OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);
    RAISE;

END GET_INCEPTION_INV_BALANCE;

-------------------------------------------------------------------------------
-- This procedure calls INTRANSIT_SETUP and then collects intransti
-- data for Discrete and Process orgs in two separate extracts.


PROCEDURE GET_INTRANSIT_INITIAL_LOAD
IS
     l_stmt_num      NUMBER;
     l_debug_msg     VARCHAR2(1000);
     l_proc_name     VARCHAR2 (60);
     l_debug_mode    VARCHAR2(1);
     l_module_name   VARCHAR2 (30);
BEGIN
     l_proc_name    :=  'GET_INTRANSIT_INITIAL_LOAD';
     l_debug_mode   :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
     l_module_name  := FND_PROFILE.value('AFLOG_MODULE');

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Entered Into GET_INTRANSIT_INITIAL_LOAD  ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     l_stmt_num :=10;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Calling Intransit setup from get_intransit_initial_load. ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     -- INTRANSIT_SETUP collect data into following temp tables.
     -- OPI_DBI_INTR_MIP_TMP
     -- OPI_DBI_INTR_SUP_TMP
     -- OPI_DBI_INTR_MMT_TMP
     Intransit_setup('INIT'); --R12 moved here

     l_stmt_num :=20;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Inserting data Into opi_dbi_intransit_stg for ODM  ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     -- The extract below gets data from mmt staging table populated in INTRANSIT_SETUP.
     -- joining with MIP and MTA tables to get the intransit data for
     -- transaction_id range as in the bounds table.
     -- There is a separate UNION ALL to get cost update on intransit
     -- value.
     -- This extract gets only discrete intransit data.

     -- Explaination of data stored in MIP:
     -- mip has two records for each setup in mtl_interorg_parameters.
     -- e.g. for M1 -> M2 FOB = 2 there are two records in mip

     -- from_org    to_org     owning_org    txn_action_id
     --    M1         M2           M1            21(shipment)
     --    M2         M1           M1            12(receiving)
     -- for another setup line lets say M2 -> M1 fob = 1 there are another two set or records
     --    M2         M1           M1            21
     --    M2         M1           M1            12

     -- When this table is joined with MMT it is joined with
     -- transaction_action_id. So for any network a different row is
     -- joined with MIP depending upon if its shipping transaction or
     -- receiving transaction.
     -- mmt.organization_id is joined with mip.from_organization_id
     -- which is not necessarily the shipping org id.
     -- for txn_action_id 21 from_org is shipping org and transfer_org is receiving_org
     -- for txn_action_id 12 from_org is receiving org and transfer_org is shipping_org

     -- so when txn_action_id = 21 and fob = 1 (shipping) owning org is receiving_org which is tranfer_org
     -- similarly when txn_action_id = 12 and fob = 2 (receiving) owning org is receiving org which is from_org

     -- for new senarios in R12 txn 15 and 22 have come in.
     -- 15 is logical receipt and 22 is logical shipment.
     -- both these logical txns always has txn_organization same as owning organization.
     -- refer to detail use cases in DLD for this.
     -- The quantity on these txns is also the +ve intransit quantity.
     OPI_DBI_RPT_UTIL_PKG.g_pk_uom_conversion := 1;
     INSERT /*+ append */ INTO OPI_DBI_INTRANSIT_STG(
          organization_id,
          inventory_item_id,
          transaction_date,
          intransit_qty,
          primary_uom,
          intransit_value_b,
          source,
          creation_date,
          last_update_date,
          created_by,
          last_updated_by,
          last_update_login)
     SELECT /*+ use_hash(mta1) use_hash(mmt1) */
          organization_id,
          inventory_item_id,
          decode (sign (trx_date - g_global_start_date),-1, g_global_start_date,trx_date) transaction_date,
          SUM (qty) intransit_qty,
          primary_uom_code primary_uom,
          SUM(value)intransit_value_b,
          decode(process_flag,'N',1,2),   --Discrete/Process Bug fix: 5362465
          g_sysdate,
          g_sysdate,
          g_user_id,
          g_user_id,
          g_login_id
     FROM
          (SELECT
               mip.owning_organization_id organization_id,
               mmt1.inventory_item_id,
               -- logical txn no need of conversion as they are always against the owning org.
               -- logical always contain qty in right sign there is -1 outside as well
               -- -1 is done outside as txn quantity is always reverse sign of the txn qty.
               -- for intransit across process and discrete orgs only logical txns are considered
               -1 * SUM (
                         DECODE(
                         msi_fm.primary_uom_code,
                         msi_to.primary_uom_code,
                         decode(mmt1.transaction_action_id,
                                        22,  mmt1.primary_quantity, -- Absolute value fix
                                        15, -1 * mmt1.primary_quantity,
                              mmt1.primary_quantity), --Bug 4878458
                                   DECODE(
                                   mmt1.transaction_action_id,
                                   21, DECODE( -- intransit shipment
                                       mip.fob_point,  -- FOB 2 is receipt
                                       2, mmt1.primary_quantity,
                                           OPI_DBI_RPT_UTIL_PKG.OPI_UM_CONVERT(mmt1.inventory_item_id,mmt1.primary_quantity , msi_fm.primary_uom_code,msi_to.primary_uom_code)
                                          ),
                                   12, DECODE ( -- inransit receipt
                                       mip.fob_point,
                                       2,  OPI_DBI_RPT_UTIL_PKG.OPI_UM_CONVERT(mmt1.inventory_item_id,mmt1.primary_quantity , msi_fm.primary_uom_code,msi_to.primary_uom_code),
                                          mmt1.primary_quantity),
                                   22,  mmt1.primary_quantity, -- Absolute value fix
                                   15, -1 * mmt1.primary_quantity))) qty,
               SUM (base_transaction_value) value,
               DECODE (mip.owning_organization_id, msi_fm.organization_id, msi_fm.primary_uom_code
                        ,msi_to.organization_id, msi_to.primary_uom_code) primary_uom_code,
               TRUNC (mmt1.transaction_date) trx_date,
	       mip.owning_org_process_flag process_flag       -- Bug fix: 5362465
          FROM opi_dbi_intr_mip_tmp mip,
               opi_dbi_intr_mmt_tmp mmt1,
               (select
                    transaction_id,
                    sum (base_transaction_value) base_transaction_value
               from mtl_transaction_accounts
               where accounting_line_type = 14     -- Accounting line for Inransit in MTA
               group by transaction_id) mta,
               mtl_system_items msi_fm,
               mtl_system_items msi_to,
               opi_dbi_conc_prog_run_log  col
             WHERE mmt1.organization_id = mip.from_organization_id
               AND mmt1.transfer_organization_id = mip.to_organization_id
               AND mmt1.transaction_action_id in (15,12,22,21)
               AND decode(mmt1.transaction_action_id,15,12,22,21,mmt1.transaction_action_id) = mip.transaction_action_id
               -- condition below avoids getting 1 of the physical txns across process and discrete orgs
               -- as the process flag is different for owning org and txn organization
               -- for more detail refer to DLD test cases
               and mmt1.organization_process_flag = mip.owning_org_process_flag
               AND mip.from_organization_id = col.bound_level_entity_id
               AND mta.transaction_id (+)= mmt1.transaction_id -- outer join is required to collect expense item
               -- As some of them might not have row in MMT.
               AND msi_fm.inventory_item_id = mmt1.inventory_item_id
               AND msi_fm.organization_id = mip.from_organization_id
               and msi_to.inventory_item_id = mmt1.inventory_item_id
               AND msi_to.organization_id = mip.to_organization_id
               AND mmt1.transaction_id >= col.from_bound_id
               AND mmt1.transaction_id < col.to_bound_id
               AND col. driving_table_code= 'MMT'
               AND col.etl_type = 'INVENTORY'
               AND col.load_type= 'INIT'
          GROUP BY
               mip.owning_organization_id,
	       mip.owning_org_process_flag,         -- Bug fix: 5362465
               mmt1.inventory_item_id,
               decode (mip.fob_point,2, decode (mip.transaction_action_id,21, msi_fm.primary_uom_code,
                              msi_to.primary_uom_code),decode (mip.transaction_action_id,
                              12, msi_to.primary_uom_code,msi_fm.primary_uom_code)) ,
               trunc(mmt1.transaction_date),
               DECODE (mip.owning_organization_id, msi_fm.organization_id, msi_fm.primary_uom_code
                        ,msi_to.organization_id, msi_to.primary_uom_code)
          --UNION ALL to collect cost update data related to Intransit.
          UNION ALL
          SELECT
               mmt1.organization_id organization_id,
               mmt1.inventory_item_id,
               0 qty,
               sum (base_transaction_value) value,
               msi_fm.primary_uom_code,
               trunc(mmt1.transaction_date) trx_date,
	       'N'  process_flag   -- Bug fix: 5362465, source is only discrete here
          FROM  opi_dbi_intr_mmt_tmp mmt1,
               mtl_transaction_accounts mta,
               mtl_system_items msi_fm,
               OPI_DBI_CONC_PROG_RUN_LOG  col
          WHERE mmt1.transaction_action_id = 24
               AND mta.transaction_id = mmt1.transaction_id
               AND mmt1.organization_id = mta.organization_id
               AND mta.accounting_line_type = 14
               AND msi_fm.inventory_item_id = mmt1.inventory_item_id
               AND msi_fm.organization_id =  mmt1.organization_id
               AND mmt1.organization_id = col.BOUND_LEVEL_ENTITY_ID
               AND mmt1.transaction_id >= col.FROM_BOUND_ID
               AND mmt1.transaction_id < col.TO_BOUND_ID
               And col. DRIVING_TABLE_CODE= 'MMT'
               And col.ETL_TYPE = 'INVENTORY'
               And col.LOAD_TYPE=     'INIT'
          GROUP BY
               mmt1.organization_id,
               mmt1.inventory_item_id,
               msi_fm.primary_uom_code,
               trunc(mmt1.transaction_date))
     GROUP BY
          organization_id,
          inventory_item_id,
          primary_uom_code,
          trx_date,
	  decode(process_flag,'N',1,2)    -- Bug fix: 5362465
     HAVING sum(value) <> 0 or sum(qty) <> 0;

     if OPI_DBI_RPT_UTIL_PKG.g_pk_uom_conversion <> 1 then
          Raise UOM_CONV_ERROR;
     end if ;

     l_debug_msg := 'Inserted into staging table opi_dbi_intransit_stg - ' || SQL%ROWCOUNT || ' rows. ';
     OPI_DBI_BOUNDS_PKG.write(g_pkg_name, l_proc_name,l_stmt_num, l_debug_msg);

     commit;

     l_stmt_num :=30;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Inserting data Into opi_dbi_intransit_stg for OPM  Post R12 ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     -- extract to collect process orgs intransit data
     -- process does not support cost updates for intransit data hence
     -- no separate extract to get cost update data.
     OPI_DBI_RPT_UTIL_PKG.g_pk_uom_conversion := 1;

     INSERT /*+ APPEND */ INTO OPI_DBI_INTRANSIT_STG(
          organization_id,
          inventory_item_id,
          transaction_date,
          intransit_qty,
          intransit_qty_draft,
          primary_uom,
          intransit_value_b,
          intransit_value_draft_b,
          source,
          creation_date,
          last_update_date,
          created_by,
          last_updated_by,
          last_update_login)
     SELECT /*+ use_hash(mta1) use_hash(mmt1) */
          organization_id,
          inventory_item_id,
          DECODE (SIGN (trx_date - g_global_start_date),
                               -1, g_global_start_date,
                                   trx_date) transaction_date,
          SUM (qty) intransit_qty,
          SUM(draft_qty) intransit_qty_draft,
          primary_uom_code primary_uom,
          SUM (value) intransit_value_b,
          SUM(draft_value) intransit_value_draft_b,
          decode(process_flag,'N',1,2), -- 1 - Discrete/ 2 - Process   -- Bug fix: 5362465
          g_sysdate,
          g_sysdate,
          g_user_id,
          g_user_id,
          g_login_id
     FROM
     (SELECT
          mip.owning_organization_id organization_id,
	  mip.owning_org_process_flag process_flag,         -- Bug fix: 5362465
          mmt1.inventory_item_id,
          -1 * sum (DECODE(gtv.accounted_flag, --
          -- -1 * sum (DECODE('D',
                       'D',0,DECODE (msi_fm.primary_uom_code,
                             msi_to.primary_uom_code,
                             decode(mmt1.transaction_action_id,
                                        22,  mmt1.primary_quantity, -- Absolute value fix
                                        15, -1 * mmt1.primary_quantity,   --bug 4878458
                              mmt1.primary_quantity),
                                DECODE (mmt1.transaction_action_id,
                                  21, DECODE (mip.fob_point,
                                        2, mmt1.primary_quantity,
                                        OPI_DBI_RPT_UTIL_PKG.OPI_UM_CONVERT(mmt1.inventory_item_id,mmt1.primary_quantity , msi_fm.primary_uom_code,msi_to.primary_uom_code)
                                        ),
                                  12, DECODE (mip.fob_point,
                                        2,OPI_DBI_RPT_UTIL_PKG.OPI_UM_CONVERT(mmt1.inventory_item_id, mmt1.primary_quantity , msi_fm.primary_uom_code,msi_to.primary_uom_code),
                                        mmt1.primary_quantity),
                                  22,  mmt1.primary_quantity ,--  Absolute value fix ,no need of conversion ??
                                  15, -1 * mmt1.primary_quantity
                              )))) qty,-- Bug 4901338, removed ,0
          -1 * sum (DECODE(gtv.accounted_flag,
          -- -1 * sum (DECODE('D',
                       'D',DECODE (msi_fm.primary_uom_code,
                             msi_to.primary_uom_code,
                             decode(mmt1.transaction_action_id,
                                        22,  mmt1.primary_quantity, --Absolute value fix
                                        15, -1 * mmt1.primary_quantity,  --bug 4878458
                              mmt1.primary_quantity),
                                DECODE (mmt1.transaction_action_id,
                                  21, DECODE (mip.fob_point,
                                        2, mmt1.primary_quantity,
                                        OPI_DBI_RPT_UTIL_PKG.OPI_UM_CONVERT(mmt1.inventory_item_id, mmt1.primary_quantity , msi_fm.primary_uom_code,msi_to.primary_uom_code)),
                                  12, DECODE (mip.fob_point,
                                        2, OPI_DBI_RPT_UTIL_PKG.OPI_UM_CONVERT(mmt1.inventory_item_id, mmt1.primary_quantity , msi_fm.primary_uom_code,msi_to.primary_uom_code),
                                        mmt1.primary_quantity),
                                  22, mmt1.primary_quantity ,-- Absolute value fix no need of conversion ??
                                  15, -1 * mmt1.primary_quantity
                              )),0)) Draft_qty,
          SUM(DECODE(gtv.accounted_flag,'D',base_transaction_value)) Draft_Value,
          SUM(DECODE(gtv.accounted_flag,'D',0,base_transaction_value)) Value, --
          --SUM(DECODE('D','D',base_transaction_value)) Draft_Value,
          --SUM(DECODE('D','D',0,base_transaction_value)) Value,
          DECODE (mip.owning_organization_id, msi_fm.organization_id, msi_fm.primary_uom_code
                   ,msi_to.organization_id, msi_to.primary_uom_code) primary_uom_code,

          TRUNC (mmt1.transaction_date) trx_date
          FROM opi_dbi_intr_mip_tmp mip,
               opi_dbi_intr_mmt_tmp mmt1,
               (SELECT transaction_id,
                       sum(txn_base_value) base_transaction_value
                       ,accounted_flag
                  FROM gmf_transaction_valuation gtv,
                       opi_dbi_org_le_temp tmp, --BUG 4768058
                       opi_dbi_conc_prog_run_log col
                  WHERE --gtv.transaction_source = 'INVENTORY' AND --bug 4870029
                        gtv.journal_line_type = 'ITR'
                    and col.driving_table_code='GTV'
                    and col.etl_type= 'INVENTORY'
                    and col.load_type= 'INIT'
                    and  gtv.ledger_id = tmp.ledger_id --BUG 4768058
                    and gtv.legal_entity_id = tmp.legal_entity_id
                    and gtv.valuation_cost_type_id = tmp.valuation_cost_type_id
                    and gtv.organization_id = tmp. organization_id
                    AND gtv.transaction_date >= g_global_start_date
                    AND (( gtv.accounted_flag IS NULL and gtv.final_posting_date < col.TO_BOUND_DATE )
                          OR (gtv.accounted_flag ='D')) --
               GROUP BY transaction_id, accounted_flag
               ) gtv,
               mtl_system_items msi_fm,
               mtl_system_items msi_to
          WHERE mmt1.organization_id = mip.from_organization_id
            AND mmt1.transfer_organization_id = mip.to_organization_id
            AND mmt1.transaction_action_id in (15,12,22,21)
            AND decode(mmt1.transaction_action_id,15,12,22,21,
                              mmt1.transaction_action_id) = mip.transaction_action_id
            and mmt1.ORGANIZATION_PROCESS_FLAG = mip.owning_org_process_flag--make sure only logical collected incase of D-> P and P->D
            AND gtv.transaction_id = mmt1.transaction_id -- No outer join is required in case of OPM
            AND msi_fm.inventory_item_id = mmt1.inventory_item_id
            AND msi_fm.organization_id = mip.from_organization_id
            AND msi_to.inventory_item_id = mmt1.inventory_item_id
            AND msi_to.organization_id = mip.to_organization_id
          GROUP BY
            mip.owning_organization_id,
	    mip.owning_org_process_flag,   -- Bug fix: 5362465
            mmt1.inventory_item_id,
            DECODE (mip.owning_organization_id, msi_fm.organization_id, msi_fm.primary_uom_code
                        ,msi_to.organization_id, msi_to.primary_uom_code),
            decode (mip.fob_point,
                 2, decode (mip.transaction_action_id,21, msi_fm.primary_uom_code,msi_to.primary_uom_code),
                      decode (mip.transaction_action_id,12, msi_to.primary_uom_code,msi_fm.primary_uom_code)) ,
            trunc(mmt1.transaction_date))
     GROUP BY
               organization_id,
               inventory_item_id,
               primary_uom_code,
               trx_date,
	       decode(process_flag,'N',1,2)          -- Bug fix: 5362465
     HAVING sum(value) <> 0 or sum(qty) <> 0 OR sum(draft_value) <> 0 OR sum(draft_qty) <> 0 ;

     if OPI_DBI_RPT_UTIL_PKG.g_pk_uom_conversion <> 1 then
          Raise  UOM_CONV_ERROR;
     end if;
     commit;

     l_debug_msg := 'Inserted into staging table opi_dbi_intransit_stg for OPM Post R12 - ' || SQL%ROWCOUNT || ' rows. ';
     OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);

     l_debug_msg := 'End of collecting intransit ODM initial load. ';
     OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Exit from GET_INTRANSIT_INITIAL_LOAD  ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

EXCEPTION
    WHEN UOM_CONV_ERROR then
    l_debug_msg := 'UOM conversion not found '  ||  SQLcode || ' - ' ||SQLERRM;
    OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);
    RAISE;

    WHEN OTHERS THEN
    l_debug_msg := 'Failed with errror '  ||  SQLcode || ' - ' ||SQLERRM;
    OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);
    RAISE;

END GET_INTRANSIT_INITIAL_LOAD ;


-------------------------------------------------------------------------------

PROCEDURE EXTRACT_INVENTORY_TXN_QTY
IS
     l_stmt_num    NUMBER;
     l_debug_msg   VARCHAR2(1000);
     l_proc_name   VARCHAR2 (60);
     l_debug_mode  VARCHAR2(1);
     l_module_name VARCHAR2 (30);
BEGIN

     l_proc_name    :=  'EXTRACT_INVENTORY_TXN_QTY';
     l_debug_mode   :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
     l_module_name  := FND_PROFILE.value('AFLOG_MODULE');

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Entered Into EXTRACT_INVENTORY_TXN_QTY  ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

  /* Extract all records from MMT in quantity staging table (OPI_DBI_INV_ONH_QTY_stg) ,
     such that transaction_date >= GSD and TRANSACTION_ID >= FROM_BOUND_ID in LOG table for this ETL.
     All Quantities are extracted from MMT but these are marked using push_to_fact_flag 'Y' or 'N'
     depending upon the to_bound_id for discrete orgs.

     For process orgs all the quantity that is costed is set for pushed to the fact and uncosted
     quantity is set for push to fact flag as 'N'.

     NOTE: It is assumed that there is not much time difference between the LOG Table
     update and Extraction of quantity in this step.
     It is assumed that database takes snapshot of underlying tables at the start of this step.
     MMT and MTA data is in synch as data is extracted for same transaction id ranges.

     MMT and GTV data is in synch as there is no bound on MMT and from GTV data is taken for all
     draft records and final_posted_date < timestamp as of stamping the log tables.

     Now it is possible there are some new transactions coming in between log table
     1.2.2 and 1.2.5 and also getting draft posted.
     These transactions will be picked up in step 1.2.5. However the next incremental load will
     take care of it by collecting quantity for those records as draft records are always reprocessed.
   */

     l_stmt_num :=10;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Inserting data into OPI_DBI_ONH_QTY_STG ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;
  --execute immediate 'alter session force parallel query parallel ' || g_degree;

       INSERT /*+ append  parallel(OPI_DBI_ONH_QTY_STG) */
       INTO OPI_DBI_ONH_QTY_STG
       (organization_id,
        subinventory_code,
        cost_group_id,
        inventory_item_id,
        transaction_date,
        onhand_qty,
        onhand_qty_draft,
        push_to_fact_flag,
        source,
        transaction_source)
        -- staging tables do not have who columns
       (SELECT /*+ use_hash(mta1) use_hash(mmt1) */
             mmt.organization_id,
             nvl(mmt.subinventory_code,-1),
             NVL(mmt.cost_group_id, mp.default_cost_group_id),
             mmt.inventory_item_id,
             TRUNC(mmt.transaction_date) transaction_date,
             -- if its process org then consider final accounted quantity for discrete consider all
             SUM(DECODE(mp.process_enabled_flag,'Y'
                   ,DECODE(mmt.opm_costed_flag --
                   --,DECODE('D'
                      ,null,mmt.primary_quantity,0)
                      ,mmt.primary_quantity)) onhand_qty,
             -- if its process org then consider draft accounted quantity. for discrete consider its always zero
             SUM(DECODE(mp.process_enabled_flag,'Y'
                    ,DECODE(mmt.opm_costed_flag,'D',
                        primary_quantity,'N', primary_quantity, 0),0)) onhand_qty_draft, --Qty extracted for opm_costed_flag 'N' and 'D'
             CASE WHEN mp.process_enabled_flag = 'Y' THEN -- if its a process org
                  DECODE(mmt.opm_costed_flaG,'N','N','Y') -- if its costed then push to fact else Not --
                  --DECODE('D','N','N','Y') -- if its costed then push to fact else Not
                     WHEN mmt.transaction_id < prl.to_bound_id THEN 'Y'
                  ELSE 'N'
             END push_to_fact_flag,
             DECODE(mp.process_enabled_flag,'N',1,'Y',2,1) source,
             'MMT' transaction_source
       FROM MTL_MATERIAL_TRANSACTIONS MMT
--           ,MTL_SYSTEM_ITEMS MSI
           ,OPI_DBI_CONC_PROG_RUN_LOG PRL
           ,MTL_PARAMETERS MP
      WHERE prl.driving_table_code (+)= 'MMT' --bug 4704813
        AND prl.etl_type (+)= 'INVENTORY'
        AND prl.load_type (+)= 'INIT'
        AND mmt.transaction_id >= nvl(prl.from_bound_id,0) --bug 4704813
        -- there is no condition on to_bound as we get all quantity from mmt but push to fact flag is set to No based
        -- on to_bound_id in select clause
        AND mmt.organization_id = prl.bound_level_entity_id (+) -- outer join as process orgs are not available in log table
        AND mmt.transaction_date >= g_global_start_date -- to avoid any backdated transactions
        AND mmt.organization_id = mp.organization_id
--        AND mmt.organization_id = msi.organization_id
--        AND mmt.inventory_item_id = msi.inventory_item_id
        AND mmt.organization_id = NVL(mmt.owning_organization_id, mmt.organization_id)
        AND NVL(mmt.owning_tp_type,2) = 2
        AND NVL(mmt.logical_transaction,0) <> 1
        AND mmt.transaction_type_id not in (73,25,26,90,91,92,55,56,57,58,87,88,89,24,28,80) --
        AND MMT.TRANSACTION_ACTION_ID NOT IN (24)
        -- or should we use AND MMT.TRANSACTION_ACTION_ID NOT IN (5,30,24,40,41,42,50,51,52)
        -- 82,83,84 inventory lot split/merge/translate are getting excluded by second condition
       GROUP BY
             mmt.organization_id,
             mmt.subinventory_code,
             NVL(mmt.cost_group_id, mp.default_cost_group_id),
             mmt.inventory_item_id,
             TRUNC(mmt.transaction_date) ,
              mp.process_enabled_flag
              , mmt.opm_costed_flag
              ,mmt.transaction_id
              ,prl.to_bound_id
              ,'MMT'
       UNION ALL
       SELECT /*+ use_hash(mta1) use_hash(mmt1) */
             moq.organization_id,
             nvl(moq.subinventory_code,-1) subinventory_code,
             nvl(moq.cost_group_id, mp.default_cost_group_id),
             moq.inventory_item_id,
             null transaction_date,
             sum(moq.transaction_quantity) onhand_qty,
             null onhand_qty_draft,
             'N' push_to_fact_flag,
             NULL source,
             'MOQ' transaction_source
       FROM MTL_ONHAND_QUANTITIES MOQ
           ,MTL_PARAMETERS MP
           ,MTL_SYSTEM_ITEMS MSI
      WHERE moq.organization_id = mp.organization_id
        AND moq.organization_id = msi.organization_id
        AND moq.inventory_item_id = msi.inventory_item_id
     GROUP BY moq.organization_id,
             NVL(moq.subinventory_code,-1),
             NVL(moq.cost_group_id, mp.default_cost_group_id),
             moq.inventory_item_id);

     l_debug_msg := 'Inserted into staging table OPI_DBI_ONH_QTY_STG - ' || SQL%ROWCOUNT || ' rows. ';
     OPI_DBI_BOUNDS_PKG.write(g_pkg_name, l_proc_name,l_stmt_num, l_debug_msg);

     commit;

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Exit from GET_INTRANSIT_INITIAL_LOAD  ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

EXCEPTION
    WHEN OTHERS THEN
    l_debug_msg := 'Failed with errror '  ||  SQLcode || ' - ' ||SQLERRM;
    OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);
    RAISE;
END EXTRACT_INVENTORY_TXN_QTY;


-------------------------------------------------------------------------------
--Extract Values in OPI_DBI_ONHAND_STG this has further separate
--unionalls explained below:
--MTA - all transactions for line type 1 and 7 will be taken. Based on
--transaction_id range from log tables it will be marked as push to fact or not.
--GTV - all transactions will be taken prior to the to_bound_date in bounds
--table. Everything will be set for push_to_fact_flag as Yes. Data will be put
--into draft or perm columns depending upon the accounted_flag.
--WPB - all current data from wpb is taken.
--WTA - All current data is taken. But it is categorized to be put into fact or
--not based on the bound.
--Extract to get current OPM Balance from GTV

/* EXTRACT_INVENTORY_TXN_VALUE

    Gets the Onhand, WIP Inventory transactions later than global start date.

    Author              Date        Action
    Suhasini	        09/11/2006  Bug Fix: 5490217: Corrected subinventory_code for
				    Direct Org transfer between different subinventories
				    when transferred from std to avg costed organizations
				    Forward ported from 11.5.10 Bug 5403832
*/

PROCEDURE EXTRACT_INVENTORY_TXN_VALUE
IS
     l_stmt_num    NUMBER;
     l_debug_msg   VARCHAR2(1000);
     l_proc_name   VARCHAR2 (60);
     l_debug_mode  VARCHAR2(1);
     l_module_name VARCHAR2 (30);
BEGIN

     l_proc_name  :=  'EXTRACT_INVENTORY_TXN_VALUE';
     l_debug_mode    :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
     l_module_name   := FND_PROFILE.value('AFLOG_MODULE');

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Enter Into EXTRACT_INVENTORY_TXN_VALUE ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;
          l_stmt_num :=10;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Inserting data into OPI_DBI_ONHAND_STG ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     INSERT /*+ append  parallel(OPI_DBI_ONH_QTY_STG) */
     INTO OPI_DBI_ONHAND_STG
     (organization_id,
     subinventory_code,
     inventory_item_id,
     transaction_date,
     onhand_value_b_draft,
     onhand_value_b,
     wip_value_b_draft,
     wip_value_b,
     source,
     push_to_fact_flag,
     transaction_source)
     -- note: staging tables do not have who columns
     (SELECT
        mta.organization_id,
        decode(mmt.transaction_action_id,
                2,decode(sign(mta.primary_quantity),-1,mmt.subinventory_code,mmt.transfer_subinventory),
                3, decode(sign(mta.primary_quantity), sign(mmt.primary_quantity), mmt.subinventory_code,
		     decode(sign(mta.primary_quantity),-1,mmt.subinventory_code, mmt.transfer_subinventory)), -- Bug 5490217
                28,decode(sign(mta.primary_quantity), -1, mmt.subinventory_code, mmt.transfer_subinventory),
                24, nvl(mmt.subinventory_code,'-1'),mmt.subinventory_code) subinventory_code,
        -- in case its wip related record then
        decode(mta.accounting_line_type,7,nvl(we.primary_item_id,-1),mta.inventory_item_id) inventory_item_id,
        trunc(mta.transaction_date) transaction_date,
        0 onhand_value_b_draft,
        sum(decode(mta.accounting_line_type,1,mta.base_transaction_value,0)) onhand_value_b,
        0 wip_value_b_draft,
        sum(decode(mta.accounting_line_type,'7',
                decode(we.entity_type,1,mta.base_transaction_value,
                                      2,mta.base_transaction_value,
                                      3,mta.base_transaction_value,
                                      4,mta.base_transaction_value,
                                      5,mta.base_transaction_value,
                                      8,mta.base_transaction_value,0),0)) wip_value_b,
        1 source,
        case when mta.transaction_id < prl.to_bound_id then 'Y'
             else 'N'
        end push_to_fact_flag,
        'MTA' transaction_source
     FROM mtl_transaction_accounts mta
      ,mtl_material_transactions mmt
      ,wip_entities we
      ,opi_dbi_conc_prog_run_log prl
     WHERE prl.driving_table_code = 'MMT'
     AND prl.etl_type = 'INVENTORY'
     AND prl.load_type = 'INIT'
     AND mta.transaction_id >= prl.from_bound_id -- changing bound to MTA bug 4576545
     -- there is no condition on to_bound as we get all value from mmt-mta but push to fact flag is set to No based
     -- on to_bound_id in select clause
     AND mta.organization_id = prl.bound_level_entity_id (+) -- outer join as process orgs are not available in log table
     -- changing bound to MTA bug 4576545
     AND mmt.transaction_date >= g_global_start_date -- to avoid any backdated transactions
     AND mmt.transaction_id = mta.transaction_id
     AND mta.accounting_line_type in (1,7)
     -- in case of transaction source type id is 5 then join with wip entities table to get the wip assembly id
     AND decode(mta.accounting_line_type,7,mta.transaction_source_id,null) = we.wip_entity_id(+)
     GROUP BY
        mta.organization_id,
        decode(mmt.transaction_action_id,
                2,decode(sign(mta.primary_quantity),-1,mmt.subinventory_code,mmt.transfer_subinventory),
                3, decode(sign(mta.primary_quantity), sign(mmt.primary_quantity), mmt.subinventory_code,
		     decode(sign(mta.primary_quantity),-1,mmt.subinventory_code, mmt.transfer_subinventory)), -- Bug 5490217
                28,decode(sign(mta.primary_quantity), -1, mmt.subinventory_code, mmt.transfer_subinventory),
                24, nvl(mmt.subinventory_code,'-1'),mmt.subinventory_code),
        -- in case its wip related record then
        decode(mta.accounting_line_type,7,nvl(we.primary_item_id,-1),mta.inventory_item_id),
        trunc(mta.transaction_date),
        case when mta.transaction_id < prl.to_bound_id then 'Y'
             else 'N'
        end
     UNION ALL
     /* if we implement the commented code to get OPM open job balance here itself there are some changes required
     to get_wip_balance api */
     -- WIP value decodes
     --1. WIP value is shown against the product and not the ingredient
     --2. In OPM one job can yield multiple products.
     --So cost allocation has to be done. GTV is joined with gmdtl only
     --for WIP records. For INV records the query should nto join
     --with gmdtl but still return 1 records and hence the outer join.
     --gmdlt can have multiple records for a doc id based on how many
     --main product the job can yield. So for jobs where multiple products
     --are yielded there is a cartesian product.
     --gtv.line_type is 1 for product yields, -1 for ingredient
     --issues and 2 for co-products.
     --For REsources? so when there are multiple products
     --and gtv.line_type is other than 1 its multiplied by
     --cost allocation factor.
     --for product lines its multiplied by 1.
     --when gtv.line_type =1 and gtv.inventory_item_id is not same
     --as gmdtl then its multiplied by zero to net affect the cartesian
     SELECT
        gtv.organization_id,
        nvl(gtv.subinventory_code,-1) subinventory_code,
        decode(gtv.journal_line_type,'WIP',gmdtl.inventory_item_id,gtv.inventory_item_id) inventory_item_id,
        trunc(gtv.transaction_date) transaction_date,
        sum(onhand_val_b_draft),
        sum(onhand_val_b),
        sum(wip_val_b_draft*(decode(gtv.line_type,1,
                                      decode(gtv.inventory_item_id,gmdtl.inventory_item_id,1,0), --Changed to inv item id from item id.Old cols not used is R12.
                                      -1,gmdtl.cost_alloc,
                                       2,gmdtl.cost_alloc,
                                       gmdtl.cost_alloc)))
                                       wip_value_b_draft,
        sum(wip_val_b*(decode(gtv.line_type,1,
                                      decode(gtv.inventory_item_id,gmdtl.inventory_item_id,1,0), --Changed to inv item id from item id.Old cols not used is R12.
                                      -1,gmdtl.cost_alloc,
                                       2,gmdtl.cost_alloc,
                                       gmdtl.cost_alloc)))
                                       wip_value_b,
        2 source,
        CASE WHEN gtv.final_posting_date < prl.to_bound_date
           OR gtv.final_posting_date IS NULL /* for draft posted --       recs */
        THEN 'Y' ELSE 'N' END push_to_fact_flag, --
        --'Y' push_to_fact_flag, --
        'GTV' transaction_source
        -- decode(gbh,gl_posted_ind,0,'OPJ','GTV') transaction_source
     FROM (select gtv.organization_id,
               decode(gtv.journal_line_type,'INV',gtv.subinventory_code,NULL) subinventory_code,
               gtv.line_type, -- amit has added this
               gtv.inventory_item_id,
               trunc(gtv.transaction_date) transaction_date,
               decode(gtv.journal_line_type,'WIP',gtv.doc_id,NULL)
               doc_id,--Gtv.doc_id is populated in inner select only when journal_line_type is WIP.
               gtv.journal_line_type,
               gtv.event_class_code,
                  gtv.final_posting_date,
               sum(decode(journal_line_type,'INV',
                          decode(gtv.accounted_flag,'D',txn_base_value,0),0)) --
                          --decode('D','D',txn_base_value,0),0))
                          onhand_val_b_draft,
               sum(decode(journal_line_type,'INV',
                          decode(gtv.accounted_flag,NULL,txn_base_value,0),0)) --
                          --decode('D',NULL,txn_base_value,0),0))
                          onhand_val_b,
               sum(decode(journal_line_type,'WIP',
                          decode(gtv.accounted_flag,'D',txn_base_value,0),0)) --
                          --decode('D','D',txn_base_value,0),0))
                          wip_val_b_draft,
               sum(decode(journal_line_type,'WIP',
                          decode(gtv.accounted_flag,NULL,txn_base_value,0),0)) --
                          --decode('D',NULL,txn_base_value,0),0))
                          wip_val_b
        from gmf_transaction_valuation gtv,
        opi_dbi_org_le_temp tmp --bug 4768058
       where --gtv.final_posting_date >= g_global_start_date -- Not required
          --and  --
            gtv.journal_line_type IN ('WIP','INV')
         and gtv.transaction_date >= g_global_start_date
         and  gtv.ledger_id = tmp.ledger_id --bug 4768058
         and gtv.legal_entity_id = tmp.legal_entity_id
         and gtv.valuation_cost_type_id = tmp.valuation_cost_type_id
         and gtv.organization_id = tmp. organization_id
      group by gtv.organization_id,
               decode(gtv.journal_line_type,'INV',gtv.subinventory_code,NULL),
               gtv.line_type,
               gtv.inventory_item_id,
               trunc(gtv.transaction_date),
               decode(gtv.journal_line_type,'WIP',gtv.doc_id,NULL),
               gtv.journal_line_type,
               gtv.event_class_code,
                  gtv.final_posting_date) gtv,
       gme_material_details gmdtl,
       opi_dbi_conc_prog_run_log prl
       -- gme_batch_headers gbh
     WHERE gtv.doc_id = gmdtl.batch_id(+)
     AND nvl(gmdtl.line_type,1) = 1 --  (MK) identified issue during UT. Need to be reviewed with Vikas/David
     AND prl.driving_table_code = 'GTV'
     AND prl.etl_type = 'INVENTORY'
     AND prl.load_type = 'INIT'
     --  AND gtv.document_id = gbh.batch_id(+)
     GROUP BY gtv.organization_id,
            decode(gtv.journal_line_type,'WIP',gmdtl.inventory_item_id,gtv.inventory_item_id),
            gtv.transaction_date,
            CASE WHEN gtv.final_posting_date < prl.to_bound_date --
             OR gtv.final_posting_date IS NULL /* for draft posted
             recs */ THEN 'Y' ELSE 'N' END,
            --'Y', --
            nvl(gtv.subinventory_code,-1)
     UNION ALL
         SELECT wta.organization_id,
                '-1' subinventory_code,
                nvl(we.primary_item_id, -1) inventory_item_id,
                trunc(wta.transaction_date) transaction_date,
                null onhand_value_b_draft,
                null onhand_value_b,
                null wip_value_b_draft,
                sum(nvl(wta.base_transaction_value,0)) wip_value_b,
                1 source,
                'Y' push_to_fact_flag,
                'WTA' transaction_source
           FROM wip_transaction_accounts wta,
                wip_entities we,
                opi_dbi_conc_prog_run_log prl
           WHERE prl.etl_type = 'INVENTORY'
             AND prl.driving_table_code = 'WTA'
             AND prl.load_type = 'INIT'
             AND wta.accounting_line_type = 7
             AND wta.transaction_id >= prl.from_bound_id
             AND wta.transaction_id < prl.to_bound_id
             AND wta.transaction_date >= g_global_start_date -- to avoid any backdated txns before GSD
             AND we.wip_entity_id = wta.wip_entity_id
             AND we.entity_type in (1, 2, 3, 4, 5, 8)
           GROUP BY
                wta.organization_id,
                we.primary_item_id,
                wta.transaction_date
         HAVING sum(wta.base_transaction_value) <> 0
     UNION ALL
      SELECT
            wpb.organization_id organization_id,
            '-1' subinventory_code,
            we.primary_item_id inventory_item_id,  -- rows with item_id null are not selected.
            g_global_start_date transaction_date,
            null onhand_value_b_draft,
            null onhand_value_b,
            null wip_value_b_draft,
            sum(nvl(tl_resource_in,0)
              + nvl(tl_overhead_in,0)
              + nvl(tl_outside_processing_in,0)
              + nvl(pl_material_in,0)
              + nvl(pl_material_overhead_in,0)
              + nvl(pl_resource_in,0)
              + nvl(pl_overhead_in,0)
              + nvl(pl_outside_processing_in,0)
                    - nvl(tl_material_out,0)
                    - nvl(tl_material_overhead_out,0)
                    - nvl(tl_resource_out,0)
                    - nvl(tl_overhead_out,0)
                    - nvl(tl_outside_processing_out,0)
                    - nvl(pl_material_out,0)
                    - nvl(pl_material_overhead_out,0)
                    - nvl(pl_resource_out,0)
                    - nvl(pl_overhead_out,0)
                    - nvl(pl_outside_processing_out,0)
              - nvl(tl_material_var,0)
              - nvl(tl_material_overhead_var,0)
              - nvl(tl_resource_var,0)
              - nvl(tl_outside_processing_var,0)
              - nvl(tl_overhead_var,0)
              - nvl(pl_material_var,0)
              - nvl(pl_material_overhead_var,0)
              - nvl(pl_resource_var,0)
              - nvl(pl_overhead_var,0)
              - nvl(pl_outside_processing_var,0)) wip_value_b,
                1,
                'N',
                'WPB' transaction_source
           FROM wip_period_balances wpb,
                wip_entities we
           WHERE wpb.wip_entity_id = we.wip_entity_id
             AND we.entity_type in (1, 2, 3, 4, 5, 8)
             AND we.primary_item_id IS NOT NULL
           GROUP BY
                wpb.organization_id ,
                we.primary_item_id
     UNION ALL
     --the query should be driven by gbh with index on * gl_posted_ind.
     --Otherwise it may end up doing FTS of gtv * which may be expensive
        SELECT gtv.organization_id,
               '-1' subinventory_code,
               --gmdtl.inventory_item_id,
               decode(gtv.journal_line_type,'WIP',gmdtl.inventory_item_id,gtv.inventory_item_id) inventory_item_id,
               trunc(gtv.transaction_date) transaction_date,
               0 onhand_value_b_draft ,
               0 onhand_value_b,
               sum (decode(accounted_flag,'D',gtv.txn_base_value *
                    decode(gtv.line_type,1,decode(gtv.inventory_item_id,gmdtl.inventory_item_id,1,0), --Changed to inv item id from item id.Old cols not used is R12.
                                        -1, gmdtl.cost_alloc,
                                         2, gmdtl.cost_alloc,
                                         gmdtl.cost_alloc),0)) wip_value_b_draft,
               sum (decode(accounted_flag, 'D', 0, gtv.txn_base_value *
                           decode(gtv.line_type,1,decode(gtv.inventory_item_id,gmdtl.inventory_item_id,1,0), --Changed to inv item id from item id.Old cols not used is R12.
                                               -1, gmdtl.cost_alloc,
                                                2, gmdtl.cost_alloc,
                                                gmdtl.cost_alloc))) wip_value_b,
              2 source,
              'N' push_to_fact_flag,
              'OPJ' transaction_source
         FROM gme_batch_header gbh,
              gmf_transaction_valuation gtv,
              opi_dbi_org_le_temp tmp, --Bug 4768058
              gme_material_details gmdtl
        WHERE gtv.journal_line_type  = 'WIP'
          AND nvl(gtv.accounted_flag,'F') <> 'N'
          AND gtv.transaction_date >= g_global_start_date
          AND gtv.doc_id = gmdtl.batch_id
          AND gmdtl.line_type = 1
          AND gbh.batch_id = gtv.doc_id
          AND gbh.gl_posted_ind = 0
          and  gtv.ledger_id = tmp.ledger_id --bug 4768058
          and gtv.legal_entity_id = tmp.legal_entity_id
          and gtv.valuation_cost_type_id = tmp.valuation_cost_type_id
          and gtv.organization_id = tmp. organization_id
     GROUP BY
               gtv.organization_id,
               decode(gtv.journal_line_type,'WIP',gmdtl.inventory_item_id,gtv.inventory_item_id),
               trunc(gtv.transaction_date));

     l_debug_msg := 'Inserted into staging table OPI_DBI_ONHAND_STG - ' || SQL%ROWCOUNT || ' rows. ';
     OPI_DBI_BOUNDS_PKG.write(g_pkg_name, l_proc_name,l_stmt_num, l_debug_msg);

     commit;

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Exit from EXTRACT_INVENTORY_TXN_VALUE  ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

EXCEPTION
    WHEN OTHERS THEN
    l_debug_msg := 'Failed with errror '  ||  SQLcode || ' - ' ||SQLERRM;
    OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);
    RAISE;
END EXTRACT_INVENTORY_TXN_VALUE;

-------------------------------------------------------------------------------
-- This procedure merges data from various staging tables populated in
-- initial load.
--   1.   OPI_DBI_ONH_QTY_STG - onhand quantity
--   2. provide each table and what all it contains
--   3.   provide conversion rate and costing info as well for inception to balance.

--In this procedure all all data from staging table is merged
-- into OPI_DBI_INV_VALUE_F fact table
PROCEDURE  MERGE_INITIAL_LOAD
IS
     l_rows          NUMBER := 0;
     l_stmt_num      NUMBER;
     l_debug_msg     VARCHAR2(1000);
     l_proc_name     VARCHAR2 (60);
     l_debug_mode    VARCHAR2(1);
     l_module_name   VARCHAR2 (30);
BEGIN

     l_proc_name  :=  'MERGE_INITIAL_LOAD';
     l_debug_mode    :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
     l_module_name   := FND_PROFILE.value('AFLOG_MODULE');

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Entered Into MERGE_INITIAL_LOAD';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     l_stmt_num := 10;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Calling Clean staging table PRE INIT';
          OPI_DBI_BOUNDS_PKG.write (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     insert /*+ append parallel(opi_dbi_inv_value_f) */ into OPI_DBI_INV_VALUE_F
     (    operating_unit_id,
          organization_id,
          subinventory_code,
          inventory_item_id,
          transaction_date,
          onhand_qty,
          intransit_qty,
          primary_uom,
          onhand_value_b,
          intransit_value_b,
          wip_value_b,
          conversion_rate,
          sec_conversion_rate,
          ONHAND_QTY_DRAFT,
          INTRANSIT_QTY_DRAFT,
          ONHAND_VALUE_B_DRAFT,
          INTRANSIT_VALUE_B_DRAFT,
          WIP_VALUE_B_DRAFT,
          source,
          created_by,
          last_update_login,
          creation_date,
          last_updated_by,
          last_update_date
     )
     select /*+ use_hash(rate, s) parallel(s) parallel(rate) */
          NULL operating_unit_id,
          s.organization_id,
          nvl(s.subinventory_code,-1),
          s.inventory_item_id,
          s.transaction_date,
          s.onhand_qty + s.ONHAND_QTY_DRAFT onhand_qty ,
          s.intransit_qty + s.INTRANSIT_QTY_DRAFT intransit_qty,
          s.primary_uom,
          s.onhand_value_b +s.ONHAND_VALUE_B_DRAFT onhand_value_b,
          s.intransit_value_b + s.INTRANSIT_VALUE_B_DRAFT intransit_value_b ,
          s.wip_value_b + s.WIP_VALUE_B_DRAFT wip_value_b,
          rate.conversion_rate,
          rate.sec_conversion_rate,
          s.ONHAND_QTY_DRAFT,
          s.INTRANSIT_QTY_DRAFT,
          s.ONHAND_VALUE_B_DRAFT,
          s.INTRANSIT_VALUE_B_DRAFT,
          s.WIP_VALUE_B_DRAFT,
          source,
          g_user_id,
          g_login_id,
          sysdate,
          g_user_id,
          sysdate
     FROM
          (SELECT /*+ parallel(activity) */
               activity.organization_id,
               activity.subinventory_code,
               activity.inventory_item_id,
               activity.transaction_date,
               nvl(SUM(onhand_qty),0) onhand_qty,
               nvl(SUM(intransit_qty),0) intransit_qty,
               MIN(msi.primary_uom_code) primary_uom,
               nvl(SUM(onhand_value_b),0) onhand_value_b,
               nvl(SUM(intransit_value_b),0) intransit_value_b,
               nvl(SUM(wip_value_b),0) wip_value_b,
               nvl(SUM(onhand_qty_draft),0) onhand_qty_draft,
               nvl(SUM(INTRANSIT_QTY_DRAFT),0) INTRANSIT_QTY_DRAFT,
               nvl(SUM(ONHAND_VALUE_B_DRAFT),0) ONHAND_VALUE_B_DRAFT,
               nvl(SUM(INTRANSIT_VALUE_B_DRAFT),0) INTRANSIT_VALUE_B_DRAFT,
               nvl(SUM(WIP_VALUE_B_DRAFT),0) WIP_VALUE_B_DRAFT,
               activity.source
          FROM
          (SELECT  /*+ parallel(opi_dbi_onhand_stg) */
             organization_id,
             subinventory_code,
             inventory_item_id,
             transaction_date,
             0 onhand_qty,
             0 intransit_qty,
             primary_uom,
             onhand_value_b,
             0 intransit_value_b,
             wip_value_b,
             0 onhand_qty_draft,
             0 intransit_qty_draft,
             onhand_value_b_draft onhand_value_b_draft,
             0 intransit_value_b_draft,
             wip_value_b_draft wip_value_b_draft,
             source
           FROM OPI_DBI_ONHAND_STG
           where push_to_fact_flag = 'Y'
           UNION ALL
           select  /*+ parallel(OPI_DBI_ONH_QTY_STG) */
             fact.organization_id,
             fact.subinventory_code,
             fact.inventory_item_id,
             fact.transaction_date,
             onhand_qty,
             0 intransit_qty,
             NULL primary_uom,
             0 onhand_value_b,
             0 intransit_value_b,
             0 wip_value_b,
             onhand_qty_draft onhand_qty_draft,
             0 intransit_qty_draft,
             0 onhand_value_b_draft,
             0 intransit_value_b_draft,
             0 wip_value_b_draft,
             source
           FROM OPI_DBI_ONH_QTY_STG  fact
           WHERE push_to_fact_flag = 'Y'
           UNION All
           select /*+ parallel(opi_dbi_intransit_stg) */
             organization_id,
             NULL,
             inventory_item_id,
             transaction_date,
             0 onhand_qty,
             intransit_qty,
             primary_uom,
             0 onhand_value_b,
             intransit_value_b,
             0 wip_value_b,
             0 onhand_qty_draft,
             intransit_qty_draft intransit_qty_draft,
             0 onhand_value_b_draft,
             intransit_value_draft_b intransit_value_b_draft,
             0 wip_value_b_draft,
             source
           from OPI_DBI_INTRANSIT_STG
           union all
           select /*+ parallel(OPI_DBI_INV_BEG_STG) */
             fact.organization_id,
             fact.subinventory_code,
             fact.inventory_item_id,
             fact.transaction_date,
             onhand_qty,
             intransit_qty,
             NULL primary_uom,
             onhand_value_b,
             intransit_value_b,
             wip_value_b,
             0 onhand_qty_draft,
             0 intransit_qty_draft,
             0 onhand_value_b_draft,
             0 intransit_value_b_draft,
             0 wip_value_b_draft,
             decode(mp.process_enabled_flag,'Y',2,1) source
           FROM OPI_DBI_INV_BEG_STG fact,
                mtl_parameters mp
           WHERE fact.organization_id =mp.organization_id
           union all
           select /*+ parallel(OPI_DBI_OPM_INV_STG) */
             organization_id,
             subinventory_code,
             inventory_item_id,
             transaction_date,
             onhand_qty,
             intransit_qty,
             primary_uom,
             onhand_value_b,
             intransit_value_b,
             wip_value_b,
             0 onhand_qty_draft,
             0 intransit_qty_draft,
             0 onhand_value_b_draft,
             0 intransit_value_b_draft,
             0 wip_value_b_draft,
             3 source
           FROM opi_dbi_opm_inv_stg
           ) activity,
           mtl_system_items msi
       WHERE activity.organization_id = msi.organization_id
          AND activity.inventory_item_id =msi.inventory_item_id
        group by
          activity.organization_id,
          activity.subinventory_code,
          activity.inventory_item_id,
          activity.transaction_date,
          activity.source
       having
         nvl(SUM(onhand_qty),0) <> 0
         OR nvl(SUM(intransit_qty),0) <> 0
         OR nvl(SUM(onhand_value_b),0) <>0
         OR nvl(SUM(intransit_value_b),0) <> 0
         OR nvl(SUM(wip_value_b),0) <> 0
         OR nvl(SUM(onhand_qty_draft),0) <> 0
         OR nvl(SUM(INTRANSIT_QTY_DRAFT),0) <> 0
         OR nvl(SUM(ONHAND_VALUE_B_DRAFT),0) <> 0
         OR nvl(SUM(INTRANSIT_VALUE_B_DRAFT),0) <> 0
         OR nvl(SUM(WIP_VALUE_B_DRAFT),0)<> 0
     ) s,
     (select /*+ no_merge parallel(rates) */
          organization_id,
          transaction_date,
          conversion_rate,
          sec_conversion_rate
     from OPI_DBI_CONVERSION_RATES
     ) rate
     where s.organization_id = rate.organization_id
     and s.transaction_date = rate.transaction_date;

     l_debug_msg := 'Inserted into staging table OPI_DBI_INV_VALUE_F - ' || SQL%ROWCOUNT || ' rows. ';
     OPI_DBI_BOUNDS_PKG.write(g_pkg_name, l_proc_name,l_stmt_num, l_debug_msg);

     commit;

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Exit from MERGE INITIAL LOAD';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     --execute immediate 'alter session disable parallel query';

EXCEPTION
    WHEN OTHERS THEN
    l_debug_msg := 'Failed with errror '  ||  SQLcode || ' - ' ||SQLERRM;
    OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);
    RAISE;

END MERGE_INITIAL_LOAD;

-------------------------------------------------------------------------------

PROCEDURE RUN_DISCRETE_FIRST_ETL
IS
     l_stmt_num     NUMBER;
     l_debug_msg    VARCHAR2(1000);
     l_proc_name    VARCHAR2 (60);
     l_debug_mode   VARCHAR2(1);
     l_module_name  VARCHAR2 (30);

BEGIN

     l_proc_name  :=  'RUN_DISCRETE_FIRST_ETL';
     l_debug_mode    :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
     l_module_name   := FND_PROFILE.value('AFLOG_MODULE');

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Entered Into RUN_DISCRETE_FIRST_ETL';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     l_stmt_num := 10;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Calling Clean staging table PRE INIT';
          OPI_DBI_BOUNDS_PKG.write (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     OPI_DBI_INV_VALUE_INIT_PKG.clean_staging_tables('PRE_INIT');

     l_stmt_num := 20;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Setting up bound for Inventory Initial Load ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     -- cleans staging table. sets bounds for MMT, GTV and WTA Tables accordingly.
     OPI_DBI_BOUNDS_PKG.maintain_opi_dbi_logs('INVENTORY','INIT');

     l_stmt_num := 25;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Calling OPI_DBI_BOUNDS_PKG.load_opm_org_ledger_data ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     OPI_DBI_BOUNDS_PKG.load_opm_org_ledger_data;

     l_stmt_num := 30;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Collecting OPI , OPM Initial Load Inventory Quantities ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     OPI_DBI_INV_VALUE_INIT_PKG.extract_inventory_txn_qty;
     -- even this procedure has a commit as it has two extracts and each one run in parallel append mode.
     commit;

     l_stmt_num := 40;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Collecting OPI, OPM Initial Load Inventory Values ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     OPI_DBI_INV_VALUE_INIT_PKG.extract_inventory_txn_value;
     commit;

     l_stmt_num := 50;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Collecting OPI , OPM Intransit Intial Load ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     OPI_DBI_INV_VALUE_INIT_PKG.get_intransit_initial_load;
     commit;

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Exit from RUN_DISCRETE_FIRST_ETL';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;
     -- ACTION: call API that Julia is writing for printing the stop reason code.

EXCEPTION
    WHEN OTHERS THEN
         l_debug_msg := 'Failed with errror '  ||  SQLcode || ' - ' ||SQLERRM;
         OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);
         RAISE;

END RUN_DISCRETE_FIRST_ETL;

-------------------------------------------------------------------------------
-- This procedure is used to insert data into OPI_DBI_INV_TYPE_CODES which
-- is apparently used in opi_inv_type_org_mv.

PROCEDURE SEED_INV_TYPE_CODES
IS

    l_stmt_num      NUMBER;
    l_debug_msg     VARCHAR2(1000);
    l_proc_name     VARCHAR2 (60);
    l_typecode      NUMBER;
    l_debug_mode    VARCHAR2(1);
    l_module_name   VARCHAR2(30);


    -- Cursor to check if the table is empty or not
    CURSOR type_code_exists_check_csr IS
      SELECT 1
        FROM OPI_DBI_INV_TYPE_CODES
        WHERE rownum < 2;
        --declared for bug 3429014

BEGIN
     l_proc_name    :=  'SEED_INV_TYPE_CODES';
     l_debug_mode   :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
     l_module_name  :=  FND_PROFILE.value('AFLOG_MODULE');

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Entered Into SEED_INV_TYPE_CODES';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     l_stmt_num := 10;
     OPEN type_code_exists_check_csr;

     FETCH type_code_exists_check_csr into l_typecode; ---added for bug 3429014

     l_stmt_num :=20;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Inserting type codes. ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     IF (type_code_exists_check_csr%NOTFOUND) THEN

          INSERT INTO opi_dbi_inv_type_codes (inventory_type) VALUES ('ONH');
          INSERT INTO opi_dbi_inv_type_codes (inventory_type) VALUES ('INT');
          INSERT INTO opi_dbi_inv_type_codes (inventory_type) VALUES ('WIP');

     END IF;

     l_stmt_num := 30;
     CLOSE type_code_exists_check_csr;

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'exit from  SEED_INV_TYPE_CODES';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

EXCEPTION
    WHEN OTHERS THEN
         l_debug_msg := 'Failed with errror '  ||  SQLcode || ' - ' ||SQLERRM;
         OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);
         RAISE;

END SEED_INV_TYPE_CODES;

-------------------------------------------------------------------------------

PROCEDURE RUN_FIRST_ETL(errbuf in out NOCOPY VARCHAR2, retcode in out NOCOPY VARCHAR2, p_degree IN NUMBER)
IS
     OPI_DBI_EXCEPTION EXCEPTION;

     PRAGMA EXCEPTION_INIT (OPI_DBI_EXCEPTION , -20002);

     l_stmt_num           NUMBER;
     l_debug_msg          VARCHAR2(1000);
     l_proc_name          VARCHAR2 (60);
     l_discrete_retcode   NUMBER :=0;
     l_opm_retcode        NUMBER := 0;
     l_debug_mode         VARCHAR2(1);
     l_module_name        VARCHAR2(30);
     l_inv_migration_date DATE;
     l_uncost_trx         BOOLEAN;

BEGIN

     l_proc_name    := 'RUN_FIRST_ETL';
     l_debug_mode   := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
     l_module_name  := FND_PROFILE.value('AFLOG_MODULE');

     l_stmt_num := 10;
     l_debug_msg := 'Starting Initial Load for Inventory Management page';
     bis_collection_utilities.put_line(l_debug_msg );

     -- action: why do we need this. confirm with performance team as why this is required
     execute immediate 'alter session set hash_area_size=104857600' ;
     execute immediate 'alter session set sort_area_size=104857600' ;

     l_stmt_num :=20;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Checking For Global Parameters';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     -- checks for GSD, primary and sec currency rate types, schema name for OPI
     -- raises exception in case there is an error
     check_initial_load_setup;

     l_stmt_num :=30;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Calling Procedure seed inv codeType ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;
     -- This will populate data for INV type report
     OPI_DBI_INV_VALUE_INIT_PKG.seed_inv_type_codes; -- No changes for R12
     commit;

     l_stmt_num := 35;
     if (bis_collection_utilities.setup ( p_object_name => 'OPI_DBI_INV_VALUE_F') = false) then
       raise_application_error(-20000,errbuf);
     end if;

     l_stmt_num :=40;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Starting ODM and OPM Post R12  Initial Collection. ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     -- collects data from post r12 model for process as well as discrete organizations
     -- collects onhand quantity, onhand value, intransit qty and value, wip value
     OPI_DBI_INV_VALUE_INIT_PKG.Run_Discrete_First_ETL ;

     l_stmt_num :=50;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Getting Convergence date. ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;
     -- Procedure will provide R12 migration date
     OPI_DBI_RPT_UTIL_PKG.get_inv_convergence_date(l_inv_migration_date);
     g_R12_date:=l_inv_migration_date;
     -- ACTION: confirm that it returns a truncated date

     IF (g_R12_date IS  NULL ) THEN
          l_debug_msg := 'CONVERGENGE Date is not available. Can not proceed';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
          RAISE OPI_DBI_EXCEPTION;
     END IF;

     l_stmt_num :=60;
     IF  g_global_start_date < g_R12_date then
          IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
               l_debug_msg := 'Strating Pre R12 OPM Collection . ';
               OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
          END IF;
          -- This procedure will collect Pre R12 data for OPM
          OPI_DBI_INV_VALUE_OPM_INIT_PKG.Run_OPM_First_ETL(errbuf, retcode);  -- For Pre R12 data
          IF (retcode <> 0) THEN
               IF (retcode = 1) THEN
                    OPI_DBI_BOUNDS_PKG.write(g_pkg_name, l_proc_name,l_stmt_num,'Process Org Initial Collection completed with warnings.');
               ELSE
                    OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num, 'Process Org Initial Collection Failed.');
                    RAISE OPI_DBI_EXCEPTION;
               END IF;
          END IF;
     ELSE
          l_debug_msg := 'GSD is greater then R12. No preR12 data is collected.';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     l_stmt_num :=70;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Start Collection of Inception quantities. ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     -- collects inception balance from staging tables above and also costs the onhand and
     -- intransit quantities
     OPI_DBI_INV_VALUE_INIT_PKG.get_inception_inv_balance;

     l_stmt_num :=80;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Checking for Conversion Rate. ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     -- this api prints the report in case there are conversion rates missing.
     -- it returns -1 in case there are missing conversion rates as well.
     IF (OPI_DBI_INV_VALUE_UTL_PKG.Get_Conversion_Rate(errbuf, retcode) = -1) THEN
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name, l_proc_name,l_stmt_num,'Missing currency rate.');
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name, l_proc_name,l_stmt_num,'Please run the concurrent program: Initial Load - Update Inventory Value and Turns Base Summary, after fixing missing currency rates.');
          retcode := -1; /* 11.5.10. Changed from warning to error */
          RAISE OPI_DBI_EXCEPTION;
     END IF;
     COMMIT;

     l_stmt_num :=90;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Starting Merge Initial Load . ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;
     -- This procedure merges data from various
     -- staging tables populated in initial load.
          -- 1. OPI_DBI_ONH_QTY_STG -- onhand quantity
          -- 2. opi_dbi_opm_inv_stg -- Pre r12 OPM DATA
          -- 3. OPI_DBI_INTRANSIT_STG -- Intransit Qty and Value
          -- 4. OPI_DBI_INV_BEG_STG -- Inception qty and value
          -- 5. OPI_DBI_ONHAND_STG -- On hand value
          -- 6. OPI_DBI_CONVERSION_RATES -- currency conversion rates
     OPI_DBI_INV_VALUE_INIT_PKG.merge_initial_load;

     l_stmt_num :=100;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Starting Clean staging table post initial Load. ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;
     -- truncate the data in staging table
     OPI_DBI_INV_VALUE_INIT_PKG.clean_staging_tables ('POST_INIT');

     l_stmt_num :=110;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Starting Period close adjustment. ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;
     -- It will populate period close adjustment data
     OPI_DBI_INV_CPCS_PKG.Run_Period_Close_Adjustment(errbuf, retcode);

     l_stmt_num :=120;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Checking for uncosted transactions. ';
          OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     l_uncost_trx  := OPI_DBI_BOUNDS_PKG.bounds_uncosted('INVENTORY', 'INIT');

     IF l_uncost_trx =TRUE   then
          retcode := 1;
          l_debug_msg := 'Warning: There are some uncosted transactions. ';
          OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     l_stmt_num :=130;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Priting the log bounds. ';
          OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     OPI_DBI_BOUNDS_PKG.print_opi_org_bounds('INVENTORY', 'INIT');

     l_stmt_num :=140;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Updating Log with success. ';
          OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     -- This will update log table for successful completion of
     -- Inventory Initial Load
     OPI_DBI_BOUNDS_PKG.set_load_successful('INVENTORY', 'INIT');

     BIS_COLLECTION_UTILITIES.wrapup( -- updates the log
     p_status => TRUE,
     p_count => 0, -- for 5.0 only. will put meaningful number in 6.0
     p_message => 'Successfully loaded inventory value base table at ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')
     );

EXCEPTION
     WHEN OPI_DBI_EXCEPTION THEN
          retcode := -1;
          l_debug_msg := 'Failed with errror '  ||  SQLcode || ' - ' ||SQLERRM;
          OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);
          RAISE;

     WHEN OTHERS THEN
          retcode := -1;
          l_debug_msg := 'Failed with errror '  ||  SQLcode || ' - ' ||SQLERRM;
          OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);

          BIS_COLLECTION_UTILITIES.WRAPUP(
          p_status => FALSE,
          p_message => 'Failed in Initial Load of inventory value base table.'
          );
          RAISE;

END RUN_FIRST_ETL;

End OPI_DBI_INV_VALUE_INIT_PKG;

/
