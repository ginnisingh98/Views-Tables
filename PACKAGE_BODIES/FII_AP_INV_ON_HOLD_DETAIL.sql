--------------------------------------------------------
--  DDL for Package Body FII_AP_INV_ON_HOLD_DETAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AP_INV_ON_HOLD_DETAIL" AS
/* $Header: FIIAPD3B.pls 120.1 2005/10/30 05:05:08 appldev noship $ */

PROCEDURE  get_inv_detail (
        p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
        get_inv_detail_sql        OUT NOCOPY VARCHAR2,
        get_inv_detail_output     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
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
       l_org_where1      VARCHAR2(240);
       l_supplier_where1 VARCHAR2(240);
       l_report_source  VARCHAR2(240);
       l_discount_offered VARCHAR2(50);
       l_join_drill     VARCHAR2(500);
       l_inv_holds_join VARCHAR2(500);
       l_fii_dim1       VARCHAR2(240);
       l_fii_dim2       VARCHAR2(240);
       l_yes            VARCHAR2(240);
       l_no             VARCHAR2(240);
       l_date_mask      VARCHAR2(240);

       l_discount_taken VARCHAR2(50);
       l_discount_lost VARCHAR2(50);
       l_discount_available VARCHAR2(50);
       l_amount_remaining VARCHAR2(50);
       l_invoice_amount VARCHAR2(50);


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

       FII_PMV_Util.Get_Report_Source(
       p_page_parameter_tbl,
       l_report_source
       );

  IF (p_page_parameter_tbl.count > 0) THEN
     FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP
       IF p_page_parameter_tbl(i).parameter_name = 'FII_DIM1' THEN
          l_fii_dim1 := p_page_parameter_tbl(i).parameter_id;

       END IF;
     END LOOP;
  END IF;

  IF (p_page_parameter_tbl.count > 0) THEN
     FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP
       IF p_page_parameter_tbl(i).parameter_name = 'FII_DIM2' THEN
          l_fii_dim2 := p_page_parameter_tbl(i).parameter_id;

       END IF;
     END LOOP;
  END IF;


      l_discount_offered := FII_PMV_Util.get_base_curr_colname(l_currency, 'discount_offered');
      l_discount_taken := FII_PMV_Util.get_base_curr_colname(l_currency, 'discount_taken');
      l_discount_lost := FII_PMV_Util.get_base_curr_colname(l_currency, 'discount_lost');
      l_discount_available := FII_PMV_Util.get_base_curr_colname(l_currency, 'discount_available');
      l_amount_remaining := FII_PMV_Util.get_base_curr_colname(l_currency, 'amount_remaining');

       IF l_currency = '_prim_g' THEN
          l_invoice_amount := 'prim_amount';
       ELSIF l_currency = '_sec_g' THEN
          l_invoice_amount := 'sec_amount';
       ELSIF l_currency = '_b' THEN
          l_invoice_amount := 'base_amount';
       END IF;


      l_record_type_id := 1143;


FII_PMV_Util.get_yes_no_msg(l_yes, l_no);

FII_PMV_Util.get_format_mask(l_date_mask);

/*--------------------------------------------------------------+
 |      VIEWBY          - Either Operating Unit / Supplier      |
 |      VIEWBYID        - Either org_id / supplier_id           |
 |      FII_MEASURE1    - Invoice Number                        |
 |      FII_MEASURE2    - Invoice ID                            |
 |      FII_MEASURE3    - Invoice Type                          |
 |      FII_MEASURE4    - Invoice Date                          |
 |      FII_MEASURE5    - Entered Date                          |
 |      FII_MEASURE6    - Due Date                              |
 |      FII_MEASURE7    - Transaction Currency Code             |
 |      FII_MEASURE8    - Transaction Invoice Amount            |
 |      FII_MEASURE9    - Invoice Amount                        |
 |      FII_MEASURE10   - Unpaid Amount                         |
 |      FII_MEASURE11   - On Hold                               |
 |      FII_MEASURE12   - Days on Hold                          |
 |      FII_MEASURE13   - Discount Offered                      |
 |      FII_MEASURE14   - Discount Taken                        |
 |      FII_MEASURE15   - Discount Lost                         |
 |      FII_MEASURE16   - Discount Remaining                    |
 |      FII_MEASURE17   - Terms                                 |
 |      FII_MEASURE18   - Source                                |
 |      FII_REPORT_SOURCE  - Report Source                      |
 |      FII_MEASURE20   - Grand Total of Invoice Amount         |
 |      FII_MEASURE21   - Grand Total of Unpaid Amount          |
 |      FII_MEASURE22   - Grand Total of Discount Offered       |
 |      FII_MEASURE23   - Grand Total of Discount Taken         |
 |      FII_MEASURE24   - Grand Total of Discount Lost          |
 |      FII_MEASURE25   - Grand Total of Discount Remaining     |
 |      FII_DIM1	- Hold Category parameter               |
 |      FII_DIM2	- Hold Type parameter                   |
 +--------------------------------------------------------------*/

 /* Performance tuning + correct days on hold logic
    1.removed period type id = 1.
    2.column aliases for the columns selected in sub-query match the AK MEASURE name.
    3.On Hold flag is derived from sub-query hold, driving table is fii_ap_inv_holds_b.
    4.days on hold is derived from sub-query hold1, driving table is fii_ap_hhist_ib_mv.
    5.variable l_inv_holds_join is used when the WHERE clause includes HOLD_CODE and HOLD_CATEGORY.
    6.main query's  driving table is fii_ap_pay_sched_b.
    7.AK FII_AP_INV_DETAIL_H has been changed to display - 30 rows.
    8.Start/End index implemented.
    9.Grand totals moved to second level.
 */

-- Construct the sql query to be sent


  IF(l_report_source = 'FII_AP_INV_ON_HOLD_DETAIL') THEN
        l_join_drill := ' ';
        l_inv_holds_join := ' ';
  ELSIF(l_report_source = 'FII_AP_INV_ON_HOLD_DUE_DETAIL') THEN
        l_join_drill := 'and ps.due_date >= &BIS_CURRENT_ASOF_DATE ';

        l_inv_holds_join := ' ';
  ELSIF(l_report_source = 'FII_AP_INV_ON_HOLD_PDUE_DETAIL') THEN
        l_join_drill := 'and ps.due_date < &BIS_CURRENT_ASOF_DATE ';

        l_inv_holds_join := ' ';
  ELSIF(l_report_source = 'FII_AP_INV_HOLD_CAT_DETAIL') THEN
         /*
         l_join_drill := ' and base.invoice_id in (SELECT DISTINCT invoice_id
                          from fii_ap_inv_holds_b f
                          WHERE hold_date <= &BIS_CURRENT_ASOF_DATE
                          '||l_org_where||l_supplier_where||'
                          and (release_date > &BIS_CURRENT_ASOF_DATE or release_date is null)) ';
        */
         l_join_drill := ' ';
         l_inv_holds_join := ' ';
  ELSIF(l_report_source = 'FII_AP_INV_HOLD_TYPE_DETAIL') THEN
           IF ((l_fii_dim1 is not null) AND (l_fii_dim1 <> 'All' )AND (l_fii_dim1 <> 'OTHER')) THEN
              /*
              l_join_drill := ' and base.invoice_id in (SELECT DISTINCT invoice_id
                          from fii_ap_inv_holds_b f
                          WHERE  hold_code = &FII_DIM2
                          '||l_org_where||l_supplier_where||'
                          and hold_category = &FII_DIM1
                          and hold_date <= &BIS_CURRENT_ASOF_DATE
                          and (release_date > &BIS_CURRENT_ASOF_DATE or release_date is null)) ';
              */
              l_join_drill := ' ';
              l_inv_holds_join := ' and hold_code = &FII_DIM2
                                    and hold_category = &FII_DIM1 ';
           ELSIF ((l_fii_dim1 is not null) AND (l_fii_dim1 <> 'All' )AND (l_fii_dim1 = 'OTHER')) THEN
              /*
              l_join_drill := ' and base.invoice_id in (SELECT DISTINCT invoice_id
                          from fii_ap_inv_holds_b f
                          WHERE  hold_code = &FII_DIM2
                          '||l_org_where||l_supplier_where||'
                          and hold_category NOT IN (''VARIANCE'',''PO MATCHING'',
                          ''INVOICE'', ''USER DEFINED'')
                          and hold_date <= &BIS_CURRENT_ASOF_DATE
                          and (release_date > &BIS_CURRENT_ASOF_DATE or release_date is null)) ';
               */
               l_join_drill := ' ';
               l_inv_holds_join := ' and hold_code = &FII_DIM2
                                     and hold_category NOT IN (''VARIANCE'',''PO MATCHING'',
                                     ''INVOICE'', ''USER DEFINED'') ';
           ELSE
              /*
              l_join_drill := ' and base.invoice_id in (SELECT DISTINCT invoice_id
                          from fii_ap_inv_holds_b f
                          WHERE  hold_code = &FII_DIM2
                          '||l_org_where||l_supplier_where||'
                          and hold_date <= &BIS_CURRENT_ASOF_DATE
                          and (release_date > &BIS_CURRENT_ASOF_DATE or release_date is null)) ';
               */
               l_join_drill := ' ';
               l_inv_holds_join := ' and hold_code = &FII_DIM2 ';
          END IF;
  ELSIF(l_report_source IS NULL) THEN
        l_join_drill := ' ';
        l_inv_holds_join := ' ';
  END IF;

  -- l_org_where1 := replace(l_org_where, 'f', 'ps');
  l_org_where1 :=  replace(l_org_where, 'f.', 'ps.');
  l_supplier_where1 := replace(l_supplier_where, 'f', 'ps');

sqlstmt := 'Select  h.FII_MEASURE1 FII_MEASURE1,
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
                    h.FII_MEASURE20 FII_MEASURE20,
                    h.FII_MEASURE21 FII_MEASURE21,
                    h.FII_MEASURE22 FII_MEASURE22,
                    h.FII_MEASURE23 FII_MEASURE23,
                    h.FII_MEASURE24 FII_MEASURE24,
                    h.FII_MEASURE25 FII_MEASURE25
                     from
                     (
                     Select  g.FII_MEASURE1 FII_MEASURE1,
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
                             sum(g.FII_MEASURE9) over()     FII_MEASURE20,
                             sum(g.FII_MEASURE10) over()     FII_MEASURE21,
                             sum(g.FII_MEASURE13) over()      FII_MEASURE22,
                             sum(g.FII_MEASURE14) over()       FII_MEASURE23,
                             sum(g.FII_MEASURE15) over()        FII_MEASURE24,
                             sum(g.FII_MEASURE16) over()   FII_MEASURE25,
                             (rank () over(&ORDER_BY_CLAUSE nulls last, g.FII_MEASURE2)) -1 rnk
                    from
                    (

SELECT base.invoice_number 			FII_MEASURE1,
       base.invoice_id				FII_MEASURE2,
       base.invoice_type 	        		FII_MEASURE3,
       to_char(base.invoice_date,'''||l_date_mask||''') 	FII_MEASURE4,
       base.entered_date			FII_MEASURE5, -- Bug #4266826
       min(ps.due_date)				FII_MEASURE6, -- Bug #4266826
       base.invoice_currency_code   		FII_MEASURE7,
       base.invoice_amount 		        	FII_MEASURE8,
       base.'||l_invoice_amount||' 		FII_MEASURE9,
       sum(ps.'||l_amount_remaining||') 	FII_MEASURE10,
       decode(nvl(hold.FII_MEASURE11, ''N''), ''Y'',
        '''||l_yes||''', ''N'', '''||l_no||''') FII_MEASURE11,
       nvl(hold1.FII_MEASURE12,0) 	 	FII_MEASURE12,
       base.'||l_discount_offered||'		FII_MEASURE13,
       sum(ps.'||l_discount_taken||') 		FII_MEASURE14,
       sum(ps.'||l_discount_lost||') 		FII_MEASURE15,
       sum(ps.'||l_discount_available||')	FII_MEASURE16,
       term.name    				FII_MEASURE17,
       base.source 				FII_MEASURE18
FROM   FII_AP_INVOICE_B base,
       FII_AP_PAY_SCHED_B ps,
       (SELECT invoice_id,
               ''Y'' FII_MEASURE11
        FROM fii_ap_inv_holds_b f
        WHERE hold_date <= &BIS_CURRENT_ASOF_DATE
        AND (release_date > &BIS_CURRENT_ASOF_DATE or release_date is null)
        '||l_inv_holds_join||'
        '||l_org_where||l_supplier_where||'
        GROUP BY f.invoice_id
        ) hold,
        (SELECT invoice_id,
                sum(days_on_hold) FII_MEASURE12
         FROM fii_ap_hhist_ib_mv f
         WHERE 1 = 1
         '||l_org_where||l_supplier_where||'
         GROUP BY invoice_id
         ) hold1,
      ap_terms_tl term
WHERE base.invoice_id = ps.invoice_id
AND ps.action_date <= &BIS_CURRENT_ASOF_DATE
'||l_org_where1||l_supplier_where1||'
'||l_join_drill||'
AND hold.invoice_id = base.invoice_id
AND hold1.invoice_id = base.invoice_id
AND hold.invoice_id = hold1.invoice_id
AND base.terms_id = term.term_id
AND base.cancel_flag = ''N''
AND term.language = userenv(''LANG'')
GROUP BY base.invoice_number,
         base.invoice_id,
         base.invoice_type,
         base.invoice_date,
         base.entered_date,
         base.invoice_currency_code,
         base.invoice_amount,
         base.'||l_invoice_amount||',
         hold.FII_MEASURE11,
         hold1.FII_MEASURE12,
         base.'||l_discount_offered||',
         term.name,
         base.source
HAVING    sum(ps.'||l_amount_remaining||') <> 0
    ) g
    ) h
     where (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
&ORDER_BY_CLAUSE' ;

--       Binding Section

       FII_PMV_Util.bind_variable(
       p_sqlstmt=> sqlstmt,
       p_page_parameter_tbl=>p_page_parameter_tbl,
       p_sql_output=> get_inv_detail_sql,
       p_bind_output_table=> get_inv_detail_output,
 --    p_invoice_number=>l_invoice_number,
       p_record_type_id=>l_record_type_id
--      p_view_by=>l_view_by,
--       p_gid=>l_gid
       );


END get_inv_detail;


END fii_ap_inv_on_hold_detail;

/
