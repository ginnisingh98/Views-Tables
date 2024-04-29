--------------------------------------------------------
--  DDL for Package Body IEX_CUST_OVERVIEW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_CUST_OVERVIEW_PVT" AS
/* $Header: iexvcuob.pls 120.37.12010000.13 2009/09/25 14:42:57 ehuh ship $ */

  G_PKG_NAME    CONSTANT VARCHAR2(30) := 'IEX_CUST_OVERVIEW_PVT';
  G_FILE_NAME   CONSTANT VARCHAR2(12) := 'iexvcuob.pls';
  G_APPL_ID              NUMBER;
  G_LOGIN_ID             NUMBER;
  G_PROGRAM_ID           NUMBER;
  G_USER_ID              NUMBER;
  G_REQUEST_ID           NUMBER;

  PG_DEBUG               NUMBER(2);

  PROCEDURE Get_Customer_Info
  (p_api_version      IN  NUMBER := 1.0,
   p_init_msg_list    IN  VARCHAR2,
   p_commit           IN  VARCHAR2,
   p_validation_level IN  NUMBER,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2,
   p_party_id         IN  NUMBER,
   p_object_source    IN  VARCHAR2,
   x_customer_info_rec OUT NOCOPY customer_info_rec_type)
  IS
    l_api_version     CONSTANT   NUMBER :=  1.0;
    l_api_name        CONSTANT   VARCHAR2(30) :=  'Get_Customer_Info';
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32767);

    amount number;
    total  number;
    l_bkr_count number; -- Added for bug#7830847 by PNAVEENK on 27-1-2009
    -- Get Tax Code
    CURSOR c_party_info IS
      SELECT jgzz_fiscal_code
      FROM   hz_parties
      WHERE  party_id = p_party_id;

    -- Collections score
    CURSOR c_collections_score IS
        SELECT a.score_value
        FROM iex_score_histories a
        WHERE a.creation_date =
        (SELECT MAX(creation_date)
       FROM iex_Score_histories
       WHERE score_object_code = 'PARTY'
       AND score_object_id = p_party_id)
     AND a.score_object_code = 'PARTY'
     AND a.score_object_id = p_party_id;

    -- Collectable/Delinquent Invoices
    -- Begin fix bug #4930425-jypark-01/11/2006-remove full table scan
--    CURSOR c_summ_info IS
--      SELECT COUNT(DECODE(ps.class, 'INV', ps.payment_schedule_id, 'DM',  ps.payment_schedule_id, 'CB',  ps.payment_schedule_id, NULL)) cnt_inv,
--             COUNT(DECODE(ps.class, 'INV', DECODE(del.status, 'DELINQUENT', del.delinquency_id, 'PREDELINQUENT', del.delinquency_id, NULL), NULL)) cnt_del
--      FROM   ar_payment_schedules ps,
--             hz_cust_accounts ca,
--             iex_delinquencies del
--      WHERE  ca.party_id = p_party_id
--      AND    ps.customer_id = ca.cust_account_id
--      AND    ps.status = 'OP'
--      AND    del.payment_schedule_id(+) = ps.payment_schedule_id;

    CURSOR c_collectible_trx IS
      SELECT COUNT(ps.payment_schedule_id) cnt_inv
      FROM   ar_payment_schedules ps,
             hz_cust_accounts ca
      WHERE  ca.party_id = p_party_id
      AND    ps.customer_id = ca.cust_account_id
      AND    ps.status = 'OP'
      AND    ps.class IN ('INV', 'DM', 'CB');

    CURSOR c_delinquent_inv IS
      SELECT COUNT(del.delinquency_id) cnt_del
      FROM   ar_payment_schedules ps,
             hz_cust_accounts ca,
             iex_delinquencies del
      WHERE  ca.party_id = p_party_id
      AND    ps.customer_id = ca.cust_account_id
      AND    ps.status = 'OP'
      AND    ps.class = 'INV'
      AND    del.status in ('DELINQUENT', 'PREDELINQUENT')
      AND    del.payment_schedule_id = ps.payment_schedule_id;
    -- End fix bug #4930425-jypark-01/11/2006-remove full table scan

    -- Delinquencies in Past Year
    CURSOR c_delinquencies IS
      SELECT Count(1)
      FROM iex_delinquencies del
      WHERE del.party_cust_id = p_party_id
      AND del.creation_date between sysdate - 365 and sysdate ;

      --  added by jypark for status in header
    CURSOR c_filter IS
      SELECT object_id, select_column, entity_name
      FROM iex_object_filters
      WHERE object_filter_type = 'IEXCUST'
      AND active_flag = 'Y';

    TYPE refCur IS REF CURSOR;
    c_universe refCur;
    l_sql_stmt VARCHAR2(1000);
    l_sql_stmt_lsd VARCHAR2(1000);
    l_status_rule_id  NUMBER;
    l_count NUMBER;
    l_delinquency_status VARCHAR(80);

    CURSOR c_rule IS
    SELECT rl.delinquency_status, rl.priority,
           iex_utilities.get_lookup_meaning('IEX_DELINQUENCY_STATUS', rl.delinquency_status) meaning
    FROM iex_cu_sts_rl_lines rl, iex_cust_status_rules r
    WHERE rl.status_rule_id = l_status_rule_id
    AND r.status_rule_id = rl.status_rule_id
    AND trunc(sysdate) BETWEEN trunc(nvl(r.start_date,sysdate)) AND trunc(nvl(r.end_date,sysdate))
    AND NVL(rl.enabled_flag, 'N') = 'Y'
    ORDER BY rl.priority;
    c_del refCur;

    -- Customer Since added by jypark 09/26/2002
    CURSOR c_customer_since IS
      SELECT MIN(account_established_date)
      FROM hz_cust_accounts
      WHERE account_established_date IS NOT NULL
      AND party_id = p_party_id;

     l_sql_select VARCHAR2(1000);
     l_sql_where VARCHAR2(1000);
     l_sql_cond VARCHAR2(1000);
     l_customer_okl_info_rec	IEX_CUST_OVERVIEW_PVT.Customer_OKL_Info_Rec_Type;
     l_calc_cust_stats VARCHAR2(1);  -- 5874874 gnramasa
  BEGIN
    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':begin');

    l_sql_select  :=  'SELECT count(1) FROM ';
    l_sql_where  := ' WHERE ';
    l_sql_cond  :=  ' = :party_id';

    x_customer_info_rec.party_id := p_party_id;

    OPEN c_party_info;
    FETCH c_party_info INTO x_customer_info_rec.identification_id;
    CLOSE c_party_info;

    if p_object_source = 'AR' then

        -- Begin fix bug #4930425-jypark-01/11/2006-remove full table scan
        --OPEN c_summ_info;
        --FETCH c_summ_info INTO x_customer_info_rec.number_of_invoices,
        --                       x_customer_info_rec.invoices_overdue;
        --CLOSE c_summ_info;
     l_calc_cust_stats := nvl(fnd_profile.value('IEX_CALC_CUST_STATS'), 'A');
      if (l_calc_cust_stats = 'A') then
        OPEN c_collectible_trx;
        FETCH c_collectible_trx INTO x_customer_info_rec.number_of_invoices;
        CLOSE c_collectible_trx;

        OPEN c_delinquent_inv;
        FETCH c_delinquent_inv INTO x_customer_info_rec.invoices_overdue;
        CLOSE c_delinquent_inv;

        -- End fix bug #4930425-jypark-01/11/2006-remove full table scan

    	OPEN c_delinquencies;
    	FETCH c_delinquencies INTO x_customer_info_rec.number_of_delinquencies;
    	CLOSE c_delinquencies;
      end if;
    elsif p_object_source = 'OKL' then

        Get_Customer_OKL_Info(
           p_api_version => p_api_version,
           p_init_msg_list => p_init_msg_list,
           p_commit => p_commit,
           p_validation_level => p_validation_level,
           x_return_status => x_return_status,
           x_msg_count => x_msg_count,
           x_msg_data => x_msg_data,
   	   p_party_id => p_party_id,
   	   x_customer_okl_info_rec => l_customer_okl_info_rec);

	x_customer_info_rec.CASES_OVERDUE := l_customer_okl_info_rec.CASES_OVERDUE;
	x_customer_info_rec.NUMBER_OF_DEL_CASES := l_customer_okl_info_rec.NUMBER_OF_DEL_CASES;
	x_customer_info_rec.NUMBER_OF_OKL_INV := l_customer_okl_info_rec.NUMBER_OF_OKL_INV;

    end if;

    OPEN c_collections_score;
    FETCH c_collections_score INTO x_customer_info_rec.collections_score;
    CLOSE c_collections_score;

    OPEN c_customer_since;
    FETCH c_customer_since INTO x_customer_info_rec.customer_since;
    CLOSE c_customer_since;


    --  added by jypark for status in header

    FOR r_filter in c_filter LOOP
      -- build SQL for universe
      -- for bug 5874874 gnramasa 25-Apr-2007
      l_sql_stmt := 'SELECT 1 FROM dual WHERE EXISTS (SELECT 1 FROM ' || r_filter.entity_name || l_sql_where || r_filter.select_column || l_sql_cond || ')';
      --l_sql_stmt :=  l_sql_select || r_filter.entity_name || l_sql_where || r_filter.select_column || l_sql_cond;

      BEGIN
        OPEN c_universe FOR l_sql_stmt USING p_party_id;
        FETCH c_universe into l_count;

        IF c_universe%FOUND AND l_count > 0 THEN

          l_status_rule_id := r_filter.object_id;
          CLOSE c_universe;

          -- begin added by jypark 01/05/2004 to fix bug #3308753
	  -- begin bug 6723556 gnramasa 10th Jan 2008

          IF l_status_rule_id IS NOT NULL THEN
            FOR r_rule IN c_rule LOOP
              l_delinquency_status := r_rule.delinquency_status;
	      iex_debug_pub.LogMessage('1. l_delinquency_status :' || l_delinquency_status);
              IF l_delinquency_status = 'BANKRUPTCY' THEN
                l_sql_stmt := 'SELECT count(1)' ||
                              '  FROM iex_bankruptcies' ||
                              ' WHERE party_id = :party_id' ||
                              '   AND close_date IS NULL ' ||
                              '   AND NVL(DISPOSITION_CODE, '' '') NOT IN (''DISMISSED'',''WITHDRAWN'' )';
              ELSIF l_delinquency_status = 'DELINQUENT' THEN
                l_sql_stmt := 'SELECT count(1)' ||
                              '  FROM iex_delinquencies' ||
                              ' WHERE party_cust_id = :party_id' ||
                              -- fix bug #4157131 ' AND status not in (''CURRENT'', ''CLOSE'')';
                              ' AND status = ''DELINQUENT''';
              ELSIF l_delinquency_status = 'LITIGATION' THEN
                l_sql_stmt_lsd := ' select count(1) from (' ||
		                  ' SELECT litigation_id' ||
			          '  FROM iex_litigations ltg, iex_delinquencies del' ||
                                  ' WHERE del.party_cust_id = :party_id' ||
                                  '  AND ltg.delinquency_id = del.delinquency_id' ||
                                  '  AND del.status not in (''CURRENT'', ''CLOSE'')' ||
			          '  AND ltg.disposition_code IS NULL ' ||
				  ' UNION ' ||
				  ' SELECT litigation_id ' ||
				  '  FROM iex_litigations ' ||
				  ' WHERE party_id= :party_id ' ||
				  ' AND contract_number IS NOT NULL ' ||
				  ' AND ''DELINQUENT'' = IEX_UTILITIES.CheckContractStatus(contract_number) ' ||
				  '  AND disposition_code IS NULL )';
              ELSIF l_delinquency_status = 'REPOSSESSION' THEN
                l_sql_stmt_lsd := ' select count(1) from (' ||
		                  ' SELECT repossession_id' ||
			          '  FROM iex_repossessions rps, iex_delinquencies del' ||
                                  ' WHERE del.party_cust_id = :party_id' ||
                                  '  AND rps.delinquency_id = del.delinquency_id' ||
                                  '  AND del.status not in (''CURRENT'', ''CLOSE'')' ||
			          '  AND (rps.disposition_code IS NULL or rps.disposition_code = ''A'' or rps.disposition_code = ''W'') ' ||
				  ' UNION ' ||
				  ' SELECT repossession_id ' ||
				  '  FROM iex_repossessions ' ||
				  ' WHERE party_id= :party_id ' ||
				  ' AND contract_number IS NOT NULL ' ||
				  ' AND ''DELINQUENT'' = IEX_UTILITIES.CheckContractStatus(contract_number) ' ||
			          ' AND (disposition_code IS NULL or disposition_code = ''A'' or disposition_code = ''W''))' ;
				  --'  AND disposition_code IS NULL )';
              ELSIF l_delinquency_status = 'WRITEOFF' THEN
                l_sql_stmt_lsd := ' select count(1) from (' ||
		                  ' SELECT writeoff_id' ||
			          '  FROM iex_writeoffs wrf, iex_delinquencies del' ||
                                  ' WHERE del.party_cust_id = :party_id' ||
                                  '  AND wrf.delinquency_id = del.delinquency_id' ||
                                  '  AND del.status not in (''CURRENT'', ''CLOSE'')' ||
			          '  AND (wrf.disposition_code IS NULL or wrf.disposition_code = ''A'' or wrf.disposition_code = ''W'') ' ||
			          --'  AND wrf.disposition_code IS NULL ' ||
				  ' UNION ' ||
				  ' SELECT writeoff_id ' ||
				  '  FROM iex_writeoffs ' ||
				  ' WHERE party_id= :party_id ' ||
				  ' AND contract_number IS NOT NULL ' ||
				  ' AND ''DELINQUENT'' = IEX_UTILITIES.CheckContractStatus(contract_number) ' ||
			          ' AND (disposition_code IS NULL or disposition_code = ''A'' or disposition_code = ''W''))' ;
				  --'  AND disposition_code IS NULL )';
              ELSIF l_delinquency_status = 'PREDELINQUENT' THEN
                l_sql_stmt := 'SELECT count(1)' ||
                              '  FROM iex_delinquencies' ||
                              ' WHERE party_cust_id = :party_id' ||
                              -- fix bug #4157131 ' AND status not in (''CURRENT'', ''CLOSE'')';
                              ' AND status = ''PREDELINQUENT''';
              END IF;

              iex_debug_pub.LogMessage('1. p_party_id :' || p_party_id);
	      IF l_delinquency_status in ('LITIGATION','REPOSSESSION','WRITEOFF') THEN
		iex_debug_pub.LogMessage('1. l_sql_stmt_lsd :' || l_sql_stmt_lsd);
		OPEN c_del FOR l_sql_stmt_lsd USING p_party_id,p_party_id;
	      ELSE
		iex_debug_pub.LogMessage('1. l_sql_stmt :' || l_sql_stmt);
		OPEN c_del FOR l_sql_stmt USING p_party_id;
	      END IF;
	      FETCH c_del INTO l_count;

              IF l_count > 0 THEN
                x_customer_info_rec.status := r_rule.meaning;
                CLOSE c_del;
                EXIT;
              END IF;
              CLOSE c_del;
            END LOOP;
          END IF;

          IF x_customer_info_rec.status IS NOT NULL THEN
            EXIT;
          END IF;
          -- end added by jypark 01/05/2004 to fix bug #3308753

        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          null;
      END ;
    END LOOP;

    IF l_status_rule_id IS NOT NULL THEN
      FOR r_rule IN c_rule LOOP
        l_delinquency_status := r_rule.delinquency_status;
	iex_debug_pub.LogMessage('2. l_delinquency_status :' || l_delinquency_status);
        IF l_delinquency_status = 'BANKRUPTCY' THEN
          l_sql_stmt := 'SELECT count(1)' ||
                        '  FROM iex_bankruptcies' ||
                        ' WHERE party_id = :party_id' ||
                        '   AND close_date IS NULL ' ||
                        '   AND NVL(DISPOSITION_CODE , '' '') NOT IN (''DISMISSED'',''WITHDRAWN'' )';
        ELSIF l_delinquency_status = 'DELINQUENT' THEN
          l_sql_stmt := 'SELECT count(1)' ||
                        '  FROM iex_delinquencies' ||
                        ' WHERE party_cust_id = :party_id' ||
                        -- fix bug #4157131 ' AND status not in (''CURRENT'', ''CLOSE'')';
                        ' AND status = ''DELINQUENT''';
        ELSIF l_delinquency_status = 'LITIGATION' THEN
          l_sql_stmt_lsd :=  'select count(1) from (' ||
		             ' SELECT litigation_id' ||
			     '  FROM iex_litigations ltg, iex_delinquencies del' ||
                             ' WHERE del.party_cust_id = :party_id' ||
                             '  AND ltg.delinquency_id = del.delinquency_id' ||
                             '  AND del.status not in (''CURRENT'', ''CLOSE'')' ||
			     '  AND ltg.disposition_code IS NULL ' ||
			     ' UNION ' ||
			     ' SELECT litigation_id ' ||
			     '  FROM iex_litigations ' ||
			     ' WHERE party_id= :party_id ' ||
			     ' AND contract_number IS NOT NULL ' ||
			     ' AND ''DELINQUENT'' = IEX_UTILITIES.CheckContractStatus(contract_number) ' ||
			     '  AND disposition_code IS NULL )';
        ELSIF l_delinquency_status = 'REPOSSESSION' THEN
          l_sql_stmt_lsd := ' select count(1) from (' ||
		            ' SELECT repossession_id' ||
			    '  FROM iex_repossessions rps, iex_delinquencies del' ||
                            ' WHERE del.party_cust_id = :party_id' ||
                            '  AND rps.delinquency_id = del.delinquency_id' ||
                            '  AND del.status not in (''CURRENT'', ''CLOSE'')' ||
			    '  AND (rps.disposition_code IS NULL or rps.disposition_code = ''A'' or rps.disposition_code = ''W'') ' ||
			    --'  AND rps.disposition_code IS NULL ' ||
			    ' UNION ' ||
			    ' SELECT repossession_id ' ||
			    '  FROM iex_repossessions ' ||
			    ' WHERE party_id= :party_id ' ||
			    ' AND contract_number IS NOT NULL ' ||
			    ' AND ''DELINQUENT'' = IEX_UTILITIES.CheckContractStatus(contract_number) ' ||
			    ' AND (disposition_code IS NULL or disposition_code = ''A'' or disposition_code = ''W''))' ;
			    --'  AND disposition_code IS NULL )';
        ELSIF l_delinquency_status = 'WRITEOFF' THEN
          l_sql_stmt_lsd := ' select count(1) from (' ||
		            ' SELECT writeoff_id' ||
			    '  FROM iex_writeoffs wrf, iex_delinquencies del' ||
                            ' WHERE del.party_cust_id = :party_id' ||
                            '  AND wrf.delinquency_id = del.delinquency_id' ||
                            '  AND del.status not in (''CURRENT'', ''CLOSE'')' ||
			    '  AND (wrf.disposition_code IS NULL or wrf.disposition_code = ''A'' or wrf.disposition_code = ''W'') ' ||
			    --'  AND wrf.disposition_code IS NULL ' ||
			    ' UNION ' ||
			    ' SELECT writeoff_id ' ||
			    '  FROM iex_writeoffs ' ||
			    ' WHERE party_id= :party_id ' ||
			    ' AND contract_number IS NOT NULL ' ||
			    ' AND ''DELINQUENT'' = IEX_UTILITIES.CheckContractStatus(contract_number) ' ||
			    ' AND (disposition_code IS NULL or disposition_code = ''A'' or disposition_code = ''W''))' ;
			    --'  AND disposition_code IS NULL )';
        ELSIF l_delinquency_status = 'PREDELINQUENT' THEN
          l_sql_stmt := 'SELECT count(1)' ||
                        '  FROM iex_delinquencies' ||
                        ' WHERE party_cust_id = :party_id' ||
                        -- fix bug #4157131 ' AND status not in (''CURRENT'', ''CLOSE'')';
                        ' AND status = ''PREDELINQUENT''';
        END IF;

        iex_debug_pub.LogMessage('2. p_party_id :' || p_party_id);
	IF l_delinquency_status in ('LITIGATION','REPOSSESSION','WRITEOFF') THEN
		iex_debug_pub.LogMessage('2. l_sql_stmt_lsd :' || l_sql_stmt_lsd);
		OPEN c_del FOR l_sql_stmt_lsd USING p_party_id,p_party_id;
        ELSE
		iex_debug_pub.LogMessage('2. l_sql_stmt :' || l_sql_stmt);
		OPEN c_del FOR l_sql_stmt USING p_party_id;
        END IF;
	--End bug 6723556 gnramasa 10th Jan 2008
	FETCH c_del INTO l_count;

        IF l_count > 0 THEN
          x_customer_info_rec.status := r_rule.meaning;
          CLOSE c_del;
          EXIT;
        END IF;
        CLOSE c_del;
      END LOOP;
    END IF;
    -- Start for bug#7830847 by PNAVEENK on 27-1-2009
    IF x_customer_info_rec.status IS NULL THEN

                        SELECT count(1) into l_bkr_count
                        FROM iex_bankruptcies
                        WHERE party_id = x_customer_info_rec.party_id
                        AND close_date IS NULL
                        AND NVL(DISPOSITION_CODE, ' ') NOT IN ('DISMISSED','WITHDRAWN' );
      IF l_bkr_count > 0 then
             x_customer_info_rec.status := iex_utilities.get_lookup_meaning('IEX_DELINQUENCY_STATUS', 'BANKRUPTCY');
      ELSE
             x_customer_info_rec.status := iex_utilities.get_lookup_meaning('IEX_CUSTOMER_STATUS_TYPE', 'CURRENT');
      END IF;
    END IF;

    -- End for bug#7830847
    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':end');
  END Get_Customer_Info;

  PROCEDURE Get_Customer_OKL_Info
  (p_api_version      		IN  NUMBER := 1.0,
   p_init_msg_list    		IN  VARCHAR2,
   p_commit           		IN  VARCHAR2,
   p_validation_level 		IN  NUMBER,
   x_return_status    		OUT NOCOPY VARCHAR2,
   x_msg_count        		OUT NOCOPY NUMBER,
   x_msg_data         		OUT NOCOPY VARCHAR2,
   p_party_id         		IN  NUMBER,
   x_customer_okl_info_rec 	OUT NOCOPY customer_okl_info_rec_type)
  IS
    l_api_version     CONSTANT   NUMBER :=  1.0;
    l_api_name        CONSTANT   VARCHAR2(30) :=  'Get_Customer_OKL_Info';
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32767);

-- Begin fix bug #4930425-jypark-01/10/2006-removed obsolete query
--    -- Delinquent Cases
--    CURSOR c_del_cases IS
--      SELECT Count(1)
--      FROM iex_delinquencies del
--      WHERE del.party_cust_id = p_party_id
--      and del.case_id is not null
--      and del.status = 'DELINQUENT';
--
--   -- Collectable OKL Invocies
--    CURSOR c_okl_inv IS
--      SELECT count(CNSLD.CONSOLIDATED_INVOICE_ID)
--      FROM   IEX_BPD_CNSLD_INV_REMAINING_V cnsld, hz_cust_accounts ca
--      WHERE  ca.party_id = p_party_id
--      AND    cnsld.customer_id = ca.cust_account_id
--      AND    cnsld.amount > 0;
--
--    -- Delinquent Cases in Past Year
--    CURSOR c_del_cases_past_year IS
--      SELECT Count(1)
--      FROM iex_delinquencies del
--      WHERE del.party_cust_id = p_party_id
--      AND del.creation_date between sysdate - 365 and sysdate
--      and del.case_id is not null
--      and del.status = 'DELINQUENT';
-- End fix bug #4930425-jypark-01/10/2006-removed obsolete query

  BEGIN
    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':begin');

-- Begin fix bug #4930425-jypark-01/10/2006-removed obsolete query
--    OPEN c_del_cases;
--    FETCH c_del_cases INTO x_customer_okl_info_rec.CASES_OVERDUE;
--    CLOSE c_del_cases;
--
--    OPEN c_okl_inv;
--    FETCH c_okl_inv INTO x_customer_okl_info_rec.NUMBER_OF_OKL_INV;
--    CLOSE c_okl_inv;
--
--    OPEN c_del_cases_past_year;
--    FETCH c_del_cases_past_year INTO x_customer_okl_info_rec.NUMBER_OF_DEL_CASES;
--    CLOSE c_del_cases_past_year;
-- End fix bug #4930425-jypark-01/10/2006-removed obsolete query

    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':end');
  END Get_Customer_OKL_Info;

  PROCEDURE Get_Object_Info
  (p_api_version      IN  NUMBER := 1.0,
   p_init_msg_list    IN  VARCHAR2,
   p_commit           IN  VARCHAR2,
   p_validation_level IN  NUMBER,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2,
   p_object_id        IN  NUMBER,
   p_object_type      IN  VARCHAR2,
   p_object_source    IN  VARCHAR2,
   x_object_info_rec  OUT NOCOPY object_info_rec_type)
  IS
    l_api_version     CONSTANT   NUMBER :=  1.0;
    l_api_name        CONSTANT   VARCHAR2(30) :=  'Get_Object_Info';
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32767);

    l_party_id NUMBER;
    l_cust_account_id NUMBER;
    l_payment_schedule_id NUMBER;
    l_customer_site_use_id NUMBER;

    TYPE c_overdue_cur_type IS REF CURSOR;
    TYPE c_balance_cur_type IS REF CURSOR;
    TYPE c_dso_cur_type IS REF CURSOR;  -- added by jypark 09/05/2002
    TYPE c_summ_info_type IS REF CURSOR;

    c_overdue c_overdue_cur_type;
    c_balance c_balance_cur_type;
    c_dso  c_dso_cur_type;  -- added by jypark 09/05/2002
    c_summ_info c_summ_info_type;

    l_last_pmt_info_rec last_pmt_info_rec_type;
    l_last_okl_pmt_info_rec   Last_OKL_Pmt_Info_Rec_Type;

    CURSOR c_del(x_delinquency_id NUMBER) IS
      SELECT payment_schedule_id
      FROM iex_delinquencies
      WHERE delinquency_id = x_delinquency_id
     AND status not in ('CURRENT', 'CLOSE');

     l_cnt_cur_codes number; --added for MOAC

     l_amount_in_dispute     ra_cm_requests_all.total_amount%type;  --Added for bug 7612000 gnramasa 4th Dec 08

  BEGIN
    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':begin');
    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':p_object_source=' || p_object_source ||
	  ':p_object_type=' || p_object_type || ':p_object_id=' || p_object_id);

    --start moac change
    --to check whether all the ou's has the same functional currency or not
    l_cnt_cur_codes:= iex_currency_pvt.get_currency_count;
    --end moac change

    IF p_object_type = 'CUSTOMER' AND p_object_id IS NOT NULL THEN
      l_party_id := p_object_id;
      l_cust_account_id := null;
      l_payment_schedule_id := null;

      --Start bug 8359894  gnramasa 18th june 09
      if (NVL(FND_PROFILE.VALUE('IEX_SHOW_DSO_IN_HEADER'), 'Y') = 'Y') then
	      OPEN c_summ_info FOR
		SELECT
		     SUM(NVL(ps.acctd_amount_due_remaining,0)) net_balance,
		     SUM(DECODE(del.status, 'DELINQUENT', NVL(acctd_amount_due_remaining,0),
					    'PREDELINQUENT', NVL(acctd_amount_due_remaining,0),0)) overdue_amt,
		     ROUND(
		       ( (SUM( DECODE(NVL(ps.receipt_confirmed_flag,'Y'), 'Y',
				DECODE(PS.CLASS,
				     'INV', 1,
				     'DM',  1,
				     'CB',  1,
				     'DEP', 1,
				     'BR',  1, /* 22-JUL-2000 J Rautiainen BR Implementation */
				      0), 0)
				* PS.ACCTD_AMOUNT_DUE_REMAINING
			      ) * MAX(SP.CER_DSO_DAYS)
			  )
			  / DECODE(
				 SUM( DECODE(NVL(ps.receipt_confirmed_flag,'Y'), 'Y',DECODE(PS.CLASS,
					    'INV', 1,
					    'DM',  1,
					    'DEP', 1,
					     0), 0)
				       * DECODE(SIGN (TRUNC(SYSDATE) - PS.TRX_DATE - SP.CER_DSO_DAYS),
						-1, (PS.AMOUNT_DUE_ORIGINAL  + NVL(PS.AMOUNT_ADJUSTED,0)) * NVL(PS.EXCHANGE_RATE, 1 ),
						 0)) ,
				 0, 1,
				 SUM( DECODE(NVL(ps.receipt_confirmed_flag,'Y'), 'Y', DECODE(PS.CLASS,
					    'INV', 1,
					    'DM',  1,
					    'DEP', 1,
					     0), 0)
				      * DECODE(SIGN (TRUNC(SYSDATE) - PS.TRX_DATE - SP.CER_DSO_DAYS),
					       -1, (PS.AMOUNT_DUE_ORIGINAL  + NVL(PS.AMOUNT_ADJUSTED,0)) * NVL(PS.EXCHANGE_RATE, 1 ),
					       0) )
				  )
			), 0)  dso
	      FROM   ar_payment_schedules ps,
		     hz_cust_accounts ca,
		     -- Begin fix bug #5261855-jypark-06/16/2006-change to based table for performance
		     -- iex_delinquencies del,
		     iex_delinquencies_all del,
		     -- End fix bug #5261855-jypark-06/16/2006-change to based table for performance
		     ar_system_parameters sp
	      WHERE  ca.party_id = l_party_id
	      AND    ps.customer_id = ca.cust_account_id
	      AND    ps.status = 'OP'
	      AND    del.payment_schedule_id(+) = ps.payment_schedule_id
	      and    sp.org_id=ps.org_id; --moac change

	      FETCH c_summ_info INTO x_object_info_rec.current_balance,
				     x_object_info_rec.amount_overdue,
				     x_object_info_rec.dso;
      else
		OPEN c_summ_info FOR
		SELECT
		     SUM(NVL(ps.acctd_amount_due_remaining,0)) net_balance,
		     SUM(DECODE(del.status, 'DELINQUENT', NVL(acctd_amount_due_remaining,0),
					    'PREDELINQUENT', NVL(acctd_amount_due_remaining,0),0)) overdue_amt
	      FROM   ar_payment_schedules ps,
		     hz_cust_accounts ca,
		     iex_delinquencies_all del,
		     ar_system_parameters sp
	      WHERE  ca.party_id = l_party_id
	      AND    ps.customer_id = ca.cust_account_id
	      AND    ps.status = 'OP'
	      AND    del.payment_schedule_id(+) = ps.payment_schedule_id
	      and    sp.org_id=ps.org_id;

	      FETCH c_summ_info INTO x_object_info_rec.current_balance,
				     x_object_info_rec.amount_overdue;
      end if; --if (NVL(FND_PROFILE.VALUE('IEX_SHOW_DSO_IN_HEADER'), 'Y') = 'Y') then

      CLOSE c_summ_info;
      --End bug 8359894  gnramasa 18th june 09

        --Start bug 7612000 gnramasa 4th Dec 08
	-- If value of "IEX: Exclude dispute amount from remaining amount " is Yes
	-- then calculate the Amount thats in dispute and substract it from the amount overdue.
	if (NVL(FND_PROFILE.VALUE('IEX_EXCLUDE_DISPUTE_AMT_FROM_REMAINING_AMT'), 'N') = 'Y') then
		select nvl(sum(cm.total_amount * -1),0)
		into l_amount_in_dispute
		from ra_cm_requests cm
		where cm.customer_trx_id in (select distinct ps.customer_trx_id
		from ar_payment_schedules ps,
		     hz_cust_accounts ca
		where ca.party_id = l_party_id
		and ps.customer_id = ca.cust_account_id
		and ps.status = 'OP')
		and cm.status='PENDING_APPROVAL';

		x_object_info_rec.amount_overdue := x_object_info_rec.amount_overdue - l_amount_in_dispute;
	end if;
	--End bug 7612000 gnramasa 4th Dec 08

      --start moac change
      --if the functional currency codes of the ou's are different
      --make the Amount overdue and Net balance fields as null.
      if l_cnt_cur_codes <>1 then
           x_object_info_rec.current_balance:=null;
           x_object_info_rec.amount_overdue:=null;
      end if;
      --end moac change

    ELSIF p_object_type = 'ACCOUNT' AND p_object_id IS NOT NULL  THEN
      l_party_id := null;
      l_cust_account_id := p_object_id;
      l_payment_schedule_id := null;

      --start moac change
      --if the functional currency codes of the ou's are different
      --make the Amount overdue and Net balance fields as null.
      if l_cnt_cur_codes <> 1 then
           x_object_info_rec.current_balance:=null;
           x_object_info_rec.amount_overdue:=null;
      else
      --end moac change
      OPEN c_overdue FOR
        SELECT sum(acctd_amount_due_remaining) amount
        FROM   ar_payment_schedules ps, iex_delinquencies del
        WHERE ps.customer_id = p_object_id
        -- fix bug #3561828 AND    ps.due_date < sysdate
--BEGIN-FIX BUG#4356388-05/24/2005-JYPARK-amount overdue should inculde Pre-Delinquent transactions which are not past due
--        AND    TRUNC(ps.due_date) < TRUNC(sysdate)
--END-FIX BUG#4356388-05/24/2005-JYPARK-amount overdue should inculde Pre-Delinquent transactions which are not past due
        AND ps.status = 'OP'
        AND del.payment_schedule_id = ps.payment_schedule_id
        AND del.status IN ('DELINQUENT', 'PREDELINQUENT');

      FETCH c_overdue INTO x_object_info_rec.amount_overdue;
      CLOSE c_overdue;

      --Start bug 7612000 gnramasa 4th Dec 08
	-- If value of "IEX: Exclude dispute amount from remaining amount " is Yes
	-- then calculate the Amount thats in dispute and substract it from the amount overdue.
	if (NVL(FND_PROFILE.VALUE('IEX_EXCLUDE_DISPUTE_AMT_FROM_REMAINING_AMT'), 'N') = 'Y') then
		select nvl(sum(cm.total_amount * -1),0)
		into l_amount_in_dispute
		from ra_cm_requests cm
		where cm.customer_trx_id in (select distinct ps.customer_trx_id
		from ar_payment_schedules ps,
		     ar_system_parameters parm
		where ps.customer_id = p_object_id
		and ps.org_id = parm.org_id
		and ps.status = 'OP')
		and cm.status='PENDING_APPROVAL';

		x_object_info_rec.amount_overdue := x_object_info_rec.amount_overdue - l_amount_in_dispute;
	end if;
	--End bug 7612000 gnramasa 4th Dec 08

      OPEN c_balance FOR
        SELECT SUM(NVL(acctd_amount_due_remaining,0))
        FROM ar_payment_schedules ps,
        -- Begin fix bug #5077320-jypark-adding parameter table to show amount for selected operating unit
             ar_system_parameters parm
        WHERE customer_id = p_object_id
        AND ps.org_id = parm.org_id
        -- End fix bug #5077320-jypark-adding parameter table to show amount for selected operating unit
        AND ps.status = 'OP';

      FETCH c_balance INTO x_object_info_rec.current_balance;
      CLOSE c_balance;

      end if; --end if for check on count of currency codes

      --Start bug 8359894  gnramasa 18th june 09
      if (NVL(FND_PROFILE.VALUE('IEX_SHOW_DSO_IN_HEADER'), 'Y') = 'Y') then
	      OPEN c_dso FOR
		SELECT
		      ROUND(
		       ( (SUM( DECODE(PS.CLASS,
				     'INV', 1,
				     'DM',  1,
				     'CB',  1,
				     'DEP', 1,
				     'BR',  1, /* 22-JUL-2000 J Rautiainen BR Implementation */
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
		FROM ar_system_parameters         sp,
		     ar_payment_schedules         ps
		WHERE ps.customer_id = l_cust_account_id
		AND NVL(ps.receipt_confirmed_flag,'Y') = 'Y'
		AND ps.org_id=sp.org_id; --added for moac change

	      FETCH c_dso INTO x_object_info_rec.dso;
	      CLOSE c_dso;
	end if;
	--End bug 8359894  gnramasa 18th june 09

    ELSIF p_object_type = 'DELINQUENCY' AND p_object_id IS NOT NULL THEN
      l_party_id := null;
      l_cust_account_id := null;

      OPEN c_del(p_object_id);
      FETCH c_del INTO l_payment_schedule_id;
      CLOSE c_del;


      --start moac change
      --if the functional currency codes of the ou's are different
      --make the Amount overdue and Net balance fields as null.
      if l_cnt_cur_codes <> 1 then
           x_object_info_rec.current_balance:=null;
           x_object_info_rec.amount_overdue:=null;
      else
      --end moac change
      OPEN c_overdue FOR
        SELECT ps.acctd_amount_due_remaining
        FROM ar_payment_schedules ps, iex_delinquencies del
        WHERE del.delinquency_id = p_object_id
        AND ps.payment_schedule_id = del.payment_schedule_id
        AND ps.status = 'OP'
        AND del.status IN ('DELINQUENT', 'PREDELINQUENT');

      FETCH c_overdue INTO x_object_info_rec.amount_overdue;
      CLOSE c_overdue;

      x_object_info_rec.current_balance := x_object_info_rec.amount_overdue;

      --Start bug 7612000 gnramasa 4th Dec 08
	-- If value of "IEX: Exclude dispute amount from remaining amount " is Yes
	-- then calculate the Amount thats in dispute and substract it from the amount overdue.
	if (NVL(FND_PROFILE.VALUE('IEX_EXCLUDE_DISPUTE_AMT_FROM_REMAINING_AMT'), 'N') = 'Y') then
		select nvl(sum(cm.total_amount * -1),0)
		into l_amount_in_dispute
		from ra_cm_requests cm
		where cm.customer_trx_id in
		(
		SELECT distinct ps.customer_trx_id
		FROM ar_payment_schedules ps, iex_delinquencies del
		WHERE del.delinquency_id = p_object_id
		AND ps.payment_schedule_id = del.payment_schedule_id
		AND ps.status = 'OP'
		AND del.status IN ('DELINQUENT', 'PREDELINQUENT'))
		and cm.status='PENDING_APPROVAL';

		x_object_info_rec.amount_overdue := x_object_info_rec.amount_overdue - l_amount_in_dispute;
	end if;
	--End bug 7612000 gnramasa 4th Dec 08

      end if; --end if for check on count of currency codes(moac change).

      --Start bug 8359894  gnramasa 18th june 09
      if (NVL(FND_PROFILE.VALUE('IEX_SHOW_DSO_IN_HEADER'), 'Y') = 'Y') then
	      OPEN c_dso FOR
		SELECT
		      ROUND(
		       ( (SUM( DECODE(PS.CLASS,
				     'INV', 1,
				     'DM',  1,
				     'CB',  1,
				     'DEP', 1,
				     'BR',  1, /* 22-JUL-2000 J Rautiainen BR Implementation */
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
		FROM ar_system_parameters         sp,
		     ar_payment_schedules         ps
		WHERE NVL(ps.receipt_confirmed_flag,'Y') = 'Y'
		AND ps.payment_schedule_id = l_payment_schedule_id
		AND ps.org_id=sp.org_id; --added for moac change
	      FETCH c_dso INTO x_object_info_rec.dso;
	      CLOSE c_dso;
	end if;
	--End bug 8359894  gnramasa 18th june 09

    ELSIF p_object_type = 'BILL_TO' AND p_object_id IS NOT NULL THEN
      l_party_id := null;
      l_cust_account_id := null;
      l_payment_schedule_id := null;
      l_customer_site_use_id := p_object_id;

      --start moac change
      --if the functional currency codes of the ou's are different
      --make the Amount overdue and Net balance fields as null.
      if l_cnt_cur_codes <> 1 then
           x_object_info_rec.current_balance:=null;
           x_object_info_rec.amount_overdue:=null;
      else
      --end moac change

      OPEN c_overdue FOR
        SELECT sum(acctd_amount_due_remaining) amount
        FROM   ar_payment_schedules ps, iex_delinquencies del
        WHERE ps.customer_site_use_id = p_object_id
--BEGIN-FIX BUG#4356388-05/24/2005-JYPARK-amount overdue should inculde Pre-Delinquent transactions which are not past due
--        AND ps.due_date < sysdate
--END-FIX BUG#4356388-05/24/2005-JYPARK-amount overdue should inculde Pre-Delinquent transactions which are not past due
        AND ps.status = 'OP'
        AND del.payment_schedule_id = ps.payment_schedule_id
        AND del.status IN ('DELINQUENT', 'PREDELINQUENT');

      FETCH c_overdue INTO x_object_info_rec.amount_overdue;
      CLOSE c_overdue;

      --Start bug 7612000 gnramasa 4th Dec 08
	-- If value of "IEX: Exclude dispute amount from remaining amount " is Yes
	-- then calculate the Amount thats in dispute and substract it from the amount overdue.
	if (NVL(FND_PROFILE.VALUE('IEX_EXCLUDE_DISPUTE_AMT_FROM_REMAINING_AMT'), 'N') = 'Y') then
		select nvl(sum(cm.total_amount * -1),0)
		into l_amount_in_dispute
		from ra_cm_requests cm
		where cm.customer_trx_id in (select distinct ps.customer_trx_id
		FROM ar_payment_schedules ps,
		     ar_system_parameters parm
		WHERE ps.customer_site_use_id = p_object_id
		AND ps.org_id = parm.org_id
		AND ps.status = 'OP')
		and cm.status='PENDING_APPROVAL';

		x_object_info_rec.amount_overdue := x_object_info_rec.amount_overdue - l_amount_in_dispute;
	end if;
	--End bug 7612000 gnramasa 4th Dec 08

      OPEN c_balance FOR
        SELECT SUM(NVL(acctd_amount_due_remaining,0))
        FROM ar_payment_schedules ps,
        -- Begin fix bug #5077320-jypark-adding parameter table to show amount for selected operating unit
             ar_system_parameters parm
        WHERE customer_site_use_id = p_object_id
        AND ps.org_id = parm.org_id
        AND status = 'OP';
        -- SELECT SUM(DECODE(class, 'INV', acctd_amount_due_remaining,
        --                         'DM', acctd_amount_due_remaining,
        --                         'GUAR', acctd_amount_due_remaining,
        --                         'CB', acctd_amount_due_remaining,
        --                         'DM', acctd_amount_due_remaining,
        --                         'DEP', acctd_amount_due_remaining,
        --                         'CM',  acctd_amount_due_remaining,
        --                         'PMT',  acctd_amount_due_remaining))
        -- FROM ar_payment_schedules
        -- End fix bug #5077320-jypark-adding parameter table to show amount for selected operating unit

      FETCH c_balance INTO x_object_info_rec.current_balance;
      CLOSE c_balance;

      end if; --end if for check on count of currency codes(moac change).

      --Start bug 8359894  gnramasa 18th june 09
      if (NVL(FND_PROFILE.VALUE('IEX_SHOW_DSO_IN_HEADER'), 'Y') = 'Y') then
	      OPEN c_dso FOR
		SELECT
		      ROUND(
		       ( (SUM( DECODE(PS.CLASS,
				     'INV', 1,
				     'DM',  1,
				     'CB',  1,
				     'DEP', 1,
				     'BR',  1, /* 22-JUL-2000 J Rautiainen BR Implementation */
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
		FROM ar_system_parameters         sp,
		     ar_payment_schedules         ps
		WHERE ps.customer_site_use_id = l_customer_site_use_id
		AND NVL(ps.receipt_confirmed_flag,'Y') = 'Y'
		AND ps.org_id=sp.org_id; --added for moac change

	      FETCH c_dso INTO x_object_info_rec.dso;
	      CLOSE c_dso;
	end if;
	--End bug 8359894  gnramasa 18th june 09


    END IF;

    if p_object_source = 'AR' then
        get_last_payment_info(
           p_api_version => p_api_version,
           p_init_msg_list => p_init_msg_list,
           p_commit => p_commit,
           p_validation_level => p_validation_level,
           x_return_status => x_return_status,
           x_msg_count => x_msg_count,
           x_msg_data => x_msg_data,
           p_object_type => p_object_type,
           p_object_id => p_object_id,
           x_last_pmt_info_rec => l_last_pmt_info_rec);

        x_object_info_rec.last_payment_amount := l_last_pmt_info_rec.amount;
        x_object_info_rec.last_payment_curr := l_last_pmt_info_rec.currency_code;
        x_object_info_rec.last_payment_due_date := l_last_pmt_info_rec.due_date;
        x_object_info_rec.last_payment_date := l_last_pmt_info_rec.receipt_date;
        x_object_info_rec.last_payment_status := l_last_pmt_info_rec.status;
        x_object_info_rec.last_payment_receipt_number := l_last_pmt_info_rec.receipt_number;
        x_object_info_rec.last_payment_id := l_last_pmt_info_rec.cash_receipt_id;

    elsif p_object_source = 'OKL' then

        Get_Last_OKL_Payment_Info(
           p_api_version => p_api_version,
           p_init_msg_list => p_init_msg_list,
           p_commit => p_commit,
           p_validation_level => p_validation_level,
           x_return_status => x_return_status,
           x_msg_count => x_msg_count,
           x_msg_data => x_msg_data,
           p_object_type => p_object_type,
           p_object_id => p_object_id,
           x_last_okl_pmt_info_rec => l_last_okl_pmt_info_rec);

        x_object_info_rec.last_okl_payment_amount := l_last_okl_pmt_info_rec.AMOUNT_APPLIED;
        x_object_info_rec.last_okl_payment_curr := l_last_okl_pmt_info_rec.currency_code;
        x_object_info_rec.last_okl_payment_due_date := l_last_okl_pmt_info_rec.due_date;
        x_object_info_rec.last_okl_payment_date := l_last_okl_pmt_info_rec.APPLY_DATE;
        x_object_info_rec.last_okl_payment_status := l_last_okl_pmt_info_rec.RECEIPT_STATUS;
        x_object_info_rec.last_okl_payment_receipt_num := l_last_okl_pmt_info_rec.receipt_number;
        x_object_info_rec.last_okl_payment_id := l_last_okl_pmt_info_rec.cash_receipt_id;

    end if;
    --start moac change
    --if the functional currency codes of the ou's are different
    --make the Amount overdue and Net balance fields as null.
    if l_cnt_cur_codes <> 1 then
           x_object_info_rec.current_balance_curr:=null;
    else
    --end moac change
    IEX_CURRENCY_PVT.GET_FUNCT_CURR(
      P_API_VERSION =>1.0,
      p_init_msg_list => 'T',
      p_commit  => 'F',
      p_validation_level => 100,
      X_Functional_currency => x_object_info_rec.current_balance_curr,
      X_return_status => x_return_status,
      X_MSG_COUNT => x_msg_count,
      X_MSG_DATA => x_msg_data   );
    end if; --end if for check on count of currency codes(moac change).

    x_object_info_rec.amount_overdue_curr := x_object_info_rec.current_balance_curr;

    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':end');

  END Get_Object_Info;

  PROCEDURE Get_Last_Payment_Info
      (p_api_version      IN  NUMBER := 1.0,
       p_init_msg_list    IN  VARCHAR2,
       p_commit           IN  VARCHAR2,
       p_validation_level IN  NUMBER,
       x_return_status    OUT NOCOPY VARCHAR2,
       x_msg_count        OUT NOCOPY NUMBER,
       x_msg_data         OUT NOCOPY VARCHAR2,
       p_object_type      IN  VARCHAR2,
       p_object_id        IN  NUMBER,
       x_last_pmt_info_rec  OUT NOCOPY last_pmt_info_rec_type)
  IS
    l_api_version     CONSTANT   NUMBER :=  1.0;
    l_api_name        CONSTANT   VARCHAR2(30) :=  'Get_Last_Payment_Info';
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32767);

    l_party_id NUMBER;
    l_cust_account_id NUMBER;
    l_payment_schedule_id NUMBER;

    TYPE c_last_pmt_cur_type IS REF CURSOR;

    c_last_pmt c_last_pmt_cur_type;
    c_last_pmt2 c_last_pmt_cur_type;

    --Begin - Andre Araujo - 03/13/06 - Bug#5024219 - Improving performance
    l_pk_query    varchar2(2000);
    l_pk_from     varchar2(200);
    l_pk_where    varchar2(200);
    l_pk_group    varchar2(200);

    l_data_query  varchar2(10000);
    l_data_from   varchar2(2000);
    l_data_where  varchar2(2000);
    l_data_group  varchar2(2000);

    TYPE cv_typ   IS REF CURSOR;
    cv            cv_typ;

    l_account     NUMBER;
    l_site        NUMBER;
    l_org         NUMBER;
    l_pay_date    date;

    l_receipt     NUMBER;
    l_PSDueDate   date;
    l_amount      AR_TRX_BAL_SUMMARY.LAST_PAYMENT_AMOUNT%TYPE;
    l_currency    AR_TRX_BAL_SUMMARY.CURRENCY%TYPE;
    l_paynumber   AR_TRX_BAL_SUMMARY.LAST_PAYMENT_NUMBER%TYPE;
    l_status      varchar2(200);
    l_partyid     number;
    --End - Andre Araujo - 03/13/06 - Bug#5024219 - Improving performance
    --Begin-fix bug #5407151-JYPARK-08012006-hide last payment due on depending on profile IEX_SHOW_LAST_PMT_DUE
    l_show_last_pmt_due VARCHAR2(240);
    --End-fix bug #5407151-JYPARK-08012006-hide last payment due on depending on profile IEX_SHOW_LAST_PMT_DUE

  BEGIN
    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':begin');

    --Begin - Andre Araujo - 03/13/06 - Bug#5024219 - Improving performance
    --First we will find the PK for the record with the info we want
    BEGIN
    l_pk_query := 'select ca.party_id, TRX_SUM.CUST_ACCOUNT_ID, TRX_SUM.SITE_USE_ID, TRX_SUM.ORG_ID, TRX_SUM.CURRENCY, max(TRX_SUM.LAST_PAYMENT_DATE) pay_date ';
    l_pk_from  := 'from AR_TRX_BAL_SUMMARY TRX_SUM, hz_cust_accounts ca ';
    l_pk_where := 'where ca.CUST_ACCOUNT_ID = TRX_SUM.CUST_ACCOUNT_ID ';
    l_pk_group := 'group by ca.party_id, TRX_SUM.CUST_ACCOUNT_ID, TRX_SUM.SITE_USE_ID, TRX_SUM.ORG_ID, TRX_SUM.CURRENCY ';

    -- Begin - Bug#5358461 - Andre Araujo - 07/07/06 - This query is not MOAC ready
    l_pk_from  := l_pk_from  || ', ar_system_parameters arsys ';
    l_pk_where := l_pk_where || '  AND arsys.org_id = trx_sum.org_id ';
    l_pk_group := l_pk_group || ' order by pay_date desc ';   -- To do this pay_date was added to the end of l_pk_query
    -- End - Bug#5358461 - Andre Araujo - 07/07/06 - This query is not MOAC ready


    -- Begin Fix bug #5417273-JYPARK-08/01/2006-Exclude if ar_trx_bal_summary.last_payment_date is null
    l_pk_where := l_pk_where || ' AND trx_sum.last_payment_date IS NOT NULL ';
    -- End Fix bug #5417273-JYPARK-08/01/2006-Exclude if ar_trx_bal_summary.last_payment_date is null

    IF p_object_type = 'CUSTOMER' AND p_object_id IS NOT NULL THEN
		 l_pk_where := l_pk_where || 'and ca.party_id = :1 ';
    ELSIF p_object_type = 'ACCOUNT' AND p_object_id IS NOT NULL THEN
		 l_pk_where := l_pk_where || 'and TRX_SUM.CUST_ACCOUNT_ID = :1 ';
    ELSIF p_object_type = 'BILL_TO' AND p_object_id IS NOT NULL THEN
		 l_pk_where := l_pk_where || 'and TRX_SUM.SITE_USE_ID = :1 ';
    ELSIF p_object_type = 'DELINQUENCY' AND p_object_id IS NOT NULL THEN
      OPEN c_last_pmt FOR
           SELECT acr.receipt_date,
           acr.cash_receipt_id,
           decode(apsa.payment_schedule_id, -1, null, APSA.due_date),
           ara.amount_applied amount,
           apsa.invoice_currency_Code currency_code       ,
           acr.receipt_number,
           ARPT_SQL_FUNC_UTIL.get_lookup_meaning('CHECK_STATUS', acr.status)
           FROM  ar_payment_schedules apsa,
                 ar_cash_receipts acr,
                 ar_receivable_applications ara,
                 ar_cash_receipt_history acrh,
                 iex_delinquencies del
           WHERE ara.cash_receipt_id = acr.cash_receipt_id
           AND ara.applied_payment_schedule_id = apsa.payment_schedule_id
           AND apsa.payment_schedule_id = del.payment_schedule_id
           AND del.delinquency_id = p_object_id
           AND acr.cash_receipt_id = acrh.cash_receipt_id
           AND nvl(acr.confirmed_flag, 'Y') = 'Y'
           AND acr.reversal_date is null
           AND acrh.status not in (decode (acrh.factor_flag, 'Y', 'RISK_ELIMINATED',
                                                  'N', ' '), 'REVERSED')
           AND acrh.current_record_flag = 'Y'
           ORDER BY 1 DESC, 2 DESC, 3 ASC;

      FETCH c_last_pmt INTO x_last_pmt_info_rec.receipt_date,
                            x_last_pmt_info_rec.cash_receipt_id,
                            x_last_pmt_info_rec.due_date,
                            x_last_pmt_info_rec.amount,
                            x_last_pmt_info_rec.currency_code,
                            x_last_pmt_info_rec.receipt_number,
                            x_last_pmt_info_rec.status;
      CLOSE c_last_pmt;

      return;
    END IF;

	 l_pk_query := l_pk_query || l_pk_from || l_pk_where || l_pk_group;

    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':Query: ' || l_pk_query);

    -- Open ref cursor for the query
    OPEN cv FOR l_pk_query USING p_object_id;
    FETCH cv INTO l_partyid, l_account, l_site, l_org, l_currency, l_pay_date;
    CLOSE cv;

    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':Result: ' || l_account || ':: ' || l_site || ':: ' || l_org || ':: ' || l_currency || ':: ' || l_pay_date);

    -- Now we have the primary key to our info, get the data

    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':Query: Getting the data');

    -- Begin fix bug #5407151-JYPARK-08/01/2006-Hide 'Last Payment Due On' depending on profile 'IEX_SHOW_LAST_PMT_DUE'
    l_show_last_pmt_due := nvl(fnd_profile.value('IEX_SHOW_LAST_PMT_DUE'), 'Y');
    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':IEX_SHOW_LAST_PMT_DUE=' || l_show_last_pmt_due);

    IF l_show_last_pmt_due = 'Y' THEN
      l_data_query := 'SELECT TRX_SUM.LAST_PAYMENT_DATE, CR.CASH_RECEIPT_ID, ';
      l_data_query := l_data_query || '   DECODE(PS.PAYMENT_SCHEDULE_ID, -1, NULL, PS.DUE_DATE), ';
      l_data_query := l_data_query || '   TRX_SUM.LAST_PAYMENT_AMOUNT, TRX_SUM.CURRENCY, TRX_SUM.LAST_PAYMENT_NUMBER, ';
      l_data_query := l_data_query || '   ARPT_SQL_FUNC_UTIL.GET_LOOKUP_MEANING(''CHECK_STATUS'', CR.STATUS) ';
      l_data_from  := 'FROM ';
      l_data_from  := l_data_from || '   AR_TRX_BAL_SUMMARY TRX_SUM, HZ_CUST_ACCOUNTS CA, AR_CASH_RECEIPTS CR, ';
      l_data_from  := l_data_from || '   AR_RECEIVABLE_APPLICATIONS RA, AR_PAYMENT_SCHEDULES PS ';
      l_data_where := 'WHERE TRX_SUM.CUST_ACCOUNT_ID = :1 ';
      l_data_where := l_data_where || '  and TRX_SUM.SITE_USE_ID = :2 ';
      l_data_where := l_data_where || '  and TRX_SUM.ORG_ID = :3 ';
      l_data_where := l_data_where || '  and TRX_SUM.CURRENCY = :4 ';
      l_data_where := l_data_where || '  and CA.PARTY_ID = :5 ';
      l_data_where := l_data_where || '  and ca.cust_account_id = trx_sum.cust_account_id '; --Added for bug#7512425 by PNAVEENK
      l_data_where := l_data_where || '  AND CR.PAY_FROM_CUSTOMER = TRX_SUM.CUST_ACCOUNT_ID '; --Added for bug#7512425 by PNAVEENK

      if p_object_type = 'BILL_TO' AND p_object_id IS NOT NULL THEN   -- added for bug 8461423
         l_data_where := l_data_where || '  AND CR.CUSTOMER_SITE_USE_ID = TRX_SUM.SITE_USE_ID '; -- Added for bug#7512425 by PNAVEENK
      end if;

      l_data_where := l_data_where || '  and trunc(cr.receipt_date) = trunc(trx_sum.last_payment_date) '; -- Added for bug#7512425 by PNAVEENK
      l_data_where := l_data_where || '  and abs(cr.amount) = abs(trx_sum.last_payment_amount) '; --Added for bug#7512425 by PNAVEENK
      l_data_where := l_data_where || '  AND CR.RECEIPT_NUMBER = TRX_SUM.LAST_PAYMENT_NUMBER ';
      l_data_where := l_data_where || '  AND RA.CASH_RECEIPT_ID(+) = CR.CASH_RECEIPT_ID ';
      l_data_where := l_data_where || '  AND PS.PAYMENT_SCHEDULE_ID(+) = RA.APPLIED_PAYMENT_SCHEDULE_ID';
      l_data_where := l_data_where || '  AND trx_sum.last_payment_date is not null';  -- added for bug 8461423

      -- Begin - Bug#5358461 - Andre Araujo - 07/07/06 - We should ignore where payment schedule id is -1
      -- l_data_where := l_data_where || '  AND PS.PAYMENT_SCHEDULE_ID <> -1'; commented by ehuh 2/27/07 bug 5665646
      l_data_where := l_data_where || '  AND PS.PAYMENT_SCHEDULE_ID(+) > 0'; -- ehuh 2/27/07 bug 5665646 , 8461423
      l_data_group := ' order by due_date asc';

      --l_data_query := l_data_query || l_data_from || l_data_where; -- Adder order by
      l_data_query := l_data_query || l_data_from || l_data_where || l_data_group; -- Adder order by
    ELSE
      l_data_query := 'SELECT TRX_SUM.LAST_PAYMENT_DATE, null, ';
      l_data_query := l_data_query || '   null, ';
      l_data_query := l_data_query || '   TRX_SUM.LAST_PAYMENT_AMOUNT, TRX_SUM.CURRENCY, TRX_SUM.LAST_PAYMENT_NUMBER, ';
      l_data_query := l_data_query || '   null ';
      l_data_from  := 'FROM ';
      l_data_from  := l_data_from || '   AR_TRX_BAL_SUMMARY TRX_SUM, HZ_CUST_ACCOUNTS CA ';
      l_data_where := 'WHERE TRX_SUM.CUST_ACCOUNT_ID = :1 ';
      l_data_where := l_data_where || '  and TRX_SUM.SITE_USE_ID = :2 ';
      l_data_where := l_data_where || '  and TRX_SUM.ORG_ID = :3 ';
      l_data_where := l_data_where || '  and TRX_SUM.CURRENCY = :4 ';
      l_data_where := l_data_where || '  and CA.PARTY_ID = :5 ';

      l_data_query := l_data_query || l_data_from || l_data_where; -- Adder order by

    END IF;

    -- End - Bug#5358461 - Andre Araujo - 07/07/06 - We should ignore where payment schedule id is -1

    -- End fix bug #5407151-JYPARK-08/01/2006-Hide 'Last Payment Due On' depending on profile 'IEX_SHOW_LAST_PMT_DUE'

    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':Data Query: ' || l_data_query);


    -- Open ref cursor for the query
    OPEN cv FOR l_data_query USING l_account, l_site, l_org, l_currency, l_partyid;
    FETCH cv INTO l_pay_date,l_receipt,l_PSDueDate,l_amount,l_currency,l_paynumber,l_status;
    CLOSE cv;

    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':Data Result: ' || l_pay_date || ':: ' || l_receipt || ':: ' || l_PSDueDate || ':: ' || l_amount || ':: ' || l_currency || ':: ' || l_paynumber || ':: ' || l_status);

    x_last_pmt_info_rec.receipt_date   := l_pay_date;
    x_last_pmt_info_rec.cash_receipt_id:= l_receipt;
    x_last_pmt_info_rec.due_date       := l_PSDueDate;
    x_last_pmt_info_rec.amount         := l_amount;
    x_last_pmt_info_rec.currency_code  := l_currency;
    x_last_pmt_info_rec.receipt_number := l_paynumber;
    x_last_pmt_info_rec.status         := l_status;

    -- Now that we got the cash receipt ID we will get the due date of the payment schedule where the receipt was applied

    -- Begin - fix bug #5665646- ehuh -2/27/2007-remove duplicate code
    --  IF x_last_pmt_info_rec.cash_receipt_id IS NOT NULL THEN
    --	  OPEN c_last_pmt2 FOR
    --			  SELECT decode(ps.payment_schedule_id, -1, null, ps.due_date)
    --				FROM ar_receivable_applications ra,
    --				 ar_payment_schedules ps
    --				WHERE ra.cash_receipt_id = l_receipt
    --				AND ps.payment_schedule_id = ra.applied_payment_schedule_id;
    --
    --	  FETCH c_last_pmt2 INTO x_last_pmt_info_rec.due_date;
    --	  CLOSE c_last_pmt2;
    --	 END IF;
    -- endfix -  bug #5665646- ehuh -2/27/2007-remove duplicate code

    EXCEPTION
       WHEN OTHERS THEN
			 iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':EXCEPTION!!!!!');
			 iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':Query: ' || l_pk_query);
			 iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':Result: ' || l_account || ':: ' || l_site || ':: ' || l_org || ':: ' || l_currency || ':: ' || l_pay_date);
			 iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':Data Query: ' || l_data_query);
			 iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':Data Result: ' || l_pay_date || ':: ' || l_receipt || ':: ' || l_PSDueDate || ':: ' || l_amount || ':: ' || l_currency || ':: ' || l_paynumber || ':: ' || l_status);
			 iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || SQLCODE || SQLERRM);
    END ;
    --End - Andre Araujo - 03/13/06 - Bug#5024219 - Improving performance

/*  --Begin - Andre Araujo - 03/13/06 - Bug#5024219 - Improving performance -- Removed code replaced with the one above
-- Begin fix bug #4930425-jypark-01/10/2006-change query to remove full table scan
    IF p_object_type = 'CUSTOMER' AND p_object_id IS NOT NULL THEN
--       OPEN c_last_pmt FOR
--            SELECT trx_sum.last_payment_date,
--              cr.cash_receipt_id,
--              decode(ps.payment_schedule_id, -1, null, ps.due_date),
--              trx_sum.last_payment_amount,
--              trx_sum.currency,
--              trx_sum.last_payment_number,
--              ARPT_SQL_FUNC_UTIL.get_lookup_meaning('CHECK_STATUS', cr.status)
--             FROM ar_trx_bal_summary trx_sum,
--              hz_cust_accounts ca, ar_cash_receipts cr,
--              ar_receivable_applications ra,
--              ar_payment_schedules ps
--             WHERE trx_sum.cust_account_id = ca.cust_account_id
--             AND ca.party_id = p_object_id
--             AND cr.receipt_number = trx_sum.last_payment_number
--             AND ra.cash_receipt_id(+) = cr.cash_receipt_id
--             AND ps.payment_schedule_id(+) = ra.applied_payment_schedule_id
--             ORDER BY 1 DESC, 2 DESC, 3 ASC;
--
--      FETCH c_last_pmt INTO x_last_pmt_info_rec.receipt_date,
--                            x_last_pmt_info_rec.cash_receipt_id,
--                            x_last_pmt_info_rec.due_date,
--                            x_last_pmt_info_rec.amount,
--                            x_last_pmt_info_rec.currency_code,
--                            x_last_pmt_info_rec.receipt_number,
--                            x_last_pmt_info_rec.status;
--      CLOSE c_last_pmt;

      OPEN c_last_pmt FOR
            SELECT trx_sum.last_payment_date,
              cr.cash_receipt_id,
              trx_sum.last_payment_amount,
              trx_sum.currency,
              trx_sum.last_payment_number,
              ARPT_SQL_FUNC_UTIL.get_lookup_meaning('CHECK_STATUS', cr.status)
             FROM ar_trx_bal_summary trx_sum,
              hz_cust_accounts ca, ar_cash_receipts cr
             WHERE trx_sum.cust_account_id = ca.cust_account_id
             AND ca.party_id = p_object_id
             AND cr.receipt_number = trx_sum.last_payment_number
             ORDER BY 1 DESC, 2 DESC;

      FETCH c_last_pmt INTO x_last_pmt_info_rec.receipt_date,
                            x_last_pmt_info_rec.cash_receipt_id,
                            x_last_pmt_info_rec.amount,
                            x_last_pmt_info_rec.currency_code,
                            x_last_pmt_info_rec.receipt_number,
                            x_last_pmt_info_rec.status;
      CLOSE c_last_pmt;

      IF x_last_pmt_info_rec.cash_receipt_id IS NOT NULL THEN

        OPEN c_last_pmt2 FOR
              SELECT decode(ps.payment_schedule_id, -1, null, ps.due_date)
               FROM ar_receivable_applications ra,
                ar_payment_schedules ps
               WHERE ra.cash_receipt_id = x_last_pmt_info_rec.cash_receipt_id
               AND ps.payment_schedule_id = ra.applied_payment_schedule_id;

        FETCH c_last_pmt2 INTO x_last_pmt_info_rec.due_date;
        CLOSE c_last_pmt2;
      END IF;

    ELSIF p_object_type = 'ACCOUNT' AND p_object_id IS NOT NULL THEN
--      OPEN c_last_pmt FOR
--           SELECT trx_sum.last_payment_date,
--            cr.cash_receipt_id,
--            decode(ps.payment_schedule_id, -1, null, ps.due_date),
--            trx_sum.last_payment_amount,
--            trx_sum.currency,
--            trx_sum.last_payment_number,
--            ARPT_SQL_FUNC_UTIL.get_lookup_meaning('CHECK_STATUS', cr.status)
--           FROM ar_trx_bal_summary trx_sum,
--            ar_cash_receipts cr,
--            ar_receivable_applications ra,
--            ar_payment_schedules ps
--           WHERE trx_sum.cust_account_id = p_object_id
--           AND cr.receipt_number = trx_sum.last_payment_number
--           AND ra.cash_receipt_id(+) = cr.cash_receipt_id
--           AND ps.payment_schedule_id(+) = ra.applied_payment_schedule_id
--           ORDER BY 1 DESC, 2 DESC, 3 ASC;
--
--      FETCH c_last_pmt INTO x_last_pmt_info_rec.receipt_date,
--                            x_last_pmt_info_rec.cash_receipt_id,
--                            x_last_pmt_info_rec.due_date,
--                            x_last_pmt_info_rec.amount,
--                            x_last_pmt_info_rec.currency_code,
--                            x_last_pmt_info_rec.receipt_number,
--                            x_last_pmt_info_rec.status;
--      CLOSE c_last_pmt;

      OPEN c_last_pmt FOR
           SELECT trx_sum.last_payment_date,
            cr.cash_receipt_id,
            trx_sum.last_payment_amount,
            trx_sum.currency,
            trx_sum.last_payment_number,
            ARPT_SQL_FUNC_UTIL.get_lookup_meaning('CHECK_STATUS', cr.status)
           FROM ar_trx_bal_summary trx_sum,
            ar_cash_receipts cr
           WHERE trx_sum.cust_account_id = p_object_id
           AND cr.receipt_number = trx_sum.last_payment_number
           ORDER BY 1 DESC, 2 DESC;

      FETCH c_last_pmt INTO x_last_pmt_info_rec.receipt_date,
                            x_last_pmt_info_rec.cash_receipt_id,
                            x_last_pmt_info_rec.amount,
                            x_last_pmt_info_rec.currency_code,
                            x_last_pmt_info_rec.receipt_number,
                            x_last_pmt_info_rec.status;
      CLOSE c_last_pmt;


      IF x_last_pmt_info_rec.cash_receipt_id IS NOT NULL THEN

        OPEN c_last_pmt2 FOR
              SELECT decode(ps.payment_schedule_id, -1, null, ps.due_date)
               FROM ar_receivable_applications ra,
                ar_payment_schedules ps
               WHERE ra.cash_receipt_id = x_last_pmt_info_rec.cash_receipt_id
               AND ps.payment_schedule_id = ra.applied_payment_schedule_id;

        FETCH c_last_pmt2 INTO x_last_pmt_info_rec.due_date;
        CLOSE c_last_pmt2;
      END IF;


    ELSIF p_object_type = 'DELINQUENCY' AND p_object_id IS NOT NULL THEN
      OPEN c_last_pmt FOR
           SELECT acr.receipt_date,
           acr.cash_receipt_id,
           decode(apsa.payment_schedule_id, -1, null, APSA.due_date),
           ara.amount_applied amount,
           apsa.invoice_currency_Code currency_code       ,
           acr.receipt_number,
           ARPT_SQL_FUNC_UTIL.get_lookup_meaning('CHECK_STATUS', acr.status)
           FROM  ar_payment_schedules apsa,
                 ar_cash_receipts acr,
                 ar_receivable_applications ara,
                 ar_cash_receipt_history acrh,
                 iex_delinquencies del
           WHERE ara.cash_receipt_id = acr.cash_receipt_id
           AND ara.applied_payment_schedule_id = apsa.payment_schedule_id
           AND apsa.payment_schedule_id = del.payment_schedule_id
           AND del.delinquency_id = p_object_id
           AND acr.cash_receipt_id = acrh.cash_receipt_id
           AND nvl(acr.confirmed_flag, 'Y') = 'Y'
           AND acr.reversal_date is null
           AND acrh.status not in (decode (acrh.factor_flag, 'Y', 'RISK_ELIMINATED',
                                                  'N', ' '), 'REVERSED')
           AND acrh.current_record_flag = 'Y'
           -- Begin fix bug #4932926-JYPARK-02/07/2006-remove unecesaary query for performance
           --AND ACR.receipt_date =
           --          (SELECT  max(a.receipt_date)
           --          FROM ar_cash_receipts a,
           --               ar_receivable_applications b,
           --               ar_cash_receipt_history c
           --          WHERE a.cash_receipt_id = b.cash_receipt_id
           --          AND b.applied_payment_schedule_id = apsa.payment_schedule_id
           --          AND a.reversal_date is null
           --          AND nvl(a.confirmed_flag, 'Y') = 'Y'
           --          AND a.cash_receipt_id = c.cash_receipt_id
           --          AND c.status not in (decode (C.factor_flag, 'Y', 'RISK_ELIMINATED',
           --                                       'N', ' '), 'REVERSED')
           --          AND c.current_record_flag = 'Y'
           --          )
           -- End fix bug #4932926-JYPARK-02/07/2006-remove unecesaary query for performance
           ORDER BY 1 DESC, 2 DESC, 3 ASC;

      FETCH c_last_pmt INTO x_last_pmt_info_rec.receipt_date,
                            x_last_pmt_info_rec.cash_receipt_id,
                            x_last_pmt_info_rec.due_date,
                            x_last_pmt_info_rec.amount,
                            x_last_pmt_info_rec.currency_code,
                            x_last_pmt_info_rec.receipt_number,
                            x_last_pmt_info_rec.status;
      CLOSE c_last_pmt;
    ELSIF p_object_type = 'BILL_TO' AND p_object_id IS NOT NULL THEN

      OPEN c_last_pmt FOR
           SELECT trx_sum.last_payment_date,
            cr.cash_receipt_id,
            trx_sum.last_payment_amount,
            trx_sum.currency,
            trx_sum.last_payment_number,
            ARPT_SQL_FUNC_UTIL.get_lookup_meaning('CHECK_STATUS', cr.status)
           FROM ar_trx_bal_summary trx_sum,
            ar_cash_receipts cr
           WHERE trx_sum.site_use_id = p_object_id
           AND cr.receipt_number = trx_sum.last_payment_number
           ORDER BY 1 DESC, 2 DESC;

      FETCH c_last_pmt INTO x_last_pmt_info_rec.receipt_date,
                            x_last_pmt_info_rec.cash_receipt_id,
                            x_last_pmt_info_rec.amount,
                            x_last_pmt_info_rec.currency_code,
                            x_last_pmt_info_rec.receipt_number,
                            x_last_pmt_info_rec.status;
      CLOSE c_last_pmt;

      IF x_last_pmt_info_rec.cash_receipt_id IS NOT NULL THEN

        OPEN c_last_pmt2 FOR
              SELECT decode(ps.payment_schedule_id, -1, null, ps.due_date)
               FROM ar_receivable_applications ra,
                ar_payment_schedules ps
               WHERE ra.cash_receipt_id = x_last_pmt_info_rec.cash_receipt_id
               AND ps.payment_schedule_id = ra.applied_payment_schedule_id;

        FETCH c_last_pmt2 INTO x_last_pmt_info_rec.due_date;
        CLOSE c_last_pmt2;
      END IF;

    END IF;
-- End fix bug #4930425-jypark-01/10/2006-change query to remove full table scan
--End - Andre Araujo - 03/13/06 - Bug#5024219 - Improving performance -- Remoed code replaced with the one above*/

    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':end');
  END Get_Last_Payment_Info;

  PROCEDURE Get_Last_OKL_Payment_Info
      (p_api_version      	IN  NUMBER := 1.0,
       p_init_msg_list    	IN  VARCHAR2,
       p_commit           	IN  VARCHAR2,
       p_validation_level 	IN  NUMBER,
       x_return_status    	OUT NOCOPY VARCHAR2,
       x_msg_count        	OUT NOCOPY NUMBER,
       x_msg_data         	OUT NOCOPY VARCHAR2,
       p_object_type      	IN  VARCHAR2,
       p_object_id        	IN  NUMBER,
       x_last_okl_pmt_info_rec  OUT NOCOPY last_okl_pmt_info_rec_type)
  IS
    l_api_version     CONSTANT   NUMBER :=  1.0;
    l_api_name        CONSTANT   VARCHAR2(30) :=  'Get_Last_OKL_Payment_Info';
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32767);

    TYPE c_last_pmt_cur_type IS REF CURSOR;
    c_last_pmt c_last_pmt_cur_type;

  BEGIN
    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':begin');

-- Begin fix bug #4930425-jypark-01/10/2006-removed obsolete query
--    IF p_object_type = 'CUSTOMER' AND p_object_id IS NOT NULL THEN
--      OPEN c_last_pmt FOR
--           SELECT pmt.APPLY_DATE,
--           	pmt.RECEIVABLE_APPLICATION_ID,
--           	pmt.DUE_DATE,
--           	pmt.CASH_RECEIPT_ID,
--           	pmt.REFERENCE_NUMBER,
--           	pmt.AMOUNT_APPLIED,
--           	pmt.CURRENCY_CODE,
--           	pmt.RECEIPT_STATUS_DSP
--           FROM iex_pay_okl_history_v pmt
--           WHERE pmt.party_id = p_object_id and
--           	pmt.REVERSAL_GL_DATE is null
--           ORDER BY 1 DESC;
--
--      FETCH c_last_pmt INTO x_last_okl_pmt_info_rec.apply_date,
--                            x_last_okl_pmt_info_rec.receivable_application_id,
--                            x_last_okl_pmt_info_rec.due_date,
--                            x_last_okl_pmt_info_rec.cash_receipt_id,
--                            x_last_okl_pmt_info_rec.receipt_number,
--                            x_last_okl_pmt_info_rec.amount_applied,
--                            x_last_okl_pmt_info_rec.currency_code,
--                            x_last_okl_pmt_info_rec.receipt_status;
--      CLOSE c_last_pmt;
--
--    ELSIF p_object_type = 'ACCOUNT' AND p_object_id IS NOT NULL THEN
--      OPEN c_last_pmt FOR
--           SELECT pmt.APPLY_DATE,
--           	pmt.RECEIVABLE_APPLICATION_ID,
--           	pmt.DUE_DATE,
--           	pmt.CASH_RECEIPT_ID,
--           	pmt.REFERENCE_NUMBER,
--           	pmt.AMOUNT_APPLIED,
--           	pmt.CURRENCY_CODE,
--           	pmt.RECEIPT_STATUS_DSP
--           FROM iex_pay_okl_history_v pmt
--           WHERE pmt.customer_id = p_object_id and
--           	pmt.REVERSAL_GL_DATE is null
--           ORDER BY 1 DESC;
--
--      FETCH c_last_pmt INTO x_last_okl_pmt_info_rec.apply_date,
--                            x_last_okl_pmt_info_rec.receivable_application_id,
--                            x_last_okl_pmt_info_rec.due_date,
--                            x_last_okl_pmt_info_rec.cash_receipt_id,
--                            x_last_okl_pmt_info_rec.receipt_number,
--                            x_last_okl_pmt_info_rec.amount_applied,
--                            x_last_okl_pmt_info_rec.currency_code,
--                            x_last_okl_pmt_info_rec.receipt_status;
--      CLOSE c_last_pmt;
--
--    ELSIF p_object_type = 'DELINQUENCY' AND p_object_id IS NOT NULL THEN
--      OPEN c_last_pmt FOR
--           SELECT pmt.APPLY_DATE,
--           	pmt.RECEIVABLE_APPLICATION_ID,
--           	pmt.DUE_DATE,
--           	pmt.CASH_RECEIPT_ID,
--           	pmt.REFERENCE_NUMBER,
--           	pmt.AMOUNT_APPLIED,
--           	pmt.CURRENCY_CODE,
--           	pmt.RECEIPT_STATUS_DSP
--           FROM iex_pay_okl_history_v pmt
--           WHERE pmt.delinquency_id is not null and
--           	pmt.delinquency_id = p_object_id and
--           	pmt.REVERSAL_GL_DATE is null
--           ORDER BY 1 DESC;
--
--      FETCH c_last_pmt INTO x_last_okl_pmt_info_rec.apply_date,
--                            x_last_okl_pmt_info_rec.receivable_application_id,
--                            x_last_okl_pmt_info_rec.due_date,
--                            x_last_okl_pmt_info_rec.cash_receipt_id,
--                            x_last_okl_pmt_info_rec.receipt_number,
--                            x_last_okl_pmt_info_rec.amount_applied,
--                            x_last_okl_pmt_info_rec.currency_code,
--                            x_last_okl_pmt_info_rec.receipt_status;
--      CLOSE c_last_pmt;
--
--    ELSIF p_object_type = 'BILL_TO' AND p_object_id IS NOT NULL THEN
--      OPEN c_last_pmt FOR
--           SELECT pmt.APPLY_DATE,
--           	pmt.RECEIVABLE_APPLICATION_ID,
--           	pmt.DUE_DATE,
--           	pmt.CASH_RECEIPT_ID,
--           	pmt.REFERENCE_NUMBER,
--           	pmt.AMOUNT_APPLIED,
--           	pmt.CURRENCY_CODE,
--           	pmt.RECEIPT_STATUS_DSP
--           FROM iex_pay_okl_history_v pmt
--           WHERE pmt.customer_site_use_id = p_object_id and
--           	pmt.REVERSAL_GL_DATE is null
--           ORDER BY 1 DESC;
--
--      FETCH c_last_pmt INTO x_last_okl_pmt_info_rec.apply_date,
--                            x_last_okl_pmt_info_rec.receivable_application_id,
--                            x_last_okl_pmt_info_rec.due_date,
--                            x_last_okl_pmt_info_rec.cash_receipt_id,
--                            x_last_okl_pmt_info_rec.receipt_number,
--                            x_last_okl_pmt_info_rec.amount_applied,
--                            x_last_okl_pmt_info_rec.currency_code,
--                            x_last_okl_pmt_info_rec.receipt_status;
--      CLOSE c_last_pmt;
--
--    END IF;
-- End fix bug #4930425-jypark-01/10/2006-removed obsolete query

    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':end');

  END Get_Last_OKL_Payment_Info;

  PROCEDURE get_contact_point_info(p_api_version      	IN  NUMBER := 1.0,
       p_init_msg_list    	IN  VARCHAR2,
       p_commit           	IN  VARCHAR2,
       p_validation_level 	IN  NUMBER,
       p_party_id        	IN  NUMBER,
       x_return_status    	OUT NOCOPY VARCHAR2,
       x_msg_count        	OUT NOCOPY NUMBER,
       x_msg_data         	OUT NOCOPY VARCHAR2,
       x_contact_point_info_rec     OUT NOCOPY contact_point_info_rec_type)
  IS
    l_api_name                      CONSTANT VARCHAR2(30) := 'GET_CONTACT_POINT_INFO';
    CURSOR c_contact_point(x_party_id number) IS
      SELECT DECODE(CONTACT_POINT_PURPOSE, 'COLLECTIONS', 1, 2) C1,
             DECODE(PRIMARY_BY_PURPOSE, 'Y', 1, 2) C2,
             DECODE(PRIMARY_FLAG, 'Y', 1, 2) C3,
             contact_point_id, phone_country_code, phone_area_code, phone_number, phone_extension,
             ARPT_SQL_FUNC_UTIL.get_lookup_meaning('PHONE_LINE_TYPE', phone_line_type) phone_line_type_meaning,
             email_address, contact_point_type
      FROM hz_contact_points
      WHERE owner_table_name = 'HZ_PARTIES'
      AND owner_table_id = x_party_id
      AND ((contact_point_type = 'EMAIL') OR
           (contact_point_type = 'PHONE' AND phone_line_type NOT IN ('PAGER', 'FAX')))
      AND NVL(do_not_use_flag, 'N') = 'N'
      AND status = 'A'
      ORDER BY 1,2,3;

    l_contact_point_row c_contact_point%ROWTYPE;
    l_email_found VARCHAR2(1);
    l_phone_found VARCHAR2(1);
  BEGIN
    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':begin');
    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':p_party_id =' || p_party_id);

    l_email_found  := 'N';
    l_phone_found  := 'N';

    OPEN c_contact_point(p_party_id);
    FETCH c_contact_point INTO l_contact_point_row;

    LOOP
      EXIT WHEN (c_contact_point%NOTFOUND);

      IF l_phone_found = 'N' AND l_contact_point_row.contact_point_type = 'PHONE' THEN
        x_contact_point_info_rec.phone_contact_point_id := l_contact_point_row.contact_point_id;
        x_contact_point_info_rec.phone_country_code := l_contact_point_row.phone_country_code;
        x_contact_point_info_rec.phone_area_code := l_contact_point_row.phone_area_code;
        x_contact_point_info_rec.phone_number := l_contact_point_row.phone_number;
        x_contact_point_info_rec.phone_extension := l_contact_point_row.phone_extension;
        x_contact_point_info_rec.phone_line_type_meaning := l_contact_point_row.phone_line_type_meaning;
        l_phone_found := 'Y';
      ELSIF l_email_found = 'N' AND l_contact_point_row.contact_point_type = 'EMAIL' THEN
        x_contact_point_info_rec.email_contact_point_id := l_contact_point_row.contact_point_id;
        x_contact_point_info_rec.email_address :=  l_contact_point_row.email_address;
        l_email_found := 'Y';
      END IF;

      EXIT WHEN (l_email_found = 'Y' AND l_phone_found = 'Y');
      FETCH c_contact_point INTO l_contact_point_row;
    END LOOP;

    CLOSE c_contact_point;

    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':end');
  END get_contact_point_Info;

  PROCEDURE get_location_Info(
       p_api_version      	IN  NUMBER := 1.0,
       p_init_msg_list    	IN  VARCHAR2,
       p_commit           	IN  VARCHAR2,
       p_validation_level 	IN  NUMBER,
       p_party_id        	IN  NUMBER,
       x_return_status    	OUT NOCOPY VARCHAR2,
       x_msg_count        	OUT NOCOPY NUMBER,
       x_msg_data         	OUT NOCOPY VARCHAR2,
       x_location_info_rec  OUT NOCOPY location_info_rec_type)
  IS
    l_api_name                      CONSTANT VARCHAR2(30) := 'GET_LOCATION_INFO';
    cursor c_get_location(x_party_id number, x_primary_flag varchar2) is
  		select location_id, address2, address3, address4, party_id,last_update_date,
         	party_site_id,party_site_number,site_last_update_date, LAST_UPDATED_BY  ,LAST_UPDATE_LOGIN , CREATED_BY, CREATION_DATE, address1, city, state, province,
		postal_code, county, country_name, country_code, address_lines_phonetic,
                po_box_number, house_number, street_suffix,  street,
                street_number,  floor, suite, time_zone,time_zone_meaning, timezone_id, object_version_number, site_object_version_number,created_by_module, application_id
  		from   ast_locations_v
  		where  party_id = x_party_id
  		and primary_flag = x_primary_flag;
    l_location_row c_get_location%ROWTYPE;
    x_get_location_found boolean := false;
  BEGIN
    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':begin');
    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':p_party_id=' || p_party_id);

    open c_get_location(p_party_id, 'Y');
    fetch c_get_location into l_location_row;
    IF c_get_location%FOUND THEN

      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':found location_row');

      x_location_info_rec.location_id := l_location_row.location_id;
      x_location_info_rec.address2 := l_location_row.address2;
      x_location_info_rec.address3 := l_location_row.address3;
      x_location_info_rec.address4 := l_location_row.address4;
      x_location_info_rec.party_id := l_location_row.party_id;
      x_location_info_rec.address_lines_phonetic := l_location_row.address_lines_phonetic;
      x_location_info_rec.po_box_number := l_location_row.po_box_number;
      x_location_info_rec.house_number := l_location_row.house_number;
      x_location_info_rec.street_suffix := l_location_row.street_suffix;
      x_location_info_rec.street := l_location_row.street;
      x_location_info_rec.street_number := l_location_row.street_number;
      x_location_info_rec.floor := l_location_row.floor;
      x_location_info_rec.suite := l_location_row.suite;
      x_location_info_rec.time_zone := l_location_row.time_zone;
      x_location_info_rec.time_zone_meaning := l_location_row.time_zone_meaning;
      x_location_info_rec.timezone_id := l_location_row.timezone_id;
      x_location_info_rec.last_update_date := l_location_row.last_update_date;
      x_location_info_rec.creation_date := l_location_row.creation_date;
      x_location_info_rec.created_by := l_location_row.created_by;
      x_location_info_rec.last_updated_by := l_location_row.last_updated_by;
      x_location_info_rec.created_by := l_location_row.created_by;
      x_location_info_rec.last_update_login := l_location_row.last_update_login;
      x_location_info_rec.site_last_update_date := l_location_row.site_last_update_date;
      x_location_info_rec.party_site_id := l_location_row.party_site_id;
      x_location_info_rec.party_site_number := l_location_row.party_site_number;
      x_location_info_rec.address1 := l_location_row.address1;
      x_location_info_rec.city := l_location_row.city;
      x_location_info_rec.state := l_location_row.state;
      x_location_info_rec.province := l_location_row.province;
      x_location_info_rec.postal_code := l_location_row.postal_code;
      x_location_info_rec.county := l_location_row.county;
      x_location_info_rec.country_name := l_location_row.country_name;
      x_location_info_rec.country_code := l_location_row.country_code;
      x_location_info_rec.object_version_number := l_location_row.object_version_number;
      x_location_info_rec.site_object_version_number := l_location_row.site_object_version_number;
      x_location_info_rec.created_by_module := l_location_row.created_by_module;
      x_location_info_rec.application_id := l_location_row.application_id;

    END IF;
    close c_get_location;
    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':end');
  END get_location_Info;

  PROCEDURE Get_Customer_Summary
  (p_api_version      IN  NUMBER := 1.0,
   p_init_msg_list    IN  VARCHAR2,
   p_commit           IN  VARCHAR2,
   p_validation_level IN  NUMBER,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2,
   p_party_id         IN  NUMBER,
   p_object_source    IN  VARCHAR2,
   x_customer_info_rec OUT NOCOPY customer_info_rec_type,
   x_object_info_rec OUT NOCOPY object_info_rec_type)
  IS
    l_api_version     CONSTANT   NUMBER :=  1.0;
    l_api_name        CONSTANT   VARCHAR2(30) :=  'Get_Customer_Summary';
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32767);

    amount  Number;
    total  Number;
    l_bkr_count number;  -- Added for bug#7590635 by PNAVEENK on 6-2-2009
    -- Get Tax Code
    CURSOR c_party_info IS
      SELECT jgzz_fiscal_code
      FROM   hz_parties
      WHERE  party_id = p_party_id;

    -- Collections score
    CURSOR c_collections_score IS
        SELECT a.score_value
        FROM iex_score_histories a
        WHERE a.creation_date =
        (SELECT MAX(creation_date)
       FROM iex_Score_histories
       WHERE score_object_code = 'PARTY'
       AND score_object_id = p_party_id)
     AND a.score_object_code = 'PARTY'
     AND a.score_object_id = p_party_id;

    -- Collectable/Delinquent Invoices
   -- start bug5874874 gnramasa 25-Apr-2007
    /* CURSOR c_summ_info IS
      SELECT COUNT(DECODE(ps.class, 'INV', ps.payment_schedule_id,
                                    'DM', ps.payment_schedule_id,
                                    'CB', ps.payment_schedule_id, NULL)) cnt_inv,
             COUNT(DECODE(ps.class, 'INV', DECODE(del.status, 'DELINQUENT', del.delinquency_id,
                                                              'PREDELINQUENT', del.delinquency_id,NULL), NULL)) cnt_del,
             SUM(NVL(ps.acctd_amount_due_remaining,0)) net_balance,
             SUM(DECODE(del.status, 'DELINQUENT', NVL(acctd_amount_due_remaining,0),
                                    'PREDELINQUENT', NVL(acctd_amount_due_remaining,0),0)) overdue_amt,
             ROUND(
               ( (SUM( DECODE(NVL(ps.receipt_confirmed_flag,'Y'), 'Y',
                        DECODE(PS.CLASS,
                             'INV', 1,
                             'DM',  1,
                             'CB',  1,
                             'DEP', 1,
                             'BR',  1, *//* 22-JUL-2000 J Rautiainen BR Implementation */
            /*                  0), 0)
                        * PS.ACCTD_AMOUNT_DUE_REMAINING
                      ) * MAX(SP.CER_DSO_DAYS)
                  )
                  / DECODE(
                         SUM( DECODE(NVL(ps.receipt_confirmed_flag,'Y'), 'Y',DECODE(PS.CLASS,
                                    'INV', 1,
                                    'DM',  1,
                                    'DEP', 1,
                                     0), 0)
                               * DECODE(SIGN (TRUNC(SYSDATE) - PS.TRX_DATE - SP.CER_DSO_DAYS),
                                        -1, (PS.AMOUNT_DUE_ORIGINAL  + NVL(PS.AMOUNT_ADJUSTED,0)) * NVL(PS.EXCHANGE_RATE, 1 ),
                                         0)) ,
                         0, 1,
                         SUM( DECODE(NVL(ps.receipt_confirmed_flag,'Y'), 'Y', DECODE(PS.CLASS,
                                    'INV', 1,
                                    'DM',  1,
                                    'DEP', 1,
                                     0), 0)
                              * DECODE(SIGN (TRUNC(SYSDATE) - PS.TRX_DATE - SP.CER_DSO_DAYS),
                                       -1, (PS.AMOUNT_DUE_ORIGINAL  + NVL(PS.AMOUNT_ADJUSTED,0)) * NVL(PS.EXCHANGE_RATE, 1 ),
                                       0) )
                          )
                ), 0)  dso
      FROM   ar_payment_schedules ps,
             hz_cust_accounts ca,
             iex_delinquencies del,
             ar_system_parameters sp
      WHERE  ca.party_id = p_party_id
      AND    ps.customer_id = ca.cust_account_id
      AND    ps.status = 'OP'
      AND    del.payment_schedule_id(+) = ps.payment_schedule_id
      and    ps.org_id=sp.org_id; --added for MOAC change
    */
    CURSOR c_summ_info1 IS
      SELECT COUNT(DECODE(ps.class, 'INV', ps.payment_schedule_id, 'DM',  ps.payment_schedule_id, 'CB',  ps.payment_schedule_id, NULL)) cnt_inv,
             COUNT(DECODE(ps.class, 'INV', DECODE(del.status, 'DELINQUENT', del.delinquency_id, 'PREDELINQUENT', del.delinquency_id, NULL), NULL)) cnt_del
      FROM   ar_payment_schedules ps,
             hz_cust_accounts ca,
             iex_delinquencies del
      WHERE  ca.party_id = p_party_id
      AND    ps.customer_id = ca.cust_account_id
      AND    ps.status = 'OP'
      AND    del.payment_schedule_id(+) = ps.payment_schedule_id;


    -- Balance, overdue amount and dso
    CURSOR c_summ_info2 IS
      SELECT SUM(NVL(ps.acctd_amount_due_remaining,0)) net_balance,
             SUM(DECODE(del.status, 'DELINQUENT', NVL(acctd_amount_due_remaining,0),
                                    'PREDELINQUENT', NVL(acctd_amount_due_remaining,0),0)) overdue_amt,
             ROUND(
               ( (SUM( DECODE(NVL(ps.receipt_confirmed_flag,'Y'), 'Y',
                        DECODE(PS.CLASS,
                             'INV', 1,
                             'DM',  1,
                             'CB',  1,
                             'DEP', 1,
                             'BR',  1, /* 22-JUL-2000 J Rautiainen BR Implementation */
                              0), 0)
                        * PS.ACCTD_AMOUNT_DUE_REMAINING
                      ) * MAX(SP.CER_DSO_DAYS)
                  )
                  / DECODE(
                         SUM( DECODE(NVL(ps.receipt_confirmed_flag,'Y'), 'Y',DECODE(PS.CLASS,
                                    'INV', 1,
                                    'DM',  1,
                                    'DEP', 1,
                                     0), 0)
                               * DECODE(SIGN (TRUNC(SYSDATE) - PS.TRX_DATE - SP.CER_DSO_DAYS),
                                        -1, (PS.AMOUNT_DUE_ORIGINAL  + NVL(PS.AMOUNT_ADJUSTED,0)) * NVL(PS.EXCHANGE_RATE, 1 ),
                                         0)) ,
                         0, 1,
                         SUM( DECODE(NVL(ps.receipt_confirmed_flag,'Y'), 'Y', DECODE(PS.CLASS,
                                    'INV', 1,
                                    'DM',  1,
                                    'DEP', 1,
                                     0), 0)
                              * DECODE(SIGN (TRUNC(SYSDATE) - PS.TRX_DATE - SP.CER_DSO_DAYS),
                                       -1, (PS.AMOUNT_DUE_ORIGINAL  + NVL(PS.AMOUNT_ADJUSTED,0)) * NVL(PS.EXCHANGE_RATE, 1 ),
                                       0) )
                          )
                ), 0)  dso
      FROM   ar_payment_schedules ps,
             hz_cust_accounts ca,
             iex_delinquencies del,
             ar_system_parameters sp
      WHERE  ca.party_id = p_party_id
      AND    ps.customer_id = ca.cust_account_id
      AND    ps.status = 'OP'
      AND    del.payment_schedule_id(+) = ps.payment_schedule_id
      AND    ps.org_id = sp.org_id;
   -- End bug5874874 gnramasa 25-Apr-2007

   --Start bug 8359894  gnramasa 18th june 09
   -- Balance, overdue amount
    CURSOR c_summ_info3 IS
      SELECT SUM(NVL(ps.acctd_amount_due_remaining,0)) net_balance,
             SUM(DECODE(del.status, 'DELINQUENT', NVL(acctd_amount_due_remaining,0),
                                    'PREDELINQUENT', NVL(acctd_amount_due_remaining,0),0)) overdue_amt
      FROM   ar_payment_schedules ps,
             hz_cust_accounts ca,
             iex_delinquencies del,
             ar_system_parameters sp
      WHERE  ca.party_id = p_party_id
      AND    ps.customer_id = ca.cust_account_id
      AND    ps.status = 'OP'
      AND    del.payment_schedule_id(+) = ps.payment_schedule_id
      AND    ps.org_id = sp.org_id;
    --End bug 8359894  gnramasa 18th june 09

    -- Delinquencies in Past Year
    CURSOR c_delinquencies IS
      SELECT Count(1)
      FROM iex_delinquencies del
      WHERE del.party_cust_id = p_party_id
      AND del.creation_date between sysdate - 365 and sysdate ;

      --  added by jypark for status in header
    CURSOR c_filter IS
      SELECT object_id, select_column, entity_name
      FROM iex_object_filters
      WHERE object_filter_type = 'IEXCUST'
      AND active_flag = 'Y';

    TYPE refCur IS REF CURSOR;
    c_universe refCur;
    l_sql_stmt VARCHAR2(1000);
    l_sql_stmt_lsd VARCHAR2(1000);
    l_status_rule_id  NUMBER;
    l_count NUMBER;
    l_delinquency_status VARCHAR(80);

    CURSOR c_rule IS
    SELECT rl.delinquency_status, rl.priority,
           iex_utilities.get_lookup_meaning('IEX_DELINQUENCY_STATUS', rl.delinquency_status) meaning
    FROM iex_cu_sts_rl_lines rl, iex_cust_status_rules r
    WHERE rl.status_rule_id = l_status_rule_id
    AND r.status_rule_id = rl.status_rule_id
    AND trunc(sysdate) BETWEEN trunc(nvl(r.start_date,sysdate)) AND trunc(nvl(r.end_date,sysdate))
    AND NVL(rl.enabled_flag, 'N') = 'Y'
    ORDER BY rl.priority;
    c_del refCur;

    -- Customer Since added by jypark 09/26/2002
    CURSOR c_customer_since IS
      SELECT MIN(account_established_date)
      FROM hz_cust_accounts
      WHERE account_established_date IS NOT NULL
      AND party_id = p_party_id;

     l_sql_select VARCHAR2(1000);
     l_sql_where VARCHAR2(1000);
     l_sql_cond VARCHAR2(1000);
     l_last_pmt_info_rec last_pmt_info_rec_type;

     l_cnt_cur_codes number; --added for MOAC
     l_calc_cust_stats VARCHAR2(1);

     l_amount_in_dispute     ra_cm_requests_all.total_amount%type;  --Added for bug 7612000 gnramasa 4th Dec 08

  BEGIN
    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':begin');

    --start moac change
    --to check whether all the ou's has the same functional currency or not
    l_cnt_cur_codes:= iex_currency_pvt.get_currency_count;
    --end moac change


    amount  :=  0 ;
    total   :=  0 ;
    l_sql_select :=  'SELECT count(1) FROM ';
    l_sql_where  := ' WHERE ';
    l_sql_cond  :=  ' = :party_id';

    x_customer_info_rec.party_id := p_party_id;

    OPEN c_party_info;
    FETCH c_party_info INTO x_customer_info_rec.identification_id;
    CLOSE c_party_info;
    -- Start bug5874874 gnramasa 25-Apr-2007
  /*  OPEN c_summ_info;
    FETCH c_summ_info INTO x_customer_info_rec.number_of_invoices,
                           x_customer_info_rec.invoices_overdue,
                           x_object_info_rec.current_balance,
                           x_object_info_rec.amount_overdue,
                           x_object_info_rec.dso;
    CLOSE c_summ_info;
  */
  l_calc_cust_stats := nvl(fnd_profile.value('IEX_CALC_CUST_STATS'), 'A');

    if (l_calc_cust_stats = 'A') then
        OPEN c_summ_info1;
        FETCH c_summ_info1 INTO x_customer_info_rec.number_of_invoices,
                            x_customer_info_rec.invoices_overdue;
        CLOSE c_summ_info1;

        OPEN c_delinquencies;
        FETCH c_delinquencies INTO x_customer_info_rec.number_of_delinquencies;
        CLOSE c_delinquencies;
    end if;

    --Start bug 8359894  gnramasa 18th june 09
    if (NVL(FND_PROFILE.VALUE('IEX_SHOW_DSO_IN_HEADER'), 'Y') = 'Y') then
	    OPEN c_summ_info2;
	    FETCH c_summ_info2 INTO x_object_info_rec.current_balance,
				x_object_info_rec.amount_overdue,
				x_object_info_rec.dso;
	    CLOSE c_summ_info2;
     else
	    OPEN c_summ_info3;
	    FETCH c_summ_info3 INTO x_object_info_rec.current_balance,
				x_object_info_rec.amount_overdue;
	    CLOSE c_summ_info3;
     end if;
     --End bug 8359894  gnramasa 18th june 09

    --Start bug 7612000 gnramasa 4th Dec 08
	-- If value of "IEX: Exclude dispute amount from remaining amount " is Yes
	-- then calculate the Amount thats in dispute and substract it from the amount overdue.
	if (NVL(FND_PROFILE.VALUE('IEX_EXCLUDE_DISPUTE_AMT_FROM_REMAINING_AMT'), 'N') = 'Y') then
		select nvl(sum(cm.total_amount * -1),0)
		into l_amount_in_dispute
		from ra_cm_requests cm
		where cm.customer_trx_id in (select distinct customer_trx_id
		from ar_payment_schedules ps,
		     hz_cust_accounts ca
		where ca.party_id = p_party_id
		and ps.customer_id = ca.cust_account_id
		and ps.status = 'OP')
		and cm.status='PENDING_APPROVAL';

		x_object_info_rec.amount_overdue := x_object_info_rec.amount_overdue - l_amount_in_dispute;
	end if;
	--End bug 7612000 gnramasa 4th Dec 08

      --start moac change
      --if the functional currency codes of the ou's are different
      --make the Amount overdue and Net balance fields as null.
      if l_cnt_cur_codes <>1 then
           x_object_info_rec.current_balance:=null;
           x_object_info_rec.amount_overdue:=null;
      end if;
      --end moac change


  /*  OPEN c_delinquencies;
    FETCH c_delinquencies INTO x_customer_info_rec.number_of_delinquencies;
    CLOSE c_delinquencies;
*/
  -- End bug5874874 gnramasa 25-Apr-2007

    OPEN c_collections_score;
    FETCH c_collections_score INTO x_customer_info_rec.collections_score;
    CLOSE c_collections_score;

    OPEN c_customer_since;
    FETCH c_customer_since INTO x_customer_info_rec.customer_since;
    CLOSE c_customer_since;

    --  added by jypark for status in header

    FOR r_filter in c_filter LOOP
      -- build SQL for universe
      -- for bug5874874 gnramasa 25-Apr-2007
      l_sql_stmt := 'SELECT 1 FROM dual WHERE EXISTS (SELECT 1 FROM ' || r_filter.entity_name || l_sql_where || r_filter.select_column || l_sql_cond || ')';
     -- l_sql_stmt :=  l_sql_select || r_filter.entity_name || l_sql_where || r_filter.select_column || l_sql_cond;

      BEGIN
        OPEN c_universe FOR l_sql_stmt USING p_party_id;
        FETCH c_universe into l_count;

        IF c_universe%FOUND AND l_count > 0 THEN

          l_status_rule_id := r_filter.object_id;
          CLOSE c_universe;


          -- begin added by jypark 01/05/2004 to fix bug #3308753
	  -- begin bug 6723556 gnramasa 10th Jan 2008

          IF l_status_rule_id IS NOT NULL THEN
            FOR r_rule IN c_rule LOOP
              l_delinquency_status := r_rule.delinquency_status;
	      iex_debug_pub.LogMessage('3. l_delinquency_status :' || l_delinquency_status);
              IF l_delinquency_status = 'BANKRUPTCY' THEN
                l_sql_stmt := 'SELECT count(1)' ||
                              '  FROM iex_bankruptcies' ||
                              ' WHERE party_id = :party_id' ||
                              '   AND close_date IS NULL ' ||
                              '   AND NVL(DISPOSITION_CODE, '' '') NOT IN (''DISMISSED'',''WITHDRAWN'' )';
              ELSIF l_delinquency_status = 'DELINQUENT' THEN
                l_sql_stmt := 'SELECT count(1)' ||
                              '  FROM iex_delinquencies' ||
                              ' WHERE party_cust_id = :party_id' ||
                              -- fix bug #4157131 ' AND status not in (''CURRENT'', ''CLOSE'')';
                              ' AND status = ''DELINQUENT''';
              ELSIF l_delinquency_status = 'LITIGATION' THEN
                l_sql_stmt_lsd :=  'select count(1) from (' ||
		             ' SELECT litigation_id' ||
			     '  FROM iex_litigations ltg, iex_delinquencies del' ||
                             ' WHERE del.party_cust_id = :party_id' ||
                             '  AND ltg.delinquency_id = del.delinquency_id' ||
                             '  AND del.status not in (''CURRENT'', ''CLOSE'')' ||
			     '  AND ltg.disposition_code IS NULL ' ||
			     ' UNION ' ||
			     ' SELECT litigation_id ' ||
			     '  FROM iex_litigations ' ||
			     ' WHERE party_id= :party_id ' ||
			     ' AND contract_number IS NOT NULL ' ||
			     ' AND ''DELINQUENT'' = IEX_UTILITIES.CheckContractStatus(contract_number) ' ||
			     '  AND disposition_code IS NULL )';
              ELSIF l_delinquency_status = 'REPOSSESSION' THEN
                l_sql_stmt_lsd := ' select count(1) from (' ||
		                  ' SELECT repossession_id' ||
			          '  FROM iex_repossessions rps, iex_delinquencies del' ||
                                  ' WHERE del.party_cust_id = :party_id' ||
                                  '  AND rps.delinquency_id = del.delinquency_id' ||
                                  '  AND del.status not in (''CURRENT'', ''CLOSE'')' ||
				  ' AND (rps.disposition_code IS NULL or rps.disposition_code = ''A'' or rps.disposition_code = ''W'') ' ||
			          --'  AND rps.disposition_code IS NULL ' ||
				  ' UNION ' ||
				  ' SELECT repossession_id ' ||
				  '  FROM iex_repossessions ' ||
				  ' WHERE party_id= :party_id ' ||
				  ' AND contract_number IS NOT NULL ' ||
				  ' AND ''DELINQUENT'' = IEX_UTILITIES.CheckContractStatus(contract_number) ' ||
				  ' AND (disposition_code IS NULL or disposition_code = ''A'' or disposition_code = ''W'')) ' ;
                                  --  Bug 766183 '  AND disposition_code IS NULL )';
              ELSIF l_delinquency_status = 'WRITEOFF' THEN
                l_sql_stmt_lsd := ' select count(1) from (' ||
		                  ' SELECT writeoff_id' ||
			          '  FROM iex_writeoffs wrf, iex_delinquencies del' ||
                                  ' WHERE del.party_cust_id = :party_id' ||
                                  '  AND wrf.delinquency_id = del.delinquency_id' ||
                                  '  AND del.status not in (''CURRENT'', ''CLOSE'')' ||
                                  '  AND (wrf.disposition_code IS NULL or wrf.disposition_code = ''A'' or wrf.disposition_code = ''W'') ' ||
			          -- '  AND wrf.disposition_code IS NULL ' ||
				  ' UNION ' ||
				  ' SELECT writeoff_id ' ||
				  '  FROM iex_writeoffs ' ||
				  ' WHERE party_id= :party_id ' ||
				  ' AND contract_number IS NOT NULL ' ||
				  ' AND ''DELINQUENT'' = IEX_UTILITIES.CheckContractStatus(contract_number) ' ||
				  ' AND (disposition_code IS NULL or disposition_code = ''A'' or disposition_code = ''W''))' ;
                                  -- '  AND disposition_code IS NULL )';
              ELSIF l_delinquency_status = 'PREDELINQUENT' THEN
                l_sql_stmt := 'SELECT count(1)' ||
                              '  FROM iex_delinquencies' ||
                              ' WHERE party_cust_id = :party_id' ||
                              -- fix bug #4157131 ' AND status not in (''CURRENT'', ''CLOSE'')';
                              ' AND status = ''PREDELINQUENT''';
              END IF;

              iex_debug_pub.LogMessage('3. p_party_id :' || p_party_id);
	      IF l_delinquency_status in ('LITIGATION','REPOSSESSION','WRITEOFF') THEN
		iex_debug_pub.LogMessage('3. l_sql_stmt_lsd :' || l_sql_stmt_lsd);
		OPEN c_del FOR l_sql_stmt_lsd USING p_party_id,p_party_id;
	      ELSE
		iex_debug_pub.LogMessage('3. l_sql_stmt :' || l_sql_stmt);
		OPEN c_del FOR l_sql_stmt USING p_party_id;
	      END IF;
              FETCH c_del INTO l_count;

              IF l_count > 0 THEN
                x_customer_info_rec.status := r_rule.meaning;
                CLOSE c_del;
                EXIT;
              END IF;
              CLOSE c_del;
            END LOOP;
          END IF;

          IF x_customer_info_rec.status IS NOT NULL THEN
            EXIT;
          END IF;
          -- end added by jypark 01/05/2004 to fix bug #3308753

        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          null;
      END ;
    END LOOP;

    IF l_status_rule_id IS NOT NULL THEN
      FOR r_rule IN c_rule LOOP
        l_delinquency_status := r_rule.delinquency_status;
	iex_debug_pub.LogMessage('4. l_delinquency_status :' || l_delinquency_status);
        IF l_delinquency_status = 'BANKRUPTCY' THEN
          l_sql_stmt := 'SELECT count(1)' ||
                        '  FROM iex_bankruptcies' ||
                        ' WHERE party_id = :party_id' ||
                        '   AND close_date IS NULL ' ||
                        '   AND NVL(DISPOSITION_CODE , '' '') NOT IN (''DISMISSED'',''WITHDRAWN'' )';
        ELSIF l_delinquency_status = 'DELINQUENT' THEN
          l_sql_stmt := 'SELECT count(1)' ||
                        '  FROM iex_delinquencies' ||
                        ' WHERE party_cust_id = :party_id' ||
                        -- fix bug #4157131 ' AND status not in (''CURRENT'', ''CLOSE'')';
                        ' AND status = ''DELINQUENT''';
        ELSIF l_delinquency_status = 'LITIGATION' THEN
          l_sql_stmt_lsd :=  'select count(1) from (' ||
		             ' SELECT litigation_id' ||
			     '  FROM iex_litigations ltg, iex_delinquencies del' ||
                             ' WHERE del.party_cust_id = :party_id' ||
                             '  AND ltg.delinquency_id = del.delinquency_id' ||
                             '  AND del.status not in (''CURRENT'', ''CLOSE'')' ||
			     '  AND ltg.disposition_code IS NULL ' ||
			     ' UNION ' ||
			     ' SELECT litigation_id ' ||
			     '  FROM iex_litigations ' ||
			     ' WHERE party_id= :party_id ' ||
			     ' AND contract_number IS NOT NULL ' ||
			     ' AND ''DELINQUENT'' = IEX_UTILITIES.CheckContractStatus(contract_number) ' ||
			     '  AND disposition_code IS NULL )';
        ELSIF l_delinquency_status = 'REPOSSESSION' THEN
          l_sql_stmt_lsd := ' select count(1) from (' ||
		                  ' SELECT repossession_id' ||
			          '  FROM iex_repossessions rps, iex_delinquencies del' ||
                                  ' WHERE del.party_cust_id = :party_id' ||
                                  '  AND rps.delinquency_id = del.delinquency_id' ||
                                  '  AND del.status not in (''CURRENT'', ''CLOSE'')' ||
				  ' AND (rps.disposition_code IS NULL or rps.disposition_code = ''A'' or rps.disposition_code = ''W'') ' ||
			          --'  AND rps.disposition_code IS NULL ' ||
				  ' UNION ' ||
				  ' SELECT repossession_id ' ||
				  '  FROM iex_repossessions ' ||
				  ' WHERE party_id= :party_id ' ||
				  ' AND contract_number IS NOT NULL ' ||
				  ' AND ''DELINQUENT'' = IEX_UTILITIES.CheckContractStatus(contract_number) ' ||
				  ' AND (disposition_code IS NULL or disposition_code = ''A'' or disposition_code = ''W'')) ' ;
                                  --  Bug 766183 '  AND disposition_code IS NULL )';
        ELSIF l_delinquency_status = 'WRITEOFF' THEN
          l_sql_stmt_lsd := ' select count(1) from (' ||
		                  ' SELECT writeoff_id' ||
			          '  FROM iex_writeoffs wrf, iex_delinquencies del' ||
                                  ' WHERE del.party_cust_id = :party_id' ||
                                  '  AND wrf.delinquency_id = del.delinquency_id' ||
                                  '  AND del.status not in (''CURRENT'', ''CLOSE'')' ||
                                  '  AND (wrf.disposition_code IS NULL or wrf.disposition_code = ''A'' or wrf.disposition_code = ''W'') ' ||
			          -- '  AND wrf.disposition_code IS NULL ' ||
				  ' UNION ' ||
				  ' SELECT writeoff_id ' ||
				  '  FROM iex_writeoffs ' ||
				  ' WHERE party_id= :party_id ' ||
				  ' AND contract_number IS NOT NULL ' ||
				  ' AND ''DELINQUENT'' = IEX_UTILITIES.CheckContractStatus(contract_number) ' ||
				  ' AND (disposition_code IS NULL or disposition_code = ''A'' or disposition_code = ''W''))' ;
                                  -- '  AND disposition_code IS NULL )';
        -- fix bug #4157131
        ELSIF l_delinquency_status = 'PREDELINQUENT' THEN
          l_sql_stmt := 'SELECT count(1)' ||
                        '  FROM iex_delinquencies' ||
                        ' WHERE party_cust_id = :party_id' ||
                        ' AND status = ''PREDELINQUENT''';
        END IF;

        iex_debug_pub.LogMessage('4. p_party_id :' || p_party_id);
	IF l_delinquency_status in ('LITIGATION','REPOSSESSION','WRITEOFF') THEN
	    iex_debug_pub.LogMessage('4. l_sql_stmt_lsd :' || l_sql_stmt_lsd);
	    OPEN c_del FOR l_sql_stmt_lsd USING p_party_id,p_party_id;
        ELSE
	    iex_debug_pub.LogMessage('4. l_sql_stmt :' || l_sql_stmt);
	    OPEN c_del FOR l_sql_stmt USING p_party_id;
        END IF;
	-- End bug 6723556 gnramasa 10th Jan 2008
        FETCH c_del INTO l_count;

        IF l_count > 0 THEN
          x_customer_info_rec.status := r_rule.meaning;
          CLOSE c_del;
          EXIT;
        END IF;
        CLOSE c_del;
      END LOOP;
    END IF;
    -- Start for bug#7590635 by PNAVEENK on 6-2-2009
    IF x_customer_info_rec.status IS NULL THEN

      SELECT count(1) into l_bkr_count
                        FROM iex_bankruptcies
                        WHERE party_id = x_customer_info_rec.party_id
                        AND close_date IS NULL
                        AND NVL(DISPOSITION_CODE, ' ') NOT IN ('DISMISSED','WITHDRAWN' );
      IF l_bkr_count > 0 then
             x_customer_info_rec.status := iex_utilities.get_lookup_meaning('IEX_DELINQUENCY_STATUS', 'BANKRUPTCY');
      ELSE
             x_customer_info_rec.status := iex_utilities.get_lookup_meaning('IEX_CUSTOMER_STATUS_TYPE', 'CURRENT');
      END IF;

    END IF;
    -- End for bug#7590635
    get_last_payment_info(
           p_api_version => p_api_version,
           p_init_msg_list => p_init_msg_list,
           p_commit => p_commit,
           p_validation_level => p_validation_level,
           x_return_status => x_return_status,
           x_msg_count => x_msg_count,
           x_msg_data => x_msg_data,
           p_object_type => 'CUSTOMER',
           p_object_id => p_party_id,
           x_last_pmt_info_rec => l_last_pmt_info_rec);

    x_object_info_rec.last_payment_amount := l_last_pmt_info_rec.amount;
    x_object_info_rec.last_payment_curr := l_last_pmt_info_rec.currency_code;
    x_object_info_rec.last_payment_due_date := l_last_pmt_info_rec.due_date;
    x_object_info_rec.last_payment_date := l_last_pmt_info_rec.receipt_date;
    x_object_info_rec.last_payment_status := l_last_pmt_info_rec.status;
    x_object_info_rec.last_payment_receipt_number := l_last_pmt_info_rec.receipt_number;
    x_object_info_rec.last_payment_id := l_last_pmt_info_rec.cash_receipt_id;

    --start moac change
    --if the functional currency codes of the ou's are different
    --make the Amount overdue and Net balance fields as null.
    if l_cnt_cur_codes <> 1 then
           x_object_info_rec.current_balance_curr:=null;
    else
    --end moac change
    IEX_CURRENCY_PVT.GET_FUNCT_CURR(
      P_API_VERSION =>1.0,
      p_init_msg_list => 'T',
      p_commit  => 'F',
      p_validation_level => 100,
      X_Functional_currency => x_object_info_rec.current_balance_curr,
      X_return_status => x_return_status,
      X_MSG_COUNT => x_msg_count,
      X_MSG_DATA => x_msg_data   );
    end if; --end if for check on count of currency codes(moac change).

    x_object_info_rec.amount_overdue_curr := x_object_info_rec.current_balance_curr;


    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':end');
  END Get_Customer_Summary;

  PROCEDURE Get_header_info
  (p_api_version      IN  NUMBER := 1.0,
   p_init_msg_list    IN  VARCHAR2,
   p_commit           IN  VARCHAR2,
   p_validation_level IN  NUMBER,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2,
   p_party_type       IN  VARCHAR2,
   p_rel_party_id     IN  NUMBER,
   p_org_party_id     IN  NUMBER,
   p_person_party_id  IN  NUMBER,
   p_object_type      IN  VARCHAR2,
   p_object_id        IN  NUMBER,
   p_object_source    IN  VARCHAR2,
   x_customer_info_rec OUT NOCOPY customer_info_rec_type,
   x_object_info_rec OUT NOCOPY object_info_rec_type,
   --x_email_info_rec OUT NOCOPY email_info_rec_type,
   --x_phone_info_rec OUT NOCOPY phone_info_rec_type,
   x_contact_point_info_rec OUT NOCOPY contact_point_info_rec_type,
   x_location_info_rec OUT NOCOPY location_info_rec_type)
  IS
    l_api_name                      CONSTANT VARCHAR2(30) := 'GET_HEADER_INFO';
    l_api_version     CONSTANT   NUMBER :=  1.0;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32767);

    l_party_id NUMBER;
  BEGIN
    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':begin');

    SAVEPOINT  Get_Header_Info_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Check p_init_msg_list
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;


    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':p_party_type=' || p_party_type || ':p_org_party_id' || p_org_party_id
      || ':p_person_paryt_id=' || p_person_party_id || ':p_rel_party_id=' || p_rel_party_id);
    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':p_object_type=' || p_object_type || ':p_object_id=' || p_object_id || ':p_object_source=' || p_object_source);

    IF p_party_type in ('ORGANIZATION', 'RELATIONSHIP') THEN
      l_party_id := p_org_party_id;
    ELSE
      l_party_id := p_person_party_id;
    END IF;

    IF p_object_source = 'AR' AND
       p_object_type = 'CUSTOMER' THEN
      Get_Customer_Summary(
           p_api_version => p_api_version,
           p_init_msg_list => p_init_msg_list,
           p_commit => p_commit,
           p_validation_level => p_validation_level,
           x_return_status => x_return_status,
           x_msg_count => x_msg_count,
           x_msg_data => x_msg_data,
   	   p_party_id => l_party_id,
           p_object_source => p_object_source,
   	   x_customer_info_rec => x_customer_info_rec,
           x_object_info_rec  => x_object_info_rec);
    ELSE
      Get_Customer_Info(
           p_api_version => p_api_version,
           p_init_msg_list => p_init_msg_list,
           p_commit => p_commit,
           p_validation_level => p_validation_level,
           x_return_status => x_return_status,
           x_msg_count => x_msg_count,
           x_msg_data => x_msg_data,
   	   p_party_id => l_party_id,
           p_object_source => p_object_source,
   	   x_customer_info_rec => x_customer_info_rec);

      Get_Object_Info(
           p_api_version => p_api_version,
           p_init_msg_list => p_init_msg_list,
           p_commit => p_commit,
           p_validation_level => p_validation_level,
           x_return_status => x_return_status,
           x_msg_count => x_msg_count,
           x_msg_data => x_msg_data,
           p_object_type => p_object_type,
           p_object_id  => p_object_id,
           p_object_source => p_object_source,
           x_object_info_rec  => x_object_info_rec);

    END IF;

    IF p_party_type = 'ORGANIZATION' THEN
      l_party_id := p_org_party_id;
    ELsIF p_party_type = 'RELATIONSHIP' THEN
      l_party_id := p_rel_party_id;
    ELSIF p_party_type = 'PERSON' THEN
      l_party_id := p_person_party_id;
    END IF;

    get_contact_point_info(
           p_api_version => p_api_version,
           p_init_msg_list => p_init_msg_list,
           p_commit => p_commit,
           p_validation_level => p_validation_level,
           x_return_status => x_return_status,
           x_msg_count => x_msg_count,
           x_msg_data => x_msg_data,
   	       p_party_id => l_party_id,
   	       x_contact_point_info_rec => x_contact_point_info_rec);

    get_location_Info(
           p_api_version => p_api_version,
           p_init_msg_list => p_init_msg_list,
           p_commit => p_commit,
           p_validation_level => p_validation_level,
   	       p_party_id => l_party_id,
           x_return_status => x_return_status,
           x_msg_count => x_msg_count,
           x_msg_data => x_msg_data,
   	       x_location_info_rec => x_location_info_rec);

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);


    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':end');
  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Get_Header_Info_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Get_Header_Info_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK TO Get_Header_Info_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
  END;
  PROCEDURE Create_Default_Contact
  (p_api_version      IN  NUMBER := 1.0,
   p_init_msg_list    IN  VARCHAR2,
   p_commit           IN  VARCHAR2,
   p_validation_level IN  NUMBER,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2,
   p_org_party_id     IN  NUMBER,
   p_person_party_id  IN  NUMBER,
   p_phone_contact_point_id IN  NUMBER,
   p_email_contact_point_id IN  NUMBER,
   p_type             IN  VARCHAR2,
   p_location_id      IN  NUMBER,
   x_relationship_id  OUT NOCOPY NUMBER,
   x_party_id         OUT NOCOPY NUMBER)
  IS
    l_api_name        CONSTANT VARCHAR2(30) := 'CREATE_DEFAULT_CONTACT';
    l_api_version     CONSTANT   NUMBER :=  1.0;

    l_party_rel_create_rec HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE;
    l_org_contact_create_rec HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE;

    l_party_rel_update_rec HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE;
    l_org_contact_update_rec HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE;

    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_return_status         VARCHAR2(1);

    l_cont_object_version_number  NUMBER;
    l_rel_object_version_number   NUMBER;
    l_party_object_version_number NUMBER;
    l_object_version_number       NUMBER;

    l_party_relationship_id NUMBER;
    l_party_id              NUMBER;
    l_party_number          VARCHAR2(30);

    l_msg_index_out number;
    l_org_contact_id NUMBER;

    l_last_update_date date;

    l_contact_point_create_rec  HZ_CONTACT_POINT_V2PUB.contact_point_Rec_type;
    l_phone_create_rec       HZ_CONTACT_POINT_V2PUB.phone_Rec_type;
    l_contact_point_id       NUMBER;
    l_email_create_rec       HZ_CONTACT_POINT_V2PUB.email_Rec_type;


    CURSOR c_exist_rel IS
      SELECT *
      FROM hz_relationships
      WHERE (subject_id = l_party_id
             AND relationship_code = p_type
             AND status = 'A');

    CURSOR c_org_contact(p_party_relationship_id NUMBER) IS
      SELECT org_contact_id, object_version_number
      FROM hz_org_contacts
      WHERE party_relationship_id = p_party_relationship_id;

    CURSOR c_party(p_party_id NUMBER) IS
      SELECT object_version_number
      FROM hz_parties
      WHERE party_id = p_party_id;

    CURSOR c_contact_point(p_contact_point_id NUMBER) is
      SELECT *
      FROM hz_contact_points
      WHERE contact_point_id = p_contact_point_id;

    --Begin Bug 6509624 31-Mar-2009 barathsr
    CURSOR c_phone_contact_point(p_contact_point_id NUMBER) is
      SELECT *
      FROM hz_contact_points
      WHERE owner_table_id=( SELECT owner_table_id
                             FROM hz_contact_points
                             WHERE contact_point_id = p_contact_point_id)
      AND contact_point_purpose=p_type
      AND contact_point_type ='PHONE'
      --Begin Bug 8322090 07-Apr-2009 barathsr
      UNION
      select *
      FROM hz_contact_points
      WHERE contact_point_id = p_contact_point_id;
      --End Bug  8322090 07-Apr-2009 barathsr

    l_phone_rec c_phone_contact_point%ROWTYPE;
   --End Bug 6509624 31-Mar-2009 barathsr
   -- l_phone_rec c_contact_point%ROWTYPE;
    l_email_rec c_contact_point%ROWTYPE;

    l_party_site_id NUMBER;
    l_party_site_number VARCHAR2(30);
    l_Party_Site_create_rec  	HZ_PARTY_SITE_V2PUB.Party_Site_Rec_type;
    l_call_api BOOLEAN;

    CURSOR c_CheckPartySite(p_partyid number,p_location_id Number) IS
      SELECT party_site_id,party_site_number
      FROM HZ_PARTY_SITES
      where party_id = p_partyid
      AND location_id = p_location_id;

  BEGIN
    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':begin');

    SAVEPOINT  Create_Default_Contact_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Check p_init_msg_list
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_party_rel_create_rec  := AST_API_RECORDS_V2PKG.INIT_HZ_PARTY_REL_REC_TYPE_V2;
    l_org_contact_create_rec  := AST_API_RECORDS_V2PKG.INIT_HZ_ORG_CONTACT_REC_V2;

    l_party_rel_update_rec  := AST_API_RECORDS_V2PKG.INIT_HZ_PARTY_REL_REC_TYPE_V2;
    l_org_contact_update_rec := AST_API_RECORDS_V2PKG.INIT_HZ_ORG_CONTACT_REC_V2;


    l_cont_object_version_number  := 1.0;
    l_rel_object_version_number   := 1.0;
    l_party_object_version_number := 1.0;
    l_object_version_number       := 1.0;

    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':p_org_party_id=' || p_org_party_id || ':p_person_party_id=' || p_person_party_id
      || ':p_phone_contact_point_id=' || p_phone_contact_point_id || ':p_type=' || p_type);

    l_party_id := p_org_party_id;

    FOR r_exist_rel IN c_exist_rel LOOP
      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':l_relationship_id=' || r_exist_rel.relationship_id);

      l_party_rel_update_rec.relationship_id         := r_exist_rel.relationship_id;
      l_party_rel_update_rec.subject_id              := r_exist_rel.subject_id;
      l_party_rel_update_rec.object_id               := r_exist_rel.object_id;
      l_party_rel_update_rec.status                  := 'I';
      l_party_rel_update_rec.start_date              := r_exist_rel.start_date;
      l_party_rel_update_rec.end_date                := sysdate;
      l_party_rel_update_rec.relationship_type       := r_exist_rel.relationship_type;
      l_party_rel_update_rec.relationship_code       := r_exist_rel.relationship_code;
      l_party_rel_update_rec.subject_table_name      := r_exist_rel.subject_table_name;
      l_party_rel_update_rec.object_table_name       := r_exist_rel.object_table_name;
      l_party_rel_update_rec.subject_type            := r_exist_rel.subject_type;
      l_party_rel_update_rec.object_type             := r_exist_rel.object_type;
      l_party_rel_update_rec.application_id          := r_exist_rel.application_id;

      l_party_rel_update_rec.party_rec.status        := 'I';

      OPEN c_org_contact(r_exist_rel.relationship_id);
      FETCH c_org_contact INTO l_org_contact_id, l_cont_object_version_number;
      CLOSE c_org_contact;

      l_org_contact_update_rec.org_contact_id        := l_org_contact_id;
      l_org_contact_update_rec.party_rel_rec         := l_party_rel_update_rec;
      l_org_contact_update_rec.application_id        := 625;

      l_rel_object_version_number := r_exist_rel.object_version_number;

      OPEN c_party(r_exist_rel.party_id);
      FETCH c_party INTO l_party_object_version_number;
      CLOSE c_party;

      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':Calling HZ_PARTY_CONTACT_V2PUB.Update_Org_Contact...');

      HZ_PARTY_CONTACT_V2PUB.Update_Org_Contact(
                p_init_msg_list          => 'F',
                p_org_contact_rec        => l_org_contact_update_rec,
                x_return_status          => l_return_status,
                x_msg_count              => l_msg_count,
                x_msg_data               => l_msg_data,
                p_cont_object_version_number  => l_cont_object_version_number,
                p_rel_object_version_number   => l_rel_object_version_number,
                p_party_object_version_number => l_party_object_version_number);

      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':l_return_status=' || l_return_status);
      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':l_cont_object_version_number=' || l_cont_object_version_number);
      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':l_rel_object_version_number=' || l_rel_object_version_number);
      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':l_party_object_version_number=' || l_party_object_version_number);

      IF l_return_status = FND_API.G_RET_STS_ERROR OR
         l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END LOOP;

    l_party_rel_create_rec.subject_id              := p_org_party_id;
    l_party_rel_create_rec.object_id               := p_person_party_id;
    l_party_rel_create_rec.status                  := 'A';
    l_party_rel_create_rec.start_date              := SYSDATE;
    l_party_rel_create_rec.relationship_type       := p_type;
    l_party_rel_create_rec.relationship_code       := p_type;
    l_party_rel_create_rec.subject_table_name      := 'HZ_PARTIES';
    l_party_rel_create_rec.object_table_name       := 'HZ_PARTIES';
    l_party_rel_create_rec.subject_type            := 'ORGANIZATION';
    l_party_rel_create_rec.object_type             := 'PERSON';
--Begin-fix bug#4604755-JYPARK-09/12/2005-When create 'Collections'/'Dunning' default contact in Collections, set CREATED_BY_MODULE column value depending on lookup HZ_CREATED_BY_MODULES
--    l_party_rel_create_rec.created_by_module       := 'IEX-DEFAULT-CONTACT';
    IF p_type = 'COLLECTIONS' THEN
      l_party_rel_create_rec.created_by_module       := 'IEX_COLLECTIONS_CONTACT';
    ELSIF p_type = 'DUNNING' THEN
      l_party_rel_create_rec.created_by_module       := 'IEX_DUNNING_CONTACT';
    END IF;
--End-fix bug#4604755-JYPARK-09/12/2005-When create 'Collections'/'Dunning' default contact in Collections, set CREATED_BY_MODULE column value depending on lookup HZ_CREATED_BY_MODULES
    l_party_rel_create_rec.application_id          := 625;

    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':HZ_GENERATE_PARTY_NUMBER=' || fnd_profile.value('HZ_GENERATE_PARTY_NUMBER'));

    IF NVL(fnd_profile.value('HZ_GENERATE_PARTY_NUMBER'), 'Y') = 'N' THEN
	  SELECT hz_parties_s.nextval
      INTO l_party_rel_create_rec.party_rec.party_number
      FROM dual;
	ELSE
      l_party_rel_create_rec.party_rec.party_number := '';
    END IF;

    l_party_rel_create_rec.party_rec.status        := 'A';
    l_org_contact_create_rec.party_rel_rec  := l_party_rel_create_rec;
--Begin-fix bug#4604755-JYPARK-09/12/2005-When create 'Collections'/'Dunning' default contact in Collections, set CREATED_BY_MODULE column value depending on lookup HZ_CREATED_BY_MODULES
--    l_org_contact_create_rec.created_by_module := 'IEX-DEFAULT-CONTACT';
    IF p_type = 'COLLECTIONS' THEN
      l_org_contact_create_rec.created_by_module       := 'IEX_COLLECTIONS_CONTACT';
    ELSIF p_type = 'DUNNING' THEN
      l_org_contact_create_rec.created_by_module       := 'IEX_DUNNING_CONTACT';
    END IF;
--End-fix bug#4604755-JYPARK-09/12/2005-When create 'Collections'/'Dunning' default contact in Collections, set CREATED_BY_MODULE column value depending on lookup HZ_CREATED_BY_MODULES

    l_org_contact_create_rec.application_id    := 625;

    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':Calling HZ_PARTY_CONTACT_V2PUB.Create_Org_Contact...');

    HZ_PARTY_CONTACT_V2PUB.Create_Org_Contact(
              p_init_msg_list          => 'F',
              p_org_contact_rec        => l_org_contact_create_rec,
              x_return_status          => l_return_status,
              x_msg_count              => l_msg_count,
              x_msg_data               => l_msg_data,
              x_org_contact_id         => l_org_contact_id,
              x_party_rel_id           => l_party_relationship_id,
              x_party_id               => l_party_id,
              x_party_number           => l_party_number );

    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':l_return_status=' || l_return_status);
    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':l_org_contact_id=' || l_org_contact_id || ' l_party_id=' || l_party_id || ' l_party_number=' || l_party_number);
    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':l_party_id=' || l_party_id);

    x_party_id := l_party_id;
    x_relationship_id := l_party_relationship_id;

    IF l_return_status = FND_API.G_RET_STS_ERROR OR
       l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF p_phone_contact_point_id IS NOT NULL THEN
    --Begin Bug 6509624 31-Mar-2009 barathsr
     /* OPEN c_contact_point(p_phone_contact_point_id);
      FETCH c_contact_point INTO l_phone_rec;
      CLOSE c_contact_point;*/

      OPEN c_phone_contact_point(p_phone_contact_point_id);
      LOOP
      FETCH c_phone_contact_point INTO l_phone_rec;
      EXIT WHEN c_phone_contact_point%NOTFOUND;
      iex_debug_pub.LogMessage('l_phone_rec.contact_point_id:' || l_phone_rec.contact_point_id);
      iex_debug_pub.LogMessage('l_phone_rec.owner_table_id:' || l_contact_point_create_rec.owner_table_id);
    --End Bug 6509624 31-Mar-2009 barathsr
      l_contact_point_create_rec.contact_point_type := l_phone_rec.contact_point_type;
      l_contact_point_create_rec.status := l_phone_rec.status;
      l_contact_point_create_rec.owner_table_name := l_phone_rec.owner_table_name;
      l_contact_point_create_rec.owner_table_id := l_party_id;
      l_contact_point_create_rec.primary_flag := l_phone_rec.primary_flag;
      l_contact_point_create_rec.contact_point_purpose := p_type;
     -- l_contact_point_create_rec.primary_by_purpose := 'Y';--Commented for Bug 6509624 31-Mar-2009 barathsr
      l_contact_point_create_rec.primary_by_purpose := l_phone_rec.primary_by_purpose; --Added for Bug 6509624 31-Mar-2009 barathsr
      l_contact_point_create_rec.orig_system_reference:= l_phone_rec.orig_system_reference;
--Begin-fix bug#4604755-JYPARK-09/12/2005-When create 'Collections'/'Dunning' default contact in Collections, set CREATED_BY_MODULE column value depending on lookup HZ_CREATED_BY_MODULES
--      l_contact_point_create_rec.created_by_module := 'IEX-DEFAULT-CONTACT';
      IF p_type = 'COLLECTIONS' THEN
        l_contact_point_create_rec.created_by_module       := 'IEX_COLLECTIONS_CONTACT';
      ELSIF p_type = 'DUNNING' THEN
        l_contact_point_create_rec.created_by_module       := 'IEX_DUNNING_CONTACT';
      END IF;
--End-fix bug#4604755-JYPARK-09/12/2005-When create 'Collections'/'Dunning' default contact in Collections, set CREATED_BY_MODULE column value depending on lookup HZ_CREATED_BY_MODULES

      l_contact_point_create_rec.content_source_type := l_phone_rec.content_source_type;
      l_contact_point_create_rec.attribute_category := l_phone_rec.attribute_category;
      l_contact_point_create_rec.attribute1 := l_phone_rec.attribute1;
      l_contact_point_create_rec.attribute2 := l_phone_rec.attribute2;
      l_contact_point_create_rec.attribute3 := l_phone_rec.attribute3;
      l_contact_point_create_rec.attribute4 := l_phone_rec.attribute4;
      l_contact_point_create_rec.attribute5 := l_phone_rec.attribute5;
      l_contact_point_create_rec.attribute6 := l_phone_rec.attribute6;
      l_contact_point_create_rec.attribute7 := l_phone_rec.attribute7;
      l_contact_point_create_rec.attribute8 := l_phone_rec.attribute8;
      l_contact_point_create_rec.attribute9 := l_phone_rec.attribute9;
      l_contact_point_create_rec.attribute10 := l_phone_rec.attribute10;
      l_contact_point_create_rec.attribute11 := l_phone_rec.attribute11;
      l_contact_point_create_rec.attribute12 := l_phone_rec.attribute12;
      l_contact_point_create_rec.attribute13 := l_phone_rec.attribute13;
      l_contact_point_create_rec.attribute14 := l_phone_rec.attribute14;
      l_contact_point_create_rec.attribute15 := l_phone_rec.attribute15;
      l_contact_point_create_rec.attribute16 := l_phone_rec.attribute16;
      l_contact_point_create_rec.attribute17 := l_phone_rec.attribute17;
      l_contact_point_create_rec.attribute18 := l_phone_rec.attribute18;
      l_contact_point_create_rec.attribute19 := l_phone_rec.attribute19;
      l_contact_point_create_rec.attribute20 := l_phone_rec.attribute20;

      l_phone_create_rec.phone_area_code := l_phone_rec.phone_area_code;
      l_phone_create_rec.phone_country_code := l_phone_rec.phone_country_code;
      l_phone_create_rec.phone_number := l_phone_rec.phone_number;
      l_phone_create_rec.phone_extension := l_phone_rec.phone_extension;
      l_phone_create_rec.phone_line_type := l_phone_rec.phone_line_type;
      --l_phone_create_rec.raw_phone_number := l_phone_rec.raw_phone_number;

      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':calling hz_contact_point_v2pub.create_phone_contact_point ...');

      hz_contact_point_v2pub.create_phone_contact_point(
        p_init_msg_list                 => 'F',
        x_return_status                 => l_return_status,
        x_msg_count                     => l_msg_count,
        x_msg_data                      => l_msg_data,
        p_contact_point_rec             => l_contact_point_create_rec,
        p_phone_rec                     => l_phone_create_rec,
        x_contact_point_id              => l_contact_point_id);

      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':l_return_status=' || l_return_status || ':l_contact_point_id=' || l_contact_point_id);

      IF l_return_status = FND_API.G_RET_STS_ERROR OR
         l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
     END LOOP;--Added for Bug 6509624 31-Mar-2009 barathsr
     CLOSE c_phone_contact_point;--Added for Bug 6509624 31-Mar-2009 barathsr

    END IF;  /*    IF p_phone_contact_point_id IS NOT NULL THEN */

    IF p_email_contact_point_id IS NOT NULL THEN
      OPEN c_contact_point(p_email_contact_point_id);
      FETCH c_contact_point INTO l_email_rec;
      CLOSE c_contact_point;

      l_contact_point_create_rec.contact_point_type := l_email_rec.contact_point_type;
      l_contact_point_create_rec.status := l_email_rec.status;
      l_contact_point_create_rec.owner_table_name := l_email_rec.owner_table_name;
      l_contact_point_create_rec.owner_table_id := l_party_id;
      l_contact_point_create_rec.primary_flag := l_email_rec.primary_flag;
      l_contact_point_create_rec.contact_point_purpose := p_type;
      l_contact_point_create_rec.primary_by_purpose := 'Y';
      l_contact_point_create_rec.orig_system_reference:= l_email_rec.orig_system_reference;
--Begin-fix bug#4604755-JYPARK-09/12/2005-When create 'Collections'/'Dunning' default contact in Collections, set CREATED_BY_MODULE column value depending on lookup HZ_CREATED_BY_MODULES
--      l_contact_point_create_rec.created_by_module := 'IEX-DEFAULT-CONTACT';
      IF p_type = 'COLLECTIONS' THEN
        l_contact_point_create_rec.created_by_module       := 'IEX_COLLECTIONS_CONTACT';
      ELSIF p_type = 'DUNNING' THEN
        l_contact_point_create_rec.created_by_module       := 'IEX_DUNNING_CONTACT';
      END IF;
--End-fix bug#4604755-JYPARK-09/12/2005-When create 'Collections'/'Dunning' default contact in Collections, set CREATED_BY_MODULE column value depending on lookup HZ_CREATED_BY_MODULES

      l_contact_point_create_rec.content_source_type := l_email_rec.content_source_type;
      l_contact_point_create_rec.attribute_category := l_email_rec.attribute_category;
      l_contact_point_create_rec.attribute1 := l_email_rec.attribute1;
      l_contact_point_create_rec.attribute2 := l_email_rec.attribute2;
      l_contact_point_create_rec.attribute3 := l_email_rec.attribute3;
      l_contact_point_create_rec.attribute4 := l_email_rec.attribute4;
      l_contact_point_create_rec.attribute5 := l_email_rec.attribute5;
      l_contact_point_create_rec.attribute6 := l_email_rec.attribute6;
      l_contact_point_create_rec.attribute7 := l_email_rec.attribute7;
      l_contact_point_create_rec.attribute8 := l_email_rec.attribute8;
      l_contact_point_create_rec.attribute9 := l_email_rec.attribute9;
      l_contact_point_create_rec.attribute10 := l_email_rec.attribute10;
      l_contact_point_create_rec.attribute11 := l_email_rec.attribute11;
      l_contact_point_create_rec.attribute12 := l_email_rec.attribute12;
      l_contact_point_create_rec.attribute13 := l_email_rec.attribute13;
      l_contact_point_create_rec.attribute14 := l_email_rec.attribute14;
      l_contact_point_create_rec.attribute15 := l_email_rec.attribute15;
      l_contact_point_create_rec.attribute16 := l_email_rec.attribute16;
      l_contact_point_create_rec.attribute17 := l_email_rec.attribute17;
      l_contact_point_create_rec.attribute18 := l_email_rec.attribute18;
      l_contact_point_create_rec.attribute19 := l_email_rec.attribute19;
      l_contact_point_create_rec.attribute20 := l_email_rec.attribute20;

      l_email_create_rec.email_format := l_email_rec.email_format;
      l_email_create_rec.email_address := l_email_rec.email_address;

      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':calling hz_contact_point_v2pub.create_email_contact_point ...');

      hz_contact_point_v2pub.create_email_contact_point(
        p_init_msg_list                 => 'F',
        x_return_status                 => l_return_status,
        x_msg_count                     => l_msg_count,
        x_msg_data                      => l_msg_data,
        p_contact_point_rec             => l_contact_point_create_rec,
        p_email_rec                     => l_email_create_rec,
        x_contact_point_id              => l_contact_point_id);

      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':l_return_status=' || l_return_status || ':l_contact_point_id=' || l_contact_point_id);

      IF l_return_status = FND_API.G_RET_STS_ERROR OR
         l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END IF;  /*    IF p_email_contact_point_id IS NOT NULL THEN */

    IF p_location_id IS NOT NULL THEN
      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':l_party_id=' || l_party_id || ':p_location_id=' || p_location_id);
      OPEN c_CheckPartySite(l_party_id, p_location_id);
      FETCH c_CheckPartySite INTO l_party_site_id, l_party_site_number;

      IF (c_CheckPartySite%FOUND) THEN
        iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':party site existing already');
        l_call_api := FALSE;
      ELSE
        l_call_api := TRUE;
      END IF; /*End of C_CheckPartySite%FOUND if loop */
      CLOSE c_CheckPartySite;

      IF l_Call_Api then
        l_Party_Site_Create_rec.Party_Id := l_party_id;
        l_Party_Site_Create_rec.Location_Id := p_location_id;

        iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':HZ_GENERATE_PARTY_SITE_NUMBER=' || fnd_profile.value('HZ_GENERATE_PARTY_SITE_NUMBER'));

        IF NVL(fnd_profile.value('HZ_GENERATE_PARTY_SITE_NUMBER'), 'Y') = 'N' THEN
          SELECT hz_party_sites_s.nextval
          INTO  l_Party_Site_Create_rec.Party_Site_Number
          FROM dual;
          iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':l_party_site_number=' || l_party_site_create_rec.party_site_number);
        ELSE
          l_Party_Site_Create_rec.Party_Site_Number := NULL;
        END IF;

        l_Party_Site_Create_rec.Identifying_Address_Flag := 'Y';
        l_Party_Site_Create_rec.Status := 'A';
--Begin-fix bug#4604755-JYPARK-09/12/2005-When create 'Collections'/'Dunning' default contact in Collections, set CREATED_BY_MODULE column value depending on lookup HZ_CREATED_BY_MODULES
--        l_Party_Site_Create_rec.Created_by_module := 'IEX-DEFAULT-CONTACT';
        IF p_type = 'COLLECTIONS' THEN
          l_Party_Site_Create_rec.created_by_module       := 'IEX_COLLECTIONS_CONTACT';
        ELSIF p_type = 'DUNNING' THEN
          l_Party_Site_Create_rec.created_by_module       := 'IEX_DUNNING_CONTACT';
        END IF;
--End-fix bug#4604755-JYPARK-09/12/2005-When create 'Collections'/'Dunning' default contact in Collections, set CREATED_BY_MODULE column value depending on lookup HZ_CREATED_BY_MODULES

        l_Party_Site_Create_rec.Application_id    := 625;

        l_Party_Site_Create_rec.Party_Site_Name := NULL;

        HZ_PARTY_SITE_V2PUB.Create_Party_Site  (
            p_init_msg_list      => 'F',
            p_party_site_rec     => l_party_site_Create_rec,
            x_return_status      => l_return_status,
            x_msg_count          => l_msg_count,
            x_msg_data           => l_msg_data,
            x_party_site_id      => l_party_site_id,
            x_party_site_number  => l_party_site_number
         );

        iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':l_return_status=' || l_return_status);
        iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':l_party_site_id=' || l_party_site_id);

        iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':l_return_status=' || l_return_status);

        IF l_return_status = FND_API.G_RET_STS_ERROR OR
           l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

      END IF; /*End of if l_Call_Api true loop for Party Site*/

    END IF; /*    IF p_location_id IS NOT NULL THEN */

    IF p_location_id IS NOT NULL THEN
      iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':l_party_id=' || l_party_id || ':p_location_id=' || p_location_id);
      OPEN c_CheckPartySite(l_party_id, p_location_id);
      FETCH c_CheckPartySite INTO l_party_site_id, l_party_site_number;

      IF (c_CheckPartySite%FOUND) THEN
        iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':party site existing already');
        l_call_api := FALSE;
      ELSE
        l_call_api := TRUE;
      END IF; /*End of C_CheckPartySite%FOUND if loop */
      CLOSE c_CheckPartySite;

      IF l_Call_Api then
        l_Party_Site_Create_rec.Party_Id := l_party_id;
        l_Party_Site_Create_rec.Location_Id := p_location_id;

        iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':HZ_GENERATE_PARTY_SITE_NUMBER=' || fnd_profile.value('HZ_GENERATE_PARTY_SITE_NUMBER'));

        IF NVL(fnd_profile.value('HZ_GENERATE_PARTY_SITE_NUMBER'), 'Y') = 'N' THEN
          SELECT hz_party_sites_s.nextval
          INTO  l_Party_Site_Create_rec.Party_Site_Number
          FROM dual;
          iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':l_party_site_number=' || l_party_site_create_rec.party_site_number);
        ELSE
          l_Party_Site_Create_rec.Party_Site_Number := NULL;
        END IF;

        l_Party_Site_Create_rec.Identifying_Address_Flag := 'Y';
        l_Party_Site_Create_rec.Status := 'A';
--Begin-fix bug#4604755-JYPARK-09/12/2005-When create 'Collections'/'Dunning' default contact in Collections, set CREATED_BY_MODULE column value depending on lookup HZ_CREATED_BY_MODULES
--        l_Party_Site_Create_rec.Created_by_module := 'IEX-DEFAULT-CONTACT';
        IF p_type = 'COLLECTIONS' THEN
          l_Party_Site_Create_rec.created_by_module       := 'IEX_COLLECTIONS_CONTACT';
        ELSIF p_type = 'DUNNING' THEN
          l_Party_Site_Create_rec.created_by_module       := 'IEX_DUNNING_CONTACT';
        END IF;
--End-fix bug#4604755-JYPARK-09/12/2005-When create 'Collections'/'Dunning' default contact in Collections, set CREATED_BY_MODULE column value depending on lookup HZ_CREATED_BY_MODULES

        l_Party_Site_Create_rec.Application_id    := 625;

        l_Party_Site_Create_rec.Party_Site_Name := NULL;

        HZ_PARTY_SITE_V2PUB.Create_Party_Site  (
            p_init_msg_list      => 'F',
            p_party_site_rec     => l_party_site_Create_rec,
            x_return_status      => l_return_status,
            x_msg_count          => l_msg_count,
            x_msg_data           => l_msg_data,
            x_party_site_id      => l_party_site_id,
            x_party_site_number  => l_party_site_number
         );

        iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':l_return_status=' || l_return_status);
        iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':l_party_site_id=' || l_party_site_id);

        IF l_return_status = FND_API.G_RET_STS_ERROR OR
           l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

      END IF; /*End of if l_Call_Api true loop for Party Site*/

    END IF; /*    IF p_location_id IS NOT NULL THEN */

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);


    iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':end');
  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Create_Default_Contact_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Create_Default_Contact_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK TO Create_Default_Contact_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
  END Create_Default_Contact;
BEGIN
  PG_DEBUG := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
  G_APPL_ID               := FND_GLOBAL.Prog_Appl_Id;
  G_LOGIN_ID              := FND_GLOBAL.Conc_Login_Id;
  G_PROGRAM_ID            := FND_GLOBAL.Conc_Program_Id;
  G_USER_ID               := FND_GLOBAL.User_Id;
  G_REQUEST_ID            := FND_GLOBAL.Conc_Request_Id;
END IEX_CUST_OVERVIEW_PVT;

/
