--------------------------------------------------------
--  DDL for Package Body OE_CREDIT_CHECK_RPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CREDIT_CHECK_RPT" AS
-- $Header: OEXRCRCB.pls 120.8 2006/06/30 21:52:34 spooruli noship $
--==============================================================
-- TYPE DECLARATIONS
--==============================================================

--==============================================================
-- CONSTANTS
--==============================================================
  --Global constant holding the package name
  G_PKG_NAME   CONSTANT VARCHAR2(30) := 'OE_CREDIT_CREDIT_RPT';

--==============================================================
-- PUBLIC VARIABLES
--==============================================================
  p_gl_currency_code    VARCHAR2(30) :=  OE_CREDIT_CHECK_UTIL.GET_GL_CURRENCY;

--==============================================================
-- PROCEDURES AND FUNCTIONS
--==============================================================

--=====================================================================
-- PROCEDURE:   Insert_In_Temp_Table
-- DESCRIPTION: Insert a row into the temporary table
--=====================================================================
PROCEDURE Insert_In_Temp_Table
  ( p_header_id		IN NUMBER
   ,p_credit_status     IN VARCHAR2
  )
IS
  l_party_name VARCHAR2(50);
  l_account_number VARCHAR2(30);
  l_transaction_type_name VARCHAR2(30);
  l_credit_status  VARCHAR2(80);
  l_credit_status_sort NUMBER;
  l_header_rec OE_Order_PUB.Header_Rec_Type;

BEGIN
  OE_DEBUG_PUB.ADD('IN  OEXRCRCB: Insert_In_Temp_Table');
  --
  -- Get order header record
  --
  OE_Header_UTIL.Query_Row
     (p_header_id            => p_header_id
     ,x_header_rec           => l_header_rec
     );
  --
  BEGIN
    SELECT SUBSTRB(HP.PARTY_NAME,1,50) NAME,
           HCA.ACCOUNT_NUMBER
    INTO   l_party_name,
           l_account_number
    FROM   HZ_CUST_ACCOUNTS HCA,
           HZ_PARTIES HP
    WHERE  HCA.PARTY_ID = HP.PARTY_ID
    AND    HCA.CUST_ACCOUNT_ID = l_header_rec.sold_to_org_id;
    OE_DEBUG_PUB.ADD('Customer Name/Number = '||l_party_name||'/'||l_account_number);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      OE_DEBUG_PUB.ADD('Custoner Name/Number not found for header_id '||p_header_id);
  END;

  BEGIN
    SELECT otv.name
    INTO   l_transaction_type_name
    FROM   oe_transaction_types_vl otv
    WHERE  l_header_rec.order_type_id = otv.transaction_type_id;
    OE_DEBUG_PUB.ADD('Order Type           = '||l_transaction_type_name);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      OE_DEBUG_PUB.ADD('Order Type not found for header_id '||p_header_id);
  END;

    IF p_credit_status = 'PASS' THEN
      l_credit_status_sort := 30;
    ELSIF p_credit_status = 'FAIL' THEN
      l_credit_status_sort := 20;
    ELSE
      l_credit_status_sort := 10;
    END IF;

  BEGIN
    SELECT meaning
    INTO   l_credit_status
    FROM   oe_lookups
    WHERE  lookup_code = p_credit_status
    AND    lookup_type = 'CREDIT_CHECK_STATUS';
    OE_DEBUG_PUB.ADD('Order Credit Status  = '||l_credit_status);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      OE_DEBUG_PUB.ADD('Credit status not found for lookup_code '||p_credit_status);
  END;

  INSERT INTO OE_CC_PROCESSOR_TEMP (
    PARTY_NAME
   ,ACCOUNT_NUMBER
   ,TRANSACTION_TYPE_NAME
   ,ORDER_NUMBER
   ,CREDIT_STATUS
   ,CREDIT_STATUS_SORT
  )
  VALUES (
    l_party_name
   ,l_account_number
   ,l_transaction_type_name
   ,l_header_rec.order_number
   ,l_credit_status
   ,l_credit_status_sort
  );
  OE_DEBUG_PUB.ADD('Inserted row into temporary table ');
  OE_DEBUG_PUB.ADD('OUT OEXRCRCB: Insert_In_Temp_Table');
EXCEPTION
  WHEN OTHERS THEN
    OE_DEBUG_PUB.ADD('OEXRCRCB: Insert_In_Temp_Table - Unexpected Error');
    RAISE;
END Insert_In_Temp_Table;

--=====================================================================
--PROCEDURE:   Credit_Check_Processor                   PUBLIC
--
-- COMMENT   : This is the pl/sql procedure for Credit Check Processor concurrent
--             program that perform credit check for a batch of sales orders.
--             It checks an order based on header id.
--             If header_id is NULL, it processes all the orders for a range of
--             profile classes, customer names, customer numbers, order dates
--             If all the parameters are NULL it picks up all order headers
--             of the profile organization [MO:Operating Unit]
--=====================================================================

PROCEDURE Credit_Check_Processor
  ( p_profile_org_id             IN NUMBER	DEFAULT NULL
  , p_cust_prof_class_name_from	 IN VARCHAR2 	DEFAULT NULL
  , p_cust_prof_class_name_to    IN VARCHAR2	DEFAULT NULL
  , p_party_name_from   	 IN VARCHAR2	DEFAULT NULL
  , p_party_name_to  	    	 IN VARCHAR2	DEFAULT NULL
  , p_cust_acct_number_from   	 IN VARCHAR2	DEFAULT NULL
  , p_cust_acct_number_to     	 IN VARCHAR2	DEFAULT NULL
  , p_order_date_from            IN DATE	DEFAULT NULL
  , p_order_date_to              IN DATE	DEFAULT NULL
  , p_header_id               	 IN NUMBER	DEFAULT NULL
  , p_order_by   		 IN VARCHAR2
  )
IS
  --================================
  --API Name And Version
  --================================
  l_api_name          CONSTANT VARCHAR2(30) := 'Credit_Check_Processor';
  l_api_version       CONSTANT NUMBER := 1.0;

  --================================
  --Variable and Cursor Declarations
  --================================

  l_msg_count          NUMBER        := 0 ;
  l_msg_data           VARCHAR2(2000):= NULL ;
  l_result_out         VARCHAR2(30)  := NULL ;
  l_return_status      VARCHAR2(30)  := FND_API.G_RET_STS_SUCCESS ;
  l_cc_limit_used      VARCHAR2(30)  := NULL ;
  l_cc_profile_used    VARCHAR2(30)  := NULL ;
  l_count              NUMBER        := 0;
  l_cc_hold_comment    VARCHAR2(2000):= NULL;
  l_profile_org_id     NUMBER;

  --variables for dynamic sql query
  v_hold_cursorID	 NUMBER;
  v_hold_final_select    VARCHAR2(7000) := NULL;

  v_release_cursorID     NUMBER;
  v_release_final_select VARCHAR2(7000) := NULL;

  v_dummy	         NUMBER;

  v_order_by_clause      VARCHAR2(1000) := NULL;
  v_cust_prof_class_clause       VARCHAR2(1000);
  v_party_name_clause            VARCHAR2(1000);
  v_cust_acct_number_clause      VARCHAR2(1000);
  v_order_date_clause            VARCHAR2(1000);

  --Variables for input of dynamic sql
  profile_org_id          NUMBER;
  cust_prof_class_from    HZ_CUST_PROFILE_CLASSES.name%TYPE;
  cust_prof_class_to      HZ_CUST_PROFILE_CLASSES.name%TYPE;
  party_name_from         HZ_PARTIES.party_name%TYPE;
  party_name_to           HZ_PARTIES.party_name%TYPE;
  cust_acct_number_from   HZ_CUST_ACCOUNTS_ALL.account_number%TYPE;
  cust_acct_number_to     HZ_CUST_ACCOUNTS_ALL.account_number%TYPE;
  order_date_from         DATE;
  order_date_to           DATE;
  gl_currency_code        FND_CURRENCIES.currency_code%TYPE;

  --Variables for output of dynamic sql
  f_hold_header_id        NUMBER;
  f_release_header_id     NUMBER;

  -- MOAC start
  CURSOR l_secured_ou_cur IS
    SELECT ou.organization_id
      FROM hr_operating_units ou
     WHERE mo_global.check_access(ou.organization_id) = 'Y';

  l_debug_level           CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  -- MOAC end

BEGIN
  OE_DEBUG_PUB.ADD('IN  OEXRCRCB: Credit_Check_Processor',1);
  OE_DEBUG_PUB.ADD ('Input Parameters:',1);
  OE_DEBUG_PUB.ADD ('p_profile_org_id            = '||to_char(p_profile_org_id),1);
  OE_DEBUG_PUB.ADD ('p_cust_prof_class_name_from = '||p_cust_prof_class_name_from,1);
  OE_DEBUG_PUB.ADD ('p_cust_prof_class_name_to   = '||p_cust_prof_class_name_to,1);
  OE_DEBUG_PUB.ADD ('p_party_name_from           = '||p_party_name_from,1);
  OE_DEBUG_PUB.ADD ('p_party_name_to             = '||p_party_name_to,1);
  OE_DEBUG_PUB.ADD ('p_cust_acct_number_from     = '||p_cust_acct_number_from,1);
  OE_DEBUG_PUB.ADD ('p_cust_acct_number_to       = '||p_cust_acct_number_to,1);
  OE_DEBUG_PUB.ADD ('p_order_date_from           = '||fnd_date.date_to_chardate(p_order_date_from),1);
  OE_DEBUG_PUB.ADD ('p_order_date_To             = '||fnd_date.date_to_chardate(p_order_date_to),1);
  OE_DEBUG_PUB.ADD ('p_header_id                 = '||p_header_id,1);
  OE_DEBUG_PUB.ADD ('p_order_by                  = '||p_order_by,1);

  -- If a header_id is not provided, there is a possibility that more than one orders need
  -- to be credit check, so the cursor needs to be built with the appropriate sorting.
  -- This is done using dynamic sql.
  -- If a header_id is provided, check credit for the combination of parameters provided.
  -- For example:  If an order number is provided and a customer range is provided, the
  --               program will ensure that the order has the sold to org at the header is
  --               within the customer range provided.

  IF p_header_id is NULL OR p_header_id = 0 THEN
    OE_DEBUG_PUB.ADD('Building the SELECT statement',2);
    --
    -- Build the sorting clause of the select statement
    --
    IF p_order_by = 'EARLIEST_ORDER_DATE' THEN
       v_order_by_clause := 'ORDER BY OH.ordered_date';
    ELSIF p_order_by = 'GREATEST_ORDER_VALUE' THEN
       v_order_by_clause :=
         'ORDER BY DECODE(OH.transactional_curr_code, :gl_currency_code,
                   oe_oe_totals_summary.prt_order_total(OH.header_id),
                   gl_currency_api.convert_closest_amount_sql(
                     OH.transactional_curr_code,
                     :gl_currency_code,
                     DECODE(OH.conversion_rate_date, NULL,SYSDATE,OH.conversion_rate_date),
                     DECODE(OH.conversion_type_code, NULL,''Corporate'',OH.conversion_type_code),
                     OH.conversion_rate,
                     oe_oe_totals_summary.prt_order_total(OH.header_id),
                     -1)) DESC, OH.ordered_date';
    ELSIF p_order_by = 'EARLIEST_SHIP_DATE' THEN
       v_order_by_clause := 'GROUP BY OH.header_id,OH.ordered_date
                             ORDER BY MIN(OL.schedule_ship_date), OH.ordered_date';
    END IF;

    --
    -- Build the v_cust_prof_class_clause
    --
    IF p_cust_prof_class_name_from IS NOT NULL OR p_cust_prof_class_name_to IS NOT NULL THEN
      IF p_cust_prof_class_name_from = p_cust_prof_class_name_to THEN
        v_cust_prof_class_clause := 'AND EXISTS
                                         (SELECT HCP.cust_account_id
                                          FROM   HZ_CUSTOMER_PROFILES HCP,
                                                 HZ_CUST_PROFILE_CLASSES HCPC
                                          WHERE  HCP.profile_class_id = HCPC.profile_class_id
                                          AND    HCP.cust_account_id = OH.sold_to_org_id
                                          AND    HCPC.name = :cust_prof_class_from) ';
      ELSIF p_cust_prof_class_name_to IS NULL THEN
        v_cust_prof_class_clause := 'AND EXISTS
                                         (SELECT HCP.cust_account_id
                                          FROM   HZ_CUSTOMER_PROFILES HCP,
                                                 HZ_CUST_PROFILE_CLASSES HCPC
                                          WHERE  HCP.profile_class_id = HCPC.profile_class_id
                                          AND    HCP.cust_account_id = OH.sold_to_org_id
                                          AND    HCPC.name >= :cust_prof_class_from) ';
      ELSIF p_cust_prof_class_name_from IS NULL THEN
        v_cust_prof_class_clause := 'AND EXISTS
                                         (SELECT HCP.cust_account_id
                                          FROM   HZ_CUSTOMER_PROFILES HCP,
                                                 HZ_CUST_PROFILE_CLASSES HCPC
                                          WHERE  HCP.profile_class_id = HCPC.profile_class_id
                                          AND    HCP.cust_account_id = OH.sold_to_org_id
                                          AND    HCPC.name <= :cust_prof_class_to) ';
      ELSE
        v_cust_prof_class_clause := 'AND EXISTS
                                         (SELECT HCP.cust_account_id
                                          FROM   HZ_CUSTOMER_PROFILES HCP,
                                                 HZ_CUST_PROFILE_CLASSES HCPC
                                          WHERE  HCP.profile_class_id = HCPC.profile_class_id
                                          AND    HCP.cust_account_id = OH.sold_to_org_id
                                          AND    HCPC.name BETWEEN :cust_prof_class_from AND
                                                 :cust_prof_class_to) ';
      END IF;
    END IF;

    --
    -- Build the v_party_name_clause
    --
    IF p_party_name_from IS NOT NULL OR p_party_name_to IS NOT NULL THEN
      IF p_party_name_from = p_party_name_to THEN
        v_party_name_clause :=
          'AND    EXISTS (
                                 SELECT HCA.cust_account_id
                                 FROM   HZ_CUST_ACCOUNTS HCA,
                                        HZ_PARTIES HP
                                 WHERE  HCA.party_id = HP.party_id
                                 AND    HCA.cust_account_id = OH.sold_to_org_id
                                 AND    HP.party_name = :party_name_from
                                 ) ';
      ELSIF p_party_name_to IS NULL THEN
        v_party_name_clause :=
          'AND    EXISTS (
                                 SELECT HCA.cust_account_id
                                 FROM   HZ_CUST_ACCOUNTS HCA,
                                        HZ_PARTIES HP
                                 WHERE  HCA.party_id = HP.party_id
                                 AND    HCA.cust_account_id = OH.sold_to_org_id
                                 AND    HP.party_name >= :party_name_from
                                 ) ';
      ELSIF p_party_name_from IS NULL THEN
        v_party_name_clause :=
          'AND    EXISTS (
                                 SELECT HCA.cust_account_id
                                 FROM   HZ_CUST_ACCOUNTS HCA,
                                        HZ_PARTIES HP
                                 WHERE  HCA.party_id = HP.party_id
                                 AND    HCA.cust_account_id = OH.sold_to_org_id
                                 AND    HP.party_name <= :party_name_to
                                 ) ';
      ELSE
        v_party_name_clause :=
          'AND    EXISTS (
                                 SELECT HCA.cust_account_id
                                 FROM   HZ_CUST_ACCOUNTS HCA,
                                        HZ_PARTIES HP
                                 WHERE  HCA.party_id = HP.party_id
                                 AND    HCA.cust_account_id = OH.sold_to_org_id
                                 AND    HP.party_name BETWEEN :party_name_from AND :party_name_to
                                 ) ';
      END IF;
    END IF;
    --
    -- Build the v_cust_acct_number_clause
    --
    IF p_cust_acct_number_from IS NOT NULL OR p_cust_acct_number_to IS NOT NULL THEN
      IF p_cust_acct_number_from = p_cust_acct_number_to THEN
        v_cust_acct_number_clause :=
          'AND    EXISTS (
                                 SELECT HCA.cust_account_id
                                 FROM   HZ_CUST_ACCOUNTS HCA
                                 WHERE  HCA.cust_account_id = OH.sold_to_org_id
                                 AND    HCA.account_number = :cust_acct_number_from
                                 ) ';
      ELSIF p_cust_acct_number_to IS NULL THEN
        v_cust_acct_number_clause :=
          'AND    EXISTS (
                                 SELECT HCA.cust_account_id
                                 FROM   HZ_CUST_ACCOUNTS HCA
                                 WHERE  HCA.cust_account_id = OH.sold_to_org_id
                                 AND    HCA.account_number >= :cust_acct_number_from
                                 ) ';
      ELSIF p_cust_acct_number_from IS NULL THEN
        v_cust_acct_number_clause :=
          'AND    EXISTS (
                                 SELECT HCA.cust_account_id
                                 FROM   HZ_CUST_ACCOUNTS HCA
                                 WHERE  HCA.cust_account_id = OH.sold_to_org_id
                                 AND    HCA.account_number <= :cust_acct_number_to
                                 ) ';
      ELSE
        v_cust_acct_number_clause :=
          'AND    EXISTS (
                                 SELECT HCA.cust_account_id
                                 FROM   HZ_CUST_ACCOUNTS HCA
                                 WHERE  HCA.cust_account_id = OH.sold_to_org_id
                                 AND    HCA.account_number BETWEEN :cust_acct_number_from AND :cust_acct_number_to
                                 ) ';
      END IF;
    END IF;

    --
    -- Build the v_order_date_clause. No need to trunc the parameters since the
    -- input accepted from the concurrent program is only the date format with
    -- no time components.
    --
    IF p_order_date_from IS NOT NULL OR p_order_date_to IS NOT NULL THEN
      IF p_order_date_from = p_order_date_to THEN
        v_order_date_clause :=
          'AND    TRUNC(OH.ordered_date) = :order_date_from ';
      ELSIF p_order_date_to IS NULL THEN
        v_order_date_clause :=
          'AND    TRUNC(OH.ordered_date) >= :order_date_from ';
      ELSIF p_order_date_from IS NULL THEN
        v_order_date_clause :=
          'AND    TRUNC(OH.ordered_date) <= :order_date_to ';
      ELSE
        v_order_date_clause :=
          'AND    TRUNC(OH.ordered_date) BETWEEN :order_date_from AND :order_date_to ';
      END IF;
    END IF;

    --
    -- Build the complete select statement for dynamic sql processing
    --
    IF p_order_by = 'EARLIEST_SHIP_DATE' THEN
      v_hold_final_select :=  'SELECT OH.header_id
                          FROM   OE_ORDER_HEADERS_ALL OH, OE_ORDER_LINES_ALL OL
                          WHERE  OH.BOOKED_FLAG = ''Y''
                          AND    OH.OPEN_FLAG = ''Y''
                          AND    OH.order_category_code <> ''RETURN''
                          AND    NVL(OH.org_id,-99) = :profile_org_id
                          AND    OH.header_id = OL.header_id
                          AND    OL.flow_status_code = ''BOOKED''
                          AND    OL.open_flag = ''Y''
                          AND    OL.booked_flag = ''Y''
                          AND    OL.line_category_code = ''ORDER''
                          AND    NVL(OL.invoiced_quantity, 0) = 0
                          AND    NVL(OL.shipped_quantity, 0) = 0 '
                        ||v_cust_prof_class_clause
                        ||v_party_name_clause
                        ||v_cust_acct_number_clause
                        ||v_order_date_clause
                        ||v_order_by_clause;

      v_release_final_select :=  'SELECT OH.header_id
                          FROM   OE_ORDER_HEADERS_ALL OH, OE_ORDER_LINES_ALL OL,
                                 OE_HOLD_SOURCES_ALL OHS
                          WHERE  OH.BOOKED_FLAG = ''Y''
                          AND    OH.OPEN_FLAG = ''Y''
                          AND    OH.order_category_code <> ''RETURN''
                          AND    NVL(OH.org_id,-99) = :profile_org_id
                          AND    OH.header_id = OL.header_id
                          AND    OL.open_flag = ''Y''
                          AND    OL.booked_flag = ''Y''
                          AND    OL.line_category_code = ''ORDER''
                          AND    NVL(OL.invoiced_quantity, 0) = 0
                          AND    NVL(OL.shipped_quantity, 0) = 0
                          AND    OH.header_id = OHS.hold_entity_id
                          AND    OHS.hold_entity_code = ''O''
                          AND    OHS.released_flag = ''N''
                          AND    OHS.hold_id = 1
                          AND    NVL(OHS.hold_until_date, SYSDATE+1) > SYSDATE '
                        ||v_cust_prof_class_clause
                        ||v_party_name_clause
                        ||v_cust_acct_number_clause
                        ||v_order_date_clause
                        ||v_order_by_clause;

    ELSE
      v_hold_final_select :=  'SELECT OH.header_id
                          FROM   OE_ORDER_HEADERS_ALL OH
                          WHERE  OH.BOOKED_FLAG = ''Y''
                          AND    OH.OPEN_FLAG = ''Y''
                          AND    OH.order_category_code <> ''RETURN''
                          AND    NVL(OH.org_id,-99) = :profile_org_id
                          AND    EXISTS (SELECT 1
                                         FROM   OE_ORDER_LINES_ALL OL
                                         WHERE  NVL(OL.org_id,-99) = :profile_org_id
                                         AND    OL.header_id = OH.header_id
                                         AND    OL.line_category_code = ''ORDER''
                                         AND    OL.open_flag = ''Y''
                                         AND    OL.booked_flag = ''Y''
                                         AND    OL.flow_status_code = ''BOOKED''
                                         AND    NVL(OL.invoiced_quantity, 0) = 0
                                         AND    NVL(OL.shipped_quantity, 0) = 0) '
                        ||v_cust_prof_class_clause
                        ||v_party_name_clause
                        ||v_cust_acct_number_clause
                        ||v_order_date_clause
                        ||v_order_by_clause;

      v_release_final_select :=  'SELECT OH.header_id
                          FROM   OE_ORDER_HEADERS_ALL OH
                          WHERE  OH.BOOKED_FLAG = ''Y''
                          AND    OH.OPEN_FLAG = ''Y''
                          AND    OH.order_category_code <> ''RETURN''
                          AND    NVL(OH.org_id,-99) = :profile_org_id
                          AND    EXISTS (SELECT 1
                                         FROM   OE_HOLD_SOURCES_ALL OHS
                                         WHERE  OHS.hold_entity_code = ''O''
                                         AND    OHS.hold_id = 1
                                         AND    OHS.released_flag = ''N''
                                         AND    NVL(OHS.hold_until_date, SYSDATE+1) > SYSDATE
                                         AND    OHS.hold_entity_id = OH.header_id
                                         )
                          AND    EXISTS (SELECT 1
                                         FROM   OE_ORDER_LINES_ALL OL
                                         WHERE  NVL(OL.org_id,-99) = :profile_org_id
                                         AND    OL.header_id = OH.header_id
                                         AND    OL.open_flag = ''Y''
                                         AND    OL.booked_flag = ''Y''
                                         AND    OL.line_category_code = ''ORDER''
                                         AND    NVL(OL.invoiced_quantity, 0) = 0
                                         AND    NVL(OL.shipped_quantity, 0) = 0 ) '
                        ||v_cust_prof_class_clause
                        ||v_party_name_clause
                        ||v_cust_acct_number_clause
                        ||v_order_date_clause
                        ||v_order_by_clause;

    END IF;
    OE_DEBUG_PUB.ADD('Hold select    : '||v_hold_final_select,2);  --bug# 5187621
    OE_DEBUG_PUB.ADD('Release select : '||v_release_final_select,2);
    --
    -- Open the dynamic sql cursor
    --
    v_hold_cursorID := DBMS_SQL.OPEN_CURSOR;
    v_release_cursorID := DBMS_SQL.OPEN_CURSOR;
    --
    -- Parse the query
    --
    DBMS_SQL.PARSE(v_hold_cursorID, v_hold_final_select, DBMS_SQL.NATIVE);
    DBMS_SQL.PARSE(v_release_cursorID, v_release_final_select, DBMS_SQL.NATIVE);
    OE_DEBUG_PUB.ADD('Parsed the cursor',2);
    --
    -- Define input variables. Only bind the variables if it is part of the
    -- select statement
    --
    OE_DEBUG_PUB.ADD('Start binding input variables',2);

    IF p_order_by = 'GREATEST_ORDER_VALUE' THEN
      DBMS_SQL.BIND_VARIABLE(v_hold_cursorID,':gl_currency_code',p_gl_currency_code);
      DBMS_SQL.BIND_VARIABLE(v_release_cursorID,':gl_currency_code',p_gl_currency_code);
      OE_DEBUG_PUB.ADD('Binded gl_currency_code',2);
    END IF;

    IF INSTRB(v_cust_prof_class_clause,':cust_prof_class_from') <> 0 THEN
      DBMS_SQL.BIND_VARIABLE(v_hold_cursorID,':cust_prof_class_from',p_cust_prof_class_name_from);
      DBMS_SQL.BIND_VARIABLE(v_release_cursorID,':cust_prof_class_from',p_cust_prof_class_name_from);
      OE_DEBUG_PUB.ADD('Binded cust_prof_class_from',2);
    END IF;

    IF INSTRB(v_cust_prof_class_clause,':cust_prof_class_to') <> 0 THEN
      DBMS_SQL.BIND_VARIABLE(v_hold_cursorID,':cust_prof_class_to',p_cust_prof_class_name_to);
      DBMS_SQL.BIND_VARIABLE(v_release_cursorID,':cust_prof_class_to' ,p_cust_prof_class_name_to);
      OE_DEBUG_PUB.ADD('Binded cust_prof_class_to',2);
    END IF;

    IF INSTRB(v_party_name_clause, ':party_name_from') <> 0 THEN
      DBMS_SQL.BIND_VARIABLE(v_hold_cursorID,':party_name_from',p_party_name_from);
      DBMS_SQL.BIND_VARIABLE(v_release_cursorID,':party_name_from',p_party_name_from);
      OE_DEBUG_PUB.ADD('Binded party_name_from',2);
    END IF;

    IF INSTRB(v_party_name_clause, ':party_name_to') <> 0 THEN
      DBMS_SQL.BIND_VARIABLE(v_hold_cursorID,':party_name_to',p_party_name_to);
      DBMS_SQL.BIND_VARIABLE(v_release_cursorID,':party_name_to' ,p_party_name_to);
      OE_DEBUG_PUB.ADD('Binded party_name_to',2);
    END IF;

    IF INSTRB(v_cust_acct_number_clause, ':cust_acct_number_from') <> 0 THEN
      DBMS_SQL.BIND_VARIABLE(v_hold_cursorID,':cust_acct_number_from', p_cust_acct_number_from);
      DBMS_SQL.BIND_VARIABLE(v_release_cursorID,':cust_acct_number_from', p_cust_acct_number_from);
      OE_DEBUG_PUB.ADD('Binded cust_acct_number_from',2);
    END IF;

    IF INSTRB(v_cust_acct_number_clause, ':cust_acct_number_to') <> 0 THEN
      DBMS_SQL.BIND_VARIABLE(v_hold_cursorID,':cust_acct_number_to', p_cust_acct_number_to);
      DBMS_SQL.BIND_VARIABLE(v_release_cursorID,':cust_acct_number_to', p_cust_acct_number_to);
      OE_DEBUG_PUB.ADD('Binded cust_acct_number_to',2);
    END IF;

    IF INSTRB(v_order_date_clause, ':order_date_from') <> 0 THEN
      DBMS_SQL.BIND_VARIABLE(v_hold_cursorID,':order_date_from', p_order_date_from);
      DBMS_SQL.BIND_VARIABLE(v_release_cursorID,':order_date_from', p_order_date_from);
      OE_DEBUG_PUB.ADD('Binded order_date_from',2);
    END IF;

    IF INSTRB(v_order_date_clause, ':order_date_to') <> 0 THEN
      DBMS_SQL.BIND_VARIABLE(v_hold_cursorID,':order_date_to', p_order_date_to);
      DBMS_SQL.BIND_VARIABLE(v_release_cursorID,':order_date_to', p_order_date_to);
      OE_DEBUG_PUB.ADD('Binded order_date_to',2);
    END IF;
    OE_DEBUG_PUB.ADD('Finished binding input variables',2);
    --
    --Define the output variables
    --
    DBMS_SQL.DEFINE_COLUMN(v_hold_cursorID, 1, f_hold_header_id);
    DBMS_SQL.DEFINE_COLUMN(v_release_cursorID, 1, f_release_header_id);

    OE_DEBUG_PUB.ADD('Hold ID    : '||v_hold_cursorID,2);  --bug# 5187621
    OE_DEBUG_PUB.ADD('Release ID : '||v_release_cursorID,2);
    --
    -- Set the l_profile_org_id value to use instead of checking for NULL
    --
    -- MOAC Start
    l_profile_org_id := p_profile_org_id;

    IF l_profile_org_id IS NOT NULL THEN
       MO_GLOBAL.set_policy_context('S', l_profile_org_id);

       IF l_debug_level  > 0 THEN
          OE_DEBUG_PUB.Add('org_id    : ' || l_profile_org_id);
       END IF;

       DBMS_SQL.BIND_VARIABLE(v_hold_cursorID,':profile_org_id', l_profile_org_id);
       DBMS_SQL.BIND_VARIABLE(v_release_cursorID,':profile_org_id', l_profile_org_id);
       OE_DEBUG_PUB.ADD('Binded profile_org_id',2);

       --------------------------------------------------------------------
       --
       -- RELEASE: Execute the RELEASE select statement
       --
       v_dummy := DBMS_SQL.EXECUTE(v_release_cursorID);
       --
       -- RELEASE: Fetch the orders and credit check each one with calling action AUTO RELEASE
       --
       LOOP
         IF DBMS_SQL.FETCH_ROWS(v_release_cursorID) = 0 THEN
            EXIT;
         END IF;
         l_count := l_count+1;
         --
         -- Retreive the header ID into output variable
         --
         DBMS_SQL.COLUMN_VALUE(v_release_cursorID, 1, f_release_header_id);
         OE_DEBUG_PUB.ADD('f_release_header_id    = '|| f_release_header_id,4);
         OE_Credit_Engine_GRP.Check_Credit
         (  p_header_id       => f_release_header_id
         ,  p_calling_action  => 'AUTO RELEASE'
         ,  x_msg_count       => l_msg_count
         ,  x_msg_data        => l_msg_data
         ,  x_result_out      => l_result_out
         ,  x_cc_hold_comment => l_cc_hold_comment
         ,  x_return_status   => l_return_status
         );
         OE_DEBUG_PUB.ADD('Check_Credit return status = '||l_return_status);
         --
         -- Insert the result into the temporary table
         --
         IF (l_return_status = FND_API.G_RET_STS_SUCCESS AND
            (l_result_out = 'PASS' OR l_result_out = 'PASS_REL'))  --bug# 5187621
	 THEN
           Insert_In_Temp_Table(f_release_header_id, 'PASS');
         ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) OR
           (l_return_status = FND_API.G_RET_STS_SUCCESS AND
	      (l_result_out = 'FAIL' OR l_result_out = 'FAIL_HOLD' OR l_result_out = 'FAIL_NONE'))  --bug# 5187621
         THEN
           Insert_In_Temp_Table(f_release_header_id, 'FAIL');
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           Insert_In_Temp_Table(f_release_header_id, 'ERROR');
         END IF;
       END LOOP;

       DBMS_SQL.CLOSE_CURSOR(v_release_cursorID);

       -------------------------------------------------------------------------
       --
       -- HOLD: Execute the HOLD select statement
       --
       v_dummy := DBMS_SQL.EXECUTE(v_hold_cursorID);

       LOOP
         IF DBMS_SQL.FETCH_ROWS(v_hold_cursorID) = 0 THEN
            EXIT;
         END IF;
         l_count := l_count+1;
         --
         -- Retreive the header ID into output variable
         --
         DBMS_SQL.COLUMN_VALUE(v_hold_cursorID, 1, f_hold_header_id);
         OE_DEBUG_PUB.ADD('f_hold_header_id    = '|| f_hold_header_id,4);
         OE_Credit_Engine_GRP.Check_Credit
         (  p_header_id       => f_hold_header_id
         ,  p_calling_action  => 'AUTO HOLD'
         ,  x_msg_count       => l_msg_count
         ,  x_msg_data        => l_msg_data
         ,  x_result_out      => l_result_out
         ,  x_cc_hold_comment => l_cc_hold_comment
         ,  x_return_status   => l_return_status
         );
         OE_DEBUG_PUB.ADD('Check_Credit return status = '||l_return_status);
         --
         -- Insert the result into the temporary table
         --
         IF (l_return_status = FND_API.G_RET_STS_SUCCESS AND
            (l_result_out = 'PASS' OR l_result_out = 'PASS_REL'))  --bug# 5187621
         THEN
           Insert_In_Temp_Table(f_hold_header_id, 'PASS');
         ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) OR
           (l_return_status = FND_API.G_RET_STS_SUCCESS AND
	      (l_result_out = 'FAIL' OR l_result_out = 'FAIL_HOLD' OR l_result_out = 'FAIL_NONE'))  --bug# 5187621
         THEN
           Insert_In_Temp_Table(f_hold_header_id, 'FAIL');
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           Insert_In_Temp_Table(f_hold_header_id, 'ERROR');
         END IF;
       END LOOP;
       --
       DBMS_SQL.CLOSE_CURSOR(v_hold_cursorID);
       OE_DEBUG_PUB.ADD('Orders Processed  = '||l_count,2);
    ELSE
       OPEN l_secured_ou_cur;

       LOOP
         FETCH l_secured_ou_cur
          into l_profile_org_id;
         EXIT WHEN l_secured_ou_cur%NOTFOUND;

         IF l_profile_org_id IS NULL THEN
            l_profile_org_id :=  mo_global.get_current_org_id;
         END IF;

         MO_GLOBAL.set_policy_context('S', l_profile_org_id);

         IF l_debug_level  > 0 THEN
            OE_DEBUG_PUB.Add('org_id    : ' || l_profile_org_id);
         END IF;

         DBMS_SQL.BIND_VARIABLE(v_hold_cursorID,':profile_org_id', l_profile_org_id);
         DBMS_SQL.BIND_VARIABLE(v_release_cursorID,':profile_org_id', l_profile_org_id);
         OE_DEBUG_PUB.ADD('Binded profile_org_id',2);

         --------------------------------------------------------------------
         --
         -- RELEASE: Execute the RELEASE select statement
         --
         v_dummy := DBMS_SQL.EXECUTE(v_release_cursorID);
         --
         -- RELEASE: Fetch the orders and credit check each one with calling action AUTO RELEASE
         --
         LOOP
           IF DBMS_SQL.FETCH_ROWS(v_release_cursorID) = 0 THEN
              EXIT;
           END IF;
           l_count := l_count+1;
           --
           -- Retreive the header ID into output variable
           --
           DBMS_SQL.COLUMN_VALUE(v_release_cursorID, 1, f_release_header_id);
           OE_DEBUG_PUB.ADD('f_release_header_id    = '|| f_release_header_id,4);
           OE_Credit_Engine_GRP.Check_Credit
           (  p_header_id       => f_release_header_id
           ,  p_calling_action  => 'AUTO RELEASE'
           ,  x_msg_count       => l_msg_count
           ,  x_msg_data        => l_msg_data
           ,  x_result_out      => l_result_out
           ,  x_cc_hold_comment => l_cc_hold_comment
           ,  x_return_status   => l_return_status
           );
           OE_DEBUG_PUB.ADD('Check_Credit return status = '||l_return_status);
           --
           -- Insert the result into the temporary table
           --
           IF (l_return_status = FND_API.G_RET_STS_SUCCESS AND
              (l_result_out = 'PASS' OR l_result_out = 'PASS_REL'))  --bug# 5187621
           THEN
             Insert_In_Temp_Table(f_release_header_id, 'PASS');
           ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) OR
             (l_return_status = FND_API.G_RET_STS_SUCCESS AND
	        (l_result_out = 'FAIL' OR l_result_out = 'FAIL_HOLD' OR l_result_out = 'FAIL_NONE'))  --bug# 5187621
           THEN
             Insert_In_Temp_Table(f_release_header_id, 'FAIL');
           ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             Insert_In_Temp_Table(f_release_header_id, 'ERROR');
           END IF;
         END LOOP;

         -------------------------------------------------------------------------
         --
         -- HOLD: Execute the HOLD select statement
         --
         v_dummy := DBMS_SQL.EXECUTE(v_hold_cursorID);

         LOOP
           IF DBMS_SQL.FETCH_ROWS(v_hold_cursorID) = 0 THEN
              EXIT;
           END IF;
           l_count := l_count+1;
           --
           -- Retreive the header ID into output variable
           --
           DBMS_SQL.COLUMN_VALUE(v_hold_cursorID, 1, f_hold_header_id);
           OE_DEBUG_PUB.ADD('f_hold_header_id    = '|| f_hold_header_id,4);
           OE_Credit_Engine_GRP.Check_Credit
           (  p_header_id       => f_hold_header_id
           ,  p_calling_action  => 'AUTO HOLD'
           ,  x_msg_count       => l_msg_count
           ,  x_msg_data        => l_msg_data
           ,  x_result_out      => l_result_out
           ,  x_cc_hold_comment => l_cc_hold_comment
           ,  x_return_status   => l_return_status
           );
           OE_DEBUG_PUB.ADD('Check_Credit return status = '||l_return_status);
           --
           -- Insert the result into the temporary table
           --
           IF (l_return_status = FND_API.G_RET_STS_SUCCESS AND
              (l_result_out = 'PASS' OR l_result_out = 'PASS_REL'))  --bug# 5187621
           THEN
             Insert_In_Temp_Table(f_hold_header_id, 'PASS');
           ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) OR
             (l_return_status = FND_API.G_RET_STS_SUCCESS AND
	        (l_result_out = 'FAIL' OR l_result_out = 'FAIL_HOLD' OR l_result_out = 'FAIL_NONE'))  --bug# 5187621
           THEN
             Insert_In_Temp_Table(f_hold_header_id, 'FAIL');
           ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             Insert_In_Temp_Table(f_hold_header_id, 'ERROR');
           END IF;
         END LOOP;
       END LOOP;

       DBMS_SQL.CLOSE_CURSOR(v_release_cursorID);
       DBMS_SQL.CLOSE_CURSOR(v_hold_cursorID);

       OE_DEBUG_PUB.ADD('Orders Processed  = '||l_count,2);

       CLOSE l_secured_ou_cur;
    END IF;
    -- MOAC End
  ELSE
    --
    -- Credit check the specific order if the header ID is provided for the Credit Check
    -- Processor PL/SQL procedure. the Order Sequence parameter.
    -- Call twice: once to release holds and once to place holds.  This is not ideal, but we will
    -- separate out the release and hold now.
    -- Future: should give option to user to determine if program should place or release holds,
    -- not both.
    OE_Credit_Engine_GRP.Check_Credit
      (  p_header_id       => p_header_id
      ,  p_calling_action  => 'AUTO RELEASE'
      ,  x_msg_count       => l_msg_count
      ,  x_msg_data        => l_msg_data
      ,  x_result_out      => l_result_out
      ,  x_cc_hold_comment => l_cc_hold_comment
      ,  x_return_status   => l_return_status
      );
    OE_DEBUG_PUB.ADD('Release: Check_Credit return status = '||l_return_status);
    --
    -- Insert the results into the temporary table
    --
    OE_DEBUG_PUB.ADD('Right before inserting into temp table');
    IF (l_return_status = FND_API.G_RET_STS_SUCCESS AND
       (l_result_out = 'PASS' OR l_result_out = 'PASS_REL'))  --bug# 5187621
    THEN
      Insert_In_Temp_Table(p_header_id, 'PASS');
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) OR
       (l_return_status = FND_API.G_RET_STS_SUCCESS AND
          (l_result_out = 'FAIL' OR l_result_out = 'FAIL_HOLD' OR l_result_out = 'FAIL_NONE'))  --bug# 5187621
    THEN
      Insert_In_Temp_Table(p_header_id, 'FAIL');
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      Insert_In_Temp_Table(p_header_id, 'ERROR');
    END IF;
    OE_DEBUG_PUB.ADD('Release: Right after inserting into temp table');

    OE_Credit_Engine_GRP.Check_Credit
      (  p_header_id       => p_header_id
      ,  p_calling_action  => 'AUTO HOLD'
      ,  x_msg_count       => l_msg_count
      ,  x_msg_data        => l_msg_data
      ,  x_result_out      => l_result_out
      ,  x_cc_hold_comment => l_cc_hold_comment
      ,  x_return_status   => l_return_status
      );
    OE_DEBUG_PUB.ADD('Hold: Check_Credit return status = '||l_return_status);
    --
    -- Insert the results into the temporary table
    --
    OE_DEBUG_PUB.ADD('Right before inserting into temp table');
    IF (l_return_status = FND_API.G_RET_STS_SUCCESS AND
       (l_result_out = 'PASS' OR l_result_out = 'PASS_REL'))  --bug# 5187621
    THEN
      Insert_In_Temp_Table(p_header_id, 'PASS');
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) OR
       (l_return_status = FND_API.G_RET_STS_SUCCESS AND
          (l_result_out = 'FAIL' OR l_result_out = 'FAIL_HOLD' OR l_result_out = 'FAIL_NONE'))  --bug# 5187621
    THEN
      Insert_In_Temp_Table(p_header_id, 'FAIL');
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      Insert_In_Temp_Table(p_header_id, 'ERROR');
    END IF;
    OE_DEBUG_PUB.ADD('Hold: Right after inserting into temp table');
  END IF;

  OE_DEBUG_PUB.ADD('OUT OEXRCRCB: Credit_Check_Processor',1);
EXCEPTION
  WHEN GL_CURRENCY_API.NO_RATE THEN
    OE_DEBUG_PUB.ADD('OEXRCRCB: Credit_Check_Processor - Error',1);
    OE_DEBUG_PUB.ADD('EXCEPTION: GL_CURRENCY_API.NO_RATE',1);
    IF DBMS_SQL.IS_OPEN(v_hold_cursorID) THEN
      DBMS_SQL.CLOSE_CURSOR(v_hold_cursorID);
    END IF;
    IF DBMS_SQL.IS_OPEN(v_release_cursorID) THEN
      DBMS_SQL.CLOSE_CURSOR(v_release_cursorID);
    END IF;
    RAISE;
  WHEN OTHERS THEN
    OE_DEBUG_PUB.ADD('OEXRCRCB: Credit_Check_Processor - Unexpected Error',1);
    OE_DEBUG_PUB.ADD('EXCEPTION: '||SUBSTR(sqlerrm,1,200),1);
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,'Credit_Check_Processor');
    END IF;
    IF DBMS_SQL.IS_OPEN(v_hold_cursorID) THEN
      DBMS_SQL.CLOSE_CURSOR(v_hold_cursorID);
    END IF;
    IF DBMS_SQL.IS_OPEN(v_release_cursorID) THEN
      DBMS_SQL.CLOSE_CURSOR(v_release_cursorID);
    END IF;
    RAISE;
END Credit_Check_Processor;


--========================================================================
-- PROCEDURE : Get_unchecked_exposure PUBLIC
-- PARAMETERS: p_party_id             Party ID
--             p_customer_id          customer ID
--             p_site_id              bill-to site id
--             p_base_currency        currency of the current operating unit
--             p_usage_curr_tbl       table of all unchecked currencies
--             x_unchecked_expousre   unchecked exposure
--
-- COMMENT   : This procedure calculates unchecked exposure in the
--             base currency.
--
--=====================================================================
PROCEDURE Get_unchecked_exposure
( p_party_id             IN NUMBER DEFAULT NULL
, p_customer_id          IN NUMBER
, p_site_id              IN NUMBER
, p_base_currency        IN VARCHAR2
, p_credit_check_rule_id IN NUMBER
, x_unchecked_expousre   OUT NOCOPY NUMBER
, x_return_status        OUT NOCOPY VARCHAR2
)
IS
---cursor to select all currencies
CURSOR curr_csr
IS
SELECT
  currency_code
FROM fnd_currencies
WHERE enabled_flag='Y'
  AND currency_flag='Y';

l_seperator            VARCHAR2(1) := '#';
l_start                NUMBER := 1;
l_end                  NUMBER := 1;
l_return_status        VARCHAR2(50);
l_currency             VARCHAR2(10);
l_checked_curr_rec     VARCHAR2(2000);
i                      INTEGER:=0;
j                      INTEGER:=0;
f                      INTEGER:=0;


l_credit_check_rule_rec OE_CREDIT_CHECK_UTIL.OE_CREDIT_RULES_REC_TYPE ;
l_system_parameters_rec OE_CREDIT_CHECK_UTIL.OE_SYSTEMS_PARAM_REC_TYPE ;
l_cust_unchk_curr_tbl   OE_CREDIT_CHECK_UTIL.CURR_TBL_TYPE;
l_site_unchk_curr_tbl   OE_CREDIT_CHECK_UTIL.CURR_TBL_TYPE;
l_total_exposure        NUMBER;
l_error_curr_tbl        OE_CREDIT_CHECK_UTIL.CURR_TBL_TYPE;
l_conversion_status     OE_CREDIT_CHECK_UTIL.CURR_TBL_TYPE;
l_include_all_flag      VARCHAR2(15);

l_order_amount          NUMBER;
l_order_hold_amount     NUMBER;
l_ar_amount             NUMBER;


BEGIN
  OE_DEBUG_PUB.ADD('IN Get_Unchecked_Exposure ');
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  ---get credit check rule record
  OE_CREDIT_CHECK_UTIL.GET_credit_check_rule
  ( p_credit_check_rule_id   => p_credit_check_rule_id
  , x_credit_check_rules_rec => l_credit_check_rule_rec
  );

  -----Get system parameters record
  OE_CREDIT_CHECK_UTIL.GET_System_parameters
  ( x_system_parameter_rec=>l_system_parameters_rec
  );

  -----Party level-------
  IF p_party_id IS NOT NULL AND p_customer_id IS NULL
  THEN
    OE_DEBUG_PUB.ADD('global table has rows= '||
   TO_CHAR(OE_Credit_Engine_GRP.G_cust_curr_tbl.COUNT));

    ----get unchecked usages
    ---put checked currencies in one string with # as separator
    FOR i in 1..OE_Credit_Engine_GRP.G_cust_curr_tbl.COUNT
    LOOP

      l_checked_curr_rec:=l_checked_curr_rec || l_seperator
     || OE_Credit_Engine_GRP.G_cust_curr_tbl(i).usage_curr_code;

    END LOOP;

    ----build table for unchecked currencies

    ---if there are no usage currencies
    IF OE_Credit_Engine_GRP.G_cust_curr_tbl.COUNT=0
    THEN
      ---build the table for all currencies
      OE_DEBUG_PUB.ADD('Build table for all currencies as unchecked');

      FOR curr_csr_rec IN curr_csr
      LOOP

          j := j + 1;
          l_cust_unchk_curr_tbl(j).usage_curr_code
                  := curr_csr_rec.currency_code;
      END LOOP;

    ELSE

      FOR curr_csr_rec IN curr_csr
      LOOP
      --  OE_DEBUG_PUB.ADD('Start loop for currency '||
  --        curr_csr_rec.currency_code);

        IF  INSTRB (l_checked_curr_rec,curr_csr_rec.currency_code,1,1)=0
        THEN
          j := j + 1;
          l_cust_unchk_curr_tbl(j).usage_curr_code
                  := curr_csr_rec.currency_code;


        END IF;
      END LOOP;

    END IF;

-----just for debuging----------------------------------------------------------
    OE_DEBUG_PUB.ADD('table for unchecked currencies for the party: ');

    FOR k IN 1..l_cust_unchk_curr_tbl.COUNT
    LOOP
      OE_DEBUG_PUB.ADD('currency_code=: '||l_cust_unchk_curr_tbl(k).usage_curr_code);
    END LOOP;
--------------------------------------------------------------------------------

    -----calculate exposure

    ----pre-calculate exposure
    IF l_credit_check_rule_rec.quick_cr_check_flag ='Y'
    THEN
      OE_DEBUG_PUB.ADD('OEXPCRGB: IN of OE_CREDIT_EXPOSURE_PVT.Get_Exposure ');
      OE_DEBUG_PUB.ADD('Parameters:');
      OE_DEBUG_PUB.ADD('p_party_id: '||p_party_id);
      OE_DEBUG_PUB.ADD('p_customer_id: '||p_customer_id);
      OE_DEBUG_PUB.ADD('p_site_id: '||p_site_id);
      OE_DEBUG_PUB.ADD('p_header_id: '||'NULL');
      OE_DEBUG_PUB.ADD('p_limit_curr_code: '||p_base_currency);
      OE_DEBUG_PUB.ADD('p_include_all_flag: '||'N');

/*

      OE_CREDIT_EXPOSURE_PVT.Get_Exposure
      ( p_customer_id             => p_customer_id
      , p_site_use_id             => NULL
      , p_header_id               => NULL
      , p_credit_check_rule_rec   => l_credit_check_rule_rec
      , p_system_parameters_rec   => l_system_parameters_rec
      , p_limit_curr_code         => p_base_currency
      , p_usage_curr_tbl          => l_cust_unchk_curr_tbl
      , p_include_all_flag        => 'N'
      , x_total_exposure          => x_unchecked_expousre
      , x_return_status           => l_return_status
      , x_error_curr_tbl          => l_error_curr_tbl
      );

*/

     OE_CREDIT_EXPOSURE_PVT.Get_Exposure
      ( p_party_id                => p_party_id
      , p_customer_id             => NULL
      , p_site_use_id             => NULL
      , p_header_id               => NULL
      , p_credit_check_rule_rec   => l_credit_check_rule_rec
      , p_system_parameters_rec   => l_system_parameters_rec
      , p_limit_curr_code         => p_base_currency
      , p_usage_curr_tbl          => l_cust_unchk_curr_tbl
      , p_include_all_flag        => 'N'
      , p_global_exposure_flag    => 'N'
      , p_need_exposure_details   => 'N'
      , x_total_exposure          => x_unchecked_expousre
      , x_order_amount            => l_order_amount
      , x_order_hold_amount       => l_order_hold_amount
      , x_ar_amount               => l_ar_amount
      , x_return_status           => l_return_status
      , x_error_curr_tbl          => l_error_curr_tbl
     );


      OE_DEBUG_PUB.ADD('OUT of Get_Exposure ');
      OE_DEBUG_PUB.ADD('x_unchecked_expousre = '|| x_unchecked_expousre );
      OE_DEBUG_PUB.ADD('l_return_status = '|| l_return_status );

      IF l_error_curr_tbl.COUNT<>0
      THEN
        FOR f IN 1..l_error_curr_tbl.COUNT
        LOOP
          OE_DEBUG_PUB.ADD('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');

          OE_DEBUG_PUB.ADD('!!!!! Exchange rate between '||l_error_curr_tbl(f).usage_curr_code||' and
          base currency '||p_base_currency||' is missing for conversion type '||
          NVL(l_credit_check_rule_rec.user_conversion_type,'Corporate'),1);

          OE_DEBUG_PUB.ADD('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        END LOOP;

       ---bug fix 2439029

       -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

       x_return_status:='C';

      ELSIF l_return_status = FND_API.G_RET_STS_ERROR
      THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    ----non pre-calculate exposure
    ELSIF l_credit_check_rule_rec.quick_cr_check_flag ='N'
    THEN
      OE_DEBUG_PUB.ADD('Party level exposure is supported only for
      credit check rule with pre-calculated exposure');

      x_unchecked_expousre:=0;

    END IF;

  ----Customer level
  ELSIF p_site_id IS NULL AND p_party_id IS NULL
  THEN
    OE_DEBUG_PUB.ADD('global table has rows= '||
   TO_CHAR(OE_Credit_Engine_GRP.G_cust_curr_tbl.COUNT));

    ----get unchecked usages
    ---put checked currencies in one string with # as separator
    FOR i in 1..OE_Credit_Engine_GRP.G_cust_curr_tbl.COUNT
    LOOP

      l_checked_curr_rec:=l_checked_curr_rec || l_seperator
     || OE_Credit_Engine_GRP.G_cust_curr_tbl(i).usage_curr_code;

    END LOOP;

    ----build table for unchecked currencies

    ---if there are no usage currencies
    IF OE_Credit_Engine_GRP.G_cust_curr_tbl.COUNT=0
    THEN
      ---build the table for all currencies
      OE_DEBUG_PUB.ADD('Build table for all currencies as unchecked');

      FOR curr_csr_rec IN curr_csr
      LOOP

          j := j + 1;
          l_cust_unchk_curr_tbl(j).usage_curr_code
                  := curr_csr_rec.currency_code;
      END LOOP;

    ELSE

      FOR curr_csr_rec IN curr_csr
      LOOP
      --  OE_DEBUG_PUB.ADD('Start loop for currency '||
  --        curr_csr_rec.currency_code);

        IF  INSTRB (l_checked_curr_rec,curr_csr_rec.currency_code,1,1)=0
        THEN
          j := j + 1;
          l_cust_unchk_curr_tbl(j).usage_curr_code
                  := curr_csr_rec.currency_code;


        END IF;
      END LOOP;

    END IF;

-----just for debuging----------------------------------------------------------
    OE_DEBUG_PUB.ADD('table for unchecked currencies for the customer: ');

    FOR k IN 1..l_cust_unchk_curr_tbl.COUNT
    LOOP
      OE_DEBUG_PUB.ADD('currency_code=: '||l_cust_unchk_curr_tbl(k).usage_curr_code);
    END LOOP;
--------------------------------------------------------------------------------

    -----calculate exposure

    ----pre-calculate exposure
    IF l_credit_check_rule_rec.quick_cr_check_flag ='Y'
    THEN
      OE_DEBUG_PUB.ADD('OEXPCRGB: IN of OE_CREDIT_EXPOSURE_PVT.Get_Exposure ');
      OE_DEBUG_PUB.ADD('Parameters:');
      OE_DEBUG_PUB.ADD('p_customer_id: '||p_customer_id);
      OE_DEBUG_PUB.ADD('p_site_id: '||p_site_id);
      OE_DEBUG_PUB.ADD('p_header_id: '||'NULL');
      OE_DEBUG_PUB.ADD('p_limit_curr_code: '||p_base_currency);
      OE_DEBUG_PUB.ADD('p_include_all_flag: '||'N');

/*

      OE_CREDIT_EXPOSURE_PVT.Get_Exposure
      ( p_customer_id             => p_customer_id
      , p_site_use_id             => NULL
      , p_header_id               => NULL
      , p_credit_check_rule_rec   => l_credit_check_rule_rec
      , p_system_parameters_rec   => l_system_parameters_rec
      , p_limit_curr_code         => p_base_currency
      , p_usage_curr_tbl          => l_cust_unchk_curr_tbl
      , p_include_all_flag        => 'N'
      , x_total_exposure          => x_unchecked_expousre
      , x_return_status           => l_return_status
      , x_error_curr_tbl          => l_error_curr_tbl
      );

*/

     OE_CREDIT_EXPOSURE_PVT.Get_Exposure
      ( p_customer_id             => p_customer_id
      , p_site_use_id             => NULL
      , p_party_id                => NULL
      , p_header_id               => NULL
      , p_credit_check_rule_rec   => l_credit_check_rule_rec
      , p_system_parameters_rec   => l_system_parameters_rec
      , p_limit_curr_code         => p_base_currency
      , p_usage_curr_tbl          => l_cust_unchk_curr_tbl
      , p_include_all_flag        => 'N'
      , p_global_exposure_flag    => 'N'
      , p_need_exposure_details   => 'N'
      , x_total_exposure          => x_unchecked_expousre
      , x_order_amount            => l_order_amount
      , x_order_hold_amount       => l_order_hold_amount
      , x_ar_amount               => l_ar_amount
      , x_return_status           => l_return_status
      , x_error_curr_tbl          => l_error_curr_tbl
     );


      OE_DEBUG_PUB.ADD('OUT of Get_Exposure ');
      OE_DEBUG_PUB.ADD('x_unchecked_expousre = '|| x_unchecked_expousre );
      OE_DEBUG_PUB.ADD('l_return_status = '|| l_return_status );

      IF l_error_curr_tbl.COUNT<>0
      THEN
        FOR f IN 1..l_error_curr_tbl.COUNT
        LOOP
          OE_DEBUG_PUB.ADD('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');

          OE_DEBUG_PUB.ADD('!!!!! Exchange rate between '||l_error_curr_tbl(f).usage_curr_code||' and
          base currency '||p_base_currency||' is missing for conversion type '||
          NVL(l_credit_check_rule_rec.user_conversion_type,'Corporate'),1);

          OE_DEBUG_PUB.ADD('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        END LOOP;

       ---bug fix 2439029

       -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

       x_return_status:='C';

      ELSIF l_return_status = FND_API.G_RET_STS_ERROR
      THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    ----non pre-calculate exposure
    ELSIF l_credit_check_rule_rec.quick_cr_check_flag ='N'
    THEN
      OE_DEBUG_PUB.ADD('OEXPCRGB: IN OE_CREDIT_ENGIN_GRB.Get_order_Exposure ');
      OE_DEBUG_PUB.ADD('Parameters:');
      OE_DEBUG_PUB.ADD('p_customer_id: '||p_customer_id);
      OE_DEBUG_PUB.ADD('p_site_id: '||p_site_id);
      OE_DEBUG_PUB.ADD('p_header_id: '||'NULL');
      OE_DEBUG_PUB.ADD('p_limit_curr_code: '||p_base_currency);
      OE_DEBUG_PUB.ADD('p_include_all_flag: '||'N');
/*
      OE_CREDIT_CHECK_UTIL.Get_order_exposure
      ( p_header_id              => NULL
      , p_transaction_curr_code  => NULL
      , p_customer_id            => p_customer_id
      , p_site_use_id            => NULL
      , p_credit_check_rule_rec  => l_credit_check_rule_rec
      , p_system_parameter_rec   => l_system_parameters_rec
      , p_credit_level           => 'CUSTOMER'
      , p_limit_curr_code        => p_base_currency
      , p_usage_curr             => l_cust_unchk_curr_tbl
      , p_include_all_flag       => 'N'
      , x_total_exposure         => x_unchecked_expousre
      , x_return_status          => l_return_status
      , x_conversion_status      => l_conversion_status
      );
*/

       OE_CREDIT_CHECK_UTIL.Get_order_exposure
       ( p_header_id              => NULL
       , p_transaction_curr_code  => NULL
       , p_customer_id            => p_customer_id
       , p_site_use_id            => NULL
       , p_credit_check_rule_rec => l_credit_check_rule_rec
       , p_system_parameter_rec  => l_system_parameters_rec
       , p_credit_level          => 'CUSTOMER'
       , p_limit_curr_code       => p_base_currency
       , p_usage_curr            => l_cust_unchk_curr_tbl
       , p_include_all_flag      => 'N'
       , p_global_exposure_flag  => 'N'
       , p_need_exposure_details  => 'N'
       , x_total_exposure         => x_unchecked_expousre
       , x_ar_amount              => l_ar_amount
       , x_order_amount           => l_order_amount
       , x_order_hold_amount     => l_order_hold_amount
       , x_conversion_status     => l_conversion_status
       , x_return_status         => l_return_status
       );


      OE_DEBUG_PUB.ADD('OUT of Get_order_exposure ');
      OE_DEBUG_PUB.ADD('x_unchecked_expousre = '|| x_unchecked_expousre );
      OE_DEBUG_PUB.ADD('l_return_status = '|| l_return_status );

      IF l_conversion_status.COUNT<>0
      THEN
        FOR f IN 1..l_conversion_status.COUNT
        LOOP
          OE_DEBUG_PUB.ADD('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');

          OE_DEBUG_PUB.ADD('!!!!! Exchange rate between '||l_conversion_status(f).usage_curr_code||' and
          base currency '||p_base_currency||' is missing for conversion type '||
          NVL(l_credit_check_rule_rec.user_conversion_type,'Corporate'),1);

          OE_DEBUG_PUB.ADD('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');

        END LOOP;

        ---bug fix 2439029

       -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

       x_return_status:='C';

      ELSIF l_return_status = FND_API.G_RET_STS_ERROR
      THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF;

  -----Bill-to Site Level
  ELSIF p_site_id IS NOT NULL
  THEN

   OE_DEBUG_PUB.ADD('global table has rows= '||
   TO_CHAR(OE_Credit_Engine_GRP.G_site_curr_tbl.COUNT));
    ----get unchecked usages
    ---put checked currencies in one string with # as separator
    FOR i in 1..OE_CREDIT_ENGINE_GRP.G_site_curr_tbl.COUNT
    LOOP
      l_checked_curr_rec:=l_checked_curr_rec || l_seperator || OE_CREDIT_ENGINE_GRP.G_site_curr_tbl(i).usage_curr_code;
    END LOOP;

    ----build table for unchecked currencies

    ---if there are no usage currencies
    IF OE_Credit_Engine_GRP.G_site_curr_tbl.COUNT=0
    THEN
      ---build the table for all currencies
      OE_DEBUG_PUB.ADD('Build table for all currencies as unchecked');

      FOR curr_csr_rec IN curr_csr
      LOOP

          j := j + 1;
          l_site_unchk_curr_tbl(j).usage_curr_code :=
                  curr_csr_rec.currency_code;
      END LOOP;
    ELSE

      FOR curr_csr_rec IN curr_csr
      LOOP

        IF  INSTRB (l_checked_curr_rec,curr_csr_rec.currency_code,1,1)=0
        THEN
          j := j + 1;
          l_site_unchk_curr_tbl(j).usage_curr_code :=
                  curr_csr_rec.currency_code;

        END IF;
      END LOOP;

    END IF;

-----just for debuging----------------------------------------------------------
    OE_DEBUG_PUB.ADD('table for unchecked currencies for the site: ');

    FOR k IN 1..l_site_unchk_curr_tbl.COUNT
    LOOP
      OE_DEBUG_PUB.ADD('currency_code=: '||l_site_unchk_curr_tbl(k).usage_curr_code);
    END LOOP;
--------------------------------------------------------------------------------

     -----calculate exposure

    ----pre-calculate exposure
    IF l_credit_check_rule_rec.quick_cr_check_flag ='Y'
    THEN
      OE_DEBUG_PUB.ADD('OEXPCRGB: IN of OE_CREDIT_EXPOSURE_PVT.Get_Exposure ');
      OE_DEBUG_PUB.ADD('Parameters:');
      OE_DEBUG_PUB.ADD('p_customer_id: '||p_customer_id);
      OE_DEBUG_PUB.ADD('p_site_id: '||p_site_id);
      OE_DEBUG_PUB.ADD('p_header_id:'||'NULL');
      OE_DEBUG_PUB.ADD('p_limit_curr_code: '||p_base_currency);
      OE_DEBUG_PUB.ADD('p_include_all_flag: '||'N');
/*
      OE_CREDIT_EXPOSURE_PVT.Get_Exposure
      ( p_customer_id             => p_customer_id
      , p_site_use_id             => p_site_id
      , p_header_id               => NULL
      , p_credit_check_rule_rec   => l_credit_check_rule_rec
      , p_system_parameters_rec   => l_system_parameters_rec
      , p_limit_curr_code         => p_base_currency
      , p_usage_curr_tbl          => l_site_unchk_curr_tbl
      , p_include_all_flag        => 'N'
      , x_total_exposure          => x_unchecked_expousre
      , x_return_status           => l_return_status
      , x_error_curr_tbl          => l_error_curr_tbl
      );
*/


      OE_CREDIT_EXPOSURE_PVT.Get_Exposure
      ( p_customer_id             => p_customer_id
      , p_site_use_id             => p_site_id
      , p_party_id                => NULL
      , p_header_id               => NULL
      , p_credit_check_rule_rec  => l_credit_check_rule_rec
      , p_system_parameters_rec  => l_system_parameters_rec
      , p_limit_curr_code        => p_base_currency
      , p_usage_curr_tbl         => l_site_unchk_curr_tbl
      , p_include_all_flag        => 'N'
      , p_global_exposure_flag   => 'N'
      , p_need_exposure_details  => 'N'
      , x_total_exposure         => x_unchecked_expousre
      , x_order_amount           => l_order_amount
      , x_order_hold_amount      => l_order_hold_amount
      , x_ar_amount              => l_ar_amount
      , x_return_status         => l_return_status
      , x_error_curr_tbl        => l_error_curr_tbl
      );


      OE_DEBUG_PUB.ADD('OEXPCRGB: OUT of OE_CREDIT_EXPOSURE_PVT.Get_Exposure ');
      OE_DEBUG_PUB.ADD('x_unchecked_expousre: '||x_unchecked_expousre);
      OE_DEBUG_PUB.ADD('l_return_status = '|| l_return_status );

      IF l_error_curr_tbl.COUNT<>0
      THEN
        FOR f IN 1..l_error_curr_tbl.COUNT
        LOOP
          OE_DEBUG_PUB.ADD('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');

          OE_DEBUG_PUB.ADD('!!!!! Exchange rate between '||l_error_curr_tbl(f).usage_curr_code||' and
          base currency '||p_base_currency||' is missing for conversion type '||
          NVL(l_credit_check_rule_rec.user_conversion_type,'Corporate'),1);

          OE_DEBUG_PUB.ADD('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');

        END LOOP;

       ---bug fix 2439029

       -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

       x_return_status:='C';

      ELSIF l_return_status = FND_API.G_RET_STS_ERROR
      THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    ----non pre-calculate exposure
    ELSIF l_credit_check_rule_rec.quick_cr_check_flag ='N'
    THEN
      OE_DEBUG_PUB.ADD('OEXPCRGB: IN of OE_CREDIT_CHECK_UTIL.Get_order_Exposure ');
      OE_DEBUG_PUB.ADD('Parameters:');
      OE_DEBUG_PUB.ADD('p_header_id: '||'NULL');
      OE_DEBUG_PUB.ADD('p_transaction_curr_code: '||'NULL');
      OE_DEBUG_PUB.ADD('p_customer_id: '||p_customer_id);
      OE_DEBUG_PUB.ADD('p_site_use_id: '||p_site_id);
      OE_DEBUG_PUB.ADD('p_credit_level: '||'SITE');
      OE_DEBUG_PUB.ADD('p_limit_curr_code: '||p_base_currency);
      OE_DEBUG_PUB.ADD('p_include_all_flag: '||'N');
/*
      OE_CREDIT_CHECK_UTIL.Get_order_exposure
      ( p_header_id              => NULL
      , p_transaction_curr_code  => NULL
      , p_customer_id            => p_customer_id
      , p_site_use_id            => p_site_id
      , p_credit_check_rule_rec  => l_credit_check_rule_rec
      , p_system_parameter_rec   => l_system_parameters_rec
      , p_credit_level           => 'SITE'
      , p_limit_curr_code        => p_base_currency
      , p_usage_curr             => l_site_unchk_curr_tbl
      , p_include_all_flag       => 'N'
      , x_total_exposure         => x_unchecked_expousre
      , x_return_status          => l_return_status
      , x_conversion_status      => l_conversion_status
      );
*/

      OE_CREDIT_CHECK_UTIL.Get_order_exposure
     ( p_header_id              => NULL
     , p_transaction_curr_code  => NULL
     , p_customer_id            => p_customer_id
     , p_site_use_id            => p_site_id
     , p_credit_check_rule_rec => l_credit_check_rule_rec
     , p_system_parameter_rec  => l_system_parameters_rec
     , p_credit_level          => 'SITE'
     , p_limit_curr_code       => p_base_currency
     , p_usage_curr            => l_site_unchk_curr_tbl
     , p_include_all_flag      => 'N'
     , p_global_exposure_flag  => 'N'
     , p_need_exposure_details => 'N'
     , x_total_exposure       => x_unchecked_expousre
     , x_ar_amount            => l_ar_amount
     , x_order_amount         => l_order_amount
     , x_order_hold_amount    => l_order_hold_amount
     , x_conversion_status   => l_conversion_status
    , x_return_status       => l_return_status
    );


      OE_DEBUG_PUB.ADD('OUT of Get_order_exposure ');
      OE_DEBUG_PUB.ADD('x_unchecked_expousre: '||x_unchecked_expousre);
      OE_DEBUG_PUB.ADD('l_return_status = '|| l_return_status );

      IF l_conversion_status.COUNT<>0
      THEN

        FOR f IN 1..l_conversion_status.COUNT
        LOOP
          OE_DEBUG_PUB.ADD('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');

          OE_DEBUG_PUB.ADD('!!!!! Exchange rate between '||l_conversion_status(f).usage_curr_code||' and
          base currency '||p_base_currency||' is missing for conversion type '||
          NVL(l_credit_check_rule_rec.user_conversion_type,'Corporate'),1);

          OE_DEBUG_PUB.ADD('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');

        END LOOP;

       ---bug fix 2439029

       -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

       x_return_status:='C';

      ELSIF l_return_status = FND_API.G_RET_STS_ERROR
      THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF;

  END IF;

 OE_DEBUG_PUB.ADD('Out Get_unchecked_exposure with status='||x_return_status);
 OE_DEBUG_PUB.ADD('unchecked_exposure='||x_unchecked_expousre);


 EXCEPTION
  WHEN OTHERS THEN
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      ,   'Get_unchecked_exposure'
      );
    END IF;
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;



END Get_unchecked_exposure;

--========================================================================
-- PROCEDURE : Credit_exposure_report_utils     PUBLIC
-- PARAMETERS: p_report_by_option
--             p_specific_party_id
--             p_specific_party_num
--             p_party_name_low
--             p_party_name_high
--             p_party_number_low
--             p_party_number_high
--             p_prof_class_low       customer profile class name from
--             p_prof_class_high      customer profile class name to
--             p_customer_name_low    customer name from
--             p_customer_name_high   customer name to
--             p_cust_number_low      customer number from
--             p_cust_number_high     customer number to
--             p_cr_check_rule_id     credit check rule
--             p_org_id
--             x_return_status
--
-- COMMENT   : This is the main procedure for Credit Exposure Report. It calculates
--             exposure and populates temp table OE_CREDIT_EXPOSURE_TMP
--
--=======================================================================--
PROCEDURE Credit_exposure_report_utils
( p_report_by_option   IN VARCHAR2 DEFAULT NULL
, p_specific_party_id  IN NUMBER DEFAULT NULL
, p_spec_party_num_id  IN NUMBER DEFAULT NULL
, p_party_name_low     IN VARCHAR2 DEFAULT NULL
, p_party_name_high    IN VARCHAR2 DEFAULT NULL
, p_party_number_low   IN VARCHAR2 DEFAULT NULL
, p_party_number_high  IN VARCHAR2 DEFAULT NULL
, p_prof_class_low     IN VARCHAR2 DEFAULT NULL
, p_prof_class_high    IN VARCHAR2 DEFAULT NULL
, p_customer_name_low  IN VARCHAR2 DEFAULT NULL
, p_customer_name_high IN VARCHAR2 DEFAULT NULL
, p_cust_number_low    IN VARCHAR2 DEFAULT NULL
, p_cust_number_high   IN VARCHAR2 DEFAULT NULL
, p_cr_check_rule_id   IN NUMBER
, p_org_id             IN NUMBER
, x_return_status      OUT NOCOPY VARCHAR2
)

IS

Type cust_cur_type IS REF CURSOR;
cust_cur           cust_cur_type;

TYPE cust_type is RECORD (
     customer         VARCHAR2(150),
     customer_id      hz_cust_accounts.cust_account_id%TYPE,
     customer_number  hz_cust_accounts.account_number%TYPE);

cust_csr_rec       cust_type;

l_input NUMBER := 0;

---cursor to select all eligible parties for Party Range Summary
/*
CURSOR party_csr(l_input NUMBER)
IS
SELECT
  p.party_name||'('||p.party_number||')' Party
, p.party_id
, p.party_number
FROM
  hz_parties p
WHERE party_type IN ('ORGANIZATION','PERSON')
  AND party_name BETWEEN p_party_name_low
                 AND NVL(p_party_name_high, party_name)
  AND party_number  BETWEEN NVL(p_party_number_low, party_number )
                 AND NVL(p_party_number_high, party_number )
  AND l_input = 1
UNION
SELECT
  p.party_name||'('||p.party_number||')' Party
, p.party_id
, p.party_number
FROM
  hz_parties p
WHERE party_type IN ('ORGANIZATION','PERSON')
  AND party_name <= p_party_name_high
  AND party_number  BETWEEN NVL(p_party_number_low, party_number )
                 AND NVL(p_party_number_high, party_number )
  AND l_input = 2
UNION
SELECT
  p.party_name||'('||p.party_number||')' Party
, p.party_id
, p.party_number
FROM
  hz_parties p
WHERE party_type IN ('ORGANIZATION','PERSON')
  AND party_number  BETWEEN p_party_number_low
                 AND NVL(p_party_number_high, party_number )
  AND l_input = 3
UNION
SELECT
  p.party_name||'('||p.party_number||')' Party
, p.party_id
, p.party_number
FROM
  hz_parties p
WHERE party_type IN ('ORGANIZATION','PERSON')
  AND party_number  <= p_party_number_high
  AND l_input = 4
; */


 -- 5212830

CURSOR party_csr1(l_input NUMBER)IS
SELECT
  p.party_name||'('||p.party_number||')' Party
, p.party_id
, p.party_number
FROM
  hz_parties p
WHERE party_type IN ('ORGANIZATION','PERSON')
  AND party_name BETWEEN p_party_name_low
                 AND NVL(p_party_name_high, party_name)
  AND party_number  BETWEEN NVL(p_party_number_low, party_number )
                 AND NVL(p_party_number_high, party_number )
  AND l_input = 1 ;

CURSOR party_csr2(l_input NUMBER)IS
SELECT
  p.party_name||'('||p.party_number||')' Party
, p.party_id
, p.party_number
FROM
  hz_parties p
WHERE party_type IN ('ORGANIZATION','PERSON')
  AND party_name <= p_party_name_high
  AND party_number  BETWEEN NVL(p_party_number_low, party_number )
                 AND NVL(p_party_number_high, party_number )
  AND l_input = 2;

CURSOR party_csr3(l_input NUMBER)IS
SELECT
  p.party_name||'('||p.party_number||')' Party
, p.party_id
, p.party_number
FROM
  hz_parties p
WHERE party_type IN ('ORGANIZATION','PERSON')
  AND party_number  BETWEEN p_party_number_low
                 AND NVL(p_party_number_high, party_number )
  AND l_input = 3;

CURSOR party_csr4(l_input NUMBER)IS
SELECT
  p.party_name||'('||p.party_number||')' Party
, p.party_id
, p.party_number
FROM
  hz_parties p
WHERE party_type IN ('ORGANIZATION','PERSON')
  AND party_number  <= p_party_number_high
  AND l_input = 4;

party_csr_rec party_csr1%ROWTYPE;

 -- 5212830


---cursor to select parties in hierarchical order
---for Party Detail
CURSOR party_hier_csr
IS
SELECT
   p.party_name||'('||p.party_number||')' Party
 , n.child_id party_id
 , p.party_number party_number
 , NVL(n.level_number,0) level_number
 FROM
   hz_parties p, hz_hierarchy_nodes n
 WHERE p.party_id=n.child_id
   AND     n.parent_object_type           = 'ORGANIZATION'
   AND     n.parent_table_name            = 'HZ_PARTIES'
   AND     n.child_object_type            = 'ORGANIZATION'
   AND     n.effective_start_date          <= SYSDATE
   AND     n.effective_end_date            >= SYSDATE
   AND     n.hierarchy_type
                = OE_CREDIT_CHECK_UTIL.G_hierarchy_type
   AND n.parent_id=NVL(p_specific_party_id,p_spec_party_num_id)
 ORDER BY level_number;

---cursor to select parties if they are not part of the
-- hierarchical order,for Party Detail
CURSOR party_hier_csr1
IS
SELECT
   p.party_name||'('||p.party_number||')' Party
 , p.party_id
 , p.party_number party_number
 FROM
   hz_parties p
 WHERE p.party_id=NVL(p_specific_party_id,p_spec_party_num_id);


----cursor to select all credit profiles for the given party
CURSOR party_prof_csr(p_party_id NUMBER)
IS
SELECT
  cpa.currency_code party_currency_code
, cpa.overall_credit_limit party_overall_limit
FROM
  hz_customer_profiles cp
, hz_cust_profile_amts cpa
WHERE cp.cust_account_profile_id=cpa.cust_account_profile_id
  AND cp.site_use_id IS NULL
  AND cp.cust_account_id=-1
  AND cp.party_id=p_party_id;


---cursor to select all eligible customers for a given party
CURSOR party_cust_csr(p_party_id IN NUMBER)
IS
SELECT
  SUBSTRB(p.party_name,1,50) ||'('||c.account_number||')' Customer
, c.cust_account_id customer_id
, c.account_number customer_number
FROM
  hz_cust_accounts c
, hz_parties p
WHERE c.status='A'
  AND c.party_id = p.party_id
  AND p.party_id= p_party_id;

---cursor to select all eligible customers
/*
--Performance issue (SQL ID-16485806 FTS on HZ_CUST_ACCOUNTS and HZ_CUST_PROFILE_CLASSES)
CURSOR cust_csr
IS
SELECT
  SUBSTRB(party.party_name,1,50) ||'('||c.account_number||')' Customer
, c.cust_account_id customer_id
, c.account_number customer_number
FROM
  hz_cust_accounts c
, hz_parties party
WHERE c.status='A'
  AND c.party_id = party.party_id
  AND party.party_name BETWEEN NVL(p_customer_name_low, party.party_name )
                 AND NVL(p_customer_name_high, party.party_name)
  AND c.account_number  BETWEEN NVL(p_cust_number_low, c.account_number )
                 AND NVL(p_cust_number_high, c.account_number )
  AND c.cust_account_id IN (SELECT cp.cust_account_id
                             FROM hz_cust_profile_classes cpc,hz_customer_profiles cp
                             WHERE cp.profile_class_id=cpc.profile_class_id
                               AND cpc.name BETWEEN NVL(p_prof_class_low, cpc.name)
                                 AND NVL(p_prof_class_high, cpc.name));
*/

----cursor to select all credit profiles for the given customer
CURSOR cust_prof_csr(p_customer_id NUMBER)
IS
SELECT
  cpa.currency_code cust_currency_code
, cpa.overall_credit_limit cust_overall_limit
FROM
  hz_customer_profiles cp
, hz_cust_profile_amts cpa
WHERE cp.cust_account_profile_id=cpa.cust_account_profile_id
  AND cp.site_use_id IS NULL
  AND cp.cust_account_id=p_customer_id;

----cursor to select all bill-to sites for the given customer
CURSOR site_csr(p_customer_id NUMBER)
IS
SELECT
  csu.location Customer_site
, csu.site_use_id site_id
, csu.cust_acct_site_id
FROM
  hz_cust_site_uses_all csu
,  hz_cust_acct_sites_all casa
WHERE csu.site_use_code='BILL_TO'
  AND csu.cust_acct_site_id=casa.cust_acct_site_id
  AND casa.cust_account_id=p_customer_id
  AND csu.org_id=p_org_id
  AND casa.org_id=p_org_id;


----cursor to select all credit profiles for the given bill-to site
CURSOR site_prof_csr(p_customer_id NUMBER, p_site_id NUMBER)
IS
SELECT
  cpa.currency_code site_currency_code
, cpa.overall_credit_limit site_overall_limit
FROM
  hz_customer_profiles cp
, hz_cust_profile_amts cpa
WHERE cp.cust_account_profile_id=cpa.cust_account_profile_id
  AND cp.site_use_id =p_site_id
  AND cp.cust_account_id=p_customer_id;

l_msg_count              NUMBER        := 0 ;
l_msg_data               VARCHAR2(2000):= NULL ;
l_cust_total_exposure    NUMBER;
l_party_total_exposure    NUMBER;
l_site_total_exposure    NUMBER;
l_return_status          VARCHAR2(30);
l_return_status1         VARCHAR2(30); ---for exchnage rate missing status
l_base_currency          VARCHAR2(15);
l_cust_available         NUMBER;
l_party_available         NUMBER;
l_site_available         NUMBER;
l_base_cur_overall_limit NUMBER;
l_base_cur_exposure      NUMBER;
l_base_cur_available     NUMBER;
l_cust_unchk_exposure    NUMBER;
l_party_unchk_exposure    NUMBER;
l_site_unchk_exposure    NUMBER;
l_conversion_type        VARCHAR2(30);
l_empty_curr_tbl         OE_CREDIT_CHECK_UTIL.CURR_TBL_TYPE;
l_global_exposure_flag   VARCHAR2(1);
l_prof_count             NUMBER:=0;
l_prof_count1            NUMBER:=0;
l_order_hold_amount      NUMBER;
l_order_amount           NUMBER;
l_ar_amount              NUMBER;
l_external_amount        NUMBER;
l_specific_party_id      NUMBER;
l_profile_value          VARCHAR2(100);
l_count_hierarchy        NUMBER;

BEGIN


  OE_DEBUG_PUB.ADD('IN OEXRCRCB:Credit_exposure_report_utils ');
  l_return_status := FND_API.G_RET_STS_SUCCESS;
  l_global_exposure_flag := 'N' ;

  ----get base currency=currency of the current operating unit
  l_base_currency:=OE_CREDIT_CHECK_UTIL.Get_GL_currency;

  OE_DEBUG_PUB.ADD('l_base_currency= '||l_base_currency);

  ---get conversion type
  SELECT
    conversion_type
  INTO
    l_conversion_type
  FROM oe_credit_check_rules
  WHERE credit_check_rule_id=p_cr_check_rule_id;

  ----get the hierarchy_type
  l_profile_value:=OE_CREDIT_CHECK_UTIL.G_hierarchy_type;

  OE_DEBUG_PUB.ADD('AR_CMGT_HIERARCHY_TYPE= '||l_profile_value);

  --------Party Range Summary Report-----------

  IF p_report_by_option='PARTY_SUMMARY'
  THEN

    OE_DEBUG_PUB.ADD('IN Party Summary Report');

    ------start loop for parties
    IF (p_party_name_low IS NOT NULL) THEN
      l_input := 1;
    ELSIF (p_party_name_high IS NOT NULL) THEN
      l_input := 2;
    ELSIF (p_party_number_low IS NOT NULL) THEN
      l_input := 3;
    ELSIF (p_party_number_high IS NOT NULL) THEN
      l_input := 4;
    ELSE
      OE_DEBUG_PUB.ADD(' no party input');
      l_input := 0;
    END IF;

   OE_DEBUG_PUB.ADD(' party input:'||l_input);
   IF (l_input > 0) THEN
 -- 5212830 FOR party_csr_rec IN party_csr(l_input)

    LOOP

  -- 5212830

       IF (l_input = 1) THEN

        IF NOT (party_csr1%ISOPEN) THEN
	  OPEN party_csr1(l_input);
	END IF;

	FETCH party_csr1 INTO party_csr_rec;
	EXIT WHEN party_csr1%NOTFOUND;

       ELSIF (l_input = 2) THEN


        IF NOT (party_csr2%ISOPEN) THEN
	OPEN party_csr2(l_input);
	END IF;

	FETCH party_csr2 INTO party_csr_rec;
	EXIT WHEN party_csr2%NOTFOUND ;


       ELSIF (l_input = 3) THEN

        IF NOT (party_csr3%ISOPEN) THEN
	OPEN party_csr3(l_input);
	END IF;

	FETCH party_csr3 INTO party_csr_rec;
	EXIT WHEN party_csr3%NOTFOUND ;

       ELSIF (l_input = 4) THEN

        IF NOT (party_csr4%ISOPEN) THEN
	OPEN party_csr4(l_input);
	END IF;

	FETCH party_csr4 INTO party_csr_rec;
	EXIT WHEN party_csr4%NOTFOUND;

       END IF;

 -- 5212830

      ----Empty global variables
      OE_Credit_Engine_GRP.G_cust_curr_tbl:=l_empty_curr_tbl;
      OE_Credit_Engine_GRP.G_cust_incl_all_flag:='N';

      ----start loop for party credit profiles



      FOR party_prof_csr_rec  IN party_prof_csr(p_party_id=>party_csr_rec.party_id)
      LOOP
        ------calculate party credit exposure
        OE_CREDIT_ENGINE_GRP.Get_Customer_Exposure
        ( p_party_id              => party_csr_rec.party_id
        , p_customer_id           => NULL
        , p_site_id               => NULL
        , p_limit_curr_code       => party_prof_csr_rec.party_currency_code
        , p_credit_check_rule_id  => p_cr_check_rule_id
        , p_need_exposure_details => 'N'
        , x_total_exposure        => l_party_total_exposure
        , x_order_hold_amount     => l_order_hold_amount
        , x_order_amount          => l_order_amount
        , x_ar_amount             => l_ar_amount
        , x_external_amount       => l_external_amount
        , x_return_status         => l_return_status
        );


        OE_DEBUG_PUB.ADD('OEXPCRGB: OUT of Get_Customer_Exposure ');
        OE_DEBUG_PUB.ADD('l_return_status = '|| l_return_status );

        IF l_return_status = 'C'
        THEN
          l_return_status1:='C';

          EXIT;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -----calculate available credit
        l_party_available:=party_prof_csr_rec.party_overall_limit - l_party_total_exposure;


        -----convert overall_credit_limit, exposure and available credit into base currency
        OE_DEBUG_PUB.ADD('IN Convert amounts ');

        l_base_cur_overall_limit :=
        GL_CURRENCY_API.Convert_closest_amount_sql
        ( x_from_currency         => party_prof_csr_rec.party_currency_code
        , x_to_currency           => l_base_currency
        , x_conversion_date       => sysdate
        , x_conversion_type       => l_conversion_type
        , x_user_rate             => NULL
        , x_amount                => party_prof_csr_rec.party_overall_limit
        , x_max_roll_days         => -1
        );

        OE_DEBUG_PUB.ADD('GL_currency_api.Convert_closest_amount_sql ');
        OE_DEBUG_PUB.ADD('l_base_cur_overall_limit = '|| TO_CHAR(l_base_cur_overall_limit));

        l_base_cur_exposure      :=
        GL_CURRENCY_API.Convert_closest_amount_sql
        ( x_from_currency         => party_prof_csr_rec.party_currency_code
        , x_to_currency           => l_base_currency
        , x_conversion_date       => sysdate
        , x_conversion_type       => l_conversion_type
        , x_user_rate             => NULL
        , x_amount                => l_party_total_exposure
        , x_max_roll_days         => -1
        );

        OE_DEBUG_PUB.ADD('GL_currency_api.Convert_closest_amount_sql ');
        OE_DEBUG_PUB.ADD('l_base_cur_exposure = '|| TO_CHAR(l_base_cur_exposure));

        l_base_cur_available     :=
        GL_CURRENCY_API.Convert_closest_amount_sql
        ( x_from_currency         => party_prof_csr_rec.party_currency_code
        , x_to_currency           => l_base_currency
        , x_conversion_date       => sysdate
        , x_conversion_type       => l_conversion_type
        , x_user_rate             => NULL
        , x_amount                => l_party_available
        , x_max_roll_days         => -1
        );

        OE_DEBUG_PUB.ADD('GL_currency_api.Convert_closest_amount_sql ');
        OE_DEBUG_PUB.ADD('l_base_cur_available  = '
             || TO_CHAR(l_base_cur_available ));

        OE_DEBUG_PUB.ADD('OUT Convert amounts ');

        OE_DEBUG_PUB.ADD('Global_exposure_flag for party always = Y ');

        l_global_exposure_flag := 'Y' ;


        OE_DEBUG_PUB.ADD('IN Insert data into temp table ');

        -----insert data into temp table
        INSERT INTO OE_CREDIT_EXPOSURE_TEMP
        ( party_id
        , party_name
        , party_number
        , party_level
        , party_parent_id
        , report_by_option
        , customer_id
        , customer_name
        , customer_number
        , bill_to_site_id
        , bill_to_site_name
        , credit_limit_currency
        , cr_cur_overall_limit
        , cr_cur_exposure
        , cr_cur_available
        , base_currency
        , base_cur_overall_limit
        , base_cur_exposure
        , base_cur_available
        , unchecked_exposure
        , global_exposure_flag
        )
        VALUES
        ( party_csr_rec.party_id
        , party_csr_rec.Party
        , party_csr_rec.party_number
        , NULL
        , NULL
        , 'PARTY_SUMMARY'
        , NULL
        , NULL
        , NULL
        , NULL
        , NULL
        , party_prof_csr_rec.party_currency_code
        , party_prof_csr_rec.party_overall_limit
        , l_party_total_exposure
        , l_party_available
        , l_base_currency
        , l_base_cur_overall_limit
        , l_base_cur_exposure
        , l_base_cur_available
        , NULL
        , l_global_exposure_flag
        );

      OE_DEBUG_PUB.ADD('OUT Insert data into temp table ');

      ----end loop for party credit profiles
      END LOOP;

      IF l_return_status = 'C'
      THEN
        l_return_status1:='C';

        EXIT;
      END IF;

      ----calculate unchecked exposure
      ----if global variable G_cust_incl_all_flag is 'Y'
      ----then unchecked exposure will be 0
      IF OE_Credit_Engine_GRP.G_cust_incl_all_flag='Y'
      THEN
        OE_DEBUG_PUB.ADD('OE_Credit_Engine_GRP.G_cust_incl_all_flag=Y,
                          so l_party_unchk_exposure=0');
        l_party_unchk_exposure:=0;
      ELSE
        OE_DEBUG_PUB.ADD('IN Get_unchecked_exposure for the party: '
                         ||TO_CHAR(party_csr_rec.party_id));
        Get_unchecked_exposure
        ( p_party_id             => party_csr_rec.party_id
        , p_customer_id          => NULL
        , p_site_id              => NULL
        , p_base_currency        => l_base_currency
        , p_credit_check_rule_id => p_cr_check_rule_id
        , x_unchecked_expousre   => l_party_unchk_exposure
        , x_return_status        => l_return_status
        );
     END IF;

     OE_DEBUG_PUB.ADD('OUT of Get_unchecked_exposure for party: '
                       ||TO_CHAR(party_csr_rec.party_id));
     OE_DEBUG_PUB.ADD('l_party_unchk_exposure = '|| TO_CHAR(l_party_unchk_exposure));
     OE_DEBUG_PUB.ADD('l_return_status = '|| l_return_status );

     IF l_return_status = 'C'
     THEN
       l_return_status1:='C';

       EXIT;

     ELSIF l_return_status = FND_API.G_RET_STS_ERROR
     THEN
       RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
     THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     OE_DEBUG_PUB.ADD('Check if the party has any credit profiles ');
     -----check if the party has any credit profiles
     SELECT COUNT(*)
     INTO l_prof_count
     FROM
       hz_customer_profiles cp
     , hz_cust_profile_amts cpa
     WHERE cp.cust_account_profile_id=cpa.cust_account_profile_id
       AND cp.site_use_id IS NULL
       AND cp.cust_account_id=-1
       AND cp.party_id=party_csr_rec.party_id;

     IF l_prof_count>0
     THEN

      OE_DEBUG_PUB.ADD('Party has credit profiles ');
      OE_DEBUG_PUB.ADD('Update temp table with unchecked exposure ');

      ----update temp table with unchecked exposure
      UPDATE oe_credit_exposure_temp
      SET unchecked_exposure=l_party_unchk_exposure
      WHERE party_id=party_csr_rec.party_id
        AND customer_id IS NULL;

     -----there are no credit profiles for this party
     ----insert unchecked exposure
     ELSE

       OE_DEBUG_PUB.ADD('Party does not have any credit profiles ');
       OE_DEBUG_PUB.ADD('IN Insert data into temp table for unchecked exposure ');

       -----insert data into temp table
        INSERT INTO OE_CREDIT_EXPOSURE_TEMP
        ( party_id
        , party_name
        , party_number
        , party_level
        , party_parent_id
        , report_by_option
        , customer_id
        , customer_name
        , customer_number
        , bill_to_site_id
        , bill_to_site_name
        , credit_limit_currency
        , cr_cur_overall_limit
        , cr_cur_exposure
        , cr_cur_available
        , base_currency
        , base_cur_overall_limit
        , base_cur_exposure
        , base_cur_available
        , unchecked_exposure
        , global_exposure_flag
        )
        VALUES
        ( party_csr_rec.party_id
        , party_csr_rec.Party
        , party_csr_rec.party_number
        , NULL
        , NULL
        , 'PARTY_SUMMARY'
        , NULL
        , NULL
        , NULL
        , NULL
        , NULL
        , NULL
        , NULL
        , NULL
        , NULL
        , l_base_currency
        , NULL
        , NULL
        , NULL
        , l_party_unchk_exposure
        , NULL
        );

       OE_DEBUG_PUB.ADD('Out Insert data into temp table ');

     END IF;

   END LOOP; ----end loop for parties

 -- 5212830

 IF (party_csr1%ISOPEN) THEN
     CLOSE party_csr1;
 END IF;

 IF (party_csr2%ISOPEN) THEN
     CLOSE party_csr2;
 END IF;

 IF (party_csr3%ISOPEN) THEN
     CLOSE party_csr3;
 END IF;

 IF (party_csr4%ISOPEN) THEN
     CLOSE party_csr4;
 END IF;

-- 5212830


   END IF; -- l_type

  --------Party Details Report-----------

  ELSIF p_report_by_option='PARTY_DETAILS'
  THEN
    -----get party_id---
    IF p_specific_party_id IS NOT NULL
    THEN
      l_specific_party_id:= p_specific_party_id;
    ELSE
      l_specific_party_id:= p_spec_party_num_id;
    END IF;

    OE_DEBUG_PUB.ADD('IN Party Detail Report for party_id='||TO_CHAR(l_specific_party_id));

    ---Check if this party is part of Hierarchy AR_CMGT_HIERARCHY_TYPE
    SELECT COUNT(*)
    INTO l_count_hierarchy
    FROM hz_hierarchy_nodes
    WHERE hierarchy_type=l_profile_value
      AND (parent_id = l_specific_party_id
        OR child_id=l_specific_party_id);

    IF l_count_hierarchy>0
    THEN
      OE_DEBUG_PUB.ADD('This party is part of the hierarchy '||l_profile_value);
      ------use cursor for hierarchical parties

      ------start loop for parties
      FOR party_hier_csr_rec IN party_hier_csr
      LOOP

        ----Empty global variables
        OE_Credit_Engine_GRP.G_cust_curr_tbl:=l_empty_curr_tbl;
        OE_Credit_Engine_GRP.G_cust_incl_all_flag:='N';

        ----start loop for party credit profiles
        FOR party_prof_csr_rec  IN party_prof_csr(p_party_id=>party_hier_csr_rec.party_id)
        LOOP
          ------calculate party credit exposure
          OE_CREDIT_ENGINE_GRP.Get_Customer_Exposure
          ( p_party_id              => party_hier_csr_rec.party_id
          , p_customer_id           => NULL
          , p_site_id               => NULL
          , p_limit_curr_code       => party_prof_csr_rec.party_currency_code
          , p_credit_check_rule_id  => p_cr_check_rule_id
          , p_need_exposure_details => 'N'
          , x_total_exposure        => l_party_total_exposure
          , x_order_hold_amount     => l_order_hold_amount
          , x_order_amount          => l_order_amount
          , x_ar_amount             => l_ar_amount
          , x_external_amount       => l_external_amount
          , x_return_status         => l_return_status
          );


          OE_DEBUG_PUB.ADD('OEXPCRGB: OUT of Get_Customer_Exposure ');
          OE_DEBUG_PUB.ADD('l_return_status = '|| l_return_status );

          IF l_return_status = 'C'
          THEN
            l_return_status1:='C';

            EXIT;

          ELSIF l_return_status = FND_API.G_RET_STS_ERROR
          THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
          THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

          -----calculate available credit
          l_party_available:=party_prof_csr_rec.party_overall_limit - l_party_total_exposure;


          -----convert overall_credit_limit, exposure and available credit into base currency
          OE_DEBUG_PUB.ADD('IN Convert amounts ');

          l_base_cur_overall_limit :=
          GL_CURRENCY_API.Convert_closest_amount_sql
          ( x_from_currency         => party_prof_csr_rec.party_currency_code
          , x_to_currency           => l_base_currency
          , x_conversion_date       => sysdate
          , x_conversion_type       => l_conversion_type
          , x_user_rate             => NULL
          , x_amount                => party_prof_csr_rec.party_overall_limit
          , x_max_roll_days         => -1
          );

          OE_DEBUG_PUB.ADD('GL_currency_api.Convert_closest_amount_sql ');
          OE_DEBUG_PUB.ADD('l_base_cur_overall_limit = '|| TO_CHAR(l_base_cur_overall_limit));

          l_base_cur_exposure      :=
          GL_CURRENCY_API.Convert_closest_amount_sql
          ( x_from_currency         => party_prof_csr_rec.party_currency_code
          , x_to_currency           => l_base_currency
          , x_conversion_date       => sysdate
          , x_conversion_type       => l_conversion_type
          , x_user_rate             => NULL
          , x_amount                => l_party_total_exposure
          , x_max_roll_days         => -1
          );

          OE_DEBUG_PUB.ADD('GL_currency_api.Convert_closest_amount_sql ');
          OE_DEBUG_PUB.ADD('l_base_cur_exposure = '|| TO_CHAR(l_base_cur_exposure));

          l_base_cur_available     :=
          GL_CURRENCY_API.Convert_closest_amount_sql
          ( x_from_currency         => party_prof_csr_rec.party_currency_code
          , x_to_currency           => l_base_currency
          , x_conversion_date       => sysdate
          , x_conversion_type       => l_conversion_type
          , x_user_rate             => NULL
          , x_amount                => l_party_available
          , x_max_roll_days         => -1
          );

          OE_DEBUG_PUB.ADD('GL_currency_api.Convert_closest_amount_sql ');
          OE_DEBUG_PUB.ADD('l_base_cur_available  = '
               || TO_CHAR(l_base_cur_available ));

          OE_DEBUG_PUB.ADD('OUT Convert amounts ');

          OE_DEBUG_PUB.ADD('Global_exposure_flag for party always = Y ');

          l_global_exposure_flag := 'Y' ;

          OE_DEBUG_PUB.ADD('IN Insert data into temp table ');

          -----insert data into temp table
          INSERT INTO OE_CREDIT_EXPOSURE_TEMP
          ( party_id
          , party_name
          , party_number
          , party_level
          , party_parent_id
          , report_by_option
          , customer_id
          , customer_name
          , customer_number
          , bill_to_site_id
          , bill_to_site_name
          , credit_limit_currency
          , cr_cur_overall_limit
          , cr_cur_exposure
          , cr_cur_available
          , base_currency
          , base_cur_overall_limit
          , base_cur_exposure
          , base_cur_available
          , unchecked_exposure
          , global_exposure_flag
          )
          VALUES
          ( party_hier_csr_rec.party_id
          , party_hier_csr_rec.Party
          , party_hier_csr_rec.party_number
          , party_hier_csr_rec.level_number
          , l_specific_party_id
          , 'PARTY_DETAILS'
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , party_prof_csr_rec.party_currency_code
          , party_prof_csr_rec.party_overall_limit
          , l_party_total_exposure
          , l_party_available
          , l_base_currency
          , l_base_cur_overall_limit
          , l_base_cur_exposure
          , l_base_cur_available
          , NULL
          , l_global_exposure_flag
          );

        OE_DEBUG_PUB.ADD('OUT Insert data into temp table ');

        ----end loop for party credit profiles
        END LOOP;

        IF l_return_status = 'C'
        THEN
          l_return_status1:='C';

          EXIT;
        END IF;

        ----calculate unchecked exposure
        ----if global variable G_cust_incl_all_flag is 'Y'
        ----then unchecked exposure will be 0
        IF OE_Credit_Engine_GRP.G_cust_incl_all_flag='Y'
        THEN
          OE_DEBUG_PUB.ADD('OE_Credit_Engine_GRP.G_cust_incl_all_flag=Y,
                            so l_party_unchk_exposure=0');
          l_party_unchk_exposure:=0;
        ELSE
          OE_DEBUG_PUB.ADD('IN Get_unchecked_exposure for the party: '
                           ||TO_CHAR(party_hier_csr_rec.party_id));
          Get_unchecked_exposure
          ( p_party_id             => party_hier_csr_rec.party_id
          , p_customer_id          => NULL
          , p_site_id              => NULL
          , p_base_currency        => l_base_currency
          , p_credit_check_rule_id => p_cr_check_rule_id
          , x_unchecked_expousre   => l_party_unchk_exposure
          , x_return_status        => l_return_status
          );
       END IF;

       OE_DEBUG_PUB.ADD('OUT of Get_unchecked_exposure, for the party:'
                        ||TO_CHAR(party_hier_csr_rec.party_id));
       OE_DEBUG_PUB.ADD('l_party_unchk_exposure = '|| TO_CHAR(l_party_unchk_exposure));
       OE_DEBUG_PUB.ADD('l_return_status = '|| l_return_status );

       IF l_return_status = 'C'
       THEN
         l_return_status1:='C';

         EXIT;

       ELSIF l_return_status = FND_API.G_RET_STS_ERROR
       THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
       THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       OE_DEBUG_PUB.ADD('Check if the party has any credit profiles ');
       -----check if the party has any credit profiles
       SELECT COUNT(*)
       INTO l_prof_count
       FROM
         hz_customer_profiles cp
       , hz_cust_profile_amts cpa
       WHERE cp.cust_account_profile_id=cpa.cust_account_profile_id
         AND cp.site_use_id IS NULL
         AND cp.cust_account_id=-1
         AND cp.party_id=party_hier_csr_rec.party_id;

       IF l_prof_count>0
       THEN

        OE_DEBUG_PUB.ADD('Party has credit profiles ');
        OE_DEBUG_PUB.ADD('Update temp table with unchecked exposure ');

        ----update temp table with unchecked exposure
        UPDATE oe_credit_exposure_temp
        SET unchecked_exposure=l_party_unchk_exposure
        WHERE party_id=party_hier_csr_rec.party_id
          AND customer_id IS NULL;

       -----there are no credit profiles for this party
       ----insert unchecked exposure
       ELSE

         OE_DEBUG_PUB.ADD('Party does not have any credit profiles ');
         OE_DEBUG_PUB.ADD('IN Insert data into temp table for unchecked exposure ');

         -----insert data into temp table
         INSERT INTO OE_CREDIT_EXPOSURE_TEMP
         ( party_id
         , party_name
         , party_number
         , party_level
         , party_parent_id
         , report_by_option
         , customer_id
         , customer_name
         , customer_number
         , bill_to_site_id
         , bill_to_site_name
         , credit_limit_currency
         , cr_cur_overall_limit
         , cr_cur_exposure
         , cr_cur_available
         , base_currency
         , base_cur_overall_limit
         , base_cur_exposure
         , base_cur_available
         , unchecked_exposure
         , global_exposure_flag
         )
         VALUES
         ( party_hier_csr_rec.party_id
         , party_hier_csr_rec.Party
         , party_hier_csr_rec.party_number
         , party_hier_csr_rec.level_number
         , l_specific_party_id
         , 'PARTY_DETAILS'
         , NULL
         , NULL
         , NULL
         , NULL
         , NULL
         , NULL
         , NULL
         , NULL
         , NULL
         , l_base_currency
         , NULL
         , NULL
         , NULL
         , l_party_unchk_exposure
         , 'Y'
         );

         OE_DEBUG_PUB.ADD('Out Insert data into temp table ');

       END IF; ---end of checking if the party has credit profiles

       ------start report for cust accounts for the specific party

       OE_DEBUG_PUB.ADD('IN Cust accounts section of the Party Deatils Report');

      ------start loop for customers
      FOR party_cust_csr_rec IN party_cust_csr (p_party_id => party_hier_csr_rec.party_id)
      LOOP

        ----Empty global variables
        OE_Credit_Engine_GRP.G_cust_curr_tbl:=l_empty_curr_tbl;
        OE_Credit_Engine_GRP.G_cust_incl_all_flag:='N';

        ----start loop for customer credit profiles
        FOR cust_prof_csr_rec  IN cust_prof_csr(p_customer_id=>party_cust_csr_rec.customer_id)
        LOOP
           ------calculate customer credit exposure
          OE_CREDIT_ENGINE_GRP.Get_Customer_Exposure
          ( p_customer_id          => party_cust_csr_rec.customer_id
          , p_site_id              => NULL
          , p_limit_curr_code      => cust_prof_csr_rec.cust_currency_code
          , p_credit_check_rule_id => p_cr_check_rule_id
          , x_total_exposure       => l_cust_total_exposure
          , x_return_status        => l_return_status
          );


          OE_DEBUG_PUB.ADD('OEXPCRGB: OUT of Get_Customer_Exposure ');
          OE_DEBUG_PUB.ADD('l_return_status = '|| l_return_status );

          IF l_return_status = 'C'
          THEN
            l_return_status1:='C';

            EXIT;

          ELSIF l_return_status = FND_API.G_RET_STS_ERROR
          THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
          THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

          -----calculate available credit
          l_cust_available:=cust_prof_csr_rec.cust_overall_limit - l_cust_total_exposure;


          -----convert overall_credit_limit, exposure and available credit into base currency
          OE_DEBUG_PUB.ADD('IN Convert amounts ');

          l_base_cur_overall_limit :=
          GL_CURRENCY_API.Convert_closest_amount_sql
          ( x_from_currency         => cust_prof_csr_rec.cust_currency_code
          , x_to_currency           => l_base_currency
          , x_conversion_date       => sysdate
          , x_conversion_type       => l_conversion_type
          , x_user_rate             => NULL
          , x_amount                => cust_prof_csr_rec.cust_overall_limit
          , x_max_roll_days         => -1
          );

          OE_DEBUG_PUB.ADD('GL_currency_api.Convert_closest_amount_sql ');
          OE_DEBUG_PUB.ADD('l_base_cur_overall_limit = '|| TO_CHAR(l_base_cur_overall_limit));

          l_base_cur_exposure      :=
          GL_CURRENCY_API.Convert_closest_amount_sql
          ( x_from_currency         => cust_prof_csr_rec.cust_currency_code
          , x_to_currency           => l_base_currency
          , x_conversion_date       => sysdate
          , x_conversion_type       => l_conversion_type
          , x_user_rate             => NULL
          , x_amount                => l_cust_total_exposure
          , x_max_roll_days         => -1
          );

          OE_DEBUG_PUB.ADD('GL_currency_api.Convert_closest_amount_sql ');
          OE_DEBUG_PUB.ADD('l_base_cur_exposure = '|| TO_CHAR(l_base_cur_exposure));

          l_base_cur_available     :=
          GL_CURRENCY_API.Convert_closest_amount_sql
          ( x_from_currency         => cust_prof_csr_rec.cust_currency_code
          , x_to_currency           => l_base_currency
          , x_conversion_date       => sysdate
          , x_conversion_type       => l_conversion_type
          , x_user_rate             => NULL
          , x_amount                => l_cust_available
          , x_max_roll_days         => -1
          );

          OE_DEBUG_PUB.ADD('GL_currency_api.Convert_closest_amount_sql ');
          OE_DEBUG_PUB.ADD('l_base_cur_available  = '
               || TO_CHAR(l_base_cur_available ));

          OE_DEBUG_PUB.ADD('OUT Convert amounts ');

          OE_DEBUG_PUB.ADD('call Get_global_exposure_flag ');

          l_global_exposure_flag :=
          OE_CREDIT_CHECK_UTIL.Get_global_exposure_flag
          (  p_entity_type     => 'CUSTOMER'
           , p_entity_id       => party_cust_csr_rec.customer_id
           , p_limit_curr_code =>  cust_prof_csr_rec.cust_currency_code
           ) ;

          OE_DEBUG_PUB.ADD('l_global_exposure_flag => '||
                l_global_exposure_flag );

          OE_DEBUG_PUB.ADD('IN Insert data into temp table ');

          -----insert data into temp table
          INSERT INTO OE_CREDIT_EXPOSURE_TEMP
          ( party_id
          , party_name
          , party_number
          , party_level
          , party_parent_id
          , report_by_option
          , customer_id
          , customer_name
          , customer_number
          , bill_to_site_id
          , bill_to_site_name
          , credit_limit_currency
          , cr_cur_overall_limit
          , cr_cur_exposure
          , cr_cur_available
          , base_currency
          , base_cur_overall_limit
          , base_cur_exposure
          , base_cur_available
          , unchecked_exposure
          , global_exposure_flag
          )
          VALUES
          ( party_hier_csr_rec.party_id
          , party_hier_csr_rec.Party
          , party_hier_csr_rec.party_number
          , party_hier_csr_rec.level_number
          , l_specific_party_id
          , 'PARTY_DETAILS'
          , party_cust_csr_rec.customer_id
          , party_cust_csr_rec.Customer
          , party_cust_csr_rec.customer_number
          , NULL
          , NULL
          , cust_prof_csr_rec.cust_currency_code
          , cust_prof_csr_rec.cust_overall_limit
          , l_cust_total_exposure
          , l_cust_available
          , l_base_currency
          , l_base_cur_overall_limit
          , l_base_cur_exposure
          , l_base_cur_available
          , NULL
          , l_global_exposure_flag
          );

        OE_DEBUG_PUB.ADD('OUT Insert data into temp table ');

        ----end loop for customer credit profiles
        END LOOP;

        IF l_return_status = 'C'
        THEN
          l_return_status1:='C';

          EXIT;
        END IF;


        ----calculate unchecked exposure
        ----if global variable G_cust_incl_all_flag is 'Y'
        ----then unchecked exposure will be 0

        IF OE_Credit_Engine_GRP.G_cust_incl_all_flag='Y'
        THEN
          OE_DEBUG_PUB.ADD('OE_Credit_Engine_GRP.G_cust_incl_all_flag=Y,
                            so l_cust_unchk_exposure=0');
          l_cust_unchk_exposure:=0;
        ELSE

          OE_DEBUG_PUB.ADD('IN Get_unchecked_exposure for the customer '
                           ||TO_CHAR(party_cust_csr_rec.customer_id));

          Get_unchecked_exposure
          ( p_party_id             => NULL
          , p_customer_id          => party_cust_csr_rec.customer_id
          , p_site_id              => NULL
          , p_base_currency        => l_base_currency
          , p_credit_check_rule_id => p_cr_check_rule_id
          , x_unchecked_expousre   => l_cust_unchk_exposure
          , x_return_status        => l_return_status
          );
       END IF;

       OE_DEBUG_PUB.ADD('OUT of Get_unchecked_exposure,for the customer: '
                        ||TO_CHAR(party_cust_csr_rec.customer_id));
       OE_DEBUG_PUB.ADD('l_cust_unchk_exposure = '|| TO_CHAR(l_cust_unchk_exposure) );
       OE_DEBUG_PUB.ADD('l_return_status = '|| l_return_status );

       IF l_return_status = 'C'
       THEN
         l_return_status1:='C';

         EXIT;

       ELSIF l_return_status = FND_API.G_RET_STS_ERROR
       THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
       THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       OE_DEBUG_PUB.ADD('Check if the customer has any credit profiles ');
       -----check if the customer has any credit profiles
       SELECT COUNT(*)
       INTO l_prof_count
       FROM
         hz_customer_profiles cp
       , hz_cust_profile_amts cpa
       WHERE cp.cust_account_profile_id=cpa.cust_account_profile_id
         AND cp.site_use_id IS NULL
         AND cp.cust_account_id=party_cust_csr_rec.customer_id;

       IF l_prof_count>0
       THEN

        OE_DEBUG_PUB.ADD('Customer has credit profiles ');
        OE_DEBUG_PUB.ADD('Update temp table with unchecked exposure ');

        ----update temp table with unchecked exposure
        UPDATE oe_credit_exposure_temp
        SET unchecked_exposure=l_cust_unchk_exposure
        WHERE customer_id=party_cust_csr_rec.customer_id
          AND party_id=party_hier_csr_rec.party_id
          AND bill_to_site_id IS NULL
          AND report_by_option='PARTY_DETAILS';

       -----there are no credit profiles for this customer
       ----insert unchecked exposure
       ELSE

         OE_DEBUG_PUB.ADD('Customer does not have any credit profiles ');
         OE_DEBUG_PUB.ADD('IN Insert data into temp table for unchecked exposure ');

         -----insert data into temp table
          INSERT INTO OE_CREDIT_EXPOSURE_TEMP
          ( party_id
          , party_name
          , party_number
          , party_level
          , party_parent_id
          , report_by_option
          , customer_id
          , customer_name
          , customer_number
          , bill_to_site_id
          , bill_to_site_name
          , credit_limit_currency
          , cr_cur_overall_limit
          , cr_cur_exposure
          , cr_cur_available
          , base_currency
          , base_cur_overall_limit
          , base_cur_exposure
          , base_cur_available
          , unchecked_exposure
          , global_exposure_flag
          )
          VALUES
          ( party_hier_csr_rec.party_id
          , party_hier_csr_rec.Party
          , party_hier_csr_rec.party_number
          , party_hier_csr_rec.level_number
          , l_specific_party_id
          , 'PARTY_DETAILS'
          , party_cust_csr_rec.customer_id
          , party_cust_csr_rec.Customer
          , party_cust_csr_rec.customer_number
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , l_base_currency
          , NULL
          , NULL
          , NULL
          , l_cust_unchk_exposure
          , 'Y'
          );

         OE_DEBUG_PUB.ADD('Out Insert data into temp table ');

       END IF; --end of checking if the customer has credit profile

      ----end loop for customers
      END LOOP;

     END LOOP; ----end loop for parties





   -----party is not part of the hierarchy
   ELSE
     OE_DEBUG_PUB.ADD('This party is not part of the hierarchy '||l_profile_value);
      ------use cursor for non hierarchical parties

      ------start loop for parties
      FOR party_hier_csr1_rec IN party_hier_csr1
      LOOP

        ----Empty global variables
        OE_Credit_Engine_GRP.G_cust_curr_tbl:=l_empty_curr_tbl;
        OE_Credit_Engine_GRP.G_cust_incl_all_flag:='N';

        ----start loop for party credit profiles
        FOR party_prof_csr_rec  IN party_prof_csr(p_party_id=>party_hier_csr1_rec.party_id)
        LOOP
          ------calculate party credit exposure
          OE_CREDIT_ENGINE_GRP.Get_Customer_Exposure
          ( p_party_id              => party_hier_csr1_rec.party_id
          , p_customer_id           => NULL
          , p_site_id               => NULL
          , p_limit_curr_code       => party_prof_csr_rec.party_currency_code
          , p_credit_check_rule_id  => p_cr_check_rule_id
          , p_need_exposure_details => 'N'
          , x_total_exposure        => l_party_total_exposure
          , x_order_hold_amount     => l_order_hold_amount
          , x_order_amount          => l_order_amount
          , x_ar_amount             => l_ar_amount
          , x_external_amount       => l_external_amount
          , x_return_status         => l_return_status
          );


          OE_DEBUG_PUB.ADD('OEXPCRGB: OUT of Get_Customer_Exposure ');
          OE_DEBUG_PUB.ADD('l_return_status = '|| l_return_status );

          IF l_return_status = 'C'
          THEN
            l_return_status1:='C';

            EXIT;

          ELSIF l_return_status = FND_API.G_RET_STS_ERROR
          THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
          THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

          -----calculate available credit
          l_party_available:=party_prof_csr_rec.party_overall_limit - l_party_total_exposure;


          -----convert overall_credit_limit, exposure and available credit into base currency
          OE_DEBUG_PUB.ADD('IN Convert amounts ');

          l_base_cur_overall_limit :=
          GL_CURRENCY_API.Convert_closest_amount_sql
          ( x_from_currency         => party_prof_csr_rec.party_currency_code
          , x_to_currency           => l_base_currency
          , x_conversion_date       => sysdate
          , x_conversion_type       => l_conversion_type
          , x_user_rate             => NULL
          , x_amount                => party_prof_csr_rec.party_overall_limit
          , x_max_roll_days         => -1
          );

          OE_DEBUG_PUB.ADD('GL_currency_api.Convert_closest_amount_sql ');
          OE_DEBUG_PUB.ADD('l_base_cur_overall_limit = '|| TO_CHAR(l_base_cur_overall_limit));

          l_base_cur_exposure      :=
          GL_CURRENCY_API.Convert_closest_amount_sql
          ( x_from_currency         => party_prof_csr_rec.party_currency_code
          , x_to_currency           => l_base_currency
          , x_conversion_date       => sysdate
          , x_conversion_type       => l_conversion_type
          , x_user_rate             => NULL
          , x_amount                => l_party_total_exposure
          , x_max_roll_days         => -1
          );

          OE_DEBUG_PUB.ADD('GL_currency_api.Convert_closest_amount_sql ');
          OE_DEBUG_PUB.ADD('l_base_cur_exposure = '|| TO_CHAR(l_base_cur_exposure));

          l_base_cur_available     :=
          GL_CURRENCY_API.Convert_closest_amount_sql
          ( x_from_currency         => party_prof_csr_rec.party_currency_code
          , x_to_currency           => l_base_currency
          , x_conversion_date       => sysdate
          , x_conversion_type       => l_conversion_type
          , x_user_rate             => NULL
          , x_amount                => l_party_available
          , x_max_roll_days         => -1
          );

          OE_DEBUG_PUB.ADD('GL_currency_api.Convert_closest_amount_sql ');
          OE_DEBUG_PUB.ADD('l_base_cur_available  = '
               || TO_CHAR(l_base_cur_available ));

          OE_DEBUG_PUB.ADD('OUT Convert amounts ');

          OE_DEBUG_PUB.ADD('Global_exposure_flag for party always = Y ');

          l_global_exposure_flag := 'Y' ;

          OE_DEBUG_PUB.ADD('IN Insert data into temp table ');

          -----insert data into temp table
          INSERT INTO OE_CREDIT_EXPOSURE_TEMP
          ( party_id
          , party_name
          , party_number
          , party_level
          , party_parent_id
          , report_by_option
          , customer_id
          , customer_name
          , customer_number
          , bill_to_site_id
          , bill_to_site_name
          , credit_limit_currency
          , cr_cur_overall_limit
          , cr_cur_exposure
          , cr_cur_available
          , base_currency
          , base_cur_overall_limit
          , base_cur_exposure
          , base_cur_available
          , unchecked_exposure
          , global_exposure_flag
          )
          VALUES
          ( party_hier_csr1_rec.party_id
          , party_hier_csr1_rec.Party
          , party_hier_csr1_rec.party_number
          , 0
          , l_specific_party_id
          , 'PARTY_DETAILS'
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , party_prof_csr_rec.party_currency_code
          , party_prof_csr_rec.party_overall_limit
          , l_party_total_exposure
          , l_party_available
          , l_base_currency
          , l_base_cur_overall_limit
          , l_base_cur_exposure
          , l_base_cur_available
          , NULL
          , l_global_exposure_flag
          );

        OE_DEBUG_PUB.ADD('OUT Insert data into temp table ');

        ----end loop for party credit profiles
        END LOOP;

        IF l_return_status = 'C'
        THEN
          l_return_status1:='C';

          EXIT;
        END IF;

        ----calculate unchecked exposure
        ----if global variable G_cust_incl_all_flag is 'Y'
        ----then unchecked exposure will be 0
        IF OE_Credit_Engine_GRP.G_cust_incl_all_flag='Y'
        THEN
          OE_DEBUG_PUB.ADD('OE_Credit_Engine_GRP.G_cust_incl_all_flag=Y,
                             so l_party_unchk_exposure=0');

          l_party_unchk_exposure:=0;
        ELSE
          OE_DEBUG_PUB.ADD('IN Get_unchecked_exposure for the party: '
                            ||TO_CHAR(party_hier_csr1_rec.party_id));

          Get_unchecked_exposure
          ( p_party_id             => party_hier_csr1_rec.party_id
          , p_customer_id          => NULL
          , p_site_id              => NULL
          , p_base_currency        => l_base_currency
          , p_credit_check_rule_id => p_cr_check_rule_id
          , x_unchecked_expousre   => l_party_unchk_exposure
          , x_return_status        => l_return_status
          );
       END IF;

       OE_DEBUG_PUB.ADD('OUT of Get_unchecked_exposure for the party: '
                        ||TO_CHAR(party_hier_csr1_rec.party_id));
       OE_DEBUG_PUB.ADD('l_party_unchk_exposure = '|| TO_CHAR(l_party_unchk_exposure) );
       OE_DEBUG_PUB.ADD('l_return_status = '|| l_return_status );

       IF l_return_status = 'C'
       THEN
         l_return_status1:='C';

         EXIT;

       ELSIF l_return_status = FND_API.G_RET_STS_ERROR
       THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
       THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       OE_DEBUG_PUB.ADD('Check if the party has any credit profiles ');
       -----check if the party has any credit profiles
       SELECT COUNT(*)
       INTO l_prof_count
       FROM
         hz_customer_profiles cp
       , hz_cust_profile_amts cpa
       WHERE cp.cust_account_profile_id=cpa.cust_account_profile_id
         AND cp.site_use_id IS NULL
         AND cp.cust_account_id=-1
         AND cp.party_id=party_hier_csr1_rec.party_id;

       IF l_prof_count>0
       THEN

        OE_DEBUG_PUB.ADD('Party has credit profiles ');
        OE_DEBUG_PUB.ADD('Update temp table with unchecked exposure ');

        ----update temp table with unchecked exposure
        UPDATE oe_credit_exposure_temp
        SET unchecked_exposure=l_party_unchk_exposure
        WHERE party_id=party_hier_csr1_rec.party_id
          AND customer_id IS NULL;

       -----there are no credit profiles for this party
       ----insert unchecked exposure
       ELSE

         OE_DEBUG_PUB.ADD('Party does not have any credit profiles ');
         OE_DEBUG_PUB.ADD('IN Insert data into temp table for unchecked exposure ');

         -----insert data into temp table
         INSERT INTO OE_CREDIT_EXPOSURE_TEMP
         ( party_id
         , party_name
         , party_number
         , party_level
         , party_parent_id
         , report_by_option
         , customer_id
         , customer_name
         , customer_number
         , bill_to_site_id
         , bill_to_site_name
         , credit_limit_currency
         , cr_cur_overall_limit
         , cr_cur_exposure
         , cr_cur_available
         , base_currency
         , base_cur_overall_limit
         , base_cur_exposure
         , base_cur_available
         , unchecked_exposure
         , global_exposure_flag
         )
         VALUES
         ( party_hier_csr1_rec.party_id
         , party_hier_csr1_rec.Party
         , party_hier_csr1_rec.party_number
         , 0
         , l_specific_party_id
         , 'PARTY_DETAILS'
         , NULL
         , NULL
         , NULL
         , NULL
         , NULL
         , NULL
         , NULL
         , NULL
         , NULL
         , l_base_currency
         , NULL
         , NULL
         , NULL
         , l_party_unchk_exposure
         , 'Y'
         );

         OE_DEBUG_PUB.ADD('Out Insert data into temp table ');

       END IF; ---end of checking if the party has credit profiles

       ------start report for cust accounts for the specific party

       OE_DEBUG_PUB.ADD('IN Cust accounts section of the Party Details Report');
       OE_DEBUG_PUB.ADD('party_hier_csr1_rec.party_id ==> '||
         party_hier_csr1_rec.party_id );

      ------start loop for customers
      FOR party_cust_csr_rec IN party_cust_csr (p_party_id => party_hier_csr1_rec.party_id)
      LOOP

        ----Empty global variables
        OE_Credit_Engine_GRP.G_cust_curr_tbl:=l_empty_curr_tbl;
        OE_Credit_Engine_GRP.G_cust_incl_all_flag:='N';

        ----start loop for customer credit profiles
        FOR cust_prof_csr_rec  IN cust_prof_csr(p_customer_id=>party_cust_csr_rec.customer_id)
        LOOP
           ------calculate customer credit exposure
          OE_CREDIT_ENGINE_GRP.Get_Customer_Exposure
          ( p_customer_id          => party_cust_csr_rec.customer_id
          , p_site_id              => NULL
          , p_limit_curr_code      => cust_prof_csr_rec.cust_currency_code
          , p_credit_check_rule_id => p_cr_check_rule_id
          , x_total_exposure       => l_cust_total_exposure
          , x_return_status        => l_return_status
          );


          OE_DEBUG_PUB.ADD('OEXPCRGB: OUT of Get_Customer_Exposure ');
          OE_DEBUG_PUB.ADD('l_return_status = '|| l_return_status );

          IF l_return_status = 'C'
          THEN
            l_return_status1:='C';

            EXIT;

          ELSIF l_return_status = FND_API.G_RET_STS_ERROR
          THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
          THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

          -----calculate available credit
          l_cust_available:=cust_prof_csr_rec.cust_overall_limit - l_cust_total_exposure;


          -----convert overall_credit_limit, exposure and available credit into base currency
          OE_DEBUG_PUB.ADD('IN Convert amounts ');

          l_base_cur_overall_limit :=
          GL_CURRENCY_API.Convert_closest_amount_sql
          ( x_from_currency         => cust_prof_csr_rec.cust_currency_code
          , x_to_currency           => l_base_currency
          , x_conversion_date       => sysdate
          , x_conversion_type       => l_conversion_type
          , x_user_rate             => NULL
          , x_amount                => cust_prof_csr_rec.cust_overall_limit
          , x_max_roll_days         => -1
          );

          OE_DEBUG_PUB.ADD('GL_currency_api.Convert_closest_amount_sql ');
          OE_DEBUG_PUB.ADD('l_base_cur_overall_limit = '|| TO_CHAR(l_base_cur_overall_limit));

          l_base_cur_exposure      :=
          GL_CURRENCY_API.Convert_closest_amount_sql
          ( x_from_currency         => cust_prof_csr_rec.cust_currency_code
          , x_to_currency           => l_base_currency
          , x_conversion_date       => sysdate
          , x_conversion_type       => l_conversion_type
          , x_user_rate             => NULL
          , x_amount                => l_cust_total_exposure
          , x_max_roll_days         => -1
          );

          OE_DEBUG_PUB.ADD('GL_currency_api.Convert_closest_amount_sql ');
          OE_DEBUG_PUB.ADD('l_base_cur_exposure = '|| TO_CHAR(l_base_cur_exposure));

          l_base_cur_available     :=
          GL_CURRENCY_API.Convert_closest_amount_sql
          ( x_from_currency         => cust_prof_csr_rec.cust_currency_code
          , x_to_currency           => l_base_currency
          , x_conversion_date       => sysdate
          , x_conversion_type       => l_conversion_type
          , x_user_rate             => NULL
          , x_amount                => l_cust_available
          , x_max_roll_days         => -1
          );

          OE_DEBUG_PUB.ADD('GL_currency_api.Convert_closest_amount_sql ');
          OE_DEBUG_PUB.ADD('l_base_cur_available  = '
               || TO_CHAR(l_base_cur_available ));

          OE_DEBUG_PUB.ADD('OUT Convert amounts ');

          OE_DEBUG_PUB.ADD('call Get_global_exposure_flag ');

          l_global_exposure_flag :=
          OE_CREDIT_CHECK_UTIL.Get_global_exposure_flag
          (  p_entity_type     => 'CUSTOMER'
           , p_entity_id       => party_cust_csr_rec.customer_id
           , p_limit_curr_code =>  cust_prof_csr_rec.cust_currency_code
           ) ;

          OE_DEBUG_PUB.ADD('l_global_exposure_flag => '||
                l_global_exposure_flag );

          OE_DEBUG_PUB.ADD('IN Insert data into temp table ');

          -----insert data into temp table
          INSERT INTO OE_CREDIT_EXPOSURE_TEMP
          ( party_id
          , party_name
          , party_number
          , party_level
          , party_parent_id
          , report_by_option
          , customer_id
          , customer_name
          , customer_number
          , bill_to_site_id
          , bill_to_site_name
          , credit_limit_currency
          , cr_cur_overall_limit
          , cr_cur_exposure
          , cr_cur_available
          , base_currency
          , base_cur_overall_limit
          , base_cur_exposure
          , base_cur_available
          , unchecked_exposure
          , global_exposure_flag
          )
          VALUES
          ( party_hier_csr1_rec.party_id
          , party_hier_csr1_rec.Party
          , party_hier_csr1_rec.party_number
          , 0
          , l_specific_party_id
          , 'PARTY_DETAILS'
          , party_cust_csr_rec.customer_id
          , party_cust_csr_rec.Customer
          , party_cust_csr_rec.customer_number
          , NULL
          , NULL
          , cust_prof_csr_rec.cust_currency_code
          , cust_prof_csr_rec.cust_overall_limit
          , l_cust_total_exposure
          , l_cust_available
          , l_base_currency
          , l_base_cur_overall_limit
          , l_base_cur_exposure
          , l_base_cur_available
          , NULL
          , 'Y'
          );

        OE_DEBUG_PUB.ADD('OUT Insert data into temp table ');

        ----end loop for customer credit profiles
        END LOOP;

        IF l_return_status = 'C'
        THEN
          l_return_status1:='C';

          EXIT;
        END IF;

        ----calculate unchecked exposure
        ----if global variable G_cust_incl_all_flag is 'Y'
        ----then unchecked exposure will be 0
        IF OE_Credit_Engine_GRP.G_cust_incl_all_flag='Y'
        THEN
          OE_DEBUG_PUB.ADD('OE_Credit_Engine_GRP.G_cust_incl_all_flag=Y,
                            so l_cust_unchk_exposure=0');

          l_cust_unchk_exposure:=0;
        ELSE
          OE_DEBUG_PUB.ADD('IN Get_unchecked_exposure for the customer='
                           ||TO_CHAR(party_cust_csr_rec.customer_id));

          Get_unchecked_exposure
          ( p_party_id             => NULL
          , p_customer_id          => party_cust_csr_rec.customer_id
          , p_site_id              => NULL
          , p_base_currency        => l_base_currency
          , p_credit_check_rule_id => p_cr_check_rule_id
          , x_unchecked_expousre   => l_cust_unchk_exposure
          , x_return_status        => l_return_status
          );
       END IF;

       OE_DEBUG_PUB.ADD('OUT of Get_unchecked_exposure,for the customer='
                        ||TO_CHAR(party_cust_csr_rec.customer_id) );
       OE_DEBUG_PUB.ADD('l_cust_unchk_exposure = '|| TO_CHAR(l_cust_unchk_exposure));
       OE_DEBUG_PUB.ADD('l_return_status = '|| l_return_status );

       IF l_return_status = 'C'
       THEN
         l_return_status1:='C';

         EXIT;

       ELSIF l_return_status = FND_API.G_RET_STS_ERROR
       THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
       THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       OE_DEBUG_PUB.ADD('Check if the customer has any credit profiles ');
       -----check if the customer has any credit profiles
       SELECT COUNT(*)
       INTO l_prof_count
       FROM
         hz_customer_profiles cp
       , hz_cust_profile_amts cpa
       WHERE cp.cust_account_profile_id=cpa.cust_account_profile_id
         AND cp.site_use_id IS NULL
         AND cp.cust_account_id=party_cust_csr_rec.customer_id;

       IF l_prof_count>0
       THEN

        OE_DEBUG_PUB.ADD('Customer has credit profiles ');
        OE_DEBUG_PUB.ADD('Update temp table with unchecked exposure ');

        ----update temp table with unchecked exposure
        UPDATE oe_credit_exposure_temp
        SET unchecked_exposure=l_cust_unchk_exposure
        WHERE customer_id=party_cust_csr_rec.customer_id
          AND party_id=party_hier_csr1_rec.party_id
          AND bill_to_site_id IS NULL
          AND report_by_option='PARTY_DETAILS';

       -----there are no credit profiles for this customer
       ----insert unchecked exposure
       ELSE

         OE_DEBUG_PUB.ADD('Customer does not have any credit profiles ');
         OE_DEBUG_PUB.ADD('IN Insert data into temp table for unchecked exposure ');

         -----insert data into temp table
          INSERT INTO OE_CREDIT_EXPOSURE_TEMP
          ( party_id
          , party_name
          , party_number
          , party_level
          , party_parent_id
          , report_by_option
          , customer_id
          , customer_name
          , customer_number
          , bill_to_site_id
          , bill_to_site_name
          , credit_limit_currency
          , cr_cur_overall_limit
          , cr_cur_exposure
          , cr_cur_available
          , base_currency
          , base_cur_overall_limit
          , base_cur_exposure
          , base_cur_available
          , unchecked_exposure
          , global_exposure_flag
          )
          VALUES
          ( party_hier_csr1_rec.party_id
          , party_hier_csr1_rec.Party
          , party_hier_csr1_rec.party_number
          , 0
          , l_specific_party_id
          , 'PARTY_DETAILS'
          , party_cust_csr_rec.customer_id
          , party_cust_csr_rec.Customer
          , party_cust_csr_rec.customer_number
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , l_base_currency
          , NULL
          , NULL
          , NULL
          , l_cust_unchk_exposure
          , 'Y'
          );

         OE_DEBUG_PUB.ADD('Out Insert data into temp table ');

       END IF; --end of checking if the customer has credit profile

      ----end loop for customers
      END LOOP;

     END LOOP; ----end loop for parties

         OE_DEBUG_PUB.ADD('Out Parties Loop 1 ');

   END IF; ---end of cheking if the party is part of the hierarchy

  -------- Customer Summary Report-----------

  ELSIF p_report_by_option='CUST_SUMMARY'
     OR p_report_by_option='CUST_DETAILS'
  THEN

    OE_DEBUG_PUB.ADD('IN Cust Summary Report');

    --Performance issue: start (SQL ID-16485806 FTS on HZ_CUST_ACCOUNTS and HZ_CUST_PROFILE_CLASSES)
    IF (p_customer_name_low IS NOT NULL) AND (p_cust_number_low IS NOT NULL) THEN
        OE_DEBUG_PUB.ADD('Customer name-LOW   :' || p_customer_name_low);
        OE_DEBUG_PUB.ADD('Customer number-LOW :' || p_cust_number_low);

	OPEN cust_cur FOR
	SELECT
          SUBSTRB(party.party_name,1,50) ||'('||c.account_number||')' Customer
        , c.cust_account_id customer_id
        , c.account_number customer_number
        FROM
          hz_cust_accounts c
        , hz_parties party
        WHERE c.status='A'
          AND c.party_id = party.party_id
          AND party.party_name BETWEEN p_customer_name_low
                 AND NVL(p_customer_name_high, party.party_name)
          AND c.account_number  BETWEEN p_cust_number_low
                 AND NVL(p_cust_number_high, c.account_number )
          AND c.cust_account_id IN (SELECT cp.cust_account_id
                             FROM hz_cust_profile_classes cpc,hz_customer_profiles cp
                             WHERE cp.profile_class_id=cpc.profile_class_id
                               AND cpc.name BETWEEN NVL(p_prof_class_low, cpc.name)
                               AND NVL(p_prof_class_high, cpc.name)) ;
    ELSIF (p_customer_name_high IS NOT NULL) AND (p_cust_number_low IS NOT NULL) THEN
        OE_DEBUG_PUB.ADD('Customer name-HIGH  :' || p_customer_name_high);
        OE_DEBUG_PUB.ADD('Customer number-LOW :' || p_cust_number_low);

	OPEN cust_cur FOR
        SELECT
          SUBSTRB(party.party_name,1,50) ||'('||c.account_number||')' Customer
        , c.cust_account_id customer_id
        , c.account_number customer_number
        FROM
          hz_cust_accounts c
        , hz_parties party
        WHERE c.status='A'
          AND c.party_id = party.party_id
          AND party.party_name <= p_customer_name_high
          AND c.account_number  BETWEEN p_cust_number_low
                 AND NVL(p_cust_number_high, c.account_number )
          AND c.cust_account_id IN (SELECT cp.cust_account_id
                             FROM hz_cust_profile_classes cpc,hz_customer_profiles cp
                             WHERE cp.profile_class_id=cpc.profile_class_id
                               AND cpc.name BETWEEN NVL(p_prof_class_low, cpc.name)
                               AND NVL(p_prof_class_high, cpc.name)) ;
    ELSIF (p_customer_name_low IS NOT NULL) AND (p_cust_number_high IS NOT NULL) THEN
        OE_DEBUG_PUB.ADD('Customer name-LOW   :' || p_customer_name_low);
        OE_DEBUG_PUB.ADD('Customer number-HIGH:' || p_cust_number_high);

	OPEN cust_cur FOR
        SELECT
          SUBSTRB(party.party_name,1,50) ||'('||c.account_number||')' Customer
        , c.cust_account_id customer_id
        , c.account_number customer_number
        FROM
          hz_cust_accounts c
        , hz_parties party
        WHERE c.status='A'
          AND c.party_id = party.party_id
          AND party.party_name BETWEEN p_customer_name_low
                 AND NVL(p_customer_name_high, party.party_name)
          AND c.account_number  <=p_cust_number_high
          AND c.cust_account_id IN (SELECT cp.cust_account_id
                             FROM hz_cust_profile_classes cpc,hz_customer_profiles cp
                             WHERE cp.profile_class_id=cpc.profile_class_id
                               AND cpc.name BETWEEN NVL(p_prof_class_low, cpc.name)
                               AND NVL(p_prof_class_high, cpc.name)) ;
    ELSIF (p_customer_name_high IS NOT NULL) AND (p_cust_number_high IS NOT NULL) THEN
        OE_DEBUG_PUB.ADD('Customer name-HIGH  :' || p_customer_name_high);
        OE_DEBUG_PUB.ADD('Customer number-HIGH:' || p_cust_number_high);

	OPEN cust_cur FOR
        SELECT
          SUBSTRB(party.party_name,1,50) ||'('||c.account_number||')' Customer
        , c.cust_account_id customer_id
        , c.account_number customer_number
        FROM
          hz_cust_accounts c
        , hz_parties party
        WHERE c.status='A'
          AND c.party_id = party.party_id
          AND party.party_name <= p_customer_name_high
          AND c.account_number <= p_cust_number_high
          AND c.cust_account_id IN (SELECT cp.cust_account_id
                             FROM hz_cust_profile_classes cpc,hz_customer_profiles cp
                             WHERE cp.profile_class_id=cpc.profile_class_id
                               AND cpc.name BETWEEN NVL(p_prof_class_low, cpc.name)
                               AND NVL(p_prof_class_high, cpc.name)) ;
    ELSIF (p_customer_name_low IS NOT NULL) THEN
        OE_DEBUG_PUB.ADD('Customer name-LOW   :' || p_customer_name_low);

	OPEN cust_cur FOR
        SELECT
          SUBSTRB(party.party_name,1,50) ||'('||c.account_number||')' Customer
        , c.cust_account_id customer_id
        , c.account_number customer_number
        FROM
          hz_cust_accounts c
        , hz_parties party
        WHERE c.status='A'
          AND c.party_id = party.party_id
          AND party.party_name BETWEEN p_customer_name_low
                 AND NVL(p_customer_name_high, party.party_name)
          AND c.cust_account_id IN (SELECT cp.cust_account_id
                             FROM hz_cust_profile_classes cpc,hz_customer_profiles cp
                             WHERE cp.profile_class_id=cpc.profile_class_id
                               AND cpc.name BETWEEN NVL(p_prof_class_low, cpc.name)
                               AND NVL(p_prof_class_high, cpc.name)) ;
    ELSIF (p_customer_name_high IS NOT NULL) THEN
	OE_DEBUG_PUB.ADD('Customer name-HIGH  :' || p_customer_name_high);

	OPEN cust_cur FOR
        SELECT
          SUBSTRB(party.party_name,1,50) ||'('||c.account_number||')' Customer
        , c.cust_account_id customer_id
        , c.account_number customer_number
        FROM
          hz_cust_accounts c
        , hz_parties party
        WHERE c.status='A'
          AND c.party_id = party.party_id
          AND party.party_name <= p_customer_name_high
          AND c.cust_account_id IN (SELECT cp.cust_account_id
                             FROM hz_cust_profile_classes cpc,hz_customer_profiles cp
                             WHERE cp.profile_class_id=cpc.profile_class_id
                               AND cpc.name BETWEEN NVL(p_prof_class_low, cpc.name)
                               AND NVL(p_prof_class_high, cpc.name)) ;
    ELSIF (p_cust_number_low IS NOT NULL) THEN
        OE_DEBUG_PUB.ADD('Customer number-LOW :' || p_cust_number_low);

	OPEN cust_cur FOR
        SELECT
          SUBSTRB(party.party_name,1,50) ||'('||c.account_number||')' Customer
        , c.cust_account_id customer_id
        , c.account_number customer_number
        FROM
          hz_cust_accounts c
        , hz_parties party
        WHERE c.status='A'
          AND c.party_id = party.party_id
          AND c.account_number  BETWEEN p_cust_number_low
                 AND NVL(p_cust_number_high, c.account_number )
          AND c.cust_account_id IN (SELECT cp.cust_account_id
                             FROM hz_cust_profile_classes cpc,hz_customer_profiles cp
                             WHERE cp.profile_class_id=cpc.profile_class_id
                               AND cpc.name BETWEEN NVL(p_prof_class_low, cpc.name)
                               AND NVL(p_prof_class_high, cpc.name)) ;
    ELSIF (p_cust_number_high IS NOT NULL) THEN
        OE_DEBUG_PUB.ADD('Customer number-HIGH:' || p_cust_number_high);

	OPEN cust_cur FOR
        SELECT
          SUBSTRB(party.party_name,1,50) ||'('||c.account_number||')' Customer
        , c.cust_account_id customer_id
        , c.account_number customer_number
        FROM
          hz_cust_accounts c
        , hz_parties party
        WHERE c.status='A'
          AND c.party_id = party.party_id
          AND c.account_number  <= p_cust_number_high
          AND c.cust_account_id IN (SELECT cp.cust_account_id
                             FROM hz_cust_profile_classes cpc,hz_customer_profiles cp
                             WHERE cp.profile_class_id=cpc.profile_class_id
                               AND cpc.name BETWEEN NVL(p_prof_class_low, cpc.name)
                               AND NVL(p_prof_class_high, cpc.name)) ;
    ELSIF (p_customer_name_low IS NULL) AND (p_customer_name_high IS NULL) AND
          (p_cust_number_high IS NULL) AND (p_cust_number_low IS NULL) THEN
        OE_DEBUG_PUB.ADD('Customer name-LOW   :' || p_customer_name_low);
        OE_DEBUG_PUB.ADD('Customer name-HIGH  :' || p_customer_name_high);
        OE_DEBUG_PUB.ADD('Customer number-LOW :' || p_cust_number_low);
        OE_DEBUG_PUB.ADD('Customer number-HIGH:' || p_cust_number_high);

	OPEN cust_cur FOR
        SELECT
          SUBSTRB(party.party_name,1,50) ||'('||c.account_number||')' Customer
        , c.cust_account_id customer_id
        , c.account_number customer_number
        FROM
          hz_cust_accounts c
        , hz_parties party
        WHERE c.status='A'
          AND c.party_id = party.party_id
          AND c.cust_account_id IN (SELECT cp.cust_account_id
                             FROM hz_cust_profile_classes cpc,hz_customer_profiles cp
                             WHERE cp.profile_class_id=cpc.profile_class_id
                               AND cpc.name BETWEEN NVL(p_prof_class_low, cpc.name)
                               AND NVL(p_prof_class_high, cpc.name)) ;
    END IF ;
    --Performance issue: end (SQL ID-16485806 FTS on HZ_CUST_ACCOUNTS and HZ_CUST_PROFILE_CLASSES)

    ------start loop for customers
    LOOP
     FETCH cust_cur INTO cust_csr_rec;
      EXIT WHEN cust_cur%NOTFOUND;

      ----Empty global variables
      OE_Credit_Engine_GRP.G_cust_curr_tbl:=l_empty_curr_tbl;
      OE_Credit_Engine_GRP.G_cust_incl_all_flag:='N';

      ----start loop for customer credit profiles
      FOR cust_prof_csr_rec  IN cust_prof_csr(p_customer_id=>cust_csr_rec.customer_id)
      LOOP
        ------calculate customer credit exposure
        OE_CREDIT_ENGINE_GRP.Get_Customer_Exposure
        ( p_customer_id          => cust_csr_rec.customer_id
        , p_site_id              => NULL
        , p_limit_curr_code      => cust_prof_csr_rec.cust_currency_code
        , p_credit_check_rule_id => p_cr_check_rule_id
        , x_total_exposure       => l_cust_total_exposure
        , x_return_status        => l_return_status
        );

        OE_DEBUG_PUB.ADD('OEXPCRGB: OUT of Get_Customer_Exposure ');
        OE_DEBUG_PUB.ADD('l_return_status = '|| l_return_status );

        IF l_return_status = 'C'
        THEN
          l_return_status1:='C';

          EXIT;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -----calculate available credit
        l_cust_available:=cust_prof_csr_rec.cust_overall_limit - l_cust_total_exposure;

        -----convert overall_credit_limit, exposure and available credit into base currency
        OE_DEBUG_PUB.ADD('IN Convert amounts ');

        l_base_cur_overall_limit :=
        GL_CURRENCY_API.Convert_closest_amount_sql
        ( x_from_currency         => cust_prof_csr_rec.cust_currency_code
        , x_to_currency           => l_base_currency
        , x_conversion_date       => sysdate
        , x_conversion_type       => l_conversion_type
        , x_user_rate             => NULL
        , x_amount                => cust_prof_csr_rec.cust_overall_limit
        , x_max_roll_days         => -1
        );

        OE_DEBUG_PUB.ADD('GL_currency_api.Convert_closest_amount_sql ');
        OE_DEBUG_PUB.ADD('l_base_cur_overall_limit = '|| TO_CHAR(l_base_cur_overall_limit));

        l_base_cur_exposure      :=
        GL_CURRENCY_API.Convert_closest_amount_sql
        ( x_from_currency         => cust_prof_csr_rec.cust_currency_code
        , x_to_currency           => l_base_currency
        , x_conversion_date       => sysdate
        , x_conversion_type       => l_conversion_type
        , x_user_rate             => NULL
        , x_amount                => l_cust_total_exposure
        , x_max_roll_days         => -1
        );

        OE_DEBUG_PUB.ADD('GL_currency_api.Convert_closest_amount_sql ');
        OE_DEBUG_PUB.ADD('l_base_cur_exposure = '|| TO_CHAR(l_base_cur_exposure));

        l_base_cur_available     :=
        GL_CURRENCY_API.Convert_closest_amount_sql
        ( x_from_currency         => cust_prof_csr_rec.cust_currency_code
        , x_to_currency           => l_base_currency
        , x_conversion_date       => sysdate
        , x_conversion_type       => l_conversion_type
        , x_user_rate             => NULL
        , x_amount                => l_cust_available
        , x_max_roll_days         => -1
        );

        OE_DEBUG_PUB.ADD('GL_currency_api.Convert_closest_amount_sql ');
        OE_DEBUG_PUB.ADD('l_base_cur_available  = '
             || TO_CHAR(l_base_cur_available ));

        OE_DEBUG_PUB.ADD('OUT Convert amounts ');

        OE_DEBUG_PUB.ADD('call Get_global_exposure_flag ');

        l_global_exposure_flag :=
        OE_CREDIT_CHECK_UTIL.Get_global_exposure_flag
        (  p_entity_type     => 'CUSTOMER'
         , p_entity_id       => cust_csr_rec.customer_id
         , p_limit_curr_code =>  cust_prof_csr_rec.cust_currency_code
         ) ;


        OE_DEBUG_PUB.ADD('l_global_exposure_flag => '||
              l_global_exposure_flag );

        OE_DEBUG_PUB.ADD('IN Insert data into temp table ');

        -----insert data into temp table
        INSERT INTO OE_CREDIT_EXPOSURE_TEMP
        ( party_id
        , party_name
        , party_number
        , party_level
        , party_parent_id
        , report_by_option
        , customer_id
        , customer_name
        , customer_number
        , bill_to_site_id
        , bill_to_site_name
        , credit_limit_currency
        , cr_cur_overall_limit
        , cr_cur_exposure
        , cr_cur_available
        , base_currency
        , base_cur_overall_limit
        , base_cur_exposure
        , base_cur_available
        , unchecked_exposure
        , global_exposure_flag
        )
        VALUES
        ( NULL
        , NULL
        , NULL
        , NULL
        , NULL
        , 'CUST_SUMMARY'
        , cust_csr_rec.customer_id
        , cust_csr_rec.Customer
        , cust_csr_rec.customer_number
        , NULL
        , NULL
        , cust_prof_csr_rec.cust_currency_code
        , cust_prof_csr_rec.cust_overall_limit
        , l_cust_total_exposure
        , l_cust_available
        , l_base_currency
        , l_base_cur_overall_limit
        , l_base_cur_exposure
        , l_base_cur_available
        , NULL
        , l_global_exposure_flag
        );

      OE_DEBUG_PUB.ADD('OUT Insert data into temp table ');

      ----end loop for customer credit profiles
      END LOOP;

      IF l_return_status = 'C'
      THEN
        l_return_status1:='C';

        EXIT;
      END IF;

      ----calculate unchecked exposure
      ----if global variable G_cust_incl_all_flag is 'Y'
      ----then unchecked exposure will be 0
      IF OE_Credit_Engine_GRP.G_cust_incl_all_flag='Y'
      THEN
         OE_DEBUG_PUB.ADD('OE_Credit_Engine_GRP.G_cust_incl_all_flag=Y,
                         so l_cust_unchk_exposure=0');

        l_cust_unchk_exposure:=0;
      ELSE
        OE_DEBUG_PUB.ADD('IN Get_unchecked_exposure for the customer= '
                         ||TO_CHAR(cust_csr_rec.customer_id));

        Get_unchecked_exposure
        ( p_party_id             => NULL
        , p_customer_id          => cust_csr_rec.customer_id
        , p_site_id              => NULL
        , p_base_currency        => l_base_currency
        , p_credit_check_rule_id => p_cr_check_rule_id
        , x_unchecked_expousre   => l_cust_unchk_exposure
        , x_return_status        => l_return_status
        );
     END IF;

     OE_DEBUG_PUB.ADD('OUT of Get_unchecked_exposure,for the customer= '
                      ||TO_CHAR(cust_csr_rec.customer_id));
     OE_DEBUG_PUB.ADD('l_cust_unchk_exposure = '|| TO_CHAR(l_cust_unchk_exposure));
     OE_DEBUG_PUB.ADD('l_return_status = '|| l_return_status );

     IF l_return_status = 'C'
     THEN
       l_return_status1:='C';

       EXIT;

     ELSIF l_return_status = FND_API.G_RET_STS_ERROR
     THEN
       RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
     THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     OE_DEBUG_PUB.ADD('Check if the customer has any credit profiles ');
     -----check if the customer has any credit profiles
     SELECT COUNT(*)
     INTO l_prof_count
     FROM
       hz_customer_profiles cp
     , hz_cust_profile_amts cpa
     WHERE cp.cust_account_profile_id=cpa.cust_account_profile_id
       AND cp.site_use_id IS NULL
       AND cp.cust_account_id=cust_csr_rec.customer_id;

     IF l_prof_count>0
     THEN

      OE_DEBUG_PUB.ADD('Customer has credit profiles ');
      OE_DEBUG_PUB.ADD('Update temp table with unchecked exposure ');

      ----update temp table with unchecked exposure
      UPDATE oe_credit_exposure_temp
      SET unchecked_exposure=l_cust_unchk_exposure
      WHERE customer_id=cust_csr_rec.customer_id
        AND bill_to_site_id IS NULL
        AND party_id IS NULL;

     -----there are no credit profiles for this customer
     ----insert unchecked exposure
     ELSE

       OE_DEBUG_PUB.ADD('Customer does not have any credit profiles ');
       OE_DEBUG_PUB.ADD('IN Insert data into temp table for unchecked exposure ');

       -----insert data into temp table
        INSERT INTO OE_CREDIT_EXPOSURE_TEMP
        ( party_id
        , party_name
        , party_number
        , party_level
        , party_parent_id
        , report_by_option
        , customer_id
        , customer_name
        , customer_number
        , bill_to_site_id
        , bill_to_site_name
        , credit_limit_currency
        , cr_cur_overall_limit
        , cr_cur_exposure
        , cr_cur_available
        , base_currency
        , base_cur_overall_limit
        , base_cur_exposure
        , base_cur_available
        , unchecked_exposure
        , global_exposure_flag
        )
        VALUES
        ( NULL
        , NULL
        , NULL
        , NULL
        , NULL
        , 'CUST_SUMMARY'
        , cust_csr_rec.customer_id
        , cust_csr_rec.Customer
        , cust_csr_rec.customer_number
        , NULL
        , NULL
        , NULL
        , NULL
        , NULL
        , NULL
        , l_base_currency
        , NULL
        , NULL
        , NULL
        , l_cust_unchk_exposure
        , NULL
        );

       OE_DEBUG_PUB.ADD('Out Insert data into temp table ');

     END IF;

      IF p_report_by_option='CUST_DETAILS'
      THEN

        OE_DEBUG_PUB.ADD('IN Customern Detail Report');
        --------Detail Report------------

        -------------------Bill-to Site Info-------------
        -----start loop for bill-to sites
        FOR site_csr_rec IN site_csr(cust_csr_rec.customer_id)
        LOOP

          ----Empty global variables
          OE_Credit_Engine_GRP.G_site_curr_tbl:=l_empty_curr_tbl;
          OE_Credit_Engine_GRP.G_site_incl_all_flag:='N';


          ----start loop for bill-to site credit profiles
          FOR site_prof_csr_rec IN site_prof_csr( p_customer_id => cust_csr_rec.customer_id
                                                , p_site_id     => site_csr_rec.site_id)
          LOOP
            OE_DEBUG_PUB.ADD('IN loop for bill-to sites ');
            OE_DEBUG_PUB.ADD('Processing site '||site_csr_rec.Customer_site);

            ------calculate bill-to site credit exposure
            OE_CREDIT_ENGINE_GRP.Get_Customer_Exposure
            ( p_customer_id          => cust_csr_rec.customer_id
            , p_site_id              => site_csr_rec.site_id
            , p_limit_curr_code      => site_prof_csr_rec.site_currency_code
            , p_credit_check_rule_id => p_cr_check_rule_id
            , x_total_exposure       => l_site_total_exposure
            , x_return_status        => l_return_status
            );


            OE_DEBUG_PUB.ADD('OUT of Get_Customer_Exposure ');
            OE_DEBUG_PUB.ADD('l_return_status = '|| l_return_status );
            OE_DEBUG_PUB.ADD('l_site_total_exposure = '||TO_CHAR(l_site_total_exposure));

            IF l_return_status = 'C'
            THEN
              l_return_status1:='C';

              EXIT;

            ELSIF l_return_status = FND_API.G_RET_STS_ERROR
            THEN
              RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
            THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            -----calculate available credit
            l_site_available:=site_prof_csr_rec.site_overall_limit - l_site_total_exposure;

            -----convert overall_credit_limit, exposure and available credit into base currency
            l_base_cur_overall_limit :=
            GL_CURRENCY_API.Convert_closest_amount_sql
            ( x_from_currency         => site_prof_csr_rec.site_currency_code
            , x_to_currency           => l_base_currency
            , x_conversion_date       => SYSDATE
            , x_conversion_type       => l_conversion_type
            , x_user_rate             => NULL
            , x_amount                => site_prof_csr_rec.site_overall_limit
            , x_max_roll_days         => -1
            );

            OE_DEBUG_PUB.ADD('GL_currency_api.Convert_closest_amount_sql ');
            OE_DEBUG_PUB.ADD('l_base_cur_overall_limit = '|| TO_CHAR(l_base_cur_overall_limit));


            l_base_cur_exposure :=
            GL_CURRENCY_API.Convert_closest_amount_sql
            ( x_from_currency         => site_prof_csr_rec.site_currency_code
            , x_to_currency           => l_base_currency
            , x_conversion_date       => SYSDATE
            , x_conversion_type       => l_conversion_type
            , x_user_rate             => NULL
            , x_amount                => l_site_total_exposure
            , x_max_roll_days         => -1
            );

            OE_DEBUG_PUB.ADD('GL_currency_api.Convert_closest_amount_sql ');
            OE_DEBUG_PUB.ADD('l_base_cur_exposure = '|| TO_CHAR(l_base_cur_exposure));


            l_base_cur_available :=
            GL_CURRENCY_API.Convert_closest_amount_sql
            ( x_from_currency         => site_prof_csr_rec.site_currency_code
            , x_to_currency           => l_base_currency
            , x_conversion_date       => SYSDATE
            , x_conversion_type       => l_conversion_type
            , x_user_rate             => NULL
            , x_amount                => l_site_available
            , x_max_roll_days         => -1
            );

            OE_DEBUG_PUB.ADD('GL_currency_api.Convert_closest_amount_sql ');
            OE_DEBUG_PUB.ADD('l_base_cur_available = '|| TO_CHAR(l_base_cur_available));

            -----insert data into temp table
            INSERT INTO OE_CREDIT_EXPOSURE_TEMP
            ( party_id
            , party_name
            , party_number
            , party_level
            , party_parent_id
            , report_by_option
            , customer_id
            , customer_name
            , customer_number
            , bill_to_site_id
            , bill_to_site_name
            , credit_limit_currency
            , cr_cur_overall_limit
            , cr_cur_exposure
            , cr_cur_available
            , base_currency
            , base_cur_overall_limit
            , base_cur_exposure
            , base_cur_available
            , unchecked_exposure
            , global_exposure_flag
            )
            VALUES
            ( NULL
            , NULL
            , NULL
            , NULL
            , NULL
            , 'CUST_DETAILS'
            , cust_csr_rec.customer_id
            , cust_csr_rec.Customer
            , cust_csr_rec.customer_number
            , site_csr_rec.site_id
            , site_csr_rec.Customer_site
            , site_prof_csr_rec.site_currency_code
            , site_prof_csr_rec.site_overall_limit
            , l_site_total_exposure
            , l_site_available
            , l_base_currency
            , l_base_cur_overall_limit
            , l_base_cur_exposure
            , l_base_cur_available
            , NULL
            , 'N'
            );

          ----end loop for bill-to site credit profiles
          END LOOP;

          ----calculate unchecked exposure for bill-to site
          ----if global variable for include_all_flag is 'Y'
          ----then unchecked_exposure will be 0

          IF OE_Credit_Engine_GRP.G_site_incl_all_flag='Y'
          THEN
            OE_DEBUG_PUB.ADD('OE_Credit_Engine_GRP.G_site_incl_all_flag='
                             ||OE_Credit_Engine_GRP.G_site_incl_all_flag
                             ||'so l_site_unchk_exposure=0');

            l_site_unchk_exposure:=0;
          ELSE
            OE_DEBUG_PUB.ADD('Start Get_unchecked_exposure for bill-to site ='
                             ||TO_CHAR(site_csr_rec.site_id));

            Get_unchecked_exposure
            ( p_party_id             => NULL
            , p_customer_id          => cust_csr_rec.customer_id
            , p_site_id              => site_csr_rec.site_id
            , p_base_currency        => l_base_currency
            , p_credit_check_rule_id => p_cr_check_rule_id
            , x_unchecked_expousre   => l_site_unchk_exposure
            , x_return_status        => l_return_status
            );
         END IF;

         OE_DEBUG_PUB.ADD('OUT of Get_unchecked_exposure,for bill-to site '||
                          TO_CHAR(site_csr_rec.site_id));
         OE_DEBUG_PUB.ADD('l_site_unchk_exposure = '|| TO_CHAR(l_site_unchk_exposure) );
         OE_DEBUG_PUB.ADD('l_return_status = '|| l_return_status );

         IF l_return_status = 'C'
         THEN
          l_return_status1:='C';

          EXIT;

         ELSIF l_return_status = FND_API.G_RET_STS_ERROR
         THEN
           RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
         THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         OE_DEBUG_PUB.ADD('Check if the customer site has any credit profiles ');

         -----check if the customer site has any credit profiles
         SELECT COUNT(*)
         INTO l_prof_count1
         FROM
           hz_customer_profiles cp
         , hz_cust_profile_amts cpa
         WHERE cp.cust_account_profile_id=cpa.cust_account_profile_id
           AND cp.site_use_id =site_csr_rec.site_id
           AND cp.cust_account_id=cust_csr_rec.customer_id;

         IF l_prof_count1>0
         THEN

           OE_DEBUG_PUB.ADD('Customer site has credit profiles ');
           OE_DEBUG_PUB.ADD('Update temp table with unchecked_exposure ');

           ----update temp table with unchecked exposure for bill-to site
           UPDATE oe_credit_exposure_temp
           SET unchecked_exposure=l_site_unchk_exposure
           WHERE customer_id=cust_csr_rec.customer_id
             AND bill_to_site_id=site_csr_rec.site_id;

         -----there are no credit profiles for this customer site
         -----insert unchecked exposure into temp table
         ELSE

           OE_DEBUG_PUB.ADD('Customer site does not have credit profiles ');
           OE_DEBUG_PUB.ADD('Insert into temp table unchecked_exposure ');

           INSERT INTO OE_CREDIT_EXPOSURE_TEMP
           ( party_id
           , party_name
           , party_number
           , party_level
           , party_parent_id
           , report_by_option
           , customer_id
           , customer_name
           , customer_number
           , bill_to_site_id
           , bill_to_site_name
           , credit_limit_currency
           , cr_cur_overall_limit
           , cr_cur_exposure
           , cr_cur_available
           , base_currency
           , base_cur_overall_limit
           , base_cur_exposure
           , base_cur_available
           , unchecked_exposure
           , global_exposure_flag
           )
           VALUES
           ( NULL
           , NULL
           , NULL
           , NULL
           , NULL
           , 'CUST_DETAILS'
           , cust_csr_rec.customer_id
           , cust_csr_rec.Customer
           , cust_csr_rec.customer_number
           , site_csr_rec.site_id
           , site_csr_rec.Customer_site
           , NULL
           , NULL
           , NULL
           , NULL
           , l_base_currency
           , NULL
           , NULL
           , NULL
           , l_site_unchk_exposure
           , 'N'
           );

           OE_DEBUG_PUB.ADD('Out of the insert into temp table ');

         END IF;

        -----end loop for bill-to sites
        END LOOP;
      END IF;
     ----end loop for customers
     END LOOP;
  END IF; -----end for p_report_by_option

  x_return_status :=l_return_status1;

  -----if some exchange rates are missing, delete everything
  ---- from the temp table, so that report will print no data found
  IF l_return_status1='C'
  THEN
    DELETE
    FROM OE_CREDIT_EXPOSURE_TEMP;
  END IF;

  COMMIT;
  OE_DEBUG_PUB.ADD('Out of OEXRCRCB:Credit_exposure_report_utils with the status='||x_return_status);

EXCEPTION

  WHEN  GL_CURRENCY_API.NO_RATE THEN
    OE_DEBUG_PUB.ADD('OEXRCRCB: Credit_exposure_report_utils - GL_CURRENCY_API.NO_RATE');
    RAISE;
  WHEN OTHERS THEN
    OE_DEBUG_PUB.ADD('OEXRCRCB: Credit_exposure_report_utils - Unexpected Error',1);
    OE_DEBUG_PUB.ADD('EXCEPTION: '||SUBSTR(sqlerrm,1,200),1);

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,'Credit_exposure_report_utils');
    END IF;
    RAISE;
END Credit_exposure_report_utils;


END OE_CREDIT_CHECK_RPT;

/
