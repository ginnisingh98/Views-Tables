--------------------------------------------------------
--  DDL for Package Body IEX_UWQ_VIEW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_UWQ_VIEW_PKG" AS
/* $Header: iextuvwb.pls 120.5.12010000.6 2010/02/16 11:05:14 pnaveenk ship $ */
  PG_DEBUG NUMBER(2);
  g_user_id NUMBER;
  g_person_id NUMBER;
  g_resource_id NUMBER;

  CURSOR c_get_emp(x_userid NUMBER) is
    SELECT e.employee_id
    FROM per_employees_current_x e, fnd_user u
    WHERE e.employee_id = u.employee_id
    AND u.user_id = nvl(x_userid, -1);

  CURSOR c_get_resource_id(x_person_id Number, x_userid NUMBER, p_category varchar2) IS
    SELECT res.resource_id
    FROM   jtf_rs_resource_extns res
    WHERE  res.source_id = nvl(x_person_id, -1)
    AND    res.user_id =  nvl(x_userid, -1)
    AND    trunc(res.START_DATE_ACTIVE) <= trunc(SYSDATE)
    AND    trunc(SYSDATE) <= trunc(NVL(RES.END_DATE_ACTIVE,SYSDATE))
    AND    res.category = p_category;

FUNCTION get_del_count(p_party_id NUMBER, p_cust_account_id NUMBER, p_site_use_id NUMBER, p_uwq_status VARCHAR2) RETURN NUMBER
IS
  TYPE refCur IS REF CURSOR;
  c_del_cnt refCur;
  l_del_clause VARCHAR2(1000);
  l_del_cnt NUMBER := 0;
  l_object_id NUMBER;
  c_bnkrpt_cnt refCur;
  l_bnkrpt_clause VARCHAR2(1000);
  l_bnkrpt_cnt NUMBER := 0;
  l_enable_bkr_filter VARCHAR2(40);
  l_Complete_Days varchar2(40);

BEGIN
  l_enable_bkr_filter := NVL(FND_PROFILE.VALUE('IEX_BANKRUPTCY_FILTER'), 'Y');
  l_Complete_Days  := NVL(FND_PROFILE.VALUE('IEX_UWQ_COMPLETION_DAYS'), 30);

  IF p_party_id > 0 THEN
    l_del_clause := 'SELECT COUNT(1) FROM iex_delinquencies WHERE party_cust_id = :party_id ' ||
--BEGIN-FIX Bug#4408860-06/06/2005-jypark-exclude CLOSE status
--                    ' AND status <> ''CURRENT'' ';
                    ' AND status NOT IN (''CURRENT'', ''CLOSE'') ';
--END-FIX Bug#4408860-06/06/2005-jypark-exclude CLOSE status
    l_bnkrpt_clause := 'SELECT COUNT(1) FROM iex_bankruptcies bnkrpt WHERE bnkrpt.party_id = :party_id';
    l_object_id := p_party_id;
  ELSIF p_cust_account_id > 0 THEN
    l_del_clause := 'SELECT COUNT(1) FROM iex_delinquencies WHERE cust_account_id = :cust_account_id ' ||
--BEGIN-FIX Bug#4408860-06/06/2005-jypark-exclude CLOSE status
--                    ' AND status <> ''CURRENT'' ';
                    ' AND status NOT IN (''CURRENT'', ''CLOSE'') ';
--END-FIX Bug#4408860-06/06/2005-jypark-exclude CLOSE status
    l_bnkrpt_clause := 'SELECT COUNT(1) FROM iex_bankruptcies bnkrpt, hz_cust_accounts acc ' ||
                       ' WHERE bnkrpt.party_id = acc.party_id AND acc.cust_account_id = :cust_account_id';
    l_object_id := p_cust_account_id;
  ELSIF p_site_use_id > 0 THEN
    l_del_clause := 'SELECT COUNT(1) FROM iex_delinquencies WHERE customer_site_use_id = :site_use_id ' ||
--BEGIN-FIX Bug#4408860-06/06/2005-jypark-exclude CLOSE status
--                    ' AND status <> ''CURRENT'' ';
                    ' AND status NOT IN (''CURRENT'', ''CLOSE'') ';
--END-FIX Bug#4408860-06/06/2005-jypark-exclude CLOSE status
    l_bnkrpt_clause := 'SELECT COUNT(1) FROM iex_bankruptcies bnkrpt,hz_cust_site_uses site_use, hz_cust_acct_sites acct_site, hz_cust_accounts acc ' ||
                       ' WHERE bnkrpt.party_id = acc.party_id ' ||
                       ' AND acct_site.cust_account_id = acc.cust_account_id ' ||
                       ' AND site_use.cust_acct_site_id = acct_site.cust_acct_site_id ' ||
                       ' AND site_use.site_use_id = :site_use_id';

    l_object_id := p_site_use_id;
  END IF;

  IF l_enable_bkr_filter = 'Y' THEN
    OPEN c_bnkrpt_cnt FOR l_bnkrpt_clause USING l_object_id;
    FETCH c_bnkrpt_cnt INTO l_bnkrpt_cnt;
    CLOSE c_bnkrpt_cnt;

    IF l_bnkrpt_cnt > 0 THEN
      return 0;
    END IF;
  END IF;

  IF p_uwq_status = 'ACTIVE' THEN
    l_del_clause := l_del_clause ||
        ' AND (UWQ_STATUS IS NULL or  UWQ_STATUS = ''ACTIVE'' or ' ||
        ' (trunc(UWQ_ACTIVE_DATE) <= trunc(SYSDATE) and UWQ_STATUS = ''PENDING'' ) )';
  ELSIF p_uwq_status = 'PENDING' THEN
    l_del_clause := l_del_clause ||
        ' AND (UWQ_STATUS = ''PENDING'' and (trunc(UWQ_ACTIVE_DATE) > trunc(SYSDATE)) )';
  ELSIF p_uwq_status = 'COMPLETE' THEN
    l_del_clause := l_del_clause ||
        ' AND (UWQ_STATUS = ''COMPLETE'' and (trunc(UWQ_COMPLETE_DATE) + :complete_days >  trunc(SYSDATE)) )';
  END IF;


  IF p_uwq_status = 'COMPLETE' THEN
     OPEN c_del_cnt FOR l_del_clause USING l_object_id, l_complete_days;
     FETCH c_del_cnt INTO l_del_cnt;
     CLOSE c_del_cnt;
  ELSE
     OPEN c_del_cnt FOR l_del_clause USING l_object_id;
     FETCH c_del_cnt INTO l_del_cnt;
     CLOSE c_del_cnt;
  END IF;

  RETURN l_del_cnt;

EXCEPTION
  WHEN OTHERS THEN
    return -1;
END get_del_count;

--Start bug 6634879 gnramasa 20th Nov 07
FUNCTION get_pro_count(p_party_id NUMBER, p_cust_account_id NUMBER, p_site_use_id NUMBER, p_uwq_status VARCHAR2, p_org_id NUMBER) RETURN NUMBER
IS
  TYPE refCur IS REF CURSOR;
  c_pro_cnt refCur;
  l_pro_clause VARCHAR2(2000);
  l_pro_cnt NUMBER := 0;
  l_object_id NUMBER;
  c_bnkrpt_cnt refCur;
  l_bnkrpt_clause VARCHAR2(1000);
  l_bnkrpt_cnt NUMBER := 0;
  l_enable_bkr_filter VARCHAR2(40);
  l_Complete_Days varchar2(40);
BEGIN
  l_enable_bkr_filter := NVL(FND_PROFILE.VALUE('IEX_BANKRUPTCY_FILTER'), 'Y');
  l_Complete_Days := NVL(FND_PROFILE.VALUE('IEX_UWQ_COMPLETION_DAYS'), 30);

  IF p_party_id > 0 THEN
    l_pro_clause := 'SELECT COUNT(1) ' ||
                    'FROM (' ||
                    '       SELECT pro.promise_detail_id, pro.uwq_status, pro.uwq_active_date, pro.uwq_complete_date' ||
                    '       FROM iex_promise_details pro, hz_cust_accounts ca, iex_delinquencies_all del ' ||
                    '       WHERE ca.cust_account_id = pro.cust_account_id ' ||
                    '       AND pro.state = ''BROKEN_PROMISE'' ' ||
                    '       AND pro.status IN (''COLLECTABLE'', ''PENDING'') ' ||
                    '       AND pro.amount_due_remaining > 0 ' || -- added by jypark 01/02/2003
--BEGIN-FIX Bug#4349915-06/06/2005-jypark-include leasing promise and remove current resource dependency
--                    '       AND pro.resource_id = :resource_id ' ||
--END-FIX Bug#4349915-06/06/2005-jypark-include leasing promise and remove current resource dependency
                    '       AND pro.delinquency_id = del.delinquency_id '||
--BEGIN-FIX Bug#4408860-06/06/2005-jypark-exclude CLOSE status
--                    '       AND del.status <> ''CURRENT'' ' ||
                    '       AND (del.status NOT IN (''CURRENT'', ''CLOSE'') ' ||
--END-FIX Bug#4408860-06/06/2005-jypark-exclude CLOSE status
                    '       OR (del.status=''CURRENT'' and  del.source_program_name=''IEX_CURR_INV'')) ' || --Added for bug 6446848 06-Jan-2009 barathsr
                    '       AND ca.party_id =  :party_id ' ||
		    '       AND del.org_id =  :org_id ' ||
                    '       UNION ALL ' ||
                    '       SELECT pro.promise_detail_id, pro.uwq_status, pro.uwq_active_date, pro.uwq_complete_date' ||
                    '       FROM iex_promise_details pro, hz_cust_accounts ca ' ||
                    '       WHERE ca.cust_account_id = pro.cust_account_id ' ||
                    '       AND pro.state = ''BROKEN_PROMISE'' ' ||
                    '       AND pro.status IN (''COLLECTABLE'', ''PENDING'') ' ||
                    '       AND pro.amount_due_remaining > 0 ' || -- added by jypark 01/02/2003
--BEGIN-FIX Bug#4349915-06/06/2005-jypark-include leasing promise and remove current resource dependency
--                    '       AND pro.resource_id = :resource_id ' ||
--END-FIX Bug#4349915-06/06/2005-jypark-include leasing promise and remove current resource dependency
                    '       AND pro.delinquency_id is null ' ||
                    '       AND ca.party_id = :party_id ' ||
                    ')';
    l_bnkrpt_clause := 'SELECT COUNT(1) FROM iex_bankruptcies bnkrpt WHERE bnkrpt.party_id = :party_id ';
    l_bnkrpt_clause := l_bnkrpt_clause || ' and NVL(bnkrpt.DISPOSITION_CODE,''GRANTED'') in (''GRANTED'',''NEGOTIATION'') ';
    l_object_id := p_party_id;
  ELSIF p_cust_account_id > 0 THEN
    l_pro_clause := 'SELECT COUNT(1) ' ||
                    'FROM (' ||
                    '       SELECT pro.promise_detail_id, pro.uwq_status, pro.uwq_active_date, pro.uwq_complete_date' ||
                    '       FROM iex_promise_details pro, iex_delinquencies_all del ' ||
                    '       WHERE pro.delinquency_id = del.delinquency_id ' ||
                    '       AND pro.state = ''BROKEN_PROMISE'' ' ||
                    '       AND pro.status IN (''COLLECTABLE'', ''PENDING'') ' ||
                    '       AND pro.amount_due_remaining > 0 ' || -- added by jypark 01/02/2003
--BEGIN-FIX Bug#4349915-06/06/2005-jypark-include leasing promise and remove current resource dependency
--                    '       AND pro.resource_id = :resource_id ' ||
--END-FIX Bug#4349915-06/06/2005-jypark-include leasing promise and remove current resource dependency
                    '       AND pro.cust_account_id = :cust_account_id ' ||
--BEGIN-FIX Bug#4408860-06/06/2005-jypark-exclude CLOSE status
--                    '       AND del.status <> ''CURRENT'' ' ||
                    '       AND (del.status NOT IN (''CURRENT'', ''CLOSE'') ' ||
		    '       OR (del.status=''CURRENT'' and  del.source_program_name=''IEX_CURR_INV'')) ' || --Added for bug 6446848 06-Jan-2009 barathsr
		    '       AND del.org_id =  :org_id ' ||
--END-FIX Bug#4408860-06/06/2005-jypark-exclude CLOSE status
                    '       UNION ALL ' ||
                    '       SELECT pro.promise_detail_id, pro.uwq_status, pro.uwq_active_date, pro.uwq_complete_date' ||
                    '       FROM iex_promise_details pro' ||
                    '       WHERE pro.state = ''BROKEN_PROMISE'' ' ||
                    '       AND pro.status IN (''COLLECTABLE'', ''PENDING'') ' ||
                    '       AND pro.amount_due_remaining > 0 ' || -- added by jypark 01/02/2003
--BEGIN-FIX Bug#4349915-06/06/2005-jypark-include leasing promise and remove current resource dependency
--                    '       AND pro.resource_id = :resource_id ' ||
--END-FIX Bug#4349915-06/06/2005-jypark-include leasing promise and remove current resource dependency
                    '       AND pro.cust_account_id = :cust_account_id ' ||
                    '       AND pro.delinquency_id is null ' ||
                    ')';
    l_bnkrpt_clause := 'SELECT COUNT(1) FROM iex_bankruptcies bnkrpt, hz_cust_accounts acc ' ||
                       ' WHERE bnkrpt.party_id = acc.party_id AND acc.cust_account_id = :cust_account_id';
    l_bnkrpt_clause := l_bnkrpt_clause || ' and NVL(bnkrpt.DISPOSITION_CODE,''GRANTED'') in (''GRANTED'',''NEGOTIATION'') ';
    l_object_id := p_cust_account_id;
  ELSIF p_site_use_id > 0 THEN
    l_pro_clause := 'SELECT COUNT(1) ' ||
                    'FROM (' ||
                    '       SELECT pro.promise_detail_id, pro.uwq_status, pro.uwq_active_date, pro.uwq_complete_date' ||
                    '       FROM iex_promise_details pro, iex_delinquencies_all del ' ||
                    '       WHERE pro.state = ''BROKEN_PROMISE'' ' ||
                    '       AND pro.status IN (''COLLECTABLE'', ''PENDING'') ' ||
                    '       AND pro.amount_due_remaining > 0 ' || -- added by jypark 01/02/2003
--BEGIN-FIX Bug#4349915-06/06/2005-jypark-include leasing promise and remove current resource dependency
--                    '       AND pro.resource_id =:resource_id ' ||
--END-FIX Bug#4349915-06/06/2005-jypark-include leasing promise and remove current resource dependency
                    '       AND pro.delinquency_id = del.delinquency_id '||
--BEGIN-FIX Bug#4408860-06/06/2005-jypark-exclude CLOSE status
--                    '       AND del.status <> ''CURRENT'' ' ||
                    '       AND (del.status NOT IN (''CURRENT'', ''CLOSE'') ' ||
--END-FIX Bug#4408860-06/06/2005-jypark-exclude CLOSE status
                    '       OR (del.status=''CURRENT'' and  del.source_program_name=''IEX_CURR_INV'')) ' || --Added for bug 6446848 06-Jan-2009 barathsr
                    '       AND del.customer_site_use_id = :site_use_id ' ||
		    '       AND del.org_id =  :org_id ' ||
--BEGIN-FIX Bug#4349915-06/06/2005-jypark-include leasing promise
                    '       UNION ALL ' ||
                    '       SELECT pro.promise_detail_id, pro.uwq_status, pro.uwq_active_date, pro.uwq_complete_date' ||
                    '       FROM iex_promise_details pro, okc_k_headers_b okch ' ||
                    '       WHERE pro.state = ''BROKEN_PROMISE'' ' ||
                    '       AND pro.status IN (''COLLECTABLE'', ''PENDING'') ' ||
                    '       AND pro.amount_due_remaining > 0 ' || -- added by jypark 01/02/2003
                    '       AND pro.contract_id = okch.id ' ||
                    '       AND okch.bill_to_site_use_id = :site_use_id ' ||
--END-FIX Bug#4349915-06/06/2005-jypark-include leasing promise
                    ')';
    l_bnkrpt_clause := 'SELECT COUNT(1) FROM iex_bankruptcies bnkrpt,hz_cust_site_uses site_use, hz_cust_acct_sites acct_site, hz_cust_accounts acc ' ||
                       ' WHERE bnkrpt.party_id = acc.party_id ' ||
                       ' AND acct_site.cust_account_id = acc.cust_account_id ' ||
                       ' AND site_use.cust_acct_site_id = acct_site.cust_acct_site_id ' ||
                       ' AND site_use.site_use_id = :site_use_id';
    l_bnkrpt_clause := l_bnkrpt_clause || ' and NVL(bnkrpt.DISPOSITION_CODE,''GRANTED'') in (''GRANTED'',''NEGOTIATION'') ';
    l_object_id := p_site_use_id;
  END IF;

  IF l_enable_bkr_filter = 'Y' THEN
    OPEN c_bnkrpt_cnt FOR l_bnkrpt_clause USING l_object_id;
    FETCH c_bnkrpt_cnt INTO l_bnkrpt_cnt;
    CLOSE c_bnkrpt_cnt;

    IF l_bnkrpt_cnt > 0 THEN
      return 0;
    END IF;
  END IF;

  IF p_uwq_status = 'ACTIVE' THEN
    l_pro_clause := l_pro_clause ||
        ' WHERE (uwq_status IS NULL or  uwq_status = ''ACTIVE'' or ' ||
        ' (trunc(uwq_active_date) <= trunc(SYSDATE) and uwq_status = ''PENDING'' ) )';
  ELSIF p_uwq_status = 'PENDING' THEN
    l_pro_clause := l_pro_clause ||
        ' WHERE (uwq_status = ''PENDING'' and (trunc(uwq_active_date) > trunc(SYSDATE)) )';
  ELSIF p_uwq_status = 'COMPLETE' THEN
    l_pro_clause := l_pro_clause ||
        ' WHERE (uwq_status = ''COMPLETE'' and (trunc(uwq_complete_date) + :complete_days > trunc(SYSDATE)) )';
  END IF;

  IF p_site_use_id >0 THEN
    IF p_uwq_status = 'COMPLETE' THEN
--BEGIN-FIX Bug#4349915-06/06/2005-jypark-include leasing promise and remove current resource dependency
--      OPEN c_pro_cnt FOR l_pro_clause USING g_resource_id, l_object_id, l_complete_days;
      OPEN c_pro_cnt FOR l_pro_clause USING l_object_id, l_object_id, l_complete_days;
--END-FIX Bug#4349915-06/06/2005-jypark-include leasing promise and remove current resource dependency
      FETCH c_pro_cnt INTO l_pro_cnt;
      CLOSE c_pro_cnt;
    ELSE
--BEGIN-FIX Bug#4349915-06/06/2005-jypark-include leasing promise and remove current resource dependency
--      OPEN c_pro_cnt FOR l_pro_clause USING g_resource_id, l_object_id;
      OPEN c_pro_cnt FOR l_pro_clause USING l_object_id, p_org_id, l_object_id;
--END-FIX Bug#4349915-06/06/2005-jypark-include leasing promise and remove current resource dependency
      FETCH c_pro_cnt INTO l_pro_cnt;
      CLOSE c_pro_cnt;
    END IF;
  ELSE
    IF p_uwq_status = 'COMPLETE' THEN
--BEGIN-FIX Bug#4349915-06/06/2005-jypark-include leasing promise and remove current resource dependency
--      OPEN c_pro_cnt FOR l_pro_clause USING g_resource_id, l_object_id, g_resource_id, l_object_id, l_complete_days;
      OPEN c_pro_cnt FOR l_pro_clause USING l_object_id, l_object_id, l_complete_days;
--END-FIX Bug#4349915-06/06/2005-jypark-include leasing promise and remove current resource dependency
      FETCH c_pro_cnt INTO l_pro_cnt;
      CLOSE c_pro_cnt;
    ELSE
--BEGIN-FIX Bug#4349915-06/06/2005-jypark-include leasing promise and remove current resource dependency
--      OPEN c_pro_cnt FOR l_pro_clause USING g_resource_id, l_object_id, g_resource_id, l_object_id;
      OPEN c_pro_cnt FOR l_pro_clause USING l_object_id, p_org_id, l_object_id;
--END-FIX Bug#4349915-06/06/2005-jypark-include leasing promise and remove current resource dependency
      FETCH c_pro_cnt INTO l_pro_cnt;
      CLOSE c_pro_cnt;
    END IF;
  END IF;


  RETURN l_pro_cnt;

EXCEPTION
  WHEN OTHERS THEN
    return -1;
END get_pro_count;
--End bug 6634879 gnramasa 20th Nov 07

FUNCTION get_str_count(p_party_id NUMBER, p_cust_account_id NUMBER, p_site_use_id NUMBER, p_uwq_status VARCHAR2) RETURN NUMBER
IS
  TYPE refCur IS REF CURSOR;
  c_str_cnt refCur;
  l_str_clause VARCHAR2(1000);
  l_str_cnt NUMBER := 0;

  l_object_id NUMBER;
  c_bnkrpt_cnt refCur;
  l_bnkrpt_clause VARCHAR2(1000);
  l_bnkrpt_cnt NUMBER := 0;
  l_Complete_Days varchar2(40);
  l_enable_bkr_filter VARCHAR2(40);
BEGIN
  l_enable_bkr_filter := NVL(FND_PROFILE.VALUE('IEX_BANKRUPTCY_FILTER'), 'Y');
  l_Complete_Days := NVL(FND_PROFILE.VALUE('IEX_UWQ_COMPLETION_DAYS'), 30);

  IF p_party_id > 0 THEN
    l_str_clause := 'SELECT COUNT(1) FROM iex_strategy_work_items wtm, iex_strategies str ' ||
                    'WHERE wtm.strategy_id = str.strategy_id ' ||
                    'AND wtm.resource_id = :resource_id ' ||
                    'AND str.status_code in (''OPEN'', ''ONHOLD'') ' ||
                    'AND wtm.status_code in (''OPEN'', ''ONHOLD'') ' ||
                    'AND str.jtf_object_type = ''PARTY'' ' ||
                    'AND str.jtf_object_id = :party_id ';
    l_bnkrpt_clause := 'SELECT COUNT(1) FROM iex_bankruptcies bnkrpt WHERE bnkrpt.party_id = :party_id';
    l_object_id := p_party_id;
  ELSIF p_cust_account_id > 0 THEN
    l_str_clause := 'SELECT COUNT(1) FROM iex_strategy_work_items wtm, iex_strategies str ' ||
                    'WHERE wtm.strategy_id = str.strategy_id ' ||
                    'AND wtm.resource_id = :resource_id ' ||
                    'AND str.status_code in (''OPEN'', ''ONHOLD'') ' ||
                    'AND wtm.status_code in (''OPEN'', ''ONHOLD'') ' ||
                    'AND str.jtf_object_type = ''IEX_ACCOUNT'' ' ||
                    'AND str.jtf_object_id = :cust_account_id ';
    l_bnkrpt_clause := 'SELECT COUNT(1) FROM iex_bankruptcies bnkrpt, hz_cust_accounts acc ' ||
                       ' WHERE bnkrpt.party_id = acc.party_id AND acc.cust_account_id = :cust_account_id';
    l_object_id := p_cust_account_id;
  ELSIF p_site_use_id > 0 THEN
    l_str_clause := 'SELECT COUNT(1) FROM iex_strategy_work_items wtm, iex_strategies str ' ||
                    'WHERE wtm.strategy_id = str.strategy_id ' ||
                    'AND wtm.resource_id = :resource_id '||
                    'AND str.status_code in (''OPEN'', ''ONHOLD'') ' ||
                    'AND wtm.status_code in (''OPEN'', ''ONHOLD'') ' ||
                    'AND str.jtf_object_type = ''IEX_BILLTO'' ' ||
                    'AND str.jtf_object_id = :site_use_id ';
    l_bnkrpt_clause := 'SELECT COUNT(1) FROM iex_bankruptcies bnkrpt,hz_cust_site_uses site_use, hz_cust_acct_sites acct_site, hz_cust_accounts acc ' ||
                       ' WHERE bnkrpt.party_id = acc.party_id ' ||
                       ' AND acct_site.cust_account_id = acc.cust_account_id ' ||
                       ' AND site_use.cust_acct_site_id = acct_site.cust_acct_site_id ' ||
                       ' AND site_use.site_use_id = :site_use_id';

    l_object_id := p_site_use_id;
  END IF;

  IF l_enable_bkr_filter = 'Y' THEN
    OPEN c_bnkrpt_cnt FOR l_bnkrpt_clause USING l_object_id;
    FETCH c_bnkrpt_cnt INTO l_bnkrpt_cnt;
    CLOSE c_bnkrpt_cnt;

    IF l_bnkrpt_cnt > 0 THEN
      return 0;
    END IF;
  END IF;

  IF p_uwq_status = 'ACTIVE' THEN
    l_str_clause := l_str_clause ||
        ' AND (UWQ_STATUS IS NULL or  UWQ_STATUS = ''ACTIVE'' or ' ||
        ' (trunc(UWQ_ACTIVE_DATE) <= trunc(SYSDATE) and UWQ_STATUS = ''PENDING'' ) )';
  ELSIF p_uwq_status = 'PENDING' THEN
    l_str_clause := l_str_clause ||
        ' AND (UWQ_STATUS = ''PENDING'' and (trunc(UWQ_ACTIVE_DATE) > trunc(SYSDATE)) )';
  ELSIF p_uwq_status = 'COMPLETE' THEN
    l_str_clause := l_str_clause ||
        ' AND (UWQ_STATUS = ''COMPLETE'' and (trunc(UWQ_COMPLETE_DATE) + :complete_days >  trunc(SYSDATE)) )';
  END IF;

  IF p_uwq_status = 'COMPLETE' THEN
     OPEN c_str_cnt FOR l_str_clause USING g_resource_id, l_object_id, l_complete_days;
     FETCH c_str_cnt INTO l_str_cnt;
     CLOSE c_str_cnt;
  ELSE
     OPEN c_str_cnt FOR l_str_clause USING g_resource_id, l_object_id;
     FETCH c_str_cnt INTO l_str_cnt;
     CLOSE c_str_cnt;
  END IF;

  RETURN l_str_cnt;

EXCEPTION
  WHEN OTHERS THEN
    return -1;
END get_str_count;

FUNCTION convert_amount(p_from_amount NUMBER, p_from_currency VARCHAR2) RETURN NUMBER
IS
  l_set_of_books_id NUMBER;
  l_conversion_type VARCHAR(30);
  l_to_amount NUMBER;

  CURSOR c_sob IS
    SELECT set_of_books_id
    FROM ar_system_parameters;
  -- Start for the bug#8630157 by PNAVEENK
/*  CURSOR c_rate_type IS
    SELECT default_exchange_rate_type
    FROM ar_cmgt_setup_options; */

BEGIN
  OPEN c_sob;
  FETCH c_sob INTO l_set_of_books_id;
  CLOSE c_sob;

 /* OPEN c_rate_type;
  FETCH c_rate_type INTO l_conversion_type;
  CLOSE c_rate_type; */
  l_conversion_type := NVL(FND_PROFILE.VALUE('IEX_EXCHANGE_RATE_TYPE'), 'Corporate');
  l_to_amount := gl_currency_api.convert_amount(x_set_of_books_id => l_set_of_books_id,
                    x_from_currency => p_from_currency,
                    x_conversion_date => sysdate,
                    x_conversion_type => l_conversion_type,
                    x_amount => p_from_amount);
  return l_to_amount;
EXCEPTION
  WHEN OTHERS THEN
    return -1;
END convert_amount;

FUNCTION get_last_payment_amount(p_party_id NUMBER, p_cust_account_id NUMBER, p_site_use_id NUMBER) RETURN NUMBER
IS
  TYPE refCur IS REF CURSOR;
  c_amt refCur;
  l_amt_clause VARCHAR2(1000);
  l_amount NUMBER;
  l_currency VARCHAR2(15);
  l_object_id NUMBER;
BEGIN
  IF p_party_id > 0 THEN

    l_amt_clause := ' SELECT o_summ.last_payment_amount, o_summ.currency ' ||
                    ' FROM ar_trx_bal_summary o_summ, hz_cust_accounts acc' ||
                    ' WHERE o_summ.cust_account_id = acc.cust_account_id' ||
                    ' AND acc.party_id = :party_id ' ||
                    ' AND last_payment_date = ' || ' (SELECT MAX(last_payment_date) ' ||
                                                   '  FROM ar_trx_bal_summary ' ||
                                                   '  WHERE cust_account_id = o_summ.cust_account_id) ';

    l_object_id := p_party_id;
  ELSIF p_cust_account_id > 0 THEN
    l_amt_clause := ' SELECT o_summ.last_payment_amount, o_summ.currency ' ||
                    ' FROM ar_trx_bal_summary o_summ' ||
                    ' WHERE o_summ.cust_account_id = :cust_account_id ' ||
                    ' AND o_summ.last_payment_date = ' || ' (SELECT MAX(last_payment_date) ' ||
                                                   '  FROM ar_trx_bal_summary ' ||
                                                   '  WHERE cust_account_id = o_summ.cust_account_id) ';
    l_object_id := p_cust_account_id;
  ELSIF p_site_use_id > 0 THEN
    l_amt_clause := ' SELECT o_summ.last_payment_amount, o_summ.currency ' ||
                    ' FROM ar_trx_bal_summary o_summ' ||
                    ' WHERE o_summ.site_use_id = :site_use_id ' ||
                    ' AND o_summ.last_payment_date = ' || ' (SELECT MAX(last_payment_date) ' ||
                                                   '  FROM ar_trx_bal_summary ' ||
                                                   '  WHERE site_use_id = o_summ.site_use_id) ';
    l_object_id := p_site_use_id;
  END IF;

  OPEN c_amt FOR l_amt_clause USING l_object_id;
  FETCH c_amt INTO l_amount, l_currency;
  CLOSE c_amt;

  IF l_amount IS NOT NULL THEN
    l_amount := iex_uwq_view_pkg.convert_amount(l_amount, l_currency);
  END IF;

  return l_amount;
--EXCEPTION
  --WHEN OTHERS THEN
    --return l_amount;
END get_last_payment_amount;

FUNCTION get_last_payment_number(p_party_id NUMBER, p_cust_account_id NUMBER, p_site_use_id NUMBER) RETURN VARCHAR2
IS
  TYPE refCur IS REF CURSOR;
  c_no refCur;
  l_no_clause VARCHAR2(1000);
  l_number VARCHAR2(30);
  l_currency VARCHAR2(15);
  l_object_id NUMBER;
BEGIN
  IF p_party_id > 0 THEN

    l_no_clause := ' SELECT o_summ.last_payment_number ' ||
                    ' FROM ar_trx_bal_summary o_summ, hz_cust_accounts acc' ||
                    ' WHERE o_summ.cust_account_id = acc.cust_account_id' ||
                    ' AND acc.party_id = :party_id ' ||
                    ' AND last_payment_date = ' || ' (SELECT MAX(last_payment_date) ' ||
                                                   '  FROM ar_trx_bal_summary ' ||
                                                   '  WHERE cust_account_id = o_summ.cust_account_id) ';

    l_object_id := p_party_id;
  ELSIF p_cust_account_id > 0 THEN
    l_no_clause := ' SELECT o_summ.last_payment_number ' ||
                    ' FROM ar_trx_bal_summary o_summ' ||
                    ' WHERE o_summ.cust_account_id = :cust_account_id ' ||
                    ' AND o_summ.last_payment_date = ' || ' (SELECT MAX(last_payment_date) ' ||
                                                   '  FROM ar_trx_bal_summary ' ||
                                                   '  WHERE cust_account_id = o_summ.cust_account_id) ';
    l_object_id := p_cust_account_id;
  ELSIF p_site_use_id > 0 THEN
    l_no_clause := ' SELECT o_summ.last_payment_number ' ||
                    ' FROM ar_trx_bal_summary o_summ' ||
                    ' WHERE o_summ.site_use_id = :site_use_id ' ||
                    ' AND o_summ.last_payment_date = ' || ' (SELECT MAX(last_payment_date) ' ||
                                                   '  FROM ar_trx_bal_summary ' ||
                                                   '  WHERE site_use_id = o_summ.site_use_id) ';
    l_object_id := p_site_use_id;
  END IF;

  OPEN c_no FOR l_no_clause USING l_object_id;
  FETCH c_no INTO l_number;
  CLOSE c_no;


  return l_number;
--EXCEPTION
  --WHEN OTHERS THEN
    --return l_amount;
END get_last_payment_number;
FUNCTION get_score(p_party_id NUMBER, p_cust_account_id NUMBER, p_site_use_id NUMBER) RETURN NUMBER
IS
  CURSOR c_score(x_score_object_id NUMBER, x_score_object_code VARCHAR2) IS
    SELECT a.score_value
    FROM iex_score_histories a
    WHERE a.creation_date =
     (SELECT MAX(creation_date)
      FROM iex_Score_histories
      WHERE score_object_code = x_score_object_code
      AND score_object_id = x_score_object_id)
    AND a.score_object_code = x_score_object_code
    AND a.score_object_id = x_score_object_id;

  l_score NUMBER;
BEGIN
  IF p_party_id > 0 THEN
    OPEN c_score(p_party_id, 'PARTY');
    FETCH c_score INTO l_score;
    CLOSE c_score;
  ELSIF p_cust_account_id > 0 THEN
    OPEN c_score(p_cust_account_id, 'IEX_ACCOUNT');
    FETCH c_score INTO l_score;
    CLOSE c_score;
  ELSIF p_site_use_id > 0 THEN
    OPEN c_score(p_site_use_id, 'IEX_BILLTO');
    FETCH c_score INTO l_score;
    CLOSE c_score;
  END IF;

  return l_score;

END get_score;

--Start bug 6634879 gnramasa 20th Nov 07
FUNCTION get_broken_prm_amt(p_party_id NUMBER, p_cust_account_id NUMBER, p_site_use_id NUMBER, p_org_id NUMBER) RETURN NUMBER
IS
  CURSOR c_party_amt IS
--BEGIN-FIX Bug#4349915-06/06/2005-jypark-include leasing promise and remove current resource dependency
--    SELECT SUM(amount_due_remaining)
--    FROM iex_promise_details pro, hz_cust_accounts ca, iex_delinquencies del
--    WHERE pro.cust_account_id = ca.cust_account_id
--    AND ca.party_id = p_party_id
--    AND pro.status in ('COLLECTABLE', 'PENDING')
--    AND pro.state = 'BROKEN_PROMISE'
--    AND pro.amount_due_remaining > 0
--    AND pro.resource_id = g_resource_id
--    AND pro.delinquency_id = del.delinquency_id(+)
--    AND del.status(+) <> 'CURRENT';
    SELECT SUM(amount_due_remaining)
    FROM ( SELECT amount_due_remaining
           FROM iex_promise_details pro, iex_delinquencies_all del
           WHERE del.party_cust_id = p_party_id
           AND pro.status in ('COLLECTABLE', 'PENDING')
           AND pro.state = 'BROKEN_PROMISE'
           AND pro.amount_due_remaining > 0
           AND pro.delinquency_id = del.delinquency_id
           AND (del.status IN ('DELINQUENT', 'PREDELINQUENT')
	   or (del.status='CURRENT' and  del.source_program_name='IEX_CURR_INV'))--Added for Bug 6446848 barathsr 06-Jan-2009
	   AND del.org_id = p_org_id
           UNION ALL
           SELECT amount_due_remaining
           FROM iex_promise_details pro, okc_k_headers_b okch, hz_cust_accounts ca
           WHERE ca.cust_account_id = pro.cust_account_id
           AND ca.party_id = p_party_id
           AND pro.status in ('COLLECTABLE', 'PENDING')
           AND pro.state = 'BROKEN_PROMISE'
           AND pro.amount_due_remaining > 0
           AND pro.contract_id = okch.id
          );
--END-FIX Bug#4349915-06/06/2005-jypark-include leasing promise and remove current resource dependency

  CURSOR c_acc_amt IS
    SELECT SUM(amount_due_remaining)
    FROM iex_promise_details pro, iex_delinquencies_all del
    WHERE pro.cust_account_id = p_cust_account_id
    AND pro.status in ('COLLECTABLE', 'PENDING')
    AND pro.state = 'BROKEN_PROMISE'
    AND pro.amount_due_remaining > 0
    AND pro.resource_id = g_resource_id
--BEGIN-FIX Bug#4408860-06/06/2005-jypark-exclude CLOSE status
--    AND pro.delinquency_id = del.delinquency_id(+)
--    AND del.status(+) <> 'CURRENT';
    AND pro.delinquency_id = del.delinquency_id
    AND (del.status IN ('DELINQUENT', 'PREDELINQUENT')
     OR (del.status='CURRENT' and  del.source_program_name='IEX_CURR_INV'))--Added for Bug 6446848 barathsr 06-Jan-2009
    AND del.org_id = p_org_id;
--END-FIX Bug#4408860-06/06/2005-jypark-exclude CLOSE status

  CURSOR c_billto_amt IS
--BEGIN-FIX Bug#4349915-06/06/2005-jypark-include leasing promise and remove current resource dependency
--    SELECT SUM(amount_due_remaining)
--    FROM iex_promise_details pro, iex_delinquencies del
--    WHERE del.customer_site_use_id = p_site_use_id
--    AND pro.status in ('COLLECTABLE', 'PENDING')
--    AND pro.state = 'BROKEN_PROMISE'
--    AND pro.amount_due_remaining > 0
--    AND pro.resource_id = g_resource_id
--    AND pro.delinquency_id = del.delinquency_id
--    AND del.status <> 'CURRENT';
--    AND del.status IN ('DELINQUENT', 'PREDELINQUENT');
    SELECT SUM(amount_due_remaining)
    FROM ( SELECT amount_due_remaining
           FROM iex_promise_details pro, iex_delinquencies_all del
           WHERE del.customer_site_use_id = p_site_use_id
           AND pro.status in ('COLLECTABLE', 'PENDING')
           AND pro.state = 'BROKEN_PROMISE'
           AND pro.amount_due_remaining > 0
           AND pro.delinquency_id = del.delinquency_id
           AND (del.status IN ('DELINQUENT', 'PREDELINQUENT')
           or (del.status='CURRENT' and  del.source_program_name='IEX_CURR_INV'))--Added for Bug 6446848 barathsr 06-Jan-2009
	   AND del.org_id = p_org_id
           UNION ALL
           SELECT amount_due_remaining
           FROM iex_promise_details pro, okc_k_headers_b okch
           WHERE okch.bill_to_site_use_id = p_site_use_id
           AND pro.status in ('COLLECTABLE', 'PENDING')
           AND pro.state = 'BROKEN_PROMISE'
           AND pro.amount_due_remaining > 0
           AND pro.contract_id = okch.id
          );
--END-FIX Bug#4349915-06/06/2005-jypark-include leasing promise and remove current resource dependency

  l_broken_prm_amt NUMBER;
BEGIN
  IF p_party_id > 0 THEN
    OPEN c_party_amt;
    FETCH c_party_amt INTO l_broken_prm_amt;
    CLOSE c_party_amt;
  ELSIF p_cust_account_id > 0 THEN
    OPEN c_acc_amt;
    FETCH c_acc_amt INTO l_broken_prm_amt;
    CLOSE c_acc_amt;
  ELSIF p_site_use_id > 0 THEN
    OPEN c_billto_amt;
    FETCH c_billto_amt INTO l_broken_prm_amt;
    CLOSE c_billto_amt;
  END IF;

  return l_broken_prm_amt;

END get_broken_prm_amt;


FUNCTION get_prm_amt(p_party_id NUMBER, p_cust_account_id NUMBER, p_site_use_id NUMBER, p_org_id NUMBER) RETURN NUMBER
IS
  CURSOR c_party_amt IS
--BEGIN-FIX Bug#4349915-06/06/2005-jypark-include leasing promise and remove current resource dependency
--    SELECT SUM(promise_amount)
--    FROM iex_promise_details pro, hz_cust_accounts ca, iex_delinquencies del
--    WHERE pro.cust_account_id = ca.cust_account_id
--    AND ca.party_id = p_party_id
--    AND pro.status in ('COLLECTABLE', 'PENDING')
--    AND pro.state = 'BROKEN_PROMISE'
--    AND pro.amount_due_remaining > 0
--    AND pro.resource_id = g_resource_id
--    AND pro.delinquency_id = del.delinquency_id(+)
--    AND del.status(+) <> 'CURRENT';
--    AND pro.delinquency_id = del.delinquency_id
--    AND del.status IN ('DELINQUENT', 'PREDELINQUENT');
    SELECT SUM(promise_amount)
    FROM ( SELECT promise_amount
           FROM iex_promise_details pro, iex_delinquencies_all del
           WHERE del.party_cust_id = p_party_id
           AND pro.status in ('COLLECTABLE', 'PENDING')
           AND pro.state = 'BROKEN_PROMISE'
           AND pro.amount_due_remaining > 0
           AND pro.delinquency_id = del.delinquency_id
           AND (del.status IN ('DELINQUENT', 'PREDELINQUENT')
	   or (del.status='CURRENT' and  del.source_program_name='IEX_CURR_INV'))--Added for Bug 6446848 barathsr 06-Jan-2009
	   AND del.org_id = p_org_id
           UNION ALL
           SELECT promise_amount
           FROM iex_promise_details pro, okc_k_headers_b okch, hz_cust_accounts ca
           WHERE ca.party_id = p_party_id
           AND pro.cust_account_id = ca.cust_account_id
           AND pro.status in ('COLLECTABLE', 'PENDING')
           AND pro.state = 'BROKEN_PROMISE'
           AND pro.amount_due_remaining > 0
           AND pro.contract_id = okch.id
   );
--END-FIX Bug#4349915-06/06/2005-jypark-include leasing promise and remove current resource dependency

  CURSOR c_acc_amt IS
    SELECT SUM(promise_amount)
    FROM iex_promise_details pro, iex_delinquencies_all del
    WHERE pro.cust_account_id = p_cust_account_id
    AND pro.amount_due_remaining > 0
    AND pro.status in ('COLLECTABLE', 'PENDING')
    AND pro.state = 'BROKEN_PROMISE'
    AND pro.resource_id = g_resource_id
--BEGIN-FIX Bug#4408860-06/06/2005-jypark-exclude CLOSE status
--    AND pro.delinquency_id = del.delinquency_id(+)
--    AND del.status(+) <> 'CURRENT';
    AND pro.delinquency_id = del.delinquency_id
    AND (del.status IN ('DELINQUENT', 'PREDELINQUENT')
    or (del.status='CURRENT' and  del.source_program_name='IEX_CURR_INV'))--Added for Bug 6446848 barathsr 06-Jan-2009
    AND del.org_id = p_org_id;
--END-FIX Bug#4408860-06/06/2005-jypark-exclude CLOSE status

  CURSOR c_billto_amt IS
--BEGIN-FIX Bug#4349915-06/06/2005-jypark-include leasing promise and remove current resource dependency
--    SELECT SUM(promise_amount)
--    FROM iex_promise_details pro, iex_delinquencies del
--    WHERE del.customer_site_use_id = p_site_use_id
--    AND pro.amount_due_remaining > 0
--    AND pro.status in ('COLLECTABLE', 'PENDING')
--    AND pro.state = 'BROKEN_PROMISE'
--    AND pro.resource_id = g_resource_id
--    AND pro.delinquency_id = del.delinquency_id
--    AND del.status <> 'CURRENT';
    SELECT SUM(promise_amount)
    FROM ( SELECT promise_amount
           FROM iex_promise_details pro, iex_delinquencies_all del
           WHERE del.customer_site_use_id = p_site_use_id
           AND pro.status in ('COLLECTABLE', 'PENDING')
           AND pro.state = 'BROKEN_PROMISE'
           AND pro.amount_due_remaining > 0
           AND pro.delinquency_id = del.delinquency_id
           AND (del.status IN ('DELINQUENT', 'PREDELINQUENT')
	   or (del.status='CURRENT' and  del.source_program_name='IEX_CURR_INV'))--Added for Bug 6446848 barathsr 06-Jan-2009
	   AND del.org_id = p_org_id
           UNION ALL
           SELECT promise_amount
           FROM iex_promise_details pro, okc_k_headers_b okch
           WHERE okch.bill_to_site_use_id = p_site_use_id
           AND pro.status in ('COLLECTABLE', 'PENDING')
           AND pro.state = 'BROKEN_PROMISE'
           AND pro.amount_due_remaining > 0
           AND pro.contract_id = okch.id
   );
--END-FIX Bug#4349915-06/06/2005-jypark-include leasing promise and remove current resource dependency

  l_prm_amt NUMBER;
BEGIN
  IF p_party_id > 0 THEN
    OPEN c_party_amt;
    FETCH c_party_amt INTO l_prm_amt;
    CLOSE c_party_amt;
  ELSIF p_cust_account_id > 0 THEN
    OPEN c_acc_amt;
    FETCH c_acc_amt INTO l_prm_amt;
    CLOSE c_acc_amt;
  ELSIF p_site_use_id > 0 THEN
    OPEN c_billto_amt;
    FETCH c_billto_amt INTO l_prm_amt;
    CLOSE c_billto_amt;
  END IF;

  return l_prm_amt;

END get_prm_amt;
--End bug 6634879 gnramasa 20th Nov 07

FUNCTION get_contract_count(p_party_id NUMBER, p_cust_account_id NUMBER, p_site_use_id NUMBER, p_uwq_status VARCHAR2) RETURN NUMBER
IS
  TYPE refCur IS REF CURSOR;
  c_contract_cnt refCur;
  l_contract_clause VARCHAR2(1000);
  l_contract_cnt NUMBER := 0;
  l_Complete_Days varchar2(40);
  l_lease_enabled VARCHAR2(40);
BEGIN
--BEGIN-FIX Bug#4408860-06/06/2005-jypark-obsolete function because we're not showing this field in UWQ
--  l_Complete_Days  := NVL(FND_PROFILE.VALUE('IEX_UWQ_COMPLETION_DAYS'), 30);
--  l_lease_enabled  := NVL(FND_PROFILE.VALUE('IEX_LEASE_ENABLED'), 'N');
--
--  IF l_lease_enabled = 'N' THEN
--    return 0;
--  END IF;
--
--  IF p_site_use_id > 0 AND p_party_id > 0 THEN
--    l_contract_clause := 'SELECT COUNT(object_id) ' ||
--                    ' FROM iex_cases_all_b icas, iex_case_objects icobj, ' ||
--                    '      iex_case_definitions icdef, iex_delinquencies idel ' ||
--                    ' WHERE icas.cas_id  = icobj.cas_id ' ||
--                    ' AND icas.party_id = :party_id ' ||
--                    ' AND icdef.column_name = ''BILL_TO_ADDRESS_ID'' ' ||
--                    ' AND icdef.column_value = :customer_site_use_id ' ||
--                    ' AND icdef.cas_id = icas.cas_id '||
--                    ' AND idel.case_id = icas.cas_id '||
--                    ' AND idel.status <> ''CURRENT'' ';
--  ELSIF p_cust_account_id > 0 AND p_party_id > 0 THEN
--    l_contract_clause := 'SELECT COUNT(object_id) ' ||
--                    ' FROM iex_cases_all_b icas, iex_case_objects icobj, ' ||
--                    '      iex_case_definitions icdef, iex_delinquencies idel ' ||
--                    ' WHERE icas.cas_id  = icobj.cas_id ' ||
--                    ' AND icas.party_id = :party_id ' ||
--                    ' AND icdef.column_name = ''CUSTOMER_ACCOUNT'' ' ||
--                    ' AND icdef.column_value = :cust_account_id ' ||
--                    ' AND icdef.cas_id = icas.cas_id ' ||
--                    ' AND idel.case_id = icas.cas_id ' ||
--                    ' AND idel.status <> ''CURRENT'' ';
--  ELSIF p_party_id > 0 THEN
--    l_contract_clause := 'SELECT COUNT(object_id) ' ||
--                    ' FROM iex_cases_all_b icas, iex_case_objects icobj, iex_delinquencies idel ' ||
--                    ' WHERE  icas.cas_id  = icobj.cas_id  ' ||
--                    ' AND icas.party_id = :party_id ' ||
--                    ' AND idel.case_id = icas.cas_id ' ||
--                    ' AND idel.status <> ''CURRENT'' ';
--  END IF;
--
--  IF p_uwq_status = 'ACTIVE' THEN
--    l_contract_clause := l_contract_clause ||
--        ' AND (UWQ_STATUS IS NULL or  UWQ_STATUS = ''ACTIVE'' or ' ||
--        ' (trunc(UWQ_ACTIVE_DATE) <= trunc(SYSDATE) and UWQ_STATUS = ''PENDING'' ) )';
--  ELSIF p_uwq_status = 'PENDING' THEN
--    l_contract_clause := l_contract_clause ||
--        ' AND (UWQ_STATUS = ''PENDING'' and (trunc(UWQ_ACTIVE_DATE) > trunc(SYSDATE)) )';
--  ELSIF p_uwq_status = 'COMPLETE' THEN
--    l_contract_clause := l_contract_clause ||
--        ' AND (UWQ_STATUS = ''COMPLETE'' and (trunc(UWQ_COMPLETE_DATE) + :complete_days >  trunc(SYSDATE)) )';
--  END IF;
--
--
--  IF p_uwq_status = 'COMPLETE' THEN
--    IF p_site_use_id > 0 AND p_party_id > 0 THEN
--      OPEN c_contract_cnt FOR l_contract_clause USING p_party_id, p_site_use_id, l_complete_days;
--      FETCH c_contract_cnt INTO l_contract_cnt;
--      CLOSE c_contract_cnt;
--    ELSIF p_cust_account_id > 0 AND p_party_id > 0 THEN
--      OPEN c_contract_cnt FOR l_contract_clause USING p_party_id, p_cust_account_id, l_complete_days;
--      FETCH c_contract_cnt INTO l_contract_cnt;
--      CLOSE c_contract_cnt;
--    ELSIF p_party_id > 0 THEN
--      OPEN c_contract_cnt FOR l_contract_clause USING p_party_id, l_complete_days;
--      FETCH c_contract_cnt INTO l_contract_cnt;
--      CLOSE c_contract_cnt;
--    END IF;
--  ELSE
--    IF p_site_use_id > 0 AND p_party_id > 0 THEN
--      OPEN c_contract_cnt FOR l_contract_clause USING p_party_id, p_site_use_id;
--      FETCH c_contract_cnt INTO l_contract_cnt;
--      CLOSE c_contract_cnt;
--    ELSIF p_cust_account_id > 0 AND p_party_id > 0 THEN
--      OPEN c_contract_cnt FOR l_contract_clause USING p_party_id, p_cust_account_id;
--      FETCH c_contract_cnt INTO l_contract_cnt;
--      CLOSE c_contract_cnt;
--    ELSIF p_party_id > 0 THEN
--      OPEN c_contract_cnt FOR l_contract_clause USING p_party_id;
--      FETCH c_contract_cnt INTO l_contract_cnt;
--      CLOSE c_contract_cnt;
--    END IF;
--  END IF;
--End-FIX Bug#4408860-06/06/2005-jypark-obsolete function because we're not showing this field in UWQ

  RETURN l_contract_cnt;

EXCEPTION
  WHEN OTHERS THEN
    return 0;
END get_contract_count;

FUNCTION get_case_count(p_party_id NUMBER, p_cust_account_id NUMBER, p_site_use_id NUMBER, p_uwq_status VARCHAR2) RETURN NUMBER
IS
  TYPE refCur IS REF CURSOR;
  c_case_cnt refCur;
  l_case_clause VARCHAR2(1000);
  l_case_cnt NUMBER := 0;
  l_Complete_Days varchar2(40);
  l_lease_enabled VARCHAR2(40);
BEGIN
--Begin-FIX Bug#4408860-06/06/2005-jypark-obsolete function because we're not showing this field in UWQ
--  l_Complete_Days  := NVL(FND_PROFILE.VALUE('IEX_UWQ_COMPLETION_DAYS'), 30);
--  l_lease_enabled  := NVL(FND_PROFILE.VALUE('IEX_LEASE_ENABLED'), 'N');
--
--  IF l_lease_enabled = 'N' THEN
--    return 0;
--  END IF;
--
--  IF p_site_use_id > 0 AND p_party_id > 0 THEN
--    l_case_clause := 'SELECT COUNT(1) ' ||
--                    ' FROM iex_cases_all_b icas, ' ||
--                    '      iex_case_definitions icdef, iex_delinquencies idel ' ||
--                    ' WHERE icas.party_id = :party_id ' ||
--                    ' AND icdef.column_name = ''BILL_TO_ADDRESS_ID'' ' ||
--                    ' AND icdef.column_value = :customer_site_use_id ' ||
--                    ' AND icdef.cas_id = icas.cas_id '||
--                    ' AND idel.case_id = icas.cas_id '||
--                    ' AND idel.status <> ''CURRENT'' ';
--  ELSIF p_cust_account_id > 0 AND p_party_id > 0 THEN
--    l_case_clause := 'SELECT COUNT(1) ' ||
--                    ' FROM iex_cases_all_b icas, ' ||
--                    '      iex_case_definitions icdef, iex_delinquencies idel ' ||
--                    ' WHERE icas.party_id = :party_id ' ||
--                    ' AND icdef.column_name = ''CUSTOMER_ACCOUNT'' ' ||
--                    ' AND icdef.column_value = :cust_account_id ' ||
--                    ' AND icdef.cas_id = icas.cas_id ' ||
--                    ' AND idel.case_id = icas.cas_id ' ||
--                    ' AND idel.status <> ''CURRENT'' ';
--  ELSIF p_party_id > 0 THEN
--    l_case_clause := 'SELECT COUNT(1) ' ||
--                    ' FROM iex_cases_all_b icas, iex_delinquencies idel ' ||
--                    ' WHERE icas.party_id = :party_id ' ||
--                    ' AND idel.case_id = icas.cas_id ' ||
--                    ' AND idel.status <> ''CURRENT'' ';
--  END IF;
--
--  IF p_uwq_status = 'ACTIVE' THEN
--    l_case_clause := l_case_clause ||
--        ' AND (UWQ_STATUS IS NULL or  UWQ_STATUS = ''ACTIVE'' or ' ||
--        ' (trunc(UWQ_ACTIVE_DATE) <= trunc(SYSDATE) and UWQ_STATUS = ''PENDING'' ) )';
--  ELSIF p_uwq_status = 'PENDING' THEN
--    l_case_clause := l_case_clause ||
--        ' AND (UWQ_STATUS = ''PENDING'' and (trunc(UWQ_ACTIVE_DATE) > trunc(SYSDATE)) )';
--  ELSIF p_uwq_status = 'COMPLETE' THEN
--    l_case_clause := l_case_clause ||
--        ' AND (UWQ_STATUS = ''COMPLETE'' and (trunc(UWQ_COMPLETE_DATE) + :complete_days >  trunc(SYSDATE)) )';
--  END IF;
--
--
--  IF p_uwq_status = 'COMPLETE' THEN
--    IF p_site_use_id > 0 AND p_party_id > 0 THEN
--      OPEN c_case_cnt FOR l_case_clause USING p_party_id, p_site_use_id, l_complete_days;
--      FETCH c_case_cnt INTO l_case_cnt;
--      CLOSE c_case_cnt;
--    ELSIF p_cust_account_id > 0 AND p_party_id > 0 THEN
--      OPEN c_case_cnt FOR l_case_clause USING p_party_id, p_cust_account_id, l_complete_days;
--      FETCH c_case_cnt INTO l_case_cnt;
--      CLOSE c_case_cnt;
--    ELSIF p_party_id > 0 THEN
--      OPEN c_case_cnt FOR l_case_clause USING p_party_id, l_complete_days;
--      FETCH c_case_cnt INTO l_case_cnt;
--      CLOSE c_case_cnt;
--    END IF;
--  ELSE
--    IF p_site_use_id > 0 AND p_party_id > 0 THEN
--      OPEN c_case_cnt FOR l_case_clause USING p_party_id, p_site_use_id;
--      FETCH c_case_cnt INTO l_case_cnt;
--      CLOSE c_case_cnt;
--    ELSIF p_cust_account_id > 0 AND p_party_id > 0 THEN
--      OPEN c_case_cnt FOR l_case_clause USING p_party_id, p_cust_account_id;
--      FETCH c_case_cnt INTO l_case_cnt;
--      CLOSE c_case_cnt;
--    ELSIF p_party_id > 0 THEN
--      OPEN c_case_cnt FOR l_case_clause USING p_party_id;
--      FETCH c_case_cnt INTO l_case_cnt;
--      CLOSE c_case_cnt;
--    END IF;
--  END IF;
--End-FIX Bug#4408860-06/06/2005-jypark-obsolete function because we're not showing this field in UWQ

  RETURN l_case_cnt;

EXCEPTION
  WHEN OTHERS THEN
    return 0;
END get_case_count;

BEGIN

  PG_DEBUG := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
  g_user_id := TO_NUMBER(NVL(FND_PROFILE.VALUE('USER_ID'), -1));

  OPEN c_get_emp(g_user_id);
  FETCH c_get_emp INTO g_person_id;
  CLOSE c_get_emp;

  OPEN c_get_resource_id(g_person_id, g_user_id,'EMPLOYEE');
  FETCH c_get_resource_id INTO g_resource_id;
  CLOSE c_get_resource_id;

END;

/
