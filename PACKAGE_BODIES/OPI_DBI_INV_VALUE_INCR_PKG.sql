--------------------------------------------------------
--  DDL for Package Body OPI_DBI_INV_VALUE_INCR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_INV_VALUE_INCR_PKG" as
/* $Header: OPIDIVRB.pls 120.27 2008/03/07 09:20:09 sdiwakar noship $ */

g_sysdate                 CONSTANT DATE   := SYSDATE;
g_user_id                 CONSTANT NUMBER := nvl(fnd_global.user_id, -1);
g_login_id                CONSTANT NUMBER := nvl(fnd_global.login_id, -1);
g_global_start_date       DATE;
g_global_curr_code        VARCHAR2(10);
g_global_sec_curr_code    VARCHAR2(10);
g_global_rate_type        VARCHAR2(32);
g_global_sec_rate_type    VARCHAR2(32);
g_pkg_name                VARCHAR2(200)  := 'OPI_DBI_INV_VALUE_INCR_PKG';
g_opi_schema              VARCHAR2(10);
--g_uom_conversion          number;

-- User Defined Exceptions

INITIALIZATION_ERROR EXCEPTION;
PRAGMA EXCEPTION_INIT (INITIALIZATION_ERROR, -20900);

UOM_CONV_ERROR EXCEPTION;
PRAGMA EXCEPTION_INIT (UOM_CONV_ERROR, -20901);

-- This package is used for incremental load collection of Invnetory Management
-- Page. This will collect data for both ODM and OPM type of organization.
-- This will called using REFRESH Procedure
--REFRESH

--     --> CHECK_INCR_LOAD_SETUP
--
--     --> DISCRETE_REFRESH
--               ---> CLEAN_STAGING_TABLE
--               ---> OPI_DBI_BOUNDS_PKG.MAINTAIN_OPI_DBI_LOGS
--               ---> GET_NET_ACTIVITY
--
--                         ---->> GET_ONHAND_ACTIVITY
--                         ---->> GET_INTRANSIT_ACTIVITY
--                         ---->> GET_WIP_ACTIVITY
--
--               ---> OPI_DBI_INV_VALUE_UTL_PKG.Get_Conversion_Rate
--               ---> MERGE_INTO_SUMMARY
--               ---> CLEAN_STAGING_TABLE
--
--     --> OPI_DBI_INV_CPCS_PKG.RUN_PERIOD_CLOSE_ADJUSTMENT
--     -->OPI_DBI_BOUNDS_PKG.print_opi_org_bounds
--     -->OPI_DBI_BOUNDS_PKG.SET_LOAD_SUCCESSFUL
--     --> OPI_DBI_BOUNDS_PKG.SET_LOAD_SUCCESSFUL
--
-- Incremental is re- runable. Even if it fail.
-- All staging tables are truncated at start of incremental load.
-- Merging of data is last step
-- Even if the staging tables are not cleared at the end of load
-- they will be cleared at the start of next run

PROCEDURE CHECK_INCR_LOAD_SETUP
IS
     l_proc_name    VARCHAR2 (40);
     l_stmt_num     NUMBER;
     l_setup_good   BOOLEAN;
     l_status       VARCHAR2(30) := NULL;
     l_industry     VARCHAR2(30) := NULL;
     l_debug_msg    VARCHAR2(200);
BEGIN
     -- Initialization
     l_proc_name := 'CHECK_INCR_LOAD_SETUP';
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

END CHECK_INCR_LOAD_SETUP;


-------------------------------------------------------------------------------

PROCEDURE CLEAN_STAGING_TABLE
IS
     l_stmt_num      NUMBER;
     l_debug_msg     VARCHAR2(1000);
     l_proc_name     VARCHAR2 (60);
     l_debug_mode    VARCHAR2(1);
     l_module_name   VARCHAR2(30);
BEGIN
     l_proc_name     :=  'CLEAN_STAGING_TABLE';
     l_debug_mode    :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
     l_module_name   :=  FND_PROFILE.value('AFLOG_MODULE');

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Start of cleaning staging table';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     l_stmt_num := 10;
     execute immediate 'truncate table ' || g_opi_schema || '.OPI_DBI_INTR_MIP_TMP';

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'OPI_DBI_INTR_MIP_TMP table truncated.';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     l_stmt_num := 20;
     execute immediate 'truncate table ' || g_opi_schema || '.OPI_DBI_INTRANSIT_STG';

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'OPI_DBI_INTRANSIT_STG table truncated.';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     l_stmt_num := 30;
     execute immediate 'truncate table ' || g_opi_schema || '.OPI_DBI_WIP_STG';

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'OPI_DBI_WIP_STG table truncated.';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     l_stmt_num := 40;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'OPI_DBI_ONHAND_STG table truncated.';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
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
END CLEAN_STAGING_TABLE;

-------------------------------------------------------------------------------
/* GET_ONHAND_ACTIVITY

    Gets the Onhand, WIP Inventory transactions for Incremental Load.

    Author              Date        Action
    Suhasini	        09/11/2006  Bug Fix: 5490217: Corrected subinventory_code for
				    Direct Org transfer between different subinventories
				    when transferred from std to avg costed organizations
				    Forward ported from 11.5.10 Bug 5403832
*/
PROCEDURE GET_ONHAND_ACTIVITY
IS
     l_stmt_num      NUMBER;
     l_debug_msg     VARCHAR2(1000);
     l_proc_name     VARCHAR2 (60);
     l_debug_mode    VARCHAR2(1);
     l_module_name   VARCHAR2(30);
BEGIN
     l_proc_name     :=  'GET_ONHAND_ACTIVITY';
     l_debug_mode    :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
     l_module_name   :=  FND_PROFILE.value('AFLOG_MODULE');

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Start of GET_ONHAND_ACTIVITY';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

  -- newly created backdated transactions are not filtered out.
  -- these will be selected and those which have transaction date prior to GSD
  -- are bucketed on GSD
/* specifications of the API needs to be changed to be called only once for all orgs in incremental load */
     l_stmt_num :=10;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Inserting data Into OPI_DBI_ONHAND_STG  ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     INSERT /*+ append */ INTO OPI_DBI_ONHAND_STG
     (organization_id,
     subinventory_code,
     inventory_item_id,
     transaction_date,
     onhand_qty_draft,
     onhand_qty,
     onhand_value_b_draft,
     onhand_value_b,
     wip_value_b_draft,
     wip_value_b,
     source,
     push_to_fact_flag,
     transaction_source)
     SELECT mmt1.ORGANIZATION_ID,
         mmt1.SUBINVENTORY_CODE,
         mmt1.INVENTORY_ITEM_ID,
         /* backdated transactions prior to GSD are bucketed on GSD in incremental load */
         decode(sign(mmt1.transaction_date - g_global_start_date), -1,
         g_global_start_date, mmt1.transaction_date) transaction_date,
         0 onhand_qty_draft, -- draft qty is applicable to process orgs only.
         nvl(mmt1.onhand_qty,0) onhand_qty,
         0 onhand_value_b_draft, -- draft value is applicable to process orgs only.
         nvl(mta1.base_transaction_value,0) onhand_value_b,
         null wip_value_b_draft, -- wip value in this table is populated only in initial load
         null wip_value_b,       -- in incr load wip incr extracts are separate
         1 source,
         null push_to_fact_flag,   -- used only in initial load
         'MTA' transaction_source -- used only in initial load
     FROM
      (SELECT mta.organization_id,
              decode(mmt3.transaction_action_id,
                     2,decode(sign(mta.primary_quantity),-1,mmt3.subinventory_code,mmt3.transfer_subinventory),
                     3, decode(sign(mta.primary_quantity), sign(mmt3.primary_quantity), mmt3.subinventory_code,
	         	     decode(sign(mta.primary_quantity),-1,mmt3.subinventory_code, mmt3.transfer_subinventory)), -- Bug 5490217
                     28,decode(sign(mta.primary_quantity), -1, mmt3.subinventory_code, mmt3.transfer_subinventory),
                     24,nvl(mmt3.subinventory_code,'-1'),mmt3.subinventory_code) subinventory_code,
              mta.inventory_item_id,
              trunc(mta.transaction_date) transaction_date,
              sum(mta.base_transaction_value) base_transaction_value
         FROM mtl_transaction_accounts mta,
              mtl_material_transactions mmt3,
              opi_dbi_conc_prog_run_log prl,
              mtl_parameters mp
        WHERE mta.accounting_line_type = 1
          AND mta.transaction_id >= prl.from_bound_id
          AND mta.transaction_id < to_bound_id
          AND prl.etl_type = 'INVENTORY'
          AND prl.load_type = 'INCR'
          AND prl.driving_table_code = 'MMT'
          AND prl.bound_level_entity_id = mta.organization_id
          AND mmt3.transaction_id = mta.transaction_id
          AND prl.bound_level_entity_id = mp.organization_id
          AND nvl(mp.process_enabled_flag,'N') <> 'Y'
     GROUP BY mta.inventory_item_id,
              decode(mmt3.transaction_action_id,
                     2,decode(sign(mta.primary_quantity),-1,mmt3.subinventory_code,mmt3.transfer_subinventory),
                     3, decode(sign(mta.primary_quantity), sign(mmt3.primary_quantity), mmt3.subinventory_code,
	         	     decode(sign(mta.primary_quantity),-1,mmt3.subinventory_code, mmt3.transfer_subinventory)), -- Bug 5490217
                     28, decode(sign(mta.primary_quantity), -1, mmt3.subinventory_code, mmt3.transfer_subinventory),
                     24, nvl(mmt3.subinventory_code,'-1'),mmt3.subinventory_code),
               mta.organization_id,
               trunc(mta.transaction_date)
      ) mta1,
      (
      -- csheu 3/31/2003. Filter out consigned Inventory transactions
      -- Added the hint to fix bug #3223207
       SELECT  /*+ index(mmt, MTL_MATERIAL_TRANSACTIONS_U1) */
              mmt.organization_id,
              decode(mmt.transaction_action_id,24,nvl(mmt.subinventory_code,-1),mmt.subinventory_code)  subinventory_code,
              mmt.inventory_item_id,
              trunc(mmt.transaction_date) transaction_date,
              nvl(sum(decode(mmt.transaction_action_id,24,0,mmt.primary_quantity)),0) onhand_qty
         FROM mtl_material_transactions mmt,
              mtl_parameters mp,
              opi_dbi_conc_prog_run_log prl
        WHERE prl.etl_type = 'INVENTORY'
          AND prl.load_type = 'INCR'
          AND prl.driving_table_code = 'MMT'
          AND mmt.organization_id = prl.bound_level_entity_id
          AND mmt.transaction_type_id not in (73, 25, 26, 90, 91, 92,55, 56, 57, 58, 87, 88, 89)
          AND mmt.organization_id =  nvl(mmt.owning_organization_id,mmt.organization_id)
          AND nvl(mmt.owning_tp_type,2) = 2 -- exclude consigned inventory
          AND nvl(mmt.logical_transaction,-99) <> 1 -- 11.5.10 changes exclude logical txns
          AND mmt.transaction_id >= prl.from_bound_id
          AND mmt.transaction_id < prl.to_bound_id
          AND prl.bound_level_entity_id = mp.organization_id
          AND nvl(mp.process_enabled_flag,'N') <> 'Y' -- only discrete orgs
     GROUP BY mmt.organization_id,
              decode(mmt.transaction_action_id,24,nvl(mmt.subinventory_code,-1),mmt.subinventory_code)  ,
              mmt.inventory_item_id,
              trunc(mmt.transaction_date)
              --, msi.primary_uom_code
        ) mmt1
     WHERE mta1.organization_id(+) = mmt1.organization_id -- expense item txns dont have recs in mta
     AND mta1.inventory_item_id(+) = mmt1.inventory_item_id
     AND mta1.transaction_date(+) = mmt1.transaction_date
     AND mta1.subinventory_code(+) = mmt1.subinventory_code
     AND (mmt1.onhand_qty <> 0 or mta1.base_transaction_value <> 0);

     l_debug_msg := 'Inserted into staging table OPI_DBI_ONHAND_STG - ' || SQL%ROWCOUNT || ' rows. ';
     OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);

     commit;

     l_stmt_num :=20;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Inserting data Into OPI_DBI_ONHAND_STG ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     -- get the process organizations data by joining to GTV
     -- Query should be (to be verified in performance testing) driven by GTV based on the dates in Log Table.
     -- grouping is done at transaction_id level in inside query because mmt can be joined at that level
     -- it is assumed that inner query on gtv is resolved first and then mmt is joined
     -- using unique index on U1 on MMT. this needs to be tested in performance testing.
     -- commit should be performed by wrapper as if the program errors out in between incremental load its not
     -- re-runnable
     INSERT /*+ append */ INTO OPI_DBI_ONHAND_STG
        (organization_id,
         subinventory_code,
         inventory_item_id,
         transaction_date,
         onhand_qty_draft,
         onhand_qty,
         onhand_value_b_draft,
         onhand_value_b,
         wip_value_b_draft,
         wip_value_b,
         source,
         push_to_fact_flag,
         transaction_source
         )
     SELECT mmt.organization_id,
         gtv.subinventory_code,
         mmt.inventory_item_id,
         -- backdated transactions prior to GSD are bucketed on GSD in incremental load
         decode(sign(trunc(mmt.transaction_date) - g_global_start_date), -1,g_global_start_date, trunc(mmt.transaction_date)) transaction_date,
         sum(case when gtv.accounted_flag  = 'D' then  -- changed mmt.opm_costed_flag to gtv.accounted_flag
               decode(mmt.transaction_action_id,2
                         ,decode(gtv.subinventory_code,mmt.transfer_subinventory,-1* mmt.primary_quantity,mmt.primary_quantity)
			 ,28
			 ,decode(gtv.subinventory_code,mmt.transfer_subinventory,-1* mmt.primary_quantity,mmt.primary_quantity)
                         ,mmt.primary_quantity)
               else 0 end) onhand_qty_draft, --Bug 4704689
         -- sum(case when mmt.opm_costed_flag IS NULL then mmt.primary_quantity else 0 end) onhand_qty,
         sum(case when gtv.accounted_flag IS NULL then  -- changed mmt.opm_costed_flag to gtv.accounted_flag
               decode(mmt.transaction_action_id,2
                         ,decode(gtv.subinventory_code,mmt.transfer_subinventory,-1* mmt.primary_quantity,mmt.primary_quantity)
			 ,28
			 ,decode(gtv.subinventory_code,mmt.transfer_subinventory,-1* mmt.primary_quantity,mmt.primary_quantity)
                         ,mmt.primary_quantity)
               else 0 end) onhand_qty, --BUG 4704689
         sum(gtv.onhand_value_b_draft) onhand_value_b_draft,
         sum(gtv.onhand_value_b) onhand_value_b,
         null wip_value_b_draft,   -- wip value in this table is populated only in initial load
         null wip_value_b,         -- in incr load wip incr extracts are separate
         2 source,                 -- 1 for discrete 2 for process orgs 3 for old opm data
         null push_to_fact_flag,   -- used only in initial load
         'GTV' transaction_source -- used only in initial load
     FROM
      (SELECT gtv.transaction_id,
              nvl(gtv.subinventory_code,-1) subinventory_code,
              sum(txn_base_value) onhand_value_b,
              0 onhand_value_b_draft,
              gtv.accounted_flag
	 FROM gmf_transaction_valuation gtv,
              opi_dbi_org_le_temp tmp, --Bug 4768058
              opi_dbi_conc_prog_run_log prl
        WHERE prl.driving_table_code = 'GTV'
          AND prl.load_type = 'INCR'
          AND prl.etl_type = 'INVENTORY'
          AND gtv.journal_line_type = 'INV'
          --AND gtv.transaction_source = 'INVENTORY' --bug 4870029
          and  gtv.ledger_id = tmp.ledger_id --Bug 4768058
          and gtv.legal_entity_id = tmp.legal_entity_id
          and gtv.valuation_cost_type_id = tmp.valuation_cost_type_id
          and gtv.organization_id = tmp. organization_id
          AND gtv.final_posting_date >= prl.from_bound_date
          AND gtv.final_posting_date < prl.to_bound_date
          AND gtv.accounted_flag IS NULL
     GROUP BY gtv.transaction_id,
              nvl(gtv.subinventory_code,-1),
              gtv.accounted_flag
       UNION ALL
       -- union all is being done here assuming that both the union alls are driven by
       -- separate indexes on GTV. one by final_posted_date and other by accounted_flag
       SELECT gtv.transaction_id,
              nvl(gtv.subinventory_code,-1) subinventory_code,
              0 onhand_value_b,
              sum(txn_base_value) onhand_value_b_draft,
              gtv.accounted_flag
         FROM gmf_transaction_valuation gtv,
              opi_dbi_org_le_temp tmp --Bug 4768058
        WHERE gtv.journal_line_type  IN ('INV')
          --AND gtv.transaction_source = 'INVENTORY' --bug 4870029
          and  gtv.ledger_id = tmp.ledger_id--Bug 4768058
          and gtv.legal_entity_id = tmp.legal_entity_id
          and gtv.valuation_cost_type_id = tmp.valuation_cost_type_id
          and gtv.organization_id = tmp. organization_id
          AND gtv.accounted_flag = 'D' --
     GROUP BY gtv.transaction_id,
              nvl(gtv.subinventory_code,-1),
              gtv.accounted_flag
       ) gtv,
       mtl_material_transactions mmt,
       mtl_system_items msi
     WHERE mmt.transaction_id = gtv.transaction_id
     AND mmt.inventory_item_id = msi.inventory_item_id
     AND mmt.organization_id = msi.organization_id
     GROUP BY mmt.organization_id,
         gtv.subinventory_code,
         mmt.inventory_item_id,
         -- backdated transactions prior to GSD are bucketed on GSD in incremental load
         decode(sign(trunc(mmt.transaction_date) - g_global_start_date), -1,g_global_start_date, trunc(mmt.transaction_date));

     l_debug_msg := 'Inserted into staging table OPI_DBI_ONHAND_STG - ' || SQL%ROWCOUNT || ' rows. ';
     OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);

     commit;

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'End of GET_ONHAND_ACTIVITY';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;
EXCEPTION
    WHEN OTHERS THEN
         l_debug_msg := 'Failed with errror '  ||  SQLcode || ' - ' ||SQLERRM;
         OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);
         RAISE;
END GET_ONHAND_ACTIVITY;

-------------------------------------------------------------------------------

PROCEDURE GET_INTRANSIT_ACTIVITY
IS
     l_stmt_num      NUMBER;
     l_debug_msg     VARCHAR2(1000);
     l_proc_name     VARCHAR2 (60);
     l_debug_mode    VARCHAR2(1);
     l_module_name   VARCHAR2(30);
     from_mta_id     NUMBER;
     to_mta_id       NUMBER;
BEGIN
     l_proc_name     :=  'GET_INTRANSIT_ACTIVITY';
     l_debug_mode    :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
     l_module_name   :=  FND_PROFILE.value('AFLOG_MODULE');

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Start of GET_INTRANSIT_ACTIVITY';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;


     l_stmt_num :=10;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Selecting from_mta bound ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     BEGIN

          select  min(FROM_BOUND_ID) into from_mta_id --USED IN DISCRETE QUERY
          from    OPI_DBI_CONC_PROG_RUN_LOG log
          where   log.driving_table_code= 'MMT'
          And     log.etl_type = 'INVENTORY'
          and     FROM_BOUND_ID IS NOT NULL
          And     log.load_type=   'INCR';

     EXCEPTION
          WHEN OTHERS THEN
               null;
     END;

     l_stmt_num :=20;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Selecting from_mta bound ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     BEGIN

          select  Max(TO_BOUND_ID) into to_mta_id -- USED IN DISCRETE QUERY
          from    OPI_DBI_CONC_PROG_RUN_LOG log
          where   log.driving_table_code= 'MMT'
          And     log.etl_type = 'INVENTORY'
          And     log.load_type=   'INCR';
     EXCEPTION
          WHEN OTHERS THEN
               null;
     END;
     -- Setup the intransit shipping network parameters.
     -- FOB = 1 = Shipment i.e. the to_org is the owning_org.
     -- FOB = 2 = Receipt i.e. the from_org is the owning_org.
     -- For shipments, the from_org is the from_org in MIP and the
     -- to_org is the to_org in MIP.
     -- For receipts, the roles of the orgs are reversed.

     l_stmt_num :=30;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Insert Data into opi_dbi_intr_mip_tmp ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     OPI_DBI_INV_VALUE_INIT_PKG.intransit_setup('INCR');
     commit;

     l_stmt_num :=40;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Inserting data Into opi_dbi_intransit_stg for ODM  ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     -- R12 changes.
     -- 1. Handle intransit across Process and discrete orgs.
     -- 2. log table is modified
     --
     -- mip has two records for each setup in mtl_parameters.
     -- e.g. for M1 -> M2 FOB = 2 there are two records in mip
     -- from_org    to_org     owning_org    txn_action_id
     --    M1         M2           M1            21
     --    M2         M1           M1            12
     -- for another setup line lets say M2 -> M1 fob = 1 there are another two set or records
     --    M2         M1           M1            21
     --    M2         M1           M1            12
     -- so what can be inferred from this data is that
     -- whenever txn_action_id = 21 and FOB = 2 from_org = owning_org
     -- whenever txn_action_id = 12 and FOB = 1 from_org = owning_org
     -- as from_org is joined with MMT org this is the txn_org and the other is transfer org
     -- this is slightly confusing as naming convention for columns in mip is not correct
     -- instead of from_org and to_org it should have been txn_org and transfer_org
     -- for new senarios in R12 txn 15 and 22 have come in.
     -- 15 is logical receipt and 22 is logical shipment.
     -- both these logical txns always has txn_organization same as owning organization.
     -- refer to detail use cases in DLD for this.
     -- The quantity on these txns is also the +ve intransit quantity.

     -- UOM conversion Logic
     --Condition              UOM of Transfer Org and Receiving Org
     --             Same                               Different
     --Shipment     FOB
     --             Shipping  Conversion Not Required  Conversion Required
     --             Receiving Conversion Not Required  Conversion Not Required
     --Receipt
     --             Shipping  Conversion Not Required  Conversion Not Required
     --             Receiving Conversion Not Required  Conversion Required

     -- Index on opi_dbi_intr_mip_tmp Can avoid full table scan
     OPI_DBI_RPT_UTIL_PKG.g_pk_uom_conversion :=1 ;
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
          sysdate,
          sysdate,
          g_user_id,
          g_user_id,
          g_login_id
     FROM
          (SELECT
               mip.owning_organization_id organization_id,
	       mip.owning_org_process_flag process_flag,
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
                                        22,  mmt1.primary_quantity, --Absolute value fix
                                        15, -1 * mmt1.primary_quantity,
                              mmt1.primary_quantity), --Bug 4878458
                                   DECODE(
                                   mmt1.transaction_action_id,
                                   21, DECODE(
                                       mip.fob_point,
                                       2, mmt1.primary_quantity,
                                         OPI_DBI_RPT_UTIL_PKG.OPI_UM_CONVERT(mmt1.inventory_item_id,mmt1.primary_quantity , msi_fm.primary_uom_code,msi_to.primary_uom_code)),
                                   12, DECODE (
                                       mip.fob_point,
                                       2, OPI_DBI_RPT_UTIL_PKG.OPI_UM_CONVERT(mmt1.inventory_item_id,mmt1.primary_quantity , msi_fm.primary_uom_code,msi_to.primary_uom_code),
                                          mmt1.primary_quantity),
                                   22,  mmt1.primary_quantity, --Absolute value fix
                                   15, -1 * mmt1.primary_quantity))) qty,
               SUM (base_transaction_value) value,
               DECODE (mip.owning_organization_id, msi_fm.organization_id, msi_fm.primary_uom_code
                        ,msi_to.organization_id, msi_to.primary_uom_code) primary_uom_code,
               TRUNC (mmt1.transaction_date) trx_date
          FROM opi_dbi_intr_mip_tmp mip,
               mtl_material_transactions mmt1,
               (select
                    transaction_id,
                    sum (base_transaction_value) base_transaction_value
               from mtl_transaction_accounts
               where accounting_line_type = 14
                 AND transaction_id >=  from_mta_id --BOUNDS COLLECTED ABOVE
                 ANd transaction_id <  to_mta_id
               group by transaction_id) mta,
               mtl_system_items msi_fm,
               mtl_system_items msi_to,
               OPI_DBI_CONC_PROG_RUN_LOG  col,
               MTL_PARAMETERS mp
             WHERE mmt1.organization_id = mip.from_organization_id
               AND mmt1.transfer_organization_id = mip.to_organization_id
	          AND mmt1.transaction_action_id in (15,12,22,21)
               AND decode(mmt1.transaction_action_id,15,12,22,21,mmt1.transaction_action_id) = mip.transaction_action_id
               -- condition below avoids getting 1 of the physical txns across process and discrete orgs
               -- as the process flag is different for owning org and txn organization
               -- for more detail refer to DLD test cases
               And mp.organization_id =mmt1.organization_id
               and mp.process_enabled_flag = mip.owning_org_process_flag --make sure only logical collected incase of D-> P and P->D
               AND mip.from_organization_id = col.bound_level_entity_id
               AND mta.transaction_id (+)= mmt1.transaction_id -- to collect expense item
               AND msi_fm.inventory_item_id = mmt1.inventory_item_id
               AND msi_fm.organization_id = mip.from_organization_id
               and msi_to.inventory_item_id = mmt1.inventory_item_id
               AND msi_to.organization_id = mip.to_organization_id
               AND mmt1.transaction_id >= col.from_bound_id
               AND mmt1.transaction_id < col.to_bound_id
               AND col. driving_table_code= 'MMT'
               AND col.etl_type = 'INVENTORY'
               AND col.load_type= 'INCR'
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
          UNION ALL
          SELECT
               mmt1.organization_id organization_id,
	       'N' process_flag,          -- Bug fix: 5362465, source is only discrete here
               mmt1.inventory_item_id,
               0 qty,
               sum (base_transaction_value) value,
               msi_fm.primary_uom_code,
               trunc(mmt1.transaction_date) trx_date
          FROM mtl_material_transactions mmt1,
               mtl_transaction_accounts mta,
               mtl_system_items msi_fm,
               OPI_DBI_CONC_PROG_RUN_LOG  col
          WHERE mmt1.transaction_action_id = 24
               AND mta.transaction_id = mmt1.transaction_id
               AND mmt1.organization_id = mta.organization_id
               AND mta.accounting_line_type = 14
               AND msi_fm.inventory_item_id = mmt1.inventory_item_id
               AND msi_fm.organization_id =  mmt1.organization_id
               AND mmt1.organization_id = col.BOUND_LEVEL_ENTITY_ID --col.organization_id
               AND mmt1.transaction_id >= col.FROM_BOUND_ID
               AND mmt1.transaction_id < col.TO_BOUND_ID
               And col. DRIVING_TABLE_CODE= 'MMT'
               And col.ETL_TYPE = 'INVENTORY'
               And col.LOAD_TYPE=     'INCR'
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

     if OPI_DBI_RPT_UTIL_PKG.g_pk_uom_conversion <>1 then
          Raise UOM_CONV_ERROR;
     end if;

     l_debug_msg := 'Inserted into staging table opi_dbi_intransit_stg - ' || SQL%ROWCOUNT || ' rows. ';
     OPI_DBI_BOUNDS_PKG.write(g_pkg_name, l_proc_name,l_stmt_num, l_debug_msg);

     commit;
     l_stmt_num :=50;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Inserting data Into opi_dbi_intransit_stg for OPM  Post R12 ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;
     OPI_DBI_RPT_UTIL_PKG.g_pk_uom_conversion :=1 ;
     -- Query to collect POST R12 OPM data
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
          decode(process_flag,'N',1,2),  -- 1 - Discrete/ 2 - Process   -- Bug fix: 5362465
          sysdate,
          sysdate,
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
                       'D',0, DECODE (msi_fm.primary_uom_code,
                             msi_to.primary_uom_code,
                             decode(mmt1.transaction_action_id,
                                        22,  mmt1.primary_quantity, --Absolute value fix
                                        15, -1 * mmt1.primary_quantity,
                              mmt1.primary_quantity), --Bug 4878458
                                DECODE (mmt1.transaction_action_id,
                                  21, DECODE (mip.fob_point,
                                        2, mmt1.primary_quantity,
                                         OPI_DBI_RPT_UTIL_PKG.OPI_UM_CONVERT(mmt1.inventory_item_id,mmt1.primary_quantity , msi_fm.primary_uom_code,msi_to.primary_uom_code)),
                                  12, DECODE (mip.fob_point,
                                        2,  OPI_DBI_RPT_UTIL_PKG.OPI_UM_CONVERT(mmt1.inventory_item_id,mmt1.primary_quantity , msi_fm.primary_uom_code,msi_to.primary_uom_code),
                                        mmt1.primary_quantity),
                                  22,  mmt1.primary_quantity ,-- Absolute value fix, no need of conversion ??
                                  15, -1 * mmt1.primary_quantity
                              )))) qty, -- Bug 4901338, removed ,0
          -1 * sum (DECODE(gtv.accounted_flag, --
          -- -1 * sum (DECODE('D',
                       'D',DECODE (msi_fm.primary_uom_code,
                             msi_to.primary_uom_code,
                             decode(mmt1.transaction_action_id,
                                        22,  mmt1.primary_quantity, --Absolute value fix
                                        15, -1 * mmt1.primary_quantity,
                              mmt1.primary_quantity), --Bug 4878458
                                DECODE (mmt1.transaction_action_id,
                                  21, DECODE (mip.fob_point,
                                        2, mmt1.primary_quantity,
                                        OPI_DBI_RPT_UTIL_PKG.OPI_UM_CONVERT(mmt1.inventory_item_id, mmt1.primary_quantity , msi_fm.primary_uom_code,msi_to.primary_uom_code)),
                                  12, DECODE (mip.fob_point,
                                        2, OPI_DBI_RPT_UTIL_PKG.OPI_UM_CONVERT(mmt1.inventory_item_id, mmt1.primary_quantity , msi_fm.primary_uom_code,msi_to.primary_uom_code),
                                        mmt1.primary_quantity),
                                  22,   mmt1.primary_quantity ,-- Absolute value fix, no need of conversion ??
                                  15, -1 * mmt1.primary_quantity
                              )),0)) Draft_qty,
          SUM(DECODE(gtv.accounted_flag --
          --SUM(DECODE('D'
                ,'D',base_transaction_value)) Draft_Value,
          SUM(DECODE(gtv.accounted_flag --
          --SUM(DECODE('D'
                ,'D',0,base_transaction_value)) Value,
          DECODE (mip.owning_organization_id, msi_fm.organization_id, msi_fm.primary_uom_code
                   ,msi_to.organization_id, msi_to.primary_uom_code) primary_uom_code,
          TRUNC (mmt1.transaction_date) trx_date
          FROM opi_dbi_intr_mip_tmp mip,
               mtl_material_transactions  mmt1,
               (SELECT transaction_id,
                       sum(txn_base_value) base_transaction_value
                       ,accounted_flag
                  FROM gmf_transaction_valuation gtv,
                       opi_dbi_org_le_temp tmp,--Bug 4760483
                       opi_dbi_conc_prog_run_log col
                  WHERE --gtv.transaction_source = 'INVENTORY' AND -- bug 4870029
                        gtv.journal_line_type = 'ITR'
                    and col.driving_table_code='GTV'
                    and col.etl_type= 'INVENTORY'
                    and col.load_type= 'INCR'
                    and  gtv.ledger_id = tmp.ledger_id --Bug 4760483
                    and gtv.legal_entity_id = tmp.legal_entity_id
                    and gtv.valuation_cost_type_id = tmp.valuation_cost_type_id
                    and gtv.organization_id = tmp. organization_id
                    And  gtv.final_posting_date >= col.FROM_BOUND_DATE --Bug 4968995
                    And  gtv.final_posting_date < col.TO_BOUND_DATE -- Bug 4968995
                    --And  col.FROM_BOUND_DATE >=gtv.final_posting_date
                    --And  col.TO_BOUND_DATE   < gtv.final_posting_date
                    Group by transaction_id, accounted_flag
                    UNION ALL
                    select transaction_id,
                         sum(txn_base_value) base_transaction_value ,
                         accounted_flag
                    from gmf_transaction_valuation gtv,
                         opi_dbi_org_le_temp tmp --Bug 4760483
                    where --gtv.transaction_source = 'INVENTORY'  and --bug 4870029
                    gtv.journal_line_type = 'ITR'
                    and  gtv.ledger_id = tmp.ledger_id --Bug 4760483
                    and gtv.legal_entity_id = tmp.legal_entity_id
                    and gtv.valuation_cost_type_id = tmp.valuation_cost_type_id
                    and gtv.organization_id = tmp. organization_id
                    AND gtv.accounted_flag ='D' --
                    Group by transaction_id, accounted_flag
               ) gtv,
               mtl_system_items msi_fm,
               mtl_system_items msi_to,
               mtl_parameters mp
          WHERE mmt1.organization_id = mip.from_organization_id
            AND mmt1.transfer_organization_id = mip.to_organization_id
            AND mmt1.transaction_action_id in (15,12,22,21)
            AND decode(mmt1.transaction_action_id,15,12,22,21,
                              mmt1.transaction_action_id) = mip.transaction_action_id
            And mmt1.organization_id=mp.organization_id
            and mp.process_enabled_flag = mip.owning_org_process_flag--make sure only logical collected incase of D-> P and P->D
             AND gtv.transaction_id = mmt1.transaction_id
            AND msi_fm.inventory_item_id = mmt1.inventory_item_id
            AND msi_fm.organization_id = mip.from_organization_id
            AND msi_to.inventory_item_id = mmt1.inventory_item_id
            AND msi_to.organization_id = mip.to_organization_id
          GROUP BY
            mip.owning_organization_id,
	    mip.owning_org_process_flag,   -- Bug fix: 5362465
            mmt1.inventory_item_id,
            DECODE (mip.owning_organization_id, msi_fm.organization_id, msi_fm.primary_uom_code
                        ,msi_to.organization_id, msi_to.primary_uom_code) ,
            decode (mip.fob_point,
                 2, decode (mip.transaction_action_id,21, msi_fm.primary_uom_code,msi_to.primary_uom_code),
                      decode (mip.transaction_action_id,12, msi_to.primary_uom_code,msi_fm.primary_uom_code)) ,
            trunc(mmt1.transaction_date))
     GROUP BY
               organization_id,
               inventory_item_id,
               primary_uom_code,
               trx_date,
	       decode(process_flag,'N',1,2)     -- Bug fix: 5362465
     HAVING sum(value) <> 0 or sum(qty) <> 0 OR sum(draft_value) <> 0 OR sum(draft_qty) <> 0
            OR (sum(draft_value) = 0 AND sum(draft_qty) = 0);  -- Bug 4968293

     if OPI_DBI_RPT_UTIL_PKG.g_pk_uom_conversion <>1 then
          Raise UOM_CONV_ERROR;
     end if;
     commit;

     l_debug_msg := 'Inserted into staging table opi_dbi_intransit_stg for OPM Post R12 - ' || SQL%ROWCOUNT || ' rows. ';
     OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'End of GET_INTRANSIT_ACTIVITY';
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
END GET_INTRANSIT_ACTIVITY;

-------------------------------------------------------------------------------

PROCEDURE GET_WIP_ACTIVITY
IS
     l_stmt_num      NUMBER;
     l_debug_msg     VARCHAR2(1000);
     l_proc_name     VARCHAR2 (60);
     l_debug_mode    VARCHAR2(1);
     l_module_name   VARCHAR2(30);
BEGIN
     l_proc_name     :=  'GET_WIP_ACTIVITY';
     l_debug_mode    :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
     l_module_name   :=  FND_PROFILE.value('AFLOG_MODULE');

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Start of GET_WIP_ACTIVITY';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     l_stmt_num :=10;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Inserting data Into OPI_DBI_WIP_STG for ODM';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     INSERT /*+ append */
     INTO OPI_DBI_WIP_STG (
        organization_id,
        inventory_item_id,
        transaction_date,
        primary_uom,
        wip_value_b,
        wip_value_b_draft,
        source,
        creation_date,
        last_update_date,
        created_by,
        last_updated_by,
        last_update_login)
     SELECT
        wip_activity.organization_id,
        wip_activity.inventory_item_id,
        decode (sign (transaction_date - g_global_start_date),
                -1, g_global_start_date,
                transaction_date) transaction_date,
        msi.primary_uom_code,
        sum (wip_value) wip_value_b,
        0 wip_value_b_draft,
        1,
        sysdate,
        sysdate,
        g_user_id,
        g_user_id,
        g_login_id
     FROM
          (-- Added the hint to fix bug #3223207
         SELECT /*+ index(mta, mtl_transaction_accounts_n1) */
               mta.organization_id organization_id,
               we.primary_item_id inventory_item_id,
               trunc (mta.transaction_date) transaction_date,
               sum (nvl (mta.base_transaction_value,0)) wip_value
         FROM
               mtl_transaction_accounts mta,
               Opi_dbi_conc_prog_run_log  prl,
               wip_entities we
         WHERE
               prl.driving_table_code = 'MMT'
               AND prl.load_type = 'INCR'
               AND prl.etl_type = 'INVENTORY'
               AND prl.bound_level_entity_code = 'ORGANIZATION'
               AND prl.bound_level_entity_id = mta.organization_id
               AND mta.transaction_source_type_id = 5
               AND mta.accounting_line_type = 7
               AND mta.transaction_id >= prl.from_bound_id
               AND mta.transaction_id < to_bound_id
               AND we.wip_entity_id = mta.transaction_source_id
               AND we.entity_type in (1, 2, 3, 4, 5, 8)
               AND we.primary_item_id is not null
         GROUP BY
               mta.organization_id,
               we.primary_item_id,
               mta.transaction_date
         UNION ALL
         SELECT
               wta.organization_id organization_id,
               we.primary_item_id inventory_item_id,
               trunc (wta.transaction_date) transaction_date,
               sum (nvl (wta.base_transaction_value,0)) wip_value
         FROM
               wip_transaction_accounts wta,
               Opi_dbi_conc_prog_run_log  prl,
               wip_entities we
         WHERE
               prl.driving_table_code = 'WTA'
               AND prl.load_type = 'INCR'
               AND prl.etl_type = 'INVENTORY'
               AND wta.accounting_line_type = 7
               --AND prl.bound_level_entity_code = 'ORGANIZATION'
               --AND prl.bound_level_entity_id = wta.organization_id
               AND wta.transaction_id >= prl.from_bound_id
               AND wta.transaction_id < prl.to_bound_id
               AND we.wip_entity_id = wta.wip_entity_id
               AND we.entity_type in (1, 2, 3, 4, 5, 8)
               AND we.primary_item_id is not null
         GROUP BY
               wta.organization_id,
               we.primary_item_id,
               wta.transaction_date
        ) wip_activity,
        mtl_system_items_b msi
     WHERE msi.organization_id = wip_activity.organization_id
        AND wip_activity.inventory_item_id = msi.inventory_item_id
     GROUP BY
            wip_activity.organization_id,
            wip_activity.inventory_item_id,
            transaction_date,
            msi.primary_uom_code
     HAVING sum (wip_value) <> 0;

     l_debug_msg := 'Inserted into staging table OPI_DBI_WIP_STG for ODM - ' || SQL%ROWCOUNT || ' rows. ';
     OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);

     commit;
     l_stmt_num :=20;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Inserting data Into OPI_DBI_WIP_STG for OPM';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;


          INSERT /*+ append */
          INTO OPI_DBI_WIP_STG (
                  organization_id,
                  inventory_item_id,
                  transaction_date,
                  primary_uom,
                  wip_value_b,
                  wip_value_b_draft,
                  source,
                  creation_date,
                  last_update_date,
                  created_by,
                  last_updated_by,
                  last_update_login)
          SELECT
               wip_activity.organization_id,
               wip_activity.inventory_item_id,
               decode (sign (transaction_date - g_global_start_date),
                          -1, g_global_start_date,
                          transaction_date) transaction_date,
               msi.primary_uom_code,
               sum (wip_value_b) wip_value_b,
               sum (wip_value_b_draft) wip_value_b_draft,
               2,
               sysdate,
               sysdate,
               g_user_id,
               g_user_id,
               g_login_id
              FROM
              (
              SELECT
                    gmdtl.organization_id,
                    gmdtl.inventory_item_id,
                    trunc (gtv.transaction_date) transaction_date,
                    sum (gtv.txn_base_value * decode (gtv.line_type,
                          1, decode(gtv.inventory_item_id,gmdtl.inventory_item_id,1,0),
                          -1, gmdtl.cost_alloc,
                          2, gmdtl.cost_alloc,
                          gmdtl.cost_alloc)) wip_value_b,
                    0 wip_value_b_draft
              FROM
                    gmf_transaction_valuation gtv,
                    opi_dbi_org_le_temp tmp,--Bug 4768058
                    gme_material_details gmdtl,
                    opi_dbi_conc_prog_run_log prl
              WHERE prl.driving_table_code = 'GTV'
                AND prl.load_type = 'INCR'
                AND prl.etl_type = 'INVENTORY'
                AND gtv.journal_line_type  = 'WIP'
                and  gtv.ledger_id = tmp.ledger_id --Bug 4768058
                and gtv.legal_entity_id = tmp.legal_entity_id
                and gtv.valuation_cost_type_id = tmp.valuation_cost_type_id
                and gtv.organization_id = tmp. organization_id
                AND gtv.final_posting_date >= prl.from_bound_date
                AND gtv.final_posting_date < prl.to_bound_date
                AND gtv.accounted_flag IS NULL
                AND gtv.doc_id = gmdtl.batch_id
                AND gmdtl.line_type = 1
              GROUP BY
                    gmdtl.organization_id,
                    gmdtl.inventory_item_id,
                    trunc (gtv.transaction_date)
              UNION ALL
              SELECT
                    gmdtl.organization_id,
                    gmdtl.inventory_item_id,
                    trunc (gtv.transaction_date) transaction_date,
                    0 wip_value_b,
                    sum (gtv.txn_base_value * decode (gtv.line_type,
                          1, decode(gtv.inventory_item_id,gmdtl.inventory_item_id,1,0),
                          -1, gmdtl.cost_alloc,
                          2, gmdtl.cost_alloc,
                          gmdtl.cost_alloc)) wip_value_b_draft
              FROM
                    gmf_transaction_valuation gtv,
                    opi_dbi_org_le_temp tmp,--Bug 4760483
                    gme_material_details gmdtl
              WHERE gtv.journal_line_type  = 'WIP'
                 AND gtv.accounted_flag = 'D' --
                AND gtv.doc_id = gmdtl.batch_id
                AND gmdtl.line_type = 1
                and  gtv.ledger_id = tmp.ledger_id --Bug 4760483
               and gtv.legal_entity_id = tmp.legal_entity_id
               and gtv.valuation_cost_type_id = tmp.valuation_cost_type_id
               and gtv.organization_id = tmp. organization_id
              GROUP BY
                    gmdtl.organization_id,
                    gmdtl.inventory_item_id,
                    trunc (gtv.transaction_date)
              ) wip_activity,
              mtl_system_items_b msi
         WHERE msi.organization_id = wip_activity.organization_id
                AND wip_activity.inventory_item_id = msi.inventory_item_id
         GROUP BY
                    wip_activity.organization_id,
                    wip_activity.inventory_item_id,
                    transaction_date,
                    msi.primary_uom_code
         HAVING sum (wip_value_b) <> 0
                  or sum (wip_value_b_draft) <> 0;

     l_debug_msg := 'Inserted into staging table OPI_DBI_WIP_STG for OPM - ' || SQL%ROWCOUNT || ' rows. ';
     OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);

     COMMIT;

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'End of GET_WIP_ACTIVITY';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;
EXCEPTION
    WHEN OTHERS THEN
         l_debug_msg := 'Failed with errror '  ||  SQLcode || ' - ' ||SQLERRM;
         OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);
         RAISE;
END GET_WIP_ACTIVITY;


-------------------------------------------------------------------------------

PROCEDURE GET_NET_ACTIVITY
IS
     l_stmt_num      NUMBER;
     l_debug_msg     VARCHAR2(1000);
     l_proc_name     VARCHAR2 (60);
     l_debug_mode    VARCHAR2(1);
     l_module_name   VARCHAR2(30);
BEGIN
     l_proc_name     :=  'GET_NET_ACTIVITY';
     l_debug_mode    :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
     l_module_name   :=  FND_PROFILE.value('AFLOG_MODULE');

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Start of GET_NET_ACTIVITY';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     l_stmt_num := 10;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Calling On Hand Collection ';
          OPI_DBI_BOUNDS_PKG.write (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     OPI_DBI_INV_VALUE_INCR_PKG.get_onhand_activity;

     l_stmt_num := 20;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Calling Intransit Collection ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     OPI_DBI_INV_VALUE_INCR_PKG.get_intransit_activity;

     l_stmt_num := 30;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Calling WIP Inventory Collection';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     OPI_DBI_INV_VALUE_INCR_PKG.get_wip_activity;


     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'End of GET_NET_ACTIVITY';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;
EXCEPTION
    WHEN OTHERS THEN
         l_debug_msg := 'Failed with errror '  ||  SQLcode || ' - ' ||SQLERRM;
         OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);
         RAISE;
END GET_NET_ACTIVITY;

-------------------------------------------------------------------------------

PROCEDURE MERGE_INTO_SUMMARY
IS
     l_stmt_num      NUMBER;
     l_debug_msg     VARCHAR2(1000);
     l_proc_name     VARCHAR2 (60);
     l_debug_mode    VARCHAR2(1);
     l_module_name   VARCHAR2(30);
BEGIN
     l_proc_name     :=  'MERGE_INTO_SUMMARY';
     l_debug_mode    :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
     l_module_name   :=  FND_PROFILE.value('AFLOG_MODULE');

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Start of MERGE_INTO_SUMMARY';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     l_stmt_num := 10;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Inserting data into OPI_DBI_INV_VALUE_F';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     MERGE INTO OPI_DBI_INV_VALUE_F base
     USING
     (SELECT /*+ index (rate OPI_DBI_CONVERSION_RATES_N2) */
          NULL operating_unit,
          s.organization_id,
          s.subinventory_code,
          s.inventory_item_id,
          s.transaction_date,
          s.onhand_qty,
          s.intransit_qty,
          s.primary_uom,
          s.onhand_value_b,
          s.intransit_value_b,
          s.wip_value_b,
          rate.conversion_rate,
          rate.sec_conversion_rate,
          s.ONHAND_QTY_DRAFT,
          s.INTRANSIT_QTY_DRAFT,
          s.ONHAND_VALUE_B_DRAFT,
          s.INTRANSIT_VALUE_B_DRAFT,
          s.WIP_VALUE_B_DRAFT,
          source
     FROM
          (SELECT /*+ index (msi MTL_SYSTEM_ITEMS_B_U1)  */
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
          from
          (SELECT
                  organization_id,
                  subinventory_code,
                  inventory_item_id,
                  transaction_date,
                  onhand_qty,
                  0 intransit_qty,
                  primary_uom,
                  onhand_value_b,
                  0 intransit_value_b,
                  0 wip_value_b,
                  onhand_qty_draft,
                  0 intransit_qty_draft,
                  onhand_value_b_draft onhand_value_b_draft,
                  0 intransit_value_b_draft,
                  0 wip_value_b_draft,
                  source
                FROM OPI_DBI_ONHAND_STG
                UNION ALL
                select
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
                UNION ALL
                select
                  organization_id,
                  NULL,
                  inventory_item_id,
                  transaction_date,
                  0 onhand_qty,
                  0 intransit_qty,
                  primary_uom,
                  0 onhand_value_b,
                  0 intransit_value_b,
                  wip_value_b,
                  0 onhand_qty_draft,
                  0 intransit_qty_draft,
                  0 onhand_value_b_draft,
                  0 intransit_value_b_draft,
                  wip_value_b_draft,
                  source
                from opi_dbi_wip_stg
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
          ) s,
          (select
               organization_id,
               transaction_date,
               conversion_rate,
               sec_conversion_rate
               from opi_dbi_conversion_rates
          ) rate
          where s.organization_id = rate.organization_id
          and s.transaction_date = rate.transaction_date
          ) stg
          ON
          (base.organization_id = stg.organization_id and
          base.inventory_item_id = stg.inventory_item_id and
          base.transaction_date = stg.transaction_date and
          nvl(base.subinventory_code,-1) = nvl(stg.subinventory_code,-1) and
          base.source = stg.source
          )
     WHEN matched THEN
     update set
     base.onhand_qty = base.onhand_qty + stg.onhand_qty - base.onhand_qty_draft + stg.onhand_qty_draft,
     base.intransit_qty = base.intransit_qty + stg.intransit_qty - base.intransit_qty_draft + stg.intransit_qty_draft,
     base.onhand_value_b = base.onhand_value_b + stg.onhand_value_b - base.onhand_value_b_draft + stg.onhand_value_b_draft,
     base.intransit_value_b = base.intransit_value_b + stg.intransit_value_b - base.intransit_value_b_draft + stg.intransit_value_b_draft,
     base.wip_value_b = base.wip_value_b + stg.wip_value_b - base.wip_value_b_draft + stg.wip_value_b_draft,
     base.onhand_qty_draft = stg.onhand_qty_draft ,
     base.intransit_qty_draft = stg.intransit_qty_draft,
     base.onhand_value_b_draft= stg.onhand_value_b_draft,
     base.intransit_value_b_draft= stg.intransit_value_b_draft ,
     base.wip_value_b_draft = stg.wip_value_b_draft,
     base.last_update_date = sysdate,
     base.last_update_login = g_login_id,
     base.last_updated_by = g_user_id
     WHEN not matched THEN
     insert (operating_unit_id,
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
     values (stg.operating_unit,
           stg.organization_id,
           nvl(stg.subinventory_code,-1),
           stg.inventory_item_id,
           stg.transaction_date,
           stg.onhand_qty+stg.onhand_qty_draft,
           stg.intransit_qty+stg.intransit_qty_draft,
           stg.primary_uom,
           stg.onhand_value_b+stg.onhand_value_b_draft,
           stg.intransit_value_b+stg.intransit_value_b_draft,
           stg.wip_value_b+stg.wip_value_b_draft,
           stg.conversion_rate,
           stg.sec_conversion_rate,
           stg.onhand_qty_draft,
           stg.intransit_qty_draft,
           stg.onhand_value_b_draft,
           stg.intransit_value_b_draft,
           stg.wip_value_b_draft,
           stg.Source,
           g_user_id,
           g_login_id,
           sysdate,
           g_user_id,
           sysdate
           );

    commit;

     l_debug_msg := 'Inserted into staging table OPI_DBI_INV_VALUE_F - ' || SQL%ROWCOUNT || ' rows. ';
     OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);


     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'End of MERGE_INTO_SUMMARY';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

EXCEPTION
    WHEN OTHERS THEN
         l_debug_msg := 'Failed with errror '  ||  SQLcode || ' - ' ||SQLERRM;
         OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);
         RAISE;
END MERGE_INTO_SUMMARY;

-------------------------------------------------------------------------------

PROCEDURE DISCRETE_REFRESH
IS
     OPI_DBI_EXCEPTION EXCEPTION;

     PRAGMA EXCEPTION_INIT (OPI_DBI_EXCEPTION , -20002);

     l_stmt_num      NUMBER;
     l_debug_msg     VARCHAR2(1000);
     l_proc_name     VARCHAR2 (60);
     l_debug_mode    VARCHAR2(1);
     l_module_name   VARCHAR2(30);
     errbuf          VARCHAR2(30);
     retcode         VARCHAR2(30);
BEGIN
     l_proc_name     :=  'DISCRETE_REFRESH';
     l_debug_mode    :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
     l_module_name   :=  FND_PROFILE.value('AFLOG_MODULE');

     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Start of Discrete_Refresh';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     l_stmt_num := 10;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Calling Clean staging table PRE INIT';
          OPI_DBI_BOUNDS_PKG.write (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     OPI_DBI_INV_VALUE_INCR_PKG.clean_staging_table;
     -- cleans staging table.

     -- sets bounds for MMT, GTV and WTA Tables accordingly.
     l_stmt_num := 20;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Setting up bound for Inventory Incremental Load ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;


     OPI_DBI_BOUNDS_PKG.maintain_opi_dbi_logs('INVENTORY','INCR');

     l_stmt_num := 25;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Calling OPI_DBI_BOUNDS_PKG.load_opm_org_ledger_data ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     OPI_DBI_BOUNDS_PKG.load_opm_org_ledger_data;

     l_stmt_num := 30;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Collecting OPI , OPM Incremental Load Inventory Quantities and Values';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     OPI_DBI_INV_VALUE_INCR_PKG.Get_Net_Activity;
     -- even this procedure has a commit as it has two extracts and each one run in parallel append mode.
     commit;

     l_stmt_num :=40;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Checking for Conversion Rate. ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     -- this api prints the report in case there are conversion rates missing.
     -- it returns -1 in case there are missing conversion rates as well.
     IF (OPI_DBI_INV_VALUE_UTL_PKG.Get_Conversion_Rate(errbuf, retcode) = -1) THEN
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name, l_proc_name,l_stmt_num,'Missing currency rate.');
          RAISE OPI_DBI_EXCEPTION;
     END IF;
     COMMIT;


     OPI_DBI_INV_VALUE_INCR_PKG.Merge_Into_Summary;
     commit;

     l_stmt_num := 50;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Finished Collecting OPI, OPM Incremental Load Inventory Quantities and Values';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     l_stmt_num := 60;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Calling Clean staging table PRE INIT';
          OPI_DBI_BOUNDS_PKG.write (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     OPI_DBI_INV_VALUE_INCR_PKG.clean_staging_table;


     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'End of Discrete_Refresh';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

EXCEPTION
     WHEN OPI_DBI_EXCEPTION THEN
          l_debug_msg := 'Failed with errror '  ||  SQLcode || ' - ' ||SQLERRM;
          OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);
          RAISE;
     WHEN OTHERS THEN
         l_debug_msg := 'Failed with errror '  ||  SQLcode || ' - ' ||SQLERRM;
         OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);
         RAISE;
END DISCRETE_REFRESH;
-------------------------------------------------------------------------------

PROCEDURE REFRESH(
                 errbuf  IN OUT NOCOPY VARCHAR2,
                 retcode IN OUT NOCOPY VARCHAR2
                 )
IS
     l_stmt_num      NUMBER;
     l_debug_msg     VARCHAR2(1000);
     l_proc_name     VARCHAR2 (60);
     l_debug_mode    VARCHAR2(1);
     l_module_name   VARCHAR2(30);
     l_uncost_trx    BOOLEAN;

BEGIN
     l_proc_name     :=  'REFRESH';
     l_debug_mode    :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
     l_module_name   :=  FND_PROFILE.value('AFLOG_MODULE');


     l_debug_msg := 'Start of Incremental Load for Inventory ';
     OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );

     l_stmt_num := 5;
     if (bis_collection_utilities.setup(p_object_name => 'OPI_DBI_INV_VALUE_F') = false) then
       raise_application_error(-20000,errbuf);
     end if;

     l_stmt_num :=10;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Checking For Global Parameters';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     -- checks for GSD, primary and sec currency rate types, schema name for OPI
     -- raises exception in case there is an error
     OPI_DBI_INV_VALUE_INCR_PKG.check_incr_load_setup;

     l_stmt_num :=20;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Calling Procedure Discrete Refersh ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     OPI_DBI_INV_VALUE_INCR_PKG.Discrete_Refresh; -- No changes for R12
     commit;

     l_stmt_num :=30;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Calling Procedure Period close Adjustment ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     OPI_DBI_INV_CPCS_PKG.Run_Period_Close_Adjustment(errbuf, retcode);

     l_stmt_num :=40;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Checking for uncosted transactions. ';
          OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     l_uncost_trx  := OPI_DBI_BOUNDS_PKG.bounds_uncosted('INVENTORY', 'INCR');

     IF l_uncost_trx =TRUE   then
          retcode := 1;
          l_debug_msg := 'Warning: There are some uncosted transactions. ';
          OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     l_stmt_num :=50;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := ' Printing Log Bound. ';
          OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     OPI_DBI_BOUNDS_PKG.print_opi_org_bounds('INVENTORY', 'INCR');

     l_stmt_num :=60;
     IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%'  then
          l_debug_msg := 'Updating Log with success ';
          OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );
     END IF;

     OPI_DBI_BOUNDS_PKG.set_load_successful('INVENTORY', 'INCR') ;



     l_debug_msg := 'End of Incremental Load for Inventory ';
     OPI_DBI_BOUNDS_PKG.write  (g_pkg_name,l_proc_name,l_stmt_num, l_debug_msg );

     BIS_COLLECTION_UTILITIES.WRAPUP(
      p_status => TRUE,
      p_count => 0,
      p_message => 'Successfully refreshed inventory value base table at ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')
    );

    RETURN;
EXCEPTION
     WHEN OTHERS THEN
          retcode := -1;
          l_debug_msg := 'Failed with errror '  ||  SQLcode || ' - ' ||SQLERRM;
          OPI_DBI_BOUNDS_PKG.write(g_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);

          BIS_COLLECTION_UTILITIES.WRAPUP(
          p_status => FALSE,
          p_message => 'Failed in Incremental Load of inventory value base table.'
          );
          RAISE;

END REFRESH;

END OPI_DBI_INV_VALUE_INCR_PKG;

/
