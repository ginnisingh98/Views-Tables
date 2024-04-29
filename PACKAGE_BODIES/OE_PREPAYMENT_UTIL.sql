--------------------------------------------------------
--  DDL for Package Body OE_PREPAYMENT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PREPAYMENT_UTIL" AS
/* $Header: OEXUPPYB.pls 120.14 2006/06/15 18:41:30 lkxu ship $ */

G_PKG_NAME    CONSTANT VARCHAR2(30) := 'OE_PrePayment_UTIL';

PROCEDURE Is_Prepaid(p_application_id               IN NUMBER,
                     p_entity_short_name            in VARCHAR2,
                     p_validation_entity_short_name in VARCHAR2,
                     p_validation_tmplt_short_name  in VARCHAR2,
                     p_record_set_tmplt_short_name  in VARCHAR2,
                     p_scope                        in VARCHAR2,
p_result OUT NOCOPY NUMBER ) IS


l_header_id NUMBER ;
l_prepaid NUMBER := 0;
l_prepayment_flag VARCHAR2(1);
l_payment_type_code  varchar2(30);
l_payment_term_id  NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OE_PREPAYMENT_UTIL.IS_PREPAID' ) ;
   END IF;
   IF OE_CODE_CONTROL.Get_Code_Release_Level < '110508' THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXUPPY: BELOW PACKH , PREPAYMENTS NOT ENABLED' ) ;
      END IF;
      p_result := 0;
      RETURN;
   END IF;
--serla begin
   IF NOT IS_MULTIPLE_PAYMENTS_ENABLED THEN
--serla end
      IF p_validation_entity_short_name = 'HEADER' THEN
         l_header_id := oe_header_security.g_record.header_id;
         l_payment_type_code := oe_header_security.g_record.payment_type_code;
         l_payment_term_id := oe_header_security.g_record.payment_term_id;
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'L_HEADER_ID: '||L_HEADER_ID ||' :L_PAYMENT_TYPE_CODE='||L_PAYMENT_TYPE_CODE||':L_PAYMENT_TERM_ID='||L_PAYMENT_TERM_ID ) ;
         END IF;
      ELSIF p_validation_entity_short_name = 'LINE' THEN
         l_header_id := oe_line_security.g_record.header_id;
      END IF;

      IF l_header_id IS NULL OR
         l_header_id = FND_API.G_MISS_NUM
      THEN
         OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);
         p_result := 0;
      END IF;

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'P_VALIDATION_ENTITY_SHORT_NAME: '||P_VALIDATION_ENTITY_SHORT_NAME ) ;
      END IF;
      IF p_validation_entity_short_name = 'HEADER' THEN
         BEGIN
            SELECT 1
            INTO l_prepaid
            FROM oe_payments
            WHERE header_id = l_header_id
            AND payment_type_code = 'CREDIT_CARD';
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_prepaid := 0;
         END;
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'L_PREPAID: '||L_PREPAID ) ;
         END IF;

         IF l_prepaid = 1 THEN
            p_result := 1;
         ELSE
            p_result := 0;
         END IF;
      ELSIF p_validation_entity_short_name = 'LINE' THEN --validation entity <> 'HEADER'
        IF Is_Prepaid_order(l_header_id) = 'Y' THEN
           BEGIN
              SELECT 1
              INTO l_prepaid
              FROM oe_payments
              WHERE header_id = l_header_id
              AND payment_type_code = 'CREDIT_CARD';
           EXCEPTION
              WHEN NO_DATA_FOUND THEN
                l_prepaid := 0;
           END;

           IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'L_PREPAID: '||L_PREPAID ) ;
           END IF;

           IF l_prepaid = 1 THEN
              p_result := 1;
           ELSE
              p_result := 0;
           END IF;
        ELSE -- Is_Prepaid_Order = 'N'
           p_result := 0;
        END IF;
      END IF;
--serla begin
   ELSE -- multiple payments enabled

      IF p_validation_entity_short_name = 'HEADER' THEN
         l_header_id := oe_header_security.g_record.header_id;
      ELSIF p_validation_entity_short_name = 'LINE' THEN
         l_header_id := oe_line_security.g_record.header_id;
      END IF;

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'P_VALIDATION_ENTITY_SHORT_NAME: '||P_VALIDATION_ENTITY_SHORT_NAME||':header_id:'||l_header_id ) ;
      END IF;

      -- 3726282 Added the outer If loop alone
      IF p_validation_entity_short_name in ('HEADER','LINE') THEN
         IF l_header_id IS NULL OR
            l_header_id = FND_API.G_MISS_NUM
         THEN
            OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);
            p_result := 0;
         ELSE
            p_result := 0;
            -- commented out the following code, as the payment shown
            -- on order header is always invoice payment when multiple
            -- payments is enabled, we should allow update. and there
            -- would not exist any line payment if prepayment exists.
            /**
            BEGIN
               SELECT 1
               INTO p_result
               FROM oe_payments
               WHERE header_id = l_header_id
               AND   payment_set_id is not null
               AND   rownum=1;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                p_result := 0;
            END;
            ****/
         END IF;
      END IF;

      -- 3726282 Start
      IF p_validation_entity_short_name = 'HEADER_PAYMENT' THEN
         IF(oe_header_payment_security.g_record.payment_set_id is NOT NULL) THEN
           p_result := 1;
         ELSE
           p_result := 0;
         END IF;
      ELSIF p_validation_entity_short_name = 'LINE_PAYMENT' THEN
           IF ( oe_line_payment_security.g_record.payment_set_id is not NULL) THEN
              p_result := 1;
           ELSE
              p_result := 0;
           END IF;
      END IF;
      -- 3726282 End
   END IF;
--serla end
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING OE_PREPAYMENT_UTIL.IS_PREPAID WITH RESULT: '||P_RESULT ) ;
   END IF;
END Is_prepaid;

PROCEDURE Get_PrePayment_Info
( p_header_id        IN   NUMBER
, x_payment_set_id OUT NOCOPY NUMBER

, x_prepaid_amount OUT NOCOPY NUMBER

) IS
l_payment_type_code VARCHAR2(30);
l_payment_term_id NUMBER;
l_prepayment_flag VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OE_PAYMENT_UTIL.GET_PREPAYMENT_INFO' ) ;
   END IF;

--serla begin
   IF IS_MULTIPLE_PAYMENTS_ENABLED THEN
      BEGIN
        SELECT max(payment_set_id)
             , sum(nvl(prepaid_amount, 0))
        INTO x_payment_set_id
            ,x_prepaid_amount
        FROM oe_payments
        WHERE header_id = p_header_id
        AND   payment_set_id IS NOT NULL;
      EXCEPTION
       WHEN NO_DATA_FOUND THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'IN NODATA FOUND - OE_PAYMENT_UTIL.GET_PREPAYMENT_INFO' ) ;
         END IF;
         x_payment_set_id := NULL;
         x_prepaid_amount := NULL;
      END;
   ELSE
--serla end
      IF Is_Prepaid_Order(p_header_id) = 'N' THEN
         x_payment_set_id := NULL;
         x_prepaid_amount := NULL;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'NOT PREPAID TERMS , RETURNING NULL PAYMENT_SET_ID' ) ;
         END IF;
      ELSE
         BEGIN
           SELECT payment_set_id
                 ,prepaid_amount
           INTO x_payment_set_id
               ,x_prepaid_amount
           FROM oe_payments
           WHERE header_id = p_header_id
           AND   payment_type_code = 'CREDIT_CARD';
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'PREPAID ORDER. X_PAYMENT_SET_ID: '||X_PAYMENT_SET_ID||' , X_PREPAID_AMOUNT: '||X_PREPAID_AMOUNT ) ;
           END IF;
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
            IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'IN NODATA FOUND - OE_PAYMENT_UTIL.GET_PREPAYMENT_INFO' ) ;
            END IF;
            x_payment_set_id := NULL;
            x_prepaid_amount := NULL;
           WHEN Too_many_rows THEN
             IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'IN TOO MANY ROWS - OE_PAYMENT_UTIL.GET_PREPAYMENT_INFO' ) ;
             END IF;
             x_payment_set_id := NULL;
             x_prepaid_amount := NULL;
         END;
      END IF;
--serla begin
   END IF;
--serla end

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING OE_PAYMENT_UTIL.GET_PREPAYMENT_INFO - PAYMENT_SET_ID: '|| X_PAYMENT_SET_ID||' PREPAID_AMOUNT : '||X_PREPAID_AMOUNT ) ;
   END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          FND_MSG_PUB.Add_Exc_Msg
               (   G_PKG_NAME
                  ,'OE_PAYMENTS_UTIL.Get_PrePayment_Info'
               );
        END IF;

END Get_PrePayment_Info;

PROCEDURE PendProcessPayments_Conc_Prog
( errbuf OUT NOCOPY VARCHAR2

,retcode OUT NOCOPY NUMBER
  ,p_operating_unit		IN  NUMBER --MOAC Changes
  ,p_ppp_hold                   IN  VARCHAR2
  ,p_epay_failure_hold          IN  VARCHAR2
  ,p_epay_server_failure_hold   IN  VARCHAR2
  ,p_payment_authorization_hold IN  VARCHAR2
  ,p_order_type_id              IN  NUMBER
  ,p_order_number_from          IN  NUMBER
  ,p_order_number_to            IN  NUMBER
  ,p_customer_number_from       IN  VARCHAR2
  ,p_customer_number_to         IN  VARCHAR2
  ,p_debug_level                IN  NUMBER
  ,p_customer_class_code        IN  VARCHAR2
  ,p_credit_card_number         IN  VARCHAR2
  ,p_credit_card_type           IN  VARCHAR2
  ,p_bill_to_org_id             IN  NUMBER
  ,p_booked_date_since          IN  VARCHAR2
)
IS
l_msg_count         NUMBER        := 0 ;
l_msg_data          VARCHAR2(2000):= NULL ;
l_message_text      VARCHAR2(2000);
l_return_status     VARCHAR2(30)   := NULL ;
l_orig_sys_document_ref   VARCHAR2(50);
l_source_document_id      NUMBER;
l_order_source_id         NUMBER;
l_change_sequence         VARCHAR2(50);
l_source_document_type_id NUMBER;

l_order_type_id                       NUMBER := p_order_type_id;
l_order_number_from                   NUMBER := p_order_number_from;
l_order_number_to                     NUMBER := p_order_number_to;
l_customer_number_from                VARCHAR2(30) := p_customer_number_from;
l_customer_number_to                  VARCHAR2(30) := p_customer_number_to;
l_customer_class_code                 VARCHAR2(30) := p_customer_class_code;

l_count_header                        NUMBER := 0;
l_count_header_warning                NUMBER := 0;
l_count_header_success                NUMBER := 0;
l_count_header_failure                NUMBER := 0;

l_header_id                           NUMBER;
l_request_id                          NUMBER;

l_debug_file                          VARCHAR2(30);
l_filename                            VARCHAR2(100);
l_database                            VARCHAR2(100);
l_hold1  NUMBER:= 13;
l_hold2  NUMBER:= 14;
l_hold3  NUMBER:= 15;
l_hold4  NUMBER:= 16;  -- credit card authorization hold
l_booked_date_since DATE;
l_hold_id	NUMBER;

p_process_prepayment    VARCHAR2(1) := 'N';
p_process_authorization VARCHAR2(1) := 'N';

--bug4689411
l_old_org_id NUMBER;

-- bug 4967981
l_hold_exists     VARCHAR2(1) := NULL ;

-- We may need to have one more cursor to avoid joining to ra_customers
-- when all the parameters related to customer (customer_number from/to,
-- customer class) are null
CURSOR ppp_order_hold_cur IS
 /****
  SELECT * MOAC_SQL_CHANGE * oh.header_id
        ,oh.orig_sys_document_ref
        ,oh.source_document_id
        ,oh.order_source_id
        ,oh.change_sequence
        ,oh.source_document_type_id
  FROM oe_order_headers oh
      ,oe_order_holds_all hd --moac
      ,oe_hold_sources_all hs --moac
      ,iby_trxn_extensions_v	ite -- ccencryption
      ,oe_payments op
  WHERE oh.header_id= hd.header_id
  AND   hd.hold_source_id = hs.hold_source_id
  AND   hs.hold_id in (l_hold1, l_hold2, l_hold3, l_hold4)
           * (SELECT hold_id   -- replace the sql with hardcoded hold_id once it is seeded: Also based on what holds should be processed
                    FROM oe_hold_definitions
                    WHERE type_code='EPAYMENT') *
  AND   hs.hold_entity_code = 'O'
  AND   hs.released_flag = 'N'
  AND   oh.order_type_id = NVL(p_order_type_id, oh.order_type_id)
  AND   oh.org_id = hs.org_id    --moac
  AND   hs.org_id = hd.org_id --moac
  AND   oh.sold_to_org_id IN (SELECT cust_account_id
                            FROM hz_cust_accounts
                            WHERE account_number BETWEEN NVL(p_customer_number_from, account_number)
                                  AND NVL(p_customer_number_to, account_number)
                            AND nvl(CUSTOMER_CLASS_CODE, 'XXX') = NVL(p_customer_class_code, nvl(CUSTOMER_CLASS_CODE, 'XXX')))
  AND   oh.order_number BETWEEN NVL(p_order_number_from, oh.order_number)
        AND NVL(p_order_number_to, oh.order_number)
  AND oh.payment_type_code = 'CREDIT_CARD'
 -- AND oh.credit_card_number = NVL(p_credit_card_number, oh.credit_card_number)
 -- AND nvl(oh.credit_card_code, 'XXX') = NVL(p_credit_card_type, nvl(oh.credit_card_code, 'XXX'))
  AND oh.header_id = ite.order_id
  AND ite.cc_number_hash1 = DECODE(p_credit_card_number, null, ite.cc_number_hash1, iby_fndcpt_setup_pub.get_hash(p_Credit_Card_Number, 'F'))
  AND ite.cc_number_hash2 = DECODE(p_credit_card_number, null, ite.cc_number_hash2, iby_fndcpt_setup_pub.get_hash(p_credit_card_number, 'T'))
  AND nvl(ite.card_issuer_code, 'XXX') = nvl(p_credit_card_type, nvl(ite.card_issuer_code, 'XXX'))
  AND oh.invoice_to_org_id = NVL(p_bill_to_org_id, oh.invoice_to_org_id)
  AND oh.booked_date >= NVL(l_booked_date_since, oh.booked_date)
  AND oh.order_category_code <> 'RETURN'
  AND oh.header_id = op.header_id
  AND op.trxn_extension_id = ite.trxn_extension_id
  -- orders on header level holds for multiple payments
  UNION
  ***/

 (SELECT distinct /* MOAC_SQL_CHANGE */ oh.header_id
        ,oh.orig_sys_document_ref
        ,oh.source_document_id
        ,oh.order_source_id
        ,oh.change_sequence
        ,oh.source_document_type_id
        ,oh.org_id --bug4689411
  FROM oe_order_headers oh
      ,oe_order_holds_all hd --moac
      ,oe_hold_sources_all hs --moac
      ,oe_payments op
       -- iby_trxn_extensions_v	ite -- ccencryption
      ,IBY_FNDCPT_TX_EXTENSIONS x
      ,IBY_PMT_INSTR_USES_ALL u
      ,IBY_CREDITCARD c
  WHERE oh.header_id= hd.header_id
  AND   hd.hold_source_id = hs.hold_source_id
  AND   hs.hold_id in (l_hold1, l_hold2, l_hold3, l_hold4)
           /* (SELECT hold_id   -- replace the sql with hardcoded hold_id once it is seeded: Also based on what holds should be processed
                    FROM oe_hold_definitions
                    WHERE type_code='EPAYMENT') */
  AND   hs.hold_entity_code = 'O'
  AND   hs.released_flag = 'N'
  AND   oh.order_type_id = NVL(p_order_type_id, oh.order_type_id)
  AND   oh.org_id = hs.org_id -- moac
  AND   hs.org_id = hd.org_id --moac
  AND   oh.sold_to_org_id IN (SELECT cust_account_id
                            FROM hz_cust_accounts
                            WHERE account_number BETWEEN NVL(p_customer_number_from, account_number)
                                  AND NVL(p_customer_number_to, account_number)
                            AND nvl(CUSTOMER_CLASS_CODE, 'XXX') = NVL(p_customer_class_code, nvl(CUSTOMER_CLASS_CODE, 'XXX')))
  AND   oh.order_number BETWEEN NVL(p_order_number_from, oh.order_number)
        AND NVL(p_order_number_to, oh.order_number)
  AND oh.header_id = op.header_id
  AND op.header_id = x.order_id
  AND c.cc_number_hash1 = DECODE(p_credit_card_number, null, c.cc_number_hash1, iby_fndcpt_setup_pub.get_hash(p_Credit_Card_Number, 'F'))
  AND c.cc_number_hash2 = DECODE(p_credit_card_number, null, c.cc_number_hash2, iby_fndcpt_setup_pub.get_hash(p_credit_card_number, 'T'))
  AND nvl(c.card_issuer_code, 'XXX') = nvl(p_credit_card_type, nvl(c.card_issuer_code, 'XXX'))
  AND op.trxn_extension_id = x.trxn_extension_id
  AND x.instr_assignment_id = u.instrument_payment_use_id
  AND u.instrument_id =  c.instrid
  AND op.payment_type_code = 'CREDIT_CARD'
  AND oh.invoice_to_org_id = NVL(p_bill_to_org_id, oh.invoice_to_org_id)
  AND oh.booked_date >= NVL(l_booked_date_since, oh.booked_date)
  AND oh.order_category_code <> 'RETURN'

  -- for CASH, CHECK payment types, no need to join with IBY table.
  UNION
  SELECT distinct /* MOAC_SQL_CHANGE */ oh.header_id
        ,oh.orig_sys_document_ref
        ,oh.source_document_id
        ,oh.order_source_id
        ,oh.change_sequence
        ,oh.source_document_type_id
        ,oh.org_id --bug4689411
  FROM oe_order_headers oh
      ,oe_order_holds_all hd --moac
      ,oe_hold_sources_all hs --moac
      ,oe_payments op
  WHERE oh.header_id= hd.header_id
  AND   hd.hold_source_id = hs.hold_source_id
  AND   hs.hold_id in (l_hold1, l_hold2, l_hold3)
           /* (SELECT hold_id   -- replace the sql with hardcoded hold_id once it is seeded: Also based on what holds should be processed
                    FROM oe_hold_definitions
                    WHERE type_code='EPAYMENT') */
  AND   hs.hold_entity_code = 'O'
  AND   hs.released_flag = 'N'
  AND   oh.order_type_id = NVL(p_order_type_id, oh.order_type_id)
  AND   oh.org_id = hs.org_id    --moac
  AND   hs.org_id = hd.org_id --moac
  AND   oh.sold_to_org_id IN (SELECT cust_account_id
                            FROM hz_cust_accounts
                            WHERE account_number BETWEEN NVL(p_customer_number_from, account_number)
                                  AND NVL(p_customer_number_to, account_number)
                            AND nvl(CUSTOMER_CLASS_CODE, 'XXX') = NVL(p_customer_class_code, nvl(CUSTOMER_CLASS_CODE, 'XXX')))
  AND   oh.order_number BETWEEN NVL(p_order_number_from, oh.order_number)
        AND NVL(p_order_number_to, oh.order_number)
  AND op.payment_type_code IN('CASH', 'CHECK')
  AND p_credit_card_number IS NULL
  AND oh.invoice_to_org_id = NVL(p_bill_to_org_id, oh.invoice_to_org_id)
  AND oh.booked_date >= NVL(l_booked_date_since, oh.booked_date)
  AND oh.order_category_code <> 'RETURN'
  AND oh.header_id = op.header_id

  -- get all orders that have at least one line being on line level
  -- authorization holds for multiple payments
  UNION
  SELECT distinct /* MOAC_SQL_CHANGE */ oh.header_id
        ,oh.orig_sys_document_ref
        ,oh.source_document_id
        ,oh.order_source_id
        ,oh.change_sequence
        ,oh.source_document_type_id
        ,oh.org_id --bug4689411
  FROM oe_order_lines_all ol --moac
      ,oe_order_headers oh
      ,oe_order_holds_all hd --moac
      ,oe_hold_sources_all hs --moac
      ,oe_payments op
      -- ,iby_trxn_extensions_v	ite -- ccencryption
      ,IBY_FNDCPT_TX_EXTENSIONS x
      ,IBY_PMT_INSTR_USES_ALL u
      ,IBY_CREDITCARD c
  WHERE oh.header_id = ol.header_id
  AND   ol.line_id= hd.line_id
  AND   hd.hold_source_id = hs.hold_source_id
  AND   hs.hold_id in (l_hold1, l_hold2, l_hold3, l_hold4)
           /* (SELECT hold_id   -- replace the sql with hardcoded hold_id once it is seeded: Also based on what holds should be processed
                    FROM oe_hold_definitions
                    WHERE type_code='EPAYMENT') */
  AND   hs.hold_entity_code = 'O'
  AND   hs.released_flag = 'N'
  AND   oh.order_type_id = NVL(p_order_type_id, oh.order_type_id)
  AND   oh.org_id = hs.org_id --moac
  AND   hs.org_id = hd.org_id --moac
  AND   oh.sold_to_org_id IN (SELECT cust_account_id
                            FROM hz_cust_accounts
                            WHERE account_number BETWEEN NVL(p_customer_number_from, account_number)
                                  AND NVL(p_customer_number_to, account_number)
                            AND nvl(CUSTOMER_CLASS_CODE, 'XXX') = NVL(p_customer_class_code, nvl(CUSTOMER_CLASS_CODE, 'XXX')))
  AND   oh.order_number BETWEEN NVL(p_order_number_from, oh.order_number)
        AND NVL(p_order_number_to, oh.order_number)
  AND ol.line_id = op.line_id
  AND ol.header_id = op.header_id
  AND op.payment_type_code = 'CREDIT_CARD'
  AND ol.header_id = x.order_id
  AND ol.line_id = x.trxn_ref_number1	 --order line_id
  AND c.cc_number_hash1 = DECODE(p_credit_card_number, null, c.cc_number_hash1, iby_fndcpt_setup_pub.get_hash(p_Credit_Card_Number, 'F'))
  AND c.cc_number_hash2 = DECODE(p_credit_card_number, null, c.cc_number_hash2, iby_fndcpt_setup_pub.get_hash(p_credit_card_number, 'T'))
 AND nvl(c.card_issuer_code, 'XXX') = nvl(p_credit_card_type,
nvl(c.card_issuer_code, 'XXX'))
  AND oh.invoice_to_org_id = NVL(p_bill_to_org_id, oh.invoice_to_org_id)
  AND oh.booked_date >= NVL(l_booked_date_since, oh.booked_date)
  AND oh.order_category_code <> 'RETURN'
  AND op.trxn_extension_id = x.trxn_extension_id)
  ORDER BY 7; --bug4689411 Using the column number to order by org_id. Please make sure that org_id is the 7th column when any changes are made to the select clause.


/* -----------------------------------------------------------
   Messages cursor
   -----------------------------------------------------------
*/
    CURSOR l_msg_cursor IS

    SELECT /*+ INDEX (a,OE_PROCESSING_MSGS_N2)
           USE_NL (a b) */
           a.header_id
         , a.order_source_id
         , a.original_sys_document_ref
         , a.source_document_id
         , a.change_sequence
         , a.source_document_type_id
         , b.message_text
      FROM oe_processing_msgs a, oe_processing_msgs_tl b
      WHERE a.request_id = l_request_id
       AND a.transaction_id = b.transaction_id
       AND b.language = oe_globals.g_lang
  ORDER BY a.order_source_id, a.original_sys_document_ref, a.header_id;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_access_mode VARCHAR2(40);  --R12 MOAC Changes
l_org_id NUMBER;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OE_PAYMENTS_UTIL.PENDPROCESSPAYMENTS_CONC_PROG' ) ;
       oe_debug_pub.add('Operating unit passed -->'||p_operating_unit);
   END IF;
  --R12 MOAC Changes
  --MOAC set policy context for single Org
  IF p_operating_unit IS NOT NULL THEN
    MO_GLOBAL.set_policy_context('S',p_operating_unit);
  END IF;

  IF l_debug_level >0 THEN
     l_org_id := MO_GLOBAL.get_current_org_id;
     l_access_mode := MO_GLOBAL.get_access_mode;
     oe_debug_pub.add('Access Mode:'|| l_access_mode);
     oe_debug_pub.add('Operating unit returned from mo_global-->'|| l_org_id);
  END IF;
  --R12 MOAC Changes

   IF OE_CODE_CONTROL.Get_Code_Release_Level < '110508' THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXUPPY: BELOW PACKH , PREPAYMENTS NOT ENABLED' ) ;
      END IF;
      fnd_file.put_line(FND_FILE.OUTPUT, 'Pack H or above must be installed to use this concurrent program');
      RETURN;
   END IF;
   l_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_ppp_hold = 'N' THEN
      l_hold1 := 0 ;
   END IF;
   IF p_epay_failure_hold = 'N' THEN
      l_hold2 := 0 ;
   END IF;
   IF p_epay_server_failure_hold = 'N' THEN
      l_hold3 := 0 ;
   END IF;
   IF p_payment_authorization_hold = 'N' THEN
      l_hold4 := 0 ;
   END IF;

   l_booked_date_since := fnd_date.canonical_to_date(p_booked_date_since);

/* -----------------------------------------------------------
   Log Output file
   -----------------------------------------------------------*/
   fnd_file.put_line(FND_FILE.OUTPUT, 'Pending Process Payments Concurrent Program');
   fnd_file.put_line(FND_FILE.OUTPUT, '');
   fnd_file.put_line(FND_FILE.OUTPUT, 'Concurrent Program Parameters');
   fnd_file.put_line(FND_FILE.OUTPUT, 'Operating Unit: '|| p_operating_unit); --MOAC Changes
   fnd_file.put_line(FND_FILE.OUTPUT, 'PPP Hold Selected: '|| p_ppp_hold);
   fnd_file.put_line(FND_FILE.OUTPUT, 'Epayment Failure Hold Selected: '|| p_epay_failure_hold);
   fnd_file.put_line(FND_FILE.OUTPUT, 'Epayment Server Failure Hold Selected: '|| p_epay_server_failure_hold);
   fnd_file.put_line(FND_FILE.OUTPUT, 'Payment Authorizatin Hold Selected: '|| p_payment_authorization_hold);
   fnd_file.put_line(FND_FILE.OUTPUT, 'Order Type: '|| p_order_type_id);
   fnd_file.put_line(FND_FILE.OUTPUT, 'Order Number From: '|| p_order_number_from);
   fnd_file.put_line(FND_FILE.OUTPUT, 'Order Number To: '|| p_order_number_to);
   fnd_file.put_line(FND_FILE.OUTPUT, 'Customer Number From: '|| p_customer_number_from);
   fnd_file.put_line(FND_FILE.OUTPUT, 'Customer Number To: '|| p_customer_number_to);
   fnd_file.put_line(FND_FILE.OUTPUT, 'Customer Class: '|| p_customer_class_code);
   fnd_file.put_line(FND_FILE.OUTPUT, 'Credit Card Number: '|| p_credit_card_number);
   fnd_file.put_line(FND_FILE.OUTPUT, 'Card Brand: '|| p_credit_card_type);
   fnd_file.put_line(FND_FILE.OUTPUT, 'Bill To Org: '|| p_bill_to_org_id);
   fnd_file.put_line(FND_FILE.OUTPUT, 'Booked Date Since: '|| p_booked_date_since);
   fnd_file.put_line(FND_FILE.OUTPUT, '');

   -----------------------------------------------------------
   -- Setting Debug Mode and File
   -----------------------------------------------------------

   FND_FILE.Put_Line(FND_FILE.OUTPUT,'Debug Level: '||nvl(p_debug_level,1));
-- commenting out as debug mode will be set to 'CONC' automatically when
-- debug level is > 0 and the debug messages can be seen in the conc program log file
/*
   IF nvl(p_debug_level, 1) > 0 THEN
      l_filename := OE_DEBUG_PUB.set_debug_mode ('FILE');
      FND_FILE.Put_Line(FND_FILE.OUTPUT,'Debug File: ' || l_filename);
      FND_FILE.Put_Line(FND_FILE.OUTPUT, '');
   END IF;

   l_filename := OE_DEBUG_PUB.set_debug_mode ('CONC');
*/
/* -----------------------------------------------------------
   Get Concurrent Request Id
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE GETTING REQUEST ID' ) ;
   END IF;

   FND_PROFILE.Get('CONC_REQUEST_ID', l_request_id);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'REQUEST ID: '|| TO_CHAR ( L_REQUEST_ID ) ) ;
   END IF;
   fnd_file.put_line(FND_FILE.OUTPUT, 'Request Id: '|| to_char(l_request_id));
--   fnd_file.put_line(FND_FILE.OUTPUT, 'l_hold1:l_hold2:l_hold3 : '|| l_hold1||':'||l_hold2||':'||l_hold3);

   l_count_header := 0;
   l_count_header_success := 0;
   l_count_header_failure := 0;
   l_old_org_id := -99; --bug4689411

   OPEN ppp_order_hold_cur;
   LOOP
      FETCH ppp_order_hold_cur
      INTO l_header_id
         , l_orig_sys_document_ref
         , l_source_document_id
         , l_order_source_id
         , l_change_sequence
         , l_source_document_type_id
	 , l_org_id; --bug4689411

      EXIT WHEN ppp_order_hold_cur%NOTFOUND;

      --bug4689411 If the Operating Unit is not passed to the concurrent program, the context needs to be set for each accessible OU before calling Process_Payments
      IF p_operating_unit is NULL THEN
	 IF l_org_id <> l_old_org_id THEN
	    MO_GLOBAL.set_policy_context('S',l_org_id);
	    IF l_debug_level > 0 THEN
	       oe_debug_pub.add('Setting the context for org_id ' || l_org_id);
	    END IF;
	    l_old_org_id := l_org_id;
	 END IF;
      END IF;
      --bug4689411 end

      fnd_file.put_line(FND_FILE.OUTPUT, 'Processing header_id: '||l_header_id);
      l_count_header       := l_count_header       + 1;
      IF l_count_header = 1 THEN
         -- Set Message Context
         OE_MSG_PUB.set_msg_context(
              p_entity_code           => 'HEADER'
             ,p_entity_id                  => l_header_id
             ,p_header_id                  => l_header_id
             ,p_line_id                    => null
             ,p_orig_sys_document_ref      => l_orig_sys_document_ref
             ,p_orig_sys_document_line_ref => null
             ,p_change_sequence            => l_change_sequence
             ,p_source_document_id         => l_source_document_id
             ,p_source_document_line_id    => null
             ,p_order_source_id            => l_order_source_id
             ,p_source_document_type_id    => l_source_document_type_id
             );
      ELSIF l_count_header > 1 THEN
         -- Update Message Context
         OE_MSG_PUB.update_msg_context(
              p_entity_code                => 'HEADER'
             ,p_entity_id                  => l_header_id
             ,p_header_id                  => l_header_id
             ,p_line_id                    => null
             ,p_orig_sys_document_ref      => l_orig_sys_document_ref
             ,p_orig_sys_document_line_ref => null
             ,p_change_sequence            => l_change_sequence
             ,p_source_document_id         => l_source_document_id
             ,p_source_document_line_id    => null
             ,p_order_source_id            => l_order_source_id
             ,p_source_document_type_id    => l_source_document_type_id
             );
      END IF;

      IF IS_MULTIPLE_PAYMENTS_ENABLED THEN
         IF p_payment_authorization_hold = 'Y' THEN
            p_process_authorization := 'Y';
         END IF;
         IF p_ppp_hold ='Y'
            OR p_epay_failure_hold = 'Y'
            OR p_epay_server_failure_hold = 'Y' THEN
               p_process_prepayment := 'Y';
         END IF;
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CALLING PROCESS_PAYMENT FOR HEADER_ID: '||L_HEADER_ID ) ;
         END IF;

         oe_prepayment_pvt.process_payments(p_header_id => l_header_id
                                          ,p_calling_action => NULL
                                          ,p_amount => NULL
                                          ,p_delayed_request => NULL
                                          ,p_process_prepayment => p_process_prepayment
                                          ,p_process_authorization => p_process_authorization
                                          ,x_msg_count => l_msg_count
                                          ,x_msg_data => l_msg_data
                                          ,x_return_status => l_return_status);

         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'AFTER CALLING PROCESS_PAYMENT, L_RETURN_STATUS: '||L_RETURN_STATUS ) ;
         END IF;
      ELSE

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'CALLING VERIFY_PAYMENT FOR HEADER_ID: '||L_HEADER_ID ) ;
         END IF;
         OE_Verify_Payment_PUB.Verify_Payment(p_header_id => l_header_id
                                             ,p_calling_action => NULL
                                             ,p_delayed_request => NULL
                                             ,p_msg_count => l_msg_count
                                             ,p_msg_data => l_msg_data
                                             ,p_return_status => l_return_status);
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'AFTER CALLING VERIFY_PAYMENT , L_RETURN_STATUS: '||L_RETURN_STATUS ) ;
         END IF;
      END IF;

      IF l_return_status = FND_API.G_RET_STS_ERROR OR
         l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
         l_count_header_failure := l_count_header_failure + 1;
      ELSE
         --bug 4967981 start
         OE_Prepayment_PVT.Any_Payment_Hold_Exists(p_header_id     => l_header_id,
                                                   p_hold_exists => l_hold_exists);
         IF l_hold_exists = 'Y' THEN
            l_count_header_failure := l_count_header_failure + 1;
         ELSE
           l_count_header_success := l_count_header_success + 1;
         END IF;
         --bug 4967981 end
      END IF;

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'UNEXPECTED ERROR' ) ;
         END IF;
   --    OE_MSG_PUB.Save_Messages(p_request_id => l_request_id);
   --    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'EXPECTED ERROR' ) ;
         END IF;
   --    OE_MSG_PUB.Save_Messages(p_request_id => l_request_id);
   --    RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- releasing the holds.
      -- commented out for bug 4967981
      /***
      IF l_return_status = FND_API.G_RET_STS_SUCCESS
         AND IS_MULTIPLE_PAYMENTS_ENABLED THEN

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OEXUPPYB: releasing payment hold.' ) ;
         END IF;

        IF p_ppp_hold = 'Y' THEN
          OE_Prepayment_PVT.Release_Payment_Hold
                                ( p_header_id     => l_header_id
                                , p_hold_id	  => 13
                                , p_msg_count     => l_msg_count
                                , p_msg_data      => l_msg_data
                                , p_return_status => l_return_status
                                );

          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;

        IF p_epay_failure_hold = 'Y' THEN
          OE_Prepayment_PVT.Release_Payment_Hold
                                ( p_header_id     => l_header_id
                                , p_hold_id	  => 14
                                , p_msg_count     => l_msg_count
                                , p_msg_data      => l_msg_data
                                , p_return_status => l_return_status
                                );

          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;

        IF p_epay_server_failure_hold = 'Y' THEN
          OE_Prepayment_PVT.Release_Payment_Hold
                                ( p_header_id     => l_header_id
                                , p_hold_id	  => 15
                                , p_msg_count     => l_msg_count
                                , p_msg_data      => l_msg_data
                                , p_return_status => l_return_status
                                );

          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;

        IF p_payment_authorization_hold = 'Y' THEN
          OE_Prepayment_PVT.Release_Payment_Hold
                                ( p_header_id     => l_header_id
                                , p_hold_id	  => 16
                                , p_msg_count     => l_msg_count
                                , p_msg_data      => l_msg_data
                                , p_return_status => l_return_status
                                );

          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;
      END IF;
      ***/   -- end of bug 4967981

     OE_MSG_PUB.Save_Messages(p_request_id => l_request_id);
   END LOOP;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'NO. OF ORDERS FOUND: ' || L_COUNT_HEADER ) ;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'NO. OF ORDERS SUCCESSFUL: '|| L_COUNT_HEADER_SUCCESS ) ;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'NO. OF ORDERS FAILED: ' || L_COUNT_HEADER_FAILURE ) ;
   END IF;

   fnd_file.put_line(FND_FILE.OUTPUT,'No. of orders found: ' ||l_count_header);
   fnd_file.put_line(FND_FILE.OUTPUT,'No. of orders processed successfully: '||l_count_header_success);
   fnd_file.put_line(FND_FILE.OUTPUT,'No. of orders failed: ' ||l_count_header_failure);
   fnd_file.put_line(FND_FILE.OUTPUT,'');

/*    -----------------------------------------------------------
      Messages
      -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE MESSAGES LOOP' ) ;
      END IF;

      fnd_file.put_line(FND_FILE.OUTPUT,'');
      fnd_file.put_line(FND_FILE.OUTPUT,'Source/Order/Seq/Line    Message');
      OPEN l_msg_cursor;
      LOOP
        FETCH l_msg_cursor
         INTO l_header_id
            , l_order_source_id
            , l_orig_sys_document_ref
            , l_source_document_id
            , l_change_sequence
            , l_source_document_type_id
            , l_message_text;
         EXIT WHEN l_msg_cursor%NOTFOUND;

         fnd_file.put_line(FND_FILE.OUTPUT,to_char(l_header_id)
                                            ||'/'||to_char(l_order_source_id)
                                            ||'/'||l_orig_sys_document_ref
                                            ||'/'||l_source_document_id
                                            ||'/'||l_change_sequence
                                            ||'/'||l_source_document_type_id
                                            ||' '||l_message_text);
         fnd_file.put_line(FND_FILE.OUTPUT,'');
      END LOOP;

   retcode := 0;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING OE_PAYMENTS_UTIL.PENDPROCESSPAYMENTS_CONC_PROG' ) ;
   END IF;
--rollback;
EXCEPTION

 WHEN FND_API.G_EXC_ERROR THEN
       l_return_status := FND_API.G_RET_STS_ERROR ;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
       END IF;
       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'PendProcessPayments_Conc_Prog');
       END IF;

       fnd_file.put_line(FND_FILE.OUTPUT,'Unexpected error: ' || sqlerrm);
       OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

 WHEN OTHERS THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
       END IF;
       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'PendProcessPayments_Conc_Prog');
       END IF;

       fnd_file.put_line(FND_FILE.OUTPUT,'Unexpected error: ' || sqlerrm);

END PendProcessPayments_Conc_Prog;

/*-------------------------------------------------------------------
Function Is_Prepaid_Order
Returns 'Y' if the Order is being paid using a Credit Card AND
               the payment term is of prepayment type.
---------------------------------------------------------------------*/
FUNCTION Is_Prepaid_Order
(  p_header_rec  IN  OE_Order_PUB.Header_Rec_Type )
RETURN  VARCHAR2
IS
l_prepayment_flag VARCHAR2(1);
l_payment_term_rec	Payment_Term_Rec_Type;
l_count NUMBER;
l_header_id NUMBER ;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXUPPYB: IN IS_PREPAID_ORDER' ) ;
  END IF;

  -- OM code level is below Pack H.
  IF OE_CODE_CONTROL.Get_Code_Release_Level < '110508' THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PREPAYMENT IS NOT SUPPORTED: OM PACK H IS NOT INSTALLED.' , 3 ) ;
    END IF;
    RETURN ('N');
  END IF;
  IF IS_MULTIPLE_PAYMENTS_ENABLED THEN
     l_header_id := p_header_rec.header_id;
     BEGIN
       SELECT count(*)
       INTO l_count
       FROM oe_payments
       WHERE header_id = l_header_id
       AND payment_type_code <> 'COMMITMENT'
       AND   nvl(payment_collection_event, 'PREPAY') = 'PREPAY';
       IF l_count > 0 THEN
          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'There are prepayments for the order-'||l_count , 3 ) ;
          END IF;
          RETURN ('Y');
       ELSE
          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'No prepayments for the order' , 3 ) ;
          END IF;
          RETURN ('N');
       END IF;
     EXCEPTION
       WHEN OTHERS THEN
          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'In when others.. returning N' , 3);
          END IF;
          RETURN ('N');
     END;
  ELSE
     IF nvl(p_header_rec.payment_type_code, 'NULL') <> 'CREDIT_CARD' THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'PREPAYMENT IS NOT SUPPORTED: PAYMENT TYPE IS NOT CREDIT CARD.' , 3 ) ;
       END IF;
       RETURN ('N');

     ELSIF p_header_rec.payment_type_code = 'CREDIT_CARD' THEN
       IF g_payment_term_tbl.exists(p_header_rec.payment_term_id) THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'VALUE FOR IS_PREPAID_ORDER IS: ' ||G_PAYMENT_TERM_TBL ( P_HEADER_REC.PAYMENT_TERM_ID ) .IS_PREPAID_ORDER , 3 ) ;
           END IF;
         RETURN g_payment_term_tbl(p_header_rec.payment_term_id).is_prepaid_order;
       ELSE
         l_prepayment_flag := AR_PUBLIC_UTILS.Check_Prepay_Payment_Term(
                         p_header_rec.payment_term_id);

         IF nvl(l_prepayment_flag, 'N') = 'Y' THEN

           l_payment_term_rec.payment_term_id := p_header_rec.payment_term_id;
           l_payment_term_rec.is_prepaid_order := 'Y';

           g_payment_term_tbl(p_header_rec.payment_term_id) := l_payment_term_rec;


           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'OEXUPPYB: VALUE FOR IS_PREPAID_ORDER IS Y.' , 3 ) ;
           END IF;
           RETURN ('Y') ;
         ELSE
           l_payment_term_rec.payment_term_id := p_header_rec.payment_term_id;
           l_payment_term_rec.is_prepaid_order := 'N';

           g_payment_term_tbl(p_header_rec.payment_term_id) := l_payment_term_rec;

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'OEXUPPYB: VALUE FOR IS_PREPAID_ORDER IS N.' , 3 ) ;
           END IF;
           RETURN ('N') ;

         END IF;
       END IF;

     END IF;
  END IF; -- multiple payments enabled
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXUPPYB: EXITING IS_PREPAID_ORDER.' , 3 ) ;
  END IF;

END Is_Prepaid_Order;

-- overloading the function so that it also takes header_id.
FUNCTION Is_Prepaid_Order
(  p_header_id  IN  NUMBER )
RETURN  VARCHAR2
IS
l_prepayment_flag VARCHAR2(1);
l_payment_type_code	VARCHAR2(30);
l_payment_term_id	NUMBER;
l_payment_term_rec	Payment_Term_Rec_Type;
l_count NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXUPPYB: IN IS_PREPAID_ORDER' ) ;
  END IF;

  -- OM code level is below Pack H.
  IF OE_CODE_CONTROL.Get_Code_Release_Level < '110508' THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PREPAYMENT IS NOT SUPPORTED: OM PACK H IS NOT INSTALLED.' , 3 ) ;
    END IF;
    RETURN ('N');
  END IF;

  IF IS_MULTIPLE_PAYMENTS_ENABLED THEN
     BEGIN
       SELECT count(*)
       INTO l_count
       FROM oe_payments
       WHERE header_id = p_header_id
       AND   payment_type_code <> 'COMMITMENT'
       AND   nvl(payment_collection_event, 'PREPAY') = 'PREPAY';
       IF l_count > 0 THEN
          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'There are prepayments for the order-'||l_count, 3 ) ;
          END IF;
          RETURN ('Y');
       ELSE
          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'No prepayments for the order' , 3 ) ;
          END IF;
          RETURN ('N');
       END IF;
     EXCEPTION
       WHEN OTHERS THEN
          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'In when others.. returning N' , 3);
          END IF;
          RETURN ('N');
     END;
  ELSE
     BEGIN
       SELECT payment_type_code,payment_term_id
       INTO   l_payment_type_code, l_payment_term_id
       FROM   oe_order_headers
       WHERE  header_id = p_header_id;

     EXCEPTION WHEN NO_DATA_FOUND THEN
       null;
     END;

     IF nvl(l_payment_type_code, 'NULL') <> 'CREDIT_CARD' THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'PREPAYMENT IS NOT SUPPORTED: PAYMENT TYPE IS NOT CREDIT CARD.' , 3 ) ;
       END IF;
       RETURN ('N');

     ELSIF l_payment_type_code = 'CREDIT_CARD' THEN

       IF g_payment_term_tbl.exists(l_payment_term_id) THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'VALUE FOR IS_PREPAID_ORDER IS: ' ||G_PAYMENT_TERM_TBL ( L_PAYMENT_TERM_ID ) .IS_PREPAID_ORDER , 3 ) ;
           END IF;
         RETURN g_payment_term_tbl(l_payment_term_id).is_prepaid_order;
       ELSE
         l_prepayment_flag := AR_PUBLIC_UTILS.Check_Prepay_Payment_Term(
                         l_payment_term_id);

         IF nvl(l_prepayment_flag, 'N') = 'Y' THEN

           l_payment_term_rec.payment_term_id := l_payment_term_id;
           l_payment_term_rec.is_prepaid_order := 'Y';

           g_payment_term_tbl(l_payment_term_id) := l_payment_term_rec;


           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'OEXUPPYB: EXITING IS_PREPAID_ORDER IS TRUE' ) ;
           END IF;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'OEXUPPYB: VALUE FOR IS_PREPAID_ORDER IS Y.' , 3 ) ;
           END IF;
           RETURN ('Y') ;
         ELSE
           l_payment_term_rec.payment_term_id := l_payment_term_id;
           l_payment_term_rec.is_prepaid_order := 'N';

           g_payment_term_tbl(l_payment_term_id) := l_payment_term_rec;


           IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXUPPYB: EXITING IS_PREPAID_ORDER IS FALSE' ) ;
           END IF;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'OEXUPPYB: VALUE FOR IS_PREPAID_ORDER IS N.' , 3 ) ;
           END IF;
           RETURN ('N') ;

         END IF;
       END IF;

     END IF;
  END IF; -- multiple payments enabled
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXUPPYB: EXITING IS_PREPAID_ORDER.' , 3 ) ;
  END IF;

END Is_Prepaid_Order;  -- end of overloaded function

FUNCTION IS_MULTIPLE_PAYMENTS_ENABLED RETURN BOOLEAN
IS
l_code_release varchar2(30) := NULL;
l_multiple_payments varchar2(1) := NULL;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_lookup_code varchar2(30) := NULL;
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OEXUPPYB: IN IS_MULTIPLE_PAYMENTS_ENABLED' ) ;
   END IF;

  /***
   -- commented out the following code as this is not needed for R12.
   l_code_release := OE_CODE_CONTROL.Get_Code_Release_Level;

   IF l_code_release < '110510' THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'LESS THAN PACK J' , 3 ) ;
      END IF;
      Return False;
   END IF;

  -- Call AR to see if Multiple Prepayments patch from AR side is already
  -- there, by looking at their lookup_type and lookup_code.

  -- per AR, the following code is not needed any more, AR prepayment is
  -- always enabled in R12.

   Begin

      SELECT LOOKUP_CODE into l_lookup_code
      FROM AR_LOOKUPS
      WHERE LOOKUP_TYPE = 'AR_PREPAY_VERSION';

   EXCEPTION

     WHEN NO_DATA_FOUND THEN
          l_lookup_code := NULL;

   END;

    IF l_lookup_code is NULL THEN

       RETURN FALSE;

    ELSIF l_lookup_code <> 'V2' THEN

      RETURN FALSE;

   END IF;

   --commenting the following as Multiple payments is always enabled in R12 and returning True always
   l_multiple_payments := nvl(OE_Sys_Parameters.Value('MULTIPLE_PAYMENTS'), 'N');

   IF  l_multiple_payments = 'N' THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add( 'Multiple Payments is not enabled ' , 3 ) ;
      END IF;
      Return False;
   END IF;
   ***/


   Return True;

   EXCEPTION

      WHEN OTHERS THEN

        Return False;

END IS_MULTIPLE_PAYMENTS_ENABLED;

-- returns 'N' to go to the old code path before multiple payments.
-- returns 'Y' to go to the new code path for multiple payments.
FUNCTION Is_MultiPayments_Order
(  p_header_id  IN  NUMBER )
RETURN  VARCHAR2
IS
l_payment_count		NUMBER := 0;
l_multipay_count	NUMBER := 0;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add( 'Entering OE_Prepayment_Util.Is_Multipayments_Order. ' , 3 ) ;
  END IF;

  -- if exists any full prepaid orders.
  BEGIN
    SELECT count(*)
    INTO   l_payment_count
    FROM   oe_payments
    WHERE  payment_collection_event IS NULL
    AND    header_id = p_header_id;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    l_payment_count := 0;
  END;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add( 'l_payment_count is:  '||l_payment_count , 3 ) ;
  END IF;

  IF l_payment_count = 1 THEN

    -- this is a full prepaid order.
    RETURN 'N';
  ELSIF l_payment_count = 0 THEN
    BEGIN
      SELECT count(*)
      INTO   l_multipay_count
      FROM   oe_payments
      WHERE  header_id = p_header_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      l_multipay_count := 0;
    END;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add( 'l_multipay_count is:  '||l_multipay_count , 3 ) ;
    END IF;

    IF l_multipay_count = 0 THEN
      return 'N';
    ELSIF l_multipay_count > 0 THEN
      return 'Y';
    ELSE
      return 'N';
    END IF;

  ELSE
    return 'N';
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add( 'Entering OE_Prepayment_Util.Is_Multipayments_Order. ' , 3 ) ;
  END IF;

END Is_MultiPayments_Order;

Procedure UPLOAD_COMMITMENT(
                             p_line_id in number,
                             p_action in varchar2,
                            x_return_status out nocopy varchar2,
                            x_msg_count out nocopy number,
                            x_msg_data out nocopy varchar2) IS
l_return_status varchar2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

         x_return_status := l_return_status;

END UPLOAD_COMMITMENT;


-- This function is used to get the first installment
-- based on the payment term.
FUNCTION get_downpayment_amount( p_header_id in number,
                                  p_term_id in number,
                                  p_curr_code in varchar2,
                                  p_order_total in number)
return number is

 l_installment_tbl           ar_prepayments_pub.installment_tbl;
 l_downpayment               number := 0;
 l_term_id number;
 l_order_total number;
 l_subtotal number;
 l_discount number;
 l_charges number;
 l_tax number;
 l_curr_code varchar2(30) := p_curr_code;
 l_prepayment_flag VARCHAR2(1) := 'N';
 l_msg_count                 NUMBER := 0;
 l_msg_data                  VARCHAR2(2000) := null;
 l_return_status             VARCHAR2(1) := NULL;
 i number;
BEGIN

   /* Call AR to get the payment installment amount */

 l_installment_tbl.delete;

 IF p_header_id is not null THEN

    IF p_term_id is null or l_curr_code is null THEN

     Begin
       select payment_term_id, transactional_curr_code
       into l_term_id, l_curr_code
       from oe_order_headers_all
       where header_id = p_header_id;
     Exception
       when no_data_found then
         l_term_id := null;
         l_curr_code := null;
     End;
    Else
       l_term_id := p_term_id;
       l_curr_code := p_curr_code;
    END IF; -- if p_term_id is null or l_curr_code is null

   /* get prepayment flag for this payment term - l_term_id */

   /* comment out for bug 3524195
   if l_term_id is not null then
     oe_debug_pub.add('term id : ' || l_term_id);

      l_prepayment_flag := AR_PUBLIC_UTILS.Check_Prepay_Payment_Term(l_term_id);

     oe_debug_pub.add('prepayment_flag is : ' || l_prepayment_flag );
   end if;
   */

   IF p_order_total is null THEN

      OE_OE_TOTALS_SUMMARY.Order_Totals
                               (
                               p_header_id=>p_header_id,
                               p_subtotal =>l_subtotal,
                               p_discount =>l_discount,
                               p_charges  =>l_charges,
                               p_tax      =>l_tax
                               );

       l_order_total := nvl(l_subtotal,0) + nvl(l_charges,0) + nvl(l_tax,0);

       oe_debug_pub.add('order total is : ' || l_order_total);

    ELSE
       l_order_total := p_order_total;
    END IF; -- if p_order_total is null


     oe_debug_pub.add('currency code is : ' || l_curr_code);

    IF l_term_id is not null and
       l_order_total is not null and
       l_curr_code is not null
    -- and nvl(l_prepayment_flag, 'N') = 'Y'
    THEN

       oe_debug_pub.add('before calling AR');

        AR_PREPAYMENTS_PUB.get_installment(
                 p_term_id => l_term_id,
                 p_amount  => l_order_total,
                 p_currency_code => l_curr_code,
                 p_installment_tbl => l_installment_tbl,
                 x_return_status  => l_return_status,
                 x_msg_count      => l_msg_count,
                 x_msg_data       => l_msg_data );

       oe_debug_pub.add('after calling AR');

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              NULL;
             oe_debug_pub.add('return status is failure ');
              l_downpayment := 0;
              --RAISE FORM_TRIGGER_FAILURE;
         ELSE

           oe_debug_pub.add('installment api succeeded ');

           IF l_installment_tbl.count > 0 THEN
              i := l_installment_tbl.first;
              while i is not null loop

                if l_installment_tbl(i).installment_number = 1 then
                   l_downpayment := l_installment_tbl(i).installment_amount;
                    exit;
                 end if;

                i := l_installment_tbl.next(i);

              end loop; -- end of while loop
           ELSE
             oe_debug_pub.add('downpayment is equal to order total ');
              l_downpayment := l_order_total;
           END IF; -- if l_installment_tbl.count > 0

         END IF; -- end of l_return_status

      null;
      END IF; -- if l_term_id is not null and l_order_total is not null...

END IF; -- if p_header_id is not null

 return l_downpayment;

Exception

    When others then
       oe_debug_pub.add('exception handling ');
        l_downpayment := 0;
        return l_downpayment;

END get_downpayment_amount;

PROCEDURE Is_Prepaid_for_payment_term(p_application_id               IN NUMBER,
                     p_entity_short_name            in VARCHAR2,
                     p_validation_entity_short_name in VARCHAR2,
                     p_validation_tmplt_short_name  in VARCHAR2,
                     p_record_set_tmplt_short_name  in VARCHAR2,
                     p_scope                        in VARCHAR2,
p_result OUT NOCOPY NUMBER ) IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OE_PREPAYMENT_UTIL.IS_PREPAID_FOR_PAYMENT_TERM' ) ;
   END IF;
      IF OE_CODE_CONTROL.Get_Code_Release_Level < '110508' THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXUPPY: BELOW PACKH , PREPAYMENTS NOT ENABLED' )
;
      END IF;
      p_result := 0;
      RETURN;
   END IF;
--serla begin
   IF IS_MULTIPLE_PAYMENTS_ENABLED THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'Multiple payment enabled. Should not fire the constraint hence setting result to 0', 5);
      END IF;
      p_result := 0;
   ELSE
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'Calling Is_Prepaid', 5);
      END IF;
      Is_Prepaid(p_application_id      => p_application_id,
                 p_entity_short_name  => p_entity_short_name,
                 p_validation_entity_short_name => p_validation_entity_short_name,
                 p_validation_tmplt_short_name => p_validation_tmplt_short_name,
                 p_record_set_tmplt_short_name => p_record_set_tmplt_short_name,
                 p_scope        => p_scope,
                 p_result => p_result );
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'p_result after call to Is_Prepaid:'||p_result, 5);
      END IF;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING OE_PREPAYMENT_UTIL.IS_PREPAID_FOR_PAYMENT_TERM WITH RESULT: '||P_RESULT ) ;
   END IF;

END Is_Prepaid_for_payment_term;

--pnpl start

FUNCTION Get_Installment_Options (p_org_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2 IS
   l_installment_options	VARCHAR2(30);
BEGIN
   l_installment_options := nvl(OE_Sys_Parameters.Value('INSTALLMENT_OPTIONS', p_org_id), 'NONE');

   RETURN l_installment_options;

EXCEPTION
   WHEN OTHERS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_Installment_Options;

-- This procedure needs to be called only when the system parameter 'Installment Options' is set to 'ENABLE_PAY_NOW'
Function Is_Pay_Now_Line (p_line_id IN NUMBER) RETURN BOOLEAN
IS

l_header_id NUMBER;
l_pay_now_subtotal NUMBER := 0;
l_pay_now_tax NUMBER := 0;
l_pay_now_charges NUMBER := 0;
l_pay_now_total NUMBER := 0;
l_pay_now_commitment NUMBER :=0;
l_msg_count    NUMBER;
l_msg_data     VARCHAR2(2000);
l_return_status VARCHAR2(30) := FND_API.G_RET_STS_SUCCESS;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
   BEGIN
      SELECT header_id
      INTO l_header_id
      FROM oe_order_lines_all
      WHERE line_id = p_line_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
	 IF l_debug_level > 0 THEN
	    oe_debug_pub.add('No data found for line_id : '||p_line_id);
	 END IF;
	 RETURN FALSE;
   END;

   OE_Prepayment_PVT.Get_Pay_Now_Amounts
      (p_header_id 		=> l_header_id
      ,p_line_id		=> p_line_id
      ,x_pay_now_subtotal 	=> l_pay_now_subtotal
      ,x_pay_now_tax   	        => l_pay_now_tax
      ,x_pay_now_charges  	=> l_pay_now_charges
      ,x_pay_now_total		=> l_pay_now_total
      ,x_pay_now_commitment     => l_pay_now_commitment
      ,x_msg_count		=> l_msg_count
      ,x_msg_data		=> l_msg_data
      ,x_return_status          => l_return_status
      );

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF l_debug_level > 0 THEN
	 oe_debug_pub.add('OE_Prepayment_PVT.Get_Pay_Now_Amounts returned with errors');
      END IF;
      RETURN FALSE;
   END IF;

   IF l_pay_now_total > 0  THEN
      -- this is a pay now line
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;

END Is_Pay_Now_Line;
--pnpl end

END OE_PrePayment_UTIL ;

/
