--------------------------------------------------------
--  DDL for Package Body IEX_COLL_IND_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_COLL_IND_PUB" AS
/* $Header: iexpmtib.pls 120.0.12010000.6 2010/02/23 21:21:15 ehuh noship $ */

  G_PKG_NAME    CONSTANT VARCHAR2(30) := 'IEX_COLL_IND_PUB';
  G_FILE_NAME   CONSTANT VARCHAR2(12) := 'iexpmtib.pls';
  G_APPL_ID              NUMBER;
  G_LOGIN_ID             NUMBER;
  G_PROGRAM_ID           NUMBER;
  G_USER_ID              NUMBER;
  G_REQUEST_ID           NUMBER;
  PG_DEBUG               NUMBER(2);

  g_base_currency_code  gl_sets_of_books.currency_code%TYPE;
  g_base_precision      fnd_currencies.precision%type;
  g_base_min_acc_unit   fnd_currencies.minimum_accountable_unit%type;

FUNCTION GET_CREDIT_LIMIT(p_party_id IN NUMBER,
                          p_cust_account_id IN NUMBER,
                          p_customer_site_use_id IN NUMBER,
                          p_org_id IN NUMBER) RETURN VARCHAR2 AS

  l_credit_limit NUMBER;
  l_num_val NUMBER;
  l_char_val VARCHAR2(1000);
  l_currency_code VARCHAR2(10);

BEGIN

  If p_org_id is null then
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  --fnd_request.set_org_id(p_org_id);
  mo_global.set_policy_context('S',p_org_id);

  GET_COMMON(p_org_id);

  iex_debug_pub.logmessage (' IEX_COLL_IND_PUB.get_true_dso - g_base_currency_code = ' ||g_base_currency_code);
  iex_debug_pub.logmessage (' IEX_COLL_IND_PUB.get_true_dso - g_base_precision = ' ||g_base_precision);
  iex_debug_pub.logmessage (' IEX_COLL_IND_PUB.get_true_dso - g_base_min_acc_unit = ' ||g_base_min_acc_unit);
  iex_debug_pub.logmessage (' IEX_COLL_IND_PUB.get_true_dso - p_org_id = ' ||p_org_id);

  IF p_party_id IS NOT NULL THEN
    SELECT SUM(DECODE(prof_amt.overall_credit_limit, NULL, NULL,
                   gl_currency_api.convert_amount_sql(prof_amt.currency_code,g_base_currency_code,
              sysdate, cm_opt.default_exchange_rate_type, prof_amt.overall_credit_limit)))
      INTO l_credit_limit
      FROM hz_customer_profiles prof, hz_cust_profile_amts prof_amt,
           ar_cmgt_setup_options cm_opt
     WHERE prof.party_id = p_party_id
       AND prof.site_use_id IS NULL
       AND prof.status = 'A'
       AND prof.cust_account_profile_id = prof_amt.cust_account_profile_id
       AND prof_amt.cust_account_id = prof.cust_account_id
       AND prof.cust_account_id = -1
       AND prof_amt.site_use_id IS NULL;

  ELSIF p_cust_account_id IS NOT NULL THEN
    SELECT SUM(DECODE(prof_amt.overall_credit_limit, NULL, NULL,
              gl_currency_api.convert_amount_sql(prof_amt.currency_code, g_base_currency_code,
              sysdate, cm_opt.default_exchange_rate_type, prof_amt.overall_credit_limit)))
      INTO l_credit_limit
      FROM hz_customer_profiles prof, hz_cust_profile_amts prof_amt,
           ar_cmgt_setup_options cm_opt
     WHERE prof.cust_account_id = p_cust_account_id
       AND prof.site_use_id IS NULL
       AND prof.status = 'A'
       AND prof.cust_account_profile_id = prof_amt.cust_account_profile_id
       AND prof_amt.cust_account_id = p_cust_account_id
       AND prof_amt.site_use_id IS NULL;
  ELSIF p_customer_site_use_id IS NOT NULL THEN
    SELECT SUM(DECODE(prof_amt.overall_credit_limit, NULL, NULL,
              gl_currency_api.convert_amount_sql(prof_amt.currency_code, g_base_currency_code,
              sysdate, cm_opt.default_exchange_rate_type, prof_amt.overall_credit_limit)))
      INTO l_credit_limit
      FROM hz_customer_profiles prof, hz_cust_profile_amts prof_amt,
           ar_cmgt_setup_options cm_opt
     WHERE prof.site_use_id = p_customer_site_use_id
       AND prof.status = 'A'
       AND prof.cust_account_profile_id = prof_amt.cust_account_profile_id
       AND prof_amt.site_use_id = p_customer_site_use_id;
  END IF;

  l_num_val := l_credit_limit;
  l_char_val := RTRIM(TO_CHAR(l_num_val, fnd_currency.get_format_mask(g_base_currency_code, 50)));
  RETURN l_char_val;

EXCEPTION
  when others then
       iex_debug_pub.logmessage (' IEX_COLL_IND_PUB.get_credit_limit - Exception = ' ||SQLERRM);
       RETURN(0);

END GET_CREDIT_LIMIT;


FUNCTION GET_WTD_DAYS_TERMS(p_party_id IN NUMBER,
                     p_cust_account_id IN NUMBER,
                     p_customer_site_use_id IN NUMBER,
                     p_org_id NUMBER) RETURN VARCHAR2 AS

  l_wtd_days_terms   NUMBER;
  l_num_val NUMBER;
  l_char_val VARCHAR2(1000);

BEGIN

  If p_org_id is null then
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  --fnd_request.set_org_id(p_org_id);
  mo_global.set_policy_context('S',p_org_id);


  IF p_party_id IS NOT NULL THEN
    SELECT sum
             (
               (
                 IEX_COLL_IND.GET_APPS_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) -
                 IEX_COLL_IND.GET_ADJ_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) +
                 nvl(ps.acctd_amount_due_remaining, 0)
               ) *
               (ps.due_date - ps.trx_date)
             )  /
             sum (
               IEX_COLL_IND.GET_APPS_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) -
               IEX_COLL_IND.GET_ADJ_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) +
               nvl(ps.acctd_amount_due_remaining, 0)
             )
      INTO   l_wtd_days_terms
      FROM   ar_payment_schedules ps, hz_cust_accounts ca
      WHERE  ps.gl_date between TRUNC(add_months(sysdate, -12)) and  TRUNC(sysdate)
      AND    ps.class in ('INV','DEP','DM','CB')
      AND    ps.payment_schedule_id <> -1
      AND    ps.customer_id = ca.cust_account_id
      AND    ca.party_id = p_party_id;
  ELSIF p_cust_account_id IS NOT NULL THEN
    SELECT sum
             (
               (
                 IEX_COLL_IND.GET_APPS_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) -
                 IEX_COLL_IND.GET_ADJ_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) +
                 nvl(ps.acctd_amount_due_remaining, 0)
               ) *
               (ps.due_date - ps.trx_date)
             )  /
             sum (
               IEX_COLL_IND.GET_APPS_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) -
               IEX_COLL_IND.GET_ADJ_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) +
               nvl(ps.acctd_amount_due_remaining, 0)
             )
      INTO   l_wtd_days_terms
      FROM   ar_payment_schedules 	ps
      WHERE  ps.gl_date between TRUNC(add_months(sysdate, -12)) and  TRUNC(sysdate)
      AND    ps.class in ('INV','DEP','DM','CB')
      AND    ps.payment_schedule_id <> -1
      AND    ps.customer_id = p_cust_account_id;
  ELSIF p_customer_site_use_id IS NOT NULL THEN
    SELECT sum
             (
               (
                 IEX_COLL_IND.GET_APPS_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) -
                 IEX_COLL_IND.GET_ADJ_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) +
                 nvl(ps.acctd_amount_due_remaining, 0)
               ) *
               (ps.due_date - ps.trx_date)
             )  /
             sum (
               IEX_COLL_IND.GET_APPS_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) -
               IEX_COLL_IND.GET_ADJ_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) +
               nvl(ps.acctd_amount_due_remaining, 0)
             )
      INTO   l_wtd_days_terms
      FROM   ar_payment_schedules 	ps
      WHERE  ps.gl_date between TRUNC(add_months(sysdate, -12)) and  TRUNC(sysdate)
      AND    ps.class in ('INV','DEP','DM','CB')
      AND    ps.payment_schedule_id <> -1
      AND    ps.customer_site_use_id = p_customer_site_use_id;
  END IF;

  l_num_val :=  TRUNC(NVL(l_wtd_days_terms, 0));
  l_char_val := RTRIM(TO_CHAR(l_num_val));
  RETURN l_char_val;

EXCEPTION
  when others then
       iex_debug_pub.logmessage (' IEX_COLL_IND_PUB.get_wtd_days_terms - Exception = ' ||SQLERRM);
       RETURN(TO_CHAR(0));
END GET_WTD_DAYS_TERMS;

FUNCTION GET_WTD_DAYS_LATE(p_party_id IN NUMBER,
                     p_cust_account_id IN NUMBER,
                     p_customer_site_use_id IN NUMBER,
                     p_org_id IN NUMBER) RETURN VARCHAR2 AS

  l_wtd_days_late   NUMBER;
  l_num_val NUMBER;
  l_char_val VARCHAR2(1000);

BEGIN

  If p_org_id is null then
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- fnd_request.set_org_id(p_org_id);
  mo_global.set_policy_context('S',p_org_id);

  IF p_party_id IS NOT NULL THEN
    SELECT sum
             (
               (
                 IEX_COLL_IND.GET_APPS_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) -
                 IEX_COLL_IND.GET_ADJ_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) +
                 nvl(ps.acctd_amount_due_remaining, 0)
               ) *
               (TRUNC(sysdate) - ps.due_date)
             )  /
             sum (
               IEX_COLL_IND.GET_APPS_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) -
               IEX_COLL_IND.GET_ADJ_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) +
               nvl(ps.acctd_amount_due_remaining, 0)
             )
      INTO   l_wtd_days_late
      FROM   ar_payment_schedules ps, hz_cust_accounts ca
      WHERE  ps.gl_date between TRUNC(add_months(sysdate, -12)) and  TRUNC(sysdate)
      AND    ps.class in ('INV','DEP','DM','CB')
      AND    ps.status = 'OP'
      AND    ps.payment_schedule_id <> -1
      AND    ps.customer_id = ca.cust_account_id
      AND    ca.party_id = p_party_id;
  ELSIF p_cust_account_id IS NOT NULL THEN
    SELECT sum
             (
               (
                 IEX_COLL_IND.GET_APPS_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) -
                 IEX_COLL_IND.GET_ADJ_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) +
                 nvl(ps.acctd_amount_due_remaining, 0)
               ) *
               (TRUNC(sysdate) - ps.due_date)
             )  /
             sum (
               IEX_COLL_IND.GET_APPS_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) -
               IEX_COLL_IND.GET_ADJ_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) +
               nvl(ps.acctd_amount_due_remaining, 0)
             )
      INTO   l_wtd_days_late
      FROM   ar_payment_schedules 	ps
      WHERE  ps.gl_date between TRUNC(add_months(sysdate, -12)) and  TRUNC(sysdate)
      AND    ps.class in ('INV','DEP','DM','CB')
      AND    ps.status = 'OP'
      AND    ps.payment_schedule_id <> -1
      AND    ps.customer_id = p_cust_account_id;
  ELSIF p_customer_site_use_id IS NOT NULL THEN
    SELECT sum
             (
               (
                 IEX_COLL_IND.GET_APPS_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) -
                 IEX_COLL_IND.GET_ADJ_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) +
                 nvl(ps.acctd_amount_due_remaining, 0)
               ) *
               (TRUNC(sysdate) - ps.due_date)
             )  /
             sum (
               IEX_COLL_IND.GET_APPS_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) -
               IEX_COLL_IND.GET_ADJ_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) +
               nvl(ps.acctd_amount_due_remaining, 0)
             )
      INTO   l_wtd_days_late
      FROM   ar_payment_schedules 	ps
      WHERE  ps.gl_date between TRUNC(add_months(sysdate, -12)) and  TRUNC(sysdate)
      AND    ps.class in ('INV','DEP','DM','CB')
      AND    ps.status = 'OP'
      AND    ps.payment_schedule_id <> -1
      AND    ps.customer_site_use_id = p_customer_site_use_id;
  END IF;

  l_num_val :=  TRUNC(NVL(l_wtd_days_late,0));
  l_char_val := RTRIM(TO_CHAR(l_num_val));
  RETURN l_char_val;

EXCEPTION
  when others then
       iex_debug_pub.logmessage (' IEX_COLL_IND_PUB.get_wtd_days_late - Exception = ' ||SQLERRM);
       RETURN(TO_CHAR(0));
END GET_WTD_DAYS_LATE;

FUNCTION GET_TRUE_DSO(p_party_id IN NUMBER,
                      p_cust_account_id IN NUMBER,
                      p_customer_site_use_id IN NUMBER,
                      p_org_id IN NUMBER) RETURN VARCHAR2 AS
  l_sales NUMBER;
  l_beg_ar NUMBER;
  l_end_ar NUMBER;
  l_dso NUMBER;
  l_num_val NUMBER;
  l_char_val VARCHAR2(1000);

BEGIN

  If p_org_id is null then
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- fnd_request.set_org_id(p_org_id);
  mo_global.set_policy_context('S',p_org_id);

  GET_COMMON(p_org_id);

  /*-----------------------------------------------------------------------
  DSO = ( Period Average Receivables / Average Sales per day)

    where tot outs rec = sum of all receivables less all receipts (use COMP_REM_REC)
    avg sales per day = sum of all receivables (use COMP_TOT_REC) / days in period
  -----------------------------------------------------------------------*/
  iex_debug_pub.logmessage (' IEX_COLL_DSO_PUB.get_true_dso - g_base_currency_code = ' ||g_base_currency_code);
  iex_debug_pub.logmessage (' IEX_COLL_DSO_PUB.get_true_dso - g_base_precision = ' ||g_base_precision);
  iex_debug_pub.logmessage (' IEX_COLL_DSO_PUB.get_true_dso - g_base_min_acc_unit = ' ||g_base_min_acc_unit);

  l_sales    := COMP_TOT_REC(TRUNC(add_months(sysdate, -12)), TRUNC(sysdate),
                            p_party_id, p_cust_account_id, p_customer_site_use_id);

  l_beg_ar   := IEX_COLL_IND.COMP_REM_REC(to_date('01/01/1952','MM/DD/YYYY'), TRUNC(add_months(sysdate, -12)) - 1,
                            p_party_id, p_cust_account_id, p_customer_site_use_id);

  l_end_ar   := IEX_COLL_IND.COMP_REM_REC(to_date('01/01/1952','MM/DD/YYYY'), TRUNC(sysdate),
                            p_party_id, p_cust_account_id, p_customer_site_use_id);

  iex_debug_pub.logmessage (' IEX_COLL_DSO_PUB.get_true_dso - l_sales = ' ||l_sales);
  iex_debug_pub.logmessage (' IEX_COLL_DSO_PUB.get_true_dso - l_beg_ar = ' ||l_beg_ar);
  iex_debug_pub.logmessage (' IEX_COLL_DSO_PUB.get_true_dso - l_end_ar = ' ||l_end_ar);


   if ( nvl(l_sales,0) = 0 ) then
     l_dso := 0;
   else
     l_dso := (((l_beg_ar + l_end_ar)/2)/l_sales)*(TRUNC(sysdate) - TRUNC(add_months(sysdate, -12)));
   end if;

  l_num_val := ROUND(nvl(l_dso,0), 0);
  l_char_val := RTRIM(TO_CHAR(l_num_val));

  RETURN l_char_val;

  exception
    When others then
         iex_debug_pub.logmessage (' IEX_COLL_DSO_PUB.get_true_dso - Exception = ' ||SQLERRM);
         return null;

END GET_TRUE_DSO;

FUNCTION COMP_TOT_REC(p_start_date IN DATE,
                      p_end_date   IN DATE,
                      p_party_id IN NUMBER,
                      p_cust_account_id IN NUMBER,
                      p_customer_site_use_id IN NUMBER) RETURN NUMBER AS

  l_tot_rec           NUMBER;
  l_temp_start        DATE;
  l_num_val NUMBER;
  l_char_val VARCHAR2(1000);

BEGIN

  if p_start_date is null then
    l_temp_start := to_date('01/01/1952','MM/DD/YYYY');
  else
    l_temp_start := p_start_date;
  end if;

  IF p_party_id IS NOT NULL THEN
    SELECT  SUM(arpcurr.functional_amount(
                ps.amount_due_original,
                g_base_currency_code,
                nvl(ps.exchange_rate,1),
                g_base_precision,
                g_base_min_acc_unit) +
                IEX_COLL_IND.GET_ADJ_FOR_TOT_REC(ps.payment_schedule_id,p_end_date))
    INTO    l_tot_rec
    FROM    ar_payment_schedules   ps,
            hz_cust_accounts       ca
    WHERE   ps.class in ('INV', 'DM', 'CB', 'DEP' )
    AND     ps.payment_schedule_id <> -1
    AND     ps.gl_date BETWEEN l_temp_start AND p_end_date
    AND     ps.customer_id = ca.cust_account_id
    AND     ca.party_id = p_party_id;
  ELSIF p_cust_account_id IS NOT NULL THEN
    SELECT  SUM(arpcurr.functional_amount(
      ps.amount_due_original,
      g_base_currency_code,
      nvl(ps.exchange_rate,1),
      g_base_precision,
      g_base_min_acc_unit) +
       IEX_COLL_IND.GET_ADJ_FOR_TOT_REC(ps.payment_schedule_id,p_end_date))
    INTO    l_tot_rec
    FROM    ar_payment_schedules   ps
    WHERE   ps.class in ('INV', 'DM', 'CB', 'DEP' )
    AND     ps.payment_schedule_id <> -1
    AND     ps.gl_date BETWEEN l_temp_start AND p_end_date
    AND     ps.customer_id = p_cust_account_id;
  ELSIF p_customer_site_use_id IS NOT NULL THEN
    SELECT  SUM(arpcurr.functional_amount(
      ps.amount_due_original,
      g_base_currency_code,
      nvl(ps.exchange_rate,1),
      g_base_precision,
      g_base_min_acc_unit) +
       IEX_COLL_IND.GET_ADJ_FOR_TOT_REC(ps.payment_schedule_id,p_end_date))
    INTO    l_tot_rec
    FROM    ar_payment_schedules   ps
    WHERE   ps.class in ('INV', 'DM', 'CB', 'DEP' )
    AND     ps.payment_schedule_id <> -1
    AND     ps.gl_date BETWEEN l_temp_start AND p_end_date
    AND     ps.customer_site_use_id = p_customer_site_use_id;
  END IF;

  l_num_val := nvl(l_tot_rec, 0);
  RETURN l_num_val;

  exception
    When others then
         iex_debug_pub.logmessage (' IEX_COLL_DSO_PUB.comp_tot_rec - Exception = ' ||SQLERRM);
         return(0);
END COMP_TOT_REC;


Procedure Get_Common(p_org_id number) is

 begin

    select gll.currency_code, c.precision, c.minimum_accountable_unit
      INTO  g_base_currency_code,g_base_precision,g_base_min_acc_unit
      from ar_system_parameters    sp,
           gl_ledgers_public_v     gll,
           fnd_currencies     c
      where
            gll.ledger_id = sp.set_of_books_id
        and gll.currency_code   = c.currency_code;

     iex_debug_pub.logmessage (' IEX_COLL_IND_PUB.get_common - g_base_currency_code = ' ||g_base_currency_code);
     iex_debug_pub.logmessage (' IEX_COLL_IND_PUB.get_common - g_base_precision = ' ||g_base_precision);
     iex_debug_pub.logmessage (' IEX_COLL_IND_PUB.get_common - g_base_min_acc_unit = ' ||g_base_min_acc_unit);


  exception
    when others then
       iex_debug_pub.logmessage (' IEX_COLL_IND_PUB.main selection - Exception = ' ||SQLERRM);
       null;

  end GET_COMMON;


END IEX_COLL_IND_PUB;

/
