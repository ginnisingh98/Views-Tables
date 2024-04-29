--------------------------------------------------------
--  DDL for Package Body FII_AP_PAY_STATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AP_PAY_STATUS" AS
/* $Header: FIIAPPSB.pls 120.5 2007/05/07 14:11:18 hsoorea ship $ */

PROCEDURE GET_OPEN_PAY_TABLE_PORTLET (
	p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
	open_pay_sum_sql        OUT NOCOPY VARCHAR2,
	open_pay_sum_output     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
	i                       NUMBER;
	l_viewby_dim            VARCHAR2(240);  -- what is the viewby
	l_as_of_date            DATE;
	l_organization          VARCHAR2(240);
	l_currency              VARCHAR2(240);  -- random size, possibly high
	l_viewby_id             VARCHAR2(240);  -- org_id or supplier_id
	l_record_type_id        NUMBER;         --
	l_gid                   NUMBER;         -- 0,4 or 8
	l_viewby_string         VARCHAR2(240);
	l_org_where             VARCHAR2(240);
	l_sup_where             VARCHAR2(240);
	l_curr_suffix		VARCHAR2(240);
	sqlstmt			VARCHAR2(14000);
	l_supplier              VARCHAR2(240);
	l_period_type		VARCHAR2(240);
	l_invoice_number	VARCHAR2(240);
	l_url_1			VARCHAR2(1000);
	l_url_2			VARCHAR2(1000);
	l_url_3			VARCHAR2(1000);
--        l_pper_end_date         DATE;
  --      l_asof_date_julien      NUMBER;
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

--  l_record_type_id := 1143;	-- no other value possible in this report
  l_record_type_id := 512;

--  l_asof_date_julien := to_number(to_char(l_as_of_date,'J'));

-- so that no conditional query construction is required
  IF(l_org_where is null) THEN
	l_org_where := ' ';
  END IF;

  IF(l_sup_where is null) THEN
	l_sup_where := ' ';
  END IF;

--       l_pper_end_date :=  fii_time_api.ent_pper_end(l_as_of_date);

-- To implement the selective drill functionality
/*CHANGED THE DRILLS FOR BUG NO.3096365*/
/* Changed drill l_url_1 to drill to Unpaid Invoice Detail Report: Bug 3096072 */

 -- l_url_1 := 'pFunctionName=FII_AP_OPEN_PAY_SUM&VIEW_BY=SUPPLIER+POA_SUPPLIERS&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';

  l_url_1 := 'pFunctionName=FII_AP_UNPAID_INV_DETAIL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_UNPAID_INV_DETAIL';
  l_url_2 := 'pFunctionName=FII_AP_PAYMENT_DETAIL&VIEW_BY_NAME=VIEW_BY_ID&FII_TIME_ENT_PERIOD=TIME+FII_TIME_ENT_PERIOD&pParamIds=Y';
  l_url_3 := 'pFunctionName=FII_AP_PAYMENT_DETAIL&VIEW_BY_NAME=VIEW_BY_ID&FII_TIME_ENT_PERIOD=TIME+FII_TIME_ENT_PERIOD&pParamIds=Y';

/*   Added FII_MEASURE15 for bug # 3343566 . We encounter an error when we hit the next button to
render the next 15 records.According to PMV, it is because we did not have an ak region item with sort
sequence equal to 1. We cannot change the existing ak region item(Amount) with sort sequence 2 to
1 because we don't want the triangle to be displayed. For the same we have added
a hidden dummy ak region item same as the Amount column and specified the sort sequence to 1 . */


/*--------------------------------------------------------------+
 |      VIEWBY          - Either Operating Unit / Supplier      |
 |      VIEWBYID        - Either org_id / supplier_id           |
 |      FII_MEASURE1    - Open Payables Amount                  |
 |      FII_MEASURE15    - Open Payables Amount                  |
 |      FII_MEASURE2    - Past Due Amount                       |
 |      FII_MEASURE4    - Days Past Due                         |
 |      FII_MEASURE5    - On Time Payment                       |
 |      FII_MEASURE6    - Late Payment                          |
 |      FII_MEASURE7    - Paid Amount                           |
 |	FII_MEASURE9-14	- Grand Total columns		         	|
 +--------------------------------------------------------------*/

 /* Made changes for bug # 3611195. Added or bitand(cal.record_type_id,64)=64 to where clause to make sure
 month data is also selected and made corresponding changes in Select clause.*/

-- Construct the sql query to be sent

  sqlstmt := '
        SELECT viewby_dim.value                           VIEWBY,
               viewby_dim.id                              VIEWBYID,
               sum(f.FII_MEASURE1)                        FII_MEASURE1,
               sum(f.FII_MEASURE15)                        FII_MEASURE15,
               sum(f.FII_MEASURE2)                        FII_MEASURE2,
               sum(f.FII_MEASURE4)                        FII_MEASURE4,
               sum(f.FII_MEASURE5)                        FII_MEASURE5,
               sum(f.FII_MEASURE6)                        FII_MEASURE6,
               sum(f.FII_MEASURE7)                        FII_MEASURE7,
               sum(f.FII_MEASURE9)                        FII_MEASURE9,
               sum(f.FII_MEASURE10)                       FII_MEASURE10,
               sum(f.FII_MEASURE11)                       FII_MEASURE11,
               sum(f.FII_MEASURE12)                       FII_MEASURE12,
               sum(f.FII_MEASURE13)                       FII_MEASURE13,
               sum(f.FII_MEASURE14)                       FII_MEASURE14,
               '''||l_url_1||'''         		               FII_ATTRIBUTE5,
               '''||l_url_2||'''	                		       FII_ATTRIBUTE6,
               '''||l_url_3||'''		    	                   FII_ATTRIBUTE7
        from
          (select ID,
                  FII_MEASURE1,
                  FII_MEASURE15,
                  FII_MEASURE2,
                  FII_MEASURE4,
                  FII_MEASURE5,
                  FII_MEASURE6,
                  FII_MEASURE7,
                  ( rank() over (&ORDER_BY_CLAUSE nulls last, ID)) - 1 rnk,
                  SUM(FII_MEASURE1) OVER()                     FII_MEASURE9,
                  DECODE(NVL(FII_MEASURE1,0), 0, 0,(SUM(FII_MEASURE2) OVER()/
                      SUM(FII_MEASURE1) OVER() * 100))         FII_MEASURE10,
        --          DECODE(NVL(FII_MEASURE2,0), 0, 0,sum(FII_MEASURE2 * days_past_due) over()/
        --              sum(FII_MEASURE2) over() )               FII_MEASURE11,
                  DECODE(sum(FII_MEASURE2) over (), 0, 0,
                       :ASOF_DATE_JULIEN  -  sum(wt_open_past_due_amt) over()/
                      sum(FII_MEASURE2) over() )               FII_MEASURE11,
                  SUM(FII_MEASURE5) OVER()                     FII_MEASURE12,
                  SUM(FII_MEASURE6) OVER()                     FII_MEASURE13,
                  DECODE(NVL((FII_MEASURE5+FII_MEASURE6), 0), 0, 0,(SUM(FII_MEASURE6) OVER() /
                      SUM(FII_MEASURE5+FII_MEASURE6) OVER() * 100)) FII_MEASURE14
           FROM
               (SELECT  f.'||l_viewby_id||'                    ID,
                        SUM(CASE WHEN bitand(cal.record_type_id, :RECORD_TYPE_ID) = :RECORD_TYPE_ID
                                 THEN f.open_amt'||l_curr_suffix||' ELSE 0 END)     FII_MEASURE1,
                        SUM(CASE WHEN bitand(cal.record_type_id, :RECORD_TYPE_ID) = :RECORD_TYPE_ID
                                 THEN f.open_amt'||l_curr_suffix||' ELSE 0 END)     FII_MEASURE15,
                        SUM(CASE WHEN bitand(cal.record_type_id, :RECORD_TYPE_ID) = :RECORD_TYPE_ID
                                 THEN f.open_past_due_amt'||l_curr_suffix||' ELSE 0 END)  FII_MEASURE2,
                        decode(sum(CASE WHEN bitand(cal.record_type_id, :RECORD_TYPE_ID) = :RECORD_TYPE_ID  then f.open_past_due_amt'||l_curr_suffix||' else 0 end) ,0,0,
                            :ASOF_DATE_JULIEN   -   SUM(CASE WHEN bitand(cal.record_type_id, :RECORD_TYPE_ID) = :RECORD_TYPE_ID then f.wt_open_past_due_amt'||l_curr_suffix||' else 0 end)/
			    sum(CASE WHEN bitand(cal.record_type_id, :RECORD_TYPE_ID) = :RECORD_TYPE_ID then f.open_past_due_amt'||l_curr_suffix||' else 0 end))         FII_MEASURE4,
                        --  0                                      days_past_due,
                        SUM(CASE WHEN bitand(cal.record_type_id, 64) = 64
                                 THEN f.on_time_payment_amt'||l_curr_suffix||' ELSE 0 END)
                                                               FII_MEASURE5,
                        SUM(CASE WHEN bitand(cal.record_type_id, 64) = 64
                                 THEN f.late_payment_amt'||l_curr_suffix||' ELSE 0 END)
                                                               FII_MEASURE6,
                        SUM(CASE WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE THEN (case when bitand(cal.record_type_id, :RECORD_TYPE_ID) = :RECORD_TYPE_ID then  f.open_payment_amt'||l_curr_suffix||' else 0 end) ELSE 0 END)
                                                               FII_MEASURE7,
                        SUM(CASE WHEN bitand(cal.record_type_id, :RECORD_TYPE_ID) = :RECORD_TYPE_ID
                                 THEN f.wt_open_past_due_amt'||l_curr_suffix||' ELSE 0 END)   wt_open_past_due_amt
                FROM    FII_AP_LIA_IB_MV f,
                        FII_TIME_STRUCTURES cal
                WHERE   f.time_id = cal.time_id
                AND     f.period_type_id  = cal.period_type_id  '||l_sup_where||'  '||l_org_where||'
                AND     (bitand(cal.record_type_id, :RECORD_TYPE_ID) = :RECORD_TYPE_ID or bitand(cal.record_type_id,64)=64)
                AND     cal.report_date in (&BIS_CURRENT_ASOF_DATE)
                AND     f.gid             = :GID
                GROUP   BY f.'||l_viewby_id||'
               )) f,
               ('||l_viewby_string||') viewby_dim
        WHERE  f.id = viewby_dim.id
        and (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
        GROUP  BY viewby_dim.value, viewby_dim.id
	       &ORDER_BY_CLAUSE';

-- Attach bind parameters
  FII_PMV_UTIL.bind_variable(
	p_sqlstmt=>sqlstmt,
	p_page_parameter_tbl=>p_page_parameter_tbl,
	p_sql_output=>open_pay_sum_sql,
	p_bind_output_table=>open_pay_sum_output,
	p_invoice_number=>l_invoice_number,
	p_record_type_id=>l_record_type_id,
	p_view_by=>l_viewby_id,
	p_gid=>l_gid);

END GET_OPEN_PAY_TABLE_PORTLET;

/***************************************************************************/
-- For the Invoices Aging Portlet Report, Payables Status Page --

PROCEDURE get_inv_aging (
        p_page_parameter_tbl   IN  BIS_PMV_PAGE_PARAMETER_TBL,
        inv_age_sql            OUT NOCOPY VARCHAR2,
        inv_age_output         OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
	l_viewby_dim            VARCHAR2(240);  -- what is the viewby
	l_as_of_date            DATE;
	l_organization          VARCHAR2(240);
	l_supplier              VARCHAR2(240);
	l_currency              VARCHAR2(240);  -- random size, possibly high
	l_viewby_id             VARCHAR2(240);  -- org_id or supplier_id
	l_record_type_id        NUMBER;         --
	l_gid                   NUMBER;         -- 0,4 or 8
	l_viewby_string         VARCHAR2(240);
	l_org_where             VARCHAR2(240);
	l_sup_where             VARCHAR2(240);
	l_curr_suffix		VARCHAR2(240);
	sqlstmt			VARCHAR2(14000);
	l_period_type		VARCHAR2(240);
	l_invoice_number	VARCHAR2(240);
	stmt1			VARCHAR2(500);
        stmt2			VARCHAR2(500);
        stmt3			VARCHAR2(500);
        stmt4			VARCHAR2(500);
        stmt5			VARCHAR2(500);
        stmt6			VARCHAR2(500); /* Added for bug 3120355 */
BEGIN

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

 --  l_record_type_id := 1143;	-- no other value possible here
 l_record_type_id := 512;

/*--------------------------------------------------------------+
 |      VIEWBY          - Either Operating Unit / Supplier      |
 |      VIEWBYID        - Either org_id / supplier_id           |
 |	FII_MEASURE1	- Invoice Age				|
 |	FII_MEASURE2	- Number of Invoices			|
 +--------------------------------------------------------------*/

/****************Messages to be displayed in the report**************/ /* Added for bug 3120355 */
       stmt1 :=  FND_MESSAGE.get_string('FII', 'FII_AP_PAST_DUE1');
       stmt2 :=  FND_MESSAGE.get_string('FII', 'FII_AP_PAST_DUE2');
       stmt3 :=  FND_MESSAGE.get_string('FII', 'FII_AP_PAST_DUE3');
       stmt4 :=  FND_MESSAGE.get_string('FII', 'FII_AP_DUE3');
       stmt5 :=  FND_MESSAGE.get_string('FII', 'FII_AP_DUE2');
       stmt6 :=  FND_MESSAGE.get_string('FII', 'FII_AP_DUE1');

-- Construct the sql query to be sent
-- Following sql changed for customer bug-6028881. Added supplier to where clause
  sqlstmt := '

	SELECT decode(t1.multiplier,''1'', :FIIBIND1,
                        ''2'', :FIIBIND2,
                        ''3'', :FIIBIND3,
                        ''4'', :FIIBIND4,
                        ''5'', :FIIBIND5,
                        ''6'', :FIIBIND6) FII_MEASURE1,
          DECODE(t1.multiplier, ''1'', SUM(open_past_due_bucket1_count),
                            ''2'', SUM(open_past_due_bucket2_count),
                            ''3'', SUM(open_past_due_bucket3_count),
                            ''4'', SUM(open_due_bucket3_count),
                            ''5'', SUM(open_due_bucket2_count),
                            ''6'', SUM(open_due_bucket1_count)) FII_MEASURE2
   FROM FII_AP_LIA_IB_MV f,
        fii_time_structures cal,
        gl_row_multipliers t1
   WHERE t1.multiplier <= 6
   AND   f.time_id = cal.time_id
   AND   f.period_type_id = cal.period_type_id
   '||l_org_where||'
   '||l_sup_where||'
   AND   bitand(cal.record_type_id, :RECORD_TYPE_ID) = :RECORD_TYPE_ID
   AND   cal.report_date in (&BIS_CURRENT_ASOF_DATE)
   AND   f.gid = :GID
   Group by t1.multiplier order by t1.multiplier asc';

-- Attach bind parameters
  FII_PMV_UTIL.bind_variable(
	p_sqlstmt=>sqlstmt,
	p_page_parameter_tbl=>p_page_parameter_tbl,
	p_sql_output=>inv_age_sql,
	p_bind_output_table=>inv_age_output,
	p_invoice_number=>l_invoice_number,
	p_record_type_id=>l_record_type_id,
	p_view_by=>l_viewby_id,
	p_gid=>l_gid,

        p_fiibind1=>stmt1,
        p_fiibind2=>stmt2,
        p_fiibind3=>stmt3,
        p_fiibind4=>stmt4,
        p_fiibind5=>stmt5,
        p_fiibind6=>stmt6
);

END get_inv_aging;

PROCEDURE get_pay_liability_pie (
	p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
	open_pay_sum_pie_sql        OUT NOCOPY VARCHAR2,
	open_pay_sum_pie_output     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
	l_viewby_dim            VARCHAR2(240);  -- what is the viewby
	l_as_of_date            DATE;
	l_organization          VARCHAR2(240);
	l_currency              VARCHAR2(240);  -- random size, possibly high
	l_viewby_id             VARCHAR2(240);  -- org_id or supplier_id
	l_record_type_id        NUMBER;         --
	l_gid                   NUMBER;         -- 0,4 or 8
	l_viewby_string         VARCHAR2(240);
	l_org_where             VARCHAR2(240);
	l_sup_where             VARCHAR2(240);
	l_curr_suffix		VARCHAR2(240);
	l_sqlstmt			VARCHAR2(14000);
	l_supplier              VARCHAR2(240);
	l_period_type		VARCHAR2(240);
	l_invoice_number	VARCHAR2(240);

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

  -- l_record_type_id := 1143;	-- no other value possible in this report
  l_record_type_id := 512;	-- no other value possible in this report

-- so that no conditional query construction is required
  IF(l_org_where is null) THEN
	l_org_where := ' ';
  END IF;

  IF(l_sup_where is null) THEN
	l_sup_where := ' ';
  END IF;

/*--------------------------------------------------------------+
 |      VIEWBY          - Either Operating Unit / Supplier      |
 |      VIEWBYID        - Either org_id / supplier_id           |
 |      FII_MEASURE1    - Open Payables Amount                  |
 +--------------------------------------------------------------*/

-- Construct the sql query to be sent
  l_sqlstmt := '
         SELECT viewby_dim.value                         	VIEWBY,
               viewby_dim.id                              VIEWBYID,
               sum(f.FII_MEASURE1)                        FII_MEASURE1,
               sum(f.FII_MEASURE2)                        FII_MEASURE2
         FROM
         (select id,
                 FII_MEASURE1,
                 ( rank() over (&ORDER_BY_CLAUSE nulls last, id)) - 1 rnk,
                 FII_MEASURE2
          from
               (SELECT  f.'||l_viewby_id||'     id,
                        SUM(f.open_amt'||l_curr_suffix||' )	FII_MEASURE1,
                        SUM(SUM(f.open_amt'||l_curr_suffix||')) over() FII_MEASURE2,
                        SUM(f.open_count)			open_count,
                        SUM(f.open_due_count)			due_count,
                        0					weighted_avg_days_due,
			SUM(f.open_past_due_amt'||l_curr_suffix||' )
								past_due_amt,
                        SUM(f.open_past_due_count)		past_due_count,
                        0					weighted_avg_days_past_due
                FROM FII_AP_LIA_IB_MV f ,fii_time_structures cal
                WHERE f.time_id = cal.time_id
                AND   f.period_type_id  = cal.period_type_id   '||l_org_where||'
                AND   bitand(cal.record_type_id, :RECORD_TYPE_ID) = :RECORD_TYPE_ID
                AND   cal.report_date in (&BIS_CURRENT_ASOF_DATE)
                AND   f.gid             = :GID
                GROUP BY f.'||l_viewby_id||'
               ) ) f,
        ('||l_viewby_string||') viewby_dim
        WHERE f.id = viewby_dim.id
        and (f.rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
        GROUP  BY viewby_dim.value, viewby_dim.id
       	&ORDER_BY_CLAUSE';

-- Attach bind parameters
  FII_PMV_UTIL.bind_variable(
	p_sqlstmt=>l_sqlstmt,
	p_page_parameter_tbl=>p_page_parameter_tbl,
	p_sql_output=>open_pay_sum_pie_sql,
	p_bind_output_table=>open_pay_sum_pie_output,
	p_invoice_number=>l_invoice_number,
	p_record_type_id=>l_record_type_id,
	p_view_by=>l_viewby_id,
	p_gid=>l_gid);

END get_pay_liability_pie;

/***************************************************************************/
-- For the KPI Portlet, Payables Status Page --

PROCEDURE get_kpi (
        p_page_parameter_tbl   IN  BIS_PMV_PAGE_PARAMETER_TBL,
        kpi_sql            OUT NOCOPY VARCHAR2,
        kpi_output         OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
	l_viewby_dim            VARCHAR2(240);  -- what is the viewby
	l_as_of_date            DATE;
	l_organization          VARCHAR2(240);
	l_supplier              VARCHAR2(240);
	l_currency              VARCHAR2(240);  -- random size, possibly high
	l_viewby_id             VARCHAR2(240);  -- org_id or supplier_id
	l_record_type_id        NUMBER;         --
	l_gid                   NUMBER;         -- 0,4 or 8
	l_viewby_string         VARCHAR2(240);
	l_org_where             VARCHAR2(240);
	l_sup_where             VARCHAR2(240);
	l_curr_suffix           VARCHAR2(240);
	sqlstmt                 VARCHAR2(14000);
	l_period_type		         VARCHAR2(240);
	l_invoice_number	       VARCHAR2(240);


BEGIN

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

 -- l_record_type_id := 1143;	-- no other value possible here
 l_record_type_id := 512;	-- no other value possible here
 --l_asof_date_julien := to_number(to_char(l_as_of_date,'J'));
/*--------------------------------------------------------------+
 |      VIEWBY          - Either Operating Unit / Supplier      |
 |      VIEWBYID        - Either org_id / supplier_id           |
 |	FII_MEASURE1	- Invoice Age				|
 |	FII_MEASURE2	- Number of Invoices			|
 +--------------------------------------------------------------*/

-- Construct the sql query to be sent

  sqlstmt := '

	select sum(f.open_amt'||l_curr_suffix||') FII_MEASURE1,
        sum(f.open_amt'||l_curr_suffix||') - sum(f.open_past_due_amt'||l_curr_suffix||') FII_MEASURE2,
        sum(f.open_due_count) FII_MEASURE3,
        decode(SUM(open_amt'||l_curr_suffix||' - open_past_due_amt'||l_curr_suffix||'),
             0, 0,
            (SUM(dd_open_due_amt'||l_curr_suffix||') /
                     SUM(open_amt'||l_curr_suffix||' - open_past_due_amt'||l_curr_suffix||')) -
                      :ASOF_DATE_JULIEN)  FII_MEASURE4,
        sum(f.open_past_due_amt'||l_curr_suffix||') FII_MEASURE5,
        sum(f.open_past_due_count) FII_MEASURE6,
        decode(SUM(f.open_past_due_amt'||l_curr_suffix||'), 0, 0,
          :ASOF_DATE_JULIEN  - SUM(f.dd_open_past_due_amt'||l_curr_suffix||')
           /SUM(f.open_past_due_amt'||l_curr_suffix||')) FII_MEASURE7,
        sum(f.open_discount_remaining'||l_curr_suffix||') FII_MEASURE8,
        sum(f.open_discount_offered'||l_curr_suffix||') FII_MEASURE9,
        sum(f.inv_on_hold_amt'||l_curr_suffix||') FII_MEASURE10,
        sum(f.inv_on_hold_amt'||l_curr_suffix||')/sum(f.open_amt'||l_curr_suffix||')*100 FII_MEASURE11
 from FII_AP_LIA_KPI_MV f,
     fii_time_structures cal
WHERE f.time_id = cal.time_id
AND   f.period_type_id = cal.period_type_id
'||l_org_where||'
AND   bitand(cal.record_type_id, :RECORD_TYPE_ID) = :RECORD_TYPE_ID
AND   cal.report_date in (&BIS_CURRENT_ASOF_DATE)';

-- Attach bind parameters
  FII_PMV_UTIL.bind_variable(
	p_sqlstmt=>sqlstmt,
	p_page_parameter_tbl=>p_page_parameter_tbl,
	p_sql_output=>kpi_sql,
	p_bind_output_table=>kpi_output,
	p_invoice_number=>l_invoice_number,
	p_record_type_id=>l_record_type_id,
	p_view_by=>l_viewby_id,
	p_gid=>l_gid);

END get_kpi;

PROCEDURE get_hold_sum
     ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
       get_hold_sum_sql out NOCOPY VARCHAR2,
       get_hold_sum_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)IS

       -- declaration section
       sqlstmt          VARCHAR2(14000);

       l_as_of_date     DATE;
       l_operating_unit VARCHAR2(240);
       l_supplier       VARCHAR2(240);
       l_invoice_number VARCHAR2(240);
       l_period_type    VARCHAR2(240);
       l_record_type_id NUMBER;
       l_view_by        VARCHAR2(240);
       l_currency       VARCHAR2(240);
       l_column_name    VARCHAR2(240);
       l_table_name     VARCHAR2(240);
       l_gid            NUMBER;
       l_org_where      VARCHAR2(240);
       l_supplier_where VARCHAR2(240);
       l_url_1            VARCHAR2(240);
       l_url_4            VARCHAR2(240);
       l_order            VARCHAR2(500);
       l_order2            VARCHAR2(100);

BEGIN

-- Retrieve parameter info

       FII_PMV_Util.Get_Parameters(
       p_page_parameter_tbl,
       l_as_of_date,
       l_operating_unit,
       l_supplier,
       l_invoice_number,
       l_period_type,
       l_record_type_id,
       l_view_by,
       l_currency,
       l_column_name,
       l_table_name,
       l_gid,
       l_org_where,
       l_supplier_where
       );

-- l_record_type_id := 1143;
l_record_type_id := 512;


-- Decide on the viewby stuff and pk to be used
-- Map the l_column_name based on the selected viewby

l_url_1  := 'pFunctionName=FII_AP_INV_ON_HOLD_DETAIL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_INV_ON_HOLD_DETAIL' ;

l_url_4  := 'pFunctionName=FII_AP_HOLD_SUM&VIEW_BY=SUPPLIER+POA_SUPPLIERS&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y' ;

--  to know sort direction DESC or ASC
  IF (p_page_parameter_tbl.count > 0) THEN
     FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP
       IF p_page_parameter_tbl(i).parameter_name = 'ORDERBY' THEN
          l_order := p_page_parameter_tbl(i).parameter_value;
       END IF;
     END LOOP;
  END IF;

  IF  (INSTR(l_order,'ASC')>0) THEN
       l_order2 := 'ASC';
    ELSE
       l_order2 := 'DESC';
  END IF;


/*--------------------------------------------------------------+
 |      VIEWBY          - Either Operating Unit / Supplier      |
 |      VIEWBYID        - Either org_id / supplier_id           |
 |      FII_MEASURE1    - Invoices on Hold  Amount              |
 |      FII_MEASURE2    - Number of Invoices                    |
 |      FII_MEASURE3   - Number of Holds                       |
 |      FII_MEASURE4   - Grand Total of Invoices on Hold  Amount  |
 |      FII_MEASURE5   - Grand Total of Number of Invoices     |
 |      FII_MEASURE6   - Grand Total of Number of Holds        |
 +--------------------------------------------------------------*/

-- Construct the sql query to be sent


sqlstmt := '
       SELECT viewby_dim.value                                     VIEWBY,
              viewby_dim.id                                        VIEWBYID,
              sum(inv_on_hold_amt)                                 FII_MEASURE1,
              sum(inv_on_hold_count)                               FII_MEASURE2,
              sum(no_of_holds)                                     FII_MEASURE3,
              sum(on_hold_past_due_amt)                            FII_MEASURE4,
              sum(inv_on_hold_amt) - sum(on_hold_past_due_amt)     FII_MEASURE5,
	      sum(gt_inv_on_hold_amt)                  		   FII_MEASURE6,
              sum(gt_inv_on_hold_count)                            FII_MEASURE7,
              sum(gt_no_of_holds)                                  FII_MEASURE8,
              sum(gt_on_hold_past_due_amt)          		   FII_MEASURE9,
              sum(gt_hold_due_amt)  				   FII_MEASURE10,
              decode('''||l_view_by||''',''ORGANIZATION+FII_OPERATING_UNITS'',
                    '''||l_url_4||''', ''SUPPLIER+POA_SUPPLIERS'','''||l_url_1||''',
                    null)                             FII_ATTRIBUTE1
       FROM
             (SELECT    f.'||l_column_name||'                      id,
                       sum(f.inv_on_hold_amt'||l_currency||')      inv_on_hold_amt,
                       ( rank() over (ORDER BY sum(f.inv_on_hold_amt'||l_currency||') '||l_order2||' nulls last, f.'||l_column_name||')) - 1 rnk,
                       sum(f.inv_on_hold_count)                    inv_on_hold_count,
                       sum(f.no_of_holds)                          no_of_holds,
                       sum(f.on_hold_past_due_amt'||l_currency||') on_hold_past_due_amt,
	      sum(sum(f.inv_on_hold_amt'||l_currency||')) over()   gt_inv_on_hold_amt,
              sum(sum(inv_on_hold_count)) over()                   gt_inv_on_hold_count,
              sum(sum(no_of_holds)) over()                         gt_no_of_holds,
              sum(sum(f.on_hold_past_due_amt'||l_currency||')) over()  gt_on_hold_past_due_amt,
              sum(sum(f.inv_on_hold_amt'||l_currency||') - sum(f.on_hold_past_due_amt'||l_currency||')) over() gt_hold_due_amt
             FROM    FII_AP_HLIA_I_MV f,
                     fii_time_structures cal
             WHERE   f.time_id = cal.time_id '||l_org_where||l_supplier_where||'
             AND     f.period_type_id = cal.period_type_id
             AND     bitand(cal.record_type_id, :RECORD_TYPE_ID) = :RECORD_TYPE_ID
             AND     cal.report_date in (&BIS_CURRENT_ASOF_DATE)
             AND     f.gid =   :GID
             GROUP BY f.'||l_column_name||'
               ) f,
       ('||l_table_name||') viewby_dim
       WHERE f.id = viewby_dim.id
       and (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
       GROUP BY viewby_dim.value, viewby_dim.id
        &ORDER_BY_CLAUSE ' ;

--       Binding Section

       FII_PMV_Util.bind_variable(
       p_sqlstmt=> sqlstmt,
       p_page_parameter_tbl=>p_page_parameter_tbl,
       p_sql_output=>get_hold_sum_sql,
       p_bind_output_table=>get_hold_sum_output,
       p_record_type_id=>l_record_type_id,
       p_view_by=>l_view_by,
       p_gid=>l_gid
       );

END get_hold_sum;


END FII_AP_PAY_STATUS;


/
