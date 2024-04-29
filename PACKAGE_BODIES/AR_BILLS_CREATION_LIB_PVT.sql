--------------------------------------------------------
--  DDL for Package Body AR_BILLS_CREATION_LIB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_BILLS_CREATION_LIB_PVT" AS
/* $Header: ARBRCRLB.pls 120.6 2005/11/11 12:33:42 sgnagara ship $ */

G_PKG_NAME      CONSTANT VARCHAR2(30)   := 'AR_BILLS_CREATION_LIB_PVT';


API_EXCEPTION		EXCEPTION;

/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Default_GL_Date		                                  		|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Validates the GL Date if passed to the procedure or defaults it		|
 |    										|
 +==============================================================================*/


PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE Default_GL_date(p_entered_date	IN  	DATE		,
			  p_gl_date      	OUT NOCOPY 	DATE		,
                          p_return_status 	OUT NOCOPY 	VARCHAR2	) IS

l_error_message        VARCHAR2(128);
l_defaulting_rule_used VARCHAR2(50);
l_default_gl_date      DATE;

BEGIN
  	IF PG_DEBUG in ('Y', 'C') THEN
  	   arp_util.debug('AR_BILLS_CREATION_LIB_PVT.Default_gl_date ()+');
  	END IF;

	p_return_status := FND_API.G_RET_STS_SUCCESS;

	IF (arp_util.validate_and_default_gl_date(
               	p_entered_date	,
               	NULL		,
               	NULL		,
               	NULL		,
               	NULL		,
               	NULL		,
               	NULL		,
               	NULL		,
               	'N' 		,
               	NULL		,
               	arp_global.set_of_books_id	,
               	222				,
               	l_default_gl_date		,
               	l_defaulting_rule_used		,
               	l_error_message)   =   TRUE	)
     	THEN
       		p_gl_date := l_default_gl_date;
     	ELSE
      		--  Raise error message if failure in defaulting the gl_date
      		--  this is the only place in the defaulting routine where we raise
      		--  error message

      		p_return_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('AR', 'GENERIC_MESSAGE');
      		FND_MESSAGE.SET_TOKEN('GENERIC_TEXT', l_error_message);
  		app_exception.raise_exception;

     	END IF;

  	IF PG_DEBUG in ('Y', 'C') THEN
  	   arp_util.debug('AR_BILLS_CREATION_LIB_PVT.Default_gl_date ()-');
  	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_LIB_PVT.default_gl_date () ');
		   arp_util.debug('Default_GL_date: ' || '           p_entered_date = ' || p_entered_date);
		END IF;
		RAISE;

END default_gl_date;




/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Default_Drawee_Location	                                     		|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Defaults the Drawee Location : Primary Site for the BR Drawee Purpose     |
 |                                                                           	|
 +==============================================================================*/

PROCEDURE Default_Drawee_Location (p_drawee_id		IN  NUMBER	,
				   p_drawee_site_use_id	OUT NOCOPY NUMBER	) IS

l_drawee_site_use_id	NUMBER;

BEGIN
   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_CREATION_LIB_PVT.Default_Drawee_Location ()+');
   	END IF;

        /* modified for tca uptake */
	SELECT 	site_uses.SITE_USE_ID
	INTO	p_drawee_site_use_id
	FROM	hz_cust_site_uses site_uses,
		hz_cust_acct_sites acct_site
	WHERE  	acct_site.cust_account_id	=  p_drawee_id
	AND	acct_site.cust_acct_site_id	=  site_uses.cust_acct_site_id
	AND	site_uses.site_use_code		=  'DRAWEE'
	AND	site_uses.status		=  'A'
	AND	site_uses.primary_flag		=  'Y';

   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_CREATION_LIB_PVT.Default_Drawee_Location ()-');
   	END IF;

EXCEPTION
    	WHEN   NO_DATA_FOUND THEN
      	   	IF PG_DEBUG in ('Y', 'C') THEN
      	   	   arp_util.debug ('Default_Drawee_Location: ' || '>>>>>>>>>> No Drawee Location could be Defaulted');
		   arp_util.debug ('Default_Drawee_Location: ' || '>>>>>>>>>> The Drawee Location is Mandatory');
		END IF;
		FND_MESSAGE.SET_NAME ('AR', 'AR_BR_DRAWEE_SITE_NULL');
		app_exception.raise_exception;

	WHEN TOO_MANY_ROWS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>> Default_Drawee_Location : Too Many rows');
		   arp_util.debug('Default_Drawee_Location: ' || '           p_drawee_id	         = ' || p_drawee_id	);
		END IF;

	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : Default_Drawee_Location () ');
		   arp_util.debug('Default_Drawee_Location: ' || '           p_drawee_id = ' || p_drawee_id);
		END IF;
		RAISE;

END Default_Drawee_Location;



/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Default_Drawee_Contact	                                     		|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Defaults the Drawee Contact : Primary Contact assigned to the site or     |
 |    the client                                                              	|
 |										|
 +==============================================================================*/

PROCEDURE Default_Drawee_Contact  (p_drawee_id			IN  NUMBER	,
				   p_drawee_site_use_id		IN  NUMBER	,
				   p_drawee_contact_id		OUT NOCOPY NUMBER	) IS


BEGIN
   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_CREATION_LIB_PVT.Default_Drawee_Contact ()+');
   	END IF;

        /* modified for tca uptake */
        /* fix bug 1883538: replace current role state with status column */
	SELECT 	acct_role.cust_account_role_id
	INTO	p_drawee_contact_id
	FROM	hz_cust_account_roles acct_role,
		hz_role_responsibility role_res,
		HZ_CUST_SITE_USES site_uses
	WHERE  	acct_role.cust_account_id	=  p_drawee_id
	AND	nvl(acct_role.status, 'I')	=  'A'
	AND	acct_role.cust_acct_site_id  =  site_uses.cust_acct_site_id
	AND	site_uses.site_use_id	=  p_drawee_site_use_id
	AND	acct_role.cust_account_role_id	=  role_res.cust_account_role_id
	AND	role_res.responsibility_type 	=  'BILL_TO'
	AND	role_res.primary_flag		=  'Y';

   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_CREATION_LIB_PVT.Default_Drawee_Contact ()-');
   	END IF;

EXCEPTION
    	WHEN NO_DATA_FOUND THEN
      	   	IF PG_DEBUG in ('Y', 'C') THEN
      	   	   arp_util.debug('Default_Drawee_Contact: ' || '>>>>> No Drawee Contact could be defaulted');
		   arp_util.debug('Default_Drawee_Contact: ' || '           p_drawee_id	         = ' || p_drawee_id	);
		   arp_util.debug('Default_Drawee_Contact: ' || '           p_drawee_site_use_id  = ' || p_drawee_site_use_id);
		END IF;

	WHEN TOO_MANY_ROWS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>> Default_Drawee_Contact : Too Many rows');
		   arp_util.debug('Default_Drawee_Contact: ' || '           p_drawee_id	         = ' || p_drawee_id	);
		   arp_util.debug('Default_Drawee_Contact: ' || '           p_drawee_site_use_id  = ' || p_drawee_site_use_id);
		END IF;

    	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_LIB_PVT.Default_Drawee_Contact () ');
		   arp_util.debug('Default_Drawee_Contact: ' || '           p_drawee_id	         = ' || p_drawee_id	);
		   arp_util.debug('Default_Drawee_Contact: ' || '           p_drawee_site_use_id  = ' || p_drawee_site_use_id);
		END IF;
		RAISE;

END Default_Drawee_Contact;



/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Default_Printing_Option	                                     		|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Defaults the Printing Option from the Transaction Type			|
 |										|
 +==============================================================================*/

PROCEDURE Default_Printing_Option  (p_cust_trx_type_id		IN  NUMBER	,
				    p_printing_option		OUT NOCOPY VARCHAR2	) IS


BEGIN
   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_CREATION_LIB_PVT.Default_Printing_Option ()+');
   	END IF;

	SELECT 	default_printing_option
	INTO	p_printing_option
	FROM	RA_CUST_TRX_TYPES
	WHERE  	cust_trx_type_id	=  p_cust_trx_type_id;

   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_CREATION_LIB_PVT.Default_Printing_Option ()-');
   	END IF;

EXCEPTION
	WHEN   	NO_DATA_FOUND THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_LIB_PVT.Default_Printing_Option () () ');
      		   arp_util.debug('Default_Printing_Option: ' || '>>>>>>>>>> Invalid Transaction Type');
		   arp_util.debug('Default_Printing_Option: ' || '           p_cust_trx_type_id = ' || p_cust_trx_type_id);
		END IF;
	   	FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_INVALID_TRX_TYPE');
		app_exception.raise_exception;

    	WHEN 	OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_LIB_PVT.Default_Printing_Option () ');
		   arp_util.debug('Default_Printing_Option: ' || '           p_cust_trx_type_id      = ' || p_cust_trx_type_id);
		END IF;
		RAISE;

END Default_Printing_Option;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Default_Drawee_Account	                                     		|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Defaults the Drawee Bank Account ID : 					|
 |	Drawee's primary bank account for the the currency			|
 |										|
 +==============================================================================*/

PROCEDURE Default_Drawee_Account  ( p_drawee_id			IN  NUMBER	,
				    p_invoice_currency_code	IN  VARCHAR2	,
				    p_drawee_bank_account_id	OUT NOCOPY NUMBER	) IS


BEGIN
       /* PAYMENT_UPTAKE */
   	IF PG_DEBUG in ('Y', 'C') THEN
   	  arp_util.debug('AR_BILLS_CREATION_LIB_PVT.Default_Drawee_Account ()+');
	  arp_util.debug('Default_Drawee_Account: ' || '>>>>> No Drawee Account could be defaulted');
   	   arp_util.debug('AR_BILLS_CREATION_LIB_PVT.Default_Drawee_Account ()-');
   	END IF;

END Default_Drawee_Account;



/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Get_Payment_Schedule_Id			                                |
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Returns the payment schedule ID of the BR, identified by the 		|
 |    p_customer_trx_id parameter						|
 |										|
 +==============================================================================*/


PROCEDURE Get_Payment_Schedule_ID (
	p_customer_trx_id 	 IN    ra_customer_trx.customer_trx_id%TYPE		,
	p_payment_schedule_id 	 OUT NOCOPY   ar_payment_schedules.payment_schedule_id%TYPE	)
IS

BEGIN

   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_CREATION_LIB_PVT.Get_Payment_Schedule_Id()+ ');
   	END IF;

  	SELECT 	payment_schedule_id
	INTO	p_payment_schedule_id
	FROM	ar_payment_schedules
	WHERE	customer_trx_id		=	p_customer_trx_id;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('Get_Payment_Schedule_ID: ' || 'Payment Schedule Id : ' || p_payment_schedule_id);
   	   arp_util.debug('AR_BILLS_CREATION_LIB_PVT.Get_Payment_Schedule_Id()- ');
   	END IF;

EXCEPTION
    	WHEN NO_DATA_FOUND THEN
      	   	IF PG_DEBUG in ('Y', 'C') THEN
      	   	   arp_util.debug('Get_Payment_Schedule_ID: ' || '>>>>> No Payment Schedule for the BR could found');
		   arp_util.debug('Get_Payment_Schedule_ID: ' || '           p_customer_trx_id   = ' || p_customer_trx_id);
		END IF;

    	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_LIB_PVT.Get_Payment_Schedule_Id () ');
		   arp_util.debug('Get_Payment_Schedule_ID: ' || '           p_customer_trx_id   = ' || p_customer_trx_id);
		END IF;
		RAISE;

END Get_Payment_Schedule_Id;



/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Check_Header_Mandatory_Data		                                |
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Check that mandatory parameters are passed to the API			|
 |										|
 +==============================================================================*/



PROCEDURE Check_Header_Mandatory_Data ( p_trx_rec  IN    ra_customer_trx%ROWTYPE)
IS
BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_CREATION_LIB_PVT.Check_Header_Mandatory_Data ()+ ');
	END IF;

	IF  (p_trx_rec.batch_source_id IS NULL) THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('Check_Header_Mandatory_Data: ' || '>>>>>>>>>> Batch Source Missing');
		END IF;
		FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_BATCH_SOURCE_NULL');
	   	app_exception.raise_exception;
	END IF;


	IF  (p_trx_rec.cust_trx_type_id IS NULL) THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('Check_Header_Mandatory_Data: ' || '>>>>>>>>>> Transaction Type Missing');
		END IF;
		FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_TRX_TYPE_NULL');
	   	app_exception.raise_exception;
	END IF;


	IF  (p_trx_rec.invoice_currency_code IS NULL) THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('Check_Header_Mandatory_Data: ' || '>>>>>>>>>> Currency Code Missing');
		END IF;
		FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_CURRENCY_NULL');
	   	app_exception.raise_exception;
	END IF;


	IF  (p_trx_rec.drawee_id IS NULL) THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('Check_Header_Mandatory_Data: ' || '>>>>>>>>>> Drawee Id Missing');
		END IF;
		FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_DRAWEE_ID_NULL');
	   	app_exception.raise_exception;
	END IF;

        IF  (p_trx_rec.legal_entity_id IS NULL) THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug('Check_Header_Mandatory_Data: ' || '>>>>>>>>>> Legal Entity Id Missing');
                END IF;
                FND_MESSAGE.SET_NAME  ('AR', 'AR_LE_NAME_MANDATORY');
                app_exception.raise_exception;
        END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_CREATION_LIB_PVT.Check_Header_Mandatory_Data ()- ');
	END IF;

EXCEPTION
    	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_LIB_PVT.Check_Header_Mandatory_Data () ');
		END IF;
		RAISE;

END Check_Header_Mandatory_Data;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Validate_Desc_Flexfield	                                     		|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Validate and Default the flexfields					|
 |										|
 +==============================================================================*/


PROCEDURE Validate_Desc_Flexfield (	p_attribute_category	IN OUT NOCOPY 	VARCHAR2	,
					p_attribute1		IN OUT NOCOPY 	VARCHAR2	,
					p_attribute2		IN OUT NOCOPY 	VARCHAR2	,
					p_attribute3		IN OUT NOCOPY 	VARCHAR2	,
					p_attribute4		IN OUT NOCOPY 	VARCHAR2	,
					p_attribute5		IN OUT NOCOPY 	VARCHAR2	,
					p_attribute6		IN OUT NOCOPY 	VARCHAR2	,
					p_attribute7		IN OUT NOCOPY 	VARCHAR2	,
					p_attribute8		IN OUT NOCOPY 	VARCHAR2	,
					p_attribute9		IN OUT NOCOPY 	VARCHAR2	,
					p_attribute10		IN OUT NOCOPY 	VARCHAR2	,
					p_attribute11		IN OUT NOCOPY 	VARCHAR2	,
					p_attribute12		IN OUT NOCOPY 	VARCHAR2	,
					p_attribute13		IN OUT NOCOPY	VARCHAR2	,
					p_attribute14		IN OUT NOCOPY 	VARCHAR2	,
					p_attribute15		IN OUT NOCOPY 	VARCHAR2	,
                          		p_desc_flex_name      	IN 	VARCHAR2	)
IS

l_flex_name     	fnd_descriptive_flexs.descriptive_flexfield_name%type;
l_count         	NUMBER;
l_col_name     		VARCHAR2(50);
p_desc_flex_rec		arp_util.attribute_rec_type;
l_return_status		VARCHAR2(1);


BEGIN

    	IF PG_DEBUG in ('Y', 'C') THEN
    	   arp_util.debug('AR_BILLS_CREATION_LIB_PVT.Validate_Desc_Flexfield ()+');
    	END IF;

 	p_desc_flex_rec.attribute_category 	:= 	p_attribute_category	;
     	p_desc_flex_rec.attribute1  		:= 	p_attribute1		;
     	p_desc_flex_rec.attribute2  		:= 	p_attribute2		;
     	p_desc_flex_rec.attribute3  		:= 	p_attribute3		;
     	p_desc_flex_rec.attribute4 		:= 	p_attribute4		;
     	p_desc_flex_rec.attribute5  		:= 	p_attribute5		;
     	p_desc_flex_rec.attribute6  		:= 	p_attribute6		;
     	p_desc_flex_rec.attribute7  		:= 	p_attribute7		;
     	p_desc_flex_rec.attribute8  		:= 	p_attribute8		;
     	p_desc_flex_rec.attribute9  		:= 	p_attribute9		;
     	p_desc_flex_rec.attribute10 		:= 	p_attribute10		;
     	p_desc_flex_rec.attribute11 		:= 	p_attribute11		;
     	p_desc_flex_rec.attribute12 		:= 	p_attribute12		;
     	p_desc_flex_rec.attribute13 		:= 	p_attribute13		;
     	p_desc_flex_rec.attribute14 		:= 	p_attribute14		;
     	p_desc_flex_rec.attribute15 		:= 	p_attribute15		;

     	arp_util.Validate_Desc_Flexfield (	p_desc_flex_rec	,
                                      		p_desc_flex_name,
                                      		l_return_status	);

     	IF ( l_return_status 	<>	FND_API.G_RET_STS_SUCCESS)
     	THEN
       		IF PG_DEBUG in ('Y', 'C') THEN
       		   arp_util.debug ('Validate_Desc_Flexfield: ' || '>>>>>>>>>> Flexfield Invalid : ' || p_desc_flex_name);
       		END IF;
		FND_MESSAGE.SET_NAME  ('AR'	 , 'AR_RAPI_DESC_FLEX_INVALID');
       		FND_MESSAGE.SET_TOKEN ('DFF_NAME',  p_desc_flex_name);
       		app_exception.raise_exception;
     	END IF;

     	p_attribute_category 			:= 	p_desc_flex_rec.attribute_category	;
     	p_attribute1  				:= 	p_desc_flex_rec.attribute1		;
     	p_attribute2  				:= 	p_desc_flex_rec.attribute2		;
     	p_attribute3  				:= 	p_desc_flex_rec.attribute3		;
     	p_attribute4  				:= 	p_desc_flex_rec.attribute4		;
     	p_attribute5  				:= 	p_desc_flex_rec.attribute5		;
     	p_attribute6  				:= 	p_desc_flex_rec.attribute6		;
     	p_attribute7  				:= 	p_desc_flex_rec.attribute7		;
     	p_attribute8  				:= 	p_desc_flex_rec.attribute8		;
     	p_attribute9  				:= 	p_desc_flex_rec.attribute9		;
     	p_attribute10 				:= 	p_desc_flex_rec.attribute10		;
     	p_attribute11 				:= 	p_desc_flex_rec.attribute11		;
     	p_attribute12 				:= 	p_desc_flex_rec.attribute12		;
     	p_attribute13 				:= 	p_desc_flex_rec.attribute13		;
     	p_attribute14 				:= 	p_desc_flex_rec.attribute14		;
     	p_attribute15 				:= 	p_desc_flex_rec.attribute15		;

     	IF PG_DEBUG in ('Y', 'C') THEN
     	   arp_util.debug('AR_BILLS_CREATION_LIB_PVT.Validate_Desc_Flexfield()-');
     	END IF;

EXCEPTION
    	WHEN 	OTHERS THEN
        	IF PG_DEBUG in ('Y', 'C') THEN
        	   arp_util.debug('EXCEPTION: AR_BILLS_CREATION_LIB_PVT.Validate_Desc_Flexfield');
        	END IF;
	       	RAISE;

END Validate_Desc_Flexfield;




/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Default_Create_BR_Header			                                |
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Defaults data in the BR Header 						|
 |										|
 +==============================================================================*/


PROCEDURE Default_Create_BR_Header ( 	p_trx_rec	IN OUT NOCOPY	ra_customer_trx%ROWTYPE	,
					p_gl_date	IN OUT NOCOPY	DATE			)

IS
	l_signed_flag		VARCHAR2(1);
	l_return_status		VARCHAR2(1);

BEGIN

   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_CREATION_LIB_PVT.Default_Create_BR_Header()+ ');
   	END IF;


	Check_Header_Mandatory_Data (p_trx_rec);


       /*-----------------------------------------------+
        |   Default the maturity date if NULL  		|
        +-----------------------------------------------*/

	IF 	(p_trx_rec.term_due_date IS NULL)
	THEN
		SELECT 	SYSDATE
    		INTO 	p_trx_rec.term_due_date
    		FROM 	dual;
  	END IF;


       /*-----------------------------------------------+
        |   Default the Issue date if NULL  		|
        +-----------------------------------------------*/

  	IF 	(p_trx_rec.trx_date IS NULL)
	THEN
    		SELECT 	SYSDATE
    		INTO 	p_trx_rec.trx_date
    		FROM	dual;
  	END IF;


        /*-----------------------------------------------------------------------
          Bug 1746385 : gl date was defaulting to sysdate when BR DID NOT
          require acceptance, this was opposite of what it should have been
          ie, If Bill requires acceptance, default the GL date to Sysdate
          removed NOT before AR_BILLS_MAINTAIN_STATUS_PUB

          Part 2 : since the GL date of a BR that requires acceptance will NOT
          affect GL until it is actually accepted, the value that defaults in
          is irrelevant, By commenting out NOCOPY the following IF clause, GL date
          defaults to Batch GL date regardless of whether the BR requires
          accpetance or not


  	IF AR_BILLS_MAINTAIN_STATUS_PUB.Is_Acceptance_Required(p_trx_rec.cust_trx_type_id)
	THEN
    		Default_gl_date (sysdate, p_gl_date, l_return_status);
    		IF PG_DEBUG in ('Y', 'C') THEN
    		   arp_util.debug('Default_Create_BR_Header: ' || 'l_default_gl_date_return_status : ' || l_return_status);
	  	   arp_util.debug('Default_Create_BR_Header: ' || 'GL Date defaulted               : ' || p_gl_date);
	  	END IF;
  	END IF;

          ----------------------------------------------------------------------*/



       /*-----------------------------------------------+
        |   Default the printing option  		|
        +-----------------------------------------------*/

	IF 	(p_trx_rec.printing_option IS NULL)
	THEN
		Default_Printing_Option  (p_trx_rec.cust_trx_type_id,
					  p_trx_rec.printing_option );
	END IF;


       /*-----------------------------------------------+
        |   Default the Override Remittance Account Flag|
        +-----------------------------------------------*/

	IF  	(p_trx_rec.override_remit_account_flag IS NULL)
	THEN
		p_trx_rec.override_remit_account_flag := 'N';
	END IF;



       /*-----------------------------------------------+
        |   Default the drawee location, contact,	|
	|   account for the auto creation program.	|
	+-----------------------------------------------*/

	IF	(p_trx_rec.created_from	  not    in	('ARBRMAIN', 'ARBRMAIB'))
	THEN

		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('Default_Create_BR_Header: ' || 'Auto Creation Program Defaulting');
		END IF;


	 	/*----------------------------------------------+
	        |   Default the drawee location			|
	        +-----------------------------------------------*/

		IF	(p_trx_rec.drawee_site_use_id IS NULL)
		THEN
			Default_Drawee_Location	(p_trx_rec.drawee_id, p_trx_rec.drawee_site_use_id);
		END IF;


	 	/*----------------------------------------------+
	        |   Default the drawee contact id		|
	        +-----------------------------------------------*/

		IF	(p_trx_rec.drawee_contact_id  IS NULL)
		THEN
			Default_Drawee_Contact	(p_trx_rec.drawee_id		,
						 p_trx_rec.drawee_site_use_id	,
						 p_trx_rec.drawee_contact_id	);
		END IF;


	 	/*----------------------------------------------+
	        |   Default the drawee account			|
	        +-----------------------------------------------*/

                /* bug 1808976 : the correct drawee_bank_account_id should have
                   been derived in ARBRTESB.pls procedure create_br, if at this
                   point it is still NULL, leave it NULL

		IF	(p_trx_rec.drawee_bank_account_id IS NULL)
		THEN
			Default_drawee_account ( p_trx_rec.drawee_id		,
						 p_trx_rec.invoice_currency_code,
						 p_trx_rec.drawee_bank_account_id);
		END IF;

                */

          END IF;

        -- 3999819 : flexfield validation should only be done when creating BR thru ARBRMAIN.fmb
        -- for all other "automatic" methods of creating BR ie. batch/exchange from TRX WB,
        -- desc flexfield validation is bypassed
        IF      (p_trx_rec.created_from = 'ARBRMAIN')
        THEN

		/*----------------------------------------------+
	        |   Validate and default the flexfields		|
	        +-----------------------------------------------*/

		Validate_Desc_Flexfield	  (  	p_trx_rec.attribute_category	,
					   	p_trx_rec.attribute1		,
						p_trx_rec.attribute2		,
						p_trx_rec.attribute3		,
						p_trx_rec.attribute4		,
						p_trx_rec.attribute5		,
						p_trx_rec.attribute6		,
						p_trx_rec.attribute7		,
						p_trx_rec.attribute8		,
						p_trx_rec.attribute9		,
						p_trx_rec.attribute10		,
						p_trx_rec.attribute11		,
						p_trx_rec.attribute12		,
						p_trx_rec.attribute13		,
						p_trx_rec.attribute14		,
						p_trx_rec.attribute15		,
						'RA_CUSTOMER_TRX'		);


	END IF;


 	IF PG_DEBUG in ('Y', 'C') THEN
 	   arp_util.debug('AR_BILLS_CREATION_LIB_PVT.Default_Create_BR_Header ()-');
 	END IF;

EXCEPTION
    	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_LIB_PVT.Default_Create_BR_Header () ');
		END IF;
		RAISE;


END Default_Create_BR_Header;



/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Default_Update_BR_Header			                                |
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Defaults data in the BR Header during Update				|
 |										|
 +==============================================================================*/


PROCEDURE Default_Update_BR_Header ( p_trx_rec	IN OUT NOCOPY	ra_customer_trx%ROWTYPE)
IS

BEGIN

   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_CREATION_LIB_PVT.Default_Update_BR_Header()+ ');
   	END IF;

 	/*----------------------------------------------+
        |   Default the Batch Source ID			|
        +-----------------------------------------------*/

  	SELECT 	batch_source_id
	INTO	p_trx_rec.batch_source_id
	FROM	ra_customer_trx
	WHERE	customer_trx_id		=	p_trx_rec.customer_trx_id;


	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_CREATION_LIB_PVT.Default_Update_BR_Header()- ');
	END IF;

EXCEPTION
    	WHEN NO_DATA_FOUND THEN
      	   	IF PG_DEBUG in ('Y', 'C') THEN
      	   	   arp_util.debug('Default_Update_BR_Header: ' || '>>>>> No Batch Source could be defaulted for the BR');
      	   	END IF;

    	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_LIB_PVT.Default_Update_BR_Header () ');
		END IF;
		RAISE;

END Default_Update_BR_Header;



/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Default_Create_BR_Assignment                                     		|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |    Defaults data in the BR Assignment during creation :			|
 |	-  The Assigned Amount							|
 |	-  The Identifier of the exchanged transaction				|
 |										|
 +==============================================================================*/


PROCEDURE Default_Create_BR_Assignment (p_trl_rec  IN OUT NOCOPY  ra_customer_trx_lines%ROWTYPE,
					p_ps_rec   IN      ar_payment_schedules%ROWTYPE	)
IS

l_amount_due_remaining		NUMBER;
l_acctd_amount_due_remaining	NUMBER;
l_count				NUMBER;

BEGIN
   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_CREATION_LIB_PVT.Default_Create_BR_Assignment()+ ');
   	END IF;

	/*----------------------------------------------+
       	|   Check that the transaction is not already	|
	|   assigned to the BR				|
       	+-----------------------------------------------*/

	SELECT	count(*)
	INTO	l_count
	FROM	RA_CUSTOMER_TRX_LINES
	WHERE	br_ref_payment_schedule_id	=	p_ps_rec.payment_schedule_id
	AND	customer_trx_id			=	p_trl_rec.customer_trx_id;

	IF	(l_count  >  0)
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug ('Default_Create_BR_Assignment: ' || 'The transaction is already assigned to the BR');
		END IF;
		FND_MESSAGE.SET_NAME  ('AR', 'AR_BR_TRX_ASSIGNED_BR');
		FND_MESSAGE.SET_TOKEN ('TRXNUM', p_ps_rec.trx_number);
		app_exception.raise_exception;
	END IF;


	/*----------------------------------------------+
       	|   Default the assigned amount			|
       	+-----------------------------------------------*/

	IF (p_trl_rec.extended_amount IS NULL) THEN
           	p_trl_rec.extended_amount		:=	p_ps_rec.amount_due_remaining;
		p_trl_rec.extended_acctd_amount		:=	p_ps_rec.acctd_amount_due_remaining;
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('Default_Create_BR_Assignment: ' || 'Amount Defaulted       	: ' || p_trl_rec.extended_amount);
		   arp_util.debug('Default_Create_BR_Assignment: ' || 'Acctd Amount Defaulted 	: ' || p_trl_rec.extended_acctd_amount);
		END IF;
	END IF;


	/*----------------------------------------------+
       	|   Default the exchange transaction identifier	|
       	+-----------------------------------------------*/

	p_trl_rec.br_ref_customer_trx_id	:=	p_ps_rec.customer_trx_id;


 	IF PG_DEBUG in ('Y', 'C') THEN
 	   arp_util.debug('AR_BILLS_CREATION_LIB_PVT.Default_Create_BR_Assignment()-');
 	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_LIB_PVT.Default_Create_BR_Assignment () ');
		END IF;
		RAISE;

END Default_Create_BR_Assignment;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    DeAssign_BR		                                     		|
 |                                                                           	|
 | DESCRIPTION                                                              	|
 |   Deassign all the transactions of a BR					|
 |										|
 +==============================================================================*/


PROCEDURE DeAssign_BR (p_customer_trx_id   IN  ra_customer_trx.customer_trx_id%TYPE)
IS

CURSOR 	assignment_cur IS
	SELECT 	customer_trx_line_id
	FROM	ra_customer_trx_lines
	WHERE	customer_trx_id = p_customer_trx_id;

assignment_rec	assignment_cur%ROWTYPE;

l_return_status  	   VARCHAR2(1);
l_msg_count      	   NUMBER;
l_msg_data       	   VARCHAR2(2000);

BEGIN
   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_CREATION_LIB_PVT.DeAssign_BR()+ ');
   	END IF;

	FOR  assignment_rec  IN  assignment_cur LOOP

		AR_BILLS_CREATION_PUB.delete_br_assignment (
		p_api_version 			=>  1.0			,
	        x_return_status 		=>  l_return_status	,
	        x_msg_count     		=>  l_msg_count		,
	        x_msg_data     	 		=>  l_msg_data		,
		p_customer_trx_line_id		=>  assignment_rec.customer_trx_line_id);


		IF  	(l_return_status <> 'S')
		THEN
			IF PG_DEBUG in ('Y', 'C') THEN
			   arp_util.debug('DeAssign_BR: ' || '>>>>>>>>>> Problems during BR deassignment');
			   arp_util.debug('DeAssign_BR: ' || 'l_return_status : ' || l_return_status);
			END IF;
			app_exception.raise_exception;
		END IF;

	END LOOP;

   	IF PG_DEBUG in ('Y', 'C') THEN
   	   arp_util.debug('AR_BILLS_CREATION_LIB_PVT.DeAssign_BR()- ');
   	END IF;

EXCEPTION
	WHEN 	OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('>>>>>>>>>> EXCEPTION : AR_BILLS_CREATION_LIB_PVT.DeAssign_BR () ');
		END IF;
		IF	(assignment_cur%ISOPEN)
		THEN
			CLOSE	assignment_cur;
		END IF;
		RAISE;

END DeAssign_BR;


END AR_BILLS_CREATION_LIB_PVT ;

/
