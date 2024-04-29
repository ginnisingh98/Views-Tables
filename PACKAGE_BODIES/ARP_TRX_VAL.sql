--------------------------------------------------------
--  DDL for Package Body ARP_TRX_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_TRX_VAL" AS
/* $Header: ARTUVA3B.pls 120.11 2006/08/08 09:49:42 arnkumar ship $ */

/*===========================================================================+
 | FUNCTION                                                                  |
 |    check_commitment_overapp                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Checks if the commitment balance is overapplied                        |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                p_commitment_trx_id                                        |
 |                p_commitment_class - DEP or GUAR                           |
 |                p_commitment_amount - original amount of the commitment    |
 |                p_trx_amount - amount applied against the commitment       |
 |                p_so_source_code                                           |
 |                p_so_installed_flag                                        |
 |                                                                           |
 |              OUT:                                                         |
 |                p_commitment_bal                                           |
 |                                                                           |
 | RETURNS                                                                   |
 |   TRUE if commitment balance is not overapplied                           |
 |   FALSE if commitment balance is overapplied                              |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     06-MAR-1996	Martin Johnson	Created                              |
 |                                                                           |
 +===========================================================================*/

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

FUNCTION check_commitment_overapp( p_commitment_trx_id IN number,
                                   p_commitment_class  IN varchar2,

                                   p_commitment_amount IN number,
                                   p_trx_amount        IN number,
                                   p_so_source_code    IN varchar2,
                                   p_so_installed_flag IN varchar2,
                                   p_commitment_bal    OUT NOCOPY number)
RETURN BOOLEAN IS

  l_commitment_amount  number;
  l_commitment_bal     number;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_trx_val.check_commitment_overapp()+');
  END IF;

  l_commitment_bal :=
                     arp_bal_util.get_commitment_balance(
                                      p_commitment_trx_id,
                                      p_commitment_class,
                                      p_so_source_code,
                                      p_so_installed_flag );

  p_commitment_bal := l_commitment_bal;

  /*------------------------------------------------------------+
   |  If p_commitment_amount was not passed, get value from db  |
   +------------------------------------------------------------*/

  IF ( p_commitment_amount IS NULL )
    THEN
      SELECT amount
      INTO   l_commitment_amount
      FROM   ra_cust_trx_line_gl_dist
      WHERE  customer_trx_id = p_commitment_trx_id
      AND    latest_rec_flag = 'Y'
      AND    account_class   = 'REC';
    ELSE
      l_commitment_amount := p_commitment_amount;
  END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('check_commitment_overapp: ' || 'commitment amount = ' || to_char(l_commitment_amount));
       arp_util.debug('check_commitment_overapp: ' || 'commitment bal = ' || to_char(l_commitment_bal));
       arp_util.debug('check_commitment_overapp: ' || 'trx amount = ' || to_char(p_trx_amount));
    END IF;

--  Bug 433549: changing logic to check if commitment is overapplied.
/*  IF (
       sign( l_commitment_amount ) !=
       sign( l_commitment_bal + p_trx_amount )
     )
     AND
     ( l_commitment_bal + p_trx_amount != 0 )
*/
    IF ( (p_trx_amount > l_commitment_bal))
    THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('arp_trx_val.check_commitment_overapp()-');
      END IF;
      return(FALSE);
    ELSE
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('arp_trx_val.check_commitment_overapp()-');
      END IF;
      return(TRUE);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION: arp_trx_val.check_commitment_overapp()');
    END IF;
    RAISE;

END check_commitment_overapp;


/*===========================================================================+
 | FUNCTION                                                                  |
 |    check_currency_amounts                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Checks if the transaction amounts are valid for the currency.          |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_customer_trx_id				  	     |
 |                   p_currency_code					     |
 |                   p_display_message_flag				     |
 |                                                                           |
 |              OUT:                                                         |
 |                   None                                                    |
 |                                                                           |
 | RETURNS                                                                   |
 |   TRUE  if the amounts are valid for the currency.                        |
 |   FALSE if the amounts are not valid for the currency                     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     21-AUG-1996	Charlie Tomberg  Created                             |
 |                                                                           |
 +===========================================================================*/

FUNCTION check_currency_amounts(
                                 p_customer_trx_id       IN number,
                                 p_currency_code         IN varchar2,
                                 p_display_message_flag  IN boolean
                               )  RETURN boolean IS

  l_message             varchar2(30);
  l_dummy               integer;
  l_precision           integer;
  l_extended_precision  integer;
  l_min_acct_unit       number;

  CURSOR invalid_amounts IS
  /* Currency references line amounts with invalid precision */
  select 1,
         'AR_TW_BAD_CURR_LINE_AMT'
  from   dual
  where  rownum = 1
  and    exists
         (select 'invalid precision'
           from ra_customer_trx_lines line
           where (( decode(l_min_acct_unit, null,
                          round(extended_amount, l_precision),
                          round(extended_amount / l_min_acct_unit)
                                 * l_min_acct_unit) - extended_amount <> 0 )
                 or
                ( decode(l_min_acct_unit, null,
                          round(revenue_amount, l_precision),
                          round(revenue_amount / l_min_acct_unit)
                                 * l_min_acct_unit) - revenue_amount <> 0 ))
             and line.customer_trx_id = p_customer_trx_id)
  UNION ALL
  /* Currency references distribution amounts with invalid precision */
  select 2,
         'AR_TW_BAD_CURR_DIST_AMT'
  from   dual
  where  rownum = 1
  and    exists
         (select 'invalid precision'
            from ra_cust_trx_line_gl_dist
           where ( decode(l_min_acct_unit, null,
                          round(amount, l_precision),
                          round(amount / l_min_acct_unit)
                                  * l_min_acct_unit) - amount <> 0 )
             and customer_trx_id = p_customer_trx_id
             and (account_set_flag = 'N'
                  or account_class = 'REC') )
  UNION ALL
  /* Currency references salesrep amounts with invalid precision */
  select 3,
         'AR_TW_BAD_CURR_SREP_AMT'
  from   dual
  where  rownum = 1
  and    exists
         (select 'invalid precision'
            from ra_cust_trx_line_salesreps
           where (( decode(l_min_acct_unit, null,
                      round(revenue_amount_split, l_precision),
                      round(revenue_amount_split / l_min_acct_unit)
                        * l_min_acct_unit) - revenue_amount_split <> 0 )
                  or
                  ( decode(l_min_acct_unit, null,
                    round(non_revenue_amount_split, l_precision),
                    round(non_revenue_amount_split / l_min_acct_unit)
                        * l_min_acct_unit) - non_revenue_amount_split <> 0 ))
             and customer_trx_id = p_customer_trx_id
             and customer_trx_line_id is not null)
  UNION ALL
      /* Currency references installment amounts with invalid precision */
      select 4,
             'AR_TW_BAD_CURR_PS_AMT'
        from dual
       where rownum = 1
         and exists
         (select 'invalid precision'
            from ar_payment_schedules
           where (( decode(l_min_acct_unit, null,
                      round(amount_due_original, l_precision),
                      round(amount_due_original / l_min_acct_unit)
                        * l_min_acct_unit) - amount_due_original <> 0 )
                  or
                  ( decode(l_min_acct_unit, null,
                      round(amount_line_items_original, l_precision),
                      round(amount_line_items_original / l_min_acct_unit)
                        * l_min_acct_unit) - amount_line_items_original <> 0 )
                  or
                  ( decode(l_min_acct_unit, null,
                      round(freight_original, l_precision),
                      round(freight_original / l_min_acct_unit)
                        * l_min_acct_unit) - freight_original <> 0 )
                  or
                  ( decode(l_min_acct_unit, null,
                      round(tax_original, l_precision),
                      round(tax_original / l_min_acct_unit)
                        * l_min_acct_unit) - tax_original <> 0 ))
             and customer_trx_id = p_customer_trx_id)
   ORDER BY 1;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_trx_val.check_currency_amounts()+');
  END IF;

  FND_CURRENCY.get_info( p_currency_code,
                         l_precision,
                         l_extended_precision,
                         l_min_acct_unit );

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('check_currency_amounts: ' || ' CTID: '       || TO_CHAR(p_customer_trx_id) ||
                 '  currency: '  || p_currency_code ||
                 '  precision: ' || TO_CHAR(l_precision) ||
                 '  extended: '  || TO_CHAR(l_extended_precision) ||
                 '  MAU: '       || TO_CHAR(l_min_acct_unit));
  END IF;

  OPEN invalid_amounts;

  FETCH invalid_amounts
  INTO  l_dummy,
        l_message;

  CLOSE invalid_amounts;

  IF ( l_message IS NULL )
  THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug(' Passed check_currency_amounts check');
        END IF;
        RETURN(TRUE);

  ELSE
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug(' Failed check_currency_amounts check: ' || l_message ||
                      '  rows: ' || TO_CHAR(SQL%ROWCOUNT));
       END IF;

       IF ( p_display_message_flag = TRUE )
       THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('arp_trx_val.check_currency_amounts()-');
            END IF;
            FND_MESSAGE.set_name ('AR', l_message );
            APP_EXCEPTION.raise_exception;
       END IF;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_trx_val.check_currency_amounts()-');
  END IF;

  RETURN(FALSE);

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION: arp_trx_val.check_currency_amounts()');
    END IF;
    RAISE;

END check_currency_amounts;

/*Bug3283086 */
/*===========================================================================+
 | FUNCTION                                                                  |
 |    check_payent_method_validate					     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Checks if the payment method is valid for the given transaction date   |
 |    The reason to create this seperate function is 			     |
 |    ARP_TRX_VALIDATE.VALIDATE_TRX_DATE uses p_customer_Trx_id which will   |
 |    not be created in add mode (before save mode. Hence validation needs   |
 |    to be done also).
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_trx_date					  	     |
 |                   p_currency_code					     |
 |                   p_bill_to_customer_id				     |
 |                   p_ship_to_customer_id				     |
 |		     p_receipt_method_id				     |
 |                                                                           |
 |              OUT:                                                         |
 |                   None                                                    |
 |                                                                           |
 | RETURNS                                                                   |
 |   TRUE  if the payment method is valid for this trx date 		     |
 |   FALSE if the payment method is not valid for this trx date		     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     21-JAN-2004	Srivasud					     |
 |                                                                           |
 +===========================================================================*/

FUNCTION check_payment_method_validate(p_trx_date            IN  DATE,
                             p_currency_code                 IN  VARCHAR2,
                             p_bill_to_customer_id	     IN  NUMBER,
                             p_pay_to_customer_id	     IN  NUMBER,
			     p_receipt_method_id	     IN  NUMBER,
			     p_set_of_books_id		     IN  NUMBER) RETURN BOOLEAN

IS
  CURSOR receipt_creation_method_cur IS
    SELECT arc.creation_method_code
    FROM   ar_receipt_methods     arm,
           ar_receipt_classes     arc
    WHERE  arm.receipt_class_id   = arc.receipt_class_id
    AND    arm.receipt_method_id  = p_receipt_method_id;

    receipt_creation_method_rec receipt_creation_method_cur%ROWTYPE;
    l_temp 	VARCHAR2(100);
     --5150135
    l_pay_to_party_id  hz_parties.party_id%type;
    l_bill_to_party_id hz_parties.party_id%type;
BEGIN

     IF ( p_receipt_method_id IS NOT NULL ) THEN

      /*--------------------------------------------------------------------+
       | 23-MAY-2000 J Rautiainen BR Implementation                         |
       | BR payment method does not have bank account associated with it    |
       +--------------------------------------------------------------------*/
       OPEN receipt_creation_method_cur;
       FETCH receipt_creation_method_cur INTO receipt_creation_method_rec;
       CLOSE receipt_creation_method_cur;


      /*--------------------------------------------------------------------+
       | 23-MAY-2000 J Rautiainen BR Implementation                         |
       | BR payment method does not have bank account associated with it    |
       +--------------------------------------------------------------------*/

       IF NVL(receipt_creation_method_rec.creation_method_code,'INV') = 'BR' THEN
          BEGIN

	      /* If Payment Method creation code is BR then validate the receipt method
                 only*/

                 SELECT   'invalid_payment method'
                 INTO     l_temp
                 FROM     ar_receipt_methods             arm,
                          ar_receipt_classes             arc
                 WHERE    arm.receipt_method_id  = p_receipt_method_id
                 AND      arm.receipt_class_id   = arc.receipt_class_id
                 AND      p_trx_date BETWEEN NVL(arm.start_date,p_trx_date)
		 AND      NVL(arm.end_date,p_trx_date)
                 AND      rownum = 1;
		 RETURN(TRUE);
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
		RETURN (FALSE);
             WHEN OTHERS THEN
		RETURN (FALSE);
          END;

       ELSE

          BEGIN

	     /* We need to validate the following.
	        1. Receipt Method end date.
		2. Receipt method account end date
		3. Receipt method should have atleast one
		   bank account with valid end dates
		4. Also bank account should be of invoice currency or
		   multi currency enabled.
	        5. and that valid bank account should have
		   atleast one bank valid branch.
		6. Additionally If payment method creation is MANUAL or AUTOMATIC
		   then the trx currency is as same as payment method currency or
		   multi currency flag should be 'Y'
		7. For Automatic methods if Payment type is NOT CREDIT_CARD
		   additionally the currency should be defined or associated
		   with paying or bill to customer bank accounts.This condition is
		   taken from paying customer payment method LOV.. to keep the
		   both validations in sync.*/

	   --5150135
           l_bill_to_party_id := arp_trx_defaults_3.get_party_id(p_bill_to_customer_id);
 	   l_pay_to_party_id := arp_trx_defaults_3.get_party_id(p_pay_to_customer_id);

           SELECT     'invalid_payment method'
           INTO       l_temp
           FROM       ar_receipt_methods             arm,
                      ar_receipt_method_accounts     arma,
                      ce_bank_accounts     	     cba,
                      ce_bank_acct_uses              aba,
                      ar_receipt_classes             arc,
                      ce_bank_branches_v	     bp
           WHERE      arm.receipt_method_id  = arma.receipt_method_id
           AND        arm.receipt_class_id   = arc.receipt_class_id
           AND        arma.remit_bank_acct_use_id  = aba.bank_acct_use_id
           AND        aba.bank_account_id    = cba.bank_account_id
           /* New Condition added Begin*/
	   AND	      bp.branch_party_id = cba.bank_branch_id
	   AND	      p_trx_date	 <= NVL(bp.end_date,p_trx_date)
	   AND        (cba.currency_code = p_currency_code or
		             cba.receipt_multi_currency_flag ='Y') /* New condition */
           /* Removing the join condition based on currency code as part of bug fix 5346710
	   AND (arc.creation_method_code='MANUAL'
    		     or (arc.creation_method_code='AUTOMATIC'
                     and ( (nvl(arm.payment_channel_code,'*') = 'CREDIT_CARD' )
                     or
                     (nvl(arm.payment_channel_code,'*') <> 'CREDIT_CARD'
                     AND p_currency_code in
                         (select currency_code from iby_fndcpt_payer_assgn_instr_v
			 where party_id in (l_pay_to_party_id,l_bill_to_party_id))))))*/
           /* New Condition added Ends*/
           -- AND        aba.set_of_books_id    = arp_global.set_of_books_id
           AND        arm.receipt_method_id  = p_receipt_method_id
           AND        p_trx_date             <  NVL(cba.end_date,
                                                    TO_DATE('01/01/2200','DD/MM/YYYY') )
           AND        p_trx_date BETWEEN NVL(arm.start_date,
                                             p_trx_date)
                                     AND NVL(arm.end_date,
                                             p_trx_date)
           AND        p_trx_date BETWEEN NVL(arma.start_date,
                                             p_trx_date)
                                     AND NVL(arma.end_date,
                                             p_trx_date)
           AND        rownum = 1;

	   RETURN(TRUE);

          EXCEPTION
             WHEN NO_DATA_FOUND THEN
		 RETURN(FALSE);
             WHEN OTHERS THEN
		 RETURN(FALSE);
          END;
       END IF;
     END IF;
END check_payment_method_validate;
END ARP_TRX_VAL;

/
