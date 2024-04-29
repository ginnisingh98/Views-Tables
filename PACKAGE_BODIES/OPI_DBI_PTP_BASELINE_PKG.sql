--------------------------------------------------------
--  DDL for Package Body OPI_DBI_PTP_BASELINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_PTP_BASELINE_PKG" as
/* $Header: OPIDPTPETLB.pls 120.1 2006/02/19 22:28:38 vganeshk noship $ */

--global variables
g_ok                      CONSTANT NUMBER := 0;
g_error                   CONSTANT NUMBER := -1;
g_warning                 CONSTANT NUMBER := 1;
g_sysdate                 DATE;
g_created_by              NUMBER;
g_last_update_login       NUMBER;
g_last_updated_by         NUMBER;
g_global_start_date       DATE;
g_global_currency_code    VARCHAR2(10);
g_secondary_currency_code VARCHAR2 (10);
g_opi_schema              VARCHAR2(30);
g_degree                  NUMBER := 0;
g_global_rate_type        VARCHAR2(15);
g_secondary_rate_type     VARCHAR2(15);

--pre-defined oracle exceptions
partition_exist_exception       EXCEPTION;
value_exist_exception           EXCEPTION;
tablename_exist_exception       EXCEPTION;
PRAGMA EXCEPTION_INIT (partition_exist_exception, -14013);
PRAGMA EXCEPTION_INIT (value_exist_exception, -14312);
PRAGMA EXCEPTION_INIT (tablename_exist_exception, -00955);

--ptp-defined exceptions
intialization_exception         EXCEPTION;
collection_parameter_exception  EXCEPTION;
load_exception                  EXCEPTION;
archive_cleanup_exception       EXCEPTION;
update_log_exception            EXCEPTION;
cost_conversion_rate_exception  EXCEPTION;
mv_refresh_exception            EXCEPTION;
isc_collection_exception        EXCEPTION;

PRAGMA EXCEPTION_INIT (intialization_exception, -20900);
PRAGMA EXCEPTION_INIT (collection_parameter_exception, -20901);
PRAGMA EXCEPTION_INIT (load_exception, -20902);
PRAGMA EXCEPTION_INIT (archive_cleanup_exception, -20903);
PRAGMA EXCEPTION_INIT (update_log_exception, -20904);
PRAGMA EXCEPTION_INIT (cost_conversion_rate_exception, -20905);
PRAGMA EXCEPTION_INIT (mv_refresh_exception, -20906);
PRAGMA EXCEPTION_INIT (isc_collection_exception, -20907);

/*
Procedure to extract cost/conversion rate for discrete manufacturing orgs.
We extract cost for all items of organizations associated with the baseline being processed.
*/
PROCEDURE Get_Discrete_Cost_and_Rate
(
  errbuf  OUT NOCOPY VARCHAR2,
  retcode OUT NOCOPY VARCHAR2
)
IS
  TYPE NUMBERLIST is TABLE of NUMBER;
  l_org_list NUMBERLIST := NUMBERLIST();
  l_existing_list NUMBERLIST := NUMBERLIST();
  l_new_orgs VARCHAR2(1024) := NULL;
  l_existing_orgs VARCHAR2(1024) := NULL;
  TYPE DATELIST is TABLE of DATE;
  l_from_dates DATELIST := DATELIST();
  l_stmt VARCHAR2(10240);
  l_currency_code VARCHAR2(10);
  l_rate NUMBER;
  l_secondary_rate NUMBER;
  l_missing_flag NUMBER := 0;
  l_stmt_num NUMBER := 0;

  -- marker to see if primary and secondary currencies are the same
  l_pri_sec_curr_same NUMBER;

BEGIN

  l_stmt_num := 5;
  l_pri_sec_curr_same := 0;
  -- check if the primary and secondary currencies and rate types are
  -- identical.
  IF (g_global_currency_code = nvl (g_secondary_currency_code, '---') AND
      g_global_rate_type = nvl (g_secondary_rate_type, '---') ) THEN
      l_pri_sec_curr_same := 1;
  END IF;


  --get list of organizations, for which cost/conv rate need to be collected.
  BIS_COLLECTION_UTILITIES.put_line('Get list of organizations to be processed.');
  l_stmt_num := 10;

  select org1.organization_id, nvl(org2.existing_flag, 0), org1.from_date
    bulk collect into l_org_list, l_existing_list, l_from_dates
    from (select /*+ no_merge use_hash(sched,setup,plan,org) */
                 distinct org.organization_id,
                 sched.from_date
            from isc_dbi_plan_organizations org,
                 isc_dbi_plans plan,
                 opi_dbi_baseline_schedules sched,
                 opi_dbi_baseline_plans setup
           where sched.next_collection_date <= g_sysdate
             and sched.schedule_type = 1
             and sched.baseline_id = setup.baseline_id
             and setup.plan_name = plan.compile_designator
             and setup.owning_org_id = plan.organization_id
             and org.plan_id = plan.plan_id
         ) org1,
         (select distinct organization_id,
                 1 existing_flag
            from opi_dbi_ptp_conv
         ) org2
   where org1.organization_id = org2.organization_id (+)
  ;

  IF l_org_list.count <> 0 THEN
    FOR i IN l_org_list.FIRST..l_org_list.LAST LOOP
      IF l_existing_list(i) = 0 THEN
          l_new_orgs := l_new_orgs || l_org_list(i) || ',';
      ELSE
          l_existing_orgs := l_existing_orgs || l_org_list(i) || ',';
      END IF;
    END LOOP;
  END IF;

  IF l_new_orgs IS NOT NULL THEN
    l_new_orgs := '(' || substrb(l_new_orgs, 1, instrb(l_new_orgs, ',', -1, 1)-1) || ')';
  END IF;

  IF l_existing_orgs IS NOT NULL THEN
    l_existing_orgs := '(' || substrb(l_existing_orgs, 1, instrb(l_existing_orgs, ',', -1, 1)-1) || ')';
  END IF;

  BIS_COLLECTION_UTILITIES.put_line('l_new_orgs=' || l_new_orgs);
  BIS_COLLECTION_UTILITIES.put_line('l_existing_orgs=' || l_existing_orgs);

  --collect cost for new organizations
  --two rows inserted for each new item-org as:
  -- row 1: from_date = global_start_date, to_date = baseline from_date, cost = 0
  -- row 2: from_date = baseline from_date, to_date = null, cost = item cost from cst_item_costs
  IF l_new_orgs IS NOT NULL THEN
    BIS_COLLECTION_UTILITIES.put_line('Collect item cost for new organizations.');
    l_stmt_num := 30;
    l_stmt := ' insert into OPI_DBI_PTP_COST
                (
                 FROZEN_FLAG,
                 ORGANIZATION_ID,
                 INVENTORY_ITEM_ID,
                 UNIT_COST,
                 FROM_DATE,
                 TO_DATE,
                 SOURCE,
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 LAST_UPDATE_LOGIN
                )
                select /*+ use_hash(msi,mp) index_ffs(msi,MTL_SYSTEM_ITEMS_B_U1) parallel_index(msi,MTL_SYSTEM_ITEMS_B_U1) */
                       null l_frozen_flag,
                       msi.organization_id,
                       msi.inventory_item_id,
                       0 item_cost,
                       :g_global_start_date FROM_DATE,
                       org_dates.from_date TO_DATE,
                       :l_source,
                       :g_sysdate,
                       :g_last_updated_by,
                       :g_sysdate,
                       :g_last_updated_by,
                       :g_last_update_login
                  from
                       mtl_parameters mp,
                       mtl_system_Items_b msi,
                       (select /*+ no_merge use_hash(sched,setup,plan,orgs) */
                               orgs.organization_id,
                               sched.from_date
                          from opi_dbi_baseline_schedules sched,
                               opi_dbi_baseline_plans setup,
                               isc_dbi_plans plan,
                               isc_dbi_plan_organizations orgs
                         where sched.next_collection_date <= :g_sysdate
                           and sched.schedule_type = 1
                           and sched.baseline_id = setup.baseline_id
                           and setup.plan_name = plan.compile_designator
                           and setup.owning_org_id = plan.organization_id
                           and plan.plan_id = orgs.plan_id
                       ) org_dates
                 where mp.organization_id in ' || l_new_orgs ||
               '   AND mp.organization_id = org_dates.organization_id
                   AND mp.process_enabled_flag <> ''Y''
                   AND mp.organization_id = msi.organization_id
                union all
                select /*+ use_hash(cic) index(cic CST_ITEM_COSTS_U1) parallel(io) parallel(cic) */
                       :l_frozen_flag,
                       io.organization_id,
                       io.inventory_item_id,
                       nvl(cic.item_cost, 0) item_cost,
                       org_dates.from_date FROM_DATE,
                       null TO_DATE,
                       :l_source,
                       :g_sysdate,
                       :g_last_updated_by,
                       :g_sysdate,
                       :g_last_updated_by,
                       :g_last_update_login
                  from
                       cst_item_costs cic,
                       (select /*+ no_merge use_hash(msi) parallel(mp) index_ffs(msi,MTL_SYSTEM_ITEMS_B_U1) parallel_index(msi,MTL_SYSTEM_ITEMS_B_U1) */
                               msi.organization_id,
                               msi.inventory_item_id,
                               decode (mp.primary_cost_method, 1, 1, 2) cost_type_id
                          from
                               mtl_system_items_b msi,
                               mtl_parameters mp
                         where mp.organization_id in ' || l_new_orgs || '
                           AND mp.process_enabled_flag <> ''Y''
                           AND mp.organization_id = msi.organization_id
                       ) io,
                       (select /*+ no_merge use_hash(sched,setup,plan,orgs) */
                               orgs.organization_id,
                               sched.from_date
                          from opi_dbi_baseline_schedules sched,
                               opi_dbi_baseline_plans setup,
                               isc_dbi_plans plan,
                               isc_dbi_plan_organizations orgs
                         where sched.next_collection_date <= :g_sysdate
                           and sched.schedule_type = 1
                           and sched.baseline_id = setup.baseline_id
                           and setup.plan_name = plan.compile_designator
                           and setup.owning_org_id = plan.organization_id
                           and plan.plan_id = orgs.plan_id
                       ) org_dates
                 where io.organization_id = org_dates.organization_id
                   AND io.organization_id = cic.organization_id (+)
                   AND io.inventory_item_id = cic.inventory_item_id (+)
                   AND io.cost_type_id = cic.cost_type_id (+)
               '
    ;
    EXECUTE IMMEDIATE l_stmt USING g_global_start_date, 1, g_sysdate, g_last_updated_by, g_sysdate, g_last_updated_by, g_last_update_login, g_sysdate, -1, 1, g_sysdate, g_last_updated_by, g_sysdate, g_last_updated_by, g_last_update_login, g_sysdate;
    --get conversion rate for new organizations
    -- added secondary currency support
    BIS_COLLECTION_UTILITIES.put_line('Collect conversion rate new organizations.');
    FOR i IN l_org_list.FIRST..l_org_list.LAST LOOP
      IF l_existing_list(i) = 0 THEN
        l_stmt_num := 40;
        SELECT gsob.currency_code
          INTO l_currency_code
          FROM hr_organization_information hoi,
               gl_sets_of_books gsob
         WHERE
               hoi.ORG_INFORMATION_CONTEXT  = 'Accounting Information'
           AND hoi.org_information1  = to_char(gsob.set_of_books_id)
           AND hoi.organization_id  = l_org_list(i)
           AND rownum < 2;

        l_stmt_num := 50;
        IF sql%rowcount = 1 THEN

          -- secondary currency support and conversion rate standards based
          -- calls to FII API's
          IF (l_currency_code = g_global_currency_code) THEN
            l_rate := 1;
          ELSE
            SELECT fii_currency.get_global_rate_primary(l_currency_code, g_sysdate)
              INTO l_rate
              FROM dual;
          END IF;

          IF (l_currency_code = g_secondary_currency_code) THEN
            l_secondary_rate := 1;
          ELSIF (l_pri_sec_curr_same = 1) THEN
            l_secondary_rate := l_rate;
          ELSIF (g_secondary_currency_code IS NULL) THEN
            l_secondary_rate := NULL;
          ELSE
            l_secondary_rate := fii_currency.get_global_rate_secondary
                                        (l_currency_code, g_sysdate);
          END IF;

          -- The FII APIs behave as follows:
          -- Return: rate (> 0) if one exists.
          --         -1 if no rate exists for given day
          --         -2 if the currency code is not recognized
          --         -3 if Euro rate is missing prior to 01-JAN-1999.
          If ( (l_rate >= 0) AND
               ( (l_secondary_rate >= 0) OR
                 (l_secondary_rate IS NULL AND
                  g_secondary_currency_code IS NULL) ) ) THEN
            l_stmt_num := 60;
            l_stmt := '
                      insert into OPI_DBI_PTP_CONV
                      (
                       FROZEN_FLAG,
                       ORGANIZATION_ID,
                       CONVERSION_RATE,
                       SEC_CONVERSION_RATE,
                       CURRENCY_CODE,
                       FROM_DATE,
                       TO_DATE,
                       SOURCE,
                       CREATION_DATE,
                       CREATED_BY,
                       LAST_UPDATE_DATE,
                       LAST_UPDATED_BY,
                       LAST_UPDATE_LOGIN
                      )
                      VALUES (
                       null,
                       :l_org_id,
                       :l_rate,
                       :l_secondary_rate,
                       :l_currency_code,
                       :g_global_start_date,
                       :l_from_date,
                       :l_source,
                       :g_sysdate,
                       :g_last_upated_by,
                       :g_sysdate,
                       :g_last_updated_by,
                       :g_last_update_login
                      )
                      '
                      ;
            EXECUTE IMMEDIATE l_stmt USING l_org_list(i), 0, 0, l_currency_code, g_global_start_date, l_from_dates(i), 1, g_sysdate, g_last_updated_by, g_sysdate, g_last_updated_by, g_last_update_login;

            l_stmt := '
                      insert into OPI_DBI_PTP_CONV
                      (
                       FROZEN_FLAG,
                       ORGANIZATION_ID,
                       CONVERSION_RATE,
                       SEC_CONVERSION_RATE,
                       CURRENCY_CODE,
                       FROM_DATE,
                       TO_DATE,
                       SOURCE,
                       CREATION_DATE,
                       CREATED_BY,
                       LAST_UPDATE_DATE,
                       LAST_UPDATED_BY,
                       LAST_UPDATE_LOGIN
                      )
                      VALUES (
                       :l_frozen_flag,
                       :l_org_id,
                       :l_rate,
                       :l_secondary_rate,
                       :l_currency_code,
                       :l_from_date,
                       null,
                       :l_source,
                       :g_sysdate,
                       :g_last_upated_by,
                       :g_sysdate,
                       :g_last_updated_by,
                       :g_last_update_login
                      )
                      '
                      ;
            EXECUTE IMMEDIATE l_stmt USING -1, l_org_list(i), l_rate, l_secondary_rate, l_currency_code, l_from_dates(i), 1, g_sysdate, g_last_updated_by, g_sysdate, g_last_updated_by, g_last_update_login;
          ELSE
            IF (l_missing_flag = 0) THEN
              l_missing_flag := 1;
              BIS_COLLECTION_UTILITIES.writeMissingRateHeader;
            END IF;
	    IF (l_rate = -1) THEN
            BIS_COLLECTION_UTILITIES.writeMissingRate(
              g_global_rate_type,
              l_currency_code,
              g_global_currency_code,
              g_sysdate
            );
	    END IF;
	    IF (l_secondary_rate = -1) THEN
            BIS_COLLECTION_UTILITIES.writeMissingRate(
              g_global_rate_type,
              l_currency_code,
              g_secondary_currency_code,
              g_sysdate
            );
	    END IF;
          END IF;
        END IF;
      END IF;
    END LOOP;
  END IF;

  --get cost/conversion rate for existing organizations
  IF l_existing_orgs IS NOT NULL THEN
    BIS_COLLECTION_UTILITIES.put_line('Collect item cost for existing organizations.');
    l_stmt_num := 70;
    l_stmt := '
              update OPI_DBI_PTP_COST
                 set frozen_flag = null,
                     to_date = :g_sysdate,
                     last_update_date = :g_sysdate,
                     last_updated_by = :g_last_updated_by,
                     last_update_login = :g_last_update_login,
                     source = -1
               where frozen_flag = -1
                 and source = 1
                 and organization_id in ' || l_existing_orgs
              ;

    EXECUTE IMMEDIATE l_stmt USING g_sysdate, g_sysdate, g_last_updated_by, g_last_update_login;
    l_stmt_num := 80;
    l_stmt :='
              merge into OPI_DBI_PTP_COST cost
              using
              (
              select /*+ use_hash(cic) parallel(io) parallel(cic) */
                     :l_frozen_flag frozen_flag,
                     io.organization_id,
                     io.inventory_item_id,
                     nvl(cic.item_cost, 0) item_cost,
                     :g_sysdate from_date,
                     null to_date,
                     :l_source source
                from
                     cst_item_costs cic,
                     (select /*+ no_merge use_hash(msi) parallel(mp) index_ffs(msi,MTL_SYSTEM_ITEMS_B_U1) parallel_index(msi,MTL_SYSTEM_ITEMS_B_U1) */
                             msi.organization_id,
                             msi.inventory_item_id,
                             decode (mp.primary_cost_method, 1, 1, 2) cost_type_id
                        from
                             mtl_system_items_b msi,
                             mtl_parameters mp
                       where mp.organization_id in ' || l_existing_orgs || '
                         AND mp.process_enabled_flag <> ''Y''
                         AND mp.organization_id = msi.organization_id
                     ) io
               where io.organization_id = cic.organization_id (+)
                 AND io.inventory_item_id = cic.inventory_item_id (+)
                 AND io.cost_type_id = cic.cost_type_id (+)
              ) new_cost
              on
              ( cost.organization_id = new_cost.organization_id
                and cost.inventory_item_id = new_cost.inventory_item_id
                and cost.unit_cost = new_cost.item_cost
                and cost.source = -1
              )
              when matched then
                update set
                  cost.frozen_flag = -1,
                  cost.to_date = null
              when not matched then
                insert
                (
                 FROZEN_FLAG,
                 ORGANIZATION_ID,
                 INVENTORY_ITEM_ID,
                 UNIT_COST,
                 FROM_DATE,
                 TO_DATE,
                 SOURCE,
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 LAST_UPDATE_LOGIN
                )
                values
                (
                 new_cost.frozen_flag,
                 new_cost.organization_id,
                 new_cost.inventory_item_id,
                 new_cost.item_cost,
                 new_cost.from_date,
                 new_cost.to_date,
                 new_cost.source,
                 :g_sysdate,
                 :g_last_updated_by,
                 :g_sysdate,
                 :g_last_updated_by,
                 :g_last_update_login
              )
             ';
    EXECUTE IMMEDIATE l_stmt USING -1, g_sysdate, 1, g_sysdate, g_last_updated_by, g_sysdate, g_last_updated_by, g_last_update_login;

    --shift date back to global_start_date for new items
    l_stmt :='
              update OPI_DBI_PTP_COST
                 set from_date = :g_global_start_date
               where (organization_id, inventory_item_id) in
                     (select organization_id, inventory_item_id from OPI_DBI_PTP_COST
                       where source = 1 and frozen_flag = -1 and creation_date = :g_sysdate
                      minus
                      select organization_id, inventory_item_id from OPI_DBI_PTP_COST
                       where source = -1
                     )
             ';
    EXECUTE IMMEDIATE l_stmt USING g_global_start_date, g_sysdate;

    l_stmt_num := 90;
    update opi_dbi_ptp_cost
       set source = 1
     where source = -1
    ;

    --get conversion rate for existing organizations
    BIS_COLLECTION_UTILITIES.put_line('Collect conversion rate for existing organizations.');
    l_stmt_num := 100;
    l_stmt := '
              update OPI_DBI_PTP_CONV
                 set frozen_flag = null,
                     to_date = :g_sysdate,
                     last_update_date = :g_sysdate,
                     last_updated_by = :g_last_updated_by,
                     last_update_login = :g_last_update_login,
                     source = -1
               where organization_id in ' || l_existing_orgs ||
              '  and frozen_flag = -1
                 and source = 1
              ';

    EXECUTE IMMEDIATE l_stmt USING g_sysdate, g_sysdate, g_last_updated_by, g_last_update_login;

    FOR i IN l_org_list.FIRST..l_org_list.LAST LOOP
      IF l_existing_list(i) = 1 THEN
        l_stmt_num := 110;
        SELECT gsob.currency_code
          INTO l_currency_code
          FROM hr_organization_information hoi,
               gl_sets_of_books gsob
         WHERE
               hoi.ORG_INFORMATION_CONTEXT  = 'Accounting Information'
           AND hoi.org_information1  = to_char(gsob.set_of_books_id)
           AND hoi.organization_id  = l_org_list(i)
           AND rownum < 2;

        l_stmt_num := 120;
        IF sql%rowcount = 1 THEN

          -- secondary currency support and conversion rate standards based
          -- calls to FII API's
          IF (l_currency_code = g_global_currency_code) THEN
            l_rate := 1;
          ELSE
            SELECT fii_currency.get_global_rate_primary(l_currency_code, g_sysdate)
              INTO l_rate
              FROM dual;
          END IF;

          IF (l_currency_code = g_secondary_currency_code) THEN
            l_secondary_rate := 1;
          ELSIF (l_pri_sec_curr_same = 1) THEN
            l_secondary_rate := l_rate;
          ELSIF (g_secondary_currency_code IS NULL) THEN
            l_secondary_rate := NULL;
          ELSE
            l_secondary_rate := fii_currency.get_global_rate_secondary
                                        (l_currency_code, g_sysdate);
          END IF;

        l_stmt_num := 130;
          -- The FII APIs behave as follows:
          -- Return: rate (> 0) if one exists.
          --         -1 if no rate exists for given day
          --         -2 if the currency code is not recognized
          --         -3 if Euro rate is missing prior to 01-JAN-1999.
          IF ( (l_rate >= 0) AND
               ( (l_secondary_rate >= 0) OR
                 (l_secondary_rate IS NULL AND
                  g_secondary_currency_code IS NULL) ) ) THEN

            l_stmt := '
                      merge into OPI_DBI_PTP_CONV conv
                      using
                      (
                      select
                             :l_org_id organization_id,
                             :l_rate conversion_rate,
                             :l_secondary_rate sec_conversion_rate,
                             :g_sysdate from_date,
                             null to_date
                        from dual
                      ) new_conv
                      on
                      ( conv.organization_id = new_conv.organization_id
                        and conv.conversion_rate = new_conv.conversion_rate
                        and nvl (conv.sec_conversion_rate, -9999) = nvl (new_conv.sec_conversion_rate, -9999)
                        and conv.source = -1
                      )
                      when matched then
                        update set
                          conv.frozen_flag = -1,
                          conv.to_date = null
                      when not matched then
                        insert (
                         FROZEN_FLAG,
                         ORGANIZATION_ID,
                         CONVERSION_RATE,
                         SEC_CONVERSION_RATE,
                         CURRENCY_CODE,
                         FROM_DATE,
                         TO_DATE,
                         SOURCE,
                         CREATION_DATE,
                         CREATED_BY,
                         LAST_UPDATE_DATE,
                         LAST_UPDATED_BY,
                         LAST_UPDATE_LOGIN
                        )
                        values
                        (
                         :l_frozen_flag,
                         new_conv.organization_id,
                         new_conv.conversion_rate,
                         new_conv.sec_conversion_rate,
                         :l_currency_code,
                         new_conv.from_date,
                         new_conv.to_date,
                         :l_source,
                         :g_sysdate,
                         :g_last_upated_by,
                         :g_sysdate,
                         :g_last_updated_by,
                         :g_last_update_login
                        )
                      ';
            EXECUTE IMMEDIATE l_stmt USING l_org_list(i), l_rate, l_secondary_rate, g_sysdate, -1, l_currency_code, 1, g_sysdate, g_last_updated_by, g_sysdate, g_last_updated_by, g_last_update_login;
          ELSE
            IF (l_missing_flag = 0) THEN
              l_missing_flag := 1;
              BIS_COLLECTION_UTILITIES.writeMissingRateHeader;
            END IF;
	    IF (l_rate = -1) THEN
            BIS_COLLECTION_UTILITIES.writeMissingRate(
              g_global_rate_type,
              l_currency_code,
              g_global_currency_code,
              g_sysdate
            );
	    END IF;
	    IF (l_secondary_rate = -1) THEN
            BIS_COLLECTION_UTILITIES.writeMissingRate(
              g_global_rate_type,
              l_currency_code,
              g_secondary_currency_code,
              g_sysdate
            );
	    END IF;
          END IF;
        END IF;
      END IF;
    END LOOP;

    l_stmt_num := 140;
    update OPI_DBI_PTP_CONV
       set source = 1
     where source = -1
    ;
  END IF;

  IF l_missing_flag = 1 THEN
    errbuf := 'Exit because of missing currency rate.';
    RAISE cost_conversion_rate_exception;
  END IF;

EXCEPTION
  WHEN cost_conversion_rate_exception THEN
    BIS_COLLECTION_UTILITIES.put_line('There are missing currency rate. Program stops. Please check output file for more details.');
    retcode := g_error;
    RAISE cost_conversion_rate_exception;
  WHEN OTHERS THEN
    BIS_COLLECTION_UTILITIES.put_line('Fail to collect cost/conversion rate for discrete manufacturing organizations.');
    BIS_COLLECTION_UTILITIES.put_line('Error out at stmt_num ' || l_stmt_num || ' in Get_Discrete_Cost_and_Rate.');
    retcode := g_error;
    errbuf := SQLERRM;
    RAISE cost_conversion_rate_exception;
END Get_Discrete_Cost_and_Rate;

PROCEDURE Get_Process_Cost
(
  errbuf  OUT NOCOPY VARCHAR2,
  retcode OUT NOCOPY VARCHAR2
)
IS
  TYPE NUMBERLIST is TABLE of NUMBER;
  l_org_list NUMBERLIST := NUMBERLIST();
  l_existing_list NUMBERLIST := NUMBERLIST();
  l_new_orgs VARCHAR2(1024) := NULL;
  l_existing_orgs VARCHAR2(1024) := NULL;
  TYPE DATELIST is TABLE of DATE;
  l_from_dates DATELIST := DATELIST();
  l_stmt VARCHAR2(10240);
  l_missing_flag NUMBER := 0;
  l_stmt_num NUMBER := 0;
BEGIN
  --get list of organizations, for which cost need to be collected.
  BIS_COLLECTION_UTILITIES.put_line('Get list of Process-enabled organizations to be processed.');
  l_stmt_num := 10;

-- following statement is same as for discrete, except limiting organizations to process-enabled

  select org1.organization_id, nvl(org2.existing_flag, 0), org1.from_date
    bulk collect into l_org_list, l_existing_list, l_from_dates
    from (select /*+ no_merge use_hash(sched,setup,plan,org) */
                 distinct org.organization_id,
                 sched.from_date
            from isc_dbi_plan_organizations org,
                 isc_dbi_plans plan,
                 opi_dbi_baseline_schedules sched,
                 opi_dbi_baseline_plans setup
           where sched.next_collection_date <= g_sysdate
             and sched.schedule_type = 1
             and sched.baseline_id = setup.baseline_id
             and setup.plan_name = plan.compile_designator
             and setup.owning_org_id = plan.organization_id
             and org.plan_id = plan.plan_id
         ) org1,
         (select distinct organization_id,
                 1 existing_flag
            from opi_dbi_ptp_conv
         ) org2,
         mtl_parameters mp
   where org1.organization_id = org2.organization_id (+)
   and org1.organization_id = mp.organization_id
   and mp.process_enabled_flag = 'Y';

   BIS_COLLECTION_UTILITIES.put_line(TO_CHAR(SQL%ROWCOUNT) || ' orgs identified for cost determination.');

  IF l_org_list.count <> 0 THEN
    FOR i IN l_org_list.FIRST..l_org_list.LAST LOOP
      IF l_existing_list(i) = 0 THEN
          l_new_orgs := l_new_orgs || l_org_list(i) || ',';
      ELSE
          l_existing_orgs := l_existing_orgs || l_org_list(i) || ',';
      END IF;
    END LOOP;
  END IF;

  IF l_new_orgs IS NOT NULL THEN
    l_new_orgs := '(' || substrb(l_new_orgs, 1, instrb(l_new_orgs, ',', -1, 1)-1) || ')';
    BIS_COLLECTION_UTILITIES.put_line('Collect item cost for new Process-Enabled organizations.');
    l_stmt_num := 30;
    l_stmt := 'INSERT INTO opi_pmi_cost_param_gtmp
               (
                   item_id,
                   whse_code,
                   orgn_code,
                   trans_date
               )
               SELECT
                   i.item_id,
                   w.whse_code,
                   w.orgn_code,
                   SYSDATE trans_date
               FROM
                   ic_item_mst_b i,
                   ic_whse_mst w
               WHERE
                   w.mtl_organization_id IN ' || l_new_orgs;

    EXECUTE IMMEDIATE l_stmt;

    BIS_COLLECTION_UTILITIES.put_line(TO_CHAR(SQL%ROWCOUNT) || ' org items identified for costing.');

    opi_pmi_cost.get_cost;

  END IF;

  IF l_existing_orgs IS NOT NULL THEN
    l_existing_orgs := '(' || substrb(l_existing_orgs, 1, instrb(l_existing_orgs, ',', -1, 1)-1) || ')';
    BIS_COLLECTION_UTILITIES.put_line('Adding item cost for new Process-Enabled organizations...');
    l_stmt_num := 35;
    l_stmt := 'INSERT INTO opi_pmi_cost_param_gtmp
               (
                   item_id,
                   whse_code,
                   orgn_code,
                   trans_date
               )
               SELECT
                   i.item_id,
                   w.whse_code,
                   w.orgn_code,
                   SYSDATE trans_date
               FROM
                   ic_item_mst_b i,
                   ic_whse_mst w
               WHERE
                   w.mtl_organization_id IN ' || l_existing_orgs;

    EXECUTE IMMEDIATE l_stmt;

    BIS_COLLECTION_UTILITIES.put_line(TO_CHAR(SQL%ROWCOUNT) || ' org items identified for costing.');

    opi_pmi_cost.get_cost;

  END IF;

  BIS_COLLECTION_UTILITIES.put_line('l_new_orgs=' || l_new_orgs);
  BIS_COLLECTION_UTILITIES.put_line('l_existing_orgs=' || l_existing_orgs);

  --collect cost for new organizations
  --two rows inserted for each new item-org as:
  -- row 1: from_date = global_start_date, to_date = baseline from_date, cost = 0
  -- row 2: from_date = baseline from_date, to_date = null, cost = item cost from cst_item_costs


  IF l_new_orgs IS NOT NULL THEN

    l_stmt := ' insert into OPI_DBI_PTP_COST
                (
                 FROZEN_FLAG,
                 ORGANIZATION_ID,
                 INVENTORY_ITEM_ID,
                 UNIT_COST,
                 FROM_DATE,
                 TO_DATE,
                 SOURCE,
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 LAST_UPDATE_LOGIN
                )
                select
                       null l_frozen_flag,
                       msi.organization_id,
                       msi.inventory_item_id,
                       0 item_cost,
                       :g_global_start_date FROM_DATE,
                       org_dates.from_date TO_DATE,
                       :l_source,
                       :g_sysdate,
                       :g_last_updated_by,
                       :g_sysdate,
                       :g_last_updated_by,
                       :g_last_update_login
                  from
                       mtl_parameters mp,
                       mtl_system_Items_b msi,
                       (select orgs.organization_id,
                               sched.from_date
                          from opi_dbi_baseline_schedules sched,
                               opi_dbi_baseline_plans setup,
                               isc_dbi_plans plan,
                               isc_dbi_plan_organizations orgs
                         where sched.next_collection_date <= :g_sysdate
                           and sched.schedule_type = 1
                           and sched.baseline_id = setup.baseline_id
                           and setup.plan_name = plan.compile_designator
                           and setup.owning_org_id = plan.organization_id
                           and plan.plan_id = orgs.plan_id
                       ) org_dates
                 where mp.organization_id in ' || l_new_orgs ||
               '   AND mp.organization_id = org_dates.organization_id
                   AND mp.process_enabled_flag = ''Y''
                   AND mp.organization_id = msi.organization_id
                union all
                select
                       :l_frozen_flag,
                       msi.organization_id,
                       msi.inventory_item_id,
                       nvl(cst.total_cost, 0) item_cost,
                       org_dates.from_date FROM_DATE,
                       null TO_DATE,
                       :l_source,
                       :g_sysdate,
                       :g_last_updated_by,
                       :g_sysdate,
                       :g_last_updated_by,
                       :g_last_update_login
                  from
                       (select orgs.organization_id,
                               sched.from_date
                          from opi_dbi_baseline_schedules sched,
                               opi_dbi_baseline_plans setup,
                               isc_dbi_plans plan,
                               isc_dbi_plan_organizations orgs
                         where sched.next_collection_date <= :g_sysdate
                           and sched.schedule_type = 1
                           and sched.baseline_id = setup.baseline_id
                           and setup.plan_name = plan.compile_designator
                           and setup.owning_org_id = plan.organization_id
                           and plan.plan_id = orgs.plan_id
                       ) org_dates,
                       ic_whse_mst w,
                       mtl_system_items_b msi,
                       ic_item_mst_b i,
                       opi_pmi_cost_result_gtmp cst
                 where
                       w.mtl_organization_id = org_dates.organization_id
                   AND msi.organization_id = w.mtl_organization_id
                   AND i.item_no = msi.segment1
                   AND i.item_id = cst.item_id
                   AND w.whse_code = cst.whse_code
               '
    ;
    EXECUTE IMMEDIATE l_stmt USING g_global_start_date, 2, g_sysdate, g_last_updated_by, g_sysdate,
                                   g_last_updated_by, g_last_update_login, g_sysdate, -1, 2,
                                   g_sysdate, g_last_updated_by, g_sysdate, g_last_updated_by,
                                   g_last_update_login, g_sysdate;

    BIS_COLLECTION_UTILITIES.put_line(TO_CHAR(SQL%ROWCOUNT) || ' costs collected for new Process orgs.');

  END IF; -- l_new_orgs IS NOT NULL

  --get cost/conversion rate for existing organizations
  IF l_existing_orgs IS NOT NULL THEN
    BIS_COLLECTION_UTILITIES.put_line('Collect item cost for existing organizations.');
    l_stmt_num := 70;
    l_stmt := '
              update OPI_DBI_PTP_COST
                 set frozen_flag = null,
                     to_date = :g_sysdate,
                     last_update_date = :g_sysdate,
                     last_updated_by = :g_last_updated_by,
                     last_update_login = :g_last_update_login,
                     source = -2
               where frozen_flag = -1
                 and source = 2
                 and organization_id in ' || l_existing_orgs
              ;

    EXECUTE IMMEDIATE l_stmt USING g_sysdate, g_sysdate, g_last_updated_by, g_last_update_login;

    l_stmt_num := 80;
    l_stmt :='
              merge into OPI_DBI_PTP_COST cost
              using
              (
              select
                     :l_frozen_flag frozen_flag,
                     msi.organization_id,
                     msi.inventory_item_id,
                     nvl(cst.total_cost, 0) item_cost,
                     :g_sysdate from_date,
                     null to_date,
                     :l_source source
                from
                     opi_pmi_cost_result_gtmp cst,
                     ic_whse_mst w,
                     ic_item_mst_b i,
                     mtl_system_items_b msi
               where
                     w.mtl_organization_id IN ' || l_existing_orgs || '
                 AND w.whse_code = cst.whse_code
                 AND i.item_id = cst.item_id
                 AND msi.segment1 = i.item_no
                 AND msi.organization_id = w.mtl_organization_id
              ) new_cost
              on
              ( cost.organization_id = new_cost.organization_id
                and cost.inventory_item_id = new_cost.inventory_item_id
                and cost.unit_cost = new_cost.item_cost
                and cost.source = -1
              )
              when matched then
                update set
                  cost.frozen_flag = -1,
                  cost.to_date = null
              when not matched then
                insert
                (
                 FROZEN_FLAG,
                 ORGANIZATION_ID,
                 INVENTORY_ITEM_ID,
                 UNIT_COST,
                 FROM_DATE,
                 TO_DATE,
                 SOURCE,
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 LAST_UPDATE_LOGIN
                )
                values
                (
                 new_cost.frozen_flag,
                 new_cost.organization_id,
                 new_cost.inventory_item_id,
                 new_cost.item_cost,
                 new_cost.from_date,
                 new_cost.to_date,
                 new_cost.source,
                 :g_sysdate,
                 :g_last_updated_by,
                 :g_sysdate,
                 :g_last_updated_by,
                 :g_last_update_login
              )
             ';
    EXECUTE IMMEDIATE l_stmt USING -1, g_sysdate, 2, g_sysdate, g_last_updated_by, g_sysdate, g_last_updated_by, g_last_update_login;

    BIS_COLLECTION_UTILITIES.put_line(TO_CHAR(SQL%ROWCOUNT) || ' Process Org costs merged into costing fact.');

    --shift date back to global_start_date for new items
    l_stmt :='
              update OPI_DBI_PTP_COST
                 set from_date = :g_global_start_date
               where (organization_id, inventory_item_id) in
                     (select organization_id, inventory_item_id from OPI_DBI_PTP_COST
                       where source = 2 and frozen_flag = -1 and creation_date = :g_sysdate
                      minus
                      select organization_id, inventory_item_id from OPI_DBI_PTP_COST
                       where source = -2
                     )
             ';

    EXECUTE IMMEDIATE l_stmt USING g_global_start_date, g_sysdate;

    l_stmt_num := 90;
    update opi_dbi_ptp_cost
       set source = 2
     where source = -2
    ;

  END IF; -- l_existing_orgs IS NOT NULL

EXCEPTION
  WHEN OTHERS THEN
    BIS_COLLECTION_UTILITIES.put_line('Fail to collect cost for Process Manufacturing organizations.');
    BIS_COLLECTION_UTILITIES.put_line('Error out at stmt_num ' || l_stmt_num || ' in Get_Process_Cost');
    retcode := g_error;
    errbuf := SQLERRM;
    RAISE cost_conversion_rate_exception;

END Get_Process_Cost;

PROCEDURE Extract_Baseline
(
  errbuf  IN OUT NOCOPY VARCHAR2,
  retcode IN OUT NOCOPY VARCHAR2
)
IS
  l_segment_num NUMBER;
  l_refresh NUMBER;
  l_list dbms_sql.varchar2_table;
  l_status VARCHAR2(30);
  l_industry VARCHAR2(30);
  l_from_date DATE;
  l_has_missing_date BOOLEAN;
  l_isc_return_code NUMBER;
  TYPE STRINGLIST is table of VARCHAR2(255);
  l_strings STRINGLIST := STRINGLIST();
  l_create_tables STRINGLIST := STRINGLIST();
  l_insert_tables STRINGLIST := STRINGLIST();
  l_add_partitions STRINGLIST := STRINGLIST();
  l_swap_partitions STRINGLIST := STRINGLIST();
  l_drop_tables STRINGLIST := STRINGLIST();
  TYPE DATELIST is table of DATE;
  l_collected_dates DATELIST := DATELIST();
  TYPE NUMBERLIST is table of NUMBER;
  l_baseline_ids NUMBERLIST := NUMBERLIST();
  l_stmt VARCHAR2(10240);
  l_count NUMBER;
  l_delete NUMBER;
  l_archive NUMBER;
  cursor l_baseline_info is
  select def.baseline_id,
         def.data_start_date,
         sched.from_date
    from OPI_DBI_BASELINE_DEFINITIONS def,
         OPI_DBI_BASELINE_SCHEDULES sched
   where def.baseline_id = sched.baseline_id
     and sched.next_collection_date <= trunc(sysdate)
     and sched.schedule_type = 1
  ;
  l_baseline_record l_baseline_info%ROWTYPE;
BEGIN
  --setup
  BIS_COLLECTION_UTILITIES.put_line('Start baseline collection.');
  l_segment_num := 10;
  /* we don't truncate table here at first run. purge/deletion should be provided separately*/

  IF BIS_COLLECTION_UTILITIES.SETUP(
       p_object_name => 'OPI_DBI_PTP_PLAN_F'
       ) = false then
       BIS_COLLECTION_UTILITIES.put_line('Fail to initialize through BIS_COLLECTION_UTILITIES.SETUP.');
       retcode := g_error;
       errbuf := 'Program stops.';
       RAISE intialization_exception;
  End if;

  l_segment_num := 20;
  BIS_COLLECTION_UTILITIES.put_line('Check global variables.');
  l_list(1) := 'BIS_GLOBAL_START_DATE';
  l_list(2) := 'BIS_PRIMARY_CURRENCY_CODE';
  l_list(3) := 'BIS_PRIMARY_RATE_TYPE';

  IF (NOT BIS_COMMON_PARAMETERS.CHECK_GLOBAL_PARAMETERS(l_list)) THEN
    BIS_COLLECTION_UTILITIES.put_line('Missing global parameters. Please setup global_start_date and primary_currency_code first.');
    retcode := g_error;
    errbuf := 'Program stops.';
    RAISE intialization_exception;
  END IF;

  --initialize global variables
  BIS_COLLECTION_UTILITIES.put_line('Initialize global variables.');
  l_segment_num := 30;
  BEGIN
    g_sysdate := trunc(sysdate);
    g_created_by := nvl(fnd_global.user_id, -1);
    g_last_update_login := nvl(fnd_global.login_id, -1);
    g_last_updated_by := nvl(fnd_global.user_id, -1);
    SELECT BIS_COMMON_PARAMETERS.GET_GLOBAL_START_DATE INTO g_global_start_date FROM DUAL;
    SELECT bis_common_parameters.get_currency_code INTO g_global_currency_code FROM dual;
    IF g_global_currency_code IS NULL THEN
      RAISE intialization_exception;
    END IF;

    IF NOT fnd_installation.get_app_info( 'OPI', l_status, l_industry, g_opi_schema) THEN
      RAISE intialization_exception;
    END IF;
    g_degree := bis_common_parameters.get_degree_of_parallelism;
    BIS_COLLECTION_UTILITIES.put_line('global_start_date = ' || TO_CHAR(g_global_start_date, 'DD-MON-YYYY') || '.');
    g_global_rate_type := bis_common_parameters.get_rate_type;
    BIS_COLLECTION_UTILITIES.put_line('The primary rate type is ' || g_global_rate_type);

    -- secondary currency support
    g_secondary_rate_type := bis_common_parameters.get_secondary_rate_type;
    g_secondary_currency_code :=
            bis_common_parameters.get_secondary_currency_code;

    -- check that either both the secondary rate type and secondary
    -- rate are null, or that neither are null.
    IF (   (g_secondary_currency_code IS NULL AND
            g_secondary_rate_type IS NOT NULL)
        OR (g_secondary_currency_code IS NOT NULL AND
            g_secondary_rate_type IS NULL) ) THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE ('The global secondary currency code setup is incorrect. The secondary currency code cannot be null when the secondary rate type is defined and vice versa.');

        RAISE intialization_exception;

    END IF;


  EXCEPTION
    WHEN others THEN
      BIS_COLLECTION_UTILITIES.put_line('Fail to initialize global variable values. Please re-run the concurrent request set.');
      retcode := g_error;
      errbuf := SQLERRM;
      RAISE intialization_exception;
  END;

  --if fail to refresh OPI_PTP_SUM_STG_MV last time, try to refresh it again
  BEGIN
    select stop_reason_code into l_refresh from opi_dbi_run_log_curr where etl_id = 7 and source = 1;
    IF l_refresh = 1 THEN
      BIS_COLLECTION_UTILITIES.put_line('re-synchronize OPI_PTP_SUM_STG_MV with OPI_DBI_PTP_PLAN_STG.');
      EXECUTE IMMEDIATE 'ALTER SESSION FORCE PARALLEL QUERY';
      DBMS_MVIEW.REFRESH('OPI_PTP_SUM_STG_MV','?',parallelism => g_degree);
      EXECUTE IMMEDIATE 'ALTER SESSION DISABLE PARALLEL QUERY';
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      insert into opi_dbi_run_log_curr
      (organization_id,
       source,
       last_collection_date,
       start_txn_id,
       next_start_txn_id,
       etl_id,
       stop_reason_code,
       last_transaction_date,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       last_update_login)
      values
      (null, 1, null, null, null, 7, 2, null, g_sysdate, g_last_updated_by, g_sysdate, g_last_updated_by, g_last_update_login);
      commit;
    WHEN OTHERS THEN
      BIS_COLLECTION_UTILITIES.put_line('Fail to refresh materialized view OPI_PTP_SUM_STG_MV. Please fix the problem and re-run the concurrent request set.');
      retcode := g_error;
      errbuf := SQLERRM;
      RAISE intialization_exception;
  END;

  --check missing date in time dimension
  --some logic here is commented out, because ISC APS extraction has checked dangling key against time dimension.
  --BIS_COLLECTION_UTILITIES.put_line('Check missing date against time dimension.');
  BIS_COLLECTION_UTILITIES.put_line('Check scheduled baseline collections.');
  l_segment_num := 40;
  BEGIN
    select min(from_date)
      into l_from_date
      from
           (
            select sched.baseline_id,
                   sched.from_date
              from OPI_DBI_BASELINE_SCHEDULES sched,
                   OPI_DBI_BASELINE_PLANS setup
             where sched.next_collection_date <= g_sysdate
               and sched.schedule_type = 1
               and sched.baseline_id = setup.baseline_id
           ) boundary
     ;
  EXCEPTION
    WHEN others THEN
      BIS_COLLECTION_UTILITIES.put_line('Fail to retreive following collection information: minimum from_date and maximum to_date.');
      retcode := g_error;
      errbuf := SQLERRM;
      RAISE intialization_exception;
  END;

  /*
  l_from_date = null, meaning that there is no scheduled collection to be processed. just simply exit.
  */
  IF l_from_date is NULL THEN
    BIS_COLLECTION_UTILITIES.put_line('There is no scheduled collection. Program exits normally.');
    BIS_COLLECTION_UTILITIES.WRAPUP(
      p_status => TRUE,
      p_count => 0,
      p_message => 'There is no scheduled collection.'
    );
    retcode := g_ok;
    return;
  END IF;

  --change per bug 3422479
  --call ISC APS collection program to get latest APS data
  BIS_COLLECTION_UTILITIES.put_line('Collect latest APS snapshot.');
  l_segment_num := 65;
  l_isc_return_code := ISC_DBI_MSC_OBJECTS_C.LOAD_BASES;
  IF (l_isc_return_code <> 1 ) THEN
     --BIS_COLLECTION_UTILITIES.put_line('Fail to collect latest APS snapshot.');
     retcode := g_error;
     errbuf := 'Fail to collect latest APS snapshot.';
     RAISE isc_collection_exception;
  END IF;

  --validate information against baseline setup
  --Check if one organization exists in more than one baseline as scheduled
  BIS_COLLECTION_UTILITIES.put_line('Check if one organization exists in more than one baselines.');
  l_segment_num := 50;
  select count(*)
    into l_count
    from
    (
    select orgs.organization_id, count(orgs.plan_id) num_of_plans
      from OPI_DBI_BASELINE_SCHEDULES sched,
           OPI_DBI_BASELINE_PLANS setup,
           ISC_DBI_PLANS plan,
           ISC_DBI_PLAN_ORGANIZATIONS orgs
     where sched.next_collection_date <= g_sysdate
       and sched.schedule_type = 1
       and sched.baseline_id = setup.baseline_id
       and setup.plan_name = plan.compile_designator
       and setup.owning_org_id = plan.organization_id
       and plan.plan_id = orgs.plan_id
  group by orgs.organization_id
    ) org_plan
   where num_of_plans > 1
  ;

  IF l_count > 0 THEN
    BIS_COLLECTION_UTILITIES.put_line('There are organizations existing in more than one baseline, which is not allowed. Please verify baseline setup.');
    retcode := g_error;
    errbuf := 'Organizations exist in more than one baseline.';
    RAISE collection_parameter_exception;
  END IF;

  --Check from_date against plan run date
  BIS_COLLECTION_UTILITIES.put_line('Check from_date against plan run date.');
  BEGIN
  select count(*)
    into l_count
    from OPI_DBI_BASELINE_SCHEDULES sched,
         OPI_DBI_BASELINE_PLANS setup,
         ISC_DBI_PLANS plan
   where sched.baseline_id = setup.baseline_id
     and setup.plan_name = plan.compile_designator
     and setup.owning_org_id = plan.organization_id
     and sched.from_date < trunc(plan.data_start_date)
     and sched.next_collection_date <= g_sysdate
     and sched.schedule_type = 1
  ;
  EXCEPTION
    WHEN others THEN
      retcode := g_error;
      errbuf := SQLERRM;
      RAISE collection_parameter_exception;
  END;

  IF l_count <> 0 THEN
    BIS_COLLECTION_UTILITIES.put_line('Some APS plans have plan run date post to associated baseline collection from_date. Please reset the from_date.');
    BIS_COLLECTION_UTILITIES.put_line(RPAD('BASELINE NAME', 20, ' ') || ' ' ||
                         RPAD('PLAN NAME', 20, ' ') || ' ' ||
                         RPAD('FROM DATE', 20, ' ') || ' ' ||
                         RPAD('PLAN RUN DATE', 20, ' ')
                        );
    BIS_COLLECTION_UTILITIES.put_line(RPAD('-', 20, '-') || ' ' ||
                         RPAD('-', 20, '-') || ' ' ||
                         RPAD('-', 20, '-') || ' ' ||
                         RPAD('-', 20, '-')
                        );
    select RPAD(def.baseline_name, 20, ' ') || ' ' ||
           RPAD(setup.plan_name, 20, ' ') || ' ' ||
           RPAD(TO_CHAR(sched.from_date, 'DD-MON-YYYY'), 20, ' ') || ' ' ||
           RPAD(TO_CHAR(plan.data_start_date, 'DD-MON-YYYY'), 20, ' ')
      bulk collect into l_strings
      from OPI_DBI_BASELINE_DEFINITIONS def,
           OPI_DBI_BASELINE_SCHEDULES sched,
           OPI_DBI_BASELINE_PLANS setup,
           ISC_DBI_PLANS plan
     where def.baseline_id = sched.baseline_id
       and sched.baseline_id = setup.baseline_id
       and setup.plan_name = plan.compile_designator
       and setup.owning_org_id = plan.organization_id
       and sched.next_collection_date <= g_sysdate
       and sched.schedule_type = 1
    ;

    FOR i IN l_strings.FIRST..l_strings.LAST LOOP
      BIS_COLLECTION_UTILITIES.put_line(l_strings(i));
    END LOOP;
    retcode := g_error;
    errbuf := 'Program stops.';
    RAISE collection_parameter_exception;
  END IF;

  --lock schedules to be processed
  BIS_COLLECTION_UTILITIES.put_line('Lock rows of schedules to be processed.');
  l_segment_num := 60;
  lock table opi_dbi_baseline_definitions in exclusive mode;


  --start loading new data
  BIS_COLLECTION_UTILITIES.put_line('Start loading new data');
  l_segment_num := 70;
  BEGIN
  select def.baseline_name, sched.baseline_id, def.last_collected_date
    bulk collect into l_strings, l_baseline_ids, l_collected_dates
    from OPI_DBI_BASELINE_SCHEDULES sched,
         OPI_DBI_BASELINE_DEFINITIONS def
   where sched.next_collection_date <= g_sysdate
     and sched.schedule_type = 1
     and def.baseline_id = sched.baseline_id
  ;
  EXCEPTION
    WHEN others THEN
      BIS_COLLECTION_UTILITIES.put_line('Fail to retreive baseline information.');
      retcode := g_error;
      errbuf := SQLERRM;
      RAISE load_exception;
  END;

  --prepare statements
  BIS_COLLECTION_UTILITIES.put_line('Prepare SQL statements.');
  l_segment_num := 80;
  IF l_baseline_ids.count <> 0 THEN
    l_create_tables.extend(l_baseline_ids.count);
    l_insert_tables.extend(l_baseline_ids.count);
    l_add_partitions.extend(l_baseline_ids.count);
    l_swap_partitions.extend(l_baseline_ids.count);
    l_drop_tables.extend(l_baseline_ids.count);
    FOR i IN l_baseline_ids.FIRST..l_baseline_ids.LAST LOOP
      --prepare create table stmt
      l_create_tables(i) := 'CREATE TABLE OPI_DBI_PTP_TMP_' || l_baseline_ids(i);
      --prepare insert table stmt
      l_insert_tables(i) := 'WHEN BASELINE_ID = ''' || l_baseline_ids(i) || ''' THEN INTO OPI_DBI_PTP_TMP_' || l_baseline_ids(i);
      --prepare add partition stmt
      IF l_collected_dates(i) IS NULL THEN
        l_add_partitions(i) := 'ALTER TABLE '|| g_opi_schema || '.OPI_DBI_PTP_PLAN_STG ADD PARTITION BASELINE_' || l_baseline_ids(i) || ' VALUES(' || l_baseline_ids(i) ||')';
      END IF;
      --prepare swap partition stmt
      l_swap_partitions(i) := 'ALTER TABLE '|| g_opi_schema || '.OPI_DBI_PTP_PLAN_STG EXCHANGE PARTITION BASELINE_' || l_baseline_ids(i) || ' WITH TABLE OPI_DBI_PTP_TMP_' || l_baseline_ids(i) || ' including indexes without validation';
      --prepare drop table stmt
      l_drop_tables(i) := 'DROP TABLE OPI_DBI_PTP_TMP_' || l_baseline_ids(i);
    END LOOP;
  END IF;

  BIS_COLLECTION_UTILITIES.put_line('Create temporary regular tables.');
  l_segment_num := 90;
  IF l_create_tables.count <> 0 THEN
    FOR i IN l_create_tables.FIRST..l_create_tables.LAST LOOP
      l_stmt := l_create_tables(i) || ' (' ||
        'ORGANIZATION_ID        NUMBER NOT NULL, ' ||
        'BASELINE_ID            NUMBER NOT NULL, ' ||
        'PLAN_NAME              VARCHAR2(10) NOT NULL, ' ||
        'OWNING_ORG_ID          NUMBER NOT NULL, ' ||
        'INVENTORY_ITEM_ID      NUMBER NOT NULL, ' ||
        'TRANSACTION_DATE       DATE NOT NULL, ' ||
        'PLANNED_QUANTITY       NUMBER, ' ||
        'UOM_CODE               VARCHAR2(3), ' ||
        'CREATION_DATE          DATE NOT NULL, ' ||
        'CREATED_BY             NUMBER NOT NULL, ' ||
        'LAST_UPDATE_DATE       DATE NOT NULL, ' ||
        'LAST_UPDATED_BY        NUMBER NOT NULL, ' ||
        'LAST_UPDATE_LOGIN      NUMBER)';
      BEGIN
        BIS_COLLECTION_UTILITIES.put_line('...'|| l_create_tables(i));
        EXECUTE IMMEDIATE l_stmt;
      EXCEPTION
        WHEN tablename_exist_exception THEN
          BIS_COLLECTION_UTILITIES.put_line('Temporary regular table already exists for baseline ' || l_strings(i) || '. Cleanup temporary table.');
          EXECUTE IMMEDIATE 'truncate table opi_dbi_ptp_tmp_' || l_baseline_ids(i);
        WHEN others THEN
          BIS_COLLECTION_UTILITIES.put_line('Fail to create temporary regular table for baseline ' || l_strings(i) || '.');
          retcode := g_error;
          errbuf := SQLERRM;
          RAISE load_exception;
      END;
    END LOOP;
  END IF;

  BIS_COLLECTION_UTILITIES.put_line('Insert new data into temporary regular tables.');
  l_segment_num := 100;
  l_stmt := 'INSERT /*+ append ';
  IF l_baseline_ids.count <> 0 THEN
    FOR i IN l_baseline_ids.FIRST..l_baseline_ids.LAST LOOP
      l_stmt := l_stmt || 'parallel(OPI_DBI_PTP_TMP_' || l_baseline_ids(i) || ') ';
    END LOOP;
  END IF;
  l_stmt := l_stmt || '*/ FIRST ';
  IF l_insert_tables.count <> 0 THEN
    FOR i IN l_create_tables.FIRST..l_create_tables.LAST LOOP
      l_stmt := l_stmt || l_insert_tables(i)
                       || ' VALUES (' ||
                          'ORGANIZATION_ID, ' ||
                          'BASELINE_ID, ' ||
                          'PLAN_NAME, ' ||
                          'OWNING_ORG_ID, ' ||
                          'INVENTORY_ITEM_ID, ' ||
                          'TRANSACTION_DATE, ' ||
                          'PLANNED_QUANTITY, ' ||
                          'UOM_CODE, ' ||
                          'CREATION_DATE, ' ||
                          'CREATED_BY, ' ||
                          'LAST_UPDATE_DATE, ' ||
                          'LAST_UPDATED_BY, ' ||
                          'LAST_UPDATE_LOGIN)';
    END LOOP;
    l_stmt := l_stmt || ' ' ||
        'select /*+ ordered use_nl(time) use_hash(bucket, supply) parallel(supply) */
                supply.organization_id      ORGANIZATION_ID,
                bl.baseline_id              BASELINE_ID,
                bl.compile_designator       PLAN_NAME,
                bl.organization_id          OWNING_ORG_ID,
                supply.sr_inventory_item_id INVENTORY_ITEM_ID,
                trunc(time.report_date)     TRANSACTION_DATE,
                sum(nvl(supply.new_order_quantity, 0)/bucket.days_in_bkt) PLANNED_QUANTITY,
                supply.uom_code             UOM_CODE,
                :g_sysdate                  CREATION_DATE,
                :g_last_updated_by          CREATED_BY,
                :g_sysdate                  LAST_UPDATE_DATE,
                :g_last_updated_by          LAST_UPDATED_BY,
                :g_last_update_login        LAST_UPDATE_LOGIN
            from
                (select /*+ no_merge use_hash(sched,setup,plan) */
                   sched.baseline_id,
                   sched.from_date,
                   sched.to_date,
                   plan.plan_id,
                   plan.compile_designator,
                   plan.organization_id,
                   plan.cutoff_date
                 from
                   opi_dbi_baseline_schedules sched,
                   opi_dbi_baseline_plans setup,
                   isc_dbi_plans plan
                 where sched.next_collection_date <= :g_sysdate
                   and sched.schedule_type = 1
                   and sched.baseline_id = setup.baseline_id
                   and setup.plan_name = plan.compile_designator
                   and setup.owning_org_id = plan.organization_id
                ) bl,
                isc_dbi_plan_buckets bucket,
                fii_time_day_all_v time,
                isc_dbi_supplies_f supply
            where bucket.plan_id = bl.plan_id
            and bucket.organization_id = bl.organization_id
            and bucket.plan_id = supply.plan_id
            and supply.new_schedule_date + nvl(supply.new_processing_days, 0) between bucket.bkt_start_date and bucket.bkt_end_date
            AND nvl(supply.disposition_status_type, 0) <> 2
            and supply.in_source_plan = 2
            and nvl(supply.bom_item_type, 0) <> 3
            --and nvl(supply.r_cfm_routing_flag, 0) <> 3
            and (supply.order_type in (3, 14, 16, 27, 28, 30)
                 OR
                 (supply.order_type in (5, 17)
                  AND supply.source_sr_instance_id = supply.sr_instance_id
                  AND supply.source_organization_id = supply.organization_id
                 )
                 OR
                 (supply.order_type in (5, 17)
                  AND supply.source_sr_instance_id is null
                  AND supply.source_supplier_id is null
                  AND supply.planning_make_buy_code = 1
                 )
                )
            and time.report_date between bucket.bkt_start_date and bucket.bkt_end_date
            and time.report_date between bl.from_date and nvl(bl.to_date, bl.cutoff_date)
            group by
                supply.organization_id,
                bl.baseline_id,
                bl.compile_designator,
                bl.organization_id,
                supply.sr_inventory_item_id,
                trunc(time.report_date),
                supply.uom_code
        ';
    BEGIN
      EXECUTE IMMEDIATE l_stmt USING g_sysdate, g_last_updated_by, g_sysdate, g_last_updated_by, g_last_update_login, g_sysdate;
      null;
    EXCEPTION
      WHEN others THEN
        BIS_COLLECTION_UTILITIES.put_line('Fail to insert new data into temporary regular table.');
        retcode := g_error;
        errbuf := SQLERRM;
        RAISE load_exception;
    END;
  END IF;

  /*commit explicitly for direct load*/
  commit;

  BIS_COLLECTION_UTILITIES.put_line('Add new partitions if necessary.');
  l_segment_num := 110;
  IF l_add_partitions.count <> 0 THEN
    FOR i IN l_add_partitions.FIRST..l_add_partitions.LAST LOOP
      BEGIN
        IF l_collected_dates(i) IS NULL THEN
          BIS_COLLECTION_UTILITIES.put_line('...'|| l_add_partitions(i));
          EXECUTE IMMEDIATE l_add_partitions(i);
        END IF;
      EXCEPTION
        WHEN partition_exist_exception or value_exist_exception THEN
          BIS_COLLECTION_UTILITIES.put_line('Partition exists already for baseline ' || l_strings(i) || '. No action.');
        WHEN others THEN
          BIS_COLLECTION_UTILITIES.put_line('Fail to add partition to baseline staging table for baseline ' || l_strings(i) || '.');
          retcode := g_error;
          errbuf := SQLERRM;
          RAISE load_exception;
      END;
    END LOOP;
  END IF;

  BIS_COLLECTION_UTILITIES.put_line('Swap partitions with corresponding temporary regular tables.');
  l_segment_num := 120;
  IF l_swap_partitions.count <> 0 THEN
    FOR i IN l_swap_partitions.FIRST..l_swap_partitions.LAST LOOP
      BEGIN
        BIS_COLLECTION_UTILITIES.put_line('...'|| l_swap_partitions(i));
        EXECUTE IMMEDIATE l_swap_partitions(i);
      EXCEPTION
        WHEN others THEN
          BIS_COLLECTION_UTILITIES.put_line('Fail to exchange partition for baseline ' || l_strings(i) || '.');
          retcode := g_error;
          errbuf := SQLERRM;
          RAISE load_exception;
      END;
    END LOOP;
  END IF;

  BIS_COLLECTION_UTILITIES.put_line('Drop temporary regular tables.');
  l_segment_num := 130;
  IF l_drop_tables.count <> 0 THEN
    FOR i IN l_drop_tables.FIRST..l_drop_tables.LAST LOOP
      BEGIN
        BIS_COLLECTION_UTILITIES.put_line('...'|| l_drop_tables(i));
        EXECUTE IMMEDIATE l_drop_tables(i);
      EXCEPTION
        WHEN others THEN
          retcode := g_error;
          errbuf := SQLERRM;
          RAISE load_exception;
      END;
    END LOOP;
  END IF;

  --archive/cleanup data
  BEGIN
    select SUM(decode(sign(sched.from_date - def.last_from_date), -1, 1, 0)) del_cnt,
           SUM(decode(sign(sched.from_date - def.last_from_date), 1, 1, 0)) arv_cnt
      into l_delete, l_archive
      from OPI_DBI_BASELINE_DEFINITIONS def,
           OPI_DBI_BASELINE_SCHEDULES sched
     where sched.next_collection_date <= g_sysdate
       and sched.schedule_type = 1
       and sched.baseline_id = def.baseline_id
    ;
  EXCEPTION
    WHEN others THEN
      BIS_COLLECTION_UTILITIES.put_line('Fail to determine if there is need to cleanup/archive data.');
      retcode := g_error;
      errbuf := SQLERRM;
      RAISE archive_cleanup_exception;
  END;

  l_segment_num := 140;
  IF l_delete > 0 THEN
  BIS_COLLECTION_UTILITIES.put_line('Clean up data in baseline fact table.');
    BEGIN
      delete from OPI_DBI_PTP_PLAN_F
      where
        rowid in
        (select f.rowid
           from OPI_DBI_PTP_PLAN_F f,
                OPI_DBI_BASELINE_SCHEDULES sched
          where sched.next_collection_date <= g_sysdate
            and sched.schedule_type = 1
            and f.baseline_id = sched.baseline_id
            and f.transaction_date >= sched.from_date
        );
    EXCEPTION
      WHEN others THEN
        BIS_COLLECTION_UTILITIES.put_line('Fail to delete old data from baseline fact table.');
        retcode := g_error;
        errbuf := SQLERRM;
        RAISE archive_cleanup_exception;
    END;
  END IF;

  l_segment_num := 150;
  IF l_archive > 0 THEN
  BIS_COLLECTION_UTILITIES.put_line('Archive data into baseline fact table.');
    BEGIN
      insert /*+ append parallel(OPI_DBI_PTP_PLAN_F) */
      into OPI_DBI_PTP_PLAN_F
      (
       ORGANIZATION_ID,
       BASELINE_ID,
       PLAN_NAME,
       OWNING_ORG_ID,
       INVENTORY_ITEM_ID,
       TRANSACTION_DATE,
       PLANNED_QUANTITY,
       UOM_CODE,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN
      )
      select /*+ use_hash(day,stg) parallel(stg) parallel(day) */
             stg.ORGANIZATION_ID,
             stg.BASELINE_ID,
             stg.PLAN_NAME,
             stg.OWNING_ORG_ID,
             stg.INVENTORY_ITEM_ID,
             day.report_date,
             stg.PLANNED_QUANTITY,
             stg.UOM_CODE,
             g_sysdate,
             g_last_updated_by,
             g_sysdate,
             g_last_updated_by,
             g_last_update_login
        from OPI_PTP_SUM_STG_MV stg,
             OPI_DBI_BASELINE_SCHEDULES sched,
             fii_time_day day
       where sched.next_collection_date <= g_sysdate
         and sched.schedule_type = 1
         and stg.baseline_id = sched.baseline_id
         and stg.item_cat_flag = 0
         and stg.period_type_id = 1
         and stg.day_id = day.report_date_julian
         and day.report_date < sched.from_date
      ;
      --only new rows inserted being reported to wrapup procedure
      l_count := SQL%ROWCOUNT;
    EXCEPTION
      WHEN others THEN
        BIS_COLLECTION_UTILITIES.put_line('Fail to archive data into baseline fact table.');
        retcode := g_error;
        errbuf := SQLERRM;
        RAISE archive_cleanup_exception;
    END;
  END IF;

  --put call to get cost/conv collection here
  l_segment_num := 160;
  BIS_COLLECTION_UTILITIES.put_line('Collect cost/conversion rate information.');
  Get_Discrete_Cost_and_Rate(errbuf, retcode);
  Get_Process_Cost(errbuf, retcode);

  --Archive collection history

  BIS_COLLECTION_UTILITIES.put_line('Archive collection history into log table, update baseline setup tables.');
  BEGIN
    l_segment_num := 170;
    insert into OPI_DBI_PTP_LOG
    (
     BASELINE_ID,
     BASELINE_NAME,
     PLAN_NAME,
     OWNING_ORG_ID,
     ORGANIZATION_ID,
     FROM_DATE,
     TO_DATE,
     COLLECTED_DATE,
     PLAN_RUN_DATE,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN
    )
    select def.BASELINE_ID,
           def.BASELINE_NAME,
           setup.PLAN_NAME,
           setup.OWNING_ORG_ID,
           orgs.ORGANIZATION_ID,
           sched.FROM_DATE,
           nvl(sched.TO_DATE, plan.cutoff_date),
           g_sysdate COLLECTED_DATE,
           plan.data_start_date PLAN_RUN_DATE,
           g_sysdate,
           g_last_updated_by,
           g_sysdate,
           g_last_updated_by,
           g_last_update_login
      from OPI_DBI_BASELINE_DEFINITIONS def,
           OPI_DBI_BASELINE_SCHEDULES sched,
           OPI_DBI_BASELINE_PLANS setup,
           ISC_DBI_PLANS plan,
           ISC_DBI_PLAN_ORGANIZATIONS orgs
     where def.baseline_id = sched.baseline_id
       and sched.next_collection_date <= g_sysdate
       and sched.schedule_type = 1
       and sched.baseline_id = setup.baseline_id
       and setup.plan_name = plan.compile_designator
       and setup.owning_org_id = plan.organization_id
       and plan.plan_id = orgs.plan_id
    ;

    l_segment_num := 180;
    update OPI_DBI_BASELINE_DEFINITIONS def
       set (data_start_date, last_collected_date, last_from_date, last_to_date, last_update_date, last_updated_by, last_update_login)
           =
           (select nvl(def.data_start_date, sched.FROM_DATE),
                   g_sysdate,
                   sched.FROM_DATE,
                   min(nvl(sched.TO_DATE, plan.cutoff_date)),
                   g_sysdate,
                   g_last_updated_by,
                   g_last_update_login
              from OPI_DBI_BASELINE_SCHEDULES sched,
                   OPI_DBI_BASELINE_PLANS setup,
                   ISC_DBI_PLANS plan
             where def.baseline_id = sched.baseline_id
               and sched.baseline_id = setup.baseline_id
               and setup.plan_name = plan.compile_designator
               and setup.owning_org_id = plan.organization_id
            group by def.data_start_date, sched.FROM_DATE
           )
    where def.baseline_id in
          (select baseline_id from opi_dbi_baseline_schedules
            where next_collection_date <= g_sysdate
              and schedule_type = 1
          )
    ;

    FOR l_baseline_record IN l_baseline_info LOOP
      IF (l_baseline_record.data_start_date IS NOT NULL) and (l_baseline_record.data_start_date > l_baseline_record.from_date) THEN
        l_segment_num := 190;
        update OPI_DBI_PTP_COST cost
           set to_date = l_baseline_record.from_date
        where cost.organization_id in
              (select orgs.organization_id
                 from OPI_DBI_BASELINE_PLANS setup,
                      ISC_DBI_PLANS plan,
                      ISC_DBI_PLAN_ORGANIZATIONS orgs
                where setup.baseline_id = l_baseline_record.baseline_id
                  and setup.plan_name = plan.compile_designator
                  and setup.owning_org_id = plan.organization_id
                  and plan.plan_id = orgs.plan_id
              )
          and cost.to_date = l_baseline_record.data_start_date
        ;

        update OPI_DBI_PTP_COST cost
           set from_date = l_baseline_record.from_date
        where cost.organization_id in
              (select orgs.organization_id
                 from OPI_DBI_BASELINE_PLANS setup,
                      ISC_DBI_PLANS plan,
                      ISC_DBI_PLAN_ORGANIZATIONS orgs
                where setup.baseline_id = l_baseline_record.baseline_id
                  and setup.plan_name = plan.compile_designator
                  and setup.owning_org_id = plan.organization_id
                  and plan.plan_id = orgs.plan_id
              )
          and cost.from_date = l_baseline_record.data_start_date
        ;

        update OPI_DBI_PTP_CONV conv
           set to_date = l_baseline_record.from_date
        where conv.organization_id in
              (select orgs.organization_id
                 from OPI_DBI_BASELINE_PLANS setup,
                      ISC_DBI_PLANS plan,
                      ISC_DBI_PLAN_ORGANIZATIONS orgs
                where setup.baseline_id = l_baseline_record.baseline_id
                  and setup.plan_name = plan.compile_designator
                  and setup.owning_org_id = plan.organization_id
                  and plan.plan_id = orgs.plan_id
              )
          and conv.to_date = l_baseline_record.data_start_date
        ;

        update OPI_DBI_PTP_CONV conv
           set from_date = l_baseline_record.from_date
        where conv.organization_id in
              (select orgs.organization_id
                 from OPI_DBI_BASELINE_PLANS setup,
                      ISC_DBI_PLANS plan,
                      ISC_DBI_PLAN_ORGANIZATIONS orgs
                where setup.baseline_id = l_baseline_record.baseline_id
                  and setup.plan_name = plan.compile_designator
                  and setup.owning_org_id = plan.organization_id
                  and plan.plan_id = orgs.plan_id
              )
          and conv.from_date = l_baseline_record.data_start_date
        ;

        l_segment_num := 200;
        update OPI_DBI_BASELINE_DEFINITIONS def
           set data_start_date = last_from_date
        where baseline_id = l_baseline_record.baseline_id
        ;
      END IF;

    update OPI_DBI_BASELINE_SCHEDULES
       set from_date = null,
           to_date = null,
           schedule_type = null,
           next_collection_date = null
     where baseline_id = l_baseline_record.baseline_id
    ;
    END LOOP;
  EXCEPTION
    WHEN others THEN
      retcode := g_error;
      errbuf := SQLERRM;
      RAISE update_log_exception;
  END;

  --explict commit
  COMMIT;

  --synchronize OPI_PTP_SUM_STG_MV with OPI_DBI_PTP_PLAN_STG
  BIS_COLLECTION_UTILITIES.put_line('synchronize OPI_PTP_SUM_STG_MV with OPI_DBI_PTP_PLAN_STG.');
  l_segment_num := 180;
  --analyze table first per performance team's advice
  FND_STATS.GATHER_TABLE_STATS(errbuf,retcode,'OPI','OPI_DBI_PTP_PLAN_STG');
  BEGIN
    EXECUTE IMMEDIATE 'ALTER SESSION FORCE PARALLEL QUERY';
    DBMS_MVIEW.REFRESH('OPI_PTP_SUM_STG_MV','?',parallelism => g_degree);
    EXECUTE IMMEDIATE 'ALTER SESSION DISABLE PARALLEL QUERY';
    update opi_dbi_run_log_curr
       set stop_reason_code = 2
     where etl_id = 7 and source = 1;
    commit;
  EXCEPTION
    WHEN OTHERS THEN
      update opi_dbi_run_log_curr
         set stop_reason_code = 1
       where etl_id = 7 and source = 1;
      commit;
      BIS_COLLECTION_UTILITIES.put_line('Fail to refresh materialized view OPI_PTP_SUM_STG_MV. Please fix the problem and re-run the concurrent request set.');
      RAISE mv_refresh_exception;
  END;

  BIS_COLLECTION_UTILITIES.put_line('Successfully collect baseline data on ' || TO_CHAR(g_sysdate, 'DD-MON-YYYY') || '.');
  BIS_COLLECTION_UTILITIES.WRAPUP(
    p_status => TRUE,
    p_count => l_count,
    p_message => 'Successfully collect baseline data on ' || TO_CHAR(g_sysdate, 'DD-MON-YYYY') || '.'
   );

  retcode := g_ok;
  return;
EXCEPTION
  WHEN intialization_exception or collection_parameter_exception or isc_collection_exception THEN
    ROLLBACK;
    BIS_COLLECTION_UTILITIES.put_line('Error out at segment ' || l_segment_num || '.');
    BIS_COLLECTION_UTILITIES.put_line(errbuf);
    BIS_COLLECTION_UTILITIES.WRAPUP(
      p_status => FALSE,
      p_message => 'Failed to collect baseline data.'
    );
  WHEN load_exception or archive_cleanup_exception or update_log_exception or cost_conversion_rate_exception THEN
    ROLLBACK;
    BIS_COLLECTION_UTILITIES.put_line('Error out at segment ' || l_segment_num || '.');
    BIS_COLLECTION_UTILITIES.put_line(errbuf);
    IF l_segment_num >= 90 THEN
      IF l_drop_tables.count <> 0 THEN
        FOR i IN l_drop_tables.FIRST..l_drop_tables.LAST LOOP
          BIS_COLLECTION_UTILITIES.put_line('...' || l_drop_tables(i));
          BEGIN
            EXECUTE IMMEDIATE l_drop_tables(i);
          EXCEPTION
            --if data has been dropped, ignore the other
            WHEN others THEN
              null;
          END;
        END LOOP;
      END IF;
    END IF;
    BIS_COLLECTION_UTILITIES.WRAPUP(
      p_status => FALSE,
      p_message => 'Failed to collect baseline data.'
    );
  WHEN others THEN
    ROLLBACK;
    BIS_COLLECTION_UTILITIES.put_line('Error out at segment ' || l_segment_num || '.');
    retcode := g_error;
    errbuf := SQLERRM;
    BIS_COLLECTION_UTILITIES.put_line(errbuf);
    BIS_COLLECTION_UTILITIES.WRAPUP(
      p_status => FALSE,
      p_message => 'Failed to collect baseline data.'
    );
END Extract_Baseline;

PROCEDURE REFRESH_RPT_BND_MV(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
BEGIN
  -- very small mv. don't need parallelism, which will introduces unnecessary overhead
  dbms_mview.refresh('OPI_PTP_RPT_BND_MV',
                 '?'
            );

END REFRESH_RPT_BND_MV;

PROCEDURE REFRESH_CBN_MV(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
BEGIN

  dbms_mview.refresh('OPI_PTP_CBN_MV',
                 '?',
                     parallelism => g_degree  -- PARALLELISM
            );

END REFRESH_CBN_MV;


PROCEDURE REFRESH_ITEM_F_MV(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
BEGIN

 dbms_mview.refresh('OPI_PTP_ITEM_F_MV',
            '?',
                    parallelism => g_degree  -- PARALLELISM
                );

END REFRESH_ITEM_F_MV;


PROCEDURE REFRESH_SUM_F_MV(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
BEGIN

 dbms_mview.refresh('OPI_PTP_SUM_F_MV',
                '?',
                    parallelism => g_degree  -- PARALLELISM
                );
END REFRESH_SUM_F_MV;

PROCEDURE REFRESH_SUM_STG_MV(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
BEGIN

 dbms_mview.refresh('OPI_PTP_SUM_STG_MV',
                '?',
                    parallelism => g_degree  -- PARALLELISM
                );
END REFRESH_SUM_STG_MV;

PROCEDURE REFRESH(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2)
IS
 l_stmt_num NUMBER;
 l_err_num NUMBER;
 l_err_msg VARCHAR2(255);
BEGIN

 l_stmt_num := 10;
 g_degree := bis_common_parameters.get_degree_of_parallelism;
 BIS_COLLECTION_UTILITIES.PUT_LINE('Starting Materialized Views Refresh for Production to Plan...');

 l_stmt_num := 20;
 REFRESH_CBN_MV(errbuf, retcode);
 BIS_COLLECTION_UTILITIES.PUT_LINE('Refresh OPI_PTP_CBN_MV finished ...');

 l_stmt_num := 30;
 REFRESH_ITEM_F_MV(errbuf, retcode);
 BIS_COLLECTION_UTILITIES.PUT_LINE('Refresh OPI_PTP_ITEM_F_MV finished ...');

 l_stmt_num := 40;
 REFRESH_SUM_F_MV(errbuf, retcode);
 BIS_COLLECTION_UTILITIES.PUT_LINE('Refresh OPI_PTP_SUM_F_MV finished ...');

 l_stmt_num := 50;
 REFRESH_SUM_STG_MV(errbuf, retcode);
 BIS_COLLECTION_UTILITIES.PUT_LINE('Refresh OPI_PTP_SUM_STG_MV finished ...');

 l_stmt_num := 60;
 REFRESH_RPT_BND_MV(errbuf, retcode);
 BIS_COLLECTION_UTILITIES.PUT_LINE('Refresh OPI_PTP_RPT_BND_MV finished ...');
 retcode := 0;

EXCEPTION
 WHEN OTHERS THEN
   retcode := SQLCODE;
   errbuf := SQLERRM;

   BIS_COLLECTION_UTILITIES.PUT_LINE('OPI_DBI_PTP_REFRESH_PKG.REFRESH - Error at statement ('
                    || to_char(l_stmt_num)
                    || ')');

   BIS_COLLECTION_UTILITIES.PUT_LINE('Error Number: ' ||  retcode);
   BIS_COLLECTION_UTILITIES.PUT_LINE('Error Message: ' || errbuf);
END REFRESH;

END OPI_DBI_PTP_BASELINE_PKG;

/
