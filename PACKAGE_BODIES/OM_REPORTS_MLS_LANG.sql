--------------------------------------------------------
--  DDL for Package Body OM_REPORTS_MLS_LANG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OM_REPORTS_MLS_LANG" AS
/* $Header: OEXOEAMB.pls 120.0 2005/06/01 01:54:52 appldev noship $ */

FUNCTION GET_LANG RETURN VARCHAR2 IS
  p_order_number_lo             NUMBER := NULL;
  p_order_number_hi             NUMBER := NULL;
  p_order_date_lo		DATE	:= NULL	;
  p_order_date_hi		DATE	:= NULL	;
  p_schedule_date_lo		DATE	:= NULL	;
  p_schedule_date_hi		DATE	:= NULL	;
  p_request_date_lo		DATE	:= NULL	;
  p_request_date_hi		DATE	:= NULL	;
  p_promise_date_lo		DATE	:= NULL	;
  p_promise_date_hi		DATE	:= NULL	;
  p_bill_to_customer_name_lo 	VARCHAR2(50) 	:= NULL;
  p_bill_to_customer_name_hi 	VARCHAR2(50) 	:= NULL;
  p_ship_to_customer_name_lo 	VARCHAR2(50) 	:= NULL;
  p_ship_to_customer_name_hi 	VARCHAR2(50) 	:= NULL;
  p_del_to_customer_name_lo 	VARCHAR2(50) 	:= NULL;
  p_del_to_customer_name_hi 	VARCHAR2(50) 	:= NULL;
  p_salesrep			VARCHAR2(50) 	:= NULL;
  p_created_by			VARCHAR2(50)	:= NULL;
  p_open_flag 			VARCHAR2(1) 	:= NULL;
  p_booked_status 		VARCHAR2(50) 	:= NULL;
  p_order_type  		NUMBER 		:= NULL;

  ret_val 			NUMBER		:= NULL;
  parm_number 			NUMBER		;
  v_select_statement 		VARCHAR2(4000)	;
  v_select_statement1 		VARCHAR2(2000)	;
  v_select_statement2 		VARCHAR2(2000)	;
  v_select_statement3 		VARCHAR2(2000)	;
  v_select_statement4 		VARCHAR2(2000)	;
  v_select_statement5 		VARCHAR2(2000)	;
  v_select_statement6 		VARCHAR2(2000)	;
  l_cursor_id 			INTEGER		;
  lang_string 			VARCHAR2(240)	:= NULL;
  l_lang 			VARCHAR2(30)	;
  l_lang_str 			VARCHAR2(500)	:= NULL;
  l_base_lang 			VARCHAR2(30)	;
  l_dummy 			INTEGER		;

BEGIN

  -- ORDER NUMBER (From)
  ret_val := FND_REQUEST_INFO.GET_PARAM_NUMBER('Order Number (From)', parm_number
);

  IF (ret_val = -1) THEN
     p_order_number_lo := NULL;
  ELSE
     p_order_number_lo := TO_NUMBER(FND_REQUEST_INFO.GET_PARAMETER(parm_number))
;

  END IF;

  -- ORDER NUMBER (To)
  ret_val := FND_REQUEST_INFO.GET_PARAM_NUMBER('Order Number (To)', parm_number);

  IF (ret_val = -1) THEN
     p_order_number_hi := NULL;
  ELSE
     p_order_number_hi := TO_NUMBER(FND_REQUEST_INFO.GET_PARAMETER(parm_number))
;

  END IF;

  -- ORDER DATE(From)
  ret_val := FND_REQUEST_INFO.GET_PARAM_NUMBER('Order Date (From)', parm_number);


  IF (ret_val = -1) THEN
     p_order_date_lo := NULL;
  ELSE
     p_order_date_lo := FND_DATE.CANONICAL_TO_DATE(FND_REQUEST_INFO.GET_PARAMETER
(parm_number));

  END IF;

  -- ORDER DATE To
  ret_val := FND_REQUEST_INFO.GET_PARAM_NUMBER('Order Date (To)', parm_number)
;

  IF (ret_val = -1) THEN
     p_order_date_hi := NULL;
  ELSE
     p_order_date_hi := FND_DATE.CANONICAL_TO_DATE(FND_REQUEST_INFO.GET_PARAMETER
(parm_number));

  END IF;


  --SCHEDULE DATE(From)
  ret_val := FND_REQUEST_INFO.GET_PARAM_NUMBER('Schedule Date (From)', parm_number);


  IF (ret_val = -1) THEN
     p_schedule_date_lo := NULL;
  ELSE
     p_schedule_date_lo := FND_DATE.CANONICAL_TO_DATE(FND_REQUEST_INFO.GET_PARAMETER(parm_number));

  END IF;

  -- SCHEDULE DATE To
  ret_val := FND_REQUEST_INFO.GET_PARAM_NUMBER('Schedule Date (To)', parm_number)
;

  IF (ret_val = -1) THEN
     p_schedule_date_hi := NULL;
  ELSE
     p_schedule_date_hi := FND_DATE.CANONICAL_TO_DATE(FND_REQUEST_INFO.GET_PARAMETER(parm_number));

  END IF;

  -- PROMISE DATE(From)
  ret_val := FND_REQUEST_INFO.GET_PARAM_NUMBER('Promise Date (From)', parm_number);


  IF (ret_val = -1) THEN
     p_promise_date_lo := NULL;
  ELSE
     p_promise_date_lo := FND_DATE.CANONICAL_TO_DATE(FND_REQUEST_INFO.GET_PARAMETER(parm_number));

  END IF;

  -- PROMISE DATE To
  ret_val := FND_REQUEST_INFO.GET_PARAM_NUMBER('Promise Date (To)', parm_number)
;

  IF (ret_val = -1) THEN
     p_promise_date_hi := NULL;
  ELSE
     p_promise_date_hi := FND_DATE.CANONICAL_TO_DATE(FND_REQUEST_INFO.GET_PARAMETER(parm_number));

  END IF;

  --REQUEST DATE(From)
  ret_val := FND_REQUEST_INFO.GET_PARAM_NUMBER('Request Date (From)', parm_number);


  IF (ret_val = -1) THEN
     p_request_date_lo := NULL;
  ELSE
     p_request_date_lo := FND_DATE.CANONICAL_TO_DATE(FND_REQUEST_INFO.GET_PARAMETER(parm_number));

  END IF;

  -- REQUEST DATE To
  ret_val := FND_REQUEST_INFO.GET_PARAM_NUMBER('Request Date (To)', parm_number)
;

  IF (ret_val = -1) THEN
     p_request_date_hi := NULL;
  ELSE
     p_request_date_hi := FND_DATE.CANONICAL_TO_DATE(FND_REQUEST_INFO.GET_PARAMETER(parm_number));

  END IF;

  -- BILL TO CUSTOMER NAME(From)
  ret_val := FND_REQUEST_INFO.GET_PARAM_NUMBER('Bill To Customer Name (From)', parm_number);

  IF (ret_val = -1) THEN
     p_bill_to_customer_name_lo := NULL;
  ELSE
     p_bill_to_customer_name_lo := FND_REQUEST_INFO.GET_PARAMETER(parm_number);
  END IF;

  -- BILL TO CUSTOMER NAME To
  ret_val := FND_REQUEST_INFO.GET_PARAM_NUMBER('Bill To Customer Name (To)', parm_number);

  IF (ret_val = -1) THEN
     p_bill_to_customer_name_hi := NULL;
  ELSE
     p_bill_to_customer_name_hi := FND_REQUEST_INFO.GET_PARAMETER(parm_number);
  END IF;

  -- SHIP TO CUSTOMER NAME(From)
  ret_val := FND_REQUEST_INFO.GET_PARAM_NUMBER('Ship To Customer Name (From)', parm_number);

  IF (ret_val = -1) THEN
     p_ship_to_customer_name_lo := NULL;
  ELSE
     p_ship_to_customer_name_lo := FND_REQUEST_INFO.GET_PARAMETER(parm_number);
  END IF;

  -- SHIP TO CUSTOMER NAME To
  ret_val := FND_REQUEST_INFO.GET_PARAM_NUMBER('Ship To Customer Name (To)', parm_number);

  IF (ret_val = -1) THEN
     p_ship_to_customer_name_hi := NULL;
  ELSE
     p_ship_to_customer_name_hi := FND_REQUEST_INFO.GET_PARAMETER(parm_number);
  END IF;


  -- Deliver TO CUSTOMER NAME(From)
  ret_val := FND_REQUEST_INFO.GET_PARAM_NUMBER('Deliver To Customer (From)', parm_number);

  IF (ret_val = -1) THEN
     p_del_to_customer_name_lo := NULL;
  ELSE
     p_del_to_customer_name_lo := FND_REQUEST_INFO.GET_PARAMETER(parm_number);
  END IF;

  -- DELIVER TO CUSTOMER NAME To
  ret_val := FND_REQUEST_INFO.GET_PARAM_NUMBER('Deliver To Customer (To)', parm_number);

  IF (ret_val = -1) THEN
     p_del_to_customer_name_hi := NULL;
  ELSE
     p_del_to_customer_name_hi := FND_REQUEST_INFO.GET_PARAMETER(parm_number);
  END IF;


  -- Order Type
  ret_val := FND_REQUEST_INFO.GET_PARAM_NUMBER('Order Type', parm_number);


  IF (ret_val = -1) THEN
     p_order_type := NULL;
  ELSE
     p_order_type := FND_REQUEST_INFO.GET_PARAMETER(parm_number);

  END IF;


  -- Salesperson
  ret_val := FND_REQUEST_INFO.GET_PARAM_NUMBER('Salesperson', parm_number);


  IF (ret_val = -1) THEN
     p_salesrep := NULL;
  ELSE
     p_salesrep := FND_REQUEST_INFO.GET_PARAMETER(parm_number);

  END IF;

  -- Open Orders
  ret_val := FND_REQUEST_INFO.GET_PARAM_NUMBER('Open Orders Only', parm_number);


  IF (ret_val = -1) THEN
     p_open_flag := NULL;
  ELSE
     p_open_flag := FND_REQUEST_INFO.GET_PARAMETER(parm_number);

  END IF;

  -- Booked Status
  ret_val := FND_REQUEST_INFO.GET_PARAM_NUMBER('Booked Status', parm_number);


  IF (ret_val = -1) THEN
     p_booked_status := NULL;
  ELSE
     p_booked_status := FND_REQUEST_INFO.GET_PARAMETER(parm_number);

  END IF;

  -- Created By
  ret_val := FND_REQUEST_INFO.GET_PARAM_NUMBER('Created By', parm_number);


  IF (ret_val = -1) THEN
     p_created_by := NULL;
  ELSE
     p_created_by := FND_REQUEST_INFO.GET_PARAMETER(parm_number);

  END IF;

--Get Base Language

  SELECT language_code INTO l_base_lang FROM fnd_languages
  WHERE installed_flag = 'B';

--Create a query string to get languages based on parameters.


v_select_statement1 :=
'select DISTINCT loc.language from      oe_order_headers_all h, oe_order_lines_all l, hz_cust_accounts bill_cust, hz_cust_accounts ship_cust, hz_cust_accounts del_cust, hz_cust_site_uses bill_su, hz_parties bill_p, hz_parties ship_p, hz_parties del_p,';

v_select_statement2 := ' hz_cust_site_uses ship_su, hz_cust_site_uses del_su,hz_cust_acct_sites a, hz_cust_acct_sites bill_addr, hz_cust_acct_sites ship_addr, hz_cust_acct_sites del_addr, ra_salesreps sr, fnd_user u, hz_party_sites ps, hz_locations loc';

-- Changes are made as a part of bug # 	4221221
-- Removed the conditions l.item_type_code(+) != ''INCLUDED'' and h.cancelled_flag is null
-- These conditions are not required here

v_select_statement3 :=
' where h.header_id = l.header_id(+) and    h.salesrep_id = sr.salesrep_id (+) and    u.user_id = h.created_by';

/* ' where  h.cancelled_flag is null and h.header_id = l.header_id(+) and    l.item_type_code(+) != ''INCLUDED'' and    h.salesrep_id = sr.salesrep_id (+) and    u.user_id = h.created_by';*/

v_select_statement4 := ' and    h.ship_to_org_id = ship_su.site_use_id(+) and    ship_su.cust_acct_site_id    = ship_addr.cust_acct_site_id(+) and    ship_addr.cust_account_id = ship_cust.cust_account_id(+) ';

v_select_statement5 :=
'and    h.invoice_to_org_id = bill_su.site_use_id(+) and    bill_su.cust_acct_site_id       = bill_addr.cust_acct_site_id(+) and    bill_addr.cust_account_id    = bill_cust.cust_account_id(+) and    h.deliver_to_org_id = del_su.site_use_id(+) and ';

v_select_statement6 := ' del_su.cust_acct_site_id = del_addr.cust_acct_site_id(+) and del_addr.cust_account_id = del_cust.cust_account_id(+) and  (h.invoice_to_org_id is not null or h.ship_to_org_id is not null) and a.cust_account_id = h.sold_to_org_id';
v_select_statement6 := v_select_statement6 || ' and bill_cust.party_id = bill_p.party_id and ship_cust.party_id = ship_p.party_id and del_cust.party_id = del_p.party_id and a.party_site_id = ps.party_site_id and ps.location_id = loc.location_id';

 v_select_statement := v_select_statement1 || v_select_statement2 || v_select_statement3 || v_select_statement4 || v_select_statement5 || v_select_statement6;

  IF p_order_number_lo IS NOT NULL OR p_order_number_hi IS NOT NULL THEN
     IF p_order_number_lo IS NULL THEN
        v_select_statement := v_select_statement||' AND h.order_number <= :p_order_number_hi';

     ELSIF p_order_number_hi IS NULL THEN
        v_select_statement := v_select_statement||' AND h.order_number >= :p_order_number_lo';

     ELSE
        v_select_statement := v_select_statement||' AND h.order_number BETWEEN :p_order_number_lo AND :p_order_number_hi';

     END IF;
  END IF;

  IF p_order_date_lo IS NOT NULL OR p_order_date_hi IS NOT NULL THEN
     IF p_order_date_lo IS NULL THEN
        v_select_statement := v_select_statement||' AND h.ordered_date <= :p_order_date_hi';

     ELSIF p_order_date_hi IS NULL THEN
        v_select_statement := v_select_statement||' AND h.ordered_date >= :p_order_date_lo';

     ELSE
        v_select_statement := v_select_statement||' AND h.ordered_date BETWEEN :p_order_date_lo AND :p_order_date_hi';

     END IF;
  END IF;

  IF p_schedule_date_lo IS NOT NULL OR p_schedule_date_hi IS NOT NULL THEN
     IF p_schedule_date_lo IS NULL THEN
        v_select_statement := v_select_statement||' AND l.schedule_ship_date <= :p_schedule_date_hi';

     ELSIF p_schedule_date_hi IS NULL THEN
        v_select_statement := v_select_statement||' AND l.schedule_ship_date >= :p_schedule_date_lo';

     ELSE
        v_select_statement := v_select_statement||' AND l.schedule_ship_date BETWEEN :p_schedule_date_lo AND :p_schedule_date_hi';

     END IF;
  END IF;

IF p_promise_date_lo IS NOT NULL OR p_promise_date_hi IS NOT NULL THEN
     IF p_promise_date_lo IS NULL THEN
        v_select_statement := v_select_statement||' AND l.promise_date <= :p_promise_date_hi';

     ELSIF p_promise_date_hi IS NULL THEN
        v_select_statement := v_select_statement||' AND l.promise_date >= :p_promise_date_lo';

     ELSE
        v_select_statement := v_select_statement||' AND l.promise_date BETWEEN :p_promise_date_lo AND :p_promise_date_hi';

     END IF;
  END IF;

IF p_request_date_lo IS NOT NULL OR p_request_date_hi IS NOT NULL THEN
     IF p_request_date_lo IS NULL THEN
       v_select_statement := v_select_statement||' AND l.request_date <= :p_request_date_hi';

     ELSIF p_request_date_hi IS NULL THEN
        v_select_statement := v_select_statement||' AND l.request_date >= :p_request_date_lo';

     ELSE
        v_select_statement := v_select_statement||' AND l.request_date BETWEEN :p_request_date_lo AND :p_request_date_hi';

     END IF;
  END IF;


  IF p_bill_to_customer_name_lo IS NOT NULL OR p_bill_to_customer_name_hi IS NOT
 NULL THEN

     IF p_bill_to_customer_name_lo IS NULL THEN
        v_select_statement := v_select_statement||' AND bill_p.party_name <= :p_bill_to_customer_name_hi';

     ELSIF p_bill_to_customer_name_hi IS NULL THEN
        v_select_statement := v_select_statement||' AND bill_p.party_name >= :p_bill_to_customer_name_lo';

     ELSE
        v_select_statement := v_select_statement||' AND bill_p.party_name BETWEEN :p_bill_to_customer_name_lo AND :p_bill_to_customer_name_hi';

     END IF;
  END IF;

  IF p_ship_to_customer_name_lo IS NOT NULL OR p_ship_to_customer_name_hi IS NOT
 NULL THEN
     IF p_ship_to_customer_name_lo IS NULL THEN
        v_select_statement := v_select_statement||' AND ship_p.party_name <= :p_ship_to_customer_name_hi';

     ELSIF p_ship_to_customer_name_hi IS NULL THEN
        v_select_statement := v_select_statement||' AND ship_p.party_name >= :p_ship_to_customer_name_lo';

     ELSE
        v_select_statement := v_select_statement||' AND ship_p.party_name BETWEEN :p_ship_to_customer_name_lo AND :p_ship_to_customer_name_hi';

     END IF;
  END IF;


  IF p_del_to_customer_name_lo IS NOT NULL OR p_del_to_customer_name_hi IS NOT NULL THEN
     IF p_del_to_customer_name_lo IS NULL THEN
        v_select_statement := v_select_statement||' AND del_p.party_name <= :p_del_to_customer_name_hi';

     ELSIF p_del_to_customer_name_hi IS NULL THEN
        v_select_statement := v_select_statement||' AND del_p.party_name >= :p_del_to_customer_name_lo';

     ELSE
        v_select_statement := v_select_statement||' AND del_p.party_name BETWEEN :p_del_to_customer_name_lo AND :p_del_to_customer_name_hi';
     END IF;
  END IF;

     IF p_order_type IS NOT NULL THEN
        v_select_statement := v_select_statement||' AND h.order_type_id = :p_order_type';
     END IF;

     IF p_booked_status IS NOT NULL THEN
         IF  substr(upper(p_booked_status),1,1) = 'Y' THEN
	    v_select_statement := v_select_statement || ' AND h.booked_flag = ''Y''';     ELSE
	    v_select_statement := v_select_statement || ' AND h.booked_flag = ''N''';
         END IF;
     END IF;

     IF p_open_flag IS NOT NULL THEN
         IF  substr(upper(p_open_flag),1,1) = 'Y' THEN
	    v_select_statement := v_select_statement || ' AND h.open_flag = ''Y''';     ELSE
	    v_select_statement := v_select_statement || ' AND h.open_flag = ''N''';
         END IF;
     END IF;

     IF p_salesrep IS NOT NULL THEN
        v_select_statement := v_select_statement||' AND sr.name = :p_salesrep';
     END IF;

     IF p_created_by IS NOT NULL THEN
        v_select_statement := v_select_statement||' AND u.user_name = :p_created_by';
     END IF;

  l_cursor_id := DBMS_SQL.OPEN_CURSOR;

  DBMS_SQL.PARSE(l_cursor_id, v_select_statement, DBMS_SQL.V7);

  IF p_order_number_lo IS NOT NULL THEN
     DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_order_number_lo', p_order_number_lo);
  END IF;

  IF p_order_number_hi IS NOT NULL THEN
     DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_order_number_hi', p_order_number_hi);
  END IF;

  IF p_bill_to_customer_name_lo IS NOT NULL THEN
     DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_bill_to_customer_name_lo',
	p_bill_to_customer_name_lo);
  END IF;

  IF p_bill_to_customer_name_hi IS NOT NULL THEN
     DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_bill_to_customer_name_hi',
	p_bill_to_customer_name_hi);
  END IF;

  IF p_ship_to_customer_name_lo IS NOT NULL THEN
     DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_ship_to_customer_name_lo',
	p_ship_to_customer_name_lo);
  END IF;

  IF p_ship_to_customer_name_hi IS NOT NULL THEN
     DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_ship_to_customer_name_hi',
	p_ship_to_customer_name_hi);
  END IF;

  IF p_del_to_customer_name_lo IS NOT NULL THEN
     DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_del_to_customer_name_lo',
	p_del_to_customer_name_lo);
  END IF;

  IF p_del_to_customer_name_hi IS NOT NULL THEN
     DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_del_to_customer_name_hi',
	p_del_to_customer_name_hi);
  END IF;

  IF p_order_date_lo IS NOT NULL THEN
     DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_order_date_lo',
       p_order_date_lo);
  END IF;

  IF p_order_date_hi IS NOT NULL THEN
     DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_order_date_hi',
       p_order_date_hi);
  END IF;

  IF p_schedule_date_lo IS NOT NULL THEN
     DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_schedule_date_lo',
       p_schedule_date_lo);
  END IF;

  IF p_schedule_date_hi IS NOT NULL THEN
     DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_schedule_date_hi',
       p_schedule_date_hi);
  END IF;

  IF p_request_date_lo IS NOT NULL THEN
     DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_request_date_lo',
       p_request_date_lo);
  END IF;

  IF p_request_date_hi IS NOT NULL THEN
     DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_request_date_hi',
       p_request_date_hi);
  END IF;

  IF p_promise_date_lo IS NOT NULL THEN
     DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_promise_date_lo',
       p_promise_date_lo);
  END IF;

  IF p_promise_date_hi IS NOT NULL THEN
     DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_promise_date_hi',
       p_promise_date_hi);
  END IF;

  IF p_order_type IS NOT NULL THEN
     DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_order_type',
       p_order_type);
  END IF;

  IF p_salesrep IS NOT NULL THEN
     DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_salesrep',
       p_salesrep);
  END IF;

  IF p_created_by IS NOT NULL THEN
     DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_created_by',
       p_created_by);
  END IF;

  DBMS_SQL.DEFINE_COLUMN(l_cursor_id,1,l_lang,30);

  l_dummy := DBMS_SQL.EXECUTE(l_cursor_id);

  LOOP
    IF DBMS_SQL.FETCH_ROWS(l_cursor_id) = 0 THEN
       EXIT;
    END IF;
    DBMS_SQL.COLUMN_VALUE(l_cursor_id, 1, l_lang);

    IF (l_lang IS NOT NULL) THEN
       IF (l_lang_str IS NULL) THEN
          l_lang_str := l_lang;
       ELSE
          l_lang_str := l_lang_str||','||l_lang;
       END IF;
    END IF;
      /* IF (l_lang_str IS NULL) THEN
          l_lang_str := l_base_lang;
       ELSE
          IF instr(l_lang_str, l_lang) = 0 THEN
             l_lang_str := l_lang_str||','||l_base_lang;
          END IF;
       END IF;*/

  END LOOP;

  DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
  IF (l_lang_str IS NULL) THEN
     l_lang_str := l_base_lang;
  ELSE
     IF instr(l_lang_str, l_lang) = 0 THEN
        l_lang_str := l_lang_str||','||l_base_lang;
     END IF;
  END IF;
  return (l_lang_str);

  EXCEPTION
     WHEN OTHERS THEN
          DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
     RAISE;
END GET_LANG;

END OM_REPORTS_MLS_LANG;

/
