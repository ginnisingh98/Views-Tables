--------------------------------------------------------
--  DDL for Package Body FII_EA_AP_INV_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_EA_AP_INV_DTL_PKG" AS
/* $Header: FIIEAINVDETB.pls 120.1 2005/07/15 08:09:15 dhmehra noship $ */

 PROCEDURE get_inv_detail
     (
	p_page_parameter_tbl	IN BIS_PMV_PAGE_PARAMETER_TBL
       ,p_invoice_detail_sql	OUT NOCOPY VARCHAR2
       ,p_invoice_detail_output	OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
     )IS


-- Local Variables Declaration

       l_sqlstmt		VARCHAR2(14000);
       l_as_of_date		DATE;
       l_operating_unit		VARCHAR2(240);
       l_supplier		VARCHAR2(240);
       l_invoice_number		NUMBER;
       l_period_type		VARCHAR2(240);
       l_record_type_id		NUMBER;
       l_view_by		VARCHAR2(240);
       l_currency		VARCHAR2(240);
       l_column_name		VARCHAR2(240);
       l_table_name		VARCHAR2(240);
       l_gid			NUMBER;
       l_org_where		VARCHAR2(240);
       l_supplier_where		VARCHAR2(240);
       l_ea_supplier_where	VARCHAR2(240);
       l_invoice_id		NUMBER;
       l_yes			VARCHAR2(240);
       l_no			VARCHAR2(240);
       l_due_date_url		VARCHAR2(1000);
       l_tran_amt_url		VARCHAR2(1000);
       l_ever_on_hold_url	VARCHAR2(1000);


 BEGIN

       FII_PMV_UTIL.get_parameters(
				    p_page_parameter_tbl
				   ,l_as_of_date
				   ,l_operating_unit
				   ,l_supplier
				   ,l_invoice_number
				   ,l_period_type
				   ,l_record_type_id
				   ,l_view_by
				   ,l_currency
				   ,l_column_name
				   ,l_table_name
				   ,l_gid
				   ,l_org_where
				   ,l_supplier_where
			           );

-- Get Invoice ID from UTIL package
	FII_PMV_UTIL.get_invoice_id(p_page_parameter_tbl, l_invoice_id);


-- Get Translated Messages for -- YES , NO
       FII_PMV_UTIL.get_yes_no_msg(l_yes, l_no);

-- UTIL package returns, l_supplier_where = f.supplier_id
-- However, Oracle Payables table,ap_invoices_all has column name, vendor_id instead.

       l_ea_supplier_where := REPLACE(l_supplier_where,'supplier_id','vendor_id');

-- Deciding URL's based on the drill column:

  l_due_date_url := 'pFunctionName=FII_AP_SCHED_PAY_DISCOUNT&FII_AP_INVOICE_ID=FII_INVOICE_ID&FII_CURRENCIES=FII_EA_TRAN_CURRENCY&pParamIds=Y';
  l_tran_amt_url := 'pFunctionName=FII_AP_INV_DIST_DETAIL&FII_AP_INVOICE_ID=FII_INVOICE_ID&FII_CURRENCIES=FII_EA_TRAN_CURRENCY&pParamIds=Y';
  l_ever_on_hold_url := 'pFunctionName=FII_AP_HOLD_HISTORY&FII_AP_INVOICE_ID=FII_INVOICE_ID&pParamIds=Y';


-- PMV SQL formation

        l_sqlstmt := '

		  SELECT TRUNC(f.invoice_date)			FII_EA_INV_DATE
			,TRUNC(f.creation_date)			FII_EA_ENTERED_DATE
			,TRUNC(MIN(pay.due_date))		FII_EA_DUE_DATE
			,f.invoice_currency_code		FII_EA_TRAN_CURRENCY
			,f.invoice_amount			FII_EA_TRAN_AMT
			,CASE WHEN COUNT(hold.hold_date) > 0
			      THEN '''||l_yes||'''
			         ELSE '''||l_no||'''
			 END						FII_EA_EVER_ON_HOLD
			,COUNT(DISTINCT aid.invoice_distribution_id)	FII_EA_DIST_LINES
			,tl.name					FII_EA_TERMS
			,f.source					FII_EA_SOURCE
			,'''||l_due_date_url||'''			FII_EA_DUE_DATE_DRILL
			,'''||l_tran_amt_url||'''			FII_EA_TRAN_AMT_DRILL
			,'''||l_ever_on_hold_url||'''			FII_EA_EVER_ON_HOLD_DRILL
	           FROM ap_invoices_all			f
		       ,ap_payment_schedules_all	pay
		       ,ap_invoice_distributions_all	aid
		       ,ap_terms_tl		        tl
		       ,ap_holds_all			hold
		  WHERE f.invoice_id =  :INVOICE_ID
		    '||l_org_where||' '||l_ea_supplier_where||'
		    AND f.invoice_id = pay.invoice_id (+)
		    AND f.invoice_id = hold.invoice_id (+)
		    AND f.cancelled_date IS NULL
		    AND f.invoice_id = aid.invoice_id (+)
-- Bug # 4491000 , Commented out following filter
-- 	            AND f.invoice_type_lookup_code NOT IN (''EXPENSE REPORT'')
		    AND f.invoice_amount <> 0
		    AND f.terms_id = tl.term_id
		    AND tl.language = USERENV(''LANG'')
	       GROUP BY f.invoice_date
		       ,f.creation_date
		       ,f.invoice_currency_code
		       ,f.invoice_amount
		       ,tl.name
		       ,f.source
		';


 --  Binding Section

      FII_PMV_UTIL.bind_variable(
				  p_sqlstmt=> l_sqlstmt
				 ,p_page_parameter_tbl=> p_page_parameter_tbl
                                 ,p_sql_output=> p_invoice_detail_sql
                                 ,p_bind_output_table=> p_invoice_detail_output
                                 ,p_invoice_number=> l_invoice_id
                                );
 END;

END FII_EA_AP_INV_DTL_PKG;

/
