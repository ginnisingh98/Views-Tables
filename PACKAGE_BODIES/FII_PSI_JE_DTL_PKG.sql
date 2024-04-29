--------------------------------------------------------
--  DDL for Package Body FII_PSI_JE_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_PSI_JE_DTL_PKG" AS
/* $Header: FIIPSIJEDTLB.pls 120.9 2006/08/22 07:35:00 wywong noship $ */


g_carryfwd_msg VARCHAR2(240) := fnd_message.get_string('FII','FII_PSI_CARRYFWD');

PROCEDURE GET_ENCUM_JRNL (
        p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
        jrnl_dtl_sql             OUT NOCOPY VARCHAR2,
        jrnl_dtl_output          OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
        sqlstmt                 VARCHAR2(14000);
	l_company_where		VARCHAR2(1000); -- To store company id dynamic where clause
	l_cost_center_where	VARCHAR2(1000); -- To store cost center dynamic where clause
	l_fud1_where		VARCHAR2(1000); -- To store user dim 1 dynamic where clause
	l_fud2_where		VARCHAR2(1000); -- To store user dim 2 dynamic where clause
	l_category_where	VARCHAR2(1000); -- To store category dynamic where clause
	l_enc_category_where	VARCHAR2(1000); -- To store category dynamic where clause


BEGIN

FII_EA_UTIL_PKG.reset_globals;
FII_EA_UTIL_PKG.get_parameters(p_page_parameter_tbl=>p_page_parameter_tbl);

/* Preparing Dynamic where clauses for PMV sql */

l_category_where 	:= ' AND f.natural_account_id = &FINANCIAL ITEM+GL_FII_FIN_ITEM ';
l_enc_category_where 	:= ' AND f.fin_category_id = &FINANCIAL ITEM+GL_FII_FIN_ITEM ';
l_company_where 	:= ' f.company_id = &FII_COMPANIES+FII_COMPANIES ';
l_cost_center_where 	:= ' AND f.cost_center_id = &ORGANIZATION+HRI_CL_ORGCC ';

l_fud1_where := REPLACE(fii_ea_util_pkg.get_fud1_for_detail, 'fud1_id', 'user_dim1_id');
l_fud2_where := REPLACE(fii_ea_util_pkg.get_fud2_for_detail, 'fud2_id', 'user_dim2_id');

SELECT	report_date_julian INTO fii_ea_util_pkg.g_curr_per_start_id
FROM fii_time_day
WHERE	report_date = fii_ea_util_pkg.g_curr_per_start;

SELECT	report_date_julian INTO fii_ea_util_pkg.g_as_of_date_id
FROM fii_time_day
WHERE	report_date = fii_ea_util_pkg.g_as_of_date;

/* For a Purchase Order, gl_je_lines.reference_2 and gl_je_lines.reference_4 store po_header_id and po_number respectively.
We join between gl_je_lines and po_distributions_all on po_header_id to fetch po_release_id (to be passed in PO drill).
While joining, we are using outer join since all encumbrance entries may not come through PO. */

/* Bug 4586540. Since jln.reference_2 can also have alphanumeric values, using TO_NUMBER directly was leading to
'invalid number' error due to failure of TO_NUMBER function to convert alphanumeric values to numbers. So perf
team suggested to use TRANSLATE and TO_NUMBER functions together. */

/* PMV SQL */

sqlstmt :=
' SELECT
	inline_view.FII_PSI_JOURNAL_NAME 	FII_PSI_JOURNAL_NAME,
	inline_view.FII_PSI_CURRENCY 		FII_PSI_CURRENCY,
	inline_view.FII_PSI_ENTERED_AMOUNT 	FII_PSI_ENTERED_AMOUNT,
	inline_view.FII_PSI_NET_AMOUNT 		FII_PSI_NET_AMOUNT,
	inline_view.FII_PSI_JOURNAL_DATE 	FII_PSI_JOURNAL_DATE,
	inline_view.FII_PSI_DOC_NUMBER 		FII_PSI_DOC_NUMBER,
	inline_view.FII_PSI_CATEGORY 		FII_PSI_CATEGORY,
	inline_view.FII_PSI_DESCRIPTION 	FII_PSI_DESCRIPTION,
	inline_view.FII_PSI_SOURCE 		FII_PSI_SOURCE,
	inline_view.FII_PSI_GT_NET_AMOUNT 	FII_PSI_GT_NET_AMOUNT,
	DECODE(inline_view.FII_PSI_CATEGORY, ''Purchases'', DECODE(inline_view.FII_PSI_DOC_NUMBER,NULL,'''',
		''pFunctionName=FII_EA_POA_DRILL&PoHeaderId='' || PO_HEADER_ID ||
                     ''&PoReleaseId='' || PO_RELEASE_ID || ''&addBreadCrumb=Y&retainAM=Y''))	FII_PSI_DOC_NUMBER_DRILL
FROM
(SELECT
 	f.name 				FII_PSI_JOURNAL_NAME,
     	f.currency_code 		FII_PSI_CURRENCY,
	SUM(NVL(jln.entered_cr, 0) -  NVL(jln.entered_dr, 0))*-1 FII_PSI_ENTERED_AMOUNT,
	SUM(NVL(jln.accounted_cr, 0) -  NVL(jln.accounted_dr, 0))*-1 FII_PSI_NET_AMOUNT,
     	jln.effective_date		FII_PSI_JOURNAL_DATE,
	jln.reference_4			FII_PSI_DOC_NUMBER,
     	f.je_category 			FII_PSI_CATEGORY,
     	f.description 			FII_PSI_DESCRIPTION,
     	jes.user_je_source_name	 	FII_PSI_SOURCE,
	DECODE(LENGTH(TRANSLATE(jln.reference_2,''0''||TRANSLATE(jln.reference_2,''a0123456789'',''a''),''0''))
               -LENGTH(jln.reference_2),
               0, TO_NUMBER(jln.reference_2),
               NULL) PO_HEADER_ID,
        NULL                            PO_RELEASE_ID,
	(SUM(SUM(NVL(jln.accounted_cr, 0) -NVL(jln.accounted_dr,0))) OVER()) *-1 FII_PSI_GT_NET_AMOUNT
 FROM 	gl_je_headers f,
     	gl_je_lines jln,
	fii_gl_processed_header_ids fgl,
	gl_je_sources_tl jes
WHERE  	f.je_header_id = fgl.je_header_id
	AND	f.je_header_id = jln.je_header_id
	AND     f.je_source = jes.je_source_name
	AND  	f.actual_flag = ''E''
	AND 	jes.language =   userenv(''LANG'')
	AND	jln.effective_date BETWEEN :CURR_PERIOD_START AND :ASOF_DATE
	AND	jln.code_combination_id IN (	SELECT	f.code_combination_id
						FROM	fii_gl_ccid_dimensions f
			 			WHERE	'||l_company_where||'
							'||l_cost_center_where||'
							'||l_category_where||'
							'||l_fud1_where||'
							'||l_fud2_where||'
					    )
GROUP BY	f.je_header_id, f.name, jln.effective_date, jln.reference_4, f.currency_code,
		f.je_category, f.description, jes.user_je_source_name, jln.reference_2

UNION ALL

SELECT		'''||g_carryfwd_msg||''' 				FII_PSI_JOURNAL_NAME,
		functional_currency 		FII_PSI_CURRENCY,
		SUM(NVL(obligated_amount_prim, 0) +  NVL(committed_amount_prim, 0)+ NVL(other_amount_prim, 0))*-1 FII_PSI_ENTERED_AMOUNT,
		SUM(NVL(obligated_amount_prim, 0) +  NVL(committed_amount_prim, 0)+ NVL(other_amount_prim, 0))*-1 FII_PSI_NET_AMOUNT,
		posted_date		FII_PSI_JOURNAL_DATE,
		NULL FII_PSI_DOC_NUMBER,
		NULL 			FII_PSI_CATEGORY,
		'''||g_carryfwd_msg||''' 			FII_PSI_DESCRIPTION,
		NULL	 	FII_PSI_SOURCE,
		NULL		PO_HEADER_ID,
		NULL		PO_RELEASE_ID,
		(SUM(SUM(NVL(obligated_amount_prim, 0) +  NVL(committed_amount_prim, 0)+ NVL(other_amount_prim, 0))) OVER())*-1 FII_PSI_GT_NET_AMOUNT

FROM 		fii_gl_enc_carryfwd_f f

WHERE		'||l_company_where||l_cost_center_where||l_enc_category_where||l_fud1_where||l_fud2_where||'
		AND f.time_id between :CURR_PERIOD_START_ID AND :ASOF_DATE_ID
GROUP BY	functional_currency,posted_date ) inline_view

ORDER BY	FII_PSI_JOURNAL_DATE DESC';


-- Attach bind parameters

FII_EA_UTIL_PKG.bind_variable(
        p_sqlstmt=>sqlstmt,
        p_page_parameter_tbl=>p_page_parameter_tbl,
        p_sql_output=>jrnl_dtl_sql,
        p_bind_output_table=>jrnl_dtl_output);

END GET_ENCUM_JRNL;

--***********************************--

/* Code for Budget Journal Entry Details Report */

PROCEDURE GET_BUDGET_JRNL (
        p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
        jrnl_dtl_sql             OUT NOCOPY VARCHAR2,
        jrnl_dtl_output          OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
        l_prim_global_curr        VARCHAR2(20);
        l_sec_global_curr         VARCHAR2(20);
        sqlstmt                 VARCHAR2(14000);
	l_ledger_where		VARCHAR2(1000);
	l_company_where		VARCHAR2(1000); -- To store company id dynamic where clause
	l_cost_center_where	VARCHAR2(1000); -- To store cost center dynamic where clause
	l_fud1_where		VARCHAR2(1000); -- To store user dim 1 dynamic where clause
	l_fud2_where		VARCHAR2(1000); -- To store user dim 2 dynamic where clause
	l_category_where	VARCHAR2(1000); -- To store category dynamic where clause

        l_industry_profile      VARCHAR2(1);
        l_budget_source         VARCHAR2(15);
        l_currency_where        VARCHAR2(1000) := NULL;

BEGIN

FII_EA_UTIL_PKG.reset_globals;
FII_EA_UTIL_PKG.get_parameters(p_page_parameter_tbl=>p_page_parameter_tbl);

/* Preparing Dynamic where clauses for PMV sql */

l_category_where 	:= ' AND f.natural_account_id = &FINANCIAL ITEM+GL_FII_FIN_ITEM ';
l_company_where 	:= ' f.company_id = &FII_COMPANIES+FII_COMPANIES ';
l_cost_center_where 	:= ' AND f.cost_center_id = &ORGANIZATION+HRI_CL_ORGCC ';

l_fud1_where := REPLACE(fii_ea_util_pkg.get_fud1_for_detail, 'fud1_id', 'user_dim1_id');
l_fud2_where := REPLACE(fii_ea_util_pkg.get_fud2_for_detail, 'fud2_id', 'user_dim2_id');

l_prim_global_curr := BIS_COMMON_PARAMETERS.get_currency_code;
l_sec_global_curr  := BIS_COMMON_PARAMETERS.get_secondary_currency_code;

/* Bugfix 5470346
   - If industry = 'G', add: currency_code = primary currency
                             and currency code != 'STAT'
   - If budget source = 'GL', add: currency_code in (primary, secondary currency)
                                   and currency_code != 'STAT' */
-- Find out if this is commercial or government install
l_industry_profile := FND_PROFILE.value('INDUSTRY');

-- Find out the source of budget
l_budget_source := FND_PROFILE.value('FII_BUDGET_SOURCE');

-- Set currency where clause depends on industry and budget source profile
IF (l_industry_profile = 'G') THEN
  l_currency_where := ' AND f.currency_code = '''||l_prim_global_curr||'''
                        AND f.currency_code != ''STAT''';
ELSIF (l_budget_source = 'GL') THEN
  l_currency_where := ' AND f.currency_code IN ('''||l_prim_global_curr||''',
                                                '''||l_sec_global_curr||''')
                        AND f.currency_code != ''STAT''';
END IF;

/* PMV SQL */
sqlstmt :=
' SELECT
	inline_view.FII_PSI_JOURNAL_NAME 	FII_PSI_JOURNAL_NAME,
	inline_view.FII_PSI_CURRENCY 		FII_PSI_CURRENCY,
	inline_view.FII_PSI_ENTERED_AMOUNT 	FII_PSI_ENTERED_AMOUNT,
	inline_view.FII_PSI_LINE_AMOUNT 	FII_PSI_LINE_AMOUNT,
	inline_view.FII_PSI_JOURNAL_DATE 	FII_PSI_JOURNAL_DATE,
	inline_view.FII_PSI_DOC_NUMBER 		FII_PSI_DOC_NUMBER,
	inline_view.FII_PSI_CATEGORY 		FII_PSI_CATEGORY,
	inline_view.FII_PSI_DESCRIPTION 	FII_PSI_DESCRIPTION,
	inline_view.FII_PSI_SOURCE 		FII_PSI_SOURCE,
	inline_view.FII_PSI_GT_LINE_AMOUNT 	FII_PSI_GT_LINE_AMOUNT
FROM
	(SELECT
	 	f.name 				FII_PSI_JOURNAL_NAME,
     		f.currency_code 		FII_PSI_CURRENCY,
		SUM(NVL(jln.entered_cr, 0) -  NVL(jln.entered_dr, 0))*-1 FII_PSI_ENTERED_AMOUNT,
		SUM(NVL(jln.accounted_cr, 0) -  NVL(jln.accounted_dr, 0))*-1 FII_PSI_LINE_AMOUNT,
	     	jln.effective_date		FII_PSI_JOURNAL_DATE,
		jln.reference_4			FII_PSI_DOC_NUMBER,
	     	f.je_category 			FII_PSI_CATEGORY,
     		f.description 			FII_PSI_DESCRIPTION,
	     	jes.user_je_source_name	 	FII_PSI_SOURCE,
		(SUM(SUM(NVL(jln.accounted_cr, 0) -NVL(jln.accounted_dr,0))) OVER())*-1 FII_PSI_GT_LINE_AMOUNT

	 FROM 	gl_je_headers f,
     		gl_je_lines jln,
		gl_je_sources_tl jes,
		gl_ledgers_public_v sob,
                gl_periods per,
		fii_slg_budget_asgns slba
	WHERE  	f.je_header_id = jln.je_header_id
		AND     f.je_source = jes.je_source_name
		AND  	f.actual_flag = ''B''
		AND     f.status = ''P''
                AND     sob.ledger_id = f.ledger_id
                AND     per.period_set_name = sob.period_set_name
                AND     f.posted_date between per.start_date and per.end_date
                AND     per.adjustment_period_flag = ''N''
		AND  	per.period_type = sob.accounted_period_type
		AND 	jes.language =   userenv(''LANG'')
		AND	jln.effective_date BETWEEN :CURR_PERIOD_START AND :ASOF_DATE
		AND	f.budget_version_id = slba.budget_version_id '||l_currency_where||'
		AND	jln.code_combination_id IN (    SELECT  f.code_combination_id
							FROM	fii_gl_ccid_dimensions f
				 			WHERE   '||l_company_where||l_cost_center_where||l_category_where
								||l_fud1_where||l_fud2_where||'
						    )
	GROUP BY	f.je_header_id, f.name, jln.effective_date, jln.reference_4, f.currency_code,
			f.je_category, f.description, jes.user_je_source_name

UNION ALL

SELECT		'''||g_carryfwd_msg||'''	FII_PSI_JOURNAL_NAME,
		sob.currency_code 		FII_PSI_CURRENCY,
		SUM(NVL(b.begin_balance_cr,0) - NVL(b.begin_balance_dr,0))*-1 FII_PSI_ENTERED_AMOUNT,
	        SUM(NVL(b.begin_balance_cr,0) - NVL(b.begin_balance_dr,0))*-1 FII_PSI_LINE_AMOUNT,
		p.start_date		FII_PSI_JOURNAL_DATE,
		NULL FII_PSI_DOC_NUMBER,
		NULL 			FII_PSI_CATEGORY,
		'''||g_carryfwd_msg||''' 			FII_PSI_DESCRIPTION,
		NULL	 	FII_PSI_SOURCE,
		(SUM(SUM(NVL(b.begin_balance_cr,0) - NVL(b.begin_balance_dr,0))) OVER())*-1 FII_GT_PSI_LINE_AMOUNT

 FROM		FII_SOURCE_LEDGER_GROUPS fslg,
	        FII_SLG_ASSIGNMENTS      slga,
		FII_SLG_BUDGET_ASGNS     slba,
		FII_GL_CCID_DIMENSIONS   f,
		FII_FIN_CAT_TYPE_ASSGNS  fcta,
		GL_BALANCES              b,
		GL_PERIODS               p,
	        GL_LEDGERS_PUBLIC_V      sob

 WHERE		fslg.usage_code = ''DBI''
		AND   slga.source_ledger_group_id = fslg.source_ledger_group_id
		AND   slba.source_ledger_group_id = slga.source_ledger_group_id
		AND   slba.ledger_id = slga.ledger_id
		AND   sob.ledger_id = slba.ledger_id
		AND   p.period_set_name = sob.period_set_name
		AND   p.period_type     = sob.accounted_period_type
		AND   p.period_num      = 1
		AND   p.start_date BETWEEN :CURR_PERIOD_START AND :ASOF_DATE
		AND   b.actual_flag     = ''B''
		AND   b.period_name     = p.period_name
		AND   b.ledger_id = slga.ledger_id
		AND   b.budget_version_id = slba.budget_version_id
		AND   b.currency_code = '''||l_prim_global_curr||'''
                AND   b.currency_code != ''STAT''
		AND  (b.begin_balance_dr <> 0 OR b.begin_balance_cr <> 0)
		AND   b.code_combination_id = f.code_combination_id
		AND '||l_company_where||l_cost_center_where||l_category_where||l_fud1_where||l_fud2_where||'
		AND   (f.company_id = slga.bal_seg_value_id OR
			slga.bal_seg_value_id = -1)
		AND   f.chart_of_accounts_id = slga.chart_of_accounts_id
		AND   fcta.fin_category_id = f.natural_account_id
		AND   fcta.fin_cat_type_code = ''OE''

GROUP BY	sob.currency_code, p.start_date ) inline_view

ORDER BY	FII_PSI_JOURNAL_DATE DESC';




-- Attach bind parameters

FII_EA_UTIL_PKG.bind_variable(
        p_sqlstmt=>sqlstmt,
        p_page_parameter_tbl=>p_page_parameter_tbl,
        p_sql_output=>jrnl_dtl_sql,
        p_bind_output_table=>jrnl_dtl_output);

END GET_BUDGET_JRNL;

END FII_PSI_JE_DTL_PKG;


/
