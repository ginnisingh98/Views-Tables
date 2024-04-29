--------------------------------------------------------
--  DDL for Package Body AR_BILLS_MAINTAIN_STATUS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_BILLS_MAINTAIN_STATUS_PUB" AS
/* $Header: ARBRSVEB.pls 115.12 2003/11/04 16:43:34 mraymond ship $ */


/* =======================================================================
 | Bills Receivable status constants
 * ======================================================================*/

C_INCOMPLETE				CONSTANT VARCHAR2(30)	:=	'INCOMPLETE';
C_PENDING_REMITTANCE			CONSTANT VARCHAR2(30)	:=	'PENDING_REMITTANCE';
C_PENDING_ACCEPTANCE			CONSTANT VARCHAR2(30)	:=	'PENDING_ACCEPTANCE';
C_MATURED_PEND_RISK_ELIM		CONSTANT VARCHAR2(30)	:=	'MATURED_PEND_RISK_ELIMINATION';
C_CLOSED				CONSTANT VARCHAR2(30)   :=	'CLOSED';
C_REMITTED				CONSTANT VARCHAR2(30)	:=	'REMITTED';
C_PROTESTED				CONSTANT VARCHAR2(30)	:=	'PROTESTED';
C_FACTORED				CONSTANT VARCHAR2(30)   :=	'FACTORED';
C_ENDORSED				CONSTANT VARCHAR2(30)	:=	'ENDORSED';


/* =======================================================================
 | Bills Receivable event constants
 * ======================================================================*/

C_MATURITY_DATE				CONSTANT VARCHAR2(30)	:=	'MATURITY_DATE';
C_MATURITY_DATE_UPDATED			CONSTANT VARCHAR2(30)	:=	'MATURITY_DATE_UPDATED';
C_FORMATTED				CONSTANT VARCHAR2(30)	:=	'FORMATTED';
C_COMPLETED				CONSTANT VARCHAR2(30)	:=	'COMPLETED';
C_ACCEPTED				CONSTANT VARCHAR2(30)	:=	'ACCEPTED';
C_SELECTED_REMITTANCE			CONSTANT VARCHAR2(30)	:=	'SELECTED_REMITTANCE';
C_DESELECTED_REMITTANCE			CONSTANT VARCHAR2(30)	:=	'DESELECTED_REMITTANCE';
C_CANCELLED				CONSTANT VARCHAR2(30)	:=	'CANCELLED';
C_RISK_ELIMINATED			CONSTANT VARCHAR2(30)	:=	'RISK_ELIMINATED';
C_RISK_UNELIMINATED			CONSTANT VARCHAR2(30)	:=	'RISK_UNELIMINATED';
C_RECALLED				CONSTANT VARCHAR2(30)	:=	'RECALLED';
C_EXCHANGED				CONSTANT VARCHAR2(30)	:=	'EXCHANGED';
C_RELEASE_HOLD				CONSTANT VARCHAR2(30)	:=	'RELEASE_HOLD';


/* =======================================================================
 | Bills Receivable action constants
 * ======================================================================*/

C_COMPLETE				CONSTANT VARCHAR2(30)	:=	'COMPLETE';
C_ACCEPT				CONSTANT VARCHAR2(30)	:=	'ACCEPT';
C_COMPLETE_ACC				CONSTANT VARCHAR2(30)	:=	'COMPLETE_ACC';
C_UNCOMPLETE				CONSTANT VARCHAR2(30)	:=	'UNCOMPLETE';
C_HOLD					CONSTANT VARCHAR2(30)	:=	'HOLD';
C_UNHOLD				CONSTANT VARCHAR2(30)	:=	'RELEASE HOLD';
C_SELECT_REMIT				CONSTANT VARCHAR2(30)	:=	'SELECT_REMIT';
C_DESELECT_REMIT			CONSTANT VARCHAR2(30)	:=	'DESELECT_REMIT';
C_CANCEL				CONSTANT VARCHAR2(30)	:=	'CANCEL';
C_UNPAID				CONSTANT VARCHAR2(30)	:=	'UNPAID';
C_REMIT_STANDARD			CONSTANT VARCHAR2(30)	:=	'REMIT_STANDARD';
C_FACTORE				CONSTANT VARCHAR2(30)	:=	'FACTORE';
C_FACTORE_RECOURSE			CONSTANT VARCHAR2(30)	:=	'FACTORE_RECOURSE';
C_RECALL				CONSTANT VARCHAR2(30)	:=	'RECALL';
C_ELIMINATE_RISK			CONSTANT VARCHAR2(30)	:=	'RISK ELIMINATION';
C_UNELIMINATE_RISK			CONSTANT VARCHAR2(30)	:=	'REESTABLISH RISK';
C_PROTEST				CONSTANT VARCHAR2(30)	:=	'PROTEST';
C_ENDORSE				CONSTANT VARCHAR2(30)	:=	'ENDORSE';
C_ENDORSE_RECOURSE			CONSTANT VARCHAR2(30)	:=	'ENDORSE_RECOURSE';
C_RESTATE				CONSTANT VARCHAR2(30)	:=	'RESTATE';
C_EXCHANGE				CONSTANT VARCHAR2(30)	:=	'EXCHANGE';
C_EXCHANGE_COMPLETE			CONSTANT VARCHAR2(30)	:=	'EXCHANGE_COMPLETE';
C_EXCHANGE_UNCOMPLETE			CONSTANT VARCHAR2(30)	:=	'EXCHANGE_UNCOMPLETE';
C_DELETE				CONSTANT VARCHAR2(30)	:=	'DELETE';
C_APPROVE_REMIT				CONSTANT VARCHAR2(30)	:=	'REMITTANCE APPROVAL';

/* =======================================================================
 | Bills Receivable remittance method code constants
 * ======================================================================*/

C_STANDARD				CONSTANT VARCHAR2(30)	:=	'STANDARD';
C_FACTORING				CONSTANT VARCHAR2(30)	:=	'FACTORING';


/*==============================================================================+
 | FUNCTION                                                                 	|
 |    Is_Payment_Schedule_Reduced                             			|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    Validates that the original amount is equal to the Amount Due Remaining	|
 |									  	|
 +==============================================================================*/

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

FUNCTION  Is_Payment_Schedule_Reduced (	p_ps_rec  IN  ar_payment_schedules%ROWTYPE) RETURN BOOLEAN
IS

BEGIN

  	IF PG_DEBUG in ('Y', 'C') THEN
  	   arp_util.debug('AR_BILLS_MAINTAIN_STATUS_PUB.Is_Payment_Schedule_Reduced()+');
  	END IF;

	IF  (p_ps_rec.amount_due_original = p_ps_rec.amount_due_remaining)
	THEN
		RETURN (FALSE);
	ELSE
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('Is_Payment_Schedule_Reduced: ' || '>>>>>>>>>> Original amount is not equal to the remaining amount');
		   arp_util.debug('Is_Payment_Schedule_Reduced: ' || 'Original  amount  : ' || p_ps_rec.amount_due_original);
		   arp_util.debug('Is_Payment_Schedule_Reduced: ' || 'Remaining amount  : ' || p_ps_rec.amount_due_remaining);
		END IF;
		RETURN (TRUE);
	END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_STATUS_PUB.Is_Payment_Schedule_Reduced()-');
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_STATUS_PUB.Is_Payment_Schedule_Reduced () ');
		END IF;
		RAISE;

END Is_Payment_Schedule_Reduced;



/*==============================================================================+
 | FUNCTION                                                                 	|
 |    Is_BR_Reserved		                             			|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    Validates that the BR is not reserved :					|
 |	-> reserved columns of the Payment Schedule should contain null values	|
 |									  	|
 +==============================================================================*/

FUNCTION Is_BR_Reserved (p_ps_rec  IN  ar_payment_schedules%ROWTYPE) RETURN BOOLEAN
IS

BEGIN

  	IF PG_DEBUG in ('Y', 'C') THEN
  	   arp_util.debug('AR_BILLS_MAINTAIN_STATUS_PUB.Is_BR_Reserved()+');
  	END IF;


	IF  (p_ps_rec.reserved_type IS NULL AND  p_ps_rec.reserved_value IS NULL)
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug ('Is_BR_Reserved: ' || '>>>>>>>>>>> The BR is not reserved');
		END IF;
		RETURN (FALSE);
	ELSE
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug ('Is_BR_Reserved: ' || 'p_ps_rec.reserved_type  : ' || p_ps_rec.reserved_type);
		   arp_util.debug ('Is_BR_Reserved: ' || 'p_ps_rec.reserved_value : ' || p_ps_rec.reserved_value);
		END IF;
		RETURN (TRUE);
	END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_STATUS_PUB.Is_BR_Reserved()-');
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_STATUS_PUB.Is_BR_Reserved () ');
		END IF;
		RAISE;

END Is_BR_Reserved;



/*==============================================================================+
 | FUNCTION                                                                 	|
 |    Is_BR_Hold		                             			|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    Validates that BR is on hold						|
 |									  	|
 +==============================================================================*/

FUNCTION Is_BR_Hold  (p_ps_rec  IN  ar_payment_schedules%ROWTYPE) RETURN BOOLEAN
IS

BEGIN

  	IF PG_DEBUG in ('Y', 'C') THEN
  	   arp_util.debug('AR_BILLS_MAINTAIN_STATUS_PUB.Is_BR_Hold()+');
  	END IF;

	IF  (p_ps_rec.reserved_type = 'USER')
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug ('Is_BR_Hold: ' || '>>>>>>>>>>> The BR is on Hold');
		END IF;
		RETURN (TRUE);
	ELSE
		RETURN (FALSE);
	END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_STATUS_PUB.Is_BR_Hold()-');
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_STATUS_PUB.Is_BR_Hold () ');
		END IF;
		RAISE;

END Is_BR_Hold;



/*==============================================================================+
 | PROCEDURE Find_Prev_posted_trh                                               |
 |    	                                                                     	|
 | DESCRIPTION                                                               	|
 |    This function fetches the Previous posted transaction history record   	|
 |                                                                           	|
 | SCOPE - PUBLIC                                                            	|
 |                                                                           	|
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   	|
 |    arp_util.debug                                                         	|
 |                                                                           	|
 | ARGUMENTS  : 								|
 |	    IN  OUT NOCOPY   p_trh_rec - BR transaction history record     	        |
 |                             							|
 |                                                                          	|
 |                                                                           	|
 | MODIFICATION HISTORY                                                      	|
 |     04-JUL-2000  	Tien TRAN      	Created	                             	|
 |                                                                           	|
 +==============================================================================*/

PROCEDURE Find_Prev_posted_trh (p_trh_rec    IN OUT NOCOPY 	ar_transaction_history%ROWTYPE)

IS

 /*------------------------------------------------------------+
  | Cursor to fetch Previous posted transaction history record |
  +------------------------------------------------------------*/

	CURSOR 	Prev_trh_cur 	IS
    	SELECT 	*
    	FROM 	ar_transaction_history
    	WHERE 	(postable_flag = 'Y' OR nvl(event,'1') = 'MATURITY_DATE')
    	CONNECT BY PRIOR 	prv_trx_history_id = transaction_history_id
    	START WITH 		transaction_history_id = p_trh_rec.transaction_history_id
    	ORDER BY 		transaction_history_id desc;

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug ('AR_BILLS_MAINTAIN_STATUS_PUB.Find_Prev_posted_trh()+');
	END IF;

 	/*------------------------------------------------------+
	| Fetch Previous posted transaction history record 	|
	+-------------------------------------------------------*/

  	OPEN 	Prev_trh_cur;
  	FETCH 	Prev_trh_cur 	INTO	p_trh_rec;

  	IF  	(Prev_trh_cur%NOTFOUND)
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug ('Find_Prev_posted_trh: ' || 'Find_Previous transaction history record cannot be found' );
		END IF;
  	END IF;

  	CLOSE 	Prev_trh_cur;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug ('AR_BILLS_MAINTAIN_STATUS_PUB.Find_Prev_posted_trh()-');
	END IF;

EXCEPTION
    	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug ('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_STATUS_PUB.Find_Prev_posted_trh ' || SQLERRM);
		END IF;
		IF	(Prev_trh_cur%ISOPEN)
		THEN
			CLOSE	Prev_trh_cur;
		END IF;
      		RAISE;

END Find_Prev_posted_trh;



/*==============================================================================+
 | PROCEDURE Find_Last_relevant_trh 	                                        |
 |    	                                                                     	|
 | DESCRIPTION                                                               	|
 |    This function fetches the last transaction history record with a 		|
 |    relevant event (different from MATURITY_DATE_UPDATED and FORMATTED)	|
 |                                                                           	|
 | SCOPE - PUBLIC                                                            	|
 |                                                                           	|
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   	|
 |    arp_util.debug                                                         	|
 |                                                                           	|
 | ARGUMENTS  : 								|
 |	    IN  OUT NOCOPY    p_trh_rec - BR transaction history record     	        |
 |                             							|
 |                                                                          	|
 |                                                                           	|
 | MODIFICATION HISTORY                                                      	|
 |     04-JUL-2000  	Tien TRAN      	Created	                             	|
 |                                                                           	|
 +==============================================================================*/

PROCEDURE Find_Last_relevant_trh (p_trh_rec  IN  OUT NOCOPY  ar_transaction_history%ROWTYPE)

IS

 /*--------------------------------------------------------------+
  | Cursor to fetch last relevant transaction history record 	 |
  +--------------------------------------------------------------*/

	CURSOR 	Prev_trh_cur 	IS
    	SELECT 	*
    	FROM 	ar_transaction_history
    	WHERE 	nvl(event,'A') NOT IN (C_MATURITY_DATE_UPDATED, C_FORMATTED)
    	CONNECT BY PRIOR 	prv_trx_history_id = transaction_history_id
    	START WITH 		transaction_history_id = p_trh_rec.transaction_history_id
    	ORDER BY 		transaction_history_id desc;

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug ('AR_BILLS_MAINTAIN_STATUS_PUB.Find_Last_relevant_trh()+');
	END IF;

 	/*------------------------------------------------------+
	| Fetch last relevant transaction history record 	|
	+-------------------------------------------------------*/

  	OPEN 	Prev_trh_cur;
  	FETCH 	Prev_trh_cur 	INTO	p_trh_rec;

  	IF  	(Prev_trh_cur%NOTFOUND)
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug ('Find_Last_relevant_trh: ' || 'Find_Previous transaction history record cannot be found' );
		END IF;
  	END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug ('Find_Last_relevant_trh: ' || 'Previous Relevant Status  	:  ' ||  p_trh_rec.status);
	   arp_util.debug ('Find_Last_relevant_trh: ' || 'Previous Relevant Event   	:  ' ||  p_trh_rec.event);
	END IF;

  	CLOSE 	Prev_trh_cur;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug ('AR_BILLS_MAINTAIN_STATUS_PUB.Find_Last_relevant_trh()-');
	END IF;

EXCEPTION
    	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug ('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_STATUS_PUB.Find_Last_relevant_trh ()' || SQLERRM);
		END IF;
		IF	(Prev_trh_cur%ISOPEN)
		THEN
			CLOSE	Prev_trh_cur;
		END IF;
      		RAISE;

END Find_Last_relevant_trh;



/*==============================================================================+
 | FUNCTION                                                                 	|
 |    Is_BR_Remit_Selected  	                           			|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    Validates that the BR is selected for remittance				|
 |									  	|
 +==============================================================================*/

FUNCTION Is_BR_Remit_Selected  (p_trh_id  IN  ar_transaction_history.transaction_history_id%TYPE)  RETURN BOOLEAN
IS

l_trh_rec	ar_transaction_history%ROWTYPE;

BEGIN

  	IF PG_DEBUG in ('Y', 'C') THEN
  	   arp_util.debug('AR_BILLS_MAINTAIN_STATUS_PUB.Is_BR_Remit_Selected()+');
  	END IF;

	/*----------------------------------------------+
        |   Find Current Relevant History Information 	|
        +-----------------------------------------------*/

	l_trh_rec.transaction_history_id 	:=	p_trh_id;
	Find_last_relevant_trh (l_trh_rec);

	IF  (l_trh_rec.event = C_SELECTED_REMITTANCE)
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug ('Is_BR_Remit_Selected: ' || '>>>>>>>>>>> The BR is Selected for Remittance');
		END IF;
		RETURN (TRUE);
	ELSE
		RETURN (FALSE);
	END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_STATUS_PUB.Is_BR_Remit_Selected()-');
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug ('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_STATUS_PUB.Is_BR_Remit_Selected () ');
		   arp_util.debug ('Is_BR_Remit_Selected: ' || '           p_trh_id  : ' || p_trh_id);
		END IF;
		RAISE;

END Is_BR_Remit_Selected;



/*==============================================================================+
 | FUNCTION                                                                 	|
 |    Is_BR_Risk_Eliminated  	                           			|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    Validates that the BR has been risk eliminated				|
 |									  	|
 +==============================================================================*/

FUNCTION Is_BR_Risk_Eliminated  (p_trh_id  IN	ar_transaction_history.transaction_history_id%TYPE) RETURN BOOLEAN
IS

l_trh_rec	ar_transaction_history%ROWTYPE;
l_prev_trh_rec  ar_transaction_history%ROWTYPE;


BEGIN


  	IF PG_DEBUG in ('Y', 'C') THEN
  	   arp_util.debug('AR_BILLS_MAINTAIN_STATUS_PUB.Is_BR_Risk_Eliminated()+');
  	END IF;

	l_trh_rec.transaction_history_id	:=	p_trh_id;
	Find_Last_relevant_trh	(l_trh_rec);

	IF	(l_trh_rec.event = C_RISK_ELIMINATED)
	THEN
		l_prev_trh_rec.transaction_history_id	:=	l_trh_rec.prv_trx_history_id;
		Find_Last_relevant_trh	(l_prev_trh_rec);

		IF	(l_prev_trh_rec.status = C_MATURED_PEND_RISK_ELIM)
		THEN
			RETURN (TRUE);
		ELSE
			/*----------------------------------------------+
	        	|   Risk Restoration on Closed Endorsed BR 	|
			|   is not activated currently			|
		        +-----------------------------------------------*/

			RETURN (FALSE);
		END IF;
	END IF;

	RETURN (FALSE);

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_STATUS_PUB.Is_BR_Risk_Eliminated()-');
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_STATUS_PUB.Is_BR_Risk_Eliminated () ');
		   arp_util.debug('Is_BR_Risk_Eliminated: ' || 'p_trh_id		: ' || p_trh_id);
		END IF;
		RAISE;

END Is_BR_Risk_Eliminated;



/*==============================================================================+
 | FUNCTION                                                                 	|
 |    Is_BR_Matured	  	                           			|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    Check if the BR is matured 					 	|
 |	                                                                   	|
 +==============================================================================*/

FUNCTION Is_BR_Matured  (p_maturity_date	IN	DATE) RETURN BOOLEAN
IS

l_trh_rec	ar_transaction_history%ROWTYPE;

BEGIN

  	IF PG_DEBUG in ('Y', 'C') THEN
  	   arp_util.debug('AR_BILLS_MAINTAIN_STATUS_PUB.Is_BR_Matured()+');
  	END IF;


	IF	trunc(p_maturity_date)   <=   trunc(SYSDATE)
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug ('Is_BR_Matured: ' || 'The BR is matured');
		END IF;
		RETURN (TRUE);
	ELSE
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug ('Is_BR_Matured: ' || 'The BR is not matured yet');
		END IF;
		RETURN (FALSE);
	END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_STATUS_PUB.Is_BR_Matured()-');
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_STATUS_PUB.Is_BR_Matured () ');
		   arp_util.debug('Is_BR_Matured: ' || 'p_maturity_date		: ' || p_maturity_date);
		END IF;
		RAISE;

END Is_BR_Matured;



/*==============================================================================+
 | FUNCTION                                                                 	|
 |    Is_Receipt_Cleared 	                           			|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    Validates that the latest receipt for the BR has been cleared		|
 |									  	|
 +==============================================================================*/

FUNCTION Is_Receipt_Cleared  (p_customer_trx_id  IN  ra_customer_trx.customer_trx_id%TYPE) RETURN BOOLEAN
IS

l_cr_id		ar_receivable_applications.cash_receipt_id%TYPE;
l_crh_rec	ar_cash_receipt_history%ROWTYPE;

BEGIN

  	IF PG_DEBUG in ('Y', 'C') THEN
  	   arp_util.debug('AR_BILLS_MAINTAIN_STATUS_PUB.Is_Receipt_Cleared()+');
  	END IF;

	SELECT 	max(cash_receipt_id)
	INTO	l_cr_id
	FROM	ar_receivable_applications
	WHERE	applied_customer_trx_id   =	p_customer_trx_id
	OR	link_to_customer_trx_id   = 	p_customer_trx_id;

	ARP_CR_HISTORY_PKG.fetch_f_crid(l_cr_id, l_crh_rec);

	IF 	(l_crh_rec.status <> 'CLEARED')
	THEN
		RETURN (FALSE);
	ELSE
		RETURN (TRUE);
	END IF;


	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_STATUS_PUB.Is_Receipt_Cleared()-');
	END IF;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_STATUS_PUB.Is_Receipt_Cleared () ');
		   arp_util.debug('Is_Receipt_Cleared: ' || 'No receipt application has been found for the BR');
		   arp_util.debug('Is_Receipt_Cleared: ' || 'p_customer_trx_id		: ' || p_customer_trx_id);
		END IF;
		RAISE;

	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_STATUS_PUB.Is_Receipt_Cleared () ');
		   arp_util.debug('Is_Receipt_Cleared: ' || 'p_customer_trx_id		: ' || p_customer_trx_id);
		END IF;
		RAISE;

END Is_Receipt_Cleared;



/*==============================================================================+
 | FUNCTION                                                                 	|
 |    Is_BR_Paid_In_One_Time	 	                           		|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    Validates that the BR was paid by one receipt or one endorsement adj	|
 |									  	|
 +==============================================================================*/

FUNCTION Is_BR_Paid_In_One_Time  (p_trh_rec  IN  ar_transaction_history%ROWTYPE	,
				  p_ps_rec   IN  ar_payment_schedules%ROWTYPE	) RETURN BOOLEAN
IS

l_trx_rec		RA_CUSTOMER_TRX%ROWTYPE;
l_ra_id			AR_RECEIVABLE_APPLICATIONS.receivable_application_id%TYPE;
l_ra_rec		AR_RECEIVABLE_APPLICATIONS%ROWTYPE;
l_prev_trh_rec		AR_TRANSACTION_HISTORY%ROWTYPE;

BEGIN

  	IF PG_DEBUG in ('Y', 'C') THEN
  	   arp_util.debug('AR_BILLS_MAINTAIN_STATUS_PUB.Is_BR_Paid_In_One_Time()+');
  	END IF;

	/*----------------------------------------------+
        |   Find Previous Relevant History Information 	|
        +-----------------------------------------------*/

	l_prev_trh_rec.transaction_history_id 	:=	p_trh_rec.prv_trx_history_id;

	Find_last_relevant_trh (l_prev_trh_rec);


	/*----------------------------------------------+
        |   Unpaid :  Endorsed and then Closed   	|
	|   ********  With or without Recourse		|
        +-----------------------------------------------*/

	IF  	(l_prev_trh_rec.status = C_ENDORSED)
	THEN
		-- Only Endorsement for the whole amount is allowed, so return TRUE
		RETURN (TRUE);


	/*----------------------------------------------+
        |   Unpaid :  Remitted and then Closed   	|
	|   ********  Factored and then Closed		|
        +-----------------------------------------------*/

	ELSIF  (p_trh_rec.event in (C_CLOSED, C_RISK_ELIMINATED))
	THEN


		SELECT 	max(receivable_application_id)
		INTO	l_ra_id
		FROM	ar_receivable_applications
		WHERE	applied_customer_trx_id	    =	p_trh_rec.customer_trx_id;

		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug ('Is_BR_Paid_In_One_Time: ' || 'l_ra_id : ' || l_ra_id);
		END IF;

		arp_app_pkg.fetch_p (l_ra_id, l_ra_rec);


		--  Validate that the BR was paid by a single receipt

		IF  (l_ra_rec.amount_applied <> p_ps_rec.amount_due_original)
		THEN
			IF PG_DEBUG in ('Y', 'C') THEN
			   arp_util.debug ('Is_BR_Paid_In_One_Time: ' || '>>>>>>>>>> The BR cannot be Unpaid, because the BR was not paid by a single receipt');
			   arp_util.debug ('Is_BR_Paid_In_One_Time: ' || 'p_ps_rec.amount_due_original : ' || p_ps_rec.amount_due_original);
			   arp_util.debug ('Is_BR_Paid_In_One_Time: ' || 'l_ra_rec.amount_applied      : ' || l_ra_rec.amount_applied);
			END IF;
			RETURN (FALSE);
		ELSE
			RETURN (TRUE);
		END IF;

	END IF;

	RETURN (FALSE);

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_STATUS_PUB.Is_BR_Paid_In_One_Time()-');
	END IF;

EXCEPTION
	WHEN 	NO_DATA_FOUND	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_STATUS_PUB.Is_BR_Paid_In_One_Time () ');
		   arp_util.debug('Is_BR_Paid_In_One_Time: ' || 'No receipt application could be found for the BR');
		END IF;
		RETURN (FALSE);

	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_STATUS_PUB.Is_BR_Paid_In_One_Time () ');
		END IF;
		RAISE;

END Is_BR_Paid_In_One_Time;



/*==============================================================================+
| FUNCTION									|
|   Activities_Exist								|
|										|
| DESCRIPTION									|
|   Test if the BR has activities : receipt applications or adjustments 	|
|										|
+===============================================================================*/


FUNCTION Activities_Exist (p_customer_trx_id IN NUMBER) RETURN BOOLEAN
IS

l_rec_count 	NUMBER;
l_adj_count	NUMBER;


BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_STATUS_PUB.Activities_Exist()+');
	END IF;

	/*----------------------------------------------+
        |  Check if the BR has receipt applications	|
        +-----------------------------------------------*/

	SELECT 	count(*)
	INTO 	l_rec_count
	FROM 	ar_receivable_applications
	WHERE 	applied_customer_trx_id		=	p_customer_trx_id
	OR	link_to_customer_trx_id		=	p_customer_trx_id;


	/*----------------------------------------------+
        |  Check if the BR has adjustments against it	|
        +-----------------------------------------------*/

	SELECT	count(*)
	INTO	l_adj_count
	FROM	ar_adjustments
	WHERE	customer_trx_id			=	p_customer_trx_id;


	IF	(l_adj_count > 0) 	OR	(l_rec_count  >  0)
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug ('Activities_Exist: ' || 'The BR has activities');
		   arp_util.debug ('Activities_Exist: ' || 'l_rec_count : ' || l_rec_count);
		   arp_util.debug ('Activities_Exist: ' || 'l_adj_count : ' || l_adj_count);
		END IF;
		RETURN (TRUE);
	ELSE
		RETURN (FALSE);
	END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_STATUS_PUB.Activities_Exist()-');
	END IF;

EXCEPTION
	WHEN Others THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : Activities_Exist () ');
		END IF;
		RAISE;

END Activities_Exist;



/*==============================================================================+
 | FUNCTION                                                                 	|
 |    Has_been_posted	                                     			|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Checks whether the BR has been posted to GL or not			|
 |                                                                            	|
 +==============================================================================*/

FUNCTION Has_been_posted (p_customer_trx_id IN  NUMBER) RETURN BOOLEAN IS

l_count		NUMBER;

BEGIN
   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_MAINTAIN_STATUS_PUB.Has_been_posted()+');
   	END IF;

	/*----------------------------------------------+
        |   If posting_control_id is <> -3, the BR has 	|
	|   been posted.				|
        +-----------------------------------------------*/

	SELECT 	count(*)
	INTO	l_count
	FROM	AR_TRANSACTION_HISTORY
	WHERE  	customer_trx_id		=  	p_customer_trx_id
	AND	posting_control_id 	<> 	-3;

	IF (l_count > 0)
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug ('Has_been_posted: ' || 'The BR has been posted');
		END IF;
		RETURN TRUE;
	ELSE
		RETURN FALSE;
	END IF;

   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_MAINTAIN_STATUS_PUB.Has_been_posted()-');
   	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_STATUS_PUB.Has_been_posted () ');
		   arp_util.debug('Has_been_posted: ' || 'p_customer_trx_id = ' || p_customer_trx_id);
		END IF;
		RAISE;

END Has_been_posted;



/*===========================================================================+
 | FUNCTION                                                                  |
 |    Is_Acceptance_Required                                   		     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function determines if the BR requires acceptance or not	     |
 |                                                                           |
 +===========================================================================*/

FUNCTION Is_Acceptance_Required (p_cust_trx_type_id IN  ra_customer_trx.cust_trx_type_id%TYPE) RETURN BOOLEAN
IS

l_signed_flag		VARCHAR2(1);
l_drawee_issued_flag 	VARCHAR2(1);

BEGIN

   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_MAINTAIN_STATUS_PUB.Is_Acceptance_Required()+');
   	END IF;

	SELECT	signed_flag  , 	  drawee_issued_flag
   	INTO	l_signed_flag, 	l_drawee_issued_flag
   	FROM	ra_cust_trx_types
	WHERE	cust_trx_type_id	=	p_cust_trx_type_id;

   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('Is_Acceptance_Required: ' || 'l_signed_flag        : ' || l_signed_flag);
   	   arp_util.debug('Is_Acceptance_Required: ' || 'l_drawee_issued_flag : ' || l_drawee_issued_flag);
   	END IF;

	/*----------------------------------------------+
        |   The BR requires acceptance if :	 	|
	|	 signed_flag = 'Y'			|
	|   and  drawee_issued_flag = 'N'		|
        +-----------------------------------------------*/

   	IF	(l_signed_flag  =  'Y' AND  l_drawee_issued_flag <> 'Y')  THEN
		return(true);
	ELSE
		return(false);
	END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('AR_BILLS_MAINTAIN_STATUS_PUB.Is_Acceptance_Required()-');
   END IF;

EXCEPTION
	WHEN   	NO_DATA_FOUND THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_STATUS_PUB.Is_Acceptance_Required () ');
      		   arp_util.debug('Is_Acceptance_Required: ' || '>>>>>>>>>> Invalid Transaction Type');
		   arp_util.debug('Is_Acceptance_Required: ' || '           p_cust_trx_type_id = ' || p_cust_trx_type_id);
		END IF;
	   	FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_INVALID_TRX_TYPE');
		app_exception.raise_exception;


    	WHEN 	OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_STATUS_PUB.Is_Acceptance_Required () ');
		   arp_util.debug('Is_Acceptance_Required: ' || 'p_cust_trx_type_id      = ' || p_cust_trx_type_id);
		END IF;
		RAISE;

END Is_Acceptance_Required;



/*==============================================================================+
 | FUNCTION                                                                 	|
 |    BR_Has_Assignment                                     			|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Checks whether the BR has assignments or not				|
 |                                                                           	|
 +==============================================================================*/

FUNCTION BR_Has_Assignment (p_customer_trx_id IN  NUMBER) RETURN BOOLEAN IS

l_count		NUMBER;

BEGIN
   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_MAINTAIN_STATUS_PUB.BR_Has_Assignment()+');
   	END IF;

	SELECT 	count(*)
	INTO	l_count
	FROM	RA_CUSTOMER_TRX_LINES
	WHERE  	customer_trx_id		=  	p_customer_trx_id;

	IF (l_count > 0)
	THEN
		RETURN (TRUE);
	ELSE
		RETURN (FALSE);
	END IF;

   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_MAINTAIN_STATUS_PUB.BR_Has_Assignment()-');
   	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_STATUS_PUB.BR_Has_Assignment () ');
		   arp_util.debug('BR_Has_Assignment: ' || 'p_customer_trx_id = ' || p_customer_trx_id);
		END IF;
		RAISE;

END BR_Has_Assignment;



/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_actions					                        |
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    For a given BR, validates which actions are allowed			|
 |    13-DEC-02	VCRISOST	Bug 2702173 : ps_id lost in call to fetch_p	|
 |				declare local variable l_ps_id		        |
 |										|
 +==============================================================================*/


PROCEDURE Validate_actions ( p_customer_trx_id		IN 	NUMBER		,
			     p_complete_flag		OUT NOCOPY	VARCHAR2	,
			     p_uncomplete_flag		OUT NOCOPY	VARCHAR2	,
			     p_accept_flag		OUT NOCOPY	VARCHAR2	,
			     p_cancel_flag		OUT NOCOPY	VARCHAR2	,
			     p_select_remit_flag	OUT NOCOPY	VARCHAR2	,
			     p_deselect_remit_flag	OUT NOCOPY	VARCHAR2	,
			     p_approve_remit_flag	OUT NOCOPY	VARCHAR2	,
			     p_hold_flag		OUT NOCOPY	VARCHAR2	,
			     p_unhold_flag		OUT NOCOPY	VARCHAR2	,
			     p_recall_flag		OUT NOCOPY	VARCHAR2	,
			     p_eliminate_flag		OUT NOCOPY	VARCHAR2	,
			     p_uneliminate_flag		OUT NOCOPY	VARCHAR2	,
			     p_unpaid_flag		OUT NOCOPY	VARCHAR2	,
			     p_protest_flag		OUT NOCOPY	VARCHAR2	,
			     p_endorse_flag		OUT NOCOPY	VARCHAR2	,
			     p_restate_flag		OUT NOCOPY	VARCHAR2	,
			     p_exchange_flag		OUT NOCOPY	VARCHAR2	,
			     p_delete_flag		OUT NOCOPY	VARCHAR2	)

IS

l_trh_rec		AR_TRANSACTION_HISTORY%ROWTYPE;
l_ps_rec		AR_PAYMENT_SCHEDULES%ROWTYPE;
l_trx_rec		RA_CUSTOMER_TRX%ROWTYPE;
l_ps_id			NUMBER;

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_STATUS_PUB.validate_actions()+');
	END IF;

	p_complete_flag		:=	'N';
	p_uncomplete_flag	:=	'N';
	p_accept_flag		:=	'N';
	p_cancel_flag		:=	'N';
	p_select_remit_flag	:=	'N';
	p_deselect_remit_flag	:=	'N';
	p_approve_remit_flag	:=	'N';
	p_hold_flag		:=	'N';
	p_unhold_flag		:=	'N';
	p_recall_flag		:=	'N';
	p_eliminate_flag	:=	'N';
	p_uneliminate_flag	:=	'N';
	p_unpaid_flag		:=	'N';
	p_protest_flag		:=	'N';
	p_endorse_flag		:=	'N';
	p_restate_flag		:=	'N';
	p_exchange_flag		:=	'N';
	p_delete_flag		:=	'N';


	/*----------------------------------------------+
        |  Validate the BR Identifier			|
        +-----------------------------------------------*/

	AR_BILLS_CREATION_VAL_PVT.Validate_Customer_Trx_ID (p_customer_trx_id);
	ARP_CT_PKG.fetch_p (l_trx_rec, p_customer_trx_id);


	/*----------------------------------------------+
        |  Fetch The current transaction history record	|
        +-----------------------------------------------*/

	l_trh_rec.customer_trx_id	:=	p_customer_trx_id;
	ARP_TRANSACTION_HISTORY_PKG.fetch_f_trx_id (l_trh_rec);


	/*----------------------------------------------+
        |  Fetch The  BR payment schedule information	|
        +-----------------------------------------------*/

	IF	(l_trh_rec.status NOT IN  (C_INCOMPLETE, C_PENDING_ACCEPTANCE, C_CANCELLED))
	THEN
		AR_BILLS_CREATION_LIB_PVT.Get_Payment_Schedule_Id (p_customer_trx_id, l_ps_rec.payment_schedule_id);

                -- bug 2702173 : declare local variable to hold ps_id and pass it to fetch_p
                l_ps_id := l_ps_rec.payment_schedule_id;

		arp_ps_pkg.fetch_p(l_ps_id, l_ps_rec);
	ELSE
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug ('Validate_actions: ' || 'There is no payment schedule for the BR');
		END IF;
	END IF;


	/*----------------------------------------------+
        |   INCOMPLETE	 				|
        +-----------------------------------------------*/

	IF	(l_trh_rec.status = C_INCOMPLETE)
	THEN

		IF	(BR_Has_Assignment(p_customer_trx_id))
		THEN
			p_complete_flag			:=	'Y';
		END IF;

		IF	NOT (Has_Been_Posted(p_customer_trx_id))
		THEN
			p_delete_flag		:=	'Y';
		END IF;



	/*----------------------------------------------+
        |   PENDING_ACCEPTANCE 				|
        +-----------------------------------------------*/

	ELSIF	(l_trh_rec.status = C_PENDING_ACCEPTANCE)
	THEN
		p_accept_flag			:=	'Y';
		p_cancel_flag			:=	'Y';
		p_uncomplete_flag		:=	'Y';



	/*----------------------------------------------+
        |   PENDING_REMITTANCE				|
        +-----------------------------------------------*/

	ELSIF	(l_trh_rec.status = C_PENDING_REMITTANCE)
	THEN

		IF  NOT (Is_BR_Reserved (l_ps_rec)) AND NOT (Is_Payment_Schedule_Reduced (l_ps_rec))
		THEN
			p_cancel_flag		:=	'Y';
			p_endorse_flag		:=	'Y';
		END IF;


		IF	(Is_BR_Remit_Selected(l_trh_rec.transaction_history_id))
		THEN
			p_deselect_remit_flag	:=	'Y';
			p_approve_remit_flag	:=	'Y';
		END IF;


		IF  Not(Is_BR_Reserved (l_ps_rec))
		THEN
			p_hold_flag		:=	'Y';
			p_unpaid_flag		:=	'Y';
			p_select_remit_flag 	:=	'Y';
		END IF;


		IF  (Is_BR_Hold(l_ps_rec))
		THEN
			p_unhold_flag		:=	'Y';
		END IF;


		IF 	(NOT Is_Acceptance_Required (l_ps_rec.cust_trx_type_id) AND
			 NOT Has_been_posted  (p_customer_trx_id)  	AND
			 NOT Is_Payment_Schedule_Reduced (l_ps_rec)	AND
			 NOT Activities_Exist (p_customer_trx_id)	AND
			 NOT Is_BR_Reserved (l_ps_rec)
 			 )
		THEN
			p_uncomplete_flag	:=	'Y';
		END IF;



	/*----------------------------------------------+
        |   STANDARD REMITTED				|
        +-----------------------------------------------*/

	ELSIF	(l_trh_rec.status = C_REMITTED)
	THEN
		p_recall_flag		:=	'Y';

		IF 	Is_BR_Matured(l_ps_rec.due_date)
		THEN
			p_unpaid_flag		:=	'Y';
		END IF;



	/*----------------------------------------------+
        |   FACTORED REMITTED				|
        +-----------------------------------------------*/

	ELSIF	(l_trh_rec.status = C_FACTORED)
	THEN
		p_recall_flag			:=	'Y';



	/*----------------------------------------------+
        |   MATURED PENDING RISK ELIMINATION		|
        +-----------------------------------------------*/

	ELSIF	(l_trh_rec.status = C_MATURED_PEND_RISK_ELIM)
	THEN
		p_unpaid_flag			:=	'Y';

		IF	(Is_Receipt_Cleared (p_customer_trx_id))
		THEN
			p_eliminate_flag	:=	'Y';
		END IF;



	/*----------------------------------------------+
        |   CLOSED					|
        +-----------------------------------------------*/

	ELSIF	(l_trh_rec.status = C_CLOSED)
	THEN

		IF	(Is_BR_Risk_Eliminated(l_trh_rec.transaction_history_id))
		THEN
			p_uneliminate_flag 	:=	'Y';
		END IF;

		IF 	(l_trh_rec.event <> C_EXCHANGED  AND Is_BR_Paid_In_One_Time (l_trh_rec, l_ps_rec))
		AND	(Is_BR_Matured (l_ps_rec.due_date))
		THEN
			p_unpaid_flag		:=	'Y';
		END IF;



	/*----------------------------------------------+
        |   UNPAID					|
        +-----------------------------------------------*/

	ELSIF	(l_trh_rec.status = C_UNPAID)
	THEN

		p_protest_flag			:=	'Y';
		p_restate_flag			:=	'Y';

		IF  NOT (Is_BR_Reserved (l_ps_rec)) AND NOT (Is_Payment_Schedule_Reduced (l_ps_rec))
		THEN
			p_cancel_flag		:=	'Y';
			p_endorse_flag		:=	'Y';
			p_exchange_flag		:=	'Y';
		END IF;

		IF  Not(Is_BR_Reserved (l_ps_rec))
		THEN
			p_hold_flag		:=	'Y';
			p_select_remit_flag	:=	'Y';
		END IF;


		IF  (Is_BR_Hold(l_ps_rec))
		THEN
			p_unhold_flag		:=	'Y';
		END IF;



	/*----------------------------------------------+
        |   PROTESTED					|
        +-----------------------------------------------*/

	ELSIF	(l_trh_rec.status = C_PROTESTED)
	THEN
		p_unpaid_flag			:=	'Y';



	/*----------------------------------------------+
        |   ENDORSED					|
        +-----------------------------------------------*/

	ELSIF	(l_trh_rec.status = C_ENDORSED)
	THEN
		p_recall_flag			:=	'Y';
--		p_eliminate_flag		:=	'Y';

		IF 	Is_BR_Matured(l_ps_rec.due_date)
		THEN
			p_unpaid_flag		:=	'Y';
		END IF;


	END IF;


	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_STATUS_PUB.validate_actions()-');
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : validate_actions () ');
		   arp_util.debug('Validate_actions: ' || 'p_customer_trx_id		: ' || p_customer_trx_id);
		END IF;
		RAISE;

END validate_actions;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    New_Status_Event				                                |
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    For a given BR and an action, returns the new status and event		|
 |										|
 +==============================================================================*/


PROCEDURE New_Status_Event ( 	p_trx_rec		IN 	ra_customer_trx%ROWTYPE	,
				p_action                IN 	VARCHAR2		,
				p_new_status		OUT NOCOPY 	VARCHAR2		,
				p_new_event		OUT NOCOPY 	VARCHAR2		)
IS

l_trh_rec		ar_transaction_history%ROWTYPE;
l_prev_trh_rec		ar_transaction_history%ROWTYPE;

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_STATUS_PUB.New_Status_Event()+');
	END IF;

	p_new_status	:=	NULL;
	p_new_event	:=	NULL;

	/*----------------------------------------------+
        |  Find the Last Relevant History Information	|
        +-----------------------------------------------*/

	SELECT	transaction_history_id
	INTO	l_trh_rec.transaction_history_id
	FROM	ar_transaction_history
	WHERE	customer_trx_id		=	p_trx_rec.customer_trx_id
	AND	current_record_flag	= 	'Y';

	Find_Last_relevant_trh   (l_trh_rec) ;

	l_prev_trh_rec.transaction_history_id 	:=	l_trh_rec.prv_trx_history_id;

	/*----------------------------------------------+
        |   COMPLETE	 				|
        +-----------------------------------------------*/

	IF	(p_action	=	C_COMPLETE)
	THEN
		IF  	(is_acceptance_required(p_trx_rec.cust_trx_type_id))
		THEN
			p_new_status	:=	C_PENDING_ACCEPTANCE;
		ELSE
			p_new_status	:=	C_PENDING_REMITTANCE;
		END IF;

		p_new_event		:=	C_COMPLETED;


	/*----------------------------------------------+
        |   ACCEPT	 				|
        +-----------------------------------------------*/

	ELSIF	(p_action	=	C_ACCEPT)
	THEN
		p_new_status	:=	C_PENDING_REMITTANCE	;
		p_new_event	:=	C_ACCEPTED		;


	/*----------------------------------------------+
        |   UNCOMPLETE	 				|
        +-----------------------------------------------*/

	ELSIF	(p_action	=	C_UNCOMPLETE)
	THEN
		p_new_status	:=	C_INCOMPLETE		;
		p_new_event	:=	C_INCOMPLETE		;


	/*----------------------------------------------+
        |   HOLD	 				|
        +-----------------------------------------------*/

	ELSIF	(p_action	=	C_HOLD		)
	THEN
		p_new_status	:=	l_trh_rec.status	;
		p_new_event	:=	C_HOLD			;


	/*----------------------------------------------+
        |   UNHOLD	 				|
        +-----------------------------------------------*/

	ELSIF	(p_action	=	C_UNHOLD	)
	THEN
		p_new_status	:=	l_trh_rec.status	;
		p_new_event	:=	C_RELEASE_HOLD		;


	/*----------------------------------------------+
        |   SELECT FOR REMITTANCE			|
        +-----------------------------------------------*/

	ELSIF	(p_action = C_SELECT_REMIT)
	THEN
		p_new_status	:=	C_PENDING_REMITTANCE	;
		p_new_event	:=	C_SELECTED_REMITTANCE	;


	/*----------------------------------------------+
        |   DESELECT FOR REMITTANCE			|
        +-----------------------------------------------*/

	ELSIF	(p_action = C_DESELECT_REMIT)
	THEN
		IF  	(p_trx_rec.br_unpaid_flag = 'Y')
		THEN
			p_new_status	:=	C_UNPAID;
		ELSE
			p_new_status	:=	C_PENDING_REMITTANCE	;
		END IF;

		p_new_event	:=	C_DESELECTED_REMITTANCE	;


	/*----------------------------------------------+
        |   CANCEL					|
        +-----------------------------------------------*/

	ELSIF	(p_action = C_CANCEL)
	THEN
		p_new_status	:=	C_CANCELLED		;
		p_new_event	:=	C_CANCELLED		;



	/*----------------------------------------------+
        |   APPROVE STANDARD REMITTED			|
        +-----------------------------------------------*/

	ELSIF	(p_action = C_REMIT_STANDARD)
	THEN
		p_new_status	:=	C_REMITTED		;
		p_new_event	:=	C_REMITTED		;


	/*----------------------------------------------+
        |   APPROVE FACTORE WITHOUT RECOURSE		|
        +-----------------------------------------------*/

	ELSIF	(p_action = C_FACTORE)
	THEN
		IF	(l_trh_rec.status = C_FACTORED)
		THEN
			p_new_status	:=	C_CLOSED	;
			p_new_event	:=	C_CLOSED	;
		ELSE
			p_new_status	:=	C_FACTORED	;
			p_new_event	:=	C_FACTORED	;
		END IF;


	/*----------------------------------------------+
        |   APPROVE FACTORE WITH RECOURSE		|
        +-----------------------------------------------*/

	ELSIF	(p_action = C_FACTORE_RECOURSE)
	THEN
		p_new_status	:=	C_FACTORED		;
		p_new_event	:=	C_FACTORED		;


	/*----------------------------------------------+
        |   ELIMINATE RISK				|
        +-----------------------------------------------*/

	ELSIF	(p_action = C_ELIMINATE_RISK)
	THEN
		p_new_status	:=	C_CLOSED		;
		p_new_event	:=	C_RISK_ELIMINATED	;


	/*----------------------------------------------+
        |   UNELIMINATE RISK				|
        +-----------------------------------------------*/

	ELSIF	(p_action = C_UNELIMINATE_RISK)
	THEN

		Find_Last_relevant_trh  (l_prev_trh_rec) 	;

		p_new_status	:=	l_prev_trh_rec.status	;
		p_new_event	:=	C_RISK_UNELIMINATED	;


	/*----------------------------------------------+
        |   ENDORSE WITH RECOURSE			|
        +-----------------------------------------------*/

	ELSIF	(p_action = C_ENDORSE_RECOURSE)
	THEN
		p_new_status	:=	C_ENDORSED		;
		p_new_event	:=	C_ENDORSED 		;


	/*----------------------------------------------+
        |   ENDORSE WITHOUT RECOURSE			|
        +-----------------------------------------------*/

	ELSIF	(p_action = C_ENDORSE)
	THEN
		IF	(l_trh_rec.status = C_ENDORSED)
		THEN
			p_new_status	:=	C_CLOSED	;
			p_new_event	:=	C_CLOSED 	;
		ELSE
			p_new_status	:=	C_ENDORSED	;
			p_new_event	:=	C_ENDORSED 	;
		END IF;


	/*----------------------------------------------+
        |   UNPAID					|
        +-----------------------------------------------*/

	ELSIF	(p_action = C_UNPAID)
	THEN
		p_new_status	:=	C_UNPAID		;
		p_new_event	:=	C_UNPAID 		;


	/*----------------------------------------------+
        |   RESTATE					|
        +-----------------------------------------------*/

	ELSIF	(p_action = C_RESTATE)
	THEN
		p_new_status	:=	C_PENDING_REMITTANCE	;
		p_new_event	:=	C_RESTATE 		;



	/*----------------------------------------------+
        |   RECALL					|
        +-----------------------------------------------*/

	ELSIF	(p_action = C_RECALL)
	THEN

		IF  	(p_trx_rec.br_unpaid_flag = 'Y')
		THEN
			p_new_status	:=	C_UNPAID		;
		ELSE
			p_new_status	:=	C_PENDING_REMITTANCE	;
		END IF;
		p_new_event		:=	C_RECALLED 		;


	/*----------------------------------------------+
        |   PROTEST					|
        +-----------------------------------------------*/

	ELSIF	(p_action = C_PROTEST)
	THEN
		p_new_status	:=	C_PROTESTED		;
		p_new_event	:=	C_PROTESTED 		;


	/*----------------------------------------------+
        |   EXCHANGE					|
        +-----------------------------------------------*/

	ELSIF	(p_action = C_EXCHANGE)
	THEN
		p_new_status	:=	l_trh_rec.status	;
		p_new_event	:=	C_EXCHANGED 		;



	/*----------------------------------------------+
        |   EXCHANGE COMPLETE				|
        +-----------------------------------------------*/

	ELSIF	(p_action = C_EXCHANGE_COMPLETE)
	THEN
		p_new_status	:=	C_CLOSED		;
		p_new_event	:=	C_EXCHANGED 		;


	/*----------------------------------------------+
        |   EXCHANGE UNCOMPLETE				|
        +-----------------------------------------------*/

	ELSIF	(p_action = C_EXCHANGE_UNCOMPLETE)
	THEN
		p_new_status	:=	C_UNPAID		;
		p_new_event	:=	C_EXCHANGED 		;

	ELSE

		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug ('New_Status_Event: ' || '>>>>>>>>>> The action ' || p_action || ' is invalid ');
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_MAINTAIN_STATUS_PUB.New_Status_Event () ');
		END IF;
		FND_MESSAGE.SET_NAME ('AR', 'AR_BR_ACTION_FORBIDDEN');
		FND_MESSAGE.SET_TOKEN('ACTION', p_action);
		FND_MESSAGE.SET_TOKEN('BRNUM',  p_trx_rec.trx_number);
		app_EXCEPTION.raise_EXCEPTION;

	END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug ('New_Status_Event: ' || 'New Status  : ' ||  p_new_status);
	   arp_util.debug ('New_Status_Event: ' || 'New Event   : ' ||  p_new_event);
	   arp_util.debug('AR_BILLS_MAINTAIN_STATUS_PUB.New_Status_Event()-');
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : New_Status_Event () ');
		   arp_util.debug('New_Status_Event: ' || 'p_action = ' || p_action);
		END IF;
		RAISE;

END New_Status_Event;


/*===========================================================================+
 | FUNCTION                                                                  |
 |    revision                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function returns the revision number of this package.             |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | RETURNS    : Revision number of this package                              |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |      10 JAN 2001 John HALL           Created                              |
 +===========================================================================*/
FUNCTION revision RETURN VARCHAR2 IS
BEGIN
  RETURN '$Revision: 115.12 $';
END revision;
--


END AR_BILLS_MAINTAIN_STATUS_PUB ;

/
