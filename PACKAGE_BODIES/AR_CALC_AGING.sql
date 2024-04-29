--------------------------------------------------------
--  DDL for Package Body AR_CALC_AGING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CALC_AGING" AS
/* $Header: ARRECONB.pls 120.22.12010000.3 2009/10/07 00:02:59 rmanikan ship $ */
/*-------------------------------------------------------------
 PRIVATE variables
---------------------------------------------------------------*/

company_segment_where    VARCHAR2(500)  := NULL;
br_enabled_flag          VARCHAR2(1)    := NULL;
l_gl_dist_table          VARCHAR2(50)   := NULL;
l_ps_table               VARCHAR2(50)   := NULL;
l_trx_table              VARCHAR2(50)   := NULL;
l_line_table             VARCHAR2(50)   := NULL;
l_ra_table               VARCHAR2(50)   := NULL;
l_ard_table              VARCHAR2(50)   := NULL;
l_adj_table              VARCHAR2(50)   := NULL;
l_cr_table               VARCHAR2(50)   := NULL;
l_ps_org_where           VARCHAR2(2000) := NULL;
l_gl_dist_org_where      VARCHAR2(2000) := NULL;
l_trx_org_where          VARCHAR2(2000) := NULL;
l_line_org_where         VARCHAR2(2000) := NULL;
l_ra_org_where           VARCHAR2(2000) := NULL;
l_ard_org_where          VARCHAR2(2000) := NULL;
l_ard1_org_where         VARCHAR2(2000) := NULL;
l_ath_org_where          VARCHAR2(2000) := NULL;
l_adj_org_where          VARCHAR2(2000) := NULL;
l_cr_org_where           VARCHAR2(2000) := NULL;

PROCEDURE build_parameters(p_reporting_level          IN  VARCHAR2,
                           p_reporting_entity_id      IN  NUMBER,
                           p_co_seg_low               IN VARCHAR2,
                           p_co_seg_high              IN VARCHAR2,
                           p_coa_id                   IN NUMBER)
IS
BEGIN

 ar_calc_aging.g_reporting_entity_id   := p_reporting_entity_id;

 IF NVL(ar_calc_aging.ca_sob_type,'P') = 'P' THEN
     l_ps_table      := 'ar_payment_schedules_all ';
     l_ra_table      := 'ar_receivable_applications_all ';
     l_adj_table     := 'ar_adjustments_all ';
     l_ard_table     := 'ar_distributions_all ';
     l_gl_dist_table := 'ra_cust_trx_line_gl_dist_all ';
     l_line_table    := 'ra_customer_trx_lines_all ';
     l_trx_table     := 'ra_customer_trx_all ';
     l_cr_table      := 'ar_cash_receipts_all ';
  ELSE
     l_ps_table      := 'ar_payment_schedules_all_mrc_v ';
     l_ra_table      := 'ar_receivable_apps_all_mrc_v ';
     l_adj_table     := 'ar_adjustments_all_mrc_v ';
     l_ard_table     := 'ar_distributions_all_mrc_v ';
     l_gl_dist_table := 'ra_trx_line_gl_dist_all_mrc_v ';
     l_line_table    := 'ra_cust_trx_ln_all_mrc_v ';
     l_trx_table     := 'ra_customer_trx_all_mrc_v ';
     l_cr_table      := 'ar_cash_receipts_all_mrc_v ';
  END IF;

  XLA_MO_REPORTING_API.Initialize(p_reporting_level, p_reporting_entity_id, 'AUTO');

  l_ps_org_where     := XLA_MO_REPORTING_API.Get_Predicate('ps',null);
  l_gl_dist_org_where:= XLA_MO_REPORTING_API.Get_Predicate('gl_dist', null);
  l_trx_org_where    := XLA_MO_REPORTING_API.Get_Predicate('trx', null);
  l_line_org_where   := XLA_MO_REPORTING_API.Get_Predicate('lines',null);
  l_ra_org_where     := XLA_MO_REPORTING_API.Get_Predicate('ra' , null);
  l_ard_org_where    := XLA_MO_REPORTING_API.Get_Predicate('ard',null);
  l_ard1_org_where   := XLA_MO_REPORTING_API.Get_Predicate('ard1',null);
  l_ath_org_where    := XLA_MO_REPORTING_API.Get_Predicate('ath' ,null);
  l_adj_org_where    := XLA_MO_REPORTING_API.Get_Predicate('adj' ,null);
  l_cr_org_where     := XLA_MO_REPORTING_API.Get_Predicate('cr' ,null);

  /* Replace the variables to bind with the function calls so that we don't have to bind those */
  l_ps_org_where     := replace(l_ps_org_where,
                                  ':p_reporting_entity_id','ar_calc_aging.get_reporting_entity_id()');
  l_gl_dist_org_where:= replace(l_gl_dist_org_where,
                                  ':p_reporting_entity_id','ar_calc_aging.get_reporting_entity_id()');
  l_trx_org_where    := replace(l_trx_org_where,
                                  ':p_reporting_entity_id','ar_calc_aging.get_reporting_entity_id()');
  l_line_org_where   := replace(l_line_org_where,
                                  ':p_reporting_entity_id','ar_calc_aging.get_reporting_entity_id()');
  l_ra_org_where     := replace(l_ra_org_where,
                                  ':p_reporting_entity_id','ar_calc_aging.get_reporting_entity_id()');
  l_ard_org_where    := replace(l_ard_org_where,
                                  ':p_reporting_entity_id','ar_calc_aging.get_reporting_entity_id()');
  l_ard1_org_where   := replace(l_ard1_org_where,
                                  ':p_reporting_entity_id','ar_calc_aging.get_reporting_entity_id()');
  l_ath_org_where    := replace(l_ath_org_where,
                                  ':p_reporting_entity_id','ar_calc_aging.get_reporting_entity_id()');
  l_adj_org_where    := replace(l_adj_org_where,
                                  ':p_reporting_entity_id','ar_calc_aging.get_reporting_entity_id()');
  l_cr_org_where     := replace(l_cr_org_where,
                                  ':p_reporting_entity_id','ar_calc_aging.get_reporting_entity_id()');

  IF company_segment_where IS NULL THEN
     IF p_co_seg_low IS NULL AND p_co_seg_high IS NULL THEN
        company_segment_where := NULL;
     ELSIF p_co_seg_low IS NULL THEN
        company_segment_where := ' AND ' ||
               ar_calc_aging.FLEX_SQL(p_application_id => 101,
                               p_id_flex_code => 'GL#',
                               p_id_flex_num =>p_coa_id,
                               p_table_alias => 'GC',
                               p_mode => 'WHERE',
                               p_qualifier => 'GL_BALANCING',
                               p_function => '<=',
                               p_operand1 => p_co_seg_high);
     ELSIF p_co_seg_high IS NULL THEN
        company_segment_where := ' AND ' ||
               ar_calc_aging.FLEX_SQL(p_application_id => 101,
                               p_id_flex_code => 'GL#',
                               p_id_flex_num => p_coa_id,
                               p_table_alias => 'GC',
                               p_mode => 'WHERE',
                               p_qualifier => 'GL_BALANCING',
                               p_function => '>=',
                               p_operand1 => p_co_seg_low);
    ELSE
        company_segment_where := ' AND ' ||
               ar_calc_aging.FLEX_SQL(p_application_id => 101,
                               p_id_flex_code => 'GL#',
                               p_id_flex_num =>p_coa_id,
                               p_table_alias => 'GC',
                               p_mode => 'WHERE',
                               p_qualifier => 'GL_BALANCING',
                               p_function => 'BETWEEN',
                               p_operand1 => p_co_seg_low,
                               p_operand2 => p_co_seg_high);
    END IF;

  END IF;

END build_parameters;

/*========================================================================+
 Function which returns the global variable g_reporting_entity_id
 ========================================================================*/

FUNCTION get_reporting_entity_id return NUMBER is
BEGIN
    return ar_calc_aging.g_reporting_entity_id;
END get_reporting_entity_id;


/*========================================================================+
   Wrapper procedures for the APIS available in FA_RX_FLEX_SQL package
   When patch 4128137 is released, we need to replace this call with the
   corresponding FND API calls
 ========================================================================*/
FUNCTION flex_sql(
        p_application_id in number,
        p_id_flex_code in varchar2,
        p_id_flex_num in number default null,
        p_table_alias in varchar2,
        p_mode in varchar2,
        p_qualifier in varchar2,
        p_function in varchar2 default null,
        p_operand1 in varchar2 default null,
        p_operand2 in varchar2 default null) return varchar2 IS

l_ret_param varchar2(2000);

BEGIN

        /* This is a wrapper function for the fa_rx_flex_pkg.flex_sql
           When patch 4128137 is released, we need to replace this call with the corresponding
           FND API calls */

         l_ret_param := fa_rx_flex_pkg.flex_sql(
                                                p_application_id   => p_application_id,
                                                p_id_flex_code     => p_id_flex_code,
                                                p_id_flex_num      => p_id_flex_num,
                                                p_table_alias      => p_table_alias,
                                                p_mode             => p_mode,
                                                p_qualifier        => p_qualifier,
                                                p_function         => p_function,
                                                p_operand1         => p_operand1,
                                                p_operand2         => p_operand2);

         return l_ret_param;

END flex_sql;


FUNCTION get_value(
        p_application_id in number,
        p_id_flex_code in varchar2,
        p_id_flex_num in number default NULL,
        p_qualifier in varchar2,
        p_ccid in number) return varchar2 IS

l_value  varchar2(2000);

BEGIN
         /* This is a wrapper function for the fa_rx_flex_pkg.get_value
           When patch 4128137 is released, we need to replace this call with the corresponding
           FND API calls */

         l_value := fa_rx_flex_pkg.get_value (
                                              p_application_id => p_application_id,
                                              p_id_flex_code   => p_id_flex_code,
                                              p_id_flex_num    => p_id_flex_num,
                                              p_qualifier      => p_qualifier,
                                              p_ccid           => p_ccid);

         return l_value;

END get_value;

FUNCTION get_description(
        p_application_id in number,
        p_id_flex_code in varchar2,
        p_id_flex_num in number default NULL,
        p_qualifier in varchar2,
        p_data in varchar2) return varchar2 IS

l_description varchar2(2000);
l_account     varchar2(30);

BEGIN
         /* This is a wrapper function for the fa_rx_flex_pkg.get_description
           When patch 4128137 is released, we need to replace this call with the corresponding
           FND API calls */

         l_account     :=  get_value(p_application_id => p_application_id,
                                              p_id_flex_code   => p_id_flex_code,
                                              p_id_flex_num    => p_id_flex_num,
                                              p_qualifier      => p_qualifier,
                                              p_ccid           => p_data);

         l_description := fa_rx_flex_pkg.get_description(
                                                         p_application_id => p_application_id,
                                                         p_id_flex_code   => p_id_flex_code,
                                                         p_id_flex_num    => p_id_flex_num,
                                                         p_qualifier      => p_qualifier,
                                                         p_data           => l_account);

         return l_description;

END get_description;


PROCEDURE initialize
IS
    l_profile_rsob_id NUMBER := NULL;
    l_client_info_rsob_id NUMBER := NULL;
BEGIN
    --Bug 4928220
    ar_calc_aging.ca_sob_type := 'P';

 END;

/*-------------------------------------------------------------
PUBLIC PROCEDURE aging
---------------------------------------------------------------*/
PROCEDURE aging_as_of(
                      p_as_of_date_from          IN  DATE,
                      p_as_of_date_to            IN  DATE,
                      p_reporting_level          IN  VARCHAR2,
                      p_reporting_entity_id      IN  NUMBER,
                      p_co_seg_low               IN  VARCHAR2,
                      p_co_seg_high              IN  VARCHAR2,
                      p_coa_id                   IN  NUMBER,
                      p_begin_bal                OUT NOCOPY NUMBER,
                      p_end_bal                  OUT NOCOPY NUMBER,
                      p_acctd_begin_bal          OUT NOCOPY NUMBER,
                      p_acctd_end_bal            OUT NOCOPY NUMBER) IS
 l_ps_select                VARCHAR2(5000);
 l_ra_select                VARCHAR2(5000);
 l_cm_ra_select             VARCHAR2(5000);
 l_adj_select               VARCHAR2(5000);
 l_cancel_br_select         VARCHAR2(5000);
 l_trx_main_select          VARCHAR2(32000);
 l_br_select                VARCHAR2(5000);
 l_br_app_select            VARCHAR2(5000);
 l_br_adj_select            VARCHAR2(5000);
 l_br_main_select           VARCHAR2(32000);
 l_unapp_select             VARCHAR2(5000);
 l_main_select              VARCHAR2(32000);
 v_cursor                   NUMBER;
 l_ignore                   INTEGER;
 l_customer_trx_id          NUMBER;

BEGIN

  COMMIT;
  SET TRANSACTION READ ONLY;

  build_parameters (p_reporting_level,
                    p_reporting_entity_id,
                    p_co_seg_low,
                    p_co_seg_high,
                    p_coa_id);

  l_ps_select := 'SELECT ps.customer_trx_id ,
                         sum(ar_calc_aging.begin_or_end_bal(ps.gl_date,ps.gl_date_closed,
                                                            NULL,:p_as_of_date_from)
                             *  ps.amount_due_remaining) start_bal,
                         sum(ar_calc_aging.begin_or_end_bal(ps.gl_date,ps.gl_date_closed,
                                                            NULL,:p_as_of_date_to)
                             *  ps.amount_due_remaining) end_bal,
                         sum(ar_calc_aging.begin_or_end_bal(ps.gl_date,ps.gl_date_closed,
                                                            NULL,:p_as_of_date_from)
                             *  ps.acctd_amount_due_remaining) acctd_start_bal,
                         sum(ar_calc_aging.begin_or_end_bal(ps.gl_date,ps.gl_date_closed,
                                                            NULL,:p_as_of_date_to)
                             *  ps.acctd_amount_due_remaining) acctd_end_bal
                  FROM '||l_ps_table||'  ps
                  WHERE ps.payment_schedule_id+0 > 0
                  AND   ps.gl_date_closed  >= :p_as_of_date_from
                  AND   ps.class IN ( ''CB'', ''CM'',''DEP'',''DM'',''GUAR'',''INV'')
                  AND   ps.gl_date  <= :p_as_of_date_to
                  '|| l_ps_org_where ||'
                  GROUP BY ps.customer_trx_id ' ;

  l_ra_select := 'SELECT
                         ps.customer_trx_id ,
                         sum(ar_calc_aging.begin_or_end_bal(ps.gl_date,ps.gl_date_closed,
                                                            ra.gl_date,:p_as_of_date_from)
                             * ( ra.amount_applied  + NVL(ra.earned_discount_taken,0)
                                 + NVL(ra.unearned_discount_taken,0))) start_bal,
                         sum(ar_calc_aging.begin_or_end_bal(ps.gl_date,ps.gl_date_closed,
                                                            ra.gl_date,:p_as_of_date_to)
                             * ( ra.amount_applied  + NVL(ra.earned_discount_taken,0)
                                 + NVL(ra.unearned_discount_taken,0))) end_bal,
                         sum(ar_calc_aging.begin_or_end_bal(ps.gl_date,ps.gl_date_closed,
                                                            ra.gl_date,:p_as_of_date_from)
                             * (ra.acctd_amount_applied_to +
                                 NVL(ra.acctd_earned_discount_taken,0)
                                 + NVL(ra.acctd_unearned_discount_taken,0)))  acctd_start_bal,
                         sum(ar_calc_aging.begin_or_end_bal(ps.gl_date,ps.gl_date_closed,
                                                            ra.gl_date,:p_as_of_date_to)
                             * (ra.acctd_amount_applied_to +
                                 NVL(ra.acctd_earned_discount_taken,0)
                                 + NVL(ra.acctd_unearned_discount_taken,0)))  acctd_end_bal
                 FROM '|| l_ps_table ||' ps,
                      '|| l_ra_table ||' ra
                WHERE  ra.applied_payment_schedule_id = ps.payment_schedule_id
                  AND  ps.payment_schedule_id+0 > 0
                  AND  ps.gl_date_closed  >= :p_as_of_date_from
                  AND  ps.class IN ( ''CB'', ''CM'',''DEP'',''DM'',''GUAR'',''INV'')
                  AND  ra.gl_date > :p_as_of_date_from
                  AND  ra.status = ''APP''
                  AND  ps.gl_date <= :p_as_of_date_to
                  AND  NVL(ra.confirmed_flag,''Y'') = ''Y''
                  '|| l_ps_org_where||'
                  '|| l_ra_org_where||'
               GROUP BY ps.customer_trx_id ';

  l_cm_ra_select := 'SELECT
                         ps.customer_trx_id ,
                         sum(ar_calc_aging.begin_or_end_bal(ps.gl_date,ps.gl_date_closed,
                                                            ra.gl_date,:p_as_of_date_from)
                             * -1
                             * ( ra.amount_applied  + NVL(ra.earned_discount_taken,0)
                                 + NVL(ra.unearned_discount_taken,0))) start_bal,
                         sum(ar_calc_aging.begin_or_end_bal(ps.gl_date,ps.gl_date_closed,
                                                            ra.gl_date,:p_as_of_date_to)
                             * -1
                             * ( ra.amount_applied  + NVL(ra.earned_discount_taken,0)
                                 + NVL(ra.unearned_discount_taken,0))) end_bal,
                         sum(ar_calc_aging.begin_or_end_bal(ps.gl_date,ps.gl_date_closed,
                                                            ra.gl_date,:p_as_of_date_from)
                             * -1
                             * ra.acctd_amount_applied_from )  acctd_start_bal,
                         sum(ar_calc_aging.begin_or_end_bal(ps.gl_date,ps.gl_date_closed,
                                                            ra.gl_date,:p_as_of_date_to)
                             * -1
                             * ra.acctd_amount_applied_from ) acctd_end_bal
                 FROM '|| l_ps_table ||' ps,
                      '|| l_ra_table ||' ra
                  WHERE ra.payment_schedule_id = ps.payment_schedule_id
                  AND  ps.payment_schedule_id+0 > 0
                  AND  ps.gl_date_closed  >= :p_as_of_date_from
                  AND  ps.class  = ''CM''
                  AND  ra.gl_date > :p_as_of_date_from
                  AND  ra.status IN (''APP'',''ACTIVITY'') --bug 5290086
                  AND  ra.application_type = ''CM''
                  AND  ps.gl_date <= :p_as_of_date_to
                  AND  NVL(ra.confirmed_flag,''Y'') = ''Y''
                  '|| l_ps_org_where||'
                  '|| l_ra_org_where||'
               GROUP BY ps.customer_trx_id ';

  l_adj_select := 'SELECT ps.customer_trx_id,
                          -sum(ar_calc_aging.begin_or_end_bal(ps.gl_date,ps.gl_date_closed,
                                                                  adj.gl_date,:p_as_of_date_from)
                             *   adj.amount)  start_bal,
                          -sum(ar_calc_aging.begin_or_end_bal(ps.gl_date,ps.gl_date_closed,
                                                                  adj.gl_date,:p_as_of_date_to)
                             *   adj.amount)  end_bal  ,
                          -sum(ar_calc_aging.begin_or_end_bal(ps.gl_date,ps.gl_date_closed,
                                                                  adj.gl_date,:p_as_of_date_from)
                             *   adj.acctd_amount)  acctd_start_bal,
                          -sum(ar_calc_aging.begin_or_end_bal(ps.gl_date,ps.gl_date_closed,
                                                                  adj.gl_date,:p_as_of_date_to)
                             *   adj.acctd_amount) acctd_end_bal
                    FROM  '||l_adj_table||' adj ,'
                           ||l_ps_table ||' ps
                    WHERE ps.payment_schedule_id + 0 > 0
                    AND   ps.gl_date_closed  >= :p_as_of_date_from
                    AND   ps.class IN ( ''CB'', ''CM'',''DEP'',''DM'',''GUAR'',''INV'')
                    AND   ps.gl_date  <= :p_as_of_date_to
                    AND   adj.payment_schedule_id = ps.payment_schedule_id
                    AND   adj.gl_date > :p_as_of_date_from
                    AND   adj.status = ''A''
                    '|| l_adj_org_where||'
                    '|| l_ps_org_where|| '
                    GROUP BY ps.customer_trx_id ';

  IF p_co_seg_low IS NOT NULL OR p_co_seg_high IS NOT NULL THEN
      l_cancel_br_select :=  'SELECT
                               sum(ar_calc_aging.begin_or_end_bal(ps.gl_date,ps.gl_date_closed,
                                                            ath.gl_date,:p_as_of_date_from)
                               * decode(nvl(ard.amount_cr,0), 0, nvl(ard.amount_dr,0),
                                             (ard.amount_cr * -1))) start_bal,
                               sum(ar_calc_aging.begin_or_end_bal(ps.gl_date,ps.gl_date_closed,
                                                            ath.gl_date,:p_as_of_date_to)
                               * decode(nvl(ard.amount_cr,0), 0, nvl(ard.amount_dr,0),
                                             (ard.amount_cr * -1))) end_bal,
                               sum(ar_calc_aging.begin_or_end_bal(ps.gl_date,ps.gl_date_closed,
                                                            ath.gl_date,:p_as_of_date_from)
                               * decode(nvl(ard.acctd_amount_cr,0), 0, nvl(ard.acctd_amount_dr,0),
                                            (ard.acctd_amount_cr * -1))) acctd_start_bal,
                               sum(ar_calc_aging.begin_or_end_bal(ps.gl_date,ps.gl_date_closed,
                                                            ath.gl_date,:p_as_of_date_to)
                               * decode(nvl(ard.acctd_amount_cr,0), 0, nvl(ard.acctd_amount_dr,0),
                                            (ard.acctd_amount_cr * -1))) acctd_end_bal
                       FROM '||l_ps_table||' ps,
                            '||l_ard_table || ' ard,
                            '||'ar_transaction_history_all ath,
                            '||l_line_table|| ' lines,
                             gl_code_combinations gc
                       WHERE ps.payment_schedule_id+0 > 0
                       AND  ps.gl_date_closed  >= :p_as_of_date_from
                       AND  ps.class IN ( ''BR'',''CB'', ''CM'',''DEP'',''DM'',''GUAR'',''INV'')
                       AND  ath.gl_date > :p_as_of_date_from
                       AND  ath.event = ''CANCELLED''
                       AND  ps.gl_date <= :p_as_of_date_to
                       AND  ps.customer_trx_id = ath.customer_trx_id
                       AND  ard.source_table = ''TH''
                       AND  ard.source_id = ath.transaction_history_id
                       AND  ps.customer_trx_id = lines.customer_trx_id
                       AND  ard.source_id_secondary = lines.customer_trx_line_id
                       AND  ard.code_combination_id = gc.code_combination_id
                       ' || l_ps_org_where ||'
                       ' || l_ard_org_where||'
                       ' || l_ath_org_where||'
                       ' || l_line_org_where ||'
                       ' || company_segment_where;
     ELSE
      l_cancel_br_select :=  'SELECT
                               sum(ar_calc_aging.begin_or_end_bal(ps.gl_date,ps.gl_date_closed,
                                                            ath.gl_date,:p_as_of_date_from)
                               * decode(nvl(ard.amount_cr,0), 0, nvl(ard.amount_dr,0),
                                             (ard.amount_cr * -1))) start_bal,
                               sum(ar_calc_aging.begin_or_end_bal(ps.gl_date,ps.gl_date_closed,
                                                            ath.gl_date,:p_as_of_date_to)
                               * decode(nvl(ard.amount_cr,0), 0, nvl(ard.amount_dr,0),
                                             (ard.amount_cr * -1))) end_bal,
                               sum(ar_calc_aging.begin_or_end_bal(ps.gl_date,ps.gl_date_closed,
                                                            ath.gl_date,:p_as_of_date_from)
                               * decode(nvl(ard.acctd_amount_cr,0), 0, nvl(ard.acctd_amount_dr,0),
                                            (ard.acctd_amount_cr * -1))) acctd_start_bal,
                               sum(ar_calc_aging.begin_or_end_bal(ps.gl_date,ps.gl_date_closed,
                                                            ath.gl_date,:p_as_of_date_to)
                               * decode(nvl(ard.acctd_amount_cr,0), 0, nvl(ard.acctd_amount_dr,0),
                                            (ard.acctd_amount_cr * -1))) acctd_end_bal
                       FROM '||l_ps_table||' ps,
                            '||l_ard_table || ' ard,
                            '||'ar_transaction_history_all ath,
                            '||l_line_table|| ' lines
                       WHERE ps.payment_schedule_id+0 > 0
                       AND  ps.gl_date_closed  >= :p_as_of_date_from
                       AND  ps.class IN ( ''BR'',''CB'', ''CM'',''DEP'',''DM'',''GUAR'',''INV'')
                       AND  ath.gl_date > :p_as_of_date_from
                       AND  ath.event = ''CANCELLED''
                       AND  ps.gl_date <= :p_as_of_date_to
                       AND  ps.customer_trx_id = ath.customer_trx_id
                       AND  ard.source_table = ''TH''
                       AND  ard.source_id = ath.transaction_history_id
                       AND  ps.customer_trx_id = lines.customer_trx_id
                       AND  ard.source_id_secondary = lines.customer_trx_line_id
                       ' || l_ps_org_where ||'
                       ' || l_ard_org_where||'
                       ' || l_ath_org_where||'
                       ' || l_line_org_where;
  END IF;

  l_br_select :=    ' SELECT ps.customer_trx_id ,
                             sum(ar_calc_aging.begin_or_end_bal(gl_date,gl_date_closed,
                                                                NULL,:p_as_of_date_from)
                               *  ps.amount_due_remaining) start_bal,
                             sum(ar_calc_aging.begin_or_end_bal(gl_date,gl_date_closed,
                                                                NULL,:p_as_of_date_to)
                               *  ps.amount_due_remaining) end_bal,
                             sum(ar_calc_aging.begin_or_end_bal(gl_date,gl_date_closed,
                                                                NULL,:p_as_of_date_from)
                               *  ps.acctd_amount_due_remaining) acctd_start_bal,
                             sum(ar_calc_aging.begin_or_end_bal(gl_date,gl_date_closed,
                                                                NULL,:p_as_of_date_to)
                               *  ps.acctd_amount_due_remaining) acctd_end_bal
                       FROM  '||l_ps_table||' ps
                       WHERE ps.payment_schedule_id+0 > 0
                       AND   ps.class  = ''BR''
                       AND   ps.gl_date        <= :p_as_of_date_to
                       AND   ps.gl_date_closed  >= :p_as_of_date_from
                       '||   l_ps_org_where ||'
                       GROUP BY ps.customer_trx_id ';

  l_br_app_select :=  ' SELECT
                              ps.customer_trx_id ,
                              sum(ar_calc_aging.begin_or_end_bal(ps.gl_date,ps.gl_date_closed,
                                                                  ra.gl_date,:p_as_of_date_from)
                                *(ra.amount_applied  + NVL(ra.earned_discount_taken,0)
                                       + NVL(ra.unearned_discount_taken,0))) start_bal,
                              sum(ar_calc_aging.begin_or_end_bal(ps.gl_date,ps.gl_date_closed,
                                                                   ra.gl_date,:p_as_of_date_to)
                                *(ra.amount_applied  + NVL(ra.earned_discount_taken,0)
                                       + NVL(ra.unearned_discount_taken,0))) end_bal,
                              sum(ar_calc_aging.begin_or_end_bal(ps.gl_date,ps.gl_date_closed,
                                                                   ra.gl_date,:p_as_of_date_from)
                                *(ra.acctd_amount_applied_to + NVL(ra.acctd_earned_discount_taken,0)
                                        + NVL(ra.acctd_unearned_discount_taken,0))) acctd_start_bal,
                              sum(ar_calc_aging.begin_or_end_bal(ps.gl_date,ps.gl_date_closed,
                                                                   ra.gl_date,:p_as_of_date_to)
                                *(ra.acctd_amount_applied_to + NVL(ra.acctd_earned_discount_taken,0)
                                        + NVL(ra.acctd_unearned_discount_taken,0))) acctd_end_bal
                         FROM '|| l_ps_table||' ps,
                            '|| l_ra_table||' ra
                         WHERE ra.applied_payment_schedule_id = ps.payment_schedule_id
                          AND  ps.payment_schedule_id+0 > 0
                          AND  ps.class  =''BR''
                          AND  ra.gl_date > :p_as_of_date_from
                          AND  ra.status = ''APP''
                          AND  ps.gl_date <= :p_as_of_date_to
                          AND  ps.gl_date_closed  >= :p_as_of_date_from
                          AND  NVL(ra.confirmed_flag,''Y'') = ''Y''
                          '||  l_ps_org_where ||'
                          '||  l_ra_org_where ||'
                        GROUP by ps.customer_trx_id ';

  l_br_adj_select:=  ' SELECT ps.customer_trx_id,
                         -sum(ar_calc_aging.begin_or_end_bal(ps.gl_date,ps.gl_date_closed,
                                                                   adj.gl_date,:p_as_of_date_from)
                                * adj.amount) start_bal,
                         -sum(ar_calc_aging.begin_or_end_bal(ps.gl_date,ps.gl_date_closed,
                                                                   adj.gl_date,:p_as_of_date_to)
                                * adj.amount) end_bal,
                         -sum(ar_calc_aging.begin_or_end_bal(ps.gl_date,ps.gl_date_closed,
                                                                   adj.gl_date,:p_as_of_date_from)
                                * adj.acctd_amount) acctd_start_bal,
                         -sum(ar_calc_aging.begin_or_end_bal(ps.gl_date,ps.gl_date_closed,
                                                                   adj.gl_date,:p_as_of_date_to)
                                * adj.acctd_amount) acctd_end_bal
                       FROM  '|| l_adj_table ||' adj,
                             '|| l_ps_table  ||' ps
                       WHERE ps.payment_schedule_id + 0 > 0
                       AND   ps.class  = ''BR''
                       AND   adj.payment_schedule_id = ps.payment_schedule_id
                       AND   adj.gl_date > :p_as_of_date_from
                       AND   ps.gl_date        <= :p_as_of_date_to
                       AND   ps.gl_date_closed >= :p_as_of_date_from
                       AND   adj.status = ''A''
                       '||   l_adj_org_where||'
                       '||   l_ps_org_where ||'
                       GROUP BY ps.customer_trx_id ';

     IF p_co_seg_low IS NOT NULL OR p_co_seg_high IS NOT NULL THEN
         l_unapp_select := 'SELECT
                            NVL(-sum(ar_calc_aging.begin_or_end_bal(ra.gl_date,gl_date_closed,
                                                           NULL,:p_as_of_date_from)
                              * ra.amount_applied) ,0 ) start_bal,
                            NVL(-sum(ar_calc_aging.begin_or_end_bal(ra.gl_date,gl_date_closed,
                                                           NULL,:p_as_of_date_to)
                              * ra.amount_applied) ,0)  end_bal,
                            NVL(-sum(ar_calc_aging.begin_or_end_bal(ra.gl_date,gl_date_closed,
                                                           NULL,:p_as_of_date_from)
                              * ra.acctd_amount_applied_from) ,0 ) acctd_start_bal,
                            NVL(-sum(ar_calc_aging.begin_or_end_bal(ra.gl_date,gl_date_closed,
                                                           NULL,:p_as_of_date_to)
                              * ra.acctd_amount_applied_from) ,0) acctd_end_bal
                      FROM  '|| l_ps_table ||' ps,
                            '|| l_ra_table ||' ra,
                             gl_code_combinations gc
                     WHERE  ra.gl_date  <= :p_as_of_date_to
                       AND  ps.cash_receipt_id = ra.cash_receipt_id
                       AND  ra.status in ( ''ACC'', ''UNAPP'', ''UNID'', ''OTHER ACC'' )
                       AND  nvl(ra.confirmed_flag, ''Y'') = ''Y''
                       AND  ps.class = ''PMT''
                       AND  ps.gl_date_closed >= :p_as_of_date_from
                       AND  nvl( ps.receipt_confirmed_flag, ''Y'' ) = ''Y''
                       AND  gc.code_combination_id = ra.code_combination_id
                       ' || l_ps_org_where ||'
                       ' || l_ra_org_where || '
                       ' || company_segment_where;
     ELSE
         l_unapp_select := 'SELECT
                            NVL(-sum(ar_calc_aging.begin_or_end_bal(ra.gl_date,gl_date_closed,
                                                           NULL,:p_as_of_date_from)
                              * ra.amount_applied) ,0 ) start_bal,
                            NVL(-sum(ar_calc_aging.begin_or_end_bal(ra.gl_date,gl_date_closed,
                                                           NULL,:p_as_of_date_to)
                              * ra.amount_applied) ,0)  end_bal,
                            NVL(-sum(ar_calc_aging.begin_or_end_bal(ra.gl_date,gl_date_closed,
                                                           NULL,:p_as_of_date_from)
                              * ra.acctd_amount_applied_from) ,0 ) acctd_start_bal,
                            NVL(-sum(ar_calc_aging.begin_or_end_bal(ra.gl_date,gl_date_closed,
                                                           NULL,:p_as_of_date_to)
                              * ra.acctd_amount_applied_from) ,0) acctd_end_bal
                      FROM  '|| l_ps_table ||' ps,
                            '|| l_ra_table ||' ra
                     WHERE  ra.gl_date  <= :p_as_of_date_to
                       AND  ps.cash_receipt_id = ra.cash_receipt_id
                       AND  ra.status in ( ''ACC'', ''UNAPP'', ''UNID'', ''OTHER ACC'' )
                       AND  nvl(ra.confirmed_flag, ''Y'') = ''Y''
                       AND  ps.class = ''PMT''
                       AND  ps.gl_date_closed >= :p_as_of_date_from
                       AND  nvl( ps.receipt_confirmed_flag, ''Y'' ) = ''Y''
                       ' || l_ps_org_where ||'
                       ' || l_ra_org_where ;
    END IF;


  l_trx_main_select := '
                      SELECT sum(start_bal) start_bal,
                             sum(end_bal) end_bal,
                             sum(acctd_start_bal)acctd_start_bal ,
                             sum(acctd_end_bal) acctd_end_bal
                      FROM (
                         '||l_ps_select ||'
                         UNION ALL
                         '||l_ra_select ||'
                         UNION ALL
                         '||l_cm_ra_select ||'
                         UNION ALL
                         '||l_adj_select ||'
                     ) ps ';
  IF p_co_seg_low IS NOT NULL OR p_co_seg_high IS NOT NULL THEN
    l_trx_main_select := l_trx_main_select || ', '|| l_gl_dist_table ||' gl_dist,
                         gl_code_combinations gc
                  where gl_dist.customer_trx_id = ps.customer_trx_id
                  and   gl_dist.account_class  =''REC''
                  and   gl_dist.latest_rec_flag  =''Y''
                  and   gl_dist.code_combination_id = gc.code_combination_id
                  ' || l_gl_dist_org_where ||'
                  ' || company_segment_where ;
  END IF;

    l_br_main_select := '
                      SELECT sum(start_bal) start_bal,
                             sum(end_bal) end_bal,
                             sum(acctd_start_bal)acctd_start_bal ,
                             sum(acctd_end_bal) acctd_end_bal
                      FROM (
                         '||l_br_select ||'
                         UNION ALL
                         '||l_br_app_select ||'
                         UNION ALL
                         '||l_br_adj_select ||'
                              ) ps ';
    IF p_co_seg_low IS NOT NULL OR p_co_seg_high IS NOT NULL THEN
       l_br_main_select := l_br_main_select || ' , ar_transaction_history_all ath,
                             '|| l_ard_table ||' ard,
                             gl_code_combinations gc
                      WHERE  ps.customer_trx_id = ath.customer_trx_id
                      AND    ath.status = ''PENDING_REMITTANCE''
                      AND    ath.event in (''COMPLETED'',''ACCEPTED'')
                      AND    ard.source_id = ath.transaction_history_id
                      AND    ard.source_table  = ''TH''
                      AND    ard.source_type = ''REC''
                      AND    ard.source_id_secondary IS NULL
                      AND    ard.source_table_secondary IS NULL
                      AND    ard.source_type_secondary IS NULL
                      AND    gc.code_combination_id = ard.code_combination_id
                      '||    l_ath_org_where ||'
                      '||    l_ard_org_where ||'
                      '||    company_segment_where ;
    END IF;

    IF nvl(br_enabled_flag,'N')  = 'Y' THEN
          l_main_select := 'SELECT sum(start_bal) start_bal,
                                   sum(end_bal) end_bal,
                                   sum(acctd_start_bal) acctd_start_bal ,
                                   sum(acctd_end_bal) acctd_end_bal
                           FROM ('|| l_trx_main_select ||' UNION ALL '||
                                     l_br_main_select  ||'
                                   UNION ALL
                                '|| l_unapp_select    ||' UNION ALL
                                '|| l_cancel_br_select|| ') ';
    ELSE
          l_main_select := 'SELECT sum(start_bal) start_bal,
                                   sum(end_bal) end_bal,
                                   sum(acctd_start_bal) acctd_start_bal ,
                                   sum(acctd_end_bal) acctd_end_bal
                            FROM ('|| l_trx_main_select ||' UNION ALL
                                  '|| l_unapp_select
                                   || ') ';
    END IF;

    v_cursor := dbms_sql.open_cursor;

    dbms_sql.parse(v_cursor,l_main_select,DBMS_SQL.NATIVE);

    dbms_sql.bind_variable(v_cursor, ':p_as_of_date_from', p_as_of_date_from);
    dbms_sql.bind_variable(v_cursor, ':p_as_of_date_to', p_as_of_date_to);

    dbms_sql.define_column(v_cursor, 1, p_begin_bal);
    dbms_sql.define_column(v_cursor, 2, p_end_bal);
    dbms_sql.define_column(v_cursor, 3, p_acctd_begin_bal);
    dbms_sql.define_column(v_cursor, 4, p_acctd_end_bal);

    l_ignore := dbms_sql.execute(v_cursor);

    LOOP
      IF dbms_sql.fetch_rows(v_cursor) > 0 then
         dbms_sql.column_value(v_cursor, 1, p_begin_bal);
         dbms_sql.column_value(v_cursor, 2, p_end_bal);
         dbms_sql.column_value(v_cursor, 3, p_acctd_begin_bal);
         dbms_sql.column_value(v_cursor, 4, p_acctd_end_bal);
      ELSE
         EXIT;
      END IF;
   END LOOP;

  dbms_sql.close_cursor(v_cursor);

END aging_as_of;

/*-----------------------------------------------------------
 PUBLIC PROCEDURE adjustment_register
-------------------------------------------------------------*/

PROCEDURE adjustment_register(p_gl_date_low            IN  DATE ,
                              p_gl_date_high           IN  DATE,
                              p_reporting_level        IN  VARCHAR2,
                              p_reporting_entity_id    IN  NUMBER,
                              p_co_seg_low             IN  VARCHAR2,
                              p_co_seg_high            IN  VARCHAR2,
                              p_coa_id                 IN  NUMBER,
                              p_fin_chrg_amount        OUT NOCOPY NUMBER,
                              p_fin_chrg_acctd_amount  OUT NOCOPY NUMBER,
                              p_adj_amount             OUT NOCOPY NUMBER,
                              p_adj_acctd_amount       OUT NOCOPY NUMBER,
                              p_guar_amount            OUT NOCOPY NUMBER,
                              p_guar_acctd_amount      OUT NOCOPY NUMBER,
                              p_dep_amount             OUT NOCOPY NUMBER,
                              p_dep_acctd_amount       OUT NOCOPY NUMBER,
                              p_endorsmnt_amount       OUT NOCOPY NUMBER,
                              p_endorsmnt_acctd_amount OUT NOCOPY NUMBER ) IS

 l_main_select              VARCHAR2(10000);
 l_endorsement_select       VARCHAR2(5000);
 v_cursor                   NUMBER;
 l_ignore                   INTEGER;
BEGIN

  /* AR Reconciliation Process Enhancements : Procedure is completely re-written */

    build_parameters (p_reporting_level,
                      p_reporting_entity_id,
                      p_co_seg_low,
                      p_co_seg_high,
                      p_coa_id);

    l_main_select := '
            SELECT sum(decode(rec.type,''FINCHRG'', adj.amount,0)) fin_amount,
                   sum(decode(rec.type,''FINCHRG'', adj.acctd_amount,0)) fin_acctd_amount,
                   sum(decode(rec.type,''ADJUST'',
                                decode(adj.adjustment_type,''C'',0,
                                  decode(adj.receivables_trx_id,-15,0, adj.amount)))) Adj_amount,
                   sum(decode(rec.type,''ADJUST'',
                                decode(adj.adjustment_type,''C'',0,
                                decode(adj.receivables_trx_id,-15,0, adj.acctd_amount)))) Adj_acctd_amount,
                   sum(decode(rec.type,''ADJUST'',
                                decode(adj.adjustment_type,''C'',
                                  decode(type.type,''GUAR'',adj.amount,0)))) Guar_amount,
                   sum(decode(rec.type,''ADJUST'',
                                decode(adj.adjustment_type,''C'',
                                  decode(type.type,''GUAR'',adj.acctd_amount,0)))) Guar_acctd_amount,
                   sum(decode(rec.type,''ADJUST'',
                                decode(adj.adjustment_type,''C'',
                                  decode(type.type,''GUAR'',0,adj.amount)))) Dep_amount,
                   sum(decode(rec.type,''ADJUST'',
                                decode(adj.adjustment_type,''C'',
                                  decode(type.type,''GUAR'',0,adj.acctd_amount)))) Dep_acctd_amount
           FROM   '||l_adj_table||' adj,
                  ar_receivables_trx_all rec,
                  '||l_trx_table||' trx,
                  ra_cust_trx_types_all type ';
   IF p_co_seg_low IS NOT NULL OR p_co_seg_high IS NOT NULL THEN
           l_main_select := l_main_select || ',
                  '||l_gl_dist_table||' gl_dist,
                  gl_code_combinations gc ';
   END IF;
    l_main_select := l_main_select ||'
           WHERE  nvl(adj.status, ''A'') = ''A''
           AND    adj.receivables_trx_id <> -15
           AND    adj.receivables_trx_id = rec.receivables_trx_id
           AND    nvl(rec.org_id,-99) = nvl(adj.org_id,-99)
           AND    adj.gl_date between :gl_date_low and :gl_date_high
           AND    trx.customer_trx_id = adj.customer_trx_id
           AND    trx.complete_flag = ''Y''
           AND    trx.cust_trx_type_id =  type.cust_trx_type_id
           AND    nvl(type.org_id,-99) = nvl(trx.org_id,-99)
           '||    l_adj_org_where ||'
           '||    l_trx_org_where ;

   IF p_co_seg_low IS NOT NULL OR p_co_seg_high IS NOT NULL THEN
           l_main_select := l_main_select ||'
           AND    adj.customer_trx_id = gl_dist.customer_trx_id
           AND    gl_dist.account_class = ''REC''
           AND    gl_dist.latest_rec_flag = ''Y''
           AND    gc.code_combination_id = gl_dist.code_combination_id
           '||    l_gl_dist_org_where ||'
           '|| company_segment_where;
   END IF;
    l_endorsement_select := 'SELECT
                             sum(adj.amount) Endsmnt_amount,
                             sum(adj.acctd_amount) Endrsmnt_acctd_amount
                             FROM   '||l_adj_table||' adj,
                                    ar_receivables_trx_all rec';
   IF p_co_seg_low IS NOT NULL OR p_co_seg_high IS NOT NULL THEN
      l_endorsement_select := l_endorsement_select || ' ,
                                    ar_transaction_history_all ath ';
   END IF;
    l_endorsement_select := l_endorsement_select ||'
                             WHERE  nvl(adj.status, ''A'') = ''A''
                             AND    adj.receivables_trx_id <> -15
                             AND    adj.receivables_trx_id = rec.receivables_trx_id
                             AND    nvl(adj.org_id,-99) = nvl(rec.org_id,-99)
                             AND    rec.type = ''ENDORSEMENT''
                             AND    adj.gl_date between :gl_date_low and :gl_date_high
                             '||    l_adj_org_where ;
  IF p_co_seg_low IS NOT NULL OR p_co_seg_high IS NOT NULL THEN
      l_endorsement_select := l_endorsement_select || '
                             AND    adj.customer_trx_id = ath.customer_trx_id
                             AND    ath.status = ''PENDING_REMITTANCE''
                             AND    ath.event in (''COMPLETED'',''ACCEPTED'')
                             '||    l_ath_org_where ||'
                             AND    exists (SELECT line_id
                                            FROM   '|| l_ard_table ||' ard,
                                                   gl_code_combinations gc
                                            WHERE  ard.source_id = ath.transaction_history_id
                                            AND    ard.source_table  = ''TH''
                                            AND    ard.source_type = ''REC''
                                            AND    ard.source_id_secondary IS NULL
                                            AND    ard.source_table_secondary IS NULL
                                            AND    ard.source_type_secondary IS NULL
                                            AND    gc.code_combination_id = ard.code_combination_id
                                            '|| l_ard_org_where ||'
                                            '||company_segment_where||')';
  END IF;

    v_cursor := dbms_sql.open_cursor;

    dbms_sql.parse(v_cursor,l_main_select,DBMS_SQL.NATIVE);

    dbms_sql.bind_variable(v_cursor, ':gl_date_low', p_gl_date_low);
    dbms_sql.bind_variable(v_cursor, ':gl_date_high', p_gl_date_high);

    dbms_sql.define_column(v_cursor, 1, p_fin_chrg_amount);
    dbms_sql.define_column(v_cursor, 2, p_fin_chrg_acctd_amount);
    dbms_sql.define_column(v_cursor, 3, p_adj_amount);
    dbms_sql.define_column(v_cursor, 4, p_adj_acctd_amount);
    dbms_sql.define_column(v_cursor, 5, p_guar_amount);
    dbms_sql.define_column(v_cursor, 6, p_guar_acctd_amount);
    dbms_sql.define_column(v_cursor, 7, p_dep_amount);
    dbms_sql.define_column(v_cursor, 8, p_dep_acctd_amount);

    l_ignore := dbms_sql.execute(v_cursor);

    LOOP
      IF dbms_sql.fetch_rows(v_cursor) > 0 then
         dbms_sql.column_value(v_cursor, 1, p_fin_chrg_amount);
         dbms_sql.column_value(v_cursor, 2, p_fin_chrg_acctd_amount);
         dbms_sql.column_value(v_cursor, 3, p_adj_amount);
         dbms_sql.column_value(v_cursor, 4, p_adj_acctd_amount);
         dbms_sql.column_value(v_cursor, 5, p_guar_amount);
         dbms_sql.column_value(v_cursor, 6, p_guar_acctd_amount);
         dbms_sql.column_value(v_cursor, 7, p_dep_amount);
         dbms_sql.column_value(v_cursor, 8, p_dep_acctd_amount);
      ELSE
         EXIT;
      END IF;
   END LOOP;

   IF nvl(br_enabled_flag,'N')  = 'Y' THEN
      dbms_sql.parse(v_cursor,l_endorsement_select,DBMS_SQL.NATIVE);

      dbms_sql.bind_variable(v_cursor, ':gl_date_low', p_gl_date_low);
      dbms_sql.bind_variable(v_cursor, ':gl_date_high', p_gl_date_high);

      dbms_sql.define_column(v_cursor, 1, p_endorsmnt_amount);
      dbms_sql.define_column(v_cursor, 2, p_endorsmnt_acctd_amount);

      l_ignore := dbms_sql.execute(v_cursor);

      LOOP
         IF dbms_sql.fetch_rows(v_cursor) > 0 then
            dbms_sql.column_value(v_cursor, 1, p_endorsmnt_amount);
            dbms_sql.column_value(v_cursor, 2, p_endorsmnt_acctd_amount);
         ELSE
            EXIT;
         END IF;
      END LOOP;
   END IF;

  dbms_sql.close_cursor(v_cursor);

END adjustment_register  ;

/*-----------------------------------------------------------
 PUBLIC PROCEDURE transaction_register
-------------------------------------------------------------*/

PROCEDURE transaction_register(p_gl_date_low              IN  DATE,
                               p_gl_date_high             IN  DATE,
                               p_reporting_level          IN  VARCHAR2,
                               p_reporting_entity_id      IN  NUMBER,
                               p_co_seg_low               IN  VARCHAR2,
                               p_co_seg_high              IN  VARCHAR2,
                               p_coa_id                   IN  NUMBER,
                               p_non_post_amount          OUT NOCOPY NUMBER,
                               p_non_post_acctd_amount    OUT NOCOPY NUMBER,
                               p_post_amount              OUT NOCOPY NUMBER ,
                               p_post_acctd_amount        OUT NOCOPY NUMBER ) IS

 l_post_select              VARCHAR2(2000);
 l_non_post_select          VARCHAR2(2000);
 v_cursor                   NUMBER;
 l_ignore                   INTEGER;


BEGIN

    /* AR Reconciliation Process Enhancements:  The procedure is completely modified */

    build_parameters (p_reporting_level,
                      p_reporting_entity_id,
                      p_co_seg_low,
                      p_co_seg_high,
                      p_coa_id);

    IF p_co_seg_low IS NOT NULL OR p_co_seg_high IS NOT NULL THEN
        l_post_select := '
                      SELECT
                         NVL(SUM(NVL(gl_dist.amount,0)),0)       Invoice_Currency,
                         NVL(SUM(NVL(gl_dist.acctd_amount,0)),0) Functional_Currency
                      FROM ra_cust_trx_types_all type,
                           '||l_trx_table||'         trx,
                           '||l_gl_dist_table||' gl_dist,
                           gl_code_combinations gc
                      WHERE   gl_dist.gl_date BETWEEN :gl_date_low AND :gl_date_high
                      AND     gl_dist.gl_date IS NOT NULL
                      AND     gl_dist.account_class   = ''REC''
                      AND     gl_dist.latest_rec_flag = ''Y''
                      AND     gl_dist.customer_trx_id = trx.customer_trx_id
                      AND     type.cust_trx_type_id   = trx.cust_trx_type_id
                      AND     trx.complete_flag       = ''Y''
                      AND     type.type  in (''INV'',''DEP'',''GUAR'', ''CM'',''DM'', ''CB'' )
                      AND     nvl(type.org_id,-99) = nvl(trx.org_id,-99)
                      AND     gc.code_combination_id = gl_dist.code_combination_id
                      '||l_gl_dist_org_where ||'
                      '||l_trx_org_where ||'
                      '||company_segment_where;
         l_non_post_select := '
                      SELECT
                         NVL(SUM(NVL(gl_dist.amount,0)),0)       Invoice_Currency,
                         NVL(SUM(NVL(gl_dist.acctd_amount,0)),0) Functional_Currency
                      FROM ra_cust_trx_types_all type,
                           '||l_trx_table||'         trx,
                           '||l_gl_dist_table||' gl_dist,
                           gl_code_combinations gc
                      WHERE   trx.trx_date  BETWEEN :gl_date_low AND :gl_date_high
                      AND     gl_dist.gl_date IS NULL
                      AND     gl_dist.account_class   = ''REC''
                      AND     gl_dist.latest_rec_flag = ''Y''
                      AND     gl_dist.customer_trx_id = trx.customer_trx_id
                      AND     type.cust_trx_type_id   = trx.cust_trx_type_id
                      AND     trx.complete_flag       = ''Y''
                      AND     type.type  in (''INV'',''DEP'',''GUAR'', ''CM'',''DM'', ''CB'' )
                      AND     nvl(type.org_id,-99) = nvl(trx.org_id,-99)
                      AND     gc.code_combination_id = gl_dist.code_combination_id
                      '||l_gl_dist_org_where ||'
                      '||l_trx_org_where ||'
                      '||company_segment_where;
    ELSE
        l_post_select := '
                      SELECT
                         NVL(SUM(NVL(gl_dist.amount,0)),0)       Invoice_Currency,
                         NVL(SUM(NVL(gl_dist.acctd_amount,0)),0) Functional_Currency
                      FROM ra_cust_trx_types_all type,
                           '||l_trx_table||'         trx,
                           '||l_gl_dist_table||' gl_dist
                      WHERE   gl_dist.gl_date BETWEEN :gl_date_low AND :gl_date_high
                      AND     gl_dist.gl_date IS NOT NULL
                      AND     gl_dist.account_class   = ''REC''
                      AND     gl_dist.latest_rec_flag = ''Y''
                      AND     gl_dist.customer_trx_id = trx.customer_trx_id
                      AND     type.cust_trx_type_id   = trx.cust_trx_type_id
                      AND     nvl(type.org_id,-99) = nvl(trx.org_id,-99)
                      AND     trx.complete_flag       = ''Y''
                      AND     type.type  in (''INV'',''DEP'',''GUAR'', ''CM'',''DM'', ''CB'' )
                      '||l_gl_dist_org_where ||'
                      '||l_trx_org_where;
         l_non_post_select := '
                      SELECT
                         NVL(SUM(NVL(gl_dist.amount,0)),0)       Invoice_Currency,
                         NVL(SUM(NVL(gl_dist.acctd_amount,0)),0) Functional_Currency
                      FROM ra_cust_trx_types_all type,
                           '||l_trx_table||'         trx,
                           '||l_gl_dist_table||' gl_dist
                      WHERE   trx.trx_date  BETWEEN :gl_date_low AND :gl_date_high
                      AND     gl_dist.gl_date IS NULL
                      AND     gl_dist.account_class   = ''REC''
                      AND     gl_dist.latest_rec_flag = ''Y''
                      AND     gl_dist.customer_trx_id = trx.customer_trx_id
                      AND     type.cust_trx_type_id   = trx.cust_trx_type_id
                      AND     nvl(type.org_id,-99) = nvl(trx.org_id,-99)
                      AND     trx.complete_flag       = ''Y''
                      AND     type.type  in (''INV'',''DEP'',''GUAR'', ''CM'',''DM'', ''CB'' )
                      '||l_gl_dist_org_where ||'
                      '||l_trx_org_where;
    END IF;

    v_cursor := dbms_sql.open_cursor;

    dbms_sql.parse(v_cursor,l_post_select ,DBMS_SQL.NATIVE);

    dbms_sql.bind_variable(v_cursor, ':gl_date_low', p_gl_date_low);
    dbms_sql.bind_variable(v_cursor, ':gl_date_high', p_gl_date_high);

    dbms_sql.define_column(v_cursor, 1, p_post_amount);
    dbms_sql.define_column(v_cursor, 2, p_post_acctd_amount);

    l_ignore := dbms_sql.execute(v_cursor);

    LOOP
      IF dbms_sql.fetch_rows(v_cursor) > 0 then
         dbms_sql.column_value(v_cursor, 1, p_post_amount);
         dbms_sql.column_value(v_cursor, 2, p_post_acctd_amount);
      ELSE
         EXIT;
      END IF;
   END LOOP;

    dbms_sql.parse(v_cursor,l_non_post_select ,DBMS_SQL.NATIVE);

    dbms_sql.bind_variable(v_cursor, ':gl_date_low', p_gl_date_low);
    dbms_sql.bind_variable(v_cursor, ':gl_date_high', p_gl_date_high);

    dbms_sql.define_column(v_cursor, 1, p_non_post_amount);
    dbms_sql.define_column(v_cursor, 2, p_non_post_acctd_amount);

    l_ignore := dbms_sql.execute(v_cursor);

    LOOP
      IF dbms_sql.fetch_rows(v_cursor) > 0 then
         dbms_sql.column_value(v_cursor, 1, p_non_post_amount);
         dbms_sql.column_value(v_cursor, 2, p_non_post_acctd_amount);
      ELSE
         EXIT;
      END IF;
   END LOOP;

   dbms_sql.close_cursor(v_cursor);

END transaction_register ;

/*-------------------------------------------------
PUBLIC PROCEDURE rounding_diff
--------------------------------------------------*/

PROCEDURE rounding_diff(l_gl_date_low   IN DATE,
                        l_gl_date_high  IN DATE,
                        l_rounding_diff OUT NOCOPY NUMBER ) IS
BEGIN

    /*
     * Bug fix: 2498344
     *   MRC enhancements to select data from reporting book
     *   please refer to bug for more details.
     *   we need to execute different selects depending on the book
     *   for which report is run
     */


   -- For Zero Amount Transactions , sometimes the acctd_amount is
   -- derived as 0.01 or 0.02.

  IF NVL(ar_calc_aging.ca_sob_type,'P') = 'P'
  THEN
    SELECT NVL(SUM(NVL(acctd_amount,0)),0)
    INTO   l_rounding_diff
    FROM   ra_cust_trx_line_gl_dist
    WHERE  amount = 0
    AND    gl_date BETWEEN l_gl_date_low AND l_gl_date_high ;
  ELSE
    SELECT NVL(SUM(NVL(acctd_amount,0)),0)
    INTO   l_rounding_diff
    FROM   ra_trx_line_gl_dist_mrc_v
    WHERE  amount = 0
    AND    gl_date BETWEEN l_gl_date_low AND l_gl_date_high ;
  END IF;

END rounding_diff ;


/*------------------------------------------------
PUBLIC PROCEDURE cash_receipt_register
--------------------------------------------------*/
-- Calculate  Applied, Unapplied and CM gain/loss amounts
--

PROCEDURE cash_receipts_register(p_gl_date_low           IN  DATE ,
                                 p_gl_date_high          IN  DATE,
                                 p_reporting_level       IN  VARCHAR2,
                                 p_reporting_entity_id   IN  NUMBER,
                                 p_co_seg_low            IN  VARCHAR2,
                                 p_co_seg_high           IN  VARCHAR2,
                                 p_coa_id                IN  NUMBER,
                                 p_unapp_amount          OUT NOCOPY NUMBER,
                                 p_unapp_acctd_amount    OUT NOCOPY NUMBER,
                                 p_acc_amount            OUT NOCOPY NUMBER,
                                 p_acc_acctd_amount      OUT NOCOPY NUMBER,
                                 p_claim_amount          OUT NOCOPY NUMBER,
                                 p_claim_acctd_amount    OUT NOCOPY NUMBER,
                                 p_prepay_amount         OUT NOCOPY NUMBER,
                                 p_prepay_acctd_amount   OUT NOCOPY NUMBER,
                                 p_app_amount            OUT NOCOPY NUMBER,
                                 p_app_acctd_amount      OUT NOCOPY NUMBER,
                                 p_edisc_amount          OUT NOCOPY NUMBER,
                                 p_edisc_acctd_amount    OUT NOCOPY NUMBER,
                                 p_unedisc_amount        OUT NOCOPY NUMBER,
                                 p_unedisc_acctd_amount  OUT NOCOPY NUMBER,
                                 p_cm_gain_loss          OUT NOCOPY NUMBER,
                                 p_on_acc_cm_ref_amount  OUT NOCOPY NUMBER,  /*bug 5290086*/
                                 p_on_acc_cm_ref_acctd_amount OUT NOCOPY NUMBER   ) IS

 l_main_select                VARCHAR2(20000);
 v_cursor                     NUMBER;
 l_ignore                     INTEGER;

BEGIN

    /* AR Reconciliation Process Enhancements : Procedure is completely re-written */

    build_parameters (p_reporting_level,
                      p_reporting_entity_id,
                      p_co_seg_low,
                      p_co_seg_high,
                      p_coa_id);

    l_main_select := 'SELECT   NVL(SUM(DECODE(ra.application_type,
                              ''CASH'',
                                    DECODE(ra.status,
                                    ''ACC'',  ra.amount_applied,0)
                                    ,0)),0)  Onacc_amt,
             NVL(SUM(DECODE(ra.application_type,
                              ''CASH'',
                                    DECODE(ra.status,
                                    ''ACC'',  ra.acctd_amount_applied_from,0)
                                    ,0)),0)  Onacc_acctd_amt,
             NVL(SUM(DECODE(ra.application_type,
                              ''CASH'',
                                    DECODE(ra.status,
                                    ''OTHER ACC'', DECODE(ra.applied_payment_schedule_id,
                                                   -4, ra.amount_applied,0),0)
                                    ,0)),0) claim_amount,
             NVL(SUM(DECODE(ra.application_type,
                              ''CASH'',
                                    DECODE(ra.status,
                                    ''OTHER ACC'', DECODE(ra.applied_payment_schedule_id,
                                                   -4, ra.acctd_amount_applied_from,0),0)
                                    ,0)),0) claim_acctd_amt,
             NVL(SUM(DECODE(ra.application_type,
                              ''CASH'',
                                    DECODE(ra.status,
                                    ''OTHER ACC'', DECODE(ra.applied_payment_schedule_id,
                                                   -7, ra.amount_applied,0),0)
                                    ,0)),0) prepay_amount,
             NVL(SUM(DECODE(ra.application_type,
                              ''CASH'',
                                    DECODE(ra.status,
                                    ''OTHER ACC'', DECODE(ra.applied_payment_schedule_id,
                                                   -7, ra.acctd_amount_applied_from,0),0)
                                    ,0)),0) prepay_acctd_amt,
             NVL(SUM(DECODE(ra.application_type,
                              ''CASH'',
                                    DECODE(ra.status,
                                    ''UNAPP'',  ra.amount_applied,
                                    ''UNID'', ra.amount_applied,0)
                                    ,0)),0) unapp_amt,
             NVL(SUM(DECODE(ra.application_type,
                              ''CASH'',
                                    DECODE(ra.status,
                                    ''UNAPP'',  ra.acctd_amount_applied_from,
                                    ''UNID'', ra.acctd_amount_applied_from,0)
                                    ,0)),0)  unapp_acctd_amt,

             NVL(SUM(DECODE(ra.application_type,
                                ''CM'', DECODE(ra.amount_applied,0,0,
                                            ra.acctd_amount_applied_from)
                                    , 0)
                         ),0)  -
             NVL(SUM(DECODE(ra.application_type,
                                ''CM'', DECODE(ra.amount_applied,0,0,
                                             NVL(ra.acctd_amount_applied_to,0))
                                    , 0)
                         ),0)   cm_gain_loss,
             NVL(SUM(DECODE(ra.application_type,
                              ''CASH'',
                                    DECODE(ra.status,
                                                ''APP'',
                                           ra.amount_applied,0),0)),0) app_amt,
             NVL(SUM(DECODE(ra.application_type,
                              ''CASH'',
                                    DECODE(ra.status,
                                                ''APP'',
                                      NVL(ra.earned_discount_taken,0),0),0)),0) edisc_amt,
             NVL(SUM(DECODE(ra.application_type,
                              ''CASH'',
                                    DECODE(ra.status,
                                                ''APP'',
                                      NVL(ra.unearned_discount_taken,0),0),0)),0) unedisc_amt,
             NVL(SUM(DECODE(ra.application_type,
                              ''CASH'',
                                    DECODE(ra.status,
                                                ''APP'',
                                      NVL(ra.acctd_amount_applied_to,0),0),0)),0) acctd_app_amt,
             NVL(SUM(DECODE(ra.application_type,
                              ''CASH'',
                                    DECODE(ra.status,
                                                ''APP'',
                              NVL(ra.acctd_earned_discount_taken,0),0),0)),0) acctd_edisc_amt,
             NVL(SUM(DECODE(ra.application_type,
                              ''CASH'',
                                    DECODE(ra.status,
                                                ''APP'',
                            NVL(ra.acctd_unearned_discount_taken,0),0),0)),0) acctd_unedisc_amt,
             NVL(SUM(DECODE(ra.application_type,     /*bug5290086*/
                              ''CM'',
                                    DECODE(ra.status,
                                    ''ACTIVITY'', DECODE(ra.applied_payment_schedule_id,
                                                   -8, ra.amount_applied,0),0)
                                    ,0)),0) onacc_cm_ref_amount,
               NVL(SUM(DECODE(ra.application_type,
                              ''CM'',
                                    DECODE(ra.status,
                                    ''ACTIVITY'', DECODE(ra.applied_payment_schedule_id,
                                                   -8, ra.acctd_amount_applied_to,0),0)
                                    ,0)),0) onacc_cm_ref_acctd_amount
    FROM  '|| l_ra_table || ' ra ';

    IF p_co_seg_low IS NOT NULL OR p_co_seg_high IS NOT NULL THEN
        l_main_select := l_main_select || ',
                         gl_code_combinations gc ';
    END IF;
    l_main_select  := l_main_select || '
          WHERE  NVL(ra.confirmed_flag,''Y'') = ''Y''
          AND   ra.gl_date BETWEEN :gl_date_low  AND :gl_date_high
          '||   l_ra_org_where;

    IF p_co_seg_low IS NOT NULL OR p_co_seg_high IS NOT NULL THEN
       l_main_select := l_main_select || '
          AND gc.code_combination_id = ra.code_combination_id
         '|| company_segment_where;
    END IF;

    v_cursor := dbms_sql.open_cursor;

    dbms_sql.parse(v_cursor,l_main_select,DBMS_SQL.NATIVE);

    dbms_sql.bind_variable(v_cursor, ':gl_date_low', p_gl_date_low);
    dbms_sql.bind_variable(v_cursor, ':gl_date_high', p_gl_date_high);

    dbms_sql.define_column(v_cursor, 1, p_acc_amount);
    dbms_sql.define_column(v_cursor, 2, p_acc_acctd_amount);
    dbms_sql.define_column(v_cursor, 3, p_claim_amount);
    dbms_sql.define_column(v_cursor, 4, p_claim_acctd_amount);
    dbms_sql.define_column(v_cursor, 5, p_prepay_amount);
    dbms_sql.define_column(v_cursor, 6, p_prepay_acctd_amount);
    dbms_sql.define_column(v_cursor, 7, p_unapp_amount);
    dbms_sql.define_column(v_cursor, 8, p_unapp_acctd_amount);
    dbms_sql.define_column(v_cursor, 9, p_cm_gain_loss);
    dbms_sql.define_column(v_cursor, 10, p_app_amount);
    dbms_sql.define_column(v_cursor, 11, p_edisc_amount);
    dbms_sql.define_column(v_cursor, 12, p_unedisc_amount);
    dbms_sql.define_column(v_cursor, 13, p_app_acctd_amount);
    dbms_sql.define_column(v_cursor, 14, p_edisc_acctd_amount);
    dbms_sql.define_column(v_cursor, 15, p_unedisc_acctd_amount);
    dbms_sql.define_column(v_cursor, 16, p_on_acc_cm_ref_amount);  /*bug5290086*/
    dbms_sql.define_column(v_cursor, 17, p_on_acc_cm_ref_acctd_amount);

    l_ignore := dbms_sql.execute(v_cursor);

    LOOP
      IF dbms_sql.fetch_rows(v_cursor) > 0 then
          dbms_sql.column_value(v_cursor, 1, p_acc_amount);
          dbms_sql.column_value(v_cursor, 2, p_acc_acctd_amount);
          dbms_sql.column_value(v_cursor, 3, p_claim_amount);
          dbms_sql.column_value(v_cursor, 4, p_claim_acctd_amount);
          dbms_sql.column_value(v_cursor, 5, p_prepay_amount);
          dbms_sql.column_value(v_cursor, 6, p_prepay_acctd_amount);
          dbms_sql.column_value(v_cursor, 7, p_unapp_amount);
          dbms_sql.column_value(v_cursor, 8, p_unapp_acctd_amount);
          dbms_sql.column_value(v_cursor, 9, p_cm_gain_loss);
          dbms_sql.column_value(v_cursor, 10, p_app_amount);
          dbms_sql.column_value(v_cursor, 11, p_edisc_amount);
          dbms_sql.column_value(v_cursor, 12, p_unedisc_amount);
          dbms_sql.column_value(v_cursor, 13, p_app_acctd_amount);
          dbms_sql.column_value(v_cursor, 14, p_edisc_acctd_amount);
          dbms_sql.column_value(v_cursor, 15, p_unedisc_acctd_amount);
          dbms_sql.column_value(v_cursor, 16, p_on_acc_cm_ref_amount);    /*bug5290086*/
          dbms_sql.column_value(v_cursor, 17, p_on_acc_cm_ref_acctd_amount);
      ELSE
         EXIT;
      END IF;
    END LOOP;

   dbms_sql.close_cursor(v_cursor);

END cash_receipts_register ;

/*------------------------------------------------
PUBLIC PROCEDURE invoice_exception
--------------------------------------------------*/

PROCEDURE invoice_exceptions( p_gl_date_low                 IN  DATE,
                              p_gl_date_high                IN  DATE,
                              p_reporting_level             IN  VARCHAR2,
                              p_reporting_entity_id         IN  NUMBER,
                              p_co_seg_low                  IN  VARCHAR2,
                              p_co_seg_high                 IN  VARCHAR2,
                              p_coa_id                      IN  NUMBER,
                              p_post_excp_amount            OUT NOCOPY NUMBER,
                              p_post_excp_acctd_amount      OUT NOCOPY NUMBER,
                              p_nonpost_excp_amount         OUT NOCOPY NUMBER,
                              p_nonpost_excp_acctd_amount   OUT NOCOPY NUMBER) IS
 l_post_select              VARCHAR2(10000);
 l_non_post_select          VARCHAR2(10000);
 v_cursor                   NUMBER;
 l_ignore                   INTEGER;

BEGIN

    build_parameters (p_reporting_level,
                      p_reporting_entity_id,
                      p_co_seg_low,
                      p_co_seg_high,
                      p_coa_id);

    l_post_select := '
                      SELECT
                        NVL(SUM(NVL(gl_dist.amount,0)),0) ,
                        NVL(SUM(NVL(gl_dist.acctd_amount,0)),0)
                      FROM
                        ra_cust_trx_types_all   type,
                        '||l_trx_table||'   trx,
                        '||l_gl_dist_table||'  gl_dist ';
    l_non_post_select := '
                      SELECT
                        NVL(SUM(NVL(gl_dist.amount,0)),0) ,
                        NVL(SUM(NVL(gl_dist.acctd_amount,0)),0)
                      FROM
                        ra_cust_trx_types_all  type,
                        '||l_trx_table||'  trx,
                        '||l_gl_dist_table||'  gl_dist ';

    IF p_co_seg_low IS NOT NULL OR p_co_seg_high IS NOT NULL THEN
       l_post_select := l_post_select ||',
                        gl_code_combinations gc ';
       l_non_post_select := l_non_post_select ||',
                        gl_code_combinations gc ';
    END IF;

    l_post_select := l_post_select || '
                      WHERE   trx.complete_flag = ''Y''
                      AND     NOT EXISTS ( SELECT ''x''
                                            FROM   '||l_ps_table||' ps
                                            WHERE  ps.customer_trx_id = trx.customer_trx_id
                                             '|| l_ps_org_where||')
                      AND     gl_dist.gl_date BETWEEN :gl_date_low AND :gl_date_high
                      AND     type.post_to_gl = ''Y''
                      AND     gl_dist.account_class = ''REC''
                      AND     gl_dist.latest_rec_flag = ''Y''
                      AND     gl_dist.customer_trx_id = trx.customer_trx_id
                      AND     trx.cust_trx_type_id = type.cust_trx_type_id
                      AND     nvl(type.org_id,-99) = nvl(trx.org_id,-99)
                      AND     type.type IN (''INV'', ''DEP'', ''GUAR'', ''CM'',''DM'')
                      '|| l_trx_org_where||'
                      '|| l_gl_dist_org_where ;
    l_non_post_select := l_non_post_select||'
                      WHERE   trx.complete_flag = ''Y''
                      AND     NOT EXISTS ( SELECT ''x''
                                           FROM   '||l_ps_table||' ps
                                           WHERE  ps.customer_trx_id = trx.customer_trx_id
                                           '|| l_ps_org_where||')
                      AND     trx.trx_date BETWEEN :gl_date_low AND :gl_date_high
                      AND     type.post_to_gl = ''N''
                      AND     gl_dist.account_class = ''REC''
                      AND     gl_dist.latest_rec_flag = ''Y''
                      AND     gl_dist.customer_trx_id = trx.customer_trx_id
                      AND     trx.cust_trx_type_id = type.cust_trx_type_id
                      AND     nvl(type.org_id,-99) = nvl(trx.org_id,-99)
                      AND     type.type IN (''INV'', ''DEP'', ''GUAR'', ''CM'',''DM'')
                      '|| l_trx_org_where ||'
                      '|| l_gl_dist_org_where;

  IF p_co_seg_low IS NOT NULL OR p_co_seg_high IS NOT NULL THEN
    l_post_select := l_post_select||'
                     AND     gc.code_combination_id = gl_dist.code_combination_id
                      '||company_segment_where ;
    l_non_post_select := l_non_post_select ||'
                     AND     gc.code_combination_id = gl_dist.code_combination_id
                      '||company_segment_where ;
  END IF;

    v_cursor := dbms_sql.open_cursor;

    dbms_sql.parse(v_cursor,l_post_select,DBMS_SQL.NATIVE);

    dbms_sql.bind_variable(v_cursor, ':gl_date_low', p_gl_date_low);
    dbms_sql.bind_variable(v_cursor, ':gl_date_high', p_gl_date_high);

    dbms_sql.define_column(v_cursor, 1, p_post_excp_amount);
    dbms_sql.define_column(v_cursor, 2, p_post_excp_acctd_amount);

    l_ignore := dbms_sql.execute(v_cursor);

    LOOP
      IF dbms_sql.fetch_rows(v_cursor) > 0 then
         dbms_sql.column_value(v_cursor, 1, p_post_excp_amount);
         dbms_sql.column_value(v_cursor, 2, p_post_excp_acctd_amount);
      ELSE
         EXIT;
      END IF;
    END LOOP;

    dbms_sql.parse(v_cursor,l_non_post_select,DBMS_SQL.NATIVE);

    dbms_sql.bind_variable(v_cursor, ':gl_date_low', p_gl_date_low);
    dbms_sql.bind_variable(v_cursor, ':gl_date_high', p_gl_date_high);

    dbms_sql.define_column(v_cursor, 1, p_nonpost_excp_amount);
    dbms_sql.define_column(v_cursor, 2, p_nonpost_excp_acctd_amount);

    l_ignore := dbms_sql.execute(v_cursor);

    LOOP
      IF dbms_sql.fetch_rows(v_cursor) > 0 then
         dbms_sql.column_value(v_cursor, 1, p_nonpost_excp_amount);
         dbms_sql.column_value(v_cursor, 2, p_nonpost_excp_acctd_amount);
      ELSE
         EXIT;
      END IF;
    END LOOP;

   dbms_sql.close_cursor(v_cursor);

END invoice_exceptions ;

FUNCTION begin_or_end_bal( p_gl_date IN DATE,
                           p_gl_date_closed IN DATE,
                           p_activity_date IN DATE,
                           p_as_of_date IN DATE
                           )RETURN NUMBER IS

BEGIN
  --If the payment schedule gl date is less than p_as_of_date_start
  --and gl date closed is greater than p_as_of_date_start

 IF p_activity_date IS NULL THEN  --for Open Trx
   IF (  ( p_gl_date <= p_as_of_date)
   AND   ( p_gl_date_closed > p_as_of_date) ) THEN
        RETURN 1;
   ELSE
        RETURN 0;
   END IF;
 ELSIF p_activity_date IS NOT NULL THEN  -- applications and adjustments
   IF (  (p_gl_date <=  p_as_of_date)
     AND  (p_gl_date_closed > p_as_of_date)
     AND  (p_activity_date > p_as_of_date))  THEN
        RETURN 1;
   ELSE
        RETURN 0;
   END IF;
 END IF;

END begin_or_end_bal;

PROCEDURE journal_reports(  p_gl_date_low                 IN  DATE,
                            p_gl_date_high                IN  DATE,
                            p_reporting_level             IN  VARCHAR2,
                            p_reporting_entity_id         IN  NUMBER,
                            p_co_seg_low                  IN  VARCHAR2,
                            p_co_seg_high                 IN  VARCHAR2,
                            p_coa_id                      IN  NUMBER,
                            p_sales_journal_amt           OUT NOCOPY NUMBER,
                            p_sales_journal_acctd_amt     OUT NOCOPY NUMBER,
                            p_adj_journal_amt             OUT NOCOPY NUMBER,
                            p_adj_journal_acctd_amt       OUT NOCOPY NUMBER,
                            p_app_journal_amt             OUT NOCOPY NUMBER,
                            p_app_journal_acctd_amt       OUT NOCOPY NUMBER,
                            p_unapp_journal_amt           OUT NOCOPY NUMBER,
                            p_unapp_journal_acctd_amt     OUT NOCOPY NUMBER,
                            p_cm_journal_acctd_amt        OUT NOCOPY NUMBER) IS

 l_sales_journal_salect          VARCHAR2(2000);
 l_adj_journal_select            VARCHAR2(2000);
 l_app_journal_select            VARCHAR2(3000);
 l_unapp_journal_select          VARCHAR2(2000);
 l_cm_journal_select             VARCHAR2(2000);
 v_cursor                        NUMBER;
 l_ignore                        INTEGER;
 l_ledger_id                     NUMBER;

BEGIN

    build_parameters (p_reporting_level,
                      p_reporting_entity_id,
                      p_co_seg_low,
                      p_co_seg_high,
                      p_coa_id);

    /* Bug7265328 - This used to pick Journal data from the AR distributions entries. Modified to pick
       details from SLA tables without tying it back to AR tables for amounts. This exercise will help
       find actual difference between AR side operational data and SLA side accounting data */

    --{Bug7265328 Modifications Start

    IF (p_reporting_level = '1000') THEN
        l_ledger_id := p_reporting_entity_id;

    ELSIF (p_reporting_level = '3000') THEN

       SELECT set_of_books_id
         INTO l_ledger_id
         FROM ar_system_parameters_all
        WHERE org_id = p_reporting_entity_id;

    END IF;

    l_sales_journal_salect   := ' SELECT (sum(nvl(lk.unrounded_entered_dr,0))-sum(nvl(lk.unrounded_entered_cr,0))),
                                        (sum(nvl(lk.unrounded_accounted_dr,0))-sum(nvl(lk.unrounded_accounted_cr,0)))
                                  FROM   '||l_trx_table||' trx,
				         xla_transaction_entities_upg en,
					 xla_ae_headers hdr,
					 xla_ae_lines ae,
           xla_distribution_links lk ';

  IF p_co_seg_low IS NOT NULL OR p_co_seg_high IS NOT NULL THEN
    l_sales_journal_salect := l_sales_journal_salect ||',
                                gl_code_combinations gc ';
  END IF;

    l_sales_journal_salect := l_sales_journal_salect ||'
                         WHERE  en.application_id = 222
			   AND  en.ledger_id = '|| l_ledger_id ||'
			   AND  en.entity_code = ''TRANSACTIONS''
			   AND  hdr.entity_id = en.entity_id
			   AND  trx.customer_trx_id = en.source_id_int_1
			   AND  hdr.application_id = 222
			   AND  hdr.ledger_id = en.ledger_id
			   AND  hdr.ae_header_id = ae.ae_header_id
			   AND  hdr.accounting_date between :gl_date_low and :gl_date_high
			   AND  ae.application_id = 222
			   AND  ae.accounting_class_code IN (''RECEIVABLE'')
			   AND  ae.ledger_id = en.ledger_id
			   AND  lk.event_id = hdr.event_id
         AND  lk.ae_header_id = ae.ae_header_id
         AND  lk.ae_line_num = ae.ae_line_num
         AND  lk.application_id = 222
         AND  lk.source_distribution_type = ''RA_CUST_TRX_LINE_GL_DIST_ALL''
			   '|| l_trx_org_where;

  IF p_co_seg_low IS NOT NULL OR p_co_seg_high IS NOT NULL THEN
    l_sales_journal_salect := l_sales_journal_salect ||'
                         AND    gc.code_combination_id = ae.code_combination_id
                        '||company_segment_where;
  END IF;

    l_adj_journal_select := 'SELECT (sum(nvl(ae.entered_dr,0))-  sum(nvl(ae.entered_cr,0))),
                                    (sum(nvl(ae.accounted_dr,0))- sum(nvl(ae.accounted_cr,0)))
                             FROM  '||l_adj_table||' adj,
			           xla_transaction_entities_upg en,
				   xla_ae_headers hdr,
				   xla_ae_lines ae ';

  IF p_co_seg_low IS NOT NULL OR p_co_seg_high IS NOT NULL THEN
    l_adj_journal_select := l_adj_journal_select||',
                                   gl_code_combinations gc';
  END IF;

    l_adj_journal_select := l_adj_journal_select||'
                            WHERE  en.application_id = 222
			      AND  en.ledger_id = '|| l_ledger_id ||'
			      AND  hdr.entity_id = en.entity_id
			      AND  adj.adjustment_id = en.source_id_int_1
			      AND  hdr.application_id = 222
			      AND  hdr.ledger_id = en.ledger_id
			      AND  hdr.ae_header_id = ae.ae_header_id
			      AND  hdr.accounting_date between :gl_date_low and :gl_date_high
			      AND  ae.application_id = 222
			      AND  ae.accounting_class_code IN (''RECEIVABLE'')
			      AND  ae.ledger_id = en.ledger_id
			      AND  EXISTS ( SELECT ''x''
			                      FROM xla_distribution_links lk
					     WHERE lk.event_id = hdr.event_id
					       AND lk.ae_header_id = ae.ae_header_id
					       AND lk.ae_line_num = ae.ae_line_num
					       AND lk.application_id = 222
					       AND lk.source_distribution_type = ''AR_DISTRIBUTIONS_ALL''
					       AND lk.event_class_code = ''ADJUSTMENT'')
                              '|| l_adj_org_where;

  IF p_co_seg_low IS NOT NULL OR p_co_seg_high IS NOT NULL THEN
    l_adj_journal_select := l_adj_journal_select||'
                             AND gc.code_combination_id = ae.code_combination_id
                            '||company_segment_where;
  END IF;

    l_app_journal_select := 'SELECT (sum(nvl(ae.entered_cr,0))- sum(nvl(ae.entered_dr,0))),
                                    (sum(nvl(ae.accounted_cr,0))- sum(nvl(ae.accounted_dr,0)))
                             FROM   '||l_cr_table ||' cr,
			            xla_transaction_entities_upg en,
				    xla_ae_headers hdr,
				    xla_ae_lines ae ';

  IF p_co_seg_low IS NOT NULL OR p_co_seg_high IS NOT NULL THEN
    l_app_journal_select := l_app_journal_select ||',
                                   gl_code_combinations gc';
  END IF;
    l_app_journal_select := l_app_journal_select||'
                            WHERE  en.application_id = 222
			      AND  en.ledger_id = '|| l_ledger_id ||'
			      AND  hdr.entity_id = en.entity_id
			      AND  cr.cash_receipt_id = en.source_id_int_1
			      AND  hdr.application_id = 222
			      AND  hdr.ledger_id = en.ledger_id
			      AND  hdr.ae_header_id = ae.ae_header_id
			      AND  hdr.accounting_date between :gl_date_low and :gl_date_high
			      AND  ae.application_id = 222
			      AND  ae.accounting_class_code IN (''RECEIVABLE'', ''EDISC'', ''UNEDISC'', ''UNPAID_BR'', ''REM_BR'', ''FAC_BR'')
			      AND  ae.ledger_id = en.ledger_id
			      AND  EXISTS ( SELECT ''x''
			                      FROM xla_distribution_links lk
					     WHERE lk.event_id = hdr.event_id
					       AND lk.ae_header_id = ae.ae_header_id
					       AND lk.ae_line_num = ae.ae_line_num
					       AND lk.application_id = 222
					       AND lk.source_distribution_type = ''AR_DISTRIBUTIONS_ALL''
					       AND lk.event_class_code = ''RECEIPT'')
                              '|| l_cr_org_where;

  IF p_co_seg_low IS NOT NULL OR p_co_seg_high IS NOT NULL THEN
    l_app_journal_select := l_app_journal_select||'
                               AND gc.code_combination_id = ae.code_combination_id
                              '||company_segment_where;
  END IF;

    l_unapp_journal_select := 'SELECT (sum(nvl(entered_cr,0))-  sum(nvl(entered_dr,0))),
                                      (sum(nvl(accounted_cr,0))- sum(nvl(accounted_dr,0)))
                                 FROM '||l_cr_table||' cr,
				      xla_transaction_entities_upg en,
				      xla_ae_headers hdr,
				      xla_ae_lines ae ';

  IF p_co_seg_low IS NOT NULL OR p_co_seg_high IS NOT NULL THEN
    l_unapp_journal_select := l_unapp_journal_select ||',
                                    gl_code_combinations gc ';
  END IF;

    l_unapp_journal_select := l_unapp_journal_select ||'
                              WHERE  en.application_id = 222
			        AND  en.ledger_id = '|| l_ledger_id ||'
				AND  hdr.entity_id = en.entity_id
				AND  cr.cash_receipt_id = en.source_id_int_1
				AND  hdr.application_id = 222
				AND  hdr.ledger_id = en.ledger_id
				AND  hdr.ae_header_id = ae.ae_header_id
				AND  hdr.accounting_date between :gl_date_low and :gl_date_high
				AND  ae.application_id = 222
				AND  ae.accounting_class_code IN (''CLAIM'',''PREPAY'',''UNAPP'',''UNID'',''ACC'')
				AND  ae.ledger_id = en.ledger_id
				'|| l_cr_org_where;

  IF p_co_seg_low IS NOT NULL OR p_co_seg_high IS NOT NULL THEN
    l_unapp_journal_select := l_unapp_journal_select ||'
                               AND   gc.code_combination_id = ae.code_combination_id
                             '||company_segment_where;
  END IF;

    l_cm_journal_select  := 'SELECT (sum(nvl(ae.accounted_cr,0))- sum(nvl(ae.accounted_dr,0)))
                             FROM '||l_trx_table||' trx,
			          xla_transaction_entities_upg en,
				  xla_ae_headers hdr,
				  xla_ae_lines ae ';

  IF p_co_seg_low IS NOT NULL OR p_co_seg_high IS NOT NULL THEN
    l_cm_journal_select  := l_cm_journal_select ||',
                                  gl_code_combinations gc';
  END IF;

    l_cm_journal_select  := l_cm_journal_select ||'
                            WHERE  en.application_id = 222
			      AND  en.ledger_id = '|| l_ledger_id ||'
			      AND  hdr.entity_id = en.entity_id
			      AND  trx.customer_trx_id = en.source_id_int_1
			      AND  hdr.application_id = 222
			      AND  hdr.ledger_id = en.ledger_id
			      AND  hdr.ae_header_id = ae.ae_header_id
			      AND  hdr.accounting_date between :gl_date_low and :gl_date_high
			      AND  ae.application_id = 222
			      AND  ae.ledger_id = en.ledger_id
			      AND  ae.accounting_class_code IN (''EXCHANGE_GAIN_LOSS'')
			      AND  EXISTS ( SELECT ''x''
			                      FROM xla_distribution_links lk
					     WHERE lk.event_id = hdr.event_id
					       AND lk.ae_header_id = ae.ae_header_id
					       AND lk.ae_line_num = ae.ae_line_num
					       AND lk.application_id = 222
					       AND lk.source_distribution_type = ''AR_DISTRIBUTIONS_ALL''
					       AND lk.event_class_code = ''CREDIT_MEMO'')
                             '|| l_trx_org_where;

  IF p_co_seg_low IS NOT NULL OR p_co_seg_high IS NOT NULL THEN
    l_cm_journal_select  := l_cm_journal_select ||'
                             AND   gc.code_combination_id = ae.code_combination_id
                             '||company_segment_where;
  END IF;

    --Bug7265328 Modifications End}

    v_cursor := dbms_sql.open_cursor;

    dbms_sql.parse(v_cursor,l_sales_journal_salect,DBMS_SQL.NATIVE);

    dbms_sql.bind_variable(v_cursor, ':gl_date_low', p_gl_date_low);
    dbms_sql.bind_variable(v_cursor, ':gl_date_high', p_gl_date_high);

    dbms_sql.define_column(v_cursor, 1, p_sales_journal_amt);
    dbms_sql.define_column(v_cursor, 2, p_sales_journal_acctd_amt);

    l_ignore := dbms_sql.execute(v_cursor);

    LOOP
      IF dbms_sql.fetch_rows(v_cursor) > 0 then
         dbms_sql.column_value(v_cursor, 1, p_sales_journal_amt);
         dbms_sql.column_value(v_cursor, 2, p_sales_journal_acctd_amt);
      ELSE
         EXIT;
      END IF;
    END LOOP;

    dbms_sql.parse(v_cursor,l_adj_journal_select,DBMS_SQL.NATIVE);

    dbms_sql.bind_variable(v_cursor, ':gl_date_low', p_gl_date_low);
    dbms_sql.bind_variable(v_cursor, ':gl_date_high', p_gl_date_high);

    dbms_sql.define_column(v_cursor, 1, p_adj_journal_amt);
    dbms_sql.define_column(v_cursor, 2, p_adj_journal_acctd_amt);

    l_ignore := dbms_sql.execute(v_cursor);

    LOOP
      IF dbms_sql.fetch_rows(v_cursor) > 0 then
         dbms_sql.column_value(v_cursor, 1, p_adj_journal_amt);
         dbms_sql.column_value(v_cursor, 2, p_adj_journal_acctd_amt);
      ELSE
         EXIT;
      END IF;
    END LOOP;

    dbms_sql.parse(v_cursor,l_app_journal_select,DBMS_SQL.NATIVE);

    dbms_sql.bind_variable(v_cursor, ':gl_date_low', p_gl_date_low);
    dbms_sql.bind_variable(v_cursor, ':gl_date_high', p_gl_date_high);

    dbms_sql.define_column(v_cursor, 1, p_app_journal_amt);
    dbms_sql.define_column(v_cursor, 2, p_app_journal_acctd_amt);

    l_ignore := dbms_sql.execute(v_cursor);

    LOOP
      IF dbms_sql.fetch_rows(v_cursor) > 0 then
         dbms_sql.column_value(v_cursor, 1, p_app_journal_amt);
         dbms_sql.column_value(v_cursor, 2, p_app_journal_acctd_amt);
      ELSE
         EXIT;
      END IF;
    END LOOP;

    dbms_sql.parse(v_cursor,l_unapp_journal_select,DBMS_SQL.NATIVE);

    dbms_sql.bind_variable(v_cursor, ':gl_date_low', p_gl_date_low);
    dbms_sql.bind_variable(v_cursor, ':gl_date_high', p_gl_date_high);

    dbms_sql.define_column(v_cursor, 1, p_unapp_journal_amt);
    dbms_sql.define_column(v_cursor, 2, p_unapp_journal_acctd_amt);

    l_ignore := dbms_sql.execute(v_cursor);

    LOOP
      IF dbms_sql.fetch_rows(v_cursor) > 0 then
         dbms_sql.column_value(v_cursor, 1, p_unapp_journal_amt);
         dbms_sql.column_value(v_cursor, 2, p_unapp_journal_acctd_amt);
      ELSE
         EXIT;
      END IF;
    END LOOP;

    dbms_sql.parse(v_cursor,l_cm_journal_select,DBMS_SQL.NATIVE);

    dbms_sql.bind_variable(v_cursor, ':gl_date_low', p_gl_date_low);
    dbms_sql.bind_variable(v_cursor, ':gl_date_high', p_gl_date_high);

    dbms_sql.define_column(v_cursor, 1,p_cm_journal_acctd_amt);

    l_ignore := dbms_sql.execute(v_cursor);

    LOOP
      IF dbms_sql.fetch_rows(v_cursor) > 0 then
         dbms_sql.column_value(v_cursor, 1,p_cm_journal_acctd_amt);
     ELSE
         EXIT;
      END IF;
    END LOOP;

   dbms_sql.close_cursor(v_cursor);

END journal_reports;


PROCEDURE get_report_heading ( p_reporting_level          IN  VARCHAR2,
                               p_reporting_entity_id      IN  NUMBER,
                               p_set_of_books_id          IN  NUMBER,
                               p_sob_name                 OUT NOCOPY VARCHAR2,
                               p_functional_currency      OUT NOCOPY VARCHAR2,
                               p_coa_id                   OUT NOCOPY NUMBER,
                               p_precision                OUT NOCOPY NUMBER,
                               p_sysdate                  OUT NOCOPY VARCHAR2,
                               p_organization             OUT NOCOPY VARCHAR2,
                               p_bills_receivable_flag    OUT NOCOPY VARCHAR2) IS
l_select_stmt      VARCHAR2(10000);
l_sysparam_table   VARCHAR2(50);
l_sysparam_where   VARCHAR2(10000); --Changed the data length from 2000 to 10000 - when testing for Bug:4942083
l_org_name         VARCHAR2(10000);
l_br_flag          VARCHAR2(1);
BEGIN

 ar_calc_aging.g_reporting_entity_id   := p_reporting_entity_id;

 IF NVL(ar_calc_aging.ca_sob_type,'P') = 'P' THEN
     l_sysparam_table := 'ar_system_parameters_all ';
  ELSE
     l_sysparam_table := 'ar_system_parameters_all_mrc_v ';
  END IF;

  XLA_MO_REPORTING_API.Initialize(p_reporting_level, p_reporting_entity_id, 'AUTO');

  l_sysparam_where     := XLA_MO_REPORTING_API.Get_Predicate('param',null);

  l_sysparam_where     := replace(l_sysparam_where,
                                  ':p_reporting_entity_id','ar_calc_aging.get_reporting_entity_id()');

  l_select_stmt := 'SELECT  sob.name sob_name,
                            sob.currency_code functional_currency,
                            sob.chart_of_accounts_id ,
                            cur.precision,
                            to_char(sysdate,''DD-MON-YYYY hh24:mi'') p_sysdate
                    FROM    gl_sets_of_books sob,
                            fnd_currencies cur
                    WHERE   sob.set_of_books_id = :p_set_of_books_id
                    AND     sob.currency_code = cur.currency_code';

  EXECUTE IMMEDIATE  l_select_stmt
     INTO p_sob_name,
          p_functional_currency,
          p_coa_id,
          p_precision,
          p_sysdate
   USING  p_set_of_books_id;

   IF p_reporting_level <> '3000' THEN
        select meaning
        into p_organization
        from ar_lookups
        where lookup_code = 'ALL'
        and lookup_type = 'ALL';
     BEGIN
       execute immediate
          'select ''Y''
          from dual
          where exists( select ''br_enabled''
                        from '||l_sysparam_table||' param
                        where bills_receivable_enabled_flag = ''Y''
                       '||l_sysparam_where||')'
       into br_enabled_flag;

     EXCEPTION WHEN OTHERS THEN
           br_enabled_flag := 'N';
     END;

   ELSE

    execute immediate 'select substr(hou.name,1,60) organization,
                             nvl(param.bills_receivable_enabled_flag,''N'')
                        from hr_organization_units hou,
                            '||l_sysparam_table||' param
                        where hou.organization_id = :org_id
                          and hou.organization_id = param.org_id'
    into p_organization,br_enabled_flag
    using p_reporting_entity_id;

   END IF;

    IF nvl(br_enabled_flag,'N') <> 'Y' THEN
       br_enabled_flag := 'N';
    END IF;

    p_bills_receivable_flag := br_enabled_flag;

END get_report_heading;

END ar_calc_aging ;

/
