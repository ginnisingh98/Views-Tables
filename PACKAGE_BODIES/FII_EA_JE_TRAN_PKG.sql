--------------------------------------------------------
--  DDL for Package Body FII_EA_JE_TRAN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_EA_JE_TRAN_PKG" AS
/* $Header: FIIEAJ1B.pls 120.4 2006/08/08 17:00:32 vkazhipu noship $ */


/* Getting category type for a category */
PROCEDURE get_cat_type
IS

l_type VARCHAR2(100);
BEGIN

	SELECT fin_cat_type_code
	INTO FII_EA_JE_TRAN_PKG.g_fin_type
	FROM fii_fin_cat_type_assgns
	WHERE fin_category_id= fii_ea_util_pkg.g_fin_category_id
	AND fin_cat_type_code IN ('EXP','R');

EXCEPTION
WHEN no_data_found THEN
   FII_EA_JE_TRAN_PKG.g_fin_type := NULL;
END get_cat_type;


PROCEDURE get_je_tran (
        p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
        jrnl_dtl_sql             OUT NOCOPY VARCHAR2,
        jrnl_dtl_output          OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
        l_as_of_date            DATE;
        l_currency              VARCHAR2(240);
        sqlstmt                 VARCHAR2(14000);
	l_ledger_where		VARCHAR2(1000);
	l_company_where		VARCHAR2(1000); -- To store company id dynamic where clause
	l_cost_center_where	VARCHAR2(1000); -- To store cost center dynamic where clause
	l_fud1_where		VARCHAR2(1000); -- To store user dim 1 dynamic where clause
	l_fud2_where		VARCHAR2(1000); -- To store user dim 2 dynamic where clause
	l_category_where	VARCHAR2(1000); -- To store categoty dynamic where clause
	l_source_where		VARCHAR2(1000); -- To store je source dynamic where clause
	l_entered_amount	VARCHAR2(1000); -- To store dynamic Select entered amt columns based on g_fin_type is Expense or Revenue.
	l_functional_amount	VARCHAR2(1000); -- To store dynamic Select functional amt columns based on g_fin_type is Expense or Revenue.
	l_gt_functional_amount	VARCHAR2(1000); -- To store dynamic Select grand total functional columns based on g_fin_type is Expense or Revenue.
	l_fud1_enabled_flag	VARCHAR2(1) := NULL;
	l_fud2_enabled_flag	VARCHAR2(1) := NULL;


BEGIN

FII_EA_UTIL_PKG.reset_globals;
FII_EA_UTIL_PKG.get_parameters(p_page_parameter_tbl=>p_page_parameter_tbl);

/* Getting category type for a category */
FII_EA_JE_TRAN_PKG.get_cat_type;

/* Preparing Dynamic where clauses for PMV sql */

l_ledger_where          := ' AND f.ledger_id = &FII_LEDGER+FII_LEDGER ';
l_category_where 	:= ' AND f.natural_account_id = &FINANCIAL ITEM+GL_FII_FIN_ITEM ';
l_company_where 	:= ' f.company_id = &FII_COMPANIES+FII_COMPANIES ';
l_cost_center_where 	:= ' AND f.cost_center_id = &ORGANIZATION+HRI_CL_ORGCC ';



l_fud1_where := fii_ea_util_pkg.get_fud1_for_detail;
l_fud2_where := fii_ea_util_pkg.get_fud2_for_detail;

l_fud1_where := REPLACE(l_fud1_where,'f.fud1_id','f.user_dim1_id');
l_fud2_where := REPLACE(l_fud2_where,'f.fud2_id','f.user_dim2_id');


/* Selecting Chart of Accounts ID */

	BEGIN
		SELECT chart_of_accounts_id INTO FII_EA_UTIL_PKG.g_coaid
                FROM gl_ledgers_public_v
                WHERE ledger_id = FII_EA_UTIL_PKG.g_ledger_id;
	END;

/* Select columns based on call for Expense or Revenue */

IF FII_EA_JE_TRAN_PKG.g_fin_type = 'EXP' THEN /* Expense*/

	l_entered_amount := ' SUM(NVL(jln.entered_cr, 0) -  NVL(jln.entered_dr, 0))*-1 FII_EA_ENTERED_AMOUNT, ';
	l_functional_amount := ' SUM(NVL(jln.accounted_cr, 0) -  NVL(jln.accounted_dr, 0))*-1 FII_EA_FUNCTIONAL_AMOUNT, ';
	l_gt_functional_amount := ' SUM(SUM(NVL(jln.accounted_cr, 0) -NVL(jln.accounted_dr,0))*-1) OVER() FII_GT_EA_FUNCTIONAL_AMOUNT ';

ELSIF FII_EA_JE_TRAN_PKG.g_fin_type = 'R' THEN /* Revenue */

	l_entered_amount := ' SUM(NVL(jln.entered_cr, 0) -  NVL(jln.entered_dr, 0)) FII_EA_ENTERED_AMOUNT, ';
	l_functional_amount := ' SUM(NVL(jln.accounted_cr, 0) -  NVL(jln.accounted_dr, 0)) FII_EA_FUNCTIONAL_AMOUNT, ';
	l_gt_functional_amount := ' SUM(SUM(NVL(jln.accounted_cr, 0) -NVL(jln.accounted_dr,0))) OVER() FII_GT_EA_FUNCTIONAL_AMOUNT ';

END IF;

/* PMV SQL */

sqlstmt :=
' SELECT
	g.FII_EA_JOURNAL_NAME 		FII_EA_JOURNAL_NAME,
	g.FII_EA_CURRENCY 		FII_EA_CURRENCY,
	g.FII_EA_ENTERED_AMOUNT 	FII_EA_ENTERED_AMOUNT,
	g.FII_EA_FUNCTIONAL_AMOUNT 	FII_EA_FUNCTIONAL_AMOUNT,
	g.FII_EA_JOURNAL_DATE 		FII_EA_JOURNAL_DATE,
	g.FII_EA_CATEGORY 		FII_EA_CATEGORY,
	g.FII_EA_DESCRIPTION 		FII_EA_DESCRIPTION,
	g.FII_EA_SOURCE 		FII_EA_SOURCE,
	g.FII_GT_EA_FUNCTIONAL_AMOUNT 	FII_GT_EA_FUNCTIONAL_AMOUNT
FROM
(SELECT
	(rank () over(ORDER BY NLSSORT(f.name, ''NLS_SORT= BINARY'') nulls last,f.NAME)) -1 rnk,
 	f.name 				FII_EA_JOURNAL_NAME,
     	f.currency_code 		FII_EA_CURRENCY,
	'||l_entered_amount||'
	'||l_functional_amount||'
     	jln.effective_date		FII_EA_JOURNAL_DATE,
     	f.je_category 			FII_EA_CATEGORY,
     	f.description 			FII_EA_DESCRIPTION,
     	jes.user_je_source_name	 	FII_EA_SOURCE,
	'||l_gt_functional_amount||'
 FROM 	gl_je_headers f,
     	gl_je_lines jln,
	fii_gl_processed_header_ids fgl,
	gl_je_sources_tl jes
WHERE  	f.je_header_id = fgl.je_header_id
AND	f.je_header_id = jln.je_header_id
AND     f.je_source = :SOURCE_GROUP
'||l_ledger_where||'
AND     f.je_source = jes.je_source_name
AND  	f.actual_flag = ''A''
and 	jes.language =   userenv(''LANG'')
AND	jln.effective_date BETWEEN :CURR_PERIOD_START AND :ASOF_DATE
AND	jln.code_combination_id IN (SELECT f.code_combination_id
				   FROM fii_gl_ccid_dimensions f
			 	   WHERE '||l_company_where||'
				   '||l_cost_center_where||'
				   '||l_category_where||'
				   AND f.chart_of_accounts_id = :COAID
				   '||l_fud1_where||'
				   '||l_fud2_where||'
				   )
GROUP BY f.je_header_id, f.name, jln.effective_date, f.currency_code, f.je_category, f.description, jes.user_je_source_name) g
WHERE  (rnk BETWEEN &START_INDEX AND &END_INDEX or &END_INDEX = -1)
ORDER BY FII_EA_FUNCTIONAL_AMOUNT DESC  ';


-- Attach bind parameters

FII_EA_UTIL_PKG.bind_variable(
        p_sqlstmt=>sqlstmt,
        p_page_parameter_tbl=>p_page_parameter_tbl,
        p_sql_output=>jrnl_dtl_sql,
        p_bind_output_table=>jrnl_dtl_output);

END get_je_tran;

--***********************************--

/* Code for Journal Transaction Line Level Report */

PROCEDURE get_je_line_tran (
        p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
        jrnl_dtl_sql             OUT NOCOPY VARCHAR2,
        jrnl_dtl_output          OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
        l_as_of_date            DATE;
        l_currency              VARCHAR2(240);
        sqlstmt                 VARCHAR2(14000);
	l_ledger_where		VARCHAR2(1000);
	l_company_where		VARCHAR2(1000); -- To store company id dynamic where clause
	l_cost_center_where	VARCHAR2(1000); -- To store cost center dynamic where clause
	l_fud1_where		VARCHAR2(1000); -- To store user dim 1 dynamic where clause
	l_fud2_where		VARCHAR2(1000); -- To store user dim 2 dynamic where clause
	l_category_where	VARCHAR2(1000); -- To store categoty dynamic where clause
	l_source_where		VARCHAR2(1000); -- To store je source dynamic where clause
	l_entered_amount	VARCHAR2(1000); -- To store dynamic Select entered amt columns based on g_fin_type is Expense or Revenue.
	l_functional_amount	VARCHAR2(1000); -- To store dynamic Select functional amt columns based on g_fin_type is Expense or Revenue.
	l_gt_functional_amount	VARCHAR2(1000); -- To store dynamic Select grand total functional columns based on g_fin_type is Expense or Revenue.
	l_fud1_enabled_flag	VARCHAR2(1) := NULL;
	l_fud2_enabled_flag	VARCHAR2(1) := NULL;


BEGIN

FII_EA_UTIL_PKG.get_parameters(p_page_parameter_tbl=>p_page_parameter_tbl);

/* Getting category type for a category */
FII_EA_JE_TRAN_PKG.get_cat_type;

/* Preparing Dynamic where clauses for PMV sql */

l_ledger_where          := ' AND f.ledger_id = &FII_LEDGER+FII_LEDGER ';
l_category_where 	:= ' AND f.natural_account_id = &FINANCIAL ITEM+GL_FII_FIN_ITEM ';
l_company_where 	:= ' f.company_id = &FII_COMPANIES+FII_COMPANIES ';
l_cost_center_where 	:= ' AND f.cost_center_id = &ORGANIZATION+HRI_CL_ORGCC ';


l_fud1_where := fii_ea_util_pkg.get_fud1_for_detail;
l_fud2_where := fii_ea_util_pkg.get_fud2_for_detail;

l_fud1_where := REPLACE(l_fud1_where,'f.fud1_id','f.user_dim1_id');
l_fud2_where := REPLACE(l_fud2_where,'f.fud2_id','f.user_dim2_id');


/* Selecting Chart of Accounts ID */

	BEGIN
		SELECT chart_of_accounts_id INTO FII_EA_UTIL_PKG.g_coaid
                FROM gl_ledgers_public_v
                WHERE ledger_id = FII_EA_UTIL_PKG.g_ledger_id;
	END;

/* Select columns based on call for Expense or Revenue */

IF FII_EA_JE_TRAN_PKG.g_fin_type = 'EXP' THEN /* Expense*/

	l_entered_amount := ' (NVL(jln.entered_cr, 0) -  NVL(jln.entered_dr, 0))*-1 FII_EA_ENTERED_AMOUNT, ';
	l_functional_amount := ' (NVL(jln.accounted_cr, 0) -  NVL(jln.accounted_dr, 0)) *-1 FII_EA_FUNCTIONAL_AMOUNT, ';
	l_gt_functional_amount := ' SUM((NVL(jln.accounted_cr, 0) -NVL(jln.accounted_dr,0)) *-1) OVER() FII_GT_EA_FUNCTIONAL_AMOUNT ';

ELSIF FII_EA_JE_TRAN_PKG.g_fin_type = 'R' THEN /* Revenue */


	l_entered_amount := ' (NVL(jln.entered_cr, 0) -  NVL(jln.entered_dr, 0)) FII_EA_ENTERED_AMOUNT, ';
	l_functional_amount := ' (NVL(jln.accounted_cr, 0) -  NVL(jln.accounted_dr, 0))  FII_EA_FUNCTIONAL_AMOUNT, ';
	l_gt_functional_amount := ' SUM((NVL(jln.accounted_cr, 0) -NVL(jln.accounted_dr,0))) OVER() FII_GT_EA_FUNCTIONAL_AMOUNT ';

END IF;

/* PMV SQL */
sqlstmt :=
' SELECT
	g.FII_EA_JOURNAL_NAME 		FII_EA_JOURNAL_NAME,
	g.FII_EA_CURRENCY 		FII_EA_CURRENCY,
	g.FII_EA_ENTERED_AMOUNT 	FII_EA_ENTERED_AMOUNT,
	g.FII_EA_LINE_NUMBER		FII_EA_LINE_NUMBER,
	g.FII_EA_ACCOUNT_NUMBER		FII_EA_ACCOUNT_NUMBER,
	g.FII_EA_FUNCTIONAL_AMOUNT 	FII_EA_FUNCTIONAL_AMOUNT,
	g.FII_EA_JOURNAL_DATE 		FII_EA_JOURNAL_DATE,
	g.FII_EA_CATEGORY 		FII_EA_CATEGORY,
	g.FII_EA_DESCRIPTION 		FII_EA_DESCRIPTION,
	g.FII_EA_SOURCE 		FII_EA_SOURCE,
	g.FII_EA_REFERENCE_1		FII_EA_REFERENCE_1,
	g.FII_EA_REFERENCE_2		FII_EA_REFERENCE_2,
	g.FII_EA_REFERENCE_3		FII_EA_REFERENCE_3,
	g.FII_EA_REFERENCE_4		FII_EA_REFERENCE_4,
	g.FII_EA_REFERENCE_5		FII_EA_REFERENCE_5,
	g.FII_EA_REFERENCE_6		FII_EA_REFERENCE_6,
	g.FII_EA_REFERENCE_7		FII_EA_REFERENCE_7,
	g.FII_EA_REFERENCE_8		FII_EA_REFERENCE_8,
	g.FII_EA_REFERENCE_9		FII_EA_REFERENCE_9,
	g.FII_EA_REFERENCE_10		FII_EA_REFERENCE_10,
	g.FII_GT_EA_FUNCTIONAL_AMOUNT 	FII_GT_EA_FUNCTIONAL_AMOUNT
FROM
(SELECT
	(rank () over(ORDER BY NLSSORT(f.name, ''NLS_SORT= BINARY'') nulls last,f.NAME,jln.effective_date,jln.je_line_num)) -1 rnk,
 	f.name 				FII_EA_JOURNAL_NAME,
     	f.currency_code 		FII_EA_CURRENCY,
	'||l_entered_amount||'
	jln.je_line_num			FII_EA_LINE_NUMBER,
	RTRIM(glc.concatenated_segments)	FII_EA_ACCOUNT_NUMBER,
	'||l_functional_amount||'
     	jln.effective_date		FII_EA_JOURNAL_DATE,
     	f.je_category 			FII_EA_CATEGORY,
     	f.description 			FII_EA_DESCRIPTION,
     	jes.user_je_source_name		FII_EA_SOURCE,
	TRIM(jln.reference_1)			FII_EA_REFERENCE_1,
	TRIM(jln.reference_2)			FII_EA_REFERENCE_2,
	TRIM(jln.reference_3)			FII_EA_REFERENCE_3,
	TRIM(jln.reference_4)			FII_EA_REFERENCE_4,
	TRIM(jln.reference_5)			FII_EA_REFERENCE_5,
	TRIM(jln.reference_6)			FII_EA_REFERENCE_6,
	TRIM(jln.reference_7)			FII_EA_REFERENCE_7,
	TRIM(jln.reference_8)			FII_EA_REFERENCE_8,
	TRIM(jln.reference_9)			FII_EA_REFERENCE_9,
	TRIM(jln.reference_10)			FII_EA_REFERENCE_10,
	'||l_gt_functional_amount||'
 FROM 	gl_je_headers f,
     	gl_je_lines jln,
	fii_gl_processed_header_ids fgl,
	gl_code_combinations_kfv glc,
	gl_je_sources_tl jes
WHERE  	f.je_header_id = fgl.je_header_id
AND	f.je_header_id = jln.je_header_id
AND     f.je_source = :SOURCE_GROUP
'||l_ledger_where||'
AND     f.je_source = jes.je_source_name
AND     f.actual_flag = ''A''
AND 	jes.language =   userenv(''LANG'')
AND	jln.effective_date BETWEEN :CURR_PERIOD_START AND :ASOF_DATE
AND 	jln.code_combination_id = glc.code_combination_id
AND 	glc.chart_of_accounts_id = :COAID
AND	jln.code_combination_id IN (SELECT f.code_combination_id
				   FROM fii_gl_ccid_dimensions f
			 	   WHERE '||l_company_where||'
				   '||l_cost_center_where||'
				   '||l_category_where||'
				   AND f.chart_of_accounts_id = :COAID
				   '||l_fud1_where||'
				   '||l_fud2_where||'
				   )
) g
WHERE  (rnk BETWEEN &START_INDEX AND &END_INDEX or &END_INDEX = -1)
ORDER BY FII_EA_FUNCTIONAL_AMOUNT DESC  ';




-- Attach bind parameters

FII_EA_UTIL_PKG.bind_variable(
        p_sqlstmt=>sqlstmt,
        p_page_parameter_tbl=>p_page_parameter_tbl,
        p_sql_output=>jrnl_dtl_sql,
        p_bind_output_table=>jrnl_dtl_output);

END get_je_line_tran;



END FII_EA_JE_TRAN_PKG;


/
