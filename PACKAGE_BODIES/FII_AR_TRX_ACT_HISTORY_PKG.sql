--------------------------------------------------------
--  DDL for Package Body FII_AR_TRX_ACT_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_TRX_ACT_HISTORY_PKG" AS
/* $Header: FIIARDBITAHB.pls 120.7.12000000.1 2007/02/23 02:29:12 applrt ship $ */

PROCEDURE get_trx_act_history (
        p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
        trx_act_history_sql             OUT NOCOPY VARCHAR2,
        trx_act_history_output          OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS

sqlstmt                       VARCHAR2(32000);

  --Variable to implement drill on 'amount' column for Receipts
l_drill	VARCHAR2(300);
l_app_rec_drill	VARCHAR2(300);
l_trx_id_join	VARCHAR2(100);
l_adjust_flag   VARCHAR2(10);
l_trx_sql	VARCHAR2(32000);
l_cust_all      VARCHAR2(30);

BEGIN
  --Call to reset the parameter variables
  fii_ar_util_pkg.reset_globals;

  --Call to get all the parameters in the report
  fii_ar_util_pkg.get_parameters(p_page_parameter_tbl);

/* Changes for bug 5086091

1. Changed the query to use Applied_customer_trx_id and not customer_trx_id in case of Receipts
2. Changed l_drill to send customer_trx_id and cash_receipt_id while drilling to Receipts Detail */

--Amount Drills

l_cust_all := 'All';

l_drill := 'pFunctionName=FII_AR_APP_RCT_DTL&TRX_NUM=FII_AR_CUST_TRX_ID&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS='||l_cust_all||'&FII_AR_CASH_RECEIPT_ID=''||inline.FII_AR_CASH_RECEIPT_ID||''&pParamIds=Y';

l_app_rec_drill := 'DECODE(inline.LOOKUP_CODE, ''RECEIPT'', '''||l_drill||''')';

IF fii_ar_util_pkg.g_tran_class = 'CM' THEN
	l_trx_id_join := 'customer_trx_id = :CUST_TRX_ID and';
ELSE
	l_trx_id_join := 'applied_customer_trx_id = :CUST_TRX_ID and';
END IF;

-- Assigning l_adjust_flag to N when there is drill from Balance column
   l_adjust_flag := 'N';

IF (p_page_parameter_tbl.count > 0) THEN
    FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP

      IF p_page_parameter_tbl(i).parameter_name = 'FII_AR_ADJUST_ONLY' THEN
        l_adjust_flag := p_page_parameter_tbl(i).parameter_value;
      END IF;
    END LOOP;
END IF;

-- l_adjust_flag variable holds Y when drilled from Adjustments column

IF l_adjust_flag <> 'Y' THEN
   l_trx_sql :=
	     'SELECT  ''ENTRY'' LOOKUP_CODE,
			amount_due_original_trx FII_AR_TRAN_AMT,
			ar_creation_date FII_AR_TRAN_DATE,
			user_id USER_ID,
			:CUST_TRX_ID FII_AR_CUST_TRX_ID,
			NULL FII_AR_CASH_RECEIPT_ID

		FROM    fii_ar_transactions_f

		WHERE   customer_trx_id = :CUST_TRX_ID and
			filter_date <= TRUNC(sysdate) and
			class = :TRAN_CLASS

		UNION ALL

		SELECT  ''RECEIPT'' LOOKUP_CODE,
			amount_applied_trx FII_AR_TRAN_AMT,
			ar_creation_date FII_AR_TRAN_DATE,
			user_id USER_ID,
			:CUST_TRX_ID FII_AR_CUST_TRX_ID,
			CASH_RECEIPT_ID FII_AR_CASH_RECEIPT_ID

		FROM	fii_ar_receipts_f

		WHERE   applied_customer_trx_id = :CUST_TRX_ID and
			filter_date <= TRUNC(sysdate) and
			application_type = ''CASH''

		UNION ALL

		SELECT  ''CREDIT'' LOOKUP_CODE,
			amount_applied_trx FII_AR_TRAN_AMT,
			ar_creation_date FII_AR_TRAN_DATE,
			user_id USER_ID,
			:CUST_TRX_ID FII_AR_CUST_TRX_ID,
			NULL FII_AR_CASH_RECEIPT_ID

		FROM	fii_ar_receipts_f

		WHERE   '||l_trx_id_join||'
			filter_date <= TRUNC(sysdate) and
			application_type = ''CM''

		UNION ALL

		SELECT  ''DISC'' LOOKUP_CODE,
			earned_discount_amount_trx FII_AR_TRAN_AMT,
			ar_creation_date FII_AR_TRAN_DATE,
			user_id USER_ID,
			:CUST_TRX_ID FII_AR_CUST_TRX_ID,
			NULL FII_AR_CASH_RECEIPT_ID

		FROM	fii_ar_receipts_f

		WHERE   applied_customer_trx_id = :CUST_TRX_ID and
			earned_discount_amount_trx is not null and
			filter_date <= TRUNC(sysdate) and
			application_type = ''CASH''

		UNION ALL

		SELECT  ''ASSIGN'' LOOKUP_CODE,
			amount_trx FII_AR_TRAN_AMT,
			ar_creation_date FII_AR_TRAN_DATE,
		        user_id USER_ID,
			:CUST_TRX_ID FII_AR_CUST_TRX_ID,
			NULL FII_AR_CASH_RECEIPT_ID

		FROM	fii_ar_adjustments_f

		WHERE   customer_trx_id = :CUST_TRX_ID and
			filter_date <= TRUNC(sysdate) and
			adj_class = ''BR''
		UNION ALL
	      ';

END IF;

-- Report Query

sqlstmt := '
	SELECT	lookup.meaning FII_AR_ACTION,
		inline.FII_AR_TRAN_AMT FII_AR_TRAN_AMT,
		inline.FII_AR_TRAN_DATE FII_AR_TRAN_DATE,
		users.user_name FII_AR_USER,
		'||l_app_rec_drill||' FII_AR_TRAN_AMT_DRILL
	FROM (
		'||l_trx_sql||'
		SELECT ''ADJ'' LOOKUP_CODE,
			amount_trx FII_AR_TRAN_AMT,
			ar_creation_date FII_AR_TRAN_DATE,
		        user_id USER_ID,
			:CUST_TRX_ID FII_AR_CUST_TRX_ID,
			NULL FII_AR_CASH_RECEIPT_ID

		  FROM	fii_ar_adjustments_f

		 WHERE  customer_trx_id = :CUST_TRX_ID and
			filter_date <= TRUNC(sysdate) and
			NVL(adj_class,''XX'') <> ''BR''

		) inline,
		fnd_user users,
		fnd_lookup_values lookup

	WHERE	inline.user_id = users.user_id
		and lookup.lookup_type = ''FII_AR_TRX_ACTIONS''
		and lookup.lookup_code = inline.lookup_code
		and lookup.language = userenv(''LANG'')

	&ORDER_BY_CLAUSE';

fii_ar_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, trx_act_history_sql, trx_act_history_output);

END get_trx_act_history;

END FII_AR_TRX_ACT_HISTORY_PKG;

/
