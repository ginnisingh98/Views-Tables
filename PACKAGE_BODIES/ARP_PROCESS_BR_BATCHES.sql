--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_BR_BATCHES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_BR_BATCHES" AS
/* $Header: ARTEBRBB.pls 120.5 2006/06/02 15:42:25 ggadhams arhmapss.pls $ */


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    Validate_GL_Date 			                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validates that GL Date :						     |
 |	-  Is in an open or future period     	    			     |
 |      -  Is equal or later than the Issue Date			     |                                                                     |
 |									     |
 +===========================================================================*/

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE Validate_GL_Date (	p_gl_date	IN  DATE,
				p_issue_date	IN  DATE)  IS
BEGIN

   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('ARP_PROCESS_BR_BATCHES.Validate_GL_Date()+');
   	END IF;

   	IF 	NOT (arp_util.is_gl_date_valid (p_gl_date))
	THEN
		FND_MESSAGE.set_name  ('AR', 'AR_INVALID_APP_GL_DATE');
		FND_MESSAGE.set_token ('GL_DATE', TO_CHAR (p_gl_date));
        	app_exception.raise_exception;
	END IF;

   	IF 	(p_gl_date <  p_issue_date)
	THEN
     	 	FND_MESSAGE.set_name  ('AR', 'AR_BR_BATCH_GL_DATE');
	 	app_exception.raise_exception;
   	END IF;

   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('ARP_PROCESS_BR_BATCHES.Validate_GL_Date()-');
   	END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION:  ARP_PROCESS_BR_BATCHES.Validate_GL_Date()');
           arp_util.debug(  '');
           arp_util.debug('------ parameters for Validate_GL_Date() -------');
           arp_util.debug(  'p_gl_date          = '|| p_gl_date);
           arp_util.debug(  'p_issue_date       = '|| p_issue_date);
        END IF;
        RAISE;

END Validate_GL_Date;



/*===========================================================================+
 | PROCEDURE                                                                 |
 |    Validate_Maturity_Date		                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validates that Maturity Date is equal or later than the Issue Date     |									     |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Validate_Maturity_Date (	p_maturity_date	IN  DATE,
					p_issue_date	IN  DATE)  IS
BEGIN

   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('ARP_PROCESS_BR_BATCHES.Validate_Maturity_Date()+');
   	END IF;

   	IF 	(p_maturity_date IS NOT NULL)
	THEN
  		IF 	(p_maturity_date <  p_issue_date)
		THEN
     			FND_MESSAGE.set_name  ('AR', 'AR_BR_MAT_BEFORE_ISSUE_DATE ');
			app_exception.raise_exception;
   		END IF;
	END IF;

   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('ARP_PROCESS_BR_BATCHES.Validate_Maturity_Date()-');
   	END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION:  ARP_PROCESS_BR_BATCHES.Validate_Maturity_Date()');
           arp_util.debug(  '');
           arp_util.debug('------ parameters for Validate_Maturity_Date() -------');
           arp_util.debug(  'p_maturity_date    = '|| p_maturity_date);
           arp_util.debug(  'p_issue_date       = '|| p_issue_date);
        END IF;
        RAISE;

END Validate_Maturity_Date;



/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_Batch_Source		                                     	|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Validates that the Batch Source :					     	|
 |	- is active			     	    			     	|
 |      - is defined as Manual						     	|
 |      - has Automatic Transaction Numbering checked  OR 		     	|
 |            Copy Doc Number to Trx Number checked			     	|
 |	- Batch Date between Start Date and End Date of the Batch Source     	|
 |      - Issue Date between Start Date and End Date of the Batch Source    	|
 |										|
 |									     	|
 +=============================================================================*/

PROCEDURE Validate_Batch_Source (	p_batch_source_id	IN  NUMBER,
					p_batch_date		IN  DATE  ,
					p_issue_date		IN  DATE  )  IS

l_start_date			DATE;
l_end_date			DATE;
l_auto_trx_numbering_flag	VARCHAR2(1);
l_copy_doc_number_flag		VARCHAR2(1);


BEGIN

   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('ARP_PROCESS_BR_BATCHES.Validate_Batch_Source()+');
   	END IF;

   	SELECT 	start_date, end_date, auto_trx_numbering_flag, copy_doc_number_flag
	INTO	l_start_date, l_end_date, l_auto_trx_numbering_flag, l_copy_doc_number_flag
   	FROM	RA_BATCH_SOURCES
   	WHERE  	batch_source_id 	=  p_batch_source_id
   	AND	nvl(status, 'A')      	=  'A'
   	AND    	batch_source_type       =  'INV';


   	IF     (l_auto_trx_numbering_flag = 'N' AND l_copy_doc_number_flag = 'N')
	THEN
	  	IF PG_DEBUG in ('Y', 'C') THEN
	  	   arp_util.debug('Validate_Batch_Source: ' || 'Invalid Source - Flags');
	  	END IF;
	  	FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_INVALID_NUMBERING_SOURCE');
	  	app_exception.raise_exception;
   	END IF;


   	IF  	(p_batch_date	NOT BETWEEN nvl(l_start_date , p_batch_date)
	      		    		AND nvl(l_end_date   , p_batch_date))
	THEN
  	  	IF PG_DEBUG in ('Y', 'C') THEN
  	  	   arp_util.debug('Validate_Batch_Source: ' || 'Invalid Source - batch date');
  	  	END IF;
	  	FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_BAD_BATCH_DATE_SOURCE');
	  	app_exception.raise_exception;
   	END IF;


   	IF     (p_issue_date NOT BETWEEN nvl(l_start_date , p_issue_date)
			 	     AND nvl(l_end_date   , p_issue_date))
	THEN
  	  	IF PG_DEBUG in ('Y', 'C') THEN
  	  	   arp_util.debug('Validate_Batch_Source: ' || 'Invalid Source - issue date');
  	  	END IF;
	  	FND_MESSAGE.SET_NAME ('AR', 'AR_BR_BAD_DATE_SOURCE');
	  	app_exception.raise_exception;
   	END IF;

   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('ARP_PROCESS_BR_BATCHES.Validate_Batch_Source()-');
   	END IF;

EXCEPTION
    WHEN   NO_DATA_FOUND THEN
	   FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_INVALID_BATCH_SOURCE');
	   app_exception.raise_exception;

    WHEN OTHERS THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_util.debug('EXCEPTION:  ARP_PROCESS_BR_BATCHES.Validate_Batch_Source()');
              arp_util.debug('Validate_Batch_Source: ' || '');
              arp_util.debug('------ parameters for Validate_Batch_Source() -------');
              arp_util.debug('Validate_Batch_Source: ' || 'p_batch_source_id          = '|| p_batch_source_id);
              arp_util.debug('Validate_Batch_Source: ' || 'p_batch_date               = '|| p_batch_date);
              arp_util.debug('Validate_Batch_Source: ' || 'p_issue_date               = '|| p_issue_date);
           END IF;
           RAISE;

END Validate_Batch_Source;



/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_Currency 		                                     	|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Validates that the Currency :					     	|
 |	- is active at the Issue Date	     	    			     	|
 |      - is enabled							     	|
 |      - belongs to a currency group			 		     	|
 |										|
 +=============================================================================*/

PROCEDURE Validate_Currency	 (	p_currency_code		IN  VARCHAR2,
					p_issue_date		IN  DATE  )  IS
l_currency_valid VARCHAR2(1);

BEGIN

   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('ARP_PROCESS_BR_BATCHES.Validate_Currency()+');
   	END IF;

  	IF  	(p_currency_code  IS NOT NULL)
	THEN

	   	SELECT  'Y'
	   	INTO	l_currency_valid
	   	FROM	FND_CURRENCIES_VL cur
	   	WHERE   CURRENCY_CODE     =	  p_currency_code
	   	AND	p_issue_date      BETWEEN  nvl(cur.START_DATE_ACTIVE, p_issue_date)
				     	      AND  nvl(cur.END_DATE_ACTIVE, p_issue_date)
	   	AND	ENABLED_FLAG  = 'Y'
	   	AND	CURRENCY_FLAG = 'Y';
   	END IF;

   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('ARP_PROCESS_BR_BATCHES.Validate_Currency()-');
   	END IF;

EXCEPTION
    WHEN   NO_DATA_FOUND THEN
	   FND_MESSAGE.SET_NAME  ('AR', 'AR_INVALID_CURRENCY');
	   app_exception.raise_exception;

    WHEN   OTHERS THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_util.debug('EXCEPTION:  ARP_PROCESS_BR_BATCHES.Validate_Currency()');
              arp_util.debug('Validate_Currency: ' || '');
              arp_util.debug('------ parameters for Validate_Currency() -------');
              arp_util.debug('Validate_Currency: ' || 'p_currency_code            = '|| p_currency_code);
              arp_util.debug('Validate_Currency: ' || 'p_issue_date               = '|| p_issue_date);
           END IF;
           RAISE;

END Validate_Currency;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_Receipt_Method		                                     	|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Validates that the Issue Date is between the Start date and End date of   |
 |    receipt method								|
 |									     	|
 +=============================================================================*/

PROCEDURE Validate_Receipt_Method (	p_receipt_method_id	IN  NUMBER,
					p_issue_date		IN  DATE  )  IS

l_receipt_method_valid	VARCHAR2(1);

BEGIN

   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('ARP_PROCESS_BR_BATCHES.Validate_Receipt_Method()+');
   	END IF;

   	IF   (p_receipt_method_id IS NOT NULL)
	THEN
   		SELECT 	'Y'
	   	INTO	l_Receipt_Method_valid
   		FROM	AR_RECEIPT_METHODS  rm
	   	WHERE  	rm.receipt_method_id = p_receipt_method_id
   		AND	p_issue_date 	BETWEEN nvl(rm.start_date , p_issue_date)
					AND	nvl(rm.end_date   , p_issue_date);
   	END IF;

   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('ARP_PROCESS_BR_BATCHES.Validate_Receipt_Method()-');
   	END IF;

EXCEPTION
    WHEN   NO_DATA_FOUND THEN
	   FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_BAD_DATE_RECEIPT_METHOD');
	   app_exception.raise_exception;

    WHEN OTHERS THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_util.debug('EXCEPTION:  ARP_PROCESS_BR_BATCHES.Validate_Receipt_Method()');
              arp_util.debug('Validate_Receipt_Method: ' || '');
              arp_util.debug('------ parameters for Validate_Receipt_Method () -------');
              arp_util.debug('Validate_Receipt_Method: ' || 'p_receipt_method_id        = '|| p_receipt_method_id);
              arp_util.debug('Validate_Receipt_Method: ' || 'p_issue_date               = '|| p_issue_date);
           END IF;
           RAISE;

END Validate_Receipt_Method;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Check_Mandatory_Data                               			|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Checks that mandatory parameters for the batch are passed	:		|
 |	-  Bacth Source								|
 |	-  Batch Date								|
 |	-  GL Date								|
 |	-  Issue Date								|
 |										|
 +==============================================================================*/


PROCEDURE Check_Mandatory_Data ( p_batch_rec  IN    ra_batches%ROWTYPE)
IS
BEGIN

	IF  	(p_batch_rec.batch_source_id IS NULL)
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('Check_Mandatory_Data: ' || 'Batch Source Missing');
		END IF;
		FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_BATCH_SOURCE_NULL');
	   	app_exception.raise_exception;
	END IF;


	IF  	(p_batch_rec.batch_date IS NULL)
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('Check_Mandatory_Data: ' || 'Batch Date Missing');
		END IF;
		FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_BATCH_DATE_NULL');
	   	app_exception.raise_exception;
	END IF;


	IF  	(p_batch_rec.gl_date IS NULL)
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('Check_Mandatory_Data: ' || 'GL Date Missing');
		END IF;
		FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_GL_DATE_NULL');
	   	app_exception.raise_exception;
	END IF;


	IF  	(p_batch_rec.issue_date IS NULL)
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('Check_Mandatory_Data: ' || 'Issue Date Missing');
		END IF;
		FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_ISSUE_DATE_NULL');
	   	app_exception.raise_exception;
	END IF;

EXCEPTION
    WHEN OTHERS THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_util.debug('EXCEPTION:  ARP_PROCESS_BR_BATCHES.Check_Mandatory_Data()');
              arp_util.debug('Check_Mandatory_Data: ' || '');
           END IF;
           RAISE;

END Check_Mandatory_Data;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_batch			                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Does validation that is required when a new batch is inserted.	     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_batch_rec					     |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-APR-2000     Tien Tran     	Created                              |
 |                                                                           |
 +===========================================================================*/


PROCEDURE validate_batch ( p_batch_rec IN ra_batches%rowtype ) IS


BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('ARP_PROCESS_BR_BATCHES.validate_batch()+');
   END IF;


   ARP_PROCESS_BR_BATCHES.Validate_GL_Date
		( 	p_batch_rec.gl_date		,
			p_batch_rec.issue_date		);

   ARP_PROCESS_BR_BATCHES.Validate_Maturity_Date
		( 	p_batch_rec.maturity_date	,
 			p_batch_rec.issue_date   	);

   ARP_PROCESS_BR_BATCHES.Validate_Batch_Source
		( 	p_batch_rec.batch_source_id	,
			p_batch_rec.batch_date		,
			p_batch_rec.issue_date		);

   ARP_PROCESS_BR_BATCHES.Validate_Currency
		( 	p_batch_rec.currency_code	,
 			p_batch_rec.issue_date   	);

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('ARP_PROCESS_BR_BATCHES.validate_batch()-');
   END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION:  arp_process_batch.validate_batch()');
           arp_util.debug('validate_batch: ' || '');
           arp_util.debug('------ parameters for validate_batch() -------');
        END IF;
        arp_tbat_pkg.display_batch_rec(p_batch_rec);
        RAISE;

END validate_batch;




/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_delete_batch		                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Does validation that is required when a batch is deleted.	     	     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_batch_id					     |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-APR-2000     Tien Tran     	Created                              |
 |                                                                           |
 +===========================================================================*/


PROCEDURE validate_delete_batch ( p_batch_id IN ra_batches.batch_id%type ) IS


BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('ARP_PROCESS_BR_BATCHES.validate_delete_batch()+');
   END IF;

   arp_process_batch.ar_empty_batch(p_batch_id);

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('ARP_PROCESS_BR_BATCHES.validate_delete_batch()-');
   END IF;


EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION:  arp_process_batch.validate_delete_batch()');
           arp_util.debug('validate_delete_batch: ' || '');
           arp_util.debug('------ parameters for validate_delete_batch() -------');
           arp_util.debug('validate_delete_batch: ' || 'p_batch_id               = '|| p_batch_id);
        END IF;
        RAISE;

END validate_delete_batch;



/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_selection		                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Does validation that is required when Selection Criteria are inserted  |
 |    or updated                                                             |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_sel_rec					     	     |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-APR-2000     Tien Tran     	Created                              |
 |                                                                           |
 +===========================================================================*/


PROCEDURE validate_selection (  p_sel_rec 	IN  ar_selection_criteria%rowtype,
			  	p_issue_date 	IN  ra_batches.issue_date%type   ) IS


BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('ARP_PROCESS_BR_BATCHES.validate_selection()+');
   END IF;

   Validate_Receipt_Method ( 	p_sel_rec.receipt_method_id, p_issue_date);

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('ARP_PROCESS_BR_BATCHES.validate_selection()-');
   END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION:  arp_process_batch.validate_selection()');
           arp_util.debug('validate_selection: ' || '');
           arp_util.debug('------ parameters for validate_selection() -------');
        END IF;
        arp_selection_criteria_pkg.display_selection_rec(p_sel_rec);
        RAISE;

END validate_selection;



/*===========================================================================+
 | FUNCTION                                                                  |
 |    Is_Selection_Entered                                     		     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function determines if Selection Criteria have been entered or not|
 |                                                                           |
 +===========================================================================*/

FUNCTION Is_Selection_Entered (p_sel_rec  IN  ar_selection_criteria%rowtype ) RETURN BOOLEAN IS
BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('ARP_PROCESS_BR_BATCHES.Is_Selection_Entered()');
   END IF;

   	IF 	(p_sel_rec.due_date_low  	 	IS NULL)	AND
   		(p_sel_rec.due_date_high 	 	IS NULL)	AND
   		(p_sel_rec.trx_date_low		 	IS NULL)	AND
   		(p_sel_rec.trx_date_high	 	IS NULL)	AND
   		(p_sel_rec.cust_trx_type_id	 	IS NULL)	AND
   		(p_sel_rec.receipt_method_id	 	IS NULL)	AND
   		(p_sel_rec.bank_branch_id	 	IS NULL)	AND
   		(p_sel_rec.trx_number_low	 	IS NULL)	AND
   		(p_sel_rec.trx_number_high	 	IS NULL)	AND
   		(p_sel_rec.customer_class_code	 	IS NULL)	AND
  		(p_sel_rec.customer_category_code 	IS NULL)	AND
   		(p_sel_rec.customer_id		 	IS NULL)	AND
   		(p_sel_rec.site_use_id		 	IS NULL)
   	THEN
		return(false);
   	ELSE
		return(true);
   	END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION:  arp_process_batches.Is_Selection_Entered ()');
           arp_util.debug('Is_Selection_Entered: ' || '');
           arp_util.debug('Is_Selection_Entered: ' || '------ parameters for validate_selection() -------');
        END IF;
        arp_selection_criteria_pkg.display_selection_rec(p_sel_rec);
        RAISE;

END Is_Selection_Entered;



/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_batch                                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Cover for calling the batch entity handler insert_batch                |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_form_name                                            |
 |                    p_form_version                                         |
 |                    p_batch_source_id                                      |
 |                    p_batch_date                                           |
 |                    p_gl_date                                              |
 |                    p_type                                                 |
 |                    p_currency_code                                        |
 |                    p_comments                                             |
 |                    p_attribute_category                                   |
 |                    p_attribute1 - 15                                      |
 |                    p_issue_date					     |
 |                    p_maturity_date                                        |
 |                    p_special_instructions                                 |
 |                    p_batch_process_status                                 |
 |		      p_due_date_low					     |
 |		      p_due_date_high				  	     |
 |		      p_trx_date_low					     |
 |		      p_trx_date_high					     |
 |		      p_cust_trx_type_id				     |
 |		      p_receipt_method_id				     |
 |		      p_bank_branch_id			  	     	     |
 |		      p_trx_number_low				     	     |
 |		      p_trx_number_high				     	     |
 |		      p_customer_class_code				     |
 |		      p_customer_category_code		  	             |
 |		      p_customer_id					     |
 |		      p_site_use_id		 			     |
 |              OUT:                                                         |
 |                    p_batch_id    					     |
 |		      p_selection_criteria_id                                |
 |          IN  OUT:                                                         |
 |                    p_name                                                 |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-APR-2000     Tien Tran     	Created                              |
 |                                                                           |
 +===========================================================================*/

PROCEDURE insert_batch (
	p_form_name              	IN  	varchar2				,
	p_form_version           	IN  	number					,
	p_batch_source_id        	IN  	ra_batches.batch_source_id%TYPE		,
	p_batch_date             	IN  	ra_batches.batch_date%TYPE		,
	p_gl_date                	IN  	ra_batches.gl_date%TYPE			,
	p_TYPE                   	IN  	ra_batches.TYPE%TYPE			,
  	p_currency_code          	IN  	ra_batches.currency_code%TYPE		,
  	p_comments               	IN  	ra_batches.comments%TYPE		,
  	p_attribute_category     	IN  	ra_batches.attribute_category%TYPE	,
	p_attribute1             	IN  	ra_batches.attribute1%TYPE		,
 	p_attribute2             	IN  	ra_batches.attribute2%TYPE		,
  	p_attribute3             	IN  	ra_batches.attribute3%TYPE		,
  	p_attribute4             	IN  	ra_batches.attribute4%TYPE		,
  	p_attribute5             	IN  	ra_batches.attribute5%TYPE		,
  	p_attribute6             	IN  	ra_batches.attribute6%TYPE		,
  	p_attribute7             	IN  	ra_batches.attribute7%TYPE		,
  	p_attribute8            	IN  	ra_batches.attribute8%TYPE		,
  	p_attribute9            	IN  	ra_batches.attribute9%TYPE		,
  	p_attribute10            	IN  	ra_batches.attribute10%TYPE		,
  	p_attribute11            	IN  	ra_batches.attribute11%TYPE		,
  	p_attribute12            	IN  	ra_batches.attribute12%TYPE		,
  	p_attribute13            	IN  	ra_batches.attribute13%TYPE		,
  	p_attribute14            	IN  	ra_batches.attribute14%TYPE		,
  	p_attribute15            	IN  	ra_batches.attribute15%TYPE		,
  	p_issue_date		   	IN  	ra_batches.issue_date%TYPE		,
  	p_maturity_date   	   	IN  	ra_batches.maturity_date%TYPE		,
  	p_special_instructions   	IN  	ra_batches.special_instructions%TYPE	,
  	p_batch_process_status   	IN  	ra_batches.batch_process_status%TYPE	,
  	p_due_date_low  	   	IN  	ar_selection_criteria.due_date_low%TYPE	,
  	p_due_date_high	   		IN  	ar_selection_criteria.due_date_high%TYPE,
  	p_trx_date_low	   		IN  	ar_selection_criteria.trx_date_low%TYPE	,
  	p_trx_date_high	   		IN  	ar_selection_criteria.trx_date_high%TYPE,
  	p_cust_trx_TYPE_id	   	IN  	ar_selection_criteria.cust_trx_TYPE_id%TYPE	,
  	p_receipt_method_id	   	IN  	ar_selection_criteria.receipt_method_id%TYPE	,
  	p_bank_branch_id	   	IN  	ar_selection_criteria.bank_branch_id%TYPE	,
  	p_trx_number_low	   	IN  	ar_selection_criteria.trx_number_low%TYPE	,
  	p_trx_number_high	   	IN  	ar_selection_criteria.trx_number_high%TYPE	,
  	p_customer_class_code	   	IN  	ar_selection_criteria.customer_class_code%TYPE	,
  	p_customer_category_code 	IN  	ar_selection_criteria.customer_category_code%TYPE,
  	p_customer_id		   	IN  	ar_selection_criteria.customer_id%TYPE	,
  	p_site_use_id		   	IN 	ar_selection_criteria.site_use_id%TYPE	,
  	p_selection_criteria_id  	OUT NOCOPY 	ra_batches.selection_criteria_id%TYPE	,
  	p_batch_id               	OUT NOCOPY 	ra_batches.batch_id%TYPE		,
  	p_name               	   	IN OUT NOCOPY 	ra_batches.name%TYPE			)

IS
  	l_batch_rec     ra_batches%rowtype		;
  	l_batch_id      ra_batches.batch_id%type	;
  	l_name          ra_batches.name%type		;
  	l_sel_rec       ar_selection_criteria%rowtype	;
  	l_sel_id	ar_selection_criteria.selection_criteria_id%type;

BEGIN

   	arp_util.debug('arp_process_br_batch.insert_batch()+');

     	/*-------------------------------------------------------------+
	|  Check the form version to determine if it is compatible     |
     	|  with the entity handler                                     |
     	+-------------------------------------------------------------*/

    	arp_trx_validate.ar_entity_version_check (p_form_name, p_form_version);

   	/*----------------------------------------------------------------+
    	|                 Batch Information                              |
    	+----------------------------------------------------------------*/

    	l_batch_rec.batch_source_id      	:= 	p_batch_source_id	;
    	l_batch_rec.batch_date           	:= 	p_batch_date		;
    	l_batch_rec.gl_date              	:= 	p_gl_date		;
    	l_batch_rec.type                 	:= 	p_type			;
    	l_batch_rec.currency_code        	:= 	p_currency_code		;
    	l_batch_rec.comments             	:= 	p_comments		;
    	l_batch_rec.attribute_category   	:= 	p_attribute_category	;
    	l_batch_rec.attribute1           	:= 	p_attribute1		;
    	l_batch_rec.attribute2           	:= 	p_attribute2		;
    	l_batch_rec.attribute3           	:= 	p_attribute3		;
    	l_batch_rec.attribute4           	:= 	p_attribute4		;
    	l_batch_rec.attribute5           	:= 	p_attribute5		;
    	l_batch_rec.attribute6           	:= 	p_attribute6		;
    	l_batch_rec.attribute7           	:= 	p_attribute7		;
    	l_batch_rec.attribute8           	:= 	p_attribute8		;
    	l_batch_rec.attribute9           	:= 	p_attribute9		;
    	l_batch_rec.attribute10          	:= 	p_attribute10		;
    	l_batch_rec.attribute11          	:= 	p_attribute11		;
    	l_batch_rec.attribute12          	:= 	p_attribute12		;
    	l_batch_rec.attribute13          	:= 	p_attribute13		;
    	l_batch_rec.attribute14          	:= 	p_attribute14		;
    	l_batch_rec.attribute15          	:= 	p_attribute15		;
    	l_batch_rec.issue_date	     		:= 	p_issue_date		;
    	l_batch_rec.maturity_date        	:= 	p_maturity_date		;
   	l_batch_rec.special_instructions 	:= 	p_special_instructions	;
    	l_batch_rec.batch_process_status 	:= 	p_batch_process_status	;
    	l_batch_rec.selection_criteria_id  	:= 	null			;
    	l_batch_rec.name                 	:= 	p_name			;

	l_batch_rec.status			:=	'A'			;

    	check_mandatory_data (l_batch_rec);


     	/*-------------------------------------------------------------+
     	|  Do required validation for the batch                        |
     	+-------------------------------------------------------------*/

       	ARP_PROCESS_BR_BATCHES.validate_batch (l_batch_rec);


     	/*---------------------------------------------------------------+
     	|  Call Table Handler to insert the batch                        |
     	+---------------------------------------------------------------*/

    	arp_tbat_pkg.insert_p (l_batch_rec, p_batch_id, p_name);


     	/*---------------------------------------------------------------+
     	|                 Selection Criteria Information                 |
     	+---------------------------------------------------------------*/

     	l_sel_rec.due_date_low			:= 	p_due_date_low		;
     	l_sel_rec.due_date_high			:= 	p_due_date_high		;
     	l_sel_rec.trx_date_low			:= 	p_trx_date_low		;
     	l_sel_rec.trx_date_high			:= 	p_trx_date_high		;
     	l_sel_rec.cust_trx_type_id		:= 	p_cust_trx_type_id	;
     	l_sel_rec.receipt_method_id		:= 	p_receipt_method_id	;
     	l_sel_rec.bank_branch_id		:= 	p_bank_branch_id	;
     	l_sel_rec.trx_number_low		:= 	p_trx_number_low	;
     	l_sel_rec.trx_number_high		:= 	p_trx_number_high	;
     	l_sel_rec.customer_class_code		:= 	p_customer_class_code	;
     	l_sel_rec.customer_category_code	:= 	p_customer_category_code;
    	l_sel_rec.customer_id			:= 	p_customer_id		;
     	l_sel_rec.site_use_id			:= 	p_site_use_id		;

    	p_selection_criteria_id			:= 	NULL			;


	IF  (Is_Selection_Entered (l_sel_rec)) THEN

		/*-------------------------------------------------------------+
       		|  Do required validation for the selection criteria           |
       		+-------------------------------------------------------------*/

		ARP_PROCESS_BR_BATCHES.validate_selection (l_sel_rec, p_issue_date);


		/*-------------------------------------------------------------+
     		|  Call Table Handler to insert the selection                  |
     		+-------------------------------------------------------------*/

     		arp_selection_criteria_pkg.insert_p (l_sel_rec, p_selection_criteria_id);


     		/*-------------------------------------------------------------+
     		|  Update the Batch information with the Selection Criteria ID |
     		+-------------------------------------------------------------*/

		UPDATE  RA_BATCHES
		SET	selection_criteria_id = p_selection_criteria_id
		WHERE	batch_id = p_batch_id;


     	END IF;

     	arp_util.debug('ARP_PROCESS_BR_BATCHES.insert_batch()-');

EXCEPTION
  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION : ARP_PROCESS_BR_BATCHES.insert_batch');
    arp_util.debug('p_batch_source_id       : ' || p_batch_source_id);
    arp_util.debug('p_batch_date            : ' || p_batch_date);
    arp_util.debug('p_gl_date               : ' || p_gl_date);
    arp_util.debug('p_type                  : ' || p_type);
    arp_util.debug('p_currency_code         : ' || p_currency_code);
    arp_util.debug('p_comments              : ' || p_comments);
    arp_util.debug('p_attribute_category    : ' || p_attribute_category);
    arp_util.debug('p_attribute1            : ' || p_attribute1);
    arp_util.debug('p_attribute2            : ' || p_attribute2);
    arp_util.debug('p_attribute3            : ' || p_attribute3);
    arp_util.debug('p_attribute4            : ' || p_attribute4);
    arp_util.debug('p_attribute5            : ' || p_attribute5);
    arp_util.debug('p_attribute6            : ' || p_attribute6);
    arp_util.debug('p_attribute7            : ' || p_attribute7);
    arp_util.debug('p_attribute8            : ' || p_attribute8);
    arp_util.debug('p_attribute9            : ' || p_attribute9);
    arp_util.debug('p_attribute10           : ' || p_attribute10);
    arp_util.debug('p_attribute11           : ' || p_attribute11);
    arp_util.debug('p_attribute12           : ' || p_attribute12);
    arp_util.debug('p_attribute13           : ' || p_attribute13);
    arp_util.debug('p_attribute14           : ' || p_attribute14);
    arp_util.debug('p_attribute15           : ' || p_attribute15);
    arp_util.debug('p_issue_date            : ' || p_issue_date);
    arp_util.debug('p_maturity_date         : ' || p_maturity_date);
    arp_util.debug('p_special_instructions  : ' || p_special_instructions);
    arp_util.debug('p_batch_process_status  : ' || p_batch_process_status);
    arp_util.debug('p_name                  : ' || p_name);
    arp_util.debug('p_selection_criteria_id : ' || p_selection_criteria_id);
    arp_util.debug('p_due_date_low          : ' || p_due_date_low);
    arp_util.debug('p_due_date_high         : ' || p_due_date_high);
    arp_util.debug('p_trx_date_low          : ' || p_trx_date_low);
    arp_util.debug('p_trx_date_high         : ' || p_trx_date_high);
    arp_util.debug('p_cust_trx_type_id      : ' || p_cust_trx_type_id);
    arp_util.debug('p_receipt_method_id     : ' || p_receipt_method_id);
    arp_util.debug('p_bank_branch_id        : ' || p_bank_branch_id);
    arp_util.debug('p_trx_number_low        : ' || p_trx_number_low);
    arp_util.debug('p_trx_number_high       : ' || p_trx_number_high);
    arp_util.debug('p_customer_class_code   : ' || p_customer_class_code);
    arp_util.debug('p_customer_category_code: ' || p_customer_category_code);
    arp_util.debug('p_customer_id	    : ' || p_customer_id);
    arp_util.debug('p_site_use_id           : ' || p_site_use_id);
    RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_batch                                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Call the table handlers of RA_BATCHES and AR_SELECTION_CRITERIA        |
 |    to update BR Batch information                                         |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_form_name                                            |
 |                    p_form_version                                         |
 |		      p_batch_id					     |
 |                    p_name                                                 |
 |                    p_batch_source_id                                      |
 |                    p_batch_date                                           |
 |                    p_gl_date                                              |
 |                    p_type                                                 |
 |                    p_currency_code                                        |
 |                    p_comments                                             |
 |                    p_attribute_category                                   |
 |                    p_attribute1 - 15                                      |
 |                    p_issue_date					     |
 |                    p_maturity_date                                        |
 |                    p_special_instructions                                 |
 |                    p_batch_process_status                                 |
 |		      p_due_date_low					     |
 |		      p_due_date_high				  	     |
 |		      p_trx_date_low					     |
 |		      p_trx_date_high					     |
 |		      p_cust_trx_type_id				     |
 |		      p_receipt_method_id				     |
 |		      p_bank_branch_id			  	     	     |
 |		      p_trx_number_low				     	     |
 |		      p_trx_number_high				     	     |
 |		      p_customer_class_code				     |
 |		      p_customer_category_code		  	             |
 |		      p_customer_id					     |
 |		      p_site_use_id		 			     |
 |      								     |
 |              IN OUT NOCOPY :						     |
 |		      p_selection_criteria_id				     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-APR-2000     Tien Tran     	Created                              |
 |                                                                           |
 +===========================================================================*/

PROCEDURE update_batch (
  	p_form_name              	IN  	varchar2				,
	p_form_version           	IN  	number					,
  	p_batch_id               	IN  	ra_batches.batch_id%TYPE		,
  	p_name                 	  	IN  	ra_batches.name%TYPE			,
  	p_batch_source_id        	IN  	ra_batches.batch_source_id%TYPE		,
  	p_batch_date             	IN  	ra_batches.batch_date%TYPE		,
  	p_gl_date                	IN  	ra_batches.gl_date%TYPE			,
  	p_TYPE                   	IN  	ra_batches.TYPE%TYPE			,
  	p_currency_code          	IN  	ra_batches.currency_code%TYPE		,
  	p_comments               	IN  	ra_batches.comments%TYPE		,
  	p_attribute_category     	IN  	ra_batches.attribute_category%TYPE	,
  	p_attribute1             	IN  	ra_batches.attribute1%TYPE		,
  	p_attribute2             	IN  	ra_batches.attribute2%TYPE		,
  	p_attribute3             	IN  	ra_batches.attribute3%TYPE		,
  	p_attribute4            	IN  	ra_batches.attribute4%TYPE		,
  	p_attribute5             	IN 	ra_batches.attribute5%TYPE		,
  	p_attribute6             	IN  	ra_batches.attribute6%TYPE		,
  	p_attribute7             	IN  	ra_batches.attribute7%TYPE		,
  	p_attribute8             	IN  	ra_batches.attribute8%TYPE		,
  	p_attribute9             	IN  	ra_batches.attribute9%TYPE		,
  	p_attribute10            	IN  	ra_batches.attribute10%TYPE		,
  	p_attribute11            	IN  	ra_batches.attribute11%TYPE		,
  	p_attribute12            	IN  	ra_batches.attribute12%TYPE		,
  	p_attribute13            	IN  	ra_batches.attribute13%TYPE		,
  	p_attribute14            	IN  	ra_batches.attribute14%TYPE		,
  	p_attribute15            	IN  	ra_batches.attribute15%TYPE		,
  	p_issue_date		   	IN  	ra_batches.issue_date%TYPE		,
  	p_maturity_date   	   	IN  	ra_batches.maturity_date%TYPE		,
  	p_special_instructions   	IN  	ra_batches.special_instructions%TYPE	,
  	p_batch_process_status   	IN  	ra_batches.batch_process_status%TYPE	,
  	p_request_id		   	IN  	ra_batches.request_id%TYPE		,
  	p_due_date_low  	   	IN  	ar_selection_criteria.due_date_low%TYPE	,
  	p_due_date_high	   		IN  	ar_selection_criteria.due_date_high%TYPE,
  	p_trx_date_low	   		IN  	ar_selection_criteria.trx_date_low%TYPE	,
  	p_trx_date_high	   		IN  	ar_selection_criteria.trx_date_high%TYPE,
  	p_cust_trx_TYPE_id	   	IN  	ar_selection_criteria.cust_trx_TYPE_id%TYPE	,
  	p_receipt_method_id	   	IN  	ar_selection_criteria.receipt_method_id%TYPE	,
  	p_bank_branch_id	   	IN  	ar_selection_criteria.bank_branch_id%TYPE	,
  	p_trx_number_low	   	IN  	ar_selection_criteria.trx_number_low%TYPE	,
  	p_trx_number_high	   	IN  	ar_selection_criteria.trx_number_high%TYPE	,
  	p_customer_class_code	   	IN  	ar_selection_criteria.customer_class_code%TYPE	,
  	p_customer_category_code 	IN  	ar_selection_criteria.customer_category_code%TYPE,
  	p_customer_id		   	IN  	ar_selection_criteria.customer_id%TYPE	,
  	p_site_use_id		   	IN  	ar_selection_criteria.site_use_id%TYPE	,
  	p_selection_criteria_id  	IN  OUT NOCOPY ar_selection_criteria.selection_criteria_id%TYPE)

IS
  l_batch_rec     ra_batches%rowtype;
  l_sel_rec       ar_selection_criteria%rowtype;


BEGIN
    	IF PG_DEBUG in ('Y', 'C') THEN
    	   arp_util.debug('ARP_PROCESS_BR_BATCHES.update_batch()+');
    	END IF;


     	/*-------------------------------------------------------------+
     	|  Check the form version to determine if it is compatible     |
     	|  with the entity handler                                     |
     	+-------------------------------------------------------------*/

    	arp_trx_validate.ar_entity_version_check (p_form_name, p_form_version);


   	/*----------------------------------------------------------------+
    	|                 Batch Information                              |
    	+----------------------------------------------------------------*/

    	arp_tbat_pkg.set_to_dummy(l_batch_rec);

    	l_batch_rec.batch_id			:=  	p_batch_id		;
    	l_batch_rec.name			:=  	p_name			;
    	l_batch_rec.batch_source_id      	:=  	p_batch_source_id	;
    	l_batch_rec.batch_date           	:=  	p_batch_date		;
    	l_batch_rec.gl_date              	:=  	p_gl_date		;
    	l_batch_rec.type                 	:=  	p_type			;
    	l_batch_rec.currency_code        	:=  	p_currency_code		;
    	l_batch_rec.comments             	:=  	p_comments		;
    	l_batch_rec.attribute_category   	:=  	p_attribute_category	;
    	l_batch_rec.attribute1           	:=  	p_attribute1		;
    	l_batch_rec.attribute2           	:=  	p_attribute2		;
   	l_batch_rec.attribute3           	:=  	p_attribute3		;
    	l_batch_rec.attribute4           	:=  	p_attribute4		;
    	l_batch_rec.attribute5           	:=  	p_attribute5		;
    	l_batch_rec.attribute6           	:=  	p_attribute6		;
    	l_batch_rec.attribute7           	:=  	p_attribute7		;
    	l_batch_rec.attribute8           	:=  	p_attribute8		;
    	l_batch_rec.attribute9           	:=  	p_attribute9		;
    	l_batch_rec.attribute10          	:=  	p_attribute10		;
    	l_batch_rec.attribute11          	:=  	p_attribute11		;
    	l_batch_rec.attribute12          	:=  	p_attribute12		;
    	l_batch_rec.attribute13          	:=  	p_attribute13		;
    	l_batch_rec.attribute14          	:=  	p_attribute14		;
    	l_batch_rec.attribute15          	:=  	p_attribute15		;
    	l_batch_rec.issue_date	     		:=  	p_issue_date		;
    	l_batch_rec.maturity_date        	:=  	p_maturity_date		;
    	l_batch_rec.special_instructions 	:=  	p_special_instructions	;
    	l_batch_rec.batch_process_status 	:=  	p_batch_process_status	;
    	l_batch_rec.selection_criteria_id   	:=  	p_selection_criteria_id	;


    	check_mandatory_data (l_batch_rec);

     	/*-------------------------------------------------------------+
     	|  Do required validation for the batch                        |
     	+-------------------------------------------------------------*/

      	ARP_PROCESS_BR_BATCHES.validate_batch (l_batch_rec);


     	/*---------------------------------------------------------------+
     	|  Call Table Handler to update the batch                        |
     	+---------------------------------------------------------------*/

    	arp_tbat_pkg.update_p (l_batch_rec, p_batch_id);


    	IF  	(p_request_id IS NOT NULL)
	THEN
		UPDATE  ra_batches
		SET	request_id 	= 	p_request_id
		WHERE	batch_id	=	p_batch_id;
    	END IF;


     	/*---------------------------------------------------------------+
     	|                 Selection Criteria Information                 |
     	+---------------------------------------------------------------*/

	IF  	(p_selection_criteria_id  IS NOT NULL)
	THEN
	     	arp_selection_criteria_pkg.set_to_dummy(l_sel_rec);
	END IF;

     	l_sel_rec.due_date_low			:= 	p_due_date_low		;
     	l_sel_rec.due_date_high			:= 	p_due_date_high		;
     	l_sel_rec.trx_date_low			:= 	p_trx_date_low		;
     	l_sel_rec.trx_date_high			:= 	p_trx_date_high		;
     	l_sel_rec.cust_trx_type_id		:= 	p_cust_trx_type_id	;
     	l_sel_rec.receipt_method_id		:= 	p_receipt_method_id	;
     	l_sel_rec.bank_branch_id		:= 	p_bank_branch_id	;
     	l_sel_rec.trx_number_low		:= 	p_trx_number_low	;
     	l_sel_rec.trx_number_high		:= 	p_trx_number_high	;
     	l_sel_rec.customer_class_code		:= 	p_customer_class_code	;
     	l_sel_rec.customer_category_code	:= 	p_customer_category_code;
     	l_sel_rec.customer_id			:= 	p_customer_id		;
     	l_sel_rec.site_use_id			:= 	p_site_use_id		;


     	IF  (Is_Selection_Entered (l_sel_rec))
	THEN

		/*-------------------------------------------------------------+
       		|  Do required validation for the selection criteria           |
       		+-------------------------------------------------------------*/

		ARP_PROCESS_BR_BATCHES.validate_selection (l_sel_rec, p_issue_date);


		IF  	(p_selection_criteria_id  IS NULL)
		THEN

			/*-------------------------------------------------------------+
	     		|  Call Table Handler to insert the selection                  |
     			+-------------------------------------------------------------*/

		     	arp_selection_criteria_pkg.insert_p ( l_sel_rec, p_selection_criteria_id);

	     		/*-------------------------------------------------------------+
     			|  Update the Batch information with the Selection Criteria ID |
     			+-------------------------------------------------------------*/

			UPDATE  RA_BATCHES
			SET	selection_criteria_id = p_selection_criteria_id
			WHERE	batch_id = p_batch_id;

		ELSE

			/*-------------------------------------------------------------+
     			|  Call Table Handler to update the selection                  |
     			+-------------------------------------------------------------*/

	     		arp_selection_criteria_pkg.update_p (l_sel_rec, p_selection_criteria_id);

		END IF;

     	END IF;

     	IF PG_DEBUG in ('Y', 'C') THEN
     	   arp_util.debug('ARP_PROCESS_BR_BATCHES.update_batch()-');
     	END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION : ARP_PROCESS_BR_BATCHES.update_batch');
       arp_util.debug('update_batch: ' || 'p_batch_source_id       : ' || p_batch_source_id);
       arp_util.debug('update_batch: ' || 'p_batch_date            : ' || p_batch_date);
       arp_util.debug('update_batch: ' || 'p_gl_date               : ' || p_gl_date);
       arp_util.debug('update_batch: ' || 'p_type                  : ' || p_type);
       arp_util.debug('update_batch: ' || 'p_currency_code         : ' || p_currency_code);
       arp_util.debug('update_batch: ' || 'p_comments              : ' || p_comments);
       arp_util.debug('update_batch: ' || 'p_attribute_category    : ' || p_attribute_category);
       arp_util.debug('update_batch: ' || 'p_attribute1            : ' || p_attribute1);
       arp_util.debug('update_batch: ' || 'p_attribute2            : ' || p_attribute2);
       arp_util.debug('update_batch: ' || 'p_attribute3            : ' || p_attribute3);
       arp_util.debug('update_batch: ' || 'p_attribute4            : ' || p_attribute4);
       arp_util.debug('update_batch: ' || 'p_attribute5            : ' || p_attribute5);
       arp_util.debug('update_batch: ' || 'p_attribute6            : ' || p_attribute6);
       arp_util.debug('update_batch: ' || 'p_attribute7            : ' || p_attribute7);
       arp_util.debug('update_batch: ' || 'p_attribute8            : ' || p_attribute8);
       arp_util.debug('update_batch: ' || 'p_attribute9            : ' || p_attribute9);
       arp_util.debug('update_batch: ' || 'p_attribute10           : ' || p_attribute10);
       arp_util.debug('update_batch: ' || 'p_attribute11           : ' || p_attribute11);
       arp_util.debug('update_batch: ' || 'p_attribute12           : ' || p_attribute12);
       arp_util.debug('update_batch: ' || 'p_attribute13           : ' || p_attribute13);
       arp_util.debug('update_batch: ' || 'p_attribute14           : ' || p_attribute14);
       arp_util.debug('update_batch: ' || 'p_attribute15           : ' || p_attribute15);
       arp_util.debug('update_batch: ' || 'p_issue_date            : ' || p_issue_date);
       arp_util.debug('update_batch: ' || 'p_maturity_date         : ' || p_maturity_date);
       arp_util.debug('update_batch: ' || 'p_special_instructions  : ' || p_special_instructions);
       arp_util.debug('update_batch: ' || 'p_batch_process_status  : ' || p_batch_process_status);
       arp_util.debug('update_batch: ' || 'p_name                  : ' || p_name);
       arp_util.debug('update_batch: ' || 'p_selection_criteria_id : ' || p_selection_criteria_id);
       arp_util.debug('update_batch: ' || 'p_due_date_low          : ' || p_due_date_low);
       arp_util.debug('update_batch: ' || 'p_due_date_high         : ' || p_due_date_high);
       arp_util.debug('update_batch: ' || 'p_trx_date_low          : ' || p_trx_date_low);
       arp_util.debug('update_batch: ' || 'p_trx_date_high         : ' || p_trx_date_high);
       arp_util.debug('update_batch: ' || 'p_cust_trx_type_id      : ' || p_cust_trx_type_id);
       arp_util.debug('update_batch: ' || 'p_receipt_method_id     : ' || p_receipt_method_id);
       arp_util.debug('update_batch: ' || 'p_bank_branch_id        : ' || p_bank_branch_id);
       arp_util.debug('update_batch: ' || 'p_trx_number_low        : ' || p_trx_number_low);
       arp_util.debug('update_batch: ' || 'p_trx_number_high       : ' || p_trx_number_high);
       arp_util.debug('update_batch: ' || 'p_customer_class_code   : ' || p_customer_class_code);
       arp_util.debug('update_batch: ' || 'p_customer_category_code: ' || p_customer_category_code);
       arp_util.debug('update_batch: ' || 'p_customer_id	    : ' || p_customer_id);
       arp_util.debug('update_batch: ' || 'p_site_use_id           : ' || p_site_use_id);
    END IF;
    RAISE;
END Update_Batch;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_batch                                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |									     |
 |    Call the table handlers of RA_BATCHES and AR_SELECTION_CRITERIA        |
 |    to delete BR Batch information                                         |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_form_name                                            |
 |                    p_form_version                                         |
 |                    p_batch_id                                             |
 |              OUT:                                                         |
 |                    None                                                   |
 |          IN  OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-APR-2000    Tien Tran            Created                           |
 |                                                                           |
 +===========================================================================*/

PROCEDURE delete_batch (
  	p_form_name              	IN 	varchar2				,
  	p_form_version           	IN 	number					,
  	p_batch_id               	IN 	ra_batches.batch_id%TYPE		,
  	p_selection_criteria_id  	IN 	ar_selection_criteria.selection_criteria_id%TYPE)

IS

BEGIN
    	arp_util.debug('ARP_PROCESS_BR_BATCHES.delete_batch()+');

     	/*-------------------------------------------------------------+
    	|  Check the form version to determine if it is compatible     |
     	|  with the entity handler                                     |
     	+-------------------------------------------------------------*/

    	arp_trx_validate.ar_entity_version_check (p_form_name, p_form_version);


     	/*-------------------------------------------------------------+
     	|  Do required validation  	                            |
     	+-------------------------------------------------------------*/

     	ARP_PROCESS_BR_BATCHES.validate_delete_batch (p_batch_id);


     	/*---------------------------------------------------------------+
     	|  Delete the selection Criteria if they exist                   |
     	+---------------------------------------------------------------*/

     	IF  (p_selection_criteria_id IS NOT NULL)
	THEN
         	arp_selection_criteria_pkg.delete_p (p_selection_criteria_id);
     	END IF;


     	/*---------------------------------------------------------------+
     	|  Call Table Handler to delete the batch                        |
     	+---------------------------------------------------------------*/

     	arp_tbat_pkg.delete_p (p_batch_id);


    	arp_util.debug('ARP_PROCESS_BR_BATCHES.delete_batch()-');

EXCEPTION
  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION : ARP_PROCESS_BR_BATCHES.delete_batch');

    arp_util.debug('p_form_name             : '|| p_form_name);
    arp_util.debug('p_form_version          : '|| p_form_version);
    arp_util.debug('p_batch_id              : '|| p_batch_id);
    arp_util.debug('p_selection_criteria_id : '|| p_selection_criteria_id);

    RAISE;
END;




/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_compare_batch                                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Call the table handlers of RA_BATCHES and AR_SELECTION_CRITERIA        |
 |    to lock BR Batch information                                           |
 |                                                                           |
 | SCOPE -                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_form_name                                            |
 |                    p_form_version                                         |
 |                    p_batch_id                                             |
 |                    p_name                                                 |
 |                    p_batch_source_id                                      |
 |                    p_batch_date                                           |
 |                    p_gl_date                                              |
 |                    p_type                                                 |
 |                    p_currency_code                                        |
 |                    p_comments                                             |
 |                    p_attribute_category                                   |
 |                    p_attribute1 - 15                                      |
 |                    p_issue_date					     |
 |                    p_maturity_date                                        |
 |                    p_special_instructions                                 |
 |                    p_batch_process_status                                 |
 |                    p_selection_criteria_id                                |
 |		      p_due_date_low					     |
 |		      p_due_date_high				  	     |
 |		      p_trx_date_low					     |
 |		      p_trx_date_high					     |
 |		      p_cust_trx_type_id				     |
 |		      p_receipt_method_id				     |
 |		      p_bank_branch_id			  	     	     |
 |		      p_trx_number_low				     	     |
 |		      p_trx_number_high				     	     |
 |		      p_customer_class_code				     |
 |		      p_customer_category_code		  	             |
 |		      p_customer_id					     |
 |		      p_site_use_id		 			     |
 |              OUT:                                                         |
 |                    None                                                   |
 |          IN  OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-APR-2000    Tien Tran            Created                           |
 |									     |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_compare_batch (
  	p_form_name              	IN  	varchar2			,
  	p_form_version           	IN  	number				,
  	p_batch_id               	IN  	ra_batches.batch_id%TYPE	,
  	p_name                   	IN  	ra_batches.name%TYPE		,
  	p_batch_source_id        	IN  	ra_batches.batch_source_id%TYPE	,
  	p_batch_date            	IN  	ra_batches.batch_date%TYPE	,
  	p_gl_date                	IN  	ra_batches.gl_date%TYPE		,
  	p_TYPE                   	IN  	ra_batches.TYPE%TYPE		,
  	p_currency_code          	IN  	ra_batches.currency_code%TYPE	,
  	p_comments               	IN  	ra_batches.comments%TYPE	,
  	p_attribute_category     	IN  	ra_batches.attribute_category%TYPE,
  	p_attribute1             	IN  	ra_batches.attribute1%TYPE	,
  	p_attribute2             	IN  	ra_batches.attribute2%TYPE	,
  	p_attribute3             	IN  	ra_batches.attribute3%TYPE	,
  	p_attribute4             	IN  	ra_batches.attribute4%TYPE	,
  	p_attribute5             	IN  	ra_batches.attribute5%TYPE	,
  	p_attribute6             	IN  	ra_batches.attribute6%TYPE	,
  	p_attribute7             	IN  	ra_batches.attribute7%TYPE	,
  	p_attribute8             	IN  	ra_batches.attribute8%TYPE	,
  	p_attribute9             	IN  	ra_batches.attribute9%TYPE	,
  	p_attribute10            	IN  	ra_batches.attribute10%TYPE	,
  	p_attribute11            	IN  	ra_batches.attribute11%TYPE	,
  	p_attribute12            	IN  	ra_batches.attribute12%TYPE	,
  	p_attribute13            	IN  	ra_batches.attribute13%TYPE	,
  	p_attribute14            	IN  	ra_batches.attribute14%TYPE	,
  	p_attribute15            	IN  	ra_batches.attribute15%TYPE	,
  	p_issue_date		   	IN  	ra_batches.issue_date%TYPE	,
  	p_maturity_date   	   	IN  	ra_batches.maturity_date%TYPE	,
  	p_special_instructions   	IN  	ra_batches.special_instructions%TYPE		,
  	p_batch_process_status   	IN  	ra_batches.batch_process_status%TYPE		,
  	p_selection_criteria_id  	IN  	ar_selection_criteria.selection_criteria_id%TYPE,
  	p_due_date_low  	   	IN  	ar_selection_criteria.due_date_low%TYPE		,
  	p_due_date_high	   		IN  	ar_selection_criteria.due_date_high%TYPE	,
 	p_trx_date_low	   		IN  	ar_selection_criteria.trx_date_low%TYPE		,
  	p_trx_date_high	   		IN  	ar_selection_criteria.trx_date_high%TYPE	,
  	p_cust_trx_TYPE_id	   	IN  	ar_selection_criteria.cust_trx_TYPE_id%TYPE	,
  	p_receipt_method_id	   	IN  	ar_selection_criteria.receipt_method_id%TYPE	,
  	p_bank_branch_id	   	IN  	ar_selection_criteria.bank_branch_id%TYPE	,
  	p_trx_number_low	   	IN  	ar_selection_criteria.trx_number_low%TYPE	,
  	p_trx_number_high	   	IN  	ar_selection_criteria.trx_number_high%TYPE	,
  	p_customer_class_code	   	IN  	ar_selection_criteria.customer_class_code%TYPE	,
  	p_customer_category_code 	IN  	ar_selection_criteria.customer_category_code%TYPE,
  	p_customer_id		   	IN  	ar_selection_criteria.customer_id%TYPE		,
  	p_site_use_id		   	IN  	ar_selection_criteria.site_use_id%TYPE		)

IS
  	l_batch_rec        ra_batches%rowtype		;
  	l_sel_rec          ar_selection_criteria%rowtype;

BEGIN
    	IF PG_DEBUG in ('Y', 'C') THEN
    	   arp_util.debug('ARP_PROCESS_BR_BATCHES.lock_compare_batch ()+');
    	END IF;

     	/*-------------------------------------------------------------+
     	|  Check the form version to determine if it is compatible     |
     	|  with the entity handler                                     |
     	+-------------------------------------------------------------*/

    	arp_trx_validate.ar_entity_version_check (p_form_name, p_form_version);



     	/*---------------------------------------------------------------+
     	| Call Table Handler to lock the Selection Criteria if they exist|
     	+---------------------------------------------------------------*/

    	IF	(p_selection_criteria_id IS NOT NULL)
	THEN
		ARP_SELECTION_CRITERIA_PKG.set_to_dummy(l_sel_rec);

    		l_sel_rec.selection_criteria_id := p_selection_criteria_id;
	    	l_sel_rec.due_date_low		:= p_due_date_low;
    		l_sel_rec.due_date_high		:= p_due_date_high;
	    	l_sel_rec.trx_date_low		:= p_trx_date_low;
	    	l_sel_rec.trx_date_high		:= p_trx_date_high;
    		l_sel_rec.cust_trx_type_id	:= p_cust_trx_type_id;
	    	l_sel_rec.receipt_method_id	:= p_receipt_method_id;
    		l_sel_rec.bank_branch_id	:= p_bank_branch_id;
	    	l_sel_rec.trx_number_low	:= p_trx_number_low;
    		l_sel_rec.trx_number_high	:= p_trx_number_high;
	    	l_sel_rec.customer_class_code	:= p_customer_class_code;
    		l_sel_rec.customer_category_code:= p_customer_category_code;
	    	l_sel_rec.customer_id		:= p_customer_id;
    		l_sel_rec.site_use_id		:= p_site_use_id;

		arp_selection_criteria_pkg.display_selection_rec (l_sel_rec);

    		ARP_SELECTION_CRITERIA_PKG.lock_compare_p(l_sel_rec,p_selection_criteria_id);

     	END IF;



     	/*---------------------------------------------------------------+
     	|  Call Table Handler to lock the batch                          |
     	+---------------------------------------------------------------*/

    	arp_tbat_pkg.set_to_dummy(l_batch_rec);

    	l_batch_rec.batch_id             	:= 	p_batch_id		;
    	l_batch_rec.name                 	:= 	p_name			;
	l_batch_rec.batch_source_id      	:= 	p_batch_source_id	;
    	l_batch_rec.batch_date           	:= 	trunc(p_batch_date)	;
    	l_batch_rec.gl_date              	:= 	trunc(p_gl_date)	;
    	l_batch_rec.type                 	:= 	p_type			;
    	l_batch_rec.currency_code        	:= 	p_currency_code		;
    	l_batch_rec.comments             	:= 	p_comments		;
    	l_batch_rec.attribute_category   	:= 	p_attribute_category	;
    	l_batch_rec.attribute1           	:= 	p_attribute1		;
    	l_batch_rec.attribute2           	:= 	p_attribute2		;
    	l_batch_rec.attribute3           	:= 	p_attribute3		;
    	l_batch_rec.attribute4           	:= 	p_attribute4		;
    	l_batch_rec.attribute5           	:= 	p_attribute5		;
    	l_batch_rec.attribute6           	:= 	p_attribute6		;
    	l_batch_rec.attribute7           	:= 	p_attribute7		;
    	l_batch_rec.attribute8           	:= 	p_attribute8		;
    	l_batch_rec.attribute9           	:= 	p_attribute9		;
    	l_batch_rec.attribute10          	:= 	p_attribute10		;
    	l_batch_rec.attribute11          	:= 	p_attribute11		;
    	l_batch_rec.attribute12          	:= 	p_attribute12		;
    	l_batch_rec.attribute13          	:= 	p_attribute13		;
    	l_batch_rec.attribute14          	:= 	p_attribute14		;
    	l_batch_rec.attribute15          	:= 	p_attribute15		;
    	l_batch_rec.issue_date	     		:= 	trunc(p_issue_date)	;
    	l_batch_rec.maturity_date        	:= 	trunc(p_maturity_date)	;
    	l_batch_rec.special_instructions 	:= 	p_special_instructions	;
    	l_batch_rec.batch_process_status 	:= 	p_batch_process_status	;
    	l_batch_rec.selection_criteria_id  	:= 	p_selection_criteria_id	;

    	arp_tbat_pkg.display_batch_rec (l_batch_rec);

    	arp_tbat_pkg.lock_compare_p(l_batch_rec, p_batch_id);


    	IF PG_DEBUG in ('Y', 'C') THEN
    	   arp_util.debug('ARP_PROCESS_BR_BATCHES.lock_compare_batch()-');
    	END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION : ARP_PROCESS_BR_BATCHES.lock_compare_batch');
    END IF;

    RAISE;
END lock_compare_batch;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    submit_print                                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Call the format program						     |
 |                                                                           |
 | SCOPE -                                                           	     |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_format                                               |
 |		      p_BR_ID	  	 			     	     |
 |              OUT:                                                         |
 |                    p_request_id                                           |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     13-JUL-2000    Tien Tran            Created                           |
 |									     |
 |                                                                           |
 +===========================================================================*/

PROCEDURE submit_print ( p_format			IN	varchar2	,
			 p_BR_ID			IN	number		,
			 p_request_id			OUT NOCOPY	number		)

IS

BEGIN

	p_request_id := FND_REQUEST.submit_request   (	'AR'				,
                                         		'ARBRFMTW'      		,
							NULL				,
					 		NULL				,
                                         		NULL				,
                                         		p_format			,
                                         		p_BR_ID				,
                                         		NULL				,
                                         		NULL				,
                                         		arp_global.set_of_books_id	);


EXCEPTION
	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : ARP_PROCESS_BR_BATCHES.Submit_Print () ');
		END IF;
		RAISE;

END submit_print;


/*----------------------------------------------------------------------------------------
 | PROCEDURE
 |    br_create
 |
 | DESCRIPTION
 |    Procedure called during the process to create bills receivable
 |    to submit the BR Creation concurrent program
 |
 | SCOPE - PUBLIC
 |
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE
 |
 | ARGUMENTS : IN :
 |
 | RETURNS   : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY - Created by O Charni - 10/08/2000
 |
 +===========================================================================*/

PROCEDURE br_create(
	p_call                   	IN  	NUMBER					,
	p_draft_mode             	IN  	VARCHAR2 				,
	p_print_flag             	IN  	VARCHAR2				,
	p_batch_id               	IN  	RA_BATCHES.batch_id%TYPE 		,
	p_batch_source_id        	IN  	RA_BATCHES.batch_source_id%TYPE	        ,
	p_batch_date             	IN  	RA_BATCHES.batch_date%TYPE		,
	p_gl_date                	IN  	RA_BATCHES.gl_date%TYPE			,
	p_issue_date             	IN  	RA_BATCHES.issue_date%TYPE		,
	p_maturity_date          	IN  	RA_BATCHES.maturity_date%TYPE 		,
	p_currency_code          	IN  	RA_BATCHES.currency_code%TYPE 		,
	p_comments               	IN  	RA_BATCHES.comments%TYPE 		,
	p_special_instructions   	IN  	RA_BATCHES.special_instructions%TYPE	,
	p_attribute_category     	IN  	RA_BATCHES.attribute_category%TYPE	,
	p_attribute1             	IN  	VARCHAR2				,
	p_attribute2             	IN  	VARCHAR2				,
	p_attribute3             	IN  	VARCHAR2				,
	p_attribute4             	IN  	VARCHAR2				,
	p_attribute5             	IN  	VARCHAR2				,
	p_attribute6             	IN  	VARCHAR2				,
	p_attribute7             	IN  	VARCHAR2				,
	p_attribute8             	IN  	VARCHAR2				,
	p_attribute9             	IN  	VARCHAR2				,
	p_attribute10            	IN  	VARCHAR2				,
	p_attribute11            	IN  	VARCHAR2				,
	p_attribute12            	IN  	VARCHAR2				,
	p_attribute13            	IN  	VARCHAR2				,
	p_attribute14            	IN  	VARCHAR2				,
	p_attribute15            	IN  	VARCHAR2				,
	p_due_date_low           	IN  	AR_PAYMENT_SCHEDULES.due_date%TYPE	,
	p_due_date_high          	IN  	AR_PAYMENT_SCHEDULES.due_date%TYPE	,
	p_trx_date_low           	IN  	RA_CUSTOMER_TRX.trx_date%TYPE		,
	p_trx_date_high          	IN  	RA_CUSTOMER_TRX.trx_date%TYPE		,
	p_trx_type_id            	IN  	RA_CUST_TRX_TYPES.cust_trx_type_id%TYPE	,
	p_rcpt_meth_id           	IN  	AR_RECEIPT_METHODS.receipt_method_id%TYPE,
	p_cust_bank_branch_id    	IN  	CE_BANK_BRANCHES_V.branch_party_id%TYPE	,
	p_trx_number_low         	IN  	RA_CUSTOMER_TRX.trx_number%TYPE 	,
	p_trx_number_high        	IN  	RA_CUSTOMER_TRX.trx_number%TYPE 	,
	p_cust_class             	IN  	AR_LOOKUPS.lookup_code%TYPE		,
	p_cust_category          	IN  	AR_LOOKUPS.lookup_code%TYPE 		,
	p_customer_id            	IN  	HZ_CUST_ACCOUNTS.cust_account_id%TYPE 		,
	p_site_use_id            	IN  	HZ_CUST_SITE_USES.site_use_id%TYPE		,
	p_req_id                 	OUT NOCOPY 	NUMBER					,
	p_batch_process_status   	OUT NOCOPY 	VARCHAR2 				)

IS
	l_request_id 		RA_BATCHES.request_id%TYPE ;
	l_batch_process_status 	RA_BATCHES.batch_process_status%TYPE ;
        l_org_id                RA_BATCH_SOURCES_ALL.ORG_ID%TYPE;

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('ARP_PROCESS_BR_BATCHES.br_create(+)');
	END IF;

        --Bug 5051673
        SELECT org_id
        INTO  l_org_id
        FROM RA_BATCH_SOURCES
        WHERE batch_source_id = p_batch_source_id;

       FND_REQUEST.set_org_id(l_org_id);

	l_request_id := FND_REQUEST.submit_request(
		application  	=> 'AR'
	, 	program     	=> 'ARBRBRCP'
	,	description  	=> NULL
	,	start_time    	=> NULL
	, 	sub_request 	=> NULL
	, 	argument1   	=> p_call
	, 	argument2   	=> p_draft_mode
	, 	argument3   	=> p_print_flag
	, 	argument4   	=> p_batch_id
	,	argument5   	=> p_batch_source_id
	, 	argument6    	=> fnd_date.date_to_canonical(p_batch_date)
	, 	argument7    	=> fnd_date.date_to_canonical(p_gl_date)
	, 	argument8   	=> fnd_date.date_to_canonical(p_issue_date)
	, 	argument9    	=> fnd_date.date_to_canonical(p_maturity_date)
	, 	argument10   	=> p_currency_code
	, 	argument11  	=> p_comments
	, 	argument12  	=> p_special_instructions
	, 	argument13  	=> p_attribute_category
	, 	argument14  	=> p_attribute1
	, 	argument15  	=> p_attribute2
	, 	argument16  	=> p_attribute3
	, 	argument17  	=> p_attribute4
	, 	argument18  	=> p_attribute5
	, 	argument19  	=> p_attribute6
	, 	argument20  	=> p_attribute7
	, 	argument21  	=> p_attribute8
	, 	argument22  	=> p_attribute9
	, 	argument23  	=> p_attribute10
	, 	argument24  	=> p_attribute11
	, 	argument25  	=> p_attribute12
	, 	argument26  	=> p_attribute13
	, 	argument27  	=> p_attribute14
	, 	argument28  	=> p_attribute15
	, 	argument29  	=> fnd_date.date_to_canonical(p_due_date_low)
	, 	argument30  	=> fnd_date.date_to_canonical(p_due_date_high)
	, 	argument31  	=> fnd_date.date_to_canonical(p_trx_date_low)
	, 	argument32  	=> fnd_date.date_to_canonical(p_trx_date_high)
	, 	argument33  	=> p_trx_type_id
	, 	argument34  	=> p_rcpt_meth_id
	, 	argument35  	=> p_cust_bank_branch_id
	, 	argument36  	=> p_trx_number_low
	, 	argument37  	=> p_trx_number_high
	, 	argument38  	=> p_cust_class
	, 	argument39  	=> p_cust_category
	, 	argument40  	=> p_customer_id
	, 	argument41  	=> p_site_use_id ) ;



	p_req_id               	:= l_request_id;
	p_batch_process_status 	:= l_batch_process_status;


	COMMIT;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('ARP_PROCESS_BR_BATCHES.br_create(-)');
	END IF;

EXCEPTION
     	WHEN OTHERS THEN
      		IF PG_DEBUG in ('Y', 'C') THEN
      		   arp_util.debug('>>>>>>>>>>> EXCEPTION : ARP_PROCESS_BR_BATCHES.br_create() ');
      		END IF;

END br_create ;


END ARP_PROCESS_BR_BATCHES;

/
