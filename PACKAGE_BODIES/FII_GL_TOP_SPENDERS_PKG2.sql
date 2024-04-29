--------------------------------------------------------
--  DDL for Package Body FII_GL_TOP_SPENDERS_PKG2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_GL_TOP_SPENDERS_PKG2" AS
/* $Header: FIIGLC4B.pls 120.4 2006/05/05 10:39:21 hpoddar noship $ */

PROCEDURE get_top_spenders (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
top_spenders_sql out NOCOPY VARCHAR2, top_spenders_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_global_curr_view            VARCHAR2(1);
  sqlstmt			VARCHAR2(15000);
  l_exists			NUMBER := 0;
  l_exists2			NUMBER := 0;
  l_url				VARCHAR2(200) := NULL;
  l_stmt 			VARCHAR2(200) ;

BEGIN

fii_gl_util_pkg.reset_globals;
fii_gl_util_pkg.get_parameters(p_page_parameter_tbl);

l_global_curr_view := fii_gl_util_pkg.g_global_curr_view;

/* Hardcoded 'sys' schema name to use sys.all_tables (instead of all_tables) in order to make the code gscc compliant */

   BEGIN

	SELECT	1 INTO l_exists
	FROM	dba_tables
	WHERE	table_name = 'PER_EMPDIR_PEOPLE'
		AND owner = fii_util.get_schema_name('PER');

   EXCEPTION
       WHEN NO_DATA_FOUND THEN
            l_exists := 0;
   END;

   IF l_exists > 0 THEN
	l_stmt := 'SELECT count(*) FROM per_empdir_people WHERE orig_system = ''PER'' AND rownum <= 1';
	EXECUTE IMMEDIATE(l_stmt) INTO l_exists2;
  END IF;

    IF fii_gl_util_pkg.g_mgr_id = -99999 THEN

    sqlstmt := '
		SELECT NULL	FII_MEASURE1,
		       NULL	FII_MEASURE2,
		       NULL	FII_MEASURE3,
		       NULL	FII_MEASURE4,
		       NULL	FII_MEASURE7,
		       NULL	FII_MEASURE5,
		       NULL	FII_MEASURE8,
		       NULL	FII_MEASURE9
		FROM   DUAL
		WHERE  1=2';

   ELSE

   sqlstmt := '
		SELECT ppl1.value FII_MEASURE1,
		       ppl2.value FII_MEASURE2,
		       p.FII_MEASURE3 FII_MEASURE3,
		       p.FII_MEASURE4 FII_MEASURE4,
		       p.FII_MEASURE7 FII_MEASURE7,
		       p.RANK_WITHIN_MANAGER_PTD FII_MEASURE5,
		       p.person_id     FII_MEASURE8,
		       DECODE('||l_exists2||', 1, ''pFunctionName=HR_EMPDIR_EMPDTL_PROXY_SS&pId=FII_MEASURE8&OAPB=FII_HR_BRAND_TEXT'', '''') FII_MEASURE9
		FROM   hri_dbi_cl_per_n_v 	ppl1,
		       hri_dbi_cl_per_n_v ppl2,

		(SELECT
                        b.PERSON_ID     PERSON_ID,
                        h.SUP_PERSON_ID DIRECT_MGR_ID,
                        MAX(amount_g)      FII_MEASURE3,
                        MAX(NO_EXP_REPORTS_PTD)    FII_MEASURE4,
                        b.manager_id    FII_MEASURE7,
                        RANK() OVER (PARTITION BY b.MANAGER_ID  ORDER BY MAX(amount_g) DESC) AS RANK_WITHIN_MANAGER_ptd
                   FROM fii_top_spenders_v'||l_global_curr_view||'  b,
                        hri_cs_suph	h
                   WHERE b.PERIOD_ID BETWEEN :START_ID AND :END_ID
                        AND b.MANAGER_ID = &HRI_PERSON+HRI_PER_USRDR_H
                        AND b.slice_type_flag = :SLICE_TYPE_FLAG
                        AND h.sub_person_id (+)= b.person_id
			AND h.sub_relative_level = 1
			AND sysdate BETWEEN h.effective_start_date AND h.effective_end_date
                   GROUP BY person_id, manager_id, h.SUP_PERSON_ID) p

		WHERE sysdate BETWEEN ppl1.effective_start_date (+) AND ppl1.effective_end_date (+)
		      AND sysdate BETWEEN ppl2.effective_start_date (+) AND ppl2.effective_end_date (+)
		      AND p.person_id = ppl1.id (+)
		      AND p.direct_mgr_id = ppl2.id (+)
		      AND p.rank_within_manager_ptd <= 10
		ORDER BY p.FII_MEASURE3 desc';

	END IF;

	fii_gl_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, top_spenders_sql, top_spenders_output);

END get_top_spenders;


PROCEDURE get_top_spenders_drilldown
(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,top_spenders_drilldown_sql out NOCOPY VARCHAR2,
top_spenders_drilldown_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

i			NUMBER;
sqlstmt			VARCHAR2(15000);
l_currency		VARCHAR2(50);
l_currency_type		VARCHAR2(20);


BEGIN

fii_gl_util_pkg.reset_globals;
fii_gl_util_pkg.get_parameters(p_page_parameter_tbl);
fii_gl_util_pkg.get_bitmasks;
l_currency := fii_gl_util_pkg.g_currency;


 IF (p_page_parameter_tbl.count > 0) THEN
     FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP
       IF p_page_parameter_tbl(i).parameter_name = 'FII_MEASURE8' THEN
          fii_gl_util_pkg.g_prev_mgr_id := p_page_parameter_tbl(i).parameter_value;
       END IF;
       IF p_page_parameter_tbl(i).parameter_name = 'FII_MEASURE9' THEN
          fii_gl_util_pkg.g_emp_id := p_page_parameter_tbl(i).parameter_value;
       END IF;
     END LOOP;
  END IF;


  IF l_currency = 'FII_GLOBAL1' THEN
    	l_currency_type := 'prim_amount_g';
      ELSIF l_currency = 'FII_GLOBAL2' THEN
      	l_currency_type := 'sec_amount_g';
      ELSE l_currency_type := 'prim_amount_g';
  END IF;

sqlstmt := 'SELECT
		   x.invoice_num	FII_MEASURE10,
                   headers.report_header_id FII_MEASURE1,
                   x.inv_currency_code FII_MEASURE2,
		   headers.total FII_MEASURE3,
		   SUM(x.amount_g) FII_MEASURE4,
		   tl.name	 FII_MEASURE5,
                   x.account_date FII_MEASURE6,
		   headers.description FII_MEASURE7,
		   SUM(SUM(x.amount_g)) OVER()  FII_ATTRIBUTE1
FROM ap_expense_report_headers_all headers,
     hr_all_organization_units_tl  tl,
	(
	SELECT ap.invoice_num invoice_num,
        	cc.ccc_org_id cost_center,
        	ap.inv_currency_code inv_currency_code,
        	ap.account_date account_date,
        	SUM(ap.'||l_currency_type||') amount_g,
		ap.employee_id employee_id

	FROM fii_ap_inv_b ap,
		fii_org_mgr_mappings cc,
		fii_com_cc_mappings m
	WHERE ap.company_id = m.company_id
		AND ap.cost_center_id = m.cost_center_id
		AND cc.ccc_org_id = m.company_cost_center_org_id
		AND cc.manager_id = :PREV_MGR_ID
		AND   ap.employee_id = :EMP_ID
		AND   ap.account_date BETWEEN to_date(:P_TOP_SPEND_START, ''DD-MM-YYYY'') AND to_date(:P_TOP_SPEND_END, ''DD-MM-YYYY'')
                AND ap.discretionary_expense_flag = ''Y''
	GROUP BY ap.invoice_num, cc.ccc_org_id, ap.account_date, ap.inv_currency_code, ap.employee_id
	) x
    WHERE 	headers.invoice_num = x.invoice_num
    AND NVL(headers.employee_id, x.employee_id) = x.employee_id
	AND tl.organization_id = x.cost_center
	AND tl.language = userenv(''LANG'')
	GROUP BY x.invoice_num, headers.report_header_id, tl.name, headers.description, x.inv_currency_code, x.account_date, headers.total
	&ORDER_BY_CLAUSE';

	fii_gl_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, top_spenders_drilldown_sql, top_spenders_drilldown_output);

END get_top_spenders_drilldown;

END fii_gl_top_spenders_pkg2;


/
