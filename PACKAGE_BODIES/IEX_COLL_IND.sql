--------------------------------------------------------
--  DDL for Package Body IEX_COLL_IND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_COLL_IND" AS
/* $Header: iexvmtib.pls 120.12.12010000.3 2010/03/09 06:58:08 barathsr ship $ */
/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |                                                                         |
 |    GET_AVG_DAYS_LATE                                                    |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    This function will compute for average days late                     |
 | REQUIRES                                                                |
 |                                                                         |
 | OPTIONAL                                                                |
 |                                                                         |
 | RETURNS                                                                 |
 |    Average Days Late                                                    |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |                                                                         |
 +-------------------------------------------------------------------------*/

FUNCTION GET_AVG_DAYS_LATE(p_party_id IN NUMBER,
                     p_cust_account_id IN NUMBER,
                     p_customer_site_use_id IN NUMBER) RETURN VARCHAR2 AS

  l_avg_days_late   NUMBER;
  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  l_num_val NUMBER;
  l_char_val VARCHAR2(1000);
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable

BEGIN

  IF p_party_id IS NOT NULL THEN
    SELECT sum(TRUNC(sysdate) - ps.due_date)
          / COUNT(1)
      INTO   l_avg_days_late
      FROM   ar_payment_schedules ps, hz_cust_accounts ca
      WHERE  ps.gl_date between TRUNC(add_months(sysdate, -12)) and  TRUNC(sysdate)
      AND    ps.class in ('INV','DEP','DM','CB')
      AND    ps.gl_date_closed > TRUNC(sysdate)
      -- Begin fix bug #4949609-JYPARK-2/15/2006-add condition for performance
      AND    ps.status = 'OP'
      -- End fix bug #4949609-JYPARK-2/15/2006-add condition for performance
      AND    ps.due_date       < TRUNC(sysdate)
      AND    ps.payment_schedule_id <> -1
      AND    ca.cust_account_id = ps.customer_id
      AND    ca.party_id = p_party_id;
  ELSIF p_cust_account_id IS NOT NULL THEN
    SELECT sum(TRUNC(sysdate) - ps.due_date)
          / COUNT(1)
      INTO   l_avg_days_late
      FROM   ar_payment_schedules ps
      WHERE  ps.gl_date between TRUNC(add_months(sysdate, -12)) and  TRUNC(sysdate)
      AND    ps.class in ('INV','DEP','DM','CB')
      AND    ps.gl_date_closed > TRUNC(sysdate)
      -- Begin fix bug #4949609-JYPARK-2/15/2006-add condition for performance
      AND    ps.status = 'OP'
      -- End fix bug #4949609-JYPARK-2/15/2006-add condition for performance
      AND    ps.due_date       < TRUNC(sysdate)
      AND    ps.payment_schedule_id <> -1
      AND    ps.customer_id = p_cust_account_id;
  ELSIF p_customer_site_use_id IS NOT NULL THEN
    SELECT sum(TRUNC(sysdate) - ps.due_date)
          / COUNT(1)
      INTO   l_avg_days_late
      FROM   ar_payment_schedules ps
      WHERE  ps.gl_date between TRUNC(add_months(sysdate, -12)) and  TRUNC(sysdate)
      AND    ps.class in ('INV','DEP','DM','CB')
      AND    ps.gl_date_closed > TRUNC(sysdate)
      -- Begin fix bug #4949609-JYPARK-2/15/2006-add condition for performance
      AND    ps.status = 'OP'
      -- End fix bug #4949609-JYPARK-2/15/2006-add condition for performance
      AND    ps.due_date       < TRUNC(sysdate)
      AND    ps.payment_schedule_id <> -1
      AND    ps.customer_site_use_id = p_customer_site_use_id;
  END IF;

  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  -- RETURN  TO_CHAR(TRUNC(NVL(l_avg_days_late,0)));

  l_num_val :=  TRUNC(NVL(l_avg_days_late,0));
  l_char_val := RTRIM(TO_CHAR(l_num_val));

  RETURN l_char_val;
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable

EXCEPTION
        WHEN NO_DATA_FOUND THEN RETURN(TO_CHAR(0));

END GET_AVG_DAYS_LATE;


/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |                                                                         |
 |    GET_WTD_DAYS_LATE                                                    |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    This function will compute for weighted average                      |
 |    days late                                                            |
 |    Added calls to GET_ADJ_TOTAL and GET_APPS_TOTAL                      |
 | REQUIRES                                                                |
 |                                                                         |
 | OPTIONAL                                                                |
 |                                                                         |
 | RETURNS                                                                 |
 |    Weighted Average Days Late                                           |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |                                                                         |
 +-------------------------------------------------------------------------*/

FUNCTION GET_WTD_DAYS_LATE(p_party_id IN NUMBER,
                     p_cust_account_id IN NUMBER,
                     p_customer_site_use_id IN NUMBER) RETURN VARCHAR2 AS

  l_wtd_days_late   NUMBER;
  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  l_num_val NUMBER;
  l_char_val VARCHAR2(1000);
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable

BEGIN

  IF p_party_id IS NOT NULL THEN
    SELECT sum
             (
               (
                 GET_APPS_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) -
                 GET_ADJ_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) +
                 nvl(ps.acctd_amount_due_remaining, 0)
               ) *
               (TRUNC(sysdate) - ps.due_date)
             )  /
             sum (
               GET_APPS_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) -
               GET_ADJ_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) +
               nvl(ps.acctd_amount_due_remaining, 0)
             )
      INTO   l_wtd_days_late
      FROM   ar_payment_schedules ps, hz_cust_accounts ca
      WHERE  ps.gl_date between TRUNC(add_months(sysdate, -12)) and  TRUNC(sysdate)
      AND    ps.class in ('INV','DEP','DM','CB')
      -- Begin fix bug #4917851-jypark-11/47/2005-remove invalid condition
      --AND    ps.gl_date_closed > TRUNC(sysdate)
      --AND    ps.due_date       < TRUNC(sysdate)
      -- End fix bug #4917851-jypark-11/47/2005-remove invalid condition
      -- Begin fix bug #4949609-JYPARK-2/15/2006-add condition for performance
      AND    ps.status = 'OP'
      -- End fix bug #4949609-JYPARK-2/15/2006-add condition for performance
      AND    ps.payment_schedule_id <> -1
      AND    ps.customer_id = ca.cust_account_id
      AND    ca.party_id = p_party_id;
  ELSIF p_cust_account_id IS NOT NULL THEN
    SELECT sum
             (
               (
                 GET_APPS_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) -
                 GET_ADJ_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) +
                 nvl(ps.acctd_amount_due_remaining, 0)
               ) *
               (TRUNC(sysdate) - ps.due_date)
             )  /
             sum (
               GET_APPS_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) -
               GET_ADJ_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) +
               nvl(ps.acctd_amount_due_remaining, 0)
             )
      INTO   l_wtd_days_late
      FROM   ar_payment_schedules 	ps
      WHERE  ps.gl_date between TRUNC(add_months(sysdate, -12)) and  TRUNC(sysdate)
      AND    ps.class in ('INV','DEP','DM','CB')
      -- Begin fix bug #4917851-jypark-11/47/2005-remove invalid condition
      -- AND    ps.gl_date_closed > TRUNC(sysdate)
      -- AND    ps.due_date       < TRUNC(sysdate)
      -- End fix bug #4917851-jypark-11/47/2005-remove invalid condition
      -- Begin fix bug #4949609-JYPARK-2/15/2006-add condition for performance
      AND    ps.status = 'OP'
      -- End fix bug #4949609-JYPARK-2/15/2006-add condition for performance
      AND    ps.payment_schedule_id <> -1
      AND    ps.customer_id = p_cust_account_id;
  ELSIF p_customer_site_use_id IS NOT NULL THEN
    SELECT sum
             (
               (
                 GET_APPS_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) -
                 GET_ADJ_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) +
                 nvl(ps.acctd_amount_due_remaining, 0)
               ) *
               (TRUNC(sysdate) - ps.due_date)
             )  /
             sum (
               GET_APPS_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) -
               GET_ADJ_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) +
               nvl(ps.acctd_amount_due_remaining, 0)
             )
      INTO   l_wtd_days_late
      FROM   ar_payment_schedules 	ps
      WHERE  ps.gl_date between TRUNC(add_months(sysdate, -12)) and  TRUNC(sysdate)
      AND    ps.class in ('INV','DEP','DM','CB')
      -- Begin fix bug #4917851-jypark-11/47/2005-remove invalid condition
      -- AND    ps.gl_date_closed > TRUNC(sysdate)
      -- AND    ps.due_date       < TRUNC(sysdate)
      -- End fix bug #4917851-jypark-11/47/2005-remove invalid condition
      -- Begin fix bug #4949609-JYPARK-2/15/2006-add condition for performance
      AND    ps.status = 'OP'
      -- End fix bug #4949609-JYPARK-2/15/2006-add condition for performance
      AND    ps.payment_schedule_id <> -1
      AND    ps.customer_site_use_id = p_customer_site_use_id;
  END IF;

  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  --RETURN  TO_CHAR(TRUNC(NVL(l_wtd_days_late,0)));
  l_num_val :=  TRUNC(NVL(l_wtd_days_late,0));
  l_char_val := RTRIM(TO_CHAR(l_num_val));
  RETURN l_char_val;
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable

EXCEPTION
  WHEN NO_DATA_FOUND THEN RETURN(TO_CHAR(0));
END GET_WTD_DAYS_LATE;

/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |                                                                         |
 |    GET_WTD_DAYS_PAID                                                    |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    This function will compute for weighted average                      |
 |    days paid                                                            |
 | REQUIRES                                                                |
 |                                                                         |
 | OPTIONAL                                                                |
 |                                                                         |
 | RETURNS                                                                 |
 |    Weighted Average Days Paid                                           |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |                                                                         |
 +-------------------------------------------------------------------------*/

FUNCTION GET_WTD_DAYS_PAID(p_party_id IN NUMBER,
                     p_cust_account_id IN NUMBER,
                     p_customer_site_use_id IN NUMBER) RETURN VARCHAR2 AS

  l_wtd_days_paid   NUMBER;
  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  l_num_val NUMBER;
  l_char_val VARCHAR2(1000);
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable

BEGIN

  IF p_party_id IS NOT NULL THEN
    SELECT ROUND(SUM((ra.apply_date - ps.trx_date) * ra.amount_applied)
                / SUM(ra.amount_applied)
              , 0) WEIGHTED_AVG_DAYS_PAID
      INTO l_wtd_days_paid
      FROM ar_receivable_applications ra,
           ar_payment_schedules ps,
           hz_cust_accounts ca
     WHERE ps.customer_id = ca.cust_account_id
       AND ca.party_id = p_party_id
       AND ra.status = 'APP'
       AND ps.payment_schedule_id = ra.applied_payment_schedule_id
       AND ps.gl_date between TRUNC(add_months(sysdate, -12)) and  TRUNC(sysdate)
       AND ps.class in ('INV','DEP','DM','CB')
       -- Begin fix bug #4917851-jypark-11/47/2005-remove invalid condition
       -- AND ps.gl_date_closed > TRUNC(sysdate)
       -- AND ps.due_date       < TRUNC(sysdate)
       -- End fix bug #4917851-jypark-11/47/2005-remove invalid condition
      -- Begin fix bug #4949604-JYPARK-2/15/2006-add condition for performance
      AND    ps.status = 'CL'
      -- End fix bug #4949604-JYPARK-2/15/2006-add condition for performance
       AND ps.payment_schedule_id <> -1;
  ELSIF p_cust_account_id IS NOT NULL THEN
    SELECT ROUND(SUM((ra.apply_date - ps.trx_date) * ra.amount_applied)
                / SUM(ra.amount_applied)
              , 0) WEIGHTED_AVG_DAYS_PAID
      INTO l_wtd_days_paid
      FROM ar_receivable_applications ra,
           ar_payment_schedules ps
     WHERE ps.customer_id = p_cust_account_id
       AND ra.status = 'APP'
       AND ps.payment_schedule_id = ra.applied_payment_schedule_id
       AND ps.gl_date between TRUNC(add_months(sysdate, -12)) and  TRUNC(sysdate)
       AND ps.class in ('INV','DEP','DM','CB')
       -- Begin fix bug #4917851-jypark-11/47/2005-remove invalid condition
       -- AND ps.gl_date_closed > TRUNC(sysdate)
       -- AND ps.due_date       < TRUNC(sysdate)
       -- End fix bug #4917851-jypark-11/47/2005-remove invalid condition
      -- Begin fix bug #4949604-JYPARK-2/15/2006-add condition for performance
      AND    ps.status = 'CL'
      -- End fix bug #4949604-JYPARK-2/15/2006-add condition for performance
       AND ps.payment_schedule_id <> -1;
  ELSIF p_customer_site_use_id IS NOT NULL THEN
    SELECT ROUND(SUM((ra.apply_date - ps.trx_date) * ra.amount_applied)
                / SUM(ra.amount_applied)
              , 0) WEIGHTED_AVG_DAYS_PAID
      INTO l_wtd_days_paid
      FROM ar_receivable_applications ra,
           ar_payment_schedules ps
     WHERE ps.customer_site_use_id = p_customer_site_use_id
       AND ra.status = 'APP'
       AND ps.payment_schedule_id = ra.applied_payment_schedule_id
       AND ps.gl_date between TRUNC(add_months(sysdate, -12)) and  TRUNC(sysdate)
       AND ps.class in ('INV','DEP','DM','CB')
       -- Begin fix bug #4917851-jypark-11/47/2005-remove invalid condition
       -- AND ps.gl_date_closed > TRUNC(sysdate)
       -- AND ps.due_date       < TRUNC(sysdate)
       -- End fix bug #4917851-jypark-11/47/2005-remove invalid condition
      -- Begin fix bug #4949604-JYPARK-2/15/2006-add condition for performance
      AND    ps.status = 'CL'
      -- End fix bug #4949604-JYPARK-2/15/2006-add condition for performance
       AND ps.payment_schedule_id <> -1;
  END IF;

  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  --RETURN  TO_CHAR(TRUNC(NVL(l_wtd_days_paid, 0)));
  l_num_val :=  TRUNC(NVL(l_wtd_days_paid, 0));
  l_char_val := RTRIM(TO_CHAR(l_num_val));
  RETURN l_char_val;
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable

EXCEPTION
  WHEN NO_DATA_FOUND THEN RETURN(TO_CHAR(0));
END GET_WTD_DAYS_PAID;


/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |                                                                         |
 |    GET_WTD_DAYS_TERMS                                                   |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    This function will compute for weighted average                      |
 |    days terms                                                           |
 | REQUIRES                                                                |
 |                                                                         |
 | OPTIONAL                                                                |
 |                                                                         |
 | RETURNS                                                                 |
 |    Weighted Average Days Terms                                          |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |                                                                         |
 +-------------------------------------------------------------------------*/

FUNCTION GET_WTD_DAYS_TERMS(p_party_id IN NUMBER,
                     p_cust_account_id IN NUMBER,
                     p_customer_site_use_id IN NUMBER) RETURN VARCHAR2 AS

  l_wtd_days_terms   NUMBER;
  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  l_num_val NUMBER;
  l_char_val VARCHAR2(1000);
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable

BEGIN

  IF p_party_id IS NOT NULL THEN
    SELECT sum
             (
               (
                 GET_APPS_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) -
                 GET_ADJ_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) +
                 nvl(ps.acctd_amount_due_remaining, 0)
               ) *
               (ps.due_date - ps.trx_date)
             )  /
             sum (
               GET_APPS_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) -
               GET_ADJ_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) +
               nvl(ps.acctd_amount_due_remaining, 0)
             )
      INTO   l_wtd_days_terms
      FROM   ar_payment_schedules ps, hz_cust_accounts ca
      WHERE  ps.gl_date between TRUNC(add_months(sysdate, -12)) and  TRUNC(sysdate)
      AND    ps.class in ('INV','DEP','DM','CB')
       -- Begin fix bug #4917851-jypark-11/47/2005-remove invalid condition
       -- AND ps.gl_date_closed > TRUNC(sysdate)
       -- AND ps.due_date       < TRUNC(sysdate)
       -- End fix bug #4917851-jypark-11/47/2005-remove invalid condition
      AND    ps.payment_schedule_id <> -1
      AND    ps.customer_id = ca.cust_account_id
      AND    ca.party_id = p_party_id;
  ELSIF p_cust_account_id IS NOT NULL THEN
    SELECT sum
             (
               (
                 GET_APPS_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) -
                 GET_ADJ_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) +
                 nvl(ps.acctd_amount_due_remaining, 0)
               ) *
               (ps.due_date - ps.trx_date)
             )  /
             sum (
               GET_APPS_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) -
               GET_ADJ_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) +
               nvl(ps.acctd_amount_due_remaining, 0)
             )
      INTO   l_wtd_days_terms
      FROM   ar_payment_schedules 	ps
      WHERE  ps.gl_date between TRUNC(add_months(sysdate, -12)) and  TRUNC(sysdate)
      AND    ps.class in ('INV','DEP','DM','CB')
       -- Begin fix bug #4917851-jypark-11/47/2005-remove invalid condition
       -- AND ps.gl_date_closed > TRUNC(sysdate)
       -- AND ps.due_date       < TRUNC(sysdate)
       -- End fix bug #4917851-jypark-11/47/2005-remove invalid condition
      AND    ps.payment_schedule_id <> -1
      AND    ps.customer_id = p_cust_account_id;
  ELSIF p_customer_site_use_id IS NOT NULL THEN
    SELECT sum
             (
               (
                 GET_APPS_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) -
                 GET_ADJ_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) +
                 nvl(ps.acctd_amount_due_remaining, 0)
               ) *
               (ps.due_date - ps.trx_date)
             )  /
             sum (
               GET_APPS_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) -
               GET_ADJ_TOTAL(ps.payment_schedule_id, TRUNC(sysdate)) +
               nvl(ps.acctd_amount_due_remaining, 0)
             )
      INTO   l_wtd_days_terms
      FROM   ar_payment_schedules 	ps
      WHERE  ps.gl_date between TRUNC(add_months(sysdate, -12)) and  TRUNC(sysdate)
      AND    ps.class in ('INV','DEP','DM','CB')
       -- Begin fix bug #4917851-jypark-11/47/2005-remove invalid condition
       -- AND ps.gl_date_closed > TRUNC(sysdate)
       -- AND ps.due_date       < TRUNC(sysdate)
       -- End fix bug #4917851-jypark-11/47/2005-remove invalid condition
      AND    ps.payment_schedule_id <> -1
      AND    ps.customer_site_use_id = p_customer_site_use_id;
  END IF;

  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  --RETURN  TO_CHAR(TRUNC(NVL(l_wtd_days_terms, 0)));
  l_num_val :=  TRUNC(NVL(l_wtd_days_terms, 0));
  l_char_val := RTRIM(TO_CHAR(l_num_val));
  RETURN l_char_val;
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable

EXCEPTION
  WHEN NO_DATA_FOUND THEN RETURN(TO_CHAR(0));
END GET_WTD_DAYS_TERMS;

FUNCTION GET_CEI(p_party_id IN NUMBER,
                 p_cust_account_id IN NUMBER,
                 p_customer_site_use_id IN NUMBER) RETURN VARCHAR2 AS
  l_cei     NUMBER;
  l_sales   NUMBER;
  l_beg_ar  NUMBER;
  l_end_ar  NUMBER;
  l_curr_ar NUMBER;
  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  l_num_val NUMBER;
  l_char_val VARCHAR2(1000);
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable

BEGIN
  /*-----------------------------------------------------------------------
  CEI = ( Beginning Receivables + ( Credit Sales/ N*) - Ending Total Receivables) * 100
       / (Beginning Receivables + ( Credit Sales/N*) - Ending Current Receivables)

   *N= Number of Months 	Can do this monthly, quarterly , and annually
  */

  l_sales    := COMP_TOT_REC(TRUNC(add_months(sysdate, -12)), TRUNC(sysdate),
                            p_party_id, p_cust_account_id, p_customer_site_use_id);

  l_beg_ar   := COMP_REM_REC(to_date('01/01/1952','MM/DD/YYYY'), TRUNC(add_months(sysdate, -12)) - 1,
                            p_party_id, p_cust_account_id, p_customer_site_use_id);

  l_end_ar   := COMP_REM_REC(to_date('01/01/1952','MM/DD/YYYY'), TRUNC(sysdate),
                            p_party_id, p_cust_account_id, p_customer_site_use_id);

  l_curr_ar  := comp_curr_rec(to_date('01/01/1952','MM/DD/YYYY'), TRUNC(sysdate),
                            p_party_id, p_cust_account_id, p_customer_site_use_id);

  l_cei      := (l_beg_ar + (l_sales / 12) - l_end_ar) * 100 / (l_beg_ar + (l_sales / 12) - l_curr_ar);

  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  --RETURN TO_CHAR(TRUNC(NVL(l_cei, 0)));
  l_num_val :=  TRUNC(NVL(l_cei, 0));
  l_char_val := RTRIM(TO_CHAR(l_num_val));
  RETURN l_char_val;
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN(TO_CHAR(0));
END GET_CEI;

FUNCTION GET_TRUE_DSO(p_party_id IN NUMBER,
                     p_cust_account_id IN NUMBER,
                     p_customer_site_use_id IN NUMBER) RETURN VARCHAR2 AS
  l_sales NUMBER;
  l_beg_ar NUMBER;
  l_end_ar NUMBER;
  l_dso NUMBER;
  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  l_num_val NUMBER;
  l_char_val VARCHAR2(1000);
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable

BEGIN

  /*-----------------------------------------------------------------------
  DSO = ( Period Average Receivables / Average Sales per day)

    where tot outs rec = sum of all receivables less all receipts (use COMP_REM_REC)
    avg sales per day = sum of all receivables (use COMP_TOT_REC) / days in period
  -----------------------------------------------------------------------*/

  l_sales    := COMP_TOT_REC(TRUNC(add_months(sysdate, -12)), TRUNC(sysdate),
                            p_party_id, p_cust_account_id, p_customer_site_use_id);

  l_beg_ar   := COMP_REM_REC(to_date('01/01/1952','MM/DD/YYYY'), TRUNC(add_months(sysdate, -12)) - 1,
                            p_party_id, p_cust_account_id, p_customer_site_use_id);

  l_end_ar   := COMP_REM_REC(to_date('01/01/1952','MM/DD/YYYY'), TRUNC(sysdate),
                            p_party_id, p_cust_account_id, p_customer_site_use_id);

   if ( nvl(l_sales,0) = 0 ) then
     l_dso := 0;
   else
     l_dso := (((l_beg_ar + l_end_ar)/2)/l_sales)*(TRUNC(sysdate) - TRUNC(add_months(sysdate, -12)));
   end if;

  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  --RETURN TO_CHAR(ROUND(nvl(l_dso,0), 0));
  l_num_val := ROUND(nvl(l_dso,0), 0);
  l_char_val := RTRIM(TO_CHAR(l_num_val));
  RETURN l_char_val;
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable

END GET_TRUE_DSO;

FUNCTION GET_CONV_DSO(p_party_id IN NUMBER,
                     p_cust_account_id IN NUMBER,
                     p_customer_site_use_id IN NUMBER) RETURN VARCHAR2 AS
  l_conv_dso NUMBER;
  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  l_num_val NUMBER;
  l_char_val VARCHAR2(1000);
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable

BEGIN
  IF p_party_id IS NOT NULL THEN
    SELECT
         ROUND(
           ( (SUM( DECODE(PS.CLASS,
                         'INV', 1,
                         'DM',  1,
                         'CB',  1,
                         'DEP', 1,
                         'BR',  1,
                          0)
                    * PS.ACCTD_AMOUNT_DUE_REMAINING
                  ) * MAX(SP.CER_DSO_DAYS)
              )
              / DECODE(
                     SUM( DECODE(PS.CLASS,
                                'INV', 1,
                                'DM',  1,
                                'DEP', 1,
                                 0)
                           * DECODE(SIGN (TRUNC(SYSDATE) - PS.TRX_DATE - SP.CER_DSO_DAYS),
                                    -1, (PS.AMOUNT_DUE_ORIGINAL  + NVL(PS.AMOUNT_ADJUSTED,0)) * NVL(PS.EXCHANGE_RATE, 1 ),
                                     0)) ,
                     0, 1,
                     SUM( DECODE(PS.CLASS,
                                'INV', 1,
                                'DM',  1,
                                'DEP', 1,
                                 0)
                          * DECODE(SIGN (TRUNC(SYSDATE) - PS.TRX_DATE - SP.CER_DSO_DAYS),
                                   -1, (PS.AMOUNT_DUE_ORIGINAL  + NVL(PS.AMOUNT_ADJUSTED,0)) * NVL(PS.EXCHANGE_RATE, 1 ),
                                   0) )
                      )
            ), 0)                                     /* DSO */
    INTO l_conv_dso
    FROM ar_system_parameters         sp,
         hz_cust_accounts             cust_acct,
         ar_payment_schedules         ps
    WHERE ps.customer_id = cust_acct.cust_account_id
    AND cust_acct.party_id = p_party_id
    -- Begin fix bug #5261855-jypark-06/16/2006-add addtional condition for performance
    AND ps.status = 'OP'
    -- End fix bug #5261855-jypark-06/16/2006-add addtional condition for performance
    AND NVL(ps.receipt_confirmed_flag,'Y') = 'Y';
  ELSIF p_cust_account_id IS NOT NULL THEN
    SELECT
          ROUND(
           ( (SUM( DECODE(PS.CLASS,
                         'INV', 1,
                         'DM',  1,
                         'CB',  1,
                         'DEP', 1,
                         'BR',  1,
                          0)
                    * PS.ACCTD_AMOUNT_DUE_REMAINING
                  ) * MAX(SP.CER_DSO_DAYS)
              )
              / DECODE(
                     SUM( DECODE(PS.CLASS,
                                'INV', 1,
                                'DM',  1,
                                'DEP', 1,
                                 0)
                           * DECODE(SIGN (TRUNC(SYSDATE) - PS.TRX_DATE - SP.CER_DSO_DAYS),
                                    -1, (PS.AMOUNT_DUE_ORIGINAL  + NVL(PS.AMOUNT_ADJUSTED,0)) * NVL(PS.EXCHANGE_RATE, 1 ),
                                     0)) ,
                     0, 1,
                     SUM( DECODE(PS.CLASS,
                                'INV', 1,
                                'DM',  1,
                                'DEP', 1,
                                 0)
                          * DECODE(SIGN (TRUNC(SYSDATE) - PS.TRX_DATE - SP.CER_DSO_DAYS),
                                   -1, (PS.AMOUNT_DUE_ORIGINAL  + NVL(PS.AMOUNT_ADJUSTED,0)) * NVL(PS.EXCHANGE_RATE, 1 ),
                                   0) )
                      )
            ), 0)                                     /* DSO */
    INTO l_conv_dso
    FROM ar_system_parameters         sp,
         ar_payment_schedules         ps
    WHERE ps.customer_id = p_cust_account_id
    -- Begin fix bug #5261855-jypark-06/16/2006-add addtional condition for performance
    AND ps.status = 'OP'
    -- End fix bug #5261855-jypark-06/16/2006-add addtional condition for performance
    AND NVL(ps.receipt_confirmed_flag,'Y') = 'Y';

  ELSIF p_customer_site_use_id IS NOT NULL THEN
    SELECT
          ROUND(
           ( (SUM( DECODE(PS.CLASS,
                         'INV', 1,
                         'DM',  1,
                         'CB',  1,
                         'DEP', 1,
                         'BR',  1,
                          0)
                    * PS.ACCTD_AMOUNT_DUE_REMAINING
                  ) * MAX(SP.CER_DSO_DAYS)
              )
              / DECODE(
                     SUM( DECODE(PS.CLASS,
                                'INV', 1,
                                'DM',  1,
                                'DEP', 1,
                                 0)
                           * DECODE(SIGN (TRUNC(SYSDATE) - PS.TRX_DATE - SP.CER_DSO_DAYS),
                                    -1, (PS.AMOUNT_DUE_ORIGINAL  + NVL(PS.AMOUNT_ADJUSTED,0)) * NVL(PS.EXCHANGE_RATE, 1 ),
                                     0)) ,
                     0, 1,
                     SUM( DECODE(PS.CLASS,
                                'INV', 1,
                                'DM',  1,
                                'DEP', 1,
                                 0)
                          * DECODE(SIGN (TRUNC(SYSDATE) - PS.TRX_DATE - SP.CER_DSO_DAYS),
                                   -1, (PS.AMOUNT_DUE_ORIGINAL  + NVL(PS.AMOUNT_ADJUSTED,0)) * NVL(PS.EXCHANGE_RATE, 1 ),
                                   0) )
                      )
            ), 0)                                     /* DSO */
    INTO l_conv_dso
    FROM ar_system_parameters         sp,
         ar_payment_schedules         ps
    WHERE ps.customer_site_use_id = p_customer_site_use_id
    -- Begin fix bug #5261855-jypark-06/16/2006-add addtional condition for performance
    AND ps.status = 'OP'
    -- End fix bug #5261855-jypark-06/16/2006-add addtional condition for performance
    AND NVL(ps.receipt_confirmed_flag,'Y') = 'Y';

  END IF;

  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  --RETURN TO_CHAR(ROUND(NVL(l_conv_dso, 0)));
  l_num_val := ROUND(NVL(l_conv_dso, 0));
  l_char_val := RTRIM(TO_CHAR(l_num_val));
  RETURN l_char_val;
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable


EXCEPTION
  WHEN NO_DATA_FOUND THEN RETURN(TO_CHAR(0));
END GET_CONV_DSO;

FUNCTION GET_NSF_STOP_PMT_COUNT(p_party_id IN NUMBER,
                     p_cust_account_id IN NUMBER,
                     p_customer_site_use_id IN NUMBER) RETURN VARCHAR2 AS
  l_nsf_stop_payment_count NUMBER;
  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  l_num_val NUMBER;
  l_char_val VARCHAR2(1000);
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable

BEGIN

  IF p_party_id IS NOT NULL THEN
    SELECT COUNT(cr.cash_receipt_id) NSF_STOP_PAYMENT_COUNT
    INTO l_nsf_stop_payment_count
    FROM  ar_cash_receipts cr,
          ar_cash_receipt_history crh,
          hz_cust_accounts ca
    WHERE cr.cash_receipt_id = crh.cash_receipt_id
      AND crh.current_record_flag = 'Y'
      AND crh.status = 'REVERSED'
-- BEGIN fix bug #4483830--20050714-jypark-change query for NSF info
--      AND cr.status = 'REV'
--      AND cr.status = 'NSF' -- bug 5613019
        AND cr.status in ('NSF','REV') -- bug 5613019
-- END fix bug #4483830--20050714-jypark-change query for NSF info
      --AND cr.reversal_category = 'NSF'  -- big 5613019
      AND cr.reversal_category in ('NSF','REV') -- bug 5613019
      AND cr.reversal_date BETWEEN TRUNC(add_months(sysdate, -12)) AND TRUNC(sysdate)
      AND cr.pay_from_customer = ca.cust_account_id
      AND ca.party_id = p_party_id;
  ELSIF p_cust_account_id IS NOT NULL THEN
    SELECT COUNT(cr.cash_receipt_id) NSF_STOP_PAYMENT_COUNT
    INTO l_nsf_stop_payment_count
    FROM  ar_cash_receipts cr,
          ar_cash_receipt_history crh
    WHERE cr.cash_receipt_id = crh.cash_receipt_id
      AND crh.current_record_flag = 'Y'
      AND crh.status = 'REVERSED'
-- BEGIN fix bug #4483830--20050714-jypark-change query for NSF info
--      AND cr.status = 'REV'
--      AND cr.status = 'NSF'  --bug 5613019
        AND cr.status in ('NSF','REV') -- bug 5613019
-- END fix bug #4483830--20050714-jypark-change query for NSF info
      --AND cr.reversal_category = 'NSF'  -- bug 5613019
      and cr.reversal_category in ('NSF','REV') -- bug 5613019
      AND cr.reversal_date BETWEEN TRUNC(add_months(sysdate, -12)) AND TRUNC(sysdate)
      AND cr.pay_from_customer = p_cust_account_id;
  ELSIF p_customer_site_use_id IS NOT NULL THEN
    SELECT COUNT(cr.cash_receipt_id) NSF_STOP_PAYMENT_COUNT
    INTO l_nsf_stop_payment_count
    FROM  ar_cash_receipts cr,
          ar_cash_receipt_history crh
    WHERE cr.cash_receipt_id = crh.cash_receipt_id
      AND crh.current_record_flag = 'Y'
      AND crh.status = 'REVERSED'
-- BEGIN fix bug #4483830--20050714-jypark-change query for NSF info
--      AND cr.status = 'REV'
--      AND cr.status = 'NSF'  --bug 5613019
        and cr.status in ('NSF','REV') -- bug 5613019
-- END fix bug #4483830--20050714-jypark-change query for NSF info
      -- AND cr.reversal_category = 'NSF'  -- bug 5613019
      and cr.reversal_category in ('NSF','REV') -- bug 5613019
      AND cr.reversal_date BETWEEN TRUNC(add_months(sysdate, -12)) AND TRUNC(sysdate)
      AND cr.customer_site_use_id = p_customer_site_use_id;
  END IF;

  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  --RETURN TO_CHAR(TRUNC(nvl(l_nsf_stop_payment_count, 0)));
  l_num_val := TRUNC(nvl(l_nsf_stop_payment_count, 0));
  l_char_val := RTRIM(TO_CHAR(l_num_val));
  RETURN l_char_val;
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable

EXCEPTION
  WHEN NO_DATA_FOUND THEN RETURN(0);
END GET_NSF_STOP_PMT_COUNT;

FUNCTION GET_NSF_STOP_PMT_AMOUNT(p_party_id IN NUMBER,
                     p_cust_account_id IN NUMBER,
                     p_customer_site_use_id IN NUMBER) RETURN VARCHAR2 AS
  l_nsf_stop_payment_amount NUMBER;
  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  l_num_val NUMBER;
  l_char_val VARCHAR2(1000);
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable

BEGIN

  IF p_party_id IS NOT NULL THEN
    SELECT SUM(cr.amount) NSF_STOP_PAYMENT_AMOUNT
    INTO l_nsf_stop_payment_amount
    FROM  ar_cash_receipts_all cr,
          ar_cash_receipt_history_all crh,
          hz_cust_accounts ca
    WHERE cr.cash_receipt_id = crh.cash_receipt_id
      AND crh.current_record_flag = 'Y'
      AND crh.status = 'REVERSED'
-- BEGIN fix bug #4483830--20050714-jypark-change query for NSF info
--      AND cr.status = 'REV'
--      AND cr.status = 'NSF'  -- bug 5613019
        and cr.status in ('NSF','REV') -- bug 5613019
-- END fix bug #4483830--20050714-jypark-change query for NSF info
      -- AND cr.reversal_category = 'NSF' --bug 5613019
      and cr.reversal_category in ('NSF','REV') -- bug 5613019
      AND cr.reversal_date BETWEEN TRUNC(add_months(sysdate, -12)) AND TRUNC(sysdate)
      AND cr.pay_from_customer = ca.cust_account_id
      AND ca.party_id = p_party_id;
  ELSIF p_cust_account_id IS NOT NULL THEN
    SELECT SUM(cr.amount) NSF_STOP_PAYMENT_AMOUNT
    INTO l_nsf_stop_payment_amount
    FROM  ar_cash_receipts_all cr,
          ar_cash_receipt_history_all crh
    WHERE cr.cash_receipt_id = crh.cash_receipt_id
      AND crh.current_record_flag = 'Y'
      AND crh.status = 'REVERSED'
-- BEGIN fix bug #4483830--20050714-jypark-change query for NSF info
--      AND cr.status = 'REV'
--      AND cr.status = 'NSF'  -- bug 5613019
        and cr.status in ('NSF','REV') -- bug 5613019
-- END fix bug #4483830--20050714-jypark-change query for NSF info
      -- AND cr.reversal_category = 'NSF' --bug 5613019
      and cr.reversal_category in ('NSF','REV') -- bug 5613019
      AND cr.reversal_date BETWEEN TRUNC(add_months(sysdate, -12)) AND TRUNC(sysdate)
      AND cr.pay_from_customer = p_cust_account_id;
  ELSIF p_customer_site_use_id IS NOT NULL THEN
    SELECT SUM(cr.amount) NSF_STOP_PAYMENT_AMOUNT
    INTO l_nsf_stop_payment_amount
    FROM  ar_cash_receipts_all cr,
          ar_cash_receipt_history_all crh
    WHERE cr.cash_receipt_id = crh.cash_receipt_id
      AND crh.current_record_flag = 'Y'
      AND crh.status = 'REVERSED'
-- BEGIN fix bug #4483830--20050714-jypark-change query for NSF info
--      AND cr.status = 'REV'
--      AND cr.status = 'NSF' -- bug5613019
        and cr.status in ('NSF','REV') -- bug 5613019
-- END fix bug #4483830--20050714-jypark-change query for NSF info
      -- AND cr.reversal_category = 'NSF'  -- bug 5613019
      and cr.reversal_category in ('NSF','REV') -- bug 5613019
      AND cr.reversal_date BETWEEN TRUNC(add_months(sysdate, -12)) AND TRUNC(sysdate)
      AND cr.customer_site_use_id = p_customer_site_use_id;
  END IF;

  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  --RETURN TO_CHAR(nvl(l_nsf_stop_payment_amount, 0), fnd_currency.get_format_mask(g_curr_rec.base_currency, 30));
  l_num_val :=  nvl(l_nsf_stop_payment_amount, 0);
  l_char_val := RTRIM(TO_CHAR(l_num_val,fnd_currency.get_format_mask(g_curr_rec.base_currency, 30)));
  RETURN l_char_val;
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable

EXCEPTION
  WHEN NO_DATA_FOUND THEN RETURN(0);
END GET_NSF_STOP_PMT_AMOUNT;

FUNCTION GET_SALES(p_party_id IN NUMBER,
                   p_cust_account_id IN NUMBER,
                   p_customer_site_use_id IN NUMBER) RETURN VARCHAR2 AS
  l_sales NUMBER;
  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  l_num_val NUMBER;
  l_char_val VARCHAR2(1000);
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable

BEGIN

  l_sales    := COMP_TOT_REC(TRUNC(add_months(sysdate, -12)), TRUNC(sysdate),
                            p_party_id, p_cust_account_id, p_customer_site_use_id);

  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  --RETURN(TO_CHAR(NVL(l_sales, 0), fnd_currency.get_format_mask(g_curr_rec.base_currency, 50)));
  l_num_val := NVL(l_sales, 0);
  l_char_val := RTRIM(TO_CHAR(l_num_val, fnd_currency.get_format_mask(g_curr_rec.base_currency, 50)));
  RETURN l_char_val;
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable

END GET_SALES;


FUNCTION GET_DEDUCTION(p_party_id IN NUMBER,
                   p_cust_account_id IN NUMBER,
                   p_customer_site_use_id IN NUMBER) RETURN VARCHAR2 AS
  l_adj NUMBER;
  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  l_num_val NUMBER;
  l_char_val VARCHAR2(1000);
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable

BEGIN
  IF p_party_id IS NOT NULL THEN
    SELECT
       sum( nvl(adj.acctd_amount,0))
    INTO    l_adj
    FROM    ar_payment_schedules ps, ar_adjustments adj, hz_cust_accounts ca
    WHERE   ps.class in ('INV', 'DM', 'CB', 'DEP' )
    AND     ps.payment_schedule_id <> -1
    AND     ps.gl_date BETWEEN TRUNC(add_months(sysdate, -12)) AND TRUNC(sysdate)
    AND     ps.customer_id = ca.cust_account_id
    AND     ca.party_id = p_party_id
    AND     adj.payment_schedule_id = ps.payment_schedule_id
    AND     adj.status = 'A'
    AND     adj.gl_date <= TRUNC(sysdate);
  ELSIF p_cust_account_id IS NOT NULL THEN
    SELECT
       sum( nvl(adj.acctd_amount,0))
    INTO    l_adj
    FROM    ar_payment_schedules ps, ar_adjustments adj
    WHERE   ps.class in ('INV', 'DM', 'CB', 'DEP' )
    AND     ps.payment_schedule_id <> -1
    AND     ps.gl_date BETWEEN TRUNC(add_months(sysdate, -12)) AND TRUNC(sysdate)
    AND     ps.customer_id = p_cust_account_id
    AND     adj.payment_schedule_id = ps.payment_schedule_id
    AND     adj.status = 'A'
    AND     adj.gl_date <= TRUNC(sysdate);
  ELSIF p_customer_site_use_id IS NOT NULL THEN
    SELECT
       sum( nvl(adj.acctd_amount,0))
    INTO    l_adj
    FROM    ar_payment_schedules ps, ar_adjustments adj
    WHERE   ps.class in ('INV', 'DM', 'CB', 'DEP' )
    AND     ps.payment_schedule_id <> -1
    AND     ps.gl_date BETWEEN TRUNC(add_months(sysdate, -12)) AND TRUNC(sysdate)
    AND     ps.customer_site_use_id = p_customer_site_use_id
    AND     adj.payment_schedule_id = ps.payment_schedule_id
    AND     adj.status = 'A'
    AND     adj.gl_date <= TRUNC(sysdate);
  END IF;

  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  --RETURN(TO_CHAR(nvl(l_adj, 0),  fnd_currency.get_format_mask(g_curr_rec.base_currency, 50)));
  l_num_val := nvl(l_adj, 0);
  l_char_val := RTRIM(TO_CHAR(l_num_val, fnd_currency.get_format_mask(g_curr_rec.base_currency, 50)));
  RETURN l_char_val;
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable

EXCEPTION
  WHEN NO_DATA_FOUND THEN RETURN(0);
END GET_DEDUCTION;

/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |                                                                         |
 |    COMP_TOT_REC                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    Given a date range, this function will compute the total original    |
 |    receivables within the date range                                    |
 |    If function is called with a null start date, then the function      |
 |    RETURNs total original receivables as of p_end_date                  |
 |                                                                         |
 | REQUIRES                                                                |
 |    start_date                                                           |
 |    end_date                                                             |
 |                                                                         |
 | OPTIONAL                                                                |
 |                                                                         |
 | RETURNS                                                                 |
 |    total original receivables                                           |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |                                                                         |
 |                                                                         |
 +-------------------------------------------------------------------------*/

FUNCTION COMP_TOT_REC(p_start_date IN DATE,
                      p_end_date   IN DATE,
                      p_party_id IN NUMBER,
                      p_cust_account_id IN NUMBER,
                      p_customer_site_use_id IN NUMBER) RETURN NUMBER AS
  l_tot_rec           NUMBER;
  l_temp_start        DATE;

  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  l_num_val NUMBER;
  l_char_val VARCHAR2(1000);
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable

BEGIN

  if p_start_date is null then
    -- default date to earliest date to pick up everything prior to
    -- p_end_date
    l_temp_start := to_date('01/01/1952','MM/DD/YYYY');
  else
    l_temp_start := p_start_date;
  end if;

  IF p_party_id IS NOT NULL THEN
    SELECT  SUM(arpcurr.functional_amount(
      ps.amount_due_original,
      g_curr_rec.base_currency,
      nvl(ps.exchange_rate,1),
      g_curr_rec.base_precision,
      g_curr_rec.base_min_acc_unit) +
       GET_ADJ_FOR_TOT_REC(ps.payment_schedule_id,p_end_date))
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
      g_curr_rec.base_currency,
      nvl(ps.exchange_rate,1),
      g_curr_rec.base_precision,
      g_curr_rec.base_min_acc_unit) +
       GET_ADJ_FOR_TOT_REC(ps.payment_schedule_id,p_end_date))
    INTO    l_tot_rec
    FROM    ar_payment_schedules   ps
    WHERE   ps.class in ('INV', 'DM', 'CB', 'DEP' )
    AND     ps.payment_schedule_id <> -1
    AND     ps.gl_date BETWEEN l_temp_start AND p_end_date
    AND     ps.customer_id = p_cust_account_id;
  ELSIF p_customer_site_use_id IS NOT NULL THEN
    SELECT  SUM(arpcurr.functional_amount(
      ps.amount_due_original,
      g_curr_rec.base_currency,
      nvl(ps.exchange_rate,1),
      g_curr_rec.base_precision,
      g_curr_rec.base_min_acc_unit) +
       GET_ADJ_FOR_TOT_REC(ps.payment_schedule_id,p_end_date))
    INTO    l_tot_rec
    FROM    ar_payment_schedules   ps
    WHERE   ps.class in ('INV', 'DM', 'CB', 'DEP' )
    AND     ps.payment_schedule_id <> -1
    AND     ps.gl_date BETWEEN l_temp_start AND p_end_date
    AND     ps.customer_site_use_id = p_customer_site_use_id;
  END IF;

  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  --RETURN(nvl(l_tot_rec,0));
  l_num_val := nvl(l_tot_rec, 0);
  RETURN l_num_val;
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable

EXCEPTION
  WHEN NO_DATA_FOUND THEN RETURN(0);
END COMP_TOT_REC;


/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |                                                                         |
 |    COMP_REM_REC                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    Given a date range, this function will compute the total remaining   |
 |    receivables within the date range                                    |
 |                                                                         |
 | REQUIRES                                                                |
 |    start_date                                                           |
 |    end_date                                                             |
 |                                                                         |
 | OPTIONAL                                                                |
 |                                                                         |
 | RETURNS                                                                 |
 |    total remaining receivables                                          |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |                                      there is no record found           |
 +-------------------------------------------------------------------------*/

FUNCTION COMP_REM_REC(p_start_date IN DATE,
                      p_end_date   IN DATE,
                      p_party_id IN NUMBER,
                      p_cust_account_id IN NUMBER,
                      p_customer_site_use_id IN NUMBER) RETURN NUMBER IS

  l_rem_sales  NUMBER;
  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  l_num_val NUMBER;
  l_char_val VARCHAR2(1000);
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable

BEGIN

  l_rem_sales := 0;

  IF p_party_id IS NOT NULL THEN
    -- compute Remaining balance for given date range

    SELECT sum(GET_APPS_TOTAL(ps.payment_schedule_id,p_end_date) -
           GET_ADJ_TOTAL(ps.payment_schedule_id,p_end_date) +
           nvl(ps.acctd_amount_due_remaining,0))
    INTO   l_rem_sales
    FROM   ar_payment_schedules         ps,
           hz_cust_accounts ca
    WHERE  ps.gl_date between p_start_date and p_end_date
    AND    ps.class in ('INV','DEP','DM','CB')
    AND    ps.gl_date_closed > p_end_date
    AND    ps.customer_id = ca.cust_account_id
    -- Begin fix bug #4949598-JYPARK-2/15/2006-add condition for performance
      AND    ps.status = 'OP'
    -- End fix bug #4949598-JYPARK-2/15/2006-add condition for performance
    AND    ca.party_id = p_party_id;
  ELSIF p_cust_account_id IS NOT NULL THEN
    -- compute Remaining balance for given date range

    SELECT sum(GET_APPS_TOTAL(ps.payment_schedule_id,p_end_date) -
           GET_ADJ_TOTAL(ps.payment_schedule_id,p_end_date) +
           nvl(ps.acctd_amount_due_remaining,0))
    INTO   l_rem_sales
    FROM   ar_payment_schedules         ps
    WHERE  ps.gl_date between p_start_date and p_end_date
    AND    ps.class in ('INV','DEP','DM','CB')
    AND    ps.gl_date_closed > p_end_date
    -- Begin fix bug #4949598-JYPARK-2/15/2006-add condition for performance
      AND    ps.status = 'OP'
    -- End fix bug #4949598-JYPARK-2/15/2006-add condition for performance
    AND    ps.customer_id = p_cust_account_id;
  ELSIF p_customer_site_use_id IS NOT NULL THEN
    -- compute Remaining balance for given date range

    SELECT sum(GET_APPS_TOTAL(ps.payment_schedule_id,p_end_date) -
           GET_ADJ_TOTAL(ps.payment_schedule_id,p_end_date) +
           nvl(ps.acctd_amount_due_remaining,0))
    INTO   l_rem_sales
    FROM   ar_payment_schedules         ps
    WHERE  ps.gl_date between p_start_date and p_end_date
    AND    ps.class in ('INV','DEP','DM','CB')
    AND    ps.gl_date_closed > p_end_date
    -- Begin fix bug #4949598-JYPARK-2/15/2006-add condition for performance
      AND    ps.status = 'OP'
    -- End fix bug #4949598-JYPARK-2/15/2006-add condition for performance
    AND    ps.customer_site_use_id = p_customer_site_use_id;
  END IF;

  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  l_num_val := (NVL(l_rem_sales,0));
  RETURN l_num_val;
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable

EXCEPTION
  WHEN NO_DATA_FOUND THEN RETURN(0);
END COMP_REM_REC;

/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |                                                                         |
 |    comp_curr_rec                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    Given a date range, this function will compute the total current     |
 |    receivables within the date range                                    |
 |                                                                         |
 | REQUIRES                                                                |
 |    start_date                                                           |
 |    end_date                                                             |
 |                                                                         |
 | OPTIONAL                                                                |
 |                                                                         |
 | RETURNS                                                                 |
 |    total current receivables                                            |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 +-------------------------------------------------------------------------*/

FUNCTION COMP_CURR_REC(p_start_date IN DATE,
                      p_end_date   IN DATE,
                      p_party_id IN NUMBER,
                      p_cust_account_id IN NUMBER,
                      p_customer_site_use_id IN NUMBER) RETURN NUMBER IS

  l_curr_rec  NUMBER;
  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  l_num_val NUMBER;
  l_char_val VARCHAR2(1000);
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable

BEGIN

  l_curr_rec := 0;

  IF p_party_id IS NOT NULL THEN
    -- compute Remaining balance for given date range

    SELECT sum(nvl(ps.acctd_amount_due_remaining,0))
    INTO   l_curr_rec
    FROM   ar_payment_schedules         ps,
           hz_cust_accounts             ca
    WHERE  ps.gl_date between p_start_date and p_end_date
    AND    ps.class in ('INV','DEP','DM','CB')
    AND    ps.gl_date_closed > p_end_date
    AND    ps.status = 'OP'
    AND    ps.customer_id = ca.cust_account_id
    AND    ca.party_id = p_party_id
    AND    ps.due_date > p_end_date;
  ELSIF p_cust_account_id IS NOT NULL THEN
    -- compute Remaining balance for given date range

    SELECT sum(nvl(ps.acctd_amount_due_remaining,0))
    INTO   l_curr_rec
    FROM   ar_payment_schedules         ps
    WHERE  ps.gl_date between p_start_date and p_end_date
    AND    ps.class in ('INV','DEP','DM','CB')
    AND    ps.gl_date_closed > p_end_date
    AND    ps.status = 'OP'
    AND    ps.customer_id = p_cust_account_id
    AND    ps.due_date > p_end_date;
  ELSIF p_customer_site_use_id IS NOT NULL THEN
    -- compute Remaining balance for given date range

    SELECT sum(nvl(ps.acctd_amount_due_remaining,0))
    INTO   l_curr_rec
    FROM   ar_payment_schedules         ps
    WHERE  ps.gl_date between p_start_date and p_end_date
    AND    ps.class in ('INV','DEP','DM','CB')
    AND    ps.gl_date_closed > p_end_date
    AND    ps.status = 'OP'
    AND    ps.customer_site_use_id = p_customer_site_use_id
    AND    ps.due_date > p_end_date;
  END IF;

  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  --RETURN (NVL(l_curr_rec,0));
  l_num_val := (NVL(l_curr_rec,0));
  RETURN l_num_val;
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable

EXCEPTION
  WHEN NO_DATA_FOUND THEN RETURN(0);
END COMP_CURR_REC;


/*========================================================================
 | PRIVATE FUNCTION GET_APPS_TOTAL
 |
 | DESCRIPTION
 |    Calculates the total applications against a payment_schedule
 |
 =======================================================================*/

FUNCTION GET_APPS_TOTAL(p_payment_schedule_id IN NUMBER,
                        p_to_date IN DATE) RETURN NUMBER IS
  l_apps_tot  NUMBER;

  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  l_num_val NUMBER;
  l_char_val VARCHAR2(1000);
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable

BEGIN
  SELECT   sum( nvl(ra.acctd_amount_applied_to,0)  +
                nvl(ra.acctd_earned_discount_taken,0) +
                nvl(ra.acctd_unearned_discount_taken,0))
  INTO     l_apps_tot
  FROM     ar_receivable_applications   ra
  WHERE    ra.applied_payment_schedule_id = p_payment_schedule_id
  AND      ra.status = 'APP'
  AND      nvl(ra.confirmed_flag,'Y') = 'Y'
  AND      ra.gl_date   > p_to_date;

  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  --RETURN NVL(l_apps_tot,0);
  l_num_val := NVL(l_apps_tot,0);
  RETURN l_num_val;
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable

EXCEPTION
  WHEN NO_DATA_FOUND THEN RETURN(0);

END GET_APPS_TOTAL;

/*========================================================================
 | PRIVATE FUNCTION GET_ADJ_TOTAL
 |
 | DESCRIPTION
 |    Calculates the total adjustments against a payment_schedule
 |
 *=======================================================================*/

FUNCTION GET_ADJ_TOTAL(p_payment_schedule_id IN NUMBER,
                       p_to_date IN DATE) RETURN NUMBER IS
  l_adj_tot  NUMBER;

  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  l_num_val NUMBER;
  l_char_val VARCHAR2(1000);
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable

BEGIN
  SELECT  sum( nvl(a.acctd_amount,0))
  INTO    l_adj_tot
  FROM    ar_adjustments   a
  WHERE   a.payment_schedule_id = p_payment_schedule_id
  AND     a.status       = 'A'
  AND     a.gl_date       > p_to_date;

  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  --RETURN nvl(l_adj_tot,0);
  l_num_val := nvl(l_adj_tot,0);
  RETURN l_num_val;
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable

EXCEPTION
  WHEN NO_DATA_FOUND THEN RETURN(0);

END GET_ADJ_TOTAL;

FUNCTION GET_ADJ_FOR_TOT_REC(p_payment_schedule_id IN NUMBER,
                             p_to_date IN DATE) RETURN NUMBER IS
  l_adj_for_tot_rec NUMBER;

  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  l_num_val NUMBER;
  l_char_val VARCHAR2(1000);
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable

BEGIN
  SELECT  sum( nvl(a.acctd_amount,0))
  INTO    l_adj_for_tot_rec
  FROM    ar_adjustments   a
  WHERE   a.payment_schedule_id = p_payment_schedule_id
  AND     a.status = 'A'
  AND     a.gl_date <= p_to_date;

  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  --RETURN nvl(l_adj_for_tot_rec,0);
  l_num_val := nvl(l_adj_for_tot_rec,0);
  RETURN l_num_val;
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable

EXCEPTION
  WHEN NO_DATA_FOUND THEN RETURN(0);

END GET_ADJ_FOR_TOT_REC;

FUNCTION GET_CREDIT_LIMIT(p_party_id IN NUMBER,
                   p_cust_account_id IN NUMBER,
                   p_customer_site_use_id IN NUMBER) RETURN VARCHAR2 AS
  l_credit_limit NUMBER;
  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  l_num_val NUMBER;
  l_char_val VARCHAR2(1000);
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  -- Start for the bug#8630157 by PNAVEENK
  l_conversion_type VARCHAR(30);
BEGIN
  l_conversion_type := NVL(FND_PROFILE.VALUE('IEX_EXCHANGE_RATE_TYPE'), 'Corporate');
  IF p_party_id IS NOT NULL THEN
    -- Begin fix bug #6014218-31-May-07 gnramasa -return null when credit limits value is null instead of -2
    --SELECT SUM(gl_currency_api.convert_amount_sql(prof_amt.currency_code, g_curr_rec.base_currency,
    SELECT SUM(DECODE(prof_amt.overall_credit_limit, NULL, NULL, gl_currency_api.convert_amount_sql(prof_amt.currency_code, g_curr_rec.base_currency,
    -- End fix bug #6014218-31-May-07 gnramasa -return null when credit limits value is null instead of -2
         --     sysdate, cm_opt.default_exchange_rate_type, prof_amt.overall_credit_limit)))
              sysdate, l_conversion_type, prof_amt.overall_credit_limit)))
      INTO l_credit_limit
      FROM hz_customer_profiles prof, hz_cust_profile_amts prof_amt
        --   ar_cmgt_setup_options cm_opt
     WHERE prof.party_id = p_party_id
       AND prof.site_use_id IS NULL
       AND prof.status = 'A'
       AND prof.cust_account_profile_id = prof_amt.cust_account_profile_id
       AND prof_amt.cust_account_id = prof.cust_account_id
       --Begin-fix bug#4610424-JYPARK-09/16/2005-exclude credir limit for account
       AND prof.cust_account_id = -1
       --End-fix bug#4610424-JYPARK-09/16/2005-exclude credir limit for account
       AND prof_amt.site_use_id IS NULL;

  ELSIF p_cust_account_id IS NOT NULL THEN
    -- Begin fix bug #6014218-31-May-07 gnramasa -return null when credit limits value is null instead of -2
    --SELECT SUM(gl_currency_api.convert_amount_sql(prof_amt.currency_code, g_curr_rec.base_currency,
    SELECT SUM(DECODE(prof_amt.overall_credit_limit, NULL, NULL, gl_currency_api.convert_amount_sql(prof_amt.currency_code, g_curr_rec.base_currency,
    -- End fix bug #6014218-31-May-07 gnramasa -return null when credit limits value is null instead of -2
          --    sysdate, cm_opt.default_exchange_rate_type, prof_amt.overall_credit_limit)))
                sysdate, l_conversion_type, prof_amt.overall_credit_limit)))
      INTO l_credit_limit
      FROM hz_customer_profiles prof, hz_cust_profile_amts prof_amt
        --   ar_cmgt_setup_options cm_opt
     WHERE prof.cust_account_id = p_cust_account_id
       AND prof.site_use_id IS NULL
       AND prof.status = 'A'
       AND prof.cust_account_profile_id = prof_amt.cust_account_profile_id
       AND prof_amt.cust_account_id = p_cust_account_id
       AND prof_amt.site_use_id IS NULL;
  ELSIF p_customer_site_use_id IS NOT NULL THEN
    -- Begin fix bug #6014218-31-May-07 gnramasa -return null when credit limits value is null instead of -2
    --SELECT SUM(gl_currency_api.convert_amount_sql(prof_amt.currency_code, g_curr_rec.base_currency,
    SELECT SUM(DECODE(prof_amt.overall_credit_limit, NULL, NULL, gl_currency_api.convert_amount_sql(prof_amt.currency_code, g_curr_rec.base_currency,
    -- End fix bug #6014218-31-May-07 gnramasa -return null when credit limits value is null instead of -2
           --   sysdate, cm_opt.default_exchange_rate_type, prof_amt.overall_credit_limit)))
	    sysdate, l_conversion_type, prof_amt.overall_credit_limit)))
      INTO l_credit_limit
      FROM hz_customer_profiles prof, hz_cust_profile_amts prof_amt
      --     ar_cmgt_setup_options cm_opt
     WHERE prof.site_use_id = p_customer_site_use_id
       AND prof.status = 'A'
       AND prof.cust_account_profile_id = prof_amt.cust_account_profile_id
       AND prof_amt.site_use_id = p_customer_site_use_id;
  END IF;
   -- End for the bug#8630157 by PNAVEENK
  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  -- RETURN (TO_CHAR(nvl(l_credit_limit,0), fnd_currency.get_format_mask(g_curr_rec.base_currency, 50)));
  --l_num_val := nvl(l_credit_limit,0);
  l_num_val := l_credit_limit;
  l_char_val := RTRIM(TO_CHAR(l_num_val, fnd_currency.get_format_mask(g_curr_rec.base_currency, 50)));
  RETURN l_char_val;
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable

EXCEPTION
  WHEN NO_DATA_FOUND THEN RETURN(0);

END GET_CREDIT_LIMIT;

FUNCTION GET_HIGH_CREDIT_YTD(p_party_id IN NUMBER,
                   p_cust_account_id IN NUMBER,
                   p_customer_site_use_id IN NUMBER) RETURN VARCHAR2 AS
  l_high_credit_ytd NUMBER;
  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  l_num_val NUMBER;
  l_char_val VARCHAR2(1000);
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  -- Start for the bug#8630157 by PNAVEENK
   l_conversion_type VARCHAR(30);
BEGIN
  l_conversion_type := NVL(FND_PROFILE.VALUE('IEX_EXCHANGE_RATE_TYPE'), 'Corporate');
  IF p_party_id IS NOT NULL THEN
    SELECT MAX(gl_currency_api.convert_amount_sql(trx_summ.currency, g_curr_rec.base_currency,
           --   sysdate, cm_opt.default_exchange_rate_type, trx_summ.op_bal_high_watermark))
             sysdate, l_conversion_type , trx_summ.op_bal_high_watermark))
     INTO l_high_credit_ytd
     FROM ar_trx_summary trx_summ,ar_system_parameters asp,--Added for Bug 9404646 09-Mar-2010 barathsr
      --    ar_cmgt_setup_options cm_opt,
          hz_cust_accounts ca
    WHERE trx_summ.org_id=asp.org_id--Added for Bug 9404646 09-Mar-2010 barathsr
      AND trx_summ.cust_account_id = ca.cust_account_id
      AND ca.party_id = p_party_id;
  ELSIF p_cust_account_id IS NOT NULL THEN
    SELECT MAX(gl_currency_api.convert_amount_sql(trx_summ.currency, g_curr_rec.base_currency,
         --     sysdate, cm_opt.default_exchange_rate_type, trx_summ.op_bal_high_watermark))
                sysdate, l_conversion_type , trx_summ.op_bal_high_watermark))
     INTO l_high_credit_ytd
     FROM ar_trx_summary trx_summ,ar_system_parameters asp--Added for Bug 9404646 09-Mar-2010 barathsr
       --   ar_cmgt_setup_options cm_opt
    WHERE trx_summ.org_id=asp.org_id--Added for Bug 9404646 09-Mar-2010 barathsr
      AND trx_summ.cust_account_id = p_cust_account_id;
  ELSIF p_customer_site_use_id IS NOT NULL THEN
    SELECT MAX(gl_currency_api.convert_amount_sql(trx_summ.currency, g_curr_rec.base_currency,
          --    sysdate, cm_opt.default_exchange_rate_type, trx_summ.op_bal_high_watermark))
               sysdate, l_conversion_type , trx_summ.op_bal_high_watermark))
     INTO l_high_credit_ytd
     FROM ar_trx_summary trx_summ,ar_system_parameters asp--Added for Bug 9404646 09-Mar-2010 barathsr
     --     ar_cmgt_setup_options cm_opt
    WHERE trx_summ.org_id=asp.org_id--Added for Bug 9404646 09-Mar-2010 barathsr
      AND trx_summ.site_use_id = p_customer_site_use_id;
  END IF;
   -- End for the bug#8630157 by PNAVEENK
  --BEGIN-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable
  --RETURN TO_CHAR(nvl(l_high_credit_ytd,0), fnd_currency.get_format_mask(g_curr_rec.base_currency, 50));
  l_num_val := nvl(l_high_credit_ytd,0);
  l_char_val := RTRIM(TO_CHAR(l_num_val, fnd_currency.get_format_mask(g_curr_rec.base_currency, 50)));
  RETURN l_char_val;
  --END-FIX Bug#5247669-08/02/2006-jypark- simplified by using an intermediate varchar variable

EXCEPTION
  WHEN NO_DATA_FOUND THEN RETURN(0);

END GET_HIGH_CREDIT_YTD;

BEGIN
--Begin bug#5208170 schekuri 29-May-2006
--Commented out these as the same values are getting populated in IEX_METRIC_PVT.GET_METRIC_INFO
  /*SELECT sob.currency_code,
         c.precision,
         c.minimum_accountable_unit
    INTO   g_curr_rec.base_currency,
           g_curr_rec.base_precision,
           g_curr_rec.base_min_acc_unit
    FROM   ar_system_parameters   sysp,
           gl_sets_of_books     sob,
           fnd_currencies     c
   WHERE  sob.set_of_books_id = sysp.set_of_books_id
     AND    sob.currency_code   = c.currency_code;

  -- Past Year From and To
  SELECT  TRUNC(add_months(sysdate, - 12)) pastYearFrom ,
          TRUNC(sysdate) pastYearTo
    INTO  g_curr_rec.past_year_from,
          g_curr_rec.past_year_to
    FROM  dual;*/
    NULL;
  --End bug#5208170 schekuri 29-May-2006
EXCEPTION
WHEN OTHERS THEN
  NULL;

END;

/
