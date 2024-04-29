--------------------------------------------------------
--  DDL for Package Body FII_AP_OPEN_PAY_SUM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AP_OPEN_PAY_SUM" AS
/* $Header: FIIAPS1B.pls 120.2 2006/01/26 00:02:05 vkazhipu noship $ */

-- For the Open Payables Summary report --
PROCEDURE get_pay_liability (
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
        l_asof_date_julien      NUMBER;

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

  l_record_type_id := 512;	-- no other value possible in this report

  --l_asof_date_julien := to_number(to_char(l_as_of_date,'J'));

-- so that no conditional query construction is required
  IF(l_org_where is null) THEN
	l_org_where := ' ';
  END IF;

  IF(l_sup_where is null) THEN
	l_sup_where := ' ';
  END IF;

-- To implement the selective drill functionality
  IF l_viewby_dim = 'ORGANIZATION+FII_OPERATING_UNITS' THEN
    l_url_1 := 'pFunctionName=FII_AP_OPEN_PAY_SUM&VIEW_BY=SUPPLIER+POA_SUPPLIERS&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
    l_url_2 := 'pFunctionName=FII_AP_OPEN_PAY_SUM&VIEW_BY=SUPPLIER+POA_SUPPLIERS&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
    l_url_3 := 'pFunctionName=FII_AP_OPEN_PAY_SUM&VIEW_BY=SUPPLIER+POA_SUPPLIERS&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
  ELSIF l_viewby_dim = 'SUPPLIER+POA_SUPPLIERS' THEN
    l_url_1 := 'pFunctionName=FII_AP_UNPAID_INV_DETAIL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_UNPAID_INV_DETAIL';
    l_url_2 := 'pFunctionName=FII_AP_UNPAID_INV_DUE&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_UNPAID_INV_DUE';
    l_url_3 := 'pFunctionName=FII_AP_UNPAID_INV_PAST_DUE&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_UNPAID_INV_PAST_DUE';
  END IF;

/*--------------------------------------------------------------+
 |      VIEWBY          Either Operating Unit / Supplier
 |      VIEWBYID        Either org_id / supplier_id
 |	FII_MEASURE1	Open Payables Amount
 |	FII_MEASURE2	Total Number of Invoices
 |	FII_ATTRIBUTE12	Invoices Due
 |	FII_MEASURE3	Invoices Due Amount
 |	FII_KPI2	Hidden column for Invoices due amt
 |	FII_MEASURE4	Number of Invoices
 |	FII_KPI4	Hidden column for number of invoices measure
 |	FII_ATTRIBUTE2	Legend
 |	FII_MEASURE5	Weighted Average Days Due
 |	FII_KPI5	Hidden column for weighted avg days due
 |	FII_ATTRIBUTE13	Invoices Past Due
 |	FII_MEASURE6	Invoices Past Due Amount
 |	FII_KPI6
 |	FII_MEASURE7	Number of Invoices
 | 	FII_KPI7	Hidden column for Invoice past due amt
 |	FII_ATTRIBUTE3	Legend
 |	FII_MEASURE8	Weighted Average Days Past Due
 |	FII_KPI8	Hidden column for number of invoices past due
 |	FII_MEASURE9	Grand Total (Open Payables Amount)
 |	FII_MEASURE10	Grand Total (Total Number of Invoices)
 |	FII_MEASURE11	Grand Total (Invoices Due Amount)
 |	FII_MEASURE12	Grand Total (Number of Invoices (Due))
 |	FII_MEASURE13	Grand Total (Invoices Past Due Amount)
 |	FII_MEASURE14	Grand Total (Number of Invoices (Past Due))
 |	FII_ATTRIBUTE5	Drill (Total Number of Invoices)
 |	FII_ATTRIBUTE6	Drill (Number of Invoices)
 |	FII_ATTRIBUTE7	Drill (Number of Invoices Past Due)
 |	FII_KPI1	Open Payables Amount
 |      FII_DIM1        - Grand total for use in KPI
 |      FII_DIM2        - Grand total for use in KPI
 |      FII_DIM3        - Grand total for use in KPI
 |      FII_DIM4        - Grand total for use in KPI
 +----------------------------------------------------------------*/

-- Construct the sql query to be sent
  sqlstmt := '
        SELECT viewby_dim.value                                 VIEWBY,
               viewby_dim.id                                    VIEWBYID,
               f.FII_MEASURE1                          	FII_MEASURE1,
               f.FII_MEASURE2                        	FII_MEASURE2,
               f.FII_MEASURE3    	FII_MEASURE3,
               f.FII_MEASURE4                         	FII_MEASURE4,
               f.FII_MEASURE5             	FII_MEASURE5,
               f.FII_MEASURE6                      	FII_MEASURE6,
               f.FII_MEASURE7                    	FII_MEASURE7,
               f.FII_MEASURE8        	FII_MEASURE8,
               f.FII_MEASURE9                      FII_MEASURE9,
               f.FII_MEASURE10                    FII_MEASURE10,
               f.FII_MEASURE11			 FII_MEASURE11,
               f.FII_MEASURE12                     FII_MEASURE12,
               f.FII_MEASURE13                  FII_MEASURE13,
               f.FII_MEASURE14                FII_MEASURE14,
		'''||l_url_1||'''				FII_ATTRIBUTE5,
		'''||l_url_2||'''				FII_ATTRIBUTE6,
		'''||l_url_3||'''				FII_ATTRIBUTE7,
	       to_number(null) 					FII_DIM1,
	       to_number(null)					FII_DIM2,
	       to_number(null)					FII_DIM3,
	       to_number(null)					FII_DIM4
        FROM
        (SELECT
               ID,
               FII_MEASURE1,
               FII_MEASURE2,
               FII_MEASURE3,
               FII_MEASURE4,
               FII_MEASURE5,
               FII_MEASURE6,
               FII_MEASURE7,
               FII_MEASURE8,
               SUM(FII_MEASURE1) OVER()                      FII_MEASURE9,
               SUM(FII_MEASURE2) OVER()                    FII_MEASURE10,
               SUM(FII_MEASURE3) OVER()                    FII_MEASURE11,
               SUM(FII_MEASURE4) OVER()                     FII_MEASURE12,
               SUM(FII_MEASURE6) OVER()                  FII_MEASURE13,
               SUM(FII_MEASURE7) OVER()                FII_MEASURE14,
               ( rank() over (&ORDER_BY_CLAUSE nulls last, ID)) - 1 rnk
        FROM
               (SELECT  f.'||l_viewby_id||'     id,
                        SUM(f.open_amt'||l_curr_suffix||' )	FII_MEASURE1,
                        SUM(f.open_count)			FII_MEASURE2,
                        SUM(f.open_amt'||l_curr_suffix||' ) -
                           SUM(f.open_past_due_amt'||l_curr_suffix||' )
                                                                FII_MEASURE3,
                        SUM(f.open_due_count)			FII_MEASURE4,
                        decode(SUM(open_amt'||l_curr_suffix||' - open_past_due_amt'||l_curr_suffix||'),
                               0, 0,
                                (SUM(wt_open_due_amt'||l_curr_suffix||') /
                               SUM(open_amt'||l_curr_suffix||' - open_past_due_amt'||l_curr_suffix||')) -
                                :ASOF_DATE_JULIEN )
                                                                FII_MEASURE5,
			SUM(f.open_past_due_amt'||l_curr_suffix||' )
								FII_MEASURE6,
                        SUM(f.open_past_due_count)		FII_MEASURE7,
                         decode(SUM(open_past_due_amt'||l_curr_suffix||'), 0, 0,
                                :ASOF_DATE_JULIEN  -
                                SUM(wt_open_past_due_amt'||l_curr_suffix||') /
                                SUM(open_past_due_amt'||l_curr_suffix||'))
                                                                FII_MEASURE8
                FROM FII_AP_LIA_IB_MV f ,fii_time_structures cal
                WHERE f.time_id = cal.time_id
                AND   f.period_type_id  = cal.period_type_id  '||l_sup_where||'  '||l_org_where||'
                AND   bitand(cal.record_type_id, :RECORD_TYPE_ID) = :RECORD_TYPE_ID
                AND   cal.report_date in (&BIS_CURRENT_ASOF_DATE)
                AND   f.gid             = :GID
                GROUP BY f.'||l_viewby_id||'
                HAVING (SUM(f.open_amt'||l_curr_suffix||' ) > 0
                        OR SUM(f.open_count) > 0)
               )) f,
        ('||l_viewby_string||') viewby_dim
        WHERE f.id = viewby_dim.id
        AND (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
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

END get_pay_liability;



-- For the Discount Opportunities Summary report --
PROCEDURE get_discount_opp_sum (
        p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
        disc_opp_sum_sql        OUT NOCOPY VARCHAR2,
        disc_opp_sum_output     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
	i                       NUMBER;
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
	l_url_1			VARCHAR2(1000);
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

  l_record_type_id := 512;	-- no other value possible in this report

-- so that no conditional query construction is required
  IF(l_org_where is null) THEN
	l_org_where := ' ';
  END IF;

  IF(l_sup_where is null) THEN
	l_sup_where := ' ';
  END IF;

-- To implement the selective drill functionality
  IF l_viewby_dim = 'ORGANIZATION+FII_OPERATING_UNITS' THEN
    l_url_1 := 'pFunctionName=FII_AP_DISCOUNT_OPP_SUM&VIEW_BY=SUPPLIER+POA_SUPPLIERS&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
  ELSIF l_viewby_dim = 'SUPPLIER+POA_SUPPLIERS' THEN
    l_url_1 := 'pFunctionName=FII_AP_UNPAID_INV_DETAIL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_UNPAID_INV_DETAIL';
  END IF;



/*----------------------------------------------------------------+
 |      VIEWBY          Either Operating Unit / Supplier
 |      VIEWBYID        Either org_id / supplier_id
 |	FII_ATTRIBUTE11	Open Payables
 |	FII_MEASURE1	Open Payables Amount
 |	FII_MEASURE2	Total Invoice Amount
 |	FII_MEASURE3	Total Number of Invoices
 |	FII_ATTRIBUTE12	Discount Offered
 |	FII_MEASURE4	Discount Offered
 |	FII_KPI2	Hidden column for Discount offered amt
 |	FII_MEASURE8	% Offered
 |	FII_ATTRIBUTE13	Discount Taken
 |	FII_MEASURE5	Discount Taken
 |	FII_ATTRIBUTE6	Discount Remaining
 |	FII_MEASURE9	% Taken of Offered
 |	FII_ATTRIBUTE14	Discount Lost
 |	FII_MEASURE6	Discount Lost
 |	FII_ATTRIBUTE3	Discount Lost
 |	FII_MEASURE10	% Lost of Offered
 |	FII_ATTRIBUTE10	Discount Remaining
 |	FII_MEASURE7	Discount Remaining
 |	FII_KPI1	Hidden column for Discount remaining Amount
 |	FII_ATTRIBUTE2	Discount Taken
 |	FII_MEASURE11	% Remaining of Offered
 |	FII_MEASURE13	Grand Total (Open Payables Amount)
 |	FII_MEASURE14	Grand Total (Total Invoice Amount)
 |	FII_MEASURE15	Grand Total (Total Number of Invoices)
 | 	FII_MEASURE16	Grand Total (Discount Offered)
 |	FII_MEASURE17	Grand Total (Discount Taken)
 |	FII_MEASURE18	Grand Total (Discount Lost)
 |	FII_MEASURE19	Grand Total (Discount Remaining)
 | 	FII_MEASURE20	Grand Total (% Offered)
 |	FII_MEASURE21	Grand Total (% Taken of Offered)
 |	FII_MEASURE22	Grand Total (% Lost of Offered)
 |	FII_MEASURE23	Grand Total (% Remaining of Offered)
 |	FII_ATTRIBUTE5	Drill (Total Number of Invoices)
 |	FII_CV1		Discount Offered
 |	FII_CV2		% Remaining
 |	FII_CV3		% Lost
 +------------------------------------------------------------------*/

-- Construct the sql query to be sent

  sqlstmt := '
	SELECT viewby_dim.value		                	VIEWBY,
	       viewby_dim.id					VIEWBYID,
	       f.FII_MEASURE1		                       FII_MEASURE1,
	       f.FII_MEASURE2                                  FII_MEASURE2,
	       f.FII_MEASURE3				       FII_MEASURE3,
	       f.FII_MEASURE4    	                       FII_MEASURE4,
	       f.FII_MEASURE5   	                       FII_MEASURE5,
	       f.FII_MEASURE6   	                       FII_MEASURE6,
	       f.FII_MEASURE7                                  FII_MEASURE7,
        f.FII_MEASURE13                                 FII_MEASURE13,
        f.FII_MEASURE14                                 FII_MEASURE14,
        f.FII_MEASURE15                                 FII_MEASURE15,
        f.FII_MEASURE16                                 FII_MEASURE16,
        f.FII_MEASURE17                                 FII_MEASURE17,
        f.FII_MEASURE18                                 FII_MEASURE18,
        f.FII_MEASURE19                                 FII_MEASURE19,
		'''||l_url_1||'''	                	FII_ATTRIBUTE5,
		'''||l_url_1||'''				FII_DIM1  /* Added for Bug 3096072 */
	FROM
        (select
         ID,
         FII_MEASURE1,
         FII_MEASURE2,
         FII_MEASURE3,
         FII_MEASURE4,
         ( rank() over (&ORDER_BY_CLAUSE nulls last, ID)) - 1 rnk,
         FII_MEASURE5,
         FII_MEASURE6,
         FII_MEASURE7,
 	       SUM(FII_MEASURE1) OVER()                      FII_MEASURE13,
 	       SUM(FII_MEASURE2) OVER()                      FII_MEASURE14,
	        SUM(FII_MEASURE3) OVER()                      FII_MEASURE15,
	        SUM(FII_MEASURE4) OVER()                      FII_MEASURE16,
	        SUM(FII_MEASURE5) OVER()                      FII_MEASURE17,
	        SUM(FII_MEASURE6) OVER()                      FII_MEASURE18,
	        SUM(FII_MEASURE7) OVER()                      FII_MEASURE19
         from
              (SELECT
	       f.'||l_viewby_id||' 				ID,
	       SUM(f.open_amt'||l_curr_suffix||')		FII_MEASURE1,
	       SUM(f.open_amt'||l_curr_suffix||') + SUM(f.open_payment_amt'||l_curr_suffix||')
		+ SUM(f.open_discount_taken'||l_curr_suffix||') FII_MEASURE2,
	       SUM(f.open_count)				FII_MEASURE3,
	       SUM(f.open_discount_offered'||l_curr_suffix||')	FII_MEASURE4,
	       SUM(f.open_discount_taken'||l_curr_suffix||')	FII_MEASURE5,
	       SUM(f.open_discount_lost'||l_curr_suffix||')	FII_MEASURE6,
	       SUM(f.open_discount_remaining'||l_curr_suffix||') FII_MEASURE7
	FROM FII_AP_LIA_IB_MV f, fii_time_structures cal
	WHERE f.time_id = cal.time_id
	AND   f.period_type_id = cal.period_type_id  '||l_sup_where||'  '||l_org_where||'
	AND   bitand(cal.record_type_id, :RECORD_TYPE_ID) = :RECORD_TYPE_ID
	AND   cal.report_date in (&BIS_CURRENT_ASOF_DATE)
	AND   f.gid = :GID
	GROUP BY  f.'||l_viewby_id||')) f,
         ('||l_viewby_string||') viewby_dim
        WHERE   f.id = viewby_dim.id
        and (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
	&ORDER_BY_CLAUSE';

-- Attach bind parameters
  FII_PMV_UTIL.bind_variable(
	p_sqlstmt=>sqlstmt,
	p_page_parameter_tbl=>p_page_parameter_tbl,
	p_sql_output=>disc_opp_sum_sql,
	p_bind_output_table=>disc_opp_sum_output,
	p_invoice_number=>l_invoice_number,
	p_record_type_id=>l_record_type_id,
	p_view_by=>l_viewby_id,
	p_gid=>l_gid);


END get_discount_opp_sum;


-- For the Invoices Due Aging Summary report --

PROCEDURE get_inv_due_age (
        p_page_parameter_tbl   IN  BIS_PMV_PAGE_PARAMETER_TBL,
        inv_due_sum_sql        OUT NOCOPY VARCHAR2,
        inv_due_sum_output     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
	i                       NUMBER;
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
	l_url_1			VARCHAR2(1000);
	l_url_2			VARCHAR2(1000);
	l_url_3			VARCHAR2(1000);
	l_url_4			VARCHAR2(1000);
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

  l_record_type_id := 512;	-- no other value possible in this report

-- so that no conditional query construction is required
  IF(l_org_where is null) THEN
	l_org_where := ' ';
  END IF;

  IF(l_sup_where is null) THEN
	l_sup_where := ' ';
  END IF;

-- To implement the selective drill functionality
  IF l_viewby_dim = 'ORGANIZATION+FII_OPERATING_UNITS' THEN
    l_url_1 := 'pFunctionName=FII_AP_INV_DUE_AGE_SUM&VIEW_BY=SUPPLIER+POA_SUPPLIERS&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
    l_url_2 := 'pFunctionName=FII_AP_INV_DUE_AGE_SUM&VIEW_BY=SUPPLIER+POA_SUPPLIERS&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
    l_url_3 := 'pFunctionName=FII_AP_INV_DUE_AGE_SUM&VIEW_BY=SUPPLIER+POA_SUPPLIERS&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
    l_url_4 := 'pFunctionName=FII_AP_INV_DUE_AGE_SUM&VIEW_BY=SUPPLIER+POA_SUPPLIERS&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
  ELSIF l_viewby_dim = 'SUPPLIER+POA_SUPPLIERS' THEN
    l_url_1 := 'pFunctionName=FII_AP_UNPAID_INV_DUE&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_UNPAID_INV_DUE';
    l_url_2 := 'pFunctionName=FII_AP_DUE_BUCKET1_INV_DETAIL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_DUE_BUCKET1_INV_DETAIL';
    l_url_3 := 'pFunctionName=FII_AP_DUE_BUCKET2_INV_DETAIL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_DUE_BUCKET2_INV_DETAIL';
    l_url_4 := 'pFunctionName=FII_AP_DUE_BUCKET3_INV_DETAIL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_DUE_BUCKET3_INV_DETAIL';
  END IF;



/*--------------------------------------------------------------+
 |      VIEWBY          Either Operating Unit / Supplier
 |      VIEWBYID        Either org_id / supplier_id
 |	FII_MEASURE1	Open Payables Amount
 |	FII_ATTRIBUTE10	Invoices Due
 |	FII_MEASURE2	Invoices Due Amount
 |	FII_MEASURE3	Number of Invoices
 |	FII_ATTRIBUTE11	Due in 1 - 15 Days
 |	FII_MEASURE4	Amount Due in 1 to 15 Days
 |	FII_ATTRIBUTE2	In 1-15 Days
 |	FII_MEASURE5	Number of Invoices
 |	FII_ATTRIBUTE12	Due in 16 - 30 Days
 |	FII_MEASURE6	Amount Due in 16 to 30 Days
 |	FII_ATTRIBUTE3	in 16 - 30 Days
 |	FII_MEASURE7	Number of Invoices
 |	FII_ATTRIBUTE13	Due After 30 Days
 |	FII_MEASURE8	Amount Due After 30 Days
 |	FII_ATTRIBUTE4	After 30 Days
 |	FII_MEASURE9	Number of Invoices
 |	FII_MEASURE13	Grand Total (Open Payables Amount)
 |	FII_MEASURE14	Grand Total (Invoices Due Amount)
 |	FII_MEASURE15	Grand Total (Number of Invoices)
 |	FII_MEASURE16	Grand Total (Amount Due in 1-15 Days)
 |	FII_MEASURE17	Grand Total (Number of Invoices)
 |	FII_MEASURE18	Grand Total (Amount Due in 16-30 Days)
 | 	FII_MEASURE19	Grand Total (Number of Invoices)
 |	FII_MEASURE20	Grand Total (Amount Due after 30 Days)
 |	FII_MEASURE21	Grand Total (Number of Invoices)
 |	FII_ATTRIBUTE5	Drill (Number of Invoices)
 |	FII_ATTRIBUTE6	Drill (Number of Invoices :Bucket 1)
 |	FII_ATTRIBUTE7	Drill (Number of Invoices :Bucket 2)
 |	FII_ATTRIBUTE8	Drill (Number of Invoices :Bucket 3)
 +----------------------------------------------------------------*/

-- Construct the sql query to be sent

  sqlstmt := '
	SELECT viewby_dim.value					VIEWBY,
	       viewby_dim.id					VIEWBYID,
	       f.FII_MEASURE1          				FII_MEASURE1,
	       f.FII_MEASURE2          				FII_MEASURE2,
	       f.FII_MEASURE3          				FII_MEASURE3,
	       f.FII_MEASURE4      				FII_MEASURE4,
	       f.FII_MEASURE5 					 FII_MEASURE5,
	       f.FII_MEASURE6    				FII_MEASURE6,
	       f.FII_MEASURE7  					FII_MEASURE7,
	       f.FII_MEASURE8  					FII_MEASURE8,
	       f.FII_MEASURE9     				FII_MEASURE9,
	       f.FII_MEASURE13     				FII_MEASURE13,
	       f.FII_MEASURE14    				FII_MEASURE14,
	       f.FII_MEASURE15    				FII_MEASURE15,
	       f.FII_MEASURE16    				FII_MEASURE16,
	       f.FII_MEASURE17   				FII_MEASURE17,
	       f.FII_MEASURE18   				FII_MEASURE18,
	       f.FII_MEASURE19    				FII_MEASURE19,
	       f.FII_MEASURE20    				FII_MEASURE20,
	       f.FII_MEASURE21    				FII_MEASURE21,
		'''||l_url_1||'''				FII_ATTRIBUTE5,
		'''||l_url_2||'''				FII_ATTRIBUTE6,
		'''||l_url_3||'''				FII_ATTRIBUTE7,
		'''||l_url_4||'''				FII_ATTRIBUTE8
        FROM
	(SELECT
	       id,
	       FII_MEASURE1,
	       FII_MEASURE2,
	       FII_MEASURE3,
	       FII_MEASURE4,
	       FII_MEASURE5,
	       FII_MEASURE6,
	       FII_MEASURE7,
	       FII_MEASURE8,
	       FII_MEASURE9,
	       SUM(FII_MEASURE1) OVER()		FII_MEASURE13,
	       SUM(FII_MEASURE2) OVER() 	FII_MEASURE14,
	       SUM(FII_MEASURE3) OVER()		FII_MEASURE15,
	       SUM(FII_MEASURE4) OVER()		FII_MEASURE16,
	       SUM(FII_MEASURE5) OVER()		FII_MEASURE17,
	       SUM(FII_MEASURE6) OVER()		FII_MEASURE18,
	       SUM(FII_MEASURE7) OVER()		FII_MEASURE19,
	       SUM(FII_MEASURE8) OVER()		FII_MEASURE20,
	       SUM(FII_MEASURE9) OVER()		FII_MEASURE21,
               ( rank() over (&ORDER_BY_CLAUSE nulls last, ID)) - 1 rnk
	FROM
	(  SELECT f.'||l_viewby_id||'			id,
	        sum(f.open_amt'||l_curr_suffix||')		FII_MEASURE1,
	        sum(f.open_amt'||l_curr_suffix||') -
	          sum(f.open_past_due_amt'||l_curr_suffix||')	FII_MEASURE2,
	        sum(f.open_due_count)				FII_MEASURE3,
	        sum(f.open_due_bucket3'||l_curr_suffix||')	FII_MEASURE4,
	        sum(f.open_due_bucket3_count) 			FII_MEASURE5,
	        sum(f.open_due_bucket2'||l_curr_suffix||')	FII_MEASURE6,
	        sum(f.open_due_bucket2_count)			FII_MEASURE7,
	        sum(f.open_due_bucket1'||l_curr_suffix||')	FII_MEASURE8,
                sum(f.open_due_bucket1_count)			FII_MEASURE9
	   FROM FII_AP_LIA_IB_MV f, fii_time_structures cal
	   WHERE f.time_id = cal.time_id
	   AND   f.period_type_id = cal.period_type_id   '||l_sup_where ||'   '||l_org_where||'
	   AND   bitand(cal.record_type_id, :RECORD_TYPE_ID) = :RECORD_TYPE_ID
	   AND   cal.report_date in (&BIS_CURRENT_ASOF_DATE)
	   AND   f.gid = :GID
	   HAVING sum(f.open_amt'||l_curr_suffix||') <> 0 /* bug # 3148973 */
	   group by f.'||l_viewby_id||')) f,
	('||l_viewby_string||') viewby_dim
	WHERE f.id = viewby_dim.id
        and (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
	&ORDER_BY_CLAUSE';


-- Attach bind parameters
  FII_PMV_UTIL.bind_variable(
	p_sqlstmt=>sqlstmt,
	p_page_parameter_tbl=>p_page_parameter_tbl,
	p_sql_output=>inv_due_sum_sql,
	p_bind_output_table=>inv_due_sum_output,
	p_invoice_number=>l_invoice_number,
	p_record_type_id=>l_record_type_id,
	p_view_by=>l_viewby_id,
	p_gid=>l_gid);


END get_inv_due_age;


-- For the Invoice Past Due Aging Summary report --

PROCEDURE get_inv_past_due_age (
	p_page_parameter_tbl	IN  BIS_PMV_PAGE_PARAMETER_TBL,
	inv_past_due_sum_sql	OUT NOCOPY VARCHAR2,
	inv_past_due_sum_output	OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
	i                       NUMBER;
	l_viewby_dim            VARCHAR2(240);  -- what is the viewby
	l_as_of_date            DATE;
	l_organization          VARCHAR2(240);
	l_supplier              VARCHAR2(240);
	l_currency              VARCHAR2(240);  -- random size, possibly high
	l_viewby_id             VARCHAR2(240);  -- org_id or supplier_id
	l_record_type_id        NUMBER;         --
	l_gid                   NUMBER;         -- 0,4 or 8
	l_viewby_string         VARCHAR2(240);
	inv_past_due_rec        BIS_QUERY_ATTRIBUTES;
	l_org_where             VARCHAR2(240);
	l_sup_where             VARCHAR2(240);
	l_curr_suffix		VARCHAR2(240);
	sqlstmt			VARCHAR2(14000);
	l_period_type		VARCHAR2(240);
	l_invoice_number	VARCHAR2(240);
	l_url_1			VARCHAR2(1000);
	l_url_2			VARCHAR2(1000);
	l_url_3			VARCHAR2(1000);
	l_url_4			VARCHAR2(1000);
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

  l_record_type_id := 512;	-- no other value possible in this report

-- so that no conditional query construction is required
  IF(l_org_where is null) THEN
	l_org_where := ' ';
  END IF;

  IF(l_sup_where is null) THEN
	l_sup_where := ' ';
  END IF;

-- To implement the selective drill functionality
  IF l_viewby_dim = 'ORGANIZATION+FII_OPERATING_UNITS' THEN
    l_url_1 := 'pFunctionName=FII_AP_INV_PAST_DUE_AGE_SUM&VIEW_BY=SUPPLIER+POA_SUPPLIERS&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
    l_url_2 := 'pFunctionName=FII_AP_INV_PAST_DUE_AGE_SUM&VIEW_BY=SUPPLIER+POA_SUPPLIERS&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
    l_url_3 := 'pFunctionName=FII_AP_INV_PAST_DUE_AGE_SUM&VIEW_BY=SUPPLIER+POA_SUPPLIERS&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
    l_url_4 := 'pFunctionName=FII_AP_INV_PAST_DUE_AGE_SUM&VIEW_BY=SUPPLIER+POA_SUPPLIERS&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
  ELSIF l_viewby_dim = 'SUPPLIER+POA_SUPPLIERS' THEN
    l_url_1 := 'pFunctionName=FII_AP_UNPAID_INV_PAST_DUE&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_UNPAID_INV_PAST_DUE';
    l_url_2 := 'pFunctionName=FII_AP_PDUE_BUCKET1_INV_DETAIL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_PDUE_BUCKET1_INV_DETAIL';
    l_url_3 := 'pFunctionName=FII_AP_PDUE_BUCKET2_INV_DETAIL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_PDUE_BUCKET2_INV_DETAIL';
    l_url_4 := 'pFunctionName=FII_AP_PDUE_BUCKET3_INV_DETAIL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_PDUE_BUCKET3_INV_DETAIL';
  END IF;


/*--------------------------------------------------------------+
 |      VIEWBY          Either Operating Unit / Supplier
 |      VIEWBYID        Either org_id / supplier_id
 | 	FII_MEASURE1	Open Payables Amount
 | 	FII_ATTRIBUTE10	Invoices Past Due
 | 	FII_MEASURE2	Invoices Past Due Amount
 | 	FII_MEASURE3	Number of Invoices
 | 	FII_ATTRIBUTE11	Past Due in 1 - 15 Days
 | 	FII_MEASURE4	Amount 1to 15 Days Past Due
 | 	FII_ATTRIBUTE2	1-15 Days Past Due
 |  	FII_MEASURE5	Number of Invoices
 | 	FII_ATTRIBUTE12	Past Due in 16 - 30 Days
 | 	FII_MEASURE6	Amount 16 to 30 Days Past Due
 | 	FII_ATTRIBUTE3	16-30 Days Past Due
 | 	FII_MEASURE7	Number of Invoices
 | 	FII_ATTRIBUTE13	Past Due 30 Days
 | 	FII_MEASURE8	Amount Over  30 Days Past Due
 | 	FII_ATTRIBUTE4	Over 30 Days Past Due
 | 	FII_MEASURE9	Number of Invoices
 | 	FII_MEASURE13	Grand Total (Open Payables Amount)
 | 	FII_MEASURE14	Grand Total (Invoices Past Due Amount)
 | 	FII_MEASURE15	Grand Total (Number of Invoices)
 | 	FII_MEASURE16	Grand Total (Amount 1-15 Days Past Due)
 | 	FII_MEASURE17	Grand Total (Number of Invoices)
 | 	FII_MEASURE18	Grand Total (Amount 16-30 Days Past Due)
 | 	FII_MEASURE19	Grand Total (Number of Invoices)
 | 	FII_MEASURE20	Grand Total (Amount over 30 Days Past Due)
 | 	FII_MEASURE21	Grand Total (Number of Invoices)
 |  	FII_ATTRIBUTE5	Drill (Number of Invoices)
 | 	FII_ATTRIBUTE6	Drill (Invoices Past Due  Bucket 1)
 | 	FII_ATTRIBUTE7	Drill (Invoices Past Due  Bucket 2)
 | 	FII_ATTRIBUTE8	Drill (Invoices Past Due  Bucket 3)
 |
 +----------------------------------------------------------------*/

-- Construct the sql query to be sent

  sqlstmt := '
	SELECT viewby_dim.value					VIEWBY,
		viewby_dim.id					VIEWBYID,
		f.FII_MEASURE1,
		f.FII_MEASURE2,
		f.FII_MEASURE3,
		f.FII_MEASURE4,
		f.FII_MEASURE5,
		f.FII_MEASURE6,
		f.FII_MEASURE7,
		f.FII_MEASURE8,
		f.FII_MEASURE9,
		f.FII_MEASURE13,
		f.FII_MEASURE14,
		f.FII_MEASURE15,
		f.FII_MEASURE16,
		f.FII_MEASURE17,
		f.FII_MEASURE18,
		f.FII_MEASURE19,
		f.FII_MEASURE20,
		f.FII_MEASURE21,
		'''||l_url_1||'''				FII_ATTRIBUTE5,
		'''||l_url_2||'''				FII_ATTRIBUTE6,
		'''||l_url_3||'''				FII_ATTRIBUTE7,
		'''||l_url_4||'''				FII_ATTRIBUTE8
        FROM
	(SELECT
		id,
		FII_MEASURE1,
		FII_MEASURE2,
		FII_MEASURE3,
		FII_MEASURE4,
		FII_MEASURE5,
		FII_MEASURE6,
		FII_MEASURE7,
		FII_MEASURE8,
		FII_MEASURE9,
		SUM(FII_MEASURE1) OVER()			FII_MEASURE13,
		SUM(FII_MEASURE2) OVER()			FII_MEASURE14,
		SUM(FII_MEASURE3) OVER()			FII_MEASURE15,
		SUM(FII_MEASURE4) OVER()			FII_MEASURE16,
		SUM(FII_MEASURE5) OVER()			FII_MEASURE17,
		SUM(FII_MEASURE6) OVER()			FII_MEASURE18,
		SUM(FII_MEASURE7) OVER()			FII_MEASURE19,
		SUM(FII_MEASURE8) OVER()			FII_MEASURE20,
		SUM(FII_MEASURE9) OVER()			FII_MEASURE21,
                ( rank() over (&ORDER_BY_CLAUSE nulls last, ID)) - 1 rnk
	FROM
	(  SELECT f.'||l_viewby_id||'		id,
		sum(f.open_amt'||l_curr_suffix||')	FII_MEASURE1,
		sum(f.open_past_due_amt'||l_curr_suffix||')
						FII_MEASURE2,
		sum(f.open_past_due_count)	FII_MEASURE3,
		sum(f.open_past_due_bucket3'||l_curr_suffix||')
						FII_MEASURE4,
	        sum(f.open_past_due_bucket3_count)	FII_MEASURE5,
		sum(f.open_past_due_bucket2'||l_curr_suffix||')
						FII_MEASURE6,
	        sum(f.open_past_due_bucket2_count)	FII_MEASURE7,
		sum(f.open_past_due_bucket1'||l_curr_suffix||')
						FII_MEASURE8,
	        sum(f.open_past_due_bucket1_count)	FII_MEASURE9
	   FROM FII_AP_LIA_IB_MV f, fii_time_structures cal
	   WHERE f.time_id = cal.time_id
	   AND   f.period_type_id = cal.period_type_id   '||l_sup_where ||'   '||l_org_where||'
	   AND   bitand(cal.record_type_id, :RECORD_TYPE_ID) = :RECORD_TYPE_ID
	   AND   cal.report_date in (&BIS_CURRENT_ASOF_DATE)
	   AND   f.gid = :GID group by f.'||l_viewby_id||')) f,
	('||l_viewby_string||') viewby_dim
	WHERE f.id = viewby_dim.id
        and (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
	&ORDER_BY_CLAUSE';


-- Attach bind parameters
  FII_PMV_UTIL.bind_variable(
	p_sqlstmt=>sqlstmt,
	p_page_parameter_tbl=>p_page_parameter_tbl,
	p_sql_output=>inv_past_due_sum_sql,
	p_bind_output_table=>inv_past_due_sum_output,
	p_invoice_number=>l_invoice_number,
	p_record_type_id=>l_record_type_id,
	p_view_by=>l_viewby_id,
	p_gid=>l_gid);


END get_inv_past_due_age;


END fii_ap_open_pay_sum;
-- End of Summary Reports package


/
