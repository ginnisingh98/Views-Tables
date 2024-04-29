--------------------------------------------------------
--  DDL for Package Body AR_BILLS_MAINTAIN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_BILLS_MAINTAIN_PUB" AS
/* $Header: ARBRMAIB.pls 120.11.12010000.4 2009/01/30 10:59:39 dgaurab ship $ */


/* =======================================================================
 | Global Data Types
 * ======================================================================*/

G_PKG_NAME     	CONSTANT VARCHAR2(30) :=  	'AR_BILLS_MAINTAIN_PUB';

G_MSG_UERROR   	CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
G_MSG_ERROR     CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_ERROR;
G_MSG_SUCCESS   CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
G_MSG_HIGH      CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
G_MSG_MEDIUM    CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
G_MSG_LOW       CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;


/* =======================================================================
 | Bills Receivable status constants
 * ======================================================================*/

C_INCOMPLETE		  CONSTANT VARCHAR2(30)	:=  'INCOMPLETE';
C_PENDING_REMITTANCE	  CONSTANT VARCHAR2(30)	:=  'PENDING_REMITTANCE';
C_PENDING_ACCEPTANCE	  CONSTANT VARCHAR2(30)	:=  'PENDING_ACCEPTANCE';
C_MATURED_PEND_RISK_ELIM  CONSTANT VARCHAR2(30)	:=  'MATURED_PEND_RISK_ELIMINATION';
C_CLOSED		CONSTANT VARCHAR2(30)   :=  'CLOSED';
C_REMITTED		CONSTANT VARCHAR2(30)	:=  'REMITTED';
C_PROTESTED		CONSTANT VARCHAR2(30)	:=  'PROTESTED';
C_FACTORED		CONSTANT VARCHAR2(30)   :=  'FACTORED';
C_ENDORSED		CONSTANT VARCHAR2(30)	:=  'ENDORSED';


/* =======================================================================
 | Bills Receivable event constants
 * ======================================================================*/

C_MATURITY_DATE		CONSTANT VARCHAR2(30)	:=	'MATURITY_DATE';
C_MATURITY_DATE_UPDATED	CONSTANT VARCHAR2(30)	:=	'MATURITY_DATE_UPDATED';
C_FORMATTED		CONSTANT VARCHAR2(30)	:=	'FORMATTED';
C_COMPLETED		CONSTANT VARCHAR2(30)	:=	'COMPLETED';
C_ACCEPTED		CONSTANT VARCHAR2(30)	:=	'ACCEPTED';
C_SELECTED_REMITTANCE	CONSTANT VARCHAR2(30)	:=	'SELECTED_REMITTANCE';
C_DESELECTED_REMITTANCE	CONSTANT VARCHAR2(30)	:=	'DESELECTED_REMITTANCE';
C_CANCELLED		CONSTANT VARCHAR2(30)	:=	'CANCELLED';
C_RISK_ELIMINATED	CONSTANT VARCHAR2(30)	:=	'RISK_ELIMINATED';
C_RISK_UNELIMINATED	CONSTANT VARCHAR2(30)	:=	'RISK_UNELIMINATED';
C_RECALLED		CONSTANT VARCHAR2(30)	:=	'RECALLED';
C_EXCHANGED		CONSTANT VARCHAR2(30)	:=	'EXCHANGED';
C_RELEASE_HOLD		CONSTANT VARCHAR2(30)	:=	'RELEASE_HOLD';


/* =======================================================================
 | Bills Receivable action constants
 * ======================================================================*/


C_COMPLETE		CONSTANT VARCHAR2(30)	:=	'COMPLETE';
C_ACCEPT		CONSTANT VARCHAR2(30)	:=	'ACCEPT';
C_COMPLETE_ACC		CONSTANT VARCHAR2(30)	:=	'COMPLETE_ACC';
C_UNCOMPLETE		CONSTANT VARCHAR2(30)	:=	'UNCOMPLETE';
C_HOLD			CONSTANT VARCHAR2(30)	:=	'HOLD';
C_UNHOLD		CONSTANT VARCHAR2(30)	:=	'RELEASE HOLD';
C_SELECT_REMIT		CONSTANT VARCHAR2(30)	:=	'SELECT_REMIT';
C_DESELECT_REMIT	CONSTANT VARCHAR2(30)	:=	'DESELECT_REMIT';
C_CANCEL		CONSTANT VARCHAR2(30)	:=	'CANCEL';
C_UNPAID		CONSTANT VARCHAR2(30)	:=	'UNPAID';
C_REMIT_STANDARD	CONSTANT VARCHAR2(30)	:=	'REMIT_STANDARD';
C_FACTORE		CONSTANT VARCHAR2(30)	:=	'FACTORE';
C_FACTORE_RECOURSE	CONSTANT VARCHAR2(30)	:=	'FACTORE_RECOURSE';
C_RECALL		CONSTANT VARCHAR2(30)	:=	'RECALL';
C_ELIMINATE_RISK	CONSTANT VARCHAR2(30)	:=	'RISK ELIMINATION';
C_UNELIMINATE_RISK	CONSTANT VARCHAR2(30)	:=	'REESTABLISH RISK';
C_PROTEST		CONSTANT VARCHAR2(30)	:=	'PROTEST';
C_ENDORSE		CONSTANT VARCHAR2(30)	:=	'ENDORSE';
C_ENDORSE_RECOURSE	CONSTANT VARCHAR2(30)	:=	'ENDORSE_RECOURSE';
C_RESTATE		CONSTANT VARCHAR2(30)	:=	'RESTATE';
C_EXCHANGE		CONSTANT VARCHAR2(30)	:=	'EXCHANGE';
C_EXCHANGE_COMPLETE	CONSTANT VARCHAR2(30)	:=	'EXCHANGE_COMPLETE';
C_EXCHANGE_UNCOMPLETE	CONSTANT VARCHAR2(30)	:=	'EXCHANGE_UNCOMPLETE';
C_DELETE		CONSTANT VARCHAR2(30)	:=	'DELETE';
C_APPROVE_REMIT		CONSTANT VARCHAR2(30)	:=	'REMITTANCE APPROVAL';


/* =======================================================================
 | Bills Receivable remittance method code constants
 * ======================================================================*/

C_STANDARD		CONSTANT VARCHAR2(30)	:=	'STANDARD';
C_FACTORING		CONSTANT VARCHAR2(30)	:=	'FACTORING';


/* =======================================================================
 | Parameter p_created_from for the Receipt API
 * ======================================================================*/

C_BR_REMITTED		CONSTANT VARCHAR2(30) := 'BR_REMITTED';
C_BR_FACTORED_RECOURSE	CONSTANT VARCHAR2(30) := 'BR_FACTORED_WITH_RECOURSE';
C_BR_FACTORED		CONSTANT VARCHAR2(30) := 'BR_FACTORED_WITHOUT_RECOURSE';



/* =======================================================================
 |  Action_Rec : Record used for the procedure validate_actions
 * ======================================================================*/

TYPE  Action_Rec_Type	IS RECORD  (
	complete_flag		VARCHAR2(1),
	uncomplete_flag		VARCHAR2(1),
	accept_flag		VARCHAR2(1),
     	cancel_flag		VARCHAR2(1),
	select_remit_flag	VARCHAR2(1),
	deselect_remit_flag	VARCHAR2(1),
	approve_remit_flag	VARCHAR2(1),
	hold_flag		VARCHAR2(1),
	unhold_flag		VARCHAR2(1),
	recall_flag		VARCHAR2(1),
	eliminate_flag		VARCHAR2(1),
	uneliminate_flag	VARCHAR2(1),
	unpaid_flag		VARCHAR2(1),
	protest_flag		VARCHAR2(1),
	endorse_flag		VARCHAR2(1),
	restate_flag		VARCHAR2(1),
	exchange_flag		VARCHAR2(1),
	delete_flag		VARCHAR2(1));


C_ACTION_REC			Action_Rec_Type;


API_exception			EXCEPTION;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    Complete_BR			                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Completes a BR							     |
 |									     |
 | HISTORY 								     |
 | 01-OCT-02	V Crisostomo	Bug 2533917 : p_old_trx_number datatype was  |
 |				changed from NUMBER to VARCHAR2 to comply    |
 |				with data model definition in RA_CUSTOMER_TRX|
 | 25-MAY-05   V Crisostomo	SSA-R12: pass org_id                         |
 +===========================================================================*/


PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE Complete_BR (

           --   *****  Standard API parameters  *****

           p_api_version      	IN  	NUMBER,
           p_init_msg_list    	IN  	VARCHAR2 := FND_API.G_TRUE,
           p_commit           	IN  	VARCHAR2 := FND_API.G_FALSE,
           p_validation_level 	IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
           x_return_status    	OUT NOCOPY 	VARCHAR2,
           x_msg_count        	OUT NOCOPY 	NUMBER,
           x_msg_data         	OUT NOCOPY 	VARCHAR2,

           --   *****  Input  parameters  *****

	   p_customer_trx_id	IN  	NUMBER,

           --   *****  Output parameters  *****

	   p_trx_number		OUT NOCOPY 	VARCHAR2,
	   p_doc_sequence_id	OUT NOCOPY 	NUMBER,
	   p_doc_sequence_value	OUT NOCOPY 	NUMBER,
	   p_old_trx_number	OUT NOCOPY 	VARCHAR2,  /* Bug 2533917 */
	   p_status		OUT NOCOPY 	VARCHAR2)

IS

	l_api_name		CONSTANT VARCHAR2(20)	:=	'Complete_BR';
	l_api_version		CONSTANT NUMBER		:=	1.0;

	l_trx_rec		ra_customer_trx%ROWTYPE;
	l_trh_rec		ar_transaction_history%ROWTYPE;
	l_ps_rec		ar_payment_schedules%ROWTYPE;

	l_doc_sequence_id	NUMBER		;
	l_doc_sequence_value	NUMBER		;
	l_trx_number		VARCHAR2(20)	;
	l_old_trx_number	VARCHAR2(20)	;

	l_acceptance_flag	VARCHAR2(1)	;

	l_action		VARCHAR2(30)	;
	l_action_rec		action_rec_type	;

       --Bug5051673
	l_drawee_id		ra_customer_trx.drawee_id%type;
	l_drawee_site_use_id	ra_customer_trx.drawee_site_use_id%type;
	l_org_id		ra_customer_trx.org_id%type;
	l_payment_trxn_extension_id ra_customer_trx.payment_trxn_extension_id%type;
	l_created_from          ra_customer_trx.created_from%type;
	l_instr_id              iby_trxn_extensions_v.instr_assignment_id%type;


BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_PUB.Complete_BR()+ ');
	END IF;

	x_msg_count				:=	NULL;
	x_msg_data				:=	NULL;

       /*-----------------------------------------------+
        |   Standard start of API savepoint     	|
        +-----------------------------------------------*/

      	SAVEPOINT Complete_BR_PVT;


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


       /*--------------------------------------------------------------+
        |   Initialize message list if p_init_msg_list is set to TRUE  |
        +--------------------------------------------------------------*/

        IF  FND_API.to_Boolean( p_init_msg_list )  THEN
 	             FND_MSG_PUB.initialize;
        END IF;


       /*-----------------------------------------------+
        |   Initialize return status to SUCCESS   	|
        +-----------------------------------------------*/

        x_return_status := FND_API.G_RET_STS_SUCCESS;



       /*------------------------------------------------+
        |  Bug 5051673					 |
	| Creation of Payment Extension Record 		 |
        +------------------------------------------------*/
        select trx_number,drawee_id,drawee_site_use_id,org_id,payment_trxn_extension_id,
	       substr(created_from ,1,8)
	into l_trx_number,l_drawee_id,l_drawee_site_use_id,l_org_id,l_payment_trxn_extension_id,
	     l_created_from
	from ra_customer_trx
	where customer_trx_id = p_customer_trx_id;

       if l_payment_trxn_extension_id is null then
	If substr(l_created_from,1,8) = 'ARBRCBAT' then
         arp_standard.debug('Defaulting instrument Assign Id. ');

	 /* Bug724495, Bills Receivable batch program will create BR based on
	    the drawee bank account (instr_assign_id) irrespective of receipt
	    method set to One Per Customer or Per Customer Due Date or Per
	    Invoice or Per Payment Sschedule or Per Site or Per Site Due Date */

	 Begin
          Select instr_assignment_id
	  Into l_instr_id
          from ra_customer_Trx_lines brlines,
               ra_customer_trx   ct,
               iby_trxn_extensions_v iby
          where ct.customer_trx_id = brlines.br_ref_customer_trx_id
          and ct.payment_trxn_extension_id = iby.trxn_extension_id
          and brlines.customer_trx_id = p_customer_trx_id
          and rownum = 1;

	  l_drawee_site_use_id := NVL(ARP_PROGRAM_BR_REMIT.get_site_use_id(
	                               p_cust_account_id   => l_drawee_id,
			               p_org_id            => l_org_id,
			               p_instr_id          => l_instr_id),
			              l_drawee_site_use_id);

          IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('Site_Use_ID to be passed: '|| l_drawee_site_use_id);
	  END IF;

         Exception
          When others then
              l_instr_id := Null ;
         End;
	Else
	 l_instr_id := Null;
	End IF;
	arp_standard.debug('Assign Id Value: ' ||l_instr_id );

            AR_BILLS_CREATION_PUB.create_br_trxn_extension(
        p_api_version           => 1.0,
        p_init_msg_list         => p_init_msg_list,
        p_commit                => p_commit,
        x_return_status         =>  x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data,
        p_customer_trx_id       => p_CUSTOMER_TRX_ID,
        p_trx_number            => l_trx_number,
        p_org_id                => l_org_id,
        p_drawee_id             => l_drawee_id,
        p_drawee_site_use_id    => l_drawee_site_use_id,
        p_payment_channel       => 'BILLS_RECEIVABLE',
        p_instrument_assign_id  => l_instr_id,
        p_payment_trxn_extn_id  => l_payment_trxn_extension_id);

	      -- The values are based on FND_API.  S, E, U (Success, Error, Unexpected
	      IF x_return_status <>  'S'
	      THEN
        	FND_MESSAGE.set_name( 'AR'          , 'AR_BR_CANNOT_COMPLETE' );
	        FND_MESSAGE.set_token( 'BRNUM'      ,  l_trx_rec.trx_number);
 		arp_standard.debug('Call to  AR_BILLS_CREATION_PUB.create_br_trxn_extension Errored');
        	app_exception.raise_exception;
  	      END IF;

  	update ra_customer_trx
	set payment_trxn_extension_id = l_payment_trxn_extension_id
	where customer_trx_id = p_customer_trx_id;

      end if;



       /*--------------------------------------------------------------------+
        |   ============  START OF API BODY - COMPLETE BR ===================|
        +--------------------------------------------------------------------*/


	/*-----------------------------------------------+
        |   Action Validation				 |
        +-----------------------------------------------*/

	l_action			:=	C_COMPLETE;

	AR_BILLS_MAINTAIN_STATUS_PUB.validate_actions (
		p_customer_trx_id	=>  p_customer_trx_id	,
		p_complete_flag		=>  C_ACTION_REC.complete_flag,
		p_uncomplete_flag	=>  C_ACTION_REC.uncomplete_flag,
		p_accept_flag		=>  C_ACTION_REC.accept_flag,
		p_cancel_flag		=>  C_ACTION_REC.cancel_flag,
		p_select_remit_flag	=>  C_ACTION_REC.select_remit_flag,
		p_deselect_remit_flag	=>  C_ACTION_REC.deselect_remit_flag,
		p_approve_remit_flag	=>  C_ACTION_REC.approve_remit_flag,
		p_hold_flag		=>  C_ACTION_REC.hold_flag,
		p_unhold_flag		=>  C_ACTION_REC.unhold_flag,
		p_recall_flag		=>  C_ACTION_REC.recall_flag,
		p_eliminate_flag	=>  C_ACTION_REC.eliminate_flag,
		p_uneliminate_flag	=>  C_ACTION_REC.uneliminate_flag,
		p_unpaid_flag		=>  C_ACTION_REC.unpaid_flag,
		p_protest_flag		=>  C_ACTION_REC.protest_flag,
		p_endorse_flag		=>  C_ACTION_REC.endorse_flag,
		p_restate_flag		=>  C_ACTION_REC.restate_flag,
		p_exchange_flag		=>  C_ACTION_REC.exchange_flag,
		p_delete_flag		=>  C_ACTION_REC.delete_flag);


	-- Do not continue if the action is not allowed for the BR

	IF	(C_ACTION_REC.complete_flag	<>	'Y')
	THEN
	    IF PG_DEBUG in ('Y', 'C') THEN
	       arp_util.debug( '>>>>>>>>>> The action ' || l_action || ' is not allowed on the BR ' || p_customer_trx_id);
	    END IF;
	    FND_MESSAGE.set_name( 'AR'		, 'AR_BR_CANNOT_COMPLETE' );
	    FND_MESSAGE.set_token( 'BRNUM' 	,  l_trx_rec.trx_number);
	    app_exception.raise_exception;
	END IF;

        ARP_CT_PKG.lock_fetch_p (l_trx_rec, p_customer_trx_id);


       /*-----------------------------------------------+
        |   Data preparation 				|
        +-----------------------------------------------*/

	l_trh_rec.customer_trx_id	:=	p_customer_trx_id;
	ARP_TRANSACTION_HISTORY_PKG.lock_fetch_f_trx_id (l_trh_rec);



       /*-----------------------------------------------+
        |   Data Validation				|
        +-----------------------------------------------*/

        AR_BILLS_MAINTAIN_VAL_PVT.validate_Complete_BR (l_trx_rec, l_trh_rec.gl_date);



	/*-----------------------------------------------+
        |   Document Sequence Routine 			 |
        +-----------------------------------------------*/

	AR_BILLS_MAINTAIN_LIB_PVT.get_doc_seq ( 222				,
						l_trx_rec			,
						arp_global.set_of_books_id	,
						'M'				);

	/*-----------------------------------------------+
        |   BR Completion 				 |
        +------------------------------------------------*/

	IF  (AR_BILLS_MAINTAIN_STATUS_PUB.is_acceptance_required(l_trx_rec.cust_trx_type_id))
	THEN
		AR_BILLS_MAINTAIN_LIB_PVT.Complete_Acc_Required (p_customer_trx_id);
		l_trh_rec.postable_flag			:= 	'N'	;
		l_trh_rec.current_accounted_flag	:= 	'N'	;
	ELSE
		AR_BILLS_MAINTAIN_LIB_PVT.Complete_OR_Accept (l_trh_rec);
		l_trh_rec.postable_flag			:=  	'Y'	;
		l_trh_rec.current_accounted_flag	:=  	'Y'	;
	END IF;


	/*-----------------------------------------------+
        |   Update the Complete Flag in the BR Header	 |
        +------------------------------------------------*/

	l_trx_rec.complete_flag		:=	'Y';

	ARP_PROCESS_BR_HEADER.update_header  (l_trx_rec, l_trx_rec.customer_trx_id);


	/*-----------------------------------------------+
        |   Insertion in Transaction History Table	 |
        +------------------------------------------------*/


	-- Fetch the new status and new event of the BR

	AR_BILLS_MAINTAIN_STATUS_PUB.New_Status_Event (
			p_trx_rec	=>	l_trx_rec	,
			p_action        =>	l_action	,
			p_new_status	=>	l_trh_rec.status,
			p_new_event	=>	l_trh_rec.event	);

	l_trh_rec.transaction_history_id:=	NULL		;
	l_trh_rec.current_record_flag	:=  	'Y'		;
	l_trh_rec.prv_trx_history_id	:=  	NULL		;
	l_trh_rec.comments		:=  	NULL		;
	l_trh_rec.posting_control_id    := 	-3           	;
	l_trh_rec.gl_posted_date        :=  	NULL        	;
	l_trh_rec.first_posted_record_flag := 	'N'		;
	l_trh_rec.created_from		:=	'ARBRMAIB'	;
	l_trh_rec.batch_id		:=	NULL		;
        l_trh_rec.org_id                :=      l_trx_rec.org_id;

	arp_proc_transaction_history.insert_transaction_history (l_trh_rec	,
								 l_trh_rec.transaction_history_id);

	/*-----------------------------------------------+
        |   Output parameters				 |
        +------------------------------------------------*/

	p_trx_number			:=	l_trx_rec.trx_number		;
	p_doc_sequence_value		:=	l_trx_rec.doc_sequence_value	;
	p_doc_sequence_id		:=	l_trx_rec.doc_sequence_id	;
	p_old_trx_number		:=	l_trx_rec.old_trx_number	;
	p_status			:=	l_trh_rec.status		;



       /*-----------------------------------------------+
        |   Standard check of p_commit   		|
        +-----------------------------------------------*/

        IF FND_API.To_Boolean( p_commit )
        THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug( 'committing');
            END IF;
            Commit;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('AR_BILLS_MAINTAIN_PUB.Complete_BR()- ');
        END IF;


EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;
                ROLLBACK TO Complete_BR_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
  	        IF PG_DEBUG in ('Y', 'C') THEN
  	           arp_util.debug( 'Exception Error');
  	        END IF;
		raise;


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;
                ROLLBACK TO Complete_BR_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( 'Exception Unexpected Error');
		END IF;
		RAISE;


        WHEN OTHERS THEN
               /*-------------------------------------------------------+
                |  Handle application errors that result from trapable  |
                |  error conditions. The error messages have already    |
                |  been put on the error stack.                         |
                +-------------------------------------------------------*/

		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug ( 'SQLERRM : ' || SQLERRM);
		   arp_util.debug ( 'SQLCODE : ' || SQLCODE);
		END IF;

		IF (SQLCODE = -20001)
                THEN
    		      	IF PG_DEBUG in ('Y', 'C') THEN
    		      	   arp_util.debug( 'Exception Others -20001');
    		      	END IF;
                      	ROLLBACK TO Complete_BR_PVT;
                      	x_return_status := FND_API.G_RET_STS_ERROR ;
			RAISE;

                ELSE
                      IF PG_DEBUG in ('Y', 'C') THEN
                         arp_util.debug( 'Exception Others');
                      END IF;
		      NULL;
                END IF;

		ROLLBACK TO Complete_BR_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		RAISE;

END Complete_BR;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    UnComplete_BR			                                     	|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    UnCompletes a BR							     	|
 |									  	|
 +==============================================================================*/


PROCEDURE UnComplete_BR (

           --   *****  Standard API parameters *****

                p_api_version    		IN  	NUMBER					,
                p_init_msg_list    		IN  	VARCHAR2 := FND_API.G_TRUE		,
                p_commit           		IN  	VARCHAR2 := FND_API.G_FALSE		,
                p_validation_level 		IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL	,
                x_return_status    		OUT NOCOPY 	VARCHAR2				,
                x_msg_count        		OUT NOCOPY 	NUMBER					,
                x_msg_data         		OUT NOCOPY 	VARCHAR2				,

           --   *****  Input  parameters  *****

		p_customer_trx_id		IN  	NUMBER,

           --   *****  Output parameters  *****

		p_status			OUT NOCOPY 	VARCHAR2				)

IS
		l_api_name			CONSTANT VARCHAR2(20)	:=	'UnComplete_BR';
		l_api_version			CONSTANT NUMBER		:=	1.0;

		l_trx_rec			ra_customer_trx%ROWTYPE;
		l_trh_rec			ar_transaction_history%ROWTYPE;
		l_ps_id				ar_payment_schedules.payment_schedule_id%TYPE;

		l_acceptance_flag		VARCHAR2(1)	;

		l_action			VARCHAR2(30)	;

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_PUB.UnComplete_BR()+ ');
	END IF;
	x_msg_count				:=	NULL;
	x_msg_data				:=	NULL;
       /*-----------------------------------------------+
        |   Standard start of API savepoint     	|
        +-----------------------------------------------*/

      	SAVEPOINT UnComplete_BR_PVT;


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


       /*--------------------------------------------------------------+
        |   Initialize message list if p_init_msg_list is set to TRUE  |
        +--------------------------------------------------------------*/

        IF  FND_API.to_Boolean( p_init_msg_list )  THEN
 	             FND_MSG_PUB.initialize;
        END IF;


       /*-----------------------------------------------+
        |   Initialize return status to SUCCESS   	|
        +-----------------------------------------------*/

        x_return_status := FND_API.G_RET_STS_SUCCESS;


       /*-----------------------------------------------------------------------+
       |   ============  START OF API BODY - UNCOMPLETE BR  =================  	|
        +-----------------------------------------------------------------------*/


	/*-----------------------------------------------+
        |   Action Validation				 |
        +-----------------------------------------------*/

	l_action			:=	C_UNCOMPLETE;

	AR_BILLS_MAINTAIN_STATUS_PUB.validate_actions (
		p_customer_trx_id	=>  	p_customer_trx_id		,
		p_complete_flag		=>	C_ACTION_REC.complete_flag	,
		p_uncomplete_flag	=>	C_ACTION_REC.uncomplete_flag	,
		p_accept_flag		=>	C_ACTION_REC.accept_flag	,
		p_cancel_flag		=>	C_ACTION_REC.cancel_flag	,
		p_select_remit_flag	=>	C_ACTION_REC.select_remit_flag	,
		p_deselect_remit_flag	=>	C_ACTION_REC.deselect_remit_flag,
		p_approve_remit_flag	=>	C_ACTION_REC.approve_remit_flag	,
		p_hold_flag		=>	C_ACTION_REC.hold_flag		,
		p_unhold_flag		=>	C_ACTION_REC.unhold_flag	,
		p_recall_flag		=>	C_ACTION_REC.recall_flag	,
		p_eliminate_flag	=>	C_ACTION_REC.eliminate_flag	,
		p_uneliminate_flag	=>	C_ACTION_REC.uneliminate_flag	,
		p_unpaid_flag		=>	C_ACTION_REC.unpaid_flag	,
		p_protest_flag		=>	C_ACTION_REC.protest_flag	,
		p_endorse_flag		=>	C_ACTION_REC.endorse_flag	,
		p_restate_flag		=>	C_ACTION_REC.restate_flag	,
		p_exchange_flag		=>	C_ACTION_REC.exchange_flag	,
		p_delete_flag		=>	C_ACTION_REC.delete_flag	);


	-- Do not continue if the action is not allowed for the BR

	ARP_CT_PKG.lock_fetch_p (l_trx_rec, p_customer_trx_id);

	IF	(C_ACTION_REC.uncomplete_flag	<>	'Y')
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( '>>>>>>>>>> The action ' || l_action || ' is not allowed on the BR ' || p_customer_trx_id);
		END IF;
		FND_MESSAGE.set_name	( 'AR', 'AR_BR_CANNOT_INCOMPLETE' );
		FND_MESSAGE.set_token	( 'BRNUM' 	,  l_trx_rec.trx_number);
		app_exception.raise_exception;
	END IF;



       /*-----------------------------------------------+
        |   Data preparation 				|
        +-----------------------------------------------*/

	l_trh_rec.customer_trx_id	:=	p_customer_trx_id;
	ARP_TRANSACTION_HISTORY_PKG.lock_fetch_f_trx_id (l_trh_rec);


	IF  (AR_BILLS_MAINTAIN_STATUS_PUB.is_acceptance_required(l_trx_rec.cust_trx_type_id))
	THEN
		l_acceptance_flag := 'Y';
	ELSE
		l_acceptance_flag := 'N';
	END IF;


	/*-----------------------------------------------+
        |   BR UnCompletion 				 |
        +------------------------------------------------*/


	AR_BILLS_MAINTAIN_LIB_PVT.Reverse_Assignments_Adjustment (l_trh_rec, l_acceptance_flag);


	/*-----------------------------------------------+
        |   Update the Complete Flag in the BR Header	 |
        +------------------------------------------------*/

	l_trx_rec.complete_flag		:=	'N';

	ARP_PROCESS_BR_HEADER.update_header  (  l_trx_rec	,
						l_trx_rec.customer_trx_id);

	/*-----------------------------------------------+
        |   Insertion in Transaction History Table	 |
        +------------------------------------------------*/

	-- Fetch the new status and new event of the BR

	AR_BILLS_MAINTAIN_STATUS_PUB.New_Status_Event (
			p_trx_rec	=>	l_trx_rec	,
			p_action        =>	l_action	,
			p_new_status	=>	l_trh_rec.status,
			p_new_event	=>	l_trh_rec.event	);

	l_trh_rec.transaction_history_id:=	NULL		;
	l_trh_rec.postable_flag		:=  	'N'		;
	l_trh_rec.current_accounted_flag:=  	'N'		;
	l_trh_rec.current_record_flag	:=  	'Y'		;
	l_trh_rec.prv_trx_history_id	:=  	NULL		;
	l_trh_rec.comments		:=  	NULL		;
	l_trh_rec.posting_control_id    := 	-3           	;
	l_trh_rec.gl_posted_date        :=  	NULL    	;
	l_trh_rec.first_posted_record_flag  := 	'N'		;
	l_trh_rec.created_from		:=  	'ARBRMAIB'	;
	l_trh_rec.batch_id		:=	NULL		;

	arp_proc_transaction_history.insert_transaction_history (l_trh_rec	,
								 l_trh_rec.transaction_history_id);


	/*-----------------------------------------------+
        |   Delete the BR Payment Schedule		 |
        +------------------------------------------------*/

	IF  (l_acceptance_flag = 'N')
	THEN
        --  Bug 2057740:
        --  Commenting out NOCOPY and calling delete_f_Ct_id instead because
        --  there is already a routine to delete ps by cust_trx_id.
        --  no need to call another routine to find the ps id first.
	--  AR_BILLS_CREATION_LIB_PVT.Get_Payment_Schedule_Id (
        --                               p_customer_trx_id, l_ps_id);
        --  arp_ps_pkg.delete_p (l_ps_id);

            arp_ps_pkg.delete_f_ct_id(p_customer_trx_id);
	END IF;


	/*-----------------------------------------------+
        |   Output parameter				 |
        +------------------------------------------------*/

	p_status		:=	l_trh_rec.status	;


       /*-----------------------------------------------+
        |   Standard check of p_commit   		|
        +-----------------------------------------------*/

        IF FND_API.To_Boolean( p_commit )
        THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug( 'committing');
            END IF;
            Commit;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('AR_BILLS_MAINTAIN_PUB.UnComplete_BR()- ');
        END IF;


EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;
                ROLLBACK TO UnComplete_BR_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
  	        IF PG_DEBUG in ('Y', 'C') THEN
  	           arp_util.debug( 'Exception Error');
  	        END IF;
		raise;


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;
                ROLLBACK TO UnComplete_BR_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( 'Exception Unexpected Error');
		END IF;
		raise;


        WHEN OTHERS THEN
               /*-------------------------------------------------------+
                |  Handle application errors that result from trapable  |
                |  error conditions. The error messages have already    |
                |  been put on the error stack.                         |
                +-------------------------------------------------------*/

		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug ( 'SQLERRM : ' || SQLERRM);
		   arp_util.debug ( 'SQLCODE : ' || SQLCODE);
		END IF;

		IF (SQLCODE = -20001)
                THEN
    		      	IF PG_DEBUG in ('Y', 'C') THEN
    		      	   arp_util.debug( 'Exception Others -20001');
    		      	END IF;
                      	ROLLBACK TO UnComplete_BR_PVT;
                      	x_return_status := FND_API.G_RET_STS_ERROR ;
			RAISE;
                ELSE
                      	IF PG_DEBUG in ('Y', 'C') THEN
                      	   arp_util.debug( 'Exception Others');
                      	END IF;
		      	NULL;
                END IF;

                ROLLBACK TO UnComplete_BR_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		RAISE;

END UnComplete_BR;



/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Accept_BR				                                     	|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    Accepts a BR							     	|
 |									  	|
 +==============================================================================*/


PROCEDURE Accept_BR (

           --   *****  Standard API parameters *****

                p_api_version      		IN  	NUMBER					,
                p_init_msg_list    		IN  	VARCHAR2 := FND_API.G_TRUE		,
                p_commit           		IN  	VARCHAR2 := FND_API.G_FALSE		,
                p_validation_level 		IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL	,
                x_return_status    		OUT NOCOPY 	VARCHAR2				,
                x_msg_count        		OUT NOCOPY 	NUMBER					,
                x_msg_data         		OUT NOCOPY 	VARCHAR2				,

           --   *****  Input  parameters  *****

		p_customer_trx_id		IN  	NUMBER			,
		p_acceptance_date		IN  	DATE			,
		p_acceptance_gl_date		IN  	DATE			,
		p_acceptance_comments		IN  	VARCHAR2		,

           --   *****  Output parameters  *****

		p_status			OUT NOCOPY VARCHAR2					)

IS
		l_api_name			CONSTANT VARCHAR2(20)	:=	'Accept_BR';
		l_api_version			CONSTANT NUMBER		:=	1.0;

		l_trx_rec			ra_customer_trx%ROWTYPE;
		l_trh_rec			ar_transaction_history%ROWTYPE;

		l_action			VARCHAR2(30);

		l_trx_date			DATE;
		l_gl_date			DATE;
                l_mesg                          VARCHAR2(2000);

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug( 'AR_BILLS_MAINTAIN_PUB.Accept()+ ');
	END IF;

	x_msg_count				:=	NULL;
	x_msg_data				:=	NULL;

       /*-----------------------------------------------+
        |   Standard start of API savepoint     	|
        +-----------------------------------------------*/

      	SAVEPOINT Accept_BR_PVT;


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


       /*--------------------------------------------------------------+
        |   Initialize message list if p_init_msg_list is set to TRUE  |
        +--------------------------------------------------------------*/

        IF  FND_API.to_Boolean( p_init_msg_list )  THEN
 	             FND_MSG_PUB.initialize;
        END IF;


       /*-----------------------------------------------+
        |   Initialize return status to SUCCESS   	|
        +-----------------------------------------------*/

        x_return_status := FND_API.G_RET_STS_SUCCESS;


        /*-----------------------------------------------------------------------+
        |   ============  START OF API BODY - ACCEPT BR   ===================  	 |
        +-----------------------------------------------------------------------*/


	/*-----------------------------------------------+
        |   Action Validation				 |
        +-----------------------------------------------*/

	l_action			:=	C_ACCEPT;

	AR_BILLS_MAINTAIN_STATUS_PUB.validate_actions (
		p_customer_trx_id	=>  	p_customer_trx_id		,
		p_complete_flag		=>	C_ACTION_REC.complete_flag	,
		p_uncomplete_flag	=>	C_ACTION_REC.uncomplete_flag	,
		p_accept_flag		=>	C_ACTION_REC.accept_flag	,
		p_cancel_flag		=>	C_ACTION_REC.cancel_flag	,
		p_select_remit_flag	=>	C_ACTION_REC.select_remit_flag	,
		p_deselect_remit_flag	=>	C_ACTION_REC.deselect_remit_flag,
		p_approve_remit_flag	=>	C_ACTION_REC.approve_remit_flag	,
		p_hold_flag		=>	C_ACTION_REC.hold_flag		,
		p_unhold_flag		=>	C_ACTION_REC.unhold_flag	,
		p_recall_flag		=>	C_ACTION_REC.recall_flag	,
		p_eliminate_flag	=>	C_ACTION_REC.eliminate_flag	,
		p_uneliminate_flag	=>	C_ACTION_REC.uneliminate_flag	,
		p_unpaid_flag		=>	C_ACTION_REC.unpaid_flag	,
		p_protest_flag		=>	C_ACTION_REC.protest_flag	,
		p_endorse_flag		=>	C_ACTION_REC.endorse_flag	,
		p_restate_flag		=>	C_ACTION_REC.restate_flag	,
		p_exchange_flag		=>	C_ACTION_REC.exchange_flag	,
		p_delete_flag		=>	C_ACTION_REC.delete_flag	);

	-- Do not continue if the action is not allowed for the BR

	ARP_CT_PKG.lock_fetch_p (l_trx_rec, p_customer_trx_id);

	IF	(C_ACTION_REC.accept_flag	<>	'Y')
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( '>>>>>>>>>> The action ' || l_action || ' is not allowed on the BR ' || p_customer_trx_id);
		END IF;
		FND_MESSAGE.set_name	( 'AR', 'AR_BR_CANNOT_ACCEPT' );
		FND_MESSAGE.set_token	( 'BRNUM' 	,  l_trx_rec.trx_number);
		app_exception.raise_exception;
	END IF;


       /*-----------------------------------------------+
        |   Data Preparation				|
        +-----------------------------------------------*/

	l_trh_rec.customer_trx_id	:=	p_customer_trx_id;
	ARP_TRANSACTION_HISTORY_PKG.lock_fetch_f_trx_id (l_trh_rec);

	l_trx_date		:=	trunc(p_acceptance_date)	;
	l_gl_date		:=	trunc(p_acceptance_gl_date)	;


       /*-----------------------------------------------+
        |   Data Defaulting				|
        +-----------------------------------------------*/

	AR_BILLS_MAINTAIN_LIB_PVT.Default_Action_Dates (l_trx_date, l_gl_date);


       /*-----------------------------------------------+
        |   Data Validation				|
        +-----------------------------------------------*/

        l_mesg := arp_standard.FND_MESSAGE('AR_BR_SPMENU_ACCEPTANCE');
	AR_BILLS_MAINTAIN_VAL_PVT.validate_Action_Dates (l_trx_date, l_gl_date, l_trh_rec, l_mesg);

	l_trh_rec.trx_date	:=	l_trx_date	;
	l_trh_rec.gl_date	:=	l_gl_date	;
	l_trh_rec.comments	:=	p_acceptance_comments;

        AR_BILLS_MAINTAIN_VAL_PVT.validate_Accept_BR (l_trx_rec, l_trh_rec);


	/*-----------------------------------------------+
        |   BR Acceptance 				 |
        +------------------------------------------------*/

	AR_BILLS_MAINTAIN_LIB_PVT.Complete_OR_Accept (l_trh_rec);


	/*-----------------------------------------------+
        |   Insertion in Transaction History Table	 |
        +------------------------------------------------*/

	-- Fetch the new status and new event of the BR

	AR_BILLS_MAINTAIN_STATUS_PUB.New_Status_Event (
			p_trx_rec	=>	l_trx_rec	,
			p_action        =>	l_action	,
			p_new_status	=>	l_trh_rec.status,
			p_new_event	=>	l_trh_rec.event	);

	l_trh_rec.transaction_history_id:=	NULL		;
	l_trh_rec.postable_flag		:=  	'Y'		;
	l_trh_rec.current_accounted_flag:=  	'Y'		;
	l_trh_rec.current_record_flag	:=  	'Y'		;
	l_trh_rec.prv_trx_history_id	:=  	NULL		;
	l_trh_rec.posting_control_id    := 	-3           	;
	l_trh_rec.gl_posted_date        :=  	NULL       	;
	l_trh_rec.first_posted_record_flag  := 	'N'		;
	l_trh_rec.created_from		:=  	'ARBRMAIB'	;
	l_trh_rec.batch_id		:=	NULL		;
        l_trh_rec.org_id                :=      l_trx_rec.org_id;

	arp_proc_transaction_history.insert_transaction_history (l_trh_rec	,
								 l_trh_rec.transaction_history_id);

	/*-----------------------------------------------+
        |   Output parameter				 |
        +------------------------------------------------*/

	p_status		:=	l_trh_rec.status	;


       /*-----------------------------------------------+
        |   Standard check of p_commit   		|
        +-----------------------------------------------*/

        IF FND_API.To_Boolean( p_commit )
        THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug( 'committing');
            END IF;
            Commit;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug( 'AR_BILLS_MAINTAIN_PUB.Accept()- ');
        END IF;


EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;
                ROLLBACK TO Accept_BR_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
  	        IF PG_DEBUG in ('Y', 'C') THEN
  	           arp_util.debug( 'Exception Error');
  	        END IF;
		RAISE;


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;
                ROLLBACK TO Accept_BR_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( 'Exception Unexpected Error');
		END IF;
		RAISE;


        WHEN OTHERS THEN
               /*-------------------------------------------------------+
                |  Handle application errors that result from trapable  |
                |  error conditions. The error messages have already    |
                |  been put on the error stack.                         |
                +-------------------------------------------------------*/

		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug ( 'SQLERRM : ' || SQLERRM);
		   arp_util.debug ( 'SQLCODE : ' || SQLCODE);
		END IF;

		IF (SQLCODE = -20001)
                THEN
    		      	ROLLBACK TO Accept_BR_PVT;
                      	x_return_status := FND_API.G_RET_STS_ERROR ;
			RAISE;
                ELSE
		      	NULL;
                END IF;

                ROLLBACK TO Accept_BR_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		RAISE;


END Accept_BR;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Hold_BR				                                     	|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    Put a BR on hold							     	|
 |									  	|
 +==============================================================================*/


PROCEDURE Hold_BR (

           --   *****  Standard API parameters *****

                p_api_version      		IN  	NUMBER					,
                p_init_msg_list    		IN  	VARCHAR2 := FND_API.G_TRUE		,
                p_commit           		IN  	VARCHAR2 := FND_API.G_FALSE		,
                p_validation_level 		IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL	,
                x_return_status    		OUT NOCOPY 	VARCHAR2				,
                x_msg_count        		OUT NOCOPY 	NUMBER					,
                x_msg_data         		OUT NOCOPY 	VARCHAR2				,

           --   *****  Input  parameters  *****

		p_customer_trx_id		IN  	NUMBER			,

           --   *****  Output parameters  *****

		p_status			OUT NOCOPY 	VARCHAR2				)

IS
		l_api_name			CONSTANT VARCHAR2(20)	:=	'Hold_BR';
		l_api_version			CONSTANT NUMBER		:=	1.0;
		l_trh_rec			ar_transaction_history%ROWTYPE;
		l_trx_rec			ra_customer_trx%ROWTYPE;
		l_ps_rec			ar_payment_schedules%ROWTYPE;

		l_action			VARCHAR2(30);

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_PUB.Hold_BR()+ ');
	END IF;

	x_msg_count				:=	NULL;
	x_msg_data				:=	NULL;

       /*-----------------------------------------------+
        |   Standard start of API savepoint     	|
        +-----------------------------------------------*/

      	SAVEPOINT Hold_BR_PVT;


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


       /*--------------------------------------------------------------+
        |   Initialize message list if p_init_msg_list is set to TRUE  |
        +--------------------------------------------------------------*/

        IF  FND_API.to_Boolean( p_init_msg_list )  THEN
 	             FND_MSG_PUB.initialize;
        END IF;


       /*-----------------------------------------------+
        |   Initialize return status to SUCCESS   	|
        +-----------------------------------------------*/

        x_return_status := FND_API.G_RET_STS_SUCCESS;


       /*-----------------------------------------------------------------------+
        |   ============  START OF API BODY - HOLD BR ===================  	|
        +-----------------------------------------------------------------------*/

	/*-----------------------------------------------+
        |   Validate the action				|
        +-----------------------------------------------*/

	l_action			:=	C_HOLD;

	AR_BILLS_MAINTAIN_STATUS_PUB.validate_actions (
		p_customer_trx_id	=>  	p_customer_trx_id		,
		p_complete_flag		=>	C_ACTION_REC.complete_flag	,
		p_uncomplete_flag	=>	C_ACTION_REC.uncomplete_flag	,
		p_accept_flag		=>	C_ACTION_REC.accept_flag	,
		p_cancel_flag		=>	C_ACTION_REC.cancel_flag	,
		p_select_remit_flag	=>	C_ACTION_REC.select_remit_flag	,
		p_deselect_remit_flag	=>	C_ACTION_REC.deselect_remit_flag,
		p_approve_remit_flag	=>	C_ACTION_REC.approve_remit_flag	,
		p_hold_flag		=>	C_ACTION_REC.hold_flag		,
		p_unhold_flag		=>	C_ACTION_REC.unhold_flag	,
		p_recall_flag		=>	C_ACTION_REC.recall_flag	,
		p_eliminate_flag	=>	C_ACTION_REC.eliminate_flag	,
		p_uneliminate_flag	=>	C_ACTION_REC.uneliminate_flag	,
		p_unpaid_flag		=>	C_ACTION_REC.unpaid_flag	,
		p_protest_flag		=>	C_ACTION_REC.protest_flag	,
		p_endorse_flag		=>	C_ACTION_REC.endorse_flag	,
		p_restate_flag		=>	C_ACTION_REC.restate_flag	,
		p_exchange_flag		=>	C_ACTION_REC.exchange_flag	,
		p_delete_flag		=>	C_ACTION_REC.delete_flag	);


	-- Do not continue if the action is not allowed for the BR

	ARP_CT_PKG.fetch_p (l_trx_rec, p_customer_trx_id);

	IF	(C_ACTION_REC.hold_flag	<>	'Y')
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( '>>>>>>>>>> The action ' || l_action || ' is not allowed on the BR ' || p_customer_trx_id);
		END IF;
		FND_MESSAGE.set_name	( 'AR', 'AR_BR_CANNOT_HOLD' );
		FND_MESSAGE.set_token	( 'BRNUM' 	,  l_trx_rec.trx_number);
		app_exception.raise_exception;
	END IF;



       /*-----------------------------------------------+
        |   Data Preparation				|
        +-----------------------------------------------*/

	l_trh_rec.customer_trx_id	:=	p_customer_trx_id;
	ARP_TRANSACTION_HISTORY_PKG.lock_fetch_f_trx_id (l_trh_rec);


	/*----------------------------------------------+
        |    Update the Payment Schedule of the BR 	|
        +-----------------------------------------------*/

	AR_BILLS_CREATION_LIB_PVT.Get_Payment_Schedule_Id (p_customer_trx_id, l_ps_rec.payment_schedule_id);

	AR_BILLS_MAINTAIN_LIB_PVT.update_reserved_columns (l_ps_rec.payment_schedule_id, 'USER' , p_customer_trx_id);



	/*----------------------------------------------+
        |    Update the Hold Flag in the BR Header	|
        +-----------------------------------------------*/

	l_trx_rec.br_on_hold_flag	:=	'Y';

	ARP_PROCESS_BR_HEADER.update_header (l_trx_rec, l_trx_rec.customer_trx_id);



	/*----------------------------------------------+
        |    Insert a Transaction History Record 	|
        +-----------------------------------------------*/

	-- Fetch the new status and new event of the BR

	AR_BILLS_MAINTAIN_STATUS_PUB.New_Status_Event (
			p_trx_rec	=>	l_trx_rec	,
			p_action        =>	l_action	,
			p_new_status	=>	l_trh_rec.status,
			p_new_event	=>	l_trh_rec.event	);


	l_trh_rec.transaction_history_id:=	NULL		;
	l_trh_rec.postable_flag		:=  	'N'		;
	l_trh_rec.current_accounted_flag:=  	'N'		;
	l_trh_rec.current_record_flag	:=  	'Y'		;
	l_trh_rec.prv_trx_history_id	:=  	NULL		;
	l_trh_rec.comments		:=  	NULL		;
	l_trh_rec.posting_control_id    := 	-3           	;
	l_trh_rec.gl_posted_date        :=  	NULL        	;
	l_trh_rec.first_posted_record_flag  := 	'N'		;
	l_trh_rec.created_from		:=  	'ARBRMAIB'	;
	l_trh_rec.batch_id		:=	NULL		;

	IF	(l_trh_rec.trx_date < sysdate)
	THEN
		l_trh_rec.trx_date	:=	trunc(sysdate);
	END IF;


	arp_proc_transaction_history.insert_transaction_history (l_trh_rec, l_trh_rec.transaction_history_id);


	/*-----------------------------------------------+
        |   Output parameter				 |
        +------------------------------------------------*/

	p_status			:=  l_trh_rec.status;


       /*-----------------------------------------------+
        |   Standard check of p_commit   		|
        +-----------------------------------------------*/

        IF FND_API.To_Boolean( p_commit )
        THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug( 'committing');
            END IF;
            Commit;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug( 'AR_BILLS_MAINTAIN_PUB.Hold()- ');
        END IF;


EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;
                ROLLBACK TO Hold_BR_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
	        IF PG_DEBUG in ('Y', 'C') THEN
	           arp_util.debug( 'Exception Error');
	        END IF;
		RAISE;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;
                ROLLBACK TO Hold_BR_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( 'Exception Unexpected Error');
		END IF;
		RAISE;

        WHEN OTHERS THEN
               /*-------------------------------------------------------+
                |  Handle application errors that result from trapable  |
                |  error conditions. The error messages have already    |
                |  been put on the error stack.                         |
                +-------------------------------------------------------*/

		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug ( 'SQLERRM : ' || SQLERRM);
		   arp_util.debug ( 'SQLCODE : ' || SQLCODE);
		END IF;

		IF (SQLCODE = -20001)
                THEN
                      	ROLLBACK TO Hold_BR_PVT;
                      	x_return_status := FND_API.G_RET_STS_ERROR ;
	               	RAISE;
                ELSE
		      	NULL;
                END IF;

                ROLLBACK TO Hold_BR_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		RAISE;

END Hold_BR;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    UnHold_BR				                                     	|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    Releases a BR from hold						     	|
 |									  	|
 +==============================================================================*/


PROCEDURE UnHold_BR (

           --   *****  Standard API parameters *****

                p_api_version      		IN  	NUMBER					,
                p_init_msg_list    		IN  	VARCHAR2 := FND_API.G_TRUE		,
                p_commit           		IN  	VARCHAR2 := FND_API.G_FALSE		,
                p_validation_level 		IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL	,
                x_return_status    		OUT NOCOPY 	VARCHAR2				,
                x_msg_count        		OUT NOCOPY 	NUMBER					,
                x_msg_data         		OUT NOCOPY 	VARCHAR2				,

           --   *****  Input  parameters  *****

		p_customer_trx_id		IN  	NUMBER			,

           --   *****  Output parameters  *****

		p_status			OUT NOCOPY 	VARCHAR2				)

IS
		l_api_name			CONSTANT VARCHAR2(20)	:=	'UnHold_BR';
		l_api_version			CONSTANT NUMBER		:=	1.0;

		l_trh_rec			ar_transaction_history%ROWTYPE;
		l_trx_rec			ra_customer_trx%ROWTYPE;
		l_ps_rec			ar_payment_schedules%ROWTYPE;
		l_action			VARCHAR2(30);

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_PUB.UnHold_BR()+ ');
	END IF;

	x_msg_count				:=	NULL;
	x_msg_data				:=	NULL;

       /*-----------------------------------------------+
        |   Standard start of API savepoint     	|
        +-----------------------------------------------*/

      	SAVEPOINT UnHold_BR_PVT;


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


       /*--------------------------------------------------------------+
        |   Initialize message list if p_init_msg_list is set to TRUE  |
        +--------------------------------------------------------------*/

        IF  FND_API.to_Boolean( p_init_msg_list )  THEN
 	             FND_MSG_PUB.initialize;
        END IF;


       /*-----------------------------------------------+
        |   Initialize return status to SUCCESS   	|
        +-----------------------------------------------*/

        x_return_status := FND_API.G_RET_STS_SUCCESS;


       /*-----------------------------------------------------------------------+
       |   ============  START OF API BODY - UNHOLD BR   ===================  	|
        +-----------------------------------------------------------------------*/

	/*-----------------------------------------------+
        |   Validate the action				|
        +-----------------------------------------------*/

	l_action			:=	C_UNHOLD;

	AR_BILLS_MAINTAIN_STATUS_PUB.validate_actions (
		p_customer_trx_id	=>  	p_customer_trx_id		,
		p_complete_flag		=>	C_ACTION_REC.complete_flag	,
		p_uncomplete_flag	=>	C_ACTION_REC.uncomplete_flag	,
		p_accept_flag		=>	C_ACTION_REC.accept_flag	,
		p_cancel_flag		=>	C_ACTION_REC.cancel_flag	,
		p_select_remit_flag	=>	C_ACTION_REC.select_remit_flag	,
		p_deselect_remit_flag	=>	C_ACTION_REC.deselect_remit_flag,
		p_approve_remit_flag	=>	C_ACTION_REC.approve_remit_flag	,
		p_hold_flag		=>	C_ACTION_REC.hold_flag		,
		p_unhold_flag		=>	C_ACTION_REC.unhold_flag	,
		p_recall_flag		=>	C_ACTION_REC.recall_flag	,
		p_eliminate_flag	=>	C_ACTION_REC.eliminate_flag	,
		p_uneliminate_flag	=>	C_ACTION_REC.uneliminate_flag	,
		p_unpaid_flag		=>	C_ACTION_REC.unpaid_flag	,
		p_protest_flag		=>	C_ACTION_REC.protest_flag	,
		p_endorse_flag		=>	C_ACTION_REC.endorse_flag	,
		p_restate_flag		=>	C_ACTION_REC.restate_flag	,
		p_exchange_flag		=>	C_ACTION_REC.exchange_flag	,
		p_delete_flag		=>	C_ACTION_REC.delete_flag	);


	-- Do not continue if the action is not allowed for the BR

	ARP_CT_PKG.fetch_p (l_trx_rec, p_customer_trx_id);

	IF	(C_ACTION_REC.unhold_flag	<>	'Y')
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( '>>>>>>>>>> The action ' || l_action || ' is not allowed on the BR ' || p_customer_trx_id);
		END IF;
		FND_MESSAGE.set_name	( 'AR', 'AR_BR_CANNOT_UNHOLD' );
		FND_MESSAGE.set_token	( 'BRNUM' 	,  l_trx_rec.trx_number);
		app_exception.raise_exception;
	END IF;


       /*-----------------------------------------------+
        |   Data Preparation				|
        +-----------------------------------------------*/

	l_trh_rec.customer_trx_id	:=	p_customer_trx_id;
	ARP_TRANSACTION_HISTORY_PKG.lock_fetch_f_trx_id (l_trh_rec);


	/*----------------------------------------------+
        |    Updates the Payment Schedule of the BR 	|
        +-----------------------------------------------*/

	AR_BILLS_CREATION_LIB_PVT.Get_Payment_Schedule_Id (p_customer_trx_id, l_ps_rec.payment_schedule_id);

	AR_BILLS_MAINTAIN_LIB_PVT.update_reserved_columns (l_ps_rec.payment_schedule_id, NULL, NULL);


	/*----------------------------------------------+
        |    Update the Hold Flag in the BR Header	|
        +-----------------------------------------------*/

	l_trx_rec.br_on_hold_flag	:=	'N';

	ARP_PROCESS_BR_HEADER.update_header (l_trx_rec,	l_trx_rec.customer_trx_id);


	/*----------------------------------------------+
        |    Insert a Transaction History Record 	|
        +-----------------------------------------------*/

	-- Fetch the new status and new event of the BR

	AR_BILLS_MAINTAIN_STATUS_PUB.New_Status_Event (
			p_trx_rec	=>	l_trx_rec	,
			p_action        =>	l_action	,
			p_new_status	=>	l_trh_rec.status,
			p_new_event	=>	l_trh_rec.event	);

	l_trh_rec.transaction_history_id:=	NULL		;
	l_trh_rec.postable_flag		:=  	'N'		;
	l_trh_rec.current_accounted_flag:=  	'N'		;
	l_trh_rec.current_record_flag	:=  	'Y'		;
	l_trh_rec.prv_trx_history_id	:=  	NULL		;
	l_trh_rec.comments		:=  	NULL		;
	l_trh_rec.posting_control_id    := 	-3           	;
	l_trh_rec.gl_posted_date        :=  	NULL	        ;
	l_trh_rec.first_posted_record_flag  := 	'N'		;
	l_trh_rec.created_from		:=  	'ARBRMAIB'	;
	l_trh_rec.batch_id		:=	NULL		;

	IF	(l_trh_rec.trx_date < sysdate)
	THEN
		l_trh_rec.trx_date	:=	trunc(sysdate);
	END IF;

	arp_proc_transaction_history.insert_transaction_history (l_trh_rec, l_trh_rec.transaction_history_id);


	/*-----------------------------------------------+
        |   Output parameter				 |
        +------------------------------------------------*/

	p_status			:=  l_trh_rec.status;


       /*-----------------------------------------------+
        |   Standard check of p_commit   		|
        +-----------------------------------------------*/

        IF FND_API.To_Boolean( p_commit )
        THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug( 'committing');
            END IF;
            Commit;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug( 'AR_BILLS_MAINTAIN_PUB.UnHold()- ');
        END IF;


EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;
                ROLLBACK TO UnHold_BR_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
  	        IF PG_DEBUG in ('Y', 'C') THEN
  	           arp_util.debug( 'Exception Error');
  	        END IF;
		RAISE;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;
                ROLLBACK TO UnHold_BR_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( 'Exception Unexpected Error');
		END IF;
		RAISE;

        WHEN OTHERS THEN
               /*-------------------------------------------------------+
                |  Handle application errors that result from trapable  |
                |  error conditions. The error messages have already    |
                |  been put on the error stack.                         |
                +-------------------------------------------------------*/

		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;

		IF (SQLCODE = -20001)
                THEN
                      	ROLLBACK TO UnHold_BR_PVT;
                      	x_return_status := FND_API.G_RET_STS_ERROR ;
			RAISE;
                ELSE
		      	NULL;
                END IF;

                ROLLBACK TO UnHold_BR_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		RAISE;

END UnHold_BR;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Select_BR_remit			                                     	|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    Selects a BR for remittance					     	|
 |									  	|
 +==============================================================================*/


PROCEDURE Select_BR_Remit (

           --   *****  Input  parameters  *****

		p_batch_id			IN  	NUMBER	,
		p_ps_id				IN  	NUMBER	,

           --   *****  Output parameters  *****

		p_status			OUT NOCOPY 	VARCHAR2				)

IS

		l_batch_rec			ar_batches%ROWTYPE;
		l_trh_rec			ar_transaction_history%ROWTYPE;
		l_trx_rec			ra_customer_trx%ROWTYPE;
		l_ps_rec			ar_payment_schedules%ROWTYPE;
		l_action			VARCHAR2(30);

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_PUB.Select_BR_Remit ()+');
	END IF;

       /*-----------------------------------------------+
        |   Standard start of API savepoint     	|
        +-----------------------------------------------*/

      	SAVEPOINT Select_BR_Remit_PVT;


	/*-----------------------------------------------+
        |   Input Validation				 |
        +-----------------------------------------------*/

	AR_BILLS_MAINTAIN_VAL_PVT.validate_Payment_Schedule_ID (p_ps_id);
	AR_BILLS_MAINTAIN_VAL_PVT.validate_Remit_Batch_ID (p_batch_id);


	/*-----------------------------------------------+
        |   Data preparation				 |
        +-----------------------------------------------*/

	arp_cr_batches_pkg.fetch_p  (p_batch_id, l_batch_rec);

	arp_ps_pkg.fetch_p (p_ps_id, l_ps_rec);

	l_trh_rec.customer_trx_id	:=	l_ps_rec.customer_trx_id;
	ARP_TRANSACTION_HISTORY_PKG.lock_fetch_f_trx_id (l_trh_rec);


	/*-----------------------------------------------+
        |   Validate the action				|
        +-----------------------------------------------*/


	l_action			:=	C_SELECT_REMIT;

	AR_BILLS_MAINTAIN_STATUS_PUB.validate_actions (
		p_customer_trx_id	=>  	l_ps_rec.customer_trx_id	,
		p_complete_flag		=>	C_ACTION_REC.complete_flag	,
		p_uncomplete_flag	=>	C_ACTION_REC.uncomplete_flag	,
		p_accept_flag		=>	C_ACTION_REC.accept_flag	,
		p_cancel_flag		=>	C_ACTION_REC.cancel_flag	,
		p_select_remit_flag	=>	C_ACTION_REC.select_remit_flag	,
		p_deselect_remit_flag	=>	C_ACTION_REC.deselect_remit_flag,
		p_approve_remit_flag	=>	C_ACTION_REC.approve_remit_flag	,
		p_hold_flag		=>	C_ACTION_REC.hold_flag		,
		p_unhold_flag		=>	C_ACTION_REC.unhold_flag	,
		p_recall_flag		=>	C_ACTION_REC.recall_flag	,
		p_eliminate_flag	=>	C_ACTION_REC.eliminate_flag	,
		p_uneliminate_flag	=>	C_ACTION_REC.uneliminate_flag	,
		p_unpaid_flag		=>	C_ACTION_REC.unpaid_flag	,
		p_protest_flag		=>	C_ACTION_REC.protest_flag	,
		p_endorse_flag		=>	C_ACTION_REC.endorse_flag	,
		p_restate_flag		=>	C_ACTION_REC.restate_flag	,
		p_exchange_flag		=>	C_ACTION_REC.exchange_flag	,
		p_delete_flag		=>	C_ACTION_REC.delete_flag	);


	-- Do not continue if the action is not allowed for the BR

	ARP_CT_PKG.fetch_p (l_trx_rec, l_ps_rec.customer_trx_id);

	IF	(C_ACTION_REC.select_remit_flag	<>	'Y')
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( '>>>>>>>>>> The action ' || l_action || ' is not allowed on the BR ' || l_ps_rec.customer_trx_id);
		END IF;
		FND_MESSAGE.set_name	( 'AR', 'AR_BR_CANNOT_SELECT_REMIT' );
		FND_MESSAGE.set_token	( 'BRNUM' 	,  l_trx_rec.trx_number);
		app_exception.raise_exception;
	END IF;



        /*-----------------------------------------------+
        |   Data Validation				|
        +-----------------------------------------------*/

	AR_BILLS_MAINTAIN_VAL_PVT.Validate_Remittance_Dates (l_batch_rec, l_trh_rec, l_trx_rec.trx_number);

	l_trh_rec.trx_date	:=	trunc(l_batch_rec.batch_date)	;
	l_trh_rec.gl_date	:=	trunc(l_batch_rec.gl_date)	;


	/*----------------------------------------------+
        |    Updates the Payment Schedule of the BR 	|
        +-----------------------------------------------*/

	AR_BILLS_MAINTAIN_LIB_PVT.update_reserved_columns (p_ps_id, 'REMITTANCE' , p_batch_id);


	/*----------------------------------------------+
        |    Insert a Transaction History Record 	|
        +-----------------------------------------------*/

	-- Fetch the new status and new event of the BR

	AR_BILLS_MAINTAIN_STATUS_PUB.New_Status_Event (
			p_trx_rec	=>	l_trx_rec	,
			p_action        =>	l_action	,
			p_new_status	=>	l_trh_rec.status,
			p_new_event	=>	l_trh_rec.event	);


	l_trh_rec.transaction_history_id:=	NULL			;
	l_trh_rec.postable_flag		:=  	'N'			;
	l_trh_rec.current_accounted_flag:=  	'N'			;
	l_trh_rec.current_record_flag	:=  	'Y'			;
	l_trh_rec.prv_trx_history_id	:=  	NULL			;
	l_trh_rec.comments		:=  	NULL			;
	l_trh_rec.posting_control_id    := 	-3           		;
	l_trh_rec.gl_posted_date        :=  	NULL        		;
	l_trh_rec.first_posted_record_flag  := 	'N'			;
	l_trh_rec.created_from		:=  	'ARBRMAIB'		;
	l_trh_rec.batch_id		:=	NULL			;

	arp_proc_transaction_history.insert_transaction_history (l_trh_rec, l_trh_rec.transaction_history_id);


	/*-----------------------------------------------+
        |   Output parameter				 |
        +------------------------------------------------*/

	p_status			:=  l_trh_rec.status;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_PUB.Select_BR_Remit ()-');
	END IF;

EXCEPTION
 	WHEN OTHERS THEN
   		IF PG_DEBUG in ('Y', 'C') THEN
   		   arp_util.debug('EXCEPTION OTHERS: AR_BILLS_MAINTAIN_PUB.Select_BR_Remit');
		   arp_util.debug( SQLCODE);
		   arp_util.debug( SQLERRM);
		END IF;
		ROLLBACK TO Select_BR_Remit_PVT;
	RAISE;

END Select_BR_Remit;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    DeSelect_BR_remit			                                     	|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    DeSelects a BR out NOCOPY of a remittance batch				     	|
 |									  	|
 +==============================================================================*/


PROCEDURE DeSelect_BR_Remit (

           --   *****  Input  parameters  *****
		p_ps_id				IN  	NUMBER	,

           --   *****  Output parameters  *****
		p_status			OUT NOCOPY 	VARCHAR2				)
IS

		l_trh_rec			ar_transaction_history%ROWTYPE;
		l_trx_rec			ra_customer_trx%ROWTYPE;
		l_ps_rec			ar_payment_schedules%ROWTYPE;
		l_action			VARCHAR2(30);

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_PUB.DeSelect_BR_Remit ()+');
	END IF;

       /*-----------------------------------------------+
        |   Standard start of API savepoint     	|
        +-----------------------------------------------*/

      	SAVEPOINT DeSelect_BR_Remit_PVT;


	/*-----------------------------------------------+
        |   Input Validation				 |
        +-----------------------------------------------*/

	AR_BILLS_MAINTAIN_VAL_PVT.validate_Payment_Schedule_ID (p_ps_id);



	/*-----------------------------------------------+
        |   Data preparation				 |
        +-----------------------------------------------*/

	arp_ps_pkg.fetch_p (p_ps_id, l_ps_rec);



	/*-----------------------------------------------+
        |   Validate the action				|
        +-----------------------------------------------*/

	l_action			:=	C_DESELECT_REMIT;

	AR_BILLS_MAINTAIN_STATUS_PUB.validate_actions (
		p_customer_trx_id	=>  	l_ps_rec.customer_trx_id	,
		p_complete_flag		=>	C_ACTION_REC.complete_flag	,
		p_uncomplete_flag	=>	C_ACTION_REC.uncomplete_flag	,
		p_accept_flag		=>	C_ACTION_REC.accept_flag	,
		p_cancel_flag		=>	C_ACTION_REC.cancel_flag	,
		p_select_remit_flag	=>	C_ACTION_REC.select_remit_flag	,
		p_deselect_remit_flag	=>	C_ACTION_REC.deselect_remit_flag,
		p_approve_remit_flag	=>	C_ACTION_REC.approve_remit_flag	,
		p_hold_flag		=>	C_ACTION_REC.hold_flag		,
		p_unhold_flag		=>	C_ACTION_REC.unhold_flag	,
		p_recall_flag		=>	C_ACTION_REC.recall_flag	,
		p_eliminate_flag	=>	C_ACTION_REC.eliminate_flag	,
		p_uneliminate_flag	=>	C_ACTION_REC.uneliminate_flag	,
		p_unpaid_flag		=>	C_ACTION_REC.unpaid_flag	,
		p_protest_flag		=>	C_ACTION_REC.protest_flag	,
		p_endorse_flag		=>	C_ACTION_REC.endorse_flag	,
		p_restate_flag		=>	C_ACTION_REC.restate_flag	,
		p_exchange_flag		=>	C_ACTION_REC.exchange_flag	,
		p_delete_flag		=>	C_ACTION_REC.delete_flag	);


	-- Do not continue if the action is not allowed for the BR

	ARP_CT_PKG.fetch_p (l_trx_rec, l_ps_rec.customer_trx_id);

	IF	(C_ACTION_REC.deselect_remit_flag	<>	'Y')
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( '>>>>>>>>>> The action ' || l_action || ' is not allowed on the BR ' || l_ps_rec.customer_trx_id);
		END IF;
		FND_MESSAGE.set_name	( 'AR', 'AR_BR_CANNOT_DESELECT_REMIT' );
		FND_MESSAGE.set_token	( 'BRNUM' 	,  l_trx_rec.trx_number);
		app_exception.raise_exception;
	END IF;


       /*-----------------------------------------------+
        |   Data Preparation				|
        +-----------------------------------------------*/

	l_trh_rec.customer_trx_id	:=	l_ps_rec.customer_trx_id;
	ARP_TRANSACTION_HISTORY_PKG.lock_fetch_f_trx_id (l_trh_rec);


	/*----------------------------------------------+
        |    Updates the Payment Schedule of the BR 	|
        +-----------------------------------------------*/

	AR_BILLS_MAINTAIN_LIB_PVT.update_reserved_columns (p_ps_id, NULL, NULL);


	/*----------------------------------------------+
        |    Insert a Transaction History Record 	|
        +-----------------------------------------------*/

	-- Fetch the new status and new event of the BR

	AR_BILLS_MAINTAIN_STATUS_PUB.New_Status_Event (
			p_trx_rec	=>	l_trx_rec	,
			p_action        =>	l_action	,
			p_new_status	=>	l_trh_rec.status,
			p_new_event	=>	l_trh_rec.event	);

	l_trh_rec.transaction_history_id:=	NULL		;
	l_trh_rec.postable_flag		:=  	'N'		;
	l_trh_rec.current_accounted_flag:=  	'N'		;
	l_trh_rec.current_record_flag	:=  	'Y'		;
	l_trh_rec.prv_trx_history_id	:=  	NULL		;
	l_trh_rec.comments		:=  	NULL		;
	l_trh_rec.posting_control_id    := 	-3           	;
	l_trh_rec.gl_posted_date        :=  	NULL        	;
	l_trh_rec.first_posted_record_flag  := 	'N'		;
	l_trh_rec.created_from		:= 	'ARBRMAIB'	;

	arp_proc_transaction_history.insert_transaction_history (l_trh_rec, l_trh_rec.transaction_history_id);


	/*-----------------------------------------------+
        |   Output parameter				 |
        +------------------------------------------------*/

	p_status			:=  l_trh_rec.status;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_PUB.DeSelect_BR_Remit ()-');
	END IF;

EXCEPTION
 	WHEN OTHERS THEN
   		IF PG_DEBUG in ('Y', 'C') THEN
   		   arp_util.debug('EXCEPTION OTHERS: AR_BILLS_MAINTAIN_PUB.DeSelect_BR_Remit');
		   arp_util.debug( SQLCODE);
		   arp_util.debug( SQLERRM);
		END IF;
		ROLLBACK TO DeSelect_BR_Remit_PVT;
		RAISE;

END DeSelect_BR_Remit;



/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Cancel_BR_remit			                                     	|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    Cancels the selection of a BR in a remittance batch 		     	|
 |    Removes the history record related to the selection			|
 |									  	|
 +==============================================================================*/


PROCEDURE Cancel_BR_Remit (

           --   *****  Input  parameters  *****
		p_ps_id				IN  	NUMBER	)
IS

		l_trh_rec			ar_transaction_history%ROWTYPE;
		l_trx_rec			ra_customer_trx%ROWTYPE;
		l_ps_rec			ar_payment_schedules%ROWTYPE;
		l_action			VARCHAR2(30);
		l_trh_id			ar_transaction_history.transaction_history_id%TYPE;

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_PUB.Cancel_BR_Remit ()+');
	END IF;

       /*-----------------------------------------------+
        |   Standard start of API savepoint     	|
        +-----------------------------------------------*/

      	SAVEPOINT Cancel_BR_Remit_PVT;


	/*-----------------------------------------------+
        |   Input Validation				 |
        +-----------------------------------------------*/

	AR_BILLS_MAINTAIN_VAL_PVT.validate_Payment_Schedule_ID (p_ps_id);



	/*-----------------------------------------------+
        |   Data preparation				 |
        +-----------------------------------------------*/

	arp_ps_pkg.fetch_p (p_ps_id, l_ps_rec);



	/*-----------------------------------------------+
        |   Validate the action				|
        +-----------------------------------------------*/

	l_action			:=	C_DESELECT_REMIT;

	AR_BILLS_MAINTAIN_STATUS_PUB.validate_actions (
		p_customer_trx_id	=>  	l_ps_rec.customer_trx_id	,
		p_complete_flag		=>	C_ACTION_REC.complete_flag	,
		p_uncomplete_flag	=>	C_ACTION_REC.uncomplete_flag	,
		p_accept_flag		=>	C_ACTION_REC.accept_flag	,
		p_cancel_flag		=>	C_ACTION_REC.cancel_flag	,
		p_select_remit_flag	=>	C_ACTION_REC.select_remit_flag	,
		p_deselect_remit_flag	=>	C_ACTION_REC.deselect_remit_flag,
		p_approve_remit_flag	=>	C_ACTION_REC.approve_remit_flag	,
		p_hold_flag		=>	C_ACTION_REC.hold_flag		,
		p_unhold_flag		=>	C_ACTION_REC.unhold_flag	,
		p_recall_flag		=>	C_ACTION_REC.recall_flag	,
		p_eliminate_flag	=>	C_ACTION_REC.eliminate_flag	,
		p_uneliminate_flag	=>	C_ACTION_REC.uneliminate_flag	,
		p_unpaid_flag		=>	C_ACTION_REC.unpaid_flag	,
		p_protest_flag		=>	C_ACTION_REC.protest_flag	,
		p_endorse_flag		=>	C_ACTION_REC.endorse_flag	,
		p_restate_flag		=>	C_ACTION_REC.restate_flag	,
		p_exchange_flag		=>	C_ACTION_REC.exchange_flag	,
		p_delete_flag		=>	C_ACTION_REC.delete_flag	);


	-- Do not continue if the action is not allowed for the BR

	ARP_CT_PKG.fetch_p (l_trx_rec, l_ps_rec.customer_trx_id);

	IF	(C_ACTION_REC.deselect_remit_flag	<>	'Y')
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug('Cancel_BR_Remit: ' || '>>>>>>>>>> The action ' || l_action || ' is not allowed on the BR ' || l_ps_rec.customer_trx_id);
		END IF;
		FND_MESSAGE.set_name	( 'AR', 'AR_BR_CANNOT_DESELECT_REMIT' );
		FND_MESSAGE.set_token	( 'BRNUM' 	,  l_trx_rec.trx_number);
		app_exception.raise_exception;
	END IF;


       /*-----------------------------------------------+
        |   Data Preparation				|
        +-----------------------------------------------*/

	l_trh_rec.customer_trx_id	:=	l_ps_rec.customer_trx_id;
	ARP_TRANSACTION_HISTORY_PKG.lock_fetch_f_trx_id (l_trh_rec);


	/*----------------------------------------------+
        |    Updates the Payment Schedule of the BR 	|
        +-----------------------------------------------*/

	AR_BILLS_MAINTAIN_LIB_PVT.update_reserved_columns (p_ps_id, NULL, NULL);



	/*------------------------------------------------------+
        |    Deletes the current Transaction History Record 	|
	|    (Status Selected Remittance)			|
        +-------------------------------------------------------*/

	l_trh_id	:=	l_trh_rec.prv_trx_history_id;

	ARP_PROC_TRANSACTION_HISTORY.delete_transaction_history (l_trh_rec.transaction_history_id);


	/*------------------------------------------------------+
        |    Updates the previous Transaction History Record 	|
        +-------------------------------------------------------*/

 	ARP_TRANSACTION_HISTORY_PKG.set_to_dummy(l_trh_rec);

        /*---------------------------+
        | Set the flag to be updated |
        +----------------------------*/

	l_trh_rec.current_record_flag	:=	'Y';

	ARP_PROC_TRANSACTION_HISTORY.update_transaction_history	(l_trh_rec, l_trh_id);


	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('Cancel_BR_Remit: ' || 'AR_BILLS_MAINTAIN_PUB.DeSelect_BR_Remit ()-');
	END IF;

EXCEPTION
 	WHEN OTHERS THEN
   		IF PG_DEBUG in ('Y', 'C') THEN
   		   arp_util.debug('EXCEPTION OTHERS: AR_BILLS_MAINTAIN_PUB.Cancel_BR_Remit');
		   arp_util.debug('Cancel_BR_Remit: ' || SQLCODE);
		   arp_util.debug('Cancel_BR_Remit: ' || SQLERRM);
		END IF;
		ROLLBACK TO Cancel_BR_Remit_PVT;
		RAISE;

END Cancel_BR_Remit;




/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Approve_BR_Remit			                                     	|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    Approves the remittance of a BR					     	|
 |									  	|
 +==============================================================================*/


PROCEDURE Approve_BR_Remit (

           --   *****  Input  parameters  *****

		p_batch_id			IN	ar_batches.batch_id%TYPE			,
		p_ps_id				IN	ar_payment_schedules.payment_schedule_id%TYPE	,

           --   *****  Output parameters  *****

         	p_status			OUT NOCOPY 	VARCHAR2					)

IS
		l_batch_rec			ar_batches%ROWTYPE;
		l_trh_rec			ar_transaction_history%ROWTYPE;
		l_ps_rec			ar_payment_schedules%ROWTYPE;
		l_trx_rec			RA_CUSTOMER_TRX%ROWTYPE;
		l_action			VARCHAR2(30);

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_PUB.Approve_BR_Remit ()+ ');
	END IF;


       /*-----------------------------------------------+
        |   Standard start of API savepoint     	|
        +-----------------------------------------------*/

     	SAVEPOINT Approve_BR_Remit_PVT;


	/*----------------------------------------------+
        |   Fetch BR Information			|
        +-----------------------------------------------*/

	arp_cr_batches_pkg.fetch_p  (p_batch_id, l_batch_rec);

	arp_ps_pkg.fetch_p (p_ps_id, l_ps_rec);

	ARP_CT_PKG.lock_fetch_p (l_trx_rec, l_ps_rec.customer_trx_id);


	/*-----------------------------------------------+
        |   Validate the action				|
        +-----------------------------------------------*/

	l_action			:=	C_APPROVE_REMIT;

	AR_BILLS_MAINTAIN_STATUS_PUB.validate_actions (
		p_customer_trx_id	=>  	l_ps_rec.customer_trx_id	,
		p_complete_flag		=>	C_ACTION_REC.complete_flag	,
		p_uncomplete_flag	=>	C_ACTION_REC.uncomplete_flag	,
		p_accept_flag		=>	C_ACTION_REC.accept_flag	,
		p_cancel_flag		=>	C_ACTION_REC.cancel_flag	,
		p_select_remit_flag	=>	C_ACTION_REC.select_remit_flag	,
		p_deselect_remit_flag	=>	C_ACTION_REC.deselect_remit_flag,
		p_approve_remit_flag	=>	C_ACTION_REC.approve_remit_flag	,
		p_hold_flag		=>	C_ACTION_REC.hold_flag		,
		p_unhold_flag		=>	C_ACTION_REC.unhold_flag	,
		p_recall_flag		=>	C_ACTION_REC.recall_flag	,
		p_eliminate_flag	=>	C_ACTION_REC.eliminate_flag	,
		p_uneliminate_flag	=>	C_ACTION_REC.uneliminate_flag	,
		p_unpaid_flag		=>	C_ACTION_REC.unpaid_flag	,
		p_protest_flag		=>	C_ACTION_REC.protest_flag	,
		p_endorse_flag		=>	C_ACTION_REC.endorse_flag	,
		p_restate_flag		=>	C_ACTION_REC.restate_flag	,
		p_exchange_flag		=>	C_ACTION_REC.exchange_flag	,
		p_delete_flag		=>	C_ACTION_REC.delete_flag	);


	-- Do not continue if the action is not allowed for the BR

	IF	(C_ACTION_REC.approve_remit_flag	<>	'Y')
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( '>>>>>>>>>> The action ' || l_action || ' is not allowed on the BR ' || l_ps_rec.customer_trx_id);
		END IF;
		FND_MESSAGE.set_name	( 'AR', 'AR_BR_CANNOT_APPROVE' );
		FND_MESSAGE.set_token	( 'BRNUM' 	,  l_trx_rec.trx_number);
		app_exception.raise_exception;
	END IF;


	/*-----------------------------------------------+
        |   Data preparation 				|
        +-----------------------------------------------*/


	ARP_CT_PKG.fetch_p (l_trx_rec, l_ps_rec.customer_trx_id);

	l_trh_rec.customer_trx_id	:=	l_ps_rec.customer_trx_id;
	ARP_TRANSACTION_HISTORY_PKG.lock_fetch_f_trx_id (l_trh_rec);


	/*----------------------------------------------+
        |   Remittance Approval 			|
        +-----------------------------------------------*/

	IF 	(l_batch_rec.remit_method_code = C_STANDARD)
	THEN
		/*----------------------------------------------+
	        |   Standard Remittance Approval		|
	        +-----------------------------------------------*/

		l_action			:=	C_REMIT_STANDARD;
		l_trh_rec.postable_flag		:=	'Y';
		l_trh_rec.current_accounted_flag:=	'Y';


	ELSIF	(l_batch_rec.remit_method_code = C_FACTORING 	AND	l_batch_rec.with_recourse_flag = 'Y')
	THEN
		/*----------------------------------------------+
	        | Remittance Method : Factore With Recourse	|
	        +-----------------------------------------------*/

		l_action			:=	C_FACTORE_RECOURSE;
		l_trh_rec.postable_flag		:=	'Y';
		l_trh_rec.current_accounted_flag:=	'Y';
		AR_BILLS_MAINTAIN_LIB_PVT.Factore_Recourse (l_batch_rec, l_ps_rec, l_trh_rec);


	ELSIF	(l_batch_rec.remit_method_code = C_FACTORING	AND	l_batch_rec.with_recourse_flag = 'N')
	THEN
		/*----------------------------------------------+
	        | Remittance Method : Factore Without Recourse	|
	        +-----------------------------------------------*/

		l_action			:=	C_FACTORE;
		l_trh_rec.postable_flag		:=	'N';
		AR_BILLS_MAINTAIN_LIB_PVT.Factore_Without_Recourse (l_batch_rec, l_ps_rec);
		AR_BILLS_MAINTAIN_LIB_PVT.update_reserved_columns (p_ps_id, NULL , NULL);

		/*----------------------------------------------+
        	|  Insert the First Transaction History Record	|
        	+-----------------------------------------------*/

		-- Fetch the new status and new event of the BR

		AR_BILLS_MAINTAIN_STATUS_PUB.New_Status_Event (
			p_trx_rec	=>	l_trx_rec	,
			p_action        =>	l_action	,
			p_new_status	=>	l_trh_rec.status,
			p_new_event	=>	l_trh_rec.event	);

		l_trh_rec.trx_date		:=	trunc(l_batch_rec.batch_date)	;
		l_trh_rec.gl_date		:=	trunc(l_batch_rec.gl_date)	;
		l_trh_rec.transaction_history_id:=	NULL			;
		l_trh_rec.current_record_flag	:=  	'Y'			;
		l_trh_rec.prv_trx_history_id	:=  	NULL			;
		l_trh_rec.posting_control_id    := 	-3           		;
		l_trh_rec.gl_posted_date        :=  	NULL        		;
		l_trh_rec.first_posted_record_flag  := 	'N'			;
		l_trh_rec.created_from		:=	'ARBRMAIB'		;
		l_trh_rec.batch_id		:=	NULL			;


		arp_proc_transaction_history.insert_transaction_history (l_trh_rec	,
								 	l_trh_rec.transaction_history_id);

	ELSE
		/*----------------------------------------------+
	        | Remittance Method Unknown			|
	        +-----------------------------------------------*/

		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( '>>>>>>>>>> The remittance method : ' || l_batch_rec.remit_method_code || 'Recourse Flag : ' || l_batch_rec.with_recourse_flag || ' is not handled');
		END IF;
		FND_MESSAGE.set_name	( 'AR', 'AR_BR_INVALID_REMIT_METHOD');
		app_exception.raise_exception;

	END IF;


	/*----------------------------------------------+
        |   Store the Remittance Information in the 	|
	|   BR Header 					|
        +-----------------------------------------------*/

	l_trx_rec.remittance_batch_id		:=	p_batch_id;
	l_trx_rec.receipt_method_id		:=	l_batch_rec.receipt_method_id;
	l_trx_rec.remit_bank_acct_use_id	:=	l_batch_rec.remit_bank_acct_use_id;

	ARP_PROCESS_BR_HEADER.update_header  (  l_trx_rec		,
						l_trx_rec.customer_trx_id);


	/*----------------------------------------------+
        |  Insert the Transaction History Record	|
        +-----------------------------------------------*/

	-- Fetch the new status and new event of the BR

	AR_BILLS_MAINTAIN_STATUS_PUB.New_Status_Event (
			p_trx_rec	=>	l_trx_rec	,
			p_action        =>	l_action	,
			p_new_status	=>	l_trh_rec.status,
			p_new_event	=>	l_trh_rec.event	);

	l_trh_rec.trx_date		:=	trunc(l_batch_rec.batch_date)	;
	l_trh_rec.gl_date		:=	trunc(l_batch_rec.gl_date)	;
	l_trh_rec.transaction_history_id:=	NULL			;
	l_trh_rec.current_record_flag	:=  	'Y'			;
	l_trh_rec.prv_trx_history_id	:=  	NULL			;
	l_trh_rec.posting_control_id    := 	-3           		;
	l_trh_rec.gl_posted_date        :=  	NULL        		;
	l_trh_rec.first_posted_record_flag  := 	'N'			;
	l_trh_rec.created_from		:=	'ARBRMAIB'		;
	l_trh_rec.batch_id		:=	p_batch_id		;


	arp_proc_transaction_history.insert_transaction_history (l_trh_rec	,
								 l_trh_rec.transaction_history_id);


	/*----------------------------------------------+
        |  Populate LINK_TO_TRX_HISTORY_ID on the 	|
 	|  application that closes the BR for Factore	|
	|  without recourse				|
        +-----------------------------------------------*/

	IF	(l_batch_rec.remit_method_code = C_FACTORING	AND	l_batch_rec.with_recourse_flag = 'N')
	THEN

		AR_BILLS_MAINTAIN_LIB_PVT.Link_Application_History (l_trh_rec);

	END IF;



	/*-----------------------------------------------+
        |   Output parameter				 |
        +------------------------------------------------*/

	p_status			:=	l_trh_rec.status	;


        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('AR_BILLS_MAINTAIN_PUB.Approve_BR_Remit ()- ');
        END IF;

EXCEPTION
 	WHEN OTHERS THEN
   		IF PG_DEBUG in ('Y', 'C') THEN
   		   arp_util.debug('EXCEPTION OTHERS: AR_BILLS_MAINTAIN_PUB.Approve_BR_Remit');
		   arp_util.debug( SQLCODE);
		   arp_util.debug( SQLERRM);
		END IF;
		ROLLBACK TO Approve_BR_Remit_PVT;
		RAISE;


END Approve_BR_Remit;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Cancel_BR				                                     	|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    Cancels a BR							     	|
 |									  	|
 +==============================================================================*/


PROCEDURE Cancel_BR (

           --   *****  Standard API parameters *****

                p_api_version      		IN  	NUMBER					,
                p_init_msg_list    		IN  	VARCHAR2 := FND_API.G_TRUE		,
                p_commit           		IN  	VARCHAR2 := FND_API.G_FALSE		,
                p_validation_level 		IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL	,
                x_return_status    		OUT NOCOPY 	VARCHAR2				,
                x_msg_count        		OUT NOCOPY 	NUMBER					,
                x_msg_data         		OUT NOCOPY 	VARCHAR2				,

           --   *****  Input parameters  *****

		p_customer_trx_id		IN  	NUMBER		,
		p_cancel_date			IN  	DATE		,
		p_cancel_gl_date		IN  	DATE		,
		p_cancel_comments		IN  	VARCHAR2	,


           --   *****  Output parameters  *****

		p_status			OUT NOCOPY 	VARCHAR2				)


IS
		l_api_name			CONSTANT VARCHAR2(20)	:=	'Cancel_BR';
		l_api_version			CONSTANT NUMBER		:=	1.0;

		l_trh_rec			ar_transaction_history%ROWTYPE;
		l_trx_rec			ra_customer_trx%ROWTYPE;
		l_ps_rec			ar_payment_schedules%ROWTYPE;

		l_acceptance_flag		VARCHAR2(1)	;

		l_action			VARCHAR2(30)	;
		l_trx_date			DATE		;
		l_gl_date			DATE		;

		l_gl_date_closed		DATE		;
		l_actual_date_closed		DATE		;
                l_mesg                          VARCHAR2(2000);


BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_PUB.Cancel_BR()+ ');
	END IF;

	x_msg_count				:=	NULL;
	x_msg_data				:=	NULL;
       /*-----------------------------------------------+
        |   Standard start of API savepoint     	|
        +-----------------------------------------------*/

     	SAVEPOINT Cancel_BR_PVT;

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


       /*--------------------------------------------------------------+
        |   Initialize message list if p_init_msg_list is set to TRUE  |
        +--------------------------------------------------------------*/

        IF  FND_API.to_Boolean( p_init_msg_list )  THEN
 	             FND_MSG_PUB.initialize;
        END IF;


       /*-----------------------------------------------+
        |   Initialize return status to SUCCESS   	|
        +-----------------------------------------------*/

        x_return_status := FND_API.G_RET_STS_SUCCESS;


       /*-----------------------------------------------------------------------+
        |   ============  START OF API BODY - CANCEL BR  ===================  	|
        +-----------------------------------------------------------------------*/


	/*-----------------------------------------------+
        |   Validate the action				|
        +-----------------------------------------------*/

	l_action			:=	C_CANCEL;

	AR_BILLS_MAINTAIN_STATUS_PUB.validate_actions (
		p_customer_trx_id	=>  	p_customer_trx_id		,
		p_complete_flag		=>	C_ACTION_REC.complete_flag	,
		p_uncomplete_flag	=>	C_ACTION_REC.uncomplete_flag	,
		p_accept_flag		=>	C_ACTION_REC.accept_flag	,
		p_cancel_flag		=>	C_ACTION_REC.cancel_flag	,
		p_select_remit_flag	=>	C_ACTION_REC.select_remit_flag	,
		p_deselect_remit_flag	=>	C_ACTION_REC.deselect_remit_flag,
		p_approve_remit_flag	=>	C_ACTION_REC.approve_remit_flag	,
		p_hold_flag		=>	C_ACTION_REC.hold_flag		,
		p_unhold_flag		=>	C_ACTION_REC.unhold_flag	,
		p_recall_flag		=>	C_ACTION_REC.recall_flag	,
		p_eliminate_flag	=>	C_ACTION_REC.eliminate_flag	,
		p_uneliminate_flag	=>	C_ACTION_REC.uneliminate_flag	,
		p_unpaid_flag		=>	C_ACTION_REC.unpaid_flag	,
		p_protest_flag		=>	C_ACTION_REC.protest_flag	,
		p_endorse_flag		=>	C_ACTION_REC.endorse_flag	,
		p_restate_flag		=>	C_ACTION_REC.restate_flag	,
		p_exchange_flag		=>	C_ACTION_REC.exchange_flag	,
		p_delete_flag		=>	C_ACTION_REC.delete_flag	);


	-- Do not continue if the action is not allowed for the BR

	ARP_CT_PKG.fetch_p (l_trx_rec, p_customer_trx_id);

	IF	(C_ACTION_REC.cancel_flag	<>	'Y')
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( '>>>>>>>>>> The action ' || l_action || ' is not allowed on the BR ' || p_customer_trx_id);
		END IF;
		FND_MESSAGE.set_name	( 'AR', 'AR_BR_CANNOT_CANCEL' );
		FND_MESSAGE.set_token	( 'BRNUM' 	,  l_trx_rec.trx_number);
		app_exception.raise_exception;
	END IF;



        /*-----------------------------------------------+
        |   Data preparation 				|
        +-----------------------------------------------*/

	l_trh_rec.customer_trx_id	:=	p_customer_trx_id;
	ARP_TRANSACTION_HISTORY_PKG.lock_fetch_f_trx_id (l_trh_rec);

	l_trx_date			:=	trunc(p_cancel_date);
	l_gl_date			:=	trunc(p_cancel_gl_date);


	/*-----------------------------------------------+
        |   Data Defaulting				|
        +-----------------------------------------------*/

	AR_BILLS_MAINTAIN_LIB_PVT.Default_Action_Dates (l_trx_date, l_gl_date);


       /*-----------------------------------------------+
        |   Data Validation				|
        +-----------------------------------------------*/

        l_mesg := arp_standard.fnd_message('AR_BR_SPMENU_CANCEL');
	AR_BILLS_MAINTAIN_VAL_PVT.validate_Action_Dates (l_trx_date, l_gl_date, l_trh_rec, l_mesg);

	l_trh_rec.trx_date		:=	l_trx_date	;
	l_trh_rec.gl_date		:=	l_gl_date	;
	l_trh_rec.comments		:=	p_cancel_comments;

        AR_BILLS_MAINTAIN_VAL_PVT.Validate_Cancel_BR (p_customer_trx_id);


	/*-----------------------------------------------+
        |   BR Cancel	 				 |
        +------------------------------------------------*/

	IF  	(l_trh_rec.status = C_PENDING_ACCEPTANCE)
	THEN
		l_acceptance_flag := 'Y';
		l_trh_rec.postable_flag 	:= 	'N';
		l_trh_rec.current_accounted_flag:=	'N';
	ELSE
		l_acceptance_flag := 'N';
		l_trh_rec.postable_flag		:=	'Y';
		l_trh_rec.current_accounted_flag:=	'Y';
	END IF;

	AR_BILLS_MAINTAIN_LIB_PVT.Reverse_Assignments_Adjustment (l_trh_rec, l_acceptance_flag);


	/*----------------------------------------------+
        |  Insert the Transaction History Record	|
        +-----------------------------------------------*/

	-- Fetch the new status and new event of the BR

	AR_BILLS_MAINTAIN_STATUS_PUB.New_Status_Event (
			p_trx_rec	=>	l_trx_rec	,
			p_action        =>	l_action	,
			p_new_status	=>	l_trh_rec.status,
			p_new_event	=>	l_trh_rec.event	);

	l_trh_rec.transaction_history_id:=	NULL		;
	l_trh_rec.current_record_flag	:=  	'Y'		;
	l_trh_rec.prv_trx_history_id	:=  	NULL		;
	l_trh_rec.posting_control_id    := 	-3           	;
	l_trh_rec.gl_posted_date        :=  	NULL        	;
	l_trh_rec.first_posted_record_flag  := 	'N'		;
	l_trh_rec.created_from		:=  	'ARBRMAIB'	;
	l_trh_rec.batch_id		:=	NULL		;

	arp_proc_transaction_history.insert_transaction_history (l_trh_rec	,
								 l_trh_rec.transaction_history_id);


	/*----------------------------------------------+
        |   Close the Payment Schedule of the BR	|
        +-----------------------------------------------*/

	IF (l_acceptance_flag = 'N')
	THEN
		arp_ps_pkg.set_to_dummy (l_ps_rec);
		AR_BILLS_CREATION_LIB_PVT.Get_Payment_Schedule_Id (p_customer_trx_id, l_ps_rec.payment_schedule_id);
		arp_ps_pkg.lock_p(l_ps_rec.payment_schedule_id);

		arp_ps_util.get_closed_dates (
			l_ps_rec.payment_schedule_id	,
                        l_trh_rec.trx_date		,
                        l_trh_rec.gl_date		,
                        l_gl_date_closed		,
                        l_actual_date_closed, 'BR' 	);

		l_ps_rec.status				:=	'CL'			;
	 	l_ps_rec.amount_due_remaining        	:= 	0			;
                l_ps_rec.acctd_amount_due_remaining  	:= 	0			;
                l_ps_rec.amount_line_items_remaining 	:= 	0			;
                l_ps_rec.receivables_charges_remaining 	:= 	0			;
                l_ps_rec.freight_remaining  		:= 	0			;
                l_ps_rec.tax_remaining      		:= 	0			;
                l_ps_rec.actual_date_closed 		:= 	l_actual_date_closed	;
                l_ps_rec.gl_date_closed 		:= 	l_gl_date_closed	;



		arp_ps_pkg.update_p (l_ps_rec, l_ps_rec.payment_schedule_id);
	END IF;

	/*-----------------------------------------------+
        |   Output parameter				 |
        +------------------------------------------------*/

	p_status		:=	l_trh_rec.status	;


       /*-----------------------------------------------+
        |   Standard check of p_commit   		|
        +-----------------------------------------------*/

        IF FND_API.To_Boolean( p_commit )
        THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug( 'committing');
            END IF;
            Commit;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('AR_BILLS_MAINTAIN_PUB.Cancel_BR()- ');
        END IF;


EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;
                ROLLBACK TO Cancel_BR_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
  	        IF PG_DEBUG in ('Y', 'C') THEN
  	           arp_util.debug( 'Exception Error');
  	        END IF;
		RAISE;


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;
                ROLLBACK TO Cancel_BR_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( 'Exception Unexpected Error');
		END IF;
		RAISE;


        WHEN OTHERS THEN
               /*-------------------------------------------------------+
                |  Handle application errors that result from trapable  |
                |  error conditions. The error messages have already    |
                |  been put on the error stack.                         |
                +-------------------------------------------------------*/

		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;

		IF (SQLCODE = -20001)
                THEN
                      	ROLLBACK TO Cancel_BR_PVT;
                      	x_return_status := FND_API.G_RET_STS_ERROR ;
                      	RAISE;
                ELSE
		      	NULL;
                END IF;

                ROLLBACK TO Cancel_BR_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		RAISE;

END Cancel_BR;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Unpaid_BR				                                     	|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    Unpaids a BR							     	|
 |									  	|
 +==============================================================================*/


PROCEDURE Unpaid_BR (

           --   *****  Standard API parameters *****

                p_api_version      		IN  	NUMBER					,
                p_init_msg_list    		IN  	VARCHAR2 := FND_API.G_TRUE		,
                p_commit           		IN  	VARCHAR2 := FND_API.G_FALSE		,
                p_validation_level 		IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL	,
                x_return_status    		OUT NOCOPY 	VARCHAR2				,
                x_msg_count        		OUT NOCOPY 	NUMBER					,
                x_msg_data         		OUT NOCOPY 	VARCHAR2				,


           --   *****  Input parameters  *****

		p_customer_trx_id		IN  	NUMBER		,
		p_unpaid_date			IN  	DATE		,
		p_unpaid_gl_date		IN  	DATE		,
		p_unpaid_reason			IN  	VARCHAR2	,
		p_unpaid_comments		IN  	VARCHAR2	,

           --   *****  Output parameters  *****

		p_status			OUT NOCOPY 	VARCHAR2				)

IS
		l_api_name			CONSTANT VARCHAR2(20)	:=	'Unpaid_BR';
		l_api_version			CONSTANT NUMBER		:=	1.0;

		l_trh_rec			ar_transaction_history%ROWTYPE;
		l_ps_rec			ar_payment_schedules%ROWTYPE;
		l_trx_rec			RA_CUSTOMER_TRX%ROWTYPE;

		l_trx_date			DATE	;
		l_gl_date			DATE	;
		l_action			VARCHAR2(30);
                l_mesg                          VARCHAR2(2000);

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_PUB.Unpaid_BR()+ ');
	END IF;

	x_msg_count				:=	NULL;
	x_msg_data				:=	NULL;

       /*-----------------------------------------------+
        |   Standard start of API savepoint     	|
        +-----------------------------------------------*/

     	SAVEPOINT Unpaid_BR_PVT;

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


       /*--------------------------------------------------------------+
        |   Initialize message list if p_init_msg_list is set to TRUE  |
        +--------------------------------------------------------------*/

        IF  FND_API.to_Boolean( p_init_msg_list )  THEN
 	             FND_MSG_PUB.initialize;
        END IF;


       /*-----------------------------------------------+
        |   Initialize return status to SUCCESS   	|
        +-----------------------------------------------*/

        x_return_status := FND_API.G_RET_STS_SUCCESS;


       /*-----------------------------------------------------------------------+
        |   ============  START OF API BODY - UNPAID BR  ===================  	|
        +-----------------------------------------------------------------------*/


	/*-----------------------------------------------+
        |   Validate the action				|
        +-----------------------------------------------*/

	l_action			:=	C_UNPAID;

	AR_BILLS_MAINTAIN_STATUS_PUB.validate_actions (
		p_customer_trx_id	=>  	p_customer_trx_id		,
		p_complete_flag		=>	C_ACTION_REC.complete_flag	,
		p_uncomplete_flag	=>	C_ACTION_REC.uncomplete_flag	,
		p_accept_flag		=>	C_ACTION_REC.accept_flag	,
		p_cancel_flag		=>	C_ACTION_REC.cancel_flag	,
		p_select_remit_flag	=>	C_ACTION_REC.select_remit_flag	,
		p_deselect_remit_flag	=>	C_ACTION_REC.deselect_remit_flag,
		p_approve_remit_flag	=>	C_ACTION_REC.approve_remit_flag	,
		p_hold_flag		=>	C_ACTION_REC.hold_flag		,
		p_unhold_flag		=>	C_ACTION_REC.unhold_flag	,
		p_recall_flag		=>	C_ACTION_REC.recall_flag	,
		p_eliminate_flag	=>	C_ACTION_REC.eliminate_flag	,
		p_uneliminate_flag	=>	C_ACTION_REC.uneliminate_flag	,
		p_unpaid_flag		=>	C_ACTION_REC.unpaid_flag	,
		p_protest_flag		=>	C_ACTION_REC.protest_flag	,
		p_endorse_flag		=>	C_ACTION_REC.endorse_flag	,
		p_restate_flag		=>	C_ACTION_REC.restate_flag	,
		p_exchange_flag		=>	C_ACTION_REC.exchange_flag	,
		p_delete_flag		=>	C_ACTION_REC.delete_flag	);


	-- Do not continue if the action is not allowed for the BR

	ARP_CT_PKG.lock_fetch_p (l_trx_rec, p_customer_trx_id);

	IF	(C_ACTION_REC.unpaid_flag	<>	'Y')
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( '>>>>>>>>>> The action ' || l_action || ' is not allowed on the BR ' || p_customer_trx_id);
		END IF;
		FND_MESSAGE.set_name	( 'AR', 'AR_BR_CANNOT_UNPAID' );
		FND_MESSAGE.set_token	( 'BRNUM' 	,  l_trx_rec.trx_number);
		app_exception.raise_exception;
	END IF;


        /*-----------------------------------------------+
        |   Data preparation 				|
        +-----------------------------------------------*/

	l_trh_rec.customer_trx_id	:=	p_customer_trx_id;
	ARP_TRANSACTION_HISTORY_PKG.lock_fetch_f_trx_id (l_trh_rec);

	l_trx_date			:=	trunc(p_unpaid_date);
	l_gl_date			:=	trunc(p_unpaid_gl_date);


	AR_BILLS_CREATION_LIB_PVT.Get_Payment_Schedule_Id (p_customer_trx_id, l_ps_rec.payment_schedule_id);

	/*-----------------------------------------------+
        |   Data Defaulting				|
        +-----------------------------------------------*/

	AR_BILLS_MAINTAIN_LIB_PVT.Default_Action_Dates (l_trx_date, l_gl_date);


       /*-----------------------------------------------+
        |   Data Validation				|
        +-----------------------------------------------*/

        l_mesg := arp_standard.fnd_message('AR_BR_SPMENU_UNPAID');
	AR_BILLS_MAINTAIN_VAL_PVT.validate_Action_Dates (l_trx_date, l_gl_date, l_trh_rec, l_mesg);

	l_trh_rec.trx_date		:=	l_trx_date	;
	l_trh_rec.gl_date		:=	l_gl_date	;
	l_trh_rec.comments		:=	p_unpaid_comments;

        AR_BILLS_MAINTAIN_VAL_PVT.Validate_Unpaid_BR (l_trh_rec, p_unpaid_reason);


	/*-----------------------------------------------+
        |   BR Unpaid	 				 |
        +------------------------------------------------*/

	AR_BILLS_MAINTAIN_LIB_PVT.Unpaid (l_trh_rec, l_ps_rec.payment_schedule_id, l_trx_rec.remittance_batch_id, p_unpaid_reason);


	/*----------------------------------------------+
        |  Set the Unpaid Flag to 'Y' in the BR Header	|
        +-----------------------------------------------*/

	l_trx_rec.br_unpaid_flag	:=	'Y';

	/*----------------------------------------------+
        |   Remove the Remittance Information of the 	|
	|   BR Header if it exists			|
        +-----------------------------------------------*/

	l_trx_rec.receipt_method_id		:=	NULL;


	ARP_PROCESS_BR_HEADER.update_header  (l_trx_rec, l_trx_rec.customer_trx_id);


	/*----------------------------------------------+
        |  Insert the Transaction History Record	|
        +-----------------------------------------------*/

	-- Fetch the new status and new event of the BR

	AR_BILLS_MAINTAIN_STATUS_PUB.New_Status_Event (
			p_trx_rec	=>	l_trx_rec	,
			p_action        =>	l_action	,
			p_new_status	=>	l_trh_rec.status,
			p_new_event	=>	l_trh_rec.event	);

	l_trh_rec.transaction_history_id:=	NULL		;
	l_trh_rec.current_record_flag	:=  	'Y'		;
	l_trh_rec.prv_trx_history_id	:=  	NULL		;
	l_trh_rec.posting_control_id    := 	-3           	;
	l_trh_rec.gl_posted_date        :=  	NULL        	;
	l_trh_rec.first_posted_record_flag  := 	'N'		;
	l_trh_rec.created_from		:=	'ARBRMAIB'	;
	l_trh_rec.batch_id		:=	NULL		;

	arp_proc_transaction_history.insert_transaction_history (l_trh_rec, l_trh_rec.transaction_history_id);


	/*-----------------------------------------------+
        |   Output parameter				 |
        +------------------------------------------------*/

	p_status			:=	l_trh_rec.status	;


       /*-----------------------------------------------+
        |   Standard check of p_commit   		|
        +-----------------------------------------------*/

        IF FND_API.To_Boolean( p_commit )
        THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug( 'committing');
            END IF;
            Commit;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('AR_BILLS_MAINTAIN_PUB.Unpaid_BR()- ');
        END IF;


EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;
                ROLLBACK TO Unpaid_BR_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
  	        IF PG_DEBUG in ('Y', 'C') THEN
  	           arp_util.debug( 'Exception Error');
  	        END IF;
		RAISE;


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;
                ROLLBACK TO Unpaid_BR_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( 'Exception Unexpected Error');
		END IF;
		RAISE;


        WHEN OTHERS THEN
               /*-------------------------------------------------------+
                |  Handle application errors that result from trapable  |
                |  error conditions. The error messages have already    |
                |  been put on the error stack.                         |
                +-------------------------------------------------------*/

		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;

		IF (SQLCODE = -20001)
                THEN
    		      	ROLLBACK TO Unpaid_BR_PVT;
                      	x_return_status := FND_API.G_RET_STS_ERROR ;
			RAISE;
                ELSE
                      	NULL;
                END IF;

                ROLLBACK TO Unpaid_BR_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		RAISE;

END Unpaid_BR;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Endorse_BR			                                     	|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |   Endorses a BR							     	|
 |									  	|
 +==============================================================================*/


PROCEDURE Endorse_BR (

           --   *****  Standard API parameters *****

                p_api_version  			IN  	NUMBER					,
                p_init_msg_list 		IN  	VARCHAR2 := FND_API.G_TRUE		,
                p_commit        		IN  	VARCHAR2 := FND_API.G_FALSE		,
                p_validation_level		IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL	,
                x_return_status   		OUT NOCOPY 	VARCHAR2				,
                x_msg_count       		OUT NOCOPY 	NUMBER					,
                x_msg_data        		OUT NOCOPY 	VARCHAR2				,

           --   *****  Input parameters  *****

		p_customer_trx_id		IN  	NUMBER		,
		p_endorse_date			IN  	DATE		,
		p_endorse_gl_date		IN  	DATE		,
		p_adjustment_activity_id 	IN  	NUMBER		,
		p_endorse_comments		IN  	VARCHAR2	,
		p_recourse_flag			IN  	VARCHAR2	,

           --   *****  Output parameters  *****

		p_status			OUT NOCOPY 	VARCHAR2) IS

  l_api_name			CONSTANT VARCHAR2(20)	:=	'Endorse_BR';
  l_api_version			CONSTANT NUMBER		:=	1.0;
  l_trh_rec			ar_transaction_history%ROWTYPE;
  l_ps_rec			ar_payment_schedules%ROWTYPE;
  l_trx_rec			RA_CUSTOMER_TRX%ROWTYPE;
  l_action			VARCHAR2(30);
  new_adj_id             	ar_adjustments.adjustment_id%type;
  l_move_deferred_tax		VARCHAR2(1)		:=	'N';
  l_trx_date			DATE;
  l_gl_date			DATE;
  l_mesg                        VARCHAR2(2000);
  -- Added for bug # 2712726
  -- ORASHID
  --
  l_nocopy_payment_schedule_id  ar_payment_schedules.payment_schedule_id%TYPE;

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_PUB.Endorse_BR()+ ');
	END IF;

	x_msg_count				:=	NULL;
	x_msg_data				:=	NULL;

       /*-----------------------------------------------+
        |   Standard start of API savepoint     	|
        +-----------------------------------------------*/

     	SAVEPOINT Endorse_BR_PVT;

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


       /*--------------------------------------------------------------+
        |   Initialize message list if p_init_msg_list is set to TRUE  |
        +--------------------------------------------------------------*/

        IF  FND_API.to_Boolean( p_init_msg_list )  THEN
 	             FND_MSG_PUB.initialize;
        END IF;


       /*-----------------------------------------------+
        |   Initialize return status to SUCCESS   	|
        +-----------------------------------------------*/

        x_return_status := FND_API.G_RET_STS_SUCCESS;


       /*-----------------------------------------------------------------------+
        |   ============  START OF API BODY - ENDORSE BR  ===================  	|
        +-----------------------------------------------------------------------*/


	/*-----------------------------------------------+
        |   Validate the action				|
        +-----------------------------------------------*/

	l_action			:=	C_ENDORSE;

	AR_BILLS_MAINTAIN_STATUS_PUB.validate_actions (
		p_customer_trx_id	=>  	p_customer_trx_id		,
		p_complete_flag		=>	C_ACTION_REC.complete_flag	,
		p_uncomplete_flag	=>	C_ACTION_REC.uncomplete_flag	,
		p_accept_flag		=>	C_ACTION_REC.accept_flag	,
		p_cancel_flag		=>	C_ACTION_REC.cancel_flag	,
		p_select_remit_flag	=>	C_ACTION_REC.select_remit_flag	,
		p_deselect_remit_flag	=>	C_ACTION_REC.deselect_remit_flag,
		p_approve_remit_flag	=>	C_ACTION_REC.approve_remit_flag	,
		p_hold_flag		=>	C_ACTION_REC.hold_flag		,
		p_unhold_flag		=>	C_ACTION_REC.unhold_flag	,
		p_recall_flag		=>	C_ACTION_REC.recall_flag	,
		p_eliminate_flag	=>	C_ACTION_REC.eliminate_flag	,
		p_uneliminate_flag	=>	C_ACTION_REC.uneliminate_flag	,
		p_unpaid_flag		=>	C_ACTION_REC.unpaid_flag	,
		p_protest_flag		=>	C_ACTION_REC.protest_flag	,
		p_endorse_flag		=>	C_ACTION_REC.endorse_flag	,
		p_restate_flag		=>	C_ACTION_REC.restate_flag	,
		p_exchange_flag		=>	C_ACTION_REC.exchange_flag	,
		p_delete_flag		=>	C_ACTION_REC.delete_flag	);

	-- Do not continue if the action is not allowed for the BR

	ARP_CT_PKG.fetch_p (l_trx_rec, p_customer_trx_id);

	IF	(C_ACTION_REC.endorse_flag	<>	'Y')
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( '>>>>>>>>>> The action ' || l_action || ' is not allowed on the BR ' || p_customer_trx_id);
		END IF;
		FND_MESSAGE.set_name	( 'AR', 'AR_BR_CANNOT_ENDORSE' );
		FND_MESSAGE.set_token	( 'BRNUM' 	,  l_trx_rec.trx_number);
		app_exception.raise_exception;
	END IF;


	/*-----------------------------------------------+
        |   Data preparation 				|
        +-----------------------------------------------*/

	l_trh_rec.customer_trx_id	:=	p_customer_trx_id;
	ARP_TRANSACTION_HISTORY_PKG.lock_fetch_f_trx_id (l_trh_rec);

	l_trx_date		:=	trunc(p_endorse_date);
	l_gl_date		:=	trunc(p_endorse_gl_date);

	AR_BILLS_CREATION_LIB_PVT.Get_Payment_Schedule_Id (p_customer_trx_id, l_ps_rec.payment_schedule_id);

        -- Modified for bug # 2712726
        -- ORASHID
        --
        l_nocopy_payment_schedule_id := l_ps_rec.payment_schedule_id;
	arp_ps_pkg.fetch_p(l_nocopy_payment_schedule_id, l_ps_rec);


	/*-----------------------------------------------+
        |   Data Defaulting				|
        +-----------------------------------------------*/

	AR_BILLS_MAINTAIN_LIB_PVT.Default_Action_Dates (l_trx_date, l_gl_date);


	/*----------------------------------------------+
        |   Data Validation				|
        +-----------------------------------------------*/

        l_mesg := arp_standard.fnd_message('AR_BR_SPMENU_ENDORSE');
	AR_BILLS_MAINTAIN_VAL_PVT.Validate_Action_Dates (l_trx_date, l_gl_date, l_trh_rec, l_mesg);

	l_trh_rec.trx_date		:=	l_trx_date	;
	l_trh_rec.gl_date		:=	l_gl_date	;
	l_trh_rec.comments		:=	p_endorse_comments;

	AR_BILLS_MAINTAIN_VAL_PVT.Validate_Adj_Activity_ID (p_adjustment_activity_id);


	/*----------------------------------------------+
        |   Endorsement					|
        +-----------------------------------------------*/


	IF	(p_recourse_flag	=	'Y')
	THEN

		/*----------------------------------------------+
	        |   Endorsement with recourse			|
	        +-----------------------------------------------*/

		l_action	:=	C_ENDORSE_RECOURSE;


		/*----------------------------------------------+
	        |   Create an adjustment with a status W :	|
		|   Waiting for approval			|
	        +-----------------------------------------------*/

		AR_BILLS_MAINTAIN_LIB_PVT.Create_Adjustment   (
					l_trh_rec			,
					p_customer_trx_id		,
					l_ps_rec			,
					l_ps_rec.amount_due_original	,
					p_adjustment_activity_id	,
					'W'				,
					l_move_deferred_tax		,
					new_adj_id			);

		/*----------------------------------------------+
	        |    Updates the Payment Schedule of the BR 	|
		|    with the Adjustment Information		|
        	+-----------------------------------------------*/

		AR_BILLS_MAINTAIN_LIB_PVT.update_reserved_columns (l_ps_rec.payment_schedule_id, 'ADJUSTMENT', new_adj_id);

	ELSE

		/*----------------------------------------------+
	        |   Endorsement without recourse		|
	        +-----------------------------------------------*/

		l_action	:=	C_ENDORSE;


		IF	(l_ps_rec.tax_remaining IS NOT NULL	and	l_ps_rec.tax_remaining <> 0)
		THEN
			l_move_deferred_tax	:=	'Y';
		END IF;

		/*----------------------------------------------+
	        |   Create an adjustment with a status A :	|
		|   Approved					|
	        +-----------------------------------------------*/

		AR_BILLS_MAINTAIN_LIB_PVT.Create_Adjustment   (
					l_trh_rec			,
					p_customer_trx_id		,
					l_ps_rec			,
					l_ps_rec.amount_due_original	,
					p_adjustment_activity_id	,
					'A'				,
					l_move_deferred_tax		,
					new_adj_id			);


		/*----------------------------------------------+
	        |  Insert the first Transaction History Record	|
	        +-----------------------------------------------*/

		-- Fetch the new status and new event of the BR

		AR_BILLS_MAINTAIN_STATUS_PUB.New_Status_Event (
			p_trx_rec	=>	l_trx_rec	,
			p_action        =>	l_action	,
			p_new_status	=>	l_trh_rec.status,
			p_new_event	=>	l_trh_rec.event	);

		l_trh_rec.transaction_history_id:=	NULL		;
		l_trh_rec.current_record_flag	:=  	'Y'		;
		l_trh_rec.prv_trx_history_id	:=  	NULL		;
		l_trh_rec.posting_control_id    := 	-3           	;
		l_trh_rec.gl_posted_date        :=  	NULL        	;
		l_trh_rec.first_posted_record_flag  := 	'N'		;
		l_trh_rec.created_from		:=	'ARBRMAIB'	;
		l_trh_rec.postable_flag		:=	'N'		;
		l_trh_rec.current_accounted_flag:=  	'N'		;

		arp_proc_transaction_history.insert_transaction_history (l_trh_rec, l_trh_rec.transaction_history_id);

	END IF;


	/*----------------------------------------------+
        |  Insert the Transaction History Record	|
        +-----------------------------------------------*/

	-- Fetch the new status and new event of the BR

	AR_BILLS_MAINTAIN_STATUS_PUB.New_Status_Event (
			p_trx_rec	=>	l_trx_rec	,
			p_action        =>	l_action	,
			p_new_status	=>	l_trh_rec.status,
			p_new_event	=>	l_trh_rec.event	);

	l_trh_rec.transaction_history_id:=	NULL		;
	l_trh_rec.current_record_flag	:=  	'Y'		;
	l_trh_rec.prv_trx_history_id	:=  	NULL		;
	l_trh_rec.posting_control_id    := 	-3           	;
	l_trh_rec.gl_posted_date        :=  	NULL        	;
	l_trh_rec.first_posted_record_flag  := 	'N'		;
	l_trh_rec.created_from		:=	'ARBRMAIB'	;
	l_trh_rec.postable_flag		:=	'N'		;
	l_trh_rec.current_accounted_flag:=  	'N'		;

	arp_proc_transaction_history.insert_transaction_history (l_trh_rec, l_trh_rec.transaction_history_id);


	/*-----------------------------------------------+
        |   Output parameter				 |
        +------------------------------------------------*/

	p_status			:=	l_trh_rec.status	;

       /*-----------------------------------------------+
        |   Standard check of p_commit   		|
        +-----------------------------------------------*/

        IF FND_API.To_Boolean( p_commit )
        THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug( 'committing');
            END IF;
            Commit;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('AR_BILLS_MAINTAIN_PUB.Endorse_BR()- ');
        END IF;


EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;
                ROLLBACK TO Endorse_BR_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
  	        IF PG_DEBUG in ('Y', 'C') THEN
  	           arp_util.debug( 'Exception Error');
  	        END IF;
		RAISE;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;
                ROLLBACK TO Endorse_BR_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( 'Exception Unexpected Error');
		END IF;
		RAISE;


        WHEN OTHERS THEN
               /*-------------------------------------------------------+
                |  Handle application errors that result from trapable  |
                |  error conditions. The error messages have already    |
                |  been put on the error stack.                         |
                +-------------------------------------------------------*/

		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;

		IF (SQLCODE = -20001)
                THEN
	    		ROLLBACK TO Endorse_BR_PVT;
                      	x_return_status := FND_API.G_RET_STS_ERROR ;
                      	RAISE;
                ELSE
		      	NULL;
                END IF;

                ROLLBACK TO Endorse_BR_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		RAISE;


END Endorse_BR;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Protest_BR			                                     	|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    Protest a BR							     	|
 |									  	|
 +==============================================================================*/


PROCEDURE Protest_BR (

           --   *****  Standard API parameters *****

                p_api_version      		IN  	NUMBER					,
                p_init_msg_list    		IN  	VARCHAR2 := FND_API.G_TRUE		,
                p_commit           		IN  	VARCHAR2 := FND_API.G_FALSE		,
                p_validation_level 		IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL	,
                x_return_status    		OUT NOCOPY 	VARCHAR2				,
                x_msg_count        		OUT NOCOPY 	NUMBER					,
                x_msg_data         		OUT NOCOPY 	VARCHAR2				,

           --   *****  Input parameters  *****

		p_customer_trx_id		IN  	NUMBER		,
		p_protest_date			IN  	DATE		,
		p_protest_comments		IN  	VARCHAR2	,

           --   *****  Output parameters  *****

		p_status			OUT NOCOPY 	VARCHAR2				)


IS
		l_api_name			CONSTANT VARCHAR2(20)	:=	'Protest_BR';
		l_api_version			CONSTANT NUMBER		:=	1.0;

		l_trh_rec			ar_transaction_history%ROWTYPE;
		l_trx_rec			RA_CUSTOMER_TRX%ROWTYPE;
		l_action			VARCHAR2(30);
		l_trx_date			DATE;
                l_mesg                          VARCHAR2(2000);

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_PUB.Protest_BR()+ ');
	END IF;

	x_msg_count				:=	NULL;
	x_msg_data				:=	NULL;

       /*-----------------------------------------------+
        |   Standard start of API savepoint     	|
        +-----------------------------------------------*/

     	SAVEPOINT Protest_BR_PVT;

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


       /*--------------------------------------------------------------+
        |   Initialize message list if p_init_msg_list is set to TRUE  |
        +--------------------------------------------------------------*/

        IF  FND_API.to_Boolean( p_init_msg_list )  THEN
 	             FND_MSG_PUB.initialize;
        END IF;


       /*-----------------------------------------------+
        |   Initialize return status to SUCCESS   	|
        +-----------------------------------------------*/

        x_return_status := FND_API.G_RET_STS_SUCCESS;


       /*-----------------------------------------------------------------------+
        |   ============  START OF API BODY - PROTEST BR  ===================  	|
        +-----------------------------------------------------------------------*/


	/*-----------------------------------------------+
        |   Validate the action				|
        +-----------------------------------------------*/

	l_action			:=	C_PROTEST;

	AR_BILLS_MAINTAIN_STATUS_PUB.validate_actions (
		p_customer_trx_id	=>  	p_customer_trx_id		,
		p_complete_flag		=>	C_ACTION_REC.complete_flag	,
		p_uncomplete_flag	=>	C_ACTION_REC.uncomplete_flag	,
		p_accept_flag		=>	C_ACTION_REC.accept_flag	,
		p_cancel_flag		=>	C_ACTION_REC.cancel_flag	,
		p_select_remit_flag	=>	C_ACTION_REC.select_remit_flag	,
		p_deselect_remit_flag	=>	C_ACTION_REC.deselect_remit_flag,
		p_approve_remit_flag	=>	C_ACTION_REC.approve_remit_flag	,
		p_hold_flag		=>	C_ACTION_REC.hold_flag		,
		p_unhold_flag		=>	C_ACTION_REC.unhold_flag	,
		p_recall_flag		=>	C_ACTION_REC.recall_flag	,
		p_eliminate_flag	=>	C_ACTION_REC.eliminate_flag	,
		p_uneliminate_flag	=>	C_ACTION_REC.uneliminate_flag	,
		p_unpaid_flag		=>	C_ACTION_REC.unpaid_flag	,
		p_protest_flag		=>	C_ACTION_REC.protest_flag	,
		p_endorse_flag		=>	C_ACTION_REC.endorse_flag	,
		p_restate_flag		=>	C_ACTION_REC.restate_flag	,
		p_exchange_flag		=>	C_ACTION_REC.exchange_flag	,
		p_delete_flag		=>	C_ACTION_REC.delete_flag	);


	-- Do not continue if the action is not allowed for the BR

	ARP_CT_PKG.fetch_p (l_trx_rec, p_customer_trx_id);

	IF	(C_ACTION_REC.protest_flag	<>	'Y')
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( '>>>>>>>>>> The action ' || l_action || ' is not allowed on the BR ' || p_customer_trx_id);
		END IF;
		FND_MESSAGE.set_name	( 'AR', 'AR_BR_CANNOT_PROTEST' );
		FND_MESSAGE.set_token	( 'BRNUM' 	,  l_trx_rec.trx_number);
		app_exception.raise_exception;
	END IF;


	/*-----------------------------------------------+
        |   Data preparation 				|
        +-----------------------------------------------*/

	l_trh_rec.customer_trx_id	:=	p_customer_trx_id;
	ARP_TRANSACTION_HISTORY_PKG.lock_fetch_f_trx_id (l_trh_rec);

	l_trx_date			:=	trunc(nvl(p_protest_date, sysdate));


	/*-----------------------------------------------+
        |   Data validation				|
        +-----------------------------------------------*/

        l_mesg := arp_standard.fnd_message('AR_BR_SPMENU_PROTEST');
	AR_BILLS_MAINTAIN_VAL_PVT.validate_Action_Dates (l_trx_date, NULL, l_trh_rec, l_mesg);

	l_trh_rec.trx_date		:=	l_trx_date;
	l_trh_rec.comments		:=	p_protest_comments;


	/*----------------------------------------------+
        |  Insert the Transaction History Record	|
        +-----------------------------------------------*/

	-- Fetch the new status and new event of the BR

	AR_BILLS_MAINTAIN_STATUS_PUB.New_Status_Event (
			p_trx_rec	=>	l_trx_rec	,
			p_action        =>	l_action	,
			p_new_status	=>	l_trh_rec.status,
			p_new_event	=>	l_trh_rec.event	);

	l_trh_rec.transaction_history_id:=	NULL		;
	l_trh_rec.current_record_flag	:=  	'Y'		;
	l_trh_rec.prv_trx_history_id	:=  	NULL		;
	l_trh_rec.posting_control_id    := 	-3           	;
	l_trh_rec.gl_posted_date        :=  	NULL        	;
	l_trh_rec.first_posted_record_flag  := 	'N'		;
	l_trh_rec.created_from		:=	'ARBRMAIB'	;
	l_trh_rec.postable_flag		:=	'N'		;
	l_trh_rec.current_accounted_flag:=  	'N'		;

	arp_proc_transaction_history.insert_transaction_history (l_trh_rec, l_trh_rec.transaction_history_id);


	/*-----------------------------------------------+
        |   Output parameter				 |
        +------------------------------------------------*/

	p_status			:=	l_trh_rec.status	;


       /*-----------------------------------------------+
        |   Standard check of p_commit   		|
        +-----------------------------------------------*/

        IF FND_API.To_Boolean( p_commit )
        THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug( 'committing');
            END IF;
            Commit;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('AR_BILLS_MAINTAIN_PUB.Protest_BR()- ');
        END IF;


EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;
                ROLLBACK TO Protest_BR_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
  	        IF PG_DEBUG in ('Y', 'C') THEN
  	           arp_util.debug( 'Exception Error');
  	        END IF;
		RAISE;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;
                ROLLBACK TO Protest_BR_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( 'Exception Unexpected Error');
		END IF;
		RAISE;


        WHEN OTHERS THEN
               /*-------------------------------------------------------+
                |  Handle application errors that result from trapable  |
                |  error conditions. The error messages have already    |
                |  been put on the error stack.                         |
                +-------------------------------------------------------*/

		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;

		IF (SQLCODE = -20001)
                THEN
	               	ROLLBACK TO Protest_BR_PVT;
                      	x_return_status := FND_API.G_RET_STS_ERROR ;
                      	RAISE;
                ELSE
		      	NULL;
                END IF;

                ROLLBACK TO Protest_BR_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

		RAISE;

END Protest_BR;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Restate_BR			                                     	|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    Restates a BR							     	|
 |									  	|
 +==============================================================================*/


PROCEDURE Restate_BR (

           --   *****  Standard API parameters *****

                p_api_version   		IN  	NUMBER					,
                p_init_msg_list 		IN  	VARCHAR2 := FND_API.G_TRUE		,
                p_commit        		IN  	VARCHAR2 := FND_API.G_FALSE		,
                p_validation_level		IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL	,
                x_return_status   		OUT NOCOPY 	VARCHAR2				,
                x_msg_count       		OUT NOCOPY 	NUMBER					,
                x_msg_data        		OUT NOCOPY 	VARCHAR2				,


           --   *****  Input parameters  *****

		p_customer_trx_id		IN  	NUMBER		,
		p_restatement_date		IN  	DATE		,
		p_restatement_gl_date		IN  	DATE		,
		p_restatement_comments		IN  	VARCHAR2	,


           --   *****  Output parameters  *****

		p_status			OUT NOCOPY VARCHAR2					)

IS
		l_api_name			CONSTANT VARCHAR2(20)	:=	'Restate_BR';
		l_api_version			CONSTANT NUMBER		:=	1.0;

		l_trh_rec			ar_transaction_history%ROWTYPE	;
		l_trx_rec			RA_CUSTOMER_TRX%ROWTYPE		;
		l_action			VARCHAR2(30)			;
		l_trx_date			DATE				;
		l_gl_date			DATE				;
                l_mesg                          VARCHAR2(2000);

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_PUB.Restate_BR()+ ');
	END IF;

	x_msg_count				:=	NULL;
	x_msg_data				:=	NULL;

       /*-----------------------------------------------+
        |   Standard start of API savepoint     	|
        +-----------------------------------------------*/

     	SAVEPOINT Restate_BR_PVT;

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


       /*--------------------------------------------------------------+
        |   Initialize message list if p_init_msg_list is set to TRUE  |
        +--------------------------------------------------------------*/

        IF  FND_API.to_Boolean( p_init_msg_list )  THEN
 	             FND_MSG_PUB.initialize;
        END IF;


       /*-----------------------------------------------+
        |   Initialize return status to SUCCESS   	|
        +-----------------------------------------------*/

        x_return_status := FND_API.G_RET_STS_SUCCESS;


       /*-----------------------------------------------------------------------+
        |   ============  START OF API BODY - RESTATE BR  ===================  	|
        +-----------------------------------------------------------------------*/


	/*-----------------------------------------------+
        |   Validate the action				|
        +-----------------------------------------------*/

	l_action			:=	C_RESTATE;

	AR_BILLS_MAINTAIN_STATUS_PUB.validate_actions (
		p_customer_trx_id	=>  	p_customer_trx_id		,
		p_complete_flag		=>	C_ACTION_REC.complete_flag	,
		p_uncomplete_flag	=>	C_ACTION_REC.uncomplete_flag	,
		p_accept_flag		=>	C_ACTION_REC.accept_flag	,
		p_cancel_flag		=>	C_ACTION_REC.cancel_flag	,
		p_select_remit_flag	=>	C_ACTION_REC.select_remit_flag	,
		p_deselect_remit_flag	=>	C_ACTION_REC.deselect_remit_flag,
		p_approve_remit_flag	=>	C_ACTION_REC.approve_remit_flag	,
		p_hold_flag		=>	C_ACTION_REC.hold_flag		,
		p_unhold_flag		=>	C_ACTION_REC.unhold_flag	,
		p_recall_flag		=>	C_ACTION_REC.recall_flag	,
		p_eliminate_flag	=>	C_ACTION_REC.eliminate_flag	,
		p_uneliminate_flag	=>	C_ACTION_REC.uneliminate_flag	,
		p_unpaid_flag		=>	C_ACTION_REC.unpaid_flag	,
		p_protest_flag		=>	C_ACTION_REC.protest_flag	,
		p_endorse_flag		=>	C_ACTION_REC.endorse_flag	,
		p_restate_flag		=>	C_ACTION_REC.restate_flag	,
		p_exchange_flag		=>	C_ACTION_REC.exchange_flag	,
		p_delete_flag		=>	C_ACTION_REC.delete_flag	);

	-- Do not continue if the action is not allowed for the BR

	ARP_CT_PKG.fetch_p (l_trx_rec, p_customer_trx_id);

	IF	(C_ACTION_REC.restate_flag	<>	'Y')
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( '>>>>>>>>>> The action ' || l_action || ' is not allowed on the BR ' || p_customer_trx_id);
		END IF;
		FND_MESSAGE.set_name	( 'AR', 'AR_BR_CANNOT_RESTATE' );
		FND_MESSAGE.set_token	( 'BRNUM' 	,  l_trx_rec.trx_number);
		app_exception.raise_exception;
	END IF;


	/*----------------------------------------------+
        |   Data preparation 				|
        +-----------------------------------------------*/

	l_trh_rec.customer_trx_id	:=	p_customer_trx_id;
	ARP_TRANSACTION_HISTORY_PKG.lock_fetch_f_trx_id (l_trh_rec);

	l_trx_date			:=	trunc(p_restatement_date);
	l_gl_date			:=	trunc(p_restatement_gl_date);

	AR_BILLS_MAINTAIN_LIB_PVT.Default_Action_Dates (l_trx_date, l_gl_date);


	/*----------------------------------------------+
        |   Data validation  				|
        +-----------------------------------------------*/

        l_mesg := arp_standard.fnd_message('AR_BR_SPMENU_RESTATE');
	AR_BILLS_MAINTAIN_VAL_PVT.validate_Action_Dates (l_trx_date, l_gl_date, l_trh_rec, l_mesg);

	l_trh_rec.trx_date		:=	l_trx_date		;
	l_trh_rec.gl_date		:=	l_gl_date		;
	l_trh_rec.comments		:=	p_restatement_comments	;


	/*----------------------------------------------+
        |  Set the Unpaid Flag to NULL in the BR Header	|
        +-----------------------------------------------*/

	l_trx_rec.br_unpaid_flag	:=	'N';

	ARP_PROCESS_BR_HEADER.update_header  (  l_trx_rec	,
						l_trx_rec.customer_trx_id);

	/*----------------------------------------------+
        |  Insert the Transaction History Record	|
        +-----------------------------------------------*/

	-- Fetch the new status and new event of the BR

	AR_BILLS_MAINTAIN_STATUS_PUB.New_Status_Event (
			p_trx_rec	=>	l_trx_rec	,
			p_action        =>	l_action	,
			p_new_status	=>	l_trh_rec.status,
			p_new_event	=>	l_trh_rec.event	);

	l_trh_rec.transaction_history_id:=	NULL		;
	l_trh_rec.current_record_flag	:=  	'Y'		;
	l_trh_rec.prv_trx_history_id	:=  	NULL		;
	l_trh_rec.posting_control_id    := 	-3           	;
	l_trh_rec.gl_posted_date        :=  	NULL        	;
	l_trh_rec.first_posted_record_flag  := 	'N'		;
	l_trh_rec.created_from		:=	'ARBRMAIB'	;
	l_trh_rec.postable_flag		:=	'Y'		;
	l_trh_rec.current_accounted_flag:=  	'Y'		;

	arp_proc_transaction_history.insert_transaction_history (l_trh_rec	,
								 l_trh_rec.transaction_history_id);


	/*-----------------------------------------------+
        |   Output parameter				 |
        +------------------------------------------------*/

	p_status			:=	l_trh_rec.status	;


       /*-----------------------------------------------+
        |   Standard check of p_commit   		|
        +-----------------------------------------------*/

        IF FND_API.To_Boolean( p_commit )
        THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug( 'committing');
            END IF;
            Commit;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('AR_BILLS_MAINTAIN_PUB.Restate_BR()- ');
        END IF;


EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;
                ROLLBACK TO Restate_BR_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
  	        IF PG_DEBUG in ('Y', 'C') THEN
  	           arp_util.debug( 'Exception Error');
  	        END IF;
		RAISE;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;
                ROLLBACK TO Restate_BR_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( 'Exception Unexpected Error');
		END IF;
		RAISE;


        WHEN OTHERS THEN
               /*-------------------------------------------------------+
                |  Handle application errors that result from trapable  |
                |  error conditions. The error messages have already    |
                |  been put on the error stack.                         |
                +-------------------------------------------------------*/

		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;

		IF (SQLCODE = -20001)
                THEN
	               	ROLLBACK TO Restate_BR_PVT;
                      	x_return_status := FND_API.G_RET_STS_ERROR ;
                      	RAISE;
                ELSE
		      	NULL;
                END IF;

                ROLLBACK TO Restate_BR_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		RAISE;


END Restate_BR;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Recall_BR				                                     	|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    Recalls a BR							     	|
 |									  	|
 +==============================================================================*/


PROCEDURE Recall_BR (

           --   *****  Standard API parameters *****

                p_api_version      		IN  	NUMBER					,
                p_init_msg_list    		IN  	VARCHAR2 := FND_API.G_TRUE		,
                p_commit           		IN  	VARCHAR2 := FND_API.G_FALSE		,
                p_validation_level 		IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL	,
                x_return_status    		OUT NOCOPY 	VARCHAR2				,
                x_msg_count        		OUT NOCOPY 	NUMBER					,
                x_msg_data         		OUT NOCOPY 	VARCHAR2				,

           --   *****  Input parameters  *****

		p_customer_trx_id		IN  	NUMBER		,
		p_recall_date			IN  	DATE		,
		p_recall_gl_date		IN  	DATE		,
		p_recall_comments		IN  	VARCHAR2	,

           --   *****  Output parameters  *****

		p_status			OUT NOCOPY 	VARCHAR2				)

IS
		l_api_name			CONSTANT VARCHAR2(20)	:=	'Recall_BR';
		l_api_version			CONSTANT NUMBER		:=	1.0;

		l_trh_rec			ar_transaction_history%ROWTYPE		;
		l_trx_rec			RA_CUSTOMER_TRX%ROWTYPE			;
		l_ps_rec			AR_PAYMENT_SCHEDULES%ROWTYPE		;
		l_adj_id			AR_ADJUSTMENTS.adjustment_id%TYPE	;
		l_action			VARCHAR2(30)				;
		l_trx_date			DATE					;
		l_gl_date			DATE					;

		l_cash_receipt_id		ar_cash_receipts.cash_receipt_id%TYPE	;
		l_receivable_application_id	ar_receivable_applications.receivable_application_id%TYPE;
                l_mesg                          VARCHAR2(2000);

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_PUB.Recall_BR()+ ');
	END IF;

	x_msg_count				:=	NULL;
	x_msg_data				:=	NULL;

       /*-----------------------------------------------+
        |   Standard start of API savepoint     	|
        +-----------------------------------------------*/

     	SAVEPOINT Recall_BR_PVT;

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


       /*--------------------------------------------------------------+
        |   Initialize message list if p_init_msg_list is set to TRUE  |
        +--------------------------------------------------------------*/

        IF  FND_API.to_Boolean( p_init_msg_list )  THEN
 	             FND_MSG_PUB.initialize;
        END IF;


       /*-----------------------------------------------+
        |   Initialize return status to SUCCESS   	|
        +-----------------------------------------------*/

        x_return_status := FND_API.G_RET_STS_SUCCESS;


       /*-----------------------------------------------------------------------+
        |   ============  START OF API BODY - RECALL BR  ===================  	|
        +-----------------------------------------------------------------------*/


	/*-----------------------------------------------+
        |   Validate the action				|
        +-----------------------------------------------*/

	l_action			:=	C_RECALL;

	AR_BILLS_MAINTAIN_STATUS_PUB.validate_actions (
		p_customer_trx_id	=>  	p_customer_trx_id		,
		p_complete_flag		=>	C_ACTION_REC.complete_flag	,
		p_uncomplete_flag	=>	C_ACTION_REC.uncomplete_flag	,
		p_accept_flag		=>	C_ACTION_REC.accept_flag	,
		p_cancel_flag		=>	C_ACTION_REC.cancel_flag	,
		p_select_remit_flag	=>	C_ACTION_REC.select_remit_flag	,
		p_deselect_remit_flag	=>	C_ACTION_REC.deselect_remit_flag,
		p_approve_remit_flag	=>	C_ACTION_REC.approve_remit_flag	,
		p_hold_flag		=>	C_ACTION_REC.hold_flag		,
		p_unhold_flag		=>	C_ACTION_REC.unhold_flag	,
		p_recall_flag		=>	C_ACTION_REC.recall_flag	,
		p_eliminate_flag	=>	C_ACTION_REC.eliminate_flag	,
		p_uneliminate_flag	=>	C_ACTION_REC.uneliminate_flag	,
		p_unpaid_flag		=>	C_ACTION_REC.unpaid_flag	,
		p_protest_flag		=>	C_ACTION_REC.protest_flag	,
		p_endorse_flag		=>	C_ACTION_REC.endorse_flag	,
		p_restate_flag		=>	C_ACTION_REC.restate_flag	,
		p_exchange_flag		=>	C_ACTION_REC.exchange_flag	,
		p_delete_flag		=>	C_ACTION_REC.delete_flag	);

	-- Do not continue if the action is not allowed for the BR

	ARP_CT_PKG.fetch_p (l_trx_rec, p_customer_trx_id);

	IF	(C_ACTION_REC.recall_flag	<>	'Y')
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( '>>>>>>>>>> The action ' || l_action || ' is not allowed on the BR ' || p_customer_trx_id);
		END IF;
		FND_MESSAGE.set_name	( 'AR', 'AR_BR_CANNOT_RECALL' );
		FND_MESSAGE.set_token	( 'BRNUM'	, l_trx_rec.trx_number);
		app_exception.raise_exception;
	END IF;


	/*----------------------------------------------+
        |   Data preparation 				|
        +-----------------------------------------------*/

	l_trh_rec.customer_trx_id	:=	p_customer_trx_id;
	ARP_TRANSACTION_HISTORY_PKG.lock_fetch_f_trx_id (l_trh_rec);

	l_trx_date			:=	trunc(p_recall_date);
	l_gl_date			:=	trunc(p_recall_gl_date);

	AR_BILLS_MAINTAIN_LIB_PVT.Default_Action_Dates (l_trx_date, l_gl_date);


	/*----------------------------------------------+
        |   Data Validation 				|
        +-----------------------------------------------*/

        l_mesg := arp_standard.fnd_message('AR_BR_SPMENU_RECALL');
	AR_BILLS_MAINTAIN_VAL_PVT.validate_Action_Dates (l_trx_date, l_gl_date, l_trh_rec, l_mesg);

	l_trh_rec.trx_date		:=	l_trx_date		;
	l_trh_rec.gl_date		:=	l_gl_date		;
	l_trh_rec.comments		:=	p_recall_comments	;


	/*-----------------------------------------------+
        |   RECALL	 				 |
        +-----------------------------------------------*/

	IF	(l_trh_rec.status	=	C_REMITTED)
	THEN
		l_trh_rec.postable_flag			:=	'Y';
		l_trh_rec.current_accounted_flag	:=	'Y';

	ELSIF	(l_trh_rec.status 	=	C_FACTORED)
	THEN

		/*----------------------------------------------+
	        |   Reverse the receipt applied to STD		|
	        +-----------------------------------------------*/

		AR_BILLS_MAINTAIN_LIB_PVT.Find_Last_STD   (l_trh_rec.customer_trx_id, l_cash_receipt_id, l_receivable_application_id);
		AR_BILLS_MAINTAIN_LIB_PVT.Reverse_Receipt (l_trh_rec, l_cash_receipt_id, 'PAYMENT REVERSAL', C_BR_FACTORED_RECOURSE);
		l_trh_rec.postable_flag			:=	'Y';
		l_trh_rec.current_accounted_flag	:=	'Y';

	ELSIF	(l_trh_rec.status	=	C_ENDORSED)
	THEN

		/*----------------------------------------------+
	        |   Reject the adjustment created during the	|
		|   endorsement. Status = 'R'	(Reject)	|
	        +-----------------------------------------------*/

		AR_BILLS_MAINTAIN_LIB_PVT.Find_Last_Adjustment (p_customer_trx_id, l_adj_id);
		AR_BILLS_MAINTAIN_LIB_PVT.Modify_Adjustment    (l_adj_id, 'R');
		l_trh_rec.postable_flag			:=	'N';
		l_trh_rec.current_accounted_flag	:=	'N';
	END IF;


	/*-----------------------------------------------+
        |   Remove the Remittance or adjustment tags	 |
	|   on the BR Payment Schedule			 |
        +-----------------------------------------------*/

	AR_BILLS_CREATION_LIB_PVT.Get_Payment_Schedule_Id (p_customer_trx_id, l_ps_rec.payment_schedule_id);
	AR_BILLS_MAINTAIN_LIB_PVT.update_reserved_columns (l_ps_rec.payment_schedule_id, NULL , NULL);


	/*----------------------------------------------+
        |  Insert the Transaction History Record	|
        +-----------------------------------------------*/

	-- Fetch the new status and new event of the BR

	AR_BILLS_MAINTAIN_STATUS_PUB.New_Status_Event (
			p_trx_rec	=>	l_trx_rec	,
			p_action        =>	l_action	,
			p_new_status	=>	l_trh_rec.status,
			p_new_event	=>	l_trh_rec.event	);

	l_trh_rec.transaction_history_id:=	NULL		;
	l_trh_rec.current_record_flag	:=  	'Y'		;
	l_trh_rec.prv_trx_history_id	:=  	NULL		;
	l_trh_rec.posting_control_id    := 	-3           	;
	l_trh_rec.gl_posted_date        :=  	NULL        	;
	l_trh_rec.first_posted_record_flag  := 	'N'		;
	l_trh_rec.created_from		:=	'ARBRMAIB'	;
	l_trh_rec.batch_id		:=	NULL		;

	arp_proc_transaction_history.insert_transaction_history (l_trh_rec	,
								 l_trh_rec.transaction_history_id);


	/*----------------------------------------------+
        |   Remove the Remittance Information of the 	|
	|   BR Header if it exists			|
        +-----------------------------------------------*/

	l_trx_rec.receipt_method_id		:=	NULL;

	ARP_PROCESS_BR_HEADER.update_header  (  l_trx_rec, l_trx_rec.customer_trx_id);


	/*-----------------------------------------------+
        |   Output parameter				 |
        +------------------------------------------------*/

	p_status			:=	l_trh_rec.status	;


       /*-----------------------------------------------+
        |   Standard check of p_commit   		|
        +-----------------------------------------------*/

        IF FND_API.To_Boolean( p_commit )
        THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug( 'committing');
            END IF;
            Commit;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('AR_BILLS_MAINTAIN_PUB.Recall_BR()- ');
        END IF;


EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;
                ROLLBACK TO Recall_BR_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
  	        IF PG_DEBUG in ('Y', 'C') THEN
  	           arp_util.debug( 'Exception Error');
  	        END IF;
		RAISE;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;
                ROLLBACK TO Recall_BR_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( 'Exception Unexpected Error');
		END IF;
		RAISE;


        WHEN OTHERS THEN
               /*-------------------------------------------------------+
                |  Handle application errors that result from trapable  |
                |  error conditions. The error messages have already    |
                |  been put on the error stack.                         |
                +-------------------------------------------------------*/

		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;

		IF (SQLCODE = -20001)
                THEN
	               	ROLLBACK TO Recall_BR_PVT;
                      	x_return_status := FND_API.G_RET_STS_ERROR ;
                      	RAISE;
                ELSE
		      	NULL;
                END IF;

                ROLLBACK TO Recall_BR_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
 		RAISE;


END Recall_BR;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Eliminate_Risk_BR			                                     	|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    Eliminates from Risk 						     	|
 |									  	|
 +==============================================================================*/


PROCEDURE Eliminate_Risk_BR (

           --   *****  Standard API parameters *****

                p_api_version     		IN  	NUMBER					,
                p_init_msg_list   		IN  	VARCHAR2 := FND_API.G_TRUE		,
                p_commit          		IN  	VARCHAR2 := FND_API.G_FALSE		,
                p_validation_level		IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL	,
                x_return_status   		OUT NOCOPY 	VARCHAR2				,
                x_msg_count       		OUT NOCOPY 	NUMBER					,
                x_msg_data        		OUT NOCOPY 	VARCHAR2				,


           --   *****  Input parameters  *****

		p_customer_trx_id		IN  	NUMBER		,
		p_risk_eliminate_date		IN  	DATE		,
		p_risk_eliminate_gl_date	IN  	DATE		,
		p_risk_eliminate_comments	IN  	VARCHAR2	,

           --   *****  Output parameters  *****

		p_status			OUT NOCOPY 	VARCHAR2) IS

  l_api_name 		CONSTANT VARCHAR2(20)	:= 'Eliminate_Risk_BR';
  l_api_version		CONSTANT NUMBER		:= 1.0;
  l_trh_rec		ar_transaction_history%ROWTYPE;
  l_trx_rec		RA_CUSTOMER_TRX%ROWTYPE;
  l_ps_rec		AR_PAYMENT_SCHEDULES%ROWTYPE;
  l_cash_receipt_id	AR_CASH_RECEIPTS.cash_receipt_id%TYPE;
  l_adj_id		AR_ADJUSTMENTS.adjustment_id%TYPE;
  l_move_deferred_tax	VARCHAR2(1)		:= 'N';
  l_action		VARCHAR2(30);
  l_trx_date		DATE;
  l_gl_date		DATE;
  l_mesg                VARCHAR2(2000);

  -- Added for bug # 2712726
  -- ORASHID
  --
  l_nocopy_payment_schedule_id  ar_payment_schedules.payment_schedule_id%TYPE;

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_PUB.Eliminate_Risk_BR ()+ ');
	END IF;

	x_msg_count				:=	NULL;
	x_msg_data				:=	NULL;

       /*-----------------------------------------------+
        |   Standard start of API savepoint     	|
        +-----------------------------------------------*/

     	SAVEPOINT Eliminate_Risk_BR_PVT;

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


       /*--------------------------------------------------------------+
        |   Initialize message list if p_init_msg_list is set to TRUE  |
        +--------------------------------------------------------------*/

        IF  FND_API.to_Boolean( p_init_msg_list )  THEN
 	             FND_MSG_PUB.initialize;
        END IF;


       /*-----------------------------------------------+
        |   Initialize return status to SUCCESS   	|
        +-----------------------------------------------*/

        x_return_status := FND_API.G_RET_STS_SUCCESS;


       /*-----------------------------------------------------------------------+
        |   ============  START OF API BODY - ELIMINATE RISK BR  ============  	|
        +-----------------------------------------------------------------------*/


	/*-----------------------------------------------+
        |   Validate the action				|
        +-----------------------------------------------*/

	l_action			:=	C_ELIMINATE_RISK;

	AR_BILLS_MAINTAIN_STATUS_PUB.validate_actions (
		p_customer_trx_id	=>  	p_customer_trx_id		,
		p_complete_flag		=>	C_ACTION_REC.complete_flag	,
		p_uncomplete_flag	=>	C_ACTION_REC.uncomplete_flag	,
		p_accept_flag		=>	C_ACTION_REC.accept_flag	,
		p_cancel_flag		=>	C_ACTION_REC.cancel_flag	,
		p_select_remit_flag	=>	C_ACTION_REC.select_remit_flag	,
		p_deselect_remit_flag	=>	C_ACTION_REC.deselect_remit_flag,
		p_approve_remit_flag	=>	C_ACTION_REC.approve_remit_flag	,
		p_hold_flag		=>	C_ACTION_REC.hold_flag		,
		p_unhold_flag		=>	C_ACTION_REC.unhold_flag	,
		p_recall_flag		=>	C_ACTION_REC.recall_flag	,
		p_eliminate_flag	=>	C_ACTION_REC.eliminate_flag	,
		p_uneliminate_flag	=>	C_ACTION_REC.uneliminate_flag	,
		p_unpaid_flag		=>	C_ACTION_REC.unpaid_flag	,
		p_protest_flag		=>	C_ACTION_REC.protest_flag	,
		p_endorse_flag		=>	C_ACTION_REC.endorse_flag	,
		p_restate_flag		=>	C_ACTION_REC.restate_flag	,
		p_exchange_flag		=>	C_ACTION_REC.exchange_flag	,
		p_delete_flag		=>	C_ACTION_REC.delete_flag	);

	-- Do not continue if the action is not allowed for the BR

	ARP_CT_PKG.fetch_p (l_trx_rec, p_customer_trx_id);

	IF	(C_ACTION_REC.eliminate_flag	<>	'Y')
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( '>>>>>>>>>> The action ' || l_action || ' is not allowed on the BR ' || l_trx_rec.trx_number);
		END IF;
		FND_MESSAGE.set_name	( 'AR', 'AR_BR_CANNOT_ELIMINATE' );
		FND_MESSAGE.set_token	( 'BRNUM'	,  l_trx_rec.trx_number);
		app_exception.raise_exception;
	END IF;


	/*----------------------------------------------+
        |   Data preparation 				|
        +-----------------------------------------------*/

	l_trh_rec.customer_trx_id	:=	p_customer_trx_id;
	ARP_TRANSACTION_HISTORY_PKG.lock_fetch_f_trx_id (l_trh_rec);

	l_trx_date			:=	trunc(p_risk_eliminate_date);
	l_gl_date			:=	trunc(p_risk_eliminate_gl_date);

	AR_BILLS_MAINTAIN_LIB_PVT.Default_Action_Dates (l_trx_date, l_gl_date);

	AR_BILLS_CREATION_LIB_PVT.Get_Payment_Schedule_Id (p_customer_trx_id, l_ps_rec.payment_schedule_id);

        -- Modified for bug # 2712726
        -- ORASHID
        --
        l_nocopy_payment_schedule_id := l_ps_rec.payment_schedule_id;
	arp_ps_pkg.fetch_p(l_nocopy_payment_schedule_id, l_ps_rec);

	/*----------------------------------------------+
        |   Data validation 				|
        +-----------------------------------------------*/

        l_mesg := arp_standard.fnd_message('AR_BR_SPMENU_ELIMINATE');
	AR_BILLS_MAINTAIN_VAL_PVT.Validate_Action_Dates (l_trx_date, l_gl_date, l_trh_rec, l_mesg);

	l_trh_rec.trx_date		:=	l_trx_date;
	l_trh_rec.gl_date		:=	l_gl_date;
	l_trh_rec.comments		:=	p_risk_eliminate_comments;


	/*-----------------------------------------------+
        |   RISK ELIMINATION 				 |
        +-----------------------------------------------*/

	IF	(l_trh_rec.status	=	C_MATURED_PEND_RISK_ELIM)
	THEN

		/*----------------------------------------------+
	        |   The receipt created during the remittance	|
		|   approval is unapplied from Short Term Debt	|
		|   and applied to the Bills Receivables	|
	        +-----------------------------------------------*/

		AR_BILLS_MAINTAIN_LIB_PVT.Unapply_STD 	(l_trh_rec, C_BR_FACTORED_RECOURSE, l_cash_receipt_id);
		AR_BILLS_MAINTAIN_LIB_PVT.Apply_Receipt	(l_trh_rec, l_ps_rec, l_cash_receipt_id, C_BR_FACTORED_RECOURSE);

	ELSIF	(l_trh_rec.status	=	C_ENDORSED)
	THEN
		IF	NOT (AR_BILLS_MAINTAIN_STATUS_PUB.Is_BR_Matured (l_ps_rec.due_date))
		THEN

			/*------------------------------------------------------+
		        |  The Maturity Date event has not happened, so	the 	|
			|  maturity event and payment event happen at the same 	|
			|  time. So we approve the adjustment and move deferred	|
			|  tax as part of the approval. Deferred tax is only	|
			|  moved if tax to be moved exists			|
		        +-------------------------------------------------------*/

			IF	(l_ps_rec.tax_remaining IS NOT NULL	and	l_ps_rec.tax_remaining <> 0)
			THEN
				l_move_deferred_tax	:=	'Y';
			END IF;

		END IF;


		/*----------------------------------------------+
	        |   The unapproved adjustment created during the|
		|   endorsment is approved			|
	        +-----------------------------------------------*/

		AR_BILLS_MAINTAIN_LIB_PVT.Find_Last_Adjustment 	(p_customer_trx_id, l_adj_id);
		AR_BILLS_MAINTAIN_LIB_PVT.Approve_Adjustment	(l_adj_id, l_move_deferred_tax);
	END IF;


	/*-----------------------------------------------+
        |   Remove the Remittance or adjustment tags	 |
	|   on the BR Payment Schedule			 |
        +-----------------------------------------------*/

	AR_BILLS_MAINTAIN_LIB_PVT.update_reserved_columns (l_ps_rec.payment_schedule_id, NULL , NULL);


	/*----------------------------------------------+
        |  Insert the Transaction History Record	|
        +-----------------------------------------------*/

	-- Fetch the new status and new event of the BR

	AR_BILLS_MAINTAIN_STATUS_PUB.New_Status_Event (
			p_trx_rec	=>	l_trx_rec	,
			p_action        =>	l_action	,
			p_new_status	=>	l_trh_rec.status,
			p_new_event	=>	l_trh_rec.event	);

	l_trh_rec.transaction_history_id:=	NULL		;
	l_trh_rec.postable_flag		:=	'N'		;
	l_trh_rec.current_accounted_flag:=	'N'		;
	l_trh_rec.current_record_flag	:=  	'Y'		;
	l_trh_rec.prv_trx_history_id	:=  	NULL		;
	l_trh_rec.posting_control_id    := 	-3           	;
	l_trh_rec.gl_posted_date        :=  	NULL        	;
	l_trh_rec.first_posted_record_flag  := 	'N'		;
	l_trh_rec.created_from		:=	'ARBRMAIB'	;
	l_trh_rec.batch_id		:=	NULL		;

	arp_proc_transaction_history.insert_transaction_history (l_trh_rec	,
								 l_trh_rec.transaction_history_id);


	/*-----------------------------------------------+
        |   Output parameter				 |
        +------------------------------------------------*/

	p_status			:=	l_trh_rec.status	;


       /*-----------------------------------------------+
        |   Standard check of p_commit   		|
        +-----------------------------------------------*/

        IF FND_API.To_Boolean( p_commit )
        THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug( 'committing');
            END IF;
            Commit;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('AR_BILLS_MAINTAIN_PUB.Eliminate_Risk_BR ()- ');
        END IF;


EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;
                ROLLBACK TO Eliminate_Risk_BR_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
  	        IF PG_DEBUG in ('Y', 'C') THEN
  	           arp_util.debug( 'Exception Error');
  	        END IF;
		RAISE;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;
                ROLLBACK TO Eliminate_Risk_BR_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( 'Exception Unexpected Error');
		END IF;
		RAISE;


        WHEN OTHERS THEN
               /*-------------------------------------------------------+
                |  Handle application errors that result from trapable  |
                |  error conditions. The error messages have already    |
                |  been put on the error stack.                         |
                +-------------------------------------------------------*/

		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;

		IF (SQLCODE = -20001)
                THEN
	               	ROLLBACK TO Eliminate_Risk_BR_PVT;
                      	x_return_status := FND_API.G_RET_STS_ERROR ;
                      	RAISE;
                ELSE
		      	NULL;
                END IF;

                ROLLBACK TO Eliminate_Risk_BR_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

		RAISE;

END Eliminate_Risk_BR;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    UnEliminate_Risk_BR		                                     	|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    UnEliminates from Risk 						     	|
 |									  	|
 +==============================================================================*/


PROCEDURE UnEliminate_Risk_BR (

           --   *****  Standard API parameters *****

                p_api_version      		IN  	NUMBER					,
                p_init_msg_list    		IN  	VARCHAR2 := FND_API.G_TRUE		,
                p_commit           		IN  	VARCHAR2 := FND_API.G_FALSE		,
                p_validation_level 		IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL	,
                x_return_status    		OUT NOCOPY 	VARCHAR2				,
                x_msg_count        		OUT NOCOPY 	NUMBER					,
                x_msg_data         		OUT NOCOPY 	VARCHAR2				,

           --   *****  Input parameters  *****

		p_customer_trx_id		IN  	NUMBER		,
		p_risk_uneliminate_date		IN  	DATE		,
		p_risk_uneliminate_gl_date	IN  	DATE		,
		p_risk_uneliminate_comments	IN  	VARCHAR2	,

           --   *****  Output parameters  *****

		p_status			OUT NOCOPY VARCHAR2) IS


  l_api_name		CONSTANT VARCHAR2(20)	:= 'UnEliminate_Risk_BR';
  l_api_version		CONSTANT NUMBER		:= 1.0	;

  l_trh_rec		ar_transaction_history%ROWTYPE;
  l_trh_prev_rec	ar_transaction_history%ROWTYPE;
  l_trx_rec		RA_CUSTOMER_TRX%ROWTYPE;
  l_ps_rec		AR_PAYMENT_SCHEDULES%ROWTYPE;
  l_cash_receipt_id	AR_CASH_RECEIPTS.cash_receipt_id%TYPE;
  l_adj_id		AR_ADJUSTMENTS.adjustment_id%TYPE;
  l_move_deferred_tax	VARCHAR2(1):= 'N';
  l_action		VARCHAR2(30);
  l_trx_date		DATE;
  l_gl_date		DATE;
  l_new_adj_id		NUMBER;
  l_receivables_trx_id	NUMBER;
  l_mesg                VARCHAR2(2000);

  -- Added for bug # 2712726
  -- ORASHID
  --
  l_nocopy_payment_schedule_id  ar_payment_schedules.payment_schedule_id%TYPE;

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_PUB.UnEliminate_Risk_BR ()+ ');
	END IF;

	x_msg_count				:=	NULL;
	x_msg_data				:=	NULL;

       /*-----------------------------------------------+
        |   Standard start of API savepoint     	|
        +-----------------------------------------------*/

     	SAVEPOINT UnEliminate_Risk_BR_PVT;

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


       /*--------------------------------------------------------------+
        |   Initialize message list if p_init_msg_list is set to TRUE  |
        +--------------------------------------------------------------*/

        IF  FND_API.to_Boolean( p_init_msg_list )  THEN
 	             FND_MSG_PUB.initialize;
        END IF;


       /*-----------------------------------------------+
        |   Initialize return status to SUCCESS   	|
        +-----------------------------------------------*/

        x_return_status := FND_API.G_RET_STS_SUCCESS;


       /*-----------------------------------------------------------------------+
        |   ============  START OF API BODY - UNELIMINATE RISK BR  =============|
        +-----------------------------------------------------------------------*/


	/*-----------------------------------------------+
        |   Validate the action				|
        +-----------------------------------------------*/

	l_action			:=	C_UNELIMINATE_RISK;

	AR_BILLS_MAINTAIN_STATUS_PUB.validate_actions (
		p_customer_trx_id	=>  	p_customer_trx_id		,
		p_complete_flag		=>	C_ACTION_REC.complete_flag	,
		p_uncomplete_flag	=>	C_ACTION_REC.uncomplete_flag	,
		p_accept_flag		=>	C_ACTION_REC.accept_flag	,
		p_cancel_flag		=>	C_ACTION_REC.cancel_flag	,
		p_select_remit_flag	=>	C_ACTION_REC.select_remit_flag	,
		p_deselect_remit_flag	=>	C_ACTION_REC.deselect_remit_flag,
		p_approve_remit_flag	=>	C_ACTION_REC.approve_remit_flag	,
		p_hold_flag		=>	C_ACTION_REC.hold_flag		,
		p_unhold_flag		=>	C_ACTION_REC.unhold_flag	,
		p_recall_flag		=>	C_ACTION_REC.recall_flag	,
		p_eliminate_flag	=>	C_ACTION_REC.eliminate_flag	,
		p_uneliminate_flag	=>	C_ACTION_REC.uneliminate_flag	,
		p_unpaid_flag		=>	C_ACTION_REC.unpaid_flag	,
		p_protest_flag		=>	C_ACTION_REC.protest_flag	,
		p_endorse_flag		=>	C_ACTION_REC.endorse_flag	,
		p_restate_flag		=>	C_ACTION_REC.restate_flag	,
		p_exchange_flag		=>	C_ACTION_REC.exchange_flag	,
		p_delete_flag		=>	C_ACTION_REC.delete_flag	);

	-- Do not continue if the action is not allowed for the BR

	ARP_CT_PKG.fetch_p (l_trx_rec, p_customer_trx_id);

	IF	(C_ACTION_REC.uneliminate_flag	<>	'Y')
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( '>>>>>>>>>> The action ' || l_action || ' is not allowed on the BR ' || l_trx_rec.trx_number);
		END IF;
		FND_MESSAGE.set_name	( 'AR', 'AR_BR_CANNOT_UNELIMINATE' );
		FND_MESSAGE.set_token	( 'BRNUM'	,  l_trx_rec.trx_number);
		app_exception.raise_exception;
	END IF;


	/*----------------------------------------------+
        |   Data preparation 				|
        +-----------------------------------------------*/

	-- Fetch the current transaction history record information

	l_trh_rec.customer_trx_id	:=	p_customer_trx_id;
	ARP_TRANSACTION_HISTORY_PKG.lock_fetch_f_trx_id (l_trh_rec);

	l_trx_date			:=	trunc(p_risk_uneliminate_date);
	l_gl_date			:=	trunc(p_risk_uneliminate_gl_date);


	-- Fetch the previous transaction history record information

	l_trh_prev_rec.transaction_history_id	:=	l_trh_rec.prv_trx_history_id;
	AR_BILLS_MAINTAIN_STATUS_PUB.Find_Last_Relevant_Trh (l_trh_prev_rec);


	-- Fetch the Payment Schedule information

	AR_BILLS_CREATION_LIB_PVT.Get_Payment_Schedule_Id (p_customer_trx_id, l_ps_rec.payment_schedule_id);

        -- Modified for bug # 2712726
        -- ORASHID
        --
        l_nocopy_payment_schedule_id := l_ps_rec.payment_schedule_id;
	arp_ps_pkg.fetch_p(l_nocopy_payment_schedule_id, l_ps_rec);



	/*----------------------------------------------+
        |   Data defaulting 				|
        +-----------------------------------------------*/

	AR_BILLS_MAINTAIN_LIB_PVT.Default_Action_Dates (l_trx_date, l_gl_date);


	/*----------------------------------------------+
        |   Data validation 				|
        +-----------------------------------------------*/

        l_mesg := arp_standard.fnd_message('AR_BR_SPMENU_UNELIMINATE');
	AR_BILLS_MAINTAIN_VAL_PVT.Validate_Action_Dates (l_trx_date, l_gl_date, l_trh_rec, l_mesg);

	l_trh_rec.trx_date		:=	l_trx_date	;
	l_trh_rec.gl_date		:=	l_gl_date	;
	l_trh_rec.comments		:=	p_risk_uneliminate_comments;


	/*-----------------------------------------------+
        |   RISK UNELIMINATION 				 |
        +-----------------------------------------------*/

	IF	(l_trh_prev_rec.status	=	C_MATURED_PEND_RISK_ELIM)
	THEN


		/*----------------------------------------------+
        	|   Unapply the receipt from the BR and apply	|
		|   it to short term debt			|
	        +-----------------------------------------------*/

		AR_BILLS_MAINTAIN_LIB_PVT.Find_Last_Receipt (l_trh_rec.customer_trx_id, l_cash_receipt_id);
		AR_BILLS_MAINTAIN_LIB_PVT.Unapply_Receipt   (l_trh_rec, l_ps_rec.payment_schedule_id, l_cash_receipt_id, C_RISK_UNELIMINATED);
		AR_BILLS_MAINTAIN_LIB_PVT.Apply_STD	    (p_customer_trx_id, l_cash_receipt_id, l_trh_rec.trx_date, l_trh_rec.gl_date);

		/*-----------------------------------------------+
        	|   Put the Remittance tags			 |
		|   on the BR Payment Schedule			 |
	        +-----------------------------------------------*/

		AR_BILLS_MAINTAIN_LIB_PVT.update_reserved_columns (l_ps_rec.payment_schedule_id, 'REMITTANCE' , l_trx_rec.remittance_batch_id);


	ELSIF	(l_trh_prev_rec.status	=	C_ENDORSED)
	THEN

		/*----------------------------------------------+
        	|   Reverse the adjustment created during	|
 		|   endorsement and create a new unapproved	|
		|   adjustment					|
	        +-----------------------------------------------*/

		AR_BILLS_MAINTAIN_LIB_PVT.Find_Last_Adjustment (l_trh_rec.customer_trx_id, l_adj_id);

		SELECT 	receivables_trx_id
		INTO	l_receivables_trx_id
		FROM	ar_adjustments
		WHERE	adjustment_id	=	l_adj_id;

		AR_BILLS_MAINTAIN_LIB_PVT.Reverse_Adjustment   (l_adj_id, l_trh_rec, C_RISK_UNELIMINATED);

		AR_BILLS_MAINTAIN_LIB_PVT.Create_Adjustment   (
					l_trh_rec			,
					p_customer_trx_id		,
					l_ps_rec			,
					l_ps_rec.amount_due_original	,
					l_receivables_trx_id		,
					'W'				,
					l_move_deferred_tax		,
					l_new_adj_id			);

		/*----------------------------------------------+
	        |    Updates the Payment Schedule of the BR 	|
		|    with the Adjustment Information		|
        	+-----------------------------------------------*/

		AR_BILLS_MAINTAIN_LIB_PVT.update_reserved_columns (l_ps_rec.payment_schedule_id, 'ADJUSTMENT', l_new_adj_id);


	END IF;


	/*----------------------------------------------+
        |  Insert the Transaction History Record	|
        +-----------------------------------------------*/

	-- Fetch the new status and new event of the BR

	AR_BILLS_MAINTAIN_STATUS_PUB.New_Status_Event (
			p_trx_rec	=>	l_trx_rec	,
			p_action        =>	l_action	,
			p_new_status	=>	l_trh_rec.status,
			p_new_event	=>	l_trh_rec.event	);

	l_trh_rec.transaction_history_id:=	NULL		;
	l_trh_rec.postable_flag		:=	'N'		;
	l_trh_rec.current_accounted_flag:=	'N'		;
	l_trh_rec.current_record_flag	:=  	'Y'		;
	l_trh_rec.prv_trx_history_id	:=  	NULL		;
	l_trh_rec.posting_control_id    := 	-3           	;
	l_trh_rec.gl_posted_date        :=  	NULL        	;
	l_trh_rec.first_posted_record_flag  := 	'N'		;
	l_trh_rec.created_from		:=	'ARBRMAIB'	;
	l_trh_rec.batch_id		:=	NULL		;

	arp_proc_transaction_history.insert_transaction_history (l_trh_rec	,
								 l_trh_rec.transaction_history_id);


	/*-----------------------------------------------+
        |   Output parameter				 |
        +------------------------------------------------*/

	p_status			:=	l_trh_rec.status	;


       /*-----------------------------------------------+
        |   Standard check of p_commit   		|
        +-----------------------------------------------*/

        IF FND_API.To_Boolean( p_commit )
        THEN

            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug( 'committing');
            END IF;
            Commit;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('AR_BILLS_MAINTAIN_PUB.UnEliminate_Risk_BR ()- ');
        END IF;


EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;
                ROLLBACK TO UnEliminate_Risk_BR_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
  	        IF PG_DEBUG in ('Y', 'C') THEN
  	           arp_util.debug( 'Exception Error');
  	        END IF;
		RAISE;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;
                ROLLBACK TO UnEliminate_Risk_BR_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( 'Exception Unexpected Error');
		END IF;
		RAISE;


        WHEN OTHERS THEN
               /*-------------------------------------------------------+
                |  Handle application errors that result from trapable  |
                |  error conditions. The error messages have already    |
                |  been put on the error stack.                         |
                +-------------------------------------------------------*/

		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;

		IF (SQLCODE = -20001)
                THEN
	               	ROLLBACK TO UnEliminate_Risk_BR_PVT;
                      	x_return_status := FND_API.G_RET_STS_ERROR ;
                      	RAISE;
                ELSE
		      	NULL;
                END IF;

                ROLLBACK TO UnEliminate_Risk_BR_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		RAISE;


END UnEliminate_Risk_BR;


/*==============================================================================+
 | PROCEDURE                                                                 	|
 |    Exchange_BR			                                     	|
 |                                                                           	|
 | DESCRIPTION                                                               	|
 |    Exchanges a BR for another					     	|
 |									  	|
 +==============================================================================*/


PROCEDURE Exchange_BR (

           --   *****  Standard API parameters *****

                p_api_version      		IN  	NUMBER					,
                p_init_msg_list    		IN  	VARCHAR2 := FND_API.G_TRUE		,
                p_commit           		IN  	VARCHAR2 := FND_API.G_FALSE		,
                p_validation_level 		IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL	,
                x_return_status    		OUT NOCOPY 	VARCHAR2				,
                x_msg_count        		OUT NOCOPY 	NUMBER					,
                x_msg_data         		OUT NOCOPY 	VARCHAR2				,

           --   *****  Input parameters  *****

		p_customer_trx_id		IN 	NUMBER	,

           --   *****  Output parameters  *****

		p_new_customer_trx_id		OUT NOCOPY 	NUMBER					,
		p_new_trx_number		OUT NOCOPY 	VARCHAR2) IS


  l_api_name		  CONSTANT VARCHAR2(20)	:= 'Exchange_BR';
  l_api_version		  CONSTANT NUMBER := 1.0;
  l_trx_rec		  ra_customer_trx%ROWTYPE;
  l_trh_rec		  ar_transaction_history%ROWTYPE;
  l_ps_rec		  ar_payment_schedules%ROWTYPE;
  l_action_rec		  action_rec_type;
  l_status		  VARCHAR2(30);
  l_customer_trx_line_id  ra_customer_trx_lines.customer_trx_line_id%TYPE;
  l_msg_count   	  NUMBER;
  l_msg_data     	  VARCHAR2(2000);
  l_return_status	  VARCHAR2(1);

  l_action		  VARCHAR2(30) := C_EXCHANGE;

  -- Added for bug # 2712726
  -- ORASHID
  --
  l_nocopy_payment_schedule_id  ar_payment_schedules.payment_schedule_id%TYPE;

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('AR_BILLS_MAINTAIN_PUB.Exchange_BR()+ ');
	END IF;

	x_msg_count				:=	NULL;
	x_msg_data				:=	NULL;

       /*-----------------------------------------------+
        |   Standard start of API savepoint     	|
        +-----------------------------------------------*/

      	SAVEPOINT Exchange_BR_PVT;


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


       /*--------------------------------------------------------------+
        |   Initialize message list if p_init_msg_list is set to TRUE  |
        +--------------------------------------------------------------*/

        IF  FND_API.to_Boolean( p_init_msg_list )  THEN
 	             FND_MSG_PUB.initialize;
        END IF;


       /*-----------------------------------------------+
        |   Initialize return status to SUCCESS   	|
        +-----------------------------------------------*/

        x_return_status := FND_API.G_RET_STS_SUCCESS;


       /*-----------------------------------------------------------------------+
        |   ============  START OF API BODY - EXCHANGE BR ===================  	|
        +-----------------------------------------------------------------------*/


	/*-----------------------------------------------+
        |   Action Validation				 |
        +-----------------------------------------------*/


	AR_BILLS_MAINTAIN_STATUS_PUB.validate_actions (
		p_customer_trx_id	=>  	p_customer_trx_id		,
		p_complete_flag		=>	C_ACTION_REC.complete_flag	,
		p_uncomplete_flag	=>	C_ACTION_REC.uncomplete_flag	,
		p_accept_flag		=>	C_ACTION_REC.accept_flag	,
		p_cancel_flag		=>	C_ACTION_REC.cancel_flag	,
		p_select_remit_flag	=>	C_ACTION_REC.select_remit_flag	,
		p_deselect_remit_flag	=>	C_ACTION_REC.deselect_remit_flag,
		p_approve_remit_flag	=>	C_ACTION_REC.approve_remit_flag	,
		p_hold_flag		=>	C_ACTION_REC.hold_flag		,
		p_unhold_flag		=>	C_ACTION_REC.unhold_flag	,
		p_recall_flag		=>	C_ACTION_REC.recall_flag	,
		p_eliminate_flag	=>	C_ACTION_REC.eliminate_flag	,
		p_uneliminate_flag	=>	C_ACTION_REC.uneliminate_flag	,
		p_unpaid_flag		=>	C_ACTION_REC.unpaid_flag	,
		p_protest_flag		=>	C_ACTION_REC.protest_flag	,
		p_endorse_flag		=>	C_ACTION_REC.endorse_flag	,
		p_restate_flag		=>	C_ACTION_REC.restate_flag	,
		p_exchange_flag		=>	C_ACTION_REC.exchange_flag	,
		p_delete_flag		=>	C_ACTION_REC.delete_flag	);


	-- Do not continue if the action is not allowed for the BR

	ARP_CT_PKG.lock_fetch_p (l_trx_rec, p_customer_trx_id);

	IF	(C_ACTION_REC.exchange_flag	<>	'Y')
	THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( '>>>>>>>>>> The action ' || l_action || ' is not allowed on the BR ' || p_customer_trx_id);
		END IF;
		FND_MESSAGE.set_name	( 'AR', 'AR_BR_CANNOT_EXCHANGE' );
		FND_MESSAGE.set_token	( 'BRNUM' 	,  l_trx_rec.trx_number);
		app_exception.raise_exception;
	END IF;



       /*-----------------------------------------------+
        |   Data preparation 				|
        +-----------------------------------------------*/

	l_trh_rec.customer_trx_id	:=	p_customer_trx_id;
	ARP_TRANSACTION_HISTORY_PKG.lock_fetch_f_trx_id (l_trh_rec);

	AR_BILLS_CREATION_LIB_PVT.Get_Payment_Schedule_Id (p_customer_trx_id, l_ps_rec.payment_schedule_id);

        -- Modified for bug # 2712726
        -- ORASHID
        --
        l_nocopy_payment_schedule_id := l_ps_rec.payment_schedule_id;
	arp_ps_pkg.fetch_p(l_nocopy_payment_schedule_id, l_ps_rec);

	/*-----------------------------------------------+
        |   Creation of the new BR			 |
        +------------------------------------------------*/

        /* 5191632 - Added LE_ID and ORG_ID to create call */

	AR_BILLS_CREATION_PUB.create_br_header (

		p_api_version 			=>  1.0					,
	        x_return_status 		=>  l_return_status			,
	        p_init_msg_list    		=>  FND_API.G_TRUE			,
	        x_msg_count     		=>  l_msg_count				,
	        x_msg_data     	 		=>  l_msg_data				,

	 	p_trx_number			=>  NULL				,
		p_term_due_date			=>  l_trx_rec.term_due_date		,
		p_batch_source_id		=>  l_trx_rec.batch_source_id		,
		p_cust_trx_type_id		=>  l_trx_rec.cust_trx_type_id		,
		p_invoice_currency_code		=>  l_trx_rec.invoice_currency_code	,
		p_br_amount			=>  l_ps_rec.amount_due_remaining	,
		p_trx_date			=>  l_trx_rec.trx_date			,
		p_gl_date			=>  l_trh_rec.gl_date			,
		p_drawee_id			=>  l_trx_rec.drawee_id			,
		p_drawee_site_use_id		=>  l_trx_rec.drawee_site_use_id	,
		p_drawee_contact_id		=>  l_trx_rec.drawee_contact_id		,
		p_printing_option		=>  l_trx_rec.printing_option		,
		p_comments			=>  l_trx_rec.comments			,
		p_special_instructions  	=>  l_trx_rec.special_instructions	,
		p_drawee_bank_account_id     	=>  l_trx_rec.drawee_bank_account_id	,
		p_remittance_bank_account_id 	=>  l_trx_rec.remit_bank_acct_use_id,
		p_override_remit_account_flag	=>  l_trx_rec.override_remit_account_flag,
		p_batch_id			=>  l_trx_rec.batch_id			,
		p_doc_sequence_id		=>  NULL				,
		p_doc_sequence_value		=>  NULL				,
		p_created_from			=>  'ARBRMAIB'				,
		p_attribute_category		=>  l_trx_rec.attribute_category	,
		p_attribute1			=>  l_trx_rec.attribute1		,
		p_attribute2			=>  l_trx_rec.attribute2		,
		p_attribute3			=>  l_trx_rec.attribute3		,
		p_attribute4			=>  l_trx_rec.attribute4		,
		p_attribute5			=>  l_trx_rec.attribute5		,
		p_attribute6			=>  l_trx_rec.attribute6		,
		p_attribute7			=>  l_trx_rec.attribute7		,
		p_attribute8			=>  l_trx_rec.attribute8		,
		p_attribute9			=>  l_trx_rec.attribute9		,
		p_attribute10			=>  l_trx_rec.attribute10		,
		p_attribute11			=>  l_trx_rec.attribute11		,
		p_attribute12			=>  l_trx_rec.attribute12		,
		p_attribute13			=>  l_trx_rec.attribute13		,
		p_attribute14			=>  l_trx_rec.attribute14		,
		p_attribute15			=>  l_trx_rec.attribute15		,
                p_le_id                         =>  l_trx_rec.legal_entity_id,
                p_org_id                        =>  l_trx_rec.org_id,
		p_customer_trx_id		=>  p_new_customer_trx_id		,
		p_new_trx_number		=>  p_new_trx_number			,
		p_status			=>  l_status				);

	IF  (l_return_status <> 'S')
	THEN
			IF PG_DEBUG in ('Y', 'C') THEN
			   arp_util.debug( '>>>>>>>>>> Problems during the creation of the new BR');
			   arp_util.debug( 'l_msg_count   : ' || l_msg_count);
			   arp_util.debug( 'l_msg_data    : ' || l_msg_data);
			END IF;
			RAISE  API_exception;
	END IF;


	/*-----------------------------------------------+
        |   Assign the old BR to the new BR		 |
        +------------------------------------------------*/

	AR_BILLS_CREATION_PUB.create_br_assignment (

		p_api_version 			=>  1.0				,
	        p_init_msg_list 		=>  FND_API.G_TRUE		,
		p_commit			=>  FND_API.G_FALSE		,
		p_validation_level		=>  FND_API.G_VALID_LEVEL_FULL	,
	        x_return_status 		=>  l_return_status		,
	        x_msg_count     		=>  l_msg_count			,
        	x_msg_data     	 		=>  l_msg_data			,

		p_customer_trx_id		=>  p_new_customer_trx_id	,
	 	p_br_ref_payment_schedule_id 	=>  l_ps_rec.payment_schedule_id,
		p_assigned_amount		=>  l_ps_rec.amount_due_remaining,
		p_attribute_category		=>  NULL	,
		p_attribute1			=>  NULL	,
		p_attribute2			=>  NULL	,
		p_attribute3			=>  NULL	,
		p_attribute4			=>  NULL	,
		p_attribute5			=>  NULL	,
		p_attribute6			=>  NULL	,
		p_attribute7			=>  NULL	,
		p_attribute8			=>  NULL	,
		p_attribute9			=>  NULL	,
		p_attribute10			=>  NULL	,
		p_attribute11			=>  NULL	,
		p_attribute12			=>  NULL	,
		p_attribute13			=>  NULL	,
		p_attribute14			=>  NULL	,
		p_attribute15			=>  NULL	,
		p_customer_trx_line_id		=>  l_customer_trx_line_id);

	IF  (l_return_status <> 'S')
	THEN
			IF PG_DEBUG in ('Y', 'C') THEN
			   arp_util.debug( '>>>>>>>>>> Problems during the assignment of the exchanged BR to the new BR');
			   arp_util.debug( 'l_msg_count   : ' || l_msg_count);
			   arp_util.debug( 'l_msg_data    : ' || l_msg_data);
			END IF;
			RAISE  API_exception;
	END IF;



	/*-----------------------------------------------+
        |   Update the event of the new BR created	 |
        +------------------------------------------------*/

	l_trh_rec.customer_trx_id	:=	p_new_customer_trx_id;
	ARP_TRANSACTION_HISTORY_PKG.lock_fetch_f_trx_id (l_trh_rec);

	l_trh_rec.event			:=	'EXCHANGED';

	ARP_PROC_TRANSACTION_HISTORY.update_transaction_history (l_trh_rec,
								 l_trh_rec.transaction_history_id);


       /*-----------------------------------------------+
        |   Standard check of p_commit   		|
        +-----------------------------------------------*/

        IF FND_API.To_Boolean( p_commit )
        THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug( 'committing');
            END IF;
            Commit;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('AR_BILLS_MAINTAIN_PUB.Exchange_BR()- ');
        END IF;


EXCEPTION
	WHEN 	API_exception 	THEN
	 	ROLLBACK TO Exchange_BR_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug ('API Exception : AR_BILLS_MAINTAIN_PUB.Exchange_BR : ' || SQLERRM);
		END IF;
		RAISE;

	WHEN FND_API.G_EXC_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;
                ROLLBACK TO Exchange_BR_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
  	        IF PG_DEBUG in ('Y', 'C') THEN
  	           arp_util.debug( 'Exception Error');
  	        END IF;
		RAISE;


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;
                ROLLBACK TO Exchange_BR_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( 'Exception Unexpected Error');
		END IF;
		RAISE;


        WHEN OTHERS THEN
               /*-------------------------------------------------------+
                |  Handle application errors that result from trapable  |
                |  error conditions. The error messages have already    |
                |  been put on the error stack.                         |
                +-------------------------------------------------------*/

		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_util.debug( 'SQLCODE : ' || SQLCODE);
                   arp_util.debug( 'SQLERRM : ' || SQLERRM);
                END IF;

		IF (SQLCODE = -20001)
                THEN
                      ROLLBACK TO Exchange_BR_PVT;
                      x_return_status := FND_API.G_RET_STS_ERROR ;
		      RAISE;
                ELSE
		      NULL;
                END IF;

                ROLLBACK TO Exchange_BR_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		RAISE;

END Exchange_BR;




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
  RETURN '$Revision: 120.11.12010000.4 $';
END revision;
--

END AR_BILLS_MAINTAIN_PUB;


/
