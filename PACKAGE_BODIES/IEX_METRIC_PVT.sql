--------------------------------------------------------
--  DDL for Package Body IEX_METRIC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_METRIC_PVT" AS
/* $Header: iexvmtrb.pls 120.9.12010000.3 2010/04/30 04:03:28 nkanchan ship $ */
PG_DEBUG NUMBER;
--BEGIN-FIX BUG#4375831-05/18/2005-JYPARK-fix error ORA-06521 because x_metric_value_tbl has charater value so convert to numeric value
  TYPE curr_rec_type IS RECORD (
     set_of_books_id   ar_system_parameters.set_of_books_id%TYPE           ,
     base_currency     gl_sets_of_books.currency_code%TYPE                 ,
     base_precision    fnd_currencies.precision%type                       ,
     base_min_acc_unit fnd_currencies.minimum_accountable_unit%type        ,
     past_year_from    DATE,
     past_year_to      DATE
  );

  g_curr_rec curr_rec_type;
--END-FIX BUG#4375831-05/18/2005-JYPARK-fix error ORA-06521 because x_metric_value_tbl has charater value so convert to numeric value

  PROCEDURE Get_Metric_Info
      (p_api_version      	IN  NUMBER,
       p_init_msg_list    	IN  VARCHAR2,
       p_commit           	IN  VARCHAR2,
       p_validation_level 	IN  NUMBER,
       x_return_status    	OUT NOCOPY VARCHAR2,
       x_msg_count        	OUT NOCOPY NUMBER,
       x_msg_data         	OUT NOCOPY VARCHAR2,
       p_party_id               IN  NUMBER,
       p_cust_account_id        IN  NUMBER,
       p_customer_site_use_id   IN  NUMBER,
       p_delinquency_id         IN  NUMBER,
       p_filter_by_object       IN  VARCHAR2,
       x_metric_id_tbl          OUT NOCOPY Metric_ID_Tbl_Type,
       x_metric_name_tbl        OUT NOCOPY Metric_Name_Tbl_Type,
       x_metric_value_tbl       OUT NOCOPY Metric_Value_Tbl_Type,
       x_metric_rating_tbl      OUT NOCOPY Metric_Rating_Tbl_Type)
  IS

    CURSOR c_metric IS
      SELECT score_comp_type_id, score_comp_name, score_comp_value
      FROM iex_score_comp_types_vl
      WHERE active_flag = 'Y'
      AND metric_flag = 'Y'
      AND jtf_object_code = NVL(p_filter_by_object, jtf_object_code)
      ORDER BY display_order;

    l_current_row NUMBER := 0;

    l_str VARCHAR2(2000);
    l_str2 VARCHAR2(2000);
    l_party_count NUMBER;
    l_acc_count NUMBER;
    l_billto_count NUMBER;
    p_del_count NUMBER;
    l_start NUMBER;
    l_str_result VARCHAR2(2000);
    l_sqlcursor NUMBER;

    -- l_value VARCHAR2(100); -- bug 5695898 by ehuh 3/2/07
    l_value VARCHAR2(1000);   -- bug 5695898 by ehuh 3/2/07
    l_dummy INTEGER;

    CURSOR c_rating(x_score_comp_type_id NUMBER) IS
      SELECT low_from, low_to, medium_from, medium_to, high_from, high_to
      FROM iex_metric_ratings
      WHERE score_comp_type_id = x_score_comp_type_id;

    r_rating c_rating%ROWTYPE;
    l_current_status VARCHAR2(1);
--BEGIN-FIX BUG#4375831-05/18/2005-JYPARK-fix error ORA-06521 because x_metric_value_tbl has charater value so convert to numeric value
    l_current_value_num NUMBER;
--END-FIX BUG#4375831-05/18/2005-JYPARK-fix error ORA-06521 because x_metric_value_tbl has charater value so convert to numeric value
--Begin bug#5208170 schekuri 29-May-2006
   CURSOR c_currency IS
   SELECT  gll.currency_code,
           c.precision,
           c.minimum_accountable_unit,
	   TRUNC(add_months(sysdate, - 12)) pastYearFrom ,
           TRUNC(sysdate) pastYearTo
    FROM    ar_system_parameters    sp,
            gl_ledgers_public_v     gll,
	    fnd_currencies     c
    WHERE   gll.ledger_id = sp.set_of_books_id
    AND    gll.currency_code   = c.currency_code;
--End bug#5208170 schekuri 29-May-2006
  BEGIN
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.logMessage('Object ID values: ' ||  p_party_id || p_cust_account_id || p_customer_site_use_id || p_delinquency_id);

	END IF;
    x_return_status := 'S';
    --Begin bug#5208170 schekuri 29-May-2006
    open c_currency;
    fetch c_currency into IEX_COLL_IND.g_curr_rec.base_currency,
	IEX_COLL_IND.g_curr_rec.base_precision,
	IEX_COLL_IND.g_curr_rec.base_min_acc_unit,
	IEX_COLL_IND.g_curr_rec.past_year_from,
	IEX_COLL_IND.g_curr_rec.past_year_to;
    close c_currency;
    --End bug#5208170 schekuri 29-May-2006


    FOR r_metric IN c_metric LOOP
      l_current_status := 'S';
      l_current_row := l_current_row + 1;

      x_metric_id_tbl(l_current_row) := r_metric.score_comp_type_id;
      x_metric_name_tbl(l_current_row) := r_metric.score_comp_name;
      l_str := r_metric.score_comp_value;
      l_str_result := '';

      l_party_count := 0;
      l_acc_count := 0;
      l_billto_count := 0;
      p_del_count := 0;
      l_start := 1;

      IF UPPER(l_str) like 'CALL %' THEN
        l_str := REPLACE(UPPER(l_str), 'CALL ', '');

        l_str := SUBSTRB(l_str, 1, INSTRB(l_str,')',1,1));

        l_str:= l_str || '; END; ';

        LOOP
          l_start := NVL(INSTRB(l_str,':',1,1),0);
          IF l_start > 0 THEN
            l_str2 := SUBSTRB(l_str,INSTRB(l_str,':',1,1),(INSTRB(UPPER(l_str),'_ID',INSTRB(l_str,':',1,1),1)+2-INSTRB(l_str,':',1,1)+1));
            IF UPPER(l_str2) = ':PARTY_ID' THEN
              l_party_count := l_party_count + 1;
              l_str2 := ':B_PARTY_ID_' || l_party_count;
            ELSIF UPPER(l_str2) = ':CUST_ACCOUNT_ID' THEN
              l_acc_count := l_acc_count + 1;
              l_str2 := ':B_CUST_ACCOUNT_ID_' || l_acc_count;
            ELSIF UPPER(l_str2) = ':CUSTOMER_SITE_USE_ID' THEN
              l_billto_count := l_billto_count + 1;
              l_str2 := ':B_CUSTOMER_SITE_USE_ID_' || l_billto_count;
            ELSIF UPPER(l_str2) = ':DELINQUENCY_ID' THEN
              p_del_count := p_del_count + 1;
              l_str2 := ':B_DELINQUENCY_ID_' || p_del_count;
            END IF;
            l_str_result := l_str_result || SUBSTRB(l_str, 1, INSTRB(l_str,':',1,1)-1) || l_str2;

            l_str := SUBSTRB(l_str, INSTRB(UPPER(l_str),'_ID',INSTRB(l_str,':',1,1),1)+3);
          ELSE
            l_str_result := l_str_result || l_str;
          END IF;
          EXIT WHEN l_start < 1;
        END LOOP;
        l_str_result := 'BEGIN :l_result := ' || l_str_result;


	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.logMessage('result: ' ||  l_str_result);
        END IF;

        l_sqlcursor := DBMS_SQL.OPEN_CURSOR;
        BEGIN
          DBMS_SQL.PARSE(l_sqlcursor, l_str_result, 1);
          -- DBMS_SQL.BIND_VARIABLE_CHAR(l_sqlcursor,'l_result', '0', 2000); -- bug 5695898 by ehuh 3/2/07
          DBMS_SQL.BIND_VARIABLE_CHAR(l_sqlcursor,'l_result', '0', 1000);    -- bug 5695898 by ehuh 3/2/07
          --DBMS_SQL.DEFINE_COLUMN(l_sqlcursor, 1, l_count);

          IF p_party_id > 0 THEN

            FOR i IN 1..l_party_count LOOP
		DBMS_SQL.BIND_VARIABLE(l_sqlcursor,'B_PARTY_ID_'||i, p_party_id);
            END LOOP;
          END IF;

          IF p_cust_account_id > 0 THEN

            FOR i IN 1..l_acc_count LOOP
              DBMS_SQL.BIND_VARIABLE(l_sqlcursor,'B_CUST_ACCOUNT_ID_'||i, p_cust_account_id);
            END LOOP;
          END IF;

          IF p_customer_site_use_id > 0 THEN

            FOR i IN 1..l_billto_count LOOP
              DBMS_SQL.BIND_VARIABLE(l_sqlcursor,'B_CUSTOMER_SITE_USE_ID_'||i, p_customer_site_use_id);
            END LOOP;
          END IF;

          IF p_delinquency_id > 0 THEN

            FOR i IN 1..p_del_count LOOP
              DBMS_SQL.BIND_VARIABLE(l_sqlcursor,'B_DELINQUENCY_ID_'||i, p_delinquency_id);
            END LOOP;
          END IF;





          l_dummy := DBMS_SQL.EXECUTE(l_sqlcursor);

          DBMS_SQL.VARIABLE_VALUE_CHAR(l_sqlcursor, 'l_result', l_value);
          x_metric_value_tbl(l_current_row) := RTRIM(l_value, ' ');

	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.logMessage('Metrics value: ' ||  x_metric_value_tbl(l_current_row));
        END IF;

        EXCEPTION
          WHEN OTHERS THEN
            l_current_status := 'E';
            x_metric_value_tbl(l_current_row) := 'NA';

        END;
        DBMS_SQL.CLOSE_CURSOR(l_sqlcursor);
      ELSE
        LOOP
          l_start := NVL(INSTRB(l_str,':',1,1),0);
          IF l_start > 0 THEN
            l_str2 := SUBSTRB(l_str,INSTRB(l_str,':',1,1),(INSTRB(UPPER(l_str),'_ID',INSTRB(l_str,':',1,1),1)+2-INSTRB(l_str,':',1,1)+1));
            IF UPPER(l_str2) = ':PARTY_ID' THEN
              l_party_count := l_party_count + 1;
              l_str2 := ':B_PARTY_ID_' || l_party_count;
            ELSIF UPPER(l_str2) = ':CUST_ACCOUNT_ID' THEN
              l_acc_count := l_acc_count + 1;
              l_str2 := ':B_CUST_ACCOUNT_ID_' || l_acc_count;
            ELSIF UPPER(l_str2) = ':CUSTOMER_SITE_USE_ID' THEN
              l_billto_count := l_billto_count + 1;
              l_str2 := ':B_CUSTOMER_SITE_USE_ID_' || l_billto_count;
            ELSIF UPPER(l_str2) = ':DELINQUENCY_ID' THEN
              p_del_count := p_del_count + 1;
              l_str2 := ':B_DELINQUENCY_ID_' || p_del_count;
            END IF;
            l_str_result := l_str_result || SUBSTRB(l_str, 1, INSTRB(l_str,':',1,1)-1) || l_str2;

            l_str := SUBSTRB(l_str, INSTRB(UPPER(l_str),'_ID',INSTRB(l_str,':',1,1),1)+3);
          ELSE
            l_str_result := l_str_result || l_str;
          END IF;

	  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.logMessage('result: ' ||  l_str_result);
        END IF;

          EXIT WHEN l_start < 1;
        END LOOP;

        l_sqlcursor := DBMS_SQL.OPEN_CURSOR;

        BEGIN
          DBMS_SQL.PARSE(l_sqlcursor, l_str_result, 1);
          DBMS_SQL.DEFINE_COLUMN(l_sqlcursor, 1, l_value, 200);

          IF p_party_id > 0 THEN
            FOR i IN 1..l_party_count LOOP
              DBMS_SQL.BIND_VARIABLE(l_sqlcursor,'B_PARTY_ID_'||i, p_party_id);
            END LOOP;
          END IF;

          IF p_cust_account_id > 0 THEN
            FOR i IN 1..l_acc_count LOOP
              DBMS_SQL.BIND_VARIABLE(l_sqlcursor,'B_CUST_ACCOUNT_ID_'||i, p_cust_account_id);
            END LOOP;
          END IF;

          IF p_customer_site_use_id > 0 THEN
            FOR i IN 1..l_billto_count LOOP
              DBMS_SQL.BIND_VARIABLE(l_sqlcursor,'B_CUSTOMER_SITE_USE_ID_'||i, p_customer_site_use_id);
            END LOOP;
          END IF;

          IF p_delinquency_id > 0 THEN
            FOR i IN 1..p_del_count LOOP
              DBMS_SQL.BIND_VARIABLE(l_sqlcursor,'B_DELINQUENCY_ID_'||i, p_delinquency_id);
            END LOOP;
          END IF;

          l_dummy := DBMS_SQL.EXECUTE(l_sqlcursor);

          IF DBMS_SQL.FETCH_ROWS(l_sqlcursor) > 0 THEN
            DBMS_SQL.COLUMN_VALUE(l_sqlcursor,1,l_value);
          END IF;

          x_metric_value_tbl(l_current_row) := l_value;

	  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.logMessage('Metrics value: ' ||  x_metric_value_tbl(l_current_row));
          END IF;

        EXCEPTION
          WHEN OTHERS THEN
            l_current_status := 'E';
            x_metric_value_tbl(l_current_row) := 'NA';

        END;
        DBMS_SQL.CLOSE_CURSOR(l_sqlcursor);
      END IF;

      IF (l_current_status = 'S') AND (x_metric_value_tbl(l_current_row) <> 'NA') THEN
--BEGIN-FIX BUG#4375831-05/18/2005-JYPARK-fix error ORA-06521 because x_metric_value_tbl has charater value so convert to numeric value
        BEGIN
          OPEN c_rating(r_metric.score_comp_type_id);
          FETCH c_rating INTO r_rating;

          IF c_rating%FOUND THEN
            CLOSE c_rating;
	    --Begin bug#5208170 schekuri 29-May-2006
            BEGIN
	          l_current_value_num := TO_NUMBER(x_metric_value_tbl(l_current_row),
	                                     fnd_currency.get_format_mask(iex_coll_ind.g_curr_rec.base_currency, 30));
            -- Begin fix bug #5360519-JYPARK-07/06/2006-if value is negative and non-amount format, getting number value
            EXCEPTION
              WHEN OTHERS THEN
                l_current_value_num := x_metric_value_tbl(l_current_row);
            END;
            -- End fix bug #5360519-JYPARK-07/06/2006-if value is negative and non-amount format, getting number value
            --l_current_value_num := TO_NUMBER(x_metric_value_tbl(l_current_row), fnd_currency.get_format_mask(g_curr_rec.base_currency, 30));
	    --End bug#5208170 schekuri 29-May-2006

--          IF(x_metric_value_tbl(l_current_row) >= r_rating.low_from) AND
--            (x_metric_value_tbl(l_current_row) <= r_rating.low_to) THEN
--            x_metric_rating_tbl(l_current_row) := 'LOW';
--          ELSIF(x_metric_value_tbl(l_current_row) >= r_rating.medium_from) AND
--            (x_metric_value_tbl(l_current_row) <= r_rating.medium_to) THEN
--            x_metric_rating_tbl(l_current_row) := 'MEDIUM';
--          ELSIF(x_metric_value_tbl(l_current_row) >= r_rating.high_from) AND
--            (x_metric_value_tbl(l_current_row) <= r_rating.high_to) THEN
--            x_metric_rating_tbl(l_current_row) := 'HIGH';
--          ELSE
--            x_metric_rating_tbl(l_current_row) := '';
--          END IF;

            IF(l_current_value_num >= r_rating.low_from) AND
              (l_current_value_num <= r_rating.low_to) THEN
              x_metric_rating_tbl(l_current_row) := 'LOW';
            ELSIF(l_current_value_num >= r_rating.medium_from) AND
              (l_current_value_num <= r_rating.medium_to) THEN
              x_metric_rating_tbl(l_current_row) := 'MEDIUM';
            ELSIF(l_current_value_num >= r_rating.high_from) AND
              (l_current_value_num <= r_rating.high_to) THEN
              x_metric_rating_tbl(l_current_row) := 'HIGH';
            ELSE
              x_metric_rating_tbl(l_current_row) := '';
            END IF;
          ELSE
            CLOSE c_rating;
            x_metric_rating_tbl(l_current_row) := '';
          END IF;
        EXCEPTION
        WHEN OTHERS THEN
          x_metric_rating_tbl(l_current_row) := '';
        END;
--END-FIX BUG#4375831-05/18/2005-JYPARK-fix error ORA-06521 because x_metric_value_tbl has charater value so convert to numeric value
      ELSE
        x_metric_rating_tbl(l_current_row) := '';
      END IF;
    END LOOP;

--BEGIN-FIX BUG#4375831-05/18/2005-JYPARK-fix error ORA-06521 because x_metric_value_tbl has charater value so convert to numeric value
  EXCEPTION
  WHEN OTHERS THEN
     null;
  END Get_Metric_Info;
--END-FIX BUG#4375831-05/18/2005-JYPARK-fix error ORA-06521 because x_metric_value_tbl has charater value so convert to numeric value
  PROCEDURE Test_Metric
      (
       p_filter_id         	IN  NUMBER,
       p_score_comp_type_id IN  NUMBER,
       x_return_status    	OUT NOCOPY VARCHAR2,
       x_metric_value       OUT NOCOPY VARCHAR2)
  IS
    CURSOR c_metric IS
      SELECT score_comp_value
      FROM iex_score_comp_types_b
      WHERE score_comp_type_id = p_score_comp_type_id;

    l_sql_stmt VARCHAR2(2000);

    l_str VARCHAR2(2000);
    l_str2 VARCHAR2(2000);
    l_party_count NUMBER;
    l_acc_count NUMBER;
    l_billto_count NUMBER;
    p_del_count NUMBER;
    l_start NUMBER;
    l_str_result VARCHAR2(2000);
    l_sqlcursor NUMBER;
    --  l_value VARCHAR2(100); Modified by nkanchan for bug # 8848670
    l_value VARCHAR2(1000);
    l_dummy INTEGER;

    l_current_status VARCHAR2(1);
  BEGIN

    x_return_status := 'S';

    OPEN c_metric;
    FETCH c_metric INTO l_sql_stmt;
    IF c_metric%FOUND THEN
      l_current_status := 'S';

      l_str := l_sql_stmt;
      l_str_result := '';

      l_party_count := 0;
      l_acc_count := 0;
      l_billto_count := 0;
      p_del_count := 0;
      l_start := 1;

      IF UPPER(l_str) like 'CALL %' THEN
        l_str := REPLACE(UPPER(l_str), 'CALL ', '');

        l_str := SUBSTRB(l_str, 1, INSTRB(l_str,')',1,1));

        l_str:= l_str || '; END; ';

        LOOP
          l_start := NVL(INSTRB(l_str,':',1,1),0);
          IF l_start > 0 THEN
            l_str2 := SUBSTRB(l_str,INSTRB(l_str,':',1,1),(INSTRB(UPPER(l_str),'_ID',INSTRB(l_str,':',1,1),1)+2-INSTRB(l_str,':',1,1)+1));
            IF UPPER(l_str2) = ':PARTY_ID' THEN
              l_party_count := l_party_count + 1;
              l_str2 := ':B_PARTY_ID_' || l_party_count;
            ELSIF UPPER(l_str2) = ':CUST_ACCOUNT_ID' THEN
              l_acc_count := l_acc_count + 1;
              l_str2 := ':B_CUST_ACCOUNT_ID_' || l_acc_count;
            ELSIF UPPER(l_str2) = ':CUSTOMER_SITE_USE_ID' THEN
              l_billto_count := l_billto_count + 1;
              l_str2 := ':B_CUSTOMER_SITE_USE_ID_' || l_billto_count;
            ELSIF UPPER(l_str2) = ':DELINQUENCY_ID' THEN
              p_del_count := p_del_count + 1;
              l_str2 := ':B_DELINQUENCY_ID_' || p_del_count;
            END IF;
            l_str_result := l_str_result || SUBSTRB(l_str, 1, INSTRB(l_str,':',1,1)-1) || l_str2;

            l_str := SUBSTRB(l_str, INSTRB(UPPER(l_str),'_ID',INSTRB(l_str,':',1,1),1)+3);
          ELSE
            l_str_result := l_str_result || l_str;
          END IF;
          EXIT WHEN l_start < 1;
        END LOOP;
        l_str_result := 'BEGIN :l_result := ' || l_str_result;

        l_sqlcursor := DBMS_SQL.OPEN_CURSOR;
        BEGIN
          DBMS_SQL.PARSE(l_sqlcursor, l_str_result, 1);
          -- Changed value from 2000 to 1000 by nkanchan for bug # 8848670
          DBMS_SQL.BIND_VARIABLE_CHAR(l_sqlcursor,'l_result', '0', 1000);
          --DBMS_SQL.DEFINE_COLUMN(l_sqlcursor, 1, l_count);

          FOR i IN 1..l_party_count LOOP
            DBMS_SQL.BIND_VARIABLE(l_sqlcursor,'B_PARTY_ID_'||i, p_filter_id);
          END LOOP;

          FOR i IN 1..l_acc_count LOOP
            DBMS_SQL.BIND_VARIABLE(l_sqlcursor,'B_CUST_ACCOUNT_ID_'||i, p_filter_id);
          END LOOP;

          FOR i IN 1..l_billto_count LOOP
            DBMS_SQL.BIND_VARIABLE(l_sqlcursor,'B_CUSTOMER_SITE_USE_ID_'||i, p_filter_id);
          END LOOP;

          FOR i IN 1..p_del_count LOOP
            DBMS_SQL.BIND_VARIABLE(l_sqlcursor,'B_DELINQUENCY_ID_'||i, p_filter_id);
          END LOOP;

          l_dummy := DBMS_SQL.EXECUTE(l_sqlcursor);

          DBMS_SQL.VARIABLE_VALUE_CHAR(l_sqlcursor, 'l_result', l_value);
          x_metric_value := RTRIM(l_value, ' ');


        EXCEPTION
          WHEN OTHERS THEN
            x_return_status := 'E';
            x_metric_value := iex_utilities.get_lookup_meaning('IEX_METRIC_STATUS', 'NA');
            fnd_message.set_name ('IEX', 'JTF_CHK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            fnd_msg_pub.add;
        END;
        DBMS_SQL.CLOSE_CURSOR(l_sqlcursor);
      ELSE
        LOOP
          l_start := NVL(INSTRB(l_str,':',1,1),0);
          IF l_start > 0 THEN
            l_str2 := SUBSTRB(l_str,INSTRB(l_str,':',1,1),(INSTRB(UPPER(l_str),'_ID',INSTRB(l_str,':',1,1),1)+2-INSTRB(l_str,':',1,1)+1));
            IF UPPER(l_str2) = ':PARTY_ID' THEN
              l_party_count := l_party_count + 1;
              l_str2 := ':B_PARTY_ID_' || l_party_count;
            ELSIF UPPER(l_str2) = ':CUST_ACCOUNT_ID' THEN
              l_acc_count := l_acc_count + 1;
              l_str2 := ':B_CUST_ACCOUNT_ID_' || l_acc_count;
            ELSIF UPPER(l_str2) = ':CUSTOMER_SITE_USE_ID' THEN
              l_billto_count := l_billto_count + 1;
              l_str2 := ':B_CUSTOMER_SITE_USE_ID_' || l_billto_count;
            ELSIF UPPER(l_str2) = ':DELINQUENCY_ID' THEN
              p_del_count := p_del_count + 1;
              l_str2 := ':B_DELINQUENCY_ID_' || p_del_count;
            END IF;
            l_str_result := l_str_result || SUBSTRB(l_str, 1, INSTRB(l_str,':',1,1)-1) || l_str2;

            l_str := SUBSTRB(l_str, INSTRB(UPPER(l_str),'_ID',INSTRB(l_str,':',1,1),1)+3);
          ELSE
            l_str_result := l_str_result || l_str;
          END IF;
          EXIT WHEN l_start < 1;
        END LOOP;


        l_sqlcursor := DBMS_SQL.OPEN_CURSOR;

        BEGIN
          DBMS_SQL.PARSE(l_sqlcursor, l_str_result, 1);
          DBMS_SQL.DEFINE_COLUMN(l_sqlcursor, 1, l_value, 200);

          FOR i IN 1..l_party_count LOOP
            DBMS_SQL.BIND_VARIABLE(l_sqlcursor,'B_PARTY_ID_'||i, p_filter_id);
          END LOOP;

          FOR i IN 1..l_acc_count LOOP
            DBMS_SQL.BIND_VARIABLE(l_sqlcursor,'B_CUST_ACCOUNT_ID_'||i, p_filter_id);
          END LOOP;

          FOR i IN 1..l_billto_count LOOP
            DBMS_SQL.BIND_VARIABLE(l_sqlcursor,'B_CUSTOMER_SITE_USE_ID_'||i, p_filter_id);
          END LOOP;

          FOR i IN 1..p_del_count LOOP
            DBMS_SQL.BIND_VARIABLE(l_sqlcursor,'B_DELINQUENCY_ID_'||i, p_filter_id);
          END LOOP;

          l_dummy := DBMS_SQL.EXECUTE(l_sqlcursor);

          IF DBMS_SQL.FETCH_ROWS(l_sqlcursor) > 0 THEN
            DBMS_SQL.COLUMN_VALUE(l_sqlcursor,1,l_value);
          END IF;

          x_metric_value := l_value;

        EXCEPTION
          WHEN OTHERS THEN
            x_return_status := 'E';
            x_metric_value := iex_utilities.get_lookup_meaning('IEX_METRIC_STATUS', 'NA');
            fnd_message.set_name ('IEX', 'IEX_METRIC_SQL_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            fnd_msg_pub.add;
        END;
        DBMS_SQL.CLOSE_CURSOR(l_sqlcursor);
      END IF;
    END IF;
    CLOSE c_metric;

  END Test_Metric;
BEGIN
  --Strat MOAC
  --Replaced view gl_sets_of_books with gl_ledgers_public_v
  --Begin bug#5208170 schekuri 29-May-2006
  --Removed this because it's not being used anywhere
  /*SELECT gll.currency_code,
         c.precision,
         c.minimum_accountable_unit
    INTO   g_curr_rec.base_currency,
           g_curr_rec.base_precision,
           g_curr_rec.base_min_acc_unit
    FROM   ar_system_parameters   sysp,
           gl_ledgers_public_v    gll,
           fnd_currencies     c
   WHERE  gll.ledger_id = sysp.set_of_books_id
     AND    gll.currency_code   = c.currency_code;*/
 --End bug#5208170 schekuri 29-May-2006
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
     AND    sob.currency_code   = c.currency_code;*/
   --End MOAC

  -- Past Year From and To
  --Begin bug#5208170 schekuri 29-May-2006
  --Removed this because it's not being used anywhere
 /* SELECT  TRUNC(add_months(sysdate, - 12)) pastYearFrom ,
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
