--------------------------------------------------------
--  DDL for Package Body FII_AR_TRAN_DETAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_TRAN_DETAIL" AS
/* $Header: FIIARDBITDB.pls 120.32.12000000.2 2007/04/09 20:25:44 vkazhipu ship $ */



PROCEDURE get_tran_detail (
        p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
        tran_detail_sql             OUT NOCOPY VARCHAR2,
        tran_detail_output          OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS

l_select		VARCHAR2(15000);
l_party_where 		VARCHAR2(1000);
l_collector_from 	VARCHAR2(100);
l_collector_where	VARCHAR2(1000);
l_industry_from		VARCHAR2(100);
l_industry_where	VARCHAR2(1000);
l_func_where		VARCHAR2(1000);
l_cust_acc_where	VARCHAR2(250);
l_bucket		VARCHAR2(2);
l_bal_select		VARCHAR2(1000);
l_bal_where		VARCHAR2(100);
l_tran_num_drill	VARCHAR2(500);
l_first_due_date_drill	VARCHAR2(500);
l_balance_drill		VARCHAR2(5000);
l_source_drill		VARCHAR2(500);
l_order_by              VARCHAR2(250);
l_order_column          VARCHAR2(250);
l_inag_rng		VARCHAR2(250);


BEGIN

fii_ar_util_pkg.reset_globals;
fii_ar_util_pkg.get_parameters(p_page_parameter_tbl);
fii_ar_util_pkg.g_view_by := 'ORGANIZATION+FII_OPERATING_UNITS';
fii_ar_util_pkg.populate_summary_gt_tables;

IF fii_ar_util_pkg.g_party_id = '-111' THEN
	l_party_where := ' ';
ELSE
 IF fii_ar_util_pkg.g_count_parent_party_id > 1 THEN
   l_party_where := ' AND hz_cust.party_id IN ('||fii_ar_util_pkg.g_party_id||') AND hz_cust.party_id = gt.party_id ';
 ELSE
   l_party_where := ' AND hz_cust.party_id =  :PARTY_ID AND hz_cust.party_id =
gt.party_id ';
 END IF;
END IF;


IF fii_ar_util_pkg.g_collector_id = '-111' THEN
	l_collector_where := ' ';
	l_collector_from := ' ';
ELSE
	l_collector_from := ' ,fii_collectors coll ';
	l_collector_where := ' AND coll.collector_id = gt.collector_id
AND coll.site_use_id = f.bill_to_site_use_id
AND coll.cust_account_id =  f.bill_to_customer_id ';

END IF;

IF fii_ar_util_pkg.g_industry_id = '-111' THEN
	l_industry_where := ' ';
	l_industry_from := ' ';
ELSE
	l_industry_from := ' ,fii_party_mkt_class ind ';
	l_industry_where := ' AND ind.class_code = gt.class_code
AND ind.party_id =  hz_cust.party_id
AND hz_cust.cust_account_id = f.bill_to_customer_id ';

END IF;

IF fii_ar_util_pkg.g_cust_account IS NULL OR
fii_ar_util_pkg.g_cust_account = '-111' THEN
  l_cust_acc_where := ' ';
ELSE
  l_cust_acc_where :=  ' AND f.bill_to_customer_id= :CUST_ACCOUNT  ';
END IF;

l_inag_rng := 'NULL ';

IF fii_ar_util_pkg.g_function_name = 'FII_AR_OPEN_REC_DTL' THEN
/* Open Receivables Detail*/
l_func_where := ' AND f.class IN (''INV'',''DM'',''CB'',''DEP'',''BR'') ';

l_bal_select :=
' (r.current_bucket_1_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.current_bucket_2_amount'||fii_ar_util_pkg.g_col_curr_suffix||'
+r.current_bucket_3_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.past_due_bucket_1_amount'||fii_ar_util_pkg.g_col_curr_suffix||'
+r.past_due_bucket_2_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.past_due_bucket_3_amount'||fii_ar_util_pkg.g_col_curr_suffix||'
+r.past_due_bucket_4_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.past_due_bucket_5_amount'||fii_ar_util_pkg.g_col_curr_suffix||'
+r.past_due_bucket_6_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.past_due_bucket_7_amount'||fii_ar_util_pkg.g_col_curr_suffix||') ';

l_bal_where := ' AND FII_AR_BALANCE_AMT <>0 ';

ELSIF  fii_ar_util_pkg.g_function_name = 'FII_AR_PDUE_REC_DTL' THEN
/* Past Due Receivable Detail */
l_func_where := ' AND f.class IN (''INV'',''DM'',''CB'',''DEP'',''BR'') ';

l_inag_rng := '
SUM(r.past_due_bucket_1_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.past_due_bucket_2_amount'||fii_ar_util_pkg.g_col_curr_suffix||'
+r.past_due_bucket_3_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.past_due_bucket_4_amount'||fii_ar_util_pkg.g_col_curr_suffix||'
+r.past_due_bucket_5_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.past_due_bucket_6_amount'||fii_ar_util_pkg.g_col_curr_suffix||'
+r.past_due_bucket_7_amount'||fii_ar_util_pkg.g_col_curr_suffix||
') ';

l_bal_select :=
' (r.current_bucket_1_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.current_bucket_2_amount'||fii_ar_util_pkg.g_col_curr_suffix||'
+r.current_bucket_3_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.past_due_bucket_1_amount'||fii_ar_util_pkg.g_col_curr_suffix||'
+r.past_due_bucket_2_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.past_due_bucket_3_amount'||fii_ar_util_pkg.g_col_curr_suffix||'
+r.past_due_bucket_4_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.past_due_bucket_5_amount'||fii_ar_util_pkg.g_col_curr_suffix||'
+r.past_due_bucket_6_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.past_due_bucket_7_amount'||fii_ar_util_pkg.g_col_curr_suffix||') ';

l_bal_where := ' AND FII_AR_INAGE_RNG_AMT  <>0 ';

ELSIF  fii_ar_util_pkg.g_function_name = 'FII_AR_CURR_REC_DTL' THEN
/* Current  Receivable Detail */
l_func_where := ' AND f.class IN (''INV'',''DM'',''CB'',''DEP'',''BR'') ';

l_inag_rng := '
SUM(r.current_bucket_1_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.current_bucket_2_amount'||fii_ar_util_pkg.g_col_curr_suffix||'
+ r.current_bucket_3_amount'||fii_ar_util_pkg.g_col_curr_suffix||
') ';

l_bal_select :=
' (r.current_bucket_1_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.current_bucket_2_amount'||fii_ar_util_pkg.g_col_curr_suffix||'
+r.current_bucket_3_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.past_due_bucket_1_amount'||fii_ar_util_pkg.g_col_curr_suffix||'
+r.past_due_bucket_2_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.past_due_bucket_3_amount'||fii_ar_util_pkg.g_col_curr_suffix||'
+r.past_due_bucket_4_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.past_due_bucket_5_amount'||fii_ar_util_pkg.g_col_curr_suffix||'
+r.past_due_bucket_6_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.past_due_bucket_7_amount'||fii_ar_util_pkg.g_col_curr_suffix||') ';

l_bal_where := ' AND FII_AR_INAGE_RNG_AMT <>0 ';

ELSIF  fii_ar_util_pkg.g_function_name = 'FII_AR_REC_PDUE_BUCKET' THEN

l_bucket := fii_ar_util_pkg.g_bucket_num;

/* Receivable Bucket X Days Past Due*/
l_func_where := ' AND f.class IN (''INV'',''DM'',''CB'',''DEP'',''BR'') ';
l_inag_rng := ' SUM(r.past_due_bucket_'||l_bucket||'_amount'||fii_ar_util_pkg.g_col_curr_suffix||') ';

l_bal_select :=
' (r.current_bucket_1_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.current_bucket_2_amount'||fii_ar_util_pkg.g_col_curr_suffix||'
+r.current_bucket_3_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.past_due_bucket_1_amount'||fii_ar_util_pkg.g_col_curr_suffix||'
+r.past_due_bucket_2_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.past_due_bucket_3_amount'||fii_ar_util_pkg.g_col_curr_suffix||'
+r.past_due_bucket_4_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.past_due_bucket_5_amount'||fii_ar_util_pkg.g_col_curr_suffix||'
+r.past_due_bucket_6_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.past_due_bucket_7_amount'||fii_ar_util_pkg.g_col_curr_suffix||') ';

l_bal_where := ' AND FII_AR_INAGE_RNG_AMT <> 0 ';

ELSIF fii_ar_util_pkg.g_function_name = 'FII_AR_REC_DUE_BUCKET' THEN

l_bucket := fii_ar_util_pkg.g_bucket_num;

/* Receivable Due in Bucket X Days*/
l_func_where := ' AND f.class IN (''INV'',''DM'',''CB'',''DEP'',''BR'') ';
l_inag_rng := ' SUM(r.current_bucket_'||l_bucket||'_amount'||fii_ar_util_pkg.g_col_curr_suffix||') ';

l_bal_select :=
' (r.current_bucket_1_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.current_bucket_2_amount'||fii_ar_util_pkg.g_col_curr_suffix||'
+r.current_bucket_3_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.past_due_bucket_1_amount'||fii_ar_util_pkg.g_col_curr_suffix||'
+r.past_due_bucket_2_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.past_due_bucket_3_amount'||fii_ar_util_pkg.g_col_curr_suffix||'
+r.past_due_bucket_4_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.past_due_bucket_5_amount'||fii_ar_util_pkg.g_col_curr_suffix||'
+r.past_due_bucket_6_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.past_due_bucket_7_amount'||fii_ar_util_pkg.g_col_curr_suffix||') ';

l_bal_where := ' AND FII_AR_INAGE_RNG_AMT <> 0 ';

ELSIF  fii_ar_util_pkg.g_function_name = 'FII_AR_OPEN_INV_DTL' THEN
/* Invoices Detail */

l_func_where := ' AND f.class = ''INV'' ';

--l_inag_rng := ' SUM(r.past_due_bucket_'||l_bucket||'_amount'||fii_ar_util_pkg.g_col_curr_suffix||') ';

l_bal_select :=
' (r.current_bucket_1_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.current_bucket_2_amount'||fii_ar_util_pkg.g_col_curr_suffix||'
+r.current_bucket_3_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.past_due_bucket_1_amount'||fii_ar_util_pkg.g_col_curr_suffix||'
+r.past_due_bucket_2_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.past_due_bucket_3_amount'||fii_ar_util_pkg.g_col_curr_suffix||'
+r.past_due_bucket_4_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.past_due_bucket_5_amount'||fii_ar_util_pkg.g_col_curr_suffix||'
+r.past_due_bucket_6_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.past_due_bucket_7_amount'||fii_ar_util_pkg.g_col_curr_suffix||') ';

l_bal_where := ' AND FII_AR_BALANCE_AMT <>0 ';

ELSIF  fii_ar_util_pkg.g_function_name = 'FII_AR_OPEN_DM_DTL' THEN
/* Debit Memo Detail */

l_func_where :=' AND f.class = ''DM'' ';

l_bal_select :=
' (r.current_bucket_1_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.current_bucket_2_amount'||fii_ar_util_pkg.g_col_curr_suffix||'
+r.current_bucket_3_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.past_due_bucket_1_amount'||fii_ar_util_pkg.g_col_curr_suffix||'
+r.past_due_bucket_2_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.past_due_bucket_3_amount'||fii_ar_util_pkg.g_col_curr_suffix||'
+r.past_due_bucket_4_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.past_due_bucket_5_amount'||fii_ar_util_pkg.g_col_curr_suffix||'
+r.past_due_bucket_6_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.past_due_bucket_7_amount'||fii_ar_util_pkg.g_col_curr_suffix||') ';

l_bal_where := ' AND FII_AR_BALANCE_AMT <>0 ';

ELSIF  fii_ar_util_pkg.g_function_name = 'FII_AR_OPEN_CB_DTL' THEN
/* Charge Back  Detail */
l_func_where := ' AND f.class = ''CB'' ';

l_bal_select :=
' (r.current_bucket_1_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.current_bucket_2_amount'||fii_ar_util_pkg.g_col_curr_suffix||'
+r.current_bucket_3_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.past_due_bucket_1_amount'||fii_ar_util_pkg.g_col_curr_suffix||'
+r.past_due_bucket_2_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.past_due_bucket_3_amount'||fii_ar_util_pkg.g_col_curr_suffix||'
+r.past_due_bucket_4_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.past_due_bucket_5_amount'||fii_ar_util_pkg.g_col_curr_suffix||'
+r.past_due_bucket_6_amount'||fii_ar_util_pkg.g_col_curr_suffix||'+r.past_due_bucket_7_amount'||fii_ar_util_pkg.g_col_curr_suffix||') ';

l_bal_where := ' AND FII_AR_BALANCE_AMT <>0 ';

ELSE
l_func_where := NULL;
l_bal_select := NULL;
l_bal_where := NULL;

END IF;

l_tran_num_drill :=' DECODE(f.class,''INV'', '||
'''pFunctionName=ARBPA_TM_REAL_PREVIEW&retainBN=Y&retainAM=Y&addBreadCrumb=Y&TermsSequenceNumber=FII_AR_TERM_SEQ_NUM'||
'&CustomerTrxId=FII_AR_CUST_TRX_ID&orgId=''||f.org_id||''&pParamIds=Y'','''') ';

l_first_due_date_drill :=
'pFunctionName=FII_AR_SCHD_PMT_DISCNT&FII_AR_CUST_TRX_ID=FII_AR_CUST_TRX_ID&FII_AR_TRAN_NUM=FII_AR_TRAN_NUM&FII_CURRENCIES='||'''||FII_AR_TRAN_CURR||'''||
'&BIS_PMV_DRILL_CODE_FII_AR_CUST_ACCOUNT=FII_AR_ACCT_NUM&BIS_PMV_DRILL_CODE_AS_OF_DATE=sysdate&pParamIds=Y';

l_balance_drill :=
'DECODE(f.class,''INV'',
''pFunctionName=FII_AR_INV_ACT_HISTORY&FII_AR_CUST_TRX_ID=FII_AR_CUST_TRX_ID&FII_AR_TRAN_NUM=FII_AR_TRAN_NUM&FII_AR_TRAN_CLASS=FII_AR_TRAN_CLASS_CODE&FII_AR_ACCOUNT_NUM=FII_AR_ACCT_NUM
&FII_AR_TRAN_CURR=FII_AR_TRAN_CURR&BIS_PMV_DRILL_CODE_AS_OF_DATE=sysdate&pParamIds=Y'',
''BR'',
''pFunctionName=FII_AR_BR_ACT_HISTORY&FII_AR_CUST_TRX_ID=FII_AR_CUST_TRX_ID&FII_AR_TRAN_NUM=FII_AR_TRAN_NUM&FII_AR_TRAN_CLASS=FII_AR_TRAN_CLASS_CODE&FII_AR_ACCOUNT_NUM=FII_AR_ACCT_NUM
&FII_AR_TRAN_CURR=FII_AR_TRAN_CURR&BIS_PMV_DRILL_CODE_AS_OF_DATE=sysdate&pParamIds=Y'',
''CB'',
''pFunctionName=FII_AR_CB_ACT_HISTORY&FII_AR_CUST_TRX_ID=FII_AR_CUST_TRX_ID&FII_AR_TRAN_NUM=FII_AR_TRAN_NUM&FII_AR_TRAN_CLASS=FII_AR_TRAN_CLASS_CODE&FII_AR_ACCOUNT_NUM=FII_AR_ACCT_NUM
&FII_AR_TRAN_CURR=FII_AR_TRAN_CURR&BIS_PMV_DRILL_CODE_AS_OF_DATE=sysdate&pParamIds=Y'',
''CM'',
''pFunctionName=FII_AR_CM_ACT_HISTORY&FII_AR_CUST_TRX_ID=FII_AR_CUST_TRX_ID&FII_AR_TRAN_NUM=FII_AR_TRAN_NUM&FII_AR_TRAN_CLASS=FII_AR_TRAN_CLASS_CODE&FII_AR_ACCOUNT_NUM=FII_AR_ACCT_NUM
&FII_AR_TRAN_CURR=FII_AR_TRAN_CURR&BIS_PMV_DRILL_CODE_AS_OF_DATE=sysdate&pParamIds=Y'',
''DEP'',
''pFunctionName=FII_AR_DEP_ACT_HISTORY&FII_AR_CUST_TRX_ID=FII_AR_CUST_TRX_ID&FII_AR_TRAN_NUM=FII_AR_TRAN_NUM&FII_AR_TRAN_CLASS=FII_AR_TRAN_CLASS_CODE&FII_AR_ACCOUNT_NUM=FII_AR_ACCT_NUM
&FII_AR_TRAN_CURR=FII_AR_TRAN_CURR&BIS_PMV_DRILL_CODE_AS_OF_DATE=sysdate&pParamIds=Y'',
''DM'',
''pFunctionName=FII_AR_DM_ACT_HISTORY&FII_AR_CUST_TRX_ID=FII_AR_CUST_TRX_ID&FII_AR_TRAN_NUM=FII_AR_TRAN_NUM&FII_AR_TRAN_CLASS=FII_AR_TRAN_CLASS_CODE&FII_AR_ACCOUNT_NUM=FII_AR_ACCT_NUM
&FII_AR_TRAN_CURR=FII_AR_TRAN_CURR&BIS_PMV_DRILL_CODE_AS_OF_DATE=sysdate&pParamIds=Y'', '' '' )
';

l_source_drill := ' DECODE(f.order_ref_number,NULL,'''', ''pFunctionName=ONT_PORTAL_ORDERDETAILS&HeaderId=''||(select ooh.header_id
				from oe_order_headers_all ooh
				where f.order_ref_number    =
to_char(ooh.order_number) and rownum=1  ) ) ';

IF INSTR(fii_ar_util_pkg.g_order_by,',') <> 0 AND
INSTR(SUBSTR(fii_ar_util_pkg.g_order_by,1,25),'FII_AR_BALANCE_AMT DESC') <> 0 THEN

   l_order_by := 'ORDER BY NVL(FII_AR_BALANCE_AMT, -999999999) DESC';

ELSIF instr(fii_ar_util_pkg.g_order_by, ' DESC') <> 0 THEN
   l_order_column := substr(fii_ar_util_pkg.g_order_by,1,instr(fii_ar_util_pkg.g_order_by, ' DESC'));

   IF INSTR(fii_ar_util_pkg.g_order_by,'DATE') = 0 AND
      INSTR(fii_ar_util_pkg.g_order_by, 'BINARY') = 0 THEN
   l_order_by := 'ORDER BY NVL('|| l_order_column ||', -999999999) DESC';
   ELSIF  INSTR(fii_ar_util_pkg.g_order_by, 'BINARY') <> 0 THEN
   l_order_column := SUBSTR(fii_ar_util_pkg.g_order_by,
	INSTR(fii_ar_util_pkg.g_order_by,'FII'), INSTR(fii_ar_util_pkg.g_order_by,',') -
	INSTR(fii_ar_util_pkg.g_order_by,'FII'));
   l_order_by := 'ORDER BY NVL(' || l_order_column || ', ''    '') DESC';
   ELSE
   l_order_by := 'ORDER BY '|| l_order_column ||' DESC';
   END IF;

ELSE
   l_order_by := '&ORDER_BY_CLAUSE';
END IF;


l_select := '
SELECT
FII_AR_CUST_TRX_ID,
FII_AR_ACCT_NUM,
FII_AR_TRAN_NUM,
FII_AR_TERM_SEQ_NUM,
NULL FII_AR_ORD_HDR_ID,
FII_AR_TRAN_CLASS,
FII_AR_TRAN_CLASS_CODE,
FII_AR_TRAN_TYPE,
FII_AR_TRAN_DATE,
FII_AR_GL_DATE,
FII_AR_FIRST_DUE_DATE,
FII_AR_TRAN_CURR,
FII_AR_TRAN_AMT,
FII_AR_ORIG_AMT,
FII_AR_INAGE_RNG_AMT,
FII_AR_BALANCE_AMT,
FII_AR_DISPUTE_AMT,
FII_AR_TERMS,
FII_AR_SOURCE,
SUM(FII_AR_ORIG_AMT) over()     FII_AR_ORIG_AMT_GT,
SUM(FII_AR_INAGE_RNG_AMT) over() FII_AR_INAGE_RNG_AMT_GT,
SUM(FII_AR_BALANCE_AMT) over()  FII_AR_BALANCE_AMT_GT,
SUM(FII_AR_DISPUTE_AMT) over()  FII_AR_DISPUTE_AMT_GT,
FII_AR_TRAN_NUM_DRILL,
FII_AR_FIRST_DUE_DATE_DRILL,
FII_AR_BALANCE_AMT_DRILL,
FII_AR_SOURCE_DRILL
FROM
(
SELECT
f.customer_trx_id 	FII_AR_CUST_TRX_ID,
FII_AR_ACCT_NUM,
FII_AR_TRAN_NUM,
rlk.meaning             FII_AR_TRAN_CLASS,
f.class			FII_AR_TRAN_CLASS_CODE,
ctype.description       FII_AR_TRAN_TYPE,
FII_AR_TERM_SEQ_NUM,
FII_AR_TRAN_DATE,
FII_AR_GL_DATE,
FII_AR_FIRST_DUE_DATE,
FII_AR_TRAN_CURR,
FII_AR_TRAN_AMT,
FII_AR_ORIG_AMT,
FII_AR_INAGE_RNG_AMT,
FII_AR_BALANCE_AMT,
FII_AR_DISPUTE_AMT,
rterm.description       FII_AR_TERMS,
rsource.description     FII_AR_SOURCE,
'||l_tran_num_drill||' FII_AR_TRAN_NUM_DRILL,
'''||l_first_due_date_drill||''' FII_AR_FIRST_DUE_DATE_DRILL,
'||l_balance_drill||' FII_AR_BALANCE_AMT_DRILL,
'||l_source_drill||' FII_AR_SOURCE_DRILL
FROM
(SELECT customer_trx_id,SUM(current_dispute_amount_prim+past_due_dispute_amount_prim) FII_AR_DISPUTE_AMT
FROM fii_ar_aging_disputes d
WHERE event_date <= :ASOF_DATE GROUP BY customer_trx_id) d,
ra_cust_trx_types_all ctype,
ar_lookups rlk,
ra_terms_tl rterm,
ra_batch_sources_all rsource,
(select /*+ leading(gt) cardinality(gt 1) */
f.customer_trx_id,
hz_cust.account_number          FII_AR_ACCT_NUM,
f.transaction_number            FII_AR_TRAN_NUM,
f.class,
1 				FII_AR_TERM_SEQ_NUM,
f.order_ref_number,
f.cust_trx_type_id,
MIN(f.trx_date)                      FII_AR_TRAN_DATE,
MIN(f.gl_date)                       FII_AR_GL_DATE,
MIN(f.due_date)                 FII_AR_FIRST_DUE_DATE,
f.invoice_currency_code  	FII_AR_TRAN_CURR,
f.invoice_currency_code||'' ''||TO_CHAR(SUM(case when aging_flag = ''N'' and action = ''Transaction''
                                                   then f.amount_due_original_trx
                                                 else 0 end),''999,999,999,999'') FII_AR_TRAN_AMT,
SUM(case when aging_flag = ''N'' and action = ''Transaction''
             then f.amount_due_original'||fii_ar_util_pkg.g_col_curr_suffix||'
         else 0 end) FII_AR_ORIG_AMT,
 '||l_inag_rng||' FII_AR_INAGE_RNG_AMT,
SUM( '||l_bal_select||') FII_AR_BALANCE_AMT,
f.term_id,
f.batch_source_id,
f.bill_to_customer_id,
f.org_id
FROM
fii_ar_pmt_schedules_f f,
fii_ar_aging_receivables r,
hz_cust_accounts hz_cust,
fii_ar_summary_gt gt
'||l_collector_from||l_industry_from||'
WHERE f.bill_to_customer_id= hz_cust.cust_account_id
AND f.filter_date <=  :ASOF_DATE
AND r.event_date  <=  :ASOF_DATE
AND f.payment_schedule_id = r.payment_schedule_id
AND f.org_id = r.org_id
AND f.org_id = gt.org_id
'||l_party_where||l_cust_acc_where||l_collector_where||l_industry_where||l_func_where||'
group by f.customer_trx_id,f.org_id, f.transaction_number, f.class,
f.order_ref_number,
f.cust_trx_type_id,
f.invoice_currency_code,
f.term_id, f.batch_source_id,
f.bill_to_customer_id, hz_cust.account_number
 ) f
WHERE f.cust_trx_type_id = ctype.cust_trx_type_id
 '||l_bal_where||'
AND f.org_id=ctype.org_id
AND f.customer_trx_id = d.customer_trx_id(+)
AND f.class = rlk.lookup_code
AND rlk.lookup_type= ''INV/CM/ADJ''
AND f.term_id = rterm.term_id(+)
AND DECODE(rterm.term_id, NULL, USERENV(''LANG''),rterm.language) = USERENV(''LANG'')
AND f.batch_source_id = rsource.batch_source_id
AND f.org_id=rsource.org_id
) '||l_order_by||'
';

fii_ar_util_pkg.bind_variable(l_select, p_page_parameter_tbl, tran_detail_sql, tran_detail_output);

END get_tran_detail;

END FII_AR_TRAN_DETAIL;


/
