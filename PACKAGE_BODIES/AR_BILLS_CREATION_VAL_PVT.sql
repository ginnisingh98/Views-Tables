--------------------------------------------------------
--  DDL for Package Body AR_BILLS_CREATION_VAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_BILLS_CREATION_VAL_PVT" AS
/* $Header: ARBRCRVB.pls 120.7 2005/12/05 20:03:55 sgnagara ship $ */



/* =======================================================================
 | Bills Receivable status constants
 * ======================================================================*/

C_INCOMPLETE			CONSTANT VARCHAR2(30)	:=	'INCOMPLETE';
C_UNPAID			CONSTANT VARCHAR2(30)	:=	'UNPAID';
C_FACTORED			CONSTANT VARCHAR2(30)	:=	'FACTORED';
C_REMITTED			CONSTANT VARCHAR2(30)	:=	'REMITTED';


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_GL_Date			                                     	|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    Validates that the GL Date is in an open or future period		     	|
 |									  	|
 +==============================================================================*/

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE Validate_Gl_Date (p_gl_date  IN  DATE) IS

BEGIN

  	IF PG_DEBUG in ('Y', 'C') THEN
  	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_Gl_Date ()+');
  	END IF;

	IF  (p_gl_date IS NOT NULL)
	THEN
		IF ( NOT arp_util.is_gl_date_valid( p_gl_date ))
		THEN
		       	IF PG_DEBUG in ('Y', 'C') THEN
		       	   arp_util.debug('Validate_Gl_Date: ' || '>>>>>>>>>> Invalid GL Date');
		       	END IF;
    			FND_MESSAGE.set_name	( 'AR', 'AR_INVALID_APP_GL_DATE' );
	    		FND_MESSAGE.set_token	( 'GL_DATE', TO_CHAR( p_gl_date ));
			app_exception.raise_exception;
	   	END IF;
	END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_Gl_Date ()-');
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_VAL_PVT.Validate_GL_Date() ');
		   arp_util.debug('Validate_Gl_Date: ' || 'p_gl_date = ' || p_gl_date);
		END IF;
		RAISE;

END Validate_Gl_Date;




/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_Update_Maturity_Date	                                     	|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Validates that Maturity Date can be updated			     	|
 |                                                                           	|
 +==============================================================================*/

PROCEDURE Validate_Update_Maturity_Date (p_customer_trx_id	IN  ra_customer_trx.customer_trx_id%TYPE,
					 p_term_due_date 	IN  DATE				)
IS

l_trx_rec	ra_customer_trx%ROWTYPE;
l_ps_rec	ar_payment_schedules%ROWTYPE;
l_trh_rec	ar_transaction_history%ROWTYPE;

BEGIN

   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_Update_Maturity_Date ()+');
   	END IF;


	/*----------------------------------------------+
        |   Fetch the BR History Information :		|
    	|   Current Status				|
        +-----------------------------------------------*/

	ARP_CT_PKG.fetch_p (l_trx_rec, p_customer_trx_id);
	l_trh_rec.customer_trx_id	:=	p_customer_trx_id;
	ARP_TRANSACTION_HISTORY_PKG.fetch_f_trx_id (l_trh_rec);


	IF	l_trh_rec.status in (C_FACTORED, C_REMITTED)
	THEN
		IF	AR_BILLS_MAINTAIN_STATUS_PUB.Is_BR_Matured (l_trx_rec.term_due_date)
		THEN
			IF PG_DEBUG in ('Y', 'C') THEN
			   arp_util.debug('Validate_Update_Maturity_Date: ' || '>>>>>>>>>> Current Maturity Date has passed, it cannot be updated');
	      		   arp_util.debug('Validate_Update_Maturity_Date: ' || 'Maturity Date parameter  : ' || p_term_due_date);
 		     	   arp_util.debug('Validate_Update_Maturity_Date: ' || 'Maturity Date of the BR  : ' || l_trx_rec.term_due_date);
 		     	END IF;
   			FND_MESSAGE.set_name( 'AR','AR_BR_CANNOT_UPDATE_MAT_DATE');
			app_exception.raise_exception;
		END IF;

		IF	trunc(p_term_due_date)   <=  trunc(SYSDATE)
		THEN
			IF PG_DEBUG in ('Y', 'C') THEN
			   arp_util.debug('Validate_Update_Maturity_Date: ' || '>>>>>>>>>> The new Maturity Date must be later that sysdate');
	      		   arp_util.debug('Validate_Update_Maturity_Date: ' || 'Maturity Date parameter  : ' || p_term_due_date);
	      		END IF;
			FND_MESSAGE.set_name	( 'AR', 'AR_BR_INVALID_TRX_DATE' );
	    		FND_MESSAGE.set_token	( 'ACTION', NULL);
			FND_MESSAGE.set_token	( 'NEW_TRX_DATE', p_term_due_date);
			FND_MESSAGE.set_token	( 'OLD_TRX_DATE', trunc(sysdate));
			app_exception.raise_exception;
		END IF;

	END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_Update_Maturity_Date ()-');
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_VAL_PVT.Validate_Update_Maturity_Date() ');
		   arp_util.debug('Validate_Update_Maturity_Date: ' || 'p_customer_trx_id = ' || p_customer_trx_id);
		   arp_util.debug('Validate_Update_Maturity_Date: ' || 'p_term_due_date   = ' || p_term_due_date);
		END IF;
		RAISE;

END Validate_Update_Maturity_Date;



/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_Batch_Source		                                     	|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Validates that : 								|
 |	- The Batch Source exists						|
 |	- The status is Active							|
 |	- It is valid at the Issue Date						|
 |									     	|
 +=============================================================================*/

PROCEDURE Validate_Batch_Source (p_batch_source_id 	IN  	NUMBER	,
				 p_issue_date		IN	DATE	)  IS

l_start_date		DATE;
l_end_date		DATE;
l_status		VARCHAR2(1);

BEGIN
   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_Batch_Source()+');
   	END IF;

	SELECT 	start_date, end_date, status
	INTO	l_start_date, l_end_date, l_status
	FROM	RA_BATCH_SOURCES  bs
	WHERE  	bs.batch_source_id      =  p_batch_source_id;

	/*----------------------------------------------+
        |  Check the status of the batch source		|
        +-----------------------------------------------*/

	IF	(l_status 	<>	'A')
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug ('Validate_Batch_Source: ' || '>>>>>>>>>> The Batch Source is inactive');
		   arp_util.debug ('Validate_Batch_Source: ' || 'p_batch_source_id = ' || p_batch_source_id);
		   arp_util.debug ('Validate_Batch_Source: ' || 'p_issue_date	   = ' || p_issue_date);
		   arp_util.debug ('Validate_Batch_Source: ' || 'status            = ' || l_status);
		END IF;
		FND_MESSAGE.SET_NAME ('AR', 'AR_BR_INACTIVE_BATCH_SOURCE');
		app_exception.raise_exception;
	END IF;


	/*----------------------------------------------+
        |  Check the batch source is valid at the issue	|
	|  date						|
        +-----------------------------------------------*/

	IF	(p_issue_date 	NOT BETWEEN nvl (l_start_date, p_issue_date)
					AND nvl (l_end_date  , p_issue_date))
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug ('Validate_Batch_Source: ' || '>>>>>>>>>> The Batch Source is not valid at the Issue Date');
		   arp_util.debug('Validate_Batch_Source: ' || 'p_batch_source_id = ' || p_batch_source_id);
		   arp_util.debug('Validate_Batch_Source: ' || 'p_issue_date	  = ' || p_issue_date);
		   arp_util.debug('Validate_Batch_Source: ' || 'start_date        = ' || l_start_date);
		   arp_util.debug('Validate_Batch_Source: ' || 'end_date          = ' || l_end_date);
		END IF;
		FND_MESSAGE.SET_NAME ('AR', 'AR_BR_BAD_DATE_SOURCE');
		app_exception.raise_exception;
	END IF;


   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_Batch_Source()-');
   	END IF;

EXCEPTION
    	WHEN NO_DATA_FOUND THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_VAL_PVT.Validate_Batch_Source() ');
	      	   arp_util.debug('Validate_Batch_Source: ' || '>>>>>>>>>> Invalid Batch Source');
		   arp_util.debug('Validate_Batch_Source: ' || '           p_batch_source_id = ' || p_batch_source_id);
		   arp_util.debug('Validate_Batch_Source: ' || '           p_issue_date	     = ' || p_issue_date);
		END IF;
		FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_INVALID_BATCH_SOURCE');
  	   	app_exception.raise_exception;

	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_VAL_PVT.Validate_Batch_Source() ');
		   arp_util.debug('Validate_Batch_Source: ' || '           p_batch_source_id = ' || p_batch_source_id);
		   arp_util.debug('Validate_Batch_Source: ' || '           p_issue_date	     = ' || p_issue_date);
		END IF;
		RAISE;

END Validate_Batch_Source;




/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_Transaction_Type		                                     	|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Validates the Transaction Type Identifier, the status and the Type (BR)	|
 |									     	|
 +=============================================================================*/

PROCEDURE Validate_Transaction_Type (p_cust_trx_type_id		IN  	NUMBER	,
				     p_issue_date		IN	DATE	)
IS

l_start_date		DATE;
l_end_date		DATE;
l_status		VARCHAR2(1);


BEGIN

   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_Transaction_Type()+');
   	END IF;

	SELECT  status, start_date, end_date
	INTO	l_status, l_start_date, l_end_date
	FROM	RA_CUST_TRX_TYPES
	WHERE  	cust_trx_type_id      	=  p_cust_trx_type_id
	AND	TYPE			=  'BR';


	/*----------------------------------------------+
        |  Check the status of the transaction type	|
        +-----------------------------------------------*/

	IF	(l_status 	<>	'A')
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug ('Validate_Transaction_Type: ' || '>>>>>>>>>> The Transaction Type is inactive');
		   arp_util.debug ('Validate_Transaction_Type: ' || 'p_cust_trx_type_id = ' || p_cust_trx_type_id);
		   arp_util.debug ('Validate_Transaction_Type: ' || 'p_issue_date	    = ' || p_issue_date);
		   arp_util.debug ('Validate_Transaction_Type: ' || 'status             = ' || l_status);
		END IF;
		FND_MESSAGE.SET_NAME ('AR', 'AR_BR_INACTIVE_TRX_TYPE');
		app_exception.raise_exception;
	END IF;


	/*----------------------------------------------+
        |  Check the transaction type is valid at the	|
	|  Issue Date					|
        +-----------------------------------------------*/

	IF	(p_issue_date 	NOT BETWEEN l_start_date
					AND nvl (l_end_date  , p_issue_date))
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug ('Validate_Transaction_Type: ' || '>>>>>>>>>> The Transaction Type is not valid at the Issue Date');
		   arp_util.debug ('Validate_Transaction_Type: ' || 'p_cust_trx_type_id = ' || p_cust_trx_type_id);
		   arp_util.debug ('Validate_Transaction_Type: ' || 'p_issue_date	    = ' || p_issue_date);
		   arp_util.debug ('Validate_Transaction_Type: ' || 'start_date         = ' || l_start_date);
		   arp_util.debug ('Validate_Transaction_Type: ' || 'end_date           = ' || l_end_date);
		END IF;
		FND_MESSAGE.SET_NAME ('AR', 'AR_BR_BAD_DATE_TRX_TYPE');
		app_exception.raise_exception;
	END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_Transaction_Type()-');
	END IF;

EXCEPTION
    	WHEN   NO_DATA_FOUND THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_VAL_PVT.Validate_Transaction_Type() ');
      		   arp_util.debug('Validate_Transaction_Type: ' || '>>>>>>>>>> Invalid Transaction Type');
		   arp_util.debug('Validate_Transaction_Type: ' || '           p_cust_trx_type_id = ' || p_cust_trx_type_id);
		   arp_util.debug('Validate_Transaction_Type: ' || '           p_issue_date	      = ' || p_issue_date);
		END IF;
	   	FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_INVALID_TRX_TYPE');
		app_exception.raise_exception;

	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_VAL_PVT.Validate_Transaction_Type() ');
		   arp_util.debug('Validate_Transaction_Type: ' || '           p_cust_trx_type_id = ' || p_cust_trx_type_id);
		   arp_util.debug('Validate_Transaction_Type: ' || '           p_issue_date	      = ' || p_issue_date);
		END IF;
		RAISE;

END Validate_Transaction_Type;



/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_Drawee			                                     	|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Validates that the Drawee exists					     	|
 |                                                                           	|
 +==============================================================================*/

PROCEDURE Validate_Drawee (p_drawee_id 	IN  NUMBER) IS

l_drawee_valid	VARCHAR2(1);

BEGIN
   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_Drawee ()+');
   	END IF;

        /* modified for tca uptake */
	SELECT 'Y'
	INTO	l_drawee_valid
	FROM	HZ_CUST_ACCOUNTS
	WHERE  	cust_account_id    	=  p_drawee_id;

   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_Drawee ()-');
   	END IF;

EXCEPTION
    	WHEN NO_DATA_FOUND THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_VAL_PVT.Validate_Drawee () ');
      	   	   arp_util.debug('Validate_Drawee: ' || '>>>>>>>>>> Invalid Drawee');
		   arp_util.debug('Validate_Drawee: ' || '           p_drawee_id = ' || p_drawee_id);
		END IF;
	   	FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_INVALID_DRAWEE');
	   	app_exception.raise_exception;

    	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_VAL_PVT.Validate_Drawee () ');
		   arp_util.debug('Validate_Drawee: ' || '           p_drawee_id = ' || p_drawee_id);
		END IF;
		RAISE;


END Validate_Drawee;



/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_Drawee_Location		                                     	|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Validates that the Drawee Location is Active			     	|
 |                                                                           	|
 +==============================================================================*/

PROCEDURE Validate_Drawee_Location (p_drawee_site_use_id	IN  NUMBER) IS

l_status		VARCHAR2(1);

BEGIN
   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_Drawee_Location ()+');
   	END IF;

	IF (p_drawee_site_use_id IS NOT NULL)
	THEN
                /* modified for tca uptake */
		SELECT  STATUS
		INTO	l_status
		FROM	HZ_CUST_SITE_USES
		WHERE  	site_use_id    	=  p_drawee_site_use_id
		AND	SITE_USE_CODE	=  'DRAWEE';

		/*----------------------------------------------+
	        |  Check that the Drawee Location is active	|
	        +-----------------------------------------------*/

		IF  (l_status <> 'A')
		THEN
      	   	    IF PG_DEBUG in ('Y', 'C') THEN
      	   	       arp_util.debug('Validate_Drawee: ' || '>>>>>>>>>> Drawee Location Inactive');
      	   	    END IF;
	   	    FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_INACTIVE_DRAWEE_SITE');
	   	    app_exception.raise_exception;
		END IF;
	END IF;

   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_Drawee_Location ()-');
   	END IF;

EXCEPTION
    	WHEN NO_DATA_FOUND THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_VAL_PVT.Validate_Drawee_Location () ');
      	   	   arp_util.debug('Validate_Drawee: ' || '>>>>>>>>>> Invalid Location');
		   arp_util.debug('Validate_Drawee: ' || '           p_drawee_site_use_id = ' || p_drawee_site_use_id);
		END IF;
	   	FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_INVALID_DRAWEE_SITE');
	   	app_exception.raise_exception;

    	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_VAL_PVT.Validate_Drawee_Location () ');
		   arp_util.debug('Validate_Drawee: ' || '           p_drawee_site_use_id = ' || p_drawee_site_use_id);
		END IF;
		RAISE;

END Validate_Drawee_Location;



/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_Drawee_Contact			                               	|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Validates that the Drawee Contact is Active			     	|
 |                                                                           	|
 +==============================================================================*/

PROCEDURE Validate_Drawee_Contact (p_drawee_contact_id 	IN  NUMBER	,
				   p_drawee_id		IN  NUMBER	) IS

l_status	VARCHAR2(1);

BEGIN
   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_Drawee_Contact ()+');
   	END IF;

	IF (p_drawee_contact_id IS NOT NULL)
	THEN
                /* modified for tca uptake */
                /* fixed bug 1883538: use status instead of
                   current role state */
                SELECT  status
		INTO	l_status
		FROM	hz_cust_account_roles
		WHERE  	cust_account_role_id =  p_drawee_contact_id
		AND	cust_account_id	=  p_drawee_id;

		IF  (l_status <> 'A')
		THEN
      	   	    IF PG_DEBUG in ('Y', 'C') THEN
      	   	       arp_util.debug('Validate_Drawee: ' || '>>>>>>>>>> Drawee Contact Inactive');
      	   	    END IF;
	   	    FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_INACTIVE_DRAWEE_CONTACT');
	   	    app_exception.raise_exception;
		END IF;

	END IF;

   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_Drawee_Contact ()-');
   	END IF;

EXCEPTION
    	WHEN NO_DATA_FOUND THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_VAL_PVT.Validate_Drawee_Contact () ');
      	   	   arp_util.debug('Validate_Drawee: ' || '>>>>>>>>>> Invalid Contact');
		   arp_util.debug('Validate_Drawee: ' || '           p_drawee_contact_id = ' || p_drawee_contact_id);
		   arp_util.debug('Validate_Drawee: ' || '           p_drawee_id         = ' || p_drawee_id);
		END IF;
	   	FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_INVALID_DRAWEE_CONTACT');
	   	app_exception.raise_exception;

    	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_VAL_PVT.Validate_Drawee_Contact () ');
		   arp_util.debug('Validate_Drawee: ' || '           p_drawee_contact_id = ' || p_drawee_contact_id);
		   arp_util.debug('Validate_Drawee: ' || '           p_drawee_id         = ' || p_drawee_id);
		END IF;
		RAISE;

END Validate_Drawee_Contact;



/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_Currency			                                     	|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Validates that the Currency is Active at the Issue Date		     	|
 |                                                                           	|
 +==============================================================================*/

PROCEDURE Validate_Currency ( 	p_invoice_currency_code	IN  	VARCHAR2,
				p_issue_date		IN	DATE	) IS

l_start_date		DATE;
l_end_date		DATE;

BEGIN
   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('Validate_Drawee: ' || 'AR_BILLS_CREATION_VAL_PVT.Validate_Currency ()+');
   	END IF;

	SELECT  start_date_active, end_date_active
	INTO	l_start_date     , l_end_date
	FROM	FND_CURRENCIES_VL
	WHERE  	currency_code  	=  p_invoice_currency_code
	AND	enabled_flag	=	'Y';


	/*----------------------------------------------+
        |  Check the currency is valid at the issue	|
	|  date						|
        +-----------------------------------------------*/

	IF	(p_issue_date	NOT BETWEEN	nvl(l_start_date, p_issue_date)
				AND		nvl(l_end_date, p_issue_date))
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('Validate_Drawee: ' || '>>>>>>>>>> Currency Invalid with Issue Date');
		   arp_util.debug('Validate_Drawee: ' || 'Issue Date : ' || p_issue_date);
		   arp_util.debug('Validate_Drawee: ' || 'Currency   : ' || p_invoice_currency_code);
		END IF;
		FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_BAD_DATE_CURRENCY');
		app_exception.raise_exception;
	END IF;


   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('Validate_Drawee: ' || 'AR_BILLS_CREATION_VAL_PVT.Validate_Currency ()-');
   	END IF;

EXCEPTION
    	WHEN NO_DATA_FOUND THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('Validate_Drawee: ' || '>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_VAL_PVT.Validate_Currency () ');
      	   	   arp_util.debug('Validate_Drawee: ' || '>>>>>>>>>> Invalid Currency');
		   arp_util.debug('Validate_Drawee: ' || '           p_invoice_currency_code = : ' || p_invoice_currency_code);
		   arp_util.debug('Validate_Drawee: ' || '           p_issue_date            = : ' || p_issue_date);
		END IF;
	   	FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_INVALID_CURRENCY');
	   	app_exception.raise_exception;

	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('Validate_Drawee: ' || '>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_VAL_PVT.Validate_Currency () ');
		   arp_util.debug('Validate_Drawee: ' || '           p_invoice_currency_code = : ' || p_invoice_currency_code);
		   arp_util.debug('Validate_Drawee: ' || '           p_issue_date            = : ' || p_issue_date);
		END IF;
		RAISE;

END Validate_Currency;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_Printing_Option		                                     	|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Validates that :							    	|
 |	-  Values allowed are PRI and NOT					|
 | 	-  Printing is mandatory, if the bill has to be signed			|
 |	-  If the printing option is set to 'Y', a format must be defined for   |
 |	   the transaction type							|
 |                                                                           	|
 +==============================================================================*/

PROCEDURE Validate_Printing_Option  ( p_printing_option		IN  VARCHAR2	,
				      p_cust_trx_type_id	IN  NUMBER	) IS

l_format_program_id		NUMBER;
l_signed_flag			VARCHAR2(1);
l_printing_option_valid		VARCHAR2(1);
printing_option_invalid		EXCEPTION;

BEGIN
   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('Validate_Drawee: ' || 'AR_BILLS_CREATION_VAL_PVT.Validate_Printing_Option ()+');
   	END IF;


	/*----------------------------------------------+
        |  Validate p_printing_option in ar_lookups	|
	|  lookup_type = INVOICE_PRINT_OPTIONS		|
        +-----------------------------------------------*/

	IF	(p_printing_option IS NOT NULL)
	THEN
	    BEGIN
		SELECT	'Y'
		INTO	l_printing_option_valid
		FROM	AR_LOOKUPS
		WHERE	lookup_type 	=	'INVOICE_PRINT_OPTIONS'
		AND	lookup_code	=	p_printing_option;

		EXCEPTION
			WHEN	NO_DATA_FOUND	THEN
				RAISE	printing_option_invalid;
	    END;
	END IF;


	/*----------------------------------------------+
        |  Validate whether printing is mandatory or not|
        +-----------------------------------------------*/

	SELECT	signed_flag  ,  format_program_id
	INTO	l_signed_flag,	l_format_program_id
	FROM	RA_CUST_TRX_TYPES
	WHERE  	cust_trx_type_id  =  p_cust_trx_type_id;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('Validate_Drawee: ' || 'Signed Flag     : ' || l_signed_flag);
	   arp_util.debug('Validate_Drawee: ' || 'Format Program  : ' || l_format_program_id);
	   arp_util.debug('Validate_Drawee: ' || 'Printing Option : ' || p_printing_option);
	END IF;

	IF  (p_printing_option = 'NOT' and  l_signed_flag = 'Y')
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('Validate_Drawee: ' || '>>>>>>>>>> Printing is mandatory');
		END IF;
       	   	FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_PRINTING_MANDATORY');
	   	app_exception.raise_exception;
	END IF;


	/*----------------------------------------------+
        |  If printing option is PRI, check that the	|
	|  format program is defined			|
        +-----------------------------------------------*/

	IF  (p_printing_option = 'PRI' AND l_format_program_id IS NULL)
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('Validate_Drawee: ' || '>>>>>>>>>> No format program id');
		END IF;
       	   	FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_NO_PRINT_FORMAT');
	   	app_exception.raise_exception;
	END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('Validate_Drawee: ' || 'AR_BILLS_CREATION_VAL_PVT.Validate_Printing_Option ()-');
	END IF;

EXCEPTION
	WHEN  	printing_option_invalid	  THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('Validate_Drawee: ' || '>>>>>>>>>> Invalid Value for Printing Option');
      	   	   arp_util.debug('Validate_Drawee: ' || '           Printing Option : ' || p_printing_option);
      	   	END IF;
      	   	FND_MESSAGE.SET_NAME  ('AR', 'AR_PROCEDURE_VALID_ARGS_FAIL');
		FND_MESSAGE.SET_TOKEN ('PARAMETER', 'Printing Option');
		FND_MESSAGE.SET_TOKEN ('PROCEDURE', 'BR CREATION API');
	   	app_exception.raise_exception;

	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('Validate_Drawee: ' || '>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_VAL_PVT.Validate_Printing_Option () ');
		   arp_util.debug('Validate_Drawee: ' || '           p_printing_option  = ' || p_printing_option);
		   arp_util.debug('Validate_Drawee: ' || '           p_cust_trx_type_id = ' || p_cust_trx_type_id);
		END IF;
		RAISE;

END Validate_Printing_Option;



/*=============================================================================+
 | PROCEDURE                                                                   |
 |    Validate_Drawee_Account	                                     	       |
 |                                                                             |
 | DESCRIPTION                                                                 |
 |    Validates that the Drawee Account :				       |
 |	-  Belongs to the Drawee					       |
 |	-  Is Active at the Issue Date				               |
 |                                                                             |
 | History								       |
 | Date		Name		Description				       |
 | 02-May-01	Debbie Jancis	Added History Section and modified how the     |
 |				account is validated because bank account      |
 |			 	uses will only be linked to bill to buisness   |
 |				purposes.				       |
 | 24-May-01	Debbie Jancis   Fixed bug 1798699:  changed all selects to     |
 |				verify bank account information with issue     |
 |                              instead of trying to select dates and then     |
 |                              verify because customer setup allows multiple  |
 |                              usage records with different dates.  This      |
 |                              causes too many rows to be selected.           |
 +============================================================================*/

PROCEDURE Validate_Drawee_Account (	p_drawee_bank_account_id IN  VARCHAR2	,
			     		p_drawee_id		 IN  NUMBER	,
					p_drawee_site_use_id	 IN  NUMBER	,
					p_issue_date		 IN  DATE	) IS

l_start_date		DATE;
l_end_date		DATE;
l_bill_site_use_id      NUMBER;
l_bank_ok               NUMBER;   /* bug 1798699 */

BEGIN
   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_Drawee_Account ()+');
   	END IF;

        /* bug 1758982:  Unable to create Manual BR when customer has
           more then 1 drawee site with same bank account assigned */

       /* PAYMENT_UPTAKE: Removed validation bcoz Drawee_bank_account_id is obsoleted */

 	IF PG_DEBUG in ('Y', 'C') THEN
 	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_Drawee_Account ()-');
 	END IF;

END Validate_Drawee_Account;




/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_Remit_Account		                                     	|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Validates that the Remittance Account :				     	|
 |	-  Is Internal								|
 |	-  Is of the same currency as the BR or is a multi-currency account	|
 |	-  Is valid at the Issue Date						|
 |                                                                           	|
 +==============================================================================*/

PROCEDURE validate_remit_account (p_remit_bank_account_id IN VARCHAR2,
                                  p_invoice_currency_code IN VARCHAR2,
  				  p_issue_date		  IN DATE) IS


  -- Substitued a cursor for a direct select.  Because of the CBA project
  -- we should now assume that all remit_bank_account_id columns/variables
  -- contain the use ids.
  --
  -- ORASHID 22-OCT-2003

  /* Bug 3285863 Selecting receipt_multi_currency_flag rather than
     multi_currency_allowed_flag. */

  CURSOR c IS
    SELECT cba.currency_code,
           cba.receipt_multi_currency_flag receipt_multi_currency_flag,
           cbau.end_date inactive_date
    FROM   ce_bank_accounts cba,
           ce_bank_acct_uses cbau
    WHERE  cbau.bank_acct_use_id = p_remit_bank_account_id
    AND    cbau.bank_account_id = cba.bank_account_id
    AND    cba.account_classification = 'INTERNAL';


  l_receipt_multi_currency_flag	 VARCHAR2(1);
  l_currency_code	 VARCHAR2(15);
  l_inactive_date	 DATE;

BEGIN

  IF pg_debug IN ('Y', 'C') THEN
    arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_Remit_Account ()+');
  END IF;

  IF (p_remit_bank_account_id IS NOT NULL) THEN

    OPEN c;
    FETCH c INTO l_currency_code, l_receipt_multi_currency_flag, l_inactive_date;
    CLOSE c;

    /*----------------------------------------------+
     |  Validate that the remittance account is of  |
     |  the same currency as the BR or is a         |
     |  multi-currency account			    |
     +----------------------------------------------*/

    IF (l_currency_code <> p_invoice_currency_code) AND
       (l_receipt_multi_currency_flag	<>  'Y') THEN

      IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('Validate_Remit_Account: ' ||
          '>>>>>>>>>> Remittance Account invalid Currency');
        arp_util.debug('Validate_Remit_Account: ' ||
         '           remit bank account use id : ' || p_remit_bank_account_id);
        arp_util.debug('Validate_Remit_Account: ' ||
         '           BR Currency               : ' || p_invoice_currency_code);
        arp_util.debug('Validate_Remit_Account: ' ||
         '           Remit Account Currency    : ' || l_currency_code);
        arp_util.debug('Validate_Remit_Account: ' ||
         '           Multi Currency Flag       : ' || l_receipt_multi_currency_flag);
      END IF;

      fnd_message.set_name ('AR', 'AR_BR_INVALID_REMIT_CURRENCY');
      app_exception.raise_exception;

    END IF;


   /*------------------------------------------------+
    |  Validate that the remittance account is valid |
    |  at the issue date			            |
    +------------------------------------------------*/

    IF (p_issue_date NOT BETWEEN p_issue_date AND
        NVL(l_inactive_date , p_issue_date)) THEN

      IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('>>>>>>>>>> EXCEPTION : Validate_Remit_Account () ');
        arp_util.debug('Validate_Remit_Account: ' ||
          '>>>>>>>>>> Remittance Account invalid with Issue Date');
        arp_util.debug('Validate_Remit_Account: ' ||
          '           p_issue_date              : ' || p_issue_date);
        arp_util.debug('Validate_Remit_Account: ' ||
          '           remit bank account use id : ' ||
          p_remit_bank_account_id);
      END IF;

      fnd_message.set_name('AR', 'AR_BR_BAD_DATE_REMIT_ACCOUNT');
      app_exception.raise_exception;

    END IF;

  END IF;

  IF pg_debug IN ('Y', 'C') THEN
    arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_Remit_Account ()-');
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF pg_debug IN ('Y', 'C') THEN
      arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_VAL_PVT.Validate_Remit_Account () ');
      arp_util.debug('Validate_Remit_Account: ' || '>>>>>>>>>> Invalid Remittance Account');
      arp_util.debug('Validate_Remit_Account: ' || '           remit bank account use id  = ' || p_remit_bank_account_id);
      arp_util.debug('Validate_Remit_Account: ' || '           p_invoice_currency_code   = ' || p_invoice_currency_code);
      arp_util.debug('Validate_Remit_Account: ' || '           p_issue_date              = ' || p_issue_date);
    END IF;

    fnd_message.set_name('AR', 'AR_BR_INVALID_REMIT_ACCOUNT');
    app_exception.raise_exception;

  WHEN OTHERS THEN
    IF pg_debug IN ('Y', 'C') THEN
      arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_VAL_PVT.Validate_Remit_Account () ');
      arp_util.debug('Validate_Remit_Account: ' || '           remit bank account use id = ' || p_remit_bank_account_id);
      arp_util.debug('Validate_Remit_Account: ' || '           p_invoice_currency_code   = ' || p_invoice_currency_code);
      arp_util.debug('Validate_Remit_Account: ' || '           p_issue_date              = ' || p_issue_date);
    END IF;
    RAISE;

END validate_remit_account;



/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_Override_Flag		                                     	|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Validates the value of the Override_Remit_Account_Flag : 'Y' or 'N'	|
 |										|
 |                                                                           	|
 +==============================================================================*/

PROCEDURE Validate_Override_Flag  (   p_override_remit_account_flag IN  VARCHAR2) IS

BEGIN
   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_Override_Flag ()+');
   	END IF;

	IF  p_override_remit_account_flag  NOT IN ('Y', 'N')
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('Validate_Override_Flag: ' || '>>>>>>>>>> Invalid Value for the Override Remit Account Flag');
      	   	   arp_util.debug('Validate_Override_Flag: ' || 'Override remit account flag : ' || p_override_remit_account_flag);
      	   	END IF;
      	   	FND_MESSAGE.SET_NAME  ('AR', 'AR_PROCEDURE_VALID_ARGS_FAIL');
		FND_MESSAGE.SET_TOKEN ('PARAMETER', 'Override Remittance Flag');
		FND_MESSAGE.SET_TOKEN ('PROCEDURE', 'BR CREATION API');
	   	app_exception.raise_exception;
	END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_Override_Flag ()-');
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_VAL_PVT.Validate_Override_Flag () ');
		   arp_util.debug('Validate_Override_Flag: ' || '           p_override_remit_account_flag   = ' || p_override_remit_account_flag);
		END IF;
		app_exception.raise_exception;

END Validate_Override_Flag;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_Batch_ID			                                     	|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Validates the Batch Identifier and the status				|
 |                                                                           	|
 +==============================================================================*/

PROCEDURE Validate_Batch_ID    (p_batch_id IN  NUMBER) IS


l_batch_id_valid	VARCHAR2(1);

BEGIN
   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_Batch_ID ()+');
   	END IF;

	IF  (p_batch_id IS NOT NULL)
	THEN
		SELECT 	'Y'
		INTO	l_batch_id_valid
		FROM 	RA_BATCHES
		WHERE	batch_id	=	p_batch_id
		AND	status		=	'A';
	END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_Batch_ID ()-');
	END IF;

EXCEPTION
    	WHEN NO_DATA_FOUND THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_VAL_PVT.Validate_Batch_ID () ');
      	   	   arp_util.debug('Validate_Batch_ID: ' || '>>>>>>>>>> Invalid Batch ID');
 	   	   arp_util.debug('Validate_Batch_ID: ' || '           p_batch_id   = ' || p_batch_id);
 	   	END IF;
	   	FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_INVALID_BATCH_ID');
	   	app_exception.raise_exception;

	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_VAL_PVT.Validate_Batch_ID () ');
		   arp_util.debug('Validate_Batch_ID: ' || '           p_batch_id   = ' || p_batch_id);
		END IF;
		RAISE;

END Validate_Batch_ID;



/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_Customer_Trx_ID			                               	|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Validates the BR Identifier						|
 |                                                                           	|
 +==============================================================================*/

PROCEDURE Validate_Customer_Trx_ID    ( p_customer_trx_id	IN  NUMBER) IS


l_customer_trx_id_valid		VARCHAR2(1);

BEGIN
   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_Customer_Trx_ID ()+');
   	END IF;

	SELECT 	'Y'
	INTO	l_customer_trx_id_valid
	FROM 	RA_CUSTOMER_TRX
	WHERE	customer_trx_id	 =  p_customer_trx_id;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_Customer_Trx_ID ()-');
	END IF;

EXCEPTION
    	WHEN NO_DATA_FOUND THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_VAL_PVT.Validate_Customer_Trx_ID () ');
      	   	   arp_util.debug('Validate_Customer_Trx_ID: ' || '>>>>>>>>>> Invalid BR ID');
 	   	   arp_util.debug('Validate_Customer_Trx_ID: ' || '           Customer Trx ID  : ' || p_customer_trx_id);
 	   	END IF;
	   	FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_INVALID_BR_ID');
	   	app_exception.raise_exception;

	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_VAL_PVT.Validate_Customer_Trx_ID () ');
		   arp_util.debug('Validate_Customer_Trx_ID: ' || '           p_customer_trx_id   = ' || p_customer_trx_id);
		END IF;
		RAISE;

END Validate_Customer_Trx_ID;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_Customer_Trx_Line_ID			                        |
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Validates the BR Line Identifier						|
 |                                                                           	|
 +==============================================================================*/

PROCEDURE Validate_Customer_Trx_Line_ID    ( p_customer_trx_line_id	IN  NUMBER) IS


l_valid		VARCHAR2(1);

BEGIN
   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_Customer_Trx_Line_ID ()+');
   	END IF;

	SELECT 	'Y'
	INTO	l_valid
	FROM 	RA_CUSTOMER_TRX_LINES
	WHERE	customer_trx_line_id	 =  p_customer_trx_line_id;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_Customer_Trx_Line_ID ()-');
	END IF;

EXCEPTION
    	WHEN NO_DATA_FOUND THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_VAL_PVT.Validate_Customer_Trx_Line_ID () ');
      	   	   arp_util.debug('Validate_Customer_Trx_Line_ID: ' || '>>>>>>>>>> Invalid BR Assignment ID');
 	   	   arp_util.debug('Validate_Customer_Trx_Line_ID: ' || '           p_customer_trx_line_id   = ' || p_customer_trx_line_id);
 	   	END IF;
	   	FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_INVALID_ASSIGNMENT_ID');
	   	app_exception.raise_exception;

	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_VAL_PVT.Validate_Customer_Trx_Line_ID () ');
		   arp_util.debug('Validate_Customer_Trx_Line_ID: ' || '           p_customer_trx_line_id   = ' || p_customer_trx_line_id);
		END IF;
		RAISE;

END Validate_Customer_Trx_Line_ID;



/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_Create_BR_Header			                                |
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Validates the BR Header Information before insertion		     	|
 |                                                                           	|
 +==============================================================================*/


PROCEDURE  Validate_Create_BR_Header  (
		p_trx_rec		IN	ra_customer_trx%ROWTYPE	,
		p_gl_date		IN	DATE			)
IS

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_Create_BR_Header ()+');
	END IF;


    --  Validate GL Date

	Validate_GL_Date (p_gl_date);



    --  Validate Batch Source

	Validate_Batch_Source (p_trx_rec.batch_source_id, p_trx_rec.trx_date);


    --  Validate Transaction Type

	Validate_Transaction_Type (p_trx_rec.cust_trx_type_id, p_trx_rec.trx_date);


    --  Validate Drawee ID

	Validate_Drawee (p_trx_rec.drawee_id);

    --  Validate Drawee Location

	Validate_Drawee_Location (p_trx_rec.drawee_site_use_id);

    --  Validate Drawee Contact

	Validate_Drawee_Contact (p_trx_rec.drawee_contact_id, p_trx_rec.drawee_id);


    --  Validate Currency

	Validate_Currency (p_trx_rec.invoice_currency_code, p_trx_rec.trx_date);


    --  Validate Printing Option

	Validate_Printing_Option (p_trx_rec.printing_option, p_trx_rec.cust_trx_type_id);


    --  Validate Remittance Bank Account Id

	Validate_Remit_Account (
		p_trx_rec.remit_bank_acct_use_id	,
		p_trx_rec.invoice_currency_code		,
		p_trx_rec.trx_date			);


    --  Validate the Override Remit Account Flag

	Validate_Override_Flag (p_trx_rec.override_remit_account_flag);


    --  Validate the Batch ID

	Validate_Batch_ID (p_trx_rec.batch_id);

 	IF PG_DEBUG in ('Y', 'C') THEN
 	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_Create_BR_Header ()-');
 	END IF;

EXCEPTION
	WHEN Others THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_VAL_PVT.Validate_Create_BR_Header () ');
		END IF;
		RAISE;

END Validate_Create_BR_Header;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_Update_BR_Header			                                |
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Validates the BR Header Information before update			     	|
 |                                                                           	|
 +==============================================================================*/


PROCEDURE  Validate_Update_BR_Header  (
		p_trx_rec			IN	ra_customer_trx%ROWTYPE	,
		p_gl_date			IN	DATE			)

IS

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_Update_BR_Header ()+');
	END IF;

    --  Validate GL Date

	Validate_GL_Date (p_gl_date);


    --	Validate Update of Maturity_Date

	Validate_Update_Maturity_Date  (p_trx_rec.customer_trx_id	,
				 	p_trx_rec.term_due_date		);


    --  Validate Transaction Type

	Validate_Transaction_Type (p_trx_rec.cust_trx_type_id, p_trx_rec.trx_date);


    --  Validate Drawee ID

	Validate_Drawee (p_trx_rec.drawee_id);


    --  Validate Drawee Location

	Validate_Drawee_Location (p_trx_rec.drawee_site_use_id);


    --  Validate Drawee Contact

	Validate_Drawee_Contact (p_trx_rec.drawee_contact_id, p_trx_rec.drawee_id);


    --  Validate Currency

	Validate_Currency (p_trx_rec.invoice_currency_code, p_trx_rec.trx_date);


    --  Validate Printing Option

	Validate_Printing_Option (p_trx_rec.printing_option	,
				  p_trx_rec.cust_trx_type_id	);


    --  Validate Remittance Bank Account Id

	Validate_Remit_Account (
		p_trx_rec.remit_bank_acct_use_id	,
		p_trx_rec.invoice_currency_code		,
		p_trx_rec.trx_date			);


    --  Validate the Override Remit Account Flag

	Validate_Override_Flag (p_trx_rec.override_remit_account_flag);

  	IF PG_DEBUG in ('Y', 'C') THEN
  	   arp_util.debug('Validate_Update_BR_Header: ' || 'AR_BILLS_CREATION_VAL_PVT.Validate_BR_Update_Header ()-');
  	END IF;


EXCEPTION
	WHEN Others THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_VAL_PVT.Validate_Update_BR_Header () ');
		END IF;
		RAISE;

END Validate_Update_BR_Header;



/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_Assigned_Amount		                                     	|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    -  Validates that the transaction is not exchanged for more than its full |
 |       amount 								|
 |    -  Calculates the accounted assigned amount				|
 |                                                                           	|
 +==============================================================================*/

PROCEDURE Validate_Assigned_Amount  ( p_trl_rec		IN  OUT NOCOPY	ra_customer_trx_lines%ROWTYPE	,
				      p_ps_rec		IN  	ar_payment_schedules%ROWTYPE	) IS


l_exchange_rate			NUMBER;
l_functional_currency		VARCHAR2(15);
l_acctd_amount			NUMBER;
l_new_ADR			NUMBER;
l_new_acctd_ADR			NUMBER;
l_ADR				NUMBER;
l_acctd_ADR			NUMBER;



BEGIN
   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_Assigned_Amount ()+');
	   arp_util.debug ('Validate_Assigned_Amount: ' || 'Exchange rate              : ' || p_ps_rec.exchange_rate);
	   arp_util.debug ('Validate_Assigned_Amount: ' || 'Amount Due Remaining 	    : ' || p_ps_rec.amount_due_remaining);
	   arp_util.debug ('Validate_Assigned_Amount: ' || 'Acctd Amount Due Remaining : ' || p_ps_rec.acctd_amount_due_remaining);
	END IF;


	IF	(p_trl_rec.extended_amount = 0)
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('Validate_Assigned_Amount: ' || '>>>>>>>>>> The amount of the assignment must not be null');
      	   	   arp_util.debug('Validate_Assigned_Amount: ' || '           Amount Assigned      : ' || p_trl_rec.extended_amount);
      	   	END IF;
      	   	FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_INVALID_AMOUNT');
	   	app_exception.raise_exception;
	END IF;


	/*----------------------------------------------+
      	|  Validate that the transaction is not 	|
	|  exchanged for more than its remaining amount	|
        +-----------------------------------------------*/

	IF   ABS(p_trl_rec.extended_amount)  >  ABS(p_ps_rec.amount_due_remaining)
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('Validate_Assigned_Amount: ' || '>>>>>>>>>> Amount Exchanged Exceed PS');
		   arp_util.debug('Validate_Assigned_Amount: ' || '>>>>>>>>>> OverApplication not allowed');
      	   	   arp_util.debug('Validate_Assigned_Amount: ' || '           Amount Assigned      : ' || p_trl_rec.extended_amount);
		   arp_util.debug('Validate_Assigned_Amount: ' || '           Amount Remaining     : ' || p_ps_rec.amount_due_remaining);
		END IF;
      	   	FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_OVERAPPLY');
		FND_MESSAGE.SET_TOKEN ('TRXNUM', p_ps_rec.trx_number);
	   	app_exception.raise_exception;
	END IF;


	/*----------------------------------------------+
      	|  Calculate the accounted assigned amount	|
        +-----------------------------------------------*/

	l_ADR		:=	p_ps_rec.amount_due_remaining;
	l_acctd_ADR	:=	p_ps_rec.acctd_amount_due_remaining;

	arp_util.calc_acctd_amount(
		NULL,
		NULL,
		NULL,
              	nvl(p_ps_rec.exchange_rate,1)		,
              	'-'					,   	/** ADR will be reduced by amount_applied */
              	l_ADR					,       /* Current ADR */
              	l_acctd_ADR				,  	/* Current Acctd. ADR */
              	p_trl_rec.extended_amount		,       /* Assignment Amount */
              	l_new_ADR				,       /* New ADR */
              	l_new_acctd_ADR				,  	/* New Acctd. ADR */
              	p_trl_rec.extended_acctd_amount		);      /* Acct. amount_applied */

		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('Validate_Assigned_Amount: ' || 'Amount_applied		: ' || p_trl_rec.extended_amount);
		   arp_util.debug('Validate_Assigned_Amount: ' || 'Acctd Amount Applied    : ' || p_trl_rec.extended_acctd_amount);
   	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_Assigned_Amount ()-');
   	END IF;

EXCEPTION
    	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_VAL_PVT.Validate_Assigned_Amount () ');
		END IF;
		RAISE;

END Validate_Assigned_Amount;




/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Is_Transaction_BR 			                               	|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Check if the transaction type has a type 'BR'				|
 |                                                                           	|
 +==============================================================================*/

FUNCTION Is_Transaction_BR  (p_cust_trx_type_id	IN  NUMBER) RETURN BOOLEAN IS

l_type		VARCHAR2(20);

BEGIN
   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Is_Transaction_BR ()+');
   	END IF;

	SELECT 	type
	INTO	l_type
	FROM 	RA_CUST_TRX_TYPES
	WHERE	cust_trx_type_id	=  p_cust_trx_type_id;

	IF  	(l_type = 'BR')
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug ('Is_Transaction_BR: ' || 'The transaction to be exchanged is a BR');
		END IF;
		RETURN (TRUE);
	ELSE
		RETURN (FALSE);
	END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Is_Transaction_BR ()-');
	END IF;

EXCEPTION
    	WHEN NO_DATA_FOUND THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_VAL_PVT.Is_Transaction_BR () ');
	   	   arp_util.debug('Is_Transaction_BR: ' || '>>>>>>>>>> Invalid Transaction Type ID');
 	   	   arp_util.debug('Is_Transaction_BR: ' || '           p_cust_trx_type_id : ' || p_cust_trx_type_id);
 	   	END IF;
	   	FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_INVALID_TRX_TYPE');
		app_exception.raise_exception;

    	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : Is_Transaction_BR () ');
 	   	   arp_util.debug('Is_Transaction_BR: ' || '           p_cust_trx_type_id : ' || p_cust_trx_type_id);
 	   	END IF;
		RAISE;

END Is_Transaction_BR;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_BR_Status			                               	|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Validates the status of the BR (must be INCOMPLETE), so that insert, 	|
 |    update and delete of BR Assignments are allowed.				|
 |                                                                           	|
 +==============================================================================*/

PROCEDURE Validate_BR_Status    ( p_customer_trx_id	IN  NUMBER) IS

l_trh_rec		AR_TRANSACTION_HISTORY%ROWTYPE;


BEGIN
   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_BR_Status ()+');
   	END IF;

	--  Fetch the BR history information

	l_trh_rec.customer_trx_id	:=	p_customer_trx_id;
	ARP_TRANSACTION_HISTORY_PKG.fetch_f_trx_id (l_trh_rec);

	/*----------------------------------------------+
      	|  Check that the BR is incomplete, in order to	|
	|  allow the insert, update or delete of BR	|
	|  assignments.					|
        +-----------------------------------------------*/

	IF	(l_trh_rec.status <> C_INCOMPLETE)
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug ('Validate_BR_Status: ' || 'You cannot update the assignments when the BR has a status : ' || l_trh_rec.status);
		END IF;
		FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_ASSIGN_FORBIDDEN');
		app_exception.raise_exception;
	END IF;


	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_BR_Status ()-');
	END IF;

EXCEPTION
    	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_VAL_PVT.Validate_BR_Status () ');
 	           arp_util.debug('Validate_BR_Status: ' || '           p_customer_trx_id        = ' || p_customer_trx_id);
 	        END IF;
 	        RAISE;

END Validate_BR_Status;



/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_Assignment_Status			                        |
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Validates the status of the BR to be exchanged (UNPAID)			|
 |                                                                           	|
 +==============================================================================*/

PROCEDURE Validate_Assignment_Status    ( p_customer_trx_id	IN  	NUMBER,
					  p_trx_number		IN	ar_payment_schedules.trx_number%TYPE) IS

l_trh_rec		AR_TRANSACTION_HISTORY%ROWTYPE;
l_trx_rec		RA_CUSTOMER_TRX%ROWTYPE;

BEGIN
   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_Assignment_Status ()+');
   	END IF;

	l_trh_rec.customer_trx_id	:=	p_customer_trx_id;
	ARP_TRANSACTION_HISTORY_PKG.fetch_f_trx_id (l_trh_rec);
	ARP_CT_PKG.fetch_p (l_trx_rec, p_customer_trx_id);

	IF  (l_trh_rec.status <> C_UNPAID)
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('Validate_Assignment_Status: ' || '>>>>>>>>>> The BR to be exchanged must be Unpaid');
 		   arp_util.debug('Validate_Assignment_Status: ' || '           Status  : ' || l_trh_rec.status);
		   arp_util.debug('Validate_Assignment_Status: ' || '           Event   : ' || l_trh_rec.event);
		END IF;
		FND_MESSAGE.SET_NAME  ('AR'    , 'AR_BR_CANNOT_ASSIGN');
		FND_MESSAGE.set_token ('TRXNUM', p_trx_number);
		app_exception.raise_exception;
	END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_Assignment_Status ()-');
	END IF;

EXCEPTION
    	WHEN NO_DATA_FOUND THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : Validate_Assignment_Status () ');
	   	   arp_util.debug('Validate_Assignment_Status: ' || '>>>>>>>>>> Invalid BR ID');
 	   	   arp_util.debug('Validate_Assignment_Status: ' || '           Customer Trx ID  : ' || p_customer_trx_id);
 	   	END IF;
	   	FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_INVALID_BR_ID');
	   	app_exception.raise_exception;

    	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : Validate_Assignment_Status () ');
 	           arp_util.debug('Validate_Assignment_Status: ' || '           p_customer_trx_id        = ' || p_customer_trx_id);
		   arp_util.debug('Validate_Assignment_Status: ' || '           p_trx_number		    = ' || p_trx_number);
		END IF;
 	        RAISE;

END Validate_Assignment_Status;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_BR_Assignment			                        	|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Validates the BR Assignment Information before insertion or update    	|
 |                                                                           	|
 +==============================================================================*/


PROCEDURE  Validate_BR_Assignment  (p_trl_rec   IN OUT NOCOPY	ra_customer_trx_lines%ROWTYPE	,
				    p_ps_rec	IN	ar_payment_schedules%ROWTYPE	,
				    p_trx_rec	IN	ra_customer_trx%ROWTYPE		,
				    p_BR_rec	IN	ra_customer_trx%ROWTYPE		)
IS

l_type		VARCHAR2(20);

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_BR_Assignment ()+');
	END IF;


	/*----------------------------------------------+
      	|  Validate the status of the BR :		|
	|  must be INCOMPLETE				|
        +-----------------------------------------------*/

	Validate_BR_Status (p_trl_rec.customer_trx_id);



	SELECT 	type
	INTO	l_type
	FROM 	RA_CUST_TRX_TYPES
	WHERE	cust_trx_type_id	=  p_ps_rec.cust_trx_type_id;

	/*----------------------------------------------+
      	|  Validate that the assignment is not a 	|
	|  guarantee					|
        +-----------------------------------------------*/

	IF	(l_type = 'GUAR')
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug ('Validate_BR_Assignment: ' || '>>>>>>>>>> Guarantee cannot be exchanged for BR');
		END IF;
		FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_INVALID_TRX_TYPE');
		app_exception.raise_exception;

	ELSIF	(l_type = 'BR')
	THEN

		/*----------------------------------------------+
	      	|  If the transaction to be exchanged is a BR,	|
		|  validate the status of the BR exchanged.	|
	        +-----------------------------------------------*/

		Validate_Assignment_Status (p_trl_rec.br_ref_customer_trx_id, p_ps_rec.trx_number);

		/*----------------------------------------------+
	      	|  Only Total Exchange is allowed		|
	        +-----------------------------------------------*/

		IF	(AR_BILLS_MAINTAIN_STATUS_PUB.Is_Payment_Schedule_Reduced(p_ps_rec))
		THEN
			IF PG_DEBUG in ('Y', 'C') THEN
			   arp_util.debug ('Validate_BR_Assignment: ' || '>>>>>>>>>> The BR ' || p_trx_rec.trx_number || ' cannot be exchanged');
			   arp_util.debug ('Validate_BR_Assignment: ' || '           Only total exchange is allowed for BR');
			   arp_util.debug ('Validate_BR_Assignment: ' || '           amount_due_original    : ' || p_ps_rec.amount_due_original);
			   arp_util.debug ('Validate_BR_Assignment: ' || '           amount_due_remaining   : ' || p_ps_rec.amount_due_remaining);
			END IF;
			FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_CANNOT_ASSIGN');
			FND_MESSAGE.SET_TOKEN ('TRXNUM', p_trx_rec.trx_number);
			app_exception.raise_exception;
		END IF;


		IF	(p_trl_rec.extended_amount <> p_ps_rec.amount_due_original)
		THEN
			IF PG_DEBUG in ('Y', 'C') THEN
			   arp_util.debug ('Validate_BR_Assignment: ' || '>>>>>>>>>> The BR ' || p_trx_rec.trx_number || ' cannot be exchanged');
			   arp_util.debug ('Validate_BR_Assignment: ' || '           Only total exchange is allowed for BR');
			   arp_util.debug ('Validate_BR_Assignment: ' || '           amount assigned        : ' || p_trl_rec.extended_amount);
			   arp_util.debug ('Validate_BR_Assignment: ' || '           amount_due_original    : ' || p_ps_rec.amount_due_original);
			END IF;
			FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_CANNOT_ASSIGN');
			FND_MESSAGE.SET_TOKEN ('TRXNUM', p_trx_rec.trx_number);
			app_exception.raise_exception;
		END IF;

	END IF;


	/*----------------------------------------------+
      	|  Validate the reserved columns of the		|
	|  exchanged Payment Schedule			|
        +-----------------------------------------------*/

	IF 	AR_BILLS_MAINTAIN_STATUS_PUB.Is_BR_Reserved (p_ps_rec)
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug ('Validate_BR_Assignment: ' || 'The transaction ' || p_trx_rec.trx_number || ' is reserved, it cannot be assigned');
		END IF;
		FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_TRX_ALREADY_ASSIGN');
		FND_MESSAGE.SET_TOKEN ('TRXNUM', p_trx_rec.trx_number);
		app_exception.raise_exception;
	END IF;


	/*----------------------------------------------+
      	|  Validate The Assigned Amount, 		|
	|  overapplication is not allowed.		|
	|  And Calculate the accounted assigned amount	|
        +-----------------------------------------------*/

	Validate_Assigned_Amount (p_trl_rec, p_ps_rec);



        /*-------------------------------------------------+
         |   3553211 : Validate and default the flexfields  |
         |   for manual BR creation only                    |
         +--------------------------------------------------*/
	IF	p_BR_rec.created_from   = 'ARBRMAIN' THEN

		AR_BILLS_CREATION_LIB_PVT.Validate_Desc_Flexfield  (
			p_trl_rec.attribute_category	,
			p_trl_rec.attribute1		,
			p_trl_rec.attribute2		,
			p_trl_rec.attribute3		,
			p_trl_rec.attribute4		,
			p_trl_rec.attribute5		,
			p_trl_rec.attribute6		,
			p_trl_rec.attribute7		,
			p_trl_rec.attribute8		,
			p_trl_rec.attribute9		,
			p_trl_rec.attribute10		,
			p_trl_rec.attribute11		,
			p_trl_rec.attribute12		,
			p_trl_rec.attribute13		,
			p_trl_rec.attribute14		,
			p_trl_rec.attribute15		,
			'RA_CUSTOMER_TRX_LINES'		);

	END IF;


	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_CREATION_VAL_PVT.Validate_BR_Assignment ()-');
	END IF;


EXCEPTION
	WHEN Others THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_VAL_PVT.Validate_BR_Assignment () ');
		END IF;
		RAISE;

END Validate_BR_Assignment;



END AR_BILLS_CREATION_VAL_PVT;

/
