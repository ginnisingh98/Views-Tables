--------------------------------------------------------
--  DDL for Package Body FII_AP_INV_ACTIVITY_DETAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AP_INV_ACTIVITY_DETAIL" AS
/* $Header: FIIAPD4B.pls 120.3 2005/10/12 20:10:20 vkazhipu noship $ */

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



-- For the Invoice Activity Detail report --
PROCEDURE get_inv_activity_detail (
	p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
	inv_dtl_sql             OUT NOCOPY VARCHAR2,
	inv_dtl_output          OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
	i                       NUMBER;
	l_viewby_dim            VARCHAR2(240);  -- what is the viewby
	l_as_of_date            DATE;
	l_organization          VARCHAR2(240);
	l_supplier              VARCHAR2(240);
	l_currency              VARCHAR2(240);  -- random size, is possibly high
	l_viewby_id             VARCHAR2(240);  -- org_id or supplier_id
	l_viewby_string		VARCHAR2(240);
	l_record_type_id        NUMBER;         -- only possible value is 1143
	l_curr_suffix		VARCHAR2(240);
	l_org_where             VARCHAR2(240);
	l_sup_where             VARCHAR2(240);
      base_org_where             VARCHAR2(240);
	base_sup_where             VARCHAR2(240);
	l_gid			NUMBER;
	sqlstmt			VARCHAR2(14000);
	l_period_type		VARCHAR2(240);
	l_invoice_number	VARCHAR2(240);
	l_report_source		VARCHAR2(240);
	l_discount_offered	VARCHAR2(240);
	l_period_start		DATE;
	l_check_id		NUMBER := 0;
	l_url_1			VARCHAR2(1000);
	l_url_2			VARCHAR2(1000);
	l_url_3			VARCHAR2(1000);
	l_url_4			VARCHAR2(1000);
	l_yes                   VARCHAR2(240);
	l_no                    VARCHAR2(240);
	l_date_mask             VARCHAR2(240);
	l_days_into_period      NUMBER;
	l_cur_period 		NUMBER;
	l_id_column 		VARCHAR2(240);
	l_invoice_amount       VARCHAR2(240);
	l_payment_amount       VARCHAR2(240);
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


  FII_PMV_UTIL.get_report_source (
	p_page_parameter_tbl=>p_page_parameter_tbl,
	p_report_source=>l_report_source);

  l_discount_offered	:=  FII_PMV_UTIL.get_base_curr_colname(l_curr_suffix, 'discount_offered');

--Added for Bug 4309974
  SELECT TO_CHAR(TRUNC(sysdate),'DD/MM/YYYY') INTO l_sysdate FROM dual;

  FII_PMV_UTIL.get_check_id(p_page_parameter_tbl, l_check_id);

--Modified for Bug 4309974
--  l_url_1 := 'pFunctionName=FII_AP_INV_ACTIVITY_HISTORY&pParamIds=Y&FII_INVOICE_ID=FII_MEASURE2&FII_INVOICE=FII_MEASURE1';
  l_url_1 := 'AS_OF_DATE='||l_sysdate||'&pFunctionName=FII_AP_INV_ACTIVITY_HISTORY&pParamIds=Y&FII_INVOICE_ID=FII_MEASURE2&FII_INVOICE=FII_MEASURE1';

  l_url_2 := 'AS_OF_DATE='||l_sysdate||'&pFunctionName=FII_AP_SCHED_PAY_DISCOUNT&pParamIds=Y&FII_AP_INVOICE_ID=FII_MEASURE2&FII_INVOICE=FII_MEASURE1';
  l_url_3 := 'AS_OF_DATE='||l_sysdate||'&pFunctionName=FII_AP_HOLD_HISTORY&pParamIds=Y&FII_AP_INVOICE_ID=FII_MEASURE2&FII_INVOICE=FII_MEASURE1';
--  l_url_4 := 'AS_OF_DATE='||l_sysdate||'&pFunctionName=FII_AP_INV_DIST_DETAIL&pParamIds=Y&FII_INVOICE_ID=FII_MEASURE2&FII_INVOICE=FII_MEASURE1';

  l_url_4 := 'AS_OF_DATE='||l_sysdate||'&pFunctionName=FII_AP_INV_LINES_DETAIL&pParamIds=Y&FII_AP_INVOICE_ID=FII_MEASURE2&FII_INVOICE_NUM=FII_MEASURE1';

  FII_PMV_Util.get_yes_no_msg(l_yes, l_no);
  FII_PMV_Util.get_format_mask(l_date_mask);
  FII_PMV_Util.get_period_strt(p_page_parameter_tbl,
                               l_period_start,
                               l_days_into_period,
                               l_cur_period,
                               l_id_column );


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
 |	FII_MEASURE11	- Ever On Hold				|
 |	FII_MEASURE12	- Number of Holds Placed		|
 |	FII_MEASURE13	- Days on Hold				|
 |	FII_MEASURE14	- Distribution Lines			|
 |	FII_MEASURE15	- Terms					|
 |	FII_MEASURE16	- Source				|
 |	FII_MEASURE18	- Check ID				|
 |	FII_MEASURE[21-27] - GrAND Total columns		|
 +--------------------------------------------------------------*/

       l_payment_amount := FII_PMV_Util.get_base_curr_colname(l_curr_suffix, 'payment_amount');


       If l_curr_suffix = '_prim_g' then
          l_invoice_amount := 'prim_amount';
       Elsif l_curr_suffix = '_sec_g' then
          l_invoice_amount := 'sec_amount';
       Elsif l_curr_suffix = '_b' then
          l_invoice_amount := 'base_amount';
       End if;

/* Added code for bug number 3423861. It is for the case when a prepayment
invoice is entered and an action takes place on the invoice in future date
eg payment. As the action is recorded in fii_ap_pay_sched_b at a future date,
we need to display the invoice taking care about not displaying the affected
columns like paid amount in the future date . For this we use a decode and
nvl in the select statement to filter it out . To enable the rows to be selected
we add a condition in WHERE clause "or (base.action = 'PREPAYMENT') ".
Made changes in foll. reports
1. Manual Invoice Entered Detail
2. Electronic Invoice Entered Detail
3. XML Invoices Entered Detail
4. EDI Invoices Entered Detail
5. ASBN Invoices Entered Detail
6. ISP Invoices Entered Detail
7. Other Integrated Invoices Entered Detail
8. ERS Invoices Entered Detail
9. Prepayment invoices entered detail
10.Invoices Entered Detail
*/


/* Changes made during Performance tuning + enhancement for Days on Hold

1. Removed period_type_id = 1 from all the reports
2. Implemented the Start and End index logic to support Windowed mode for all reports
3. Using fii_ap_inv_holds_b to return count of holds in the period in all reports
4. Using fii_ap_hhist_ib_mv to return days on hold and Ever on Hold in all reports
5. Removed the release condition from all the reports as release date as no role in
    either days on hold,or Ever on Hold or Count ( in all reports)
6. Changed the driving tables to maximise the use of index (driving table now is fii_ap_invoice_b)
7. Cleaned up the commented part of code not being used (as fix for some bug) eg.
    Removed the commented line
        sum(base.base_amount) over()				FII_MEASURE21 ,
8. Made use of the same Measure name as being passed to AK in the inner query
9. Moved the urls to top level .
10. Removed the check_id from the group by clause as bug 3063385 was not generic.
11. In AK for FII_AP_INV_ACTIVITY_DETAIL,changed the no.of display rows to -30 and
      Number of rows per portlet to -10

*/

-- Construct the query to be sent



  CASE l_report_source

    WHEN 'FII_AP_INV_ENT_DTL' THEN  -- 1st, Invoices Entered Detail
      sqlstmt := '
Select
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
	h.FII_MEASURE18 FII_MEASURE18,
	h.FII_MEASURE21 FII_MEASURE21,
	h.FII_MEASURE22 FII_MEASURE22,
	h.FII_MEASURE23 FII_MEASURE23,
	h.FII_MEASURE24 FII_MEASURE24,
	h.FII_MEASURE25 FII_MEASURE25,
	h.FII_MEASURE26 FII_MEASURE26,
	'''||l_url_1||'''	FII_ATTRIBUTE10,
	'''||l_url_2||'''	FII_ATTRIBUTE11,
	'''||l_url_4||'''	FII_ATTRIBUTE12, /* Bug 3044407: Swapped the URLs of */
	'''||l_url_3||'''	FII_ATTRIBUTE13  /* FII_ATTRIBUTE12 and FII_ATTRIBUTE13 */

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
		g.FII_MEASURE18 FII_MEASURE18,
		g.FII_MEASURE21 FII_MEASURE21,
		g.FII_MEASURE22 FII_MEASURE22,
		g.FII_MEASURE23 FII_MEASURE23,
		g.FII_MEASURE24 FII_MEASURE24,
		g.FII_MEASURE25 FII_MEASURE25,
		g.FII_MEASURE26 FII_MEASURE26,
		(rank () over(&ORDER_BY_CLAUSE nulls last,g.FII_MEASURE2)) -1 rnk
	FROM

	(SELECT f.invoice_number						FII_MEASURE1,
	       f.invoice_id						FII_MEASURE2,
	       f.invoice_type						FII_MEASURE3,
/* Bug 3583140. Removed to_char statement */
	       f.invoice_date				  		FII_MEASURE4,
	       f.entered_date				  		FII_MEASURE5,
	       MIN(f.due_Date)				          	FII_MEASURE6,
	       f.invoice_currency_code					FII_MEASURE7,
	       f.invoice_amount						FII_MEASURE8,
	       f.'||l_invoice_amount||'						FII_MEASURE9,
	       sum(decode(base.action,''PREPAYMENT'',decode(sign(base.action_date-&BIS_CURRENT_ASOF_DATE),1,0,
	       nvl(base.'||l_payment_amount||',0)),nvl(base.'||l_payment_amount||' ,0)))				FII_MEASURE10, /*changes for bug 3423861*/
	       decode(nvl(hold1.FII_MEASURE11, ''N''), ''Y'', '''||l_yes||''', ''N'','''||l_no||''')   FII_MEASURE11,
	       nvl(hold.FII_MEASURE12,0)					FII_MEASURE12,
	       nvl(hold1.FII_MEASURE13,0)					FII_MEASURE13,
	       f.dist_count						FII_MEASURE14,
		t.name							FII_MEASURE15,
	       f.source							FII_MEASURE16,
	       max(base.check_id)					FII_MEASURE18,
	       to_number(null) 				FII_MEASURE21,
	       sum(f.'||l_invoice_amount||') over()				FII_MEASURE22,
	       sum(sum(decode(base.action,''PREPAYMENT'',decode(sign(base.action_date-&BIS_CURRENT_ASOF_DATE),1,0,
	       nvl(base.'||l_payment_amount||',0)),nvl(base.'||l_payment_amount||' ,0)))) over()		FII_MEASURE23, /*changes for bug 3423861*/
	       sum(nvl(hold.FII_MEASURE12,0)) over()			FII_MEASURE24,
	       sum(nvl(hold1.FII_MEASURE13,0)) over()			FII_MEASURE25,
	       sum(f.dist_count) over()					FII_MEASURE26
	FROM fii_ap_invoice_b		f,
	     fii_ap_pay_sched_b		base,
	     ap_terms_tl		t,
	     (SELECT  invoice_id,
                      COUNT(hold_date)  FII_MEASURE12
	      FROM fii_ap_inv_holds_b f
	      WHERE hold_date BETWEEN :PERIOD_START AND &BIS_CURRENT_ASOF_DATE
     	      '||l_org_where||' '||l_sup_where||'
	      GROUP BY invoice_id
	     ) hold,
             (SELECT  invoice_id,
		      ''Y''             FII_MEASURE11,
                      sum(days_on_hold) FII_MEASURE13
              FROM fii_ap_hhist_ib_mv f
              WHERE 1 =1
     	      '||l_org_where||' '||l_sup_where||'
	      GROUP BY invoice_id
	     ) hold1
	WHERE
	f.entered_date <= &BIS_CURRENT_ASOF_DATE
	'||l_org_where||' '||l_sup_where||'
	AND (nvl(base.action_Date,&BIS_CURRENT_ASOF_DATE) <= &BIS_CURRENT_ASOF_DATE
	or (base.action = ''PREPAYMENT'') )   /* made changes for bug 3423861*/
	/*added code for bug no.3113879*/
	AND f.entered_date >= :PERIOD_START
	AND f.cancel_flag = ''N''                    /*Added code for bug. no.3084280 */
	AND base.invoice_id (+)= f.invoice_id /*added outer join and the decode condition above for bug no.3063372*/
	AND decode(base.supplier_id,null,1,decode(base.supplier_id,f.supplier_id,1,0))=1
	AND decode(base.org_id,null,1,decode(base.org_id,f.org_id,1,0))=1
	AND t.term_id = f.terms_id
	AND t.language = userenv(''LANG'')
	AND f.invoice_id =hold.invoice_id (+)
	AND f.invoice_id =hold1.invoice_id (+)
	GROUP BY f.invoice_number,
	         f.invoice_id,
	         f.invoice_type,
	         f.invoice_date,
	         f.entered_date,
	         f.invoice_currency_code,
	         f.invoice_amount,
	         f.'||l_invoice_amount||',
	         hold1.FII_MEASURE11,
	         hold1.FII_MEASURE13,
	         f.'||l_discount_offered||',
	         hold.FII_MEASURE12,
	         f.dist_count,
	         t.name,
	         f.source) g ) h
       WHERE (rnk between &START_INDEX AND &END_INDEX or &END_INDEX = -1)
		  &ORDER_BY_CLAUSE
		';


    WHEN 'FII_AP_MANUAL_INV_ENT_DTL' THEN  -- 2nd, Manual Invoices Entered Detail
      sqlstmt := '
Select
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
	h.FII_MEASURE18 FII_MEASURE18,
	h.FII_MEASURE21 FII_MEASURE21,
	h.FII_MEASURE22 FII_MEASURE22,
	h.FII_MEASURE23 FII_MEASURE23,
	h.FII_MEASURE24 FII_MEASURE24,
	h.FII_MEASURE25 FII_MEASURE25,
	h.FII_MEASURE26 FII_MEASURE26,
	'''||l_url_1||'''	FII_ATTRIBUTE10,
	'''||l_url_2||'''	FII_ATTRIBUTE11,
	'''||l_url_4||'''	FII_ATTRIBUTE12,
	'''||l_url_3||'''	FII_ATTRIBUTE13

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
		g.FII_MEASURE18 FII_MEASURE18,
		g.FII_MEASURE21 FII_MEASURE21,
		g.FII_MEASURE22 FII_MEASURE22,
		g.FII_MEASURE23 FII_MEASURE23,
		g.FII_MEASURE24 FII_MEASURE24,
		g.FII_MEASURE25 FII_MEASURE25,
		g.FII_MEASURE26 FII_MEASURE26,
		(rank () over(&ORDER_BY_CLAUSE nulls last,g.FII_MEASURE2)) -1 rnk
	FROM

	(
		SELECT f.invoice_number					FII_MEASURE1,
	       f.invoice_id						FII_MEASURE2,
	       f.invoice_type						FII_MEASURE3,
	       to_char(f.invoice_date, '''||l_date_mask||''')  		FII_MEASURE4,
	       to_char(f.entered_date, '''||l_date_mask||''')  		FII_MEASURE5,
	       to_char(MIN(f.due_Date), '''||l_date_mask||''')          FII_MEASURE6,
	       f.invoice_currency_code					FII_MEASURE7,
	       f.invoice_amount						FII_MEASURE8,
	       f.'||l_invoice_amount||'						FII_MEASURE9,
	       sum(decode(base.action,''PREPAYMENT'',decode(sign(base.action_date-&BIS_CURRENT_ASOF_DATE),1,0,
	       nvl(base.'||l_payment_amount||',0)),nvl(base.'||l_payment_amount||' ,0)))				FII_MEASURE10, /*changes for bug 3423861*/
	       decode(nvl(hold1.FII_MEASURE11, ''N''), ''Y'', '''||l_yes||''', ''N'','''||l_no||''')   FII_MEASURE11,
	       nvl(hold.FII_MEASURE12,0)					FII_MEASURE12,
	       nvl(hold1.FII_MEASURE13,0)					FII_MEASURE13,
	       f.dist_count						FII_MEASURE14,
		t.name							FII_MEASURE15,
	       f.source							FII_MEASURE16,
	       max(base.check_id)					FII_MEASURE18,
	       to_number(null) 				FII_MEASURE21,
	       sum(f.'||l_invoice_amount||') over()				FII_MEASURE22,
	       sum(sum(decode(base.action,''PREPAYMENT'',decode(sign(base.action_date-&BIS_CURRENT_ASOF_DATE),1,0,
	       nvl(base.'||l_payment_amount||',0)),nvl(base.'||l_payment_amount||' ,0)))) over()		FII_MEASURE23, /*changes for bug 3423861*/
	       sum(nvl(hold.FII_MEASURE12,0)) over()			FII_MEASURE24,
	       sum(nvl(hold1.FII_MEASURE13,0)) over()			FII_MEASURE25,
	       sum(f.dist_count) over()					FII_MEASURE26
	FROM fii_ap_invoice_b		f,
	     fii_ap_pay_sched_b		base,
	     ap_terms_tl		t,
	     (SELECT  invoice_id,
                      COUNT(hold_date)  FII_MEASURE12
	      FROM fii_ap_inv_holds_b f
	      WHERE hold_date BETWEEN :PERIOD_START AND &BIS_CURRENT_ASOF_DATE
     	      '||l_org_where||' '||l_sup_where||'
	      GROUP BY invoice_id
	     ) hold,
             (SELECT  invoice_id,
		      ''Y''             FII_MEASURE11,
                      sum(days_on_hold) FII_MEASURE13
              FROM fii_ap_hhist_ib_mv f
              WHERE 1 =1
     	      '||l_org_where||' '||l_sup_where||'
	      GROUP BY invoice_id
	     ) hold1
	WHERE
	f.e_invoices_flag=''N''
	'||l_org_where||' '||l_sup_where||'
	AND f.entered_date <= &BIS_CURRENT_ASOF_DATE
	AND f.entered_date >= :PERIOD_START
	AND (nvl(base.action_Date,&BIS_CURRENT_ASOF_DATE) <= &BIS_CURRENT_ASOF_DATE
	OR (base.action = ''PREPAYMENT'')  )  /* made changes for bug 3423861*/
	/* added code for bug no.3113879 */
	AND f.cancel_flag = ''N''                    /* Added code for bug. no.3084280 */
	AND base.invoice_id (+)= f.invoice_id /* added outer join and the decode condition above for bug no.3063372 */
	AND decode(base.supplier_id,null,1,decode(base.supplier_id,f.supplier_id,1,0))=1
	AND decode(base.org_id,null,1,decode(base.org_id,f.org_id,1,0))=1
	AND t.term_id = f.terms_id
	AND t.language = userenv(''LANG'')
	AND f.invoice_id =hold.invoice_id (+)
	AND f.invoice_id =hold1.invoice_id (+)
	GROUP BY f.invoice_number,
	         f.invoice_id,
	         f.invoice_type,
	         f.invoice_date,
	         f.entered_date,
	         f.invoice_currency_code,
	         f.invoice_amount,
	         f.'||l_invoice_amount||',
	         hold1.FII_MEASURE11,
	         hold1.FII_MEASURE13,
	         f.'||l_discount_offered||',
	         hold.FII_MEASURE12,
	         f.dist_count,
	         t.name,
	         f.source) g ) h
       WHERE (rnk between &START_INDEX AND &END_INDEX or &END_INDEX = -1)
		  &ORDER_BY_CLAUSE
		';

    WHEN 'FII_AP_E_INV_ENT_DTL' THEN  -- 3rd, Electronic Invoices Entered Detail
      sqlstmt := '
Select
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
	h.FII_MEASURE18 FII_MEASURE18,
	h.FII_MEASURE21 FII_MEASURE21,
	h.FII_MEASURE22 FII_MEASURE22,
	h.FII_MEASURE23 FII_MEASURE23,
	h.FII_MEASURE24 FII_MEASURE24,
	h.FII_MEASURE25 FII_MEASURE25,
	h.FII_MEASURE26 FII_MEASURE26,
	'''||l_url_1||'''	FII_ATTRIBUTE10,
	'''||l_url_2||'''	FII_ATTRIBUTE11,
	'''||l_url_4||'''	FII_ATTRIBUTE12,
	'''||l_url_3||'''	FII_ATTRIBUTE13

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
		g.FII_MEASURE18 FII_MEASURE18,
		g.FII_MEASURE21 FII_MEASURE21,
		g.FII_MEASURE22 FII_MEASURE22,
		g.FII_MEASURE23 FII_MEASURE23,
		g.FII_MEASURE24 FII_MEASURE24,
		g.FII_MEASURE25 FII_MEASURE25,
		g.FII_MEASURE26 FII_MEASURE26,
		(rank () over(&ORDER_BY_CLAUSE nulls last,g.FII_MEASURE2)) -1 rnk
	FROM

	(
	SELECT f.invoice_number						FII_MEASURE1,
	       f.invoice_id						FII_MEASURE2,
	       f.invoice_type						FII_MEASURE3,
	       to_char(f.invoice_date, '''||l_date_mask||''')  		FII_MEASURE4,
	       to_char(f.entered_date, '''||l_date_mask||''')  		FII_MEASURE5,
	       to_char(MIN(f.due_Date), '''||l_date_mask||''')          FII_MEASURE6,
	       f.invoice_currency_code					FII_MEASURE7,
	       f.invoice_amount						FII_MEASURE8,
	       f.'||l_invoice_amount||'						FII_MEASURE9,
	       sum(decode(base.action,''PREPAYMENT'',decode(sign(base.action_date-&BIS_CURRENT_ASOF_DATE),1,0,
	       nvl(base.'||l_payment_amount||',0)),nvl(base.'||l_payment_amount||' ,0)))				FII_MEASURE10, /*changes for bug 3423861*/
	       decode(nvl(hold1.FII_MEASURE11, ''N''), ''Y'', '''||l_yes||''', ''N'','''||l_no||''')   FII_MEASURE11,
	       nvl(hold.FII_MEASURE12,0)					FII_MEASURE12,
	       nvl(hold1.FII_MEASURE13,0)					FII_MEASURE13,
	       f.dist_count						FII_MEASURE14,
		t.name							FII_MEASURE15,
	       f.source							FII_MEASURE16,
	       max(base.check_id)					FII_MEASURE18,
	       to_number(null) 				FII_MEASURE21,
	       sum(f.'||l_invoice_amount||') over()				FII_MEASURE22,
	       sum(sum(decode(base.action,''PREPAYMENT'',decode(sign(base.action_date-&BIS_CURRENT_ASOF_DATE),1,0,
	       nvl(base.'||l_payment_amount||',0)),nvl(base.'||l_payment_amount||' ,0)))) over()		FII_MEASURE23, /*changes for bug 3423861*/
	       sum(nvl(hold.FII_MEASURE12,0)) over()			FII_MEASURE24,
	       sum(nvl(hold1.FII_MEASURE13,0)) over()			FII_MEASURE25,
	       sum(f.dist_count) over()					FII_MEASURE26
	FROM fii_ap_invoice_b		f,
	     fii_ap_pay_sched_b		base,
	     ap_terms_tl		t,
	     (SELECT  invoice_id,
                      COUNT(hold_date)  FII_MEASURE12
	      FROM fii_ap_inv_holds_b f
	      WHERE hold_date BETWEEN :PERIOD_START AND &BIS_CURRENT_ASOF_DATE
     	      '||l_org_where||' '||l_sup_where||'
	      GROUP BY invoice_id
	     ) hold,
             (SELECT  invoice_id,
		      ''Y''             FII_MEASURE11,
                      sum(days_on_hold) FII_MEASURE13
              FROM fii_ap_hhist_ib_mv f
              WHERE 1 =1
     	      '||l_org_where||' '||l_sup_where||'
	      GROUP BY invoice_id
	     ) hold1
	WHERE f.e_invoices_flag=''Y''
	'||l_org_where||' '||l_sup_where||'
	AND f.entered_date <= &BIS_CURRENT_ASOF_DATE
	AND f.entered_date >= :PERIOD_START
	AND (nvl(base.action_Date,&BIS_CURRENT_ASOF_DATE) <= &BIS_CURRENT_ASOF_DATE /*added code for bug no.3113879*/
	OR (base.action = ''PREPAYMENT'')  )  /* made changes for bug 3423861*/
	AND f.cancel_flag = ''N''                    /*Added code for bug. no.3084280 */
	AND base.invoice_id (+)= f.invoice_id /*added outer join and the decode condition above for bug no.3063372*/
	AND decode(base.supplier_id,null,1,decode(base.supplier_id,f.supplier_id,1,0))=1
	AND decode(base.org_id,null,1,decode(base.org_id,f.org_id,1,0))=1
	AND t.term_id = f.terms_id
	AND t.language = userenv(''LANG'')
	AND f.invoice_id =hold.invoice_id (+)
	AND f.invoice_id =hold1.invoice_id (+)
	GROUP BY f.invoice_number,
	         f.invoice_id,
	         f.invoice_type,
	         f.invoice_date,
	         f.entered_date,
	         f.invoice_currency_code,
	         f.invoice_amount,
	         f.'||l_invoice_amount||',
	         hold1.FII_MEASURE11,
	         hold1.FII_MEASURE13,
	         f.'||l_discount_offered||',
	         hold.FII_MEASURE12,
	         f.dist_count,
	         t.name,
	         f.source) g ) h
       WHERE (rnk between &START_INDEX AND &END_INDEX or &END_INDEX = -1)
		  &ORDER_BY_CLAUSE
		';

    WHEN 'FII_AP_XML_INV_ENT_DTL' THEN  -- 4th, XML Invoices Entered Detail
      sqlstmt := '
Select
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
	h.FII_MEASURE18 FII_MEASURE18,
	h.FII_MEASURE21 FII_MEASURE21,
	h.FII_MEASURE22 FII_MEASURE22,
	h.FII_MEASURE23 FII_MEASURE23,
	h.FII_MEASURE24 FII_MEASURE24,
	h.FII_MEASURE25 FII_MEASURE25,
	h.FII_MEASURE26 FII_MEASURE26,
	'''||l_url_1||'''	FII_ATTRIBUTE10,
	'''||l_url_2||'''	FII_ATTRIBUTE11,
	'''||l_url_4||'''	FII_ATTRIBUTE12,
	'''||l_url_3||'''	FII_ATTRIBUTE13

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
		g.FII_MEASURE18 FII_MEASURE18,
		g.FII_MEASURE21 FII_MEASURE21,
		g.FII_MEASURE22 FII_MEASURE22,
		g.FII_MEASURE23 FII_MEASURE23,
		g.FII_MEASURE24 FII_MEASURE24,
		g.FII_MEASURE25 FII_MEASURE25,
		g.FII_MEASURE26 FII_MEASURE26,
		(rank () over(&ORDER_BY_CLAUSE nulls last,g.FII_MEASURE2)) -1 rnk
	FROM
	(
	SELECT f.invoice_number					FII_MEASURE1,
	       f.invoice_id						FII_MEASURE2,
	       f.invoice_type					FII_MEASURE3,
	       to_char(f.invoice_date, '''||l_date_mask||''')  	FII_MEASURE4,
	       to_char(f.entered_date, '''||l_date_mask||''')  	FII_MEASURE5,
	       to_char(MIN(nvl(fpay.due_date, f.due_date)), '''||l_date_mask||''')  	FII_MEASURE6,
	       f.invoice_currency_code				FII_MEASURE7,
	       f.invoice_amount						FII_MEASURE8,
	       f.'||l_invoice_amount||'					FII_MEASURE9,
	       sum(decode(fpay.action,''PREPAYMENT'',decode(sign(fpay.action_date-&BIS_CURRENT_ASOF_DATE),1,0,
	       nvl(fpay.'||l_payment_amount||',0)),nvl(fpay.'||l_payment_amount||' ,0)))				FII_MEASURE10, /*changes for bug 3423861*/
	       decode(nvl(hold1.FII_MEASURE11, ''N''), ''Y'', '''||l_yes||''', ''N'','''||l_no||''')   FII_MEASURE11,
	       nvl(hold.FII_MEASURE12,0)					FII_MEASURE12,
	       nvl(hold1.FII_MEASURE13,0)					FII_MEASURE13,
	       f.dist_count						FII_MEASURE14,
		t.name							FII_MEASURE15,
	       f.source						FII_MEASURE16,
		max(fpay.check_id)						FII_MEASURE18,
	       to_number(null)				FII_MEASURE21,
	       sum(f.'||l_invoice_amount||') over()				FII_MEASURE22,
	       sum(sum(decode(fpay.action,''PREPAYMENT'',decode(sign(fpay.action_date-&BIS_CURRENT_ASOF_DATE),1,0,
	       nvl(fpay.'||l_payment_amount||',0)),nvl(fpay.'||l_payment_amount||' ,0)))) over()			FII_MEASURE23, /*changes for bug 3423861*/
	       sum(nvl(hold.FII_MEASURE12,0)) over()			FII_MEASURE24,
	       sum(nvl(hold1.FII_MEASURE13,0)) over()			FII_MEASURE25,
	       sum(f.dist_count) over()				FII_MEASURE26
	FROM fii_ap_invoice_b		f,
	     fii_ap_pay_sched_b		fpay,
	     ap_terms_tl		t,
	     (SELECT  invoice_id,
                      COUNT(hold_date)  FII_MEASURE12
	      FROM fii_ap_inv_holds_b f
	      WHERE hold_date BETWEEN :PERIOD_START AND &BIS_CURRENT_ASOF_DATE
     	      '||l_org_where||' '||l_sup_where||'
	      GROUP BY invoice_id
	     ) hold,
             (SELECT  invoice_id,
		      ''Y''             FII_MEASURE11,
                      sum(days_on_hold) FII_MEASURE13
              FROM fii_ap_hhist_ib_mv f
              WHERE 1 =1
     	      '||l_org_where||' '||l_sup_where||'
	      GROUP BY invoice_id
	     ) hold1
	WHERE f.e_invoices_flag = ''Y''
	AND f.source = ''XML GATEWAY''
	'||l_org_where||' '||l_sup_where||'
	AND f.cancel_flag = ''N''                    /*Added code for bug. no.3084280 */
	AND f.entered_date <= &BIS_CURRENT_ASOF_DATE
	AND f.entered_date >= :PERIOD_START
        AND (nvl(fpay.action_date,&BIS_CURRENT_ASOF_DATE) <= &BIS_CURRENT_ASOF_DATE /*added code for bug no.3113879*/
	OR (fpay.action = ''PREPAYMENT'')  )  /* made changes for bug 3423861*/
	AND f.invoice_id = fpay.invoice_id(+)
	AND t.term_id = f.terms_id
	AND t.language = userenv(''LANG'')
	AND f.invoice_id =hold.invoice_id (+)
	AND f.invoice_id =hold1.invoice_id (+)
	GROUP BY f.invoice_number,
	         f.invoice_id,
	         f.invoice_type,
	         f.invoice_date,
	         f.entered_date,
	         f.invoice_currency_code,
	         f.invoice_amount,
	         f.'||l_invoice_amount||',
	         hold1.FII_MEASURE11,
	         hold1.FII_MEASURE13,
	         f.'||l_discount_offered||',
	         hold.FII_MEASURE12,
	         f.dist_count,
	         t.name,
	         f.source) g ) h
       WHERE (rnk between &START_INDEX AND &END_INDEX or &END_INDEX = -1)
		  &ORDER_BY_CLAUSE
		';


    WHEN 'FII_AP_EDI_INV_ENT_DTL' THEN  -- 5th, EDI Invoices Entered Detail
      sqlstmt := '
Select
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
	h.FII_MEASURE18 FII_MEASURE18,
	h.FII_MEASURE21 FII_MEASURE21,
	h.FII_MEASURE22 FII_MEASURE22,
	h.FII_MEASURE23 FII_MEASURE23,
	h.FII_MEASURE24 FII_MEASURE24,
	h.FII_MEASURE25 FII_MEASURE25,
	h.FII_MEASURE26 FII_MEASURE26,
	'''||l_url_1||'''	FII_ATTRIBUTE10,
	'''||l_url_2||'''	FII_ATTRIBUTE11,
	'''||l_url_4||'''	FII_ATTRIBUTE12,
	'''||l_url_3||'''	FII_ATTRIBUTE13

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
		g.FII_MEASURE18 FII_MEASURE18,
		g.FII_MEASURE21 FII_MEASURE21,
		g.FII_MEASURE22 FII_MEASURE22,
		g.FII_MEASURE23 FII_MEASURE23,
		g.FII_MEASURE24 FII_MEASURE24,
		g.FII_MEASURE25 FII_MEASURE25,
		g.FII_MEASURE26 FII_MEASURE26,
		(rank () over(&ORDER_BY_CLAUSE nulls last,g.FII_MEASURE2)) -1 rnk
	FROM
	(
	SELECT f.invoice_number					FII_MEASURE1,
	       f.invoice_id						FII_MEASURE2,
	       f.invoice_type					FII_MEASURE3,
	       to_char(f.invoice_date, '''||l_date_mask||''')  	FII_MEASURE4,
	       to_char(f.entered_date, '''||l_date_mask||''')  	FII_MEASURE5,
	       to_char(MIN(nvl(fpay.due_date, f.due_date)), '''||l_date_mask||''')  	FII_MEASURE6,
	       f.invoice_currency_code				FII_MEASURE7,
	       f.invoice_amount						FII_MEASURE8,
	       f.'||l_invoice_amount||'					FII_MEASURE9,
	       sum(decode(fpay.action,''PREPAYMENT'',decode(sign(fpay.action_date-&BIS_CURRENT_ASOF_DATE),1,0,
	       nvl(fpay.'||l_payment_amount||',0)),nvl(fpay.'||l_payment_amount||' ,0)))				FII_MEASURE10, /*changes for bug 3423861*/
	       decode(nvl(hold1.FII_MEASURE11, ''N''), ''Y'', '''||l_yes||''', ''N'','''||l_no||''')   FII_MEASURE11,
	       nvl(hold.FII_MEASURE12,0)					FII_MEASURE12,
	       nvl(hold1.FII_MEASURE13,0)					FII_MEASURE13,
	       f.dist_count						FII_MEASURE14,
		t.name							FII_MEASURE15,
	       f.source						FII_MEASURE16,
		max(fpay.check_id)						FII_MEASURE18,
	       to_number(null) 				FII_MEASURE21,
	       sum(f.'||l_invoice_amount||') over()				FII_MEASURE22,
	       sum(sum(decode(fpay.action,''PREPAYMENT'',decode(sign(fpay.action_date-&BIS_CURRENT_ASOF_DATE),1,0,
	       nvl(fpay.'||l_payment_amount||',0)),nvl(fpay.'||l_payment_amount||' ,0)))) over()			FII_MEASURE23, /*changes for bug 3423861*/
	       sum(nvl(hold.FII_MEASURE12,0)) over()			FII_MEASURE24,
	       sum(nvl(hold1.FII_MEASURE13,0)) over()			FII_MEASURE25,
	       sum(f.dist_count) over()				FII_MEASURE26
	FROM fii_ap_invoice_b		f,
	     fii_ap_pay_sched_b		fpay,
	     ap_terms_tl		t,
	     (SELECT  invoice_id,
                      COUNT(hold_date)  FII_MEASURE12
	      FROM fii_ap_inv_holds_b f
	      WHERE hold_date BETWEEN :PERIOD_START AND &BIS_CURRENT_ASOF_DATE
     	      '||l_org_where||' '||l_sup_where||'
	      GROUP BY invoice_id
	     ) hold,
             (SELECT  invoice_id,
		      ''Y''             FII_MEASURE11,
                      sum(days_on_hold) FII_MEASURE13
              FROM fii_ap_hhist_ib_mv f
              WHERE 1 =1
     	      '||l_org_where||' '||l_sup_where||'
	      GROUP BY invoice_id
	     ) hold1
	WHERE f.e_invoices_flag = ''Y''
	AND f.source = ''EDI GATEWAY''
	'||l_org_where||' '||l_sup_where||'
	AND f.cancel_flag = ''N''                    /*Added code for bug. no.3084280 */
	AND f.entered_date <= &BIS_CURRENT_ASOF_DATE
	AND f.entered_date >= :PERIOD_START
        AND (nvl(fpay.action_date,&BIS_CURRENT_ASOF_DATE) <= &BIS_CURRENT_ASOF_DATE  /*added code for bug no.3113879*/
	OR   (fpay.action = ''PREPAYMENT'')  )  /* made changes for bug 3423861*/
	AND f.invoice_id = fpay.invoice_id (+)
	AND t.term_id = f.terms_id
	AND t.language = userenv(''LANG'')
	AND f.invoice_id =hold.invoice_id (+)
	AND f.invoice_id =hold1.invoice_id (+)
	GROUP BY f.invoice_number,
	         f.invoice_id,
	         f.invoice_type,
	         f.invoice_date,
	         f.entered_date,
	         f.invoice_currency_code,
	         f.invoice_amount,
	         f.'||l_invoice_amount||',
	         hold1.FII_MEASURE11,
	         hold1.FII_MEASURE13,
	         f.'||l_discount_offered||',
	         hold.FII_MEASURE12,
	         f.dist_count,
	         t.name,
	         f.source) g ) h
       WHERE (rnk between &START_INDEX AND &END_INDEX or &END_INDEX = -1)
		  &ORDER_BY_CLAUSE
		';


    WHEN 'FII_AP_ERS_INV_ENT_DTL' THEN  -- 6th, ERS Invoices Entered Detail
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
	h.FII_MEASURE18 FII_MEASURE18,
	h.FII_MEASURE21 FII_MEASURE21,
	h.FII_MEASURE22 FII_MEASURE22,
	h.FII_MEASURE23 FII_MEASURE23,
	h.FII_MEASURE24 FII_MEASURE24,
	h.FII_MEASURE25 FII_MEASURE25,
	h.FII_MEASURE26 FII_MEASURE26,
	'''||l_url_1||'''	FII_ATTRIBUTE10,
	'''||l_url_2||'''	FII_ATTRIBUTE11,
	'''||l_url_4||'''	FII_ATTRIBUTE12,
	'''||l_url_3||'''	FII_ATTRIBUTE13

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
		g.FII_MEASURE18 FII_MEASURE18,
		g.FII_MEASURE21 FII_MEASURE21,
		g.FII_MEASURE22 FII_MEASURE22,
		g.FII_MEASURE23 FII_MEASURE23,
		g.FII_MEASURE24 FII_MEASURE24,
		g.FII_MEASURE25 FII_MEASURE25,
		g.FII_MEASURE26 FII_MEASURE26,
		(rank () over(&ORDER_BY_CLAUSE nulls last,g.FII_MEASURE2)) -1 rnk
	FROM
	(
	SELECT f.invoice_number					FII_MEASURE1,
	       f.invoice_id						FII_MEASURE2,
	       f.invoice_type					FII_MEASURE3,
	       to_char(f.invoice_date, '''||l_date_mask||''')  	FII_MEASURE4,
	       to_char(f.entered_date, '''||l_date_mask||''')  	FII_MEASURE5,
	       to_char(MIN(nvl(fpay.due_date, f.due_date)), '''||l_date_mask||''')  	FII_MEASURE6,
	       f.invoice_currency_code				FII_MEASURE7,
	       f.invoice_amount						FII_MEASURE8,
	       f.'||l_invoice_amount||'					FII_MEASURE9,
	       sum(decode(fpay.action,''PREPAYMENT'',decode(sign(fpay.action_date-&BIS_CURRENT_ASOF_DATE),1,0,
	       nvl(fpay.'||l_payment_amount||',0)),nvl(fpay.'||l_payment_amount||' ,0)))				FII_MEASURE10, /*changes for bug 3423861*/
	       decode(nvl(hold1.FII_MEASURE11, ''N''), ''Y'', '''||l_yes||''', ''N'','''||l_no||''')   FII_MEASURE11,
	       nvl(hold.FII_MEASURE12,0)					FII_MEASURE12,
	       nvl(hold1.FII_MEASURE13,0)					FII_MEASURE13,
	       f.dist_count						FII_MEASURE14,
		t.name							FII_MEASURE15,
	       f.source						FII_MEASURE16,
		max(fpay.check_id)						FII_MEASURE18,
	       to_number(null)				FII_MEASURE21,
	       sum(f.'||l_invoice_amount||') over()				FII_MEASURE22,
	       sum(sum(decode(fpay.action,''PREPAYMENT'',decode(sign(fpay.action_date-&BIS_CURRENT_ASOF_DATE),1,0,
	       nvl(fpay.'||l_payment_amount||',0)),nvl(fpay.'||l_payment_amount||' ,0)))) over()			FII_MEASURE23, /*changes for bug 3423861*/
	       sum(nvl(hold.FII_MEASURE12,0)) over()			FII_MEASURE24,
	       sum(nvl(hold1.FII_MEASURE13,0)) over()			FII_MEASURE25,
	       sum(f.dist_count) over()				FII_MEASURE26
	FROM fii_ap_invoice_b		f,
	     fii_ap_pay_sched_b		fpay,
	     ap_terms_tl		t,
	     (SELECT  invoice_id,
                      COUNT(hold_date)  FII_MEASURE12
	      FROM fii_ap_inv_holds_b f
	      WHERE hold_date BETWEEN :PERIOD_START AND &BIS_CURRENT_ASOF_DATE
     	      '||l_org_where||' '||l_sup_where||'
	      GROUP BY invoice_id
	     ) hold,
             (SELECT  invoice_id,
		      ''Y''             FII_MEASURE11,
                      sum(days_on_hold) FII_MEASURE13
              FROM fii_ap_hhist_ib_mv f
              WHERE 1 =1
     	      '||l_org_where||' '||l_sup_where||'
	      GROUP BY invoice_id
	     ) hold1
	WHERE f.e_invoices_flag = ''Y''
	AND f.source = ''ERS''
	'||l_org_where||' '||l_sup_where||'
	AND f.cancel_flag = ''N''                    /*Added code for bug. no.3084280 */
	AND f.entered_date <= &BIS_CURRENT_ASOF_DATE
	AND f.entered_date >= :PERIOD_START
        AND (nvl(fpay.action_date,&BIS_CURRENT_ASOF_DATE) <= &BIS_CURRENT_ASOF_DATE    /*added code for bug no.3113879*/
	OR   (fpay.action = ''PREPAYMENT'')  )  /* made changes for bug 3423861*/
	AND f.invoice_id = fpay.invoice_id (+)
	AND t.term_id = f.terms_id
	AND t.language = userenv(''LANG'')
	AND f.invoice_id =hold.invoice_id (+)
	AND f.invoice_id =hold1.invoice_id (+)
	GROUP BY f.invoice_number,
	         f.invoice_id,
	         f.invoice_type,
	         f.invoice_date,
	         f.entered_date,
	         f.invoice_currency_code,
	         f.invoice_amount,
	         f.'||l_invoice_amount||',
	         hold1.FII_MEASURE11,
	         hold1.FII_MEASURE13,
	         f.'||l_discount_offered||',
	         hold.FII_MEASURE12,
	         f.dist_count,
	         t.name,
	         f.source) g ) h
       WHERE (rnk between &START_INDEX AND &END_INDEX or &END_INDEX = -1)
		  &ORDER_BY_CLAUSE
		';


    WHEN 'FII_AP_ISP_INV_ENT_DTL' THEN  -- 7th, ISP Invoices Entered Detail
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
	h.FII_MEASURE18 FII_MEASURE18,
	h.FII_MEASURE21 FII_MEASURE21,
	h.FII_MEASURE22 FII_MEASURE22,
	h.FII_MEASURE23 FII_MEASURE23,
	h.FII_MEASURE24 FII_MEASURE24,
	h.FII_MEASURE25 FII_MEASURE25,
	h.FII_MEASURE26 FII_MEASURE26,
	'''||l_url_1||'''	FII_ATTRIBUTE10,
	'''||l_url_2||'''	FII_ATTRIBUTE11,
	'''||l_url_4||'''	FII_ATTRIBUTE12,
	'''||l_url_3||'''	FII_ATTRIBUTE13

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
		g.FII_MEASURE18 FII_MEASURE18,
		g.FII_MEASURE21 FII_MEASURE21,
		g.FII_MEASURE22 FII_MEASURE22,
		g.FII_MEASURE23 FII_MEASURE23,
		g.FII_MEASURE24 FII_MEASURE24,
		g.FII_MEASURE25 FII_MEASURE25,
		g.FII_MEASURE26 FII_MEASURE26,
		(rank () over(&ORDER_BY_CLAUSE nulls last,g.FII_MEASURE2)) -1 rnk
	FROM
	(
	SELECT f.invoice_number					FII_MEASURE1,
	       f.invoice_id						FII_MEASURE2,
	       f.invoice_type					FII_MEASURE3,
	       to_char(f.invoice_date, '''||l_date_mask||''')  	FII_MEASURE4,
	       to_char(f.entered_date, '''||l_date_mask||''')  	FII_MEASURE5,
	       to_char(MIN(nvl(fpay.due_date, f.due_date)), '''||l_date_mask||''')  	FII_MEASURE6,
	       f.invoice_currency_code				FII_MEASURE7,
	       f.invoice_amount						FII_MEASURE8,
	       f.'||l_invoice_amount||'					FII_MEASURE9,
	       sum(decode(fpay.action,''PREPAYMENT'',decode(sign(fpay.action_date-&BIS_CURRENT_ASOF_DATE),1,0,
	       nvl(fpay.'||l_payment_amount||',0)),nvl(fpay.'||l_payment_amount||' ,0)))				FII_MEASURE10, /*changes for bug 3423861*/
	       decode(nvl(hold1.FII_MEASURE11, ''N''), ''Y'', '''||l_yes||''', ''N'','''||l_no||''')   FII_MEASURE11,
	       nvl(hold.FII_MEASURE12,0)					FII_MEASURE12,
	       nvl(hold1.FII_MEASURE13,0)					FII_MEASURE13,
	       f.dist_count						FII_MEASURE14,
		t.name							FII_MEASURE15,
	       f.source						FII_MEASURE16,
		max(fpay.check_id)						FII_MEASURE18,
	       to_number(null)          	FII_MEASURE21,
	       sum(f.'||l_invoice_amount||') over()				FII_MEASURE22,
	       sum(sum(decode(fpay.action,''PREPAYMENT'',decode(sign(fpay.action_date-&BIS_CURRENT_ASOF_DATE),1,0,
	       nvl(fpay.'||l_payment_amount||',0)),nvl(fpay.'||l_payment_amount||' ,0)))) over()			FII_MEASURE23, /*changes for bug 3423861*/
	       sum(nvl(hold.FII_MEASURE12,0)) over()			FII_MEASURE24,
	       sum(nvl(hold1.FII_MEASURE13,0)) over()			FII_MEASURE25,
	       sum(f.dist_count) over()				FII_MEASURE26
	FROM fii_ap_invoice_b		f,
	     fii_ap_pay_sched_b		fpay,
	     ap_terms_tl		t,
	     (SELECT  invoice_id,
                      COUNT(hold_date)  FII_MEASURE12
	      FROM fii_ap_inv_holds_b f
	      WHERE hold_date BETWEEN :PERIOD_START AND &BIS_CURRENT_ASOF_DATE
     	      '||l_org_where||' '||l_sup_where||'
	      GROUP BY invoice_id
	     ) hold,
             (SELECT  invoice_id,
		      ''Y''             FII_MEASURE11,
                      sum(days_on_hold) FII_MEASURE13
              FROM fii_ap_hhist_ib_mv f
              WHERE 1 =1
     	      '||l_org_where||' '||l_sup_where||'
	      GROUP BY invoice_id
	     ) hold1
	WHERE f.e_invoices_flag = ''Y''
	AND f.source = ''ISP''
	'||l_org_where||' '||l_sup_where||'
	AND f.cancel_flag = ''N''                    /*Added code for bug. no.3084280 */
	AND f.entered_date <= &BIS_CURRENT_ASOF_DATE
	AND f.entered_date >= :PERIOD_START
	AND f.invoice_id = fpay.invoice_id (+)
        AND (nvl(fpay.action_date,&BIS_CURRENT_ASOF_DATE) <= &BIS_CURRENT_ASOF_DATE   /*added code for bug no.3113879*/
	OR   (fpay.action = ''PREPAYMENT'')  )  /* made changes for bug 3423861*/
	AND t.term_id = f.terms_id
	AND t.language = userenv(''LANG'')
	AND f.invoice_id =hold.invoice_id (+)
	AND f.invoice_id =hold1.invoice_id (+)
	GROUP BY f.invoice_number,
	         f.invoice_id,
	         f.invoice_type,
	         f.invoice_date,
	         f.entered_date,
	         f.invoice_currency_code,
	         f.invoice_amount,
	         f.'||l_invoice_amount||',
	         hold1.FII_MEASURE11,
	         hold1.FII_MEASURE13,
	         f.'||l_discount_offered||',
	         hold.FII_MEASURE12,
	         f.dist_count,
	         t.name,
	         f.source) g ) h
       WHERE (rnk between &START_INDEX AND &END_INDEX or &END_INDEX = -1)
		  &ORDER_BY_CLAUSE
		';


    WHEN 'FII_AP_ASBN_INV_ENT_DTL' THEN  -- 8th, ASBN Invoices Entered Detail
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
	h.FII_MEASURE18 FII_MEASURE18,
	h.FII_MEASURE21 FII_MEASURE21,
	h.FII_MEASURE22 FII_MEASURE22,
	h.FII_MEASURE23 FII_MEASURE23,
	h.FII_MEASURE24 FII_MEASURE24,
	h.FII_MEASURE25 FII_MEASURE25,
	h.FII_MEASURE26 FII_MEASURE26,
	'''||l_url_1||'''	FII_ATTRIBUTE10,
	'''||l_url_2||'''	FII_ATTRIBUTE11,
	'''||l_url_4||'''	FII_ATTRIBUTE12,
	'''||l_url_3||'''	FII_ATTRIBUTE13

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
		g.FII_MEASURE18 FII_MEASURE18,
		g.FII_MEASURE21 FII_MEASURE21,
		g.FII_MEASURE22 FII_MEASURE22,
		g.FII_MEASURE23 FII_MEASURE23,
		g.FII_MEASURE24 FII_MEASURE24,
		g.FII_MEASURE25 FII_MEASURE25,
		g.FII_MEASURE26 FII_MEASURE26,
		(rank () over(&ORDER_BY_CLAUSE nulls last,g.FII_MEASURE2)) -1 rnk
	FROM
	(
	SELECT f.invoice_number					FII_MEASURE1,
	       f.invoice_id						FII_MEASURE2,
	       f.invoice_type					FII_MEASURE3,
	       to_char(f.invoice_date, '''||l_date_mask||''')  	FII_MEASURE4,
	       to_char(f.entered_date, '''||l_date_mask||''')  	FII_MEASURE5,
	       to_char(MIN(nvl(fpay.due_date, f.due_date)), '''||l_date_mask||''')  	FII_MEASURE6,
	       f.invoice_currency_code				FII_MEASURE7,
	       f.invoice_amount						FII_MEASURE8,
	       f.'||l_invoice_amount||'					FII_MEASURE9,
	       sum(decode(fpay.action,''PREPAYMENT'',decode(sign(fpay.action_date-&BIS_CURRENT_ASOF_DATE),1,0,
	       nvl(fpay.'||l_payment_amount||',0)),nvl(fpay.'||l_payment_amount||' ,0)))				FII_MEASURE10, /*changes for bug 3423861*/
	       decode(nvl(hold1.FII_MEASURE11, ''N''), ''Y'', '''||l_yes||''', ''N'','''||l_no||''')   FII_MEASURE11,
	       nvl(hold.FII_MEASURE12,0)					FII_MEASURE12,
	       nvl(hold1.FII_MEASURE13,0)					FII_MEASURE13,
	       f.dist_count						FII_MEASURE14,
		t.name							FII_MEASURE15,
	       f.source						FII_MEASURE16,
		max(fpay.check_id)						FII_MEASURE18,
	       to_number(null) 				FII_MEASURE21,
	       sum(f.'||l_invoice_amount||') over()				FII_MEASURE22,
	       sum(sum(decode(fpay.action,''PREPAYMENT'',decode(sign(fpay.action_date-&BIS_CURRENT_ASOF_DATE),1,0,
	       nvl(fpay.'||l_payment_amount||',0)),nvl(fpay.'||l_payment_amount||' ,0)))) over()			FII_MEASURE23, /*changes for bug 3423861*/
	       sum(nvl(hold.FII_MEASURE12,0)) over()			FII_MEASURE24,
	       sum(nvl(hold1.FII_MEASURE13,0)) over()			FII_MEASURE25,
	       sum(f.dist_count) over()				FII_MEASURE26
	FROM fii_ap_invoice_b		f,
	     fii_ap_pay_sched_b		fpay,
	     ap_terms_tl		t,
	     (SELECT  invoice_id,
                      COUNT(hold_date)  FII_MEASURE12
	      FROM fii_ap_inv_holds_b f
	      WHERE hold_date BETWEEN :PERIOD_START AND &BIS_CURRENT_ASOF_DATE
     	      '||l_org_where||' '||l_sup_where||'
	      GROUP BY invoice_id
	     ) hold,
             (SELECT  invoice_id,
		      ''Y''             FII_MEASURE11,
                      sum(days_on_hold) FII_MEASURE13
              FROM fii_ap_hhist_ib_mv f
              WHERE 1 =1
     	      '||l_org_where||' '||l_sup_where||'
	      GROUP BY invoice_id
	     ) hold1
	WHERE f.e_invoices_flag = ''Y''
	AND f.source = ''ASBN''
	'||l_org_where||' '||l_sup_where||'
	AND f.cancel_flag = ''N''                    /*Added code for bug. no.3084280 */
	AND f.entered_date <= &BIS_CURRENT_ASOF_DATE
	AND f.entered_date >= :PERIOD_START
	AND f.invoice_id = fpay.invoice_id (+)
        AND (nvl(fpay.action_date,&BIS_CURRENT_ASOF_DATE) <= &BIS_CURRENT_ASOF_DATE   /*added code for bug no.3113879*/
	OR   (fpay.action = ''PREPAYMENT'')  )  /* made changes for bug 3423861*/
	AND t.term_id = f.terms_id
	AND t.language = userenv(''LANG'')
	AND f.invoice_id =hold.invoice_id (+)
	AND f.invoice_id =hold1.invoice_id (+)
	GROUP BY f.invoice_number,
	         f.invoice_id,
	         f.invoice_type,
	         f.invoice_date,
	         f.entered_date,
	         f.invoice_currency_code,
	         f.invoice_amount,
	         f.'||l_invoice_amount||',
	         hold1.FII_MEASURE11,
	         hold1.FII_MEASURE13,
	         f.'||l_discount_offered||',
	         hold.FII_MEASURE12,
	         f.dist_count,
	         t.name,
	         f.source) g ) h
       WHERE (rnk between &START_INDEX AND &END_INDEX or &END_INDEX = -1)
		  &ORDER_BY_CLAUSE
		';


    WHEN 'FII_AP_OTHER_SRC_INV_ENT_DTL' THEN  -- 9th, Other Integrated Invoices Entered Detail
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
	h.FII_MEASURE18 FII_MEASURE18,
	h.FII_MEASURE21 FII_MEASURE21,
	h.FII_MEASURE22 FII_MEASURE22,
	h.FII_MEASURE23 FII_MEASURE23,
	h.FII_MEASURE24 FII_MEASURE24,
	h.FII_MEASURE25 FII_MEASURE25,
	h.FII_MEASURE26 FII_MEASURE26,
	'''||l_url_1||'''	FII_ATTRIBUTE10,
	'''||l_url_2||'''	FII_ATTRIBUTE11,
	'''||l_url_4||'''	FII_ATTRIBUTE12,
	'''||l_url_3||'''	FII_ATTRIBUTE13

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
		g.FII_MEASURE18 FII_MEASURE18,
		g.FII_MEASURE21 FII_MEASURE21,
		g.FII_MEASURE22 FII_MEASURE22,
		g.FII_MEASURE23 FII_MEASURE23,
		g.FII_MEASURE24 FII_MEASURE24,
		g.FII_MEASURE25 FII_MEASURE25,
		g.FII_MEASURE26 FII_MEASURE26,
		(rank () over(&ORDER_BY_CLAUSE nulls last,g.FII_MEASURE2)) -1 rnk
	FROM
	(

	SELECT f.invoice_number					FII_MEASURE1,
	       f.invoice_id						FII_MEASURE2,
	       f.invoice_type					FII_MEASURE3,
	       to_char(f.invoice_date, '''||l_date_mask||''')  	FII_MEASURE4,
	       to_char(f.entered_date, '''||l_date_mask||''')  	FII_MEASURE5,
	       to_char(MIN(nvl(fpay.due_date, f.due_date)), '''||l_date_mask||''')  	FII_MEASURE6,
	       f.invoice_currency_code				FII_MEASURE7,
	       f.invoice_amount						FII_MEASURE8,
	       f.'||l_invoice_amount||'					FII_MEASURE9,
	       sum(decode(fpay.action,''PREPAYMENT'',decode(sign(fpay.action_date-&BIS_CURRENT_ASOF_DATE),1,0,
	       nvl(fpay.'||l_payment_amount||',0)),nvl(fpay.'||l_payment_amount||' ,0)))				FII_MEASURE10, /*changes for bug 3423861*/
	       decode(nvl(hold1.FII_MEASURE11, ''N''), ''Y'', '''||l_yes||''', ''N'','''||l_no||''')   FII_MEASURE11,
	       nvl(hold.FII_MEASURE12,0)					FII_MEASURE12,
	       nvl(hold1.FII_MEASURE13,0)					FII_MEASURE13,
	       f.dist_count						FII_MEASURE14,
		t.name							FII_MEASURE15,
	       f.source						FII_MEASURE16,
		max(fpay.check_id)						FII_MEASURE18,
	       to_number(null) 				FII_MEASURE21,
	       sum(f.'||l_invoice_amount||') over()				FII_MEASURE22,
	       sum(sum(decode(fpay.action,''PREPAYMENT'',decode(sign(fpay.action_date-&BIS_CURRENT_ASOF_DATE),1,0,
	       nvl(fpay.'||l_payment_amount||',0)),nvl(fpay.'||l_payment_amount||' ,0)))) over()			FII_MEASURE23, /*changes for bug 3423861*/
	       sum(nvl(hold.FII_MEASURE12,0)) over()			FII_MEASURE24,
	       sum(nvl(hold1.FII_MEASURE13,0)) over()			FII_MEASURE25,
	       sum(f.dist_count) over()				FII_MEASURE26
	FROM fii_ap_invoice_b		f,
	     fii_ap_pay_sched_b		fpay,
	     ap_terms_tl		t,
	     (SELECT  invoice_id,
                      COUNT(hold_date)  FII_MEASURE12
	      FROM fii_ap_inv_holds_b f
	      WHERE hold_date BETWEEN :PERIOD_START AND &BIS_CURRENT_ASOF_DATE
     	      '||l_org_where||' '||l_sup_where||'
	      GROUP BY invoice_id
	     ) hold,
             (SELECT  invoice_id,
		      ''Y''             FII_MEASURE11,
                      sum(days_on_hold) FII_MEASURE13
              FROM fii_ap_hhist_ib_mv f
              WHERE 1 =1
     	      '||l_org_where||' '||l_sup_where||'
	      GROUP BY invoice_id
	     ) hold1
	WHERE f.e_invoices_flag = ''Y''
	AND f.source NOT IN (''Manual Invoice Entry'', ''INVOICE GATEWAY'',
		''RECURRING INVOICE'', ''XML GATEWAY'', ''EDI GATEWAY'', ''ERS'', ''ISP'', ''ASBN'')
	'||l_org_where||' '||l_sup_where||'
	AND f.cancel_flag = ''N''                    /*Added code for bug. no.3084280 */
	AND f.entered_date <= &BIS_CURRENT_ASOF_DATE
	AND f.entered_date >= :PERIOD_START
        AND (nvl(fpay.action_date,&BIS_CURRENT_ASOF_DATE) <= &BIS_CURRENT_ASOF_DATE    /*added during Prepayment enh. as was not done earlier*/
	OR   (fpay.action = ''PREPAYMENT'')  )  /* made changes for bug 3423861*/
	AND f.invoice_id = fpay.invoice_id (+)
	AND t.term_id = f.terms_id
	AND t.language = userenv(''LANG'')
	AND f.invoice_id =hold.invoice_id (+)
	AND f.invoice_id =hold1.invoice_id (+)
	GROUP BY f.invoice_number,
	         f.invoice_id,
	         f.invoice_type,
	         f.invoice_date,
	         f.entered_date,
	         f.invoice_currency_code,
	         f.invoice_amount,
	         f.'||l_invoice_amount||',
	         hold1.FII_MEASURE11,
	         hold1.FII_MEASURE13,
	         f.'||l_discount_offered||',
	         hold.FII_MEASURE12,
	         f.dist_count,
	         t.name,
	         f.source) g ) h
       WHERE (rnk between &START_INDEX AND &END_INDEX or &END_INDEX = -1)
		  &ORDER_BY_CLAUSE
		';


    WHEN 'FII_AP_STANDARD_INV_ENT_DTL' THEN  -- 10th, Standard Invoices Entered Detail
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
	h.FII_MEASURE18 FII_MEASURE18,
	h.FII_MEASURE21 FII_MEASURE21,
	h.FII_MEASURE22 FII_MEASURE22,
	h.FII_MEASURE23 FII_MEASURE23,
	h.FII_MEASURE24 FII_MEASURE24,
	h.FII_MEASURE25 FII_MEASURE25,
	h.FII_MEASURE26 FII_MEASURE26,
	'''||l_url_1||'''	FII_ATTRIBUTE10,
	'''||l_url_2||'''	FII_ATTRIBUTE11,
	'''||l_url_4||'''	FII_ATTRIBUTE12,
	'''||l_url_3||'''	FII_ATTRIBUTE13

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
		g.FII_MEASURE18 FII_MEASURE18,
		g.FII_MEASURE21 FII_MEASURE21,
		g.FII_MEASURE22 FII_MEASURE22,
		g.FII_MEASURE23 FII_MEASURE23,
		g.FII_MEASURE24 FII_MEASURE24,
		g.FII_MEASURE25 FII_MEASURE25,
		g.FII_MEASURE26 FII_MEASURE26,
		(rank () over(&ORDER_BY_CLAUSE nulls last,g.FII_MEASURE2)) -1 rnk
	FROM
	(
	SELECT f.invoice_number					FII_MEASURE1,
	       f.invoice_id						FII_MEASURE2,
	       f.invoice_type					FII_MEASURE3,
	       to_char(f.invoice_date, '''||l_date_mask||''') 	FII_MEASURE4,
	       to_char(f.entered_date, '''||l_date_mask||''')  	FII_MEASURE5,
	       to_char(MIN(fpay.due_date), '''||l_date_mask||''')  	FII_MEASURE6,
	       f.invoice_currency_code				FII_MEASURE7,
	       f.invoice_amount						FII_MEASURE8,
	       f.'||l_invoice_amount||'					FII_MEASURE9,
	       sum(fpay.'||l_payment_amount||')					FII_MEASURE10,
	       decode(nvl(hold1.FII_MEASURE11, ''N''), ''Y'', '''||l_yes||''', ''N'','''||l_no||''')   FII_MEASURE11,
	       nvl(hold.FII_MEASURE12,0)					FII_MEASURE12,
	       nvl(hold1.FII_MEASURE13,0)					FII_MEASURE13,
	       f.dist_count						FII_MEASURE14,
		t.name							FII_MEASURE15,
	       f.source						FII_MEASURE16,
		max(fpay.check_id)						FII_MEASURE18,
	       to_number(null) 				FII_MEASURE21,
	       sum(f.'||l_invoice_amount||') over()				FII_MEASURE22,
	       sum(sum(fpay.'||l_payment_amount||')) over()			FII_MEASURE23,
	       sum(nvl(hold.FII_MEASURE12,0)) over()			FII_MEASURE24,
	       sum(nvl(hold1.FII_MEASURE13,0)) over()			FII_MEASURE25,
	       sum(f.dist_count) over()				FII_MEASURE26
	FROM fii_ap_invoice_b		f,
	     fii_ap_pay_sched_b		fpay,
	     ap_terms_tl		t,
	     (SELECT  invoice_id,
                      COUNT(hold_date)  FII_MEASURE12
	      FROM fii_ap_inv_holds_b f
	      WHERE hold_date BETWEEN :PERIOD_START AND &BIS_CURRENT_ASOF_DATE
     	      '||l_org_where||' '||l_sup_where||'
	      GROUP BY invoice_id
	     ) hold,
             (SELECT  invoice_id,
		      ''Y''             FII_MEASURE11,
                      sum(days_on_hold) FII_MEASURE13
              FROM fii_ap_hhist_ib_mv f
              WHERE 1 =1
     	      '||l_org_where||' '||l_sup_where||'
	      GROUP BY invoice_id
	     ) hold1
	WHERE f.invoice_type = ''STANDARD''
	'||l_org_where||' '||l_sup_where||'
	AND f.cancel_flag = ''N''                    /*Added code for bug. no.3084280 */
	AND f.entered_date <= &BIS_CURRENT_ASOF_DATE
	AND f.entered_date >= :PERIOD_START
        AND fpay.action_date <= &BIS_CURRENT_ASOF_DATE    /*added code for bug no.3113879*/
	AND f.invoice_id = fpay.invoice_id
	AND t.term_id = f.terms_id
	AND t.language = userenv(''LANG'')
	AND f.invoice_id =hold.invoice_id (+)
	AND f.invoice_id =hold1.invoice_id (+)
	GROUP BY f.invoice_number,
	         f.invoice_id,
	         f.invoice_type,
	         f.invoice_date,
	         f.entered_date,
	         f.invoice_currency_code,
	         f.invoice_amount,
	         f.'||l_invoice_amount||',
	         hold1.FII_MEASURE11,
	         hold1.FII_MEASURE13,
	         f.'||l_discount_offered||',
	         hold.FII_MEASURE12,
	         f.dist_count,
	         t.name,
	         f.source) g ) h
       WHERE (rnk between &START_INDEX AND &END_INDEX or &END_INDEX = -1)
		  &ORDER_BY_CLAUSE
		';


    WHEN 'FII_AP_WITHHOLDING_INV_ENT_DTL' THEN  -- 11th, Withholding Invoices Entered Detail
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
	h.FII_MEASURE18 FII_MEASURE18,
	h.FII_MEASURE21 FII_MEASURE21,
	h.FII_MEASURE22 FII_MEASURE22,
	h.FII_MEASURE23 FII_MEASURE23,
	h.FII_MEASURE24 FII_MEASURE24,
	h.FII_MEASURE25 FII_MEASURE25,
	h.FII_MEASURE26 FII_MEASURE26,
	'''||l_url_1||'''	FII_ATTRIBUTE10,
	'''||l_url_2||'''	FII_ATTRIBUTE11,
	'''||l_url_4||'''	FII_ATTRIBUTE12,
	'''||l_url_3||'''	FII_ATTRIBUTE13

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
		g.FII_MEASURE18 FII_MEASURE18,
		g.FII_MEASURE21 FII_MEASURE21,
		g.FII_MEASURE22 FII_MEASURE22,
		g.FII_MEASURE23 FII_MEASURE23,
		g.FII_MEASURE24 FII_MEASURE24,
		g.FII_MEASURE25 FII_MEASURE25,
		g.FII_MEASURE26 FII_MEASURE26,
		(rank () over(&ORDER_BY_CLAUSE nulls last,g.FII_MEASURE2)) -1 rnk
	FROM
	(
	SELECT f.invoice_number					FII_MEASURE1,
	       f.invoice_id						FII_MEASURE2,
	       f.invoice_type					FII_MEASURE3,
	       to_char(f.invoice_date, '''||l_date_mask||''')  	FII_MEASURE4,
	       to_char(f.entered_date, '''||l_date_mask||''')  	FII_MEASURE5,
	       to_char(MIN(fpay.due_date), '''||l_date_mask||''')  	FII_MEASURE6,
	       f.invoice_currency_code				FII_MEASURE7,
	       f.invoice_amount						FII_MEASURE8,
	       f.'||l_invoice_amount||'					FII_MEASURE9,
	       sum(fpay.'||l_payment_amount||')					FII_MEASURE10,
	       decode(nvl(hold1.FII_MEASURE11, ''N''), ''Y'', '''||l_yes||''', ''N'','''||l_no||''')   FII_MEASURE11,
	       nvl(hold.FII_MEASURE12,0)					FII_MEASURE12,
	       nvl(hold1.FII_MEASURE13,0)					FII_MEASURE13,
	       f.dist_count						FII_MEASURE14,
		t.name							FII_MEASURE15,
	       f.source						FII_MEASURE16,
		max(fpay.check_id)						FII_MEASURE18,
	       to_number(null)  				FII_MEASURE21,

	       sum(f.'||l_invoice_amount||') over()				FII_MEASURE22,
	       sum(sum(fpay.'||l_payment_amount||')) over()			FII_MEASURE23,
	       sum(nvl(hold.FII_MEASURE12,0)) over()			FII_MEASURE24,
	       sum(nvl(hold1.FII_MEASURE13,0)) over()			FII_MEASURE25,
	       sum(f.dist_count) over()				FII_MEASURE26
	FROM fii_ap_invoice_b		f,
	     fii_ap_pay_sched_b		fpay,
	     ap_terms_tl		t,
	     (SELECT  invoice_id,
                      COUNT(hold_date)  FII_MEASURE12
	      FROM fii_ap_inv_holds_b f
	      WHERE hold_date BETWEEN :PERIOD_START AND &BIS_CURRENT_ASOF_DATE
     	      '||l_org_where||' '||l_sup_where||'
	      GROUP BY invoice_id
	     ) hold,
             (SELECT  invoice_id,
		      ''Y''             FII_MEASURE11,
                      sum(days_on_hold) FII_MEASURE13
              FROM fii_ap_hhist_ib_mv f
              WHERE 1 =1
     	      '||l_org_where||' '||l_sup_where||'
	      GROUP BY invoice_id
	     ) hold1
	WHERE f.invoice_type = ''AWT''
	'||l_org_where||' '||l_sup_where||'
	AND f.cancel_flag = ''N''                    /*Added code for bug. no.3084280 */
	AND f.entered_date <= &BIS_CURRENT_ASOF_DATE
	AND f.entered_date >= :PERIOD_START
        AND fpay.action_date <= &BIS_CURRENT_ASOF_DATE    /*added code for bug no.3113879*/
	AND f.invoice_id = fpay.invoice_id
	AND t.term_id = f.terms_id
	AND t.language = userenv(''LANG'')
	AND f.invoice_id =hold.invoice_id (+)
	AND f.invoice_id =hold1.invoice_id (+)
	GROUP BY f.invoice_number,
	         f.invoice_id,
	         f.invoice_type,
	         f.invoice_date,
	         f.entered_date,
	         f.invoice_currency_code,
	         f.invoice_amount,
	         f.'||l_invoice_amount||',
	         hold1.FII_MEASURE11,
	         hold1.FII_MEASURE13,
	         f.'||l_discount_offered||',
	         hold.FII_MEASURE12,
	         f.dist_count,
	         t.name,
	         f.source) g ) h
       WHERE (rnk between &START_INDEX AND &END_INDEX or &END_INDEX = -1)
		  &ORDER_BY_CLAUSE
		';

/*Changed the query for bug no.3074836 . Changes similar to bug no.3063372*/


    WHEN 'FII_AP_PREPAYMENT_INV_ENT_DTL' THEN  -- 12th, Prepayment Invoices Entered Detail
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
	h.FII_MEASURE18 FII_MEASURE18,
	h.FII_MEASURE21 FII_MEASURE21,
	h.FII_MEASURE22 FII_MEASURE22,
	h.FII_MEASURE23 FII_MEASURE23,
	h.FII_MEASURE24 FII_MEASURE24,
	h.FII_MEASURE25 FII_MEASURE25,
	h.FII_MEASURE26 FII_MEASURE26,
	'''||l_url_1||'''	FII_ATTRIBUTE10,
	'''||l_url_2||'''	FII_ATTRIBUTE11,
	'''||l_url_4||'''	FII_ATTRIBUTE12,
	'''||l_url_3||'''	FII_ATTRIBUTE13

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
		g.FII_MEASURE18 FII_MEASURE18,
		g.FII_MEASURE21 FII_MEASURE21,
		g.FII_MEASURE22 FII_MEASURE22,
		g.FII_MEASURE23 FII_MEASURE23,
		g.FII_MEASURE24 FII_MEASURE24,
		g.FII_MEASURE25 FII_MEASURE25,
		g.FII_MEASURE26 FII_MEASURE26,
		(rank () over(&ORDER_BY_CLAUSE nulls last,g.FII_MEASURE2)) -1 rnk
	FROM
	(
	SELECT f.invoice_number					FII_MEASURE1,
	       f.invoice_id						FII_MEASURE2,
	       f.invoice_type					FII_MEASURE3,
	       to_char(f.invoice_date, '''||l_date_mask||''')  	FII_MEASURE4,
	       to_char(f.entered_date, '''||l_date_mask||''')  	FII_MEASURE5,
	       to_char(MIN(nvl(base.due_date,f.due_Date)), '''||l_date_mask||''')  	FII_MEASURE6,
	       f.invoice_currency_code				FII_MEASURE7,
	       f.invoice_amount						FII_MEASURE8,
	       f.'||l_invoice_amount||'					FII_MEASURE9,
	       sum(decode(base.action,''PREPAYMENT'',decode(sign(base.action_date-&BIS_CURRENT_ASOF_DATE),1,0,
	       nvl(base.'||l_payment_amount||',0)),nvl(base.'||l_payment_amount||' ,0)))				FII_MEASURE10, /*changes for bug 3423861*/
	       decode(nvl(hold1.FII_MEASURE11, ''N''), ''Y'', '''||l_yes||''', ''N'','''||l_no||''')   FII_MEASURE11,
	       nvl(hold.FII_MEASURE12,0)					FII_MEASURE12,
	       nvl(hold1.FII_MEASURE13,0)					FII_MEASURE13,
	       f.dist_count						FII_MEASURE14,
		t.name							FII_MEASURE15,
	       f.source						FII_MEASURE16,
		max(base.check_id)						FII_MEASURE18,
	       to_number(null)  				FII_MEASURE21,
	       sum(f.'||l_invoice_amount||') over()				FII_MEASURE22,
	       sum(sum(decode(base.action,''PREPAYMENT'',decode(sign(base.action_date-&BIS_CURRENT_ASOF_DATE),1,0,
	       nvl(base.'||l_payment_amount||',0)),nvl(base.'||l_payment_amount||' ,0)))) over()			FII_MEASURE23, /*changes for bug 3423861*/
	       sum(nvl(hold.FII_MEASURE12,0)) over()			FII_MEASURE24,
	       sum(nvl(hold1.FII_MEASURE13,0)) over()			FII_MEASURE25,
	       sum(f.dist_count) over()				FII_MEASURE26
	FROM fii_ap_invoice_b		f,
	     fii_ap_pay_sched_b		base,
	     ap_terms_tl		t,
	     (SELECT  invoice_id,
                      COUNT(hold_date)  FII_MEASURE12
	      FROM fii_ap_inv_holds_b f
	      WHERE hold_date BETWEEN :PERIOD_START AND &BIS_CURRENT_ASOF_DATE
     	      '||l_org_where||' '||l_sup_where||'
	      GROUP BY invoice_id
	     ) hold,
             (SELECT  invoice_id,
		      ''Y''             FII_MEASURE11,
                      sum(days_on_hold) FII_MEASURE13
              FROM fii_ap_hhist_ib_mv f
              WHERE 1 =1
     	      '||l_org_where||' '||l_sup_where||'
	      GROUP BY invoice_id
	     ) hold1
	WHERE
	f.invoice_type= ''PREPAYMENT''
	'||l_org_where||' '||l_sup_where||'
	AND f.cancel_flag = ''N''                    /*Added code for bug. no.3084280 */
	AND f.entered_date <= &BIS_CURRENT_ASOF_DATE
	AND f.entered_date >= :PERIOD_START
	AND (nvl(base.action_Date,&BIS_CURRENT_ASOF_DATE) <= &BIS_CURRENT_ASOF_DATE  /*added code for bug no.3113879*/
	OR   (base.action = ''PREPAYMENT'')  )  /* made changes for bug 3423861*/
	AND base.invoice_id (+)= f.invoice_id /*added outer join and the decode condition above for bug no.3063372*/
	AND decode(base.supplier_id,null,1,decode(base.supplier_id,f.supplier_id,1,0))=1
	AND decode(base.org_id,null,1,decode(base.org_id,f.org_id,1,0))=1
	AND t.term_id = f.terms_id
	AND t.language = userenv(''LANG'')
	AND f.invoice_id =hold.invoice_id (+)
	AND f.invoice_id =hold1.invoice_id (+)
	GROUP BY f.invoice_number,
	         f.invoice_id,
	         f.invoice_type,
	         f.invoice_date,
	         f.entered_date,
	         f.invoice_currency_code,
	         f.invoice_amount,
	         f.'||l_invoice_amount||',
	         hold1.FII_MEASURE11,
	         hold1.FII_MEASURE13,
	         f.'||l_discount_offered||',
	         hold.FII_MEASURE12,
	         f.dist_count,
	         t.name,
	         f.source) g ) h
       WHERE (rnk between &START_INDEX AND &END_INDEX or &END_INDEX = -1)
		  &ORDER_BY_CLAUSE
		';


    WHEN 'FII_AP_CREDIT_INV_ENT_DTL' THEN  -- 13th, Credit Invoices Entered Detail
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
	h.FII_MEASURE18 FII_MEASURE18,
	h.FII_MEASURE21 FII_MEASURE21,
	h.FII_MEASURE22 FII_MEASURE22,
	h.FII_MEASURE23 FII_MEASURE23,
	h.FII_MEASURE24 FII_MEASURE24,
	h.FII_MEASURE25 FII_MEASURE25,
	h.FII_MEASURE26 FII_MEASURE26,
	'''||l_url_1||'''	FII_ATTRIBUTE10,
	'''||l_url_2||'''	FII_ATTRIBUTE11,
	'''||l_url_4||'''	FII_ATTRIBUTE12,
	'''||l_url_3||'''	FII_ATTRIBUTE13

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
		g.FII_MEASURE18 FII_MEASURE18,
		g.FII_MEASURE21 FII_MEASURE21,
		g.FII_MEASURE22 FII_MEASURE22,
		g.FII_MEASURE23 FII_MEASURE23,
		g.FII_MEASURE24 FII_MEASURE24,
		g.FII_MEASURE25 FII_MEASURE25,
		g.FII_MEASURE26 FII_MEASURE26,
		(rank () over(&ORDER_BY_CLAUSE nulls last,g.FII_MEASURE2)) -1 rnk
	FROM
	(
	SELECT f.invoice_number					FII_MEASURE1,
	       f.invoice_id						FII_MEASURE2,
	       f.invoice_type					FII_MEASURE3,
	       to_char(f.invoice_date, '''||l_date_mask||''')  	FII_MEASURE4,
	       to_char(f.entered_date, '''||l_date_mask||''')  	FII_MEASURE5,
	       to_char(MIN(fpay.due_date), '''||l_date_mask||''')  	FII_MEASURE6,
	       f.invoice_currency_code				FII_MEASURE7,
	       f.invoice_amount						FII_MEASURE8,
	       f.'||l_invoice_amount||'					FII_MEASURE9,
	       sum(fpay.'||l_payment_amount||')					FII_MEASURE10,
	       decode(nvl(hold1.FII_MEASURE11, ''N''), ''Y'', '''||l_yes||''', ''N'','''||l_no||''')   FII_MEASURE11,
	       nvl(hold.FII_MEASURE12,0)					FII_MEASURE12,
	       nvl(hold1.FII_MEASURE13,0)					FII_MEASURE13,
	       f.dist_count						FII_MEASURE14,
		t.name							FII_MEASURE15,
	       f.source						FII_MEASURE16,
		max(fpay.check_id)						FII_MEASURE18,
	       to_number(null)  				FII_MEASURE21,

	       sum(f.'||l_invoice_amount||') over()				FII_MEASURE22,
	       sum(sum(fpay.'||l_payment_amount||')) over()			FII_MEASURE23,
	       sum(nvl(hold.FII_MEASURE12,0)) over()			FII_MEASURE24,
	       sum(nvl(hold1.FII_MEASURE13,0)) over()			FII_MEASURE25,
	       sum(f.dist_count) over()				FII_MEASURE26
	FROM fii_ap_invoice_b		f,
	     fii_ap_pay_sched_b		fpay,
	     ap_terms_tl		t,
	     (SELECT  invoice_id,
                      COUNT(hold_date)  FII_MEASURE12
	      FROM fii_ap_inv_holds_b f
	      WHERE hold_date BETWEEN :PERIOD_START AND &BIS_CURRENT_ASOF_DATE
     	      '||l_org_where||' '||l_sup_where||'
	      GROUP BY invoice_id
	     ) hold,
             (SELECT  invoice_id,
		      ''Y''             FII_MEASURE11,
                      sum(days_on_hold) FII_MEASURE13
              FROM fii_ap_hhist_ib_mv f
              WHERE 1 =1
     	      '||l_org_where||' '||l_sup_where||'
	      GROUP BY invoice_id
	     ) hold1
	WHERE f.invoice_type = ''CREDIT''
	'||l_org_where||' '||l_sup_where||'
	AND f.cancel_flag = ''N''                    /*Added code for bug. no.3084280 */
	AND f.entered_date <= &BIS_CURRENT_ASOF_DATE
	AND f.entered_date >= :PERIOD_START
	AND fpay.action_date <= &BIS_CURRENT_ASOF_DATE   /*added code for bug no.3113879*/
	AND f.invoice_id = fpay.invoice_id
	AND t.term_id = f.terms_id
	AND t.language = userenv(''LANG'')
	AND f.invoice_id =hold.invoice_id (+)
	AND f.invoice_id =hold1.invoice_id (+)
	GROUP BY f.invoice_number,
	         f.invoice_id,
	         f.invoice_type,
	         f.invoice_date,
	         f.entered_date,
	         f.invoice_currency_code,
	         f.invoice_amount,
	         f.'||l_invoice_amount||',
	         hold1.FII_MEASURE11,
	         hold1.FII_MEASURE13,
	         f.'||l_discount_offered||',
	         hold.FII_MEASURE12,
	         f.dist_count,
	         t.name,
	         f.source) g ) h
       WHERE (rnk between &START_INDEX AND &END_INDEX or &END_INDEX = -1)
		  &ORDER_BY_CLAUSE
		 ';


    WHEN 'FII_AP_DEBIT_INV_ENT_DTL' THEN  -- 14th, Debit Invoices Entered Detail
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
	h.FII_MEASURE18 FII_MEASURE18,
	h.FII_MEASURE21 FII_MEASURE21,
	h.FII_MEASURE22 FII_MEASURE22,
	h.FII_MEASURE23 FII_MEASURE23,
	h.FII_MEASURE24 FII_MEASURE24,
	h.FII_MEASURE25 FII_MEASURE25,
	h.FII_MEASURE26 FII_MEASURE26,
	'''||l_url_1||'''	FII_ATTRIBUTE10,
	'''||l_url_2||'''	FII_ATTRIBUTE11,
	'''||l_url_4||'''	FII_ATTRIBUTE12,
	'''||l_url_3||'''	FII_ATTRIBUTE13

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
		g.FII_MEASURE18 FII_MEASURE18,
		g.FII_MEASURE21 FII_MEASURE21,
		g.FII_MEASURE22 FII_MEASURE22,
		g.FII_MEASURE23 FII_MEASURE23,
		g.FII_MEASURE24 FII_MEASURE24,
		g.FII_MEASURE25 FII_MEASURE25,
		g.FII_MEASURE26 FII_MEASURE26,
		(rank () over(&ORDER_BY_CLAUSE nulls last,g.FII_MEASURE2)) -1 rnk
	FROM
	(
	SELECT f.invoice_number					FII_MEASURE1,
	       f.invoice_id						FII_MEASURE2,
	       f.invoice_type					FII_MEASURE3,
	       to_char(f.invoice_date, '''||l_date_mask||''')  	FII_MEASURE4,
	       to_char(f.entered_date, '''||l_date_mask||''')  	FII_MEASURE5,
	       to_char(MIN(fpay.due_date), '''||l_date_mask||''')  	FII_MEASURE6,
	       f.invoice_currency_code				FII_MEASURE7,
	       f.invoice_amount						FII_MEASURE8,
	       f.'||l_invoice_amount||'					FII_MEASURE9,
	       sum(fpay.'||l_payment_amount||')					FII_MEASURE10,
	       decode(nvl(hold1.FII_MEASURE11, ''N''), ''Y'', '''||l_yes||''', ''N'','''||l_no||''')   FII_MEASURE11,
	       nvl(hold.FII_MEASURE12,0)					FII_MEASURE12,
	       nvl(hold1.FII_MEASURE13,0)					FII_MEASURE13,
	       f.dist_count						FII_MEASURE14,
		t.name							FII_MEASURE15,
	       f.source						FII_MEASURE16,
		max(fpay.check_id)						FII_MEASURE18,
	       to_number(null)  				FII_MEASURE21,

	       sum(f.'||l_invoice_amount||') over()				FII_MEASURE22,
	       sum(sum(fpay.'||l_payment_amount||')) over()			FII_MEASURE23,
	       sum(nvl(hold.FII_MEASURE12,0)) over()			FII_MEASURE24,
	       sum(nvl(hold1.FII_MEASURE13,0)) over()			FII_MEASURE25,
	       sum(f.dist_count) over()				FII_MEASURE26
	FROM fii_ap_invoice_b		f,
	     fii_ap_pay_sched_b		fpay,
	     ap_terms_tl		t,
	     (SELECT  invoice_id,
                      COUNT(hold_date)  FII_MEASURE12
	      FROM fii_ap_inv_holds_b f
	      WHERE hold_date BETWEEN :PERIOD_START AND &BIS_CURRENT_ASOF_DATE
     	      '||l_org_where||' '||l_sup_where||'
	      GROUP BY invoice_id
	     ) hold,
             (SELECT  invoice_id,
		      ''Y''             FII_MEASURE11,
                      sum(days_on_hold) FII_MEASURE13
              FROM fii_ap_hhist_ib_mv f
              WHERE 1 =1
     	      '||l_org_where||' '||l_sup_where||'
	      GROUP BY invoice_id
	     ) hold1
	WHERE f.invoice_type = ''DEBIT''
	'||l_org_where||' '||l_sup_where||'
	AND f.cancel_flag = ''N''                    /*Added code for bug. no.3084280 */
	AND f.entered_date <= &BIS_CURRENT_ASOF_DATE
	AND f.entered_date >= :PERIOD_START
        AND fpay.action_date <= &BIS_CURRENT_ASOF_DATE   /*added code for bug no.3113879*/
	AND f.invoice_id = fpay.invoice_id
	AND t.term_id = f.terms_id
	AND t.language = userenv(''LANG'')
	AND f.invoice_id =hold.invoice_id (+)
	AND f.invoice_id =hold1.invoice_id (+)
	GROUP BY f.invoice_number,
	         f.invoice_id,
	         f.invoice_type,
	         f.invoice_date,
	         f.entered_date,
	         f.invoice_currency_code,
	         f.invoice_amount,
	         f.'||l_invoice_amount||',
	         hold1.FII_MEASURE11,
	         hold1.FII_MEASURE13,
	         f.'||l_discount_offered||',
	         hold.FII_MEASURE12,
	         f.dist_count,
	         t.name,
	         f.source) g ) h
       WHERE (rnk between &START_INDEX AND &END_INDEX or &END_INDEX = -1)
		  &ORDER_BY_CLAUSE
		';


    WHEN 'FII_AP_MIXED_INV_ENT_DTL' THEN  -- 15th, Mixed Invoices Entered Detail
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
	h.FII_MEASURE18 FII_MEASURE18,
	h.FII_MEASURE21 FII_MEASURE21,
	h.FII_MEASURE22 FII_MEASURE22,
	h.FII_MEASURE23 FII_MEASURE23,
	h.FII_MEASURE24 FII_MEASURE24,
	h.FII_MEASURE25 FII_MEASURE25,
	h.FII_MEASURE26 FII_MEASURE26,
	'''||l_url_1||'''	FII_ATTRIBUTE10,
	'''||l_url_2||'''	FII_ATTRIBUTE11,
	'''||l_url_4||'''	FII_ATTRIBUTE12,
	'''||l_url_3||'''	FII_ATTRIBUTE13

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
		g.FII_MEASURE18 FII_MEASURE18,
		g.FII_MEASURE21 FII_MEASURE21,
		g.FII_MEASURE22 FII_MEASURE22,
		g.FII_MEASURE23 FII_MEASURE23,
		g.FII_MEASURE24 FII_MEASURE24,
		g.FII_MEASURE25 FII_MEASURE25,
		g.FII_MEASURE26 FII_MEASURE26,
		(rank () over(&ORDER_BY_CLAUSE nulls last,g.FII_MEASURE2)) -1 rnk
	FROM
	(
	SELECT f.invoice_number					FII_MEASURE1,
	       f.invoice_id						FII_MEASURE2,
	       f.invoice_type					FII_MEASURE3,
	       to_char(f.invoice_date, '''||l_date_mask||''')  	FII_MEASURE4,
	       to_char(f.entered_date, '''||l_date_mask||''')  	FII_MEASURE5,
	       to_char(MIN(fpay.due_date), '''||l_date_mask||''')  	FII_MEASURE6,
	       f.invoice_currency_code				FII_MEASURE7,
	       f.invoice_amount						FII_MEASURE8,
	       f.'||l_invoice_amount||'					FII_MEASURE9,
	       sum(fpay.'||l_payment_amount||')					FII_MEASURE10,
	       decode(nvl(hold1.FII_MEASURE11, ''N''), ''Y'', '''||l_yes||''', ''N'','''||l_no||''')   FII_MEASURE11,
	       nvl(hold.FII_MEASURE12,0)					FII_MEASURE12,
	       nvl(hold1.FII_MEASURE13,0)					FII_MEASURE13,
	       f.dist_count						FII_MEASURE14,
		t.name							FII_MEASURE15,
	       f.source						FII_MEASURE16,
		max(fpay.check_id)						FII_MEASURE18,
	       to_number(null)  				FII_MEASURE21,

	       sum(f.'||l_invoice_amount||') over()				FII_MEASURE22,
	       sum(sum(fpay.'||l_payment_amount||')) over()			FII_MEASURE23,
	       sum(nvl(hold.FII_MEASURE12,0)) over()			FII_MEASURE24,
	       sum(nvl(hold1.FII_MEASURE13,0)) over()			FII_MEASURE25,
	       sum(f.dist_count) over()				FII_MEASURE26
	FROM fii_ap_invoice_b		f,
	     fii_ap_pay_sched_b		fpay,
	     ap_terms_tl		t,
	     (SELECT  invoice_id,
                      COUNT(hold_date)  FII_MEASURE12
	      FROM fii_ap_inv_holds_b f
	      WHERE hold_date BETWEEN :PERIOD_START AND &BIS_CURRENT_ASOF_DATE
     	      '||l_org_where||' '||l_sup_where||'
	      GROUP BY invoice_id
	     ) hold,
             (SELECT  invoice_id,
		      ''Y''             FII_MEASURE11,
                      sum(days_on_hold) FII_MEASURE13
              FROM fii_ap_hhist_ib_mv f
              WHERE 1 =1
     	      '||l_org_where||' '||l_sup_where||'
	      GROUP BY invoice_id
	     ) hold1
	WHERE f.invoice_type = ''MIXED''
	'||l_org_where||' '||l_sup_where||'
	AND f.cancel_flag = ''N''                    /*Added code for bug. no.3084280 */
	AND f.entered_date <= &BIS_CURRENT_ASOF_DATE
	AND f.entered_date >= :PERIOD_START
	AND f.invoice_id = fpay.invoice_id
	AND fpay.action_date <= &BIS_CURRENT_ASOF_DATE   /*added code for bug no.3113879*/
	AND t.term_id = f.terms_id
	AND t.language = userenv(''LANG'')
	AND f.invoice_id =hold.invoice_id (+)
	AND f.invoice_id =hold1.invoice_id (+)
	GROUP BY f.invoice_number,
	         f.invoice_id,
	         f.invoice_type,
	         f.invoice_date,
	         f.entered_date,
	         f.invoice_currency_code,
	         f.invoice_amount,
	         f.'||l_invoice_amount||',
	         hold1.FII_MEASURE11,
	         hold1.FII_MEASURE13,
	         f.'||l_discount_offered||',
	         hold.FII_MEASURE12,
	         f.dist_count,
	         t.name,
	         f.source) g ) h
       WHERE (rnk between &START_INDEX AND &END_INDEX or &END_INDEX = -1)
		  &ORDER_BY_CLAUSE
		';


    WHEN 'FII_AP_INTEREST_INV_ENT_DTL' THEN  -- 16th, Interest Invoices Entered Detail
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
	h.FII_MEASURE18 FII_MEASURE18,
	h.FII_MEASURE21 FII_MEASURE21,
	h.FII_MEASURE22 FII_MEASURE22,
	h.FII_MEASURE23 FII_MEASURE23,
	h.FII_MEASURE24 FII_MEASURE24,
	h.FII_MEASURE25 FII_MEASURE25,
	h.FII_MEASURE26 FII_MEASURE26,
	'''||l_url_1||'''	FII_ATTRIBUTE10,
	'''||l_url_2||'''	FII_ATTRIBUTE11,
	'''||l_url_4||'''	FII_ATTRIBUTE12,
	'''||l_url_3||'''	FII_ATTRIBUTE13

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
		g.FII_MEASURE18 FII_MEASURE18,
		g.FII_MEASURE21 FII_MEASURE21,
		g.FII_MEASURE22 FII_MEASURE22,
		g.FII_MEASURE23 FII_MEASURE23,
		g.FII_MEASURE24 FII_MEASURE24,
		g.FII_MEASURE25 FII_MEASURE25,
		g.FII_MEASURE26 FII_MEASURE26,
		(rank () over(&ORDER_BY_CLAUSE nulls last,g.FII_MEASURE2)) -1 rnk
	FROM
	(
	SELECT f.invoice_number					FII_MEASURE1,
	       f.invoice_id						FII_MEASURE2,
	       f.invoice_type					FII_MEASURE3,
	       to_char(f.invoice_date, '''||l_date_mask||''')  	FII_MEASURE4,
	       to_char(f.entered_date, '''||l_date_mask||''')  	FII_MEASURE5,
	       to_char(MIN(fpay.due_date), '''||l_date_mask||''')  	FII_MEASURE6,
	       f.invoice_currency_code				FII_MEASURE7,
	       f.invoice_amount						FII_MEASURE8,
	       f.'||l_invoice_amount||'					FII_MEASURE9,
	       sum(fpay.'||l_payment_amount||')					FII_MEASURE10,
	       decode(nvl(hold1.FII_MEASURE11, ''N''), ''Y'', '''||l_yes||''', ''N'','''||l_no||''')   FII_MEASURE11,
	       nvl(hold.FII_MEASURE12,0)					FII_MEASURE12,
	       nvl(hold1.FII_MEASURE13,0)					FII_MEASURE13,
	       f.dist_count						FII_MEASURE14,
		t.name							FII_MEASURE15,
	       f.source						FII_MEASURE16,
		max(fpay.check_id)						FII_MEASURE18,
	       to_number(null)  				FII_MEASURE21,
	       sum(f.'||l_invoice_amount||') over()				FII_MEASURE22,
	       sum(sum(fpay.'||l_payment_amount||')) over()			FII_MEASURE23,
	       sum(nvl(hold.FII_MEASURE12,0)) over()			FII_MEASURE24,
	       sum(nvl(hold1.FII_MEASURE13,0)) over()			FII_MEASURE25,
	       sum(f.dist_count) over()				FII_MEASURE26
	FROM fii_ap_invoice_b		f,
	     fii_ap_pay_sched_b		fpay,
	     ap_terms_tl		t,
	     (SELECT  invoice_id,
                      COUNT(hold_date)  FII_MEASURE12
	      FROM fii_ap_inv_holds_b f
	      WHERE hold_date BETWEEN :PERIOD_START AND &BIS_CURRENT_ASOF_DATE
     	      '||l_org_where||' '||l_sup_where||'
	      GROUP BY invoice_id
	     ) hold,
             (SELECT  invoice_id,
		      ''Y''             FII_MEASURE11,
                      sum(days_on_hold) FII_MEASURE13
              FROM fii_ap_hhist_ib_mv f
              WHERE 1 =1
     	      '||l_org_where||' '||l_sup_where||'
	      GROUP BY invoice_id
	     ) hold1
	WHERE f.invoice_type = ''INTEREST''
	'||l_org_where||' '||l_sup_where||'
	AND f.cancel_flag = ''N''                    /*Added code for bug. no.3084280 */
	AND f.entered_date <= &BIS_CURRENT_ASOF_DATE
	AND f.entered_date >= :PERIOD_START
	AND f.invoice_id = fpay.invoice_id
	AND fpay.action_date <= &BIS_CURRENT_ASOF_DATE    /*added code for bug no.3113879*/
	AND t.term_id = f.terms_id
	AND t.language = userenv(''LANG'')
	AND f.invoice_id =hold.invoice_id (+)
	AND f.invoice_id =hold1.invoice_id (+)
	GROUP BY f.invoice_number,
	         f.invoice_id,
	         f.invoice_type,
	         f.invoice_date,
	         f.entered_date,
	         f.invoice_currency_code,
	         f.invoice_amount,
	         f.'||l_invoice_amount||',
	         hold1.FII_MEASURE11,
	         hold1.FII_MEASURE13,
	         f.'||l_discount_offered||',
	         hold.FII_MEASURE12,
	         f.dist_count,
	         t.name,
	         f.source) g ) h
       WHERE (rnk between &START_INDEX AND &END_INDEX or &END_INDEX = -1)
		  &ORDER_BY_CLAUSE
		';


    WHEN 'FII_AP_INV_HOLD_ACTIVITY_DTL' THEN  -- 17th, Invoices Placed on Hold Detail

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
	h.FII_MEASURE18 FII_MEASURE18,
	h.FII_MEASURE21 FII_MEASURE21,
	h.FII_MEASURE22 FII_MEASURE22,
	h.FII_MEASURE23 FII_MEASURE23,
	h.FII_MEASURE24 FII_MEASURE24,
	h.FII_MEASURE25 FII_MEASURE25,
	h.FII_MEASURE26 FII_MEASURE26,
	'''||l_url_1||'''	FII_ATTRIBUTE10,
	'''||l_url_2||'''	FII_ATTRIBUTE11,
	'''||l_url_4||'''	FII_ATTRIBUTE12,
	'''||l_url_3||'''	FII_ATTRIBUTE13

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
		g.FII_MEASURE18 FII_MEASURE18,
		g.FII_MEASURE21 FII_MEASURE21,
		g.FII_MEASURE22 FII_MEASURE22,
		g.FII_MEASURE23 FII_MEASURE23,
		g.FII_MEASURE24 FII_MEASURE24,
		g.FII_MEASURE25 FII_MEASURE25,
		g.FII_MEASURE26 FII_MEASURE26,
		(rank () over(&ORDER_BY_CLAUSE nulls last,g.FII_MEASURE2)) -1 rnk
	FROM
	(
	SELECT
        f.invoice_number     FII_MEASURE1,
        f.invoice_id      FII_MEASURE2,
        f.invoice_type     FII_MEASURE3,
        to_char(f.invoice_date, '''||l_date_mask||''')
FII_MEASURE4,
        to_char(f.entered_date, '''||l_date_mask||''')
FII_MEASURE5,
        to_char(pay.due_date, '''||l_date_mask||''')   FII_MEASURE6,
        f.invoice_currency_code    FII_MEASURE7,
        f.invoice_amount      FII_MEASURE8,
        f.'||l_invoice_amount||'     FII_MEASURE9,
        nvl(pay.payment_amount, 0)     FII_MEASURE10,
        decode(nvl(hold1.FII_MEASURE11, ''N''), ''Y'', '''||l_yes||''',
''N'','''||l_no||''')   FII_MEASURE11,
        nvl(hold.FII_MEASURE12,0)     FII_MEASURE12,
        nvl(hold1.FII_MEASURE13,0)     FII_MEASURE13,
        f.dist_count      FII_MEASURE14,
        t.name       FII_MEASURE15,
        f.source      FII_MEASURE16,
        null                               FII_MEASURE18,
        to_number(null)     FII_MEASURE21,
        sum(f.'||l_invoice_amount||') over()    FII_MEASURE22,
        sum(nvl(pay.payment_amount, 0)) over()   FII_MEASURE23,
        sum(nvl(hold.FII_MEASURE12,0)) over()   FII_MEASURE24,
        sum(nvl(hold1.FII_MEASURE13,0)) over()   FII_MEASURE25,
        sum(f.dist_count) over()    FII_MEASURE26
        FROM fii_ap_invoice_b  f,
	(SELECT  invoice_id,
                     COUNT(hold_date)  FII_MEASURE12
	      FROM fii_ap_inv_holds_b f
	      WHERE hold_date BETWEEN :PERIOD_START AND &BIS_CURRENT_ASOF_DATE
     	      '||l_org_where||' '||l_sup_where||'
	      GROUP BY invoice_id
	     ) hold,
             (SELECT  invoice_id,
		      ''Y''             FII_MEASURE11,
                      sum(days_on_hold) FII_MEASURE13
              FROM fii_ap_hhist_ib_mv f
              WHERE 1 =1
     	      '||l_org_where||' '||l_sup_where||'
	      GROUP BY invoice_id
	     ) hold1,
           (SELECT fpay.invoice_id,
                  sum(fpay.'||l_payment_amount||') payment_amount,
                  min(fpay.due_date) due_date
            FROM  fii_ap_pay_sched_b fpay
            WHERE   fpay.action_date >= :PERIOD_START
            AND   fpay.action_date <= &BIS_CURRENT_ASOF_DATE
            AND   fpay.action <> ''PREPAYMENT''
            AND   fpay.invoice_id in
                  (SELECT f.invoice_id
                   FROM fii_ap_inv_holds_b f
                   WHERE f.hold_date BETWEEN :PERIOD_START AND &BIS_CURRENT_ASOF_DATE
     	           '||l_org_where||' '||l_sup_where||'
                   )
            GROUP BY fpay.invoice_id
          ) pay,
      ap_terms_tl  t
    WHERE f.cancel_flag = ''N'' /*Added code for bug. no.3084280 */
    AND f.invoice_id = hold.invoice_id
    AND f.invoice_id = pay.invoice_id(+)
    AND f.invoice_id = hold1.invoice_id
    AND hold.invoice_id = hold1.invoice_id
    AND t.term_id = f.terms_id
    AND t.language = userenv(''LANG'')
    GROUP BY f.invoice_number,
          f.invoice_id,
          f.invoice_type,
          f.invoice_date,
          f.entered_date,
          f.invoice_currency_code,
          f.invoice_amount,
          f.'||l_invoice_amount||',
          hold1.FII_MEASURE11,
          hold.FII_MEASURE12,
          hold1.FII_MEASURE13,
          f.'||l_discount_offered||',
          f.dist_count,
          t.name,
          f.source,
          pay.payment_amount,
          pay.due_date) g ) h
       WHERE (rnk between &START_INDEX AND &END_INDEX or &END_INDEX = -1)
		  &ORDER_BY_CLAUSE
  ';


    WHEN 'FII_EA_AP_TRAN' THEN  -- Drill from Expense Analysis Payables Invoices report
      sqlstmt := '
Select
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
	h.FII_MEASURE18 FII_MEASURE18,
	h.FII_MEASURE21 FII_MEASURE21,
	h.FII_MEASURE22 FII_MEASURE22,
	h.FII_MEASURE23 FII_MEASURE23,
	h.FII_MEASURE24 FII_MEASURE24,
	h.FII_MEASURE25 FII_MEASURE25,
	h.FII_MEASURE26 FII_MEASURE26,
	'''||l_url_1||'''	FII_ATTRIBUTE10,
	'''||l_url_2||'''	FII_ATTRIBUTE11,
	'''||l_url_4||'''	FII_ATTRIBUTE12, /* Bug 3044407: Swapped the URLs of */
	'''||l_url_3||'''	FII_ATTRIBUTE13  /* FII_ATTRIBUTE12 and FII_ATTRIBUTE13 */

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
		g.FII_MEASURE18 FII_MEASURE18,
		g.FII_MEASURE21 FII_MEASURE21,
		g.FII_MEASURE22 FII_MEASURE22,
		g.FII_MEASURE23 FII_MEASURE23,
		g.FII_MEASURE24 FII_MEASURE24,
		g.FII_MEASURE25 FII_MEASURE25,
		g.FII_MEASURE26 FII_MEASURE26,
		(rank () over(&ORDER_BY_CLAUSE nulls last,g.FII_MEASURE2)) -1 rnk
	FROM

	(SELECT f.invoice_number						FII_MEASURE1,
	       f.invoice_id						FII_MEASURE2,
	       f.invoice_type						FII_MEASURE3,
	       f.invoice_date				  		FII_MEASURE4,
	       f.entered_date				  		FII_MEASURE5,
	       MIN(f.due_Date)				          	FII_MEASURE6,
	       f.invoice_currency_code					FII_MEASURE7,
	       f.invoice_amount						FII_MEASURE8,
	       f.'||l_invoice_amount||'					FII_MEASURE9,
               SUM(CASE WHEN base.action = ''PREPAYMENT'' THEN
                             DECODE(SIGN(base.action_date-&BIS_CURRENT_ASOF_DATE),1,0,
                                    NVL(base.'||l_payment_amount||',0))
                        WHEN NVL(base.action_date, &BIS_CURRENT_ASOF_DATE) <= &BIS_CURRENT_ASOF_DATE THEN
                             NVL(base.'||l_payment_amount||' ,0)
                        ELSE 0
                   END) FII_MEASURE10,
	       decode(nvl(hold1.FII_MEASURE11, ''N''), ''Y'', '''||l_yes||''', ''N'','''||l_no||''')   FII_MEASURE11,
	       nvl(hold.FII_MEASURE12,0)				FII_MEASURE12,
	       nvl(hold1.FII_MEASURE13,0)				FII_MEASURE13,
	       f.dist_count						FII_MEASURE14,
		   t.name						FII_MEASURE15,
	       f.source							FII_MEASURE16,
	       max(base.check_id)					FII_MEASURE18,
	       to_number(null) 				                FII_MEASURE21,
	       sum(f.'||l_invoice_amount||') over()			FII_MEASURE22,
               SUM(SUM(CASE WHEN base.action = ''PREPAYMENT'' THEN
                                 DECODE(SIGN(base.action_date-&BIS_CURRENT_ASOF_DATE),1,0,
                                        NVL(base.'||l_payment_amount||',0))
                            WHEN NVL(base.action_date, &BIS_CURRENT_ASOF_DATE) <= &BIS_CURRENT_ASOF_DATE THEN
                                 NVL(base.'||l_payment_amount||' ,0)
                            ELSE 0
                       END)) OVER () FII_MEASURE23,
	       sum(nvl(hold.FII_MEASURE12,0)) over()			FII_MEASURE24,
	       sum(nvl(hold1.FII_MEASURE13,0)) over()			FII_MEASURE25,
	       sum(f.dist_count) over()					FII_MEASURE26
	FROM fii_ap_invoice_b		f,
	     fii_ap_pay_sched_b		base,
	     ap_terms_tl		t,
	     (SELECT  invoice_id,
                      COUNT(hold_date)  FII_MEASURE12
	      FROM fii_ap_inv_holds_b f
	      WHERE hold_date BETWEEN :PERIOD_START AND &BIS_CURRENT_ASOF_DATE
     	      '||l_org_where||' '||l_sup_where||'
	      GROUP BY invoice_id
	     ) hold,
             (SELECT  invoice_id,
		      ''Y''             FII_MEASURE11,
                      sum(days_on_hold) FII_MEASURE13
              FROM fii_ap_hhist_ib_mv f
              WHERE 1 =1
     	      '||l_org_where||' '||l_sup_where||'
	      GROUP BY invoice_id
	     ) hold1
	WHERE
        f.invoice_id = &FII_AP_INV_ID
	'||l_org_where||' '||l_sup_where||'
	AND f.cancel_flag = ''N''                    /*Added code for bug. no.3084280 */
	AND base.invoice_id (+) = f.invoice_id /*added outer join and the decode condition above for bug no.3063372*/
	AND decode(base.supplier_id,null,1,decode(base.supplier_id,f.supplier_id,1,0))=1
	AND decode(base.org_id,null,1,decode(base.org_id,f.org_id,1,0))=1
	AND t.term_id = f.terms_id
	AND t.language = userenv(''LANG'')
	AND f.invoice_id =hold.invoice_id (+)
	AND f.invoice_id =hold1.invoice_id (+)
	GROUP BY f.invoice_number,
	         f.invoice_id,
	         f.invoice_type,
	         f.invoice_date,
	         f.entered_date,
	         f.invoice_currency_code,
	         f.invoice_amount,
	         f.'||l_invoice_amount||',
	         hold1.FII_MEASURE11,
	         hold1.FII_MEASURE13,
	         f.'||l_discount_offered||',
	         hold.FII_MEASURE12,
	         f.dist_count,
	         t.name,
	         f.source) g ) h
       WHERE (rnk between &START_INDEX AND &END_INDEX or &END_INDEX = -1)
		  &ORDER_BY_CLAUSE
		';
    ELSE -- dummy code
      sqlstmt := 'Unknown report source';


  END CASE;

-- Attach bind parameters
  FII_PMV_UTIL.bind_variable(
	p_sqlstmt=>sqlstmt,
	p_page_parameter_tbl=>p_page_parameter_tbl,
	p_sql_output=>inv_dtl_sql,
	p_bind_output_table=>inv_dtl_output,
	p_period_start=>l_period_start);
--	p_record_type_id=>l_record_type_id,


END get_inv_activity_detail;



END FII_AP_INV_ACTIVITY_DETAIL;


/
