--------------------------------------------------------
--  DDL for Package Body AR_CMGT_AGING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CMGT_AGING" AS
/* $Header: ARCMAGEB.pls 120.5 2006/06/01 05:56:26 kjoshi noship $ */

--
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

pg_source_name      VARCHAR2(30) := nvl(AR_CMGT_DATA_POINTS_PKG.g_source_name,'OCM');
pg_source_id        VARCHAR2(45) := nvl(AR_CMGT_DATA_POINTS_PKG.g_source_id,-99);

PROCEDURE calc_aging_buckets (
        p_party_id        	IN NUMBER,
        p_customer_id           IN NUMBER,
        p_site_use_id           IN NUMBER,
        p_currency_code      	IN VARCHAR2,
        p_credit_option      	IN VARCHAR2,
        p_bucket_name		IN VARCHAR2,
        p_org_id                IN NUMBER,
        p_exchange_rate_type    IN VARCHAR2,
        p_source                IN VARCHAR2 default NULL,
        p_outstanding_balance	IN OUT NOCOPY NUMBER,
        p_bucket_titletop_0	OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_0	OUT NOCOPY VARCHAR2,
        p_bucket_amount_0       IN OUT NOCOPY NUMBER,
        p_bucket_titletop_1	OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_1	OUT NOCOPY VARCHAR2,
        p_bucket_amount_1       IN OUT NOCOPY NUMBER,
        p_bucket_titletop_2	OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_2	OUT NOCOPY VARCHAR2,
        p_bucket_amount_2       IN OUT NOCOPY NUMBER,
        p_bucket_titletop_3	OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_3	OUT NOCOPY VARCHAR2,
        p_bucket_amount_3       IN OUT NOCOPY NUMBER,
        p_bucket_titletop_4	OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_4	OUT NOCOPY VARCHAR2,
        p_bucket_amount_4       IN OUT NOCOPY NUMBER,
        p_bucket_titletop_5	OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_5	OUT NOCOPY VARCHAR2,
        p_bucket_amount_5       IN OUT NOCOPY NUMBER,
        p_bucket_titletop_6	OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_6	OUT NOCOPY VARCHAR2,
        p_bucket_amount_6       IN OUT NOCOPY NUMBER
) IS
   v_amount_due_remaining NUMBER;
   v_bucket_0 NUMBER;
   v_bucket_1 NUMBER;
   v_bucket_2 NUMBER;
   v_bucket_3 NUMBER;
   v_bucket_4 NUMBER;
   v_bucket_5 NUMBER;
   v_bucket_6 NUMBER;
   v_bucket_category    ar_aging_bucket_lines.type%TYPE;
--
   v_bucket_line_type_0 ar_aging_bucket_lines.type%TYPE;
   v_bucket_days_from_0 NUMBER;
   v_bucket_days_to_0   NUMBER;
   v_bucket_line_type_1 ar_aging_bucket_lines.type%TYPE;
   v_bucket_days_from_1 NUMBER;
   v_bucket_days_to_1   NUMBER;
   v_bucket_line_type_2 ar_aging_bucket_lines.type%TYPE;
   v_bucket_days_from_2 NUMBER;
   v_bucket_days_to_2   NUMBER;
   v_bucket_line_type_3 ar_aging_bucket_lines.type%TYPE;
   v_bucket_days_from_3 NUMBER;
   v_bucket_days_to_3   NUMBER;
   v_bucket_line_type_4 ar_aging_bucket_lines.type%TYPE;
   v_bucket_days_from_4 NUMBER;
   v_bucket_days_to_4   NUMBER;
   v_bucket_line_type_5 ar_aging_bucket_lines.type%TYPE;
   v_bucket_days_from_5 NUMBER;
   v_bucket_days_to_5   NUMBER;
   v_bucket_line_type_6 ar_aging_bucket_lines.type%TYPE;
   v_bucket_days_from_6 NUMBER;
   v_bucket_days_to_6   NUMBER;
   v_outstanding_balance_1 NUMBER :=0;
   v_outstanding_balance_2 NUMBER :=0;
   v_outstanding_balance_3 NUMBER :=0;
   v_outstanding_balance_4 NUMBER :=0;
   v_bucket_amount_1_0   NUMBER :=0;
   v_bucket_amount_1_1   NUMBER :=0;
   v_bucket_amount_1_2   NUMBER :=0;
   v_bucket_amount_1_3   NUMBER :=0;
   v_bucket_amount_1_4   NUMBER :=0;
   v_bucket_amount_1_5   NUMBER :=0;
   v_bucket_amount_1_6   NUMBER :=0;
   v_bucket_amount_2_0   NUMBER :=0;
   v_bucket_amount_2_1   NUMBER :=0;
   v_bucket_amount_2_2   NUMBER :=0;
   v_bucket_amount_2_3   NUMBER :=0;
   v_bucket_amount_2_4   NUMBER :=0;
   v_bucket_amount_2_5   NUMBER :=0;
   v_bucket_amount_2_6   NUMBER :=0;
   v_bucket_amount_3_0   NUMBER :=0;
   v_bucket_amount_3_1   NUMBER :=0;
   v_bucket_amount_3_2   NUMBER :=0;
   v_bucket_amount_3_3   NUMBER :=0;
   v_bucket_amount_3_4   NUMBER :=0;
   v_bucket_amount_3_5   NUMBER :=0;
   v_bucket_amount_3_6   NUMBER :=0;
   v_bucket_amount_4_0   NUMBER :=0;
   v_bucket_amount_4_1   NUMBER :=0;
   v_bucket_amount_4_2   NUMBER :=0;
   v_bucket_amount_4_3   NUMBER :=0;
   v_bucket_amount_4_4   NUMBER :=0;
   v_bucket_amount_4_5   NUMBER :=0;
   v_bucket_amount_4_6   NUMBER :=0;
--
   l_as_of_date   DATE := trunc(sysdate);

   -- Variables for ar_cmgt_util.get_limit_currency procedure
   l_limit_currency                VARCHAR2(30);
   l_trx_limit                     NUMBER;
   l_overall_limit                 NUMBER;
   l_cust_acct_profile_amt_id      NUMBER;
   l_global_exposure_flag          hz_credit_usage_rule_sets_b.global_exposure_flag%type;
   l_include_all_flag              VARCHAR2(1);
   l_curr_tbl                      HZ_CREDIT_USAGES_PKG.curr_tbl_type;
   l_excl_curr_list                VARCHAR2(2000);

   CURSOR c_sel_bucket_data is
        select lines.days_start,
               lines.days_to,
               lines.report_heading1,
               lines.report_heading2,
               lines.type
        from   ar_aging_bucket_lines    lines,
               ar_aging_buckets         buckets
        where  lines.aging_bucket_id      = buckets.aging_bucket_id
        and    upper(buckets.bucket_name) = upper(p_bucket_name)
        and nvl(buckets.status,'A')       = 'A'
        order  by lines.bucket_sequence_num
        ;
--
/* bug4887799 : Cursor c_buckets is divided into multiple cursors
                to improve performance */
   CURSOR c_buckets1 IS
select sum(adr), sum(bucket0), sum(bucket1), sum(bucket2),
       sum(bucket3), sum(bucket4), sum(bucket5),sum(bucket6)
from(
 SELECT sum( gl_currency_api.convert_amount(
                             ps.invoice_currency_code,
                             p_currency_code,
                             sysdate,
                             p_exchange_rate_type,
                             ps.amount_due_remaining)) adr,
        sum(arpt_sql_func_util.bucket_function(v_bucket_line_type_0,
            ps.amount_in_dispute,ps.amount_adjusted_pending,v_bucket_days_from_0,
            v_bucket_days_to_0,ps.due_date,v_bucket_category,l_as_of_date)
                 * gl_currency_api.convert_amount(
                             ps.invoice_currency_code,
                             p_currency_code,
                             sysdate,
                             p_exchange_rate_type,
                             ps.amount_due_remaining)) bucket0 ,
        sum(arpt_sql_func_util.bucket_function(v_bucket_line_type_1,
            ps.amount_in_dispute,ps.amount_adjusted_pending,v_bucket_days_from_1,
            v_bucket_days_to_1,ps.due_date,v_bucket_category,l_as_of_date)
                 * gl_currency_api.convert_amount(
                             ps.invoice_currency_code,
                             p_currency_code,
                             sysdate,
                             p_exchange_rate_type,
                             ps.amount_due_remaining)) bucket1 ,
        sum(arpt_sql_func_util.bucket_function(v_bucket_line_type_2,
            ps.amount_in_dispute,ps.amount_adjusted_pending,v_bucket_days_from_2,
            v_bucket_days_to_2,ps.due_date,v_bucket_category,l_as_of_date)
                 * gl_currency_api.convert_amount(
                             ps.invoice_currency_code,
                             p_currency_code,
                             sysdate,
                             p_exchange_rate_type,
                             ps.amount_due_remaining)) bucket2 ,
        sum(arpt_sql_func_util.bucket_function(v_bucket_line_type_3,
            ps.amount_in_dispute,ps.amount_adjusted_pending,v_bucket_days_from_3,
            v_bucket_days_to_3,ps.due_date,v_bucket_category,l_as_of_date)
                 * gl_currency_api.convert_amount(
                             ps.invoice_currency_code,
                             p_currency_code,
                             sysdate,
                             p_exchange_rate_type,
                             ps.amount_due_remaining)) bucket3 ,
        sum(arpt_sql_func_util.bucket_function(v_bucket_line_type_4,
            ps.amount_in_dispute,ps.amount_adjusted_pending,v_bucket_days_from_4,
            v_bucket_days_to_4,ps.due_date,v_bucket_category,l_as_of_date)
                 * gl_currency_api.convert_amount(
                             ps.invoice_currency_code,
                             p_currency_code,
                             sysdate,
                             p_exchange_rate_type,
                             ps.amount_due_remaining)) bucket4 ,
        sum(arpt_sql_func_util.bucket_function(v_bucket_line_type_5,
            ps.amount_in_dispute,ps.amount_adjusted_pending,v_bucket_days_from_5,
            v_bucket_days_to_5,ps.due_date,v_bucket_category,l_as_of_date)
                 * gl_currency_api.convert_amount(
                             ps.invoice_currency_code,
                             p_currency_code,
                             sysdate,
                             p_exchange_rate_type,
                             ps.amount_due_remaining)) bucket5 ,
        sum(arpt_sql_func_util.bucket_function(v_bucket_line_type_6,
            ps.amount_in_dispute,ps.amount_adjusted_pending,v_bucket_days_from_6,
            v_bucket_days_to_6,ps.due_date,v_bucket_category,l_as_of_date)
                 * gl_currency_api.convert_amount(
                             ps.invoice_currency_code,
                             p_currency_code,
                             sysdate,
                             p_exchange_rate_type,
                             ps.amount_due_remaining)) bucket6
    FROM  ar_payment_schedules_all  ps
    WHERE payment_schedule_id +0 > 0
    AND    ps.class NOT IN ('GUAR', 'PMT')
    --kjoshi bug#5169416
    AND    nvl(sign(ps.cons_inv_id),0) = decode(p_source,'CONS_BILL',1,0) --apandit BFB changes
    AND    trx_date        <= l_as_of_date
    AND    actual_date_closed > l_as_of_date
    and    ps.customer_id  in (select cust_account_id
                                FROM   hz_cust_accounts
                                WHERE  party_id in
                                ( SELECT child_id
                                  from hz_hierarchy_nodes
                                  where parent_object_type = 'ORGANIZATION'
                                  and parent_table_name = 'HZ_PARTIES'
                                  and child_object_type = 'ORGANIZATION'
                                  and parent_id = p_party_id
                                  and effective_start_date <= l_as_of_date
                                  and effective_end_date >= l_as_of_date
                                  and  hierarchy_type =
                                     FND_PROFILE.VALUE('AR_CMGT_HIERARCHY_TYPE')
                                  and  pg_source_name <> 'LNS'
                                  union
                                  select p_party_id from dual
                                  UNION
                                  select hz_party_id
										from LNS_LOAN_PARTICIPANTS_V
										where loan_id = pg_source_id
										and   participant_type_code = 'COBORROWER'
										and   pg_source_name = 'LNS'
										and (end_date_active is null OR
      										(sysdate between start_date_active and end_date_active)
  												)
                                 )
                                union
                                select p_customer_id  from dual
                               )
  and    decode(p_site_use_id,
                NULL, ps.customer_site_use_id,
                p_site_use_id)        = ps.customer_site_use_id
  and    ((ps.invoice_currency_code = p_currency_code
           and  p_source = 'CONS_BILL')
           or (nvl(p_source,'x') <> 'CONS_BILL' and
            ps.invoice_currency_code in
               (select currency
                 from ar_cmgt_curr_usage_gt)))
         ) ;
   CURSOR c_buckets2 IS
select sum(adr), sum(bucket0), sum(bucket1), sum(bucket2),
       sum(bucket3), sum(bucket4), sum(bucket5),sum(bucket6)
from(
   -----All the receipt and CM applications after the as of date ---------
    SELECT
        sum( gl_currency_api.convert_amount(
                             ps.invoice_currency_code,
                             p_currency_code,
                             sysdate,
                             p_exchange_rate_type,
                             (ra.amount_applied +
                              NVL(ra.earned_discount_taken,0)
                            + NVL(ra.unearned_discount_taken,0) ))) adr,
        sum(arpt_sql_func_util.bucket_function(v_bucket_line_type_0,
            ps.amount_in_dispute,ps.amount_adjusted_pending,v_bucket_days_from_0,
            v_bucket_days_to_0,ps.due_date,v_bucket_category,l_as_of_date)
                 * gl_currency_api.convert_amount(
                             ps.invoice_currency_code,
                             p_currency_code,
                             sysdate,
                             p_exchange_rate_type,
                             (ra.amount_applied +
                              NVL(ra.earned_discount_taken,0)
                            + NVL(ra.unearned_discount_taken,0) ))) bucket0 ,
        sum(arpt_sql_func_util.bucket_function(v_bucket_line_type_1,
            ps.amount_in_dispute,ps.amount_adjusted_pending,v_bucket_days_from_1,
            v_bucket_days_to_1,ps.due_date,v_bucket_category,l_as_of_date)
                 * gl_currency_api.convert_amount(
                             ps.invoice_currency_code,
                             p_currency_code,
                             sysdate,
                             p_exchange_rate_type,
                             (ra.amount_applied +
                              NVL(ra.earned_discount_taken,0)
                            + NVL(ra.unearned_discount_taken,0) ))) bucket1 ,
        sum(arpt_sql_func_util.bucket_function(v_bucket_line_type_2,
            ps.amount_in_dispute,ps.amount_adjusted_pending,v_bucket_days_from_2,
            v_bucket_days_to_2,ps.due_date,v_bucket_category,l_as_of_date)
                 * gl_currency_api.convert_amount(
                             ps.invoice_currency_code,
                             p_currency_code,
                             sysdate,
                             p_exchange_rate_type,
                             (ra.amount_applied +
                              NVL(ra.earned_discount_taken,0)
                            + NVL(ra.unearned_discount_taken,0) ))) bucket2 ,
        sum(arpt_sql_func_util.bucket_function(v_bucket_line_type_3,
            ps.amount_in_dispute,ps.amount_adjusted_pending,v_bucket_days_from_3,
            v_bucket_days_to_3,ps.due_date,v_bucket_category,l_as_of_date)
                 * gl_currency_api.convert_amount(
                             ps.invoice_currency_code,
                             p_currency_code,
                             sysdate,
                             p_exchange_rate_type,
                             (ra.amount_applied +
                              NVL(ra.earned_discount_taken,0)
                            + NVL(ra.unearned_discount_taken,0) ))) bucket3 ,
        sum(arpt_sql_func_util.bucket_function(v_bucket_line_type_4,
            ps.amount_in_dispute,ps.amount_adjusted_pending,v_bucket_days_from_4,
            v_bucket_days_to_4,ps.due_date,v_bucket_category,l_as_of_date)
                 * gl_currency_api.convert_amount(
                             ps.invoice_currency_code,
                             p_currency_code,
                             sysdate,
                             p_exchange_rate_type,
                             (ra.amount_applied +
                              NVL(ra.earned_discount_taken,0)
                            + NVL(ra.unearned_discount_taken,0) ))) bucket4 ,
        sum(arpt_sql_func_util.bucket_function(v_bucket_line_type_5,
            ps.amount_in_dispute,ps.amount_adjusted_pending,v_bucket_days_from_5,
            v_bucket_days_to_5,ps.due_date,v_bucket_category,l_as_of_date)
                 * gl_currency_api.convert_amount(
                             ps.invoice_currency_code,
                             p_currency_code,
                             sysdate,
                             p_exchange_rate_type,
                             (ra.amount_applied +
                              NVL(ra.earned_discount_taken,0)
                            + NVL(ra.unearned_discount_taken,0) ))) bucket5 ,
        sum(arpt_sql_func_util.bucket_function(v_bucket_line_type_6,
            ps.amount_in_dispute,ps.amount_adjusted_pending,v_bucket_days_from_6,
            v_bucket_days_to_6,ps.due_date,v_bucket_category,l_as_of_date)
                 * gl_currency_api.convert_amount(
                             ps.invoice_currency_code,
                             p_currency_code,
                             sysdate,
                             p_exchange_rate_type,
                             (ra.amount_applied +
                              NVL(ra.earned_discount_taken,0)
                            + NVL(ra.unearned_discount_taken,0) ))) bucket6
   FROM
     ar_payment_schedules_all  ps,
     ar_receivable_applications_all ra
   WHERE ra.applied_payment_schedule_id = ps.payment_schedule_id
    --kjoshi bug#5169416
    AND  nvl(sign(ps.cons_inv_id),0) = decode(p_source,'CONS_BILL',1,0)
    AND  ps.payment_schedule_id +0 > 0
    AND  ra.apply_date > l_as_of_date
    AND  ra.status = 'APP'
    AND    ps.class NOT IN ('GUAR', 'PMT')
    AND  ps.trx_date     <= l_as_of_date
    AND  ps.actual_date_closed > l_as_of_date
    AND  NVL(ra.confirmed_flag,'Y') = 'Y'
    and    ps.customer_id  in (select cust_account_id
                                FROM   hz_cust_accounts
                                WHERE  party_id in
                                ( SELECT child_id
                                  from hz_hierarchy_nodes
                                  where parent_object_type = 'ORGANIZATION'
                                  and parent_table_name = 'HZ_PARTIES'
                                  and child_object_type = 'ORGANIZATION'
                                  and parent_id = p_party_id
                                  and effective_start_date <= l_as_of_date
                                  and effective_end_date >= l_as_of_date
                                  and  hierarchy_type =
                                     FND_PROFILE.VALUE('AR_CMGT_HIERARCHY_TYPE')
                                  and  pg_source_name <> 'LNS'
                                  union
                                  select p_party_id from dual
                                  UNION
										select hz_party_id
										from LNS_LOAN_PARTICIPANTS_V
										where loan_id = pg_source_id
										and   participant_type_code = 'COBORROWER'
										and   pg_source_name = 'LNS'
										and (end_date_active is null OR
      										(sysdate between start_date_active and end_date_active)
  												)
                                 )
                                union
                                select p_customer_id  from dual
                               )
  and    decode(p_site_use_id,
                NULL, ps.customer_site_use_id,
                p_site_use_id)        = ps.customer_site_use_id
  and    ((ps.invoice_currency_code = p_currency_code
           and  p_source = 'CONS_BILL')
           or (nvl(p_source,'x') <> 'CONS_BILL' and
            ps.invoice_currency_code in
               (select currency
                 from ar_cmgt_curr_usage_gt)))
         ) ;
   CURSOR c_buckets3 IS
select sum(adr), sum(bucket0), sum(bucket1), sum(bucket2),
       sum(bucket3), sum(bucket4), sum(bucket5),sum(bucket6)
from(
   ------------All the adjustments after the as of date---------------
   SELECT
       -sum(gl_currency_api.convert_amount(
                             ps.invoice_currency_code,
                             p_currency_code,
                             sysdate,
                             p_exchange_rate_type,
                             adj.amount)) adr,
       -sum(arpt_sql_func_util.bucket_function(v_bucket_line_type_0,
            ps.amount_in_dispute,ps.amount_adjusted_pending,v_bucket_days_from_0,
            v_bucket_days_to_0,ps.due_date,v_bucket_category,l_as_of_date)
                 * gl_currency_api.convert_amount(
                             ps.invoice_currency_code,
                             p_currency_code,
                             sysdate,
                             p_exchange_rate_type,
                             adj.amount)) bucket0 ,
       -sum(arpt_sql_func_util.bucket_function(v_bucket_line_type_1,
            ps.amount_in_dispute,ps.amount_adjusted_pending,v_bucket_days_from_1,
            v_bucket_days_to_1,ps.due_date,v_bucket_category,l_as_of_date)
                 * gl_currency_api.convert_amount(
                             ps.invoice_currency_code,
                             p_currency_code,
                             sysdate,
                             p_exchange_rate_type,
                             adj.amount)) bucket1 ,
       -sum(arpt_sql_func_util.bucket_function(v_bucket_line_type_2,
            ps.amount_in_dispute,ps.amount_adjusted_pending,v_bucket_days_from_2,
            v_bucket_days_to_2,ps.due_date,v_bucket_category,l_as_of_date)
                 * gl_currency_api.convert_amount(
                             ps.invoice_currency_code,
                             p_currency_code,
                             sysdate,
                             p_exchange_rate_type,
                             adj.amount)) bucket2 ,
       -sum(arpt_sql_func_util.bucket_function(v_bucket_line_type_3,
            ps.amount_in_dispute,ps.amount_adjusted_pending,v_bucket_days_from_3,
            v_bucket_days_to_3,ps.due_date,v_bucket_category,l_as_of_date)
                 * gl_currency_api.convert_amount(
                             ps.invoice_currency_code,
                             p_currency_code,
                             sysdate,
                             p_exchange_rate_type,
                             adj.amount)) bucket3 ,
       -sum(arpt_sql_func_util.bucket_function(v_bucket_line_type_4,
            ps.amount_in_dispute,ps.amount_adjusted_pending,v_bucket_days_from_4,
            v_bucket_days_to_4,ps.due_date,v_bucket_category,l_as_of_date)
                 * gl_currency_api.convert_amount(
                             ps.invoice_currency_code,
                             p_currency_code,
                             sysdate,
                             p_exchange_rate_type,
                             adj.amount)) bucket4 ,
       -sum(arpt_sql_func_util.bucket_function(v_bucket_line_type_5,
            ps.amount_in_dispute,ps.amount_adjusted_pending,v_bucket_days_from_5,
            v_bucket_days_to_5,ps.due_date,v_bucket_category,l_as_of_date)
                 * gl_currency_api.convert_amount(
                             ps.invoice_currency_code,
                             p_currency_code,
                             sysdate,
                             p_exchange_rate_type,
                             adj.amount)) bucket5 ,
       -sum(arpt_sql_func_util.bucket_function(v_bucket_line_type_6,
            ps.amount_in_dispute,ps.amount_adjusted_pending,v_bucket_days_from_6,
            v_bucket_days_to_6,ps.due_date,v_bucket_category,l_as_of_date)
                 * gl_currency_api.convert_amount(
                             ps.invoice_currency_code,
                             p_currency_code,
                             sysdate,
                             p_exchange_rate_type,
                             adj.acctd_amount)) bucket6
      FROM  ar_adjustments_all adj,
            ar_payment_schedules_all ps
      WHERE adj.payment_schedule_id = ps.payment_schedule_id
      --kjoshi bug#5169416
      AND    nvl(sign(ps.cons_inv_id),0) = decode(p_source,'CONS_BILL',1,0) --apandit BFB changes
      AND   adj.apply_date > l_as_of_date
      AND    ps.class NOT IN ('GUAR', 'PMT')
      AND   ps.trx_date        <= l_as_of_date
      AND   ps.actual_date_closed > l_as_of_date
      AND   adj.status = 'A'
      and   ps.customer_id  in (select cust_account_id
                                FROM   hz_cust_accounts
                                WHERE  party_id in
                                ( SELECT child_id
                                  from hz_hierarchy_nodes
                                  where parent_object_type = 'ORGANIZATION'
                                  and parent_table_name = 'HZ_PARTIES'
                                  and child_object_type = 'ORGANIZATION'
                                  and parent_id = p_party_id
                                  and effective_start_date <= l_as_of_date
                                  and effective_end_date >= l_as_of_date
                                  and  hierarchy_type =
                                     FND_PROFILE.VALUE('AR_CMGT_HIERARCHY_TYPE')
                                  and  pg_source_name <> 'LNS'
                                  union
                                  select p_party_id from dual
                                  UNION
										select hz_party_id
										from LNS_LOAN_PARTICIPANTS_V
										where loan_id = pg_source_id
										and   participant_type_code = 'COBORROWER'
										and   pg_source_name = 'LNS'
										and (end_date_active is null OR
      										(sysdate between start_date_active and end_date_active)
  												)
                                 )
                                union
                                select p_customer_id  from dual
                               )
    and    decode(p_site_use_id,
                NULL, ps.customer_site_use_id,
                p_site_use_id)        = ps.customer_site_use_id
   and    ((ps.invoice_currency_code = p_currency_code
           and  p_source = 'CONS_BILL')
           or (nvl(p_source,'x') <> 'CONS_BILL' and
            ps.invoice_currency_code in
               (select currency
                 from ar_cmgt_curr_usage_gt)))
         ) ;
   CURSOR c_buckets4 IS
select sum(adr), sum(bucket0), sum(bucket1), sum(bucket2),
       sum(bucket3), sum(bucket4), sum(bucket5),sum(bucket6)
from(
 ---------all the CM applications after the as of date -----------
 SELECT sum(gl_currency_api.convert_amount(
                             ps.invoice_currency_code,
                             p_currency_code,
                             sysdate,
                             p_exchange_rate_type,
                             (ra.amount_applied_from +
                             NVL(ra.earned_discount_taken,0)
                           + NVL(ra.unearned_discount_taken,0) ))) adr,
       -sum(arpt_sql_func_util.bucket_function(v_bucket_line_type_0,
            ps.amount_in_dispute,ps.amount_adjusted_pending,v_bucket_days_from_0,
            v_bucket_days_to_0,ps.due_date,v_bucket_category,l_as_of_date)
                 * gl_currency_api.convert_amount(
                             ps.invoice_currency_code,
                             p_currency_code,
                             sysdate,
                             p_exchange_rate_type,
                             (ra.amount_applied_from +
                             NVL(ra.earned_discount_taken,0)
                           + NVL(ra.unearned_discount_taken,0) ))) bucket0 ,
       -sum(arpt_sql_func_util.bucket_function(v_bucket_line_type_1,
            ps.amount_in_dispute,ps.amount_adjusted_pending,v_bucket_days_from_1,
            v_bucket_days_to_1,ps.due_date,v_bucket_category,l_as_of_date)
                 * gl_currency_api.convert_amount(
                             ps.invoice_currency_code,
                             p_currency_code,
                             sysdate,
                             p_exchange_rate_type,
                             (ra.amount_applied_from +
                             NVL(ra.earned_discount_taken,0)
                           + NVL(ra.unearned_discount_taken,0) ))) bucket1 ,
       -sum(arpt_sql_func_util.bucket_function(v_bucket_line_type_2,
            ps.amount_in_dispute,ps.amount_adjusted_pending,v_bucket_days_from_2,
            v_bucket_days_to_2,ps.due_date,v_bucket_category,l_as_of_date)
                 * gl_currency_api.convert_amount(
                             ps.invoice_currency_code,
                             p_currency_code,
                             sysdate,
                             p_exchange_rate_type,
                             (ra.amount_applied_from +
                             NVL(ra.earned_discount_taken,0)
                           + NVL(ra.unearned_discount_taken,0) ))) bucket2 ,
       -sum(arpt_sql_func_util.bucket_function(v_bucket_line_type_3,
            ps.amount_in_dispute,ps.amount_adjusted_pending,v_bucket_days_from_3,
            v_bucket_days_to_3,ps.due_date,v_bucket_category,l_as_of_date)
                 * gl_currency_api.convert_amount(
                             ps.invoice_currency_code,
                             p_currency_code,
                             sysdate,
                             p_exchange_rate_type,
                             (ra.amount_applied_from +
                             NVL(ra.earned_discount_taken,0)
                           + NVL(ra.unearned_discount_taken,0) ))) bucket3 ,
       -sum(arpt_sql_func_util.bucket_function(v_bucket_line_type_4,
            ps.amount_in_dispute,ps.amount_adjusted_pending,v_bucket_days_from_4,
            v_bucket_days_to_4,ps.due_date,v_bucket_category,l_as_of_date)
                 * gl_currency_api.convert_amount(
                             ps.invoice_currency_code,
                             p_currency_code,
                             sysdate,
                             p_exchange_rate_type,
                             (ra.amount_applied_from +
                             NVL(ra.earned_discount_taken,0)
                           + NVL(ra.unearned_discount_taken,0) ))) bucket4 ,
       -sum(arpt_sql_func_util.bucket_function(v_bucket_line_type_5,
            ps.amount_in_dispute,ps.amount_adjusted_pending,v_bucket_days_from_5,
            v_bucket_days_to_5,ps.due_date,v_bucket_category,l_as_of_date)
                 * gl_currency_api.convert_amount(
                             ps.invoice_currency_code,
                             p_currency_code,
                             sysdate,
                             p_exchange_rate_type,
                             (ra.amount_applied_from +
                             NVL(ra.earned_discount_taken,0)
                           + NVL(ra.unearned_discount_taken,0) ))) bucket5 ,
       -sum(arpt_sql_func_util.bucket_function(v_bucket_line_type_6,
            ps.amount_in_dispute,ps.amount_adjusted_pending,v_bucket_days_from_6,
            v_bucket_days_to_6,ps.due_date,v_bucket_category,l_as_of_date)
                 * gl_currency_api.convert_amount(
                             ps.invoice_currency_code,
                             p_currency_code,
                             sysdate,
                             p_exchange_rate_type,
                             (ra.amount_applied_from +
                             NVL(ra.earned_discount_taken,0)
                           + NVL(ra.unearned_discount_taken,0) ))) bucket6
FROM  ar_payment_schedules_all  ps,
      ar_receivable_applications_all ra
WHERE
    ps.payment_schedule_id +0 > 0
    AND ra.payment_schedule_id = ps.payment_schedule_id
    --kjoshi bug#5169416
    AND    nvl(sign(ps.cons_inv_id),0) = decode(p_source,'CONS_BILL',1,0) --apandit BFB changes
    AND  ra.apply_date > l_as_of_date
    AND    ps.class NOT IN ('GUAR', 'PMT')
    AND  ra.status = 'APP'
    and  ra.application_type = 'CM'
    AND  ps.trx_date        <= l_as_of_date
    AND  ps.actual_date_closed > l_as_of_date
    AND  NVL(ra.confirmed_flag,'Y') = 'Y'
    and   ps.customer_id  in (select cust_account_id
                                FROM   hz_cust_accounts
                                WHERE  party_id in
                                ( SELECT child_id
                                  from hz_hierarchy_nodes
                                  where parent_object_type = 'ORGANIZATION'
                                  and parent_table_name = 'HZ_PARTIES'
                                  and child_object_type = 'ORGANIZATION'
                                  and parent_id = p_party_id
                                  and effective_start_date <= l_as_of_date
                                  and effective_end_date >= l_as_of_date
                                  and  hierarchy_type =
                                     FND_PROFILE.VALUE('AR_CMGT_HIERARCHY_TYPE')
                                  and  pg_source_name <> 'LNS'
                                  union
                                  select p_party_id from dual
                                  UNION
										select hz_party_id
										from LNS_LOAN_PARTICIPANTS_V
										where loan_id = pg_source_id
										and   participant_type_code = 'COBORROWER'
										and   pg_source_name = 'LNS'
										and (end_date_active is null OR
      										(sysdate between start_date_active and end_date_active)
  												)
                                 )
                                union
                                select p_customer_id  from dual
                               )
    and    decode(p_site_use_id,
                NULL, ps.customer_site_use_id,
                p_site_use_id)        = ps.customer_site_use_id
    and    ((ps.invoice_currency_code = p_currency_code
           and  p_source = 'CONS_BILL')
           or (nvl(p_source,'x') <> 'CONS_BILL' and
            ps.invoice_currency_code in
               (select currency
                 from ar_cmgt_curr_usage_gt)))
         ) ;
BEGIN

-- Put in the currencies in the global temporary table
-- commenting out the following code because, if aging is called
-- from top ten exposure report then user need to see the aging
-- for all currencies, whether the customer has case folder or not.
   IF (p_source = 'PERF_REPORT') THEN
       /* AR_CMGT_UTIL.get_limit_currency(
                p_party_id              =>  p_party_id,
                p_cust_account_id       =>  p_customer_id,
                p_cust_acct_site_id     =>  p_site_use_id,
                p_trx_currency_code     =>  p_currency_code,
                p_limit_curr_code       =>  l_limit_currency,
                p_trx_limit             =>  l_trx_limit,
                p_overall_limit         =>  l_overall_limit,
                p_cust_acct_profile_amt_id => l_cust_acct_profile_amt_id,
                p_global_exposure_flag  =>  l_global_exposure_flag,
                p_include_all_flag      =>  l_include_all_flag,
                p_usage_curr_tbl        =>  l_curr_tbl,
                p_excl_curr_list        =>  l_excl_curr_list);

       IF (  (nvl(l_include_all_flag,'N') = 'N') and l_limit_currency IS NOT NULL )
       THEN
          for  i in 1..l_curr_tbl.COUNT
          LOOP
             INSERT INTO ar_cmgt_curr_usage_gt ( credit_request_id, currency) values
                ( NULL, l_curr_tbl(i).usage_curr_code);
          END LOOP;
       ELSE
          -- populate temp table with all currency. may not be a good soulution
          -- to take this approach. Would be better to have another cursor.
          INSERT INTO ar_cmgt_curr_usage_gt(currency)
             ( select distinct currency from ar_trx_bal_summary);
       END IF; */
          INSERT INTO ar_cmgt_curr_usage_gt(currency)
             ( select distinct currency from ar_trx_bal_summary);
   END IF;

--
-- Get the aging buckets definition.
--
   OPEN c_sel_bucket_data;
   FETCH c_sel_bucket_data INTO v_bucket_days_from_0, v_bucket_days_to_0,
                                   p_bucket_titletop_0, p_bucket_titlebottom_0,
                                   v_bucket_line_type_0;
   IF c_sel_bucket_data%FOUND THEN
      p_bucket_amount_0 := 0;
      IF (v_bucket_line_type_0 = 'DISPUTE_ONLY') OR
         (v_bucket_line_type_0 =  'PENDADJ_ONLY') OR
         (v_bucket_line_type_0 =  'DISPUTE_PENDADJ') THEN
         v_bucket_category := v_bucket_line_type_0;
      END IF;
      FETCH c_sel_bucket_data INTO v_bucket_days_from_1, v_bucket_days_to_1,
                                   p_bucket_titletop_1, p_bucket_titlebottom_1,
                                   v_bucket_line_type_1;
   ELSE
      p_bucket_titletop_0    := NULL;
      p_bucket_titlebottom_0 := NULL;
      p_bucket_amount_0      := NULL;
   END IF;
   IF c_sel_bucket_data%FOUND THEN
      p_bucket_amount_1 := 0;
      IF (v_bucket_line_type_1 = 'DISPUTE_ONLY') OR
         (v_bucket_line_type_1 =  'PENDADJ_ONLY') OR
         (v_bucket_line_type_1 =  'DISPUTE_PENDADJ') THEN
         v_bucket_category := v_bucket_line_type_1;
      END IF;
      FETCH c_sel_bucket_data INTO v_bucket_days_from_2, v_bucket_days_to_2,
                                   p_bucket_titletop_2, p_bucket_titlebottom_2,
                                   v_bucket_line_type_2;
   ELSE
      p_bucket_titletop_1    := NULL;
      p_bucket_titlebottom_1 := NULL;
      p_bucket_amount_1      := NULL;
   END IF;
   IF c_sel_bucket_data%FOUND THEN
      p_bucket_amount_2 := 0;
      IF (v_bucket_line_type_2 = 'DISPUTE_ONLY') OR
         (v_bucket_line_type_2 =  'PENDADJ_ONLY') OR
         (v_bucket_line_type_2 =  'DISPUTE_PENDADJ') THEN
         v_bucket_category := v_bucket_line_type_2;
      END IF;
      FETCH c_sel_bucket_data INTO v_bucket_days_from_3, v_bucket_days_to_3,
                                   p_bucket_titletop_3, p_bucket_titlebottom_3,
                                   v_bucket_line_type_3;
   ELSE
      p_bucket_titletop_2    := NULL;
      p_bucket_titlebottom_2 := NULL;
      p_bucket_amount_2      := NULL;
   END IF;
   IF c_sel_bucket_data%FOUND THEN
      p_bucket_amount_3 := 0;
      IF (v_bucket_line_type_3 = 'DISPUTE_ONLY') OR
         (v_bucket_line_type_3 =  'PENDADJ_ONLY') OR
         (v_bucket_line_type_3 =  'DISPUTE_PENDADJ') THEN
         v_bucket_category := v_bucket_line_type_3;
      END IF;
      FETCH c_sel_bucket_data INTO v_bucket_days_from_4, v_bucket_days_to_4,
                                   p_bucket_titletop_4, p_bucket_titlebottom_4,
                                   v_bucket_line_type_4;
   ELSE
      p_bucket_titletop_3    := NULL;
      p_bucket_titlebottom_3 := NULL;
      p_bucket_amount_3      := NULL;
   END IF;
   IF c_sel_bucket_data%FOUND THEN
      p_bucket_amount_4 := 0;
      IF (v_bucket_line_type_4 = 'DISPUTE_ONLY') OR
         (v_bucket_line_type_4 =  'PENDADJ_ONLY') OR
         (v_bucket_line_type_4 =  'DISPUTE_PENDADJ') THEN
         v_bucket_category := v_bucket_line_type_4;
      END IF;
      FETCH c_sel_bucket_data INTO v_bucket_days_from_5, v_bucket_days_to_5,
                                   p_bucket_titletop_5, p_bucket_titlebottom_5,
                                   v_bucket_line_type_5;
   ELSE
      p_bucket_titletop_4    := NULL;
      p_bucket_titlebottom_4 := NULL;
      p_bucket_amount_4      := NULL;
   END IF;
   IF c_sel_bucket_data%FOUND THEN
      p_bucket_amount_5 := 0;
      IF (v_bucket_line_type_5 = 'DISPUTE_ONLY') OR
         (v_bucket_line_type_5 =  'PENDADJ_ONLY') OR
         (v_bucket_line_type_5 =  'DISPUTE_PENDADJ') THEN
         v_bucket_category := v_bucket_line_type_5;
      END IF;
      FETCH c_sel_bucket_data INTO v_bucket_days_from_6, v_bucket_days_to_6,
                                   p_bucket_titletop_6, p_bucket_titlebottom_6,
                                   v_bucket_line_type_6;
   ELSE
      p_bucket_titletop_5    := NULL;
      p_bucket_titlebottom_5 := NULL;
      p_bucket_amount_5      := NULL;
   END IF;
   IF c_sel_bucket_data%FOUND THEN
      p_bucket_amount_6 := 0;
      IF (v_bucket_line_type_6 = 'DISPUTE_ONLY') OR
         (v_bucket_line_type_6 =  'PENDADJ_ONLY') OR
         (v_bucket_line_type_6 =  'DISPUTE_PENDADJ') THEN
         v_bucket_category := v_bucket_line_type_6;
      END IF;
   ELSE
      p_bucket_titletop_6    := NULL;
      p_bucket_titlebottom_6 := NULL;
      p_bucket_amount_6      := NULL;
   END IF;
   CLOSE c_sel_bucket_data;
   --
   -- get the aging bucket balance.  The v_bucket_ is either 1 or 0.
   --
   p_outstanding_balance := 0;
   OPEN c_buckets1;
   FETCH c_buckets1 INTO v_outstanding_balance_1,
                        v_bucket_amount_1_0, v_bucket_amount_1_1, v_bucket_amount_1_2,
                        v_bucket_amount_1_3, v_bucket_amount_1_4, v_bucket_amount_1_5,
                        v_bucket_amount_1_6;
   CLOSE c_buckets1;
   OPEN c_buckets2;
   FETCH c_buckets2 INTO v_outstanding_balance_2,
                        v_bucket_amount_2_0, v_bucket_amount_2_1, v_bucket_amount_2_2,
                        v_bucket_amount_2_3, v_bucket_amount_2_4, v_bucket_amount_2_5,
                        v_bucket_amount_2_6;
   CLOSE c_buckets2;
   OPEN c_buckets3;
   FETCH c_buckets3 INTO v_outstanding_balance_3,
                        v_bucket_amount_3_0, v_bucket_amount_3_1, v_bucket_amount_3_2,
                        v_bucket_amount_3_3, v_bucket_amount_3_4, v_bucket_amount_3_5,
                        v_bucket_amount_3_6;
   CLOSE c_buckets3;
   OPEN c_buckets4;
   FETCH c_buckets4 INTO v_outstanding_balance_4,
                        v_bucket_amount_4_0, v_bucket_amount_4_1, v_bucket_amount_4_2,
                        v_bucket_amount_4_3, v_bucket_amount_4_4, v_bucket_amount_4_5,
                        v_bucket_amount_4_6;
   CLOSE c_buckets4;
   p_outstanding_balance :=  nvl(v_outstanding_balance_1,0)
                          + nvl(v_outstanding_balance_2,0)
                          + nvl(v_outstanding_balance_3,0)
                          + nvl(v_outstanding_balance_4,0);
   p_bucket_amount_0    :=   nvl(v_bucket_amount_1_0,0)
                          + nvl(v_bucket_amount_2_0,0)
                          + nvl(v_bucket_amount_3_0,0)
                          + nvl(v_bucket_amount_4_0,0);
   p_bucket_amount_1    :=   nvl(v_bucket_amount_1_1,0)
                          + nvl(v_bucket_amount_2_1,0)
                          + nvl(v_bucket_amount_3_1,0)
                          + nvl(v_bucket_amount_4_1,0);
   p_bucket_amount_2    :=   nvl(v_bucket_amount_1_2,0)
                          + nvl(v_bucket_amount_2_2,0)
                          + nvl(v_bucket_amount_3_2,0)
                          + nvl(v_bucket_amount_4_2,0);
   p_bucket_amount_3    :=   nvl(v_bucket_amount_1_3,0)
                          + nvl(v_bucket_amount_2_3,0)
                          + nvl(v_bucket_amount_3_3,0)
                          + nvl(v_bucket_amount_4_3,0);
   p_bucket_amount_4    :=   nvl(v_bucket_amount_1_4,0)
                          + nvl(v_bucket_amount_2_4,0)
                          + nvl(v_bucket_amount_3_4,0)
                          + nvl(v_bucket_amount_4_4,0);
   p_bucket_amount_5    :=   nvl(v_bucket_amount_1_5,0)
                          + nvl(v_bucket_amount_2_5,0)
                          + nvl(v_bucket_amount_3_5,0)
                          + nvl(v_bucket_amount_4_5,0);
   p_bucket_amount_6    :=   nvl(v_bucket_amount_1_6,0)
                          + nvl(v_bucket_amount_2_6,0)
                          + nvl(v_bucket_amount_3_6,0)
                          + nvl(v_bucket_amount_4_6,0);
   --
EXCEPTION
   WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('EXCEPTION: arp_customer_aging.calc_aging_buckets');
        END IF;
END calc_aging_buckets;

END AR_CMGT_AGING;

/
