--------------------------------------------------------
--  DDL for Package Body FII_AP_PAID_INV_DETAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AP_PAID_INV_DETAIL" AS
/* $Header: FIIAPD2B.pls 120.8 2006/02/28 17:49:01 vkazhipu ship $ */

 PROCEDURE Get_Pay_Activity_History
      ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
       pay_act_sql out NOCOPY VARCHAR2,
       pay_act_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)IS
       /* declaration section */
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

       l_check_id       NUMBER := 0;

       stmt1            VARCHAR2(240);
       stmt2            VARCHAR2(240);
       stmt3            VARCHAR2(240);
       stmt4            VARCHAR2(240);
       stmt5            VARCHAR2(240);
       stmt6            VARCHAR2(240);
       stmt7            VARCHAR2(240);
       stmt8            VARCHAR2(240);

       l_date_mask      VARCHAR2(240);
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

       FII_PMV_Util.get_check_id(p_page_parameter_tbl, l_check_id);

       /**************Description of Measures, Attributes returned to PMV *****
        FII_MEASURE1 - Action,
        FII_MEASURE2 - Date,
        FII_MEASURE3 - User
        **********************************************************************/


       /****************Messages to be displayed in the report**************/
       stmt1 :=  FND_MESSAGE.get_string('FII', 'FII_AP_CREATED');
       stmt2 :=  FND_MESSAGE.get_string('FII', 'FII_AP_STOPPED');
       stmt3 :=  FND_MESSAGE.get_string('FII', 'FII_AP_STOP_RELEASED');
       stmt4 :=  FND_MESSAGE.get_string('FII', 'FII_AP_CLEARED');
       stmt5 :=  FND_MESSAGE.get_string('FII', 'FII_AP_RECONCILED');
       stmt6 :=  FND_MESSAGE.get_string('FII', 'FII_AP_UNRECONCILED');
       stmt7 :=  FND_MESSAGE.get_string('FII', 'FII_AP_UNCLEARED');
       stmt8 :=  FND_MESSAGE.get_string('FII', 'FII_AP_VOIDED');

       /*get date mask */
       FII_PMV_Util.get_format_mask(l_date_mask);


       /* Main SQL section */

          sqlstmt := 'select action FII_MEASURE1,
                             to_char(action_date, '''||l_date_mask||''') FII_MEASURE2,
                             usr.user_name FII_MEASURE3
                      from
                      (select :CREATED action,
                              creation_date action_date,
                              created_by by_whom
                       from ap_checks_all
                       where check_id=:CHECK_ID
                       and creation_date is not null
                       union all
                       select :STOPPED action,
                               stopped_date action_date,
                               stopped_by by_whom
                       from ap_checks_all
                       where check_id=:CHECK_ID
                       and stopped_date is not null
                       union all
                       select :STOP_RELEASED action,
                              released_date action_date,
                              released_by by_whom
                       from ap_checks_all
                       where check_id=:CHECK_ID
                       and released_date is not null
                       union all
                       select :CLEARED action,
                              creation_date action_date,
                              created_by by_whom
                       from ap_payment_history_all
                       where check_id=:CHECK_ID
                       and transaction_type=''PAYMENT CLEARING''
                       and matched_flag=''N''
                       and creation_date is not null
                       union all
                       select :RECONCILED action,
                              creation_date action_date,
                              created_by by_whom
                       from ap_payment_history_all
                       where check_id=:CHECK_ID
                       and transaction_type=''PAYMENT CLEARING''
                       and matched_flag=''Y''
                       and creation_date is not null
                       union all
                       select :UNRECONCILED action,
                               creation_date action_date,
                               created_by by_whom
                       from ap_payment_history_all
                       where check_id=:CHECK_ID
                       and transaction_type=''PAYMENT UNCLEARING''
                       and matched_flag=''Y''
                       and creation_date is not null
                       union all
                       select :UNCLEARED action,
                               creation_date action_date,
                               created_by by_whom
                       from ap_payment_history_all
                       where check_id=:CHECK_ID
                       and transaction_type=''PAYMENT UNCLEARING''
                       and matched_flag=''N''
                       and creation_date is not null
                       union all
                       select :VOIDED action,
                               apc.void_date action_date,
                               pay.last_updated_by by_whom
                       from ap_checks_all apc, ap_invoice_payments_all pay
                       where apc.check_id=:CHECK_ID
                       and apc.check_id=pay.check_id
                       and void_date is not null
                       ) a,
                       fnd_user_view usr
                       Where a.by_whom = usr.user_id
                       &ORDER_BY_CLAUSE';

        /* Binding Section */
       FII_PMV_Util.bind_variable(
       p_sqlstmt=>sqlstmt,
       p_page_parameter_tbl=>p_page_parameter_tbl,
       p_sql_output=>pay_act_sql,
       p_bind_output_table=>pay_act_output,
       p_check_id=>l_check_id,

       p_created=>stmt1,
       p_stopped=>stmt2,
       p_stop_released=>stmt3,
       p_cleared=>stmt4,
       p_reconciled=>stmt5,
       p_unreconciled=>stmt6,
       p_uncleared=>stmt7,
       p_voided=>stmt8
       );
 END;

  PROCEDURE Get_Paid_Inv_Detail
     ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
       paid_inv_sql out NOCOPY VARCHAR2,
       paid_inv_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)IS
       /* declaration section */
       sqlstmt          VARCHAR2(14000);
       sqlstmt1		    VARCHAR2(14000);

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

       l_discount_offered VARCHAR2(240);
       l_late_payment_amt VARCHAR2(240);
       l_on_time_payment_amt VARCHAR2(240);
       l_discount_taken   VARCHAR2(240);
       l_discount_lost    VARCHAR2(240);
       l_payment_amount   VARCHAR2(240);
       l_invoice_amount   VARCHAR2(240);
       l_report_source    VARCHAR2(240);
       l_check_id         NUMBER := 0;

       l_url_1            VARCHAR2(1000);
       l_url_2            VARCHAR2(1000);
       l_url_3            VARCHAR2(1000);
       l_url_4            VARCHAR2(1000);

       l_yes              VARCHAR2(240);
       l_no               VARCHAR2(240);

       l_date_mask        VARCHAR2(240);

       l_period_start     DATE;
       l_days_into_period NUMBER;
       l_cur_period       NUMBER;
       l_id_column        VARCHAR2(240);
       l_sysdate         VARCHAR2(30);

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

       FII_PMV_Util.Get_Report_Source(p_page_parameter_tbl, l_report_source);

       l_discount_offered := FII_PMV_Util.get_base_curr_colname(l_currency, 'discount_offered');

       l_late_payment_amt := FII_PMV_Util.get_base_curr_colname(l_currency, 'late_payment_amt');

       l_payment_amount := FII_PMV_Util.get_base_curr_colname(l_currency, 'payment_amount');

       l_on_time_payment_amt := FII_PMV_Util.get_base_curr_colname(l_currency, 'on_time_payment_amt');

       l_discount_taken := FII_PMV_Util.get_base_curr_colname(l_currency, 'discount_taken');

       l_discount_lost := FII_PMV_Util.get_base_curr_colname(l_currency, 'discount_lost');

       If l_currency = '_prim_g' then
          l_invoice_amount := 'prim_amount';
       Elsif l_currency = '_sec_g' then
          l_invoice_amount := 'sec_amount';
       Elsif l_currency = '_b' then
          l_invoice_amount := 'base_amount';
       End if;

       FII_PMV_Util.get_check_id(p_page_parameter_tbl, l_check_id);

       FII_PMV_Util.Get_Period_Strt(
                           p_page_parameter_tbl,
                           l_period_start,
                           l_days_into_period,
                           l_cur_period,
                           l_id_column);

       /**************Description of Measures, Attributes returned to PMV *****
        FII_MEASURE1 - Invoice Number,
        FII_MEASURE2 - Invoice Id,
        FII_MEASURE3 - Invoice Type,
        FII_MEASURE4 - Invoice Date,
        FII_MEASURE5 - Entered Date,
        FII_MEASURE6 - Due Date,
        FII_MEASURE7 - Transaction Currency Code,
       FII_MEASURE8 - Transaction Invoice Amount,
       FII_MEASURE9 - Invoice Amoun,
       FII_MEASURE10 - Paid Amount,
       FII_MEASURE11 - Paid on Time Amount,
       FII_MEASURE12 - Paid Late Amount,
       FII_MEASURE13 - Ever on Hold,
       FII_MEASURE14 - Discount Offered,
       FII_MEASURE15 - Discount Taken,
       FII_MEASURE16 - Discount Lost,
       FII_MEASURE17 - Terms,
       FII_MEASURE18 - Source
       FII_MEASURE20 - Grand Total Invoice Amount
       FII_MEASURE21 - Grand Total Discount Lost
       FII_ATTRIBUTE2 - Grand Total Paid Amount
       FII_ATTRIBUTE3 - Grand Total Paid on Time Amount
       FII_ATTRIBUTE4 - Grand Total Paid Late Amount
       FII_ATTRIBUTE5 - Grand Total Discount Offered
       FII_ATTRIBUTE6 - Grand Total Discount Taken
       ***********************************************************************/

--Added for Bug 4309974
  SELECT TO_CHAR(TRUNC(sysdate),'DD/MM/YYYY') INTO l_sysdate FROM dual;

       /***************Custom drill URLs************************************/
       l_url_1 := 'AS_OF_DATE='||l_sysdate||'&pFunctionName=FII_AP_INV_ACTIVITY_HISTORY&pParamIds=Y&FII_INVOICE_ID=FII_MEASURE2&FII_INVOICE=FII_MEASURE1'
       ;
       l_url_2 := 'AS_OF_DATE='||l_sysdate||'&pFunctionName=FII_AP_SCHED_PAY_DISCOUNT&pParamIds=Y&FII_AP_INVOICE_ID=FII_MEASURE2&FII_INVOICE=FII_MEASURE1'
       ;
       l_url_3 := 'AS_OF_DATE='||l_sysdate||'&pFunctionName=FII_AP_HOLD_HISTORY&pParamIds=Y&FII_AP_INVOICE_ID=FII_MEASURE2&FII_INVOICE=FII_MEASURE1'
       ;
-- l_url_4 := 'AS_OF_DATE='||l_sysdate||'&pFunctionName=FII_AP_INV_DIST_DETAIL&pParamIds=Y&FII_INVOICE_ID=FII_MEASURE2&FII_INVOICE=FII_MEASURE1'
  l_url_4 := 'AS_OF_DATE='||l_sysdate||'&pFunctionName=FII_AP_INV_LINES_DETAIL&pParamIds=Y&FII_AP_INVOICE_ID=FII_MEASURE2&FII_INVOICE_NUM=FII_MEASURE1'
       ;

       /* get mls message for yes no */
       FII_PMV_Util.get_yes_no_msg(l_yes, l_no);

       /*get date mask */
       FII_PMV_Util.get_format_mask(l_date_mask);

      /* Performance Tuning
         1.removed period type id = 1
         2.Implemented start/end index.
         3.driving table is fii_ap_pay_sched_b.
         4.column aliases for the columns selected by sub-query match the AK MEASURE name
         5.moved urls to top level.  moved grand totals to second level.
         3.AK FII_AP_PAID_INV_DETAIL # of rows displayed = -30, # of rows displayed in portlet = -10.
      */


       /* Main SQL section */
       IF l_report_source = 'FII_AP_PAID_INV_DETAIL' then
          sqlstmt := '
                     Select  h.FII_MEASURE1 FII_MEASURE1,
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
                             h.FII_ATTRIBUTE2 FII_ATTRIBUTE2,
                             h.FII_ATTRIBUTE3 FII_ATTRIBUTE3,
                             h.FII_ATTRIBUTE4 FII_ATTRIBUTE4,
                             h.FII_ATTRIBUTE5 FII_ATTRIBUTE5,
                             h.FII_ATTRIBUTE6 FII_ATTRIBUTE6,
                             '''||l_url_1||''' FII_ATTRIBUTE10,
                             '''||l_url_2||''' FII_ATTRIBUTE11,
                             '''||l_url_3||''' FII_ATTRIBUTE12,
                             '''||l_url_4||''' FII_ATTRIBUTE13
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
                             sum(g.FII_MEASURE9) over() FII_MEASURE21,
                             sum(g.FII_MEASURE16) over() FII_MEASURE22,
                             sum(g.FII_MEASURE10) over() FII_ATTRIBUTE2,
                             sum(g.FII_MEASURE11) over() FII_ATTRIBUTE3,
                             sum(g.FII_MEASURE12) over() FII_ATTRIBUTE4,
                             sum(g.FII_MEASURE14) over() FII_ATTRIBUTE5,
                             sum(g.FII_MEASURE15) over() FII_ATTRIBUTE6,
                            ( rank() over (&ORDER_BY_CLAUSE nulls last, g.FII_MEASURE2)) - 1 rnk
                    from
                    (
                      select
                           f.invoice_number FII_MEASURE1,
                           f.invoice_id FII_MEASURE2,
                           f.invoice_type FII_MEASURE3,
                           to_char(f.invoice_date,'''||l_date_mask||''') FII_MEASURE4,
                           to_char(f.entered_date,'''||l_date_mask||''') FII_MEASURE5,
                           to_char(min(f.due_date), '''||l_date_mask||''') FII_MEASURE6,
                           f.invoice_currency_code FII_MEASURE7,
                           sum(f.base_amount) FII_MEASURE8,
                           sum(f.invoice_amount) FII_MEASURE9,
                           sum(f.payment_amount) FII_MEASURE10,
                           sum(f.on_time_payment_amount) FII_MEASURE11,
                           sum(f.late_payment_amount) FII_MEASURE12,
                           decode(nvl(hold.FII_MEASURE13, ''N''), ''Y'', '''||l_yes||''', ''N'', '''||l_no||''') FII_MEASURE13,
                           sum(f.discount_offered)  FII_MEASURE14,
                           sum(f.discount_taken) FII_MEASURE15,
                           sum(f.discount_lost) FII_MEASURE16,
                           term.name FII_MEASURE17,
                           f.source FII_MEASURE18
                    from
                    (
                        select base.invoice_number invoice_number,
                               base.invoice_id     invoice_id,
                               base.invoice_type   invoice_type,
                               base.invoice_date   invoice_date,
                               base.entered_date   entered_date,
                               min(f.due_date) due_date,
                               base.invoice_currency_code invoice_currency_code,
                               base.invoice_amount base_amount,
                               base.'||l_invoice_amount||' invoice_amount,
                               sum(f.'||l_payment_amount||') payment_amount,
                               sum(f.'||l_on_time_payment_amt||') on_time_payment_amount,
                               sum(f.'||l_late_payment_amt||') late_payment_amount,
                               base.'||l_discount_offered||'  discount_offered,
                               sum(f.'||l_discount_taken||') discount_taken,
                               sum(f.'||l_discount_lost||') discount_lost,
                               base.source source,
                               base.terms_id,
                               base.org_id,
                               base.supplier_id
                       from fii_ap_invoice_b base,
                            fii_ap_pay_sched_b f
                       where f.action_date >= :PERIOD_START
                       and   f.action_date <= &BIS_CURRENT_ASOF_DATE
                       and f.action  = ''PAYMENT''
                       and base.invoice_id = f.invoice_id
                       and base.cancel_flag = ''N'' '
                       ||l_org_where||l_supplier_where|| '
                       group by base.invoice_number,
                                base.invoice_id,
                                base.invoice_type,
                                base.invoice_date,
                                base.entered_date,
                                base.invoice_currency_code,
                                base.invoice_amount,
                                base.'||l_invoice_amount||',
                                base.'||l_discount_offered||',
                                base.source,
                                base.terms_id,
                                base.org_id,
                                base.supplier_id
                       union
                       select base.invoice_number invoice_number,
                              base.invoice_id     invoice_id,
                              base.invoice_type   invoice_type,
                              base.invoice_date   invoice_date,
                              base.entered_date   entered_date,
                              min(base.due_date)       due_date,
                              base.invoice_currency_code invoice_currency_code,
                              0 base_amount,
                              0 invoice_amount,
                              0 payment_amount,
                              0 on_time_payment_amount,
                              0 late_payment_amount,
                              0 discount_offered,
                              0 discount_taken,
                              sum(f.'||l_discount_lost||') discount_lost,
                              base.source source,
                              base.terms_id terms_id,
                              base.org_id org_id,
                              base.supplier_id supplier_id
                       from fii_ap_invoice_b base,
                            fii_ap_pay_sched_b f
                       where f.action_date >= :PERIOD_START
                       and f.action_date <= &BIS_CURRENT_ASOF_DATE
                       and f.action  = ''DISCOUNT''
                       and base.invoice_id = f.invoice_id
                       and base.cancel_flag = ''N'' '
                       ||l_org_where||l_supplier_where|| '
                       and  f.invoice_id in  (select distinct f.invoice_id
                                             from fii_ap_pay_sched_b f
                                             where f.action_date >= :PERIOD_START
                                             and f.action_date <= &BIS_CURRENT_ASOF_DATE
                                             and   f.action = ''PAYMENT''
                                             '||l_org_where||l_supplier_where|| '
                                             )
                      group by base.invoice_number,
                               base.invoice_id,
                               base.invoice_type,
                               base.invoice_date,
                               base.entered_date,
                               base.invoice_currency_code,
                               base.source,
                               base.terms_id,
                               base.org_id,
                               base.supplier_id
           )
           f, (select distinct invoice_id,
                ''Y'' FII_MEASURE13
               from fii_ap_inv_holds_b f
               where 1 = 1
  	       '||l_org_where||l_supplier_where|| '
               group by invoice_id) hold,
               ap_terms_tl term, POA_SUPPLIERS_V viewby_dim
               where hold.invoice_id (+)= f.invoice_id
               and f.SUPPLIER_ID = viewby_dim.id
               and f.terms_id = term.term_id
               and term.language = userenv(''LANG'')
               group by f.invoice_number,
                        f.invoice_id,
                        f.invoice_type,
                        f.invoice_date,
                        f.entered_date,
                        f.invoice_currency_code,
                        hold.FII_MEASURE13,
                        term.name,
                        f.source
             ) g
             ) h
            where (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
             &ORDER_BY_CLAUSE';
       ELSIF  ( l_report_source = 'FII_AP_PAID_INV_DETAIL_PYMT') then
          sqlstmt := '
                      Select  h.FII_MEASURE1 FII_MEASURE1,
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
                             h.FII_ATTRIBUTE2 FII_ATTRIBUTE2,
                             h.FII_ATTRIBUTE3 FII_ATTRIBUTE3,
                             h.FII_ATTRIBUTE4 FII_ATTRIBUTE4,
                             h.FII_ATTRIBUTE5 FII_ATTRIBUTE5,
                             h.FII_ATTRIBUTE6 FII_ATTRIBUTE6,
                             '''||l_url_1||''' FII_ATTRIBUTE10,
                             '''||l_url_2||''' FII_ATTRIBUTE11,
                             '''||l_url_3||''' FII_ATTRIBUTE12,
                             '''||l_url_4||''' FII_ATTRIBUTE13
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
                             sum(g.FII_MEASURE9) over() FII_MEASURE21,
                             sum(g.FII_MEASURE16) over() FII_MEASURE22,
                             sum(g.FII_MEASURE10) over() FII_ATTRIBUTE2,
                             sum(g.FII_MEASURE11) over() FII_ATTRIBUTE3,
                             sum(g.FII_MEASURE12) over() FII_ATTRIBUTE4,
                             sum(g.FII_MEASURE14) over() FII_ATTRIBUTE5,
                             sum(g.FII_MEASURE15) over() FII_ATTRIBUTE6,
                            ( rank() over (&ORDER_BY_CLAUSE nulls last, g.FII_MEASURE2)) - 1 rnk

                    from
                    (
                      select
                           f.invoice_number FII_MEASURE1,
                           f.invoice_id FII_MEASURE2,
                           f.invoice_type FII_MEASURE3,
                           to_char(f.invoice_date,'''||l_date_mask||''') FII_MEASURE4,
                           to_char(f.entered_date,'''||l_date_mask||''') FII_MEASURE5,
                           to_char(min(f.due_date), '''||l_date_mask||''') FII_MEASURE6,
                           f.invoice_currency_code FII_MEASURE7,
                           sum(f.base_amount) FII_MEASURE8,
                           sum(f.invoice_amount) FII_MEASURE9,
                           sum(f.payment_amount) FII_MEASURE10,
                           sum(f.on_time_payment_amount) FII_MEASURE11,
                           sum(f.late_payment_amount) FII_MEASURE12,
                           decode(nvl(hold.FII_MEASURE13, ''N''), ''Y'', '''||l_yes||''', ''N'', '''||l_no||''') FII_MEASURE13,
                           sum(f.discount_offered)  FII_MEASURE14,
                           sum(f.discount_taken) FII_MEASURE15,
                           sum(f.discount_lost) FII_MEASURE16,
                           term.name FII_MEASURE17,
                           f.source FII_MEASURE18
                    from
                    (
                        select base.invoice_number invoice_number,
                               base.invoice_id     invoice_id,
                               base.invoice_type   invoice_type,
                               base.invoice_date   invoice_date,
                               base.entered_date   entered_date,
                               min(f.due_date) due_date,
                               base.invoice_currency_code invoice_currency_code,
                               base.invoice_amount base_amount,
                               base.'||l_invoice_amount||' invoice_amount,
                               sum(f.'||l_payment_amount||') payment_amount,
                               sum(f.'||l_on_time_payment_amt||') on_time_payment_amount,
                               sum(f.'||l_late_payment_amt||') late_payment_amount,
                               base.'||l_discount_offered||'  discount_offered,
                               sum(f.'||l_discount_taken||') discount_taken,
                               sum(f.'||l_discount_lost||') discount_lost,
                               base.source source,
                               base.terms_id,
                               base.org_id,
                               base.supplier_id
                       from fii_ap_invoice_b base,
                            fii_ap_pay_sched_b f
                       where f.action_date >= :PERIOD_START
                       and f.action_date <= &BIS_CURRENT_ASOF_DATE
                       and f.action = ''PAYMENT''
                       and f.check_id = :CHECK_ID
                       and base.invoice_id = f.invoice_id
                       and base.cancel_flag = ''N'' '
                       ||l_org_where||l_supplier_where|| '
                       group by base.invoice_number,
                                base.invoice_id,
                                base.invoice_type,
                                base.invoice_date,
                                base.entered_date,
                                base.invoice_currency_code,
                                base.invoice_amount,
                                base.'||l_invoice_amount||',
                                base.'||l_discount_offered||',
                                base.source,
                                base.terms_id,
                                base.org_id,
                                base.supplier_id
                       union
                       select base.invoice_number invoice_number,
                              base.invoice_id     invoice_id,
                              base.invoice_type   invoice_type,
                              base.invoice_date   invoice_date,
                              base.entered_date   entered_date,
                              min(base.due_date)       due_date,
                              base.invoice_currency_code invoice_currency_code,
                              0 base_amount,
                              0 invoice_amount,
                              0 payment_amount,
                              0 on_time_payment_amount,
                              0 late_payment_amount,
                              0 discount_offered,
                              0 discount_taken,
                              sum(f.'||l_discount_lost||') discount_lost,
                              base.source source,
                              base.terms_id terms_id,
                              base.org_id org_id,
                              base.supplier_id supplier_id
                       from fii_ap_invoice_b base,
                            fii_ap_pay_sched_b f
                       where f.action_date >= :PERIOD_START
                       and f.action_date <= &BIS_CURRENT_ASOF_DATE
                       and f.action = ''DISCOUNT'' '
                       ||l_org_where||l_supplier_where|| '
                       and base.invoice_id = f.invoice_id
                       and base.cancel_flag = ''N''
                       and f.invoice_id in  (select distinct f.invoice_id
                                             from fii_ap_pay_sched_b f
                                             where f.action_date >= :PERIOD_START
                                             and   f.action_date <= &BIS_CURRENT_ASOF_DATE
                                             and   f.action = ''PAYMENT''
                                             and   f.check_id = :CHECK_ID '
                                             ||l_org_where||l_supplier_where|| '
                                             )
                      group by base.invoice_number,
                               base.invoice_id,
                               base.invoice_type,
                               base.invoice_date,
                               base.entered_date,
                               base.invoice_currency_code,
                               base.source,
                               base.terms_id,
                               base.org_id,
                               base.supplier_id
           )
           f, (select distinct invoice_id,
                ''Y'' FII_MEASURE13
               from fii_ap_inv_holds_b f
               where 1 = 1
               '||l_org_where||l_supplier_where|| '
               group by invoice_id) hold,
               ap_terms_tl term, POA_SUPPLIERS_V viewby_dim
               where hold.invoice_id (+)= f.invoice_id
               and f.SUPPLIER_ID = viewby_dim.id '
               ||l_org_where||l_supplier_where|| '
               and   f.terms_id = term.term_id
               and   term.language = userenv(''LANG'')
               group by f.invoice_number,
                        f.invoice_id,
                        f.invoice_type,
                        f.invoice_date,
                        f.entered_date,
                        f.invoice_currency_code,
                        hold.FII_MEASURE13,
                        term.name,
                        f.source
             ) g
             ) h
            where (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
             &ORDER_BY_CLAUSE';
       ELSIF l_report_source = 'FII_AP_PAID_INV_DETAIL_PYLATE' then

          sqlstmt := '
                     Select  h.FII_MEASURE1 FII_MEASURE1,
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
                             h.FII_ATTRIBUTE2 FII_ATTRIBUTE2,
                             h.FII_ATTRIBUTE3 FII_ATTRIBUTE3,
                             h.FII_ATTRIBUTE4 FII_ATTRIBUTE4,
                             h.FII_ATTRIBUTE5 FII_ATTRIBUTE5,
                             h.FII_ATTRIBUTE6 FII_ATTRIBUTE6,
                             '''||l_url_1||''' FII_ATTRIBUTE10,
                             '''||l_url_2||''' FII_ATTRIBUTE11,
                             '''||l_url_3||''' FII_ATTRIBUTE12,
                             '''||l_url_4||''' FII_ATTRIBUTE13
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
                             sum(g.FII_MEASURE9) over() FII_MEASURE21,
                             sum(g.FII_MEASURE16) over() FII_MEASURE22,
                             sum(g.FII_MEASURE10) over() FII_ATTRIBUTE2,
                             sum(g.FII_MEASURE11) over() FII_ATTRIBUTE3,
                             sum(g.FII_MEASURE12) over() FII_ATTRIBUTE4,
                             sum(g.FII_MEASURE14) over() FII_ATTRIBUTE5,
                             sum(g.FII_MEASURE15) over() FII_ATTRIBUTE6,
                            ( rank() over (&ORDER_BY_CLAUSE nulls last, g.FII_MEASURE2)) - 1 rnk
                    from
                    (
                     select
                           f.invoice_number FII_MEASURE1,
                           f.invoice_id FII_MEASURE2,
                           f.invoice_type FII_MEASURE3,
                           to_char(f.invoice_date,'''||l_date_mask||''') FII_MEASURE4,
                           to_char(f.entered_date,'''||l_date_mask||''') FII_MEASURE5,
                           to_char(min(f.due_date), '''||l_date_mask||''') FII_MEASURE6,
                           f.invoice_currency_code FII_MEASURE7,
                           sum(f.base_amount) FII_MEASURE8,
                           sum(f.invoice_amount) FII_MEASURE9,
                           sum(f.payment_amount) FII_MEASURE10,
                           sum(f.on_time_payment_amount) FII_MEASURE11,
                           sum(f.late_payment_amount) FII_MEASURE12,
                           decode(nvl(hold.FII_MEASURE13, ''N''), ''Y'', '''||l_yes||''', ''N'', '''||l_no||''') FII_MEASURE13,
                           sum(f.discount_offered)  FII_MEASURE14,
                           sum(f.discount_taken) FII_MEASURE15,
                           sum(f.discount_lost) FII_MEASURE16,
                           term.name FII_MEASURE17,
                           f.source FII_MEASURE18
                    from
                    (
                        select base.invoice_number invoice_number,
                               base.invoice_id     invoice_id,
                               base.invoice_type   invoice_type,
                               base.invoice_date   invoice_date,
                               base.entered_date   entered_date,
                               min(f.due_date) due_date,
                               base.invoice_currency_code invoice_currency_code,
                               base.invoice_amount base_amount,
                               base.'||l_invoice_amount||' invoice_amount,
                               sum(f.'||l_payment_amount||') payment_amount,
                               sum(f.'||l_on_time_payment_amt||') on_time_payment_amount,
                               sum(f.'||l_late_payment_amt||') late_payment_amount,
                               base.'||l_discount_offered||'  discount_offered,
                               sum(f.'||l_discount_taken||') discount_taken,
                               sum(f.'||l_discount_lost||') discount_lost,
                               base.source source,
                               base.terms_id,
                               base.org_id,
                               base.supplier_id
                       from fii_ap_invoice_b base,
                            fii_ap_pay_sched_b f
                       where f.action_date >= :PERIOD_START
                       and f.action_date <= &BIS_CURRENT_ASOF_DATE
                       and f.action = ''PAYMENT''
                       and f.check_id = :CHECK_ID
                       and f.'||l_late_payment_amt||'<> 0
                       and base.invoice_id = f.invoice_id
                       and base.cancel_flag = ''N'' '
                       ||l_org_where||l_supplier_where|| '
                       group by base.invoice_number,
                                base.invoice_id,
                                base.invoice_type,
                                base.invoice_date,
                                base.entered_date,
                                base.invoice_currency_code,
                                base.invoice_amount,
                                base.'||l_invoice_amount||',
                                base.'||l_discount_offered||',
                                base.source,
                                base.terms_id,
                                base.org_id,
                                base.supplier_id
                       union
                       select base.invoice_number invoice_number,
                              base.invoice_id     invoice_id,
                              base.invoice_type   invoice_type,
                              base.invoice_date   invoice_date,
                              base.entered_date   entered_date,
                              min(base.due_date)       due_date,
                              base.invoice_currency_code invoice_currency_code,
                              0 base_amount,
                              0 invoice_amount,
                              0 payment_amount,
                              0 on_time_payment_amount,
                              0 late_payment_amount,
                              0 discount_offered,
                              0 discount_taken,
                              sum(f.'||l_discount_lost||') discount_lost,
                              base.source source,
                              base.terms_id terms_id,
                              base.org_id org_id,
                              base.supplier_id supplier_id
                       from fii_ap_invoice_b base,
                            fii_ap_pay_sched_b f
                       where f.action_date >= :PERIOD_START
                       and f.action_date <= &BIS_CURRENT_ASOF_DATE
                       and f.action = ''DISCOUNT'' '
                       ||l_org_where||l_supplier_where|| '
                       and base.invoice_id = f.invoice_id
                       and base.cancel_flag = ''N''
                       and f.invoice_id in  (select distinct f.invoice_id
                                             from fii_ap_pay_sched_b f
                                             where f.action_date >= :PERIOD_START
                                             and   f.action_date <= &BIS_CURRENT_ASOF_DATE
                                             and   f.action = ''PAYMENT''
                                             and   f.check_id = :CHECK_ID
                                             and   f.'||l_late_payment_amt||'<> 0 '
                                             ||l_org_where||l_supplier_where|| '
                                             )
                      group by base.invoice_number,
                               base.invoice_id,
                               base.invoice_type,
                               base.invoice_date,
                               base.entered_date,
                               base.invoice_currency_code,
                               base.source,
                               base.terms_id,
                               base.org_id,
                               base.supplier_id
           )
           f, (select distinct invoice_id,
                ''Y'' FII_MEASURE13
               from fii_ap_inv_holds_b f
               where 1 = 1
               '||l_org_where||l_supplier_where|| '
               group by invoice_id) hold,
               ap_terms_tl term, POA_SUPPLIERS_V viewby_dim
               where hold.invoice_id (+)= f.invoice_id
               and f.SUPPLIER_ID = viewby_dim.id '
               ||l_org_where||l_supplier_where||'
               and   f.terms_id = term.term_id
               and   term.language = userenv(''LANG'')
               group by f.invoice_number,
                        f.invoice_id,
                        f.invoice_type,
                        f.invoice_date,
                        f.entered_date,
                        f.invoice_currency_code,
                        hold.FII_MEASURE13,
                        term.name,
                        f.source
              ) g
              ) h
            where (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
              &ORDER_BY_CLAUSE';

       ELSIF l_report_source = 'FII_AP_PAID_INV_DETAIL_PYTIME' then

          sqlstmt := '
                     Select  h.FII_MEASURE1 FII_MEASURE1,
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
                             h.FII_ATTRIBUTE2 FII_ATTRIBUTE2,
                             h.FII_ATTRIBUTE3 FII_ATTRIBUTE3,
                             h.FII_ATTRIBUTE4 FII_ATTRIBUTE4,
                             h.FII_ATTRIBUTE5 FII_ATTRIBUTE5,
                             h.FII_ATTRIBUTE6 FII_ATTRIBUTE6,
                             '''||l_url_1||''' FII_ATTRIBUTE10,
                             '''||l_url_2||''' FII_ATTRIBUTE11,
                             '''||l_url_3||''' FII_ATTRIBUTE12,
                             '''||l_url_4||''' FII_ATTRIBUTE13
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
                             sum(g.FII_MEASURE9) over() FII_MEASURE21,
                             sum(g.FII_MEASURE16) over() FII_MEASURE22,
                             sum(g.FII_MEASURE10) over() FII_ATTRIBUTE2,
                             sum(g.FII_MEASURE11) over() FII_ATTRIBUTE3,
                             sum(g.FII_MEASURE12) over() FII_ATTRIBUTE4,
                             sum(g.FII_MEASURE14) over() FII_ATTRIBUTE5,
                             sum(g.FII_MEASURE15) over() FII_ATTRIBUTE6,
                            ( rank() over (&ORDER_BY_CLAUSE nulls last, g.FII_MEASURE2)) - 1 rnk
                    from
                    (
                     select
                           f.invoice_number FII_MEASURE1,
                           f.invoice_id FII_MEASURE2,
                           f.invoice_type FII_MEASURE3,
                           to_char(f.invoice_date,'''||l_date_mask||''') FII_MEASURE4,
                           to_char(f.entered_date,'''||l_date_mask||''') FII_MEASURE5,
                           to_char(min(f.due_date), '''||l_date_mask||''') FII_MEASURE6,
                           f.invoice_currency_code FII_MEASURE7,
                           sum(f.base_amount) FII_MEASURE8,
                           sum(f.invoice_amount) FII_MEASURE9,
                           sum(f.payment_amount) FII_MEASURE10,
                           sum(f.on_time_payment_amount) FII_MEASURE11,
                           sum(f.late_payment_amount) FII_MEASURE12,
                           decode(nvl(hold.FII_MEASURE13, ''N''), ''Y'', '''||l_yes||''', ''N'', '''||l_no||''') FII_MEASURE13,
                           sum(f.discount_offered)  FII_MEASURE14,
                           sum(f.discount_taken) FII_MEASURE15,
                           sum(f.discount_lost) FII_MEASURE16,
                           term.name FII_MEASURE17,
                           f.source FII_MEASURE18
                    from
                    (
                        select base.invoice_number invoice_number,
                               base.invoice_id     invoice_id,
                               base.invoice_type   invoice_type,
                               base.invoice_date   invoice_date,
                               base.entered_date   entered_date,
                               min(f.due_date) due_date,
                               base.invoice_currency_code invoice_currency_code,
                               base.invoice_amount base_amount,
                               base.'||l_invoice_amount||' invoice_amount,
                               sum(f.'||l_payment_amount||') payment_amount,
                               sum(f.'||l_on_time_payment_amt||') on_time_payment_amount,
                               sum(f.'||l_late_payment_amt||') late_payment_amount,
                               base.'||l_discount_offered||'  discount_offered,
                               sum(f.'||l_discount_taken||') discount_taken,
                               sum(f.'||l_discount_lost||') discount_lost,
                               base.source source,
                               base.terms_id,
                               base.org_id,
                               base.supplier_id
                       from fii_ap_invoice_b base,
                            fii_ap_pay_sched_b f
                       where f.action_date >= :PERIOD_START
                       and f.action_date <= &BIS_CURRENT_ASOF_DATE
                       and f.action = ''PAYMENT''
                       and f.check_id = :CHECK_ID
                       and f.no_days_late = 0
                       and base.invoice_id = f.invoice_id
                       and base.cancel_flag = ''N'' '
                      ||l_org_where||l_supplier_where||'
                       group by base.invoice_number,
                                base.invoice_id,
                                base.invoice_type,
                                base.invoice_date,
                                base.entered_date,
                                base.invoice_currency_code,
                                base.invoice_amount,
                                base.'||l_invoice_amount||',
                                base.'||l_discount_offered||',
                                base.source,
                                base.terms_id,
                                base.org_id,
                                base.supplier_id
                       union
                       select base.invoice_number invoice_number,
                              base.invoice_id     invoice_id,
                              base.invoice_type   invoice_type,
                              base.invoice_date   invoice_date,
                              base.entered_date   entered_date,
                              min(base.due_date)       due_date,
                              base.invoice_currency_code invoice_currency_code,
                              0 base_amount,
                              0 invoice_amount,
                              0 payment_amount,
                              0 on_time_payment_amount,
                              0 late_payment_amount,
                              0 discount_offered,
                              0 discount_taken,
                              sum(f.'||l_discount_lost||') discount_lost,
                              base.source source,
                              base.terms_id terms_id,
                              base.org_id org_id,
                              base.supplier_id supplier_id
                       from fii_ap_invoice_b base,
                            fii_ap_pay_sched_b f
                       where f.action_date >= :PERIOD_START
                       and f.action_date <= &BIS_CURRENT_ASOF_DATE
                       and f.action = ''DISCOUNT'' '
                       ||l_org_where||l_supplier_where|| '
                       and base.invoice_id = f.invoice_id
                       and base.cancel_flag = ''N''
                       and f.invoice_id in (select distinct f.invoice_id
                                             from fii_ap_pay_sched_b f
                                             where f.action_date >= :PERIOD_START
                                             and   f.action_date <= &BIS_CURRENT_ASOF_DATE
                                             and   f.action = ''PAYMENT''
                                             and   f.check_id = :CHECK_ID
                                             and   f.no_days_late = 0 '
                                             ||l_org_where||l_supplier_where||'
                                             )
                      group by base.invoice_number,
                               base.invoice_id,
                               base.invoice_type,
                               base.invoice_date,
                               base.entered_date,
                               base.invoice_currency_code,
                               base.source,
                               base.terms_id,
                               base.org_id,
                               base.supplier_id
           )
           f, (select distinct invoice_id,
                ''Y'' FII_MEASURE13
               from fii_ap_inv_holds_b f
               where 1 = 1
               '||l_org_where||l_supplier_where|| '
               group by invoice_id) hold,
               ap_terms_tl term, POA_SUPPLIERS_V viewby_dim
               where hold.invoice_id (+)= f.invoice_id
               and f.SUPPLIER_ID = viewby_dim.id '
               ||l_org_where||l_supplier_where||'
               and   f.terms_id = term.term_id
               and   term.language = userenv(''LANG'')
               group by f.invoice_number,
                        f.invoice_id,
                        f.invoice_type,
                        f.invoice_date,
                        f.entered_date,
                        f.invoice_currency_code,
                        hold.FII_MEASURE13,
                        term.name,
                        f.source
            ) g
            ) h
            where (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
            &ORDER_BY_CLAUSE';

       END IF;


      /* Binding Section */
       FII_PMV_Util.bind_variable(
       p_sqlstmt=>sqlstmt,
       p_page_parameter_tbl=>p_page_parameter_tbl,
       p_sql_output=>paid_inv_sql,
       p_bind_output_table=>paid_inv_output,
       p_record_type_id=>l_record_type_id,
       p_check_id=>l_check_id,
       p_period_start=>l_period_start
       );
 END;

PROCEDURE Get_Payment_Detail
     ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
       pay_detail_sql out NOCOPY VARCHAR2,
       pay_detail_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)IS
       /* declaration section */
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

       l_period_start     DATE;
       l_days_into_period NUMBER;
       l_cur_period       NUMBER;
       l_id_column        VARCHAR2(240);

       l_url_1            VARCHAR2(1000);
       l_url_2            VARCHAR2(1000);
       l_url_3            VARCHAR2(1000);
       l_url_4            VARCHAR2(1000);

       l_date_mask        VARCHAR2(240);
       l_curr             VARCHAR2(240);
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


       FII_PMV_Util.Get_Period_Strt(
                           p_page_parameter_tbl,
                           l_period_start,
                           l_days_into_period,
                           l_cur_period,
                           l_id_column);

       /**************Description of Measures, Attributes returned to PMV *****
        FII_MEASURE1 - Payment Number,
        FII_MEASURE2 - Check ID,
        FII_MEASURE3 - Payment Method,
        FII_MEASURE4 - Payment Amount,
        FII_MEASURE5 - Payment Date,
        FII_MEASURE6 - Status,
        FII_MEASURE7 - Bank Account Name,
        FII_MEASURE8 - Bank Account Number,
        FII_MEASURE9 - Remit to Bank,
        FII_MEASURE10 - Remit to Number,
        FII_MEASURE11 - Transaction Payment Amount,
        FII_MEASURE12 - Transaction Currency Code,
        FII_MEASURE13 - Total Paid Invoices,
        FII_MEASURE14 - Invoices Paid Late,
        FII_MEASURE15 - Invoices Paid on Time
        FII_MEASURE20 - Grand Total for Payment Amount
        FII_MEASURE21 - Grand Total for Total Paid Invoices
        FII_ATTRIBUTE2 - Grand Total for Invoices Paid Late
        FII_ATTRIBUTE3 - Grand Total for Invoices Paid on Time
       ***********************************************************************/


       l_url_1 := 'pFunctionName=FII_AP_PAID_INV_DETAIL_PYMT&pParamIds=Y&FII_CHECK_ID=FII_MEASURE2&FII_REPORT_SOURCE=FII_AP_PAID_INV_DETAIL_PYMT&FII_CHECK=FII_MEASURE1'
       ;
       l_url_2 := 'pFunctionName=FII_AP_PAID_INV_DETAIL_PYLATE&pParamIds=Y&FII_CHECK_ID=FII_MEASURE2&FII_REPORT_SOURCE=FII_AP_PAID_INV_DETAIL_PYLATE&FII_CHECK=FII_MEASURE1'
       ;
       l_url_3 := 'pFunctionName=FII_AP_PAID_INV_DETAIL_PYTIME&pParamIds=Y&FII_CHECK_ID=FII_MEASURE2&FII_REPORT_SOURCE=FII_AP_PAID_INV_DETAIL_PYTIME&FII_CHECK=FII_MEASURE1'
       ;
       l_url_4 := 'pFunctionName=FII_AP_PAY_ACTIVITY_HISTORY&pParamIds=Y&FII_CHECK_ID=FII_MEASURE2&FII_CHECK=FII_MEASURE1'
       ;

       /*get date mask */
       FII_PMV_Util.get_format_mask(l_date_mask);

       l_supplier_where := replace(l_supplier_where, 'supplier', 'vendor');

--Added for fix of bug 4327606
	l_column_name := replace(l_column_name, 'SUPPLIER', 'VENDOR');

       FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP
       If p_page_parameter_tbl(i).parameter_name = 'CURRENCY+FII_CURRENCIES' then
            l_curr := p_page_parameter_tbl(i).parameter_value;
            --l_curr := substr(l_curr, 1, 3);
       End if;
       End Loop;


       /* Main SQL section */
       sqlstmt := 'select f.check_number       FII_MEASURE1,
                          f.check_id           FII_MEASURE2,
                          code.payment_method_name FII_MEASURE3,
                          decode('''||l_currency||''', ''_prim_g'', nvl(f.base_amount, f.amount)*fii_currency.get_global_rate_primary(asp.base_currency_code,f.check_date),
                                                   ''_sec_g'',  nvl(f.base_amount, f.amount)*fii_currency.get_global_rate_secondary(asp.base_currency_code,f.check_date),
                                                   ''_b'',      nvl(f.base_amount, f.amount)*fii_currency.get_rate(asp.base_currency_code, '''||l_curr||''', f.check_date, bis_common_parameters.get_rate_type)
                                )
                          FII_MEASURE4,
                          f.check_date  				 FII_MEASURE5,
                          code1.displayed_field  FII_MEASURE6,
                          f.bank_account_name  	 FII_MEASURE7,
                          f.bank_account_num   	 FII_MEASURE8,
			  									bankacct.bank_name 		 FII_MEASURE9,
                          bankacct.bank_number   FII_MEASURE10,
                          f.currency_code        FII_MEASURE12,
                          f.amount               FII_MEASURE11,
                          count(distinct pay.invoice_id) FII_MEASURE13,
                          count(distinct case when pay.no_days_late <> 0 then i.invoice_id else null end)  FII_MEASURE14,
                          count(distinct case when pay.no_days_late =  0 then i.invoice_id else null end)  FII_MEASURE15,
                          sum(decode('''||l_currency||''', ''_prim_g'', nvl(f.base_amount, f.amount)*fii_currency.get_global_rate_primary(asp.base_currency_code,f.check_date),
                                                   ''_sec_g'',  nvl(f.base_amount, f.amount)*fii_currency.get_global_rate_secondary(asp.base_currency_code,f.check_date),
                                                   ''_b'',      nvl(f.base_amount, f.amount)*fii_currency.get_rate(asp.base_currency_code,'''||l_curr||''' , f.check_date, bis_common_parameters.get_rate_type)
                                )) over() FII_MEASURE20,
                          sum(count(distinct pay.invoice_id)) over() FII_MEASURE21,
                          sum(count(distinct case when pay.no_days_late <> 0 then i.invoice_id else null end)) over() FII_ATTRIBUTE2,
                          sum(count(distinct case when pay.no_days_late =  0 then i.invoice_id else null end)) over() FII_ATTRIBUTE3,
                          '''||l_url_1||''' FII_ATTRIBUTE10,
                          '''||l_url_1||''' FII_ATTRIBUTE11,
                          '''||l_url_2||''' FII_ATTRIBUTE12,
                          '''||l_url_3||''' FII_ATTRIBUTE13,
                          '''||l_url_4||''' FII_ATTRIBUTE14
                   from   ap_checks_all f, IBY_PAYMENT_METHODS_VL code, ap_lookup_codes code1,
			                    iby_payee_assigned_bankacct_v bankacct, ap_invoices_all i,
                          ap_system_parameters_all asp,
                          fii_ap_pay_sched_b pay
                   where 	trunc(pay.action_date) <= &BIS_CURRENT_ASOF_DATE
                   and   	trunc(pay.action_date) >= :PERIOD_START
                   and   	code1.lookup_type = ''CHECK STATE''
                   and   	f.payment_method_code  = code.payment_method_code
                   and   	f.status_lookup_code = code1.lookup_code
		               and   	f.external_bank_account_id = bankacct.ext_bank_account_id(+)
                   and   	f.check_id = pay.check_id
                   and   	f.void_date is null
                   and   	pay.invoice_id = i.invoice_id
                   and   	pay.action = ''PAYMENT''
                   and   	i.org_id = asp.org_id
                   and   	i.invoice_type_lookup_code <> ''EXPENSE REPORT''
                   				'
                   				||l_org_where||l_supplier_where||'
                   group by f.check_number, f.check_id, code.payment_method_name, f.amount,
                            f.check_date, code1.displayed_field, f.bank_account_name,
			    									f.bank_account_num, bankacct.bank_name, bankacct.bank_number,
                            f.currency_code, asp.base_currency_code, f.base_amount
                   &ORDER_BY_CLAUSE ';

      /* Binding Section */
       FII_PMV_Util.bind_variable(
       p_sqlstmt=>sqlstmt,
       p_page_parameter_tbl=>p_page_parameter_tbl,
       p_sql_output=>pay_detail_sql,
       p_bind_output_table=>pay_detail_output,
       p_period_start=>l_period_start
       );
 END;
END FII_AP_PAID_INV_DETAIL;

/
