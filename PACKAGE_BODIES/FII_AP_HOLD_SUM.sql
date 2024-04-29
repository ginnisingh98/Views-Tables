--------------------------------------------------------
--  DDL for Package Body FII_AP_HOLD_SUM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AP_HOLD_SUM" AS
/* $Header: FIIAPS3B.pls 120.3 2006/01/25 23:36:04 vkazhipu noship $ */

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
       l_url_2            VARCHAR2(240);
       l_url_3            VARCHAR2(240);
       l_url_4            VARCHAR2(240);

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

l_record_type_id := 512;


-- Decide on the viewby stuff and pk to be used
-- Map the l_column_name based on the selected viewby


/*--------------------------------------------------------------+
 |      VIEWBY          - Either Operating Unit / Supplier      |
 |      VIEWBYID        - Either org_id / supplier_id           |
 |      FII_MEASURE1    - Open Payables Amount                  |
 |      FII_MEASURE2    - Total Number of Invoices              |
 |      FII_MEASURE3    - Invoices on Hold  Amount              |
 |      FII_MEASURE4    - Number of Invoices                    |
 |      FII_MEASURE5    - Holds Due Amount                      |
 |      FII_MEASURE6    - Number of Invoices                    |
 |      FII_MEASURE7    - Weighted Average Days Due             |
 |      FII_MEASURE8    - Holds Past Due Amount                 |
 |      FII_MEASURE9    - Number of Invoices                    |
 |      FII_MEASURE10   - Weighte  Average Days Past Due        |
 |      FII_MEASURE11   - Number of Holds                       |
 |      FII_MEASURE12   - Average Days on Hold                  |
 |      FII_MEASURE13   - Grand Total of Open Payables Amount   |
 |      FII_MEASURE14   - Grand Total of Total Number of Invoices  |
 |      FII_MEASURE15   - Grand Total of Invoices on Hold  Amount  |
 |      FII_MEASURE16   - Grand Total of Number of Invoices     |
 |      FII_MEASURE17   - Grand Total of Holds Due Amount       |
 |      FII_MEASURE18   - Grand Total of Number of Invoices     |
 |      FII_MEASURE19   - Grand Total of Holds Past Due Amount  |
 |      FII_MEASURE20   - Grand Total of Number of Invoices     |
 |      FII_MEASURE21   - Grand Total of Number of Holds        |
 |      FII_MEASURE22   - Percent on Hold                       |
 |      FII_MEASURE23   - Grand Total of Percent on Hold        |
 |      FII_ATTRIBUTE2  - URL for FII_MEASURE6                  |
 |      FII_ATTRIBUTE3  - URL for FII_MEASURE4                  |
 |      FII_ATTRIBUTE4  - URL for FII_MEASURE9                  |
 +--------------------------------------------------------------*/

-- Construct the sql query to be sent

-- for fii_measure4

-- If view by Operating Unit, drills to a breakdown of suppliers using the same parameters
-- as selected in this report.
-- if view by Supplier, drills to Invoice Detail report for the total invoices
-- for the given Supplier selected using the same parameters.
-- Form function to drill to : FII_AP_INV_ON_HOLD_DETAIL.

l_url_1  := 'pFunctionName=FII_AP_INV_ON_HOLD_DETAIL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_INV_ON_HOLD_DETAIL' ;

l_url_4  := 'pFunctionName=FII_AP_HOLD_SUM&VIEW_BY=SUPPLIER+POA_SUPPLIERS&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y' ;


-- for fii_measure6
-- Drills only available when view by Supplier.  It drills to Invoice Detail report
-- for the invoices due for the given Supplier selected using the same parameters.
-- Form function to drill to : FII_AP_INV_ON_HOLD_DUE_DETAIL.

l_url_2  := 'pFunctionName=FII_AP_INV_ON_HOLD_DUE_DETAIL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_INV_ON_HOLD_DUE_DETAIL' ;


-- for fii_measure9
-- Drills only available when view by Supplier.  It drills to Invoice Detail report
-- for the invoices past due for the given Supplier selected using the same parameters.
-- Form function to drill to : FII_AP_INV_ON_HOLD_PDUE_DETAIL.

l_url_3  := 'pFunctionName=FII_AP_INV_ON_HOLD_PDUE_DETAIL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_INV_ON_HOLD_PDUE_DETAIL' ;


sqlstmt := '
       SELECT h.VIEWBY                                     VIEWBY,
              h.VIEWBYID                                   VIEWBYID,
              h.FII_MEASURE1                               FII_MEASURE1,
              h.FII_MEASURE2                               FII_MEASURE2,
              h.FII_MEASURE3                               FII_MEASURE3,
              h.FII_MEASURE4                               FII_MEASURE4,
              h.FII_MEASURE5                               FII_MEASURE5,
              h.FII_MEASURE6                               FII_MEASURE6,
              h.FII_MEASURE8                               FII_MEASURE8,
              h.FII_MEASURE9                               FII_MEASURE9,
              h.FII_MEASURE11                              FII_MEASURE11,
              h.FII_MEASURE12                              FII_MEASURE12,
              h.FII_MEASURE13                              FII_MEASURE13,
              h.FII_MEASURE14                              FII_MEASURE14,
              h.FII_MEASURE15                              FII_MEASURE15,
              h.FII_MEASURE16                              FII_MEASURE16,
              h.FII_MEASURE17                              FII_MEASURE17,
              h.FII_MEASURE18                              FII_MEASURE18,
              h.FII_MEASURE19                              FII_MEASURE19,
              h.FII_MEASURE20                              FII_MEASURE20,
              h.FII_MEASURE21                              FII_MEASURE21,
           decode('''||l_view_by||''',''SUPPLIER+POA_SUPPLIERS'','''||l_url_2||''',null)
                                                   FII_ATTRIBUTE2,   -- for fii_measure6
           decode('''||l_view_by||''',''ORGANIZATION+FII_OPERATING_UNITS'','''||l_url_4||''',
              ''SUPPLIER+POA_SUPPLIERS'','''||l_url_1||''',
                 null)                             FII_ATTRIBUTE3,   -- for fii_measure4

           decode('''||l_view_by||''',''SUPPLIER+POA_SUPPLIERS'','''||l_url_3||''',null)
                                                   FII_ATTRIBUTE4,     --  for fii_measure9

           decode('''||l_view_by||''',''ORGANIZATION+FII_OPERATING_UNITS'','''||l_url_4||''',
              ''SUPPLIER+POA_SUPPLIERS'','''||l_url_1||''',
                 null)                             FII_ATTRIBUTE5   	/* Added for Bug 3096072 */
       FROM
       (SELECT g.VIEWBY                                    VIEWBY,
              g.VIEWBYID                                   VIEWBYID,
              g.FII_MEASURE1                               FII_MEASURE1,
              g.FII_MEASURE2                               FII_MEASURE2,
              g.FII_MEASURE3                               FII_MEASURE3,
              g.FII_MEASURE4                               FII_MEASURE4,
              g.FII_MEASURE5                               FII_MEASURE5,
              g.FII_MEASURE6                               FII_MEASURE6,
              g.FII_MEASURE8                               FII_MEASURE8,
              g.FII_MEASURE9                               FII_MEASURE9,
              g.FII_MEASURE11                              FII_MEASURE11,
              g.FII_MEASURE12                              FII_MEASURE12,
              sum(g.FII_MEASURE1) over()                   FII_MEASURE13,
              sum(g.FII_MEASURE2) over()                   FII_MEASURE14,
              sum(g.FII_MEASURE3) over()                   FII_MEASURE15,
              sum(g.FII_MEASURE4) over()                   FII_MEASURE16,
              sum(g.FII_MEASURE3 - g.FII_MEASURE8) over()  FII_MEASURE17,
              sum(g.FII_MEASURE6) over()                   FII_MEASURE18,
              sum(g.FII_MEASURE8) over()                   FII_MEASURE19,
              sum(g.FII_MEASURE9) over()                   FII_MEASURE20,
              sum(g.FII_MEASURE11) over()                  FII_MEASURE21,
              ( rank() over (&ORDER_BY_CLAUSE nulls last, VIEWBYID)) - 1 rnk
       FROM
       (SELECT viewby_dim.value                                     VIEWBY,
              viewby_dim.id                                        VIEWBYID,
              sum(open_amt)                                        FII_MEASURE1,
              sum(open_count)                                      FII_MEASURE2,
              sum(inv_on_hold_amt)                                 FII_MEASURE3,
              sum(inv_on_hold_count)                               FII_MEASURE4,
              sum(inv_on_hold_amt) - sum(on_hold_past_due_amt)     FII_MEASURE5,
              sum(on_hold_due_count)                               FII_MEASURE6,
              sum(on_hold_past_due_amt)                            FII_MEASURE8,
              sum(on_hold_past_due_count)                          FII_MEASURE9,
              sum(no_of_holds)                                     FII_MEASURE11,
              decode(sum(inv_on_hold_count),0,0,
              sum(days_on_hold)/sum(inv_on_hold_count))              FII_MEASURE12
            --  sum(sum(open_amt)) over()                            FII_MEASURE13,
            --  sum(sum(open_count)) over()                          FII_MEASURE14,
            --  sum(sum(inv_on_hold_amt)) over()                     FII_MEASURE15,
            --  sum(sum(inv_on_hold_count)) over()                   FII_MEASURE16,
            --  sum(sum(inv_on_hold_amt) - sum(on_hold_past_due_amt)) over()  FII_MEASURE17,
            --  sum(sum(on_hold_due_count)) over()                   FII_MEASURE18,
            --  sum(sum(on_hold_past_due_amt)) over()                FII_MEASURE19,
            --  sum(sum(on_hold_past_due_count)) over()              FII_MEASURE20,
            --  sum(sum(no_of_holds)) over()                         FII_MEASURE21,
       FROM
             (SELECT   f.'||l_column_name||'                       id,
                       sum(f.open_amt'||l_currency||' )            open_amt,
                       sum(f.open_count)                           open_count,
                       0                                           inv_on_hold_amt,
                       0                                           inv_on_hold_count,
                       0                                           on_hold_due_count,
                       0                                           on_hold_past_due_amt,
                       0                                           on_hold_past_due_count,
                       0                                           no_of_holds,
                       0                                           days_on_hold
             FROM     FII_AP_LIA_IB_MV f,
                      fii_time_structures cal
             WHERE    f.time_id = cal.time_id '||l_org_where||l_supplier_where||'
             AND      f.period_type_id = cal.period_type_id
             AND      bitand(cal.record_type_id,:RECORD_TYPE_ID) = :RECORD_TYPE_ID
             AND      cal.report_date in (&BIS_CURRENT_ASOF_DATE)
             AND      f.gid =   :GID
             GROUP BY f.'||l_column_name||'
             UNION ALL
             SELECT    f.'||l_column_name||'                         id,
                       0                                           open_amt,
                       0                                           open_count,
                       sum(f.inv_on_hold_amt'||l_currency||')   inv_on_hold_amt,
                       sum(f.inv_on_hold_count)                    inv_on_hold_count,
                       sum(f.on_hold_due_count)                    on_hold_due_count,
                       sum(f.on_hold_past_due_amt'||l_currency||') on_hold_past_due_amt,
                       sum(f.on_hold_past_due_count)               on_hold_past_due_count,
                       sum(f.no_of_holds)                          no_of_holds,
                       sum(f.days_on_hold)                         days_on_hold
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
       GROUP BY viewby_dim.value, viewby_dim.id) g ) h
       WHERE ((rnk between &START_INDEX and &END_INDEX) or (&END_INDEX = -1))
       &ORDER_BY_CLAUSE' ;

--       Binding Section

       FII_PMV_Util.bind_variable(
       p_sqlstmt=> sqlstmt,
       p_page_parameter_tbl=>p_page_parameter_tbl,
       p_sql_output=>get_hold_sum_sql,
       p_bind_output_table=>get_hold_sum_output,
   --    p_invoice_number=>l_invoice_number,
       p_record_type_id=>l_record_type_id,
       p_view_by=>l_view_by,
       p_gid=>l_gid
       );



END get_hold_sum;


PROCEDURE  get_hold_discount_sum (
        p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
        get_hold_discount_sum_sql        OUT NOCOPY VARCHAR2,
        get_hold_discount_sum_output     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS

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

l_record_type_id := 512;

-- Decide on the viewby stuff and pk to be used
-- Map the l_column_name based on the selected viewby

/*--------------------------------------------------------------+
 |      VIEWBY          - Either Operating Unit / Supplier      |
 |      VIEWBYID        - Either org_id / supplier_id           |
 |      FII_MEASURE1    - Invoices on Hold Amount               |
 |      FII_MEASURE2    - Total Invoice Amount                  |
 |      FII_MEASURE3    - Number of Invoices                    |
 |      FII_MEASURE4    - Discount Offered                      |
 |      FII_MEASURE5    - % Offered                             |
 |      FII_MEASURE6    - Discount Taken                        |
 |      FII_MEASURE7    - % Taken of Offered                    |
 |      FII_MEASURE8    - Discount Lost                         |
 |      FII_MEASURE9    - % Lost of Offered                     |
 |      FII_MEASURE10   - Discount Remaining                    |
 |      FII_MEASURE11   - % Remaining of Offered                |
 |      FII_MEASURE12   - Average Days on Hold                  |
 |      FII_MEASURE13   - Grand Total of Invoices on Hold Amount|
 |      FII_MEASURE14   - Grand Total of Total Invoice Amount   |
 |      FII_MEASURE15   - Grand Total of Number of Invoices     |
 |      FII_MEASURE16   - Grand Total of Discount Offered       |
 |      FII_MEASURE17   - Grand Total of Discount Lost          |
 |      FII_MEASURE18   - Grand Total of Discount Remaining     |
 |      FII_MEASURE19   - Grand Total of % Offered              |
 |      FII_MEASURE20   - Grand Total of % Taken of Offered     |
 |      FII_MEASURE21   - Grand Total of % Lost of Offered      |
 |      FII_MEASURE22   - Grand Total of % Remaining of Offered |
 +--------------------------------------------------------------*/


-- Construct the sql query to be sent

-- for fii_measure3

-- If view by Operating Unit, drills to a breakdown of suppliers using the same parameters
-- as selected in this report.
-- if view by Supplier, drills to Invoice Detail report for the total invoices
-- for the given Supplier selected using the same parameters.
-- Form function to drill to : FII_AP_INV_ON_HOLD_DETAIL.

l_url_1  := 'pFunctionName=FII_AP_INV_ON_HOLD_DETAIL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_INV_ON_HOLD_DETAIL' ;

l_url_4  := 'pFunctionName=FII_AP_HOLD_DISCOUNT_SUM&VIEW_BY=SUPPLIER+POA_SUPPLIERS&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y' ;



sqlstmt := '
       SELECT viewby_dim.value                                  VIEWBY,
              viewby_dim.id                                     VIEWBYID,
              f.FII_MEASURE1                                 	FII_MEASURE1,
              f.FII_MEASURE2                              	FII_MEASURE2,
              f.FII_MEASURE3                               	FII_MEASURE3,
              f.FII_MEASURE4                                    FII_MEASURE4,
              f.FII_MEASURE6                                    FII_MEASURE6,
              f.FII_MEASURE8                                    FII_MEASURE8,
              f.FII_MEASURE10                                   FII_MEASURE10,
              f.FII_MEASURE12                     		FII_MEASURE12,
              f.FII_MEASURE13                   		FII_MEASURE13,
              f.FII_MEASURE14                   		FII_MEASURE14,
              f.FII_MEASURE15                        		FII_MEASURE15,
              f.FII_MEASURE16					FII_MEASURE16,
              f.FII_MEASURE17                           	FII_MEASURE17,
              f.FII_MEASURE18                      		FII_MEASURE18,
              f.FII_MEASURE19                                   FII_MEASURE19,
              f.FII_MEASURE20                                   FII_MEASURE20,
              f.FII_MEASURE21                                   FII_MEASURE21,
              f.FII_MEASURE22                                   FII_MEASURE22,
     decode('''||l_view_by||''',''ORGANIZATION+FII_OPERATING_UNITS'','''||l_url_4||''',
        ''SUPPLIER+POA_SUPPLIERS'','''||l_url_1||''',
                 null)                                           FII_ATTRIBUTE2   -- for fii_measure3
 FROM
       (SELECT
              id ,
              FII_MEASURE1,
              FII_MEASURE2,
              FII_MEASURE3,
              FII_MEASURE4,
              FII_MEASURE6,
              FII_MEASURE8,
              FII_MEASURE10,
              sum(FII_MEASURE1) over()                     	FII_MEASURE12,
              sum(FII_MEASURE2) over()                   	FII_MEASURE13,
              sum(FII_MEASURE3) over()                   	FII_MEASURE14,
              sum(FII_MEASURE4) over()                        	FII_MEASURE15,
              sum(FII_MEASURE6) over()                          FII_MEASURE16,
              sum(FII_MEASURE8) over()                          FII_MEASURE17,
              sum(FII_MEASURE10) over()                      	FII_MEASURE18,
     decode  (sum(FII_MEASURE2) over(),0,0,
     ((sum(FII_MEASURE4) over() /   sum(FII_MEASURE2) over()) *100))
                                                                    FII_MEASURE19,
     decode  (sum(FII_MEASURE4) over(),0,0,
     ((sum(FII_MEASURE6) over() /   sum(FII_MEASURE4) over()) *100))
                                                                    FII_MEASURE20,
     decode  (sum(FII_MEASURE4) over(),0,0,
     ((sum(FII_MEASURE8) over() /   sum(FII_MEASURE4) over()) *100))
                                                                    FII_MEASURE21,
     decode  (sum(FII_MEASURE4) over(),0,0,
     ((sum(FII_MEASURE10) over() /   sum(FII_MEASURE4) over()) *100))
                                                                    FII_MEASURE22,
     ( rank() over (&ORDER_BY_CLAUSE nulls last, ID)) - 1 rnk
FROM
             (SELECT   f.'||l_column_name||'                         id,
              sum(INV_ON_HOLD_AMT'||l_currency||' )             FII_MEASURE1,
              sum(INV_ON_HOLD_AMT'||l_currency||'+
                  ON_HOLD_PAYMENT_AMOUNT'||l_currency||'+
                  ON_HOLD_DIS_TAKEN'||l_currency||')            FII_MEASURE2,
              sum(INV_ON_HOLD_COUNT)                            FII_MEASURE3,
              sum(ON_HOLD_DIS_TAKEN'||l_currency||' +
                  ON_HOLD_DIS_LOST'||l_currency||' +
                  ON_HOLD_DIS_REMAINING'||l_currency||')        FII_MEASURE4,
              sum(ON_HOLD_DIS_TAKEN'||l_currency||')            FII_MEASURE6,
              sum(ON_HOLD_DIS_LOST'||l_currency||')             FII_MEASURE8,
              sum(ON_HOLD_DIS_REMAINING'||l_currency||')        FII_MEASURE10
             FROM     FII_AP_HLIA_I_MV f,
                      fii_time_structures cal
             WHERE    f.time_id = cal.time_id '||l_org_where||l_supplier_where||'
             AND      f.period_type_id = cal.period_type_id
             AND      bitand(cal.record_type_id, :RECORD_TYPE_ID) = :RECORD_TYPE_ID
             AND      cal.report_date in (&BIS_CURRENT_ASOF_DATE)
             AND      f.gid =  :GID
             GROUP BY f.'||l_column_name||'
               )) f,
  ('||l_table_name||') viewby_dim
       WHERE f.id = viewby_dim.id
      and (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
       &ORDER_BY_CLAUSE' ;



--       Binding Section

       FII_PMV_Util.bind_variable(
       p_sqlstmt=> sqlstmt,
       p_page_parameter_tbl=>p_page_parameter_tbl,
       p_sql_output=>get_hold_discount_sum_sql,
       p_bind_output_table=>get_hold_discount_sum_output,
   --    p_invoice_number=>l_invoice_number,
       p_record_type_id=>l_record_type_id,
       p_view_by=>l_view_by,
       p_gid=>l_gid
       );




END get_hold_discount_sum;


PROCEDURE get_hold_cat_sum
     ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
       get_hold_cat_sum_sql out NOCOPY VARCHAR2,
       get_hold_cat_sum_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)IS

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
       l_url_2            VARCHAR2(240);

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


      l_record_type_id := 512;

-- Decide on the viewby stuff and pk to be used
-- Map the l_column_name based on the selected viewby


/*--------------------------------------------------------------+
 |      VIEWBY          - Either Operating Unit / Supplier      |
 |      VIEWBYID        - Either org_id / supplier_id           |
 |      FII_MEASURE1    - Open Payables Amount                  |
 |      FII_MEASURE2    - Total Number of Invoices              |
 |      FII_MEASURE3    - Invoices on Hold  Amount              |
 |      FII_MEASURE4    - Number of Invoices                    |
 |      FII_MEASURE5    - Holds Due Amount                      |
 |      FII_MEASURE6    - Number of Invoices                    |
 |      FII_MEASURE7    - Weighted Average Days Due             |
 |      FII_MEASURE8    - Holds Past Due Amount                 |
 |      FII_MEASURE9    - Number of Invoices                    |
 |      FII_MEASURE10   - Weighte  Average Days Past Due        |
 |      FII_MEASURE11   - Number of Holds                       |
 |      FII_MEASURE12   - Average Days on Hold                  |
 |      FII_MEASURE13   - Grand Total of Open Payables Amount   |
 |      FII_MEASURE14   - Grand Total of Total Number of Invoices  |
 |      FII_MEASURE15   - Grand Total of Invoices on Hold  Amount  |
 |      FII_MEASURE16   - Grand Total of Number of Invoices     |
 |      FII_MEASURE17   - Grand Total of Holds Due Amount       |
 |      FII_MEASURE18   - Grand Total of Number of Invoices     |
 |      FII_MEASURE19   - Grand Total of Holds Past Due Amount  |
 |      FII_MEASURE20   - Grand Total of Number of Invoices     |
 |      FII_MEASURE21   - Grand Total of Number of Holds        |
 +--------------------------------------------------------------*/

-- Construct the sql query to be sent

l_url_1  := 'pFunctionName=FII_AP_INV_HOLD_CAT_DETAIL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_INV_HOLD_CAT_DETAIL&FII_DIM1=All' ;

l_url_2  := 'pFunctionName=FII_AP_HOLD_CAT_SUM&VIEW_BY=SUPPLIER+POA_SUPPLIERS&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y' ;


sqlstmt := '
       SELECT
              h.VIEWBY                                        VIEWBY,
              h.VIEWBYID                                      VIEWBYID,
              h.FII_MEASURE1                                  FII_MEASURE1,
              h.FII_MEASURE2                                  FII_MEASURE2,
              h.FII_MEASURE3                                  FII_MEASURE3,
              h.FII_MEASURE4                                  FII_MEASURE4,
              h.FII_MEASURE5                          	      FII_MEASURE5,
              h.FII_MEASURE6                                  FII_MEASURE6,
              h.FII_MEASURE7                         	      FII_MEASURE7,
              h.FII_MEASURE8                                  FII_MEASURE8,
              h.FII_MEASURE13                                 FII_MEASURE13,
              h.FII_MEASURE14                  		      FII_MEASURE14,
              h.FII_MEASURE15                         	      FII_MEASURE15,
              h.FII_MEASURE16				      FII_MEASURE16,
              h.FII_MEASURE17              	              FII_MEASURE17,
              h.FII_MEASURE18                  		      FII_MEASURE18,
              h.FII_MEASURE19             	              FII_MEASURE19,
              h.FII_MEASURE20                                 FII_MEASURE20,
              decode('''||l_view_by||''',''ORGANIZATION+FII_OPERATING_UNITS'','''||l_url_2||''',
                   ''SUPPLIER+POA_SUPPLIERS'','''||l_url_1||''',
                      null)  FII_ATTRIBUTE2   -- for fii_measure2
       FROM
       (SELECT g.VIEWBY                                        VIEWBY,
              g.VIEWBYID                                       VIEWBYID,
              g.FII_MEASURE1                                   FII_MEASURE1,
              g.FII_MEASURE2                                   FII_MEASURE2,
              g.FII_MEASURE3                                   FII_MEASURE3,
              g.FII_MEASURE4                                   FII_MEASURE4,
              g.FII_MEASURE5                                   FII_MEASURE5,
              g.FII_MEASURE6                                   FII_MEASURE6,
              g.FII_MEASURE7                                   FII_MEASURE7,
              g.FII_MEASURE8                                   FII_MEASURE8,
              sum(g.FII_MEASURE1) over()                       FII_MEASURE13,
              sum(g.FII_MEASURE2) over()                       FII_MEASURE14,
              sum(g.FII_MEASURE3) over()                       FII_MEASURE15,
              sum(g.FII_MEASURE4) over()                       FII_MEASURE16,
              sum(g.FII_MEASURE5) over()                       FII_MEASURE17,
              sum(g.FII_MEASURE6) over()                       FII_MEASURE18,
              sum(g.FII_MEASURE7) over()                       FII_MEASURE19,
              sum(g.FII_MEASURE8) over()                       FII_MEASURE20,
             ( rank() over (&ORDER_BY_CLAUSE nulls last, VIEWBYID)) - 1 rnk
       FROM
       (SELECT viewby_dim.value                                     VIEWBY,
              viewby_dim.id                                        VIEWBYID,
              sum(inv_on_hold_amt)                                 FII_MEASURE1,
              sum(inv_on_hold_count)                               FII_MEASURE2,
              sum(no_of_holds)                                     FII_MEASURE3,
              sum(VARIANCE_HOLD_COUNT)                             FII_MEASURE4,
              sum(PO_MATCHING_HOLD_COUNT)                          FII_MEASURE5,
              sum(INVOICE_HOLD_COUNT)                              FII_MEASURE6,
              sum(USER_DEFINED_HOLD_COUNT)                         FII_MEASURE7,
              sum(OTHER_HOLD_COUNT)                                FII_MEASURE8
      --        sum(sum(inv_on_hold_amt)) over()                     FII_MEASURE13,
      --        sum(sum(inv_on_hold_count)) over()                   FII_MEASURE14,
      --        sum(sum(no_of_holds)) over()                         FII_MEASURE15,
      --        sum(sum(VARIANCE_HOLD_COUNT)) over()                 FII_MEASURE16,
      --        sum(sum(PO_MATCHING_HOLD_COUNT)) over()              FII_MEASURE17,
      --        sum(sum(INVOICE_HOLD_COUNT)) over()                  FII_MEASURE18,
      --        sum(sum(USER_DEFINED_HOLD_COUNT)) over()             FII_MEASURE19,
       --       sum(sum(OTHER_HOLD_COUNT)) over()                    FII_MEASURE20,
       FROM
             (SELECT   f.'||l_column_name||'                      id,
                       sum(f.inv_on_hold_amt'||l_currency||' )    inv_on_hold_amt,
                       sum(f.inv_on_hold_count)                   inv_on_hold_count,
                       sum(f.no_of_holds)                         no_of_holds,
                       0                                          VARIANCE_HOLD_COUNT,
                       0                                          PO_MATCHING_HOLD_COUNT,
                       0                                          INVOICE_HOLD_COUNT,
                       0                                          USER_DEFINED_HOLD_COUNT,
                       0                                          OTHER_HOLD_COUNT
             FROM     FII_AP_HLIA_I_MV f,
                      fii_time_structures cal
             WHERE    f.time_id = cal.time_id '||l_org_where||l_supplier_where||'
             AND      f.period_type_id = cal.period_type_id
             AND      bitand(cal.record_type_id,:RECORD_TYPE_ID) = :RECORD_TYPE_ID
             AND      cal.report_date in (&BIS_CURRENT_ASOF_DATE)
             AND      f.gid =   :GID
             GROUP BY f.'||l_column_name||'
             UNION ALL
             SELECT    f.'||l_column_name||'                       id,
                       0                                           inv_on_hold_amt,
                       0                                           inv_on_hold_count,
                       0                                           no_of_holds,
                       sum(f.VARIANCE_HOLD_COUNT)                  VARIANCE_HOLD_COUNT,
                       sum(f.PO_MATCHING_HOLD_COUNT)               PO_MATCHING_HOLD_COUNT,
                       sum(f.INVOICE_HOLD_COUNT)                   INVOICE_HOLD_COUNT,
                       sum(f.USER_DEFINED_HOLD_COUNT)              USER_DEFINED_HOLD_COUNT,
                       sum(f.OTHER_HOLD_COUNT)                     OTHER_HOLD_COUNT
             FROM    FII_AP_HCAT_IB_MV f,
                     fii_time_structures cal
             WHERE   f.time_id = cal.time_id '||l_org_where||l_supplier_where||'
             AND     f.period_type_id = cal.period_type_id
             AND     bitand(cal.record_type_id,:RECORD_TYPE_ID) = :RECORD_TYPE_ID
             AND     cal.report_date in (&BIS_CURRENT_ASOF_DATE)
             AND     f.gid =   :GID
             GROUP BY f.'||l_column_name||'
               ) f,
       ('||l_table_name||') viewby_dim
       WHERE f.id = viewby_dim.id
       GROUP BY viewby_dim.value, viewby_dim.id) g ) h
       WHERE ((rnk between &START_INDEX and &END_INDEX) or (&END_INDEX = -1))
  &ORDER_BY_CLAUSE' ;

--       Binding Section

       FII_PMV_Util.bind_variable(
       p_sqlstmt=> sqlstmt,
       p_page_parameter_tbl=>p_page_parameter_tbl,
       p_sql_output=>get_hold_cat_sum_sql,
       p_bind_output_table=>get_hold_cat_sum_output,
       p_invoice_number=>l_invoice_number,
       p_record_type_id=>l_record_type_id,
       p_view_by=>l_view_by,
       p_gid=>l_gid
       );



END get_hold_cat_sum;

PROCEDURE get_hold_type_sum
     ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
       get_hold_type_sum_sql out NOCOPY VARCHAR2,
       get_hold_type_sum_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)IS

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
       l_fii_dim1       VARCHAR2(240);
       l_cat_table      VARCHAR2(240);
       l_cat_join       VARCHAR2(240);

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

      l_record_type_id := 512;

-- Decide on the viewby stuff and pk to be used
-- Map the l_column_name based on the selected viewby

  IF (p_page_parameter_tbl.count > 0) THEN
     FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP
       IF p_page_parameter_tbl(i).parameter_name = 'FII_DIM1' THEN
          l_fii_dim1 := p_page_parameter_tbl(i).parameter_id;
       END IF;
     END LOOP;
  END IF;


/*--------------------------------------------------------------+
 |      FII_MEASURE1    - Hold Name                             |
 |      FII_MEASURE2    - Number of Holds                       |
 |      FII_MEASURE3    - Number of Invoices                    |
 |      FII_MEASURE14   - Grand Total of Number of Holds        |
 |      FII_MEASURE15   - Grand Total of Number of Invoices     |
 +--------------------------------------------------------------*/

IF ((l_fii_dim1 is not null) AND (l_fii_dim1 <> 'All' )) THEN
         IF l_fii_dim1 = 'OTHER' THEN
            l_cat_join := 'and f.HOLD_CATEGORY NOT IN (''VARIANCE'',''PO MATCHING'',
                          ''INVOICE'', ''USER DEFINED'')';
         ELSE
           l_cat_join := 'and f.HOLD_CATEGORY in (&FII_DIM1)';
         END IF;
elsif  ((l_fii_dim1 is  null) OR (l_fii_dim1 = 'All' ))  THEN
            l_cat_join    := ' ';
END IF;



-- Construct the sql query to be sent
sqlstmt := '
     SELECT
              f.HOLD_CODE                                    FII_MEASURE1,
              count(f.HOLD_CODE)                             FII_MEASURE2,
              count(distinct(f.INVOICE_ID))                  FII_MEASURE3,
              sum(count(f.HOLD_CODE)) over()                 FII_MEASURE14,
              sum(count(distinct(f.INVOICE_ID))) over()      FII_MEASURE15
     FROM     FII_AP_INV_HOLDS_B f
     WHERE    f.hold_date <= &BIS_CURRENT_ASOF_DATE
               '||l_org_where||l_supplier_where||'
                '||l_cat_join||'
     AND      (f.release_date > &BIS_CURRENT_ASOF_DATE OR f.release_date IS NULL)
     GROUP BY f.HOLD_CODE
     &ORDER_BY_CLAUSE' ;

--       Binding Section

       FII_PMV_Util.bind_variable(
       p_sqlstmt=> sqlstmt,
       p_page_parameter_tbl=>p_page_parameter_tbl,
       p_sql_output=>get_hold_type_sum_sql,
       p_bind_output_table=>get_hold_type_sum_output,
       p_invoice_number=>l_invoice_number,
       p_record_type_id=>l_record_type_id,
       p_view_by=>l_view_by,
       p_gid=>l_gid
       );



END get_hold_type_sum;


PROCEDURE get_hold_trend (
   p_page_parameter_tbl      IN  BIS_PMV_PAGE_PARAMETER_TBL,
   get_hold_trend_sql        OUT NOCOPY VARCHAR2,
   get_hold_trend_output     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
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
  --     l_period_start   Date;
  --     l_days_into_period  Number;
  --     l_cur_period     Number;
  --     l_id_column      VARCHAR2(100);
       l_date_mask      VARCHAR2(240);
       l_url_1            VARCHAR2(240);
       l_url_2            VARCHAR2(240);
       l_previous_date  DATE;
      -- l_count NUMBER;
       l_date    VARCHAR2(1000);
       l_fii_schema     VARCHAR2(30);
       l_status         VARCHAR2(30);
       l_industry       VARCHAR2(30);


 BEGIN

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



      l_record_type_id := 512;

  FII_PMV_Util.get_format_mask(l_date_mask);


-- IF l_supplier is not null and l_supplier <> 'All' then
--    l_gid := 0;
-- ELSE
--    l_gid := 4;
-- END IF;

   -- l_previous_date :=  add_months (l_as_of_date, -11);


/*--------------------------------------------------------------+
 |      FII_MEASURE1    - Date                                  |
 |      FII_MEASURE2    - Open Payables Amount                  |
 |      FII_MEASURE3    - Total Number of Invoices              |
 |      FII_MEASURE4    - Invoices on Hold Amount               |
 |      FII_MEASURE5    - Number of Invoices                    |
 |      FII_MEASURE6    - Weighted Average Days Past Due        |
 ---------------------------------------------------------------*/

-- for fii_measure5

-- if Operating Unit and Supplier are selected then drills to Invoice Detail
-- report for the total invoices using the same parameters.
-- Form function to drill to : FII_AP_INV_ON_HOLD_DETAIL.


/* As part of bug 3497818 we check if the table FII_AR_SALES_CREDITS is present. If it is present then we need
to use the new logic of populating the urls which is available in 11.5.10 env so as to avoid the security concern
arising due to using of Drill across package.
For 11.5.9 environments we will be using the same old logic of using the drill across package for passing the dates
In 11.5.9 environments the FII_AR_SALES_CREDITS table will not exist and hence this test will suffice.*/

 IF(FND_INSTALLATION.GET_APP_INFO('FII', l_status, l_industry, l_fii_schema))
  THEN NULL;
  END IF;

/* Commented out by VKAZHIPU, since FII_AP_DRILL_ACROSS Package is not used for drill down */
/* bug 4568962 */


/*select count(*)  into l_count from all_tables where table_name = 'FII_AR_SALES_CREDITS' and
 rownum = 1 and  owner = l_fii_schema;

IF l_count = 0 THEN

       IF   (l_org_where LIKE '%ORGANIZATION+FII_OPERATING_UNITS%'  AND l_supplier_where LIKE '%SUPPLIER+POA_SUPPLIERS%') THEN
              l_url_1  := 'pFunctionName=FII_AP_DRILL_ACROSS&pSource=FII_AP_HOLD_TREND&pOperatingUnit=FII_OPERATING_UNITS&pSupplier=POA_SUPPLIERS&pCurrency=FII_CURRENCIES&pAsOfDateValue=FII_MEASURE1&pPeriod=Dummy&pParamIds=Y';
       ELSE
              l_url_1 := '';
       END IF;

ELSE */


       IF   (l_org_where LIKE '%ORGANIZATION+FII_OPERATING_UNITS%'  AND l_supplier_where LIKE '%SUPPLIER+POA_SUPPLIERS%') THEN
              l_url_1 := 'AS_OF_DATE=''||drill_date||''&pFunctionName=FII_AP_INV_ON_HOLD_DETAIL&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_INV_ON_HOLD_DETAIL';
      ELSE
              l_url_1 := '';
      END IF;

--END IF;

sqlstmt :=
      ' SELECT name                                     VIEWBY,
              id                                        VIEWBYID,
    name                          FII_MEASURE1,
           sum(open_amt)                 FII_MEASURE2,
           sum(open_count)               FII_MEASURE3,
           sum(inv_on_hold_amt)          FII_MEASURE4,
           sum(inv_on_hold_count)        FII_MEASURE5,
           id                            FII_MEASURE6,
           '''||l_url_1||'''             FII_ATTRIBUTE1
    FROM
          (SELECT
                 t.ent_period_id                                id,
                 to_char(t.end_date,'''||l_date_mask||''')      name,
                 to_char(t.end_date,''DD/MM/YYYY'')            drill_date,
                 sum( f.open_amt'||l_currency||')              open_amt,
                 sum(f.open_count)                               open_count,
                 0                                              inv_on_hold_amt,
                 0                                              inv_on_hold_count
           FROM  FII_AP_LIA_IB_MV      f,
                 fii_time_structures   cal,
                 fii_time_ent_period    t
           WHERE f.time_id = cal.time_id
           AND   f.period_type_id = cal.period_type_id
           AND   bitand(cal.record_type_id,  :RECORD_TYPE_ID) = :RECORD_TYPE_ID
           AND   cal.report_date  = t.end_date
           AND   t.end_date >=  :PREVIOUS_DATE
           AND   t.end_date < &BIS_CURRENT_ASOF_DATE
           AND   f.gid = :GID2'||l_org_where||l_supplier_where||'
           GROUP BY t.ent_period_id, t.end_date
           UNION ALL
           SELECT
                 10000000                                       id,
                 to_char(cal.report_date,'''||l_date_mask||''')  name,
                 to_char(cal.report_date,''DD/MM/YYYY'')        drill_date,
                 sum(f.open_amt'||l_currency||')                open_amt,
                 sum(f.open_count)                              open_count,
                 0                                              inv_on_hold_amt,
                 0                                              inv_on_hold_count
           FROM  FII_AP_LIA_IB_MV      f,
                 fii_time_structures   cal
           WHERE f.time_id = cal.time_id
           AND   f.period_type_id = cal.period_type_id
           AND   bitand(cal.record_type_id, :RECORD_TYPE_ID) = :RECORD_TYPE_ID
           AND   cal.report_date = &BIS_CURRENT_ASOF_DATE
           AND   f.gid = :GID2'||l_org_where||l_supplier_where||'
           GROUP BY cal.report_date
           UNION ALL
           SELECT
                 t.ent_period_id                                id,
                 to_char(t.end_date,'''||l_date_mask||''')      name,
                 to_char(t.end_date,''DD/MM/YYYY'')             drill_date,
                 0                                              open_amt,
                 0                                              open_count,
                 sum(f.inv_on_hold_amt'||l_currency||')         inv_on_hold_amt,
                 sum(f.inv_on_hold_count)                       inv_on_hold_count
           FROM  FII_AP_HLIA_I_MV      f,
                 fii_time_structures   cal,
                 fii_time_ent_period   t
           WHERE f.time_id = cal.time_id
           AND   f.period_type_id = cal.period_type_id
           AND   bitand(cal.record_type_id,  :RECORD_TYPE_ID) = :RECORD_TYPE_ID
           AND   cal.report_date  = t.end_date
           AND   t.end_date >=  :PREVIOUS_DATE
           AND   t.end_date < &BIS_CURRENT_ASOF_DATE
           AND   f.gid = :GID2'||l_org_where||l_supplier_where||'
           GROUP BY t.ent_period_id, t.end_date
           UNION ALL
           SELECT
                 10000000                                       id,
                 to_char(cal.report_date,'''||l_date_mask||''')  name,
                 to_char(cal.report_date,''DD/MM/YYYY'')        drill_date,
                 0                                              open_amt,
                 0                                              open_count,
                 sum(f.inv_on_hold_amt'||l_currency||')         inv_on_hold_amt,
                 sum(f.inv_on_hold_count)                       inv_on_hold_count
           FROM  FII_AP_HLIA_I_MV      f,
                 fii_time_structures   cal
           WHERE f.time_id = cal.time_id
           AND   f.period_type_id = cal.period_type_id
           AND   bitand(cal.record_type_id, :RECORD_TYPE_ID) = :RECORD_TYPE_ID
           AND   cal.report_date = &BIS_CURRENT_ASOF_DATE
           AND   f.gid = :GID2'||l_org_where||l_supplier_where||'
           GROUP BY cal.report_date)
    GROUP by id, name, drill_date
    ORDER BY id  asc ' ;




FII_PMV_UTIL.bind_variable(
       p_sqlstmt=>sqlstmt,
       p_page_parameter_tbl=>p_page_parameter_tbl,
       p_sql_output=>get_hold_trend_sql,
       p_bind_output_table=>get_hold_trend_output,
       p_record_type_id=>l_record_type_id,
       p_view_by=>l_view_by,
       p_gid=>l_gid
--       p_period_start=>l_period_start
--       p_cur_period=>l_cur_period
       );
END get_hold_trend;


END fii_ap_hold_sum;

/
