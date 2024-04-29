--------------------------------------------------------
--  DDL for Package Body FV_GEN_ARTRX_REIMB_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_GEN_ARTRX_REIMB_PROC" AS
-- $Header: FVGARTRB.pls 120.0.12010000.16 2009/11/16 16:01:06 snama noship $

g_ledger_id NUMBER;
g_coa_id NUMBER;
g_org_id NUMBER;
g_ledger_name  VARCHAR2(50);
g_agreement_num VARCHAR2(30);
g_period_name   VARCHAR2(50);
g_period_num    NUMBER;
g_period_year   NUMBER;
C_STATE_LEVEL CONSTANT NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
g_log_level   CONSTANT NUMBER         := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
g_module_name VARCHAR2(50) := 'fv.plsql.fv_gen_artrx_reimb_proc.';
g_errbuf      VARCHAR2(500);
g_retcode     NUMBER := 0;
g_customer_id   NUMBER; --ra_customer_trx_all.bill_to_customer_id%TYPE;
g_currency      VARCHAR2(30):='USD'; --ra_customer_trx_all.invoice_currency_code%TYPE;
g_coll_hdr_tbl ar_invoice_api_pub.trx_header_tbl_type;
g_rec_hdr_tbl ar_invoice_api_pub.trx_header_tbl_type;
g_coll_lines_tbl ar_invoice_api_pub.trx_line_tbl_type;
g_rec_lines_tbl ar_invoice_api_pub.trx_line_tbl_type;
g_coll_dist_tbl ar_invoice_api_pub.trx_dist_tbl_type;
g_rec_dist_tbl ar_invoice_api_pub.trx_dist_tbl_type;
g_trx_coll_hdr_id  NUMBER;
g_trx_rec_hdr_id  NUMBER;
g_header_printed BOOLEAN := FALSE;
i                 INTEGER := 0;
j                 INTEGER := 0;
k                 INTEGER := 0;

g_agreement varchar2(50);
g_rec_due_trx_type_id  NUMBER;
g_liq_adv_trx_type_id NUMBER;
g_rec_due_prefix VARCHAR2(6);
g_liq_adv_prefix VARCHAR2(6);
g_trx_source_id NUMBER;
g_invoice_date DATE;
g_gl_balancing_segment VARCHAR2(30);
g_gl_nat_acc_segment VARCHAR2(30);
g_reimb_agreement_segment VARCHAR2(50);
g_advance_acc VARCHAR2(30);
g_revenue_acc VARCHAR2(30);
g_expenditure_acc VARCHAR2(30);
g_bfy_segment VARCHAR2(30);
g_org_segment VARCHAR2(30);
g_tot_expenses NUMBER;
g_tot_revenues NUMBER;
g_tot_advances NUMBER;
g_ussgl_flex_value_set_id NUMBER;


GET_SEGMENTS_EXCEP          EXCEPTION;
GET_QUALIFIER_SEGNUM_EXCEP  EXCEPTION;
GET_COMBINATION_ID_EXCEP    EXCEPTION;

l_batch_source_rec ar_invoice_api_pub.batch_source_rec_type;
g_trx_header_tbl ar_invoice_api_pub.trx_header_tbl_type;
g_trx_lines_tbl ar_invoice_api_pub.trx_line_tbl_type;
g_trx_dist_tbl ar_invoice_api_pub.trx_dist_tbl_type;
l_trx_salescredits_tbl ar_invoice_api_pub.trx_salescredits_tbl_type;
l_return_status varchar2(250);
l_msg_count number;
l_msg_data varchar2(2000);
l_customer_trx_id number;


PROCEDURE log (
      p_level             IN NUMBER,
      p_procedure_name    IN VARCHAR2,
      p_debug_info        IN VARCHAR2);

PROCEDURE Create_AR_Trx(p_trx_header_tbl IN ar_invoice_api_pub.trx_header_tbl_type,
                p_trx_lines_tbl IN ar_invoice_api_pub.trx_line_tbl_type,
                p_trx_dist_tbl IN ar_invoice_api_pub.trx_dist_tbl_type);

PROCEDURE create_header(p_trx_type IN VARCHAR2);

PROCEDURE create_line_dist(p_trx_type IN VARCHAR2,
                           p_amount   IN NUMBER,
                           p_agreement IN VARCHAR2);

FUNCTION get_ccid(p_agreement IN VARCHAR2
                  ,p_trx_type_id IN NUMBER
                  )
RETURN NUMBER;

PROCEDURE print_header;

PROCEDURE print_line(p_customer_name IN VARCHAR2,
                     p_trx_num IN VARCHAR2,
                     p_trx_type IN VARCHAR2,
                     p_reimb_agree_num IN VARCHAR2,
                     p_amt IN NUMBER,
                     p_terms IN VARCHAR2);



PROCEDURE main
( p_errbuf    OUT NOCOPY VARCHAR2,
  p_retcode   OUT NOCOPY NUMBER,
  p_period_name IN VARCHAR2,
  p_invoice_date IN VARCHAR2) IS

  l_module  VARCHAR2(500) := g_module_name||'.Main';
  l_log_mesg     VARCHAR2(1000);
  l_amt_not_billed   NUMBER;
  l_error_message VARCHAR2(600);
  l_error_code BOOLEAN;
  l_flag BOOLEAN;

  l_sql_agreement VARCHAR2(2500);
  l_sql_glbal VARCHAR2(2500);
  l_sql_glbc  VARCHAR2(2500);
  l_sql_balances VARCHAR2(3500);
  invalid_acct_segment_error EXCEPTION;

  TYPE ref_type IS REF CURSOR ;
  agree_cur ref_type;
  glbal_cur ref_type;
  glbc_cur ref_type;

  l_err_code NUMBER;
  l_exp_child NUMBER:=0;
  l_rev_child NUMBER:=0;
  l_adv_child NUMBER:=0;
  l_amt_rem_rec NUMBER:=0;
  l_sql_exp_child VARCHAR2(600);
  l_sql_rev_child VARCHAR2(600);
  l_sql_adv_child VARCHAR2(600);
  l_cnt number := 0;
  l_cnt_trx number:=0;
  l_sql_agree_range        VARCHAR2(1000);
  agree_range_cur ref_type;


  BEGIN

    fv_utility.log_mesg('Parameters: ');
    fv_utility.log_mesg('p_period_name: '||p_period_name);

    g_org_id := mo_global.get_current_org_id;

    fv_utility.log_mesg('Org Id: '||g_org_id);

    g_period_name := p_period_name;
    g_invoice_date :=fnd_date.canonical_to_date(p_invoice_date);

   mo_utils.Get_Ledger_Info
  (  p_operating_unit         =>	g_org_id
   , p_ledger_id              =>	g_ledger_id
   , p_ledger_name            =>	g_ledger_name);

    SELECT period_year, period_num
    INTO g_period_year, g_period_num
    FROM gl_period_statuses
    WHERE application_id = 101
    AND set_of_books_id = g_ledger_id
    AND period_name = g_period_name;

    fv_utility.log_mesg('period year: '||g_period_year);
    fv_utility.log_mesg('period num: '||g_period_num);
    fv_utility.log_mesg('p_invoice_date: '||p_invoice_date);
    fv_utility.log_mesg('Ledger: '||g_ledger_name);
    fv_utility.log_mesg('-----------------------------');

   select CHART_OF_ACCOUNTS_ID
   into g_coa_id
   from gl_ledgers
   where  ledger_id = g_ledger_id;

   fv_utility.log_mesg('g_coa_id: '||g_coa_id);


BEGIN
    SELECT REC_DUE_TRANSACTION_TYPE_ID,
    LIQ_ADV_TRANSACTION_TYPE_ID,
    REIM_TRANSACTION_SOURCE_ID,
    REC_DUE_PREFIX,
    LIQ_ADV_PREFIX
    INTO
    g_rec_due_trx_type_id,
    g_liq_adv_trx_type_id,
    g_trx_source_id,
    g_rec_due_prefix,
    g_liq_adv_prefix
    From FV_OPERATING_UNITS_ALL
    where set_of_books_id = g_ledger_id
    and org_id = g_org_id;
EXCEPTION
WHEN NO_DATA_FOUND THEN
log(C_STATE_LEVEL, l_module, 'Transaction Set up not done in Federal Options form ');
END;

 log(C_STATE_LEVEL, l_module, 'g_rec_due_trx_type_id: '||g_rec_due_trx_type_id);
 log(C_STATE_LEVEL, l_module, 'g_liq_adv_trx_type_id: '||g_liq_adv_trx_type_id);
 log(C_STATE_LEVEL, l_module, 'g_trx_source_id: '||g_trx_source_id);
 log(C_STATE_LEVEL, l_module, 'g_rec_due_prefix: '||g_rec_due_prefix);
 log(C_STATE_LEVEL, l_module, 'g_liq_adv_prefix: '||g_liq_adv_prefix);

BEGIN
      SELECT application_column_name
      INTO g_bfy_segment
      FROM fv_pya_fiscalyear_segment
     WHERE set_of_books_id = g_ledger_id;
EXCEPTION
WHEN NO_DATA_FOUND THEN
log(C_STATE_LEVEL, l_module, 'Error deriving the bfy segment ');
END;

-- Bug 8968764: Added Begin/Exception block to handle invalid_acct_segment_error
-- exception
BEGIN
log(C_STATE_LEVEL, l_module, 'bfy segment: '||g_bfy_segment);
-- finding the Account and Balancing segments
FV_UTILITY.get_segment_col_names(g_coa_id,
                                 g_gl_nat_acc_segment,
                                 g_gl_balancing_segment,
                                 l_error_code,
                                 l_error_message);
log(C_STATE_LEVEL, l_module, 'g_gl_balancing_segment: '||g_gl_balancing_segment);
log(C_STATE_LEVEL, l_module, 'g_gl_nat_acc_segment: '||g_gl_nat_acc_segment);

--finding the flex_value_set_id for the Natural Account segment
         SELECT  flex_value_set_id into g_ussgl_flex_value_set_id
         FROM    fnd_id_flex_segments
         WHERE   application_column_name = g_gl_nat_acc_segment
        AND     application_id      = 101
        AND     id_flex_code        = 'GL#'
        AND     id_flex_num         = g_coa_id;
log(C_STATE_LEVEL, l_module, 'g_ussgl_flex_value_set_id: '||g_ussgl_flex_value_set_id);

EXCEPTION

WHEN  invalid_acct_segment_error THEN
log(C_STATE_LEVEL, l_module, 'Error deriving flex value set id.');
END;

--Finding the Reimbursable Segment name from the reimb segment defined
-- in the Federal Financial Options
BEGIN
      SELECT application_column_name
      INTO   g_reimb_agreement_segment
      FROM   FND_ID_FLEX_SEGMENTS_VL
      WHERE  application_id         = 101
      AND    id_flex_code           = 'GL#'
      AND    id_flex_num            = g_coa_id
      AND    enabled_flag           = 'Y'
      AND    segment_name like
        (Select REIMB_AGREEMENT_SEGMENT_VALUE
         from fv_reimb_segment
         where set_of_books_id = g_ledger_id);


EXCEPTION
WHEN no_data_found then
log(C_STATE_LEVEL, l_module, 'Error deriving the Reimbursable Agreement Segment ');
END;

log(C_STATE_LEVEL, l_module, 'g_reimb_agreement_segment: '||g_reimb_agreement_segment);



BEGIN
Select
ADVANCE_SEGMENT_VALUE,
REVENUE_SEGMENT_VALUE,
EXPENDITURE_SEGMENT_VALUE
INTO
g_advance_acc,
g_revenue_acc,
g_expenditure_acc
from fv_reimb_segment
where set_of_books_id = g_ledger_id;

EXCEPTION
when no_data_found then
log(C_STATE_LEVEL, l_module, 'Error deriving the Advance, Expenditure and Revenue Account ');
END;

 log(C_STATE_LEVEL, l_module, 'g_advance_acc: '||g_advance_acc);
 log(C_STATE_LEVEL, l_module, 'g_revenue_acc: '||g_revenue_acc);
 log(C_STATE_LEVEL, l_module, 'g_expenditure_acc: '||g_expenditure_acc);

BEGIN
--Finding Child values if expenditure account on federal Financials options form is a parent account

        select count(distinct(FLEX_VALUE)) into l_exp_child
        from FND_FLEX_VALUE_CHILDREN_V
        where FLEX_VALUE_SET_ID = g_ussgl_flex_value_set_id
        start with PARENT_FLEX_VALUE = g_expenditure_acc
        connect by nocycle prior FLEX_VALUE = PARENT_FLEX_VALUE;

        If l_exp_child > 0 THEN

        l_sql_exp_child := 'select distinct(FLEX_VALUE)
        from FND_FLEX_VALUE_CHILDREN_V
        where FLEX_VALUE_SET_ID = '||g_ussgl_flex_value_set_id||'
        start with PARENT_FLEX_VALUE = '||''''||g_expenditure_acc||''''||'
        connect by nocycle prior FLEX_VALUE = PARENT_FLEX_VALUE';

        ELSE

        l_sql_exp_child:= g_expenditure_acc;
        END IF;
EXCEPTION
When others then
l_err_code:=SQLCODE;
l_error_message:=substr(SQLERRM, 1, 200);
log(C_STATE_LEVEL, l_module, 'Error deriving the child values for parent expenditure account: '||l_error_message);
END;
 log(C_STATE_LEVEL, l_module, 'Child accounts of g_expenditure_acc: '||l_exp_child);


BEGIN
        select count(distinct(FLEX_VALUE)) into l_rev_child
        from FND_FLEX_VALUE_CHILDREN_V
        where FLEX_VALUE_SET_ID = g_ussgl_flex_value_set_id
        start with PARENT_FLEX_VALUE = g_revenue_acc
        connect by nocycle prior FLEX_VALUE = PARENT_FLEX_VALUE;


        If l_rev_child >0 THEN

        l_sql_rev_child := 'select distinct(FLEX_VALUE)
        from FND_FLEX_VALUE_CHILDREN_V
        where FLEX_VALUE_SET_ID = '||g_ussgl_flex_value_set_id||'
        start with PARENT_FLEX_VALUE = '||''''||g_revenue_acc||''''||'
        connect by nocycle prior FLEX_VALUE = PARENT_FLEX_VALUE';

        ELSE
        l_sql_rev_child:= g_revenue_acc;
        END IF;

EXCEPTION
When others then
l_err_code:=SQLCODE;
l_error_message:=substr(SQLERRM, 1, 200);
log(C_STATE_LEVEL, l_module, 'Error deriving the child values for parent revenue account: '||l_error_message);
END;
log(C_STATE_LEVEL, l_module, 'Child Accounts of g_revenue_acc: '||l_rev_child);

BEGIN
        select count(distinct(FLEX_VALUE)) into l_adv_child
        from FND_FLEX_VALUE_CHILDREN_V
        where FLEX_VALUE_SET_ID = g_ussgl_flex_value_set_id
        start with PARENT_FLEX_VALUE = g_advance_acc
        connect by nocycle prior FLEX_VALUE = PARENT_FLEX_VALUE;

        If l_adv_child >0 THEN

        l_sql_adv_child := 'select distinct(FLEX_VALUE)
        from FND_FLEX_VALUE_CHILDREN_V
        where FLEX_VALUE_SET_ID = '||g_ussgl_flex_value_set_id||'
        start with PARENT_FLEX_VALUE = '||''''||g_advance_acc||''''||'
        connect by nocycle prior FLEX_VALUE = PARENT_FLEX_VALUE';

        ELSE
        l_sql_adv_child:= g_advance_acc;
        END IF;

EXCEPTION
When others then
l_err_code:=SQLCODE;
l_error_message:=substr(SQLERRM, 1, 200);
log(C_STATE_LEVEL, l_module, 'Error deriving the child values for parent advance account: '||l_error_message);
END;
 log(C_STATE_LEVEL, l_module, 'Child values of g_advance_acc: '||l_adv_child);

l_sql_agree_range :=
                'SELECT f.flex_value
                 FROM  fnd_flex_values_vl f, fnd_id_flex_segments segs, ra_customer_trx_all r,
                      ra_cust_trx_types_all t
                WHERE f.flex_value_set_id =segs.flex_value_set_id AND
                    segs.application_column_name = :g_reimb_agreement_segment AND
                    segs.application_id      = 101 AND
                    segs.id_flex_code        = ''GL#'' AND
                    segs.id_flex_num         = :g_coa_id AND
                    f.flex_value = r.trx_number AND
                    r.set_of_books_id = :g_ledger_id AND
                    r.invoice_currency_code = :g_currency AND
                    r.cust_trx_type_id = t.cust_trx_type_id AND
                    t.type = ''GUAR''';

log(C_STATE_LEVEL, l_module, 'l_sql_agree_range '||l_sql_agree_range);


l_sql_glbal := '(SELECT
sum(case when glc.'||g_gl_nat_acc_segment||' in ( '||l_sql_exp_child ||') then (nvl(period_net_dr,0) - nvl(period_net_cr,0)) else 0 end) expenses,
sum(case when glc.'||g_gl_nat_acc_segment||' in ( '||l_sql_rev_child ||') then (nvl(period_net_dr,0) - nvl(period_net_cr,0)) else 0 end) revenues,
sum(case when glc.'||g_gl_nat_acc_segment||' in ( '||l_sql_adv_child ||') then (nvl(period_net_dr,0) - nvl(period_net_cr,0)) else 0 end) advances
       FROM gl_balances glb,
       gl_code_combinations glc
  WHERE glb.actual_flag = ''A''
    and glb.ledger_id = :g_ledger_id
    AND glb.template_id is NULL
    AND glb.currency_code = ''USD''
    AND glb.code_combination_id = glc.code_combination_id
    and glc.chart_of_accounts_id = :g_coa_id
    and glc.'||g_gl_balancing_segment||' <> ''0''
    and glb.period_year = :g_period_year
    and glc.'||g_reimb_agreement_segment||' = :g_agreement)';


log(C_STATE_LEVEL, l_module, 'l_sql_glbal: '||l_sql_glbal);

-- Modified for bug 8815978
l_sql_glbc := '(SELECT
sum(case when glc.'||g_gl_nat_acc_segment||' in ( '||l_sql_exp_child ||') then (nvl(accounted_dr,0) - nvl(accounted_cr,0)) else 0 end) expenses,
sum(case when glc.'||g_gl_nat_acc_segment||' in ( '||l_sql_rev_child ||') then (nvl(accounted_dr,0) - nvl(accounted_cr,0)) else 0 end) revenues,
sum(case when glc.'||g_gl_nat_acc_segment||' in ( '||l_sql_adv_child ||') then (nvl(accounted_dr,0) - nvl(accounted_cr,0)) else 0 end) advances
       FROM gl_bc_packets glbc,
       gl_code_combinations glc
  WHERE glbc.actual_flag = ''A''
    and glbc.ledger_id = :g_ledger_id
    AND glbc.template_id is NULL
    AND glbc.status_code = ''A''
    AND glbc.currency_code = ''USD''
    AND glbc.code_combination_id = glc.code_combination_id
    and glc.chart_of_accounts_id = :g_coa_id
    and glc.'||g_gl_balancing_segment||' <> ''0''
    and glbc.period_year = :g_period_year
    and glc.'||g_reimb_agreement_segment||' = :g_agreement)';


log(C_STATE_LEVEL, l_module, 'l_sql_glbc: '||l_sql_glbc);


l_sql_balances:='select sum(expenses) tot_exp, sum(revenues) tot_rev,
                  sum(advances) tot_adv from
                  ('||l_sql_glbal||' UNION ALL '||l_sql_glbc||')';

log(C_STATE_LEVEL, l_module, 'SQL calculates sum of the union from gl_balances and gl_bc_packets ');
log(C_STATE_LEVEL, l_module, 'l_sql_balances: '||l_sql_balances);


OPEN agree_range_cur FOR l_sql_agree_range USING g_reimb_agreement_segment,g_coa_id,g_ledger_id,g_currency;

log(C_STATE_LEVEL, l_module, 'Opened agree_range_cur ');

LOOP
fetch agree_range_cur INTO g_agreement_num;
 exit when agree_range_cur%notfound;

   log(C_STATE_LEVEL, l_module, 'Agreement Num from Range: '||g_agreement_num);


        l_amt_not_billed := 0;
        g_coll_hdr_tbl.DELETE;
        g_rec_hdr_tbl.DELETE;
        g_coll_lines_tbl.DELETE;
        g_rec_lines_tbl.DELETE;
        g_coll_dist_tbl.DELETE;
        g_rec_dist_tbl.DELETE;
        i := 0;
        j := 0;
         --Get the customer id and other details from the reimb agreement
            BEGIN


               SELECT bill_to_customer_id
               INTO   g_customer_id
               FROM   ra_customer_trx_all
               WHERE  trx_number = g_agreement_num
               AND invoice_currency_code = g_currency;

             EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  l_log_mesg :=
                     'No data found for agreement: '||g_agreement||' - Aborting process!!';
                  log(C_STATE_LEVEL, l_module, l_log_mesg);
                  p_errbuf := l_log_mesg;
                  p_retcode := 2;

               WHEN OTHERS THEN
                  l_log_mesg :=
                       'When others error in exception 1: '||l_module||': '||sqlerrm;
                  log(C_STATE_LEVEL, l_module, l_log_mesg);
                  p_errbuf := l_log_mesg;
                  p_retcode := 2;
            END;

log(C_STATE_LEVEL, l_module, 'Fetching balances from gl_balances and gl_bc_packets...');

OPEN glbal_cur FOR l_sql_balances USING g_ledger_id,g_coa_id,g_period_year,g_agreement_num,g_ledger_id,g_coa_id,g_period_year,g_agreement_num;
         LOOP

         FETCH glbal_cur into g_tot_expenses,g_tot_revenues,g_tot_advances;

         exit when glbal_cur%notfound;


            log(C_STATE_LEVEL, l_module, 'Expenses: '||ABS(g_tot_expenses));
            log(C_STATE_LEVEL, l_module, 'Revenues: '||g_tot_revenues);
            log(C_STATE_LEVEL, l_module, 'Advances: '||g_tot_advances);

            l_amt_not_billed := ABS(g_tot_expenses) - g_tot_revenues;
            log(C_STATE_LEVEL, l_module, 'l_amt_not_billed: '||l_amt_not_billed);


            --If expenses are greater than revenues, then need to create ar trx
            --for the excess of expenses over revenues (l_amt_not_billed).
            --Check if there are any advances.  If there are advances and l_amt_not_billed
            --greater than the advances, create ar trx for the advance amount, then create
            --ar trx for l_amt_not_billed less advance amount
            IF l_amt_not_billed > 0 THEN
               --fv_utility.log_mesg('To be billed: '||l_amt_not_billed);
---if there is advance
               IF ABS(g_tot_advances) <> 0 THEN
---if difference of expenses and revenues is greater than advance
                  IF ABS(g_tot_advances) <= l_amt_not_billed THEN
--create a transaction for the amount of advance
                     l_cnt_trx:=l_cnt_trx+1;
                     create_header('COLL');
                     log(C_STATE_LEVEL, l_module, 'Total Advances liquidated, Line Amount for Liquidating: '||ABS(g_tot_advances));
                     create_line_dist('COLL',ABS(g_tot_advances),
                                      g_agreement_num);

                     IF g_retcode <> 0 THEN
                        p_errbuf := g_errbuf;
                        p_retcode := g_retcode;
                        RETURN;
                     END IF;
                     -----------------------------------------------------------------------------
                     --Create trx for rec trx type
                     IF l_amt_not_billed - ABS(g_tot_advances) > 0 THEN
                     l_cnt_trx:=l_cnt_trx+1;
                     l_amt_rem_rec:=l_amt_not_billed - ABS(g_tot_advances);
                       create_header('REC');
                     log(C_STATE_LEVEL, l_module, 'Rec due for unbilled amount Amount after liquidating advances : '||l_amt_rem_rec);
                       create_line_dist('REC',(l_amt_not_billed - ABS(g_tot_advances)),
                                      g_agreement_num);
                         IF g_retcode <> 0 THEN
                            p_errbuf := g_errbuf;
                            p_retcode := g_retcode;
                            RETURN;
                         END IF;

                    END IF;

                  ELSIF (ABS(g_tot_advances) > l_amt_not_billed) THEN
                     l_cnt_trx:=l_cnt_trx+1;
                     create_header('COLL');
                     log(C_STATE_LEVEL, l_module, 'Total Advances more, liquidating part of advance, equal to unbilled amt, Line Amount for Liquidating: '||l_amt_not_billed);
                     create_line_dist('COLL',l_amt_not_billed,
                                      g_agreement_num);
                     IF g_retcode <> 0 THEN
                        p_errbuf := g_errbuf;
                        p_retcode := g_retcode;
                        RETURN;
                     END IF;

                  END IF;

               ELSE    --if advances = 0
                 ---------------------------------------
                 l_cnt_trx:=l_cnt_trx+1;
                 create_header('REC');
                 log(C_STATE_LEVEL, l_module, 'No Advances,creating rec due for unbilled amount , line amount: '||l_amt_not_billed);
                 create_line_dist('REC',l_amt_not_billed,
                                      g_agreement_num);
                 IF g_retcode <> 0 THEN
                    p_errbuf := g_errbuf;
                    p_retcode := g_retcode;
                    RETURN;
                 END IF;

               END IF;
            END IF;

        END LOOP;
         log(C_STATE_LEVEL, l_module, 'No of Transactions that will be created,l_cnt_trx: '||l_cnt_trx);
       close glbal_cur;

         log(C_STATE_LEVEL, l_module, 'No of Transactions that will be created,l_cnt_trx: '||l_cnt_trx);

        --If all hdrs, lines and dist created, then
        --submit api to create ar trx
        IF g_coll_lines_tbl.COUNT > 0 THEN
           create_ar_trx(g_coll_hdr_tbl,
                         g_coll_lines_tbl,
                         g_coll_dist_tbl);
           IF g_retcode <> 0 THEN
              p_errbuf := g_errbuf;
              p_retcode := g_retcode;
              RETURN;
           END IF;
        END IF;

        IF g_rec_lines_tbl.COUNT > 0 THEN
           create_ar_trx(g_rec_hdr_tbl,
                         g_rec_lines_tbl,
                         g_rec_dist_tbl);
           IF g_retcode <> 0 THEN
              p_errbuf := g_errbuf;
              p_retcode := g_retcode;
              RETURN;
           END IF;
        END IF;

END LOOP;
CLOSE agree_range_cur;

 END main;
-------------------------------------------------------------------------------
PROCEDURE log (
      p_level             IN NUMBER,
      p_procedure_name    IN VARCHAR2,
      p_debug_info        IN VARCHAR2)
IS

BEGIN
  IF (p_level >= g_log_level ) THEN
    FND_LOG.STRING(p_level,
                   p_procedure_name,
                   p_debug_info);
  END IF;
END log;
-------------------------------------------------------------------------------
PROCEDURE Create_AR_Trx(p_trx_header_tbl IN ar_invoice_api_pub.trx_header_tbl_type,
                p_trx_lines_tbl IN ar_invoice_api_pub.trx_line_tbl_type,
                p_trx_dist_tbl IN ar_invoice_api_pub.trx_dist_tbl_type)

IS
    l_module     VARCHAR2(240) := g_module_name||'Create_AR_Trx';
    l_debug_info         VARCHAR2(240);


    CURSOR cur_ar_trx_err IS
    SELECT * FROM ar_trx_errors_gt;
    l_return_status varchar2(250);
    l_msg_count number;
    l_msg_data varchar2(2000);
    l_customer_trx_id number;
    l_cnt number := 0;
    l_batch_source_rec ar_invoice_api_pub.batch_source_rec_type;
    l_trx_salescredits_tbl ar_invoice_api_pub.trx_salescredits_tbl_type;

    l_reimb_agree_num VARCHAR2(50);
    l_api_version              CONSTANT NUMBER := 1.0;

    l_reimb_seg_sql VARCHAR2(300);
    l_customer_name VARCHAR2(500);
    l_trx_type VARCHAR2(100);
    l_terms VARCHAR2(100);
BEGIN

    log(C_STATE_LEVEL, l_module, 'Begin: '||l_module);

       log(C_STATE_LEVEL, l_module, '----------Header----------');
       log(C_STATE_LEVEL, l_module, 'trx_header_id: '||p_trx_header_tbl(1).trx_header_id);
       log(C_STATE_LEVEL, l_module, 'trx_number: '||p_trx_header_tbl(1).trx_number);
       log(C_STATE_LEVEL, l_module, 'cust_trx_type_id: '||p_trx_header_tbl(1).cust_trx_type_id);
       log(C_STATE_LEVEL, l_module, 'trx_date: '||p_trx_header_tbl(1).trx_date);
       log(C_STATE_LEVEL, l_module, 'bill_to_customer_id: '||p_trx_header_tbl(1).bill_to_customer_id);
       log(C_STATE_LEVEL, l_module, 'gl_date: '||p_trx_header_tbl(1).gl_date);
       log(C_STATE_LEVEL, l_module, 'trx_currency: '||p_trx_header_tbl(1).trx_currency) ;
       log(C_STATE_LEVEL, l_module, 'primary_salesrep_id: '||p_trx_header_tbl(1).primary_salesrep_id);


       FOR i IN 1..p_trx_lines_tbl.COUNT LOOP
           log(C_STATE_LEVEL, l_module, '----------Lines----------');
           log(C_STATE_LEVEL, l_module, 'trx_header_id: '||p_trx_lines_tbl(i).trx_header_id);
           log(C_STATE_LEVEL, l_module, 'trx_line_id: '||p_trx_lines_tbl(i).trx_line_id);
           log(C_STATE_LEVEL, l_module, 'line_number: '||p_trx_lines_tbl(i).line_number);
           log(C_STATE_LEVEL, l_module, 'quantity_invoiced: '||p_trx_lines_tbl(i).quantity_invoiced);
           log(C_STATE_LEVEL, l_module, 'unit_selling_price: '||p_trx_lines_tbl(i).unit_selling_price);
           log(C_STATE_LEVEL, l_module, 'uom_code: '||p_trx_lines_tbl(i).uom_code);
           log(C_STATE_LEVEL, l_module, 'description: '||p_trx_lines_tbl(i).description);
           log(C_STATE_LEVEL, l_module, 'line_type: '||p_trx_lines_tbl(i).line_type);
       END LOOP;


       FOR i IN 1..p_trx_dist_tbl.COUNT LOOP
           log(C_STATE_LEVEL, l_module, '----------Dist----------');
           log(C_STATE_LEVEL, l_module, 'trx_header_id: '||p_trx_dist_tbl(i).trx_header_id);
           log(C_STATE_LEVEL, l_module, 'trx_line_id: '||p_trx_dist_tbl(i).trx_line_id);
           log(C_STATE_LEVEL, l_module, 'trx_dist_id: '||p_trx_dist_tbl(i).trx_dist_id);
           log(C_STATE_LEVEL, l_module, 'account_class: '||p_trx_dist_tbl(i).account_class);
           log(C_STATE_LEVEL, l_module, 'code_combination_id: '||p_trx_dist_tbl(i).code_combination_id);
           log(C_STATE_LEVEL, l_module, 'amount: '||p_trx_dist_tbl(i).amount);



           --Get the reimbursable agreement number from ccid
          /* l_reimb_seg_sql:=
           'SELECT ' || g_reimb_agreement_segment || '
            FROM gl_code_combinations
           WHERE code_combination_id = ' ||p_trx_dist_tbl(i).code_combination_id;


         log(C_STATE_LEVEL, l_module, 'Reimb segment sql: '||l_reimb_seg_sql);


           EXECUTE IMMEDIATE l_reimb_seg_sql into l_reimb_agree_num;*/
          -- Bug 8824917
          l_reimb_agree_num:= g_agreement_num;
          log(C_STATE_LEVEL, l_module, 'l_reimb_agree_num: '||l_reimb_agree_num);
          BEGIN
          Select rtt.name into l_terms
          from ra_customer_trx_all rct,
          ra_terms rtt
          where rct.term_id=rtt.term_id
          and rct.trx_number = l_reimb_agree_num
          and rct.set_of_books_id = g_ledger_id;
          EXCEPTION
          when no_data_found then
          log(C_STATE_LEVEL, l_module, 'unexpected errors found while deriving Terms!');
          END;
          log(C_STATE_LEVEL, l_module, 'l_terms: '||l_terms);

          BEGIN
          select hzp.party_name into l_customer_name
          from hz_parties hzp ,
          HZ_CUST_ACCounts  hza
          where hzp.party_id = hza.party_id
          and hza.cust_account_id = p_trx_header_tbl(1).bill_to_customer_id;
          EXCEPTION when others then
          null;
          END;
          log(C_STATE_LEVEL, l_module, 'l_customer_name: '||l_customer_name);

          Select name into l_trx_type
          from ra_cust_trx_types_all
          where cust_trx_type_id = p_trx_header_tbl(1).cust_trx_type_id;

          log(C_STATE_LEVEL, l_module, 'l_trx_type: '||l_trx_type);



       END LOOP;
  log(C_STATE_LEVEL, l_module, 'Befor mo_global Out of Loop after printing lines ');
   --     mo_global.init('AR');
  log(C_STATE_LEVEL, l_module, 'After MO_global');

        l_batch_source_rec.batch_source_id :=g_trx_source_id;
    log(C_STATE_LEVEL, l_module, 'g_trx_source_id: '||l_batch_source_rec.batch_source_id);


        AR_INVOICE_API_PUB.create_single_invoice(
                p_api_version          => l_api_version,
                p_init_msg_list        => FND_API.G_TRUE,
                p_commit               => FND_API.G_FALSE,
                p_batch_source_rec => l_batch_source_rec,
                p_trx_header_tbl =>  p_trx_header_tbl,
                p_trx_lines_tbl => p_trx_lines_tbl,
                p_trx_dist_tbl => p_trx_dist_tbl,
                p_trx_salescredits_tbl => l_trx_salescredits_tbl,
                x_customer_trx_id => l_customer_trx_id,
                x_return_status => l_return_status,
                x_msg_count => l_msg_count,
                x_msg_data => l_msg_data);

  log(C_STATE_LEVEL, l_module, 'After calling single_invoice');
        IF (l_return_status = fnd_api.g_ret_sts_error OR
          l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
          log(C_STATE_LEVEL, l_module, 'unexpected errors found!');
          log(C_STATE_LEVEL, l_module, 'l_msg_data: ' || l_msg_data);
        ELSE
            -- Check whether any record exist in error table

            SELECT count(*)
            Into l_cnt
            From ar_trx_errors_gt;

            log(C_STATE_LEVEL, l_module, 'rows in ar_trx_errors_gt '|| l_cnt);

            IF (l_cnt = 0) THEN
                log(C_STATE_LEVEL, l_module, 'Customer Trx id '|| l_customer_trx_id);

                   FOR i IN 1..p_trx_dist_tbl.COUNT LOOP
               --Print report header
                         IF NOT g_header_printed THEN
                            print_header;
                            g_header_printed := TRUE;
                         END IF;
                         --Print report line --1
                         print_line(l_customer_name,p_trx_header_tbl(1).trx_number,l_trx_type, l_reimb_agree_num,
                                    p_trx_dist_tbl(i).amount,l_terms);
                   END LOOP;

            ELSE
                log(C_STATE_LEVEL, l_module, 'Transaction not Created, Please check ar_trx_errors_gt table');
                log(C_STATE_LEVEL, l_module, '==============================================================');
                FOR err IN cur_ar_trx_err LOOP
                    log(C_STATE_LEVEL, l_module, 'ar_trx_error_gt column TRX HEADER ID: ' || err.invalid_value);
                    log(C_STATE_LEVEL, l_module, 'ar_trx_error_gt column TRX LINE ID: ' || err.invalid_value);
                    log(C_STATE_LEVEL, l_module, 'ar_trx_error_gt column ERROR MESSAGE: ' || err.error_message);
                    log(C_STATE_LEVEL, l_module, 'ar_trx_error_gt column INVALID VALUE: ' || err.invalid_value);
                END LOOP;
                log(C_STATE_LEVEL, l_module, '==============================================================');
            END IF;
        END IF;

    -- ================================== FND_LOG ==================================
    l_debug_info := 'End of procedure '||l_module;
    log(C_STATE_LEVEL, l_module, l_debug_info);
    -- ================================== FND_LOG ==================================

 EXCEPTION
    WHEN OTHERS THEN
    log(C_STATE_LEVEL, l_module, 'Transaction not Created, because of SQL error: ' || SQLCODE);
    log(C_STATE_LEVEL, l_module, 'Transaction not Created, because of SQL error: ' || SQLERRM);
    g_errbuf := 'Transaction not Created, because of SQL error: ' || SQLERRM;
    g_retcode := sqlerrm;
END;
-------------------------------------------------------------------------------
--Overlay the CCID for REV
FUNCTION get_ccid(p_agreement IN VARCHAR2
                  ,p_trx_type_id IN NUMBER) RETURN NUMBER IS

 l_segment4   VARCHAR2(25);
 l_segment5   VARCHAR2(25);
 l_ccid       NUMBER;
 l_agreement_rev_segments	FND_FLEX_EXT.SEGMENTARRAY;
 l_var        NUMBER;
 l_concat_segs    VARCHAR2(500);
 l_module     VARCHAR2(100) := g_module_name||' get_ccid';
 l_rev_nat_acc_sql VARCHAR2(400);
 l_rev_nat_acc_tt VARCHAR2(50);
 l_agreement_rev_ccid NUMBER;
 l_nat_acct_seg_num NUMBER;
 l_num_segments NUMBER;

 BEGIN

    log(C_STATE_LEVEL, l_module, 'In: '||l_module);
    log(C_STATE_LEVEL, l_module, 'p_agreement: '||p_agreement);
    log(C_STATE_LEVEL, l_module, 'p_trx_type_id: '||p_trx_type_id);

IF (NOT FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(   APPL_ID                => 101,
                                                   KEY_FLEX_CODE          => 'GL#',
                                                   STRUCTURE_NUMBER       => g_coa_id,
                                                   FLEX_QUAL_NAME         => 'GL_ACCOUNT',
                                                   SEGMENT_NUMBER         => l_nat_acct_seg_num))  -- OUT




then
 RAISE GET_QUALIFIER_SEGNUM_EXCEP;
else
   log(C_STATE_LEVEL, l_module, 'Segment Number for the USSGL segment is : ' || l_nat_acct_seg_num);
end if;

    l_var := 1;

--Step 1 Get the Revenue acc ccid from Reimbursible Agreement Transaction
-- As per FD the Reimbursible Agreement Trx will have only one Revenue Line.

               SELECT rctd.code_combination_id
               into l_agreement_rev_ccid
               FROM   ra_customer_trx_all rct,
                      RA_CUST_TRX_LINE_GL_DIST_ALL   rctd
               WHERE  rct.trx_number = p_agreement
               AND rct.customer_trx_id = rctd.customer_trx_id
               AND rctd.account_class = 'REV'
               AND rctd.set_of_books_id = g_ledger_id;

log(C_STATE_LEVEL, l_module, 'l_agreement_rev_ccid: '||l_agreement_rev_ccid);
--Step 2 Get the Natural account segment of the Rec account of the transation type
--Step 2a combine gl_c_c and ra_cust_trx_types_all to get the natural segment
l_rev_nat_acc_sql:=
    'SELECT g.'||g_gl_nat_acc_segment||'
    FROM   ra_cust_trx_types_all t,
           gl_code_combinations g
    WHERE  t.cust_trx_type_id = :p_trx_type_id
    AND    t.gl_id_rev = g.code_combination_id
    and    g.chart_of_accounts_id = :g_coa_id';

EXECUTE IMMEDIATE l_rev_nat_acc_sql into l_rev_nat_acc_tt USING p_trx_type_id, g_coa_id;

log(C_STATE_LEVEL, l_module, 'l_rev_nat_acc_tt: '||l_rev_nat_acc_tt);

       IF (NOT FND_FLEX_EXT.GET_SEGMENTS(
                                          APPLICATION_SHORT_NAME  => 'SQLGL',
                                          KEY_FLEX_CODE           => 'GL#',
                                          STRUCTURE_NUMBER        => g_coa_id,
                                          COMBINATION_ID          => l_agreement_rev_ccid,
                                          N_SEGMENTS              => l_num_segments,                -- OUT
                                          SEGMENTS                => l_agreement_rev_segments))     -- OUT
      THEN
      RAISE GET_SEGMENTS_EXCEP;
      ELSE
      log(C_STATE_LEVEL, l_module, 'Segment Number for the USSGL segment is : ' || l_nat_acct_seg_num);
      END IF;

     ---Assign the natural account segment value of the transaction type Rev acc to
     -- the ccid for the reimbursable agreement
     l_agreement_rev_segments(l_nat_acct_seg_num) :=  l_rev_nat_acc_tt;
Begin
   l_concat_segs:=  fnd_flex_ext.concatenate_segments(n_segments     =>l_num_segments,
                                segments       =>l_agreement_rev_segments,
                                delimiter      =>'.');


      log(C_STATE_LEVEL, l_module, 'Concatenated Segments: ' || l_concat_segs);
--STEP 3 Check of ccid exists for the new concatenated segments, else Create new ccid

    SELECT code_combination_id
    INTO   l_ccid
    FROM   gl_code_combinations_kfv
    WHERE  chart_of_accounts_id = g_coa_id
    AND concatenated_segments = l_concat_segs;
    log(C_STATE_LEVEL, l_module, 'CCID already existing: ' || l_ccid);

EXCEPTION
when no_data_found then
   l_ccid:=fnd_flex_ext.get_ccid( APPLICATION_SHORT_NAME  => 'SQLGL',
                     KEY_FLEX_CODE           => 'GL#',
                     STRUCTURE_NUMBER        => g_coa_id,
                     validation_date         => SYSDATE,
                     concatenated_segments   =>l_concat_segs);
   log(C_STATE_LEVEL, l_module, 'CCID created new: ' || l_ccid);

   IF l_ccid = 0 THEN
          log(C_STATE_LEVEL, l_module, l_module||'ERROR: Could not create ccid.');
          g_errbuf :=  l_module||'ERROR: Could not create ccid.';
          g_retcode := 2;
          RETURN l_ccid;
       END IF;
       log(C_STATE_LEVEL, l_module, 'Returning ccid: '||l_ccid);
       RETURN l_ccid;
END;

    log(C_STATE_LEVEL, l_module, 'Returning ccid: '||l_ccid);
    RETURN l_ccid;

END get_ccid;
-------------------------------------------------------------------------------
PROCEDURE create_header(p_trx_type IN VARCHAR2) IS

l_module VARCHAR2(100) := g_module_name||'create_header';
BEGIN

  log(C_STATE_LEVEL, l_module, 'In :'||l_module);
  log(C_STATE_LEVEL, l_module, 'Trx Type: '||p_trx_type);

  IF (p_trx_type = 'COLL' AND g_coll_hdr_tbl.COUNT = 0) THEN


     SELECT fv_gen_ar_trx_s.nextval
     INTO   g_trx_coll_hdr_id
     FROM DUAL;

     g_coll_hdr_tbl(1).trx_header_id := g_trx_coll_hdr_id;
-- Use the prefix defined for Liquidate Advance in the
-- define Federal options Form. FV_OPERATING_UNITS_ALL

     SELECT g_liq_adv_prefix||fv_gen_coll_ar_trx_s.nextval
     INTO   g_coll_hdr_tbl(1).trx_number
     FROM DUAL;

     fv_utility.log_mesg('Ar Transaction: '||g_coll_hdr_tbl(1).trx_number);

--Transaction type defined for Liquidate Advance in the
--define Federal options Form. FV_OPERATING_UNITS_ALL

     g_coll_hdr_tbl(1).cust_trx_type_id :=g_liq_adv_trx_type_id;
     g_coll_hdr_tbl(1).trx_date := g_invoice_date;
     g_coll_hdr_tbl(1).bill_to_customer_id := g_customer_id;
     g_coll_hdr_tbl(1).gl_date  := g_invoice_date;
     g_coll_hdr_tbl(1).trx_currency := g_currency;

  END IF;

  IF (p_trx_type = 'REC' AND g_rec_hdr_tbl.COUNT = 0) THEN

     SELECT fv_gen_ar_trx_s.nextval
     INTO   g_trx_rec_hdr_id
     FROM DUAL;

     g_rec_hdr_tbl(1).trx_header_id := g_trx_rec_hdr_id;

--Use the prefix defined for Receivables Due in the
--define Federal options Form. FV_OPERATING_UNITS_ALL

     SELECT g_rec_due_prefix||fv_gen_rec_ar_trx_s.nextval
     INTO   g_rec_hdr_tbl(1).trx_number
     FROM DUAL;

     fv_utility.log_mesg('Ar Transaction: '||g_rec_hdr_tbl(1).trx_number);

--Transaction type defined for Receivables Due in the
--define Federal options Form. FV_OPERATING_UNITS_ALL

--The trx_date and gl_date to be that of the parameter invoice_date passed as parameter

     g_rec_hdr_tbl(1).cust_trx_type_id := g_rec_due_trx_type_id; --3896; --Reimb Earned - Rec
     g_rec_hdr_tbl(1).trx_date := g_invoice_date;
     g_rec_hdr_tbl(1).bill_to_customer_id := g_customer_id;
     g_rec_hdr_tbl(1).gl_date  := g_invoice_date;
     g_rec_hdr_tbl(1).trx_currency := g_currency;
     g_rec_hdr_tbl(1).primary_salesrep_id := -3;
  END IF;
 EXCEPTION
  WHEN OTHERS THEN
     log(C_STATE_LEVEL, l_module, 'When others error in'||l_module||': '||sqlerrm);
     g_errbuf := 'When others error in'||l_module||': '||sqlerrm ;
     g_retcode := sqlcode;
END create_header;
-------------------------------------------------------------------------------
PROCEDURE create_line_dist(p_trx_type IN VARCHAR2,
                           p_amount   IN NUMBER,
                           p_agreement IN VARCHAR2) IS
BEGIN

  IF p_trx_type = 'COLL' THEN
    i := i+1;

    g_coll_lines_tbl(i).trx_header_id := g_trx_coll_hdr_id;

    SELECT ra_customer_trx_lines_s.nextval
    INTO   g_coll_lines_tbl(i).trx_line_id
    FROM DUAL;

    g_coll_lines_tbl(i).line_number := i;
    g_coll_lines_tbl(i).quantity_invoiced := p_amount;
    g_coll_lines_tbl(i).unit_selling_price := 1;
    g_coll_lines_tbl(i).description := 'Generate Receivable for Reimbursable Related Expense - Liquidate Advance';
    g_coll_lines_tbl(i).line_type := 'LINE';
    g_coll_lines_tbl(i).uom_code := 'EA';


    --Create distribution
    g_coll_dist_tbl(i).trx_line_id := g_coll_lines_tbl(i).trx_line_id;
    g_coll_dist_tbl(i).trx_header_id := g_coll_lines_tbl(i).trx_header_id;

    SELECT ra_cust_trx_line_gl_dist_s.nextval
    INTO   g_coll_dist_tbl(i).trx_dist_id
    FROM DUAL;

    g_coll_dist_tbl(i).account_class := 'REV';
    g_coll_dist_tbl(i).code_combination_id :=
                   get_ccid(p_agreement,
                            g_liq_adv_trx_type_id);

                     IF g_retcode <> 0 THEN
                        RETURN;
                     END IF;

    g_coll_dist_tbl(i).amount := p_amount;
  END IF;

  IF p_trx_type = 'REC' THEN
    j := j+1;

    g_rec_lines_tbl(j).trx_header_id := g_trx_rec_hdr_id;

    SELECT ra_customer_trx_lines_s.nextval
    INTO   g_rec_lines_tbl(j).trx_line_id
    FROM DUAL;


    g_rec_lines_tbl(j).line_number := j;
	--bug 8903169
    /*g_rec_lines_tbl(j).quantity_invoiced := p_amount;
    g_rec_lines_tbl(j).unit_selling_price := 1;*/
	g_rec_lines_tbl(j).quantity_invoiced := 1;
    g_rec_lines_tbl(j).unit_selling_price := p_amount;
	--End of bug 8903169
    g_rec_lines_tbl(j).description := 'Generate Receivable for Reimbursable Related Expense - Receivable Due';
    g_rec_lines_tbl(j).line_type := 'LINE';
    g_rec_lines_tbl(j).uom_code := 'EA';


    --Create distribution
    g_rec_dist_tbl(j).trx_line_id := g_rec_lines_tbl(j).trx_line_id;
    g_rec_dist_tbl(j).trx_header_id := g_rec_lines_tbl(j).trx_header_id;

    SELECT ra_cust_trx_line_gl_dist_s.nextval
    INTO   g_rec_dist_tbl(j).trx_dist_id
    FROM DUAL;

--We need to get the ccid for the Revenue line of the reimbursable Agreement
--Replace the natural Account with the NAcc in the Transaction Type defined

    g_rec_dist_tbl(j).account_class := 'REV';
    g_rec_dist_tbl(j).code_combination_id :=
                   get_ccid(p_agreement,
                            g_rec_due_trx_type_id);

                     IF g_retcode <> 0 THEN
                        RETURN;
                     END IF;

    g_rec_dist_tbl(j).amount := p_amount;
  END IF;

END create_line_dist;
-------------------------------------------------------------------------------
PROCEDURE print_header IS
l_head VARCHAR2(100);

BEGIN

 fnd_file.put_line(fnd_file.output,'Date: '||g_invoice_date);
 fnd_file.put_line(fnd_file.output,' ');
 fnd_file.put_line(fnd_file.output,' ');
 l_head := '          Generate Receivables for Reimbursable Related Expenses Report';
 fnd_file.put_line(fnd_file.output,l_head);
 fnd_file.put_line(fnd_file.output,' ');
 fnd_file.put_line(fnd_file.output,' ');
 fnd_file.put_line(fnd_file.output,
 'Customer                                Transaction          Transaction          Reimbursable         Amount     Terms            ');
 fnd_file.put_line(fnd_file.output,
 '                                        Number               Type                 Agreement                                        ');
 fnd_file.put_line(fnd_file.output,
 '---------                               ------------         ------------         -------------        -------    ------           ');

 fnd_file.put_line(fnd_file.output,' ');
END;
-------------------------------------------------------------------------------
PROCEDURE print_line(p_customer_name IN VARCHAR2,
                     p_trx_num IN VARCHAR2,
                     p_trx_type IN VARCHAR2,
                     p_reimb_agree_num IN VARCHAR2,
                     p_amt IN NUMBER,
                     p_terms IN VARCHAR2) IS
BEGIN

fnd_file.put_line(fnd_file.output, rpad(p_customer_name,39)||' '||rpad(p_trx_num,20)||' '||rpad(p_trx_type,20)||' '||rpad(p_reimb_agree_num,20)||
                  ' '||rpad(p_amt,10)||' '||rpad(p_terms,15));


END;
-------------------------------------------------------------------------------
END fv_gen_artrx_reimb_proc;

/
