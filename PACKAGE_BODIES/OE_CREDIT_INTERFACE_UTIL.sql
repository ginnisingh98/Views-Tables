--------------------------------------------------------
--  DDL for Package Body OE_CREDIT_INTERFACE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CREDIT_INTERFACE_UTIL" AS
-- $Header: OEXUCERB.pls 120.2.12010000.4 2009/12/24 10:51:32 amimukhe ship $
--+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    OEXUCERB.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Package Spec of OE_CREDIT_INTERFACE_UTIL                           |
--|	 This package body contains some utility procedures for handling  |
--|	 exposure amount from receivable interface table.                 |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|    Get_Exposure_Amount                                                |
--|                                                                       |
--| HISTORY                                                               |
--|    Aug-01-2006 Initial creation                                       |
--+=======================================================================+

G_PKG_NAME    CONSTANT VARCHAR2(30) := 'OE_CREDIT_INTERFACE_UTIL';
G_DEBUG_FLAG  VARCHAR2(1)           :=  NVL(oe_credit_check_util.check_debug_flag , 'N' ) ;

--===============================================================================
-- PROCEDURE : Get_exposure_amount
-- Comments  : Return the overall exposure amount in RA_INTERFACE_LINES_ALL table
--===============================================================================
PROCEDURE Get_exposure_amount
( p_header_id              IN  NUMBER
, p_customer_id            IN  NUMBER
, p_site_use_id            IN  NUMBER
, p_credit_check_rule_rec  IN  OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type
, p_system_parameter_rec   IN  OE_CREDIT_CHECK_UTIL.OE_systems_param_rec_type
, p_credit_level           IN  VARCHAR2
, p_limit_curr_code        IN  VARCHAR2
, p_usage_curr             IN  OE_CREDIT_CHECK_UTIL.curr_tbl_type
, p_global_exposure_flag   IN  VARCHAR2 := 'N'
, x_exposure_amount        OUT NOCOPY NUMBER
, x_conversion_status      OUT NOCOPY OE_CREDIT_CHECK_UTIL.CURR_TBL_TYPE
, x_return_status          OUT NOCOPY VARCHAR2
)
IS

l_header_id                NUMBER      := NVL(p_header_id, 0) ;
l_customer_id              NUMBER      := NVL(p_customer_id, 0) ;
l_site_use_id              NUMBER      := NVL(p_site_use_id, 0) ;

l_include_tax_flag         VARCHAR2(1) := NVL(p_credit_check_rule_rec.include_tax_flag,'N') ;
l_freight_charges_flag     VARCHAR2(1) := NVL(p_credit_check_rule_rec.incl_freight_charges_flag,'N') ;
l_include_returns_flag     VARCHAR2(1) := NVL(p_credit_check_rule_rec.include_returns_flag,'N');
l_include_uninvoiced_flag  VARCHAR2(1) := NVL(p_credit_check_rule_rec.uninvoiced_orders_flag,'N');

l_org_id                   NUMBER      := OE_CREDIT_CHECK_UTIL.G_ORG_ID ;

l_total_exposure           NUMBER := 0 ;

l_total_on_order           NUMBER := 0 ;
l_total_on_return          NUMBER := 0 ;
l_total_on_freight1        NUMBER := 0 ;
l_total_on_freight2        NUMBER := 0 ;

l_cum_total_on_order       NUMBER := 0 ;
l_cum_total_on_return      NUMBER := 0 ;
l_cum_total_on_freight1    NUMBER := 0 ;
l_cum_total_on_freight2	   NUMBER := 0 ;

l_usage_total_exposure     NUMBER := 0 ;
l_limit_total_exposure     NUMBER := 0 ;

l_current_usage_cur        VARCHAR2(100) ;

l_cust_acct_site_id        number; -- bug 8744491

---------------------------------------------------------------
-- Cursor definitions
-- a) In order related cursors, use l_header_id instead of
--    p_header_id. This is done to remove the NVL on p_header_id
--    as p_header_id will be coming in as NULL for the
--    exposure reports.
---------------------------------------------------------------
--------------------- START exposure amount cursors -----------
---------------------------------------------------------------
-- CUSTOMER/SITE LEVEL CURSORS
---------------------------------------------------------------

---CUSTOMER/SITE REGULAR ORDERS
CURSOR cust_reg_orders (p_curr_code IN VARCHAR2 default NULL,l_cust_acct_site_id IN NUMBER DEFAULT NULL) IS -- bug 8744491
  SELECT SUM (
                 ( NVL( rl.amount, 0 ) )
               +   DECODE( rl.interface_line_attribute11, '0', DECODE(l_include_tax_flag, 'Y',
                   NVL(l.tax_value,0), 0 ), 0 )
              )
    FROM oe_order_lines l
       , oe_order_headers_all h
       , ra_interface_lines_all rl
   WHERE rl.orig_system_bill_customer_id  = l_customer_id
     AND rl.ORIG_SYSTEM_BILL_ADDRESS_ID = nvl(l_cust_acct_site_id,ORIG_SYSTEM_BILL_ADDRESS_ID)  --6896462 bug 8744491
     AND h.header_id                      = l.header_id
     AND h.org_id                         = l.org_id
     AND NVL( l.invoiced_quantity, 0 )    <> 0
     AND l.line_category_code             = 'ORDER'
     AND h.booked_flag                    = 'Y'
     --AND h.header_id                      <> l_header_id  --commented for bug#8879693
     AND h.transactional_curr_code        = p_curr_code
     AND nvl(rl.interface_status, '~')    <> 'P'
     AND rl.interface_line_context        = 'ORDER ENTRY'
     AND rl.interface_line_attribute1     = h.order_number
     AND rl.interface_line_attribute6     = l.line_id
     AND (EXISTS
             (SELECT NULL
                FROM oe_payment_types_all pt
               WHERE pt.payment_type_code = NVL(l.payment_type_code,
                                            NVL(h.payment_type_code, 'BME'))
                 AND pt.credit_check_flag = 'Y'
                 AND NVL(pt.org_id, -99)  = l_org_id)
           OR
           (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

---CUSTOMER/SITE RETURN ORDERS
CURSOR cust_reg_orders_return(p_curr_code IN VARCHAR2 default NULL,l_cust_acct_site_id IN NUMBER DEFAULT NULL) IS -- bug 8744491
  SELECT SUM (
          ( DECODE( SIGN (NVL( rl.quantity_ordered, 0 )), -1, (+1), (-1) ) * NVL( rl.amount, 0 ) )
         +  DECODE( rl.interface_line_attribute11, '0', DECODE(l_include_tax_flag, 'Y',
            NVL(DECODE(l.line_category_code,'RETURN',(-1)*l.tax_value,l.tax_value),0),0), 0 )
           )
    FROM oe_order_lines l
       , oe_order_headers_all h
       , ra_interface_lines_all rl
   WHERE rl.orig_system_bill_customer_id  = l_customer_id
     AND rl.ORIG_SYSTEM_BILL_ADDRESS_ID = nvl(l_cust_acct_site_id,ORIG_SYSTEM_BILL_ADDRESS_ID)  --6896462 bug 8744491
     AND h.header_id                      = l.header_id
     AND h.org_id                         = l.org_id
     AND NVL( l.invoiced_quantity, 0 )    <> 0
     AND l.line_category_code             = 'RETURN'
     AND h.booked_flag                    = 'Y'
     --AND h.header_id                      <> l_header_id   --commented for bug#8879693
     AND h.transactional_curr_code        = p_curr_code
     AND nvl(rl.interface_status, '~')    <> 'P'
     AND rl.interface_line_context        = 'ORDER ENTRY'
     AND rl.interface_line_attribute1     = h.order_number
     AND rl.interface_line_attribute6     = l.line_id
     AND (EXISTS
             (SELECT NULL
                FROM oe_payment_types_all pt
               WHERE pt.payment_type_code = NVL(l.payment_type_code,
                                            NVL(h.payment_type_code, 'BME'))
                 AND pt.credit_check_flag = 'Y'
                 AND NVL(pt.org_id, -99)  = l_org_id)
           OR
           (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

---CUSTOMER/SITE FREIGHT ORDERS
CURSOR cust_reg_orders_freight1 (p_curr_code IN VARCHAR2 default null,l_cust_acct_site_id IN NUMBER DEFAULT NULL) IS -- bug 8744491
  SELECT SUM( NVL( rl.amount, 0 ))
    FROM oe_price_adjustments p
       , oe_order_lines   l
       , oe_order_headers_all h
       , ra_interface_lines_all rl
   WHERE rl.orig_system_bill_customer_id  = l_customer_id
     AND rl.ORIG_SYSTEM_BILL_ADDRESS_ID = nvl(l_cust_acct_site_id,ORIG_SYSTEM_BILL_ADDRESS_ID)  --6896462 bug 8744491
     AND p.line_id                        = l.line_id
     AND NVL( l.invoiced_quantity, 0 )    <> 0
     AND p.header_id                      = l.header_id
     AND p.header_id                      = h.header_id
     AND h.header_id                      = l.header_id
     AND h.org_id                         = l.org_id
     AND h.booked_flag                    = 'Y'
     AND p.applied_flag                   = 'Y'
     AND p.list_line_type_code            = 'FREIGHT_CHARGE'
     AND h.order_category_code IN ('ORDER','MIXED','RETURN')
     AND NVL(p.invoiced_flag, 'N')        = 'Y'
     AND h.transactional_curr_code        = p_curr_code
     --AND h.header_id                      <> l_header_id   --commented for bug#8879693
     AND nvl(rl.interface_status, '~')    <> 'P'
     AND rl.interface_line_context        = 'ORDER ENTRY'
     AND rl.interface_line_attribute1     = h.order_number
     AND rl.interface_line_attribute6     = p.price_adjustment_id
     AND (EXISTS
           (SELECT NULL
              FROM oe_payment_types_all pt
             WHERE pt.payment_type_code = NVL(l.payment_type_code,
                                          NVL(h.payment_type_code, 'BME'))
               AND pt.credit_check_flag = 'Y'
               AND NVL(pt.org_id, -99)  = l_org_id)
            OR
           (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

CURSOR cust_reg_orders_freight2 (p_curr_code IN VARCHAR2 default null,l_cust_acct_site_id IN NUMBER DEFAULT NULL) IS -- bug 8744491
  SELECT SUM( NVL( rl.amount, 0 ))
    FROM oe_price_adjustments p
       , oe_order_headers_all h
       , ra_interface_lines_all rl
   WHERE rl.orig_system_bill_customer_id  = l_customer_id
     AND rl.ORIG_SYSTEM_BILL_ADDRESS_ID = nvl(l_cust_acct_site_id,ORIG_SYSTEM_BILL_ADDRESS_ID)  --6896462 bug 8744491
     AND p.line_id IS NULL
     AND p.header_id                      = h.header_id
     AND h.booked_flag                    = 'Y'
     AND p.applied_flag                   = 'Y'
     AND p.list_line_type_code            = 'FREIGHT_CHARGE'
     AND h.order_category_code IN ('ORDER','MIXED','RETURN')
     AND NVL(p.invoiced_flag, 'N')        = 'Y'
     AND h.transactional_curr_code        = p_curr_code
     --AND h.header_id                      <> l_header_id   --commented for bug#8879693
     AND nvl(rl.interface_status, '~')    <> 'P'
     AND rl.interface_line_context        = 'ORDER ENTRY'
     AND rl.interface_line_attribute1     = h.order_number
     AND rl.interface_line_attribute6     = p.price_adjustment_id
     AND EXISTS
           (SELECT NULL
              FROM oe_payment_types_all pt,
                   oe_order_lines l
             WHERE pt.credit_check_flag = 'Y'
               AND l.header_id = h.header_id
               AND l.org_id    = pt.org_id
               AND NVL(pt.org_id, -99) = l_org_id
               AND pt.payment_type_code =
                   DECODE(l.payment_type_code, NULL,
                     DECODE(h.payment_type_code, NULL, pt.payment_type_code,
                            h.payment_type_code),
                            l.payment_type_code));

---------------------------------------------------------------
-- GLOBAL EXPOSURE CURSORS
-------------------------------------------------------------

---GLOBAL REGULAR ORDERS
CURSOR cust_glb_orders (p_curr_code IN VARCHAR2 default NULL,l_cust_acct_site_id IN NUMBER DEFAULT NULL) IS -- bug 8744491
    SELECT SUM (
                 ( NVL( rl.amount, 0 ) )
               +   DECODE( rl.interface_line_attribute11, '0', DECODE(l_include_tax_flag, 'Y',
                    NVL(l.tax_value,0), 0 ), 0 )
               )
      FROM oe_order_lines_all l
         , oe_order_headers_all h
         , ra_interface_lines_all rl
     WHERE rl.orig_system_bill_customer_id  = l_customer_id
     AND rl.ORIG_SYSTEM_BILL_ADDRESS_ID = nvl(l_cust_acct_site_id,ORIG_SYSTEM_BILL_ADDRESS_ID)  --6896462 bug 8744491
       AND h.header_id                      = l.header_id
       AND NVL( l.invoiced_quantity, 0 )    <> 0
       AND l.line_category_code             = 'ORDER'
       AND h.booked_flag                    = 'Y'
       --AND h.header_id                      <> l_header_id   --commented for bug#8879693
       AND h.transactional_curr_code        = p_curr_code
       AND nvl(rl.interface_status, '~')    <> 'P'
       AND rl.interface_line_context        = 'ORDER ENTRY'
       AND rl.interface_line_attribute1     = h.order_number
       AND rl.interface_line_attribute6     = l.line_id
       AND (EXISTS
             (SELECT NULL
                FROM oe_payment_types_all pt
               WHERE pt.payment_type_code = NVL(l.payment_type_code,
                                            NVL(h.payment_type_code, 'BME'))
                 AND pt.credit_check_flag = 'Y'
                 AND NVL(pt.org_id, -99)  = NVL(h.org_id, -99))
           OR
           (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

---GLOBAL RETURN ORDERS
CURSOR cust_glb_orders_return (p_curr_code IN VARCHAR2 default NULL,l_cust_acct_site_id IN NUMBER DEFAULT NULL) IS  -- bug 8744491
  SELECT SUM (
          ( DECODE( SIGN (NVL( rl.quantity_ordered, 0 )), -1, (+1), (-1) ) * NVL( rl.amount, 0 ) )
         +  DECODE( rl.interface_line_attribute11, '0', DECODE(l_include_tax_flag, 'Y',
            NVL(DECODE(l.line_category_code,'RETURN',(-1)*l.tax_value,l.tax_value),0),0), 0 )
           )
    FROM oe_order_lines_all l
       , oe_order_headers_all h
       , ra_interface_lines_all rl
   WHERE rl.orig_system_bill_customer_id  = l_customer_id
     AND rl.ORIG_SYSTEM_BILL_ADDRESS_ID = nvl(l_cust_acct_site_id,ORIG_SYSTEM_BILL_ADDRESS_ID)  --6896462 bug 8744491
     AND h.header_id                      = l.header_id
     AND NVL( l.invoiced_quantity, 0 )    <> 0
     AND l.line_category_code             = 'RETURN'
     AND h.booked_flag                    = 'Y'
     --AND h.header_id                      <> l_header_id   --commented for bug#8879693
     AND h.transactional_curr_code        = p_curr_code
     AND nvl(rl.interface_status, '~')    <> 'P'
     AND rl.interface_line_context        = 'ORDER ENTRY'
     AND rl.interface_line_attribute1     = h.order_number
     AND rl.interface_line_attribute6     = l.line_id
     AND (EXISTS
             (SELECT NULL
                FROM oe_payment_types_all pt
               WHERE pt.payment_type_code = NVL(l.payment_type_code,
                                            NVL(h.payment_type_code, 'BME'))
                 AND pt.credit_check_flag = 'Y'
                 AND NVL(pt.org_id, -99)  = NVL(h.org_id, -99))
           OR
           (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

---GLOBAL FREIGHT ORDERS
CURSOR cust_glb_orders_freight1 (p_curr_code IN VARCHAR2 default null,l_cust_acct_site_id IN NUMBER DEFAULT NULL) IS -- bug 8744491
  SELECT SUM( NVL( rl.amount, 0 ))
    FROM oe_price_adjustments p
       , oe_order_lines_all l
       , oe_order_headers_all h
       , ra_interface_lines_all rl
   WHERE rl.orig_system_bill_customer_id  = l_customer_id
     AND rl.ORIG_SYSTEM_BILL_ADDRESS_ID = nvl(l_cust_acct_site_id,ORIG_SYSTEM_BILL_ADDRESS_ID)  --6896462 bug 8744491
     AND p.line_id                        = l.line_id
     AND NVL( l.invoiced_quantity, 0 )    <> 0
     AND p.header_id                      = l.header_id
     AND p.header_id                      = h.header_id
     AND h.header_id                      = l.header_id
     AND h.booked_flag                    = 'Y'
     AND p.applied_flag                   = 'Y'
     AND p.list_line_type_code            = 'FREIGHT_CHARGE'
     AND NVL(p.invoiced_flag, 'N')        = 'Y'
     AND h.transactional_curr_code        = p_curr_code
     --AND h.header_id                      <> l_header_id   --commented for bug#8879693
     AND nvl(rl.interface_status, '~')    <> 'P'
     AND rl.interface_line_context        = 'ORDER ENTRY'
     AND rl.interface_line_attribute1     = h.order_number
     AND rl.interface_line_attribute6     = p.price_adjustment_id
     AND (EXISTS
           (SELECT NULL
              FROM oe_payment_types_all pt
             WHERE pt.payment_type_code = NVL(l.payment_type_code,
                                          NVL(h.payment_type_code, 'BME'))
               AND pt.credit_check_flag = 'Y'
               AND NVL(pt.org_id, -99)  = NVL(h.org_id, -99))
            OR
           (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

CURSOR cust_glb_orders_freight2 (p_curr_code IN VARCHAR2 default null,l_cust_acct_site_id IN NUMBER DEFAULT NULL) IS  -- bug 8744491
  SELECT SUM( NVL( rl.amount, 0 ))
    FROM oe_price_adjustments p
       , oe_order_headers_all h
       , ra_interface_lines_all rl
   WHERE rl.orig_system_bill_customer_id  = l_customer_id
     AND rl.ORIG_SYSTEM_BILL_ADDRESS_ID = nvl(l_cust_acct_site_id,ORIG_SYSTEM_BILL_ADDRESS_ID)  --6896462 bug 8744491
     AND p.line_id IS NULL
     AND p.header_id                      = h.header_id
     AND h.booked_flag                    = 'Y'
     AND p.applied_flag                   = 'Y'
     AND p.list_line_type_code            = 'FREIGHT_CHARGE'
     AND h.order_category_code IN ('ORDER','MIXED','RETURN')
     AND NVL(p.invoiced_flag, 'N')        = 'Y'
     AND h.transactional_curr_code        = p_curr_code
     --AND h.header_id                      <> l_header_id   --commented for bug#8879693
     AND nvl(rl.interface_status, '~')    <> 'P'
     AND rl.interface_line_context        = 'ORDER ENTRY'
     AND rl.interface_line_attribute1     = h.order_number
     AND rl.interface_line_attribute6     = p.price_adjustment_id
     AND EXISTS
           (SELECT NULL
              FROM oe_payment_types_all pt,
                   oe_order_lines l
             WHERE pt.credit_check_flag = 'Y'
               AND l.header_id = h.header_id
               AND l.org_id    = pt.org_id
               AND NVL(pt.org_id, -99) = NVL(h.org_id, -99)
               AND pt.payment_type_code =
                   DECODE(l.payment_type_code, NULL,
                     DECODE(h.payment_type_code, NULL, pt.payment_type_code,
                            h.payment_type_code),
                            l.payment_type_code));

----------------------- END exposure amount cursors -----------

BEGIN
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add(' ');
    OE_DEBUG_PUB.ADD('OEXUCERB: IN Get_exposure_amount',1);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('Exposure Input parameters ');
    OE_DEBUG_PUB.Add('--------------------------------------');
    OE_DEBUG_PUB.Add('p_customer_id             = '|| p_customer_id, 1);
    OE_DEBUG_PUB.Add('p_site_use_id             = '|| p_site_use_id, 1);
    OE_DEBUG_PUB.Add('p_header_id               = '|| p_header_id);
    OE_DEBUG_PUB.Add('p_credit_check_rule_id    = '|| p_credit_check_rule_rec.credit_check_rule_id);
    OE_DEBUG_PUB.Add('Conversion type           = '|| p_credit_check_rule_rec.conversion_type);
    OE_DEBUG_PUB.Add('p_credit_level            = '|| p_credit_level, 1);
    OE_DEBUG_PUB.Add('p_limit_curr_code         = '|| p_limit_curr_code);
    OE_DEBUG_PUB.Add('p_global_exposure_flag    = '|| p_global_exposure_flag, 1);
    OE_DEBUG_PUB.Add(' l_include_tax_flag       = '|| l_include_tax_flag );
    OE_DEBUG_PUB.Add(' l_freight_charges_flag   = '|| l_freight_charges_flag );
    OE_DEBUG_PUB.Add(' l_include_returns_flag   = '|| l_include_returns_flag );
    OE_DEBUG_PUB.Add(' l_include_uninvoiced_flag= '|| l_include_uninvoiced_flag );

    OE_DEBUG_PUB.Add('--------------End Parameters---------- ');
  END IF;

  IF p_credit_level = 'SITE'
  THEN
     BEGIN
       -- bug 8744491
       SELECT cas.cust_account_id,su.cust_acct_site_id
         INTO l_customer_id,l_cust_acct_site_id
         FROM hz_cust_site_uses su
            , hz_cust_acct_sites_all cas
        WHERE su.site_use_id       = l_site_use_id
          AND su.cust_acct_site_id = cas.cust_acct_site_id ;

       IF G_debug_flag = 'Y'
       THEN
          OE_DEBUG_PUB.ADD(' Customer ID : ' || l_customer_id ,1);
          OE_DEBUG_PUB.ADD(' Customer site ID : ' || l_cust_acct_site_id ,1); -- bug 8744491
       END IF;
     EXCEPTION
       WHEN NO_DATA_FOUND
       THEN
         IF G_debug_flag = 'Y'
         THEN
            OE_DEBUG_PUB.ADD(' No Data found for Customer ID using Site Use ID',1);
         END IF;
     END;
  END IF;

  IF p_credit_level IN ('CUSTOMER', 'SITE')
  THEN
    -- Select total amount exposure using CUSTOMER/SITE CURSORs
    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.Add('Begin AR Exposure calculation ');
    END IF;

    -- The exposure calculation must be done for all the usage currencies
    -- as part of the multi currency set up.


    l_current_usage_cur := NULL ;

    FOR i IN 1..p_usage_curr.count
    LOOP

      l_current_usage_cur := NULL ;

      IF G_debug_flag = 'Y'
      THEN
       OE_DEBUG_PUB.ADD(' ');
       OE_DEBUG_PUB.ADD('############################### ');
       OE_DEBUG_PUB.ADD('USAGE CURR = '|| p_usage_curr(i).usage_curr_code );
       OE_DEBUG_PUB.ADD('############################### ');
       OE_DEBUG_PUB.ADD(' ');
      END IF;

      l_current_usage_cur := p_usage_curr(i).usage_curr_code ;

------------------- AR Exposure logic ------------------------
      IF p_global_exposure_flag = 'Y'
      THEN
        IF l_include_uninvoiced_flag = 'Y'
        THEN
 	  IF G_debug_flag = 'Y'
          THEN
             OE_DEBUG_PUB.Add('Select cust_glb_orders  ');
          END IF;

          OPEN cust_glb_orders(p_usage_curr(i).usage_curr_code,l_cust_acct_site_id);  --bug 8744491
          FETCH cust_glb_orders INTO l_total_on_order;

          IF G_debug_flag = 'Y'
          THEN
             OE_DEBUG_PUB.ADD(' l_total_on_order          = ' || nvl(l_total_on_order,0));
          END IF;

	  IF cust_glb_orders%NOTFOUND
          THEN
             l_total_on_order := 0 ;
             OE_DEBUG_PUB.Add('No Uninvoiced order amount found ');
          END IF;
          CLOSE cust_glb_orders;
        END IF;

        IF l_include_returns_flag = 'Y'
        THEN
          IF G_debug_flag = 'Y'
          THEN
             OE_DEBUG_PUB.Add('Select cust_glb_orders_return ');
          END IF;

          OPEN cust_glb_orders_return(p_usage_curr(i).usage_curr_code,l_cust_acct_site_id); --bug 8744491
          FETCH cust_glb_orders_return INTO l_total_on_return;

          IF G_debug_flag = 'Y'
          THEN
             OE_DEBUG_PUB.ADD(' l_total_on_return         = ' || nvl(l_total_on_return,0));
          END IF;

          IF cust_glb_orders_return%NOTFOUND
          THEN
             l_total_on_return := 0 ;
             OE_DEBUG_PUB.Add('No Return order amount found ');
          END IF;

          CLOSE cust_glb_orders_return;
        END IF;

        IF l_freight_charges_flag ='Y'
        THEN
          IF G_debug_flag = 'Y'
          THEN
             OE_DEBUG_PUB.Add('Select cust_glb_orders_freight1  ');
          END IF;

          OPEN cust_glb_orders_freight1 (p_usage_curr(i).usage_curr_code,l_cust_acct_site_id); --bug 8744491
	  FETCH cust_glb_orders_freight1 INTO l_total_on_freight1;

          IF G_debug_flag = 'Y'
          THEN
             OE_DEBUG_PUB.ADD(' l_total_on_freight1       = ' || nvl(l_total_on_freight1,0));
          END IF;

          IF cust_glb_orders_freight1%NOTFOUND
          THEN
             l_total_on_freight1 := 0 ;
             OE_DEBUG_PUB.Add('No Freight order amount found ');
          END IF;

          CLOSE cust_glb_orders_freight1;

          IF G_debug_flag = 'Y'
          THEN
             OE_DEBUG_PUB.Add('Select cust_glb_orders_freight2  ');
          END IF;

          OPEN cust_glb_orders_freight2 (p_usage_curr(i).usage_curr_code,l_cust_acct_site_id); --bug 8744491
	  FETCH cust_glb_orders_freight2 INTO l_total_on_freight2;

          IF G_debug_flag = 'Y'
          THEN
             OE_DEBUG_PUB.ADD(' l_total_on_freight2       = ' || nvl(l_total_on_freight2,0));
          END IF;

          IF cust_glb_orders_freight2%NOTFOUND
          THEN
             l_total_on_freight2 := 0 ;
             OE_DEBUG_PUB.Add('No Freight order amount found ');
          END IF;

          CLOSE cust_glb_orders_freight2;
	END IF;
      ELSE
        IF l_include_uninvoiced_flag = 'Y'
        THEN
          IF G_debug_flag = 'Y'
          THEN
             OE_DEBUG_PUB.Add('Select cust_reg_orders  ');
          END IF;

          OPEN cust_reg_orders(p_usage_curr(i).usage_curr_code,l_cust_acct_site_id); --bug 8744491
          FETCH cust_reg_orders INTO l_total_on_order;

          IF G_debug_flag = 'Y'
          THEN
             OE_DEBUG_PUB.ADD(' l_total_on_order          = ' || nvl(l_total_on_order,0));
          END IF;

	  IF cust_reg_orders%NOTFOUND
          THEN
             l_total_on_order := 0 ;
             OE_DEBUG_PUB.Add('No Uninvoiced order amount found ');
          END IF;

          CLOSE cust_reg_orders;
        END IF;

        IF l_include_returns_flag = 'Y'
	THEN
          IF G_debug_flag = 'Y'
          THEN
             OE_DEBUG_PUB.Add('Select cust_reg_orders_return  ');
          END IF;

          OPEN cust_reg_orders_return(p_usage_curr(i).usage_curr_code,l_cust_acct_site_id); --bug 8744491
          FETCH cust_reg_orders_return INTO l_total_on_return;

          IF G_debug_flag = 'Y'
          THEN
             OE_DEBUG_PUB.ADD(' l_total_on_return         = ' || nvl(l_total_on_return,0));
          END IF;

          IF cust_reg_orders_return%NOTFOUND
          THEN
             l_total_on_return := 0 ;
             OE_DEBUG_PUB.Add('No Return order amount found ');
          END IF;

          CLOSE cust_reg_orders_return;
        END IF;

        IF l_freight_charges_flag ='Y'
        THEN
          IF G_debug_flag = 'Y'
          THEN
             OE_DEBUG_PUB.Add('Select open cust_reg_orders_freight1  ');
          END IF;

          OPEN cust_reg_orders_freight1 (p_usage_curr(i).usage_curr_code,l_cust_acct_site_id); --bug 8744491
          FETCH cust_reg_orders_freight1 INTO l_total_on_freight1;

          IF G_debug_flag = 'Y'
          THEN
             OE_DEBUG_PUB.ADD(' l_total_on_freight1       = ' || nvl(l_total_on_freight1,0));
          END IF;

          IF cust_reg_orders_freight1%NOTFOUND
          THEN
             l_total_on_freight1 := 0 ;
             OE_DEBUG_PUB.Add('No Freight order amount found ');
          END IF;

          CLOSE cust_reg_orders_freight1;

          IF G_debug_flag = 'Y'
          THEN
             OE_DEBUG_PUB.Add('Select open cust_reg_orders_freight2  ');
          END IF;

          OPEN cust_reg_orders_freight2 (p_usage_curr(i).usage_curr_code,l_cust_acct_site_id);  --bug 8744491
          FETCH cust_reg_orders_freight2 INTO l_total_on_freight2;

          IF G_debug_flag = 'Y'
          THEN
             OE_DEBUG_PUB.ADD(' l_total_on_freight2       = ' || nvl(l_total_on_freight2,0));
          END IF;

          IF cust_reg_orders_freight2%NOTFOUND
          THEN
             l_total_on_freight2 := 0 ;
             OE_DEBUG_PUB.Add('No Freight order amount found ');
          END IF;

          CLOSE cust_reg_orders_freight2;
	END IF;
      END IF ; --- Global

----------------------- End AR Exposure ------------------

    l_cum_total_on_order   := l_cum_total_on_order    + NVL(l_total_on_order,0);
    l_cum_total_on_return  := l_cum_total_on_return   + NVL(l_total_on_return,0);
    l_cum_total_on_freight1:= l_cum_total_on_freight1 + NVL(l_total_on_freight1,0);
    l_cum_total_on_freight2:= l_cum_total_on_freight2 + NVL(l_total_on_freight2,0);

    l_usage_total_exposure := NVL(l_cum_total_on_order,0)    + NVL(l_cum_total_on_return,0)
                            + NVL(l_cum_total_on_freight1,0) + NVL(l_cum_total_on_freight2,0);

    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD(' ');
      OE_DEBUG_PUB.ADD(' l_cum_total_on_order      = ' || nvl(l_cum_total_on_order,0));
      OE_DEBUG_PUB.ADD(' l_cum_total_on_return     = ' || nvl(l_cum_total_on_return,0));
      OE_DEBUG_PUB.ADD(' l_cum_total_on_freight1   = ' || nvl(l_total_on_freight1,0));
      OE_DEBUG_PUB.ADD(' l_cum_total_on_freight2   = ' || nvl(l_total_on_freight2,0));
      OE_DEBUG_PUB.ADD(' l_usage_total_exposure    = ' || nvl(l_usage_total_exposure,0));

      OE_DEBUG_PUB.ADD(' Call currency conversion for exposure  ' );
      OE_DEBUG_PUB.Add(' GL_CURRENCY = '|| OE_Credit_Engine_GRP.GL_currency );
    END IF;

    IF OE_Credit_Engine_GRP.GL_currency IS NULL
    THEN
      OE_DEBUG_PUB.ADD(' Call GET_GL_currency ');

      OE_Credit_Engine_GRP.GL_currency := OE_CREDIT_CHECK_UTIL.GET_GL_currency ;

      OE_DEBUG_PUB.ADD(' GL_CURRENCY  after = ' || OE_Credit_Engine_GRP.GL_currency );
    END IF;

    l_limit_total_exposure :=
    OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
      ( p_amount	            => l_usage_total_exposure
      , p_transactional_currency    => p_usage_curr(i).usage_curr_code
      , p_limit_currency	    => p_limit_curr_code
      , p_functional_currency       => OE_Credit_Engine_GRP.GL_currency
      , p_conversion_date	    => SYSDATE
      , p_conversion_type	    => p_credit_check_rule_rec.conversion_type
      );

    l_total_exposure := NVL(l_total_exposure,0) + NVL(l_limit_total_exposure,0) ;

    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD('l_total_exposure           = ' || nvl(l_total_exposure,0));
    END IF;

    l_cum_total_on_order       := 0;
    l_cum_total_on_return      := 0;
    l_cum_total_on_freight1    := 0;
    l_cum_total_on_freight2    := 0;

    l_usage_total_exposure     := 0;
    l_limit_total_exposure     := 0;

    l_total_on_order           := 0;
    l_total_on_return          := 0;
    l_total_on_freight1        := 0;
    l_total_on_freight2        := 0;

    END LOOP ; -- CURRENCY LOOP
  END IF;

  x_exposure_amount := NVL(l_total_exposure,0) ;

  IF G_debug_flag = 'Y'
  THEN
     OE_DEBUG_PUB.Add(' ');
     OE_DEBUG_PUB.Add('---------------##########----------------' );
     OE_DEBUG_PUB.Add(' ');
     OE_DEBUG_PUB.Add('Total exposure amount in Interface table = '|| x_exposure_amount,1);
     OE_DEBUG_PUB.Add(' ');
     OE_DEBUG_PUB.Add('-------------- ##########----------------' );
     OE_DEBUG_PUB.Add(' ');
     OE_DEBUG_PUB.ADD('OEXUCERB: OUT NOCOPY Get_exposure_amount ',1);
  END IF;

EXCEPTION
  WHEN GL_CURRENCY_API.NO_RATE THEN
    OE_DEBUG_PUB.ADD('EXCEPTION: GL_CURRENCY_API.NO_RATE in get_exposure_amount',1);
    OE_DEBUG_PUB.ADD('l_current_usage_cur = '|| l_current_usage_cur );
    x_conversion_status(1).usage_curr_code := l_current_usage_cur ;

    fnd_message.set_name('ONT', 'OE_CONVERSION_ERROR');
    OE_DEBUG_PUB.ADD('Exception table added ');
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, '
                                Get_exposure_amount');
    END IF;
    RAISE;

END Get_exposure_amount ;

END OE_CREDIT_INTERFACE_UTIL ;

/
