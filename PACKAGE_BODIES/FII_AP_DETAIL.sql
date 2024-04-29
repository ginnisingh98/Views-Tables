--------------------------------------------------------
--  DDL for Package Body FII_AP_DETAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AP_DETAIL" AS
/* $Header: FIIAPDEB.pls 120.7 2006/10/13 21:24:51 vkazhipu ship $ */
 /*  This is a public function to get account description  */
 FUNCTION Get_Account_Desc(p_chart_of_accounts_id IN NUMBER, p_dist_code_combination_id IN NUMBER)
 return Varchar2 IS
     l_account_description Varchar2(1000);
 BEGIN
      IF (FND_FLEX_KEYVAL.validate_ccid
                                 ('SQLGL', 'GL#', p_CHART_OF_ACCOUNTS_ID, p_DIST_CODE_COMBINATION_ID,
                                  'ALL', NULL, NULL, 'IGNORE', NULL, NULL, NULL, NULL)) THEN
          l_account_description := FND_FLEX_KEYVAL.concatenated_descriptions;
       END IF;
       return l_account_description;
 END;

PROCEDURE Get_Inv_Distribution_Detail (
        p_page_parameter_tbl   IN 		BIS_PMV_PAGE_PARAMETER_TBL,
        inv_dist_sql           OUT NOCOPY       VARCHAR2,
        inv_dist_output        OUT NOCOPY       BIS_QUERY_ATTRIBUTES_TBL
) IS
        l_as_of_date            DATE;
        l_operating_unit        VARCHAR2(240);
        l_supplier              VARCHAR2(240);
        l_invoice_number        NUMBER;
        l_period_type           VARCHAR2(240);
        l_record_type_id        NUMBER;
        l_view_by               VARCHAR2(240);
        l_currency              VARCHAR2(240);
        l_column_name           VARCHAR2(240);
        l_table_name            VARCHAR2(240);
        l_gid                   NUMBER;
        l_org_where             VARCHAR2(240);
        l_supplier_where        VARCHAR2(240);
        l_invoice_id            NUMBER;
	      l_line_number		NUMBER := -9999;

        sqlstmt                 VARCHAR2(14000);
        l_line_stmt             VARCHAR2(1000);

BEGIN
        fii_pmv_util.get_parameters(
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

--Added code for R12 enhancement for getting value for line number
  IF (p_page_parameter_tbl.count > 0) THEN
     FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP
         IF 	p_page_parameter_tbl(i).parameter_name = 'FII_LINE_NUM' THEN
                l_line_number := p_page_parameter_tbl(i).parameter_value;

         END IF;
     END LOOP;
  END IF;
--added by vkazhipu for bug 5581666 to handle the flow from EA reports
  if (l_line_number = -9999) THEN
   l_line_stmt := '';
  else
   l_line_stmt := ' AND aid.invoice_line_number = :LINE_NUMBER';
   end if;

        fii_pmv_util.get_invoice_id(p_page_parameter_tbl, l_invoice_id);

        sqlstmt := '
        SELECT  aid.distribution_line_number 										FII_AP_DIST_NUM,
                alc.displayed_field											FII_AP_DIST_TYPE,
                aid.amount												FII_AP_DIST_AMOUNT,
                apps.fnd_flex_ext.get_segs(''SQLGL'',''GL#'',glcc.chart_of_accounts_id,aid.dist_code_combination_id)	FII_AP_ACCOUNT,
                fii_ap_detail.get_account_desc(glcc.chart_of_accounts_id,aid.dist_code_combination_id)			FII_AP_ACCOUNT_DESC,
                sum (aid.amount) over()											FII_AP_DIST_AMOUNT_GT
        FROM    ap_invoice_distributions_all    	aid,
                ap_lookup_codes                 	alc,
                gl_code_combinations            	glcc
        WHERE   aid.line_type_lookup_code               = alc.lookup_code
		AND alc.lookup_type = ''INVOICE DISTRIBUTION TYPE''
                AND aid.dist_code_combination_id        = glcc.code_combination_id
                AND aid.invoice_id                      = :INVOICE_ID'||l_line_stmt||'
	&ORDER_BY_CLAUSE
        ';

-- R12 Added bind varaiable parameter p_line_number
        fii_pmv_util.bind_variable(
                p_sqlstmt               => sqlstmt,
                p_page_parameter_tbl    => p_page_parameter_tbl,
                p_sql_output            => inv_dist_sql,
                p_bind_output_table     => inv_dist_output,
                p_invoice_number        => l_invoice_id,
		p_line_number		=> l_line_number
        );
END get_inv_distribution_detail;

  PROCEDURE Get_Hold_History
     ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
       hold_history_sql out NOCOPY VARCHAR2,
       hold_history_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)IS
       /* declaration section */
       sqlstmt          VARCHAR2(14000);

       l_as_of_date     DATE;
       l_operating_unit VARCHAR2(240);
       l_supplier       VARCHAR2(240);
       l_invoice_number NUMBER;
       l_period_type    VARCHAR2(240);
       l_record_type_id NUMBER;
       l_view_by        VARCHAR2(240);
       l_currency       VARCHAR2(240);
       l_column_name    VARCHAR2(240);
       l_table_name     VARCHAR2(240);
       l_gid            NUMBER;
       l_org_where      VARCHAR2(240);
       l_supplier_where VARCHAR2(240);

       l_invoice_id     NUMBER;

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

       FII_PMV_Util.get_invoice_id(p_page_parameter_tbl, l_invoice_id);

       /**************Description of Measures, Attributes returned to PMV *****
        FII_MEASURE1 - Hold Name
        FII_MEASURE2 - Hold Date
        FII_MEASURE3 - Held By
        FII_MEASURE4 - Hold Release Date
       ***********************************************************************/

/* Main SQL section */

-- PMV SQL modified as part of Enhancement 4234120 to pick data from Oracle Payables Tables.
-- Prior to this, data was picked from MV, FII_AP_INV_HOLDS_B

	sqlstmt := '
		    SELECT hold.hold_lookup_code	FII_MEASURE1
	                  ,TRUNC(hold.hold_date)	FII_MEASURE2
	                  ,DECODE(hold.release_lookup_code, NULL, NULL,hold.last_update_date)	FII_MEASURE4
	                  ,fnd_usr.user_name		FII_MEASURE3
		     FROM  ap_invoices_all    inv
			  ,ap_holds_all	      hold
			  ,fnd_user_view      fnd_usr
	            WHERE inv.invoice_id  = hold.invoice_id
	              AND hold.invoice_id = :INVOICE_ID
	              AND hold.held_by = fnd_usr.user_id
	              AND inv.cancelled_date IS NULL
	              AND inv.invoice_type_lookup_code NOT IN (''PREPAYMENT'')
                      &ORDER_BY_CLAUSE
		    ';


      /* Binding Section */
       FII_PMV_Util.bind_variable(
       p_sqlstmt=>sqlstmt,
       p_page_parameter_tbl=>p_page_parameter_tbl,
       p_sql_output=>hold_history_sql,
       p_bind_output_table=>hold_history_output,
       p_invoice_number=>l_invoice_id
       );
 END;

  PROCEDURE Get_Inv_Activity_History
     ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
       inv_act_sql out NOCOPY VARCHAR2,
       inv_act_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)IS
       /* declaration section */
       sqlstmt          VARCHAR2(14000);

       l_as_of_date     DATE;
       l_operating_unit VARCHAR2(240);
       l_supplier       VARCHAR2(240);
       l_invoice_number NUMBER;
       l_period_type    VARCHAR2(240);
       l_record_type_id NUMBER;
       l_view_by        VARCHAR2(240);
       l_currency       VARCHAR2(240);
       l_column_name    VARCHAR2(240);
       l_table_name     VARCHAR2(240);
       l_gid            NUMBER;
       l_org_where      VARCHAR2(240);
       l_supplier_where VARCHAR2(240);
       l_invoice_id     NUMBER;

       stmt1            VARCHAR2(240);
       stmt2            VARCHAR2(240);
       stmt3            VARCHAR2(240);
       stmt4            VARCHAR2(240);
       stmt5            VARCHAR2(240);
       stmt6            VARCHAR2(240);
       stmt7            VARCHAR2(240);
       stmt8            VARCHAR2(240);
       stmt9            VARCHAR2(240);

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

       FII_PMV_Util.get_invoice_id(p_page_parameter_tbl, l_invoice_id);

       /**************Description of Measures, Attributes returned to PMV *****
        FII_MEASURE1 - Action
        FII_MEASURE2 - Date,
        FII_MEASURE3 - User
       ***********************************************************************/



       /**********Message to be displayed ************************************/
       stmt1 :=  FND_MESSAGE.get_string('FII', 'FII_AP_ENTRY');
       stmt2 :=  FND_MESSAGE.get_string('FII', 'FII_AP_HOLD_PLACED');
       stmt3 :=  FND_MESSAGE.get_string('FII', 'FII_AP_HOLD_RELEASED');
       stmt4 :=  FND_MESSAGE.get_string('FII', 'FII_AP_PREPAY_APPLIED');
       stmt5 :=  FND_MESSAGE.get_string('FII', 'FII_AP_PREPAY_UNAPPLIED');
       stmt6 :=  FND_MESSAGE.get_string('FII', 'FII_AP_PAYMENT');
       stmt7 :=  FND_MESSAGE.get_string('FII', 'FII_AP_PAYMT_VOID');
       stmt8 :=  FND_MESSAGE.get_string('FII', 'FII_AP_PAYMT_STOP');
       stmt9 :=  FND_MESSAGE.get_string('FII', 'FII_AP_PAYMT_RELEASE');

       /*get date mask */
       FII_PMV_Util.get_format_mask(l_date_mask);

       /* Main SQL section */
       sqlstmt := 'select action FII_MEASURE1,
                   action_date FII_MEASURE2,
                   usr.user_name FII_MEASURE3
                   from
                   (select :ENTRY  action,
                    entered_date action_date,
                    created_by by_whom
                   from fii_ap_invoice_b
                   where invoice_id=:INVOICE_ID
                   union all
                   select :HOLD_PLACED action,
                   hold_date action_date,
                   held_by by_whom
                   from fii_ap_inv_holds_b
                   where invoice_id=:INVOICE_ID
                   and period_type_id = 1
                   union all
                   select :HOLD_RELEASED action,
                   release_date action_date,
                   released_by by_whom
                   from fii_ap_inv_holds_b
                   where invoice_id=:INVOICE_ID
                   and period_type_id = 1
                   union all
                   SELECT CASE WHEN b.amount < 0 THEN
                   :PREPAY_APPLIED
                   ELSE
                   :PREPAY_UNAPPLIED
                   END action,
                   trunc(b.creation_date) action_date,
                   a.last_updated_by by_whom
                   from ap_invoice_distributions_all a, ap_invoice_distributions_all b
                   where a.invoice_id=:INVOICE_ID
                   and a.invoice_distribution_id  = b.prepay_distribution_id
                   and b.line_type_lookup_code = ''PREPAY''
                   and b.amount <> 0
                   and a.invoice_id <> b.invoice_id
                   union all
                   select :PAYMT action,
                   action_date action_date,
                   created_by by_whom
                   from fii_ap_pay_sched_b
                   where invoice_id=:INVOICE_ID
                   and action in (''PAYMENT'', ''PREPAYMENT'')
                   and period_type_id = 1
                   union all
                   select CASE WHEN  c.stopped_date is not null
                   THEN :PAYMT_STOP
                   ELSE :PAYMT_RELEASE END action,
                   CASE WHEN  c.stopped_date is not null
                   THEN c.stopped_date
                   ELSE c.released_date END action_date,
                   CASE WHEN  c.stopped_date is not null
                   THEN c.stopped_by
                   ELSE c.released_by END  by_whom
                   from ap_checks_all c, ap_invoice_payments_all p
                   where c.check_id = p.check_id
                   and p.invoice_id = :INVOICE_ID
                   and (c.stopped_date is not null
                   OR c.released_date is not null)
                   ) a,
                   fnd_user usr
                   Where a.by_whom = usr.user_id
                   &ORDER_BY_CLAUSE ';

stmt1 :=  FND_MESSAGE.get_string('FII', 'FII_AP_ENTRY');
       stmt2 :=  FND_MESSAGE.get_string('FII', 'FII_AP_HOLD_PLACED');
       stmt3 :=  FND_MESSAGE.get_string('FII', 'FII_AP_HOLD_RELEASED');
       stmt4 :=  FND_MESSAGE.get_string('FII', 'FII_AP_PREPAY_APPLIED');
       stmt5 :=  FND_MESSAGE.get_string('FII', 'FII_AP_PREPAY_UNAPPLIED');
       stmt6 :=  FND_MESSAGE.get_string('FII', 'FII_AP_PAYMENT');
       stmt7 :=  FND_MESSAGE.get_string('FII', 'FII_AP_PAYMT_VOID');
       stmt8 :=  FND_MESSAGE.get_string('FII', 'FII_AP_PAYMT_STOP');
       stmt9 :=  FND_MESSAGE.get_string('FII', 'FII_AP_PAYMT_RELEASE');

      /* Binding Section */
       FII_PMV_Util.bind_variable(
       p_sqlstmt=>sqlstmt,
       p_page_parameter_tbl=>p_page_parameter_tbl,
       p_sql_output=>inv_act_sql,
       p_bind_output_table=>inv_act_output,
       p_invoice_number=>l_invoice_id,

       p_entry=>stmt1,
       p_hold_placed=>stmt2,
       p_hold_released=>stmt3,
       p_prepay_applied=>stmt4,
       p_prepay_unapplied=>stmt5,
       p_payment=>stmt6,
       p_paymt_void=>stmt7,
       p_paymt_stop=>stmt8,
       p_paymt_release=>stmt9

       );
 END;

   PROCEDURE Get_Sched_Pay_Discount
     ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
       sched_pay_sql out NOCOPY VARCHAR2,
       sched_pay_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)IS
       /* declaration section */
       sqlstmt          VARCHAR2(14000);

       l_as_of_date     DATE;
       l_operating_unit VARCHAR2(240);
       l_supplier       VARCHAR2(240);
       l_invoice_number NUMBER;
       l_period_type    VARCHAR2(240);
       l_record_type_id NUMBER;
       l_view_by        VARCHAR2(240);
       l_currency       VARCHAR2(240);
       l_column_name    VARCHAR2(240);
       l_table_name     VARCHAR2(240);
       l_gid            NUMBER;
       l_org_where      VARCHAR2(240);
       l_supplier_where VARCHAR2(240);

       l_invoice_id     NUMBER;

       l_date_mask      VARCHAR2(240);
       l_yes            VARCHAR2(240);
       l_no             VARCHAR2(240);
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

       FII_PMV_Util.get_invoice_id(p_page_parameter_tbl, l_invoice_id);

       /**************Description of Measures, Attributes returned to PMV *****
        FII_MEASURE1 - Payment Number
        FII_MEASURE2 - Due Date
        FII_MEASURE3 - Amount
        FII_MEASURE4 - Discount Date
        FII_MEASURE5 - Discount Amount
        FII_MEASURE6 - Second Discount Date
        FII_MEASURE7 - Second Discount Amount
        FII_MEASURE8 - Third Discount Date
        FII_MEASURE9 - Third Discount Amount
        FII_MEASURE10- Hold Flag
        FII_MEASURE11 - Grand Total for Gross Amount
       ***********************************************************************/

       /*get date mask */
       FII_PMV_Util.get_format_mask(l_date_mask);

       /* get mls message for yes no */
       FII_PMV_Util.get_yes_no_msg(l_yes, l_no);

       /* Main SQL section */
        sqlstmt := 'select a.Payment_Num      FII_MEASURE1,
                           a.due_date         FII_MEASURE2,
                           a.Gross_Amount            FII_MEASURE3,
                           to_char(discount_date,'''||l_date_mask||''')             FII_MEASURE4,
                           a.Discount_Amount_Available   FII_MEASURE5,
                           to_char(second_discount_date,'''||l_date_mask||''')             FII_MEASURE6,
                           a.Second_Disc_Amt_Available   FII_MEASURE7,
                           to_char(third_discount_date, '''||l_date_mask||''')             FII_MEASURE8,
                           a.Third_Disc_Amt_Available    FII_MEASURE9,
                           decode(nvl(a.hold_flag, ''N''), ''Y'', '''||l_yes||''', ''N'', '''||l_no||''') FII_MEASURE10,
                           sum(a.gross_amount) over()              FII_MEASURE11
                    from AP_Payment_Schedules_All a
                    where a.invoice_id = :INVOICE_ID
                    &ORDER_BY_CLAUSE        '
        ;


      /* Binding Section */
       FII_PMV_Util.bind_variable(
       p_sqlstmt=>sqlstmt,
       p_page_parameter_tbl=>p_page_parameter_tbl,
       p_sql_output=>sched_pay_sql,
       p_bind_output_table=>sched_pay_output,
       p_invoice_number=>l_invoice_id
       );
 END;

PROCEDURE get_inv_lines_detail (
        p_page_parameter_tbl            IN 		BIS_PMV_PAGE_PARAMETER_TBL,
        p_inv_lines_detail_sql          OUT NOCOPY      VARCHAR2,
        p_inv_lines_detail_output       OUT NOCOPY      BIS_QUERY_ATTRIBUTES_TBL
) IS
        l_invoice_id            NUMBER;                 -- Variable to retrieve Invoice ID from parameter passed from parent report
        l_as_of_date            DATE;                   -- Variables for get_parameters
        l_operating_unit        VARCHAR2(240);
        l_supplier              VARCHAR2(240);
        l_invoice_number        NUMBER;
        l_period_type           VARCHAR2(240);
        l_record_type_id        NUMBER;
        l_view_by               VARCHAR2(240);
        l_currency              VARCHAR2(240);
        l_column_name           VARCHAR2(240);
        l_table_name            VARCHAR2(240);
        l_gid                   NUMBER;
        l_org_where             VARCHAR2(240);
        l_supplier_where        VARCHAR2(240);

        sqlstmt                 VARCHAR2(14000);

        l_url_line_amount       VARCHAR2(1000);         -- URL string to drill from line amount column
        l_url_po_number         VARCHAR2(1000);         -- URL string to drill from po number column

        BEGIN

        -- To read parameters passed from the parent report
        fii_pmv_util.get_parameters(
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

        -- To get the invoice id
        fii_pmv_util.get_invoice_id(p_page_parameter_tbl, l_invoice_id);

        l_url_line_amount := 'pFunctionName=FII_AP_INV_DIST_DETAIL&pParamIds=Y&FII_INVOICE_ID='|| l_invoice_id || '&FII_LINE_NUM=FII_AP_LINE_NUM';
        l_url_po_number   := 'pFunctionName=FII_EA_POA_DRILL&PoHeaderId='' || ail.po_header_id || ''&PoReleaseId='' || ail.po_release_id || ''&addBreadCrumb=Y&retainAM=Y';

        -- PMV Query to retrieve the Invoice Lines Detail report
        sqlstmt := '
        SELECT  ail.line_number                 FII_AP_LINE_NUM,
                alc.displayed_field 		FII_AP_LINE_TYPE,
                ail.amount			FII_AP_LINE_AMOUNT,
                ail.description			FII_AP_LINE_DESC,
                ail.quantity_invoiced           FII_AP_QUANTITY,
                muom.unit_of_measure_tl         FII_AP_UOM,				--  muom.uom_code
                poh.segment1	                FII_AP_PO_NUM,				--  poh.segment1
                poll.shipment_num		FII_AP_PO_SHIPMENT_NUM,
                por.release_num			FII_AP_RELEASE_NUM,
                rcvsh.receipt_num 		FII_AP_RECEIPT_NUM,                     --  receipt_num
                sum (ail.amount) over()		FII_AP_GT_LINE_AMOUNT,
                -- Drill from Line Amount column to Invoice Distributions Detail report
                ''' || l_url_line_amount || ''' FII_AP_LINE_AMOUNT_DRILL,
                -- Drill from PO Number column to PO Overview report
                ''' || l_url_po_number || ''' FII_AP_PO_NUM_DRILL
        FROM    ap_invoice_lines_all            ail,
                ap_lookup_codes            	alc,
                mtl_units_of_measure       	muom,
                po_headers_all             	poh,
                po_line_locations_all      	poll,
                po_releases_all            	por,
                rcv_transactions           	rcvt,
                rcv_shipment_headers       	rcvsh
        WHERE   ail.line_type_lookup_code       = alc.lookup_code
		AND alc.lookup_type = ''INVOICE LINE TYPE''
                AND ail.unit_meas_lookup_code   = muom.unit_of_measure(+)
                AND ail.po_header_id          = poh.po_header_id(+)
                AND ail.po_line_location_id   = poll.line_location_id(+)
                AND ail.po_release_id         = por.po_release_id(+)
                AND ail.rcv_transaction_id    = rcvt.transaction_id(+)
                AND rcvt.shipment_header_id   = rcvsh.shipment_header_id(+)
                AND ail.invoice_id              = :INVOICE_ID
        ORDER BY ail.line_number';

        fii_pmv_util.bind_variable(
                p_sqlstmt               => sqlstmt,
                p_page_parameter_tbl    => p_page_parameter_tbl,
                p_sql_output            => p_inv_lines_detail_sql,
                p_bind_output_table     => p_inv_lines_detail_output,
                p_invoice_number        => l_invoice_id
        );
END get_inv_lines_detail;

END FII_AP_DETAIL;

/
