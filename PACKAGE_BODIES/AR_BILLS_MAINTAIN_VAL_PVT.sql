--------------------------------------------------------
--  DDL for Package Body AR_BILLS_MAINTAIN_VAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_BILLS_MAINTAIN_VAL_PVT" AS
/* $Header: ARBRMAVB.pls 120.6.12010000.2 2009/02/25 09:41:05 rvelidi ship $ */


--Validation procedures are contained in this package

/* =======================================================================
 | Bills Receivable status constants
 * ======================================================================*/

C_INCOMPLETE			CONSTANT VARCHAR2(30)	:=	'INCOMPLETE';
C_PENDING_REMITTANCE		CONSTANT VARCHAR2(30)	:=	'PENDING_REMITTANCE';
C_PENDING_ACCEPTANCE		CONSTANT VARCHAR2(30)	:=	'PENDING_ACCEPTANCE';
C_MATURED_PEND_RISK_ELIM	CONSTANT VARCHAR2(30)	:=	'MATURED_PEND_RISK_ELIMINATION';
C_CLOSED			CONSTANT VARCHAR2(30)   :=	'CLOSED';
C_REMITTED			CONSTANT VARCHAR2(30)	:=	'REMITTED';
C_PROTESTED			CONSTANT VARCHAR2(30)	:=	'PROTESTED';
C_FACTORED			CONSTANT VARCHAR2(30)   :=	'FACTORED';
C_ENDORSED			CONSTANT VARCHAR2(30)	:=	'ENDORSED';


/* =======================================================================
 | Bills Receivable event constants
 * ======================================================================*/

C_MATURITY_DATE			CONSTANT VARCHAR2(30)	:=	'MATURITY_DATE';
C_MATURITY_DATE_UPDATED		CONSTANT VARCHAR2(30)	:=	'MATURITY_DATE_UPDATED';
C_FORMATTED			CONSTANT VARCHAR2(30)	:=	'FORMATTED';
C_COMPLETED			CONSTANT VARCHAR2(30)	:=	'COMPLETED';
C_ACCEPTED			CONSTANT VARCHAR2(30)	:=	'ACCEPTED';
C_SELECTED_REMITTANCE		CONSTANT VARCHAR2(30)	:=	'SELECTED_REMITTANCE';
C_DESELECTED_REMITTANCE		CONSTANT VARCHAR2(30)	:=	'DESELECTED_REMITTANCE';
C_CANCELLED			CONSTANT VARCHAR2(30)	:=	'CANCELLED';
C_RISK_ELIMINATED		CONSTANT VARCHAR2(30)	:=	'RISK_ELIMINATED';
C_RISK_UNELIMINATED		CONSTANT VARCHAR2(30)	:=	'RISK_UNELIMINATED';
C_RECALLED			CONSTANT VARCHAR2(30)	:=	'RECALLED';
C_EXCHANGED			CONSTANT VARCHAR2(30)	:=	'EXCHANGED';
C_RELEASE_HOLD			CONSTANT VARCHAR2(30)	:=	'RELEASE_HOLD';


/* =======================================================================
 | Bills Receivable action constants
 * ======================================================================*/


C_COMPLETE			CONSTANT VARCHAR2(30)	:=	'COMPLETE';
C_ACCEPT			CONSTANT VARCHAR2(30)	:=	'ACCEPT';
C_COMPLETE_ACC			CONSTANT VARCHAR2(30)	:=	'COMPLETE_ACC';
C_UNCOMPLETE			CONSTANT VARCHAR2(30)	:=	'UNCOMPLETE';
C_HOLD				CONSTANT VARCHAR2(30)	:=	'HOLD';
C_UNHOLD			CONSTANT VARCHAR2(30)	:=	'RELEASE HOLD';
C_SELECT_REMIT			CONSTANT VARCHAR2(30)	:=	'SELECT_REMIT';
C_DESELECT_REMIT		CONSTANT VARCHAR2(30)	:=	'DESELECT_REMIT';
C_CANCEL			CONSTANT VARCHAR2(30)	:=	'CANCEL';
C_UNPAID			CONSTANT VARCHAR2(30)	:=	'UNPAID';
C_REMIT_STANDARD		CONSTANT VARCHAR2(30)	:=	'REMIT_STANDARD';
C_FACTORE			CONSTANT VARCHAR2(30)	:=	'FACTORE';
C_FACTORE_RECOURSE		CONSTANT VARCHAR2(30)	:=	'FACTORE_RECOURSE';
C_RECALL			CONSTANT VARCHAR2(30)	:=	'RECALL';
C_ELIMINATE_RISK		CONSTANT VARCHAR2(30)	:=	'RISK ELIMINATION';
C_UNELIMINATE_RISK		CONSTANT VARCHAR2(30)	:=	'REESTABLISH RISK';
C_PROTEST			CONSTANT VARCHAR2(30)	:=	'PROTEST';
C_ENDORSE			CONSTANT VARCHAR2(30)	:=	'ENDORSE';
C_ENDORSE_RECOURSE		CONSTANT VARCHAR2(30)	:=	'ENDORSE_RECOURSE';
C_RESTATE			CONSTANT VARCHAR2(30)	:=	'RESTATE';
C_EXCHANGE			CONSTANT VARCHAR2(30)	:=	'EXCHANGE';
C_EXCHANGE_COMPLETE		CONSTANT VARCHAR2(30)	:=	'EXCHANGE_COMPLETE';
C_EXCHANGE_UNCOMPLETE		CONSTANT VARCHAR2(30)	:=	'EXCHANGE_UNCOMPLETE';
C_DELETE			CONSTANT VARCHAR2(30)	:=	'DELETE';
C_APPROVE_REMIT			CONSTANT VARCHAR2(30)	:=	'REMITTANCE APPROVAL';


/* =======================================================================
 | Bills Receivable remittance method code constants
 * ======================================================================*/

C_STANDARD			CONSTANT VARCHAR2(30)	:=	'STANDARD';
C_FACTORING			CONSTANT VARCHAR2(30)	:=	'FACTORING';


/*==============================================================================+
| PROCEDURE									|
|   Drawee_Is_Related								|
|										|
| DESCRIPTION									|
|   Test if the Drawee Identifier is related to the Bill To Customer Identifier |
|										|
+===============================================================================*/


PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

FUNCTION Drawee_Is_Related (	p_customer_trx_id 	IN 	NUMBER	,
				p_drawee_id 		IN 	NUMBER	,
				p_br_trx_date IN DATE ) RETURN BOOLEAN
IS

l_count NUMBER;

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_VAL_PVT.Drawee_Is_Related()+');
	END IF;

    SELECT 	count(*)
	  INTO 	l_count
	  FROM 	ra_customer_trx trx
	 WHERE  customer_trx_id=p_customer_trx_id
	   AND  trx.bill_to_customer_id IN
	(
	   SELECT arel.related_cust_account_id
	     FROM hz_cust_acct_relate arel
	    WHERE arel.cust_account_id 	= 	p_drawee_id
          AND arel.bill_to_flag = 'Y'
        UNION
	   SELECT rel.related_cust_account_id
         FROM ar_paying_relationships_v rel,
              hz_cust_accounts acc
        WHERE rel.party_id = acc.party_id
          AND acc.cust_account_id = p_drawee_id
          AND p_br_trx_date BETWEEN effective_start_date
                               AND effective_end_date
     );

	IF  	(l_count = 0)
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('Drawee_Is_Related: ' || 'The drawee is not related to the bill to customer of the transaction');
		END IF;
	     	RETURN (FALSE);
	ELSE
		RETURN (TRUE);
	END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_VAL_PVT.Drawee_Is_Related()-');
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_VAL_PVT.Drawee_Is_Related () ');
		   arp_util.debug('Drawee_Is_Related: ' || 'p_customer_trx_id = ' || p_customer_trx_id);
		   arp_util.debug('Drawee_Is_Related: ' || 'p_drawee_id       = ' || p_drawee_id);
		END IF;
		RAISE;

END Drawee_Is_Related;


/*======================================================================================+
| PROCEDURE										|
|   Drawee_Is_Identical									|
|											|
| DESCRIPTION										|
|   Test if the Drawee Identifier is the same as the Bill To Customer Identifier     	|
|											|			 |
+=======================================================================================*/

FUNCTION Drawee_Is_Identical(p_customer_trx_id IN NUMBER, p_drawee_id IN NUMBER) RETURN BOOLEAN
IS

l_bill_to_customer_id 		NUMBER;

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_VAL_PVT.Drawee_Is_Identical()+');
	END IF;

	SELECT 	bill_to_customer_id
	INTO 	l_bill_to_customer_id
	FROM 	ra_customer_trx
	WHERE  	customer_trx_id=p_customer_trx_id;

	IF   	(l_bill_to_customer_id <> p_drawee_id)
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('Drawee_Is_Identical: ' || 'p_customer_trx_id = ' || p_customer_trx_id);
		   arp_util.debug('Drawee_Is_Identical: ' || 'p_drawee_id       = ' || p_drawee_id);
		END IF;
		RETURN (FALSE);
	ELSE
		RETURN (TRUE);
	END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_VAL_PVT.Drawee_Is_Identical()-');
	END IF;

EXCEPTION
	WHEN 	NO_DATA_FOUND THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_VAL_PVT.Drawee_Is_Identical () ');
      	   	   arp_util.debug('Drawee_Is_Identical: ' || '>>>>>>>>>> Invalid BR ID');
 	   	   arp_util.debug('Drawee_Is_Identical: ' || '           Customer Trx ID  : ' || p_customer_trx_id);
 	   	END IF;
	   	FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_INVALID_BR_ID');
	   	app_exception.raise_exception;

	WHEN 	OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_VAL_PVT.Drawee_Is_Identical () ');
		   arp_util.debug('Drawee_Is_Identical: ' || 'p_customer_trx_id = ' || p_customer_trx_id);
		   arp_util.debug('Drawee_Is_Identical: ' || 'p_drawee_id       = ' || p_drawee_id);
		END IF;
		RAISE;

END Drawee_Is_Identical;




/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_Drawee                                     			|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    Validates that : 							     	|
 |      The Drawee is the same as or is related to the bill-to-customer		|
 |	on the exchanged transaction						|
 |										|
 +==============================================================================*/

FUNCTION Validate_Drawee (	p_customer_trx_id 	IN 	NUMBER		,
				p_drawee_id 		IN 	NUMBER		,
				p_trx_number		IN  	VARCHAR2	,
				p_br_trx_date IN DATE ) RETURN BOOLEAN
IS

BEGIN
 	IF PG_DEBUG in ('Y', 'C') THEN
 	   arp_util.debug('Validate_Drawee: ' || 'AR_BILLS_MAINTAIN_VAL_PVT.Validate_Relation()+');
	   arp_util.debug('Validate_Drawee: ' || 'Pay Unrelated Invoices Flag : ' || arp_global.sysparam.pay_unrelated_invoices_flag);
	END IF;


 	IF   (arp_global.sysparam.pay_unrelated_invoices_flag='Y')
	THEN
		RETURN (TRUE);
	ELSE
 		IF    	(Drawee_Is_Identical(p_customer_trx_id, p_drawee_id))
 		THEN
			IF PG_DEBUG in ('Y', 'C') THEN
			   arp_util.debug('Validate_Drawee: ' || '>>>>>>>>>> Drawee is the same as the Bill-to Customer');
			END IF;
 			RETURN (TRUE);

 		ELSIF 	(Drawee_Is_Related(p_customer_trx_id, p_drawee_id, p_br_trx_date))
 		THEN
			IF PG_DEBUG in ('Y', 'C') THEN
			   arp_util.debug('Validate_Drawee: ' || '>>>>>>>>>> Drawee is related to the Bill-to Customer');
			END IF;
	 		FND_MESSAGE.set_name	( 'AR', 'AR_BR_RELATED_CUSTOMER' );
			FND_MESSAGE.set_token	( 'TRXNUM', p_trx_number);
 			RETURN (TRUE);
 		ELSE
			RETURN (FALSE);
 		END IF;
	END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('Validate_Drawee: ' || 'AR_BILLS_MAINTAIN_VAL_PVT.Validate_Relation()-');
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_VAL_PVT.Validate_Drawee () ');
		   arp_util.debug('Validate_Drawee: ' || 'p_customer_trx_id = ' || p_customer_trx_id);
		   arp_util.debug('Validate_Drawee: ' || 'p_drawee_id       = ' || p_drawee_id);
		END IF;
		RAISE;

END Validate_Drawee;



/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_Assignment                                     			|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    Validates that 							     	|
 |          All transactions have the same currency as the BR Header            |
 |	    All transactions have the same exchange rate                        |
 |          The total of the assignments match the BR Total Amount		|
 |									  	|
 +==============================================================================*/

PROCEDURE Validate_Assignment (p_trx_rec  IN OUT NOCOPY  ra_customer_trx%ROWTYPE) IS

 /*-------------------------------------------+
  | Cursor to fetch the assignments of the BR |
  +-------------------------------------------*/

CURSOR 	assignment_cur IS
	SELECT 	br_ref_customer_trx_id, extended_amount, br_ref_payment_schedule_id
	FROM	ra_customer_trx_lines
	WHERE	customer_trx_id = p_trx_rec.customer_trx_id;

assignment_rec	assignment_cur%ROWTYPE;


l_functional_currency		VARCHAR2(15);
l_reference_rate		NUMBER;
l_total				NUMBER;
l_ps_rec			AR_PAYMENT_SCHEDULES%ROWTYPE;
l_trx_rec			RA_CUSTOMER_TRX%ROWTYPE;

BEGIN

  	IF PG_DEBUG in ('Y', 'C') THEN
  	   arp_util.debug('AR_BILLS_MAINTAIN_VAL_PVT.Validate_Assignment()+');
  	END IF;

	l_reference_rate	:=	-3;
	l_total			:=	0;

	/*---------------------------------------+
	|     LOOP on the BR assignments	 |
	+----------------------------------------*/

	FOR  assignment_rec  IN  assignment_cur LOOP


		/*---------------------------------------+
		|     Sum the assignement amounts	 |
		+----------------------------------------*/

		l_total			:=	l_total + assignment_rec.extended_amount;


		/*--------------------------------------+
		|   Fetch the Payment Schedule of the	|
		|   assignment				|
		+---------------------------------------*/

		arp_ps_pkg.fetch_p(assignment_rec.br_ref_payment_schedule_id, l_ps_rec);


		/*--------------------------------------+
		|   Fetch the assignment information	|
		+---------------------------------------*/

		arp_ct_pkg.fetch_p (l_trx_rec, assignment_rec.br_ref_customer_trx_id);


		/*--------------------------------------+
		|   Validate that the assignment is 	|
		|   not reserved			|
		+---------------------------------------*/

		IF 	AR_BILLS_MAINTAIN_STATUS_PUB.Is_BR_Reserved (l_ps_rec)
		THEN
			IF PG_DEBUG in ('Y', 'C') THEN
			   arp_util.debug ('Validate_Assignment: ' || 'The transaction ' || l_trx_rec.trx_number || ' is reserved, it cannot be assigned');
			END IF;
			FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_TRX_ALREADY_ASSIGN');
			FND_MESSAGE.SET_TOKEN ('TRXNUM', l_trx_rec.trx_number);
			app_exception.raise_exception;
		END IF;

		/*--------------------------------------+
		|  If the assignment is a BR, check	|
		|  the status of the BR			|
		+---------------------------------------*/

		IF	(AR_BILLS_CREATION_VAL_PVT.Is_Transaction_BR (l_trx_rec.cust_trx_type_id))
		THEN
			AR_BILLS_CREATION_VAL_PVT.Validate_Assignment_Status (l_trx_rec.customer_trx_id, l_trx_rec.trx_number);
		END IF;


		/*--------------------------------------+
		|   Check that there is no 	 	|
		|   overapplication			|
		+---------------------------------------*/

		IF   ABS(assignment_rec.extended_amount) > ABS(l_ps_rec.amount_due_remaining)
		THEN
			IF PG_DEBUG in ('Y', 'C') THEN
			   arp_util.debug('Validate_Assignment: ' || '>>>>>>>>>> Amount Exchanged Exceed PS');
			   arp_util.debug('Validate_Assignment: ' || '>>>>>>>>>> Overapplication not allowed');
			   arp_util.debug('Validate_Assignment: ' || 'Invoice concerned : ' || assignment_rec.br_ref_customer_trx_id);
			   arp_util.debug('Validate_Assignment: ' || 'PS concerned      : ' || assignment_rec.br_ref_payment_schedule_id);
	      	   	   arp_util.debug('Validate_Assignment: ' || 'Amount assigned   : ' || assignment_rec.extended_amount);
			   arp_util.debug('Validate_Assignment: ' || 'PS Remaining      : ' || l_ps_rec.amount_due_remaining);
			END IF;
	      	   	FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_OVERAPPLY');
			FND_MESSAGE.SET_TOKEN ('TRXNUM', l_trx_rec.trx_number);
		   	app_exception.raise_exception;
		END IF;


		/*--------------------------------------+
		|   Check that the assignment has the 	|
		|   same currency as the BR Header	|
		+---------------------------------------*/

		IF  (l_trx_rec.invoice_currency_code <> p_trx_rec.invoice_currency_code)  THEN
			IF PG_DEBUG in ('Y', 'C') THEN
			   arp_util.debug('Validate_Assignment: ' || '>>>>>>>>>> All transactions must have the same currency as the BR Header');
			   arp_util.debug('Validate_Assignment: ' || 'Header Currency   :  ' ||  p_trx_rec.invoice_currency_code);
			   arp_util.debug('Validate_Assignment: ' || 'Line   Currency   :  ' ||  l_trx_rec.invoice_currency_code);
			END IF;
    			FND_MESSAGE.set_name	( 'AR', 'AR_BR_BAD_ASSIGN_CURRENCY' );
	    		app_exception.raise_exception;
		END IF;


		/*--------------------------------------+
		|   Check that all assignments have the	|
		|   same exchange rate			|
		+---------------------------------------*/

		IF	(l_reference_rate = -3 )  THEN
			l_reference_rate := l_trx_rec.exchange_rate;
		END IF;

		IF  (l_trx_rec.exchange_rate <> l_reference_rate) THEN
			IF PG_DEBUG in ('Y', 'C') THEN
			   arp_util.debug('Validate_Assignment: ' || '>>>>>>>>>> All transactions must have the same exchange rate');
			   arp_util.debug('Validate_Assignment: ' || 'Reference Rate   :  ' ||  l_reference_rate);
			   arp_util.debug('Validate_Assignment: ' || 'Line Rate	 :  ' ||  l_trx_rec.exchange_rate);
			END IF;
    			FND_MESSAGE.set_name	( 'AR', 'AR_BR_BAD_ASSIGN_RATE' );
	    		app_exception.raise_exception;
		END IF;


		/*--------------------------------------+
		|   Check that the drawee is equal or	|
		|   related to the bill-to customer of  |
		|   the assignment			|
		+---------------------------------------*/

		IF (NOT validate_drawee(assignment_rec.br_ref_customer_trx_id, p_trx_rec.drawee_id, l_trx_rec.trx_number, p_trx_rec.trx_date))
		THEN
			IF PG_DEBUG in ('Y', 'C') THEN
			   arp_util.debug('Validate_Assignment: ' || '>>>>>>>>>> The drawee is not related to the bill to customer');
			END IF;
			FND_MESSAGE.set_name ('AR', 'AR_BR_UNRELATED_CUSTOMER' );
			FND_MESSAGE.set_token('TRXNUM', l_trx_rec.trx_number);
			app_exception.raise_exception;
		END IF;


	END LOOP;


	/*--------------------------------------+
	|   Check that the BR Total Amount is	|
	|   positive				|
	+---------------------------------------*/

	IF 	(l_total <= 0)
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('Validate_Assignment: ' || '>>>>>>>>>> The BR Total must be positibe');
		END IF;
		FND_MESSAGE.set_name ('AR', 'AR_BR_INVALID_AMOUNT' );
		app_exception.raise_exception;

	END IF;


	/*--------------------------------------+
	|   Default the Total Amount in the 	|
	|   BR Header if it doesn't exist	|
	+---------------------------------------*/

	IF  (p_trx_rec.br_amount IS NULL) THEN
		p_trx_rec.br_amount	:=	l_total;
	END IF;


	/*--------------------------------------+
	|  Check that the sum of the assignment	|
	|  amount equal to the BR total amount	|
	+---------------------------------------*/

   	IF  (p_trx_rec.br_amount    <>  l_total)  THEN
			IF PG_DEBUG in ('Y', 'C') THEN
			   arp_util.debug('Validate_Assignment: ' || '>>>>>>>>>> The total of the assignments must match the BR Amount');
			   arp_util.debug('Validate_Assignment: ' || 'Header Total Amount   :  ' ||  p_trx_rec.br_amount);
			   arp_util.debug('Validate_Assignment: ' || 'Lines  Total Amount   :  ' ||  l_total);
			END IF;
    			FND_MESSAGE.set_name	( 'AR', 'AR_BR_BAD_TOTAL_AMOUNT' );
	    		app_exception.raise_exception;
	END IF;


	/*--------------------------------------+
	|  Derive the exchange rate of the BR	|
	|  from the assignments	if necessary	|
	+---------------------------------------*/

	l_functional_currency	:=	arp_global.functional_currency;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug ('Validate_Assignment: ' || 'Functional Currency : ' || arp_global.functional_currency);
	   arp_util.debug ('Validate_Assignment: ' || 'BR Currency         : ' || p_trx_rec.invoice_currency_code);
	END IF;

	IF  (p_trx_rec.invoice_currency_code <> l_functional_currency)
	THEN
		p_trx_rec.exchange_rate		:=	l_trx_rec.exchange_rate;
		p_trx_rec.exchange_rate_type	:=	nvl(l_trx_rec.exchange_rate_type, 'User');
                /* Bug 2649369 : use exchanged invoice's exchange date instead of trx_date */
		p_trx_rec.exchange_date		:=	l_trx_rec.exchange_date;
	END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_VAL_PVT.Validate_Assignment()-');
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_VAL_PVT.Validate_Assignment () ');
		END IF;
		IF	(assignment_cur%ISOPEN)
		THEN
			CLOSE	assignment_cur;
		END IF;
		RAISE;

END Validate_Assignment;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_Assignment_Exist                                     		|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    Validates that the exchanged transaction have not been purged		|
 |									  	|
 +==============================================================================*/

PROCEDURE Validate_Assignment_Exist (p_customer_trx_id  IN  ra_customer_trx.customer_trx_id%TYPE)
IS

 /*-------------------------------------------+
  | Cursor to fetch the assignments of the BR |
  +-------------------------------------------*/

CURSOR 	assignment_cur IS
	SELECT 	br_ref_customer_trx_id
	FROM	ra_customer_trx_lines
	WHERE	customer_trx_id = p_customer_trx_id;

assignment_rec	assignment_cur%ROWTYPE;

l_assignment_exists	VARCHAR2(1);

BEGIN

  	IF PG_DEBUG in ('Y', 'C') THEN
  	   arp_util.debug('AR_BILLS_MAINTAIN_VAL_PVT.Validate_Assignment_Exist()+');
  	END IF;

	FOR  assignment_rec  IN  assignment_cur LOOP
		SELECT  'Y'
		INTO	l_assignment_exists
		FROM	ra_customer_trx
		WHERE	customer_trx_id = assignment_rec.br_ref_customer_trx_id;

	END LOOP;

  	IF PG_DEBUG in ('Y', 'C') THEN
  	   arp_util.debug('AR_BILLS_MAINTAIN_VAL_PVT.Validate_Assignment_Exist()-');
  	END IF;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_VAL_PVT.Validate_Assignment_Exist () ');
		   arp_util.debug('Validate_Assignment: ' || '>>>>>>>>>> Exchanged Transaction has been purged : ' || assignment_rec.br_ref_customer_trx_id);
		END IF;
		IF	(assignment_cur%ISOPEN)
		THEN
			CLOSE	assignment_cur;
		END IF;
		FND_MESSAGE.set_name	( 'AR', 'AR_BR_TRX_PURGED' );
		app_exception.raise_exception;

	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_VAL_PVT.Validate_Assignment_Exist () ');
		END IF;
		IF	(assignment_cur%ISOPEN)
		THEN
			CLOSE	assignment_cur;
		END IF;
		RAISE;

END Validate_Assignment_Exist;



/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_Remit_Batch_ID		                                     	|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Validates the Batch Identifier in AR_BATCHES				|
 |                                                                           	|
 +==============================================================================*/

PROCEDURE Validate_Remit_Batch_ID    (p_batch_id IN  NUMBER) IS


l_batch_id_valid	VARCHAR2(1);

BEGIN
   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_MAINTAIN_VAL_PVT.Validate_Remit_Batch_ID()+');
   	END IF;

	IF  (p_batch_id IS NOT NULL) THEN
		SELECT 	'Y'
		INTO	l_batch_id_valid
		FROM 	ar_BATCHES
		WHERE	batch_id	=	p_batch_id;
	END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_VAL_PVT.Validate_Remit_Batch_ID()-');
	END IF;

EXCEPTION
    	WHEN NO_DATA_FOUND THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_VAL_PVT.Validate_Remit_Batch_ID () ');
      	   	   arp_util.debug('Validate_Remit_Batch_ID: ' || '>>>>>>>>>> Invalid Batch ID');
 	   	   arp_util.debug('Validate_Remit_Batch_ID: ' || 'Batch ID  : ' || p_batch_id);
 	   	END IF;
	   	FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_INVALID_BATCH_ID');
	   	app_exception.raise_exception;

	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_VAL_PVT.Validate_Remit_Batch_ID () ');
		END IF;
		RAISE;


END Validate_Remit_Batch_ID;



/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_Payment_Schedule_ID		                               	|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Validates the Payment Schedule Identifier					|
 |                                                                           	|
 +==============================================================================*/

PROCEDURE Validate_Payment_Schedule_ID ( p_payment_schedule_id	IN  NUMBER) IS


l_payment_schedule_id_valid		VARCHAR2(1);

BEGIN
   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_MAINTAIN_VAL_PVT.Validate_Payment_Schedule_ID()+');
   	END IF;

	SELECT 	'Y'
	INTO	l_payment_schedule_id_valid
	FROM 	AR_PAYMENT_SCHEDULES
	WHERE	payment_schedule_id  =  p_payment_schedule_id;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_VAL_PVT.Validate_Payment_Schedule_ID()-');
	END IF;

EXCEPTION
    	WHEN NO_DATA_FOUND THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_VAL_PVT.Validate_Payment_Schedule_ID () ');
      	   	   arp_util.debug('Validate_Payment_Schedule_ID: ' || '>>>>>>>>>> Invalid Payment Schedule ID');
 	   	   arp_util.debug('Validate_Payment_Schedule_ID: ' || 'Payment Schedule ID  : ' || p_payment_schedule_id);
 	   	END IF;
	   	FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_INVALID_PS_ID');
	   	app_exception.raise_exception;

	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_VAL_PVT.Validate_Payment_Schedule_ID () ');
		END IF;
		RAISE;

END Validate_Payment_Schedule_ID;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_Adj_Activity_ID			                                |
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Validates the adjustment activity passed during BR Endorsement		|
 |                                                                           	|
 +==============================================================================*/

PROCEDURE Validate_Adj_Activity_ID    (p_adjustment_activity_id IN  NUMBER) IS


l_adjustment_activity_valid	VARCHAR2(1);

BEGIN
   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_MAINTAIN_VAL_PVT.Validate_Adj_Activity_ID()+');
   	END IF;

	IF	(p_adjustment_activity_id  IS NOT NULL)
	THEN

		SELECT 	'Y'
		INTO	l_adjustment_activity_valid
		FROM 	AR_RECEIVABLES_TRX
		WHERE	receivables_trx_id	=	p_adjustment_activity_id
		AND	status			=	'A'
		AND	type			=	'ENDORSEMENT';
	ELSE
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug ('Validate_Adj_Activity_ID: ' || 'The Adjustment Activity is missing');
		END IF;
		FND_MESSAGE.SET_NAME  ('AR', 'AR_PROCEDURE_VALID_ARGS_FAIL');
		FND_MESSAGE.SET_TOKEN ('PARAMETER', 'Adjustment Activity');
		FND_MESSAGE.SET_TOKEN ('PROCEDURE', 'Endorse');
	   	app_exception.raise_exception;
	END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_VAL_PVT.Validate_Adj_Activity_ID()-');
	END IF;

EXCEPTION
    	WHEN NO_DATA_FOUND THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_VAL_PVT.Validate_Adj_Activity_ID () ');
      	   	   arp_util.debug('Validate_Adj_Activity_ID: ' || '>>>>>>>>>> Invalid Adjustment Activity ID');
 	   	   arp_util.debug('Validate_Adj_Activity_ID: ' || 'p_adjustment_activity_id  : ' || p_adjustment_activity_id);
 	   	END IF;
	   	FND_MESSAGE.SET_NAME  ('AR', 'AR_AAPI_INVALID_RCVABLE_ID');
		FND_MESSAGE.SET_TOKEN ('RECEIVABLES_TRX_ID', p_adjustment_activity_id);
	   	app_exception.raise_exception;

	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_VAL_PVT.Validate_Adj_Activity_ID () ');
		END IF;
		RAISE;


END Validate_Adj_Activity_ID;



/*==============================================================================+
| PROCEDURE									|
|   Validate_Reversal_Reason							|
|										|
| DESCRIPTION									|
|   Validate the Reversal reason against the values in ar_lookups for	 	|
|   lookup_type = 'REVERSAL_CATEGORY_TYPE'					|
|										|
+===============================================================================*/

PROCEDURE Validate_Reversal_Reason ( p_reversal_reason   IN   VARCHAR2)
IS
l_reversal_reason_valid		VARCHAR2(1);
BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_VAL_LIB_PVT.Validate_Reversal_Reason()+');
	END IF;

  	SELECT 	'Y'
     	INTO   	l_reversal_reason_valid
	FROM   	ar_lookups
     	WHERE  	lookup_type 	=  'CKAJST_REASON'
       	and  	enabled_flag 	=  'Y'
       	and  	lookup_code 	=  p_reversal_reason;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_VAL_LIB_PVT.Validate_Reversal_Reason()-');
	END IF;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_VAL_LIB_PVT.Validate_Reversal_Reason () ');
		   arp_util.debug ('Validate_Reversal_Reason: ' || '>>>>>>>>>> The reversal reason is invalid');
		END IF;
		FND_MESSAGE.SET_NAME('AR','AR_BR_INVALID_REVERSAL_REASON');
		app_exception.raise_exception;

	WHEN Others THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_VAL_LIB_PVT.Validate_Reversal_Reason () ');
		   arp_util.debug('Validate_Reversal_Reason: ' || 'p_reversal_reason : ' || p_reversal_reason);
		END IF;
		RAISE;
END Validate_Reversal_Reason;



/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_Complete_BR			                                |
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Validates the BR before completion				     	|
 |	-  The GL Date must be in an open or future period			|
 |	-  All transactions must have the same currency as the BR Header	|
 |	-  All transactions must have the same exchange rate			|
 |	-  The total of the assignments must match the BR Total amount		|
 |                                                                           	|
 +==============================================================================*/


PROCEDURE  Validate_Complete_BR  (
		p_trx_rec		IN OUT NOCOPY	ra_customer_trx%ROWTYPE	,
		p_gl_date		IN	DATE			)
IS

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_VAL_PVT.Validate_Complete_BR()+');
	END IF;


    --  Validate GL Date

	AR_BILLS_CREATION_VAL_PVT.Validate_GL_Date (p_gl_date);


    --  Validate the assignments

        Validate_Assignment (p_trx_rec);

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_VAL_PVT.Validate_Complete_BR()-');
	END IF;

EXCEPTION
	WHEN Others THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_VAL_PVT.Validate_Complete_BR () ');
		END IF;
		RAISE;

END Validate_Complete_BR;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_Accept_BR			                                |
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Validates the acceptance date and acceptance GL Date	   		|
 |                                                                           	|
 +==============================================================================*/


PROCEDURE  Validate_Accept_BR  (
		p_trx_rec		IN 	ra_customer_trx%ROWTYPE,
		p_trh_rec		IN	ar_transaction_history%ROWTYPE)
IS

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_VAL_PVT.Validate_Accept_BR()+');
	END IF;


    	/*--------------------------------------+
	|   The Acceptance GL Date must not be	|
	|   prior to the Issue Date		|
	+---------------------------------------*/

	IF  (p_trh_rec.gl_date < p_trx_rec.trx_date)
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('Validate_Accept_BR: ' || '>>>>>>>>>> Acceptance GL Date must not be prior to the Issue Date');
		   arp_util.debug('Validate_Accept_BR: ' || 'Acceptance GL Date :  ' ||  p_trh_rec.gl_date);
		   arp_util.debug('Validate_Accept_BR: ' || 'Issue Date         :  ' ||  p_trx_rec.trx_date);
		END IF;
    		FND_MESSAGE.set_name	( 'AR', 'AR_BR_INVALID_ACCEPT_GL_DATE' );
		app_exception.raise_exception;
	END IF;


    	/*--------------------------------------+
	|   The Acceptance Date must not be	|
	|   prior to the Issue Date		|
	+---------------------------------------*/

	IF  (p_trh_rec.trx_date < p_trx_rec.trx_date)
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('Validate_Accept_BR: ' || '>>>>>>>>>> Acceptance Date must not be prior to the Issue Date');
		   arp_util.debug('Validate_Accept_BR: ' || 'Acceptance Date :  ' ||  p_trh_rec.trx_date);
		   arp_util.debug('Validate_Accept_BR: ' || 'Issue Date      :  ' ||  p_trx_rec.trx_date);
		END IF;
    		FND_MESSAGE.set_name	( 'AR', 'AR_BR_INVALID_ACCEPT_DATE' );
		app_exception.raise_exception;
	END IF;


	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_VAL_PVT.Validate_Accept_BR()-');
	END IF;

EXCEPTION
	WHEN Others THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_VAL_PVT.Validate_Accept_BR () ');
		END IF;
		RAISE;

END Validate_Accept_BR;



/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_Cancel_BR			                                |
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Validates that the exchanged transactions have not been purged		|
 |                                                                           	|
 +==============================================================================*/


PROCEDURE  Validate_Cancel_BR  (p_customer_trx_id  	IN 	ra_customer_trx.customer_trx_id%TYPE)
IS

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_VAL_PVT.Validate_Cancel_BR()+');
	END IF;

	/*----------------------------------------------+
	|   Validate that the exchanged transactions	|
	|   have not been purged			|
	+-----------------------------------------------*/

  	Validate_Assignment_Exist (p_customer_trx_id);


	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_VAL_PVT.Validate_Cancel_BR()-');
	END IF;

EXCEPTION
	WHEN Others THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_VAL_PVT.Validate_Cancel_BR () ');
		END IF;
		RAISE;

END Validate_Cancel_BR;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_Unpaid_BR			                                |
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Validates data before a BR is unpaid 		     			|
 |                                                                           	|
 +==============================================================================*/


PROCEDURE  Validate_Unpaid_BR  (p_trh_rec  		IN 	ar_transaction_history%ROWTYPE	,
				p_unpaid_reason		IN	VARCHAR2			)
IS

l_batch_rec		AR_BATCHES%ROWTYPE;
l_amount_applied	NUMBER;
l_trx_rec		ra_customer_trx%ROWTYPE;

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_VAL_PVT.Validate_Unpaid_BR()+');
	END IF;


     --  Validate the Reversal Reason Category

	IF  (p_unpaid_reason IS NOT NULL)
	THEN
		Validate_Reversal_Reason (p_unpaid_reason);
	ELSE
		IF (p_trh_rec.status = C_MATURED_PEND_RISK_ELIM) or (p_trh_rec.event = C_CLOSED)
		THEN
			IF PG_DEBUG in ('Y', 'C') THEN
			   arp_util.debug ('Validate_Unpaid_BR: ' || '>>>>>>>>>> The Unpaid reason is missing');
			END IF;
			FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_UNPAID_REASON_NULL');
		   	app_exception.raise_exception;
		END IF;
	END IF;

  	IF PG_DEBUG in ('Y', 'C') THEN
  	   arp_util.debug('AR_BILLS_MAINTAIN_VAL_PVT.Validate_Unpaid_BR()-');
  	END IF;

EXCEPTION
	WHEN Others THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_VAL_PVT.Validate_Unpaid_BR () ');
		END IF;
		RAISE;

END Validate_Unpaid_BR;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_Action_Dates			                                |
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Validates the coherence of the trx_date and gl_date of the action, 	|
 |    compared with the transaction history record.				|
 |                                                                           	|
 +==============================================================================*/


PROCEDURE  Validate_Action_Dates   ( 	p_trx_date	IN	DATE				,
					p_gl_date	IN	DATE				,
					p_trh_rec	IN	ar_transaction_history%ROWTYPE	,
					p_action	IN	VARCHAR2			)

IS

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_VAL_PVT.Validate_Action_Dates()+');
	END IF;


	/*--------------------------------------+
	|   The Trx Date of the action must be	|
	|   equal or later than the Trx Date	|
	|   in the current transaction history	|
	|   record.				|
	+---------------------------------------*/

	IF  	(p_trx_date < p_trh_rec.trx_date)
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('Validate_Action_Dates: ' || '>>>>>>>>>> The  ' || p_action || ' Date ' || p_trx_date || ' must not be prior to ' || p_trh_rec.trx_date);
		END IF;
		FND_MESSAGE.set_name	( 'AR', 'AR_BR_INVALID_TRX_DATE' );
		FND_MESSAGE.set_token	( 'ACTION'      , p_action);
		FND_MESSAGE.set_token	( 'NEW_TRX_DATE', to_char(p_trx_date));
		FND_MESSAGE.set_token   ( 'OLD_TRX_DATE', to_char(p_trh_rec.trx_date));
		app_exception.raise_exception;
	END IF;



    	/*--------------------------------------+
	|   The GL Date of the action must be	|
	|   equal or later than the GL Date	|
	|   in the current transaction history	|
	|   record.				|
	+---------------------------------------*/

	IF	(p_gl_date  IS  NOT  NULL)
	THEN

	   IF (p_gl_date < nvl(p_trh_rec.gl_date, p_gl_date))
	     THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('Validate_Action_Dates: ' || '>>>>>>>>>> The ' || p_action || ' GL Date ' || p_gl_date || ' must not be prior to ' || p_trh_rec.gl_date);
		END IF;
		FND_MESSAGE.set_name( 'AR', 'AR_BR_INVALID_GL_DATE' );
                -- Bug 1865580: BR Message revision 7: only pass old_gl_date
                -- as token
		FND_MESSAGE.set_token( 'OLD_GL_DATE',
                                       to_char(p_trh_rec.gl_date));
		app_exception.raise_exception;
	  END IF;
	END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_VAL_PVT.Validate_Action_Dates()-');
	END IF;

EXCEPTION
	WHEN Others THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_VAL_PVT.Validate_Action_Dates () ');
		END IF;
		RAISE;

END Validate_Action_Dates;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_Remittance_Dates			                                |
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Validates the remittance batch date and gl_date, before selecting a BR 	|
 |    for the remittance batch							|
 |                                                                           	|
 +==============================================================================*/


PROCEDURE  Validate_Remittance_Dates  (	p_batch_rec	IN	ar_batches%ROWTYPE		,
					p_trh_rec	IN	ar_transaction_history%ROWTYPE	,
					p_trx_number	IN	ra_customer_trx.trx_number%TYPE	)

IS

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_VAL_PVT.Validate_Remittance_Dates()+');
	END IF;


	/*----------------------------------------------+
	|  The remittance batch date must not be prior	|
	|  to the Trx Date in the Current Transaction 	|
	|  History Record of the BR selected		|
	+-----------------------------------------------*/

          -- bug6050275
	 IF          trunc(p_batch_rec.batch_date) < p_trh_rec.trx_date and p_trh_rec.EVENT <> C_DESELECTED_REMITTANCE
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('Validate_Remittance_Dates: ' || '>>>>>>>>>> The BR ' || p_trx_number || ' cannot be selected in this remittance batch');
		   arp_util.debug('Validate_Remittance_Dates: ' || '           To include this BR, the batch date should not be prior to ' || p_trh_rec.trx_date);
		END IF;
		FND_MESSAGE.set_name	( 'AR', 'AR_BR_INVALID_REMIT_DATE' );
		FND_MESSAGE.set_token	( 'BRNUM'   , p_trx_number);
		FND_MESSAGE.set_token   ( 'TRX_DATE', to_char(p_trh_rec.trx_date));
		app_exception.raise_exception;
	END IF;



    	/*----------------------------------------------+
	| The remittance batch GL date must not be prior|
	| to the GL Date in the Current Transaction 	|
	| History Record of the BR selected		|
	+-----------------------------------------------*/
	--bug6050275
IF trunc(p_batch_rec.gl_date) < nvl(p_trh_rec.gl_date, p_batch_rec.gl_date)and p_trh_rec.EVENT <> C_DESELECTED_REMITTANCE
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('Validate_Remittance_Dates: ' || '>>>>>>>>>> The BR ' || p_trx_number || ' cannot be selected in this remittance batch');
		   arp_util.debug('Validate_Remittance_Dates: ' || '           To include this BR, the batch GL date should not be prior to ' || p_trh_rec.gl_date);
		END IF;
		FND_MESSAGE.set_name	( 'AR', 'AR_BR_INVALID_REMIT_GL_DATE' );
		FND_MESSAGE.set_token	( 'BRNUM'   , p_trx_number);
		FND_MESSAGE.set_token   ( 'GL_DATE', to_char(p_trh_rec.gl_date));
		app_exception.raise_exception;
	END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_VAL_PVT.Validate_Remittance_Dates()-');
	END IF;

EXCEPTION
	WHEN Others THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_VAL_PVT.Validate_Remittance_Dates () ');
		END IF;
		RAISE;

END Validate_Remittance_Dates;


END AR_BILLS_MAINTAIN_VAL_PVT;

/
