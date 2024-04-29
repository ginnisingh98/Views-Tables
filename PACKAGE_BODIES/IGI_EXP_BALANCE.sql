--------------------------------------------------------
--  DDL for Package Body IGI_EXP_BALANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_EXP_BALANCE" AS
-- $Header: igistpeb.pls 120.5 2008/02/08 11:53:17 dvjoshi ship $
/*  P_MODE = T for Transmission Unit Level or manual batch payment
             D for Dialogue Unit Level
             N = for manual payment without batch
*/

FUNCTION AR_BALANCE_WARNING (P_MODE                      IN     VARCHAR2,
                              P_CHECKRUN_NAME            IN     VARCHAR2,
                              P_TRANSMISSION_UNIT_ID     IN     NUMBER,
                              P_DIALOGUE_UNIT_ID         IN     NUMBER,
                              P_CUSTOMER_ID              IN     NUMBER,
                              p_CUSTOMER_NAME            OUT NOCOPY    VARCHAR2)
                              return BOOLEAN is

  l_ar_amount         NUMBER;
  l_customer_id       NUMBER;
  l_customer_name     VARCHAR2(50);

CURSOR trans_unit_customer IS
   SELECT distinct third_party_id
   FROM igi_exp_dial_unit_def
   WHERE trans_unit_id = p_transmission_unit_id;


CURSOR dial_unit_customer IS
   SELECT third_party_id
   FROM igi_exp_dial_unit_def
   WHERE dial_unit_id = p_dialogue_unit_id;

CURSOR ap_pay_bat_sel_inv_customer IS
   SELECT distinct asic.vendor_id
   FROM   ap_selected_invoice_checks asic
   WHERE  asic.checkrun_name = p_checkrun_name;

CURSOR ar_balance IS
   SELECT NVL(SUM(aps.amount_due_remaining),0)
   FROM ra_customer_trx rct,
        ar_payment_schedules aps
   WHERE  aps.customer_trx_id = rct.customer_trx_id
   AND    rct.bill_to_customer_id = l_customer_id
   AND    aps.class = 'INV'
   AND    aps.due_date <= trunc(sysdate);

CURSOR ar_customer_name IS
SELECT PARTY_NAME
FROM HZ_CUST_ACCOUNTS acct,HZ_PARTIES party
WHERE acct.PARTY_ID=party.PARTY_ID
AND   acct.cust_account_id = l_customer_id;

/*
 SELECT rc.customer_name
 FROM   ra_customers    rc
 WHERE  rc.customer_id = l_customer_id;
*/
BEGIN

l_ar_amount := 0;

-- Transmission unit payment through Workflow --
IF   (p_transmission_unit_id is not null)
 AND (p_mode = 'T')
THEN
  OPEN  trans_unit_customer;
  LOOP
      FETCH trans_unit_customer INTO l_customer_id;
      EXIT WHEN trans_unit_customer%NOTFOUND;
           OPEN ar_balance;
            FETCH ar_balance INTO l_ar_amount;
            EXIT WHEN l_ar_amount <> 0;
           CLOSE ar_balance;
  END LOOP;
  CLOSE trans_unit_customer;

ELSE
   -- Manual Mode for payment batches --
   IF   (p_checkrun_name is not null)
   AND  (p_transmission_unit_id is null)
   AND   (p_mode = 'T')
   THEN
       OPEN ap_pay_bat_sel_inv_customer;
       FETCH ap_pay_bat_sel_inv_customer INTO l_customer_id;
            OPEN ar_balance;
            FETCH ar_balance INTO l_ar_amount;
            CLOSE ar_balance;
       CLOSE ap_pay_bat_sel_inv_customer;
    ELSE
       -- Dialogue unit payment --
       IF  (p_dialogue_unit_id is not null)
       AND (p_mode = 'D')
       THEN
           OPEN dial_unit_customer;
           FETCH dial_unit_customer INTO l_customer_id;
                 OPEN ar_balance;
                 FETCH ar_balance INTO l_ar_amount;
                 CLOSE ar_balance;
           CLOSE dial_unit_customer;
       ELSE
           -- Manual Mode for payment without batch --
           IF   (p_customer_id is null)
           AND (p_mode = 'N')
           THEN
                l_customer_id := p_customer_id;
                OPEN ar_balance;
                FETCH ar_balance INTO l_ar_amount;
                CLOSE ar_balance;
           END IF;
       END IF;
   END IF;
END IF;

IF l_ar_amount = 0
THEN
     OPEN ar_customer_name;
     FETCH ar_customer_name INTO l_customer_name;
     CLOSE ar_customer_name;
     p_customer_name := l_customer_name;
     return TRUE;
ELSE
     return FALSE;
END IF;

END AR_BALANCE_WARNING;


END IGI_EXP_BALANCE;

/
