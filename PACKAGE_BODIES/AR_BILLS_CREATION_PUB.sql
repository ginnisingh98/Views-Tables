--------------------------------------------------------
--  DDL for Package Body AR_BILLS_CREATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_BILLS_CREATION_PUB" AS
/* $Header: ARBRCREB.pls 120.11 2006/02/16 12:29:46 ggadhams ship $ */


/* =======================================================================
 | Global Data Types
 * ======================================================================*/

G_PKG_NAME      	CONSTANT VARCHAR2(30) 	:=  	'AR_BILLS_CREATION_PUB'			;

G_MSG_UERROR   	 	CONSTANT NUMBER        	:=  	FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR	;
G_MSG_ERROR     	CONSTANT NUMBER        	:=  	FND_MSG_PUB.G_MSG_LVL_ERROR		;
G_MSG_SUCCESS   	CONSTANT NUMBER        	:=  	FND_MSG_PUB.G_MSG_LVL_SUCCESS		;
G_MSG_HIGH      	CONSTANT NUMBER   	:=  	FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH	;
G_MSG_MEDIUM    	CONSTANT NUMBER        	:=  	FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM	;
G_MSG_LOW       	CONSTANT NUMBER        	:=  	FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW		;


/* =======================================================================
 | Bills Receivable status constants
 * ======================================================================*/

C_INCOMPLETE		CONSTANT VARCHAR2(30)	:=	'INCOMPLETE'				;
C_PENDING_ACCEPTANCE	CONSTANT VARCHAR2(30)	:=	'PENDING_ACCEPTANCE'			;
C_CANCELLED		CONSTANT VARCHAR2(30)	:=	'CANCELLED'				;


/* =======================================================================
 | Bills Receivable action constants
 * ======================================================================*/

C_DELETE		CONSTANT VARCHAR2(30)	:=	'DELETE'				;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Create_BR_Header			                                     	|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    Stores BR Header information					     	|
 |									  	|
 +==============================================================================*/


PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE Create_BR_Header (

           --   *****  Standard API parameters *****
                p_api_version      		IN  NUMBER			,
                p_init_msg_list    		IN  VARCHAR2 := FND_API.G_TRUE	,
                p_commit           		IN  VARCHAR2 := FND_API.G_FALSE	,
                p_validation_level 		IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                x_return_status    		OUT NOCOPY VARCHAR2			,
                x_msg_count        		OUT NOCOPY NUMBER			,
                x_msg_data         		OUT NOCOPY VARCHAR2			,

           --   *****  BR Header information parameters *****
		p_trx_number			IN  VARCHAR2	DEFAULT NULL	,
		p_term_due_date			IN  DATE	DEFAULT NULL	,
		p_batch_source_id		IN  NUMBER	DEFAULT NULL	,
		p_cust_trx_type_id		IN  NUMBER	DEFAULT NULL	,
		p_invoice_currency_code 	IN  VARCHAR2	DEFAULT NULL	,
		p_br_amount			IN  NUMBER	DEFAULT NULL	,
		p_trx_date			IN  DATE	DEFAULT NULL	,
		p_gl_date			IN  DATE	DEFAULT NULL	,
		p_drawee_id			IN  NUMBER	DEFAULT NULL	,
		p_drawee_site_use_id		IN  NUMBER	DEFAULT NULL	,
		p_drawee_contact_id		IN  NUMBER	DEFAULT NULL	,
		p_printing_option		IN  VARCHAR2	DEFAULT NULL	,
		p_comments			IN  VARCHAR2	DEFAULT NULL	,
		p_special_instructions		IN  VARCHAR2	DEFAULT NULL	,
		p_drawee_bank_account_id     	IN  NUMBER	DEFAULT NULL	,
		p_remittance_bank_account_id 	IN  NUMBER 	DEFAULT NULL	,
		p_override_remit_account_flag	IN  VARCHAR2	DEFAULT NULL	,
		p_batch_id			IN  NUMBER	DEFAULT NULL	,
		p_doc_sequence_id		IN  NUMBER	DEFAULT NULL	,
		p_doc_sequence_value		IN  NUMBER	DEFAULT NULL	,
		p_created_from			IN  VARCHAR2	DEFAULT NULL	,

           --   ***** Descriptive Flexfield parameters *****
                p_attribute_category		IN  VARCHAR2	DEFAULT NULL	,
		p_attribute1			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute2			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute3			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute4			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute5			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute6			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute7			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute8			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute9			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute10			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute11			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute12			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute13			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute14			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute15			IN  VARCHAR2	DEFAULT NULL	,

           --   ***** Legal Entity and SSA *****
                p_le_id                         IN  NUMBER      DEFAULT NULL    ,
                p_org_id                        IN  NUMBER      DEFAULT NULL    ,
                p_payment_trxn_extn_id          IN  NUMBER      DEFAULT NULL    ,

           --   ***** OUT NOCOPY variables *****
                p_customer_trx_id		OUT NOCOPY NUMBER			,
		p_new_trx_number		OUT NOCOPY VARCHAR2			,
		p_status			OUT NOCOPY VARCHAR2			,
                p_customer_reference            IN  VARCHAR2    DEFAULT NULL)

IS
		l_api_name			CONSTANT VARCHAR2(20)	:=	'Create_BR_Header';
		l_api_version			CONSTANT NUMBER		:=	1.0;

		l_trx_rec			ra_customer_trx%ROWTYPE;
		l_trh_rec			ar_transaction_history%ROWTYPE;

		l_gl_date			DATE				;

		l_customer_trx_id		NUMBER				;
		l_new_trx_number		VARCHAR2(20)			;
		l_status			VARCHAR2(30)			;


BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_CREATION_PUB.Create_BR_Header()+ ');
	END IF;

	x_msg_count				:=	NULL;
	x_msg_data				:=	NULL;

       /*-----------------------------------------------+
        |   Standard start of API savepoint     	|
        +-----------------------------------------------*/

      	SAVEPOINT Create_BR_Header_PVT;


       /*-----------------------------------------------+
        | Standard call to check for call compatibility |
        +-----------------------------------------------*/

        IF NOT FND_API.Compatible_API_Call( l_api_version	,
                                            p_api_version	,
                                            l_api_name		,
                                            G_PKG_NAME          )
        THEN
        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


       /*-----------------------------------------------+
        |   Initialize return status to SUCCESS   	|
        +-----------------------------------------------*/

        x_return_status := FND_API.G_RET_STS_SUCCESS;


       /*-----------------------------------------------+
        |   ========  START OF API BODY  ============   |
        +-----------------------------------------------*/


       /*-----------------------------------------------+
        |   Data preparation 				|
        +-----------------------------------------------*/

	l_trx_rec.trx_number			:=	p_trx_number			;
	l_trx_rec.term_due_date			:=	trunc(p_term_due_date)		;
	l_trx_rec.batch_source_id		:=	p_batch_source_id		;
	l_trx_rec.cust_trx_type_id		:=	p_cust_trx_type_id		;
	l_trx_rec.invoice_currency_code 	:=	p_invoice_currency_code		;
	l_trx_rec.br_amount			:=	p_br_amount			;
	l_trx_rec.trx_date			:=	trunc(p_trx_date)		;
	l_trx_rec.drawee_id			:=	p_drawee_id			;
	l_trx_rec.drawee_site_use_id		:=	p_drawee_site_use_id		;
	l_trx_rec.drawee_contact_id		:=	p_drawee_contact_id		;
	l_trx_rec.printing_option		:=	p_printing_option		;
	l_trx_rec.comments			:=	p_comments			;
	l_trx_rec.special_instructions		:=	p_special_instructions		;
	l_trx_rec.drawee_bank_account_id     	:=	p_drawee_bank_account_id	;
	l_trx_rec.remit_bank_acct_use_id	:=	p_remittance_bank_account_id	;
	l_trx_rec.override_remit_account_flag	:=	p_override_remit_account_flag	;
	l_trx_rec.batch_id			:=	p_batch_id			;
	l_trx_rec.doc_sequence_id		:=	p_doc_sequence_id		;
	l_trx_rec.doc_sequence_value		:=	p_doc_sequence_value		;
	l_trx_rec.created_from			:=	p_created_from			;
	l_trx_rec.attribute_category		:=	p_attribute_category		;
	l_trx_rec.attribute1			:=	p_attribute1			;
	l_trx_rec.attribute2			:=	p_attribute2			;
	l_trx_rec.attribute3			:=	p_attribute3			;
	l_trx_rec.attribute4			:=	p_attribute4			;
	l_trx_rec.attribute5			:=	p_attribute5			;
	l_trx_rec.attribute6			:=	p_attribute6			;
	l_trx_rec.attribute7			:=	p_attribute7			;
	l_trx_rec.attribute8			:=	p_attribute8			;
	l_trx_rec.attribute9			:=	p_attribute9			;
	l_trx_rec.attribute10			:=	p_attribute10			;
	l_trx_rec.attribute11			:=	p_attribute11			;
	l_trx_rec.attribute12			:=	p_attribute12			;
	l_trx_rec.attribute13			:=	p_attribute13			;
	l_trx_rec.attribute14			:=	p_attribute14			;
	l_trx_rec.attribute15			:=	p_attribute15			;
        l_trx_rec.legal_entity_id               :=      p_le_id                         ;
        l_trx_rec.org_id                        :=      p_org_id                        ;
        /* PAYMENT_UPTAKE */
        l_trx_rec.payment_trxn_extension_id     :=      p_payment_trxn_extn_id          ;

	l_trx_rec.complete_flag			:=	'N'				;
	l_trx_rec.status_trx			:=	'OP'				;
	l_trx_rec.br_unpaid_flag		:=	'N'				;
	l_trx_rec.br_on_hold_flag		:=	'N'				;
        l_trx_rec.customer_reference            :=      p_customer_reference            ;

	l_gl_date				:=	trunc(p_gl_date)		;



	/*----------------------------------------------+
        |   Data Defaulting 				|
        +-----------------------------------------------*/

    	AR_BILLS_CREATION_LIB_PVT.Default_Create_BR_Header (l_trx_rec, l_gl_date);


       /*-----------------------------------------------+
        |   Data Validation				|
        +-----------------------------------------------*/

        AR_BILLS_CREATION_VAL_PVT.Validate_Create_BR_Header(l_trx_rec, l_gl_date);


       /*-----------------------------------------------+
        |   Call the Entity Handler  			|
        +-----------------------------------------------*/

	ARP_PROCESS_BR_HEADER.insert_header  (  l_trx_rec		,
						l_gl_date		,
						l_new_trx_number	,
						l_customer_trx_id	);


	/*-----------------------------------------------+
        |   Output parameters	  			|
        +-----------------------------------------------*/

	l_trh_rec.customer_trx_id	:=	l_customer_trx_id;
	ARP_TRANSACTION_HISTORY_PKG.fetch_f_trx_id (l_trh_rec);

	p_customer_trx_id		:=	l_customer_trx_id;
	p_new_trx_number		:=	l_new_trx_number ;
	p_status			:= 	l_trh_rec.status ;


       /*-----------------------------------------------+
        |   Standard check of p_commit   		|
        +-----------------------------------------------*/

        IF FND_API.To_Boolean( p_commit )
        THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug(  'committing');
            END IF;
            Commit;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('AR_BILLS_CREATION_PUB.Create_BR_Header()- ');
        END IF;


EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug (  'SQLERRM : ' || SQLERRM);
		   arp_util.debug (  'SQLCODE : ' || SQLCODE);
		END IF;
                ROLLBACK TO Create_BR_Header_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
  	        IF PG_DEBUG in ('Y', 'C') THEN
  	           arp_util.debug(  'Exception Error');
  	        END IF;
		RAISE;


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug (  'SQLERRM : ' || SQLERRM);
		   arp_util.debug (  'SQLCODE : ' || SQLCODE);
		END IF;
                ROLLBACK TO Create_BR_Header_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug(  'Exception Unexpected Error');
		END IF;
		RAISE;


        WHEN OTHERS THEN

               /*-------------------------------------------------------+
                |  Handle application errors that result from trapable  |
                |  error conditions. The error messages have already    |
                |  been put on the error stack.                         |
                +-------------------------------------------------------*/

		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug (  'SQLERRM : ' || SQLERRM);
		   arp_util.debug (  'SQLCODE : ' || SQLCODE);
		END IF;

	      	ROLLBACK TO Create_BR_Header_PVT;

		IF (SQLCODE = -20001)
                THEN
                     	x_return_status := FND_API.G_RET_STS_ERROR ;
                ELSE
               	      	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                END IF;

		RAISE;

END Create_BR_Header;



/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Update_BR_Header			                                     	|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    Updates BR Header information					     	|
 |									  	|
 +==============================================================================*/


PROCEDURE Update_BR_Header (

           --   *****  Standard API parameters *****
                p_api_version      		IN  NUMBER			,
                p_init_msg_list    		IN  VARCHAR2 := FND_API.G_TRUE	,
                p_commit           		IN  VARCHAR2 := FND_API.G_FALSE	,
                p_validation_level 		IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                x_return_status    		OUT NOCOPY VARCHAR2			,
                x_msg_count        		OUT NOCOPY NUMBER			,
                x_msg_data         		OUT NOCOPY VARCHAR2			,

           --   *****  BR Header info. parameters *****
		p_customer_trx_id		IN  NUMBER	DEFAULT NULL	,
		p_term_due_date			IN  DATE	DEFAULT NULL	,
		p_cust_trx_type_id		IN  NUMBER	DEFAULT NULL	,
		p_invoice_currency_code 	IN  VARCHAR2	DEFAULT NULL	,
		p_br_amount			IN  NUMBER	DEFAULT NULL	,
		p_trx_date			IN  DATE	DEFAULT NULL	,
		p_gl_date			IN  DATE	DEFAULT NULL	,
		p_drawee_id			IN  NUMBER	DEFAULT NULL	,
		p_drawee_site_use_id		IN  NUMBER	DEFAULT NULL	,
		p_drawee_contact_id		IN  NUMBER	DEFAULT NULL	,
		p_printing_option		IN  VARCHAR2	DEFAULT NULL	,
		p_comments			IN  VARCHAR2	DEFAULT NULL	,
		p_special_instructions		IN  VARCHAR2	DEFAULT NULL	,
		p_drawee_bank_account_id     	IN  NUMBER	DEFAULT NULL	,
		p_remittance_bank_account_id 	IN  NUMBER 	DEFAULT NULL	,
		p_override_remit_account_flag	IN  VARCHAR2	DEFAULT NULL	,
		p_doc_sequence_id		IN  NUMBER	DEFAULT NULL	,
		p_doc_sequence_value		IN  NUMBER	DEFAULT NULL	,
		p_created_from			IN  VARCHAR2	DEFAULT NULL	,

           --   ***** Descriptive Flexfield parameters *****
                p_attribute_category		IN  VARCHAR2	DEFAULT NULL	,
		p_attribute1			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute2			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute3			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute4			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute5			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute6			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute7			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute8			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute9			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute10			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute11			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute12			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute13			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute14			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute15			IN  VARCHAR2	DEFAULT NULL	,
                p_customer_reference            IN  VARCHAR2    DEFAULT NULL    ,
                p_le_id                         IN  NUMBER      DEFAULT NULL    ,
                p_payment_trxn_extn_id          IN  NUMBER      DEFAULT NULL)

IS
		l_api_name			CONSTANT VARCHAR2(20)	:=	'Update_BR_Header';
		l_api_version			CONSTANT NUMBER		:=	1.0;

		l_trx_rec			ra_customer_trx%ROWTYPE;
		l_trh_rec			ar_transaction_history%ROWTYPE;
		l_ps_rec			ar_payment_schedules%ROWTYPE;

		l_gl_date			DATE		;

BEGIN

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('AR_BILLS_CREATION_PUB.Update_BR_Header()+ ');
        END IF;

	x_msg_count				:=	NULL;
	x_msg_data				:=	NULL;

       /*-----------------------------------------------+
        |   Standard start of API savepoint     	|
        +-----------------------------------------------*/

      	SAVEPOINT Update_BR_Header_PVT;


       /*-----------------------------------------------+
        | Standard call to check for call compatibility |
        +-----------------------------------------------*/

        IF NOT FND_API.Compatible_API_Call(
                                            l_api_version	,
                                            p_api_version	,
                                            l_api_name		,
                                            G_PKG_NAME          )
        THEN
        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


       /*-----------------------------------------------+
        |   Initialize return status to SUCCESS   	|
        +-----------------------------------------------*/

        x_return_status := FND_API.G_RET_STS_SUCCESS;


       /*-----------------------------------------------+
        |   ========  START OF API BODY  ============   |
        +-----------------------------------------------*/

	AR_BILLS_CREATION_VAL_PVT.Validate_Customer_Trx_ID (p_customer_trx_id);

       /*-----------------------------------------------+
        |   Data preparation 				|
        +-----------------------------------------------*/

	ARP_CT_PKG.set_to_dummy (l_trx_rec);

	l_trx_rec.customer_trx_id		:=	p_customer_trx_id		;
	l_trx_rec.term_due_date			:=	trunc(p_term_due_date)		;
	l_trx_rec.cust_trx_type_id		:=	p_cust_trx_type_id		;
	l_trx_rec.invoice_currency_code 	:=	p_invoice_currency_code		;
	l_trx_rec.br_amount			:=	p_br_amount			;
	l_trx_rec.trx_date			:=	trunc(p_trx_date)		;
	l_trx_rec.drawee_id			:=	p_drawee_id			;
	l_trx_rec.drawee_site_use_id		:=	p_drawee_site_use_id		;
	l_trx_rec.drawee_contact_id		:=	p_drawee_contact_id		;
	l_trx_rec.printing_option		:=	p_printing_option		;
	l_trx_rec.comments			:=	p_comments			;
	l_trx_rec.special_instructions		:=	p_special_instructions		;
	l_trx_rec.drawee_bank_account_id     	:=	p_drawee_bank_account_id	;
	l_trx_rec.remit_bank_acct_use_id	:=	p_remittance_bank_account_id	;
	l_trx_rec.override_remit_account_flag	:=	p_override_remit_account_flag	;
	l_trx_rec.doc_sequence_id		:=	p_doc_sequence_id		;
	l_trx_rec.doc_sequence_value		:=	p_doc_sequence_value		;
	l_trx_rec.created_from			:=	p_created_from			;
	l_trx_rec.attribute_category		:=	p_attribute_category		;
	l_trx_rec.attribute1			:=	p_attribute1			;
	l_trx_rec.attribute2			:=	p_attribute2			;
	l_trx_rec.attribute3			:=	p_attribute3			;
	l_trx_rec.attribute4			:=	p_attribute4			;
	l_trx_rec.attribute5			:=	p_attribute5			;
	l_trx_rec.attribute6			:=	p_attribute6			;
	l_trx_rec.attribute7			:=	p_attribute7			;
	l_trx_rec.attribute8			:=	p_attribute8			;
	l_trx_rec.attribute9			:=	p_attribute9			;
	l_trx_rec.attribute10			:=	p_attribute10			;
	l_trx_rec.attribute11			:=	p_attribute11			;
	l_trx_rec.attribute12			:=	p_attribute12			;
	l_trx_rec.attribute13			:=	p_attribute13			;
	l_trx_rec.attribute14			:=	p_attribute14			;
	l_trx_rec.attribute15			:=	p_attribute15			;
        l_trx_rec.customer_reference            :=      p_customer_reference            ;
        l_trx_rec.legal_entity_id               :=      p_le_id                         ;
        /* PAYMENT_UPTAKE */
        l_trx_rec.payment_trxn_extension_id     :=      p_payment_trxn_extn_id          ;

	l_gl_date				:=	trunc(p_gl_date);

	/*----------------------------------------------+
        |   Data Defaulting 				|
        +-----------------------------------------------*/

	AR_BILLS_CREATION_LIB_PVT.Default_Update_BR_Header  (l_trx_rec);


       /*-----------------------------------------------+
        |   Data Validation				|
        +-----------------------------------------------*/

        AR_BILLS_CREATION_VAL_PVT.Validate_Update_BR_Header (l_trx_rec,	l_gl_date);


       /*-----------------------------------------------+
        |   Call the Entity Handler for BR Header	|
        +-----------------------------------------------*/

	ARP_PROCESS_BR_HEADER.update_header  (  l_trx_rec, l_trx_rec.customer_trx_id);


       /*-----------------------------------------------+
        |   Call the Entity Handler for BR History    	|
        +-----------------------------------------------*/

	l_trh_rec.customer_trx_id		:=	p_customer_trx_id		;
	ARP_TRANSACTION_HISTORY_PKG.lock_fetch_f_trx_id (l_trh_rec);

	l_trh_rec.customer_trx_id		:=	l_trx_rec.customer_trx_id	;
	l_trh_rec.gl_date			:=	l_gl_date			;
	l_trh_rec.trx_date			:=	l_trx_rec.trx_date		;
	l_trh_rec.comments			:=	l_trx_rec.comments		;


	IF  (l_trh_rec.maturity_date <> l_trx_rec.term_due_date)
	THEN
		l_trh_rec.maturity_date   	:=	l_trx_rec.term_due_date;
		l_trh_rec.event			:=	'MATURITY_DATE_UPDATED';
		l_trh_rec.current_record_flag	:=  	'Y'		;
		l_trh_rec.prv_trx_history_id	:=  	NULL		;
		l_trh_rec.comments		:=  	NULL		;
		l_trh_rec.posting_control_id    := 	-3           	;
		l_trh_rec.gl_posted_date        :=  	NULL        	;
		l_trh_rec.first_posted_record_flag := 	'N'		;
		l_trh_rec.batch_id		:=	NULL		;
		l_trh_rec.postable_flag		:=	'N'		;
		l_trh_rec.current_accounted_flag:=	'N'		;
		ARP_PROC_TRANSACTION_HISTORY.insert_transaction_history (l_trh_rec,
								 	 l_trh_rec.transaction_history_id);

		IF  (l_trh_rec.status not in (C_INCOMPLETE, C_PENDING_ACCEPTANCE, C_CANCELLED))
		THEN
			AR_BILLS_CREATION_LIB_PVT.Get_Payment_Schedule_Id (p_customer_trx_id, l_ps_rec.payment_schedule_id);
			arp_ps_pkg.lock_p(l_ps_rec.payment_schedule_id);
			arp_ps_pkg.set_to_dummy (l_ps_rec);
			l_ps_rec.due_date		:=	l_trx_rec.term_due_date;
			arp_ps_pkg.update_p (l_ps_rec, l_ps_rec.payment_schedule_id);
		END IF;
	ELSE
		ARP_PROC_TRANSACTION_HISTORY.update_transaction_history (l_trh_rec,
								 	 l_trh_rec.transaction_history_id);
	END IF;


       /*-----------------------------------------------+
        |   Update the Payment Schedule Information    	|
        +-----------------------------------------------*/

	IF  (l_trh_rec.status not in (C_INCOMPLETE, C_PENDING_ACCEPTANCE, C_CANCELLED))
	THEN
		AR_BILLS_CREATION_LIB_PVT.Get_Payment_Schedule_Id (p_customer_trx_id, l_ps_rec.payment_schedule_id);
		arp_ps_pkg.lock_p(l_ps_rec.payment_schedule_id);
		arp_ps_pkg.set_to_dummy (l_ps_rec);
		l_ps_rec.cust_trx_type_id	:=	l_trx_rec.cust_trx_type_id	;
		l_ps_rec.due_date		:=	l_trx_rec.term_due_date		;
		l_ps_rec.gl_date		:=	l_trh_rec.gl_date		;
		l_ps_rec.customer_site_use_id	:=	l_trx_rec.drawee_site_use_id	;
		l_ps_rec.trx_date		:=	l_trx_rec.trx_date		;
		arp_ps_pkg.update_p (l_ps_rec, l_ps_rec.payment_schedule_id);
	END IF;



       /*-----------------------------------------------+
        |   Standard check of p_commit   		|
        +-----------------------------------------------*/

        IF FND_API.To_Boolean( p_commit )
        THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug(  'committing');
            END IF;
            Commit;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('AR_BILLS_CREATION_PUB.Update_BR_Header()- ');
        END IF;

EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug (  'SQLERRM : ' || SQLERRM);
		   arp_util.debug (  'SQLCODE : ' || SQLCODE);
		END IF;
                ROLLBACK TO Update_BR_Header_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
  	        IF PG_DEBUG in ('Y', 'C') THEN
  	           arp_util.debug(  'Exception Error');
  	        END IF;
		RAISE;


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug (  'SQLERRM : ' || SQLERRM);
		   arp_util.debug (  'SQLCODE : ' || SQLCODE);
		END IF;
                ROLLBACK TO Update_BR_Header_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug(  'Exception Unexpected Error');
		END IF;
		RAISE;


        WHEN OTHERS THEN

               /*-------------------------------------------------------+
                |  Handle application errors that result from trapable  |
                |  error conditions. The error messages have already    |
                |  been put on the error stack.                         |
                +-------------------------------------------------------*/

		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug (  'SQLERRM : ' || SQLERRM);
		   arp_util.debug (  'SQLCODE : ' || SQLCODE);
		END IF;

                ROLLBACK TO Update_BR_Header_PVT;

		IF (SQLCODE = -20001)
                THEN
                     	x_return_status := FND_API.G_RET_STS_ERROR ;
                ELSE
               	      	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                END IF;

		RAISE;

END Update_BR_Header;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Delete_BR_Header			                                     	|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    Delete BR Header information					     	|
 |									  	|
 +==============================================================================*/

PROCEDURE Delete_BR_Header (

           --   *****  Standard API parameters *****
                p_api_version      		IN  NUMBER			,
                p_init_msg_list    		IN  VARCHAR2 := FND_API.G_TRUE	,
                p_commit           		IN  VARCHAR2 := FND_API.G_FALSE	,
                p_validation_level 		IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                x_return_status    		OUT NOCOPY VARCHAR2			,
                x_msg_count        		OUT NOCOPY NUMBER			,
                x_msg_data         		OUT NOCOPY VARCHAR2			,

           --   *****  BR Header info. parameters *****
		p_customer_trx_id		IN  NUMBER	DEFAULT NULL	)

IS
		l_api_name			CONSTANT VARCHAR2(20)	:=	'Delete_BR_Header';
		l_api_version			CONSTANT NUMBER		:=	1.0;

		l_complete_flag			VARCHAR2(1);
		l_uncomplete_flag		VARCHAR2(1);
		l_accept_flag			VARCHAR2(1);
	     	l_cancel_flag			VARCHAR2(1);
		l_select_remit_flag		VARCHAR2(1);
		l_deselect_remit_flag		VARCHAR2(1);
		l_approve_remit_flag		VARCHAR2(1);
		l_hold_flag			VARCHAR2(1);
		l_unhold_flag			VARCHAR2(1);
		l_recall_flag			VARCHAR2(1);
		l_eliminate_flag		VARCHAR2(1);
		l_uneliminate_flag		VARCHAR2(1);
		l_unpaid_flag			VARCHAR2(1);
		l_protest_flag			VARCHAR2(1);
		l_endorse_flag			VARCHAR2(1);
		l_restate_flag			VARCHAR2(1);
		l_exchange_flag			VARCHAR2(1);
		l_delete_flag			VARCHAR2(1);

		l_trx_rec			ra_customer_trx%ROWTYPE;

BEGIN

       	IF PG_DEBUG in ('Y', 'C') THEN
       	   arp_util.debug('AR_BILLS_CREATION_PUB.Delete_BR_Header()+ ');
       	END IF;

	x_msg_count				:=	NULL;
	x_msg_data				:=	NULL;

       /*-----------------------------------------------+
        |   Standard start of API savepoint     	|
        +-----------------------------------------------*/

      	SAVEPOINT Delete_BR_Header_PVT;


       /*-----------------------------------------------+
        | Standard call to check for call compatibility |
        +-----------------------------------------------*/

        IF NOT FND_API.Compatible_API_Call(
                                            l_api_version	,
                                            p_api_version	,
                                            l_api_name		,
                                            G_PKG_NAME
                                          )
        THEN
        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


       /*-----------------------------------------------+
        |   Initialize return status to SUCCESS   	|
        +-----------------------------------------------*/

        x_return_status := FND_API.G_RET_STS_SUCCESS;


       /*-----------------------------------------------+
        |   ========  START OF API BODY  ============   |
        +-----------------------------------------------*/


       /*-----------------------------------------------+
        |   Action Validation				|
        +-----------------------------------------------*/


	AR_BILLS_MAINTAIN_STATUS_PUB.validate_actions (
		p_customer_trx_id	=>  	p_customer_trx_id	,
		p_complete_flag		=>	l_complete_flag		,
		p_uncomplete_flag	=>	l_uncomplete_flag	,
		p_accept_flag		=>	l_accept_flag		,
		p_cancel_flag		=>	l_cancel_flag		,
		p_select_remit_flag	=>	l_select_remit_flag	,
		p_deselect_remit_flag	=>	l_deselect_remit_flag	,
		p_approve_remit_flag	=>	l_approve_remit_flag	,
		p_hold_flag		=>	l_hold_flag		,
		p_unhold_flag		=>	l_unhold_flag		,
		p_recall_flag		=>	l_recall_flag		,
		p_eliminate_flag	=>	l_eliminate_flag	,
		p_uneliminate_flag	=>	l_uneliminate_flag	,
		p_unpaid_flag		=>	l_unpaid_flag		,
		p_protest_flag		=>	l_protest_flag		,
		p_endorse_flag		=>	l_endorse_flag		,
		p_restate_flag		=>	l_restate_flag		,
		p_exchange_flag		=>	l_exchange_flag		,
		p_delete_flag		=>	l_delete_flag		);


	-- Do not continue if the action is not allowed for the BR


	IF	(l_delete_flag	<>	'Y')
	THEN
		ARP_CT_PKG.fetch_p (l_trx_rec, p_customer_trx_id);
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug(  '>>>>>>>>>> The Action Delete is not allowed on the BR ' || p_customer_trx_id);
		END IF;
		FND_MESSAGE.set_name	( 'AR', 'AR_BR_ACTION_FORBIDDEN' );
		FND_MESSAGE.set_token	( 'ACTION', C_DELETE);
		FND_MESSAGE.set_token	( 'BRNUM' , l_trx_rec.trx_number);
		app_exception.raise_exception;
	END IF;


	/*-----------------------------------------------+
        |   Deassign the exchanged transactions		 |
        +-----------------------------------------------*/

	AR_BILLS_CREATION_LIB_PVT.Deassign_BR (p_customer_trx_id);


       /*-----------------------------------------------+
        |   Call the Entity Handler for BR Header     	|
        +-----------------------------------------------*/

	ARP_PROCESS_BR_HEADER.delete_header  (p_customer_trx_id);


       /*-----------------------------------------------+
        |   Standard check of p_commit   		|
        +-----------------------------------------------*/

        IF FND_API.To_Boolean( p_commit )
        THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug(  'committing');
            END IF;
            Commit;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('AR_BILLS_CREATION_PUB.Delete_BR_Header()- ');
        END IF;


EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN

		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug (  'SQLERRM : ' || SQLERRM);
		   arp_util.debug (  'SQLCODE : ' || SQLCODE);
		END IF;
                ROLLBACK TO Delete_BR_Header_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
  	        IF PG_DEBUG in ('Y', 'C') THEN
  	           arp_util.debug(  'Exception Error');
  	        END IF;
		RAISE;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug (  'SQLERRM : ' || SQLERRM);
		   arp_util.debug (  'SQLCODE : ' || SQLCODE);
		END IF;
                ROLLBACK TO Delete_BR_Header_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug(  'Exception Unexpected Error');
		END IF;
		RAISE;

        WHEN OTHERS THEN

               /*-------------------------------------------------------+
                |  Handle application errors that result from trapable  |
                |  error conditions. The error messages have already    |
                |  been put on the error stack.                         |
                +-------------------------------------------------------*/

		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug (  'SQLERRM : ' || SQLERRM);
		   arp_util.debug (  'SQLCODE : ' || SQLCODE);
		END IF;

		ROLLBACK TO Delete_BR_Header_PVT;

		IF (SQLCODE = -20001)
                THEN
                     	x_return_status := FND_API.G_RET_STS_ERROR ;
                ELSE
               	      	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                END IF;

		RAISE;

END Delete_BR_Header;



/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Lock_BR_Header			                                     	|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    Locks BR Header information					     	|
 |									  	|
 +==============================================================================*/


PROCEDURE Lock_BR_Header (

           --   *****  Standard API parameters *****
                p_api_version      		IN  NUMBER			,
                p_init_msg_list    		IN  VARCHAR2 := FND_API.G_TRUE	,
                p_commit           		IN  VARCHAR2 := FND_API.G_FALSE	,
                p_validation_level 		IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                x_return_status    		OUT NOCOPY VARCHAR2			,
                x_msg_count        		OUT NOCOPY NUMBER			,
                x_msg_data         		OUT NOCOPY VARCHAR2			,

           --   *****  BR Header info. parameters *****
		p_customer_trx_id		IN  NUMBER	DEFAULT NULL	,
		p_term_due_date			IN  DATE	DEFAULT NULL	,
		p_cust_trx_type_id		IN  NUMBER	DEFAULT NULL	,
		p_invoice_currency_code 	IN  VARCHAR2	DEFAULT NULL	,
		p_br_amount			IN  NUMBER	DEFAULT NULL	,
		p_trx_date			IN  DATE	DEFAULT NULL	,
		p_gl_date			IN  DATE	DEFAULT NULL	,
		p_drawee_id			IN  NUMBER	DEFAULT NULL	,
		p_drawee_site_use_id		IN  NUMBER	DEFAULT NULL	,
		p_drawee_contact_id		IN  NUMBER	DEFAULT NULL	,
		p_printing_option		IN  VARCHAR2	DEFAULT NULL	,
		p_comments			IN  VARCHAR2	DEFAULT NULL	,
		p_special_instructions		IN  VARCHAR2	DEFAULT NULL	,
		p_drawee_bank_account_id     	IN  NUMBER	DEFAULT NULL	,
		p_remittance_bank_account_id 	IN  NUMBER 	DEFAULT NULL	,
		p_override_remit_account_flag	IN  VARCHAR2	DEFAULT NULL	,
		p_doc_sequence_id		IN  NUMBER	DEFAULT NULL	,
		p_doc_sequence_value		IN  NUMBER	DEFAULT NULL	,
		p_created_from			IN  VARCHAR2	DEFAULT NULL	,

           --   ***** Descriptive Flexfield parameters *****
                p_attribute_category		IN  VARCHAR2	DEFAULT NULL	,
		p_attribute1			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute2			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute3			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute4			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute5			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute6			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute7			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute8			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute9			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute10			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute11			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute12			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute13			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute14			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute15			IN  VARCHAR2	DEFAULT NULL	,
                p_customer_reference            IN  VARCHAR2    DEFAULT NULL    )
IS
		l_api_name			CONSTANT VARCHAR2(20)	:=	'Lock_BR_Header';
		l_api_version			CONSTANT NUMBER		:=	1.0;

		l_trx_rec			ra_customer_trx%ROWTYPE;



BEGIN

      	IF PG_DEBUG in ('Y', 'C') THEN
      	   arp_util.debug('AR_BILLS_CREATION_PUB.Lock_BR_Header()+ ');
      	END IF;

	x_msg_count				:=	NULL;
	x_msg_data				:=	NULL;


       /*-----------------------------------------------+
        |   Standard start of API savepoint     	|
        +-----------------------------------------------*/

      	SAVEPOINT Lock_BR_Header_PVT;


       /*-----------------------------------------------+
        | Standard call to check for call compatibility |
        +-----------------------------------------------*/

        IF NOT FND_API.Compatible_API_Call(
                                            l_api_version	,
                                            p_api_version	,
                                            l_api_name		,
                                            G_PKG_NAME
                                          )
        THEN
        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


       /*-----------------------------------------------+
        |   Initialize return status to SUCCESS   	|
        +-----------------------------------------------*/

        x_return_status := FND_API.G_RET_STS_SUCCESS;


       /*-----------------------------------------------+
        |   ========  START OF API BODY  ============   |
        +-----------------------------------------------*/

	AR_BILLS_CREATION_VAL_PVT.Validate_Customer_Trx_ID (p_customer_trx_id);

       /*-----------------------------------------------+
        |   Data preparation 				|
        +-----------------------------------------------*/

	ARP_CT_PKG.set_to_dummy (l_trx_rec);

	l_trx_rec.customer_trx_id		:=	p_customer_trx_id		;
	l_trx_rec.term_due_date			:=	trunc(p_term_due_date)		;
	l_trx_rec.cust_trx_type_id		:=	p_cust_trx_type_id		;
	l_trx_rec.invoice_currency_code 	:=	p_invoice_currency_code		;
	l_trx_rec.br_amount			:=	p_br_amount			;
	l_trx_rec.trx_date			:=	trunc(p_trx_date)		;
	l_trx_rec.drawee_id			:=	p_drawee_id			;
	l_trx_rec.drawee_site_use_id		:=	p_drawee_site_use_id		;
	l_trx_rec.drawee_contact_id		:=	p_drawee_contact_id		;
	l_trx_rec.printing_option		:=	p_printing_option		;
	l_trx_rec.comments			:=	p_comments			;
	l_trx_rec.special_instructions		:=	p_special_instructions		;
	l_trx_rec.drawee_bank_account_id     	:=	p_drawee_bank_account_id	;
	l_trx_rec.remit_bank_acct_use_id	:=	p_remittance_bank_account_id	;
	l_trx_rec.override_remit_account_flag	:=	p_override_remit_account_flag	;
	l_trx_rec.doc_sequence_id		:=	p_doc_sequence_id		;
	l_trx_rec.doc_sequence_value		:=	p_doc_sequence_value		;
	l_trx_rec.created_from			:=	p_created_from			;
	l_trx_rec.attribute_category		:=	p_attribute_category		;
	l_trx_rec.attribute1			:=	p_attribute1			;
	l_trx_rec.attribute2			:=	p_attribute2			;
	l_trx_rec.attribute3			:=	p_attribute3			;
	l_trx_rec.attribute4			:=	p_attribute4			;
	l_trx_rec.attribute5			:=	p_attribute5			;
	l_trx_rec.attribute6			:=	p_attribute6			;
	l_trx_rec.attribute7			:=	p_attribute7			;
	l_trx_rec.attribute8			:=	p_attribute8			;
	l_trx_rec.attribute9			:=	p_attribute9			;
	l_trx_rec.attribute10			:=	p_attribute10			;
	l_trx_rec.attribute11			:=	p_attribute11			;
	l_trx_rec.attribute12			:=	p_attribute12			;
	l_trx_rec.attribute13			:=	p_attribute13			;
	l_trx_rec.attribute14			:=	p_attribute14			;
	l_trx_rec.attribute15			:=	p_attribute15			;
        l_trx_rec.customer_reference            :=      p_customer_reference            ;

       /*-----------------------------------------------+
        |   Call the Table Handler    			|
        +-----------------------------------------------*/

	ARP_CT_PKG.lock_compare_p( l_trx_rec, p_customer_trx_id);

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('AR_BILLS_CREATION_PUB.Lock_BR_Header()- ');
        END IF;


EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN

		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug (  'SQLERRM : ' || SQLERRM);
		   arp_util.debug (  'SQLCODE : ' || SQLCODE);
		END IF;
                ROLLBACK TO Lock_BR_Header_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
  	        IF PG_DEBUG in ('Y', 'C') THEN
  	           arp_util.debug(  'Exception Error');
  	        END IF;
		RAISE;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug (  'SQLERRM : ' || SQLERRM);
		   arp_util.debug (  'SQLCODE : ' || SQLCODE);
		END IF;
                ROLLBACK TO Lock_BR_Header_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug(  'Exception Unexpected Error');
		END IF;
		RAISE;

        WHEN OTHERS THEN

               /*-------------------------------------------------------+
                |  Handle application errors that result from trapable  |
                |  error conditions. The error messages have already    |
                |  been put on the error stack.                         |
                +-------------------------------------------------------*/

		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug (  'SQLERRM : ' || SQLERRM);
		   arp_util.debug (  'SQLCODE : ' || SQLCODE);
		END IF;


                ROLLBACK TO Lock_BR_Header_PVT;

                IF (SQLCODE = -20001)
                THEN
                      	x_return_status := FND_API.G_RET_STS_ERROR ;
                ELSE
               	   	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                END IF;

		RAISE;

END Lock_BR_Header;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Create_BR_Assignment			                               	|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    Stores BR Assignment information					     	|
 |									  	|
 | 25-MAY-05	V Crisostomo	SSA-R12 : add p_org_id                          |
 +==============================================================================*/


PROCEDURE Create_BR_Assignment (

           --   *****  Standard API parameters *****
                p_api_version      		IN  NUMBER			,
                p_init_msg_list    		IN  VARCHAR2 := FND_API.G_TRUE	,
                p_commit           		IN  VARCHAR2 := FND_API.G_FALSE	,
                p_validation_level 		IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                x_return_status    		OUT NOCOPY VARCHAR2			,
                x_msg_count        		OUT NOCOPY NUMBER			,
                x_msg_data         		OUT NOCOPY VARCHAR2			,

           --   *****  BR Assignment information parameters *****
		p_customer_trx_id		IN  NUMBER	DEFAULT NULL	,
		p_br_ref_payment_schedule_id	IN  NUMBER	DEFAULT NULL	,
		p_assigned_amount		IN  NUMBER	DEFAULT NULL	,

           --   ***** Descriptive Flexfield parameters *****
                p_attribute_category		IN  VARCHAR2	DEFAULT NULL	,
		p_attribute1			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute2			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute3			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute4			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute5			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute6			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute7			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute8			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute9			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute10			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute11			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute12			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute13			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute14			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute15			IN  VARCHAR2	DEFAULT NULL	,

           --   ***** SSA  *****
                p_org_id                        IN  NUMBER      DEFAULT NULL    ,

           --   ***** OUT NOCOPY variables *****
                p_customer_trx_line_id		OUT NOCOPY NUMBER 			)


IS
		l_api_name			CONSTANT VARCHAR2(20)	:=	'Create_BR_Assignment';
		l_api_version			CONSTANT NUMBER		:=	1.0;
		l_trl_rec			ra_customer_trx_lines%ROWTYPE	;
		l_ps_rec			ar_payment_schedules%ROWTYPE	;
		l_trx_rec			ra_customer_trx%ROWTYPE		;
		l_BR_rec			ra_customer_trx%ROWTYPE		;
		l_customer_trx_line_id		NUMBER				;
		l_trh_rec			ar_transaction_history%ROWTYPE	;

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_CREATION_PUB.Create_BR_Assignment()+ ');
	END IF;

	x_msg_count				:=	NULL;
	x_msg_data				:=	NULL;


       /*-----------------------------------------------+
        |   Standard start of API savepoint     	|
        +-----------------------------------------------*/

    	SAVEPOINT Create_BR_Assignment_PVT;

       /*-----------------------------------------------+
        | Standard call to check for call compatibility |
        +-----------------------------------------------*/

        IF NOT FND_API.Compatible_API_Call( l_api_version	,
                                            p_api_version	,
                                            l_api_name		,
                                            G_PKG_NAME          )
        THEN
        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


       /*-----------------------------------------------+
        |   Initialize return status to SUCCESS   	|
        +-----------------------------------------------*/

        x_return_status := FND_API.G_RET_STS_SUCCESS;


       /*-----------------------------------------------+
        |   ========  START OF API BODY  ============   |
        +-----------------------------------------------*/

	/*-----------------------------------------------+
        |   Validation of the Input parameters 		 |
        +-----------------------------------------------*/

	AR_BILLS_CREATION_VAL_PVT.Validate_Customer_Trx_ID (p_customer_trx_id);
	AR_BILLS_MAINTAIN_VAL_PVT.Validate_Payment_schedule_ID (p_br_ref_payment_schedule_id);


	--  Fetch the BR transaction information

	ARP_CT_PKG.fetch_p (l_BR_rec, p_customer_trx_id);


	--  Fetch the payment schedule information of the exchanged transaction

	arp_ps_pkg.fetch_p (p_br_ref_payment_schedule_id, l_ps_rec);

	--  Fetch the exchanged transaction information

	ARP_CT_PKG.fetch_p (l_trx_rec, l_ps_rec.customer_trx_id);


       /*-----------------------------------------------+
        |   Data preparation 				|
        +-----------------------------------------------*/

	l_trl_rec.customer_trx_id		:=	p_customer_trx_id	;
	l_trl_rec.br_ref_payment_schedule_id	:=	p_br_ref_payment_schedule_id;
	l_trl_rec.extended_amount		:=	p_assigned_amount	;

	l_trl_rec.attribute_category		:=	p_attribute_category	;
	l_trl_rec.attribute1			:=	p_attribute1		;
	l_trl_rec.attribute2			:=	p_attribute2		;
	l_trl_rec.attribute3			:=	p_attribute3		;
	l_trl_rec.attribute4			:=	p_attribute4		;
	l_trl_rec.attribute5			:=	p_attribute5		;
	l_trl_rec.attribute6			:=	p_attribute6		;
	l_trl_rec.attribute7			:=	p_attribute7		;
	l_trl_rec.attribute8			:=	p_attribute8		;
	l_trl_rec.attribute9			:=	p_attribute9		;
	l_trl_rec.attribute10			:=	p_attribute10		;
	l_trl_rec.attribute11			:=	p_attribute11		;
	l_trl_rec.attribute12			:=	p_attribute12		;
	l_trl_rec.attribute13			:=	p_attribute13		;
	l_trl_rec.attribute14			:=	p_attribute14		;
	l_trl_rec.attribute15			:=	p_attribute15		;

	l_trl_rec.line_number			:=	1;
	l_trl_rec.line_type			:=	'LINE';

	l_trl_rec.revenue_amount		:=	p_assigned_amount;

        l_trl_rec.org_id                        :=      p_org_id;


	/*----------------------------------------------+
        |   Data Defaulting 				|
        +-----------------------------------------------*/

   	AR_BILLS_CREATION_LIB_PVT.Default_Create_BR_Assignment (l_trl_rec, l_ps_rec);


       /*-----------------------------------------------+
        |   Data Validation				|
        +-----------------------------------------------*/

        AR_BILLS_CREATION_VAL_PVT.Validate_BR_Assignment (l_trl_rec	,
						 	  l_ps_rec	,
							  l_trx_rec	,
							  l_br_rec	);


       /*-----------------------------------------------+
        |   Call the Entity Handler  			|
        +-----------------------------------------------*/

	ARP_PROCESS_BR_LINE.insert_line (l_trl_rec, l_customer_trx_line_id);


       /*-----------------------------------------------+
        |   Transaction History Entity Handler		|
        +-----------------------------------------------*/

	IF	(AR_BILLS_CREATION_VAL_PVT.Is_transaction_BR (l_trx_rec.cust_trx_type_id))
	THEN

		/*----------------------------------------------+
	        |   If the transaction to be exchanged is a BR,	|
		|   create a transaction history record for the |
		|   BR						|
	        +-----------------------------------------------*/

		l_trh_rec.customer_trx_id	:=	l_trx_rec.customer_trx_id;
		ARP_TRANSACTION_HISTORY_PKG.lock_fetch_f_trx_id (l_trh_rec);

		AR_BILLS_MAINTAIN_STATUS_PUB.New_Status_Event (
			p_trx_rec		=>	l_trx_rec		,
			p_action       	 	=>	'EXCHANGE'		,
			p_new_status		=>	l_trh_rec.status	,
			p_new_event		=>	l_trh_rec.event		);

		l_trh_rec.postable_flag		:=	'N'		;
		l_trh_rec.current_accounted_flag:=	'N'		;
		l_trh_rec.transaction_history_id:=	NULL		;
		l_trh_rec.current_record_flag	:=  	'Y'		;
		l_trh_rec.prv_trx_history_id	:=  	NULL		;
		l_trh_rec.comments		:=  	NULL		;
		l_trh_rec.posting_control_id    := 	-3           	;
		l_trh_rec.gl_posted_date        :=  	NULL        	;
		l_trh_rec.first_posted_record_flag := 	'N'		;
		l_trh_rec.created_from		:=	'ARBRMAIB'	;
		l_trh_rec.batch_id		:=	NULL		;
                l_trh_rec.org_id                :=      p_org_id        ;


		arp_proc_transaction_history.insert_transaction_history (l_trh_rec	,
									 l_trh_rec.transaction_history_id);
	END IF;


	/*----------------------------------------------+
        |   Output parameter				|
        +-----------------------------------------------*/

	p_customer_trx_line_id		:=   	l_customer_trx_line_id;



       /*-----------------------------------------------+
        |   Standard check of p_commit   		|
        +-----------------------------------------------*/

        IF FND_API.To_Boolean( p_commit )
        THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug(  'committing');
            END IF;
            Commit;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('AR_BILLS_CREATION_PUB.Create_BR_Assignment()- ');
        END IF;


EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug (  'SQLERRM : ' || SQLERRM);
		   arp_util.debug (  'SQLCODE : ' || SQLCODE);
		END IF;
                ROLLBACK TO Create_BR_Assignment_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug(  'Exception Error');
                END IF;
		RAISE;


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug (  'SQLERRM : ' || SQLERRM);
		   arp_util.debug (  'SQLCODE : ' || SQLCODE);
		END IF;
                ROLLBACK TO Create_BR_Assignment_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug(  'Exception Unexpected Error');
		END IF;
		RAISE;


        WHEN OTHERS THEN

               /*-------------------------------------------------------+
                |  Handle application errors that result from trapable  |
                |  error conditions. The error messages have already    |
                |  been put on the error stack.                         |
                +-------------------------------------------------------*/

		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug (  'SQLERRM : ' || SQLERRM);
		   arp_util.debug (  'SQLCODE : ' || SQLCODE);
		END IF;

		ROLLBACK TO Create_BR_Assignment_PVT;

		IF (SQLCODE = -20001)
                THEN
                     	x_return_status := FND_API.G_RET_STS_ERROR ;
                ELSE
               	      	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                END IF;

		RAISE;

END Create_BR_Assignment;




/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Update_BR_Assignment			                               	|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    Update BR Assignment information					     	|
 |									  	|
 +==============================================================================*/


PROCEDURE Update_BR_Assignment (

           --   *****  Standard API parameters *****
                p_api_version      		IN  NUMBER			,
                p_init_msg_list    		IN  VARCHAR2 := FND_API.G_TRUE	,
                p_commit           		IN  VARCHAR2 := FND_API.G_FALSE	,
                p_validation_level 		IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                x_return_status    		OUT NOCOPY VARCHAR2			,
                x_msg_count        		OUT NOCOPY NUMBER			,
                x_msg_data         		OUT NOCOPY VARCHAR2			,

           --   *****  BR Assignment information parameters *****
		p_customer_trx_id		IN  NUMBER	DEFAULT NULL	,
		p_customer_trx_line_id		IN  NUMBER	DEFAULT NULL	,
		p_br_ref_payment_schedule_id	IN  NUMBER	DEFAULT NULL	,
		p_assigned_amount		IN  NUMBER	DEFAULT NULL	,

           --   ***** Descriptive Flexfield parameters *****
                p_attribute_category		IN  VARCHAR2	DEFAULT NULL	,
		p_attribute1			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute2			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute3			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute4			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute5			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute6			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute7			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute8			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute9			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute10			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute11			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute12			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute13			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute14			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute15			IN  VARCHAR2	DEFAULT NULL	)

IS
		l_api_name			CONSTANT VARCHAR2(20)	:=	'Update_BR_Assignment';
		l_api_version			CONSTANT NUMBER		:=	1.0;

		l_trl_rec			ra_customer_trx_lines%ROWTYPE;
		l_ps_rec			ar_payment_schedules%ROWTYPE;

		l_trx_rec			ra_customer_trx%ROWTYPE;
		l_BR_rec			ra_customer_trx%ROWTYPE;

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_CREATION_PUB.Update_BR_Assignment()+ ');
	END IF;

	x_msg_count				:=	NULL;
	x_msg_data				:=	NULL;


       /*-----------------------------------------------+
        |   Standard start of API savepoint     	|
        +-----------------------------------------------*/

      	SAVEPOINT Update_BR_Assignment_PVT;


       /*-----------------------------------------------+
        | Standard call to check for call compatibility |
        +-----------------------------------------------*/

        IF NOT FND_API.Compatible_API_Call( l_api_version	,
                                            p_api_version	,
                                            l_api_name		,
                                            G_PKG_NAME          )
        THEN
        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


       /*-----------------------------------------------+
        |   Initialize return status to SUCCESS   	|
        +-----------------------------------------------*/

        x_return_status := FND_API.G_RET_STS_SUCCESS;


       /*-----------------------------------------------+
        |   ========  START OF API BODY  ============   |
        +-----------------------------------------------*/


       /*-----------------------------------------------+
        |   Data preparation 				|
        +----------------------------------------------*/

	AR_BILLS_CREATION_VAL_PVT.Validate_Customer_trx_line_id (p_customer_trx_line_id);

	ARP_CTL_PKG.lock_fetch_p (l_trl_rec, p_customer_trx_line_id);

	l_trl_rec.extended_amount		:=	p_assigned_amount	;
	l_trl_rec.attribute_category		:=	p_attribute_category	;
	l_trl_rec.attribute1			:=	p_attribute1		;
	l_trl_rec.attribute2			:=	p_attribute2		;
	l_trl_rec.attribute3			:=	p_attribute3		;
	l_trl_rec.attribute4			:=	p_attribute4		;
	l_trl_rec.attribute5			:=	p_attribute5		;
	l_trl_rec.attribute6			:=	p_attribute6		;
	l_trl_rec.attribute7			:=	p_attribute7		;
	l_trl_rec.attribute8			:=	p_attribute8		;
	l_trl_rec.attribute9			:=	p_attribute9		;
	l_trl_rec.attribute10			:=	p_attribute10		;
	l_trl_rec.attribute11			:=	p_attribute11		;
	l_trl_rec.attribute12			:=	p_attribute12		;
	l_trl_rec.attribute13			:=	p_attribute13		;
	l_trl_rec.attribute14			:=	p_attribute14		;
	l_trl_rec.attribute15			:=	p_attribute15		;



	/*----------------------------------------------+
        |   Data Defaulting 				|
        +-----------------------------------------------*/


	--  Fetch the BR transaction information

	ARP_CT_PKG.fetch_p (l_BR_rec, l_trl_rec.customer_trx_id);


	--  Fetch the payment schedule information of the exchanged transaction

	arp_ps_pkg.fetch_p (l_trl_rec.br_ref_payment_schedule_id, l_ps_rec);


	--  Fetch the exchanged transaction information

	ARP_CT_PKG.fetch_p (l_trx_rec, l_trl_rec.br_ref_customer_trx_id);



       /*-----------------------------------------------+
        |   Data Validation				|
        +-----------------------------------------------*/

        AR_BILLS_CREATION_VAL_PVT.Validate_BR_Assignment (l_trl_rec	,
						 	  l_ps_rec	,
							  l_trx_rec	,
							  l_br_rec	);


       /*-----------------------------------------------+
        |   Call the Entity Handler  		     	|
        +-----------------------------------------------*/

	ARP_PROCESS_BR_LINE.update_line  (l_trl_rec.customer_trx_line_id, l_trl_rec);


       /*-----------------------------------------------+
        |   Standard check of p_commit   		|
        +-----------------------------------------------*/

        IF FND_API.To_Boolean( p_commit )
        THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug(  'committing');
            END IF;
            Commit;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('AR_BILLS_CREATION_PUB.Update_BR_Assignment()- ');
        END IF;


EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug (  'SQLERRM : ' || SQLERRM);
		   arp_util.debug (  'SQLCODE : ' || SQLCODE);
		END IF;
                ROLLBACK TO Update_BR_Assignment_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
		RAISE;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug (  'SQLERRM : ' || SQLERRM);
		   arp_util.debug (  'SQLCODE : ' || SQLCODE);
		END IF;
                ROLLBACK TO Update_BR_Assignment_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		RAISE;

        WHEN OTHERS THEN

               /*-------------------------------------------------------+
                |  Handle application errors that result from trapable  |
                |  error conditions. The error messages have already    |
                |  been put on the error stack.                         |
                +-------------------------------------------------------*/

		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug (  'SQLERRM : ' || SQLERRM);
		   arp_util.debug (  'SQLCODE : ' || SQLCODE);
		END IF;


		ROLLBACK TO Update_BR_Assignment_PVT;

		IF (SQLCODE = -20001)
                THEN
                     	x_return_status := FND_API.G_RET_STS_ERROR ;
                ELSE
               	      	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                END IF;

		RAISE;

END Update_BR_Assignment;




/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Delete_BR_Assignment			                               	|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    Delete BR Assignment information					     	|
 |									  	|
 +==============================================================================*/


PROCEDURE Delete_BR_Assignment (

           --   *****  Standard API parameters *****
                p_api_version      		IN  NUMBER			,
                p_init_msg_list    		IN  VARCHAR2 := FND_API.G_TRUE	,
                p_commit           		IN  VARCHAR2 := FND_API.G_FALSE	,
                p_validation_level 		IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                x_return_status    		OUT NOCOPY VARCHAR2			,
                x_msg_count        		OUT NOCOPY NUMBER			,
                x_msg_data         		OUT NOCOPY VARCHAR2			,

           --   *****  BR Assignment information parameters *****
		p_customer_trx_id		IN  NUMBER	DEFAULT NULL	,
		p_customer_trx_line_id		IN  NUMBER	DEFAULT NULL	)

IS
		l_api_name			CONSTANT VARCHAR2(20)	:=	'Delete_BR_Assignment';
		l_api_version			CONSTANT NUMBER		:=	1.0;
		l_trl_rec			ra_customer_trx_lines%ROWTYPE;
		l_BR_rec			ra_customer_trx%ROWTYPE;


BEGIN

       	IF PG_DEBUG in ('Y', 'C') THEN
       	   arp_util.debug('AR_BILLS_CREATION_PUB.Delete_BR_Assignment()+ ');
       	END IF;

       	x_msg_count				:=	NULL;
	x_msg_data				:=	NULL;

       /*-----------------------------------------------+
        |   Standard start of API savepoint     	|
        +-----------------------------------------------*/

      	SAVEPOINT Delete_BR_Assignment_PVT;


       /*-----------------------------------------------+
        | Standard call to check for call compatibility |
        +-----------------------------------------------*/

        IF NOT FND_API.Compatible_API_Call( l_api_version	,
                                            p_api_version	,
                                            l_api_name		,
                                            G_PKG_NAME          )
        THEN
        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


       /*-----------------------------------------------+
        |   Initialize return status to SUCCESS   	|
        +-----------------------------------------------*/

        x_return_status := FND_API.G_RET_STS_SUCCESS;


       /*-----------------------------------------------+
        |   ========  START OF API BODY  ============   |
        +-----------------------------------------------*/

       /*-----------------------------------------------+
        |   Data preparation 				|
        +----------------------------------------------*/

	AR_BILLS_CREATION_VAL_PVT.Validate_Customer_trx_line_id (p_customer_trx_line_id);

	--  Fetch the Assignment information
	arp_ctl_pkg.fetch_p (l_trl_rec, p_customer_trx_line_id);

	--  Fetch the BR transaction information
	ARP_CT_PKG.fetch_p (l_BR_rec, l_trl_rec.customer_trx_id);


       /*-----------------------------------------------+
        |   Data Validation				|
        +-----------------------------------------------*/

        --  Validate the status of the BR (must be INCOMPLETE)

	AR_BILLS_CREATION_VAL_PVT.Validate_BR_Status (l_trl_rec.customer_trx_id);


       /*-----------------------------------------------+
        |   Call the Entity Handler  		     	|
        +-----------------------------------------------*/

	ARP_PROCESS_BR_LINE.Delete_line  (p_customer_trx_line_id, l_trl_rec.customer_trx_id);

       /*-----------------------------------------------+
        |   Standard check of p_commit   		|
        +-----------------------------------------------*/

        IF FND_API.To_Boolean( p_commit )
        THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug(  'committing');
            END IF;
            Commit;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('AR_BILLS_CREATION_PUB.Delete_BR_Assignment()- ');
        END IF;


EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug (  'SQLERRM : ' || SQLERRM);
		   arp_util.debug (  'SQLCODE : ' || SQLCODE);
		END IF;
                ROLLBACK TO Delete_BR_Assignment_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
  	        IF PG_DEBUG in ('Y', 'C') THEN
  	           arp_util.debug(  'Exception Error');
  	        END IF;
		RAISE;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug (  'SQLERRM : ' || SQLERRM);
		   arp_util.debug (  'SQLCODE : ' || SQLCODE);
		END IF;
                ROLLBACK TO Delete_BR_Assignment_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug(  'Exception Unexpected Error');
		END IF;
		RAISE;

        WHEN OTHERS THEN

               /*-------------------------------------------------------+
                |  Handle application errors that result from trapable  |
                |  error conditions. The error messages have already    |
                |  been put on the error stack.                         |
                +-------------------------------------------------------*/

		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug (  'SQLERRM : ' || SQLERRM);
		   arp_util.debug (  'SQLCODE : ' || SQLCODE);
		END IF;

		ROLLBACK TO Delete_BR_Assignment_PVT;

		IF (SQLCODE = -20001)
                THEN
                     	x_return_status := FND_API.G_RET_STS_ERROR ;
                ELSE
               	      	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                END IF;

		RAISE;

END Delete_BR_Assignment;



/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Lock_BR_Assignment			                               	|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    Lock BR Assignment information					     	|
 |									  	|
 +==============================================================================*/


PROCEDURE Lock_BR_Assignment (

           --   *****  Standard API parameters *****
                p_api_version      		IN  NUMBER			,
                p_init_msg_list    		IN  VARCHAR2 := FND_API.G_TRUE	,
                p_commit           		IN  VARCHAR2 := FND_API.G_FALSE	,
                p_validation_level 		IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                x_return_status    		OUT NOCOPY VARCHAR2			,
                x_msg_count        		OUT NOCOPY NUMBER			,
                x_msg_data         		OUT NOCOPY VARCHAR2			,

           --   *****  BR Assignment information parameters *****
		p_customer_trx_id		IN  NUMBER	DEFAULT NULL	,
		p_customer_trx_line_id		IN  NUMBER	DEFAULT NULL	,
		p_br_ref_payment_schedule_id	IN  NUMBER	DEFAULT NULL	,
		p_assigned_amount		IN  NUMBER	DEFAULT NULL	,

           --   ***** Descriptive Flexfield parameters *****
                p_attribute_category		IN  VARCHAR2	DEFAULT NULL	,
		p_attribute1			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute2			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute3			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute4			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute5			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute6			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute7			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute8			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute9			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute10			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute11			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute12			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute13			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute14			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute15			IN  VARCHAR2	DEFAULT NULL	)

IS
		l_api_name			CONSTANT VARCHAR2(20)	:=	'Lock_BR_Assignment';
		l_api_version			CONSTANT NUMBER		:=	1.0;

		l_trl_rec			ra_customer_trx_lines%ROWTYPE;


BEGIN

       	IF PG_DEBUG in ('Y', 'C') THEN
       	   arp_util.debug('AR_BILLS_CREATION_PUB.Lock_BR_Assignment()+ ');
       	END IF;

       	x_msg_count				:=	NULL;
	x_msg_data				:=	NULL;


       /*-----------------------------------------------+
        |   Standard start of API savepoint     	|
        +-----------------------------------------------*/

      	SAVEPOINT Lock_BR_Assignment_PVT;


       /*-----------------------------------------------+
        | Standard call to check for call compatibility |
        +-----------------------------------------------*/

        IF NOT FND_API.Compatible_API_Call( l_api_version	,
                                            p_api_version	,
                                            l_api_name		,
                                            G_PKG_NAME          )
        THEN
        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


       /*-----------------------------------------------+
        |   Initialize return status to SUCCESS   	|
        +-----------------------------------------------*/

        x_return_status := FND_API.G_RET_STS_SUCCESS;


       /*-----------------------------------------------+
        |   ========  START OF API BODY  ============   |
        +-----------------------------------------------*/

       /*-----------------------------------------------+
        |   Data preparation 				|
        +-----------------------------------------------*/

	AR_BILLS_CREATION_VAL_PVT.Validate_Customer_trx_line_id (p_customer_trx_line_id);

	arp_ctl_pkg.set_to_dummy (l_trl_rec);

	l_trl_rec.customer_trx_id		:=	p_customer_trx_id	;
	l_trl_rec.customer_trx_line_id		:=	p_customer_trx_line_id	;
	l_trl_rec.br_ref_payment_schedule_id	:=	p_br_ref_payment_schedule_id;
	l_trl_rec.extended_amount		:=	p_assigned_amount	;

	l_trl_rec.attribute_category		:=	p_attribute_category	;
	l_trl_rec.attribute1			:=	p_attribute1		;
	l_trl_rec.attribute2			:=	p_attribute2		;
	l_trl_rec.attribute3			:=	p_attribute3		;
	l_trl_rec.attribute4			:=	p_attribute4		;
	l_trl_rec.attribute5			:=	p_attribute5		;
	l_trl_rec.attribute6			:=	p_attribute6		;
	l_trl_rec.attribute7			:=	p_attribute7		;
	l_trl_rec.attribute8			:=	p_attribute8		;
	l_trl_rec.attribute9			:=	p_attribute9		;
	l_trl_rec.attribute10			:=	p_attribute10		;
	l_trl_rec.attribute11			:=	p_attribute11		;
	l_trl_rec.attribute12			:=	p_attribute12		;
	l_trl_rec.attribute13			:=	p_attribute13		;
	l_trl_rec.attribute14			:=	p_attribute14		;
	l_trl_rec.attribute15			:=	p_attribute15		;

       /*-----------------------------------------------+
        |   Call the Table Handler    			|
        +-----------------------------------------------*/

	ARP_CTL_PKG.lock_compare_p  (l_trl_rec, p_customer_trx_line_id);

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('AR_BILLS_CREATION_PUB.Lock_BR_Assignment()- ');
        END IF;

EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug (  'SQLERRM : ' || SQLERRM);
		   arp_util.debug (  'SQLCODE : ' || SQLCODE);
		END IF;
                ROLLBACK TO Lock_BR_Assignment_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
  	        RAISE;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug (  'SQLERRM : ' || SQLERRM);
		   arp_util.debug (  'SQLCODE : ' || SQLCODE);
		END IF;
                ROLLBACK TO Lock_BR_Assignment_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		RAISE;

        WHEN OTHERS THEN

               /*-------------------------------------------------------+
                |  Handle application errors that result from trapable  |
                |  error conditions. The error messages have already    |
                |  been put on the error stack.                         |
                +-------------------------------------------------------*/

		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug (  'SQLERRM : ' || SQLERRM);
		   arp_util.debug (  'SQLCODE : ' || SQLCODE);
		END IF;

		ROLLBACK TO Lock_BR_Assignment_PVT;

		IF (SQLCODE = -20001)
                THEN
                      x_return_status := FND_API.G_RET_STS_ERROR ;
                ELSE
                      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                END IF;

		RAISE;

END Lock_BR_Assignment;


/*==============================================================================+
 | PROCEDURE                                                                    |
 |    Create_BR_Trxn_Extension                                                  |
 |                                                                              |
 | DESCRIPTION                                                                  |
 |    Creates payment trxn extension details via IBY API                        |
 |                                                                              |
 +==============================================================================*/

PROCEDURE Create_BR_Trxn_Extension(

           --   *****  Standard API parameters *****
                p_api_version                   IN  NUMBER                      ,
                p_init_msg_list                 IN  VARCHAR2 := FND_API.G_TRUE  ,
                p_commit                        IN  VARCHAR2 := FND_API.G_FALSE ,
                x_return_status                 OUT NOCOPY VARCHAR2             ,
                x_msg_count                     OUT NOCOPY NUMBER               ,
                x_msg_data                      OUT NOCOPY VARCHAR2             ,

           --   *****  BR Header information parameters *****
                p_customer_trx_id               IN  NUMBER      DEFAULT NULL    ,
                p_trx_number                    IN  VARCHAR2    DEFAULT NULL    ,
                p_org_id                        IN  NUMBER      DEFAULT NULL    ,
                p_drawee_id                     IN  NUMBER      DEFAULT NULL    ,
                p_drawee_site_use_id            IN  NUMBER      DEFAULT NULL    ,
                p_payment_channel               IN  VARCHAR2    DEFAULT NULL    ,
                p_instrument_assign_id          IN  NUMBER      DEFAULT NULL    ,
           --   ***** OUTPUT variables *****
                p_payment_trxn_extn_id          OUT NOCOPY NUMBER              )
IS
    l_payer_rec            IBY_FNDCPT_COMMON_PUB.payercontext_rec_type;
    l_trxn_attribs_rec     IBY_FNDCPT_TRXN_PUB.trxnextension_rec_type;
    l_response             IBY_FNDCPT_COMMON_PUB.result_rec_type;
    l_payment_channel      ar_receipt_methods.payment_channel_code%type;
Begin
        arp_standard.debug('AR_BILLS_CREATION_PUB.Create_BR_Trxn_Extension()+ ');
        x_msg_count          := NULL;
        x_msg_data           := NULL;
        x_return_status      := FND_API.G_RET_STS_SUCCESS;
        l_payer_rec.party_id :=  arp_trx_defaults_3.get_party_Id(P_DRAWEE_ID);
        l_payer_rec.payment_function                  := 'CUSTOMER_PAYMENT';
        l_payer_rec.org_type                          := 'OPERATING_UNIT';
        l_payer_rec.cust_account_id                   :=  P_DRAWEE_ID;
        l_payer_rec.org_id                            :=  P_ORG_ID;
        l_payer_rec.account_site_id                   :=  P_DRAWEE_SITE_USE_ID;
        l_payment_channel                             := 'BILLS_RECEIVABLE';
        l_trxn_attribs_rec.originating_application_id := 222;
        l_trxn_attribs_rec.trxn_ref_number1           := 'BILLS_RECEIVABLE';
        l_trxn_attribs_rec.order_id                   := P_TRX_NUMBER;
        l_trxn_attribs_rec.trxn_ref_number2           := P_CUSTOMER_TRX_ID;

           /*-------------------------+
            |   Call the IBY API      |
            +-------------------------*/
            arp_standard.debug('Call TO IBY API ()+ ');

            IBY_FNDCPT_TRXN_PUB.create_transaction_extension(
               p_api_version           => 1.0,
               p_init_msg_list         => p_init_msg_list,
               p_commit                => p_commit,
               x_return_status         => x_return_status,
               x_msg_count             => x_msg_count,
               x_msg_data              => x_msg_data,
               p_payer                 => l_payer_rec,
               p_payer_equivalency     => 'UPWARD',
               p_pmt_channel           => l_payment_channel,
               p_instr_assignment      => p_instrument_assign_id,
               p_trxn_attribs          => l_trxn_attribs_rec,
               x_entity_id             => p_payment_trxn_extn_id,
               x_response              => l_response);

    IF x_return_status  = fnd_api.g_ret_sts_success
    THEN
       arp_standard.debug('Payment_Trxn_Extension_Id : ' || p_payment_trxn_extn_id);
    Else
       arp_standard.debug('Errors Reported by IBY API: ');
    END IF;
EXCEPTION
     WHEN OTHERS THEN
       arp_standard.debug('exception in AR_BILLS_CREATION_PUB.Create_BR_Trxn_Extension ');
       RAISE;
END Create_BR_Trxn_Extension;



/*==============================================================================+
 | PROCEDURE                                                                    |
 |   Update_BR_Trxn_Extension                                                  |
 |                                                                              |
 | DESCRIPTION                                                                  |
 |    Updates  payment trxn extension details via IBY API                        |
 |                                                                              |
 +==============================================================================*/

PROCEDURE Update_BR_Trxn_Extension(

           --   *****  Standard API parameters *****
                p_api_version                   IN  NUMBER                      ,
                p_init_msg_list                 IN  VARCHAR2 := FND_API.G_TRUE  ,
                p_commit                        IN  VARCHAR2 := FND_API.G_FALSE ,
                x_return_status                 OUT NOCOPY VARCHAR2             ,
                x_msg_count                     OUT NOCOPY NUMBER               ,
                x_msg_data                      OUT NOCOPY VARCHAR2             ,

           --   *****  BR Header information parameters *****
                p_customer_trx_id               IN  NUMBER      DEFAULT NULL    ,
                p_trx_number                    IN  VARCHAR2    DEFAULT NULL    ,
                p_org_id                        IN  NUMBER      DEFAULT NULL    ,
                p_drawee_id                     IN  NUMBER      DEFAULT NULL    ,
                p_drawee_site_use_id            IN  NUMBER      DEFAULT NULL    ,
                p_payment_channel               IN  VARCHAR2    DEFAULT NULL    ,
                p_instrument_assign_id          IN  NUMBER      DEFAULT NULL    ,
                p_payment_trxn_extn_id          IN  IBY_TRXN_EXTENSIONS_V.TRXN_EXTENSION_ID%TYPE    )
IS
    l_payer_rec            IBY_FNDCPT_COMMON_PUB.payercontext_rec_type;
    l_trxn_attribs_rec     IBY_FNDCPT_TRXN_PUB.trxnextension_rec_type;
    l_response             IBY_FNDCPT_COMMON_PUB.result_rec_type;
    l_payment_channel      ar_receipt_methods.payment_channel_code%type;
Begin
        arp_standard.debug('AR_BILLS_CREATION_PUB.Update_BR_Trxn_Extension()+ ');
        x_msg_count          := NULL;
        x_msg_data           := NULL;
        x_return_status      := FND_API.G_RET_STS_SUCCESS;
        l_payer_rec.party_id :=  arp_trx_defaults_3.get_party_Id(P_DRAWEE_ID);
        l_payer_rec.payment_function                  := 'CUSTOMER_PAYMENT';
        l_payer_rec.org_type                          := 'OPERATING_UNIT';
        l_payer_rec.cust_account_id                   :=  P_DRAWEE_ID;
        l_payer_rec.org_id                            :=  P_ORG_ID;
        l_payer_rec.account_site_id                   :=  P_DRAWEE_SITE_USE_ID;
        l_payment_channel                             := 'BILLS_RECEIVABLE';
        l_trxn_attribs_rec.originating_application_id := 222;
        l_trxn_attribs_rec.trxn_ref_number1           := 'BILLS_RECEIVABLE';
        l_trxn_attribs_rec.order_id                   := P_TRX_NUMBER;
        l_trxn_attribs_rec.trxn_ref_number2           := P_CUSTOMER_TRX_ID;

           /*-------------------------+
            |   Call the IBY API      |
            +-------------------------*/
            arp_standard.debug('Call TO IBY API ()+ ');

            IBY_FNDCPT_TRXN_PUB.update_transaction_extension(
               p_api_version           => 1.0,
               p_init_msg_list         => p_init_msg_list,
               p_commit                => p_commit,
               x_return_status         => x_return_status,
               x_msg_count             => x_msg_count,
               x_msg_data              => x_msg_data,
               p_payer                 => l_payer_rec,
               p_payer_equivalency     => 'UPWARD',
               p_pmt_channel           => l_payment_channel,
               p_instr_assignment      => nvl(p_instrument_assign_id,FND_API.G_MISS_NUM),
               p_trxn_attribs          => l_trxn_attribs_rec,
               p_entity_id             => p_payment_trxn_extn_id,
               x_response              => l_response);

    IF x_return_status  = fnd_api.g_ret_sts_success
    THEN
       arp_standard.debug('Payment_Trxn_Extension_Id : ' || p_payment_trxn_extn_id);
    Else
       arp_standard.debug('Errors Reported by IBY API:Update Transaction Extension ');
    END IF;
EXCEPTION
     WHEN OTHERS THEN
       arp_standard.debug('exception in AR_BILLS_CREATION_PUB.Update_BR_Trxn_Extension ');
       RAISE;
END Update_BR_Trxn_Extension;



/*==============================================================================+
 | PROCEDURE                                                                    |
 |   Delete_BR_Trxn_Extension      	                                        |
 |                                                                              |
 | DESCRIPTION                                                                  |
 |    Deletes  payment trxn extension details via IBY API                       |
 |                                                                              |
 +==============================================================================*/

PROCEDURE Delete_BR_Trxn_Extension(

           --   *****  Standard API parameters *****
                p_api_version                   IN  NUMBER                      ,
                p_init_msg_list                 IN  VARCHAR2 := FND_API.G_TRUE  ,
                p_commit                        IN  VARCHAR2 := FND_API.G_FALSE ,
                x_return_status                 OUT NOCOPY VARCHAR2             ,
                x_msg_count                     OUT NOCOPY NUMBER               ,
                x_msg_data                      OUT NOCOPY VARCHAR2             ,

           --   *****  BR Header information parameters *****
                p_customer_trx_id               IN  NUMBER      DEFAULT NULL    ,
                p_trx_number                    IN  VARCHAR2    DEFAULT NULL    ,
                p_org_id                        IN  NUMBER      DEFAULT NULL    ,
                p_drawee_id                     IN  NUMBER      DEFAULT NULL    ,
                p_drawee_site_use_id            IN  NUMBER      DEFAULT NULL    ,
                p_payment_channel               IN  VARCHAR2    DEFAULT NULL    ,
                p_instrument_assign_id          IN  NUMBER      DEFAULT NULL    ,
                p_payment_trxn_extn_id          IN  IBY_TRXN_EXTENSIONS_V.TRXN_EXTENSION_ID%TYPE    )
IS
    l_payer_rec            IBY_FNDCPT_COMMON_PUB.payercontext_rec_type;
    l_trxn_attribs_rec     IBY_FNDCPT_TRXN_PUB.trxnextension_rec_type;
    l_response             IBY_FNDCPT_COMMON_PUB.result_rec_type;
    l_payment_channel      ar_receipt_methods.payment_channel_code%type;
Begin
        arp_standard.debug('AR_BILLS_CREATION_PUB.Delete_BR_Trxn_Extension()+ ');
        x_msg_count          := NULL;
        x_msg_data           := NULL;
        x_return_status      := FND_API.G_RET_STS_SUCCESS;
        l_payer_rec.party_id :=  arp_trx_defaults_3.get_party_Id(P_DRAWEE_ID);
        l_payer_rec.payment_function                  := 'CUSTOMER_PAYMENT';
        l_payer_rec.org_type                          := 'OPERATING_UNIT';
        l_payer_rec.cust_account_id                   :=  P_DRAWEE_ID;
        l_payer_rec.org_id                            :=  P_ORG_ID;
        l_payer_rec.account_site_id                   :=  P_DRAWEE_SITE_USE_ID;

           /*-------------------------+
            |   Call the IBY API      |
            +-------------------------*/
            arp_standard.debug('Call TO IBY API ()+ ');

            IBY_FNDCPT_TRXN_PUB.delete_transaction_extension(
               p_api_version           => 1.0,
               p_init_msg_list         => p_init_msg_list,
               p_commit                => p_commit,
               x_return_status         => x_return_status,
               x_msg_count             => x_msg_count,
               x_msg_data              => x_msg_data,
               p_payer                 => l_payer_rec,
               p_payer_equivalency     => 'UPWARD',
               p_entity_id             => p_payment_trxn_extn_id,
               x_response              => l_response);

    IF x_return_status  = fnd_api.g_ret_sts_success
    THEN
       arp_standard.debug('Payment_Trxn_Extension_Id : ' || p_payment_trxn_extn_id);
    Else
       arp_standard.debug('Errors Reported by IBY API:Delete Transaction Extension ');
    END IF;
EXCEPTION
     WHEN OTHERS THEN
       arp_standard.debug('exception in AR_BILLS_CREATION_PUB.Delete_BR_Trxn_Extension ');
       RAISE;
END Delete_BR_Trxn_Extension;





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
  RETURN '$Revision: 120.11 $';
END revision;
--

END AR_BILLS_CREATION_PUB;


/
