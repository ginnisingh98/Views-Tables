--------------------------------------------------------
--  DDL for Package Body FII_GL_TOP_SPENDERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_GL_TOP_SPENDERS_PKG" AS
/* $Header: FIIGLTSB.pls 120.3 2006/05/05 10:08:56 hpoddar noship $ */

g_debug_flag 	VARCHAR2(1) := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');
g_retcode	VARCHAR2(20) := NULL;
g_phase         VARCHAR2(100);
g_fii_schema	VARCHAR2(30);
g_fii_user_id   NUMBER(15);
g_fii_login_id  NUMBER(15);

PROCEDURE INIT IS

l_status		VARCHAR2(30);
l_industry		VARCHAR2(30);
l_ap_row_cnt    NUMBER;

BEGIN

     ----------------------------------------------------------
     -- Determine whether ap base summary (FII_AP_INV_B) is populated
     ----------------------------------------------------------
    g_phase := 'Determine whether ap base summary is populated ';
    SELECT 1 INTO l_ap_row_cnt
    FROM FII_AP_INV_B
    WHERE rownum = 1;

     ----------------------------------------------------------
     -- Find the schema owner of FII
     ----------------------------------------------------------

     g_phase := 'Find FII schema';
     IF(FND_INSTALLATION.GET_APP_INFO('FII', l_status, l_industry,
          g_fii_schema))THEN
	NULL;
     END IF;

     ----------------------------------------------------------
     -- Find user id and user login
     ----------------------------------------------------------

     g_phase := 'Find User ID and User Login';

     g_fii_user_id := FND_GLOBAL.User_Id;
     g_fii_login_id := FND_GLOBAL.Login_Id;

    ----------------------------------------------------------
     -- Truncate staging and base tables
    ----------------------------------------------------------
      g_phase := 'Truncate table FII_TOP_SPENDERS_STG';
      FII_UTIL.truncate_table ('FII_TOP_SPENDERS_STG', 'FII', g_retcode);

      g_phase := 'Truncate table FII_TOP_SPNDR_SUM_B';
      FII_UTIL.truncate_table ('FII_TOP_SPNDR_SUM_B', 'FII', g_retcode);

Exception

  WHEN NO_DATA_FOUND THEN
         FII_UTIL.Write_Log ( 'Phase: ' || g_phase);
         FII_MESSAGE.write_log(msg_name   => 'FII_GL_AP_BASE_EMPTY',
                               token_num  => 0);
         g_retcode := 1;
	 RAISE;

    WHEN OTHERS THEN
         g_retcode := -1;

    	FII_UTIL.write_log('
		---------------------------------
		Error in Procedure: INIT
    Phase: '||g_phase||'
	Message: '||sqlerrm);

    RAISE;

END INIT;


PROCEDURE POPULATE_STG_MONTHS IS

BEGIN

if g_debug_flag = 'Y' then
   fii_util.write_log('Populating month slices in fii_top_spenders_stg table');
end if;

g_phase := 'Insert month slices into fii_top_spenders_stg table';

INSERT /*+ append parallel(stg) */ INTO FII_TOP_SPENDERS_STG (
	period_id,
	slice_type_flag,
	qtr_id,
	year_id,
	person_id,
	ccc_org_id,
	prim_amount_g,
	sec_amount_g,
	no_of_exp_rpts,
	last_update_date,
	last_updated_by,
	creation_date,
	created_by,
	last_update_login)
SELECT /*+ ordered use_hash(b,m) parallel(b) parallel(m) */
	t.ENT_PERIOD_ID,
	'M',
	t.ENT_QTR_ID,
	t.ENT_YEAR_ID,
	b.employee_id,
	m.COMPANY_COST_CENTER_ORG_ID,
	sum(b.PRIM_AMOUNT_G),
	sum(b.SEC_AMOUNT_G) ,
	count(distinct b.INVOICE_ID),
	sysdate,
	g_fii_user_id,
	sysdate,
    g_fii_user_id,
    g_fii_login_id
FROM fii_time_day t, FII_AP_INV_B b,  FII_COM_CC_MAPPINGS m
WHERE b.discretionary_expense_flag = 'Y'
      and b.account_Date = t.report_date
      and b.COMPANY_ID = m.COMPANY_ID
      and b.COST_CENTER_ID = m.COST_CENTER_ID
GROUP BY m.COMPANY_COST_CENTER_ORG_ID, b.employee_id, t.ENT_YEAR_ID,  t.ENT_QTR_ID, t.ENT_PERIOD_ID;

if g_debug_flag = 'Y' then
   fii_util.write_log('Inserted '||SQL%ROWCOUNT||' rows into FII_TOP_SPENDERS_STG');
end if;

commit;

EXCEPTION
	WHEN OTHERS THEN
		g_retcode := -1;

	    		FII_UTIL.write_log('
				----------------------------
				Error in Function: POPULATE_STG_MONTHS
                Phase: '||g_phase||'
				Message: '||sqlerrm);

		RAISE;

END POPULATE_STG_MONTHS;

PROCEDURE POPULATE_STG_QUARTERS IS

BEGIN

if g_debug_flag = 'Y' then
   fii_util.write_log('Populating quarter slices in fii_top_spenders_stg table');
end if;

g_phase := 'Insert quarter slices into fii_top_spenders_stg table';

INSERT /*+ append parallel(stg) */ INTO FII_TOP_SPENDERS_STG (
	period_id,
	slice_type_flag,
	qtr_id,
	year_id,
	person_id,
	ccc_org_id,
	prim_amount_g,
	sec_amount_g,
	no_of_exp_rpts,
	last_update_date,
	last_updated_by,
	creation_date,
	created_by,
	last_update_login)

SELECT /*+ parallel(t) */
	t.PERIOD_ID,
	'Q',
	t.QTR_ID,
	t.YEAR_ID,
	t.person_id,
	t.CCC_ORG_ID,
	SUM(t.PRIM_AMOUNT_G) OVER (PARTITION BY t.QTR_ID, t.YEAR_ID, t.CCC_ORG_ID, t.person_id  ORDER BY t.period_id ROWS UNBOUNDED PRECEDING) AS PRIM_AMOUNT_G,
	SUM(t.SEC_AMOUNT_G) OVER (PARTITION BY t.QTR_ID, t.YEAR_ID, t.CCC_ORG_ID, t.person_id  ORDER BY t.period_id ROWS UNBOUNDED PRECEDING) AS SEC_AMOUNT_G,
	SUM(t.no_of_exp_rpts) OVER (PARTITION BY t.QTR_ID, t.YEAR_ID, t.CCC_ORG_ID, t.person_id  ORDER BY t.period_id ROWS UNBOUNDED PRECEDING) AS no_of_exp_rpts,
	sysdate,
	g_fii_user_id,
	sysdate,
        g_fii_user_id,
        g_fii_login_id
FROM fii_top_spenders_stg t;

if g_debug_flag = 'Y' then
   fii_util.write_log('Inserted '||SQL%ROWCOUNT||' rows into FII_TOP_SPENDERS_STG');
end if;

commit;

EXCEPTION
	WHEN OTHERS THEN
		g_retcode := -1;

	    		FII_UTIL.write_log('
				----------------------------
				Error in Function: POPULATE_STG_QUARTERS
                Phase: '||g_phase||'
				Message: '||sqlerrm);

    		RAISE;

END POPULATE_STG_QUARTERS;


PROCEDURE POPULATE_STG_YEARS IS

BEGIN

if g_debug_flag = 'Y' then
   fii_util.write_log('Populating year slices in fii_top_spenders_stg table');
end if;

g_phase := 'Insert year slices into fii_top_spenders_stg table';

INSERT /*+ append parallel(stg) */  INTO FII_TOP_SPENDERS_STG (
	period_id,
	slice_type_flag,
	qtr_id,
	year_id,
	person_id,
	ccc_org_id,
	prim_amount_g,
	sec_amount_g,
	no_of_exp_rpts,
	last_update_date,
	last_updated_by,
	creation_date,
	created_by,
	last_update_login)
SELECT /*+ append parallel(b) */
	b.PERIOD_ID,
	'Y',
	b.QTR_ID,
	b.YEAR_ID,
	b.person_id,
	b.CCC_ORG_ID,
	SUM(B.PRIM_AMOUNT_G) OVER (PARTITION BY B.YEAR_ID, b.CCC_ORG_ID, b.person_id  ORDER BY b.period_id ROWS UNBOUNDED PRECEDING) AS PRIM_AMOUNT_G,
	SUM(B.SEC_AMOUNT_G) OVER (PARTITION BY B.YEAR_ID, b.CCC_ORG_ID, b.person_id  ORDER BY b.period_id ROWS UNBOUNDED PRECEDING) AS SEC_AMOUNT_G,
	SUM(B.no_of_exp_rpts) OVER (PARTITION BY B.YEAR_ID, b.CCC_ORG_ID, b.person_id  ORDER BY b.period_id ROWS UNBOUNDED PRECEDING) AS no_of_exp_rpts,
	sysdate,
	g_fii_user_id,
	sysdate,
        g_fii_user_id,
        g_fii_login_id
FROM fii_top_spenders_stg b
WHERE b.slice_type_flag = 'M';

if g_debug_flag = 'Y' then
   fii_util.write_log('Inserted '||SQL%ROWCOUNT||' rows into FII_TOP_SPENDERS_STG');
end if;

commit;

EXCEPTION
	WHEN OTHERS THEN
		g_retcode := -1;

	    		FII_UTIL.write_log('
				----------------------------
				Error in Function: POPULATE_STG_YEARS
                Phase: '||g_phase||'
				Message: '||sqlerrm);

    		RAISE;

END POPULATE_STG_YEARS;

PROCEDURE POPULATE_SUMMARY IS

BEGIN

if g_debug_flag = 'Y' then
   fii_util.write_log('Populating fii_top_spndr_sum_b table');
end if;

g_phase := 'Insert rows into fii_top_spndr_sum_b table';

INSERT /*+ append parallel(b) */ INTO   fii_top_spndr_sum_b (
	person_id,
	period_id,
	slice_type_flag,
	manager_id,
	rank_within_manager_ptd,
	prim_ptd_g,
	sec_ptd_g,
	no_exp_reports_ptd,
	last_update_date,
	last_updated_by,
	creation_date,
	created_by,
	last_update_login)
SELECT
	person_id,
	period_id,
	slice_type_flag,
	manager_id,
	RANK_WITHIN_MANAGER_ptd,
	prim_ptd_g,
	sec_ptd_g,
	no_of_exp_rpts_ptd,
	sysdate,
	g_fii_user_id,
	sysdate,
        g_fii_user_id,
        g_fii_login_id
FROM (SELECT /*+ ordered use_hash(stg) parallel(stg) */
         stg.person_id person_id,
	     stg.period_id period_id,
	     stg.slice_type_flag,
	     help.manager_id manager_id,
	     RANK() OVER (PARTITION BY stg.period_id, stg.slice_type_flag, help.manager_id
	     ORDER BY sum(stg.prim_amount_g) DESC) AS RANK_WITHIN_MANAGER_ptd ,
	     sum(stg.prim_amount_g) prim_ptd_g,
	     sum(stg.sec_amount_g) sec_ptd_g,
	     sum(stg.no_of_exp_rpts) no_of_exp_rpts_ptd
	FROM  fii_org_mgr_mappings help, fii_top_spenders_stg stg
	WHERE help.ccc_org_id = stg.ccc_org_id
	GROUP BY stg.person_id ,
		 stg.period_id ,
		 stg.slice_type_flag,
		 help.manager_id ) x
WHERE x.RANK_WITHIN_MANAGER_ptd <= 10;

if g_debug_flag = 'Y' then
   fii_util.write_log('Inserted '||SQL%ROWCOUNT||' rows into FII_TOP_SPNDR_SUM_B');
end if;

FND_STATS.gather_table_stats
               (ownname => g_fii_schema,
                tabname => 'FII_TOP_SPNDR_SUM_B');
commit;

EXCEPTION
	WHEN OTHERS THEN
		g_retcode := -1;

	    		FII_UTIL.write_log('
				----------------------------
				Error in Function: POPULATE_SUMMARY
                Phase: '||g_phase||'
				Message: '||sqlerrm);

    		RAISE;

END POPULATE_SUMMARY;

----------------------------------
-- Public Functions and Procedures
----------------------------------

PROCEDURE Main ( ERRBUF		IN OUT 	NOCOPY VARCHAR2,
		 RETCODE	IN OUT 	NOCOPY VARCHAR2) IS
         l_dir                VARCHAR2(400);
BEGIN
        l_dir:=FII_UTIL.get_utl_file_dir;
        FII_UTIL.initialize('fii_gl_top_spenders_pkg.log','fii_gl_top_spenders_pkg.out',l_dir, 'fii_gl_top_spenders_pkg');

	INIT;
	POPULATE_STG_MONTHS;
	POPULATE_STG_QUARTERS;
	POPULATE_STG_YEARS;
	POPULATE_SUMMARY;

     -- Exception handling
EXCEPTION
     WHEN NO_DATA_FOUND THEN
        RETCODE  := g_retcode;
     WHEN OTHERS THEN
        RETCODE  := g_retcode;

END MAIN;

END fii_gl_top_spenders_pkg;

/
