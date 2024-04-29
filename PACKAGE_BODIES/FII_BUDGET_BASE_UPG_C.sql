--------------------------------------------------------
--  DDL for Package Body FII_BUDGET_BASE_UPG_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_BUDGET_BASE_UPG_C" AS
/*$Header: FIIBUDUPB.pls 120.1 2006/01/18 20:44:33 lpoon noship $*/

PROCEDURE UPDATE_TABLE(errbuf  IN OUT NOCOPY VARCHAR2,
                       retcode IN OUT NOCOPY VARCHAR2) IS

     l_debug_flag    VARCHAR2(1);
     l_phase         VARCHAR2(100);
     l_unassigned_id NUMBER;
     l_fii_schema    VARCHAR2(30);
     l_stmt	         VARCHAR2(300);

BEGIN
     l_phase := 'Cache the FII debug mode';
     l_debug_flag := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');

     -- 1. Find the unassigned ID used for UD1 and UD2
     l_phase := 'Find the unassigned ID used for UD1 and UD2';

     IF l_debug_flag = 'Y' THEN
       FII_UTIL.put_line(TO_CHAR(sysdate, 'DD-MON-YYYY HH24:MI:SS') || ' - '
                          || l_phase);
     END IF;

     SELECT flex_value_id
     INTO l_unassigned_id
     FROM FND_FLEX_VALUES
     WHERE flex_value_set_id =
           (SELECT flex_value_set_id
              FROM FND_FLEX_VALUE_SETS
             WHERE flex_value_set_name
			         = 'Financials Intelligence Internal Value Set')
     AND flex_value = 'UNASSIGNED';

     -- 2. Truncate FII_BUDGET_BASE_UPG_T
     l_phase := 'Find FII schema name';
     IF l_debug_flag = 'Y' THEN
       FII_UTIL.put_line(TO_CHAR(sysdate, 'DD-MON-YYYY HH24:MI:SS') || ' - '
                          || l_phase);
     END IF;

     l_fii_schema := FII_UTIL.get_schema_name('FII');

     l_phase := 'Truncate FII_BUDGET_BASE_UPG_T before inserting';
     IF l_debug_flag = 'Y' THEN
       FII_UTIL.put_line(TO_CHAR(sysdate, 'DD-MON-YYYY HH24:MI:SS') || ' - '
                          || l_phase);
     END IF;

     l_stmt := 'truncate table '||l_fii_schema||'.FII_BUDGET_BASE_UPG_T';
     EXECUTE IMMEDIATE l_stmt;

     -- 3. Insert data into FII_BUDGET_BASE_UPG_T from FII_BUDGET_BASE
     l_phase := 'Insert into FII_BUDGET_BASE_UPG_T';
     IF l_debug_flag = 'Y' THEN
       FII_UTIL.put_line(TO_CHAR(sysdate, 'DD-MON-YYYY HH24:MI:SS') || ' - '
                          || l_phase);
     END IF;

     INSERT /*+ append parallel(t) */
     INTO FII_BUDGET_BASE_UPG_T t
     (  plan_type_code, time_id, period_type_id, prim_amount_g, sec_amount_g
      , creation_date, created_by, last_update_date, last_updated_by
      , last_update_login, company_cost_center_org_id, line_of_business
      , natural_account, fin_item, product_code, category_id, fin_category_id
      , ledger_id, company_id, cost_center_id, user_dim1_id, user_dim2_id
      , prim_amount_total, sec_amount_total, version_date, upload_date
      , no_version_flag, posted_date, baseline_amount_prim)
      SELECT /*+ parallel(b) use_hash(v) */
	         b.plan_type_code
           , b.time_id
           , b.period_type_id
           , b.prim_amount_g
           , b.sec_amount_g
           , b.creation_date
           , b.created_by
           , b.last_update_date
           , b.last_updated_by
           , b.last_update_login
           , b.company_cost_center_org_id
           , b.line_of_business
           , b.natural_account
           , b.fin_item
           , b.product_code
           , b.category_id
           , b.fin_category_id
           , nvl(b.ledger_id, -1) ledger_id
           , nvl(b.company_id, v.company_id) company_id
           , nvl(b.cost_center_id, v.cost_center_id) cost_center_id
           , nvl(b.user_dim1_id, l_unassigned_id) user_dim1_id
           , nvl(b.user_dim2_id, l_unassigned_id) user_dim2_id
           , b.prim_amount_total
           , b.sec_amount_total
           , b.version_date
           , b.upload_date
           , b.no_version_flag
           , b.posted_date
           , b.baseline_amount_prim
        FROM FII_BUDGET_BASE b
           , (SELECT /*+ no_merge */
		             ccc_tbl.organization_id
                   , fv1.flex_value_id company_id
                   , fv2.flex_value_id cost_center_id
                FROM HR_ORGANIZATION_INFORMATION ccc_tbl
                   , HR_ORGANIZATION_INFORMATION org
                   , FND_FLEX_VALUES fv1
                   , FND_FLEX_VALUES fv2
               WHERE ccc_tbl.org_information_context = 'CLASS'
                 AND ccc_tbl.org_information1 = 'CC'
                 AND ccc_tbl.org_information2 = 'Y'
                 AND org.org_information_context = 'Company Cost Center'
                 AND org.organization_id = ccc_tbl.organization_id
                 AND fv1.flex_value_set_id = org.org_information2
                 AND fv1.flex_value = org.org_information3
                 AND fv2.flex_value_set_id = org.org_information4
                 AND fv2.flex_value = org.org_information5) v
       WHERE b.company_cost_center_org_id = v.organization_id (+);

     -- 4. Truncate FII_BUDGET_BASE
     l_phase := 'Truncate FII_BUDGET_BASE';
     IF l_debug_flag = 'Y' THEN
       FII_UTIL.put_line(TO_CHAR(sysdate, 'DD-MON-YYYY HH24:MI:SS') || ' - '
                          || 'Inserted ' || SQL%ROWCOUNT
                          || ' rows into FII_BUDGET_BASE_UPG_T');
       FII_UTIL.put_line(TO_CHAR(sysdate, 'DD-MON-YYYY HH24:MI:SS') || ' - '
                          || l_phase);
     END IF;

     l_stmt := 'truncate table '||l_fii_schema||'.FII_BUDGET_BASE';
     EXECUTE IMMEDIATE l_stmt;

     -- 5. Re-insert data into FII_BUDGET_BASE from FII_BUDGET_BASE_UPG_T
     l_phase := 'Insert into FII_BUDGET_BASE';
     IF l_debug_flag = 'Y' THEN
       FII_UTIL.put_line(TO_CHAR(sysdate, 'DD-MON-YYYY HH24:MI:SS') || ' - '
                          || l_phase);
     END IF;

     INSERT /*+ append parallel(b) */
     INTO FII_BUDGET_BASE b
     (  plan_type_code, time_id, period_type_id, prim_amount_g, sec_amount_g
      , creation_date, created_by, last_update_date, last_updated_by
      , last_update_login, company_cost_center_org_id, line_of_business
      , natural_account, fin_item, product_code, category_id, fin_category_id
      , ledger_id, company_id, cost_center_id, user_dim1_id, user_dim2_id
      , prim_amount_total, sec_amount_total, version_date, upload_date
      , no_version_flag, posted_date, baseline_amount_prim)
      SELECT /*+ parallel(t) */
	         t.plan_type_code
           , t.time_id
           , t.period_type_id
           , t.prim_amount_g
           , t.sec_amount_g
           , t.creation_date
           , t.created_by
           , t.last_update_date
           , t.last_updated_by
           , t.last_update_login
           , t.company_cost_center_org_id
           , t.line_of_business
           , t.natural_account
           , t.fin_item
           , t.product_code
           , t.category_id
           , t.fin_category_id
           , t.ledger_id
           , t.company_id
           , t.cost_center_id
           , t.user_dim1_id
           , t.user_dim2_id
           , t.prim_amount_total
           , t.sec_amount_total
           , t.version_date
           , t.upload_date
           , t.no_version_flag
           , t.posted_date
           , t.baseline_amount_prim
        FROM FII_BUDGET_BASE_UPG_T t;

     -- 6. Truncate MLOG$_FII_BUDGET_BASE
     l_phase := 'Truncate MLOG$_FII_BUDGET_BASE';
     IF l_debug_flag = 'Y' THEN
       FII_UTIL.put_line(TO_CHAR(sysdate, 'DD-MON-YYYY HH24:MI:SS') || ' - '
                          || 'Inserted ' || SQL%ROWCOUNT
                          || ' rows into FII_BUDGET_BASE');
       FII_UTIL.put_line(TO_CHAR(sysdate, 'DD-MON-YYYY HH24:MI:SS') || ' - '
                          || l_phase);
     END IF;

     l_stmt:='truncate table '||l_fii_schema||'.'|| 'MLOG$_FII_BUDGET_BASE';
     EXECUTE IMMEDIATE l_stmt;

     -- 7. Truncate FII_BUDGET_BASE_UPG_T
     l_phase := 'Truncate FII_BUDGET_BASE_UPG_T before exit';
     IF l_debug_flag = 'Y' THEN
       FII_UTIL.put_line(TO_CHAR(sysdate, 'DD-MON-YYYY HH24:MI:SS') || ' - '
                          || l_phase);
     END IF;

     l_stmt := 'truncate table '||l_fii_schema||'.FII_BUDGET_BASE_UPG_T';
     EXECUTE IMMEDIATE l_stmt;

EXCEPTION
  WHEN OTHERS THEN
    errbuf := sqlerrm;
    retcode := sqlcode;
    FII_UTIL.put_line('
---------------------------------
Error in Procedure: UPDATE_TABLE
Phase: '||l_phase||'
Message: '||errbuf);
    raise;

END UPDATE_TABLE;

END FII_BUDGET_BASE_UPG_C;

/
