--------------------------------------------------------
--  DDL for Package Body FII_AP_PAID_INV_ACTIVITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AP_PAID_INV_ACTIVITY" AS
/* $Header: FIIAPS2B.pls 120.1 2005/08/22 15:34:16 vkazhipu ship $ */

 PROCEDURE GET_PAID_INV
     ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
       paid_invoice_sql out NOCOPY VARCHAR2,
       paid_invoice_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)IS
       /* declaration section */
       sqlstmt          VARCHAR2(15000);

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
       l_paid_inv_count VARCHAR2(240);
       l_paid_on_time   VARCHAR2(240);
       l_paid_late      VARCHAR2(240);
       l_payment_count  VARCHAR2(240);
       l_period_type_str VARCHAR2(10);

       l_url_1 VARCHAR2(10000);
       l_url_4 VARCHAR2(10000);
       l_url_2 VARCHAR2(10000);
       l_url_3 VARCHAR2(10000);
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
       l_period_type_str := FII_PMV_Util.get_period_type_suffix(l_period_type);
       l_paid_inv_count := 'paid_inv_count'||l_period_type_str;
       l_paid_on_time := 'paid_on_time_count'||l_period_type_str;
       l_paid_late       := 'paid_late_count'||l_period_type_str;
       l_payment_count := 'payment_count'||l_period_type_str;

       /**************Description of Measures, Attributes returned to
PMV *****
        FII_MEASURE1 - Paid Amount, (Payments)
        FII_MEASURE12 - Paid Amount in base currency, (Payments)
        FII_MEASURE2 - Prior Paid amount,(Payments)
        FII_MEASURE16 - Prior Paid amount in base currency,(Payments)
        FII_MEASURE3 - Change (Payments)
        FII_MEASURE4 - Number of Invoices, (Payments)
        FII_MEASURE5 - Prior Number of Invoices,
        FII_MEASURE6 - Change (Payments)
        FII_MEASURE7 - Number of Payments,(Payments)
        FII_MEASURE8 - Prior Number of Payments,
        FII_MEASURE9 - Change (Payments)
        FII_MEASURE10 - Paid on Time,
        FII_MEASURE60 - # of invoices (Paid on Time)
        FII_MEASURE61 = prior # of invoices (Paid on Time)
        FII_MEASURE13 - Change (Paid on Time)
        FII_MEASURE14 - Paid late Amount,
        FII_MEASURE62 - # of invoices (Paid Late)
        FII_MEASURE63 - prior # of invoices (Paid Late)
        FII_MEASURE17 - Change (Paid Late)
        FII_MEASURE18 - Electronic Disbursement Amount,
        FII_MEASURE27 - Electronic Payment (calculation goes as MEASURE18/MEASURE1*100)
        FII_MEASURE28 - Invoice to Payment Days
        FII_MEASURE29 - Prior Invoice to Payment Days
        FII_MEASURE30 - Change        (between MEASURE51 and MEASURE52)
        FII_MEASURE20 - Grand Total Amount (Payment)
        FII_MEASURE21 - Grand Total Change (Payment)
        FII_MEASURE22 - Grand Total # of invocies (Paid on Time)
        FII_MEASURE23 - Grand Total Change (Paid on Time)
        FII_MEASURE24 - Grand Total Amount (Paid Late)
        FII_MEASURE25 - Grand Total # of invoices (Paid Late)
        FII_MEASURE64 Paid Late % for Payment Porltet (this is refered by FII_CV3)
        FII_MEASURE65 Change (Paid Late - Payment portlet).  This is refered by FII_CV4.
        FII_MEASURE66 - Grand Total(Paid LAte % Payment Portlet)
        FII_MEASURE67 - Grand Total (Change - Payment Portlet)

        FII_MEASURE26 - Grand Total Change (Paid Late)
        FII_ATTRIBUTE2 - Grand Total Number of Invoices
        FII_ATTRIBUTE3 - Grand Total Change
        FII_ATTRIBUTE4 - Grand Total Number of Payments
        FII_ATTRIBUTE5 - Grand Total Change (Payments)
        FII_ATTRIBUTE6 - Grand Total Amount (Paid on Time)
        FII_GRAND_TOTAL1 - Grand Total for Electronic Payment
        FII_GRAND_TOTAL2 - Grand Total Invoice to Payment Days
        FII_GRAND_TOTAL3 - Grand Total Change
        FII_MEASURE31 - Graph Legends for Paid on Time
        FII_MEASURE32 - Graph Legends for  Paid Late
        FII_EMPTY_COLSPAN - Empty Column span on top of Electronic Payment, Invoice to Payment Days, Change
        FII_PAID_LATE - Colspan Paid Late
        FII_PAID_TIME - Colspan Paid Time
        FII_PAYMENTS_COLSPAN - Colspan Payments
        FII_ATTRIBUTE10 - Drills for Number of Invoices
        FII_ATTRIBUTE11 - Drills for Number of Payments
        FII_MEASURE51 - Invoice to Payment Days (Measure28/Measure1)
        FII_MEASURE52 - Prior invoice to payment days (Measure29/MEasure2)
***********************************************************************/

       /**************CustomDrills*******************************************/
l_url_1 :=

'pFunctionName=FII_AP_PAID_INV_DETAIL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_PAID_INV_DETAIL&FII_CHECK_ID=All&FII_CHECK=All'

;
l_url_4  :=
'pFunctionName=FII_AP_PAID_INV&VIEW_BY=SUPPLIER+POA_SUPPLIERS&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'

;
l_url_2 :=
'pFunctionName=FII_AP_PAYMENT_DETAIL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'

;
l_url_3  :=
'pFunctionName=FII_AP_PAID_INV&VIEW_BY=SUPPLIER+POA_SUPPLIERS&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'

;


       /* Main SQL section */
       sqlstmt := 'select VIEWBY,
                        VIEWBYID,
                        sum(FII_MEASURE1) FII_MEASURE1,
                        sum(FII_MEASURE12) FII_MEASURE12,
                        sum(FII_MEASURE2) FII_MEASURE2,
                        sum(FII_MEASURE16) FII_MEASURE16,
                        sum(FII_MEASURE4) FII_MEASURE4,
                        sum(FII_MEASURE5) FII_MEASURE5,
                        sum(FII_MEASURE7) FII_MEASURE7,
                        sum(FII_MEASURE8)  FII_MEASURE8,
                        sum(FII_MEASURE10) FII_MEASURE10,
                        sum(FII_MEASURE11) FII_MEASURE11,
                        sum(FII_MEASURE60) FII_MEASURE60,
                        sum(FII_MEASURE61) FII_MEASURE61,
                        sum(FII_MEASURE14) FII_MEASURE14,
                        sum(FII_MEASURE15) FII_MEASURE15,
                        sum(FII_MEASURE62) FII_MEASURE62,
                        sum(FII_MEASURE63) FII_MEASURE63,
                        sum(FII_MEASURE18) FII_MEASURE18,
                        sum(FII_MEASURE28) FII_MEASURE28,
                        sum(FII_MEASURE29) FII_MEASURE29,
                        sum(FII_MEASURE20) FII_MEASURE20,
                        sum(FII_MEASURE24) FII_MEASURE24,
                        sum(FII_ATTRIBUTE2) FII_ATTRIBUTE2,
                        sum(FII_ATTRIBUTE4) FII_ATTRIBUTE4,
                        sum(FII_MEASURE23) FII_MEASURE23,
                        sum(FII_MEASURE26) FII_MEASURE26,
                        sum(FII_MEASURE21) FII_MEASURE21,
                        sum(FII_MEASURE22) FII_MEASURE22,
                        sum(FII_MEASURE25) FII_MEASURE25,
                        sum(FII_ATTRIBUTE6) FII_ATTRIBUTE6,
                        sum(FII_ATTRIBUTE3) FII_ATTRIBUTE3,
                        sum(FII_ATTRIBUTE5) FII_ATTRIBUTE5,
                        sum(FII_GRAND_TOTAL1) FII_GRAND_TOTAL1,
                        sum(FII_GRAND_TOTAL2) FII_GRAND_TOTAL2,
                        sum(FII_GRAND_TOTAL3) FII_GRAND_TOTAL3,
                        sum(FII_MEASURE66) FII_MEASURE66,
                        sum(FII_MEASURE67) FII_MEASURE67,
                        decode('''||l_view_by||''',''ORGANIZATION+FII_OPERATING_UNITS'','''||l_url_4||''', ''SUPPLIER+POA_SUPPLIERS'','''||l_url_1||''', null) FII_ATTRIBUTE10,
                        decode('''||l_view_by||''',''ORGANIZATION+FII_OPERATING_UNITS'','''||l_url_3||''', ''SUPPLIER+POA_SUPPLIERS'','''||l_url_2||''', null) FII_ATTRIBUTE11
           FROM (select VIEWBY,
                        VIEWBYID,
                        FII_MEASURE1 FII_MEASURE1,
                        FII_MEASURE12 FII_MEASURE12,
                        FII_MEASURE2 FII_MEASURE2,
                        FII_MEASURE16 FII_MEASURE16,
                        FII_MEASURE4 FII_MEASURE4,
                        FII_MEASURE5 FII_MEASURE5,
                        FII_MEASURE7 FII_MEASURE7,
                        FII_MEASURE8  FII_MEASURE8,
                        FII_MEASURE10 FII_MEASURE10,
                        FII_MEASURE11 FII_MEASURE11,
                        FII_MEASURE60 FII_MEASURE60,
                        FII_MEASURE61 FII_MEASURE61,
                        FII_MEASURE14 FII_MEASURE14,
                        FII_MEASURE15 FII_MEASURE15,
                        FII_MEASURE62 FII_MEASURE62,
                        FII_MEASURE63 FII_MEASURE63,
                        FII_MEASURE18 FII_MEASURE18,
                        FII_MEASURE28 FII_MEASURE28,
                        FII_MEASURE29 FII_MEASURE29,
                        sum(FII_MEASURE1) over() FII_MEASURE20,
                        sum(FII_MEASURE14) over() FII_MEASURE24,
                        sum(FII_MEASURE4) over() FII_ATTRIBUTE2,
                        sum(FII_MEASURE7) over() FII_ATTRIBUTE4,
                        decode(sum(FII_MEASURE61) over(), 0, 0,
                                (sum(FII_MEASURE60) over() - sum(FII_MEASURE61) over())  * 100
                                       /sum(FII_MEASURE61) over()
                               ) FII_MEASURE23,											-- Bug #3969884
                        decode(sum(FII_MEASURE63) over(), 0, 0,
                                 (sum(FII_MEASURE62) over() - sum(FII_MEASURE63) over()) * 100
                                        /sum(FII_MEASURE63) over()
                               ) FII_MEASURE26,											-- Bug #3969884
                        decode(sum(FII_MEASURE2) over(), 0, 0,
                        (sum(FII_MEASURE1) over() - sum(FII_MEASURE2) over()) *100/sum(FII_MEASURE2) over()) FII_MEASURE21,	-- Bug #3969884
                        sum(FII_MEASURE60) over() FII_MEASURE22,
                        sum(FII_MEASURE62) over()  FII_MEASURE25,
                        sum(FII_MEASURE10) over() FII_ATTRIBUTE6,
                        decode(sum(FII_MEASURE5) over(), 0, 0,
                        (sum(FII_MEASURE4) over() - sum(FII_MEASURE5) over()) *100
                         /sum(FII_MEASURE5) over()) FII_ATTRIBUTE3, 								-- Bug #3969884
                        decode(sum(FII_MEASURE8) over(), 0, 0,
                        (sum(FII_MEASURE7) over() - sum(FII_MEASURE8) over()) *100
                         /sum(FII_MEASURE8) over()) FII_ATTRIBUTE5,								-- Bug #3969884
                        decode(sum(FII_MEASURE7) over(), 0, 0,
                        sum(FII_MEASURE18) over() * 100/sum(FII_MEASURE7) over()
                        ) FII_GRAND_TOTAL1, 											-- Bug #3969884
                        decode(sum(FII_MEASURE12) over(), 0, 0,
                        sum(FII_MEASURE28) over()
                        /sum(FII_MEASURE12) over() ) FII_GRAND_TOTAL2,								-- Bug #3969884
                         case when sum(FII_MEASURE12) over() = 0 then 0 else
                                 case  when sum(FII_MEASURE16) over() = 0 then 0 else
                                          case   when sum(FII_MEASURE29) over() = 0 then 0 else
                                                     (
                                                      (sum(FII_MEASURE28) over()
                                                      /sum(FII_MEASURE12) over() -
                                                      sum(FII_MEASURE29) over()
                                                      /sum(FII_MEASURE16) over()
                                                      )*100)
                                                      /(sum(FII_MEASURE29) over()
                                                      /sum(FII_MEASURE16) over() )
                                            end
                               end
                        end FII_GRAND_TOTAL3,											-- Bug #3969884
                        decode(sum(FII_MEASURE4) over(), 0, 0,
                                   sum(FII_MEASURE62) over()*100/sum(FII_MEASURE4) over()) FII_MEASURE66,			-- Bug #3969884
                        case when sum(FII_MEASURE4) over() = 0 then 0 else
                             case when sum(FII_MEASURE5) over() = 0 then 0 else
                                  case when sum(FII_MEASURE63) over() = 0 then 0 else
                                       ((sum(FII_MEASURE62) over()*100/sum(FII_MEASURE4) over()) - (sum(FII_MEASURE63) over()*100/sum(FII_MEASURE5) over()))
                                  end
                             end
                        end FII_MEASURE67, 											-- Bug #3969884
                        ( rank() over (&ORDER_BY_CLAUSE nulls last, VIEWBYID)) - 1 rnk
             FROM (
               select VIEWBY,
                      VIEWBYID,
                      sum(FII_MEASURE1) FII_MEASURE1,
                      sum(FII_MEASURE12) FII_MEASURE12,
                      sum(FII_MEASURE2) FII_MEASURE2,
                      sum(FII_MEASURE16) FII_MEASURE16,
                      sum(FII_MEASURE4) FII_MEASURE4,
                      sum(FII_MEASURE5) FII_MEASURE5,
                      sum(FII_MEASURE7) FII_MEASURE7,
                      sum(FII_MEASURE8)  FII_MEASURE8,
                      sum(FII_MEASURE10) FII_MEASURE10,
                      sum(FII_MEASURE11) FII_MEASURE11,
                      sum(FII_MEASURE60) FII_MEASURE60,
                      sum(FII_MEASURE61) FII_MEASURE61,
                      sum(FII_MEASURE14) FII_MEASURE14,
                      sum(FII_MEASURE15) FII_MEASURE15,
                      sum(FII_MEASURE62) FII_MEASURE62,
                      sum(FII_MEASURE63) FII_MEASURE63,
                      sum(FII_MEASURE18) FII_MEASURE18,
                      sum(FII_MEASURE28) FII_MEASURE28,
                      sum(FII_MEASURE29) FII_MEASURE29
               from(
                 select viewby_dim.value VIEWBY,
                        viewby_dim.id VIEWBYID,
                        sum(case when cal.report_date =&BIS_CURRENT_ASOF_DATE then f.paid_amt'||l_currency||' else 0 end)  FII_MEASURE1,
                        sum(case when cal.report_date =&BIS_CURRENT_ASOF_DATE then f.paid_amt_b else 0 end)  FII_MEASURE12,
                        sum(case when cal.report_date =&BIS_PREVIOUS_ASOF_DATE then f.paid_amt'||l_currency||' else 0 end) FII_MEASURE2,
                        sum(case when cal.report_date =&BIS_PREVIOUS_ASOF_DATE then f.paid_amt_b else 0 end) FII_MEASURE16,
                        sum(case when cal.report_date =&BIS_CURRENT_ASOF_DATE then f.'||l_paid_inv_count||' else 0 end) FII_MEASURE4,
                        sum(case when cal.report_date =&BIS_PREVIOUS_ASOF_DATE then f.'||l_paid_inv_count||' else 0 end) FII_MEASURE5,
                        sum(case when cal.report_date =&BIS_CURRENT_ASOF_DATE then f.'||l_payment_count||' else 0 end)  FII_MEASURE7,
                        sum(case when cal.report_date =&BIS_PREVIOUS_ASOF_DATE then f.'||l_payment_count||' else 0 end)  FII_MEASURE8,
                        sum(case when cal.report_date =&BIS_CURRENT_ASOF_DATE then f.paid_on_time_amt'||l_currency||' else 0 end) FII_MEASURE10,
                        sum(case when cal.report_date =&BIS_PREVIOUS_ASOF_DATE then f.paid_on_time_amt'||l_currency||' else 0 end) FII_MEASURE11,
                        0 FII_MEASURE60,
                        0 FII_MEASURE61,
                        sum(case when cal.report_date =&BIS_CURRENT_ASOF_DATE then f.paid_late_amt'||l_currency||' else 0 end) FII_MEASURE14,
                        sum(case when cal.report_date =&BIS_PREVIOUS_ASOF_DATE then f.paid_late_amt'||l_currency||' else 0 end) FII_MEASURE15,
                        0 FII_MEASURE62,
                        0 FII_MEASURE63,
                        sum(case when cal.report_date =&BIS_CURRENT_ASOF_DATE then f.e_payment_count else 0 end) FII_MEASURE18,
                        sum(case when cal.report_date =&BIS_CURRENT_ASOF_DATE then f.invoice_to_payment_days else 0 end) FII_MEASURE28,
                        sum(case when cal.report_date =&BIS_PREVIOUS_ASOF_DATE then f.invoice_to_payment_days else 0 end) FII_MEASURE29
                   from FII_AP_PAID_XB_MV f,
                          fii_time_structures cal, '
                          ||l_table_name||' viewby_dim
                   where f.time_id = cal.time_id
                   and   f.period_type_id = cal.period_type_id
                   and   bitand(cal.record_type_id, :RECORD_TYPE_ID) = :RECORD_TYPE_ID
                   and   cal.report_date in (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE)
                   and   f.gid = :GID
                   and   f.'||l_column_name||' = viewby_dim.id '
                   ||l_org_where||l_supplier_where||
                   ' group by viewby_dim.value, viewby_dim.id, to_number(null)
                   union
                   select
                        viewby_dim.value VIEWBY,
                        viewby_dim.id VIEWBYID,
                        0 FII_MEASURE1,
                        0 FII_MEASURE12,
                        0 FII_MEASURE2,
                        0 FII_MEASURE16,
                        0 FII_MEASURE4,
                        0 FII_MEASURE5,
                        0 FII_MEASURE7,
                        0 FII_MEASURE8,
                        0 FII_MEASURE10,
                        0 FII_MEASURE11,
                        sum(case when cal.report_date =&BIS_CURRENT_ASOF_DATE then f.'||l_paid_on_time||' else 0 end) FII_MEASURE60,
                        sum(case when cal.report_date =&BIS_PREVIOUS_ASOF_DATE then f.'||l_paid_on_time||' else 0 end)  FII_MEASURE61,
                        0 FII_MEASURE14,
                        0 FII_MEASURE15,
                        sum(case when cal.report_date =&BIS_CURRENT_ASOF_DATE then f.'||l_paid_late||' else 0 end) FII_MEASURE62,
                        sum(case when cal.report_date =&BIS_PREVIOUS_ASOF_DATE then f.'||l_paid_late||' else 0 end)  FII_MEASURE63,
                        0  FII_MEASURE18,
                        0 FII_MEASURE28,
                        0 FII_MEASURE29
                        FROM FII_AP_PAYOL_XB_MV f,
                          fii_time_structures cal, '
                          ||l_table_name||' viewby_dim
                   where f.time_id = cal.time_id
                   and   f.period_type_id = cal.period_type_id
                   and   bitand(cal.record_type_id, :RECORD_TYPE_ID) = :RECORD_TYPE_ID
                   and   cal.report_date in (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE)
                   and   f.gid = :GID
                   and   f.'||l_column_name||' = viewby_dim.id '
                   ||l_org_where||l_supplier_where||
                   ' group by viewby_dim.value, viewby_dim.id, to_number(null))
               group by VIEWBY, VIEWBYID)
             )
           where (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
           group by VIEWBY, VIEWBYID
           &ORDER_BY_CLAUSE';

      /* Binding Section */
       FII_PMV_Util.bind_variable(
       p_sqlstmt=>sqlstmt,
       p_page_parameter_tbl=>p_page_parameter_tbl,
       p_sql_output=>paid_invoice_sql,
       p_bind_output_table=>paid_invoice_output,
       p_record_type_id=>l_record_type_id,
       p_gid=>l_gid
       );

 END;

 PROCEDURE GET_PAID_INV_DISCOUNT
     ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
       paid_invoice_sql out NOCOPY VARCHAR2,
       paid_invoice_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)IS
       /* declaration section */
       sqlstmt          VARCHAR2(20000);

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
       l_paid_inv_count VARCHAR2(240);
       l_paid_amt       VARCHAR2(240);
       l_per_type       VARCHAR2(240);

       l_url_1          VARCHAR2(1000);
       l_url_4          VARCHAR2(1000);
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

       l_per_type := FII_PMV_Util.get_period_type_suffix(l_period_type);

       /**************Description of Measures, Attributes returned to PMV *****
        FII_MEASURE1 - Paid Amount,(Payments)
        FII_MEASURE2 - Prior Paid amount,(Payments)
        FII_MEASURE3 - Change(Payments)
        FII_MEASURE4 - Number of Invoices,(Payments)
        FII_MEASURE28 - Gross Invoice Amount
        FII_MEASURE5 - Total Invoice Amount,
        FII_MEASURE6 - Percent (Discount Offered)
        FII_MEASURE8 - Discount Offered Amount,
        FII_MEASURE9 - Prior Discount Offered,
        FII_MEASURE10 - change (Discount Offered)
        FII_MEASURE11 - Paid Discount Taken,
        FII_MEASURE12 - Prior Paid Discount Taken,
        FII_MEASURE7 - Percent (Discount Taken)
        FII_MEASURE13 - Change (Discount Taken)
        FII_MEASURE14 - Discount Lost Amount,
        FII_MEASURE15 - Prior Discount Lost
        FII_MEASURE16 - Change (Discount Lost)
        FII_MEASURE20 - Grand Total Amount (Payment)
        FII_MEASURE21 - Grand Total Change (Payment)
        FII_MEASURE22 - Grand Total Change (Discount Offered)
        FII_MEASURE23 - Grand Total Change (Discount Taken)
        FII_MEASURE24 - Grand Total Amount (Discount Lost)
        FII_MEASURE25 - Grand Total Change (Discount Lost)
        FII_MEASURE26 - Grand Total Amount (Discount Taken)
        FII_ATTRIBUTE2 - Grand Total Number of Invoices (Payments)
        FII_ATTRIBUTE3 - Grand Total Gross Invoice Amount (Payments)
        FII_ATTRIBUTE4 - Grand Total Percent (Discount taken)
        FII_ATTRIBUTE5 - Grand Total Percent (Discount Offered)
        FII_ATTRIBUTE6 - Grand Total Amount (Discount Offered)
        FII_MEASURE31 - Graph Legends for Discounts Taken
        FII_MEASURE30 - Graph Legends for Discounts Offered
        FII_PAYMENTS_COLSPAN - Colspan Payments
        FII_EMPTY_COLSPAN - Colspan on top of Gross Invoice Amount
        FII_DISCOUNT_OFFERED - Colspan
        FII_DISCOUNT_TAKEN - Colspan
        FII_DISCOUNT_LOST - Colspan
        FII_ATTRIBUTE10 - Drill on Number of Invoices
        FII_ATTRIBUTE13 - Grand Total Prior Percent (Discount taken)
        FII_ATTRIBUTE14 - Grand Total Prior Percent (Discount Offered)
       ***********************************************************************/

       /***************************Custom Drills******************************/
l_url_1 := 'pFunctionName=FII_AP_PAID_INV_DETAIL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_REPORT_SOURCE=FII_AP_PAID_INV_DETAIL&FII_CHECK_ID=All&FII_CHECK=All'
;
l_url_4  := 'pFunctionName=FII_AP_PAID_INV_DISCOUNT&VIEW_BY=SUPPLIER+POA_SUPPLIERS&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'
;

       /* Main SQL section */
       sqlstmt := '
       select viewby_dim.value VIEWBY,
              viewby_dim.id VIEWBYID,
              sum(f.FII_MEASURE1) FII_MEASURE1,
              sum(f.FII_MEASURE2) FII_MEASURE2,
              sum(f.FII_MEASURE4) FII_MEASURE4,
              sum(f.FII_MEASURE28) FII_MEASURE28,
              sum(f.FII_MEASURE5) FII_MEASURE5,
              sum(f.FII_MEASURE8) FII_MEASURE8,
              sum(f.FII_MEASURE9) FII_MEASURE9,
              sum(f.FII_MEASURE11) FII_MEASURE11,
              sum(f.FII_MEASURE12) FII_MEASURE12,
              sum(f.FII_MEASURE14) FII_MEASURE14,
              sum(f.FII_MEASURE15) FII_MEASURE15,
              sum(f.FII_MEASURE20) FII_MEASURE20,
              sum(f.FII_MEASURE21) FII_MEASURE21,
              sum(f.FII_MEASURE22) FII_MEASURE22,
              sum(f.FII_MEASURE23) FII_MEASURE23,
              sum(f.FII_MEASURE24) FII_MEASURE24,
              sum(f.FII_MEASURE25) FII_MEASURE25,
              sum(f.FII_MEASURE26) FII_MEASURE26,
              sum(f.FII_ATTRIBUTE2) FII_ATTRIBUTE2,
              sum(f.FII_ATTRIBUTE3) FII_ATTRIBUTE3,
              sum(f.FII_ATTRIBUTE4) FII_ATTRIBUTE4,
              sum(f.FII_ATTRIBUTE5) FII_ATTRIBUTE5,
              sum(f.FII_ATTRIBUTE6) FII_ATTRIBUTE6,
              decode('''||l_view_by||''',''ORGANIZATION+FII_OPERATING_UNITS'','''||l_url_4||''',
                               ''SUPPLIER+POA_SUPPLIERS'','''||l_url_1||''', null) FII_ATTRIBUTE10,
              sum(f.FII_CV1) FII_CV1,
              sum(f.FII_CV2) FII_CV2,
              sum(f.FII_ATTRIBUTE7) FII_ATTRIBUTE7,
              sum(f.FII_ATTRIBUTE8) FII_ATTRIBUTE8,
              sum(f.FII_ATTRIBUTE13) FII_ATTRIBUTE13,
              sum(f.FII_ATTRIBUTE14) FII_ATTRIBUTE14
       from
       (select ID,
               FII_MEASURE1,
               FII_MEASURE2,
               FII_MEASURE4,
               FII_MEASURE28,
               FII_MEASURE5,
               FII_MEASURE8,
               FII_MEASURE9,
               FII_MEASURE11,
               FII_MEASURE12,
               FII_MEASURE14,
               FII_MEASURE15,
               FII_MEASURE20,
               FII_MEASURE21,
               FII_MEASURE22,
               FII_MEASURE23,
               FII_MEASURE24,
               FII_MEASURE25,
               FII_MEASURE26,
               FII_ATTRIBUTE2,
               FII_ATTRIBUTE3,
               FII_ATTRIBUTE4,
               FII_ATTRIBUTE5,
               FII_ATTRIBUTE6,
               FII_CV1,
               FII_CV2,
               FII_ATTRIBUTE7,
               FII_ATTRIBUTE8,
               FII_ATTRIBUTE13,
               FII_ATTRIBUTE14,
               ( rank() over (&ORDER_BY_CLAUSE nulls last, ID)) - 1 rnk
        from
                (select f.'||l_column_name||' ID,
                        sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE then f.paid_amt'||l_currency||'  else 0 end) FII_MEASURE1,
                        sum(case when cal.report_date = &BIS_PREVIOUS_ASOF_DATE then f.paid_amt'||l_currency||' else 0 end) FII_MEASURE2,
                        sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE then f.paid_inv_count'||l_per_type||' else 0 end) FII_MEASURE4,
                        sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE then
                          (f.paid_amt'||l_currency||' +  f.paid_dis_taken'||l_currency||')  else 0 end) FII_MEASURE28,
                        sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE then f.paid_invoice_amt'||l_per_type||l_currency||' else 0 end) FII_MEASURE5,
                        sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE then f.paid_dis_offered'||l_per_type||l_currency|| ' else 0 end)  FII_MEASURE8,
                        sum(case when cal.report_date = &BIS_PREVIOUS_ASOF_DATE then f.paid_dis_offered'||l_per_type||l_currency|| ' else 0 end)  FII_MEASURE9,
                        sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE then f.paid_dis_taken'||l_currency||'  else 0 end)  FII_MEASURE11,
                        sum(case when cal.report_date = &BIS_PREVIOUS_ASOF_DATE then f.paid_dis_taken'||l_currency||' else 0 end)  FII_MEASURE12,
                        sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE then f.paid_dis_lost'||l_per_type||l_currency||'     else 0 end) FII_MEASURE14,
                        sum(case when cal.report_date = &BIS_PREVIOUS_ASOF_DATE then f.paid_dis_lost'||l_per_type||l_currency||' else 0 end) FII_MEASURE15,
                        sum(sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE then f.paid_amt'||l_currency||'  else 0 end)) over()
                        FII_MEASURE20,
                        decode(nvl(sum(case when cal.report_date = &BIS_PREVIOUS_ASOF_DATE then f.paid_amt'||l_currency||' else 0 end),0), 0, 0,
                        (sum(sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE then f.paid_amt'||l_currency||'  else 0 end)) over()
                        - sum(sum(case when cal.report_date = &BIS_PREVIOUS_ASOF_DATE then f.paid_amt'||l_currency||' else 0 end)) over())
                        *100/sum(sum(case when cal.report_date = &BIS_PREVIOUS_ASOF_DATE then f.paid_amt'||l_currency||' else 0 end)) over())
                        FII_MEASURE21,
                        decode(nvl(sum(case when cal.report_date = &BIS_PREVIOUS_ASOF_DATE then f.paid_dis_offered'||l_per_type||l_currency|| ' else 0 end),0), 0, 0,
                        (sum(sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE then f.paid_dis_offered'||l_per_type||l_currency|| ' else 0 end)) over()
                         - sum(sum(case when cal.report_date = &BIS_PREVIOUS_ASOF_DATE then f.paid_dis_offered'||l_per_type||l_currency|| ' else 0 end)) over())
                        *100/sum(sum(case when cal.report_date = &BIS_PREVIOUS_ASOF_DATE then f.paid_dis_offered'||l_per_type||l_currency|| ' else 0 end)) over())
                        FII_MEASURE22,
                        decode(nvl(sum(case when cal.report_date = &BIS_PREVIOUS_ASOF_DATE then f.paid_dis_taken'||l_currency||' else 0 end),0), 0, 0,
                        (sum(sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE then f.paid_dis_taken'||l_currency||'  else 0 end)) over()
                        - sum(sum(case when cal.report_date = &BIS_PREVIOUS_ASOF_DATE then f.paid_dis_taken'||l_currency||' else 0 end)) over())
                        *100/sum(sum(case when cal.report_date = &BIS_PREVIOUS_ASOF_DATE then f.paid_dis_taken'||l_currency||' else 0 end)) over())
                        FII_MEASURE23,
                        sum(sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE then f.paid_dis_lost'||l_per_type||l_currency||'     else 0 end)) over()
                        FII_MEASURE24,
                        decode(nvl(sum(case when cal.report_date = &BIS_PREVIOUS_ASOF_DATE then f.paid_dis_lost'||l_per_type||l_currency||' else 0 end),0), 0, 0,
                        (sum(sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE then f.paid_dis_lost'||l_per_type||l_currency||'     else 0 end)) over()
                        - sum(sum(case when cal.report_date = &BIS_PREVIOUS_ASOF_DATE then f.paid_dis_lost'||l_per_type||l_currency||' else 0 end)) over())
                        *100/sum(sum(case when cal.report_date = &BIS_PREVIOUS_ASOF_DATE then f.paid_dis_lost'||l_per_type||l_currency||' else 0 end)) over())
                        FII_MEASURE25,
                        sum(sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE then f.paid_dis_taken'||l_currency||'  else 0 end)) over()
                        FII_MEASURE26,
                        sum(sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE then f.paid_inv_count'||l_per_type||' else 0 end)) over()
                        FII_ATTRIBUTE2,
                        sum(sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE then f.paid_amt'||l_currency||'  else 0 end)) over()
                        + sum(sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE then f.paid_dis_taken'||l_currency||'  else 0 end)) over()
                        FII_ATTRIBUTE3,
                        case when(sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE then f.paid_amt'||l_currency||'  else 0 end)) = 0 then 0
                             when(sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE then f.paid_dis_taken'||l_currency||'  else 0 end)) = 0 then 0
                             else
                             sum(sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE then f.paid_dis_taken'||l_currency||'  else 0 end)) over()
                             *100/(sum(sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE then f.paid_amt'||l_currency||'  else 0 end)) over()
                             + sum(sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE then f.paid_dis_taken'||l_currency||'  else 0 end)) over())
                        end
                        FII_ATTRIBUTE4,
                        decode(nvl(sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE then f.paid_invoice_amt'||l_per_type||l_currency||' else 0 end),0), 0, 0,
                         sum(sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE then f.paid_dis_offered'||l_per_type||l_currency|| ' else 0 end)) over()
                         * 100/sum(sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE then f.paid_invoice_amt'||l_per_type||l_currency||' else 0 end)) over())
                        FII_ATTRIBUTE5,
                        sum(sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE then f.paid_dis_offered'||l_per_type||l_currency|| ' else 0 end)) over()
                        FII_ATTRIBUTE6,
                        sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE then f.paid_dis_taken'||l_currency||'  else 0 end)  FII_CV1,
                        sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE then
                          (f.paid_amt'||l_currency||' +  f.paid_dis_taken'||l_currency||')  else 0 end) FII_CV2,
                        sum(sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE then f.paid_amt'||l_currency||'  else 0 end)) over()
                        + sum(sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE then f.paid_dis_taken'||l_currency||'  else 0 end)) over()
                        FII_ATTRIBUTE7,
                        sum(sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE then f.paid_dis_taken'||l_currency||'  else 0 end)) over()
                        FII_ATTRIBUTE8,
                        case when(sum(case when cal.report_date = &BIS_PREVIOUS_ASOF_DATE
                                            then f.paid_amt'||l_currency||'  else 0 end)) = 0
                             then 0
			     when(sum(case when cal.report_date = &BIS_PREVIOUS_ASOF_DATE
                                           then f.paid_dis_taken'||l_currency||'  else 0 end)) = 0
			     then 0
			     else
				sum(sum(case when cal.report_date = &BIS_PREVIOUS_ASOF_DATE
					     then f.paid_dis_taken'||l_currency||'  else 0 end)) over()
					*100/(sum(sum(case when cal.report_date = &BIS_PREVIOUS_ASOF_DATE
							    then f.paid_amt'||l_currency||'  else 0 end)) over()
					+ sum(sum(case when cal.report_date = &BIS_PREVIOUS_ASOF_DATE
					       then f.paid_dis_taken'||l_currency||'  else 0 end)) over())	end           				               FII_ATTRIBUTE13,
                        decode(nvl(sum(case when cal.report_date = &BIS_PREVIOUS_ASOF_DATE then f.paid_invoice_amt'||l_per_type||l_currency||' else 0 end),0), 0, 0,
sum(sum(case when cal.report_date = &BIS_PREVIOUS_ASOF_DATE then f.paid_dis_offered'||l_per_type||l_currency|| ' else 0 end)) over()
* 100/sum(sum(case when cal.report_date = &BIS_PREVIOUS_ASOF_DATE then f.paid_invoice_amt'||l_per_type||l_currency||' else 0 end)) over())      FII_ATTRIBUTE14
                   from FII_AP_PAID_XB_MV f,
                        fii_time_structures cal
                   where f.time_id = cal.time_id
                   and   f.period_type_id = cal.period_type_id
                   and   bitand(cal.record_type_id, :RECORD_TYPE_ID) = :RECORD_TYPE_ID
                   and   cal.report_date in (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE)'
                   ||l_org_where||l_supplier_where||'
                   and   f.gid = :GID
                   group by f.'||l_column_name||')) f, '||l_table_name||' viewby_dim
                   where   f.id = viewby_dim.id
                   and (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
                   group by viewby_dim.value, viewby_dim.id
                   &ORDER_BY_CLAUSE';

      /* Binding Section */
       FII_PMV_Util.bind_variable(
       p_sqlstmt=>sqlstmt,
       p_page_parameter_tbl=>p_page_parameter_tbl,
       p_sql_output=>paid_invoice_sql,
       p_bind_output_table=>paid_invoice_output,
       p_record_type_id=>l_record_type_id,
       p_gid=>l_gid
       );

 END;
END FII_AP_PAID_INV_ACTIVITY;

/
