--------------------------------------------------------
--  DDL for Package Body FII_AP_INV_DETAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AP_INV_DETAIL" AS
/* $Header: FIIAPD1B.pls 120.3 2005/10/12 20:09:36 vkazhipu noship $ */

-- To show the as-of-date in the report title --
FUNCTION get_report_title(
	p_page_parameter_tbl    BIS_PMV_PAGE_PARAMETER_TBL)
RETURN VARCHAR2
IS
	l_as_of_date            VARCHAR2(240);
BEGIN
   IF (p_page_parameter_tbl.count > 0) THEN
     FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP
	IF p_page_parameter_tbl(i).parameter_name = 'AS_OF_DATE' THEN
	  l_as_of_date  := p_page_parameter_tbl(i).parameter_value;
	END IF;
     END LOOP;
   END IF;
   RETURN l_as_of_date;
END get_report_title;



-- To get last_update_date for Past Due Invoices --

FUNCTION get_past_due_inv_up_date
RETURN VARCHAR2
IS
        l_last_update_date            VARCHAR2(300);
        l_date_mask                   VARCHAR2(240);

BEGIN

   FII_PMV_Util.get_format_mask(l_date_mask);

  SELECT ' ('||fnd_message.get_string('FII','FII_AP_ASOF')||' '||to_char(TRUNC(last_refresh_date),l_date_mask)||')'
  INTO l_last_update_date FROM bis_obj_properties
  WHERE object_name = 'FII_AP_CURR_TOP_PDUE' AND object_type = 'REPORT';

   RETURN l_last_update_date;

END get_past_due_inv_up_date;


--Procedure added as part of report Current Past Due Invoices

PROCEDURE get_current_top_pdue (
	p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
	inv_dtl_sql             OUT NOCOPY VARCHAR2,
	inv_dtl_output          OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
	l_viewby_dim            VARCHAR2(240);  -- the viewby selected
	l_as_of_date            DATE;
	l_organization          VARCHAR2(240);
	l_supplier              VARCHAR2(240);
	l_currency              VARCHAR2(240);
	l_viewby_id             VARCHAR2(240);  -- org_id or supplier_id
	l_viewby_string		VARCHAR2(240);
	l_record_type_id        NUMBER;         -- only possible value is 1143
	l_curr_suffix		VARCHAR2(240);
	l_org_where             VARCHAR2(240);
	l_sup_where             VARCHAR2(240);
	l_gid			NUMBER;
	sqlstmt			VARCHAR2(14000);
	l_period_type		VARCHAR2(240);
	l_invoice_number	VARCHAR2(240);
	l_invoice_amt_col	VARCHAR2(240);
	l_unpaid_amt_col	VARCHAR2(240);
	l_report_source		VARCHAR2(240);
	l_discount_lost_col	VARCHAR2(240);
	l_past_due_amt_col 	VARCHAR2(240);
	l_check_id		NUMBER := 0;
	l_url_inv_activity	VARCHAR2(1000);
	l_url_pay_discount	VARCHAR2(1000);
	l_url_hold_history	VARCHAR2(1000);
	l_url_inv_detail	VARCHAR2(1000);
	l_yes                   VARCHAR2(240);
	l_no                    VARCHAR2(240);
        l_date_mask             VARCHAR2(240);
	l_sysdate		VARCHAR2(30);

BEGIN

-- Read the parameters passed

   FII_PMV_UTIL.get_parameters(
	p_page_parameter_tbl=>p_page_parameter_tbl,
	p_as_of_date=>l_as_of_date,
	p_operating_unit=>l_organization,
	p_supplier=>l_supplier,
	p_invoice_number=>l_invoice_number,
	p_period_type=>l_period_type,
	p_record_type_id=>l_record_type_id,
	p_view_by=>l_viewby_dim,
	p_currency=>l_curr_suffix,
	p_column_name=>l_viewby_id,
	p_table_name=>l_viewby_string,
	p_gid=>l_gid,
	p_org_where=>l_org_where,
	p_supplier_where=>l_sup_where);


 IF l_curr_suffix IS NOT NULL THEN
     IF l_curr_suffix = '_prim_g' THEN
        l_invoice_amt_col := 'invoice_amt_prim_g';
        l_unpaid_amt_col := 'unpaid_amt_prim_g';
        l_past_due_amt_col := 'past_due_amt_prim_g';
        l_discount_lost_col := 'discount_lost_prim_g';
     ELSIF l_curr_suffix = '_sec_g' THEN
        l_invoice_amt_col := 'invoice_amt_sec_g';
        l_unpaid_amt_col := 'unpaid_amt_sec_g';
        l_past_due_amt_col := 'past_due_amt_sec_g';
        l_discount_lost_col :=  'discount_lost_sec_g';
     ELSE
        l_invoice_amt_col := 'invoice_amt_b';
        l_unpaid_amt_col := 'unpaid_amt_b';
        l_past_due_amt_col := 'past_due_amt_b';
        l_discount_lost_col := 'discount_lost_b';
     END IF;
  END IF;

--Added for Bug 4309974
  SELECT TO_CHAR(TRUNC(sysdate),'DD/MM/YYYY') INTO l_sysdate FROM dual;


/* url defined for the drills */
  l_url_inv_activity := 'AS_OF_DATE='||l_sysdate||'&pFunctionName=FII_AP_INV_ACTIVITY_HISTORY&pParamIds=Y&FII_INVOICE_ID=FII_INVOICE_ID&FII_INVOICE=FII_INVOICE_NUM';
  l_url_pay_discount := 'AS_OF_DATE='||l_sysdate||'&pFunctionName=FII_AP_SCHED_PAY_DISCOUNT&pParamIds=Y&FII_AP_INVOICE_ID=FII_INVOICE_ID&FII_INVOICE=FII_INVOICE_NUM';
  l_url_hold_history := 'AS_OF_DATE='||l_sysdate||'&pFunctionName=FII_AP_HOLD_HISTORY&pParamIds=Y&FII_AP_INVOICE_ID=FII_INVOICE_ID&FII_INVOICE=FII_INVOICE_NUM';
--  l_url_inv_detail:= 'AS_OF_DATE='||l_sysdate||'&pFunctionName=FII_AP_INV_DIST_DETAIL&pParamIds=Y&FII_INVOICE_ID=FII_INVOICE_ID&FII_INVOICE=FII_INVOICE_NUM';
  l_url_inv_detail:= 'AS_OF_DATE='||l_sysdate||'&pFunctionName=FII_AP_INV_LINES_DETAIL&pParamIds=Y&FII_AP_INVOICE_ID=FII_INVOICE_ID&FII_INVOICE_NUM=FII_INVOICE_NUM';

FII_PMV_Util.get_yes_no_msg(l_yes, l_no);

/*
Added the following code to replace f.org_id with org.organization_id, due to
performance consciderations to make the table table hr_all_organization_units as the
driving table in place of fii_ap_inv_b_mv in the case when only l_supplier = ALL.

The replace is not done in the case when l_supplier = 1 supplier, because it's found
during 1 supplier the performance degrades if we make  table hr_all_organization_units
as the driving table.
*/

IF l_supplier = 'All' THEN
     l_org_where := REPLACE(l_org_where,'f.org_id','org.organization_id');
END IF;

/*------------------------------------------------------+
 |							|
 |	FII_INVOICE_NUM	-	Invoice Number		|
 |	FII_INVOICE_ID	-	Invoice ID		|
 |	FII_INVOICE_TYPE-	Invoice Type		|
 |	FII_SUPPLIER	-	Supplier		|
 |	FII_OPER_UNIT	-	Operating Unit 		|
 |	FII_INVOICE_DATE-	Invoice Date		|
 |	FII_ENT_DATE	-	Entered Date		|
 |	FII_DUE_DATE	-	Due Date		|
 |	FII_DAYS_PDUE	-	Days Past Due		|
 |	FII_TRX_CURRENCY-	Tran. Currency		|
 |	FII_TRX_INVOICE_AMT-	Tran.Invoice Amt	|
 |	FII_INVOICE_AMT	-	Invoice Amount		|
 |	FII_UNPAID_AMT	-	Unpaid Amount		|
 |	FII_AMT_PDUE	-	Amount Past Due		|
 |	FII_ON_HOLD	-	On Hold			|
 |	FII_DAYS_ON_HOLD-	Days on Hold		|
 |	FII_DISC_LOST	-	Discount Lost		|
 |	FII_TERMS	-	Terms			|
 |	FII_GT_INVOICE_AMT-	Grand Total Inv. Amount |
 |	FII_GT_UNPAID_AMT -	Grand Total Unpaid Amount|
 |	FII_GT_AMT_PDUE	-	Grand Total Amt. Past Due|
 |	FII_GT_DISC_LOST-	Grand Total Discount Lost|
 |	FII_INV_ACT_HIST_URL-	URL on Invoice Number 	|
 |	FII_SCHD_PAY_URL-	URL on Due Date		|
 |	FII_HOLD_HIST_URL-	URL on On Hold		|
 |	FII_INV_DIST_URL-	URL on Tran. Inv. Amount|
+-------------------------------------------------------*/

      sqlstmt := '
SELECT
	h.FII_INVOICE_NUM	FII_INVOICE_NUM,
	h.FII_INVOICE_ID	FII_INVOICE_ID,
	h.FII_INVOICE_TYPE	FII_INVOICE_TYPE,
	SUPP.VALUE		FII_SUPPLIER,
	h.FII_OPER_UNIT		FII_OPER_UNIT,
	h.FII_INVOICE_DATE	FII_INVOICE_DATE,
	h.FII_ENT_DATE		FII_ENT_DATE,
	h.FII_DUE_DATE		FII_DUE_DATE,
	h.FII_DAYS_PDUE		FII_DAYS_PDUE,
	h.FII_TRX_CURRENCY	FII_TRX_CURRENCY,
	h.FII_TRX_INVOICE_AMT	FII_TRX_INVOICE_AMT,
	h.FII_INVOICE_AMT	FII_INVOICE_AMT,
	h.FII_UNPAID_AMT	FII_UNPAID_AMT,
	h.FII_AMT_PDUE		FII_AMT_PDUE,
	h.FII_ON_HOLD		FII_ON_HOLD,
	h.FII_DAYS_ON_HOLD	FII_DAYS_ON_HOLD,
	h.FII_DISC_LOST		FII_DISC_LOST,
	TERMS.NAME			FII_TERMS,
	h.FII_GT_INVOICE_AMT	FII_GT_INVOICE_AMT,
	h.FII_GT_UNPAID_AMT	FII_GT_UNPAID_AMT,
	h.FII_GT_AMT_PDUE	FII_GT_AMT_PDUE,
	h.FII_GT_DISC_LOST	FII_GT_DISC_LOST,
	'''||l_url_inv_activity||'''   	FII_INV_ACT_HIST_URL,
	'''||l_url_pay_discount||'''   	FII_SCHD_PAY_URL,
	'''||l_url_hold_history||'''	FII_HOLD_HIST_URL,
	'''||l_url_inv_detail||'''	FII_INV_DIST_URL
	FROM
	(
	SELECT
		g.TERMS_ID		TERMS_ID,
		g.FII_INVOICE_NUM		FII_INVOICE_NUM,
		g.FII_INVOICE_ID		FII_INVOICE_ID,
		g.FII_INVOICE_TYPE	FII_INVOICE_TYPE,
		g.SUPPLIER_ID		SUPPLIER_ID,
		g.FII_OPER_UNIT		FII_OPER_UNIT,
		g.FII_INVOICE_DATE	FII_INVOICE_DATE,
		g.FII_ENT_DATE		FII_ENT_DATE,
		g.FII_DUE_DATE		FII_DUE_DATE,
		g.FII_DAYS_PDUE		FII_DAYS_PDUE,
		g.FII_TRX_CURRENCY	FII_TRX_CURRENCY,
		g.FII_TRX_INVOICE_AMT	FII_TRX_INVOICE_AMT,
		g.FII_INVOICE_AMT	FII_INVOICE_AMT,
		g.FII_UNPAID_AMT	FII_UNPAID_AMT,
		g.FII_AMT_PDUE		FII_AMT_PDUE,
		g.FII_ON_HOLD		FII_ON_HOLD,
		g.FII_DAYS_ON_HOLD	FII_DAYS_ON_HOLD,
		g.FII_DISC_LOST		FII_DISC_LOST,
		g.FII_GT_INVOICE_AMT	FII_GT_INVOICE_AMT,
		g.FII_GT_UNPAID_AMT	FII_GT_UNPAID_AMT,
		g.FII_GT_AMT_PDUE	FII_GT_AMT_PDUE,
		g.FII_GT_DISC_LOST	FII_GT_DISC_LOST,
		(rank () over(&ORDER_BY_CLAUSE nulls last,g.FII_INVOICE_ID)) -1 rnk
	FROM
	(SELECT f.terms_id					TERMS_ID,
	       f.invoice_number					FII_INVOICE_NUM,
	       f.invoice_id					FII_INVOICE_ID,
	       f.invoice_type					FII_INVOICE_TYPE,
 	       f.supplier_id 					SUPPLIER_ID,
	       org.name 					FII_OPER_UNIT,
	       f.invoice_date					FII_INVOICE_DATE,
	       f.entered_date					FII_ENT_DATE,
	       f.due_date					FII_DUE_DATE,
	       f.days_past_due					FII_DAYS_PDUE,
	       f.trx_currency_code				FII_TRX_CURRENCY,
	       f.invoice_amt_t					FII_TRX_INVOICE_AMT,
	       f.'||l_invoice_amt_col||'			FII_INVOICE_AMT,
	       f.'||l_unpaid_amt_col||'				FII_UNPAID_AMT,
	       f.'||l_past_due_amt_col||'			FII_AMT_PDUE,
	       decode(nvl(f.on_hold, ''N''), ''Y'', '''||l_yes||''', ''N'','''||l_no||''')  	FII_ON_HOLD,
	       nvl(f.days_on_hold,0)				FII_DAYS_ON_HOLD,
	       f.'||l_discount_lost_col||'			FII_DISC_LOST,
	       SUM(f.'||l_invoice_amt_col||') OVER()		FII_GT_INVOICE_AMT,
	       SUM(f.'||l_unpaid_amt_col||') OVER()		FII_GT_UNPAID_AMT,
	       SUM(f.'||l_past_due_amt_col||') OVER()		FII_GT_AMT_PDUE,
	       SUM(f.'||l_discount_lost_col||') OVER()		FII_GT_DISC_LOST
	   FROM
	   FII_AP_INV_B_MV f, hr_all_organization_units org
	   WHERE f.org_id=org.organization_id
	   '||l_org_where||' '||l_sup_where||'
	) g
	) h,  ap_terms_tl terms, poa_suppliers_v supp
      WHERE h.terms_id = terms.term_id
   	AND terms.language = userenv(''LANG'')
   	AND h.supplier_id = supp.id
      	AND	(rnk BETWEEN &START_INDEX AND &END_INDEX or &END_INDEX = -1)
		 &ORDER_BY_CLAUSE
		';

-- Attach bind parameters
  FII_PMV_UTIL.bind_variable(
	p_sqlstmt=>sqlstmt,
	p_page_parameter_tbl=>p_page_parameter_tbl,
	p_sql_output=>inv_dtl_sql,
	p_bind_output_table=>inv_dtl_output);

END get_current_top_pdue;


-- For the Invoice Detail report --
PROCEDURE get_inv_detail (
	p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
	inv_dtl_sql             OUT NOCOPY VARCHAR2,
	inv_dtl_output          OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
	l_viewby_dim            VARCHAR2(240);  -- the viewby selected
	l_as_of_date            DATE;
	l_organization          VARCHAR2(240);
	l_supplier              VARCHAR2(240);
	l_currency              VARCHAR2(240);
	l_viewby_id             VARCHAR2(240);  -- org_id or supplier_id
	l_viewby_string		VARCHAR2(240);
	l_record_type_id        NUMBER;         -- only possible value is 1143
	l_curr_suffix		VARCHAR2(240);
	l_org_where             VARCHAR2(240);
	l_sup_where             VARCHAR2(240);
	l_gid			NUMBER;
	sqlstmt			VARCHAR2(14000);
	l_period_type		VARCHAR2(240);
	l_invoice_number	VARCHAR2(240);
	l_invoice_amt_col	VARCHAR2(240);
	l_unpaid_amt_col	VARCHAR2(240);
	l_report_source		VARCHAR2(240);
	l_discount_offered	VARCHAR2(240);
	l_discount_lost		VARCHAR2(240);
	l_discount_taken	VARCHAR2(240);
	l_discount_available	VARCHAR2(240);
	l_check_id		NUMBER := 0;
	l_url_1			VARCHAR2(1000);
	l_url_2			VARCHAR2(1000);
	l_url_3			VARCHAR2(1000);
	l_url_4			VARCHAR2(1000);
	l_yes                   VARCHAR2(240);
	l_no                    VARCHAR2(240);
        l_date_mask             VARCHAR2(240);
	l_sysdate               VARCHAR2(30);
BEGIN

-- Read the parameters passed
  FII_PMV_UTIL.get_parameters(
	p_page_parameter_tbl=>p_page_parameter_tbl,
	p_as_of_date=>l_as_of_date,
	p_operating_unit=>l_organization,
	p_supplier=>l_supplier,
	p_invoice_number=>l_invoice_number,
	p_period_type=>l_period_type,
	p_record_type_id=>l_record_type_id,
	p_view_by=>l_viewby_dim,
	p_currency=>l_curr_suffix,
	p_column_name=>l_viewby_id,
	p_table_name=>l_viewby_string,
	p_gid=>l_gid,
	p_org_where=>l_org_where,
	p_supplier_where=>l_sup_where);


  IF (p_page_parameter_tbl.count > 0) THEN
     FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP
	  IF p_page_parameter_tbl(i).parameter_name = 'CURRENCY+FII_CURRENCIES'
	  THEN
		l_currency := p_page_parameter_tbl(i).parameter_id;
	  END IF;
     END LOOP;
  END IF;


  FII_PMV_UTIL.get_report_source (
	p_page_parameter_tbl=>p_page_parameter_tbl,
	p_report_source=>l_report_source);

  l_record_type_id := 1143;	-- no other value possible in this report
  l_discount_offered	:=  FII_PMV_UTIL.get_base_curr_colname(l_curr_suffix, 'discount_offered');
  l_discount_lost	:=  FII_PMV_UTIL.get_base_curr_colname(l_curr_suffix, 'discount_lost');
  l_discount_taken	:=  FII_PMV_UTIL.get_base_curr_colname(l_curr_suffix, 'discount_taken');
  l_discount_available	:=  FII_PMV_UTIL.get_base_curr_colname(l_curr_suffix, 'discount_available');

  IF l_curr_suffix IS NOT NULL THEN
     IF l_curr_suffix = '_prim_g' THEN
	l_invoice_amt_col := 'prim_amount';
	l_unpaid_amt_col := 'prim_amount_remaining';
     ELSIF l_curr_suffix = '_sec_g' THEN
	l_invoice_amt_col := 'sec_amount';
	l_unpaid_amt_col := 'sec_amount_remaining';
     ELSE
	l_invoice_amt_col := 'base_amount';
	l_unpaid_amt_col := 'amount_remaining_b';
     END IF;
  END IF;

  FII_PMV_UTIL.get_check_id(p_page_parameter_tbl, l_check_id);

  --Added for Bug 4309974
  SELECT TO_CHAR(TRUNC(sysdate),'DD/MM/YYYY') INTO l_sysdate FROM dual;

  l_url_1 := 'AS_OF_DATE='||l_sysdate||'&pFunctionName=FII_AP_INV_ACTIVITY_HISTORY&pParamIds=Y&FII_INVOICE_ID=FII_MEASURE2&FII_INVOICE=FII_MEASURE1';
  l_url_2 := 'AS_OF_DATE='||l_sysdate||'&pFunctionName=FII_AP_SCHED_PAY_DISCOUNT&pParamIds=Y&FII_AP_INVOICE_ID=FII_MEASURE2&FII_INVOICE=FII_MEASURE1';
  l_url_3 := 'AS_OF_DATE='||l_sysdate||'&pFunctionName=FII_AP_HOLD_HISTORY&pParamIds=Y&FII_AP_INVOICE_ID=FII_MEASURE2&FII_INVOICE=FII_MEASURE1';
--  l_url_4 := 'AS_OF_DATE='||l_sysdate||'&pFunctionName=FII_AP_INV_DIST_DETAIL&pParamIds=Y&FII_INVOICE_ID=FII_MEASURE2&FII_INVOICE=FII_MEASURE1';
  l_url_4 := 'AS_OF_DATE='||l_sysdate||'&pFunctionName=FII_AP_INV_LINES_DETAIL&pParamIds=Y&FII_AP_INVOICE_ID=FII_MEASURE2&FII_INVOICE_NUM=FII_MEASURE1';
FII_PMV_Util.get_yes_no_msg(l_yes, l_no);
FII_PMV_Util.get_format_mask(l_date_mask);

/*--------------------------------------------------------------+
 |      FII_MEASURE1    - Invoice Number			|
 |      FII_MEASURE2    - Invoice ID				|
 |      FII_MEASURE3    - Invoice Type				|
 |      FII_MEASURE4    - Invoice Date				|
 |      FII_MEASURE5    - Entered Date				|
 |      FII_MEASURE6    - Due Date				|
 |      FII_MEASURE7    - Transaction Currency Code		|
 |      FII_MEASURE8    - Transaction invoice Amount		|
 |	FII_MEASURE9	- Invoice Amount			|
 |	FII_MEASURE10	- Unpaid Amount				|
 |	FII_MEASURE11	- On Hold				|
 |	FII_MEASURE12	- Days on Hold				|
 |	FII_MEASURE13	- Discount Offered			|
 |	FII_MEASURE14	- Discount Taken			|
 |	FII_MEASURE15	- Discount Lost				|
 |	FII_MEASURE16	- Discount Remaining			|
 |	FII_MEASURE17	- Terms					|
 |	FII_MEASURE18	- Source				|
 |	FII_MEASURE[21-27] - Grand Total columns		|
 |	FII_ATTRIBUTE[10-13] - Drill columns			|
 +--------------------------------------------------------------*/



/*Changes made for version 115.35 include
 1. Removed the WITHHOLDING logic from all reports. Earlier Due date was not populated
    for the invoice.Now the withholding action carries a due date as part of
    enhancement 3065476 .
 2. Changed the logic for due detail reports .Removed the +1 day logic implemented
    earlier.
 3. Made changes as part of impact of  enhancement 3065413.
 */

/* Changes made during Performance tuning + enhancement for Days on Hold

1. Removed period_type_id = 1 from all the reports
2. Implemented the Start and End index logic to support Windowed mode for all reports
3. Using fii_ap_inv_holds_b to return on hold on the As of date
4. Using fii_ap_hhist_ib_mv to return days on hold .
5. Changed the driving tables to maximise the use of index (driving table now is fii_ap_invoice_b)
6. Cleaned up the commented part of code not being used (as fix for some bug) eg.
    Removed the commented line
        sum(base.base_amount) over()				FII_MEASURE21 ,
7. Made use of the same Measure name as being passed to AK in the inner query
8. Moved the urls to top level .
9. In AK for FII_AP_INV_DETAIL,changed the no.of display rows to -30 and
      Number of rows per portlet to -10

*/


-- Construct the query to be sent

  CASE l_report_source

    WHEN 'FII_AP_UNPAID_INV_DETAIL' THEN  -- 1st, Unpaid Invoices Detail
      sqlstmt := '
SELECT
	h.FII_MEASURE1 FII_MEASURE1,
	h.FII_MEASURE2 FII_MEASURE2,
	h.FII_MEASURE3 FII_MEASURE3,
	h.FII_MEASURE4 FII_MEASURE4,
	h.FII_MEASURE5 FII_MEASURE5,
	h.FII_MEASURE6 FII_MEASURE6,
	h.FII_MEASURE7 FII_MEASURE7,
	h.FII_MEASURE8 FII_MEASURE8,
	h.FII_MEASURE9 FII_MEASURE9,
	h.FII_MEASURE10  FII_MEASURE10,
	h.FII_MEASURE11 FII_MEASURE11,
	h.FII_MEASURE12 FII_MEASURE12,
	h.FII_MEASURE13 FII_MEASURE13,
	h.FII_MEASURE14 FII_MEASURE14,
	h.FII_MEASURE15 FII_MEASURE15,
	h.FII_MEASURE16 FII_MEASURE16,
	h.FII_MEASURE17 FII_MEASURE17,
	h.FII_MEASURE18 FII_MEASURE18,
	h.FII_MEASURE21 FII_MEASURE21,
	h.FII_MEASURE22 FII_MEASURE22,
	h.FII_MEASURE23 FII_MEASURE23,
	h.FII_MEASURE24 FII_MEASURE24,
	h.FII_MEASURE25 FII_MEASURE25,
	h.FII_MEASURE26 FII_MEASURE26,
	h.FII_MEASURE27 FII_MEASURE27,
	'''||l_url_1||'''     FII_ATTRIBUTE10,
	'''||l_url_2||'''     FII_ATTRIBUTE11,
	'''||l_url_3||'''	FII_ATTRIBUTE12,
	'''||l_url_4||'''	FII_ATTRIBUTE13

	FROM
	(
	SELECT
		g.FII_MEASURE1 FII_MEASURE1,
		g.FII_MEASURE2 FII_MEASURE2,
		g.FII_MEASURE3 FII_MEASURE3,
		g.FII_MEASURE4 FII_MEASURE4,
		g.FII_MEASURE5 FII_MEASURE5,
		g.FII_MEASURE6 FII_MEASURE6,
		g.FII_MEASURE7 FII_MEASURE7,
		g.FII_MEASURE8 FII_MEASURE8,
		g.FII_MEASURE9 FII_MEASURE9,
		g.FII_MEASURE10  FII_MEASURE10,
		g.FII_MEASURE11 FII_MEASURE11,
		g.FII_MEASURE12 FII_MEASURE12,
		g.FII_MEASURE13 FII_MEASURE13,
		g.FII_MEASURE14 FII_MEASURE14,
		g.FII_MEASURE15 FII_MEASURE15,
		g.FII_MEASURE16 FII_MEASURE16,
		g.FII_MEASURE17 FII_MEASURE17,
		g.FII_MEASURE18 FII_MEASURE18,
		g.FII_MEASURE21 FII_MEASURE21,
		g.FII_MEASURE22 FII_MEASURE22,
		g.FII_MEASURE23 FII_MEASURE23,
		g.FII_MEASURE24 FII_MEASURE24,
		g.FII_MEASURE25 FII_MEASURE25,
		g.FII_MEASURE26 FII_MEASURE26,
		g.FII_MEASURE27 FII_MEASURE27,
		(rank () over(&ORDER_BY_CLAUSE nulls last,g.FII_MEASURE2)) -1 rnk
	FROM

	(SELECT	f.invoice_number						FII_MEASURE1,
		f.invoice_id							FII_MEASURE2,
		f.invoice_type							FII_MEASURE3,
		to_char(f.invoice_date, '''||l_date_mask||''')  		FII_MEASURE4,
		f.entered_date  						FII_MEASURE5, -- Bug #4266826
		MIN(fpay.due_date)  						FII_MEASURE6, -- Bug #4266826
		f.invoice_currency_code						FII_MEASURE7,
		f.invoice_amount						FII_MEASURE8,
		f.'||l_invoice_amt_col||'					FII_MEASURE9,
		sum(fpay.'||l_unpaid_amt_col||')				FII_MEASURE10,
		decode(nvl(hold.FII_MEASURE11, ''N''), ''Y'', '''||l_yes||''', ''N'','''||l_no||''')   FII_MEASURE11,
		nvl(hold1.FII_MEASURE12,0)					FII_MEASURE12,
		f.'||l_discount_offered||'					FII_MEASURE13,
		SUM(fpay.'||l_discount_taken||')				FII_MEASURE14,
		SUM(fpay.'||l_discount_lost||')					FII_MEASURE15,
		SUM(fpay.'||l_discount_available||') 				FII_MEASURE16,
		t.name								FII_MEASURE17,
		f.source							FII_MEASURE18,
                to_number(null) 						FII_MEASURE21,
		SUM(f.'||l_invoice_amt_col||') OVER()				FII_MEASURE22,
		SUM(SUM(fpay.'||l_unpaid_amt_col||')) OVER()			FII_MEASURE23,
		SUM(f.'||l_discount_offered||') OVER()				FII_MEASURE24,
		SUM(SUM(fpay.'||l_discount_taken||')) OVER()			FII_MEASURE25,
		SUM(SUM(fpay.'||l_discount_lost||')) OVER()			FII_MEASURE26,
		SUM(SUM(fpay.'||l_discount_available||')) OVER()		FII_MEASURE27
	FROM fii_ap_invoice_b    		f,
	         fii_ap_pay_sched_b		fpay,
	         ap_terms_tl			t,
	       (
	       SELECT	f.invoice_id,
				''Y''     FII_MEASURE11
	       FROM   fii_ap_inv_holds_b f
	       WHERE  ( f.release_date > &BIS_CURRENT_ASOF_DATE OR f.release_date is null)
               AND     f.hold_date <= &BIS_CURRENT_ASOF_DATE
		          '||l_org_where||' '||l_sup_where|| '
               GROUP BY  invoice_id
              ) hold,
              (SELECT f.invoice_id,
                        SUM(days_on_hold) FII_MEASURE12
            FROM    fii_ap_hhist_ib_mv f
            WHERE 1 = 1
            '||l_org_where||' '||l_sup_where|| '
            GROUP BY invoice_id
              ) hold1
	WHERE      f.entered_Date<= &BIS_CURRENT_ASOF_DATE                   /*added for bug no.3054524*/
		   '||l_org_where||' '||l_sup_where||'
       	AND	   fpay.action_date <= &BIS_CURRENT_ASOF_DATE		     /*added for bug no.3114633*/
        AND        fpay.action <> ''PREPAYMENT''
	AND	   t.term_id = f.terms_id
	AND	   t.language = userenv(''LANG'')
	AND	   f.cancel_flag = ''N''
	AND	   ( f.fully_paid_date > &BIS_CURRENT_ASOF_DATE or f.fully_paid_date is null)
	AND	   f.invoice_id = fpay.invoice_id
	AND	   f.invoice_id = hold.invoice_id(+)
	AND	   f.invoice_id = hold1.invoice_id(+)
	HAVING SUM(fpay.amount_remaining) <> 0				     /* bug # 3191403*/
	GROUP BY  f.invoice_number,
		  f.invoice_id,
		  f.invoice_type,
		  f.invoice_date,
		  f.entered_date,
		  f.invoice_currency_code,
		  f.invoice_amount,
		  f.'||l_invoice_amt_col||',
		  hold.FII_MEASURE11,
		  hold1.FII_MEASURE12,
		  f.'||l_discount_offered||',
		  t.name,
		  f.source) g ) h
       WHERE (rnk BETWEEN &START_INDEX AND &END_INDEX or &END_INDEX = -1)
		  &ORDER_BY_CLAUSE
		  ';



/*added logic base.entered_Date<&BIS_CURRENT_ASOF_DATE
                      for Bug no.3054524 in Unpaid Invoices,
 		        Invoices Due Detail repts */
/* Added logic in Invoice due detail report to include
			witholding amt in unpaid invoices for
			bug no 3055143	*/

    WHEN 'FII_AP_UNPAID_INV_DUE' THEN  -- 2nd, Invoices Due Detail
      sqlstmt := '
SELECT
	h.FII_MEASURE1 FII_MEASURE1,
	h.FII_MEASURE2 FII_MEASURE2,
	h.FII_MEASURE3 FII_MEASURE3,
	h.FII_MEASURE4 FII_MEASURE4,
	h.FII_MEASURE5 FII_MEASURE5,
	h.FII_MEASURE6 FII_MEASURE6,
	h.FII_MEASURE7 FII_MEASURE7,
	h.FII_MEASURE8 FII_MEASURE8,
	h.FII_MEASURE9 FII_MEASURE9,
	h.FII_MEASURE10  FII_MEASURE10,
	h.FII_MEASURE11 FII_MEASURE11,
	h.FII_MEASURE12 FII_MEASURE12,
	h.FII_MEASURE13 FII_MEASURE13,
	h.FII_MEASURE14 FII_MEASURE14,
	h.FII_MEASURE15 FII_MEASURE15,
	h.FII_MEASURE16 FII_MEASURE16,
	h.FII_MEASURE17 FII_MEASURE17,
	h.FII_MEASURE18 FII_MEASURE18,
	h.FII_MEASURE21 FII_MEASURE21,
	h.FII_MEASURE22 FII_MEASURE22,
	h.FII_MEASURE23 FII_MEASURE23,
	h.FII_MEASURE24 FII_MEASURE24,
	h.FII_MEASURE25 FII_MEASURE25,
	h.FII_MEASURE26 FII_MEASURE26,
	h.FII_MEASURE27 FII_MEASURE27,
	'''||l_url_1||'''     FII_ATTRIBUTE10,
	'''||l_url_2||'''     FII_ATTRIBUTE11,
	'''||l_url_3||'''	FII_ATTRIBUTE12,
	'''||l_url_4||'''	FII_ATTRIBUTE13

	FROM
	(
	SELECT
		g.FII_MEASURE1 FII_MEASURE1,
		g.FII_MEASURE2 FII_MEASURE2,
		g.FII_MEASURE3 FII_MEASURE3,
		g.FII_MEASURE4 FII_MEASURE4,
		g.FII_MEASURE5 FII_MEASURE5,
		g.FII_MEASURE6 FII_MEASURE6,
		g.FII_MEASURE7 FII_MEASURE7,
		g.FII_MEASURE8 FII_MEASURE8,
		g.FII_MEASURE9 FII_MEASURE9,
		g.FII_MEASURE10  FII_MEASURE10,
		g.FII_MEASURE11 FII_MEASURE11,
		g.FII_MEASURE12 FII_MEASURE12,
		g.FII_MEASURE13 FII_MEASURE13,
		g.FII_MEASURE14 FII_MEASURE14,
		g.FII_MEASURE15 FII_MEASURE15,
		g.FII_MEASURE16 FII_MEASURE16,
		g.FII_MEASURE17 FII_MEASURE17,
		g.FII_MEASURE18 FII_MEASURE18,
		g.FII_MEASURE21 FII_MEASURE21,
		g.FII_MEASURE22 FII_MEASURE22,
		g.FII_MEASURE23 FII_MEASURE23,
		g.FII_MEASURE24 FII_MEASURE24,
		g.FII_MEASURE25 FII_MEASURE25,
		g.FII_MEASURE26 FII_MEASURE26,
		g.FII_MEASURE27 FII_MEASURE27,
		(rank () over(&ORDER_BY_CLAUSE nulls last,g.FII_MEASURE2)) -1 rnk
	FROM

	(SELECT f.invoice_number						FII_MEASURE1,
	       f.invoice_id						FII_MEASURE2,
	       f.invoice_type						FII_MEASURE3,
	       to_char(f.invoice_date, '''||l_date_mask||''')  		FII_MEASURE4,
	       f.entered_date 						FII_MEASURE5, -- Bug #4266826
	       MIN(fpay.due_date)  					FII_MEASURE6, -- Bug #4266826
	       f.invoice_currency_code					FII_MEASURE7,
	       f.invoice_amount						FII_MEASURE8,
	       f.'||l_invoice_amt_col||'				FII_MEASURE9,
	       sum(fpay.'||l_unpaid_amt_col||')				FII_MEASURE10,
	       decode(nvl(hold.FII_MEASURE11, ''N''), ''Y'', '''||l_yes||''', ''N'','''||l_no||''')   FII_MEASURE11,
	       nvl(hold1.FII_MEASURE12,0)				FII_MEASURE12,
	       f.'||l_discount_offered||'				FII_MEASURE13,
	       SUM(fpay.'||l_discount_taken||')				FII_MEASURE14,
	       SUM(fpay.'||l_discount_lost||')				FII_MEASURE15,
	       SUM(fpay.'||l_discount_available||') 			FII_MEASURE16,
		t.name							FII_MEASURE17,
	        f.source						FII_MEASURE18,
		to_number(null)         				FII_MEASURE21,
		SUM(f.'||l_invoice_amt_col||') OVER()			FII_MEASURE22,
		SUM(sum(fpay.'||l_unpaid_amt_col||')) OVER()		FII_MEASURE23,
		SUM(f.'||l_discount_offered||') OVER()			FII_MEASURE24,
		SUM(SUM(fpay.'||l_discount_taken||')) OVER()		FII_MEASURE25,
		SUM(SUM(fpay.'||l_discount_lost||')) OVER()		FII_MEASURE26,
		SUM(SUM(fpay.'||l_discount_available||')) OVER()	FII_MEASURE27
	FROM  fii_ap_invoice_b			f,
	      fii_ap_pay_sched_b		fpay,
	      ap_terms_tl			t,
	    (
	       SELECT	f.invoice_id,
			''Y''     FII_MEASURE11
	       FROM   fii_ap_inv_holds_b f
	       WHERE ( f.release_date > &BIS_CURRENT_ASOF_DATE OR f.release_date is null)
               AND     f.hold_date <= &BIS_CURRENT_ASOF_DATE
		          '||l_org_where||' '||l_sup_where|| '
               GROUP BY  invoice_id
              ) hold,
              (SELECT	f.invoice_id,
                        SUM(days_on_hold) FII_MEASURE12
            FROM    fii_ap_hhist_ib_mv f
            WHERE 1 = 1
            '||l_org_where||' '||l_sup_where|| '
            GROUP BY invoice_id
              ) hold1
	WHERE fpay.due_date >= &BIS_CURRENT_ASOF_DATE
	AND f.entered_Date<=&BIS_CURRENT_ASOF_DATE								  /*added for bug no.3054524*/
	AND fpay.action_date <= &BIS_CURRENT_ASOF_DATE								  /*added for bug no.3114633*/
        AND        fpay.action <> ''PREPAYMENT''
	'||l_org_where||' '||l_sup_where||'
	AND t.term_id = f.terms_id
	AND t.language = userenv(''LANG'')
	AND (f.fully_paid_date > &BIS_CURRENT_ASOF_DATE OR f.fully_paid_date IS NULL)
	AND f.invoice_id = fpay.invoice_id
	AND f.cancel_flag = ''N''
	AND  f.invoice_id =hold.invoice_id (+)
	AND  f.invoice_id =hold1.invoice_id (+)
	HAVING SUM(fpay.amount_remaining) <> 0									  /* bug # 3191403*/
	GROUP BY f.invoice_number,
	         f.invoice_id,
	         f.invoice_type,
	         f.invoice_date,
        	 f.entered_date,
	         f.invoice_currency_code,
	         f.invoice_amount,
	         f.'||l_invoice_amt_col||',
	         hold.FII_MEASURE11,
	         hold1.FII_MEASURE12,
	         f.'||l_discount_offered||',
	         t.name,
        	 f.source) g ) h
       WHERE (rnk BETWEEN &START_INDEX AND &END_INDEX or &END_INDEX = -1)
		  &ORDER_BY_CLAUSE
		 ';

/*added logic base.entered_Date<&BIS_CURRENT_ASOF_DATE
                      for Bug no.3054524 in Invoices Past Due Detail repts */
/* Added logic in Invoice past due detail report to include
			witholding amt in unpaid invoices for
			bug no 3055143	*/
    WHEN 'FII_AP_UNPAID_INV_PAST_DUE' THEN  -- 3rd, Invoices Past Due Detail
      sqlstmt := '
SELECT
	h.FII_MEASURE1 FII_MEASURE1,
	h.FII_MEASURE2 FII_MEASURE2,
	h.FII_MEASURE3 FII_MEASURE3,
	h.FII_MEASURE4 FII_MEASURE4,
	h.FII_MEASURE5 FII_MEASURE5,
	h.FII_MEASURE6 FII_MEASURE6,
	h.FII_MEASURE7 FII_MEASURE7,
	h.FII_MEASURE8 FII_MEASURE8,
	h.FII_MEASURE9 FII_MEASURE9,
	h.FII_MEASURE10  FII_MEASURE10,
	h.FII_MEASURE11 FII_MEASURE11,
	h.FII_MEASURE12 FII_MEASURE12,
	h.FII_MEASURE13 FII_MEASURE13,
	h.FII_MEASURE14 FII_MEASURE14,
	h.FII_MEASURE15 FII_MEASURE15,
	h.FII_MEASURE16 FII_MEASURE16,
	h.FII_MEASURE17 FII_MEASURE17,
	h.FII_MEASURE18 FII_MEASURE18,
	h.FII_MEASURE21 FII_MEASURE21,
	h.FII_MEASURE22 FII_MEASURE22,
	h.FII_MEASURE23 FII_MEASURE23,
	h.FII_MEASURE24 FII_MEASURE24,
	h.FII_MEASURE25 FII_MEASURE25,
	h.FII_MEASURE26 FII_MEASURE26,
	h.FII_MEASURE27 FII_MEASURE27,
	'''||l_url_1||'''     FII_ATTRIBUTE10,
	'''||l_url_2||'''     FII_ATTRIBUTE11,
	'''||l_url_3||'''	FII_ATTRIBUTE12,
	'''||l_url_4||'''	FII_ATTRIBUTE13

	FROM
	(
	SELECT
		g.FII_MEASURE1 FII_MEASURE1,
		g.FII_MEASURE2 FII_MEASURE2,
		g.FII_MEASURE3 FII_MEASURE3,
		g.FII_MEASURE4 FII_MEASURE4,
		g.FII_MEASURE5 FII_MEASURE5,
		g.FII_MEASURE6 FII_MEASURE6,
		g.FII_MEASURE7 FII_MEASURE7,
		g.FII_MEASURE8 FII_MEASURE8,
		g.FII_MEASURE9 FII_MEASURE9,
		g.FII_MEASURE10  FII_MEASURE10,
		g.FII_MEASURE11 FII_MEASURE11,
		g.FII_MEASURE12 FII_MEASURE12,
		g.FII_MEASURE13 FII_MEASURE13,
		g.FII_MEASURE14 FII_MEASURE14,
		g.FII_MEASURE15 FII_MEASURE15,
		g.FII_MEASURE16 FII_MEASURE16,
		g.FII_MEASURE17 FII_MEASURE17,
		g.FII_MEASURE18 FII_MEASURE18,
		g.FII_MEASURE21 FII_MEASURE21,
		g.FII_MEASURE22 FII_MEASURE22,
		g.FII_MEASURE23 FII_MEASURE23,
		g.FII_MEASURE24 FII_MEASURE24,
		g.FII_MEASURE25 FII_MEASURE25,
		g.FII_MEASURE26 FII_MEASURE26,
		g.FII_MEASURE27 FII_MEASURE27,
		(rank () over(&ORDER_BY_CLAUSE nulls last,g.FII_MEASURE2)) -1 rnk
	FROM

	(SELECT f.invoice_number							FII_MEASURE1,
	       f.invoice_id							FII_MEASURE2,
	       f.invoice_type							FII_MEASURE3,
	       to_char(f.invoice_date, '''||l_date_mask||''')			FII_MEASURE4,
	       f.entered_date							FII_MEASURE5, -- Bug #4266826
	       MIN(fpay.due_date)						FII_MEASURE6, -- Bug #4266826
	       f.invoice_currency_code						FII_MEASURE7,
	       f.invoice_amount							FII_MEASURE8,
	       f.'||l_invoice_amt_col||'					FII_MEASURE9,
	       sum(fpay.'||l_unpaid_amt_col||')					FII_MEASURE10,
	       decode(nvl(hold.FII_MEASURE11, ''N''), ''Y'', '''||l_yes||''', ''N'','''||l_no||''')   FII_MEASURE11,
	       nvl(hold1.FII_MEASURE12,0)					FII_MEASURE12,
	       f.'||l_discount_offered||'					FII_MEASURE13,
	       SUM(fpay.'||l_discount_taken||')					FII_MEASURE14,
	       SUM(fpay.'||l_discount_lost||')					FII_MEASURE15,
	       SUM(fpay.'||l_discount_available||') 				FII_MEASURE16,
		t.name								FII_MEASURE17,
	        f.source							FII_MEASURE18,
		to_number(null)         					FII_MEASURE21,
		SUM(f.'||l_invoice_amt_col||') OVER()				FII_MEASURE22,
		SUM(sum(fpay.'||l_unpaid_amt_col||')) OVER()			FII_MEASURE23,
		SUM(f.'||l_discount_offered||') OVER()				FII_MEASURE24,
		SUM(SUM(fpay.'||l_discount_taken||')) OVER()			FII_MEASURE25,
		SUM(SUM(fpay.'||l_discount_lost||')) OVER()			FII_MEASURE26,
		SUM(SUM(fpay.'||l_discount_available||')) OVER()		FII_MEASURE27
	FROM fii_ap_invoice_b		f,
	     fii_ap_pay_sched_b		fpay,
	     ap_terms_tl		t,
		(
	       SELECT	f.invoice_id,
				''Y''     FII_MEASURE11
	       FROM   fii_ap_inv_holds_b f
	       WHERE ( f.release_date > &BIS_CURRENT_ASOF_DATE OR f.release_date is null)
               AND     f.hold_date <= &BIS_CURRENT_ASOF_DATE
		          '||l_org_where||' '||l_sup_where|| '
               GROUP BY  invoice_id
                ) hold,
                (SELECT f.invoice_id,
                        SUM(days_on_hold) FII_MEASURE12
                 FROM    fii_ap_hhist_ib_mv f
                 WHERE 1 = 1
                 '||l_org_where||' '||l_sup_where|| '
                 GROUP BY invoice_id
                ) hold1
	WHERE fpay.due_date < &BIS_CURRENT_ASOF_DATE
	AND f.entered_Date<=&BIS_CURRENT_ASOF_DATE        /*added for bug no.3054524*/
	AND fpay.action_date <= &BIS_CURRENT_ASOF_DATE       /*added for bug no.3114633*/
        AND        fpay.action <> ''PREPAYMENT''
	'||l_org_where||' '||l_sup_where||'
	AND t.term_id = f.terms_id
	AND t.language = userenv(''LANG'')
	AND ( f.fully_paid_date > &BIS_CURRENT_ASOF_DATE OR f.fully_paid_date is null )
	AND f.invoice_id = fpay.invoice_id
	AND f.cancel_flag = ''N''
	AND  f.invoice_id =hold.invoice_id (+)
	AND  f.invoice_id =hold1.invoice_id (+)
--	HAVING sum(fpay.'||l_unpaid_amt_col||') <> 0 /* bug # 3129815*/
	HAVING sum(fpay.amount_remaining) <> 0       /* bug # 3191403*/
	GROUP BY f.invoice_number,
	         f.invoice_id,
	         f.invoice_type,
	         f.invoice_date,
	         f.entered_date,
	         f.invoice_currency_code,
	         f.invoice_amount,
	         f.'||l_invoice_amt_col||',
	         hold.FII_MEASURE11,
	         hold1.FII_MEASURE12,
	         f.'||l_discount_offered||',
	         t.name,
	         f.source) g ) h
       WHERE (rnk BETWEEN &START_INDEX AND &END_INDEX or &END_INDEX = -1)
		  &ORDER_BY_CLAUSE
		';


    WHEN 'FII_AP_DUE_BUCKET1_INV_DETAIL' THEN  -- 4th, Invoices Due in 1-15 days
      sqlstmt := '
SELECT
	h.FII_MEASURE1 FII_MEASURE1,
	h.FII_MEASURE2 FII_MEASURE2,
	h.FII_MEASURE3 FII_MEASURE3,
	h.FII_MEASURE4 FII_MEASURE4,
	h.FII_MEASURE5 FII_MEASURE5,
	h.FII_MEASURE6 FII_MEASURE6,
	h.FII_MEASURE7 FII_MEASURE7,
	h.FII_MEASURE8 FII_MEASURE8,
	h.FII_MEASURE9 FII_MEASURE9,
	h.FII_MEASURE10  FII_MEASURE10,
	h.FII_MEASURE11 FII_MEASURE11,
	h.FII_MEASURE12 FII_MEASURE12,
	h.FII_MEASURE13 FII_MEASURE13,
	h.FII_MEASURE14 FII_MEASURE14,
	h.FII_MEASURE15 FII_MEASURE15,
	h.FII_MEASURE16 FII_MEASURE16,
	h.FII_MEASURE17 FII_MEASURE17,
	h.FII_MEASURE18 FII_MEASURE18,
	h.FII_MEASURE21 FII_MEASURE21,
	h.FII_MEASURE22 FII_MEASURE22,
	h.FII_MEASURE23 FII_MEASURE23,
	h.FII_MEASURE24 FII_MEASURE24,
	h.FII_MEASURE25 FII_MEASURE25,
	h.FII_MEASURE26 FII_MEASURE26,
	h.FII_MEASURE27 FII_MEASURE27,
	'''||l_url_1||'''     FII_ATTRIBUTE10,
	'''||l_url_2||'''     FII_ATTRIBUTE11,
	'''||l_url_3||'''	FII_ATTRIBUTE12,
	'''||l_url_4||'''	FII_ATTRIBUTE13

	FROM
	(
	SELECT
		g.FII_MEASURE1 FII_MEASURE1,
		g.FII_MEASURE2 FII_MEASURE2,
		g.FII_MEASURE3 FII_MEASURE3,
		g.FII_MEASURE4 FII_MEASURE4,
		g.FII_MEASURE5 FII_MEASURE5,
		g.FII_MEASURE6 FII_MEASURE6,
		g.FII_MEASURE7 FII_MEASURE7,
		g.FII_MEASURE8 FII_MEASURE8,
		g.FII_MEASURE9 FII_MEASURE9,
		g.FII_MEASURE10  FII_MEASURE10,
		g.FII_MEASURE11 FII_MEASURE11,
		g.FII_MEASURE12 FII_MEASURE12,
		g.FII_MEASURE13 FII_MEASURE13,
		g.FII_MEASURE14 FII_MEASURE14,
		g.FII_MEASURE15 FII_MEASURE15,
		g.FII_MEASURE16 FII_MEASURE16,
		g.FII_MEASURE17 FII_MEASURE17,
		g.FII_MEASURE18 FII_MEASURE18,
		g.FII_MEASURE21 FII_MEASURE21,
		g.FII_MEASURE22 FII_MEASURE22,
		g.FII_MEASURE23 FII_MEASURE23,
		g.FII_MEASURE24 FII_MEASURE24,
		g.FII_MEASURE25 FII_MEASURE25,
		g.FII_MEASURE26 FII_MEASURE26,
		g.FII_MEASURE27 FII_MEASURE27,
		(rank () over(&ORDER_BY_CLAUSE nulls last,g.FII_MEASURE2)) -1 rnk
	FROM

	(SELECT f.invoice_number							FII_MEASURE1,
	       f.invoice_id							FII_MEASURE2,
	       f.invoice_type							FII_MEASURE3,
	       to_char(f.invoice_date, '''||l_date_mask||''')  			FII_MEASURE4,
	       f.entered_date							FII_MEASURE5, -- Bug #4266826
               MIN(fpay.due_date)						FII_MEASURE6, -- Bug #4266826
	       f.invoice_currency_code						FII_MEASURE7,
	       f.invoice_amount							FII_MEASURE8,
	       f.'||l_invoice_amt_col||'					FII_MEASURE9,
	       sum(fpay.'||l_unpaid_amt_col||')					FII_MEASURE10,
	      decode(nvl(hold.FII_MEASURE11, ''N''), ''Y'', '''||l_yes||''', ''N'','''||l_no||''')   FII_MEASURE11,
	       nvl(hold1.FII_MEASURE12,0)					FII_MEASURE12,
	       f.'||l_discount_offered||'					FII_MEASURE13,
	       SUM(fpay.'||l_discount_taken||')					FII_MEASURE14,
	       SUM(fpay.'||l_discount_lost||')					FII_MEASURE15,
	       SUM(fpay.'||l_discount_available||')				FII_MEASURE16,
		t.name								FII_MEASURE17,
	        f.source							FII_MEASURE18,
		to_number(null)          					FII_MEASURE21,
		SUM(f.'||l_invoice_amt_col||') OVER()				FII_MEASURE22,
		SUM(sum(fpay.'||l_unpaid_amt_col||')) OVER()			FII_MEASURE23,
		SUM(f.'||l_discount_offered||') OVER()				FII_MEASURE24,
		SUM(SUM(fpay.'||l_discount_taken||')) OVER()			FII_MEASURE25,
		SUM(SUM(fpay.'||l_discount_lost||')) OVER()			FII_MEASURE26,
		SUM(SUM(fpay.'||l_discount_available||')) OVER()		FII_MEASURE27
	FROM fii_ap_invoice_b		f,
	     fii_ap_pay_sched_b		fpay,
	     ap_terms_tl		t,
	     (
	       SELECT	f.invoice_id,
				''Y''     FII_MEASURE11
	       FROM   fii_ap_inv_holds_b f
	       WHERE ( f.release_date > &BIS_CURRENT_ASOF_DATE OR f.release_date is null)
               AND     f.hold_date <= &BIS_CURRENT_ASOF_DATE
		          '||l_org_where||' '||l_sup_where|| '
               GROUP BY  invoice_id
             ) hold,
             (   SELECT f.invoice_id,
                        SUM(days_on_hold) FII_MEASURE12
                 FROM    fii_ap_hhist_ib_mv f
                 WHERE 1 = 1
                 '||l_org_where||' '||l_sup_where|| '
                 GROUP BY invoice_id
             ) hold1
	WHERE (fpay.due_date - &BIS_CURRENT_ASOF_DATE ) BETWEEN 0 AND 15
	AND f.entered_Date<=&BIS_CURRENT_ASOF_DATE				/*added for bug no.3054524*/
	AND fpay.action_date <= &BIS_CURRENT_ASOF_DATE				/*added for bug no.3114633*/
        AND        fpay.action <> ''PREPAYMENT''
	'||l_org_where||' '||l_sup_where||'
	AND t.term_id = f.terms_id
	AND t.language = userenv(''LANG'')
	AND (f.fully_paid_date > &BIS_CURRENT_ASOF_DATE OR f.fully_paid_date is null )
	AND f.invoice_id = fpay.invoice_id
	AND f.cancel_flag = ''N''
	AND  f.invoice_id =hold.invoice_id (+)
	AND  f.invoice_id =hold1.invoice_id (+)
--	HAVING sum(fpay.'||l_unpaid_amt_col||') <> 0				/* bug # 3148973 */
	HAVING sum(fpay.amount_remaining) <> 0					/* bug # 3191403*/
	GROUP BY f.invoice_number,
	         f.invoice_id,
	         f.invoice_type,
	         f.invoice_date,
	         f.entered_date,
	         f.invoice_currency_code,
	         f.invoice_amount,
	         f.'||l_invoice_amt_col||',
	         hold.FII_MEASURE11,
	         hold1.FII_MEASURE12,
	         f.'||l_discount_offered||',
	         t.name,
	         f.source) g ) h
       WHERE (rnk BETWEEN &START_INDEX AND &END_INDEX or &END_INDEX = -1)
		  &ORDER_BY_CLAUSE
		 ';


    WHEN 'FII_AP_DUE_BUCKET2_INV_DETAIL' THEN  -- 5th, Invoices Due in 16-30 days
      sqlstmt := '
SELECT
	h.FII_MEASURE1 FII_MEASURE1,
	h.FII_MEASURE2 FII_MEASURE2,
	h.FII_MEASURE3 FII_MEASURE3,
	h.FII_MEASURE4 FII_MEASURE4,
	h.FII_MEASURE5 FII_MEASURE5,
	h.FII_MEASURE6 FII_MEASURE6,
	h.FII_MEASURE7 FII_MEASURE7,
	h.FII_MEASURE8 FII_MEASURE8,
	h.FII_MEASURE9 FII_MEASURE9,
	h.FII_MEASURE10  FII_MEASURE10,
	h.FII_MEASURE11 FII_MEASURE11,
	h.FII_MEASURE12 FII_MEASURE12,
	h.FII_MEASURE13 FII_MEASURE13,
	h.FII_MEASURE14 FII_MEASURE14,
	h.FII_MEASURE15 FII_MEASURE15,
	h.FII_MEASURE16 FII_MEASURE16,
	h.FII_MEASURE17 FII_MEASURE17,
	h.FII_MEASURE18 FII_MEASURE18,
	h.FII_MEASURE21 FII_MEASURE21,
	h.FII_MEASURE22 FII_MEASURE22,
	h.FII_MEASURE23 FII_MEASURE23,
	h.FII_MEASURE24 FII_MEASURE24,
	h.FII_MEASURE25 FII_MEASURE25,
	h.FII_MEASURE26 FII_MEASURE26,
	h.FII_MEASURE27 FII_MEASURE27,
	'''||l_url_1||'''     FII_ATTRIBUTE10,
	'''||l_url_2||'''     FII_ATTRIBUTE11,
	'''||l_url_3||'''	FII_ATTRIBUTE12,
	'''||l_url_4||'''	FII_ATTRIBUTE13

	FROM
	(
	SELECT
		g.FII_MEASURE1 FII_MEASURE1,
		g.FII_MEASURE2 FII_MEASURE2,
		g.FII_MEASURE3 FII_MEASURE3,
		g.FII_MEASURE4 FII_MEASURE4,
		g.FII_MEASURE5 FII_MEASURE5,
		g.FII_MEASURE6 FII_MEASURE6,
		g.FII_MEASURE7 FII_MEASURE7,
		g.FII_MEASURE8 FII_MEASURE8,
		g.FII_MEASURE9 FII_MEASURE9,
		g.FII_MEASURE10  FII_MEASURE10,
		g.FII_MEASURE11 FII_MEASURE11,
		g.FII_MEASURE12 FII_MEASURE12,
		g.FII_MEASURE13 FII_MEASURE13,
		g.FII_MEASURE14 FII_MEASURE14,
		g.FII_MEASURE15 FII_MEASURE15,
		g.FII_MEASURE16 FII_MEASURE16,
		g.FII_MEASURE17 FII_MEASURE17,
		g.FII_MEASURE18 FII_MEASURE18,
		g.FII_MEASURE21 FII_MEASURE21,
		g.FII_MEASURE22 FII_MEASURE22,
		g.FII_MEASURE23 FII_MEASURE23,
		g.FII_MEASURE24 FII_MEASURE24,
		g.FII_MEASURE25 FII_MEASURE25,
		g.FII_MEASURE26 FII_MEASURE26,
		g.FII_MEASURE27 FII_MEASURE27,
		(rank () over(&ORDER_BY_CLAUSE nulls last,g.FII_MEASURE2)) -1 rnk
	FROM

	(SELECT f.invoice_number					FII_MEASURE1,
	       f.invoice_id					FII_MEASURE2,
	       f.invoice_type				 	FII_MEASURE3,
	       to_char(f.invoice_date, '''||l_date_mask||''')  	FII_MEASURE4,
	       f.entered_date					FII_MEASURE5, -- Bug #4266826
	       MIN(fpay.due_date)				FII_MEASURE6, -- Bug #4266826
	       f.invoice_currency_code				FII_MEASURE7,
	       f.invoice_amount					FII_MEASURE8,
	       f.'||l_invoice_amt_col||'			FII_MEASURE9,
	       sum(fpay.'||l_unpaid_amt_col||')			FII_MEASURE10,
	       decode(nvl(hold.FII_MEASURE11, ''N''), ''Y'', '''||l_yes||''', ''N'','''||l_no||''')   FII_MEASURE11,
	       nvl(hold1.FII_MEASURE12,0)			FII_MEASURE12,
	       f.'||l_discount_offered||'			FII_MEASURE13,
	       SUM(fpay.'||l_discount_taken||')			FII_MEASURE14,
	       SUM(fpay.'||l_discount_lost||')			FII_MEASURE15,
	       SUM(fpay.'||l_discount_available||') 		FII_MEASURE16,
		t.name						FII_MEASURE17,
	        f.source					FII_MEASURE18,
		to_number(null)					FII_MEASURE21,
		SUM(f.'||l_invoice_amt_col||') OVER()		FII_MEASURE22,
		SUM(sum(fpay.'||l_unpaid_amt_col||')) OVER()	FII_MEASURE23,
		SUM(f.'||l_discount_offered||') OVER()		FII_MEASURE24,
		SUM(SUM(fpay.'||l_discount_taken||')) OVER()	FII_MEASURE25,
		SUM(SUM(fpay.'||l_discount_lost||')) OVER()     FII_MEASURE26,
		SUM(SUM(fpay.'||l_discount_available||')) OVER() FII_MEASURE27
	FROM fii_ap_invoice_b 			f,
	     fii_ap_pay_sched_b			fpay,
	     ap_terms_tl			t,
	     (
	       SELECT	f.invoice_id,
				''Y''     FII_MEASURE11
	       FROM   fii_ap_inv_holds_b f
	       WHERE ( f.release_date > &BIS_CURRENT_ASOF_DATE OR f.release_date is null)
               AND     f.hold_date <= &BIS_CURRENT_ASOF_DATE
		          '||l_org_where||' '||l_sup_where|| '
               GROUP BY  invoice_id
             ) hold,
             (   SELECT f.invoice_id,
                        SUM(days_on_hold) FII_MEASURE12
                 FROM    fii_ap_hhist_ib_mv f
                 WHERE 1 = 1
                 '||l_org_where||' '||l_sup_where|| '
                 GROUP BY invoice_id
             ) hold1
	WHERE (fpay.due_date - &BIS_CURRENT_ASOF_DATE) BETWEEN 16 AND 30
	AND f.entered_Date<=&BIS_CURRENT_ASOF_DATE        /*added for bug no.3054524*/
	AND fpay.action_date <= &BIS_CURRENT_ASOF_DATE       /*added for bug no.3114633*/
        AND        fpay.action <> ''PREPAYMENT''
        '||l_org_where||' '||l_sup_where||'
	AND t.term_id = f.terms_id
	AND t.language = userenv(''LANG'')
	AND (f.fully_paid_date > &BIS_CURRENT_ASOF_DATE OR f.fully_paid_date IS NULL)
	AND f.invoice_id = fpay.invoice_id
	AND f.cancel_flag = ''N''
	AND  f.invoice_id =hold.invoice_id (+)
	AND  f.invoice_id =hold1.invoice_id (+)
--	HAVING sum(fpay.'||l_unpaid_amt_col||') <> 0 /* bug # 3148973 */
	HAVING sum(fpay.amount_remaining) <> 0       /* bug # 3191403*/
	GROUP BY f.invoice_number,
	         f.invoice_id,
	         f.invoice_type,
	         f.invoice_date,
	         f.entered_date,
	         f.invoice_currency_code,
	         f.invoice_amount,
	         f.'||l_invoice_amt_col||',
	         hold.FII_MEASURE11,
	         hold1.FII_MEASURE12,
	         f.'||l_discount_offered||',
	         t.name,
	         f.source) g ) h
       WHERE (rnk BETWEEN &START_INDEX AND &END_INDEX or &END_INDEX = -1)
		  &ORDER_BY_CLAUSE
		';


    WHEN 'FII_AP_DUE_BUCKET3_INV_DETAIL' THEN  -- 6th, Invoices Due After 30 days
      sqlstmt := '
SELECT
	h.FII_MEASURE1 FII_MEASURE1,
	h.FII_MEASURE2 FII_MEASURE2,
	h.FII_MEASURE3 FII_MEASURE3,
	h.FII_MEASURE4 FII_MEASURE4,
	h.FII_MEASURE5 FII_MEASURE5,
	h.FII_MEASURE6 FII_MEASURE6,
	h.FII_MEASURE7 FII_MEASURE7,
	h.FII_MEASURE8 FII_MEASURE8,
	h.FII_MEASURE9 FII_MEASURE9,
	h.FII_MEASURE10  FII_MEASURE10,
	h.FII_MEASURE11 FII_MEASURE11,
	h.FII_MEASURE12 FII_MEASURE12,
	h.FII_MEASURE13 FII_MEASURE13,
	h.FII_MEASURE14 FII_MEASURE14,
	h.FII_MEASURE15 FII_MEASURE15,
	h.FII_MEASURE16 FII_MEASURE16,
	h.FII_MEASURE17 FII_MEASURE17,
	h.FII_MEASURE18 FII_MEASURE18,
	h.FII_MEASURE21 FII_MEASURE21,
	h.FII_MEASURE22 FII_MEASURE22,
	h.FII_MEASURE23 FII_MEASURE23,
	h.FII_MEASURE24 FII_MEASURE24,
	h.FII_MEASURE25 FII_MEASURE25,
	h.FII_MEASURE26 FII_MEASURE26,
	h.FII_MEASURE27 FII_MEASURE27,
	'''||l_url_1||'''     FII_ATTRIBUTE10,
	'''||l_url_2||'''     FII_ATTRIBUTE11,
	'''||l_url_3||'''	FII_ATTRIBUTE12,
	'''||l_url_4||'''	FII_ATTRIBUTE13

	FROM
	(
	SELECT
		g.FII_MEASURE1 FII_MEASURE1,
		g.FII_MEASURE2 FII_MEASURE2,
		g.FII_MEASURE3 FII_MEASURE3,
		g.FII_MEASURE4 FII_MEASURE4,
		g.FII_MEASURE5 FII_MEASURE5,
		g.FII_MEASURE6 FII_MEASURE6,
		g.FII_MEASURE7 FII_MEASURE7,
		g.FII_MEASURE8 FII_MEASURE8,
		g.FII_MEASURE9 FII_MEASURE9,
		g.FII_MEASURE10  FII_MEASURE10,
		g.FII_MEASURE11 FII_MEASURE11,
		g.FII_MEASURE12 FII_MEASURE12,
		g.FII_MEASURE13 FII_MEASURE13,
		g.FII_MEASURE14 FII_MEASURE14,
		g.FII_MEASURE15 FII_MEASURE15,
		g.FII_MEASURE16 FII_MEASURE16,
		g.FII_MEASURE17 FII_MEASURE17,
		g.FII_MEASURE18 FII_MEASURE18,
		g.FII_MEASURE21 FII_MEASURE21,
		g.FII_MEASURE22 FII_MEASURE22,
		g.FII_MEASURE23 FII_MEASURE23,
		g.FII_MEASURE24 FII_MEASURE24,
		g.FII_MEASURE25 FII_MEASURE25,
		g.FII_MEASURE26 FII_MEASURE26,
		g.FII_MEASURE27 FII_MEASURE27,
		(rank () over(&ORDER_BY_CLAUSE nulls last,g.FII_MEASURE2)) -1 rnk
	FROM

	(SELECT f.invoice_number							FII_MEASURE1,
	       f.invoice_id					  		FII_MEASURE2,
	       f.invoice_type							FII_MEASURE3,
	       to_char(f.invoice_date, '''||l_date_mask||''')  			FII_MEASURE4,
	       f.entered_date  							FII_MEASURE5, -- Bug #4266826
	       MIN(fpay.due_date)						FII_MEASURE6, -- Bug #4266826
	       f.invoice_currency_code						FII_MEASURE7,
	       f.invoice_amount							FII_MEASURE8,
	       f.'||l_invoice_amt_col||'					FII_MEASURE9,
	       sum(fpay.'||l_unpaid_amt_col||')					FII_MEASURE10,
	       decode(nvl(hold.FII_MEASURE11, ''N''), ''Y'', '''||l_yes||''', ''N'','''||l_no||''')   FII_MEASURE11,
	       nvl(hold1.FII_MEASURE12,0)					FII_MEASURE12,
	       f.'||l_discount_offered||'					FII_MEASURE13,
	       SUM(fpay.'||l_discount_taken||')					FII_MEASURE14,
	       SUM(fpay.'||l_discount_lost||')					FII_MEASURE15,
	       SUM(fpay.'||l_discount_available||') 				FII_MEASURE16,
		t.name								FII_MEASURE17,
	        f.source							FII_MEASURE18,
		to_number(null)         					FII_MEASURE21,
		SUM(f.'||l_invoice_amt_col||') OVER()				FII_MEASURE22,
		SUM(sum(fpay.'||l_unpaid_amt_col||')) OVER()			FII_MEASURE23,
		SUM(f.'||l_discount_offered||') OVER()				FII_MEASURE24,
		SUM(SUM(fpay.'||l_discount_taken||')) OVER()			FII_MEASURE25,
		SUM(SUM(fpay.'||l_discount_lost||')) OVER()			FII_MEASURE26,
		SUM(SUM(fpay.'||l_discount_available||')) OVER()		FII_MEASURE27
	FROM fii_ap_invoice_b			f,
	     fii_ap_pay_sched_b			fpay,
	     ap_terms_tl			t,
	     (
	       SELECT	f.invoice_id,
				''Y''     FII_MEASURE11
	       FROM   fii_ap_inv_holds_b f
	       WHERE ( f.release_date > &BIS_CURRENT_ASOF_DATE OR f.release_date is null)
               AND     f.hold_date <= &BIS_CURRENT_ASOF_DATE
		          '||l_org_where||' '||l_sup_where|| '
               GROUP BY  invoice_id
             ) hold,
             (   SELECT f.invoice_id,
                        SUM(days_on_hold) FII_MEASURE12
                 FROM    fii_ap_hhist_ib_mv f
                 WHERE 1 = 1
                 '||l_org_where||' '||l_sup_where|| '
                 GROUP BY invoice_id
             ) hold1
	WHERE (fpay.due_date - &BIS_CURRENT_ASOF_DATE) > 30
	AND  fpay.action_date <= &BIS_CURRENT_ASOF_DATE				/*added for bug no.3114633*/
        AND        fpay.action <> ''PREPAYMENT''
        '||l_org_where||' '||l_sup_where||'
	AND  f.entered_Date<=&BIS_CURRENT_ASOF_DATE				/*added for bug no.3054524*/
	AND  t.term_id = f.terms_id
	AND  t.language = userenv(''LANG'')
	AND  (f.fully_paid_date > &BIS_CURRENT_ASOF_DATE OR f.fully_paid_date IS NULL)
	AND  f.invoice_id = fpay.invoice_id
	AND  f.cancel_flag = ''N''
	AND  f.invoice_id =hold.invoice_id (+)
	AND  f.invoice_id =hold1.invoice_id (+)
--	HAVING sum(fpay.'||l_unpaid_amt_col||') <> 0 /* bug # 3148973 */
	HAVING sum(fpay.amount_remaining) <> 0					/* bug # 3191403*/
	GROUP BY f.invoice_number,
	     f.invoice_id,
	     f.invoice_type,
	     f.invoice_date,
	     f.entered_date,
	     f.invoice_currency_code,
	     f.invoice_amount,
	     f.'||l_invoice_amt_col||',
	     hold.FII_MEASURE11,
	     hold1.FII_MEASURE12,
	     f.'||l_discount_offered||',
	     t.name,
	     f.source) g ) h
       WHERE (rnk BETWEEN &START_INDEX AND &END_INDEX or &END_INDEX = -1)
       &ORDER_BY_CLAUSE
	     ';


    WHEN 'FII_AP_PDUE_BUCKET1_INV_DETAIL' THEN  -- 7th, Invoices 1-15 Days Past Due
      sqlstmt := '
SELECT
	h.FII_MEASURE1 FII_MEASURE1,
	h.FII_MEASURE2 FII_MEASURE2,
	h.FII_MEASURE3 FII_MEASURE3,
	h.FII_MEASURE4 FII_MEASURE4,
	h.FII_MEASURE5 FII_MEASURE5,
	h.FII_MEASURE6 FII_MEASURE6,
	h.FII_MEASURE7 FII_MEASURE7,
	h.FII_MEASURE8 FII_MEASURE8,
	h.FII_MEASURE9 FII_MEASURE9,
	h.FII_MEASURE10  FII_MEASURE10,
	h.FII_MEASURE11 FII_MEASURE11,
	h.FII_MEASURE12 FII_MEASURE12,
	h.FII_MEASURE13 FII_MEASURE13,
	h.FII_MEASURE14 FII_MEASURE14,
	h.FII_MEASURE15 FII_MEASURE15,
	h.FII_MEASURE16 FII_MEASURE16,
	h.FII_MEASURE17 FII_MEASURE17,
	h.FII_MEASURE18 FII_MEASURE18,
	h.FII_MEASURE21 FII_MEASURE21,
	h.FII_MEASURE22 FII_MEASURE22,
	h.FII_MEASURE23 FII_MEASURE23,
	h.FII_MEASURE24 FII_MEASURE24,
	h.FII_MEASURE25 FII_MEASURE25,
	h.FII_MEASURE26 FII_MEASURE26,
	h.FII_MEASURE27 FII_MEASURE27,
	'''||l_url_1||'''     FII_ATTRIBUTE10,
	'''||l_url_2||'''     FII_ATTRIBUTE11,
	'''||l_url_3||'''	FII_ATTRIBUTE12,
	'''||l_url_4||'''	FII_ATTRIBUTE13

	FROM
	(
	SELECT
		g.FII_MEASURE1 FII_MEASURE1,
		g.FII_MEASURE2 FII_MEASURE2,
		g.FII_MEASURE3 FII_MEASURE3,
		g.FII_MEASURE4 FII_MEASURE4,
		g.FII_MEASURE5 FII_MEASURE5,
		g.FII_MEASURE6 FII_MEASURE6,
		g.FII_MEASURE7 FII_MEASURE7,
		g.FII_MEASURE8 FII_MEASURE8,
		g.FII_MEASURE9 FII_MEASURE9,
		g.FII_MEASURE10  FII_MEASURE10,
		g.FII_MEASURE11 FII_MEASURE11,
		g.FII_MEASURE12 FII_MEASURE12,
		g.FII_MEASURE13 FII_MEASURE13,
		g.FII_MEASURE14 FII_MEASURE14,
		g.FII_MEASURE15 FII_MEASURE15,
		g.FII_MEASURE16 FII_MEASURE16,
		g.FII_MEASURE17 FII_MEASURE17,
		g.FII_MEASURE18 FII_MEASURE18,
		g.FII_MEASURE21 FII_MEASURE21,
		g.FII_MEASURE22 FII_MEASURE22,
		g.FII_MEASURE23 FII_MEASURE23,
		g.FII_MEASURE24 FII_MEASURE24,
		g.FII_MEASURE25 FII_MEASURE25,
		g.FII_MEASURE26 FII_MEASURE26,
		g.FII_MEASURE27 FII_MEASURE27,
		(rank () over(&ORDER_BY_CLAUSE nulls last,g.FII_MEASURE2)) -1 rnk
	FROM

	(SELECT f.invoice_number					FII_MEASURE1,
	       f.invoice_id					FII_MEASURE2,
	       f.invoice_type					FII_MEASURE3,
	       to_char(f.invoice_date, '''||l_date_mask||''')  	FII_MEASURE4,
	       f.entered_date  					FII_MEASURE5, -- Bug #4266826
	       MIN(fpay.due_date) 				FII_MEASURE6, -- Bug #4266826
	       f.invoice_currency_code				FII_MEASURE7,
	       f.invoice_amount					FII_MEASURE8,
	       f.'||l_invoice_amt_col||'			FII_MEASURE9,
	       sum(fpay.'||l_unpaid_amt_col||')			FII_MEASURE10,
	       decode(nvl(hold.FII_MEASURE11, ''N''), ''Y'', '''||l_yes||''', ''N'','''||l_no||''')   FII_MEASURE11,
	       nvl(hold1.FII_MEASURE12,0)			FII_MEASURE12,
	       f.'||l_discount_offered||'			FII_MEASURE13,
	       SUM(fpay.'||l_discount_taken||')			FII_MEASURE14,
	       SUM(fpay.'||l_discount_lost||')			FII_MEASURE15,
	       SUM(fpay.'||l_discount_available||') 		FII_MEASURE16,
		t.name						FII_MEASURE17,
	        f.source					FII_MEASURE18,
		to_number(null)         			FII_MEASURE21,
		SUM(f.'||l_invoice_amt_col||') OVER()		FII_MEASURE22,
		SUM(sum(fpay.'||l_unpaid_amt_col||')) OVER()	FII_MEASURE23,
		SUM(f.'||l_discount_offered||') OVER()		FII_MEASURE24,
		SUM(SUM(fpay.'||l_discount_taken||')) OVER()	FII_MEASURE25,
		SUM(SUM(fpay.'||l_discount_lost||')) OVER()	FII_MEASURE26,
		SUM(SUM(fpay.'||l_discount_available||')) OVER() FII_MEASURE27
	FROM fii_ap_invoice_b		f,
	     fii_ap_pay_sched_b		fpay,
	     ap_terms_tl		t,
	     (
	       SELECT	f.invoice_id,
				''Y''     FII_MEASURE11
	       FROM   fii_ap_inv_holds_b f
	       WHERE ( f.release_date > &BIS_CURRENT_ASOF_DATE OR f.release_date is null)
               AND     f.hold_date <= &BIS_CURRENT_ASOF_DATE
		          '||l_org_where||' '||l_sup_where|| '
               GROUP BY  invoice_id
             ) hold,
             (   SELECT f.invoice_id,
                        SUM(days_on_hold) FII_MEASURE12
                 FROM    fii_ap_hhist_ib_mv f
                 WHERE 1 = 1
                 '||l_org_where||' '||l_sup_where|| '
                 GROUP BY invoice_id
             ) hold1
	WHERE (&BIS_CURRENT_ASOF_DATE - fpay.due_date) BETWEEN 1 AND 15
	AND f.entered_Date<=&BIS_CURRENT_ASOF_DATE				/*added for bug no.3054524*/
	AND fpay.action_date <= &BIS_CURRENT_ASOF_DATE				/*added for bug no.3114633*/
        AND        fpay.action <> ''PREPAYMENT''
        '||l_org_where||' '||l_sup_where||'
	AND t.term_id = f.terms_id
	AND t.language = userenv(''LANG'')
	AND (f.fully_paid_date > &BIS_CURRENT_ASOF_DATE OR f.fully_paid_date IS NULL)
	AND f.invoice_id = fpay.invoice_id
	AND f.cancel_flag = ''N''
	AND f.invoice_id =hold.invoice_id (+)
	AND f.invoice_id =hold1.invoice_id (+)
	HAVING sum(fpay.amount_remaining) <> 0					/* bug # 3191403*/
	GROUP BY f.invoice_number,
	         f.invoice_id,
	         f.invoice_type,
	         f.invoice_date,
	         f.entered_date,
	         f.invoice_currency_code,
	         f.invoice_amount,
	         f.'||l_invoice_amt_col||',
	         hold.FII_MEASURE11,
	         hold1.FII_MEASURE12,
	         f.'||l_discount_offered||',
	         t.name,
	         f.source) g ) h
       WHERE (rnk BETWEEN &START_INDEX AND &END_INDEX or &END_INDEX = -1)
		  &ORDER_BY_CLAUSE
		';


    WHEN 'FII_AP_PDUE_BUCKET2_INV_DETAIL' THEN  -- 8th, Invoices 16-30 Days Past Due
      sqlstmt := '
SELECT
	h.FII_MEASURE1 FII_MEASURE1,
	h.FII_MEASURE2 FII_MEASURE2,
	h.FII_MEASURE3 FII_MEASURE3,
	h.FII_MEASURE4 FII_MEASURE4,
	h.FII_MEASURE5 FII_MEASURE5,
	h.FII_MEASURE6 FII_MEASURE6,
	h.FII_MEASURE7 FII_MEASURE7,
	h.FII_MEASURE8 FII_MEASURE8,
	h.FII_MEASURE9 FII_MEASURE9,
	h.FII_MEASURE10  FII_MEASURE10,
	h.FII_MEASURE11 FII_MEASURE11,
	h.FII_MEASURE12 FII_MEASURE12,
	h.FII_MEASURE13 FII_MEASURE13,
	h.FII_MEASURE14 FII_MEASURE14,
	h.FII_MEASURE15 FII_MEASURE15,
	h.FII_MEASURE16 FII_MEASURE16,
	h.FII_MEASURE17 FII_MEASURE17,
	h.FII_MEASURE18 FII_MEASURE18,
	h.FII_MEASURE21 FII_MEASURE21,
	h.FII_MEASURE22 FII_MEASURE22,
	h.FII_MEASURE23 FII_MEASURE23,
	h.FII_MEASURE24 FII_MEASURE24,
	h.FII_MEASURE25 FII_MEASURE25,
	h.FII_MEASURE26 FII_MEASURE26,
	h.FII_MEASURE27 FII_MEASURE27,
	'''||l_url_1||'''     FII_ATTRIBUTE10,
	'''||l_url_2||'''     FII_ATTRIBUTE11,
	'''||l_url_3||'''	FII_ATTRIBUTE12,
	'''||l_url_4||'''	FII_ATTRIBUTE13

	FROM
	(
	SELECT
		g.FII_MEASURE1 FII_MEASURE1,
		g.FII_MEASURE2 FII_MEASURE2,
		g.FII_MEASURE3 FII_MEASURE3,
		g.FII_MEASURE4 FII_MEASURE4,
		g.FII_MEASURE5 FII_MEASURE5,
		g.FII_MEASURE6 FII_MEASURE6,
		g.FII_MEASURE7 FII_MEASURE7,
		g.FII_MEASURE8 FII_MEASURE8,
		g.FII_MEASURE9 FII_MEASURE9,
		g.FII_MEASURE10  FII_MEASURE10,
		g.FII_MEASURE11 FII_MEASURE11,
		g.FII_MEASURE12 FII_MEASURE12,
		g.FII_MEASURE13 FII_MEASURE13,
		g.FII_MEASURE14 FII_MEASURE14,
		g.FII_MEASURE15 FII_MEASURE15,
		g.FII_MEASURE16 FII_MEASURE16,
		g.FII_MEASURE17 FII_MEASURE17,
		g.FII_MEASURE18 FII_MEASURE18,
		g.FII_MEASURE21 FII_MEASURE21,
		g.FII_MEASURE22 FII_MEASURE22,
		g.FII_MEASURE23 FII_MEASURE23,
		g.FII_MEASURE24 FII_MEASURE24,
		g.FII_MEASURE25 FII_MEASURE25,
		g.FII_MEASURE26 FII_MEASURE26,
		g.FII_MEASURE27 FII_MEASURE27,
		(rank () over(&ORDER_BY_CLAUSE nulls last,g.FII_MEASURE2)) -1 rnk
	FROM

	(SELECT f.invoice_number							FII_MEASURE1,
	       f.invoice_id							FII_MEASURE2,
	       f.invoice_type							FII_MEASURE3,
	       to_char(f.invoice_date, '''||l_date_mask||''') 			FII_MEASURE4,
	       f.entered_date							FII_MEASURE5, -- Bug #4266826
	       MIN(fpay.due_date)						FII_MEASURE6, -- Bug #4266826
	       f.invoice_currency_code						FII_MEASURE7,
	       f.invoice_amount							FII_MEASURE8,
	       f.'||l_invoice_amt_col||'					FII_MEASURE9,
	       sum(fpay.'||l_unpaid_amt_col||')					FII_MEASURE10,
	       decode(nvl(hold.FII_MEASURE11, ''N''), ''Y'', '''||l_yes||''', ''N'','''||l_no||''')   FII_MEASURE11,
	       nvl(hold1.FII_MEASURE12,0)					FII_MEASURE12,
	       f.'||l_discount_offered||'					FII_MEASURE13,
	       SUM(fpay.'||l_discount_taken||')					FII_MEASURE14,
	       SUM(fpay.'||l_discount_lost||')					FII_MEASURE15,
	       SUM(fpay.'||l_discount_available||') 				FII_MEASURE16,
		t.name								FII_MEASURE17,
	        f.source							FII_MEASURE18,
		to_number(null)							FII_MEASURE21,
		SUM(f.'||l_invoice_amt_col||') OVER()				FII_MEASURE22,
		SUM(sum(fpay.'||l_unpaid_amt_col||')) OVER()			FII_MEASURE23,
		SUM(f.'||l_discount_offered||') OVER()				FII_MEASURE24,
		SUM(SUM(fpay.'||l_discount_taken||')) OVER()			FII_MEASURE25,
		SUM(SUM(fpay.'||l_discount_lost||')) OVER()			FII_MEASURE26,
		SUM(SUM(fpay.'||l_discount_available||')) OVER()		FII_MEASURE27
	FROM fii_ap_invoice_b		f,
	     fii_ap_pay_sched_b		fpay,
	     ap_terms_tl		t,
	     (
	       SELECT	f.invoice_id,
				''Y''     FII_MEASURE11
	       FROM   fii_ap_inv_holds_b f
	       WHERE ( f.release_date > &BIS_CURRENT_ASOF_DATE OR f.release_date is null)
               AND     f.hold_date <= &BIS_CURRENT_ASOF_DATE
		          '||l_org_where||' '||l_sup_where|| '
               GROUP BY  invoice_id
             ) hold,
             (   SELECT f.invoice_id,
                        SUM(days_on_hold) FII_MEASURE12
                 FROM    fii_ap_hhist_ib_mv f
                 WHERE 1 = 1
                 '||l_org_where||' '||l_sup_where|| '
                 GROUP BY invoice_id
             ) hold1
	WHERE (&BIS_CURRENT_ASOF_DATE - fpay.due_date) BETWEEN 16 AND 30
	AND  f.entered_Date<=&BIS_CURRENT_ASOF_DATE				/*added for bug no.3054524*/
	AND  fpay.action_date <= &BIS_CURRENT_ASOF_DATE				/*added for bug no.3114633*/
        AND        fpay.action <> ''PREPAYMENT''
        '||l_org_where||' '||l_sup_where||'
	AND  t.term_id = f.terms_id
	AND  t.language = userenv(''LANG'')
	AND  (f.fully_paid_date > &BIS_CURRENT_ASOF_DATE OR f.fully_paid_date IS NULL)
	AND  f.cancel_flag = ''N''
	AND  f.invoice_id = fpay.invoice_id
	AND  f.invoice_id =hold.invoice_id (+)
	AND  f.invoice_id =hold1.invoice_id (+)
	HAVING sum(fpay.amount_remaining) <> 0					/* bug # 3191403*/
	GROUP BY f.invoice_number,
	     f.invoice_id,
	     f.invoice_type,
	     f.invoice_date,
	     f.entered_date,
	     f.invoice_currency_code,
	     f.invoice_amount,
	     f.'||l_invoice_amt_col||',
	     hold.FII_MEASURE11,
	     hold1.FII_MEASURE12,
	     f.'||l_discount_offered||',
	     t.name,
	     f.source) g ) h
       WHERE (rnk BETWEEN &START_INDEX AND &END_INDEX or &END_INDEX = -1)
		  &ORDER_BY_CLAUSE
	     ';


    WHEN 'FII_AP_PDUE_BUCKET3_INV_DETAIL' THEN  -- 9th, Invoices Over 30 Days Past Due
      sqlstmt := '
SELECT
	h.FII_MEASURE1 FII_MEASURE1,
	h.FII_MEASURE2 FII_MEASURE2,
	h.FII_MEASURE3 FII_MEASURE3,
	h.FII_MEASURE4 FII_MEASURE4,
	h.FII_MEASURE5 FII_MEASURE5,
	h.FII_MEASURE6 FII_MEASURE6,
	h.FII_MEASURE7 FII_MEASURE7,
	h.FII_MEASURE8 FII_MEASURE8,
	h.FII_MEASURE9 FII_MEASURE9,
	h.FII_MEASURE10  FII_MEASURE10,
	h.FII_MEASURE11 FII_MEASURE11,
	h.FII_MEASURE12 FII_MEASURE12,
	h.FII_MEASURE13 FII_MEASURE13,
	h.FII_MEASURE14 FII_MEASURE14,
	h.FII_MEASURE15 FII_MEASURE15,
	h.FII_MEASURE16 FII_MEASURE16,
	h.FII_MEASURE17 FII_MEASURE17,
	h.FII_MEASURE18 FII_MEASURE18,
	h.FII_MEASURE21 FII_MEASURE21,
	h.FII_MEASURE22 FII_MEASURE22,
	h.FII_MEASURE23 FII_MEASURE23,
	h.FII_MEASURE24 FII_MEASURE24,
	h.FII_MEASURE25 FII_MEASURE25,
	h.FII_MEASURE26 FII_MEASURE26,
	h.FII_MEASURE27 FII_MEASURE27,
	'''||l_url_1||'''     FII_ATTRIBUTE10,
	'''||l_url_2||'''     FII_ATTRIBUTE11,
	'''||l_url_3||'''	FII_ATTRIBUTE12,
	'''||l_url_4||'''	FII_ATTRIBUTE13

	FROM
	(
	SELECT
		g.FII_MEASURE1 FII_MEASURE1,
		g.FII_MEASURE2 FII_MEASURE2,
		g.FII_MEASURE3 FII_MEASURE3,
		g.FII_MEASURE4 FII_MEASURE4,
		g.FII_MEASURE5 FII_MEASURE5,
		g.FII_MEASURE6 FII_MEASURE6,
		g.FII_MEASURE7 FII_MEASURE7,
		g.FII_MEASURE8 FII_MEASURE8,
		g.FII_MEASURE9 FII_MEASURE9,
		g.FII_MEASURE10  FII_MEASURE10,
		g.FII_MEASURE11 FII_MEASURE11,
		g.FII_MEASURE12 FII_MEASURE12,
		g.FII_MEASURE13 FII_MEASURE13,
		g.FII_MEASURE14 FII_MEASURE14,
		g.FII_MEASURE15 FII_MEASURE15,
		g.FII_MEASURE16 FII_MEASURE16,
		g.FII_MEASURE17 FII_MEASURE17,
		g.FII_MEASURE18 FII_MEASURE18,
		g.FII_MEASURE21 FII_MEASURE21,
		g.FII_MEASURE22 FII_MEASURE22,
		g.FII_MEASURE23 FII_MEASURE23,
		g.FII_MEASURE24 FII_MEASURE24,
		g.FII_MEASURE25 FII_MEASURE25,
		g.FII_MEASURE26 FII_MEASURE26,
		g.FII_MEASURE27 FII_MEASURE27,
		(rank () over(&ORDER_BY_CLAUSE nulls last,g.FII_MEASURE2)) -1 rnk
	FROM

	(SELECT f.invoice_number							FII_MEASURE1,
	       f.invoice_id							FII_MEASURE2,
	       f.invoice_type							FII_MEASURE3,
	       to_char(f.invoice_date, '''||l_date_mask||''')  			FII_MEASURE4,
	       f.entered_date							FII_MEASURE5, -- Bug #4266826
	       MIN(fpay.due_date)						FII_MEASURE6, -- Bug #4266826
	       f.invoice_currency_code						FII_MEASURE7,
	       f.invoice_amount							FII_MEASURE8,
	       f.'||l_invoice_amt_col||'					FII_MEASURE9,
	       sum(fpay.'||l_unpaid_amt_col||')					FII_MEASURE10,
	       decode(nvl(hold.FII_MEASURE11, ''N''), ''Y'', '''||l_yes||''', ''N'','''||l_no||''')   FII_MEASURE11,
	       nvl(hold1.FII_MEASURE12,0)					FII_MEASURE12,
	       f.'||l_discount_offered||'					FII_MEASURE13,
	       SUM(fpay.'||l_discount_taken||')					FII_MEASURE14,
	       SUM(fpay.'||l_discount_lost||')					FII_MEASURE15,
	       SUM(fpay.'||l_discount_available||') 				FII_MEASURE16,
		t.name								FII_MEASURE17,
	        f.source							FII_MEASURE18,
		to_number(null) 						FII_MEASURE21,
		SUM(f.'||l_invoice_amt_col||') OVER()				FII_MEASURE22,
		SUM(sum(fpay.'||l_unpaid_amt_col||')) OVER()			FII_MEASURE23,
		SUM(f.'||l_discount_offered||') OVER()				FII_MEASURE24,
		SUM(SUM(fpay.'||l_discount_taken||')) OVER()			FII_MEASURE25,
		SUM(SUM(fpay.'||l_discount_lost||')) OVER()			FII_MEASURE26,
		SUM(SUM(fpay.'||l_discount_available||')) OVER()		FII_MEASURE27
	FROM   fii_ap_invoice_b		f,
	       fii_ap_pay_sched_b	fpay,
	       ap_terms_tl		t,
	     (
	       SELECT	f.invoice_id,
				''Y''     FII_MEASURE11
	       FROM   fii_ap_inv_holds_b f
	       WHERE ( f.release_date > &BIS_CURRENT_ASOF_DATE OR f.release_date IS NULL)
               AND     f.hold_date <= &BIS_CURRENT_ASOF_DATE
	       '||l_org_where||' '||l_sup_where|| '
               GROUP BY  invoice_id
             ) hold,
             (   SELECT f.invoice_id,
                        SUM(days_on_hold) FII_MEASURE12
                 FROM    fii_ap_hhist_ib_mv f
                 WHERE 1 = 1
                 '||l_org_where||' '||l_sup_where|| '
                 GROUP BY invoice_id
             ) hold1
	WHERE (&BIS_CURRENT_ASOF_DATE - fpay.due_date) > 30
	AND  f.entered_Date<=&BIS_CURRENT_ASOF_DATE				/*added for bug no.3054524*/
	AND  f.cancel_flag = ''N''
	AND  fpay.action_date <= &BIS_CURRENT_ASOF_DATE				/*added for bug no.3114633*/
        AND        fpay.action <> ''PREPAYMENT''
        '||l_org_where||' '||l_sup_where||'
	AND  t.term_id = f.terms_id
	AND  t.language = userenv(''LANG'')
	AND  (f.fully_paid_date > &BIS_CURRENT_ASOF_DATE OR f.fully_paid_date IS NULL)
	AND  f.invoice_id = fpay.invoice_id
	AND  f.invoice_id =hold.invoice_id (+)
	AND  f.invoice_id =hold1.invoice_id (+)
	HAVING SUM(fpay.amount_remaining) <> 0					/* bug # 3191403*/
	GROUP BY f.invoice_number,
	     f.invoice_id,
	     f.invoice_type,
	     f.invoice_date,
	     f.entered_date,
	     f.invoice_currency_code,
	     f.invoice_amount,
	     f.'||l_invoice_amt_col||',
	     hold.FII_MEASURE11,
	     hold1.FII_MEASURE12,
	     f.'||l_discount_offered||',
	     t.name,
	     f.source) g ) h
       WHERE (rnk BETWEEN &START_INDEX AND &END_INDEX or &END_INDEX = -1)
		  &ORDER_BY_CLAUSE
	     ';

    ELSE -- dummy code
      sqlstmt := 'Invalid report source';

  END CASE;

-- Attach bind parameters
  FII_PMV_UTIL.bind_variable(
	p_sqlstmt=>sqlstmt,
	p_page_parameter_tbl=>p_page_parameter_tbl,
	p_sql_output=>inv_dtl_sql,
	p_bind_output_table=>inv_dtl_output);
--	,p_record_type_id=>l_record_type_id);

END get_inv_detail;



END FII_AP_INV_DETAIL;


/
