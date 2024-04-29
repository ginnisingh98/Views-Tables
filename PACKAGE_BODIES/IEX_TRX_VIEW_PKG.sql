--------------------------------------------------------
--  DDL for Package Body IEX_TRX_VIEW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_TRX_VIEW_PKG" AS
/* $Header: iexttvwb.pls 120.9 2006/02/27 21:46:13 jypark ship $ */

PG_DEBUG NUMBER(2);


FUNCTION is_paid(p_payment_schedule_id NUMBER) RETURN NUMBER
IS
    --Begin - schekuri - Date 13-Apr-2005 - Bug#4113120
    --modified the query to reduce the Disk reads and Query reads
    cursor c_pay IS
    SELECT '1'
    FROM ar_cash_receipts acr,
         ar_receivable_applications ara
    WHERE ara.applied_payment_schedule_id = p_payment_schedule_id
      AND ara.cash_receipt_id = acr.cash_receipt_id
      AND nvl(acr.confirmed_flag, 'Y') = 'Y'
      AND acr.reversal_date is null
      AND EXISTS
      (SELECT '1'
        FROM ar_cash_receipt_history acrh
       WHERE acr.cash_receipt_id = acrh.cash_receipt_id
         AND ACRH.STATUS NOT IN (DECODE (ACRH.FACTOR_FLAG, 'Y', 'RISK_ELIMINATED', 'N', ' '), 'REVERSED')
         AND ACRH.CURRENT_RECORD_FLAG = 'Y');
  /*cursor c_pay IS
    SELECT '1'
    FROM ar_cash_receipts acr,
         ar_receivable_applications ara,
         ar_cash_receipt_history acrh
    WHERE ara.applied_payment_schedule_id = p_payment_schedule_id
    AND ara.cash_receipt_id = acr.cash_receipt_id
    AND acr.cash_receipt_id = acrh.cash_receipt_id
    AND nvl(acr.confirmed_flag, 'Y') = 'Y'
    AND acr.reversal_date is null
    AND acrh.status not in (decode (acrh.factor_flag, 'Y', 'RISK_ELIMINATED',
                                                      'N', ' '), 'REVERSED')
    AND acrh.current_record_flag = 'Y';*/

  --End - schekuri - Date 13-Apr-2005 - Bug#4113120

  l_dummy VARCHAR(1);
  l_status NUMBER;
BEGIN
  open c_pay;
  fetch c_pay into l_dummy;
  if c_pay%found then
    l_status := 1;
  else
    l_status := 0;
  END if;
  close c_pay;

  RETURN l_status;
END;
FUNCTION is_promised(p_delinquency_id NUMBER) RETURN NUMBER
IS
  cursor c_pro IS
    select '1'
    from iex_promISe_details
    where delinquency_id = p_delinquency_id
    and status = 'COLLECTABLE';
  l_dummy VARCHAR(1);
  l_status NUMBER;
BEGIN
  open c_pro;
  fetch c_pro into l_dummy;
  if c_pro%found then
    l_status := 1;
  else
    l_status := 0;
  END if;
  close c_pro;

  RETURN l_status;
END;
FUNCTION get_sales_order(p_customer_trx_id NUMBER) RETURN VARCHAR2
IS
  cursor c_so IS
    select sales_order
	from ra_customer_trx_lines
	where customer_trx_id = p_customer_trx_id
        -- Begin fix bug #5012865-JYPARK-02/01/2006-getting line type to get sales_order
        and line_type = 'LINE'
        -- End fix bug #5012865-JYPARK-02/01/2006-getting line type to get sales_order
	and line_NUMBER = 1;
  l_sales_order VARCHAR2(50);
BEGIN
  open c_so;
  fetch c_so into l_sales_order;
  close c_so;
  RETURN l_sales_order;
END;

FUNCTION get_score(p_payment_schedule_id NUMBER) RETURN NUMBER
IS
  CURSOR c_score IS
      SELECT a.score_value
      FROM iex_score_histories a
      WHERE a.creation_date =
            (SELECT MAX(creation_date)
             FROM iex_Score_histories
             WHERE score_object_code = 'IEX_INVOICES'
             AND score_object_id = p_payment_schedule_id)
      AND a.score_object_code = 'IEX_INVOICES'
      AND a.score_object_id = p_payment_schedule_id;
  l_score NUMBER;
BEGIN
  OPEN c_score;
  FETCH c_score INTO l_score;
  CLOSE c_score;
  RETURN l_score;
END get_score;
FUNCTION get_strategy_name(p_delinquency_id NUMBER) RETURN VARCHAR2
IS
  CURSOR c_str IS
    SELECT str.strategy_id, str.strategy_template_id, str_temp.strategy_name
    FROM iex_strategies str, iex_strategy_templates_vl str_temp
    WHERE str.delinquency_id = p_delinquency_id
    AND str.strategy_template_id = str_temp.strategy_temp_id
    AND str_temp.category_type = 'DELINQUENT';
  l_strategy_row c_str%rowtype;
BEGIN
  OPEN c_str;
  FETCH c_str INTO l_strategy_row;
  CLOSE c_str;
  return l_strategy_row.strategy_name;
END get_strategy_name;


-- clchang added 11/11/2002 for IEX_DUNNINGS_ACCT_BALI_V
FUNCTION get_party_id(p_account_id NUMBER) RETURN NUMBER
IS
  cursor c_party (IN_ID number) is
     select del.party_cust_id
       --from iex_delinquencies_all del
       from iex_delinquencies del
      where del.cust_account_id = in_id;
  l_party number;
BEGIN
  IF PG_DEBUG < 10  THEN
     iex_debug_pub.LogMessage ('IEXTTVWB:get_party_id');
  END IF;
  IF PG_DEBUG < 10  THEN
     iex_debug_pub.LogMessage ('get_party_id: ' || 'IEXTTVWB:account_id='||p_account_id);
  END IF;
  open c_party(p_account_id);
  fetch c_party into l_party;
  if c_party%found then
    IF PG_DEBUG < 10  THEN
       iex_debug_pub.LogMessage ('get_party_id: ' || 'IEXTTVWB:party='||l_party);
    END IF;
  else
    IF PG_DEBUG < 10  THEN
       iex_debug_pub.LogMessage ('get_party_id: ' || 'IEXTTVWB:notfound');
    END IF;
    l_party := 0;
  END if;
  close c_party;

  RETURN l_party;

END get_party_id;

PROCEDURE post_query_trx(p_trx_tab IN OUT NOCOPY postQueryTabType, p_type IN VARCHAR2)
IS
  --Begin - schekuri - Date 13-Apr-2005 - Bug#4113120
  --modified the query to reduce the Disk reads and Query reads
  cursor c_pay(p_payment_schedule_id NUMBER) IS
    SELECT '1'
    FROM ar_cash_receipts acr,
         ar_receivable_applications ara
    WHERE ara.applied_payment_schedule_id = p_payment_schedule_id
      AND ara.cash_receipt_id = acr.cash_receipt_id
      AND nvl(acr.confirmed_flag, 'Y') = 'Y'
      AND acr.reversal_date is null
-- Begin-fix bug #4572737-JYPARK-08/30/2005-exclude unapplied receipt
      AND ara.display = 'Y'
-- End-fix bug #4572737-JYPARK-08/30/2005-exclude unapplied receipt
      AND EXISTS
      (SELECT '1'
        FROM ar_cash_receipt_history acrh
       WHERE acr.cash_receipt_id = acrh.cash_receipt_id
         AND ACRH.STATUS NOT IN (DECODE (ACRH.FACTOR_FLAG, 'Y', 'RISK_ELIMINATED', 'N', ' '), 'REVERSED')
         AND ACRH.CURRENT_RECORD_FLAG = 'Y');

  /*cursor c_pay(p_payment_schedule_id NUMBER) IS
    SELECT '1'
    FROM ar_cash_receipts acr,
         ar_receivable_applications ara,
         ar_cash_receipt_history acrh
    WHERE ara.applied_payment_schedule_id = p_payment_schedule_id
    AND ara.cash_receipt_id = acr.cash_receipt_id
    AND acr.cash_receipt_id = acrh.cash_receipt_id
    AND nvl(acr.confirmed_flag, 'Y') = 'Y'
    AND acr.reversal_date is null
    AND acrh.status not in (decode (acrh.factor_flag, 'Y', 'RISK_ELIMINATED',
                                                      'N', ' '), 'REVERSED')
    AND acrh.current_record_flag = 'Y';*/

  --End - schekuri - Date 13-Apr-2005 - Bug#4113120

  cursor c_pro(p_delinquency_id NUMBER) IS
    select '1'
    from iex_promise_details
    where delinquency_id = p_delinquency_id
    and status = 'COLLECTABLE';

  cursor c_so(p_customer_trx_id NUMBER) IS
    select sales_order
	from ra_customer_trx_lines
	where customer_trx_id = p_customer_trx_id
        -- Begin fix bug #5012865-JYPARK-02/01/2006-getting line type to get sales_order
        and line_type = 'LINE'
        -- End fix bug #5012865-JYPARK-02/01/2006-getting line type to get sales_order
	and line_NUMBER = 1;

  CURSOR c_str(p_delinquency_id NUMBER) IS
    SELECT str_temp.strategy_name
    FROM iex_strategies str, iex_strategy_templates_vl str_temp
    WHERE str.delinquency_id = p_delinquency_id
    AND str.strategy_template_id = str_temp.strategy_temp_id
    AND str_temp.category_type = 'DELINQUENT'
    AND str.status_code IN ('OPEN', 'ONHOLD');

  CURSOR c_score(p_payment_schedule_id NUMBER) IS
      SELECT a.score_value
      FROM iex_score_histories a
      WHERE a.creation_date =
            (SELECT MAX(creation_date)
             FROM iex_Score_histories
             WHERE score_object_code = 'IEX_INVOICES'
             AND score_object_id = p_payment_schedule_id)
      AND a.score_object_code = 'IEX_INVOICES'
      AND a.score_object_id = p_payment_schedule_id;

  l_dummy VARCHAR(1);
  l_status NUMBER;
BEGIN
  FOR i IN p_trx_tab.first..p_trx_tab.last LOOP
    open c_pay(p_trx_tab(i).payment_schedule_id);
    fetch c_pay into l_dummy;
    if c_pay%found then
      -- p_trx_tab(i).paid_flag := 'jtfgtrue.gif';
      p_trx_tab(i).paid_flag := ARPT_SQL_FUNC_UTIL.get_lookup_meaning('YES/NO', 'Y');
    else
      -- p_trx_tab(i).paid_flag := 'jtfgnull.gif';
      p_trx_tab(i).paid_flag := '';
    END if;
    close c_pay;

    open c_pro(p_trx_tab(i).delinquency_id);
    fetch c_pro into l_dummy;
    if c_pro%found then
      -- p_trx_tab(i).promised_flag := 'jtfgtrue.gif';
      p_trx_tab(i).promised_flag :=  ARPT_SQL_FUNC_UTIL.get_lookup_meaning('YES/NO', 'Y');
    else
      -- p_trx_tab(i).promised_flag := 'jtfgnull.gif';
      p_trx_tab(i).promised_flag := '';
    END if;
    close c_pro;

    open c_so(p_trx_tab(i).customer_trx_id);
    fetch c_so into p_trx_tab(i).sales_order;
    close c_so;

    OPEN c_score(p_trx_tab(i).payment_schedule_id);
    FETCH c_score INTO p_trx_tab(i).trx_score;
    CLOSE c_score;
  END LOOP;

END post_query_trx;
BEGIN
  PG_DEBUG := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
END;

/
