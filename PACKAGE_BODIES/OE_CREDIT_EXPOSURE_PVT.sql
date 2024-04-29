--------------------------------------------------------
--  DDL for Package Body OE_CREDIT_EXPOSURE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CREDIT_EXPOSURE_PVT" AS
-- $Header: OEXVCRXB.pls 120.9.12010000.6 2009/12/28 08:15:22 msundara ship $

--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    OEXVCRXB.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Body of OE_CREDIT_EXPOSURE_PVT                                     |
--|                                                                       |
--| HISTORY                                                               |
--|     06/05/2001 Rene Schaub     Created                                |
--|     02/04/2002 Rajesh Krishnan ontdev => 115.10 2001/09/01 00:53:53   |
--|                                multi org FEB-04-2002 7PM              |
--|     03/15/2002 Vanessa To      modified get_exposure - include        |
--|                                external exposure.                     |
--|     05/01/2002 rajkrish        Bug 2352020                            |
--|     06/18/2002 vto             renee -- init summary only             |
--|     Aug-2002  rajkrish - Implement MUlti buckets algorithm            |
--|               ontdev==> 115.14 2002/05/02                             |
--|     August-29-2002 rajkrish 6PM                                       |
--|     12/20/2002 vto             Added NOCOPY to OUT variables          |
--|     23-DEc-2002 - BR Issue                                            |
--|     07/02/2003 tsimmond     Added code for the FPJ Returns project in |
--|                             Init_Summary_Table,balance types proc.,   |
--|                             Retrieve_Exposure                         |
--|     08/27/2003 vto          Modification for Partial payments support |
--|                                                                       |
--|     12/23/2003 tsimmond     Modified insert for G_ORDER_RETURN_HOLDS, |
--|                             G_ORDER_RETURN_TAX_HOLDS,                 |
--|                             G_LINE_RETURN_TAX_HOLDS,                  |
--|                             and G_LINE_RETURN_HOLDS, bug fix 3223770  |
--|     01/06/2004 vto          3320260. Modified to handle non-multiorg  |
--|     08/06/2004 vto          3818562. Add NVL on h.request_date        |
--+======================================================================*/


--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'OE_CREDIT_EXPOSURE_PVT';
G_debug_flag        VARCHAR2(1) :=
 NVL(oe_credit_check_util.check_debug_flag , 'N' ) ;
--===================
-- GLOBAL VARIABLES
--===================
  b1              NUMBER;
  b2              NUMBER;
  b3              NUMBER;
  b4              NUMBER;
  b5              NUMBER;
  b6              NUMBER;
  b7              NUMBER;
  b8              NUMBER;
  b9              NUMBER;
  b10             NUMBER;
  b11             NUMBER;
  b12             NUMBER;
  b13             NUMBER;
  b14             NUMBER;
  b15             NUMBER;
  b16             NUMBER;
  b17             NUMBER;
  b18             NUMBER;
  b21             NUMBER;
  b22             NUMBER;

----added for the RETURNS-------
  b23             NUMBER;
  b24             NUMBER;
  b25             NUMBER;
  b26             NUMBER;
  b27             NUMBER;
  b28             NUMBER;
  b29             NUMBER;
  b30             NUMBER;
  b31             NUMBER;
  b32             NUMBER;
  b33             NUMBER;
  b34             NUMBER;
  b35             NUMBER;
  b36             NUMBER;

  g_error_curr_tbl        OE_CREDIT_CHECK_UTIL.curr_tbl_type;
  g_conversion_type       OE_Credit_Check_Rules.conversion_type%TYPE;
  g_functional_currency   FND_CURRENCIES.Currency_code%TYPE;
  g_use_party_hierarchy   VARCHAR2(1) ;

  --g_external_exposure    NUMBER ;

--===================
-- PRIVATE PROCEDURES
--===================

------------------------------------------------------
-- Function used for debug log printing the time execution
-------------------------------------------------------

FUNCTION Do_Time RETURN VARCHAR2 IS
  t   VARCHAR2(30);
BEGIN

 t := TO_CHAR( SYSDATE, 'YYYY-MON-HH-MI-SS' ) ;
  RETURN t;

END;


------------------------------------------------------
-- PROCEDURE  : get_invoices_over_duedate
-- DESCRIPTION: Returns Y if Invoices exist past due dates
-- HISTORY:
-- 01/06/04  3320260: Modified to handle non-multiorg setup
-- 12/20/05  4514215: Modified all the cursors, replaced the condition
-- bucket  < l_jdate with   bucket  <= l_jdate
--------------------------------------------------------
PROCEDURE get_invoices_over_duedate
( p_customer_id          IN   NUMBER
, p_site_use_id          IN   NUMBER
, p_party_id             IN   NUMBER
, p_credit_check_rule_rec IN
             OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type
, p_credit_level         IN   VARCHAR2
, p_usage_curr           IN   oe_credit_check_util.curr_tbl_type
, p_include_all_flag     IN   VARCHAR2
, p_global_exposure_flag IN   VARCHAR2 := 'N'
, p_org_id               IN   NUMBER
, x_exist_flag           OUT  NOCOPY VARCHAR2
)
IS

l_jdate NUMBER;
l_return VARCHAR2(1) ;

 CURSOR chk_inv_past_due_cust(p_curr_code IN VARCHAR2 ) IS
  SELECT 'Y'
  FROM    OE_credit_summaries
  WHERE   cust_account_id = p_customer_id
   AND  currency_code   = p_curr_code
   AND  bucket  <= l_jdate
   AND  bucket_duration = 1
   AND  ((org_id             =  p_org_id)
         OR
        (org_id IS NULL AND p_org_id IS NULL))
   AND  balance_type    = 20 ;

 CURSOR chk_inv_past_due_cust_gl(p_curr_code IN VARCHAR2 ) IS
  SELECT 'Y'
  FROM    OE_credit_summaries
  WHERE   cust_account_id = p_customer_id
   AND  currency_code   = p_curr_code
   AND  bucket  <= l_jdate
   AND  bucket_duration = 1
   AND  balance_type    = 20 ;


 CURSOR chk_inv_past_due_site(p_curr_code IN VARCHAR2 ) IS
  SELECT 'Y'
  FROM    OE_credit_summaries
  WHERE   site_use_id    = p_site_use_id
   AND   currency_code  = p_curr_code
   AND  bucket  <= l_jdate
   AND  bucket_duration = 1
   AND  balance_type    = 20 ;

 CURSOR chk_inv_past_due_party(p_curr_code IN VARCHAR2 ) IS
   SELECT 'Y'
  FROM    OE_credit_summaries oes
     ,    hz_hierarchy_nodes hn
  WHERE   hn.parent_id                 = p_party_id
  AND  hn.parent_object_type           = 'ORGANIZATION'
  and  hn.parent_table_name            = 'HZ_PARTIES'
  and  hn.child_object_type            = 'ORGANIZATION'
  and  hn.effective_start_date  <=  sysdate
  and  hn.effective_end_date    >= SYSDATE
  and  hn.hierarchy_type     =
            OE_CREDIT_CHECK_UTIL.G_hierarchy_type
  AND  oes.party_id                    =  hn.child_id
  AND  oes.currency_code               = p_curr_code
  AND  oes.bucket                 <= l_jdate
  AND  oes.balance_type    = 20
  AND  oes.bucket_duration = 1 ;

 --Bug 4991241
 CURSOR chk_inv_past_due_single_party(p_curr_code IN VARCHAR2 ) IS
  SELECT 'Y'
  FROM    OE_credit_summaries
  WHERE   party_id    = p_party_id
   AND   currency_code  = p_curr_code
   AND  bucket  <= l_jdate
   AND  bucket_duration = 1
   AND  balance_type    = 20 ;

 CURSOR chk_inv_past_due_cust_all IS
  SELECT 'Y'
  FROM    OE_credit_summaries
  WHERE cust_account_id = p_customer_id
   AND  bucket  <= l_jdate
   AND  bucket_duration = 1
   AND  ((org_id              =  p_org_id)
          OR
         (org_id IS NULL AND p_org_id IS NULL))
   AND  balance_type    = 20 ;

 CURSOR chk_inv_past_due_cust_all_gl IS
  SELECT 'Y'
  FROM    OE_credit_summaries
  WHERE cust_account_id = p_customer_id
   AND  bucket  <= l_jdate
   AND  bucket_duration = 1
   AND  balance_type    = 20 ;


 CURSOR chk_inv_past_due_site_all IS
  SELECT 'Y'
  FROM    OE_credit_summaries
  WHERE site_use_id    = p_site_use_id
   AND  bucket  <= l_jdate
   AND  bucket_duration = 1
   AND  balance_type    = 20 ;

 CURSOR chk_inv_past_due_party_all IS
  SELECT 'Y'
  FROM    OE_credit_summaries oes
     ,    hz_hierarchy_nodes hn
  WHERE   hn.parent_id                 = p_party_id
  AND  hn.parent_object_type           = 'ORGANIZATION'
  and  hn.parent_table_name            = 'HZ_PARTIES'
  and  hn.child_object_type            = 'ORGANIZATION'
  and  hn.effective_start_date  <=  sysdate
  and  hn.effective_end_date    >= SYSDATE
  and  hn.hierarchy_type     =
            OE_CREDIT_CHECK_UTIL.G_hierarchy_type
  AND  oes.party_id                      =  hn.child_id
  AND  oes.bucket  <= l_jdate
  AND  oes.balance_type    = 20
  AND  oes.bucket_duration = 1;

 --Bug 4991241
 CURSOR chk_inv_past_party_single_all IS
  SELECT 'Y'
  FROM    OE_credit_summaries
  WHERE party_id    = p_party_id
   AND  bucket  <= l_jdate
   AND  bucket_duration = 1
   AND  balance_type    = 20 ;

BEGIN

  l_jdate := TO_NUMBER( TO_CHAR( ( SYSDATE -
              p_credit_check_rule_rec.maximum_days_past_due ), 'J' ) );

  x_exist_flag := 'N' ;

  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add(' l_jdate => '|| l_jdate );
    oe_debug_pub.add(' p_credit_level => '|| p_credit_level );
    oe_debug_pub.add(' p_site_use_id => '|| p_site_use_id );
    oe_debug_pub.add(' p_customer_id => '|| p_customer_id );
    oe_debug_pub.add(' p_party_id => '|| p_party_id );
  END IF;

 BEGIN

  IF p_credit_level = 'CUSTOMER'
  THEN
    IF p_include_all_flag = 'N'
    THEN
      FOR i IN 1..p_usage_curr.count
      LOOP
        IF p_global_exposure_flag = 'N'
        THEN
          OPEN chk_inv_past_due_cust (p_usage_curr(i).usage_curr_code ) ;
          FETCH chk_inv_past_due_cust
          INTO x_exist_flag ;

          IF chk_inv_past_due_cust%NOTFOUND
          THEN
            x_exist_flag := 'N' ;
          ELSE
            CLOSE chk_inv_past_due_cust ;
            EXIT ;
          END IF;
          CLOSE chk_inv_past_due_cust ;

        ELSE
         OPEN chk_inv_past_due_cust_gl (p_usage_curr(i).usage_curr_code ) ;
         FETCH chk_inv_past_due_cust_gl INTO x_exist_flag ;
         IF chk_inv_past_due_cust_gl%NOTFOUND
         THEN
           x_exist_flag := 'N' ;
         ELSE
           CLOSE chk_inv_past_due_cust_gl ;
           EXIT;
         END IF;
         CLOSE chk_inv_past_due_cust_gl ;
       END IF; -- global
      END LOOP ;

    ELSE -- al currency
      IF p_global_exposure_flag = 'N'
      THEN
        OPEN chk_inv_past_due_cust_all ;
        FETCH chk_inv_past_due_cust_all
        INTO x_exist_flag ;

          IF chk_inv_past_due_cust_all%NOTFOUND
          THEN
            x_exist_flag := 'N' ;
          END IF;
        CLOSE chk_inv_past_due_cust_all ;
      ELSE
        OPEN chk_inv_past_due_cust_all_gl  ;
        FETCH chk_inv_past_due_cust_all_gl INTO x_exist_flag ;
        IF chk_inv_past_due_cust_all_gl%NOTFOUND
        THEN
           x_exist_flag := 'N' ;
        END IF;

        CLOSE chk_inv_past_due_cust_all_gl ;
      END IF ; -- global;
    END IF; -- all curr

  ELSIF p_credit_level = 'SITE'
  THEN
   IF p_include_all_flag = 'N'
   THEN
     FOR i IN 1..p_usage_curr.count
     LOOP

      OPEN chk_inv_past_due_site(p_usage_curr(i).usage_curr_code) ;
      FETCH chk_inv_past_due_site
      INTO x_exist_flag ;

        IF chk_inv_past_due_site%NOTFOUND
        THEN
          x_exist_flag := 'N' ;
        ELSE
          CLOSE chk_inv_past_due_site ;
          EXIT ;
        END IF;

       CLOSE chk_inv_past_due_site ;
     END LOOP;
   ELSE -- all curr
     OPEN chk_inv_past_due_site_all ;
     FETCH chk_inv_past_due_site_all
     INTO x_exist_flag ;

       IF chk_inv_past_due_site_all%NOTFOUND
        THEN
          x_exist_flag := 'N' ;
       END IF;

      CLOSE chk_inv_past_due_site_all ;
   END IF;

 ELSIF p_credit_level = 'PARTY'
 THEN
   IF p_include_all_flag = 'N'
   THEN
     FOR i IN 1..p_usage_curr.count
     LOOP
       --Bug 4991241
       OPEN chk_inv_past_due_single_party(p_usage_curr(i).usage_curr_code ) ;
       FETCH chk_inv_past_due_single_party
       INTO x_exist_flag ;
       IF chk_inv_past_due_single_party%NOTFOUND
       THEN
         x_exist_flag := 'N' ;
       ELSE
         CLOSE chk_inv_past_due_single_party ;
         EXIT ;
       END IF;
       CLOSE chk_inv_past_due_single_party ;

       OPEN chk_inv_past_due_party(p_usage_curr(i).usage_curr_code ) ;
       FETCH chk_inv_past_due_party
       INTO x_exist_flag ;

       IF chk_inv_past_due_party%NOTFOUND
       THEN
         x_exist_flag := 'N' ;
       ELSE
         CLOSE chk_inv_past_due_party ;
         EXIT ;
       END IF;
       CLOSE chk_inv_past_due_party ;
     END LOOP;
   ELSE
     --Bug 4991241
     OPEN chk_inv_past_party_single_all ;
     FETCH  chk_inv_past_party_single_all INTO x_exist_flag ;

      IF chk_inv_past_party_single_all%NOTFOUND
      THEN
        x_exist_flag := 'N' ;
      END IF;
     CLOSE chk_inv_past_party_single_all ;

     IF x_exist_flag = 'N' THEN
     OPEN chk_inv_past_due_party_all ;
     FETCH  chk_inv_past_due_party_all INTO x_exist_flag ;

      IF chk_inv_past_due_party_all%NOTFOUND
      THEN
        x_exist_flag := 'N' ;
      END IF;
     CLOSE chk_inv_past_due_party_all ;
     END IF;
   END IF;


 END IF; -- credit level

 END ;

END get_invoices_over_duedate ;

------------------------------------------------------------------
-- This procedure will populate the PL/SQL table
-- used for storing the currencies that failed the
-- conversion to the credit limit currencies
-----------------------------------------------------
PROCEDURE add_error_currency
( x_error_curr_tbl     IN OUT  NOCOPY  OE_CREDIT_CHECK_UTIL.curr_tbl_type
, p_error_currency     IN           HZ_CREDIT_PROFILE_AMTS.currency_code%TYPE
)
IS
  i  BINARY_INTEGER;
BEGIN
  i  := x_error_curr_tbl.FIRST;
  WHILE  i  IS NOT NULL  LOOP
    IF
      p_error_currency  =  x_error_curr_tbl(i).usage_curr_code
    THEN
      EXIT;
    END IF;
    i := x_error_curr_tbl.NEXT(i);
  END LOOP;

  IF  i  IS NULL THEN
    x_error_curr_tbl( NVL(x_error_curr_tbl.LAST, 0) + 1 ).usage_curr_code  :=
      p_error_currency;
  END IF;
END;

------------------------------------------------------
--- This function will return the OM Horizon Date
--- in the Juilan format
---------------------------------------------

FUNCTION ship_date( p_date  IN  DATE )
RETURN NUMBER
IS
  l_date   NUMBER;
BEGIN
  IF p_date  IS NULL  THEN
    l_date  := TO_NUMBER( TO_CHAR( (SYSDATE + 1000 ), 'J' ) );
    -- last day of a max bucket in the far future
    l_date  := l_date - MOD( l_date, G_MAX_BUCKET_LENGTH )  - 1;
  ELSE
    l_date  := TO_NUMBER( TO_CHAR( p_date, 'J' ) );
  END IF;

  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'Shipping Horizon Julian Date is:' || l_date, 2 );
  END IF;

  RETURN l_date;

END ship_date;

-----------------------------------------------------
-- This function will return the AR Horizon date
-- in Juilan format
--------------------------------------------------------
FUNCTION open_date( p_days  IN  NUMBER )
RETURN NUMBER
IS
  l_date   NUMBER;
BEGIN
  IF  p_days  IS NULL  THEN
    l_date  := TO_NUMBER( TO_CHAR( ( SYSDATE + 1000 ), 'J' ) );
    -- last day of a max bucket in the far future
    l_date  := l_date - MOD( l_date, G_MAX_BUCKET_LENGTH )  - 1;

  ELSE
    l_date  := TO_NUMBER( TO_CHAR( ( SYSDATE - p_days ), 'J' ) );
  END IF;

  IF G_debug_flag = 'Y'
  THEN
     oe_debug_pub.add( 'Open Receivables Horizon Julian is:' || l_date, 2 );
  END IF;

  RETURN l_date;

END open_date;


PROCEDURE balance_types_om_and_ar
( p_credit_check_rule_rec   IN    OE_CREDIT_CHECK_UTIL.oe_credit_rules_rec_type
)
IS
BEGIN
  b1 := -1;
  b2 := -1;
  b3 := -1;
  b4 := -1;
  b5 := -1;
  b6 := -1;
  b7 := -1;
  b8 := -1;
  b9 := -1;
  b10 := -1;
  b11 := -1;
  b12 := -1;
  b13 := -1;
  b14 := -1;
  b15 := -1;
  b16 := -1;
  b17 := -1;
  b18 := -1;
  b21 := -1;
  b22 := -1;

  ----added for the RETURNS
  b23 := -1;
  b24 := -1;
  b25 := -1;
  b26 := -1;
  b27 := -1;
  b28 := -1;
  b29 := -1;
  b30 := -1;
  b31 := -1;
  b32 := -1;
  b33 := -1;
  b34 := -1;
  b35 := -1;
  b36 := -1;



  -- Determine which balance types to select:
  -- Chosing a balance type is indicated by setting the corresponding
  -- variable to a balance type global constant
  -- (e.g. b4 := G_ORDER_HOLDS)

  IF  p_credit_check_rule_rec.uninvoiced_orders_flag     =  'Y'
  THEN
    IF p_credit_check_rule_rec.credit_check_level_code  = 'LINE'
    THEN
      b3 := G_LINE_UNINVOICED_ORDERS;

      -----added for the Returns project
      IF p_credit_check_rule_rec.include_returns_flag = 'Y'
      THEN
        b24 := G_LINE_RETURN_UNINV_ORDERS;
      END IF;

      IF p_credit_check_rule_rec.orders_on_hold_flag  =  'N'
      THEN
        b11 := G_LINE_HOLDS;

        -----added for the Returns project
        IF p_credit_check_rule_rec.include_returns_flag = 'Y'
        THEN
          b31 := G_LINE_RETURN_HOLDS;
        END IF;

      END IF;
    ELSE
      b1 := G_HEADER_UNINVOICED_ORDERS;

      -----added for the Returns project
      IF p_credit_check_rule_rec.include_returns_flag = 'Y'
      THEN
        b23 := G_HEAD_RETURN_UNINV_ORDERS;
      END IF;

      IF p_credit_check_rule_rec.orders_on_hold_flag  =  'N'
      THEN
        b10 := G_ORDER_HOLDS;

        -----added for the Returns project
        IF p_credit_check_rule_rec.include_returns_flag = 'Y'
        THEN
          b30 := G_ORDER_RETURN_HOLDS;
        END IF;

      END IF;
    END IF;

  END IF;

  IF  p_credit_check_rule_rec.include_tax_flag           =  'Y'
  THEN
    IF p_credit_check_rule_rec.credit_check_level_code  = 'LINE'
    THEN
      b4 := G_LINE_UNINVOICED_ORDERS_TAX;

      -----added for the Returns project
      IF p_credit_check_rule_rec.include_returns_flag = 'Y'
      THEN
        b26:= G_LINE_RETURN_UNINV_ORD_TAX;
      END IF;

      IF p_credit_check_rule_rec.orders_on_hold_flag  =  'N'
      THEN
        b14 := G_LINE_TAX_HOLDS;

        -----added for the Returns project
        IF p_credit_check_rule_rec.include_returns_flag = 'Y'
        THEN
          b33:= G_LINE_RETURN_TAX_HOLDS;
        END IF;

      END IF;
    ELSE
      b2 := G_HEADER_UNINVOICED_ORDERS_TAX;

      -----added for the Returns project
      IF p_credit_check_rule_rec.include_returns_flag = 'Y'
      THEN
        b25:= G_HEAD_RETURN_UNINV_ORD_TAX;
      END IF;

      IF p_credit_check_rule_rec.orders_on_hold_flag  =  'N'
      THEN
        b13 := G_ORDER_TAX_HOLDS;

        -----added for the Returns project
        IF p_credit_check_rule_rec.include_returns_flag = 'Y'
        THEN
          b32:= G_ORDER_RETURN_TAX_HOLDS;
        END IF;

      END IF;
    END IF;
  END IF;

  IF  p_credit_check_rule_rec.incl_freight_charges_flag  =  'Y'
  THEN
    IF p_credit_check_rule_rec.credit_check_level_code  = 'LINE'
    THEN
      b5 := G_LINE_UNINVOICED_FREIGHT;

      -----added for the Returns project
      IF p_credit_check_rule_rec.include_returns_flag = 'Y'
      THEN
        b28:= G_LINE_RETURN_UNINV_FREIGHT;
      END IF;

      IF p_credit_check_rule_rec.orders_on_hold_flag  =  'N'
      THEN
        b16 := G_LINE_FREIGHT_HOLDS;

        -----added for the Returns project
        IF p_credit_check_rule_rec.include_returns_flag = 'Y'
        THEN
          b35:= G_LINE_RETURN_FREIGHT_HOLDS;
        END IF;

      END IF;
    ELSE
      b6 := G_HEADER_UNINVOICED_FREIGHT;

      -----added for the Returns project
      IF p_credit_check_rule_rec.include_returns_flag = 'Y'
      THEN
        b27:= G_HEAD_RETURN_UNINV_FREIGHT;
      END IF;

     IF p_credit_check_rule_rec.orders_on_hold_flag  =  'N'
     THEN
        b15 := G_ORDER_FREIGHT_HOLDS;

        -----added for the Returns project
        IF p_credit_check_rule_rec.include_returns_flag = 'Y'
        THEN
          b34:= G_ORDER_RETURN_FREIGHT_HOLDS;
        END IF;

      END IF;
    END IF;

    b7 := G_HEADER_AND_LINE_FREIGHT;

    -----added for the Returns project
    IF p_credit_check_rule_rec.include_returns_flag = 'Y'
    THEN
      b29:= G_HEAD_LINE_RETURN_FREIGHT;
    END IF;

    IF p_credit_check_rule_rec.orders_on_hold_flag  =  'N'
    THEN
      b17 := G_HEADER_LINE_FREIGHT_HOLDS;

      -----added for the Returns project
      IF p_credit_check_rule_rec.include_returns_flag = 'Y'
      THEN
        b36:= G_H_L_RETURN_FREIGHT_HOLDS;
      END IF;

    END IF;
  END IF;

  -- Set value for external exposure
  IF  p_credit_check_rule_rec.include_external_exposure_flag  =  'Y'  THEN
    b18 := G_EXTERNAL_EXPOSURE;
  END IF;

  IF  p_credit_check_rule_rec.include_payments_at_risk_flag  =  'Y'  THEN
    b9 := G_PAYMENTS_AT_RISK;

    IF p_credit_check_rule_rec.open_ar_days is NULL
    THEN
      b22 := G_BR_PAYMENTS_AT_RISK ;
    END IF;

  END IF;
  IF  p_credit_check_rule_rec.open_ar_balance_flag  =  'Y'  THEN
    b8 := G_INVOICES;

    IF p_credit_check_rule_rec.open_ar_days is NULL
    THEN
      b21 := G_BR_INVOICES ;
    END IF;
  END IF;


  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add
  (b1 || ' ' || b2 || ' ' || b3 || ' ' || b4 || ' ' || b5 || ' ' || b6 || ' '
   || b7 || ' ' || b8 || ' ' || b9 || ' ' || b10 || ' ' || b11 || ' ' || b12 ||
' '
   || b13 || ' ' || b14 || ' ' || b15 || ' ' || b16 || ' ' || b17 || ' ' || b18||
   ' '|| b23 || ' ' || b24 || ' ' || b25 || ' ' || b26 || ' ' || b27 || ' ' || b28||
   ' '|| b29 || ' ' || b30 || ' ' || b31 || ' ' || b32 || ' ' || b33 || ' ' || b34||
   ' '|| b35 || ' ' || b36,
 2 );

    oe_debug_pub.add( ' Out from balance_types_om_and_ar ');
  END IF;

END balance_types_om_and_ar ;

-----------------------------------------------------------

-----------------------------------------------------------
-- This procedure will set the balance types for the
-- OM exposure based on the credit check rules setup
--  This procedure will also set the external exposure
-- balance types
-----------------------------------------------------------

PROCEDURE balance_types_om_nohold
(p_credit_check_rule_rec   IN    OE_CREDIT_CHECK_UTIL.oe_credit_rules_rec_type
)
IS
BEGIN
  b1 := -1;
  b2 := -1;
  b3 := -1;
  b4 := -1;
  b5 := -1;
  b6 := -1;
  b7 := -1;
  b8 := -1;
  b9 := -1;
  b10 := -1;
  b11 := -1;
  b12 := -1;
  b13 := -1;
  b14 := -1;
  b15 := -1;
  b16 := -1;
  b17 := -1;
  b18 := -1;
  b21 := -1;
  b22 := -1;

----added for the RETURNS
  b23 := -1;
  b24 := -1;
  b25 := -1;
  b26 := -1;
  b27 := -1;
  b28 := -1;
  b29 := -1;
  b30 := -1;
  b31 := -1;
  b32 := -1;
  b33 := -1;
  b34 := -1;
  b35 := -1;
  b36 := -1;


  -- Determine which balance types to select:
  -- Chosing a balance type is indicated by setting the corresponding
  -- variable to a balance type global constant
  -- (e.g. b4 := G_ORDER_HOLDS)


  IF  p_credit_check_rule_rec.uninvoiced_orders_flag     =  'Y'  THEN
    IF p_credit_check_rule_rec.credit_check_level_code  = 'LINE' THEN
      b3 := G_LINE_UNINVOICED_ORDERS;

      -----added for the Returns project
      IF p_credit_check_rule_rec.include_returns_flag = 'Y'
      THEN
        b24 := G_LINE_RETURN_UNINV_ORDERS;
      END IF;
    ELSE
      b1 := G_HEADER_UNINVOICED_ORDERS;

      -----added for the Returns project
      IF p_credit_check_rule_rec.include_returns_flag = 'Y'
      THEN
        b23 := G_HEAD_RETURN_UNINV_ORDERS;
      END IF;
    END IF;
  END IF;


  IF  p_credit_check_rule_rec.include_tax_flag           =  'Y'  THEN
    IF p_credit_check_rule_rec.credit_check_level_code  = 'LINE' THEN
      b4 := G_LINE_UNINVOICED_ORDERS_TAX;

      -----added for the Returns project
      IF p_credit_check_rule_rec.include_returns_flag = 'Y'
      THEN
        b26:= G_LINE_RETURN_UNINV_ORD_TAX;
      END IF;
    ELSE
      b2 := G_HEADER_UNINVOICED_ORDERS_TAX;

      -----added for the Returns project
      IF p_credit_check_rule_rec.include_returns_flag = 'Y'
      THEN
        b25:= G_HEAD_RETURN_UNINV_ORD_TAX;
      END IF;

    END IF;
  END IF;

  IF  p_credit_check_rule_rec.incl_freight_charges_flag  =  'Y'  THEN
    IF p_credit_check_rule_rec.credit_check_level_code  = 'LINE' THEN
      b5 := G_LINE_UNINVOICED_FREIGHT;

      -----added for the Returns project
      IF p_credit_check_rule_rec.include_returns_flag = 'Y'
      THEN
        b28:= G_LINE_RETURN_UNINV_FREIGHT;
      END IF;

    ELSE
      b6 := G_HEADER_UNINVOICED_FREIGHT;

      -----added for the Returns project
      IF p_credit_check_rule_rec.include_returns_flag = 'Y'
      THEN
        b27:= G_HEAD_RETURN_UNINV_FREIGHT;
      END IF;

    END IF;
    b7 := G_HEADER_AND_LINE_FREIGHT;

    -----added for the Returns project
    IF p_credit_check_rule_rec.include_returns_flag = 'Y'
    THEN
      b29:= G_HEAD_LINE_RETURN_FREIGHT;
    END IF;

  END IF;

  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add
    (b1 || ' ' || b2 || ' ' || b3 || ' ' || b4 || ' ' || b5 || ' ' || b6 || ' '
   || b7 || ' ' || b8 || ' ' || b9 || ' ' || b10 || ' ' || b11 || ' ' || b12 || ' '
   || b13 || ' ' || b14 || ' ' || b15 || ' ' || b16 || ' ' || b17 || ' ' || b18||' '
   || b23 || ' ' || b24 || ' ' || b25 || ' ' || b26 || ' ' || b27 || ' ' || b28||' '||b29, 2 );

    oe_debug_pub.add( ' Out from balance_types_om_nohold ' );
  END IF;
END balance_types_om_nohold;
---------------------------------------------------------------

PROCEDURE balance_types_om_hold
(p_credit_check_rule_rec   IN    OE_CREDIT_CHECK_UTIL.oe_credit_rules_rec_type
)
IS
BEGIN
  b1 := -1;
  b2 := -1;
  b3 := -1;
  b4 := -1;
  b5 := -1;
  b6 := -1;
  b7 := -1;
  b8 := -1;
  b9 := -1;
  b10 := -1;
  b11 := -1;
  b12 := -1;
  b13 := -1;
  b14 := -1;
  b15 := -1;
  b16 := -1;
  b17 := -1;
  b18 := -1;
  b21 := -1;
  b22 := -1;
----added for the RETURNS
  b23 := -1;
  b24 := -1;
  b25 := -1;
  b26 := -1;
  b27 := -1;
  b28 := -1;
  b29 := -1;
  b30 := -1;
  b31 := -1;
  b32 := -1;
  b33 := -1;
  b34 := -1;
  b35 := -1;
  b36 := -1;


  -- Determine which balance types to select:
  -- Chosing a balance type is indicated by setting the corresponding
  -- variable to a balance type global constant
  -- (e.g. b4 := G_ORDER_HOLDS)

  IF  p_credit_check_rule_rec.uninvoiced_orders_flag     =  'Y'  THEN
    IF p_credit_check_rule_rec.credit_check_level_code  = 'LINE' THEN
      IF p_credit_check_rule_rec.orders_on_hold_flag  =  'N'  THEN
        b11 := G_LINE_HOLDS;

        -----added for the Returns project
        IF p_credit_check_rule_rec.include_returns_flag = 'Y'
        THEN
          b31 := G_LINE_RETURN_HOLDS;
        END IF;

      END IF;
    ELSE
      IF p_credit_check_rule_rec.orders_on_hold_flag  =  'N'  THEN
        b10 := G_ORDER_HOLDS;

        -----added for the Returns project
        IF p_credit_check_rule_rec.include_returns_flag = 'Y'
        THEN
          b30 := G_ORDER_RETURN_HOLDS;
        END IF;

      END IF;
    END IF;
  END IF;

  IF  p_credit_check_rule_rec.include_tax_flag           =  'Y'  THEN
    IF p_credit_check_rule_rec.credit_check_level_code  = 'LINE' THEN
      IF p_credit_check_rule_rec.orders_on_hold_flag  =  'N'  THEN
        b14 := G_LINE_TAX_HOLDS;

        -----added for the Returns project
        IF p_credit_check_rule_rec.include_returns_flag = 'Y'
        THEN
          b33:= G_LINE_RETURN_TAX_HOLDS;
        END IF;

      END IF;
    ELSE
      IF p_credit_check_rule_rec.orders_on_hold_flag  =  'N'  THEN
	b13 := G_ORDER_TAX_HOLDS;

        -----added for the Returns project
        IF p_credit_check_rule_rec.include_returns_flag = 'Y'
        THEN
          b32:= G_ORDER_RETURN_TAX_HOLDS;
        END IF;

      END IF;
    END IF;
  END IF;

  IF  p_credit_check_rule_rec.incl_freight_charges_flag  =  'Y'  THEN
    IF p_credit_check_rule_rec.credit_check_level_code  = 'LINE' THEN
      IF p_credit_check_rule_rec.orders_on_hold_flag  =  'N'  THEN
	b16 := G_LINE_FREIGHT_HOLDS;

        -----added for the Returns project
        IF p_credit_check_rule_rec.include_returns_flag = 'Y'
        THEN
          b35:= G_LINE_RETURN_FREIGHT_HOLDS;
        END IF;

      END IF;
    ELSE
      IF p_credit_check_rule_rec.orders_on_hold_flag  =  'N'  THEN
        b15 := G_ORDER_FREIGHT_HOLDS;

        -----added for the Returns project
        IF p_credit_check_rule_rec.include_returns_flag = 'Y'
        THEN
          b34:= G_ORDER_RETURN_FREIGHT_HOLDS;
        END IF;

      END IF;
    END IF;

    IF p_credit_check_rule_rec.orders_on_hold_flag  =  'N'  THEN
      b17 := G_HEADER_LINE_FREIGHT_HOLDS;

      -----added for the Returns project
      IF p_credit_check_rule_rec.include_returns_flag = 'Y'
      THEN
        b36:= G_H_L_RETURN_FREIGHT_HOLDS;
      END IF;

    END IF;
  END IF;

  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add
  (b1 || ' ' || b2 || ' ' || b3 || ' ' || b4 || ' ' || b5 || ' ' || b6 || ' '
   || b7 || ' ' || b8 || ' ' || b9 || ' ' || b10 || ' ' || b11 || ' ' || b12 || ' '
   || b13 || ' ' || b14 || ' ' || b15 || ' ' || b16 || ' ' || b17 || ' ' || b18|| ' '
   || b30 || ' ' || b31 || ' ' || b32 || ' ' || b33 || ' ' || b34 || ' ' || b35|| ' '
   || b36, 2 );

    oe_debug_pub.add( ' Out from balance_types_om_hold ' );
  END IF;
END balance_types_om_hold;

PROCEDURE balance_types_om
( p_credit_check_rule_rec   IN    OE_CREDIT_CHECK_UTIL.oe_credit_rules_rec_type
)
IS
BEGIN
  b1 := -1;
  b2 := -1;
  b3 := -1;
  b4 := -1;
  b5 := -1;
  b6 := -1;
  b7 := -1;
  b8 := -1;
  b9 := -1;
  b10 := -1;
  b11 := -1;
  b12 := -1;
  b13 := -1;
  b14 := -1;
  b15 := -1;
  b16 := -1;
  b17 := -1;
  b18 := -1;
  b21 := -1;
  b22 := -1;

----added for the RETURNS
  b23 := -1;
  b24 := -1;
  b25 := -1;
  b26 := -1;
  b27 := -1;
  b28 := -1;
  b29 := -1;
  b30 := -1;
  b31 := -1;
  b32 := -1;
  b33 := -1;
  b34 := -1;
  b35 := -1;
  b36 := -1;


  -- Determine which balance types to select:
  -- Chosing a balance type is indicated by setting the corresponding
  -- variable to a balance type global constant
  -- (e.g. b4 := G_ORDER_HOLDS)

  IF  p_credit_check_rule_rec.uninvoiced_orders_flag     =  'Y'  THEN
    IF p_credit_check_rule_rec.credit_check_level_code  = 'LINE' THEN
      b3 := G_LINE_UNINVOICED_ORDERS;

      -----added for the Returns project
      IF p_credit_check_rule_rec.include_returns_flag = 'Y'
      THEN
        b24 := G_LINE_RETURN_UNINV_ORDERS;
      END IF;

      IF p_credit_check_rule_rec.orders_on_hold_flag  =  'N'  THEN
        b11 := G_LINE_HOLDS;

        -----added for the Returns project
        IF p_credit_check_rule_rec.include_returns_flag = 'Y'
        THEN
          b31 := G_LINE_RETURN_HOLDS;
        END IF;

      END IF;
    ELSE
      b1 := G_HEADER_UNINVOICED_ORDERS;

      -----added for the Returns project
      IF p_credit_check_rule_rec.include_returns_flag = 'Y'
      THEN
        b23 := G_HEAD_RETURN_UNINV_ORDERS;
      END IF;

      IF p_credit_check_rule_rec.orders_on_hold_flag  =  'N'
      THEN
        b10 := G_ORDER_HOLDS;

        -----added for the Returns project
        IF p_credit_check_rule_rec.include_returns_flag = 'Y'
        THEN
          b30 := G_ORDER_RETURN_HOLDS;
        END IF;

      END IF;
    END IF;
  END IF;
  IF  p_credit_check_rule_rec.include_tax_flag           =  'Y'
  THEN
    IF p_credit_check_rule_rec.credit_check_level_code  = 'LINE'
    THEN
      b4 := G_LINE_UNINVOICED_ORDERS_TAX;

      -----added for the Returns project
      IF p_credit_check_rule_rec.include_returns_flag = 'Y'
      THEN
        b26:= G_LINE_RETURN_UNINV_ORD_TAX;
      END IF;

      IF p_credit_check_rule_rec.orders_on_hold_flag  =  'N'
      THEN
        b14 := G_LINE_TAX_HOLDS;

        -----added for the Returns project
        IF p_credit_check_rule_rec.include_returns_flag = 'Y'
        THEN
          b33:= G_LINE_RETURN_TAX_HOLDS;
        END IF;

      END IF;
    ELSE
      b2 := G_HEADER_UNINVOICED_ORDERS_TAX;

      -----added for the Returns project
      IF p_credit_check_rule_rec.include_returns_flag = 'Y'
      THEN
        b25:= G_HEAD_RETURN_UNINV_ORD_TAX;
      END IF;

      IF p_credit_check_rule_rec.orders_on_hold_flag  =  'N'
      THEN
	b13 := G_ORDER_TAX_HOLDS;

        -----added for the Returns project
        IF p_credit_check_rule_rec.include_returns_flag = 'Y'
        THEN
          b32:= G_ORDER_RETURN_TAX_HOLDS;
        END IF;

      END IF;
    END IF;
  END IF;
  IF  p_credit_check_rule_rec.incl_freight_charges_flag  =  'Y'
  THEN
    IF p_credit_check_rule_rec.credit_check_level_code  = 'LINE'
    THEN
      b5 := G_LINE_UNINVOICED_FREIGHT;

      -----added for the Returns project
      IF p_credit_check_rule_rec.include_returns_flag = 'Y'
      THEN
        b28:= G_LINE_RETURN_UNINV_FREIGHT;
      END IF;

      IF p_credit_check_rule_rec.orders_on_hold_flag  =  'N'
      THEN
	b16 := G_LINE_FREIGHT_HOLDS;

        -----added for the Returns project
        IF p_credit_check_rule_rec.include_returns_flag = 'Y'
        THEN
          b35:= G_LINE_RETURN_FREIGHT_HOLDS;
        END IF;

      END IF;
    ELSE
      b6 := G_HEADER_UNINVOICED_FREIGHT;

      -----added for the Returns project
      IF p_credit_check_rule_rec.include_returns_flag = 'Y'
      THEN
        b27:= G_HEAD_RETURN_UNINV_FREIGHT;
      END IF;

      IF p_credit_check_rule_rec.orders_on_hold_flag  =  'N'
      THEN
        b15 := G_ORDER_FREIGHT_HOLDS;

        -----added for the Returns project
        IF p_credit_check_rule_rec.include_returns_flag = 'Y'
        THEN
          b34:= G_ORDER_RETURN_FREIGHT_HOLDS;
        END IF;

      END IF;
    END IF;
    b7 := G_HEADER_AND_LINE_FREIGHT;

    -----added for the Returns project
    IF p_credit_check_rule_rec.include_returns_flag = 'Y'
    THEN
      b29:= G_HEAD_LINE_RETURN_FREIGHT;
    END IF;

    IF p_credit_check_rule_rec.orders_on_hold_flag  =  'N'
    THEN
      b17 := G_HEADER_LINE_FREIGHT_HOLDS;

      -----added for the Returns project
      IF p_credit_check_rule_rec.include_returns_flag = 'Y'
      THEN
        b36:= G_H_L_RETURN_FREIGHT_HOLDS;
      END IF;

    END IF;
  END IF;

  -- Set value for external exposure
  IF  p_credit_check_rule_rec.include_external_exposure_flag  =  'Y'
  THEN
    b18 := G_EXTERNAL_EXPOSURE;
  END IF;

  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add
  (b1 || ' ' || b2 || ' ' || b3 || ' ' || b4 || ' ' || b5 || ' ' || b6 || ' '
   || b7 || ' ' || b8 || ' ' || b9 || ' ' || b10 || ' ' || b11 || ' ' || b12 || ' '
   || b13 || ' ' || b14 || ' ' || b15 || ' ' || b16 || ' ' || b17 || ' ' || b18 || ' '
   || b23 || ' ' || b24 || ' ' || b25 || ' ' || b26 || ' ' || b27 || ' ' || b28|| ' '
   || b29 || ' ' || b30 || ' ' || b31 || ' ' || b32 || ' ' || b33 || ' ' || b34|| ' '
   || b35 || ' ' || b36, 2 );

    oe_debug_pub.add( ' Out from balance_types_om ' );
  END IF;
END balance_types_om;

-----------------------------------------------------------
-- This procedure will set the balance types for the
-- AR exposure based on the credit check rules setup
----------------------------------------------------------
PROCEDURE balance_types_ar
( p_credit_check_rule_rec   IN    OE_CREDIT_CHECK_UTIL.oe_credit_rules_rec_type
)
IS
BEGIN
  b1 := -1;
  b2 := -1;
  b3 := -1;
  b4 := -1;
  b5 := -1;
  b6 := -1;
  b7 := -1;
  b8 := -1;
  b9 := -1;
  b10 := -1;
  b11 := -1;
  b12 := -1;
  b13 := -1;
  b14 := -1;
  b15 := -1;
  b16 := -1;
  b17 := -1;
  b18 := -1;
  b21 := -1 ;
  b22 := -1;

----added for the RETURNS
  b23 := -1;
  b24 := -1;
  b25 := -1;
  b26 := -1;
  b27 := -1;
  b28 := -1;
  b29 := -1;
  b30 := -1;
  b31 := -1;
  b32 := -1;
  b33 := -1;
  b34 := -1;
  b35 := -1;
  b36 := -1;

  IF  p_credit_check_rule_rec.include_payments_at_risk_flag  =  'Y'  THEN
    b9 := G_PAYMENTS_AT_RISK;

    IF p_credit_check_rule_rec.open_ar_days is NULL
    THEN
      b22 := G_BR_PAYMENTS_AT_RISK ;
    END IF;

  END IF;
  IF  p_credit_check_rule_rec.open_ar_balance_flag  =  'Y'  THEN
    b8 := G_INVOICES;

    IF p_credit_check_rule_rec.open_ar_days is NULL
    THEN
      b21 := G_BR_INVOICES ;
    END IF;
  END IF;


  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add
    (b1 || ' ' || b2 || ' ' || b3 || ' ' || b4 || ' ' || b5 || ' ' || b6 || ' '
        || b7 || ' ' || b8 || ' ' || b9 || ' ' || b10 || ' ' || b11 || ' ' || b12 || ' '
        || b13 || ' ' || b14 || ' ' || b15 || ' ' || b16 || ' ' || b17 || ' ' || b18 || ' ' || b21 || ' ' ||b22,2 );

    oe_debug_pub.add( ' Out from balance_types_ar ');
  END IF;

END balance_types_ar;


------------------------------------------------------------------
-- COMMENTS: This procedure will calculate all the
--           buckets that are required to be summed
--           to arive at the exposure balance
--           The driving date for the calculate buckets
--           will be the Horizon date ( both OM and AR )
--          as the Main starting Bucket will be the largest
--          bucket that includes this Horizon date
--          Once the Main Bucket is calculated, all the
--          Buckets to the LEFT of the Main Bucket is
--         SUMMED UP.
--         Now inside the Main Bucket, the remaining Buckets
--         constitute the Fractional Amount and this
--         procedure wil identify those Buckets as well.

--        p_interval parameter is used to identify the cases
--        where the credit check rule was not setup to use
--        horizon days.
--        In such cases, the exposure can be recovered by
--        SUMMING overal exposure for all the largest
--        buckets , as we need to use all the data
-----------------------------------------------------------------
PROCEDURE calculate_buckets
( p_date         IN   NUMBER
, p_interval     IN   NUMBER
, x_main_bucket  OUT  NOCOPY NUMBER
, x_binary_tbl   OUT  NOCOPY oe_credit_exposure_pvt.Binary_tbl_type
)
IS
  l_date                NUMBER;
  l_level               NUMBER;
  l_bucket_length       NUMBER;
  l_bucket              NUMBER;
  l_main_bucket_length  NUMBER;
  i                     BINARY_INTEGER;
BEGIN
  l_date  := p_date;

  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'Into calculate_buckets ');
    oe_debug_pub.add( 'p_date =>'|| p_date );
    oe_debug_pub.add( 'p_interval =>' || p_interval );
  END IF;

  -- the Main Bucket
  l_level             :=  G_MAX_BUCKET_LEVEL;
  l_bucket_length     := POWER( 2, l_level );
  l_bucket            := l_date  -  MOD( l_date, l_bucket_length );

  l_main_bucket_length := l_bucket_length;
  x_main_bucket        := l_bucket;

  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'l_date ==> '|| l_date);
    oe_debug_pub.add( 'l_bucket_length ==> '|| l_bucket_length );
    oe_debug_pub.add( 'Main Bucket ==> '|| x_main_bucket ,1);
  END IF;

  IF p_interval is NOT NULL
  THEN
    -- The Buckets need to be identified as the Horizon interval
    -- is included.
    BEGIN
  -- the fractional amount of the Main Bucket
  -- Start from the Main Bucket and navigate to
  -- the right of the bucket
 --  by decreasing the level for each iteration and thereby
  -- reducing the bucket lengths as well as the bucket lengths as
  -- well. Include the buckets where the buckets comprise
  -- data for the dates <= than the horizon date and continue from
  -- there

     WHILE  l_bucket  - 1  <>  l_date
     LOOP
      IF l_bucket + l_bucket_length - 1  <=  l_date
      THEN
      --  include Bucket

          x_binary_tbl( l_level ).bucket        := l_bucket;
          x_binary_tbl( l_level ).bucket_length := l_bucket_length;

         l_bucket  := l_bucket + l_bucket_length;

      END IF;

      l_level  := l_level - 1;
      l_bucket_length  := l_bucket_length / 2;

     END LOOP;

     IF G_debug_flag = 'Y'
     THEN
       oe_debug_pub.add( 'Out of the Main LOOP');
       oe_debug_pub.add( '-------------------------------------- ');
       oe_debug_pub.add( 'selected buckets: ' );
     END IF;

      i  :=  x_binary_tbl.FIRST;
      WHILE i IS NOT NULL LOOP

     IF G_debug_flag = 'Y'
     THEN
      oe_debug_pub.add
      ( 'Bucket Number: ' || x_binary_tbl(i).bucket || ', '
          || 'Bucket Length:' || x_binary_tbl(i).bucket_length, 2 );
     END IF;

        i :=  x_binary_tbl.NEXT(i);
      END LOOP;

      oe_debug_pub.add( '-------------------------------------- ');

    END;
   ELSE
    oe_debug_pub.add( 'No need to calculate Buckets, no Horizon  ');
   END IF;

  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'Out calculate_buckets ');
  END IF;


END calculate_buckets;



-----------------------------------------------------------------
--- API to convert the amount using GL currency API
-- with Traingulation
----------------------------------------------------------------
FUNCTION convert_currency_amount
( p_amount                   IN   NUMBER
, p_transactional_currency   IN   VARCHAR2
, p_limit_currency           IN   VARCHAR2
)
RETURN NUMBER
IS
  l_term     NUMBER;
BEGIN
  BEGIN
    l_term :=
      OE_CREDIT_CHECK_UTIL.convert_currency_amount
      ( p_amount                  => p_amount
      , p_transactional_currency  => p_transactional_currency
      , p_limit_currency          => p_limit_currency
      , p_functional_currency     => g_functional_currency
      , p_conversion_date         => SYSDATE
      , p_conversion_type         => g_conversion_type
      );
  EXCEPTION
    WHEN  GL_CURRENCY_API.NO_RATE  OR
     GL_CURRENCY_API.INVALID_CURRENCY
    THEN
     oe_debug_pub.add( 'conversion exception for '
             || p_transactional_currency, 1 );
      add_error_currency( g_error_curr_tbl, p_transactional_currency );
  END;

  RETURN NVL( l_term, 0 );

END convert_currency_amount;

----------------------------------------------------------
---- COMMENTS: Fucntion to select the overall exposure from the
--             OE_CREDIT_SUMMARIES table for the balance types
--             This function will be called from the main
--              GET_EXPOSURE procedure both for AR and OM exposure
--             as the exposure balance is governed by the
--             balance types used
--------------------------------------------------------------
FUNCTION retrieve_exposure
( p_binary_tbl           IN  oe_credit_exposure_pvt.Binary_tbl_type
, p_site_use_id          IN  NUMBER
, p_customer_id          IN  NUMBER
, p_party_id             IN  NUMBER
, p_org_id               IN  NUMBER
, p_include_all_flag     IN  VARCHAR2
, p_usage_curr_tbl       IN  OE_CREDIT_CHECK_UTIL.curr_tbl_type
, p_limit_curr_code      IN  HZ_CREDIT_PROFILE_AMTS.currency_code%TYPE
, p_main_bucket          IN  NUMBER
, p_global_exposure_flag IN  VARCHAR2
, p_credit_check_rule_rec IN
     OE_CREDIT_CHECK_UTIL.oe_credit_rules_rec_type
, x_error_curr_tbl       IN  OUT NOCOPY  OE_CREDIT_CHECK_UTIL.curr_tbl_type
)
RETURN NUMBER
IS
  i                  BINARY_INTEGER;
  l_site_use_id      NUMBER;
  l_br_site_use_id   NUMBER;
  l_currency_code HZ_CREDIT_PROFILE_AMTS.currency_code%TYPE;

  l_balance          NUMBER := 0 ;
  l_br_balance       NUMBER := 0 ;
  l_term             NUMBER := 0 ;
  l_total            NUMBER := 0 ;

  l_bucket          NUMBER;
  l_bucket_length   NUMBER;
  j                 NUMBER;

  l_br_bucket          NUMBER;
  l_br_bucket_length   NUMBER;

  CURSOR site_balance_csr IS
  SELECT SUM( balance )
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
 	 (b1, b2, b3, b4, b5, b6, b7, b8, b9,
	  b10, b11, b12, b13, b14, b15, b16, b17, b18)
  AND  site_use_id           =  l_site_use_id
  AND  currency_code         =  l_currency_code
  AND  bucket                =  l_bucket
  AND  bucket_duration       =  l_bucket_length
  ;

  ---added for the Returns project
  ---the same as above including Returns
  CURSOR site_balance_ret_csr IS
  SELECT NVL(SUM( balance ),0)
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
 	 (b1, b2, b3, b4, b5, b6, b7, b8, b9,
	  b10, b11, b12, b13, b14, b15, b16, b17, b18, b23, b24,
        b25, b26, b27, b28, b29, b30, b31, b32, b33, b34, b35, b36)
  AND  site_use_id           =  l_site_use_id
  AND  currency_code         =  l_currency_code
  AND  bucket                =  l_bucket
  AND  bucket_duration       =  l_bucket_length;


  CURSOR site_balance_stub_csr IS
  SELECT SUM( balance )
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
	 (b1, b2, b3, b4, b5, b6, b7, b8, b9,
	  b10, b11, b12, b13, b14, b15, b16, b17, b18)
  AND  site_use_id           =  l_site_use_id
  AND  currency_code         =  l_currency_code
  AND  bucket                <  l_bucket
  AND  bucket_duration       =  l_bucket_length
  ;

  ---added for the Returns project
  ---the same as above including Returns
  CURSOR site_balance_stub_ret_csr IS
  SELECT SUM( balance )
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
	 (b1, b2, b3, b4, b5, b6, b7, b8, b9,
	  b10, b11, b12, b13, b14, b15, b16, b17, b18, b23, b24,
        b25, b26, b27, b28, b29, b30, b31, b32, b33, b34, b35, b36)
  AND  site_use_id           =  l_site_use_id
  AND  currency_code         =  l_currency_code
  AND  bucket                <  l_bucket
  AND  bucket_duration       =  l_bucket_length;


  CURSOR site_br_stub_csr IS
  SELECT SUM( balance )
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
          (21,22)
  AND  site_use_id           =  l_br_site_use_id
  AND  currency_code         =  l_currency_code
  AND  bucket                <  l_br_bucket
  AND bucket_duration        =  l_br_bucket_length
  ;


  CURSOR customer_balance_csr IS
  SELECT SUM( balance )
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
	 (b1, b2, b3, b4, b5, b6, b7, b8, b9,
          b10, b11, b12, b13, b14, b15, b16, b17, b18, b21,b22)
  AND  cust_account_id       =  p_customer_id
  AND  ((org_id              =  p_org_id)
         OR
        (org_id IS NULL AND p_org_id IS NULL))
  AND  currency_code         =  l_currency_code
  AND  bucket                =  l_bucket
  AND bucket_duration        =  l_bucket_length
  ;

  ---added for the Returns project
  ---the same as above including Returns
  CURSOR customer_balance_ret_csr IS
  SELECT SUM( balance )
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
	 (b1, b2, b3, b4, b5, b6, b7, b8, b9,
          b10, b11, b12, b13, b14, b15, b16, b17, b18, b21,b22, b23, b24,
        b25, b26, b27, b28, b29, b30, b31, b32, b33, b34, b35, b36)
  AND  cust_account_id       =  p_customer_id
  AND  ((org_id              =  p_org_id)
         OR
        (org_id IS NULL AND p_org_id IS NULL))
  AND  currency_code         =  l_currency_code
  AND  bucket                =  l_bucket
  AND bucket_duration         =  l_bucket_length;


  CURSOR customer_balance_stub_csr IS
  SELECT SUM( balance )
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
	 (b1, b2, b3, b4, b5, b6, b7, b8, b9,
	  b10, b11, b12, b13, b14, b15, b16, b17, b18, b21, b22)
  AND  cust_account_id       =  p_customer_id
  AND  ((org_id              =  p_org_id)
         OR
        (org_id IS NULL AND p_org_id IS NULL))
  AND  currency_code         =  l_currency_code
  AND  bucket                <  l_bucket
  AND bucket_duration         =  l_bucket_length
  ;

  ---added for the Returns project
  ---the same as above including Returns
  CURSOR customer_balance_stub_ret_csr IS
  SELECT SUM( balance )
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
	 (b1, b2, b3, b4, b5, b6, b7, b8, b9,
	  b10, b11, b12, b13, b14, b15, b16, b17, b18, b21, b22, b23, b24,
        b25, b26, b27, b28, b29, b30, b31, b32, b33, b34, b35, b36)
  AND  cust_account_id       =  p_customer_id
  AND  ((org_id              =  p_org_id)
         OR
        (org_id IS NULL AND p_org_id IS NULL))
  AND  currency_code         =  l_currency_code
  AND  bucket                <  l_bucket
  AND bucket_duration         =  l_bucket_length
  ;


  CURSOR customer_br_stub_csr IS
  SELECT SUM( balance )
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
          (21,22)
  AND  cust_account_id       =  p_customer_id
  AND  ((org_id              =  p_org_id)
         OR
        (org_id IS NULL AND p_org_id IS NULL))
  AND  currency_code         =  l_currency_code
  AND  bucket                <  l_br_bucket
  AND bucket_duration         =  l_br_bucket_length
  ;


  CURSOR cust_balance_csr_global IS
  SELECT SUM( balance )
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
         (b1, b2, b3, b4, b5, b6, b7, b8, b9, b10,
  	  b11, b12, b13, b14, b15, b16, b17, b18, b21, b22)
  AND  cust_account_id       =  p_customer_id
  AND  currency_code         =  l_currency_code
  AND  bucket                =  l_bucket
  AND bucket_duration         =  l_bucket_length
  ;

  ---added for the Returns project
  ---the same as above including Returns

  CURSOR cust_balance_ret_csr_global IS
  SELECT SUM( balance )
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
         (b1, b2, b3, b4, b5, b6, b7, b8, b9, b10,
  	  b11, b12, b13, b14, b15, b16, b17, b18, b21, b22,
          b23, b24, b25, b26, b27, b28, b29, b30, b31,
          b32, b33, b34, b35, b36)
  AND  cust_account_id       =  p_customer_id
  AND  currency_code         =  l_currency_code
  AND  bucket                =  l_bucket
  AND bucket_duration        =  l_bucket_length
  ;

  CURSOR cust_balance_stub_csr_global IS
  SELECT SUM( balance )
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
         (b1, b2, b3, b4, b5, b6, b7, b8, b9, b10,
	  b11, b12, b13, b14, b15, b16, b17, b18, b21, b22)
  AND  cust_account_id       =  p_customer_id
  AND  currency_code         =  l_currency_code
  AND  bucket                <  l_bucket
  AND bucket_duration         =  l_bucket_length
  ;

  ---added for the Returns project
  ---the same as above including Returns
  CURSOR cust_bal_stub_ret_csr_global IS
  SELECT SUM( balance )
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
         (b1, b2, b3, b4, b5, b6, b7, b8, b9, b10,
	  b11, b12, b13, b14, b15, b16, b17, b18, b21, b22,
          b23, b24, b25, b26, b27, b28, b29, b30, b31,
          b32, b33, b34, b35, b36)
  AND  cust_account_id       =  p_customer_id
  AND  currency_code         =  l_currency_code
  AND  bucket                <  l_bucket
  AND bucket_duration         =  l_bucket_length
  ;

  CURSOR cust_br_stub_csr_global IS
  SELECT SUM( balance )
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
          (21,22)
  AND  cust_account_id       =  p_customer_id
  AND  currency_code         =  l_currency_code
  AND  bucket                <  l_br_bucket
  AND bucket_duration         =  l_br_bucket_length
  ;


--------------------------------------------------------------

  CURSOR party_balance_csr_global IS
  SELECT SUM( balance )
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
         (b1, b2, b3, b4, b5, b6, b7, b8, b9, b10,
  	  b11, b12, b13, b14, b15, b16, b17, b18, b21, b22)
  AND  party_id              =  p_party_id
  AND  currency_code         =  l_currency_code
  AND  bucket                =  l_bucket
  AND bucket_duration         =  l_bucket_length
  ;

  ---added for the Returns project
  ---the same as above including Returns

  CURSOR party_balance_ret_csr_global IS
  SELECT SUM( balance )
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
         (b1, b2, b3, b4, b5, b6, b7, b8, b9, b10,
  	  b11, b12, b13, b14, b15, b16, b17, b18, b21, b22,
          b23, b24, b25, b26, b27, b28, b29, b30, b31,
          b32, b33, b34, b35, b36)
  AND  party_id              =  p_party_id
  AND  currency_code         =  l_currency_code
  AND  bucket                =  l_bucket
  AND bucket_duration         =  l_bucket_length
  ;


  CURSOR party_balance_stub_csr_global IS
  SELECT SUM( balance )
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
         (b1, b2, b3, b4, b5, b6, b7, b8, b9, b10,
	  b11, b12, b13, b14, b15, b16, b17, b18, b21, b22)
  AND  party_id              =  p_party_id
  AND  currency_code         =  l_currency_code
  AND  bucket                <  l_bucket
  AND bucket_duration         =  l_bucket_length
  ;

  ---added for the Returns project
  ---the same as above including Returns
  CURSOR party_bal_stub_ret_csr_global IS
  SELECT SUM( balance )
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
         (b1, b2, b3, b4, b5, b6, b7, b8, b9, b10,
	  b11, b12, b13, b14, b15, b16, b17, b18, b21, b22,
           b23, b24, b25, b26, b27, b28, b29, b30, b31,
          b32, b33, b34, b35, b36)
  AND  party_id              =  p_party_id
  AND  currency_code         =  l_currency_code
  AND  bucket                <  l_bucket
  AND bucket_duration         =  l_bucket_length
  ;

  CURSOR party_br_stub_csr_global IS
  SELECT SUM( balance )
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
          (21,22)
  AND  party_id              =  p_party_id
  AND  currency_code         =  l_currency_code
  AND  bucket                <  l_br_bucket
  AND bucket_duration         =  l_br_bucket_length
  ;


-------------------------------------------------------------
  CURSOR party_h_balance_csr_global IS
  SELECT SUM( oes.balance )
  FROM   oe_credit_summaries oes
     ,   hz_hierarchy_nodes hn
  WHERE  oes.balance_type  IN
         (b1, b2, b3, b4, b5, b6, b7, b8, b9, b10,
  	  b11, b12, b13, b14, b15, b16, b17, b18, b21, b22)
  AND  hn.parent_id                    = p_party_id
  AND  hn.parent_object_type           = 'ORGANIZATION'
  and  hn.parent_table_name            = 'HZ_PARTIES'
  and  hn.child_object_type            = 'ORGANIZATION'
  and  hn.effective_start_date  <=  sysdate
  and  hn.effective_end_date    >= SYSDATE
  and  hn.hierarchy_type
                = OE_CREDIT_CHECK_UTIL.G_hierarchy_type
  AND  oes.party_id                        =  hn.child_id
  AND  oes.currency_code                   =  l_currency_code
  AND  oes.bucket                          =  l_bucket
  AND  oes.bucket_duration                   =  l_bucket_length
  ;


  ---added for the Returns project
  ---the same as above including Returns
  CURSOR party_h_bal_ret_csr_global IS
  SELECT SUM( oes.balance )
  FROM   oe_credit_summaries oes
     ,   hz_hierarchy_nodes hn
  WHERE  oes.balance_type  IN
         (b1, b2, b3, b4, b5, b6, b7, b8, b9, b10,
  	  b11, b12, b13, b14, b15, b16, b17, b18, b21, b22,
          b23, b24, b25, b26, b27, b28, b29, b30, b31,
          b32, b33, b34, b35, b36)
  AND  hn.parent_id                    = p_party_id
  AND  hn.parent_object_type           = 'ORGANIZATION'
  and  hn.parent_table_name            = 'HZ_PARTIES'
  and  hn.child_object_type            = 'ORGANIZATION'
  and  hn.effective_start_date  <=  sysdate
  and  hn.effective_end_date    >= SYSDATE
  and  hn.hierarchy_type
                = OE_CREDIT_CHECK_UTIL.G_hierarchy_type
  AND  oes.party_id                        =  hn.child_id
  AND  oes.currency_code                   =  l_currency_code
  AND  oes.bucket                          =  l_bucket
  AND  oes.bucket_duration                   =  l_bucket_length
  ;


  CURSOR party_h_bal_stub_csr_gl IS
  SELECT SUM( oes.balance )
  FROM   oe_credit_summaries oes
     ,   hz_hierarchy_nodes hn
  WHERE  oes.balance_type  IN
         (b1, b2, b3, b4, b5, b6, b7, b8, b9, b10,
	  b11, b12, b13, b14, b15, b16, b17, b18, b21, b22)
  AND  hn.parent_id                  = p_party_id
  AND  hn.parent_object_type           = 'ORGANIZATION'
  and  hn.parent_table_name            = 'HZ_PARTIES'
  and  hn.child_object_type            = 'ORGANIZATION'
  and  hn.effective_start_date  <=  sysdate
  and  hn.effective_end_date    >= SYSDATE
  and  hn.hierarchy_type
                = OE_CREDIT_CHECK_UTIL.G_hierarchy_type
  AND  oes.party_id              =  hn.child_id
  AND  oes.currency_code         =  l_currency_code
  AND  oes.bucket                <  l_bucket
  AND  oes.bucket_duration         =  l_bucket_length
  ;

  ---added for the Returns project
  ---the same as above including Returns
  CURSOR party_h_bal_ret_stub_csr_gl IS
  SELECT SUM( oes.balance )
  FROM   oe_credit_summaries oes
     ,   hz_hierarchy_nodes hn
  WHERE  oes.balance_type  IN
         (b1, b2, b3, b4, b5, b6, b7, b8, b9, b10,
	  b11, b12, b13, b14, b15, b16, b17, b18, b21, b22,
          b23, b24, b25, b26, b27, b28, b29, b30, b31,
          b32, b33, b34, b35, b36)
  AND  hn.parent_id                  = p_party_id
  AND  hn.parent_object_type           = 'ORGANIZATION'
  and  hn.parent_table_name            = 'HZ_PARTIES'
  and  hn.child_object_type            = 'ORGANIZATION'
  and  hn.effective_start_date  <=  sysdate
  and  hn.effective_end_date    >= SYSDATE
  and  hn.hierarchy_type
                = OE_CREDIT_CHECK_UTIL.G_hierarchy_type
  AND  oes.party_id              =  hn.child_id
  AND  oes.currency_code         =  l_currency_code
  AND  oes.bucket                <  l_bucket
  AND  oes.bucket_duration         =  l_bucket_length
  ;


  CURSOR party_br_h_stub_csr_gl IS
  SELECT SUM( oes.balance )
  FROM   oe_credit_summaries oes
     ,   hz_hierarchy_nodes hn
  WHERE  oes.balance_type  IN
          (21,22)
  AND  hn.parent_id                  = p_party_id
  AND  hn.parent_object_type           = 'ORGANIZATION'
  and  hn.parent_table_name            = 'HZ_PARTIES'
  and  hn.child_object_type            = 'ORGANIZATION'
  and  hn.effective_start_date  <=  sysdate
  and  hn.effective_end_date    >= SYSDATE
  and  hn.hierarchy_type
                = OE_CREDIT_CHECK_UTIL.G_hierarchy_type
  AND  oes.party_id              =  hn.child_id
  AND  oes.currency_code         =  l_currency_code
  AND  oes.bucket                <  l_br_bucket
  AND  oes.bucket_duration         =  l_br_bucket_length
  ;

-------------------------------------------------------------


  CURSOR site_balance_all_curr_csr IS
  SELECT SUM( balance )
       , currency_code
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
	 (b1, b2, b3, b4, b5, b6, b7, b8, b9,
	  b10, b11, b12, b13, b14, b15, b16, b17, b18)
  AND  site_use_id      =  l_site_use_id
  AND  bucket                =  l_bucket
  AND bucket_duration         =  l_bucket_length
  GROUP BY  currency_code
  ;

  ---added for the Returns project
  ---the same as above including Returns

  CURSOR site_bal_all_curr_ret_csr IS
  SELECT SUM( balance )
    , currency_code
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
 	 (b1, b2, b3, b4, b5, b6, b7, b8, b9,
	  b10, b11, b12, b13, b14, b15, b16, b17, b18,
          b23, b24, b25, b26, b27, b28, b29, b30, b31,
          b32, b33, b34, b35, b36)
  AND  site_use_id           =  l_site_use_id
  AND  bucket                =  l_bucket
  AND  bucket_duration       =  l_bucket_length
  GROUP BY  currency_code
  ;


  CURSOR site_balance_all_curr_stub_csr IS
  SELECT SUM( balance )
       , currency_code
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
	 (b1, b2, b3, b4, b5, b6, b7, b8, b9,
	  b10, b11, b12, b13, b14, b15, b16, b17, b18)
  AND  site_use_id      =  l_site_use_id
  AND  bucket           <  l_bucket
  AND bucket_duration   =  l_bucket_length
  GROUP BY  currency_code
  ;

  ---added for the Returns project
  ---the same as above including Returns
  CURSOR site_bal_all_curr_stub_ret_csr IS
  SELECT SUM( balance )
       , currency_code
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
	 (b1, b2, b3, b4, b5, b6, b7, b8, b9,
	  b10, b11, b12, b13, b14, b15, b16, b17, b18,
          b23, b24, b25, b26, b27, b28, b29, b30, b31,
          b32, b33, b34, b35, b36)
  AND  site_use_id      =  l_site_use_id
  AND  bucket           <  l_bucket
  AND bucket_duration   =  l_bucket_length
  GROUP BY  currency_code
  ;

  CURSOR site_br_all_curr_stub_csr IS
  SELECT SUM( balance )
       , currency_code
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
          (21,22)
  AND  site_use_id      =  l_br_site_use_id
  AND  bucket           <  l_br_bucket
  AND bucket_duration   =  l_br_bucket_length
  GROUP BY  currency_code
  ;


  CURSOR customer_balance_all_curr_csr IS
  SELECT SUM( balance )
       , currency_code
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
         (b1, b2, b3, b4, b5, b6, b7, b8, b9,
	  b10, b11, b12, b13, b14, b15, b16, b17, b18, b21, b22 )
  AND  cust_account_id      =  p_customer_id
  AND  ((org_id             =  p_org_id)
         OR
        (org_id IS NULL AND p_org_id IS NULL))
  AND  bucket               =  l_bucket
  AND bucket_duration       =  l_bucket_length
  GROUP BY currency_code
  ;

  ---added for the Returns project
  ---the same as above including Returns
  CURSOR customer_bal_all_curr_ret_csr IS
  SELECT SUM( balance )
       , currency_code
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
         (b1, b2, b3, b4, b5, b6, b7, b8, b9,
	  b10, b11, b12, b13, b14, b15, b16, b17, b18, b21, b22,
          b23, b24, b25, b26, b27, b28, b29, b30, b31,
          b32, b33, b34, b35, b36)
  AND  cust_account_id      =  p_customer_id
  AND  ((org_id             =  p_org_id)
         OR
        (org_id IS NULL AND p_org_id IS NULL))
  AND  bucket               =  l_bucket
  AND bucket_duration       =  l_bucket_length
  GROUP BY currency_code
  ;

  CURSOR customer_all_curr_stub_csr IS
  SELECT SUM( balance )
       , currency_code
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
	 (b1, b2, b3, b4, b5, b6, b7, b8, b9,
	  b10, b11, b12, b13, b14, b15, b16, b17, b18, b21, b22)
  AND  cust_account_id      =  p_customer_id
  AND  ((org_id             =  p_org_id)
         OR
        (org_id IS NULL AND p_org_id IS NULL))
  AND  bucket               <  l_bucket
  AND bucket_duration       =  l_bucket_length
  GROUP BY currency_code
  ;

  ---added for the Returns project
  ---the same as above including Returns
  CURSOR customer_all_curr_stub_ret_csr IS
  SELECT SUM( balance )
       , currency_code
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
	 (b1, b2, b3, b4, b5, b6, b7, b8, b9,
	  b10, b11, b12, b13, b14, b15, b16, b17, b18, b21, b22,
          b23, b24, b25, b26, b27, b28, b29, b30, b31,
          b32, b33, b34, b35, b36)
  AND  cust_account_id      =  p_customer_id
  AND  ((org_id             =  p_org_id)
         OR
        (org_id IS NULL AND p_org_id IS NULL))
  AND  bucket               <  l_bucket
  AND bucket_duration       =  l_bucket_length
  GROUP BY currency_code
  ;

  CURSOR customer_br_all_curr_stub_csr IS
  SELECT SUM( balance )
       , currency_code
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
          (21,22)
  AND  cust_account_id      =  p_customer_id
  AND  ((org_id             =  p_org_id)
         OR
        (org_id IS NULL AND p_org_id IS NULL))
  AND  bucket               <  l_br_bucket
  AND bucket_duration       =  l_br_bucket_length
  GROUP BY currency_code
  ;


  CURSOR cust_all_curr_csr_global IS
  SELECT SUM( balance )
       , currency_code
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
	 (b1, b2, b3, b4, b5, b6, b7, b8, b9,
	  b10, b11, b12, b13, b14, b15, b16, b17, b18 , b21, b22)
  AND    cust_account_id     =  p_customer_id
  AND  bucket                =  l_bucket
  AND bucket_duration        =  l_bucket_length
  GROUP BY currency_code
  ;

  ---added for the Returns project
  ---the same as above including Returns
  CURSOR cust_all_curr_ret_csr_global IS
  SELECT SUM( balance )
       , currency_code
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
	 (b1, b2, b3, b4, b5, b6, b7, b8, b9,
	  b10, b11, b12, b13, b14, b15, b16, b17, b18 , b21, b22,
          b23, b24, b25, b26, b27, b28, b29, b30, b31,
          b32, b33, b34, b35, b36)
  AND    cust_account_id      =  p_customer_id
  AND  bucket                 =  l_bucket
  AND bucket_duration         =  l_bucket_length
  GROUP BY currency_code
  ;


  CURSOR cust_all_curr_stub_csr_global IS
  SELECT SUM( balance )
       , currency_code
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
	 (b1, b2, b3, b4, b5, b6, b7, b8, b9,
	  b10, b11, b12, b13, b14, b15, b16, b17, b18 , b21, b22)
  AND    cust_account_id      =  p_customer_id
  AND  bucket                 <  l_bucket
  AND bucket_duration         =  l_bucket_length
  GROUP BY currency_code
  ;

  ---added for the Returns project
  ---the same as above including Returns
  CURSOR cust_all_curr_stub_ret_csr_gl IS
  SELECT SUM( balance )
       , currency_code
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
	 (b1, b2, b3, b4, b5, b6, b7, b8, b9,
	  b10, b11, b12, b13, b14, b15, b16, b17, b18 , b21, b22,
          b23, b24, b25, b26, b27, b28, b29, b30, b31,
          b32, b33, b34, b35, b36)
  AND    cust_account_id      =  p_customer_id
  AND  bucket                 <  l_bucket
  AND bucket_duration         =  l_bucket_length
  GROUP BY currency_code
  ;

  CURSOR cust_br_all_curr_stub_csr_gl IS
  SELECT SUM( balance )
       , currency_code
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
          (21,22)
  AND    cust_account_id      =  p_customer_id
  AND  bucket                 <  l_br_bucket
  AND bucket_duration         =  l_br_bucket_length
  GROUP BY currency_code
  ;


----------------------------------------------------------

  CURSOR party_all_curr_csr_global IS
  SELECT SUM( balance )
       , currency_code
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
	 (b1, b2, b3, b4, b5, b6, b7, b8, b9,
	  b10, b11, b12, b13, b14, b15, b16, b17, b18 , b21, b22)
  AND  party_id              = p_party_id
  AND  bucket                =  l_bucket
  AND bucket_duration        =  l_bucket_length
  GROUP BY currency_code
  ;

  ---added for the Returns project
  ---the same as above including Returns
  CURSOR party_all_curr_ret_csr_gl IS
  SELECT SUM( balance )
       , currency_code
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
	 (b1, b2, b3, b4, b5, b6, b7, b8, b9,
	  b10, b11, b12, b13, b14, b15, b16, b17, b18 , b21, b22,
          b23, b24, b25, b26, b27, b28, b29, b30, b31,
          b32, b33, b34, b35, b36)
  AND  party_id              = p_party_id
  AND  bucket                =  l_bucket
  AND bucket_duration        =  l_bucket_length
  GROUP BY currency_code
  ;

  CURSOR party_all_curr_stub_csr_global IS
  SELECT SUM( balance )
       , currency_code
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
	 (b1, b2, b3, b4, b5, b6, b7, b8, b9,
	  b10, b11, b12, b13, b14, b15, b16, b17, b18 , b21, b22)
  AND  party_id              = p_party_id
  AND  bucket                <  l_bucket
  AND bucket_duration        =  l_bucket_length
  GROUP BY currency_code
  ;

  ---added for the Returns project
  ---the same as above including Returns
  CURSOR party_all_curr_stub_ret_csr_gl IS
  SELECT SUM( balance )
       , currency_code
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
	 (b1, b2, b3, b4, b5, b6, b7, b8, b9,
	  b10, b11, b12, b13, b14, b15, b16, b17, b18 , b21, b22,
          b23, b24, b25, b26, b27, b28, b29, b30, b31,
          b32, b33, b34, b35, b36)
  AND  party_id              = p_party_id
  AND  bucket                <  l_bucket
  AND bucket_duration        =  l_bucket_length
  GROUP BY currency_code
  ;

  CURSOR party_br_all_curr_stub_csr_gl IS
  SELECT SUM( balance )
       , currency_code
  FROM   oe_credit_summaries
  WHERE  balance_type  IN
          (21,22)
  AND  party_id              = p_party_id
  AND  bucket                <  l_br_bucket
  AND bucket_duration        =  l_br_bucket_length
  GROUP BY currency_code
  ;


---------------------------------------------------

  CURSOR party_h_all_curr_csr_global IS
  SELECT SUM( oes.balance )
       , oes.currency_code
  FROM   oe_credit_summaries oes
     ,   hz_hierarchy_nodes hn
  WHERE  oes.balance_type  IN
	 (b1, b2, b3, b4, b5, b6, b7, b8, b9,
	  b10, b11, b12, b13, b14, b15, b16, b17, b18 , b21, b22)
  AND  hn.parent_id                  = p_party_id
  AND  hn.parent_object_type           = 'ORGANIZATION'
  and  hn.parent_table_name            = 'HZ_PARTIES'
  and  hn.child_object_type            = 'ORGANIZATION'
  and  hn.effective_start_date  <=  sysdate
  and  hn.effective_end_date    >= SYSDATE
  and  hn.hierarchy_type
                = OE_CREDIT_CHECK_UTIL.G_hierarchy_type
  AND  oes.party_id              =  hn.child_id
  AND  oes.bucket                =  l_bucket
  AND  oes.bucket_duration         =  l_bucket_length
  GROUP BY oes.currency_code
  ;

  ---added for the Returns project
  ---the same as above including Returns
  CURSOR party_h_all_curr_ret_csr_gl IS
  SELECT SUM( oes.balance )
       , oes.currency_code
  FROM   oe_credit_summaries oes
     ,   hz_hierarchy_nodes hn
  WHERE  oes.balance_type  IN
	 (b1, b2, b3, b4, b5, b6, b7, b8, b9,
	  b10, b11, b12, b13, b14, b15, b16, b17, b18 , b21, b22,
          b23, b24, b25, b26, b27, b28, b29, b30, b31,
          b32, b33, b34, b35, b36)
  AND  hn.parent_id                  = p_party_id
  AND  hn.parent_object_type           = 'ORGANIZATION'
  and  hn.parent_table_name            = 'HZ_PARTIES'
  and  hn.child_object_type            = 'ORGANIZATION'
  and  hn.effective_start_date  <=  sysdate
  and  hn.effective_end_date    >= SYSDATE
  and  hn.hierarchy_type
                = OE_CREDIT_CHECK_UTIL.G_hierarchy_type
  AND  oes.party_id              =  hn.child_id
  AND  oes.bucket                =  l_bucket
  AND  oes.bucket_duration         =  l_bucket_length
  GROUP BY oes.currency_code
  ;

  CURSOR party_h_all_curr_stub_csr_gl IS
  SELECT SUM( oes.balance )
       , oes.currency_code
    FROM   oe_credit_summaries oes
     ,   hz_hierarchy_nodes hn
  WHERE  oes.balance_type  IN
	 (b1, b2, b3, b4, b5, b6, b7, b8, b9,
	  b10, b11, b12, b13, b14, b15, b16, b17, b18 , b21, b22)
  AND  hn.parent_id                  = p_party_id
  AND  hn.parent_object_type           = 'ORGANIZATION'
  and  hn.parent_table_name            = 'HZ_PARTIES'
  and  hn.child_object_type            = 'ORGANIZATION'
  and  hn.effective_start_date  <=  sysdate
  and  hn.effective_end_date    >= SYSDATE
  and  hn.hierarchy_type
                = OE_CREDIT_CHECK_UTIL.G_hierarchy_type
  AND  oes.party_id              = hn.child_id
  AND  oes.bucket                <  l_bucket
  AND  oes.bucket_duration         =  l_bucket_length
  GROUP BY oes.currency_code
  ;

  ---added for the Returns project
  ---the same as above including Returns
  CURSOR p_h_all_curr_stub_ret_csr_gl IS
  SELECT SUM( oes.balance )
       , oes.currency_code
    FROM   oe_credit_summaries oes
     ,   hz_hierarchy_nodes hn
  WHERE  oes.balance_type  IN
	 (b1, b2, b3, b4, b5, b6, b7, b8, b9,
	  b10, b11, b12, b13, b14, b15, b16, b17, b18 , b21, b22,
          b23, b24, b25, b26, b27, b28, b29, b30, b31,
          b32, b33, b34, b35, b36)
  AND  hn.parent_id                  = p_party_id
  AND  hn.parent_object_type           = 'ORGANIZATION'
  and  hn.parent_table_name            = 'HZ_PARTIES'
  and  hn.child_object_type            = 'ORGANIZATION'
  and  hn.effective_start_date  <=  sysdate
  and  hn.effective_end_date    >= SYSDATE
  and  hn.hierarchy_type
                = OE_CREDIT_CHECK_UTIL.G_hierarchy_type
  AND  oes.party_id              = hn.child_id
  AND  oes.bucket                <  l_bucket
  AND  oes.bucket_duration         =  l_bucket_length
  GROUP BY oes.currency_code
  ;

  CURSOR party_br_h_all_curr_stub_gl IS
  SELECT SUM( oes.balance )
       , oes.currency_code
    FROM   oe_credit_summaries oes
     ,   hz_hierarchy_nodes hn
  WHERE  oes.balance_type  IN
          (21,22)
  AND  hn.parent_id                  = p_party_id
  AND  hn.parent_object_type           = 'ORGANIZATION'
  and  hn.parent_table_name            = 'HZ_PARTIES'
  and  hn.child_object_type            = 'ORGANIZATION'
  and  hn.effective_start_date  <=  sysdate
  and  hn.effective_end_date    >= SYSDATE
  and  hn.hierarchy_type
                = OE_CREDIT_CHECK_UTIL.G_hierarchy_type
  AND  oes.party_id              = hn.child_id
  AND  oes.bucket                <  l_br_bucket
  AND  oes.bucket_duration         =  l_br_bucket_length
  GROUP BY oes.currency_code
  ;

BEGIN
  --  We are determining now which summary cursor to open depending on
  -- whether the exposure is a site or customer level, and
  -- whether it is for all currencies or a list of currencies.
  --  The choice between order or line bill-to-site has already been
  -- made above by selecting the right balance types.

  -- for each of the for cases, there are nested loops.
  -- The only difference between the two site and customer level cases
  -- are the cursor names.

  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'Into retrieve_exposure ');
    oe_debug_pub.add( '+++++++++++++++++++++++++++++++++++');
    oe_debug_pub.add( 'p_site_use_id          ==> '|| p_site_use_id );
    oe_debug_pub.add( 'p_customer_id          ==> '|| p_customer_id );
    oe_debug_pub.add( 'p_party_id             ==> ' || p_party_id );
    oe_debug_pub.add( 'p_org_id               ==> '|| p_org_id);
    oe_debug_pub.add( 'p_include_all_flag     ==> '|| p_include_all_flag );
    oe_debug_pub.add( 'p_main_bucket          ==> '|| p_main_bucket );
    oe_debug_pub.add( 'p_global_exposure_flag ==> '|| p_global_exposure_flag );
    oe_debug_pub.add( 'p_limit_curr_code      ==> '|| p_limit_curr_code );
    oe_debug_pub.add( 'include_returns_flag   ==> '|| p_credit_check_rule_rec.include_returns_flag);
    oe_debug_pub.add( '+++++++++++++++++++++++++++++++++++');
  END IF;

  l_total := 0;
  l_br_site_use_id := NULL ;

  IF  p_credit_check_rule_rec.open_ar_balance_flag = 'Y'
  THEN
   l_br_bucket_length  := POWER( 2, G_MAX_BUCKET_LEVEL );
   l_br_bucket         := open_date( p_days  => NULL);

  END IF;

  IF  p_site_use_id  IS NOT NULL
  THEN
   ----------------------------------------------------------------
   ---------------------- Site Level Exposure ----------------------

    IF G_debug_flag = 'Y'
    THEN
      oe_debug_pub.add( 'exposure at site level ',1);
    END IF;

    l_site_use_id := p_site_use_id;

    IF G_debug_flag = 'Y'
    THEN
      oe_debug_pub.add( 'l_site_use_id => '|| l_site_use_id );
    END IF;

    IF  NVL(p_include_all_flag,'N')  =  'N'
    THEN
     IF G_debug_flag = 'Y'
     THEN
       oe_debug_pub.add('site - NOT all currencies');
     END IF;
      -- exposure is at site level and for a list of currencies

      -- for each currency in the list, loop
      i  := p_usage_curr_tbl.FIRST;

      WHILE  i  IS NOT NULL
      LOOP

        l_currency_code  := p_usage_curr_tbl(i).usage_curr_code;

	l_bucket         :=  p_main_bucket;
	l_bucket_length  :=  G_MAX_BUCKET_LENGTH;


        ----change for the Return project
        ---- if Returns are included, the cursor site_balance_stub_ret_csr
        ---- is used, if Returns are not included, then the old logic and
        ---- site_balance_stub_csr is used.

        IF NVL(p_credit_check_rule_rec.include_returns_flag,'N') = 'N'
        THEN
          OPEN site_balance_stub_csr;
 	  FETCH site_balance_stub_csr
          INTO l_balance;
        ELSE
          IF G_debug_flag = 'Y'
          THEN
            oe_debug_pub.add('OPEN site_balance_stub_ret_csr');
          END IF;

          OPEN site_balance_stub_ret_csr;
 	  FETCH site_balance_stub_ret_csr
          INTO l_balance;

          IF G_debug_flag = 'Y'
          THEN
            oe_debug_pub.add('l_balance='||TO_CHAR(l_balance));
          END IF;
        END IF;

        IF p_credit_check_rule_rec.open_ar_balance_flag = 'Y'
        THEN
           l_br_site_use_id :=
           oe_credit_check_util.get_drawee_site_use_id ( p_site_use_id);
        END IF;

        IF b8 = G_INVOICES
        THEN
          IF l_br_site_use_id IS NOT NULL
          THEN
            OPEN   site_br_stub_csr;
            FETCH  site_br_stub_csr
            INTO   l_br_balance;
            CLOSE site_br_stub_csr ;
          END IF;
        END IF;

        IF G_debug_flag = 'Y'
        THEN
	  oe_debug_pub.add
	    ( 'stub cursor at ' || l_currency_code || ' currency with balance '
	      || l_balance || ' and bucket/length ' || l_bucket
              || '/' || l_bucket_length, 2 );

	  oe_debug_pub.add
	    ( 'stub cursor at ' || l_currency_code
                 || ' currency with BR balance '
	      || l_br_balance || ' and bucket/length ' || l_bucket
              || '/' || l_bucket_length, 2 );

         END IF;

	  l_total  := l_total +  convert_currency_amount
	  	      ( p_amount                  =>
                              l_balance + NVL(l_br_balance,0)
		      , p_transactional_currency  => l_currency_code
		      , p_limit_currency          => p_limit_curr_code
		      );

        ----change for the Return project
        ---- closing appropriate cursor: if Returns are included,
        ---- the cursor site_balance_stub_ret_csr, if Returns are not included,
        ---- then the cursor site_balance_stub_csr is used.

        IF NVL(p_credit_check_rule_rec.include_returns_flag,'N') = 'N'
        THEN
          CLOSE site_balance_stub_csr;
        ELSE
          CLOSE site_balance_stub_ret_csr;
        END IF;

        -----------------------------
        -- for fraction of Main Bucket

        j  :=  p_binary_tbl.FIRST;
	WHILE j IS NOT NULL LOOP
 	  l_bucket         :=  p_binary_tbl(j).bucket;
	  l_bucket_length  :=  p_binary_tbl(j).bucket_length;

          ----change for the Return project
          IF NVL(p_credit_check_rule_rec.include_returns_flag,'N') = 'N'
          THEN
   	    OPEN  site_balance_csr;
	    FETCH  site_balance_csr
            INTO  l_balance;
          ELSE
            IF G_debug_flag = 'Y'
            THEN
              oe_debug_pub.add('OPEN site_balance_ret_csr');
            END IF;

            OPEN  site_balance_ret_csr;
	    FETCH  site_balance_ret_csr
            INTO  l_balance;
          END IF;


          IF G_debug_flag = 'Y'
          THEN
	    oe_debug_pub.add
	    ( 'cursor at ' || l_currency_code || ' currency with balance '
	      || l_balance || ' and bucket/length ' || l_bucket || '/'
              || l_bucket_length, 2 );
          END IF;

	  BEGIN
	    l_term :=
	      OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
	      ( p_amount                  => l_balance
	      , p_transactional_currency  => l_currency_code
	      , p_limit_currency          => p_limit_curr_code
              , p_functional_currency     => g_functional_currency
	      , p_conversion_date         => SYSDATE
	      , p_conversion_type         => g_conversion_type
	      );
	    l_total := l_total + NVL( l_term, 0 );

	  EXCEPTION
	    WHEN  GL_CURRENCY_API.NO_RATE  OR
                  GL_CURRENCY_API.INVALID_CURRENCY THEN
 	      add_error_currency( x_error_curr_tbl, l_currency_code );

              IF G_debug_flag = 'Y'
              THEN
	        oe_debug_pub.add( 'conversion exception for '
                || l_currency_code, 1 );
              END IF;
	  END;
          ----change for the Return project
          IF NVL(p_credit_check_rule_rec.include_returns_flag,'N') = 'N'
          THEN
	    CLOSE site_balance_csr;
          ELSE
            CLOSE site_balance_ret_csr;
          END IF;

	  j  :=  p_binary_tbl.NEXT(j);
        END LOOP;
        i := p_usage_curr_tbl.NEXT(i);
      END LOOP;

    ELSE
      -- exposure is at site level and for all currencies
     IF G_debug_flag = 'Y'
     THEN
      oe_debug_pub.add( 'SITE, ALL currencies ');
     END IF;
      i := 0;

      --------------------------
      -- for left of Main Bucket
      l_bucket         :=  p_main_bucket;
      l_bucket_length  :=  G_MAX_BUCKET_LENGTH;

      ----change for the Return project
      IF NVL(p_credit_check_rule_rec.include_returns_flag,'N') = 'N'
      THEN
        OPEN site_balance_all_curr_stub_csr;
        FETCH site_balance_all_curr_stub_csr
        INTO l_balance, l_currency_code;

        -- For each currency in the cursor
      WHILE NOT site_balance_all_curr_stub_csr%NOTFOUND
      LOOP
        IF G_debug_flag = 'Y'
        THEN
	  oe_debug_pub.add
   ( '(all) stub cursor at ' || l_currency_code || ' currency with balance '
	      || l_balance || ' and bucket/length '
            || l_bucket || '/' || l_bucket_length, 2 );
        END IF;


          IF ( NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                     l_currency_code ,1,1),0) = 0 )
	    OR
	     ((NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                     l_currency_code ,1,1),0) > 0 )
	      AND ( l_currency_code = p_limit_curr_code )
	     )
	  THEN
	    BEGIN
 	      l_term :=
	        OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
	        ( p_amount                  => l_balance
                , p_transactional_currency  => l_currency_code
	        , p_limit_currency          => p_limit_curr_code
	        , p_functional_currency     => g_functional_currency
	        , p_conversion_date         => SYSDATE
	        , p_conversion_type         => g_conversion_type
	        );
	      l_total  := l_total  +  NVL( l_term, 0 );

	    EXCEPTION
	      WHEN  GL_CURRENCY_API.NO_RATE  OR
                    GL_CURRENCY_API.INVALID_CURRENCY THEN
	        oe_debug_pub.add( 'conversion exception for '
                   || l_currency_code, 1 );
	        add_error_currency( x_error_curr_tbl, l_currency_code );
	    END;
          ELSE
	    oe_debug_pub.add( 'Currency excluded from usages '
              || l_currency_code);
	  END IF;  -- exclude curr list

	  FETCH  site_balance_all_curr_stub_csr
          INTO  l_balance, l_currency_code;

	  i := i + 1;

      END LOOP;

     CLOSE site_balance_all_curr_stub_csr;


     ----change for the Return project
     --- the code is the same as above but using cursor
     --- site_bal_all_curr_stub_ret_csr instead site_balance_all_curr_stub_csr

     ELSE
       IF G_debug_flag = 'Y'
       THEN
         oe_debug_pub.add('OPEN site_bal_all_curr_stub_ret_csr');
       END IF;

       OPEN site_bal_all_curr_stub_ret_csr;
       FETCH site_bal_all_curr_stub_ret_csr
       INTO l_balance, l_currency_code;

       -- For each currency in the cursor
      WHILE NOT site_bal_all_curr_stub_ret_csr%NOTFOUND
      LOOP
        IF G_debug_flag = 'Y'
        THEN
	  oe_debug_pub.add
   ( '(all) stub cursor at ' || l_currency_code || ' currency with balance '
	      || l_balance || ' and bucket/length '
            || l_bucket || '/' || l_bucket_length, 2 );
        END IF;


          IF ( NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                     l_currency_code ,1,1),0) = 0 )
	    OR
	     ((NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                     l_currency_code ,1,1),0) > 0 )
	      AND ( l_currency_code = p_limit_curr_code )
	     )
	  THEN
	    BEGIN
 	      l_term :=
	        OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
	        ( p_amount                  => l_balance
                , p_transactional_currency  => l_currency_code
	        , p_limit_currency          => p_limit_curr_code
	        , p_functional_currency     => g_functional_currency
	        , p_conversion_date         => SYSDATE
	        , p_conversion_type         => g_conversion_type
	        );
	      l_total  := l_total  +  NVL( l_term, 0 );

	    EXCEPTION
	      WHEN  GL_CURRENCY_API.NO_RATE  OR
                    GL_CURRENCY_API.INVALID_CURRENCY THEN
	        oe_debug_pub.add( 'conversion exception for '
                   || l_currency_code, 1 );
	        add_error_currency( x_error_curr_tbl, l_currency_code );
	    END;
          ELSE
	    oe_debug_pub.add( 'Currency excluded from usages '
              || l_currency_code);
	  END IF;  -- exclude curr list

	  FETCH  site_bal_all_curr_stub_ret_csr
          INTO  l_balance, l_currency_code;

	  i := i + 1;

        END LOOP;

       CLOSE site_bal_all_curr_stub_ret_csr;

     END IF; ----end of checking for include returns

      ---------------------start BR -------------------
     IF p_credit_check_rule_rec.open_ar_balance_flag = 'Y'
     THEN
        l_br_site_use_id :=
           oe_credit_check_util.get_drawee_site_use_id ( p_site_use_id);
     END IF;

     IF l_br_site_use_id IS NOT NULL
     AND b8 = G_INVOICES
     THEN
         i := 0;

      --------------------------
      -- for left of Main Bucket
         l_bucket         :=  p_main_bucket;
         l_bucket_length  :=  G_MAX_BUCKET_LENGTH;

         OPEN  site_br_all_curr_stub_csr;
         FETCH site_br_all_curr_stub_csr
         INTO l_br_balance, l_currency_code;

        -- For each currency in the cursor
        WHILE NOT site_br_all_curr_stub_csr%NOTFOUND
        LOOP
          IF G_debug_flag = 'Y'
          THEN
	    oe_debug_pub.add
              ( '(all) stub cursor at ' || l_currency_code
                || ' currency with BR  balance '
	      || l_br_balance || ' and bucket/length '
            || l_bucket || '/' || l_bucket_length, 2 );
          END IF;

            IF ( NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                     l_currency_code ,1,1),0) = 0 )
	    OR
	     ((NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                     l_currency_code ,1,1),0) > 0 )
	      AND ( l_currency_code = p_limit_curr_code )
	     )
	    THEN
	      BEGIN
 	      l_term :=
	        OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
	        ( p_amount                  => l_br_balance
                , p_transactional_currency  => l_currency_code
	        , p_limit_currency          => p_limit_curr_code
	        , p_functional_currency     => g_functional_currency
	        , p_conversion_date         => SYSDATE
	        , p_conversion_type         => g_conversion_type
	        );
	        l_total  := l_total  +  NVL( l_term, 0 );

	      EXCEPTION
	      WHEN  GL_CURRENCY_API.NO_RATE  OR
                    GL_CURRENCY_API.INVALID_CURRENCY THEN
	        oe_debug_pub.add( 'conversion exception for '
                   || l_currency_code, 1 );
	        add_error_currency( x_error_curr_tbl, l_currency_code );
	    END;
          ELSE
	    oe_debug_pub.add( 'Currency excluded from usages '
              || l_currency_code);
	  END IF;  -- exclude curr list

	  FETCH  site_br_all_curr_stub_csr
          INTO  l_balance, l_currency_code;

	  i := i + 1;
        END LOOP;

       CLOSE site_br_all_curr_stub_csr ;
     END IF;
---------------------------- end BR ------------------
      -- for fraction of Main Bucket

      j  :=  p_binary_tbl.FIRST;
      WHILE j IS NOT NULL LOOP
        l_bucket         :=  p_binary_tbl(j).bucket;
        l_bucket_length  :=  p_binary_tbl(j).bucket_length;

        ----change for the Return project
        IF NVL(p_credit_check_rule_rec.include_returns_flag,'N') = 'N'
        THEN

          -- this cursor deals with one site and all currencies
          OPEN site_balance_all_curr_csr;
          FETCH site_balance_all_curr_csr
          INTO l_balance, l_currency_code;

          -- For each currency that exists, the cursor returns a row.
          -- Convert the balance and sum up to total exposure

          WHILE NOT site_balance_all_curr_csr%NOTFOUND
          LOOP
           IF G_debug_flag = 'Y'
           THEN
            oe_debug_pub.add
              ( 'cursor at ' || l_currency_code || ' currency with balance '
	        || l_balance || ' and bucket/length ' || l_bucket
                   || '/' || l_bucket_length, 2 );
            END IF;

            IF ( NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                     l_currency_code ,1,1),0) = 0 )
        	    OR
	       ((NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                    l_currency_code ,1,1),0) > 0 )
	        AND ( l_currency_code = p_limit_curr_code )
        	     )
	    THEN
              BEGIN
	        l_term :=
	          OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
	          ( p_amount                  => l_balance
                  , p_transactional_currency  => l_currency_code
	          , p_limit_currency          => p_limit_curr_code
	          , p_functional_currency     => g_functional_currency
	          , p_conversion_date         => SYSDATE
	          , p_conversion_type         => g_conversion_type
	          );
	        l_total := l_total + NVL( l_term, 0 );

              EXCEPTION
                WHEN  GL_CURRENCY_API.NO_RATE  OR
                      GL_CURRENCY_API.INVALID_CURRENCY THEN
                oe_debug_pub.add( 'conversion exception for '
                  || l_currency_code, 1 );
                add_error_currency( x_error_curr_tbl, l_currency_code );
	      END;
            ELSE
              oe_debug_pub.add( 'Currency excluded from usages ');
	    END IF;  -- exclude curr list

            FETCH  site_balance_all_curr_csr
            INTO  l_balance, l_currency_code;
            i := i + 1;
          END LOOP;
          CLOSE site_balance_all_curr_csr;

        -----if returns are included use appropriate cursor
        ----- the rest code is the same as above
        ELSE
          -- this cursor deals with one site and all currencies
          OPEN site_bal_all_curr_ret_csr;
          FETCH site_bal_all_curr_ret_csr
          INTO l_balance, l_currency_code;

          -- For each currency that exists, the cursor returns a row.
          -- Convert the balance and sum up to total exposure

          WHILE NOT site_bal_all_curr_ret_csr%NOTFOUND
          LOOP
           IF G_debug_flag = 'Y'
           THEN
            oe_debug_pub.add
              ( 'cursor at ' || l_currency_code || ' currency with balance '
	        || l_balance || ' and bucket/length ' || l_bucket
                   || '/' || l_bucket_length, 2 );
            END IF;

            IF ( NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                     l_currency_code ,1,1),0) = 0 )
        	    OR
	       ((NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                    l_currency_code ,1,1),0) > 0 )
	        AND ( l_currency_code = p_limit_curr_code )
        	     )
	    THEN
              BEGIN
	        l_term :=
	          OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
	          ( p_amount                  => l_balance
                  , p_transactional_currency  => l_currency_code
	          , p_limit_currency          => p_limit_curr_code
	          , p_functional_currency     => g_functional_currency
	          , p_conversion_date         => SYSDATE
	          , p_conversion_type         => g_conversion_type
	          );
	        l_total := l_total + NVL( l_term, 0 );

              EXCEPTION
                WHEN  GL_CURRENCY_API.NO_RATE  OR
                      GL_CURRENCY_API.INVALID_CURRENCY THEN
                oe_debug_pub.add( 'conversion exception for '
                  || l_currency_code, 1 );
                add_error_currency( x_error_curr_tbl, l_currency_code );
	      END;
            ELSE
              oe_debug_pub.add( 'Currency excluded from usages ');
	    END IF;  -- exclude curr list

            FETCH  site_bal_all_curr_ret_csr
            INTO  l_balance, l_currency_code;
            i := i + 1;
          END LOOP;
          CLOSE site_bal_all_curr_ret_csr;

        END IF; ---end of checking for include returns
        j  :=  p_binary_tbl.NEXT(j);
      END LOOP;
    END IF;  -- site level currency - all/single

----------------- End site level -----------------------------------
--------------------------------------------------------------------------

------------------------- Start customer level --------------------
  ELSIF p_customer_id IS NOT NULL
  THEN
   IF G_debug_flag = 'Y'
   THEN
     oe_debug_pub.add( 'exposure at customer level', 1 );
   END IF;

    IF  NVL(p_include_all_flag,'N')  =  'N'
    THEN
      -- exposure is at customer level and for a list of currencies
      -- for each currency in the list

      IF G_debug_flag = 'Y'
      THEN
        oe_debug_pub.add( 'NOT ALL currencies ');
      END IF;

      i  := p_usage_curr_tbl.FIRST;
      WHILE  i  IS NOT NULL
      LOOP
        l_currency_code := p_usage_curr_tbl(i).usage_curr_code;
        --------------------------
        -- for left of Main Bucket
	l_bucket         :=  p_main_bucket;
	l_bucket_length  :=  G_MAX_BUCKET_LENGTH;

        IF p_global_exposure_flag = 'Y'
        THEN
          IF G_debug_flag = 'Y'
          THEN
            oe_debug_pub.add( ' Into CUST global ');
          END IF;

          ----change for the Return project
          IF NVL(p_credit_check_rule_rec.include_returns_flag,'N') = 'N'
          THEN
	    OPEN cust_balance_stub_csr_global;
	    FETCH cust_balance_stub_csr_global
            INTO l_balance;
          ELSE
            OPEN cust_bal_stub_ret_csr_global;
	    FETCH cust_bal_stub_ret_csr_global
            INTO l_balance;
          END IF;

          IF p_credit_check_rule_rec.open_ar_days IS NOT NULL
             AND p_credit_check_rule_rec.open_ar_balance_flag = 'Y'
             AND b8 = G_INVOICES
          THEN
           OPEN  cust_br_stub_csr_global ;
           FETCH cust_br_stub_csr_global
           INTO  l_br_balance ;
           CLOSE cust_br_stub_csr_global ;
          END IF;

           IF G_debug_flag = 'Y'
           THEN
	    oe_debug_pub.add
	      ( 'global stub cursor at ' || l_currency_code
	        || ' currency with balance ' || l_balance, 2 );
	    oe_debug_pub.add
	      ( 'global stub cursor at ' || l_currency_code
	        || ' currency with BR balance ' || l_br_balance, 2 );
          END IF;
            BEGIN
	      l_term :=
	        OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
	        ( p_amount                  => l_balance +
                             NVL(l_br_balance,0)
	        , p_transactional_currency  => l_currency_code
	        , p_limit_currency          => p_limit_curr_code
	        , p_functional_currency     => g_functional_currency
	        , p_conversion_date         => SYSDATE
	        , p_conversion_type         => g_conversion_type
	        );
  	      l_total := l_total + NVL( l_term, 0 );

       	    EXCEPTION
	      WHEN  GL_CURRENCY_API.NO_RATE  OR
                    GL_CURRENCY_API.INVALID_CURRENCY THEN
	        oe_debug_pub.add( 'conversion exception for '
                 || l_currency_code, 1 );
	        add_error_currency( x_error_curr_tbl, l_currency_code );
             END;
             ----change for the Return project
             IF NVL(p_credit_check_rule_rec.include_returns_flag,'N') = 'N'
             THEN
	       CLOSE cust_balance_stub_csr_global;
             ELSE
               CLOSE cust_bal_stub_ret_csr_global;
             END IF;

	    -----------------------------
	    -- for fraction of Main Bucket

	   j  :=  p_binary_tbl.FIRST;
	  WHILE  j  IS NOT NULL
          LOOP
	    l_bucket         :=  p_binary_tbl(j).bucket;
	    l_bucket_length  :=  p_binary_tbl(j).bucket_length;

            ----change for the Return project
            IF NVL(p_credit_check_rule_rec.include_returns_flag,'N') = 'N'
            THEN
	      OPEN cust_balance_csr_global;
	      FETCH cust_balance_csr_global
              INTO l_balance;
            ELSE
              OPEN cust_balance_ret_csr_global;
	      FETCH cust_balance_ret_csr_global
              INTO l_balance;
            END IF;

            IF G_debug_flag = 'Y'
            THEN
	      oe_debug_pub.add
	      ( 'cust global cursor at ' || l_currency_code
	       || ' currency with balance ' || l_balance, 2 );
            END IF;
	    BEGIN
	      l_term :=
	        OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
	        ( p_amount                  => l_balance
	        , p_transactional_currency  => l_currency_code
	        , p_limit_currency          => p_limit_curr_code
		, p_functional_currency     => g_functional_currency
		, p_conversion_date         => SYSDATE
		, p_conversion_type         => g_conversion_type
		);
	      l_total := l_total + NVL( l_term, 0 );

	     EXCEPTION
	      WHEN  GL_CURRENCY_API.NO_RATE  OR
                    GL_CURRENCY_API.INVALID_CURRENCY THEN
	        oe_debug_pub.add( 'conversion exception for '
                    || l_currency_code, 1 );
	        add_error_currency( x_error_curr_tbl, l_currency_code );
	      END;

            ----change for the Return project
            IF NVL(p_credit_check_rule_rec.include_returns_flag,'N') = 'N'
            THEN
              CLOSE cust_balance_csr_global;
            ELSE
              CLOSE cust_balance_ret_csr_global;
            END IF;

            j  :=  p_binary_tbl.NEXT(j);
	   END LOOP;

         ELSE  -- not global cck
          IF G_debug_flag = 'Y'
          THEN
            oe_debug_pub.add( 'Into cust NOT global ');
          END IF;

          ----change for the Return project
          IF NVL(p_credit_check_rule_rec.include_returns_flag,'N') = 'N'
          THEN

            OPEN customer_balance_stub_csr;
	    FETCH customer_balance_stub_csr
            INTO l_balance;
          ELSE
            OPEN customer_balance_stub_ret_csr;
	    FETCH customer_balance_stub_ret_csr
            INTO l_balance;
          END IF;

          IF p_credit_check_rule_rec.open_ar_days IS NOT NULL
            AND p_credit_check_rule_rec.open_ar_balance_flag = 'Y'
            AND b8 = G_INVOICES
          THEN
           OPEN customer_br_stub_csr ;
           FETCH customer_br_stub_csr
           INTO l_br_balance ;
           CLOSE customer_br_stub_csr ;
          END IF;

          IF G_debug_flag = 'Y'
          THEN
	    oe_debug_pub.add
	      ( 'cust stub cursor at ' || l_currency_code
	       || ' currency with balance ' || l_balance, 2 );
	    oe_debug_pub.add
	      ( 'cust stub cursor at ' || l_currency_code
	       || ' currency with BR balance ' || l_br_balance, 2 );
          END IF;

	    BEGIN
	      l_term :=
	        OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
	        ( p_amount                  => l_balance +
                             NVL(l_br_balance,0)
	        , p_transactional_currency  => l_currency_code
	        , p_limit_currency          => p_limit_curr_code
	        , p_functional_currency     => g_functional_currency
	        , p_conversion_date         => SYSDATE
	        , p_conversion_type         => g_conversion_type
	        );
	      l_total := l_total + NVL( l_term, 0 );
	      EXCEPTION
	      WHEN  GL_CURRENCY_API.NO_RATE  OR
                     GL_CURRENCY_API.INVALID_CURRENCY THEN
	        oe_debug_pub.add( 'conversion exception for '
                  || l_currency_code, 1 );
		add_error_currency( x_error_curr_tbl, l_currency_code );
	     END;

             ----change for the Return project
             IF NVL(p_credit_check_rule_rec.include_returns_flag,'N') = 'N'
             THEN
               CLOSE customer_balance_stub_csr ;
             ELSE
               CLOSE customer_balance_stub_ret_csr;
             END IF;

	  -----------------------------
	  -- for fraction of Main Bucket

	    j  :=  p_binary_tbl.FIRST;
	    WHILE  j  IS NOT NULL
            LOOP
	     l_bucket         :=  p_binary_tbl(j).bucket;
	     l_bucket_length  :=  p_binary_tbl(j).bucket_length;

              ----change for the Return project
              IF NVL(p_credit_check_rule_rec.include_returns_flag,'N') = 'N'
              THEN
	        OPEN customer_balance_csr;
	        FETCH customer_balance_csr
                INTO l_balance;
              ELSE
                OPEN customer_balance_ret_csr;
	        FETCH customer_balance_ret_csr
                INTO l_balance;
              END IF;

              IF G_debug_flag = 'Y'
              THEN
	        oe_debug_pub.add
	        ( 'cust cursor at ' || l_currency_code
	       || ' currency with balance ' || l_balance, 2 );
              END IF;

	      BEGIN
              l_term :=
	        OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
	        ( p_amount                  => l_balance
	        , p_transactional_currency  => l_currency_code
	        , p_limit_currency          => p_limit_curr_code
                , p_functional_currency     => g_functional_currency
	        , p_conversion_date         => SYSDATE
	        , p_conversion_type         => g_conversion_type
	        );
	      l_total := l_total + NVL( l_term, 0 );

	      EXCEPTION
	        WHEN  GL_CURRENCY_API.NO_RATE  OR
                     GL_CURRENCY_API.INVALID_CURRENCY THEN
	        oe_debug_pub.add( 'conversion exception for '
                || l_currency_code, 1 );
	        add_error_currency( x_error_curr_tbl, l_currency_code );
	      END;

              ----change for the Return project
              IF NVL(p_credit_check_rule_rec.include_returns_flag,'N') = 'N'
              THEN
	        CLOSE customer_balance_csr;
              ELSE
                CLOSE customer_balance_ret_csr;
              END IF;

              j  :=  p_binary_tbl.NEXT(j);
	    END LOOP;
          END IF; -- global
          i := p_usage_curr_tbl.NEXT(i);
        END LOOP;  -- i loop

    ELSE -- customer level all currencies
      -- exposure is at customer level and for all currencies
      -- for each currency in the list

      IF G_debug_flag = 'Y'
      THEN
        oe_debug_pub.add(' Into ALL currencies ');
      END IF;


      i  := 0;
      --------------------------
      -- for left of Main Bucket
      l_bucket         :=  p_main_bucket;
      l_bucket_length  :=  G_MAX_BUCKET_LENGTH;

      IF p_global_exposure_flag = 'Y'
      THEN
        IF G_debug_flag = 'Y'
        THEN
          oe_debug_pub.add( ' Into cust GLOBAL');
        END IF;

       ----change for the Return project
       IF NVL(p_credit_check_rule_rec.include_returns_flag,'N') = 'N'
       THEN
         -----returns are not included
         OPEN cust_all_curr_stub_csr_global;
         FETCH cust_all_curr_stub_csr_global
         INTO l_balance, l_currency_code;
            -- For each currency in the cursor

            WHILE NOT cust_all_curr_stub_csr_global%NOTFOUND
            LOOP
              IF G_debug_flag = 'Y'
              THEN
                oe_debug_pub.add
	        ( '(all) stub global cursor at ' || l_currency_code
                   || ' currency with balance '
	        || l_balance || ' and bucket/length '
                || l_bucket || '/' || l_bucket_length, 2 );
              END IF;

	      IF ( NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                      l_currency_code ,1,1),0) = 0 )
	        OR
	        ((NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                    l_currency_code ,1,1),0) > 0 )
	          AND ( l_currency_code = p_limit_curr_code )
	        )
              THEN
                BEGIN
	          l_term :=
	            OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
	            ( p_amount                  => l_balance
	            , p_transactional_currency  => l_currency_code
	            , p_limit_currency          => p_limit_curr_code
	            , p_functional_currency     => g_functional_currency
		    , p_conversion_date         => SYSDATE
		    , p_conversion_type         => g_conversion_type
		    );
	          l_total := l_total + NVL( l_term, 0 );

	        EXCEPTION
	          WHEN  GL_CURRENCY_API.NO_RATE
                       OR  GL_CURRENCY_API.INVALID_CURRENCY THEN
	            oe_debug_pub.add( 'conversion exception for '
                       || l_currency_code, 1 );
	            add_error_currency( x_error_curr_tbl, l_currency_code );
	        END;
              ELSE
	        oe_debug_pub.add( 'Currency excluded from usages ');
              END IF; -- exclude curr list
              FETCH cust_all_curr_stub_csr_global
              INTO l_balance, l_currency_code;
              i := i + 1;
            END LOOP;

            CLOSE cust_all_curr_stub_csr_global;

          -----returns are included
          ELSE
            OPEN cust_all_curr_stub_ret_csr_gl;
            FETCH cust_all_curr_stub_ret_csr_gl
            INTO l_balance, l_currency_code;
              -- For each currency in the cursor

              WHILE NOT cust_all_curr_stub_ret_csr_gl%NOTFOUND
              LOOP
                IF G_debug_flag = 'Y'
                THEN
                  oe_debug_pub.add
	          ( '(all) stub global cursor at ' || l_currency_code
                     || ' currency with balance '
	          || l_balance || ' and bucket/length '
                  || l_bucket || '/' || l_bucket_length, 2 );
                END IF;

	        IF ( NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                        l_currency_code ,1,1),0) = 0 )
	          OR
	          ((NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                      l_currency_code ,1,1),0) > 0 )
	            AND ( l_currency_code = p_limit_curr_code )
	          )
                THEN
                  BEGIN
	            l_term :=
	              OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
	              ( p_amount                  => l_balance
	              , p_transactional_currency  => l_currency_code
	              , p_limit_currency          => p_limit_curr_code
	              , p_functional_currency     => g_functional_currency
		      , p_conversion_date         => SYSDATE
		      , p_conversion_type         => g_conversion_type
		      );
	            l_total := l_total + NVL( l_term, 0 );

	          EXCEPTION
	            WHEN  GL_CURRENCY_API.NO_RATE
                         OR  GL_CURRENCY_API.INVALID_CURRENCY THEN
	              oe_debug_pub.add( 'conversion exception for '
                         || l_currency_code, 1 );
	              add_error_currency( x_error_curr_tbl, l_currency_code );
	          END;
                ELSE
	          oe_debug_pub.add( 'Currency excluded from usages ');
                END IF; -- exclude curr list

                FETCH cust_all_curr_stub_ret_csr_gl
                INTO l_balance, l_currency_code;
                i := i + 1;
              END LOOP;

              CLOSE cust_all_curr_stub_ret_csr_gl;

          END IF;-----end of checking if returns are included

------------------------start  BR --------------------
          IF p_credit_check_rule_rec.open_ar_days IS NOT NULL
             AND p_credit_check_rule_rec.open_ar_balance_flag = 'Y'
             AND b8 = G_INVOICES
          THEN

           i  := 0;
               --------------------------
            -- for left of Main Bucket
            l_bucket         :=  p_main_bucket;
            l_bucket_length  :=  G_MAX_BUCKET_LENGTH;

           IF G_debug_flag = 'Y'
           THEN
             oe_debug_pub.add( ' Into cust GLOBAL');
           END IF;

            OPEN cust_br_all_curr_stub_csr_gl;
            FETCH cust_br_all_curr_stub_csr_gl
            INTO l_br_balance, l_currency_code;

          -- For each currency in the cursor

              WHILE NOT cust_br_all_curr_stub_csr_gl%NOTFOUND
              LOOP
              IF G_debug_flag = 'Y'
              THEN
                oe_debug_pub.add
	      ( '(all) stub global cursor at ' || l_currency_code
                 || ' currency with BR balance '
	      || l_br_balance || ' and bucket/length '
              || l_bucket || '/' || l_bucket_length, 2 );
              END IF;


	       IF ( NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                    l_currency_code ,1,1),0) = 0 )
	      OR
	      ((NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                  l_currency_code ,1,1),0) > 0 )
	        AND ( l_currency_code = p_limit_curr_code )
	      )
              THEN
                BEGIN
	        l_term :=
	          OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
	          ( p_amount                  => l_br_balance
	          , p_transactional_currency  => l_currency_code
	          , p_limit_currency          => p_limit_curr_code
	          , p_functional_currency     => g_functional_currency
		  , p_conversion_date         => SYSDATE
		  , p_conversion_type         => g_conversion_type
		  );
	        l_total := l_total + NVL( l_term, 0 );

	        EXCEPTION
	          WHEN  GL_CURRENCY_API.NO_RATE
                     OR  GL_CURRENCY_API.INVALID_CURRENCY THEN
	          oe_debug_pub.add( 'conversion exception for '
                     || l_currency_code, 1 );
	          add_error_currency( x_error_curr_tbl, l_currency_code );
	        END;
              ELSE
	        oe_debug_pub.add( 'Currency excluded from usages ');
              END IF; -- exclude curr list
              FETCH cust_br_all_curr_stub_csr_gl
               INTO l_br_balance, l_currency_code;
                 i := i + 1;
            END LOOP;

          CLOSE cust_br_all_curr_stub_csr_gl ;
       END IF;
---------------------------- end  BR ------------------------

        -----------------------------
	-- for fraction of Main Bucket

        j  :=  p_binary_tbl.FIRST;
        WHILE  j  IS NOT NULL LOOP
	  l_bucket         :=  p_binary_tbl(j).bucket;
	  l_bucket_length  :=  p_binary_tbl(j).bucket_length;

          ----change for the Return project
          IF NVL(p_credit_check_rule_rec.include_returns_flag,'N') = 'N'
          THEN
            -----returns are not included
	    OPEN cust_all_curr_csr_global;
  	    FETCH cust_all_curr_csr_global
            INTO l_balance, l_currency_code;

	    -- For each currency that exists, the cursor returns a row.
	    -- Convert the balance and sum up to total exposure

	    WHILE NOT cust_all_curr_csr_global%NOTFOUND
            LOOP
              IF G_debug_flag = 'Y'
              THEN
	       oe_debug_pub.add
	        ( 'cust all global cursor at ' || l_currency_code
                   || ' currency with balance '
	          || l_balance || ' and bucket/length '
                  || l_bucket || '/' || l_bucket_length, 2 );

              END IF;

	      IF ( NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                  l_currency_code ,1,1),0) = 0 )
                OR
	         ((NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                  l_currency_code ,1,1),0) > 0 )
	           AND ( l_currency_code = p_limit_curr_code )
	         )
	      THEN
	        BEGIN
	          l_term :=
                    OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
	            ( p_amount                  => l_balance
	            , p_transactional_currency  => l_currency_code
	            , p_limit_currency          => p_limit_curr_code
 	            , p_functional_currency     => g_functional_currency
	            , p_conversion_date         => SYSDATE
	            , p_conversion_type         => g_conversion_type
	            );
	          l_total := l_total + NVL( l_term, 0 );

	        EXCEPTION
	          WHEN  GL_CURRENCY_API.NO_RATE  OR
                         GL_CURRENCY_API.INVALID_CURRENCY THEN
	            oe_debug_pub.add( 'conversion exception for ' ||
                      l_currency_code, 1 );
	            add_error_currency( x_error_curr_tbl, l_currency_code );
	        END;
              ELSE
	        oe_debug_pub.add( 'Currency excluded from usages ');
	      END IF;  -- exclude curr list
              FETCH cust_all_curr_csr_global INTO l_balance, l_currency_code;
              i := i + 1;
            END LOOP;
	    CLOSE cust_all_curr_csr_global;

          -----returns are included
          ELSE
            OPEN cust_all_curr_ret_csr_global;
  	    FETCH cust_all_curr_ret_csr_global
            INTO l_balance, l_currency_code;

	    -- For each currency that exists, the cursor returns a row.
	    -- Convert the balance and sum up to total exposure

	    WHILE NOT cust_all_curr_ret_csr_global%NOTFOUND
            LOOP
              IF G_debug_flag = 'Y'
              THEN
	       oe_debug_pub.add
	        ( 'cust all global cursor at ' || l_currency_code
                   || ' currency with balance '
	          || l_balance || ' and bucket/length '
                  || l_bucket || '/' || l_bucket_length, 2 );

              END IF;

	      IF ( NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                  l_currency_code ,1,1),0) = 0 )
                OR
	         ((NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                  l_currency_code ,1,1),0) > 0 )
	           AND ( l_currency_code = p_limit_curr_code )
	         )
	      THEN
	        BEGIN
	          l_term :=
                    OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
	            ( p_amount                  => l_balance
	            , p_transactional_currency  => l_currency_code
	            , p_limit_currency          => p_limit_curr_code
 	            , p_functional_currency     => g_functional_currency
	            , p_conversion_date         => SYSDATE
	            , p_conversion_type         => g_conversion_type
	            );
	          l_total := l_total + NVL( l_term, 0 );

	        EXCEPTION
	          WHEN  GL_CURRENCY_API.NO_RATE  OR
                         GL_CURRENCY_API.INVALID_CURRENCY THEN
	            oe_debug_pub.add( 'conversion exception for ' ||
                      l_currency_code, 1 );
	            add_error_currency( x_error_curr_tbl, l_currency_code );
	        END;
              ELSE
	        oe_debug_pub.add( 'Currency excluded from usages ');
	      END IF;  -- exclude curr list

              FETCH cust_all_curr_ret_csr_global
              INTO l_balance, l_currency_code;
              i := i + 1;
            END LOOP;

	    CLOSE cust_all_curr_ret_csr_global;
          END IF; ----end of checking if returns are included

          j  :=  p_binary_tbl.NEXT(j);
        END LOOP;  -- J


      ELSE  -- not global cck
        IF G_debug_flag = 'Y'
        THEN
         oe_debug_pub.add(' Into cust NOT  global ');
        END IF;

        ----change for the Return project
        IF NVL(p_credit_check_rule_rec.include_returns_flag,'N') = 'N'
        THEN
          ----returns are not included, old code
          OPEN customer_all_curr_stub_csr;
	  FETCH customer_all_curr_stub_csr
          INTO l_balance, l_currency_code;
            -- For each currency in the cursor

   	    WHILE NOT customer_all_curr_stub_csr%NOTFOUND
             LOOP
              IF G_debug_flag = 'Y'
              THEN
	        oe_debug_pub.add
	        ( '(all) stub cursor at ' || l_currency_code
                       || ' currency with balance '
	          || l_balance || ' and bucket/length '
                    || l_bucket || '/' || l_bucket_length, 2 );
              END IF;

	      IF ( NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                    l_currency_code ,1,1),0) = 0 )
	          OR
	         ((NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                       l_currency_code ,1,1),0) > 0 )
		  AND ( l_currency_code = p_limit_curr_code )
	         )
	      THEN
	        BEGIN
	          l_term :=
	            OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
	            ( p_amount                  => l_balance
	            , p_transactional_currency  => l_currency_code
	            , p_limit_currency          => p_limit_curr_code
	            , p_functional_currency     => g_functional_currency
	            , p_conversion_date         => SYSDATE
	            , p_conversion_type         => g_conversion_type
	            );
	          l_total := l_total + NVL( l_term, 0 );

	       EXCEPTION
	          WHEN  GL_CURRENCY_API.NO_RATE
                       OR  GL_CURRENCY_API.INVALID_CURRENCY THEN
	            oe_debug_pub.add( 'conversion exception for '
                      || l_currency_code, 1 );
	            add_error_currency( x_error_curr_tbl, l_currency_code );
  	        END;
	      ELSE
	        oe_debug_pub.add(' Currency excluded from usages list ');
	      END IF;

                FETCH customer_all_curr_stub_csr
                INTO l_balance, l_currency_code;
                i := i + 1;
              END LOOP;

              CLOSE customer_all_curr_stub_csr;

            ------returns are included, the same code as above but
            ------ using different cursors
            ELSE
              OPEN customer_all_curr_stub_ret_csr;
	      FETCH customer_all_curr_stub_ret_csr
              INTO l_balance, l_currency_code;

              -- For each currency in the cursor

   	      WHILE NOT customer_all_curr_stub_ret_csr%NOTFOUND
               LOOP
                IF G_debug_flag = 'Y'
                THEN
	          oe_debug_pub.add
	          ( '(all) stub cursor at ' || l_currency_code
                         || ' currency with balance '
	            || l_balance || ' and bucket/length '
                      || l_bucket || '/' || l_bucket_length, 2 );
                END IF;

	        IF ( NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                      l_currency_code ,1,1),0) = 0 )
	            OR
	           ((NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                         l_currency_code ,1,1),0) > 0 )
		    AND ( l_currency_code = p_limit_curr_code )
	           )
	        THEN
	          BEGIN
	            l_term :=
	              OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
	              ( p_amount                  => l_balance
	              , p_transactional_currency  => l_currency_code
	              , p_limit_currency          => p_limit_curr_code
	              , p_functional_currency     => g_functional_currency
	              , p_conversion_date         => SYSDATE
	              , p_conversion_type         => g_conversion_type
	              );
	            l_total := l_total + NVL( l_term, 0 );

	         EXCEPTION
	            WHEN  GL_CURRENCY_API.NO_RATE
                         OR  GL_CURRENCY_API.INVALID_CURRENCY THEN
	              oe_debug_pub.add( 'conversion exception for '
                        || l_currency_code, 1 );
	              add_error_currency( x_error_curr_tbl, l_currency_code );
  	          END;
	        ELSE
	          oe_debug_pub.add(' Currency excluded from usages list ');
	        END IF;

                FETCH customer_all_curr_stub_ret_csr
                INTO l_balance, l_currency_code;
                i := i + 1;
              END LOOP;

              CLOSE customer_all_curr_stub_ret_csr;

            END IF;  ---end of checking if returns are include

----------------------- start BR ------------------

        IF p_credit_check_rule_rec.open_ar_days IS NOT NULL
         AND p_credit_check_rule_rec.open_ar_balance_flag = 'Y'
         AND b8 = G_INVOICES
        THEN
          OPEN customer_br_all_curr_stub_csr;
          FETCH customer_br_all_curr_stub_csr
          INTO l_br_balance, l_currency_code;

          -- For each currency in the cursor

	  WHILE NOT customer_br_all_curr_stub_csr%NOTFOUND
          LOOP
            IF G_debug_flag = 'Y'
            THEN
	     oe_debug_pub.add
	      ( '(all) stub cursor at ' || l_currency_code
                     || ' currency with BR balance '
	        || l_br_balance || ' and bucket/length '
                  || l_bucket || '/' || l_bucket_length, 2 );
            END IF;

	       IF ( NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                  l_currency_code ,1,1),0) = 0 )
	        OR
	       ((NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                     l_currency_code ,1,1),0) > 0 )
		AND ( l_currency_code = p_limit_curr_code )
	       )
	      THEN
	        BEGIN
	        l_term :=
	          OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
	          ( p_amount                  => l_br_balance
	          , p_transactional_currency  => l_currency_code
	          , p_limit_currency          => p_limit_curr_code
	          , p_functional_currency     => g_functional_currency
	          , p_conversion_date         => SYSDATE
	          , p_conversion_type         => g_conversion_type
	          );
	        l_total := l_total + NVL( l_term, 0 );

	      EXCEPTION
	        WHEN  GL_CURRENCY_API.NO_RATE
                     OR  GL_CURRENCY_API.INVALID_CURRENCY THEN
	          oe_debug_pub.add( 'conversion exception for '
                    || l_currency_code, 1 );
	          add_error_currency( x_error_curr_tbl, l_currency_code );
  	      END;
	    ELSE
	      oe_debug_pub.add(' Currency excluded from usages list ');
	    END IF;

            FETCH customer_br_all_curr_stub_csr
            INTO l_br_balance, l_currency_code;
            i := i + 1;
          END LOOP;
          CLOSE customer_br_all_curr_stub_csr ;
        END IF;

-------------------------- end BR --------------------------

        -----------------------------
        -- for fraction of Main Bucket

        j  :=  p_binary_tbl.FIRST;
	WHILE  j  IS NOT NULL
        LOOP
 	  l_bucket         :=  p_binary_tbl(j).bucket;
	  l_bucket_length  :=  p_binary_tbl(j).bucket_length;

          ----change for the Return project
          IF NVL(p_credit_check_rule_rec.include_returns_flag,'N') = 'N'
          THEN
            ----returns are not included, old code
	    OPEN customer_balance_all_curr_csr;
	    FETCH customer_balance_all_curr_csr
            INTO l_balance, l_currency_code;

	    -- For each currency in the cursor
	    WHILE NOT customer_balance_all_curr_csr%NOTFOUND
            LOOP
              IF G_debug_flag = 'Y'
              THEN
	        oe_debug_pub.add
	        ( '(all) cursor at ' || l_currency_code
                    || ' currency with balance '
	          || l_balance || ' and bucket/length '
                  || l_bucket || '/' || l_bucket_length, 2 );
              END IF;

	      IF ( NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                    l_currency_code ,1,1),0) = 0 )
	        OR
	         ((NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                     l_currency_code ,1,1),0) > 0 )
	          AND ( l_currency_code = p_limit_curr_code )
	         )
	      THEN
	        BEGIN
	          l_term :=
	            OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
	            ( p_amount                  => l_balance
	            , p_transactional_currency  => l_currency_code
	            , p_limit_currency          => p_limit_curr_code
	            , p_functional_currency     => g_functional_currency
	            , p_conversion_date         => SYSDATE
	            , p_conversion_type         => g_conversion_type
	            );
                  l_total := l_total + NVL( l_term, 0 );

	        EXCEPTION
	          WHEN  GL_CURRENCY_API.NO_RATE  OR
                        GL_CURRENCY_API.INVALID_CURRENCY THEN

	            oe_debug_pub.add( 'conversion exception for '
                    || l_currency_code, 1 );
	            add_error_currency( x_error_curr_tbl, l_currency_code );
 	        END;
              ELSE
	        oe_debug_pub.add(' Currency excluded from usages list ');
	      END IF;

              FETCH customer_balance_all_curr_csr
              INTO l_balance, l_currency_code;

              i := i + 1;
            END LOOP;
            CLOSE customer_balance_all_curr_csr;

            ------returns are included
            ELSE
              OPEN customer_bal_all_curr_ret_csr;
	      FETCH customer_bal_all_curr_ret_csr
              INTO l_balance, l_currency_code;

	      -- For each currency in the cursor
	      WHILE NOT customer_bal_all_curr_ret_csr%NOTFOUND
              LOOP
                IF G_debug_flag = 'Y'
                THEN
	          oe_debug_pub.add
	          ( '(all) cursor at ' || l_currency_code
                      || ' currency with balance '
	            || l_balance || ' and bucket/length '
                    || l_bucket || '/' || l_bucket_length, 2 );
                END IF;

	        IF ( NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                      l_currency_code ,1,1),0) = 0 )
	          OR
	           ((NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                       l_currency_code ,1,1),0) > 0 )
	            AND ( l_currency_code = p_limit_curr_code )
	           )
	        THEN
	          BEGIN
	            l_term :=
	              OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
	              ( p_amount                  => l_balance
	              , p_transactional_currency  => l_currency_code
	              , p_limit_currency          => p_limit_curr_code
	              , p_functional_currency     => g_functional_currency
	              , p_conversion_date         => SYSDATE
	              , p_conversion_type         => g_conversion_type
	              );
                    l_total := l_total + NVL( l_term, 0 );

	          EXCEPTION
	            WHEN  GL_CURRENCY_API.NO_RATE  OR
                          GL_CURRENCY_API.INVALID_CURRENCY THEN

	              oe_debug_pub.add( 'conversion exception for '
                      || l_currency_code, 1 );
	              add_error_currency( x_error_curr_tbl, l_currency_code );
 	          END;
                ELSE
	          oe_debug_pub.add(' Currency excluded from usages list ');
	        END IF;

                FETCH customer_bal_all_curr_ret_csr
                INTO l_balance, l_currency_code;

                i := i + 1;
              END LOOP;

              CLOSE customer_bal_all_curr_ret_csr;

            END IF; ------end of checking if returns are included

	    j  :=  p_binary_tbl.NEXT(j);
          END LOOP; -- J

      END IF; -- global/not global
    END IF; -- all currency

----------------------- END customer -----------------------------
------------------------------------------------------------------
--------------------------Party-----------------------------------
-------------------------------------------------------------------
  ELSIF p_party_id is NOT NULL
  THEN

    IF G_debug_flag = 'Y'
    THEN
      oe_debug_pub.add( 'exposure at Party level ',1);
      oe_debug_pub.add( 'g_use_party_hierarchy => '|| g_use_party_hierarchy );
    END IF;

    IF  NVL(p_include_all_flag,'N')  =  'N'
    THEN
      IF G_debug_flag = 'Y'
      THEN
        oe_debug_pub.add( 'NOT ALL currencies ');
      END IF;

      IF g_use_party_hierarchy = 'N'
      THEN
        i  := p_usage_curr_tbl.FIRST;
        WHILE  i  IS NOT NULL
        LOOP
          l_currency_code := p_usage_curr_tbl(i).usage_curr_code;
        --------------------------
        -- for left of Main Bucket
	  l_bucket         :=  p_main_bucket;
	  l_bucket_length  :=  G_MAX_BUCKET_LENGTH;

          ----change for the Return project
          IF NVL(p_credit_check_rule_rec.include_returns_flag,'N') = 'N'
          THEN
            -----returns are not included
	    OPEN party_balance_stub_csr_global ;
	    FETCH party_balance_stub_csr_global
            INTO l_balance;

          -----returns are included
          ELSE
            OPEN party_bal_stub_ret_csr_global ;
	    FETCH party_bal_stub_ret_csr_global
            INTO l_balance;
          END IF;

           IF p_credit_check_rule_rec.open_ar_days IS NOT NULL
               AND p_credit_check_rule_rec.open_ar_balance_flag = 'Y'
               AND b8 = G_INVOICES
           THEN
             OPEN party_br_stub_csr_global ;
             FETCH party_br_stub_csr_global
             INTO l_br_balance ;

             CLOSE party_br_stub_csr_global ;
           END IF;

          IF G_debug_flag = 'Y'
          THEN
	    oe_debug_pub.add
           ( 'global stub cursor at ' || l_currency_code
	        || ' currency with balance ' || l_balance, 2 );
	    oe_debug_pub.add
           ( 'global stub cursor at ' || l_currency_code
	        || ' currency with  BR balance ' || l_br_balance, 2 );
           END IF;
            BEGIN
	      l_term :=
	        OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
	        ( p_amount                  => l_balance +
                               NVL(l_br_balance,0)
	        , p_transactional_currency  => l_currency_code
	        , p_limit_currency          => p_limit_curr_code
	        , p_functional_currency     => g_functional_currency
	        , p_conversion_date         => SYSDATE
	        , p_conversion_type         => g_conversion_type
	        );
  	      l_total := l_total + NVL( l_term, 0 );

	    EXCEPTION
	      WHEN  GL_CURRENCY_API.NO_RATE  OR
                    GL_CURRENCY_API.INVALID_CURRENCY THEN
	        oe_debug_pub.add( 'conversion exception for '
                 || l_currency_code, 1 );
	        add_error_currency( x_error_curr_tbl, l_currency_code );
            END;

            ----change for the Return project
            IF NVL(p_credit_check_rule_rec.include_returns_flag,'N') = 'N'
            THEN
              CLOSE party_balance_stub_csr_global;
            ELSE
              CLOSE party_bal_stub_ret_csr_global;
            END IF;

	  -----------------------------
	  -- for fraction of Main Bucket

	  j  :=  p_binary_tbl.FIRST;
	  WHILE  j  IS NOT NULL
          LOOP
	    l_bucket         :=  p_binary_tbl(j).bucket;
	    l_bucket_length  :=  p_binary_tbl(j).bucket_length;


            ----change for the Return project
            IF NVL(p_credit_check_rule_rec.include_returns_flag,'N') = 'N'
            THEN
	      OPEN party_balance_csr_global ;

	      FETCH party_balance_csr_global
              INTO l_balance;

            ---include returns
            ELSE
              OPEN party_balance_ret_csr_global ;

	      FETCH party_balance_ret_csr_global
              INTO l_balance;
            END IF;

            IF G_debug_flag = 'Y'
            THEN
        	    oe_debug_pub.add
	      ( 'global cursor at ' || l_currency_code
	       || ' currency with balance ' || l_balance, 2 );
            END IF;
	    BEGIN
	      l_term :=
	        OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
	        ( p_amount                  => l_balance
	        , p_transactional_currency  => l_currency_code
	        , p_limit_currency          => p_limit_curr_code
		, p_functional_currency     => g_functional_currency
		, p_conversion_date         => SYSDATE
		, p_conversion_type         => g_conversion_type
		);
	      l_total := l_total + NVL( l_term, 0 );

	    EXCEPTION
	      WHEN  GL_CURRENCY_API.NO_RATE  OR
                    GL_CURRENCY_API.INVALID_CURRENCY THEN
	        oe_debug_pub.add( 'conversion exception for '
                    || l_currency_code, 1 );
	        add_error_currency( x_error_curr_tbl, l_currency_code );
	    END;

            ----change for the Return project
            IF NVL(p_credit_check_rule_rec.include_returns_flag,'N') = 'N'
            THEN

	      CLOSE party_balance_csr_global ;
            ELSE
              CLOSE party_balance_ret_csr_global ;
            END IF;

            j  :=  p_binary_tbl.NEXT(j);

	  END LOOP;

        i := p_usage_curr_tbl.NEXT(i);
      END LOOP;  -- i loop

     ELSE --- Hierarchy usages
       IF G_debug_flag = 'Y'
       THEN
         oe_debug_pub.add(' Hierarchy Usages ',1);
         oe_debug_pub.add(' OE_CREDIT_CHECK_UTIL.G_hierarchy_type => '||
          OE_CREDIT_CHECK_UTIL.G_hierarchy_type );
         oe_debug_pub.add(' G_MAX_BUCKET_LENGTH => '||
            G_MAX_BUCKET_LENGTH);
        END IF;

        i  := p_usage_curr_tbl.FIRST;
        WHILE  i  IS NOT NULL
        LOOP
          l_currency_code := p_usage_curr_tbl(i).usage_curr_code;
        --------------------------
        -- for left of Main Bucket
	  l_bucket         :=  p_main_bucket;
	  l_bucket_length  :=  G_MAX_BUCKET_LENGTH;

          ---change for the Return project
          IF NVL(p_credit_check_rule_rec.include_returns_flag,'N') = 'N'
          THEN
	    OPEN party_h_bal_stub_csr_gl ;
	    FETCH party_h_bal_stub_csr_gl
            INTO l_balance;
          ELSE
            OPEN party_h_bal_ret_stub_csr_gl ;
	    FETCH party_h_bal_ret_stub_csr_gl
            INTO l_balance;
          END IF;

          IF p_credit_check_rule_rec.open_ar_days IS NOT NULL
            AND p_credit_check_rule_rec.open_ar_balance_flag = 'Y'
            AND b8 = G_INVOICES
          THEN
            OPEN party_br_h_stub_csr_gl ;
            FETCH party_br_h_stub_csr_gl
            INTO l_br_balance ;
            CLOSE party_br_h_stub_csr_gl ;
          END IF;

          IF G_debug_flag = 'Y'
          THEN
	   oe_debug_pub.add
           ( 'global stub cursor at ' || l_currency_code
	        || ' currency with balance ' || l_balance, 2 );
          END IF;

            BEGIN
	      l_term :=
	        OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
	        ( p_amount                  => l_balance
                                 + nvl(l_br_balance ,0)
	        , p_transactional_currency  => l_currency_code
	        , p_limit_currency          => p_limit_curr_code
	        , p_functional_currency     => g_functional_currency
	        , p_conversion_date         => SYSDATE
	        , p_conversion_type         => g_conversion_type
	        );
  	      l_total := l_total + NVL( l_term, 0 );

	    EXCEPTION
	      WHEN  GL_CURRENCY_API.NO_RATE  OR
                    GL_CURRENCY_API.INVALID_CURRENCY THEN
	        oe_debug_pub.add( 'conversion exception for '
                 || l_currency_code, 1 );
	        add_error_currency( x_error_curr_tbl, l_currency_code );
            END;

            ---change for the Return project
            IF NVL(p_credit_check_rule_rec.include_returns_flag,'N') = 'N'
            THEN
	      CLOSE party_h_bal_stub_csr_gl ;
            ELSE
              CLOSE party_h_bal_ret_stub_csr_gl ;
            END IF;

	  -----------------------------
	  -- for fraction of Main Bucket

	  j  :=  p_binary_tbl.FIRST;
	  WHILE  j  IS NOT NULL
          LOOP
	    l_bucket         :=  p_binary_tbl(j).bucket;
	    l_bucket_length  :=  p_binary_tbl(j).bucket_length;

            ---change for the Return project
            IF NVL(p_credit_check_rule_rec.include_returns_flag,'N') = 'N'
            THEN

  	      OPEN party_h_balance_csr_global ;
	      FETCH party_h_balance_csr_global
              INTO l_balance;
            ELSE
              OPEN party_h_bal_ret_csr_global ;
	      FETCH party_h_bal_ret_csr_global
              INTO l_balance;
            END IF;

            IF G_debug_flag = 'Y'
            THEN
         	    oe_debug_pub.add
	      ( 'global cursor at ' || l_currency_code
	       || ' currency with balance ' || l_balance, 2 );
            END IF;

	    BEGIN
	      l_term :=
	        OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
	        ( p_amount                  => l_balance
	        , p_transactional_currency  => l_currency_code
	        , p_limit_currency          => p_limit_curr_code
		, p_functional_currency     => g_functional_currency
		, p_conversion_date         => SYSDATE
		, p_conversion_type         => g_conversion_type
		);
	      l_total := l_total + NVL( l_term, 0 );

	    EXCEPTION
	      WHEN  GL_CURRENCY_API.NO_RATE  OR
                    GL_CURRENCY_API.INVALID_CURRENCY THEN
	        oe_debug_pub.add( 'conversion exception for '
                    || l_currency_code, 1 );
	        add_error_currency( x_error_curr_tbl, l_currency_code );
	    END;

            ---change for the Return project
            IF NVL(p_credit_check_rule_rec.include_returns_flag,'N') = 'N'
            THEN
	      CLOSE party_h_balance_csr_global ;
            ELSE
              CLOSE party_h_bal_ret_csr_global ;
            END IF;

            j  :=  p_binary_tbl.NEXT(j);

	  END LOOP;

        i := p_usage_curr_tbl.NEXT(i);
      END LOOP;  -- i loop


     END IF; -- hierarchy check

    ELSE --  level all currencies
      IF G_debug_flag = 'Y'
      THEN
        oe_debug_pub.add(' Into ALL currencies  party ');
      END IF;


      i  := 0;
      --------------------------
      -- for left of Main Bucket
      l_bucket         :=  p_main_bucket;
      l_bucket_length  :=  G_MAX_BUCKET_LENGTH;

      IF g_use_party_hierarchy = 'N'
      THEN
       IF G_debug_flag = 'Y'
       THEN
         oe_debug_pub.add( ' Into party all curr ');
       END IF;

       ---change for the Return project
       IF NVL(p_credit_check_rule_rec.include_returns_flag,'N') = 'N'
       THEN
         ---returns are not included
         OPEN party_all_curr_stub_csr_global ;
         FETCH party_all_curr_stub_csr_global
         INTO l_balance, l_currency_code;
            -- For each currency in the cursor

          WHILE NOT party_all_curr_stub_csr_global%NOTFOUND
          LOOP
            IF G_debug_flag = 'Y'
            THEN
              oe_debug_pub.add
	        ( '(all) stub global cursor at ' || l_currency_code
                   || ' currency with balance '
	        || l_balance || ' and bucket/length '
                || l_bucket || '/' || l_bucket_length, 2 );
            END IF;

	      IF ( NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                      l_currency_code ,1,1),0) = 0 )
	        OR
	        ((NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                    l_currency_code ,1,1),0) > 0 )
	          AND ( l_currency_code = p_limit_curr_code )
	        )
              THEN
                BEGIN
	          l_term :=
	            OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
	            ( p_amount                  => l_balance
	            , p_transactional_currency  => l_currency_code
	            , p_limit_currency          => p_limit_curr_code
	            , p_functional_currency     => g_functional_currency
		    , p_conversion_date         => SYSDATE
		    , p_conversion_type         => g_conversion_type
		    );
	          l_total := l_total + NVL( l_term, 0 );

	        EXCEPTION
	          WHEN  GL_CURRENCY_API.NO_RATE
                       OR  GL_CURRENCY_API.INVALID_CURRENCY THEN
	            oe_debug_pub.add( 'conversion exception for '
                       || l_currency_code, 1 );
	            add_error_currency( x_error_curr_tbl, l_currency_code );
	        END;
              ELSE
	        oe_debug_pub.add( 'Currency excluded from usages ');
              END IF; -- exclude curr list

              FETCH party_all_curr_stub_csr_global
              INTO l_balance, l_currency_code;

              i := i + 1;
          END LOOP;

          CLOSE party_all_curr_stub_csr_global ;

        -----returns are included
        ELSE
          OPEN party_all_curr_stub_ret_csr_gl ;
          FETCH party_all_curr_stub_ret_csr_gl
          INTO l_balance, l_currency_code;
            -- For each currency in the cursor

          WHILE NOT party_all_curr_stub_ret_csr_gl%NOTFOUND
          LOOP
            IF G_debug_flag = 'Y'
            THEN
              oe_debug_pub.add
	        ( '(all) stub global cursor at ' || l_currency_code
                   || ' currency with balance '
	        || l_balance || ' and bucket/length '
                || l_bucket || '/' || l_bucket_length, 2 );
            END IF;

	      IF ( NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                      l_currency_code ,1,1),0) = 0 )
	        OR
	        ((NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                    l_currency_code ,1,1),0) > 0 )
	          AND ( l_currency_code = p_limit_curr_code )
	        )
              THEN
                BEGIN
	          l_term :=
	            OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
	            ( p_amount                  => l_balance
	            , p_transactional_currency  => l_currency_code
	            , p_limit_currency          => p_limit_curr_code
	            , p_functional_currency     => g_functional_currency
		    , p_conversion_date         => SYSDATE
		    , p_conversion_type         => g_conversion_type
		    );
	          l_total := l_total + NVL( l_term, 0 );

	        EXCEPTION
	          WHEN  GL_CURRENCY_API.NO_RATE
                       OR  GL_CURRENCY_API.INVALID_CURRENCY THEN
	            oe_debug_pub.add( 'conversion exception for '
                       || l_currency_code, 1 );
	            add_error_currency( x_error_curr_tbl, l_currency_code );
	        END;
              ELSE
	        oe_debug_pub.add( 'Currency excluded from usages ');
              END IF; -- exclude curr list

              FETCH party_all_curr_stub_ret_csr_gl
              INTO l_balance, l_currency_code;

              i := i + 1;
          END LOOP;

          CLOSE party_all_curr_stub_ret_csr_gl ;

        END IF; ---end of checking if returns are included

    --------------------- start  BR ---------------
       IF p_credit_check_rule_rec.open_ar_days IS NOT NULL
         AND p_credit_check_rule_rec.open_ar_balance_flag = 'Y'
        AND b8 = G_INVOICES
       THEN

          OPEN party_br_all_curr_stub_csr_gl ;
          FETCH party_br_all_curr_stub_csr_gl
          INTO l_br_balance, l_currency_code;
          -- For each currency in the cursor

          WHILE NOT party_br_all_curr_stub_csr_gl%NOTFOUND
          LOOP

            IF G_debug_flag = 'Y'
            THEN
             oe_debug_pub.add
	      ( '(all) stub global cursor at ' || l_currency_code
                 || ' currency with BR balance '
	      || l_br_balance || ' and bucket/length '
              || l_bucket || '/' || l_bucket_length, 2 );
            END IF;

	     IF ( NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                    l_currency_code ,1,1),0) = 0 )
	      OR
	      ((NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                  l_currency_code ,1,1),0) > 0 )
	        AND ( l_currency_code = p_limit_curr_code )
	      )
            THEN
              BEGIN
	        l_term :=
	          OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
	          ( p_amount                  => l_br_balance
	          , p_transactional_currency  => l_currency_code
	          , p_limit_currency          => p_limit_curr_code
	          , p_functional_currency     => g_functional_currency
		  , p_conversion_date         => SYSDATE
		  , p_conversion_type         => g_conversion_type
		  );
	        l_total := l_total + NVL( l_term, 0 );

	      EXCEPTION
	        WHEN  GL_CURRENCY_API.NO_RATE
                     OR  GL_CURRENCY_API.INVALID_CURRENCY THEN
	          oe_debug_pub.add( 'conversion exception for '
                     || l_currency_code, 1 );
	          add_error_currency( x_error_curr_tbl, l_currency_code );
	      END;
            ELSE
	      oe_debug_pub.add( 'Currency excluded from usages ');
            END IF; -- exclude curr list

            FETCH party_br_all_curr_stub_csr_gl
            INTO l_br_balance, l_currency_code;

            i := i + 1;
        END LOOP;

        CLOSE party_br_all_curr_stub_csr_gl ;

      END IF;

 -----------------------------end BR ------------
	-- for fraction of Main Bucket

        j  :=  p_binary_tbl.FIRST;
        WHILE  j  IS NOT NULL LOOP
	  l_bucket         :=  p_binary_tbl(j).bucket;
	  l_bucket_length  :=  p_binary_tbl(j).bucket_length;

          ---change for the Return project
          IF NVL(p_credit_check_rule_rec.include_returns_flag,'N') = 'N'
          THEN
            ---returns are not included
	    OPEN party_all_curr_csr_global ;
  	    FETCH party_all_curr_csr_global
            INTO l_balance, l_currency_code;

	    -- For each currency that exists, the cursor returns a row.
	    -- Convert the balance and sum up to total exposure

	    WHILE NOT party_all_curr_csr_global%NOTFOUND
            LOOP

              IF G_debug_flag = 'Y'
              THEN
	        oe_debug_pub.add
	        ( 'party all global cursor at ' || l_currency_code
                   || ' currency with balance '
	          || l_balance || ' and bucket/length '
                  || l_bucket || '/' || l_bucket_length, 2 );
              END IF;

	      IF ( NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                  l_currency_code ,1,1),0) = 0 )
                OR
	         ((NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                  l_currency_code ,1,1),0) > 0 )
	           AND ( l_currency_code = p_limit_curr_code )
	         )
	      THEN
	        BEGIN
	          l_term :=
                    OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
	            ( p_amount                  => l_balance
	            , p_transactional_currency  => l_currency_code
	            , p_limit_currency          => p_limit_curr_code
 	            , p_functional_currency     => g_functional_currency
	            , p_conversion_date         => SYSDATE
	            , p_conversion_type         => g_conversion_type
	            );
	          l_total := l_total + NVL( l_term, 0 );

	        EXCEPTION
	          WHEN  GL_CURRENCY_API.NO_RATE  OR
                         GL_CURRENCY_API.INVALID_CURRENCY THEN
	            oe_debug_pub.add( 'conversion exception for ' ||
                      l_currency_code, 1 );
	            add_error_currency( x_error_curr_tbl, l_currency_code );
	        END;
              ELSE
	        oe_debug_pub.add( 'Currency excluded from usages ');
	      END IF;  -- exclude curr list

              FETCH party_all_curr_csr_global INTO l_balance, l_currency_code;

              i := i + 1;
            END LOOP;
	    CLOSE party_all_curr_csr_global;

          ----returns are included
          ELSE

	    OPEN party_all_curr_ret_csr_gl ;
  	    FETCH party_all_curr_ret_csr_gl
            INTO l_balance, l_currency_code;

	    -- For each currency that exists, the cursor returns a row.
	    -- Convert the balance and sum up to total exposure

	    WHILE NOT party_all_curr_ret_csr_gl%NOTFOUND
            LOOP

              IF G_debug_flag = 'Y'
              THEN
	        oe_debug_pub.add
	        ( 'party all global cursor at ' || l_currency_code
                   || ' currency with balance '
	          || l_balance || ' and bucket/length '
                  || l_bucket || '/' || l_bucket_length, 2 );
              END IF;

	      IF ( NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                  l_currency_code ,1,1),0) = 0 )
                OR
	         ((NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                  l_currency_code ,1,1),0) > 0 )
	           AND ( l_currency_code = p_limit_curr_code )
	         )
	      THEN
	        BEGIN
	          l_term :=
                    OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
	            ( p_amount                  => l_balance
	            , p_transactional_currency  => l_currency_code
	            , p_limit_currency          => p_limit_curr_code
 	            , p_functional_currency     => g_functional_currency
	            , p_conversion_date         => SYSDATE
	            , p_conversion_type         => g_conversion_type
	            );
	          l_total := l_total + NVL( l_term, 0 );

	        EXCEPTION
	          WHEN  GL_CURRENCY_API.NO_RATE  OR
                         GL_CURRENCY_API.INVALID_CURRENCY THEN
	            oe_debug_pub.add( 'conversion exception for ' ||
                      l_currency_code, 1 );
	            add_error_currency( x_error_curr_tbl, l_currency_code );
	        END;
              ELSE
	        oe_debug_pub.add( 'Currency excluded from usages ');
	      END IF;  -- exclude curr list

              FETCH party_all_curr_ret_csr_gl
              INTO l_balance, l_currency_code;

              i := i + 1;
            END LOOP;

	    CLOSE party_all_curr_ret_csr_gl;

          END IF;  ---end of checking if returns are included

          j  :=  p_binary_tbl.NEXT(j);
        END LOOP;  -- J

      ELSE  -- Hierarchy

        IF G_debug_flag = 'Y'
        THEN
          oe_debug_pub.add(' Into party Hierarchy ',1);
        END IF;

        ---change for the Return project
        IF NVL(p_credit_check_rule_rec.include_returns_flag,'N') = 'N'
        THEN
          ---returns are not included
          OPEN party_h_all_curr_stub_csr_gl ;

          FETCH party_h_all_curr_stub_csr_gl
          INTO l_balance, l_currency_code;

          -- For each currency in the cursor

          WHILE NOT party_h_all_curr_stub_csr_gl%NOTFOUND
          LOOP
            IF G_debug_flag = 'Y'
            THEN
              oe_debug_pub.add
	      ( '(all) stub cursor at ' || l_currency_code
                      || ' currency with balance '
	      || l_balance || ' and bucket/length '
                     || l_bucket || '/' || l_bucket_length, 2 );
            END IF;

	    IF ( NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
               l_currency_code ,1,1),0) = 0 )
	       OR
	       ((NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                  l_currency_code ,1,1),0) > 0 )
	       AND ( l_currency_code = p_limit_curr_code )
	        )
	    THEN
	      BEGIN
	        l_term :=
	        OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
	        ( p_amount                  => l_balance
	        , p_transactional_currency  => l_currency_code
	        , p_limit_currency          => p_limit_curr_code
	        , p_functional_currency     => g_functional_currency
	        , p_conversion_date         => SYSDATE
	        , p_conversion_type         => g_conversion_type
	        );
	        l_total := l_total + NVL( l_term, 0 );

	      EXCEPTION
	        WHEN  GL_CURRENCY_API.NO_RATE
                  OR  GL_CURRENCY_API.INVALID_CURRENCY
                THEN
	          oe_debug_pub.add( 'conversion exception for '
                  || l_currency_code, 1 );
	          add_error_currency( x_error_curr_tbl, l_currency_code );
  	      END;
	    ELSE
	      oe_debug_pub.add(' Currency excluded from usages list ');
	    END IF;

            FETCH party_h_all_curr_stub_csr_gl
            INTO l_balance, l_currency_code;
            i := i + 1;
          END LOOP;

          CLOSE party_h_all_curr_stub_csr_gl ;

        -----returns are included
        ELSE
          OPEN p_h_all_curr_stub_ret_csr_gl ;

          FETCH p_h_all_curr_stub_ret_csr_gl
          INTO l_balance, l_currency_code;

          -- For each currency in the cursor

          WHILE NOT p_h_all_curr_stub_ret_csr_gl%NOTFOUND
          LOOP
            IF G_debug_flag = 'Y'
            THEN
              oe_debug_pub.add
              ( '(all) stub cursor at ' || l_currency_code
                 || ' currency with balance '
                 || l_balance || ' and bucket/length '
                 || l_bucket || '/' || l_bucket_length, 2 );
            END IF;

	    IF ( NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
               l_currency_code ,1,1),0) = 0 )
	       OR
	       ((NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                l_currency_code ,1,1),0) > 0 )
	       AND ( l_currency_code = p_limit_curr_code )
	        )
	    THEN
	      BEGIN
	        l_term :=
	        OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
	        ( p_amount                  => l_balance
	        , p_transactional_currency  => l_currency_code
	        , p_limit_currency          => p_limit_curr_code
	        , p_functional_currency     => g_functional_currency
	        , p_conversion_date         => SYSDATE
	        , p_conversion_type         => g_conversion_type
	        );
	        l_total := l_total + NVL( l_term, 0 );

	      EXCEPTION
	        WHEN  GL_CURRENCY_API.NO_RATE
                  OR  GL_CURRENCY_API.INVALID_CURRENCY
                THEN
	          oe_debug_pub.add( 'conversion exception for '
                  || l_currency_code, 1 );
	           add_error_currency( x_error_curr_tbl, l_currency_code );
  	      END;
	    ELSE
              oe_debug_pub.add(' Currency excluded from usages list ');
            END IF;

            FETCH p_h_all_curr_stub_ret_csr_gl
            INTO l_balance, l_currency_code;
            i := i + 1;
          END LOOP;

          CLOSE p_h_all_curr_stub_ret_csr_gl ;

        END IF; ----end of checking if retruns are included

------------------------ BR -------------
         IF p_credit_check_rule_rec.open_ar_days IS NOT NULL
          AND p_credit_check_rule_rec.open_ar_balance_flag = 'Y'
          AND b8 = G_INVOICES
         THEN
           OPEN party_br_h_all_curr_stub_gl ;
	   FETCH party_br_h_all_curr_stub_gl
           INTO l_br_balance, l_currency_code;
          -- For each currency in the cursor

	   WHILE NOT party_br_h_all_curr_stub_gl%NOTFOUND
           LOOP
             IF G_debug_flag = 'Y'
             THEN
	       oe_debug_pub.add
	       ( '(all) stub cursor at ' || l_currency_code
                     || ' currency with BR balance '
	        || l_BR_balance || ' and bucket/length '
                  || l_bucket || '/' || l_bucket_length, 2 );
              END IF;

	      IF ( NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                  l_currency_code ,1,1),0) = 0 )
	        OR
	       ((NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                     l_currency_code ,1,1),0) > 0 )
		AND ( l_currency_code = p_limit_curr_code )
	       )
	      THEN
	        BEGIN
	        l_term :=
	          OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
	          ( p_amount                  => l_br_balance
	          , p_transactional_currency  => l_currency_code
	          , p_limit_currency          => p_limit_curr_code
	          , p_functional_currency     => g_functional_currency
	          , p_conversion_date         => SYSDATE
	          , p_conversion_type         => g_conversion_type
	          );
	        l_total := l_total + NVL( l_term, 0 );

	      EXCEPTION
	        WHEN  GL_CURRENCY_API.NO_RATE
                     OR  GL_CURRENCY_API.INVALID_CURRENCY THEN
	          oe_debug_pub.add( 'conversion exception for '
                    || l_currency_code, 1 );
	          add_error_currency( x_error_curr_tbl, l_currency_code );
  	      END;
	    ELSE
	      oe_debug_pub.add(' Currency excluded from usages list ');
	    END IF;

            FETCH party_br_h_all_curr_stub_gl
            INTO l_br_balance, l_currency_code;
            i := i + 1;
          END LOOP;

          CLOSE party_br_h_all_curr_stub_gl ;
       END IF;
--------------------- end BR ------------
        -- for fraction of Main Bucket

        j  :=  p_binary_tbl.FIRST;
	WHILE  j  IS NOT NULL
        LOOP
 	  l_bucket         :=  p_binary_tbl(j).bucket;
	  l_bucket_length  :=  p_binary_tbl(j).bucket_length;

          IF NVL(p_credit_check_rule_rec.include_returns_flag,'N') = 'N'
          THEN
            ---returns are not included
	    OPEN party_h_all_curr_csr_global ;

	    FETCH party_h_all_curr_csr_global
            INTO l_balance, l_currency_code;

	    -- For each currency in the cursor
	    WHILE NOT party_h_all_curr_csr_global%NOTFOUND
            LOOP
              IF G_debug_flag = 'Y'
              THEN
	        oe_debug_pub.add
	        ( '(all) cursor at ' || l_currency_code
                  || ' currency with balance '
	          || l_balance || ' and bucket/length '
                  || l_bucket || '/' || l_bucket_length, 2 );
              END IF;

	      IF ( NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                  l_currency_code ,1,1),0) = 0 )
	         OR
	         ((NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                  l_currency_code ,1,1),0) > 0 )
	         AND ( l_currency_code = p_limit_curr_code )
	         )
	      THEN
	        BEGIN
	          l_term :=
	          OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
	          ( p_amount                  => l_balance
	          , p_transactional_currency  => l_currency_code
	          , p_limit_currency          => p_limit_curr_code
	          , p_functional_currency     => g_functional_currency
	          , p_conversion_date         => SYSDATE
	          , p_conversion_type         => g_conversion_type
	          );
                  l_total := l_total + NVL( l_term, 0 );

	        EXCEPTION
	          WHEN  GL_CURRENCY_API.NO_RATE  OR
                        GL_CURRENCY_API.INVALID_CURRENCY
                  THEN

   	            oe_debug_pub.add( 'conversion exception for '
                    || l_currency_code, 1 );
	            add_error_currency( x_error_curr_tbl, l_currency_code );
 	        END;
              ELSE
	        oe_debug_pub.add(' Currency excluded from usages list ');
	      END IF;

              FETCH party_h_all_curr_csr_global
              INTO l_balance, l_currency_code;

              i := i + 1;
            END LOOP;
            CLOSE party_h_all_curr_csr_global ;

          ---returns are included
          ELSE
            OPEN party_h_all_curr_ret_csr_gl ;

	    FETCH party_h_all_curr_ret_csr_gl
            INTO l_balance, l_currency_code;

	    -- For each currency in the cursor
	    --WHILE NOT party_h_all_curr_csr_global%NOTFOUND -- bug 9213846
	    WHILE NOT party_h_all_curr_ret_csr_gl%NOTFOUND
            LOOP
              IF G_debug_flag = 'Y'
              THEN
	        oe_debug_pub.add
	        ( '(all) cursor at ' || l_currency_code
                  || ' currency with balance '
	          || l_balance || ' and bucket/length '
                  || l_bucket || '/' || l_bucket_length, 2 );
              END IF;

	      IF ( NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                  l_currency_code ,1,1),0) = 0 )
	         OR
	         ((NVL(INSTRB(OE_CREDIT_CHECK_UTIL.G_excl_curr_list,
                  l_currency_code ,1,1),0) > 0 )
	         AND ( l_currency_code = p_limit_curr_code )
	         )
	      THEN
	        BEGIN
	          l_term :=
	          OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
	          ( p_amount                  => l_balance
	          , p_transactional_currency  => l_currency_code
	          , p_limit_currency          => p_limit_curr_code
	          , p_functional_currency     => g_functional_currency
	          , p_conversion_date         => SYSDATE
	          , p_conversion_type         => g_conversion_type
	          );
                  l_total := l_total + NVL( l_term, 0 );

	        EXCEPTION
	          WHEN  GL_CURRENCY_API.NO_RATE  OR
                        GL_CURRENCY_API.INVALID_CURRENCY
                  THEN

   	            oe_debug_pub.add( 'conversion exception for '
                    || l_currency_code, 1 );
	            add_error_currency( x_error_curr_tbl, l_currency_code );
 	        END;
              ELSE
	        oe_debug_pub.add(' Currency excluded from usages list ');
	      END IF;

              FETCH party_h_all_curr_ret_csr_gl
              INTO l_balance, l_currency_code;

              i := i + 1;
            END LOOP;
            CLOSE party_h_all_curr_ret_csr_gl ;

          END IF; ---end of checking if returns are included

	  j  :=  p_binary_tbl.NEXT(j);
        END LOOP; -- J
      END IF; -- global/not global
    END IF;
------------------------- end party ---------------------
--------------------------------------------------------

  END IF; -- top IF level


  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( ' -------------------------------------');
    oe_debug_pub.add( ' Final l_total ===> ' || l_total,1 );
    oe_debug_pub.add( ' Return out from  retrieve_exposure ');
  END IF;

  return NVL(l_total,0) ;

EXCEPTION

  WHEN OTHERS THEN
    oe_debug_pub.add(SQLERRM );

    IF
      FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, 'retrieve_exposure');
    END IF;

END retrieve_exposure;


--========================================================================
-- PROCEDURE : Init_Summary_Table     PUBLIC
-- PARAMETERS: x_retcode              0 success, 1 warning, 2 error
--             x_errbuf               error buffer
--             p_lock_tables          'Y' or 'N' for all transaction tables
---
-- COMMENT   : This is the concurrent program body for
--             Initialize Credit Summaries Table
--             which will repopulate oe_credit_summaries table with summarized
--             credit exposure information.
--             The p_lock_tables flag specifies if
--             the oe_order_lines_all, oe_order_headers_all,
--             oe_cash_adjustments, ar_payment_schedules_all,
--           ar_cash_receipts_all tables should all be locked in exclusive mode
--             until all of the summary data is obtained.
--             If the flag is not set to 'Y', none of the tables is locked.
-- 08-22-03    Modified to only select lines with payment type cc flag = Y
--=======================================================================--
PROCEDURE  Init_Summary_Table
( x_retcode        OUT NOCOPY VARCHAR2
, x_errbuf         OUT NOCOPY VARCHAR2
, p_lock_tables    IN  VARCHAR2
)
IS

l_return_status          VARCHAR2(1);
l_msg_count              NUMBER;
l_msg_data               VARCHAR2(100);

l_created_by             NUMBER;
l_last_updated_by        NUMBER;
l_last_update_login      NUMBER;
l_request_id             NUMBER;
l_program_application_id NUMBER;
l_program_id             NUMBER;

l_level                  NUMBER;
l_bucket_length          NUMBER;

l_ret                    BOOLEAN; --4219133
l_status                 VARCHAR2(30);
l_ont_schema             VARCHAR2(30);
l_industry               VARCHAR2(30);
l_sql_stmnt              VARCHAR2(200);
l_past_due_bal           VARCHAR2(1);
l_order_hold_bal         VARCHAR2(1);
l_freight_bal            VARCHAR2(1);
l_sql_stmnt_hwm		 VARCHAR2(500);  --8567481
l_cc_level_flag          VARCHAR2(1):='Y';

CURSOR cc_precalc_rules
IS
SELECT
  orders_on_hold_flag
, maximum_days_past_due
, nvl(incl_freight_charges_flag, 'N') incl_freight_charges_flag
FROM oe_credit_check_rules
WHERE nvl(quick_cr_check_flag, 'N') = 'Y'
AND   sysdate between nvl(start_date_active, sysdate)
                  and nvl(end_date_active, sysdate);


BEGIN

  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'In OEXVCRXB.Init_Summary_Table ', 1 );
  END IF;

-----------
-- Locks needed for periodic operation (no triggers/table handlers):
--
-- Goal: Read-consistent view accross transaction tables
-- Means: set transaction level read consistency, and only commit after all
--   changes.
--   This can result in ORA-1555: snapshot too old (rollback segment too small)
--   because the rollback segments of all transactions occurring
--   while initialization
--   is in progress are used to reconstruct old (read-consistent) data.
--   See "Multiversion Concurrency Control" in Oracle Concepts manual
--
-- (Note: When periodic initialization occurs
--  while many transactions take place,
-- the rollback segment for the initialization transaction will be hot
-- because it is accessed to reconstruct old data in the summary table.)
-- (Note: Due to the full delete, the rollback segment needs to be at least
--  twice the size of the summary table. The summary table is small however.)
--
-- Compromise: Read-consistent view per transaction tables seperately
-- Tradeoffs:  +rollback segment +(potentially) contention
--             -inconsistencies e.g. for payrisk vs. invoices atomic booking
-- Means: Nothing required
--
-- Goal: consistent state of summary table
-- Means: no commit until all balance types have been updated



-----------
-- Locks needed for init only operation:
-- Goal: No updates to transaction tables so that triggers don't interfere with
--       initialization
-- Means: Exclusive Locks on all transaction tables
-- Compromise 1: Read-consistency or compromise as for periodic operation, while
--             Triggers are switched off
-- Tradeoffs:  Turning triggers on is not guaranteed to
--    coincide with new update,
--             but quite likely
-- Compromise 2: No considerations
-- Tradeoffs:  Triggers fire during the initialization: double counting




--  TODO: Periodic operation only. Change this once we have triggers/handlers.

IF p_lock_tables  =  'Y'  THEN
--  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;


  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'starting to lock tables', 2 );
  END IF;

  LOCK TABLE oe_order_lines_all          IN EXCLUSIVE MODE;
  LOCK TABLE oe_order_headers_all        IN EXCLUSIVE MODE;
  LOCK TABLE oe_price_adjustments        IN EXCLUSIVE MODE;
  LOCK TABLE ar_payment_schedules_all    IN EXCLUSIVE MODE;
  LOCK TABLE ar_cash_receipts_all        IN EXCLUSIVE MODE;
  LOCK TABLE ar_cash_receipt_history_all IN EXCLUSIVE MODE;

  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'locked tables', 2 );
  END IF;
END IF;



l_created_by                := fnd_global.USER_ID;
l_last_updated_by           := fnd_global.USER_ID;
l_last_update_login         := fnd_global.LOGIN_ID;

l_request_id                := fnd_global.CONC_REQUEST_ID;
l_program_application_id    := fnd_global.PROG_APPL_ID;
l_program_id                := fnd_global.CONC_PROGRAM_ID;


--Bug 4219133:
--If the Profile 'OM: Preserve External Credit Balances' is set to
--Yes,application will use 'delete' and preserve external credit exposure.
--When this profile is set to 'No', application will truncate the table
--before populating the credit exposure.

  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'Value of the profile OM: Preserve External Credit Balances is  :' || NVL(FND_PROFILE.VALUE('ONT_PRESERVE_EXT_CR_BAL'),'Y'),2);
  END IF;

  --8567481 start
  l_ret := FND_INSTALLATION.get_app_info('ONT',l_status,l_industry,l_ont_schema);
  l_sql_stmnt_hwm := 'ANALYZE TABLE '|| l_ont_schema||'.oe_credit_summaries  ESTIMATE STATISTICS';
  EXECUTE IMMEDIATE l_sql_stmnt_hwm;
  --8567481 end

  IF NVL(FND_PROFILE.VALUE('ONT_PRESERVE_EXT_CR_BAL'),'Y') = 'Y' THEN
     DELETE FROM oe_credit_summaries
     WHERE       balance_type <> 18;
  ELSE
     l_ret := FND_INSTALLATION.get_app_info('ONT',l_status,l_industry,l_ont_schema); --This API is used to get schema name
     l_sql_stmnt := 'truncate table '||l_ont_schema ||'.oe_credit_summaries';
     EXECUTE IMMEDIATE l_sql_stmnt;
  END IF;

/* comment out the following code for bug 4219133
-- Do not delete external exposure data
DELETE FROM oe_credit_summaries
WHERE       balance_type <> 18;
*/


  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'purged summary table at ' || DO_TIME, 2 );
  END IF;

  -- Bug 3960616 : Scan all PreCalc CC Rules to find required Balances.
  l_past_due_bal := 'N';
  l_order_hold_bal := 'N';
  l_freight_bal := 'N';

  FOR cc_rules_rec in cc_precalc_rules LOOP

    --If Max Days Past Due set on any Rule, store Past Due Invoice Balance.

    IF cc_rules_rec.maximum_days_past_due is NOT NULL THEN
      l_past_due_bal := 'Y';
    END IF;

    -- If Orders on Hold set to be excluded on any Rule, store Hold Balances.

    IF cc_rules_rec.orders_on_hold_flag = 'Y' THEN
      l_order_hold_bal := 'Y';
    END IF;

    -- If Freight Charges set to be included on any Rule, store Freight Balances.

    IF cc_rules_rec.incl_freight_charges_flag = 'Y' THEN
      l_freight_bal := 'Y';
    END IF;

  END LOOP;

 begin
   select 'N'
     into l_cc_level_flag
     from dual
      where not exists ( select 1 from oe_credit_check_rules where credit_check_level_code = 'ORDER' and quick_cr_check_flag= 'Y');
   exception
    when others then
      l_cc_level_flag:='Y';
  end;

  oe_debug_pub.add( 'Create Past Due Invoice Balance : '||l_past_due_bal);
  oe_debug_pub.add( 'Create Orders on Hold Balance : '||l_order_hold_bal);
  oe_debug_pub.add( 'Create Freight Charges Balance : '||l_freight_bal);
  oe_debug_pub.add( 'Credit Check Level Flag : '||l_cc_level_flag);

INSERT INTO OE_INIT_CREDIT_SUMM_GTT
(line_ordered_quantity  ,
line_unit_selling_price,
order_invoice_to_org_id,
rl_amount,
rl_quantity_ordered,
order_org_id ,
order_transactional_curr_code,
line_schedule_ship_date ,
line_request_date  ,
order_request_date,
order_creation_date,
line_tax_value    ,
line_invoice_to_org_id,
line_line_category_code ,
line_invoiced_quantity  ,
line_payment_type_code ,
order_payment_type_code,
order_order_number    ,
line_line_id  ,
order_header_id,
line_header_id ,
order_cust_account_id,
order_party_id,
line_cust_account_id,
line_party_id)
select
l.ordered_quantity line_ordered_quantity,
l.unit_selling_price line_unit_selling_price,
h.invoice_to_org_id   order_invoice_to_org_id,
0  rl_amount,
0  rl_quantity_ordered,
h.org_id  order_org_id,
h.transactional_curr_code order_transactional_curr_code,
l.schedule_ship_date  line_schedule_ship_date,
l.request_date  line_request_date,
h.request_date  order_request_date,
h.creation_date  order_creation_date,
l.tax_value  line_tax_value,
l.invoice_to_org_id  line_invoice_to_org_id,
l.line_category_code  line_line_category_code,
l.invoiced_quantity  line_invoiced_quantity,
l.payment_type_code  line_payment_type_code,
h.payment_type_code  order_payment_type_code,
h.order_number  order_order_number,
l.line_id  line_line_id,
h.header_id  order_header_id,
l.header_id  line_header_id,
s.cust_account_id  order_cust_account_id,
ca.party_id   order_party_id,
s_l.cust_account_id  line_cust_account_id,
ca_l.party_id   line_party_id
from  oe_order_lines_all       l
    , oe_order_headers_all     h
    , hz_cust_site_uses_all          su
    , hz_cust_acct_sites_all         s
    , hz_cust_accounts               ca
    , hz_cust_site_uses_all          su_l
    , hz_cust_acct_sites_all         s_l
    , hz_cust_accounts               ca_l
where  h.header_id                    =  l.header_id
    AND    h.booked_flag                  =  'Y'
    AND    h.open_flag                    =  'Y'
    AND    l.open_flag                    =  'Y'
    AND    NVL( l.invoiced_quantity, 0 )  =  0
    AND    su.site_use_id                 =  h.invoice_to_org_id
    AND    su.cust_acct_site_id           =  s.cust_acct_site_id
    AND    ca.cust_account_id             =  s.cust_account_id
    AND    su_l.site_use_id                 =  l.invoice_to_org_id
    AND    su_l.cust_acct_site_id           =  s_l.cust_acct_site_id
    AND    ca_l.cust_account_id             =  s_l.cust_account_id
    AND    EXISTS
           ( SELECT  NULL
             FROM  oe_payment_types_all t
             WHERE t.credit_check_flag = 'Y'
             AND   NVL(t.org_id,-99) = NVL(h.org_id, -99)
             AND   l.header_id = h.header_id
             AND   t.payment_type_code =
                   DECODE(l.payment_type_code, NULL,
                     DECODE(h.payment_type_code, NULL, t.payment_type_code,
                            h.payment_type_code),
                          l.payment_type_code)
           )
UNION ALL
select
/*+ cardinality ( rl 10 ) leading(rl h l)  */ 0 line_ordered_quantity,
0 line_unit_selling_price,
h.invoice_to_org_id   order_invoice_to_org_id,
rl.amount  rl_amount,
rl.quantity_ordered rl_quantity_ordered,
h.org_id  order_org_id,
h.transactional_curr_code order_transactional_curr_code,
l.schedule_ship_date  line_schedule_ship_date,
l.request_date  line_request_date,
h.request_date  order_request_date,
h.creation_date  order_creation_date,
l.tax_value  line_tax_value,
l.invoice_to_org_id  line_invoice_to_org_id,
l.line_category_code  line_line_category_code,
l.invoiced_quantity  line_invoiced_quantity,
l.payment_type_code  line_payment_type_code,
h.payment_type_code  order_payment_type_code,
h.order_number  order_order_number,
l.line_id  line_line_id,
h.header_id  order_header_id,
l.header_id  line_header_id,
s.cust_account_id  order_cust_account_id,
ca.party_id   order_party_id,
s_l.cust_account_id  line_cust_account_id,
ca_l.party_id   line_party_id
from  oe_order_lines_all       l
    , oe_order_headers_all     h
    , hz_cust_site_uses_all          su
    , hz_cust_acct_sites_all         s
    , hz_cust_accounts               ca
    , hz_cust_site_uses_all          su_l
    , hz_cust_acct_sites_all         s_l
    , hz_cust_accounts               ca_l
    , ra_interface_lines_all         rl
where      h.header_id                    =  l.header_id
    AND    h.booked_flag                  =  'Y'
    AND    rl.orig_system_bill_customer_id = ca.cust_account_id
    AND    nvl(rl.interface_status, '~')  <> 'P'
    AND    rl.interface_line_context      = 'ORDER ENTRY'
    AND    rl.interface_line_attribute1   = h.order_number
    AND    rl.interface_line_attribute6   = l.line_id
    AND    NVL( l.invoiced_quantity, 0 )  <>  0
    AND    su.site_use_id                 =  h.invoice_to_org_id
    AND    su.cust_acct_site_id           =  s.cust_acct_site_id
    AND    ca.cust_account_id             =  s.cust_account_id
    AND    su_l.site_use_id                 =  l.invoice_to_org_id
    AND    su_l.cust_acct_site_id           =  s_l.cust_acct_site_id
    AND    ca_l.cust_account_id             =  s_l.cust_account_id
    AND    EXISTS
           ( SELECT  NULL
             FROM  oe_payment_types_all t
             WHERE t.credit_check_flag = 'Y'
             AND   NVL(t.org_id,-99) = NVL(h.org_id, -99)
             AND   l.header_id = h.header_id
             AND   t.payment_type_code =
                   DECODE(l.payment_type_code, NULL,
                     DECODE(h.payment_type_code, NULL, t.payment_type_code,
                            h.payment_type_code),
                          l.payment_type_code)
           );


--  For each balance type, a distinct insert statement
--  is run against the relevant OM/AR transaction tables
--  The summary table is populated with precalculated summaries
--  (the SELECT subquery of each INSERT statent) which are
--  then used in the Get_Exposure procedure to quickly
--  determine the total exposure depending on the credit
--  check rule and other parameters.


--------------------------------------------------------
--  Insert Tax Summaries into oe_credit_summaries
--  for uninvoiced orders and tax balance types at
--  header bill-to-site level


  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'Start Inserting into summary tables ',1);
  END IF;
IF l_cc_level_flag='Y' THEN
-- balance type 1
  INSERT INTO oe_credit_summaries
  ( balance
  , balance_type
  , site_use_id
  , cust_account_id
  , party_id
  , org_id
  , currency_code
  , bucket
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_application_id
  , program_id
  , program_update_date
  , request_id
  , bucket_duration
  )


  SELECT
      SUM( NVL( m.line_ordered_quantity, 0 )
         * NVL( m.line_unit_selling_price, 0 ) )
    - SUM( NVL( p.commitment_applied_amount, 0 ) )
    + SUM( NVL( m.rl_amount, 0 ))
    , G_HEADER_UNINVOICED_ORDERS
    , m.order_invoice_to_org_id
    , order_cust_account_id
    , order_party_id
    , m.order_org_id
    , m.order_transactional_curr_code
    , TO_NUMBER( TO_CHAR( NVL( m.line_schedule_ship_date,
                          NVL( m.line_request_date,
                          NVL( m.order_request_date, m.order_creation_date) ) ), 'J' ) )
    , SYSDATE
    , l_created_by
    , SYSDATE
    , l_last_updated_by
    , l_last_update_login
    , l_program_application_id
    , l_program_id
    , SYSDATE
    , l_request_id
    , 1

  FROM
      OE_INIT_CREDIT_SUMM_GTT  m
    , oe_payments                    p
  WHERE
         m.line_line_category_code           =  'ORDER'
    AND    p.header_id  (+)               =  m.line_header_id
    AND    p.line_id    (+)               =  m.line_line_id
  GROUP BY
    m.order_invoice_to_org_id
  , m.order_transactional_curr_code
  , order_cust_account_id
  , order_party_id
  , m.order_org_id
  , TO_NUMBER( TO_CHAR( NVL( m.line_schedule_ship_date,
                        NVL( m.line_request_date,
                        NVL( m.order_request_date, m.order_creation_date) ) ), 'J' ) );


  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'G_HEADER_UNINVOICED_ORDERS done at ' || DO_TIME, 2);
  END IF;
END IF; -- l_cc_level_flag

IF l_cc_level_flag='Y' THEN
-- balance type 3
  INSERT INTO OE_CREDIT_SUMMARIES
  ( balance
  , balance_type
  , site_use_id
  , cust_account_id
  , party_id
  , org_id
  , currency_code
  , bucket
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_application_id
  , program_id
  , program_update_date
  , request_id
  , bucket_duration
  )


  SELECT
      SUM( NVL( m.line_tax_value, 0 ) )
    , G_HEADER_UNINVOICED_ORDERS_TAX
    , m.order_invoice_to_org_id
    , order_cust_account_id
    , order_party_id
    , m.order_org_id
    , m.order_transactional_curr_code
    , TO_NUMBER( TO_CHAR( NVL( m.line_schedule_ship_date,
                          NVL( m.line_request_date,
                          NVL( m.order_request_date, m.order_creation_date) ) ), 'J' ) )
    , SYSDATE
    , l_created_by
    , SYSDATE
    , l_last_updated_by
    , l_last_update_login
    , l_program_application_id
    , l_program_id
    , SYSDATE
    , l_request_id
    , 1

  FROM
          OE_INIT_CREDIT_SUMM_GTT  m
  WHERE
           m.line_line_category_code          =  'ORDER'
  GROUP BY
    m.order_invoice_to_org_id
  , m.order_transactional_curr_code
  , order_cust_account_id
  , order_party_id
  , m.order_org_id
  , TO_NUMBER( TO_CHAR( NVL( m.line_schedule_ship_date,
                        NVL( m.line_request_date,
                        NVL( m.order_request_date, m.order_creation_date) ) ), 'J' ) );


  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'G_HEADER_UNINVOICED_ORDERS_TAX done at ' || DO_TIME, 2);
  END IF;
 END IF; -- l_cc_level_flag
----------------------------------------------
---------- RETURNS ---------------------------
--- For uninvoiced orders and tax returns
--- balance types at header bill-to-site level
----------------------------------------------
IF l_cc_level_flag='Y' THEN
-- balance type 23
  INSERT INTO oe_credit_summaries
  ( balance
  , balance_type
  , site_use_id
  , cust_account_id
  , party_id
  , org_id
  , currency_code
  , bucket
  , bucket_duration
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_application_id
  , program_id
  , program_update_date
  , request_id
  )


  SELECT
    - SUM( NVL( m.line_ordered_quantity, 0 )
         * NVL( m.line_unit_selling_price, 0 ) )
    + SUM( NVL( p.commitment_applied_amount, 0 ) )
    + SUM( DECODE( SIGN (NVL( m.rl_quantity_ordered, 0 )), -1, (+1), (-1) ) * NVL( m.rl_amount, 0 ) )
    , G_HEAD_RETURN_UNINV_ORDERS
    , m.order_invoice_to_org_id
    , order_cust_account_id
    , order_party_id
    , m.order_org_id
    , m.order_transactional_curr_code
    , -2
    , OE_CREDIT_EXPOSURE_PVT.G_MAX_BUCKET_LENGTH
    , sysdate
    , l_created_by
    , SYSDATE
    , l_last_updated_by
    , l_last_update_login
    , l_program_application_id
    , l_program_id
    , SYSDATE
    , l_request_id

  FROM
      OE_INIT_CREDIT_SUMM_GTT   m
    , oe_payments                    p
  WHERE
           m.line_line_category_code           =  'RETURN'
    AND    p.header_id  (+)               =  m.line_header_id
    AND    p.line_id    (+)               =  m.line_line_id
  GROUP BY
    m.order_invoice_to_org_id
  , m.order_transactional_curr_code
  , order_cust_account_id
  , order_party_id
  , m.order_org_id;


  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'G_HEAD_RETURN_UNINV_ORDERS done at ' || DO_TIME, 2);
  END IF;
END IF; -- l_cc_level_flag

IF l_cc_level_flag='Y' THEN
-- balance type 25
  INSERT INTO OE_CREDIT_SUMMARIES
  ( balance
  , balance_type
  , site_use_id
  , cust_account_id
  , party_id
  , org_id
  , currency_code
  , bucket
  , bucket_duration
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_application_id
  , program_id
  , program_update_date
  , request_id
  )


  SELECT
     - SUM( NVL( m.line_tax_value, 0 ) )
    , G_HEAD_RETURN_UNINV_ORD_TAX
    , m.order_invoice_to_org_id
    , order_cust_account_id
    , order_party_id
    , m.order_org_id
    , m.order_transactional_curr_code
    , -2
    , OE_CREDIT_EXPOSURE_PVT.G_MAX_BUCKET_LENGTH
    , sysdate
    , l_created_by
    , sysdate
    , l_last_updated_by
    , l_last_update_login
    , l_program_application_id
    , l_program_id
    , SYSDATE
    , l_request_id

  FROM
         OE_INIT_CREDIT_SUMM_GTT   m
  WHERE
           m.line_line_category_code          =  'RETURN'
  GROUP BY
    m.order_invoice_to_org_id
  , m.order_transactional_curr_code
  , order_cust_account_id
  , order_party_id
  , m.order_org_id;

  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'G_HEAD_RETURN_UNINV_ORD_TAX done at ' || DO_TIME, 2);
  END IF;
END IF; -- l_cc_level_flag

--------------------------
--  Line Uninvoiced Orders
--------------------------
--  Note this is identical code except that
--  h.invoice_to_org_id is replaced with l.invoice_to_org_id

-- balance type 2

  INSERT INTO OE_CREDIT_SUMMARIES
  ( balance
  , balance_type
  , site_use_id
  , cust_account_id
  , party_id
  , org_id
  , currency_code
  , bucket
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_application_id
  , program_id
  , program_update_date
  , request_id
  , bucket_duration
  )

  SELECT
    SUM( NVL( m.line_ordered_quantity, 0 )
       * NVL( m.line_unit_selling_price, 0 )
       )
    - SUM( NVL( p.commitment_applied_amount, 0 ) )
    + SUM( NVL( m.rl_amount, 0 ))
    , G_LINE_UNINVOICED_ORDERS
    , m.line_invoice_to_org_id
    , line_cust_account_id
    , line_party_id
    , m.order_org_id
    , m.order_transactional_curr_code
    , TO_NUMBER( TO_CHAR( NVL( m.line_schedule_ship_date,
                          NVL( m.line_request_date,
                          NVL( m.order_request_date, m.order_creation_date) ) ), 'J' ) )
    , SYSDATE
    , l_created_by
    , SYSDATE
    , l_last_updated_by
    , l_last_update_login
    , l_program_application_id
    , l_program_id
    , SYSDATE
    , l_request_id
    , 1

  FROM
         OE_INIT_CREDIT_SUMM_GTT   m
       , oe_payments                    p
  WHERE
          m.line_line_category_code           =  'ORDER'
    AND    p.header_id  (+)               =  m.line_header_id
    AND    p.line_id    (+)               =  m.line_line_id
  GROUP BY
     m.line_invoice_to_org_id
   , m.order_transactional_curr_code
   , line_cust_account_id
   , line_party_id
   , m.order_org_id
   , TO_NUMBER( TO_CHAR( NVL( m.line_schedule_ship_date,
                         NVL( m.line_request_date,
                         NVL( m.order_request_date, m.order_creation_date) ) ), 'J' ) );


  IF G_debug_flag = 'Y'
  THEN
   oe_debug_pub.add( 'G_LINE_UNINVOICED_ORDERS done at ' || DO_TIME, 2);
  END IF;

-- balance type 4

  INSERT INTO OE_CREDIT_SUMMARIES
  ( balance
  , balance_type
  , site_use_id
  , cust_account_id
  , party_id
  , org_id
  , currency_code
  , bucket
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_application_id
  , program_id
  , program_update_date
  , request_id
  , bucket_duration
  )


  SELECT
    SUM( NVL( m.line_tax_value, 0 ) )
    , G_LINE_UNINVOICED_ORDERS_TAX
    , m.line_invoice_to_org_id
    , line_cust_account_id
    , line_party_id
    , m.order_org_id
    , m.order_transactional_curr_code
    , TO_NUMBER( TO_CHAR( NVL( m.line_schedule_ship_date,
                          NVL( m.line_request_date,
                          NVL( m.order_request_date, m.order_creation_date) ) ), 'J' ) )
    , SYSDATE
    , l_created_by
    , SYSDATE
    , l_last_updated_by
    , l_last_update_login
    , l_program_application_id
    , l_program_id
    , SYSDATE
    , l_request_id
    , 1

  FROM
      OE_INIT_CREDIT_SUMM_GTT   m
  WHERE
           m.line_line_category_code           =  'ORDER'
  GROUP BY
     m.line_invoice_to_org_id
   , m.order_transactional_curr_code
   , line_cust_account_id
   , line_party_id
   , m.order_org_id
   , TO_NUMBER( TO_CHAR( NVL( m.line_schedule_ship_date,
                         NVL( m.line_request_date,
                         NVL( m.order_request_date, m.order_creation_date) ) ), 'J' ) );


  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'G_LINE_UNINVOICED_ORDERS_TAX done at ' || DO_TIME, 2);
  END IF;

----------------------------------
------ RETURNS--------------------
--  Line Uninvoiced Orders returns
----------------------------------
--  Note this is identical code except that
--  h.invoice_to_org_id is replaced with l.invoice_to_org_id

-- balance type 24

  INSERT INTO OE_CREDIT_SUMMARIES
  ( balance
  , balance_type
  , site_use_id
  , cust_account_id
  , party_id
  , org_id
  , currency_code
  , bucket
  , bucket_duration
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_application_id
  , program_id
  , program_update_date
  , request_id
  )


  SELECT
    - SUM( NVL(m.line_ordered_quantity, 0 )
         * NVL( m.line_unit_selling_price, 0 )
         )
    + SUM( NVL( p.commitment_applied_amount, 0 ) )
    + SUM( DECODE( SIGN (NVL( m.rl_quantity_ordered, 0 )), -1, (+1), (-1) ) * NVL( m.rl_amount, 0 ) )
    , G_LINE_RETURN_UNINV_ORDERS
    , m.line_invoice_to_org_id
    , line_cust_account_id
    , line_party_id
    , m.order_org_id
    , m.order_transactional_curr_code
    , -2
    , OE_CREDIT_EXPOSURE_PVT.G_MAX_BUCKET_LENGTH
    , sysdate
    , l_created_by
    , sysdate
    , l_last_updated_by
    , l_last_update_login
    , l_program_application_id
    , l_program_id
    , SYSDATE
    , l_request_id

  FROM
         OE_INIT_CREDIT_SUMM_GTT   m
       , oe_payments                    p
  WHERE
           m.line_line_category_code           =  'RETURN'
    AND    p.header_id  (+)               =  m.line_header_id
    AND    p.line_id    (+)               =  m.line_line_id
  GROUP BY
     m.line_invoice_to_org_id
   , m.order_transactional_curr_code
   , line_cust_account_id
   , line_party_id
   , m.order_org_id;


  IF G_debug_flag = 'Y'
  THEN
   oe_debug_pub.add( 'G_LINE_RETURN_UNINV_ORDERS done at ' || DO_TIME, 2);
  END IF;

-- balance type 26

  INSERT INTO OE_CREDIT_SUMMARIES
  ( balance
  , balance_type
  , site_use_id
  , cust_account_id
  , party_id
  , org_id
  , currency_code
  , bucket
  , bucket_duration
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_application_id
  , program_id
  , program_update_date
  , request_id
  )


  SELECT
    - SUM( NVL(m.line_tax_value, 0 ) )
    , G_LINE_RETURN_UNINV_ORD_TAX
    , m.line_invoice_to_org_id
    , line_cust_account_id
    , line_party_id
    , m.order_org_id
    , m.order_transactional_curr_code
    , -2
    , OE_CREDIT_EXPOSURE_PVT.G_MAX_BUCKET_LENGTH
    , sysdate
    , l_created_by
    , sysdate
    , l_last_updated_by
    , l_last_update_login
    , l_program_application_id
    , l_program_id
    , SYSDATE
    , l_request_id

  FROM
	OE_INIT_CREDIT_SUMM_GTT   m
  WHERE
           m.line_line_category_code           =  'RETURN'
  GROUP BY
     m.line_invoice_to_org_id
   , m.order_transactional_curr_code
   , line_cust_account_id
   , line_party_id
   , m.order_org_id;



  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'G_LINE_RETURN_UNINV_ORD_TAX done at ' || DO_TIME, 2);
  END IF;

-- Bug 4219133 : Insert Freight Balances only if Freight Charges to be Included
IF l_freight_bal = 'Y' THEN
--------------------------
--  Line Freight
--------------------------

-- balance type 6
  INSERT INTO OE_CREDIT_SUMMARIES
  ( balance
  , balance_type
  , site_use_id
  , cust_account_id
  , party_id
  , org_id
  , currency_code
  , bucket
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_application_id
  , program_id
  , program_update_date
  , request_id
  , bucket_duration
  )

  SELECT
      SUM
      ( DECODE( p.credit_or_charge_flag, 'C', (-1), (+1) )
      * DECODE( p.arithmetic_operator, 'LUMPSUM',			--bug 4295298
                p.operand, (m.line_ordered_quantity * p.adjusted_amount))
      )
      + SUM( NVL( m.rl_amount, 0 ))
    , G_LINE_UNINVOICED_FREIGHT
    , m.line_invoice_to_org_id
    , line_cust_account_id
    , line_party_id
    , m.order_org_id
    , m.order_transactional_curr_code
    , TO_NUMBER( TO_CHAR( NVL( m.line_schedule_ship_date,
                          NVL( m.line_request_date,
                          NVL( m.order_request_date, m.order_creation_date) ) ), 'J' ) )
    , SYSDATE
    , l_created_by
    , SYSDATE
    , l_last_updated_by
    , l_last_update_login
    , l_program_application_id
    , l_program_id
    , SYSDATE
    , l_request_id
    , 1

  FROM
      OE_INIT_CREDIT_SUMM_GTT  m,
      oe_price_adjustments     p
  WHERE
         p.line_id             =  m.line_line_id
    AND  p.header_id           =  m.line_header_id
    AND  p.header_id           =  m.order_header_id
    AND  m.line_line_category_code           =  'ORDER'
    AND  p.applied_flag        =  'Y'
    AND  p.list_line_type_code =  'FREIGHT_CHARGE'
    AND  NVL( p.invoiced_flag, 'N' )  =  'N'
  GROUP BY
      m.line_invoice_to_org_id
    , m.order_transactional_curr_code
    , line_cust_account_id
    , line_party_id
    , m.order_org_id
    , TO_NUMBER( TO_CHAR( NVL( m.line_schedule_ship_date,
                          NVL( m.line_request_date,
                          NVL( m.order_request_date, m.order_creation_date) ) ), 'J' ) );


  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'G_LINE_UNINVOICED_FREIGHT done at ' || DO_TIME, 2);
  END IF;
END IF; -- l_freight_bal

--------------------------
------- RETURNS-----------
--------------------------
--  Line Freight
--------------------------

-- balance type 28
  INSERT INTO OE_CREDIT_SUMMARIES
  ( balance
  , balance_type
  , site_use_id
  , cust_account_id
  , party_id
  , org_id
  , currency_code
  , bucket
  , bucket_duration
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_application_id
  , program_id
  , program_update_date
  , request_id
  )

  SELECT
     SUM
      ( DECODE( p.credit_or_charge_flag, 'C', (-1), (+1) )
      * DECODE( p.arithmetic_operator, 'LUMPSUM',			--bug 4295298
                p.operand, (m.line_ordered_quantity * p.adjusted_amount))
      )
      + SUM( NVL( m.rl_amount, 0 ))
    , G_LINE_RETURN_UNINV_FREIGHT
    , m.line_invoice_to_org_id
    , line_cust_account_id
    , line_party_id
    , m.order_org_id
    , m.order_transactional_curr_code
    , -2
    , OE_CREDIT_EXPOSURE_PVT.G_MAX_BUCKET_LENGTH
    , sysdate
    , l_created_by
    , sysdate
    , l_last_updated_by
    , l_last_update_login
    , l_program_application_id
    , l_program_id
    , SYSDATE
    , l_request_id

  FROM
      oe_price_adjustments     p,
      OE_INIT_CREDIT_SUMM_GTT    m
  WHERE
         p.line_id             =  m.line_line_id
    AND  p.header_id           =  m.line_header_id
    AND  p.header_id           =  m.order_header_id
    AND  m.line_line_category_code           =  'RETURN'
    AND  p.applied_flag        =  'Y'
    AND  p.list_line_type_code =  'FREIGHT_CHARGE'
    AND  NVL( p.invoiced_flag, 'N' )  =  'N'
  GROUP BY
      m.line_invoice_to_org_id
    , m.order_transactional_curr_code
    , line_cust_account_id
    , line_party_id
    , m.order_org_id;



  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'G_LINE_RETURN_UNINV_FREIGHT done at ' || DO_TIME, 2);
  END IF;

-- Bug 4219133 : Insert Freight Balances only if Freight Charges to be Included.

IF l_freight_bal = 'Y' THEN

--------------------------
--  Header Freight
--------------------------
IF l_cc_level_flag='Y' THEN
-- balance type 5

  INSERT INTO OE_CREDIT_SUMMARIES
  ( balance
  , balance_type
  , site_use_id
  , cust_account_id
  , party_id
  , org_id
  , currency_code
  , bucket
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_application_id
  , program_id
  , program_update_date
  , request_id
  , bucket_duration
  )

SELECT
      SUM
      ( DECODE( p.credit_or_charge_flag, 'C', (-1), (+1) )
      * DECODE( p.arithmetic_operator, 'LUMPSUM',			--bug 4295298
                p.operand, (m.line_ordered_quantity * p.adjusted_amount))
      )
      + SUM( NVL( m.rl_amount, 0 ))
    , G_HEADER_UNINVOICED_FREIGHT
    , m.order_invoice_to_org_id
    , order_cust_account_id
    , order_party_id
    , m.order_org_id
    , m.order_transactional_curr_code
    , TO_NUMBER( TO_CHAR( NVL( m.line_schedule_ship_date,
                          NVL( m.line_request_date,
                          NVL( m.order_request_date, m.order_creation_date) ) ), 'J' ) )
    , SYSDATE
    , l_created_by
    , SYSDATE
    , l_last_updated_by
    , l_last_update_login
    , l_program_application_id
    , l_program_id
    , SYSDATE
    , l_request_id
    , 1

FROM   oe_price_adjustments     p,
      OE_INIT_CREDIT_SUMM_GTT    m
WHERE
       p.line_id             =  m.line_line_id
  AND  p.header_id           =  m.line_header_id
  AND  p.header_id           =  m.order_header_id
  AND  m.line_line_category_code           =  'ORDER'
  AND  p.applied_flag                 =  'Y'
  AND  p.list_line_type_code          =  'FREIGHT_CHARGE'
  AND  NVL( p.invoiced_flag, 'N' )    =  'N'
GROUP BY
    m.order_invoice_to_org_id
  , m.order_transactional_curr_code
  , order_cust_account_id
  , order_party_id
  , m.order_org_id
  , TO_NUMBER( TO_CHAR( NVL( m.line_schedule_ship_date,
                        NVL( m.line_request_date,
                        NVL( m.order_request_date, m.order_creation_date) ) ), 'J' ) );


  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'G_HEADER_UNINVOICED_FREIGHT done at ' || DO_TIME, 2 );
  END IF;
END IF; -- l_cc_level_flag
END IF;  -- l_freight_bal

--------------------------------
--------- RETURNS --------------
--  Header Freight
--------------------------------
IF l_cc_level_flag='Y' THEN
-- balance type 27

  INSERT INTO OE_CREDIT_SUMMARIES
  ( balance
  , balance_type
  , site_use_id
  , cust_account_id
  , party_id
  , org_id
  , currency_code
  , bucket
  , bucket_duration
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_application_id
  , program_id
  , program_update_date
  , request_id
  )


SELECT
      SUM
      ( DECODE( p.credit_or_charge_flag, 'C', (-1), (+1) )
      * DECODE( p.arithmetic_operator, 'LUMPSUM',			--bug 4295298
                p.operand, (m.line_ordered_quantity * p.adjusted_amount))
      )
      + SUM( NVL( m.rl_amount, 0 ))
    , G_HEAD_RETURN_UNINV_FREIGHT
    , m.order_invoice_to_org_id
    , order_cust_account_id
    , order_party_id
    , m.order_org_id
    , m.order_transactional_curr_code
    , -2
    , OE_CREDIT_EXPOSURE_PVT.G_MAX_BUCKET_LENGTH
    , sysdate
    , l_created_by
    , sysdate
    , l_last_updated_by
    , l_last_update_login
    , l_program_application_id
    , l_program_id
    , SYSDATE
    , l_request_id

FROM   oe_price_adjustments     p,
      OE_INIT_CREDIT_SUMM_GTT    m
WHERE
       p.line_id             =  m.line_line_id
  AND  p.header_id           =  m.line_header_id
  AND  p.header_id           =  m.order_header_id
  AND  m.line_line_category_code           =  'RETURN'
  AND  p.applied_flag                 =  'Y'
  AND  p.list_line_type_code          =  'FREIGHT_CHARGE'
  AND  NVL( p.invoiced_flag, 'N' )    =  'N'
GROUP BY
    m.order_invoice_to_org_id
  , m.order_transactional_curr_code
  , order_cust_account_id
  , order_party_id
  , m.order_org_id;


  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'G_HEAD_RETURN_UNINV_FREIGHT done at ' || DO_TIME, 2 );
  END IF;
END IF; -- l_cc_level_flag
-- Bug 4219133 : Insert Freight Balances only if Freight Charges to be Included.

IF l_freight_bal = 'Y' THEN
--------------------------
--  Header + Line Fright Part 2
--------------------------
--  This cost is specified at the order header and thus
--  the bill-to site to be used is always the header bill-to site.
--  Therefore for both line and header bill-to site level exposures,
--  this same balance type summary is added

-- balance type 7

  INSERT INTO OE_CREDIT_SUMMARIES
  ( balance
  , balance_type
  , site_use_id
  , cust_account_id
  , party_id
  , org_id
  , currency_code
  , bucket
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_application_id
  , program_id
  , program_update_date
  , request_id
  , bucket_duration
  )


SELECT
      SUM( DECODE( p.credit_or_charge_flag, 'C', (-1), (+1) ) * p.operand )
    , G_HEADER_AND_LINE_FREIGHT
    , h.invoice_to_org_id
    , s.cust_account_id
    , ca.party_id
    , h.org_id
    , h.transactional_curr_code
    , TO_NUMBER( TO_CHAR( NVL( h.request_date, h.creation_date ), 'J' ) )
    , SYSDATE
    , l_created_by
    , SYSDATE
    , l_last_updated_by
    , l_last_update_login
    , l_program_application_id
    , l_program_id
    , SYSDATE
    , l_request_id
    , 1

FROM
    oe_price_adjustments      p
  , oe_order_headers_all      h
  , hz_cust_site_uses_all     su
  , hz_cust_acct_sites_all    s
  , hz_cust_accounts          ca
WHERE
       p.line_id IS NULL
  AND  p.header_id           =  h.header_id
  AND  h.order_category_code IN ('ORDER','MIXED')
  AND  h.open_flag           =  'Y'
  AND  h.booked_flag         =  'Y'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code = 'FREIGHT_CHARGE'
  AND  NVL( p.invoiced_flag, 'N' )  =  'N'
  AND  su.site_use_id        =  h.invoice_to_org_id
  AND  su.cust_acct_site_id  =  s.cust_acct_site_id
  AND  ca.cust_account_id  =  s.cust_account_id
  AND  EXISTS
         ( SELECT  NULL
             FROM  oe_payment_types_all t,
                   oe_order_lines_all l
             WHERE t.credit_check_flag = 'Y'
             AND   NVL(t.org_id,-99) = NVL(h.org_id, -99)
             AND   l.header_id = h.header_id
             AND   t.payment_type_code =
                   DECODE(l.payment_type_code, NULL,
                     DECODE(h.payment_type_code, NULL, t.payment_type_code,
                            h.payment_type_code),
                          l.payment_type_code)
         )
GROUP BY
      h.invoice_to_org_id
    , h.transactional_curr_code
    , s.cust_account_id
    , ca.party_id
    , h.org_id
    , TO_NUMBER( TO_CHAR( NVL( h.request_date, h.creation_date ), 'J' ) )
UNION ALL  --bug# 2714553
SELECT
      SUM( NVL( rl.amount, 0 ))
    , G_HEADER_AND_LINE_FREIGHT
    , h.invoice_to_org_id
    , s.cust_account_id
    , ca.party_id
    , h.org_id
    , h.transactional_curr_code
    , TO_NUMBER( TO_CHAR( NVL( h.request_date, h.creation_date ), 'J' ) )
    , SYSDATE
    , l_created_by
    , SYSDATE
    , l_last_updated_by
    , l_last_update_login
    , l_program_application_id
    , l_program_id
    , SYSDATE
    , l_request_id
    , 1

FROM
    oe_price_adjustments      p
  , oe_order_headers_all      h
  , hz_cust_site_uses_all     su
  , hz_cust_acct_sites_all    s
  , hz_cust_accounts          ca
  , ra_interface_lines_all    rl
WHERE
       p.line_id IS NULL
  AND  p.header_id           =  h.header_id
  AND  h.order_category_code IN ('ORDER','MIXED')
  AND  h.booked_flag         =  'Y'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code = 'FREIGHT_CHARGE'
  AND  NVL( p.invoiced_flag, 'N' )  =  'Y'
  AND  su.site_use_id        =  h.invoice_to_org_id
  AND  su.cust_acct_site_id  =  s.cust_acct_site_id
  AND  ca.cust_account_id  =  s.cust_account_id
  AND  rl.orig_system_bill_customer_id = ca.cust_account_id
  AND  nvl(rl.interface_status, '~')  <> 'P'
  AND  rl.interface_line_context      = 'ORDER ENTRY'
  AND  rl.interface_line_attribute1   = h.order_number
  AND  rl.interface_line_attribute6   = p.price_adjustment_id
  AND  EXISTS
         ( SELECT  NULL
             FROM  oe_payment_types_all t,
                   oe_order_lines_all l
             WHERE t.credit_check_flag = 'Y'
             AND   NVL(t.org_id,-99) = NVL(h.org_id, -99)
             AND   l.header_id = h.header_id
             AND   t.payment_type_code =
                   DECODE(l.payment_type_code, NULL,
                     DECODE(h.payment_type_code, NULL, t.payment_type_code,
                            h.payment_type_code),
                          l.payment_type_code)
         )
GROUP BY
      h.invoice_to_org_id
    , h.transactional_curr_code
    , s.cust_account_id
    , ca.party_id
    , h.org_id
    , TO_NUMBER( TO_CHAR( NVL( h.request_date, h.creation_date ), 'J' ) )
;



  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'G_HEADER_AND_LINE_FREIGHT done at ' || DO_TIME, 2 );
  END IF;
END IF;  -- l_freight_bal

-------------------------------
----- RETURNS -----------------
--  Header + Line Freight Part 2
-------------------------------
--  This cost is specified at the order header and thus
--  the bill-to site to be used is always the header bill-to site.
--  Therefore for both line and header bill-to site level exposures,
--  this same balance type summary is added

-- balance type 29

  INSERT INTO OE_CREDIT_SUMMARIES
  ( balance
  , balance_type
  , site_use_id
  , cust_account_id
  , party_id
  , org_id
  , currency_code
  , bucket
  , bucket_duration
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_application_id
  , program_id
  , program_update_date
  , request_id
  )


SELECT
      SUM( DECODE( p.credit_or_charge_flag, 'C', (-1), (+1) ) * p.operand )
    , G_HEAD_LINE_RETURN_FREIGHT
    , h.invoice_to_org_id
    , s.cust_account_id
    , ca.party_id
    , h.org_id
    , h.transactional_curr_code
    , -2
    , OE_CREDIT_EXPOSURE_PVT.G_MAX_BUCKET_LENGTH
    , sysdate
    , l_created_by
    , sysdate
    , l_last_updated_by
    , l_last_update_login
    , l_program_application_id
    , l_program_id
    , SYSDATE
    , l_request_id

FROM
    oe_price_adjustments      p
  , oe_order_headers_all      h
  , hz_cust_site_uses_all     su
  , hz_cust_acct_sites_all    s
  , hz_cust_accounts          ca
WHERE
       p.line_id IS NULL
  AND  p.header_id           =  h.header_id
  AND  h.order_category_code ='RETURN'
  AND  h.open_flag           =  'Y'
  AND  h.booked_flag         =  'Y'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code = 'FREIGHT_CHARGE'
  AND  NVL( p.invoiced_flag, 'N' )  =  'N'
  AND  su.site_use_id        =  h.invoice_to_org_id
  AND  su.cust_acct_site_id  =  s.cust_acct_site_id
  AND  ca.cust_account_id    =  s.cust_account_id
  AND  EXISTS
         ( SELECT  NULL
             FROM  oe_payment_types_all t,
                   oe_order_lines_all l
             WHERE t.credit_check_flag = 'Y'
             AND   NVL(t.org_id,-99) = NVL(h.org_id, -99)
             AND   l.header_id = h.header_id
             AND   t.payment_type_code =
                   DECODE(l.payment_type_code, NULL,
                     DECODE(h.payment_type_code, NULL, t.payment_type_code,
                            h.payment_type_code),
                          l.payment_type_code)
         )
GROUP BY
      h.invoice_to_org_id
    , h.transactional_curr_code
    , s.cust_account_id
    , ca.party_id
    , h.org_id
UNION ALL  --bug# 2714553
SELECT
      SUM( NVL( rl.amount, 0 ))
    , G_HEAD_LINE_RETURN_FREIGHT
    , h.invoice_to_org_id
    , s.cust_account_id
    , ca.party_id
    , h.org_id
    , h.transactional_curr_code
    , -2
    , OE_CREDIT_EXPOSURE_PVT.G_MAX_BUCKET_LENGTH
    , sysdate
    , l_created_by
    , sysdate
    , l_last_updated_by
    , l_last_update_login
    , l_program_application_id
    , l_program_id
    , SYSDATE
    , l_request_id

FROM
    oe_price_adjustments      p
  , oe_order_headers_all      h
  , hz_cust_site_uses_all     su
  , hz_cust_acct_sites_all    s
  , hz_cust_accounts          ca
  , ra_interface_lines_all    rl
WHERE
       p.line_id IS NULL
  AND  p.header_id           =  h.header_id
  AND  h.order_category_code ='RETURN'
  AND  h.booked_flag         =  'Y'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code = 'FREIGHT_CHARGE'
  AND  NVL( p.invoiced_flag, 'N' )  =  'Y'
  AND  su.site_use_id        =  h.invoice_to_org_id
  AND  su.cust_acct_site_id  =  s.cust_acct_site_id
  AND  ca.cust_account_id    =  s.cust_account_id
  AND  rl.orig_system_bill_customer_id = ca.cust_account_id
  AND  nvl(rl.interface_status, '~')  <> 'P'
  AND  rl.interface_line_context      = 'ORDER ENTRY'
  AND  rl.interface_line_attribute1   = h.order_number
  AND  rl.interface_line_attribute6   = p.price_adjustment_id
  AND  EXISTS
         ( SELECT  NULL
             FROM  oe_payment_types_all t,
                   oe_order_lines_all l
             WHERE t.credit_check_flag = 'Y'
             AND   NVL(t.org_id,-99) = NVL(h.org_id, -99)
             AND   l.header_id = h.header_id
             AND   t.payment_type_code =
                   DECODE(l.payment_type_code, NULL,
                     DECODE(h.payment_type_code, NULL, t.payment_type_code,
                            h.payment_type_code),
                          l.payment_type_code)
         )
GROUP BY
      h.invoice_to_org_id
    , h.transactional_curr_code
    , s.cust_account_id
    , ca.party_id
    , h.org_id
;



  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'G_HEAD_LINE_RETURN_FREIGHT done at ' || DO_TIME, 2 );
  END IF;

--------------------------
--  Holds
--------------------------
--  This is a repeat of all the order balance types, but this
--  time qualified by existing holds.
--  In the Get_Exposure procedure, this negative balance
--  is added if the Include Orders on Hold box is checked in the credit
--  check rule

-- Bug 4219133:Insert Hold Balances only if Orders on Hold Need to be Excluded.

IF l_order_hold_bal = 'Y' THEN

IF l_cc_level_flag='Y' THEN
-- balance type 10

  INSERT INTO OE_CREDIT_SUMMARIES
  ( balance
  , balance_type
  , site_use_id
  , cust_account_id
  , party_id
  , org_id
  , currency_code
  , bucket
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_application_id
  , program_id
  , program_update_date
  , request_id
  , bucket_duration
  )


  SELECT
    - SUM( NVL( m.line_ordered_quantity, 0 )
         * NVL( m.line_unit_selling_price, 0 ) )
    + SUM( NVL( p.commitment_applied_amount, 0 ) )
    , G_ORDER_HOLDS
    , m.order_invoice_to_org_id
    , order_cust_account_id
    , order_party_id
    , m.order_org_id
    , m.order_transactional_curr_code
    , TO_NUMBER( TO_CHAR( NVL( m.line_schedule_ship_date,
                          NVL( m.line_request_date,
                          NVL( m.order_request_date, m.order_creation_date) ) ), 'J' ) )
    , SYSDATE
    , l_created_by
    , SYSDATE
    , l_last_updated_by
    , l_last_update_login
    , l_program_application_id
    , l_program_id
    , SYSDATE
    , l_request_id
    , 1

  FROM
      OE_INIT_CREDIT_SUMM_GTT    m,
      oe_payments                    p
  WHERE
           m.line_line_category_code           =  'ORDER'
    AND    p.header_id  (+)               =  m.line_header_id
    AND    p.line_id    (+)               =  m.line_line_id
    AND    EXISTS
           ( SELECT  1
             FROM
                     oe_order_holds_all  oh
             WHERE
                     oh.header_id         =  m.order_header_id
             AND   ( oh.line_id           =  m.line_line_id
                     OR  oh.line_id IS NULL
                   )
             AND     oh.hold_release_id  IS NULL
           )
  GROUP BY
    m.order_invoice_to_org_id
  , m.order_transactional_curr_code
  , order_cust_account_id
  , order_party_id
  , m.order_org_id
  , TO_NUMBER( TO_CHAR( NVL( m.line_schedule_ship_date,
                        NVL( m.line_request_date,
                        NVL( m.order_request_date, m.order_creation_date) ) ), 'J' ) )
  ;



  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'G_ORDER_HOLDS done at ' || DO_TIME, 2 );
  END IF;
END IF; -- l_cc_level_flag

IF l_cc_level_flag='Y' THEN
-- balance type 13
  INSERT INTO OE_CREDIT_SUMMARIES
  ( balance
  , balance_type
  , site_use_id
  , cust_account_id
  , party_id
  , org_id
  , currency_code
  , bucket
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_application_id
  , program_id
  , program_update_date
  , request_id
  , bucket_duration
  )


  SELECT
    - SUM( NVL( m.line_tax_value, 0 ) )
    , G_ORDER_TAX_HOLDS
    , m.order_invoice_to_org_id
    , order_cust_account_id
    , order_party_id
    , m.order_org_id
    , m.order_transactional_curr_code
    , TO_NUMBER( TO_CHAR( NVL( m.line_schedule_ship_date,
                          NVL( m.line_request_date,
                          NVL( m.order_request_date, m.order_creation_date) ) ), 'J' ) )
    , SYSDATE
    , l_created_by
    , SYSDATE
    , l_last_updated_by
    , l_last_update_login
    , l_program_application_id
    , l_program_id
    , SYSDATE
    , l_request_id
    , 1

  FROM
      OE_INIT_CREDIT_SUMM_GTT    m
  WHERE
  	   m.line_line_category_code           =  'ORDER'
  AND    EXISTS
            ( SELECT  1
              FROM    oe_order_holds_all  oh
              WHERE   oh.header_id          =  m.order_header_id
              AND    (  oh.line_id        =  m.line_line_id
                      OR  oh.line_id IS NULL
                     )
              AND     oh.hold_release_id  IS NULL
            )
  GROUP BY
    m.order_invoice_to_org_id
  , m.order_transactional_curr_code
  , order_cust_account_id
  , order_party_id
  , m.order_org_id
  , TO_NUMBER( TO_CHAR( NVL( m.line_schedule_ship_date,
                        NVL( m.line_request_date,
                        NVL( m.order_request_date, m.order_creation_date) ) ), 'J' ) )
  ;


  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'G_ORDER_TAX_HOLDS done at ' || DO_TIME, 2 );
  END IF;
END IF; -- l_cc_level_flag
END IF; -- IF l_order_hold_bal

-------------------------------
---------- RETURNS-------------
--  Return Holds --------------
-------------------------------
--  This is a repeat of all the order balance types, but this
--  time qualified by existing holds.
--  In the Get_Exposure procedure, this negative balance
--  is added if the Include Orders on Hold box is checked in the credit
--  check rule

IF l_cc_level_flag='Y' THEN
-- balance type 30
  INSERT INTO OE_CREDIT_SUMMARIES
  ( balance
  , balance_type
  , site_use_id
  , cust_account_id
  , party_id
  , org_id
  , currency_code
  , bucket
  , bucket_duration
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_application_id
  , program_id
  , program_update_date
  , request_id
  )


  SELECT
    SUM( NVL( l.ordered_quantity, 0 )
         * NVL( l.unit_selling_price, 0 ) )
    - SUM( NVL( p.commitment_applied_amount, 0 ) )
    , G_ORDER_RETURN_HOLDS
    , h.invoice_to_org_id
    , s.cust_account_id
    , ca.party_id
    , h.org_id
    , h.transactional_curr_code
    , -2
    , OE_CREDIT_EXPOSURE_PVT.G_MAX_BUCKET_LENGTH
    , sysdate
    , l_created_by
    , sysdate
    , l_last_updated_by
    , l_last_update_login
    , l_program_application_id
    , l_program_id
    , SYSDATE
    , l_request_id

  FROM
         oe_order_lines_all             l
       , oe_order_headers_all           h
       , oe_payments                    p
       , hz_cust_site_uses_all          su
       , hz_cust_acct_sites_all         s
       , hz_cust_accounts               ca
  WHERE
           h.header_id                    =  l.header_id

    AND    h.booked_flag                  =  'Y'
    AND    h.open_flag                    =  'Y'
    AND    l.open_flag                    =  'Y'
    AND    l.line_category_code           =  'RETURN'
    AND    NVL( l.invoiced_quantity, 0 )  =  0

    AND    p.header_id  (+)               =  l.header_id
    AND    p.line_id    (+)               =  l.line_id

    AND    su.site_use_id                 =  h.invoice_to_org_id
    AND    su.cust_acct_site_id           =  s.cust_acct_site_id
    AND    ca.cust_account_id             =  s.cust_account_id
    AND    EXISTS
            ( SELECT  1
              FROM    oe_order_holds_all  oh
              WHERE   oh.header_id          =  h.header_id
              AND    (  oh.line_id        =  l.line_id
                      OR  oh.line_id IS NULL
                     )
              AND     oh.hold_release_id  IS NULL
            )
    AND    EXISTS
           ( SELECT  NULL
             FROM  oe_payment_types_all t
             WHERE t.credit_check_flag = 'Y'
             AND   NVL(t.org_id,-99) = NVL(h.org_id, -99)
             AND   l.header_id = h.header_id
             AND   t.payment_type_code =
                   DECODE(l.payment_type_code, NULL,
                     DECODE(h.payment_type_code, NULL, t.payment_type_code,
                            h.payment_type_code),
                          l.payment_type_code)
           )



  GROUP BY
    h.invoice_to_org_id
  , h.transactional_curr_code
  , s.cust_account_id
  , ca.party_id
  , h.org_id
  ;


  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'G_ORDER_RETURN_HOLDS done at ' || DO_TIME, 2 );
  END IF;
END IF; -- l_cc_level_flag

IF l_cc_level_flag='Y' THEN
-- balance type 32

  INSERT INTO OE_CREDIT_SUMMARIES
  ( balance
  , balance_type
  , site_use_id
  , cust_account_id
  , party_id
  , org_id
  , currency_code
  , bucket
  , bucket_duration
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_application_id
  , program_id
  , program_update_date
  , request_id
  )


  SELECT
    SUM( NVL( m.line_tax_value, 0 ) )
    , G_ORDER_RETURN_TAX_HOLDS
    , m.order_invoice_to_org_id
    , order_cust_account_id
    , order_party_id
    , m.order_org_id
    , m.order_transactional_curr_code
    , -2
    , OE_CREDIT_EXPOSURE_PVT.G_MAX_BUCKET_LENGTH
    , sysdate
    , l_created_by
    , sysdate
    , l_last_updated_by
    , l_last_update_login
    , l_program_application_id
    , l_program_id
    , SYSDATE
    , l_request_id

  FROM
	OE_INIT_CREDIT_SUMM_GTT		m
  WHERE
	   m.line_line_category_code           =  'RETURN'
    AND    EXISTS
            ( SELECT  1
              FROM    oe_order_holds_all  oh
              WHERE   oh.header_id          =  m.order_header_id
              AND    (  oh.line_id        =  m.line_line_id
                      OR  oh.line_id IS NULL
                     )
              AND     oh.hold_release_id  IS NULL
            )
  GROUP BY
    m.order_invoice_to_org_id
  , m.order_transactional_curr_code
  , order_cust_account_id
  , order_party_id
  , m.order_org_id
  ;


  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'G_ORDER_RETURN_TAX_HOLDS  done at ' || DO_TIME, 2 );
  END IF;
END IF; -- l_cc_level_flag

IF l_order_hold_bal = 'Y' THEN
--------------------------
--  Line Uninvoiced Orders Holds
--------------------------
--  Note this is identical code except that
--  h.invoice_to_org_id is replaced with l.invoice_to_org_id

-- balance type 11

  INSERT INTO OE_CREDIT_SUMMARIES
  ( balance
  , balance_type
  , site_use_id
  , cust_account_id
  , party_id
  , org_id
  , currency_code
  , bucket
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_application_id
  , program_id
  , program_update_date
  , request_id
  , bucket_duration
  )


  SELECT
    - SUM( NVL( m.line_ordered_quantity, 0 )
         * NVL( m.line_unit_selling_price, 0 ) )
    + SUM( NVL( p.commitment_applied_amount, 0 ) )
    , G_LINE_HOLDS
    , m.line_invoice_to_org_id
    , line_cust_account_id
    , line_party_id
    , m.order_org_id
    , m.order_transactional_curr_code
    , TO_NUMBER( TO_CHAR( NVL( m.line_schedule_ship_date,
                          NVL( m.line_request_date,
                          NVL( m.order_request_date, m.order_creation_date) ) ), 'J' ) )
    , SYSDATE
    , l_created_by
    , SYSDATE
    , l_last_updated_by
    , l_last_update_login
    , l_program_application_id
    , l_program_id
    , SYSDATE
    , l_request_id
    , 1

  FROM
         OE_INIT_CREDIT_SUMM_GTT        m
       , oe_payments                    p
  WHERE
           m.line_line_category_code           =  'ORDER'
    AND    p.header_id  (+)               =  m.line_header_id
    AND    p.line_id    (+)               =  m.line_line_id
    AND    EXISTS
            ( SELECT  1
              FROM    oe_order_holds_all  oh
              WHERE   oh.header_id          =  m.order_header_id
              AND    (  oh.line_id        =  m.line_line_id
                      OR  oh.line_id IS NULL
                     )
              AND     oh.hold_release_id  IS NULL
            )
  GROUP BY
     m.line_invoice_to_org_id
   , m.order_transactional_curr_code
   , line_cust_account_id
   , line_party_id
   , m.order_org_id
   , TO_NUMBER( TO_CHAR( NVL( m.line_schedule_ship_date,
                         NVL( m.line_request_date,
                         NVL( m.order_request_date, m.order_creation_date) ) ), 'J' ) )
  ;


  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'G_LINE_HOLDS done at ' || DO_TIME, 2 );
  END IF;

-- balance type 14

  INSERT INTO OE_CREDIT_SUMMARIES
  ( balance
  , balance_type
  , site_use_id
  , cust_account_id
  , party_id
  , org_id
  , currency_code
  , bucket
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_application_id
  , program_id
  , program_update_date
  , request_id
  , bucket_duration
  )


  SELECT
    - SUM( NVL( m.line_tax_value, 0 ) )
    , G_LINE_TAX_HOLDS
    , m.line_invoice_to_org_id
    , line_cust_account_id
    , line_party_id
    , m.order_org_id
    , m.order_transactional_curr_code
    , TO_NUMBER( TO_CHAR( NVL( m.line_schedule_ship_date,
                          NVL( m.line_request_date,
                          NVL( m.order_request_date, m.order_creation_date) ) ), 'J' ) )
    , SYSDATE
    , l_created_by
    , SYSDATE
    , l_last_updated_by
    , l_last_update_login
    , l_program_application_id
    , l_program_id
    , SYSDATE
    , l_request_id
    , 1

  FROM
         OE_INIT_CREDIT_SUMM_GTT	m
  WHERE
           m.line_line_category_code           =  'ORDER'
    AND    EXISTS
            ( SELECT  1
              FROM    oe_order_holds_all  oh
              WHERE   oh.header_id          =  m.order_header_id
              AND    (  oh.line_id        =  m.line_line_id
                      OR  oh.line_id IS NULL
                     )
              AND     oh.hold_release_id  IS NULL
            )
  GROUP BY
     m.line_invoice_to_org_id
   , m.order_transactional_curr_code
   , line_cust_account_id
   , line_party_id
   , m.order_org_id
   , TO_NUMBER( TO_CHAR( NVL( m.line_schedule_ship_date,
                         NVL( m.line_request_date,
                         NVL( m.order_request_date, m.order_creation_date) ) ), 'J' ) )
  ;


  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'G_LINE_TAX_HOLDS done at ' || DO_TIME, 2 );
  END IF;
END IF; -- IF l_order_hold_bal

--------------------------------
----- RETURNS ------------------
--  Line Uninvoiced Orders Holds
--------------------------------
--  Note this is identical code except that
--  h.invoice_to_org_id is replaced with l.invoice_to_org_id

-- balance type 31

  INSERT INTO OE_CREDIT_SUMMARIES
  ( balance
  , balance_type
  , site_use_id
  , cust_account_id
  , party_id
  , org_id
  , currency_code
  , bucket
  , bucket_duration
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_application_id
  , program_id
  , program_update_date
  , request_id
  )


  SELECT
    SUM( NVL( m.line_ordered_quantity, 0 )
         * NVL( m.line_unit_selling_price, 0 ) )
    - SUM( NVL( p.commitment_applied_amount, 0 ) )
    , G_LINE_RETURN_HOLDS
    , m.line_invoice_to_org_id
    , line_cust_account_id
    , line_party_id
    , m.order_org_id
    , m.order_transactional_curr_code
    , -2
    , OE_CREDIT_EXPOSURE_PVT.G_MAX_BUCKET_LENGTH
    , sysdate
    , l_created_by
    , sysdate
    , l_last_updated_by
    , l_last_update_login
    , l_program_application_id
    , l_program_id
    , SYSDATE
    , l_request_id

  FROM
  	 OE_INIT_CREDIT_SUMM_GTT	m
       , oe_payments                    p
  WHERE
           m.line_line_category_code           =  'RETURN'
    AND    p.header_id  (+)               =  m.line_header_id
    AND    p.line_id    (+)               =  m.line_line_id
    AND    EXISTS
             ( SELECT  1
              FROM    oe_order_holds_all  oh
              WHERE   oh.header_id          =  m.order_header_id
              AND    (  oh.line_id        =  m.line_line_id
                      OR  oh.line_id IS NULL
                     )
              AND     oh.hold_release_id  IS NULL
            )
  GROUP BY
     m.line_invoice_to_org_id
   , m.order_transactional_curr_code
   , line_cust_account_id
   , line_party_id
   , m.order_org_id
  ;


  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'G_LINE_RETURN_HOLDS done at ' || DO_TIME, 2 );
  END IF;

-- balance type 33

  INSERT INTO OE_CREDIT_SUMMARIES
  ( balance
  , balance_type
  , site_use_id
  , cust_account_id
  , party_id
  , org_id
  , currency_code
  , bucket
  , bucket_duration
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_application_id
  , program_id
  , program_update_date
  , request_id
  )


  SELECT
    SUM( NVL( m.line_tax_value, 0 ) )
    , G_LINE_RETURN_TAX_HOLDS
    , m.line_invoice_to_org_id
    , line_cust_account_id
    , line_party_id
    , m.order_org_id
    , m.order_transactional_curr_code
    , -2
    , OE_CREDIT_EXPOSURE_PVT.G_MAX_BUCKET_LENGTH
    , sysdate
    , l_created_by
    , sysdate
    , l_last_updated_by
    , l_last_update_login
    , l_program_application_id
    , l_program_id
    , SYSDATE
    , l_request_id

  FROM
	OE_INIT_CREDIT_SUMM_GTT		m
  WHERE
           m.line_line_category_code           =  'RETURN'
    AND    EXISTS
            ( SELECT  1
              FROM    oe_order_holds_all  oh
              WHERE   oh.header_id          =  m.order_header_id
              AND    (  oh.line_id        =  m.line_line_id
                      OR  oh.line_id IS NULL
                     )
              AND     oh.hold_release_id  IS NULL
            )
  GROUP BY
     m.line_invoice_to_org_id
   , m.order_transactional_curr_code
   , line_cust_account_id
   , line_party_id
   , m.order_org_id
  ;

  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'G_LINE_RETURN_TAX_HOLDS done at ' || DO_TIME, 2 );
  END IF;


IF l_order_hold_bal = 'Y' THEN
--------------------------
--  Line Freight Holds
--------------------------

-- balance type 16

  INSERT INTO OE_CREDIT_SUMMARIES
  ( balance
  , balance_type
  , site_use_id
  , cust_account_id
  , party_id
  , org_id
  , currency_code
  , bucket
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_application_id
  , program_id
  , program_update_date
  , request_id
  , bucket_duration
  )

  SELECT
    - SUM
      ( DECODE( p.credit_or_charge_flag, 'C', (-1), (+1) )
      * DECODE( p.arithmetic_operator, 'LUMPSUM',			--bug 4295298
                p.operand, (m.line_ordered_quantity * p.adjusted_amount))
      )
    , G_LINE_FREIGHT_HOLDS
    , m.line_invoice_to_org_id
    , line_cust_account_id
    , line_party_id
    , m.order_org_id
    , m.order_transactional_curr_code
    , TO_NUMBER( TO_CHAR( NVL( m.line_schedule_ship_date,
                          NVL( m.line_request_date,
                          NVL( m.order_request_date, m.order_creation_date) ) ), 'J' ) )
    , SYSDATE
    , l_created_by
    , SYSDATE
    , l_last_updated_by
    , l_last_update_login
    , l_program_application_id
    , l_program_id
    , SYSDATE
    , l_request_id
    , 1

  FROM
      oe_price_adjustments     p,
      OE_INIT_CREDIT_SUMM_GTT	m
  WHERE
         p.line_id             =  m.line_line_id
    AND  p.header_id           =  m.line_header_id
    AND  p.header_id           =  m.order_header_id
    AND  m.line_line_category_code           =  'ORDER'
    AND  p.applied_flag        =  'Y'
    AND  p.list_line_type_code =  'FREIGHT_CHARGE'
    AND  NVL( p.invoiced_flag, 'N' )  =  'N'
    AND    EXISTS
            ( SELECT  1
              FROM    oe_order_holds_all  oh
              WHERE   oh.header_id          =  m.order_header_id
              AND    (  oh.line_id        =  m.line_line_id
                      OR  oh.line_id IS NULL
                     )
              AND     oh.hold_release_id  IS NULL
            )
  GROUP BY
      m.line_invoice_to_org_id
    , m.order_transactional_curr_code
    , line_cust_account_id
    , line_party_id
    , m.order_org_id
    , TO_NUMBER( TO_CHAR( NVL( m.line_schedule_ship_date,
                          NVL( m.line_request_date,
                          NVL( m.order_request_date, m.order_creation_date) ) ), 'J' ) )
  ;


  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'G_LINE_FREIGHT_HOLDS done at ' || DO_TIME, 2 );
  END IF;
END IF; -- IF l_order_hold_bal

---------------------------------
--------- RETURNS ---------------
--  Line Freight Holds ----------
---------------------------------

-- balance type 35

  INSERT INTO OE_CREDIT_SUMMARIES
  ( balance
  , balance_type
  , site_use_id
  , cust_account_id
  , party_id
  , org_id
  , currency_code
  , bucket
  , bucket_duration
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_application_id
  , program_id
  , program_update_date
  , request_id
  )

  SELECT
    - SUM
      ( DECODE( p.credit_or_charge_flag, 'C', (-1), (+1) )
      * DECODE( p.arithmetic_operator, 'LUMPSUM',			--bug 4295298
                p.operand, (m.line_ordered_quantity * p.adjusted_amount))
      )
    , G_LINE_RETURN_FREIGHT_HOLDS
    , m.line_invoice_to_org_id
    , line_cust_account_id
    , line_party_id
    , m.order_org_id
    , m.order_transactional_curr_code
    , -2
    , OE_CREDIT_EXPOSURE_PVT.G_MAX_BUCKET_LENGTH
    , sysdate
    , l_created_by
    , sysdate
    , l_last_updated_by
    , l_last_update_login
    , l_program_application_id
    , l_program_id
    , SYSDATE
    , l_request_id

  FROM
      oe_price_adjustments     p,
      OE_INIT_CREDIT_SUMM_GTT  m
  WHERE
         p.line_id             =  m.line_line_id
    AND  p.header_id           =  m.line_header_id
    AND  p.header_id           =  m.order_header_id
    AND  m.line_line_category_code           =  'RETURN'
    AND  p.applied_flag        =  'Y'
    AND  p.list_line_type_code =  'FREIGHT_CHARGE'
    AND  NVL( p.invoiced_flag, 'N' )  =  'N'
    AND    EXISTS
            ( SELECT  1
              FROM    oe_order_holds_all  oh
              WHERE   oh.header_id          =  m.order_header_id
              AND    (  oh.line_id        =  m.line_line_id
                      OR  oh.line_id IS NULL
                     )
              AND     oh.hold_release_id  IS NULL
            )
  GROUP BY
      m.line_invoice_to_org_id
    , m.order_transactional_curr_code
    , line_cust_account_id
    , line_party_id
    , m.order_org_id
  ;


  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'G_LINE_RETURN_FREIGHT_HOLDS done at ' || DO_TIME, 2 );
  END IF;


IF l_order_hold_bal = 'Y' THEN
--------------------------
--  Header Freight Holds
--------------------------
IF l_cc_level_flag='Y' THEN
-- balance type 15

  INSERT INTO OE_CREDIT_SUMMARIES
  ( balance
  , balance_type
  , site_use_id
  , cust_account_id
  , party_id
  , org_id
  , currency_code
  , bucket
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_application_id
  , program_id
  , program_update_date
  , request_id
  , bucket_duration
  )


SELECT
    - SUM
      ( DECODE( p.credit_or_charge_flag, 'C', (-1), (+1) )
      * DECODE( p.arithmetic_operator, 'LUMPSUM',			--bug 4295298
                p.operand, (m.line_ordered_quantity * p.adjusted_amount))
      )
    , G_ORDER_FREIGHT_HOLDS
    , m.order_invoice_to_org_id
    , order_cust_account_id
    , order_party_id
    , m.order_org_id
    , m.order_transactional_curr_code
    , TO_NUMBER( TO_CHAR( NVL( m.line_schedule_ship_date,
                          NVL( m.line_request_date,
                          NVL( m.order_request_date, m.order_creation_date) ) ), 'J' ) )
    , SYSDATE
    , l_created_by
    , SYSDATE
    , l_last_updated_by
    , l_last_update_login
    , l_program_application_id
    , l_program_id
    , SYSDATE
    , l_request_id
    , 1

FROM   oe_price_adjustments     p,
	OE_INIT_CREDIT_SUMM_GTT  m
WHERE
       p.line_id             =  m.line_line_id
  AND  p.header_id           =  m.line_header_id
  AND  p.header_id           =  m.order_header_id
  AND  m.line_line_category_code           =  'ORDER'
  AND  p.applied_flag                 =  'Y'
  AND  p.list_line_type_code          =  'FREIGHT_CHARGE'
  AND  NVL( p.invoiced_flag, 'N' )    =  'N'
  AND  EXISTS
        ( SELECT  1
          FROM    oe_order_holds_all  oh
          WHERE   oh.header_id          =  m.order_header_id
          AND    (  oh.line_id        =  m.line_line_id
                  OR  oh.line_id IS NULL
                 )
          AND     oh.hold_release_id  IS NULL
        )
GROUP BY
    m.order_invoice_to_org_id
  , m.order_transactional_curr_code
  , order_cust_account_id
  , order_party_id
  , m.order_org_id
  , TO_NUMBER( TO_CHAR( NVL( m.line_schedule_ship_date,
                        NVL( m.line_request_date,
                        NVL( m.order_request_date, m.order_creation_date) ) ), 'J' ) )
;


  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'G_ORDER_FREIGHT_HOLDS done at ' || DO_TIME, 2 );
  END IF;
END IF; -- l_cc_level_flag
END IF; -- IF l_order_hold_bal

--------------------------------------
-------- RETURNS ---------------------
--  Header Freight Holds -------------
--------------------------------------
IF l_cc_level_flag='Y' THEN
-- balance type 34

  INSERT INTO OE_CREDIT_SUMMARIES
  ( balance
  , balance_type
  , site_use_id
  , cust_account_id
  , party_id
  , org_id
  , currency_code
  , bucket
  , bucket_duration
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_application_id
  , program_id
  , program_update_date
  , request_id
  )


SELECT
    - SUM
      ( DECODE( p.credit_or_charge_flag, 'C', (-1), (+1) )
      * DECODE( p.arithmetic_operator, 'LUMPSUM',			--bug 4295298
                p.operand, (m.line_ordered_quantity * p.adjusted_amount))
      )
    , G_ORDER_RETURN_FREIGHT_HOLDS
    , m.order_invoice_to_org_id
    , order_cust_account_id
    , order_party_id
    , m.order_org_id
    , m.order_transactional_curr_code
    , -2
    , OE_CREDIT_EXPOSURE_PVT.G_MAX_BUCKET_LENGTH
    , sysdate
    , l_created_by
    , sysdate
    , l_last_updated_by
    , l_last_update_login
    , l_program_application_id
    , l_program_id
    , SYSDATE
    , l_request_id

FROM   oe_price_adjustments     p,
	OE_INIT_CREDIT_SUMM_GTT	m
WHERE
       p.line_id             =  m.line_line_id
  AND  p.header_id           =  m.line_header_id
  AND  p.header_id           =  m.order_header_id
  AND  m.line_line_category_code           =  'RETURN'
  AND  p.applied_flag                 =  'Y'
  AND  p.list_line_type_code          =  'FREIGHT_CHARGE'
  AND  NVL( p.invoiced_flag, 'N' )    =  'N'
  AND  EXISTS
        ( SELECT  1
          FROM    oe_order_holds_all  oh
          WHERE   oh.header_id          =  m.order_header_id
          AND    (  oh.line_id        =  m.line_line_id
                  OR  oh.line_id IS NULL
                 )
          AND     oh.hold_release_id  IS NULL
        )
GROUP BY
    m.order_invoice_to_org_id
  , m.order_transactional_curr_code
  , order_cust_account_id
  , order_party_id
  , m.order_org_id
;


  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'G_ORDER_RETURN_FREIGHT_HOLDS done at ' || DO_TIME, 2 );
  END IF;
END IF; -- l_cc_level_flag

IF l_order_hold_bal = 'Y' THEN
--------------------------
--  Header + Line Freight Part 2 Holds
--------------------------

-- balance type 17

  INSERT INTO OE_CREDIT_SUMMARIES
  ( balance
  , balance_type
  , site_use_id
  , cust_account_id
  , party_id
  , org_id
  , currency_code
  , bucket
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_application_id
  , program_id
  , program_update_date
  , request_id
  , bucket_duration
  )


SELECT
    - SUM( DECODE( p.credit_or_charge_flag, 'C', (-1), (+1) ) * p.operand )
    , G_HEADER_LINE_FREIGHT_HOLDS
    , h.invoice_to_org_id
    , s.cust_account_id
    , ca.party_id
    , h.org_id
    , h.transactional_curr_code
    , TO_NUMBER( TO_CHAR( NVL( h.request_date, h.creation_date ), 'J' ) )
    , SYSDATE
    , l_created_by
    , SYSDATE
    , l_last_updated_by
    , l_last_update_login
    , l_program_application_id
    , l_program_id
    , SYSDATE
    , l_request_id
    , 1

FROM
    oe_price_adjustments      p
  , oe_order_headers_all      h
  , hz_cust_site_uses_all     su
  , hz_cust_acct_sites_all    s
  , hz_cust_accounts          ca
WHERE
       p.line_id IS NULL
  AND  p.header_id           =  h.header_id
  AND  h.order_category_code IN ('ORDER','MIXED')
  AND  h.open_flag           =  'Y'
  AND  h.booked_flag         =  'Y'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code = 'FREIGHT_CHARGE'
  AND  NVL( p.invoiced_flag, 'N' )  =  'N'
  AND  su.site_use_id        =  h.invoice_to_org_id
  AND  su.cust_acct_site_id  =  s.cust_acct_site_id
  AND  ca.cust_account_id    =  s.cust_account_id
  AND  EXISTS
        ( SELECT  1
          FROM    oe_order_holds_all  oh
          WHERE   oh.header_id            =  h.header_id
          AND     oh.hold_release_id  IS NULL
        )
  AND  EXISTS
         ( SELECT  NULL
             FROM  oe_payment_types_all t,
                   oe_order_lines_all l
             WHERE t.credit_check_flag = 'Y'
             AND   NVL(t.org_id,-99) = NVL(h.org_id, -99)
             AND   l.header_id = h.header_id
             AND   t.payment_type_code =
                   DECODE(l.payment_type_code, NULL,
                     DECODE(h.payment_type_code, NULL, t.payment_type_code,
                            h.payment_type_code),
                          l.payment_type_code)
         )
GROUP BY
      h.invoice_to_org_id
    , h.transactional_curr_code
    , s.cust_account_id
    , ca.party_id
    , h.org_id
    , TO_NUMBER( TO_CHAR( NVL( h.request_date, h.creation_date ), 'J' ) )
;

  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'G_HEADER_LINE_FREIGHT_HOLDS done at ' || DO_TIME, 2 );
  END IF;
END IF; -- IF l_order_hold_bal

--------------------------------------
------------- RETURNS ----------------
--  Header + Line Fright Part 2 Holds
--------------------------------------

-- balance type 36

  INSERT INTO OE_CREDIT_SUMMARIES
  ( balance
  , balance_type
  , site_use_id
  , cust_account_id
  , party_id
  , org_id
  , currency_code
  , bucket
  , bucket_duration
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_application_id
  , program_id
  , program_update_date
  , request_id
  )


SELECT
    - SUM( DECODE( p.credit_or_charge_flag, 'C', (-1), (+1) ) * p.operand )
    , G_H_L_RETURN_FREIGHT_HOLDS
    , h.invoice_to_org_id
    , s.cust_account_id
    , ca.party_id
    , h.org_id
    , h.transactional_curr_code
    , -2
    , OE_CREDIT_EXPOSURE_PVT.G_MAX_BUCKET_LENGTH
    , sysdate
    , l_created_by
    , sysdate
    , l_last_updated_by
    , l_last_update_login
    , l_program_application_id
    , l_program_id
    , SYSDATE
    , l_request_id

FROM
    oe_price_adjustments      p
  , oe_order_headers_all      h
  , hz_cust_site_uses_all     su
  , hz_cust_acct_sites_all    s
  , hz_cust_accounts          ca
WHERE
       p.line_id IS NULL
  AND  p.header_id           =  h.header_id
  AND  h.order_category_code = 'RETURN'
  AND  h.open_flag           =  'Y'
  AND  h.booked_flag         =  'Y'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code = 'FREIGHT_CHARGE'
  AND  NVL( p.invoiced_flag, 'N' )  =  'N'
  AND  su.site_use_id        =  h.invoice_to_org_id
  AND  su.cust_acct_site_id  =  s.cust_acct_site_id
  AND  ca.cust_account_id    =  s.cust_account_id
  AND  EXISTS
        ( SELECT  1
          FROM    oe_order_holds_all  oh
          WHERE   oh.header_id     =  h.header_id
          AND     oh.hold_release_id  IS NULL
        )
  AND  EXISTS
         ( SELECT  NULL
             FROM  oe_payment_types_all t,
                   oe_order_lines_all l
             WHERE t.credit_check_flag = 'Y'
             AND   NVL(t.org_id,-99) = NVL(h.org_id, -99)
             AND   l.header_id = h.header_id
             AND   t.payment_type_code =
                   DECODE(l.payment_type_code, NULL,
                     DECODE(h.payment_type_code, NULL, t.payment_type_code,
                            h.payment_type_code),
                          l.payment_type_code)
         )
GROUP BY
      h.invoice_to_org_id
    , h.transactional_curr_code
    , s.cust_account_id
    , ca.party_id
    , h.org_id
;

  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'G_H_L_RETURN_FREIGHT_HOLDS done at ' || DO_TIME, 2 );
  END IF;



--------------------------
--  Invoices
--------------------------
-- The term in ther where clause containing the hard-coded
-- GL date was recommended for performance reasons
-- by AR

-- balance type 8

  INSERT INTO OE_CREDIT_SUMMARIES
  ( balance
  , balance_type
  , site_use_id
  , cust_account_id
  , party_id
  , org_id
  , currency_code
  , bucket
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_application_id
  , program_id
  , program_update_date
  , request_id
  , bucket_duration
  )

  SELECT
    SUM( sch.amount_due_remaining )
    , G_INVOICES
    , sch.customer_site_use_id
    , sch.customer_id
    , ca.party_id
    , sch.org_id
    , sch.invoice_currency_code
    , TO_NUMBER( TO_CHAR( sch.trx_date, 'J' ) )
    , sysdate
    , l_created_by
    , sysdate
    , l_last_updated_by
    , l_last_update_login
    , l_program_application_id
    , l_program_id
    , SYSDATE
    , l_request_id
    , 1

  FROM
    ar_payment_schedules_all     sch ,
    hz_cust_accounts             ca
    , hz_cust_site_uses_all      su
  WHERE
         NVL( receipt_confirmed_flag, 'Y' )  =  'Y'
    AND  gl_date_closed = to_date( '31-12-4712', 'DD-MM-YYYY')
    AND  ca.cust_account_id             =  sch.customer_id
    AND  su.site_use_id                 = sch.customer_site_use_id
    AND  su.site_use_code               <> 'DRAWEE'
  GROUP BY
      sch.customer_site_use_id
    , sch.invoice_currency_code
    , sch.customer_id
    , ca.party_id
    , sch.org_id
    , TO_NUMBER( TO_CHAR( sch.trx_date, 'J' ) )
  ;


  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'G_INVOICES done at ' || DO_TIME, 2 );
  END IF;


-----------------------------------------
--  Pay Risk
-----------------------------------------

-- balance type 9

  INSERT INTO OE_CREDIT_SUMMARIES
  ( balance
  , balance_type
  , site_use_id
  , cust_account_id
  , party_id
  , org_id
  , currency_code
  , bucket
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login

  , program_application_id
  , program_id
  , program_update_date
  , request_id
  , bucket_duration
  )


  SELECT
    SUM( crh.amount )  pay_risk
    , G_PAYMENTS_AT_RISK
    , cr.customer_site_use_id
    , cr.pay_from_customer
    , ca.party_id
    , cr.org_id
    , cr.currency_code
    , TO_NUMBER( TO_CHAR( cr.receipt_date, 'J' ) )
    , sysdate
    , l_created_by
    , sysdate
    , l_last_updated_by
    , l_last_update_login

    , l_program_application_id
    , l_program_id
    , SYSDATE
    , l_request_id
    , 1

  FROM
    ar_cash_receipts_all          cr
  , ar_cash_receipt_history_all   crh
  , hz_cust_accounts              ca
  , hz_cust_site_uses_all         su
  WHERE
         cr.cash_receipt_id             =  crh.cash_receipt_id
    AND  crh.current_record_flag        =  'Y'
    AND  NVL( cr.confirmed_flag, 'Y' )  =  'Y'
    AND  NVL( cr.reversal_category, cr.status || 'X' )  <>  cr.status
    AND  crh.status NOT IN
         (
           DECODE( crh.factor_flag
                 , 'Y', 'RISK_ELIMINATED'
                 , 'N', 'CLEARED'
                 )
         , 'REVERSED'
         )
    AND  NOT EXISTS
         (
           SELECT
             'X'
           FROM
             ar_receivable_applications_all        rap
           WHERE
                  rap.cash_receipt_id              =  cr.cash_receipt_id
             AND  rap.applied_payment_schedule_id  =  -2
             AND  rap.display                      =  'Y'
         )
  AND  ca.cust_account_id             =  cr.pay_from_customer
  AND  su.site_use_id                 = cr.customer_site_use_id
  AND  su.site_use_code               <> 'DRAWEE'
  GROUP BY
    cr.customer_site_use_id
  , cr.currency_code
  , cr.pay_from_customer
  , ca.party_id
  , cr.org_id
  , TO_NUMBER( TO_CHAR( cr.receipt_date, 'J' ) )
  ;

  IF G_debug_flag = 'Y'
  THEN
   oe_debug_pub.add( 'G_PAYMENTS_AT_RISK done at ' || DO_TIME, 2 );
  END IF;

---------------------- BR ------------------

-- balance type 21

  INSERT INTO OE_CREDIT_SUMMARIES
  ( balance
  , balance_type
  , site_use_id
  , cust_account_id
  , party_id
  , org_id
  , currency_code
  , bucket
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login

  , program_application_id
  , program_id
  , program_update_date
  , request_id
  , bucket_duration
  )

  SELECT
    SUM( sch.amount_due_remaining )
    , G_BR_INVOICES
    , sch.customer_site_use_id
    , sch.customer_id
    , ca.party_id
    , sch.org_id
    , sch.invoice_currency_code
    , TO_NUMBER( TO_CHAR( sch.trx_date, 'J' ) )
    , sysdate
    , l_created_by
    , sysdate
    , l_last_updated_by
    , l_last_update_login

    , l_program_application_id
    , l_program_id
    , SYSDATE
    , l_request_id
    , 1

  FROM
    ar_payment_schedules_all     sch ,
    hz_cust_accounts             ca
    , hz_cust_site_uses_all      su
  WHERE
         NVL( receipt_confirmed_flag, 'Y' )  =  'Y'
    AND  gl_date_closed = to_date( '31-12-4712', 'DD-MM-YYYY')
    AND  ca.cust_account_id             =  sch.customer_id
    AND  su.site_use_id                 = sch.customer_site_use_id
    AND  su.site_use_code               = 'DRAWEE'
  GROUP BY
      sch.customer_site_use_id
    , sch.invoice_currency_code
    , sch.customer_id
    , ca.party_id
    , sch.org_id
    , TO_NUMBER( TO_CHAR( sch.trx_date, 'J' ) )
  ;


  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'G_BR_INVOICES done at ' || DO_TIME, 2 );
  END IF;


-----------------------------------------
--  Pay Risk
-----------------------------------------

-- balance type 22

  INSERT INTO OE_CREDIT_SUMMARIES
  ( balance
  , balance_type
  , site_use_id
  , cust_account_id
  , party_id
  , org_id
  , currency_code
  , bucket
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login

  , program_application_id
  , program_id
  , program_update_date
  , request_id
  , bucket_duration
  )


  SELECT
    SUM( crh.amount )  pay_risk
    , G_BR_PAYMENTS_AT_RISK
    , cr.customer_site_use_id
    , cr.pay_from_customer
    , ca.party_id
    , cr.org_id
    , cr.currency_code
    , TO_NUMBER( TO_CHAR( cr.receipt_date, 'J' ) )
    , sysdate
    , l_created_by
    , sysdate
    , l_last_updated_by
    , l_last_update_login

    , l_program_application_id
    , l_program_id
    , SYSDATE
    , l_request_id
    , 1

  FROM
    ar_cash_receipts_all          cr
  , ar_cash_receipt_history_all   crh
  , hz_cust_accounts              ca
  , hz_cust_site_uses_all         su
  WHERE
         cr.cash_receipt_id             =  crh.cash_receipt_id
    AND  crh.current_record_flag        =  'Y'
    AND  NVL( cr.confirmed_flag, 'Y' )  =  'Y'
    AND  NVL( cr.reversal_category, cr.status || 'X' )  <>  cr.status
    AND  crh.status NOT IN
         (
           DECODE( crh.factor_flag
                 , 'Y', 'RISK_ELIMINATED'
                 , 'N', 'CLEARED'
                 )
         , 'REVERSED'
         )
    AND  NOT EXISTS
         (
           SELECT
             'X'
           FROM
             ar_receivable_applications_all        rap
           WHERE
                  rap.cash_receipt_id              =  cr.cash_receipt_id
             AND  rap.applied_payment_schedule_id  =  -2
             AND  rap.display                      =  'Y'
         )
  AND  ca.cust_account_id             =  cr.pay_from_customer
  AND  su.site_use_id                 = cr.customer_site_use_id
  AND  su.site_use_code               = 'DRAWEE'
  GROUP BY
    cr.customer_site_use_id
  , cr.currency_code
  , cr.pay_from_customer
  , ca.party_id
  , cr.org_id
  , TO_NUMBER( TO_CHAR( cr.receipt_date, 'J' ) )
  ;

  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'G_PAYMENTS_AT_RISK done at ' || DO_TIME, 2 );
  END IF;

-- Bug 4219133 : Insert Past Due Inv Balance only if needed.

IF l_past_due_bal = 'Y' THEN

----------------------- past due inv -------------

 -- balance type 20

 INSERT INTO OE_CREDIT_SUMMARIES
  ( balance
  , balance_type
  , site_use_id
  , cust_account_id
  , party_id
  , org_id
  , currency_code
  , bucket
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_application_id
  , program_id
  , program_update_date
  , request_id
  , bucket_duration
  )

  SELECT
    COUNT(payment_schedule_id)
    , G_past_due_invoices
    , sch.customer_site_use_id
    , sch.customer_id
    , ca.party_id
    , sch.org_id
    , sch.invoice_currency_code
    , TO_NUMBER( TO_CHAR( sch.due_date, 'J' ) )
    , sysdate
    , l_created_by
    , sysdate
    , l_last_updated_by
    , l_last_update_login
    , l_program_application_id
    , l_program_id
    , SYSDATE
    , l_request_id
    , 1

  FROM
    ar_payment_schedules_all     sch ,
    hz_cust_accounts             ca
  WHERE
         NVL( receipt_confirmed_flag, 'Y' )  =  'Y'
    AND  gl_date_closed = to_date( '31-12-4712', 'DD-MM-YYYY')
    AND  ca.cust_account_id             =  sch.customer_id
    AND  amount_due_remaining > 0
  GROUP BY
      sch.customer_site_use_id
    , sch.invoice_currency_code
    , sch.customer_id
    , ca.party_id
    , sch.org_id
    , TO_NUMBER( TO_CHAR( sch.due_date, 'J' ) )
  ;

  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'past due invt ' || DO_TIME, 2 );
  END IF;

END IF; -- IF l_past_due_bal

  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( ' End of first phase ');
  END IF;


  ----------------------
  --- second phase -----
  ----------------------
  l_level          := 0;
  l_bucket_length  := POWER( 2, l_level );

  -- Commented for thr bug 7688615 to improve the performance.
  /*UPDATE
    oe_credit_summaries
  SET
    bucket_duration  = l_bucket_length
    WHERE balance_type NOT IN (18,23,24,25,26,27,28,29,30,31,32,33,34,35,36); ---change for Returns

  */
  IF NVL(FND_PROFILE.VALUE('ONT_PRESERVE_EXT_CR_BAL'),'Y') = 'N' THEN
       UPDATE
         oe_credit_summaries
       SET
        bucket_duration  = l_bucket_length
       WHERE balance_type =18;
  END IF;

  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'level 0 records updated at ' || DO_TIME, 2 );
  END IF;

  l_level          := 1;
  l_bucket_length  := POWER( 2, l_level );

  --8567481 start
     --- Modification for the Bucket Logic -------
      INSERT /*+ parallel */ INTO OE_INIT_SUMM_TMP
      (balance,
       balance_type,
       site_use_id,
       cust_account_id,
       party_id,
       org_id,
       currency_code,
       bucket,
       bucket_duration)
       SELECT /*+ parallel(OE_CREDIT_SUMMARIES) */
             balance
           , balance_type
           , site_use_id
           , cust_account_id
           , party_id
           , org_id
           , currency_code
           , bucket
           , bucket_duration
           FROM
             oe_credit_summaries
           WHERE
            balance_type NOT IN (18,23,24,25,26,27,28,29,30,31,32,33,34,35,36); ---change for Returns

    WHILE  l_level  <=  G_MAX_BUCKET_LEVEL  LOOP


      INSERT /*+ parallel */ INTO OE_CREDIT_SUMMARIES
      ( balance
      , balance_type
      , site_use_id
      , cust_account_id
      , party_id
      , org_id
      , currency_code
      , bucket
      ,bucket_duration
      , creation_date
      , created_by
      , last_update_date
      , last_updated_by
      , last_update_login
       , program_application_id
      , program_id
      , program_update_date
      , request_id
      )

      SELECT /*+ parallel(OE_INIT_SUMM_TMP) */
        SUM( balance )
      , balance_type
      , site_use_id
      , cust_account_id
      , party_id
      , org_id
      , currency_code
      , bucket - MOD( bucket, l_bucket_length )
      , l_bucket_length
      , SYSDATE
      , l_created_by
      , SYSDATE
      , l_last_updated_by
      , l_last_update_login
      , l_program_application_id
      , l_program_id
      , SYSDATE
      , l_request_id

      FROM
        OE_INIT_SUMM_TMP
     -- WHERE
     --  bucket_duration  =  l_bucket_length / 2
      GROUP BY
        balance_type
      , site_use_id
      , cust_account_id
      , party_id
      , org_id
      , currency_code
      , bucket - MOD( bucket, l_bucket_length )
      ;

    IF G_debug_flag = 'Y'
    THEN
      oe_debug_pub.add( 'level ' || l_level || ' records done at '||DO_TIME, 2 );
    END IF;

      l_level          := l_level + 1;
      l_bucket_length  := POWER( 2, l_level );
    END LOOP;
  --8567481 end

/*8567481 start
  WHILE  l_level  <=  G_MAX_BUCKET_LEVEL  LOOP

    -- hints are introduced as part of the performance bug 7688615

    INSERT /*+ parallel  INTO OE_CREDIT_SUMMARIES
    ( balance
    , balance_type
    , site_use_id
    , cust_account_id
    , party_id
    , org_id
    , currency_code
    , bucket
    ,bucket_duration
    , creation_date
    , created_by
    , last_update_date
    , last_updated_by
    , last_update_login
     , program_application_id
    , program_id
    , program_update_date
    , request_id
    )

    SELECT /*+ parallel(OE_CREDIT_SUMMARIES)
      SUM( balance )
    , balance_type
    , site_use_id
    , cust_account_id
    , party_id
    , org_id
    , currency_code
    , bucket - MOD( bucket, l_bucket_length )
    , l_bucket_length
    , SYSDATE
    , l_created_by
    , SYSDATE
    , l_last_updated_by
    , l_last_update_login
    , l_program_application_id
    , l_program_id
    , SYSDATE
    , l_request_id

    FROM
      oe_credit_summaries
    WHERE
     bucket_duration  =  l_bucket_length / 2
    AND balance_type NOT IN (18,23,24,25,26,27,28,29,30,31,32,33,34,35,36) ---change for Returns
    GROUP BY
      balance_type
    , site_use_id
    , cust_account_id
    , party_id
    , org_id
    , currency_code
    , bucket - MOD( bucket, l_bucket_length )
    ;

  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'level ' || l_level || ' records done at '||DO_TIME, 2 );
  END IF;

    l_level          := l_level + 1;
    l_bucket_length  := POWER( 2, l_level );
  END LOOP;
   8567481 end */

  IF G_debug_flag = 'Y'
  THEN
   oe_debug_pub.add( ' Done Inserting into summary table, about to COMMIT');
  END IF;

  COMMIT;

  x_retcode  := 0;

  IF G_debug_flag = 'Y'
  THEN
   oe_debug_pub.add( ' after COMMIT  command');
   oe_debug_pub.add( 'Exiting OE_CREDIT_EXPOSURE_PVT.Init_Summary_Table ', 1 );
  END IF;

EXCEPTION

  WHEN OTHERS THEN

    IF
      FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME , 'Init_Summary_Table' );
    END IF;

   x_errbuf   := FND_MSG_PUB.Get( p_encoded  =>  FND_API.G_FALSE );
   x_retcode  := 2;


END Init_Summary_Table;

--========================================================================
-- PROCEDURE : Get_Exposure            PUBLIC
-- PARAMETERS: x_retcode               0 success, 1 warning, 2 error
--             x_errbuf                error buffer
--             p_customer_id           not null  (tca: cust_account_id)
--             p_site_use_id           can be null
--             p_header_id             order header
--             p_credit_check_rule_rec
--             p_system_parameters_rec for org id
--             p_limit_curr_code       currency in which to show the exposure
--             p_usage_curr_tbl        only include tran in these currencies
--             p_include_all_flag      include transactions in any currency
--             x_total_exposure
--             x_return_status
--             x_error_curr_tbl        contains currencies with no rates

---
-- COMMENT   : This returns the total exposure for a customer or customer site
--             using precalculated data.
--  rajkrish Jan-23-2002 included the logic for p_global_exposure_flag
--=======================================================================--

PROCEDURE  Get_Exposure
( p_customer_id             IN    NUMBER
, p_site_use_id             IN    NUMBER
, p_party_id                IN    NUMBER := NULL
, p_header_id               IN    NUMBER
, p_credit_check_rule_rec IN
          OE_CREDIT_CHECK_UTIL.oe_credit_rules_rec_type
, p_system_parameters_rec IN
          OE_CREDIT_CHECK_UTIL.oe_systems_param_rec_type
, p_limit_curr_code         IN
           HZ_CREDIT_PROFILE_AMTS.currency_code%TYPE
, p_usage_curr_tbl          IN  OE_CREDIT_CHECK_UTIL.curr_tbl_type
, p_include_all_flag        IN    VARCHAR2
, p_global_exposure_flag    IN    VARCHAR2 := 'N'
, p_need_exposure_details   IN    VARCHAR2 := 'N'
, x_total_exposure          OUT   NOCOPY NUMBER
, x_order_amount            OUT   NOCOPY NUMBER
, x_order_hold_amount       OUT   NOCOPY NUMBER
, x_ar_amount               OUT   NOCOPY NUMBER
, x_return_status           OUT   NOCOPY VARCHAR2
, x_error_curr_tbl          OUT   NOCOPY OE_CREDIT_CHECK_UTIL.curr_tbl_type
)
IS

  i                        BINARY_INTEGER;
  l_site_use_id            NUMBER;
  l_org_id                 NUMBER;
  l_currency_code          HZ_CREDIT_PROFILE_AMTS.currency_code%TYPE;
  l_balance                NUMBER;
  l_term                   NUMBER;
  l_total                  NUMBER;

  l_bucket                 NUMBER;
  l_bucket_length          NUMBER;
  l_main_bucket            NUMBER;
  l_main_bucket_length     NUMBER;
  l_level                  NUMBER;
  l_binary_tbl             oe_credit_exposure_pvt.Binary_tbl_type;
  j                        NUMBER;
  l_ship                   NUMBER;
  l_both_exposure          VARCHAR2(1) ;

  CURSOR C_g_use_party_hierarchy IS
  SELECT
    'Y'
   FROM
    hz_hierarchy_nodes hn
   WHERE  hn.parent_id                     = p_party_id
  AND     hn.parent_object_type           = 'ORGANIZATION'
  and     hn.parent_table_name            = 'HZ_PARTIES'
  and     hn.child_object_type            = 'ORGANIZATION'
  and     hn.effective_start_date  <=  sysdate
  and     hn.effective_end_date    >= SYSDATE
  and     hn.hierarchy_type
                = OE_CREDIT_CHECK_UTIL.G_hierarchy_type ;

BEGIN
  g_use_party_hierarchy := 'N' ;


  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'IN OEXVCRXB.OE_CREDIT_EXPOSURE_PVT.Get_Exposure', 1 );
    oe_debug_pub.add( '+++++++++++++++++++++++++++++++++++++++++++');
    oe_debug_pub.add( 'p_customer_id : ' || p_customer_id, 2 );
    oe_debug_pub.add( 'p_site_use_id : ' || p_site_use_id, 2 );
    oe_debug_pub.add( 'p_party_id    : '|| p_party_id ,2);
    oe_debug_pub.add( 'p_header_id : '   || p_header_id, 2 );
    oe_debug_pub.add( 'g_use_party_hierarchy : '|| g_use_party_hierarchy );
    oe_debug_pub.add( ' p_include_all_flag   => '||
           p_include_all_flag );
    oe_debug_pub.add('  p_global_exposure_flag    => '||
           p_global_exposure_flag );
    oe_debug_pub.add('  p_need_exposure_details   => '||
           p_need_exposure_details );
    oe_debug_pub.add
       ( 'p_credit_check_rule_rec.credit_check_rule_id: '
       || p_credit_check_rule_rec.credit_check_rule_id, 2 );
    oe_debug_pub.add
     ( 'p_credit_check_rule_rec.name: '
     ||  p_credit_check_rule_rec.name, 2 );
    oe_debug_pub.add
    (  'p_credit_check_rule_rec.failure_result_code: '
    ||  p_credit_check_rule_rec.failure_result_code, 2 );
    oe_debug_pub.add
    (  'p_credit_check_rule_rec.open_ar_balance_flag : '
    ||  p_credit_check_rule_rec.open_ar_balance_flag, 2 );
    oe_debug_pub.add
    ( 'p_credit_check_rule_rec.uninvoiced_orders_flag : '
     || p_credit_check_rule_rec.uninvoiced_orders_flag, 2 );
    oe_debug_pub.add
     ( 'p_credit_check_rule_rec.orders_on_hold_flag : '
      || p_credit_check_rule_rec.orders_on_hold_flag, 2 );
     oe_debug_pub.add
     ( 'p_credit_check_rule_rec.shipping_interval : '
     || p_credit_check_rule_rec.shipping_interval, 2 );
     oe_debug_pub.add
      ( 'p_credit_check_rule_rec.open_ar_days : '
      || p_credit_check_rule_rec.open_ar_days, 2 );
     oe_debug_pub.add
     ( 'p_credit_check_rule_rec.start_date_active : '
     || p_credit_check_rule_rec.start_date_active, 2 );
     oe_debug_pub.add
     ( 'p_credit_check_rule_rec.end_date_active : '
      || p_credit_check_rule_rec.end_date_active, 2 );
     oe_debug_pub.add
     ( 'p_credit_check_rule_rec.include_payments_at_risk_flag : '
     || p_credit_check_rule_rec.include_payments_at_risk_flag, 2 );
     oe_debug_pub.add
     ( 'p_credit_check_rule_rec.include_tax_flag : '
     || p_credit_check_rule_rec.include_tax_flag, 2 );
     oe_debug_pub.add
     ( 'p_credit_check_rule_rec.maximum_days_past_due : '
     || p_credit_check_rule_rec.maximum_days_past_due, 2 );
     oe_debug_pub.add
     ( 'p_credit_check_rule_rec.QUICK_CR_CHECK_FLAG : '
     || p_credit_check_rule_rec.QUICK_CR_CHECK_FLAG, 2 );
     oe_debug_pub.add
     ( 'p_credit_check_rule_rec.incl_freight_charges_flag : '
      || p_credit_check_rule_rec.incl_freight_charges_flag, 2 );
     oe_debug_pub.add
      ( 'p_credit_check_rule_rec.shipping_horizon : '
     || p_credit_check_rule_rec.shipping_horizon, 2 );
     oe_debug_pub.add
     ( 'p_credit_check_rule_rec.include_external_exposure_flag : '
     || p_credit_check_rule_rec.include_external_exposure_flag, 2 );
     oe_debug_pub.add
     ( 'p_credit_check_rule_rec.include_returns_flag : '
     || p_credit_check_rule_rec.include_returns_flag, 2 );
     oe_debug_pub.add
     ( 'p_system_parameters_rec.org_id : '
     || p_system_parameters_rec.org_id, 2 );
     oe_debug_pub.add
     ( 'p_system_parameters_rec.master_organization_id : '
     || p_system_parameters_rec.master_organization_id, 2 );
     oe_debug_pub.add( 'p_limit_curr_code: '  ||  p_limit_curr_code, 2 );
     oe_debug_pub.add( 'p_include_all_flag: ' ||  p_include_all_flag, 2 );
     oe_debug_pub.add( 'p_global_exposure_flag = '|| p_global_exposure_flag );

  END IF;

  ------------------------------------------------------------------

  g_use_party_hierarchy := 'N' ;

    IF p_party_id is not NULL
    THEN
       OPEN C_g_use_party_hierarchy ;

       FETCH C_g_use_party_hierarchy
       INTO g_use_party_hierarchy ;

       CLOSE C_g_use_party_hierarchy ;
    ELSE
     g_use_party_hierarchy := 'N' ;
    END IF;


    IF G_debug_flag = 'Y'
    THEN
      oe_debug_pub.add( 'final g_use_party_hierarchy ==> '||
         g_use_party_hierarchy );
    END IF;
  ------------------------------------------------------------------

  i  :=  p_usage_curr_tbl.FIRST;

  WHILE i IS NOT NULL LOOP
  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add( 'usage curr: '
       || p_usage_curr_tbl(i).usage_curr_code, 2 );
  END IF;
    i  :=  p_usage_curr_tbl.NEXT(i);
  END LOOP;

  g_conversion_type  := p_credit_check_rule_rec.conversion_type;


-----------
-- Locks needed for consistency
-- Goal: read-consistency of oe_credit_summaries during exposure
-- Means: SHARE lock or read-only transaction.
--        SHARE: Need to verify that update overrides share.
--        read-only: May slow down query due to reconstruction using
--          rollback segment w.r.t SCN
-- Compromise: do nothing
-- Tradeoffs: (consistent periodic) inconsistency extremely unlikely
--            (triggers/table handlers) inconsistency slightly more likely
--            since seperate exposure and update transactions may be correlated

  -- Get the functional currency for use in currency conversion
--  using triangulation

  g_functional_currency := oe_credit_check_util.Get_GL_Currency;

  l_org_id        := OE_CREDIT_CHECK_UTIL.G_org_id;  --bug# 5031301
  l_total         := 0;
  l_both_exposure := 'N' ;

  x_ar_amount       := NULL;
  x_order_amount      := NULL ;
  x_order_hold_amount := NULL ;
  -----------------------------

  IF NVL(p_need_exposure_details,'N') = 'N'
  THEN
  -- Order Management Summaries
    IF G_debug_flag = 'Y'
    THEN
     oe_debug_pub.add(' OM Balances ');
     oe_debug_pub.add(' call balance_types_om ');
   END IF;

     balance_types_om( p_credit_check_rule_rec );

     calculate_buckets
     ( ship_date( p_credit_check_rule_rec.shipping_horizon )
     , p_credit_check_rule_rec.shipping_interval
     , l_main_bucket
     , l_binary_tbl
     );


  ---------------------
  -- IF no OM or AR Horizon days setup, then the exposure
  -- can be calculated in one execution from the
  -- summary table both for OM and AR exposure as we need
  -- all the data

    IF p_credit_check_rule_rec.open_ar_days IS NULL
       AND p_credit_check_rule_rec.shipping_interval IS NULL
    THEN
      IF G_debug_flag = 'Y'
      THEN
        oe_debug_pub.add(' Call balance_types_om_and_ar ');
      END IF;

       balance_types_om_and_ar( p_credit_check_rule_rec );

       l_both_exposure := 'Y' ;

    ELSE
      IF G_debug_flag = 'Y'
      THEN
        oe_debug_pub.add(' Select OM and AR exposure separately ');
      END IF;
    END IF;

    IF G_debug_flag = 'Y'
    THEN
      oe_debug_pub.add(' l_both_exposure ==> '|| l_both_exposure );
      oe_debug_pub.add(' Call retrieve_exposure ');
    END IF;

        l_total  := l_total  +  retrieve_exposure
        ( p_binary_tbl           =>  l_binary_tbl
        , p_site_use_id          =>  p_site_use_id
        , p_customer_id          =>  p_customer_id
        , p_party_id             => p_party_id
        , p_org_id               =>  l_org_id
        , p_include_all_flag     =>  p_include_all_flag
        , p_usage_curr_tbl       =>  p_usage_curr_tbl
        , p_limit_curr_code      =>  p_limit_curr_code
        , p_main_bucket          =>  l_main_bucket
        , p_global_exposure_flag =>  p_global_exposure_flag
        , p_credit_check_rule_rec => p_credit_check_rule_rec
        , x_error_curr_tbl       =>  x_error_curr_tbl
        );

      IF G_debug_flag = 'Y'
      THEN
        oe_debug_pub.add(' Out of Retreive exposure with total ==>  '
            || l_total );
      END IF;

  ---------------------------------
  -- Accounts Receivables Summaries

      IF l_both_exposure = 'N'
      THEN
        IF G_debug_flag = 'Y'
        THEN
          oe_debug_pub.add(' AR exposure ');
          oe_debug_pub.add(' Call balance_types_ar ');
        END IF;

         balance_types_ar( p_credit_check_rule_rec );


         calculate_buckets
         ( open_date( p_credit_check_rule_rec.open_ar_days )
         , p_credit_check_rule_rec.open_ar_days
         , l_main_bucket
         , l_binary_tbl
          );

         oe_debug_pub.add(' Call retrieve_exposure for AR balance ');

         l_total  := l_total  +  retrieve_exposure
         ( p_binary_tbl           =>  l_binary_tbl
         , p_site_use_id          =>  p_site_use_id
         , p_customer_id          =>  p_customer_id
         , p_party_id             => p_party_id
         , p_org_id               =>  l_org_id
         , p_include_all_flag     =>  p_include_all_flag
         , p_usage_curr_tbl       =>  p_usage_curr_tbl
         , p_limit_curr_code      =>  p_limit_curr_code
         , p_main_bucket          =>  l_main_bucket
         , p_global_exposure_flag =>  p_global_exposure_flag
         , p_credit_check_rule_rec => p_credit_check_rule_rec
         , x_error_curr_tbl       =>  x_error_curr_tbl
         );

        IF G_debug_flag = 'Y'
        THEN
           oe_debug_pub.add(' out of AR  retrieve_exposure ==> '||
         l_total );
        END IF;

      ELSE
        IF G_debug_flag = 'Y'
        THEN
          oe_debug_pub.add(' NO need for AR expe as both exp calculated = '
                || l_both_exposure );
        END IF;
      END IF;

      x_total_exposure := l_total;

   ELSE

  ------------------------------ support detail exposure ------------
      IF G_debug_flag = 'Y'
      THEN
        oe_debug_pub.add(' support detail exposure ',1);
      END IF;

      balance_types_om_hold( p_credit_check_rule_rec );

      calculate_buckets
      ( ship_date( p_credit_check_rule_rec.shipping_horizon )
       , p_credit_check_rule_rec.shipping_interval
       , l_main_bucket
       , l_binary_tbl
       );

       x_order_hold_amount :=  retrieve_exposure
       ( p_binary_tbl            =>  l_binary_tbl
       , p_site_use_id           =>  p_site_use_id
       , p_customer_id           =>  p_customer_id
       , p_party_id              => p_party_id
       , p_org_id                =>  l_org_id
       , p_include_all_flag      =>  p_include_all_flag
       , p_usage_curr_tbl        =>  p_usage_curr_tbl
       , p_limit_curr_code       =>  p_limit_curr_code
       , p_main_bucket           =>  l_main_bucket
       , p_global_exposure_flag  =>  p_global_exposure_flag
       , p_credit_check_rule_rec => p_credit_check_rule_rec
       , x_error_curr_tbl        =>  x_error_curr_tbl
       );

      IF G_debug_flag = 'Y'
      THEN
        oe_debug_pub.add(' x_order_hold_amount => '||
         x_order_hold_amount );

        oe_debug_pub.add(' x_order_amount => '|| x_order_amount );

        oe_debug_pub.add(' x_ar_amount ' || x_ar_amount );
      END IF;
     --------------------------------------------------------
      balance_types_om_nohold ( p_credit_check_rule_rec );

      calculate_buckets
      ( ship_date( p_credit_check_rule_rec.shipping_horizon )
       , p_credit_check_rule_rec.shipping_interval
       , l_main_bucket
       , l_binary_tbl
       );

       x_order_amount :=  retrieve_exposure
       ( p_binary_tbl            =>  l_binary_tbl
       , p_site_use_id           =>  p_site_use_id
       , p_customer_id           =>  p_customer_id
       , p_party_id              => p_party_id
       , p_org_id                =>  l_org_id
       , p_include_all_flag      =>  p_include_all_flag
       , p_usage_curr_tbl        =>  p_usage_curr_tbl
       , p_limit_curr_code       =>  p_limit_curr_code
       , p_main_bucket           =>  l_main_bucket
       , p_global_exposure_flag  =>  p_global_exposure_flag
       , p_credit_check_rule_rec => p_credit_check_rule_rec
       , x_error_curr_tbl        =>  x_error_curr_tbl
       );

      IF G_debug_flag = 'Y'
      THEN
        oe_debug_pub.add(' x_order_amount => '|| x_order_amount );
        oe_debug_pub.add(' AR exposure ');
        oe_debug_pub.add(' Call balance_types_ar ');
      END IF;

         balance_types_ar( p_credit_check_rule_rec );


         calculate_buckets
         ( open_date( p_credit_check_rule_rec.open_ar_days )
         , p_credit_check_rule_rec.open_ar_days
         , l_main_bucket
         , l_binary_tbl
          );

         oe_debug_pub.add(' Call retrieve_exposure for AR balance ');

         x_ar_amount :=   retrieve_exposure
         ( p_binary_tbl           =>  l_binary_tbl
         , p_site_use_id          =>  p_site_use_id
         , p_customer_id          =>  p_customer_id
         , p_party_id             => p_party_id
         , p_org_id               =>  l_org_id
         , p_include_all_flag     =>  p_include_all_flag
         , p_usage_curr_tbl       =>  p_usage_curr_tbl
         , p_limit_curr_code      =>  p_limit_curr_code
         , p_main_bucket          =>  l_main_bucket
         , p_global_exposure_flag =>  p_global_exposure_flag
         , p_credit_check_rule_rec => p_credit_check_rule_rec
         , x_error_curr_tbl       =>  x_error_curr_tbl
         );

        IF G_debug_flag = 'Y'
        THEN
          oe_debug_pub.add(' out of AR  retrieve_exposure ==> '||
         x_ar_amount );
       END IF;

       --bug# 5597791
       IF G_debug_flag = 'Y'
       THEN
         oe_debug_pub.add(' x_order_hold_amount => '||
          x_order_hold_amount );

         oe_debug_pub.add(' x_order_amount => '|| x_order_amount );

         oe_debug_pub.add(' x_ar_amount ' || x_ar_amount );
       END IF;

       x_total_exposure := nvl(x_order_hold_amount,0) + nvl(x_order_amount,0) + nvl(x_ar_amount,0);

 END IF; -- exposure details

--------------------------------------------------------------
  x_return_status  := FND_API.G_RET_STS_SUCCESS;

  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add(' ');
    oe_debug_pub.add(' Total FINAL exposure ==> '|| x_total_exposure,1 );
    oe_debug_pub.add(' ');
    oe_debug_pub.add('*************************************************');
    oe_debug_pub.add( 'Exiting OE_CREDIT_EXPOSURE_PVT.Get_Exposure', 1 );
  END IF;


  l_total   := 0;
  l_both_exposure := 'N' ;



EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    oe_debug_pub.add(SQLERRM );

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    oe_debug_pub.add(SQLERRM );
    IF
      FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
    THEN
--        FND_MSG_PUB.Add_Exc_Msg( l_api_name, 'Get_Exposure' );
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, 'Get_Exposure' );
    END IF;

END Get_Exposure;


END OE_CREDIT_EXPOSURE_PVT;

/
